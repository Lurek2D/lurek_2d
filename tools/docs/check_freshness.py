#!/usr/bin/env python3
"""Regenerate docs and fail if generated outputs are stale."""

from __future__ import annotations

import subprocess
import sys
import argparse
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]


def is_generated_output(path: str) -> bool:
    if path.startswith("build/docs-data/"):
        return True
    if path.startswith("logs/data/") or path.startswith("logs/reports/"):
        return True
    if path.startswith("pages/"):
        return True
    if path.startswith("docs/modules/"):
        return path.endswith(".md")
    if path.startswith("docs/wiki/"):
        return path.endswith(".md")
    if path.startswith("docs/api/"):
        return path.endswith((".md", ".lua"))
    if path.startswith("docs/specs/"):
        name = Path(path).name
        return path.endswith(".md") and name not in {"README.md", "AGENTS.md", "SPEC_TEMPLATE.md"}
    return False


def is_ignorable_docs_data_line(line: str) -> bool:
    return re.fullmatch(r'\s*"(generated|generated_at)"\s*:\s*"[^"]+",?', line) is not None


def has_only_ignored_diff(path: str) -> bool:
    if not path.startswith("build/docs-data/") or not path.endswith(".json"):
        return False
    result = subprocess.run(
        ["git", "diff", "--unified=0", "--", path],
        cwd=ROOT,
        capture_output=True,
        text=True,
        encoding="utf-8",
    )
    changed_lines = []
    for line in result.stdout.splitlines():
        if not line or line.startswith(("diff --git", "index ", "--- ", "+++ ", "@@ ")):
            continue
        if line.startswith(("+", "-")):
            changed_lines.append(line[1:])
    return bool(result.stdout.strip()) and (
        not changed_lines or all(is_ignorable_docs_data_line(line) for line in changed_lines)
    )


def main() -> int:
    parser = argparse.ArgumentParser(description="Regenerate docs and fail if generated outputs are stale")
    parser.parse_args()

    subprocess.run([sys.executable, str(ROOT / "tools" / "gen_all_docs.py")], cwd=ROOT, check=True)
    result = subprocess.run(
        ["git", "diff", "--name-only"],
        cwd=ROOT,
        capture_output=True,
        text=True,
        encoding="utf-8",
    )
    changed = [
        line
        for line in result.stdout.splitlines()
        if is_generated_output(line)
        and not has_only_ignored_diff(line)
    ]
    if changed:
        print("Generated docs are stale:")
        print("\n".join(changed))
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
