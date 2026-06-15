"""
Build an agent-friendly context bundle from the local Lurek2D RAG index.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

from query import (
    RAG_CONTEXT_CONTENT_CHARS_DEFAULT,
    RAG_CONTEXT_CONTENT_CHARS_MAX,
    RAG_CONTEXT_CONTENT_CHARS_MIN,
    RAG_CONTEXT_LIMIT_MIN,
    RAG_CONTEXT_LIMIT_MAX,
    RAG_CONTEXT_NEIGHBORS_MAX,
    RAG_CONTEXT_NEIGHBORS_MIN,
    RAG_CONTEXT_DEFAULT_LIMIT,
    RAG_CONTEXT_DEFAULT_NEIGHBORS,
    hydrate_hits,
    read_api_usage_chunks,
    read_module_usage_chunks,
    read_navigation_chunks,
    read_related_chunks,
    read_tool_candidates,
    read_governing_contracts,
    search_index,
)

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")


def _clamp_rag_arg(value: int, name: str, min_value: int, max_value: int) -> int:
    if value < min_value or value > max_value:
        raise ValueError(f"`{name}` must be between {min_value} and {max_value}.")
    return value


GUIDANCE_TOKENS = {"agent", "agents", "contract", "contracts", "codex", "rule", "rules", "skill", "skills", "workflow"}
SOURCE_TOKENS = {"bug", "fix", "implement", "implementation", "module", "rust", "source", "src"}
API_TOKENS = {"api", "callback", "callbacks", "function", "functions", "method", "methods", "reference"}
GAMEPLAY_TOKENS = {
    "game",
    "gameplay",
    "player",
    "movement",
    "jump",
    "enemy",
    "camera",
    "scene",
    "sprite",
    "render",
    "physics",
    "tilemap",
    "input",
    "audio",
    "ui",
    "window",
    "example",
    "examples",
    "hud",
}
TOOLING_TOKENS = {"tool", "tools", "mcp", "command", "commands", "audit", "validate", "validator", "coverage", "check"}


def _bundle_intent(prompt: str) -> str:
    lowered = prompt.lower()
    tokens = set(lowered.split())
    if "lurek." in lowered or tokens & API_TOKENS:
        return "api"
    if tokens & TOOLING_TOKENS:
        return "tooling"
    if tokens & GAMEPLAY_TOKENS:
        return "gameplay"
    if tokens & GUIDANCE_TOKENS:
        return "navigation"
    if tokens & SOURCE_TOKENS:
        return "source"
    return "general"


def _bundle_budget(intent: str, limit: int, content_chars: int) -> dict[str, int]:
    budgets: dict[str, dict[str, int]] = {
        "api": {
            "search_results": min(limit, 4),
            "api_usage": min(max(limit, 3), 4),
            "module_usage": min(max(limit, 2), 3),
            "navigation": 2,
            "related": 2,
            "tool_candidates": 2,
            "content_chars": content_chars,
        },
        "gameplay": {
            "search_results": min(limit, 3),
            "api_usage": min(max(limit, 2), 3),
            "module_usage": min(max(limit, 3), 4),
            "navigation": 1,
            "related": 2,
            "tool_candidates": 1,
            "content_chars": min(content_chars, max(1400, content_chars)),
        },
        "tooling": {
            "search_results": min(limit, 3),
            "api_usage": 1,
            "module_usage": 1,
            "navigation": min(max(limit, 3), 4),
            "related": 2,
            "tool_candidates": min(max(limit, 4), 5),
            "content_chars": content_chars,
        },
        "navigation": {
            "search_results": min(limit, 3),
            "api_usage": 1,
            "module_usage": 1,
            "navigation": min(max(limit, 3), 4),
            "related": 2,
            "tool_candidates": 3,
            "content_chars": content_chars,
        },
        "source": {
            "search_results": min(limit, 4),
            "api_usage": 1,
            "module_usage": 2,
            "navigation": 1,
            "related": min(max(limit, 3), 4),
            "tool_candidates": 1,
            "content_chars": content_chars,
        },
        "general": {
            "search_results": limit,
            "api_usage": min(max(limit, 2), 3),
            "module_usage": min(max(limit, 2), 3),
            "navigation": 2,
            "related": 2,
            "tool_candidates": 2,
            "content_chars": content_chars,
        },
    }
    return budgets[intent]


def emit_payload(payload: dict[str, Any], *, json_output: bool = False, output_path: str | None = None) -> None:
    if output_path:
        Path(output_path).write_text(json.dumps(payload, ensure_ascii=False), encoding="utf-8")
        return
    if json_output:
        print(json.dumps(payload, ensure_ascii=False))
    else:
        print(json.dumps(payload, indent=2, ensure_ascii=False))


def _context_searches(prompt: str) -> list[str]:
    searches = [prompt]
    lowered = prompt.lower()
    tokens = set(lowered.split())
    if tokens & GUIDANCE_TOKENS and "agents" not in tokens:
        searches.append(f"{prompt} AGENTS rules workflow")
    elif tokens & SOURCE_TOKENS:
        searches.append(f"{prompt} source spec")
    elif tokens & API_TOKENS and "api" not in tokens:
        searches.append(f"{prompt} api reference")
    return searches


def build_context_bundle(
    prompt: str,
    *,
    profile: str = "all",
    limit: int = RAG_CONTEXT_DEFAULT_LIMIT,
    neighbors: int = RAG_CONTEXT_DEFAULT_NEIGHBORS,
    content_chars: int = RAG_CONTEXT_CONTENT_CHARS_DEFAULT,
    db_path: Path | None = None,
) -> dict[str, Any]:
    searches = _context_searches(prompt)
    intent = _bundle_intent(prompt)
    budget = _bundle_budget(intent, limit, content_chars)

    seen: set[str] = set()
    candidates: list[dict[str, Any]] = []
    search_reports: list[dict[str, Any]] = []
    per_search_limit = max(6, budget["search_results"] * 2)

    for query_text in searches:
        report = search_index(
            query_text,
            profile,
            per_search_limit,
            db_path,
            include_content=False,
            content_chars=content_chars,
            neighbors=0,
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
            candidates.append(item)
            if len(candidates) >= per_search_limit:
                break
        if len(candidates) >= per_search_limit:
            break

    selected_ids = [item["id"] for item in candidates[: budget["search_results"]]]
    results = hydrate_hits(
        selected_ids,
        db_path,
        neighbors=neighbors,
        content_chars=budget["content_chars"],
    )
    api_usage_chunks = read_api_usage_chunks(
        prompt,
        db_path,
        limit=max(1, budget["api_usage"]),
        content_chars=min(budget["content_chars"], max(1400, budget["content_chars"] // 2)),
    )
    module_usage_chunks = read_module_usage_chunks(
        prompt,
        db_path,
        limit=max(1, budget["module_usage"]),
        content_chars=min(budget["content_chars"], max(1400, budget["content_chars"] // 2)),
    )
    navigation_chunks = read_navigation_chunks(
        prompt,
        db_path,
        limit=max(1, budget["navigation"]),
        content_chars=min(budget["content_chars"], max(1600, budget["content_chars"] // 2)),
    )
    tool_candidates = read_tool_candidates(
        prompt,
        db_path,
        limit=max(1, budget["tool_candidates"]),
    )
    related_chunks = read_related_chunks(
        selected_ids,
        db_path,
        limit=max(1, budget["related"]),
        content_chars=min(budget["content_chars"], max(1400, budget["content_chars"] // 2)),
    )
    governing_paths = [
        str(item.get("governs_path", "")).strip()
        for item in (results + api_usage_chunks + module_usage_chunks + navigation_chunks + related_chunks)
        if item.get("source_kind") != "contract"
    ]
    governing_contracts = read_governing_contracts(
        governing_paths,
        db_path,
        content_chars=min(budget["content_chars"], max(1200, budget["content_chars"] // 3)),
        max_chunks_per_contract=2,
    )
    if intent in {"tooling", "navigation"}:
        context_items = governing_contracts + navigation_chunks + results + module_usage_chunks + api_usage_chunks + related_chunks
    elif intent == "gameplay":
        context_items = governing_contracts + module_usage_chunks + api_usage_chunks + results + related_chunks + navigation_chunks
    else:
        context_items = governing_contracts + navigation_chunks + module_usage_chunks + api_usage_chunks + results + related_chunks

    return {
        "prompt": prompt,
        "profile": profile,
        "intent": intent,
        "budget": budget,
        "searches": search_reports,
        "governing_contracts": governing_contracts,
        "module_usage_chunks": module_usage_chunks,
        "navigation_chunks": navigation_chunks,
        "api_usage_chunks": api_usage_chunks,
        "tool_candidates": tool_candidates,
        "related_chunks": related_chunks,
        "context_items": context_items,
        "results": results,
    }


def main() -> None:
    parser = argparse.ArgumentParser(description="Build a RAG context bundle for an agent task")
    parser.add_argument("prompt", help="Task prompt or search intent")
    parser.add_argument("--profile", choices=["all", "game", "engine"], default="all")
    parser.add_argument("--limit", type=int, default=RAG_CONTEXT_DEFAULT_LIMIT)
    parser.add_argument("--neighbors", type=int, default=RAG_CONTEXT_DEFAULT_NEIGHBORS)
    parser.add_argument("--content-chars", type=int, default=RAG_CONTEXT_CONTENT_CHARS_DEFAULT)
    parser.add_argument("--db", help="Override DB path for tests")
    parser.add_argument("--json", action="store_true", help="Emit compact JSON output")
    parser.add_argument("--output", help="Write JSON output to file")
    args = parser.parse_args()
    try:
        limit = _clamp_rag_arg(
            args.limit,
            "limit",
            RAG_CONTEXT_LIMIT_MIN,
            RAG_CONTEXT_LIMIT_MAX,
        )
        neighbors = _clamp_rag_arg(
            args.neighbors,
            "neighbors",
            RAG_CONTEXT_NEIGHBORS_MIN,
            RAG_CONTEXT_NEIGHBORS_MAX,
        )
        content_chars = _clamp_rag_arg(
            args.content_chars,
            "content_chars",
            RAG_CONTEXT_CONTENT_CHARS_MIN,
            RAG_CONTEXT_CONTENT_CHARS_MAX,
        )
    except ValueError as exc:
        emit_payload({"error": str(exc)}, json_output=args.json, output_path=args.output)
        return

    result = build_context_bundle(
        args.prompt,
        profile=args.profile,
        limit=limit,
        neighbors=neighbors,
        content_chars=content_chars,
        db_path=Path(args.db) if args.db else None,
    )
    emit_payload(result, json_output=args.json, output_path=args.output)


if __name__ == "__main__":
    main()
