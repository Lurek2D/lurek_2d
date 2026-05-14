#!/usr/bin/env python3
"""scan_missing_docs.py — detect Rust items without doc-comments in src/ (no lua_api)."""
import re, os, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SRC  = ROOT / "src"

ITEM_RE = re.compile(
    r"^(?P<indent>[ \t]*)"
    r"(?:pub(?:\s*\([^)]*\))?\s+)?"
    r"(?:"
    r"(?:async\s+)?(?:unsafe\s+)?(?:extern\s+['\"]C['\"]\s+)?(?:fn|struct|enum|trait|union|type|const|static|macro_rules!)"
    r"|impl(?:\s*<[^{>]*>)?"
    r"|mod\s+[A-Za-z_]\w*\s*;"
    r")\s*[A-Za-z_!]",
)
VARIANT_RE = re.compile(r"^(?P<indent>[ \t]*)(?P<name>[A-Z][A-Za-z0-9_]*)(?:\s*(?:[,({]|$))")


def has_file_doc(source: str) -> bool:
    for line in source.splitlines():
        s = line.strip()
        if s.startswith("//!"):
            return True
        if s and not s.startswith("//") and not s.startswith("#!"):
            break
    return False


def preceding_has_doc(lines: list[str], i: int) -> bool:
    j = i - 1
    while j >= 0 and lines[j].strip() == "":
        j -= 1
    return j >= 0 and bool(re.match(r"[ \t]*///", lines[j]))


def scan_file(path: Path):
    content = path.read_text(encoding="utf-8")
    hfd = has_file_doc(content)
    lines = content.splitlines()
    undoc: list[tuple[int, str]] = []
    depth = 0
    block_kind: list[str] = []

    for i, raw in enumerate(lines):
        # simple brace counting (good enough for top-level items)
        s_strip = re.sub(r'"[^"\\]*"', '""', raw)   # strip string literals
        s_strip = re.sub(r"//.*", "", s_strip)         # strip line comments
        opens  = s_strip.count("{")
        closes = s_strip.count("}")
        line_depth = depth
        depth = max(0, depth + opens - closes)

        if opens > closes:
            for _ in range(opens - closes):
                if re.match(r"[ \t]*(?:pub(?:\([^)]*\))?\s+)?enum\s+", raw):
                    block_kind.append("enum")
                elif re.match(r"[ \t]*(?:pub(?:\([^)]*\))?\s+)?impl", raw):
                    block_kind.append("impl")
                else:
                    block_kind.append("other")
        elif closes > opens:
            for _ in range(closes - opens):
                if block_kind:
                    block_kind.pop()

        if line_depth > 1:
            continue

        # Enum variants inside an enum block
        if line_depth == 1 and block_kind and block_kind[-1] == "enum":
            m = VARIANT_RE.match(raw)
            if m and not preceding_has_doc(lines, i):
                undoc.append((i + 1, raw.rstrip()[:90]))
            continue

        if ITEM_RE.match(raw) and not preceding_has_doc(lines, i):
            undoc.append((i + 1, raw.rstrip()[:90]))

    return hfd, undoc


def main() -> None:
    limit = int(sys.argv[1]) if len(sys.argv) > 1 else 40
    results = []
    for root, dirs, files in os.walk(SRC):
        dirs[:] = [d for d in dirs if d != "lua_api"]
        for f in sorted(files):
            if not f.endswith(".rs"):
                continue
            path = Path(root) / f
            hfd, undoc = scan_file(path)
            if not hfd or undoc:
                results.append((path.relative_to(ROOT), hfd, undoc))

    print(f"=== {len(results)} files need work ===\n")
    for rel, hfd, undoc in sorted(results, key=lambda x: -len(x[2]))[:limit]:
        marker = "  [NO_FILE_DOC]" if not hfd else ""
        print(f"{rel}{marker}: {len(undoc)} undoc items")
        for ln, snip in undoc[:5]:
            print(f"    L{ln}: {snip}")
    print()


if __name__ == "__main__":
    main()
