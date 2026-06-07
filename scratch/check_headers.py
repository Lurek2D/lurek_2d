import os
from pathlib import Path

render_dir = Path("src/render")
output_lines = []
for path in sorted(render_dir.glob("*.rs")):
    content = path.read_text(encoding="utf-8")
    lines = content.splitlines()
    header = []
    for line in lines:
        if line.startswith("//") or line.strip() == "":
            header.append(line)
        else:
            break
    output_lines.append(f"=== {path.name} ({len(lines)} LOC) ===")
    for idx, line in enumerate(header[:20]):
        output_lines.append(f"{idx+1:2}: {line}")
    output_lines.append("")

Path("scratch/headers_report.txt").write_text("\n".join(output_lines), encoding="utf-8")
print("Done writing to scratch/headers_report.txt")
