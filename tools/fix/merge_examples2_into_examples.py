#!/usr/bin/env python3
"""Merge content/examples2/<module>_NN.lua into content/examples/<module>.lua.

Rules:
- Group source files by module prefix.
- Sort each group by numeric suffix.
- Preserve the real example blocks as-is.
- Strip only the per-file trailing print("...lua") line from each source chunk.
- Overwrite content/examples/<module>.lua for every merged module.
- Remove stale root-level .lua files in content/examples/ that were generated
  earlier but no longer have a source group in content/examples2/.
- Leave subdirectories in content/examples/ untouched.

Usage:
    python tools/fix/merge_examples2_into_examples.py [--dry-run]
"""
from __future__ import annotations

import argparse
from dataclasses import dataclass
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
EXAMPLES2 = ROOT / "content" / "examples2"
EXAMPLES = ROOT / "content" / "examples"

SOURCE_RE = re.compile(r"^([a-z0-9]+)_(\d+)\.lua$")
TRAILING_PRINT_RE = re.compile(r'^print\(".*?\.lua"\)\s*$')
STUB_RE = re.compile(r"^---?@api-stub:\s*(.+?)\s*$")
TOP_LEVEL_DO_RE = re.compile(r"^do\b")
TOP_LEVEL_END_RE = re.compile(r"^end\s*$")


@dataclass
class ExampleBlock:
    stub: str
    comment: str
    inner_lines: list[str]

    def append_usage(self, comment: str | None, inner_lines: list[str]) -> None:
        extra_body = strip_blank_edges(inner_lines)
        if not extra_body:
            return

        if self.inner_lines:
            self.inner_lines.append("")

        extra_comment = normalize_comment_text(comment)
        if extra_comment is None:
            extra_comment = f"Additional usage for {short_stub_name(self.stub)}."

        self.inner_lines.append(f"    -- {extra_comment}")
        self.inner_lines.extend(extra_body)

    def render(self) -> str:
        lines: list[str] = []
        lines.append(f"--@api-stub: {self.stub}")
        lines.append(f"-- {normalize_comment_text(self.comment) or f'Example usage for {short_stub_name(self.stub)}.'}")
        lines.append("do")
        lines.extend(strip_blank_edges(self.inner_lines))
        lines.append("end")
        return "\n".join(lines)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Merge content/examples2 parts into content/examples module files"
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Report what would change without writing files",
    )
    return parser.parse_args()


def group_sources() -> dict[str, list[Path]]:
    groups: dict[str, list[tuple[int, Path]]] = {}
    for path in sorted(EXAMPLES2.glob("*.lua")):
        match = SOURCE_RE.match(path.name)
        if not match:
            continue
        module = match.group(1)
        order = int(match.group(2))
        groups.setdefault(module, []).append((order, path))

    ordered: dict[str, list[Path]] = {}
    for module, items in groups.items():
        ordered[module] = [path for _, path in sorted(items, key=lambda item: item[0])]
    return ordered


def trim_source_chunk(text: str) -> str:
    text = text.replace("\r\n", "\n").lstrip("\ufeff")
    lines = text.split("\n")

    while lines and not lines[-1].strip():
        lines.pop()

    if lines and TRAILING_PRINT_RE.match(lines[-1].strip()):
        lines.pop()

    while lines and not lines[-1].strip():
        lines.pop()

    return "\n".join(lines).strip("\n")


def strip_blank_edges(lines: list[str]) -> list[str]:
    cleaned = list(lines)
    while cleaned and not cleaned[0].strip():
        cleaned.pop(0)
    while cleaned and not cleaned[-1].strip():
        cleaned.pop()
    return cleaned


def indent_line(line: str) -> str:
    if not line.strip():
        return ""
    return f"    {line.lstrip()}"


def normalize_comment_text(comment: str | None) -> str | None:
    if comment is None:
        return None
    text = " ".join(comment.split())
    if not text:
        return None
    if not text.endswith((".", "!", "?")):
        text += "."
    return text


def short_stub_name(stub: str) -> str:
    tail = stub.split(":")[-1]
    return tail.split(".")[-1]


def comment_text_from_lines(lines: list[str]) -> str | None:
    parts: list[str] = []
    for line in strip_blank_edges(lines):
        stripped = line.strip()
        if not stripped:
            continue
        if stripped.startswith("---@") or stripped.startswith("---"):
            continue
        if stripped.startswith("--"):
            text = stripped[2:].strip()
            if text:
                parts.append(text)

    if not parts:
        return None

    return normalize_comment_text(" ".join(parts))


def split_prelude(lines: list[str]) -> tuple[list[str], str | None, list[str]]:
    trimmed = strip_blank_edges(lines)
    if not trimmed:
        return [], None, []

    first_stub_index: int | None = None
    stubs: list[str] = []
    for index, line in enumerate(trimmed):
        match = STUB_RE.match(line)
        if not match:
            continue
        if first_stub_index is None:
            first_stub_index = index
        stubs.append(match.group(1).strip())

    if first_stub_index is None:
        return trimmed, None, []

    before_stub = trimmed[:first_stub_index]
    stub_end_index = first_stub_index
    while stub_end_index < len(trimmed) and STUB_RE.match(trimmed[stub_end_index]):
        stub_end_index += 1

    description_after_stub = comment_text_from_lines(trimmed[stub_end_index:])

    if not before_stub:
        return [], description_after_stub, stubs

    desc_end = len(before_stub) - 1
    while desc_end >= 0 and not before_stub[desc_end].strip():
        desc_end -= 1

    desc_start = desc_end
    while desc_start >= 0:
        stripped = before_stub[desc_start].strip()
        if not stripped:
            break
        if stripped.startswith("--") and not stripped.startswith("---@") and not stripped.startswith("---"):
            desc_start -= 1
            continue
        break

    if desc_end >= 0 and desc_start < desc_end:
        description_before_stub = comment_text_from_lines(before_stub[desc_start + 1:desc_end + 1])
        leading = strip_blank_edges(before_stub[:desc_start + 1])
        return leading, description_after_stub or description_before_stub, stubs

    return before_stub, description_after_stub, stubs


def build_block_comment(base_comment: str | None, stub: str, total_stubs: int) -> str:
    normalized = normalize_comment_text(base_comment)
    if normalized is None:
        return f"Example usage for {short_stub_name(stub)}."
    if total_stubs <= 1:
        return normalized
    return f"{normalized} Focus: {short_stub_name(stub)}."


def split_chunk_items(chunk: str) -> list[tuple[str, list[str], list[str]]]:
    lines = chunk.split("\n")
    items: list[tuple[str, list[str], list[str]]] = []
    pending: list[str] = []
    index = 0

    while index < len(lines):
        line = lines[index]
        if TOP_LEVEL_DO_RE.match(line):
            block_lines = [line]
            index += 1
            while index < len(lines):
                block_lines.append(lines[index])
                if TOP_LEVEL_END_RE.match(lines[index]):
                    index += 1
                    break
                index += 1
            items.append(("block", pending, block_lines))
            pending = []
            continue

        pending.append(line)
        index += 1

    if any(line.strip() for line in pending):
        items.append(("text", pending, []))

    return items


def build_output(module: str, sources: list[Path]) -> str:
    header = [
        f"-- content/examples/{module}.lua",
        (
            f"-- Auto-generated from content/examples2/{module}_*.lua "
            f"by tools/fix/merge_examples2_into_examples.py"
        ),
        f"-- Run: cargo run -- content/examples/{module}.lua",
    ]

    chunks: list[str] = ["\n".join(header)]
    rendered_items: list[str | ExampleBlock] = []
    seen_stubs: dict[str, ExampleBlock] = {}

    for source in sources:
        chunk = trim_source_chunk(source.read_text(encoding="utf-8"))
        if not chunk:
            continue

        for kind, prelude_lines, block_lines in split_chunk_items(chunk):
            if kind == "text":
                text = "\n".join(strip_blank_edges(prelude_lines))
                if text:
                    rendered_items.append(text)
                continue

            leading_text, comment, stubs = split_prelude(prelude_lines)
            if leading_text:
                text = "\n".join(leading_text)
                if text:
                    rendered_items.append(text)

            if not stubs:
                raw_block = "\n".join(strip_blank_edges(prelude_lines + block_lines))
                if raw_block:
                    rendered_items.append(raw_block)
                continue

            block_inner = strip_blank_edges(block_lines[1:-1])

            for stub in stubs:
                target = seen_stubs.get(stub)
                block_comment = build_block_comment(comment, stub, len(stubs))
                if target is None:
                    block = ExampleBlock(stub=stub, comment=block_comment, inner_lines=list(block_inner))
                    rendered_items.append(block)
                    seen_stubs[stub] = block
                    continue

                target.append_usage(block_comment, block_inner)

    chunks.append(f'print("content/examples/{module}.lua")')

    for item in rendered_items:
        if isinstance(item, ExampleBlock):
            chunks.insert(-1, item.render())
        else:
            chunks.insert(-1, item)

    return "\n\n".join(chunks) + "\n"


def write_outputs(groups: dict[str, list[Path]], dry_run: bool) -> int:
    changed = 0
    EXAMPLES.mkdir(parents=True, exist_ok=True)

    generated_names: set[str] = set()

    for module, sources in sorted(groups.items()):
        target = EXAMPLES / f"{module}.lua"
        generated_names.add(target.name)
        content = build_output(module, sources)
        previous = target.read_text(encoding="utf-8") if target.exists() else None
        if previous == content:
            print(f"OK     {target.relative_to(ROOT)} ({len(sources)} source files)")
            continue

        changed += 1
        print(f"WRITE  {target.relative_to(ROOT)} ({len(sources)} source files)")
        if not dry_run:
            target.write_text(content, encoding="utf-8")

    stale_targets = [
        path
        for path in sorted(EXAMPLES.glob("*.lua"))
        if path.name not in generated_names
    ]
    for stale in stale_targets:
        changed += 1
        print(f"REMOVE {stale.relative_to(ROOT)}")
        if not dry_run:
            stale.unlink()

    return changed


def main() -> int:
    args = parse_args()
    if not EXAMPLES2.exists():
        print(f"Missing source directory: {EXAMPLES2}", file=sys.stderr)
        return 1

    groups = group_sources()
    if not groups:
        print("No content/examples2/<module>_NN.lua files found", file=sys.stderr)
        return 1

    changed = write_outputs(groups, dry_run=args.dry_run)
    print(f"Done. Modules: {len(groups)}  Changed: {changed}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())