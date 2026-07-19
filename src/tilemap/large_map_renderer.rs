//! Owns the bounded renderer snapshot for maps that are too large for one monolithic redraw.
//!
//! `LargeMapRenderer` is intentionally an independent dense snapshot: `TileMap` and `ChunkMap`
//! remain authoritative storage owners, while this type owns only its snapshot and visible-chunk
//! cache. All snapshot allocations and camera inputs pass through `TileMapLimits` validation.

use std::collections::HashMap;

use super::error::TileMapError;
use super::limits::{
    checked_chunk_cells, checked_chunk_count, checked_flat_index, checked_layer_cells,
    TileMapLimits,
};
use crate::camera::{camera_visible_chunk_range, ChunkViewportRange};

/// A single rendered chunk: a region of tile IDs with a dirty flag for incremental updates.
#[derive(Debug)]
/// # Fields
pub struct MapChunk {
    /// Chunk column coordinate in chunk space.
    pub cx: i32,
    /// Chunk row coordinate in chunk space.
    pub cy: i32,
    /// True when the tiles were modified since the last render refresh.
    pub dirty: bool,
    /// Flat tile-ID slice for this chunk, row-major within the chunk bounds.
    pub tile_ids: Vec<u32>,
}

/// Stateful renderer context for an independently mutable, bounded dense map snapshot.
/// # Fields
pub struct LargeMapRenderer {
    /// Pixel width of a single tile.
    pub tile_width: u32,
    /// Pixel height of a single tile.
    pub tile_height: u32,
    /// Map width in tiles.
    pub map_width: u32,
    /// Map height in tiles.
    pub map_height: u32,
    /// Flat row-major tile-ID array for the renderer snapshot.
    tile_data: Vec<u32>,
    /// Number of columns in the source tileset texture.
    pub tileset_columns: u32,
    /// Side length in tiles of each square chunk.
    pub chunk_size: u32,
    /// Loaded chunk cache keyed by chunk coordinates.
    chunks: HashMap<(i32, i32), MapChunk>,
    /// World X position of the camera centre.
    pub camera_x: f32,
    /// World Y position of the camera centre.
    pub camera_y: f32,
    /// Camera zoom factor; values less than 1 zoom out.
    pub camera_zoom: f32,
    /// Viewport width in pixels at zoom=1.
    pub viewport_w: f32,
    /// Viewport height in pixels at zoom=1.
    pub viewport_h: f32,
    /// Whether LOD down-sampling is active.
    pub lod_enabled: bool,
    /// Sorted, deduplicated zoom thresholds at which successive LOD levels activate.
    pub lod_thresholds: Vec<f32>,
    /// Shared allocation and input ceilings for this snapshot.
    limits: TileMapLimits,
}

impl LargeMapRenderer {
    /// Create a renderer with legacy clamping for zero tile dimensions.
    /// Prefer `try_new` at fallible boundaries such as Lua constructors.
    pub fn new(tile_w: u32, tile_h: u32) -> Self {
        match Self::try_new(tile_w, tile_h, &TileMapLimits::default()) {
            Ok(renderer) => renderer,
            Err(_) => Self {
                tile_width: tile_w.max(1),
                tile_height: tile_h.max(1),
                map_width: 0,
                map_height: 0,
                tile_data: Vec::new(),
                tileset_columns: 1,
                chunk_size: 16,
                chunks: HashMap::new(),
                camera_x: 0.0,
                camera_y: 0.0,
                camera_zoom: 1.0,
                viewport_w: 0.0,
                viewport_h: 0.0,
                lod_enabled: false,
                lod_thresholds: Vec::new(),
                limits: TileMapLimits::default(),
            },
        }
    }

    /// Create a renderer with validated tile dimensions and allocation limits.
    pub fn try_new(tile_w: u32, tile_h: u32, limits: &TileMapLimits) -> Result<Self, TileMapError> {
        limits.validate()?;
        if tile_w == 0 || tile_h == 0 {
            return Err(TileMapError::InvalidTileSize {
                tile_width: tile_w,
                tile_height: tile_h,
            });
        }
        checked_chunk_cells(16, limits)?;
        Ok(Self {
            tile_width: tile_w,
            tile_height: tile_h,
            map_width: 0,
            map_height: 0,
            tile_data: Vec::new(),
            tileset_columns: 1,
            chunk_size: 16,
            chunks: HashMap::new(),
            camera_x: 0.0,
            camera_y: 0.0,
            camera_zoom: 1.0,
            viewport_w: 0.0,
            viewport_h: 0.0,
            lod_enabled: false,
            lod_thresholds: Vec::new(),
            limits: *limits,
        })
    }

    /// Replace map data through the renderer's configured bounded policy.
    pub fn set_map_data(&mut self, data: Vec<u32>, width: u32, height: u32) {
        let _ = self.try_set_map_data(data, width, height);
    }

    /// Replace the renderer snapshot, requiring exactly `width * height` tile IDs.
    pub fn try_set_map_data(
        &mut self,
        data: Vec<u32>,
        width: u32,
        height: u32,
    ) -> Result<(), TileMapError> {
        let expected = checked_layer_cells(width, height, &self.limits)?;
        if data.len() != expected {
            return Err(TileMapError::InvalidLength {
                context: "large-map tile data",
                expected,
                actual: data.len(),
            });
        }
        checked_chunk_count(width, height, self.chunk_size, &self.limits)?;
        self.map_width = width;
        self.map_height = height;
        self.tile_data = data;
        self.rebuild_chunks();
        Ok(())
    }

    /// Write `tile_id` at map position `(x, y)` and mark its chunk dirty.
    pub fn set_tile(&mut self, x: u32, y: u32, tile_id: u32) {
        let _ = self.try_set_tile(x, y, tile_id);
    }

    /// Write one tile using checked row-major arithmetic.
    pub fn try_set_tile(&mut self, x: u32, y: u32, tile_id: u32) -> Result<(), TileMapError> {
        if x >= self.map_width || y >= self.map_height {
            return Ok(());
        }
        let Some(idx) = checked_flat_index(self.map_width, x, y, self.tile_data.len()) else {
            return Ok(());
        };
        if self.tile_data[idx] == tile_id {
            return Ok(());
        }
        self.tile_data[idx] = tile_id;
        let cx = (x / self.chunk_size) as i32;
        let cy = (y / self.chunk_size) as i32;
        if let Some(chunk) = self.chunks.get_mut(&(cx, cy)) {
            let start_x = cx.max(0) as u32 * self.chunk_size;
            let start_y = cy.max(0) as u32 * self.chunk_size;
            let local_width = self.map_width.saturating_sub(start_x).min(self.chunk_size);
            let local_index = y
                .saturating_sub(start_y)
                .saturating_mul(local_width)
                .saturating_add(x.saturating_sub(start_x)) as usize;
            if let Some(cached) = chunk.tile_ids.get_mut(local_index) {
                *cached = tile_id;
            }
            chunk.dirty = true;
        }
        Ok(())
    }

    /// Return the tile ID at `(x, y)`, or `None` for out-of-bounds.
    pub fn get_tile(&self, x: u32, y: u32) -> Option<u32> {
        if x >= self.map_width || y >= self.map_height {
            return None;
        }
        checked_flat_index(self.map_width, x, y, self.tile_data.len())
            .and_then(|idx| self.tile_data.get(idx).copied())
    }

    /// Return the map dimensions as `(width, height)` in tiles.
    pub fn get_map_size(&self) -> (u32, u32) {
        (self.map_width, self.map_height)
    }

    /// Set the chunk side length; legacy callers receive a no-op on invalid input.
    pub fn set_chunk_size(&mut self, size: u32) {
        let _ = self.try_set_chunk_size(size);
    }

    /// Set the chunk side length after applying cell and total-chunk ceilings.
    pub fn try_set_chunk_size(&mut self, size: u32) -> Result<(), TileMapError> {
        if size == 0 {
            return Err(TileMapError::InvalidChunkSize { chunk_size: size });
        }
        checked_chunk_cells(size, &self.limits)?;
        checked_chunk_count(self.map_width, self.map_height, size, &self.limits)?;
        self.chunk_size = size;
        self.rebuild_chunks();
        Ok(())
    }

    /// Return the current chunk side length.
    pub fn get_chunk_size(&self) -> u32 {
        self.chunk_size
    }

    /// Mark the chunk at `(cx, cy)` dirty; no-op when not cached.
    pub fn invalidate_chunk(&mut self, cx: i32, cy: i32) {
        if let Some(chunk) = self.chunks.get_mut(&(cx, cy)) {
            chunk.dirty = true;
        }
    }

    /// Mark every cached chunk dirty.
    pub fn invalidate_all(&mut self) {
        for chunk in self.chunks.values_mut() {
            chunk.dirty = true;
        }
    }

    /// Return the count of cached chunks that intersect the current camera viewport.
    pub fn get_visible_chunks(&self) -> usize {
        let range = self.visible_chunk_range();
        if range.is_empty() {
            return 0;
        }
        self.chunks
            .keys()
            .filter(|&&(cx, cy)| {
                cx >= range.min_x && cx <= range.max_x && cy >= range.min_y && cy <= range.max_y
            })
            .count()
    }

    /// Return the total number of cached chunks regardless of visibility.
    pub fn get_total_chunks(&self) -> usize {
        self.chunks.len()
    }

    /// Return the full chunk cache map for render adapters.
    pub fn chunks(&self) -> &HashMap<(i32, i32), MapChunk> {
        &self.chunks
    }

    /// Set the camera centre and zoom using finite coordinates and positive zoom.
    pub fn set_camera(&mut self, x: f32, y: f32, zoom: f32) {
        let _ = self.try_set_camera(x, y, zoom);
    }

    /// Set the camera centre and zoom with typed numeric validation.
    pub fn try_set_camera(&mut self, x: f32, y: f32, zoom: f32) -> Result<(), TileMapError> {
        validate_finite(x, "camera x")?;
        validate_finite(y, "camera y")?;
        validate_positive(zoom, "camera zoom")?;
        self.camera_x = x;
        self.camera_y = y;
        self.camera_zoom = zoom;
        Ok(())
    }

    /// Set the viewport dimensions in pixels; legacy callers receive a no-op on invalid input.
    pub fn set_viewport(&mut self, w: f32, h: f32) {
        let _ = self.try_set_viewport(w, h);
    }

    /// Set a positive, finite viewport size.
    pub fn try_set_viewport(&mut self, w: f32, h: f32) -> Result<(), TileMapError> {
        validate_positive(w, "viewport width")?;
        validate_positive(h, "viewport height")?;
        self.viewport_w = w;
        self.viewport_h = h;
        Ok(())
    }

    /// Enable or disable LOD down-sampling.
    pub fn set_lod_enabled(&mut self, enabled: bool) {
        self.lod_enabled = enabled;
    }

    /// Return `true` when LOD is currently enabled.
    pub fn is_lod_enabled(&self) -> bool {
        self.lod_enabled
    }

    /// Replace LOD thresholds after validating, sorting, and deduplicating them.
    pub fn set_lod_thresholds(&mut self, levels: Vec<f32>) {
        let _ = self.try_set_lod_thresholds(levels);
    }

    /// Replace LOD thresholds with an explicit validation result.
    pub fn try_set_lod_thresholds(&mut self, mut levels: Vec<f32>) -> Result<(), TileMapError> {
        for level in &levels {
            validate_positive(*level, "LOD threshold")?;
        }
        levels.sort_by(|a, b| a.partial_cmp(b).unwrap_or(std::cmp::Ordering::Equal));
        levels.dedup_by(|a, b| a == b);
        self.lod_thresholds = levels;
        Ok(())
    }

    /// Set the tileset column count; zero is clamped for legacy callers.
    pub fn set_tileset_columns(&mut self, cols: u32) {
        self.tileset_columns = cols.max(1);
    }

    /// Return the current tileset column count.
    pub fn get_tileset_columns(&self) -> u32 {
        self.tileset_columns
    }

    /// Rebuild all visible-chunk cache entries from the current snapshot.
    fn rebuild_chunks(&mut self) {
        self.chunks.clear();
        if self.map_width == 0 || self.map_height == 0 {
            return;
        }
        let cols_chunks = self.map_width.div_ceil(self.chunk_size);
        let rows_chunks = self.map_height.div_ceil(self.chunk_size);
        for cy in 0..rows_chunks {
            for cx in 0..cols_chunks {
                let Some(start_x) = cx.checked_mul(self.chunk_size) else {
                    return;
                };
                let Some(start_y) = cy.checked_mul(self.chunk_size) else {
                    return;
                };
                let end_x = start_x.saturating_add(self.chunk_size).min(self.map_width);
                let end_y = start_y.saturating_add(self.chunk_size).min(self.map_height);
                let mut tile_ids = Vec::new();
                let row_width = end_x.saturating_sub(start_x);
                let reserve = row_width.saturating_mul(end_y.saturating_sub(start_y)) as usize;
                tile_ids.reserve(reserve);
                for ty in start_y..end_y {
                    for tx in start_x..end_x {
                        if let Some(idx) =
                            checked_flat_index(self.map_width, tx, ty, self.tile_data.len())
                        {
                            tile_ids.push(self.tile_data[idx]);
                        }
                    }
                }
                self.chunks.insert(
                    (cx as i32, cy as i32),
                    MapChunk {
                        cx: cx as i32,
                        cy: cy as i32,
                        dirty: false,
                        tile_ids,
                    },
                );
            }
        }
    }

    /// Return the inclusive chunk range visible through the current camera viewport.
    fn visible_chunk_range(&self) -> ChunkViewportRange {
        camera_visible_chunk_range(
            self.map_width,
            self.map_height,
            self.tile_width,
            self.tile_height,
            self.chunk_size,
            self.camera_x,
            self.camera_y,
            self.camera_zoom,
            self.viewport_w,
            self.viewport_h,
        )
    }
}

fn validate_finite(value: f32, context: &'static str) -> Result<(), TileMapError> {
    if !value.is_finite() {
        return Err(TileMapError::NonFiniteFloat { context });
    }
    Ok(())
}

fn validate_positive(value: f32, context: &'static str) -> Result<(), TileMapError> {
    validate_finite(value, context)?;
    if value <= 0.0 {
        return Err(TileMapError::NonPositiveFloat { context, value });
    }
    Ok(())
}

/// Default `LargeMapRenderer` uses 32 by 32 pixel tiles.
impl Default for LargeMapRenderer {
    fn default() -> Self {
        Self::new(32, 32)
    }
}
