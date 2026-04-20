#!/usr/bin/env python3
"""thin_wrapper_audit.py — Enforce TST-03 (thin wrappers in src/lua_api/).

Walks ``src/lua_api/*_api.rs`` and heuristically scores each file for
"business logic" that should live in the domain module under ``src/<module>/``
instead. The classifier flags:

* Long free functions (> 40 non-trivial lines) that are NOT registration
  helpers.
* Loop / iterator / numeric-op hotspots outside of Lua closures.
* `std::collections::*` imports (HashMap, BTreeMap, HashSet, VecDeque).

Exit code: 0 if no VIOLATION, 1 otherwise.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

FN_TOP_RE = re.compile(r"^(?:pub(?:\([^)]*\))?\s+)?(?:async\s+)?fn\s+([A-Za-z_][A-Za-z0-9_]*)\s*[<(]")
IMPL_RE = re.compile(r"^\s*impl\b")
STDCOLL_RE = re.compile(r"^\s*use\s+std::collections::")
HOTSPOT_RES = [
    re.compile(r"\bfor\s"),
    re.compile(r"\bwhile\s"),
    re.compile(r"\bloop\s*\{"),
    re.compile(r"\.iter\(\)"),
    re.compile(r"\.map\("),
    re.compile(r"\.fold\("),
    re.compile(r"\.reduce\("),
    re.compile(r"[+\-*/]="),
]
REG_HINTS = (".set(", "lua.create_function", "add_method", "add_function", "add_meta_method")


def non_trivial(line: str) -> bool:
    s = line.strip()
    if not s:
        return False
    if s.startswith(("//", "///", "//!", "/*", "*")):
        return False
    if s.startswith("#["):
        return False
    return True


def brace_track(line: str, depth: int) -> int:
    # crude — counts braces outside of strings/comments. Good enough for
    # our heuristic use.
    in_str = False
    in_char = False
    escape = False
    i = 0
    while i < len(line):
        c = line[i]
        if escape:
            escape = False
            i += 1
            continue
        if c == "\\":
            escape = True
            i += 1
            continue
        if in_str:
            if c == '"':
                in_str = False
        elif in_char:
            if c == "'":
                in_char = False
        else:
            if c == '"':
                in_str = True
            elif c == "//":
                break
            elif c == "{":
                depth += 1
            elif c == "}":
                depth -= 1
        i += 1
    return depth


def scan_file(path: Path) -> dict:
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return {}
    lines = text.splitlines()
    total_lines = len(lines)

    # Walk top-level (brace depth == 0) looking for free `fn` declarations.
    # Skip content inside `impl` blocks. We approximate "top level" via brace
    # depth tracking.
    depth = 0
    in_impl_at = []  # stack of depths where an impl started
    free_fns: list[dict] = []
    i = 0
    while i < total_lines:
        line = lines[i]
        stripped = line.lstrip()
        # Detect impl entry at current depth 0 (or inside mod).
        if IMPL_RE.match(line):
            # track until matching close
            new_depth = brace_track(line, depth)
            in_impl_at.append(depth)
            depth = new_depth
            i += 1
            continue
        # top-level free fn candidate
        if depth == len(in_impl_at) * 0 + 0 and FN_TOP_RE.match(stripped) and not in_impl_at:
            # find body: advance until we see `{`, then brace-track to close
            body_start = i
            # scan for opening brace (could be same or later line for multi-line sig)
            k = i
            found_open = False
            d2 = 0
            while k < total_lines:
                if "{" in lines[k]:
                    d2 = brace_track(lines[k], 0)
                    found_open = True
                    break
                if ";" in lines[k]:
                    break  # it's a trait decl or forward; bail
                k += 1
            if not found_open:
                i += 1
                continue
            # Now walk until d2 returns to 0
            body_end = k
            while d2 > 0 and body_end + 1 < total_lines:
                body_end += 1
                d2 = brace_track(lines[body_end], d2)
            body = lines[body_start : body_end + 1]
            body_nontrivial = sum(1 for ln in body if non_trivial(ln))
            body_text = "\n".join(body)
            is_registration = any(hint in body_text for hint in REG_HINTS)
            free_fns.append(
                {
                    "name": FN_TOP_RE.match(stripped).group(1),
                    "start": body_start + 1,
                    "end": body_end + 1,
                    "body_lines": body_nontrivial,
                    "registration": is_registration,
                }
            )
            # Advance
            depth = brace_track(lines[body_end], depth) if body_end == k else depth
            i = body_end + 1
            continue
        # Generic brace tracking
        depth = brace_track(line, depth)
        # Pop impl stack if we've closed its outer scope
        while in_impl_at and depth <= in_impl_at[-1]:
            in_impl_at.pop()
        i += 1

    long_fns = [f for f in free_fns if f["body_lines"] > 40 and not f["registration"]]

    # Count hotspots outside of `add_method`/`add_function`/`create_function` closures.
    # Heuristic: count hotspots in lines NOT between a line containing
    # `add_method`/`add_function`/`create_function` and its matching closure end.
    # Simpler: count hotspots in the whole file, minus those inside any
    # closure block started by `|...|` right after one of those helpers.
    # Much simpler: mark each line as "inside closure" based on a running
    # depth counter that increments on helper-closure openers.
    closure_depth = 0
    hotspot_count = 0
    closure_opener_re = re.compile(
        r"(?:add_method|add_method_mut|add_function|add_function_mut|add_meta_method|create_function|create_function_mut)\b"
    )
    for ln in lines:
        if closure_depth > 0:
            # Track open/close of the closure block
            before = closure_depth
            closure_depth = brace_track(ln, closure_depth)
            if closure_depth <= 0:
                closure_depth = 0
            continue
        # Not currently inside a helper closure: count hotspots
        for rx in HOTSPOT_RES:
            if rx.search(ln):
                hotspot_count += 1
        # If this line opens a helper closure, start tracking
        if closure_opener_re.search(ln) and "{" in ln:
            d = brace_track(ln, 0)
            if d > 0:
                closure_depth = d

    stdcoll_imports = sum(1 for ln in lines if STDCOLL_RE.match(ln))

    score = 0
    if long_fns:
        score += 2
    if hotspot_count >= 5:
        score += 2
    if stdcoll_imports >= 2:
        score += 1

    if score >= 3:
        verdict = "VIOLATION"
    elif score >= 1:
        verdict = "SUSPECT"
    else:
        verdict = "CLEAN"

    return {
        "lines": total_lines,
        "free_fn_count": len(free_fns),
        "long_fn_count": len(long_fns),
        "loop_hotspot_count": hotspot_count,
        "stdcoll_import_count": stdcoll_imports,
        "long_fns": [{"name": f["name"], "line": f["start"], "body_lines": f["body_lines"]} for f in long_fns],
        "score": score,
        "verdict": verdict,
    }


def run(root: Path, scope: str | None) -> dict:
    lua_api_dir = root / "src" / "lua_api"
    files: list[Path] = []
    if scope:
        candidate = lua_api_dir / f"{scope}_api.rs"
        if candidate.is_file():
            files = [candidate]
    if not files:
        files = sorted(p for p in lua_api_dir.glob("*_api.rs") if p.is_file())

    per_file: list[dict] = []
    for p in files:
        data = scan_file(p)
        if not data:
            continue
        data["file"] = p.relative_to(root).as_posix()
        per_file.append(data)

    violations = [f for f in per_file if f["verdict"] == "VIOLATION"]
    suspects = [f for f in per_file if f["verdict"] == "SUSPECT"]
    return {
        "total_files": len(per_file),
        "violation_count": len(violations),
        "suspect_count": len(suspects),
        "clean_count": len(per_file) - len(violations) - len(suspects),
        "files": sorted(per_file, key=lambda f: (-f["score"], f["file"])),
    }


def format_text(report: dict) -> str:
    out: list[str] = []
    out.append("# lua_api thin-wrapper audit (TST-03)")
    out.append("")
    out.append(f"Files scanned : {report['total_files']}")
    out.append(f"CLEAN         : {report['clean_count']}")
    out.append(f"SUSPECT       : {report['suspect_count']}")
    out.append(f"VIOLATION     : {report['violation_count']}")
    out.append("")
    violations = [f for f in report["files"] if f["verdict"] == "VIOLATION"][:10]
    suspects = [f for f in report["files"] if f["verdict"] == "SUSPECT"][:10]
    if violations:
        out.append("## Top 10 VIOLATION")
        for f in violations:
            out.append(
                f"  score={f['score']}  long={f['long_fn_count']}  hotspots={f['loop_hotspot_count']}  "
                f"stdcoll={f['stdcoll_import_count']}  {f['file']}"
            )
        out.append("")
    if suspects:
        out.append("## Top 10 SUSPECT")
        for f in suspects:
            out.append(
                f"  score={f['score']}  long={f['long_fn_count']}  hotspots={f['loop_hotspot_count']}  "
                f"stdcoll={f['stdcoll_import_count']}  {f['file']}"
            )
        out.append("")
    return "\n".join(out)


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0] if __doc__ else "")
    ap.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[2])
    ap.add_argument("--scope", default=None, help="Restrict to one lua_api/<scope>_api.rs file.")
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
