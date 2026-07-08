//! Owns the runtime walkability grid that stores byte movement costs, diagonal policy, and HPA dirty rectangles.
//! Provides constructors, bulk mutation, byte import and export, snapshots, and cell queries over flat tile data.
//! Defines DiagonalMode parsing so Lua and engine callers share one source of truth for corner-cutting behavior.
//! Also enforces unit-size walkability checks, making this file the clearance boundary for multi-tile navigation.
//! This file is where chunk size, dirty invalidation hints, and neighbor enumeration rules are coordinated together.
//! Neighboring changes usually involve A*, HPA, render debug overlays, and Lua bindings that edit pathing grids.
//! Open this owner when navigation cost storage or directional movement policy changes across the pathfind stack.

use crate::log_msg;
use crate::runtime::log_messages::{NG01, NG02, NG03};
use std::collections::{HashMap, HashSet};
/// Controls which diagonal moves are permitted during pathfinding.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum DiagonalMode {
    /// No diagonal movement allowed.
    None,
    /// Diagonal movement always permitted, even past blocked corners.
    Always,
    /// Diagonal movement only when neither adjacent cardinal neighbour is blocked.
    NoCornerCut,
}
/// Conversion helpers between Lua string names and `DiagonalMode`.
impl DiagonalMode {
    /// Parse a case-insensitive Lua string to a `DiagonalMode`; return `None` for unknown strings.
    pub fn from_lua_str(s: &str) -> Option<Self> {
        match s.to_ascii_lowercase().as_str() {
            "none" => Some(Self::None),
            "always" => Some(Self::Always),
            "nocornercut" | "no_corner_cut" => Some(Self::NoCornerCut),
            _ => Option::None,
        }
    }
    /// Return the canonical lowercase Lua string for this mode.
    pub fn to_lua_str(self) -> &'static str {
        match self {
            Self::None => "none",
            Self::Always => "always",
            Self::NoCornerCut => "nocornercut",
        }
    }
}
/// Rebuild policy used when committing a batched grid update.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum UpdateRebuildMode {
    /// Leave any precomputed footprint caches stale until explicitly rebuilt.
    None,
    /// Refresh footprint caches only for dirty regions affected by the batch.
    DirtyChunks,
    /// Rebuild every footprint cache across the full grid.
    Full,
}
/// Conversion helpers between Lua string names and `UpdateRebuildMode`.
impl UpdateRebuildMode {
    /// Parse a case-insensitive Lua string to a rebuild mode; return `None` for unknown strings.
    pub fn from_lua_str(s: &str) -> Option<Self> {
        match s.to_ascii_lowercase().as_str() {
            "none" => Some(Self::None),
            "dirty_chunks" | "dirtychunks" => Some(Self::DirtyChunks),
            "full" => Some(Self::Full),
            _ => None,
        }
    }

    /// Return the canonical lowercase Lua string for this mode.
    pub fn to_lua_str(self) -> &'static str {
        match self {
            Self::None => "none",
            Self::DirtyChunks => "dirty_chunks",
            Self::Full => "full",
        }
    }
}
/// Rectangle footprint measured in grid cells.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct FootprintSpec {
    /// Width in cells.
    pub width: u32,
    /// Height in cells.
    pub height: u32,
}
impl FootprintSpec {
    /// Create a normalized footprint with both dimensions clamped to at least one cell.
    pub fn new(width: u32, height: u32) -> Self {
        Self {
            width: width.max(1),
            height: height.max(1),
        }
    }
}

#[derive(Debug, Clone)]
struct ClearanceCache {
    walkable: Vec<bool>,
    built_generation: Option<u64>,
}

impl ClearanceCache {
    fn new(size: usize) -> Self {
        Self {
            walkable: vec![false; size],
            built_generation: None,
        }
    }
}

#[derive(Debug, Clone, Default)]
struct PendingUpdate {
    dirty_rects: Vec<(u32, u32, u32, u32)>,
}
/// Runtime walkability grid: integer movement costs, dirty tracking, and snapshot support.
#[derive(Debug, Clone)]
pub struct NavGrid {
    /// Grid width in tiles.
    width: u32,
    /// Grid height in tiles.
    height: u32,
    /// Per-cell cost values; `0` means blocked, `1`–`254` are movement weights.
    costs: Vec<u8>,
    /// Chunk size used by HPA* hierarchy construction.
    chunk_size: u32,
    /// Current diagonal movement policy.
    diagonal_mode: DiagonalMode,
    /// Pending dirty regions awaiting hierarchy rebuild.
    dirty_rects: Vec<(u32, u32, u32, u32)>,
    /// Monotonic generation incremented when committed walkability or cost data changes.
    generation: u64,
    /// Named footprint definitions exposed to callers.
    footprint_profiles: HashMap<String, FootprintSpec>,
    /// Cached walkability masks keyed by footprint dimensions.
    clearance_caches: HashMap<FootprintSpec, ClearanceCache>,
    /// Batched pending edits collected between `begin_update` and `commit_update`.
    pending_update: Option<PendingUpdate>,
}
/// Construction, query, and mutation methods for `NavGrid`.
impl NavGrid {
    /// Return the flat storage length for `width * height`, panicking with context on overflow.
    fn grid_len(width: u32, height: u32) -> usize {
        width
            .checked_mul(height)
            .and_then(|len| usize::try_from(len).ok())
            .expect("NavGrid dimensions overflow addressable storage")
    }

    /// Return the flat cell index for `(x, y)`, or `None` when out-of-bounds.
    fn index(&self, x: u32, y: u32) -> Option<usize> {
        if x >= self.width || y >= self.height {
            return None;
        }
        y.checked_mul(self.width)
            .and_then(|row| row.checked_add(x))
            .and_then(|idx| usize::try_from(idx).ok())
    }

    fn flat_index(width: u32, x: u32, y: u32) -> usize {
        (y * width + x) as usize
    }

    /// Create a fully walkable `width × height` grid with all costs set to `1`.
    pub fn new(width: u32, height: u32) -> Self {
        log_msg!(debug, NG01, "{}x{}", width, height);
        Self {
            width,
            height,
            costs: vec![1u8; Self::grid_len(width, height)],
            chunk_size: 16,
            diagonal_mode: DiagonalMode::NoCornerCut,
            dirty_rects: Vec::new(),
            generation: 0,
            footprint_profiles: HashMap::new(),
            clearance_caches: HashMap::new(),
            pending_update: None,
        }
    }
    /// Create a grid from an existing flat cost buffer; panics if `costs.len() != width * height`.
    pub fn from_costs(width: u32, height: u32, costs: Vec<u8>) -> Self {
        assert_eq!(
            costs.len(),
            Self::grid_len(width, height),
            "costs length must equal width * height"
        );
        log_msg!(debug, NG02, "{}x{} {} costs", width, height, costs.len());
        Self {
            width,
            height,
            costs,
            chunk_size: 16,
            diagonal_mode: DiagonalMode::NoCornerCut,
            dirty_rects: Vec::new(),
            generation: 0,
            footprint_profiles: HashMap::new(),
            clearance_caches: HashMap::new(),
            pending_update: None,
        }
    }
    /// Return the grid width in tiles.
    pub fn get_width(&self) -> u32 {
        self.width
    }
    /// Return the grid height in tiles.
    pub fn get_height(&self) -> u32 {
        self.height
    }
    /// Return `(width, height)` as a tuple.
    pub fn get_dimensions(&self) -> (u32, u32) {
        (self.width, self.height)
    }
    /// Return the current mutation generation for cache invalidation and diagnostics.
    pub fn get_generation(&self) -> u64 {
        self.generation
    }
    /// Return the cost at `(x, y)`; returns `0` (blocked) for out-of-bounds coordinates.
    pub fn get_cost(&self, x: u32, y: u32) -> u8 {
        self.index(x, y).map_or(0, |idx| self.costs[idx])
    }
    /// Set the cost at `(x, y)`; silently ignores out-of-bounds coordinates.
    pub fn set_cost(&mut self, x: u32, y: u32, cost: u8) {
        if let Some(idx) = self.index(x, y) {
            if self.costs[idx] == cost {
                return;
            }
            log_msg!(trace, NG03, "({}, {})={}", x, y, cost);
            self.costs[idx] = cost;
            self.record_committed_change(x, y, 1, 1, UpdateRebuildMode::DirtyChunks);
        }
    }
    /// Return true when `(x, y)` has cost `0` (blocked) or is out-of-bounds.
    pub fn is_blocked(&self, x: u32, y: u32) -> bool {
        self.get_cost(x, y) == 0
    }
    /// Set `(x, y)` to cost `0` (blocked) or `1` (passable).
    pub fn set_blocked(&mut self, x: u32, y: u32, blocked: bool) {
        self.set_cost(x, y, if blocked { 0 } else { 1 });
    }
    /// Return true when a `unit_size × unit_size` footprint anchored at `(x, y)` is fully walkable.
    pub fn is_walkable(&self, x: u32, y: u32, unit_size: u32) -> bool {
        self.is_walkable_spec(FootprintSpec::new(unit_size, unit_size), x, y)
    }
    /// Return true when the named footprint anchored at `(x, y)` is fully walkable.
    pub fn is_walkable_for(&self, name: &str, x: u32, y: u32) -> bool {
        self.get_footprint(name)
            .is_some_and(|spec| self.is_walkable_spec(spec, x, y))
    }
    /// Store or replace a named footprint definition.
    pub fn define_footprint(
        &mut self,
        name: impl Into<String>,
        width: u32,
        height: u32,
    ) -> FootprintSpec {
        let spec = FootprintSpec::new(width, height);
        self.footprint_profiles.insert(name.into(), spec);
        self.clearance_caches
            .entry(spec)
            .or_insert_with(|| ClearanceCache::new(Self::grid_len(self.width, self.height)));
        spec
    }
    /// Return one named footprint definition when it exists.
    pub fn get_footprint(&self, name: &str) -> Option<FootprintSpec> {
        self.footprint_profiles.get(name).copied()
    }
    /// Rebuild clearance caches for all defined footprints or only the named subset.
    pub fn rebuild_clearance(&mut self, profiles: Option<&[String]>) -> usize {
        let specs = self.resolve_rebuild_specs(profiles);
        self.rebuild_clearance_specs(&specs);
        specs.len()
    }
    /// Set all cells to `cost`. This function is part of the public API.
    pub fn fill(&mut self, cost: u8) {
        if self.costs.iter().all(|existing| *existing == cost) {
            return;
        }
        self.costs.fill(cost);
        self.record_committed_change(
            0,
            0,
            self.width,
            self.height,
            UpdateRebuildMode::DirtyChunks,
        );
    }
    /// Set all cells in the axis-aligned rectangle at `(x, y, w, h)` to `cost`.
    pub fn fill_rect(&mut self, x: u32, y: u32, w: u32, h: u32, cost: u8) {
        let x_end = x.saturating_add(w).min(self.width);
        let y_end = y.saturating_add(h).min(self.height);
        let mut changed = false;
        for cy in y..y_end {
            for cx in x..x_end {
                if let Some(idx) = self.index(cx, cy) {
                    if self.costs[idx] == cost {
                        continue;
                    }
                    self.costs[idx] = cost;
                    changed = true;
                }
            }
        }
        if changed {
            self.record_committed_change(x, y, w, h, UpdateRebuildMode::DirtyChunks);
        }
    }
    /// Set all cells in the rectangle at `(x, y, w, h)` to blocked or passable.
    pub fn set_blocked_rect(&mut self, x: u32, y: u32, w: u32, h: u32, blocked: bool) {
        self.fill_rect(x, y, w, h, if blocked { 0 } else { 1 });
    }
    /// Set all cells in the rectangle at `(x, y, w, h)` to `cost`.
    pub fn set_cost_rect(&mut self, x: u32, y: u32, w: u32, h: u32, cost: u8) {
        self.fill_rect(x, y, w, h, cost);
    }
    /// Replace the cost buffer from `data`; return an error if the length does not match `width * height`.
    pub fn load_from_bytes(&mut self, data: &[u8]) -> Result<(), String> {
        let expected = Self::grid_len(self.width, self.height);
        if data.len() != expected {
            return Err(format!("expected {} bytes, got {}", expected, data.len()));
        }
        if self.costs == data {
            return Ok(());
        }
        self.costs.copy_from_slice(data);
        self.record_committed_change(
            0,
            0,
            self.width,
            self.height,
            UpdateRebuildMode::DirtyChunks,
        );
        Ok(())
    }
    /// Return a copy of the cost buffer as a byte vector.
    pub fn save_to_bytes(&self) -> Vec<u8> {
        self.costs.clone()
    }
    /// Set the chunk size used by HPA*; clamped to `[2, min(width, height)]`.
    pub fn set_chunk_size(&mut self, size: u32) {
        self.chunk_size = size.max(2).min(self.width.min(self.height).max(2));
    }
    /// Return the current HPA* chunk size.
    pub fn get_chunk_size(&self) -> u32 {
        self.chunk_size
    }
    /// Set the diagonal movement policy for neighbour queries.
    pub fn set_diagonal_mode(&mut self, mode: DiagonalMode) {
        self.diagonal_mode = mode;
    }
    /// Begin collecting batched navigation edits that are finalized by `commit_update`.
    pub fn begin_update(&mut self) {
        if self.pending_update.is_none() {
            self.pending_update = Some(PendingUpdate::default());
        }
    }
    /// Commit any batched navigation edits and refresh caches according to `rebuild`.
    pub fn commit_update(&mut self, rebuild: UpdateRebuildMode) -> usize {
        let Some(pending) = self.pending_update.take() else {
            return 0;
        };
        if pending.dirty_rects.is_empty() {
            return 0;
        }
        self.finish_committed_changes(&pending.dirty_rects, rebuild);
        pending.dirty_rects.len()
    }
    /// Return the current diagonal movement policy.
    pub fn get_diagonal_mode(&self) -> DiagonalMode {
        self.diagonal_mode
    }
    /// Record a dirty rectangle `(x, y, w, h)` for deferred hierarchy invalidation.
    pub fn set_dirty(&mut self, x: u32, y: u32, w: u32, h: u32) {
        self.dirty_rects.push((x, y, w, h));
    }
    /// Clear all pending dirty rectangles.
    pub fn clear_dirty(&mut self) {
        self.dirty_rects.clear();
    }
    /// Return the current slice of pending dirty rectangles.
    pub fn dirty_rects(&self) -> &[(u32, u32, u32, u32)] {
        &self.dirty_rects
    }
    /// Return the passable neighbours of `(x, y)` respecting the current `diagonal_mode`.
    pub fn neighbors(&self, x: u32, y: u32) -> Vec<(u32, u32)> {
        let mut result = Vec::with_capacity(8);
        let w = self.width;
        let h = self.height;
        let can_up = y > 0 && !self.is_blocked(x, y - 1);
        let can_down = y + 1 < h && !self.is_blocked(x, y + 1);
        let can_left = x > 0 && !self.is_blocked(x - 1, y);
        let can_right = x + 1 < w && !self.is_blocked(x + 1, y);
        if can_up {
            result.push((x, y - 1));
        }
        if can_down {
            result.push((x, y + 1));
        }
        if can_left {
            result.push((x - 1, y));
        }
        if can_right {
            result.push((x + 1, y));
        }
        match self.diagonal_mode {
            DiagonalMode::None => {}
            DiagonalMode::Always => {
                if y > 0 && x > 0 && !self.is_blocked(x - 1, y - 1) {
                    result.push((x - 1, y - 1));
                }
                if y > 0 && x + 1 < w && !self.is_blocked(x + 1, y - 1) {
                    result.push((x + 1, y - 1));
                }
                if y + 1 < h && x > 0 && !self.is_blocked(x - 1, y + 1) {
                    result.push((x - 1, y + 1));
                }
                if y + 1 < h && x + 1 < w && !self.is_blocked(x + 1, y + 1) {
                    result.push((x + 1, y + 1));
                }
            }
            DiagonalMode::NoCornerCut => {
                if can_up && can_left && !self.is_blocked(x - 1, y - 1) {
                    result.push((x - 1, y - 1));
                }
                if can_up && can_right && !self.is_blocked(x + 1, y - 1) {
                    result.push((x + 1, y - 1));
                }
                if can_down && can_left && !self.is_blocked(x - 1, y + 1) {
                    result.push((x - 1, y + 1));
                }
                if can_down && can_right && !self.is_blocked(x + 1, y + 1) {
                    result.push((x + 1, y + 1));
                }
            }
        }
        result
    }
    /// Return a deep copy of this grid without carrying over dirty rectangles.
    pub fn snapshot(&self) -> Self {
        Self {
            width: self.width,
            height: self.height,
            costs: self.costs.clone(),
            chunk_size: self.chunk_size,
            diagonal_mode: self.diagonal_mode,
            dirty_rects: Vec::new(),
            generation: self.generation,
            footprint_profiles: self.footprint_profiles.clone(),
            clearance_caches: self.clearance_caches.clone(),
            pending_update: None,
        }
    }
    /// Render the grid and optionally overlay a `path`, `start`, and `end` marker into an `ImageData`.
    pub fn draw_to_image(
        &self,
        cell_size: u32,
        path: Option<&[(u32, u32)]>,
        start: Option<(u32, u32)>,
        end: Option<(u32, u32)>,
    ) -> crate::image::ImageData {
        let mut img = crate::image::ImageData::new(self.width * cell_size, self.height * cell_size);
        img.fill(50, 50, 60, 255);
        for y in 0..self.height {
            for x in 0..self.width {
                let cost = self.get_cost(x, y);
                let (r, g, b) = if cost == 0 || cost == 255 {
                    (80u8, 30, 30)
                } else if cost > 3 {
                    (100, 80, 40)
                } else {
                    (50, 70, 50)
                };
                for py in 0..cell_size {
                    for px in 0..cell_size {
                        img.set_pixel(x * cell_size + px, y * cell_size + py, r, g, b, 255);
                    }
                }
            }
        }
        if let Some(p) = path {
            for &(px, py) in p {
                for dy in 2..cell_size.saturating_sub(2) {
                    for dx in 2..cell_size.saturating_sub(2) {
                        img.set_pixel(px * cell_size + dx, py * cell_size + dy, 0, 200, 100, 255);
                    }
                }
            }
        }
        if let Some((sx, sy)) = start {
            img.draw_circle(
                (sx * cell_size + cell_size / 2) as i32,
                (sy * cell_size + cell_size / 2) as i32,
                6,
                0,
                255,
                0,
                255,
            );
        }
        if let Some((ex, ey)) = end {
            img.draw_circle(
                (ex * cell_size + cell_size / 2) as i32,
                (ey * cell_size + cell_size / 2) as i32,
                6,
                255,
                0,
                0,
                255,
            );
        }
        img
    }

    pub(crate) fn is_walkable_spec(&self, spec: FootprintSpec, x: u32, y: u32) -> bool {
        if let Some(cache) = self.clearance_caches.get(&spec) {
            if cache.built_generation == Some(self.generation) {
                return self.cached_walkable(cache, x, y);
            }
        }
        self.scan_walkable_rect(x, y, spec)
    }

    fn cached_walkable(&self, cache: &ClearanceCache, x: u32, y: u32) -> bool {
        self.index(x, y)
            .and_then(|idx| cache.walkable.get(idx))
            .copied()
            .unwrap_or(false)
    }

    fn scan_walkable_rect(&self, x: u32, y: u32, spec: FootprintSpec) -> bool {
        Self::scan_walkable_rect_in(&self.costs, self.width, self.height, x, y, spec)
    }

    fn scan_walkable_rect_in(
        costs: &[u8],
        width: u32,
        height: u32,
        x: u32,
        y: u32,
        spec: FootprintSpec,
    ) -> bool {
        let Some(x_end) = x.checked_add(spec.width) else {
            return false;
        };
        let Some(y_end) = y.checked_add(spec.height) else {
            return false;
        };
        if x_end > width || y_end > height {
            return false;
        }
        for dy in 0..spec.height {
            for dx in 0..spec.width {
                if costs[Self::flat_index(width, x + dx, y + dy)] == 0 {
                    return false;
                }
            }
        }
        true
    }

    fn resolve_rebuild_specs(&self, profiles: Option<&[String]>) -> Vec<FootprintSpec> {
        let mut specs = Vec::new();
        let mut seen = HashSet::new();
        match profiles {
            Some(names) => {
                for name in names {
                    if let Some(spec) = self.get_footprint(name) {
                        if seen.insert(spec) {
                            specs.push(spec);
                        }
                    }
                }
            }
            None => {
                for spec in self.footprint_profiles.values().copied() {
                    if seen.insert(spec) {
                        specs.push(spec);
                    }
                }
            }
        }
        specs
    }

    fn rebuild_clearance_specs(&mut self, specs: &[FootprintSpec]) {
        for spec in specs.iter().copied() {
            self.rebuild_cache_for_spec(spec);
        }
    }

    fn rebuild_cache_for_spec(&mut self, spec: FootprintSpec) {
        let mut cache = ClearanceCache::new(Self::grid_len(self.width, self.height));
        let anchor_width = self.anchor_limit(self.width, spec.width);
        let anchor_height = self.anchor_limit(self.height, spec.height);
        for y in 0..anchor_height {
            for x in 0..anchor_width {
                let idx = self
                    .index(x, y)
                    .expect("anchor coordinates should always fit within the grid");
                cache.walkable[idx] = self.scan_walkable_rect(x, y, spec);
            }
        }
        cache.built_generation = Some(self.generation);
        self.clearance_caches.insert(spec, cache);
    }

    fn refresh_caches_for_rects(&mut self, rects: &[(u32, u32, u32, u32)]) {
        let specs: Vec<FootprintSpec> = self
            .clearance_caches
            .iter()
            .filter_map(|(spec, cache)| cache.built_generation.map(|_| *spec))
            .collect();
        for spec in specs {
            let stale = self
                .clearance_caches
                .get(&spec)
                .and_then(|cache| cache.built_generation)
                != Some(self.generation.saturating_sub(1));
            if stale {
                self.rebuild_cache_for_spec(spec);
                continue;
            }
            let anchor_width = self.anchor_limit(self.width, spec.width);
            let anchor_height = self.anchor_limit(self.height, spec.height);
            let Some(cache) = self.clearance_caches.get_mut(&spec) else {
                continue;
            };
            for &(x, y, w, h) in rects {
                let start_x = x.saturating_sub(spec.width.saturating_sub(1));
                let start_y = y.saturating_sub(spec.height.saturating_sub(1));
                let end_x = x.saturating_add(w).min(anchor_width);
                let end_y = y.saturating_add(h).min(anchor_height);
                for ay in start_y..end_y {
                    for ax in start_x..end_x {
                        let idx = Self::flat_index(self.width, ax, ay);
                        cache.walkable[idx] = Self::scan_walkable_rect_in(
                            &self.costs,
                            self.width,
                            self.height,
                            ax,
                            ay,
                            spec,
                        );
                    }
                }
            }
            cache.built_generation = Some(self.generation);
        }
    }

    fn anchor_limit(&self, total: u32, footprint: u32) -> u32 {
        total
            .checked_sub(footprint)
            .map(|remaining| remaining + 1)
            .unwrap_or(0)
    }

    fn clamp_rect(&self, x: u32, y: u32, w: u32, h: u32) -> Option<(u32, u32, u32, u32)> {
        if w == 0 || h == 0 || x >= self.width || y >= self.height {
            return None;
        }
        let x_end = x.saturating_add(w).min(self.width);
        let y_end = y.saturating_add(h).min(self.height);
        if x_end <= x || y_end <= y {
            None
        } else {
            Some((x, y, x_end - x, y_end - y))
        }
    }

    fn record_committed_change(
        &mut self,
        x: u32,
        y: u32,
        w: u32,
        h: u32,
        rebuild: UpdateRebuildMode,
    ) {
        let Some(rect) = self.clamp_rect(x, y, w, h) else {
            return;
        };
        if let Some(pending) = self.pending_update.as_mut() {
            pending.dirty_rects.push(rect);
        } else {
            self.finish_committed_changes(&[rect], rebuild);
        }
    }

    fn finish_committed_changes(
        &mut self,
        rects: &[(u32, u32, u32, u32)],
        rebuild: UpdateRebuildMode,
    ) {
        if rects.is_empty() {
            return;
        }
        self.generation = self.generation.saturating_add(1);
        self.dirty_rects.extend_from_slice(rects);
        match rebuild {
            UpdateRebuildMode::None => {}
            UpdateRebuildMode::DirtyChunks => self.refresh_caches_for_rects(rects),
            UpdateRebuildMode::Full => {
                let specs: Vec<FootprintSpec> = self.clearance_caches.keys().copied().collect();
                self.rebuild_clearance_specs(&specs);
            }
        }
    }
}
