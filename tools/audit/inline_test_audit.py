#!/usr/bin/env python3
"""inline_test_audit.py — Enforce TST-02 (no inline `#[cfg(test)]` in src/).

Walks ``src/**/*.rs`` and reports every inline ``#[cfg(test)]`` block, the
number of ``#[test]`` functions it contains, and the suggested migration
target under ``tests/rust/unit/<module>_tests.rs`` (plus a Lua candidate
when a ``src/lua_api/<module>_api.rs`` exists, per TST-01).

Exit code: 0 if no blocks found, 1 otherwise.

Usage:
```
usage: inline_test_audit.py [-h] [--root ROOT] [--scope SCOPE]
                            [--format {text,json}] [--output OUTPUT]

inline_test_audit.py â€” Enforce TST-02 (no inline `#[cfg(test)]` in src/).

options:
  -h, --help            show this help message and exit
  --root ROOT
  --scope SCOPE         Restrict to one src/ subdirectory.
  --format {text,json}
  --output OUTPUT       Optional JSON output path.
```
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from collections import Counter
from pathlib import Path

CFG_TEST_RE = re.compile(r"^\s*#\[cfg\(test\)\]\s*$")
MOD_TESTS_RE = re.compile(r"^\s*(?:pub\s+)?mod\s+(tests?|test)\b")
TEST_ATTR_RE = re.compile(r"^\s*#\[(?:tokio::)?test\b")


def find_block_end(lines: list[str], start: int) -> int:
    """Return index of the closing `}` line for a `mod tests { ... }` that
    opens on or after ``start``. If no opening brace is found, return start."""
    depth = 0
    opened = False
    for i in range(start, len(lines)):
        for ch in lines[i]:
            if ch == "{":
                depth += 1
                opened = True
            elif ch == "}":
                depth -= 1
                if opened and depth == 0:
                    return i
    return len(lines) - 1


def scan_file(path: Path) -> list[dict]:
    """Find every inline `#[cfg(test)]` block in one file."""
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return []
    lines = text.splitlines()
    hits: list[dict] = []
    i = 0
    while i < len(lines):
        if CFG_TEST_RE.match(lines[i]):
            attr_line = i + 1  # 1-based
            # Look ahead for `mod tests` (or similar) within the next few lines
            j = i + 1
            while j < len(lines) and j < i + 5 and not MOD_TESTS_RE.match(lines[j]):
                # Allow intervening attributes / doc comments
                if lines[j].strip() and not lines[j].lstrip().startswith(("#[", "//", "///", "//!")):
                    break
                j += 1
            if j < len(lines) and MOD_TESTS_RE.match(lines[j]):
                end = find_block_end(lines, j)
                body = lines[j : end + 1]
                test_count = sum(1 for ln in body if TEST_ATTR_RE.match(ln))
                hits.append(
                    {
                        "line": attr_line,
                        "mod_line": j + 1,
                        "end_line": end + 1,
                        "test_count": test_count,
                    }
                )
                i = end + 1
                continue
            else:
                # `#[cfg(test)]` on something other than a mod (e.g. a fn or use).
                # Still record it but with test_count = 1 if the next non-attr
                # line is a `#[test]`, else 0.
                test_count = 0
                k = i + 1
                while k < len(lines) and lines[k].lstrip().startswith("#["):
                    if TEST_ATTR_RE.match(lines[k]):
                        test_count = 1
                    k += 1
                hits.append(
                    {
                        "line": attr_line,
                        "mod_line": None,
                        "end_line": None,
                        "test_count": test_count,
                    }
                )
                i += 1
                continue
        i += 1
    return hits


def classify(path: Path, src_root: Path) -> tuple[str, list[str]]:
    """Return (module, [suggested_targets])."""
    try:
        rel = path.relative_to(src_root)
    except ValueError:
        return ("", [])
    parts = rel.parts
    if len(parts) == 0:
        return ("", [])
    # Top-level module = first directory under src/, or the file stem if at root.
    if len(parts) == 1:
        module = path.stem
    else:
        module = parts[0]
    # Strip lua_api special case: a file src/lua_api/foo_api.rs should
    # suggest tests/lua/unit/test_foo.lua as a lua candidate.
    targets: list[str] = []
    if module == "lua_api" and path.stem.endswith("_api"):
        base = path.stem[: -len("_api")]
        targets.append(f"tests/rust/unit/{base}_tests.rs")
        targets.append(f"tests/lua/unit/test_{base}.lua")
    else:
        targets.append(f"tests/rust/unit/{module}_tests.rs")
        lua_api_file = src_root / "lua_api" / f"{module}_api.rs"
        if lua_api_file.is_file():
            targets.append(f"tests/lua/unit/test_{module}.lua")
    return (module, targets)


def run(root: Path, scope: str | None) -> dict:
    src_root = root / "src"
    if scope:
        walk_root = src_root / scope
        if not walk_root.exists():
            walk_root = src_root  # fall back silently
    else:
        walk_root = src_root
    findings: list[dict] = []
    for rs in sorted(walk_root.rglob("*.rs")):
        hits = scan_file(rs)
        if not hits:
            continue
        module, targets = classify(rs, src_root)
        for h in hits:
            entry = {
                "file": rs.relative_to(root).as_posix(),
                "line": h["line"],
                "mod_line": h["mod_line"],
                "end_line": h["end_line"],
                "test_count": h["test_count"],
                "module": module,
                "suggested_target": targets[0] if targets else "",
            }
            if len(targets) > 1:
                entry["lua_candidate"] = targets[1]
            findings.append(entry)
    total_blocks = len(findings)
    total_tests = sum(f["test_count"] for f in findings)
    per_module = Counter(f["module"] for f in findings)
    per_file = Counter()
    for f in findings:
        per_file[f["file"]] += f["test_count"]
    return {
        "total_blocks": total_blocks,
        "total_tests": total_tests,
        "per_module": dict(per_module.most_common()),
        "top_files_by_tests": per_file.most_common(10),
        "findings": findings,
    }


def format_text(report: dict) -> str:
    lines: list[str] = []
    lines.append("# Inline `#[cfg(test)]` audit (TST-02)")
    lines.append("")
    lines.append(f"Total blocks: {report['total_blocks']}")
    lines.append(f"Total `#[test]` fns: {report['total_tests']}")
    lines.append("")
    if report["per_module"]:
        lines.append("## Blocks per module")
        for mod, n in report["per_module"].items():
            lines.append(f"  {mod:30s} {n:5d}")
        lines.append("")
    if report["top_files_by_tests"]:
        lines.append("## Top 10 files by `#[test]` count")
        for path, n in report["top_files_by_tests"]:
            lines.append(f"  {n:5d}  {path}")
        lines.append("")
    return "\n".join(lines)


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0] if __doc__ else "")
    ap.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[2])
    ap.add_argument("--scope", default=None, help="Restrict to one src/ subdirectory.")
    ap.add_argument("--format", choices=["text", "json"], default="text")
    ap.add_argument("--output", type=Path, default=None, help="Optional JSON output path.")
    args = ap.parse_args(argv)

    report = run(args.root.resolve(), args.scope)

    if args.format == "json":
        print(json.dumps(report, indent=2, sort_keys=True))
    else:
        print(format_text(report))

    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(json.dumps(report, indent=2, sort_keys=True), encoding="utf-8")

    return 1 if report["total_blocks"] > 0 else 0


if __name__ == "__main__":
    sys.exit(main())
