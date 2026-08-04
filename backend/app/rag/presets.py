"""Named RagConfig presets for callers (not used for pipeline branching).

Document-type names appear only as preset labels here / in tests — never as
control-flow switches inside chunker/embedder/retriever/pipeline modules.
"""

from __future__ import annotations

from app.rag.config import ChunkStrategy, RagConfig

CONTRACT_CONFIG = RagConfig(
    chunk_size=800,
    chunk_overlap=100,
    strategy=ChunkStrategy.paragraph,
    top_k=8,
    dense_weight=0.6,
    keyword_weight=0.4,
    max_context_chars=6000,
)

RECEIPT_CONFIG = RagConfig(
    chunk_size=200,
    chunk_overlap=20,
    strategy=ChunkStrategy.fixed,
    top_k=4,
    dense_weight=0.4,
    keyword_weight=0.6,
    max_context_chars=2000,
)

DEFAULT_CONFIG = RagConfig(
    chunk_size=500,
    chunk_overlap=50,
    strategy=ChunkStrategy.fixed,
)

PRESETS: dict[str, RagConfig] = {
    "contract": CONTRACT_CONFIG,
    "receipt": RECEIPT_CONFIG,
    "default": DEFAULT_CONFIG,
}


def resolve_config(name_or_dict: str | dict | RagConfig) -> RagConfig:
    """Resolve a preset name, raw dict, or RagConfig instance."""
    if isinstance(name_or_dict, RagConfig):
        return name_or_dict
    if isinstance(name_or_dict, dict):
        return RagConfig.model_validate(name_or_dict)
    key = name_or_dict.strip().lower()
    if key not in PRESETS:
        raise KeyError(f"Unknown RagConfig preset: {name_or_dict}")
    return PRESETS[key]
