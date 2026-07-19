//! Owns local tile-id and frame-duration records for tileset animations.
//!
//! These frames are metadata consumed by tilemap timing/render selection; they are
//! intentionally not general entity animation timelines.

/// A single frame in a tile sprite-sheet animation.
///
/// # Fields
///
/// The local frame tile id and its positive display duration are validated by
/// `TileSet::set_animation` before storage.
#[derive(Debug, Clone)]
pub struct TileAnimFrame {
    /// Local tile ID this frame displays.
    pub tile_id: u32,
    /// How long this frame is shown in milliseconds.
    pub duration_ms: f32,
}
