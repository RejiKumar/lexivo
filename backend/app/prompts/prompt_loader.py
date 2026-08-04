"""Shared prompt loader — reads versioned templates from ``app/prompts/`` only.

Agents MUST load prompt bodies via this module; never inline prompt strings.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

import yaml

_PROMPTS_ROOT = Path(__file__).resolve().parent


@dataclass(frozen=True, slots=True)
class PromptTemplate:
    """Loaded prompt template with structured fields."""

    name: str
    version: str
    template: str
    metadata: dict[str, Any]


class PromptNotFoundError(FileNotFoundError):
    """Raised when a named/versioned prompt template cannot be found."""


class PromptPathError(ValueError):
    """Raised when a prompt path escapes the prompts directory."""


def _resolve_template_path(name: str, version: str) -> Path:
    if not name or not version:
        raise PromptPathError("Prompt name and version are required")
    if ".." in name or ".." in version or "/" in name or "\\" in name:
        raise PromptPathError(f"Invalid prompt path components: {name!r}/{version!r}")
    if Path(name).is_absolute() or Path(version).is_absolute():
        raise PromptPathError("Absolute prompt paths are not allowed")

    candidate = (_PROMPTS_ROOT / name / f"{version}.yaml").resolve()
    root = _PROMPTS_ROOT.resolve()
    if not candidate.is_relative_to(root):
        raise PromptPathError(f"Path traversal rejected for prompt {name}/{version}")
    return candidate


def load(name: str, version: str = "v1") -> PromptTemplate:
    """Load a versioned prompt template from ``app/prompts/<name>/<version>.yaml``."""
    path = _resolve_template_path(name, version)
    if not path.is_file():
        raise PromptNotFoundError(
            f"Prompt template not found: {name}/{version} (expected {path})"
        )

    raw = yaml.safe_load(path.read_text(encoding="utf-8"))
    if not isinstance(raw, dict):
        raise ValueError(f"Prompt {name}/{version} must be a YAML mapping")

    template_text = raw.get("template")
    if not isinstance(template_text, str) or not template_text.strip():
        raise ValueError(f"Prompt {name}/{version} missing non-empty 'template' field")

    meta = {k: v for k, v in raw.items() if k not in {"name", "version", "template"}}
    return PromptTemplate(
        name=str(raw.get("name", name)),
        version=str(raw.get("version", version)),
        template=template_text,
        metadata=meta,
    )
