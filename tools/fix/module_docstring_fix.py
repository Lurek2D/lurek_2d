#!/usr/bin/env python3
"""Apply manually authored Rust file-level //! docs from a manifest."""

from __future__ import annotations

import argparse
import difflib
import json
import sys
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parent.parent.parent
AUDIT_DIR = ROOT / "tools" / "audit"
if str(AUDIT_DIR) not in sys.path:
    sys.path.insert(0, str(AUDIT_DIR))

from module_docstring_audit import (  # noqa: E402
    MAX_DOC_BODY_CHARS,
    MIN_DOC_BODY_CHARS,
    collect_leading_doc_lines,
    required_doc_lines,
)


def repo_rel(path: Path) -> str:
    return str(path.relative_to(ROOT)).replace("\\", "/")


def normalize_doc_body(text: str) -> str:
    body = text.strip()
    if body.startswith("//!"):
        body = body[3:].lstrip()
    return " ".join(body.split())


def strip_leading_doc_block(lines: list[str]) -> list[str]:
    seen_doc = False
    end = 0
    for index, line in enumerate(lines):
        stripped = line.rstrip()
        if stripped.startswith("//!"):
            seen_doc = True
            end = index + 1
        elif not seen_doc and stripped == "":
            end = index + 1
            continue
        else:
            break
    rest = lines[end:]
    while rest and rest[0].strip() == "":
        rest = rest[1:]
    return rest


def load_manifest(path: Path) -> dict[str, list[str]]:
    raw = json.loads(path.read_text(encoding="utf-8"))
    if isinstance(raw, dict) and isinstance(raw.get("files"), dict):
        raw = raw["files"]
    if not isinstance(raw, dict):
        raise ValueError("manifest must be a JSON object or an object with a `files` map")

    normalized: dict[str, list[str]] = {}
    for rel_path, lines in raw.items():
        if not isinstance(rel_path, str) or not isinstance(lines, list) or not all(isinstance(item, str) for item in lines):
            raise ValueError("manifest entries must map repo-relative file paths to arrays of strings")
        normalized[rel_path.replace("\\", "/")] = list(lines)
    return normalized


def validate_manual_lines(path: Path, doc_lines: list[str], *, min_chars: int, max_chars: int) -> list[str]:
    errors: list[str] = []
    bodies = [normalize_doc_body(line) for line in doc_lines]
    try:
        file_lines = path.read_text(encoding="utf-8", errors="replace").splitlines()
    except OSError as exc:
        return [f"{repo_rel(path)}: cannot read file: {exc}"]

    required = required_doc_lines(path, len(file_lines))
    if len(bodies) != required:
        errors.append(f"{repo_rel(path)}: got {len(bodies)} manual line(s), expected exactly {required}")

    for index, body in enumerate(bodies, start=1):
        if not body:
            errors.append(f"{repo_rel(path)}: line {index} is empty after removing //! prefix")
            continue
        length = len(body)
        if length < min_chars or length > max_chars:
            errors.append(
                f"{repo_rel(path)}: line {index} has {length} characters, expected between {min_chars} and {max_chars}"
            )
    return errors


def build_rewritten_text(path: Path, manual_lines: list[str]) -> str:
    text = path.read_text(encoding="utf-8", errors="replace")
    lines = text.splitlines()
    rest = strip_leading_doc_block(lines)
    doc_lines = [f"//! {normalize_doc_body(line)}" for line in manual_lines]
    new_lines = [*doc_lines, "", *rest] if rest else doc_lines
    return "\n".join(new_lines) + ("\n" if text.endswith("\n") or text else "")


def rewrite_file(path: Path, manual_lines: list[str], *, dry_run: bool) -> bool:
    try:
        old_text = path.read_text(encoding="utf-8", errors="replace")
    except OSError as exc:
        print(f"ERROR {repo_rel(path)}: {exc}")
        return False

    new_text = build_rewritten_text(path, manual_lines)
    if new_text == old_text:
        print(f"OK    {repo_rel(path)}")
        return True

    if dry_run:
        rel = repo_rel(path)
        diff = difflib.unified_diff(
            old_text.splitlines(),
            new_text.splitlines(),
            fromfile=rel,
            tofile=rel,
            lineterm="",
        )
        print("\n".join(diff))
        return True

    path.write_text(new_text, encoding="utf-8")
    print(f"APPLY {repo_rel(path)}")
    return True


def resolve_targets(manifest: dict[str, list[str]], only_file: str | None) -> list[tuple[Path, list[str]]]:
    if only_file:
        rel = only_file.replace("\\", "/")
        if rel not in manifest:
            raise ValueError(f"{rel} is not present in the manifest")
        return [(ROOT / rel, manifest[rel])]

    return [(ROOT / rel, lines) for rel, lines in sorted(manifest.items())]


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--manifest", required=True, help="JSON manifest mapping repo-relative Rust files to manual //! lines.")
    parser.add_argument("--file", help="Apply only one repo-relative Rust file from the manifest.")
    parser.add_argument("--dry-run", action="store_true", help="Print unified diffs without writing files.")
    parser.add_argument(
        "--min-doc-body-chars",
        type=int,
        default=MIN_DOC_BODY_CHARS,
        help="Minimum nonblank characters required after each //! prefix.",
    )
    parser.add_argument(
        "--max-doc-body-chars",
        type=int,
        default=MAX_DOC_BODY_CHARS,
        help="Maximum nonblank characters allowed after each //! prefix.",
    )
    args = parser.parse_args()

    if args.min_doc_body_chars > args.max_doc_body_chars:
        print("ERROR: --min-doc-body-chars cannot be greater than --max-doc-body-chars", file=sys.stderr)
        return 2

    manifest_path = Path(args.manifest).resolve()
    if not manifest_path.is_file():
        print(f"ERROR: manifest not found: {manifest_path}", file=sys.stderr)
        return 2

    try:
        manifest = load_manifest(manifest_path)
        targets = resolve_targets(manifest, args.file)
    except (ValueError, json.JSONDecodeError) as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 2

    validation_errors: list[str] = []
    for path, manual_lines in targets:
        if not path.is_file():
            validation_errors.append(f"{repo_rel(path)}: file not found")
            continue
        validation_errors.extend(
            validate_manual_lines(
                path,
                manual_lines,
                min_chars=args.min_doc_body_chars,
                max_chars=args.max_doc_body_chars,
            )
        )

    if validation_errors:
        for error in validation_errors:
            print(f"ERROR: {error}", file=sys.stderr)
        return 1

    failures = 0
    for path, manual_lines in targets:
        if not rewrite_file(path, manual_lines, dry_run=args.dry_run):
            failures += 1
    if failures:
        print(f"FAILED {failures}/{len(targets)} file(s).")
        return 1

    print(f"Processed {len(targets)} file(s).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
