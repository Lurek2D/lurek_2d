import sys

with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_pipeline.rs", "r", encoding="utf-8") as f:
    content = f.read()

# Let's find #[inline] at the end of the file and truncate everything from there.
inline_idx = content.rfind("/// Transform a point by a `Mat3` and return the screen-space `(x, y)` pair.")
if inline_idx != -1:
    content = content[:inline_idx]
    print("gpu_pipeline.rs truncated successfully.")
else:
    # Fallback to lines truncation
    lines = content.splitlines()
    if len(lines) > 428:
        content = "\n".join(lines[:428]) + "\n"
        print("gpu_pipeline.rs truncated by lines.")

with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_pipeline.rs", "w", encoding="utf-8") as f:
    f.write(content)
