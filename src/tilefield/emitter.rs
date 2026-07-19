//! This file owns emitter behavior inside the tilefield subsystem, close to its data and invariants.
//! It keeps validation, defaults, and error-facing rules near the operations that mutate emitter state.
//! Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.

/// Tile-based light emitter stored on a tilefield cell or modifier.
///
/// # Fields
///
/// `radius` and `intensity` are non-negative authored values; `color` stores RGB components in `0..=1`.
#[derive(Debug, Clone)]
pub struct TileLightEmitter {
    /// Radius in tiles.
    pub radius: f32,
    /// Light intensity multiplier.
    pub intensity: f32,
    /// RGB color in 0..1.
    pub color: [f32; 3],
}

impl TileLightEmitter {
    /// Validate authored emitter metadata before it enters field state.
    pub fn validate(&self) -> Result<(), String> {
        if !self.radius.is_finite() || self.radius < 0.0 {
            return Err("tilefield light radius must be finite and >= 0".to_string());
        }
        if !self.intensity.is_finite() || self.intensity < 0.0 {
            return Err("tilefield light intensity must be finite and >= 0".to_string());
        }
        if self
            .color
            .iter()
            .any(|component| !component.is_finite() || *component < 0.0 || *component > 1.0)
        {
            return Err("tilefield light color must contain finite values in 0..1".to_string());
        }
        Ok(())
    }
}

/// Tile light emitter instance at a concrete cell.
///
/// # Fields
///
/// `x`, `y`, and `z` identify the source cell; the remaining fields copy the authored emitter metadata.
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
