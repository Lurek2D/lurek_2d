//! Owns multi-level tilefield storage, channel blockers, channel costs, declared object slots, regions, and cell exports.
//! Implements bounds checks, cell mutation, line queries, modifiers, and layer exports.
//! Stores cells, slots, modifiers, and regions in one grid owner.
//! Uses topology and line helpers locally so callers can query blockers without owning traversal logic.
//! Provides renderer-independent input consumed by movement, awareness, tilelight, minimap, and render adapters.
//! Keeps action, vision, movement, light, and sun channels independent by never inferring one from another.
//! Returns controlled string errors at the domain boundary so Lua bindings can attach lurek.tilefield names.
//! Does not depend on pathfind, awareness, tilelight, raycaster, minimap, tilemap rendering, or renderer state.

use crate::tilefield::cell::{TileCell, TileChannel};
use crate::tilefield::emitter::{TileLightEmitter, TileLightSource};
use crate::tilefield::line::{line_between, CellCoord};
use crate::tilefield::modifier::TileModifier;
use crate::tilefield::topology::TileTopology;
use std::collections::BTreeSet;
use std::collections::{HashMap, HashSet};

/// Named tile-level region stored as an explicit set of whole cells.
#[derive(Debug, Clone)]
pub struct TileRegion {
    /// Region name.
    pub name: String,
    /// Whole tile cells owned by the region.
    pub cells: Vec<CellCoord>,
}

/// Multi-level tile gameplay field.
#[derive(Debug, Clone)]
pub struct TileField {
    width: u32,
    height: u32,
    levels: u32,
    topology: TileTopology,
    cells: Vec<TileCell>,
    modifiers: HashMap<String, TileModifier>,
    slots: BTreeSet<String>,
    regions: HashMap<String, TileRegion>,
}

impl TileField {
    /// Create a new field with all cells empty.
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
            modifiers: HashMap::new(),
            slots: BTreeSet::new(),
            regions: HashMap::new(),
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

    /// Return same-level neighbours for a coordinate using this field topology.
    pub fn neighbors(&self, coord: CellCoord) -> Vec<CellCoord> {
        if !self.in_bounds(coord) {
            return Vec::new();
        }
        self.topology.neighbors(coord, self.width, self.height)
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

    /// Define or replace a named rectangular tile region on one level using inclusive zero-based coordinates.
    pub fn set_region_rect(
        &mut self,
        name: String,
        x1: u32,
        y1: u32,
        x2: u32,
        y2: u32,
        z: u32,
    ) -> Result<(), String> {
        if name.trim().is_empty() {
            return Err("tilefield region name must not be empty".to_string());
        }
        let min_x = x1.min(x2);
        let max_x = x1.max(x2);
        let min_y = y1.min(y2);
        let max_y = y1.max(y2);
        if max_x >= self.width || max_y >= self.height || z >= self.levels {
            return Err("tilefield region rectangle is out of bounds".to_string());
        }
        let mut cells = Vec::new();
        for y in min_y..=max_y {
            for x in min_x..=max_x {
                cells.push(CellCoord { x, y, z });
            }
        }
        self.regions
            .insert(name.clone(), TileRegion { name, cells });
        Ok(())
    }

    /// Define or replace a named tile region from explicit whole cells.
    pub fn set_region_cells(&mut self, name: String, cells: Vec<CellCoord>) -> Result<(), String> {
        if name.trim().is_empty() {
            return Err("tilefield region name must not be empty".to_string());
        }
        let mut seen = HashSet::new();
        let mut unique = Vec::new();
        for coord in cells {
            if !self.in_bounds(coord) {
                return Err("tilefield region cell is out of bounds".to_string());
            }
            if seen.insert(coord) {
                unique.push(coord);
            }
        }
        self.regions.insert(
            name.clone(),
            TileRegion {
                name,
                cells: unique,
            },
        );
        Ok(())
    }

    /// Remove a named region. Returns true when it existed.
    pub fn remove_region(&mut self, name: &str) -> bool {
        self.regions.remove(name).is_some()
    }

    /// Return true when a region contains a zero-based coordinate.
    pub fn region_contains(&self, name: &str, coord: CellCoord) -> bool {
        self.regions
            .get(name)
            .is_some_and(|region| region.cells.contains(&coord))
    }

    /// Return copied cells for a named region.
    pub fn region_cells(&self, name: &str) -> Option<Vec<CellCoord>> {
        self.regions.get(name).map(|region| region.cells.clone())
    }

    /// Return region names in stable sorted order.
    pub fn region_names(&self) -> Vec<String> {
        let mut names: Vec<_> = self.regions.keys().cloned().collect();
        names.sort();
        names
    }

    /// Return immutable cell reference.
    pub fn cell(&self, coord: CellCoord) -> Option<&TileCell> {
        self.index(coord).and_then(|idx| self.cells.get(idx))
    }

    /// Return mutable cell reference.
    pub fn cell_mut(&mut self, coord: CellCoord) -> Option<&mut TileCell> {
        self.index(coord).and_then(|idx| self.cells.get_mut(idx))
    }

    /// Clear every cell.
    pub fn clear(&mut self) {
        for cell in &mut self.cells {
            *cell = TileCell::default();
        }
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
        let Some(cell) = self.cell(coord) else {
            return true;
        };
        let mut blocked = cell.blocks(channel);
        for modifier_name in cell.modifiers() {
            if let Some(value) = self
                .modifiers
                .get(modifier_name)
                .and_then(|modifier| modifier.blockers.get(&channel))
            {
                blocked = *value;
            }
        }
        blocked
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
        let Some(cell) = self.cell(coord) else {
            return 0.0;
        };
        let mut cost = cell.cost(channel);
        for modifier_name in cell.modifiers() {
            let Some(modifier) = self.modifiers.get(modifier_name) else {
                continue;
            };
            if let Some(multiplier) = modifier.cost_mul.get(&channel) {
                cost *= *multiplier;
            }
            if let Some(add) = modifier.cost_add.get(&channel) {
                cost += *add;
            }
        }
        cost.max(0.0)
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
        let Some(cell) = self.cell(coord) else {
            return 1.0;
        };
        let mut occlusion = cell.sun_occlusion();
        for modifier_name in cell.modifiers() {
            if let Some(modifier) = self.modifiers.get(modifier_name) {
                occlusion += modifier.sun_occlusion_add;
            }
        }
        occlusion.clamp(0.0, 1.0)
    }

    /// Register or replace a named tile modifier.
    pub fn set_modifier(&mut self, name: String, mut modifier: TileModifier) -> Result<(), String> {
        let name = name.trim();
        if name.is_empty() {
            return Err("tilefield modifier name must not be empty".to_string());
        }
        modifier.name = name.to_string();
        self.modifiers.insert(name.to_string(), modifier);
        Ok(())
    }

    /// Return a named tile modifier.
    pub fn modifier(&self, name: &str) -> Option<&TileModifier> {
        self.modifiers.get(name)
    }

    /// Remove a named modifier and clear it from all cells.
    pub fn remove_modifier(&mut self, name: &str) -> bool {
        let removed = self.modifiers.remove(name).is_some();
        if removed {
            for cell in &mut self.cells {
                cell.remove_modifier(name);
            }
        }
        removed
    }

    /// Apply a named modifier to one cell.
    pub fn apply_modifier(&mut self, coord: CellCoord, name: &str) -> Result<(), String> {
        if !self.modifiers.contains_key(name) {
            return Err(format!("tilefield modifier '{name}' does not exist"));
        }
        let cell = self
            .cell_mut(coord)
            .ok_or_else(|| "tilefield applyModifier coordinate is out of bounds".to_string())?;
        cell.add_modifier(name.to_string());
        Ok(())
    }

    /// Remove one modifier from one cell.
    pub fn clear_modifier(&mut self, coord: CellCoord, name: &str) -> Result<bool, String> {
        let cell = self
            .cell_mut(coord)
            .ok_or_else(|| "tilefield clearModifier coordinate is out of bounds".to_string())?;
        Ok(cell.remove_modifier(name))
    }

    /// Return active modifier names for one cell.
    pub fn active_modifiers(&self, coord: CellCoord) -> Vec<String> {
        self.cell(coord)
            .map(|cell| cell.modifiers().to_vec())
            .unwrap_or_default()
    }

    /// Set, replace, or clear a named tilelight source on one cell.
    pub fn set_light(
        &mut self,
        coord: CellCoord,
        source: String,
        light: Option<TileLightEmitter>,
    ) -> Result<(), String> {
        let cell = self
            .cell_mut(coord)
            .ok_or_else(|| "tilefield setLight coordinate is out of bounds".to_string())?;
        cell.set_light(source, light)
    }

    /// Return tilelight sources contributed by base cell data and active modifiers.
    pub fn tile_light_sources(&self) -> Vec<TileLightSource> {
        let mut out = Vec::new();
        for z in 0..self.levels {
            for y in 0..self.height {
                for x in 0..self.width {
                    let coord = CellCoord { x, y, z };
                    let Some(cell) = self.cell(coord) else {
                        continue;
                    };
                    for light in cell.lights().values() {
                        out.push(TileLightSource {
                            x,
                            y,
                            z,
                            radius: light.radius,
                            intensity: light.intensity,
                            color: light.color,
                        });
                    }
                    for modifier_name in cell.modifiers() {
                        let Some(light) = self
                            .modifiers
                            .get(modifier_name)
                            .and_then(|modifier| modifier.light.as_ref())
                        else {
                            continue;
                        };
                        out.push(TileLightSource {
                            x,
                            y,
                            z,
                            radius: light.radius,
                            intensity: light.intensity,
                            color: light.color,
                        });
                    }
                }
            }
        }
        out
    }

    /// Set a named object/tile reference on one cell.
    pub fn set_ref(&mut self, coord: CellCoord, slot: String, value: u32) -> Result<(), String> {
        if !self.has_slot(&slot) {
            return Err(format!("tilefield slot '{slot}' is not defined"));
        }
        let cell = self
            .cell_mut(coord)
            .ok_or_else(|| "tilefield setRef coordinate is out of bounds".to_string())?;
        cell.set_ref(slot, value)
    }

    /// Return a named object/tile reference for one cell.
    pub fn get_ref(&self, coord: CellCoord, slot: &str) -> Option<u32> {
        self.cell(coord).and_then(|cell| cell.get_ref(slot))
    }

    /// Define a game-owned object slot that cells may reference.
    pub fn define_slot(&mut self, slot: String) -> Result<(), String> {
        let slot = slot.trim();
        if slot.is_empty() {
            return Err("tilefield slot name must not be empty".to_string());
        }
        self.slots.insert(slot.to_string());
        Ok(())
    }

    /// Remove a declared slot and clear its references from every cell.
    pub fn remove_slot(&mut self, slot: &str) -> bool {
        let removed = self.slots.remove(slot);
        if removed {
            for cell in &mut self.cells {
                cell.clear_ref(slot);
                let _ = cell.set_light(slot.to_string(), None);
            }
        }
        removed
    }

    /// Return true when a slot has been declared on this field.
    pub fn has_slot(&self, slot: &str) -> bool {
        self.slots.contains(slot)
    }

    /// Return every declared ref slot name.
    pub fn ref_slots(&self) -> Vec<String> {
        self.slots.iter().cloned().collect()
    }

    /// Clear a named object/tile reference on one cell.
    pub fn clear_ref(&mut self, coord: CellCoord, slot: &str) -> Result<(), String> {
        if !self.has_slot(slot) {
            return Err(format!("tilefield slot '{slot}' is not defined"));
        }
        let cell = self
            .cell_mut(coord)
            .ok_or_else(|| "tilefield clearRef coordinate is out of bounds".to_string())?;
        cell.clear_ref(slot);
        cell.set_light(slot.to_string(), None)?;
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

    /// Export one named object/tile reference slot for one level in row-major order.
    pub fn export_ref_layer(&self, slot: &str, z: u32) -> Vec<Option<u32>> {
        let mut out = Vec::with_capacity((self.width * self.height) as usize);
        for y in 0..self.height {
            for x in 0..self.width {
                out.push(self.get_ref(CellCoord { x, y, z }, slot));
            }
        }
        out
    }

    fn validate_layer_values(&self, z: u32, len: usize, label: &str) -> Result<(), String> {
        if z >= self.levels {
            return Err(format!("tilefield {label} level is out of bounds"));
        }
        let expected = self
            .width
            .checked_mul(self.height)
            .and_then(|value| usize::try_from(value).ok())
            .ok_or_else(|| format!("tilefield {label} dimensions overflow"))?;
        if len != expected {
            return Err(format!(
                "tilefield {label} expected {expected} values, got {len}"
            ));
        }
        Ok(())
    }

    /// Write a full blocker layer for one channel and level in row-major order.
    pub fn write_block_layer(
        &mut self,
        channel: TileChannel,
        z: u32,
        values: &[bool],
    ) -> Result<(), String> {
        self.validate_layer_values(z, values.len(), "writeBlockLayer")?;
        for y in 0..self.height {
            for x in 0..self.width {
                let idx = (y * self.width + x) as usize;
                self.set_block(CellCoord { x, y, z }, channel, values[idx])?;
            }
        }
        Ok(())
    }

    /// Write a full cost layer for one channel and level in row-major order.
    pub fn write_cost_layer(
        &mut self,
        channel: TileChannel,
        z: u32,
        values: &[f32],
    ) -> Result<(), String> {
        self.validate_layer_values(z, values.len(), "writeCostLayer")?;
        for y in 0..self.height {
            for x in 0..self.width {
                let idx = (y * self.width + x) as usize;
                self.set_cost(CellCoord { x, y, z }, channel, values[idx])?;
            }
        }
        Ok(())
    }

    /// Write a full named ref layer for one level in row-major order.
    pub fn write_ref_layer(
        &mut self,
        slot: &str,
        z: u32,
        values: &[Option<u32>],
    ) -> Result<(), String> {
        self.validate_layer_values(z, values.len(), "writeRefLayer")?;
        for y in 0..self.height {
            for x in 0..self.width {
                let idx = (y * self.width + x) as usize;
                let coord = CellCoord { x, y, z };
                match values[idx] {
                    Some(value) => self.set_ref(coord, slot.to_string(), value)?,
                    None => self.clear_ref(coord, slot)?,
                }
            }
        }
        Ok(())
    }
}
