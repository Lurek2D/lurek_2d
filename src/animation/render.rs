//! Render-command generation for sprite animations.
//!
//! Provides a helper to convert the current animation frame into a
//! [`RenderCommand::DrawQuad`].  Pure CPU — no wgpu, winit, or mlua.

use crate::animation::controller::Animation;
use crate::math::Rect;
use crate::render::renderer::RenderCommand;
use crate::runtime::resource_keys::TextureKey;

/// Parameters for rendering an animated sprite.
///
/// Since [`Animation`] is a pure frame/clip controller and does not store
/// position, texture, or transform, the caller supplies those via this struct.
///
/// # Fields
/// - `texture_key` — `TextureKey`. Handle to the sprite-sheet texture.
/// - `tex_w` — `f32`. Full texture width in pixels (for UV normalisation).
/// - `tex_h` — `f32`. Full texture height in pixels (for UV normalisation).
/// - `x` — `f32`. World X position.
/// - `y` — `f32`. World Y position.
/// - `rotation` — `f32`. Rotation in radians.
/// - `sx` — `f32`. Horizontal scale.
/// - `sy` — `f32`. Vertical scale.
/// - `ox` — `f32`. Origin X offset.
/// - `oy` — `f32`. Origin Y offset.
#[derive(Debug, Clone)]
pub struct AnimRenderParams {
    /// Handle to the sprite-sheet texture.
    pub texture_key: TextureKey,
    /// Full texture width in pixels (for UV normalisation).
    pub tex_w: f32,
    /// Full texture height in pixels (for UV normalisation).
    pub tex_h: f32,
    /// World X position.
    pub x: f32,
    /// World Y position.
    pub y: f32,
    /// Rotation in radians.
    pub rotation: f32,
    /// Horizontal scale.
    pub sx: f32,
    /// Vertical scale.
    pub sy: f32,
    /// Origin X offset.
    pub ox: f32,
    /// Origin Y offset.
    pub oy: f32,
}

impl Animation {
    /// Produces a single `DrawQuad` render command for the current frame.
    ///
    /// Returns `None` if no clip is active or the animation has no frames.
    /// The caller supplies the texture and transform via [`AnimRenderParams`].
    ///
    /// # Parameters
    /// - `params` — `&AnimRenderParams`. Texture and transform info.
    ///
    /// # Returns
    /// `Option<RenderCommand>`.
    pub fn generate_render_command(&self, params: &AnimRenderParams) -> Option<RenderCommand> {
        let quad = self.current_quad()?;
        Some(quad_to_draw_command(&quad, params))
    }
}

/// Converts a source quad and render parameters into a `DrawQuad` command.
///
/// # Parameters
/// - `quad` — `&Rect`. Source rectangle within the sprite-sheet.
/// - `params` — `&AnimRenderParams`. Texture and transform info.
///
/// # Returns
/// `RenderCommand`.
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

// ── Tests ────────────────────────────────────────────────────────────────────

#[cfg(test)]
mod tests {
    use super::*;
    use crate::animation::controller::Animation;
    use crate::math::Rect;
    use crate::runtime::resource_keys::TextureKey;
    use slotmap::KeyData;

    fn dummy_key() -> TextureKey {
        TextureKey::from(KeyData::from_ffi(1))
    }

    fn make_params() -> AnimRenderParams {
        AnimRenderParams {
            texture_key: dummy_key(),
            tex_w: 256.0,
            tex_h: 256.0,
            x: 100.0,
            y: 200.0,
            rotation: 0.0,
            sx: 1.0,
            sy: 1.0,
            ox: 16.0,
            oy: 16.0,
        }
    }

    #[test]
    fn no_clip_returns_none() {
        let anim = Animation::new();
        let params = make_params();
        assert!(anim.generate_render_command(&params).is_none());
    }

    #[test]
    fn active_clip_returns_draw_quad() {
        let mut anim = Animation::new();
        anim.add_frame(Rect::new(0.0, 0.0, 32.0, 32.0));
        anim.add_frame(Rect::new(32.0, 0.0, 32.0, 32.0));
        anim.add_clip("walk", vec![0, 1], 10.0, true);
        anim.play("walk");

        let params = make_params();
        let cmd = anim.generate_render_command(&params);
        assert!(cmd.is_some());
        if let Some(RenderCommand::DrawQuad { quad_x, quad_y, quad_w, quad_h, x, y, ox, oy, .. }) = cmd {
            assert!((quad_x).abs() < 1e-5);
            assert!((quad_y).abs() < 1e-5);
            assert!((quad_w - 32.0).abs() < 1e-5);
            assert!((quad_h - 32.0).abs() < 1e-5);
            assert!((x - 100.0).abs() < 1e-5);
            assert!((y - 200.0).abs() < 1e-5);
            assert!((ox - 16.0).abs() < 1e-5);
            assert!((oy - 16.0).abs() < 1e-5);
        } else {
            panic!("Expected DrawQuad");
        }
    }

    #[test]
    fn quad_to_draw_preserves_all_fields() {
        let quad = Rect::new(64.0, 32.0, 16.0, 16.0);
        let params = make_params();
        let cmd = quad_to_draw_command(&quad, &params);
        if let RenderCommand::DrawQuad { quad_x, quad_y, tex_w, tex_h, .. } = cmd {
            assert!((quad_x - 64.0).abs() < 1e-5);
            assert!((quad_y - 32.0).abs() < 1e-5);
            assert!((tex_w - 256.0).abs() < 1e-5);
            assert!((tex_h - 256.0).abs() < 1e-5);
        } else {
            panic!("Expected DrawQuad");
        }
    }
}
