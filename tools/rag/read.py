"""
Read full chunks from the local Lurek2D RAG index by chunk id.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

from query import read_chunk

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")


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
    parser.add_argument("--neighbors", type=int, default=1, help="Adjacent chunks from the same file")
    parser.add_argument("--content-chars", type=int, default=12000, help="Max content chars per chunk")
    parser.add_argument("--db", help="Override DB path for tests")
    parser.add_argument("--json", action="store_true", help="Emit compact JSON output")
    parser.add_argument("--output", help="Write JSON output to file")
    args = parser.parse_args()
    result = read_chunk(
        args.id,
        Path(args.db) if args.db else None,
        neighbors=args.neighbors,
        content_chars=args.content_chars,
    )
    emit_payload(result, json_output=args.json, output_path=args.output)


if __name__ == "__main__":
    main()
