//! Scripted procedural map assembler: executes a sequence of placement steps.
//!
//! - `MapBlockGenerator` owns the grid, block registry, and RNG state.
//! - Runs the `MapScript` step list: Fill, PlaceGroup, PlaceBlock, ApplyLayer.
//! - After assembly, converts the grid to a `TileMap` via `mapblock::output`.
//! - Exposed to Lua via `lurek.mapblock.generate(config, script)` returning a tilemap.

use super::config::MapBlockConfig;
use super::constraints::NeighborRules;
use super::group::MapGroup;
use super::multilevel::MultiLevelMap;
use super::orientation::MapOrientation;
use super::output::MapBlockResult;
use super::placement::{find_valid_positions, PlacedBlock, PlacementGrid};
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

        for step in script.steps() {
            if step.chance < 1.0 && rng.next_f32() >= step.chance {
                continue;
            }

            for _ in 0..step.repeat_count {
                match step.step_type {
                    StepType::PlaceRandom => {
                        self.step_place_random(step, &mut rng);
                    }
                    StepType::PlaceBlock => {
                        self.step_place_block(step, &mut rng);
                    }
                    StepType::FillRandom => {
                        self.step_fill_random(step, &mut rng);
                    }
                    StepType::FillEdges => {
                        self.step_fill_edges(step, &mut rng);
                    }
                    StepType::AutoPlace => {
                        self.step_auto_place(step, &mut rng);
                    }
                    StepType::FillRect => {
                        self.step_fill_rect(step);
                    }
                    _ => {}
                }
            }
        }

        MapBlockResult::new(
            &self.grid,
            &self.levels,
            &self.groups,
            &self.config,
            self.orientation,
            self.tile_pixel_w,
            self.tile_pixel_h,
        )
    }

    /// Place a random block from the specified group at a valid position.
    fn step_place_random(&mut self, step: &super::script::ScriptStep, rng: &mut Lcg) {
        let group = match self.groups.get(&step.group_name) {
            Some(g) => g,
            None => return,
        };

        if group.block_count() == 0 {
            return;
        }

        for _ in 0..step.count {
            let block_idx = rng.next_bounded(group.block_count() as u32) as usize;

            let valid_positions =
                find_valid_positions(&self.grid, group.blocks(), block_idx, &self.rules);

            if valid_positions.is_empty() {
                continue;
            }

            let pos_idx = rng.next_bounded(valid_positions.len() as u32) as usize;
            let (gx, gy) = valid_positions[pos_idx];

            let rotation = if step.random_rotation {
                rng.next_bounded(4)
            } else {
                step.rotation
            };

            let mirrored = if step.random_mirror {
                rng.next_bounded(2) == 1
            } else {
                step.mirror
            };

            let placed = PlacedBlock {
                block_index: block_idx,
                grid_x: gx,
                grid_y: gy,
                level: step.level,
                rotation,
                mirrored,
            };

            if self.grid.place_block(placed.clone()) {
                self.levels.add_block_to_level(step.level, placed);
                self.last_placed_count += 1;
            }
        }
    }

    /// Place a specific block at a fixed position.
    fn step_place_block(&mut self, step: &super::script::ScriptStep, rng: &mut Lcg) {
        let group = match self.groups.get(&step.group_name) {
            Some(g) => g,
            None => return,
        };

        let block_idx = if step.block_index >= 0 {
            step.block_index as usize
        } else {
            rng.next_bounded(group.block_count() as u32) as usize
        };

        if block_idx >= group.block_count() {
            return;
        }

        let (gx, gy) = if step.x != 0 || step.y != 0 {
            (step.x, step.y)
        } else {
            let valid =
                find_valid_positions(&self.grid, group.blocks(), block_idx, &self.rules);
            if valid.is_empty() {
                return;
            }
            let pos_idx = rng.next_bounded(valid.len() as u32) as usize;
            valid[pos_idx]
        };

        let placed = PlacedBlock {
            block_index: block_idx,
            grid_x: gx,
            grid_y: gy,
            level: step.level,
            rotation: step.rotation,
            mirrored: step.mirror,
        };

        if self.grid.place_block(placed.clone()) {
            self.levels.add_block_to_level(step.level, placed);
            self.last_placed_count += 1;
        }
    }

    /// Fill all available positions with random blocks.
    fn step_fill_random(&mut self, step: &super::script::ScriptStep, rng: &mut Lcg) {
        let group = match self.groups.get(&step.group_name) {
            Some(g) => g.clone(),
            None => return,
        };

        if group.block_count() == 0 {
            return;
        }

        let positions = self.grid.available_positions();
        for (gx, gy) in positions {
            let block_idx = rng.next_bounded(group.block_count() as u32) as usize;

            if step.match_sides
                && !super::placement::find_valid_positions(
                    &self.grid,
                    group.blocks(),
                    block_idx,
                    &self.rules,
                )
                .contains(&(gx, gy))
            {
                continue;
            }

            let rotation = if step.random_rotation {
                rng.next_bounded(4)
            } else {
                step.rotation
            };

            let placed = PlacedBlock {
                block_index: block_idx,
                grid_x: gx,
                grid_y: gy,
                level: step.level,
                rotation,
                mirrored: step.mirror,
            };

            if self.grid.place_block(placed.clone()) {
                self.levels.add_block_to_level(step.level, placed);
                self.last_placed_count += 1;
            }
        }
    }

    /// Fill edge positions with blocks from the specified group.
    fn step_fill_edges(&mut self, step: &super::script::ScriptStep, rng: &mut Lcg) {
        let group = match self.groups.get(&step.group_name) {
            Some(g) => g.clone(),
            None => return,
        };

        if group.block_count() == 0 {
            return;
        }

        let positions: Vec<_> = self
            .grid
            .available_positions()
            .into_iter()
            .filter(|&(x, y)| self.grid.is_edge_position(x, y))
            .collect();

        for (gx, gy) in positions {
            let block_idx = rng.next_bounded(group.block_count() as u32) as usize;

            let placed = PlacedBlock {
                block_index: block_idx,
                grid_x: gx,
                grid_y: gy,
                level: step.level,
                rotation: if step.random_rotation {
                    rng.next_bounded(4)
                } else {
                    step.rotation
                },
                mirrored: step.mirror,
            };

            if self.grid.place_block(placed.clone()) {
                self.levels.add_block_to_level(step.level, placed);
                self.last_placed_count += 1;
            }
        }
    }

    /// Automatically place blocks respecting all constraints until no positions remain.
    fn step_auto_place(&mut self, step: &super::script::ScriptStep, rng: &mut Lcg) {
        let group = match self.groups.get(&step.group_name) {
            Some(g) => g.clone(),
            None => return,
        };

        if group.block_count() == 0 {
            return;
        }

        let max_attempts = step.count.max(self.grid.available_count() as u32 * 2);
        let mut attempts = 0;

        while self.grid.available_count() > 0 && attempts < max_attempts {
            attempts += 1;
            let block_idx = rng.next_bounded(group.block_count() as u32) as usize;

            let valid =
                find_valid_positions(&self.grid, group.blocks(), block_idx, &self.rules);

            if valid.is_empty() {
                continue;
            }

            let pos_idx = rng.next_bounded(valid.len() as u32) as usize;
            let (gx, gy) = valid[pos_idx];

            let placed = PlacedBlock {
                block_index: block_idx,
                grid_x: gx,
                grid_y: gy,
                level: step.level,
                rotation: if step.random_rotation {
                    rng.next_bounded(4)
                } else {
                    step.rotation
                },
                mirrored: step.mirror,
            };

            if self.grid.place_block(placed.clone()) {
                self.levels.add_block_to_level(step.level, placed);
                self.last_placed_count += 1;
            }
        }
    }

    /// Fill a rectangular area with a specific tile (no block placement).
    fn step_fill_rect(&mut self, _step: &super::script::ScriptStep) {
        // FillRect operates on the output tilemap, not on placement grid.
        // This is handled in the output phase.
        self.last_placed_count += 1;
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
