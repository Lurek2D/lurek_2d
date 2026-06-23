//! Registers the `lurek.tilefield` Lua API for multi-level tile gameplay semantics.
//! The binding layer converts Lua tables and one-based coordinates while the Rust domain module owns field behavior.

use super::tilemap_api::LuaTileMap;
use super::SharedState;
use crate::tilefield::{
    CellCoord, GlobalLight, LightColor, PointLightUpdate, TileChannel, TileField, TileProfile,
    TileTopology,
};
use mlua::prelude::*;
use std::cell::RefCell;
use std::collections::HashSet;
use std::rc::Rc;

/// Lua-side handle wrapping a shared tilefield.
pub struct LuaTileField {
    /// Shared tilefield state used by adapters in sibling Lua modules.
    pub(crate) inner: Rc<RefCell<TileField>>,
}

fn lua_err(api: &str, err: impl std::fmt::Display) -> LuaError {
    LuaError::RuntimeError(format!("lurek.tilefield.{api}: {err}"))
}

fn one_based(value: u32, label: &str) -> LuaResult<u32> {
    value
        .checked_sub(1)
        .ok_or_else(|| LuaError::RuntimeError(format!("lurek.tilefield: {label} must be >= 1")))
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

fn channel_from_str(value: String, api: &str) -> LuaResult<TileChannel> {
    TileChannel::parse(&value).map_err(|err| lua_err(api, err))
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

fn profile_from_table(table: LuaTable, api: &str) -> LuaResult<TileProfile> {
    let mut profile = TileProfile::default();
    if let Ok(blocks) = table.get::<_, LuaTable>("blocks") {
        for pair in blocks.pairs::<String, bool>() {
            let (name, value) = pair.map_err(|e| lua_err(api, e))?;
            profile.blockers.insert(channel_from_str(name, api)?, value);
        }
    }
    if let Ok(costs) = table.get::<_, LuaTable>("costs") {
        for pair in costs.pairs::<String, f32>() {
            let (name, value) = pair.map_err(|e| lua_err(api, e))?;
            if !value.is_finite() || value < 0.0 {
                return Err(lua_err(api, "cost values must be finite and >= 0"));
            }
            profile.costs.insert(channel_from_str(name, api)?, value);
        }
    }
    profile.sun_occlusion = table
        .get::<_, Option<f32>>("sunOcclusion")
        .map_err(|e| lua_err(api, e))?
        .unwrap_or(0.0)
        .clamp(0.0, 1.0);
    Ok(profile)
}

fn profile_to_lua<'lua>(lua: &'lua Lua, profile: &TileProfile) -> LuaResult<LuaTable<'lua>> {
    let table = lua.create_table()?;
    let blocks = lua.create_table()?;
    for (channel, blocked) in &profile.blockers {
        blocks.set(channel.as_str(), *blocked)?;
    }
    let costs = lua.create_table()?;
    for (channel, cost) in &profile.costs {
        costs.set(channel.as_str(), *cost)?;
    }
    table.set("blocks", blocks)?;
    table.set("costs", costs)?;
    table.set("sunOcclusion", profile.sun_occlusion)?;
    Ok(table)
}

fn cell_to_lua<'lua>(
    lua: &'lua Lua,
    field: &TileField,
    coord: CellCoord,
) -> LuaResult<LuaTable<'lua>> {
    let table = lua.create_table()?;
    let blocks = lua.create_table()?;
    let costs = lua.create_table()?;
    for channel in [
        TileChannel::Move,
        TileChannel::Vision,
        TileChannel::Action,
        TileChannel::Light,
        TileChannel::Sun,
    ] {
        blocks.set(channel.as_str(), field.blocks(coord, channel))?;
        costs.set(channel.as_str(), field.cost(coord, channel))?;
    }
    table.set("blocks", blocks)?;
    table.set("costs", costs)?;
    table.set("sunOcclusion", field.sun_occlusion(coord))?;
    if let Some(profile) = field.cell(coord).and_then(|cell| cell.profile()) {
        table.set("profile", profile)?;
    }
    Ok(table)
}

fn cells_to_lua<'lua>(lua: &'lua Lua, cells: Vec<CellCoord>) -> LuaResult<LuaTable<'lua>> {
    let table = lua.create_table()?;
    for (i, coord) in cells.into_iter().enumerate() {
        let row = lua.create_table()?;
        row.set("x", coord.x + 1)?;
        row.set("y", coord.y + 1)?;
        row.set("z", coord.z + 1)?;
        table.set(i + 1, row)?;
    }
    Ok(table)
}

fn light_to_lua<'lua>(lua: &'lua Lua, color: LightColor) -> LuaResult<LuaTable<'lua>> {
    let table = lua.create_table()?;
    table.set("r", color.r)?;
    table.set("g", color.g)?;
    table.set("b", color.b)?;
    table.set("luma", color.luma())?;
    Ok(table)
}

fn export_bool_layer<'lua>(lua: &'lua Lua, values: Vec<bool>) -> LuaResult<LuaTable<'lua>> {
    let table = lua.create_table()?;
    for (i, value) in values.into_iter().enumerate() {
        table.set(i + 1, value)?;
    }
    Ok(table)
}

fn export_number_layer<'lua>(lua: &'lua Lua, values: Vec<f32>) -> LuaResult<LuaTable<'lua>> {
    let table = lua.create_table()?;
    for (i, value) in values.into_iter().enumerate() {
        table.set(i + 1, value)?;
    }
    Ok(table)
}

fn export_profile_layer<'lua>(
    lua: &'lua Lua,
    values: Vec<Option<String>>,
) -> LuaResult<LuaTable<'lua>> {
    let table = lua.create_table()?;
    for (i, value) in values.into_iter().enumerate() {
        table.set(i + 1, value)?;
    }
    Ok(table)
}

impl LuaUserData for LuaTileField {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- getSize --
        /// Returns field width, height, and level count.
        /// @return | integer | Field width in cells.
        /// @return | integer | Field height in cells.
        /// @return | integer | Level count.
        methods.add_method("getSize", |_, this, ()| Ok(this.inner.borrow().size()));

        // -- getTopology --
        /// Returns the field topology name.
        /// @return | string | `square`, `iso_square`, or `hex`.
        methods.add_method("getTopology", |_, this, ()| {
            Ok(this.inner.borrow().topology().as_str().to_string())
        });

        // -- inBounds --
        /// Returns whether one-based coordinates are inside the field.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @param | z | integer? | One-based level, default 1.
        /// @return | boolean | True when coordinates are in bounds.
        methods.add_method("inBounds", |_, this, (x, y, z): (u32, u32, Option<u32>)| {
            Ok(coord_from_values(x, y, z)
                .map(|coord| this.inner.borrow().in_bounds(coord))
                .unwrap_or(false))
        });

        // -- clear --
        /// Clears all cell gameplay state and computed light values.
        methods.add_method("clear", |_, this, ()| {
            this.inner.borrow_mut().clear();
            Ok(())
        });

        // -- clearCell --
        /// Clears one cell.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @param | z | integer? | One-based level, default 1.
        methods.add_method(
            "clearCell",
            |_, this, (x, y, z): (u32, u32, Option<u32>)| {
                let coord = coord_from_values(x, y, z)?;
                this.inner
                    .borrow_mut()
                    .clear_cell(coord)
                    .map_err(|e| lua_err("clearCell", e))
            },
        );

        // -- getCell --
        /// Returns a table with blockers, costs, sun occlusion, and optional profile name.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @param | z | integer? | One-based level, default 1.
        /// @return | table | Cell state table.
        methods.add_method(
            "getCell",
            |lua, this, (x, y, z): (u32, u32, Option<u32>)| {
                let coord = coord_from_values(x, y, z)?;
                let field = this.inner.borrow();
                if !field.in_bounds(coord) {
                    return Err(lua_err("getCell", "coordinate is out of bounds"));
                }
                cell_to_lua(lua, &field, coord)
            },
        );

        // -- setCell --
        /// Sets cell state from a table with optional `blocks`, `costs`, `sunOcclusion`, and `profile`.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @param | z | integer? | One-based level, default 1.
        /// @param | cell | table | Cell data.
        methods.add_method(
            "setCell",
            |_, this, (x, y, z, cell_tbl): (u32, u32, Option<u32>, LuaTable)| {
                let coord = coord_from_values(x, y, z)?;
                let mut field = this.inner.borrow_mut();
                if !field.in_bounds(coord) {
                    return Err(lua_err("setCell", "coordinate is out of bounds"));
                }
                if let Ok(profile) = cell_tbl.get::<_, String>("profile") {
                    field
                        .apply_profile(coord, &profile)
                        .map_err(|e| lua_err("setCell", e))?;
                }
                if let Ok(blocks) = cell_tbl.get::<_, LuaTable>("blocks") {
                    for pair in blocks.pairs::<String, bool>() {
                        let (name, value) = pair.map_err(|e| lua_err("setCell", e))?;
                        let channel = channel_from_str(name, "setCell")?;
                        field
                            .set_block(coord, channel, value)
                            .map_err(|e| lua_err("setCell", e))?;
                    }
                }
                if let Ok(costs) = cell_tbl.get::<_, LuaTable>("costs") {
                    for pair in costs.pairs::<String, f32>() {
                        let (name, value) = pair.map_err(|e| lua_err("setCell", e))?;
                        let channel = channel_from_str(name, "setCell")?;
                        field
                            .set_cost(coord, channel, value)
                            .map_err(|e| lua_err("setCell", e))?;
                    }
                }
                if let Some(value) = cell_tbl
                    .get::<_, Option<f32>>("sunOcclusion")
                    .map_err(|e| lua_err("setCell", e))?
                {
                    field
                        .set_sun_occlusion(coord, value)
                        .map_err(|e| lua_err("setCell", e))?;
                }
                Ok(())
            },
        );

        // -- setBlock --
        /// Sets whether a cell blocks a channel.
        methods.add_method(
            "setBlock",
            |_, this, (x, y, z, channel, blocked): (u32, u32, Option<u32>, String, bool)| {
                let coord = coord_from_values(x, y, z)?;
                let channel = channel_from_str(channel, "setBlock")?;
                this.inner
                    .borrow_mut()
                    .set_block(coord, channel, blocked)
                    .map_err(|e| lua_err("setBlock", e))
            },
        );

        // -- blocks --
        /// Returns whether a cell blocks a channel.
        methods.add_method(
            "blocks",
            |_, this, (x, y, z, channel): (u32, u32, Option<u32>, String)| {
                let coord = coord_from_values(x, y, z)?;
                let channel = channel_from_str(channel, "blocks")?;
                Ok(this.inner.borrow().blocks(coord, channel))
            },
        );

        // -- setCost --
        /// Sets the cost for one cell/channel.
        methods.add_method(
            "setCost",
            |_, this, (x, y, z, channel, cost): (u32, u32, Option<u32>, String, f32)| {
                let coord = coord_from_values(x, y, z)?;
                let channel = channel_from_str(channel, "setCost")?;
                this.inner
                    .borrow_mut()
                    .set_cost(coord, channel, cost)
                    .map_err(|e| lua_err("setCost", e))
            },
        );

        // -- getCost --
        /// Returns the cost for one cell/channel.
        methods.add_method(
            "getCost",
            |_, this, (x, y, z, channel): (u32, u32, Option<u32>, String)| {
                let coord = coord_from_values(x, y, z)?;
                let channel = channel_from_str(channel, "getCost")?;
                Ok(this.inner.borrow().cost(coord, channel))
            },
        );

        // -- setSunOcclusion --
        /// Sets top-light occlusion in the inclusive range 0..1.
        methods.add_method(
            "setSunOcclusion",
            |_, this, (x, y, z, value): (u32, u32, Option<u32>, f32)| {
                let coord = coord_from_values(x, y, z)?;
                this.inner
                    .borrow_mut()
                    .set_sun_occlusion(coord, value)
                    .map_err(|e| lua_err("setSunOcclusion", e))
            },
        );

        // -- getSunOcclusion --
        /// Returns top-light occlusion in the inclusive range 0..1.
        methods.add_method(
            "getSunOcclusion",
            |_, this, (x, y, z): (u32, u32, Option<u32>)| {
                let coord = coord_from_values(x, y, z)?;
                Ok(this.inner.borrow().sun_occlusion(coord))
            },
        );

        // -- setProfile --
        /// Registers or replaces a named object profile.
        methods.add_method(
            "setProfile",
            |_, this, (name, profile_tbl): (String, LuaTable)| {
                let profile = profile_from_table(profile_tbl, "setProfile")?;
                this.inner
                    .borrow_mut()
                    .set_profile(name, profile)
                    .map_err(|e| lua_err("setProfile", e))
            },
        );

        // -- applyProfile --
        /// Applies a named profile to one cell.
        methods.add_method(
            "applyProfile",
            |_, this, (x, y, z, name): (u32, u32, Option<u32>, String)| {
                let coord = coord_from_values(x, y, z)?;
                this.inner
                    .borrow_mut()
                    .apply_profile(coord, &name)
                    .map_err(|e| lua_err("applyProfile", e))
            },
        );

        // -- getProfile --
        /// Returns a named object profile table, or nil when absent.
        /// @param | name | string | Profile name to read.
        /// @return | table|nil | Profile table with blockers, costs, and sunOcclusion, or nil.
        methods.add_method("getProfile", |lua, this, name: String| {
            let field = this.inner.borrow();
            match field.profile(&name) {
                Some(profile) => Ok(Some(profile_to_lua(lua, profile)?)),
                None => Ok(None),
            }
        });

        // -- removeProfile --
        /// Removes a named object profile.
        /// @param | name | string | Profile name to remove.
        methods.add_method("removeProfile", |_, this, name: String| {
            this.inner.borrow_mut().remove_profile(&name);
            Ok(())
        });

        // -- line --
        /// Returns topology-aware one-based cells between `from` and `to` tables.
        /// @param | opts | table | `{from={x,y,z?}, to={x,y,z?}, includeEndpoints?}`.
        methods.add_method("line", |lua, this, opts: LuaTable| {
            let from = coord_from_table(opts.get("from")?, "line")?;
            let to = coord_from_table(opts.get("to")?, "line")?;
            let include = opts
                .get::<_, Option<bool>>("includeEndpoints")?
                .unwrap_or(true);
            let cells = this
                .inner
                .borrow()
                .line(from, to, include)
                .map_err(|e| lua_err("line", e))?;
            cells_to_lua(lua, cells)
        });

        // -- clearLine --
        /// Returns true when the line between two cell tables has no blocker for a channel.
        methods.add_method(
            "clearLine",
            |_, this, (from_tbl, to_tbl, channel, _opts): (LuaTable, LuaTable, String, Option<LuaTable>)| {
                let from = coord_from_table(from_tbl, "clearLine")?;
                let to = coord_from_table(to_tbl, "clearLine")?;
                let channel = channel_from_str(channel, "clearLine")?;
                this.inner
                    .borrow()
                    .clear_line(from, to, channel)
                    .map_err(|e| lua_err("clearLine", e))
            },
        );

        // -- firstBlocker --
        /// Returns the first one-based blocking cell table between two cells, or nil.
        methods.add_method(
            "firstBlocker",
            |lua, this, (from_tbl, to_tbl, channel, _opts): (LuaTable, LuaTable, String, Option<LuaTable>)| {
                let from = coord_from_table(from_tbl, "firstBlocker")?;
                let to = coord_from_table(to_tbl, "firstBlocker")?;
                let channel = channel_from_str(channel, "firstBlocker")?;
                match this
                    .inner
                    .borrow()
                    .first_blocker(from, to, channel)
                    .map_err(|e| lua_err("firstBlocker", e))?
                {
                    Some(coord) => {
                        let table = lua.create_table()?;
                        table.set("x", coord.x + 1)?;
                        table.set("y", coord.y + 1)?;
                        table.set("z", coord.z + 1)?;
                        Ok(Some(table))
                    }
                    None => Ok(None),
                }
            },
        );

        // -- addPointLight --
        /// Adds a point light and returns its stable id.
        /// @param | opts | table | `{x, y, z?, radius, intensity?, color?}` light definition.
        methods.add_method("addPointLight", |_, this, opts: LuaTable| {
            let coord = coord_from_table(opts.clone(), "addPointLight")?;
            let radius: f32 = opts
                .get("radius")
                .map_err(|e| lua_err("addPointLight", e))?;
            let intensity: f32 = opts
                .get::<_, Option<f32>>("intensity")
                .map_err(|e| lua_err("addPointLight", e))?
                .unwrap_or(1.0);
            let color = color_from_table(
                opts.get::<_, Option<LuaTable>>("color")
                    .map_err(|e| lua_err("addPointLight", e))?,
                LightColor::WHITE,
                "addPointLight",
            )?;
            this.inner
                .borrow_mut()
                .add_point_light(coord.x, coord.y, coord.z, radius, intensity, color)
                .map_err(|e| lua_err("addPointLight", e))
        });

        // -- updatePointLight --
        /// Updates an existing point light by id.
        methods.add_method(
            "updatePointLight",
            |_, this, (id, opts): (u32, LuaTable)| {
                let x = opts
                    .get::<_, Option<u32>>("x")
                    .map_err(|e| lua_err("updatePointLight", e))?
                    .map(|v| one_based(v, "x"))
                    .transpose()?;
                let y = opts
                    .get::<_, Option<u32>>("y")
                    .map_err(|e| lua_err("updatePointLight", e))?
                    .map(|v| one_based(v, "y"))
                    .transpose()?;
                let z = opts
                    .get::<_, Option<u32>>("z")
                    .map_err(|e| lua_err("updatePointLight", e))?
                    .map(|v| one_based(v, "z"))
                    .transpose()?;
                let radius = opts
                    .get::<_, Option<f32>>("radius")
                    .map_err(|e| lua_err("updatePointLight", e))?;
                let intensity = opts
                    .get::<_, Option<f32>>("intensity")
                    .map_err(|e| lua_err("updatePointLight", e))?;
                let color = match opts
                    .get::<_, Option<LuaTable>>("color")
                    .map_err(|e| lua_err("updatePointLight", e))?
                {
                    Some(table) => Some(color_from_table(
                        Some(table),
                        LightColor::WHITE,
                        "updatePointLight",
                    )?),
                    None => None,
                };
                this.inner
                    .borrow_mut()
                    .update_point_light(
                        id,
                        PointLightUpdate {
                            x,
                            y,
                            z,
                            radius,
                            intensity,
                            color,
                        },
                    )
                    .map_err(|e| lua_err("updatePointLight", e))
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
        /// Removes all point lights.
        methods.add_method("clearPointLights", |_, this, ()| {
            this.inner.borrow_mut().clear_point_lights();
            Ok(())
        });

        // -- setGlobalLight --
        /// Sets top-down global light.
        /// @param | opts | table | `{intensity?, color?}` global top-light settings.
        methods.add_method("setGlobalLight", |_, this, opts: LuaTable| {
            let intensity = opts
                .get::<_, Option<f32>>("intensity")
                .map_err(|e| lua_err("setGlobalLight", e))?
                .unwrap_or(0.0);
            let color = color_from_table(
                opts.get::<_, Option<LuaTable>>("color")
                    .map_err(|e| lua_err("setGlobalLight", e))?,
                LightColor::WHITE,
                "setGlobalLight",
            )?;
            this.inner
                .borrow_mut()
                .set_global_light(GlobalLight { intensity, color });
            Ok(())
        });

        // -- computeLight --
        /// Computes tile light from ambient, point lights, and global top light.
        /// @param | opts | table? | Optional includePointLights, includeGlobalLight, and ambient settings.
        methods.add_method("computeLight", |_, this, opts: Option<LuaTable>| {
            let (include_point, include_global, ambient) = if let Some(opts) = opts {
                let include_point = opts
                    .get::<_, Option<bool>>("includePointLights")
                    .map_err(|e| lua_err("computeLight", e))?
                    .unwrap_or(true);
                let include_global = opts
                    .get::<_, Option<bool>>("includeGlobalLight")
                    .map_err(|e| lua_err("computeLight", e))?
                    .unwrap_or(true);
                let ambient = color_from_table(
                    opts.get::<_, Option<LuaTable>>("ambient")
                        .map_err(|e| lua_err("computeLight", e))?,
                    LightColor::BLACK,
                    "computeLight",
                )?;
                (include_point, include_global, ambient)
            } else {
                (true, true, LightColor::BLACK)
            };
            this.inner
                .borrow_mut()
                .compute_light(include_point, include_global, ambient);
            Ok(())
        });

        // -- getLight --
        /// Returns r, g, b, and luma for one cell.
        /// @param | x | integer | One-based cell x coordinate.
        /// @param | y | integer | One-based cell y coordinate.
        /// @param | z | integer? | One-based level, default 1.
        /// @return | number | Red component in 0..1.
        /// @return | number | Green component in 0..1.
        /// @return | number | Blue component in 0..1.
        /// @return | number | Luma value in 0..1.
        methods.add_method("getLight", |_, this, (x, y, z): (u32, u32, Option<u32>)| {
            let coord = coord_from_values(x, y, z)?;
            let color = this.inner.borrow().light_at(coord);
            Ok((color.r, color.g, color.b, color.luma()))
        });

        // -- exportLightLayer --
        /// Exports one level of computed light as row-major `{r,g,b,luma}` tables.
        /// @param | z | integer? | One-based level, default 1.
        /// @return | table | Row-major array of light tables.
        methods.add_method("exportLightLayer", |lua, this, z: Option<u32>| {
            let z = one_based(z.unwrap_or(1), "z")?;
            let field = this.inner.borrow();
            let (w, h, _) = field.size();
            let out = lua.create_table()?;
            let mut i = 1;
            for y in 0..h {
                for x in 0..w {
                    out.set(i, light_to_lua(lua, field.light_at(CellCoord { x, y, z }))?)?;
                    i += 1;
                }
            }
            Ok(out)
        });

        // -- exportLightVolume --
        /// Exports all computed light levels as nested row-major tables.
        /// @return | table | Array of per-level row-major light layers.
        methods.add_method("exportLightVolume", |lua, this, ()| {
            let field = this.inner.borrow();
            let (w, h, levels) = field.size();
            let volume = lua.create_table()?;
            for z in 0..levels {
                let layer = lua.create_table()?;
                let mut i = 1;
                for y in 0..h {
                    for x in 0..w {
                        layer.set(i, light_to_lua(lua, field.light_at(CellCoord { x, y, z }))?)?;
                        i += 1;
                    }
                }
                volume.set(z + 1, layer)?;
            }
            Ok(volume)
        });

        // -- exportBlockLayer --
        /// Exports one blocker channel and level as a row-major boolean array.
        methods.add_method(
            "exportBlockLayer",
            |lua, this, (channel, z): (String, Option<u32>)| {
                let channel = channel_from_str(channel, "exportBlockLayer")?;
                let z = one_based(z.unwrap_or(1), "z")?;
                let values = this.inner.borrow().export_block_layer(channel, z);
                export_bool_layer(lua, values)
            },
        );

        // -- exportCostLayer --
        /// Exports one cost channel and level as a row-major number array.
        methods.add_method(
            "exportCostLayer",
            |lua, this, (channel, z): (String, Option<u32>)| {
                let channel = channel_from_str(channel, "exportCostLayer")?;
                let z = one_based(z.unwrap_or(1), "z")?;
                let values = this.inner.borrow().export_cost_layer(channel, z);
                export_number_layer(lua, values)
            },
        );

        // -- exportProfileLayer --
        /// Exports one level of profile names as a row-major array.
        /// @param | z | integer? | One-based level, default 1.
        methods.add_method("exportProfileLayer", |lua, this, z: Option<u32>| {
            let z = one_based(z.unwrap_or(1), "z")?;
            let values = this.inner.borrow().export_profile_layer(z);
            export_profile_layer(lua, values)
        });

        // -- type --
        /// Returns the Lua-visible type name for this tilefield handle.
        /// @return | string | The string `LTileField`.
        methods.add_method("type", |_, _, ()| Ok("LTileField"));

        // -- typeOf --
        /// Returns whether this handle matches a supported type name.
        /// @param | name | string | Type name to compare.
        /// @return | boolean | True for `LTileField` or `LObject`.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LTileField" || name == "LObject")
        });
    }
}

/// Registers `lurek.tilefield`.
pub fn register(lua: &Lua, lurek: &LuaTable, _state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let tbl = lua.create_table()?;

    // -- new --
    /// Creates a multi-level tilefield.
    /// @param | opts | table | `{width, height, levels?, topology?}`.
    /// @return | LTileField | New tilefield handle.
    tbl.set(
        "new",
        lua.create_function(|_, opts: LuaTable| {
            let width: u32 = opts.get("width").map_err(|e| lua_err("new", e))?;
            let height: u32 = opts.get("height").map_err(|e| lua_err("new", e))?;
            let levels: u32 = opts
                .get::<_, Option<u32>>("levels")
                .map_err(|e| lua_err("new", e))?
                .unwrap_or(1);
            let topology_name = opts
                .get::<_, Option<String>>("topology")
                .map_err(|e| lua_err("new", e))?
                .unwrap_or_else(|| "square".to_string());
            let topology = TileTopology::parse(&topology_name).map_err(|e| lua_err("new", e))?;
            let field =
                TileField::new(width, height, levels, topology).map_err(|e| lua_err("new", e))?;
            Ok(LuaTileField {
                inner: Rc::new(RefCell::new(field)),
            })
        })?,
    )?;

    // -- fromTileMap --
    /// Copies a tilemap layer into a tilefield using solid and empty profiles.
    /// @param | tilemap | LTileMap | Source tilemap.
    /// @param | opts | table? | `{level?, topology?, solidProfile?, emptyProfile?, solidGids?}`.
    /// @return | LTileField | New tilefield copied from the tilemap layer.
    tbl.set(
        "fromTileMap",
        lua.create_function(|_, (tm_ud, opts): (LuaAnyUserData, Option<LuaTable>)| {
            let tilemap = tm_ud.borrow::<LuaTileMap>()?;
            let layer = one_based(
                match &opts {
                    Some(opts) => opts
                        .get::<_, Option<u32>>("layer")
                        .map_err(|e| lua_err("fromTileMap", e))?,
                    None => None,
                }
                .unwrap_or(1),
                "layer",
            )? as usize;
            let solid_profile = match &opts {
                Some(opts) => opts
                    .get::<_, Option<String>>("solidProfile")
                    .map_err(|e| lua_err("fromTileMap", e))?,
                None => None,
            }
            .unwrap_or_else(|| "wall".to_string());
            let empty_profile = match &opts {
                Some(opts) => opts
                    .get::<_, Option<String>>("emptyProfile")
                    .map_err(|e| lua_err("fromTileMap", e))?,
                None => None,
            }
            .unwrap_or_else(|| "empty".to_string());
            let topology_name = match &opts {
                Some(opts) => opts
                    .get::<_, Option<String>>("topology")
                    .map_err(|e| lua_err("fromTileMap", e))?,
                None => None,
            }
            .unwrap_or_else(|| "square".to_string());
            let topology =
                TileTopology::parse(&topology_name).map_err(|e| lua_err("fromTileMap", e))?;
            let mut solid_gids = HashSet::new();
            if let Some(opts) = &opts {
                if let Ok(tbl) = opts.get::<_, LuaTable>("solidGids") {
                    for gid in tbl.sequence_values::<u32>() {
                        solid_gids.insert(gid.map_err(|e| lua_err("fromTileMap", e))?);
                    }
                }
            }
            let tm = tilemap.inner.borrow();
            let (width, height) = tm
                .get_layer_dimensions(layer)
                .ok_or_else(|| lua_err("fromTileMap", "tilemap layer does not exist"))?;
            let mut field = TileField::new(width, height, 1, topology)
                .map_err(|e| lua_err("fromTileMap", e))?;
            for y in 0..height {
                for x in 0..width {
                    let gid = tm.get_tile(layer, x, y);
                    let solid = if solid_gids.is_empty() {
                        gid != 0 && tm.is_solid(layer, x, y)
                    } else {
                        solid_gids.contains(&gid)
                    };
                    let profile = if solid {
                        &solid_profile
                    } else {
                        &empty_profile
                    };
                    field
                        .apply_profile(CellCoord { x, y, z: 0 }, profile)
                        .map_err(|e| lua_err("fromTileMap", e))?;
                }
            }
            Ok(LuaTileField {
                inner: Rc::new(RefCell::new(field)),
            })
        })?,
    )?;

    lurek.set("tilefield", tbl)?;
    Ok(())
}
