//! This file owns the cellular-automata cave generator that evolves random occupancy into enclosed cavern maps.
//! `CellularOpts` stores fill probability, rule thresholds, iterations, and seed for one reproducible generation run.
//! Neighbor counting and border-as-solid behavior stay here because they define the resulting cave texture directly.
//! Open it when cave evolution rules change; flood fill and sandbox material simulation live in sibling modules.

use super::lcg::Lcg;
use crate::procgen::{
    limits::{
        checked_cell_count, validate_iterations, validate_non_zero_dimensions, validate_range,
    },
    ProcgenError, ProcgenLimits,
};

/// Configuration for one cellular automata cave generation run.
#[derive(Debug, Clone)]
pub struct CellularOpts {
    /// Initial fill probability per cell; range 0.0–1.0 (0.45 = 45 % solid).
    pub fill: f32,
    /// Number of birth/survive update passes applied to the initial grid.
    pub iterations: u32,
    /// Moore-neighbour count at or above which a dead cell becomes alive (birth rule).
    pub birth: u32,
    /// Moore-neighbour count at or above which a live cell survives (survive rule).
    pub survive: u32,
    /// Seed passed to the internal `Lcg` for reproducible initialisation.
    pub seed: u64,
}

/// Provide cave-friendly defaults: fill=0.45, iterations=5, birth=6, survive=4.
impl Default for CellularOpts {
    fn default() -> Self {
        Self {
            fill: 0.45,
            iterations: 5,
            birth: 6,
            survive: 4,
            seed: 12345,
        }
    }
}

impl CellularOpts {
    /// Validate fill ratio and iteration budget for safe cellular generation.
    pub fn validate(&self, limits: &ProcgenLimits) -> Result<(), ProcgenError> {
        validate_range("fill", self.fill as f64, 0.0, 1.0)?;
        validate_iterations(self.iterations, limits)?;
        if self.birth > 8 {
            return Err(ProcgenError::ValueOutOfRange {
                field: "birth",
                min: 0.0,
                max: 8.0,
                value: self.birth as f64,
            });
        }
        if self.survive > 8 {
            return Err(ProcgenError::ValueOutOfRange {
                field: "survive",
                min: 0.0,
                max: 8.0,
                value: self.survive as f64,
            });
        }
        Ok(())
    }
}

/// Run cellular automata on a `width × height` grid and return a flat `0`/`1` slice (1 = solid).
pub fn cellular_automata(width: u32, height: u32, opts: &CellularOpts) -> Vec<u8> {
    try_cellular_automata(width, height, opts, &ProcgenLimits::default())
        .expect("cellular_automata received invalid dimensions or options")
}

/// Run cellular automata after validating dimensions, fill range, and iteration budgets.
pub fn try_cellular_automata(
    width: u32,
    height: u32,
    opts: &CellularOpts,
    limits: &ProcgenLimits,
) -> Result<Vec<u8>, ProcgenError> {
    validate_non_zero_dimensions(width, height)?;
    let size = checked_cell_count(width, height, limits)?;
    opts.validate(limits)?;
    let mut grid = vec![0u8; size];
    let mut rng = Lcg::new(opts.seed);
    for cell in grid.iter_mut() {
        *cell = if rng.next_f32() < opts.fill { 1 } else { 0 };
    }
    let mut next = vec![0u8; size];
    for _ in 0..opts.iterations {
        for y in 0..height {
            for x in 0..width {
                let idx = (y * width + x) as usize;
                let mut neighbors = 0u32;
                for dy in -1i32..=1 {
                    for dx in -1i32..=1 {
                        if dx == 0 && dy == 0 {
                            continue;
                        }
                        let nx = x as i32 + dx;
                        let ny = y as i32 + dy;
                        if nx < 0 || ny < 0 || nx >= width as i32 || ny >= height as i32 {
                            neighbors += 1;
                        } else {
                            neighbors += grid[(ny as u32 * width + nx as u32) as usize] as u32;
                        }
                    }
                }
                next[idx] = if grid[idx] == 1 {
                    if neighbors >= opts.survive {
                        1
                    } else {
                        0
                    }
                } else if neighbors >= opts.birth {
                    1
                } else {
                    0
                };
            }
        }
        std::mem::swap(&mut grid, &mut next);
    }
    Ok(grid)
}
