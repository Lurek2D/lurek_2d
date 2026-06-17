//! Per-level tile storage for multi-storey mapblock outputs. `mapblock/layer` delivers the layer implementation for the mapblock subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Manages independent 2D block layers indexed by non-negative vertical levels. The file owns or coordinates data contracts including `BlockLayer`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Provides bounds-aware tile access and mutation for placement operations. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `width`, `height`, `get_tile`, `get_tile_mut`, `set_tile_slot`, and 4 more stays attached to the local data model and invariants.
//! Keeps slot counts and layer dimensions aligned with global config. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

use super::maptile::MapTile;

/// A single layer within a map block — a 2D grid of map tiles.
#[derive(Debug, Clone)]
pub struct BlockLayer {
    /// Width in tiles.
    width: u32,
    /// Height in tiles.
    height: u32,
    /// Number of slots per tile (from config).
    slot_count: usize,
    /// Tile data stored row-major: `tiles[y * width + x]`.
    tiles: Vec<MapTile>,
}

impl BlockLayer {
    /// Create a new layer with given dimensions and slot count per tile.
    pub fn new(width: u32, height: u32, slot_count: usize) -> Self {
        let count = (width * height) as usize;
        let tiles = vec![MapTile::new(slot_count); count];
        Self {
            width,
            height,
            slot_count,
            tiles,
        }
    }

    /// Get the tile width of this layer.
    pub fn width(&self) -> u32 {
        self.width
    }

    /// Get the tile height of this layer.
    pub fn height(&self) -> u32 {
        self.height
    }

    /// Get a tile reference at (x, y).
    pub fn get_tile(&self, x: u32, y: u32) -> Option<&MapTile> {
        if x < self.width && y < self.height {
            Some(&self.tiles[(y * self.width + x) as usize])
        } else {
            None
        }
    }

    /// Get a mutable tile reference at (x, y).
    pub fn get_tile_mut(&mut self, x: u32, y: u32) -> Option<&mut MapTile> {
        if x < self.width && y < self.height {
            Some(&mut self.tiles[(y * self.width + x) as usize])
        } else {
            None
        }
    }

    /// Set a specific slot on a tile at (x, y).
    pub fn set_tile_slot(&mut self, x: u32, y: u32, slot_index: usize, tileset_id: u32, gid: u32) {
        if let Some(tile) = self.get_tile_mut(x, y) {
            tile.set_slot(slot_index, tileset_id, gid);
        }
    }

    /// Get the GID of a specific slot at (x, y).
    pub fn get_tile_gid(&self, x: u32, y: u32, slot_index: usize) -> u32 {
        self.get_tile(x, y)
            .and_then(|t| t.get_slot(slot_index))
            .map(|s| s.gid)
            .unwrap_or(0)
    }

    /// Fill entire layer with a single GID in a specific slot.
    pub fn fill(&mut self, slot_index: usize, tileset_id: u32, gid: u32) {
        for tile in &mut self.tiles {
            tile.set_slot(slot_index, tileset_id, gid);
        }
    }

    /// Clear all tiles in this layer.
    pub fn clear(&mut self) {
        for tile in &mut self.tiles {
            *tile = MapTile::new(self.slot_count);
        }
    }

    /// Return the number of slots per tile.
    pub fn slot_count(&self) -> usize {
        self.slot_count
    }
}
