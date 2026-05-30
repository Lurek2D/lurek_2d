//! Bridges CPU `ImageData` content into render-command payloads consumed by the draw pipeline.
//! Provides lightweight conversion helpers that reference texture keys and screen placement.
//! Includes image snapshot utilities used where value-copy semantics are required.

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
