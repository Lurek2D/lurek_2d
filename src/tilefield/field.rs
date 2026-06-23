//! Owns multi-level tilefield storage, channel blockers, channel costs, profiles, and lighting state.
//! Implements bounds checks, cell mutation, profile application, layer exports, and light accumulation.
//! Stores cells, named profiles, point lights, global light, and computed light values in one grid owner.
//! Uses topology and line helpers locally so callers can query blockers without owning traversal logic.
//! Provides renderer-independent input consumed by movement, visibility, minimap, and render adapters.
//! Keeps action, vision, movement, point-light, and sun channels independent by never inferring one from another.
//! Returns controlled string errors at the domain boundary so Lua bindings can attach lurek.tilefield names.
//! Does not depend on pathfind, visibility, raycaster, minimap, tilemap rendering, or renderer state.

use crate::tilefield::cell::{TileCell, TileChannel};
use crate::tilefield::light::{GlobalLight, LightColor, PointLight, PointLightUpdate};
use crate::tilefield::line::{line_between, visit_line_cells, CellCoord};
use crate::tilefield::profile::TileProfile;
use crate::tilefield::topology::TileTopology;
use std::collections::HashMap;

/// Multi-level tile gameplay field.
#[derive(Debug, Clone)]
pub struct TileField {
    width: u32,
    height: u32,
    levels: u32,
    topology: TileTopology,
    cells: Vec<TileCell>,
    profiles: HashMap<String, TileProfile>,
    point_lights: Vec<Option<PointLight>>,
    next_light_id: u32,
    global_light: GlobalLight,
    light_values: Vec<LightColor>,
}

impl TileField {
    /// Create a new field with all cells empty and built-in profiles registered.
    pub fn new(
        width: u32,
        height: u32,
        levels: u32,
        topology: TileTopology,
    ) -> Result<Self, String> {
        if width == 0 || height == 0 || levels == 0 {
            return Err("tilefield dimensions and levels must be > 0".to_string());
        }
        let len = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(levels))
            .and_then(|v| usize::try_from(v).ok())
            .ok_or_else(|| "tilefield dimensions overflow addressable storage".to_string())?;
        Ok(Self {
            width,
            height,
            levels,
            topology,
            cells: vec![TileCell::default(); len],
            profiles: TileProfile::builtins(),
            point_lights: Vec::new(),
            next_light_id: 1,
            global_light: GlobalLight::default(),
            light_values: vec![LightColor::BLACK; len],
        })
    }

    /// Return field dimensions.
    pub fn size(&self) -> (u32, u32, u32) {
        (self.width, self.height, self.levels)
    }

    /// Return field topology.
    pub fn topology(&self) -> TileTopology {
        self.topology
    }

    /// Return true when a zero-based coordinate is in bounds.
    pub fn in_bounds(&self, coord: CellCoord) -> bool {
        coord.x < self.width && coord.y < self.height && coord.z < self.levels
    }

    fn index(&self, coord: CellCoord) -> Option<usize> {
        if !self.in_bounds(coord) {
            return None;
        }
        coord
            .z
            .checked_mul(self.width * self.height)
            .and_then(|base| base.checked_add(coord.y * self.width + coord.x))
            .and_then(|idx| usize::try_from(idx).ok())
    }

    /// Return immutable cell reference.
    pub fn cell(&self, coord: CellCoord) -> Option<&TileCell> {
        self.index(coord).and_then(|idx| self.cells.get(idx))
    }

    /// Return mutable cell reference.
    pub fn cell_mut(&mut self, coord: CellCoord) -> Option<&mut TileCell> {
        self.index(coord).and_then(|idx| self.cells.get_mut(idx))
    }

    /// Clear every cell and computed light value.
    pub fn clear(&mut self) {
        for cell in &mut self.cells {
            *cell = TileCell::default();
        }
        self.light_values.fill(LightColor::BLACK);
    }

    /// Clear one cell.
    pub fn clear_cell(&mut self, coord: CellCoord) -> Result<(), String> {
        let cell = self
            .cell_mut(coord)
            .ok_or_else(|| "tilefield clearCell coordinate is out of bounds".to_string())?;
        *cell = TileCell::default();
        Ok(())
    }

    /// Set channel blocker for one cell.
    pub fn set_block(
        &mut self,
        coord: CellCoord,
        channel: TileChannel,
        blocked: bool,
    ) -> Result<(), String> {
        let cell = self
            .cell_mut(coord)
            .ok_or_else(|| "tilefield setBlock coordinate is out of bounds".to_string())?;
        cell.set_block(channel, blocked);
        Ok(())
    }

    /// Return channel blocker for one cell; out-of-bounds blocks line-style queries.
    pub fn blocks(&self, coord: CellCoord, channel: TileChannel) -> bool {
        self.cell(coord).is_none_or(|cell| cell.blocks(channel))
    }

    /// Set channel cost for one cell.
    pub fn set_cost(
        &mut self,
        coord: CellCoord,
        channel: TileChannel,
        cost: f32,
    ) -> Result<(), String> {
        let cell = self
            .cell_mut(coord)
            .ok_or_else(|| "tilefield setCost coordinate is out of bounds".to_string())?;
        cell.set_cost(channel, cost)
    }

    /// Return channel cost for one cell; out-of-bounds returns 0.
    pub fn cost(&self, coord: CellCoord, channel: TileChannel) -> f32 {
        self.cell(coord).map_or(0.0, |cell| cell.cost(channel))
    }

    /// Set top-light occlusion for one cell.
    pub fn set_sun_occlusion(&mut self, coord: CellCoord, value: f32) -> Result<(), String> {
        let cell = self
            .cell_mut(coord)
            .ok_or_else(|| "tilefield setSunOcclusion coordinate is out of bounds".to_string())?;
        cell.set_sun_occlusion(value)
    }

    /// Return top-light occlusion for one cell.
    pub fn sun_occlusion(&self, coord: CellCoord) -> f32 {
        self.cell(coord).map_or(1.0, TileCell::sun_occlusion)
    }

    /// Register or replace a named profile.
    pub fn set_profile(&mut self, name: String, profile: TileProfile) -> Result<(), String> {
        if name.trim().is_empty() {
            return Err("tilefield profile name must not be empty".to_string());
        }
        self.profiles.insert(name, profile);
        Ok(())
    }

    /// Return a named profile.
    pub fn profile(&self, name: &str) -> Option<&TileProfile> {
        self.profiles.get(name)
    }

    /// Remove a named profile.
    pub fn remove_profile(&mut self, name: &str) {
        self.profiles.remove(name);
    }

    /// Apply a named profile to one cell.
    pub fn apply_profile(&mut self, coord: CellCoord, name: &str) -> Result<(), String> {
        let profile = self
            .profiles
            .get(name)
            .cloned()
            .ok_or_else(|| format!("tilefield profile '{name}' does not exist"))?;
        let cell = self
            .cell_mut(coord)
            .ok_or_else(|| "tilefield applyProfile coordinate is out of bounds".to_string())?;
        for (channel, blocked) in profile.blockers {
            cell.set_block(channel, blocked);
        }
        for (channel, cost) in profile.costs {
            cell.set_cost(channel, cost)?;
        }
        cell.set_sun_occlusion(profile.sun_occlusion)?;
        cell.set_profile(Some(name.to_string()));
        Ok(())
    }

    /// Compute a topology-aware line.
    pub fn line(
        &self,
        from: CellCoord,
        to: CellCoord,
        include_endpoints: bool,
    ) -> Result<Vec<CellCoord>, String> {
        line_between(self.topology, from, to, include_endpoints)
    }

    /// Return the first blocking cell along a line, excluding the starting cell.
    pub fn first_blocker(
        &self,
        from: CellCoord,
        to: CellCoord,
        channel: TileChannel,
    ) -> Result<Option<CellCoord>, String> {
        let cells = self.line(from, to, true)?;
        for coord in cells.into_iter().skip(1) {
            if self.blocks(coord, channel) {
                return Ok(Some(coord));
            }
        }
        Ok(None)
    }

    /// Return true when no cell blocks the channel between two cells.
    pub fn clear_line(
        &self,
        from: CellCoord,
        to: CellCoord,
        channel: TileChannel,
    ) -> Result<bool, String> {
        Ok(self.first_blocker(from, to, channel)?.is_none())
    }

    /// Return topology distance.
    pub fn distance(&self, a: CellCoord, b: CellCoord) -> u32 {
        if a.z != b.z {
            a.z.abs_diff(b.z)
                + self
                    .topology
                    .distance(CellCoord { z: 0, ..a }, CellCoord { z: 0, ..b })
        } else {
            self.topology.distance(a, b)
        }
    }

    /// Add a point light and return its stable id.
    pub fn add_point_light(
        &mut self,
        x: u32,
        y: u32,
        z: u32,
        radius: f32,
        intensity: f32,
        color: LightColor,
    ) -> Result<u32, String> {
        let coord = CellCoord { x, y, z };
        if !self.in_bounds(coord) {
            return Err("tilefield addPointLight coordinate is out of bounds".to_string());
        }
        if !radius.is_finite() || radius <= 0.0 {
            return Err("tilefield point light radius must be finite and > 0".to_string());
        }
        if !intensity.is_finite() || intensity < 0.0 {
            return Err("tilefield point light intensity must be finite and >= 0".to_string());
        }
        let id = self.next_light_id;
        self.next_light_id = self.next_light_id.saturating_add(1).max(1);
        self.point_lights.push(Some(PointLight {
            id,
            x,
            y,
            z,
            radius,
            intensity,
            color: color.clamped(),
        }));
        Ok(id)
    }

    /// Update an existing point light.
    pub fn update_point_light(&mut self, id: u32, patch: PointLightUpdate) -> Result<(), String> {
        let light = self
            .point_lights
            .iter_mut()
            .filter_map(Option::as_mut)
            .find(|light| light.id == id)
            .ok_or_else(|| format!("tilefield point light id {id} does not exist"))?;
        let next_x = patch.x.unwrap_or(light.x);
        let next_y = patch.y.unwrap_or(light.y);
        let next_z = patch.z.unwrap_or(light.z);
        if next_x >= self.width || next_y >= self.height || next_z >= self.levels {
            return Err("tilefield updatePointLight coordinate is out of bounds".to_string());
        }
        if let Some(radius) = patch.radius {
            if !radius.is_finite() || radius <= 0.0 {
                return Err("tilefield point light radius must be finite and > 0".to_string());
            }
            light.radius = radius;
        }
        if let Some(intensity) = patch.intensity {
            if !intensity.is_finite() || intensity < 0.0 {
                return Err("tilefield point light intensity must be finite and >= 0".to_string());
            }
            light.intensity = intensity;
        }
        light.x = next_x;
        light.y = next_y;
        light.z = next_z;
        if let Some(color) = patch.color {
            light.color = color.clamped();
        }
        Ok(())
    }

    /// Remove a point light by id. Returns true when a light was removed.
    pub fn remove_point_light(&mut self, id: u32) -> bool {
        for slot in &mut self.point_lights {
            if slot.as_ref().is_some_and(|light| light.id == id) {
                *slot = None;
                return true;
            }
        }
        false
    }

    /// Remove all point lights.
    pub fn clear_point_lights(&mut self) {
        self.point_lights.clear();
    }

    /// Set global top light.
    pub fn set_global_light(&mut self, global: GlobalLight) {
        self.global_light = GlobalLight {
            intensity: global.intensity.max(0.0),
            color: global.color.clamped(),
        };
    }

    /// Compute current light values from ambient, point lights, and top light.
    pub fn compute_light(
        &mut self,
        include_point_lights: bool,
        include_global_light: bool,
        ambient: LightColor,
    ) {
        self.light_values.fill(ambient.clamped());
        if include_global_light {
            self.apply_global_light();
        }
        if include_point_lights {
            self.apply_point_lights();
        }
    }

    fn apply_global_light(&mut self) {
        for y in 0..self.height {
            for x in 0..self.width {
                let mut transmission = 1.0;
                for z in (0..self.levels).rev() {
                    let coord = CellCoord { x, y, z };
                    if let Some(idx) = self.index(coord) {
                        self.light_values[idx].add_scaled(
                            self.global_light.color,
                            self.global_light.intensity * transmission,
                        );
                    }
                    transmission *= 1.0 - self.sun_occlusion(coord).clamp(0.0, 1.0);
                }
            }
        }
    }

    fn apply_point_lights(&mut self) {
        let lights: Vec<_> = self.point_lights.iter().filter_map(Clone::clone).collect();
        for light in lights {
            let origin = CellCoord {
                x: light.x,
                y: light.y,
                z: light.z,
            };
            let radius = light.radius.ceil() as i32;
            for dy in -radius..=radius {
                for dx in -radius..=radius {
                    let x = light.x as i32 + dx;
                    let y = light.y as i32 + dy;
                    if x < 0 || y < 0 {
                        continue;
                    }
                    let coord = CellCoord {
                        x: x as u32,
                        y: y as u32,
                        z: light.z,
                    };
                    if !self.in_bounds(coord) {
                        continue;
                    }
                    let dist = self.point_light_distance(origin, coord);
                    if dist > light.radius {
                        continue;
                    }
                    let transmission = self.light_transmission(origin, coord);
                    if transmission <= f32::EPSILON {
                        continue;
                    }
                    let falloff = 1.0 - (dist / light.radius);
                    if let Some(idx) = self.index(coord) {
                        self.light_values[idx].add_scaled(
                            light.color,
                            light.intensity * falloff.max(0.0) * transmission,
                        );
                    }
                }
            }
        }
    }

    fn point_light_distance(&self, a: CellCoord, b: CellCoord) -> f32 {
        if a.z != b.z {
            return f32::INFINITY;
        }
        match self.topology {
            TileTopology::Square | TileTopology::IsoSquare => {
                let dx = a.x.abs_diff(b.x) as f32;
                let dy = a.y.abs_diff(b.y) as f32;
                (dx * dx + dy * dy).sqrt()
            }
            TileTopology::Hex => self.topology.distance(a, b) as f32,
        }
    }

    fn light_transmission(&self, origin: CellCoord, target: CellCoord) -> f32 {
        if origin == target {
            return 1.0;
        }
        let mut transmission = 1.0;
        let mut first = true;
        let _ = visit_line_cells(self.topology, origin, target, |coord| {
            if first {
                first = false;
                return true;
            }
            if coord == target {
                return false;
            }
            if self.blocks(coord, TileChannel::Light) {
                transmission = 0.0;
                return false;
            }
            transmission *= self.cost(coord, TileChannel::Light).clamp(0.0, 1.0);
            transmission > f32::EPSILON
        });
        transmission.clamp(0.0, 1.0)
    }

    /// Return computed light for a cell.
    pub fn light_at(&self, coord: CellCoord) -> LightColor {
        self.index(coord)
            .and_then(|idx| self.light_values.get(idx).copied())
            .unwrap_or(LightColor::BLACK)
    }

    /// Export a blocker layer for one level in row-major order.
    pub fn export_block_layer(&self, channel: TileChannel, z: u32) -> Vec<bool> {
        let mut out = Vec::with_capacity((self.width * self.height) as usize);
        for y in 0..self.height {
            for x in 0..self.width {
                out.push(self.blocks(CellCoord { x, y, z }, channel));
            }
        }
        out
    }

    /// Export a cost layer for one level in row-major order.
    pub fn export_cost_layer(&self, channel: TileChannel, z: u32) -> Vec<f32> {
        let mut out = Vec::with_capacity((self.width * self.height) as usize);
        for y in 0..self.height {
            for x in 0..self.width {
                out.push(self.cost(CellCoord { x, y, z }, channel));
            }
        }
        out
    }

    /// Export profile names for one level in row-major order.
    pub fn export_profile_layer(&self, z: u32) -> Vec<Option<String>> {
        let mut out = Vec::with_capacity((self.width * self.height) as usize);
        for y in 0..self.height {
            for x in 0..self.width {
                out.push(
                    self.cell(CellCoord { x, y, z })
                        .and_then(|cell| cell.profile().map(ToOwned::to_owned)),
                );
            }
        }
        out
    }
}
