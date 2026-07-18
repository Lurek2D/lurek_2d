"""Render the generated SVG subset to RGBA PNGs without third-party packages.

The SVG generator intentionally emits only rect, ellipse, circle, polygon, and
line primitives. Keeping the renderer dependency-free makes the asset pipeline
reproducible on the same Windows checkout that runs the game.
"""

from __future__ import annotations

import argparse
from pathlib import Path
import math
import struct
import xml.etree.ElementTree as ET
import zlib


GAME_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_ASSETS = GAME_ROOT / "mods/core/assets"


def number(value: str | None, fallback: float = 0.0) -> float:
    try:
        return float(value) if value is not None else fallback
    except ValueError:
        return fallback


def color(value: str | None) -> tuple[int, int, int, int] | None:
    if not value or value == "none":
        return None
    if value.startswith("#") and len(value) == 7:
        return int(value[1:3], 16), int(value[3:5], 16), int(value[5:7], 16), 255
    if value.startswith("#") and len(value) == 4:
        return int(value[1] * 2, 16), int(value[2] * 2, 16), int(value[3] * 2, 16), 255
    named = {"black": (0, 0, 0, 255), "white": (255, 255, 255, 255)}
    return named.get(value.lower())


class Image:
    def __init__(self, width: int, height: int):
        self.width = width
        self.height = height
        self.pixels = bytearray(width * height * 4)

    def put(self, x: int, y: int, rgba: tuple[int, int, int, int], opacity: float = 1.0) -> None:
        if x < 0 or y < 0 or x >= self.width or y >= self.height:
            return
        sr, sg, sb, sa = rgba
        source_alpha = max(0.0, min(1.0, opacity * sa / 255.0))
        offset = (y * self.width + x) * 4
        dr, dg, db, da_byte = self.pixels[offset:offset + 4]
        dest_alpha = da_byte / 255.0
        out_alpha = source_alpha + dest_alpha * (1.0 - source_alpha)
        if out_alpha <= 0:
            return
        self.pixels[offset] = int((sr * source_alpha + dr * dest_alpha * (1 - source_alpha)) / out_alpha)
        self.pixels[offset + 1] = int((sg * source_alpha + dg * dest_alpha * (1 - source_alpha)) / out_alpha)
        self.pixels[offset + 2] = int((sb * source_alpha + db * dest_alpha * (1 - source_alpha)) / out_alpha)
        self.pixels[offset + 3] = int(out_alpha * 255)


def draw_rect(image: Image, attrs: dict[str, str], rgba, opacity: float) -> None:
    x, y = math.floor(number(attrs.get("x"))), math.floor(number(attrs.get("y")))
    width, height = math.ceil(number(attrs.get("width"))), math.ceil(number(attrs.get("height")))
    for yy in range(y, y + height):
        for xx in range(x, x + width):
            image.put(xx, yy, rgba, opacity)


def draw_ellipse(image: Image, attrs: dict[str, str], rgba, opacity: float) -> None:
    cx, cy = number(attrs.get("cx")), number(attrs.get("cy"))
    rx, ry = max(0.5, number(attrs.get("rx"))), max(0.5, number(attrs.get("ry")))
    for yy in range(math.floor(cy - ry), math.ceil(cy + ry) + 1):
        for xx in range(math.floor(cx - rx), math.ceil(cx + rx) + 1):
            if ((xx + 0.5 - cx) / rx) ** 2 + ((yy + 0.5 - cy) / ry) ** 2 <= 1:
                image.put(xx, yy, rgba, opacity)


def draw_polygon(image: Image, attrs: dict[str, str], rgba, opacity: float) -> None:
    points = []
    for pair in attrs.get("points", "").split():
        x, y = pair.split(",", 1)
        points.append((number(x), number(y)))
    if len(points) < 3:
        return
    min_x = math.floor(min(x for x, _ in points))
    max_x = math.ceil(max(x for x, _ in points))
    min_y = math.floor(min(y for _, y in points))
    max_y = math.ceil(max(y for _, y in points))
    for yy in range(min_y, max_y + 1):
        for xx in range(min_x, max_x + 1):
            inside = False
            previous = points[-1]
            for current in points:
                x1, y1 = previous
                x2, y2 = current
                crosses = (y1 > yy) != (y2 > yy)
                if crosses and xx < (x2 - x1) * (yy - y1) / ((y2 - y1) or 1e-9) + x1:
                    inside = not inside
                previous = current
            if inside:
                image.put(xx, yy, rgba, opacity)


def draw_line(image: Image, attrs: dict[str, str], rgba, opacity: float) -> None:
    x1, y1 = number(attrs.get("x1")), number(attrs.get("y1"))
    x2, y2 = number(attrs.get("x2")), number(attrs.get("y2"))
    width = max(1.0, number(attrs.get("stroke-width"), 1.0))
    steps = max(1, int(max(abs(x2 - x1), abs(y2 - y1)) * 2))
    radius = max(0, int(math.ceil(width / 2)))
    for step in range(steps + 1):
        t = step / steps
        cx = round(x1 + (x2 - x1) * t)
        cy = round(y1 + (y2 - y1) * t)
        for yy in range(cy - radius, cy + radius + 1):
            for xx in range(cx - radius, cx + radius + 1):
                image.put(xx, yy, rgba, opacity)


def render(svg_path: Path) -> tuple[int, int, bytes]:
    root = ET.parse(svg_path).getroot()
    width = int(number(root.attrib.get("width")))
    height = int(number(root.attrib.get("height")))
    image = Image(width, height)
    for element in root.iter():
        tag = element.tag.rsplit("}", 1)[-1]
        attrs = element.attrib
        opacity = number(attrs.get("opacity"), 1.0)
        if tag in {"rect", "ellipse", "circle", "polygon"}:
            rgba = color(attrs.get("fill"))
            if rgba is None:
                continue
            if tag == "rect":
                draw_rect(image, attrs, rgba, opacity)
            elif tag == "ellipse":
                draw_ellipse(image, attrs, rgba, opacity)
            elif tag == "circle":
                circle_attrs = dict(attrs)
                circle_attrs["rx"] = circle_attrs.get("r", "0")
                circle_attrs["ry"] = circle_attrs.get("r", "0")
                draw_ellipse(image, circle_attrs, rgba, opacity)
            else:
                draw_polygon(image, attrs, rgba, opacity)
        elif tag == "line":
            rgba = color(attrs.get("stroke"))
            if rgba is not None:
                draw_line(image, attrs, rgba, opacity)
    return width, height, bytes(image.pixels)


def png_chunk(kind: bytes, payload: bytes) -> bytes:
    return struct.pack(">I", len(payload)) + kind + payload + struct.pack(">I", zlib.crc32(kind + payload) & 0xFFFFFFFF)


def encode_png(width: int, height: int, pixels: bytes) -> bytes:
    rows = b"".join(b"\x00" + pixels[row * width * 4:(row + 1) * width * 4] for row in range(height))
    return b"\x89PNG\r\n\x1a\n" + png_chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)) + png_chunk(b"IDAT", zlib.compress(rows, 9)) + png_chunk(b"IEND", b"")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--assets", type=Path, default=DEFAULT_ASSETS, help="asset root containing the generated SVG files")
    parser.add_argument("--dry-run", action="store_true", help="validate and list outputs without overwriting PNGs")
    args = parser.parse_args()
    svg_files = sorted(args.assets.rglob("*.svg"))
    assert svg_files, f"no SVG assets found under {args.assets}"
    for svg_path in svg_files:
        width, height, pixels = render(svg_path)
        png_path = svg_path.with_suffix(".png")
        if not args.dry_run:
            png_path.write_bytes(encode_png(width, height, pixels))
        print(f"{svg_path.relative_to(args.assets)} -> {png_path.name} ({width}x{height})")
    print(f"rendered {len(svg_files)} SVG assets; PNG files {'validated' if args.dry_run else 'replaced'}")


if __name__ == "__main__":
    main()
