import sys
import re

# Read current gpu_renderer.rs
with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_renderer.rs", "r", encoding="utf-8") as f:
    orig_lines = f.readlines()

# Let's define the line indices (0-based) for extractions based on profile_methods output:
# impl GpuRenderer starts at line 320 (index 319)
#
# Methods to move to gpu_resources.rs:
# - grow_capacity: 483-492 (idx 482-491)
# - ensure_geometry_buffer_capacity: 494-553 (idx 493-552)
# - create_sampler: 555-573 (idx 554-572)
# - create_texture_bind_group: 575-595 (idx 574-594)
# - create_gpu_texture_raw: 597-648 (idx 596-647)
# - upload_texture: 650-661 (idx 649-660)
# - ensure_font_atlas: 663-682 (idx 662-681)
# - create_canvas: 684-719 (idx 683-718)
# - create_depth_stencil_target: 721-748 (idx 720-747)
# - ensure_screen_stencil_target: 750-763 (idx 749-762)
# - ensure_canvas_stencil_target: 765-777 (idx 764-776)
# - prune_released_resources: 779-824 (idx 778-823)
#
# Methods to move to gpu_shadows.rs:
# - ensure_light_resources: 826-1144 (idx 825-1143)
# - ensure_shadow_edge_capacity: 1146-1181 (idx 1145-1180)
# - dispatch_shadow_map_gpu: 1183-1225 (idx 1182-1224)
# - aabb_visible_2d: 1229-1267 (idx 1228-1266)
#
# Methods to move to gpu_tess.rs:
# - tess_rect: 4763-4793 (idx 4762-4792)
# - tess_rounded_rect: 4796-4828 (idx 4795-4827)
# - tess_ellipse: 4831-4883 (idx 4830-4882)
# - tess_triangle: 4886-4919 (idx 4885-4918)
# - tess_polygon: 4922-4967 (idx 4921-4966)
# - tess_arc: 4970-5023 (idx 4969-5022)

# Free functions to move to gpu_tess.rs (lines 5025 to 5209 idx 5024 to 5208)
# - append_color_draw
# - append_tex_draw
# - normalize_scissor
# - color_write_mask_bits
# - color_write_mask_from_bits
# - shader_for_draw
# - parse_filter_mode
# - uniform_kind
# - uniform_bytes
# - apply
# - push_thick_line
# - push_quad_verts
# - push_fan_fill
# - build_rounded_rect_path
# - push_tex_quad
# - push_tex_quad_corners

# Free functions to move to gpu_pipeline.rs:
# - uniform_wgsl_type
# - custom_uniform_declarations
# - custom_fragment_call_args
# - build_custom_color_shader_source
# - build_custom_texture_shader_source
# - create_render_pipeline
# - depth_stencil_state
# - stencil_face_state
# - compare_function
# - stencil_operation

def extract_range(start_1based, end_1based):
    return "".join(orig_lines[start_1based-1 : end_1based])

resources_code = (
    extract_range(483, 492) + "\n" +
    extract_range(494, 553) + "\n" +
    extract_range(555, 573) + "\n" +
    extract_range(575, 595) + "\n" +
    extract_range(597, 648) + "\n" +
    extract_range(650, 661) + "\n" +
    extract_range(663, 682) + "\n" +
    extract_range(684, 719) + "\n" +
    extract_range(721, 748) + "\n" +
    extract_range(750, 763) + "\n" +
    extract_range(765, 777) + "\n" +
    extract_range(779, 824)
)

shadows_code = (
    extract_range(826, 1144) + "\n" +
    extract_range(1146, 1181) + "\n" +
    extract_range(1183, 1225) + "\n" +
    extract_range(1229, 1267)
)

tess_code = (
    extract_range(4761, 5024) + "\n" + # contains all tess_ methods
    extract_range(5025, 5198) + "\n" + # contains free functions up to uniform_bytes
    extract_range(5521, 5691)          # contains apply, push_thick_line, etc.
)

pipeline_code = (
    extract_range(5199, 5520) # contains uniform_wgsl_type up to stencil_operation
)

# Let's write the new files:
# 1. gpu_resources.rs
with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_resources.rs", "w", encoding="utf-8") as f:
    f.write('''//! This file manages persistent GPU resource lifetimes, allocations, and buffer uploads.
//! Dynamic capacity adjustment handles growing vertex/index buffers under heavy draw-call counts.
//! Slotmap registration caches textures, fonts, and canvases synchronously for main render passes.
//! Resource pruning runs automatically between frames to release dead texture and canvas resources.

use crate::runtime::resource_keys::{TextureKey, FontKey, CanvasKey};
use crate::render::gpu_state::{GpuTexture, DepthStencilTarget, RenderStats};
use crate::render::gpu_types::{TexRef, RenderTargetId};
use crate::render::renderer::TextureData;
use crate::log_msg;
use slotmap::SparseSecondaryMap;
use super::GpuRenderer;

impl GpuRenderer {
''')
    f.write(resources_code)
    f.write("}\n")

# 2. gpu_shadows.rs
with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_shadows.rs", "w", encoding="utf-8") as f:
    f.write('''//! This file manages 1-D shadow map rendering, dynamic light lists, and compute dispatches.
//! Occluder geometry is gathered and transformed into a dedicated GPU-side edge storage buffer.
//! The shadow compute shader is dispatched per active light source to write distances into the atlas.
//! Viewport-space visibility checks cull light regions before any rendering commands are queued.

use crate::render::gpu_types::{ShadowEdgeGpu, ShadowComputeParams, ShadowDispatchInput};
use crate::render::gpu_light::{LightGpuState, SHADOW_MAP_RES, SHADOW_COMPUTE_WORKGROUP_SIZE};
use crate::light::occluder::Occluder;
use std::sync::mpsc;
use super::GpuRenderer;

pub(crate) fn collect_shadow_edges(
    light_x: f32,
    light_y: f32,
    shadow_mask: u16,
    occluders: impl IntoIterator<Item = impl std::borrow::Borrow<Occluder>>,
) -> Vec<ShadowEdgeGpu> {
    let mut edges = Vec::new();
    for occ_ref in occluders {
        let occ = occ_ref.borrow();
        if !occ.enabled {
            continue;
        }
        if occ.light_mask & shadow_mask == 0 {
            continue;
        }
        let verts = occ.get_vertices();
        let n = verts.len();
        if n < 2 {
            continue;
        }
        for j in 0..n {
            let a = verts[j];
            let b = verts[(j + 1) % n];
            let ax = a.x + occ.position.x - light_x;
            let ay = a.y + occ.position.y - light_y;
            let bx = b.x + occ.position.x - light_x;
            let by = b.y + occ.position.y - light_y;
            edges.push(ShadowEdgeGpu {
                ax,
                ay,
                sx: bx - ax,
                sy: by - ay,
            });
        }
    }
    edges
}

impl GpuRenderer {
''')
    f.write(shadows_code)
    f.write("}\n")

# 3. gpu_tess.rs
with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_tess.rs", "w", encoding="utf-8") as f:
    f.write('''//! This file tessellates 2D vector shapes, text glyphs, and sprite quads into triangle lists.
//! Stroke thick-lines are expanded to rectangular quads to solve native GPU line-width limitations.
//! Circle and ellipse vertex counts adapt to screen-space radii to prevent excessive vertex pressure.
//! Textured quad utilities pack position, UV coords, tints, and perspective-correct depth values.

use crate::math::{Mat3, Vec2};
use crate::render::gpu_types::{ColorVertex, TexVertex, TexRef, ScissorRect, RenderTargetId, PreparedDraw};
use crate::render::gpu_pipeline::{GeometryKind, GpuStencilMode, blend_state_for, PipelineKey, PipelineSelectionKey};
use crate::render::gpu_shaders::ShaderUniformKind;
use crate::render::renderer::{BlendMode, DrawMode};
use crate::render::shader::{Shader, ShaderFragmentInput, UniformValue};
use crate::runtime::resource_keys::{ShaderKey, CanvasKey, FontKey};
use std::f32::consts::PI;
use super::GpuRenderer;

impl GpuRenderer {
''')
    f.write(tess_code)
    f.write("\n")

# 4. Append to gpu_pipeline.rs
# First read the existing content of gpu_pipeline.rs
with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_pipeline.rs", "r", encoding="utf-8") as f:
    pipeline_orig = f.read()

# Let's add imports to gpu_pipeline.rs and append the code.
# The original file has:
# use crate::render::renderer::{BlendMode};
# use crate::runtime::resource_keys::ShaderKey;
# We need to add:
# use crate::render::gpu_types::{ColorVertex, TexVertex};
# use crate::render::shader::{Shader, ShaderFragmentInput};
# use crate::render::gpu_shaders::ShaderUniformKind;
additional_imports = '''
use crate::render::gpu_types::{ColorVertex, TexVertex};
use crate::render::shader::{Shader, ShaderFragmentInput};
use crate::render::gpu_shaders::ShaderUniformKind;
'''
pipeline_new_content = pipeline_orig.replace("use crate::runtime::resource_keys::ShaderKey;", "use crate::runtime::resource_keys::ShaderKey;" + additional_imports, 1)
pipeline_new_content += "\n" + pipeline_code

with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_pipeline.rs", "w", encoding="utf-8") as f:
    f.write(pipeline_new_content)

print("Split files created successfully.")
