"""Validate and emit the deterministic native shape catalogue.

The runtime never reads TOML. TOML is the editable source of truth for the
96-entry contract; this tool emits a small Rust ID table and supports --check
for CI/release reproducibility.
"""

from __future__ import annotations

import argparse
from dataclasses import dataclass
import json
import math
from pathlib import Path
import tomllib

EXPECTED_CATEGORIES = [
    "blocks_terrain",
    "character",
    "creature",
    "item",
    "prop",
    "ui",
    "effect",
    "data_viz",
]
OUTPUT = Path("src/render/builtin_shape_catalog_generated.rs")
PALETTE_ROLES = {
    "background",
    "primary",
    "secondary",
    "accent",
    "outline",
    "highlight",
    "shadow",
    "emissive",
}
MAX_ELEMENTS = 256
MAX_PATH_SEGMENTS = 4096


@dataclass(frozen=True)
class CatalogEntry:
    """Validated, generator-owned metadata for one native shape template."""

    shape_id: str
    category: str
    anchor: tuple[float, float]
    tags: tuple[str, ...]
    primitives: tuple[str, ...]
    palette: tuple[tuple[str, tuple[float, float, float, float]], ...]


def _finite_numbers(value: object, where: str) -> None:
    """Reject NaN/Inf anywhere in optional native element metadata."""
    if isinstance(value, bool):
        return
    if isinstance(value, (int, float)):
        if not math.isfinite(float(value)):
            raise ValueError(f"{where}: numeric values must be finite")
        return
    if isinstance(value, list):
        for index, item in enumerate(value):
            _finite_numbers(item, f"{where}[{index}]")
        return
    if isinstance(value, dict):
        for key, item in value.items():
            _finite_numbers(item, f"{where}.{key}")


def _path_count(value: object, where: str) -> int:
    """Count path verb records recursively and validate the known verbs."""
    if isinstance(value, dict):
        total = 0
        for key, item in value.items():
            if key in {"path", "segments", "verbs"} and isinstance(item, list):
                if len(item) > MAX_PATH_SEGMENTS:
                    raise ValueError(
                        f"{where}.{key}: path segments exceed {MAX_PATH_SEGMENTS}"
                    )
                for index, segment in enumerate(item):
                    if isinstance(segment, dict) and "verb" in segment:
                        verb = segment["verb"]
                        if verb not in {
                            "moveTo",
                            "lineTo",
                            "quadTo",
                            "cubicTo",
                            "close",
                            "closePath",
                        }:
                            raise ValueError(
                                f"{where}.{key}[{index}]: unknown path verb {verb!r}"
                            )
                total += len(item)
            total += _path_count(item, f"{where}.{key}")
        return total
    if isinstance(value, list):
        return sum(_path_count(item, f"{where}[{index}]") for index, item in enumerate(value))
    return 0


def _validate_palette(palette: object, where: str) -> None:
    """Validate the closed palette-role contract for file and shape palettes."""
    if not isinstance(palette, dict):
        raise ValueError(f"{where}: palette must be a table")
    for role, color in palette.items():
        if role not in PALETTE_ROLES:
            raise ValueError(f"{where}: unknown palette role {role!r}")
        if not isinstance(color, list) or len(color) not in {3, 4}:
            raise ValueError(f"{where}.{role} must contain 3 or 4 channels")
        _finite_numbers(color, f"{where}.{role}")
        if any(
            not isinstance(channel, (int, float))
            or isinstance(channel, bool)
            or not 0 <= float(channel) <= 1
            for channel in color
        ):
            raise ValueError(f"{where}.{role} channels must be within 0..1")


def _references(value: object) -> list[str]:
    """Collect optional composition references from a shape/elements tree."""
    found: list[str] = []
    if isinstance(value, dict):
        for key, item in value.items():
            if key in {"ref", "reference", "extends", "use"} and isinstance(item, str):
                found.append(item)
            elif key in {"references", "children"} and isinstance(item, list):
                found.extend(item for item in item if isinstance(item, str))
            found.extend(_references(item))
    elif isinstance(value, list):
        for item in value:
            found.extend(_references(item))
    return found


def _validate_shape(shape: object, path: Path, category: str) -> list[str]:
    if not isinstance(shape, dict):
        raise ValueError(f"{path}: each shape must be a table")
    shape_id = shape.get("id")
    if not isinstance(shape_id, str) or not shape_id or "/" in shape_id:
        raise ValueError(f"{path}: invalid shape id {shape_id!r}")
    anchor = shape.get("anchor")
    if anchor is not None:
        if not isinstance(anchor, list) or len(anchor) != 2:
            raise ValueError(f"{path} shape {shape_id!r}: anchor must contain two numbers")
        _finite_numbers(anchor, f"{path} shape {shape_id!r}.anchor")
    palette = shape.get("palette")
    if palette is not None:
        _validate_palette(palette, f"{path} shape {shape_id!r}.palette")
    elements = shape.get("elements", [])
    if not isinstance(elements, list):
        raise ValueError(f"{path} shape {shape_id!r}: elements must be a list")
    if len(elements) > MAX_ELEMENTS:
        raise ValueError(
            f"{path} shape {shape_id!r}: elements exceed {MAX_ELEMENTS}"
        )
    _finite_numbers(elements, f"{path} shape {shape_id!r}.elements")
    path_segments = _path_count(elements, f"{path} shape {shape_id!r}.elements")
    if path_segments > MAX_PATH_SEGMENTS:
        raise ValueError(
            f"{path} shape {shape_id!r}: total path segments exceed {MAX_PATH_SEGMENTS}"
        )
    return _references(shape)


def read_catalog(root: Path) -> list[CatalogEntry]:
    source = root / "assets" / "native_shapes" / "v1"
    # The catalogue order is part of the deterministic runtime contract.  Do
    # not rely on filesystem/locale sorting (which also puts data_viz/effect
    # before item/prop on some platforms).
    actual_files = sorted(path.name for path in source.glob("*.toml"))
    expected_files = sorted(f"{category}.toml" for category in EXPECTED_CATEGORIES)
    if actual_files != expected_files:
        raise ValueError(
            "expected exactly the eight category TOML files "
            f"{expected_files}, found {actual_files}"
        )
    files = [source / f"{category}.toml" for category in EXPECTED_CATEGORIES]
    entries: list[CatalogEntry] = []
    references: dict[str, list[str]] = {}
    for path in files:
        if not path.is_file():
            raise ValueError(f"missing catalogue file: {path}")
        data = tomllib.loads(path.read_text(encoding="utf-8"))
        category = data.get("category")
        if category not in EXPECTED_CATEGORIES:
            raise ValueError(f"{path}: invalid category {category!r}")
        if data.get("view_box") != [0, 0, 64, 64]:
            raise ValueError(f"{path}: view_box must be [0, 0, 64, 64]")
        if "palette" in data:
            _validate_palette(data["palette"], f"{path}.palette")
        shapes = data.get("shapes")
        if not isinstance(shapes, list) or len(shapes) != 12:
            raise ValueError(f"{path}: category must contain exactly 12 shapes")
        for shape in shapes:
            shape_id = shape.get("id") if isinstance(shape, dict) else None
            _validate_shape(shape, path, category)
            canonical_id = f"{category}/{shape_id}"
            anchor_value = shape.get("anchor", [0.5, 0.5])
            anchor = (float(anchor_value[0]), float(anchor_value[1]))
            tags_value = shape.get("tags", [])
            if not isinstance(tags_value, list) or any(
                not isinstance(tag, str) or not tag for tag in tags_value
            ):
                raise ValueError(f"{path} shape {shape_id!r}: tags must be strings")
            primitives: list[str] = []
            for element in shape.get("elements", []):
                if isinstance(element, dict):
                    primitive = element.get("primitive") or element.get("kind")
                    if isinstance(primitive, str) and primitive:
                        primitives.append(primitive)
            palette_value = shape.get("palette", data.get("palette", {}))
            _validate_palette(palette_value, f"{path} shape {shape_id!r}.palette")
            palette: list[tuple[str, tuple[float, float, float, float]]] = []
            for role in sorted(palette_value):
                channels = [float(channel) for channel in palette_value[role]]
                if len(channels) == 3:
                    channels.append(1.0)
                palette.append((role, tuple(channels)))
            entries.append(
                CatalogEntry(
                    shape_id=canonical_id,
                    category=category,
                    anchor=anchor,
                    tags=tuple(tags_value),
                    primitives=tuple(primitives),
                    palette=tuple(palette),
                )
            )
            references[canonical_id] = _references(shape)
    if {entry.category for entry in entries} != set(EXPECTED_CATEGORIES):
        raise ValueError("catalogue categories do not match the eight required groups")
    if len(entries) != 96 or len({entry.shape_id for entry in entries}) != 96:
        raise ValueError("catalogue must contain exactly 96 unique canonical IDs")
    known_ids = {entry.shape_id for entry in entries}
    graph: dict[str, list[str]] = {}
    for source, refs in references.items():
        resolved: list[str] = []
        category = source.split("/", 1)[0]
        for ref in refs:
            candidate = ref if "/" in ref else f"{category}/{ref}"
            if candidate not in known_ids:
                raise ValueError(f"{source}: unknown shape reference {ref!r}")
            resolved.append(candidate)
        graph[source] = resolved
    visiting: set[str] = set()
    visited: set[str] = set()

    def visit(node: str) -> None:
        if node in visiting:
            raise ValueError(f"catalogue shape references contain a cycle at {node!r}")
        if node in visited:
            return
        visiting.add(node)
        for child in graph.get(node, []):
            visit(child)
        visiting.remove(node)
        visited.add(node)

    for node in graph:
        visit(node)
    return entries


def _rust_float(value: float) -> str:
    """Format finite TOML numbers without locale or non-deterministic output."""
    text = format(value, ".9g")
    return text if any(char in text for char in ".eE") else f"{text}.0"


def _rust_string(value: str) -> str:
    return json.dumps(value, ensure_ascii=True)


def render(entries: list[CatalogEntry]) -> str:
    lines = [
        "//! Generated by tools/render/gen_builtin_shapes.py; do not edit manually.",
        "/// Canonical IDs from assets/native_shapes/v1.",
        "pub const GENERATED_BUILTIN_SHAPE_IDS: [&str; 96] = [",
    ]
    lines.extend(f"    {_rust_string(entry.shape_id)}," for entry in entries)
    lines.extend(
        [
            "];",
            "",
            "/// Metadata emitted from the canonical TOML catalogue.",
            "#[derive(Debug, Clone, Copy)]",
            "pub struct GeneratedBuiltinShapeMetadata {",
            "    pub id: &'static str,",
            "    pub category: &'static str,",
            "    pub anchor: [f32; 2],",
            "    pub tags: &'static [&'static str],",
            "    pub primitives: &'static [&'static str],",
            "    pub palette: &'static [crate::render::builtin_shapes::BuiltinPaletteRole],",
            "}",
            "",
            "#[rustfmt::skip]",
            "pub const GENERATED_BUILTIN_SHAPE_METADATA: [GeneratedBuiltinShapeMetadata; 96] = [",
        ]
    )
    for entry in entries:
        tags = ", ".join(_rust_string(tag) for tag in entry.tags)
        primitives = ", ".join(_rust_string(primitive) for primitive in entry.primitives)
        palette = ", ".join(
            "crate::render::builtin_shapes::BuiltinPaletteRole { role: "
            f"{_rust_string(role)}, color: [{', '.join(_rust_float(channel) for channel in color)}] }}"
            for role, color in entry.palette
        )
        lines.extend(
            [
                "    GeneratedBuiltinShapeMetadata {",
                f"        id: {_rust_string(entry.shape_id)},",
                f"        category: {_rust_string(entry.category)},",
                f"        anchor: [{_rust_float(entry.anchor[0])}, {_rust_float(entry.anchor[1])}],",
                f"        tags: &[{tags}],",
                f"        primitives: &[{primitives}],",
                f"        palette: &[{palette}],",
                "    },",
            ]
        )
    lines.extend(["];"])
    return "\n".join(lines) + "\n"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true", help="fail when generated output is stale")
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[2])
    args = parser.parse_args()
    try:
        entries = read_catalog(args.root)
    except (OSError, ValueError, tomllib.TOMLDecodeError) as exc:
        parser.error(str(exc))
    expected = render(entries)
    output = args.root / OUTPUT
    actual = output.read_text(encoding="utf-8") if output.exists() else None
    if args.check:
        if actual != expected:
            print(f"stale generated catalogue: {output}")
            return 1
        print("native shape catalogue: 96 entries, generated output is current")
        return 0
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(expected, encoding="utf-8", newline="\n")
    print(f"wrote {output} ({len(entries)} entries)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
