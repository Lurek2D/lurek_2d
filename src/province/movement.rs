//! Unit movement along province paths with progress interpolation.
//!
//! Provides a [`MovingUnit`] that advances along a [`ProvincePath`] over time,
//! and a [`MovementManager`] that ticks all active units each frame.

use std::collections::HashMap;

use crate::math::Vec2;

use super::core::ProvinceMap;
use super::pathfinding::ProvincePath;

/// A unit that moves along a province path.
#[derive(Debug, Clone)]
pub struct MovingUnit {
    /// Unique identifier for this moving unit.
    pub id: u64,
    /// The path this unit is following.
    pub path: ProvincePath,
    /// Index of the current province in the path.
    pub current_index: usize,
    /// Progress between current and next province (0.0 = at current, 1.0 = at next).
    pub progress: f32,
    /// Movement speed in provinces per second.
    pub speed: f32,
    /// Whether the unit is currently paused.
    pub paused: bool,
}

impl MovingUnit {
    /// Create a new moving unit on the given path.
    pub fn new(id: u64, path: ProvincePath, speed: f32) -> Self {
        Self {
            id,
            path,
            current_index: 0,
            progress: 0.0,
            speed,
            paused: false,
        }
    }

    /// Advance the unit along its path by `dt` seconds.
    ///
    /// Returns `true` if the unit has reached its destination.
    pub fn update(&mut self, dt: f32) -> bool {
        if self.paused || self.is_finished() {
            return self.is_finished();
        }

        self.progress += self.speed * dt;

        while self.progress >= 1.0 && !self.is_finished() {
            self.progress -= 1.0;
            self.current_index += 1;
        }

        if self.is_finished() {
            self.progress = 0.0;
        }

        self.is_finished()
    }

    /// Get the province ID at the unit's current position.
    pub fn current_province(&self) -> u32 {
        let idx = self.current_index.min(self.path.provinces.len().saturating_sub(1));
        self.path.provinces[idx]
    }

    /// Interpolate the unit's world position between current and next province primary positions.
    ///
    /// Uses `positions[0]` (primary position) if available, otherwise falls
    /// back to the province centroid.
    pub fn world_position(&self, map: &ProvinceMap) -> Vec2 {
        let current_idx = self.current_index.min(self.path.provinces.len().saturating_sub(1));
        let current_id = self.path.provinces[current_idx];

        let current_pos = map
            .get_province(current_id)
            .map(|p| p.positions.first().copied().unwrap_or(p.centroid))
            .unwrap_or(Vec2::ZERO);

        let next_idx = current_idx + 1;
        if next_idx >= self.path.provinces.len() || self.is_finished() {
            return current_pos;
        }

        let next_id = self.path.provinces[next_idx];
        let next_pos = map
            .get_province(next_id)
            .map(|p| p.positions.first().copied().unwrap_or(p.centroid))
            .unwrap_or(Vec2::ZERO);

        let t = self.progress;
        Vec2::new(
            current_pos.x + (next_pos.x - current_pos.x) * t,
            current_pos.y + (next_pos.y - current_pos.y) * t,
        )
    }

    /// Whether the unit has reached its final destination.
    pub fn is_finished(&self) -> bool {
        self.current_index >= self.path.provinces.len().saturating_sub(1)
    }
}

/// Manages all moving units on the province map.
#[derive(Debug, Clone, Default)]
pub struct MovementManager {
    units: HashMap<u64, MovingUnit>,
    next_id: u64,
}

impl MovementManager {
    /// Create an empty movement manager.
    pub fn new() -> Self {
        Self::default()
    }

    /// Add a unit moving along the given path at the given speed.
    ///
    /// Returns the assigned unit ID.
    pub fn add_unit(&mut self, path: ProvincePath, speed: f32) -> u64 {
        let id = self.next_id;
        self.next_id += 1;
        self.units.insert(id, MovingUnit::new(id, path, speed));
        id
    }

    /// Remove a unit by ID. Returns `true` if the unit existed.
    pub fn remove_unit(&mut self, id: u64) -> bool {
        self.units.remove(&id).is_some()
    }

    /// Get a reference to a unit by ID.
    pub fn get_unit(&self, id: u64) -> Option<&MovingUnit> {
        self.units.get(&id)
    }

    /// Tick all units forward by `dt` seconds.
    ///
    /// Finished units are kept in the manager — call [`remove_unit`] to clean
    /// them up when desired.
    pub fn update_all(&mut self, dt: f32) {
        for unit in self.units.values_mut() {
            unit.update(dt);
        }
    }

    /// Iterate over all active units.
    pub fn units(&self) -> impl Iterator<Item = &MovingUnit> {
        self.units.values()
    }
}
