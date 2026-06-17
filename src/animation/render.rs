//! Converts active animation frame state into renderer-ready textured draw command payloads. `animation/render` delivers the rendering adapter and draw-command integration for the animation subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Bundles atlas identity and transform inputs so frame sampling maps cleanly to render execution. The file owns or coordinates data contracts including `AnimRenderParams`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Keeps rendering adaptation lightweight while preserving consistent frame-to-visual translation. Public callable behavior is centered on `quad_to_draw_command`, while method-level behavior such as `generate_render_command` stays attached to the local data model and invariants.

use crate::animation::controller::Animation;
use crate::math::Rect;
use crate::render::renderer::RenderCommand;
use crate::runtime::resource_keys::TextureKey;

/// Rendering inputs shared by animation frame draw helpers.
#[derive(Debug, Clone)]
pub struct AnimRenderParams {
    /// Texture atlas that contains the frame quad.
    pub texture_key: TextureKey,
    /// Full atlas width in pixels.
    pub tex_w: f32,
    /// Full atlas height in pixels.
    pub tex_h: f32,
    /// World-space or screen-space X position for the draw call.
    pub x: f32,
    /// World-space or screen-space Y position for the draw call.
    pub y: f32,
    /// Rotation in radians.
    pub rotation: f32,
    /// Horizontal scale.
    pub sx: f32,
    /// Vertical scale.
    pub sy: f32,
    /// Origin X used as the rotation and scale pivot.
    pub ox: f32,
    /// Origin Y used as the rotation and scale pivot.
    pub oy: f32,
}

impl Animation {
    /// Build a draw command for the current frame when the animation has an active quad.
    pub fn generate_render_command(&self, params: &AnimRenderParams) -> Option<RenderCommand> {
        let quad = self.current_quad()?;
        Some(quad_to_draw_command(&quad, params))
    }
}

/// Convert a texture quad plus render parameters into a renderer draw command.
pub fn quad_to_draw_command(quad: &Rect, params: &AnimRenderParams) -> RenderCommand {
    RenderCommand::DrawQuad {
        texture_key: params.texture_key,
        quad_x: quad.x,
        quad_y: quad.y,
        quad_w: quad.width,
        quad_h: quad.height,
        tex_w: params.tex_w,
        tex_h: params.tex_h,
        x: params.x,
        y: params.y,
        rotation: params.rotation,
        sx: params.sx,
        sy: params.sy,
        ox: params.ox,
        oy: params.oy,
        effect: None,
    }
}
