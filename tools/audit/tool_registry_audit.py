"""Audit the single-source tools registry for internal consistency.

Checks that every durable script under `tools/` is:
  1. Registered in `tools/README.md`.
  2. Registered in `tools/agent_cli_reference.md`.
  3. Documented with a module-level docstring.
  4. Free from hardcoded user-home paths.
  5. Not duplicated under a second tool path with the same filename.

Also checks for phantom registry entries: scripts listed in the generated
registry files but missing on disk.

Usage:
    python tools/audit/tool_registry_audit.py [--strict] [--format text|json]
"""

from __future__ import annotations

import argparse
import ast
import json
import re
import sys
from pathlib import Path

ROOT = Path(".").resolve()
TOOLS_DIR = ROOT / "tools"
MASTER_README = TOOLS_DIR / "README.md"
CLI_REFERENCE = TOOLS_DIR / "agent_cli_reference.md"
HELPER_FILES = {"__init__.py"}


SCRIPT_SUFFIXES = {".py", ".ps1", ".cmd", ".bat", ".sh", ".nsi"}


def find_all_scripts() -> list[Path]:
    """Find tool scripts under `tools/`, excluding tests and helper modules."""
    scripts: list[Path] = []
    for script in sorted(TOOLS_DIR.rglob("*")):
        if not script.is_file() or script.suffix.lower() not in SCRIPT_SUFFIXES:
            continue
        rel = script.relative_to(TOOLS_DIR).as_posix()
        if rel.startswith("tests/") or "__pycache__" in rel:
            continue
        if script.name in HELPER_FILES:
            continue
        scripts.append(script)
    return scripts


def has_docstring(script: Path) -> bool:
    """Check whether the module has a top-level docstring."""
    if script.suffix.lower() != ".py":
        return bool(script.read_text(encoding="utf-8", errors="replace").strip())
    try:
        text = script.read_text(encoding="utf-8")
        tree = ast.parse(text)
    except Exception:
        return False
    return (
        bool(tree.body)
        and isinstance(tree.body[0], ast.Expr)
        and isinstance(tree.body[0].value, ast.Constant)
        and isinstance(tree.body[0].value.value, str)
    )


def has_hardcoded_user_path(script: Path) -> str | None:
    """Return the first hardcoded absolute user path if one is present."""
    try:
        text = script.read_text(encoding="utf-8")
    except Exception:
        return None
    match = re.search(r'["\']([A-Za-z]:[/\\]+Users[/\\]+\w+)', text)
    if match:
        return match.group(1)
    match = re.search(r'["\'](/home/\w+|/Users/\w+)', text)
    if match:
        return match.group(1)
    return None


def extract_registry_scripts(readme_path: Path) -> set[str]:
    """Extract backtick-wrapped script paths from a generated registry file."""
    if not readme_path.exists():
        return set()
    text = readme_path.read_text(encoding="utf-8")
    return set(re.findall(r"`([a-zA-Z0-9_./-]+\.(?:py|ps1|cmd|bat|sh|nsi))`", text))


def find_duplicate_names(scripts: list[Path]) -> list[tuple[str, list[str]]]:
    """Return duplicate filenames that appear under multiple tool paths."""
    buckets: dict[str, list[str]] = {}
    for script in scripts:
        buckets.setdefault(script.name, []).append(script.relative_to(TOOLS_DIR).as_posix())
    return [(name, paths) for name, paths in buckets.items() if len(paths) > 1]


def main() -> int:
    """Run the audit and report findings in text or JSON form."""
    parser = argparse.ArgumentParser(
        description="Audit the generated tools registry for consistency."
    )
    parser.add_argument("--strict", action="store_true")
    parser.add_argument("--format", choices=["text", "json"], default="text")
    args = parser.parse_args()

    all_scripts = find_all_scripts()
    findings: list[dict[str, str]] = []
    master_scripts = extract_registry_scripts(MASTER_README)
    cli_scripts = extract_registry_scripts(CLI_REFERENCE)

    for script in all_scripts:
        rel = script.relative_to(TOOLS_DIR).as_posix()

        if rel not in master_scripts:
            findings.append(
                {
                    "level": "ERROR",
                    "script": rel,
                    "check": "master_readme",
                    "message": "Not registered in tools/README.md",
                }
            )

        if rel not in cli_scripts:
            findings.append(
                {
                    "level": "ERROR",
                    "script": rel,
                    "check": "agent_cli_reference",
                    "message": "Not registered in tools/agent_cli_reference.md",
                }
            )

        if not has_docstring(script):
            findings.append(
                {
                    "level": "ERROR",
                    "script": rel,
                    "check": "docstring",
                    "message": "Missing module-level docstring",
                }
            )

        bad_path = has_hardcoded_user_path(script)
        if bad_path:
            findings.append(
                {
                    "level": "ERROR",
                    "script": rel,
                    "check": "hardcoded_path",
                    "message": f"Contains hardcoded user path: {bad_path}",
                }
            )

    disk_scripts = {script.relative_to(TOOLS_DIR).as_posix() for script in all_scripts}
    for listed in sorted(master_scripts | cli_scripts):
        if listed not in disk_scripts:
            findings.append(
                {
                    "level": "ERROR",
                    "script": listed,
                    "check": "phantom",
                    "message": "Listed in generated registry but not on disk",
                }
            )

    for name, paths in find_duplicate_names(all_scripts):
        findings.append(
            {
                "level": "WARN",
                "script": name,
                "check": "duplicate_name",
                "message": f"Filename reused across tools: {', '.join(paths)}",
            }
        )

    errors = [finding for finding in findings if finding["level"] == "ERROR"]

    if args.format == "json":
        print(
            json.dumps(
                {
                    "total_scripts": len(all_scripts),
                    "findings": findings,
                },
                indent=2,
            )
        )
    else:
        for finding in findings:
            print(
                f"[{finding['level']}] {finding['script']}: {finding['message']}"
            )
        print(f"\n{len(all_scripts)} scripts audited, {len(errors)} error(s)")

    if args.strict:
        return 1 if findings else 0
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
