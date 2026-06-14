"""
Query and read the local SQLite FTS5 RAG index for Lurek2D.
"""

from __future__ import annotations

import argparse
import json
import re
import sqlite3
import sys
import tomllib
from pathlib import Path
from typing import Any


WORKSPACE_ROOT = Path(__file__).resolve().parent.parent.parent
DB_PATH = WORKSPACE_ROOT / "tools" / "rag" / "rag_index.db"
CONFIG_PATH = WORKSPACE_ROOT / "tools" / "rag" / "rag.toml"


with open(CONFIG_PATH, "rb") as f:
    config = tomllib.load(f)

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")


BM25_WEIGHTS = config.get("search", {}).get("bm25_weights", [1.0, 8.0, 1.0])
SNIPPET_TOKENS = int(config.get("search", {}).get("snippet_tokens", 96))
MAX_QUERY_LENGTH = 2048
RAG_SEARCH_MIN_LIMIT = 1
RAG_SEARCH_MAX_LIMIT = 25
RAG_SEARCH_DEFAULT_LIMIT = 8


def connect(db_path_override: Path | None = None) -> sqlite3.Connection:
    active_db = db_path_override if db_path_override else DB_PATH
    if not active_db.exists():
        raise FileNotFoundError(f"RAG index not found: {active_db}. Run tools/rag/build_index.py first.")
    conn = sqlite3.connect(active_db)
    conn.row_factory = sqlite3.Row
    return conn


def sanitize_fts_query(query: str) -> str:
    if len(query) > MAX_QUERY_LENGTH:
        query = query[:MAX_QUERY_LENGTH]
    raw_tokens = re.findall(r"[A-Za-z0-9_./:-]+", query)
    safe_tokens = []
    for token in raw_tokens:
        token = token.strip("._:/-")
        if token:
            safe_tokens.append(token)
    return " ".join(safe_tokens)


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


def row_to_dict(row: sqlite3.Row, *, include_content: bool = False, content_chars: int = 6000) -> dict[str, Any]:
    item = {
        "id": row["id"],
        "path": row["path"],
        "type": row["type"],
        "title": row["title"],
        "line_start": int(row["line_start"]),
        "line_end": int(row["line_end"]),
        "source_kind": row["source_kind"],
        "priority": float(row["priority"]),
        "is_generated": bool(int(row["is_generated"])),
        "is_vendor": bool(int(row["is_vendor"])),
    }
    if "context" in row.keys():
        item["context"] = row["context"]
    if "rank" in row.keys():
        item["rank"] = row["rank"]
    if include_content:
        content = row["content"]
        if content_chars > 0 and len(content) > content_chars:
            content = content[:content_chars].rstrip() + "\n...[truncated]"
        item["content"] = content
    return item


def _profile_clause(profile: str) -> str:
    if profile == "game":
        return (
            " AND (type = 'api' OR path LIKE '.codex/skills/%' OR path LIKE 'content/%' "
            "OR path LIKE 'docs/%' OR path LIKE 'library/%' OR path LIKE 'tests/lua/%' "
            "OR path LIKE 'tools/audit/%' OR path LIKE 'tools/validate/%' OR path LIKE 'tools/ui/%' "
            "OR path LIKE 'tools/snippets/%') "
        )
    if profile == "engine":
        return (
            " AND (path = 'AGENTS.md' OR path LIKE '.agents/%' OR path LIKE '.codex/%' "
            "OR path LIKE '.github/%' OR path LIKE 'docs/%' OR path LIKE 'extension/%' "
            "OR path LIKE 'src/%' OR path LIKE 'tests/%' OR path LIKE 'tools/%') "
        )
    return ""


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
        if limit < RAG_SEARCH_MIN_LIMIT or limit > RAG_SEARCH_MAX_LIMIT:
            return {"error": f"`limit` must be between {RAG_SEARCH_MIN_LIMIT} and {RAG_SEARCH_MAX_LIMIT}.", "results": []}
        results = _search_once(conn, safe_query, profile, limit, include_content, content_chars)
        mode = "and"
        if len(results) < limit and " " in safe_query:
            relaxed = " OR ".join(safe_query.split())
            relaxed_results = _search_once(conn, relaxed, profile, limit, include_content, content_chars)
            seen = {item["id"] for item in results}
            for item in relaxed_results:
                if item["id"] not in seen:
                    results.append(item)
                    seen.add(item["id"])
                if len(results) >= limit:
                    break
            mode = "and+or" if results else "or"
        if neighbors > 0:
            for item in results:
                item["neighbors"] = read_neighbors(conn, item["id"], neighbors, content_chars=content_chars)
        return {"query": query, "fts_query": safe_query, "profile": profile, "mode": mode, "results": results}
    except sqlite3.OperationalError as exc:
        return {"error": f"Search syntax error: {exc}"}
    finally:
        conn.close()


def _search_once(
    conn: sqlite3.Connection,
    safe_query: str,
    profile: str,
    limit: int,
    include_content: bool,
    content_chars: int,
) -> list[dict[str, Any]]:
    weight_str = ", ".join(str(w) for w in BM25_WEIGHTS)
    sql = f"""
        SELECT
            id,
            path,
            type,
            title,
            content,
            line_start,
            line_end,
            source_kind,
            priority,
            is_generated,
            is_vendor,
            snippet(documents, 4, '[[', ']]', '...', {SNIPPET_TOKENS}) as context,
            bm25(documents, {weight_str}) as rank
        FROM documents
        WHERE documents MATCH ?
    """
    sql += _profile_clause(profile)
    sql += """
        ORDER BY
            CAST(is_vendor AS INTEGER) ASC,
            (CAST(is_generated AS INTEGER) AND source_kind NOT IN ('skill', 'agent', 'contract')) ASC,
            (rank - CAST(priority AS REAL)) ASC
        LIMIT ?
    """
    candidate_limit = max(limit * 8, 50)
    rows = conn.execute(sql, (safe_query, candidate_limit)).fetchall()
    ranked = sorted(rows, key=lambda row: _adjusted_rank(row, safe_query))
    return [row_to_dict(row, include_content=include_content, content_chars=content_chars) for row in ranked[:limit]]


def _adjusted_rank(row: sqlite3.Row, safe_query: str) -> float:
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
    path = row["path"].lower()
    title = row["title"].lower()
    source_kind = row["source_kind"]
    score = float(row["rank"]) - float(row["priority"])
    for token in specific_tokens:
        if token in path:
            score -= 8.0
        if token in title:
            score -= 5.0
    generated_request = "generated" in tokens
    source_kind = row["source_kind"]
    score += _query_intent_boost(safe_query, source_kind)
    if row["is_generated"] and not generated_request and source_kind not in {"skill", "agent", "contract", "api"}:
        score += 7.0
    if specific_tokens and source_kind in {"skill", "contract", "prompt_mirror"}:
        if not any(token in path or token in title for token in specific_tokens):
            score += 6.0
    return score


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
        row = conn.execute(
            """
            SELECT id, path, type, title, content, line_start, line_end,
                   source_kind, priority, is_generated, is_vendor
            FROM documents
            WHERE id = ?
            """,
            (chunk_id,),
        ).fetchone()
        if not row:
            return {"error": f"RAG chunk not found: {chunk_id}"}
        item = row_to_dict(row, include_content=True, content_chars=content_chars)
        if neighbors > 0:
            item["neighbors"] = read_neighbors(conn, chunk_id, neighbors, content_chars=content_chars)
        return {"chunk": item}
    finally:
        conn.close()


def read_neighbors(
    conn: sqlite3.Connection,
    chunk_id: str,
    distance: int,
    *,
    content_chars: int = 6000,
) -> list[dict[str, Any]]:
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
    rows = conn.execute(
        f"""
        SELECT id, path, type, title, content, line_start, line_end,
               source_kind, priority, is_generated, is_vendor
        FROM documents
        WHERE id IN ({placeholders})
        ORDER BY line_start
        """,
        ids,
    ).fetchall()
    return [row_to_dict(row, include_content=True, content_chars=content_chars) for row in rows]


def stats(db_path_override: Path | None = None) -> dict[str, Any]:
    try:
        conn = connect(db_path_override)
    except FileNotFoundError as exc:
        return {"error": str(exc)}
    try:
        by_type = [dict(row) for row in conn.execute("SELECT type, count(*) as chunks FROM documents GROUP BY type ORDER BY chunks DESC")]
        by_kind = [
            dict(row)
            for row in conn.execute(
                "SELECT source_kind, count(*) as chunks FROM documents GROUP BY source_kind ORDER BY chunks DESC"
            )
        ]
        total = conn.execute("SELECT count(*) FROM documents").fetchone()[0]
        top_paths = [
            dict(row)
            for row in conn.execute(
                "SELECT path, count(*) as chunks FROM documents GROUP BY path ORDER BY chunks DESC LIMIT 20"
            )
        ]
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
