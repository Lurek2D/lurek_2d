import sys

# 1. Fix gpu_resources.rs imports
with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_resources.rs", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace("use slotmap::SparseSecondaryMap;", "use slotmap::SlotMap;", 1)

with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_resources.rs", "w", encoding="utf-8") as f:
    f.write(content)
print("gpu_resources.rs imports corrected.")


# 2. Fix gpu_tess.rs imports (remove blend_state_for)
with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_tess.rs", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace(
    "use crate::render::gpu_pipeline::{GeometryKind, GpuStencilMode, blend_state_for};",
    "use crate::render::gpu_pipeline::{GeometryKind, GpuStencilMode};",
    1
)

with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_tess.rs", "w", encoding="utf-8") as f:
    f.write(content)
print("gpu_tess.rs imports corrected.")
