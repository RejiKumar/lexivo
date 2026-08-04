"""Export table repository (SQL only)."""

from __future__ import annotations

from datetime import UTC, datetime
from typing import Any

from sqlalchemy.orm import Session

from app.models import Export, ExportStatus
from app.repositories.base import BaseRepository


class ExportRepository(BaseRepository[Export]):
    model = Export

    def __init__(self, session: Session) -> None:
        super().__init__(session)

    def create(
        self,
        *,
        user_id: str,
        document_id: str,
        include_summary: bool = False,
        include_translation: bool = False,
        include_chat: bool = False,
        status: ExportStatus = ExportStatus.idle,
        **fields: Any,
    ) -> Export:
        now = datetime.now(UTC)
        fields.setdefault("created_at", now)
        fields.setdefault("updated_at", now)
        return super().create(
            user_id=user_id,
            document_id=document_id,
            include_summary=include_summary,
            include_translation=include_translation,
            include_chat=include_chat,
            status=status,
            **fields,
        )

    def get_latest_for_document(
        self, *, document_id: str, user_id: str
    ) -> Export | None:
        return (
            self.session.query(Export)
            .filter(
                Export.document_id == document_id,
                Export.user_id == user_id,
            )
            .order_by(
                Export.created_at.desc(),
                Export.updated_at.desc(),
                Export.id.desc(),
            )
            .first()
        )
