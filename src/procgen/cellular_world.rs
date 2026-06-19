//! This file owns the falling-material sandbox that simulates sand, water, rock, fire, gas, and empty space on a grid.
//! `CellType` defines the material vocabulary, while `CellularWorld` owns cells, fire lifetimes, tick parity, and RNG.
//! Paint helpers such as rectangle and circle fills stay here because direct authoring of test or gameplay setups is local.
//! Step logic also belongs here since per-material movement, spread, and bias reduction define world-update semantics.
//! Serialization, region export, palette rendering, and cell queries remain local because they expose owned grid state.
//! Open it when material interaction rules change; static cave generation lives in `cellular.rs` instead.
//! This file is the runtime simulation owner, not a generic renderer, physics system, or authored content container.

use crate::procgen::{
    limits::{checked_cell_count, checked_output_bytes, validate_non_zero_dimensions},
    ProcgenError, ProcgenLimits, ProcgenReport,
};

const CELLULAR_WORLD_MAGIC: [u8; 4] = *b"LCW1";
const CELLULAR_WORLD_VERSION: u32 = 1;

/// Bounds covering cells changed during the last `CellularWorld::step`.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct CellularWorldActiveBounds {
    /// Minimum changed X coordinate.
    pub min_x: u32,
    /// Minimum changed Y coordinate.
    pub min_y: u32,
    /// Maximum changed X coordinate.
    pub max_x: u32,
    /// Maximum changed Y coordinate.
    pub max_y: u32,
}

/// Diagnostics describing the last stepped simulation update.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct CellularWorldStepStats {
    /// Shared procgen summary fields for the step.
    pub summary: ProcgenReport,
    /// Number of source/destination cell transitions applied during the step.
    pub moved_cells: usize,
    /// Number of fire spread events started during the step.
    pub fire_spread_count: usize,
    /// Bounding box containing all changed cells when at least one cell changed.
    pub active_bounds: Option<CellularWorldActiveBounds>,
}

#[derive(Default)]
struct StepScratchStats {
    moved_cells: usize,
    fire_spread_count: usize,
    active_bounds: Option<CellularWorldActiveBounds>,
}

/// Cell material type used in `CellularWorld`.
#[repr(u8)]
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum CellType {
    /// Empty cell.
    Air = 0,
    /// Granular solid that falls and displaces water.
    Sand = 1,
    /// Liquid that flows sideways and falls.
    Water = 2,
    /// Immovable solid.
    Rock = 3,
    /// Burning cell that rises and spreads.
    Fire = 4,
    /// Light gas that rises and disperses.
    Gas = 5,
}

impl CellType {
    /// Map a raw `u8` to `CellType`; unmapped values return `Air`.
    pub fn from_u8(v: u8) -> Self {
        match v {
            1 => CellType::Sand,
            2 => CellType::Water,
            3 => CellType::Rock,
            4 => CellType::Fire,
            5 => CellType::Gas,
            _ => CellType::Air,
        }
    }
}

/// Fixed-size grid simulating material interactions each step.
pub struct CellularWorld {
    /// Grid width in cells.
    pub width: u32,
    /// Grid height in cells.
    pub height: u32,
    /// Flat row-major cell storage.
    cells: Vec<CellType>,
    /// Per-cell fire lifetime counter.
    fire_life: Vec<u8>,
    /// Reused destination buffer for stepped cell states.
    scratch_cells: Vec<CellType>,
    /// Reused destination buffer for stepped fire lifetimes.
    scratch_fire_life: Vec<u8>,
    /// Alternates each step to reduce left/right bias.
    even_tick: bool,
    /// Internal xorshift RNG state.
    rng_state: u32,
    /// Diagnostics captured for the last completed simulation step.
    last_step_stats: CellularWorldStepStats,
}

impl CellularWorld {
    /// Create an all-air grid of `width × height` cells.
    pub fn new(width: u32, height: u32) -> Self {
        Self::new_with_seed(width, height, 0xDEAD_BEEF)
    }

    /// Create an all-air grid with an explicit RNG seed.
    pub fn new_with_seed(width: u32, height: u32, seed: u32) -> Self {
        Self::try_new_with_seed(width, height, seed, &ProcgenLimits::default())
            .expect("CellularWorld::new_with_seed received invalid dimensions")
    }

    /// Create an all-air grid after validating procgen dimensions and cell budgets.
    pub fn try_new(width: u32, height: u32, limits: &ProcgenLimits) -> Result<Self, ProcgenError> {
        Self::try_new_with_seed(width, height, 0xDEAD_BEEF, limits)
    }

    /// Create an all-air grid with an explicit RNG seed after validating procgen dimensions and cell budgets.
    pub fn try_new_with_seed(
        width: u32,
        height: u32,
        seed: u32,
        limits: &ProcgenLimits,
    ) -> Result<Self, ProcgenError> {
        validate_non_zero_dimensions(width, height)?;
        let total = checked_cell_count(width, height, limits)?;
        Ok(Self {
            width,
            height,
            cells: vec![CellType::Air; total],
            fire_life: vec![0u8; total],
            scratch_cells: vec![CellType::Air; total],
            scratch_fire_life: vec![0u8; total],
            even_tick: true,
            rng_state: seed,
            last_step_stats: CellularWorldStepStats {
                summary: ProcgenReport {
                    seed: Some(u64::from(seed)),
                    cell_count: total,
                    iterations: 0,
                    attempts: 1,
                },
                moved_cells: 0,
                fire_spread_count: 0,
                active_bounds: None,
            },
        })
    }

    /// Set the cell at `(cx,cy)` to `cell`; initializes fire lifetime when cell is Fire.
    pub fn set_cell(&mut self, cx: u32, cy: u32, cell: CellType) {
        if cx >= self.width || cy >= self.height {
            return;
        }
        let idx = (cy * self.width + cx) as usize;
        self.cells[idx] = cell;
        if cell == CellType::Fire {
            self.fire_life[idx] = 80 + (self.rng_u8() % 40);
        } else {
            self.fire_life[idx] = 0;
        }
    }

    /// Return the cell type at `(cx,cy)`; returns Air when out of bounds.
    pub fn get_cell(&self, cx: u32, cy: u32) -> CellType {
        if cx >= self.width || cy >= self.height {
            return CellType::Air;
        }
        self.cells[(cy * self.width + cx) as usize]
    }

    /// Fill a rectangular region with `cell`; clips to grid bounds.
    pub fn fill_rect(&mut self, cx0: u32, cy0: u32, cw: u32, ch: u32, cell: CellType) {
        let x1 = cx0.saturating_add(cw).min(self.width);
        let y1 = cy0.saturating_add(ch).min(self.height);
        for cy in cy0..y1 {
            for cx in cx0..x1 {
                self.set_cell(cx, cy, cell);
            }
        }
    }

    /// Fill a circular region of radius `r_cells` around `(cx_c,cy_c)` with `cell`.
    pub fn fill_circle(&mut self, cx_c: u32, cy_c: u32, r_cells: u32, cell: CellType) {
        let r = r_cells as i64;
        let r2 = r * r;
        for dy in -r..=r {
            for dx in -r..=r {
                if dx * dx + dy * dy <= r2 {
                    let cx = cx_c as i64 + dx;
                    let cy = cy_c as i64 + dy;
                    if cx >= 0 && cy >= 0 && cx < self.width as i64 && cy < self.height as i64 {
                        self.set_cell(cx as u32, cy as u32, cell);
                    }
                }
            }
        }
    }

    /// Advance the simulation by one tick, applying material rules to every cell.
    pub fn step(&mut self) {
        self.even_tick = !self.even_tick;
        self.scratch_cells.clone_from(&self.cells);
        self.scratch_fire_life.clone_from(&self.fire_life);
        let w = self.width as i64;
        let h = self.height as i64;
        let mut step_stats = StepScratchStats::default();
        for cy in (0..h).rev() {
            if self.even_tick {
                for cx in 0..w {
                    self.step_one(cx, cy, w, h, &mut step_stats);
                }
            } else {
                for cx in (0..w).rev() {
                    self.step_one(cx, cy, w, h, &mut step_stats);
                }
            }
        }
        std::mem::swap(&mut self.cells, &mut self.scratch_cells);
        std::mem::swap(&mut self.fire_life, &mut self.scratch_fire_life);
        self.last_step_stats = CellularWorldStepStats {
            summary: ProcgenReport {
                seed: Some(u64::from(self.rng_state)),
                cell_count: self.cells.len(),
                iterations: 1,
                attempts: 1,
            },
            moved_cells: step_stats.moved_cells,
            fire_spread_count: step_stats.fire_spread_count,
            active_bounds: step_stats.active_bounds,
        };
    }

    /// Run one stepped cell update using the current grid as source and the scratch buffers as destination.
    fn step_one(&mut self, cx: i64, cy: i64, w: i64, h: i64, stats: &mut StepScratchStats) {
        let idx = (cy * w + cx) as usize;
        match self.cells[idx] {
            CellType::Air | CellType::Rock => {}
            CellType::Sand => {
                if cy + 1 < h {
                    let below = (cy + 1) * w + cx;
                    if self.scratch_cells[below as usize] == CellType::Air {
                        self.scratch_cells[below as usize] = CellType::Sand;
                        self.scratch_cells[idx] = CellType::Air;
                        Self::record_change(
                            &mut stats.active_bounds,
                            cx as u32,
                            cy as u32,
                            cx as u32,
                            (cy + 1) as u32,
                        );
                        stats.moved_cells += 1;
                        return;
                    }
                    let bias = if self.even_tick { 1i64 } else { -1i64 };
                    for &dx in &[bias, -bias] {
                        let nx = cx + dx;
                        if nx >= 0 && nx < w {
                            let diag = ((cy + 1) * w + nx) as usize;
                            if self.scratch_cells[diag] == CellType::Air {
                                self.scratch_cells[diag] = CellType::Sand;
                                self.scratch_cells[idx] = CellType::Air;
                                Self::record_change(
                                    &mut stats.active_bounds,
                                    cx as u32,
                                    cy as u32,
                                    nx as u32,
                                    (cy + 1) as u32,
                                );
                                stats.moved_cells += 1;
                                break;
                            }
                            if self.scratch_cells[diag] == CellType::Water {
                                self.scratch_cells[diag] = CellType::Sand;
                                self.scratch_cells[idx] = CellType::Water;
                                Self::record_change(
                                    &mut stats.active_bounds,
                                    cx as u32,
                                    cy as u32,
                                    nx as u32,
                                    (cy + 1) as u32,
                                );
                                stats.moved_cells += 1;
                                break;
                            }
                        }
                    }
                }
            }
            CellType::Water => {
                if cy + 1 < h {
                    let below = ((cy + 1) * w + cx) as usize;
                    if self.scratch_cells[below] == CellType::Air {
                        self.scratch_cells[below] = CellType::Water;
                        self.scratch_cells[idx] = CellType::Air;
                        Self::record_change(
                            &mut stats.active_bounds,
                            cx as u32,
                            cy as u32,
                            cx as u32,
                            (cy + 1) as u32,
                        );
                        stats.moved_cells += 1;
                        return;
                    }
                }
                let bias = if self.even_tick { 1i64 } else { -1i64 };
                for &dx in &[bias, -bias] {
                    let nx = cx + dx;
                    if nx >= 0 && nx < w {
                        let side = (cy * w + nx) as usize;
                        if self.scratch_cells[side] == CellType::Air {
                            self.scratch_cells[side] = CellType::Water;
                            self.scratch_cells[idx] = CellType::Air;
                            Self::record_change(
                                &mut stats.active_bounds,
                                cx as u32,
                                cy as u32,
                                nx as u32,
                                cy as u32,
                            );
                            stats.moved_cells += 1;
                            break;
                        }
                    }
                }
            }
            CellType::Fire => {
                let life = &mut self.scratch_fire_life[idx];
                if *life == 0 {
                    self.scratch_cells[idx] = CellType::Air;
                    return;
                }
                *life -= 1;
                if cy > 0 {
                    let above = ((cy - 1) * w + cx) as usize;
                    if self.scratch_cells[above] == CellType::Air && (self.rng_u8() & 3) != 0 {
                        self.scratch_fire_life[above] =
                            self.scratch_fire_life[idx].saturating_sub(1);
                        self.scratch_cells[above] = CellType::Fire;
                        self.scratch_cells[idx] = CellType::Air;
                        self.scratch_fire_life[idx] = 0;
                        Self::record_change(
                            &mut stats.active_bounds,
                            cx as u32,
                            cy as u32,
                            cx as u32,
                            (cy - 1) as u32,
                        );
                        stats.moved_cells += 1;
                        return;
                    }
                }
                let spread_dirs: [(i64, i64); 4] = [(-1, 0), (1, 0), (0, -1), (0, 1)];
                if (self.rng_u8() & 15) == 0 {
                    let di = (self.rng_u8() as usize) % 4;
                    let (dx, dy) = spread_dirs[di];
                    let nx = cx + dx;
                    let ny = cy + dy;
                    if nx >= 0 && nx < w && ny >= 0 && ny < h {
                        let ni = (ny * w + nx) as usize;
                        if self.scratch_cells[ni] == CellType::Air
                            || self.scratch_cells[ni] == CellType::Gas
                        {
                            self.scratch_cells[ni] = CellType::Fire;
                            self.scratch_fire_life[ni] = 40 + (self.rng_u8() % 20);
                            Self::record_change(
                                &mut stats.active_bounds,
                                cx as u32,
                                cy as u32,
                                nx as u32,
                                ny as u32,
                            );
                            stats.fire_spread_count += 1;
                        }
                    }
                }
            }
            CellType::Gas => {
                if cy > 0 {
                    let above = ((cy - 1) * w + cx) as usize;
                    if self.scratch_cells[above] == CellType::Air {
                        self.scratch_cells[above] = CellType::Gas;
                        self.scratch_cells[idx] = CellType::Air;
                        Self::record_change(
                            &mut stats.active_bounds,
                            cx as u32,
                            cy as u32,
                            cx as u32,
                            (cy - 1) as u32,
                        );
                        stats.moved_cells += 1;
                        return;
                    }
                }
                let bias = if self.even_tick { 1i64 } else { -1i64 };
                for &dx in &[bias, -bias] {
                    let nx = cx + dx;
                    if nx >= 0 && nx < w {
                        let side = (cy * w + nx) as usize;
                        if self.scratch_cells[side] == CellType::Air {
                            self.scratch_cells[side] = CellType::Gas;
                            self.scratch_cells[idx] = CellType::Air;
                            Self::record_change(
                                &mut stats.active_bounds,
                                cx as u32,
                                cy as u32,
                                nx as u32,
                                cy as u32,
                            );
                            stats.moved_cells += 1;
                            break;
                        }
                    }
                }
            }
        }
    }

    /// Run `n` simulation steps. This function is part of the public API.
    pub fn step_n(&mut self, n: u32) {
        for _ in 0..n {
            self.step();
        }
    }

    /// Encode the full grid as RGBA pixel data using `palette`.
    pub fn to_image_data<F: Fn(CellType) -> [u8; 4]>(&self, palette: F) -> Vec<u8> {
        self.try_to_image_data(palette, &ProcgenLimits::default())
            .expect("CellularWorld::to_image_data overflowed image export size")
    }

    /// Encode the full grid as RGBA pixel data, rejecting oversized outputs before allocation.
    pub fn try_to_image_data<F: Fn(CellType) -> [u8; 4]>(
        &self,
        palette: F,
        limits: &ProcgenLimits,
    ) -> Result<Vec<u8>, ProcgenError> {
        let cap = checked_output_bytes(
            self.width,
            self.height,
            4,
            "cellular_world image export",
            limits,
        )?;
        let mut buf = Vec::with_capacity(cap);
        for &cell in &self.cells {
            buf.extend_from_slice(&palette(cell));
        }
        Ok(buf)
    }

    /// Encode a rectangular sub-region as RGBA pixel data using `palette`.
    pub fn to_image_data_region<F: Fn(CellType) -> [u8; 4]>(
        &self,
        cx0: u32,
        cy0: u32,
        cw: u32,
        ch: u32,
        palette: F,
    ) -> Vec<u8> {
        self.try_to_image_data_region(cx0, cy0, cw, ch, palette, &ProcgenLimits::default())
            .expect("CellularWorld::to_image_data_region overflowed image export size")
    }

    /// Encode a rectangular sub-region as RGBA pixel data, rejecting oversized outputs before allocation.
    pub fn try_to_image_data_region<F: Fn(CellType) -> [u8; 4]>(
        &self,
        cx0: u32,
        cy0: u32,
        cw: u32,
        ch: u32,
        palette: F,
        limits: &ProcgenLimits,
    ) -> Result<Vec<u8>, ProcgenError> {
        let cap = checked_output_bytes(cw, ch, 4, "cellular_world region export", limits)?;
        let mut buf = Vec::with_capacity(cap);
        for dy in 0..ch {
            for dx in 0..cw {
                let cx = cx0.saturating_add(dx);
                let cy = cy0.saturating_add(dy);
                let cell = self.get_cell(cx, cy);
                buf.extend_from_slice(&palette(cell));
            }
        }
        Ok(buf)
    }

    /// Return all `(cx,cy)` positions containing `cell_type`.
    pub fn find_cells(&self, cell_type: CellType) -> Vec<(u32, u32)> {
        let mut out = Vec::new();
        for cy in 0..self.height {
            for cx in 0..self.width {
                if self.cells[(cy * self.width + cx) as usize] == cell_type {
                    out.push((cx, cy));
                }
            }
        }
        out
    }

    /// Return the count of cells matching `cell_type`.
    pub fn count_cells(&self, cell_type: CellType) -> u32 {
        self.cells.iter().filter(|&&c| c == cell_type).count() as u32
    }

    /// Serialize the grid to a compact byte buffer (`width u32 LE` + `height u32 LE` + cell bytes).
    pub fn to_bytes(&self) -> Vec<u8> {
        let mut buf = Vec::with_capacity(24 + self.cells.len() * 2);
        buf.extend_from_slice(&CELLULAR_WORLD_MAGIC);
        buf.extend_from_slice(&CELLULAR_WORLD_VERSION.to_le_bytes());
        buf.extend_from_slice(&self.width.to_le_bytes());
        buf.extend_from_slice(&self.height.to_le_bytes());
        buf.extend_from_slice(&self.rng_state.to_le_bytes());
        buf.push(u8::from(self.even_tick));
        buf.extend_from_slice(&[0u8; 3]);
        for &cell in &self.cells {
            buf.push(cell as u8);
        }
        buf.extend_from_slice(&self.fire_life);
        buf
    }

    /// Deserialize a grid from a byte buffer produced by `to_bytes`; return `None` on malformed input.
    pub fn from_bytes(bytes: &[u8]) -> Option<Self> {
        Self::from_bytes_with_limits(bytes, &ProcgenLimits::default()).ok()
    }

    /// Deserialize a grid from a byte buffer produced by `to_bytes`, rejecting oversized or malformed payloads.
    pub fn from_bytes_with_limits(
        bytes: &[u8],
        limits: &ProcgenLimits,
    ) -> Result<Self, ProcgenError> {
        if bytes.len() >= 24 && bytes[0..4] == CELLULAR_WORLD_MAGIC {
            return Self::from_versioned_bytes(bytes, limits);
        }
        if bytes.len() < 8 {
            return Err(ProcgenError::InvalidLength {
                context: "cellular_world bytes header",
                expected: 8,
                actual: bytes.len(),
            });
        }
        let width = u32::from_le_bytes(bytes[0..4].try_into().expect("header width slice"));
        let height = u32::from_le_bytes(bytes[4..8].try_into().expect("header height slice"));
        validate_non_zero_dimensions(width, height)?;
        let total = checked_cell_count(width, height, limits)?;
        let expected = 8usize
            .checked_add(total)
            .expect("validated procgen cell count overflowed bytes length");
        if bytes.len() != expected {
            return Err(ProcgenError::InvalidLength {
                context: "cellular_world bytes payload",
                expected,
                actual: bytes.len(),
            });
        }
        let cells: Vec<CellType> = bytes[8..].iter().map(|&b| CellType::from_u8(b)).collect();
        Ok(Self {
            width,
            height,
            scratch_cells: vec![CellType::Air; total],
            scratch_fire_life: vec![0u8; total],
            cells,
            fire_life: vec![0u8; total],
            even_tick: true,
            rng_state: 0xDEAD_BEEF,
            last_step_stats: CellularWorldStepStats {
                summary: ProcgenReport {
                    seed: Some(0xDEAD_BEEF),
                    cell_count: total,
                    iterations: 0,
                    attempts: 1,
                },
                moved_cells: 0,
                fire_spread_count: 0,
                active_bounds: None,
            },
        })
    }

    /// Read current storage capacities for allocation regression tests; all four buffers should stay aligned to the same grid size.
    pub fn buffer_capacities(&self) -> (usize, usize, usize, usize) {
        (
            self.cells.capacity(),
            self.fire_life.capacity(),
            self.scratch_cells.capacity(),
            self.scratch_fire_life.capacity(),
        )
    }

    /// Advance the internal xorshift RNG and return one byte.
    fn rng_u8(&mut self) -> u8 {
        let mut x = self.rng_state;
        x ^= x << 13;
        x ^= x >> 17;
        x ^= x << 5;
        self.rng_state = x;
        x as u8
    }

    /// Return the exact internal RNG state for deterministic restore or serialization tests.
    pub fn rng_state(&self) -> u32 {
        self.rng_state
    }

    /// Overwrite the internal RNG state with an exact saved snapshot.
    pub fn set_rng_state(&mut self, rng_state: u32) {
        self.rng_state = rng_state;
    }

    /// Return diagnostics for the last completed `step`.
    pub fn last_step_stats(&self) -> &CellularWorldStepStats {
        &self.last_step_stats
    }

    fn record_change(
        active_bounds: &mut Option<CellularWorldActiveBounds>,
        x0: u32,
        y0: u32,
        x1: u32,
        y1: u32,
    ) {
        let min_x = x0.min(x1);
        let min_y = y0.min(y1);
        let max_x = x0.max(x1);
        let max_y = y0.max(y1);
        match active_bounds {
            Some(bounds) => {
                bounds.min_x = bounds.min_x.min(min_x);
                bounds.min_y = bounds.min_y.min(min_y);
                bounds.max_x = bounds.max_x.max(max_x);
                bounds.max_y = bounds.max_y.max(max_y);
            }
            None => {
                *active_bounds = Some(CellularWorldActiveBounds {
                    min_x,
                    min_y,
                    max_x,
                    max_y,
                });
            }
        }
    }

    fn from_versioned_bytes(bytes: &[u8], limits: &ProcgenLimits) -> Result<Self, ProcgenError> {
        let version = u32::from_le_bytes(bytes[4..8].try_into().expect("version slice"));
        if version != CELLULAR_WORLD_VERSION {
            return Err(ProcgenError::UnsupportedVersion {
                context: "cellular_world bytes",
                version,
            });
        }
        let width = u32::from_le_bytes(bytes[8..12].try_into().expect("width slice"));
        let height = u32::from_le_bytes(bytes[12..16].try_into().expect("height slice"));
        let rng_state = u32::from_le_bytes(bytes[16..20].try_into().expect("rng slice"));
        let even_tick = bytes[20] != 0;
        validate_non_zero_dimensions(width, height)?;
        let total = checked_cell_count(width, height, limits)?;
        let expected = 24usize
            .checked_add(total.checked_mul(2).expect("cell pair count"))
            .expect("validated versioned length");
        if bytes.len() != expected {
            return Err(ProcgenError::InvalidLength {
                context: "cellular_world versioned bytes payload",
                expected,
                actual: bytes.len(),
            });
        }
        let cell_start = 24;
        let fire_start = cell_start + total;
        let cells: Vec<CellType> = bytes[cell_start..fire_start]
            .iter()
            .map(|&b| CellType::from_u8(b))
            .collect();
        let fire_life = bytes[fire_start..].to_vec();
        Ok(Self {
            width,
            height,
            scratch_cells: vec![CellType::Air; total],
            scratch_fire_life: vec![0u8; total],
            cells,
            fire_life,
            even_tick,
            rng_state,
            last_step_stats: CellularWorldStepStats {
                summary: ProcgenReport {
                    seed: Some(u64::from(rng_state)),
                    cell_count: total,
                    iterations: 0,
                    attempts: 1,
                },
                moved_cells: 0,
                fire_spread_count: 0,
                active_bounds: None,
            },
        })
    }
}

/// Default RGBA palette mapping each `CellType` to a recognizable colour.
pub fn default_palette(cell: CellType) -> [u8; 4] {
    match cell {
        CellType::Air => [20, 20, 30, 255],
        CellType::Sand => [194, 178, 128, 255],
        CellType::Water => [64, 164, 223, 200],
        CellType::Rock => [120, 120, 120, 255],
        CellType::Fire => [230, 80, 20, 255],
        CellType::Gas => [140, 220, 120, 160],
    }
}
