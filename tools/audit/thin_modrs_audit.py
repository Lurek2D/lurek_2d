#!/usr/bin/env python3
"""thin_modrs_audit.py — Enforce TST-04 (thin `mod.rs`).

Walks ``src/**/mod.rs`` (excluding ``src/lib.rs``) and flags any file that
contains definitions (``fn``, ``struct``, ``enum``, ``impl``, ``trait``,
``const``, ``static``, ``type``) or more than 5 "other" non-trivial lines
that are not allowed: ``mod`` declarations, ``use`` imports, attributes,
doc comments, or blank lines.

Exit code: 0 if no VIOLATION, 1 otherwise.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

DEF_KEYWORDS = (
    "fn ",
    "struct ",
    "enum ",
    "impl ",
    "impl<",
    "trait ",
    "const ",
    "static ",
    "type ",
)

ALLOWED_PREFIXES = (
    "pub mod ",
    "mod ",
    "pub use ",
    "use ",
    "pub(crate) use ",
    "pub(super) use ",
    "pub(crate) mod ",
    "pub(super) mod ",
    "extern crate ",
)

DEF_RE = re.compile(r"^\s*(?:pub(?:\([^)]*\))?\s+)?(?:async\s+)?(?:unsafe\s+)?(fn|struct|enum|impl|trait|const|static|type)\b")


def classify_line(line: str) -> str:
    """Return one of: blank, comment, attr, mod, use, definition, other."""
    raw = line.rstrip("\n")
    s = raw.strip()
    if not s:
        return "blank"
    if s.startswith(("//", "///", "//!")):
        return "comment"
    if s.startswith("/*") or s.endswith("*/") or s.startswith("*"):
        return "comment"
    if s.startswith("#![") or s.startswith("#["):
        return "attr"
    if DEF_RE.match(raw):
        return "definition"
    # Check allowed prefixes (match on stripped line)
    for pref in ALLOWED_PREFIXES:
        if s.startswith(pref):
            if "mod " in pref:
                return "mod"
            return "use"
    # Check any "fn/struct/..." keyword appearing in a continuation
    for kw in DEF_KEYWORDS:
        if kw in s:
            return "definition"
    return "other"


def scan_file(path: Path) -> dict:
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return {}
    lines = text.splitlines()
    counts = {"blank": 0, "comment": 0, "attr": 0, "mod": 0, "use": 0, "definition": 0, "other": 0}
    def_samples: list[dict] = []
    other_samples: list[dict] = []
    for idx, ln in enumerate(lines, 1):
        kind = classify_line(ln)
        counts[kind] += 1
        if kind == "definition" and len(def_samples) < 10:
            def_samples.append({"line": idx, "text": ln.strip()[:160]})
        elif kind == "other" and len(other_samples) < 10:
            other_samples.append({"line": idx, "text": ln.strip()[:160]})

    verdict = "CLEAN"
    if counts["definition"] > 0 or counts["other"] > 5:
        verdict = "VIOLATION"

    return {
        "lines": len(lines),
        "definition_lines": counts["definition"],
        "other_lines": counts["other"],
        "mod_lines": counts["mod"],
        "use_lines": counts["use"],
        "attr_lines": counts["attr"],
        "comment_lines": counts["comment"],
        "blank_lines": counts["blank"],
        "definition_samples": def_samples,
        "other_samples": other_samples,
        "verdict": verdict,
    }


def run(root: Path, scope: str | None) -> dict:
    src_root = root / "src"
    walk_root = src_root / scope if scope else src_root
    if not walk_root.exists():
        walk_root = src_root
    files: list[Path] = []
    for p in walk_root.rglob("mod.rs"):
        if p.name == "mod.rs":
            files.append(p)
    files.sort()

    per_file: list[dict] = []
    for p in files:
        data = scan_file(p)
        if not data:
            continue
        data["file"] = p.relative_to(root).as_posix()
        per_file.append(data)

    violations = [f for f in per_file if f["verdict"] == "VIOLATION"]
    return {
        "total_files": len(per_file),
        "violation_count": len(violations),
        "clean_count": len(per_file) - len(violations),
        "files": sorted(per_file, key=lambda f: (f["verdict"] != "VIOLATION", -f["lines"], f["file"])),
    }


def format_text(report: dict) -> str:
    out: list[str] = []
    out.append("# mod.rs thin-module audit (TST-04)")
    out.append("")
    out.append(f"Files scanned : {report['total_files']}")
    out.append(f"CLEAN         : {report['clean_count']}")
    out.append(f"VIOLATION     : {report['violation_count']}")
    out.append("")
    violations = [f for f in report["files"] if f["verdict"] == "VIOLATION"][:10]
    if violations:
        out.append("## Top 10 VIOLATION (by lines)")
        for f in violations:
            out.append(
                f"  lines={f['lines']:4d}  def={f['definition_lines']:3d}  other={f['other_lines']:3d}  {f['file']}"
            )
        out.append("")
    return "\n".join(out)


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

    return 1 if report["violation_count"] > 0 else 0


if __name__ == "__main__":
    sys.exit(main())
