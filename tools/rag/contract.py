"""Shared RAG contract constants loaded from ``rag_contract.json``.

This keeps search/read/context/indexing limits and defaults in one place for both
Python and tooling integrations.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any

WORKSPACE_ROOT = Path(__file__).resolve().parent.parent.parent
CONTRACT_PATH = WORKSPACE_ROOT / "tools" / "rag" / "rag_contract.json"


def _load_contract() -> dict[str, Any]:
    try:
        if CONTRACT_PATH.exists():
            return json.loads(CONTRACT_PATH.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return {}
    return {}


RAG_CONTRACT = _load_contract()


def _as_int(value: Any, default: int) -> int:
    try:
        return int(value)
    except (TypeError, ValueError):
        return default


def _clamp_range(section: str, key: str, fallback: tuple[int, int, int]) -> tuple[int, int, int]:
    fallback_min, fallback_max, fallback_default = fallback
    if fallback_min > fallback_max:
        fallback_min, fallback_max = fallback_max, fallback_min
    if not fallback_min <= fallback_default <= fallback_max:
        fallback_default = min(max(fallback_default, fallback_min), fallback_max)

    data = RAG_CONTRACT.get(section, {})
    if isinstance(data, dict):
        raw = data.get(key, {})
        if isinstance(raw, dict):
            minimum = _as_int(raw.get("min"), fallback[0])
            maximum = _as_int(raw.get("max"), fallback[1])
            default = _as_int(raw.get("default"), fallback[2])
            if minimum > maximum:
                minimum, maximum = maximum, minimum
            if default < minimum:
                default = minimum
            if default > maximum:
                default = maximum
            return (minimum, maximum, default)
    return (fallback_min, fallback_max, fallback_default)


def _as_string_list(section: str, key: str, fallback: list[str]) -> list[str]:
    data = RAG_CONTRACT.get(section, {})
    if isinstance(data, dict):
        values = data.get(key)
        if isinstance(values, list):
            return [str(value) for value in values]
    return list(fallback)


RAG_SEARCH_LIMIT_MIN, RAG_SEARCH_LIMIT_MAX, RAG_SEARCH_LIMIT_DEFAULT = _clamp_range(
    "search",
    "limit",
    (1, 25, 8),
)

RAG_READ_NEIGHBORS_MIN, RAG_READ_NEIGHBORS_MAX, RAG_READ_NEIGHBORS_DEFAULT = _clamp_range(
    "read",
    "neighbors",
    (0, 3, 1),
)
RAG_READ_CONTENT_CHARS_MIN, RAG_READ_CONTENT_CHARS_MAX, RAG_READ_CONTENT_CHARS_DEFAULT = _clamp_range(
    "read",
    "content_chars",
    (500, 100000, 12000),
)

RAG_CONTEXT_LIMIT_MIN, RAG_CONTEXT_LIMIT_MAX, RAG_CONTEXT_LIMIT_DEFAULT = _clamp_range(
    "context",
    "limit",
    (1, 25, 8),
)
RAG_CONTEXT_NEIGHBORS_MIN, RAG_CONTEXT_NEIGHBORS_MAX, RAG_CONTEXT_NEIGHBORS_DEFAULT = _clamp_range(
    "context",
    "neighbors",
    (0, 3, 1),
)
RAG_CONTEXT_CONTENT_CHARS_MIN, RAG_CONTEXT_CONTENT_CHARS_MAX, RAG_CONTEXT_CONTENT_CHARS_DEFAULT = _clamp_range(
    "context",
    "content_chars",
    (500, 100000, 8000),
)

RAG_EVAL_LIMIT_MIN, RAG_EVAL_LIMIT_MAX, RAG_EVAL_LIMIT_DEFAULT = _clamp_range(
    "eval",
    "limit",
    (3, 25, 10),
)

RAG_INDEXING_ALLOWED_EXTENSIONS = _as_string_list(
    "indexing",
    "allowed_extensions",
    [
        ".md",
        ".lua",
        ".rs",
        ".py",
        ".toml",
        ".json",
        ".html",
        ".js",
        ".ts",
        ".css",
        ".wgsl",
    ],
)

RAG_INDEXING_DEFAULT_TARGET_DIRS = _as_string_list(
    "indexing",
    "default_target_dirs",
    [
        "AGENTS.md",
        ".agents",
        ".codex",
        ".github",
        "content",
        "docs",
        "extension",
        "ideas",
        "library",
        "pages",
        "src",
        "tests",
        "tools",
    ],
)

RAG_WATCH_EXTENSIONS = _as_string_list(
    "watch",
    "extensions",
    RAG_INDEXING_ALLOWED_EXTENSIONS,
)
RAG_WATCH_PREFIXES = _as_string_list(
    "watch",
    "prefixes",
    RAG_INDEXING_DEFAULT_TARGET_DIRS,
)
