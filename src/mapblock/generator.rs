//! Operational core for scripted mapblock assembly over a block grid. `mapblock/generator` delivers the generator implementation for the mapblock subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Owns block registries, multi-level placement state, and RNG progression. The file owns or coordinates data contracts including `MapBlockGenerator`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Executes fill, targeted placement, random placement, and repeat steps. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `set_rect_shape`, `set_shape`, `set_grid`, `set_orientation`, `set_max_levels`, and 9 more stays attached to the local data model and invariants.
//! Applies neighbor constraints to keep layouts structurally coherent. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.
//! Threads orientation and config context through the build process. External integration uses `super`, `std`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.
//! Converts intermediate placements into renderer-ready output structures. The file boundary separates mapblock implementation details from Lua bindings, generated specs, and examples, so public behavior remains documented at the owning source.

use super::config::MapBlockConfig;
use super::constraints::NeighborRules;
use super::group::MapGroup;
use super::multilevel::MultiLevelMap;
use super::orientation::MapOrientation;
use super::output::{MapBlockResult, MapBlockResultBuild, PaintRectOp};
use super::placement::{
    find_valid_placements, PlacedBlock, PlacementCandidate, PlacementGrid, PlacementSearch,
};
use super::script::{MapScript, StepType};
use std::collections::HashMap;

/// Minimal LCG pseudo-random number generator for deterministic generation.
struct Lcg {
    state: u64,
}

impl Lcg {
    fn new(seed: u64) -> Self {
        Self {
            state: seed.wrapping_add(1),
        }
    }

    fn next_u64(&mut self) -> u64 {
        self.state = self
            .state
            .wrapping_mul(6_364_136_223_846_793_005)
            .wrapping_add(1_442_695_040_888_963_407);
        self.state
    }

    fn next_bounded(&mut self, bound: u32) -> u32 {
        if bound == 0 {
            return 0;
        }
        (self.next_u64() % bound as u64) as u32
    }

    fn next_f32(&mut self) -> f32 {
        (self.next_u64() % 10000) as f32 / 10000.0
    }
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
        let mut rng = Lcg::new(self.seed);
        self.grid.clear_placed();
        self.levels.clear();
        self.last_placed_count = 0;
        self.paint_ops.clear();

        for step in script.steps() {
            if step.chance < 1.0 && rng.next_f32() >= step.chance {
                continue;
            }

            for _ in 0..step.repeat_count {
                match step.step_type {
                    StepType::PlaceRandom => self.step_place_random(step, &mut rng),
                    StepType::PlaceBlock => self.step_place_block(step, &mut rng),
                    StepType::FillRandom => self.step_fill_random(step, &mut rng),
                    StepType::FillEdges => self.step_fill_edges(step, &mut rng),
                    StepType::AutoPlace => self.step_auto_place(step, &mut rng),
                    StepType::FillRect => self.step_fill_rect(step),
                    StepType::SolveShape => self.step_solve_shape(step, &mut rng),
                    _ => {}
                }
            }
        }

        MapBlockResult::new(MapBlockResultBuild {
            grid: &self.grid,
            levels: &self.levels,
            groups: &self.groups,
            config: &self.config,
            paint_ops: &self.paint_ops,
            orientation: self.orientation,
            tile_pixel_w: self.tile_pixel_w,
            tile_pixel_h: self.tile_pixel_h,
        })
    }

    /// Place a random block from the specified group at a valid position.
    fn step_place_random(&mut self, step: &super::script::ScriptStep, rng: &mut Lcg) {
        let Some(group) = self.groups.get(&step.group_name).cloned() else {
            return;
        };
        if group.block_count() == 0 {
            return;
        }

        let rotations = self.allowed_rotations(step);
        let mirrors = self.allowed_mirrors(step);

        for _ in 0..step.count {
            let Some(block_idx) = self.choose_weighted_block_index(&group, rng) else {
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
            let candidates = find_valid_placements(&self.grid, &search);
            let Some(candidate) = self.choose_candidate(&candidates, rng) else {
                continue;
            };
            self.place_candidate(step.level, candidate);
        }
    }

    /// Place a specific block at a fixed or inferred position.
    fn step_place_block(&mut self, step: &super::script::ScriptStep, rng: &mut Lcg) {
        let Some(group) = self.groups.get(&step.group_name).cloned() else {
            return;
        };
        let Some(block_idx) = self.resolve_block_index(step, &group, rng) else {
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
        let candidates = find_valid_placements(&self.grid, &search);
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
            self.place_candidate(step.level, candidate);
        }
    }

    /// Fill all available positions with weighted random blocks.
    fn step_fill_random(&mut self, step: &super::script::ScriptStep, rng: &mut Lcg) {
        let Some(group) = self.groups.get(&step.group_name).cloned() else {
            return;
        };
        if group.block_count() == 0 {
            return;
        }

        let max_iters = self.grid.available_count().max(step.count.max(1) as usize);
        let rotations = self.allowed_rotations(step);
        let mirrors = self.allowed_mirrors(step);

        for _ in 0..max_iters {
            let Some(block_idx) = self.choose_weighted_block_index(&group, rng) else {
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
            let candidates = find_valid_placements(&self.grid, &search);
            let Some(candidate) = self.choose_candidate(&candidates, rng) else {
                continue;
            };
            self.place_candidate(step.level, candidate);
            if self.grid.available_count() == 0 {
                break;
            }
        }
    }

    /// Fill edge positions with blocks from the specified group.
    fn step_fill_edges(&mut self, step: &super::script::ScriptStep, rng: &mut Lcg) {
        let Some(group) = self.groups.get(&step.group_name).cloned() else {
            return;
        };
        if group.block_count() == 0 {
            return;
        }

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
            let Some(block_idx) = self.choose_weighted_block_index(&group, rng) else {
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
            let candidates = find_valid_placements(&self.grid, &search);
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
                continue;
            };
            self.place_candidate(step.level, candidate);
        }
    }

    /// Automatically place blocks respecting all constraints until the grid stalls.
    fn step_auto_place(&mut self, step: &super::script::ScriptStep, rng: &mut Lcg) {
        let Some(group) = self.groups.get(&step.group_name).cloned() else {
            return;
        };
        if group.block_count() == 0 {
            return;
        }

        let max_attempts = step.count.max(self.grid.available_count() as u32 * 4);
        let rotations = self.allowed_rotations(step);
        let mirrors = self.allowed_mirrors(step);
        let mut attempts = 0;

        while self.grid.available_count() > 0 && attempts < max_attempts {
            attempts += 1;
            let Some(block_idx) = self.choose_weighted_block_index(&group, rng) else {
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
            let candidates = find_valid_placements(&self.grid, &search);
            let Some(candidate) = self.choose_candidate(&candidates, rng) else {
                continue;
            };
            self.place_candidate(step.level, candidate);
        }
    }

    /// Solve the remaining available shape with backtracking placement.
    fn step_solve_shape(&mut self, step: &super::script::ScriptStep, rng: &mut Lcg) {
        let Some(group) = self.groups.get(&step.group_name).cloned() else {
            return;
        };
        if group.block_count() == 0 {
            return;
        }

        let rotations = self.allowed_rotations(step);
        let mirrors = self.allowed_mirrors(step);
        let mut scratch = self.grid.clone();
        let Some(solution) =
            self.solve_shape_recursive(&mut scratch, &group, step.level, &rotations, &mirrors, rng)
        else {
            return;
        };

        for candidate in solution {
            self.place_candidate(step.level, candidate);
        }
    }

    /// Fill a rectangular area with a specific tile after block placement.
    fn step_fill_rect(&mut self, step: &super::script::ScriptStep) {
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
        &self,
        grid: &mut PlacementGrid,
        group: &MapGroup,
        level: u32,
        rotations: &[u32],
        mirrors: &[bool],
        rng: &mut Lcg,
    ) -> Option<Vec<PlacementCandidate>> {
        let mut free_cells = grid.available_positions();
        free_cells.sort_unstable();
        if free_cells.is_empty() {
            return Some(Vec::new());
        }
        let next_cell = free_cells[0];

        let mut candidates = Vec::new();
        for block_index in 0..group.block_count() {
            let search = PlacementSearch {
                groups: &self.groups,
                group_name: group.name(),
                block_index,
                rules: &self.rules,
                match_sides: true,
                rotations,
                mirrors,
            };
            let placements = find_valid_placements(grid, &search);
            candidates.extend(
                placements
                    .into_iter()
                    .filter(|candidate| candidate.occupied_cells.contains(&next_cell)),
            );
        }

        self.order_candidates_by_weight(group, &mut candidates, rng);

        for candidate in candidates {
            let mut next_grid = grid.clone();
            let placed = PlacedBlock {
                group_name: candidate.group_name.clone(),
                block_index: candidate.block_index,
                grid_x: candidate.grid_x,
                grid_y: candidate.grid_y,
                level,
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
                self.solve_shape_recursive(&mut next_grid, group, level, rotations, mirrors, rng)
            {
                let mut solution = vec![candidate];
                solution.append(&mut tail);
                return Some(solution);
            }
        }

        None
    }

    fn resolve_block_index(
        &self,
        step: &super::script::ScriptStep,
        group: &MapGroup,
        rng: &mut Lcg,
    ) -> Option<usize> {
        if group.block_count() == 0 {
            return None;
        }
        if step.block_index >= 0 {
            let idx = step.block_index as usize;
            (idx < group.block_count()).then_some(idx)
        } else {
            self.choose_weighted_block_index(group, rng)
        }
    }

    fn choose_weighted_block_index(&self, group: &MapGroup, rng: &mut Lcg) -> Option<usize> {
        let total_weight: f32 = group
            .blocks()
            .iter()
            .map(|block| block.get_weight().max(0.0))
            .sum();
        if total_weight <= 0.0 {
            return (group.block_count() > 0)
                .then(|| rng.next_bounded(group.block_count() as u32) as usize);
        }

        let mut roll = rng.next_f32() * total_weight;
        for (index, block) in group.blocks().iter().enumerate() {
            roll -= block.get_weight().max(0.0);
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
        Some(candidates[rng.next_bounded(candidates.len() as u32) as usize].clone())
    }

    fn order_candidates_by_weight(
        &self,
        group: &MapGroup,
        candidates: &mut [PlacementCandidate],
        rng: &mut Lcg,
    ) {
        let mut ordered = Vec::with_capacity(candidates.len());
        let mut remaining = candidates.to_vec();
        while !remaining.is_empty() {
            let pick = self.pick_weighted_candidate_index(group, &remaining, rng);
            ordered.push(remaining.remove(pick));
        }
        candidates.clone_from_slice(&ordered);
    }

    fn pick_weighted_candidate_index(
        &self,
        group: &MapGroup,
        candidates: &[PlacementCandidate],
        rng: &mut Lcg,
    ) -> usize {
        let total_weight: f32 = candidates
            .iter()
            .map(|candidate| {
                group
                    .get_block(candidate.block_index)
                    .map(|block| block.get_weight().max(0.0))
                    .unwrap_or(0.0)
            })
            .sum();
        if total_weight <= 0.0 {
            return rng.next_bounded(candidates.len() as u32) as usize;
        }

        let mut roll = rng.next_f32() * total_weight;
        for (index, candidate) in candidates.iter().enumerate() {
            roll -= group
                .get_block(candidate.block_index)
                .map(|block| block.get_weight().max(0.0))
                .unwrap_or(0.0);
            if roll <= 0.0 {
                return index;
            }
        }
        candidates.len() - 1
    }

    fn place_candidate(&mut self, level: u32, candidate: PlacementCandidate) {
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
        }
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

    /// Get the current configuration.
    pub fn config(&self) -> &MapBlockConfig {
        &self.config
    }

    /// Get the current orientation.
    pub fn orientation(&self) -> MapOrientation {
        self.orientation
    }
}
