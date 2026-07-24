"""
Build the local DuckDB RAG index for Lurek2D docs, code, tests, and Codex assets.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import html.parser
import json
import os
import re
import tempfile
import tomllib
from dataclasses import dataclass
from pathlib import Path, PurePosixPath
from typing import Any

import duckdb

from contract import RAG_INDEXING_ALLOWED_EXTENSIONS, RAG_INDEXING_DEFAULT_TARGET_DIRS


WORKSPACE_ROOT = Path(__file__).resolve().parent.parent.parent
DB_PATH = WORKSPACE_ROOT / "tools" / "rag" / "rag_index.duckdb"
CONFIG_PATH = WORKSPACE_ROOT / "tools" / "rag" / "rag.toml"
API_DATA_PATH = WORKSPACE_ROOT / "logs" / "data" / "lua_api_data.json"


with open(CONFIG_PATH, "rb") as f:
    config = tomllib.load(f)


INDEXING = config.get("indexing", {})
RANKING = config.get("ranking", {})

MAX_CHUNK_SIZE = int(INDEXING.get("max_chunk_size", 1800))
MIN_CHUNK_SIZE = int(INDEXING.get("min_chunk_size", 120))
ALLOWED_EXTENSIONS = set(RAG_INDEXING_ALLOWED_EXTENSIONS)
DEFAULT_TARGET_DIRS = INDEXING.get(
    "default_target_dirs",
    RAG_INDEXING_DEFAULT_TARGET_DIRS,
)
IGNORE_DIRS = set(
    INDEXING.get(
        "ignore_dirs",
        [".git", ".pytest_cache", "__pycache__", "node_modules", "target", "dist", "build", ".cache"],
    )
)
IGNORE_FILES = set(INDEXING.get("ignore_files", ["rag_index.db", "rag_index.duckdb", "rag_index.duckdb.wal"]))
IGNORE_PATH_PATTERNS = INDEXING.get("ignore_path_patterns", [])
MAX_FILE_BYTES = int(INDEXING.get("max_file_bytes", 2_000_000))
SOURCE_PRIORITIES = RANKING.get("source_priorities", {})
GENERATED_PATH_PATTERNS = RANKING.get(
    "generated_path_patterns",
    ["docs/api/lurek.lua", "docs/api/lurek.md", "docs/wiki/API-Reference.md", "lurek_2d_pages/"],
)
VENDOR_PATH_PATTERNS = RANKING.get("vendor_path_patterns", ["node_modules/", "/vendor/"])
DOCUMENT_COLUMNS = (
    "id",
    "path",
    "type",
    "title",
    "content",
    "line_start",
    "line_end",
    "source_kind",
    "priority",
    "is_generated",
    "is_vendor",
    "governs_path",
    "section_kind",
    "sha256",
)
CODE_INSIGHT_INDEXES = (
    "CREATE INDEX IF NOT EXISTS idx_code_insights_path ON code_insights(path)",
    "CREATE INDEX IF NOT EXISTS idx_code_insights_governs ON code_insights(governs_path)",
    "CREATE INDEX IF NOT EXISTS idx_code_insights_type ON code_insights(type)",
)
SYMBOL_EDGE_INDEXES = (
    "CREATE INDEX IF NOT EXISTS idx_symbol_edges_path ON symbol_edges(path)",
    "CREATE INDEX IF NOT EXISTS idx_symbol_edges_governs ON symbol_edges(governs_path)",
    "CREATE INDEX IF NOT EXISTS idx_symbol_edges_kind ON symbol_edges(edge_kind)",
    "CREATE INDEX IF NOT EXISTS idx_symbol_edges_value ON symbol_edges(edge_value)",
)
EXAMPLE_API_MARKER_INDEXES = (
    "CREATE INDEX IF NOT EXISTS idx_example_api_markers_path ON example_api_markers(path)",
    "CREATE INDEX IF NOT EXISTS idx_example_api_markers_api_name ON example_api_markers(api_name)",
)
EXAMPLE_API_MARKER_RE = re.compile(r"^\s*--\s*@api(?:-stub)?:\s*(lurek\.[A-Za-z0-9_.]+)\s*$")
TOOL_CATALOG_INDEXES = (
    "CREATE INDEX IF NOT EXISTS idx_tool_catalog_name ON tool_catalog(tool_name)",
    "CREATE INDEX IF NOT EXISTS idx_tool_catalog_handler ON tool_catalog(handler)",
)
MCP_TOOL_SPEC_RE = re.compile(
    r'"(?P<registry_key>[^"]+)":\s*ToolSpec\(\s*'
    r'name="(?P<tool_name>[^"]+)",\s*'
    r'description="(?P<description>[^"]+)"[\s\S]*?'
    r'handler=(?P<handler>handle_[A-Za-z0-9_]+),',
    re.MULTILINE,
)


@dataclass(frozen=True)
class Chunk:
    title: str
    content: str
    line_start: int
    line_end: int


class TextHTMLParser(html.parser.HTMLParser):
    """Small HTML-to-text parser that preserves heading breaks for generated pages."""

    def __init__(self) -> None:
        super().__init__()
        self._skip_depth = 0
        self.lines: list[str] = []
        self._current: list[str] = []

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        if tag in {"script", "style", "svg", "nav", "footer"}:
            self._skip_depth += 1
        if tag in {"h1", "h2", "h3", "h4", "p", "li", "pre", "section", "article", "main", "br"}:
            self._flush()
        if tag in {"h1", "h2", "h3", "h4"}:
            self._current.append("#" * int(tag[1]))

    def handle_endtag(self, tag: str) -> None:
        if tag in {"script", "style", "svg", "nav", "footer"} and self._skip_depth:
            self._skip_depth -= 1
        if tag in {"h1", "h2", "h3", "h4", "p", "li", "pre", "section", "article", "main"}:
            self._flush()

    def handle_data(self, data: str) -> None:
        if self._skip_depth:
            return
        text = " ".join(data.split())
        if text:
            self._current.append(text)

    def _flush(self) -> None:
        text = " ".join(part for part in self._current if part).strip()
        if text:
            self.lines.append(text)
        self._current = []

    def finish(self) -> str:
        self._flush()
        return "\n".join(self.lines)


def init_db(db_path: Path) -> duckdb.DuckDBPyConnection:
    conn = duckdb.connect(str(db_path))
    existing_cols = [
        row[0]
        for row in conn.execute(
            """
            SELECT column_name
            FROM information_schema.columns
            WHERE table_name = 'documents'
            ORDER BY ordinal_position
            """
        ).fetchall()
    ]
    expected_cols = [
        "id",
        "path",
        "type",
        "title",
        "content",
        "line_start",
        "line_end",
        "source_kind",
        "priority",
        "is_generated",
        "is_vendor",
        "governs_path",
        "section_kind",
        "sha256",
    ]
    if existing_cols and existing_cols != expected_cols:
        conn.execute("DROP TABLE IF EXISTS documents")
        conn.execute("DROP INDEX IF EXISTS idx_documents_id")
        conn.execute("DROP INDEX IF EXISTS idx_documents_path")
        conn.execute("DROP INDEX IF EXISTS idx_documents_kind")
    conn.execute(
        """
        CREATE TABLE IF NOT EXISTS documents (
            id VARCHAR,
            path VARCHAR,
            type VARCHAR,
            title VARCHAR,
            content VARCHAR,
            line_start INTEGER,
            line_end INTEGER,
            source_kind VARCHAR,
            priority DOUBLE,
            is_generated BOOLEAN,
            is_vendor BOOLEAN,
            governs_path VARCHAR,
            section_kind VARCHAR,
            sha256 VARCHAR
        );
        """
    )
    return conn


def _drop_indexes(conn: duckdb.DuckDBPyConnection) -> None:
    conn.execute("DROP INDEX IF EXISTS idx_documents_id")
    conn.execute("DROP INDEX IF EXISTS idx_documents_path")
    conn.execute("DROP INDEX IF EXISTS idx_documents_kind")


def _ensure_indexes(conn: duckdb.DuckDBPyConnection) -> None:
    conn.execute("CREATE UNIQUE INDEX IF NOT EXISTS idx_documents_id ON documents(id)")
    conn.execute("CREATE INDEX IF NOT EXISTS idx_documents_path ON documents(path)")
    conn.execute("CREATE INDEX IF NOT EXISTS idx_documents_kind ON documents(source_kind)")


def _refresh_code_insights(conn: duckdb.DuckDBPyConnection) -> None:
    conn.execute("DROP TABLE IF EXISTS code_insights")
    conn.execute(
        r"""
        CREATE TABLE code_insights AS
        WITH base AS (
            SELECT
                id,
                path,
                type,
                title,
                line_start,
                line_end,
                source_kind,
                governs_path,
                section_kind,
                content,
                regexp_extract_all(content, '(?m)^\s*(?:pub\s+)?(?:async\s+)?fn\s+([A-Za-z_][A-Za-z0-9_]*)', 1, 'c')
                    || regexp_extract_all(content, '(?m)^\s*(?:pub\s+)?(?:struct|enum|trait|mod)\s+([A-Za-z_][A-Za-z0-9_]*)', 1, 'c')
                    || regexp_extract_all(content, '(?m)^\s*(?:class|def|async\s+def)\s+([A-Za-z_][A-Za-z0-9_]*)', 1, 'c')
                    || regexp_extract_all(content, '(?m)^\s*(?:local\s+function|function)\s+([A-Za-z_][A-Za-z0-9_:.]*)', 1, 'c')
                    || regexp_extract_all(content, '(?m)^\s*(?:export\s+)?(?:default\s+)?(?:async\s+)?(?:function|class|interface|type|const|let|var)\s+([A-Za-z_][A-Za-z0-9_]*)', 1, 'c')
                    AS symbol_names,
                regexp_extract_all(content, '(?m)^\s*pub\s+(?:async\s+)?fn\s+([A-Za-z_][A-Za-z0-9_]*)', 1, 'c')
                    || regexp_extract_all(content, '(?m)^\s*pub\s+(?:struct|enum|trait|mod)\s+([A-Za-z_][A-Za-z0-9_]*)', 1, 'c')
                    || regexp_extract_all(content, '(?m)^\s*export\s+(?:default\s+)?(?:async\s+)?(?:function|class|interface|type|const|let|var)\s+([A-Za-z_][A-Za-z0-9_]*)', 1, 'c')
                    AS public_api_names,
                regexp_extract_all(content, '(?m)^\s*use\s+([^;]+)', 1, 'c')
                    || regexp_extract_all(content, '(?m)^\s*from\s+([A-Za-z0-9_./-]+)\s+import\s+', 1, 'c')
                    || regexp_extract_all(content, '(?m)^\s*import\s+([A-Za-z0-9_.,\\s-]+)', 1, 'c')
                    || regexp_extract_all(content, '(?m)^\s*import\s+.*?\s+from\s+"([^"]+)"', 1, 'c')
                    || regexp_extract_all(content, '(?m)^\s*import\s+.*?\s+from\s+''([^'']+)''', 1, 'c')
                    || regexp_extract_all(content, '(?m)^\s*const\s+.*?=\s+require\("([^"]+)"\)', 1, 'c')
                    || regexp_extract_all(content, '(?m)^\s*const\s+.*?=\s+require\(''([^'']+)''\)', 1, 'c')
                    || regexp_extract_all(content, '(?m)^\s*local\s+[A-Za-z_][A-Za-z0-9_]*\s*=\s*require\s*\(?"([^"]+)"\)?', 1, 'c')
                    || regexp_extract_all(content, '(?m)^\s*local\s+[A-Za-z_][A-Za-z0-9_]*\s*=\s*require\s*\(?''([^'']+)''\)?', 1, 'c')
                    AS import_refs,
                regexp_extract_all(content, '(TODO|FIXME|HACK|XXX)', 1, 'c') AS todo_tags,
                regexp_extract_all(content, '((?:[A-Za-z0-9_.-]+/)?AGENTS\.md)', 1, 'c') AS contract_refs,
                regexp_extract_all(content, '((?:[A-Za-z0-9_.-]+/)?SKILL\.md)', 1, 'c') AS skill_refs,
                regexp_extract_all(content, '(?m)(docs/specs/[A-Za-z0-9_./-]+\.md)', 1, 'c') AS spec_refs,
                regexp_extract_all(content, '(#\[test\]|describe\s*\(|it\s*\(|assert[_!(]|expect\s*\()', 1, 'c') AS test_markers,
                regexp_extract_all(lower(content), '(?m)(?:--\s*@api:|//\s*@api:|#\s*@api:)\s*(lurek\.[a-z0-9_\.]+)', 1, 'c') AS api_markers,
                regexp_extract_all(lower(content), '(lurek\.[a-z0-9_]+(?:\.[a-z0-9_]+)+)', 1, 'c') AS api_calls,
                regexp_extract_all(lower(content), '(agents?|rules?|workflow|skills?)', 1, 'c') AS agent_terms
            FROM documents
            WHERE type IN ('rs', 'py', 'lua', 'ts', 'js', 'wgsl')
        )
        SELECT
            id,
            path,
            type,
            title,
            line_start,
            line_end,
            source_kind,
            governs_path,
            section_kind,
            symbol_names,
            public_api_names,
            import_refs,
            todo_tags,
            contract_refs,
            skill_refs,
            spec_refs,
            test_markers,
            api_markers,
            api_calls,
            agent_terms,
            array_length(string_split(content, '\n')) AS line_count,
            length(content) AS char_count,
            array_length(symbol_names) AS symbol_count,
            array_length(public_api_names) AS public_api_count,
            array_length(import_refs) AS import_count,
            array_length(todo_tags) AS todo_count,
            array_length(contract_refs) AS contract_ref_count,
            array_length(skill_refs) AS skill_ref_count,
            array_length(spec_refs) AS spec_ref_count,
            array_length(test_markers) AS test_marker_count,
            array_length(api_markers) AS api_marker_count,
            array_length(api_calls) AS api_call_count,
            array_length(agent_terms) AS agent_term_count,
            array_length(public_api_names) > 0 AS has_public_api,
            array_length(agent_terms) > 0 AS contains_agent_terms
        FROM base
        """
    )
    for statement in CODE_INSIGHT_INDEXES:
        conn.execute(statement)


def _refresh_symbol_edges(conn: duckdb.DuckDBPyConnection) -> None:
    conn.execute("DROP TABLE IF EXISTS symbol_edges")
    conn.execute(
        """
        CREATE TABLE symbol_edges AS
        WITH exploded AS (
            SELECT id, path, type, source_kind, governs_path, 'symbol' AS edge_kind, unnest(symbol_names) AS edge_value
            FROM code_insights
            UNION ALL
            SELECT id, path, type, source_kind, governs_path, 'public_api' AS edge_kind, unnest(public_api_names) AS edge_value
            FROM code_insights
            UNION ALL
            SELECT id, path, type, source_kind, governs_path, 'import' AS edge_kind, unnest(import_refs) AS edge_value
            FROM code_insights
            UNION ALL
            SELECT id, path, type, source_kind, governs_path, 'contract_ref' AS edge_kind, unnest(contract_refs) AS edge_value
            FROM code_insights
            UNION ALL
            SELECT id, path, type, source_kind, governs_path, 'skill_ref' AS edge_kind, unnest(skill_refs) AS edge_value
            FROM code_insights
            UNION ALL
            SELECT id, path, type, source_kind, governs_path, 'spec_ref' AS edge_kind, unnest(spec_refs) AS edge_value
            FROM code_insights
            UNION ALL
            SELECT id, path, type, source_kind, governs_path, 'todo' AS edge_kind, unnest(todo_tags) AS edge_value
            FROM code_insights
            UNION ALL
            SELECT id, path, type, source_kind, governs_path, 'test_marker' AS edge_kind, unnest(test_markers) AS edge_value
            FROM code_insights
            UNION ALL
            SELECT id, path, type, source_kind, governs_path, 'api_marker' AS edge_kind, unnest(api_markers) AS edge_value
            FROM code_insights
            UNION ALL
            SELECT id, path, type, source_kind, governs_path, 'api_call' AS edge_kind, unnest(api_calls) AS edge_value
            FROM code_insights
        )
        SELECT
            id,
            path,
            type,
            source_kind,
            governs_path,
            edge_kind,
            trim(edge_value) AS edge_value
        FROM exploded
        WHERE trim(edge_value) <> ''
        """
    )
    for statement in SYMBOL_EDGE_INDEXES:
        conn.execute(statement)


def _bulk_insert_rows(conn: duckdb.DuckDBPyConnection, rows: list[tuple[Any, ...]]) -> None:
    if not rows:
        return

    temp_path: Path | None = None
    try:
        with tempfile.NamedTemporaryFile(
            mode="w",
            encoding="utf-8",
            newline="",
            suffix=".csv",
            delete=False,
        ) as handle:
            writer = csv.writer(handle, quoting=csv.QUOTE_ALL)
            writer.writerow(DOCUMENT_COLUMNS)
            writer.writerows(rows)
            temp_path = Path(handle.name)

        conn.execute(
            """
            INSERT INTO documents
            SELECT
                id::VARCHAR,
                path::VARCHAR,
                type::VARCHAR,
                title::VARCHAR,
                content::VARCHAR,
                line_start::INTEGER,
                line_end::INTEGER,
                source_kind::VARCHAR,
                priority::DOUBLE,
                is_generated::BOOLEAN,
                is_vendor::BOOLEAN,
                governs_path::VARCHAR,
                section_kind::VARCHAR,
                sha256::VARCHAR
            FROM read_csv(
                ?,
                header = true,
                columns = {
                    'id': 'VARCHAR',
                    'path': 'VARCHAR',
                    'type': 'VARCHAR',
                    'title': 'VARCHAR',
                    'content': 'VARCHAR',
                    'line_start': 'INTEGER',
                    'line_end': 'INTEGER',
                    'source_kind': 'VARCHAR',
                    'priority': 'DOUBLE',
                    'is_generated': 'BOOLEAN',
                    'is_vendor': 'BOOLEAN',
                    'governs_path': 'VARCHAR',
                    'section_kind': 'VARCHAR',
                    'sha256': 'VARCHAR'
                }
            )
            """,
            (str(temp_path),),
        )
    finally:
        if temp_path and temp_path.exists():
            temp_path.unlink()


def _refresh_example_api_markers(conn: duckdb.DuckDBPyConnection) -> None:
    conn.execute("DROP TABLE IF EXISTS example_api_markers")
    conn.execute(
        """
        CREATE TABLE example_api_markers (
            path VARCHAR,
            api_name VARCHAR,
            line_no INTEGER
        )
        """
    )
    example_dir = WORKSPACE_ROOT / "content" / "examples"
    if not example_dir.exists():
        for statement in EXAMPLE_API_MARKER_INDEXES:
            conn.execute(statement)
        return

    rows: list[tuple[str, str, int]] = []
    for file_path in sorted(example_dir.glob("*.lua")):
        try:
            lines = file_path.read_text(encoding="utf-8", errors="replace").splitlines()
        except OSError:
            continue
        rel_path = rel_path_for(file_path)
        for line_no, line in enumerate(lines, start=1):
            match = EXAMPLE_API_MARKER_RE.match(line)
            if not match:
                continue
            rows.append((rel_path, match.group(1).lower(), line_no))

    if rows:
        temp_path: Path | None = None
        try:
            with tempfile.NamedTemporaryFile(
                mode="w",
                encoding="utf-8",
                newline="",
                suffix=".csv",
                delete=False,
            ) as handle:
                writer = csv.writer(handle, quoting=csv.QUOTE_ALL)
                writer.writerow(("path", "api_name", "line_no"))
                writer.writerows(rows)
                temp_path = Path(handle.name)
            conn.execute(
                """
                INSERT INTO example_api_markers
                SELECT
                    path::VARCHAR,
                    api_name::VARCHAR,
                    line_no::INTEGER
                FROM read_csv(
                    ?,
                    header = true,
                    columns = {
                        'path': 'VARCHAR',
                        'api_name': 'VARCHAR',
                        'line_no': 'INTEGER'
                    }
                )
                """,
                (str(temp_path),),
            )
        finally:
            if temp_path and temp_path.exists():
                temp_path.unlink()

    for statement in EXAMPLE_API_MARKER_INDEXES:
        conn.execute(statement)


def _refresh_tool_catalog(conn: duckdb.DuckDBPyConnection) -> None:
    conn.execute("DROP TABLE IF EXISTS tool_catalog")
    conn.execute(
        """
        CREATE TABLE tool_catalog (
            tool_name VARCHAR,
            registry_key VARCHAR,
            description VARCHAR,
            handler VARCHAR,
            source_path VARCHAR
        )
        """
    )
    source_path = WORKSPACE_ROOT / "tools" / "mcp" / "lurek_mcp_server.py"
    if not source_path.exists():
        for statement in TOOL_CATALOG_INDEXES:
            conn.execute(statement)
        return

    content = source_path.read_text(encoding="utf-8", errors="replace")
    rows = [
        (
            match.group("tool_name"),
            match.group("registry_key"),
            match.group("description"),
            match.group("handler"),
            rel_path_for(source_path),
        )
        for match in MCP_TOOL_SPEC_RE.finditer(content)
    ]
    if rows:
        temp_path: Path | None = None
        try:
            with tempfile.NamedTemporaryFile(
                mode="w",
                encoding="utf-8",
                newline="",
                suffix=".csv",
                delete=False,
            ) as handle:
                writer = csv.writer(handle, quoting=csv.QUOTE_ALL)
                writer.writerow(("tool_name", "registry_key", "description", "handler", "source_path"))
                writer.writerows(rows)
                temp_path = Path(handle.name)
            conn.execute(
                """
                INSERT INTO tool_catalog
                SELECT
                    tool_name::VARCHAR,
                    registry_key::VARCHAR,
                    description::VARCHAR,
                    handler::VARCHAR,
                    source_path::VARCHAR
                FROM read_csv(
                    ?,
                    header = true,
                    columns = {
                        'tool_name': 'VARCHAR',
                        'registry_key': 'VARCHAR',
                        'description': 'VARCHAR',
                        'handler': 'VARCHAR',
                        'source_path': 'VARCHAR'
                    }
                )
                """,
                (str(temp_path),),
            )
        finally:
            if temp_path and temp_path.exists():
                temp_path.unlink()

    for statement in TOOL_CATALOG_INDEXES:
        conn.execute(statement)


def _normalize_target(target: str) -> str:
    normalized = target.replace("\\", "/").strip()
    while normalized.startswith("./"):
        normalized = normalized[2:]
    return normalized.rstrip("/")


def _escape_like(value: str) -> str:
    return value.replace("\\", "\\\\").replace("_", "\\_").replace("%", "\\%")


def _count_matches(conn: duckdb.DuckDBPyConnection, sql: str, params: tuple[Any, ...]) -> int:
    return int(conn.execute(sql, params).fetchone()[0])


def _delete_path_prefix(conn: duckdb.DuckDBPyConnection, target: str) -> int:
    cleaned = _normalize_target(target).strip()
    if not cleaned:
        return 0
    removed_exact = _count_matches(conn, "SELECT count(*) FROM documents WHERE path = ?", (cleaned,))
    conn.execute("DELETE FROM documents WHERE path = ?", (cleaned,))
    like_prefix = f"{_escape_like(cleaned)}/%"
    removed_nested = _count_matches(
        conn,
        "SELECT count(*) FROM documents WHERE path LIKE ? ESCAPE '\\'",
        (like_prefix,),
    )
    conn.execute(
        "DELETE FROM documents WHERE path LIKE ? ESCAPE '\\'",
        (like_prefix,),
    )
    return removed_exact + removed_nested


def _line_chunks(
    lines: list[str],
    title: str,
    start_line: int = 1,
    *,
    max_chunk_size: int = MAX_CHUNK_SIZE,
    overlap_lines: int = 4,
) -> list[Chunk]:
    chunks: list[Chunk] = []
    current: list[str] = []
    current_start = start_line
    for offset, line in enumerate(lines, start_line):
        if current and sum(len(item) + 1 for item in current) + len(line) > max_chunk_size:
            chunks.append(Chunk(title, "\n".join(current).strip(), current_start, offset - 1))
            overlap = []
            if overlap_lines > 0:
                overlap = current[-overlap_lines:] if len(current) > overlap_lines else current[-1:]
            current = overlap[:]
            current_start = max(start_line, offset - len(current))
        current.append(line)
    if any(item.strip() for item in current):
        chunks.append(Chunk(title, "\n".join(current).strip(), current_start, start_line + len(lines) - 1))
    return [chunk for chunk in chunks if len(chunk.content) >= MIN_CHUNK_SIZE or len(chunks) == 1]


def chunk_markdown(content: str) -> list[Chunk]:
    chunks: list[Chunk] = []
    current_title = "Document Start"
    current_lines: list[str] = []
    current_start = 1
    heading_stack: list[str] = []

    for line_no, line in enumerate(content.splitlines(), 1):
        match = re.match(r"^(#{1,4})\s+(.*)", line)
        if match:
            if any(item.strip() for item in current_lines):
                chunks.extend(_line_chunks(current_lines, current_title, current_start))
            level = len(match.group(1))
            heading = match.group(2).strip()
            heading_stack = heading_stack[: level - 1] + [heading]
            current_title = " > ".join(heading_stack)
            current_lines = [line]
            current_start = line_no
        else:
            current_lines.append(line)

    if any(item.strip() for item in current_lines):
        chunks.extend(_line_chunks(current_lines, current_title, current_start))
    return chunks


def chunk_contract_markdown(content: str) -> list[Chunk]:
    chunks: list[Chunk] = []
    current_title = "Document Start"
    current_lines: list[str] = []
    current_start = 1
    heading_stack: list[str] = []

    for line_no, line in enumerate(content.splitlines(), 1):
        match = re.match(r"^(#{1,4})\s+(.*)", line)
        if match:
            if any(item.strip() for item in current_lines):
                chunks.extend(
                    _line_chunks(
                        current_lines,
                        current_title,
                        current_start,
                        max_chunk_size=min(MAX_CHUNK_SIZE, 900),
                        overlap_lines=0,
                    )
                )
            level = len(match.group(1))
            heading = match.group(2).strip()
            heading_stack = heading_stack[: level - 1] + [heading]
            current_title = " > ".join(heading_stack)
            current_lines = [line]
            current_start = line_no
        else:
            current_lines.append(line)

    if any(item.strip() for item in current_lines):
        chunks.extend(
            _line_chunks(
                current_lines,
                current_title,
                current_start,
                max_chunk_size=min(MAX_CHUNK_SIZE, 900),
                overlap_lines=0,
            )
        )
    return chunks


CODE_BOUNDARY = {
    ".rs": re.compile(r"^\s*(pub\s+)?(async\s+)?(fn|struct|enum|trait|impl|mod)\b"),
    ".py": re.compile(r"^\s*(class|def|async\s+def)\s+"),
    ".lua": re.compile(r"^\s*(local\s+function|function|describe\s*\(|it\s*\(|--@api(?:-stub)?:)"),
    ".js": re.compile(r"^\s*(export\s+)?(async\s+)?(function|class|const|let|var)\s+"),
    ".ts": re.compile(r"^\s*(export\s+)?(async\s+)?(function|class|interface|type|const|let|var)\s+"),
    ".wgsl": re.compile(r"^\s*(fn|struct|let|var)\s+"),
}


def _code_title(line: str, fallback: str) -> str:
    clean = line.strip()
    return clean[:120] if clean else fallback


def chunk_code(content: str, suffix: str, file_name: str) -> list[Chunk]:
    lines = content.splitlines()
    boundary = CODE_BOUNDARY.get(suffix)
    chunks: list[Chunk] = []
    current: list[str] = []
    current_start = 1
    current_title = f"{file_name} chunk"

    for line_no, line in enumerate(lines, 1):
        is_boundary = bool(boundary and boundary.match(line))
        current_len = sum(len(item) + 1 for item in current)
        should_split = current and is_boundary and current_len >= MIN_CHUNK_SIZE
        should_split = should_split or (current and current_len + len(line) > MAX_CHUNK_SIZE)
        if should_split:
            chunks.append(Chunk(current_title, "\n".join(current).strip(), current_start, line_no - 1))
            current = []
            current_start = line_no
        if not current and is_boundary:
            current_title = _code_title(line, f"{file_name} line {line_no}")
        current.append(line)

    if any(item.strip() for item in current):
        chunks.append(Chunk(current_title, "\n".join(current).strip(), current_start, len(lines)))
    return [chunk for chunk in chunks if len(chunk.content) >= MIN_CHUNK_SIZE or len(chunks) == 1]


def chunk_toml(content: str) -> list[Chunk]:
    chunks: list[Chunk] = []
    current: list[str] = []
    current_start = 1
    current_title = "TOML Document Start"
    for line_no, line in enumerate(content.splitlines(), 1):
        match = re.match(r"^\s*(\[[^\]]+\])", line)
        if match and current:
            chunks.extend(_line_chunks(current, current_title, current_start))
            current = []
            current_start = line_no
            current_title = match.group(1)
        elif match:
            current_title = match.group(1)
            current_start = line_no
        current.append(line)
    if any(item.strip() for item in current):
        chunks.extend(_line_chunks(current, current_title, current_start))
    return chunks


def chunk_html(content: str, file_name: str) -> list[Chunk]:
    parser = TextHTMLParser()
    parser.feed(content)
    text = parser.finish()
    return chunk_markdown(text) if text.strip() else [Chunk(file_name, "", 1, 1)]


def chunk_file(content: str, suffix: str, file_name: str, rel_path: str) -> list[Chunk]:
    if rel_path == "AGENTS.md" or rel_path.endswith("/AGENTS.md"):
        return chunk_contract_markdown(content)
    if suffix == ".md":
        return chunk_markdown(content)
    if suffix == ".toml":
        return chunk_toml(content)
    if suffix == ".html":
        return chunk_html(content, file_name)
    return chunk_code(content, suffix, file_name)


def rel_path_for(path: Path) -> str:
    return path.relative_to(WORKSPACE_ROOT).as_posix()


def governing_contract_for(rel_path: str) -> str:
    pure_path = PurePosixPath(rel_path)
    if pure_path.name == "AGENTS.md":
        return rel_path

    parents = pure_path.parts[:-1]
    for idx in range(len(parents), 0, -1):
        candidate = PurePosixPath(*parents[:idx]) / "AGENTS.md"
        if (WORKSPACE_ROOT / candidate.as_posix()).exists():
            return candidate.as_posix()
    if (WORKSPACE_ROOT / "AGENTS.md").exists():
        return "AGENTS.md"
    return ""


def source_kind(rel_path: str, file_type: str) -> str:
    if rel_path == "AGENTS.md" or rel_path.endswith("/AGENTS.md"):
        return "contract"
    if rel_path.startswith(".codex/skills/"):
        return "skill"
    if rel_path.startswith(".codex/agents/"):
        return "agent"
    if rel_path.startswith("docs/specs/"):
        return "spec"
    if rel_path.startswith("docs/"):
        return "docs"
    if rel_path.startswith("src/"):
        return "source"
    if rel_path.startswith("tests/"):
        return "test"
    if rel_path.startswith("content/examples/") or rel_path.startswith("content/snippets/"):
        return "example"
    if rel_path.startswith("tools/"):
        return "tool"
    return file_type


def priority_for(rel_path: str, kind: str) -> float:
    for pattern, value in SOURCE_PRIORITIES.items():
        if pattern == kind or rel_path == pattern or rel_path.startswith(pattern.rstrip("*")):
            return float(value)
    return float(SOURCE_PRIORITIES.get("default", 1.0))


def _matches_any(rel_path: str, patterns: list[str]) -> bool:
    return any(pattern in rel_path or rel_path.startswith(pattern.rstrip("*")) for pattern in patterns)


def contract_section_kind(title: str) -> str:
    lowered = title.lower()
    if "rule" in lowered:
        return "rules"
    if "workflow" in lowered:
        return "workflow"
    if "mission" in lowered:
        return "mission"
    if "scope" in lowered:
        return "scope"
    if "file" in lowered:
        return "files"
    if "reference" in lowered:
        return "references"
    if "document start" in lowered:
        return "preamble"
    return "other"


def should_skip(path: Path) -> bool:
    rel_path = rel_path_for(path)
    if path.name in IGNORE_FILES:
        return True
    if path.suffix not in ALLOWED_EXTENSIONS:
        return True
    if path.stat().st_size > MAX_FILE_BYTES:
        return True
    if _matches_any(rel_path, IGNORE_PATH_PATTERNS):
        return True
    rel_parts = path.relative_to(WORKSPACE_ROOT).parts
    return any(part in IGNORE_DIRS for part in rel_parts)


def index_lua_api_data(rows: list[tuple[Any, ...]]) -> int:
    if not API_DATA_PATH.exists():
        return 0

    indexed_chunks = 0
    data = json.loads(API_DATA_PATH.read_text(encoding="utf-8"))
    modules = data.get("lua_api", {}).get("modules", {})
    digest = hashlib.sha256(API_DATA_PATH.read_bytes()).hexdigest()
    for mod_name, mod_data in modules.items():
        funcs = mod_data.get("functions", [])
        for fn in funcs:
            lua_name = fn.get("lua_name", "")
            kind = fn.get("kind", "function")
            desc = fn.get("description", "")
            full_doc = fn.get("full_doc", "")
            content = f"Module: {mod_name}\nName: {lua_name}\nKind: {kind}\n\n{desc}\n\n{full_doc}".strip()
            title = f"API: {lua_name} ({kind})"
            chunk_id = f"API#{mod_name}.{lua_name}.{kind}.{indexed_chunks}"
            rows.append(
                (chunk_id, "API", "api", title, content, 1, 1, "api", 8.0, True, False, "", "api", digest)
            )
            indexed_chunks += 1
    return indexed_chunks


def process_single_file(conn: duckdb.DuckDBPyConnection, file_path: Path, rows: list[tuple[Any, ...]]) -> int:
    if should_skip(file_path):
        return 0

    rel_path = rel_path_for(file_path)
    conn.execute("DELETE FROM documents WHERE path = ?", (rel_path,))

    try:
        raw = file_path.read_bytes()
        content = raw.decode("utf-8")
    except UnicodeDecodeError:
        return 0

    if not content.strip():
        return 0

    file_type = file_path.suffix.lstrip(".")
    kind = source_kind(rel_path, file_type)
    priority = priority_for(rel_path, kind)
    is_generated = _matches_any(rel_path, GENERATED_PATH_PATTERNS)
    is_vendor = _matches_any(rel_path, VENDOR_PATH_PATTERNS)
    governs_path = governing_contract_for(rel_path)
    digest = hashlib.sha256(raw).hexdigest()
    chunks = chunk_file(content, file_path.suffix, file_path.name, rel_path)

    inserted_chunks = 0
    for idx, chunk in enumerate(chunks):
        if not chunk.content.strip():
            continue
        title = chunk.title if file_type == "md" else f"{file_path.name}: {chunk.title}"
        section_kind = contract_section_kind(chunk.title) if kind == "contract" else kind
        rows.append(
            (
                f"{rel_path}#{idx}",
                rel_path,
                file_type,
                title,
                chunk.content,
                chunk.line_start,
                chunk.line_end,
                kind,
                priority,
                is_generated,
                is_vendor,
                governs_path,
                section_kind,
                digest,
            )
        )
        inserted_chunks += 1

    return inserted_chunks


def iter_files(target_path: Path) -> list[Path]:
    if target_path.is_file():
        return [target_path]
    paths: list[Path] = []
    for root, dirs, files in os.walk(target_path):
        dirs[:] = [item for item in dirs if item not in IGNORE_DIRS]
        for file_name in files:
            paths.append(Path(root) / file_name)
    return paths


def build_index(
    targets: list[str] | None = None, db_path_override: Path | None = None
) -> dict[str, Any]:
    active_db = db_path_override if db_path_override else DB_PATH
    print(f"Building RAG index at: {active_db}")
    active_db.parent.mkdir(parents=True, exist_ok=True)

    conn = init_db(active_db)
    indexed_files = 0
    indexed_chunks = 0
    removed_targets = 0
    pending_rows: list[tuple[Any, ...]] = []

    full_rebuild = not targets
    try:
        _drop_indexes(conn)
        conn.execute("BEGIN TRANSACTION")

        if full_rebuild:
            conn.execute("DELETE FROM documents")
            targets = list(DEFAULT_TARGET_DIRS)

        if full_rebuild or "docs" in targets:
            conn.execute("DELETE FROM documents WHERE path = 'API'")
            api_chunks = index_lua_api_data(pending_rows)
            indexed_chunks += api_chunks
            print(f"Indexed {api_chunks} API functions from lua_api_data.json")

        for raw_target in targets:
            target = _normalize_target(raw_target)
            if not target:
                continue
            target_path = WORKSPACE_ROOT / target
            if not target_path.exists():
                removed_targets += _delete_path_prefix(conn, target)
                print(f"Index cleanup for missing target: {target}")
                continue

            if target_path.is_dir():
                dir_rel = rel_path_for(target_path)
                dir_prefix = f"{_escape_like(dir_rel)}/%"
                conn.execute("DELETE FROM documents WHERE path = ?", (dir_rel,))
                conn.execute(
                    "DELETE FROM documents WHERE path LIKE ? ESCAPE '\\'",
                    (dir_prefix,),
                )

            for file_path in iter_files(target_path):
                chunks_added = process_single_file(conn, file_path, pending_rows)
                if chunks_added > 0:
                    indexed_files += 1
                    indexed_chunks += chunks_added

        _bulk_insert_rows(conn, pending_rows)
        conn.commit()
        _ensure_indexes(conn)
        _refresh_code_insights(conn)
        _refresh_symbol_edges(conn)
        _refresh_example_api_markers(conn)
        _refresh_tool_catalog(conn)
        conn.execute("ANALYZE documents")
        conn.execute("ANALYZE code_insights")
        conn.execute("ANALYZE symbol_edges")
        conn.execute("ANALYZE example_api_markers")
        conn.execute("ANALYZE tool_catalog")
        conn.execute("VACUUM")
    finally:
        conn.close()
    if removed_targets:
        print(f"Removed {removed_targets} stale chunks for deleted targets.")
    print(f"Index built successfully! Indexed/Updated {indexed_files} files into {indexed_chunks} chunks.")
    return {
        "full_rebuild": full_rebuild,
        "targets": targets,
        "indexed_files": indexed_files,
        "indexed_chunks": indexed_chunks,
        "removed_chunks": removed_targets,
    }


def main() -> None:
    parser = argparse.ArgumentParser(description="Build Lurek2D RAG index")
    parser.add_argument("targets", nargs="*", help="Specific directories or files to index")
    parser.add_argument("--db", help="Override DB path for tests")
    parser.add_argument("--json", action="store_true", help="Emit JSON output")
    parser.add_argument("--output", help="Write JSON output to file")
    args = parser.parse_args()
    report = build_index(args.targets, Path(args.db) if args.db else None)
    if args.output:
        Path(args.output).write_text(json.dumps(report, ensure_ascii=False), encoding="utf-8")
    elif args.json:
        print(json.dumps(report, ensure_ascii=False))


if __name__ == "__main__":
    main()
