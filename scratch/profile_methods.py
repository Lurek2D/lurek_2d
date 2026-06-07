import sys

with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_renderer.rs", "r", encoding="utf-8") as f:
    lines = f.readlines()

impl_line = -1
for idx, line in enumerate(lines):
    if "impl GpuRenderer {" in line:
        impl_line = idx
        break

print(f"impl GpuRenderer starts at line {impl_line+1}")

methods = []
current_method = None
brace_count = 0
in_impl = False

for idx, line in enumerate(lines):
    if idx < impl_line:
        continue
    if "impl GpuRenderer {" in line:
        in_impl = True
        brace_count = 1
        continue
    if not in_impl:
        continue
    
    if brace_count == 1 and ("fn " in line) and ("(" in line):
        if current_method:
            methods.append(current_method)
        name = line.split("fn ")[1].split("(")[0].strip()
        current_method = {"name": name, "start": idx + 1}
        
    for char in line:
        if char == "{":
            brace_count += 1
        elif char == "}":
            brace_count -= 1
            if brace_count == 1 and current_method:
                current_method["end"] = idx + 1
                methods.append(current_method)
                current_method = None
            elif brace_count == 0:
                in_impl = False
                break

for m in methods:
    if "end" in m:
        print(f"{m['name']}: lines {m['start']}-{m['end']} ({m['end'] - m['start'] + 1} lines)")
    else:
        print(f"{m['name']}: lines {m['start']}-EOF")
