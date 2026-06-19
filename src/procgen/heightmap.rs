//! This file owns the normalized heightmap model used to build terrain fields from noise or binary cellular sources.
//! `HeightmapOpts` stores noise parameters and erosion passes, while `Heightmap` owns width, height, and cell storage.
//! Generation from FBM noise stays here because map options, normalization, and seed-driven reproducibility are local.
//! Simple erosion also belongs here since it mutates terrain cells in-place and defines the file's smoothing behavior.
//! RGBA export and sampled access remain local because they expose the heightmap as usable terrain data to callers.

use crate::procgen::noise::{FractalType, MapGenOptions, NoiseGenerator, NoiseKind};
use crate::procgen::scalar_map_to_rgba_bytes;
use crate::procgen::{
    limits::{
        checked_cell_count, validate_finite, validate_iterations, validate_non_zero_dimensions,
        validate_octaves, validate_positive,
    },
    ProcgenError, ProcgenLimits, ProcgenReport,
};

/// Erosion update order mode used by `Heightmap`.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ErosionMode {
    /// Update cells in place while scanning; fast but order-dependent.
    InPlace,
    /// Read from a frozen source snapshot and write into a separate destination buffer each pass.
    Buffered,
}

/// Diagnostics emitted by safe erosion helpers.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct HeightmapErosionReport {
    /// Shared procgen summary fields for the erosion run.
    pub summary: ProcgenReport,
    /// Erosion mode used for the run.
    pub mode: ErosionMode,
    /// Number of cell updates applied across all passes.
    pub changed_cells: usize,
}

/// Parameters for procedural heightmap generation.
#[derive(Debug, Clone)]
pub struct HeightmapOpts {
    /// Grid width in cells.
    pub width: u32,
    /// Grid height in cells.
    pub height: u32,
    /// Noise frequency scale applied to both axes; smaller = smoother features.
    pub scale: f64,
    /// Number of FBM octaves summed together.
    pub octaves: u32,
    /// Frequency multiplier per octave (typically 2.0).
    pub lacunarity: f64,
    /// Amplitude multiplier per octave; controls how much each octave contributes.
    pub persistence: f64,
    /// Seed passed to `NoiseGenerator::new`.
    pub seed: u64,
    /// Number of simple hydraulic erosion passes run after noise generation; 0 = none.
    pub erosion_passes: u32,
    /// Erosion update mode; in-place is faster but order-dependent.
    pub erosion_mode: ErosionMode,
}

/// Default for a 64×64 map with 5 octaves, no erosion.
impl Default for HeightmapOpts {
    fn default() -> Self {
        Self {
            width: 64,
            height: 64,
            scale: 1.0 / 32.0,
            octaves: 5,
            lacunarity: 2.0,
            persistence: 0.5,
            seed: 0,
            erosion_passes: 0,
            erosion_mode: ErosionMode::InPlace,
        }
    }
}

impl HeightmapOpts {
    /// Validate dimensions, noise parameters, octave count, and erosion budget for safe generation.
    pub fn validate(&self, limits: &ProcgenLimits) -> Result<(), ProcgenError> {
        validate_non_zero_dimensions(self.width, self.height)?;
        checked_cell_count(self.width, self.height, limits)?;
        validate_positive("scale", self.scale)?;
        validate_octaves(self.octaves, limits)?;
        validate_positive("lacunarity", self.lacunarity)?;
        validate_finite("persistence", self.persistence)?;
        validate_iterations(self.erosion_passes, limits)?;
        if self.persistence < 0.0 {
            return Err(ProcgenError::ValueOutOfRange {
                field: "persistence",
                min: 0.0,
                max: f64::MAX,
                value: self.persistence,
            });
        }
        Ok(())
    }
}

/// Normalised heightmap grid with float cells in 0.0–1.0 after construction.
#[derive(Debug, Clone)]
pub struct Heightmap {
    /// Grid width in cells.
    pub width: u32,
    /// Grid height in cells.
    pub height: u32,
    /// Flat row-major cell values; index = `y * width + x`.
    pub cells: Vec<f32>,
}

/// Core construction, sampling, erosion, and export methods.
impl Heightmap {
    /// Generate a heightmap from `opts` using FBM Perlin noise, normalised and optionally eroded.
    pub fn generate(opts: &HeightmapOpts) -> Self {
        Self::try_generate(opts, &ProcgenLimits::default())
            .expect("Heightmap::generate received invalid dimensions or options")
    }

    /// Generate a heightmap from `opts`, rejecting invalid dimensions, finite parameters, and budget overruns.
    pub fn try_generate(
        opts: &HeightmapOpts,
        limits: &ProcgenLimits,
    ) -> Result<Self, ProcgenError> {
        opts.validate(limits)?;
        let gen = NoiseGenerator::new(opts.seed);
        let map_opts = MapGenOptions {
            scale_x: opts.scale,
            scale_y: opts.scale,
            octaves: opts.octaves,
            lacunarity: opts.lacunarity,
            persistence: opts.persistence,
            kind: NoiseKind::Perlin,
            fractal: FractalType::Fbm,
            offset_x: 0.0,
            offset_y: 0.0,
            parallel_enabled: true,
            parallel_chunk_size: None,
        };
        let raw = gen.try_generate_map(opts.width, opts.height, &map_opts, limits)?;
        let cells: Vec<f32> = raw.iter().map(|&v| v as f32).collect();
        let mut hm = Self {
            width: opts.width,
            height: opts.height,
            cells,
        };
        hm.normalize();
        if opts.erosion_passes > 0 {
            hm.erode_with_mode(opts.erosion_passes, opts.erosion_mode);
            hm.normalize();
        }
        Ok(hm)
    }

    /// Build a heightmap from a pre-computed `f64` noise slice; normalises the result.
    pub fn from_noise_map(width: u32, height: u32, values: &[f64]) -> Self {
        Self::try_from_noise_map(width, height, values, &ProcgenLimits::default())
            .expect("Heightmap::from_noise_map received invalid dimensions or values length")
    }

    /// Build a heightmap from a pre-computed `f64` noise slice, requiring an exact cell count.
    pub fn try_from_noise_map(
        width: u32,
        height: u32,
        values: &[f64],
        limits: &ProcgenLimits,
    ) -> Result<Self, ProcgenError> {
        validate_non_zero_dimensions(width, height)?;
        let len = checked_cell_count(width, height, limits)?;
        if values.len() != len {
            return Err(ProcgenError::InvalidLength {
                context: "heightmap noise map",
                expected: len,
                actual: values.len(),
            });
        }
        let mut cells = Vec::with_capacity(len);
        for &value in values {
            validate_finite("noise_map_value", value)?;
            cells.push(value as f32);
        }
        let mut hm = Self {
            width,
            height,
            cells,
        };
        hm.normalize();
        Ok(hm)
    }

    /// Build a heightmap from a cellular automata `u8` grid: cells != `floor_value` map to 1.0, others to 0.0.
    pub fn from_cellular(width: u32, height: u32, cells: &[u8], floor_value: u8) -> Self {
        Self::try_from_cellular(width, height, cells, floor_value, &ProcgenLimits::default())
            .expect("Heightmap::from_cellular received invalid dimensions or cell data")
    }

    /// Build a heightmap from a cellular automata grid, requiring an exact cell count.
    pub fn try_from_cellular(
        width: u32,
        height: u32,
        cells: &[u8],
        floor_value: u8,
        limits: &ProcgenLimits,
    ) -> Result<Self, ProcgenError> {
        validate_non_zero_dimensions(width, height)?;
        let len = checked_cell_count(width, height, limits)?;
        if cells.len() != len {
            return Err(ProcgenError::InvalidLength {
                context: "heightmap cellular grid",
                expected: len,
                actual: cells.len(),
            });
        }
        let mut out = Vec::with_capacity(len);
        for &value in cells {
            out.push(if value == floor_value { 0.0 } else { 1.0 });
        }
        Ok(Self {
            width,
            height,
            cells: out,
        })
    }

    /// Return the cell value at `(x, y)` when the map is well-formed, or `None` for empty or malformed storage.
    pub fn try_get(&self, x: u32, y: u32) -> Option<f32> {
        if self.width == 0 || self.height == 0 {
            return None;
        }
        let len = usize::try_from(u64::from(self.width) * u64::from(self.height)).ok()?;
        if self.cells.len() < len {
            return None;
        }
        let x = x.min(self.width.saturating_sub(1));
        let y = y.min(self.height.saturating_sub(1));
        self.cells.get((y * self.width + x) as usize).copied()
    }

    /// Return the cell value at `(x, y)`, clamping out-of-bounds coordinates to the grid edge.
    pub fn get(&self, x: u32, y: u32) -> f32 {
        self.try_get(x, y).unwrap_or(0.0)
    }

    /// Overwrite the cell at `(x, y)` with `v`; assumes coordinates are in-bounds.
    fn set(&mut self, x: u32, y: u32, v: f32) {
        let idx = (y * self.width + x) as usize;
        self.cells[idx] = v;
    }

    /// Remap all cells to 0.0–1.0 by dividing by the current min/max range; no-op if range < 1e-7.
    pub fn normalize(&mut self) {
        if self.cells.is_empty() {
            return;
        }
        let min = self.cells.iter().cloned().fold(f32::MAX, f32::min);
        let max = self.cells.iter().cloned().fold(f32::MIN, f32::max);
        let range = max - min;
        if range < 1e-7 {
            return;
        }
        for v in &mut self.cells {
            *v = (*v - min) / range;
        }
    }

    /// Apply `passes` rounds of simple hydraulic erosion: each cell deposits 10 % of its height difference into its lowest 4-connected neighbour.
    pub fn erode(&mut self, passes: u32) {
        self.erode_with_mode(passes, ErosionMode::InPlace);
    }

    /// Apply erosion using either in-place or buffered scan order and return a diagnostics report.
    pub fn erode_with_mode(&mut self, passes: u32, mode: ErosionMode) -> HeightmapErosionReport {
        let mut changed_cells = 0usize;
        for _ in 0..passes {
            if mode == ErosionMode::Buffered {
                let source = self.cells.clone();
                let mut next = source.clone();
                let w = self.width;
                let h = self.height;
                for y in 0..h {
                    for x in 0..w {
                        let idx = (y * w + x) as usize;
                        let center = source[idx];
                        let dirs: [(i32, i32); 4] = [(1, 0), (-1, 0), (0, 1), (0, -1)];
                        let mut lowest_val = center;
                        let mut lowest_idx: Option<usize> = None;
                        for (dx, dy) in dirs {
                            let nx = x as i32 + dx;
                            let ny = y as i32 + dy;
                            if nx >= 0 && ny >= 0 && nx < w as i32 && ny < h as i32 {
                                let n_idx = (ny as u32 * w + nx as u32) as usize;
                                let nv = source[n_idx];
                                if nv < lowest_val {
                                    lowest_val = nv;
                                    lowest_idx = Some(n_idx);
                                }
                            }
                        }
                        if let Some(low_idx) = lowest_idx {
                            let diff = (center - lowest_val) * 0.1;
                            if diff > 0.0 {
                                next[idx] -= diff;
                                next[low_idx] += diff;
                                changed_cells += 2;
                            }
                        }
                    }
                }
                self.cells = next;
                continue;
            }
            let w = self.width;
            let h = self.height;
            for y in 0..h {
                for x in 0..w {
                    let center = self.get(x, y);
                    let dirs: [(i32, i32); 4] = [(1, 0), (-1, 0), (0, 1), (0, -1)];
                    let mut lowest_val = center;
                    let mut lowest_dir: Option<(u32, u32)> = None;
                    for (dx, dy) in dirs {
                        let nx = x as i32 + dx;
                        let ny = y as i32 + dy;
                        if nx >= 0 && ny >= 0 && nx < w as i32 && ny < h as i32 {
                            let nv = self.get(nx as u32, ny as u32);
                            if nv < lowest_val {
                                lowest_val = nv;
                                lowest_dir = Some((nx as u32, ny as u32));
                            }
                        }
                    }
                    if let Some((lx, ly)) = lowest_dir {
                        let diff = (center - lowest_val) * 0.1;
                        if diff > 0.0 {
                            let new_center = center - diff;
                            let new_low = lowest_val + diff;
                            self.set(x, y, new_center);
                            self.set(lx, ly, new_low);
                            changed_cells += 2;
                        }
                    }
                }
            }
        }
        HeightmapErosionReport {
            summary: ProcgenReport {
                seed: None,
                cell_count: self.cells.len(),
                iterations: passes,
                attempts: 1,
            },
            mode,
            changed_cells,
        }
    }

    /// Convert the cell grid to a flat grayscale RGBA byte buffer at 4 bytes per cell.
    pub fn to_rgba_bytes(&self) -> Vec<u8> {
        scalar_map_to_rgba_bytes(&self.cells)
    }
}
