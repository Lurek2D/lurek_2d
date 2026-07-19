//! Loads LDtk JSON content into the engine tilemap model while rebuilding the geometry and layer data it needs.
//! Parses levels and tile layers, then converts pixel placements into stable grid-cell coordinates for runtime use.
//! Keeps external LDtk import rules separate from TMX and procedural paths so format-specific failures stay local.
//! Acts as the LDtk boundary between authored project files and the engine layered tilemap representation.
//! Open this file when LDtk levels, layer placement, or imported tileset reconstruction behaves incorrectly.

use super::limits::TileMapLimits;
use super::tilemap::TileMap;
use crate::tileset::TileSet;
use std::fmt;

/// Structured LDtk import error used by Rust callers and Lua bindings.
#[derive(Debug, Clone)]
/// # Fields
pub struct LdtkImportError {
    pub code: &'static str,
    pub message: String,
}

impl LdtkImportError {
    fn new(code: &'static str, message: impl Into<String>) -> Self {
        Self {
            code,
            message: message.into(),
        }
    }
}

impl fmt::Display for LdtkImportError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}: {}", self.code, self.message)
    }
}

impl std::error::Error for LdtkImportError {}

/// Parse `json_str` as an LDtk project, import the level named `level_name` (or the first level when `None`), and return a `TileMap`.
pub fn load_ldtk(json_str: &str, level_name: Option<&str>) -> Result<TileMap, LdtkImportError> {
    load_ldtk_with_limits(json_str, level_name, &TileMapLimits::default())
}

/// Parse `json_str` as an LDtk project using explicit tilemap limits.
pub fn load_ldtk_with_limits(
    json_str: &str,
    level_name: Option<&str>,
    limits: &TileMapLimits,
) -> Result<TileMap, LdtkImportError> {
    limits
        .validate()
        .map_err(|err| LdtkImportError::new("ldtk_invalid_limits", err.to_string()))?;
    if json_str.len() > limits.max_import_bytes {
        return Err(LdtkImportError::new(
            "ldtk_input_too_large",
            format!(
                "LDtk JSON uses {} bytes, exceeding limit {}",
                json_str.len(),
                limits.max_import_bytes
            ),
        ));
    }
    let root: serde_json::Value = serde_json::from_str(json_str).map_err(|e| {
        LdtkImportError::new("ldtk_json_parse", format!("LDtk JSON parse error: {e}"))
    })?;
    let mut nodes = 0u64;
    validate_json_budget(&root, limits, 0, &mut nodes)?;
    let levels = root
        .get("levels")
        .and_then(|v| v.as_array())
        .ok_or_else(|| {
            LdtkImportError::new("ldtk_missing_levels", "LDtk JSON missing 'levels' array")
        })?;
    if levels.len() as u64 > limits.max_layers as u64 {
        return Err(LdtkImportError::new(
            "ldtk_level_limit",
            format!(
                "LDtk project contains {} levels, exceeding limit {}",
                levels.len(),
                limits.max_layers
            ),
        ));
    }
    let level = if let Some(name) = level_name {
        levels
            .iter()
            .find(|l| l.get("identifier").and_then(|v| v.as_str()) == Some(name))
            .ok_or_else(|| {
                LdtkImportError::new(
                    "ldtk_level_not_found",
                    format!("LDtk level '{name}' not found"),
                )
            })?
    } else {
        levels
            .first()
            .ok_or_else(|| LdtkImportError::new("ldtk_no_levels", "LDtk project has no levels"))?
    };
    let layer_instances = level
        .get("layerInstances")
        .and_then(|v| v.as_array())
        .ok_or_else(|| {
            LdtkImportError::new(
                "ldtk_missing_layer_instances",
                "LDtk level missing 'layerInstances'",
            )
        })?;
    if layer_instances.len() > limits.max_layers {
        return Err(LdtkImportError::new(
            "ldtk_layer_limit",
            format!(
                "LDtk level contains {} layers, exceeding limit {}",
                layer_instances.len(),
                limits.max_layers
            ),
        ));
    }
    let tile_layer = layer_instances.iter().rev().find(|l| is_tile_layer(l));
    let (grid_size, map_width, map_height) = if let Some(tl) = tile_layer {
        let grid_size = u32::try_from(tl.get("__gridSize").and_then(|v| v.as_u64()).unwrap_or(16))
            .map_err(|_| LdtkImportError::new("ldtk_invalid_grid_size", "grid size exceeds u32"))?;
        let map_width = u32::try_from(tl.get("__cWid").and_then(|v| v.as_u64()).unwrap_or(0))
            .map_err(|_| LdtkImportError::new("ldtk_invalid_width", "map width exceeds u32"))?;
        let map_height = u32::try_from(tl.get("__cHei").and_then(|v| v.as_u64()).unwrap_or(0))
            .map_err(|_| LdtkImportError::new("ldtk_invalid_height", "map height exceeds u32"))?;
        (grid_size, map_width, map_height)
    } else {
        return Err(LdtkImportError::new(
            "ldtk_no_tile_layers",
            "LDtk level contains no tile or auto-layer layers",
        ));
    };
    let mut map = TileMap::try_new_with_limits(grid_size, grid_size, 16, *limits)
        .map_err(|err| LdtkImportError::new("ldtk_invalid_map_config", err.to_string()))?;
    for layer in layer_instances.iter().rev() {
        if !is_tile_layer(layer) {
            continue;
        }
        let layer_name = layer
            .get("__identifier")
            .and_then(|v| v.as_str())
            .unwrap_or("layer");
        let layer_idx = map
            .try_add_layer(layer_name, map_width, map_height)
            .map_err(|err| LdtkImportError::new("ldtk_invalid_layer", err.to_string()))?;
        let grid_tiles = layer
            .get("gridTiles")
            .or_else(|| layer.get("autoLayerTiles"))
            .and_then(|v| v.as_array());
        if let Some(tiles) = grid_tiles {
            if tiles.len() as u64 > limits.max_tile_operation_cells {
                return Err(LdtkImportError::new(
                    "ldtk_tile_limit",
                    format!(
                        "LDtk layer contains {} tile entries, exceeding limit {}",
                        tiles.len(),
                        limits.max_tile_operation_cells
                    ),
                ));
            }
        }
        let max_tile_id = grid_tiles
            .map(|tiles| {
                tiles
                    .iter()
                    .filter_map(|t| t.get("t").and_then(|v| v.as_u64()))
                    .max()
                    .unwrap_or(0)
            })
            .unwrap_or(0);
        let max_tile_id = u32::try_from(max_tile_id)
            .map_err(|_| LdtkImportError::new("ldtk_invalid_tile_id", "tile id exceeds u32"))?;
        let tileset_w_px = layer
            .get("__tilesetRelPath")
            .and_then(|_| {
                layer.get("__tilesetDefUid").and_then(|_| {
                    root.get("defs")
                        .and_then(|d| d.get("tilesets"))
                        .and_then(|ts| ts.as_array())
                        .and_then(|arr| {
                            let uid = layer.get("__tilesetDefUid")?.as_u64()?;
                            arr.iter()
                                .find(|ts| ts.get("uid").and_then(|v| v.as_u64()) == Some(uid))
                        })
                        .and_then(|ts| ts.get("pxWid").and_then(|v| v.as_u64()))
                })
            })
            .unwrap_or_else(|| u64::from(max_tile_id.saturating_add(1)) * u64::from(grid_size));
        let tileset_w_px = u32::try_from(tileset_w_px).map_err(|_| {
            LdtkImportError::new("ldtk_invalid_tileset_width", "tileset width exceeds u32")
        })?;
        let columns = if grid_size > 0 {
            (tileset_w_px / grid_size).max(1)
        } else {
            1
        };
        let tile_count = max_tile_id.checked_add(1).ok_or_else(|| {
            LdtkImportError::new("ldtk_tile_count_overflow", "tile count overflow")
        })?;
        if u64::from(tile_count) > limits.max_tiles_per_layer {
            return Err(LdtkImportError::new(
                "ldtk_tile_limit",
                format!(
                    "LDtk tileset contains {} tiles, exceeding limit {}",
                    tile_count, limits.max_tiles_per_layer
                ),
            ));
        }
        let tileset =
            TileSet::try_new(1, tile_count.max(1), columns, grid_size, grid_size, 0, 0)
                .map_err(|err| LdtkImportError::new("ldtk_invalid_tileset", err.to_string()))?;
        map.add_tileset(tileset);
        if let Some(tiles) = grid_tiles {
            for tile in tiles {
                let px = tile.get("px").and_then(|v| v.as_array());
                let tile_id = u32::try_from(tile.get("t").and_then(|v| v.as_u64()).unwrap_or(0))
                    .map_err(|_| {
                        LdtkImportError::new("ldtk_invalid_tile_id", "tile id exceeds u32")
                    })?;
                if let Some(px) = px {
                    let px_x = u32::try_from(px.first().and_then(|v| v.as_u64()).unwrap_or(0))
                        .map_err(|_| {
                            LdtkImportError::new("ldtk_invalid_position", "tile x exceeds u32")
                        })?;
                    let px_y = u32::try_from(px.get(1).and_then(|v| v.as_u64()).unwrap_or(0))
                        .map_err(|_| {
                            LdtkImportError::new("ldtk_invalid_position", "tile y exceeds u32")
                        })?;
                    let tx = if grid_size > 0 { px_x / grid_size } else { 0 };
                    let ty = if grid_size > 0 { px_y / grid_size } else { 0 };
                    let gid = tile_id.checked_add(1).ok_or_else(|| {
                        LdtkImportError::new(
                            "ldtk_invalid_tile_id",
                            "tile id cannot be converted to a GID",
                        )
                    })?;
                    map.set_tile(layer_idx, tx, ty, gid);
                }
            }
        }
    }
    Ok(map)
}

fn validate_json_budget(
    value: &serde_json::Value,
    limits: &TileMapLimits,
    depth: usize,
    nodes: &mut u64,
) -> Result<(), LdtkImportError> {
    if depth > 128 {
        return Err(LdtkImportError::new(
            "ldtk_json_depth_limit",
            "LDtk JSON nesting exceeds depth 128",
        ));
    }
    *nodes = nodes.saturating_add(1);
    if *nodes > limits.max_decoded_bytes as u64 {
        return Err(LdtkImportError::new(
            "ldtk_json_node_limit",
            "LDtk JSON node count exceeds the decoded-byte safety budget",
        ));
    }
    match value {
        serde_json::Value::Array(values) => {
            for child in values {
                validate_json_budget(child, limits, depth + 1, nodes)?;
            }
        }
        serde_json::Value::Object(values) => {
            for child in values.values() {
                validate_json_budget(child, limits, depth + 1, nodes)?;
            }
        }
        _ => {}
    }
    Ok(())
}
/// Return `true` when `layer` is a `"Tiles"` or `"AutoLayer"` layer type.
fn is_tile_layer(layer: &serde_json::Value) -> bool {
    matches!(
        layer.get("__type").and_then(|v| v.as_str()),
        Some("Tiles") | Some("AutoLayer")
    )
}
