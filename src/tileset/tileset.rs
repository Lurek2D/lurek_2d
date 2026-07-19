//! Owns validated atlas geometry and atlas-local metadata registries.
//!
//! `TileSet` stores local tile ids, object mappings, properties, animations, and
//! autotile metadata. It never owns map cells, GPU resources, or runtime gameplay
//! state. All Lua-created instances enter through `try_new` so checked dimensions,
//! global-id ranges, and tileset-specific ceilings are enforced before registration.

use crate::log_msg;
use crate::math::Rect;
use crate::runtime::log_messages::{TS01, TS02};
use crate::tileset::animation::TileAnimFrame;
use crate::tileset::archetype::TileObjectArchetype;
use crate::tileset::autotile::{AutoTileMode, TerrainProfile};
use crate::tileset::error::TilesetError;
use crate::tileset::limits::TilesetLimits;
use std::collections::HashMap;

/// A tileset slice of a sprite-sheet texture plus reusable object archetypes.
///
/// # Fields
///
/// Atlas geometry is immutable after construction. The remaining registries hold
/// local properties, animations, object mappings, autotile rules, and terrain metadata.
#[derive(Debug, Clone)]
pub struct TileSet {
    first_gid: u32,
    tile_count: u32,
    columns: u32,
    tile_width: u32,
    tile_height: u32,
    spacing: u32,
    margin: u32,
    texture_width: u32,
    texture_height: u32,
    limits: TilesetLimits,
    archetypes: HashMap<String, TileObjectArchetype>,
    tile_archetypes: HashMap<u32, String>,
    properties: HashMap<u32, HashMap<String, String>>,
    property_count: usize,
    animations: HashMap<u32, Vec<TileAnimFrame>>,
    auto_rules_4: HashMap<String, HashMap<u8, u32>>,
    auto_rules_8: HashMap<String, HashMap<u16, u32>>,
    auto_rule_count_4: usize,
    auto_rule_count_8: usize,
    auto_modes: HashMap<String, AutoTileMode>,
    terrain_profiles: HashMap<String, TerrainProfile>,
}

impl TileSet {
    /// Create a validated `TileSet` using the default tileset limits.
    pub fn try_new(
        first_gid: u32,
        tile_count: u32,
        columns: u32,
        tile_width: u32,
        tile_height: u32,
        spacing: u32,
        margin: u32,
    ) -> Result<Self, TilesetError> {
        Self::try_new_with_limits(
            first_gid,
            tile_count,
            columns,
            tile_width,
            tile_height,
            spacing,
            margin,
            TilesetLimits::default(),
        )
    }

    /// Create a validated `TileSet` with explicit limits for importers and tests.
    // Keep the scalar constructor aligned with the legacy public API; callers
    // that need a different shape can use the checked constructor defaults.
    #[allow(clippy::too_many_arguments)]
    /// Construct a tileset using explicit validation ceilings.
    pub fn try_new_with_limits(
        first_gid: u32,
        tile_count: u32,
        columns: u32,
        tile_width: u32,
        tile_height: u32,
        spacing: u32,
        margin: u32,
        limits: TilesetLimits,
    ) -> Result<Self, TilesetError> {
        for (field, value) in [
            ("tile_count", tile_count),
            ("columns", columns),
            ("tile_width", tile_width),
            ("tile_height", tile_height),
        ] {
            if value == 0 {
                return Err(TilesetError::invalid(field, "must be greater than zero"));
            }
        }
        if tile_count > limits.max_tile_count {
            return Err(TilesetError::LimitExceeded {
                resource: "tile_count",
                requested: u64::from(tile_count),
                maximum: u64::from(limits.max_tile_count),
            });
        }
        if columns > limits.max_columns {
            return Err(TilesetError::LimitExceeded {
                resource: "columns",
                requested: u64::from(columns),
                maximum: u64::from(limits.max_columns),
            });
        }
        if spacing > limits.max_spacing {
            return Err(TilesetError::LimitExceeded {
                resource: "spacing",
                requested: u64::from(spacing),
                maximum: u64::from(limits.max_spacing),
            });
        }
        if margin > limits.max_margin {
            return Err(TilesetError::LimitExceeded {
                resource: "margin",
                requested: u64::from(margin),
                maximum: u64::from(limits.max_margin),
            });
        }
        let last_gid =
            first_gid
                .checked_add(tile_count - 1)
                .ok_or(TilesetError::GidRangeOverflow {
                    first_gid,
                    tile_count,
                })?;
        let _ = last_gid;
        let rows = (tile_count - 1) / columns + 1;
        let horizontal_tiles = u64::from(columns)
            .checked_mul(u64::from(tile_width))
            .and_then(|value| {
                value.checked_add(u64::from(columns - 1).saturating_mul(u64::from(spacing)))
            })
            .ok_or(TilesetError::ArithmeticOverflow {
                field: "atlas width",
            })?;
        let vertical_tiles = u64::from(rows)
            .checked_mul(u64::from(tile_height))
            .and_then(|value| {
                value.checked_add(u64::from(rows - 1).saturating_mul(u64::from(spacing)))
            })
            .ok_or(TilesetError::ArithmeticOverflow {
                field: "atlas height",
            })?;
        let texture_width = horizontal_tiles
            .checked_add(u64::from(margin).checked_mul(2).ok_or(
                TilesetError::ArithmeticOverflow {
                    field: "atlas width margin",
                },
            )?)
            .ok_or(TilesetError::ArithmeticOverflow {
                field: "atlas width margin",
            })?;
        let texture_height = vertical_tiles
            .checked_add(u64::from(margin).checked_mul(2).ok_or(
                TilesetError::ArithmeticOverflow {
                    field: "atlas height margin",
                },
            )?)
            .ok_or(TilesetError::ArithmeticOverflow {
                field: "atlas height margin",
            })?;
        for (resource, value) in [
            ("atlas width", texture_width),
            ("atlas height", texture_height),
        ] {
            if value > u64::from(limits.max_atlas_dimension) {
                return Err(TilesetError::LimitExceeded {
                    resource,
                    requested: value,
                    maximum: u64::from(limits.max_atlas_dimension),
                });
            }
        }
        let texture_width =
            u32::try_from(texture_width).map_err(|_| TilesetError::ArithmeticOverflow {
                field: "atlas width u32 conversion",
            })?;
        let texture_height =
            u32::try_from(texture_height).map_err(|_| TilesetError::ArithmeticOverflow {
                field: "atlas height u32 conversion",
            })?;
        log_msg!(debug, TS01, "first_gid={} tiles={}", first_gid, tile_count);
        Ok(Self {
            first_gid,
            tile_count,
            columns,
            tile_width,
            tile_height,
            spacing,
            margin,
            texture_width,
            texture_height,
            limits,
            archetypes: HashMap::new(),
            tile_archetypes: HashMap::new(),
            properties: HashMap::new(),
            property_count: 0,
            animations: HashMap::new(),
            auto_rules_4: HashMap::new(),
            auto_rules_8: HashMap::new(),
            auto_rule_count_4: 0,
            auto_rule_count_8: 0,
            auto_modes: HashMap::new(),
            terrain_profiles: HashMap::new(),
        })
    }

    /// Legacy infallible constructor retained for internal callers with known-valid data.
    ///
    /// Lua and provider boundaries use [`Self::try_new`]. Invalid direct Rust inputs are
    /// normalized to a safe one-tile atlas instead of reaching unchecked arithmetic.
    pub fn new(
        first_gid: u32,
        tile_count: u32,
        columns: u32,
        tile_width: u32,
        tile_height: u32,
        spacing: u32,
        margin: u32,
    ) -> Self {
        match Self::try_new(
            first_gid,
            tile_count,
            columns,
            tile_width,
            tile_height,
            spacing,
            margin,
        ) {
            Ok(tileset) => tileset,
            Err(_) => Self::try_new(1, 1, 1, 1, 1, 0, 0)
                .expect("the fixed safe legacy tileset must always validate"),
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
        self.texture_width
    }
    /// Return inferred atlas texture height in pixels.
    pub fn get_texture_height(&self) -> u32 {
        self.texture_height
    }

    /// Store a Godot-style terrain-set profile by name.
    pub fn set_terrain_profile(
        &mut self,
        name: &str,
        profile: TerrainProfile,
    ) -> Result<(), TilesetError> {
        validate_name(name, "terrain profile", &self.limits)?;
        profile.validate(&self.limits)?;
        if let Some(default_tile_id) = profile.default_tile_id {
            self.ensure_tile_id(default_tile_id)?;
        }
        if !self.terrain_profiles.contains_key(name)
            && self.terrain_profiles.len() >= self.limits.max_terrain_profiles
        {
            return Err(TilesetError::LimitExceeded {
                resource: "terrain profiles",
                requested: (self.terrain_profiles.len() + 1) as u64,
                maximum: self.limits.max_terrain_profiles as u64,
            });
        }
        self.terrain_profiles.insert(name.to_string(), profile);
        Ok(())
    }

    /// Return a terrain-set profile by name.
    pub fn get_terrain_profile(&self, name: &str) -> Option<&TerrainProfile> {
        self.terrain_profiles.get(name)
    }

    /// Return the source-image `Rect` in pixels for `local_tile_id`.
    pub fn try_get_quad(&self, local_tile_id: u32) -> Result<Rect, TilesetError> {
        self.ensure_tile_id(local_tile_id)?;
        let col = local_tile_id % self.columns;
        let row = local_tile_id / self.columns;
        let x = u64::from(self.margin)
            .checked_add(
                u64::from(col)
                    .checked_mul(u64::from(self.tile_width) + u64::from(self.spacing))
                    .ok_or(TilesetError::ArithmeticOverflow { field: "quad x" })?,
            )
            .ok_or(TilesetError::ArithmeticOverflow { field: "quad x" })?;
        let y = u64::from(self.margin)
            .checked_add(
                u64::from(row)
                    .checked_mul(u64::from(self.tile_height) + u64::from(self.spacing))
                    .ok_or(TilesetError::ArithmeticOverflow { field: "quad y" })?,
            )
            .ok_or(TilesetError::ArithmeticOverflow { field: "quad y" })?;
        Ok(Rect::new(
            x as f32,
            y as f32,
            self.tile_width as f32,
            self.tile_height as f32,
        ))
    }

    /// Return the source quad for legacy render callers, using an empty rectangle on invalid ids.
    pub fn get_quad(&self, local_tile_id: u32) -> Rect {
        self.try_get_quad(local_tile_id)
            .unwrap_or_else(|_| Rect::new(0.0, 0.0, 0.0, 0.0))
    }

    /// Register or replace an object archetype after validating all author defaults.
    pub fn set_archetype(&mut self, archetype: TileObjectArchetype) -> Result<(), TilesetError> {
        archetype.validate(&self.limits)?;
        if !self.archetypes.contains_key(&archetype.name)
            && self.archetypes.len() >= self.limits.max_archetypes
        {
            return Err(TilesetError::LimitExceeded {
                resource: "archetypes",
                requested: (self.archetypes.len() + 1) as u64,
                maximum: self.limits.max_archetypes as u64,
            });
        }
        self.archetypes.insert(archetype.name.clone(), archetype);
        Ok(())
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
    ) -> Result<(), TilesetError> {
        self.ensure_tile_id(local_tile_id)?;
        match archetype {
            Some(name) if !name.trim().is_empty() => {
                validate_name(&name, "tile archetype", &self.limits)?;
                if !self.archetypes.contains_key(&name) {
                    return Err(TilesetError::invalid(
                        "tile archetype",
                        format!("object archetype '{name}' does not exist"),
                    ));
                }
                self.tile_archetypes.insert(local_tile_id, name);
            }
            Some(_) => return Err(TilesetError::invalid("tile archetype", "must not be empty")),
            None => {
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
    pub fn set_animation(
        &mut self,
        local_tile_id: u32,
        frames: Vec<TileAnimFrame>,
    ) -> Result<(), TilesetError> {
        self.ensure_tile_id(local_tile_id)?;
        if frames.len() > self.limits.max_animation_frames {
            return Err(TilesetError::LimitExceeded {
                resource: "animation frames",
                requested: frames.len() as u64,
                maximum: self.limits.max_animation_frames as u64,
            });
        }
        for frame in &frames {
            self.ensure_tile_id(frame.tile_id)?;
            if !frame.duration_ms.is_finite() || frame.duration_ms <= 0.0 {
                return Err(TilesetError::invalid(
                    "animation duration_ms",
                    "must be finite and greater than zero",
                ));
            }
        }
        if !self.animations.contains_key(&local_tile_id)
            && self.animations.len() >= self.limits.max_animation_sequences
        {
            return Err(TilesetError::LimitExceeded {
                resource: "animation sequences",
                requested: (self.animations.len() + 1) as u64,
                maximum: self.limits.max_animation_sequences as u64,
            });
        }
        log_msg!(
            debug,
            TS02,
            "tile={} frames={}",
            local_tile_id,
            frames.len()
        );
        self.animations.insert(local_tile_id, frames);
        Ok(())
    }

    /// Return the animation frames for `local_tile_id`, or `None` when not animated.
    pub fn get_animation(&self, local_tile_id: u32) -> Option<&[TileAnimFrame]> {
        self.animations.get(&local_tile_id).map(Vec::as_slice)
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
    ) -> Result<(), TilesetError> {
        self.ensure_tile_id(local_tile_id)?;
        if name.trim().is_empty() {
            return Err(TilesetError::invalid("property name", "must not be empty"));
        }
        if name.len() > self.limits.max_name_bytes {
            return Err(TilesetError::LimitExceeded {
                resource: "property name bytes",
                requested: name.len() as u64,
                maximum: self.limits.max_name_bytes as u64,
            });
        }
        match value {
            Some(value) => {
                if value.len() > self.limits.max_string_bytes {
                    return Err(TilesetError::LimitExceeded {
                        resource: "property value bytes",
                        requested: value.len() as u64,
                        maximum: self.limits.max_string_bytes as u64,
                    });
                }
                let is_new = self
                    .properties
                    .get(&local_tile_id)
                    .map(|properties| !properties.contains_key(&name))
                    .unwrap_or(true);
                let owner_property_count = self
                    .properties
                    .get(&local_tile_id)
                    .map(HashMap::len)
                    .unwrap_or(0);
                if is_new && owner_property_count >= self.limits.max_properties_per_owner {
                    return Err(TilesetError::LimitExceeded {
                        resource: "properties per tile",
                        requested: (owner_property_count + 1) as u64,
                        maximum: self.limits.max_properties_per_owner as u64,
                    });
                }
                if is_new && self.property_count >= self.limits.max_total_properties {
                    return Err(TilesetError::LimitExceeded {
                        resource: "total properties",
                        requested: (self.property_count + 1) as u64,
                        maximum: self.limits.max_total_properties as u64,
                    });
                }
                if is_new {
                    self.property_count += 1;
                }
                self.properties
                    .entry(local_tile_id)
                    .or_default()
                    .insert(name, value);
            }
            None => {
                if let Some(properties) = self.properties.get_mut(&local_tile_id) {
                    if properties.remove(&name).is_some() {
                        self.property_count = self.property_count.saturating_sub(1);
                    }
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
    pub fn set_auto_tile_rule(
        &mut self,
        type_name: &str,
        bitmask: u8,
        local_tile_id: u32,
    ) -> Result<(), TilesetError> {
        self.ensure_tile_id(local_tile_id)?;
        validate_name(type_name, "autotile type", &self.limits)?;
        let rules = self.auto_rules_4.entry(type_name.to_string()).or_default();
        if !rules.contains_key(&bitmask)
            && self.auto_rule_count_4 >= self.limits.max_autotile_rules_4
        {
            return Err(TilesetError::LimitExceeded {
                resource: "4-way autotile rules",
                requested: (self.auto_rule_count_4 + 1) as u64,
                maximum: self.limits.max_autotile_rules_4 as u64,
            });
        }
        if rules.insert(bitmask, local_tile_id).is_none() {
            self.auto_rule_count_4 += 1;
        }
        Ok(())
    }
    /// Look up the 4-bit autotile local ID for `(type_name, bitmask)`, or `None`.
    pub fn get_auto_tile_id(&self, type_name: &str, bitmask: u8) -> Option<u32> {
        self.auto_rules_4
            .get(type_name)
            .and_then(|rules| rules.get(&bitmask))
            .copied()
    }
    /// Register an 8-bit autotile rule mapping `(type_name, bitmask)` to `local_tile_id`.
    pub fn set_auto_tile_rule_8(
        &mut self,
        type_name: &str,
        bitmask: u16,
        local_tile_id: u32,
    ) -> Result<(), TilesetError> {
        self.ensure_tile_id(local_tile_id)?;
        validate_name(type_name, "autotile type", &self.limits)?;
        let rules = self.auto_rules_8.entry(type_name.to_string()).or_default();
        if !rules.contains_key(&bitmask)
            && self.auto_rule_count_8 >= self.limits.max_autotile_rules_8
        {
            return Err(TilesetError::LimitExceeded {
                resource: "8-way autotile rules",
                requested: (self.auto_rule_count_8 + 1) as u64,
                maximum: self.limits.max_autotile_rules_8 as u64,
            });
        }
        if rules.insert(bitmask, local_tile_id).is_none() {
            self.auto_rule_count_8 += 1;
        }
        Ok(())
    }
    /// Look up the 8-bit autotile local ID for `(type_name, bitmask)`, or `None`.
    pub fn get_auto_tile_id_8(&self, type_name: &str, bitmask: u16) -> Option<u32> {
        self.auto_rules_8
            .get(type_name)
            .and_then(|rules| rules.get(&bitmask))
            .copied()
    }
    /// Set the neighbour matching strategy for a logical autotile type.
    pub fn set_auto_tile_mode(
        &mut self,
        type_name: &str,
        mode: AutoTileMode,
    ) -> Result<(), TilesetError> {
        validate_name(type_name, "autotile type", &self.limits)?;
        self.auto_modes.insert(type_name.to_string(), mode);
        Ok(())
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

    /// Return the limits used to validate this snapshot.
    pub fn limits(&self) -> TilesetLimits {
        self.limits
    }

    fn ensure_tile_id(&self, local_tile_id: u32) -> Result<(), TilesetError> {
        if local_tile_id >= self.tile_count {
            Err(TilesetError::TileIdOutOfBounds {
                local_tile_id,
                tile_count: self.tile_count,
            })
        } else {
            Ok(())
        }
    }
}

fn validate_name(name: &str, field: &str, limits: &TilesetLimits) -> Result<(), TilesetError> {
    if name.trim().is_empty() {
        return Err(TilesetError::invalid(field, "must not be empty"));
    }
    if name.len() > limits.max_name_bytes {
        return Err(TilesetError::LimitExceeded {
            resource: "name bytes",
            requested: name.len() as u64,
            maximum: limits.max_name_bytes as u64,
        });
    }
    Ok(())
}
