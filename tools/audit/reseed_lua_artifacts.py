#!/usr/bin/env python3
"""Rebuild Lua golden baselines from current evidence artifacts.

Copies only the evidence files referenced by canonical Lua golden tests into
`tests/artifacts/baselines/`. This keeps one artifact root and prevents stale
files from accumulating outside the active golden contract.
"""

from __future__ import annotations

import argparse
import re
import shutil
import sys
from pathlib import Path

from lua_artifact_lock import lua_artifact_lock

ROOT = Path(__file__).resolve().parents[2]
GOLDEN_DIR = ROOT / "tests" / "lua" / "golden"
ARTIFACTS_DIR = ROOT / "tests" / "artifacts"
CURRENT_DIR = ARTIFACTS_DIR / "current"
BASELINES_DIR = ARTIFACTS_DIR / "baselines"

EXPLICIT_MATCH_RE = re.compile(
    r'expect_golden_(?:file|text)_match\(\s*"(?P<evidence>tests/artifacts/current/[^"]+)"\s*,\s*"(?P<golden>tests/artifacts/baselines/[^"]+)"\s*\)',
    re.S,
)
DIR_MATCH_RE = re.compile(
    r'expect_golden_(?:file|text)_match\(\s*evidence_output_dir\("(?P<category>[^"]+)"\)\s*\.\.\s*"(?P<name>[^"]+)"\s*,\s*"(?P<golden>tests/artifacts/baselines/[^"]+)"\s*\)',
    re.S,
)
LOCAL_BINDING_MATCH_RE = re.compile(
    r'local\s+evidence\s*=\s*"(?P<evidence>tests/artifacts/current/[^"]+)"\s*.*?'
    r'local\s+golden\s*=\s*"(?P<golden>tests/artifacts/baselines/[^"]+)"\s*.*?'
    r'expect_golden_(?:file|text)_match\(\s*evidence\s*,\s*golden\s*\)',
    re.S,
)
MIGRATED_OUTPUT_RE = re.compile(r'return\s+"(?P<path>tests/artifacts/current/migrated_20/)"')
MIGRATED_BASELINE_RE = re.compile(r'return\s+"(?P<path>tests/artifacts/baselines/migrated_20)"')
VERIFY_CALL_RE = re.compile(r'verify_(?P<kind>png|wav)\("(?P<name>[^"]+)"\)')


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Rebuild tests/artifacts/baselines from evidence files referenced by Lua golden tests."
    )
    parser.add_argument(
        "--clean",
        action="store_true",
        help="Delete tests/artifacts/baselines before copying the referenced files.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print planned copies without modifying files.",
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Print every copied artifact.",
    )
    return parser.parse_args()


def collect_pairs() -> list[tuple[Path, Path]]:
    pairs: list[tuple[Path, Path]] = []
    for path in sorted(GOLDEN_DIR.glob("*.lua")):
        text = path.read_text(encoding="utf-8")

        for match in EXPLICIT_MATCH_RE.finditer(text):
            pairs.append((ROOT / match.group("evidence"), ROOT / match.group("golden")))

        for match in LOCAL_BINDING_MATCH_RE.finditer(text):
            pairs.append((ROOT / match.group("evidence"), ROOT / match.group("golden")))

        for match in DIR_MATCH_RE.finditer(text):
            evidence = ROOT / f'tests/artifacts/current/{match.group("category")}/{match.group("name")}'
            golden = ROOT / match.group("golden")
            pairs.append((evidence, golden))

        if "verify_png(" in text or "verify_wav(" in text:
            current_root_match = MIGRATED_OUTPUT_RE.search(text)
            baseline_root_match = MIGRATED_BASELINE_RE.search(text)
            if current_root_match and baseline_root_match:
                current_root = ROOT / current_root_match.group("path")
                baseline_root = ROOT / baseline_root_match.group("path")
                for call in VERIFY_CALL_RE.finditer(text):
                    ext = ".png" if call.group("kind") == "png" else ".wav"
                    name = call.group("name")
                    pairs.append(
                        (
                            current_root / f"{name}{ext}",
                            baseline_root / f"{name}{ext}",
                        )
                    )

    unique: list[tuple[Path, Path]] = []
    seen: set[tuple[Path, Path]] = set()
    for pair in pairs:
        if pair not in seen:
            seen.add(pair)
            unique.append(pair)
    return unique


def clean_baselines() -> None:
    if BASELINES_DIR.exists():
        shutil.rmtree(BASELINES_DIR)


def main() -> int:
    args = parse_args()
    with lua_artifact_lock("reseed_lua_artifacts.py"):
        if args.clean and not args.dry_run:
            clean_baselines()

        pairs = collect_pairs()
        missing: list[Path] = []
        copied = 0

        for evidence, golden in pairs:
            if not evidence.exists():
                missing.append(evidence)
                continue
            if args.verbose or args.dry_run:
                print(f"{evidence.relative_to(ROOT).as_posix()} -> {golden.relative_to(ROOT).as_posix()}")
            if args.dry_run:
                continue
            golden.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(evidence, golden)
            copied += 1

        print(f"referenced_pairs={len(pairs)} copied={copied} missing={len(missing)}")
        if missing:
            for evidence in missing:
                print(f"missing evidence: {evidence.relative_to(ROOT).as_posix()}", file=sys.stderr)
            return 1
        return 0


if __name__ == "__main__":
    raise SystemExit(main())
