//! `lurek.visibility` -- Lua bindings for universal fog-of-war, discovery, and line-of-sight.
//!
//! - Registers `lurek.visibility.*` functions and types via `register()`.
//! - `LuaVisibilityGrid`: userdata type exposed to Lua.
//! - Bridges 16 Lua-callable methods via `mlua`.

use super::SharedState;
use crate::visibility::{FogConfig, TileFov, VisibilityEvent, VisibilityFlags, VisibilityGrid};
use mlua::prelude::*;
use std::cell::RefCell;
use std::rc::Rc;

/// Lua-side wrapper for a visibility grid instance.
struct LuaVisibilityGrid {
    inner: RefCell<VisibilityGrid>,
}

impl LuaUserData for LuaVisibilityGrid {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- reveal --
        /// Reveals a region for a player (and their allies). Optional flags argument.
        /// @param | player_id | integer | Player index (0-based).
        /// @param | region_id | integer | Region index (0-based).
        /// @param | flags | integer? | Optional bitfield flags to set on the region.
        methods.add_method("reveal", |_, this, (player_id, region_id, flags): (u32, u32, Option<u64>)| {
            let reveal_flags = VisibilityFlags(flags.unwrap_or(0));
            this.inner.borrow_mut().reveal(player_id, region_id, reveal_flags);
            Ok(())
        });

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
                crate::visibility::VisibilityState::Hidden => "hidden".to_string(),
                crate::visibility::VisibilityState::Discovered => "discovered".to_string(),
                crate::visibility::VisibilityState::Visible => "visible".to_string(),
                crate::visibility::VisibilityState::Custom(v) => v.to_string(),
            };
            Ok(result)
        });

        // -- getFogIntensity --
        /// Gets the fog intensity for a region from a player's perspective.
        /// @param | player_id | integer | Player index (0-based).
        /// @param | region_id | integer | Region index (0-based).
        /// @return | number | Fog intensity from 0.0 (clear) to 1.0 (fully fogged).
        methods.add_method("getFogIntensity", |_, this, (player_id, region_id): (u32, u32)| {
            Ok(this.inner.borrow().get_fog_intensity(player_id, region_id))
        });

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
        methods.add_method("setFlag", |_, this, (region_id, bit, value): (u32, u8, bool)| {
            let mut grid = this.inner.borrow_mut();
            let mut flags = grid.get_flags(region_id);
            flags.set(bit, value);
            grid.set_flags(region_id, flags);
            Ok(())
        });

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
                    VisibilityEvent::Revealed { player_id, region_id } => {
                        tbl.set("type", "revealed")?;
                        tbl.set("player_id", *player_id)?;
                        tbl.set("region_id", *region_id)?;
                    }
                    VisibilityEvent::Hidden { player_id, region_id } => {
                        tbl.set("type", "hidden")?;
                        tbl.set("player_id", *player_id)?;
                        tbl.set("region_id", *region_id)?;
                    }
                    VisibilityEvent::Forgotten { player_id, region_id } => {
                        /// Event type string for this forgotten visibility event.
                        tbl.set("type", "forgotten")?;
                        /// Player index affected by this forgotten visibility event.
                        tbl.set("player_id", *player_id)?;
                        /// Region index hidden from this player.
                        tbl.set("region_id", *region_id)?;
                    }
                    VisibilityEvent::GroupChanged { player_id, group_id } => {
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

/// Registers the `lurek.visibility` module into the Lua `lurek` table.
pub fn register(lua: &Lua, lurek: &LuaTable, _state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let tbl = lua.create_table()?;

    // -- new --
    /// Create a new visibility grid for shadow-cast computation.
    /// @param | config | table | Configuration table with `regions` (integer) and `players` (integer) fields. Optional `fog` sub-table with `discovered` (number), `hidden` (number), `smooth` (boolean), `speed` (number).
    /// @return | LVisibilityGrid | New visibility grid handle.
    tbl.set(
        "new",
        lua.create_function(|_, config: LuaTable| {
            let regions: u32 = config.get("regions")?;
            let players: u32 = config.get("players")?;

            let mut grid = VisibilityGrid::new(regions, players);

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

            Ok(LuaVisibilityGrid {
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

    lurek.set("visibility", tbl)?;
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
                this.inner.borrow_mut().compute(oxz, oyz, &|x, y| blocked[(y * w + x) as usize]);
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
            this.inner.borrow_mut().restore(blob.as_bytes()).map_err(LuaError::external)
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
