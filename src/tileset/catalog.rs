//! Owns lookup across many named tilesets.
//! Catalog state is reusable definition data only; placed refs remain owned by tilefield.

use crate::tilefield::{TileObjectCatalog, TileRef};
use crate::tileset::{TileObjectArchetype, TileSet, TileVisual};
use std::collections::HashMap;

/// Many-tileset resolver keyed by stable Lua-authored tileset id.
#[derive(Debug, Clone, Default)]
pub struct TileCatalog {
    tilesets: HashMap<String, TileSet>,
}

impl TileCatalog {
    /// Create an empty catalog.
    pub fn new() -> Self {
        Self::default()
    }

    /// Insert or replace one named tileset.
    pub fn set_tileset(&mut self, id: String, tileset: TileSet) -> Result<(), String> {
        let id = id.trim();
        if id.is_empty() {
            return Err("tileset catalog id must not be empty".to_string());
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
