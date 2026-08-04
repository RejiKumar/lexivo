"""Initial users, documents, jobs tables.

Revision ID: 0001_initial_core
Revises:
Create Date: 2026-08-04

Bootstrap notes:
- On Postgres, enable pgvector before RAG ingest:
  CREATE EXTENSION IF NOT EXISTS vector;
- document_chunks is deferred to the RAG step (no ingest logic here).
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "0001_initial_core"
down_revision: Union[str, Sequence[str], None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # pgvector is required later for document_chunks embeddings (RAG step).
    # Safe no-op on non-Postgres dialects used in unit tests.
    bind = op.get_bind()
    if bind.dialect.name == "postgresql":
        op.execute("CREATE EXTENSION IF NOT EXISTS vector")

    op.create_table(
        "users",
        sa.Column("id", sa.String(length=36), primary_key=True),
        sa.Column("external_id", sa.String(length=255), nullable=False),
        sa.Column("email", sa.String(length=320), nullable=True),
        sa.Column("display_name", sa.String(length=255), nullable=True),
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
        sa.UniqueConstraint("external_id"),
    )
    op.create_index("ix_users_external_id", "users", ["external_id"])

    document_status = sa.Enum(
        "processing", "ready", "failed", name="document_status"
    )
    job_status = sa.Enum(
        "queued", "running", "succeeded", "failed", name="job_status"
    )

    op.create_table(
        "documents",
        sa.Column("id", sa.String(length=36), primary_key=True),
        sa.Column("user_id", sa.String(length=36), nullable=False),
        sa.Column("title", sa.String(length=512), nullable=True),
        sa.Column("storage_key", sa.String(length=1024), nullable=True),
        sa.Column("status", document_status, nullable=False),
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
    )
    op.create_index("ix_documents_user_id", "documents", ["user_id"])

    op.create_table(
        "jobs",
        sa.Column("id", sa.String(length=36), primary_key=True),
        sa.Column("document_id", sa.String(length=36), nullable=False),
        sa.Column("job_type", sa.String(length=64), nullable=False),
        sa.Column("status", job_status, nullable=False),
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
        sa.ForeignKeyConstraint(
            ["document_id"], ["documents.id"], ondelete="CASCADE"
        ),
    )
    op.create_index("ix_jobs_document_id", "jobs", ["document_id"])


def downgrade() -> None:
    op.drop_index("ix_jobs_document_id", table_name="jobs")
    op.drop_table("jobs")
    op.drop_index("ix_documents_user_id", table_name="documents")
    op.drop_table("documents")
    op.drop_index("ix_users_external_id", table_name="users")
    op.drop_table("users")

    bind = op.get_bind()
    if bind.dialect.name == "postgresql":
        sa.Enum(name="job_status").drop(bind, checkfirst=True)
        sa.Enum(name="document_status").drop(bind, checkfirst=True)
