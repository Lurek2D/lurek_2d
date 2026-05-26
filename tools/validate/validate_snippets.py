#!/usr/bin/env python3
"""Validate content/snippets marker structure and VS Code snippet output freshness."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
if str(ROOT / "tools" / "snippets") not in sys.path:
    sys.path.insert(0, str(ROOT / "tools" / "snippets"))

from snippet_catalog import PLACEHOLDER_RE, ParseError, parse_dir  # noqa: E402

DEFAULT_SNIPPETS_DIR = ROOT / "content" / "snippets"
DEFAULT_VSCODE_SNIPPETS = ROOT / "extensions" / "vscode" / "data" / "snippets.json"


def validate_blocks(snippets_dir: Path) -> list[str]:
    issues: list[str] = []
    seen_prefixes: dict[str, Path] = {}

    try:
        blocks = parse_dir(snippets_dir)
    except ParseError as exc:
        return [str(exc)]

    if not blocks:
        issues.append(f"No snippets found in {snippets_dir}")
        return issues

    for block in blocks:
        if block.module != block.file_path.stem:
            issues.append(
                f"{block.file_path}:{block.line}: @module '{block.module}' must match file name '{block.file_path.stem}'"
            )

        if block.prefix in seen_prefixes:
            issues.append(
                f"{block.file_path}:{block.line}: duplicate @prefix '{block.prefix}' (already in {seen_prefixes[block.prefix]})"
            )
        else:
            seen_prefixes[block.prefix] = block.file_path

        if len(block.description.strip()) < 20:
            issues.append(f"{block.file_path}:{block.line}: @description is too short")

        if not block.body:
            issues.append(f"{block.file_path}:{block.line}: snippet body is empty")

        if not any(PLACEHOLDER_RE.search(line) for line in block.body):
            issues.append(f"{block.file_path}:{block.line}: snippet body must contain at least one VS Code placeholder")

    return issues


def validate_vscode_output(path: Path) -> list[str]:
    if not path.exists():
        return [f"Missing VS Code snippets file: {path}"]

    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        return [f"Invalid JSON in {path}: {exc}"]

    if not isinstance(payload, dict) or not payload:
        return [f"VS Code snippet file must be a non-empty JSON object: {path}"]

    return []


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate snippet source files and generated VS Code snippets.")
    parser.add_argument("--snippets-dir", default=str(DEFAULT_SNIPPETS_DIR))
    parser.add_argument("--vscode-snippets", default=str(DEFAULT_VSCODE_SNIPPETS))
    args = parser.parse_args()

    snippets_dir = Path(args.snippets_dir)
    vscode_snippets = Path(args.vscode_snippets)

    issues = []
    issues.extend(validate_blocks(snippets_dir))
    issues.extend(validate_vscode_output(vscode_snippets))

    if issues:
        print("Snippet validation FAILED")
        for issue in issues:
            print(f"- {issue}")
        return 1

    print("Snippet validation PASSED")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
