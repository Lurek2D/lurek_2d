#!/usr/bin/env python3
"""gen_rust_docstrings.py — AI-assisted Rust doc-comment generator for src/ (excluding lua_api/).

Scans every .rs file under src/ and:
  • Adds a //! module-level architecture block (300–1200 chars) when absent.
  • Adds a /// one-liner above every undocumented item:
      struct, enum, enum variant, fn, trait, type alias, const, static,
      impl block, union, macro_rules!, and mod declarations.

Both kinds of comment must be concrete and relevant — the LLM receives the
full file source as context so it can write accurate descriptions.

Requirements:
    pip install anthropic

Usage:
    python tools/docs/gen_rust_docstrings.py                      # all files
    python tools/docs/gen_rust_docstrings.py --dry-run            # count only, no writes
    python tools/docs/gen_rust_docstrings.py --file src/ai/fsm.rs # single file
    python tools/docs/gen_rust_docstrings.py --overwrite          # also redo existing docs
    python tools/docs/gen_rust_docstrings.py --model claude-opus-4-5
    ANTHROPIC_API_KEY=sk-... python tools/docs/gen_rust_docstrings.py
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Iterator

try:
    import anthropic
except ImportError:
    sys.exit(
        "ERROR: anthropic package is not installed.\n"
        "Run:  pip install anthropic"
    )

# ── Project paths ──────────────────────────────────────────────────────────────

ROOT   = Path(__file__).resolve().parents[2]   # …/lurek2D
SRC    = ROOT / "src"
EXCLUDE_DIRS = {"lua_api"}

# ── Rust item detection ────────────────────────────────────────────────────────

# Matches any line that opens a documentable Rust declaration.
# We intentionally keep this broad; brace-depth filtering narrows it down later.
_ITEM_RE = re.compile(
    r"""
    ^(?P<indent>[ \t]*)
    (?:pub(?:\s*\([^)]*\))?\s+)?           # optional visibility
    (?:
        (?:async\s+)?                       # async fn
        (?:unsafe\s+)?                      # unsafe fn / unsafe trait
        (?:extern\s+"[A-Za-z0-9_-]+"\s+)?  # extern "C" fn
        (?:fn|struct|enum|trait|union|type|const|static|macro_rules!)
        |
        impl(?:\s*<[^{>]*>)?               # impl<T> Foo
        |
        mod\s+[A-Za-z_]\w*\s*;             # inline module declaration (not a block)
    )
    \s*[A-Za-z_!]                          # must have identifier/macro-name next
    """,
    re.VERBOSE,
)

# Enum variants: leading uppercase word optionally followed by ,  (  or {
_VARIANT_RE = re.compile(r"^(?P<indent>[ \t]*)(?P<name>[A-Z][A-Za-z0-9_]*)(?:\s*(?:[,({\n]|$))")

# Helpers for brace counting ───────────────────────────────────────────────────

_STRING_RE      = re.compile(r'"(?:[^"\\]|\\.)*"')
_RAW_STRING_RE  = re.compile(r'r(#*)".*?"\1', re.DOTALL)
_CHAR_RE        = re.compile(r"'(?:[^'\\]|\\.)'")
_LINE_CMT_RE    = re.compile(r"//.*")


def _strip_for_counting(line: str) -> str:
    """Remove literals and line comments so brace counting is not confused."""
    line = _RAW_STRING_RE.sub('""', line)
    line = _STRING_RE.sub('""', line)
    line = _CHAR_RE.sub("''", line)
    line = _LINE_CMT_RE.sub("", line)
    return line


@dataclass
class RustItem:
    line_no:  int    # 1-based line number of the declaration
    snippet:  str    # the declaration line text (stripped)
    depth:    int    # brace depth at the START of this line
    has_doc:  bool   # True if the line above (skipping blanks) is a /// comment
    is_variant: bool # True when this is an enum variant, not a top-level item


def _preceding_has_doc(lines: list[str], item_idx: int) -> bool:
    """Return True if the nearest non-blank line above item_idx starts with ///."""
    j = item_idx - 1
    while j >= 0 and lines[j].strip() == "":
        j -= 1
    return j >= 0 and bool(re.match(r"[ \t]*///", lines[j]))


def parse_items(source: str) -> list[RustItem]:
    """
    Return all documentable items found in `source`.

    Tracks brace depth so we can distinguish module-level items (depth 0),
    methods inside impl/trait blocks (depth 1), and enum variants (depth 1
    inside an enum).  Items deeper than 1 are skipped (nested functions,
    closures, etc.).
    """
    lines = source.splitlines()
    items: list[RustItem] = []

    depth      = 0          # running brace depth
    in_block   = 0          # block-comment nesting level
    # Track what kind of block we're inside at each depth level
    # so we can detect enum variants
    block_kind: list[str] = []  # "enum", "impl", "struct", "other"

    for i, raw in enumerate(lines):
        # ── block-comment tracking ────────────────────────────────────────
        temp = raw
        if in_block > 0:
            close = temp.count("*/")
            open_ = temp.count("/*")
            in_block = max(0, in_block + open_ - close)
            if in_block > 0:
                # Update depth for any braces inside block comment lines
                s = _strip_for_counting(raw)
                depth = max(0, depth + s.count("{") - s.count("}"))
                continue
        else:
            open_ = temp.count("/*")
            if open_ > 0:
                close = temp.count("*/")
                in_block = max(0, open_ - close)

        s = _strip_for_counting(raw)
        line_depth = depth  # depth BEFORE processing this line's braces

        # Update depth for next line
        opens  = s.count("{")
        closes = s.count("}")
        depth  = max(0, depth + opens - closes)

        # ── Track block_kind stack ─────────────────────────────────────────
        if opens > closes:
            # We opened a block; record what kind
            for _ in range(opens - closes):
                if re.match(r"[ \t]*(?:pub(?:\([^)]*\))?\s+)?enum\s+", raw):
                    block_kind.append("enum")
                elif re.match(r"[ \t]*(?:pub(?:\([^)]*\))?\s+)?impl", raw):
                    block_kind.append("impl")
                elif re.match(r"[ \t]*(?:pub(?:\([^)]*\))?\s+)?struct\s+", raw):
                    block_kind.append("struct")
                else:
                    block_kind.append("other")
        elif closes > opens:
            for _ in range(closes - opens):
                if block_kind:
                    block_kind.pop()

        # ── Only document items at depth 0 or 1 ───────────────────────────
        if line_depth > 1:
            continue

        # ── Enum variants (depth 1 inside an enum block) ──────────────────
        if line_depth == 1 and block_kind and block_kind[-1] == "enum":
            m = _VARIANT_RE.match(raw)
            if m:
                has_doc = _preceding_has_doc(lines, i)
                items.append(RustItem(
                    line_no=i + 1,
                    snippet=raw.rstrip(),
                    depth=line_depth,
                    has_doc=has_doc,
                    is_variant=True,
                ))
            continue

        # ── Regular item declarations ──────────────────────────────────────
        if _ITEM_RE.match(raw):
            has_doc = _preceding_has_doc(lines, i)
            items.append(RustItem(
                line_no=i + 1,
                snippet=raw.rstrip(),
                depth=line_depth,
                has_doc=has_doc,
                is_variant=False,
            ))

    return items


def file_has_module_doc(source: str) -> bool:
    """Return True if the file already starts with a //! comment."""
    for line in source.splitlines():
        s = line.strip()
        if s.startswith("//!"):
            return True
        # Stop at the first real content that isn't an attribute or blank
        if s and not s.startswith("//") and not s.startswith("#![") and not s.startswith("#["):
            break
    return False


# ── LLM integration ───────────────────────────────────────────────────────────

_SYSTEM_PROMPT = """\
You are a senior Rust engine engineer. Write precise, accurate Rust documentation.

Output format: a single JSON object — no prose, no markdown fences, no extra keys.

Schema:
{
  "file_doc": "<string or null>",
  "items": [{"line_no": <int>, "doc": "<string>"}]
}

Rules:
- "file_doc": null when no file-level doc is needed. Otherwise: plain text,
  300-1200 characters. Describe the module's architectural role in the engine,
  the core abstractions it owns, key design decisions, and how it relates to
  other modules. No item listings, no "This module provides" filler openers.
- "items": include only items whose has_doc is false in the input.
  Each "doc" is a single line. No leading ///. Concrete and specific.
  Start directly with what the item IS or DOES — never "This struct",
  "Represents", "Helper for", or similar empty openers.
  For enum variants: describe the specific case, not just the enum name.
  For impl blocks: describe the method group or extension being added.
  Do not hallucinate. If the code reveals limited information, describe
  what is observable (e.g. field types, naming, usage patterns).
"""

_MAX_SOURCE_CHARS = 60_000   # truncate very large files before sending


def _truncate_source(source: str) -> str:
    if len(source) <= _MAX_SOURCE_CHARS:
        return source
    kept = source[:_MAX_SOURCE_CHARS]
    return kept + "\n// ... file truncated for doc generation ..."


def _call_llm(
    client: anthropic.Anthropic,
    file_rel: Path,
    source: str,
    items: list[RustItem],
    need_file_doc: bool,
    model: str,
    retries: int = 3,
) -> dict:
    """Send source + item list to Claude and return parsed JSON result."""
    pending = [
        {
            "line_no":    it.line_no,
            "snippet":    it.snippet,
            "has_doc":    it.has_doc,
            "is_variant": it.is_variant,
        }
        for it in items
        if not it.has_doc
    ]

    if not need_file_doc and not pending:
        return {"file_doc": None, "items": []}

    user_msg = (
        f"File: {file_rel}\n"
        f"Need file-level doc: {need_file_doc}\n\n"
        f"--- SOURCE ---\n{_truncate_source(source)}\n--- END SOURCE ---\n\n"
        f"Items requiring documentation (has_doc=false):\n"
        f"{json.dumps(pending, indent=2)}\n\n"
        f"Return the JSON object as specified."
    )

    for attempt in range(retries):
        try:
            resp = client.messages.create(
                model=model,
                max_tokens=8192,
                system=_SYSTEM_PROMPT,
                messages=[{"role": "user", "content": user_msg}],
            )
            text = resp.content[0].text.strip()
            # Strip markdown fences if the model wrapped the JSON
            if text.startswith("```"):
                text = re.sub(r"^```[a-z]*\n?", "", text, flags=re.MULTILINE)
                text = re.sub(r"\n?```\s*$", "", text).strip()
            return json.loads(text)
        except anthropic.RateLimitError:
            wait = 2 ** attempt * 5
            print(f"    rate-limit, retrying in {wait}s …", file=sys.stderr)
            time.sleep(wait)
        except Exception as exc:
            if attempt == retries - 1:
                raise
            print(f"    LLM attempt {attempt+1} failed: {exc}", file=sys.stderr)
            time.sleep(2)

    raise RuntimeError("LLM call failed after all retries")


# ── Apply generated docstrings ─────────────────────────────────────────────────

def _wrap_file_doc(text: str, line_width: int = 100) -> list[str]:
    """Format text as //! lines, word-wrapped at `line_width` chars."""
    out: list[str] = []
    words = text.split()
    cur = "//!"
    for word in words:
        candidate = (cur + " " + word) if cur != "//!" else ("//! " + word)
        if len(candidate) > line_width:
            out.append(cur + "\n")
            cur = "//! " + word
        else:
            cur = candidate
    if cur.strip() not in ("//!", ""):
        out.append(cur + "\n")
    out.append("\n")
    return out


def apply_docstrings(source: str, result: dict) -> str:
    """
    Insert the docstrings returned by the LLM into `source`.

    Insertions are applied in reverse line-number order so earlier
    line numbers stay valid as we add lines.
    """
    lines = source.splitlines(keepends=True)

    # Build line_no → doc mapping (only items that actually got a doc)
    doc_map: dict[int, str] = {}
    for entry in result.get("items") or []:
        ln = int(entry["line_no"])
        doc_str = entry.get("doc", "").strip()
        if doc_str:
            doc_map[ln] = doc_str

    # Insert /// lines in reverse order
    for ln in sorted(doc_map, reverse=True):
        idx = ln - 1  # convert to 0-based
        if idx < 0 or idx >= len(lines):
            continue
        indent = re.match(r"^([ \t]*)", lines[idx]).group(1)
        doc_line = f"{indent}/// {doc_map[ln]}\n"
        lines.insert(idx, doc_line)

    # Prepend //! file-level doc block
    file_doc = (result.get("file_doc") or "").strip()
    if file_doc:
        doc_block = _wrap_file_doc(file_doc)
        # Insert after any leading #![…] inner attributes
        insert_at = 0
        for k, ln in enumerate(lines):
            stripped = ln.lstrip()
            if stripped.startswith("#!["):
                insert_at = k + 1
            elif stripped == "\n" and insert_at == k:
                insert_at = k + 1
            elif stripped == "" and insert_at == k:
                insert_at = k + 1
            else:
                break
        lines = lines[:insert_at] + doc_block + lines[insert_at:]

    return "".join(lines)


# ── File iterator ──────────────────────────────────────────────────────────────

def iter_rust_files(src: Path, exclude: set[str]) -> Iterator[Path]:
    for p in sorted(src.rglob("*.rs")):
        parts = p.relative_to(src).parts
        if not any(part in exclude for part in parts):
            yield p


# ── Process one file ───────────────────────────────────────────────────────────

def process_file(
    client: anthropic.Anthropic,
    path: Path,
    *,
    dry_run:   bool,
    overwrite: bool,
    model:     str,
) -> bool:
    """Process a single Rust file. Returns True if the file was (or would be) modified."""
    source = path.read_text(encoding="utf-8")
    items  = parse_items(source)

    need_file_doc  = overwrite or not file_has_module_doc(source)
    undoc_items    = [it for it in items if not it.has_doc]

    if not need_file_doc and not undoc_items:
        print(f"  skip   {path.relative_to(ROOT)}")
        return False

    rel = path.relative_to(ROOT)
    print(
        f"  proc   {rel}  "
        f"(file_doc={'yes' if need_file_doc else 'no'}, "
        f"undoc_items={len(undoc_items)})"
    )

    try:
        result = _call_llm(client, rel, source, items, need_file_doc, model)
    except Exception as exc:
        print(f"  ERROR  {rel}: {exc}", file=sys.stderr)
        return False

    new_source = apply_docstrings(source, result)

    if new_source == source:
        print(f"  same   {rel}  (LLM returned nothing new)")
        return False

    if dry_run:
        old_doc_lines = sum(
            1 for ln in source.splitlines()
            if ln.strip().startswith("///") or ln.strip().startswith("//!")
        )
        new_doc_lines = sum(
            1 for ln in new_source.splitlines()
            if ln.strip().startswith("///") or ln.strip().startswith("//!")
        )
        delta = new_doc_lines - old_doc_lines
        print(f"  diff   {rel}  (+{delta} doc lines)")
        return True

    path.write_text(new_source, encoding="utf-8")
    print(f"  done   {rel}")
    return True


# ── Entry point ────────────────────────────────────────────────────────────────

def main() -> None:
    ap = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    ap.add_argument(
        "--dry-run", action="store_true",
        help="Show what would change; do not write files.",
    )
    ap.add_argument(
        "--file", metavar="PATH",
        help="Process only this one file (relative to project root).",
    )
    ap.add_argument(
        "--overwrite", action="store_true",
        help="Regenerate existing doc-comments too.",
    )
    ap.add_argument(
        "--model", default="claude-opus-4-5",
        help="Anthropic model to use (default: claude-opus-4-5).",
    )
    ap.add_argument(
        "--exclude-mods", action="store_true",
        help="Skip mod.rs files (they should only have pub mod / pub use).",
    )
    args = ap.parse_args()

    api_key = os.environ.get("ANTHROPIC_API_KEY")
    if not api_key:
        sys.exit(
            "ERROR: ANTHROPIC_API_KEY environment variable is not set.\n"
            "Export it before running this script."
        )

    client = anthropic.Anthropic(api_key=api_key)

    if args.file:
        target = ROOT / args.file
        if not target.exists():
            sys.exit(f"ERROR: file not found: {target}")
        files = [target]
    else:
        files = list(iter_rust_files(SRC, EXCLUDE_DIRS))
        if args.exclude_mods:
            files = [f for f in files if f.name != "mod.rs"]

    print(
        f"gen_rust_docstrings: {len(files)} file(s)  "
        f"model={args.model}  dry_run={args.dry_run}  overwrite={args.overwrite}\n"
    )

    modified = 0
    for f in files:
        if process_file(
            client, f,
            dry_run=args.dry_run,
            overwrite=args.overwrite,
            model=args.model,
        ):
            modified += 1

    verb = "would be modified" if args.dry_run else "modified"
    print(f"\nDone: {modified}/{len(files)} file(s) {verb}.")


if __name__ == "__main__":
    main()
