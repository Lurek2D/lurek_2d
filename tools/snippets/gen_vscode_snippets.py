#!/usr/bin/env python3
"""Build extensions/vscode/data/snippets.json from content/snippets/*.lua."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path

from snippet_catalog import parse_dir

ROOT = Path(__file__).resolve().parents[2]
SNIPPETS_DIR = ROOT / "content" / "snippets"
OUT_FILE = ROOT / "extensions" / "vscode" / "data" / "snippets.json"
TOKEN_RE = re.compile(r"\bSNIP_(\d+)_([A-Za-z0-9_]+)\b")


def convert_tokens(line: str) -> str:
    def repl(match: re.Match[str]) -> str:
        index = match.group(1)
        default = match.group(2)
        return f"${{{index}:{default}}}"

    return TOKEN_RE.sub(repl, line)


def main() -> int:
    parser = argparse.ArgumentParser(description="Generate VS Code snippets JSON from Lua snippet catalogs.")
    parser.add_argument("--snippets-dir", default=str(SNIPPETS_DIR))
    parser.add_argument("--out", default=str(OUT_FILE))
    args = parser.parse_args()

    snippets_dir = Path(args.snippets_dir)
    out = Path(args.out)

    blocks = parse_dir(snippets_dir)

    payload: dict[str, dict] = {}
    for block in blocks:
        title = f"{block.module}: {block.prefix}"
        payload[title] = {
            "prefix": block.prefix,
            "description": block.description,
            "scope": "lua",
            "body": [convert_tokens(line) for line in block.body],
        }

    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(payload, indent=2, ensure_ascii=False) + "\n", encoding="utf-8", newline="\n")

    print(f"Generated {len(payload)} VS Code snippets to {out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
