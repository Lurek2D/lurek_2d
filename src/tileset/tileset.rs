//! This file owns tileset behavior inside the tileset subsystem, close to its data and invariants.
//! It keeps validation, defaults, and error-facing rules near the operations that mutate tileset state.
//! Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.
//! Public functions in this file are the stable entry points other modules should use for tileset work.
//! Serialization, indexing, and boundary checks stay here when they depend on tileset internals.
//! Renderer, API, and test layers should call through these helpers rather than duplicate private rules.

use crate::log_msg;
use crate::math::Rect;
use crate::runtime::log_messages::{TS01, TS02};
use crate::tileset::animation::TileAnimFrame;
use crate::tileset::archetype::TileObjectArchetype;
use crate::tileset::autotile::AutoTileMode;
use std::collections::HashMap;

/// A tileset slice of a sprite-sheet texture plus reusable object archetypes.
#[derive(Debug, Clone)]
pub struct TileSet {
    first_gid: u32,
    tile_count: u32,
    columns: u32,
    tile_width: u32,
    tile_height: u32,
    spacing: u32,
    margin: u32,
    archetypes: HashMap<String, TileObjectArchetype>,
    tile_archetypes: HashMap<u32, String>,
    properties: HashMap<u32, HashMap<String, String>>,
    animations: HashMap<u32, Vec<TileAnimFrame>>,
    auto_rules_4: HashMap<(String, u8), u32>,
    auto_rules_8: HashMap<(String, u16), u32>,
    auto_modes: HashMap<String, AutoTileMode>,
}

impl TileSet {
    /// Create a `TileSet` with atlas layout and empty archetype/animation/autotile tables.
    pub fn new(
        first_gid: u32,
        tile_count: u32,
        columns: u32,
        tile_width: u32,
        tile_height: u32,
        spacing: u32,
        margin: u32,
    ) -> Self {
        log_msg!(debug, TS01, "first_gid={} tiles={}", first_gid, tile_count);
        Self {
            first_gid,
            tile_count,
            columns,
            tile_width,
            tile_height,
            spacing,
            margin,
            archetypes: HashMap::new(),
            tile_archetypes: HashMap::new(),
            properties: HashMap::new(),
            animations: HashMap::new(),
            auto_rules_4: HashMap::new(),
            auto_rules_8: HashMap::new(),
            auto_modes: HashMap::new(),
        }
    }

    /// Return the first global tile ID owned by this tileset.
    pub fn get_first_gid(&self) -> u32 {
        self.first_gid
    }
    /// Return the total tile count.
    pub fn get_tile_count(&self) -> u32 {
        self.tile_count
    }
    /// Return the number of tile columns in the source image.
    pub fn get_columns(&self) -> u32 {
        self.columns
    }
    /// Return tile width in pixels.
    pub fn get_tile_width(&self) -> u32 {
        self.tile_width
    }
    /// Return tile height in pixels.
    pub fn get_tile_height(&self) -> u32 {
        self.tile_height
    }
    /// Return tile dimensions as `(width, height)` in pixels.
    pub fn get_tile_dimensions(&self) -> (u32, u32) {
        (self.tile_width, self.tile_height)
    }
    /// Return pixel spacing between tiles in the source image.
    pub fn get_spacing(&self) -> u32 {
        self.spacing
    }
    /// Return pixel margin around the source image edge.
    pub fn get_margin(&self) -> u32 {
        self.margin
    }
    /// Return inferred atlas texture width in pixels.
    pub fn get_texture_width(&self) -> u32 {
        self.margin
            .saturating_mul(2)
            .saturating_add(
                self.columns
                    .max(1)
                    .saturating_mul(self.tile_width + self.spacing),
            )
            .saturating_sub(self.spacing)
    }
    /// Return inferred atlas texture height in pixels.
    pub fn get_texture_height(&self) -> u32 {
        let columns = self.columns.max(1);
        let rows = self.tile_count.saturating_add(columns - 1) / columns;
        self.margin
            .saturating_mul(2)
            .saturating_add(rows.max(1).saturating_mul(self.tile_height + self.spacing))
            .saturating_sub(self.spacing)
    }

    /// Return the source-image `Rect` in pixels for `local_tile_id`.
    pub fn get_quad(&self, local_tile_id: u32) -> Rect {
        let columns = self.columns.max(1);
        let col = local_tile_id % columns;
        let row = local_tile_id / columns;
        let x = self.margin + col * (self.tile_width + self.spacing);
        let y = self.margin + row * (self.tile_height + self.spacing);
        Rect::new(
            x as f32,
            y as f32,
            self.tile_width as f32,
            self.tile_height as f32,
        )
    }

    /// Register or replace an object archetype.
    pub fn set_archetype(&mut self, archetype: TileObjectArchetype) {
        self.archetypes.insert(archetype.name.clone(), archetype);
    }

    /// Return an object archetype by name.
    pub fn archetype(&self, name: &str) -> Option<&TileObjectArchetype> {
        self.archetypes.get(name)
    }

    /// Remove an object archetype and detach tile mappings that referenced it.
    pub fn remove_archetype(&mut self, name: &str) -> bool {
        let removed = self.archetypes.remove(name).is_some();
        if removed {
            self.tile_archetypes
                .retain(|_, archetype_name| archetype_name != name);
        }
        removed
    }

    /// Return archetype names in stable sorted order.
    pub fn archetype_names(&self) -> Vec<String> {
        let mut names: Vec<_> = self.archetypes.keys().cloned().collect();
        names.sort();
        names
    }

    /// Assign or clear the object archetype used by a local tile ID.
    pub fn set_tile_archetype(
        &mut self,
        local_tile_id: u32,
        archetype: Option<String>,
    ) -> Result<(), String> {
        if local_tile_id >= self.tile_count {
            return Err("tileset local tile id is out of bounds".to_string());
        }
        match archetype {
            Some(name) if !name.trim().is_empty() => {
                if !self.archetypes.contains_key(&name) {
                    return Err(format!("tileset object archetype '{name}' does not exist"));
                }
                self.tile_archetypes.insert(local_tile_id, name);
            }
            _ => {
                self.tile_archetypes.remove(&local_tile_id);
            }
        }
        Ok(())
    }

    /// Return the object archetype name assigned to a local tile ID.
    pub fn get_tile_archetype(&self, local_tile_id: u32) -> Option<&str> {
        self.tile_archetypes.get(&local_tile_id).map(String::as_str)
    }

    /// Return the object archetype assigned to a local tile ID.
    pub fn archetype_for_tile(&self, local_tile_id: u32) -> Option<&TileObjectArchetype> {
        self.get_tile_archetype(local_tile_id)
            .and_then(|name| self.archetype(name))
    }

    /// Register or replace the animation frame sequence for `local_tile_id`.
    pub fn set_animation(&mut self, local_tile_id: u32, frames: Vec<TileAnimFrame>) {
        log_msg!(
            debug,
            TS02,
            "tile={} frames={}",
            local_tile_id,
            frames.len()
        );
        self.animations.insert(local_tile_id, frames);
    }

    /// Return the animation frames for `local_tile_id`, or `None` when not animated.
    pub fn get_animation(&self, local_tile_id: u32) -> Option<&Vec<TileAnimFrame>> {
        self.animations.get(&local_tile_id)
    }

    /// Iterate over local tile IDs that own animation sequences.
    pub fn iter_animated_local_ids(&self) -> impl Iterator<Item = u32> + '_ {
        self.animations.keys().copied()
    }

    /// Set, replace, or clear an arbitrary author property for `local_tile_id`.
    pub fn set_property(
        &mut self,
        local_tile_id: u32,
        name: String,
        value: Option<String>,
    ) -> Result<(), String> {
        if name.trim().is_empty() {
            return Err("tileset property name must not be empty".to_string());
        }
        match value {
            Some(value) => {
                self.properties
                    .entry(local_tile_id)
                    .or_default()
                    .insert(name, value);
            }
            None => {
                if let Some(properties) = self.properties.get_mut(&local_tile_id) {
                    properties.remove(&name);
                    if properties.is_empty() {
                        self.properties.remove(&local_tile_id);
                    }
                }
            }
        }
        Ok(())
    }

    /// Return an arbitrary author property for `local_tile_id`, or `None` when unset.
    pub fn get_property(&self, local_tile_id: u32, name: &str) -> Option<&str> {
        self.properties
            .get(&local_tile_id)
            .and_then(|p| p.get(name))
            .map(String::as_str)
    }

    /// Return arbitrary author properties for `local_tile_id`.
    pub fn properties(&self, local_tile_id: u32) -> Option<&HashMap<String, String>> {
        self.properties.get(&local_tile_id)
    }

    /// Register a 4-bit autotile rule mapping `(type_name, bitmask)` to `local_tile_id`.
    pub fn set_auto_tile_rule(&mut self, type_name: &str, bitmask: u8, local_tile_id: u32) {
        self.auto_rules_4
            .insert((type_name.to_string(), bitmask), local_tile_id);
    }
    /// Look up the 4-bit autotile local ID for `(type_name, bitmask)`, or `None`.
    pub fn get_auto_tile_id(&self, type_name: &str, bitmask: u8) -> Option<u32> {
        self.auto_rules_4
            .get(&(type_name.to_string(), bitmask))
            .copied()
    }
    /// Register an 8-bit autotile rule mapping `(type_name, bitmask)` to `local_tile_id`.
    pub fn set_auto_tile_rule_8(&mut self, type_name: &str, bitmask: u16, local_tile_id: u32) {
        self.auto_rules_8
            .insert((type_name.to_string(), bitmask), local_tile_id);
    }
    /// Look up the 8-bit autotile local ID for `(type_name, bitmask)`, or `None`.
    pub fn get_auto_tile_id_8(&self, type_name: &str, bitmask: u16) -> Option<u32> {
        self.auto_rules_8
            .get(&(type_name.to_string(), bitmask))
            .copied()
    }
    /// Set the neighbour matching strategy for a logical autotile type.
    pub fn set_auto_tile_mode(&mut self, type_name: &str, mode: AutoTileMode) {
        self.auto_modes.insert(type_name.to_string(), mode);
    }
    /// Return the neighbour matching strategy for a logical autotile type.
    pub fn get_auto_tile_mode(&self, type_name: &str) -> AutoTileMode {
        self.auto_modes
            .get(type_name)
            .copied()
            .unwrap_or(AutoTileMode::MatchSides)
    }
    /// Return true if this tileset has an explicit matching strategy for the logical autotile type.
    pub fn has_auto_tile_mode(&self, type_name: &str) -> bool {
        self.auto_modes.contains_key(type_name)
    }
}
