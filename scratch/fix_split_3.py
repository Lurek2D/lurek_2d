import sys

# 1. Update imports in gpu_renderer.rs
with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_renderer.rs", "r", encoding="utf-8") as f:
    r_content = f.read()

old_tess_imports = """use crate::render::gpu_tess::{
    append_color_draw, append_tex_draw, normalize_scissor,
    shader_for_draw,
};"""

new_tess_imports = """use crate::render::gpu_tess::{
    append_color_draw, append_tex_draw, normalize_scissor,
    shader_for_draw, push_tex_quad_corners, apply, uniform_kind, uniform_bytes,
};"""

r_content = r_content.replace(old_tess_imports, new_tess_imports, 1)

with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_renderer.rs", "w", encoding="utf-8") as f:
    f.write(r_content)
print("gpu_renderer.rs imports updated.")


# 2. Update imports in gpu_resources.rs
with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_resources.rs", "r", encoding="utf-8") as f:
    res_content = f.read()

# We need:
# - SlotMap from slotmap
# - ColorVertex, TexVertex from crate::render::gpu_types
# - parse_filter_mode from crate::render::gpu_tess
extra_res_imports = """use slotmap::SlotMap;
use crate::render::gpu_types::{ColorVertex, TexVertex};
use crate::render::gpu_tess::parse_filter_mode;
"""

res_content = res_content.replace(
    "use slotmap::SparseSecondaryMap;",
    "use slotmap::{SlotMap, SparseSecondaryMap};\n" + extra_res_imports,
    1
)

with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_resources.rs", "w", encoding="utf-8") as f:
    f.write(res_content)
print("gpu_resources.rs imports updated.")
