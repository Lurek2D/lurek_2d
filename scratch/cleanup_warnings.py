import sys

# 1. Clean gpu_renderer.rs imports
with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_renderer.rs", "r", encoding="utf-8") as f:
    content = f.read()

# Replace imports on line 19:
content = content.replace(
    "use crate::render::shader::{Shader, ShaderFragmentInput, UniformValue};",
    "use crate::render::shader::Shader;",
    1
)

# Replace lines 34-36
old_types = """use crate::render::gpu_types::{
    ColorVertex, TexVertex, LightVertex, ShadowEdgeGpu, ShadowComputeParams,
    ShadowDispatchInput, ViewportUniform, TexRef, MAX_COLOR_VERTS, MAX_COLOR_IDXS,
    MAX_TEX_VERTS, MAX_TEX_IDXS, MAX_LIGHT_QUADS, ScissorRect, RenderTargetId, PreparedDraw,
};"""
new_types = """use crate::render::gpu_types::{
    ColorVertex, TexVertex, LightVertex,
    ShadowDispatchInput, ViewportUniform, TexRef, MAX_COLOR_VERTS, MAX_COLOR_IDXS,
    MAX_TEX_VERTS, MAX_TEX_IDXS, MAX_LIGHT_QUADS, RenderTargetId, PreparedDraw,
};"""
content = content.replace(old_types, new_types, 1)

# Replace line 39
content = content.replace(
    "use crate::render::gpu_state::{GpuTexture, DepthStencilTarget, PendingSurfaceReadback, RenderStats};",
    "use crate::render::gpu_state::{PendingSurfaceReadback, RenderStats};",
    1
)

# Replace line 40
content = content.replace(
    "use crate::render::gpu_pipeline::{PipelineKey, GpuStencilMode, GeometryKind, PipelineSelectionKey, blend_state_for};",
    "use crate::render::gpu_pipeline::{PipelineKey, GpuStencilMode, GeometryKind, PipelineSelectionKey};",
    1
)

# Replace line 41
content = content.replace(
    "use crate::render::gpu_light::{LightGpuState, SHADOW_MAP_RES, MAX_SHADOW_LIGHTS, SHADOW_COMPUTE_WORKGROUP_SIZE};",
    "use crate::render::gpu_light::{SHADOW_MAP_RES, MAX_SHADOW_LIGHTS};",
    1
)

# Replace line 47
old_tess = """use crate::render::gpu_tess::{
    append_color_draw, append_tex_draw, normalize_scissor,
    shader_for_draw, push_tex_quad_corners, apply, uniform_kind, uniform_bytes,
    color_write_mask_bits, color_write_mask_from_bits, push_quad_verts, push_tex_quad, push_thick_line,
};"""
new_tess = """use crate::render::gpu_tess::{
    append_color_draw, append_tex_draw, normalize_scissor,
    shader_for_draw, push_tex_quad_corners, apply, uniform_kind, uniform_bytes,
    color_write_mask_bits, push_quad_verts, push_tex_quad, push_thick_line,
};"""
content = content.replace(old_tess, new_tess, 1)

# Remove unused imports of collect_shadow_edges and depth_stencil_state
content = content.replace("use crate::render::gpu_shadows::collect_shadow_edges;\n", "", 1)
content = content.replace(
    "use crate::render::gpu_pipeline::{\n    create_render_pipeline, depth_stencil_state, build_custom_color_shader_source,\n    build_custom_texture_shader_source,\n};",
    "use crate::render::gpu_pipeline::{\n    create_render_pipeline, build_custom_color_shader_source,\n    build_custom_texture_shader_source,\n};",
    1
)

with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_renderer.rs", "w", encoding="utf-8") as f:
    f.write(content)
print("gpu_renderer.rs warnings cleaned.")


# 2. Clean gpu_tess.rs imports
with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_tess.rs", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace(
    "use crate::render::gpu_pipeline::{GeometryKind, GpuStencilMode, blend_state_for, PipelineKey, PipelineSelectionKey};",
    "use crate::render::gpu_pipeline::{GeometryKind, GpuStencilMode, blend_state_for};",
    1
)
content = content.replace(
    "use crate::render::shader::{Shader, ShaderFragmentInput, UniformValue};",
    "use crate::render::shader::UniformValue;",
    1
)
content = content.replace(
    "use crate::runtime::resource_keys::{ShaderKey, CanvasKey, FontKey};",
    "use crate::runtime::resource_keys::ShaderKey;",
    1
)

with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_tess.rs", "w", encoding="utf-8") as f:
    f.write(content)
print("gpu_tess.rs warnings cleaned.")


# 3. Clean gpu_resources.rs imports
with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_resources.rs", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace(
    "use crate::render::gpu_state::{GpuTexture, DepthStencilTarget, RenderStats};",
    "use crate::render::gpu_state::{GpuTexture, DepthStencilTarget};",
    1
)
content = content.replace(
    "use crate::render::gpu_types::{TexRef, RenderTargetId};",
    "",
    1
)
content = content.replace("use crate::log_msg;\n", "", 1)
content = content.replace("use slotmap::{SlotMap, SparseSecondaryMap};\n", "use slotmap::SparseSecondaryMap;\n", 1)

with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_resources.rs", "w", encoding="utf-8") as f:
    f.write(content)
print("gpu_resources.rs warnings cleaned.")


# 4. Clean gpu_shadows.rs imports
with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_shadows.rs", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace("use std::sync::mpsc;\n", "", 1)

with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_shadows.rs", "w", encoding="utf-8") as f:
    f.write(content)
print("gpu_shadows.rs warnings cleaned.")
