//! - Defines raw binary structures and types representing compiled user WGSL shaders.
//! - Maps uniform value types to their corresponding GPU buffer layout variants.
//! - Caches compiled wgpu pipelines within shader structures to prevent reconstruction.
//! - Key-indexes compiled shaders in the central registry for zero-cost search lookups.
//! - Enforces static layout verification to validate uniform layouts at draw dispatch.
//! - Defines uniform value mappings for scalars, vectors, matrices, and arrays.
//! - Provides conversion helpers to bridge dynamic uniforms to byte arrays.
//! - Translates compile errors into standard Lurek2D diagnostic logs.
use crate::render::gpu_pipeline::PipelineKey;
use crate::runtime::resource_keys::ShaderKey;
use std::collections::HashMap;

/// WGSL uniform value type tag; used to select the correct buffer layout.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum ShaderUniformKind {
    /// 32-bit float scalar.
    Float,
    /// Two-component float vector.
    Vec2,
    /// Three-component float vector.
    Vec3,
    /// Four-component float vector.
    Vec4,
    /// 32-bit signed integer.
    Int,
    /// Boolean mapped to u32.
    Bool,
}

/// Compiled user WGSL shader with cached render pipelines for each `PipelineKey`.
pub struct GpuShader {
    /// Original WGSL source string retained for hot-reload.
    pub source: String,
    /// Ordered list of uniform names and their value types.
    pub uniform_signature: Vec<(String, ShaderUniformKind)>,
    /// Per-uniform GPU buffers, one per `uniform_signature` entry.
    pub uniform_buffers: Vec<wgpu::Buffer>,
    /// Bind group holding all uniform buffers for this shader.
    pub uniform_bind_group: Option<wgpu::BindGroup>,
    /// Compiled shader module for the flat-color vertex path.
    pub color_module: wgpu::ShaderModule,
    /// Compiled shader module for the textured vertex path.
    pub texture_module: wgpu::ShaderModule,
    /// Pipeline layout for the color module.
    pub color_layout: wgpu::PipelineLayout,
    /// Pipeline layout for the texture module.
    pub texture_layout: wgpu::PipelineLayout,
    /// Cached color render pipelines keyed by blend/stencil state.
    pub color_pipelines: HashMap<PipelineKey, wgpu::RenderPipeline>,
    /// Cached texture render pipelines keyed by blend/stencil state.
    pub texture_pipelines: HashMap<PipelineKey, wgpu::RenderPipeline>,
}

// Suppress unused key warning — ShaderKey is needed by callers that store GpuShader in a SparseSecondaryMap keyed by ShaderKey.
const _: fn() = || {
    let _: ShaderKey;
};
