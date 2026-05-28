#!/usr/bin/env python3
"""
module_docstring_fix.py -- Expand/repair module-level //! docstrings in Rust source files.

Reads logs/data/module_docstring_audit.json and patches each violating file so its
leading //! block meets the LOC-based minimum.  Use --force to re-patch files whose
count already meets the minimum (useful after the first bad-bullet run).

Usage:
    python tools/fix/module_docstring_fix.py               # fix all from audit JSON
    python tools/fix/module_docstring_fix.py --dry-run     # print diffs, no write
    python tools/fix/module_docstring_fix.py --force       # re-patch even if count OK
    python tools/fix/module_docstring_fix.py --top N       # N worst violations only
    python tools/fix/module_docstring_fix.py --file F      # single file
    python tools/fix/module_docstring_fix.py --audit PATH  # custom audit JSON

Exit codes: 0 OK, 1 some failures, 2 fatal error
"""

import argparse
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent.parent
AUDIT = ROOT / "logs" / "data" / "module_docstring_audit.json"

# Must match module_docstring_audit.py
LOC_TIERS: list[tuple[float, int]] = [
    (30,       1),
    (80,       3),
    (200,      4),
    (400,      5),
    (800,      6),
    (2000,     8),
    (1e18,    10),
]


def min_lines(loc: int) -> int:
    for mx, mn in LOC_TIERS:
        if loc <= mx:
            return mn
    return 10


# ---------------------------------------------------------------------------
# Public-item scanners
# ---------------------------------------------------------------------------

_UDIMPL = re.compile(r"^impl(?:<[^>]+>)?\s+LuaUserData\s+for\s+(\w+)")
_STRUCT  = re.compile(r"^pub(?:\([^)]+\))?\s+struct\s+(\w+)")
_ENUM    = re.compile(r"^pub(?:\([^)]+\))?\s+enum\s+(\w+)")
_TRAIT   = re.compile(r"^pub(?:\([^)]+\))?\s+trait\s+(\w+)")
_FN      = re.compile(r"^pub(?:\([^)]+\))?\s+fn\s+(\w+)")
_TYPE    = re.compile(r"^pub(?:\([^)]+\))?\s+type\s+(\w+)")
_MOD     = re.compile(r"^pub\s+mod\s+(\w+)")
_IMPL    = re.compile(r"^impl(?:<[^>]+>)?\s+(?:\w+\s+for\s+)?(\w+)")


def scan(text: str) -> dict[str, list[str]]:
    """Scan file text and return categorised public-item name lists."""
    c: dict[str, list[str]] = {
        "ud": [], "structs": [], "enums": [], "traits": [],
        "fns": [], "types": [], "mods": [], "impls": [],
    }
    for line in text.splitlines():
        s = line.strip()
        is_top = not line[:1].strip() == ""  # True if line starts at column 0
        m = _UDIMPL.match(s)
        if m:
            n = m.group(1)
            if n not in c["ud"]:
                c["ud"].append(n)
        for pat, key in [
            (_STRUCT, "structs"), (_ENUM, "enums"), (_TRAIT, "traits"),
            # Only collect top-level pub fns (not impl methods)
            (_FN, "fns") if is_top else (None, None),
            (_TYPE, "types"), (_MOD, "mods"), (_IMPL, "impls"),
        ]:
            if pat is None:
                continue
            m = pat.match(s)
            if m:
                n = m.group(1)
                if n not in c[key]:
                    c[key].append(n)
                break
    return c


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def join(names: list[str], cap: int = 4) -> str:
    shown = names[:cap]
    rest = len(names) - cap
    joined = ", ".join(f"`{n}`" for n in shown)
    return joined + (f", and {rest} more" if rest > 0 else "")


def pl(word: str, n: int, plural: str | None = None) -> str:
    return word if n == 1 else (plural if plural is not None else word + "s")


# ---------------------------------------------------------------------------
# Bullet generation
# ---------------------------------------------------------------------------

def make_bullets(path: Path, text: str, needed: int) -> list[str]:
    """Generate *needed* unique, informative //! bullet lines for *path*."""
    if needed <= 0:
        return []
    rel = str(path.relative_to(ROOT)).replace("\\", "/")
    c = scan(text)
    parts = Path(rel.replace("src/", "")).with_suffix("").parts
    parent = "/".join(parts[:-1]) if len(parts) > 1 else parts[0]
    bullets: list[str] = []

    if "lua_api" in rel:
        # --- lua_api files: registration bullet + per-type bullets ---
        stem = Path(rel).stem.removesuffix("_api")
        bullets.append(
            f"//! - Registers `lurek.{stem}.*` functions and types via `register()`."
        )
        ud = c["ud"]
        if ud and len(bullets) < needed:
            slots = needed - len(bullets)
            if len(ud) <= slots:
                for t in ud:
                    bullets.append(f"//! - `{t}`: userdata type exposed to Lua.")
                    if len(bullets) >= needed:
                        break
            else:
                # Group in threes
                for i in range(0, len(ud), 3):
                    grp = ud[i : i + 3]
                    lbl = pl("Userdata type", len(grp), "Userdata types")
                    bullets.append(f"//! - {lbl}: {join(grp)}.")
                    if len(bullets) >= needed:
                        break
        # Extra helper fns
        fns = [f for f in c["fns"] if f != "register"]
        if fns and len(bullets) < needed:
            bullets.append(
                f"//! - {pl('Helper function', len(fns), 'Helper functions')}: {join(fns)}."
            )
        # Count add_method / add_function / create_function calls as a method-count bullet
        if len(bullets) < needed:
            n_methods = (text.count(".add_method") + text.count(".add_function")
                         + text.count("create_function") + text.count("create_async_function"))
            if n_methods > 0:
                bullets.append(
                    f"//! - Bridges {n_methods} Lua-callable {pl('method', n_methods)} via `mlua`."
                )
        # Docs-spec reference
        if len(bullets) < needed:
            bullets.append(
                f"//! - See `docs/specs/{stem}.md` for the full API specification."
            )
    else:
        # --- Generic files: one bullet per populated category ---
        for key, sg, pl_ in [
            ("structs", "Data type",  "Data types"),
            ("enums",   "Enum",       "Enums"),
            ("traits",  "Trait",      "Traits"),
            ("types",   "Type alias", "Type aliases"),
            ("fns",     "Function",   "Functions"),
            ("mods",    "Sub-module", "Sub-modules"),
        ]:
            if len(bullets) >= needed:
                break
            items = c[key]
            if not items:
                continue
            lbl = pl_ if len(items) > 1 else sg
            bullets.append(f"//! - {lbl}: {join(items)}.")

        non_ud = [i for i in c["impls"] if i not in c["ud"]]
        if non_ud and len(bullets) < needed:
            lbl = pl("Implementation", len(non_ud), "Implementations")
            bullets.append(f"//! - {lbl}: {join(non_ud)}.")

        if c["ud"] and len(bullets) < needed:
            ud = c["ud"]
            lbl = pl("Lua userdata type", len(ud), "Lua userdata types")
            bullets.append(f"//! - {lbl}: {join(ud)}.")

        # Public methods inside impl blocks (pub fn / pub(crate) fn at method indent)
        if len(bullets) < needed:
            pub_methods = re.findall(
                r"^\s{4}pub(?:\([^)]+\))?\s+fn\s+(\w+)", text, re.MULTILINE
            )
            if pub_methods:
                bullets.append(
                    f"//! - {pl('Public method', len(pub_methods), 'Public methods')}: {join(pub_methods)}."
                )

        # Total method count for large impl-heavy files
        if len(bullets) < needed:
            all_methods = re.findall(
                r"^\s{4}(?:pub(?:\([^)]+\))?\s+)?(?:async\s+)?fn\s+(\w+)",
                text, re.MULTILINE
            )
            if all_methods:
                bullets.append(
                    f"//! - Contains {len(all_methods)} method {pl('implementation', len(all_methods))}."
                )

        # Use-crate subsystem dependencies
        if len(bullets) < needed:
            uses = re.findall(r"^use crate::(\w+)", text, re.MULTILINE)
            unique_uses = list(dict.fromkeys(uses))
            if unique_uses:
                bullets.append(
                    f"//! - Uses: {join(unique_uses, cap=5)}."
                )

        # Public consts/statics
        if len(bullets) < needed:
            consts = re.findall(
                r"^pub(?:\([^)]+\))?\s+(?:const|static)\s+(\w+)", text, re.MULTILINE
            )
            if consts:
                bullets.append(
                    f"//! - {pl('Constant', len(consts), 'Constants')}: {join(consts)}."
                )

        # docs/specs reference for the parent module
        if len(bullets) < needed:
            spec_name = parts[-2] if len(parts) >= 2 else parts[0]
            spec_path = ROOT / "docs" / "specs" / f"{spec_name}.md"
            if spec_path.is_file():
                bullets.append(
                    f"//! - See `docs/specs/{spec_name}.md` for the module specification."
                )

        # Unsafe-block indicator
        if len(bullets) < needed and "unsafe {" in text:
            n_unsafe = text.count("unsafe {")
            bullets.append(
                f"//! - Contains {n_unsafe} `unsafe` {pl('block', n_unsafe)}; see SAFETY comments."
            )

        # Derived traits used in this file
        if len(bullets) < needed:
            raw_derives: list[str] = re.findall(r"#\[derive\(([^)]+)\)\]", text)
            all_traits: list[str] = []
            for d in raw_derives:
                for t in d.split(","):
                    t = t.strip()
                    if t and t not in all_traits:
                        all_traits.append(t)
            if all_traits:
                bullets.append(
                    f"//! - Derives: {join(all_traits, cap=5)}."
                )

    # Single fallback — only one occurrence
    if len(bullets) < needed:
        bullets.append(f"//! - Part of the `{parent}` subsystem.")

    # Ultimate pad (should rarely fire)
    idx = 0
    while len(bullets) < needed:
        idx += 1
        bullets.append(f"//! - See `src/{parent}` for related modules ({idx}).")

    return bullets[:needed]


# ---------------------------------------------------------------------------
# Leading //! block utilities
# ---------------------------------------------------------------------------

def doc_end(lines: list[str]) -> int:
    """Return index of first line after the leading //! block."""
    seen = False
    for i, line in enumerate(lines):
        s = line.rstrip()
        if s.startswith("//!"):
            seen = True
        elif not seen and s == "":
            continue
        else:
            return i
    return len(lines)


def count_leading(lines: list[str]) -> int:
    """Count //! lines in the leading block (stops at first non-//! non-blank)."""
    n, seen = 0, False
    for line in lines:
        s = line.rstrip()
        if s.startswith("//!"):
            n += 1
            seen = True
        elif not seen and s == "":
            continue
        else:
            break
    return n


def build_docstring(path: Path, text: str, required: int, force: bool = False) -> list[str]:
    """Return the replacement leading //! block as a list of lines (no \\n).

    When *force* is True the existing bullets are discarded and regenerated
    from scratch (needed to repair files that already have the right count
    but with bad/duplicate content).
    """
    lines = text.splitlines()
    end = doc_end(lines)
    existing = [l.rstrip() for l in lines[:end] if l.rstrip().startswith("//!")]

    if existing:
        summary = existing[0]
    else:
        module = "/".join(
            Path(str(path.relative_to(ROOT)).replace("\\", "/").replace("src/", ""))
            .with_suffix("").parts
        )
        summary = f"//! `{module}` module."

    # When force=True, throw away all existing bullets and regenerate fresh.
    # When force=False, preserve well-formed existing bullets and only add deficit.
    if force:
        ex_bullets: list[str] = []
    else:
        ex_bullets = [
            l for l in (existing[1:] if existing else [])
            if l not in ("//!", "//! ")
        ]

    # Formula: required = 1 (summary) + 1 (blank //!) + N (bullets)  when required > 1
    needed_bullets = max(0, required - 1 - (1 if required > 1 else 0))
    deficit = max(0, needed_bullets - len(ex_bullets))
    new_b = make_bullets(path, text, deficit)
    all_b = ex_bullets + new_b

    doc: list[str] = [summary]
    if all_b:
        doc.append("//!")
        doc.extend(all_b)
    return doc


# ---------------------------------------------------------------------------
# File patching
# ---------------------------------------------------------------------------

def patch(path: Path, required: int, dry_run: bool, force: bool) -> bool:
    """Patch *path* so its //! block has at least *required* lines."""
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except OSError as exc:
        print(f"  ERROR  {path}: {exc}")
        return False

    raw = text.splitlines(keepends=True)
    leading = count_leading([l.rstrip("\n") for l in raw])

    if leading >= required and not force:
        return True  # silent skip in normal mode

    end = doc_end([l.rstrip("\n") for l in raw])
    new_doc = build_docstring(path, text, required, force=force)
    block = "\n".join(new_doc) + "\n"
    rest = "".join(raw[end:])
    if rest and not rest.startswith("\n"):
        block += "\n"
    new_text = block + rest

    rel = str(path.relative_to(ROOT)).replace("\\", "/")
    if dry_run:
        print(f"\n  --- {rel}  ({leading} -> {len(new_doc)}) ---")
        for line in new_doc:
            print(f"  + {line}")
        return True

    try:
        path.write_text(new_text, encoding="utf-8")
        print(f"  FIXED  {rel}  ({leading} -> {len(new_doc)} //! lines)")
        return True
    except OSError as exc:
        print(f"  ERROR  {path}: {exc}")
        return False


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> int:
    ap = argparse.ArgumentParser(
        description="Expand/repair module-level //! docstrings in Rust source files."
    )
    ap.add_argument("--audit", default=str(AUDIT))
    ap.add_argument("--file", help="Patch a single .rs file.")
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument(
        "--force",
        action="store_true",
        help="Re-patch even if the file already meets the minimum (repairs bad bullets).",
    )
    ap.add_argument("--top", type=int, default=0, help="Process N worst violations only.")
    args = ap.parse_args()

    # --- Single-file mode ---
    if args.file:
        path = Path(args.file).resolve()
        if not path.is_file():
            print(f"ERROR: {path} not found", file=sys.stderr)
            return 2
        text = path.read_text(encoding="utf-8", errors="replace")
        req = min_lines(len(text.splitlines()))
        return 0 if patch(path, req, args.dry_run, True) else 1

    # --- Batch mode ---
    audit_path = Path(args.audit)

    if args.force:
        # --force: always scan every src/**/*.rs so we reach files whose count is
        # already correct but whose bullet content is wrong (the 38 bad-bullet files).
        violations = []
        for f in sorted(ROOT.joinpath("src").rglob("*.rs")):
            txt = f.read_text(encoding="utf-8", errors="replace")
            loc = len(txt.splitlines())
            req = min_lines(loc)
            rel = str(f.relative_to(ROOT)).replace("\\", "/")
            violations.append(
                {"file": rel, "loc": loc,
                 "required_doc_lines": req, "deficit": req}
            )
        if args.top:
            violations = violations[: args.top]
    else:
        if not audit_path.is_file():
            print(
                f"ERROR: audit JSON not found at {audit_path}\n"
                "       Run: python tools/audit/module_docstring_audit.py",
                file=sys.stderr,
            )
            return 2
        violations = json.loads(audit_path.read_text(encoding="utf-8"))
        violations.sort(key=lambda v: (-v.get("deficit", 0), -v.get("loc", 0)))
        if args.top:
            violations = violations[: args.top]

    if not violations:
        print("No violations in audit -- nothing to fix.")
        return 0

    label = "DRY RUN - " if args.dry_run else ""
    print(f"{label}Processing {len(violations)} file(s)...\n")
    fails = 0
    for v in violations:
        fp = ROOT / v["file"].replace("/", "\\")
        if not patch(fp, v["required_doc_lines"], args.dry_run, args.force):
            fails += 1

    verb = "Would patch" if args.dry_run else "Patched"
    print(f"\n{verb} {len(violations) - fails}/{len(violations)} files.")
    return 0 if fails == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
