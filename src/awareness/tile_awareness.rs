//! This file owns tile awareness behavior inside the awareness subsystem, close to its data and invariants.
//! It keeps validation, defaults, and error-facing rules near the operations that mutate tile awareness state.
//! Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.
//! Public functions in this file are the stable entry points other modules should use for tile awareness work.
//! Serialization, indexing, and boundary checks stay here when they depend on tile awareness internals.
//! Renderer, API, and test layers should call through these helpers rather than duplicate private rules.
//! Open this file when tile awareness ownership changes, but keep unrelated subsystem policy in sibling modules.
//! The code favors small data transformations so examples, specs, and tests can assert behavior directly.
//! Stateful changes are kept deterministic here so generated docs and smoke tests remain reproducible.

use crate::tilefield::{CellCoord, TileChannel, TileField};
use std::collections::{HashMap, HashSet};

/// Tile awareness shape for one category computation.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum AwarenessMode {
    /// Full radial awareness around the origin.
    Omni,
    /// Directional cone using facing vector and arc angle.
    Cone,
}

/// Per-category awareness computation config.
#[derive(Debug, Clone)]
pub struct AwarenessCategoryConfig {
    /// Whether this category contributes to aggregate visibility.
    pub active: bool,
    /// Default range when a compute call does not override it.
    pub range: u32,
    /// Omni or cone computation mode.
    pub mode: AwarenessMode,
    /// Cone arc in degrees.
    pub arc_degrees: f32,
    /// Facing vector used by cone mode.
    pub facing: (i32, i32),
    /// Tilefield category used to test blockers.
    pub blocker_category: String,
}

impl AwarenessCategoryConfig {
    /// Create an active omni category with the same blocker category name.
    pub fn new(name: &str) -> Self {
        Self {
            active: true,
            range: 8,
            mode: AwarenessMode::Omni,
            arc_degrees: 360.0,
            facing: (1, 0),
            blocker_category: name.to_string(),
        }
    }
}

#[derive(Debug, Clone)]
struct PlayerMasks {
    visible: Vec<bool>,
    explored: Vec<bool>,
    action: Vec<bool>,
    categories: HashMap<String, CategoryMasks>,
}

#[derive(Debug, Clone)]
struct CategoryMasks {
    visible: Vec<bool>,
    explored: Vec<bool>,
}

impl PlayerMasks {
    fn new(len: usize) -> Self {
        Self {
            visible: vec![false; len],
            explored: vec![false; len],
            action: vec![false; len],
            categories: HashMap::new(),
        }
    }

    fn clear_action(&mut self) {
        self.action.fill(false);
    }

    fn category_mut(&mut self, category: &str, len: usize) -> &mut CategoryMasks {
        self.categories
            .entry(category.to_string())
            .or_insert_with(|| CategoryMasks {
                visible: vec![false; len],
                explored: vec![false; len],
            })
    }
}

#[derive(Debug, Clone, PartialEq, Eq, Hash)]
struct ShareEdge {
    from: String,
    to: String,
    category: String,
}

/// Multi-player tile visibility/action state.
#[derive(Debug, Clone)]
pub struct TileAwareness {
    width: u32,
    height: u32,
    levels: u32,
    remember_explored: bool,
    players: HashMap<String, PlayerMasks>,
    categories: HashMap<String, AwarenessCategoryConfig>,
    shares: HashSet<ShareEdge>,
}

impl TileAwareness {
    /// Create mask storage for a tilefield-sized volume.
    pub fn new(
        width: u32,
        height: u32,
        levels: u32,
        players: Vec<String>,
        remember_explored: bool,
    ) -> Self {
        let len = (width * height * levels) as usize;
        let players = players
            .into_iter()
            .map(|id| (id, PlayerMasks::new(len)))
            .collect();
        let mut categories = HashMap::new();
        categories.insert(
            "vision".to_string(),
            AwarenessCategoryConfig {
                active: true,
                range: 8,
                mode: AwarenessMode::Omni,
                arc_degrees: 360.0,
                facing: (1, 0),
                blocker_category: "vision".to_string(),
            },
        );
        categories.insert(
            "action".to_string(),
            AwarenessCategoryConfig {
                active: false,
                range: 8,
                mode: AwarenessMode::Omni,
                arc_degrees: 360.0,
                facing: (1, 0),
                blocker_category: "action".to_string(),
            },
        );
        Self {
            width,
            height,
            levels,
            remember_explored,
            players,
            categories,
            shares: HashSet::new(),
        }
    }

    fn index(&self, coord: CellCoord) -> Option<usize> {
        if coord.x >= self.width || coord.y >= self.height || coord.z >= self.levels {
            return None;
        }
        Some((coord.z * self.width * self.height + coord.y * self.width + coord.x) as usize)
    }

    fn player_mut(&mut self, id: &str) -> Result<&mut PlayerMasks, String> {
        self.players
            .get_mut(id)
            .ok_or_else(|| format!("visibility player '{id}' does not exist"))
    }

    fn player(&self, id: &str) -> Option<&PlayerMasks> {
        self.players.get(id)
    }

    fn len(&self) -> usize {
        (self.width * self.height * self.levels) as usize
    }

    /// Define or replace one awareness category.
    pub fn define_category(
        &mut self,
        name: String,
        config: AwarenessCategoryConfig,
    ) -> Result<(), String> {
        let name = name.trim();
        if name.is_empty() {
            return Err("awareness category name must not be empty".to_string());
        }
        if !config.arc_degrees.is_finite() || config.arc_degrees <= 0.0 {
            return Err("awareness category arc must be finite and > 0".to_string());
        }
        self.categories.insert(name.to_string(), config);
        Ok(())
    }

    /// Return one category config.
    pub fn category(&self, name: &str) -> Option<&AwarenessCategoryConfig> {
        self.categories.get(name)
    }

    /// Return known category names in stable order.
    pub fn category_names(&self) -> Vec<String> {
        let mut names: Vec<_> = self.categories.keys().cloned().collect();
        names.sort();
        names
    }

    /// Compute current visible mask for one player.
    pub fn compute_visible(
        &mut self,
        field: &TileField,
        player: &str,
        origin: CellCoord,
        range: u32,
        channel: TileChannel,
    ) -> Result<(), String> {
        self.compute_category_visible_with_config(
            field,
            player,
            channel.as_str(),
            origin,
            range,
            AwarenessCategoryConfig {
                active: true,
                range,
                mode: AwarenessMode::Omni,
                arc_degrees: 360.0,
                facing: (1, 0),
                blocker_category: channel.as_str().to_string(),
            },
        )
    }

    /// Compute current visible mask for one player and awareness category.
    #[allow(clippy::too_many_arguments)]
    pub fn compute_category_visible(
        &mut self,
        field: &TileField,
        player: &str,
        category: &str,
        origin: CellCoord,
        range_override: Option<u32>,
        mode_override: Option<AwarenessMode>,
        arc_override: Option<f32>,
        facing_override: Option<(i32, i32)>,
        blocker_override: Option<String>,
    ) -> Result<(), String> {
        let mut config = self
            .categories
            .get(category)
            .cloned()
            .unwrap_or_else(|| AwarenessCategoryConfig::new(category));
        if let Some(range) = range_override {
            config.range = range;
        }
        if let Some(mode) = mode_override {
            config.mode = mode;
        }
        if let Some(arc) = arc_override {
            config.arc_degrees = arc;
        }
        if let Some(facing) = facing_override {
            config.facing = facing;
        }
        if let Some(blocker) = blocker_override {
            config.blocker_category = blocker;
        }
        self.compute_category_visible_with_config(
            field,
            player,
            category,
            origin,
            config.range,
            config,
        )
    }

    fn compute_category_visible_with_config(
        &mut self,
        field: &TileField,
        player: &str,
        category: &str,
        origin: CellCoord,
        range: u32,
        config: AwarenessCategoryConfig,
    ) -> Result<(), String> {
        if !field.in_bounds(origin) {
            return Err("awareness origin is out of bounds".to_string());
        }
        let width = self.width;
        let height = self.height;
        let len = self.len();
        let remember_explored = self.remember_explored;
        let masks = self.player_mut(player)?;
        let category_masks = masks.category_mut(category, len);
        category_masks.visible.fill(false);
        for z in origin.z..=origin.z {
            for y in 0..height {
                for x in 0..width {
                    let coord = CellCoord { x, y, z };
                    if field.range_distance(origin, coord) > range as f32 {
                        continue;
                    }
                    if !Self::coord_in_arc(
                        origin,
                        coord,
                        config.facing,
                        config.arc_degrees,
                        config.mode,
                    ) {
                        continue;
                    }
                    if field.clear_line_category(origin, coord, &config.blocker_category)? {
                        let idx = (coord.z * width * height + coord.y * width + coord.x) as usize;
                        category_masks.visible[idx] = true;
                        if remember_explored {
                            category_masks.explored[idx] = true;
                        }
                    }
                }
            }
        }
        Ok(())
    }

    fn coord_in_arc(
        origin: CellCoord,
        coord: CellCoord,
        facing: (i32, i32),
        arc_degrees: f32,
        mode: AwarenessMode,
    ) -> bool {
        if mode == AwarenessMode::Omni || origin == coord || arc_degrees >= 359.9 {
            return true;
        }
        let vx = coord.x as f32 - origin.x as f32;
        let vy = coord.y as f32 - origin.y as f32;
        let fx = facing.0 as f32;
        let fy = facing.1 as f32;
        let v_len = (vx * vx + vy * vy).sqrt();
        let f_len = (fx * fx + fy * fy).sqrt();
        if v_len <= f32::EPSILON || f_len <= f32::EPSILON {
            return true;
        }
        let dot = (vx * fx + vy * fy) / (v_len * f_len);
        let min_dot = (arc_degrees.to_radians() * 0.5).cos();
        dot >= min_dot
    }

    /// Compute current action mask for one player.
    pub fn compute_action(
        &mut self,
        field: &TileField,
        player: &str,
        origin: CellCoord,
        range: u32,
        channel: TileChannel,
    ) -> Result<(), String> {
        let width = self.width;
        let height = self.height;
        let masks = self.player_mut(player)?;
        masks.clear_action();
        for z in origin.z..=origin.z {
            for y in 0..height {
                for x in 0..width {
                    let coord = CellCoord { x, y, z };
                    if field.range_distance(origin, coord) > range as f32 {
                        continue;
                    }
                    if field.clear_line(origin, coord, channel)? {
                        let idx = (coord.z * width * height + coord.y * width + coord.x) as usize;
                        masks.action[idx] = true;
                    }
                }
            }
        }
        Ok(())
    }

    /// Return current visible state.
    pub fn is_visible(&self, player: &str, coord: CellCoord) -> bool {
        let Some(idx) = self.index(coord) else {
            return false;
        };
        self.aggregate_visible_at(player, idx)
    }

    /// Return awareness for a specific category, including directed shares into `player`.
    pub fn is_aware(&self, player: &str, category: &str, coord: CellCoord) -> bool {
        let Some(idx) = self.index(coord) else {
            return false;
        };
        self.category_visible_at(player, category, idx)
    }

    /// Return remembered explored state.
    pub fn is_explored(&self, player: &str, coord: CellCoord) -> bool {
        let Some(idx) = self.index(coord) else {
            return false;
        };
        let Some(masks) = self.player(player) else {
            return false;
        };
        if masks.explored[idx] {
            return true;
        }
        self.categories
            .iter()
            .filter(|(_, config)| config.active)
            .any(|(category, _)| {
                masks
                    .categories
                    .get(category)
                    .is_some_and(|category_masks| category_masks.explored[idx])
            })
    }

    /// Return current action state.
    pub fn can_act_on(&self, player: &str, coord: CellCoord) -> bool {
        self.index(coord)
            .and_then(|idx| self.player(player).map(|masks| masks.action[idx]))
            .unwrap_or(false)
    }

    /// Return all visible cells for a player, optionally filtered by level.
    pub fn visible_cells(&self, player: &str, level: Option<u32>) -> Vec<CellCoord> {
        self.collect_aggregate_visible_cells(player, level)
    }

    /// Return visible cells for a specific category, including directed shares.
    pub fn visible_cells_for_category(
        &self,
        player: &str,
        category: &str,
        level: Option<u32>,
    ) -> Vec<CellCoord> {
        let mut cells = Vec::new();
        for z in 0..self.levels {
            if level.is_some_and(|wanted| wanted != z) {
                continue;
            }
            for y in 0..self.height {
                for x in 0..self.width {
                    let coord = CellCoord { x, y, z };
                    let idx = (z * self.width * self.height + y * self.width + x) as usize;
                    if self.category_visible_at(player, category, idx) {
                        cells.push(coord);
                    }
                }
            }
        }
        cells
    }

    /// Return all action cells for a player, optionally filtered by level.
    pub fn action_cells(&self, player: &str, level: Option<u32>) -> Vec<CellCoord> {
        self.collect_cells(player, level, |masks, idx| masks.action[idx])
    }

    fn collect_aggregate_visible_cells(&self, player: &str, level: Option<u32>) -> Vec<CellCoord> {
        let mut cells = Vec::new();
        for z in 0..self.levels {
            if level.is_some_and(|wanted| wanted != z) {
                continue;
            }
            for y in 0..self.height {
                for x in 0..self.width {
                    let idx = (z * self.width * self.height + y * self.width + x) as usize;
                    if self.aggregate_visible_at(player, idx) {
                        cells.push(CellCoord { x, y, z });
                    }
                }
            }
        }
        cells
    }

    fn aggregate_visible_at(&self, player: &str, idx: usize) -> bool {
        let Some(masks) = self.player(player) else {
            return false;
        };
        if masks.visible[idx] {
            return true;
        }
        for (category, config) in &self.categories {
            if !config.active {
                continue;
            }
            if self.category_visible_at(player, category, idx) {
                return true;
            }
        }
        false
    }

    fn category_visible_at(&self, player: &str, category: &str, idx: usize) -> bool {
        if self
            .player(player)
            .and_then(|masks| masks.categories.get(category))
            .is_some_and(|masks| masks.visible[idx])
        {
            return true;
        }
        self.shares.iter().any(|edge| {
            edge.to == player
                && edge.category == category
                && self
                    .player(&edge.from)
                    .and_then(|masks| masks.categories.get(category))
                    .is_some_and(|masks| masks.visible[idx])
        })
    }

    fn collect_cells(
        &self,
        player: &str,
        level: Option<u32>,
        predicate: impl Fn(&PlayerMasks, usize) -> bool,
    ) -> Vec<CellCoord> {
        let Some(masks) = self.player(player) else {
            return Vec::new();
        };
        let mut cells = Vec::new();
        for z in 0..self.levels {
            if level.is_some_and(|wanted| wanted != z) {
                continue;
            }
            for y in 0..self.height {
                for x in 0..self.width {
                    let idx = (z * self.width * self.height + y * self.width + x) as usize;
                    if predicate(masks, idx) {
                        cells.push(CellCoord { x, y, z });
                    }
                }
            }
        }
        cells
    }

    /// Clears one player's current and remembered state.
    pub fn clear_player(&mut self, player: &str) -> Result<(), String> {
        let masks = self.player_mut(player)?;
        masks.visible.fill(false);
        masks.explored.fill(false);
        masks.action.fill(false);
        for category in masks.categories.values_mut() {
            category.visible.fill(false);
            category.explored.fill(false);
        }
        Ok(())
    }

    /// Clears all players.
    pub fn clear_all(&mut self) {
        for masks in self.players.values_mut() {
            masks.visible.fill(false);
            masks.explored.fill(false);
            masks.action.fill(false);
            for category in masks.categories.values_mut() {
                category.visible.fill(false);
                category.explored.fill(false);
            }
        }
    }

    /// Add a directed share edge: `from` contributes one category to `to`.
    pub fn share(&mut self, from: String, to: String, category: String) -> Result<(), String> {
        if !self.players.contains_key(&from) {
            return Err(format!("visibility player '{from}' does not exist"));
        }
        if !self.players.contains_key(&to) {
            return Err(format!("visibility player '{to}' does not exist"));
        }
        if category.trim().is_empty() {
            return Err("awareness share category must not be empty".to_string());
        }
        self.shares.insert(ShareEdge { from, to, category });
        Ok(())
    }

    /// Remove all directed share edges.
    pub fn clear_shares(&mut self) {
        self.shares.clear();
    }

    /// Convenience helper that creates directed share edges between all listed players.
    pub fn set_team(&mut self, players: &[String], categories: &[String]) -> Result<(), String> {
        for player in players {
            if !self.players.contains_key(player) {
                return Err(format!("visibility player '{player}' does not exist"));
            }
        }
        for from in players {
            for to in players {
                if from == to {
                    continue;
                }
                for category in categories {
                    self.share(from.clone(), to.clone(), category.clone())?;
                }
            }
        }
        Ok(())
    }
}
