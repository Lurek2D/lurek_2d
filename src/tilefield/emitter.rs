//! Owns tilefield-side light emitter data stored on cells or contributed by modifiers.
//! Tilefield stores emitters as input data; `tilelight` owns propagation and accumulation.

/// Tile-based light emitter stored on a tilefield cell or modifier.
#[derive(Debug, Clone)]
pub struct TileLightEmitter {
    /// Radius in tiles.
    pub radius: f32,
    /// Light intensity multiplier.
    pub intensity: f32,
    /// RGB color in 0..1.
    pub color: [f32; 3],
}

/// Tile light emitter instance at a concrete cell.
#[derive(Debug, Clone)]
pub struct TileLightSource {
    /// Zero-based x cell coordinate.
    pub x: u32,
    /// Zero-based y cell coordinate.
    pub y: u32,
    /// Zero-based z level coordinate.
    pub z: u32,
    /// Radius in tiles.
    pub radius: f32,
    /// Light intensity multiplier.
    pub intensity: f32,
    /// RGB color in 0..1.
    pub color: [f32; 3],
}
