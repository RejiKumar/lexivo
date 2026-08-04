"""Add exports table for multi-section PDF export jobs.

Revision ID: 0005_exports
Revises: 0004_chats
Create Date: 2026-08-04
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "0005_exports"
down_revision: Union[str, Sequence[str], None] = "0004_chats"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    bind = op.get_bind()
    export_status = sa.Enum(
        "idle",
        "processing",
        "ready",
        "failed",
        name="export_status",
    )
    if bind.dialect.name == "postgresql":
        export_status.create(bind, checkfirst=True)

    op.create_table(
        "exports",
        sa.Column("id", sa.String(length=36), primary_key=True),
        sa.Column("user_id", sa.String(length=36), nullable=False),
        sa.Column("document_id", sa.String(length=36), nullable=False),
        sa.Column("include_summary", sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.Column(
            "include_translation", sa.Boolean(), nullable=False, server_default=sa.false()
        ),
        sa.Column("include_chat", sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.Column("status", export_status, nullable=False),
        sa.Column("storage_key", sa.String(length=1024), nullable=True),
        sa.Column("signed_url", sa.String(length=2048), nullable=True),
        sa.Column("error_message", sa.Text(), nullable=True),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("CURRENT_TIMESTAMP"),
            nullable=False,
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("CURRENT_TIMESTAMP"),
            nullable=False,
        ),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(
            ["document_id"], ["documents.id"], ondelete="CASCADE"
        ),
    )
    op.create_index("ix_exports_user_id", "exports", ["user_id"])
    op.create_index("ix_exports_document_id", "exports", ["document_id"])


def downgrade() -> None:
    op.drop_index("ix_exports_document_id", table_name="exports")
    op.drop_index("ix_exports_user_id", table_name="exports")
    op.drop_table("exports")
    bind = op.get_bind()
    if bind.dialect.name == "postgresql":
        sa.Enum(name="export_status").drop(bind, checkfirst=True)
