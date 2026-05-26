//! Z-layer management for multi-storey and multi-level map construction.
//!
//! - `LayerStack` holds a `Vec<MapBlockGrid>`, one per Z level starting from 0.
//! - Layers are independent grids; block placement in one layer does not affect another.
//! - Layer 0 is the ground floor; negative indices are not supported.
//! - The `MapBlockConfig::layer_count` field pre-allocates the stack at generator init.

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
    pub fn set_tile_slot(
        &mut self,
        x: u32,
        y: u32,
        slot_index: usize,
        tileset_id: u32,
        gid: u32,
    ) {
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
