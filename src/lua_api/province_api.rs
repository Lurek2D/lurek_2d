//! Registers the `lurek.province` Lua API for province maps, markers, tints, borders, and province registries.

use super::render_api::{ensure_shader_target, LuaImage, LuaShader};
use super::SharedState;
use crate::image::ProvinceGrid;
use crate::image::TextureColorSpace;
use crate::province::events::ProvinceChange;
use crate::province::map_modes::MapModeConfig;
use crate::province::registry::ProvinceRegistry;
use crate::province::render::{
    generate_capital_path_commands, generate_render_commands, render_segment_raster,
    resolve_zoom_mode, viewport_bounds, ProvinceCapitalPathMode, ProvinceCapitalPathOptions,
    ProvinceRenderOptions, ProvinceSegmentRasterOptions, ProvinceZoomMode,
};
use crate::province::routing;
use crate::province::types::{BorderPairFlags, BorderPairStyle, BorderTypeConfig, ProvinceId};
use crate::province::{fit_camera_to_screen, map_to_cell, screen_to_map, zoom_camera_at};
use crate::province::{
    import_metadata_from_files, sanitize_marked_png, MarkerSanitizeOptions,
    ProvinceMetadataImportOptions,
};
use crate::render::renderer::{RenderCommand, TextureData};
use crate::render::ShaderTarget;
use crate::runtime::shared_state::ProvinceSegmentTextureCache;
use mlua::prelude::*;
use std::cell::RefCell;
use std::collections::{hash_map::DefaultHasher, HashMap};
use std::hash::{Hash, Hasher};
use std::path::Path;
use std::rc::Rc;
/// Resolves a province asset path against the active game directory when the path is relative.
fn resolve_game_path(state: &Rc<RefCell<SharedState>>, path: &str) -> String {
    let st = state.borrow();
    let p = Path::new(path);
    if p.is_absolute() {
        p.to_string_lossy().into_owned()
    } else {
        st.game_dir.join(p).to_string_lossy().into_owned()
    }
}

fn extend_province_render_commands(st: &mut SharedState, commands: Vec<RenderCommand>) {
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

fn wrap_province_commands_with_shader(
    shader: Option<crate::runtime::resource_keys::ShaderKey>,
    commands: Vec<RenderCommand>,
) -> Vec<RenderCommand> {
    let Some(shader) = shader else {
        return commands;
    };
    let mut wrapped = Vec::with_capacity(commands.len() + 2);
    wrapped.push(RenderCommand::SetShader(Some(shader)));
    wrapped.extend(commands);
    wrapped.push(RenderCommand::SetShader(None));
    wrapped
}
/// Parses optional marker sanitization settings from a Lua options table.
fn marker_options_from_lua(opts: Option<&LuaTable>) -> MarkerSanitizeOptions {
    let mut out = MarkerSanitizeOptions::default();
    if let Some(t) = opts {
        if let Some(v) = t.get::<_, Option<u8>>("capital_min").ok().flatten() {
            out.capital_min = v;
        }
        if let Some(v) = t.get::<_, Option<u8>>("label_r_min").ok().flatten() {
            out.label_r_min = v;
        }
        if let Some(v) = t.get::<_, Option<u8>>("label_g_max").ok().flatten() {
            out.label_g_max = v;
        }
        if let Some(v) = t.get::<_, Option<u8>>("label_b_min").ok().flatten() {
            out.label_b_min = v;
        }
        if let Some(v) = t.get::<_, Option<u32>>("search_radius").ok().flatten() {
            out.search_radius = v;
        }
    }
    out
}

fn parse_border_pair_flags_from_lua(value: LuaValue) -> LuaResult<BorderPairFlags> {
    match value {
        LuaValue::Nil => Ok(BorderPairFlags::empty()),
        LuaValue::String(s) => {
            let token = s.to_str()?.to_lowercase();
            let bit = BorderPairFlags::parse_token(token.as_str()).ok_or_else(|| {
                LuaError::RuntimeError(format!("invalid border flag '{}'", token))
            })?;
            Ok(BorderPairFlags::from_bits(bit))
        }
        LuaValue::Table(t) => {
            let mut flags = BorderPairFlags::empty();
            for value in t.sequence_values::<String>() {
                let token = value?.to_lowercase();
                let bit = BorderPairFlags::parse_token(token.as_str()).ok_or_else(|| {
                    LuaError::RuntimeError(format!("invalid border flag '{}'", token))
                })?;
                flags.insert_bits(bit);
            }
            Ok(flags)
        }
        _ => Err(LuaError::RuntimeError(
            "flags must be a string or array of strings".to_string(),
        )),
    }
}

fn parse_border_pair_style_from_lua(style: &LuaTable) -> LuaResult<BorderPairStyle> {
    let thickness = style
        .get::<_, Option<f32>>("thickness")?
        .unwrap_or(1.0)
        .max(1.0);
    let color = if let Some(color_tbl) = style.get::<_, Option<LuaTable>>("color")? {
        Some([
            color_tbl.get::<_, Option<f32>>(1)?.unwrap_or(1.0),
            color_tbl.get::<_, Option<f32>>(2)?.unwrap_or(1.0),
            color_tbl.get::<_, Option<f32>>(3)?.unwrap_or(1.0),
            color_tbl.get::<_, Option<f32>>(4)?.unwrap_or(1.0),
        ])
    } else {
        None
    };
    let flags_value = style
        .get::<_, Option<LuaValue>>("flags")?
        .unwrap_or(LuaValue::Nil);
    let flags = parse_border_pair_flags_from_lua(flags_value)?;
    Ok(BorderPairStyle {
        color,
        thickness,
        flags,
    })
}

fn parse_zoom_mode_from_lua(value: Option<String>) -> Option<ProvinceZoomMode> {
    match value.as_deref() {
        Some("auto") => Some(ProvinceZoomMode::Auto),
        Some("strategic") => Some(ProvinceZoomMode::Strategic),
        Some("tactical") => Some(ProvinceZoomMode::Tactical),
        _ => None,
    }
}

fn clamp_unit(v: f32) -> LuaResult<f32> {
    if !v.is_finite() {
        return Err(LuaError::RuntimeError(
            "LProvinceRegistry:render color components must be finite numbers".to_string(),
        ));
    }
    Ok(v.clamp(0.0, 1.0))
}

fn parse_render_color_table(t: LuaTable, field: &str) -> LuaResult<[f32; 4]> {
    let r = t.get::<_, Option<f32>>(1)?.ok_or_else(|| {
        LuaError::RuntimeError(format!(
            "LProvinceRegistry:render {} must contain r,g,b components",
            field
        ))
    })?;
    let g = t.get::<_, Option<f32>>(2)?.ok_or_else(|| {
        LuaError::RuntimeError(format!(
            "LProvinceRegistry:render {} must contain r,g,b components",
            field
        ))
    })?;
    let b = t.get::<_, Option<f32>>(3)?.ok_or_else(|| {
        LuaError::RuntimeError(format!(
            "LProvinceRegistry:render {} must contain r,g,b components",
            field
        ))
    })?;
    let a = t.get::<_, Option<f32>>(4)?.unwrap_or(1.0);
    Ok([
        clamp_unit(r)?,
        clamp_unit(g)?,
        clamp_unit(b)?,
        clamp_unit(a)?,
    ])
}

#[derive(Debug, Clone, Copy)]
struct ProvinceRenderBorderPalette {
    enabled: bool,
    province_border_color: [f32; 4],
    coast_border_color: [f32; 4],
    country_border_color: [f32; 4],
    sea_border_darken: f32,
}

impl Default for ProvinceRenderBorderPalette {
    fn default() -> Self {
        Self {
            enabled: true,
            province_border_color: [72.0 / 255.0, 58.0 / 255.0, 32.0 / 255.0, 1.0],
            coast_border_color: [224.0 / 255.0, 196.0 / 255.0, 128.0 / 255.0, 238.0 / 255.0],
            country_border_color: [230.0 / 255.0, 48.0 / 255.0, 44.0 / 255.0, 245.0 / 255.0],
            sea_border_darken: 0.15,
        }
    }
}

struct ProvinceLuaParser;

impl ProvinceLuaParser {
    fn parse_border_palette_from_lua(
        opts: Option<&LuaTable>,
    ) -> LuaResult<ProvinceRenderBorderPalette> {
        let mut palette = ProvinceRenderBorderPalette::default();
        let Some(opts) = opts else {
            return Ok(palette);
        };
        if let Some(t) = opts.get::<_, Option<LuaTable>>("border_palette")? {
            palette.enabled = t.get::<_, Option<bool>>("enabled")?.unwrap_or(true);
            if let Some(color) = t.get::<_, Option<LuaTable>>("province_color")? {
                palette.province_border_color =
                    parse_render_color_table(color, "border_palette.province_color")?;
            }
            if let Some(color) = t.get::<_, Option<LuaTable>>("land_color")? {
                palette.province_border_color =
                    parse_render_color_table(color, "border_palette.land_color")?;
            }
            if let Some(color) = t.get::<_, Option<LuaTable>>("coast_color")? {
                palette.coast_border_color =
                    parse_render_color_table(color, "border_palette.coast_color")?;
            }
            if let Some(color) = t.get::<_, Option<LuaTable>>("country_color")? {
                palette.country_border_color =
                    parse_render_color_table(color, "border_palette.country_color")?;
            }
            if let Some(darken) = t.get::<_, Option<f32>>("sea_darken")? {
                palette.sea_border_darken = darken.clamp(0.0, 1.0);
            }
        }
        if let Some(color) = opts.get::<_, Option<LuaTable>>("province_border_color")? {
            palette.enabled = true;
            palette.province_border_color =
                parse_render_color_table(color, "province_border_color")?;
        }
        if let Some(color) = opts.get::<_, Option<LuaTable>>("coast_border_color")? {
            palette.enabled = true;
            palette.coast_border_color = parse_render_color_table(color, "coast_border_color")?;
        }
        if let Some(color) = opts.get::<_, Option<LuaTable>>("country_border_color")? {
            palette.enabled = true;
            palette.country_border_color = parse_render_color_table(color, "country_border_color")?;
        }
        if let Some(darken) = opts.get::<_, Option<f32>>("sea_border_darken")? {
            palette.enabled = true;
            palette.sea_border_darken = darken.clamp(0.0, 1.0);
        }
        Ok(palette)
    }
}

fn parse_border_palette_from_lua(
    opts: Option<&LuaTable>,
) -> LuaResult<ProvinceRenderBorderPalette> {
    ProvinceLuaParser::parse_border_palette_from_lua(opts)
}

fn parse_province_tint_key(key: LuaValue) -> LuaResult<ProvinceId> {
    match key {
        LuaValue::Integer(id) if id > 0 && id <= u32::MAX as i64 => Ok(ProvinceId(id as u32)),
        LuaValue::Number(id) if id.is_finite() && id.fract() == 0.0 && id > 0.0 => {
            if id > u32::MAX as f64 {
                Err(LuaError::RuntimeError(
                    "LProvinceRegistry:render province_tints keys must fit u32".to_string(),
                ))
            } else {
                Ok(ProvinceId(id as u32))
            }
        }
        _ => Err(LuaError::RuntimeError(
            "LProvinceRegistry:render province_tints keys must be positive province ids"
                .to_string(),
        )),
    }
}

fn parse_province_tints_from_lua(
    value: Option<LuaTable>,
) -> LuaResult<HashMap<ProvinceId, [f32; 4]>> {
    let mut out = HashMap::new();
    let Some(tints) = value else {
        return Ok(out);
    };
    for pair in tints.pairs::<LuaValue, LuaValue>() {
        let (key, value) = pair?;
        let id = parse_province_tint_key(key)?;
        let LuaValue::Table(color_table) = value else {
            return Err(LuaError::RuntimeError(
                "LProvinceRegistry:render province_tints values must be {r,g,b,a?} tables"
                    .to_string(),
            ));
        };
        out.insert(
            id,
            parse_render_color_table(color_table, "province_tints[id]")?,
        );
    }
    Ok(out)
}
/// Handle to a named province registry, exposing spatial queries, style mutations, rendering, and change tracking to Lua scripts.
#[derive(Clone)]
pub struct LuaProvinceRegistry {
    name: String,
    state: Rc<RefCell<SharedState>>,
}
impl LuaProvinceRegistry {
    /// Runs a closure with the current province registry or returns a Lua runtime error when missing.
    pub(crate) fn with_registry<R>(&self, f: impl FnOnce(&ProvinceRegistry) -> R) -> LuaResult<R> {
        let st = self.state.borrow();
        let reg = st.province_registries.get(&self.name).ok_or_else(|| {
            LuaError::RuntimeError(format!("province registry '{}' not found", self.name))
        })?;
        Ok(f(reg))
    }
    fn with_registry_mut<R>(&self, f: impl FnOnce(&mut ProvinceRegistry) -> R) -> LuaResult<R> {
        let mut st = self.state.borrow_mut();
        let reg = st.province_registries.get_mut(&self.name).ok_or_else(|| {
            LuaError::RuntimeError(format!("province registry '{}' not found", self.name))
        })?;
        Ok(f(reg))
    }

    fn segment_render_fingerprint(opts: &ProvinceSegmentRasterOptions) -> u64 {
        let mut hasher = DefaultHasher::new();
        opts.pixel_size.hash(&mut hasher);
        opts.map_x.hash(&mut hasher);
        opts.map_y.hash(&mut hasher);
        opts.map_w.hash(&mut hasher);
        opts.map_h.hash(&mut hasher);
        opts.draw_fills.hash(&mut hasher);
        opts.draw_borders.hash(&mut hasher);
        opts.edge_gradient_radius.to_bits().hash(&mut hasher);
        opts.edge_gradient_strength.to_bits().hash(&mut hasher);
        for value in opts.tint {
            value.to_bits().hash(&mut hasher);
        }
        hasher.finish()
    }

    fn queue_segment_render(
        &self,
        options: &ProvinceRenderOptions,
        edge_gradient_radius: f32,
        edge_gradient_strength: f32,
        reuse_cached_tints: bool,
    ) -> LuaResult<()> {
        let scale = if options.pixel_size.is_finite() {
            options.pixel_size.round().clamp(1.0, 64.0) as u32
        } else {
            1
        };
        let (map_x, map_y, map_w, map_h) = {
            let st = self.state.borrow();
            let reg = st.province_registries.get(&self.name).ok_or_else(|| {
                LuaError::RuntimeError(format!("province registry '{}' not found", self.name))
            })?;
            let (left, top, right, bottom) = viewport_bounds(options);
            let pad = (edge_gradient_radius / scale as f32).ceil() as i32 + 4;
            let max_x = reg.width() as i32;
            let max_y = reg.height() as i32;
            let x0 = (left.floor() as i32 - pad).clamp(0, max_x);
            let y0 = (top.floor() as i32 - pad).clamp(0, max_y);
            let mut x1 = (right.ceil() as i32 + pad + 1).clamp(0, max_x);
            let mut y1 = (bottom.ceil() as i32 + pad + 1).clamp(0, max_y);
            if x1 <= x0 {
                x1 = (x0 + 1).min(max_x);
            }
            if y1 <= y0 {
                y1 = (y0 + 1).min(max_y);
            }
            (
                x0 as u32,
                y0 as u32,
                x1.saturating_sub(x0) as u32,
                y1.saturating_sub(y0) as u32,
            )
        };
        let has_new_tints = !options.province_tints.is_empty();
        let mut segment_opts = ProvinceSegmentRasterOptions {
            pixel_size: scale,
            map_x,
            map_y,
            map_w,
            map_h,
            tint: options.tint.unwrap_or([1.0, 1.0, 1.0, 1.0]),
            province_tints: if has_new_tints {
                options.province_tints.clone()
            } else {
                HashMap::new()
            },
            draw_fills: options.draw_fills,
            draw_borders: options.draw_borders,
            edge_gradient_radius,
            edge_gradient_strength,
        };
        let fingerprint = Self::segment_render_fingerprint(&segment_opts);
        let (registry_revision, should_rebuild, cached_key) = {
            let st = self.state.borrow();
            let reg = st.province_registries.get(&self.name).ok_or_else(|| {
                LuaError::RuntimeError(format!("province registry '{}' not found", self.name))
            })?;
            let revision = reg.revision();
            let cache = st.province_segment_texture_cache.get(&self.name);
            let cached_key = cache.map(|entry| entry.texture_key);
            let valid = cache
                .map(|entry| {
                    entry.registry_revision == revision
                        && entry.options_fingerprint == fingerprint
                        && st.textures.contains_key(entry.texture_key)
                })
                .unwrap_or(false);
            (revision, has_new_tints || !valid, cached_key)
        };

        if should_rebuild && !has_new_tints && reuse_cached_tints {
            let st = self.state.borrow();
            if let Some(cache) = st.province_segment_texture_cache.get(&self.name) {
                segment_opts.province_tints = cache.province_tints.clone();
            }
        }

        let texture_key = if should_rebuild {
            let registry = {
                let st = self.state.borrow();
                st.province_registries
                    .get(&self.name)
                    .ok_or_else(|| {
                        LuaError::RuntimeError(format!(
                            "province registry '{}' not found",
                            self.name
                        ))
                    })?
                    .clone()
            };
            let raster = render_segment_raster(&registry, &segment_opts);
            let mut st = self.state.borrow_mut();
            match cached_key.filter(|key| st.textures.contains_key(*key)) {
                Some(key) => {
                    let texture = st.textures.get_mut(key).ok_or_else(|| {
                        LuaError::RuntimeError(
                            "LProvinceRegistry:render segment cache texture disappeared"
                                .to_string(),
                        )
                    })?;
                    texture.pixels = raster.pixels;
                    texture.width = raster.width;
                    texture.height = raster.height;
                    texture.color_space = TextureColorSpace::Srgb;
                    texture.mark_dirty();
                    st.province_segment_texture_cache.insert(
                        self.name.clone(),
                        ProvinceSegmentTextureCache {
                            texture_key: key,
                            registry_revision,
                            options_fingerprint: fingerprint,
                            width: raster.width,
                            height: raster.height,
                            map_x,
                            map_y,
                            province_tints: segment_opts.province_tints.clone(),
                        },
                    );
                    key
                }
                None => {
                    let key = st.textures.insert(TextureData::new(
                        raster.pixels,
                        raster.width,
                        raster.height,
                        TextureColorSpace::Srgb,
                    ));
                    st.province_segment_texture_cache.insert(
                        self.name.clone(),
                        ProvinceSegmentTextureCache {
                            texture_key: key,
                            registry_revision,
                            options_fingerprint: fingerprint,
                            width: raster.width,
                            height: raster.height,
                            map_x,
                            map_y,
                            province_tints: segment_opts.province_tints.clone(),
                        },
                    );
                    key
                }
            }
        } else {
            cached_key.ok_or_else(|| {
                LuaError::RuntimeError(
                    "LProvinceRegistry:render segment cache key missing".to_string(),
                )
            })?
        };

        self.state
            .borrow_mut()
            .render_commands
            .push(RenderCommand::DrawImageEx {
                texture_key,
                x: options.x + map_x as f32 * scale as f32 * options.zoom,
                y: options.y + map_y as f32 * scale as f32 * options.zoom,
                rotation: 0.0,
                sx: options.zoom,
                sy: options.zoom,
                ox: 0.0,
                oy: 0.0,
                effect: None,
            });
        Ok(())
    }
}
impl LuaUserData for LuaProvinceRegistry {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- getName --
        /// Returns the string name used to identify this registry in the province system.
        /// @return | string | The registry name passed to `newFromPng`.
        methods.add_method("getName", |_, this, ()| Ok(this.name.clone()));
        // -- getWidth --
        /// Returns the width of the province grid in cells (pixels of the source PNG).
        /// @return | integer | Grid width in cells.
        methods.add_method("getWidth", |_, this, ()| this.with_registry(|r| r.width()));
        // -- getHeight --
        /// Returns the height of the province grid in cells (pixels of the source PNG).
        /// @return | integer | Grid height in cells.
        methods.add_method("getHeight", |_, this, ()| {
            this.with_registry(|r| r.height())
        });
        // -- setShader --
        /// Binds or clears a `mapviz` shader for command-rendered province visualization.
        /// @param | shader | LShader? | Shader created by `lurek.render.newShader(code, { target = "mapviz" })`, or nil to clear.
        methods.add_method_mut("setShader", |_, this, shader: Option<LuaAnyUserData>| {
            let shader_key = if let Some(shader_ud) = shader {
                let key = shader_ud
                    .borrow::<LuaShader>()
                    .map_err(|_| {
                        LuaError::RuntimeError(
                        "LProvinceRegistry:setShader expects LShader from lurek.render.newShader"
                            .to_string(),
                    )
                    })?
                    .key;
                let st = this.state.borrow();
                ensure_shader_target(
                    &st,
                    key,
                    ShaderTarget::MapViz,
                    "LProvinceRegistry:setShader",
                )?;
                Some(key)
            } else {
                None
            };
            this.with_registry_mut(|r| r.set_shader(shader_key))?;
            Ok(())
        });
        // -- getShader --
        /// Returns the currently bound command-render province shader, or nil.
        /// @return | LShader? | Bound shader handle.
        methods.add_method("getShader", |_, this, ()| {
            let key = this.with_registry(|r| r.get_shader())?;
            Ok(key.map(|key| LuaShader {
                key,
                state: this.state.clone(),
            }))
        });
        // -- getAt --
        /// Returns the province ID at the given grid cell coordinates. Returns 0 if the cell is unowned (sea, wasteland, etc.).
        /// @param | x | integer | Zero-based column index.
        /// @param | y | integer | Zero-based row index.
        /// @return | integer | Province ID at (x, y), or 0 for unowned cells.
        methods.add_method("getAt", |_, this, (x, y): (u32, u32)| {
            this.with_registry(|r| r.get_at(x, y))
        });
        // -- fitCamera --
        /// Computes camera position and zoom so the entire province map fits within the given screen dimensions.
        /// @param | screen_w | number | Screen width in pixels.
        /// @param | screen_h | number | Screen height in pixels.
        /// @param | pixel_size | number? | Size of one map cell in screen pixels (default 1.0).
        /// @return | number, number, number | Camera x, camera y, and zoom factor.
        methods.add_method(
            "fitCamera",
            |_, this, (screen_w, screen_h, pixel_size): (f32, f32, Option<f32>)| {
                let (map_w, map_h) = this.with_registry(|r| (r.width(), r.height()))?;
                let (x, y, zoom) = fit_camera_to_screen(
                    map_w,
                    map_h,
                    pixel_size.unwrap_or(1.0),
                    screen_w,
                    screen_h,
                );
                Ok((x, y, zoom))
            },
        );
        // -- screenToMap --
        /// Converts screen-space pixel coordinates to map-space floating-point coordinates using the current camera transform.
        /// @param | screen_x | number | Screen x in pixels.
        /// @param | screen_y | number | Screen y in pixels.
        /// @param | cam_x | number | Camera center x in map space.
        /// @param | cam_y | number | Camera center y in map space.
        /// @param | zoom | number | Current zoom factor.
        /// @param | pixel_size | number? | Cell size in screen pixels (default 1.0).
        /// @return | number, number | Map-space x and y.
        methods.add_method(
            "screenToMap",
            |_,
             _,
             (screen_x, screen_y, cam_x, cam_y, zoom, pixel_size): (
                f32,
                f32,
                f32,
                f32,
                f32,
                Option<f32>,
            )| {
                let (map_x, map_y) = screen_to_map(
                    screen_x,
                    screen_y,
                    cam_x,
                    cam_y,
                    zoom,
                    pixel_size.unwrap_or(1.0),
                );
                Ok((map_x, map_y))
            },
        );
        // -- screenToProvince --
        /// Converts screen-space coordinates directly to a province ID. Returns nil if the cursor is outside the map or over an unowned cell.
        /// @param | screen_x | number | Screen x in pixels.
        /// @param | screen_y | number | Screen y in pixels.
        /// @param | cam_x | number | Camera center x in map space.
        /// @param | cam_y | number | Camera center y in map space.
        /// @param | zoom | number | Current zoom factor.
        /// @param | pixel_size | number? | Cell size in screen pixels (default 1.0).
        /// @return | integer | Province ID under the cursor, or nil if none.
        methods.add_method(
            "screenToProvince",
            |_,
             this,
             (screen_x, screen_y, cam_x, cam_y, zoom, pixel_size): (
                f32,
                f32,
                f32,
                f32,
                f32,
                Option<f32>,
            )| {
                let (map_w, map_h) = this.with_registry(|r| (r.width(), r.height()))?;
                let (map_x, map_y) = screen_to_map(
                    screen_x,
                    screen_y,
                    cam_x,
                    cam_y,
                    zoom,
                    pixel_size.unwrap_or(1.0),
                );
                let Some((cell_x, cell_y)) = map_to_cell(map_x, map_y, map_w, map_h) else {
                    return Ok(None::<u32>);
                };
                let id = this.with_registry(|r| r.get_at(cell_x, cell_y))?;
                if id == 0 {
                    Ok(None::<u32>)
                } else {
                    Ok(Some(id))
                }
            },
        );
        // -- viewportRect --
        /// Computes the province-space viewport rectangle used by province rendering and culling. The returned table can be passed to minimap:setViewportRect(rect.x, rect.y, rect.w, rect.h).
        /// @param | opts | table? | Camera/render options: x/y translation, zoom, pixel_size, screen_w, screen_h.
        /// @return | table | Viewport table with x, y, w, h, left, top, right, and bottom fields in province map pixels.
        methods.add_method("viewportRect", |lua, this, opts: Option<LuaTable>| {
            let mut render_opts = ProvinceRenderOptions::default();
            if let Some(t) = opts {
                if let Some(x) = t.get::<_, Option<f32>>("x")? {
                    render_opts.x = x;
                }
                if let Some(y) = t.get::<_, Option<f32>>("y")? {
                    render_opts.y = y;
                }
                if let Some(zoom) = t.get::<_, Option<f32>>("zoom")? {
                    render_opts.zoom = zoom.max(0.0001);
                }
                if let Some(pixel_size) = t.get::<_, Option<f32>>("pixel_size")? {
                    render_opts.pixel_size = pixel_size.max(0.0001);
                }
                if let Some(screen_w) = t.get::<_, Option<f32>>("screen_w")? {
                    render_opts.screen_w = screen_w.max(0.0001);
                }
                if let Some(screen_h) = t.get::<_, Option<f32>>("screen_h")? {
                    render_opts.screen_h = screen_h.max(0.0001);
                }
            }
            let (left, top, right, bottom) = viewport_bounds(&render_opts);
            let out = lua.create_table()?;
            out.set("x", left)?;
            out.set("y", top)?;
            out.set("w", right - left)?;
            out.set("h", bottom - top)?;
            out.set("left", left)?;
            out.set("top", top)?;
            out.set("right", right)?;
            out.set("bottom", bottom)?;
            out.set("map_w", this.with_registry(|r| r.width())?)?;
            out.set("map_h", this.with_registry(|r| r.height())?)?;
            Ok(out)
        });
        // -- provinceCount --
        /// Returns the total number of distinct provinces in this registry (excluding ID 0).
        /// @return | integer | Count of provinces.
        methods.add_method("provinceCount", |_, this, ()| {
            this.with_registry(|r| r.province_count() as u32)
        });
        // -- provinceIds --
        /// Returns a sequential table of all province IDs in this registry.
        /// @return | integer[] | Province ID numbers.
        methods.add_method("provinceIds", |lua, this, ()| {
            let ids = this.with_registry(|r| r.province_ids())?;
            let out = lua.create_table()?;
            for (i, id) in ids.into_iter().enumerate() {
                out.set(i + 1, id.0)?;
            }
            Ok(out)
        });
        // -- adjacencies --
        /// Returns all adjacency pairs in the registry. Each entry has `province_a` and `province_b` fields representing two neighboring provinces.
        /// @return | table | Array of tables with fields: province_a (number), province_b (number).
        /// @field | province_a | integer | First province id.
        /// @field | province_b | integer | Second province id.
        methods.add_method("adjacencies", |lua, this, ()| {
            let pairs = this.with_registry(|r| r.adjacency_pairs())?;
            let out = lua.create_table()?;
            for (i, (a, b)) in pairs.into_iter().enumerate() {
                let row = lua.create_table()?;
                /// Performs the 'province_a' operation.
                row.set("province_a", a.0)?;
                /// Performs the 'province_b' operation.
                row.set("province_b", b.0)?;
                out.set(i + 1, row)?;
            }
            Ok(out)
        });
        // -- provinceSpans --
        /// Returns the raw span data for all provinces. Each span is a horizontal run of cells belonging to one province, useful for custom rendering or spatial analysis.
        /// @return | table | Array of tables with fields: province_id (number), y (number), x0 (number), x1 (number).
        /// @field | province_id | integer | Province id.
        /// @field | y | number | Scanline y coordinate.
        /// @field | x0 | number | Start x coordinate.
        /// @field | x1 | number | End x coordinate.
        methods.add_method("provinceSpans", |lua, this, ()| {
            let spans = this.with_registry(|r| r.spans().to_vec())?;
            let out = lua.create_table()?;
            for (i, (id, y, x0, x1)) in spans.into_iter().enumerate() {
                let row = lua.create_table()?;
                /// Performs the 'province_id' operation.
                row.set("province_id", id)?;
                /// The 'y' field value exposed to Lua scripts.
                row.set("y", y)?;
                /// The 'x0' field value exposed to Lua scripts.
                row.set("x0", x0)?;
                /// The 'x1' field value exposed to Lua scripts.
                row.set("x1", x1)?;
                out.set(i + 1, row)?;
            }
            Ok(out)
        });
        // -- borderSegments --
        /// Returns all border line segments between adjacent provinces. Each segment is a line from (x0,y0) to (x1,y1) separating province_a from province_b.
        /// @return | table | Array of tables with fields: province_a (number), province_b (number), x0 (number), y0 (number), x1 (number), y1 (number).
        /// @field | province_a | integer | First province id.
        /// @field | province_b | integer | Second province id.
        /// @field | x0 | number | Segment start x.
        /// @field | y0 | number | Segment start y.
        /// @field | x1 | number | Segment end x.
        /// @field | y1 | number | Segment end y.
        methods.add_method("borderSegments", |lua, this, ()| {
            let segs = this.with_registry(|r| r.border_segments().to_vec())?;
            let out = lua.create_table()?;
            for (i, (a, b, x0, y0, x1, y1)) in segs.into_iter().enumerate() {
                let seg = lua.create_table()?;
                /// Performs the 'province_a' operation.
                seg.set("province_a", a)?;
                /// Performs the 'province_b' operation.
                seg.set("province_b", b)?;
                /// The 'x0' field value exposed to Lua scripts.
                seg.set("x0", x0)?;
                /// The 'y0' field value exposed to Lua scripts.
                seg.set("y0", y0)?;
                /// The 'x1' field value exposed to Lua scripts.
                seg.set("x1", x1)?;
                /// The 'y1' field value exposed to Lua scripts.
                seg.set("y1", y1)?;
                out.set(i + 1, seg)?;
            }
            Ok(out)
        });
        // -- getRevision --
        /// Returns the current change revision counter. Incremented on every mutation (color, terrain, border, fog changes). Use with `getChangesSince` for incremental updates.
        /// @return | integer | Current revision number.
        methods.add_method("getRevision", |_, this, ()| {
            this.with_registry(|r| r.revision())
        });
        // -- getProvince --
        /// Returns a snapshot table describing a single province: its ID, revision, style (political_color, terrain_type, border_style, fog_state, visibility_state), centroid, and custom attributes.
        /// @param | id | integer | Province ID to query.
        /// @return | table | Province snapshot table, or nil if the ID does not exist.
        /// @field | province_id | integer | Province id.
        /// @field | revision | integer | Revision number.
        /// @field | style | table | Style table with terrain_type, fog_state, etc.
        /// @field | centroid | table | Centroid position table.
        /// @field | attrs | table | Custom attributes table.
        methods.add_method("getProvince", |lua, this, id: u32| {
            let snap = this.with_registry(|r| r.get_province(ProvinceId(id)))?;
            let Some(snap) = snap else {
                return Ok(LuaValue::Nil);
            };
            let out = lua.create_table()?;
            /// Performs the 'province_id' operation.
            out.set("province_id", snap.province_id.0)?;
            /// Performs the 'revision' operation.
            out.set("revision", snap.revision)?;
            let style = lua.create_table()?;
            /// Performs the 'political_color' operation.
            style.set("political_color", {
                let t = lua.create_table()?;
                t.set(1, snap.style.political_color[0])?;
                t.set(2, snap.style.political_color[1])?;
                t.set(3, snap.style.political_color[2])?;
                t.set(4, snap.style.political_color[3])?;
                t
            })?;
            /// Performs the 'terrain_type' operation.
            style.set("terrain_type", snap.style.terrain_type)?;
            /// Performs the 'border_style' operation.
            style.set("border_style", snap.style.border_style)?;
            /// Performs the 'fog_state' operation.
            style.set("fog_state", snap.style.fog_state)?;
            /// Performs the 'visibility_state' operation.
            style.set("visibility_state", snap.style.visibility_state)?;
            /// Performs the 'style' operation.
            out.set("style", style)?;
            if let Some((cx, cy)) = snap.centroid {
                let ct = lua.create_table()?;
                /// The 'x' field value exposed to Lua scripts.
                ct.set("x", cx)?;
                /// The 'y' field value exposed to Lua scripts.
                ct.set("y", cy)?;
                /// Performs the 'centroid' operation.
                out.set("centroid", ct)?;
            }
            let attrs = lua.create_table()?;
            for (k, v) in snap.attrs {
                attrs.set(k, v)?;
            }
            /// Performs the 'attrs' operation.
            out.set("attrs", attrs)?;
            Ok(LuaValue::Table(out))
        });
        // -- getNeighbors --
        /// Returns a table of province IDs that share a border with the given province.
        /// @param | id | integer | Province ID to query.
        /// @return | integer[] | Array of neighboring province IDs.
        methods.add_method("getNeighbors", |lua, this, id: u32| {
            let ids = this.with_registry(|r| r.get_neighbors(ProvinceId(id)))?;
            let out = lua.create_table()?;
            for (i, n) in ids.into_iter().enumerate() {
                out.set(i + 1, n.0)?;
            }
            Ok(out)
        });
        // -- findRoute --
        /// Finds a route between two provinces by adapting registry adjacency to pathfind graph routing. Uses BFS by default or Dijkstra when `cost_fn` is supplied.
        /// @param | from_id | integer | Start province id.
        /// @param | to_id | integer | Target province id.
        /// @param | cost_fn | function? | Optional cost callback `fn(from_id, to_id) -> number`.
        /// @return | table | Array of province ids from start to target; nil when unreachable.
        methods.add_method(
            "findRoute",
            |lua, this, (from_id, to_id, cost_fn): (u32, u32, Option<LuaFunction>)| {
                let (pairs, all_ids) = this.with_registry(|r| {
                    let pairs: Vec<(u32, u32)> = r
                        .adjacency_pairs()
                        .into_iter()
                        .map(|(a, b)| (a.0, b.0))
                        .collect();
                    let ids: Vec<u32> = r.province_ids().into_iter().map(|id| id.0).collect();
                    (pairs, ids)
                })?;

                let adjacency = routing::build_adjacency_map(&pairs);
                let has_from = all_ids.contains(&from_id);
                let has_to = all_ids.contains(&to_id);
                if !has_from || !has_to {
                    return Ok(LuaValue::Nil);
                }

                let route = if let Some(f) = cost_fn {
                    let mut edge_cost: HashMap<(u32, u32), f64> = HashMap::new();
                    for (a, b) in pairs {
                        let ab = f
                            .call::<_, Option<f64>>((a, b))?
                            .unwrap_or(1.0)
                            .max(0.000_001);
                        let ba = f
                            .call::<_, Option<f64>>((b, a))?
                            .unwrap_or(1.0)
                            .max(0.000_001);
                        edge_cost.insert((a, b), ab);
                        edge_cost.insert((b, a), ba);
                    }
                    routing::find_route_dijkstra(&adjacency, from_id, to_id, &|a, b| {
                        edge_cost.get(&(a, b)).copied().unwrap_or(1.0)
                    })
                } else {
                    routing::find_route_bfs(&adjacency, from_id, to_id)
                };

                if let Some(path) = route {
                    let out = lua.create_table()?;
                    for (i, id) in path.into_iter().enumerate() {
                        out.set(i + 1, id)?;
                    }
                    Ok(LuaValue::Table(out))
                } else {
                    Ok(LuaValue::Nil)
                }
            },
        );
        // -- drawCapitalPath --
        /// Emits render commands for a route by connecting consecutive province capitals. Pass the route table returned by `findRoute`; pathfinding itself stays in the routing helpers. Options: mode ("line"|"bezier"), color ({r,g,b,a?} in 0..1), width, pixel_size, curve_offset, and segments.
        /// @param | route | integer[] | Array of province ids whose capitals should be connected in order.
        /// @param | opts | table? | Draw options: mode="line"|"bezier", color={r,g,b,a?}, width=number, pixel_size=number, curve_offset=number, segments=integer.
        /// @return | integer | Number of route hop primitives queued.
        methods.add_method(
            "drawCapitalPath",
            |_, this, (route_tbl, opts): (LuaTable, Option<LuaTable>)| {
                let mut route = Vec::new();
                for value in route_tbl.sequence_values::<u32>() {
                    let id = value?;
                    if id == 0 {
                        return Err(LuaError::RuntimeError(
                            "LProvinceRegistry:drawCapitalPath route ids must be positive"
                                .to_string(),
                        ));
                    }
                    route.push(ProvinceId(id));
                }

                let mut path_opts = ProvinceCapitalPathOptions::default();
                if let Some(t) = opts {
                    if let Some(pixel_size) = t.get::<_, Option<f32>>("pixel_size")? {
                        path_opts.pixel_size = pixel_size.max(0.0001);
                    }
                    if let Some(width) = t.get::<_, Option<f32>>("width")? {
                        path_opts.width = width.max(1.0);
                    }
                    if let Some(color) = t.get::<_, Option<LuaTable>>("color")? {
                        path_opts.color = parse_render_color_table(color, "color")?;
                    }
                    if let Some(mode) = t.get::<_, Option<String>>("mode")? {
                        path_opts.mode = match mode.as_str() {
                            "line" => ProvinceCapitalPathMode::Line,
                            "bezier" => ProvinceCapitalPathMode::Bezier,
                            _ => {
                                return Err(LuaError::RuntimeError(format!(
                                    "LProvinceRegistry:drawCapitalPath unknown mode '{}'",
                                    mode
                                )));
                            }
                        };
                    }
                    if let Some(curve_offset) = t.get::<_, Option<f32>>("curve_offset")? {
                        path_opts.curve_offset = curve_offset;
                    }
                    if let Some(segments) = t.get::<_, Option<u32>>("segments")? {
                        path_opts.segments = segments.max(1);
                    }
                }

                let commands =
                    this.with_registry(|r| generate_capital_path_commands(r, &route, &path_opts))?;
                let primitive_count = commands
                    .iter()
                    .filter(|cmd| {
                        matches!(
                            cmd,
                            RenderCommand::Line { .. } | RenderCommand::DrawQuadBezier { .. }
                        )
                    })
                    .count();
                this.state.borrow_mut().render_commands.extend(commands);
                Ok(primitive_count)
            },
        );
        // -- findRoutes --
        /// Finds routes for a batch of `{from, to}` pairs by adapting registry adjacency to pathfind graph routing.
        /// @param | pairs | table | Array of `{from=integer, to=integer}` tables.
        /// @param | cost_fn | function? | Optional cost callback `fn(from_id, to_id) -> number?`.
        /// @return | table | Array of route arrays (or nil for unreachable entries).
        methods.add_method(
            "findRoutes",
            |lua, this, (pairs_tbl, cost_fn): (LuaTable, Option<LuaFunction>)| {
                let (pairs, all_ids) = this.with_registry(|r| {
                    let pairs: Vec<(u32, u32)> = r
                        .adjacency_pairs()
                        .into_iter()
                        .map(|(a, b)| (a.0, b.0))
                        .collect();
                    let ids: Vec<u32> = r.province_ids().into_iter().map(|id| id.0).collect();
                    (pairs, ids)
                })?;
                let adjacency = routing::build_adjacency_map(&pairs);

                let mut edge_cost: HashMap<(u32, u32), f64> = HashMap::new();
                if let Some(ref f) = cost_fn {
                    for &(a, b) in &pairs {
                        let ab = f
                            .call::<_, Option<f64>>((a, b))?
                            .unwrap_or(1.0)
                            .max(0.000_001);
                        let ba = f
                            .call::<_, Option<f64>>((b, a))?
                            .unwrap_or(1.0)
                            .max(0.000_001);
                        edge_cost.insert((a, b), ab);
                        edge_cost.insert((b, a), ba);
                    }
                }

                let out = lua.create_table()?;
                for (i, pair_val) in pairs_tbl.sequence_values::<LuaTable>().enumerate() {
                    let t = pair_val?;
                    let from_id: u32 = t.get("from")?;
                    let to_id: u32 = t.get("to")?;

                    let route = if !all_ids.contains(&from_id) || !all_ids.contains(&to_id) {
                        None
                    } else if cost_fn.is_some() {
                        routing::find_route_dijkstra(&adjacency, from_id, to_id, &|a, b| {
                            edge_cost.get(&(a, b)).copied().unwrap_or(1.0)
                        })
                    } else {
                        routing::find_route_bfs(&adjacency, from_id, to_id)
                    };

                    if let Some(path) = route {
                        let row = lua.create_table()?;
                        for (j, id) in path.into_iter().enumerate() {
                            row.set(j + 1, id)?;
                        }
                        out.set(i + 1, LuaValue::Table(row))?;
                    } else {
                        out.set(i + 1, LuaValue::Nil)?;
                    }
                }
                Ok(out)
            },
        );
        // -- getConnectedComponents --
        /// Returns connected components in the province adjacency graph via pathfind graph traversal.
        /// @return | table | Array of arrays of province ids.
        methods.add_method("getConnectedComponents", |lua, this, ()| {
            let (pairs, ids) = this.with_registry(|r| {
                let pairs: Vec<(u32, u32)> = r
                    .adjacency_pairs()
                    .into_iter()
                    .map(|(a, b)| (a.0, b.0))
                    .collect();
                let ids: Vec<u32> = r.province_ids().into_iter().map(|id| id.0).collect();
                (pairs, ids)
            })?;
            let adjacency = routing::build_adjacency_map(&pairs);
            let comps = routing::connected_components(&adjacency, &ids);
            let out = lua.create_table()?;
            for (i, comp) in comps.into_iter().enumerate() {
                let row = lua.create_table()?;
                for (j, id) in comp.into_iter().enumerate() {
                    row.set(j + 1, id)?;
                }
                out.set(i + 1, row)?;
            }
            Ok(out)
        });
        // -- findIsolatedProvinces --
        /// Returns provinces that have no adjacent province with the same owner attribute.
        /// @param | owner_attr | string | Attribute key (for example `faction`).
        /// @return | integer[] | Array of isolated province ids.
        methods.add_method("findIsolatedProvinces", |lua, this, owner_attr: String| {
            let (pairs, ids, owner_by_id) = this.with_registry(|r| {
                let pairs: Vec<(u32, u32)> = r
                    .adjacency_pairs()
                    .into_iter()
                    .map(|(a, b)| (a.0, b.0))
                    .collect();
                let ids: Vec<u32> = r.province_ids().into_iter().map(|id| id.0).collect();
                let mut owner_by_id = HashMap::new();
                for id in &ids {
                    if let Some(snap) = r.get_province(ProvinceId(*id)) {
                        let v = snap
                            .attrs
                            .get(owner_attr.as_str())
                            .cloned()
                            .unwrap_or_default();
                        owner_by_id.insert(*id, v);
                    }
                }
                (pairs, ids, owner_by_id)
            })?;

            let adjacency = routing::build_adjacency_map(&pairs);
            let mut isolated = routing::find_isolated_provinces(&adjacency, &owner_by_id);
            isolated.retain(|id| ids.contains(id));

            let out = lua.create_table()?;
            for (i, id) in isolated.into_iter().enumerate() {
                out.set(i + 1, id)?;
            }
            Ok(out)
        });
        // -- isConnected --
        /// Returns true when there is at least one pathfind graph route between two provinces.
        /// @param | from_id | integer | Start province id.
        /// @param | to_id | integer | Target province id.
        /// @return | boolean | True when connected.
        methods.add_method("isConnected", |_, this, (from_id, to_id): (u32, u32)| {
            let (pairs, ids) = this.with_registry(|r| {
                let pairs: Vec<(u32, u32)> = r
                    .adjacency_pairs()
                    .into_iter()
                    .map(|(a, b)| (a.0, b.0))
                    .collect();
                let ids: Vec<u32> = r.province_ids().into_iter().map(|id| id.0).collect();
                (pairs, ids)
            })?;
            if !ids.contains(&from_id) || !ids.contains(&to_id) {
                return Ok(false);
            }
            let adjacency = routing::build_adjacency_map(&pairs);
            Ok(routing::is_connected(&adjacency, from_id, to_id))
        });
        // -- totalAttrForOwner --
        /// Sums a numeric attribute for all provinces with matching owner value.
        /// @param | owner_attr | string | Owner attribute key.
        /// @param | owner_val | string | Owner attribute value to filter by.
        /// @param | sum_attr | string | Numeric attribute key to sum.
        /// @return | number | Total numeric sum.
        methods.add_method(
            "totalAttrForOwner",
            |_, this, (owner_attr, owner_val, sum_attr): (String, String, String)| {
                let (owner_by_id, value_by_id) = this.with_registry(|r| {
                    let ids: Vec<u32> = r.province_ids().into_iter().map(|id| id.0).collect();
                    let mut owner_by_id = HashMap::new();
                    let mut value_by_id = HashMap::new();
                    for id in ids {
                        if let Some(snap) = r.get_province(ProvinceId(id)) {
                            let owner = snap
                                .attrs
                                .get(owner_attr.as_str())
                                .cloned()
                                .unwrap_or_default();
                            owner_by_id.insert(id, owner);
                            let value = snap
                                .attrs
                                .get(sum_attr.as_str())
                                .and_then(|s| s.parse::<f64>().ok())
                                .unwrap_or(0.0);
                            value_by_id.insert(id, value);
                        }
                    }
                    (owner_by_id, value_by_id)
                })?;
                Ok(routing::total_numeric_attr_for_owner(
                    &owner_by_id,
                    &value_by_id,
                    owner_val.as_str(),
                ))
            },
        );
        // -- getBorderType --
        /// Returns the border type ID (0-255) between two adjacent provinces, or nil if not set.
        /// @param | a | integer | First province ID.
        /// @param | b | integer | Second province ID.
        /// @return | integer | Border type ID, or nil.
        methods.add_method("getBorderType", |_, this, (a, b): (u32, u32)| {
            let bt = this.with_registry(|r| r.get_border_type(ProvinceId(a), ProvinceId(b)))?;
            Ok(bt)
        });
        // -- setBorderType --
        /// Sets the border type ID between two adjacent provinces. Register types first with registerBorderType.
        /// @param | a | integer | First province ID.
        /// @param | b | integer | Second province ID.
        /// @param | border_type | integer | Border type ID (0-255).
        methods.add_method_mut(
            "setBorderType",
            |_, this, (a, b, border_type): (u32, u32, u8)| {
                this.with_registry_mut(|r| {
                    r.set_border_type(ProvinceId(a), ProvinceId(b), border_type)
                })?;
                Ok(())
            },
        );
        // -- getBorderClass (backward-compat alias) --
        /// Backward-compatible alias for getBorderType. Returns the border type ID.
        /// @param | a | integer | First province ID.
        /// @param | b | integer | Second province ID.
        /// @return | integer | Border type ID, or nil.
        methods.add_method("getBorderClass", |_, this, (a, b): (u32, u32)| {
            let bt = this.with_registry(|r| r.get_border_type(ProvinceId(a), ProvinceId(b)))?;
            Ok(bt)
        });
        // -- setBorderClass (backward-compat alias) --
        /// Backward-compatible alias for setBorderType. Sets the border type ID.
        /// @param | a | integer | First province ID.
        /// @param | b | integer | Second province ID.
        /// @param | border_type | integer | Border type ID (0-255).
        methods.add_method_mut(
            "setBorderClass",
            |_, this, (a, b, border_type): (u32, u32, u8)| {
                this.with_registry_mut(|r| {
                    r.set_border_type(ProvinceId(a), ProvinceId(b), border_type)
                })?;
                Ok(())
            },
        );
        // -- registerBorderType --
        /// Registers a border type config by ID. Defines visual appearance for borders of this type.
        /// @param | type_id | integer | Border type ID (0-255).
        /// @param | config | table | Config table: name (string), color ({r,g,b,a} numbers 0-255), thickness (number), draw_priority (integer?).
        methods.add_method_mut(
            "registerBorderType",
            |_, this, (type_id, config): (u8, LuaTable)| {
                let name: String = config.get("name")?;
                let color_tbl: LuaTable = config.get("color")?;
                let r_val: f32 = color_tbl.get::<_, f32>(1)? / 255.0;
                let g_val: f32 = color_tbl.get::<_, f32>(2)? / 255.0;
                let b_val: f32 = color_tbl.get::<_, f32>(3)? / 255.0;
                let a_val: f32 = color_tbl.get::<_, Option<f32>>(4)?.unwrap_or(255.0) / 255.0;
                let thickness: f32 = config.get::<_, Option<f32>>("thickness")?.unwrap_or(1.0);
                let draw_priority: u8 = config.get::<_, Option<u8>>("draw_priority")?.unwrap_or(0);
                this.with_registry_mut(|reg| {
                    reg.register_border_type(
                        type_id,
                        BorderTypeConfig {
                            name,
                            color: [r_val, g_val, b_val, a_val],
                            thickness,
                            draw_priority,
                        },
                    )
                })?;
                Ok(())
            },
        );
        // -- setBorderPairStyle --
        /// Sets the style override for a specific adjacency pair, including optional color, thickness, and semantic flags.
        /// @param | a | integer | First province ID.
        /// @param | b | integer | Second province ID.
        /// @param | style | table | Style table with optional fields: color={r,g,b,a}, thickness=number, flags accepts a single string or an array of strings.
        /// @return | boolean | True when style was applied.
        methods.add_method_mut(
            "setBorderPairStyle",
            |_, this, (a, b, style): (u32, u32, LuaTable)| {
                let parsed = parse_border_pair_style_from_lua(&style)?;
                this.with_registry_mut(|r| {
                    r.set_border_pair_style(ProvinceId(a), ProvinceId(b), parsed)
                })?;
                Ok(true)
            },
        );
        // -- getBorderPairStyle --
        /// Returns the style override for a specific adjacency pair, or nil when unset.
        /// @param | a | integer | First province ID.
        /// @param | b | integer | Second province ID.
        /// @return | table | Style table or nil.
        methods.add_method("getBorderPairStyle", |lua, this, (a, b): (u32, u32)| {
            let style =
                this.with_registry(|r| r.get_border_pair_style(ProvinceId(a), ProvinceId(b)))?;
            let Some(style) = style else {
                return Ok(LuaValue::Nil);
            };
            let out = lua.create_table()?;
            out.set("thickness", style.thickness)?;
            if let Some(color) = style.color {
                let c = lua.create_table()?;
                c.set(1, color[0])?;
                c.set(2, color[1])?;
                c.set(3, color[2])?;
                c.set(4, color[3])?;
                out.set("color", c)?;
            }
            let flags = lua.create_table()?;
            for (i, token) in style.flags.to_tokens().into_iter().enumerate() {
                flags.set(i + 1, token)?;
            }
            out.set("flags", flags)?;
            Ok(LuaValue::Table(out))
        });
        // -- setPoliticalColor --
        /// Sets the political map color for a province. Used in political map mode rendering and change tracking.
        /// @param | id | integer | Province ID.
        /// @param | r | number | Red component (0.0â€“1.0).
        /// @param | g | number | Green component (0.0â€“1.0).
        /// @param | b | number | Blue component (0.0â€“1.0).
        /// @param | a | number? | Alpha component (default 1.0).
        /// @return | boolean | True if the province ID exists.
        methods.add_method_mut(
            "setPoliticalColor",
            |_, this, (id, r, g, b, a): (u32, f32, f32, f32, Option<f32>)| {
                this.with_registry_mut(|reg| {
                    reg.set_political_color(ProvinceId(id), [r, g, b, a.unwrap_or(1.0)])
                })
            },
        );
        // -- setTerrainType --
        /// Sets the terrain type index for a province. Terrain type controls which fill color or texture is used in terrain map mode.
        /// @param | id | integer | Province ID.
        /// @param | terrain_type | integer | Terrain type index (game-defined meaning).
        /// @return | boolean | True if the province ID exists.
        methods.add_method_mut(
            "setTerrainType",
            |_, this, (id, terrain_type): (u32, u32)| {
                this.with_registry_mut(|reg| reg.set_terrain_type(ProvinceId(id), terrain_type))
            },
        );
        // -- setBorderStyle --
        /// Sets the border rendering style index for a province. Controls line thickness, color, or pattern when borders are drawn.
        /// @param | id | integer | Province ID.
        /// @param | border_style | integer | Border style index (game-defined meaning).
        /// @return | boolean | True if the province ID exists.
        methods.add_method_mut(
            "setBorderStyle",
            |_, this, (id, border_style): (u32, u32)| {
                this.with_registry_mut(|reg| reg.set_border_style(ProvinceId(id), border_style))
            },
        );
        // -- setFogState --
        /// Sets a fog-of-war byte for a province. This value is game-defined metadata and can be used by scripts/map modes.
        /// @param | id | integer | Province ID.
        /// @param | fog_state | integer | Fog state value (game-defined meaning).
        /// @return | boolean | True if the province ID exists.
        methods.add_method_mut("setFogState", |_, this, (id, fog_state): (u32, u8)| {
            this.with_registry_mut(|reg| reg.set_fog_state(ProvinceId(id), fog_state))
        });
        // -- setVisibilityState --
        /// Sets the render visibility state for a province. `0` = hidden (no fill/border/capital/label), `1` = discovered (gray fill only), `2+` = fully visible.
        /// @param | id | integer | Province ID.
        /// @param | visibility_state | integer | Visibility state byte.
        /// @return | boolean | True if the province ID exists.
        methods.add_method_mut(
            "setVisibilityState",
            |_, this, (id, visibility_state): (u32, u8)| {
                this.with_registry_mut(|reg| {
                    reg.set_visibility_state(ProvinceId(id), visibility_state)
                })
            },
        );
        // -- setAttr --
        /// Sets a custom string attribute on a province. Attributes are returned in the `attrs` table of `getProvince` and can store arbitrary game metadata.
        /// @param | id | integer | Province ID.
        /// @param | key | string | Attribute name.
        /// @param | value | string | Attribute value.
        /// @return | boolean | True if the province ID exists.
        methods.add_method_mut(
            "setAttr",
            |_, this, (id, key, value): (u32, String, String)| {
                this.with_registry_mut(|reg| reg.set_attr(ProvinceId(id), key, value))
            },
        );
        // -- setCapital --
        /// Sets the capital marker position for a province. The capital is drawn as a small icon during `render` when `draw_capitals` is enabled.
        /// @param | id | integer | Province ID.
        /// @param | x | number | Capital x position in map space.
        /// @param | y | number | Capital y position in map space.
        /// @return | boolean | True if the province ID exists.
        methods.add_method_mut("setCapital", |_, this, (id, x, y): (u32, f32, f32)| {
            this.with_registry_mut(|reg| reg.set_capital(ProvinceId(id), x, y))
        });
        // -- setLabelLine --
        /// Sets the label baseline for a province. The label text is rendered along the line from (ax,ay) to (bx,by), allowing curved or angled province names.
        /// @param | id | integer | Province ID.
        /// @param | ax | number | Start x of the label line in map space.
        /// @param | ay | number | Start y of the label line in map space.
        /// @param | bx | number | End x of the label line in map space.
        /// @param | by | number | End y of the label line in map space.
        /// @return | boolean | True if the province ID exists.
        methods.add_method_mut(
            "setLabelLine",
            |_, this, (id, ax, ay, bx, by): (u32, f32, f32, f32, f32)| {
                this.with_registry_mut(|reg| reg.set_label_line(ProvinceId(id), ax, ay, bx, by))
            },
        );
        // -- setLabelText --
        /// Sets the display name text for a province. Rendered on the map when `draw_labels` is enabled in `render` options.
        /// @param | id | integer | Province ID.
        /// @param | text | string | Province display name.
        /// @return | boolean | True if the province ID exists.
        methods.add_method_mut("setLabelText", |_, this, (id, text): (u32, String)| {
            this.with_registry_mut(|reg| reg.set_label_text(ProvinceId(id), text))
        });
        // -- importMetadataFromFiles --
        /// Bulk-imports province metadata (colors, capitals, labels, terrain) from external files (PNG color map, CSV color table, TOML province definitions, marker PNG). Returns a summary of how many provinces were mapped.
        /// @param | opts | table | Options table with fields: color_map_png (string, required), color_csv (string, required), marker_png (string?), province_toml (string?), water_terrain_tokens (table?), water_terrain_type (number?), land_terrain_type (number?), set_political_colors (boolean?), set_label_text (boolean?), set_capitals (boolean?), set_label_lines (boolean?), marker_options (table?).
        /// @return | table | Summary with fields: mapped_provinces (number), capitals_set (number), label_lines_set (number), labels_set (number).
        /// @field | mapped_provinces | integer | Mapped provinces count.
        /// @field | capitals_set | integer | Capitals set count.
        /// @field | label_lines_set | integer | Label lines set count.
        /// @field | labels_set | integer | Labels set count.
        methods.add_method_mut("importMetadataFromFiles", |lua, this, opts: LuaTable| {
            let color_map_png =
                opts.get::<_, Option<String>>("color_map_png")?
                    .ok_or_else(|| {
                        LuaError::RuntimeError(
                        "lurek.province.importMetadataFromFiles: opts.color_map_png is required"
                            .to_string(),
                    )
                    })?;
            let color_csv = opts.get::<_, Option<String>>("color_csv")?.ok_or_else(|| {
                LuaError::RuntimeError(
                    "lurek.province.importMetadataFromFiles: opts.color_csv is required"
                        .to_string(),
                )
            })?;
            let marker_png = opts.get::<_, Option<String>>("marker_png")?;
            let province_toml = opts.get::<_, Option<String>>("province_toml")?;
            let mut water_tokens = vec!["sea".to_string(), "river".to_string()];
            if let Some(tbl) = opts.get::<_, Option<LuaTable>>("water_terrain_tokens")? {
                let mut parsed = Vec::new();
                for value in tbl.sequence_values::<String>() {
                    parsed.push(value?);
                }
                if !parsed.is_empty() {
                    water_tokens = parsed;
                }
            }
            let mut import_opts = ProvinceMetadataImportOptions::default();
            import_opts.color_map_png_path = resolve_game_path(&this.state, color_map_png.as_str());
            import_opts.marker_png_path = marker_png
                .as_ref()
                .map(|p| resolve_game_path(&this.state, p.as_str()));
            import_opts.color_csv_path = resolve_game_path(&this.state, color_csv.as_str());
            import_opts.province_toml_path = province_toml
                .as_ref()
                .map(|p| resolve_game_path(&this.state, p.as_str()));
            import_opts.water_terrain_tokens = water_tokens;
            import_opts.water_terrain_type = opts
                .get::<_, Option<u32>>("water_terrain_type")?
                .unwrap_or(import_opts.water_terrain_type);
            import_opts.land_terrain_type = opts
                .get::<_, Option<u32>>("land_terrain_type")?
                .unwrap_or(import_opts.land_terrain_type);
            import_opts.set_political_colors = opts
                .get::<_, Option<bool>>("set_political_colors")?
                .unwrap_or(import_opts.set_political_colors);
            import_opts.set_label_text = opts
                .get::<_, Option<bool>>("set_label_text")?
                .unwrap_or(import_opts.set_label_text);
            import_opts.set_capitals = opts
                .get::<_, Option<bool>>("set_capitals")?
                .unwrap_or(import_opts.set_capitals);
            import_opts.set_label_lines = opts
                .get::<_, Option<bool>>("set_label_lines")?
                .unwrap_or(import_opts.set_label_lines);
            import_opts.marker_options = marker_options_from_lua(
                opts.get::<_, Option<LuaTable>>("marker_options")?.as_ref(),
            );
            let summary = this
                .with_registry_mut(|reg| import_metadata_from_files(reg, &import_opts))?
                .map_err(LuaError::RuntimeError)?;
            let out = lua.create_table()?;
            /// Performs the 'mapped_provinces' operation.
            out.set("mapped_provinces", summary.mapped_provinces)?;
            /// Performs the 'capitals_set' operation.
            out.set("capitals_set", summary.capitals_set)?;
            /// Performs the 'label_lines_set' operation.
            out.set("label_lines_set", summary.label_lines_set)?;
            /// Performs the 'labels_set' operation.
            out.set("labels_set", summary.labels_set)?;
            Ok(out)
        });
        // -- render --
        /// Renders the province map to the screen using the current camera and style settings. Generates draw commands for fills, borders, labels, and capitals based on the provided options. Optional `tint` multiplies all province fill colours for this render only, while `province_tints` supplies render-time fill colour overrides keyed by province id without mutating the registry.
        /// @param | opts | table? | Render options: backend ("commands"|"gpu"|"segments"?), map_mode (string?), x/y/zoom/pixel_size/screen_w/screen_h (number?), tint ({r,g,b,a?}?), province_tints (table<integer,{r,g,b,a?}>?), segment_reuse_cache (boolean?), terrain_texture (LImage?), terrain_texture_scale/terrain_texture_strength (number?), edge_gradient_radius (output pixels?), edge_gradient_strength/edge_gradient_softness (number?), edge_gradient_color ({r,g,b,a?}?), border_palette ({province_color|land_color,coast_color,country_color,sea_darken}?), province_border_color/coast_border_color/country_border_color ({r,g,b,a?}?), sea_border_darken (number?), draw_fills/draw_borders/draw_labels/draw_capitals/draw_roads (boolean?), border_width (number?), zoom_mode ("auto"|"strategic"|"tactical"), tactical_zoom_threshold (number?), hovered_id/selected_id (integer?).
        methods.add_method("render", |_, this, opts: Option<LuaTable>| {
            let opts = opts;
            let backend = if let Some(ref t) = opts {
                t.get::<_, Option<String>>("backend")?
                    .unwrap_or_else(|| "commands".to_string())
            } else {
                "commands".to_string()
            };
            let mode = if let Some(ref t) = opts {
                t.get::<_, Option<String>>("map_mode")?
                    .unwrap_or_else(|| "political".to_string())
            } else {
                "political".to_string()
            };
            let tint = if let Some(ref t) = opts {
                t.get::<_, Option<LuaTable>>("tint")?
                    .map(|t| parse_render_color_table(t, "tint"))
                    .transpose()?
            } else {
                None
            };
            let province_tints = if let Some(ref t) = opts {
                parse_province_tints_from_lua(t.get::<_, Option<LuaTable>>("province_tints")?)?
            } else {
                HashMap::new()
            };
            let options = ProvinceRenderOptions {
                x: opts
                    .as_ref()
                    .and_then(|t| t.get::<_, Option<f32>>("x").ok().flatten())
                    .unwrap_or(0.0),
                y: opts
                    .as_ref()
                    .and_then(|t| t.get::<_, Option<f32>>("y").ok().flatten())
                    .unwrap_or(0.0),
                zoom: opts
                    .as_ref()
                    .and_then(|t| t.get::<_, Option<f32>>("zoom").ok().flatten())
                    .unwrap_or(1.0),
                pixel_size: opts
                    .as_ref()
                    .and_then(|t| t.get::<_, Option<f32>>("pixel_size").ok().flatten())
                    .unwrap_or(1.0),
                screen_w: opts
                    .as_ref()
                    .and_then(|t| t.get::<_, Option<f32>>("screen_w").ok().flatten())
                    .unwrap_or(1280.0),
                screen_h: opts
                    .as_ref()
                    .and_then(|t| t.get::<_, Option<f32>>("screen_h").ok().flatten())
                    .unwrap_or(720.0),
                map_mode: mode,
                tint,
                province_tints,
                draw_fills: opts
                    .as_ref()
                    .and_then(|t| t.get::<_, Option<bool>>("draw_fills").ok().flatten())
                    .unwrap_or(true),
                draw_borders: opts
                    .as_ref()
                    .and_then(|t| t.get::<_, Option<bool>>("draw_borders").ok().flatten())
                    .unwrap_or(true),
                draw_labels: opts
                    .as_ref()
                    .and_then(|t| t.get::<_, Option<bool>>("draw_labels").ok().flatten())
                    .unwrap_or(false),
                draw_capitals: opts
                    .as_ref()
                    .and_then(|t| t.get::<_, Option<bool>>("draw_capitals").ok().flatten())
                    .unwrap_or(true),
                border_width: opts
                    .as_ref()
                    .and_then(|t| t.get::<_, Option<f32>>("border_width").ok().flatten())
                    .unwrap_or(1.0),
                zoom_mode: parse_zoom_mode_from_lua(
                    opts.as_ref()
                        .and_then(|t| t.get::<_, Option<String>>("zoom_mode").ok().flatten()),
                ),
                tactical_zoom_threshold: opts
                    .as_ref()
                    .and_then(|t| {
                        t.get::<_, Option<f32>>("tactical_zoom_threshold")
                            .ok()
                            .flatten()
                    })
                    .unwrap_or(3.0),
                draw_roads: opts
                    .as_ref()
                    .and_then(|t| t.get::<_, Option<bool>>("draw_roads").ok().flatten())
                    .unwrap_or(true),
                hovered_id: opts
                    .as_ref()
                    .and_then(|t| t.get::<_, Option<u32>>("hovered_id").ok().flatten())
                    .map(ProvinceId),
                selected_id: opts
                    .as_ref()
                    .and_then(|t| t.get::<_, Option<u32>>("selected_id").ok().flatten())
                    .map(ProvinceId),
            };
            if backend == "gpu" {
                let (left, top, right, bottom) = viewport_bounds(&options);
                let zoom_mode = match resolve_zoom_mode(&options) {
                    ProvinceZoomMode::Strategic | ProvinceZoomMode::Auto => 0,
                    ProvinceZoomMode::Tactical => 1,
                };
                let time = opts
                    .as_ref()
                    .and_then(|t| t.get::<_, Option<f32>>("time").ok().flatten())
                    .unwrap_or(0.0);
                let terrain_texture = if let Some(ref t) = opts {
                    t.get::<_, Option<LuaAnyUserData>>("terrain_texture")?
                        .map(|ud| {
                            let image = ud.borrow::<LuaImage>().map_err(|_| {
                                LuaError::RuntimeError(
                                    "LProvinceRegistry:render terrain_texture must be LImage from lurek.render.newImage()"
                                        .to_string(),
                                )
                            })?;
                            LuaResult::Ok(image.key)
                        })
                        .transpose()?
                } else {
                    None
                };
                let terrain_texture_scale = opts
                    .as_ref()
                    .and_then(|t| t.get::<_, Option<f32>>("terrain_texture_scale").ok().flatten())
                    .unwrap_or(32.0)
                    .max(1.0);
                let terrain_texture_strength = opts
                    .as_ref()
                    .and_then(|t| {
                        t.get::<_, Option<f32>>("terrain_texture_strength")
                            .ok()
                            .flatten()
                    })
                    .unwrap_or(if terrain_texture.is_some() { 0.08 } else { 0.0 })
                    .clamp(0.0, 1.0);
                let edge_gradient_color = opts
                    .as_ref()
                    .and_then(|t| t.get::<_, Option<LuaTable>>("edge_gradient_color").ok().flatten())
                    .map(|t| parse_render_color_table(t, "edge_gradient_color"))
                    .transpose()?
                    .unwrap_or([64.0 / 255.0, 64.0 / 255.0, 60.0 / 255.0, 1.0]);
                let edge_gradient_radius = opts
                    .as_ref()
                    .and_then(|t| t.get::<_, Option<f32>>("edge_gradient_radius").ok().flatten())
                    .unwrap_or(16.0)
                    .clamp(0.0, 32.0);
                let edge_gradient_strength = opts
                    .as_ref()
                    .and_then(|t| {
                        t.get::<_, Option<f32>>("edge_gradient_strength")
                            .ok()
                            .flatten()
                    })
                    .unwrap_or(0.25)
                    .clamp(0.0, 1.0);
                let edge_gradient_softness = opts
                    .as_ref()
                    .and_then(|t| {
                        t.get::<_, Option<f32>>("edge_gradient_softness")
                            .ok()
                            .flatten()
                    })
                    .unwrap_or(0.45)
                    .clamp(0.05, 2.0);
                let border_palette = parse_border_palette_from_lua(opts.as_ref())?;
                this.state
                    .borrow_mut()
                    .render_commands
                    .push(RenderCommand::DrawProvinceMap {
                        registry_name: this.name.clone(),
                        viewport: [left, top, right, bottom],
                        screen_size: [options.screen_w, options.screen_h],
                        tint: options.tint.unwrap_or([1.0, 1.0, 1.0, 1.0]),
                        province_tints: options
                            .province_tints
                            .iter()
                            .map(|(id, color)| (id.raw(), *color))
                            .collect(),
                        terrain_texture,
                        terrain_texture_scale,
                        terrain_texture_strength,
                        edge_gradient_color,
                        edge_gradient_radius,
                        edge_gradient_strength,
                        edge_gradient_softness,
                        border_palette_enabled: border_palette.enabled,
                        province_border_color: border_palette.province_border_color,
                        coast_border_color: border_palette.coast_border_color,
                        country_border_color: border_palette.country_border_color,
                        sea_border_darken: border_palette.sea_border_darken,
                        selected_id: options.selected_id.map(|id| id.raw()).unwrap_or(0),
                        hovered_id: options.hovered_id.map(|id| id.raw()).unwrap_or(0),
                        zoom_mode,
                        time,
                    });

                if options.draw_labels || options.draw_capitals || options.draw_roads {
                    let mut overlay_options = options.clone();
                    overlay_options.draw_fills = false;
                    overlay_options.draw_borders = false;
                    let font_key = {
                        let st = this.state.borrow();
                        st.active_font.or(st.default_font)
                    };
                    let cmds = this.with_registry(|reg| {
                        generate_render_commands(reg, &overlay_options, font_key)
                    })?;
                    this.state.borrow_mut().render_commands.extend(cmds);
                }
                return Ok(());
            }
            if backend == "segments" {
                let segment_reuse_cache = opts
                    .as_ref()
                    .and_then(|t| t.get::<_, Option<bool>>("segment_reuse_cache").ok().flatten())
                    .unwrap_or(false);
                let edge_gradient_radius = opts
                    .as_ref()
                    .and_then(|t| t.get::<_, Option<f32>>("edge_gradient_radius").ok().flatten())
                    .unwrap_or(16.0)
                    .clamp(0.0, 128.0);
                let edge_gradient_strength = opts
                    .as_ref()
                    .and_then(|t| {
                        t.get::<_, Option<f32>>("edge_gradient_strength")
                            .ok()
                            .flatten()
                    })
                    .unwrap_or(0.25)
                    .clamp(0.0, 1.0);
                this.queue_segment_render(
                    &options,
                    edge_gradient_radius,
                    edge_gradient_strength,
                    segment_reuse_cache,
                )?;

                if options.draw_labels || options.draw_capitals || options.draw_roads {
                    let mut overlay_options = options.clone();
                    overlay_options.draw_fills = false;
                    overlay_options.draw_borders = false;
                    let font_key = {
                        let st = this.state.borrow();
                        st.active_font.or(st.default_font)
                    };
                    let cmds = this.with_registry(|reg| {
                        generate_render_commands(reg, &overlay_options, font_key)
                    })?;
                    this.state.borrow_mut().render_commands.extend(cmds);
                }
                return Ok(());
            }
            if backend != "commands" {
                return Err(LuaError::RuntimeError(format!(
                    "unknown province render backend '{}'",
                    backend
                )));
            }
            let font_key = {
                let st = this.state.borrow();
                st.active_font.or(st.default_font)
            };
            let cmds = this.with_registry(|reg| {
                wrap_province_commands_with_shader(
                    reg.get_shader(),
                    generate_render_commands(reg, &options, font_key),
                )
            })?;
            extend_province_render_commands(&mut this.state.borrow_mut(), cmds);
            Ok(())
        });
        // -- getChangesSince --
        /// Returns all province changes that occurred after the given revision. Each entry contains the revision number and a change record describing what was modified (political_color, terrain_type, border_style, fog_state, visibility_state, or border_class).
        /// @param | revision | integer | The revision to query from (exclusive). Pass the last known revision to get only new changes.
        /// @return | table | Array of change tables, each with a `revision` field and change-specific fields (kind, province_id, etc.).
        /// @field | revision | integer | Change revision number.
        /// @field | kind | string | Change kind (political_color, terrain_type, etc.).
        /// @field | province_id | integer? | Province id when applicable.
        methods.add_method("getChangesSince", |lua, this, revision: u64| {
            let changes = this.with_registry(|r| r.get_changes_since(revision))?;
            let out = lua.create_table()?;
            for (i, (rev, ch)) in changes.into_iter().enumerate() {
                let row = lua.create_table()?;
                /// Performs the 'revision' operation.
                row.set("revision", rev)?;
                match ch {
                    ProvinceChange::PoliticalColor { province_id, color } => {
                        /// Performs the 'kind' operation.
                        row.set("kind", "political_color")?;
                        /// Performs the 'province_id' operation.
                        row.set("province_id", province_id.0)?;
                        let c = lua.create_table()?;
                        c.set(1, color[0])?;
                        c.set(2, color[1])?;
                        c.set(3, color[2])?;
                        c.set(4, color[3])?;
                        /// Performs the 'color' operation.
                        row.set("color", c)?;
                    }
                    ProvinceChange::TerrainType {
                        province_id,
                        terrain_type,
                    } => {
                        /// Performs the 'kind' operation.
                        row.set("kind", "terrain_type")?;
                        /// Performs the 'province_id' operation.
                        row.set("province_id", province_id.0)?;
                        /// Performs the 'terrain_type' operation.
                        row.set("terrain_type", terrain_type)?;
                    }
                    ProvinceChange::BorderStyle {
                        province_id,
                        border_style,
                    } => {
                        /// Performs the 'kind' operation.
                        row.set("kind", "border_style")?;
                        /// Performs the 'province_id' operation.
                        row.set("province_id", province_id.0)?;
                        /// Performs the 'border_style' operation.
                        row.set("border_style", border_style)?;
                    }
                    ProvinceChange::FogState {
                        province_id,
                        fog_state,
                    } => {
                        /// Performs the 'kind' operation.
                        row.set("kind", "fog_state")?;
                        /// Performs the 'province_id' operation.
                        row.set("province_id", province_id.0)?;
                        /// Performs the 'fog_state' operation.
                        row.set("fog_state", fog_state)?;
                    }
                    ProvinceChange::VisibilityState {
                        province_id,
                        visibility_state,
                    } => {
                        /// Performs the 'kind' operation.
                        row.set("kind", "visibility_state")?;
                        /// Performs the 'province_id' operation.
                        row.set("province_id", province_id.0)?;
                        /// Performs the 'visibility_state' operation.
                        row.set("visibility_state", visibility_state)?;
                    }
                    ProvinceChange::BorderType {
                        province_a,
                        province_b,
                        border_type,
                    } => {
                        /// Performs the 'kind' operation.
                        row.set("kind", "border_type")?;
                        /// Performs the 'province_a' operation.
                        row.set("province_a", province_a.0)?;
                        /// Performs the 'province_b' operation.
                        row.set("province_b", province_b.0)?;
                        /// Performs the 'border_type' operation.
                        row.set("border_type", border_type)?;
                    }
                    ProvinceChange::BorderPairStyle {
                        province_a,
                        province_b,
                        color,
                        thickness,
                        flags,
                    } => {
                        /// Performs the 'kind' operation.
                        row.set("kind", "border_pair_style")?;
                        /// Performs the 'province_a' operation.
                        row.set("province_a", province_a.0)?;
                        /// Performs the 'province_b' operation.
                        row.set("province_b", province_b.0)?;
                        /// Performs the 'thickness' operation.
                        row.set("thickness", thickness)?;
                        /// Performs the 'flags' operation.
                        row.set("flags", flags)?;
                        if let Some(color) = color {
                            let c = lua.create_table()?;
                            c.set(1, color[0])?;
                            c.set(2, color[1])?;
                            c.set(3, color[2])?;
                            c.set(4, color[3])?;
                            /// Performs the 'color' operation.
                            row.set("color", c)?;
                        }
                    }
                    ProvinceChange::MapModeChanged { mode } => {
                        row.set("kind", "map_mode_changed")?;
                        row.set("mode", mode)?;
                    }
                }
                out.set(i + 1, row)?;
            }
            Ok(out)
        });
        // -- registerMapMode --
        /// Registers a named map mode with display configuration. Overwrites if name exists.
        /// @param | name | string | Map mode identifier (e.g. "political", "religion", "economy").
        /// @param | config | table | Config: show_labels (bool?), show_borders (bool?), show_roads (bool?), show_capitals (bool?), show_values (bool?), value_property (string?), color_property (string?), fog_intensity (number?), border_filter (integer[]?).
        methods.add_method_mut(
            "registerMapMode",
            |_, this, (name, config): (String, LuaTable)| {
                let map_config = MapModeConfig {
                    name: name.clone(),
                    show_labels: config
                        .get::<_, Option<bool>>("show_labels")?
                        .unwrap_or(true),
                    show_borders: config
                        .get::<_, Option<bool>>("show_borders")?
                        .unwrap_or(true),
                    show_roads: config.get::<_, Option<bool>>("show_roads")?.unwrap_or(true),
                    show_capitals: config
                        .get::<_, Option<bool>>("show_capitals")?
                        .unwrap_or(true),
                    show_values: config
                        .get::<_, Option<bool>>("show_values")?
                        .unwrap_or(false),
                    value_property: config.get::<_, Option<String>>("value_property")?,
                    color_property: config.get::<_, Option<String>>("color_property")?,
                    fog_intensity: config
                        .get::<_, Option<f32>>("fog_intensity")?
                        .unwrap_or(1.0),
                    border_filter: {
                        let filter: Option<LuaTable> = config.get("border_filter")?;
                        match filter {
                            Some(t) => {
                                let mut v = Vec::new();
                                for i in 1..=t.len()? {
                                    v.push(t.get::<_, u8>(i)?);
                                }
                                v
                            }
                            None => Vec::new(),
                        }
                    },
                };
                this.with_registry_mut(|r| r.register_map_mode(&name, map_config))?;
                Ok(())
            },
        );
        // -- setMapMode --
        /// Switches the active map mode to a previously registered mode name.
        /// @param | name | string | Mode name to activate.
        /// @return | boolean | True if mode exists and was activated.
        methods.add_method_mut("setMapMode", |_, this, name: String| {
            let ok = this.with_registry_mut(|r| r.set_map_mode(&name))?;
            Ok(ok)
        });
        // -- getMapMode --
        /// Returns the name of the currently active map mode.
        /// @return | string | Active mode name.
        methods.add_method("getMapMode", |_, this, ()| {
            let name = this.with_registry(|r| r.active_map_mode().to_string())?;
            Ok(name)
        });
        // -- type --
        /// Returns the type name string for this userdata object.
        /// @return | string | Always "LProvinceRegistry".
        methods.add_method("type", |_, _, ()| Ok("LProvinceRegistry"));
        // -- typeOf --
        /// Checks whether this object matches the given type name. Returns true for "LProvinceRegistry" and "Object".
        /// @param | name | string | Type name to check.
        /// @return | boolean | True if the name matches.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LProvinceRegistry" || name == "LObject")
        });
    }
}
/// Registers the `lurek.province` module table and all its functions into the Lua state.
pub fn register(lua: &Lua, lurek: &LuaTable, state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let tbl = lua.create_table()?;
    let s = state.clone();
    // -- newFromPng --
    /// Creates a new province registry by loading a color-coded PNG where each unique color represents a distinct province. The PNG is parsed into a grid and adjacencies are computed automatically.
    /// @param | name | string | Unique registry name for later retrieval.
    /// @param | png_path | string | Path to the province map PNG (relative to game directory or absolute).
    /// @return | LProvinceRegistry | The newly created registry handle.
    tbl.set(
        "newFromPng",
        lua.create_function(move |_, (name, png_path): (String, String)| {
            let resolved_path = resolve_game_path(&s, png_path.as_str());
            let grid = ProvinceGrid::from_file(&resolved_path).map_err(LuaError::RuntimeError)?;
            let registry = ProvinceRegistry::from_grid(&grid);
            {
                let mut st = s.borrow_mut();
                st.province_registries.insert(name.clone(), registry);
                st.active_province_registry = Some(name.clone());
            }
            Ok(LuaProvinceRegistry {
                name,
                state: s.clone(),
            })
        })?,
    )?;
    let s = state.clone();
    // -- sanitizeMarkedPng --
    /// Pre-processes a marker PNG by replacing capital and label marker pixels with the surrounding province color. Outputs a cleaned PNG suitable for `newFromPng`. Returns a summary of pixel replacements.
    /// @param | input_png | string | Path to the source marker PNG.
    /// @param | output_png | string | Path to write the sanitized output PNG.
    /// @param | opts | table? | Marker detection thresholds: capital_min (number?), label_r_min (number?), label_g_max (number?), label_b_min (number?), search_radius (number?).
    /// @return | table | Summary with fields: replaced_pixels (number), unresolved_pixels (number).
    /// @field | replaced_pixels | integer | Replaced pixel count.
    /// @field | unresolved_pixels | integer | Unresolved pixel count.
    tbl.set(
        "sanitizeMarkedPng",
        lua.create_function(
            move |lua, (input_png, output_png, opts): (String, String, Option<LuaTable>)| {
                let in_path = resolve_game_path(&s, input_png.as_str());
                let out_path = resolve_game_path(&s, output_png.as_str());
                let marker_opts = marker_options_from_lua(opts.as_ref());
                let summary =
                    sanitize_marked_png(in_path.as_str(), out_path.as_str(), &marker_opts)
                        .map_err(LuaError::RuntimeError)?;
                let out = lua.create_table()?;
                /// Performs the 'replaced_pixels' operation.
                out.set("replaced_pixels", summary.replaced_pixels)?;
                /// Performs the 'unresolved_pixels' operation.
                out.set("unresolved_pixels", summary.unresolved_pixels)?;
                Ok(out)
            },
        )?,
    )?;
    let s = state.clone();
    // -- get --
    /// Retrieves an existing province registry by name. Returns nil if no registry with that name has been created.
    /// @param | name | string | Registry name to look up.
    /// @return | LProvinceRegistry | The registry handle, or nil if not found.
    tbl.set(
        "get",
        lua.create_function(move |_, name: String| {
            let exists = s.borrow().province_registries.contains_key(&name);
            if exists {
                Ok(Some(LuaProvinceRegistry {
                    name,
                    state: s.clone(),
                }))
            } else {
                Ok(None::<LuaProvinceRegistry>)
            }
        })?,
    )?;
    let s = state.clone();
    // -- exists --
    /// Checks whether a province registry with the given name exists.
    /// @param | name | string | Registry name to check.
    /// @return | boolean | True if the registry exists.
    tbl.set(
        "exists",
        lua.create_function(move |_, name: String| {
            Ok(s.borrow().province_registries.contains_key(&name))
        })?,
    )?;
    let s = state.clone();
    // -- remove --
    /// Removes a province registry by name and clears the active registry if it was the one removed. Returns true if a registry was actually removed.
    /// @param | name | string | Registry name to remove.
    /// @return | boolean | True if the registry existed and was removed.
    tbl.set(
        "remove",
        lua.create_function(move |_, name: String| {
            let mut st = s.borrow_mut();
            let removed = st.province_registries.remove(&name).is_some();
            if st.active_province_registry.as_deref() == Some(name.as_str()) {
                st.active_province_registry = None;
            }
            Ok(removed)
        })?,
    )?;
    let s = state.clone();
    // -- setActive --
    /// Sets the named registry as the active province registry. Returns false if no registry with that name exists.
    /// @param | name | string | Registry name to activate.
    /// @return | boolean | True if the registry was found and activated.
    tbl.set(
        "setActive",
        lua.create_function(move |_, name: String| {
            let mut st = s.borrow_mut();
            if st.province_registries.contains_key(&name) {
                st.active_province_registry = Some(name);
                Ok(true)
            } else {
                Ok(false)
            }
        })?,
    )?;
    let s = state.clone();
    // -- getActive --
    /// Returns the currently active province registry, or nil if none is set.
    /// @return | LProvinceRegistry | The active registry handle, or nil.
    tbl.set(
        "getActive",
        lua.create_function(move |_, ()| {
            let name_opt = s.borrow().active_province_registry.clone();
            Ok(name_opt.map(|name| LuaProvinceRegistry {
                name,
                state: s.clone(),
            }))
        })?,
    )?;
    // -- zoomCameraAt --
    /// Computes new camera position after zooming centered on an anchor point. Keeps the anchor point visually stationary on screen while the zoom level changes.
    /// @param | anchor_x | number | Anchor x in screen space.
    /// @param | anchor_y | number | Anchor y in screen space.
    /// @param | cam_x | number | Current camera x.
    /// @param | cam_y | number | Current camera y.
    /// @param | old_zoom | number | Previous zoom level.
    /// @param | new_zoom | number | Target zoom level.
    /// @return | number, number | New camera x and y after zoom adjustment.
    tbl.set(
        "zoomCameraAt",
        lua.create_function(
            move |_,
                  (anchor_x, anchor_y, cam_x, cam_y, old_zoom, new_zoom): (
                f32,
                f32,
                f32,
                f32,
                f32,
                f32,
            )| {
                Ok(zoom_camera_at(
                    anchor_x, anchor_y, cam_x, cam_y, old_zoom, new_zoom,
                ))
            },
        )?,
    )?;
    let s = state.clone();
    // -- setProperty --
    /// Sets a numeric property on a province. Game logic defines the semantics of each key.
    /// @param | id | integer | Province ID.
    /// @param | key | string | Property name.
    /// @param | value | number | Numeric value to store.
    tbl.set(
        "setProperty",
        lua.create_function(move |_, (id, key, value): (u32, String, f64)| {
            s.borrow_mut()
                .province_properties
                .set_numeric(id, &key, value);
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- getProperty --
    /// Gets a numeric property from a province. Returns nil if not set.
    /// @param | id | integer | Province ID.
    /// @param | key | string | Property name.
    /// @return | number | The stored value, or nil.
    tbl.set(
        "getProperty",
        lua.create_function(move |_, (id, key): (u32, String)| {
            Ok(s.borrow().province_properties.get_numeric(id, &key))
        })?,
    )?;
    let s = state.clone();
    // -- setAttr --
    /// Sets a string attribute on a province.
    /// @param | id | integer | Province ID.
    /// @param | key | string | Attribute name.
    /// @param | value | string | String value to store.
    tbl.set(
        "setAttr",
        lua.create_function(move |_, (id, key, value): (u32, String, String)| {
            s.borrow_mut()
                .province_properties
                .set_string(id, &key, &value);
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- getAttr --
    /// Gets a string attribute from a province. Returns nil if not set.
    /// @param | id | integer | Province ID.
    /// @param | key | string | Attribute name.
    /// @return | string | The stored value, or nil.
    tbl.set(
        "getAttr",
        lua.create_function(move |_, (id, key): (u32, String)| {
            Ok(s.borrow()
                .province_properties
                .get_string(id, &key)
                .map(|s| s.to_string()))
        })?,
    )?;
    let s = state.clone();
    // -- setFlag --
    /// Sets a single flag bit (0â€“63) on a province.
    /// @param | id | integer | Province ID.
    /// @param | bit | integer | Flag bit index (0â€“63).
    /// @param | value | boolean | True to set, false to clear.
    tbl.set(
        "setFlag",
        lua.create_function(move |_, (id, bit, value): (u32, u8, bool)| {
            s.borrow_mut().province_properties.set_flag(id, bit, value);
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- hasFlag --
    /// Checks whether a flag bit is set on a province.
    /// @param | id | integer | Province ID.
    /// @param | bit | integer | Flag bit index (0â€“63).
    /// @return | boolean | True if the flag bit is set.
    tbl.set(
        "hasFlag",
        lua.create_function(move |_, (id, bit): (u32, u8)| {
            Ok(s.borrow().province_properties.has_flag(id, bit))
        })?,
    )?;
    let s = state.clone();
    // -- clearProperties --
    /// Removes all properties, attributes, and flags for a province.
    /// @param | id | integer | Province ID.
    tbl.set(
        "clearProperties",
        lua.create_function(move |_, id: u32| {
            s.borrow_mut().province_properties.clear_province(id);
            Ok(())
        })?,
    )?;
    /// Performs the 'province' operation.
    lurek.set("province", tbl)?;
    Ok(())
}
