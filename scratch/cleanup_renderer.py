import sys

with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_renderer.rs", "r", encoding="utf-8") as f:
    orig_lines = f.readlines()

def extract_range(start_1based, end_1based):
    return "".join(orig_lines[start_1based-1 : end_1based])

# Make fields of GpuRenderer pub(crate)
# Let's inspect GpuRenderer fields. GpuRenderer is defined in lines 213-282 (0-indexed 212-281).
gpu_renderer_struct = orig_lines[212:282]
gpu_renderer_struct_new = []
for line in gpu_renderer_struct:
    sline = line.strip()
    if sline.startswith("pub struct GpuRenderer") or sline.startswith("impl") or sline.startswith("}") or sline.startswith("///") or sline.startswith("#["):
        gpu_renderer_struct_new.append(line)
    elif sline:
        # It's a field
        if not sline.startswith("pub") and not sline.startswith("pub(crate)"):
            # make it pub(crate)
            # Find indentation
            indent = line[:len(line) - len(line.lstrip())]
            gpu_renderer_struct_new.append(f"{indent}pub(crate) {sline}\n")
        else:
            gpu_renderer_struct_new.append(line)
    else:
        gpu_renderer_struct_new.append(line)

# Let's check imports
# We want to replace lines 12 to 43 (0-indexed 11 to 42) with clean explicit imports
new_imports = '''use crate::log_msg;
use crate::math::{Mat3, Vec2};
use crate::render::mesh::Mesh;
use crate::render::renderer::{
    adaptive_circle_ellipse_segments, BevelStyle, BlendMode, DrawMode, GradientDirection,
    HexOrientation, ParticleRenderShape, PathSegment, RenderCommand, TextAlign, TextureData,
};
use crate::render::shader::{Shader, ShaderFragmentInput, UniformValue};
use crate::runtime::log_messages::{
    G002_SCREENSHOT_ZERO_SIZE, G003_SCREENSHOT_MAP_FAIL, G004_SCREENSHOT_RECV_FAIL,
    G005_SCREENSHOT_DATA_FAIL,
};
use crate::runtime::resource_keys::{
    CanvasKey, FontKey, MeshKey, ShaderKey, SpriteBatchKey, TextureKey,
};
use slotmap::{SlotMap, SparseSecondaryMap};
use std::collections::{HashMap, HashSet};
use std::sync::mpsc;
use std::time::Instant;

use crate::render::gpu_types::{
    ColorVertex, TexVertex, LightVertex, ShadowEdgeGpu, ShadowComputeParams,
    ShadowDispatchInput, ViewportUniform, TexRef, MAX_COLOR_VERTS, MAX_COLOR_IDXS,
    MAX_TEX_VERTS, MAX_TEX_IDXS, MAX_LIGHT_QUADS, ScissorRect, RenderTargetId, PreparedDraw,
};
use crate::render::gpu_shaders::{GpuShader, ShaderUniformKind};
use crate::render::gpu_state::{GpuTexture, DepthStencilTarget, PendingSurfaceReadback, RenderStats};
use crate::render::gpu_pipeline::{PipelineKey, GpuStencilMode, GeometryKind, PipelineSelectionKey, blend_state_for};
use crate::render::gpu_light::{LightGpuState, SHADOW_MAP_RES, MAX_SHADOW_LIGHTS, SHADOW_COMPUTE_WORKGROUP_SIZE};

// Submodule helper imports
use crate::render::gpu_tess::{
    append_color_draw, append_tex_draw, normalize_scissor,
    shader_for_draw,
};
use crate::render::gpu_shadows::collect_shadow_edges;
use crate::render::gpu_pipeline::{
    create_render_pipeline, depth_stencil_state, build_custom_color_shader_source,
    build_custom_texture_shader_source,
};
'''

# Construct the cleaned gpu_renderer.rs
# 1. Header (up to index 11)
part1 = "".join(orig_lines[0:11])
# 2. Imports (replaced)
part2 = new_imports
# 3. WGSL Constants (index 43 to 211)
part3 = "".join(orig_lines[43:212])
# 4. GpuRenderer Struct (replaced with fields made pub(crate))
part4 = "".join(gpu_renderer_struct_new)
# 5. collect_shadow_edges and start of impl GpuRenderer (index 282 to 321)
part5 = "".join(orig_lines[282:321])
# 6. impl GpuRenderer - new and resize (index 321 to 481)
part6 = "".join(orig_lines[321:481])
# 7. impl GpuRenderer - render_frame and following (index 1269 to 4760)
part7 = "".join(orig_lines[1269:4760])
# 8. End of impl GpuRenderer (lines 5023-5024)
part8 = "}\n}\n"
# 9. Tests (index 5691 to end)
part9 = "".join(orig_lines[5691:])

cleaned_content = part1 + part2 + part3 + part4 + part5 + part6 + part7 + part8 + part9

with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_renderer.rs", "w", encoding="utf-8") as f:
    f.write(cleaned_content)

print("gpu_renderer.rs cleaned up and rewritten successfully.")
