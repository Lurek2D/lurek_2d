//! This file owns emitter behavior inside the tilefield subsystem, close to its data and invariants.
//! It keeps validation, defaults, and error-facing rules near the operations that mutate emitter state.
//! Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.

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
