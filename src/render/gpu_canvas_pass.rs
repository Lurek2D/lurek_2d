//! Owns the gpu canvas pass owner for the render subsystem and keeps its rules local to this file.
//! Keeps render data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
//! Defines how gpu canvas pass data is validated, transformed, or stored before neighboring systems use it.
//! Owns render behavior with explicit state, validation, and crate-local integration boundaries.

use slotmap::SlotMap;

use crate::render::gpu_renderer::GpuRenderer;
use crate::render::gpu_resources::canvas_texture_needs_recreate;
use crate::render::gpu_types::RenderTargetId;
use crate::runtime::resource_keys::CanvasKey;

impl GpuRenderer {
    /// Synchronize GPU canvas textures with the logical canvas store before frame command preparation.
    pub(crate) fn sync_canvas_targets(
        &mut self,
        canvases: &SlotMap<CanvasKey, crate::render::Canvas>,
        default_filter: &(String, String, u32),
    ) {
        for (key, canvas) in canvases.iter() {
            let existing_size = self
                .canvas_gpu_textures
                .get(key)
                .map(|texture| (texture.width, texture.height));
            if canvas_texture_needs_recreate(existing_size, canvas.width, canvas.height) {
                if let Err(err) =
                    self.create_canvas(key, canvas.width, canvas.height, default_filter)
                {
                    self.render_diagnostics.record_invalid_canvas_allocation();
                    log::warn!("Skipping invalid canvas allocation for {:?}: {}", key, err);
                }
            }
        }
    }

    /// Return the pixel dimensions of a render target from the logical canvas store.
    pub(crate) fn target_dimensions(
        &self,
        target: RenderTargetId,
        canvases: &SlotMap<CanvasKey, crate::render::Canvas>,
    ) -> (u32, u32) {
        match target {
            RenderTargetId::Screen => (self.width, self.height),
            RenderTargetId::Canvas(key) => canvases
                .get(key)
                .map(|canvas| (canvas.width, canvas.height))
                .unwrap_or((self.width, self.height)),
        }
    }

    /// Return the pixel dimensions of a render target from the GPU texture store.
    pub(crate) fn target_dimensions_from_gpu(&self, target: RenderTargetId) -> (u32, u32) {
        match target {
            RenderTargetId::Screen => (self.width, self.height),
            RenderTargetId::Canvas(key) => self
                .canvas_gpu_textures
                .get(key)
                .map(|canvas| (canvas.width, canvas.height))
                .unwrap_or((self.width, self.height)),
        }
    }
}
