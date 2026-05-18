#!/usr/bin/env python3
"""Generate minimal example stub files in content/examples2/ from Lua API data.

Each API item becomes:
  --@api-stub: <api name>
  -- <description>
  do
    -- TODO: tutaj opisz example
    print("<api name>")
  end

Files are grouped per module and split into chunks of 50 API items by default.
Generated files are named <module>_00.lua, <module>_01.lua, and so on.
Every file ends with:
  print("<file name>")
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable


ROOT = Path(__file__).resolve().parents[2]
API_JSON = ROOT / "logs" / "data" / "lua_api_data.json"
DEFAULT_OUTPUT_DIR = ROOT / "content" / "examples2"
DEFAULT_CHUNK_SIZE = 50


@dataclass(frozen=True)
class Entry:
    module: str
    api_name: str
    description: str


def _normalise_description(value: str) -> str:
    text = re.sub(r"\s+", " ", value or "").strip()
    return text or "(no description)"


def load_entries(api_json: Path) -> dict[str, list[Entry]]:
    data = json.loads(api_json.read_text(encoding="utf-8"))
    modules = data["lua_api"]["modules"]
    grouped: dict[str, list[Entry]] = {}

    for module_name in sorted(modules.keys()):
        module = modules[module_name]
        entries: list[Entry] = []

        for function in module.get("functions") or []:
            entries.append(
                Entry(
                    module=module_name,
                    api_name=function.get("lua_name") or function["name"],
                    description=_normalise_description(function.get("description", "")),
                )
            )

        for class_name, class_data in (module.get("classes") or {}).items():
            for method in class_data.get("methods") or []:
                entries.append(
                    Entry(
                        module=module_name,
                        api_name=method.get("lua_name") or f"{class_name}:{method['name']}",
                        description=_normalise_description(method.get("description", "")),
                    )
                )

        grouped[module_name] = entries

    return grouped


def chunked(values: list[Entry], size: int) -> Iterable[list[Entry]]:
    for index in range(0, len(values), size):
        yield values[index:index + size]


def render_file(file_name: str, entries: list[Entry]) -> str:
    lines: list[str] = []

    for index, entry in enumerate(entries):
        lines.extend(
            [
                f"--@api-stub: {entry.api_name}",
                f"-- {entry.description}",
                "do",
                "  -- TODO: tutaj opisz example",
                f'  print("{entry.api_name}")',
                "end",
            ]
        )

        if index != len(entries) - 1:
            lines.append("")

    if lines:
        lines.append("")

    lines.append(f'print("{file_name}")')
    lines.append("")
    return "\n".join(lines)


def write_text(path: Path, content: str) -> None:
    with path.open("w", encoding="utf-8", newline="\n") as handle:
        handle.write(content)


def remove_old_module_files(output_dir: Path, module_name: str) -> int:
    removed = 0
    for path in sorted(output_dir.glob(f"{module_name}_*.lua")):
        path.unlink()
        removed += 1
    return removed


def resolve_output_dir(path_arg: str | None) -> Path:
    if not path_arg:
        return DEFAULT_OUTPUT_DIR

    path = Path(path_arg)
    if path.is_absolute():
        return path
    return ROOT / path


def generate_module(output_dir: Path, module_name: str, entries: list[Entry], chunk_size: int) -> list[Path]:
    output_dir.mkdir(parents=True, exist_ok=True)
    remove_old_module_files(output_dir, module_name)

    written: list[Path] = []
    chunks = list(chunked(entries, chunk_size)) or [[]]

    for chunk_index, chunk_entries in enumerate(chunks):
        file_name = f"{module_name}_{chunk_index:02d}.lua"
        file_path = output_dir / file_name
        write_text(file_path, render_file(file_name, chunk_entries))
        written.append(file_path)

    return written


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--module",
        action="append",
        dest="modules",
        help="Generate files only for the given module. Repeat to select multiple modules.",
    )
    parser.add_argument(
        "--chunk-size",
        type=int,
        default=DEFAULT_CHUNK_SIZE,
        help=f"Maximum API items per generated file (default: {DEFAULT_CHUNK_SIZE}).",
    )
    parser.add_argument(
        "--output-dir",
        help="Output directory. Relative paths are resolved from the repository root.",
    )
    args = parser.parse_args()

    if args.chunk_size <= 0:
        print("ERROR: --chunk-size must be greater than zero.")
        return 1

    if not API_JSON.exists():
        print(f"ERROR: {API_JSON} not found. Run python tools/gen_all_docs.py first.")
        return 1

    by_module = load_entries(API_JSON)
    selected_modules = sorted(args.modules or by_module.keys())

    missing_modules = [name for name in selected_modules if name not in by_module]
    if missing_modules:
        print("ERROR: unknown module(s): " + ", ".join(missing_modules))
        return 1

    output_dir = resolve_output_dir(args.output_dir)
    total_files = 0
    total_entries = 0

    for module_name in selected_modules:
        entries = by_module[module_name]
        written = generate_module(output_dir, module_name, entries, args.chunk_size)
        total_files += len(written)
        total_entries += len(entries)
        print(f"[{module_name}] wrote {len(written)} file(s), {len(entries)} API item(s)")

    print(f"Done. Wrote {total_files} file(s) and {total_entries} API item(s) to {output_dir}.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
