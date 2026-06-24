//! Registers the `lurek.pathfind` Lua API for path queries, async pools, waypoint conversion, and grid validation.

use super::tilefield_api::LuaTileField;
use super::tilemap_api::LuaTileMap;
use super::SharedState;
use crate::lua_api::callback_registry::CallbackRegistry;
use crate::pathfind::ai_flow_field::FlowField as AiFlowField;
use crate::pathfind::goal_map::{GoalMap, GoalSource};
use crate::pathfind::hpa::{build_abstract, hpa_star, AbstractGraph};
use crate::pathfind::pathgrid::PathGrid;
use crate::pathfind::ContextSteering;
use crate::pathfind::{
    bidirectional_astar, AsyncPathEvent, AsyncPathRequest, DiagonalMode, FlowField, NavGrid,
    NavMesh, ORCAAgent, ORCASolver, PathEventStatus, PathThreadPool, SteeringManager,
    UnitPathfinder, Waypoint,
};
use crate::pathfind::{HexGrid, HexLayout, InfluenceMap, JpsGrid, RangeMap};
use crate::tilefield::{CellCoord, TileChannel};
use mlua::prelude::*;
use std::cell::RefCell;
use std::rc::Rc;
use std::sync::atomic::{AtomicU32, AtomicU64, Ordering};
use std::sync::{Mutex, OnceLock};

static PATHFIND_THREAD_COUNT: AtomicU32 = AtomicU32::new(1);
static NEXT_ASYNC_PATH_REQUEST_ID: AtomicU64 = AtomicU64::new(1);
static PATHFIND_ASYNC_POOL: OnceLock<Mutex<PathThreadPool>> = OnceLock::new();

fn async_pool() -> &'static Mutex<PathThreadPool> {
    PATHFIND_ASYNC_POOL.get_or_init(|| {
        Mutex::new(PathThreadPool::new(
            PATHFIND_THREAD_COUNT.load(Ordering::Relaxed).max(1) as usize,
        ))
    })
}

fn with_async_pool<T>(f: impl FnOnce(&mut PathThreadPool) -> T) -> T {
    let mut pool = async_pool().lock().unwrap_or_else(|e| e.into_inner());
    f(&mut pool)
}

fn one_based_to_zero_based(value: u32, label: &str) -> LuaResult<u32> {
    value.checked_sub(1).ok_or_else(|| {
        LuaError::RuntimeError(format!("{} must be >= 1 for one-based coordinates", label))
    })
}

fn one_based_to_zero_based_usize(value: usize, label: &str) -> LuaResult<usize> {
    value.checked_sub(1).ok_or_else(|| {
        LuaError::RuntimeError(format!("{} must be >= 1 for one-based coordinates", label))
    })
}

fn one_based_coords_u32(x: u32, y: u32, x_label: &str, y_label: &str) -> LuaResult<(u32, u32)> {
    Ok((
        one_based_to_zero_based(x, x_label)?,
        one_based_to_zero_based(y, y_label)?,
    ))
}

fn one_based_coords_usize(
    x: usize,
    y: usize,
    x_label: &str,
    y_label: &str,
) -> LuaResult<(usize, usize)> {
    Ok((
        one_based_to_zero_based_usize(x, x_label)?,
        one_based_to_zero_based_usize(y, y_label)?,
    ))
}

fn require_positive_u32(value: u32, label: &str) -> LuaResult<u32> {
    if value == 0 {
        Err(LuaError::RuntimeError(format!("{} must be > 0", label)))
    } else {
        Ok(value)
    }
}

fn require_positive_usize(value: usize, label: &str) -> LuaResult<usize> {
    if value == 0 {
        Err(LuaError::RuntimeError(format!("{} must be > 0", label)))
    } else {
        Ok(value)
    }
}

fn require_positive_f32(value: f32, label: &str) -> LuaResult<f32> {
    if value.is_finite() && value > 0.0 {
        Ok(value)
    } else {
        Err(LuaError::RuntimeError(format!(
            "{} must be a finite number greater than 0",
            label
        )))
    }
}

fn lua_require_finite_f32(field: &'static str, value: f32) -> LuaResult<f32> {
    if value.is_finite() {
        Ok(value)
    } else {
        Err(LuaError::RuntimeError(format!(
            "pathfind field '{field}' must be finite, got {value}"
        )))
    }
}

fn lua_require_non_negative_f64(field: &'static str, value: f64) -> LuaResult<f64> {
    if value.is_finite() && value >= 0.0 {
        Ok(value)
    } else {
        Err(LuaError::RuntimeError(format!(
            "pathfind field '{field}' must be >= 0, got {value}"
        )))
    }
}

fn lua_require_positive_f32(field: &'static str, value: f32) -> LuaResult<f32> {
    if value.is_finite() && value > 0.0 {
        Ok(value)
    } else {
        Err(LuaError::RuntimeError(format!(
            "pathfind field '{field}' must be > 0, got {value}"
        )))
    }
}

fn parse_tilefield_channel(
    opts: &LuaTable,
    key: &str,
    default: &str,
    api: &str,
) -> LuaResult<TileChannel> {
    let value = opts
        .get::<_, Option<String>>(key)?
        .unwrap_or_else(|| default.to_string());
    TileChannel::parse(&value).map_err(|err| LuaError::RuntimeError(format!("{api}: {err}")))
}

fn parse_tilefield_level(opts: &LuaTable, api: &str) -> LuaResult<u32> {
    let level = opts.get::<_, Option<u32>>("level")?.unwrap_or(1);
    one_based_to_zero_based(level, &format!("{api}.level"))
}

/// Converts zero-based Rust waypoints into one-based Lua point tables.
fn waypoints_to_lua<'a>(lua: &'a Lua, path: &[Waypoint]) -> LuaResult<LuaTable<'a>> {
    let tbl = lua.create_table()?;
    for (i, wp) in path.iter().enumerate() {
        let entry = lua.create_table()?;
        /// The 'x' field value exposed to Lua scripts.
        entry.set("x", wp.x + 1)?;
        /// The 'y' field value exposed to Lua scripts.
        entry.set("y", wp.y + 1)?;
        tbl.set(i + 1, entry)?;
    }
    Ok(tbl)
}
/// Converts one-based Lua point tables into zero-based Rust waypoints.
fn lua_to_waypoints(tbl: &LuaTable) -> LuaResult<Vec<Waypoint>> {
    let mut waypoints = Vec::new();
    for pair in tbl.clone().sequence_values::<LuaTable>() {
        let entry = pair?;
        let x: u32 = entry.get("x")?;
        let y: u32 = entry.get("y")?;
        waypoints.push(Waypoint {
            x: one_based_to_zero_based(x, "x")?,
            y: one_based_to_zero_based(y, "y")?,
        });
    }
    Ok(waypoints)
}

fn tuple_path_to_lua<'a>(lua: &'a Lua, path: &[(u32, u32)]) -> LuaResult<LuaTable<'a>> {
    let tbl = lua.create_table()?;
    for (i, (x, y)) in path.iter().enumerate() {
        let entry = lua.create_table()?;
        entry.set("x", *x + 1)?;
        entry.set("y", *y + 1)?;
        tbl.set(i + 1, entry)?;
    }
    Ok(tbl)
}

fn path_event_status_name(status: PathEventStatus) -> &'static str {
    match status {
        PathEventStatus::Partial => "partial",
        PathEventStatus::Complete => "complete",
        PathEventStatus::Failed => "failed",
        PathEventStatus::Cancelled => "cancelled",
        PathEventStatus::Superseded => "superseded",
    }
}

fn path_event_to_lua<'a>(lua: &'a Lua, event: AsyncPathEvent) -> LuaResult<LuaTable<'a>> {
    let tbl = lua.create_table()?;
    tbl.set("id", event.id)?;
    tbl.set("owner_id", event.owner_id)?;
    tbl.set("version", event.version)?;
    tbl.set("step", event.step)?;
    tbl.set("status", path_event_status_name(event.status))?;
    tbl.set("complete", event.complete)?;
    tbl.set("final", event.final_event)?;
    match event.path {
        Some(path) => tbl.set("path", tuple_path_to_lua(lua, &path)?)?,
        None => tbl.set("path", LuaValue::Nil)?,
    }
    Ok(tbl)
}
/// Lua-side wrapper for a navigation grid and optional abstract graph cache.
pub struct LuaNavGrid {
    /// Shared navigation grid data exposed by the lurek engine.
    inner: Rc<RefCell<NavGrid>>,
    /// Optional abstract graph built for hierarchical pathfinding.
    abstract_graph: Rc<RefCell<Option<AbstractGraph>>>,
}
/// Provides Lua methods for navigation grid dimensions, costs, blocking, serialization, dirty regions, and diagonal mode.
impl LuaUserData for LuaNavGrid {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- getWidth --
        /// Returns grid width from this object.
        /// @return | integer | Grid width.
        methods.add_method("getWidth", |_, this, ()| {
            Ok(this.inner.borrow().get_width())
        });
        // -- getHeight --
        /// Returns grid height from this object.
        /// @return | integer | Grid height.
        methods.add_method("getHeight", |_, this, ()| {
            Ok(this.inner.borrow().get_height())
        });
        // -- getDimensions --
        /// Returns grid width and height as two integers.
        /// @return | integer | Grid width.
        /// @return | integer | Grid height.
        methods.add_method("getDimensions", |_, this, ()| {
            Ok(this.inner.borrow().get_dimensions())
        });
        // -- setCost --
        /// Sets movement cost at a one-based grid cell.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @param | cost | integer | Movement cost (0â€“255).
        methods.add_method("setCost", |_, this, (x, y, cost): (u32, u32, u8)| {
            let (x, y) = one_based_coords_u32(x, y, "x", "y")?;
            this.inner.borrow_mut().set_cost(x, y, cost);
            Ok(())
        });
        // -- getCost --
        /// Returns movement cost at a one-based grid cell.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @return | integer | Movement cost.
        methods.add_method("getCost", |_, this, (x, y): (u32, u32)| {
            let (x, y) = one_based_coords_u32(x, y, "x", "y")?;
            Ok(this.inner.borrow().get_cost(x, y))
        });
        // -- setBlocked --
        /// Sets blocked state at a one-based grid cell.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @param | blocked | boolean | True to block the cell.
        methods.add_method(
            "setBlocked",
            |_, this, (x, y, blocked): (u32, u32, bool)| {
                let (x, y) = one_based_coords_u32(x, y, "x", "y")?;
                this.inner.borrow_mut().set_blocked(x, y, blocked);
                Ok(())
            },
        );
        // -- isBlocked --
        /// Returns whether a one-based grid cell is blocked.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @return | boolean | True when blocked.
        methods.add_method("isBlocked", |_, this, (x, y): (u32, u32)| {
            let (x, y) = one_based_coords_u32(x, y, "x", "y")?;
            Ok(this.inner.borrow().is_blocked(x, y))
        });
        // -- isWalkable --
        /// Returns whether a one-based grid cell is walkable for a unit size.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @param | unit_size | integer? | Unit footprint in cells (default 1).
        /// @return | boolean | True when walkable.
        methods.add_method(
            "isWalkable",
            |_, this, (x, y, unit_size): (u32, u32, Option<u32>)| {
                Ok(this.inner.borrow().is_walkable(
                    one_based_to_zero_based(x, "x")?,
                    one_based_to_zero_based(y, "y")?,
                    unit_size.unwrap_or(1),
                ))
            },
        );
        // -- fill --
        /// Fills the entire grid with a uniform movement cost.
        /// @param | cost | integer | Movement cost (0â€“255).
        methods.add_method("fill", |_, this, cost: u8| {
            this.inner.borrow_mut().fill(cost);
            Ok(())
        });
        // -- fillRect --
        /// Fills a one-based rectangular area with a movement cost.
        /// @param | x | integer | One-based column of the top-left corner.
        /// @param | y | integer | One-based row of the top-left corner.
        /// @param | w | integer | Rectangle width in cells.
        /// @param | h | integer | Rectangle height in cells.
        /// @param | cost | integer | Movement cost (0â€“255).
        methods.add_method(
            "fillRect",
            |_, this, (x, y, w, h, cost): (u32, u32, u32, u32, u8)| {
                let (x, y) = one_based_coords_u32(x, y, "x", "y")?;
                this.inner.borrow_mut().fill_rect(x, y, w, h, cost);
                Ok(())
            },
        );
        // -- loadFromString --
        /// Loads grid data from a serialized binary string.
        /// @param | data | string | Serialized grid bytes.
        methods.add_method("loadFromString", |_, this, data: LuaString| {
            this.inner
                .borrow_mut()
                .load_from_bytes(data.as_bytes())
                .map_err(LuaError::external)
        });
        // -- saveToString --
        /// Saves grid data to a serialized binary string.
        /// @return | string | Serialized grid bytes.
        methods.add_method("saveToString", |lua, this, ()| {
            lua.create_string(this.inner.borrow().save_to_bytes())
        });
        // -- setChunkSize --
        /// Sets hierarchical chunk size for abstract graph partitioning.
        /// @param | size | integer | Chunk side length in cells.
        methods.add_method("setChunkSize", |_, this, size: u32| {
            this.inner.borrow_mut().set_chunk_size(size);
            Ok(())
        });
        // -- getChunkSize --
        /// Returns the hierarchical chunk size in cells.
        /// @return | integer | Chunk size.
        methods.add_method("getChunkSize", |_, this, ()| {
            Ok(this.inner.borrow().get_chunk_size())
        });
        // -- rebuildAbstract --
        /// Rebuilds the cached abstract graph for this grid.
        methods.add_method("rebuildAbstract", |_, this, ()| {
            let grid = this.inner.borrow();
            let chunk_size = grid.get_chunk_size();
            let graph = build_abstract(&grid, chunk_size);
            *this.abstract_graph.borrow_mut() = Some(graph);
            Ok(())
        });
        // -- findHpaPath --
        /// Finds a hierarchical path using the cached abstract graph, rebuilding it on first use.
        /// @param | sx | integer | One-based start column.
        /// @param | sy | integer | One-based start row.
        /// @param | gx | integer | One-based goal column.
        /// @param | gy | integer | One-based goal row.
        /// @param | unit_size | integer? | Optional unit footprint in cells, default 1.
        /// @return | table | Array of `{x, y}` waypoint tables, or nil when no path exists.
        methods.add_method(
            "findHpaPath",
            |lua, this, (sx, sy, gx, gy, unit_size): (u32, u32, u32, u32, Option<u32>)| {
                let start = (
                    one_based_to_zero_based(sx, "sx")?,
                    one_based_to_zero_based(sy, "sy")?,
                );
                let goal = (
                    one_based_to_zero_based(gx, "gx")?,
                    one_based_to_zero_based(gy, "gy")?,
                );
                let unit_size = unit_size.unwrap_or(1).max(1);
                if this.abstract_graph.borrow().is_none() {
                    let grid = this.inner.borrow();
                    let graph = build_abstract(&grid, grid.get_chunk_size());
                    drop(grid);
                    *this.abstract_graph.borrow_mut() = Some(graph);
                }
                let grid = this.inner.borrow();
                let graph_ref = this.abstract_graph.borrow();
                let graph = graph_ref
                    .as_ref()
                    .ok_or_else(|| LuaError::runtime("abstract graph is unavailable"))?;
                match hpa_star(&grid, graph, start, goal, unit_size) {
                    Some(path) => {
                        let out = lua.create_table()?;
                        for (i, (x, y)) in path.iter().enumerate() {
                            let row = lua.create_table()?;
                            row.set("x", *x + 1)?;
                            row.set("y", *y + 1)?;
                            out.set(i + 1, row)?;
                        }
                        Ok(LuaValue::Table(out))
                    }
                    None => Ok(LuaValue::Nil),
                }
            },
        );
        // -- setDirty --
        /// Marks a one-based rectangular region dirty for incremental rebuild.
        /// @param | x | integer | One-based column of the top-left corner.
        /// @param | y | integer | One-based row of the top-left corner.
        /// @param | w | integer | Region width in cells.
        /// @param | h | integer | Region height in cells.
        methods.add_method("setDirty", |_, this, (x, y, w, h): (u32, u32, u32, u32)| {
            let (x, y) = one_based_coords_u32(x, y, "x", "y")?;
            this.inner.borrow_mut().set_dirty(x, y, w, h);
            Ok(())
        });
        // -- clearDirty --
        /// Clears all dirty region markers from the grid.
        methods.add_method("clearDirty", |_, this, ()| {
            this.inner.borrow_mut().clear_dirty();
            Ok(())
        });
        // -- setDiagonalMode --
        /// Sets diagonal movement mode for this object.
        /// @param | mode | string | Mode name: `none`, `always`, or `nocornercut`.
        methods.add_method("setDiagonalMode", |_, this, mode: String| {
            let dm = DiagonalMode::from_lua_str(&mode).ok_or_else(|| {
                LuaError::external(format!(
                    "invalid diagonal mode '{}' (expected 'none', 'always', or 'nocornercut')",
                    mode
                ))
            })?;
            this.inner.borrow_mut().set_diagonal_mode(dm);
            Ok(())
        });
        // -- getDiagonalMode --
        /// Returns the current diagonal movement mode name.
        /// @return | string | Mode name.
        methods.add_method("getDiagonalMode", |_, this, ()| {
            Ok(this
                .inner
                .borrow()
                .get_diagonal_mode()
                .to_lua_str()
                .to_string())
        });
        // -- type --
        /// Returns the Lua-visible type name for this navigation grid handle.
        /// @return | string | The string `LNavGrid`.
        methods.add_method("type", |_, _, ()| Ok("LNavGrid"));
        // -- typeOf --
        /// Returns whether this navigation grid handle matches a supported type name.
        /// @param | name | string | String value for `name`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LNavGrid" || name == "LObject")
        });
    }
}
/// Lua-side wrapper for a unit pathfinder over a navigation grid.
pub struct LuaUnitPathfinder {
    /// Shared pathfinder data for this object.
    inner: Rc<RefCell<UnitPathfinder>>,
}
/// Provides Lua methods for path queries, reachability, line of sight, and cache settings.
impl LuaUserData for LuaUnitPathfinder {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- findPath --
        /// Finds a path between one-based grid cells.
        /// @param | x1 | integer | One-based start column.
        /// @param | y1 | integer | One-based start row.
        /// @param | x2 | integer | One-based goal column.
        /// @param | y2 | integer | One-based goal row.
        /// @param | unit_size | integer? | Unit footprint in cells (default 1).
        /// @return | table | Array of `{x, y}` waypoint tables, or nil when no path exists.
        /// @field | x | number | X.
        /// @field | y | number | Y.
        methods.add_method(
            "findPath",
            |lua, this, (x1, y1, x2, y2, unit_size): (u32, u32, u32, u32, Option<u32>)| {
                let sx = one_based_to_zero_based(x1, "x1")?;
                let sy = one_based_to_zero_based(y1, "y1")?;
                let gx = one_based_to_zero_based(x2, "x2")?;
                let gy = one_based_to_zero_based(y2, "y2")?;
                let result =
                    this.inner
                        .borrow_mut()
                        .find_path(sx, sy, gx, gy, unit_size.unwrap_or(1));
                match result {
                    Some(path) => Ok(LuaValue::Table(waypoints_to_lua(lua, &path)?)),
                    None => Ok(LuaValue::Nil),
                }
            },
        );
        // -- findPathSmooth --
        /// Finds a smoothed path between one-based grid cells.
        /// @param | x1 | integer | One-based start column.
        /// @param | y1 | integer | One-based start row.
        /// @param | x2 | integer | One-based goal column.
        /// @param | y2 | integer | One-based goal row.
        /// @param | unit_size | integer? | Unit footprint in cells (default 1).
        /// @return | table | Array of `{x, y}` waypoint tables, or nil when no path exists.
        /// @field | x | number | X.
        /// @field | y | number | Y.
        methods.add_method(
            "findPathSmooth",
            |lua, this, (x1, y1, x2, y2, unit_size): (u32, u32, u32, u32, Option<u32>)| {
                let sx = one_based_to_zero_based(x1, "x1")?;
                let sy = one_based_to_zero_based(y1, "y1")?;
                let gx = one_based_to_zero_based(x2, "x2")?;
                let gy = one_based_to_zero_based(y2, "y2")?;
                let result = this.inner.borrow_mut().find_path_smooth(
                    sx,
                    sy,
                    gx,
                    gy,
                    unit_size.unwrap_or(1),
                );
                match result {
                    Some(path) => Ok(LuaValue::Table(waypoints_to_lua(lua, &path)?)),
                    None => Ok(LuaValue::Nil),
                }
            },
        );
        // -- findPathBidirectional --
        /// Finds a path using bidirectional A* and returns completion status.
        /// @param | x1 | integer | One-based column of the start cell.
        /// @param | y1 | integer | One-based row of the start cell.
        /// @param | x2 | integer | One-based column of the goal cell.
        /// @param | y2 | integer | One-based row of the goal cell.
        /// @param | unit_size | integer? | Width or height of the unit in grid cells for clearance checks (default 1).
        /// @param | max_nodes | integer? | Optional node-expansion budget; 0 uses the full search.
        /// @return | table | Array of waypoint tables, or nil when no path exists.
        /// @field | x | number | X.
        /// @field | y | number | Y.
        /// @return | boolean | True when the path is complete.
        methods.add_method(
            "findPathBidirectional",
            |lua,
             this,
             (x1, y1, x2, y2, unit_size, max_nodes): (
                u32,
                u32,
                u32,
                u32,
                Option<u32>,
                Option<u32>,
            )| {
                let sx = one_based_to_zero_based(x1, "x1")?;
                let sy = one_based_to_zero_based(y1, "y1")?;
                let gx = one_based_to_zero_based(x2, "x2")?;
                let gy = one_based_to_zero_based(y2, "y2")?;
                let pf = this.inner.borrow();
                let grid_borrowed = pf.nav_grid().borrow();
                let (path_opt, complete) = bidirectional_astar(
                    &grid_borrowed,
                    (sx, sy),
                    (gx, gy),
                    unit_size.unwrap_or(1),
                    max_nodes.unwrap_or(0),
                );
                match path_opt {
                    Some(cells) => {
                        let tbl = lua.create_table()?;
                        for (i, (cx, cy)) in cells.iter().enumerate() {
                            let entry = lua.create_table()?;
                            /// The 'x' field value exposed to Lua scripts.
                            entry.set("x", cx + 1)?;
                            /// The 'y' field value exposed to Lua scripts.
                            entry.set("y", cy + 1)?;
                            tbl.set(i + 1, entry)?;
                        }
                        Ok((LuaValue::Table(tbl), complete))
                    }
                    None => Ok((LuaValue::Nil, false)),
                }
            },
        );
        // -- getPathLength --
        /// Returns the total Euclidean length of a waypoint path.
        /// @param | path | table | Array of `{x, y}` waypoint tables.
        /// @return | number | Path length.
        methods.add_method("getPathLength", |_, _this, path: LuaTable| {
            let waypoints = lua_to_waypoints(&path)?;
            Ok(UnitPathfinder::get_path_length(&waypoints))
        });
        // -- getPathCost --
        /// Returns the total movement cost along a waypoint path.
        /// @param | path | table | Array of `{x, y}` waypoint tables.
        /// @return | number | Path cost.
        methods.add_method("getPathCost", |_, this, path: LuaTable| {
            let waypoints = lua_to_waypoints(&path)?;
            Ok(this.inner.borrow().get_path_cost(&waypoints))
        });
        // -- findPartialPath --
        /// Finds the best reachable path from a start to a goal within a maximum node budget. Useful for incremental pathfinding across frames.
        /// @param | x1 | integer | One-based column of the start cell.
        /// @param | y1 | integer | One-based row of the start cell.
        /// @param | x2 | integer | One-based column of the goal cell.
        /// @param | y2 | integer | One-based row of the goal cell.
        /// @param | max_nodes | integer | Maximum number of nodes to expand before stopping.
        /// @param | unit_size | integer? | Width/height of the unit in grid cells for clearance checks (default 1).
        /// @return | table | Array of `{x, y}` waypoint tables forming the found partial path.
        /// @field | x | number | X.
        /// @field | y | number | Y.
        /// @return | boolean | `true` if the returned path reaches the exact goal cell.
        methods.add_method("findPartialPath", |lua,
             this,
             (x1, y1, x2, y2, max_nodes, unit_size): (
                u32,
                u32,
                u32,
                u32,
                u32,
                Option<u32>,
            )| {
                let (sx, sy) = one_based_coords_u32(x1, y1, "x1", "y1")?;
                let (gx, gy) = one_based_coords_u32(x2, y2, "x2", "y2")?;
                let (path, complete) = this.inner.borrow().find_partial_path(
                    sx,
                    sy,
                    gx,
                    gy,
                    max_nodes,
                    unit_size.unwrap_or(1),
                );
                Ok((waypoints_to_lua(lua, &path)?, complete))
            },
        );
        // -- findNearestWalkable --
        /// Finds nearest walkable one-based grid cell within a radius.
        /// @param | x | integer | One-based column of the search origin.
        /// @param | y | integer | One-based row of the search origin.
        /// @param | max_radius | integer | Maximum search radius in cells.
        /// @param | unit_size | integer? | Unit footprint in cells (default 1).
        /// @return | integer | One-based column of the nearest walkable cell, or nil.
        /// @return | integer | One-based row of the nearest walkable cell, or nil.
        methods.add_method(
            "findNearestWalkable",
            |_, this, (x, y, max_radius, unit_size): (u32, u32, u32, Option<u32>)| {
                let (x, y) = one_based_coords_u32(x, y, "x", "y")?;
                match this.inner.borrow().find_nearest_walkable(
                    x,
                    y,
                    max_radius,
                    unit_size.unwrap_or(1),
                ) {
                    Some((rx, ry)) => Ok((
                        LuaValue::Integer((rx + 1) as i64),
                        LuaValue::Integer((ry + 1) as i64),
                    )),
                    None => Ok((LuaValue::Nil, LuaValue::Nil)),
                }
            },
        );
        // -- isReachable --
        /// Returns whether a target cell is reachable from a start cell.
        /// @param | x1 | integer | One-based start column.
        /// @param | y1 | integer | One-based start row.
        /// @param | x2 | integer | One-based target column.
        /// @param | y2 | integer | One-based target row.
        /// @param | unit_size | integer? | Unit footprint in cells (default 1).
        /// @return | boolean | True when reachable.
        methods.add_method(
            "isReachable",
            |_, this, (x1, y1, x2, y2, unit_size): (u32, u32, u32, u32, Option<u32>)| {
                let (sx, sy) = one_based_coords_u32(x1, y1, "x1", "y1")?;
                let (gx, gy) = one_based_coords_u32(x2, y2, "x2", "y2")?;
                Ok(this
                    .inner
                    .borrow()
                    .is_reachable(sx, sy, gx, gy, unit_size.unwrap_or(1)))
            },
        );
        // -- heuristicDistance --
        /// Returns heuristic distance between two one-based cells.
        /// @param | x1 | integer | One-based column of the first cell.
        /// @param | y1 | integer | One-based row of the first cell.
        /// @param | x2 | integer | One-based column of the second cell.
        /// @param | y2 | integer | One-based row of the second cell.
        /// @return | number | Heuristic distance.
        methods.add_method(
            "heuristicDistance",
            |_, _this, (x1, y1, x2, y2): (u32, u32, u32, u32)| {
                let (sx, sy) = one_based_coords_u32(x1, y1, "x1", "y1")?;
                let (gx, gy) = one_based_coords_u32(x2, y2, "x2", "y2")?;
                Ok(UnitPathfinder::heuristic_distance(sx, sy, gx, gy))
            },
        );
        // -- setCacheEnabled --
        /// Enables or disables the path cache on this object.
        /// @param | enabled | boolean | True to enable caching.
        methods.add_method("setCacheEnabled", |_, this, enabled: bool| {
            this.inner.borrow_mut().set_cache_enabled(enabled);
            Ok(())
        });
        // -- isCacheEnabled --
        /// Returns whether path cache is enabled.
        /// @return | boolean | True when enabled.
        methods.add_method("isCacheEnabled", |_, this, ()| {
            Ok(this.inner.borrow().is_cache_enabled())
        });
        // -- clearCache --
        /// Clears all cached paths on this object.
        methods.add_method("clearCache", |_, this, ()| {
            this.inner.borrow_mut().clear_cache();
            Ok(())
        });
        // -- getCacheSize --
        /// Returns the current path cache entry count.
        /// @return | integer | Cache size.
        methods.add_method("getCacheSize", |_, this, ()| {
            Ok(this.inner.borrow().get_cache_size())
        });
        // -- setCacheMaxSize --
        /// Sets maximum path cache size for this object.
        /// @param | n | integer | Maximum number of cached paths.
        methods.add_method("setCacheMaxSize", |_, this, n: usize| {
            this.inner.borrow_mut().set_cache_max_size(n);
            Ok(())
        });
        // -- type --
        /// Returns the Lua-visible type name for this pathfinder handle.
        /// @return | string | The string `LUnitPathfinder`.
        methods.add_method("type", |_, _, ()| Ok("LUnitPathfinder"));
        // -- typeOf --
        /// Returns whether this pathfinder handle matches a supported type name.
        /// @param | name | string | String value for `name`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LUnitPathfinder" || name == "LObject")
        });
    }
}
/// Lua-side wrapper for a flow field over a navigation grid.
pub struct LuaFlowField {
    /// Shared flow field data for this object.
    inner: Rc<RefCell<FlowField>>,
}
/// Provides Lua methods for flow field calculation, direction lookup, and steering.
impl LuaUserData for LuaFlowField {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- calculate --
        /// Calculates a flow field toward one target cell.
        /// @param | tx | integer | One-based target column.
        /// @param | ty | integer | One-based target row.
        /// @param | unit_size | integer? | Unit footprint in cells (default 1).
        methods.add_method(
            "calculate",
            |_, this, (tx, ty, unit_size): (u32, u32, Option<u32>)| {
                let (tx, ty) = one_based_coords_u32(tx, ty, "tx", "ty")?;
                this.inner
                    .borrow_mut()
                    .calculate(tx, ty, unit_size.unwrap_or(1));
                Ok(())
            },
        );
        // -- calculateMulti --
        /// Calculates a flow field toward multiple target cells.
        /// @param | targets | table | Array of `{x, y}` target tables.
        /// @param | unit_size | integer? | Unit footprint in cells (default 1).
        methods.add_method(
            "calculateMulti",
            |_, this, (targets, unit_size): (LuaTable, Option<u32>)| {
                let mut pts = Vec::new();
                for pair in targets.sequence_values::<LuaTable>() {
                    let entry = pair?;
                    let x: u32 = entry.get("x")?;
                    let y: u32 = entry.get("y")?;
                    pts.push(one_based_coords_u32(x, y, "x", "y")?);
                }
                this.inner
                    .borrow_mut()
                    .calculate_multi(&pts, unit_size.unwrap_or(1));
                Ok(())
            },
        );
        // -- getDirection --
        /// Returns flow direction vector at a one-based grid cell.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @return | number | Direction X component.
        /// @return | number | Direction Y component.
        methods.add_method("getDirection", |_, this, (x, y): (u32, u32)| {
            let (x, y) = one_based_coords_u32(x, y, "x", "y")?;
            Ok(this.inner.borrow().get_direction(x, y))
        });
        // -- getDirectionAngle --
        /// Returns flow direction angle at a one-based grid cell.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @return | number | Direction angle in radians.
        methods.add_method("getDirectionAngle", |_, this, (x, y): (u32, u32)| {
            let (x, y) = one_based_coords_u32(x, y, "x", "y")?;
            Ok(this.inner.borrow().get_direction_angle(x, y))
        });
        // -- getCostToTarget --
        /// Returns integration cost to the target from a one-based grid cell.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @return | number | Integration cost to the nearest target.
        methods.add_method("getCostToTarget", |_, this, (x, y): (u32, u32)| {
            let (x, y) = one_based_coords_u32(x, y, "x", "y")?;
            Ok(this.inner.borrow().get_cost_to_target(x, y))
        });
        // -- isCalculated --
        /// Returns whether the flow field has been calculated.
        /// @return | boolean | True when calculated.
        methods.add_method("isCalculated", |_, this, ()| {
            Ok(this.inner.borrow().is_calculated())
        });
        // -- getTargets --
        /// Returns target cells for this flow field.
        /// @return | table | Array table of target point tables.
        /// @field | x | number | X.
        /// @field | y | number | Y.
        methods.add_method("getTargets", |lua, this, ()| {
            let targets = this.inner.borrow().get_targets();
            let tbl = lua.create_table()?;
            for (i, (x, y)) in targets.iter().enumerate() {
                let entry = lua.create_table()?;
                /// The 'x' field value exposed to Lua scripts.
                entry.set("x", x + 1)?;
                /// The 'y' field value exposed to Lua scripts.
                entry.set("y", y + 1)?;
                tbl.set(i + 1, entry)?;
            }
            Ok(tbl)
        });
        // -- steer --
        /// Returns a steering velocity for a world position using the flow field.
        /// @param | wx | number | World X position.
        /// @param | wy | number | World Y position.
        /// @param | speed | number | Movement speed scalar.
        /// @param | tw | number | Tile width in world units.
        /// @param | th | number | Tile height in world units.
        /// @return | number | Steered X velocity.
        /// @return | number | Steered Y velocity.
        methods.add_method(
            "steer",
            |_, this, (wx, wy, speed, tw, th): (f32, f32, f32, f32, f32)| {
                Ok(this.inner.borrow().steer(wx, wy, speed, tw, th))
            },
        );
        // -- type --
        /// Returns the Lua-visible type name for this flow field handle.
        /// @return | string | The string `LFlowField`.
        methods.add_method("type", |_, _, ()| Ok("LFlowField"));
        // -- typeOf --
        /// Returns whether this flow field handle matches a supported type name.
        /// @param | name | string | String value for `name`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LFlowField" || name == "LObject")
        });
    }
}
/// Lua-side wrapper for a cell-size path grid.
pub struct LuaPathGrid {
    /// Shared path grid data for this object.
    inner: Rc<RefCell<PathGrid>>,
}
/// Provides Lua methods for walkability, costs, and path queries on a path grid.
impl LuaUserData for LuaPathGrid {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- getWidth --
        /// Returns grid width from this object.
        /// @return | integer | Grid width.
        methods.add_method("getWidth", |_, this, ()| {
            Ok(this.inner.borrow().width as u32)
        });
        // -- getHeight --
        /// Returns grid height from this object.
        /// @return | integer | Grid height.
        methods.add_method("getHeight", |_, this, ()| {
            Ok(this.inner.borrow().height as u32)
        });
        // -- getCellSize --
        /// Returns path grid cell size from this object.
        /// @return | number | Cell size.
        methods.add_method("getCellSize", |_, this, ()| {
            Ok(this.inner.borrow().cell_size)
        });
        // -- setWalkable --
        /// Sets walkability at a one-based cell.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @param | w | boolean | True to mark the cell walkable.
        methods.add_method("setWalkable", |_, this, (x, y, w): (usize, usize, bool)| {
            let (x, y) = one_based_coords_usize(x, y, "x", "y")?;
            this.inner.borrow_mut().set_walkable(x, y, w);
            Ok(())
        });
        // -- isWalkable --
        /// Returns walkability at a one-based cell.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @return | boolean | True when walkable.
        methods.add_method("isWalkable", |_, this, (x, y): (usize, usize)| {
            let (x, y) = one_based_coords_usize(x, y, "x", "y")?;
            Ok(this.inner.borrow().is_walkable(x, y))
        });
        // -- setCost --
        /// Sets movement cost at a one-based cell.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @param | cost | number | Movement cost value.
        methods.add_method("setCost", |_, this, (x, y, cost): (usize, usize, f32)| {
            let (x, y) = one_based_coords_usize(x, y, "x", "y")?;
            this.inner.borrow_mut().set_cost(x, y, cost);
            Ok(())
        });
        // -- getCost --
        /// Returns movement cost at a one-based cell.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @return | number | Movement cost.
        methods.add_method("getCost", |_, this, (x, y): (usize, usize)| {
            let (x, y) = one_based_coords_usize(x, y, "x", "y")?;
            Ok(this.inner.borrow().get_cost(x, y))
        });
        // -- findPath --
        /// Finds a path between one-based path grid cells.
        /// @param | sx | integer | One-based start column.
        /// @param | sy | integer | One-based start row.
        /// @param | gx | integer | One-based goal column.
        /// @param | gy | integer | One-based goal row.
        /// @return | table | Array of `{x, y}` point tables, or nil when no path exists.
        /// @field | x | number | X.
        /// @field | y | number | Y.
        methods.add_method(
            "findPath",
            |lua, this, (sx, sy, gx, gy): (usize, usize, usize, usize)| -> LuaResult<LuaValue> {
                let (sx, sy) = one_based_coords_usize(sx, sy, "sx", "sy")?;
                let (gx, gy) = one_based_coords_usize(gx, gy, "gx", "gy")?;
                match this.inner.borrow().find_path(sx, sy, gx, gy) {
                    None => Ok(LuaValue::Nil),
                    Some(pts) => {
                        let tbl = lua.create_table()?;
                        for (i, (px, py)) in pts.iter().enumerate() {
                            let pt = lua.create_table()?;
                            /// The 'x' field value exposed to Lua scripts.
                            pt.set("x", *px)?;
                            /// The 'y' field value exposed to Lua scripts.
                            pt.set("y", *py)?;
                            tbl.set(i + 1, pt)?;
                        }
                        Ok(LuaValue::Table(tbl))
                    }
                }
            },
        );
        // -- findPathSmoothed --
        /// Finds a smoothed path between one-based path grid cells.
        /// @param | sx | integer | One-based start column.
        /// @param | sy | integer | One-based start row.
        /// @param | gx | integer | One-based goal column.
        /// @param | gy | integer | One-based goal row.
        /// @return | table | Array of `{x, y}` point tables, or nil when no path exists.
        /// @field | x | number | X.
        /// @field | y | number | Y.
        methods.add_method(
            "findPathSmoothed",
            |lua, this, (sx, sy, gx, gy): (usize, usize, usize, usize)| -> LuaResult<LuaValue> {
                let (sx, sy) = one_based_coords_usize(sx, sy, "sx", "sy")?;
                let (gx, gy) = one_based_coords_usize(gx, gy, "gx", "gy")?;
                match this.inner.borrow().find_path_smoothed(sx, sy, gx, gy) {
                    None => Ok(LuaValue::Nil),
                    Some(pts) => {
                        let tbl = lua.create_table()?;
                        for (i, (px, py)) in pts.iter().enumerate() {
                            let pt = lua.create_table()?;
                            /// The 'x' field value exposed to Lua scripts.
                            pt.set("x", *px)?;
                            /// The 'y' field value exposed to Lua scripts.
                            pt.set("y", *py)?;
                            tbl.set(i + 1, pt)?;
                        }
                        Ok(LuaValue::Table(tbl))
                    }
                }
            },
        );
        // -- type --
        /// Returns the Lua-visible type name for this path grid handle.
        /// @return | string | The string `LPathGrid`.
        methods.add_method("type", |_, _, ()| Ok("LPathGrid"));
        // -- typeOf --
        /// Returns whether this path grid handle matches a supported type name.
        /// @param | name | string | String value for `name`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LPathGrid" || name == "LObject")
        });
    }
}
/// Lua-side wrapper for an AI flow field over a path grid.
pub struct LuaAiFlowField {
    /// Shared AI flow field data for this object.
    inner: Rc<RefCell<AiFlowField>>,
}
/// Provides Lua methods for AI flow field dimensions, goal, direction, and distance.
impl LuaUserData for LuaAiFlowField {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- getWidth --
        /// Returns flow field width from this object.
        /// @return | integer | Width.
        methods.add_method("getWidth", |_, this, ()| {
            Ok(this.inner.borrow().width as u32)
        });
        // -- getHeight --
        /// Returns flow field height from this object.
        /// @return | integer | Height.
        methods.add_method("getHeight", |_, this, ()| {
            Ok(this.inner.borrow().height as u32)
        });
        // -- hasGoal --
        /// Returns whether a flow field goal is currently set.
        /// @return | boolean | True when a goal exists.
        methods.add_method("hasGoal", |_, this, ()| {
            Ok(this.inner.borrow().goal.is_some())
        });
        // -- setGoal --
        /// Sets the one-based flow field goal and recalculates the field.
        /// @param | x | integer | One-based goal column.
        /// @param | y | integer | One-based goal row.
        methods.add_method("setGoal", |_, this, (x, y): (usize, usize)| {
            let (x, y) = one_based_coords_usize(x, y, "x", "y")?;
            this.inner.borrow_mut().set_goal(x, y);
            Ok(())
        });
        // -- getGoal --
        /// Returns the one-based flow field goal, or nil when no goal is set.
        /// @return | integer | One-based goal column, or nil.
        /// @return | integer | One-based goal row, or nil.
        methods.add_method(
            "getGoal",
            |_, this, ()| -> LuaResult<(LuaValue, LuaValue)> {
                match this.inner.borrow().goal {
                    None => Ok((LuaValue::Nil, LuaValue::Nil)),
                    Some((gx, gy)) => Ok((
                        LuaValue::Integer((gx + 1) as i64),
                        LuaValue::Integer((gy + 1) as i64),
                    )),
                }
            },
        );
        // -- getDirection --
        /// Returns flow direction vector for a one-based cell.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @return | number | Direction X component.
        /// @return | number | Direction Y component.
        methods.add_method("getDirection", |_, this, (x, y): (usize, usize)| {
            let (x, y) = one_based_coords_usize(x, y, "x", "y")?;
            Ok(this.inner.borrow().get_direction(x, y))
        });
        // -- getDistance --
        /// Returns distance to goal for a one-based cell.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @return | number | Distance to the goal.
        methods.add_method("getDistance", |_, this, (x, y): (usize, usize)| {
            let (x, y) = one_based_coords_usize(x, y, "x", "y")?;
            Ok(this.inner.borrow().get_distance(x, y))
        });
        // -- type --
        /// Returns the Lua-visible type name for this AI flow field handle.
        /// @return | string | The string `LAIFlowField`.
        methods.add_method("type", |_, _, ()| Ok("LAIFlowField"));
        // -- typeOf --
        /// Returns whether this AI flow field handle matches a supported type name.
        /// @param | name | string | String value for `name`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LAIFlowField" || name == "LObject")
        });
    }
}
/// Lua-side wrapper for a hexagonal grid.
pub struct LuaHexGrid {
    /// Shared hex grid data for this object.
    inner: Rc<RefCell<HexGrid>>,
}
/// Provides Lua methods for hex grid blocking, costs, pathing, visibility, movement range, and distance.
impl LuaUserData for LuaHexGrid {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- setBlocked --
        /// Sets blocked state for a one-based hex cell.
        /// @param | col | integer | One-based hex column.
        /// @param | row | integer | One-based hex row.
        /// @param | blocked | boolean | True to block the cell.
        methods.add_method_mut(
            "setBlocked",
            |_, this, (col, row, blocked): (u32, u32, bool)| {
                let (col, row) = one_based_coords_u32(col, row, "col", "row")?;
                this.inner.borrow_mut().set_blocked(col, row, blocked);
                Ok(())
            },
        );
        // -- setCost --
        /// Sets movement cost for a one-based hex cell.
        /// @param | col | integer | One-based hex column.
        /// @param | row | integer | One-based hex row.
        /// @param | cost | number | Movement cost value.
        methods.add_method_mut("setCost", |_, this, (col, row, cost): (u32, u32, f32)| {
            let (col, row) = one_based_coords_u32(col, row, "col", "row")?;
            this.inner.borrow_mut().set_cost(col, row, cost);
            Ok(())
        });
        // -- isBlocked --
        /// Returns whether a one-based hex cell is blocked.
        /// @param | col | integer | One-based hex column.
        /// @param | row | integer | One-based hex row.
        /// @return | boolean | True when blocked.
        methods.add_method("isBlocked", |_, this, (col, row): (u32, u32)| {
            let (col, row) = one_based_coords_u32(col, row, "col", "row")?;
            Ok(this.inner.borrow().is_blocked(col, row))
        });
        // -- findPath --
        /// Finds a path between one-based hex cells.
        /// @param | fc | integer | One-based start column.
        /// @param | fr | integer | One-based start row.
        /// @param | tc | integer | One-based goal column.
        /// @param | tr | integer | One-based goal row.
        /// @return | table | Array of `{col, row}` hex cell tables, or nil when no path exists.
        /// @field | col | integer | Col.
        /// @field | row | integer | Row.
        methods.add_method(
            "findPath",
            |lua, this, (fc, fr, tc, tr): (u32, u32, u32, u32)| {
                let from = one_based_coords_u32(fc, fr, "fc", "fr")?;
                let to = one_based_coords_u32(tc, tr, "tc", "tr")?;
                match this.inner.borrow().find_path(from, to) {
                    None => Ok(LuaValue::Nil),
                    Some(path) => {
                        let t = lua.create_table()?;
                        for (i, (c, r)) in path.iter().enumerate() {
                            let cell = lua.create_table()?;
                            /// The 'col' field value exposed to Lua scripts.
                            cell.set("col", c + 1)?;
                            /// The 'row' field value exposed to Lua scripts.
                            cell.set("row", r + 1)?;
                            t.set(i + 1, cell)?;
                        }
                        Ok(LuaValue::Table(t))
                    }
                }
            },
        );
        // -- fieldOfView --
        /// Returns visible hex cells within range from an origin.
        /// @param | col | integer | One-based origin column.
        /// @param | row | integer | One-based origin row.
        /// @param | max_range | integer | Maximum visibility range in cells.
        /// @return | table | Array of `{col, row}` hex cell tables.
        /// @field | col | integer | Col.
        /// @field | row | integer | Row.
        methods.add_method(
            "fieldOfView",
            |lua, this, (col, row, max_range): (u32, u32, u32)| {
                let origin = one_based_coords_u32(col, row, "col", "row")?;
                let cells = this.inner.borrow().field_of_view(origin, max_range);
                let t = lua.create_table()?;
                for (i, (c, r)) in cells.iter().enumerate() {
                    let cell = lua.create_table()?;
                    /// The 'col' field value exposed to Lua scripts.
                    cell.set("col", c + 1)?;
                    /// The 'row' field value exposed to Lua scripts.
                    cell.set("row", r + 1)?;
                    t.set(i + 1, cell)?;
                }
                Ok(t)
            },
        );
        // -- rangeOfMovement --
        /// Returns reachable hex cells within a movement budget.
        /// @param | col | integer | One-based origin column.
        /// @param | row | integer | One-based origin row.
        /// @param | budget | number | Maximum movement cost budget.
        /// @return | table | Array of `{col, row}` hex cell tables.
        /// @field | col | integer | Col.
        /// @field | row | integer | Row.
        methods.add_method(
            "rangeOfMovement",
            |lua, this, (col, row, budget): (u32, u32, f32)| {
                let origin = one_based_coords_u32(col, row, "col", "row")?;
                let cells = this.inner.borrow().range_of_movement(origin, budget);
                let t = lua.create_table()?;
                for (i, (c, r)) in cells.iter().enumerate() {
                    let cell = lua.create_table()?;
                    /// The 'col' field value exposed to Lua scripts.
                    cell.set("col", c + 1)?;
                    /// The 'row' field value exposed to Lua scripts.
                    cell.set("row", r + 1)?;
                    t.set(i + 1, cell)?;
                }
                Ok(t)
            },
        );
        // -- distance --
        /// Returns hex distance between two one-based hex cells.
        /// @param | c1 | integer | One-based column of the first cell.
        /// @param | r1 | integer | One-based row of the first cell.
        /// @param | c2 | integer | One-based column of the second cell.
        /// @param | r2 | integer | One-based row of the second cell.
        /// @return | number | Hex distance.
        methods.add_method(
            "distance",
            |_, this, (c1, r1, c2, r2): (u32, u32, u32, u32)| {
                let from = one_based_coords_u32(c1, r1, "c1", "r1")?;
                let to = one_based_coords_u32(c2, r2, "c2", "r2")?;
                Ok(this.inner.borrow().distance(from, to))
            },
        );
        // -- type --
        /// Returns the Lua-visible type name for this hex grid handle.
        /// @return | string | The string `LHexGrid`.
        methods.add_method("type", |_, _, ()| Ok("LHexGrid"));
        // -- typeOf --
        /// Returns whether this hex grid handle matches a supported type name.
        /// @param | name | string | String value for `name`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LHexGrid" || name == "LObject")
        });
    }
}
/// Lua-side wrapper for a Jump Point Search grid.
pub struct LuaJpsGrid {
    /// Shared JPS grid data for this object.
    inner: Rc<RefCell<JpsGrid>>,
}
/// Provides Lua methods for JPS blocking and path queries.
impl LuaUserData for LuaJpsGrid {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- setBlocked --
        /// Sets blocked state for a one-based JPS grid cell.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @param | blocked | boolean | True to block the cell.
        methods.add_method_mut(
            "setBlocked",
            |_, this, (x, y, blocked): (u32, u32, bool)| {
                let (x, y) = one_based_coords_u32(x, y, "x", "y")?;
                this.inner.borrow_mut().set_blocked(x, y, blocked);
                Ok(())
            },
        );
        // -- isBlocked --
        /// Returns whether a one-based JPS grid cell is blocked.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @return | boolean | True when blocked.
        methods.add_method("isBlocked", |_, this, (x, y): (u32, u32)| {
            let (x, y) = one_based_coords_u32(x, y, "x", "y")?;
            Ok(this.inner.borrow().is_blocked(x, y))
        });
        // -- findPath --
        /// Finds a JPS path between one-based grid cells.
        /// @param | fx | integer | One-based start column.
        /// @param | fy | integer | One-based start row.
        /// @param | tx | integer | One-based goal column.
        /// @param | ty | integer | One-based goal row.
        /// @return | table | Array of `{x, y}` point tables, or nil when no path exists.
        /// @field | x | number | X.
        /// @field | y | number | Y.
        methods.add_method(
            "findPath",
            |lua, this, (fx, fy, tx, ty): (u32, u32, u32, u32)| {
                let from = one_based_coords_u32(fx, fy, "fx", "fy")?;
                let to = one_based_coords_u32(tx, ty, "tx", "ty")?;
                match this.inner.borrow().find_path(from, to) {
                    None => Ok(LuaValue::Nil),
                    Some(path) => {
                        let t = lua.create_table()?;
                        for (i, (x, y)) in path.iter().enumerate() {
                            let cell = lua.create_table()?;
                            /// The 'x' field value exposed to Lua scripts.
                            cell.set("x", x + 1)?;
                            /// The 'y' field value exposed to Lua scripts.
                            cell.set("y", y + 1)?;
                            t.set(i + 1, cell)?;
                        }
                        Ok(LuaValue::Table(t))
                    }
                }
            },
        );
        // -- type --
        /// Returns the Lua-visible type name for this JPS grid handle.
        /// @return | string | The string `LJpsGrid`.
        methods.add_method("type", |_, _, ()| Ok("LJpsGrid"));
        // -- typeOf --
        /// Returns whether this JPS grid handle matches a supported type name.
        /// @param | name | string | String value for `name`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LJpsGrid" || name == "LObject")
        });
    }
}
/// Lua-side wrapper for a navigation mesh.
pub struct LuaNavMesh {
    /// Shared navmesh data for this object.
    inner: Rc<RefCell<NavMesh>>,
}
/// Provides Lua methods for navmesh polygons, links, and path queries.
impl LuaUserData for LuaNavMesh {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- addPolygon --
        /// Adds a polygon from vertex tables and returns a one-based id.
        /// @param | vertices | table | Array of `{x, y}` vertex tables (minimum 3).
        /// @return | integer | One-based polygon id.
        methods.add_method_mut("addPolygon", |_, this, vertices: LuaTable| {
            let mut points = Vec::new();
            for entry in vertices.sequence_values::<LuaTable>() {
                let v = entry?;
                let x: f32 = v.get("x")?;
                let y: f32 = v.get("y")?;
                points.push((x, y));
            }
            let id = this
                .inner
                .borrow_mut()
                .add_polygon(points)
                .ok_or_else(|| LuaError::runtime("addPolygon requires at least 3 vertices"))?;
            Ok((id + 1) as u32)
        });
        // -- connectPolygons --
        /// Connects two polygons by one-based id.
        /// @param | a | integer | One-based id of the first polygon.
        /// @param | b | integer | One-based id of the second polygon.
        /// @param | bidirectional | boolean? | True for two-way link (default true).
        /// @return | boolean | True when the connection was added.
        methods.add_method_mut(
            "connectPolygons",
            |_, this, (a, b, bidirectional): (u32, u32, Option<bool>)| {
                Ok(this.inner.borrow_mut().connect(
                    a.saturating_sub(1) as usize,
                    b.saturating_sub(1) as usize,
                    bidirectional.unwrap_or(true),
                ))
            },
        );
        // -- findPath --
        /// Finds a path through the navmesh between world points.
        /// @param | sx | number | Start X in world coordinates.
        /// @param | sy | number | Start Y in world coordinates.
        /// @param | gx | number | Goal X in world coordinates.
        /// @param | gy | number | Goal Y in world coordinates.
        /// @return | table | Array of `{x, y}` point tables, or nil when no path exists.
        /// @field | x | number | X.
        /// @field | y | number | Y.
        methods.add_method(
            "findPath",
            |lua, this, (sx, sy, gx, gy): (f32, f32, f32, f32)| {
                let path = this.inner.borrow().find_path((sx, sy), (gx, gy));
                match path {
                    Some(points) => {
                        let out = lua.create_table()?;
                        for (i, (x, y)) in points.iter().enumerate() {
                            let node = lua.create_table()?;
                            /// The 'x' field value exposed to Lua scripts.
                            node.set("x", *x)?;
                            /// The 'y' field value exposed to Lua scripts.
                            node.set("y", *y)?;
                            out.set(i + 1, node)?;
                        }
                        Ok(LuaValue::Table(out))
                    }
                    None => Ok(LuaValue::Nil),
                }
            },
        );
        // -- getPolygonCount --
        /// Returns the total navmesh polygon count.
        /// @return | integer | Polygon count.
        methods.add_method("getPolygonCount", |_, this, ()| {
            Ok(this.inner.borrow().polygon_count() as u32)
        });
        // -- type --
        /// Returns the Lua-visible type name for this navmesh handle.
        /// @return | string | The string `LNavMesh`.
        methods.add_method("type", |_, _, ()| Ok("LNavMesh"));
        // -- typeOf --
        /// Returns whether this navmesh handle matches a supported type name.
        /// @param | name | string | String value for `name`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LNavMesh" || name == "LObject")
        });
    }
}
/// Lua handle for a steering behavior stack that combines movement forces for an agent.
#[derive(Clone)]
struct LuaSteeringManager {
    /// Shared steering manager containing configured steering behaviors and path state.
    inner: Rc<RefCell<SteeringManager>>,
    /// Registry used by custom steering behavior callbacks.
    custom_callbacks: Rc<RefCell<CallbackRegistry>>,
}
impl LuaUserData for LuaSteeringManager {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- addSeek --
        /// Adds a seek behavior that pulls the agent toward a target point.
        /// @param | tx | number | Target X position in world units.
        /// @param | ty | number | Target Y position in world units.
        /// @param | weight | number? | Behavior weight applied during steering combination; defaults to 1.0.
        methods.add_method(
            "addSeek",
            |_, this, (tx, ty, weight): (f32, f32, Option<f32>)| {
                let tx = lua_require_finite_f32("steering seek target.x", tx)?;
                let ty = lua_require_finite_f32("steering seek target.y", ty)?;
                let weight = lua_require_non_negative_f64(
                    "steering seek weight",
                    f64::from(weight.unwrap_or(1.0)),
                )? as f32;
                this.inner.borrow_mut().add_seek(tx, ty, weight);
                Ok(())
            },
        );
        // -- addFlee --
        /// Adds a flee behavior that pushes the agent away from a target point inside a panic distance.
        /// @param | tx | number | Threat X position in world units.
        /// @param | ty | number | Threat Y position in world units.
        /// @param | panic_dist | number? | Distance inside which fleeing is active; defaults to 200.0.
        /// @param | weight | number? | Behavior weight applied during steering combination; defaults to 1.0.
        methods.add_method(
            "addFlee",
            |_, this, (tx, ty, panic_dist, weight): (f32, f32, Option<f32>, Option<f32>)| {
                let tx = lua_require_finite_f32("steering flee target.x", tx)?;
                let ty = lua_require_finite_f32("steering flee target.y", ty)?;
                let panic_dist = lua_require_non_negative_f64(
                    "steering panic_dist",
                    f64::from(panic_dist.unwrap_or(200.0)),
                )? as f32;
                let weight = lua_require_non_negative_f64(
                    "steering flee weight",
                    f64::from(weight.unwrap_or(1.0)),
                )? as f32;
                this.inner.borrow_mut().add_flee(tx, ty, panic_dist, weight);
                Ok(())
            },
        );
        // -- addArrive --
        /// Adds an arrive behavior that slows the agent as it approaches a target point.
        /// @param | tx | number | Target X position in world units.
        /// @param | ty | number | Target Y position in world units.
        /// @param | slowing | number? | Radius used to reduce speed near the target; defaults to 50.0.
        /// @param | weight | number? | Behavior weight applied during steering combination; defaults to 1.0.
        methods.add_method(
            "addArrive",
            |_, this, (tx, ty, slowing, weight): (f32, f32, Option<f32>, Option<f32>)| {
                let tx = lua_require_finite_f32("steering arrive target.x", tx)?;
                let ty = lua_require_finite_f32("steering arrive target.y", ty)?;
                let slowing =
                    lua_require_positive_f32("steering slowing_radius", slowing.unwrap_or(50.0))?;
                let weight = lua_require_non_negative_f64(
                    "steering arrive weight",
                    f64::from(weight.unwrap_or(1.0)),
                )? as f32;
                this.inner.borrow_mut().add_arrive(tx, ty, slowing, weight);
                Ok(())
            },
        );
        // -- addWander --
        /// Adds a wander behavior that produces jittered exploratory movement.
        /// @param | radius | number? | Wander circle radius; defaults to 20.0.
        /// @param | dist | number? | Wander circle distance in front of the agent; defaults to 40.0.
        /// @param | jitter | number? | Random displacement applied per update; defaults to 5.0.
        /// @param | weight | number? | Behavior weight applied during steering combination; defaults to 1.0.
        methods.add_method(
            "addWander",
            |_,
             this,
             (radius, dist, jitter, weight): (
                Option<f32>,
                Option<f32>,
                Option<f32>,
                Option<f32>,
            )| {
                let radius =
                    lua_require_positive_f32("steering wander_radius", radius.unwrap_or(20.0))?;
                let dist =
                    lua_require_positive_f32("steering wander_distance", dist.unwrap_or(40.0))?;
                let jitter = lua_require_non_negative_f64(
                    "steering wander_jitter",
                    f64::from(jitter.unwrap_or(5.0)),
                )? as f32;
                let weight = lua_require_non_negative_f64(
                    "steering wander weight",
                    f64::from(weight.unwrap_or(1.0)),
                )? as f32;
                this.inner
                    .borrow_mut()
                    .add_wander(radius, dist, jitter, weight);
                Ok(())
            },
        );
        // -- addPursue --
        /// Adds a pursue behavior that chases another named agent when a target name is supplied.
        /// @param | target_name | string? | Optional name of the agent to pursue.
        /// @param | weight | number? | Behavior weight applied during steering combination; defaults to 1.0.
        methods.add_method(
            "addPursue",
            |_, this, (target_name, weight): (Option<String>, Option<f32>)| {
                this.inner
                    .borrow_mut()
                    .add_pursue(target_name, weight.unwrap_or(1.0));
                Ok(())
            },
        );
        // -- addEvade --
        /// Adds an evade behavior that moves away from another named agent when a threat name is supplied.
        /// @param | threat_name | string? | Optional name of the agent to evade.
        /// @param | weight | number? | Behavior weight applied during steering combination; defaults to 1.0.
        methods.add_method(
            "addEvade",
            |_, this, (threat_name, weight): (Option<String>, Option<f32>)| {
                this.inner
                    .borrow_mut()
                    .add_evade(threat_name, weight.unwrap_or(1.0));
                Ok(())
            },
        );
        // -- addFlock --
        /// Adds a flocking behavior with separation, alignment, and cohesion weights.
        /// @param | neighbor_radius | number? | Radius used to find flock neighbors; defaults to 100.0.
        /// @param | sep_w | number? | Separation force weight; defaults to 1.5.
        /// @param | align_w | number? | Alignment force weight; defaults to 1.0.
        /// @param | coh_w | number? | Cohesion force weight; defaults to 1.0.
        /// @param | weight | number? | Behavior weight applied during steering combination; defaults to 1.0.
        methods.add_method(
            "addFlock",
            #[allow(clippy::type_complexity)]
            |_,
             this,
             (neighbor_radius, sep_w, align_w, coh_w, weight): (
                Option<f32>,
                Option<f32>,
                Option<f32>,
                Option<f32>,
                Option<f32>,
            )| {
                this.inner.borrow_mut().add_flock(
                    neighbor_radius.unwrap_or(100.0),
                    sep_w.unwrap_or(1.5),
                    align_w.unwrap_or(1.0),
                    coh_w.unwrap_or(1.0),
                    weight.unwrap_or(1.0),
                );
                Ok(())
            },
        );
        // -- getBehaviorCount --
        /// Returns the number of steering behaviors configured on this manager.
        /// @return | integer | Current steering behavior count.
        methods.add_method("getBehaviorCount", |_, this, ()| {
            Ok(this.inner.borrow().behaviors.len())
        });
        // -- setCombineMode --
        /// Sets how steering behavior forces are combined.
        /// @param | mode | string | Combine mode string parsed by the steering manager.
        methods.add_method("setCombineMode", |_, this, mode: String| {
            this.inner.borrow_mut().set_combine_mode_str(&mode);
            Ok(())
        });
        // -- getCombineMode --
        /// Returns the current steering force combination mode.
        /// @return | string | Combine mode name.
        methods.add_method("getCombineMode", |_, this, ()| {
            Ok(this.inner.borrow().combine_mode.as_str().to_string())
        });
        // -- getLastSteering --
        /// Returns the last steering force calculated by this manager.
        /// @return | number, number | X and Y force values from the previous calculation.
        methods.add_method("getLastSteering", |_, this, ()| {
            Ok(this.inner.borrow().last_force())
        });
        // -- calculate --
        /// Calculates a steering force for the supplied agent movement state.
        /// @param | px | number | Current agent X position.
        /// @param | py | number | Current agent Y position.
        /// @param | vx | number | Current agent X velocity.
        /// @param | vy | number | Current agent Y velocity.
        /// @param | max_speed | number | Maximum allowed speed used by steering constraints.
        /// @param | max_force | number | Maximum allowed steering force.
        /// @param | dt | number | Elapsed time in seconds for this steering step.
        /// @return | number, number | X and Y steering force.
        methods.add_method("calculate", |_, this, (px, py, vx, vy, max_speed, max_force, dt): (f32, f32, f32, f32, f32, f32, f32)| {
                let px = lua_require_finite_f32("steering position.x", px)?;
                let py = lua_require_finite_f32("steering position.y", py)?;
                let vx = lua_require_finite_f32("steering velocity.x", vx)?;
                let vy = lua_require_finite_f32("steering velocity.y", vy)?;
                let max_speed = lua_require_positive_f32("steering max_speed", max_speed)?;
                let max_force = lua_require_non_negative_f64("steering max_force", f64::from(max_force))? as f32;
                let dt = lua_require_finite_f32("steering dt", dt)?;
                let force = this.inner.borrow_mut().calculate(
                    (px, py),
                    (vx, vy),
                    max_speed,
                    max_force,
                    dt,
                );
                Ok(force)
            },
        );
        // -- setPath --
        /// Sets a waypoint path behavior from an array of `{x, y}` tables.
        /// @param | waypoints | table | Array of waypoint tables, each containing numeric `x` and `y` fields.
        /// @param | reach_radius | number? | Distance at which a waypoint is considered reached; defaults to 12.0.
        /// @param | weight | number? | Path following behavior weight; defaults to 1.0.
        methods.add_method(
            "setPath",
            |_, this, (waypoints, reach_radius, weight): (LuaTable, Option<f32>, Option<f32>)| {
                let mut out = Vec::new();
                for entry in waypoints.sequence_values::<LuaTable>() {
                    let pt = entry?;
                    let x: f32 = pt.get("x").map_err(|_| {
                        LuaError::RuntimeError(
                            "lurek.pathfind.SteeringManager:setPath expected waypoint.x"
                                .to_string(),
                        )
                    })?;
                    let y: f32 = pt.get("y").map_err(|_| {
                        LuaError::RuntimeError(
                            "lurek.pathfind.SteeringManager:setPath expected waypoint.y"
                                .to_string(),
                        )
                    })?;
                    out.push((x, y));
                }
                this.inner.borrow_mut().set_path(
                    out,
                    reach_radius.unwrap_or(12.0),
                    weight.unwrap_or(1.0),
                );
                Ok(())
            },
        );
        // -- clearPath --
        /// Clears the active waypoint path behavior.
        methods.add_method("clearPath", |_, this, ()| {
            this.inner.borrow_mut().clear_path();
            Ok(())
        });
        // -- hasPath --
        /// Returns whether this manager currently has an active waypoint path.
        /// @return | boolean | True when a path is configured and not complete.
        methods.add_method("hasPath", |_, this, ()| {
            Ok(this.inner.borrow().has_active_path())
        });
        // -- getPathProgress --
        /// Returns the current one-based waypoint index and total waypoint count.
        /// @return | integer, integer | Current waypoint index and total waypoint count.
        methods.add_method("getPathProgress", |_, this, ()| {
            let (idx, total) = this.inner.borrow().path_progress();
            Ok((idx + 1, total))
        });
        // -- setEntity --
        /// Sets or replaces one named steering-context entity.
        /// @param | name | string | Entity name used by pursue, evade, and flock behaviors.
        /// @param | x | number | Current entity X position.
        /// @param | y | number | Current entity Y position.
        /// @param | vx | number? | Current entity X velocity; defaults to 0.
        /// @param | vy | number? | Current entity Y velocity; defaults to 0.
        methods.add_method_mut(
            "setEntity",
            |_, this, (name, x, y, vx, vy): (String, f32, f32, Option<f32>, Option<f32>)| {
                let x = lua_require_finite_f32("steering entity.x", x)?;
                let y = lua_require_finite_f32("steering entity.y", y)?;
                let vx = lua_require_finite_f32("steering entity.vx", vx.unwrap_or(0.0))?;
                let vy = lua_require_finite_f32("steering entity.vy", vy.unwrap_or(0.0))?;
                this.inner.borrow_mut().set_entity(name, (x, y), (vx, vy));
                Ok(())
            },
        );
        // -- removeEntity --
        /// Removes one named steering-context entity.
        /// @param | name | string | Entity name to remove.
        /// @return | boolean | True when an entity was removed.
        methods.add_method_mut("removeEntity", |_, this, name: String| {
            Ok(this.inner.borrow_mut().remove_entity(&name))
        });
        // -- clearEntities --
        /// Clears all steering-context entities.
        methods.add_method_mut("clearEntities", |_, this, ()| {
            this.inner.borrow_mut().clear_entities();
            Ok(())
        });
        // -- entityCount --
        /// Returns the number of steering-context entities.
        /// @return | integer | Entity count.
        methods.add_method("entityCount", |_, this, ()| {
            Ok(this.inner.borrow().entity_count() as i64)
        });
        // -- getLastDiagnostic --
        /// Returns the most recent steering validation or runtime diagnostic.
        /// @return | LuaValue | Diagnostic string, or nil when no diagnostic has been recorded.
        methods.add_method("getLastDiagnostic", |_, this, ()| {
            Ok(this.inner.borrow().last_diagnostic.clone())
        });
        // -- type --
        /// Returns the Lua-visible type name for this steering manager handle.
        /// @return | string | The string `LSteeringManager`.
        methods.add_method("type", |_, _, ()| Ok("LSteeringManager"));
        // -- typeOf --
        /// Returns whether this steering manager handle matches a supported type name.
        /// @param | name | string | Type name to compare against `SteeringManager` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LSteeringManager" || name == "LObject")
        });
        // -- setSpatialHashCellSize --
        /// Sets the cell size used by the steering manager spatial hash.
        /// @param | size | number | Spatial hash cell size in world units.
        methods.add_method_mut("setSpatialHashCellSize", |_, this, size: f32| {
            this.inner.borrow_mut().set_cell_size(size);
            Ok(())
        });
        // -- enableSpatialHash --
        /// Enables or disables spatial hash acceleration for neighbor queries.
        /// @param | enabled | boolean | True to use spatial hashing, false to use direct scans.
        methods.add_method_mut("enableSpatialHash", |_, this, enabled: bool| {
            this.inner.borrow_mut().set_use_spatial_hash(enabled);
            Ok(())
        });
        // -- addCustomBehavior --
        /// Adds a custom steering behavior backed by a Lua callback.
        /// @param | func | function | Function called as `(agent, dt)` that returns an X and Y steering force.
        /// @param | weight | number? | Custom behavior weight applied to returned forces; defaults to 1.0.
        methods.add_method(
            "addCustomBehavior",
            |lua, this, (func, weight): (LuaFunction, Option<f32>)| {
                let key = lua.create_registry_value(func)?;
                let callback_id = this.custom_callbacks.borrow_mut().register(key);
                this.inner.borrow_mut().behaviors.push(
                    crate::pathfind::SteeringBehaviorType::Custom {
                        callback_id,
                        base: crate::pathfind::SteeringBase {
                            weight: weight.unwrap_or(1.0),
                            enabled: true,
                        },
                    },
                );
                Ok(())
            },
        );
        // -- applyCustomSteering --
        /// Runs enabled custom steering callbacks for an agent and returns the weighted combined force.
        /// @param | agent | LBot | Bot handle passed through to every custom steering callback.
        /// @param | dt | number | Elapsed time in seconds passed to every custom steering callback.
        /// @return | number, number | Combined custom X and Y steering force.
        methods.add_method(
            "applyCustomSteering",
            |lua, this, (agent_ud, dt): (LuaAnyUserData, f32)| {
                let behaviors: Vec<(u32, f32)> = {
                    let sm = this.inner.borrow();
                    sm.behaviors
                        .iter()
                        .filter_map(|b| {
                            if let crate::pathfind::SteeringBehaviorType::Custom {
                                callback_id,
                                base,
                            } = b
                            {
                                if base.enabled {
                                    Some((*callback_id, base.weight))
                                } else {
                                    None
                                }
                            } else {
                                None
                            }
                        })
                        .collect()
                };
                let mut force = (0.0f32, 0.0f32);
                for (callback_id, weight) in behaviors {
                    let func_opt: Option<LuaFunction> = {
                        let cb = this.custom_callbacks.borrow();
                        cb.get(callback_id)
                            .and_then(|key| lua.registry_value(key).ok())
                    };
                    if let Some(func) = func_opt {
                        match func.call::<_, (f32, f32)>((agent_ud.clone(), dt)) {
                            Ok((fx, fy)) => {
                                force.0 += fx * weight;
                                force.1 += fy * weight;
                            }
                            Err(e) => {
                                this.inner.borrow_mut().last_diagnostic =
                                    Some(format!("custom steering callback error: {e}"));
                            }
                        }
                    }
                }
                Ok(force)
            },
        );
    }
}

/// Lua handle for a grid-based influence map with named layers.
#[derive(Clone)]
struct LuaInfluenceMap {
    /// Shared influence map storing layer grids and world-cell conversion data.
    inner: Rc<RefCell<InfluenceMap>>,
}
impl LuaUserData for LuaInfluenceMap {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- addLayer --
        /// Adds an influence layer with the given name if it does not already exist.
        /// @param | name | string | Layer name used by later influence operations.
        methods.add_method("addLayer", |_, this, name: String| {
            this.inner.borrow_mut().add_layer(&name);
            Ok(())
        });
        // -- hasLayer --
        /// Returns whether an influence layer exists.
        /// @param | name | string | Layer name to check.
        /// @return | boolean | True when the layer exists.
        methods.add_method("hasLayer", |_, this, name: String| {
            Ok(this.inner.borrow().has_layer(&name))
        });
        // -- setInfluence --
        /// Sets one cell value in a named influence layer using one-based cell coordinates.
        /// @param | layer | string | Layer name to modify.
        /// @param | x | integer | One-based cell X coordinate.
        /// @param | y | integer | One-based cell Y coordinate.
        /// @param | value | number | Influence value to store in the cell.
        methods.add_method(
            "setInfluence",
            |_, this, (layer, x, y, value): (String, usize, usize, f32)| {
                this.inner.borrow_mut().set_influence(
                    &layer,
                    x.saturating_sub(1),
                    y.saturating_sub(1),
                    value,
                );
                Ok(())
            },
        );
        // -- getInfluence --
        /// Returns one cell value from a named influence layer using one-based cell coordinates.
        /// @param | layer | string | Layer name to read.
        /// @param | x | integer | One-based cell X coordinate.
        /// @param | y | integer | One-based cell Y coordinate.
        /// @return | number | Influence value at the requested cell.
        methods.add_method(
            "getInfluence",
            |_, this, (layer, x, y): (String, usize, usize)| {
                Ok(this.inner.borrow().get_influence(
                    &layer,
                    x.saturating_sub(1),
                    y.saturating_sub(1),
                ))
            },
        );
        // -- stampInfluence --
        /// Applies a radial influence stamp to a named layer in world coordinates.
        /// @param | layer | string | Layer name to modify.
        /// @param | wx | number | World X coordinate of the stamp center.
        /// @param | wy | number | World Y coordinate of the stamp center.
        /// @param | radius | number | Stamp radius in world units.
        /// @param | value | number | Influence value applied at the center.
        /// @param | falloff | number? | Falloff exponent or multiplier; defaults to 1.0.
        methods.add_method("stampInfluence", |_, this, (layer, wx, wy, radius, value, falloff): (String, f32, f32, f32, f32, Option<f32>)| {
                this.inner.borrow_mut().stamp_influence(
                    &layer,
                    wx,
                    wy,
                    radius,
                    value,
                    falloff.unwrap_or(1.0),
                );
                Ok(())
            },
        );
        // -- propagate --
        /// Propagates influence values across neighboring cells on a named layer.
        /// @param | layer | string | Layer name to propagate.
        /// @param | momentum | number? | Propagation momentum factor; defaults to 0.5.
        methods.add_method(
            "propagate",
            |_, this, (layer, momentum): (String, Option<f32>)| {
                this.inner
                    .borrow_mut()
                    .propagate(&layer, momentum.unwrap_or(0.5));
                Ok(())
            },
        );
        // -- decay --
        /// Multiplies a named layer by a decay factor.
        /// @param | layer | string | Layer name to decay.
        /// @param | factor | number | Decay factor applied to every cell.
        methods.add_method("decay", |_, this, (layer, factor): (String, f32)| {
            this.inner.borrow_mut().decay(&layer, factor);
            Ok(())
        });
        // -- clearLayer --
        /// Clears every value in a named influence layer.
        /// @param | layer | string | Layer name to clear.
        methods.add_method("clearLayer", |_, this, layer: String| {
            this.inner.borrow_mut().clear_layer(&layer);
            Ok(())
        });
        // -- clearAll --
        /// Clears every influence value in every layer.
        methods.add_method("clearAll", |_, this, ()| {
            this.inner.borrow_mut().clear_all();
            Ok(())
        });
        // -- getMaxPosition --
        /// Returns the cell position with the highest value on a named layer.
        /// @param | layer | string | Layer name to scan.
        /// @return | integer, integer | One-based X and Y cell coordinates of the maximum value.
        methods.add_method("getMaxPosition", |_, this, layer: String| {
            Ok(this.inner.borrow().max_position(&layer))
        });
        // -- getMinPosition --
        /// Returns the cell position with the lowest value on a named layer.
        /// @param | layer | string | Layer name to scan.
        /// @return | integer, integer | One-based X and Y cell coordinates of the minimum value.
        methods.add_method("getMinPosition", |_, this, layer: String| {
            Ok(this.inner.borrow().min_position(&layer))
        });
        // -- queryRect --
        /// Returns influence values inside a world-space rectangle on a named layer.
        /// @param | layer | string | Layer name to query.
        /// @param | wx | number | Rectangle X coordinate in world units.
        /// @param | wy | number | Rectangle Y coordinate in world units.
        /// @param | ww | number | Rectangle width in world units.
        /// @param | wh | number | Rectangle height in world units.
        /// @return | number[] | Array of influence samples from cells inside the rectangle.
        methods.add_method(
            "queryRect",
            |_, this, (layer, wx, wy, ww, wh): (String, f32, f32, f32, f32)| {
                Ok(this.inner.borrow().query_rect(&layer, wx, wy, ww, wh))
            },
        );
        // -- blend --
        /// Blends two source layers into a destination layer using independent weights.
        /// @param | layer_a | string | First source layer name.
        /// @param | weight_a | number | Weight applied to the first source layer.
        /// @param | layer_b | string | Second source layer name.
        /// @param | weight_b | number | Weight applied to the second source layer.
        /// @param | dest | string | Destination layer name that receives the blended values.
        methods.add_method("blend", |_, this, (layer_a, weight_a, layer_b, weight_b, dest): (String, f32, String, f32, String)| {
                this.inner.borrow_mut().blend(&layer_a, weight_a, &layer_b, weight_b, &dest);
                Ok(())
            },
        );
        // -- getWidth --
        /// Returns the influence map width in cells.
        /// @return | integer | Cell width of the map.
        methods.add_method("getWidth", |_, this, ()| Ok(this.inner.borrow().width));
        // -- getHeight --
        /// Returns the influence map height in cells.
        /// @return | integer | Cell height of the map.
        methods.add_method("getHeight", |_, this, ()| Ok(this.inner.borrow().height));
        // -- getCellSize --
        /// Returns the world size represented by each influence map cell.
        /// @return | number | Cell size in world units.
        methods.add_method("getCellSize", |_, this, ()| {
            Ok(this.inner.borrow().cell_size)
        });
        // -- type --
        /// Returns the Lua-visible type name for this influence map handle.
        /// @return | string | The string `LInfluenceMap`.
        methods.add_method("type", |_, _, ()| Ok("LInfluenceMap"));
        // -- typeOf --
        /// Returns whether this influence map handle matches a supported type name.
        /// @param | name | string | Type name to compare against `InfluenceMap` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LInfluenceMap" || name == "LObject")
        });
    }
}

/// Lua handle for slot-based context steering direction selection.
#[derive(Clone)]
struct LuaContextSteering {
    /// Shared context steering model containing directional slots and behavior weights.
    inner: Rc<RefCell<ContextSteering>>,
}
impl LuaUserData for LuaContextSteering {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- addSeekTarget --
        /// Adds a context steering target attraction.
        /// @param | tx | number | Target X position in world units.
        /// @param | ty | number | Target Y position in world units.
        /// @param | weight | number | Attraction weight.
        methods.add_method_mut(
            "addSeekTarget",
            |_, this, (tx, ty, weight): (f32, f32, f32)| {
                this.inner.borrow_mut().add_seek_target(tx, ty, weight);
                Ok(())
            },
        );
        // -- addWander --
        /// Adds wander noise to context steering.
        /// @param | jitter | number | Random steering jitter strength.
        /// @param | weight | number | Wander behavior weight.
        methods.add_method_mut("addWander", |_, this, (jitter, weight): (f32, f32)| {
            this.inner.borrow_mut().add_wander(jitter, weight);
            Ok(())
        });
        // -- addAvoidPoint --
        /// Adds a point avoidance influence to context steering.
        /// @param | x | number | Avoidance point X position.
        /// @param | y | number | Avoidance point Y position.
        /// @param | radius | number | Avoidance radius in world units.
        /// @param | weight | number | Avoidance behavior weight.
        methods.add_method_mut(
            "addAvoidPoint",
            |_, this, (x, y, radius, weight): (f32, f32, f32, f32)| {
                this.inner
                    .borrow_mut()
                    .add_avoid_point(x, y, radius, weight);
                Ok(())
            },
        );
        // -- addAvoidBounds --
        /// Adds rectangular bounds avoidance to context steering.
        /// @param | min_x | number | Minimum X bound.
        /// @param | min_y | number | Minimum Y bound.
        /// @param | max_x | number | Maximum X bound.
        /// @param | max_y | number | Maximum Y bound.
        /// @param | margin | number | Distance from bounds where avoidance begins.
        /// @param | weight | number | Avoidance behavior weight.
        methods.add_method_mut("addAvoidBounds", |_, this, (min_x, min_y, max_x, max_y, margin, weight): (f32, f32, f32, f32, f32, f32)| {
            this.inner.borrow_mut().add_avoid_bounds(min_x, min_y, max_x, max_y, margin, weight);
            Ok(())
        });
        // -- clearBehaviors --
        /// Removes all context steering behaviors.
        methods.add_method_mut("clearBehaviors", |_, this, ()| {
            this.inner.borrow_mut().clear_behaviors();
            Ok(())
        });
        // -- evaluate --
        /// Evaluates context steering and returns the selected movement direction.
        /// @param | ax | number | Agent X position.
        /// @param | ay | number | Agent Y position.
        /// @param | vx | number | Agent X velocity.
        /// @param | vy | number | Agent Y velocity.
        /// @return | number, number | Selected X and Y direction.
        methods.add_method_mut(
            "evaluate",
            |_, this, (ax, ay, vx, vy): (f32, f32, f32, f32)| {
                let (dx, dy) = this.inner.borrow_mut().evaluate(ax, ay, vx, vy);
                Ok((dx, dy))
            },
        );
        // -- chosenMagnitude --
        /// Returns the magnitude of the last selected context steering slot.
        /// @return | number | Last chosen magnitude.
        methods.add_method("chosenMagnitude", |_, this, ()| {
            Ok(this.inner.borrow().chosen_magnitude())
        });
        // -- slotCount --
        /// Returns the number of directional slots used by this context steering model.
        /// @return | integer | Direction slot count.
        methods.add_method("slotCount", |_, this, ()| {
            Ok(this.inner.borrow().slot_count() as i64)
        });
        // -- type --
        /// Returns the Lua-visible type name for this context steering handle.
        /// @return | string | The string `LContextSteering`.
        methods.add_method("type", |_, _, ()| Ok("LContextSteering"));
        // -- typeOf --
        /// Returns whether this context steering handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LContextSteering` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LContextSteering" || name == "LObject")
        });
    }
}

/// Lua handle for reciprocal velocity obstacle avoidance agents.
#[derive(Clone)]
struct LuaORCASolver {
    /// Shared ORCA solver containing agent state and time horizon settings.
    inner: Rc<RefCell<ORCASolver>>,
}
impl LuaUserData for LuaORCASolver {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- addAgent --
        /// Adds an ORCA avoidance agent and returns its zero-based solver index.
        /// @param | x | number | Initial X position.
        /// @param | y | number | Initial Y position.
        /// @param | radius | number | Collision radius.
        /// @param | max_speed | number | Maximum preferred speed.
        /// @return | integer | Zero-based ORCA agent index.
        methods.add_method_mut(
            "addAgent",
            |_, this, (x, y, radius, max_speed): (f32, f32, f32, f32)| {
                Ok(this
                    .inner
                    .borrow_mut()
                    .add_agent(ORCAAgent::new(x, y, radius, max_speed)) as i64)
            },
        );
        // -- setPreferredVelocity --
        /// Sets the preferred velocity for an ORCA agent by zero-based index.
        /// @param | idx | integer | Zero-based ORCA agent index.
        /// @param | pvx | number | Preferred X velocity.
        /// @param | pvy | number | Preferred Y velocity.
        methods.add_method_mut(
            "setPreferredVelocity",
            |_, this, (idx, pvx, pvy): (usize, f32, f32)| {
                if let Some(a) = this.inner.borrow_mut().agents.get_mut(idx) {
                    a.preferred_velocity = (pvx, pvy);
                }
                Ok(())
            },
        );
        // -- setPosition --
        /// Sets the position for an ORCA agent by zero-based index.
        /// @param | idx | integer | Zero-based ORCA agent index.
        /// @param | x | number | New X position.
        /// @param | y | number | New Y position.
        methods.add_method_mut("setPosition", |_, this, (idx, x, y): (usize, f32, f32)| {
            if let Some(a) = this.inner.borrow_mut().agents.get_mut(idx) {
                a.position = (x, y);
            }
            Ok(())
        });
        // -- compute --
        /// Computes safe velocities for all ORCA agents.
        /// @param | dt | number | Elapsed time in seconds for the avoidance step.
        methods.add_method_mut("compute", |_, this, dt: f32| {
            this.inner.borrow_mut().compute(dt);
            Ok(())
        });
        // -- getSafeVelocity --
        /// Returns the computed safe velocity for an ORCA agent.
        /// @param | idx | integer | Zero-based ORCA agent index.
        /// @return | number, number | Safe X and Y velocity, or zero velocity for an invalid index.
        methods.add_method("getSafeVelocity", |_, this, idx: usize| {
            let solver = this.inner.borrow();
            let v = solver
                .agents
                .get(idx)
                .map(|a| a.safe_velocity)
                .unwrap_or((0.0, 0.0));
            Ok((v.0, v.1))
        });
        // -- agentCount --
        /// Returns the number of ORCA agents in this solver.
        /// @return | integer | Current ORCA agent count.
        methods.add_method("agentCount", |_, this, ()| {
            Ok(this.inner.borrow().agent_count() as i64)
        });
        // -- type --
        /// Returns the Lua-visible type name for this ORCA solver handle.
        /// @return | string | The string `LORCASolver`.
        methods.add_method("type", |_, _, ()| Ok("LORCASolver"));
        // -- typeOf --
        /// Returns whether this ORCA solver handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LORCASolver` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LORCASolver" || name == "LObject")
        });
    }
}

fn path_provider_u32(provider: &LuaTable, name: &str, api: &str) -> LuaResult<u32> {
    provider
        .get::<_, Option<u32>>(name)?
        .ok_or_else(|| LuaError::RuntimeError(format!("{api}: provider.{name} is required")))
}

fn nav_grid_from_provider(provider: LuaTable, api: &str) -> LuaResult<NavGrid> {
    let width = require_positive_u32(path_provider_u32(&provider, "width", api)?, "width")?;
    let height = require_positive_u32(path_provider_u32(&provider, "height", api)?, "height")?;
    let mut grid = NavGrid::new(width, height);
    if let Some(mode) = provider.get::<_, Option<String>>("diagonalMode")? {
        let mode = DiagonalMode::from_lua_str(&mode).ok_or_else(|| {
            LuaError::RuntimeError(format!("{api}: unknown diagonalMode '{mode}'"))
        })?;
        grid.set_diagonal_mode(mode);
    }
    let costs = provider.get::<_, Option<LuaTable>>("costs")?;
    let blocked = provider.get::<_, Option<LuaTable>>("blocked")?;
    let get_cost = provider.get::<_, Option<LuaFunction>>("getCost")?;
    let is_blocked = provider.get::<_, Option<LuaFunction>>("isBlocked")?;
    let mut flat_index = 1usize;
    for y in 0..height {
        for x in 0..width {
            let mut cost = if let Some(costs) = &costs {
                costs.get::<_, Option<u8>>(flat_index)?.unwrap_or(1)
            } else if let Some(get_cost) = &get_cost {
                get_cost.call((provider.clone(), x + 1, y + 1))?
            } else {
                1
            };
            let cell_blocked = if let Some(blocked) = &blocked {
                blocked.get::<_, Option<bool>>(flat_index)?.unwrap_or(false)
            } else if let Some(is_blocked) = &is_blocked {
                is_blocked.call((provider.clone(), x + 1, y + 1))?
            } else {
                false
            };
            if cell_blocked {
                cost = 0;
            }
            grid.set_cost(x, y, cost);
            flat_index += 1;
        }
    }
    Ok(grid)
}

fn path_grid_from_provider(provider: LuaTable, api: &str) -> LuaResult<PathGrid> {
    let width = require_positive_usize(
        provider
            .get::<_, Option<usize>>("width")?
            .ok_or_else(|| LuaError::RuntimeError(format!("{api}: provider.width is required")))?,
        "width",
    )?;
    let height = require_positive_usize(
        provider
            .get::<_, Option<usize>>("height")?
            .ok_or_else(|| LuaError::RuntimeError(format!("{api}: provider.height is required")))?,
        "height",
    )?;
    let cell_size = require_positive_f32(
        provider.get::<_, Option<f32>>("cellSize")?.unwrap_or(1.0),
        "cellSize",
    )?;
    let mut grid = PathGrid::new(width, height, cell_size);
    let costs = provider.get::<_, Option<LuaTable>>("costs")?;
    let walkable = provider.get::<_, Option<LuaTable>>("walkable")?;
    let get_cost = provider.get::<_, Option<LuaFunction>>("getCost")?;
    let is_walkable = provider.get::<_, Option<LuaFunction>>("isWalkable")?;
    let mut flat_index = 1usize;
    for y in 0..height {
        for x in 0..width {
            if let Some(costs) = &costs {
                if let Some(cost) = costs.get::<_, Option<f32>>(flat_index)? {
                    grid.set_cost(x, y, cost);
                }
            } else if let Some(get_cost) = &get_cost {
                let cost: f32 = get_cost.call((provider.clone(), x + 1, y + 1))?;
                grid.set_cost(x, y, cost);
            }
            let passable = if let Some(walkable) = &walkable {
                walkable.get::<_, Option<bool>>(flat_index)?.unwrap_or(true)
            } else if let Some(is_walkable) = &is_walkable {
                is_walkable.call((provider.clone(), x + 1, y + 1))?
            } else {
                true
            };
            grid.set_walkable(x, y, passable);
            flat_index += 1;
        }
    }
    Ok(grid)
}

/// Registers the `lurek.pathfind` module.
pub fn register(lua: &Lua, lurek: &LuaTable, _state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let tbl = lua.create_table()?;
    // -- newNavGrid --
    /// Creates a navigation grid with the given dimensions.
    /// @param | width | integer | Grid width in cells.
    /// @param | height | integer | Grid height in cells.
    /// @return | LNavGrid | New navigation grid handle.
    tbl.set(
        "newNavGrid",
        lua.create_function(|_, (width, height): (u32, u32)| {
            let width = require_positive_u32(width, "width")?;
            let height = require_positive_u32(height, "height")?;
            Ok(LuaNavGrid {
                inner: Rc::new(RefCell::new(NavGrid::new(width, height))),
                abstract_graph: Rc::new(RefCell::new(None)),
            })
        })?,
    )?;

    // -- newNavGridFromProvider --
    /// Builds a navigation grid from a Lua provider table with width, height, optional costs/blocked arrays, or getCost/isBlocked callbacks.
    /// @param | provider | table | Lua-authored navigation-grid provider.
    /// @return | LNavGrid | New navigation grid copied from provider data.
    tbl.set(
        "newNavGridFromProvider",
        lua.create_function(|_, provider: LuaTable| {
            Ok(LuaNavGrid {
                inner: Rc::new(RefCell::new(nav_grid_from_provider(
                    provider,
                    "lurek.pathfind.newNavGridFromProvider",
                )?)),
                abstract_graph: Rc::new(RefCell::new(None)),
            })
        })?,
    )?;
    // -- newPathfinder --
    /// Creates a unit pathfinder for a navigation grid.
    /// @param | grid_ud | LNavGrid | Navigation grid to pathfind on.
    /// @return | LUnitPathfinder | New pathfinder handle.
    tbl.set(
        "newPathfinder",
        lua.create_function(|_, grid_ud: LuaAnyUserData| {
            let grid = grid_ud.borrow::<LuaNavGrid>()?;
            Ok(LuaUnitPathfinder {
                inner: Rc::new(RefCell::new(UnitPathfinder::new(grid.inner.clone()))),
            })
        })?,
    )?;
    // -- newFlowField --
    /// Creates a flow field for a navigation grid.
    /// @param | grid_ud | LNavGrid | Navigation grid to compute flow field from.
    /// @return | LFlowField | New flow field handle.
    tbl.set(
        "newFlowField",
        lua.create_function(|_, grid_ud: LuaAnyUserData| {
            let grid = grid_ud.borrow::<LuaNavGrid>()?;
            Ok(LuaFlowField {
                inner: Rc::new(RefCell::new(FlowField::new(grid.inner.clone()))),
            })
        })?,
    )?;
    // -- newPathGrid --
    /// Creates a cell-size path grid with given dimensions.
    /// @param | w | integer | Grid width in cells.
    /// @param | h | integer | Grid height in cells.
    /// @param | cell_size | number | World-space size of each cell.
    /// @return | LPathGrid | New path grid handle.
    tbl.set(
        "newPathGrid",
        lua.create_function(|_, (w, h, cell_size): (usize, usize, f32)| {
            let w = require_positive_usize(w, "w")?;
            let h = require_positive_usize(h, "h")?;
            let cell_size = require_positive_f32(cell_size, "cell_size")?;
            Ok(LuaPathGrid {
                inner: Rc::new(RefCell::new(PathGrid::new(w, h, cell_size))),
            })
        })?,
    )?;

    // -- newPathGridFromProvider --
    /// Builds a path grid from a Lua provider table with width, height, optional cellSize, costs/walkable arrays, or getCost/isWalkable callbacks.
    /// @param | provider | table | Lua-authored path-grid provider.
    /// @return | LPathGrid | New path grid copied from provider data.
    tbl.set(
        "newPathGridFromProvider",
        lua.create_function(|_, provider: LuaTable| {
            Ok(LuaPathGrid {
                inner: Rc::new(RefCell::new(path_grid_from_provider(
                    provider,
                    "lurek.pathfind.newPathGridFromProvider",
                )?)),
            })
        })?,
    )?;
    // -- newPathFlowField --
    /// Creates an AI flow field from a path grid.
    /// @param | grid_ud | LPathGrid | Path grid to compute AI flow field from.
    /// @return | LAIFlowField | New AI flow field handle.
    tbl.set(
        "newPathFlowField",
        lua.create_function(|_, grid_ud: LuaAnyUserData| {
            let grid = grid_ud.borrow::<LuaPathGrid>()?;
            let g = grid.inner.borrow();
            let walkable: Vec<bool> = (0..g.height)
                .flat_map(|y| (0..g.width).map(move |x| (x, y)))
                .map(|(x, y)| g.is_walkable(x, y))
                .collect();
            Ok(LuaAiFlowField {
                inner: Rc::new(RefCell::new(AiFlowField::new(g.width, g.height, walkable))),
            })
        })?,
    )?;
    // -- newSteeringManager --
    /// Creates an empty steering manager with support for built-in and custom movement behaviors.
    /// @return | LSteeringManager | New steering manager handle.
    tbl.set(
        "newSteeringManager",
        lua.create_function(|_, ()| {
            Ok(LuaSteeringManager {
                inner: Rc::new(RefCell::new(SteeringManager::new())),
                custom_callbacks: Rc::new(RefCell::new(CallbackRegistry::new())),
            })
        })?,
    )?;
    // -- newInfluenceMap --
    /// Creates a grid influence map with the supplied cell dimensions and world cell size.
    /// @param | w | integer | Map width in cells.
    /// @param | h | integer | Map height in cells.
    /// @param | cs | number | World size of one cell.
    /// @return | LInfluenceMap | New influence map handle.
    tbl.set(
        "newInfluenceMap",
        lua.create_function(|_, (w, h, cs): (usize, usize, f32)| {
            Ok(LuaInfluenceMap {
                inner: Rc::new(RefCell::new(InfluenceMap::new(w, h, cs))),
            })
        })?,
    )?;
    // -- newContextSteering --
    /// Creates a context steering model with the requested directional slot count.
    /// @param | slots | integer | Directional slot count; zero selects the engine default of 16.
    /// @return | LContextSteering | New context steering handle.
    tbl.set(
        "newContextSteering",
        lua.create_function(|_, slots: usize| {
            let slots = if slots == 0 { 16 } else { slots };
            Ok(LuaContextSteering {
                inner: Rc::new(RefCell::new(ContextSteering::new(slots))),
            })
        })?,
    )?;
    // -- newORCASolver --
    /// Creates an ORCA avoidance solver with the supplied prediction horizon.
    /// @param | time_horizon | number | Time horizon used when computing collision avoidance velocities.
    /// @return | LORCASolver | New ORCA solver handle.
    tbl.set(
        "newORCASolver",
        lua.create_function(|_, time_horizon: f32| {
            Ok(LuaORCASolver {
                inner: Rc::new(RefCell::new(ORCASolver::new(time_horizon))),
            })
        })?,
    )?;
    // -- setThreadCount --
    /// Sets the configured pathfinding worker-thread count.
    /// @param | count | integer | Desired thread count.
    tbl.set(
        "setThreadCount",
        lua.create_function(|_, count: u32| {
            let count = count.max(1);
            PATHFIND_THREAD_COUNT.store(count, Ordering::Relaxed);
            if let Some(pool) = PATHFIND_ASYNC_POOL.get() {
                let mut guard = pool.lock().unwrap_or_else(|e| e.into_inner());
                guard.set_thread_count(count as usize);
            }
            Ok(())
        })?,
    )?;
    // -- getThreadCount --
    /// Returns the configured pathfinding thread count.
    /// @return | integer | Thread count (minimum 1).
    tbl.set(
        "getThreadCount",
        lua.create_function(|_, ()| -> LuaResult<u32> {
            if let Some(pool) = PATHFIND_ASYNC_POOL.get() {
                let guard = pool.lock().unwrap_or_else(|e| e.into_inner());
                Ok(guard.get_thread_count() as u32)
            } else {
                Ok(PATHFIND_THREAD_COUNT.load(Ordering::Relaxed).max(1))
            }
        })?,
    )?;
    // -- submitAsyncPath --
    /// Queues an async path query against a navigation grid snapshot.
    /// @param | grid_ud | LNavGrid | Navigation grid to clone for the worker.
    /// @param | opts | table | Options with start/goal cells and optional owner, version, priority, unit size, and stream budget.
    /// @return | integer | Request id for polling and cancellation.
    tbl.set(
        "submitAsyncPath",
        lua.create_function(|_, (grid_ud, opts): (LuaAnyUserData, LuaTable)| {
            let grid = grid_ud.borrow::<LuaNavGrid>()?;
            let sx: u32 = opts.get("start_x")?;
            let sy: u32 = opts.get("start_y")?;
            let gx: u32 = opts.get("goal_x")?;
            let gy: u32 = opts.get("goal_y")?;
            let unit_size = opts.get::<_, Option<u32>>("unit_size")?.unwrap_or(1).max(1);
            let request_id = opts
                .get::<_, Option<u64>>("request_id")?
                .unwrap_or_else(|| NEXT_ASYNC_PATH_REQUEST_ID.fetch_add(1, Ordering::Relaxed));
            let owner_id = opts
                .get::<_, Option<u64>>("owner_id")?
                .unwrap_or(request_id);
            let version = opts.get::<_, Option<u64>>("version")?.unwrap_or(0);
            let priority = opts.get::<_, Option<i32>>("priority")?.unwrap_or(0);
            let stream_budget = opts.get::<_, Option<u32>>("stream_budget")?.unwrap_or(0);
            let request = AsyncPathRequest {
                id: request_id,
                owner_id,
                version,
                priority,
                grid: grid.inner.borrow().clone(),
                start: one_based_coords_u32(sx, sy, "start_x", "start_y")?,
                goal: one_based_coords_u32(gx, gy, "goal_x", "goal_y")?,
                unit_size,
                stream_budget,
            };
            with_async_pool(|pool| {
                let _ = pool.submit_query(request);
            });
            Ok(request_id)
        })?,
    )?;
    // -- pollAsyncPaths --
    /// Returns all currently available async path events without blocking.
    /// @return | table | Array of event tables with ids, status, optional path, and completion flags.
    tbl.set(
        "pollAsyncPaths",
        lua.create_function(|lua, ()| {
            let events = with_async_pool(|pool| pool.poll_events());
            let out = lua.create_table()?;
            for (i, event) in events.into_iter().enumerate() {
                out.set(i + 1, path_event_to_lua(lua, event)?)?;
            }
            Ok(out)
        })?,
    )?;
    // -- cancelAsyncPath --
    /// Marks an async path request as cancelled.
    /// @param | request_id | integer | Request id returned by `submitAsyncPath`.
    /// @return | boolean | Always true once the cancel marker is recorded.
    tbl.set(
        "cancelAsyncPath",
        lua.create_function(|_, request_id: u64| {
            with_async_pool(|pool| pool.cancel(request_id));
            Ok(true)
        })?,
    )?;
    // -- getAsyncPendingCount --
    /// Returns the number of async path requests that have not emitted a terminal event.
    /// @return | integer | Pending async request count.
    tbl.set(
        "getAsyncPendingCount",
        lua.create_function(|_, ()| Ok(with_async_pool(|pool| pool.pending_count())))?,
    )?;
    // -- clearAsyncPaths --
    /// Drops all queued async path requests and recreates the worker pool with the configured thread count.
    tbl.set(
        "clearAsyncPaths",
        lua.create_function(|_, ()| {
            with_async_pool(|pool| {
                *pool = PathThreadPool::new(
                    PATHFIND_THREAD_COUNT.load(Ordering::Relaxed).max(1) as usize
                );
            });
            Ok(())
        })?,
    )?;
    // -- newNavGridFromTileMap --
    /// Creates a navigation grid from a tilemap layer and blocked gid table.
    /// @param | tm_ud | LTileMap | Tilemap to derive navigation grid from.
    /// @param | layer_index | integer | One-based tilemap layer index.
    /// @param | blocked_table | table | Array of tile GIDs that should be blocked.
    /// @return | LNavGrid | New navigation grid handle.
    tbl.set(
        "newNavGridFromTileMap",
        lua.create_function(
            |_, (tm_ud, layer_index, blocked_table): (LuaAnyUserData, usize, mlua::Table)| {
                let tilemap_ud = tm_ud.borrow::<LuaTileMap>()?;
                let tm = tilemap_ud.inner.borrow();
                let layer_idx = one_based_to_zero_based_usize(layer_index, "layer_index")?;
                let (w, h) = tm.get_layer_dimensions(layer_idx).ok_or_else(|| {
                    LuaError::RuntimeError(format!("layer {} does not exist", layer_index))
                })?;
                let mut blocked: std::collections::HashSet<u32> = std::collections::HashSet::new();
                for v in blocked_table.sequence_values::<u32>() {
                    blocked.insert(v?);
                }
                let mut grid = NavGrid::new(w, h);
                for y in 0..h {
                    for x in 0..w {
                        let gid = tm.get_tile(layer_idx, x, y);
                        if blocked.contains(&gid) {
                            grid.set_cost(x, y, 0);
                        }
                    }
                }
                Ok(LuaNavGrid {
                    inner: Rc::new(RefCell::new(grid)),
                    abstract_graph: Rc::new(RefCell::new(None)),
                })
            },
        )?,
    )?;
    // -- newNavGridFromField --
    /// Creates a navigation grid from a tilefield level and channel.
    /// @param | field_ud | LTileField | Tilefield to derive navigation grid from.
    /// @param | opts | table? | Options with `level`, `channel`, `costChannel`, and `diagonalMode`.
    /// @return | LNavGrid | New navigation grid handle.
    tbl.set(
        "newNavGridFromField",
        lua.create_function(|_, (field_ud, opts): (LuaAnyUserData, Option<LuaTable>)| {
            let field_ud = field_ud.borrow::<LuaTileField>()?;
            let level = match &opts {
                Some(opts) => parse_tilefield_level(opts, "lurek.pathfind.newNavGridFromField")?,
                None => 0,
            };
            let channel = match &opts {
                Some(opts) => parse_tilefield_channel(
                    opts,
                    "channel",
                    "move",
                    "lurek.pathfind.newNavGridFromField",
                )?,
                None => TileChannel::Move,
            };
            let cost_channel = match &opts {
                Some(opts) => parse_tilefield_channel(
                    opts,
                    "costChannel",
                    channel.as_str(),
                    "lurek.pathfind.newNavGridFromField",
                )?,
                None => channel,
            };
            let diagonal_mode = match &opts {
                Some(opts) => opts.get::<_, Option<String>>("diagonalMode")?,
                None => None,
            };
            let field = field_ud.inner.borrow();
            let (width, height, levels) = field.size();
            if level >= levels {
                return Err(LuaError::RuntimeError(format!(
                    "lurek.pathfind.newNavGridFromField: level {} is out of bounds",
                    level + 1
                )));
            }
            let mut grid = NavGrid::new(width, height);
            if let Some(mode) = diagonal_mode {
                let dm = DiagonalMode::from_lua_str(&mode).ok_or_else(|| {
                    LuaError::RuntimeError(format!(
                        "lurek.pathfind.newNavGridFromField: invalid diagonalMode '{}'",
                        mode
                    ))
                })?;
                grid.set_diagonal_mode(dm);
            }
            for y in 0..height {
                for x in 0..width {
                    let coord = CellCoord { x, y, z: level };
                    if field.blocks(coord, channel) {
                        grid.set_cost(x, y, 0);
                    } else {
                        let cost = field.cost(coord, cost_channel).round().clamp(1.0, 254.0) as u8;
                        grid.set_cost(x, y, cost);
                    }
                }
            }
            Ok(LuaNavGrid {
                inner: Rc::new(RefCell::new(grid)),
                abstract_graph: Rc::new(RefCell::new(None)),
            })
        })?,
    )?;
    // -- newHexGrid --
    /// Creates a hex grid with the given dimensions.
    /// @param | width | integer | Grid width in hex columns.
    /// @param | height | integer | Grid height in hex rows.
    /// @param | layout_str | string? | Hex layout: `flat` (default) or `pointy`.
    /// @return | LHexGrid | New hex grid handle.
    tbl.set(
        "newHexGrid",
        lua.create_function(
            |_, (width, height, layout_str): (u32, u32, Option<String>)| {
                let layout = match layout_str.as_deref().unwrap_or("flat") {
                    "pointy" => HexLayout::PointyTop,
                    _ => HexLayout::FlatTop,
                };
                Ok(LuaHexGrid {
                    inner: Rc::new(RefCell::new(HexGrid::new(width, height, layout))),
                })
            },
        )?,
    )?;
    // -- newJpsGrid --
    /// Creates a Jump Point Search grid with given dimensions.
    /// @param | width | integer | Grid width in cells.
    /// @param | height | integer | Grid height in cells.
    /// @return | LJpsGrid | New JPS grid handle.
    tbl.set(
        "newJpsGrid",
        lua.create_function(|_, (width, height): (u32, u32)| {
            Ok(LuaJpsGrid {
                inner: Rc::new(RefCell::new(JpsGrid::new(width, height))),
            })
        })?,
    )?;
    // -- newNavMesh --
    /// Creates an empty navigation mesh for polygon-based pathfinding.
    /// @return | LNavMesh | New navmesh handle.
    tbl.set(
        "newNavMesh",
        lua.create_function(|_, ()| {
            Ok(LuaNavMesh {
                inner: Rc::new(RefCell::new(NavMesh::new())),
            })
        })?,
    )?;
    // -- rangeMap --
    /// Computes reachable cells from range map options.
    /// @param | opts | table | Options with dimensions, origin, budget, optional diagonal flag, costs, and blocked cells.
    /// @return | table | Range map result with `cells`, `width`, and `height` fields.
    /// @field | cells | table | Array of reachable cell tables, each with integer x, y and number cost fields.
    /// @field | width | integer | Grid width.
    /// @field | height | integer | Grid height.
    tbl.set(
        "rangeMap",
        lua.create_function(|lua, opts: LuaTable| {
            let width: u32 = opts.get("width")?;
            let height: u32 = opts.get("height")?;
            let ox: u32 = opts.get("origin_x")?;
            let oy: u32 = opts.get("origin_y")?;
            let budget: f32 = opts.get("budget")?;
            let width = require_positive_u32(width, "width")?;
            let height = require_positive_u32(height, "height")?;
            let (ox, oy) = one_based_coords_u32(ox, oy, "origin_x", "origin_y")?;
            let diagonal: bool = opts.get("diagonal").unwrap_or(false);
            let cost_n = (width * height) as usize;
            let mut costs_v = vec![1.0f32; cost_n];
            let mut blocked_v = vec![false; cost_n];
            if let Ok(ct) = opts.get::<_, LuaTable>("costs") {
                for (i, v) in ct.sequence_values::<f32>().enumerate() {
                    if i < cost_n {
                        costs_v[i] = v?;
                    }
                }
            }
            if let Ok(bt) = opts.get::<_, LuaTable>("blocked") {
                for (i, v) in bt.sequence_values::<bool>().enumerate() {
                    if i < cost_n {
                        blocked_v[i] = v?;
                    }
                }
            }
            let rm = RangeMap::from_grid(
                width, height, &costs_v, &blocked_v, ox, oy, budget, diagonal,
            );
            let cells_tbl = lua.create_table()?;
            let mut count = 0;
            for (x, y, cost) in rm.reachable_cells_with_cost() {
                let ct = lua.create_table()?;
                /// The 'x' field value exposed to Lua scripts.
                ct.set("x", x + 1)?;
                /// The 'y' field value exposed to Lua scripts.
                ct.set("y", y + 1)?;
                /// Performs the 'cost' operation.
                ct.set("cost", cost)?;
                count += 1;
                cells_tbl.set(count, ct)?;
            }
            let out = lua.create_table()?;
            /// Performs the 'cells' operation.
            out.set("cells", cells_tbl)?;
            /// Performs the 'width' operation.
            out.set("width", width)?;
            /// Performs the 'height' operation.
            out.set("height", height)?;
            Ok(out)
        })?,
    )?;
    // -- rangeMapFromField --
    /// Computes reachable cells from a tilefield level and movement channel.
    /// @param | field_ud | LTileField | Tilefield to read.
    /// @param | opts | table | Options with `origin`, `budget`, optional `level`, `channel`, `costChannel`, and `diagonal`.
    /// @return | table | Range map result with `cells`, `width`, `height`, and `level`.
    tbl.set(
        "rangeMapFromField",
        lua.create_function(|lua, (field_ud, opts): (LuaAnyUserData, LuaTable)| {
            let field_ud = field_ud.borrow::<LuaTileField>()?;
            let origin_tbl: LuaTable = opts.get("origin")?;
            let ox: u32 = origin_tbl.get("x")?;
            let oy: u32 = origin_tbl.get("y")?;
            let oz: u32 = origin_tbl
                .get::<_, Option<u32>>("z")?
                .or(opts.get::<_, Option<u32>>("level")?)
                .unwrap_or(1);
            let origin_x = one_based_to_zero_based(ox, "origin.x")?;
            let origin_y = one_based_to_zero_based(oy, "origin.y")?;
            let level = one_based_to_zero_based(oz, "origin.z")?;
            let budget: f32 = opts.get("budget")?;
            let budget = require_positive_f32(budget, "budget")?;
            let diagonal: bool = opts.get("diagonal").unwrap_or(false);
            let channel = parse_tilefield_channel(
                &opts,
                "channel",
                "move",
                "lurek.pathfind.rangeMapFromField",
            )?;
            let cost_channel = parse_tilefield_channel(
                &opts,
                "costChannel",
                channel.as_str(),
                "lurek.pathfind.rangeMapFromField",
            )?;
            let field = field_ud.inner.borrow();
            let (width, height, levels) = field.size();
            if level >= levels {
                return Err(LuaError::RuntimeError(format!(
                    "lurek.pathfind.rangeMapFromField: level {} is out of bounds",
                    level + 1
                )));
            }
            let len = (width * height) as usize;
            let mut costs = vec![1.0f32; len];
            let mut blocked = vec![false; len];
            for y in 0..height {
                for x in 0..width {
                    let idx = (y * width + x) as usize;
                    let coord = CellCoord { x, y, z: level };
                    blocked[idx] = field.blocks(coord, channel);
                    costs[idx] = field.cost(coord, cost_channel).max(0.0);
                }
            }
            let rm = RangeMap::from_grid(
                width, height, &costs, &blocked, origin_x, origin_y, budget, diagonal,
            );
            let cells_tbl = lua.create_table()?;
            for (i, (x, y, cost)) in rm.reachable_cells_with_cost().into_iter().enumerate() {
                let cell = lua.create_table()?;
                cell.set("x", x + 1)?;
                cell.set("y", y + 1)?;
                cell.set("z", level + 1)?;
                cell.set("cost", cost)?;
                cells_tbl.set(i + 1, cell)?;
            }
            let out = lua.create_table()?;
            out.set("cells", cells_tbl)?;
            out.set("width", width)?;
            out.set("height", height)?;
            out.set("level", level + 1)?;
            Ok(out)
        })?,
    )?;
    // -- newGoalMap --
    /// Creates a new multi-source Dijkstra distance-field goal map for the given grid dimensions.
    /// @param | width  | integer | Grid width in cells.
    /// @param | height | integer | Grid height in cells.
    /// @return | LGoalMap | New goal map ready for source registration and baking.
    tbl.set(
        "newGoalMap",
        lua.create_function(|_, (width, height): (u32, u32)| {
            let width = require_positive_u32(width, "width")?;
            let height = require_positive_u32(height, "height")?;
            Ok(LuaGoalMap {
                inner: RefCell::new(GoalMap::new(width, height)),
                blocker_key: RefCell::new(None),
            })
        })?,
    )?;
    /// Performs the 'pathfind' operation.
    lurek.set("pathfind", tbl)?;
    Ok(())
}

/// Lua-side wrapper for a multi-source Dijkstra distance-field (goal map).
pub struct LuaGoalMap {
    /// Owned goal map data.
    inner: RefCell<GoalMap>,
    /// Optional Lua blocker predicate (registry key).
    blocker_key: RefCell<Option<LuaRegistryKey>>,
}

/// Provides `newGoalMap` methods: addSource, bake, distanceAt, gradientAt, flee, floodFill, save, restore.
impl LuaUserData for LuaGoalMap {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- addSource --
        /// Registers a source cell for this goal map. Coordinates are one-based.
        /// @param | x      | integer  | One-based column.
        /// @param | y      | integer  | One-based row.
        /// @param | weight | integer? | Relative weight (default 1). Lower = stronger pull.
        methods.add_method(
            "addSource",
            |_, this, (x, y, weight): (u32, u32, Option<u32>)| {
                let xz = one_based_to_zero_based(x, "x")?;
                let yz = one_based_to_zero_based(y, "y")?;
                this.inner
                    .borrow_mut()
                    .add_source(xz, yz, weight.unwrap_or(1));
                Ok(())
            },
        );

        // -- setSources --
        /// Replaces all registered source cells. Each entry must have x, y (one-based) and optional weight.
        /// @param | sources | table | Array of `{x, y, weight?}` tables.
        methods.add_method("setSources", |_, this, sources: LuaTable| {
            let mut gs = Vec::new();
            for v in sources.sequence_values::<LuaTable>() {
                let t = v?;
                let x: u32 = t.get("x")?;
                let y: u32 = t.get("y")?;
                let w: u32 = t.get::<_, Option<u32>>("weight")?.unwrap_or(1);
                gs.push(GoalSource {
                    x: one_based_to_zero_based(x, "x")?,
                    y: one_based_to_zero_based(y, "y")?,
                    weight: w.max(1),
                });
            }
            this.inner.borrow_mut().set_sources(gs);
            Ok(())
        });

        // -- clearSources --
        /// Removes all registered source cells.
        methods.add_method("clearSources", |_, this, ()| {
            this.inner.borrow_mut().clear_sources();
            Ok(())
        });

        // -- setBlocker --
        /// Sets a Lua predicate called during `bake` to determine blocked cells.
        /// @param | fn | function | `fn(x: integer, y: integer) -> boolean` (one-based).
        methods.add_method("setBlocker", |lua, this, f: LuaFunction| {
            if let Some(old) = this.blocker_key.borrow_mut().take() {
                lua.remove_registry_value(old)?;
            }
            *this.blocker_key.borrow_mut() = Some(lua.create_registry_value(f)?);
            Ok(())
        });

        // -- bake --
        /// Runs multi-source Dijkstra to build the distance field using the registered blocker.
        methods.add_method("bake", |lua, this, ()| {
            let blocker_key = this.blocker_key.borrow();
            if let Some(ref key) = *blocker_key {
                let f: LuaFunction = lua.registry_value(key)?;
                let w = this.inner.borrow().width();
                let h = this.inner.borrow().height();
                // Pre-compute blocker table to avoid Lua calls inside tight Rust loop.
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
                    .bake(&|x, y| blocked[(y * w + x) as usize]);
            } else {
                this.inner.borrow_mut().bake(&|_, _| false);
            }
            Ok(())
        });

        // -- isReady --
        /// Returns true when the distance field has been baked and not invalidated.
        /// @return | boolean | True when the field is ready for queries.
        methods.add_method("isReady", |_, this, ()| Ok(!this.inner.borrow().is_dirty()));

        // -- distanceAt --
        /// Returns the minimum cost from (x, y) to the nearest source.
        /// Returns the maximum integer value when unreachable.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @return | integer | Distance value; max-int means unreachable.
        methods.add_method("distanceAt", |_, this, (x, y): (u32, u32)| {
            let xz = one_based_to_zero_based(x, "x")?;
            let yz = one_based_to_zero_based(y, "y")?;
            Ok(this.inner.borrow().distance_at(xz, yz))
        });

        // -- gradientAt --
        /// Returns a normalised direction vector pointing toward the nearest source.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @return | number | dx component.
        /// @return | number | dy component.
        methods.add_method("gradientAt", |_, this, (x, y): (u32, u32)| {
            let xz = one_based_to_zero_based(x, "x")?;
            let yz = one_based_to_zero_based(y, "y")?;
            Ok(this.inner.borrow().gradient_at(xz, yz))
        });

        // -- flee --
        /// Returns a normalised direction vector pointing away from sources (for fleeing NPCs).
        /// @param | x    | integer | One-based column.
        /// @param | y    | integer | One-based row.
        /// @param | fear | number? | Scale factor (default 1.0).
        /// @return | number | dx component.
        /// @return | number | dy component.
        methods.add_method("flee", |_, this, (x, y, fear): (u32, u32, Option<f32>)| {
            let xz = one_based_to_zero_based(x, "x")?;
            let yz = one_based_to_zero_based(y, "y")?;
            Ok(this.inner.borrow().flee_at(xz, yz, fear.unwrap_or(1.0)))
        });

        // -- floodFill --
        /// Returns all cells reachable from (cx, cy) within `threshold` steps.
        /// @param | cx        | integer | One-based center column.
        /// @param | cy        | integer | One-based center row.
        /// @param | threshold | integer | Maximum distance to include.
        /// @return | table | Array of `{x, y}` tables (one-based).
        methods.add_method(
            "floodFill",
            |lua, this, (cx, cy, threshold): (u32, u32, u32)| {
                let cxz = one_based_to_zero_based(cx, "cx")?;
                let cyz = one_based_to_zero_based(cy, "cy")?;
                let cells = this.inner.borrow().flood_fill(cxz, cyz, threshold);
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
            },
        );

        // -- save --
        /// Serialises the current distance field to a binary blob string.
        /// @return | string | Serialised blob.
        methods.add_method("save", |lua, this, ()| {
            lua.create_string(this.inner.borrow().save())
        });

        // -- restore --
        /// Restores a distance field from a blob produced by `save`.
        /// @param | blob | string | Serialised blob.
        methods.add_method("restore", |_, this, blob: LuaString| {
            this.inner
                .borrow_mut()
                .restore(blob.as_bytes())
                .map_err(LuaError::external)
        });

        // -- type --
        /// Returns the Lua-visible type name for this goal map handle.
        /// @return | string | The string `LGoalMap`.
        methods.add_method("type", |_, _, ()| Ok("LGoalMap"));

        // -- typeOf --
        /// Returns whether this goal map handle matches a supported type name.
        /// @param | name | string | Type name to check.
        /// @return | boolean | True when the name matches.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LGoalMap" || name == "LObject")
        });
    }
}
