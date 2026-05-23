"""Quick check: verify that atlas slots 0x80-0x9F contain non-zero pixels.

Usage:
```
Usage:
    python tools/assets/_check_box_slots.py
```
"""
import json
from PIL import Image

with open("assets/fonts/bitmap_fonts.json") as f:
    meta = json.load(f)

entry = meta["font_12"]
fname = entry["file_name"]
img = Image.open(f"assets/fonts/{fname}").convert("L")
cw = entry["cell_width"]
ch = entry["cell_height"]
cols = entry["cols_per_row"]

SUBS = {
    0x80:"─",0x81:"│",0x82:"┌",0x83:"┐",0x84:"└",0x85:"┘",0x86:"├",0x87:"┤",
    0x88:"┬",0x89:"┴",0x8A:"┼",0x8B:"═",0x8C:"║",0x8D:"╔",0x8E:"╗",0x8F:"╚",
    0x90:"╝",0x91:"╠",0x92:"╣",0x93:"╦",0x94:"╩",0x95:"╬",0x96:"░",0x97:"▒",
    0x98:"▓",0x99:"█",0x9A:"▀",0x9B:"▄",0x9C:"▲",0x9D:"▼",0x9E:"◄",0x9F:"►",
}

print(f"Atlas: {fname}  cell={cw}x{ch}")
print("Slot   CP    Char  Nonzero_px")
all_ok = True
for slot in range(96, 128):
    cp = 0x20 + slot
    col = slot % cols
    row = slot // cols
    x0, y0 = col * cw, row * ch
    cell = img.crop((x0, y0, x0 + cw, y0 + ch))
    nz = sum(1 for p in cell.getdata() if p > 0)
    ch_str = SUBS.get(cp, "?")
    ok = "OK" if nz > 0 else "EMPTY!"
    if nz == 0:
        all_ok = False
    print(f"  {slot:3d}  0x{cp:02X}  {ch_str}    {nz:4d}  {ok}")

print()
print("All slots non-empty:", all_ok)
