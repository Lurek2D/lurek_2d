//! Owns tileset animation frame records used by tilemap render-time GID resolution.

/// A single frame in a tile sprite-sheet animation.
#[derive(Debug, Clone)]
pub struct TileAnimFrame {
    /// Local tile ID this frame displays.
    pub tile_id: u32,
    /// How long this frame is shown in milliseconds.
    pub duration_ms: f32,
}
