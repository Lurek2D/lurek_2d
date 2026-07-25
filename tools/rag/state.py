"""Shared state, configuration, and tokenization helpers for the local RAG.

The active index is selected through a tiny JSON manifest.  Readers never open
the database being written, which keeps a successful previous generation
available throughout a rebuild.
"""

from __future__ import annotations

import hashlib
import json
import os
import re
import time
import unicodedata
import uuid
from contextlib import contextmanager
from pathlib import Path, PurePosixPath
from typing import Any, Iterator

import tomllib


WORKSPACE_ROOT = Path(__file__).resolve().parent.parent.parent
RAG_DIR = Path(__file__).resolve().parent
CONFIG_PATH = RAG_DIR / "rag.toml"
CONTRACT_PATH = RAG_DIR / "rag_contract.json"
MANIFEST_PATH = RAG_DIR / "rag_index.manifest.json"
LEGACY_DB_PATH = RAG_DIR / "rag_index.duckdb"
SCHEMA_VERSION = 2

POLISH_ALIASES = {
    "muzyka": "audio", "dzwiek": "audio", "dźwięk": "audio", "audio": "audio",
    "kolizja": "physics", "fizyka": "physics", "physics": "physics",
    "przyklad": "example", "przykład": "example", "example": "example",
    "specyfikacja": "spec", "spec": "spec", "narzedzie": "tool", "narzędzie": "tool",
    "wejscie": "input", "wejście": "input",
}
NON_ASCII_RE = re.compile(r"[^\x00-\x7f]")
CAMEL_BOUNDARY_RE = re.compile(r"(?<=[a-z0-9])(?=[A-Z])")
WORD_RE = re.compile(r"[\w]+", flags=re.UNICODE)
LUA_SYMBOL_RE = re.compile(r"\blurek(?:\.[A-Za-z0-9_]+){1,}\b")


def load_config() -> dict[str, Any]:
    try:
        with CONFIG_PATH.open("rb") as handle:
            config = tomllib.load(handle)
    except (OSError, tomllib.TOMLDecodeError) as exc:
        raise RuntimeError(f"Invalid RAG configuration {CONFIG_PATH.name}: {exc}") from exc
    if not isinstance(config, dict):
        raise RuntimeError("Invalid RAG configuration: root must be a TOML table.")
    return config


def config_fingerprint(config: dict[str, Any] | None = None) -> str:
    payload = json.dumps(config or load_config(), ensure_ascii=False, sort_keys=True, separators=(",", ":"))
    return hashlib.sha256(payload.encode("utf-8")).hexdigest()


def load_manifest() -> dict[str, Any] | None:
    try:
        data = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))
    except FileNotFoundError:
        return None
    except (OSError, json.JSONDecodeError) as exc:
        raise RuntimeError(f"Invalid RAG index manifest: {exc}") from exc
    if not isinstance(data, dict) or not isinstance(data.get("active"), str):
        raise RuntimeError("Invalid RAG index manifest: `active` is required.")
    return data


def active_db_path(db_override: Path | None = None) -> Path:
    """Resolve a test override, then the active snapshot, then the legacy DB."""
    if db_override is not None:
        return db_override
    manifest = load_manifest()
    if manifest:
        active = MANIFEST_PATH.parent / manifest["active"]
        if not active.is_file():
            raise RuntimeError(f"RAG manifest points to a missing snapshot: {active.name}")
        return active
    return LEGACY_DB_PATH


def new_generation_path() -> tuple[str, Path]:
    generation = f"{int(time.time() * 1000):013d}-{uuid.uuid4().hex[:8]}"
    return generation, RAG_DIR / f"rag_index.{generation}.duckdb"


def publish_manifest(generation: str, db_path: Path, metadata: dict[str, Any]) -> None:
    manifest = {
        "schema_version": SCHEMA_VERSION,
        "active": db_path.name,
        "generation": generation,
        "published_at": int(time.time()),
        **metadata,
    }
    temporary = MANIFEST_PATH.with_suffix(".tmp")
    temporary.write_text(json.dumps(manifest, ensure_ascii=False, indent=2, sort_keys=True), encoding="utf-8")
    os.replace(temporary, MANIFEST_PATH)


def cleanup_snapshots(keep: int = 2) -> None:
    manifest = load_manifest()
    active = manifest.get("active") if manifest else None
    snapshots = sorted(RAG_DIR.glob("rag_index.*.duckdb"), key=lambda path: path.stat().st_mtime, reverse=True)
    retained = 0
    for path in snapshots:
        if path.name == active or retained < keep:
            retained += 1
            continue
        try:
            path.unlink()
        except OSError:
            # A reader may still hold a Windows handle; it will be retried later.
            continue


@contextmanager
def writer_lock(timeout_seconds: float = 30.0) -> Iterator[None]:
    """A small cross-process lock used only by snapshot writers."""
    lock_path = RAG_DIR / "rag_index.lock"
    deadline = time.monotonic() + timeout_seconds
    handle: Any | None = None
    while handle is None:
        try:
            handle = lock_path.open("x", encoding="utf-8")
            handle.write(str(os.getpid()))
            handle.flush()
        except FileExistsError:
            if time.monotonic() >= deadline:
                raise RuntimeError("RAG index writer is busy; timed out waiting for lock.")
            time.sleep(0.05)
    try:
        yield
    finally:
        handle.close()
        try:
            lock_path.unlink()
        except OSError:
            pass


def fold_text(value: str) -> str:
    return "".join(
        char for char in unicodedata.normalize("NFD", value.casefold()) if unicodedata.category(char) != "Mn"
    )


def tokenize(value: str, *, expand_aliases: bool = True) -> list[str]:
    """Tokenize Unicode words, symbols, paths, camelCase and snake_case."""
    normalized = unicodedata.normalize("NFC", value).casefold()
    expanded = CAMEL_BOUNDARY_RE.sub(" ", value)
    expanded = unicodedata.normalize("NFC", expanded).casefold().replace("/", " ").replace(".", " ")
    raw = WORD_RE.findall(expanded)
    tokens: list[str] = []
    for token in raw:
        if len(token) < 2:
            continue
        tokens.append(token)
        folded = fold_text(token) if NON_ASCII_RE.search(token) else token
        if folded != token:
            tokens.append(folded)
        if expand_aliases:
            alias = POLISH_ALIASES.get(token) or POLISH_ALIASES.get(folded)
            if alias:
                tokens.append(alias)
    # Preserve full Lua symbols as an exact search term in addition to segments.
    for symbol in LUA_SYMBOL_RE.findall(normalized):
        tokens.append(symbol)
    return list(dict.fromkeys(tokens))


def safe_repo_target(value: str) -> str:
    normalized = value.replace("\\", "/").strip().rstrip("/")
    if not normalized or normalized.startswith("/") or re.match(r"^[A-Za-z]:", normalized):
        raise ValueError("targets must be non-empty repository-relative paths.")
    pure = PurePosixPath(normalized)
    if any(part in {"", ".", ".."} for part in pure.parts):
        raise ValueError("targets must not contain traversal segments.")
    return pure.as_posix()
