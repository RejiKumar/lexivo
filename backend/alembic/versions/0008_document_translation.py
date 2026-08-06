"""Add translation fields on documents.

Revision ID: 0008_document_translation
Revises: 0007_subscriptions
Create Date: 2026-08-06
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "0008_document_translation"
down_revision: Union[str, Sequence[str], None] = "0007_subscriptions"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    bind = op.get_bind()
    translation_status = sa.Enum(
        "idle",
        "processing",
        "ready",
        "failed",
        name="translation_status",
    )
    if bind.dialect.name == "postgresql":
        translation_status.create(bind, checkfirst=True)

    op.add_column(
        "documents",
        sa.Column("translated_text", sa.Text(), nullable=True),
    )
    op.add_column(
        "documents",
        sa.Column("source_lang", sa.String(length=16), nullable=True),
    )
    op.add_column(
        "documents",
        sa.Column("target_lang", sa.String(length=16), nullable=True),
    )
    op.add_column(
        "documents",
        sa.Column(
            "translation_status",
            translation_status,
            nullable=False,
            server_default="idle",
        ),
    )


def downgrade() -> None:
    op.drop_column("documents", "translation_status")
    op.drop_column("documents", "target_lang")
    op.drop_column("documents", "source_lang")
    op.drop_column("documents", "translated_text")
    bind = op.get_bind()
    if bind.dialect.name == "postgresql":
        sa.Enum(name="translation_status").drop(bind, checkfirst=True)
