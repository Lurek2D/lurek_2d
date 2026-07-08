//! This file owns field behavior inside the tilefield subsystem, close to its data and invariants.
//! It keeps validation, defaults, and error-facing rules near the operations that mutate field state.
//! Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.
//! Public functions in this file are the stable entry points other modules should use for field work.
//! Serialization, indexing, and boundary checks stay here when they depend on field internals.
//! Renderer, API, and test layers should call through these helpers rather than duplicate private rules.
//! Open this file when field ownership changes, but keep unrelated subsystem policy in sibling modules.
//! The code favors small data transformations so examples, specs, and tests can assert behavior directly.
//! Stateful changes are kept deterministic here so generated docs and smoke tests remain reproducible.
//! Cross-module dependencies are intentionally narrow, with shared types imported only at this boundary.

use crate::tilefield::category::{TileCategory, TileCategoryKind};
use crate::tilefield::cell::{TileCell, TileChannel};
use crate::tilefield::emitter::{TileLightEmitter, TileLightSource};
use crate::tilefield::line::{line_between, CellCoord};
use crate::tilefield::modifier::TileModifier;
use crate::tilefield::reference::TileRef;
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
    /// Arbitrary string properties attached to the region.
    pub properties: HashMap<String, String>,
}

/// Multi-level tile gameplay field.
#[derive(Debug, Clone)]
pub struct TileField {
    width: u32,
    height: u32,
    levels: u32,
    topology: TileTopology,
    cells: Vec<TileCell>,
    categories: HashMap<String, TileCategory>,
    modifiers: HashMap<String, TileModifier>,
    slots: BTreeSet<String>,
    regions: HashMap<String, TileRegion>,
    occupants: HashMap<CellCoord, u64>,
    resources: HashMap<CellCoord, String>,
    buildable: HashMap<CellCoord, bool>,
    version: u64,
    dirty_rects: Vec<(u32, u32, u32, u32, u32)>,
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
        let mut categories = HashMap::new();
        for (name, kind) in [
            ("move", TileCategoryKind::Movement),
            ("vision", TileCategoryKind::Awareness),
            ("action", TileCategoryKind::Awareness),
            ("light", TileCategoryKind::Light),
            ("sun", TileCategoryKind::Sun),
        ] {
            categories.insert(
                name.to_string(),
                TileCategory::new(name.to_string(), kind, true)?,
            );
        }
        let mut modifiers = HashMap::new();
        Self::install_builtin_profiles(&mut modifiers)?;
        Ok(Self {
            width,
            height,
            levels,
            topology,
            cells: vec![TileCell::default(); len],
            categories,
            modifiers,
            slots: BTreeSet::new(),
            regions: HashMap::new(),
            occupants: HashMap::new(),
            resources: HashMap::new(),
            buildable: HashMap::new(),
            version: 1,
            dirty_rects: Vec::new(),
        })
    }

    /// Set or replace the occupant id for one cell.
    pub fn set_occupant(&mut self, coord: CellCoord, occupant: u64) -> Result<(), String> {
        if !self.in_bounds(coord) {
            return Err("tilefield occupant coordinate is out of bounds".to_string());
        }
        self.occupants.insert(coord, occupant);
        self.mark_dirty_cell(coord);
        Ok(())
    }

    /// Clear the occupant id for one cell.
    pub fn clear_occupant(&mut self, coord: CellCoord) -> Result<bool, String> {
        if !self.in_bounds(coord) {
            return Err("tilefield occupant coordinate is out of bounds".to_string());
        }
        let removed = self.occupants.remove(&coord).is_some();
        if removed {
            self.mark_dirty_cell(coord);
        }
        Ok(removed)
    }

    /// Return the occupant id for one cell.
    pub fn occupant(&self, coord: CellCoord) -> Option<u64> {
        self.occupants.get(&coord).copied()
    }

    /// Set or clear the resource label for one cell.
    pub fn set_resource(
        &mut self,
        coord: CellCoord,
        resource: Option<String>,
    ) -> Result<(), String> {
        if !self.in_bounds(coord) {
            return Err("tilefield resource coordinate is out of bounds".to_string());
        }
        match resource {
            Some(resource) if !resource.trim().is_empty() => {
                self.resources.insert(coord, resource);
            }
            _ => {
                self.resources.remove(&coord);
            }
        }
        self.mark_dirty_cell(coord);
        Ok(())
    }

    /// Return the resource label for one cell.
    pub fn resource(&self, coord: CellCoord) -> Option<&str> {
        self.resources.get(&coord).map(String::as_str)
    }

    /// Set whether one cell accepts build placement.
    pub fn set_buildable(&mut self, coord: CellCoord, value: bool) -> Result<(), String> {
        if !self.in_bounds(coord) {
            return Err("tilefield buildable coordinate is out of bounds".to_string());
        }
        self.buildable.insert(coord, value);
        self.mark_dirty_cell(coord);
        Ok(())
    }

    /// Return whether one cell accepts build placement.
    pub fn is_buildable(&self, coord: CellCoord) -> bool {
        self.in_bounds(coord) && *self.buildable.get(&coord).unwrap_or(&true)
    }

    /// Return field dimensions.
    pub fn size(&self) -> (u32, u32, u32) {
        (self.width, self.height, self.levels)
    }

    /// Return field topology.
    pub fn topology(&self) -> TileTopology {
        self.topology
    }

    /// Return the monotonically increasing field data version.
    pub fn version(&self) -> u64 {
        self.version
    }

    /// Register or replace a user-defined category.
    pub fn define_category(&mut self, category: TileCategory) -> Result<(), String> {
        if category.name.trim().is_empty() {
            return Err("tilefield category name must not be empty".to_string());
        }
        self.categories.insert(category.name.clone(), category);
        self.bump_version();
        Ok(())
    }

    /// Return a category record by name.
    pub fn category(&self, name: &str) -> Option<&TileCategory> {
        self.categories.get(name)
    }

    /// Return known category names in stable order.
    pub fn category_names(&self) -> Vec<String> {
        let mut names: Vec<_> = self.categories.keys().cloned().collect();
        names.sort();
        names
    }

    /// Clear and return pending dirty cell rectangles.
    pub fn drain_dirty_rects(&mut self) -> Vec<(u32, u32, u32, u32, u32)> {
        std::mem::take(&mut self.dirty_rects)
    }

    fn bump_version(&mut self) {
        self.version = self.version.saturating_add(1).max(1);
    }

    fn mark_dirty_cell(&mut self, coord: CellCoord) {
        self.bump_version();
        self.dirty_rects.push((coord.x, coord.y, coord.z, 1, 1));
    }

    fn channel_for_category(category: &str) -> Option<TileChannel> {
        TileChannel::parse(category).ok()
    }

    fn install_builtin_profiles(
        modifiers: &mut HashMap<String, TileModifier>,
    ) -> Result<(), String> {
        for (name, blocks, sun_occlusion) in [
            ("empty", [false, false, false, false], 0.0),
            ("wall", [true, true, true, true], 1.0),
            ("window", [true, false, true, false], 0.2),
            ("door_open", [false, false, false, false], 0.0),
            ("door_closed", [true, true, true, true], 0.6),
            ("half_wall", [true, false, false, false], 0.5),
        ] {
            let mut modifier = TileModifier::new(name.to_string())?;
            for (channel, blocked) in [
                (TileChannel::Move, blocks[0]),
                (TileChannel::Vision, blocks[1]),
                (TileChannel::Action, blocks[2]),
                (TileChannel::Light, blocks[3]),
            ] {
                modifier.blockers.insert(channel, blocked);
            }
            modifier.sun_occlusion_add = sun_occlusion;
            modifiers.insert(name.to_string(), modifier);
        }
        Ok(())
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
        self.regions.insert(
            name.clone(),
            TileRegion {
                properties: self
                    .regions
                    .get(&name)
                    .map(|region| region.properties.clone())
                    .unwrap_or_default(),
                name,
                cells,
            },
        );
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
                properties: self
                    .regions
                    .get(&name)
                    .map(|region| region.properties.clone())
                    .unwrap_or_default(),
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

    /// Set, replace, or clear one string property on a named region.
    pub fn set_region_property(
        &mut self,
        name: &str,
        key: String,
        value: Option<String>,
    ) -> Result<(), String> {
        let region = self
            .regions
            .get_mut(name)
            .ok_or_else(|| format!("tilefield region '{name}' does not exist"))?;
        let key = key.trim();
        if key.is_empty() {
            return Err("tilefield region property name must not be empty".to_string());
        }
        match value {
            Some(value) => {
                region.properties.insert(key.to_string(), value);
            }
            None => {
                region.properties.remove(key);
            }
        }
        self.bump_version();
        Ok(())
    }

    /// Return one string property from a named region.
    pub fn region_property(&self, name: &str, key: &str) -> Option<&str> {
        self.regions
            .get(name)
            .and_then(|region| region.properties.get(key))
            .map(|value| value.as_str())
    }

    /// Return cloned properties for a named region.
    pub fn region_properties(&self, name: &str) -> Option<HashMap<String, String>> {
        self.regions
            .get(name)
            .map(|region| region.properties.clone())
    }

    /// Return sorted region names that contain the given coordinate.
    pub fn regions_at(&self, coord: CellCoord) -> Vec<String> {
        let mut names = Vec::new();
        for (name, region) in &self.regions {
            if region.cells.contains(&coord) {
                names.push(name.clone());
            }
        }
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
        self.mark_dirty_cell(coord);
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
        self.mark_dirty_cell(coord);
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

    /// Set a blocker override for one user-defined category on one cell.
    pub fn set_category_block(
        &mut self,
        coord: CellCoord,
        category: String,
        blocked: bool,
    ) -> Result<(), String> {
        let cell = self
            .cell_mut(coord)
            .ok_or_else(|| "tilefield setCategoryBlock coordinate is out of bounds".to_string())?;
        cell.set_category_block(category, Some(blocked))?;
        self.mark_dirty_cell(coord);
        Ok(())
    }

    /// Return whether one cell blocks a user-defined category.
    pub fn blocks_category(&self, coord: CellCoord, category: &str) -> bool {
        let Some(cell) = self.cell(coord) else {
            return true;
        };
        let mut blocked = cell
            .blocks_category(category)
            .or_else(|| Self::channel_for_category(category).map(|channel| cell.blocks(channel)))
            .unwrap_or(false);
        for modifier_name in cell.modifiers() {
            let Some(modifier) = self.modifiers.get(modifier_name) else {
                continue;
            };
            if let Some(value) = modifier.category_blockers.get(category) {
                blocked = *value;
            } else if let Some(channel) = Self::channel_for_category(category) {
                if let Some(value) = modifier.blockers.get(&channel) {
                    blocked = *value;
                }
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
        cell.set_cost(channel, cost)?;
        self.mark_dirty_cell(coord);
        Ok(())
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

    /// Set a movement/transmission cost for a user-defined category on one cell.
    pub fn set_category_cost(
        &mut self,
        coord: CellCoord,
        category: String,
        cost: f32,
    ) -> Result<(), String> {
        let cell = self
            .cell_mut(coord)
            .ok_or_else(|| "tilefield setCategoryCost coordinate is out of bounds".to_string())?;
        cell.set_category_cost(category, Some(cost))?;
        self.mark_dirty_cell(coord);
        Ok(())
    }

    /// Return effective cost for a user-defined category.
    pub fn category_cost(&self, coord: CellCoord, category: &str) -> f32 {
        let Some(cell) = self.cell(coord) else {
            return 0.0;
        };
        let mut cost = cell
            .category_cost(category)
            .or_else(|| Self::channel_for_category(category).map(|channel| cell.cost(channel)))
            .unwrap_or(1.0);
        for modifier_name in cell.modifiers() {
            let Some(modifier) = self.modifiers.get(modifier_name) else {
                continue;
            };
            if let Some(multiplier) = modifier.category_cost_mul.get(category) {
                cost *= *multiplier;
            } else if let Some(channel) = Self::channel_for_category(category) {
                if let Some(multiplier) = modifier.cost_mul.get(&channel) {
                    cost *= *multiplier;
                }
            }
            if let Some(add) = modifier.category_cost_add.get(category) {
                cost += *add;
            } else if let Some(channel) = Self::channel_for_category(category) {
                if let Some(add) = modifier.cost_add.get(&channel) {
                    cost += *add;
                }
            }
        }
        cost.max(0.0)
    }

    /// Set a transmission multiplier for a category.
    pub fn set_category_transmission(
        &mut self,
        coord: CellCoord,
        category: String,
        value: f32,
    ) -> Result<(), String> {
        let cell = self.cell_mut(coord).ok_or_else(|| {
            "tilefield setCategoryTransmission coordinate is out of bounds".to_string()
        })?;
        cell.set_category_transmission(category, Some(value))?;
        self.mark_dirty_cell(coord);
        Ok(())
    }

    /// Return effective category transmission in `[0, 1]`.
    pub fn category_transmission(&self, coord: CellCoord, category: &str) -> f32 {
        if self.blocks_category(coord, category) {
            return 0.0;
        }
        let Some(cell) = self.cell(coord) else {
            return 0.0;
        };
        let base = cell
            .category_transmission(category)
            .unwrap_or_else(|| self.category_cost(coord, category).clamp(0.0, 1.0));
        let mut transmission = base;
        for modifier_name in cell.modifiers() {
            if let Some(value) = self
                .modifiers
                .get(modifier_name)
                .and_then(|modifier| modifier.category_transmission.get(category))
            {
                transmission *= *value;
            }
        }
        transmission.clamp(0.0, 1.0)
    }

    /// Set an RGB filter for a category.
    pub fn set_category_filter(
        &mut self,
        coord: CellCoord,
        category: String,
        value: [f32; 3],
    ) -> Result<(), String> {
        let cell = self
            .cell_mut(coord)
            .ok_or_else(|| "tilefield setCategoryFilter coordinate is out of bounds".to_string())?;
        cell.set_category_filter(category, Some(value))?;
        self.mark_dirty_cell(coord);
        Ok(())
    }

    /// Return effective RGB filter for a category.
    pub fn category_filter(&self, coord: CellCoord, category: &str) -> [f32; 3] {
        let Some(cell) = self.cell(coord) else {
            return [0.0, 0.0, 0.0];
        };
        let mut filter = cell.category_filter(category).unwrap_or([1.0, 1.0, 1.0]);
        for modifier_name in cell.modifiers() {
            if let Some(value) = self
                .modifiers
                .get(modifier_name)
                .and_then(|modifier| modifier.category_filters.get(category))
            {
                filter[0] *= value[0];
                filter[1] *= value[1];
                filter[2] *= value[2];
            }
        }
        filter
    }

    /// Set top-light occlusion for one cell.
    pub fn set_sun_occlusion(&mut self, coord: CellCoord, value: f32) -> Result<(), String> {
        let cell = self
            .cell_mut(coord)
            .ok_or_else(|| "tilefield setSunOcclusion coordinate is out of bounds".to_string())?;
        cell.set_sun_occlusion(value)?;
        self.mark_dirty_cell(coord);
        Ok(())
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
        self.bump_version();
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
            self.bump_version();
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
        self.mark_dirty_cell(coord);
        Ok(())
    }

    /// Apply a named profile to one cell.
    pub fn apply_profile(&mut self, coord: CellCoord, name: &str) -> Result<(), String> {
        self.apply_modifier(coord, name)
    }

    /// Remove one modifier from one cell.
    pub fn clear_modifier(&mut self, coord: CellCoord, name: &str) -> Result<bool, String> {
        let cell = self
            .cell_mut(coord)
            .ok_or_else(|| "tilefield clearModifier coordinate is out of bounds".to_string())?;
        let removed = cell.remove_modifier(name);
        if removed {
            self.mark_dirty_cell(coord);
        }
        Ok(removed)
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
        cell.set_light(source, light)?;
        self.mark_dirty_cell(coord);
        Ok(())
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
        self.define_slot(slot.clone())?;
        let cell = self
            .cell_mut(coord)
            .ok_or_else(|| "tilefield setRef coordinate is out of bounds".to_string())?;
        cell.set_ref(slot, value)?;
        self.mark_dirty_cell(coord);
        Ok(())
    }

    /// Return a named object/tile reference for one cell.
    pub fn get_ref(&self, coord: CellCoord, slot: &str) -> Option<u32> {
        self.cell(coord).and_then(|cell| cell.get_ref(slot))
    }

    /// Set a typed object/tile reference on one cell.
    pub fn set_typed_ref(
        &mut self,
        coord: CellCoord,
        slot: String,
        value: TileRef,
    ) -> Result<(), String> {
        self.define_slot(slot.clone())?;
        let cell = self
            .cell_mut(coord)
            .ok_or_else(|| "tilefield setRef coordinate is out of bounds".to_string())?;
        cell.set_typed_ref(slot, value)?;
        self.mark_dirty_cell(coord);
        Ok(())
    }

    /// Return a typed object/tile reference for one cell.
    pub fn get_typed_ref(&self, coord: CellCoord, slot: &str) -> Option<&TileRef> {
        self.cell(coord).and_then(|cell| cell.get_typed_ref(slot))
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
            self.bump_version();
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
        self.mark_dirty_cell(coord);
        Ok(())
    }

    /// Return true when a footprint anchored at `anchor` is passable for a category.
    pub fn footprint_passable(
        &self,
        anchor: CellCoord,
        width: u32,
        height: u32,
        category: &str,
    ) -> bool {
        let width = width.max(1);
        let height = height.max(1);
        let Some(x_end) = anchor.x.checked_add(width) else {
            return false;
        };
        let Some(y_end) = anchor.y.checked_add(height) else {
            return false;
        };
        if anchor.z >= self.levels || x_end > self.width || y_end > self.height {
            return false;
        }
        for y in anchor.y..y_end {
            for x in anchor.x..x_end {
                if self.blocks_category(CellCoord { x, y, z: anchor.z }, category) {
                    return false;
                }
            }
        }
        true
    }

    /// Return true when no cell blocks the category between two cells.
    pub fn clear_line_category(
        &self,
        from: CellCoord,
        to: CellCoord,
        category: &str,
    ) -> Result<bool, String> {
        let cells = self.line(from, to, true)?;
        for coord in cells.into_iter().skip(1) {
            if self.blocks_category(coord, category) {
                return Ok(false);
            }
        }
        Ok(true)
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

    /// Return topology-aware radial range distance.
    pub fn range_distance(&self, a: CellCoord, b: CellCoord) -> f32 {
        if a.z != b.z {
            a.z.abs_diff(b.z) as f32
                + self
                    .topology
                    .range_distance(CellCoord { z: 0, ..a }, CellCoord { z: 0, ..b })
        } else {
            self.topology.range_distance(a, b)
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
