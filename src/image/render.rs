//! Render-command generation for the image module.
//!
//! Provides methods on [`ImageData`] to produce GPU-facing [`RenderCommand`]s
//! and a CPU identity copy (`draw_to_image`).  The caller is responsible for
//! uploading pixel data to a GPU texture before submitting the draw command.
//! Pure CPU — no wgpu, winit, or mlua imports.

use crate::render::renderer::RenderCommand;
use crate::runtime::resource_keys::TextureKey;

use super::image_data::ImageData;

impl ImageData {
    /// Generate a single `DrawImage` render command for this image.
    ///
    /// The caller is responsible for uploading the `ImageData` pixels to the
    /// GPU texture identified by `texture_key` before this command executes.
    ///
    /// # Parameters
    /// - `texture_key` — `TextureKey`. GPU texture handle to draw.
    /// - `x` — `f32`. Destination X position in screen pixels.
    /// - `y` — `f32`. Destination Y position in screen pixels.
    ///
    /// # Returns
    /// `Vec<RenderCommand>`.
    pub fn generate_render_commands(
        &self,
        texture_key: TextureKey,
        x: f32,
        y: f32,
    ) -> Vec<RenderCommand> {
        vec![RenderCommand::DrawImage {
            texture_key,
            x,
            y,
            effect: None,
        }]
    }

    /// Return a CPU copy of this image (identity draw-to-image).
    ///
    /// `ImageData` is already the CPU image representation, so this method
    /// returns a clone. Useful for conforming to the `draw_to_image` interface.
    ///
    /// # Returns
    /// `ImageData`.
    pub fn draw_to_image(&self) -> ImageData {
        self.clone()
    }
}

// ── Tests ────────────────────────────────────────────────────────────────────
