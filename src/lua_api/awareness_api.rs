//! Registers the `lurek.awareness` Lua API for visibility userdata, queries, and visibility-side validation.

use super::tilefield_api::LuaTileField;
use super::SharedState;
use crate::awareness::{
    AwarenessCategoryConfig, AwarenessEvent, AwarenessFlags, AwarenessGrid, AwarenessMode,
    FogConfig, TileAwareness, TileFov,
};
use crate::tilefield::{CellCoord, TileChannel};
use mlua::prelude::*;
use std::cell::RefCell;
use std::rc::Rc;

fn awareness_lua_err(api: &str, err: impl std::fmt::Display) -> LuaError {
    LuaError::RuntimeError(format!("lurek.awareness.{api}: {err}"))
}

fn one_based_awareness(value: u32, label: &str) -> LuaResult<u32> {
    value
        .checked_sub(1)
        .ok_or_else(|| LuaError::RuntimeError(format!("lurek.awareness: {label} must be >= 1")))
}

fn awareness_coord_from_table(table: LuaTable, api: &str) -> LuaResult<CellCoord> {
    let x: u32 = table.get("x").map_err(|e| awareness_lua_err(api, e))?;
    let y: u32 = table.get("y").map_err(|e| awareness_lua_err(api, e))?;
    let z: Option<u32> = table.get("z").map_err(|e| awareness_lua_err(api, e))?;
    Ok(CellCoord {
        x: one_based_awareness(x, "x")?,
        y: one_based_awareness(y, "y")?,
        z: one_based_awareness(z.unwrap_or(1), "z")?,
    })
}

fn awareness_channel(opts: &LuaTable, default: &str, api: &str) -> LuaResult<TileChannel> {
    let name = opts
        .get::<_, Option<String>>("channel")
        .map_err(|e| awareness_lua_err(api, e))?
        .unwrap_or_else(|| default.to_string());
    TileChannel::parse(&name).map_err(|e| awareness_lua_err(api, e))
}

fn awareness_category(
    opts: &LuaTable,
    default: &str,
    legacy: &str,
    api: &str,
) -> LuaResult<String> {
    Ok(opts
        .get::<_, Option<String>>("category")
        .map_err(|e| awareness_lua_err(api, e))?
        .or(opts.get::<_, Option<String>>(legacy).ok().flatten())
        .unwrap_or_else(|| default.to_string()))
}

fn awareness_mode_from_opts(opts: &LuaTable, api: &str) -> LuaResult<Option<AwarenessMode>> {
    let Some(mode) = opts
        .get::<_, Option<String>>("mode")
        .map_err(|e| awareness_lua_err(api, e))?
    else {
        return Ok(None);
    };
    match mode.as_str() {
        "omni" => Ok(Some(AwarenessMode::Omni)),
        "cone" => Ok(Some(AwarenessMode::Cone)),
        other => Err(awareness_lua_err(
            api,
            format!("unknown awareness mode '{other}'"),
        )),
    }
}

fn awareness_facing_from_opts(opts: &LuaTable, api: &str) -> LuaResult<Option<(i32, i32)>> {
    if let Some(facing) = opts
        .get::<_, Option<LuaTable>>("facing")
        .map_err(|e| awareness_lua_err(api, e))?
    {
        return Ok(Some((
            facing
                .get::<_, Option<i32>>("x")
                .map_err(|e| awareness_lua_err(api, e))?
                .unwrap_or(1),
            facing
                .get::<_, Option<i32>>("y")
                .map_err(|e| awareness_lua_err(api, e))?
                .unwrap_or(0),
        )));
    }
    let dx = opts
        .get::<_, Option<i32>>("dx")
        .map_err(|e| awareness_lua_err(api, e))?;
    let dy = opts
        .get::<_, Option<i32>>("dy")
        .map_err(|e| awareness_lua_err(api, e))?;
    Ok(match (dx, dy) {
        (Some(dx), Some(dy)) => Some((dx, dy)),
        (Some(dx), None) => Some((dx, 0)),
        (None, Some(dy)) => Some((1, dy)),
        (None, None) => None,
    })
}

fn awareness_cells_to_lua<'lua>(
    lua: &'lua Lua,
    cells: Vec<CellCoord>,
) -> LuaResult<LuaTable<'lua>> {
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

/// Lua-side wrapper for a visibility grid instance.
struct LuaAwarenessGrid {
    inner: RefCell<AwarenessGrid>,
}

/// Lua-side wrapper for per-player tile visibility/action masks.
struct LuaTileAwareness {
    field: Rc<RefCell<crate::tilefield::TileField>>,
    inner: RefCell<TileAwareness>,
}

impl LuaUserData for LuaTileAwareness {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- defineCategory --
        /// Defines or replaces one awareness category.
        /// @param | name | string | Category name to create or replace.
        /// @param | opts | table? | Optional category settings such as range, arc, facing, active, and blocker rules.
        methods.add_method(
            "defineCategory",
            |_, this, (name, opts): (String, Option<LuaTable>)| {
                let mut config = AwarenessCategoryConfig::new(&name);
                if let Some(opts) = opts {
                    config.active = opts
                        .get::<_, Option<bool>>("active")
                        .map_err(|e| awareness_lua_err("LTileAwareness.defineCategory", e))?
                        .unwrap_or(true);
                    config.range = opts
                        .get::<_, Option<u32>>("range")
                        .map_err(|e| awareness_lua_err("LTileAwareness.defineCategory", e))?
                        .unwrap_or(config.range);
                    if let Some(mode) =
                        awareness_mode_from_opts(&opts, "LTileAwareness.defineCategory")?
                    {
                        config.mode = mode;
                    }
                    config.arc_degrees = opts
                        .get::<_, Option<f32>>("arc")
                        .map_err(|e| awareness_lua_err("LTileAwareness.defineCategory", e))?
                        .or_else(|| opts.get::<_, Option<f32>>("arcDegrees").ok().flatten())
                        .unwrap_or(config.arc_degrees);
                    if let Some(facing) =
                        awareness_facing_from_opts(&opts, "LTileAwareness.defineCategory")?
                    {
                        config.facing = facing;
                    }
                    config.blocker_category = opts
                        .get::<_, Option<String>>("blockerCategory")
                        .map_err(|e| awareness_lua_err("LTileAwareness.defineCategory", e))?
                        .or_else(|| opts.get::<_, Option<String>>("blocker").ok().flatten())
                        .unwrap_or_else(|| config.blocker_category.clone());
                }
                this.inner
                    .borrow_mut()
                    .define_category(name, config)
                    .map_err(|e| awareness_lua_err("LTileAwareness.defineCategory", e))
            },
        );

        // -- getCategory --
        /// Returns awareness category metadata.
        /// @param | name | string | Category name to inspect.
        /// @return | table | Category metadata table, or nil when the category is unknown.
        methods.add_method("getCategory", |lua, this, name: String| {
            let inner = this.inner.borrow();
            let Some(config) = inner.category(&name) else {
                return Ok(None);
            };
            let table = lua.create_table()?;
            table.set("active", config.active)?;
            table.set("range", config.range)?;
            table.set(
                "mode",
                match config.mode {
                    AwarenessMode::Omni => "omni",
                    AwarenessMode::Cone => "cone",
                },
            )?;
            table.set("arc", config.arc_degrees)?;
            let facing = lua.create_table()?;
            facing.set("x", config.facing.0)?;
            facing.set("y", config.facing.1)?;
            table.set("facing", facing)?;
            table.set("blockerCategory", config.blocker_category.as_str())?;
            Ok(Some(table))
        });

        // -- getCategories --
        /// Returns known awareness category names.
        /// @return | table | Array of registered awareness category names.
        methods.add_method("getCategories", |lua, this, ()| {
            let names = this.inner.borrow().category_names();
            let table = lua.create_table()?;
            for (index, name) in names.into_iter().enumerate() {
                table.set(index + 1, name)?;
            }
            Ok(table)
        });

        // -- computeVisible --
        /// Computes one player's current visible mask from a tilefield origin.
        /// @param | player | string | Player identifier whose visibility mask should be computed.
        /// @param | opts | table | Options table with origin, range, category, mode, arc, facing, and blockerCategory.
        methods.add_method(
            "computeVisible",
            |_, this, (player, opts): (String, LuaTable)| {
                let origin = awareness_coord_from_table(
                    opts.get("origin")?,
                    "LTileAwareness.computeVisible",
                )?;
                let range = opts
                    .get::<_, Option<u32>>("range")
                    .map_err(|e| awareness_lua_err("LTileAwareness.computeVisible", e))?;
                let category = awareness_category(
                    &opts,
                    "vision",
                    "channel",
                    "LTileAwareness.computeVisible",
                )?;
                let mode = awareness_mode_from_opts(&opts, "LTileAwareness.computeVisible")?;
                let arc = opts
                    .get::<_, Option<f32>>("arc")
                    .map_err(|e| awareness_lua_err("LTileAwareness.computeVisible", e))?
                    .or_else(|| opts.get::<_, Option<f32>>("arcDegrees").ok().flatten());
                let facing = awareness_facing_from_opts(&opts, "LTileAwareness.computeVisible")?;
                let blocker = opts
                    .get::<_, Option<String>>("blockerCategory")
                    .map_err(|e| awareness_lua_err("LTileAwareness.computeVisible", e))?
                    .or_else(|| opts.get::<_, Option<String>>("blocker").ok().flatten());
                let field = this.field.borrow();
                this.inner
                    .borrow_mut()
                    .compute_category_visible(
                        &field, &player, &category, origin, range, mode, arc, facing, blocker,
                    )
                    .map_err(|e| awareness_lua_err("LTileAwareness.computeVisible", e))
            },
        );

        // -- computeAction --
        /// Computes one player's current action mask from a tilefield origin.
        /// @param | player | string | Player identifier whose action mask should be computed.
        /// @param | opts | table | Options table with origin, range, and optional action channel.
        methods.add_method(
            "computeAction",
            |_, this, (player, opts): (String, LuaTable)| {
                let origin = awareness_coord_from_table(
                    opts.get("origin")?,
                    "LTileAwareness.computeAction",
                )?;
                let range: u32 = opts
                    .get("range")
                    .map_err(|e| awareness_lua_err("LTileAwareness.computeAction", e))?;
                let channel = awareness_channel(&opts, "action", "LTileAwareness.computeAction")?;
                let field = this.field.borrow();
                this.inner
                    .borrow_mut()
                    .compute_action(&field, &player, origin, range, channel)
                    .map_err(|e| awareness_lua_err("LTileAwareness.computeAction", e))
            },
        );

        // -- isVisible --
        /// Returns whether a one-based cell is currently visible for a player.
        /// @param | player | string | Player identifier to query.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @param | z | integer? | One-based level, default 1.
        /// @return | boolean | True when the cell is currently visible.
        methods.add_method(
            "isVisible",
            |_, this, (player, x, y, z): (String, u32, u32, Option<u32>)| {
                let coord = CellCoord {
                    x: one_based_awareness(x, "x")?,
                    y: one_based_awareness(y, "y")?,
                    z: one_based_awareness(z.unwrap_or(1), "z")?,
                };
                Ok(this.inner.borrow().is_visible(&player, coord))
            },
        );

        // -- isAware --
        /// Returns whether a one-based cell is visible for a specific awareness category.
        /// @param | player | string | Player identifier to query.
        /// @param | category | string | Awareness category name.
        /// @param | x | integer | One-based cell column.
        /// @param | y | integer | One-based cell row.
        /// @param | z | integer? | Optional one-based level index, defaulting to 1.
        /// @return | boolean | True when the addressed cell is visible for the selected category.
        methods.add_method(
            "isAware",
            |_, this, (player, category, x, y, z): (String, String, u32, u32, Option<u32>)| {
                let coord = CellCoord {
                    x: one_based_awareness(x, "x")?,
                    y: one_based_awareness(y, "y")?,
                    z: one_based_awareness(z.unwrap_or(1), "z")?,
                };
                Ok(this.inner.borrow().is_aware(&player, &category, coord))
            },
        );

        // -- isExplored --
        /// Returns whether a one-based cell has been explored for a player.
        /// @param | player | string | Player identifier to query.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @param | z | integer? | One-based level, default 1.
        /// @return | boolean | True when the cell has been explored.
        methods.add_method(
            "isExplored",
            |_, this, (player, x, y, z): (String, u32, u32, Option<u32>)| {
                let coord = CellCoord {
                    x: one_based_awareness(x, "x")?,
                    y: one_based_awareness(y, "y")?,
                    z: one_based_awareness(z.unwrap_or(1), "z")?,
                };
                Ok(this.inner.borrow().is_explored(&player, coord))
            },
        );

        // -- canActOn --
        /// Returns whether a one-based cell is currently actionable for a player.
        /// @param | player | string | Player identifier to query.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @param | z | integer? | One-based level, default 1.
        /// @return | boolean | True when the cell is currently actionable.
        methods.add_method(
            "canActOn",
            |_, this, (player, x, y, z): (String, u32, u32, Option<u32>)| {
                let coord = CellCoord {
                    x: one_based_awareness(x, "x")?,
                    y: one_based_awareness(y, "y")?,
                    z: one_based_awareness(z.unwrap_or(1), "z")?,
                };
                Ok(this.inner.borrow().can_act_on(&player, coord))
            },
        );

        // -- visibleCells --
        /// Returns all currently visible cells for a player, optionally filtered to a level.
        /// @param | player | string | Player identifier to query.
        /// @param | categoryOrZ | string|integer? | Optional category name or one-based level filter when no separate `z` argument is supplied.
        /// @param | z | integer? | Optional one-based level filter used when `categoryOrZ` is a category string.
        /// @return | table | Array of one-based visible cell tables.
        methods.add_method(
            "visibleCells",
            |lua, this, (player, category_or_z, z): (String, Option<LuaValue>, Option<u32>)| {
                let mut category = None;
                let mut level = z.map(|v| one_based_awareness(v, "z")).transpose()?;
                if let Some(value) = category_or_z {
                    match value {
                        LuaValue::String(value) => category = Some(value.to_str()?.to_string()),
                        LuaValue::Integer(value) if value >= 1 && value <= u32::MAX as i64 => {
                            level = Some(one_based_awareness(value as u32, "z")?);
                        }
                        LuaValue::Number(value)
                            if value >= 1.0 && value.fract() == 0.0 && value <= u32::MAX as f64 =>
                        {
                            level = Some(one_based_awareness(value as u32, "z")?);
                        }
                        other => {
                            return Err(awareness_lua_err(
                                "LTileAwareness.visibleCells",
                                format!(
                                    "category/z must be string, integer, or nil, got {}",
                                    other.type_name()
                                ),
                            ));
                        }
                    }
                }
                let cells = match category {
                    Some(category) => this
                        .inner
                        .borrow()
                        .visible_cells_for_category(&player, &category, level),
                    None => this.inner.borrow().visible_cells(&player, level),
                };
                awareness_cells_to_lua(lua, cells)
            },
        );

        // -- actionCells --
        /// Returns all currently actionable cells for a player, optionally filtered to a level.
        /// @param | player | string | Player identifier to query.
        /// @param | z | integer? | Optional one-based level filter.
        /// @return | table | Array of one-based actionable cell tables.
        methods.add_method(
            "actionCells",
            |lua, this, (player, z): (String, Option<u32>)| {
                let level = z.map(|v| one_based_awareness(v, "z")).transpose()?;
                awareness_cells_to_lua(lua, this.inner.borrow().action_cells(&player, level))
            },
        );

        // -- clearPlayer --
        /// Clears current, explored, and action masks for one player.
        /// @param | player | string | Player identifier whose visibility state should be cleared.
        methods.add_method("clearPlayer", |_, this, player: String| {
            this.inner
                .borrow_mut()
                .clear_player(&player)
                .map_err(|e| awareness_lua_err("LTileAwareness.clearPlayer", e))
        });

        // -- clearAll --
        /// Clears current, explored, and action masks for all players.
        methods.add_method("clearAll", |_, this, ()| {
            this.inner.borrow_mut().clear_all();
            Ok(())
        });

        // -- share --
        /// Adds a directed awareness share edge for one category.
        /// @param | from | string | Source player identifier.
        /// @param | to | string | Target player identifier.
        /// @param | category | string | Awareness category to share.
        /// @param | opts | table? | Reserved optional settings table for future share options.
        methods.add_method(
            "share",
            |_, this, (from, to, category, _opts): (String, String, String, Option<LuaTable>)| {
                this.inner
                    .borrow_mut()
                    .share(from, to, category)
                    .map_err(|e| awareness_lua_err("LTileAwareness.share", e))
            },
        );

        // -- clearShares --
        /// Clears all directed awareness share edges.
        methods.add_method("clearShares", |_, this, ()| {
            this.inner.borrow_mut().clear_shares();
            Ok(())
        });

        // -- setTeam --
        /// Creates directed share edges between all listed players for selected categories.
        /// @param | players | table | Array of player identifiers that should share visibility.
        /// @param | categories | table? | Optional array of category names to share; omitted shares every category.
        methods.add_method(
            "setTeam",
            |_, this, (players, categories): (LuaTable, Option<LuaTable>)| {
                let mut player_ids = Vec::new();
                for value in players.sequence_values::<String>() {
                    player_ids.push(value?);
                }
                let mut category_ids = Vec::new();
                if let Some(categories) = categories {
                    for value in categories.sequence_values::<String>() {
                        category_ids.push(value?);
                    }
                } else {
                    category_ids.push("vision".to_string());
                }
                this.inner
                    .borrow_mut()
                    .set_team(&player_ids, &category_ids)
                    .map_err(|e| awareness_lua_err("LTileAwareness.setTeam", e))
            },
        );

        // -- type --
        /// Returns the Lua-visible type name for this tile visibility handle.
        /// @return | string | The string `LTileAwareness`.
        methods.add_method("type", |_, _, ()| Ok("LTileAwareness"));

        // -- typeOf --
        /// Returns whether this handle matches a supported type name.
        /// @param | name | string | Type name to compare against this handle.
        /// @return | boolean | True for `LTileAwareness` or `LObject`.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LTileAwareness" || name == "LObject")
        });
    }
}

impl LuaUserData for LuaAwarenessGrid {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- reveal --
        /// Reveals a region for a player (and their allies). Optional flags argument.
        /// @param | player_id | integer | Player index (0-based).
        /// @param | region_id | integer | Region index (0-based).
        /// @param | flags | integer? | Optional bitfield flags to set on the region.
        methods.add_method(
            "reveal",
            |_, this, (player_id, region_id, flags): (u32, u32, Option<u64>)| {
                let reveal_flags = AwarenessFlags(flags.unwrap_or(0));
                this.inner
                    .borrow_mut()
                    .reveal(player_id, region_id, reveal_flags);
                Ok(())
            },
        );

        // -- hide --
        /// Hides a region for a player (moves from Visible to Discovered).
        /// @param | player_id | integer | Player index (0-based).
        /// @param | region_id | integer | Region index (0-based).
        methods.add_method("hide", |_, this, (player_id, region_id): (u32, u32)| {
            this.inner.borrow_mut().hide(player_id, region_id);
            Ok(())
        });

        // -- getState --
        /// Gets the visibility state for a player at a region.
        /// @param | player_id | integer | Player index (0-based).
        /// @param | region_id | integer | Region index (0-based).
        /// @return | string | "hidden", "discovered", "visible", or a number for custom levels.
        methods.add_method("getState", |_, this, (player_id, region_id): (u32, u32)| {
            let state = this.inner.borrow().get_state(player_id, region_id);
            let result = match state {
                crate::awareness::AwarenessState::Hidden => "hidden".to_string(),
                crate::awareness::AwarenessState::Discovered => "discovered".to_string(),
                crate::awareness::AwarenessState::Visible => "visible".to_string(),
                crate::awareness::AwarenessState::Custom(v) => v.to_string(),
            };
            Ok(result)
        });

        // -- getFogIntensity --
        /// Gets the fog intensity for a region from a player's perspective.
        /// @param | player_id | integer | Player index (0-based).
        /// @param | region_id | integer | Region index (0-based).
        /// @return | number | Fog intensity from 0.0 (clear) to 1.0 (fully fogged).
        methods.add_method(
            "getFogIntensity",
            |_, this, (player_id, region_id): (u32, u32)| {
                Ok(this.inner.borrow().get_fog_intensity(player_id, region_id))
            },
        );

        // -- setCost --
        /// Sets the discovery cost for a region.
        /// @param | region_id | integer | Region index (0-based).
        /// @param | cost | number | Discovery cost value.
        methods.add_method("setCost", |_, this, (region_id, cost): (u32, f32)| {
            this.inner.borrow_mut().set_cost(region_id, cost);
            Ok(())
        });

        // -- getCost --
        /// Gets the discovery cost for a region.
        /// @param | region_id | integer | Region index (0-based).
        /// @return | number | Discovery cost value.
        methods.add_method("getCost", |_, this, region_id: u32| {
            Ok(this.inner.borrow().get_cost(region_id))
        });

        // -- setFlag --
        /// Sets a visibility flag bit on a region.
        /// @param | region_id | integer | Region index (0-based).
        /// @param | bit | integer | Flag bit index (0-63).
        /// @param | value | boolean | Whether to set or clear the bit.
        methods.add_method(
            "setFlag",
            |_, this, (region_id, bit, value): (u32, u8, bool)| {
                let mut grid = this.inner.borrow_mut();
                let mut flags = grid.get_flags(region_id);
                flags.set(bit, value);
                grid.set_flags(region_id, flags);
                Ok(())
            },
        );

        // -- hasFlag --
        /// Checks if a visibility flag bit is set on a region.
        /// @param | region_id | integer | Region index (0-based).
        /// @param | bit | integer | Flag bit index (0-63).
        /// @return | boolean | Whether the bit is set.
        methods.add_method("hasFlag", |_, this, (region_id, bit): (u32, u8)| {
            Ok(this.inner.borrow().get_flags(region_id).has(bit))
        });

        // -- setGroup --
        /// Sets an alliance group for a list of players (shared visibility).
        /// @param | players | table | Array of player IDs (0-based) to group together.
        /// @return | integer | The assigned group ID.
        methods.add_method("setGroup", |_, this, players: LuaTable| {
            let player_ids: Vec<u32> = players
                .sequence_values::<u32>()
                .filter_map(|r| r.ok())
                .collect();
            let gid = this.inner.borrow_mut().set_group(&player_ids);
            Ok(gid)
        });

        // -- sharesVisibility --
        /// Checks if two players share visibility (same alliance group or same player).
        /// @param | player_a | integer | First player index (0-based).
        /// @param | player_b | integer | Second player index (0-based).
        /// @return | boolean | Whether they share visibility.
        methods.add_method("sharesVisibility", |_, this, (a, b): (u32, u32)| {
            Ok(this.inner.borrow().shares_visibility(a, b))
        });

        // -- revealAll --
        /// Reveals all regions for a player (debug/cheat).
        /// @param | player_id | integer | Player index (0-based).
        methods.add_method("revealAll", |_, this, player_id: u32| {
            this.inner.borrow_mut().reveal_all(player_id);
            Ok(())
        });

        // -- reset --
        /// Resets all visibility to Hidden for a player.
        /// @param | player_id | integer | Player index (0-based).
        methods.add_method("reset", |_, this, player_id: u32| {
            this.inner.borrow_mut().reset(player_id);
            Ok(())
        });

        // -- drainEvents --
        /// Drains and returns all pending visibility events.
        /// @return | table | Array of event tables with `type`, `player_id`, and `region_id` fields.
        methods.add_method("drainEvents", |lua, this, ()| {
            let events = this.inner.borrow_mut().drain_events();
            let result = lua.create_table()?;
            for (i, event) in events.iter().enumerate() {
                let tbl = lua.create_table()?;
                match event {
                    AwarenessEvent::Revealed {
                        player_id,
                        region_id,
                    } => {
                        /// Event type string for this visibility event.
                        tbl.set("type", "revealed")?;
                        /// Player index affected by this visibility event.
                        tbl.set("player_id", *player_id)?;
                        /// Region index affected by this visibility event.
                        tbl.set("region_id", *region_id)?;
                    }
                    AwarenessEvent::Hidden {
                        player_id,
                        region_id,
                    } => {
                        /// Event type string for this hidden visibility event.
                        tbl.set("type", "hidden")?;
                        /// Player index affected by this hidden visibility event.
                        tbl.set("player_id", *player_id)?;
                        /// Region index hidden from this player.
                        tbl.set("region_id", *region_id)?;
                    }
                    AwarenessEvent::Forgotten {
                        player_id,
                        region_id,
                    } => {
                        /// Event type string for this forgotten visibility event.
                        tbl.set("type", "forgotten")?;
                        /// Player index affected by this forgotten visibility event.
                        tbl.set("player_id", *player_id)?;
                        /// Region index forgotten for this player.
                        tbl.set("region_id", *region_id)?;
                    }
                    AwarenessEvent::GroupChanged {
                        player_id,
                        group_id,
                    } => {
                        /// Event type string for this group-changed visibility event.
                        tbl.set("type", "group_changed")?;
                        /// Player index whose group membership changed.
                        tbl.set("player_id", *player_id)?;
                        /// New group id assigned to the player.
                        tbl.set("group_id", *group_id)?;
                    }
                }
                result.set(i + 1, tbl)?;
            }
            Ok(result)
        });

        // -- regionCount --
        /// Returns the total number of regions in the grid.
        /// @return | integer | Region count.
        methods.add_method("regionCount", |_, this, ()| {
            Ok(this.inner.borrow().region_count())
        });

        // -- playerCount --
        /// Returns the total number of players in the grid.
        /// @return | integer | Player count.
        methods.add_method("playerCount", |_, this, ()| {
            Ok(this.inner.borrow().player_count())
        });
    }
}

/// Registers the `lurek.awareness` module into the Lua `lurek` table.
pub fn register(lua: &Lua, lurek: &LuaTable, _state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let tbl = lua.create_table()?;

    // -- new --
    /// Create a new visibility grid for shadow-cast computation.
    /// @param | config | table | Configuration table with `regions` (integer) and `players` (integer) fields. Optional `fog` sub-table with `discovered` (number), `hidden` (number), `smooth` (boolean), `speed` (number).
    /// @return | LAwarenessGrid | New visibility grid handle.
    tbl.set(
        "new",
        lua.create_function(|_, config: LuaTable| {
            let regions: u32 = config.get("regions")?;
            let players: u32 = config.get("players")?;

            let mut grid = AwarenessGrid::new(regions, players);

            if let Ok(fog_tbl) = config.get::<_, LuaTable>("fog") {
                let discovered = fog_tbl.get::<_, f32>("discovered").unwrap_or(0.5);
                let hidden = fog_tbl.get::<_, f32>("hidden").unwrap_or(1.0);
                let smooth = fog_tbl.get::<_, bool>("smooth").unwrap_or(true);
                let speed = fog_tbl.get::<_, f32>("speed").unwrap_or(0.5);
                grid.set_fog_config(FogConfig {
                    discovered_intensity: discovered,
                    hidden_intensity: hidden,
                    smooth_transitions: smooth,
                    transition_speed: speed,
                });
            }

            Ok(LuaAwarenessGrid {
                inner: RefCell::new(grid),
            })
        })?,
    )?;

    // -- newFov --
    /// Creates a new tile-grid shadowcasting FOV for roguelike and stealth games.
    /// @param | opts | table | `{ range=integer, light_walls=boolean? }` (default light_walls=true).
    /// @return | LFov | New FOV handle ready for blocker assignment and compute calls.
    tbl.set(
        "newFov",
        lua.create_function(|_, opts: LuaTable| {
            let range: u32 = opts.get("range")?;
            let light_walls: bool = opts.get::<_, Option<bool>>("light_walls")?.unwrap_or(true);
            let width: u32 = opts.get::<_, Option<u32>>("width")?.unwrap_or(256);
            let height: u32 = opts.get::<_, Option<u32>>("height")?.unwrap_or(256);
            Ok(LuaTileFov {
                inner: RefCell::new(TileFov::new(width, height, range, light_walls)),
                blocker_key: RefCell::new(None),
            })
        })?,
    )?;

    // -- newTileAwareness --
    /// Creates per-player tile visibility/action masks backed by a tilefield.
    /// @param | field | LTileField | Source tilefield.
    /// @param | opts | table | `{players={...}, rememberExplored=true?}`.
    /// @return | LTileAwareness | New tile visibility handle.
    tbl.set(
        "newTileAwareness",
        lua.create_function(|_, (field_ud, opts): (LuaAnyUserData, LuaTable)| {
            let field_ud = field_ud.borrow::<LuaTileField>()?;
            let players_tbl: LuaTable = opts.get("players")?;
            let mut players = Vec::new();
            for player in players_tbl.sequence_values::<String>() {
                players.push(player?);
            }
            if players.is_empty() {
                return Err(awareness_lua_err(
                    "newTileAwareness",
                    "players must contain at least one id",
                ));
            }
            let remember = opts
                .get::<_, Option<bool>>("rememberExplored")?
                .unwrap_or(true);
            let (width, height, levels) = field_ud.inner.borrow().size();
            Ok(LuaTileAwareness {
                field: field_ud.inner.clone(),
                inner: RefCell::new(TileAwareness::new(width, height, levels, players, remember)),
            })
        })?,
    )?;

    // -- lineOfSight --
    /// Returns whether two tilefield cells have a clear sight line.
    /// @param | field | LTileField | Tilefield to query.
    /// @param | from | table | One-based `{x,y,z?}` start.
    /// @param | to | table | One-based `{x,y,z?}` target.
    /// @param | opts | table? | Optional `{category="sight"}` or legacy `{channel="vision"}`.
    /// @return | boolean | True when clear.
    tbl.set(
        "lineOfSight",
        lua.create_function(
            |_,
             (field_ud, from_tbl, to_tbl, opts): (
                LuaAnyUserData,
                LuaTable,
                LuaTable,
                Option<LuaTable>,
            )| {
                let field_ud = field_ud.borrow::<LuaTileField>()?;
                let from = awareness_coord_from_table(from_tbl, "lineOfSight")?;
                let to = awareness_coord_from_table(to_tbl, "lineOfSight")?;
                let field = field_ud.inner.borrow();
                match opts {
                    Some(opts) => {
                        let category =
                            awareness_category(&opts, "vision", "channel", "lineOfSight")?;
                        field
                            .clear_line_category(from, to, &category)
                            .map_err(|e| awareness_lua_err("lineOfSight", e))
                    }
                    None => field
                        .clear_line(from, to, TileChannel::Vision)
                        .map_err(|e| awareness_lua_err("lineOfSight", e)),
                }
            },
        )?,
    )?;

    // -- lineOfAction --
    /// Returns whether two tilefield cells have a clear action line.
    /// @param | field | LTileField | Tilefield to query.
    /// @param | from | table | One-based `{x,y,z?}` start.
    /// @param | to | table | One-based `{x,y,z?}` target.
    /// @param | opts | table? | Optional `{category="action"}` or legacy `{channel="action"}`.
    /// @return | boolean | True when clear.
    tbl.set(
        "lineOfAction",
        lua.create_function(
            |_,
             (field_ud, from_tbl, to_tbl, opts): (
                LuaAnyUserData,
                LuaTable,
                LuaTable,
                Option<LuaTable>,
            )| {
                let field_ud = field_ud.borrow::<LuaTileField>()?;
                let from = awareness_coord_from_table(from_tbl, "lineOfAction")?;
                let to = awareness_coord_from_table(to_tbl, "lineOfAction")?;
                let field = field_ud.inner.borrow();
                match opts {
                    Some(opts) => {
                        let category =
                            awareness_category(&opts, "action", "channel", "lineOfAction")?;
                        field
                            .clear_line_category(from, to, &category)
                            .map_err(|e| awareness_lua_err("lineOfAction", e))
                    }
                    None => field
                        .clear_line(from, to, TileChannel::Action)
                        .map_err(|e| awareness_lua_err("lineOfAction", e)),
                }
            },
        )?,
    )?;

    lurek.set("awareness", tbl)?;
    Ok(())
}

/// Lua-side wrapper for a tile-grid recursive-shadowcasting FOV.
pub struct LuaTileFov {
    /// Owned FOV state.
    inner: RefCell<TileFov>,
    /// Optional Lua blocker predicate stored in the registry.
    blocker_key: RefCell<Option<LuaRegistryKey>>,
}

/// Provides `newFov` methods: setBlocker, setRange, compute, isVisible, isExplored,
/// resetExplored, eachVisible, visibleCells, export, import.
impl LuaUserData for LuaTileFov {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- setBlocker --
        /// Sets the Lua predicate that determines which cells are opaque.
        /// @param | fn | function | `fn(x: integer, y: integer) -> boolean` (one-based).
        methods.add_method("setBlocker", |lua, this, f: LuaFunction| {
            if let Some(old) = this.blocker_key.borrow_mut().take() {
                lua.remove_registry_value(old)?;
            }
            *this.blocker_key.borrow_mut() = Some(lua.create_registry_value(f)?);
            Ok(())
        });

        // -- setRange --
        /// Changes the visibility radius for subsequent compute calls.
        /// @param | range | integer | Maximum sight radius in cells.
        methods.add_method("setRange", |_, this, range: u32| {
            this.inner.borrow_mut().set_range(range);
            Ok(())
        });

        // -- compute --
        /// Runs recursive shadowcasting from the observer position.
        /// Resets the current `visible` mask before computing.
        /// @param | ox | integer | Observer column (one-based).
        /// @param | oy | integer | Observer row (one-based).
        methods.add_method("compute", |lua, this, (ox, oy): (u32, u32)| {
            if ox == 0 || oy == 0 {
                return Err(LuaError::external("compute: coordinates must be >= 1"));
            }
            let oxz = ox - 1;
            let oyz = oy - 1;
            let blocker_key = this.blocker_key.borrow();
            if let Some(ref key) = *blocker_key {
                let f: LuaFunction = lua.registry_value(key)?;
                let w = this.inner.borrow().width();
                let h = this.inner.borrow().height();
                let size = (w * h) as usize;
                let mut blocked = vec![false; size];
                for y in 0..h {
                    for x in 0..w {
                        let result: bool = f.call((x + 1, y + 1))?;
                        blocked[(y * w + x) as usize] = result;
                    }
                }
                this.inner
                    .borrow_mut()
                    .compute(oxz, oyz, &|x, y| blocked[(y * w + x) as usize]);
            } else {
                this.inner.borrow_mut().compute(oxz, oyz, &|_, _| false);
            }
            Ok(())
        });

        // -- isVisible --
        /// Returns true if the cell is visible in the current frame.
        /// @param | x | integer | Column (one-based).
        /// @param | y | integer | Row (one-based).
        /// @return | boolean | True when visible.
        methods.add_method("isVisible", |_, this, (x, y): (u32, u32)| {
            if x == 0 || y == 0 {
                return Ok(false);
            }
            Ok(this.inner.borrow().is_visible(x - 1, y - 1))
        });

        // -- isExplored --
        /// Returns true if the cell has ever been visible.
        /// @param | x | integer | Column (one-based).
        /// @param | y | integer | Row (one-based).
        /// @return | boolean | True when explored.
        methods.add_method("isExplored", |_, this, (x, y): (u32, u32)| {
            if x == 0 || y == 0 {
                return Ok(false);
            }
            Ok(this.inner.borrow().is_explored(x - 1, y - 1))
        });

        // -- resetExplored --
        /// Clears the explored mask so all cells appear unexplored.
        methods.add_method("resetExplored", |_, this, ()| {
            this.inner.borrow_mut().reset_explored();
            Ok(())
        });

        // -- eachVisible --
        /// Calls `fn(x, y)` for every currently visible cell (one-based coordinates).
        /// @param | fn | function | Callback receiving column and row integers.
        methods.add_method("eachVisible", |_, this, f: LuaFunction| {
            let cells = this.inner.borrow().visible_cells();
            for (x, y) in cells {
                f.call::<_, ()>((x + 1, y + 1))?;
            }
            Ok(())
        });

        // -- visibleCells --
        /// Returns an array of `{x, y}` tables for all currently visible cells (one-based).
        /// @return | table | Array of cell position tables.
        methods.add_method("visibleCells", |lua, this, ()| {
            let cells = this.inner.borrow().visible_cells();
            let out = lua.create_table()?;
            for (i, (x, y)) in cells.into_iter().enumerate() {
                let pt = lua.create_table()?;
                /// The 'x' field value exposed to Lua scripts.
                pt.set("x", x + 1)?;
                /// The 'y' field value exposed to Lua scripts.
                pt.set("y", y + 1)?;
                out.set(i + 1, pt)?;
            }
            Ok(out)
        });

        // -- export --
        /// Serialises the visible and explored masks to a binary blob.
        /// @return | string | Binary blob.
        methods.add_method("export", |lua, this, ()| {
            lua.create_string(this.inner.borrow().save())
        });

        // -- import --
        /// Restores visible and explored masks from a blob produced by `export`.
        /// @param | blob | string | Binary blob.
        methods.add_method("import", |_, this, blob: LuaString| {
            this.inner
                .borrow_mut()
                .restore(blob.as_bytes())
                .map_err(LuaError::external)
        });

        // -- type --
        /// Returns the Lua-visible type name for this FOV handle.
        /// @return | string | The string `LFov`.
        methods.add_method("type", |_, _, ()| Ok("LFov"));

        // -- typeOf --
        /// Returns whether this FOV handle matches the given type name.
        /// @param | name | string | Type name to check.
        /// @return | boolean | True when the name matches.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LFov" || name == "LObject")
        });
    }
}
