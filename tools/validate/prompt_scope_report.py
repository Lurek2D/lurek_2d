#!/usr/bin/env python3
"""Report active prompt scope and flag deprecated analysis-style prompts.

This is the tool-side replacement for review/audit/analyze prompts.
It helps keep the prompt catalog create-first and leaves non-create tasks
in the validation and audit toolchain.
"""

from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from _cag_common import PROMPTS_DIR, parse_frontmatter, relpath


def is_deprecated(path: Path) -> bool:
    text = path.read_text(encoding="utf-8")
    fm = parse_frontmatter(text)
    return bool(fm.present and str(fm.data.get("status", "")).lower() == "deprecated")


def is_create_first(path: Path) -> bool:
    name = path.stem.lower()
    create_tokens = (
        "create-",
        "add-",
        "implement-",
        "design-",
        "author-",
        "extend-",
        "flesh-",
        "generate-",
    )
    return any(name.startswith(token) for token in create_tokens)


def main() -> int:
    if not PROMPTS_DIR.exists():
        print("No .github/prompts directory found.")
        return 1

    prompts = sorted(PROMPTS_DIR.glob("*.prompt.md"))
    active = [p for p in prompts if not is_deprecated(p)]
    deprecated = [p for p in prompts if is_deprecated(p)]

    print("Prompt scope report")
    print("- total prompts:", len(prompts))
    print("- active create-first prompts:", sum(1 for p in active if is_create_first(p)))
    print("- active non-create prompts:", sum(1 for p in active if not is_create_first(p)))
    print("- deprecated prompts:", len(deprecated))

    if deprecated:
        print("\nDeprecated prompts:")
        for p in deprecated:
            print("  -", relpath(p))

    if active:
        print("\nActive prompt catalog (create-first only):")
        for p in active:
            if is_create_first(p):
                print("  +", relpath(p))

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
