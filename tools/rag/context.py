"""
Build an agent-friendly context bundle from the local Lurek2D RAG index.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

from query import search_index

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")


DEFAULT_EXPANSIONS = [
    "AGENTS workflow Codex skills",
    "source spec tests examples",
]


def build_context_bundle(
    prompt: str,
    *,
    profile: str = "all",
    limit: int = 8,
    neighbors: int = 1,
    content_chars: int = 8000,
    db_path: Path | None = None,
) -> dict[str, Any]:
    searches = [prompt]
    lowered = prompt.lower()
    if "codex" not in lowered and "agent" not in lowered:
        searches.append(f"{prompt} {' '.join(DEFAULT_EXPANSIONS)}")
    if "test" not in lowered:
        searches.append(f"{prompt} tests coverage")

    seen: set[str] = set()
    results: list[dict[str, Any]] = []
    search_reports: list[dict[str, Any]] = []
    per_search_limit = max(3, limit)

    for query_text in searches:
        report = search_index(
            query_text,
            profile,
            per_search_limit,
            db_path,
            include_content=True,
            content_chars=content_chars,
            neighbors=neighbors,
        )
        search_reports.append(
            {
                "query": query_text,
                "error": report.get("error"),
                "result_count": len(report.get("results", [])),
            }
        )
        for item in report.get("results", []):
            chunk_id = item["id"]
            if chunk_id in seen:
                continue
            seen.add(chunk_id)
            results.append(item)
            if len(results) >= limit:
                break
        if len(results) >= limit:
            break

    return {
        "prompt": prompt,
        "profile": profile,
        "searches": search_reports,
        "results": results,
    }


def main() -> None:
    parser = argparse.ArgumentParser(description="Build a RAG context bundle for an agent task")
    parser.add_argument("prompt", help="Task prompt or search intent")
    parser.add_argument("--profile", choices=["all", "game", "engine"], default="all")
    parser.add_argument("--limit", type=int, default=8)
    parser.add_argument("--neighbors", type=int, default=1)
    parser.add_argument("--content-chars", type=int, default=8000)
    parser.add_argument("--db", help="Override DB path for tests")
    args = parser.parse_args()
    result = build_context_bundle(
        args.prompt,
        profile=args.profile,
        limit=args.limit,
        neighbors=args.neighbors,
        content_chars=args.content_chars,
        db_path=Path(args.db) if args.db else None,
    )
    print(json.dumps(result, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
