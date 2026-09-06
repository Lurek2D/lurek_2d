//! Registers the `lurek.tilemap` Lua API for tilemap userdata, imports, one-based coordinates, and validation.

use super::render_api::{ensure_shader_target, shader_key_from_userdata, LuaShader};
use super::tilefield_api::{field_from_provider, LuaTileField};
use super::tileset_api::{tileset_from_provider, LuaTileCatalog, LuaTileSet};
use super::SharedState;
use crate::render::renderer::RenderCommand;
use crate::render::ShaderTarget;
use crate::tilemap::autotile_sheet::{
    layout_from_name, layout_name, supported_layouts, AutoTileSheet,
};
use crate::tilemap::chunk::{ChunkMap, PreparedChunkBatch};
use crate::tilemap::coords;
use crate::tilemap::isomap::IsoMap;
use crate::tilemap::large_map_renderer::LargeMapRenderer;
use crate::tilemap::ldtk::load_ldtk_with_limits;
use crate::tilemap::orientation::MapOrientation;
use crate::tilemap::render::TileFieldSlotRenderOptions;
use crate::tilemap::tilemap::TileMap;
use crate::tilemap::tmx::{load_tmx_with_options, TmxLayer, TmxLoadOptions, TmxMap};
use crate::tilemap::{
    TileMapDiagnosticsSnapshot, TileMapLimits, TiledObjectShape, TiledPropertyValue,
};
use crate::tileset::{TileCatalog, TileSet};
use mlua::prelude::*;
use std::cell::RefCell;
use std::path::PathBuf;
use std::rc::Rc;
/// Converts a one-based Lua index into a zero-based `usize` tile index.
fn one_based_usize(name: &str, val: usize) -> LuaResult<usize> {
    val.checked_sub(1)
        .ok_or_else(|| mlua::Error::RuntimeError(format!("{name} must be >= 1 (got {val})")))
}
/// Converts a one-based Lua index into a zero-based `u32` tile index.
fn one_based_u32(name: &str, val: u32) -> LuaResult<u32> {
    val.checked_sub(1)
        .ok_or_else(|| mlua::Error::RuntimeError(format!("{name} must be >= 1 (got {val})")))
}

fn tilemap_import_error_table<'lua>(
    lua: &'lua Lua,
    format_name: &str,
    code: &str,
    message: &str,
    line: Option<u32>,
    column: Option<u32>,
) -> LuaResult<LuaTable<'lua>> {
    let err = lua.create_table()?;
    err.set("format", format_name)?;
    err.set("code", code)?;
    err.set("message", message)?;
    err.set("line", line)?;
    err.set("column", column)?;
    Ok(err)
}

fn extend_tilemap_render_commands(st: &mut SharedState, commands: Vec<RenderCommand>) {
    let previous_shader = st.active_shader;
    let changed_shader = commands
        .iter()
        .any(|command| matches!(command, RenderCommand::SetShader(_)));
    st.render_commands.extend(commands);
    if changed_shader {
        if let Some(shader_key) = previous_shader {
            st.render_commands
                .push(RenderCommand::SetShader(Some(shader_key)));
        }
    }
}

fn tilemap_limits_from_table(opts: Option<&LuaTable>) -> LuaResult<TileMapLimits> {
    let mut limits = TileMapLimits::default();
    let Some(opts) = opts else {
        return Ok(limits);
    };
    limits.max_layers = opts
        .get::<_, Option<usize>>("maxLayers")?
        .unwrap_or(limits.max_layers);
    limits.max_tiles_per_layer = opts
        .get::<_, Option<u64>>("maxTiles")?
        .unwrap_or(limits.max_tiles_per_layer);
    limits.max_import_bytes = opts
        .get::<_, Option<usize>>("maxImportBytes")?
        .unwrap_or(limits.max_import_bytes);
    limits.max_decoded_bytes = opts
        .get::<_, Option<usize>>("maxDecodedBytes")?
        .unwrap_or(limits.max_decoded_bytes);
    limits.max_chunk_cells = opts
        .get::<_, Option<u64>>("maxChunkCells")?
        .unwrap_or(limits.max_chunk_cells);
    limits.max_chunks = opts
        .get::<_, Option<usize>>("maxChunks")?
        .unwrap_or(limits.max_chunks);
    limits.max_tile_operation_cells = opts
        .get::<_, Option<u64>>("maxTileOperationCells")?
        .unwrap_or(limits.max_tile_operation_cells);
    limits.max_objects = opts
        .get::<_, Option<usize>>("maxObjects")?
        .unwrap_or(limits.max_objects);
    limits.max_points_per_object = opts
        .get::<_, Option<usize>>("maxPointsPerObject")?
        .unwrap_or(limits.max_points_per_object);
    limits.max_total_object_points = opts
        .get::<_, Option<usize>>("maxTotalObjectPoints")?
        .unwrap_or(limits.max_total_object_points);
    limits
        .validate()
        .map_err(|err| LuaError::RuntimeError(format!("lurek.tilemap.limits: {err}")))?;
    Ok(limits)
}

fn finite_lua(value: f32, api: &str) -> LuaResult<()> {
    if !value.is_finite() {
        return Err(LuaError::RuntimeError(format!(
            "{api}: numeric input must be finite"
        )));
    }
    Ok(())
}

fn positive_lua(value: f32, api: &str) -> LuaResult<()> {
    finite_lua(value, api)?;
    if value <= 0.0 {
        return Err(LuaError::RuntimeError(format!(
            "{api}: numeric input must be > 0"
        )));
    }
    Ok(())
}

fn finite_values_lua(values: &[f32], api: &str) -> LuaResult<()> {
    for value in values {
        finite_lua(*value, api)?;
    }
    Ok(())
}

fn create_auto_tile_sheet<'lua>(
    lua: &'lua Lua,
    tile_w: u32,
    tile_h: u32,
    layout_str: &str,
) -> LuaResult<LuaAnyUserData<'lua>> {
    let layout = layout_from_name(layout_str).ok_or_else(|| {
        LuaError::RuntimeError(format!(
            "newAutoTileSheet: unknown layout '{}', use 'blob47', 'composite48', 'rpgmaker48', or 'minimal16'",
            layout_str
        ))
    })?;
    lua.create_userdata(LuaAutoTileSheet {
        inner: Rc::new(RefCell::new(AutoTileSheet::new(tile_w, tile_h, layout))),
    })
}

fn auto_tile_formats_table<'lua>(lua: &'lua Lua) -> LuaResult<LuaTable<'lua>> {
    let outer = lua.create_table()?;
    for (idx, (layout, tile_count)) in supported_layouts().iter().enumerate() {
        let entry = lua.create_table()?;
        entry.set("name", layout_name(*layout))?;
        entry.set("tileCount", *tile_count)?;
        entry.set(
            "mode",
            crate::tilemap::autotile_sheet::default_mode_for_layout(*layout).as_str(),
        )?;
        outer.set(idx + 1, entry)?;
    }
    Ok(outer)
}

fn tmx_map_table<'lua>(lua: &'lua Lua, tmx: &TmxMap) -> LuaResult<LuaTable<'lua>> {
    let result = lua.create_table()?;
    result.set("width", tmx.width)?;
    result.set("height", tmx.height)?;
    result.set("tileWidth", tmx.tile_width)?;
    result.set("tileHeight", tmx.tile_height)?;
    let orient_str = match tmx.orientation {
        crate::tilemap::tmx::TmxOrientation::Orthogonal => "orthogonal",
        crate::tilemap::tmx::TmxOrientation::Isometric => "isometric",
        crate::tilemap::tmx::TmxOrientation::Staggered => "staggered",
        crate::tilemap::tmx::TmxOrientation::Hexagonal => "hexagonal",
    };
    result.set("orientation", orient_str)?;
    let layers_tbl = lua.create_table()?;
    for (layer_idx, layer) in tmx.layers.iter().enumerate() {
        let entry = lua.create_table()?;
        match layer {
            TmxLayer::Tile(tile) => {
                entry.set("type", "tile")?;
                entry.set("name", tile.name.as_str())?;
                entry.set("width", tile.width)?;
                entry.set("height", tile.height)?;
            }
            TmxLayer::Object(object) => {
                entry.set("type", "object")?;
                entry.set("name", object.name.as_str())?;
                entry.set("visible", object.visible)?;
                entry.set("offsetX", object.offset_x)?;
                entry.set("offsetY", object.offset_y)?;
                let objects = lua.create_table()?;
                for (object_idx, object) in object.objects.iter().enumerate() {
                    let object_tbl = lua.create_table()?;
                    object_tbl.set("id", object.id)?;
                    object_tbl.set("name", object.name.as_str())?;
                    object_tbl.set("type", object.obj_type.as_str())?;
                    object_tbl.set("x", object.x)?;
                    object_tbl.set("y", object.y)?;
                    object_tbl.set("width", object.width)?;
                    object_tbl.set("height", object.height)?;
                    object_tbl.set("gid", object.gid)?;
                    object_tbl.set("rotation", object.rotation)?;
                    match &object.shape {
                        TiledObjectShape::Point => {
                            object_tbl.set("shape", "point")?;
                            object_tbl.set("point", true)?;
                        }
                        TiledObjectShape::Polygon(points) => {
                            object_tbl.set("shape", "polygon")?;
                            let points_tbl = lua.create_table()?;
                            for (point_idx, point) in points.iter().enumerate() {
                                let point_tbl = lua.create_table()?;
                                point_tbl.set("x", point.x)?;
                                point_tbl.set("y", point.y)?;
                                point_tbl.set(1, point.x)?;
                                point_tbl.set(2, point.y)?;
                                points_tbl.set(point_idx + 1, point_tbl)?;
                            }
                            object_tbl.set("polygon", points_tbl)?;
                        }
                        TiledObjectShape::Unsupported => {
                            object_tbl.set("shape", "unsupported")?;
                        }
                    }
                    let properties = lua.create_table()?;
                    for (name, value) in &object.properties {
                        properties.set(name.as_str(), tiled_property_to_lua(lua, value)?)?;
                    }
                    object_tbl.set("properties", properties)?;
                    objects.set(object_idx + 1, object_tbl)?;
                }
                entry.set("objects", objects)?;
            }
        }
        layers_tbl.set(layer_idx + 1, entry)?;
    }
    result.set("layers", layers_tbl)?;
    Ok(result)
}

fn tiled_property_to_lua<'lua>(
    lua: &'lua Lua,
    value: &TiledPropertyValue,
) -> LuaResult<LuaValue<'lua>> {
    match value {
        TiledPropertyValue::String(value)
        | TiledPropertyValue::Color(value)
        | TiledPropertyValue::File(value) => Ok(LuaValue::String(lua.create_string(value)?)),
        TiledPropertyValue::Int(value) => Ok(LuaValue::Integer(*value)),
        TiledPropertyValue::Float(value) => Ok(LuaValue::Number(*value)),
        TiledPropertyValue::Bool(value) => Ok(LuaValue::Boolean(*value)),
        TiledPropertyValue::Object(value) => Ok(LuaValue::Integer(i64::from(*value))),
    }
}

fn load_ldtk_lua<'lua>(
    lua: &'lua Lua,
    json_str: &str,
    level_name: Option<&str>,
    opts: Option<&LuaTable<'lua>>,
    state: &Rc<RefCell<SharedState>>,
) -> LuaResult<(LuaValue<'lua>, LuaValue<'lua>)> {
    let limits = tilemap_limits_from_table(opts)?;
    match load_ldtk_with_limits(json_str, level_name, &limits) {
        Ok(map) => {
            let ud = lua.create_userdata(LuaTileMap {
                inner: Rc::new(RefCell::new(map)),
                state: state.clone(),
            })?;
            Ok((LuaValue::UserData(ud), LuaValue::Nil))
        }
        Err(err) => {
            let err_tbl =
                tilemap_import_error_table(lua, "ldtk", err.code, &err.message, None, None)?;
            Ok((LuaValue::Nil, LuaValue::Table(err_tbl)))
        }
    }
}

fn chunk_pairs_to_lua<'lua>(lua: &'lua Lua, chunks: Vec<(i32, i32)>) -> LuaResult<LuaTable<'lua>> {
    let tbl = lua.create_table()?;
    for (i, (cx, cy)) in chunks.iter().enumerate() {
        let entry = lua.create_table()?;
        entry.set(1, *cx)?;
        entry.set(2, *cy)?;
        entry.set("cx", *cx)?;
        entry.set("cy", *cy)?;
        tbl.set(i + 1, entry)?;
    }
    Ok(tbl)
}

fn provider_u32(provider: &LuaTable, name: &str, api: &str) -> LuaResult<u32> {
    provider
        .get::<_, Option<u32>>(name)?
        .ok_or_else(|| LuaError::RuntimeError(format!("{api}: provider.{name} is required")))
}

struct TileMapLuaProvider;

impl TileMapLuaProvider {
    fn tilemap_from_provider(
        provider: LuaTable,
        limits: TileMapLimits,
        api: &str,
    ) -> LuaResult<TileMap> {
        let tile_width = provider_u32(&provider, "tileWidth", api)?;
        let tile_height = provider_u32(&provider, "tileHeight", api)?;
        let chunk_size = provider.get::<_, Option<u32>>("chunkSize")?.unwrap_or(16);
        let mut map = TileMap::try_new_with_limits(tile_width, tile_height, chunk_size, limits)
            .map_err(|err| LuaError::RuntimeError(format!("{api}: {err}")))?;
        if let Ok(tilesets) = provider.get::<_, LuaTable>("tilesets") {
            for tileset in tilesets.sequence_values::<LuaValue>() {
                let tileset = tileset_from_value(tileset?, api)?;
                map.add_tileset(tileset.borrow().clone());
            }
        }
        let layers = provider
            .get::<_, Option<LuaTable>>("layers")?
            .ok_or_else(|| LuaError::RuntimeError(format!("{api}: provider.layers is required")))?;
        let provider_get_tile = provider.get::<_, Option<LuaFunction>>("getTile")?;
        for layer_pair in layers.sequence_values::<LuaTable>() {
            let layer = layer_pair?;
            let layer_number = map.get_layer_count() + 1;
            let name = layer
                .get::<_, Option<String>>("name")?
                .unwrap_or_else(|| format!("layer{layer_number}"));
            let width = layer
                .get::<_, Option<u32>>("width")?
                .or_else(|| provider.get::<_, Option<u32>>("width").ok().flatten())
                .ok_or_else(|| LuaError::RuntimeError(format!("{api}: layer.width is required")))?;
            let height = layer
                .get::<_, Option<u32>>("height")?
                .or_else(|| provider.get::<_, Option<u32>>("height").ok().flatten())
                .ok_or_else(|| {
                    LuaError::RuntimeError(format!("{api}: layer.height is required"))
                })?;
            let layer_index = map
                .try_add_layer(&name, width, height)
                .map_err(|err| LuaError::RuntimeError(format!("{api}: {err}")))?;
            if let Some(visible) = layer.get::<_, Option<bool>>("visible")? {
                map.set_layer_visible(layer_index, visible);
            }
            if let Ok(color) = layer.get::<_, LuaTable>("color") {
                let r = color.get::<_, Option<f32>>("r")?.unwrap_or(1.0);
                let g = color.get::<_, Option<f32>>("g")?.unwrap_or(1.0);
                let b = color.get::<_, Option<f32>>("b")?.unwrap_or(1.0);
                let a = color.get::<_, Option<f32>>("a")?.unwrap_or(1.0);
                map.try_set_layer_color(layer_index, r, g, b, a)
                    .map_err(|err| LuaError::RuntimeError(format!("{api}: {err}")))?;
            }
            if let Ok(tiles) = layer.get::<_, LuaTable>("tiles") {
                let mut idx = 1usize;
                for y in 0..height {
                    for x in 0..width {
                        let gid = tiles.get::<_, Option<u32>>(idx)?.unwrap_or(0);
                        map.set_tile(layer_index, x, y, gid);
                        idx += 1;
                    }
                }
            } else if let Some(layer_get_tile) = layer.get::<_, Option<LuaFunction>>("getTile")? {
                for y in 0..height {
                    for x in 0..width {
                        let gid: u32 = layer_get_tile.call((layer.clone(), x + 1, y + 1))?;
                        map.set_tile(layer_index, x, y, gid);
                    }
                }
            } else if let Some(provider_get_tile) = &provider_get_tile {
                for y in 0..height {
                    for x in 0..width {
                        let layer_number = u32::try_from(layer_index + 1).map_err(|_| {
                            LuaError::RuntimeError(format!("{api}: layer index overflow"))
                        })?;
                        let gid: u32 = provider_get_tile.call((
                            provider.clone(),
                            layer_number,
                            x + 1,
                            y + 1,
                        ))?;
                        map.set_tile(layer_index, x, y, gid);
                    }
                }
            }
        }
        Ok(map)
    }
}

fn tilemap_from_provider(
    provider: LuaTable,
    limits: TileMapLimits,
    api: &str,
) -> LuaResult<TileMap> {
    TileMapLuaProvider::tilemap_from_provider(provider, limits, api)
}

fn tilefield_from_value(
    value: LuaValue,
    api: &str,
) -> LuaResult<Rc<RefCell<crate::tilefield::TileField>>> {
    match value {
        LuaValue::UserData(field_ud) => {
            let field = field_ud.borrow::<LuaTileField>()?;
            Ok(field.inner.clone())
        }
        LuaValue::Table(provider) => Ok(Rc::new(RefCell::new(field_from_provider(provider, api)?))),
        other => Err(LuaError::RuntimeError(format!(
            "{api}: expected LTileField or provider table, got {}",
            other.type_name()
        ))),
    }
}

fn tileset_from_value(value: LuaValue, api: &str) -> LuaResult<Rc<RefCell<TileSet>>> {
    match value {
        LuaValue::UserData(tileset_ud) => {
            let tileset = tileset_ud.borrow::<LuaTileSet>()?;
            Ok(tileset.inner.clone())
        }
        LuaValue::Table(provider) => {
            Ok(Rc::new(RefCell::new(tileset_from_provider(provider, api)?)))
        }
        other => Err(LuaError::RuntimeError(format!(
            "{api}: expected LTileSet or provider table, got {}",
            other.type_name()
        ))),
    }
}

fn catalog_from_value(value: LuaValue, api: &str) -> LuaResult<Rc<RefCell<TileCatalog>>> {
    match value {
        LuaValue::UserData(catalog_ud) => {
            let catalog = catalog_ud.borrow::<LuaTileCatalog>()?;
            Ok(catalog.inner.clone())
        }
        other => Err(LuaError::RuntimeError(format!(
            "{api}: expected LTileCatalog, got {}",
            other.type_name()
        ))),
    }
}

fn tmx_options_from_table(opts: Option<&LuaTable>) -> LuaResult<TmxLoadOptions> {
    let mut options = TmxLoadOptions::default();
    if let Some(opts) = opts {
        options.strict_layer_size = opts
            .get::<_, Option<bool>>("strictLayerSize")?
            .unwrap_or(options.strict_layer_size);
        options.allow_external_tilesets = opts
            .get::<_, Option<bool>>("allowExternalTilesets")?
            .unwrap_or(options.allow_external_tilesets);
        options.safe_paths = opts
            .get::<_, Option<bool>>("safePaths")?
            .unwrap_or(options.safe_paths);
        options.asset_root = opts
            .get::<_, Option<String>>("assetRoot")?
            .map(PathBuf::from);
        options.limits = tilemap_limits_from_table(Some(opts))?;
    }
    Ok(options)
}

fn diagnostics_table(
    lua: &Lua,
    diagnostics: TileMapDiagnosticsSnapshot,
) -> LuaResult<LuaTable<'_>> {
    let tbl = lua.create_table()?;
    /// @field | invalidLayer | integer | Number of rejected layer indices.
    tbl.set("invalidLayer", diagnostics.invalid_layer)?;
    /// @field | invalidCoord | integer | Number of rejected tile coordinates.
    tbl.set("invalidCoord", diagnostics.invalid_coord)?;
    /// @field | unknownGid | integer | Number of tile lookups for unknown global IDs.
    tbl.set("unknownGid", diagnostics.unknown_gid)?;
    /// @field | invalidQueries | integer | Number of rejected spatial queries.
    tbl.set("invalidQueries", diagnostics.invalid_queries)?;
    /// @field | lazyIndexRebuilds | integer | Number of reverse-index rebuilds.
    tbl.set("lazyIndexRebuilds", diagnostics.lazy_index_rebuilds)?;
    Ok(tbl)
}
/// Lua-side handle wrapping a `TileMap` with layers, tile data, viewports, auto-tiling, and render command output.
pub struct LuaTileMap {
    pub(crate) inner: Rc<RefCell<TileMap>>,
    state: Rc<RefCell<SharedState>>,
}
impl LuaUserData for LuaTileMap {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- addTileSet --
        /// Attaches a tileset to this map for tile rendering.
        /// @param | tileSet | LTileSet | Tileset to add.
        methods.add_method("addTileSet", |_, this, ts_ud: LuaAnyUserData| {
            let ts = ts_ud.borrow::<LuaTileSet>()?;
            this.inner
                .borrow_mut()
                .add_tileset(ts.inner.borrow().clone());
            Ok(())
        });
        // -- getTileSetCount --
        /// Returns how many tilesets are attached to this map.
        /// @return | integer | Tileset count.
        methods.add_method("getTileSetCount", |_, this, ()| {
            Ok(this.inner.borrow().get_tileset_count())
        });
        // -- getTileSet --
        /// Returns the tileset at the given index.
        /// @param | idx | integer | Tileset index (1-based).
        /// @return | LTileSet | The tileset, or nil if index is out of range.
        methods.add_method("getTileSet", |_, this, idx: usize| {
            let idx = one_based_usize("getTileSet idx", idx)?;
            let inner = this.inner.borrow();
            match inner.get_tileset(idx) {
                Some(ts) => Ok(Some(LuaTileSet {
                    inner: Rc::new(RefCell::new(ts.clone())),
                })),
                None => Ok(None),
            }
        });
        // -- addLayer --
        /// Creates a new tile layer with the given name and dimensions.
        /// @param | name | string | Layer name.
        /// @param | w | integer | Width in tiles.
        /// @param | h | integer | Height in tiles.
        /// @return | integer | Index of the new layer (1-based).
        methods.add_method("addLayer", |_, this, (name, w, h): (String, u32, u32)| {
            let idx = this
                .inner
                .borrow_mut()
                .try_add_layer(&name, w, h)
                .map_err(|err| LuaError::RuntimeError(format!("LTileMap:addLayer: {err}")))?;
            Ok(idx + 1)
        });
        // -- tryAddLayer --
        /// Creates a new tile layer and returns `nil, error` instead of throwing on invalid dimensions or layer limits.
        /// @param | name | string | Layer name.
        /// @param | w | integer | Width in tiles.
        /// @param | h | integer | Height in tiles.
        /// @return | integer | Index of the new layer (1-based).
        /// @return | string | Error message when validation fails.
        methods.add_method(
            "tryAddLayer",
            |_, this, (name, w, h): (String, u32, u32)| match this
                .inner
                .borrow_mut()
                .try_add_layer(&name, w, h)
            {
                Ok(idx) => Ok((Some(idx + 1), None::<String>)),
                Err(err) => Ok((None::<usize>, Some(err.to_string()))),
            },
        );
        // -- getLayerCount --
        /// Returns the total number of layers in this map.
        /// @return | integer | Layer count.
        methods.add_method("getLayerCount", |_, this, ()| {
            Ok(this.inner.borrow().get_layer_count())
        });
        // -- getLayerName --
        /// Returns the name of a layer by index.
        /// @param | idx | integer | Layer index (1-based).
        /// @return | string | Layer name, or nil if index is out of range.
        methods.add_method("getLayerName", |_, this, idx: usize| {
            let idx = one_based_usize("getLayerName idx", idx)?;
            Ok(this
                .inner
                .borrow()
                .get_layer_name(idx)
                .map(|s| s.to_string()))
        });
        // -- setLayerVisible --
        /// Sets whether a layer is drawn during rendering.
        /// @param | idx | integer | Layer index (1-based).
        /// @param | visible | boolean | True to show, false to hide.
        methods.add_method(
            "setLayerVisible",
            |_, this, (idx, visible): (usize, bool)| {
                let idx = one_based_usize("setLayerVisible idx", idx)?;
                this.inner
                    .borrow_mut()
                    .try_set_layer_visible(idx, visible)
                    .map_err(|err| {
                        LuaError::RuntimeError(format!("LTileMap:setLayerVisible: {err}"))
                    })?;
                Ok(())
            },
        );
        // -- getLayerVisible --
        /// Returns whether a layer is currently visible.
        /// @param | idx | integer | Layer index (1-based).
        /// @return | boolean | True if the layer is visible.
        methods.add_method("getLayerVisible", |_, this, idx: usize| {
            let idx = one_based_usize("getLayerVisible idx", idx)?;
            Ok(this.inner.borrow().get_layer_visible(idx))
        });
        // -- setLayerColor --
        /// Sets the tint color for an entire layer.
        /// @param | idx | integer | Layer index (1-based).
        /// @param | r | number | Red channel (0..1).
        /// @param | g | number | Green channel (0..1).
        /// @param | b | number | Blue channel (0..1).
        /// @param | a | number | Alpha channel (0..1).
        methods.add_method(
            "setLayerColor",
            |_, this, (idx, r, g, b, a): (usize, f32, f32, f32, f32)| {
                let idx = one_based_usize("setLayerColor idx", idx)?;
                finite_values_lua(&[r, g, b, a], "LTileMap:setLayerColor")?;
                this.inner
                    .borrow_mut()
                    .try_set_layer_color(idx, r, g, b, a)
                    .map_err(|err| {
                        LuaError::RuntimeError(format!("LTileMap:setLayerColor: {err}"))
                    })?;
                Ok(())
            },
        );
        // -- getLayerColor --
        /// Returns the tint color of a layer as four RGBA components.
        /// @param | idx | integer | Layer index (1-based).
        /// @return | number | Red (0..1).
        /// @return | number | Green (0..1).
        /// @return | number | Blue (0..1).
        /// @return | number | Alpha (0..1).
        methods.add_method("getLayerColor", |_, this, idx: usize| {
            let idx = one_based_usize("getLayerColor idx", idx)?;
            let c = this.inner.borrow().get_layer_color(idx);
            Ok((c[0], c[1], c[2], c[3]))
        });
        // -- setLayerOffset --
        /// Sets the pixel offset for a layer, shifting all tiles during rendering.
        /// @param | idx | integer | Layer index (1-based).
        /// @param | ox | number | Horizontal offset in pixels.
        /// @param | oy | number | Vertical offset in pixels.
        methods.add_method(
            "setLayerOffset",
            |_, this, (idx, ox, oy): (usize, f32, f32)| {
                let idx = one_based_usize("setLayerOffset idx", idx)?;
                finite_values_lua(&[ox, oy], "LTileMap:setLayerOffset")?;
                this.inner
                    .borrow_mut()
                    .try_set_layer_offset(idx, ox, oy)
                    .map_err(|err| {
                        LuaError::RuntimeError(format!("LTileMap:setLayerOffset: {err}"))
                    })?;
                Ok(())
            },
        );
        // -- getLayerOffset --
        /// Returns the pixel offset of a layer.
        /// @param | idx | integer | Layer index (1-based).
        /// @return | number | Horizontal offset.
        /// @return | number | Vertical offset.
        methods.add_method("getLayerOffset", |_, this, idx: usize| {
            let idx = one_based_usize("getLayerOffset idx", idx)?;
            let v = this.inner.borrow().get_layer_offset(idx);
            Ok((v.x, v.y))
        });
        // -- setLayerParallax --
        /// Sets the parallax scroll factor for a layer. Values less than 1 scroll slower than the camera.
        /// @param | idx | integer | Layer index (1-based).
        /// @param | px | number | Horizontal parallax factor.
        /// @param | py | number | Vertical parallax factor.
        methods.add_method(
            "setLayerParallax",
            |_, this, (idx, px, py): (usize, f32, f32)| {
                let idx = one_based_usize("setLayerParallax idx", idx)?;
                finite_values_lua(&[px, py], "LTileMap:setLayerParallax")?;
                this.inner
                    .borrow_mut()
                    .try_set_layer_parallax(idx, px, py)
                    .map_err(|err| {
                        LuaError::RuntimeError(format!("LTileMap:setLayerParallax: {err}"))
                    })?;
                Ok(())
            },
        );
        // -- getLayerParallax --
        /// Returns the parallax scroll factor of a layer.
        /// @param | idx | integer | Layer index (1-based).
        /// @return | number | Horizontal parallax factor.
        /// @return | number | Vertical parallax factor.
        methods.add_method("getLayerParallax", |_, this, idx: usize| {
            let idx = one_based_usize("getLayerParallax idx", idx)?;
            let v = this.inner.borrow().get_layer_parallax(idx);
            Ok((v.x, v.y))
        });
        // -- setTile --
        /// Sets the tile GID at a specific grid position on a layer.
        /// @param | layer | integer | Layer index (1-based).
        /// @param | x | integer | Column (1-based).
        /// @param | y | integer | Row (1-based).
        /// @param | gid | integer | Global tile ID to place.
        methods.add_method(
            "setTile",
            |_, this, (layer, x, y, gid): (usize, u32, u32, u32)| {
                let layer = one_based_usize("setTile layer", layer)?;
                let x = one_based_u32("setTile x", x)?;
                let y = one_based_u32("setTile y", y)?;
                this.inner
                    .borrow_mut()
                    .try_set_tile(layer, x, y, gid)
                    .map_err(|err| LuaError::RuntimeError(format!("LTileMap:setTile: {err}")))?;
                Ok(())
            },
        );
        // -- trySetTile --
        /// Sets a tile and returns `false, error` instead of throwing on invalid layer or coordinate input.
        /// @param | layer | integer | Layer index (1-based).
        /// @param | x | integer | Column (1-based).
        /// @param | y | integer | Row (1-based).
        /// @param | gid | integer | Global tile ID to place.
        /// @return | boolean | True on success.
        /// @return | string | Error message on failure.
        methods.add_method(
            "trySetTile",
            |_, this, (layer, x, y, gid): (usize, u32, u32, u32)| match this
                .inner
                .borrow_mut()
                .try_set_tile(
                    one_based_usize("trySetTile layer", layer)?,
                    one_based_u32("trySetTile x", x)?,
                    one_based_u32("trySetTile y", y)?,
                    gid,
                ) {
                Ok(()) => Ok((true, None::<String>)),
                Err(err) => Ok((false, Some(err.to_string()))),
            },
        );
        // -- getTile --
        /// Returns the tile GID at a specific grid position on a layer.
        /// @param | layer | integer | Layer index (1-based).
        /// @param | x | integer | Column (1-based).
        /// @param | y | integer | Row (1-based).
        /// @return | integer | Global tile ID at that position.
        methods.add_method("getTile", |_, this, (layer, x, y): (usize, u32, u32)| {
            let layer = one_based_usize("getTile layer", layer)?;
            let x = one_based_u32("getTile x", x)?;
            let y = one_based_u32("getTile y", y)?;
            Ok(this.inner.borrow().get_tile(layer, x, y))
        });
        // -- tryGetTile --
        /// Returns the tile GID at a specific grid position, or `nil, error` when the layer or coord is invalid.
        /// @param | layer | integer | Layer index (1-based).
        /// @param | x | integer | Column (1-based).
        /// @param | y | integer | Row (1-based).
        /// @return | integer | Global tile ID at that position.
        /// @return | string | Error message on failure.
        methods.add_method(
            "tryGetTile",
            |_, this, (layer, x, y): (usize, u32, u32)| match this.inner.borrow().try_get_tile(
                one_based_usize("tryGetTile layer", layer)?,
                one_based_u32("tryGetTile x", x)?,
                one_based_u32("tryGetTile y", y)?,
            ) {
                Ok(gid) => Ok((Some(gid), None::<String>)),
                Err(err) => Ok((None::<u32>, Some(err.to_string()))),
            },
        );
        // -- clearTile --
        /// Removes the tile at a specific grid position, setting it to empty (GID 0).
        /// @param | layer | integer | Layer index (1-based).
        /// @param | x | integer | Column (1-based).
        /// @param | y | integer | Row (1-based).
        methods.add_method("clearTile", |_, this, (layer, x, y): (usize, u32, u32)| {
            let layer = one_based_usize("clearTile layer", layer)?;
            let x = one_based_u32("clearTile x", x)?;
            let y = one_based_u32("clearTile y", y)?;
            this.inner.borrow_mut().clear_tile(layer, x, y);
            Ok(())
        });
        // -- fill --
        /// Fills every cell of a layer with the given GID.
        /// @param | layer | integer | Layer index (1-based).
        /// @param | gid | integer | Global tile ID to fill with.
        methods.add_method("fill", |_, this, (layer, gid): (usize, u32)| {
            let layer = one_based_usize("fill layer", layer)?;
            this.inner.borrow_mut().fill(layer, gid);
            Ok(())
        });
        // -- tileTypeIndex --
        /// Builds an index mapping each GID present on a layer to an array of `{x, y}` positions.
        /// @param | layer | integer | Layer index (1-based).
        /// @return | table | Table keyed by GID, each value an array of `{x=number, y=number}`.
        /// @field | x | number | X.
        /// @field | y | number | Y.
        methods.add_method("tileTypeIndex", |lua, this, layer: usize| {
            let layer = one_based_usize("tileTypeIndex layer", layer)?;
            let index = this.inner.borrow_mut().tile_type_index(layer);
            let result = lua.create_table()?;
            for (gid, positions) in index {
                let arr = lua.create_table()?;
                for (i, (x, y)) in positions.iter().enumerate() {
                    let pos = lua.create_table()?;
                    /// The 'x' field value exposed to Lua scripts.
                    pos.set("x", *x)?;
                    /// The 'y' field value exposed to Lua scripts.
                    pos.set("y", *y)?;
                    arr.set(i + 1, pos)?;
                }
                result.set(gid, arr)?;
            }
            Ok(result)
        });
        // -- findTilesByGid --
        /// Returns all positions on a layer that contain a specific GID.
        /// @param | layer | integer | Layer index (1-based).
        /// @param | gid | integer | Global tile ID to search for.
        /// @return | table | Array of `{x=number, y=number}` positions.
        /// @field | x | number | X.
        /// @field | y | number | Y.
        methods.add_method("findTilesByGid", |lua, this, (layer, gid): (usize, u32)| {
            let layer = one_based_usize("findTilesByGid layer", layer)?;
            let positions = this.inner.borrow_mut().find_tiles_by_gid(layer, gid);
            let arr = lua.create_table()?;
            for (i, (x, y)) in positions.iter().enumerate() {
                let pos = lua.create_table()?;
                /// The 'x' field value exposed to Lua scripts.
                pos.set("x", *x)?;
                /// The 'y' field value exposed to Lua scripts.
                pos.set("y", *y)?;
                arr.set(i + 1, pos)?;
            }
            Ok(arr)
        });
        // -- setViewport --
        /// Sets the visible area of the map for culling during rendering.
        /// @param | x | number | Left edge in world pixels.
        /// @param | y | number | Top edge in world pixels.
        /// @param | w | number | Viewport width in pixels.
        /// @param | h | number | Viewport height in pixels.
        methods.add_method(
            "setViewport",
            |_, this, (x, y, w, h): (f32, f32, f32, f32)| {
                finite_values_lua(&[x, y], "LTileMap:setViewport")?;
                positive_lua(w, "LTileMap:setViewport width")?;
                positive_lua(h, "LTileMap:setViewport height")?;
                this.inner
                    .borrow_mut()
                    .try_set_viewport(x, y, w, h)
                    .map_err(|err| {
                        LuaError::RuntimeError(format!("LTileMap:setViewport: {err}"))
                    })?;
                Ok(())
            },
        );
        // -- getViewport --
        /// Returns the current viewport rectangle, or nils if none is set.
        /// @return | number | Left edge.
        /// @return | number | Top edge.
        /// @return | number | Width.
        /// @return | number | Height.
        methods.add_method("getViewport", |_, this, ()| {
            match this.inner.borrow().get_viewport() {
                Some((x, y, w, h)) => Ok((Some(x), Some(y), Some(w), Some(h))),
                None => Ok((None, None, None, None)),
            }
        });
        // -- update --
        /// Advances tile animations by the given delta time.
        /// @param | dt | number | Time elapsed in seconds since last update.
        methods.add_method("update", |_, this, dt: f32| {
            finite_lua(dt, "LTileMap:update")?;
            this.inner
                .borrow_mut()
                .try_update(dt)
                .map_err(|err| LuaError::RuntimeError(format!("LTileMap:update: {err}")))?;
            Ok(())
        });
        // -- worldToTile --
        /// Converts world-space pixel coordinates to tile-grid coordinates.
        /// @param | wx | number | World X position in pixels.
        /// @param | wy | number | World Y position in pixels.
        /// @return | integer | Tile column (1-based).
        /// @return | integer | Tile row (1-based).
        methods.add_method("worldToTile", |_, this, (wx, wy): (f32, f32)| {
            finite_values_lua(&[wx, wy], "LTileMap:worldToTile")?;
            let (tx, ty) = this.inner.borrow().world_to_tile(wx, wy);
            Ok((tx + 1, ty + 1))
        });
        // -- tryWorldToTile --
        /// Converts world-space pixel coordinates to tile-grid coordinates, returning nils for negative or non-finite input.
        /// @param | wx | number | World X position in pixels.
        /// @param | wy | number | World Y position in pixels.
        /// @return | integer | Tile column (1-based).
        /// @return | integer | Tile row (1-based).
        methods.add_method("tryWorldToTile", |_, this, (wx, wy): (f32, f32)| {
            finite_values_lua(&[wx, wy], "LTileMap:tryWorldToTile")?;
            Ok(this
                .inner
                .borrow()
                .try_world_to_tile(wx, wy)
                .map(|(tx, ty)| (Some(tx + 1), Some(ty + 1)))
                .unwrap_or((None::<u32>, None::<u32>)))
        });
        // -- tileToWorld --
        /// Converts tile-grid coordinates to world-space pixel coordinates (top-left corner of the tile).
        /// @param | tx | integer | Tile column (1-based).
        /// @param | ty | integer | Tile row (1-based).
        /// @return | number | World X position in pixels.
        /// @return | number | World Y position in pixels.
        methods.add_method("tileToWorld", |_, this, (tx, ty): (u32, u32)| {
            let tx = one_based_u32("tileToWorld tx", tx)?;
            let ty = one_based_u32("tileToWorld ty", ty)?;
            let (wx, wy) = this.inner.borrow().tile_to_world(tx, ty);
            Ok((wx, wy))
        });
        // -- getTileWidth --
        /// Returns the width of a single tile in pixels for this map.
        /// @return | integer | Tile width in pixels.
        methods.add_method("getTileWidth", |_, this, ()| {
            Ok(this.inner.borrow().get_tile_width())
        });
        // -- getTileHeight --
        /// Returns the height of a single tile in pixels for this map.
        /// @return | integer | Tile height in pixels.
        methods.add_method("getTileHeight", |_, this, ()| {
            Ok(this.inner.borrow().get_tile_height())
        });
        // -- getTileDimensions --
        /// Returns both tile width and height in pixels.
        /// @return | integer | Tile width.
        /// @return | integer | Tile height.
        methods.add_method("getTileDimensions", |_, this, ()| {
            let (w, h) = this.inner.borrow().get_tile_dimensions();
            Ok((w, h))
        });
        // -- getChunkSize --
        /// Returns the chunk size used for internal tile storage.
        /// @return | integer | Chunk size in tiles per side.
        methods.add_method("getChunkSize", |_, this, ()| {
            Ok(this.inner.borrow().get_chunk_size())
        });
        // -- applyAutoTile --
        /// Runs 4-bit auto-tiling on an entire layer, replacing tiles according to registered rules.
        /// @param | layer | integer | Layer index (1-based).
        /// @param | typeName | string | Tile type name whose rules to apply.
        methods.add_method(
            "applyAutoTile",
            |_, this, (layer, type_name): (usize, String)| {
                let layer = one_based_usize("applyAutoTile layer", layer)?;
                this.inner.borrow_mut().apply_autotile(layer, &type_name);
                Ok(())
            },
        );
        // -- applyAutoTileAt --
        /// Runs 4-bit auto-tiling at a single tile position and updates it and its neighbors.
        /// @param | layer | integer | Layer index (1-based).
        /// @param | x | integer | Column (1-based).
        /// @param | y | integer | Row (1-based).
        /// @param | typeName | string | Tile type name whose rules to apply.
        methods.add_method(
            "applyAutoTileAt",
            |_, this, (layer, x, y, type_name): (usize, u32, u32, String)| {
                let layer = one_based_usize("applyAutoTileAt layer", layer)?;
                let x = one_based_u32("applyAutoTileAt x", x)?;
                let y = one_based_u32("applyAutoTileAt y", y)?;
                this.inner
                    .borrow_mut()
                    .apply_autotile_at(layer, x, y, &type_name);
                Ok(())
            },
        );
        // -- applyAutoTile8 --
        /// Runs 8-bit auto-tiling on an entire layer, considering diagonal neighbors.
        /// @param | layer | integer | Layer index (1-based).
        /// @param | typeName | string | Tile type name whose rules to apply.
        methods.add_method(
            "applyAutoTile8",
            |_, this, (layer, type_name): (usize, String)| {
                let layer = one_based_usize("applyAutoTile8 layer", layer)?;
                this.inner.borrow_mut().apply_autotile_8(layer, &type_name);
                Ok(())
            },
        );
        // -- applyAutoTile8At --
        /// Runs 8-bit auto-tiling at a single tile position and updates it and its neighbors.
        /// @param | layer | integer | Layer index (1-based).
        /// @param | x | integer | Column (1-based).
        /// @param | y | integer | Row (1-based).
        /// @param | typeName | string | Tile type name whose rules to apply.
        methods.add_method(
            "applyAutoTile8At",
            |_, this, (layer, x, y, type_name): (usize, u32, u32, String)| {
                let layer = one_based_usize("applyAutoTile8At layer", layer)?;
                let x = one_based_u32("applyAutoTile8At x", x)?;
                let y = one_based_u32("applyAutoTile8At y", y)?;
                this.inner
                    .borrow_mut()
                    .apply_autotile_8_at(layer, x, y, &type_name);
                Ok(())
            },
        );
        // -- applyAutoTileMode --
        /// Runs auto-tiling on an entire layer using the mode configured on the matching tileset.
        /// @param | layer | integer | Layer index (1-based).
        /// @param | typeName | string | Tile type name whose configured mode and rules to apply.
        methods.add_method(
            "applyAutoTileMode",
            |_, this, (layer, type_name): (usize, String)| {
                let layer = one_based_usize("applyAutoTileMode layer", layer)?;
                this.inner
                    .borrow_mut()
                    .apply_autotile_mode(layer, &type_name);
                Ok(())
            },
        );
        // -- applyAutoTileModeAt --
        /// Runs configured-mode auto-tiling at a single tile position and updates it and its neighbors.
        /// @param | layer | integer | Layer index (1-based).
        /// @param | x | integer | Column (1-based).
        /// @param | y | integer | Row (1-based).
        /// @param | typeName | string | Tile type name whose configured mode and rules to apply.
        methods.add_method(
            "applyAutoTileModeAt",
            |_, this, (layer, x, y, type_name): (usize, u32, u32, String)| {
                let layer = one_based_usize("applyAutoTileModeAt layer", layer)?;
                let x = one_based_u32("applyAutoTileModeAt x", x)?;
                let y = one_based_u32("applyAutoTileModeAt y", y)?;
                this.inner
                    .borrow_mut()
                    .apply_autotile_mode_at(layer, x, y, &type_name);
                Ok(())
            },
        );
        // -- getOrientation --
        /// Returns the current map orientation as a string.
        /// @return | string | One of `"topdown"`, `"sideview"`, `"isometric"`, `"hexagonal"`.
        methods.add_method("getOrientation", |_, this, ()| {
            let o = this.inner.borrow().get_orientation();
            Ok(match o {
                MapOrientation::TopDown => "topdown",
                MapOrientation::SideView => "sideview",
                MapOrientation::Isometric => "isometric",
                MapOrientation::Hexagonal => "hexagonal",
            })
        });
        // -- setOrientation --
        /// Sets the map orientation, affecting coordinate transforms and rendering.
        /// @param | orientation | string | One of `"topdown"`, `"sideview"`, `"isometric"`, `"hexagonal"`.
        methods.add_method("setOrientation", |_, this, orientation: String| {
            let o = match orientation.as_str() {
                "topdown" => MapOrientation::TopDown,
                "sideview" => MapOrientation::SideView,
                "isometric" => MapOrientation::Isometric,
                "hexagonal" => MapOrientation::Hexagonal,
                other => {
                    return Err(LuaError::RuntimeError(format!(
                    "setOrientation: unknown '{}' (valid: topdown, sideview, isometric, hexagonal)",
                    other
                )))
                }
            };
            this.inner.borrow_mut().set_orientation(o);
            Ok(())
        });
        // -- setTileTint --
        /// Overrides the color tint for a single tile at a given position.
        /// @param | layer | integer | Layer index (1-based).
        /// @param | x | integer | Column (1-based).
        /// @param | y | integer | Row (1-based).
        /// @param | r | number | Red channel (0..1).
        /// @param | g | number | Green channel (0..1).
        /// @param | b | number | Blue channel (0..1).
        /// @param | a | number | Alpha channel (0..1).
        methods.add_method(
            "setTileTint",
            |_, this, (layer, x, y, r, g, b, a): (usize, u32, u32, f32, f32, f32, f32)| {
                let layer = one_based_usize("setTileTint layer", layer)?;
                let x = one_based_u32("setTileTint x", x)?;
                let y = one_based_u32("setTileTint y", y)?;
                finite_values_lua(&[r, g, b, a], "LTileMap:setTileTint")?;
                this.inner
                    .borrow_mut()
                    .try_set_tile_tint(layer, x, y, r, g, b, a)
                    .map_err(|err| {
                        LuaError::RuntimeError(format!("LTileMap:setTileTint: {err}"))
                    })?;
                Ok(())
            },
        );
        // -- trySetTileTint --
        /// Sets a per-cell tint override and returns `false, error` instead of throwing on invalid input.
        /// @param | layer | integer | Layer index (1-based).
        /// @param | x | integer | Column (1-based).
        /// @param | y | integer | Row (1-based).
        /// @param | r | number | Red tint channel.
        /// @param | g | number | Green tint channel.
        /// @param | b | number | Blue tint channel.
        /// @param | a | number | Alpha tint channel.
        /// @return | boolean | True on success.
        /// @return | string | Error message on failure.
        methods.add_method(
            "trySetTileTint",
            |_, this, (layer, x, y, r, g, b, a): (usize, u32, u32, f32, f32, f32, f32)| match this
                .inner
                .borrow_mut()
                .try_set_tile_tint(
                    one_based_usize("trySetTileTint layer", layer)?,
                    one_based_u32("trySetTileTint x", x)?,
                    one_based_u32("trySetTileTint y", y)?,
                    r,
                    g,
                    b,
                    a,
                ) {
                Ok(()) => Ok((true, None::<String>)),
                Err(err) => Ok((false, Some(err.to_string()))),
            },
        );
        // -- setShader --
        /// Binds a tilemap-target shader to this map's generated render commands. Pass nil to clear.
        /// @param | shader | LShader? | Shader created with `lurek.render.newShader(code, { target = "tilemap" })`.
        methods.add_method_mut("setShader", |_, this, shader: Option<LuaAnyUserData>| {
            match shader {
                Some(shader_ud) => {
                    let key = shader_key_from_userdata(&shader_ud)?;
                    let st = this.state.borrow();
                    ensure_shader_target(&st, key, ShaderTarget::Tilemap, "LTileMap:setShader")?;
                    drop(st);
                    this.inner.borrow_mut().set_shader(Some(key));
                }
                None => this.inner.borrow_mut().set_shader(None),
            }
            Ok(())
        });
        // -- getShader --
        /// Returns the tilemap shader bound to this map, or nil when none is bound.
        /// @return | LShader | Bound shader handle.
        methods.add_method("getShader", |_, this, ()| {
            Ok(this.inner.borrow().get_shader().map(|key| LuaShader {
                state: this.state.clone(),
                key,
            }))
        });
        // -- setLayerShader --
        /// Binds a tilemap-target shader override to one layer. Pass nil to clear the layer override.
        /// @param | layer | integer | Layer index (1-based).
        /// @param | shader | LShader? | Shader created with `lurek.render.newShader(code, { target = "tilemap" })`.
        methods.add_method_mut(
            "setLayerShader",
            |_, this, (layer, shader): (usize, Option<LuaAnyUserData>)| {
                let layer_index = one_based_usize("layer", layer)?;
                let key = match shader {
                    Some(shader_ud) => {
                        let key = shader_key_from_userdata(&shader_ud)?;
                        let st = this.state.borrow();
                        ensure_shader_target(
                            &st,
                            key,
                            ShaderTarget::Tilemap,
                            "LTileMap:setLayerShader",
                        )?;
                        Some(key)
                    }
                    None => None,
                };
                this.inner
                    .borrow_mut()
                    .set_layer_shader(layer_index, key)
                    .map_err(|err| {
                        LuaError::RuntimeError(format!("LTileMap:setLayerShader: {err}"))
                    })?;
                Ok(())
            },
        );
        // -- getLayerShader --
        /// Returns the shader override bound to one layer, or nil when the layer has no override.
        /// @param | layer | integer | Layer index (1-based).
        /// @return | LShader | Bound layer shader handle.
        methods.add_method("getLayerShader", |_, this, layer: usize| {
            let layer_index = one_based_usize("layer", layer)?;
            Ok(this
                .inner
                .borrow()
                .get_layer_shader(layer_index)
                .map(|key| LuaShader {
                    state: this.state.clone(),
                    key,
                }))
        });
        // -- render --
        /// Submits render commands for all visible tiles, optionally offset by a scroll position.
        /// @param | ox | number? | Horizontal scroll offset (default 0).
        /// @param | oy | number? | Vertical scroll offset (default 0).
        methods.add_method("render", |_, this, (ox, oy): (Option<f32>, Option<f32>)| {
            let sx = ox.unwrap_or(0.0);
            let sy = oy.unwrap_or(0.0);
            finite_values_lua(&[sx, sy], "LTileMap:render")?;
            let cmds = this.inner.borrow().build_render_commands(sx, sy);
            extend_tilemap_render_commands(&mut this.state.borrow_mut(), cmds);
            Ok(())
        });

        // -- renderFieldSlot --
        /// Renders objects referenced from a tilefield slot using tileset object visuals.
        /// @param | field | LTileField|table | Source tilefield handle or provider table containing slot refs.
        /// @param | tileset | LTileSet|table | Tileset handle or provider table with object archetype visuals.
        /// @param | opts | table | Options: slot, z, offsetX, offsetY, refIsGid.
        methods.add_method(
            "renderFieldSlot",
            |_, this, (field_value, tileset_value, opts): (LuaValue, LuaValue, LuaTable)| {
                let slot: String = opts.get("slot")?;
                let z = opts
                    .get::<_, Option<u32>>("z")?
                    .unwrap_or(1)
                    .checked_sub(1)
                    .ok_or_else(|| {
                        LuaError::RuntimeError("renderFieldSlot: z must be >= 1".to_string())
                    })?;
                let offset_x = opts.get::<_, Option<f32>>("offsetX")?.unwrap_or(0.0);
                let offset_y = opts.get::<_, Option<f32>>("offsetY")?.unwrap_or(0.0);
                finite_values_lua(&[offset_x, offset_y], "LTileMap:renderFieldSlot")?;
                let ref_is_gid = opts.get::<_, Option<bool>>("refIsGid")?.unwrap_or(false);
                let field_ref = tilefield_from_value(field_value, "LTileMap:renderFieldSlot")?;
                let tileset_ref = tileset_from_value(tileset_value, "LTileMap:renderFieldSlot")?;
                let field = field_ref.borrow();
                let tileset = tileset_ref.borrow();
                let map = this.inner.borrow();
                let options = TileFieldSlotRenderOptions {
                    slot,
                    z,
                    offset_x,
                    offset_y,
                    ref_is_gid,
                };
                let state = this.state.borrow();
                let commands = map
                    .build_field_slot_render_commands(&field, &tileset, &options, |texture_key| {
                        state.textures.contains_key(texture_key)
                    })
                    .map_err(LuaError::RuntimeError)?;
                drop(state);
                extend_tilemap_render_commands(&mut this.state.borrow_mut(), commands);
                Ok(())
            },
        );

        // -- renderFieldCatalogSlot --
        /// Renders typed refs from a tilefield slot through a tileset catalog.
        /// @param | field | LTileField|table | Source tilefield handle or provider table containing typed slot refs.
        /// @param | catalog | LTileCatalog | Catalog resolving `{tileset,tile/object}` refs to visuals.
        /// @param | opts | table | Options: slot, z, offsetX, offsetY.
        methods.add_method(
            "renderFieldCatalogSlot",
            |_, this, (field_value, catalog_value, opts): (LuaValue, LuaValue, LuaTable)| {
                let slot: String = opts.get("slot")?;
                let z = opts
                    .get::<_, Option<u32>>("z")?
                    .unwrap_or(1)
                    .checked_sub(1)
                    .ok_or_else(|| {
                        LuaError::RuntimeError("renderFieldCatalogSlot: z must be >= 1".to_string())
                    })?;
                let offset_x = opts.get::<_, Option<f32>>("offsetX")?.unwrap_or(0.0);
                let offset_y = opts.get::<_, Option<f32>>("offsetY")?.unwrap_or(0.0);
                finite_values_lua(&[offset_x, offset_y], "LTileMap:renderFieldCatalogSlot")?;
                let field_ref =
                    tilefield_from_value(field_value, "LTileMap:renderFieldCatalogSlot")?;
                let catalog_ref =
                    catalog_from_value(catalog_value, "LTileMap:renderFieldCatalogSlot")?;
                let field = field_ref.borrow();
                let catalog = catalog_ref.borrow();
                let map = this.inner.borrow();
                let options = TileFieldSlotRenderOptions {
                    slot,
                    z,
                    offset_x,
                    offset_y,
                    ref_is_gid: false,
                };
                let state = this.state.borrow();
                let commands = map
                    .build_field_catalog_slot_render_commands(
                        &field,
                        &catalog,
                        &options,
                        |texture_key| state.textures.contains_key(texture_key),
                    )
                    .map_err(LuaError::RuntimeError)?;
                drop(state);
                extend_tilemap_render_commands(&mut this.state.borrow_mut(), commands);
                Ok(())
            },
        );
        // -- getDiagnostics --
        /// Returns tilemap diagnostics counters for invalid calls, unknown gids, and lazy index rebuilds.
        methods.add_method("getDiagnostics", |lua, this, ()| {
            diagnostics_table(lua, this.inner.borrow().diagnostics_snapshot())
        });
        // -- type --
        /// Returns the type name of this userdata.
        /// @return | string | Always `"LTileMap"`.
        methods.add_method("type", |_, _, ()| Ok("LTileMap"));
        // -- typeOf --
        /// Checks whether this object matches the given type name.
        /// @param | name | string | Type name to check against.
        /// @return | boolean | True if `name` is `"LTileMap"` or `"Object"`.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LTileMap" || name == "LObject")
        });
    }
}
/// Lua-side handle wrapping an `AutoTileSheet` that maps bitmasks to tile quads for auto-tiling.
#[derive(Clone)]
pub struct LuaAutoTileSheet {
    inner: Rc<RefCell<AutoTileSheet>>,
}
impl LuaUserData for LuaAutoTileSheet {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- getLayout --
        /// Returns the auto-tile layout type as a string.
        /// @return | string | One of `"blob47"`, `"composite48"`, `"rpgmaker48"`, `"minimal16"`.
        methods.add_method("getLayout", |_, this, ()| {
            Ok(this.inner.borrow().get_layout_name())
        });
        // -- getDefaultMode --
        /// Returns the default neighbor matching mode for this auto-tile sheet layout.
        /// @return | string | One of `"matchSides"` or `"matchCornersAndSides"`.
        methods.add_method("getDefaultMode", |_, this, ()| {
            Ok(this.inner.borrow().get_default_mode().as_str())
        });
        // -- getTileCount --
        /// Returns the total number of tiles in this auto-tile sheet.
        /// @return | integer | Tile count.
        methods.add_method("getTileCount", |_, this, ()| {
            Ok(this.inner.borrow().get_tile_count())
        });
        // -- getTileWidth --
        /// Returns the width of each tile in the auto-tile sheet, in pixels.
        /// @return | integer | Tile width.
        methods.add_method("getTileWidth", |_, this, ()| {
            Ok(this.inner.borrow().get_tile_width())
        });
        // -- getTileHeight --
        /// Returns the height of each tile in the auto-tile sheet, in pixels.
        /// @return | integer | Tile height.
        methods.add_method("getTileHeight", |_, this, ()| {
            Ok(this.inner.borrow().get_tile_height())
        });
        // -- applyToTileSet --
        /// Writes the auto-tile bitmask-to-tile rules from this sheet into a tileset.
        /// @param | tileSet | LTileSet | Target tileset to receive the rules.
        /// @param | typeName | string | Logical tile type name to register under.
        /// @param | startGid | integer? | Optional first GID offset.
        methods.add_method(
            "applyToTileSet",
            |_, this, (ts_ud, type_name, start_gid): (LuaAnyUserData, String, Option<u32>)| {
                let ts = ts_ud.borrow::<LuaTileSet>()?;
                this.inner
                    .borrow()
                    .apply_to_tileset(&mut ts.inner.borrow_mut(), &type_name, start_gid)
                    .map_err(|err| {
                        LuaError::RuntimeError(format!("lurek.tilemap.applyToTileSet: {err}"))
                    })?;
                Ok(())
            },
        );
        // -- getBitmaskForTile --
        /// Returns the bitmask associated with a tile in this auto-tile sheet.
        /// @param | tileId | integer | Tile ID (1-based).
        /// @return | integer | Bitmask value, or nil if not found.
        methods.add_method("getBitmaskForTile", |_, this, tile_id: u32| {
            let tile_id = one_based_u32("getBitmaskForTile tile_id", tile_id)?;
            Ok(this.inner.borrow().get_bitmask_for_tile(tile_id))
        });
        // -- getTileForBitmask --
        /// Looks up which tile corresponds to a given bitmask value.
        /// @param | bitmask | integer | Bitmask to resolve.
        /// @return | integer | Tile ID (1-based), or nil if no tile matches.
        methods.add_method("getTileForBitmask", |_, this, bitmask: u16| {
            Ok(this
                .inner
                .borrow()
                .get_tile_for_bitmask(bitmask)
                .map(|idx| idx + 1))
        });
        // -- getQuad --
        /// Returns the source rectangle for a tile in the auto-tile sheet.
        /// @param | tileId | integer | Tile ID (1-based).
        /// @return | integer | X offset in pixels.
        /// @return | integer | Y offset in pixels.
        /// @return | integer | Width in pixels.
        /// @return | integer | Height in pixels.
        methods.add_method("getQuad", |_, this, tile_id: u32| {
            let tile_id = one_based_u32("getQuad tile_id", tile_id)?;
            let r = this.inner.borrow().get_quad(tile_id);
            Ok((r.x, r.y, r.width, r.height))
        });
        // -- type --
        /// Returns the type name of this userdata.
        /// @return | string | Always `"LAutoTileSheet"`.
        methods.add_method("type", |_, _, ()| Ok("LAutoTileSheet"));
        // -- typeOf --
        /// Checks whether this object matches the given type name.
        /// @param | name | string | Type name to check against.
        /// @return | boolean | True if `name` is `"LAutoTileSheet"` or `"Object"`.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LAutoTileSheet" || name == "LObject")
        });
    }
}
/// Lua-side handle wrapping a `ChunkMap` for infinite or very large tile grids stored in dynamically loaded chunks.
#[derive(Clone)]
pub struct LuaChunkMap {
    inner: Rc<RefCell<ChunkMap>>,
}

fn chunk_map_error(api: &str, error: impl std::fmt::Display) -> LuaError {
    LuaError::RuntimeError(format!("lurek.tilemap.{api}: {error}"))
}

fn chunk_edits_from_table(
    edits: LuaTable,
    max_edits: u64,
    api: &str,
) -> LuaResult<Vec<(i32, i32, u32)>> {
    let raw_len = edits.raw_len();
    if raw_len as u64 > max_edits {
        return Err(chunk_map_error(
            api,
            format!("edit count {raw_len} exceeds limit {max_edits}"),
        ));
    }
    let mut parsed = Vec::new();
    parsed
        .try_reserve_exact(raw_len)
        .map_err(|_| chunk_map_error(api, "could not allocate edit staging"))?;
    for (index, value) in edits.sequence_values::<LuaTable>().enumerate() {
        let edit =
            value.map_err(|err| chunk_map_error(api, format!("edit {}: {err}", index + 1)))?;
        let x: i32 = edit
            .get("x")
            .or_else(|_| edit.get(1))
            .map_err(|err| chunk_map_error(api, format!("edit {} missing x: {err}", index + 1)))?;
        let y: i32 = edit
            .get("y")
            .or_else(|_| edit.get(2))
            .map_err(|err| chunk_map_error(api, format!("edit {} missing y: {err}", index + 1)))?;
        let gid: u32 = edit.get("gid").or_else(|_| edit.get(3)).map_err(|err| {
            chunk_map_error(api, format!("edit {} missing gid: {err}", index + 1))
        })?;
        parsed.push((x, y, gid));
    }
    Ok(parsed)
}

/// Prepared, version-checked mutation for one existing `LChunkMap`.
#[derive(Clone)]
pub struct LuaChunkMapBatch {
    map: Rc<RefCell<ChunkMap>>,
    prepared: Rc<RefCell<Option<PreparedChunkBatch>>>,
}

impl LuaUserData for LuaChunkMapBatch {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- preview --
        /// Returns deterministic metadata for this prepared chunk-map mutation.
        /// @return | table | Base version, edit count, changed tile count, and changed chunks.
        methods.add_method("preview", |lua, this, ()| {
            let prepared = this.prepared.borrow();
            let batch = prepared
                .as_ref()
                .ok_or_else(|| chunk_map_error("LChunkMapBatch:preview", "batch is not pending"))?;
            let out = lua.create_table()?;
            out.set("baseVersion", batch.base_version())?;
            out.set("editCount", batch.edit_count())?;
            out.set("changedTileCount", batch.changed_tile_count())?;
            out.set(
                "changedChunks",
                chunk_pairs_to_lua(lua, batch.changed_chunks().to_vec())?,
            )?;
            Ok(out)
        });
        // -- commit --
        /// Commits this prepared mutation if the map version is unchanged.
        /// @return | table | Deterministically ordered changed chunk coordinates.
        methods.add_method("commit", |lua, this, ()| {
            let batch =
                this.prepared.borrow().as_ref().cloned().ok_or_else(|| {
                    chunk_map_error("LChunkMapBatch:commit", "batch is not pending")
                })?;
            let changed = this
                .map
                .borrow_mut()
                .commit_prepared(batch)
                .map_err(|error| chunk_map_error("LChunkMapBatch:commit", error))?;
            *this.prepared.borrow_mut() = None;
            chunk_pairs_to_lua(lua, changed)
        });
        // -- discard --
        /// Discards this prepared mutation without changing the map.
        /// @return | boolean | True when a pending mutation was discarded.
        methods.add_method("discard", |_, this, ()| {
            Ok(this.prepared.borrow_mut().take().is_some())
        });
        // -- isPending --
        /// Returns whether this batch can still be committed or discarded.
        /// @return | boolean | True while the batch remains pending.
        methods.add_method("isPending", |_, this, ()| {
            Ok(this.prepared.borrow().is_some())
        });
        // -- type --
        /// Returns the type name of this prepared batch.
        /// @return | string | Always `"LChunkMapBatch"`.
        methods.add_method("type", |_, _, ()| Ok("LChunkMapBatch"));
        // -- typeOf --
        /// Checks whether this object matches the requested type.
        /// @param | name | string | Type name.
        /// @return | boolean | True for `LChunkMapBatch` or `LObject`.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LChunkMapBatch" || name == "LObject")
        });
    }
}

impl LuaUserData for LuaChunkMap {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- getTile --
        /// Returns the tile GID at the given world-tile coordinate.
        /// @param | x | integer | Tile X coordinate.
        /// @param | y | integer | Tile Y coordinate.
        /// @return | integer | Global tile ID.
        methods.add_method("getTile", |_, this, (x, y): (i32, i32)| {
            Ok(this.inner.borrow().get_tile(x, y))
        });
        // -- setTile --
        /// Sets the tile GID at the given world-tile coordinate.
        /// @param | x | integer | Tile X coordinate.
        /// @param | y | integer | Tile Y coordinate.
        /// @param | gid | integer | Global tile ID to place.
        methods.add_method("setTile", |_, this, (x, y, gid): (i32, i32, u32)| {
            this.inner
                .borrow_mut()
                .try_set_tile(x, y, gid)
                .map_err(|err| LuaError::RuntimeError(format!("LChunkMap:setTile: {err}")))?;
            Ok(())
        });
        // -- setTiles --
        /// Applies multiple `{x, y, gid}` tile edits and returns the chunks dirtied by this batch.
        /// @param | edits | table | Array of `{x, y, gid}` tables or `{x, y, gid}` arrays.
        /// @return | table | Array of `{cx, cy}` chunks changed by the batch.
        methods.add_method("setTiles", |lua, this, edits: LuaTable| {
            let max_edits = this.inner.borrow().limits().max_tile_operation_cells;
            let parsed = chunk_edits_from_table(edits, max_edits, "LChunkMap:setTiles")?;
            let dirty = this
                .inner
                .borrow_mut()
                .try_set_tiles(&parsed)
                .map_err(|err| chunk_map_error("LChunkMap:setTiles", err))?;
            chunk_pairs_to_lua(lua, dirty)
        });
        // -- prepareBatch --
        /// Validates and stages tile edits without mutating the live map.
        /// @param | edits | table | Array of `{x, y, gid}` tables or arrays.
        /// @param | expectedVersion | integer? | Optional required current map version.
        /// @return | LChunkMapBatch | Prepared mutation with preview, commit, and discard.
        methods.add_method(
            "prepareBatch",
            |lua, this, (edits, expected_version): (LuaTable, Option<u64>)| {
                let map = this.inner.borrow();
                if let Some(expected) = expected_version {
                    if expected != map.version() {
                        return Err(chunk_map_error(
                            "LChunkMap:prepareBatch",
                            format!(
                                "version conflict: expected {expected}, current version is {}",
                                map.version()
                            ),
                        ));
                    }
                }
                let parsed = chunk_edits_from_table(
                    edits,
                    map.limits().max_tile_operation_cells,
                    "LChunkMap:prepareBatch",
                )?;
                let prepared = map
                    .prepare_tiles(&parsed)
                    .map_err(|error| chunk_map_error("LChunkMap:prepareBatch", error))?;
                drop(map);
                lua.create_userdata(LuaChunkMapBatch {
                    map: this.inner.clone(),
                    prepared: Rc::new(RefCell::new(Some(prepared))),
                })
            },
        );
        // -- getVersion --
        /// Returns the monotonic logical tile-content version.
        /// @return | integer | Version incremented once per successful content mutation.
        methods.add_method("getVersion", |_, this, ()| {
            Ok(this.inner.borrow().version())
        });
        // -- readTiles --
        /// Reads many tile coordinates while crossing the Lua boundary only once.
        /// @param | coords | table | Array of `{x, y}` tables or arrays.
        /// @return | table | Array of `{x, y,gid}` records in input order.
        methods.add_method("readTiles", |lua, this, coords: LuaTable| {
            let map = this.inner.borrow();
            let raw_len = coords.raw_len();
            let limit = map.limits().max_tile_operation_cells;
            if raw_len as u64 > limit {
                return Err(chunk_map_error(
                    "LChunkMap:readTiles",
                    format!("coordinate count {raw_len} exceeds limit {limit}"),
                ));
            }
            let out = lua.create_table_with_capacity(raw_len, 0)?;
            for (index, value) in coords.sequence_values::<LuaTable>().enumerate() {
                let coord = value.map_err(|error| {
                    chunk_map_error(
                        "LChunkMap:readTiles",
                        format!("coord {}: {error}", index + 1),
                    )
                })?;
                let x: i32 = coord.get("x").or_else(|_| coord.get(1)).map_err(|error| {
                    chunk_map_error(
                        "LChunkMap:readTiles",
                        format!("coord {} missing x: {error}", index + 1),
                    )
                })?;
                let y: i32 = coord.get("y").or_else(|_| coord.get(2)).map_err(|error| {
                    chunk_map_error(
                        "LChunkMap:readTiles",
                        format!("coord {} missing y: {error}", index + 1),
                    )
                })?;
                let row = lua.create_table_with_capacity(0, 3)?;
                row.set("x", x)?;
                row.set("y", y)?;
                row.set("gid", map.get_tile(x, y))?;
                out.set(index + 1, row)?;
            }
            Ok(out)
        });
        // -- snapshotRegion --
        /// Captures a bounded half-open rectangle as a deterministic row-major tile array.
        /// @param | x0 | integer | Inclusive left coordinate.
        /// @param | y0 | integer | Inclusive top coordinate.
        /// @param | x1 | integer | Exclusive right coordinate.
        /// @param | y1 | integer | Exclusive bottom coordinate.
        /// @return | table | Snapshot containing bounds, dimensions, version, and flat `tiles`.
        methods.add_method(
            "snapshotRegion",
            |lua, this, (x0, y0, x1, y1): (i32, i32, i32, i32)| {
                let map = this.inner.borrow();
                let tiles = map
                    .read_region(x0, y0, x1, y1)
                    .map_err(|error| chunk_map_error("LChunkMap:snapshotRegion", error))?;
                let out = lua.create_table_with_capacity(0, 8)?;
                out.set("x0", x0)?;
                out.set("y0", y0)?;
                out.set("x1", x1)?;
                out.set("y1", y1)?;
                out.set("width", i64::from(x1).saturating_sub(i64::from(x0)).max(0))?;
                out.set("height", i64::from(y1).saturating_sub(i64::from(y0)).max(0))?;
                out.set("version", map.version())?;
                out.set("tiles", tiles)?;
                Ok(out)
            },
        );
        // -- hashRegion --
        /// Returns a deterministic hash of one bounded half-open tile rectangle.
        /// @param | x0 | integer | Inclusive left coordinate.
        /// @param | y0 | integer | Inclusive top coordinate.
        /// @param | x1 | integer | Exclusive right coordinate.
        /// @param | y1 | integer | Exclusive bottom coordinate.
        /// @return | string | Lowercase 64-bit FNV-1a hash.
        methods.add_method(
            "hashRegion",
            |_, this, (x0, y0, x1, y1): (i32, i32, i32, i32)| {
                this.inner
                    .borrow()
                    .hash_region(x0, y0, x1, y1)
                    .map_err(|error| chunk_map_error("LChunkMap:hashRegion", error))
            },
        );
        // -- clearTile --
        /// Removes the tile at the given world-tile coordinate.
        /// @param | x | integer | Tile X coordinate.
        /// @param | y | integer | Tile Y coordinate.
        methods.add_method("clearTile", |_, this, (x, y): (i32, i32)| {
            this.inner
                .borrow_mut()
                .try_set_tile(x, y, 0)
                .map_err(|err| LuaError::RuntimeError(format!("LChunkMap:clearTile: {err}")))?;
            Ok(())
        });
        // -- fillRect --
        /// Fills a rectangular region of tiles with a given GID.
        /// @param | x0 | integer | Left tile coordinate.
        /// @param | y0 | integer | Top tile coordinate.
        /// @param | x1 | integer | Right tile coordinate (inclusive).
        /// @param | y1 | integer | Bottom tile coordinate (inclusive).
        /// @param | gid | integer | Global tile ID to fill with.
        methods.add_method(
            "fillRect",
            |_, this, (x0, y0, x1, y1, gid): (i32, i32, i32, i32, u32)| {
                let limits = this.inner.borrow().limits();
                this.inner
                    .borrow_mut()
                    .try_fill_rect(x0, y0, x1, y1, gid, &limits)
                    .map_err(|err| LuaError::RuntimeError(format!("LChunkMap:fillRect: {err}")))?;
                Ok(())
            },
        );
        // -- loadChunk --
        /// Loads a chunk into memory at the given chunk coordinates.
        /// @param | cx | integer | Chunk X coordinate.
        /// @param | cy | integer | Chunk Y coordinate.
        methods.add_method("loadChunk", |_, this, (cx, cy): (i32, i32)| {
            this.inner
                .borrow_mut()
                .try_load_chunk(cx, cy)
                .map_err(|err| LuaError::RuntimeError(format!("LChunkMap:loadChunk: {err}")))?;
            Ok(())
        });
        // -- unloadChunk --
        /// Unloads a chunk from memory at the given chunk coordinates.
        /// @param | cx | integer | Chunk X coordinate.
        /// @param | cy | integer | Chunk Y coordinate.
        methods.add_method("unloadChunk", |_, this, (cx, cy): (i32, i32)| {
            this.inner.borrow_mut().unload_chunk(cx, cy);
            Ok(())
        });
        // -- getDirtyChunks --
        /// Returns loaded chunk coordinates with tile changes pending downstream updates.
        /// @return | table | Array of `{cx, cy}` pairs.
        methods.add_method("getDirtyChunks", |lua, this, ()| {
            chunk_pairs_to_lua(lua, this.inner.borrow().get_dirty_chunks())
        });
        // -- drainDirtyChunks --
        /// Clears and returns chunk coordinates with pending tile changes.
        /// @return | table | Array of `{cx, cy}` pairs.
        methods.add_method("drainDirtyChunks", |lua, this, ()| {
            chunk_pairs_to_lua(lua, this.inner.borrow_mut().drain_dirty_chunks())
        });
        // -- clearDirtyChunks --
        /// Clears chunk dirty tracking without changing tile contents.
        methods.add_method("clearDirtyChunks", |_, this, ()| {
            this.inner.borrow_mut().clear_dirty_chunks();
            Ok(())
        });
        // -- chunkToBytes --
        /// Serializes one loaded chunk into binary bytes for save workflows.
        /// @param | cx | integer | Chunk X coordinate.
        /// @param | cy | integer | Chunk Y coordinate.
        /// @return | string | Binary chunk data, or nil when the chunk is not loaded.
        methods.add_method("chunkToBytes", |lua, this, (cx, cy): (i32, i32)| match this
            .inner
            .borrow()
            .chunk_to_bytes(cx, cy)
        {
            Some(bytes) => Ok(Some(lua.create_string(&bytes)?)),
            None => Ok(None),
        });
        // -- loadChunkFromBytes --
        /// Loads one chunk from bytes previously returned by `chunkToBytes`.
        /// @param | cx | integer | Chunk X coordinate.
        /// @param | cy | integer | Chunk Y coordinate.
        /// @param | data | string | Binary chunk data.
        methods.add_method(
            "loadChunkFromBytes",
            |_, this, (cx, cy, data): (i32, i32, LuaString)| {
                this.inner
                    .borrow_mut()
                    .load_chunk_from_bytes(cx, cy, data.as_bytes().as_ref())
                    .map_err(|err| {
                        LuaError::RuntimeError(format!("LChunkMap:loadChunkFromBytes: {err}"))
                    })
            },
        );
        // -- getChunkSize --
        /// Returns the size of each chunk in tiles per side.
        /// @return | integer | Chunk size.
        methods.add_method("getChunkSize", |_, this, ()| {
            Ok(this.inner.borrow().get_chunk_size())
        });
        // -- getLoadedChunks --
        /// Returns a list of all currently loaded chunk coordinates.
        /// @return | table | Array of `{cx, cy}` pairs.
        /// @field | cx | integer | Cx.
        /// @field | cy | integer | Cy.
        methods.add_method("getLoadedChunks", |lua, this, ()| {
            chunk_pairs_to_lua(lua, this.inner.borrow().get_loaded_chunks())
        });
        // -- getChunksInView --
        /// Returns chunk coordinates that overlap a viewport region, given tile dimensions.
        /// @param | vx | number | Viewport left edge in world pixels.
        /// @param | vy | number | Viewport top edge in world pixels.
        /// @param | vw | number | Viewport width in pixels.
        /// @param | vh | number | Viewport height in pixels.
        /// @param | tw | number | Tile width in pixels.
        /// @param | th | number | Tile height in pixels.
        /// @return | table | Array of `{cx, cy}` pairs.
        /// @field | cx | integer | Cx.
        /// @field | cy | integer | Cy.
        methods.add_method(
            "getChunksInView",
            |lua, this, (vx, vy, vw, vh, tw, th): (f32, f32, f32, f32, f32, f32)| {
                finite_values_lua(&[vx, vy, vw, vh, tw, th], "LChunkMap:getChunksInView")?;
                positive_lua(vw, "LChunkMap:getChunksInView viewport width")?;
                positive_lua(vh, "LChunkMap:getChunksInView viewport height")?;
                positive_lua(tw, "LChunkMap:getChunksInView tile width")?;
                positive_lua(th, "LChunkMap:getChunksInView tile height")?;
                let chunks = this
                    .inner
                    .borrow()
                    .try_get_chunks_in_view(vx, vy, vw, vh, tw, th)
                    .map_err(|err| {
                        LuaError::RuntimeError(format!("LChunkMap:getChunksInView: {err}"))
                    })?;
                chunk_pairs_to_lua(lua, chunks)
            },
        );
        // -- chunkTileRange --
        /// Returns the tile-coordinate range covered by a specific chunk.
        /// @param | cx | integer | Chunk X coordinate.
        /// @param | cy | integer | Chunk Y coordinate.
        /// @return | integer | Minimum tile X.
        /// @return | integer | Minimum tile Y.
        /// @return | integer | Maximum tile X.
        /// @return | integer | Maximum tile Y.
        methods.add_method("chunkTileRange", |_, this, (cx, cy): (i32, i32)| {
            let (x0, y0, x1, y1) = this.inner.borrow().chunk_tile_range(cx, cy);
            Ok((x0, y0, x1, y1))
        });
        // -- type --
        /// Returns the type name of this userdata.
        /// @return | string | Always `"LChunkMap"`.
        methods.add_method("type", |_, _, ()| Ok("LChunkMap"));
        // -- typeOf --
        /// Checks whether this object matches the given type name.
        /// @param | name | string | Type name to check against.
        /// @return | boolean | True if `name` is `"LChunkMap"` or `"Object"`.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LChunkMap" || name == "LObject")
        });
    }
}
/// Lua-side handle wrapping a `LargeMapRenderer` for chunk-based rendering of very large tile maps with LOD support.
#[derive(Clone)]
pub struct LuaLargeMapRenderer {
    inner: Rc<RefCell<LargeMapRenderer>>,
}
impl LuaUserData for LuaLargeMapRenderer {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- setMapData --
        /// Replaces all tile data with a flat array of GIDs for the given dimensions.
        /// @param | data | table | Flat array of tile GIDs (row-major order).
        /// @param | width | integer | Map width in tiles.
        /// @param | height | integer | Map height in tiles.
        methods.add_method_mut(
            "setMapData",
            |_, this, (data, width, height): (LuaTable, u32, u32)| {
                let mut ids: Vec<u32> = Vec::new();
                for v in data.sequence_values::<u32>() {
                    ids.push(v?);
                }
                this.inner
                    .borrow_mut()
                    .try_set_map_data(ids, width, height)
                    .map_err(|err| {
                        LuaError::RuntimeError(format!("LLargeMapRenderer:setMapData: {err}"))
                    })?;
                Ok(())
            },
        );
        // -- setTile --
        /// Sets a single tile GID at a given position.
        /// @param | x | integer | Column.
        /// @param | y | integer | Row.
        /// @param | tileId | integer | Tile GID to place.
        methods.add_method_mut("setTile", |_, this, (x, y, tile_id): (u32, u32, u32)| {
            this.inner
                .borrow_mut()
                .try_set_tile(x, y, tile_id)
                .map_err(|err| {
                    LuaError::RuntimeError(format!("LLargeMapRenderer:setTile: {err}"))
                })?;
            Ok(())
        });
        // -- setTiles --
        /// Applies a bounded list of tile edits atomically and increments the data version once.
        /// @param | edits | table | Array of `{x, y, tileId}` edit tables using zero-based coordinates.
        /// @return | integer | Number of submitted writes whose value changed.
        methods.add_method_mut("setTiles", |_, this, edits: LuaTable| {
            let raw_len = edits.raw_len();
            let limit = this.inner.borrow().max_tile_operation_cells();
            if raw_len as u64 > limit {
                return Err(LuaError::RuntimeError(format!(
                    "LLargeMapRenderer:setTiles: edit count {raw_len} exceeds limit {limit}"
                )));
            }
            let mut parsed = Vec::new();
            parsed.try_reserve_exact(raw_len).map_err(|_| {
                LuaError::RuntimeError(
                    "LLargeMapRenderer:setTiles: could not allocate edit staging".to_string(),
                )
            })?;
            for (index, value) in edits.sequence_values::<LuaTable>().enumerate() {
                let edit = value.map_err(|error| {
                    LuaError::RuntimeError(format!(
                        "LLargeMapRenderer:setTiles: edit {}: {error}",
                        index + 1
                    ))
                })?;
                let x = edit.get::<_, u32>("x").or_else(|_| edit.get(1))?;
                let y = edit.get::<_, u32>("y").or_else(|_| edit.get(2))?;
                let tile_id = edit
                    .get::<_, u32>("tileId")
                    .or_else(|_| edit.get("gid"))
                    .or_else(|_| edit.get(3))?;
                parsed.push((x, y, tile_id));
            }
            this.inner
                .borrow_mut()
                .try_set_tiles(&parsed)
                .map_err(|err| LuaError::RuntimeError(format!("LLargeMapRenderer:setTiles: {err}")))
        });
        // -- getVersion --
        /// Returns the monotonic version of this renderer's tile snapshot.
        /// @return | integer | Tile-data version.
        methods.add_method("getVersion", |_, this, ()| {
            Ok(this.inner.borrow().version())
        });
        // -- getTile --
        /// Returns the tile GID at a given position.
        /// @param | x | integer | Column.
        /// @param | y | integer | Row.
        /// @return | integer | Tile GID.
        methods.add_method("getTile", |_, this, (x, y): (u32, u32)| {
            Ok(this.inner.borrow().get_tile(x, y))
        });
        // -- getMapSize --
        /// Returns the map dimensions in tiles.
        /// @return | integer | Width in tiles.
        /// @return | integer | Height in tiles.
        methods.add_method("getMapSize", |_, this, ()| {
            let (w, h) = this.inner.borrow().get_map_size();
            Ok((w, h))
        });
        // -- setChunkSize --
        /// Sets the chunk size used for rendering subdivision.
        /// @param | size | integer | Chunk size in tiles per side.
        methods.add_method_mut("setChunkSize", |_, this, size: u32| {
            this.inner
                .borrow_mut()
                .try_set_chunk_size(size)
                .map_err(|err| {
                    LuaError::RuntimeError(format!("LLargeMapRenderer:setChunkSize: {err}"))
                })?;
            Ok(())
        });
        // -- getChunkSize --
        /// Returns the current chunk size. This method is available to Lua scripts.
        /// @return | integer | Chunk size in tiles per side.
        methods.add_method("getChunkSize", |_, this, ()| {
            Ok(this.inner.borrow().get_chunk_size())
        });
        // -- invalidateChunk --
        /// Marks a specific chunk as dirty so it will be rebuilt on the next render.
        /// @param | cx | integer | Chunk X index.
        /// @param | cy | integer | Chunk Y index.
        methods.add_method_mut("invalidateChunk", |_, this, (cx, cy): (i32, i32)| {
            this.inner.borrow_mut().invalidate_chunk(cx, cy);
            Ok(())
        });
        // -- invalidateAll --
        /// Marks all chunks as dirty, forcing a full rebuild on the next render.
        methods.add_method_mut("invalidateAll", |_, this, ()| {
            this.inner.borrow_mut().invalidate_all();
            Ok(())
        });
        // -- getVisibleChunks --
        /// Returns the number of chunks currently visible in the viewport.
        /// @return | integer | Visible chunk count.
        methods.add_method("getVisibleChunks", |_, this, ()| {
            Ok(this.inner.borrow().get_visible_chunks())
        });
        // -- getTotalChunks --
        /// Returns the total number of chunks in the map.
        /// @return | integer | Total chunk count.
        methods.add_method("getTotalChunks", |_, this, ()| {
            Ok(this.inner.borrow().get_total_chunks())
        });
        // -- setCamera --
        /// Sets the camera position and zoom level for determining visible chunks.
        /// @param | x | number | Camera center X in world pixels.
        /// @param | y | number | Camera center Y in world pixels.
        /// @param | zoom | number | Zoom factor (1.0 = normal).
        methods.add_method_mut("setCamera", |_, this, (x, y, zoom): (f32, f32, f32)| {
            this.inner
                .borrow_mut()
                .try_set_camera(x, y, zoom)
                .map_err(|err| {
                    LuaError::RuntimeError(format!("LLargeMapRenderer:setCamera: {err}"))
                })?;
            Ok(())
        });
        // -- setViewport --
        /// Sets the viewport rectangle used for render-command culling.
        /// @param | w | number | Viewport width in pixels.
        /// @param | h | number | Viewport height in pixels.
        methods.add_method_mut("setViewport", |_, this, (w, h): (f32, f32)| {
            this.inner
                .borrow_mut()
                .try_set_viewport(w, h)
                .map_err(|err| {
                    LuaError::RuntimeError(format!("LLargeMapRenderer:setViewport: {err}"))
                })?;
            Ok(())
        });
        // -- setLodEnabled --
        /// Enables or disables level-of-detail rendering for distant chunks.
        /// @param | enabled | boolean | True to enable LOD.
        methods.add_method_mut("setLodEnabled", |_, this, enabled: bool| {
            this.inner.borrow_mut().set_lod_enabled(enabled);
            Ok(())
        });
        // -- isLodEnabled --
        /// Returns whether LOD rendering is currently enabled.
        /// @return | boolean | True if LOD is enabled.
        methods.add_method("isLodEnabled", |_, this, ()| {
            Ok(this.inner.borrow().is_lod_enabled())
        });
        // -- setLodThresholds --
        /// Sets the zoom thresholds at which LOD levels change.
        /// @param | levels | table | Array of zoom threshold values.
        methods.add_method_mut("setLodThresholds", |_, this, levels: LuaTable| {
            let mut thresholds: Vec<f32> = Vec::new();
            for v in levels.sequence_values::<f32>() {
                thresholds.push(v?);
            }
            this.inner
                .borrow_mut()
                .try_set_lod_thresholds(thresholds)
                .map_err(|err| {
                    LuaError::RuntimeError(format!("LLargeMapRenderer:setLodThresholds: {err}"))
                })?;
            Ok(())
        });
        // -- setTilesetColumns --
        /// Sets the column count of the associated tileset atlas for UV calculation.
        /// @param | cols | integer | Number of columns in the tileset image.
        methods.add_method_mut("setTilesetColumns", |_, this, cols: u32| {
            this.inner.borrow_mut().set_tileset_columns(cols);
            Ok(())
        });
        // -- getTilesetColumns --
        /// Returns the tileset column count used for UV calculation.
        /// @return | integer | Column count.
        methods.add_method("getTilesetColumns", |_, this, ()| {
            Ok(this.inner.borrow().get_tileset_columns())
        });
        // -- type --
        /// Returns the type name of this userdata.
        /// @return | string | Always `"LLargeMapRenderer"`.
        methods.add_method("type", |_, _, ()| Ok("LLargeMapRenderer"));
        // -- typeOf --
        /// Checks whether this object matches the given type name.
        /// @param | name | string | Type name to check against.
        /// @return | boolean | True if `name` is `"LLargeMapRenderer"` or `"Object"`.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LLargeMapRenderer" || name == "LObject")
        });
    }
}
/// Lua-side handle wrapping an `IsoMap` for isometric tile rendering with multi-level support and configurable part ordering.
#[derive(Clone)]
pub struct LuaIsoMap {
    inner: Rc<RefCell<IsoMap>>,
}
impl LuaUserData for LuaIsoMap {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- addLevel --
        /// Adds a new vertical level to the isometric map and returns its index.
        /// @return | integer | Index of the new level (1-based).
        methods.add_method("addLevel", |_, this, ()| {
            let idx = this
                .inner
                .borrow_mut()
                .try_add_level()
                .map_err(|err| LuaError::RuntimeError(format!("LIsoMap:addLevel: {err}")))?;
            Ok(idx + 1)
        });
        // -- getLevelCount --
        /// Returns the number of vertical levels in the isometric map.
        /// @return | integer | Level count.
        methods.add_method("getLevelCount", |_, this, ()| {
            Ok(this.inner.borrow().get_level_count())
        });
        // -- setLevelVisible --
        /// Sets whether a vertical level is drawn during rendering.
        /// @param | z | integer | Level index (1-based).
        /// @param | visible | boolean | True to show, false to hide.
        methods.add_method("setLevelVisible", |_, this, (z, visible): (usize, bool)| {
            let z = one_based_usize("z", z)?;
            this.inner.borrow_mut().set_level_visible(z, visible);
            Ok(())
        });
        // -- isLevelVisible --
        /// Returns whether a vertical level is currently visible.
        /// @param | z | integer | Level index (1-based).
        /// @return | boolean | True if the level is visible.
        methods.add_method("isLevelVisible", |_, this, z: usize| {
            let z = one_based_usize("z", z)?;
            Ok(this.inner.borrow().get_level_visible(z))
        });
        // -- setTilePart --
        /// Sets the GID for a specific part of a tile at a given position and level.
        /// @param | z | integer | Level index (1-based).
        /// @param | x | integer | Column (1-based).
        /// @param | y | integer | Row (1-based).
        /// @param | part | integer | Part index (e.g. floor, wall, object).
        /// @param | gid | integer | Global tile ID to place.
        methods.add_method(
            "setTilePart",
            |_, this, (z, x, y, part, gid): (usize, u32, u32, u32, u32)| {
                let z = one_based_usize("z", z)?;
                let x = one_based_u32("x", x)?;
                let y = one_based_u32("y", y)?;
                this.inner.borrow_mut().set_tile_part(z, x, y, part, gid);
                Ok(())
            },
        );
        // -- getTilePart --
        /// Returns the GID for a specific part of a tile at a given position and level.
        /// @param | z | integer | Level index (1-based).
        /// @param | x | integer | Column (1-based).
        /// @param | y | integer | Row (1-based).
        /// @param | part | integer | Part index.
        /// @return | integer | Global tile ID.
        methods.add_method(
            "getTilePart",
            |_, this, (z, x, y, part): (usize, u32, u32, u32)| {
                let z = one_based_usize("z", z)?;
                let x = one_based_u32("x", x)?;
                let y = one_based_u32("y", y)?;
                Ok(this.inner.borrow().get_tile_part(z, x, y, part))
            },
        );
        // -- fillLevel --
        /// Fills all tiles on a level for a given part with a single GID.
        /// @param | z | integer | Level index (1-based).
        /// @param | part | integer | Part index to fill.
        /// @param | gid | integer | Global tile ID to fill with.
        methods.add_method("fillLevel", |_, this, (z, part, gid): (usize, u32, u32)| {
            let z = one_based_usize("z", z)?;
            this.inner.borrow_mut().fill_level(z, part, gid);
            Ok(())
        });
        // -- setOrigin --
        /// Sets the screen-space origin (top-left anchor) for isometric rendering.
        /// @param | x | number | Origin X in pixels.
        /// @param | y | number | Origin Y in pixels.
        methods.add_method("setOrigin", |_, this, (x, y): (f32, f32)| {
            finite_values_lua(&[x, y], "LIsoMap:setOrigin")?;
            this.inner.borrow_mut().set_origin(x, y);
            Ok(())
        });
        // -- getWidth --
        /// Returns the map width in tiles. This method is available to Lua scripts.
        /// @return | integer | Width.
        methods.add_method("getWidth", |_, this, ()| Ok(this.inner.borrow().width));
        // -- getHeight --
        /// Returns the map height in tiles. This method is available to Lua scripts.
        /// @return | integer | Height.
        methods.add_method("getHeight", |_, this, ()| Ok(this.inner.borrow().height));
        // -- getTileWidth --
        /// Returns the width of an isometric tile in pixels.
        /// @return | integer | Tile width.
        methods.add_method("getTileWidth", |_, this, ()| Ok(this.inner.borrow().tile_w));
        // -- getTileHeight --
        /// Returns the height of an isometric tile in pixels.
        /// @return | integer | Tile height.
        methods.add_method("getTileHeight", |_, this, ()| {
            Ok(this.inner.borrow().tile_h)
        });
        // -- getLevelHeight --
        /// Returns the vertical pixel offset between levels.
        /// @return | integer | Level height in pixels.
        methods.add_method("getLevelHeight", |_, this, ()| {
            Ok(this.inner.borrow().level_height)
        });
        // -- tileToScreen --
        /// Converts tile-grid coordinates to screen-space pixel position.
        /// @param | tx | number | Tile X.
        /// @param | ty | number | Tile Y.
        /// @param | tz | number | Tile Z (level).
        /// @return | number | Screen X.
        /// @return | number | Screen Y.
        methods.add_method("tileToScreen", |_, this, (tx, ty, tz): (f32, f32, f32)| {
            finite_values_lua(&[tx, ty, tz], "LIsoMap:tileToScreen")?;
            let (sx, sy) = this.inner.borrow().tile_to_screen(tx, ty, tz);
            Ok((sx, sy))
        });
        // -- screenToTile --
        /// Converts screen-space pixel coordinates to tile-grid coordinates (ignoring Z).
        /// @param | sx | number | Screen X.
        /// @param | sy | number | Screen Y.
        /// @return | number | Tile X.
        /// @return | number | Tile Y.
        methods.add_method("screenToTile", |_, this, (sx, sy): (f32, f32)| {
            finite_values_lua(&[sx, sy], "LIsoMap:screenToTile")?;
            let (tx, ty) = this.inner.borrow().screen_to_tile(sx, sy);
            Ok((tx, ty))
        });
        // -- getPartCount --
        /// Returns the number of tile parts per cell.
        /// @return | integer | Part count.
        methods.add_method("getPartCount", |_, this, ()| {
            Ok(this.inner.borrow().get_part_count())
        });
        // -- getPartOrder --
        /// Returns the rendering order of tile parts as an array of part indices.
        /// @return | integer[] | Part index values.
        methods.add_method("getPartOrder", |lua, this, ()| {
            let order = this.inner.borrow().get_part_order().to_vec();
            let tbl = lua.create_table()?;
            for (i, &idx) in order.iter().enumerate() {
                tbl.set(i + 1, idx)?;
            }
            Ok(tbl)
        });
        // -- setPartOrder --
        /// Overrides the rendering order of tile parts.
        /// @param | order | table | Array of part indices in desired draw order.
        methods.add_method_mut("setPartOrder", |_, this, order: Vec<u32>| {
            this.inner
                .borrow_mut()
                .set_part_order(order)
                .map_err(LuaError::external)
        });
        // -- type --
        /// Returns the type name of this userdata.
        /// @return | string | Always `"LIsoMap"`.
        methods.add_method("type", |_, _, ()| Ok("LIsoMap"));
        // -- typeOf --
        /// Checks whether this object matches the given type name.
        /// @param | name | string | Type name to check against.
        /// @return | boolean | True if `name` is `"LIsoMap"` or `"Object"`.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LIsoMap" || name == "LObject")
        });
    }
}
/// Registers the `lurek.tilemap` module table and all factory functions.
pub fn register(lua: &Lua, lurek: &LuaTable, state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let tbl = lua.create_table()?;
    // -- newTileSet --
    /// Compatibility alias for `lurek.tileset.newTileSet`.
    tbl.set(
        "newTileSet",
        lua.create_function(
            |lua,
             (first_gid, tile_count, columns, tile_width, tile_height, spacing, margin): (
                u32,
                u32,
                u32,
                u32,
                u32,
                Option<u32>,
                Option<u32>,
            )| {
                let tileset = TileSet::try_new(
                    first_gid,
                    tile_count,
                    columns,
                    tile_width,
                    tile_height,
                    spacing.unwrap_or(0),
                    margin.unwrap_or(0),
                )
                .map_err(|err| {
                    LuaError::RuntimeError(format!("lurek.tilemap.newTileSet: {err}"))
                })?;
                lua.create_userdata(LuaTileSet {
                    inner: Rc::new(RefCell::new(tileset)),
                })
            },
        )?,
    )?;

    let s = state.clone();
    // -- newTileMap --
    /// Creates a new empty tilemap with the given tile dimensions.
    /// @param | tileWidth | integer | Tile width in pixels.
    /// @param | tileHeight | integer | Tile height in pixels.
    /// @param | chunkSize | integer? | Internal chunk size in tiles (default 16).
    /// @param | opts | any? | Optional limits table (`maxLayers`, `maxTiles`, `maxImportBytes`, `maxDecodedBytes`, `maxChunkCells`, `maxChunks`, `maxTileOperationCells`).
    /// @return | LTileMap | New tilemap.
    tbl.set(
        "newTileMap",
        lua.create_function(
            move |lua,
                  (tile_width, tile_height, chunk_size, opts): (
                u32,
                u32,
                Option<u32>,
                Option<LuaTable>,
            )| {
                let limits = tilemap_limits_from_table(opts.as_ref())?;
                let inner_map = TileMap::try_new_with_limits(
                    tile_width,
                    tile_height,
                    chunk_size.unwrap_or(16),
                    limits,
                )
                .map_err(|err| {
                    LuaError::RuntimeError(format!("lurek.tilemap.newTileMap: {err}"))
                })?;
                let inner_rc = Rc::new(RefCell::new(inner_map));
                s.borrow_mut().auto_tilemaps.push(Rc::downgrade(&inner_rc));
                lua.create_userdata(LuaTileMap {
                    inner: inner_rc,
                    state: s.clone(),
                })
            },
        )?,
    )?;

    // -- fromProvider --
    /// Builds a native tilemap from a Lua provider table with tileWidth, tileHeight, layers, optional tilesets, and optional getTile(layer,x,y).
    /// @param | provider | table | Lua-authored tilemap provider.
    /// @param | opts | table? | Optional limits table.
    /// @return | LTileMap | New tilemap copied from provider data.
    let s = state.clone();
    tbl.set(
        "fromProvider",
        lua.create_function(move |lua, (provider, opts): (LuaTable, Option<LuaTable>)| {
            let limits = tilemap_limits_from_table(opts.as_ref())?;
            let inner_map = tilemap_from_provider(provider, limits, "lurek.tilemap.fromProvider")?;
            let inner_rc = Rc::new(RefCell::new(inner_map));
            s.borrow_mut().auto_tilemaps.push(Rc::downgrade(&inner_rc));
            lua.create_userdata(LuaTileMap {
                inner: inner_rc,
                state: s.clone(),
            })
        })?,
    )?;
    // --- Auto-tile factories ---
    // -- newAutoTileSheet --
    /// Creates an auto-tile sheet with a given tile size and layout.
    /// @param | tileW | integer | Tile width in pixels.
    /// @param | tileH | integer | Tile height in pixels.
    /// @param | layout | string | Layout type: `"blob47"`, `"composite48"`, `"rpgmaker48"`, or `"minimal16"`.
    /// @return | LAutoTileSheet | New auto-tile sheet.
    tbl.set(
        "newAutoTileSheet",
        lua.create_function(|lua, (tile_w, tile_h, layout_str): (u32, u32, String)| {
            create_auto_tile_sheet(lua, tile_w, tile_h, &layout_str)
        })?,
    )?;
    // -- getAutoTileFormats --
    /// Returns the supported auto-tile sheet layouts and their default matching modes.
    /// @return | table | Array of `{ name, tileCount, mode }` entries.
    tbl.set(
        "getAutoTileFormats",
        lua.create_function(|lua, ()| auto_tile_formats_table(lua))?,
    )?;
    // -- newChunkMap --
    /// Creates a new infinite chunk-based tile map.
    /// @param | chunkSize | integer? | Tiles per chunk side (default 16).
    /// @param | opts | any? | Optional limits table (`maxChunkCells`, `maxChunks`, `maxTileOperationCells`, and related tilemap ceilings).
    /// @return | LChunkMap | New chunk map.
    // --- Coordinate projections and importers ---
    tbl.set(
        "newChunkMap",
        lua.create_function(|lua, (chunk_size, opts): (Option<u32>, Option<LuaTable>)| {
            let limits = tilemap_limits_from_table(opts.as_ref())?;
            lua.create_userdata(LuaChunkMap {
                inner: Rc::new(RefCell::new(
                    ChunkMap::try_new_with_limits(chunk_size.unwrap_or(16), &limits).map_err(
                        |err| LuaError::RuntimeError(format!("lurek.tilemap.newChunkMap: {err}")),
                    )?,
                )),
            })
        })?,
    )?;
    // -- newIsoMap --
    /// Creates a new isometric map with the given dimensions and tile geometry.
    /// @param | width | integer | Map width in tiles.
    /// @param | height | integer | Map height in tiles.
    /// @param | tileW | integer | Tile width in pixels.
    /// @param | tileH | integer | Tile height in pixels.
    /// @param | levelHeight | integer | Vertical pixel offset between levels.
    /// @param | partCount | integer? | Number of tile parts per cell (default 4).
    /// @param | opts | table? | Optional tilemap limits table.
    /// @return | LIsoMap | New isometric map.
    tbl.set(
        "newIsoMap",
        lua.create_function(
            |lua,
             (width, height, tile_w, tile_h, level_height, part_count, opts): (
                u32,
                u32,
                u32,
                u32,
                u32,
                Option<u32>,
                Option<LuaTable>,
            )| {
                let limits = tilemap_limits_from_table(opts.as_ref())?;
                let map = IsoMap::try_new(
                    width,
                    height,
                    tile_w,
                    tile_h,
                    level_height,
                    part_count.unwrap_or(4),
                    &limits,
                )
                .map_err(|err| LuaError::RuntimeError(format!("lurek.tilemap.newIsoMap: {err}")))?;
                lua.create_userdata(LuaIsoMap {
                    inner: Rc::new(RefCell::new(map)),
                })
            },
        )?,
    )?;
    // -- toScreenIso --
    /// Converts tile coordinates to screen-space position for isometric projection.
    /// @param | tx | number | Tile X.
    /// @param | ty | number | Tile Y.
    /// @param | tw | number | Tile width in pixels.
    /// @param | th | number | Tile height in pixels.
    /// @return | number | Screen X.
    /// @return | number | Screen Y.
    tbl.set(
        "toScreenIso",
        lua.create_function(|_, (tx, ty, tw, th): (f32, f32, f32, f32)| {
            coords::validate_projection_inputs(&[tx, ty], &[tw, th]).map_err(|err| {
                LuaError::RuntimeError(format!("lurek.tilemap.toScreenIso: {err}"))
            })?;
            let v = coords::to_screen_iso(tx, ty, tw, th);
            Ok((v.x, v.y))
        })?,
    )?;
    // -- fromScreenIso --
    /// Converts screen-space coordinates back to tile coordinates for isometric projection.
    /// @param | sx | number | Screen X.
    /// @param | sy | number | Screen Y.
    /// @param | tw | number | Tile width in pixels.
    /// @param | th | number | Tile height in pixels.
    /// @return | number | Tile X.
    /// @return | number | Tile Y.
    tbl.set(
        "fromScreenIso",
        lua.create_function(|_, (sx, sy, tw, th): (f32, f32, f32, f32)| {
            coords::validate_projection_inputs(&[sx, sy], &[tw, th]).map_err(|err| {
                LuaError::RuntimeError(format!("lurek.tilemap.fromScreenIso: {err}"))
            })?;
            let v = coords::from_screen_iso(sx, sy, tw, th);
            Ok((v.x, v.y))
        })?,
    )?;
    // -- toScreenHex --
    /// Converts axial hex coordinates to screen-space pixel position.
    /// @param | q | integer | Axial Q coordinate.
    /// @param | r | integer | Axial R coordinate.
    /// @param | size | number | Hex cell size in pixels.
    /// @return | number | Screen X.
    /// @return | number | Screen Y.
    tbl.set(
        "toScreenHex",
        lua.create_function(|_, (q, r, size): (i32, i32, f32)| {
            coords::validate_projection_inputs(&[], &[size]).map_err(|err| {
                LuaError::RuntimeError(format!("lurek.tilemap.toScreenHex: {err}"))
            })?;
            let v = coords::to_screen_hex(q, r, size);
            Ok((v.x, v.y))
        })?,
    )?;
    // -- fromScreenHex --
    /// Converts screen-space pixel coordinates to axial hex coordinates.
    /// @param | sx | number | Screen X.
    /// @param | sy | number | Screen Y.
    /// @param | size | number | Hex cell size in pixels.
    /// @return | integer | Axial Q.
    /// @return | integer | Axial R.
    tbl.set(
        "fromScreenHex",
        lua.create_function(|_, (sx, sy, size): (f32, f32, f32)| {
            coords::validate_projection_inputs(&[sx, sy], &[size]).map_err(|err| {
                LuaError::RuntimeError(format!("lurek.tilemap.fromScreenHex: {err}"))
            })?;
            let (q, r) = coords::from_screen_hex(sx, sy, size);
            Ok((q, r))
        })?,
    )?;
    // -- loadTMX --
    /// Parses a TMX (Tiled XML) string and returns a table describing the map structure.
    /// @param | xml | string | Raw TMX XML content.
    /// @param | opts | any? | Optional import policy table (`strictLayerSize`, `allowExternalTilesets`, `safePaths`, `assetRoot`) plus byte/size limits, including `maxObjects`, `maxPointsPerObject`, and `maxTotalObjectPoints` for object-layer geometry.
    /// @return | table | Parsed map with `width`, `height`, `tileWidth`, `tileHeight`, `orientation`, and `layers`, or nil on parse failure. Object layers also expose `offsetX`, `offsetY`, and `objects`; each object retains `id`, position, rotation, `shape`, polygon points, and typed custom `properties`.
    /// @return | table | Structured import error table on parse failure, or nil on success.
    /// @field | format | string | Source format identifier (`"tmx"`).
    /// @field | code | string | Stable machine-readable error code.
    /// @field | message | string | Human-readable parser message.
    /// @field | line | integer? | 1-based source line when available.
    /// @field | column | integer? | 1-based source column when available.
    /// @field | width | number | Width.
    /// @field | height | number | Height.
    /// @field | tileWidth | integer | Tile width in pixels.
    /// @field | tileHeight | integer | Tile height in pixels.
    /// @field | orientation | string | Map orientation.
    /// @field | layers | table | Layers array.
    tbl.set(
        "loadTMX",
        lua.create_function(|lua, (xml, opts): (String, Option<LuaTable>)| {
            let options = tmx_options_from_table(opts.as_ref())?;
            let tmx = match load_tmx_with_options(&xml, &options) {
                Ok(tmx) => tmx,
                Err(err) => {
                    let err_tbl = tilemap_import_error_table(
                        lua,
                        "tmx",
                        err.code,
                        &err.message,
                        err.line,
                        err.column,
                    )?;
                    return Ok((LuaValue::Nil, LuaValue::Table(err_tbl)));
                }
            };
            Ok((LuaValue::Table(tmx_map_table(lua, &tmx)?), LuaValue::Nil))
        })?,
    )?;
    // -- fromLDtk --
    /// Loads a tilemap from an LDtk JSON string, optionally targeting a specific level.
    /// @param | jsonStr | string | Raw LDtk JSON content.
    /// @param | levelName | string? | Level name to load, or nil for the first level.
    /// @param | opts | any? | Optional limits table used to bound imported layer size, chunk allocation, and decoded input bytes.
    /// @return | LTileMap | Loaded tilemap, or nil when import fails.
    /// @return | table | Structured import error table on import failure, or nil on success.
    /// @field | format | string | Source format identifier (`"ldtk"`).
    /// @field | code | string | Stable machine-readable error code.
    /// @field | message | string | Human-readable parser message.
    /// @field | line | integer? | Always nil for LDtk parser errors.
    /// @field | column | integer? | Always nil for LDtk parser errors.
    tbl.set(
        "fromLDtk",
        lua.create_function({
            let state = state.clone();
            move |lua, (json_str, level_name, opts): (String, Option<String>, Option<LuaTable>)| {
                load_ldtk_lua(lua, &json_str, level_name.as_deref(), opts.as_ref(), &state)
            }
        })?,
    )?;
    // -- newLargeMapRenderer --
    /// Creates a chunk-based large-map renderer for efficient rendering of very large maps.
    /// @param | tileW | integer | Tile width in pixels.
    /// @param | tileH | integer | Tile height in pixels.
    /// @param | opts | table? | Optional tilemap limits table.
    /// @return | LLargeMapRenderer | New large-map renderer.
    tbl.set(
        "newLargeMapRenderer",
        lua.create_function(
            |lua, (tile_w, tile_h, opts): (u32, u32, Option<LuaTable>)| {
                let limits = tilemap_limits_from_table(opts.as_ref())?;
                let renderer =
                    LargeMapRenderer::try_new(tile_w, tile_h, &limits).map_err(|err| {
                        LuaError::RuntimeError(format!("lurek.tilemap.newLargeMapRenderer: {err}"))
                    })?;
                let ud = lua.create_userdata(LuaLargeMapRenderer {
                    inner: Rc::new(RefCell::new(renderer)),
                })?;
                Ok(LuaValue::UserData(ud))
            },
        )?,
    )?;
    /// Performs the 'tilemap' operation.
    lurek.set("tilemap", tbl)?;
    Ok(())
}
