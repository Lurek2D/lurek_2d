#!/usr/bin/env python3
"""Shared parser for content/snippets/*.lua marker blocks."""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import re

SNIPPET_RE = re.compile(r"^--\s*@snippet\s+([^\s]+)\s*$")
PREFIX_RE = re.compile(r"^--\s*@prefix\s+([^\s]+)\s*$")
MODULE_RE = re.compile(r"^--\s*@module\s+([^\s]+)\s*$")
DESC_RE = re.compile(r"^--\s*@description\s+(.+?)\s*$")
BODY_START_RE = re.compile(r"^--\s*@body\s*$")
BODY_END_RE = re.compile(r"^--\s*@end\s*$")
PLACEHOLDER_RE = re.compile(r"\bSNIP_\d+_[A-Za-z0-9_]+\b")


@dataclass
class SnippetBlock:
    file_path: Path
    line: int
    marker: str
    prefix: str
    module: str
    description: str
    body: list[str]


class ParseError(RuntimeError):
    pass


def parse_file(path: Path) -> list[SnippetBlock]:
    lines = path.read_text(encoding="utf-8").splitlines()
    blocks: list[SnippetBlock] = []

    i = 0
    while i < len(lines):
        m = SNIPPET_RE.match(lines[i].strip())
        if not m:
            i += 1
            continue

        marker = m.group(1)
        line_no = i + 1

        if i + 4 >= len(lines):
            raise ParseError(f"{path}: incomplete snippet block near line {line_no}")

        prefix_m = PREFIX_RE.match(lines[i + 1].strip())
        module_m = MODULE_RE.match(lines[i + 2].strip())
        desc_m = DESC_RE.match(lines[i + 3].strip())
        body_start = BODY_START_RE.match(lines[i + 4].strip())

        if not prefix_m:
            raise ParseError(f"{path}:{i+2}: expected -- @prefix <trigger>")
        if not module_m:
            raise ParseError(f"{path}:{i+3}: expected -- @module <module>")
        if not desc_m:
            raise ParseError(f"{path}:{i+4}: expected -- @description <text>")
        if not body_start:
            raise ParseError(f"{path}:{i+5}: expected -- @body")

        body: list[str] = []
        j = i + 5
        found_end = False
        while j < len(lines):
            if BODY_END_RE.match(lines[j].strip()):
                found_end = True
                break
            body.append(lines[j])
            j += 1

        if not found_end:
            raise ParseError(f"{path}:{line_no}: missing -- @end")

        blocks.append(
            SnippetBlock(
                file_path=path,
                line=line_no,
                marker=marker,
                prefix=prefix_m.group(1),
                module=module_m.group(1),
                description=desc_m.group(1),
                body=body,
            )
        )

        i = j + 1

    return blocks


def parse_dir(snippets_dir: Path) -> list[SnippetBlock]:
    blocks: list[SnippetBlock] = []
    for path in sorted(snippets_dir.glob("*.lua")):
        if path.name.startswith("_"):
            continue
        blocks.extend(parse_file(path))
    return blocks
