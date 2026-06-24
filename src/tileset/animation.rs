//! This file owns animation behavior inside the tileset subsystem, close to its data and invariants.
//! It keeps validation, defaults, and error-facing rules near the operations that mutate animation state.
//! Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.

/// A single frame in a tile sprite-sheet animation.
#[derive(Debug, Clone)]
pub struct TileAnimFrame {
    /// Local tile ID this frame displays.
    pub tile_id: u32,
    /// How long this frame is shown in milliseconds.
    pub duration_ms: f32,
}
