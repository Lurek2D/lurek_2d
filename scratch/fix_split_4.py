import sys

# 1. Update imports in gpu_renderer.rs to add PI and more tess functions
with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_renderer.rs", "r", encoding="utf-8") as f:
    content = f.read()

# Add std::f32::consts::PI
content = content.replace(
    "use std::time::Instant;",
    "use std::time::Instant;\nuse std::f32::consts::PI;",
    1
)

# Expand use crate::render::gpu_tess::{...} to include:
# color_write_mask_bits, color_write_mask_from_bits, push_quad_verts, push_tex_quad, push_thick_line
old_tess = """use crate::render::gpu_tess::{
    append_color_draw, append_tex_draw, normalize_scissor,
    shader_for_draw, push_tex_quad_corners, apply, uniform_kind, uniform_bytes,
};"""

new_tess = """use crate::render::gpu_tess::{
    append_color_draw, append_tex_draw, normalize_scissor,
    shader_for_draw, push_tex_quad_corners, apply, uniform_kind, uniform_bytes,
    color_write_mask_bits, color_write_mask_from_bits, push_quad_verts, push_tex_quad, push_thick_line,
};"""

content = content.replace(old_tess, new_tess, 1)

with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_renderer.rs", "w", encoding="utf-8") as f:
    f.write(content)

print("gpu_renderer.rs imports updated with PI and additional helper functions.")
