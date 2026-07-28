//! Registers the `lurek.minimap` Lua API for minimap userdata, icon parsing, colors, and minimap rendering.

use super::awareness_api::LuaTileAwareness;
use super::camera_api::LuaCamera2D;
use super::province_api::LuaProvinceRegistry;
use super::render_api::{ensure_shader_target, LuaImage, LuaShader};
use super::tilefield_api::LuaTileField;
use super::tilelight_api::LuaTileLightMap;
use super::tilemap_api::LuaTileMap;
use super::SharedState;
use crate::minimap::province_adapter;
use crate::minimap::{
    ColorMode, FogLevel, LayerBlendMode, LayerData, MarkerAnimation, Minimap, MinimapError,
    MinimapLimits,
};
use crate::render::renderer::RenderCommand;
use crate::render::ShaderTarget;
use crate::tilefield::TileChannel;
use mlua::prelude::*;
use std::cell::RefCell;
use std::rc::Rc;

fn extend_minimap_render_commands(st: &mut SharedState, commands: Vec<RenderCommand>) {
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
/// Reads an RGBA byte color from a Lua array table, defaulting missing channels to 255.
fn parse_color_table(tbl: LuaTable) -> LuaResult<[u8; 4]> {
    let r: u8 = tbl.get(1).unwrap_or(255);
    let g: u8 = tbl.get(2).unwrap_or(255);
    let b: u8 = tbl.get(3).unwrap_or(255);
    let a: u8 = tbl.get(4).unwrap_or(255);
    Ok([r, g, b, a])
}
/// Resolves a `LuaImage` icon handle and display size for minimap object and marker textures.
struct MinimapLuaParser;

impl MinimapLuaParser {
    fn parse_lua_image_icon(
        image_ud: LuaAnyUserData,
        default_width: Option<f32>,
        default_height: Option<f32>,
        method_name: &str,
    ) -> LuaResult<(
        crate::runtime::resource_keys::TextureKey,
        f32,
        f32,
        f32,
        f32,
    )> {
        if default_width.is_some_and(|value| !value.is_finite() || value <= 0.0)
            || default_height.is_some_and(|value| !value.is_finite() || value <= 0.0)
        {
            return Err(LuaError::RuntimeError(format!(
            "lurek.minimap: {method_name} width and height overrides must be finite positive numbers"
        )));
        }
        let image = image_ud.borrow::<LuaImage>().map_err(|_| {
            LuaError::RuntimeError(format!(
                "lurek.minimap: {} expects an LImage from lurek.render.newImage()",
                method_name
            ))
        })?;
        let (texture_width, texture_height) = {
            let state = image.state.borrow();
            let Some(texture) = state.textures.get(image.key) else {
                return Err(LuaError::RuntimeError(format!(
                    "lurek.minimap: {} received an image whose texture is no longer resident",
                    method_name
                )));
            };
            (texture.width as f32, texture.height as f32)
        };
        Ok((
            image.key,
            texture_width,
            texture_height,
            default_width.unwrap_or(texture_width),
            default_height.unwrap_or(texture_height),
        ))
    }
}

fn parse_lua_image_icon(
    image_ud: LuaAnyUserData,
    default_width: Option<f32>,
    default_height: Option<f32>,
    method_name: &str,
) -> LuaResult<(
    crate::runtime::resource_keys::TextureKey,
    f32,
    f32,
    f32,
    f32,
)> {
    MinimapLuaParser::parse_lua_image_icon(image_ud, default_width, default_height, method_name)
}

fn minimap_error(err: MinimapError) -> LuaError {
    LuaError::RuntimeError(format!("lurek.minimap: {err}"))
}

fn validate_finite_number(field: &'static str, value: f32) -> LuaResult<f32> {
    if value.is_finite() {
        Ok(value)
    } else {
        Err(LuaError::RuntimeError(format!(
            "lurek.minimap: {field} must be finite"
        )))
    }
}

fn clamp_unit_color(field: &'static str, color: [f32; 4]) -> LuaResult<[f32; 4]> {
    if color.iter().any(|channel| !channel.is_finite()) {
        return Err(LuaError::RuntimeError(format!(
            "lurek.minimap: {field} must contain only finite color components"
        )));
    }
    Ok(color.map(|channel| channel.clamp(0.0, 1.0)))
}

fn minimap_set_raw_layer(
    minimap: &mut Minimap,
    layer: usize,
    cells: Vec<u8>,
) -> Result<(), MinimapError> {
    let width = minimap.grid_width();
    let height = minimap.grid_height();
    minimap.try_set_layer_data(
        layer,
        LayerData {
            cells,
            width,
            height,
        },
    )
}

fn minimap_cells_expected(minimap: &Minimap) -> usize {
    minimap.grid_width() as usize * minimap.grid_height() as usize
}

fn minimap_world_to_tile_center(tilemap: &LuaTileMap, wx: f32, wy: f32) -> (f32, f32) {
    let map = tilemap.inner.borrow();
    let (tx, ty) = map.world_to_tile(wx, wy);
    (tx as f32 + 1.0, ty as f32 + 1.0)
}

fn minimap_cells_to_lua<'lua>(lua: &'lua Lua, cells: &[u8]) -> LuaResult<LuaTable<'lua>> {
    let table = lua.create_table()?;
    for (index, value) in cells.iter().enumerate() {
        table.set(index + 1, *value)?;
    }
    Ok(table)
}

fn minimap_apply_layer_style(
    minimap: &mut Minimap,
    layer: usize,
    style: Option<LuaTable>,
) -> LuaResult<()> {
    let Some(style) = style else {
        return Ok(());
    };
    if let Some(visible) = style.get::<_, Option<bool>>("visible")? {
        minimap
            .set_layer_visible(layer, visible)
            .map_err(minimap_error)?;
    }
    if let Some(alpha) = style.get::<_, Option<f32>>("alpha")? {
        minimap
            .set_layer_alpha(layer, alpha)
            .map_err(minimap_error)?;
    }
    if let Some(blend) = style.get::<_, Option<String>>("blend")? {
        let Some(mode) = LayerBlendMode::parse_mode(blend.as_str()) else {
            return Err(LuaError::RuntimeError(format!(
                "lurek.minimap: unknown layer blend mode '{}'",
                blend
            )));
        };
        minimap
            .set_layer_blend_mode(layer, mode)
            .map_err(minimap_error)?;
    }
    if let Some(colors) = style.get::<_, Option<LuaTable>>("colors")? {
        for pair in colors.pairs::<LuaValue, LuaTable>() {
            let (key, color_table) = pair?;
            let value = match key {
                LuaValue::Integer(v) if (0..=u8::MAX as i64).contains(&v) => v as u8,
                LuaValue::Number(v) if v.fract() == 0.0 && (0.0..=u8::MAX as f64).contains(&v) => {
                    v as u8
                }
                other => {
                    return Err(LuaError::RuntimeError(format!(
                        "lurek.minimap: layer color key must be byte, got {}",
                        other.type_name()
                    )));
                }
            };
            let color = clamp_unit_color(
                "layer style color",
                [
                    color_table.get(1).unwrap_or(1.0),
                    color_table.get(2).unwrap_or(1.0),
                    color_table.get(3).unwrap_or(1.0),
                    color_table.get(4).unwrap_or(1.0),
                ],
            )?;
            minimap
                .set_layer_color(layer, value, color)
                .map_err(minimap_error)?;
        }
    }
    Ok(())
}
/// Lua-side wrapper for a minimap instance and access to render command state.
pub struct LuaMinimap {
    /// Wrapped minimap model exposed by the lurek engine.
    pub(crate) inner: Minimap,
    /// Shared runtime state used to enqueue render commands.
    state: Rc<RefCell<SharedState>>,
}
/// Provides Lua methods for minimap content, overlays, layers, interaction, and rendering.
impl LuaUserData for LuaMinimap {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- getGridWidth --
        /// Returns the width of the minimap grid in cells.
        /// @return | integer | Grid width in cells.
        methods.add_method("getGridWidth", |_, this, ()| Ok(this.inner.grid_width()));
        // -- getGridHeight --
        /// Returns the height of the minimap grid in cells.
        /// @return | integer | Grid height in cells.
        methods.add_method("getGridHeight", |_, this, ()| Ok(this.inner.grid_height()));
        // -- getCellCount --
        /// Returns the total number of grid cells.
        /// @return | integer | Cell count.
        methods.add_method("getCellCount", |_, this, ()| Ok(this.inner.grid_size()));
        // -- getGridSize --
        /// Returns the minimap grid width and height in cells.
        /// @return | integer | Grid width in cells.
        /// @return | integer | Grid height in cells.
        methods.add_method("getGridSize", |_, this, ()| {
            Ok((this.inner.grid_width(), this.inner.grid_height()))
        });
        // -- getDisplayWidth --
        /// Returns the minimap display width.
        /// @return | integer | Display width in pixels.
        methods.add_method("getDisplayWidth", |_, this, ()| {
            Ok(this.inner.display_width())
        });
        // -- getDisplayHeight --
        /// Returns the minimap display height.
        /// @return | integer | Display height in pixels.
        methods.add_method("getDisplayHeight", |_, this, ()| {
            Ok(this.inner.display_height())
        });
        // -- getDisplaySize --
        /// Returns the minimap display width and height in pixels.
        /// @return | integer | Display width in pixels.
        /// @return | integer | Display height in pixels.
        methods.add_method("getDisplaySize", |_, this, ()| {
            Ok((this.inner.display_width(), this.inner.display_height()))
        });
        // -- setDisplaySize --
        /// Sets the minimap display width and height in pixels.
        /// @param | w | integer | Display width in pixels.
        /// @param | h | integer | Display height in pixels.
        methods.add_method_mut("setDisplaySize", |_, this, (w, h): (u32, u32)| {
            this.inner.try_set_display_size(w, h).map_err(minimap_error)
        });
        // -- setShader --
        /// Binds or clears a `mapviz` shader for command-rendered minimap visualization.
        /// @param | shader | LShader? | Shader created by `lurek.render.newShader(code, { target = "mapviz" })`, or nil to clear.
        methods.add_method_mut("setShader", |_, this, shader: Option<LuaAnyUserData>| {
            let shader_key = if let Some(shader_ud) = shader {
                let key = shader_ud
                    .borrow::<LuaShader>()
                    .map_err(|_| {
                        LuaError::RuntimeError(
                            "LMinimap:setShader expects LShader from lurek.render.newShader"
                                .to_string(),
                        )
                    })?
                    .key;
                let st = this.state.borrow();
                ensure_shader_target(&st, key, ShaderTarget::MapViz, "LMinimap:setShader")?;
                Some(key)
            } else {
                None
            };
            this.inner.set_shader(shader_key);
            Ok(())
        });
        // -- getShader --
        /// Returns the currently bound command-render minimap shader, or nil.
        /// @return | LShader | Bound shader handle.
        methods.add_method("getShader", |_, this, ()| {
            Ok(this.inner.get_shader().map(|key| LuaShader {
                key,
                state: this.state.clone(),
            }))
        });
        // -- setTerrain --
        /// Sets terrain type for a one-based grid cell.
        /// @param | x | integer | One-based grid x coordinate.
        /// @param | y | integer | One-based grid y coordinate.
        /// @param | terrain_type | integer | Terrain type id.
        methods.add_method_mut(
            "setTerrain",
            |_, this, (x, y, terrain_type): (u32, u32, u32)| {
                if x == 0 || y == 0 {
                    return Err(LuaError::RuntimeError(
                        "lurek.minimap: setTerrain coordinates are 1-based".into(),
                    ));
                }
                this.inner.set_terrain(x - 1, y - 1, terrain_type);
                Ok(())
            },
        );
        // -- getTerrain --
        /// Returns terrain type for a one-based grid cell.
        /// @param | x | integer | One-based grid x coordinate.
        /// @param | y | integer | One-based grid y coordinate.
        /// @return | integer | Terrain type id.
        methods.add_method("getTerrain", |_, this, (x, y): (u32, u32)| {
            if x == 0 || y == 0 {
                return Err(LuaError::RuntimeError(
                    "lurek.minimap: getTerrain coordinates are 1-based".into(),
                ));
            }
            Ok(this.inner.get_terrain(x - 1, y - 1))
        });
        // -- setTerrainData --
        /// Replaces terrain data from a flat array table.
        /// @param | data | table | Array table of terrain type ids.
        methods.add_method_mut("setTerrainData", |_, this, data: LuaTable| {
            let len = data.len()? as usize;
            let mut values = Vec::with_capacity(len);
            for i in 1..=len {
                let v: u32 = data.get(i)?;
                values.push(v);
            }
            this.inner
                .try_set_terrain_data(&values)
                .map_err(minimap_error)
        });
        // -- setTerrainColor --
        /// Sets the RGBA display color for a terrain type.
        /// @param | terrain_type | integer | Terrain type id.
        /// @param | r | number | Red channel.
        /// @param | g | number | Green channel.
        /// @param | b | number | Blue channel.
        /// @param | a | number? | Alpha channel, defaults to 1.0.
        methods.add_method_mut(
            "setTerrainColor",
            |_, this, (terrain_type, r, g, b, a): (u32, f32, f32, f32, Option<f32>)| {
                let color = clamp_unit_color("terrain color", [r, g, b, a.unwrap_or(1.0)])?;
                this.inner.set_terrain_color(terrain_type, color);
                Ok(())
            },
        );
        // -- getTerrainColor --
        /// Returns RGBA color for a terrain type.
        /// @param | terrain_type | integer | Terrain type id.
        /// @return | number | Red channel.
        /// @return | number | Green channel.
        /// @return | number | Blue channel.
        /// @return | number | Alpha channel.
        methods.add_method("getTerrainColor", |_, this, terrain_type: u32| {
            let c = this.inner.get_terrain_color(terrain_type);
            Ok((c[0], c[1], c[2], c[3]))
        });
        // -- setTileDescription --
        /// Sets text description for a tile type.
        /// @param | type_id | integer | Tile type id.
        /// @param | desc | string | Description text.
        methods.add_method_mut(
            "setTileDescription",
            |_, this, (type_id, desc): (u32, String)| {
                this.inner.set_tile_description(type_id, desc);
                Ok(())
            },
        );
        // -- getTileDescription --
        /// Returns text description for a tile type.
        /// @param | type_id | integer | Tile type id.
        /// @return | string | Description text, or nil when missing.
        methods.add_method("getTileDescription", |_, this, type_id: u32| {
            Ok(this
                .inner
                .get_tile_description(type_id)
                .map(|s| s.to_string()))
        });
        // -- setFogEnabled --
        /// Enables or disables the minimap fog display.
        /// @param | enabled | boolean | Fog enabled flag.
        methods.add_method_mut("setFogEnabled", |_, this, enabled: bool| {
            this.inner.set_fog_enabled(enabled);
            Ok(())
        });
        // -- isFogEnabled --
        /// Returns whether fog display is enabled.
        /// @return | boolean | True when fog is enabled.
        methods.add_method("isFogEnabled", |_, this, ()| Ok(this.inner.fog_enabled()));
        // -- setFogLevel --
        /// Sets fog level for a one-based grid cell.
        /// @param | x | integer | One-based grid x coordinate.
        /// @param | y | integer | One-based grid y coordinate.
        /// @param | level | integer | Fog level byte.
        methods.add_method_mut("setFogLevel", |_, this, (x, y, level): (u32, u32, u8)| {
            if x == 0 || y == 0 {
                return Err(LuaError::RuntimeError(
                    "lurek.minimap: setFogLevel coordinates are 1-based".into(),
                ));
            }
            this.inner
                .set_fog_level(x - 1, y - 1, FogLevel::from_u8(level));
            Ok(())
        });
        // -- getFogLevel --
        /// Returns fog level for a one-based grid cell.
        /// @param | x | integer | One-based grid x coordinate.
        /// @param | y | integer | One-based grid y coordinate.
        /// @return | integer | Fog level byte.
        methods.add_method("getFogLevel", |_, this, (x, y): (u32, u32)| {
            if x == 0 || y == 0 {
                return Err(LuaError::RuntimeError(
                    "lurek.minimap: getFogLevel coordinates are 1-based".into(),
                ));
            }
            Ok(this.inner.get_fog_level(x - 1, y - 1) as u8)
        });
        // -- setFogColor --
        /// Sets the RGBA fog overlay color for covered cells.
        /// @param | r | number | Red channel.
        /// @param | g | number | Green channel.
        /// @param | b | number | Blue channel.
        /// @param | a | number? | Alpha channel, defaults to 0.8.
        methods.add_method_mut(
            "setFogColor",
            |_, this, (r, g, b, a): (f32, f32, f32, Option<f32>)| {
                let color = clamp_unit_color("fog color", [r, g, b, a.unwrap_or(0.8)])?;
                this.inner.set_fog_color(color);
                Ok(())
            },
        );
        // -- getFogColor --
        /// Returns the current RGBA fog overlay color.
        /// @return | number | Red channel.
        /// @return | number | Green channel.
        /// @return | number | Blue channel.
        /// @return | number | Alpha channel.
        methods.add_method("getFogColor", |_, this, ()| {
            let c = this.inner.fog_color();
            Ok((c[0], c[1], c[2], c[3]))
        });
        // -- setFogData --
        /// Replaces fog data from a flat array table.
        /// @param | data | table | Array table of fog level bytes.
        methods.add_method_mut("setFogData", |_, this, data: LuaTable| {
            let len = data.len()? as usize;
            let mut bytes = Vec::with_capacity(len);
            for i in 1..=len {
                let v: u8 = data.get(i)?;
                bytes.push(v);
            }
            this.inner.try_set_fog_data(&bytes).map_err(minimap_error)
        });
        // -- syncProvinceRegistry --
        /// Copies province registry terrain, visibility, and palette data into this minimap.
        /// @param | registry | LProvinceRegistry | Province registry handle.
        /// @param | opts | table? | Optional `{terrain?, visibility?, palette?}` booleans, all default true.
        methods.add_method_mut(
            "syncProvinceRegistry",
            |_, this, (registry_ud, opts): (LuaAnyUserData, Option<LuaTable>)| {
                let registry = registry_ud.borrow::<LuaProvinceRegistry>().map_err(|_| {
                    LuaError::RuntimeError(
                        "lurek.minimap: syncProvinceRegistry expects an LProvinceRegistry"
                            .to_string(),
                    )
                })?;
                let terrain = opts
                    .as_ref()
                    .map(|t| t.get::<_, Option<bool>>("terrain"))
                    .transpose()?
                    .flatten()
                    .unwrap_or(true);
                let visibility = opts
                    .as_ref()
                    .map(|t| t.get::<_, Option<bool>>("visibility"))
                    .transpose()?
                    .flatten()
                    .unwrap_or(true);
                let palette = opts
                    .as_ref()
                    .map(|t| t.get::<_, Option<bool>>("palette"))
                    .transpose()?
                    .flatten()
                    .unwrap_or(true);

                registry.with_registry(|province_registry| {
                    if terrain {
                        province_adapter::apply_terrain(&mut this.inner, province_registry);
                    }
                    if visibility {
                        province_adapter::apply_visibility(&mut this.inner, province_registry);
                    }
                    if palette {
                        province_adapter::apply_terrain_palette(&mut this.inner, province_registry);
                    }
                })?;
                Ok(())
            },
        );
        // -- syncTileMapTerrain --
        /// Copies tile GIDs from an `LTileMap` layer into minimap terrain cells.
        /// @param | tilemap | LTileMap | Source tilemap.
        /// @param | opts | table? | Optional `{layer=1, emptyTerrain=1, solidTerrain=2, terrainByGid?, blockedGids?}`.
        methods.add_method_mut(
            "syncTileMapTerrain",
            |_, this, (tilemap_ud, opts): (LuaAnyUserData, Option<LuaTable>)| {
                let tilemap = tilemap_ud.borrow::<LuaTileMap>().map_err(|_| {
                    LuaError::RuntimeError(
                        "lurek.minimap: syncTileMapTerrain expects an LTileMap".to_string(),
                    )
                })?;
                let layer = opts
                    .as_ref()
                    .and_then(|t| t.get::<_, Option<usize>>("layer").ok().flatten())
                    .unwrap_or(1)
                    .saturating_sub(1);
                let empty_terrain = opts
                    .as_ref()
                    .and_then(|t| {
                        t.get::<_, Option<u32>>("emptyTerrain")
                            .ok()
                            .flatten()
                            .or_else(|| t.get::<_, Option<u32>>("empty_terrain").ok().flatten())
                    })
                    .unwrap_or(1);
                let solid_terrain = opts
                    .as_ref()
                    .and_then(|t| {
                        t.get::<_, Option<u32>>("solidTerrain")
                            .ok()
                            .flatten()
                            .or_else(|| t.get::<_, Option<u32>>("solid_terrain").ok().flatten())
                    })
                    .unwrap_or(2);
                let terrain_by_gid = opts.as_ref().and_then(|t| {
                    t.get::<_, Option<LuaTable>>("terrainByGid")
                        .ok()
                        .flatten()
                        .or_else(|| {
                            t.get::<_, Option<LuaTable>>("terrain_by_gid")
                                .ok()
                                .flatten()
                        })
                });
                let blocked_gids = opts.as_ref().and_then(|t| {
                    t.get::<_, Option<LuaTable>>("blockedGids")
                        .ok()
                        .flatten()
                        .or_else(|| t.get::<_, Option<LuaTable>>("blocked_gids").ok().flatten())
                });
                let map = tilemap.inner.borrow();
                for y in 0..this.inner.grid_height() {
                    for x in 0..this.inner.grid_width() {
                        let gid = map.get_tile(layer, x, y);
                        let mut terrain = empty_terrain;
                        if let Some(table) = terrain_by_gid.as_ref() {
                            if let Some(value) = table.get::<_, Option<u32>>(gid).ok().flatten() {
                                terrain = value;
                            }
                        } else if let Some(table) = blocked_gids.as_ref() {
                            if table
                                .get::<_, Option<bool>>(gid)
                                .ok()
                                .flatten()
                                .unwrap_or(false)
                            {
                                terrain = solid_terrain;
                            }
                        } else if gid != 0 {
                            terrain = gid;
                        }
                        this.inner.set_terrain(x, y, terrain);
                    }
                }
                Ok(())
            },
        );
        // -- setCenterFromTileMapWorld --
        /// Converts tilemap world coordinates into one-based tile coordinates and centers this minimap.
        methods.add_method_mut(
            "setCenterFromTileMapWorld",
            |_, this, (tilemap_ud, wx, wy): (LuaAnyUserData, f32, f32)| {
                let tilemap = tilemap_ud.borrow::<LuaTileMap>().map_err(|_| {
                    LuaError::RuntimeError(
                        "lurek.minimap: setCenterFromTileMapWorld expects an LTileMap".to_string(),
                    )
                })?;
                let (tx, ty) = minimap_world_to_tile_center(&tilemap, wx, wy);
                this.inner.try_set_center(tx, ty).map_err(minimap_error)?;
                Ok((tx, ty))
            },
        );
        // -- setViewportFromTileMapWorld --
        /// Converts a tilemap world rectangle into a minimap viewport rectangle.
        methods.add_method_mut(
            "setViewportFromTileMapWorld",
            |_, this, (tilemap_ud, x, y, w, h): (LuaAnyUserData, f32, f32, f32, f32)| {
                let tilemap = tilemap_ud.borrow::<LuaTileMap>().map_err(|_| {
                    LuaError::RuntimeError(
                        "lurek.minimap: setViewportFromTileMapWorld expects an LTileMap"
                            .to_string(),
                    )
                })?;
                let (tx1, ty1) = minimap_world_to_tile_center(&tilemap, x, y);
                let (tx2, ty2) = minimap_world_to_tile_center(&tilemap, x + w, y + h);
                let vw = (tx2 - tx1 + 1.0).max(1.0);
                let vh = (ty2 - ty1 + 1.0).max(1.0);
                this.inner
                    .try_set_viewport_rect(tx1, ty1, vw, vh)
                    .map_err(minimap_error)?;
                Ok((tx1, ty1, vw, vh))
            },
        );
        // -- setLayerStyle --
        /// Applies common raw-layer style fields: visible, alpha, blend, and colors.
        methods.add_method_mut(
            "setLayerStyle",
            |_, this, (layer, style): (usize, LuaTable)| {
                minimap_apply_layer_style(&mut this.inner, layer, Some(style))
            },
        );
        // -- syncTileFieldBlockLayer --
        /// Copies one `LTileField` blocker channel layer into a minimap raw data layer.
        methods.add_method_mut(
            "syncTileFieldBlockLayer",
            |lua,
             this,
             (field_ud, channel, layer, opts): (
                LuaAnyUserData,
                String,
                usize,
                Option<LuaTable>,
            )| {
                let field = field_ud.borrow::<LuaTileField>().map_err(|_| {
                    LuaError::RuntimeError(
                        "lurek.minimap: syncTileFieldBlockLayer expects an LTileField".to_string(),
                    )
                })?;
                let channel = TileChannel::parse(&channel)
                    .map_err(|e| LuaError::RuntimeError(format!("lurek.minimap: {e}")))?;
                let z = opts
                    .as_ref()
                    .and_then(|t| t.get::<_, Option<u32>>("z").ok().flatten())
                    .unwrap_or(1)
                    .saturating_sub(1);
                let values = field.inner.borrow().export_block_layer(channel, z);
                let cells: Vec<u8> = values
                    .into_iter()
                    .map(|v| if v { 255 } else { 0 })
                    .collect();
                if cells.len() != minimap_cells_expected(&this.inner) {
                    return Err(LuaError::RuntimeError(
                        "lurek.minimap: tilefield layer size does not match minimap grid"
                            .to_string(),
                    ));
                }
                minimap_set_raw_layer(&mut this.inner, layer, cells.clone())
                    .map_err(minimap_error)?;
                let style = opts
                    .as_ref()
                    .and_then(|t| t.get::<_, Option<LuaTable>>("style").ok().flatten());
                minimap_apply_layer_style(&mut this.inner, layer, style)?;
                minimap_cells_to_lua(lua, &cells)
            },
        );
        // -- syncTileFieldCostLayer --
        /// Copies one `LTileField` cost channel layer into a minimap raw byte layer.
        methods.add_method_mut(
            "syncTileFieldCostLayer",
            |lua,
             this,
             (field_ud, channel, layer, opts): (
                LuaAnyUserData,
                String,
                usize,
                Option<LuaTable>,
            )| {
                let field = field_ud.borrow::<LuaTileField>().map_err(|_| {
                    LuaError::RuntimeError(
                        "lurek.minimap: syncTileFieldCostLayer expects an LTileField".to_string(),
                    )
                })?;
                let channel = TileChannel::parse(&channel)
                    .map_err(|e| LuaError::RuntimeError(format!("lurek.minimap: {e}")))?;
                let z = opts
                    .as_ref()
                    .and_then(|t| t.get::<_, Option<u32>>("z").ok().flatten())
                    .unwrap_or(1)
                    .saturating_sub(1);
                let scale = opts
                    .as_ref()
                    .and_then(|t| t.get::<_, Option<f32>>("scale").ok().flatten())
                    .unwrap_or(1.0);
                let values = field.inner.borrow().export_cost_layer(channel, z);
                let cells: Vec<u8> = values
                    .into_iter()
                    .map(|v| (v * scale).round().clamp(0.0, 255.0) as u8)
                    .collect();
                if cells.len() != minimap_cells_expected(&this.inner) {
                    return Err(LuaError::RuntimeError(
                        "lurek.minimap: tilefield layer size does not match minimap grid"
                            .to_string(),
                    ));
                }
                minimap_set_raw_layer(&mut this.inner, layer, cells.clone())
                    .map_err(minimap_error)?;
                let style = opts
                    .as_ref()
                    .and_then(|t| t.get::<_, Option<LuaTable>>("style").ok().flatten());
                minimap_apply_layer_style(&mut this.inner, layer, style)?;
                minimap_cells_to_lua(lua, &cells)
            },
        );
        // -- syncTileLightLayer --
        /// Copies computed tilelight luma into a minimap raw byte layer.
        methods.add_method_mut(
            "syncTileLightLayer",
            |lua, this, (light_ud, layer, opts): (LuaAnyUserData, usize, Option<LuaTable>)| {
                let light = light_ud.borrow::<LuaTileLightMap>().map_err(|_| {
                    LuaError::RuntimeError(
                        "lurek.minimap: syncTileLightLayer expects an LTileLightMap".to_string(),
                    )
                })?;
                let z = opts
                    .as_ref()
                    .and_then(|t| t.get::<_, Option<u32>>("z").ok().flatten())
                    .unwrap_or(1)
                    .saturating_sub(1);
                let scale = opts
                    .as_ref()
                    .and_then(|t| t.get::<_, Option<f32>>("scale").ok().flatten())
                    .unwrap_or(255.0);
                let field = light.field.borrow();
                let values = light
                    .inner
                    .borrow()
                    .ensure_current(&field)
                    .and_then(|_| light.inner.borrow().export_layer(z))
                    .map_err(|e| LuaError::RuntimeError(format!("lurek.minimap: {e}")))?;
                let cells: Vec<u8> = values
                    .into_iter()
                    .map(|v| (v.luma() * scale).round().clamp(0.0, 255.0) as u8)
                    .collect();
                if cells.len() != minimap_cells_expected(&this.inner) {
                    return Err(LuaError::RuntimeError(
                        "lurek.minimap: tilelight layer size does not match minimap grid"
                            .to_string(),
                    ));
                }
                minimap_set_raw_layer(&mut this.inner, layer, cells.clone())
                    .map_err(minimap_error)?;
                let style = opts
                    .as_ref()
                    .and_then(|t| t.get::<_, Option<LuaTable>>("style").ok().flatten());
                minimap_apply_layer_style(&mut this.inner, layer, style)?;
                minimap_cells_to_lua(lua, &cells)
            },
        );
        // -- syncTileAwarenessFog --
        /// Copies explored/visible masks from `LTileAwareness` into minimap fog data.
        methods.add_method_mut(
            "syncTileAwarenessFog",
            |lua,
             this,
             (awareness_ud, player, opts): (LuaAnyUserData, String, Option<LuaTable>)| {
                let awareness = awareness_ud.borrow::<LuaTileAwareness>().map_err(|_| {
                    LuaError::RuntimeError(
                        "lurek.minimap: syncTileAwarenessFog expects an LTileAwareness".to_string(),
                    )
                })?;
                let hidden_value = opts
                    .as_ref()
                    .and_then(|t| {
                        t.get::<_, Option<u8>>("hiddenValue")
                            .ok()
                            .flatten()
                            .or_else(|| t.get::<_, Option<u8>>("hidden_value").ok().flatten())
                    })
                    .unwrap_or(0);
                let explored_value = opts
                    .as_ref()
                    .and_then(|t| {
                        t.get::<_, Option<u8>>("exploredValue")
                            .ok()
                            .flatten()
                            .or_else(|| t.get::<_, Option<u8>>("explored_value").ok().flatten())
                    })
                    .unwrap_or(1);
                let visible_value = opts
                    .as_ref()
                    .and_then(|t| {
                        t.get::<_, Option<u8>>("visibleValue")
                            .ok()
                            .flatten()
                            .or_else(|| t.get::<_, Option<u8>>("visible_value").ok().flatten())
                    })
                    .unwrap_or(2);
                let include_explored = opts
                    .as_ref()
                    .and_then(|t| {
                        t.get::<_, Option<bool>>("includeExplored")
                            .ok()
                            .flatten()
                            .or_else(|| t.get::<_, Option<bool>>("include_explored").ok().flatten())
                    })
                    .unwrap_or(true);
                let z = opts
                    .as_ref()
                    .and_then(|t| t.get::<_, Option<u32>>("z").ok().flatten())
                    .unwrap_or(1)
                    .saturating_sub(1);
                let mut cells = vec![hidden_value; minimap_cells_expected(&this.inner)];
                let width = this.inner.grid_width();
                let height = this.inner.grid_height();
                if include_explored {
                    for y in 0..height {
                        for x in 0..width {
                            let coord = crate::tilefield::CellCoord { x, y, z };
                            if awareness.inner.borrow().is_explored(&player, coord) {
                                cells[(y * width + x) as usize] = explored_value;
                            }
                        }
                    }
                }
                for coord in awareness.inner.borrow().visible_cells(&player, Some(z)) {
                    if coord.x < width && coord.y < height {
                        cells[(coord.y * width + coord.x) as usize] = visible_value;
                    }
                }
                this.inner.try_set_fog_data(&cells).map_err(minimap_error)?;
                if opts
                    .as_ref()
                    .and_then(|t| t.get::<_, Option<bool>>("enable").ok().flatten())
                    .unwrap_or(true)
                {
                    this.inner.set_fog_enabled(true);
                }
                minimap_cells_to_lua(lua, &cells)
            },
        );
        // -- syncTileAwarenessLayer --
        /// Copies visible or action masks from `LTileAwareness` into a minimap raw layer.
        methods.add_method_mut(
            "syncTileAwarenessLayer",
            |lua,
             this,
             (awareness_ud, player, kind, layer, opts): (
                LuaAnyUserData,
                String,
                String,
                usize,
                Option<LuaTable>,
            )| {
                let awareness = awareness_ud.borrow::<LuaTileAwareness>().map_err(|_| {
                    LuaError::RuntimeError(
                        "lurek.minimap: syncTileAwarenessLayer expects an LTileAwareness"
                            .to_string(),
                    )
                })?;
                let hidden_value = opts
                    .as_ref()
                    .and_then(|t| {
                        t.get::<_, Option<u8>>("hiddenValue")
                            .ok()
                            .flatten()
                            .or_else(|| t.get::<_, Option<u8>>("hidden_value").ok().flatten())
                    })
                    .unwrap_or(0);
                let mark_value = opts
                    .as_ref()
                    .and_then(|t| t.get::<_, Option<u8>>("value").ok().flatten())
                    .unwrap_or(1);
                let z = opts
                    .as_ref()
                    .and_then(|t| t.get::<_, Option<u32>>("z").ok().flatten())
                    .unwrap_or(1)
                    .saturating_sub(1);
                let cells_to_mark = match kind.as_str() {
                    "visible" => awareness.inner.borrow().visible_cells(&player, Some(z)),
                    "action" => awareness.inner.borrow().action_cells(&player, Some(z)),
                    _ => {
                        return Err(LuaError::RuntimeError(
                            "lurek.minimap: awareness layer kind must be 'visible' or 'action'"
                                .to_string(),
                        ))
                    }
                };
                let mut cells = vec![hidden_value; minimap_cells_expected(&this.inner)];
                let width = this.inner.grid_width();
                let height = this.inner.grid_height();
                for coord in cells_to_mark {
                    if coord.x < width && coord.y < height {
                        cells[(coord.y * width + coord.x) as usize] = mark_value;
                    }
                }
                minimap_set_raw_layer(&mut this.inner, layer, cells.clone())
                    .map_err(minimap_error)?;
                let style = opts
                    .as_ref()
                    .and_then(|t| t.get::<_, Option<LuaTable>>("style").ok().flatten());
                minimap_apply_layer_style(&mut this.inner, layer, style)?;
                minimap_cells_to_lua(lua, &cells)
            },
        );
        // -- addObjectType --
        /// Adds an object type and returns its one-based index.
        /// @param | name | string | Object type name.
        /// @param | r | number | Red channel.
        /// @param | g | number | Green channel.
        /// @param | b | number | Blue channel.
        /// @param | a | number? | Alpha channel, defaults to 1.0.
        /// @return | integer | One-based object type index.
        methods.add_method_mut(
            "addObjectType",
            |_, this, (name, r, g, b, a): (String, f32, f32, f32, Option<f32>)| {
                let color = clamp_unit_color("object type color", [r, g, b, a.unwrap_or(1.0)])?;
                let idx = this.inner.add_object_type(name, color);
                Ok(idx + 1)
            },
        );
        // -- setObjectTypeVisible --
        /// Sets visibility for an object type by one-based index.
        /// @param | type_idx | integer | One-based object type index.
        /// @param | visible | boolean | Visibility flag.
        methods.add_method_mut(
            "setObjectTypeVisible",
            |_, this, (type_idx, visible): (usize, bool)| {
                if type_idx == 0 {
                    return Err(LuaError::RuntimeError(
                        "lurek.minimap: object type index is 1-based".into(),
                    ));
                }
                if this.inner.set_object_type_visible(type_idx - 1, visible) {
                    Ok(())
                } else {
                    Err(minimap_error(MinimapError::MissingObjectType {
                        index: type_idx - 1,
                    }))
                }
            },
        );
        // -- isObjectTypeVisible --
        /// Returns visibility for an object type by one-based index.
        /// @param | type_idx | integer | One-based object type index.
        /// @return | boolean | True when the object type is visible.
        methods.add_method("isObjectTypeVisible", |_, this, type_idx: usize| {
            if type_idx == 0 {
                return Err(LuaError::RuntimeError(
                    "lurek.minimap: object type index is 1-based".into(),
                ));
            }
            Ok(this.inner.is_object_type_visible(type_idx - 1))
        });
        // -- getObjectTypeCount --
        /// Returns the number of object types.
        /// @return | integer | Object type count.
        methods.add_method("getObjectTypeCount", |_, this, ()| {
            Ok(this.inner.object_type_count())
        });
        // -- setObjectTypeTexture --
        /// Assigns an image texture to an object type.
        /// @param | type_idx | integer | One-based object type index.
        /// @param | image_ud | LImage | Image handle from `lurek.render.newImage`.
        /// @param | width | number? | Display width override.
        /// @param | height | number? | Display height override.
        methods.add_method_mut(
            "setObjectTypeTexture",
            |_,
             this,
             (type_idx, image_ud, width, height): (
                usize,
                LuaAnyUserData,
                Option<f32>,
                Option<f32>,
            )| {
                if type_idx == 0 {
                    return Err(LuaError::RuntimeError(
                        "lurek.minimap: object type index is 1-based".into(),
                    ));
                }
                let (texture_key, tex_w, tex_h, display_w, display_h) =
                    parse_lua_image_icon(image_ud, width, height, "setObjectTypeTexture")?;
                if this.inner.set_object_type_texture(
                    type_idx - 1,
                    texture_key,
                    tex_w,
                    tex_h,
                    display_w,
                    display_h,
                ) {
                    Ok(())
                } else {
                    Err(minimap_error(MinimapError::MissingObjectType {
                        index: type_idx - 1,
                    }))
                }
            },
        );
        // -- clearObjectTypeTexture --
        /// Clears image texture for an object type.
        /// @param | type_idx | integer | One-based object type index.
        methods.add_method_mut("clearObjectTypeTexture", |_, this, type_idx: usize| {
            if type_idx == 0 {
                return Err(LuaError::RuntimeError(
                    "lurek.minimap: object type index is 1-based".into(),
                ));
            }
            this.inner.clear_object_type_texture(type_idx - 1);
            Ok(())
        });
        // -- setObject --
        /// Adds or updates an object on the minimap.
        /// @param | id | integer | Object id.
        /// @param | x | number | Object x coordinate.
        /// @param | y | number | Object y coordinate.
        /// @param | type_idx | integer | One-based object type index.
        /// @param | owner | integer? | Owner id, defaults to 0.
        methods.add_method_mut(
            "setObject",
            |_, this, (id, x, y, type_idx, owner): (u32, f32, f32, usize, Option<u32>)| {
                if type_idx == 0 {
                    return Err(LuaError::RuntimeError(
                        "lurek.minimap: object type index is 1-based".into(),
                    ));
                }
                let x = validate_finite_number("object x", x)?;
                let y = validate_finite_number("object y", y)?;
                if this
                    .inner
                    .set_object(id, x, y, type_idx - 1, owner.unwrap_or(0))
                {
                    Ok(())
                } else if type_idx > this.inner.object_type_count() {
                    Err(minimap_error(MinimapError::MissingObjectType {
                        index: type_idx - 1,
                    }))
                } else {
                    Err(minimap_error(MinimapError::ObjectLimitExceeded {
                        limit: this.inner.limits().max_objects,
                    }))
                }
            },
        );
        // -- setObjects --
        /// Applies object icon updates atomically for one Lua-owned minimap refresh.
        /// This does not inspect ECS or network state; Lua prepares the compact update records.
        /// @param | updates | table | Array of `{ id, x, y, type_idx, owner? }` object records.
        /// @return | boolean | True when every update was accepted and committed together.
        methods.add_method_mut("setObjects", |_, this, updates: LuaTable| {
            let mut parsed = Vec::with_capacity(updates.raw_len());
            for entry in updates.sequence_values::<LuaTable>() {
                let entry = entry?;
                let id: u32 = entry.get("id")?;
                let x: f32 = validate_finite_number("object x", entry.get("x")?)?;
                let y: f32 = validate_finite_number("object y", entry.get("y")?)?;
                let type_idx: usize = entry.get("type_idx")?;
                if type_idx == 0 {
                    return Err(LuaError::RuntimeError(
                        "lurek.minimap.LMinimap:setObjects: type_idx is 1-based".to_string(),
                    ));
                }
                let owner = entry.get::<_, Option<u32>>("owner")?.unwrap_or(0);
                parsed.push((id, x, y, type_idx - 1, owner));
            }
            if this.inner.set_objects_atomic(&parsed) {
                Ok(true)
            } else {
                Err(LuaError::RuntimeError(
                    "lurek.minimap.LMinimap:setObjects: batch has duplicate ids, invalid types, non-finite coordinates, or exceeds object capacity"
                        .to_string(),
                ))
            }
        });
        // -- removeObject --
        /// Removes a minimap object by its unique id.
        /// @param | id | integer | Object id.
        /// @return | boolean | True when an object was removed.
        methods.add_method_mut("removeObject", |_, this, id: u32| {
            Ok(this.inner.remove_object(id))
        });
        // -- clearObjects --
        /// Clears all objects from the minimap.
        methods.add_method_mut("clearObjects", |_, this, ()| {
            this.inner.clear_objects();
            Ok(())
        });
        // -- getObjectCount --
        /// Returns the number of objects on the minimap.
        /// @return | integer | Object count.
        methods.add_method("getObjectCount", |_, this, ()| {
            Ok(this.inner.object_count())
        });
        // -- setOwnerColor --
        /// Sets the RGBA display color for an owner id.
        /// @param | owner | integer | Owner id.
        /// @param | r | number | Red channel.
        /// @param | g | number | Green channel.
        /// @param | b | number | Blue channel.
        /// @param | a | number? | Alpha channel, defaults to 1.0.
        methods.add_method_mut(
            "setOwnerColor",
            |_, this, (owner, r, g, b, a): (u32, f32, f32, f32, Option<f32>)| {
                let color = clamp_unit_color("owner color", [r, g, b, a.unwrap_or(1.0)])?;
                this.inner.set_owner_color(owner, color);
                Ok(())
            },
        );
        // -- getOwnerColor --
        /// Returns the current RGBA color for an owner id.
        /// @param | owner | integer | Owner id.
        /// @return | number | Red channel.
        /// @return | number | Green channel.
        /// @return | number | Blue channel.
        /// @return | number | Alpha channel.
        methods.add_method("getOwnerColor", |_, this, owner: u32| {
            let c = this.inner.get_owner_color(owner);
            Ok((c[0], c[1], c[2], c[3]))
        });
        // -- setColorMode --
        /// Sets the minimap color mode to terrain or political.
        /// @param | mode | string | Color mode name, expected `terrain` or `political`.
        methods.add_method_mut("setColorMode", |_, this, mode: String| {
            let cm = ColorMode::parse_mode(&mode).ok_or_else(|| {
                LuaError::RuntimeError(format!(
                    "lurek.minimap: unknown color mode '{}', expected 'terrain' or 'political'",
                    mode
                ))
            })?;
            this.inner.set_color_mode(cm);
            Ok(())
        });
        // -- getColorMode --
        /// Returns the current minimap color mode.
        /// @return | string | Color mode name.
        methods.add_method("getColorMode", |_, this, ()| {
            Ok(this.inner.color_mode().as_str())
        });
        // -- setZoom --
        /// Sets the minimap zoom magnification level.
        /// @param | zoom | number | Zoom value.
        methods.add_method_mut("setZoom", |_, this, zoom: f32| {
            this.inner.try_set_zoom(zoom).map_err(minimap_error)
        });
        // -- getZoom --
        /// Returns the current minimap zoom magnification level.
        /// @return | number | Zoom value.
        methods.add_method("getZoom", |_, this, ()| Ok(this.inner.zoom()));
        // -- setCenter --
        /// Sets the minimap world-space center position.
        /// @param | x | number | Center x coordinate.
        /// @param | y | number | Center y coordinate.
        methods.add_method_mut("setCenter", |_, this, (x, y): (f32, f32)| {
            this.inner.try_set_center(x, y).map_err(minimap_error)
        });
        // -- trackCamera --
        /// Centers the minimap and viewport rectangle from a camera handle.
        /// @param | camera_ud | LCamera | Camera handle from `lurek.camera.newCamera`.
        methods.add_method_mut("trackCamera", |_, this, camera_ud: LuaAnyUserData| {
            let camera = camera_ud.borrow::<LuaCamera2D>().map_err(|_| {
                LuaError::RuntimeError(
                    "lurek.minimap: trackCamera expects an LCamera from lurek.camera.newCamera()"
                        .into(),
                )
            })?;
            let (camera_x, camera_y) = camera.position();
            let (vx, vy, vw, vh) = camera.visible_area();
            this.inner
                .try_set_center(camera_x, camera_y)
                .map_err(minimap_error)?;
            this.inner
                .try_set_viewport_rect(vx, vy, vw, vh)
                .map_err(minimap_error)
        });
        // -- revealRadius --
        /// Reveals fog inside a world-space radius.
        /// @param | cx | number | Center x coordinate.
        /// @param | cy | number | Center y coordinate.
        /// @param | radius | number | Reveal radius.
        methods.add_method_mut(
            "revealRadius",
            |_, this, (cx, cy, radius): (f32, f32, f32)| {
                this.inner
                    .try_reveal_radius(cx, cy, radius)
                    .map_err(minimap_error)
            },
        );
        // -- getCenter --
        /// Returns the current minimap world-space center position.
        /// @return | number | Center x coordinate.
        /// @return | number | Center y coordinate.
        methods.add_method("getCenter", |_, this, ()| {
            Ok((this.inner.center_x(), this.inner.center_y()))
        });
        // -- getCenterX --
        /// Returns minimap world center x coordinate.
        /// @return | number | Center x coordinate.
        methods.add_method("getCenterX", |_, this, ()| Ok(this.inner.center_x()));
        // -- getCenterY --
        /// Returns minimap world center y coordinate.
        /// @return | number | Center y coordinate.
        methods.add_method("getCenterY", |_, this, ()| Ok(this.inner.center_y()));
        // -- setViewportRect --
        /// Sets the visible viewport rectangle shown on the minimap.
        /// @param | x | number | Viewport x coordinate.
        /// @param | y | number | Viewport y coordinate.
        /// @param | w | number | Viewport width.
        /// @param | h | number | Viewport height.
        methods.add_method_mut(
            "setViewportRect",
            |_, this, (x, y, w, h): (f32, f32, f32, f32)| {
                this.inner
                    .try_set_viewport_rect(x, y, w, h)
                    .map_err(minimap_error)
            },
        );
        // -- clearViewportRect --
        /// Clears the minimap viewport rectangle overlay.
        methods.add_method_mut("clearViewportRect", |_, this, ()| {
            this.inner.clear_viewport_rect();
            Ok(())
        });
        // -- getViewportRect --
        /// Returns the viewport rectangle when one is set.
        /// @return | number | X coordinate, or nil when unset.
        /// @return | number | Y coordinate, or nil when unset.
        /// @return | number | Width, or nil when unset.
        /// @return | number | Height, or nil when unset.
        methods.add_method("getViewportRect", |_, this, ()| {
            match this.inner.viewport_rect() {
                Some((x, y, w, h)) => Ok((Some(x), Some(y), Some(w), Some(h))),
                None => Ok((None, None, None, None)),
            }
        });
        // -- setViewportVisible --
        /// Sets whether the viewport rectangle is visible.
        /// @param | visible | boolean | Visibility flag.
        methods.add_method_mut("setViewportVisible", |_, this, visible: bool| {
            this.inner.set_viewport_visible(visible);
            Ok(())
        });
        // -- isViewportVisible --
        /// Returns whether the viewport rectangle is visible.
        /// @return | boolean | True when visible.
        methods.add_method("isViewportVisible", |_, this, ()| {
            Ok(this.inner.viewport_visible())
        });
        // -- setViewportColor --
        /// Sets the viewport rectangle color.
        /// @param | r | number | Red channel.
        /// @param | g | number | Green channel.
        /// @param | b | number | Blue channel.
        /// @param | a | number? | Alpha channel, defaults to 0.8.
        methods.add_method_mut(
            "setViewportColor",
            |_, this, (r, g, b, a): (f32, f32, f32, Option<f32>)| {
                let color = clamp_unit_color("viewport color", [r, g, b, a.unwrap_or(0.8)])?;
                this.inner.set_viewport_color(color);
                Ok(())
            },
        );
        // -- getViewportColor --
        /// Returns the viewport rectangle color.
        /// @return | number | Red channel.
        /// @return | number | Green channel.
        /// @return | number | Blue channel.
        /// @return | number | Alpha channel.
        methods.add_method("getViewportColor", |_, this, ()| {
            let c = this.inner.viewport_color();
            Ok((c[0], c[1], c[2], c[3]))
        });
        #[allow(clippy::type_complexity)]
        // -- addPing --
        /// Adds a timed ping effect at a minimap world position.
        /// @param | x | number | World x coordinate of the ping.
        /// @param | y | number | World y coordinate of the ping.
        /// @param | duration | number | Duration in seconds before the ping fades out.
        /// @param | r | number? | Red channel, defaults to 1.0.
        /// @param | g | number? | Green channel, defaults to 1.0.
        /// @param | b | number? | Blue channel, defaults to 0.0.
        /// @param | a | number? | Alpha channel, defaults to 1.0.
        methods.add_method_mut(
            "addPing",
            |_,
             this,
             (x, y, duration, r, g, b, a): (
                f32,
                f32,
                f32,
                Option<f32>,
                Option<f32>,
                Option<f32>,
                Option<f32>,
            )| {
                let x = validate_finite_number("ping x", x)?;
                let y = validate_finite_number("ping y", y)?;
                let duration = validate_finite_number("ping duration", duration)?;
                if duration < 0.0 {
                    return Err(LuaError::RuntimeError(
                        "lurek.minimap: ping duration must be non-negative".into(),
                    ));
                }
                let color = clamp_unit_color(
                    "ping color",
                    [
                        r.unwrap_or(1.0),
                        g.unwrap_or(1.0),
                        b.unwrap_or(0.0),
                        a.unwrap_or(1.0),
                    ],
                )?;
                if this.inner.add_ping(x, y, duration, color) {
                    Ok(())
                } else {
                    Err(minimap_error(MinimapError::PingLimitExceeded {
                        limit: this.inner.limits().max_pings,
                    }))
                }
            },
        );
        // -- getPingCount --
        /// Returns the number of active pings.
        /// @return | integer | Ping count.
        methods.add_method("getPingCount", |_, this, ()| Ok(this.inner.ping_count()));
        #[allow(clippy::type_complexity)]
        // -- addMarker --
        /// Adds a world-space marker and returns its unique id.
        /// @param | x | number | Marker x coordinate.
        /// @param | y | number | Marker y coordinate.
        /// @param | desc | string? | Marker description.
        /// @param | r | number? | Red channel override, defaults to 1.0.
        /// @param | g | number? | Green channel override, defaults to 0.0.
        /// @param | b | number? | Blue channel override, defaults to 0.0.
        /// @param | a | number? | Alpha channel override, defaults to 1.0.
        /// @return | integer | Marker id.
        methods.add_method_mut(
            "addMarker",
            |_,
             this,
             (x, y, desc, r, g, b, a): (
                f32,
                f32,
                Option<String>,
                Option<f32>,
                Option<f32>,
                Option<f32>,
                Option<f32>,
            )| {
                let color = clamp_unit_color(
                    "marker color",
                    [
                        r.unwrap_or(1.0),
                        g.unwrap_or(0.0),
                        b.unwrap_or(0.0),
                        a.unwrap_or(1.0),
                    ],
                )?;
                let id = this
                    .inner
                    .try_add_marker(x, y, desc.unwrap_or_default(), color)
                    .map_err(minimap_error)?;
                Ok(id)
            },
        );
        // -- removeMarker --
        /// Removes a minimap marker by its unique id.
        /// @param | id | integer | Marker id.
        /// @return | boolean | True when a marker was removed.
        methods.add_method_mut("removeMarker", |_, this, id: u32| {
            Ok(this.inner.remove_marker(id))
        });
        // -- hasMarker --
        /// Returns whether a marker id exists.
        /// @param | id | integer | Marker id.
        /// @return | boolean | True when the marker exists.
        methods.add_method("hasMarker", |_, this, id: u32| {
            Ok(this.inner.has_marker(id))
        });
        // -- getMarkerDescription --
        /// Returns a marker description by id.
        /// @param | id | integer | Marker id.
        /// @return | string | Marker description, or nil when missing.
        methods.add_method("getMarkerDescription", |_, this, id: u32| {
            Ok(this.inner.get_marker_description(id).map(|s| s.to_string()))
        });
        // -- getMarkerCount --
        /// Returns the total number of minimap markers.
        /// @return | integer | Marker count.
        methods.add_method("getMarkerCount", |_, this, ()| {
            Ok(this.inner.marker_count())
        });
        // -- setMarkerTexture --
        /// Assigns an image texture to a marker.
        /// @param | id | integer | Marker id.
        /// @param | image_ud | LImage | Image handle from `lurek.render.newImage`.
        /// @param | width | number? | Display width override.
        /// @param | height | number? | Display height override.
        methods.add_method_mut(
            "setMarkerTexture",
            |_, this, (id, image_ud, width, height): (u32, LuaAnyUserData, Option<f32>, Option<f32>)| {
                let (texture_key, tex_w, tex_h, display_w, display_h) =
                    parse_lua_image_icon(image_ud, width, height, "setMarkerTexture")?;
                if this
                    .inner
                    .set_marker_texture(id, texture_key, tex_w, tex_h, display_w, display_h)
                {
                    Ok(())
                } else {
                    Err(minimap_error(MinimapError::MissingMarker { id }))
                }
            },
        );
        // -- clearMarkerTexture --
        /// Clears image texture from a marker.
        /// @param | id | integer | Marker id.
        methods.add_method_mut("clearMarkerTexture", |_, this, id: u32| {
            this.inner.clear_marker_texture(id);
            Ok(())
        });
        // -- setMarkerAnimation --
        /// Sets marker animation by type name.
        /// @param | id | integer | Marker id.
        /// @param | anim_type | string | Animation type: `blink`, `pulse`, or `rotate`.
        /// @param | speed | number | Animation speed.
        methods.add_method_mut(
            "setMarkerAnimation",
            |_, this, (id, anim_type, speed): (u32, String, f32)| {
                let speed = validate_finite_number("marker animation speed", speed)?;
                let anim = match anim_type.as_str() {
                    "blink" => MarkerAnimation::Blink { speed, phase: 0.0 },
                    "pulse" => MarkerAnimation::Pulse { speed, phase: 0.0 },
                    "rotate" => MarkerAnimation::Rotate { speed, angle: 0.0 },
                    other => {
                        return Err(LuaError::RuntimeError(format!(
                            "lurek.minimap: unknown animation type '{}', \
                             expected 'blink', 'pulse', or 'rotate'",
                            other
                        )))
                    }
                };
                this.inner.set_marker_animation(id, anim);
                Ok(())
            },
        );
        // -- clearMarkerAnimation --
        /// Clears the animation assigned to a marker by id.
        /// @param | id | integer | Marker id.
        methods.add_method_mut("clearMarkerAnimation", |_, this, id: u32| {
            this.inner.clear_marker_animation(id);
            Ok(())
        });
        // -- drawLine --
        /// Adds an overlay line between two world-space points.
        /// @param | x1 | number | Start x coordinate.
        /// @param | y1 | number | Start y coordinate.
        /// @param | x2 | number | End x coordinate.
        /// @param | y2 | number | End y coordinate.
        /// @param | color_tbl | table | RGBA byte color table.
        methods.add_method_mut(
            "drawLine",
            |_, this, (x1, y1, x2, y2, color_tbl): (f32, f32, f32, f32, LuaTable)| {
                let color = parse_color_table(color_tbl)?;
                if this.inner.draw_line(x1, y1, x2, y2, color) {
                    Ok(())
                } else {
                    Err(minimap_error(MinimapError::OverlayLimitExceeded {
                        limit: this.inner.limits().max_overlay_shapes,
                    }))
                }
            },
        );
        // -- drawRect --
        /// Adds an overlay rectangle at a world-space position.
        /// @param | x | number | Rectangle x coordinate.
        /// @param | y | number | Rectangle y coordinate.
        /// @param | w | number | Rectangle width.
        /// @param | h | number | Rectangle height.
        /// @param | color_tbl | table | RGBA byte color table.
        methods.add_method_mut(
            "drawRect",
            |_, this, (x, y, w, h, color_tbl): (f32, f32, f32, f32, LuaTable)| {
                let color = parse_color_table(color_tbl)?;
                if this.inner.draw_rect(x, y, w, h, color) {
                    Ok(())
                } else {
                    Err(minimap_error(MinimapError::OverlayLimitExceeded {
                        limit: this.inner.limits().max_overlay_shapes,
                    }))
                }
            },
        );
        // -- clearOverlay --
        /// Clears all minimap overlay shapes.
        methods.add_method_mut("clearOverlay", |_, this, ()| {
            this.inner.clear_overlay();
            Ok(())
        });
        // -- getOverlayShapeCount --
        /// Returns the number of overlay shapes.
        /// @return | integer | Overlay shape count.
        methods.add_method("getOverlayShapeCount", |_, this, ()| {
            Ok(this.inner.overlay_shapes().len())
        });
        // -- showPath --
        /// Adds a colored path overlay and returns its id.
        /// @param | points_tbl | table | Array table of point arrays `{x, y}`.
        /// @param | color_tbl | table | RGBA byte color table.
        /// @return | integer | Path id.
        methods.add_method_mut(
            "showPath",
            |_, this, (points_tbl, color_tbl): (LuaTable, LuaTable)| {
                let color = parse_color_table(color_tbl)?;
                let len = points_tbl.len()? as usize;
                let mut points = Vec::with_capacity(len);
                for i in 1..=len {
                    let pt: LuaTable = points_tbl.get(i)?;
                    let x: f32 = pt.get(1)?;
                    let y: f32 = pt.get(2)?;
                    validate_finite_number("path x", x)?;
                    validate_finite_number("path y", y)?;
                    points.push((x, y));
                }
                let id = this
                    .inner
                    .try_show_path(points, color)
                    .map_err(minimap_error)?;
                Ok(id)
            },
        );
        // -- clearPath --
        /// Clears one path by id or all paths when no id is provided.
        /// @param | id | integer? | Path id to clear.
        methods.add_method_mut("clearPath", |_, this, id: Option<u32>| {
            this.inner.clear_path(id);
            Ok(())
        });
        // -- getPathCount --
        /// Returns the number of active path overlays.
        /// @return | integer | Path count.
        methods.add_method("getPathCount", |_, this, ()| Ok(this.inner.paths().len()));
        // -- setLayer --
        /// Sets the active minimap display layer index.
        /// @param | layer | integer | Layer index.
        methods.add_method_mut("setLayer", |_, this, layer: usize| {
            if this.inner.set_layer(layer) {
                Ok(())
            } else if this.inner.layer_data(layer).is_none() {
                Err(minimap_error(MinimapError::InvalidLayer { layer }))
            } else {
                Err(minimap_error(MinimapError::EmptyLayer { layer }))
            }
        });
        // -- getLayer --
        /// Returns the active minimap display layer index.
        /// @return | integer | Layer index.
        methods.add_method("getLayer", |_, this, ()| Ok(this.inner.get_layer()));
        // -- getLayerCount --
        /// Returns the number of minimap layers.
        /// @return | integer | Layer count.
        methods.add_method("getLayerCount", |_, this, ()| Ok(this.inner.layer_count()));
        // -- setLayerData --
        /// Sets raw cell data for a minimap layer.
        /// @param | layer | integer | Layer index.
        /// @param | data_tbl | table | Array table of cell bytes.
        methods.add_method_mut(
            "setLayerData",
            |_, this, (layer, data_tbl): (usize, LuaTable)| {
                let len = data_tbl.len()? as usize;
                let mut cells = Vec::with_capacity(len);
                for i in 1..=len {
                    let v: u8 = data_tbl.get(i)?;
                    cells.push(v);
                }
                let w = this.inner.grid_width();
                let h = this.inner.grid_height();
                this.inner
                    .try_set_layer_data(
                        layer,
                        LayerData {
                            cells,
                            width: w,
                            height: h,
                        },
                    )
                    .map_err(minimap_error)
            },
        );
        // -- getLayerData --
        /// Returns raw cell data for a minimap layer.
        /// @param | layer | integer | Layer index.
        /// @return | integer[] | Array table of cell bytes, or nil when missing.
        methods.add_method("getLayerData", |lua, this, layer: usize| {
            let Some(layer_data) = this.inner.layer_data(layer) else {
                return Ok(None::<LuaTable>);
            };
            let tbl = lua.create_table()?;
            for (index, cell) in layer_data.cells.iter().enumerate() {
                tbl.set(index + 1, *cell)?;
            }
            Ok(Some(tbl))
        });
        // -- setLayerVisible --
        /// Sets whether a minimap data layer is drawn even when it is not the active layer.
        /// @param | layer | integer | Layer index.
        /// @param | visible | boolean | Visibility flag.
        methods.add_method_mut(
            "setLayerVisible",
            |_, this, (layer, visible): (usize, bool)| {
                this.inner
                    .set_layer_visible(layer, visible)
                    .map_err(minimap_error)
            },
        );
        // -- isLayerVisible --
        /// Returns whether a minimap data layer is drawn when it is not active.
        /// @param | layer | integer | Layer index.
        /// @return | boolean | True when the layer is visible, or nil when missing.
        methods.add_method("isLayerVisible", |_, this, layer: usize| {
            Ok(this.inner.layer_visible(layer))
        });
        // -- setLayerAlpha --
        /// Sets the opacity multiplier for a minimap data layer.
        /// @param | layer | integer | Layer index.
        /// @param | alpha | number | Opacity clamped to 0..1.
        methods.add_method_mut("setLayerAlpha", |_, this, (layer, alpha): (usize, f32)| {
            this.inner
                .set_layer_alpha(layer, alpha)
                .map_err(minimap_error)
        });
        // -- getLayerAlpha --
        /// Returns the opacity multiplier for a minimap data layer.
        /// @param | layer | integer | Layer index.
        /// @return | number | Opacity multiplier, or nil when missing.
        methods.add_method("getLayerAlpha", |_, this, layer: usize| {
            Ok(this.inner.layer_alpha(layer))
        });
        // -- setLayerColor --
        /// Sets a palette color for one raw value in a minimap data layer.
        /// @param | layer | integer | Layer index.
        /// @param | value | integer | Raw byte value in the layer data.
        /// @param | r | number | Red channel.
        /// @param | g | number | Green channel.
        /// @param | b | number | Blue channel.
        /// @param | a | number? | Alpha channel, defaults to 1.0.
        methods.add_method_mut(
            "setLayerColor",
            |_, this, (layer, value, r, g, b, a): (usize, u8, f32, f32, f32, Option<f32>)| {
                let color = clamp_unit_color("layer color", [r, g, b, a.unwrap_or(1.0)])?;
                this.inner
                    .set_layer_color(layer, value, color)
                    .map_err(minimap_error)
            },
        );
        // -- getLayerColor --
        /// Returns the palette color for one raw value in a minimap data layer.
        /// @param | layer | integer | Layer index.
        /// @param | value | integer | Raw byte value in the layer data.
        /// @return | number | Red channel, or nil when missing.
        /// @return | number | Green channel, or nil when missing.
        /// @return | number | Blue channel, or nil when missing.
        /// @return | number | Alpha channel, or nil when missing.
        methods.add_method(
            "getLayerColor",
            |_, this, (layer, value): (usize, u8)| match this.inner.get_layer_color(layer, value) {
                Some(c) => Ok((Some(c[0]), Some(c[1]), Some(c[2]), Some(c[3]))),
                None => Ok((None, None, None, None)),
            },
        );
        // -- setLayerBlendMode --
        /// Sets how a minimap data layer is blended over the base terrain.
        /// @param | layer | integer | Layer index.
        /// @param | mode | string | Blend mode: `normal`, `multiply`, `add`, or `replace`.
        methods.add_method_mut(
            "setLayerBlendMode",
            |_, this, (layer, mode): (usize, String)| {
                let Some(mode) = LayerBlendMode::parse_mode(mode.as_str()) else {
                    return Err(LuaError::RuntimeError(format!(
                        "lurek.minimap: unknown layer blend mode '{}', expected 'normal', 'multiply', 'add', or 'replace'",
                        mode
                    )));
                };
                this.inner
                    .set_layer_blend_mode(layer, mode)
                    .map_err(minimap_error)
            },
        );
        // -- getLayerBlendMode --
        /// Returns how a minimap data layer is blended over the base terrain.
        /// @param | layer | integer | Layer index.
        /// @return | string | Blend mode, or nil when missing.
        methods.add_method("getLayerBlendMode", |_, this, layer: usize| {
            Ok(this
                .inner
                .layer_blend_mode(layer)
                .map(|mode| mode.as_str().to_string()))
        });
        // -- setAntiAlias --
        /// Enables or disables minimap anti-aliasing.
        /// @param | enabled | boolean | Anti-alias flag.
        methods.add_method_mut("setAntiAlias", |_, this, enabled: bool| {
            this.inner.set_anti_alias(enabled);
            Ok(())
        });
        // -- isAntiAlias --
        /// Returns whether anti-aliasing is enabled.
        /// @return | boolean | True when enabled.
        methods.add_method("isAntiAlias", |_, this, ()| Ok(this.inner.anti_alias()));
        // -- setClickable --
        /// Enables or disables minimap click handling.
        /// @param | enabled | boolean | Clickable flag.
        methods.add_method_mut("setClickable", |_, this, enabled: bool| {
            this.inner.set_clickable(enabled);
            Ok(())
        });
        // -- isClickable --
        /// Returns whether minimap click handling is enabled.
        /// @return | boolean | True when clickable.
        methods.add_method("isClickable", |_, this, ()| Ok(this.inner.is_clickable()));
        // -- getHoverInfo --
        /// Returns hover text for a screen position when available.
        /// @param | sx | number | Screen x coordinate.
        /// @param | sy | number | Screen y coordinate.
        /// @param | mx | number | Minimap x position.
        /// @param | my | number | Minimap y position.
        /// @return | string | Hover info text, or nil when unavailable.
        methods.add_method(
            "getHoverInfo",
            |_, this, (sx, sy, mx, my): (f32, f32, f32, f32)| {
                Ok(this
                    .inner
                    .get_hover_info(sx, sy, mx, my)
                    .map(|s| s.to_string()))
            },
        );
        // -- screenToGrid --
        /// Converts a screen position to grid coordinates.
        /// @param | sx | number | Screen x coordinate.
        /// @param | sy | number | Screen y coordinate.
        /// @param | mx | number | Minimap x position.
        /// @param | my | number | Minimap y position.
        /// @return | number | Grid x coordinate, or nil when the transform state is invalid.
        /// @return | number | Grid y coordinate, or nil when the transform state is invalid.
        methods.add_method(
            "screenToGrid",
            |_, this, (sx, sy, mx, my): (f32, f32, f32, f32)| match this
                .inner
                .try_screen_to_grid(sx, sy, mx, my)
            {
                Ok((gx, gy)) => Ok((Some(gx), Some(gy))),
                Err(MinimapError::TransformUnavailable { .. }) => Ok((None, None)),
                Err(err) => Err(minimap_error(err)),
            },
        );
        // -- gridToScreen --
        /// Converts grid coordinates to screen coordinates.
        /// @param | gx | number | Grid x coordinate.
        /// @param | gy | number | Grid y coordinate.
        /// @param | mx | number | Minimap x position.
        /// @param | my | number | Minimap y position.
        /// @return | number | Screen x coordinate, or nil when the transform state is invalid.
        /// @return | number | Screen y coordinate, or nil when the transform state is invalid.
        methods.add_method(
            "gridToScreen",
            |_, this, (gx, gy, mx, my): (f32, f32, f32, f32)| match this
                .inner
                .try_grid_to_screen(gx, gy, mx, my)
            {
                Ok((sx, sy)) => Ok((Some(sx), Some(sy))),
                Err(MinimapError::TransformUnavailable { .. }) => Ok((None, None)),
                Err(err) => Err(minimap_error(err)),
            },
        );
        // -- update --
        /// Advances minimap animations and timers.
        /// @param | dt | number | Delta time in seconds.
        methods.add_method_mut("update", |_, this, dt: f32| {
            validate_finite_number("update dt", dt)?;
            this.inner.update(dt);
            Ok(())
        });
        // -- type --
        /// Returns the Lua-visible type name for this minimap handle.
        /// @return | string | The string `LMinimap`.
        methods.add_method("type", |_, _, ()| Ok("LMinimap"));
        // -- typeOf --
        /// Returns whether this minimap handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LMinimap`, `Minimap`, and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LMinimap" || name == "LObject")
        });
        // -- render --
        /// Enqueues minimap render commands at an optional screen position.
        /// @param | x | number? | Screen x coordinate, defaults to 0.
        /// @param | y | number? | Screen y coordinate, defaults to 0.
        methods.add_method("render", |_, this, (x, y): (Option<f32>, Option<f32>)| {
            let sx = x.unwrap_or(0.0);
            let sy = y.unwrap_or(0.0);
            let cmds = this.inner.build_render_commands(sx, sy);
            extend_minimap_render_commands(&mut this.state.borrow_mut(), cmds);
            Ok(())
        });
        // -- drawToImage --
        /// Draws the minimap into image data at a pixel size.
        /// @param | pixel_size | integer | Pixel size scale.
        /// @return | LImageData | Image data containing the rendered minimap.
        methods.add_method("drawToImage", |_, this, pixel_size: u32| {
            let img = this
                .inner
                .try_draw_to_image(pixel_size)
                .map_err(minimap_error)?;
            Ok(img)
        });
    }
}
/// Registers the `lurek.minimap` module.
pub fn register(lua: &Lua, lurek: &LuaTable, state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let tbl = lua.create_table()?;
    let s = state.clone();
    // -- newMinimap --
    /// Creates a minimap with grid dimensions and optional display size.
    /// @param | grid_w | integer | Grid width in cells.
    /// @param | grid_h | integer | Grid height in cells.
    /// @param | display_w | integer? | Display width in pixels, defaults to 200.
    /// @param | display_h | integer? | Display height in pixels, defaults to 200.
    /// @return | LMinimap | New minimap handle.
    tbl.set("newMinimap", lua.create_function(
            move |_, (grid_w, grid_h, display_w, display_h): (u32, u32, Option<u32>, Option<u32>)| {
                let dw = display_w.unwrap_or(200);
                let dh = display_h.unwrap_or(200);
                Ok(LuaMinimap {
                    inner: Minimap::try_new(grid_w, grid_h, dw, dh, MinimapLimits::default())
                        .map_err(minimap_error)?,
                    state: s.clone(),
                })
            },
        )?,
    )?;
    /// Performs the 'minimap' operation.
    lurek.set("minimap", tbl)?;
    Ok(())
}
