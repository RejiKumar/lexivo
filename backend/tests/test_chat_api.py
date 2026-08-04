"""Tests for chat schemas, ChatService, and thin /api/v1/chats routes."""

from __future__ import annotations

from pathlib import Path
from unittest.mock import AsyncMock, patch

import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

from app.adapters.types import UserIdentity
from app.agents.base_agent import AgentResult
from app.models import ChatMessageRole, DocumentStatus
from app.repositories.chat_repo import ChatMessageRepository, ChatRepository
from app.repositories.chunk_repo import DocumentChunkRepository
from app.repositories.document_repo import DocumentRepository
from app.repositories.user_repo import UserRepository
from app.schemas import (
    ChatMessageCreate,
    ChatMessageListResponse,
    ChatMessageResponse,
    ChatResponse,
)
from app.services.base import ConflictError, NotFoundError, ValidationError
from app.services.chat_service import CANNOT_ANSWER, ChatService
from app.services.user_service import UserService
from tests.conftest import make_auth_header
from tests.fakes import FakeLLMProvider


def test_chat_schemas_serialize_with_citations() -> None:
    chat = ChatResponse(
        id="c1",
        user_id="u1",
        document_id="d1",
        created_at=None,
        updated_at=None,
    )
    assert chat.model_dump()["document_id"] == "d1"

    msg = ChatMessageResponse(
        id="m1",
        chat_id="c1",
        role="assistant",
        content="Answer grounded in lease.",
        citations=[
            {"chunk_id": "ch1", "index": 0, "snippet": "rent is due"},
            {"index": 1, "snippet": "deposit"},
        ],
        created_at=None,
    )
    dumped = msg.model_dump()
    assert dumped["role"] == "assistant"
    assert dumped["citations"][0]["snippet"] == "rent is due"

    listing = ChatMessageListResponse(items=[msg])
    assert len(listing.items) == 1

    create = ChatMessageCreate(content="What is the rent?")
    assert create.model_dump() == {"content": "What is the rent?"}


def test_chat_service_module_enters_via_master_only() -> None:
    service_src = (
        Path(__file__).resolve().parents[1] / "app" / "services" / "chat_service.py"
    ).read_text(encoding="utf-8")
    router_src = (
        Path(__file__).resolve().parents[1]
        / "app"
        / "api"
        / "v1"
        / "routers"
        / "chats.py"
    ).read_text(encoding="utf-8")
    for source in (service_src, router_src):
        assert "SearchAgent" not in source
        assert "CitationAgent" not in source
        assert "search_agent" not in source
        assert "citation_agent" not in source
        assert "RagPipeline" not in source
    assert "run_master" in service_src
    assert "from app.agents.master_agent import run_master" in service_src
    assert "run_master" not in router_src


def _ready_ingested_doc(db_session: Session, *, subject: str, text: str = "Lease body"):
    users = UserService(UserRepository(db_session))
    user = users.upsert_from_identity(
        UserIdentity(subject=subject, email=f"{subject}@example.com")
    )
    docs = DocumentRepository(db_session)
    doc = docs.create(
        user_id=user.id,
        title="Ready",
        storage_key="documents/u1/ready.pdf",
        status=DocumentStatus.ready,
        extracted_text=text,
    )
    DocumentChunkRepository(db_session).create(
        document_id=doc.id,
        chunk_index=0,
        content=text,
        embedding=[0.1] * 32,
    )
    return user, docs, doc


def _chat_service(db_session: Session, *, llm: FakeLLMProvider | None = None) -> ChatService:
    return ChatService(
        ChatRepository(db_session),
        ChatMessageRepository(db_session),
        DocumentRepository(db_session),
        DocumentChunkRepository(db_session),
        llm=llm or FakeLLMProvider(),
        rag_pipeline=object(),
    )


@pytest.mark.asyncio
async def test_chat_service_rejects_not_ready(db_session: Session) -> None:
    users = UserService(UserRepository(db_session))
    user = users.upsert_from_identity(
        UserIdentity(subject="chat-nr", email="nr@example.com")
    )
    docs = DocumentRepository(db_session)
    doc = docs.create(
        user_id=user.id,
        title="Processing",
        status=DocumentStatus.processing,
        extracted_text=None,
    )
    service = _chat_service(db_session)
    with pytest.raises(ConflictError, match="not ready"):
        await service.ask(document_id=doc.id, user_id=user.id, content="Q?")


@pytest.mark.asyncio
async def test_chat_service_rejects_not_ingested(db_session: Session) -> None:
    users = UserService(UserRepository(db_session))
    user = users.upsert_from_identity(
        UserIdentity(subject="chat-ni", email="ni@example.com")
    )
    docs = DocumentRepository(db_session)
    doc = docs.create(
        user_id=user.id,
        title="Ready empty",
        status=DocumentStatus.ready,
        extracted_text="body",
    )
    service = _chat_service(db_session)
    with pytest.raises(ConflictError, match="not ingested"):
        await service.ask(document_id=doc.id, user_id=user.id, content="Q?")


@pytest.mark.asyncio
async def test_chat_service_rejects_wrong_owner(db_session: Session) -> None:
    user, _docs, doc = _ready_ingested_doc(db_session, subject="chat-owner")
    other = UserService(UserRepository(db_session)).upsert_from_identity(
        UserIdentity(subject="other-chat", email="other@example.com")
    )
    service = _chat_service(db_session)
    with pytest.raises(NotFoundError):
        await service.ask(document_id=doc.id, user_id=other.id, content="Q?")


@pytest.mark.asyncio
async def test_chat_service_rejects_empty_content(db_session: Session) -> None:
    user, _docs, doc = _ready_ingested_doc(db_session, subject="chat-empty")
    service = _chat_service(db_session)
    with pytest.raises(ValidationError, match="empty"):
        await service.ask(document_id=doc.id, user_id=user.id, content="   ")


@pytest.mark.asyncio
async def test_chat_service_ask_persists_user_and_assistant(db_session: Session) -> None:
    user, _docs, doc = _ready_ingested_doc(db_session, subject="chat-ok")
    service = _chat_service(db_session)
    citations = [{"chunk_id": "ch1", "index": 0, "snippet": "rent is due"}]
    with patch(
        "app.services.chat_service.run_master",
        new=AsyncMock(
            return_value=AgentResult(
                success=True,
                data={
                    "answer": "Rent is due on the first.",
                    "citations": citations,
                    "ungrounded": False,
                    "cannot_answer": False,
                },
            )
        ),
    ) as mocked:
        assistant = await service.ask(
            document_id=doc.id,
            user_id=user.id,
            content="When is rent due?",
        )
        mocked.assert_awaited_once()
        call_args = mocked.await_args
        assert call_args.args[0] == "ask"
        assert call_args.args[1]["question"] == "When is rent due?"
        assert call_args.args[1]["document_id"] == doc.id

    assert assistant.role == ChatMessageRole.assistant
    assert assistant.content == "Rent is due on the first."
    assert assistant.citations == citations

    messages = service.list_messages(document_id=doc.id, user_id=user.id)
    assert len(messages) == 2
    assert messages[0].role == ChatMessageRole.user
    assert messages[0].content == "When is rent due?"
    assert messages[1].id == assistant.id


@pytest.mark.asyncio
async def test_chat_service_ungrounded_persists_cannot_answer(
    db_session: Session,
) -> None:
    user, _docs, doc = _ready_ingested_doc(db_session, subject="chat-ungrounded")
    service = _chat_service(db_session)
    with patch(
        "app.services.chat_service.run_master",
        new=AsyncMock(
            return_value=AgentResult(
                success=True,
                data={
                    "answer": CANNOT_ANSWER,
                    "citations": [],
                    "ungrounded": True,
                    "cannot_answer": True,
                },
            )
        ),
    ):
        assistant = await service.ask(
            document_id=doc.id,
            user_id=user.id,
            content="What is the secret code?",
        )
    assert assistant.content == CANNOT_ANSWER
    assert assistant.citations == []


@pytest.mark.asyncio
async def test_chat_service_master_failure_cannot_answer(db_session: Session) -> None:
    user, _docs, doc = _ready_ingested_doc(db_session, subject="chat-fail")
    service = _chat_service(db_session)
    with patch(
        "app.services.chat_service.run_master",
        new=AsyncMock(
            return_value=AgentResult(success=False, error="boom", data=None)
        ),
    ):
        assistant = await service.ask(
            document_id=doc.id,
            user_id=user.id,
            content="Anything?",
        )
    assert assistant.content == CANNOT_ANSWER


def test_chat_service_ensure_idempotent(db_session: Session) -> None:
    user, _docs, doc = _ready_ingested_doc(db_session, subject="chat-ensure")
    service = _chat_service(db_session)
    first = service.ensure_chat(document_id=doc.id, user_id=user.id)
    second = service.ensure_chat(document_id=doc.id, user_id=user.id)
    assert first.id == second.id


def test_openapi_includes_chat_paths(api_client: TestClient) -> None:
    paths = api_client.get("/openapi.json").json()["paths"]
    assert "/api/v1/chats/{doc_id}" in paths
    assert "/api/v1/chats/{doc_id}/messages" in paths


def test_api_ensure_chat_auth_and_idempotent(api_client: TestClient, db_session: Session) -> None:
    user, _docs, doc = _ready_ingested_doc(db_session, subject="api-chat-ensure")
    headers = make_auth_header(sub="api-chat-ensure")

    r1 = api_client.post(f"/api/v1/chats/{doc.id}", headers=headers)
    assert r1.status_code == 200
    body1 = r1.json()
    assert body1["document_id"] == doc.id
    assert body1["user_id"] == user.id

    r2 = api_client.post(f"/api/v1/chats/{doc.id}", headers=headers)
    assert r2.status_code == 200
    assert r2.json()["id"] == body1["id"]


def test_api_list_messages_empty_then_resume(
    api_client: TestClient, db_session: Session
) -> None:
    _user, _docs, doc = _ready_ingested_doc(db_session, subject="api-chat-list")
    headers = make_auth_header(sub="api-chat-list")

    empty = api_client.get(f"/api/v1/chats/{doc.id}/messages", headers=headers)
    assert empty.status_code == 200
    assert empty.json() == {"items": []}

    with patch(
        "app.services.chat_service.run_master",
        new=AsyncMock(
            return_value=AgentResult(
                success=True,
                data={
                    "answer": "Hello back",
                    "citations": [{"index": 0, "snippet": "hello"}],
                },
            )
        ),
    ):
        posted = api_client.post(
            f"/api/v1/chats/{doc.id}/messages",
            headers=headers,
            json={"content": "Hello?"},
        )
    assert posted.status_code == 200

    resumed = api_client.get(f"/api/v1/chats/{doc.id}/messages", headers=headers)
    assert resumed.status_code == 200
    items = resumed.json()["items"]
    assert len(items) == 2
    assert items[0]["role"] == "user"
    assert items[1]["role"] == "assistant"
    assert items[1]["citations"][0]["snippet"] == "hello"


def test_api_post_message_happy_path(
    api_client: TestClient, db_session: Session
) -> None:
    _user, _docs, doc = _ready_ingested_doc(db_session, subject="api-chat-ask")
    headers = make_auth_header(sub="api-chat-ask")
    with patch(
        "app.services.chat_service.run_master",
        new=AsyncMock(
            return_value=AgentResult(
                success=True,
                data={
                    "answer": "The deposit is one month.",
                    "citations": [
                        {"chunk_id": "c1", "index": 0, "snippet": "deposit"}
                    ],
                },
            )
        ),
    ):
        response = api_client.post(
            f"/api/v1/chats/{doc.id}/messages",
            headers=headers,
            json={"content": "What is the deposit?"},
        )
    assert response.status_code == 200
    body = response.json()
    assert body["role"] == "assistant"
    assert "deposit" in body["content"].lower()
    assert body["citations"][0]["index"] == 0


def test_api_post_message_409_not_ready(
    api_client: TestClient, db_session: Session
) -> None:
    users = UserService(UserRepository(db_session))
    user = users.upsert_from_identity(
        UserIdentity(subject="api-chat-409", email="nr@example.com")
    )
    doc = DocumentRepository(db_session).create(
        user_id=user.id,
        title="Processing",
        status=DocumentStatus.processing,
    )
    headers = make_auth_header(sub="api-chat-409")
    response = api_client.post(
        f"/api/v1/chats/{doc.id}/messages",
        headers=headers,
        json={"content": "Q?"},
    )
    assert response.status_code == 409
    assert "not ready" in response.json()["detail"].lower()


def test_api_post_message_409_not_ingested(
    api_client: TestClient, db_session: Session
) -> None:
    users = UserService(UserRepository(db_session))
    user = users.upsert_from_identity(
        UserIdentity(subject="api-chat-ni", email="ni@example.com")
    )
    doc = DocumentRepository(db_session).create(
        user_id=user.id,
        title="Ready",
        status=DocumentStatus.ready,
        extracted_text="body",
    )
    headers = make_auth_header(sub="api-chat-ni")
    response = api_client.post(
        f"/api/v1/chats/{doc.id}/messages",
        headers=headers,
        json={"content": "Q?"},
    )
    assert response.status_code == 409
    assert "not ingested" in response.json()["detail"].lower()


def test_api_post_message_422_empty_content(
    api_client: TestClient, db_session: Session
) -> None:
    _user, _docs, doc = _ready_ingested_doc(db_session, subject="api-chat-422")
    headers = make_auth_header(sub="api-chat-422")
    response = api_client.post(
        f"/api/v1/chats/{doc.id}/messages",
        headers=headers,
        json={"content": "   "},
    )
    assert response.status_code == 422


def test_api_post_message_ungrounded_200(
    api_client: TestClient, db_session: Session
) -> None:
    _user, _docs, doc = _ready_ingested_doc(db_session, subject="api-chat-ung")
    headers = make_auth_header(sub="api-chat-ung")
    with patch(
        "app.services.chat_service.run_master",
        new=AsyncMock(
            return_value=AgentResult(
                success=True,
                data={
                    "answer": CANNOT_ANSWER,
                    "citations": [],
                    "ungrounded": True,
                    "cannot_answer": True,
                },
            )
        ),
    ):
        response = api_client.post(
            f"/api/v1/chats/{doc.id}/messages",
            headers=headers,
            json={"content": "Unknown fact?"},
        )
    assert response.status_code == 200
    assert response.json()["content"] == CANNOT_ANSWER


def test_api_chats_require_auth(api_client: TestClient) -> None:
    response = api_client.post("/api/v1/chats/missing")
    assert response.status_code == 401
