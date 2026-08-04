"""RagConfig — chunk/overlap/strategy knobs; no per-document-type branches."""

from __future__ import annotations

from enum import Enum

from pydantic import BaseModel, Field, model_validator


class ChunkStrategy(str, Enum):
    fixed = "fixed"
    paragraph = "paragraph"


class RagConfig(BaseModel):
    """Pipeline parameters. Callers pick values; pipeline code stays type-agnostic."""

    chunk_size: int = Field(..., gt=0)
    chunk_overlap: int = Field(..., ge=0)
    strategy: ChunkStrategy = ChunkStrategy.fixed
    top_k: int = Field(default=5, gt=0)
    dense_weight: float = Field(default=0.5, ge=0.0)
    keyword_weight: float = Field(default=0.5, ge=0.0)
    max_context_chars: int | None = Field(default=None, gt=0)

    @model_validator(mode="after")
    def _overlap_lt_size(self) -> RagConfig:
        if self.chunk_overlap >= self.chunk_size:
            raise ValueError("chunk_overlap must be less than chunk_size")
        return self
