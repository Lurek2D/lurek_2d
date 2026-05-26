//! Output converter: transforms an assembled map block grid into a `TileMap`.
//!
//! - `grid_to_tilemap(grid, tileset_id)` produces a `TileMap` ready for the renderer.
//! - Slot roles (floor/wall/object) are translated to `TileMap` layer indices.
//! - Block-local tile IDs are offset by the tileset base ID to produce world tile IDs.
//! - The returned `TileMap` is owned by the caller; no reference to the block grid is kept.

use super::config::MapBlockConfig;
use super::group::MapGroup;
use super::multilevel::MultiLevelMap;
use super::orientation::MapOrientation;
use super::placement::PlacementGrid;
use std::collections::HashMap;

/// Result of map block generation — contains all placed tiles ready for rendering.
#[derive(Debug, Clone)]
pub struct MapBlockResult {
    /// Total width in tiles.
    pub width: u32,
    /// Total height in tiles.
    pub height: u32,
    /// Number of levels.
    pub level_count: u32,
    /// Number of layers per block.
    pub layer_count: u32,
    /// Slot count per tile.
    pub slot_count: usize,
    /// Tile data: `[level][layer][y * width + x][slot] = (tileset_id, gid)`.
    pub tiles: Vec<Vec<Vec<Vec<(u32, u32)>>>>,
    /// Orientation used.
    pub orientation: MapOrientation,
    /// Tile pixel width.
    pub tile_pixel_w: u32,
    /// Tile pixel height.
    pub tile_pixel_h: u32,
    /// Number of blocks successfully placed.
    pub blocks_placed: u32,
}

impl MapBlockResult {
    /// Build the result from placement data.
    pub fn new(
        grid: &PlacementGrid,
        levels: &MultiLevelMap,
        groups: &HashMap<String, MapGroup>,
        config: &MapBlockConfig,
        orientation: MapOrientation,
        tile_pixel_w: u32,
        tile_pixel_h: u32,
    ) -> Self {
        let bounds = grid.bounds().unwrap_or((0, 0, 0, 0));
        let (min_x, min_y, max_x, max_y) = bounds;
        // Calculate output dimensions based on bounds and block sizes
        // For now, assume each grid cell = segment_size tiles
        let segment_size = config.default_segment_size;
        let grid_w = (max_x - min_x + 1) as u32;
        let grid_h = (max_y - min_y + 1) as u32;
        let width = grid_w * segment_size;
        let height = grid_h * segment_size;
        let level_count = levels.level_count();
        let slot_count = config.slot_count();

        // Find max layer count across all blocks
        let mut max_layers = 1u32;
        for group in groups.values() {
            for block in group.blocks() {
                max_layers = max_layers.max(block.get_layer_count());
            }
        }

        // Initialize tile data
        let empty_tile = vec![(0u32, 0u32); slot_count];
        let tiles: Vec<Vec<Vec<Vec<(u32, u32)>>>> = (0..level_count)
            .map(|_| {
                (0..max_layers)
                    .map(|_| {
                        vec![empty_tile.clone(); (width * height) as usize]
                    })
                    .collect()
            })
            .collect();

        let mut result = Self {
            width,
            height,
            level_count,
            layer_count: max_layers,
            slot_count,
            tiles,
            orientation,
            tile_pixel_w,
            tile_pixel_h,
            blocks_placed: grid.placed_count() as u32,
        };

        // Copy tiles from placed blocks into the result
        for level_idx in 0..level_count {
            for placed in levels.blocks_on_level(level_idx) {
                // Find the group and block
                let block = groups
                    .values()
                    .flat_map(|g| g.blocks().get(placed.block_index))
                    .next();

                if let Some(block) = block {
                    let offset_x = ((placed.grid_x - min_x) as u32) * segment_size;
                    let offset_y = ((placed.grid_y - min_y) as u32) * segment_size;

                    for layer_idx in 0..block.get_layer_count() as usize {
                        if let Some(layer) = block.get_layer(layer_idx) {
                            for ty in 0..layer.height().min(segment_size) {
                                for tx in 0..layer.width().min(segment_size) {
                                    let out_x = offset_x + tx;
                                    let out_y = offset_y + ty;
                                    if out_x < width && out_y < height {
                                        let idx = (out_y * width + out_x) as usize;
                                        if let Some(tile) = layer.get_tile(tx, ty) {
                                            for (slot_idx, slot) in
                                                tile.slots.iter().enumerate()
                                            {
                                                if !slot.is_empty() {
                                                    result.tiles[level_idx as usize]
                                                        [layer_idx][idx][slot_idx] =
                                                        (slot.tileset_id, slot.gid);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        result
    }

    /// Get a tile slot value at (level, layer, x, y, slot).
    pub fn get_tile(&self, level: u32, layer: u32, x: u32, y: u32, slot: usize) -> (u32, u32) {
        if level < self.level_count
            && (layer as usize) < self.tiles.get(level as usize).map(|l| l.len()).unwrap_or(0)
            && x < self.width
            && y < self.height
            && slot < self.slot_count
        {
            let idx = (y * self.width + x) as usize;
            self.tiles[level as usize][layer as usize][idx][slot]
        } else {
            (0, 0)
        }
    }

    /// Get just the GID (ignoring tileset) at (level, layer, x, y, slot).
    pub fn get_gid(&self, level: u32, layer: u32, x: u32, y: u32, slot: usize) -> u32 {
        self.get_tile(level, layer, x, y, slot).1
    }

    /// Check if the result is empty (no blocks placed).
    pub fn is_empty(&self) -> bool {
        self.blocks_placed == 0
    }
}
