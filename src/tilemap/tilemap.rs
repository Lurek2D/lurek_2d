//! This file owns tilemap behavior inside the tilemap subsystem, close to its data and invariants.
//! It keeps validation, defaults, and error-facing rules near the operations that mutate tilemap state.
//! Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.
//! Public functions in this file are the stable entry points other modules should use for tilemap work.
//! Serialization, indexing, and boundary checks stay here when they depend on tilemap internals.
//! Renderer, API, and test layers should call through these helpers rather than duplicate private rules.
//! Open this file when tilemap ownership changes, but keep unrelated subsystem policy in sibling modules.
//! The code favors small data transformations so examples, specs, and tests can assert behavior directly.
//! Stateful changes are kept deterministic here so generated docs and smoke tests remain reproducible.
//! Cross-module dependencies are intentionally narrow, with shared types imported only at this boundary.
//! This module documents where tilemap data becomes behavior and where surrounding systems take over.

use super::error::TileMapError;
use super::limits::{checked_chunk_cells, checked_flat_index, checked_layer_cells, TileMapLimits};
use super::orientation::MapOrientation;
use super::tilemap_index::remove_pos_from_gid;
use crate::log_msg;
use crate::math::{Rect, Vec2};
use crate::runtime::log_messages::{TM01_TILEMAP_INIT, TM02_TILESET_ADD, TM03_LAYER_ADD};
use crate::runtime::resource_keys::ShaderKey;
use crate::tileset::{AutoTileMode, TileSet};
use std::cell::Cell;
use std::collections::{BTreeSet, HashMap};

/// A single tile layer with per-tile GID and optional per-tile tint data.
#[derive(Debug, Clone)]
/// # Fields
pub struct TileLayer {
    /// Layer identifier shown in editors and log messages.
    pub name: String,
    /// Tile count along the X axis.
    pub width: u32,
    /// Tile count along the Y axis.
    pub height: u32,
    /// Whether this layer is included in render-command output.
    pub visible: bool,
    /// Multiplicative tint `[r, g, b, a]` applied to every tile in the layer.
    pub tint: [f32; 4],
    /// World-space draw offset applied to this layer.
    pub offset: Vec2,
    /// Per-axis parallax scroll factor; `(1, 1)` = full scroll, `(0, 0)` = fixed.
    pub parallax: Vec2,
    /// Flat GID array in row-major order; `0` means empty.
    tiles: Vec<u32>,
    /// Optional per-tile tint override; `None` falls back to `tint`.
    tile_tints: Vec<Option<[f32; 4]>>,
}
impl TileLayer {
    /// Create a fully-empty `TileLayer` of `width` by `height` tiles with all GIDs set to `0`.
    /// Convert `(x, y)` into a flat index; returns `None` when out of bounds.
    fn index(&self, x: u32, y: u32) -> Option<usize> {
        checked_flat_index(self.width, x, y, self.tiles.len())
    }

    /// Create a fully-empty `TileLayer` with checked dimensions and configured limits.
    fn try_new(
        name: &str,
        width: u32,
        height: u32,
        limits: &TileMapLimits,
    ) -> Result<Self, TileMapError> {
        limits.validate()?;
        let cap = checked_layer_cells(width, height, limits)?;
        Ok(Self {
            name: name.to_string(),
            width,
            height,
            visible: true,
            tint: [1.0, 1.0, 1.0, 1.0],
            offset: Vec2::ZERO,
            parallax: Vec2::new(1.0, 1.0),
            tiles: vec![0u32; cap],
            tile_tints: vec![None; cap],
        })
    }
}

/// Policy controlling when the reverse GID index is materialized.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
/// # Variants
pub enum TileIndexPolicy {
    /// Keep the reverse index incrementally updated.
    Eager,
    /// Rebuild the reverse index only when a query needs it.
    Lazy,
}

/// Snapshot of tilemap diagnostics counters used to surface silent fallbacks and guarded queries.
#[derive(Debug, Clone, Copy, Default, PartialEq, Eq)]
/// # Fields
pub struct TileMapDiagnosticsSnapshot {
    /// Count of operations targeting a missing layer.
    pub invalid_layer: u64,
    /// Count of operations targeting out-of-bounds coordinates.
    pub invalid_coord: u64,
    /// Count of GID resolutions that failed because no tileset owned the GID.
    pub unknown_gid: u64,
    /// Count of coordinate or storage queries rejected by input validation.
    pub invalid_queries: u64,
    /// Count of lazy reverse-index rebuilds triggered by read paths.
    pub lazy_index_rebuilds: u64,
}

/// Interior-mutable diagnostics counters used by both mutating and read-only tilemap methods.
#[derive(Debug, Clone, Default)]
struct TileMapDiagnostics {
    invalid_layer: Cell<u64>,
    invalid_coord: Cell<u64>,
    unknown_gid: Cell<u64>,
    invalid_queries: Cell<u64>,
    lazy_index_rebuilds: Cell<u64>,
}

impl TileMapDiagnostics {
    fn bump(cell: &Cell<u64>) {
        cell.set(cell.get().saturating_add(1));
    }

    fn snapshot(&self) -> TileMapDiagnosticsSnapshot {
        TileMapDiagnosticsSnapshot {
            invalid_layer: self.invalid_layer.get(),
            invalid_coord: self.invalid_coord.get(),
            unknown_gid: self.unknown_gid.get(),
            invalid_queries: self.invalid_queries.get(),
            lazy_index_rebuilds: self.lazy_index_rebuilds.get(),
        }
    }
}
/// Multi-layer tile map with tileset attachment, tile storage, autotile, animation, and render-command output.
#[derive(Debug, Clone)]
/// # Fields
pub struct TileMap {
    /// Width of each tile in pixels.
    tile_width: u32,
    /// Height of each tile in pixels.
    tile_height: u32,
    /// Chunk size used by the streaming chunk sub-system.
    chunk_size: u32,
    /// World-space coordinate interpretation (TopDown, Isometric, Hex, etc.).
    orientation: MapOrientation,
    /// Ordered list of tilesets attached to this map.
    tilesets: Vec<TileSet>,
    /// Ordered list of tile layers.
    layers: Vec<TileLayer>,
    /// Optional shader bound to all tilemap render-command output.
    shader: Option<ShaderKey>,
    /// Optional shader override per layer, parallel to `layers`.
    layer_shaders: Vec<Option<ShaderKey>>,
    /// Per-layer GID-to-position reverse index for fast `find_tiles_by_gid`.
    tile_type_index_cache: Vec<HashMap<u32, Vec<(u32, u32)>>>,
    /// Tracks which per-layer reverse indexes require a lazy rebuild before reads.
    tile_type_index_dirty: Vec<bool>,
    /// Controls whether the reverse index is eagerly maintained or lazily rebuilt.
    index_policy: TileIndexPolicy,
    /// Optional viewport rect for camera-culled render-command generation.
    viewport: Option<Rect>,
    /// Per-GID animation state `(frame_index, elapsed_ms)`.
    anim_timers: HashMap<u32, (usize, f32)>,
    /// Animated GIDs currently intersecting render culling state.
    render_active_animated_gids: Vec<u32>,
    /// Marks whether render-active animated GIDs must be rebuilt before the next update.
    anim_culling_dirty: bool,
    /// Shared tilemap sizing and query limits.
    limits: TileMapLimits,
    /// Diagnostics counters for guarded fallbacks and invalid calls.
    diagnostics: TileMapDiagnostics,
}
impl TileMap {
    /// Create an empty `TileMap` with the given tile dimensions and chunk size.
    pub fn new(tile_width: u32, tile_height: u32, chunk_size: u32) -> Self {
        debug_assert!(
            tile_width > 0 && tile_height > 0 && chunk_size > 0,
            "tilemap dimensions must be positive"
        );
        let tile_width = tile_width.max(1);
        let tile_height = tile_height.max(1);
        // The fallible constructor is preferred for custom limits; this
        // legacy path keeps its stored chunk arithmetic within safe defaults.
        let chunk_size = chunk_size.clamp(1, 1024);
        log_msg!(
            debug,
            TM01_TILEMAP_INIT,
            "{}x{} tiles, chunk={}",
            tile_width,
            tile_height,
            chunk_size
        );
        Self {
            tile_width,
            tile_height,
            chunk_size,
            orientation: MapOrientation::TopDown,
            tilesets: Vec::new(),
            layers: Vec::new(),
            shader: None,
            layer_shaders: Vec::new(),
            tile_type_index_cache: Vec::new(),
            tile_type_index_dirty: Vec::new(),
            index_policy: TileIndexPolicy::Lazy,
            viewport: None,
            anim_timers: HashMap::new(),
            render_active_animated_gids: Vec::new(),
            anim_culling_dirty: true,
            limits: TileMapLimits::default(),
            diagnostics: TileMapDiagnostics::default(),
        }
    }

    /// Create a validated `TileMap` that rejects zero tile sizes and invalid chunk sizes.
    pub fn try_new(
        tile_width: u32,
        tile_height: u32,
        chunk_size: u32,
    ) -> Result<Self, TileMapError> {
        Self::try_new_with_limits(
            tile_width,
            tile_height,
            chunk_size,
            TileMapLimits::default(),
        )
    }

    /// Create a validated `TileMap` using explicit limits.
    pub fn try_new_with_limits(
        tile_width: u32,
        tile_height: u32,
        chunk_size: u32,
        limits: TileMapLimits,
    ) -> Result<Self, TileMapError> {
        limits.validate()?;
        if tile_width == 0 || tile_height == 0 {
            return Err(TileMapError::InvalidTileSize {
                tile_width,
                tile_height,
            });
        }
        if chunk_size == 0 {
            return Err(TileMapError::InvalidChunkSize { chunk_size });
        }
        checked_chunk_cells(chunk_size, &limits)?;
        let mut map = Self::new(tile_width, tile_height, chunk_size);
        map.chunk_size = chunk_size;
        map.limits = limits;
        Ok(map)
    }

    fn mark_anim_culling_dirty(&mut self) {
        self.anim_culling_dirty = true;
    }

    fn mark_layer_index_dirty(&mut self, layer: usize) {
        if let Some(dirty) = self.tile_type_index_dirty.get_mut(layer) {
            *dirty = true;
        }
    }

    fn ensure_index(&mut self, layer: usize) -> Result<(), TileMapError> {
        let layer_ref = self
            .layers
            .get(layer)
            .ok_or_else(|| self.invalid_layer_error(layer))?;
        let needs_rebuild = self
            .tile_type_index_dirty
            .get(layer)
            .copied()
            .unwrap_or_default();
        if !needs_rebuild {
            return Ok(());
        }
        let mut rebuilt = HashMap::<u32, Vec<(u32, u32)>>::new();
        for y in 0..layer_ref.height {
            for x in 0..layer_ref.width {
                let Some(idx) = checked_flat_index(layer_ref.width, x, y, layer_ref.tiles.len())
                else {
                    continue;
                };
                let gid = layer_ref.tiles[idx];
                if gid != 0 {
                    rebuilt.entry(gid).or_default().push((x, y));
                }
            }
        }
        self.tile_type_index_cache[layer] = rebuilt;
        self.tile_type_index_dirty[layer] = false;
        TileMapDiagnostics::bump(&self.diagnostics.lazy_index_rebuilds);
        Ok(())
    }

    fn invalid_layer_error(&self, layer: usize) -> TileMapError {
        TileMapDiagnostics::bump(&self.diagnostics.invalid_layer);
        TileMapError::InvalidLayerIndex {
            layer,
            layer_count: self.layers.len(),
        }
    }

    fn invalid_coord_error(&self, layer: usize, x: u32, y: u32) -> TileMapError {
        let (width, height) = self
            .layers
            .get(layer)
            .map(|tile_layer| (tile_layer.width, tile_layer.height))
            .unwrap_or((0, 0));
        TileMapDiagnostics::bump(&self.diagnostics.invalid_coord);
        TileMapError::InvalidTileCoord {
            layer,
            x,
            y,
            width,
            height,
        }
    }

    /// Return the current tilemap diagnostics counters.
    pub fn diagnostics_snapshot(&self) -> TileMapDiagnosticsSnapshot {
        self.diagnostics.snapshot()
    }

    /// Override the shared tilemap limits used by safe helpers and guarded queries.
    pub fn set_limits(&mut self, limits: TileMapLimits) {
        self.limits = limits;
    }

    /// Return the active tilemap limits.
    pub fn limits(&self) -> TileMapLimits {
        self.limits
    }

    /// Set the reverse-index maintenance policy.
    pub fn set_index_policy(&mut self, policy: TileIndexPolicy) {
        self.index_policy = policy;
        if policy == TileIndexPolicy::Lazy {
            for dirty in &mut self.tile_type_index_dirty {
                *dirty = true;
            }
        }
    }

    /// Return the reverse-index maintenance policy.
    pub fn index_policy(&self) -> TileIndexPolicy {
        self.index_policy
    }

    /// Append a tileset and take ownership; called during map load or runtime attachment.
    pub fn add_tileset(&mut self, ts: TileSet) {
        log_msg!(debug, TM02_TILESET_ADD);
        self.tilesets.push(ts);
        self.mark_anim_culling_dirty();
    }
    /// Return the tileset at `index`, or `None` when out of range.
    pub fn get_tileset(&self, index: usize) -> Option<&TileSet> {
        self.tilesets.get(index)
    }
    /// Return the number of attached tilesets.
    pub fn get_tileset_count(&self) -> usize {
        self.tilesets.len()
    }
    /// Add a new empty layer of `width × height` tiles; return its layer index.
    pub fn add_layer(&mut self, name: &str, width: u32, height: u32) -> usize {
        self.try_add_layer(name, width, height)
            .unwrap_or_else(|_| self.layers.len().saturating_sub(1))
    }

    /// Add a new empty layer with checked dimensions and configured limits.
    pub fn try_add_layer(
        &mut self,
        name: &str,
        width: u32,
        height: u32,
    ) -> Result<usize, TileMapError> {
        if self.layers.len() >= self.limits.max_layers {
            return Err(TileMapError::MaxLayersExceeded {
                requested: self.layers.len() + 1,
                max_layers: self.limits.max_layers,
            });
        }
        log_msg!(debug, TM03_LAYER_ADD, "{}", name);
        self.layers
            .push(TileLayer::try_new(name, width, height, &self.limits)?);
        self.layer_shaders.push(None);
        self.tile_type_index_cache.push(HashMap::new());
        self.tile_type_index_dirty.push(false);
        self.mark_anim_culling_dirty();
        Ok(self.layers.len() - 1)
    }
    /// Return the total number of layers.
    pub fn get_layer_count(&self) -> usize {
        self.layers.len()
    }
    /// Bind a tilemap-target shader to all generated render commands, or clear it with `None`.
    pub fn set_shader(&mut self, shader: Option<ShaderKey>) {
        self.shader = shader;
    }
    /// Return the shader bound to this tilemap, if any.
    pub fn get_shader(&self) -> Option<ShaderKey> {
        self.shader
    }
    /// Bind a tilemap-target shader override to a single layer.
    pub fn set_layer_shader(
        &mut self,
        idx: usize,
        shader: Option<ShaderKey>,
    ) -> Result<(), TileMapError> {
        if idx >= self.layers.len() {
            return Err(self.invalid_layer_error(idx));
        }
        if let Some(layer_shader) = self.layer_shaders.get_mut(idx) {
            *layer_shader = shader;
        }
        Ok(())
    }
    /// Return the shader override for a single layer.
    pub fn get_layer_shader(&self, idx: usize) -> Option<ShaderKey> {
        self.layer_shaders.get(idx).and_then(|shader| *shader)
    }
    /// Return the shader that should apply to a layer after resolving layer override and map default.
    pub(crate) fn effective_layer_shader(&self, idx: usize) -> Option<ShaderKey> {
        self.get_layer_shader(idx).or(self.shader)
    }
    /// Return the name of layer `idx`, or `None` when out of range.
    pub fn get_layer_name(&self, idx: usize) -> Option<&str> {
        self.layers.get(idx).map(|l| l.name.as_str())
    }
    /// Set the visibility flag on layer `idx`; no-op when out of range.
    pub fn set_layer_visible(&mut self, idx: usize, visible: bool) {
        let _ = self.try_set_layer_visible(idx, visible);
    }
    /// Return `true` when layer `idx` is visible; returns `false` when out of range.
    pub fn get_layer_visible(&self, idx: usize) -> bool {
        self.layers.get(idx).is_some_and(|l| l.visible)
    }
    /// Set the tint RGBA of layer `idx`; no-op when out of range.
    pub fn set_layer_color(&mut self, idx: usize, r: f32, g: f32, b: f32, a: f32) {
        let _ = self.try_set_layer_color(idx, r, g, b, a);
    }
    /// Return the tint `[r, g, b, a]` of layer `idx`; returns `[0; 4]` when out of range.
    pub fn get_layer_color(&self, idx: usize) -> [f32; 4] {
        self.layers.get(idx).map_or([0.0; 4], |l| l.tint)
    }

    /// Return the effective tint for a tile by combining layer tint with optional per-tile tint override.
    /// Returns transparent black when layer or tile coordinates are out of range.
    pub(crate) fn effective_tile_tint(&self, layer: usize, x: u32, y: u32) -> [f32; 4] {
        self.layers
            .get(layer)
            .and_then(|l| l.index(x, y).map(|idx| l.tile_tints[idx].unwrap_or(l.tint)))
            .unwrap_or([0.0, 0.0, 0.0, 0.0])
    }

    /// Set the world-space draw offset `(ox, oy)` of layer `idx`; no-op when out of range.
    pub fn set_layer_offset(&mut self, idx: usize, ox: f32, oy: f32) {
        let _ = self.try_set_layer_offset(idx, ox, oy);
    }
    /// Return the draw offset of layer `idx`; returns `Vec2::ZERO` when out of range.
    pub fn get_layer_offset(&self, idx: usize) -> Vec2 {
        self.layers.get(idx).map_or(Vec2::ZERO, |l| l.offset)
    }
    /// Set the parallax factor `(px, py)` of layer `idx`; no-op when out of range.
    pub fn set_layer_parallax(&mut self, idx: usize, px: f32, py: f32) {
        let _ = self.try_set_layer_parallax(idx, px, py);
    }
    /// Return the parallax factor of layer `idx`; returns `(1, 1)` when out of range.
    pub fn get_layer_parallax(&self, idx: usize) -> Vec2 {
        self.layers
            .get(idx)
            .map_or(Vec2::new(1.0, 1.0), |l| l.parallax)
    }
    /// Return the `(width, height)` tile dimensions of layer `idx`, or `None` when out of range.
    pub fn get_layer_dimensions(&self, idx: usize) -> Option<(u32, u32)> {
        self.layers.get(idx).map(|l| (l.width, l.height))
    }
    /// Write GID `gid` at `(x, y)` in layer `layer`; updates the type-index cache; no-op when out of bounds.
    pub fn set_tile(&mut self, layer: usize, x: u32, y: u32, gid: u32) {
        let _ = self.try_set_tile(layer, x, y, gid);
    }
    /// Return the GID at `(x, y)` in layer `layer`; returns `0` when out of bounds.
    pub fn get_tile(&self, layer: usize, x: u32, y: u32) -> u32 {
        self.try_get_tile(layer, x, y).unwrap_or(0)
    }
    #[allow(clippy::too_many_arguments)]
    /// Set a per-tile RGBA tint override at `(x, y)` in `layer`; no-op when out of bounds.
    pub fn set_tile_tint(&mut self, layer: usize, x: u32, y: u32, r: f32, g: f32, b: f32, a: f32) {
        let _ = self.try_set_tile_tint(layer, x, y, r, g, b, a);
    }
    /// Set the tile at `(x, y)` in `layer` to GID `0`; updates the type-index cache.
    pub fn clear_tile(&mut self, layer: usize, x: u32, y: u32) {
        self.set_tile(layer, x, y, 0);
    }
    /// Fill all tiles in `layer` with `gid`; rebuilds the type-index cache for that layer.
    pub fn fill(&mut self, layer: usize, gid: u32) {
        if let Some(l) = self.layers.get_mut(layer) {
            for tile in l.tiles.iter_mut() {
                *tile = gid;
            }
            if let Some(layer_index) = self.tile_type_index_cache.get_mut(layer) {
                layer_index.clear();
            }
            self.mark_layer_index_dirty(layer);
            self.mark_anim_culling_dirty();
        } else {
            TileMapDiagnostics::bump(&self.diagnostics.invalid_layer);
        }
    }
    /// Return a copy of the GID-to-positions index for `layer`; empty map when out of range.
    pub fn tile_type_index(&mut self, layer: usize) -> HashMap<u32, Vec<(u32, u32)>> {
        if self.ensure_index(layer).is_err() {
            return HashMap::new();
        }
        self.tile_type_index_cache
            .get(layer)
            .cloned()
            .unwrap_or_default()
    }
    /// Return all `(x, y)` positions for tiles matching `gid` in `layer`; empty vec when not found.
    pub fn find_tiles_by_gid(&mut self, layer: usize, gid: u32) -> Vec<(u32, u32)> {
        if self.ensure_index(layer).is_err() {
            return Vec::new();
        }
        self.tile_type_index_cache
            .get(layer)
            .and_then(|idx| idx.get(&gid).cloned())
            .unwrap_or_default()
    }

    /// Set the visibility flag on layer `idx`, returning a typed error when the layer is missing.
    pub fn try_set_layer_visible(&mut self, idx: usize, visible: bool) -> Result<(), TileMapError> {
        if idx >= self.layers.len() {
            return Err(self.invalid_layer_error(idx));
        }
        let layer = &mut self.layers[idx];
        layer.visible = visible;
        self.mark_anim_culling_dirty();
        Ok(())
    }

    /// Set the tint RGBA of layer `idx`, returning a typed error when the layer is missing.
    pub fn try_set_layer_color(
        &mut self,
        idx: usize,
        r: f32,
        g: f32,
        b: f32,
        a: f32,
    ) -> Result<(), TileMapError> {
        validate_finite_rgba([r, g, b, a])?;
        if idx >= self.layers.len() {
            return Err(self.invalid_layer_error(idx));
        }
        let layer = &mut self.layers[idx];
        layer.tint = [r, g, b, a];
        Ok(())
    }

    /// Set the world-space draw offset `(ox, oy)` of layer `idx`, returning a typed error when the layer is missing.
    pub fn try_set_layer_offset(
        &mut self,
        idx: usize,
        ox: f32,
        oy: f32,
    ) -> Result<(), TileMapError> {
        validate_finite_pair(ox, oy, "layer offset")?;
        if idx >= self.layers.len() {
            return Err(self.invalid_layer_error(idx));
        }
        let layer = &mut self.layers[idx];
        layer.offset = Vec2::new(ox, oy);
        Ok(())
    }

    /// Set the parallax factor `(px, py)` of layer `idx`, returning a typed error when the layer is missing.
    pub fn try_set_layer_parallax(
        &mut self,
        idx: usize,
        px: f32,
        py: f32,
    ) -> Result<(), TileMapError> {
        validate_finite_pair(px, py, "layer parallax")?;
        if idx >= self.layers.len() {
            return Err(self.invalid_layer_error(idx));
        }
        let layer = &mut self.layers[idx];
        layer.parallax = Vec2::new(px, py);
        Ok(())
    }

    /// Write GID `gid` at `(x, y)` in layer `layer` and return a typed error on invalid layer or coord.
    pub fn try_set_tile(
        &mut self,
        layer: usize,
        x: u32,
        y: u32,
        gid: u32,
    ) -> Result<(), TileMapError> {
        if layer >= self.layers.len() {
            return Err(self.invalid_layer_error(layer));
        }
        let l = &mut self.layers[layer];
        let idx = match l.index(x, y) {
            Some(idx) => idx,
            None => return Err(self.invalid_coord_error(layer, x, y)),
        };
        let old_gid = l.tiles[idx];
        if old_gid == gid {
            return Ok(());
        }
        l.tiles[idx] = gid;
        if self.index_policy == TileIndexPolicy::Eager && !self.tile_type_index_dirty[layer] {
            if let Some(layer_index) = self.tile_type_index_cache.get_mut(layer) {
                if old_gid != 0 {
                    remove_pos_from_gid(layer_index, old_gid, x, y);
                }
                if gid != 0 {
                    layer_index.entry(gid).or_default().push((x, y));
                }
            }
        } else {
            self.mark_layer_index_dirty(layer);
        }
        self.mark_anim_culling_dirty();
        Ok(())
    }

    /// Return the GID at `(x, y)` in layer `layer`, or a typed error when the layer or coord is invalid.
    pub fn try_get_tile(&self, layer: usize, x: u32, y: u32) -> Result<u32, TileMapError> {
        let l = self
            .layers
            .get(layer)
            .ok_or_else(|| self.invalid_layer_error(layer))?;
        let idx = l
            .index(x, y)
            .ok_or_else(|| self.invalid_coord_error(layer, x, y))?;
        Ok(l.tiles[idx])
    }

    /// Set a per-tile RGBA tint override at `(x, y)` in `layer`, or return a typed error on invalid input.
    #[allow(clippy::too_many_arguments)]
    pub fn try_set_tile_tint(
        &mut self,
        layer: usize,
        x: u32,
        y: u32,
        r: f32,
        g: f32,
        b: f32,
        a: f32,
    ) -> Result<(), TileMapError> {
        validate_finite_rgba([r, g, b, a])?;
        if layer >= self.layers.len() {
            return Err(self.invalid_layer_error(layer));
        }
        let l = &mut self.layers[layer];
        let idx = match l.index(x, y) {
            Some(idx) => idx,
            None => return Err(self.invalid_coord_error(layer, x, y)),
        };
        l.tile_tints[idx] = Some([r, g, b, a]);
        Ok(())
    }
    /// Set the active camera viewport rect; enables culled render-command generation.
    pub fn set_viewport(&mut self, x: f32, y: f32, w: f32, h: f32) {
        let _ = self.try_set_viewport(x, y, w, h);
    }

    /// Set the active camera viewport with finite origin and positive dimensions.
    pub fn try_set_viewport(&mut self, x: f32, y: f32, w: f32, h: f32) -> Result<(), TileMapError> {
        validate_finite_pair(x, y, "viewport origin")?;
        validate_positive(w, "viewport width")?;
        validate_positive(h, "viewport height")?;
        self.viewport = Some(Rect::new(x, y, w, h));
        self.mark_anim_culling_dirty();
        Ok(())
    }
    /// Return the viewport as `(x, y, w, h)`, or `None` when not set.
    pub fn get_viewport(&self) -> Option<(f32, f32, f32, f32)> {
        self.viewport.map(|v| (v.x, v.y, v.width, v.height))
    }
    /// Advance all GID animation timers by `dt` seconds; updates frame indices for each animated tileset.
    pub fn update(&mut self, dt: f32) {
        let _ = self.try_update(dt);
    }

    /// Advance animation timers, rejecting non-finite or negative frame deltas.
    pub fn try_update(&mut self, dt: f32) -> Result<(), TileMapError> {
        validate_finite(dt, "animation dt")?;
        if dt < 0.0 {
            return Err(TileMapError::NonPositiveFloat {
                context: "animation dt",
                value: dt,
            });
        }
        if self.anim_culling_dirty {
            self.rebuild_render_active_animated_gids();
        }
        if dt == 0.0 {
            return Ok(());
        }
        let dt_ms = ((dt as f64) * 1000.0).min(f32::MAX as f64) as f32;
        for &gid in &self.render_active_animated_gids {
            if let Some((ts_idx, local_id)) = self.resolve_gid(gid) {
                let Some(frames) = self.tilesets[ts_idx].get_animation(local_id) else {
                    continue;
                };
                if frames.is_empty() {
                    continue;
                }
                let (frame_idx, elapsed) = self.anim_timers.entry(gid).or_insert((0, 0.0));
                *elapsed += dt_ms;
                let cycle_ms: f32 = frames
                    .iter()
                    .map(|frame| frame.duration_ms)
                    .filter(|duration| duration.is_finite() && *duration > 0.0)
                    .sum();
                if cycle_ms.is_finite() && cycle_ms > 0.0 && *elapsed > cycle_ms {
                    *elapsed %= cycle_ms;
                }
                let mut guard = frames.len().saturating_mul(2).max(1);
                while guard > 0 {
                    let duration_ms = frames[*frame_idx].duration_ms;
                    if !duration_ms.is_finite() || duration_ms <= 0.0 {
                        *frame_idx = (*frame_idx + 1) % frames.len();
                        guard -= 1;
                        continue;
                    }
                    if *elapsed < duration_ms {
                        break;
                    }
                    *elapsed -= duration_ms;
                    *frame_idx = (*frame_idx + 1) % frames.len();
                    guard -= 1;
                }
            }
        }
        Ok(())
    }
    /// Convert world position `(wx, wy)` to tile grid coordinates; clamps negative values to `0`.
    pub fn world_to_tile(&self, wx: f32, wy: f32) -> (u32, u32) {
        self.try_world_to_tile(wx, wy).unwrap_or((0, 0))
    }

    /// Convert world position `(wx, wy)` to tile grid coordinates, returning `None` for negative or non-finite input.
    pub fn try_world_to_tile(&self, wx: f32, wy: f32) -> Option<(u32, u32)> {
        if !wx.is_finite() || !wy.is_finite() || wx < 0.0 || wy < 0.0 {
            TileMapDiagnostics::bump(&self.diagnostics.invalid_queries);
            return None;
        }
        Some((
            (wx / self.tile_width as f32) as u32,
            (wy / self.tile_height as f32) as u32,
        ))
    }
    /// Convert tile grid coordinates `(tx, ty)` to world-space top-left pixel position.
    pub fn tile_to_world(&self, tx: u32, ty: u32) -> (f32, f32) {
        (
            tx as f32 * self.tile_width as f32,
            ty as f32 * self.tile_height as f32,
        )
    }
    /// Return tile width in pixels. This function is part of the public API.
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
    /// Return the streaming chunk size.
    pub fn get_chunk_size(&self) -> u32 {
        self.chunk_size
    }
    /// Return the map orientation. This function is part of the public API.
    pub fn get_orientation(&self) -> MapOrientation {
        self.orientation
    }
    /// Set the map orientation. This function is part of the public API.
    pub fn set_orientation(&mut self, orientation: MapOrientation) {
        self.orientation = orientation;
        self.mark_anim_culling_dirty();
    }

    fn tile_origin_for_culling(&self, tx: u32, ty: u32) -> (f32, f32) {
        match self.orientation {
            MapOrientation::TopDown | MapOrientation::SideView => self.tile_to_world(tx, ty),
            MapOrientation::Isometric => {
                let pos = super::coords::to_screen_iso(
                    tx as f32,
                    ty as f32,
                    self.tile_width as f32,
                    self.tile_height as f32,
                );
                (pos.x, pos.y)
            }
            MapOrientation::Hexagonal => {
                let pos = super::coords::to_screen_hex(
                    tx as i32,
                    ty as i32,
                    self.tile_height as f32 * 0.5,
                );
                (pos.x, pos.y)
            }
        }
    }

    /// Return the render-space origin for one tile coordinate using this map orientation.
    pub fn tile_render_origin(&self, tx: u32, ty: u32) -> (f32, f32) {
        self.tile_origin_for_culling(tx, ty)
    }

    fn tile_intersects_viewport(&self, tx: u32, ty: u32) -> bool {
        let Some(viewport) = self.viewport else {
            return true;
        };
        let (x, y) = self.tile_origin_for_culling(tx, ty);
        x + self.tile_width as f32 >= viewport.x
            && x <= viewport.x + viewport.width
            && y + self.tile_height as f32 >= viewport.y
            && y <= viewport.y + viewport.height
    }

    fn rebuild_render_active_animated_gids(&mut self) {
        let mut visible = BTreeSet::new();
        let animated_gids: Vec<u32> = self
            .tilesets
            .iter()
            .flat_map(|ts| {
                ts.iter_animated_local_ids()
                    .map(move |local_id| ts.get_first_gid() + local_id)
            })
            .collect();
        for layer_idx in 0..self.layers.len() {
            if !self.layers[layer_idx].visible {
                continue;
            }
            if self.ensure_index(layer_idx).is_err() {
                continue;
            }
            let Some(layer_index) = self.tile_type_index_cache.get(layer_idx) else {
                continue;
            };
            for gid in &animated_gids {
                let Some(positions) = layer_index.get(gid) else {
                    continue;
                };
                if positions
                    .iter()
                    .any(|&(x, y)| self.tile_intersects_viewport(x, y))
                {
                    visible.insert(*gid);
                }
            }
        }
        self.render_active_animated_gids = visible.into_iter().collect();
        let animated_set: BTreeSet<u32> = animated_gids.into_iter().collect();
        self.anim_timers.retain(|gid, _| animated_set.contains(gid));
        self.anim_culling_dirty = false;
    }

    /// Resolve animated tiles to the currently active frame GID used for rendering.
    /// Returns the original GID when the tile is static, unknown, or has no animation frames.
    pub(crate) fn render_gid(&self, gid: u32) -> u32 {
        let Some((ts_idx, local_id)) = self.resolve_gid(gid) else {
            return gid;
        };
        let Some(frames) = self.tilesets[ts_idx].get_animation(local_id) else {
            return gid;
        };
        if frames.is_empty() {
            return gid;
        }
        let frame_idx = self.anim_timers.get(&gid).map(|(idx, _)| *idx).unwrap_or(0);
        self.tilesets[ts_idx].get_first_gid() + frames[frame_idx % frames.len()].tile_id
    }
    /// Resolve global GID `gid` to a `(tileset_index, local_id)` pair; returns `None` for GID `0` or unknown GIDs.
    fn resolve_gid(&self, gid: u32) -> Option<(usize, u32)> {
        if gid == 0 {
            return None;
        }
        for (i, ts) in self.tilesets.iter().enumerate() {
            let first = ts.get_first_gid();
            if gid >= first && gid < first + ts.get_tile_count() {
                return Some((i, gid - first));
            }
        }
        TileMapDiagnostics::bump(&self.diagnostics.unknown_gid);
        None
    }
    /// Apply 4-neighbour autotile GID substitution to all non-empty tiles in `layer` matching `type_name`.
    pub fn apply_autotile(&mut self, layer: usize, type_name: &str) {
        let (width, height) = match self.layers.get(layer) {
            Some(l) => (l.width, l.height),
            None => return,
        };
        let mut replacements = Vec::new();
        for y in 0..height {
            for x in 0..width {
                if self.get_tile(layer, x, y) == 0 {
                    continue;
                }
                let mask = self.compute_bitmask_4(layer, x, y, width, height);
                if let Some(new_gid) = self.lookup_autotile_4(type_name, mask) {
                    replacements.push((x, y, new_gid));
                }
            }
        }
        for (x, y, gid) in replacements {
            self.set_tile(layer, x, y, gid);
        }
    }
    /// Apply 4-neighbour autotile substitution to the 3×3 neighbourhood around `(x, y)` only.
    pub fn apply_autotile_at(&mut self, layer: usize, x: u32, y: u32, type_name: &str) {
        let (width, height) = match self.layers.get(layer) {
            Some(l) => (l.width, l.height),
            None => return,
        };
        if width == 0 || height == 0 {
            return;
        }
        let mut replacements = Vec::new();
        let x_start = x.saturating_sub(1);
        let y_start = y.saturating_sub(1);
        let x_end = (x + 1).min(width - 1);
        let y_end = (y + 1).min(height - 1);
        for ny in y_start..=y_end {
            for nx in x_start..=x_end {
                if self.get_tile(layer, nx, ny) == 0 {
                    continue;
                }
                let mask = self.compute_bitmask_4(layer, nx, ny, width, height);
                if let Some(new_gid) = self.lookup_autotile_4(type_name, mask) {
                    replacements.push((nx, ny, new_gid));
                }
            }
        }
        for (x, y, gid) in replacements {
            self.set_tile(layer, x, y, gid);
        }
    }
    /// Apply 8-neighbour autotile GID substitution to all non-empty tiles in `layer` matching `type_name`.
    pub fn apply_autotile_8(&mut self, layer: usize, type_name: &str) {
        let (width, height) = match self.layers.get(layer) {
            Some(l) => (l.width, l.height),
            None => return,
        };
        let mut replacements = Vec::new();
        for y in 0..height {
            for x in 0..width {
                if self.get_tile(layer, x, y) == 0 {
                    continue;
                }
                let mask = self.compute_bitmask_8(layer, x, y, width, height);
                if let Some(new_gid) = self.lookup_autotile_8(type_name, mask) {
                    replacements.push((x, y, new_gid));
                }
            }
        }
        for (x, y, gid) in replacements {
            self.set_tile(layer, x, y, gid);
        }
    }
    /// Apply 8-neighbour autotile substitution to the 3×3 neighbourhood around `(x, y)` only.
    pub fn apply_autotile_8_at(&mut self, layer: usize, x: u32, y: u32, type_name: &str) {
        let (width, height) = match self.layers.get(layer) {
            Some(l) => (l.width, l.height),
            None => return,
        };
        if width == 0 || height == 0 {
            return;
        }
        let mut replacements = Vec::new();
        let x_start = x.saturating_sub(1);
        let y_start = y.saturating_sub(1);
        let x_end = (x + 1).min(width - 1);
        let y_end = (y + 1).min(height - 1);
        for ny in y_start..=y_end {
            for nx in x_start..=x_end {
                if self.get_tile(layer, nx, ny) == 0 {
                    continue;
                }
                let mask = self.compute_bitmask_8(layer, nx, ny, width, height);
                if let Some(new_gid) = self.lookup_autotile_8(type_name, mask) {
                    replacements.push((nx, ny, new_gid));
                }
            }
        }
        for (x, y, gid) in replacements {
            self.set_tile(layer, x, y, gid);
        }
    }
    /// Apply autotile substitution using the matching strategy configured on the tileset for `type_name`.
    pub fn apply_autotile_mode(&mut self, layer: usize, type_name: &str) {
        match self.lookup_autotile_mode(type_name) {
            AutoTileMode::MatchSides => self.apply_autotile(layer, type_name),
            AutoTileMode::MatchCorners => self.apply_autotile_corners(layer, type_name),
            AutoTileMode::MatchCornersAndSides => self.apply_autotile_8(layer, type_name),
        }
    }

    /// Apply configured-strategy autotile substitution to the 3x3 neighbourhood around `(x, y)` only.
    pub fn apply_autotile_mode_at(&mut self, layer: usize, x: u32, y: u32, type_name: &str) {
        match self.lookup_autotile_mode(type_name) {
            AutoTileMode::MatchSides => self.apply_autotile_at(layer, x, y, type_name),
            AutoTileMode::MatchCorners => self.apply_autotile_corners_at(layer, x, y, type_name),
            AutoTileMode::MatchCornersAndSides => self.apply_autotile_8_at(layer, x, y, type_name),
        }
    }

    /// Apply corner-only autotile GID substitution to all non-empty tiles in `layer`.
    fn apply_autotile_corners(&mut self, layer: usize, type_name: &str) {
        let (width, height) = match self.layers.get(layer) {
            Some(l) => (l.width, l.height),
            None => return,
        };
        let mut replacements = Vec::new();
        for y in 0..height {
            for x in 0..width {
                if self.get_tile(layer, x, y) == 0 {
                    continue;
                }
                let mask = self.compute_bitmask_corners(layer, x, y, width, height);
                if let Some(new_gid) = self.lookup_autotile_4(type_name, mask) {
                    replacements.push((x, y, new_gid));
                }
            }
        }
        for (x, y, gid) in replacements {
            self.set_tile(layer, x, y, gid);
        }
    }

    /// Apply corner-only autotile substitution to the 3x3 neighbourhood around `(x, y)` only.
    fn apply_autotile_corners_at(&mut self, layer: usize, x: u32, y: u32, type_name: &str) {
        let (width, height) = match self.layers.get(layer) {
            Some(l) => (l.width, l.height),
            None => return,
        };
        if width == 0 || height == 0 {
            return;
        }
        let mut replacements = Vec::new();
        let x_start = x.saturating_sub(1);
        let y_start = y.saturating_sub(1);
        let x_end = (x + 1).min(width - 1);
        let y_end = (y + 1).min(height - 1);
        for ny in y_start..=y_end {
            for nx in x_start..=x_end {
                if self.get_tile(layer, nx, ny) == 0 {
                    continue;
                }
                let mask = self.compute_bitmask_corners(layer, nx, ny, width, height);
                if let Some(new_gid) = self.lookup_autotile_4(type_name, mask) {
                    replacements.push((nx, ny, new_gid));
                }
            }
        }
        for (x, y, gid) in replacements {
            self.set_tile(layer, x, y, gid);
        }
    }
    /// Compute the 4-bit cardinal-neighbour bitmask for `(x, y)` in `layer`; bits: N=1, E=2, S=4, W=8.
    fn compute_bitmask_4(&self, layer: usize, x: u32, y: u32, width: u32, height: u32) -> u8 {
        let mut mask = 0u8;
        if y > 0 && self.get_tile(layer, x, y - 1) != 0 {
            mask |= 1;
        }
        if x + 1 < width && self.get_tile(layer, x + 1, y) != 0 {
            mask |= 2;
        }
        if y + 1 < height && self.get_tile(layer, x, y + 1) != 0 {
            mask |= 4;
        }
        if x > 0 && self.get_tile(layer, x - 1, y) != 0 {
            mask |= 8;
        }
        mask
    }
    /// Compute the 8-bit full-neighbour bitmask for `(x, y)` in `layer`; cardinals=1..8, diagonals=16..128.
    fn compute_bitmask_8(&self, layer: usize, x: u32, y: u32, width: u32, height: u32) -> u16 {
        let n = y > 0 && self.get_tile(layer, x, y - 1) != 0;
        let e = x + 1 < width && self.get_tile(layer, x + 1, y) != 0;
        let s = y + 1 < height && self.get_tile(layer, x, y + 1) != 0;
        let w = x > 0 && self.get_tile(layer, x - 1, y) != 0;
        let mut mask: u16 = 0;
        if n {
            mask |= 1;
        }
        if e {
            mask |= 2;
        }
        if s {
            mask |= 4;
        }
        if w {
            mask |= 8;
        }
        if n && e && y > 0 && x + 1 < width && self.get_tile(layer, x + 1, y - 1) != 0 {
            mask |= 16;
        }
        if s && e && y + 1 < height && x + 1 < width && self.get_tile(layer, x + 1, y + 1) != 0 {
            mask |= 32;
        }
        if s && w && y + 1 < height && x > 0 && self.get_tile(layer, x - 1, y + 1) != 0 {
            mask |= 64;
        }
        if n && w && y > 0 && x > 0 && self.get_tile(layer, x - 1, y - 1) != 0 {
            mask |= 128;
        }
        mask
    }
    /// Compute the 4-bit corner-neighbour bitmask for `(x, y)`; bits: NE=1, SE=2, SW=4, NW=8.
    fn compute_bitmask_corners(&self, layer: usize, x: u32, y: u32, width: u32, height: u32) -> u8 {
        let mut mask = 0u8;
        if y > 0 && x + 1 < width && self.get_tile(layer, x + 1, y - 1) != 0 {
            mask |= 1;
        }
        if y + 1 < height && x + 1 < width && self.get_tile(layer, x + 1, y + 1) != 0 {
            mask |= 2;
        }
        if y + 1 < height && x > 0 && self.get_tile(layer, x - 1, y + 1) != 0 {
            mask |= 4;
        }
        if y > 0 && x > 0 && self.get_tile(layer, x - 1, y - 1) != 0 {
            mask |= 8;
        }
        mask
    }
    /// Search all tilesets for a configured autotile mode for `type_name`; defaults to side matching.
    fn lookup_autotile_mode(&self, type_name: &str) -> AutoTileMode {
        for ts in &self.tilesets {
            if ts.has_auto_tile_mode(type_name) {
                return ts.get_auto_tile_mode(type_name);
            }
        }
        AutoTileMode::MatchSides
    }
    /// Search all tilesets for a 4-bit autotile match for `type_name` and `bitmask`; returns the global GID or `None`.
    fn lookup_autotile_4(&self, type_name: &str, bitmask: u8) -> Option<u32> {
        for ts in &self.tilesets {
            if let Some(local_id) = ts.get_auto_tile_id(type_name, bitmask) {
                return Some(ts.get_first_gid() + local_id);
            }
        }
        None
    }
    /// Search all tilesets for an 8-bit autotile match for `type_name` and `bitmask`; returns the global GID or `None`.
    fn lookup_autotile_8(&self, type_name: &str, bitmask: u16) -> Option<u32> {
        for ts in &self.tilesets {
            if let Some(local_id) = ts.get_auto_tile_id_8(type_name, bitmask) {
                return Some(ts.get_first_gid() + local_id);
            }
        }
        None
    }
}

fn validate_finite(value: f32, context: &'static str) -> Result<(), TileMapError> {
    if !value.is_finite() {
        return Err(TileMapError::NonFiniteFloat { context });
    }
    Ok(())
}

fn validate_finite_pair(x: f32, y: f32, context: &'static str) -> Result<(), TileMapError> {
    validate_finite(x, context)?;
    validate_finite(y, context)
}

fn validate_finite_rgba(values: [f32; 4]) -> Result<(), TileMapError> {
    for value in values {
        validate_finite(value, "tint")?;
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
