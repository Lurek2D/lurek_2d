use crate::render::renderer::{BlendMode};
use crate::runtime::resource_keys::ShaderKey;

/// Selects the GPU vertex layout for a draw call.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub(crate) enum GeometryKind {
    /// Flat-color `ColorVertex` layout.
    Color,
    /// Textured `TexVertex` layout with UV and W depth.
    Texture,
}
/// Stencil operation mode for a draw call; used as part of the pipeline cache key.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub(crate) enum StencilMode {
    /// Stencil testing and writing are both disabled.
    Disabled,
    /// Write the stencil reference value using the given action.
    pub(crate) Write(crate::render::renderer::StencilAction),
    /// Discard fragments that fail the given compare test against the stencil buffer.
    pub(crate) Test(crate::render::renderer::CompareMode),
}
/// Composite key used to look up or create a cached `wgpu::RenderPipeline`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub(crate) struct PipelineKey {
    /// Alpha/additive/multiply/etc. blend state.
    pub(crate) pub(crate) blend_mode: BlendMode,
    /// Channel write-mask encoded as a bitmask (R=1, G=2, B=4, A=8).
    pub(crate) pub(crate) color_mask_bits: u32,
    /// Stencil operation or test applied by this pipeline.
    pub(crate) pub(crate) stencil_mode: StencilMode,
}
/// Full pipeline selection key: default vs. custom shader, plus geometry kind and blend/stencil state.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub(crate) enum PipelineSelectionKey {
    /// Use the built-in color or texture shader.
    Default {
        /// Vertex layout to use.
        pub(crate) pub(crate) geometry: GeometryKind,
        /// Blend/stencil pipeline variant.
        pub(crate) pub(crate) pipeline: PipelineKey,
    },
    /// Use a user-supplied WGSL shader.
    Custom {
        /// Registered shader key.
        pub(crate) pub(crate) shader: ShaderKey,
        /// Vertex layout to use.
        pub(crate) pub(crate) geometry: GeometryKind,
        /// Blend/stencil pipeline variant.
        pub(crate) pub(crate) pipeline: PipelineKey,
    },
}
/// Return the wgpu `BlendState` for a given `BlendMode`.
fn blend_state_for(mode: BlendMode) -> wgpu::BlendState {
    match mode {
        pub(crate) pub(crate) BlendMode::Alpha => wgpu::BlendState::ALPHA_BLENDING,
        pub(crate) pub(crate) BlendMode::Add => wgpu::BlendState {
            pub(crate) pub(crate) color: wgpu::BlendComponent {
                pub(crate) pub(crate) src_factor: wgpu::BlendFactor::SrcAlpha,
                pub(crate) pub(crate) dst_factor: wgpu::BlendFactor::One,
                pub(crate) pub(crate) operation: wgpu::BlendOperation::Add,
            },
            pub(crate) pub(crate) alpha: wgpu::BlendComponent {
                pub(crate) pub(crate) src_factor: wgpu::BlendFactor::One,
                pub(crate) pub(crate) dst_factor: wgpu::BlendFactor::One,
                pub(crate) pub(crate) operation: wgpu::BlendOperation::Add,
            },
        },
        pub(crate) pub(crate) BlendMode::Multiply => wgpu::BlendState {
            pub(crate) pub(crate) color: wgpu::BlendComponent {
                pub(crate) pub(crate) src_factor: wgpu::BlendFactor::Dst,
                pub(crate) pub(crate) dst_factor: wgpu::BlendFactor::Zero,
                pub(crate) pub(crate) operation: wgpu::BlendOperation::Add,
            },
            pub(crate) pub(crate) alpha: wgpu::BlendComponent {
                pub(crate) pub(crate) src_factor: wgpu::BlendFactor::DstAlpha,
                pub(crate) pub(crate) dst_factor: wgpu::BlendFactor::Zero,
                pub(crate) pub(crate) operation: wgpu::BlendOperation::Add,
            },
        },
        pub(crate) pub(crate) BlendMode::Replace => wgpu::BlendState {
            pub(crate) pub(crate) color: wgpu::BlendComponent::REPLACE,
            pub(crate) pub(crate) alpha: wgpu::BlendComponent::REPLACE,
        },
        pub(crate) pub(crate) BlendMode::Screen => wgpu::BlendState {
            pub(crate) pub(crate) color: wgpu::BlendComponent {
                pub(crate) pub(crate) src_factor: wgpu::BlendFactor::One,
                pub(crate) pub(crate) dst_factor: wgpu::BlendFactor::OneMinusSrc,
                pub(crate) pub(crate) operation: wgpu::BlendOperation::Add,
            },
            pub(crate) pub(crate) alpha: wgpu::BlendComponent {
                pub(crate) pub(crate) src_factor: wgpu::BlendFactor::One,
                pub(crate) pub(crate) dst_factor: wgpu::BlendFactor::OneMinusSrcAlpha,
                pub(crate) pub(crate) operation: wgpu::BlendOperation::Add,
            },
        },
    }
}
