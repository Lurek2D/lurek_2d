#!/usr/bin/env python3
"""Inventory and classify legacy showcase-style entries."""

from __future__ import annotations

import argparse
import json
from dataclasses import asdict, dataclass
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SHOWCASE_ROOT = ROOT / "content" / "showcase"

PLACEHOLDER_TOKENS = (
    "next step:",
    "skeleton",
    "upgrade target",
    "merge target",
)


@dataclass
class ShowcaseEntry:
    path: str
    has_main: bool
    has_conf: bool
    has_readme: bool
    has_screen: bool
    has_preview: bool
    placeholder_text: bool
    classification: str
    reasons: list[str]


def _read_text(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except Exception:
        return ""


def _iter_entries(root: Path) -> list[Path]:
    entries: list[Path] = []
    for candidate in sorted(root.rglob("main.lua")):
        entries.append(candidate.parent)
    return entries


def classify_entry(path: Path) -> ShowcaseEntry:
    main = path / "main.lua"
    conf = (path / "conf.toml").exists() or (path / "conf.lua").exists()
    readme = path / "README.md"
    screen = (path / "screen.png").exists() or (path / "screenshot_smoke.png").exists()
    preview = (path / "preview.gif").exists()

    text = (_read_text(main) + "\n" + _read_text(readme)).lower()
    placeholder = any(token in text for token in PLACEHOLDER_TOKENS)

    reasons: list[str] = []
    if placeholder:
        reasons.append("placeholder-text")
    if not conf:
        reasons.append("missing-conf")
    if not readme.exists():
        reasons.append("missing-readme")
    if not screen:
        reasons.append("missing-screen")

    if placeholder and not conf:
        classification = "candidate_delete_or_evidence"
    elif placeholder:
        classification = "candidate_review"
    else:
        classification = "showcase"

    try:
        display_path = path.relative_to(ROOT).as_posix()
    except ValueError:
        display_path = path.as_posix()

    return ShowcaseEntry(
        path=display_path,
        has_main=main.exists(),
        has_conf=conf,
        has_readme=readme.exists(),
        has_screen=screen,
        has_preview=preview,
        placeholder_text=placeholder,
        classification=classification,
        reasons=reasons,
    )


def render_text(entries: list[ShowcaseEntry]) -> str:
    counts: dict[str, int] = {}
    for entry in entries:
        counts[entry.classification] = counts.get(entry.classification, 0) + 1

    lines = ["Showcase audit", "", "Summary:"]
    for key in sorted(counts):
        lines.append(f"- {key}: {counts[key]}")

    flagged = [entry for entry in entries if entry.classification != "showcase"]
    if flagged:
        lines.append("")
        lines.append("Flagged entries:")
        for entry in flagged:
            lines.append(f"- {entry.path}: {entry.classification} ({', '.join(entry.reasons)})")
    return "\n".join(lines) + "\n"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--json", action="store_true", help="emit JSON instead of text")
    args = parser.parse_args()

    entries = [classify_entry(path) for path in _iter_entries(SHOWCASE_ROOT)]
    if args.json:
        print(json.dumps([asdict(entry) for entry in entries], indent=2))
    else:
        print(render_text(entries), end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
