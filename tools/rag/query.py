"""
Query and read the local DuckDB RAG index for Lurek2D.
"""

from __future__ import annotations

import argparse
from collections import defaultdict
import json
import re
import sys
import tomllib
from pathlib import Path
from typing import Any

import duckdb

from contract import (
    RAG_CONTEXT_CONTENT_CHARS_DEFAULT,
    RAG_CONTEXT_CONTENT_CHARS_MAX,
    RAG_CONTEXT_CONTENT_CHARS_MIN,
    RAG_CONTEXT_LIMIT_DEFAULT,
    RAG_CONTEXT_LIMIT_MAX,
    RAG_CONTEXT_LIMIT_MIN,
    RAG_CONTEXT_NEIGHBORS_DEFAULT,
    RAG_CONTEXT_NEIGHBORS_MAX,
    RAG_CONTEXT_NEIGHBORS_MIN,
    RAG_READ_CONTENT_CHARS_DEFAULT,
    RAG_READ_CONTENT_CHARS_MAX,
    RAG_READ_CONTENT_CHARS_MIN,
    RAG_READ_NEIGHBORS_DEFAULT,
    RAG_READ_NEIGHBORS_MAX,
    RAG_READ_NEIGHBORS_MIN,
    RAG_SEARCH_LIMIT_DEFAULT,
    RAG_SEARCH_LIMIT_MAX,
    RAG_SEARCH_LIMIT_MIN,
)


WORKSPACE_ROOT = Path(__file__).resolve().parent.parent.parent
DB_PATH = WORKSPACE_ROOT / "tools" / "rag" / "rag_index.duckdb"
CONFIG_PATH = WORKSPACE_ROOT / "tools" / "rag" / "rag.toml"


with open(CONFIG_PATH, "rb") as f:
    config = tomllib.load(f)

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")


FIELD_WEIGHTS = config.get("search", {}).get("bm25_weights", [1.0, 8.0, 1.0])
SNIPPET_TOKENS = int(config.get("search", {}).get("snippet_tokens", 96))
MAX_QUERY_LENGTH = 2048
RAG_SEARCH_MIN_LIMIT = RAG_SEARCH_LIMIT_MIN
RAG_SEARCH_MAX_LIMIT = RAG_SEARCH_LIMIT_MAX
RAG_SEARCH_DEFAULT_LIMIT = RAG_SEARCH_LIMIT_DEFAULT
RAG_READ_DEFAULT_NEIGHBORS = RAG_READ_NEIGHBORS_DEFAULT
RAG_READ_MAX_NEIGHBORS = RAG_READ_NEIGHBORS_MAX
RAG_READ_MIN_NEIGHBORS = RAG_READ_NEIGHBORS_MIN
RAG_READ_DEFAULT_CONTENT_CHARS = RAG_READ_CONTENT_CHARS_DEFAULT
RAG_READ_CONTENT_CHARS_MIN = RAG_READ_CONTENT_CHARS_MIN
RAG_READ_CONTENT_CHARS_MAX = RAG_READ_CONTENT_CHARS_MAX
RAG_CONTEXT_DEFAULT_LIMIT = RAG_CONTEXT_LIMIT_DEFAULT
RAG_CONTEXT_MAX_LIMIT = RAG_CONTEXT_LIMIT_MAX
RAG_CONTEXT_MIN_LIMIT = RAG_CONTEXT_LIMIT_MIN
RAG_CONTEXT_DEFAULT_NEIGHBORS = RAG_CONTEXT_NEIGHBORS_DEFAULT
RAG_CONTEXT_MAX_NEIGHBORS = RAG_CONTEXT_NEIGHBORS_MAX
RAG_CONTEXT_MIN_NEIGHBORS = RAG_CONTEXT_NEIGHBORS_MIN
RAG_CONTEXT_DEFAULT_CONTENT_CHARS = RAG_CONTEXT_CONTENT_CHARS_DEFAULT
RAG_CONTEXT_CONTENT_CHARS_MIN = RAG_CONTEXT_CONTENT_CHARS_MIN
RAG_CONTEXT_CONTENT_CHARS_MAX = RAG_CONTEXT_CONTENT_CHARS_MAX


GUIDANCE_TOKENS = {
    "agent",
    "agents",
    "codex",
    "contract",
    "contracts",
    "guide",
    "instruction",
    "policy",
    "policies",
    "rule",
    "rules",
    "skill",
    "skills",
    "workflow",
    "workflows",
}
API_REFERENCE_RE = re.compile(r"lurek\.[A-Za-z0-9_]+(?:\.[A-Za-z0-9_]+)+")
QUERY_TOKEN_RE = re.compile(r"[A-Za-z][A-Za-z0-9_./-]{2,}")
ECOSYSTEM_TOKENS = {
    "agent",
    "agents",
    "skill",
    "skills",
    "tool",
    "tools",
    "mcp",
    "command",
    "commands",
    "workflow",
    "contract",
    "contracts",
    "audit",
    "validate",
    "validator",
    "rag",
}
GAMEPLAY_HINT_TOKENS = {
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
}
TEST_TOKENS = {"coverage", "test", "tests", "unit", "integration", "regression"}
EXAMPLE_TOKENS = {"demo", "demos", "example", "examples", "sample", "samples", "snippet", "snippets"}
API_TOKENS = {"api", "callback", "callbacks", "function", "functions", "method", "methods", "reference"}
SOURCE_TOKENS = {"bug", "fix", "implement", "implementation", "module", "rust", "source", "src"}
PROMPT_TOKENS = {"prompt", "prompts", "routing", "route"}
MODULE_ALIAS_MAP = {
    "music": "audio",
    "sound": "audio",
    "sounds": "audio",
    "sfx": "audio",
    "voice": "audio",
    "voices": "audio",
    "collision": "physics",
    "collisions": "physics",
    "rigidbody": "physics",
    "rigidbodies": "physics",
    "sensor": "physics",
    "sensors": "physics",
    "zoom": "camera",
    "shake": "camera",
    "fullscreen": "window",
    "dpi": "window",
}
MODULE_QUERY_STOPWORDS = {
    "how",
    "do",
    "does",
    "did",
    "i",
    "the",
    "a",
    "an",
    "and",
    "or",
    "for",
    "of",
    "in",
    "on",
    "my",
    "me",
    "what",
    "when",
    "where",
    "which",
    "why",
    "use",
    "using",
    "create",
    "should",
    "would",
    "could",
    "give",
    "gives",
    "play",
    "into",
    "with",
    "from",
    "that",
    "this",
}


def connect(db_path_override: Path | None = None) -> duckdb.DuckDBPyConnection:
    active_db = db_path_override if db_path_override else DB_PATH
    if not active_db.exists():
        raise FileNotFoundError(f"RAG index not found: {active_db}. Run tools/rag/build_index.py first.")
    return duckdb.connect(str(active_db), read_only=True)


def sanitize_fts_query(query: str) -> str:
    if len(query) > MAX_QUERY_LENGTH:
        query = query[:MAX_QUERY_LENGTH]
    raw_tokens = re.findall(r"[A-Za-z0-9_]+", query)
    return " ".join(raw_tokens)


def _require_int_in_range(
    value: Any,
    name: str,
    minimum: int,
    maximum: int,
) -> int:
    try:
        normalized = int(value)
    except (TypeError, ValueError):
        raise ValueError(f"`{name}` must be an integer.")
    if normalized < minimum or normalized > maximum:
        raise ValueError(f"`{name}` must be between {minimum} and {maximum}.")
    return normalized


def emit_payload(payload: dict[str, Any], *, json_output: bool = False, output_path: str | None = None) -> None:
    if output_path:
        Path(output_path).write_text(
            json.dumps(payload, ensure_ascii=False), encoding="utf-8"
        )
        return
    if json_output:
        print(json.dumps(payload, ensure_ascii=False))
    else:
        print(json.dumps(payload, indent=2, ensure_ascii=False))


def _fetch_rows(
    conn: duckdb.DuckDBPyConnection,
    sql: str,
    params: tuple[Any, ...] = (),
) -> list[dict[str, Any]]:
    cursor = conn.execute(sql, params)
    columns = [item[0] for item in cursor.description]
    return [dict(zip(columns, row)) for row in cursor.fetchall()]


def _fetch_one(
    conn: duckdb.DuckDBPyConnection,
    sql: str,
    params: tuple[Any, ...] = (),
) -> dict[str, Any] | None:
    rows = _fetch_rows(conn, sql, params)
    return rows[0] if rows else None


def _normalize_bool(value: Any) -> bool:
    if isinstance(value, bool):
        return value
    if value is None:
        return False
    return bool(int(value))


def _dedupe_tokens(safe_query: str) -> list[str]:
    return list(
        dict.fromkeys(
            token.lower()
            for token in safe_query.split()
            if token and token.lower() not in MODULE_QUERY_STOPWORDS
        )
    )


def _build_snippet(content: str, tokens: list[str]) -> str:
    if not content:
        return ""
    lowered = content.lower()
    positions = [lowered.find(token) for token in tokens if token and lowered.find(token) >= 0]
    pivot = min(positions) if positions else 0
    max_chars = max(240, SNIPPET_TOKENS * 7)
    start = max(0, pivot - max_chars // 3)
    end = min(len(content), start + max_chars)
    snippet = content[start:end].strip()
    if start > 0:
        snippet = "..." + snippet
    if end < len(content):
        snippet = snippet.rstrip() + "..."
    for token in sorted(dict.fromkeys(tokens), key=len, reverse=True):
        snippet = re.sub(f"(?i)({re.escape(token)})", r"[[\1]]", snippet, count=1)
    return snippet


def _analyze_query_intent(safe_query: str) -> dict[str, Any]:
    tokens = [token.lower() for token in safe_query.split() if token]
    token_set = set(tokens)
    return {
        "tokens": tokens,
        "token_set": token_set,
        "wants_guidance": bool(token_set & GUIDANCE_TOKENS),
        "wants_tests": bool(token_set & TEST_TOKENS),
        "wants_examples": bool(token_set & EXAMPLE_TOKENS),
        "wants_api": bool(token_set & API_TOKENS) or "lurek" in token_set,
        "wants_source": bool(token_set & SOURCE_TOKENS),
        "wants_prompts": bool(token_set & PROMPT_TOKENS),
        "wants_gameplay": bool(token_set & GAMEPLAY_HINT_TOKENS),
        "wants_tooling": bool(token_set & {"tool", "tools", "mcp", "command", "commands", "audit", "validate", "validator", "registry"}),
    }


def _query_intent_boost(safe_query: str, source_kind: str) -> float:
    if source_kind == "api":
        tokens = {"api", "function", "method", "callback", "doc", "reference"}
    elif source_kind == "spec":
        tokens = {"spec", "specification", "contract", "requirement", "behavior"}
    elif source_kind == "contract":
        tokens = {"contract", "guide", "instruction", "workflow", "policy"}
    elif source_kind == "skill":
        tokens = {"skill", "skillset", "agent", "prompt"}
    elif source_kind == "agent":
        tokens = {"agent", "assistant", "persona", "prompt"}
    elif source_kind == "prompt_mirror":
        tokens = {"prompt", "prompt_mirror", "persona"}
    elif source_kind == "example":
        tokens = {"example", "tutorial", "snippet", "demo"}
    elif source_kind == "test":
        tokens = {"test", "coverage", "validate"}
    elif source_kind == "docs":
        tokens = {"doc", "documentation", "reference", "guide"}
    elif source_kind == "page":
        tokens = {"page", "wiki", "documentation"}
    else:
        tokens = set[str]()

    lowered = [token.lower() for token in safe_query.split() if len(token) > 2]
    return -4.5 if set(lowered).intersection(tokens) else 0.0


def row_to_dict(row: dict[str, Any], *, include_content: bool = False, content_chars: int = 6000) -> dict[str, Any]:
    item = {
        "id": row["id"],
        "path": row["path"],
        "type": row["type"],
        "title": row["title"],
        "line_start": int(row["line_start"]),
        "line_end": int(row["line_end"]),
        "source_kind": row["source_kind"],
        "priority": float(row["priority"]),
        "is_generated": _normalize_bool(row["is_generated"]),
        "is_vendor": _normalize_bool(row["is_vendor"]),
    }
    if "governs_path" in row:
        item["governs_path"] = row["governs_path"]
    if "section_kind" in row:
        item["section_kind"] = row["section_kind"]
    if "context" in row:
        item["context"] = row["context"]
    if "rank" in row:
        item["rank"] = row["rank"]
    if include_content:
        content = str(row["content"])
        if content_chars > 0 and len(content) > content_chars:
            content = content[:content_chars].rstrip() + "\n...[truncated]"
        item["content"] = content
    return item


def _profile_filter_sql(profile: str) -> str:
    if profile == "game":
        return (
            " AND (d.type = 'api' OR d.path LIKE '.codex/skills/%' OR d.path LIKE 'content/%' "
            "OR d.path LIKE 'docs/%' OR d.path LIKE 'lurek_2d_content/%' OR d.path LIKE 'lurek_2d_workbench/%' OR d.path LIKE 'tests/lua/%' "
            "OR d.path LIKE 'tools/audit/%' OR d.path LIKE 'tools/validate/%' OR d.path LIKE 'tools/ui/%' "
            "OR d.path LIKE 'tools/snippets/%') "
        )
    if profile == "engine":
        return (
            " AND (d.path = 'AGENTS.md' OR d.path LIKE '.codex/%' OR d.path LIKE 'docs/%' "
            "OR d.path LIKE 'src/%' OR d.path LIKE 'tests/%' OR d.path LIKE 'tools/%' "
            "OR d.path LIKE 'lurek_2d_extension/%' OR d.path LIKE 'lurek_2d_workbench/%') "
        )
    return ""


def _candidate_sql(profile: str, token_count: int, conjunctive: bool) -> str:
    if token_count <= 0:
        raise ValueError("search requires at least one token")
    token_predicates = [
        "(strpos(lower(path), ?) > 0 OR strpos(lower(title), ?) > 0 OR strpos(lower(content), ?) > 0)"
        for _ in range(token_count)
    ]
    joiner = " AND " if conjunctive else " OR "
    where_tokens = joiner.join(token_predicates)
    return f"""
        SELECT
            d.id,
            d.path,
            d.type,
            d.title,
            d.content,
            d.line_start,
            d.line_end,
            d.source_kind,
            d.priority,
            d.is_generated,
            d.is_vendor,
            d.governs_path,
            d.section_kind,
            coalesce(ci.agent_term_count, 0) AS insight_agent_term_count,
            coalesce(ci.symbol_count, 0) AS insight_symbol_count,
            coalesce(ci.contains_agent_terms, false) AS insight_contains_agent_terms
        FROM documents d
        LEFT JOIN code_insights ci ON ci.id = d.id
        WHERE 1 = 1
        {_profile_filter_sql(profile)}
          AND ({where_tokens.replace('path', 'd.path').replace('title', 'd.title').replace('content', 'd.content')})
        ORDER BY
            CAST(d.is_vendor AS INTEGER) ASC,
            CAST(d.is_generated AS INTEGER) ASC,
            d.priority DESC,
            d.path ASC,
            d.line_start ASC
        LIMIT ?
    """


def _candidate_params(tokens: list[str], limit: int) -> tuple[Any, ...]:
    params: list[Any] = []
    for token in tokens:
        params.extend([token, token, token])
    params.append(limit)
    return tuple(params)


def _candidate_score(row: dict[str, Any], tokens: list[str]) -> tuple[int, float]:
    path_l = str(row["path"]).lower()
    title_l = str(row["title"]).lower()
    content_l = str(row["content"]).lower()
    matched_terms = 0
    lexical_score = 0.0
    path_weight = float(FIELD_WEIGHTS[0]) if len(FIELD_WEIGHTS) > 0 else 1.0
    title_weight = float(FIELD_WEIGHTS[1]) if len(FIELD_WEIGHTS) > 1 else 8.0
    content_weight = float(FIELD_WEIGHTS[2]) if len(FIELD_WEIGHTS) > 2 else 1.0
    for token in tokens:
        in_path = token in path_l
        in_title = token in title_l
        in_content = token in content_l
        if in_path or in_title or in_content:
            matched_terms += 1
        lexical_score += path_weight if in_path else 0.0
        lexical_score += title_weight if in_title else 0.0
        lexical_score += content_weight if in_content else 0.0
    return matched_terms, lexical_score


def search_index(
    query: str,
    profile: str = "all",
    limit: int = RAG_SEARCH_DEFAULT_LIMIT,
    db_path_override: Path | None = None,
    *,
    include_content: bool = False,
    content_chars: int = 6000,
    neighbors: int = 0,
) -> dict[str, Any]:
    if not query:
        return {"error": "query cannot be empty", "results": []}
    if len(query) > MAX_QUERY_LENGTH:
        return {"error": f"query is too long (max {MAX_QUERY_LENGTH} chars)", "results": []}

    safe_query = sanitize_fts_query(query)
    if not safe_query:
        return {"query": query, "profile": profile, "results": []}

    try:
        conn = connect(db_path_override)
    except FileNotFoundError as exc:
        return {"error": str(exc)}

    try:
        validated_limit = _require_int_in_range(
            limit,
            "limit",
            RAG_SEARCH_MIN_LIMIT,
            RAG_SEARCH_MAX_LIMIT,
        )
        validated_neighbors = _require_int_in_range(
            neighbors,
            "neighbors",
            RAG_READ_NEIGHBORS_MIN,
            RAG_READ_NEIGHBORS_MAX,
        )
        validated_content_chars = _require_int_in_range(
            content_chars,
            "content_chars",
            RAG_READ_CONTENT_CHARS_MIN,
            RAG_READ_CONTENT_CHARS_MAX,
        )
        intent = _analyze_query_intent(safe_query)

        results = _search_once(
            conn,
            safe_query,
            profile,
            validated_limit,
            include_content,
            validated_content_chars,
            conjunctive=True,
        )
        mode = "and"
        if len(results) < validated_limit and " " in safe_query:
            relaxed_results = _search_once(
                conn,
                safe_query,
                profile,
                validated_limit,
                include_content,
                validated_content_chars,
                conjunctive=False,
            )
            seen = {item["id"] for item in results}
            for item in relaxed_results:
                if item["id"] not in seen:
                    results.append(item)
                    seen.add(item["id"])
                if len(results) >= validated_limit:
                    break
            mode = "and+or" if results else "or"
        results = sorted(results, key=lambda item: _adjusted_rank(item, safe_query, intent))
        results = _select_diverse_rows(results, validated_limit)[:validated_limit]
        if validated_neighbors > 0:
            for item in results:
                item["neighbors"] = read_neighbors(
                    conn,
                    item["id"],
                    validated_neighbors,
                    content_chars=validated_content_chars,
                )
        return {"query": query, "fts_query": safe_query, "profile": profile, "mode": mode, "results": results}
    except ValueError as exc:
        return {"error": str(exc)}
    except duckdb.Error as exc:
        return {"error": f"Search syntax error: {exc}"}
    finally:
        conn.close()


def _search_once(
    conn: duckdb.DuckDBPyConnection,
    safe_query: str,
    profile: str,
    limit: int,
    include_content: bool,
    content_chars: int,
    *,
    conjunctive: bool,
) -> list[dict[str, Any]]:
    intent = _analyze_query_intent(safe_query)
    tokens = _dedupe_tokens(safe_query)
    candidate_limit = max(limit * (24 if conjunctive else 40), 120 if conjunctive else 240)
    rows = _fetch_rows(
        conn,
        _candidate_sql(profile, len(tokens), conjunctive),
        _candidate_params(tokens, candidate_limit),
    )

    ranked_rows: list[dict[str, Any]] = []
    for row in rows:
        matched_terms, lexical_score = _candidate_score(row, tokens)
        if conjunctive and matched_terms < len(tokens):
            continue
        row["rank"] = -(matched_terms * 100.0 + lexical_score)
        row["context"] = _build_snippet(str(row["content"]), tokens)
        ranked_rows.append(row)

    ranked = sorted(ranked_rows, key=lambda row: _adjusted_rank(row, safe_query, intent))
    ranked = _select_diverse_rows(ranked, limit)
    return [row_to_dict(row, include_content=include_content, content_chars=content_chars) for row in ranked[:limit]]


def _adjusted_rank(row: dict[str, Any], safe_query: str, intent: dict[str, Any]) -> float:
    tokens = [token.lower() for token in safe_query.split() if len(token) > 2]
    generic = {
        "api",
        "lua",
        "test",
        "tests",
        "example",
        "examples",
        "coverage",
        "docs",
        "spec",
        "specs",
        "create",
        "review",
        "generated",
    }
    specific_tokens = [token for token in tokens if token not in generic]
    path = str(row["path"]).lower()
    title = str(row["title"]).lower()
    source_kind = str(row["source_kind"])
    section_kind = str(row["section_kind"]).lower() if "section_kind" in row else ""
    module_terms = _extract_module_terms(safe_query, limit=4)
    score = float(row["rank"]) - float(row["priority"])
    for token in specific_tokens:
        if token in path:
            score -= 8.0
        if token in title:
            score -= 5.0
    generated_request = "generated" in tokens
    score += _query_intent_boost(safe_query, source_kind)
    if source_kind == "contract":
        if intent["wants_guidance"]:
            score -= 8.0
        if section_kind in {"rules", "workflow"}:
            score -= 6.5
        elif section_kind in {"mission", "scope", "preamble"}:
            score -= 3.5
        elif section_kind in {"references", "files"}:
            score += 2.5
    if source_kind == "spec" and (intent["wants_guidance"] or intent["wants_source"]):
        score -= 4.0
    if intent["wants_guidance"] and not intent["wants_source"] and source_kind in {
        "tool",
        "source",
        "test",
        "example",
        "page",
        "py",
        "ts",
        "js",
        "rs",
        "lua",
        "wgsl",
    }:
        score += 80.0
    insight_agent_term_count = int(row.get("insight_agent_term_count") or 0)
    insight_symbol_count = int(row.get("insight_symbol_count") or 0)
    insight_contains_agent_terms = _normalize_bool(row.get("insight_contains_agent_terms"))
    if (
        intent["wants_guidance"]
        and not intent["wants_source"]
        and source_kind in {"tool", "source", "test"}
        and insight_contains_agent_terms
    ):
        score += min(36.0, float(insight_agent_term_count) * 4.0)
        if insight_symbol_count <= 1:
            score += 6.0
    if source_kind == "source" and intent["wants_source"]:
        score -= 5.0
    if source_kind == "api" and intent["wants_api"]:
        score -= 5.5
    if source_kind == "skill" and intent["wants_guidance"]:
        score -= 3.5
    if source_kind == "agent" and intent["wants_guidance"]:
        score -= 2.5
    if source_kind == "prompt_mirror":
        score += 8.0
        if intent["wants_prompts"]:
            score -= 4.0
    if source_kind == "test" and not intent["wants_tests"]:
        score += 9.0
    if source_kind == "example" and not intent["wants_examples"]:
        score += 5.5
    if source_kind == "page":
        score += 6.0
    if _normalize_bool(row["is_generated"]) and not generated_request and source_kind not in {"skill", "agent", "contract", "api"}:
        score += 7.0
    if specific_tokens and source_kind in {"skill", "contract", "prompt_mirror"}:
        if not any(token in path or token in title for token in specific_tokens):
            score += 6.0
    if intent.get("wants_gameplay"):
        for module_name in module_terms:
            if path == f"content/examples/{module_name}.lua":
                score -= 28.0
            if path == f"docs/modules/{module_name}.md":
                score -= 22.0
            if path == f"docs/specs/{module_name}.md":
                score -= 18.0
            if path == f"src/lua_api/{module_name}_api.rs":
                score -= 15.0
            if source_kind == "test" and module_name in path:
                score -= 16.0
        if source_kind in {"skill", "agent", "contract"} and module_terms:
            if not any(module_name in path or module_name in title for module_name in module_terms):
                score += 18.0
    if intent.get("wants_tooling"):
        if path.startswith("tools/"):
            score -= 14.0
        if path.startswith("tools/mcp/"):
            score -= 12.0
        if source_kind in {"tool", "skill", "contract"}:
            score -= 10.0
        if source_kind in {"example", "source", "docs", "page"} and not path.startswith("tools/"):
            score += 12.0
    if "mcp" in tokens and "rag" in tokens and ("rebuild" in tokens or "build" in tokens or "index" in tokens):
        if path == "tools/mcp/lurek_mcp_server.py":
            score -= 34.0
        if path == "tools/rag/build_index.py":
            score -= 28.0
    if "skill" in tokens and intent["wants_examples"] and intent["wants_api"]:
        if path == ".codex/skills/create-example/skill.md":
            score -= 42.0
        if path == "content/examples/agents.md":
            score -= 20.0
        if source_kind == "skill" and "example" in path:
            score -= 14.0
    if "agents" in tokens or "workflow" in tokens or "rules" in tokens or "contract" in tokens or "contracts" in tokens:
        if path == "agents.md":
            score -= 30.0
        elif path.endswith("/agents.md"):
            score -= 22.0
        if "root" in tokens and path == "agents.md":
            score -= 14.0
    if "pages" in tokens and "generated" in tokens:
        if path == ".codex/skills/create-pages/skill.md":
            score -= 28.0
        if path == "docs/templates/agents.md":
            score -= 24.0
    if "context" in tokens and "bundle" in tokens:
        if path == "tools/rag/context.py":
            score -= 120.0
        if path == "tools/rag/query.py":
            score -= 40.0
    if "evidence" in tokens or "golden" in tokens or "artifacts" in tokens:
        if path == ".codex/skills/create-test-evidence/skill.md":
            score -= 26.0
        if path == "tools/audit/golden_test.py":
            score -= 20.0
        if path == "tools/audit/lua_evidence_golden_contract_audit.py":
            score -= 16.0
        if path.startswith("tests/lua/evidence/") or path.startswith("tests/lua/golden/"):
            score -= 14.0
    return score


def _select_diverse_rows(rows: list[dict[str, Any]], limit: int) -> list[dict[str, Any]]:
    selected: list[dict[str, Any]] = []
    per_path_count: defaultdict[str, int] = defaultdict(int)

    for row in rows:
        path = str(row["path"])
        if per_path_count[path] > 0:
            continue
        selected.append(row)
        per_path_count[path] += 1
        if len(selected) >= limit:
            return selected

    for row in rows:
        if row in selected:
            continue
        selected.append(row)
        if len(selected) >= limit:
            break
    return selected


def _extract_api_terms(query: str) -> list[str]:
    seen: set[str] = set()
    terms: list[str] = []
    for match in API_REFERENCE_RE.findall(query or ""):
        value = match.lower()
        if value in seen:
            continue
        seen.add(value)
        terms.append(value)
    return terms


def _extract_query_tokens(query: str, *, limit: int = 8) -> list[str]:
    seen: set[str] = set()
    tokens: list[str] = []
    for match in QUERY_TOKEN_RE.findall(query or ""):
        token = match.lower().strip("./-")
        if len(token) < 3 or token in seen or token in MODULE_QUERY_STOPWORDS:
            continue
        seen.add(token)
        tokens.append(token)
        if len(tokens) >= limit:
            break
    return tokens


def _extract_module_terms(query: str, *, limit: int = 6) -> list[str]:
    seen: set[str] = set()
    modules: list[str] = []
    for api_name in _extract_api_terms(query):
        parts = api_name.split(".")
        if len(parts) >= 3:
            module_name = parts[1].lower()
            if module_name not in seen:
                seen.add(module_name)
                modules.append(module_name)
                if len(modules) >= limit:
                    return modules
    query_tokens = _extract_query_tokens(query, limit=limit * 4)
    for token in query_tokens:
        alias = MODULE_ALIAS_MAP.get(token.lower())
        if alias and alias not in seen:
            seen.add(alias)
            modules.append(alias)
            if len(modules) >= limit:
                return modules
    for token in query_tokens:
        lowered = token.lower()
        if lowered in GAMEPLAY_HINT_TOKENS and lowered not in {"example", "examples"} and lowered not in seen:
            seen.add(lowered)
            modules.append(lowered)
            if len(modules) >= limit:
                return modules
    for token in query_tokens:
        lowered = token.lower()
        if lowered in ECOSYSTEM_TOKENS or lowered in MODULE_QUERY_STOPWORDS:
            continue
        if lowered not in seen:
            seen.add(lowered)
            modules.append(lowered)
            if len(modules) >= limit:
                break
    return modules


def _table_exists(conn: duckdb.DuckDBPyConnection, table_name: str) -> bool:
    row = conn.execute(
        """
        SELECT count(*)
        FROM information_schema.tables
        WHERE table_schema = current_schema()
          AND table_name = ?
        """,
        (table_name,),
    ).fetchone()
    return bool(row and row[0])


def _base_select_sql() -> str:
    return """
        SELECT id, path, type, title, content, line_start, line_end,
               source_kind, priority, is_generated, is_vendor, governs_path, section_kind
        FROM documents
    """


def _rows_by_ids(conn: duckdb.DuckDBPyConnection, chunk_ids: list[str]) -> list[dict[str, Any]]:
    if not chunk_ids:
        return []
    placeholders = ",".join("?" for _ in chunk_ids)
    order_clause = " ".join(f"WHEN ? THEN {idx}" for idx, _ in enumerate(chunk_ids))
    sql = f"""
        {_base_select_sql()}
        WHERE id IN ({placeholders})
        ORDER BY CASE id {order_clause} END
    """
    return _fetch_rows(conn, sql, tuple(chunk_ids + chunk_ids))


def hydrate_hits(
    chunk_ids: list[str],
    db_path_override: Path | None = None,
    *,
    neighbors: int = 0,
    content_chars: int = 8000,
) -> list[dict[str, Any]]:
    if not chunk_ids:
        return []
    try:
        conn = connect(db_path_override)
    except FileNotFoundError:
        return []

    try:
        validated_neighbors = _require_int_in_range(
            neighbors,
            "neighbors",
            RAG_READ_NEIGHBORS_MIN,
            RAG_READ_NEIGHBORS_MAX,
        )
        validated_content_chars = _require_int_in_range(
            content_chars,
            "content_chars",
            RAG_READ_CONTENT_CHARS_MIN,
            RAG_READ_CONTENT_CHARS_MAX,
        )
        results: list[dict[str, Any]] = []
        for row in _rows_by_ids(conn, chunk_ids):
            item = row_to_dict(
                row,
                include_content=True,
                content_chars=validated_content_chars,
            )
            if validated_neighbors > 0:
                item["neighbors"] = read_neighbors(
                    conn,
                    item["id"],
                    validated_neighbors,
                    content_chars=validated_content_chars,
                )
            results.append(item)
        return results
    finally:
        conn.close()


def read_related_chunks(
    seed_chunk_ids: list[str],
    db_path_override: Path | None = None,
    *,
    limit: int = 3,
    content_chars: int = 2500,
) -> list[dict[str, Any]]:
    if not seed_chunk_ids:
        return []
    try:
        conn = connect(db_path_override)
    except FileNotFoundError:
        return []

    try:
        validated_limit = _require_int_in_range(limit, "limit", 1, 12)
        validated_content_chars = _require_int_in_range(
            content_chars,
            "content_chars",
            RAG_CONTEXT_CONTENT_CHARS_MIN,
            RAG_CONTEXT_CONTENT_CHARS_MAX,
        )
        placeholders = ",".join("?" for _ in seed_chunk_ids)
        sql = f"""
            WITH seed_chunks AS (
                SELECT DISTINCT id, path
                FROM documents
                WHERE id IN ({placeholders})
            ),
            seed_edges AS (
                SELECT DISTINCT lower(trim(edge_value)) AS edge_value
                FROM symbol_edges
                WHERE path IN (SELECT path FROM seed_chunks)
                  AND edge_kind IN ('symbol', 'public_api', 'import')
                  AND trim(edge_value) <> ''
            ),
            candidate_edges AS (
                SELECT
                    se.id,
                    se.path,
                    sum(
                        CASE
                            WHEN se.edge_kind = 'public_api' THEN 4
                            WHEN se.edge_kind = 'symbol' THEN 2
                            WHEN se.edge_kind = 'import' THEN 1
                            ELSE 0
                        END
                    ) AS edge_score,
                    count(*) AS matched_edges
                FROM symbol_edges se
                JOIN seed_edges sd ON lower(trim(se.edge_value)) = sd.edge_value
                WHERE se.id NOT IN ({placeholders})
                  AND se.path NOT IN (SELECT path FROM seed_chunks)
                  AND se.edge_kind IN ('symbol', 'public_api', 'import')
                GROUP BY se.id, se.path
            )
            SELECT
                d.id,
                d.path,
                d.type,
                d.title,
                d.content,
                d.line_start,
                d.line_end,
                d.source_kind,
                d.priority,
                d.is_generated,
                d.is_vendor,
                d.governs_path,
                d.section_kind,
                ce.edge_score,
                ce.matched_edges
            FROM candidate_edges ce
            JOIN documents d ON d.id = ce.id
            WHERE d.source_kind IN ('source', 'tool', 'spec', 'api', 'contract', 'skill')
            ORDER BY
                ce.edge_score DESC,
                ce.matched_edges DESC,
                d.priority DESC,
                d.path ASC,
                d.line_start ASC
            LIMIT ?
        """
        params = tuple(seed_chunk_ids + seed_chunk_ids + [validated_limit * 8])
        rows = _fetch_rows(conn, sql, params)
        selected = _select_diverse_rows(rows, validated_limit)[:validated_limit]
        if not selected:
            fallback_sql = f"""
                WITH seed_chunks AS (
                    SELECT DISTINCT id, path, governs_path
                    FROM documents
                    WHERE id IN ({placeholders})
                )
                SELECT
                    d.id,
                    d.path,
                    d.type,
                    d.title,
                    d.content,
                    d.line_start,
                    d.line_end,
                    d.source_kind,
                    d.priority,
                    d.is_generated,
                    d.is_vendor,
                    d.governs_path,
                    d.section_kind
                FROM documents d
                WHERE d.governs_path IN (
                    SELECT DISTINCT governs_path FROM seed_chunks WHERE governs_path <> ''
                )
                  AND d.path NOT IN (SELECT path FROM seed_chunks)
                  AND d.source_kind IN ('source', 'tool', 'spec', 'api', 'contract', 'skill')
                ORDER BY
                    d.priority DESC,
                    d.path ASC,
                    d.line_start ASC
                LIMIT ?
            """
            fallback_rows = _fetch_rows(conn, fallback_sql, tuple(seed_chunk_ids + [validated_limit * 4]))
            selected = _select_diverse_rows(fallback_rows, validated_limit)[:validated_limit]
        return [
            row_to_dict(row, include_content=True, content_chars=validated_content_chars)
            for row in selected
        ]
    finally:
        conn.close()


def read_api_usage_chunks(
    query_text: str,
    db_path_override: Path | None = None,
    *,
    limit: int = 3,
    content_chars: int = 2500,
) -> list[dict[str, Any]]:
    api_terms = _extract_api_terms(query_text)
    if not api_terms:
        return []
    try:
        conn = connect(db_path_override)
    except FileNotFoundError:
        return []

    try:
        validated_limit = _require_int_in_range(limit, "limit", 1, 12)
        validated_content_chars = _require_int_in_range(
            content_chars,
            "content_chars",
            RAG_CONTEXT_CONTENT_CHARS_MIN,
            RAG_CONTEXT_CONTENT_CHARS_MAX,
        )
        direct_example_rows: list[dict[str, Any]] = []
        if _table_exists(conn, "example_api_markers"):
            placeholders = ",".join("?" for _ in api_terms)
            example_sql = f"""
                SELECT
                    d.id,
                    d.path,
                    d.type,
                    d.title,
                    d.content,
                    d.line_start,
                    d.line_end,
                    d.source_kind,
                    d.priority,
                    d.is_generated,
                    d.is_vendor,
                    d.governs_path,
                    d.section_kind,
                    400 AS retrieval_score
                FROM example_api_markers em
                JOIN documents d
                  ON d.path = em.path
                 AND d.line_start <= em.line_no
                 AND d.line_end >= em.line_no
                WHERE em.api_name IN ({placeholders})
                ORDER BY em.path ASC, em.line_no ASC
            """
            direct_example_rows = _fetch_rows(conn, example_sql, tuple(api_terms))
        insight_columns = {
            str(row[1]).lower()
            for row in conn.execute("PRAGMA table_info('code_insights')").fetchall()
        }
        selected_direct = _select_diverse_rows(direct_example_rows, validated_limit)
        if "api_markers" not in insight_columns or "api_calls" not in insight_columns:
            return [
                row_to_dict(row, include_content=True, content_chars=validated_content_chars)
                for row in selected_direct[:validated_limit]
            ]
        score_parts: list[str] = []
        score_params: list[Any] = []
        where_parts: list[str] = []
        where_params: list[Any] = []
        for api_name in api_terms:
            score_parts.append(
                "CASE "
                "WHEN list_contains(coalesce(ci.api_markers, []::VARCHAR[]), ?) THEN 320 "
                "WHEN list_contains(coalesce(ci.api_calls, []::VARCHAR[]), ?) THEN 220 "
                "ELSE 0 END"
            )
            score_params.extend([api_name, api_name])
            where_parts.append(
                "(list_contains(coalesce(ci.api_markers, []::VARCHAR[]), ?) OR list_contains(coalesce(ci.api_calls, []::VARCHAR[]), ?))"
            )
            where_params.extend([api_name, api_name])
        sql = f"""
            SELECT
                d.id,
                d.path,
                d.type,
                d.title,
                d.content,
                d.line_start,
                d.line_end,
                d.source_kind,
                d.priority,
                d.is_generated,
                d.is_vendor,
                d.governs_path,
                d.section_kind,
                (
                    {" + ".join(score_parts)}
                    + CASE WHEN d.path LIKE 'content/examples/%' THEN 140 ELSE 0 END
                    + CASE WHEN d.source_kind = 'example' THEN 60 ELSE 0 END
                    + CASE WHEN d.path LIKE 'docs/%' THEN 20 ELSE 0 END
                    + coalesce(d.priority, 0)
                ) AS retrieval_score
            FROM documents d
            LEFT JOIN code_insights ci ON ci.id = d.id
            WHERE ({' OR '.join(where_parts)})
              AND (
                  d.path LIKE 'content/examples/%'
                  OR d.path LIKE 'docs/%'
                  OR d.path LIKE 'src/%'
              )
            ORDER BY retrieval_score DESC, d.path ASC, d.line_start ASC
            LIMIT ?
        """
        rows = _fetch_rows(conn, sql, tuple(score_params + where_params + [validated_limit * 6]))
        selected = _select_diverse_rows(direct_example_rows + rows, validated_limit)[:validated_limit]
        return [
            row_to_dict(row, include_content=True, content_chars=validated_content_chars)
            for row in selected
        ]
    finally:
        conn.close()


def read_module_usage_chunks(
    query_text: str,
    db_path_override: Path | None = None,
    *,
    limit: int = 4,
    content_chars: int = 2200,
) -> list[dict[str, Any]]:
    module_terms = _extract_module_terms(query_text)
    if not module_terms:
        return []
    try:
        conn = connect(db_path_override)
    except FileNotFoundError:
        return []

    try:
        validated_limit = _require_int_in_range(limit, "limit", 1, 12)
        validated_content_chars = _require_int_in_range(
            content_chars,
            "content_chars",
            RAG_CONTEXT_CONTENT_CHARS_MIN,
            RAG_CONTEXT_CONTENT_CHARS_MAX,
        )
        rows: list[dict[str, Any]] = []
        seen_paths: set[str] = set()
        query_tokens = _extract_query_tokens(query_text, limit=10)
        for module_name in module_terms:
            module_rows = _fetch_rows(
                conn,
                f"""
                SELECT
                    d.id,
                    d.path,
                    d.type,
                    d.title,
                    d.content,
                    d.line_start,
                    d.line_end,
                    d.source_kind,
                    d.priority,
                    d.is_generated,
                    d.is_vendor,
                    d.governs_path,
                    d.section_kind,
                    CASE
                        WHEN d.path = ? THEN 220
                        WHEN d.path = ? THEN 180
                        WHEN d.path = ? THEN 150
                        WHEN d.path = ? THEN 130
                        ELSE 0
                    END AS retrieval_score
                FROM documents d
                WHERE d.path IN (?, ?, ?, ?)
                ORDER BY retrieval_score DESC, d.path ASC, d.line_start ASC
                LIMIT 8
                """,
                (
                    f"content/examples/{module_name}.lua",
                    f"docs/modules/{module_name}.md",
                    f"docs/specs/{module_name}.md",
                    f"src/lua_api/{module_name}_api.rs",
                    f"content/examples/{module_name}.lua",
                    f"docs/modules/{module_name}.md",
                    f"docs/specs/{module_name}.md",
                    f"src/lua_api/{module_name}_api.rs",
                ),
            )
            for row in module_rows:
                path = str(row["path"])
                if path in seen_paths:
                    continue
                if query_tokens:
                    content = str(row.get("content") or "").lower()
                    score_boost = sum(1 for token in query_tokens if token in content)
                    row["retrieval_score"] = float(row.get("retrieval_score") or 0) + score_boost * 6.0
                seen_paths.add(path)
                rows.append(row)
        selected = _select_diverse_rows(
            sorted(rows, key=lambda row: (-float(row.get("retrieval_score") or 0), str(row.get("path") or ""))),
            validated_limit,
        )[:validated_limit]
        return [
            row_to_dict(row, include_content=True, content_chars=validated_content_chars)
            for row in selected
        ]
    finally:
        conn.close()


def read_navigation_chunks(
    query_text: str,
    db_path_override: Path | None = None,
    *,
    limit: int = 4,
    content_chars: int = 2200,
) -> list[dict[str, Any]]:
    query_tokens = _extract_query_tokens(query_text)
    if not query_tokens:
        return []
    lowered = query_text.lower()
    if "agents.md" not in lowered and "skill" not in lowered and "mcp" not in lowered and not (set(query_tokens) & ECOSYSTEM_TOKENS):
        return []
    try:
        conn = connect(db_path_override)
    except FileNotFoundError:
        return []

    try:
        validated_limit = _require_int_in_range(limit, "limit", 1, 12)
        validated_content_chars = _require_int_in_range(
            content_chars,
            "content_chars",
            RAG_CONTEXT_CONTENT_CHARS_MIN,
            RAG_CONTEXT_CONTENT_CHARS_MAX,
        )
        score_parts: list[str] = []
        params: list[Any] = []
        where_parts: list[str] = []
        for token in query_tokens:
            score_parts.append(
                "CASE WHEN lower(d.title) LIKE '%' || ? || '%' THEN 14 ELSE 0 END + "
                "CASE WHEN lower(d.path) LIKE '%' || ? || '%' THEN 10 ELSE 0 END + "
                "CASE WHEN lower(d.content) LIKE '%' || ? || '%' THEN 4 ELSE 0 END"
            )
            params.extend([token, token, token])
            where_parts.append(
                "lower(d.title) LIKE '%' || ? || '%' OR lower(d.path) LIKE '%' || ? || '%' OR lower(d.content) LIKE '%' || ? || '%'"
            )
            params.extend([token, token, token])
        sql = f"""
            SELECT
                d.id,
                d.path,
                d.type,
                d.title,
                d.content,
                d.line_start,
                d.line_end,
                d.source_kind,
                d.priority,
                d.is_generated,
                d.is_vendor,
                d.governs_path,
                d.section_kind,
                (
                    {" + ".join(score_parts)}
                    + CASE WHEN d.source_kind = 'skill' THEN 40 ELSE 0 END
                    + CASE WHEN d.source_kind = 'agent' THEN 34 ELSE 0 END
                    + CASE WHEN d.source_kind = 'contract' THEN 26 ELSE 0 END
                    + CASE WHEN d.path LIKE 'tools/%' THEN 14 ELSE 0 END
                    + CASE WHEN d.title LIKE '%Workflow%' OR d.title LIKE '%Rules%' OR d.title LIKE '%Companion File Index%' THEN 12 ELSE 0 END
                ) AS retrieval_score
            FROM documents d
            WHERE d.source_kind IN ('skill', 'agent', 'contract', 'tool')
              AND ({' OR '.join(where_parts)})
            ORDER BY retrieval_score DESC, d.priority DESC, d.path ASC, d.line_start ASC
            LIMIT ?
        """
        rows = _fetch_rows(conn, sql, tuple(params + [validated_limit * 6]))
        selected = _select_diverse_rows(rows, validated_limit)[:validated_limit]
        return [
            row_to_dict(row, include_content=True, content_chars=validated_content_chars)
            for row in selected
        ]
    finally:
        conn.close()


def read_tool_candidates(
    query_text: str,
    db_path_override: Path | None = None,
    *,
    limit: int = 5,
) -> list[dict[str, Any]]:
    query_tokens = _extract_query_tokens(query_text)
    if not query_tokens:
        return []
    lowered = query_text.lower()
    if "mcp" not in lowered and "tool" not in lowered and "command" not in lowered and "validate" not in lowered and "audit" not in lowered and not (set(query_tokens) & ECOSYSTEM_TOKENS):
        return []
    try:
        conn = connect(db_path_override)
    except FileNotFoundError:
        return []

    try:
        if not _table_exists(conn, "tool_catalog"):
            return []
        validated_limit = _require_int_in_range(limit, "limit", 1, 12)
        score_parts: list[str] = []
        params: list[Any] = []
        for token in query_tokens:
            score_parts.append(
                "CASE WHEN lower(tool_name) LIKE '%' || ? || '%' THEN 18 ELSE 0 END + "
                "CASE WHEN lower(registry_key) LIKE '%' || ? || '%' THEN 14 ELSE 0 END + "
                "CASE WHEN lower(description) LIKE '%' || ? || '%' THEN 6 ELSE 0 END + "
                "CASE WHEN lower(handler) LIKE '%' || ? || '%' THEN 4 ELSE 0 END"
            )
            params.extend([token, token, token, token])
        sql = f"""
            SELECT
                tool_name,
                registry_key,
                description,
                handler,
                source_path,
                {" + ".join(score_parts)} AS match_score
            FROM tool_catalog
            ORDER BY match_score DESC, tool_name ASC
            LIMIT ?
        """
        rows = _fetch_rows(conn, sql, tuple(params + [validated_limit * 3]))
        return [row for row in rows if int(row.get("match_score") or 0) > 0][:validated_limit]
    finally:
        conn.close()


def read_governing_contracts(
    governing_paths: list[str],
    db_path_override: Path | None = None,
    *,
    content_chars: int = 2500,
    max_chunks_per_contract: int = 2,
) -> list[dict[str, Any]]:
    unique_paths = [path for path in dict.fromkeys(governing_paths) if path]
    if not unique_paths:
        return []
    try:
        conn = connect(db_path_override)
    except FileNotFoundError:
        return []

    try:
        validated_content_chars = _require_int_in_range(
            content_chars,
            "content_chars",
            RAG_CONTEXT_CONTENT_CHARS_MIN,
            RAG_CONTEXT_CONTENT_CHARS_MAX,
        )
        results: list[dict[str, Any]] = []
        preferred_sections = ("rules", "workflow", "mission", "scope", "preamble")
        placeholders = ",".join("?" for _ in preferred_sections)
        for governing_path in unique_paths:
            rows = _fetch_rows(
                conn,
                f"""
                {_base_select_sql()}
                WHERE path = ?
                  AND source_kind = 'contract'
                  AND section_kind IN ({placeholders})
                ORDER BY CASE section_kind
                    WHEN 'rules' THEN 0
                    WHEN 'workflow' THEN 1
                    WHEN 'mission' THEN 2
                    WHEN 'scope' THEN 3
                    WHEN 'preamble' THEN 4
                    ELSE 99
                END, line_start
                LIMIT ?
                """,
                (governing_path, *preferred_sections, max_chunks_per_contract),
            )
            results.extend(
                row_to_dict(row, include_content=True, content_chars=validated_content_chars)
                for row in rows
            )
        return results
    finally:
        conn.close()


def read_chunk(
    chunk_id: str,
    db_path_override: Path | None = None,
    *,
    neighbors: int = 0,
    content_chars: int = 12000,
) -> dict[str, Any]:
    try:
        conn = connect(db_path_override)
    except FileNotFoundError as exc:
        return {"error": str(exc)}

    try:
        row = _fetch_one(
            conn,
            """
            SELECT id, path, type, title, content, line_start, line_end,
                   source_kind, priority, is_generated, is_vendor, governs_path, section_kind
            FROM documents
            WHERE id = ?
            """,
            (chunk_id,),
        )
        if not row:
            return {"error": f"RAG chunk not found: {chunk_id}"}
        validated_neighbors = _require_int_in_range(
            neighbors,
            "neighbors",
            RAG_READ_NEIGHBORS_MIN,
            RAG_READ_NEIGHBORS_MAX,
        )
        validated_content_chars = _require_int_in_range(
            content_chars,
            "content_chars",
            RAG_READ_CONTENT_CHARS_MIN,
            RAG_READ_CONTENT_CHARS_MAX,
        )
        item = row_to_dict(
            row,
            include_content=True,
            content_chars=validated_content_chars,
        )
        if validated_neighbors > 0:
            item["neighbors"] = read_neighbors(
                conn,
                chunk_id,
                validated_neighbors,
                content_chars=validated_content_chars,
            )
        return {"chunk": item}
    except ValueError as exc:
        return {"error": str(exc)}
    finally:
        conn.close()


def read_neighbors(
    conn: duckdb.DuckDBPyConnection,
    chunk_id: str,
    distance: int,
    *,
    content_chars: int = 6000,
) -> list[dict[str, Any]]:
    if distance < RAG_READ_NEIGHBORS_MIN:
        raise ValueError(
            f"`neighbors` must be between {RAG_READ_NEIGHBORS_MIN} and {RAG_READ_NEIGHBORS_MAX}."
        )
    if distance > RAG_READ_NEIGHBORS_MAX:
        raise ValueError(
            f"`neighbors` must be between {RAG_READ_NEIGHBORS_MIN} and {RAG_READ_NEIGHBORS_MAX}."
        )
    if "#" not in chunk_id:
        return []
    path, idx_text = chunk_id.rsplit("#", 1)
    if not idx_text.isdigit():
        return []
    idx = int(idx_text)
    min_idx = max(0, idx - distance)
    max_idx = idx + distance
    ids = [f"{path}#{i}" for i in range(min_idx, max_idx + 1) if i != idx]
    if not ids:
        return []
    placeholders = ",".join("?" for _ in ids)
    rows = _fetch_rows(
        conn,
        f"""
        SELECT id, path, type, title, content, line_start, line_end,
               source_kind, priority, is_generated, is_vendor, governs_path, section_kind
        FROM documents
        WHERE id IN ({placeholders})
        ORDER BY line_start
        """,
        tuple(ids),
    )
    return [row_to_dict(row, include_content=True, content_chars=content_chars) for row in rows]


def stats(db_path_override: Path | None = None) -> dict[str, Any]:
    try:
        conn = connect(db_path_override)
    except FileNotFoundError as exc:
        return {"error": str(exc)}
    try:
        by_type = _fetch_rows(conn, "SELECT type, count(*) as chunks FROM documents GROUP BY type ORDER BY chunks DESC")
        by_kind = _fetch_rows(
            conn,
            "SELECT source_kind, count(*) as chunks FROM documents GROUP BY source_kind ORDER BY chunks DESC",
        )
        total = conn.execute("SELECT count(*) FROM documents").fetchone()[0]
        top_paths = _fetch_rows(
            conn,
            "SELECT path, count(*) as chunks FROM documents GROUP BY path ORDER BY chunks DESC LIMIT 20",
        )
        return {"total_chunks": total, "by_type": by_type, "by_kind": by_kind, "top_paths": top_paths}
    finally:
        conn.close()


def main() -> None:
    parser = argparse.ArgumentParser(description="Query or read the Lurek2D RAG index")
    parser.add_argument("query", nargs="?", help="Search query keywords")
    parser.add_argument("--profile", choices=["all", "game", "engine"], default="all", help="Filter profile")
    parser.add_argument("--limit", type=int, default=RAG_SEARCH_DEFAULT_LIMIT, help="Max results")
    parser.add_argument("--db", help="Override DB path for tests")
    parser.add_argument("--include-content", action="store_true", help="Include full chunk content in search results")
    parser.add_argument("--content-chars", type=int, default=6000, help="Max content chars per returned chunk")
    parser.add_argument("--neighbors", type=int, default=0, help="Include adjacent chunks from the same file")
    parser.add_argument("--id", help="Read a chunk by exact RAG id")
    parser.add_argument("--stats", action="store_true", help="Print index stats")
    parser.add_argument("--json", action="store_true", help="Emit compact JSON output")
    parser.add_argument("--output", help="Write JSON output to file")
    args = parser.parse_args()

    db_override = Path(args.db) if args.db else None
    if args.stats:
        res = stats(db_override)
    elif args.id:
        res = read_chunk(args.id, db_override, neighbors=args.neighbors, content_chars=args.content_chars)
    elif args.query:
        res = search_index(
            args.query,
            args.profile,
            args.limit,
            db_override,
            include_content=args.include_content,
            content_chars=args.content_chars,
            neighbors=args.neighbors,
        )
    else:
        parser.error("query, --id, or --stats is required")
    emit_payload(res, json_output=args.json, output_path=args.output)


if __name__ == "__main__":
    main()
