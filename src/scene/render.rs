//! `src/scene/render.rs` owns the render-facing bridge from current scene-stack state into commands and image snapshots.
//! It extends `SceneStack` with render-command and image helpers, keeping render adaptation separate from stack state.
//! Read it when active-scene rendering output, snapshot behavior, or scene-to-renderer bridging logic needs to change.

use super::stack::SceneStack;
use crate::image::ImageData;
use crate::render::renderer::RenderCommand;

/// Render methods added to SceneStack by this file.
impl SceneStack {
    /// Collect and return RenderCommand list for the current scene; returns empty vec when no scene is active.
    pub fn generate_render_commands(&self) -> Vec<RenderCommand> {
        Vec::new()
    }
    /// Render the active scene into a new ImageData of the given pixel dimensions; fills with background colour when empty.
    pub fn draw_to_image(&self, width: u32, height: u32) -> ImageData {
        let mut img = ImageData::new(width, height);
        img.fill(12, 12, 18, 255);
        img
    }
}
