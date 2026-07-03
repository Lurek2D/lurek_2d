//! Owns the parallax render implementation for the parallax subsystem and keeps related runtime rules local here.
//! Keeps parallax layers, draw state, and render-facing helpers so helpers stay close to invariants this file updates.
//! Defines how parallax render data is validated, transformed, or stored before neighboring systems consume it.
//! Separates parallax render behavior from Lua bindings, tests, and sibling owners so integration stays readable.

use crate::parallax::layer::{ParallaxDrawBatch, ParallaxLayer};
use crate::render::renderer::RenderCommand;

/// Render-command generation for a single parallax layer.
impl ParallaxLayer {
    /// Generate a `Vec<RenderCommand>` for this layer at the given camera position and screen size.
    pub fn generate_render_commands(
        &self,
        cam_x: f32,
        cam_y: f32,
        screen_w: f32,
        screen_h: f32,
    ) -> Vec<RenderCommand> {
        let batch = match self.build_draw_calls(cam_x, cam_y, screen_w, screen_h) {
            Some(b) => b,
            None => return Vec::new(),
        };
        let mut cmds = batch_to_render_commands(&batch);
        if let Some(shader) = self.shader {
            cmds.insert(0, RenderCommand::SetShader(Some(shader)));
            cmds.push(RenderCommand::SetShader(None));
        }
        cmds
    }
}
/// Convert a `ParallaxDrawBatch` into a flat list of `RenderCommand` values ready for submission.
pub fn batch_to_render_commands(batch: &ParallaxDrawBatch) -> Vec<RenderCommand> {
    let [r, g, b, a] = batch.color;
    let mut cmds = Vec::with_capacity(2 + batch.tiles.len());
    cmds.push(RenderCommand::SetColor(r, g, b, a));
    cmds.push(RenderCommand::SetBlendMode(batch.blend_mode));
    for &(x, y) in &batch.tiles {
        cmds.push(RenderCommand::DrawImageEx {
            texture_key: batch.texture_key,
            x,
            y,
            rotation: 0.0,
            sx: batch.sx,
            sy: batch.sy,
            ox: 0.0,
            oy: 0.0,
            effect: batch.effect.clone(),
        });
    }
    cmds
}
