"""
Read full chunks from the local Lurek2D RAG index by chunk id.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

from query import (
    RAG_READ_CONTENT_CHARS_DEFAULT,
    RAG_READ_CONTENT_CHARS_MAX,
    RAG_READ_CONTENT_CHARS_MIN,
    RAG_READ_DEFAULT_NEIGHBORS,
    RAG_READ_NEIGHBORS_MAX,
    RAG_READ_NEIGHBORS_MIN,
)

from query import read_chunk

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")


def _clamp_rag_arg(value: int, name: str, min_value: int, max_value: int) -> int:
    if value < min_value or value > max_value:
        raise ValueError(f"`{name}` must be between {min_value} and {max_value}.")
    return value


def emit_payload(payload: dict, *, json_output: bool = False, output_path: str | None = None) -> None:
    if output_path:
        Path(output_path).write_text(json.dumps(payload, ensure_ascii=False), encoding="utf-8")
        return
    if json_output:
        print(json.dumps(payload, ensure_ascii=False))
    else:
        print(json.dumps(payload, indent=2, ensure_ascii=False))


def main() -> None:
    parser = argparse.ArgumentParser(description="Read a Lurek2D RAG chunk by id")
    parser.add_argument("id", help="Exact chunk id returned by tools/rag/query.py")
    parser.add_argument(
        "--neighbors",
        type=int,
        default=RAG_READ_DEFAULT_NEIGHBORS,
        help="Adjacent chunks from the same file",
    )
    parser.add_argument(
        "--content-chars",
        type=int,
        default=RAG_READ_CONTENT_CHARS_DEFAULT,
        help="Max content chars per chunk",
    )
    parser.add_argument("--db", help="Override DB path for tests")
    parser.add_argument("--json", action="store_true", help="Emit compact JSON output")
    parser.add_argument("--output", help="Write JSON output to file")
    args = parser.parse_args()

    try:
        neighbors = _clamp_rag_arg(
            args.neighbors,
            "neighbors",
            RAG_READ_NEIGHBORS_MIN,
            RAG_READ_NEIGHBORS_MAX,
        )
        content_chars = _clamp_rag_arg(
            args.content_chars,
            "content_chars",
            RAG_READ_CONTENT_CHARS_MIN,
            RAG_READ_CONTENT_CHARS_MAX,
        )
    except ValueError as exc:
        emit_payload({"error": str(exc)}, json_output=args.json, output_path=args.output)
        return

    result = read_chunk(
        args.id,
        Path(args.db) if args.db else None,
        neighbors=neighbors,
        content_chars=content_chars,
    )
    emit_payload(result, json_output=args.json, output_path=args.output)


if __name__ == "__main__":
    main()
