#!/usr/bin/env python3
"""Check links and structured References across active Codex skills and contracts."""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "validate"))
from _cag_common import (  # noqa: E402
    CODEX_DIR, WORKSPACE_ROOT, discover_repo_agents, discover_skills, optional_missing,
    parse_references, relpath, safe_read,
)


def repo_root(path: Path) -> Path:
    for candidate in (path.parent, *path.parents):
        if (candidate / ".git").exists():
            return candidate
    return WORKSPACE_ROOT


def resolve(path: Path, token: str) -> Path | None:
    token = token.strip().split("#", 1)[0]
    if not token or any(char in token for char in " <>|*") or token.startswith(("http://", "https://", "lurek.")):
        return None
    if token.startswith("tools/") or token.startswith(("AGENTS.md", ".codex/", "content/", "docs/", "src/", "tests/", "lurek_2d_")):
        return WORKSPACE_ROOT / token
    candidate = repo_root(path) / token
    return candidate if "/" in token or token.endswith((".md", ".toml", ".py", ".lua", ".json")) else None


def scan(require_workspace: bool = False) -> dict[str, object]:
    files = sorted(set(discover_skills() + discover_repo_agents() + list(CODEX_DIR.glob("*.md"))))
    broken: list[dict[str, object]] = []
    total = 0
    for source in files:
        text = safe_read(source)
        refs = parse_references(text)
        contracts = refs.get("contracts")
        if isinstance(contracts, list):
            for token in contracts:
                target = WORKSPACE_ROOT / token
                total += 1
                rel = relpath(target)
                if not target.exists() and (require_workspace or not optional_missing(rel)):
                    broken.append({"file": relpath(source), "target": token, "resolved": rel})
        tools = refs.get("tools")
        if isinstance(tools, list):
            for token in tools:
                for script in re.findall(r"(?:^|\s)(tools/[A-Za-z0-9_./-]+\.(?:py|cmd|ps1))", token):
                    target = WORKSPACE_ROOT / script
                    total += 1
                    if not target.exists():
                        broken.append({"file": relpath(source), "target": script, "resolved": relpath(target)})
    return {"files_scanned": len(files), "links_total": total, "broken_total": len(broken), "broken": broken}


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--strict", action="store_true")
    parser.add_argument("--require-workspace", action="store_true")
    parser.add_argument("--format", choices=["text", "json"], default="text")
    args = parser.parse_args()
    report = scan(args.require_workspace)
    if args.format == "json":
        print(json.dumps(report, indent=2))
    else:
        for item in report["broken"]:
            print(f"  BROKEN {item['file']} -> {item['target']} ({item['resolved']})")
        print(f"Files scanned: {report['files_scanned']}, links: {report['links_total']}, broken: {report['broken_total']}")
    return 1 if args.strict and report["broken_total"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
