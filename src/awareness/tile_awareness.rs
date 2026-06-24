//! Owns per-player tile visibility, explored, and action masks backed by one shared `TileField`.
//! Computes visible and actionable cells by asking tilefield for channel-specific line clearance data.
//! Stores independent masks per player so teams can have different current sight, memory, and action reach.
//! Exposes stateless line-of-sight and line-of-action helpers without owning movement or lighting rules.
//! Keeps tilefield as the source for blockers, costs, modifiers, and bounds while awareness owns masks only.
//! Change this file when sight/action mask behavior changes, not when pathfinding or tile-light math changes.

use crate::tilefield::{CellCoord, TileChannel, TileField};
use std::collections::HashMap;

#[derive(Debug, Clone)]
struct PlayerMasks {
    visible: Vec<bool>,
    explored: Vec<bool>,
    action: Vec<bool>,
}

impl PlayerMasks {
    fn new(len: usize) -> Self {
        Self {
            visible: vec![false; len],
            explored: vec![false; len],
            action: vec![false; len],
        }
    }

    fn clear_current(&mut self) {
        self.visible.fill(false);
    }

    fn clear_action(&mut self) {
        self.action.fill(false);
    }
}

/// Multi-player tile visibility/action state.
#[derive(Debug, Clone)]
pub struct TileAwareness {
    width: u32,
    height: u32,
    levels: u32,
    remember_explored: bool,
    players: HashMap<String, PlayerMasks>,
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
        Self {
            width,
            height,
            levels,
            remember_explored,
            players,
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

    /// Compute current visible mask for one player.
    pub fn compute_visible(
        &mut self,
        field: &TileField,
        player: &str,
        origin: CellCoord,
        range: u32,
        channel: TileChannel,
    ) -> Result<(), String> {
        let width = self.width;
        let height = self.height;
        let remember_explored = self.remember_explored;
        let masks = self.player_mut(player)?;
        masks.clear_current();
        for z in origin.z..=origin.z {
            for y in 0..height {
                for x in 0..width {
                    let coord = CellCoord { x, y, z };
                    if field.distance(origin, coord) > range {
                        continue;
                    }
                    if field.clear_line(origin, coord, channel)? {
                        let idx = (coord.z * width * height + coord.y * width + coord.x) as usize;
                        masks.visible[idx] = true;
                        if remember_explored {
                            masks.explored[idx] = true;
                        }
                    }
                }
            }
        }
        Ok(())
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
                    if field.distance(origin, coord) > range {
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
        self.index(coord)
            .and_then(|idx| self.player(player).map(|masks| masks.visible[idx]))
            .unwrap_or(false)
    }

    /// Return remembered explored state.
    pub fn is_explored(&self, player: &str, coord: CellCoord) -> bool {
        self.index(coord)
            .and_then(|idx| self.player(player).map(|masks| masks.explored[idx]))
            .unwrap_or(false)
    }

    /// Return current action state.
    pub fn can_act_on(&self, player: &str, coord: CellCoord) -> bool {
        self.index(coord)
            .and_then(|idx| self.player(player).map(|masks| masks.action[idx]))
            .unwrap_or(false)
    }

    /// Return all visible cells for a player, optionally filtered by level.
    pub fn visible_cells(&self, player: &str, level: Option<u32>) -> Vec<CellCoord> {
        self.collect_cells(player, level, |masks, idx| masks.visible[idx])
    }

    /// Return all action cells for a player, optionally filtered by level.
    pub fn action_cells(&self, player: &str, level: Option<u32>) -> Vec<CellCoord> {
        self.collect_cells(player, level, |masks, idx| masks.action[idx])
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
        Ok(())
    }

    /// Clears all players.
    pub fn clear_all(&mut self) {
        for masks in self.players.values_mut() {
            masks.visible.fill(false);
            masks.explored.fill(false);
            masks.action.fill(false);
        }
    }
}
