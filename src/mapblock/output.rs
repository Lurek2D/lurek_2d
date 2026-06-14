//! Final mapblock conversion layer that turns placements into tile data outputs.
//! Translates layered slot payloads into ordered tile layers and resolved tileset ids.
//! Applies orientation and level handling so exports match runtime presentation.
//! Produces owned result structures detached from mutable generator state.
//! Serves as the last step in the mapblock build pipeline.

use super::config::MapBlockConfig;
use super::group::MapGroup;
use super::multilevel::MultiLevelMap;
use super::orientation::MapOrientation;
use super::placement::PlacementGrid;
use std::collections::HashMap;

/// Alias for 4-level tile data: `[level][layer][tile_index][slot] = (tileset_id, gid)`.
type TileData = Vec<Vec<Vec<Vec<(u32, u32)>>>>;

/// Direct paint operation applied after block placement.
#[derive(Debug, Clone)]
pub struct PaintRectOp {
    /// Tile-space X coordinate.
    pub x: i32,
    /// Tile-space Y coordinate.
    pub y: i32,
    /// Width in tiles.
    pub width: u32,
    /// Height in tiles.
    pub height: u32,
    /// GID to write.
    pub tile_id: u32,
    /// Slot index to write.
    pub slot_index: usize,
    /// Tileset identifier to write.
    pub tileset_id: u32,
    /// Layer index to write.
    pub layer: u32,
    /// Level index to write.
    pub level: u32,
}

/// Placement export summary for Lua callers.
#[derive(Debug, Clone)]
pub struct PlacementRecord {
    /// Group name that owns this placement.
    pub group_name: String,
    /// Block name stored on the source block.
    pub block_name: String,
    /// Block index inside the group.
    pub block_index: usize,
    /// Placement anchor X in grid cells.
    pub grid_x: i32,
    /// Placement anchor Y in grid cells.
    pub grid_y: i32,
    /// Level index.
    pub level: u32,
    /// Rotation in quarter turns clockwise.
    pub rotation: u32,
    /// Whether mirrored horizontally.
    pub mirrored: bool,
    /// Covered placement cells.
    pub cells: Vec<(i32, i32)>,
}

/// Inputs required to materialize a `MapBlockResult`.
#[derive(Debug, Clone, Copy)]
pub struct MapBlockResultBuild<'a> {
    /// Placement grid that defines output bounds.
    pub grid: &'a PlacementGrid,
    /// Placed blocks organized by level.
    pub levels: &'a MultiLevelMap,
    /// Registered block groups.
    pub groups: &'a HashMap<String, MapGroup>,
    /// Slot and segment configuration.
    pub config: &'a MapBlockConfig,
    /// Deferred direct paint operations.
    pub paint_ops: &'a [PaintRectOp],
    /// Chosen output orientation.
    pub orientation: MapOrientation,
    /// Output tile pixel width.
    pub tile_pixel_w: u32,
    /// Output tile pixel height.
    pub tile_pixel_h: u32,
}

/// Result of map block generation containing all placed tiles ready for rendering.
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
    pub tiles: TileData,
    /// Orientation used.
    pub orientation: MapOrientation,
    /// Tile pixel width.
    pub tile_pixel_w: u32,
    /// Tile pixel height.
    pub tile_pixel_h: u32,
    /// Number of blocks successfully placed.
    pub blocks_placed: u32,
    /// Placement summaries for inspection and tests.
    placements: Vec<PlacementRecord>,
}

impl MapBlockResult {
    /// Build the result from placement data.
    pub fn new(build: MapBlockResultBuild<'_>) -> Self {
        let bounds = build.grid.bounds().unwrap_or((0, 0, 0, 0));
        let (min_x, min_y, max_x, max_y) = bounds;
        let segment_size = build.config.default_segment_size.max(1);
        let grid_w = (max_x - min_x + 1).max(1) as u32;
        let grid_h = (max_y - min_y + 1).max(1) as u32;
        let width = grid_w * segment_size;
        let height = grid_h * segment_size;
        let level_count = build.levels.level_count();
        let slot_count = build.config.slot_count();

        let mut max_layers = 1u32;
        for group in build.groups.values() {
            for block in group.blocks() {
                max_layers = max_layers.max(block.get_layer_count());
            }
        }
        for op in build.paint_ops {
            max_layers = max_layers.max(op.layer + 1);
        }

        let empty_tile = vec![(0u32, 0u32); slot_count];
        let tiles: TileData = (0..level_count)
            .map(|_| {
                (0..max_layers)
                    .map(|_| vec![empty_tile.clone(); (width * height) as usize])
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
            orientation: build.orientation,
            tile_pixel_w: build.tile_pixel_w,
            tile_pixel_h: build.tile_pixel_h,
            blocks_placed: build.grid.placed_count() as u32,
            placements: Vec::new(),
        };

        for level_idx in 0..level_count {
            for placed in build.levels.blocks_on_level(level_idx) {
                let Some(group) = build.groups.get(&placed.group_name) else {
                    continue;
                };
                let Some(block) = group.get_block(placed.block_index) else {
                    continue;
                };

                result.placements.push(PlacementRecord {
                    group_name: placed.group_name.clone(),
                    block_name: block.get_name().to_string(),
                    block_index: placed.block_index,
                    grid_x: placed.grid_x,
                    grid_y: placed.grid_y,
                    level: placed.level,
                    rotation: placed.rotation,
                    mirrored: placed.mirrored,
                    cells: placed.occupied_cells.clone(),
                });

                let offset_x = ((placed.grid_x - min_x) as u32) * segment_size;
                let offset_y = ((placed.grid_y - min_y) as u32) * segment_size;

                for layer_idx in 0..block.get_layer_count() as usize {
                    if let Some(layer) = block.get_layer(layer_idx) {
                        for src_y in 0..layer.height() {
                            for src_x in 0..layer.width() {
                                let cell_x = (src_x / segment_size) as i32;
                                let cell_y = (src_y / segment_size) as i32;
                                if !block.is_footprint_cell(cell_x, cell_y) {
                                    continue;
                                }
                                let (dst_x, dst_y) = transform_tile(
                                    src_x,
                                    src_y,
                                    layer.width(),
                                    layer.height(),
                                    placed.rotation,
                                    placed.mirrored,
                                );
                                let out_x = offset_x + dst_x;
                                let out_y = offset_y + dst_y;
                                if out_x >= width || out_y >= height {
                                    continue;
                                }
                                let idx = (out_y * width + out_x) as usize;
                                if let Some(tile) = layer.get_tile(src_x, src_y) {
                                    for (slot_idx, slot) in tile.slots.iter().enumerate() {
                                        if !slot.is_empty() {
                                            result.tiles[level_idx as usize][layer_idx][idx]
                                                [slot_idx] = (slot.tileset_id, slot.gid);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        for op in build.paint_ops {
            result.apply_paint_op(op);
        }

        result
    }

    /// Get a tile slot value at (level, layer, x, y, slot).
    pub fn get_tile(&self, level: u32, layer: u32, x: u32, y: u32, slot: usize) -> (u32, u32) {
        if level < self.level_count
            && (layer as usize)
                < self
                    .tiles
                    .get(level as usize)
                    .map(|layers| layers.len())
                    .unwrap_or(0)
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

    /// Get the placement summaries captured during generation.
    pub fn placements(&self) -> &[PlacementRecord] {
        &self.placements
    }

    fn apply_paint_op(&mut self, op: &PaintRectOp) {
        if op.level >= self.level_count || op.layer >= self.layer_count {
            return;
        }
        for dy in 0..op.height {
            for dx in 0..op.width {
                let tx = op.x + dx as i32;
                let ty = op.y + dy as i32;
                if tx < 0 || ty < 0 {
                    continue;
                }
                let tx = tx as u32;
                let ty = ty as u32;
                if tx >= self.width || ty >= self.height || op.slot_index >= self.slot_count {
                    continue;
                }
                let idx = (ty * self.width + tx) as usize;
                self.tiles[op.level as usize][op.layer as usize][idx][op.slot_index] =
                    (op.tileset_id, op.tile_id);
            }
        }
    }
}

fn transform_tile(
    src_x: u32,
    src_y: u32,
    width: u32,
    height: u32,
    rotation: u32,
    mirrored: bool,
) -> (u32, u32) {
    let mx = if mirrored { width - 1 - src_x } else { src_x };
    match rotation % 4 {
        0 => (mx, src_y),
        1 => (height - 1 - src_y, mx),
        2 => (width - 1 - mx, height - 1 - src_y),
        _ => (src_y, width - 1 - mx),
    }
}
