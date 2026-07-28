//! Defines the stable render-capability snapshot exposed to scripts and tools.
//!
//! The renderer translates mutable backend limits and feature bits into this
//! narrow, backend-neutral data model. Lua receives only this snapshot and
//! never a raw `wgpu` object or backend-specific adapter string.

/// Stable, read-only render limits and optional features for the active device.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct RenderCapabilities {
    /// Maximum two-dimensional texture size accepted by the active device.
    pub max_texture_dimension_2d: u32,
    /// Maximum size in bytes of one GPU buffer allocation.
    pub max_buffer_size: u64,
    /// Maximum bindings accepted in one bind group.
    pub max_bindings_per_bind_group: u32,
    /// Whether timestamp-query timing is available to renderer diagnostics.
    pub timestamp_queries: bool,
    /// Whether the active surface supports asynchronous readback requests.
    pub asynchronous_readback: bool,
    /// Whether deterministic command replay is available for headless evidence.
    pub deterministic_software_replay: bool,
}

impl Default for RenderCapabilities {
    /// Return the conservative capability set used before a GPU device is initialized.
    fn default() -> Self {
        Self {
            max_texture_dimension_2d: 0,
            max_buffer_size: 0,
            max_bindings_per_bind_group: 0,
            timestamp_queries: false,
            asynchronous_readback: false,
            deterministic_software_replay: true,
        }
    }
}

impl RenderCapabilities {
    /// Build a stable public snapshot from an initialized renderer device.
    pub fn from_device(device: &wgpu::Device) -> Self {
        let limits = device.limits();
        Self {
            max_texture_dimension_2d: limits.max_texture_dimension_2d,
            max_buffer_size: limits.max_buffer_size,
            max_bindings_per_bind_group: limits.max_bindings_per_bind_group,
            timestamp_queries: device.features().contains(wgpu::Features::TIMESTAMP_QUERY),
            asynchronous_readback: true,
            deterministic_software_replay: true,
        }
    }
}
