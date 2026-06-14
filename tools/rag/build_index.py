"""
Build the local SQLite FTS5 RAG index for Lurek2D docs, code, tests, and Codex assets.
"""

from __future__ import annotations

import argparse
import hashlib
import html.parser
import json
import os
import re
import sqlite3
import tomllib
from dataclasses import dataclass
from pathlib import Path


WORKSPACE_ROOT = Path(__file__).resolve().parent.parent.parent
DB_PATH = WORKSPACE_ROOT / "tools" / "rag" / "rag_index.db"
CONFIG_PATH = WORKSPACE_ROOT / "tools" / "rag" / "rag.toml"
API_DATA_PATH = WORKSPACE_ROOT / "logs" / "data" / "lua_api_data.json"


with open(CONFIG_PATH, "rb") as f:
    config = tomllib.load(f)


INDEXING = config.get("indexing", {})
RANKING = config.get("ranking", {})

MAX_CHUNK_SIZE = int(INDEXING.get("max_chunk_size", 1800))
MIN_CHUNK_SIZE = int(INDEXING.get("min_chunk_size", 120))
ALLOWED_EXTENSIONS = set(
    INDEXING.get(
        "allowed_extensions",
        [".md", ".lua", ".rs", ".py", ".toml", ".json", ".html", ".js", ".ts", ".css", ".wgsl"],
    )
)
DEFAULT_TARGET_DIRS = INDEXING.get(
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
IGNORE_DIRS = set(
    INDEXING.get(
        "ignore_dirs",
        [".git", ".pytest_cache", "__pycache__", "node_modules", "target", "dist", "build", ".cache"],
    )
)
IGNORE_FILES = set(INDEXING.get("ignore_files", ["rag_index.db"]))
IGNORE_PATH_PATTERNS = INDEXING.get("ignore_path_patterns", [])
MAX_FILE_BYTES = int(INDEXING.get("max_file_bytes", 2_000_000))
SOURCE_PRIORITIES = RANKING.get("source_priorities", {})
GENERATED_PATH_PATTERNS = RANKING.get(
    "generated_path_patterns",
    [".github/prompts/", "pages/", "docs/api/lurek.lua", "docs/api/lurek.md", "docs/wiki/API-Reference.md"],
)
VENDOR_PATH_PATTERNS = RANKING.get("vendor_path_patterns", ["node_modules/", "/vendor/"])



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


def init_db(db_path: Path) -> sqlite3.Connection:
    conn = sqlite3.connect(db_path)
    existing_cols = [row[1] for row in conn.execute("PRAGMA table_info(documents)").fetchall()]
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
        "sha256",
    ]
    if existing_cols and existing_cols != expected_cols:
        conn.execute("DROP TABLE IF EXISTS documents")
    conn.execute(
        """
        CREATE VIRTUAL TABLE IF NOT EXISTS documents USING fts5(
            id UNINDEXED,
            path,
            type UNINDEXED,
            title,
            content,
            line_start UNINDEXED,
            line_end UNINDEXED,
            source_kind UNINDEXED,
            priority UNINDEXED,
            is_generated UNINDEXED,
            is_vendor UNINDEXED,
            sha256 UNINDEXED,
            tokenize = 'unicode61 tokenchars ''_./:-'''
        );
        """
    )
    return conn


def _normalize_target(target: str) -> str:
    normalized = target.replace("\\", "/").strip()
    while normalized.startswith("./"):
        normalized = normalized[2:]
    return normalized.rstrip("/")


def _escape_like(value: str) -> str:
    return value.replace("\\", "\\\\").replace("_", "\\_").replace("%", "\\%")


def _delete_path_prefix(cursor: sqlite3.Cursor, target: str) -> int:
    cleaned = _normalize_target(target).strip()
    if not cleaned:
        return 0
    removed_exact = cursor.execute("DELETE FROM documents WHERE path = ?", (cleaned,)).rowcount
    like_prefix = f"{_escape_like(cleaned)}/%"
    removed_nested = cursor.execute(
        "DELETE FROM documents WHERE path LIKE ? ESCAPE '\\\\'",
        (like_prefix,),
    ).rowcount
    return int(removed_exact) + int(removed_nested)


def _line_chunks(lines: list[str], title: str, start_line: int = 1) -> list[Chunk]:
    chunks: list[Chunk] = []
    current: list[str] = []
    current_start = start_line
    for offset, line in enumerate(lines, start_line):
        if current and sum(len(item) + 1 for item in current) + len(line) > MAX_CHUNK_SIZE:
            chunks.append(Chunk(title, "\n".join(current).strip(), current_start, offset - 1))
            overlap = current[-4:] if len(current) > 4 else current[-1:]
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


CODE_BOUNDARY = {
    ".rs": re.compile(r"^\s*(pub\s+)?(async\s+)?(fn|struct|enum|trait|impl|mod)\b"),
    ".py": re.compile(r"^\s*(class|def|async\s+def)\s+"),
    ".lua": re.compile(r"^\s*(local\s+function|function|describe\s*\(|it\s*\(|--@api-stub:)"),
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


def chunk_file(content: str, suffix: str, file_name: str) -> list[Chunk]:
    if suffix == ".md":
        return chunk_markdown(content)
    if suffix == ".toml":
        return chunk_toml(content)
    if suffix == ".html":
        return chunk_html(content, file_name)
    return chunk_code(content, suffix, file_name)


def rel_path_for(path: Path) -> str:
    return path.relative_to(WORKSPACE_ROOT).as_posix()


def source_kind(rel_path: str, file_type: str) -> str:
    if rel_path == "AGENTS.md" or rel_path.endswith("/AGENTS.md"):
        return "contract"
    if rel_path.startswith(".codex/skills/"):
        return "skill"
    if rel_path.startswith(".codex/agents/"):
        return "agent"
    if rel_path.startswith(".github/prompts/"):
        return "prompt_mirror"
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
    if rel_path.startswith("pages/"):
        return "page"
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


def index_lua_api_data(cursor: sqlite3.Cursor) -> int:
    if not API_DATA_PATH.exists():
        return 0

    cursor.execute("DELETE FROM documents WHERE path = 'API'")
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
            chunk_id = f"API#{lua_name}"
            cursor.execute(
                """
                INSERT INTO documents
                (id, path, type, title, content, line_start, line_end, source_kind, priority, is_generated, is_vendor, sha256)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (chunk_id, "API", "api", title, content, 1, 1, "api", 8.0, 1, 0, digest),
            )
            indexed_chunks += 1
    return indexed_chunks


def process_single_file(cursor: sqlite3.Cursor, file_path: Path) -> int:
    if should_skip(file_path):
        return 0

    rel_path = rel_path_for(file_path)
    cursor.execute("DELETE FROM documents WHERE path = ?", (rel_path,))

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
    is_generated = int(_matches_any(rel_path, GENERATED_PATH_PATTERNS))
    is_vendor = int(_matches_any(rel_path, VENDOR_PATH_PATTERNS))
    digest = hashlib.sha256(raw).hexdigest()
    chunks = chunk_file(content, file_path.suffix, file_path.name)

    for idx, chunk in enumerate(chunks):
        if not chunk.content.strip():
            continue
        title = chunk.title if file_type == "md" else f"{file_path.name}: {chunk.title}"
        cursor.execute(
            """
            INSERT INTO documents
            (id, path, type, title, content, line_start, line_end, source_kind, priority, is_generated, is_vendor, sha256)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
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
                digest,
            ),
        )

    return len(chunks)


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
    cursor = conn.cursor()
    indexed_files = 0
    indexed_chunks = 0
    removed_targets = 0

    full_rebuild = not targets
    if full_rebuild:
        cursor.execute("DELETE FROM documents")
        targets = list(DEFAULT_TARGET_DIRS)

    if full_rebuild or "docs" in targets:
        api_chunks = index_lua_api_data(cursor)
        indexed_chunks += api_chunks
        print(f"Indexed {api_chunks} API functions from lua_api_data.json")

    for raw_target in targets:
        target = _normalize_target(raw_target)
        if not target:
            continue
        target_path = WORKSPACE_ROOT / target
        if not target_path.exists():
            removed_targets += _delete_path_prefix(cursor, target)
            print(f"Index cleanup for missing target: {target}")
            continue

        if target_path.is_dir():
            dir_prefix = f"{_escape_like(rel_path_for(target_path))}/%"
            cursor.execute(
                "DELETE FROM documents WHERE path LIKE ? ESCAPE '\\\\'",
                (dir_prefix,),
            )

        for file_path in iter_files(target_path):
            chunks_added = process_single_file(cursor, file_path)
            if chunks_added > 0:
                indexed_files += 1
                indexed_chunks += chunks_added

    conn.commit()
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
