//! This file owns the thin `ImageData` rendering bridge that turns image buffers into renderer commands.
//! It emits `DrawImage` command payloads with texture keys and screen placement, and can clone buffers as images.
//! Open this file when image-to-render command translation changes; pixel storage and effects live in siblings.

use super::image_data::ImageData;
use crate::render::renderer::RenderCommand;
use crate::runtime::resource_keys::TextureKey;

/// Rendering and snapshot helpers for image buffers.
impl ImageData {
    /// Generate draw commands for this image buffer at the given screen position.
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
    /// Clone the image buffer into a standalone image value.
    pub fn draw_to_image(&self) -> ImageData {
        self.clone()
    }
}
