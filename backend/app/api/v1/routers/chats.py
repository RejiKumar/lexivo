"""Thin chats router — ensure / list / ask via ChatService only."""

from fastapi import APIRouter, Depends, HTTPException, status

from app.adapters.types import UserIdentity
from app.api.deps import get_chat_service, get_user_service
from app.core.security import get_current_user
from app.schemas.chats import (
    ChatMessageCreate,
    ChatMessageListResponse,
    ChatMessageResponse,
    ChatResponse,
)
from app.services.base import ConflictError, NotFoundError, ValidationError
from app.services.chat_service import ChatService
from app.services.user_service import UserService

router = APIRouter(prefix="/chats", tags=["chats"])


async def _current_db_user(
    identity: UserIdentity = Depends(get_current_user),
    users: UserService = Depends(get_user_service),
):
    return users.upsert_from_identity(identity)


@router.post(
    "/{doc_id}",
    response_model=ChatResponse,
    status_code=status.HTTP_200_OK,
)
async def ensure_chat(
    doc_id: str,
    user=Depends(_current_db_user),
    chats: ChatService = Depends(get_chat_service),
) -> ChatResponse:
    try:
        chat = chats.ensure_chat(document_id=doc_id, user_id=user.id)
    except NotFoundError as exc:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=exc.message,
        ) from exc
    return ChatResponse.model_validate(chat)


@router.get(
    "/{doc_id}/messages",
    response_model=ChatMessageListResponse,
)
async def list_chat_messages(
    doc_id: str,
    user=Depends(_current_db_user),
    chats: ChatService = Depends(get_chat_service),
) -> ChatMessageListResponse:
    try:
        messages = chats.list_messages(document_id=doc_id, user_id=user.id)
    except NotFoundError as exc:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=exc.message,
        ) from exc
    return ChatMessageListResponse(
        items=[ChatMessageResponse.model_validate(m) for m in messages]
    )


@router.post(
    "/{doc_id}/messages",
    response_model=ChatMessageResponse,
    status_code=status.HTTP_200_OK,
)
async def post_chat_message(
    doc_id: str,
    body: ChatMessageCreate,
    user=Depends(_current_db_user),
    chats: ChatService = Depends(get_chat_service),
) -> ChatMessageResponse:
    try:
        message = await chats.ask(
            document_id=doc_id,
            user_id=user.id,
            content=body.content,
        )
    except NotFoundError as exc:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=exc.message,
        ) from exc
    except ConflictError as exc:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=exc.message,
        ) from exc
    except ValidationError as exc:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=exc.message,
        ) from exc
    return ChatMessageResponse.model_validate(message)
