//! Owns procgen behavior with explicit state, validation, and crate-local integration boundaries.
//! Centers the implementation around NoiseGrid, from_perlin, try_from_perlin, with helpers kept close to their invariants.
//! Defines how render data is validated, transformed, or stored before neighboring systems use it.
//! Owns procgen behavior with explicit state, validation, and crate-local integration boundaries.

use crate::procgen::noise::perlin_noise_periodic;
use crate::procgen::scalar_map_to_rgba_bytes;
use crate::procgen::{
    limits::{checked_cell_count, validate_positive},
    ProcgenError, ProcgenLimits,
};

/// Flat noise grid with tiling-Perlin cell values in 0.0–1.0.
pub struct NoiseGrid {
    /// Grid width in cells.
    pub width: u32,
    /// Grid height in cells.
    pub height: u32,
    /// Row-major cell values; index = `y * width + x`.
    pub cells: Vec<f32>,
}

impl NoiseGrid {
    /// Build a tileable Perlin noise grid at the given `scale`; scale is clamped to >= 1e-6.
    pub fn from_perlin(width: u32, height: u32, scale: f64) -> Self {
        Self::try_from_perlin(width, height, scale, &ProcgenLimits::default())
            .expect("NoiseGrid::from_perlin received invalid dimensions or scale")
    }

    /// Build a tileable Perlin noise grid after validating dimensions and scale.
    pub fn try_from_perlin(
        width: u32,
        height: u32,
        scale: f64,
        limits: &ProcgenLimits,
    ) -> Result<Self, ProcgenError> {
        validate_positive("scale", scale)?;
        let len = checked_cell_count(width, height, limits)?;
        let px = width as f64 * scale;
        let py = height as f64 * scale;
        let mut cells = Vec::with_capacity(len);
        for y in 0..height {
            for x in 0..width {
                let nx = x as f64 * scale;
                let ny = y as f64 * scale;
                let v = (perlin_noise_periodic(nx, ny, px, py) * 0.5 + 0.5).clamp(0.0, 1.0) as f32;
                cells.push(v);
            }
        }
        Ok(Self {
            width,
            height,
            cells,
        })
    }
    /// Convert the cell grid to a flat grayscale RGBA byte buffer at 4 bytes per cell.
    pub fn to_rgba_bytes(&self) -> Vec<u8> {
        scalar_map_to_rgba_bytes(&self.cells)
    }
}
