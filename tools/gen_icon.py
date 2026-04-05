#!/usr/bin/env python3
"""
gen_icon.py — Generate assets/icon.ico (and .png) for the Luna2D engine.

Usage:
    python tools/gen_icon.py              # writes assets/icon.ico + assets/icon.png
    python tools/gen_icon.py --ico custom.ico --png custom.png

The .ico file is embedded into luna2d.exe on Windows via build.rs + winresource.
The .png is a 256×256 high-resolution source kept alongside it.

Requires:  pip install Pillow
"""

from __future__ import annotations

import argparse
import math
import os
import sys
from pathlib import Path

try:
    from PIL import Image, ImageDraw
    HAVE_PILLOW = True
except ImportError:
    HAVE_PILLOW = False

WORKSPACE = Path(__file__).resolve().parent.parent
ICO_OUTPUT = WORKSPACE / "assets" / "icon.ico"
PNG_OUTPUT = WORKSPACE / "assets" / "icon.png"


def lerp_color(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(4))


def build_mark_points(
    cx: float,
    cy: float,
    inner_r: float,
    outer_r: float,
    mouth_half: float,
    num_teeth: int,
    tooth_width: float = 0.45,
) -> list[tuple[float, float]]:
    tooth_period = math.tau / num_teeth
    steps = num_teeth * 20
    points = [(cx, cy)]

    for i in range(steps + 1):
        angle = mouth_half + (math.tau - 2 * mouth_half) * i / steps
        phase = (angle % tooth_period) / tooth_period
        radius = outer_r if phase < tooth_width else inner_r
        points.append((cx + radius * math.cos(angle), cy + radius * math.sin(angle)))

    return points


def draw_cube(draw: ImageDraw.ImageDraw, cx: float, cy: float, size: float) -> None:
    draw.polygon(
        [(cx, cy - size), (cx + size, cy - size * 0.5), (cx, cy), (cx - size, cy - size * 0.5)],
        fill=(120, 182, 242, 255),
    )
    draw.polygon(
        [(cx - size, cy - size * 0.5), (cx, cy), (cx, cy + size), (cx - size, cy + size * 0.5)],
        fill=(77, 135, 210, 255),
    )
    draw.polygon(
        [(cx, cy), (cx + size, cy - size * 0.5), (cx + size, cy + size * 0.5), (cx, cy + size)],
        fill=(44, 93, 168, 255),
    )


def generate_icon_image(size: int) -> Image.Image:
    """Draw a single icon frame: the latest Luna mark eating the incoming cube."""
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img, "RGBA")

    s = float(size)
    px = s * 0.39
    py = s * 0.50
    gear_inner = s * 0.30
    gear_outer = s * 0.38

    draw_cube(d, px + s * 0.45, py - s * 0.03, s * 0.08)
    d.polygon(
        build_mark_points(px, py, gear_inner, gear_outer, math.radians(36), 12),
        fill=(142, 200, 232, 255),
    )

    cutout_x = px + s * 0.11
    cutout_y = py - s * 0.02
    cutout_r = s * 0.24
    d.ellipse(
        [cutout_x - cutout_r, cutout_y - cutout_r, cutout_x + cutout_r, cutout_y + cutout_r],
        fill=(30, 10, 64, 255),
    )

    eye_x = px - s * 0.06
    eye_y = py - s * 0.15
    eye_r = max(1.0, s * 0.04)
    d.ellipse(
        [eye_x - eye_r, eye_y - eye_r, eye_x + eye_r, eye_y + eye_r],
        fill=(22, 12, 48, 255),
    )

    return img


def generate_icon(ico_path: Path, png_path: Path) -> None:
    print("Generating Luna2D icon …")
    ico_path.parent.mkdir(parents=True, exist_ok=True)
    png_path.parent.mkdir(parents=True, exist_ok=True)

    # ICO sizes: Windows needs 16, 32, 48, 256
    ico_sizes = [16, 32, 48, 256]
    frames = [generate_icon_image(sz) for sz in ico_sizes]

    # Save ICO (Pillow uses the first image's format)
    frames[0].save(
        str(ico_path),
        format="ICO",
        sizes=[(sz, sz) for sz in ico_sizes],
        append_images=frames[1:],
    )
    print(f"  Written {ico_path}")

    # Save high-res PNG
    frames[-1].save(str(png_path), "PNG")
    print(f"  Written {png_path}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--ico", default=str(ICO_OUTPUT), metavar="FILE",
                        help=f"ICO output path (default: {ICO_OUTPUT})")
    parser.add_argument("--png", default=str(PNG_OUTPUT), metavar="FILE",
                        help=f"PNG output path (default: {PNG_OUTPUT})")
    args = parser.parse_args()

    if not HAVE_PILLOW:
        print("ERROR: Pillow is not installed.", file=sys.stderr)
        print("  Install it with:  pip install Pillow", file=sys.stderr)
        return 1

    generate_icon(Path(args.ico), Path(args.png))
    print("Done. Re-build the project — the .ico will be embedded via build.rs.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
