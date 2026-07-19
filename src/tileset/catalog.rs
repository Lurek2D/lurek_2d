//! Owns snapshot catalogs that resolve typed tilefield references to tileset metadata.
//!
//! A catalog stores cloned `TileSet` values intentionally. A catalog lookup is a
//! stable snapshot; mutating the original Lua tileset after `newCatalog` does not
//! mutate the catalog entry. Shared live handles remain a separate future feature.

use crate::tilefield::{TileObjectCatalog, TileRef};
use crate::tileset::error::TilesetError;
use crate::tileset::limits::TilesetLimits;
use crate::tileset::{TileObjectArchetype, TileSet, TileVisual};
use std::collections::HashMap;

/// Many-tileset resolver keyed by stable Lua-authored tileset id.
///
/// # Fields
///
/// The catalog contains a bounded map of cloned tileset snapshots and the limits
/// used for catalog insertion.
#[derive(Debug, Clone, Default)]
pub struct TileCatalog {
    tilesets: HashMap<String, TileSet>,
    limits: TilesetLimits,
}

impl TileCatalog {
    /// Create an empty catalog.
    pub fn new() -> Self {
        Self {
            tilesets: HashMap::new(),
            limits: TilesetLimits::default(),
        }
    }

    /// Build a snapshot catalog transactionally from validated tileset entries.
    pub fn from_entries<I>(entries: I) -> Result<Self, TilesetError>
    where
        I: IntoIterator<Item = (String, TileSet)>,
    {
        let mut catalog = Self::new();
        for (id, tileset) in entries {
            catalog.set_tileset(id, tileset)?;
        }
        Ok(catalog)
    }

    /// Insert or replace one named tileset.
    pub fn set_tileset(&mut self, id: String, tileset: TileSet) -> Result<(), TilesetError> {
        let id = id.trim();
        if id.is_empty() {
            return Err(TilesetError::invalid(
                "tileset catalog id",
                "must not be empty",
            ));
        }
        if id.len() > self.limits.max_name_bytes {
            return Err(TilesetError::LimitExceeded {
                resource: "catalog id bytes",
                requested: id.len() as u64,
                maximum: self.limits.max_name_bytes as u64,
            });
        }
        if !self.tilesets.contains_key(id) && self.tilesets.len() >= self.limits.max_catalog_entries
        {
            return Err(TilesetError::LimitExceeded {
                resource: "catalog entries",
                requested: (self.tilesets.len() + 1) as u64,
                maximum: self.limits.max_catalog_entries as u64,
            });
        }
        self.tilesets.insert(id.to_string(), tileset);
        Ok(())
    }

    /// Return a tileset by stable catalog id.
    pub fn tileset(&self, id: &str) -> Option<&TileSet> {
        self.tilesets.get(id)
    }

    /// Return sorted catalog ids.
    pub fn ids(&self) -> Vec<String> {
        let mut ids: Vec<_> = self.tilesets.keys().cloned().collect();
        ids.sort();
        ids
    }

    /// Resolve visual metadata for a typed ref.
    pub fn visual_for_ref(&self, reference: &TileRef) -> Option<TileVisual> {
        let tileset = self.tileset(&reference.tileset_id)?;
        if let Some(object_id) = reference.object_id.as_deref() {
            return tileset
                .archetype(object_id)
                .and_then(|archetype| archetype.visual.clone());
        }
        reference.local_id.and_then(|local_id| {
            tileset
                .archetype_for_tile(local_id)
                .and_then(|archetype| archetype.visual.clone())
                .or_else(|| {
                    Some(TileVisual {
                        tile_id: Some(local_id),
                        ..Default::default()
                    })
                })
        })
    }
}

impl TileObjectCatalog for TileCatalog {
    type Object = TileObjectArchetype;

    fn object_for_ref(&self, reference: &TileRef) -> Option<&Self::Object> {
        let tileset = self.tileset(&reference.tileset_id)?;
        if let Some(object_id) = reference.object_id.as_deref() {
            return tileset.archetype(object_id);
        }
        reference
            .local_id
            .and_then(|local_id| tileset.archetype_for_tile(local_id))
    }
}
