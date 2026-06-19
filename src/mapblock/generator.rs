//! This file owns the operational mapblock engine that runs scripts, tracks RNG, and mutates placement state over time.
//! `MapBlockGenerator` stores config, grid, rules, orientation, groups, levels, paint ops, and output tile sizing knobs.
//! It reuses the shared `procgen::Lcg` so deterministic picks follow one engine-wide RNG contract.
//! `generate` orchestrates the whole build, resetting state, running each script step, and then materializing output.
//! Random, fixed, edge, auto, rectangle-paint, and shape-solver step handlers all live here as runtime control flow.
//! Weighted block choice and candidate ordering stay here because authored content selection is step execution logic.
//! Backtracking shape solving stays local because it recursively consumes placement candidates against the live grid state.
//! `MapBlockReport` and `place_candidate` bridge execution outcomes into diagnostics, `PlacementGrid`, and `MultiLevelMap`.
//! Open it when generation behavior changes; blocks, scripts, legality checks, and result export live in sibling owners.

use super::config::MapBlockConfig;
use super::constraints::NeighborRules;
use super::group::MapGroup;
use super::multilevel::MultiLevelMap;
use super::orientation::MapOrientation;
use super::output::{MapBlockResult, MapBlockResultBuild, PaintRectOp};
use super::placement::{
    find_valid_placements_cached, PlacedBlock, PlacementCandidate, PlacementGrid, PlacementSearch,
    PlacementTransformCache,
};
use super::script::{MapScript, StepType};
use crate::procgen::lcg::Lcg;
use std::collections::HashMap;
use std::time::Instant;

const MAPBLOCK_RNG_VERSION: &str = "procgen.lcg.v1";

/// Diagnostic counters emitted by one mapblock generation pass.
#[derive(Debug, Clone, Default, PartialEq, Eq)]
pub struct MapBlockDiagnostics {
    /// Script steps that are parsed but not implemented by the generator.
    pub unsupported_steps: u32,
    /// Steps that referenced a missing group name.
    pub missing_groups: u32,
    /// Steps that referenced a group with no blocks.
    pub empty_groups: u32,
    /// Steps that referenced an out-of-range block index.
    pub invalid_block_indices: u32,
    /// Candidate searches that produced no legal placement.
    pub no_candidates: u32,
    /// Candidate commits that failed despite passing search.
    pub failed_places: u32,
    /// Shape solving passes that failed to find a complete covering.
    pub solve_failures: u32,
    /// Non-finite or negative weights observed while selecting authored blocks.
    pub invalid_weights: u32,
    /// Weighted choices that had to fall back to uniform selection because all weights were zero.
    pub zero_weight_fallbacks: u32,
    /// Auto-place passes that stopped after repeated no-progress attempts.
    pub no_progress_breaks: u32,
    /// Placement attempts rejected because block span exceeded the configured level count.
    pub level_overflows: u32,
    /// Fill-rect operations rejected up front due to invalid level, slot, or zero area.
    pub invalid_paint_ops: u32,
    /// Fill-rect operations rejected because the rectangle lies fully outside the output bounds.
    pub rejected_paint_ops: u32,
    /// Fill-rect operations accepted but clipped against the output bounds.
    pub clipped_paint_ops: u32,
}

/// Guard rails for `SolveShape` so recursive search remains bounded and predictable.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct SolverBudget {
    /// Maximum recursive nodes visited before the solver aborts.
    pub max_nodes: u32,
    /// Maximum recursion depth before the solver aborts.
    pub max_depth: u32,
    /// Maximum wall-clock budget for one solve pass in milliseconds.
    pub max_ms: u64,
    /// Maximum branch fan-out explored for one chosen cell.
    pub max_candidates_per_cell: usize,
}

impl Default for SolverBudget {
    fn default() -> Self {
        Self {
            max_nodes: 50_000,
            max_depth: 1_024,
            max_ms: 250,
            max_candidates_per_cell: 128,
        }
    }
}

/// Terminal reason why the backtracking solver could not finish a shape pass.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum SolveFailureReason {
    /// Search stopped because one of the configured budgets was exceeded.
    BudgetExceeded,
    /// No placements were legal for the current free shape.
    NoCandidates,
    /// At least one remaining free cell had no covering candidate.
    Contradiction,
}

/// Report emitted by one generation pass so callers can inspect silent failures.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct MapBlockReport {
    /// Seed used for deterministic generation.
    pub seed: u64,
    /// Identifier for the RNG implementation used by this pass.
    pub rng_version: &'static str,
    /// Number of top-level script steps provided.
    pub script_steps: usize,
    /// Number of step iterations actually executed after chance checks.
    pub executed_step_iterations: u32,
    /// Number of placements successfully committed.
    pub placements_committed: u32,
    /// Number of recursive solver nodes visited.
    pub visited_nodes: u32,
    /// Deepest recursion depth reached by the solver.
    pub max_depth_reached: u32,
    /// Number of placement candidates tested across all solver branches.
    pub candidates_tested: u32,
    /// Last solve failure reason observed during this generation pass.
    pub solve_failure_reason: Option<SolveFailureReason>,
    /// Transformed footprint/socket cache hits observed during this pass.
    pub transform_cache_hits: u32,
    /// Transformed footprint/socket cache misses observed during this pass.
    pub transform_cache_misses: u32,
    /// Aggregated diagnostic counters from the pass.
    pub diagnostics: MapBlockDiagnostics,
}

impl Default for MapBlockReport {
    fn default() -> Self {
        Self {
            seed: 0,
            rng_version: MAPBLOCK_RNG_VERSION,
            script_steps: 0,
            executed_step_iterations: 0,
            placements_committed: 0,
            visited_nodes: 0,
            max_depth_reached: 0,
            candidates_tested: 0,
            solve_failure_reason: None,
            transform_cache_hits: 0,
            transform_cache_misses: 0,
            diagnostics: MapBlockDiagnostics::default(),
        }
    }
}

struct SolveShapeContext<'a> {
    group: &'a MapGroup,
    level: u32,
    rotations: &'a [u32],
    mirrors: &'a [bool],
    budget: SolverBudget,
    started_at: Instant,
    failure_reason: Option<SolveFailureReason>,
    report: &'a mut MapBlockReport,
    transform_cache: &'a mut PlacementTransformCache,
}

/// Main generator that assembles maps from blocks using scripts.
#[derive(Debug, Clone)]
pub struct MapBlockGenerator {
    /// Configuration for tile slots.
    config: MapBlockConfig,
    /// Placement grid (map shape).
    grid: PlacementGrid,
    /// Neighbor matching rules.
    rules: NeighborRules,
    /// Rendering orientation.
    orientation: MapOrientation,
    /// Multi-level map data.
    levels: MultiLevelMap,
    /// RNG seed.
    seed: u64,
    /// Named groups of blocks.
    groups: HashMap<String, MapGroup>,
    /// Tile pixel dimensions for output.
    tile_pixel_w: u32,
    tile_pixel_h: u32,
    /// Statistics from last generation.
    last_placed_count: u32,
    /// Direct paint operations applied after block placement.
    paint_ops: Vec<PaintRectOp>,
    /// Diagnostics captured during the last generation pass.
    last_report: MapBlockReport,
    /// Budgets applied to recursive `SolveShape` passes.
    solver_budget: SolverBudget,
    /// Reused transformed block geometry for repeated placement searches.
    transform_cache: PlacementTransformCache,
}

impl MapBlockGenerator {
    /// Create a new generator with default configuration.
    pub fn new(config: MapBlockConfig) -> Self {
        Self {
            config,
            grid: PlacementGrid::new(),
            rules: NeighborRules::new(),
            orientation: MapOrientation::TopDown,
            levels: MultiLevelMap::new(1),
            seed: 0,
            groups: HashMap::new(),
            tile_pixel_w: 32,
            tile_pixel_h: 32,
            last_placed_count: 0,
            paint_ops: Vec::new(),
            last_report: MapBlockReport::default(),
            solver_budget: SolverBudget::default(),
            transform_cache: PlacementTransformCache::default(),
        }
    }

    /// Set the map shape as a rectangular grid.
    pub fn set_rect_shape(&mut self, width: u32, height: u32) {
        self.grid = PlacementGrid::new_rect(width, height);
    }

    /// Set the map shape from arbitrary positions.
    pub fn set_shape(&mut self, positions: &[(i32, i32)]) {
        self.grid = PlacementGrid::new();
        self.grid.add_positions(positions);
    }

    /// Set the placement grid directly.
    pub fn set_grid(&mut self, grid: PlacementGrid) {
        self.grid = grid;
    }

    /// Set the map rendering orientation.
    pub fn set_orientation(&mut self, orientation: MapOrientation) {
        self.orientation = orientation;
    }

    /// Set the number of levels (storeys).
    pub fn set_max_levels(&mut self, levels: u32) {
        self.levels = MultiLevelMap::new(levels);
    }

    /// Set the neighbor placement rules.
    pub fn set_rules(&mut self, rules: NeighborRules) {
        self.rules = rules;
    }

    /// Set the random number generator seed.
    pub fn set_seed(&mut self, seed: u64) {
        self.seed = seed;
    }

    /// Set tile pixel dimensions for output conversion.
    pub fn set_tile_size(&mut self, w: u32, h: u32) {
        self.tile_pixel_w = w;
        self.tile_pixel_h = h;
    }

    /// Set the recursive solver budget used by `SolveShape`.
    pub fn set_solver_budget(&mut self, budget: SolverBudget) {
        self.solver_budget = budget;
    }

    /// Get the recursive solver budget used by `SolveShape`.
    pub fn solver_budget(&self) -> SolverBudget {
        self.solver_budget
    }

    /// Add a named group of map blocks.
    pub fn add_group(&mut self, group: MapGroup) {
        self.groups.insert(group.name().to_string(), group);
    }

    /// Get a named block group by name.
    pub fn get_group(&self, name: &str) -> Option<&MapGroup> {
        self.groups.get(name)
    }

    /// Generate the map using a script.
    pub fn generate(&mut self, script: &MapScript) -> MapBlockResult {
        self.generate_with_report(script).0
    }

    /// Generate the map and return a diagnostic report describing silent failures and fallbacks.
    pub fn generate_with_report(&mut self, script: &MapScript) -> (MapBlockResult, MapBlockReport) {
        let mut rng = Lcg::new(self.seed);
        let mut report = MapBlockReport {
            seed: self.seed,
            script_steps: script.step_count(),
            ..MapBlockReport::default()
        };
        self.grid.clear_placed();
        self.levels.clear();
        self.last_placed_count = 0;
        self.paint_ops.clear();
        self.transform_cache.clear();

        for step in script.steps() {
            if step.chance < 1.0 && rng.next_f32() >= step.chance {
                continue;
            }

            for _ in 0..step.repeat_count {
                report.executed_step_iterations += 1;
                match step.step_type {
                    StepType::PlaceRandom => self.step_place_random(step, &mut rng, &mut report),
                    StepType::PlaceBlock => self.step_place_block(step, &mut rng, &mut report),
                    StepType::FillRandom => self.step_fill_random(step, &mut rng, &mut report),
                    StepType::FillEdges => self.step_fill_edges(step, &mut rng, &mut report),
                    StepType::AutoPlace => self.step_auto_place(step, &mut rng, &mut report),
                    StepType::FillRect => self.step_fill_rect(step, &mut report),
                    StepType::SolveShape => self.step_solve_shape(step, &mut rng, &mut report),
                    _ => report.diagnostics.unsupported_steps += 1,
                }
            }
        }

        let result = MapBlockResult::new(MapBlockResultBuild {
            grid: &self.grid,
            levels: &self.levels,
            groups: &self.groups,
            config: &self.config,
            paint_ops: &self.paint_ops,
            orientation: self.orientation,
            tile_pixel_w: self.tile_pixel_w,
            tile_pixel_h: self.tile_pixel_h,
        });
        report.placements_committed = self.last_placed_count;
        report.transform_cache_hits = self.transform_cache.hits();
        report.transform_cache_misses = self.transform_cache.misses();
        self.last_report = report.clone();
        (result, report)
    }

    /// Place a random block from the specified group at a valid position.
    fn step_place_random(
        &mut self,
        step: &super::script::ScriptStep,
        rng: &mut Lcg,
        report: &mut MapBlockReport,
    ) {
        let Some(group) = self.resolve_group(step, report) else {
            return;
        };

        let rotations = self.allowed_rotations(step);
        let mirrors = self.allowed_mirrors(step);

        for _ in 0..step.count {
            let Some(block_idx) = self.choose_weighted_block_index(&group, rng, report) else {
                return;
            };
            let search = PlacementSearch {
                groups: &self.groups,
                group_name: &step.group_name,
                block_index: block_idx,
                rules: &self.rules,
                match_sides: step.match_sides,
                rotations: &rotations,
                mirrors: &mirrors,
            };
            let candidates =
                find_valid_placements_cached(&self.grid, &search, &mut self.transform_cache);
            let Some(candidate) = self.choose_candidate(&candidates, rng) else {
                report.diagnostics.no_candidates += 1;
                continue;
            };
            self.place_candidate(step.level, candidate, report);
        }
    }

    /// Place a specific block at a fixed or inferred position.
    fn step_place_block(
        &mut self,
        step: &super::script::ScriptStep,
        rng: &mut Lcg,
        report: &mut MapBlockReport,
    ) {
        let Some(group) = self.resolve_group(step, report) else {
            return;
        };
        let Some(block_idx) = self.resolve_block_index(step, &group, rng, report) else {
            return;
        };
        let rotations = self.allowed_rotations(step);
        let mirrors = self.allowed_mirrors(step);
        let search = PlacementSearch {
            groups: &self.groups,
            group_name: &step.group_name,
            block_index: block_idx,
            rules: &self.rules,
            match_sides: step.match_sides,
            rotations: &rotations,
            mirrors: &mirrors,
        };
        let candidates =
            find_valid_placements_cached(&self.grid, &search, &mut self.transform_cache);
        let chosen = if step.has_position {
            let filtered: Vec<_> = candidates
                .into_iter()
                .filter(|candidate| candidate.grid_x == step.x && candidate.grid_y == step.y)
                .filter(|candidate| step.random_rotation || candidate.rotation == step.rotation % 4)
                .filter(|candidate| step.random_mirror || candidate.mirrored == step.mirror)
                .collect();
            self.choose_candidate(&filtered, rng)
        } else {
            self.choose_candidate(&candidates, rng)
        };
        if let Some(candidate) = chosen {
            self.place_candidate(step.level, candidate, report);
        } else {
            report.diagnostics.no_candidates += 1;
        }
    }

    /// Fill all available positions with weighted random blocks.
    fn step_fill_random(
        &mut self,
        step: &super::script::ScriptStep,
        rng: &mut Lcg,
        report: &mut MapBlockReport,
    ) {
        let Some(group) = self.resolve_group(step, report) else {
            return;
        };

        let max_iters = self.grid.available_count().max(step.count.max(1) as usize);
        let rotations = self.allowed_rotations(step);
        let mirrors = self.allowed_mirrors(step);

        for _ in 0..max_iters {
            let Some(block_idx) = self.choose_weighted_block_index(&group, rng, report) else {
                return;
            };
            let search = PlacementSearch {
                groups: &self.groups,
                group_name: &step.group_name,
                block_index: block_idx,
                rules: &self.rules,
                match_sides: step.match_sides,
                rotations: &rotations,
                mirrors: &mirrors,
            };
            let candidates =
                find_valid_placements_cached(&self.grid, &search, &mut self.transform_cache);
            let Some(candidate) = self.choose_candidate(&candidates, rng) else {
                report.diagnostics.no_candidates += 1;
                continue;
            };
            self.place_candidate(step.level, candidate, report);
            if self.grid.available_count() == 0 {
                break;
            }
        }
    }

    /// Fill edge positions with blocks from the specified group.
    fn step_fill_edges(
        &mut self,
        step: &super::script::ScriptStep,
        rng: &mut Lcg,
        report: &mut MapBlockReport,
    ) {
        let Some(group) = self.resolve_group(step, report) else {
            return;
        };

        let rotations = self.allowed_rotations(step);
        let mirrors = self.allowed_mirrors(step);
        let edge_targets: HashMap<_, _> = self
            .grid
            .available_positions()
            .into_iter()
            .filter(|&(x, y)| self.grid.is_edge_position(x, y))
            .map(|cell| (cell, true))
            .collect();

        for _ in 0..edge_targets.len() {
            let Some(block_idx) = self.choose_weighted_block_index(&group, rng, report) else {
                return;
            };
            let search = PlacementSearch {
                groups: &self.groups,
                group_name: &step.group_name,
                block_index: block_idx,
                rules: &self.rules,
                match_sides: step.match_sides,
                rotations: &rotations,
                mirrors: &mirrors,
            };
            let candidates =
                find_valid_placements_cached(&self.grid, &search, &mut self.transform_cache);
            let edge_candidates: Vec<_> = candidates
                .into_iter()
                .filter(|candidate| {
                    candidate
                        .occupied_cells
                        .iter()
                        .any(|cell| edge_targets.contains_key(cell))
                })
                .collect();
            let Some(candidate) = self.choose_candidate(&edge_candidates, rng) else {
                report.diagnostics.no_candidates += 1;
                continue;
            };
            self.place_candidate(step.level, candidate, report);
        }
    }

    /// Automatically place blocks respecting all constraints until the grid stalls.
    fn step_auto_place(
        &mut self,
        step: &super::script::ScriptStep,
        rng: &mut Lcg,
        report: &mut MapBlockReport,
    ) {
        let Some(group) = self.resolve_group(step, report) else {
            return;
        };

        let max_attempts = (step.count as usize).max(self.grid.available_count().saturating_mul(4));
        let rotations = self.allowed_rotations(step);
        let mirrors = self.allowed_mirrors(step);
        let mut attempts = 0usize;
        let mut no_progress_attempts = 0usize;
        let no_progress_limit = self.grid.available_count().max(1);

        while self.grid.available_count() > 0 && attempts < max_attempts {
            attempts += 1;
            let before = self.last_placed_count;
            let Some(block_idx) = self.choose_weighted_block_index(&group, rng, report) else {
                return;
            };
            let search = PlacementSearch {
                groups: &self.groups,
                group_name: &step.group_name,
                block_index: block_idx,
                rules: &self.rules,
                match_sides: step.match_sides,
                rotations: &rotations,
                mirrors: &mirrors,
            };
            let candidates =
                find_valid_placements_cached(&self.grid, &search, &mut self.transform_cache);
            let Some(candidate) = self.choose_candidate(&candidates, rng) else {
                report.diagnostics.no_candidates += 1;
                no_progress_attempts += 1;
                if no_progress_attempts >= no_progress_limit {
                    report.diagnostics.no_progress_breaks += 1;
                    break;
                }
                continue;
            };
            self.place_candidate(step.level, candidate, report);
            if self.last_placed_count == before {
                no_progress_attempts += 1;
                if no_progress_attempts >= no_progress_limit {
                    report.diagnostics.no_progress_breaks += 1;
                    break;
                }
            } else {
                no_progress_attempts = 0;
            }
        }
    }

    /// Solve the remaining available shape with backtracking placement.
    fn step_solve_shape(
        &mut self,
        step: &super::script::ScriptStep,
        rng: &mut Lcg,
        report: &mut MapBlockReport,
    ) {
        let Some(group) = self.resolve_group(step, report) else {
            return;
        };

        let rotations = self.allowed_rotations(step);
        let mirrors = self.allowed_mirrors(step);
        let mut scratch = self.grid.clone();
        let groups = &self.groups;
        let rules = &self.rules;
        let solver_budget = self.solver_budget;
        let solution = {
            let mut ctx = SolveShapeContext {
                group: &group,
                level: step.level,
                rotations: &rotations,
                mirrors: &mirrors,
                budget: solver_budget,
                started_at: Instant::now(),
                failure_reason: None,
                report,
                transform_cache: &mut self.transform_cache,
            };
            let solution =
                Self::solve_shape_recursive(groups, rules, &mut scratch, &mut ctx, rng, 0);
            if solution.is_none() {
                ctx.report.diagnostics.solve_failures += 1;
                ctx.report.solve_failure_reason = ctx.failure_reason;
            }
            solution
        };
        let Some(solution) = solution else {
            return;
        };

        for candidate in solution {
            self.place_candidate(step.level, candidate, report);
        }
    }

    /// Fill a rectangular area with a specific tile after block placement.
    fn step_fill_rect(&mut self, step: &super::script::ScriptStep, report: &mut MapBlockReport) {
        if step.width == 0
            || step.height == 0
            || step.level >= self.levels.level_count()
            || step.slot_index >= self.config.slot_count()
            || step.layer >= self.config.max_layers
        {
            report.diagnostics.invalid_paint_ops += 1;
            report.diagnostics.rejected_paint_ops += 1;
            return;
        }
        let (map_width, map_height) = self.output_tile_size();
        let rect_min_x = i64::from(step.x);
        let rect_min_y = i64::from(step.y);
        let rect_max_x = rect_min_x.saturating_add(i64::from(step.width));
        let rect_max_y = rect_min_y.saturating_add(i64::from(step.height));
        if rect_max_x <= 0
            || rect_max_y <= 0
            || rect_min_x >= i64::from(map_width)
            || rect_min_y >= i64::from(map_height)
        {
            report.diagnostics.rejected_paint_ops += 1;
            return;
        }
        if rect_min_x < 0
            || rect_min_y < 0
            || rect_max_x > i64::from(map_width)
            || rect_max_y > i64::from(map_height)
        {
            report.diagnostics.clipped_paint_ops += 1;
        }
        self.paint_ops.push(PaintRectOp {
            x: step.x,
            y: step.y,
            width: step.width,
            height: step.height,
            tile_id: step.tile_id,
            slot_index: step.slot_index,
            tileset_id: step.tileset_id,
            layer: step.layer,
            level: step.level,
        });
    }

    fn solve_shape_recursive(
        groups: &HashMap<String, MapGroup>,
        rules: &NeighborRules,
        grid: &mut PlacementGrid,
        ctx: &mut SolveShapeContext<'_>,
        rng: &mut Lcg,
        depth: u32,
    ) -> Option<Vec<PlacementCandidate>> {
        let mut free_cells = grid.available_positions();
        free_cells.sort_unstable();
        if free_cells.is_empty() {
            return Some(Vec::new());
        }
        if Self::solve_budget_exceeded(ctx, depth) {
            ctx.failure_reason = Some(SolveFailureReason::BudgetExceeded);
            return None;
        }
        ctx.report.visited_nodes = ctx.report.visited_nodes.saturating_add(1);
        ctx.report.max_depth_reached = ctx.report.max_depth_reached.max(depth);

        let free_lookup: std::collections::HashSet<_> = free_cells.iter().copied().collect();
        let mut coverage_counts: HashMap<_, usize> = free_cells
            .iter()
            .copied()
            .map(|cell| (cell, 0usize))
            .collect();
        let mut all_candidates = Vec::new();
        for block_index in 0..ctx.group.block_count() {
            let search = PlacementSearch {
                groups,
                group_name: ctx.group.name(),
                block_index,
                rules,
                match_sides: true,
                rotations: ctx.rotations,
                mirrors: ctx.mirrors,
            };
            let placements = find_valid_placements_cached(grid, &search, ctx.transform_cache);
            for candidate in placements {
                ctx.report.candidates_tested = ctx.report.candidates_tested.saturating_add(1);
                for &cell in &candidate.occupied_cells {
                    if free_lookup.contains(&cell) {
                        let count = coverage_counts.entry(cell).or_default();
                        *count = count.saturating_add(1);
                    }
                }
                all_candidates.push(candidate);
            }
        }
        if all_candidates.is_empty() {
            ctx.failure_reason = Some(SolveFailureReason::NoCandidates);
            return None;
        }

        let Some((&next_cell, &candidate_count)) =
            coverage_counts.iter().min_by_key(|(_, count)| **count)
        else {
            ctx.failure_reason = Some(SolveFailureReason::NoCandidates);
            return None;
        };
        if candidate_count == 0 {
            ctx.failure_reason = Some(SolveFailureReason::Contradiction);
            return None;
        }
        let mut candidates: Vec<_> = all_candidates
            .into_iter()
            .filter(|candidate| candidate.occupied_cells.contains(&next_cell))
            .collect();
        Self::order_candidates_by_weight(ctx.group, &mut candidates, rng, ctx.report);
        if candidates.len() > ctx.budget.max_candidates_per_cell {
            candidates.truncate(ctx.budget.max_candidates_per_cell);
        }

        for candidate in candidates {
            let mut next_grid = grid.clone();
            let placed = PlacedBlock {
                group_name: candidate.group_name.clone(),
                block_index: candidate.block_index,
                grid_x: candidate.grid_x,
                grid_y: candidate.grid_y,
                level: ctx.level,
                rotation: candidate.rotation,
                mirrored: candidate.mirrored,
                occupied_cells: candidate.occupied_cells.clone(),
            };
            if !next_grid.place_block(placed) {
                continue;
            }
            if next_grid.available_count() == 0 {
                return Some(vec![candidate]);
            }
            if let Some(mut tail) =
                Self::solve_shape_recursive(groups, rules, &mut next_grid, ctx, rng, depth + 1)
            {
                let mut solution = vec![candidate];
                solution.append(&mut tail);
                return Some(solution);
            }
        }

        ctx.failure_reason
            .get_or_insert(SolveFailureReason::Contradiction);
        None
    }

    fn resolve_block_index(
        &self,
        step: &super::script::ScriptStep,
        group: &MapGroup,
        rng: &mut Lcg,
        report: &mut MapBlockReport,
    ) -> Option<usize> {
        if group.block_count() == 0 {
            return None;
        }
        if step.block_index >= 0 {
            let idx = step.block_index as usize;
            if idx < group.block_count() {
                Some(idx)
            } else {
                report.diagnostics.invalid_block_indices += 1;
                None
            }
        } else {
            self.choose_weighted_block_index(group, rng, report)
        }
    }

    fn choose_weighted_block_index(
        &self,
        group: &MapGroup,
        rng: &mut Lcg,
        report: &mut MapBlockReport,
    ) -> Option<usize> {
        let total_weight: f32 = group
            .blocks()
            .iter()
            .map(|block| Self::weight_for_selection(block.get_weight(), report))
            .sum();
        if total_weight <= 0.0 {
            if group.block_count() > 0 {
                report.diagnostics.zero_weight_fallbacks += 1;
                return Some(Self::bounded_index(rng, group.block_count()));
            }
            return None;
        }

        let mut roll = rng.next_f32() * total_weight;
        for (index, block) in group.blocks().iter().enumerate() {
            roll -= Self::weight_for_selection(block.get_weight(), report);
            if roll <= 0.0 {
                return Some(index);
            }
        }
        group.block_count().checked_sub(1)
    }

    fn choose_candidate(
        &self,
        candidates: &[PlacementCandidate],
        rng: &mut Lcg,
    ) -> Option<PlacementCandidate> {
        if candidates.is_empty() {
            return None;
        }
        Some(candidates[Self::bounded_index(rng, candidates.len())].clone())
    }

    fn order_candidates_by_weight(
        group: &MapGroup,
        candidates: &mut [PlacementCandidate],
        rng: &mut Lcg,
        report: &mut MapBlockReport,
    ) {
        let mut ordered = Vec::with_capacity(candidates.len());
        let mut remaining = candidates.to_vec();
        while !remaining.is_empty() {
            let pick = Self::pick_weighted_candidate_index(group, &remaining, rng, report);
            ordered.push(remaining.remove(pick));
        }
        candidates.clone_from_slice(&ordered);
    }

    fn pick_weighted_candidate_index(
        group: &MapGroup,
        candidates: &[PlacementCandidate],
        rng: &mut Lcg,
        report: &mut MapBlockReport,
    ) -> usize {
        let total_weight: f32 = candidates
            .iter()
            .map(|candidate| {
                group
                    .get_block(candidate.block_index)
                    .map(|block| Self::weight_for_selection(block.get_weight(), report))
                    .unwrap_or(0.0)
            })
            .sum();
        if total_weight <= 0.0 {
            report.diagnostics.zero_weight_fallbacks += 1;
            return Self::bounded_index(rng, candidates.len());
        }

        let mut roll = rng.next_f32() * total_weight;
        for (index, candidate) in candidates.iter().enumerate() {
            roll -= group
                .get_block(candidate.block_index)
                .map(|block| Self::weight_for_selection(block.get_weight(), report))
                .unwrap_or(0.0);
            if roll <= 0.0 {
                return index;
            }
        }
        candidates.len() - 1
    }

    fn place_candidate(
        &mut self,
        level: u32,
        candidate: PlacementCandidate,
        report: &mut MapBlockReport,
    ) {
        let Some(group) = self.groups.get(&candidate.group_name) else {
            report.diagnostics.missing_groups += 1;
            return;
        };
        let Some(block) = group.get_block(candidate.block_index) else {
            report.diagnostics.invalid_block_indices += 1;
            return;
        };
        if block.level_span == 0 {
            report.diagnostics.level_overflows += 1;
            return;
        }
        if match level.checked_add(block.level_span) {
            Some(end) => end > self.levels.level_count(),
            None => true,
        } {
            report.diagnostics.level_overflows += 1;
            return;
        }

        let placed = PlacedBlock {
            group_name: candidate.group_name,
            block_index: candidate.block_index,
            grid_x: candidate.grid_x,
            grid_y: candidate.grid_y,
            level,
            rotation: candidate.rotation,
            mirrored: candidate.mirrored,
            occupied_cells: candidate.occupied_cells,
        };
        if self.grid.place_block(placed.clone()) {
            self.levels.add_block_to_level(level, placed);
            self.last_placed_count += 1;
        } else {
            report.diagnostics.failed_places += 1;
        }
    }

    fn resolve_group(
        &self,
        step: &super::script::ScriptStep,
        report: &mut MapBlockReport,
    ) -> Option<MapGroup> {
        let Some(group) = self.groups.get(&step.group_name).cloned() else {
            report.diagnostics.missing_groups += 1;
            return None;
        };
        if group.block_count() == 0 {
            report.diagnostics.empty_groups += 1;
            return None;
        }
        Some(group)
    }

    fn allowed_rotations(&self, step: &super::script::ScriptStep) -> Vec<u32> {
        if step.random_rotation {
            vec![0, 1, 2, 3]
        } else {
            vec![step.rotation % 4]
        }
    }

    fn allowed_mirrors(&self, step: &super::script::ScriptStep) -> Vec<bool> {
        if step.random_mirror {
            vec![false, true]
        } else {
            vec![step.mirror]
        }
    }

    /// Get the last placement count.
    pub fn last_placed_count(&self) -> u32 {
        self.last_placed_count
    }

    /// Get the report captured during the last generation pass.
    pub fn last_report(&self) -> &MapBlockReport {
        &self.last_report
    }

    /// Get the current configuration.
    pub fn config(&self) -> &MapBlockConfig {
        &self.config
    }

    /// Get the current orientation.
    pub fn orientation(&self) -> MapOrientation {
        self.orientation
    }

    fn solve_budget_exceeded(ctx: &SolveShapeContext<'_>, depth: u32) -> bool {
        depth > ctx.budget.max_depth
            || ctx.report.visited_nodes >= ctx.budget.max_nodes
            || ctx.started_at.elapsed().as_millis() > u128::from(ctx.budget.max_ms)
    }

    fn output_tile_size(&self) -> (u32, u32) {
        let bounds = self.grid.bounds().unwrap_or((0, 0, 0, 0));
        let (min_x, min_y, max_x, max_y) = bounds;
        let segment_size = self.config.default_segment_size.max(1);
        let grid_w = (max_x - min_x + 1).max(1) as u32;
        let grid_h = (max_y - min_y + 1).max(1) as u32;
        (grid_w * segment_size, grid_h * segment_size)
    }

    fn bounded_index(rng: &mut Lcg, bound: usize) -> usize {
        if bound == 0 {
            return 0;
        }
        (rng.next() % bound as u64) as usize
    }

    fn weight_for_selection(weight: f32, report: &mut MapBlockReport) -> f32 {
        if !weight.is_finite() || weight < 0.0 {
            report.diagnostics.invalid_weights += 1;
            0.0
        } else {
            weight
        }
    }
}
