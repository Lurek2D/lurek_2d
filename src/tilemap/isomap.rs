//! Defines a multi-level isometric map model where each tile can carry separate floor, wall, and object parts.
//! Maps tile coordinates into diamond-projected screen placement so isometric draw order stays coherent.
//! Iterates diagonal draw order to make elevation layering and overlap read correctly during presentation.
//! Lets each level be shown or hidden, which supports staged reveals and editor-style focused inspection.
//! Keeps part ordering configurable so floor, wall, and object composition can vary by project needs.
//! Acts as the isometric-map boundary instead of forcing the general orthogonal TileMap owner to absorb it.
//! Open this file when iso level stacking, tile part ordering, or projected draw ordering looks incorrect.

use super::error::TileMapError;
use super::limits::{checked_flat_index, checked_layer_cells, TileMapLimits};

/// Draw-layer part of an isometric tile (floor, walls, objects).
#[non_exhaustive]
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
/// # Variants
pub enum IsoTilePart {
    /// Floor/ground plane of the tile.
    Floor = 0,
    /// North-facing wall segment.
    NorthWall = 1,
    /// West-facing wall segment.
    WestWall = 2,
    /// Decorative or interactive object placed on the tile.
    Object = 3,
}
impl IsoTilePart {
    /// Convert an integer `i` to an `IsoTilePart`; returns `None` for unrecognised values.
    pub fn from_index(i: u32) -> Option<Self> {
        match i {
            0 => Some(Self::Floor),
            1 => Some(Self::NorthWall),
            2 => Some(Self::WestWall),
            3 => Some(Self::Object),
            _ => None,
        }
    }
    /// Return the integer index of this part variant.
    pub fn index(self) -> u32 {
        self as u32
    }
}

/// A single isometric cell holding one GID per draw-layer part.
#[derive(Debug, Clone)]
/// # Fields
pub struct IsoTile {
    /// GID values indexed by part order; length equals `IsoMap::part_count`.
    pub parts: Vec<u32>,
}

/// One elevation layer of an `IsoMap` grid of `IsoTile`s.
#[derive(Debug, Clone)]
/// # Fields
pub struct IsoLevel {
    /// Number of tile columns in this level.
    pub width: u32,
    /// Number of tile rows in this level.
    pub height: u32,
    /// Whether this level is included in `draw_iter` output.
    pub visible: bool,
    /// Flat row-major array of tiles.
    tiles: Vec<IsoTile>,
}
impl IsoLevel {
    /// Allocate a `width`×`height` level with each tile pre-filled with `part_count` zero GIDs.
    pub fn new(width: u32, height: u32, part_count: u32) -> Self {
        match Self::try_new(width, height, part_count, &TileMapLimits::default()) {
            Ok(level) => level,
            Err(_) => Self {
                width: 0,
                height: 0,
                visible: true,
                tiles: Vec::new(),
            },
        }
    }

    /// Allocate a checked level whose cell and part storage stays within `limits`.
    pub fn try_new(
        width: u32,
        height: u32,
        part_count: u32,
        limits: &TileMapLimits,
    ) -> Result<Self, TileMapError> {
        let cells = checked_layer_cells(width, height, limits)?;
        if part_count == 0 {
            return Err(TileMapError::InvalidLimitConfiguration {
                field: "part_count",
            });
        }
        let total = (cells as u64).checked_mul(u64::from(part_count)).ok_or(
            TileMapError::TileOperationLimitExceeded {
                cells: u64::MAX,
                max_cells: limits.max_tile_operation_cells,
            },
        )?;
        if total > limits.max_tile_operation_cells {
            return Err(TileMapError::TileOperationLimitExceeded {
                cells: total,
                max_cells: limits.max_tile_operation_cells,
            });
        }
        let pc =
            usize::try_from(part_count).map_err(|_| TileMapError::InvalidLimitConfiguration {
                field: "part_count",
            })?;
        Ok(Self {
            width,
            height,
            visible: true,
            tiles: (0..cells)
                .map(|_| IsoTile {
                    parts: vec![0u32; pc],
                })
                .collect(),
        })
    }
    /// Return the flat index for tile `(x, y)`, or `None` for out-of-bounds.
    fn index(&self, x: u32, y: u32) -> Option<usize> {
        checked_flat_index(self.width, x, y, self.tiles.len())
    }
    /// Return a shared reference to the tile at `(x, y)`, or `None` for out-of-bounds.
    pub fn get_tile(&self, x: u32, y: u32) -> Option<&IsoTile> {
        self.index(x, y).map(|i| &self.tiles[i])
    }

    /// Return a mutable reference to the tile at `(x, y)`, or `None` for out-of-bounds.
    pub fn get_tile_mut(&mut self, x: u32, y: u32) -> Option<&mut IsoTile> {
        self.index(x, y).map(|i| &mut self.tiles[i])
    }
}
/// A single draw-order entry produced by `IsoMap::draw_iter`.
#[derive(Debug, Clone)]
/// # Fields
pub struct IsoDrawItem {
    /// Elevation index of the level this item belongs to.
    pub level: u32,
    /// Tile column coordinate.
    pub tile_x: u32,
    /// Tile row coordinate.
    pub tile_y: u32,
    /// Part index within the tile.
    pub part: u32,
    /// GID to look up in the tileset; 0 means empty.
    pub gid: u32,
    /// Screen X position for rendering this item.
    pub screen_x: f32,
    /// Screen Y position for rendering this item.
    pub screen_y: f32,
}

/// Multi-level isometric tile map with painter-sorted draw iteration.
#[derive(Debug, Clone)]
/// # Fields
pub struct IsoMap {
    /// Number of tile columns.
    pub width: u32,
    /// Number of tile rows.
    pub height: u32,
    /// Pixel width of one tile.
    pub tile_w: u32,
    /// Pixel height of one tile.
    pub tile_h: u32,
    /// Vertical pixel offset between elevation levels.
    pub level_height: u32,
    /// World-space X origin of tile (0,0,0).
    pub origin_x: f32,
    /// World-space Y origin of tile (0,0,0).
    pub origin_y: f32,
    /// Number of draw-layer parts per tile.
    pub part_count: u32,
    /// Draw order for parts within each tile; indices into `[0, part_count)`.
    pub part_order: Vec<u32>,
    /// Elevation levels; each holds a full `width`×`height` grid of tiles.
    levels: Vec<IsoLevel>,
    /// Shared allocation ceiling for elevation-level storage.
    limits: TileMapLimits,
}
impl IsoMap {
    /// Create an empty map with the given tile dimensions and `part_count` (clamped to at least 1).
    pub fn new(
        width: u32,
        height: u32,
        tile_w: u32,
        tile_h: u32,
        level_height: u32,
        part_count: u32,
    ) -> Self {
        match Self::try_new(
            width,
            height,
            tile_w,
            tile_h,
            level_height,
            part_count,
            &TileMapLimits::default(),
        ) {
            Ok(map) => map,
            Err(_) => Self {
                width: 0,
                height: 0,
                tile_w: tile_w.max(1),
                tile_h: tile_h.max(1),
                level_height,
                origin_x: 0.0,
                origin_y: 0.0,
                part_count: 1,
                part_order: vec![0],
                levels: Vec::new(),
                limits: TileMapLimits::default(),
            },
        }
    }

    /// Create an isometric map with checked grid, tile, part, and level limits.
    pub fn try_new(
        width: u32,
        height: u32,
        tile_w: u32,
        tile_h: u32,
        level_height: u32,
        part_count: u32,
        limits: &TileMapLimits,
    ) -> Result<Self, TileMapError> {
        limits.validate()?;
        if tile_w == 0 || tile_h == 0 {
            return Err(TileMapError::InvalidTileSize {
                tile_width: tile_w,
                tile_height: tile_h,
            });
        }
        checked_layer_cells(width, height, limits)?;
        if part_count == 0 {
            return Err(TileMapError::InvalidLimitConfiguration {
                field: "part_count",
            });
        }
        if u64::from(part_count) > limits.max_tile_operation_cells {
            return Err(TileMapError::TileOperationLimitExceeded {
                cells: u64::from(part_count),
                max_cells: limits.max_tile_operation_cells,
            });
        }
        Ok(Self {
            width,
            height,
            tile_w,
            tile_h,
            level_height,
            origin_x: 0.0,
            origin_y: 0.0,
            part_count,
            part_order: (0..part_count).collect(),
            levels: Vec::new(),
            limits: *limits,
        })
    }
    /// Append a new elevation level and return its index.
    pub fn add_level(&mut self) -> usize {
        self.try_add_level().unwrap_or(self.levels.len())
    }

    /// Append a new elevation level within the configured layer and storage ceilings.
    pub fn try_add_level(&mut self) -> Result<usize, TileMapError> {
        if self.levels.len() >= self.limits.max_layers {
            return Err(TileMapError::MaxLayersExceeded {
                requested: self.levels.len() + 1,
                max_layers: self.limits.max_layers,
            });
        }
        let idx = self.levels.len();
        self.levels.push(IsoLevel::try_new(
            self.width,
            self.height,
            self.part_count,
            &self.limits,
        )?);
        Ok(idx)
    }
    /// Return the number of elevation levels currently in this map.
    pub fn get_level_count(&self) -> usize {
        self.levels.len()
    }

    /// Set `visible` on level `z`; no-op for out-of-range indices.
    pub fn set_level_visible(&mut self, z: usize, visible: bool) {
        if let Some(level) = self.levels.get_mut(z) {
            level.visible = visible;
        }
    }
    /// Return the visibility of level `z`; returns `true` for missing levels.
    pub fn get_level_visible(&self, z: usize) -> bool {
        self.levels.get(z).is_none_or(|l| l.visible)
    }
    /// Write `gid` to part `part` of tile `(x,y)` on level `z`; no-op for out-of-range inputs.
    pub fn set_tile_part(&mut self, z: usize, x: u32, y: u32, part: u32, gid: u32) {
        if part >= self.part_count {
            return;
        }
        if let Some(level) = self.levels.get_mut(z) {
            if let Some(tile) = level.get_tile_mut(x, y) {
                if let Some(slot) = tile.parts.get_mut(part as usize) {
                    *slot = gid;
                }
            }
        }
    }
    /// Return the GID of part `part` at tile `(x,y)` on level `z`; returns 0 for missing data.
    pub fn get_tile_part(&self, z: usize, x: u32, y: u32, part: u32) -> u32 {
        if part >= self.part_count {
            return 0;
        }
        self.levels
            .get(z)
            .and_then(|l| l.get_tile(x, y))
            .map_or(0, |t| t.parts.get(part as usize).copied().unwrap_or(0))
    }
    /// Fill every tile on level `z` at part index `part` with `gid`.
    pub fn fill_level(&mut self, z: usize, part: u32, gid: u32) {
        if part >= self.part_count {
            return;
        }
        if let Some(level) = self.levels.get_mut(z) {
            for tile in level.tiles.iter_mut() {
                if let Some(slot) = tile.parts.get_mut(part as usize) {
                    *slot = gid;
                }
            }
        }
    }
    /// Set the world-space origin `(x, y)` that maps to tile `(0,0,0)` in screen space.
    pub fn set_origin(&mut self, x: f32, y: f32) {
        self.origin_x = x;
        self.origin_y = y;
    }

    /// Convert tile position `(tx, ty, tz)` to screen position `(sx, sy)`.
    pub fn tile_to_screen(&self, tx: f32, ty: f32, tz: f32) -> (f32, f32) {
        let hw = self.tile_w as f32 / 2.0;
        let hh = self.tile_h as f32 / 2.0;
        let sx = self.origin_x + (tx - ty) * hw;
        let sy = self.origin_y + (tx + ty) * hh - tz * self.level_height as f32;
        (sx, sy)
    }
    /// Convert screen position `(sx, sy)` to fractional tile `(tx, ty)` at elevation 0.
    pub fn screen_to_tile(&self, sx: f32, sy: f32) -> (f32, f32) {
        let rel_x = sx - self.origin_x;
        let rel_y = sy - self.origin_y;
        let hw = self.tile_w as f32 / 2.0;
        let hh = self.tile_h as f32 / 2.0;
        let tx = (rel_x / hw + rel_y / hh) / 2.0;
        let ty = (rel_y / hh - rel_x / hw) / 2.0;
        (tx, ty)
    }
    /// Return draw items for all tiles up to `active_z`, sorted in painter order (diagonal strips).
    pub fn draw_iter(&self, active_z: usize) -> Vec<IsoDrawItem> {
        if self.levels.is_empty() || self.width == 0 || self.height == 0 {
            return Vec::new();
        }
        let max_z = active_z.min(self.levels.len() - 1);
        let w = self.width as usize;
        let h = self.height as usize;
        let pc = self.part_count as usize;
        let capacity = w
            .checked_mul(h)
            .and_then(|cells| cells.checked_mul(max_z + 1))
            .and_then(|cells| cells.checked_mul(pc));
        let mut items = capacity.map_or_else(Vec::new, Vec::with_capacity);
        let max_d = (w + h).saturating_sub(2);
        for d in 0..=max_d {
            let tx_min = d.saturating_sub(h - 1);
            let tx_max = d.min(w - 1);
            for tx in tx_min..=tx_max {
                let ty = d - tx;
                for z in 0..=max_z {
                    let level = &self.levels[z];
                    if !level.visible {
                        continue;
                    }
                    let tile = match level.get_tile(tx as u32, ty as u32) {
                        Some(t) => t,
                        None => continue,
                    };
                    let (sx, sy) = self.tile_to_screen(tx as f32, ty as f32, z as f32);
                    for &part in &self.part_order {
                        let gid = tile.parts.get(part as usize).copied().unwrap_or(0);
                        items.push(IsoDrawItem {
                            level: z as u32,
                            tile_x: tx as u32,
                            tile_y: ty as u32,
                            part,
                            gid,
                            screen_x: sx,
                            screen_y: sy,
                        });
                    }
                }
            }
        }
        items
    }
    /// Return the number of draw-layer parts per tile.
    pub fn get_part_count(&self) -> u32 {
        self.part_count
    }

    /// Return the current draw-order slice for parts within a tile.
    pub fn get_part_order(&self) -> &[u32] {
        &self.part_order
    }

    /// Replace part draw order with `order`; returns an error if length or indices are invalid.
    pub fn set_part_order(&mut self, order: Vec<u32>) -> Result<(), String> {
        if order.len() != self.part_count as usize {
            return Err(format!(
                "setPartOrder: expected {} indices, got {}",
                self.part_count,
                order.len()
            ));
        }
        for &idx in &order {
            if idx >= self.part_count {
                return Err(format!(
                    "setPartOrder: index {} out of range (part_count = {})",
                    idx, self.part_count
                ));
            }
        }
        self.part_order = order;
        Ok(())
    }
}
