"""
Run SQL insights and audits over the local DuckDB RAG index.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

import duckdb

from query import DB_PATH, connect

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")


REPORT_ORDER = (
    "overview",
    "edge-summary",
    "api-example-coverage",
    "todos",
    "dead-imports",
    "duplicate-symbols",
    "public-api-without-tests",
    "public-api-gaps",
    "guidance-noise",
    "owner-coverage",
    "owner-drift",
    "contract-reference-gaps",
    "imports",
)


def _fetch_rows(
    conn: duckdb.DuckDBPyConnection,
    sql: str,
    params: tuple[Any, ...] = (),
) -> list[dict[str, Any]]:
    cursor = conn.execute(sql, params)
    columns = [item[0] for item in cursor.description]
    return [dict(zip(columns, row)) for row in cursor.fetchall()]


def _emit(payload: dict[str, Any], *, json_output: bool = False, output_path: str | None = None) -> None:
    if output_path:
        Path(output_path).write_text(json.dumps(payload, ensure_ascii=False), encoding="utf-8")
        return
    if json_output:
        print(json.dumps(payload, ensure_ascii=False))
    else:
        print(json.dumps(payload, indent=2, ensure_ascii=False))


REPORT_SQL: dict[str, str] = {
    "overview": """
        SELECT
            type,
            count(*) AS chunks,
            sum(symbol_count) AS symbols,
            sum(public_api_count) AS public_api_symbols,
            sum(import_count) AS imports,
            sum(todo_count) AS todo_markers,
            sum(test_marker_count) AS test_markers,
            sum(agent_term_count) AS agent_terms
        FROM code_insights
        GROUP BY type
        ORDER BY chunks DESC, type
        LIMIT ?
    """,
    "edge-summary": """
        SELECT
            edge_kind,
            count(*) AS edges,
            count(DISTINCT path) AS files
        FROM symbol_edges
        GROUP BY edge_kind
        ORDER BY edges DESC, files DESC, edge_kind
        LIMIT ?
    """,
    "api-example-coverage": """
        WITH api_catalog AS (
            SELECT DISTINCT
                lower(trim(regexp_extract(content, '(?m)^Name:\\s*([^\\r\\n]+)', 1, 'c'))) AS api_name,
                lower(trim(regexp_extract(content, '(?m)^Module:\\s*([^\\r\\n]+)', 1, 'c'))) AS module_name
            FROM documents
            WHERE path = 'API'
              AND source_kind = 'api'
              AND lower(trim(regexp_extract(content, '(?m)^Name:\\s*([^\\r\\n]+)', 1, 'c'))) LIKE 'lurek.%'
        ),
        example_api AS (
            SELECT DISTINCT api_name
            FROM example_api_markers
        )
        SELECT
            c.api_name,
            c.module_name,
            CASE
                WHEN c.module_name = 'system' THEN 'content/examples/runtime.lua'
                ELSE 'content/examples/' || c.module_name || '.lua'
            END AS expected_example_file,
            CASE WHEN e.api_name IS NULL THEN 0 ELSE 1 END AS has_example_marker
        FROM api_catalog c
        LEFT JOIN example_api e ON e.api_name = c.api_name
        ORDER BY has_example_marker ASC, c.module_name ASC, c.api_name ASC
        LIMIT ?
    """,
    "todos": """
        SELECT
            path,
            type,
            title,
            line_start,
            line_end,
            todo_count,
            todo_tags
        FROM code_insights
        WHERE todo_count > 0
        ORDER BY todo_count DESC, path, line_start
        LIMIT ?
    """,
    "dead-imports": """
        WITH imports AS (
            SELECT
                path,
                trim(edge_value) AS import_ref,
                lower(
                    regexp_extract(
                        CASE
                            WHEN trim(edge_value) LIKE './%' OR trim(edge_value) LIKE '../%' OR strpos(trim(edge_value), '/') > 0
                                THEN regexp_replace(trim(edge_value), '\\.[A-Za-z0-9_]+$', '', 'c')
                            ELSE trim(edge_value)
                        END,
                        '([A-Za-z_][A-Za-z0-9_]*)$',
                        1,
                        'c'
                    )
                ) AS import_key,
                regexp_replace(
                    regexp_replace(
                        replace(replace(lower(trim(edge_value)), '.', '/'), '::', '/'),
                        '\\.[A-Za-z0-9_]+$',
                        '',
                        'c'
                    ),
                    '^(?:\\.\\./|\\./)+',
                    '',
                    'c'
                ) AS path_hint
            FROM symbol_edges
            WHERE edge_kind = 'import'
              AND trim(edge_value) <> ''
              AND (
                  trim(edge_value) LIKE './%'
                  OR trim(edge_value) LIKE '../%'
                  OR lower(trim(edge_value)) LIKE 'src/%'
                  OR lower(trim(edge_value)) LIKE 'tools/%'
                  OR lower(trim(edge_value)) LIKE 'content/%'
                  OR lower(trim(edge_value)) LIKE 'library/%'
                  OR lower(trim(edge_value)) LIKE 'docs/%'
                  OR lower(trim(edge_value)) LIKE 'pages/%'
                  OR lower(trim(edge_value)) LIKE 'src.%'
                  OR lower(trim(edge_value)) LIKE 'tools.%'
                  OR lower(trim(edge_value)) LIKE 'content.%'
                  OR lower(trim(edge_value)) LIKE 'library.%'
                  OR lower(trim(edge_value)) LIKE 'docs.%'
                  OR lower(trim(edge_value)) LIKE 'pages.%'
                  OR lower(trim(edge_value)) LIKE 'crate::%'
                  OR lower(trim(edge_value)) LIKE 'super::%'
                  OR lower(trim(edge_value)) LIKE 'self::%'
              )
        ),
        known_paths AS (
            SELECT DISTINCT lower(path) AS path
            FROM documents
        ),
        matches AS (
            SELECT
                i.path,
                i.import_ref,
                i.import_key,
                max(CASE WHEN se.path IS NOT NULL THEN 1 ELSE 0 END) AS symbol_match,
                max(CASE WHEN kp.path IS NOT NULL THEN 1 ELSE 0 END) AS path_match
            FROM imports i
            LEFT JOIN symbol_edges se
                ON se.edge_kind IN ('symbol', 'public_api')
               AND lower(se.edge_value) = i.import_key
               AND se.path <> i.path
            LEFT JOIN known_paths kp
                ON (
                    kp.path LIKE '%/' || i.path_hint || '.ts'
                    OR kp.path LIKE '%/' || i.path_hint || '.tsx'
                    OR kp.path LIKE '%/' || i.path_hint || '.js'
                    OR kp.path LIKE '%/' || i.path_hint || '.jsx'
                    OR kp.path LIKE '%/' || i.path_hint || '/index.ts'
                    OR kp.path LIKE '%/' || i.path_hint || '/index.tsx'
                    OR kp.path LIKE '%/' || i.path_hint || '/index.js'
                    OR kp.path LIKE '%/' || i.path_hint || '/index.jsx'
                    OR kp.path LIKE '%' || i.path_hint || '%'
                )
               AND kp.path <> lower(i.path)
            GROUP BY i.path, i.import_ref, i.import_key
        )
        SELECT
            path,
            import_ref,
            import_key
        FROM matches
        WHERE import_key <> ''
          AND symbol_match = 0
          AND path_match = 0
        ORDER BY path, import_ref
        LIMIT ?
    """,
    "duplicate-symbols": """
        SELECT
            lower(edge_value) AS symbol,
            count(*) AS occurrences,
            count(DISTINCT path) AS files
        FROM symbol_edges
        WHERE edge_kind IN ('symbol', 'public_api')
          AND trim(edge_value) <> ''
        GROUP BY lower(edge_value)
        HAVING count(*) > 1
        ORDER BY occurrences DESC, files DESC, lower(edge_value)
        LIMIT ?
    """,
    "public-api-without-tests": """
        WITH public_symbols AS (
            SELECT
                path,
                type,
                edge_value AS symbol
            FROM symbol_edges
            WHERE edge_kind = 'public_api'
        ),
        test_corpus AS (
            SELECT lower(string_agg(content, '\n')) AS corpus
            FROM documents
            WHERE source_kind = 'test'
        )
        SELECT
            path,
            type,
            symbol
        FROM public_symbols, test_corpus
        WHERE symbol <> ''
          AND strpos(corpus, lower(symbol)) = 0
        ORDER BY path, symbol
        LIMIT ?
    """,
    "public-api-gaps": """
        WITH public_symbols AS (
            SELECT
                path,
                type,
                edge_value AS symbol
            FROM symbol_edges
            WHERE edge_kind = 'public_api'
        ),
        test_corpus AS (
            SELECT lower(string_agg(content, '\n')) AS corpus
            FROM documents
            WHERE source_kind = 'test'
        )
        SELECT
            path,
            type,
            symbol
        FROM public_symbols, test_corpus
        WHERE symbol <> ''
          AND strpos(corpus, lower(symbol)) = 0
        ORDER BY path, symbol
        LIMIT ?
    """,
    "guidance-noise": """
        SELECT
            path,
            type,
            source_kind,
            title,
            line_start,
            line_end,
            symbol_count,
            agent_term_count
        FROM code_insights
        WHERE contains_agent_terms
          AND source_kind IN ('tool', 'source', 'test')
        ORDER BY agent_term_count DESC, symbol_count DESC, path, line_start
        LIMIT ?
    """,
    "owner-coverage": """
        SELECT
            governs_path,
            count(*) AS code_chunks,
            sum(public_api_count) AS public_api_symbols,
            sum(todo_count) AS todo_markers,
            sum(agent_term_count) AS agent_terms
        FROM code_insights
        GROUP BY governs_path
        ORDER BY code_chunks DESC, governs_path
        LIMIT ?
    """,
    "owner-drift": """
        WITH foreign_contract_refs AS (
            SELECT
                path,
                governs_path,
                edge_value AS referenced_contract,
                count(*) AS refs
            FROM symbol_edges
            WHERE edge_kind = 'contract_ref'
              AND governs_path <> ''
              AND trim(edge_value) <> ''
              AND edge_value <> governs_path
            GROUP BY path, governs_path, edge_value
        )
        SELECT
            governs_path,
            referenced_contract,
            count(*) AS files,
            sum(refs) AS refs
        FROM foreign_contract_refs
        GROUP BY governs_path, referenced_contract
        ORDER BY files DESC, refs DESC, governs_path, referenced_contract
        LIMIT ?
    """,
    "contract-reference-gaps": """
        WITH referenced_paths AS (
            SELECT DISTINCT path
            FROM symbol_edges
            WHERE edge_kind = 'contract_ref'
        )
        SELECT
            ci.path,
            ci.governs_path,
            ci.type,
            ci.public_api_count,
            ci.symbol_count
        FROM code_insights ci
        LEFT JOIN referenced_paths rp ON rp.path = ci.path
        WHERE ci.governs_path <> ''
          AND ci.source_kind IN ('source', 'tool', 'test')
          AND rp.path IS NULL
        ORDER BY ci.public_api_count DESC, ci.symbol_count DESC, ci.path
        LIMIT ?
    """,
    "imports": """
        SELECT
            trim(edge_value) AS import_ref,
            count(*) AS references,
            count(DISTINCT path) AS files
        FROM symbol_edges
        WHERE edge_kind = 'import'
          AND trim(edge_value) <> ''
        GROUP BY trim(edge_value)
        ORDER BY references DESC, files DESC, trim(edge_value)
        LIMIT ?
    """,
}


def run_report(
    report: str = "all",
    *,
    limit: int = 20,
    db_path: Path | None = None,
) -> dict[str, Any]:
    if limit < 1:
        return {"error": "`limit` must be at least 1."}
    if report != "all" and report not in REPORT_SQL:
        return {"error": f"Unknown report: {report}"}

    try:
        conn = connect(db_path)
    except FileNotFoundError as exc:
        return {"error": str(exc), "db_path": str(db_path or DB_PATH)}

    try:
        available = {
            row[0]
            for row in conn.execute(
                "SELECT table_name FROM information_schema.tables WHERE table_name IN ('documents', 'code_insights')"
            ).fetchall()
        }
        if "code_insights" not in available:
            return {
                "error": "code_insights table not found. Rebuild the RAG index first.",
                "db_path": str(db_path or DB_PATH),
            }

        if report == "all":
            return {
                "report": "all",
                "db_path": str(db_path or DB_PATH),
                "reports": {
                    name: _fetch_rows(conn, REPORT_SQL[name], (limit,))
                    for name in REPORT_ORDER
                },
            }

        return {
            "report": report,
            "db_path": str(db_path or DB_PATH),
            "rows": _fetch_rows(conn, REPORT_SQL[report], (limit,)),
        }
    finally:
        conn.close()


def main() -> None:
    parser = argparse.ArgumentParser(description="Run SQL insights over the DuckDB RAG index")
    parser.add_argument(
        "--report",
        default="all",
        choices=("all", *REPORT_ORDER),
        help="Insight report to run",
    )
    parser.add_argument("--limit", type=int, default=20, help="Max rows per report")
    parser.add_argument("--db", help="Override DB path")
    parser.add_argument("--json", action="store_true", help="Emit compact JSON output")
    parser.add_argument("--output", help="Write JSON output to file")
    args = parser.parse_args()

    result = run_report(
        args.report,
        limit=args.limit,
        db_path=Path(args.db) if args.db else None,
    )
    _emit(result, json_output=args.json, output_path=args.output)


if __name__ == "__main__":
    main()
