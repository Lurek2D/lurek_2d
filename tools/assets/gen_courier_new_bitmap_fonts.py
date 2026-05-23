#!/usr/bin/env python3
"""Generate Courier New bitmap font sprite sheets for ASCII 32..255 (Latin-1).

Sizes are POINT sizes (pt), as in any text editor.
Converted to pixels at 96 DPI (Windows standard):
  8pt→11px, 10pt→13px, 12pt→16px, 16pt→21px, 20pt→27px, 24pt→32px, 30pt→40px

Two variants per size: regular (font_N.png) and bold (fontb_N.png).

Atlas layout: 16 columns × 14 rows = 224 cells (chars 32..=255).
Rendering is 1-bit (bilevel, no antialiasing).
Cell dimensions: advance width from monospace 'M', height from ascent+descent+2×PADDING.

Usage:
```
usage: gen_courier_new_bitmap_fonts.py [-h] [--font-path FONT_PATH]
                                       [--bold-path BOLD_PATH]
                                       [--sizes SIZES [SIZES ...]]
                                       [--output-dir OUTPUT_DIR]
                                       [--metadata METADATA]

Lurek2D Tool

options:
  -h, --help            show this help message and exit
  --font-path FONT_PATH
                        Path to Courier New regular .ttf (cour.ttf)
  --bold-path BOLD_PATH
                        Path to Courier New Bold .ttf (courbd.ttf)
  --sizes SIZES [SIZES ...]
  --output-dir OUTPUT_DIR
  --metadata METADATA

Examples:
  # Default execution
  python tools/assets/gen_courier_new_bitmap_fonts.py

  # Show all arguments
  python tools/assets/gen_courier_new_bitmap_fonts.py --help
```
"""
from __future__ import annotations

import argparse
import json
import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ASCII_START = 32
ASCII_END = 255  # Latin-1 full range: 224 chars → 16 cols × 14 rows
COLUMNS = 16
PADDING = 1  # 1 px padding per side
SCREEN_DPI = 96  # Windows standard DPI — converts pt sizes to pixels

DEFAULT_SIZES = [8, 10, 12, 16, 20, 24, 30]  # point sizes, same as in any text editor
DEFAULT_FONT_PATHS = [
    Path("C:/Windows/Fonts/cour.ttf"),
    Path("/usr/share/fonts/truetype/msttcorefonts/Courier_New.ttf"),
    Path("/Library/Fonts/Courier New.ttf"),
]
DEFAULT_BOLD_PATHS = [
    Path("C:/Windows/Fonts/courbd.ttf"),
    Path("/usr/share/fonts/truetype/msttcorefonts/Courier_New_Bold.ttf"),
    Path("/Library/Fonts/Courier New Bold.ttf"),
]

# Latin-1 code points 0x80..0x9F are C1 control characters — Courier New has no glyphs
# for them (they render as blank cells).  We substitute the 32 most useful terminal chars
# from the Unicode box-drawing and block-elements ranges so Lua can render box-art and
# simple UI decorations by writing string.char(0x80)..string.char(0x9F).
#
# Atlas slot 0x80 = index 96  (row 6 col 0)
# Atlas slot 0x9F = index 127 (row 7 col 15)
C1_SUBSTITUTES: dict[int, str] = {
    0x80: "─",  # U+2500 box light horizontal
    0x81: "│",  # U+2502 box light vertical
    0x82: "┌",  # U+250C box light down-right
    0x83: "┐",  # U+2510 box light down-left
    0x84: "└",  # U+2514 box light up-right
    0x85: "┘",  # U+2518 box light up-left
    0x86: "├",  # U+251C box light vertical-right
    0x87: "┤",  # U+2524 box light vertical-left
    0x88: "┬",  # U+252C box light horizontal-down
    0x89: "┴",  # U+2534 box light horizontal-up
    0x8A: "┼",  # U+253C box light cross
    0x8B: "═",  # U+2550 box double horizontal
    0x8C: "║",  # U+2551 box double vertical
    0x8D: "╔",  # U+2554 box double down-right
    0x8E: "╗",  # U+2557 box double down-left
    0x8F: "╚",  # U+255A box double up-right
    0x90: "╝",  # U+255D box double up-left
    0x91: "╠",  # U+2560 box double vertical-right
    0x92: "╣",  # U+2563 box double vertical-left
    0x93: "╦",  # U+2566 box double horizontal-down
    0x94: "╩",  # U+2569 box double horizontal-up
    0x95: "╬",  # U+256C box double cross
    0x96: "░",  # U+2591 light shade
    0x97: "▒",  # U+2592 medium shade
    0x98: "▓",  # U+2593 dark shade
    0x99: "█",  # U+2588 full block
    0x9A: "▀",  # U+2580 upper-half block
    0x9B: "▄",  # U+2584 lower-half block
    0x9C: "▲",  # U+25B2 black up-pointing triangle
    0x9D: "▼",  # U+25BC black down-pointing triangle
    0x9E: "◄",  # U+25C4 black left-pointing pointer
    0x9F: "►",  # U+25BA black right-pointing pointer
}


def find_font(font_path: str | None, candidates: list[Path], label: str) -> Path:
    if font_path:
        path = Path(font_path)
        if path.exists():
            return path
        raise FileNotFoundError(f"{label} not found: {font_path}")
    for candidate in candidates:
        if candidate.exists():
            return candidate
    raise FileNotFoundError(
        f"{label} not found. Pass --font-path / --bold-path pointing to the .ttf file."
    )


def render_bitmap(font_path: Path, pt_size: int, output_path: Path, style: str = "regular") -> dict:
    # Convert point size to pixels at Windows 96 DPI.
    pixel_size = round(pt_size * SCREEN_DPI / 72)
    font = ImageFont.truetype(str(font_path), pixel_size)

    # Cell dimensions from font metrics — NOT from individual glyph bboxes.
    ascent, descent = font.getmetrics()
    advance = round(font.getlength("M"))  # monospace: all glyphs share one advance width

    cell_w = advance + 2 * PADDING
    cell_h = ascent + descent + 2 * PADDING

    # Charset: 32..=255, 224 chars, 16 cols × 14 rows
    # Code points 0x80-0x9F are substituted with box-drawing/block chars (C1_SUBSTITUTES).
    chars = [C1_SUBSTITUTES.get(c, chr(c)) for c in range(ASCII_START, ASCII_END + 1)]
    rows = math.ceil(len(chars) / COLUMNS)

    atlas = Image.new("RGBA", (cell_w * COLUMNS, cell_h * rows), (0, 0, 0, 0))
    white_layer = Image.new("RGBA", (cell_w, cell_h), (255, 255, 255, 255))

    for idx, ch in enumerate(chars):
        col = idx % COLUMNS
        row = idx // COLUMNS
        cell_x = col * cell_w
        cell_y = row * cell_h

        # 1-bit mode: Pillow disables FreeType AA when destination is mode '1'.
        # Result: pixel-exact bilevel rendering — no antialias, no subpixel blending.
        cell_1bit = Image.new("1", (cell_w, cell_h), 0)
        ImageDraw.Draw(cell_1bit).text((PADDING, PADDING), ch, font=font, fill=1)
        cell_mask = cell_1bit.convert("L")
        atlas.paste(white_layer, (cell_x, cell_y), cell_mask)

    atlas.save(output_path)

    return {
        "pt_size": pt_size,
        "pixel_size": pixel_size,
        "style": style,
        "file_name": output_path.name,
        "cell_width": cell_w,
        "cell_height": cell_h,
        "cols_per_row": COLUMNS,
        "ascii_start": ASCII_START,
        "ascii_end": ASCII_END,
        "rows": rows,
    }


def main() -> None:
    from argparse import RawDescriptionHelpFormatter
    epilog = """
Examples:
  # Default execution
  python tools/assets/gen_courier_new_bitmap_fonts.py

  # Show all arguments
  python tools/assets/gen_courier_new_bitmap_fonts.py --help
"""
    parser = argparse.ArgumentParser(
        description="Lurek2D Tool",
        epilog=epilog,
        formatter_class=RawDescriptionHelpFormatter
    )
    parser.add_argument("--font-path", type=str, default=None,
                        help="Path to Courier New regular .ttf (cour.ttf)")
    parser.add_argument("--bold-path", type=str, default=None,
                        help="Path to Courier New Bold .ttf (courbd.ttf)")
    parser.add_argument("--sizes", type=int, nargs="+", default=DEFAULT_SIZES)
    parser.add_argument("--output-dir", type=Path, default=Path("assets/fonts"))
    parser.add_argument("--metadata", type=Path,
                        default=Path("assets/fonts/bitmap_fonts.json"))
    args = parser.parse_args()

    regular_path = find_font(args.font_path, DEFAULT_FONT_PATHS, "Courier New regular")
    bold_path = find_font(args.bold_path, DEFAULT_BOLD_PATHS, "Courier New bold")
    args.output_dir.mkdir(parents=True, exist_ok=True)

    metadata: dict = {}

    print("Regular:")
    for pt_size in args.sizes:
        out = args.output_dir / f"font_{pt_size}.png"
        entry = render_bitmap(regular_path, pt_size, out, style="regular")
        metadata[f"font_{pt_size}"] = entry
        print(f"  {out.name}  pt={pt_size} px={entry['pixel_size']} cell={entry['cell_width']}x{entry['cell_height']}")

    print("Bold:")
    for pt_size in args.sizes:
        out = args.output_dir / f"fontb_{pt_size}.png"
        entry = render_bitmap(bold_path, pt_size, out, style="bold")
        metadata[f"fontb_{pt_size}"] = entry
        print(f"  {out.name}  pt={pt_size} px={entry['pixel_size']} cell={entry['cell_width']}x{entry['cell_height']}")

    args.metadata.parent.mkdir(parents=True, exist_ok=True)
    with args.metadata.open("w", encoding="utf-8") as fh:
        json.dump(metadata, fh, indent=2)
    print(f"Metadata: {args.metadata}")


if __name__ == "__main__":
    main()
