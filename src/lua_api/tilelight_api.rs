//! Registers lurek.lua_api Lua API bindings for tilelight api, including validation, conversions, and userdata.

use super::tilefield_api::{field_from_provider, LuaTileField};
use super::SharedState;
use crate::tilefield::CellCoord;
use crate::tilelight::{
    AreaLightUpdate, LightColor, LightModulation, LineLightUpdate, PointLightUpdate, SunLight,
    SunLightMode, TileLightMap,
};
use mlua::prelude::*;
use std::cell::RefCell;
use std::rc::Rc;

/// Lua-side handle wrapping a tile light map tied to one shared tilefield.
pub(crate) struct LuaTileLightMap {
    pub(crate) field: Rc<RefCell<crate::tilefield::TileField>>,
    pub(crate) inner: RefCell<TileLightMap>,
}

fn lua_err(api: &str, err: impl std::fmt::Display) -> LuaError {
    LuaError::RuntimeError(format!("lurek.tilelight.{api}: {err}"))
}

fn one_based(value: u32, label: &str) -> LuaResult<u32> {
    value
        .checked_sub(1)
        .ok_or_else(|| LuaError::RuntimeError(format!("lurek.tilelight: {label} must be >= 1")))
}

fn coord_from_values(x: u32, y: u32, z: Option<u32>) -> LuaResult<CellCoord> {
    Ok(CellCoord {
        x: one_based(x, "x")?,
        y: one_based(y, "y")?,
        z: one_based(z.unwrap_or(1), "z")?,
    })
}

fn coord_from_table(table: LuaTable, api: &str) -> LuaResult<CellCoord> {
    let x: u32 = table.get("x").map_err(|e| lua_err(api, e))?;
    let y: u32 = table.get("y").map_err(|e| lua_err(api, e))?;
    let z: Option<u32> = table.get("z").map_err(|e| lua_err(api, e))?;
    coord_from_values(x, y, z).map_err(|e| lua_err(api, e))
}

fn shared_field_from_value(
    value: LuaValue,
    api: &str,
) -> LuaResult<Rc<RefCell<crate::tilefield::TileField>>> {
    match value {
        LuaValue::UserData(field_ud) => {
            let field = field_ud.borrow::<LuaTileField>()?;
            Ok(field.inner.clone())
        }
        LuaValue::Table(provider) => {
            let field = field_from_provider(provider, api)?;
            Ok(Rc::new(RefCell::new(field)))
        }
        other => Err(lua_err(
            api,
            format!(
                "expected LTileField or provider table, got {}",
                other.type_name()
            ),
        )),
    }
}

fn color_from_table(
    table: Option<LuaTable>,
    default: LightColor,
    api: &str,
) -> LuaResult<LightColor> {
    let Some(table) = table else {
        return Ok(default);
    };
    Ok(LightColor {
        r: table
            .get::<_, Option<f32>>("r")
            .map_err(|e| lua_err(api, e))?
            .unwrap_or(default.r),
        g: table
            .get::<_, Option<f32>>("g")
            .map_err(|e| lua_err(api, e))?
            .unwrap_or(default.g),
        b: table
            .get::<_, Option<f32>>("b")
            .map_err(|e| lua_err(api, e))?
            .unwrap_or(default.b),
    }
    .clamped())
}

fn light_to_lua<'lua>(lua: &'lua Lua, color: LightColor) -> LuaResult<LuaTable<'lua>> {
    let table = lua.create_table()?;
    table.set("r", color.r)?;
    table.set("g", color.g)?;
    table.set("b", color.b)?;
    table.set("luma", color.luma())?;
    Ok(table)
}

struct TileLightLuaParser;

impl TileLightLuaParser {
    fn modulation_from_table(table: Option<LuaTable>, api: &str) -> LuaResult<LightModulation> {
        let mut modulation = LightModulation::default();
        let Some(table) = table else {
            return Ok(modulation);
        };
        if let Some(flicker) = table
            .get::<_, Option<LuaTable>>("flicker")
            .map_err(|e| lua_err(api, e))?
        {
            modulation.intensity_amplitude = flicker
                .get::<_, Option<f32>>("amplitude")
                .map_err(|e| lua_err(api, e))?
                .unwrap_or(0.0)
                .clamp(0.0, 1.0);
            modulation.intensity_frequency_hz = flicker
                .get::<_, Option<f32>>("frequency")
                .map_err(|e| lua_err(api, e))?
                .or_else(|| flicker.get::<_, Option<f32>>("frequencyHz").ok().flatten())
                .unwrap_or(0.0)
                .max(0.0);
            modulation.intensity_phase = flicker
                .get::<_, Option<f32>>("phase")
                .map_err(|e| lua_err(api, e))?
                .unwrap_or(0.0);
        }
        if let Some(cycle) = table
            .get::<_, Option<LuaTable>>("colorCycle")
            .map_err(|e| lua_err(api, e))?
        {
            modulation.color_a = Some(color_from_table(
                cycle
                    .get::<_, Option<LuaTable>>("from")
                    .map_err(|e| lua_err(api, e))?,
                LightColor::WHITE,
                api,
            )?);
            modulation.color_b = Some(color_from_table(
                cycle
                    .get::<_, Option<LuaTable>>("to")
                    .map_err(|e| lua_err(api, e))?,
                LightColor::WHITE,
                api,
            )?);
            modulation.color_frequency_hz = cycle
                .get::<_, Option<f32>>("frequency")
                .map_err(|e| lua_err(api, e))?
                .or_else(|| cycle.get::<_, Option<f32>>("frequencyHz").ok().flatten())
                .unwrap_or(0.0)
                .max(0.0);
            modulation.color_phase = cycle
                .get::<_, Option<f32>>("phase")
                .map_err(|e| lua_err(api, e))?
                .unwrap_or(0.0);
        }
        Ok(modulation)
    }
}

fn modulation_from_table(table: Option<LuaTable>, api: &str) -> LuaResult<LightModulation> {
    TileLightLuaParser::modulation_from_table(table, api)
}

fn modulation_patch_from_table(table: LuaTable, api: &str) -> LuaResult<Option<LightModulation>> {
    let has_flicker = table
        .get::<_, Option<LuaTable>>("flicker")
        .map_err(|e| lua_err(api, e))?
        .is_some();
    let has_color_cycle = table
        .get::<_, Option<LuaTable>>("colorCycle")
        .map_err(|e| lua_err(api, e))?
        .is_some();
    if has_flicker || has_color_cycle {
        modulation_from_table(Some(table), api).map(Some)
    } else {
        Ok(None)
    }
}

impl TileLightLuaParser {
    fn compute_opts(
        opts: Option<LuaTable>,
    ) -> LuaResult<(bool, bool, bool, bool, Option<LightColor>, f32)> {
        if let Some(opts) = opts {
            let include_point = opts
                .get::<_, Option<bool>>("includePointLights")
                .map_err(|e| lua_err("compute", e))?
                .unwrap_or(true);
            let include_line = opts
                .get::<_, Option<bool>>("includeLineLights")
                .map_err(|e| lua_err("compute", e))?
                .unwrap_or(true);
            let include_area = opts
                .get::<_, Option<bool>>("includeAreaLights")
                .map_err(|e| lua_err("compute", e))?
                .or_else(|| {
                    opts.get::<_, Option<bool>>("includeRectLights")
                        .ok()
                        .flatten()
                })
                .unwrap_or(true);
            let include_sun = opts
                .get::<_, Option<bool>>("includeSunLight")
                .map_err(|e| lua_err("compute", e))?
                .unwrap_or(true);
            let ambient = opts
                .get::<_, Option<LuaTable>>("ambient")
                .map_err(|e| lua_err("compute", e))?
                .map(|table| color_from_table(Some(table), LightColor::BLACK, "compute"))
                .transpose()?;
            let time_seconds = opts
                .get::<_, Option<f32>>("time")
                .map_err(|e| lua_err("compute", e))?
                .or_else(|| opts.get::<_, Option<f32>>("timeSeconds").ok().flatten())
                .unwrap_or(0.0);
            Ok((
                include_point,
                include_line,
                include_area,
                include_sun,
                ambient,
                time_seconds,
            ))
        } else {
            Ok((true, true, true, true, None, 0.0))
        }
    }
}

fn compute_opts(
    opts: Option<LuaTable>,
) -> LuaResult<(bool, bool, bool, bool, Option<LightColor>, f32)> {
    TileLightLuaParser::compute_opts(opts)
}

impl TileLightLuaParser {
    fn sun_from_table(opts: LuaTable, api: &str) -> LuaResult<SunLight> {
        let intensity = opts
            .get::<_, Option<f32>>("intensity")
            .map_err(|e| lua_err(api, e))?
            .unwrap_or(0.0);
        let color = color_from_table(
            opts.get::<_, Option<LuaTable>>("color")
                .map_err(|e| lua_err(api, e))?,
            LightColor::WHITE,
            api,
        )?;
        let kind = opts
            .get::<_, Option<String>>("kind")
            .map_err(|e| lua_err(api, e))?
            .or_else(|| opts.get::<_, Option<String>>("mode").ok().flatten())
            .unwrap_or_else(|| "top".to_string());
        let mode = match kind.as_str() {
            "top" | "vertical" => SunLightMode::Top,
            "directional" => {
                let direction = opts
                    .get::<_, Option<LuaTable>>("direction")
                    .map_err(|e| lua_err(api, e))?;
                let dx = direction
                    .as_ref()
                    .and_then(|table| table.get::<_, Option<i32>>("x").ok().flatten())
                    .or_else(|| opts.get::<_, Option<i32>>("dx").ok().flatten())
                    .unwrap_or(0);
                let dy = direction
                    .as_ref()
                    .and_then(|table| table.get::<_, Option<i32>>("y").ok().flatten())
                    .or_else(|| opts.get::<_, Option<i32>>("dy").ok().flatten())
                    .unwrap_or(1);
                SunLightMode::Directional { dx, dy }
            }
            other => {
                return Err(lua_err(
                    api,
                    format!("unknown sun kind '{other}' (expected top or directional)"),
                ))
            }
        };
        Ok(SunLight {
            intensity,
            color,
            mode,
        })
    }
}

fn sun_from_table(opts: LuaTable, api: &str) -> LuaResult<SunLight> {
    TileLightLuaParser::sun_from_table(opts, api)
}

fn area_size_from_table(opts: &LuaTable, api: &str) -> LuaResult<(u32, u32)> {
    let width = opts
        .get::<_, Option<u32>>("width")
        .map_err(|e| lua_err(api, e))?
        .or_else(|| opts.get::<_, Option<u32>>("w").ok().flatten())
        .ok_or_else(|| lua_err(api, "width/w is required"))?;
    let height = opts
        .get::<_, Option<u32>>("height")
        .map_err(|e| lua_err(api, e))?
        .or_else(|| opts.get::<_, Option<u32>>("h").ok().flatten())
        .ok_or_else(|| lua_err(api, "height/h is required"))?;
    Ok((width, height))
}

fn add_area_light_from_opts(this: &LuaTileLightMap, opts: LuaTable, api: &str) -> LuaResult<u32> {
    let coord = coord_from_table(opts.clone(), api)?;
    let (width, height) = area_size_from_table(&opts, api)?;
    let radius: f32 = opts.get("radius").map_err(|e| lua_err(api, e))?;
    let intensity: f32 = opts
        .get::<_, Option<f32>>("intensity")
        .map_err(|e| lua_err(api, e))?
        .unwrap_or(1.0);
    let color = color_from_table(
        opts.get::<_, Option<LuaTable>>("color")
            .map_err(|e| lua_err(api, e))?,
        LightColor::WHITE,
        api,
    )?;
    let modulation = modulation_from_table(Some(opts), api)?;
    let field = this.field.borrow();
    this.inner
        .borrow_mut()
        .add_area_light(
            &field, coord, width, height, radius, intensity, color, modulation,
        )
        .map_err(|e| lua_err(api, e))
}

impl TileLightLuaParser {
    fn update_area_light_from_opts(
        this: &LuaTileLightMap,
        id: u32,
        opts: LuaTable,
        api: &str,
    ) -> LuaResult<()> {
        let parse_coord = |name: &str| -> LuaResult<Option<u32>> {
            opts.get::<_, Option<u32>>(name)
                .map_err(|e| lua_err(api, e))?
                .map(|v| one_based(v, name))
                .transpose()
        };
        let width = opts
            .get::<_, Option<u32>>("width")
            .map_err(|e| lua_err(api, e))?
            .or_else(|| opts.get::<_, Option<u32>>("w").ok().flatten());
        let height = opts
            .get::<_, Option<u32>>("height")
            .map_err(|e| lua_err(api, e))?
            .or_else(|| opts.get::<_, Option<u32>>("h").ok().flatten());
        let radius = opts
            .get::<_, Option<f32>>("radius")
            .map_err(|e| lua_err(api, e))?;
        let intensity = opts
            .get::<_, Option<f32>>("intensity")
            .map_err(|e| lua_err(api, e))?;
        let color = match opts
            .get::<_, Option<LuaTable>>("color")
            .map_err(|e| lua_err(api, e))?
        {
            Some(table) => Some(color_from_table(Some(table), LightColor::WHITE, api)?),
            None => None,
        };
        let modulation = modulation_patch_from_table(opts.clone(), api)?;
        let field = this.field.borrow();
        this.inner
            .borrow_mut()
            .update_area_light(
                &field,
                id,
                AreaLightUpdate {
                    x: parse_coord("x")?,
                    y: parse_coord("y")?,
                    z: parse_coord("z")?,
                    width,
                    height,
                    radius,
                    intensity,
                    color,
                    modulation,
                },
            )
            .map_err(|e| lua_err(api, e))
    }
}

fn update_area_light_from_opts(
    this: &LuaTileLightMap,
    id: u32,
    opts: LuaTable,
    api: &str,
) -> LuaResult<()> {
    TileLightLuaParser::update_area_light_from_opts(this, id, opts, api)
}

impl LuaUserData for LuaTileLightMap {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- addPointLight --
        /// Adds a point light and returns its stable id.
        /// @param | opts | table | `{x, y, z?, radius, intensity?, color?, flicker?, colorCycle?}` light definition.
        methods.add_method("addPointLight", |_, this, opts: LuaTable| {
            let coord = coord_from_table(opts.clone(), "LTileLightMap.addPointLight")?;
            let radius: f32 = opts
                .get("radius")
                .map_err(|e| lua_err("LTileLightMap.addPointLight", e))?;
            let intensity: f32 = opts
                .get::<_, Option<f32>>("intensity")
                .map_err(|e| lua_err("LTileLightMap.addPointLight", e))?
                .unwrap_or(1.0);
            let color = color_from_table(
                opts.get::<_, Option<LuaTable>>("color")
                    .map_err(|e| lua_err("LTileLightMap.addPointLight", e))?,
                LightColor::WHITE,
                "LTileLightMap.addPointLight",
            )?;
            let modulation =
                modulation_from_table(Some(opts.clone()), "LTileLightMap.addPointLight")?;
            let field = this.field.borrow();
            this.inner
                .borrow_mut()
                .add_point_light(
                    &field, coord.x, coord.y, coord.z, radius, intensity, color, modulation,
                )
                .map_err(|e| lua_err("LTileLightMap.addPointLight", e))
        });

        // -- updatePointLight --
        /// Updates an existing point light by id.
        /// @param | id | integer | Stable point light id returned by `addPointLight`.
        /// @param | opts | table | Partial light update table with x, y, z, radius, intensity, or color.
        methods.add_method(
            "updatePointLight",
            |_, this, (id, opts): (u32, LuaTable)| {
                let x = opts
                    .get::<_, Option<u32>>("x")
                    .map_err(|e| lua_err("LTileLightMap.updatePointLight", e))?
                    .map(|v| one_based(v, "x"))
                    .transpose()?;
                let y = opts
                    .get::<_, Option<u32>>("y")
                    .map_err(|e| lua_err("LTileLightMap.updatePointLight", e))?
                    .map(|v| one_based(v, "y"))
                    .transpose()?;
                let z = opts
                    .get::<_, Option<u32>>("z")
                    .map_err(|e| lua_err("LTileLightMap.updatePointLight", e))?
                    .map(|v| one_based(v, "z"))
                    .transpose()?;
                let radius = opts
                    .get::<_, Option<f32>>("radius")
                    .map_err(|e| lua_err("LTileLightMap.updatePointLight", e))?;
                let intensity = opts
                    .get::<_, Option<f32>>("intensity")
                    .map_err(|e| lua_err("LTileLightMap.updatePointLight", e))?;
                let color = match opts
                    .get::<_, Option<LuaTable>>("color")
                    .map_err(|e| lua_err("LTileLightMap.updatePointLight", e))?
                {
                    Some(table) => Some(color_from_table(
                        Some(table),
                        LightColor::WHITE,
                        "LTileLightMap.updatePointLight",
                    )?),
                    None => None,
                };
                let modulation =
                    modulation_patch_from_table(opts.clone(), "LTileLightMap.updatePointLight")?;
                let field = this.field.borrow();
                this.inner
                    .borrow_mut()
                    .update_point_light(
                        &field,
                        id,
                        PointLightUpdate {
                            x,
                            y,
                            z,
                            radius,
                            intensity,
                            color,
                            modulation,
                        },
                    )
                    .map_err(|e| lua_err("LTileLightMap.updatePointLight", e))
            },
        );

        // -- removePointLight --
        /// Removes a point light by id and returns whether it existed.
        /// @param | id | integer | Stable point light id returned by `addPointLight`.
        /// @return | boolean | True when a point light was removed.
        methods.add_method("removePointLight", |_, this, id: u32| {
            Ok(this.inner.borrow_mut().remove_point_light(id))
        });

        // -- clearPointLights --
        /// Removes all point lights currently stored on this tile light map.
        methods.add_method("clearPointLights", |_, this, ()| {
            this.inner.borrow_mut().clear_point_lights();
            Ok(())
        });

        // -- addLineLight --
        /// Adds a tile line light and returns its stable id.
        /// @param | opts | table | `{x1,y1,z1?,x2,y2,z2?,radius,intensity?,color?,flicker?,colorCycle?}`.
        methods.add_method("addLineLight", |_, this, opts: LuaTable| {
            let start = coord_from_values(
                opts.get("x1")
                    .map_err(|e| lua_err("LTileLightMap.addLineLight", e))?,
                opts.get("y1")
                    .map_err(|e| lua_err("LTileLightMap.addLineLight", e))?,
                opts.get("z1")
                    .map_err(|e| lua_err("LTileLightMap.addLineLight", e))?,
            )
            .map_err(|e| lua_err("LTileLightMap.addLineLight", e))?;
            let end = coord_from_values(
                opts.get("x2")
                    .map_err(|e| lua_err("LTileLightMap.addLineLight", e))?,
                opts.get("y2")
                    .map_err(|e| lua_err("LTileLightMap.addLineLight", e))?,
                opts.get("z2")
                    .map_err(|e| lua_err("LTileLightMap.addLineLight", e))?,
            )
            .map_err(|e| lua_err("LTileLightMap.addLineLight", e))?;
            let radius: f32 = opts
                .get("radius")
                .map_err(|e| lua_err("LTileLightMap.addLineLight", e))?;
            let intensity: f32 = opts
                .get::<_, Option<f32>>("intensity")
                .map_err(|e| lua_err("LTileLightMap.addLineLight", e))?
                .unwrap_or(1.0);
            let color = color_from_table(
                opts.get::<_, Option<LuaTable>>("color")
                    .map_err(|e| lua_err("LTileLightMap.addLineLight", e))?,
                LightColor::WHITE,
                "LTileLightMap.addLineLight",
            )?;
            let modulation =
                modulation_from_table(Some(opts.clone()), "LTileLightMap.addLineLight")?;
            let field = this.field.borrow();
            this.inner
                .borrow_mut()
                .add_line_light(&field, start, end, radius, intensity, color, modulation)
                .map_err(|e| lua_err("LTileLightMap.addLineLight", e))
        });

        // -- updateLineLight --
        /// Updates an existing tile line light by id.
        /// @param | id | integer | Stable line light id returned by `addLineLight`.
        /// @param | opts | table | Partial line light update.
        methods.add_method("updateLineLight", |_, this, (id, opts): (u32, LuaTable)| {
            let parse_u32 = |name: &str| -> LuaResult<Option<u32>> {
                opts.get::<_, Option<u32>>(name)
                    .map_err(|e| lua_err("LTileLightMap.updateLineLight", e))?
                    .map(|v| one_based(v, name))
                    .transpose()
            };
            let radius = opts
                .get::<_, Option<f32>>("radius")
                .map_err(|e| lua_err("LTileLightMap.updateLineLight", e))?;
            let intensity = opts
                .get::<_, Option<f32>>("intensity")
                .map_err(|e| lua_err("LTileLightMap.updateLineLight", e))?;
            let color = match opts
                .get::<_, Option<LuaTable>>("color")
                .map_err(|e| lua_err("LTileLightMap.updateLineLight", e))?
            {
                Some(table) => Some(color_from_table(
                    Some(table),
                    LightColor::WHITE,
                    "LTileLightMap.updateLineLight",
                )?),
                None => None,
            };
            let modulation =
                modulation_patch_from_table(opts.clone(), "LTileLightMap.updateLineLight")?;
            let field = this.field.borrow();
            this.inner
                .borrow_mut()
                .update_line_light(
                    &field,
                    id,
                    LineLightUpdate {
                        x1: parse_u32("x1")?,
                        y1: parse_u32("y1")?,
                        z1: parse_u32("z1")?,
                        x2: parse_u32("x2")?,
                        y2: parse_u32("y2")?,
                        z2: parse_u32("z2")?,
                        radius,
                        intensity,
                        color,
                        modulation,
                    },
                )
                .map_err(|e| lua_err("LTileLightMap.updateLineLight", e))
        });

        // -- removeLineLight --
        /// Removes a line light by id and returns whether it existed.
        /// @param | id | integer | Stable line-light id returned by `addLineLight`.
        /// @return | boolean | True when a line light was removed.
        methods.add_method("removeLineLight", |_, this, id: u32| {
            Ok(this.inner.borrow_mut().remove_line_light(id))
        });

        // -- clearLineLights --
        /// Removes all line lights currently stored on this tile light map.
        methods.add_method("clearLineLights", |_, this, ()| {
            this.inner.borrow_mut().clear_line_lights();
            Ok(())
        });

        // -- addAreaLight --
        /// Adds a rectangular area light and returns its stable id.
        /// @param | opts | table | `{x,y,z?,width|w,height|h,radius,intensity?,color?,flicker?,colorCycle?}`.
        methods.add_method("addAreaLight", |_, this, opts: LuaTable| {
            add_area_light_from_opts(this, opts, "LTileLightMap.addAreaLight")
        });

        // -- addRectLight --
        /// Creates a rectangular area light via `addAreaLight`.
        /// @param | opts | table | `{x,y,z?,width|w,height|h,radius,intensity?,color?,flicker?,colorCycle?}`.
        /// @return | integer | Stable rectangular light id.
        methods.add_method("addRectLight", |_, this, opts: LuaTable| {
            add_area_light_from_opts(this, opts, "LTileLightMap.addRectLight")
        });

        // -- updateAreaLight --
        /// Updates an existing rectangular area light by id.
        /// @param | id | integer | Stable area-light id returned by `addAreaLight`.
        /// @param | opts | table | Area-light fields to update.
        methods.add_method("updateAreaLight", |_, this, (id, opts): (u32, LuaTable)| {
            update_area_light_from_opts(this, id, opts, "LTileLightMap.updateAreaLight")
        });

        // -- updateRectLight --
        /// Updates a rectangular area light via `updateAreaLight`.
        /// @param | id | integer | Stable rectangular light id returned by `addRectLight`.
        /// @param | opts | table | Rectangular-light fields to update.
        methods.add_method("updateRectLight", |_, this, (id, opts): (u32, LuaTable)| {
            update_area_light_from_opts(this, id, opts, "LTileLightMap.updateRectLight")
        });

        // -- removeAreaLight --
        /// Removes a rectangular area light by id and returns whether it existed.
        /// @param | id | integer | Stable area-light id returned by `addAreaLight`.
        /// @return | boolean | True when an area light was removed.
        methods.add_method("removeAreaLight", |_, this, id: u32| {
            Ok(this.inner.borrow_mut().remove_area_light(id))
        });

        // -- removeRectLight --
        /// Removes a rectangular area light via `removeAreaLight`.
        /// @param | id | integer | Stable rectangular light id returned by `addRectLight`.
        /// @return | boolean | True when a rectangular light was removed.
        methods.add_method("removeRectLight", |_, this, id: u32| {
            Ok(this.inner.borrow_mut().remove_area_light(id))
        });

        // -- clearAreaLights --
        /// Removes all rectangular area lights currently stored on this tile light map.
        methods.add_method("clearAreaLights", |_, this, ()| {
            this.inner.borrow_mut().clear_area_lights();
            Ok(())
        });

        // -- clearRectLights --
        /// Clears all rectangular area lights via `clearAreaLights`.
        methods.add_method("clearRectLights", |_, this, ()| {
            this.inner.borrow_mut().clear_area_lights();
            Ok(())
        });

        // -- setAmbient --
        /// Sets ambient tile light stored on this light map.
        /// @param | color | table | `{r,g,b}` ambient color.
        methods.add_method("setAmbient", |_, this, color: LuaTable| {
            let color =
                color_from_table(Some(color), LightColor::BLACK, "LTileLightMap.setAmbient")?;
            this.inner.borrow_mut().set_ambient_light(color);
            Ok(())
        });

        // -- setSunLight --
        /// Sets tile sun light parameters used during light computation.
        /// @param | opts | table | `{kind='top'|'directional', intensity?, color?, direction?}`.
        methods.add_method("setSunLight", |_, this, opts: LuaTable| {
            let sun = sun_from_table(opts, "LTileLightMap.setSunLight")?;
            this.inner.borrow_mut().set_sun_light(sun);
            Ok(())
        });

        // -- setGlobalLight --
        /// Compatibility alias for top sun light parameters used during light computation.
        /// @param | opts | table | `{intensity?, color?}` top-light settings.
        methods.add_method("setGlobalLight", |_, this, opts: LuaTable| {
            let sun = sun_from_table(opts, "LTileLightMap.setGlobalLight")?;
            this.inner.borrow_mut().set_sun_light(sun);
            Ok(())
        });

        // -- compute --
        /// Computes tile light from ambient, point lights, line lights, and sun light.
        /// @param | opts | table? | Optional includePointLights, includeLineLights, includeAreaLights, includeSunLight, ambient, and time settings.
        methods.add_method("compute", |_, this, opts: Option<LuaTable>| {
            let (include_point, include_line, include_area, include_sun, ambient, time_seconds) =
                compute_opts(opts)?;
            let field = this.field.borrow();
            this.inner
                .borrow_mut()
                .compute(
                    &field,
                    include_point,
                    include_line,
                    include_area,
                    include_sun,
                    ambient,
                    time_seconds,
                )
                .map_err(|e| lua_err("LTileLightMap.compute", e))
        });

        // -- getLight --
        /// Returns r, g, b, and luma for one cell.
        /// @param | x | integer | One-based cell x coordinate.
        /// @param | y | integer | One-based cell y coordinate.
        /// @param | z | integer? | One-based level, default 1.
        /// @return | number, number, number, number | Red, green, blue, and luma values for the cell.
        methods.add_method("getLight", |_, this, (x, y, z): (u32, u32, Option<u32>)| {
            let coord = coord_from_values(x, y, z)?;
            let color = this.inner.borrow().light_at(coord);
            Ok((color.r, color.g, color.b, color.luma()))
        });

        // -- exportLayer --
        /// Exports one level of computed light as row-major `{r,g,b,luma}` tables.
        /// @param | z | integer? | One-based level, default 1.
        /// @return | table | Row-major array of light color tables for the requested level.
        methods.add_method("exportLayer", |lua, this, z: Option<u32>| {
            let z = one_based(z.unwrap_or(1), "z")?;
            let values = this.inner.borrow().export_layer(z);
            let out = lua.create_table()?;
            for (i, color) in values.into_iter().enumerate() {
                out.set(i + 1, light_to_lua(lua, color)?)?;
            }
            Ok(out)
        });

        // -- exportVolume --
        /// Exports all computed light levels as nested row-major tables.
        /// @return | table | Array of exported light layers, one table per level.
        methods.add_method("exportVolume", |lua, this, ()| {
            let volume = this.inner.borrow().export_volume();
            let out = lua.create_table()?;
            for (z, layer_values) in volume.into_iter().enumerate() {
                let layer = lua.create_table()?;
                for (i, color) in layer_values.into_iter().enumerate() {
                    layer.set(i + 1, light_to_lua(lua, color)?)?;
                }
                out.set(z + 1, layer)?;
            }
            Ok(out)
        });

        // -- getSize --
        /// Returns light-map width, height, and level count.
        /// @return | integer, integer, integer | Width, height, and level count.
        methods.add_method("getSize", |_, this, ()| Ok(this.inner.borrow().size()));

        // -- type --
        /// Returns the Lua-visible type name for this tile light map handle.
        /// @return | string | The string `LTileLightMap`.
        methods.add_method("type", |_, _, ()| Ok("LTileLightMap"));

        // -- typeOf --
        /// Returns whether this handle matches a supported type name.
        /// @param | name | string | Type name to compare.
        /// @return | boolean | True for `LTileLightMap` or `LObject`.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LTileLightMap" || name == "LObject")
        });
    }
}

/// Registers `lurek.tilelight`.
pub fn register(lua: &Lua, lurek: &LuaTable, _state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let tbl = lua.create_table()?;

    // -- new --
    /// Creates a tile light map attached to a shared tilefield or copied from a Lua tilefield provider table.
    /// @param | field | LTileField|table | Source tilefield handle or provider table.
    /// @return | LTileLightMap | New tile light map handle.
    tbl.set(
        "new",
        lua.create_function(|_, field_value: LuaValue| {
            let shared_field = shared_field_from_value(field_value, "new")?;
            let field = shared_field.borrow();
            let light_map = TileLightMap::from_field(&field).map_err(|e| lua_err("new", e))?;
            drop(field);
            Ok(LuaTileLightMap {
                field: shared_field,
                inner: RefCell::new(light_map),
            })
        })?,
    )?;

    // -- compute --
    /// Creates and computes a tile light map for a shared tilefield or Lua tilefield provider table.
    /// @param | field | LTileField|table | Source tilefield handle or provider table.
    /// @param | opts | table? | Optional includePointLights, includeLineLights, includeSunLight, ambient, and time settings.
    /// @return | LTileLightMap | Computed tile light map handle.
    tbl.set(
        "compute",
        lua.create_function(|_, (field_value, opts): (LuaValue, Option<LuaTable>)| {
            let shared_field = shared_field_from_value(field_value, "compute")?;
            let field = shared_field.borrow();
            let (include_point, include_line, include_area, include_sun, ambient, time_seconds) =
                compute_opts(opts)?;
            let mut light_map =
                TileLightMap::from_field(&field).map_err(|e| lua_err("compute", e))?;
            light_map
                .compute(
                    &field,
                    include_point,
                    include_line,
                    include_area,
                    include_sun,
                    ambient,
                    time_seconds,
                )
                .map_err(|e| lua_err("compute", e))?;
            drop(field);
            Ok(LuaTileLightMap {
                field: shared_field,
                inner: RefCell::new(light_map),
            })
        })?,
    )?;

    lurek.set("tilelight", tbl)?;
    Ok(())
}
