import json
from pathlib import Path
from PIL import Image

FONTS_DIR = Path("assets/fonts")
with open(FONTS_DIR / "courier_new_bitmap_fonts.json") as f:
    data = json.load(f)

for key, entry in data.items():
    path = FONTS_DIR / entry["file_name"]
    img = Image.open(path).convert("RGBA")
    w, h = img.size
    cw, ch = entry["cell_width"], entry["cell_height"]
    cols = entry["cols_per_row"]
    num_chars = entry["ascii_end"] - entry["ascii_start"] + 1
    pixels = img.load()

    total_nonzero = 0
    empty_cells = 0
    for idx in range(num_chars):
        col = idx % cols
        row = idx // cols
        x0, y0 = col * cw, row * ch
        cell_px = 0
        for y in range(y0, min(y0 + ch, h)):
            for x in range(x0, min(x0 + cw, w)):
                r, g, b, a = pixels[x, y]
                if max(r, a) > 0:
                    cell_px += 1
                    total_nonzero += 1
        if cell_px == 0:
            ch_code = entry["ascii_start"] + idx
            if chr(ch_code) not in (" ",):
                empty_cells += 1

    boundary_violation = 0
    for idx in range(num_chars):
        col = idx % cols
        row = idx // cols
        x_edge = (col + 1) * cw - 1
        y0 = row * ch
        for y in range(y0, min(y0 + ch, h)):
            if x_edge < w:
                r, g, b, a = pixels[x_edge, y]
                if max(r, a) > 0:
                    boundary_violation += 1

    print(f"{entry['file_name']}: atlas={w}x{h} cell={cw}x{ch} nonzero_px={total_nonzero} empty_nonspace={empty_cells} edge_viol={boundary_violation}")

    # Print 'A' glyph (index 33)
    idx = 33
    col, row = idx % cols, idx // cols
    x0, y0 = col * cw, row * ch
    print(f"  'A' ({x0},{y0})-({x0+cw},{y0+ch}):")
    for y in range(y0, min(y0 + ch, h)):
        row_s = ""
        for x in range(x0, min(x0 + cw, w)):
            r, g, b, a = pixels[x, y]
            val = max(r, a)
            row_s += "#" if val > 128 else ("." if val > 0 else " ")
        print(f"    |{row_s}|")
