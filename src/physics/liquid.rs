//! Owns the physics liquid implementation for the physics subsystem and keeps related runtime rules local here.
//! Keeps body state, simulation helpers, and authored world contracts so helpers stay close to invariants this updates.
//! Defines how physics liquid data is validated, transformed, or stored before neighboring systems consume it.
//! Separates physics liquid behavior from Lua bindings, tests, and sibling owners so integration stays readable.
//! Documents the boundary where physics code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing physics liquid defaults, lifecycle handling, validation, or data ownership rules.
//! Keeps failure paths and edge cases near the physics liquid state that explains them instead of spreading rules outward.
//! Preserves deterministic behavior by keeping physics liquid calculations explicit at their owning subsystem boundary.
//! Provides the local adaptation layer that lets callers reuse physics liquid rules without duplicating engine decisions.
//! Open this owner before sibling files when a regression centers on physics liquid state, helpers, or integration rules.

use super::body::BodyType;
use super::error::PhysicsError;
use super::limits::{
    checked_liquid_cells, validate_finite, validate_positive, validate_range, PhysicsLimits,
};
use super::terrain::TerrainMap;
use super::world::World;
use std::collections::HashSet;

const LIQUID_BYTES_VERSION: u32 = 1;
const LIQUID_CHUNK_SIZE: u32 = 16;
const LIQUID_MAX_AMOUNT: f32 = 1.0;
const LIQUID_EPSILON: f32 = 0.000_1;

fn read_u32(bytes: &[u8], offset: usize, context: &'static str) -> Result<u32, PhysicsError> {
    let end = offset.checked_add(4).ok_or(PhysicsError::InvalidLength {
        context,
        expected: usize::MAX,
        actual: bytes.len(),
    })?;
    let slice = bytes.get(offset..end).ok_or(PhysicsError::InvalidLength {
        context,
        expected: end,
        actual: bytes.len(),
    })?;
    let array: [u8; 4] = slice.try_into().map_err(|_| PhysicsError::InvalidLength {
        context,
        expected: end,
        actual: bytes.len(),
    })?;
    Ok(u32::from_le_bytes(array))
}

fn read_u16(bytes: &[u8], offset: usize, context: &'static str) -> Result<u16, PhysicsError> {
    let end = offset.checked_add(2).ok_or(PhysicsError::InvalidLength {
        context,
        expected: usize::MAX,
        actual: bytes.len(),
    })?;
    let slice = bytes.get(offset..end).ok_or(PhysicsError::InvalidLength {
        context,
        expected: end,
        actual: bytes.len(),
    })?;
    let array: [u8; 2] = slice.try_into().map_err(|_| PhysicsError::InvalidLength {
        context,
        expected: end,
        actual: bytes.len(),
    })?;
    Ok(u16::from_le_bytes(array))
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
struct LiquidChunkId {
    cx: u32,
    cy: u32,
}

/// Discrete authored liquid material stored per cell.
/// # Variants
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum LiquidKind {
    /// Standard water-like liquid with no intrinsic damage.
    Water,
    /// Hot liquid typically used for damage or hazards.
    Lava,
    /// Corrosive liquid typically used for damage-over-time gameplay.
    Acid,
    /// Project-defined liquid kind stored as an unsigned 16-bit id.
    Custom(u16),
}

impl LiquidKind {
    fn default_empty() -> Self {
        Self::Water
    }

    fn to_bytes(self) -> (u16, u16) {
        match self {
            Self::Water => (0, 0),
            Self::Lava => (1, 0),
            Self::Acid => (2, 0),
            Self::Custom(id) => (3, id),
        }
    }

    fn from_bytes(tag: u16, custom: u16) -> Self {
        match tag {
            0 => Self::Water,
            1 => Self::Lava,
            2 => Self::Acid,
            3 => Self::Custom(custom),
            _ => Self::Water,
        }
    }
}

/// One grid cell of liquid state.
/// # Fields
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct LiquidCell {
    /// Liquid fill amount in `0.0..=1.0`.
    pub amount: f32,
    /// Authored liquid material for non-empty cells.
    pub kind: LiquidKind,
}

impl Default for LiquidCell {
    fn default() -> Self {
        Self {
            amount: 0.0,
            kind: LiquidKind::default_empty(),
        }
    }
}

/// Tunable flow controls for one liquid step call.
/// # Fields
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct LiquidStepOptions {
    /// Maximum downward transfer per substep, in cell-fill units.
    pub gravity_flow: f32,
    /// Maximum lateral transfer per substep, in cell-fill units.
    pub sideways_flow: f32,
    /// Maximum upward pressure equalization per substep, in cell-fill units.
    pub pressure_flow: f32,
    /// Amount removed from every non-empty cell per substep, in cell-fill units.
    pub evaporation: f32,
    /// Maximum number of deterministic substeps to run in one `step` call.
    pub max_steps_per_frame: u32,
}

impl Default for LiquidStepOptions {
    fn default() -> Self {
        Self {
            gravity_flow: 1.0,
            sideways_flow: 0.35,
            pressure_flow: 0.1,
            evaporation: 0.0,
            max_steps_per_frame: 1,
        }
    }
}

impl LiquidStepOptions {
    /// Validate all numeric controls against the shared physics contract.
    pub fn validate(&self) -> Result<(), PhysicsError> {
        validate_range(
            "gravity_flow",
            f64::from(self.gravity_flow),
            0.0,
            f64::from(LIQUID_MAX_AMOUNT),
        )?;
        validate_range(
            "sideways_flow",
            f64::from(self.sideways_flow),
            0.0,
            f64::from(LIQUID_MAX_AMOUNT),
        )?;
        validate_range(
            "pressure_flow",
            f64::from(self.pressure_flow),
            0.0,
            f64::from(LIQUID_MAX_AMOUNT),
        )?;
        validate_range(
            "evaporation",
            f64::from(self.evaporation),
            0.0,
            f64::from(LIQUID_MAX_AMOUNT),
        )?;
        Ok(())
    }
}

/// Diagnostics returned after stepping a liquid map.
/// # Fields
#[derive(Debug, Clone, Copy, Default, PartialEq)]
pub struct LiquidStepStats {
    /// Total amount transferred between cells during the call.
    pub moved_amount: f32,
    /// Number of non-empty cells after the final substep.
    pub active_cells: u32,
    /// Number of chunks whose liquid state changed during the call.
    pub dirty_chunks: u32,
}

/// Sampling and force controls for liquid-to-body interaction.
/// # Fields
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct LiquidBodyForceOptions {
    /// Layer mask used to select eligible bodies.
    pub layer_mask: u32,
    /// Relative fluid density multiplier applied against world gravity.
    pub density: f32,
    /// Linear drag coefficient applied against sampled submerged velocity.
    pub drag: f32,
}

impl Default for LiquidBodyForceOptions {
    fn default() -> Self {
        Self {
            layer_mask: u32::MAX,
            density: 1.0,
            drag: 0.0,
        }
    }
}

impl LiquidBodyForceOptions {
    /// Validate liquid-to-body force controls.
    pub fn validate(&self) -> Result<(), PhysicsError> {
        validate_finite("density", f64::from(self.density))?;
        validate_finite("drag", f64::from(self.drag))?;
        if self.density < 0.0 {
            return Err(PhysicsError::ValueOutOfRange {
                field: "density",
                min: 0.0,
                max: f64::INFINITY,
                value: f64::from(self.density),
            });
        }
        if self.drag < 0.0 {
            return Err(PhysicsError::ValueOutOfRange {
                field: "drag",
                min: 0.0,
                max: f64::INFINITY,
                value: f64::from(self.drag),
            });
        }
        Ok(())
    }
}

/// Diagnostics returned after applying liquid forces to a world.
/// # Fields
#[derive(Debug, Clone, Copy, Default, PartialEq, Eq)]
pub struct LiquidBodyForceStats {
    /// Number of dynamic bodies that matched the layer mask.
    pub affected_bodies: u32,
    /// Number of bodies that sampled any non-zero liquid amount.
    pub submerged_bodies: u32,
}

/// Separate grid-based liquid storage used for leaking tanks, settling, and simple buoyancy sampling.
/// # Fields
pub struct LiquidMap {
    /// Grid width in cells.
    pub width: u32,
    /// Grid height in cells.
    pub height: u32,
    /// World units per cell side.
    pub cell_size: f32,
    /// World-space x origin of the grid.
    pub offset_x: f32,
    /// World-space y origin of the grid.
    pub offset_y: f32,
    cells: Vec<LiquidCell>,
    dirty_chunks: HashSet<LiquidChunkId>,
}

impl LiquidMap {
    fn full_dirty_set(width: u32, height: u32) -> HashSet<LiquidChunkId> {
        let chunk_cols = width.div_ceil(LIQUID_CHUNK_SIZE);
        let chunk_rows = height.div_ceil(LIQUID_CHUNK_SIZE);
        let mut dirty = HashSet::new();
        for cy in 0..chunk_rows {
            for cx in 0..chunk_cols {
                dirty.insert(LiquidChunkId { cx, cy });
            }
        }
        dirty
    }

    fn cell_index(&self, cx: u32, cy: u32) -> usize {
        (cy * self.width + cx) as usize
    }

    fn index_to_cell(&self, idx: usize) -> (u32, u32) {
        let idx = idx as u32;
        (idx % self.width, idx / self.width)
    }

    fn current_amount(current: &[LiquidCell], delta: &[f32], idx: usize) -> f32 {
        (current[idx].amount + delta[idx]).clamp(0.0, LIQUID_MAX_AMOUNT)
    }

    fn mark_dirty(&mut self, cx: u32, cy: u32) {
        self.dirty_chunks.insert(LiquidChunkId {
            cx: cx / LIQUID_CHUNK_SIZE,
            cy: cy / LIQUID_CHUNK_SIZE,
        });
    }

    /// Return chunks with liquid changes pending downstream save/render/minimap work.
    pub fn dirty_chunks(&self) -> Vec<(u32, u32)> {
        let mut chunks = self
            .dirty_chunks
            .iter()
            .map(|chunk| (chunk.cx, chunk.cy))
            .collect::<Vec<_>>();
        chunks.sort();
        chunks
    }

    fn neighbor_index(&self, cx: i32, cy: i32) -> Option<usize> {
        if cx < 0 || cy < 0 || cx >= self.width as i32 || cy >= self.height as i32 {
            return None;
        }
        Some(self.cell_index(cx as u32, cy as u32))
    }

    fn linked_amount_at(&self, wx: f32, wy: f32, terrain: Option<&TerrainMap>) -> f32 {
        let Some((cx, cy)) = self.world_to_cell(wx, wy) else {
            return 0.0;
        };
        if terrain.is_some_and(|map| self.is_blocked_by_terrain(cx, cy, map)) {
            return 0.0;
        }
        self.cells[self.cell_index(cx, cy)].amount
    }

    fn transfer(
        &self,
        current: &[LiquidCell],
        delta: &mut [f32],
        next_kinds: &mut [LiquidKind],
        from_idx: usize,
        to_idx: usize,
        requested: f32,
    ) -> f32 {
        if requested <= LIQUID_EPSILON {
            return 0.0;
        }
        let from_amount = Self::current_amount(current, delta, from_idx);
        let to_amount = Self::current_amount(current, delta, to_idx);
        let space = (LIQUID_MAX_AMOUNT - to_amount).max(0.0);
        let flow = requested.min(from_amount).min(space);
        if flow <= LIQUID_EPSILON {
            return 0.0;
        }
        delta[from_idx] -= flow;
        delta[to_idx] += flow;
        if to_amount <= LIQUID_EPSILON || flow >= to_amount {
            next_kinds[to_idx] = current[from_idx].kind;
        }
        flow
    }

    fn step_once(
        &mut self,
        terrain: Option<&TerrainMap>,
        options: &LiquidStepOptions,
    ) -> LiquidStepStats {
        let mut current = self.cells.clone();
        if let Some(terrain) = terrain {
            for cy in 0..self.height {
                for cx in 0..self.width {
                    if self.is_blocked_by_terrain(cx, cy, terrain) {
                        current[self.cell_index(cx, cy)] = LiquidCell::default();
                    }
                }
            }
        }

        let mut delta = vec![0.0f32; current.len()];
        let mut next_kinds = current.iter().map(|cell| cell.kind).collect::<Vec<_>>();
        let mut moved_amount = 0.0;
        self.dirty_chunks.clear();

        for cy in (0..self.height).rev() {
            for cx in 0..self.width {
                let idx = self.cell_index(cx, cy);
                let mut remaining = Self::current_amount(&current, &delta, idx);
                if remaining <= LIQUID_EPSILON {
                    continue;
                }
                if terrain.is_some_and(|map| self.is_blocked_by_terrain(cx, cy, map)) {
                    delta[idx] = -current[idx].amount;
                    continue;
                }

                if let Some(down_idx) = self.neighbor_index(cx as i32, cy as i32 + 1) {
                    if !terrain.is_some_and(|map| self.is_blocked_by_terrain(cx, cy + 1, map)) {
                        let flowed = self.transfer(
                            &current,
                            &mut delta,
                            &mut next_kinds,
                            idx,
                            down_idx,
                            options.gravity_flow,
                        );
                        moved_amount += flowed;
                        remaining -= flowed;
                    }
                }

                if remaining > LIQUID_EPSILON && options.sideways_flow > 0.0 {
                    let side_offsets = if cy % 2 == 0 { [-1, 1] } else { [1, -1] };
                    for dx in side_offsets {
                        let Some(side_idx) = self.neighbor_index(cx as i32 + dx, cy as i32) else {
                            continue;
                        };
                        let side_cx = (cx as i32 + dx) as u32;
                        if terrain.is_some_and(|map| self.is_blocked_by_terrain(side_cx, cy, map)) {
                            continue;
                        }
                        let side_amount = Self::current_amount(&current, &delta, side_idx);
                        let diff = remaining - side_amount;
                        if diff <= LIQUID_EPSILON {
                            continue;
                        }
                        let requested = options.sideways_flow.min(diff * 0.5).min(remaining);
                        let flowed = self.transfer(
                            &current,
                            &mut delta,
                            &mut next_kinds,
                            idx,
                            side_idx,
                            requested,
                        );
                        moved_amount += flowed;
                        remaining -= flowed;
                        if remaining <= LIQUID_EPSILON {
                            break;
                        }
                    }
                }

                if remaining > LIQUID_EPSILON && options.pressure_flow > 0.0 {
                    if let Some(up_idx) = self.neighbor_index(cx as i32, cy as i32 - 1) {
                        if !terrain.is_some_and(|map| {
                            self.is_blocked_by_terrain(cx, cy.saturating_sub(1), map)
                        }) {
                            let up_amount = Self::current_amount(&current, &delta, up_idx);
                            let requested = options
                                .pressure_flow
                                .min((remaining - up_amount - 0.25).max(0.0) * 0.5);
                            let flowed = self.transfer(
                                &current,
                                &mut delta,
                                &mut next_kinds,
                                idx,
                                up_idx,
                                requested,
                            );
                            moved_amount += flowed;
                            remaining -= flowed;
                        }
                    }
                }

                if options.evaporation > 0.0 && remaining > LIQUID_EPSILON {
                    let evaporated = remaining.min(options.evaporation);
                    delta[idx] -= evaporated;
                }
            }
        }

        let mut active_cells = 0u32;
        for idx in 0..self.cells.len() {
            let (cx, cy) = self.index_to_cell(idx);
            let mut next_cell = LiquidCell {
                amount: (current[idx].amount + delta[idx]).clamp(0.0, LIQUID_MAX_AMOUNT),
                kind: next_kinds[idx],
            };
            if next_cell.amount <= LIQUID_EPSILON {
                next_cell.amount = 0.0;
                next_cell.kind = LiquidKind::default_empty();
            } else {
                active_cells += 1;
            }
            if self.cells[idx] != next_cell {
                self.mark_dirty(cx, cy);
            }
            self.cells[idx] = next_cell;
        }

        LiquidStepStats {
            moved_amount,
            active_cells,
            dirty_chunks: self.dirty_chunks.len() as u32,
        }
    }

    fn sample_submerged_fraction(
        &self,
        body: &super::body::Body,
        terrain: Option<&TerrainMap>,
    ) -> f32 {
        let sample_half_w = (body.width * 0.25).max(0.0);
        let sample_half_h = (body.height * 0.25).max(0.0);
        let samples = [
            (0.0, 0.0),
            (-sample_half_w, 0.0),
            (sample_half_w, 0.0),
            (0.0, -sample_half_h),
            (0.0, sample_half_h),
        ];
        let mut sum = 0.0;
        for (dx, dy) in samples {
            sum += self.linked_amount_at(body.position.x + dx, body.position.y + dy, terrain);
        }
        (sum / samples.len() as f32).clamp(0.0, 1.0)
    }

    /// Creates an empty liquid map using strict shared physics validation.
    pub fn try_new(width: u32, height: u32, cell_size: f32) -> Result<Self, PhysicsError> {
        Self::try_new_with_limits(width, height, cell_size, &PhysicsLimits::default())
    }

    /// Creates an empty liquid map using explicit shared physics limits.
    pub fn try_new_with_limits(
        width: u32,
        height: u32,
        cell_size: f32,
        limits: &PhysicsLimits,
    ) -> Result<Self, PhysicsError> {
        if width == 0 || height == 0 {
            return Err(PhysicsError::InvalidLiquidDimensions { width, height });
        }
        validate_positive("cell_size", f64::from(cell_size))?;
        if cell_size < limits.min_cell_size {
            return Err(PhysicsError::ValueOutOfRange {
                field: "cell_size",
                min: f64::from(limits.min_cell_size),
                max: f64::from(f32::MAX),
                value: f64::from(cell_size),
            });
        }
        let total = checked_liquid_cells(width, height, limits)?;
        Ok(Self {
            width,
            height,
            cell_size,
            offset_x: 0.0,
            offset_y: 0.0,
            cells: vec![LiquidCell::default(); total],
            dirty_chunks: HashSet::new(),
        })
    }

    /// Creates an empty liquid map, clamping invalid inputs to safe fallback values.
    pub fn new(width: u32, height: u32, cell_size: f32) -> Self {
        Self::try_new(width, height, cell_size).unwrap_or_else(|_| Self {
            width: width.max(1),
            height: height.max(1),
            cell_size: if cell_size.is_finite() {
                cell_size.abs().max(1.0)
            } else {
                1.0
            },
            offset_x: 0.0,
            offset_y: 0.0,
            cells: vec![
                LiquidCell::default();
                usize::try_from(width.max(1) * height.max(1)).unwrap_or(1)
            ],
            dirty_chunks: HashSet::new(),
        })
    }

    /// Validates that a linked terrain grid shares the same size, cell size, and origin.
    pub fn validate_terrain_compatibility(&self, terrain: &TerrainMap) -> Result<(), PhysicsError> {
        let same_cell_size = (terrain.cell_size - self.cell_size).abs() <= f32::EPSILON;
        let same_offsets = (terrain.offset_x - self.offset_x).abs() <= f32::EPSILON
            && (terrain.offset_y - self.offset_y).abs() <= f32::EPSILON;
        if self.width != terrain.width
            || self.height != terrain.height
            || !same_cell_size
            || !same_offsets
        {
            return Err(PhysicsError::ConfigMismatch {
                context: "physics liquid terrain",
                detail: format!(
                    "liquid {}x{} @ {} ({}, {}) must match terrain {}x{} @ {} ({}, {})",
                    self.width,
                    self.height,
                    self.cell_size,
                    self.offset_x,
                    self.offset_y,
                    terrain.width,
                    terrain.height,
                    terrain.cell_size,
                    terrain.offset_x,
                    terrain.offset_y
                ),
            });
        }
        Ok(())
    }

    /// Sets one cell to the given amount and kind.
    pub fn try_set_cell(
        &mut self,
        cx: u32,
        cy: u32,
        amount: f32,
        kind: LiquidKind,
    ) -> Result<(), PhysicsError> {
        validate_range(
            "amount",
            f64::from(amount),
            0.0,
            f64::from(LIQUID_MAX_AMOUNT),
        )?;
        if cx >= self.width || cy >= self.height {
            return Ok(());
        }
        let idx = self.cell_index(cx, cy);
        let next_cell = if amount <= LIQUID_EPSILON {
            LiquidCell::default()
        } else {
            LiquidCell { amount, kind }
        };
        if self.cells[idx] != next_cell {
            self.cells[idx] = next_cell;
            self.mark_dirty(cx, cy);
        }
        Ok(())
    }

    /// Sets one cell to the given amount and kind, ignoring invalid inputs.
    pub fn set_cell(&mut self, cx: u32, cy: u32, amount: f32, kind: LiquidKind) {
        let _ = self.try_set_cell(cx, cy, amount, kind);
    }

    /// Returns one cell, or an empty default cell when out of bounds.
    pub fn get_cell(&self, cx: u32, cy: u32) -> LiquidCell {
        if cx >= self.width || cy >= self.height {
            return LiquidCell::default();
        }
        self.cells[self.cell_index(cx, cy)]
    }

    /// Sets every cell in the rectangle to the requested amount and kind.
    pub fn try_fill_rect(
        &mut self,
        x: u32,
        y: u32,
        width: u32,
        height: u32,
        amount: f32,
        kind: LiquidKind,
    ) -> Result<(), PhysicsError> {
        validate_range(
            "amount",
            f64::from(amount),
            0.0,
            f64::from(LIQUID_MAX_AMOUNT),
        )?;
        let x1 = x.saturating_add(width).min(self.width);
        let y1 = y.saturating_add(height).min(self.height);
        for cy in y..y1 {
            for cx in x..x1 {
                self.try_set_cell(cx, cy, amount, kind)?;
            }
        }
        Ok(())
    }

    /// Sets every cell in the rectangle to the requested amount and kind, ignoring invalid inputs.
    pub fn fill_rect(
        &mut self,
        x: u32,
        y: u32,
        width: u32,
        height: u32,
        amount: f32,
        kind: LiquidKind,
    ) {
        let _ = self.try_fill_rect(x, y, width, height, amount, kind);
    }

    /// Removes up to `amount` from every cell in the rectangle.
    pub fn try_drain_rect(
        &mut self,
        x: u32,
        y: u32,
        width: u32,
        height: u32,
        amount: f32,
    ) -> Result<(), PhysicsError> {
        validate_range(
            "amount",
            f64::from(amount),
            0.0,
            f64::from(LIQUID_MAX_AMOUNT),
        )?;
        let x1 = x.saturating_add(width).min(self.width);
        let y1 = y.saturating_add(height).min(self.height);
        for cy in y..y1 {
            for cx in x..x1 {
                let idx = self.cell_index(cx, cy);
                let next_amount = (self.cells[idx].amount - amount).max(0.0);
                let next_cell = if next_amount <= LIQUID_EPSILON {
                    LiquidCell::default()
                } else {
                    LiquidCell {
                        amount: next_amount,
                        kind: self.cells[idx].kind,
                    }
                };
                if self.cells[idx] != next_cell {
                    self.cells[idx] = next_cell;
                    self.mark_dirty(cx, cy);
                }
            }
        }
        Ok(())
    }

    /// Removes up to `amount` from every cell in the rectangle, ignoring invalid inputs.
    pub fn drain_rect(&mut self, x: u32, y: u32, width: u32, height: u32, amount: f32) {
        let _ = self.try_drain_rect(x, y, width, height, amount);
    }

    /// Returns the total liquid amount across every cell.
    pub fn total_amount(&self) -> f32 {
        self.cells.iter().map(|cell| cell.amount).sum()
    }

    /// Returns the number of non-empty cells.
    pub fn active_cell_count(&self) -> u32 {
        self.cells
            .iter()
            .filter(|cell| cell.amount > LIQUID_EPSILON)
            .count() as u32
    }

    /// Converts one world-space point into a liquid cell coordinate when the point is inside the map.
    pub fn world_to_cell(&self, wx: f32, wy: f32) -> Option<(u32, u32)> {
        if !wx.is_finite() || !wy.is_finite() {
            return None;
        }
        let cx = ((wx - self.offset_x) / self.cell_size).floor() as i32;
        let cy = ((wy - self.offset_y) / self.cell_size).floor() as i32;
        if cx < 0 || cy < 0 || cx >= self.width as i32 || cy >= self.height as i32 {
            return None;
        }
        Some((cx as u32, cy as u32))
    }

    /// Returns true when the linked terrain treats the requested cell as solid.
    pub fn is_blocked_by_terrain(&self, cx: u32, cy: u32, terrain: &TerrainMap) -> bool {
        terrain.get_cell(cx, cy)
    }

    /// Steps the liquid map without terrain blocking.
    pub fn step(&mut self, options: LiquidStepOptions) -> Result<LiquidStepStats, PhysicsError> {
        self.step_with_limits(options, &PhysicsLimits::default())
    }

    /// Steps the liquid map without terrain blocking while honoring explicit shared physics limits.
    pub fn step_with_limits(
        &mut self,
        options: LiquidStepOptions,
        limits: &PhysicsLimits,
    ) -> Result<LiquidStepStats, PhysicsError> {
        options.validate()?;
        let active_cells = u64::from(self.active_cell_count());
        if active_cells > limits.max_active_liquid_cells {
            return Err(PhysicsError::CountLimitExceeded {
                context: "physics active liquid cells",
                count: usize::try_from(active_cells).unwrap_or(usize::MAX),
                max: usize::try_from(limits.max_active_liquid_cells).unwrap_or(usize::MAX),
            });
        }
        let steps = options.max_steps_per_frame.max(1);
        let mut stats = LiquidStepStats::default();
        for _ in 0..steps {
            let substep = self.step_once(None, &options);
            stats.moved_amount += substep.moved_amount;
            stats.active_cells = substep.active_cells;
            stats.dirty_chunks = substep.dirty_chunks;
        }
        Ok(stats)
    }

    /// Steps the liquid map while treating solid terrain cells as blocked.
    pub fn step_with_terrain(
        &mut self,
        terrain: &TerrainMap,
        options: LiquidStepOptions,
    ) -> Result<LiquidStepStats, PhysicsError> {
        self.step_with_terrain_with_limits(terrain, options, &PhysicsLimits::default())
    }

    /// Steps the liquid map with terrain blocking while honoring explicit shared physics limits.
    pub fn step_with_terrain_with_limits(
        &mut self,
        terrain: &TerrainMap,
        options: LiquidStepOptions,
        limits: &PhysicsLimits,
    ) -> Result<LiquidStepStats, PhysicsError> {
        self.validate_terrain_compatibility(terrain)?;
        options.validate()?;
        let active_cells = u64::from(self.active_cell_count());
        if active_cells > limits.max_active_liquid_cells {
            return Err(PhysicsError::CountLimitExceeded {
                context: "physics active liquid cells",
                count: usize::try_from(active_cells).unwrap_or(usize::MAX),
                max: usize::try_from(limits.max_active_liquid_cells).unwrap_or(usize::MAX),
            });
        }
        let steps = options.max_steps_per_frame.max(1);
        let mut stats = LiquidStepStats::default();
        for _ in 0..steps {
            let substep = self.step_once(Some(terrain), &options);
            stats.moved_amount += substep.moved_amount;
            stats.active_cells = substep.active_cells;
            stats.dirty_chunks = substep.dirty_chunks;
        }
        Ok(stats)
    }

    /// Returns the liquid amount at one world-space point, or zero when outside the map.
    pub fn get_amount_at(&self, wx: f32, wy: f32) -> f32 {
        self.linked_amount_at(wx, wy, None)
    }

    /// Returns the liquid amount at one world-space point while respecting solid terrain blockers.
    pub fn get_amount_at_with_terrain(&self, wx: f32, wy: f32, terrain: &TerrainMap) -> f32 {
        self.linked_amount_at(wx, wy, Some(terrain))
    }

    /// Returns the surface level in world-space Y for the column containing the point, or `None` when empty.
    pub fn get_level_at(&self, wx: f32, wy: f32) -> Option<f32> {
        self.level_at_internal(wx, wy, None)
    }

    /// Returns the surface level in world-space Y while skipping solid terrain cells in the sampled column.
    pub fn get_level_at_with_terrain(&self, wx: f32, wy: f32, terrain: &TerrainMap) -> Option<f32> {
        self.level_at_internal(wx, wy, Some(terrain))
    }

    fn level_at_internal(&self, wx: f32, wy: f32, terrain: Option<&TerrainMap>) -> Option<f32> {
        let (cx, _) = self.world_to_cell(wx, wy)?;
        for cy in 0..self.height {
            if terrain.is_some_and(|map| self.is_blocked_by_terrain(cx, cy, map)) {
                continue;
            }
            let cell = self.get_cell(cx, cy);
            if cell.amount <= LIQUID_EPSILON {
                continue;
            }
            let cell_top = self.offset_y + cy as f32 * self.cell_size;
            let fill_offset =
                (LIQUID_MAX_AMOUNT - cell.amount.clamp(0.0, LIQUID_MAX_AMOUNT)) * self.cell_size;
            return Some(cell_top + fill_offset);
        }
        None
    }

    /// Applies sampled buoyancy and drag forces to matching dynamic bodies in the world.
    pub fn apply_body_forces(
        &self,
        world: &mut World,
        terrain: Option<&TerrainMap>,
        options: LiquidBodyForceOptions,
    ) -> Result<LiquidBodyForceStats, PhysicsError> {
        options.validate()?;
        if let Some(terrain) = terrain {
            self.validate_terrain_compatibility(terrain)?;
        }
        let (gravity_x, gravity_y) = world.get_gravity();
        let mut stats = LiquidBodyForceStats::default();
        for body_id in world.get_body_ids() {
            let Some(body) = world.get_body(body_id) else {
                continue;
            };
            if body.body_type != BodyType::Dynamic || body.layer & options.layer_mask == 0 {
                continue;
            }
            stats.affected_bodies += 1;
            let body_snapshot = (
                body.mass,
                body.velocity.x,
                body.velocity.y,
                body.width,
                body.height,
                body.position.x,
                body.position.y,
            );
            let submerged = self.sample_submerged_fraction(body, terrain);
            if submerged <= LIQUID_EPSILON {
                continue;
            }
            stats.submerged_bodies += 1;
            let material_buoyancy = world
                .get_body_material(body_id)
                .map(|material| material.buoyancy)
                .unwrap_or(0.0);
            let buoyancy_scale = options.density * submerged * (1.0 + material_buoyancy);
            let (mass, velocity_x, velocity_y, _, _, _, _) = body_snapshot;
            world.apply_force(
                body_id,
                -gravity_x * mass * buoyancy_scale - velocity_x * mass * options.drag * submerged,
                -gravity_y * mass * buoyancy_scale - velocity_y * mass * options.drag * submerged,
            );
        }
        Ok(stats)
    }

    /// Serializes the liquid grid into a compact binary format.
    pub fn to_bytes(&self) -> Vec<u8> {
        let mut buf = Vec::with_capacity(16 + self.cells.len() * 8);
        buf.extend_from_slice(&LIQUID_BYTES_VERSION.to_le_bytes());
        buf.extend_from_slice(&self.width.to_le_bytes());
        buf.extend_from_slice(&self.height.to_le_bytes());
        buf.extend_from_slice(&self.cell_size.to_bits().to_le_bytes());
        for cell in &self.cells {
            buf.extend_from_slice(&cell.amount.to_bits().to_le_bytes());
            let (tag, custom) = cell.kind.to_bytes();
            buf.extend_from_slice(&tag.to_le_bytes());
            buf.extend_from_slice(&custom.to_le_bytes());
        }
        buf
    }

    /// Deserializes a liquid map from bytes using explicit shared physics limits.
    pub fn from_bytes_with_limits(
        bytes: &[u8],
        limits: &PhysicsLimits,
    ) -> Result<Self, PhysicsError> {
        if bytes.len() < 16 {
            return Err(PhysicsError::InvalidLength {
                context: "physics liquid bytes",
                expected: 16,
                actual: bytes.len(),
            });
        }
        let version = read_u32(bytes, 0, "physics liquid bytes")?;
        if version != LIQUID_BYTES_VERSION {
            return Err(PhysicsError::UnsupportedVersion {
                context: "physics liquid bytes",
                version,
            });
        }
        let width = read_u32(bytes, 4, "physics liquid bytes")?;
        let height = read_u32(bytes, 8, "physics liquid bytes")?;
        let cell_size = f32::from_bits(read_u32(bytes, 12, "physics liquid bytes")?);
        let total = checked_liquid_cells(width, height, limits)?;
        let expected_len = 16 + total * 8;
        if bytes.len() != expected_len {
            return Err(PhysicsError::InvalidLength {
                context: "physics liquid bytes",
                expected: expected_len,
                actual: bytes.len(),
            });
        }
        let mut liquid = Self::try_new_with_limits(width, height, cell_size, limits)?;
        let mut cursor = 16usize;
        for cell in &mut liquid.cells {
            let amount = f32::from_bits(read_u32(bytes, cursor, "physics liquid bytes")?);
            validate_finite("liquid amount", f64::from(amount))?;
            let tag = read_u16(bytes, cursor + 4, "physics liquid bytes")?;
            let custom = read_u16(bytes, cursor + 6, "physics liquid bytes")?;
            cursor += 8;
            cell.amount = amount.clamp(0.0, LIQUID_MAX_AMOUNT);
            cell.kind = if cell.amount <= LIQUID_EPSILON {
                LiquidKind::default_empty()
            } else {
                LiquidKind::from_bytes(tag, custom)
            };
        }
        liquid.dirty_chunks = Self::full_dirty_set(width, height);
        Ok(liquid)
    }

    /// Deserializes a liquid map from bytes, returning `None` on invalid input.
    pub fn from_bytes(bytes: &[u8]) -> Option<Self> {
        Self::from_bytes_with_limits(bytes, &PhysicsLimits::default()).ok()
    }

    /// Loads bytes into this map when dimensions and cell size match.
    pub fn load_from_bytes(&mut self, bytes: &[u8]) -> bool {
        match Self::from_bytes_with_limits(bytes, &PhysicsLimits::default()) {
            Ok(loaded)
                if loaded.width == self.width
                    && loaded.height == self.height
                    && (loaded.cell_size - self.cell_size).abs() <= f32::EPSILON =>
            {
                self.cells = loaded.cells;
                self.dirty_chunks = loaded.dirty_chunks;
                true
            }
            _ => false,
        }
    }
}
