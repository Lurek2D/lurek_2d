//! Tileable Perlin noise grid generation and cell access.
//!
//! - Conversion to flat grayscale RGBA byte buffers for higher-tier projection.

use crate::procgen::noise::perlin_noise_periodic;
use crate::procgen::scalar_map_to_rgba_bytes;

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
        let scale = scale.max(1e-6);
        let px = width as f64 * scale;
        let py = height as f64 * scale;
        let size = (width * height) as usize;
        let mut cells = Vec::with_capacity(size);
        for y in 0..height {
            for x in 0..width {
                let nx = x as f64 * scale;
                let ny = y as f64 * scale;
                let v = (perlin_noise_periodic(nx, ny, px, py) * 0.5 + 0.5).clamp(0.0, 1.0) as f32;
                cells.push(v);
            }
        }
        Self {
            width,
            height,
            cells,
        }
    }
    /// Convert the cell grid to a flat grayscale RGBA byte buffer at 4 bytes per cell.
    pub fn to_rgba_bytes(&self) -> Vec<u8> {
        scalar_map_to_rgba_bytes(&self.cells)
    }
}
