"""Add short/detailed summary fields and summary_status on documents.

Revision ID: 0003_document_summaries
Revises: 0002_rag_chunks
Create Date: 2026-08-04
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "0003_document_summaries"
down_revision: Union[str, Sequence[str], None] = "0002_rag_chunks"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    bind = op.get_bind()
    summary_status = sa.Enum(
        "idle",
        "processing",
        "ready",
        "failed",
        name="summary_status",
    )
    if bind.dialect.name == "postgresql":
        summary_status.create(bind, checkfirst=True)

    op.add_column(
        "documents",
        sa.Column("short_summary", sa.Text(), nullable=True),
    )
    op.add_column(
        "documents",
        sa.Column("detailed_summary", sa.Text(), nullable=True),
    )
    op.add_column(
        "documents",
        sa.Column(
            "summary_status",
            summary_status,
            nullable=False,
            server_default="idle",
        ),
    )


def downgrade() -> None:
    op.drop_column("documents", "summary_status")
    op.drop_column("documents", "detailed_summary")
    op.drop_column("documents", "short_summary")
    bind = op.get_bind()
    if bind.dialect.name == "postgresql":
        sa.Enum(name="summary_status").drop(bind, checkfirst=True)
