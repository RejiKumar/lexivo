"""Add summary_prompt_version for cache invalidation by prompt template.

Revision ID: 0009_summary_prompt_version
Revises: 0008_document_translation
Create Date: 2026-08-06
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "0009_summary_prompt_version"
down_revision: Union[str, Sequence[str], None] = "0008_document_translation"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        "documents",
        sa.Column("summary_prompt_version", sa.String(length=16), nullable=True),
    )


def downgrade() -> None:
    op.drop_column("documents", "summary_prompt_version")
