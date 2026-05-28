//! `lurek.scene` — Stack-based scene management with animated transitions, overlay support, shared data passing, lifecycle callbacks (enter/leave/pause/resume/ready/update/draw/render), and depth-sorted rendering via `LDepthSorter`.
//!
//! - Registers `lurek.scene.*` functions and types via `register()`.
//! - `LuaDepthSorter`: userdata type exposed to Lua.
//! - Bridges 70 Lua-callable methods via `mlua`.
//! - See `docs/specs/scene.md` for the full API specification.

use super::SharedState;
use crate::scene::depth_sorter::DepthSorter;
use crate::scene::stack::{SceneId, SceneStack};
use crate::scene::transition::{EasingType, TransitionType};
use mlua::prelude::*;
use std::cell::RefCell;
use std::collections::{HashMap, HashSet};
use std::rc::Rc;

/// Internal per-module state holding the scene stack, Lua registry references for scene tables, shared data slots, and preload/deferred-loading bookkeeping.
struct SceneState {
    stack: SceneStack,
    scene_refs: HashMap<SceneId, LuaRegistryKey>,
    data_refs: HashMap<String, LuaRegistryKey>,
    scene_ready_pending: HashSet<SceneId>,
    preload_callbacks: HashMap<String, LuaRegistryKey>,
    preloaded_names: HashSet<String>,
}
/// Invoke a named lifecycle method (e.g. `enter`, `leave`, `update`) directly on a scene table.
fn call_scene_table_method<'a>(
    table: LuaTable<'a>,
    method: &str,
    args: impl IntoLuaMulti<'a>,
) -> LuaResult<()> {
    if let Ok(func) = table.get::<_, LuaFunction>(method) {
        func.call::<_, ()>((table.clone(), args))?;
    }
    Ok(())
}

/// Resolve a scene id from an optional target selector:
/// - nil: current top scene (see lurek Lua API reference for details).
/// - string: registered scene name
/// - integer: 1-based stack index (bottom=1)
fn resolve_target_scene_id(state: &SceneState, target: Option<LuaValue>) -> Option<SceneId> {
    match target {
        None | Some(LuaValue::Nil) => state.stack.get_current(),
        Some(LuaValue::String(name)) => name
            .to_str()
            .ok()
            .and_then(|n| state.stack.get_registered(n)),
        Some(LuaValue::Integer(idx)) if idx > 0 => {
            let index = (idx as usize) - 1;
            state.stack.get_all().get(index).copied()
        }
        _ => None,
    }
}
/// Depth sorter exposed to Lua as `LDepthSorter`. Collects draw callbacks or drawable objects with numeric depth values and flushes them in back-to-front order for correct painter's-algorithm rendering. Ideal for sorting sprites, particles, and layered game objects within a single scene.
pub struct LuaDepthSorter {
    inner: Rc<RefCell<DepthSorter>>,
    callbacks: Rc<RefCell<Vec<LuaRegistryKey>>>,
}
impl LuaUserData for LuaDepthSorter {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- add --
        /// Register a draw callback at a given depth value. When `flush` is called, all registered callbacks execute in back-to-front order (lowest depth drawn first, highest depth drawn last / on top). Use this for simple draw calls like sprite rendering where each entity has a depth/z-layer.
        /// @param | callback | function | A zero-argument draw function invoked during flush.
        /// @param | depth | number | Numeric z-depth controlling draw order — lower values are drawn behind higher values.
        methods.add_method("add", |lua, this, (callback, depth): (LuaFunction, f32)| {
            let key = lua.create_registry_value(callback)?;
            let mut cbs = this.callbacks.borrow_mut();
            let index = cbs.len();
            cbs.push(key);
            this.inner.borrow_mut().add(index, depth);
            Ok(())
        });
        // -- addObject --
        /// Register a game object table for depth-sorted rendering. The object must expose a numeric `depth` field and a `drawSorted(self)` method. During `flush`, each object's `drawSorted` is called in depth order, making this ideal for entity-based architectures where objects manage their own drawing.
        /// @param | obj | table | A game object table with a numeric `depth` field and a `drawSorted(self)` method.
        methods.add_method("addObject", |lua, this, obj: LuaTable| {
            let depth: f32 = obj.get::<_, f32>("depth").unwrap_or(0.0);
            let key = lua.create_registry_value(obj)?;
            let mut cbs = this.callbacks.borrow_mut();
            let index = cbs.len();
            cbs.push(key);
            this.inner.borrow_mut().add_object(index, depth);
            Ok(())
        });
        // -- sort --
        /// Sort all registered entries by depth without executing any callbacks. Call this only if you need to inspect the sorted order before drawing; `flush` already sorts automatically.
        methods.add_method("sort", |_, this, ()| {
            this.inner.borrow_mut().sort();
            Ok(())
        });
        // -- flush --
        /// Sort all entries by depth, execute every callback or object's `drawSorted` method in back-to-front order, then clear the sorter for the next frame. This is the standard one-call render path — call it once per frame inside your scene's `draw` or `render` callback.
        methods.add_method("flush", |lua, this, ()| {
            enum PendingDepthCall<'lua> {
                Function(LuaFunction<'lua>),
                Object(LuaTable<'lua>, LuaFunction<'lua>),
            }

            let entries: Vec<(usize, bool)> = {
                let mut sorter = this.inner.borrow_mut();
                sorter
                    .sorted_entries()
                    .iter()
                    .map(|e| (e.callback_index, e.is_object))
                    .collect()
            };
            let pending_calls = {
                let cbs = this.callbacks.borrow();
                let mut pending = Vec::new();
                for (idx, is_object) in &entries {
                    if let Some(key) = cbs.get(*idx) {
                        if *is_object {
                            if let Ok(obj) = lua.registry_value::<LuaTable>(key) {
                                if let Ok(func) = obj.get::<_, LuaFunction>("drawSorted") {
                                    pending.push(PendingDepthCall::Object(obj, func));
                                }
                            }
                        } else if let Ok(func) = lua.registry_value::<LuaFunction>(key) {
                            pending.push(PendingDepthCall::Function(func));
                        }
                    }
                }
                pending
            };
            for pending_call in pending_calls {
                match pending_call {
                    PendingDepthCall::Function(func) => {
                        let _ = func.call::<_, ()>(());
                    }
                    PendingDepthCall::Object(obj, func) => {
                        let _ = func.call::<_, ()>(obj);
                    }
                }
            }
            this.inner.borrow_mut().clear();
            this.callbacks.borrow_mut().clear();
            Ok(())
        });
        // -- setStable --
        /// Enable or disable stable sorting. When stable, items sharing the same depth value retain their insertion order, which prevents visual flickering between overlapping sprites at the same layer. Unstable sort is slightly faster but may swap equal-depth items between frames.
        /// @param | stable | boolean | True for stable sort (deterministic order at equal depth), false for unstable (faster but may flicker).
        methods.add_method("setStable", |_, this, stable: bool| {
            this.inner.borrow_mut().set_stable(stable);
            Ok(())
        });
        // -- isStable --
        /// Returns whether the sorter uses stable sorting.
        /// @return | boolean | True if stable sort is enabled.
        methods.add_method("isStable", |_, this, ()| {
            Ok(this.inner.borrow().is_stable())
        });
        // -- clear --
        /// Discard all pending entries without executing any draw callbacks. Use this when a scene is interrupted, reset, or destroyed before its normal `flush` call.
        methods.add_method("clear", |_, this, ()| {
            this.inner.borrow_mut().clear();
            this.callbacks.borrow_mut().clear();
            Ok(())
        });
        // -- getCount --
        /// Returns the number of draw entries currently queued for the next `flush` call. Useful for debugging or deciding whether to skip an empty render pass.
        /// @return | number | Count of pending draw entries.
        methods.add_method("getCount", |_, this, ()| {
            Ok(this.inner.borrow().get_count())
        });
        // -- type --
        /// Returns the type name string `"LDepthSorter"`.
        /// @return | string | The literal `"LDepthSorter"`.
        methods.add_method("type", |_, _, ()| Ok("LDepthSorter"));
        // -- typeOf --
        /// Check whether this object matches a given type name. Accepts `"LDepthSorter"` or `"Object"`.
        /// @param | name | string | The type name to test against.
        /// @return | boolean | True if the name matches.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LDepthSorter" || name == "Object")
        });
    }
}
/// Register the `lurek.scene` module table, all scene-stack functions, transition helpers, shared data API, and the `LDepthSorter` factory.
pub fn register(lua: &Lua, lurek: &LuaTable, _state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let tbl = lua.create_table()?;
    let state = Rc::new(RefCell::new(SceneState {
        stack: SceneStack::new(),
        scene_refs: HashMap::new(),
        data_refs: HashMap::new(),
        scene_ready_pending: HashSet::new(),
        preload_callbacks: HashMap::new(),
        preloaded_names: HashSet::new(),
    }));
    // -- push --
    /// Push a new scene onto the stack, making it the active scene. The previously-active scene receives its `pause()` lifecycle callback and the new scene receives `enter(self, params)`. An optional visual transition (fade, slide, iris, etc.) animates between the two scenes over the specified duration.
    /// @param | scene | table | A scene table with lifecycle methods (`enter`, `leave`, `pause`, `resume`, `update`, `draw`, etc.).
    /// @param | transition | string? | Transition type name: `"fade"`, `"slideleft"`, `"slideright"`, `"slideup"`, `"slidedown"`, `"wipe"`, `"iris"`, `"zoom"`, `"crossfade"`. Defaults to `"none"`.
    /// @param | duration | number? | Transition animation duration in seconds. Defaults to 0 (instant).
    /// @param | easing | string? | Easing curve name (e.g. `"linear"`, `"ease_in"`, `"ease_out"`, `"ease_in_out"`). Defaults to `"linear"`.
    /// @param | params | table? | Arbitrary data forwarded to the new scene's `enter(self, params)` callback for initialization.
    let st = state.clone();
    tbl.set(
        "push",
        lua.create_function(
            move |lua,
                  (scene, transition, duration, easing, params): (
                LuaTable,
                Option<String>,
                Option<f32>,
                Option<String>,
                Option<LuaValue>,
            )| {
                let trans = transition
                    .as_deref()
                    .map(TransitionType::from_lua_str)
                    .unwrap_or(TransitionType::None);
                let dur = duration.unwrap_or(0.0);
                let eas = easing
                    .as_deref()
                    .map(EasingType::from_lua_str)
                    .unwrap_or_default();
                let params_arg = params.unwrap_or(LuaValue::Nil);
                let (prev_table, new_table) = {
                    let mut s = st.borrow_mut();
                    let scene_id = s.stack.next_scene_id();
                    let key = lua.create_registry_value(scene)?;
                    let prev_id = s.stack.push(scene_id, trans, dur, eas);
                    let prev_table = prev_id
                        .and_then(|pid| s.scene_refs.get(&pid))
                        .and_then(|prev_key| lua.registry_value::<LuaTable>(prev_key).ok());
                    s.scene_refs.insert(scene_id, key);
                    s.scene_ready_pending.insert(scene_id);
                    let new_table = s
                        .scene_refs
                        .get(&scene_id)
                        .and_then(|new_key| lua.registry_value::<LuaTable>(new_key).ok());
                    (prev_table, new_table)
                };
                if let Some(prev_table) = prev_table {
                    let _ = call_scene_table_method(prev_table, "pause", ());
                }
                if let Some(new_table) = new_table {
                    let _ = call_scene_table_method(new_table, "enter", params_arg);
                }
                Ok(())
            },
        )?,
    )?;
    let st = state.clone();
    // -- pop --
    /// Pop the top scene off the stack and return to the previous one. The popped scene receives `leave()` and the revealed scene receives `resume()` (unless the popped scene was an overlay, in which case the underlying scene was never paused). Use this for "back" navigation, closing menus, or exiting sub-screens.
    /// @param | transition | string? | Transition type name. Defaults to `"none"` (instant).
    /// @param | duration | number? | Transition animation duration in seconds. Defaults to 0.
    /// @param | easing | string? | Easing curve name. Defaults to `"linear"`.
    tbl.set("pop", lua.create_function(
            move |lua, (transition, duration, easing): (Option<String>, Option<f32>, Option<String>)| {
                let trans = transition
                    .as_deref()
                    .map(TransitionType::from_lua_str)
                    .unwrap_or(TransitionType::None);
                let dur = duration.unwrap_or(0.0);
                let eas = easing.as_deref().map(EasingType::from_lua_str).unwrap_or_default();
                let (popped_table, revealed_table) = {
                    let mut s = st.borrow_mut();
                    let was_overlay = s
                        .stack
                        .get_current()
                        .map(|id| s.stack.is_overlay(id))
                        .unwrap_or(false);
                    let (popped_id, revealed_id) =
                        s.stack.pop(trans, dur, eas).map_err(LuaError::RuntimeError)?;
                    let popped_table = s
                        .scene_refs
                        .remove(&popped_id)
                        .and_then(|popped_key| lua.registry_value::<LuaTable>(&popped_key).ok());
                    let revealed_table = if was_overlay {
                        None
                    } else {
                        revealed_id
                            .and_then(|rid| s.scene_refs.get(&rid))
                            .and_then(|revealed_key| lua.registry_value::<LuaTable>(revealed_key).ok())
                    };
                    (popped_table, revealed_table)
                };
                if let Some(popped_table) = popped_table {
                    let _ = call_scene_table_method(popped_table, "leave", ());
                }
                if let Some(revealed_table) = revealed_table {
                    let _ = call_scene_table_method(revealed_table, "resume", ());
                }
                Ok(())
            },
        )?,
    )?;
    // -- switchTo --
    /// Replace the current top scene with a different one without changing stack depth. The old scene receives `leave()` and the new scene receives `enter(self, params)`. Unlike `push`, no scene is added to the stack — the old scene is removed and the new one takes its slot. Ideal for transitioning between peer-level game states (e.g. level 1 → level 2).
    /// @param | scene | table | The replacement scene table.
    /// @param | transition | string? | Transition type name. Defaults to `"none"`.
    /// @param | duration | number? | Transition animation duration in seconds. Defaults to 0.
    /// @param | easing | string? | Easing curve name. Defaults to `"linear"`.
    /// @param | params | table? | Arbitrary data forwarded to the new scene's `enter(self, params)` callback.
    let st = state.clone();
    tbl.set(
        "switchTo",
        lua.create_function(
            move |lua,
                  (scene, transition, duration, easing, params): (
                LuaTable,
                Option<String>,
                Option<f32>,
                Option<String>,
                Option<LuaValue>,
            )| {
                let trans = transition
                    .as_deref()
                    .map(TransitionType::from_lua_str)
                    .unwrap_or(TransitionType::None);
                let dur = duration.unwrap_or(0.0);
                let eas = easing
                    .as_deref()
                    .map(EasingType::from_lua_str)
                    .unwrap_or_default();
                let params_arg = params.unwrap_or(LuaValue::Nil);
                let (old_table, new_table) = {
                    let mut s = st.borrow_mut();
                    let scene_id = s.stack.next_scene_id();
                    let key = lua.create_registry_value(scene)?;
                    let old_id = s.stack.switch_to(scene_id, trans, dur, eas);
                    let old_table = old_id
                        .and_then(|oid| s.scene_refs.remove(&oid))
                        .and_then(|old_key| lua.registry_value::<LuaTable>(&old_key).ok());
                    s.scene_refs.insert(scene_id, key);
                    s.scene_ready_pending.insert(scene_id);
                    let new_table = s
                        .scene_refs
                        .get(&scene_id)
                        .and_then(|new_key| lua.registry_value::<LuaTable>(new_key).ok());
                    (old_table, new_table)
                };
                if let Some(old_table) = old_table {
                    let _ = call_scene_table_method(old_table, "leave", ());
                }
                if let Some(new_table) = new_table {
                    let _ = call_scene_table_method(new_table, "enter", params_arg);
                }
                Ok(())
            },
        )?,
    )?;
    // -- clear --
    /// Remove all scenes from the stack. Each removed scene receives its `leave()` callback in stack order. After this call the stack is empty and `isEmpty()` returns true. Useful for returning to a title screen or tearing down the entire scene graph.
    let st = state.clone();
    tbl.set(
        "clear",
        lua.create_function(move |lua, ()| {
            let removed_tables = {
                let mut s = st.borrow_mut();
                let removed = s.stack.clear();
                let mut tables = Vec::with_capacity(removed.len());
                for id in &removed {
                    if let Some(scene_key) = s.scene_refs.remove(id) {
                        if let Ok(table) = lua.registry_value::<LuaTable>(&scene_key) {
                            tables.push(table);
                        }
                    }
                }
                tables
            };
            for table in removed_tables {
                let _ = call_scene_table_method(table, "leave", ());
            }
            Ok(())
        })?,
    )?;
    // -- popTo --
    /// Pop scenes off the stack until the named registered scene is on top. Every popped scene receives `leave()` and the target scene receives `resume()`. The target scene must have been previously added via `registerScene`. Returns false if no scene with that name exists on the stack.
    /// @param | name | string | The registered name of the target scene to unwind to.
    /// @return | boolean | True if the named scene was found and is now the active top scene, false if the name was not found.
    let st = state.clone();
    tbl.set(
        "popTo",
        lua.create_function(move |lua, name: String| {
            let (found, popped_tables, resumed_table) = {
                let mut s = st.borrow_mut();
                let target_id = match s.stack.pop_to(&name) {
                    Some(id) => id,
                    None => return Ok(false),
                };
                let popped_ids = s.stack.pop_until(target_id);
                let mut popped_tables = Vec::with_capacity(popped_ids.len());
                for id in &popped_ids {
                    if let Some(scene_key) = s.scene_refs.remove(id) {
                        if let Ok(table) = lua.registry_value::<LuaTable>(&scene_key) {
                            popped_tables.push(table);
                        }
                    }
                }
                let resumed_table = s
                    .stack
                    .get_current()
                    .and_then(|id| s.scene_refs.get(&id))
                    .and_then(|top_key| lua.registry_value::<LuaTable>(top_key).ok());
                (true, popped_tables, resumed_table)
            };
            if !found {
                return Ok(false);
            }
            for table in popped_tables {
                let _ = call_scene_table_method(table, "leave", ());
            }
            if let Some(table) = resumed_table {
                let _ = call_scene_table_method(table, "resume", ());
            }
            Ok(true)
        })?,
    )?;
    // -- update --
    /// Advance any active transition animation and call `update(self, dt)` on the current top scene.
    /// Execution can be frozen per scene via `setUpdateEnabled`.
    /// @param | dt | number | Delta time in seconds since the last frame (e.g. from `lurek.timer.getDelta()`).
    let st = state.clone();
    tbl.set(
        "update",
        lua.create_function(move |lua, dt: f32| {
            let top_table = {
                let mut s = st.borrow_mut();
                s.stack.update_transition(dt);
                s.stack.get_current().and_then(|top_id| {
                    if !s.stack.is_update_enabled(top_id) {
                        return None;
                    }
                    s.scene_refs
                        .get(&top_id)
                        .and_then(|top_key| lua.registry_value::<LuaTable>(top_key).ok())
                })
            };
            if let Some(top_table) = top_table {
                let _ = call_scene_table_method(top_table, "update", dt);
            }
            Ok(())
        })?,
    )?;
    // -- process --
    /// Call `ready(self)` once on newly-pushed scenes, then call `process(self, dt)` on every process-active scene ordered by layer (lowest first).
    /// Individual scenes can be frozen/unfrozen with `setProcessEnabled`.
    /// @param | dt | number | Fixed time-step delta in seconds (e.g. 1/60 for 60-tick logic).
    let st = state.clone();
    tbl.set(
        "process",
        lua.create_function(move |lua, dt: f64| {
            let active_ids: Vec<SceneId> = {
                let s = st.borrow();
                s.stack.get_active_ids_ordered_by_layer()
            };
            for id in &active_ids {
                let (ready_table, process_table) = {
                    let mut s = st.borrow_mut();
                    let ready_table = if s.scene_ready_pending.remove(id) {
                        s.scene_refs
                            .get(id)
                            .and_then(|key| lua.registry_value::<LuaTable>(key).ok())
                    } else {
                        None
                    };
                    let process_table = s
                        .scene_refs
                        .get(id)
                        .and_then(|key| lua.registry_value::<LuaTable>(key).ok());
                    (ready_table, process_table)
                };
                if let Some(table) = ready_table {
                    let _ = call_scene_table_method(table, "ready", ());
                }
                let should_process = {
                    let s = st.borrow();
                    s.stack.is_process_enabled(*id)
                };
                if !should_process {
                    continue;
                }
                if let Some(table) = process_table {
                    let _ = call_scene_table_method(table, "process", dt);
                }
            }
            Ok(())
        })?,
    )?;
    // -- processPhysics --
    /// Call `process_physics(self, dt)` on every process-active scene ordered by layer.
    /// Individual scenes can be frozen/unfrozen with `setPhysicsEnabled`.
    /// @param | dt | number | Physics time-step delta in seconds.
    let st = state.clone();
    tbl.set(
        "processPhysics",
        lua.create_function(move |lua, dt: f64| {
            let active_ids: Vec<SceneId> = {
                let s = st.borrow();
                s.stack.get_active_ids_ordered_by_layer()
            };
            for id in &active_ids {
                let table = {
                    let s = st.borrow();
                    if !s.stack.is_physics_enabled(*id) {
                        None
                    } else {
                    s.scene_refs
                        .get(id)
                        .and_then(|key| lua.registry_value::<LuaTable>(key).ok())
                    }
                };
                if let Some(table) = table {
                    let _ = call_scene_table_method(table, "process_physics", dt);
                }
            }
            Ok(())
        })?,
    )?;
    // -- processLate --
    /// Call `process_late(self, dt)` on every process-active scene after all other processing.
    /// Individual scenes can be frozen/unfrozen with `setLateEnabled`.
    /// @param | dt | number | Delta time in seconds (same value passed to `process`).
    let st = state.clone();
    tbl.set(
        "processLate",
        lua.create_function(move |lua, dt: f64| {
            let active_ids: Vec<SceneId> = {
                let s = st.borrow();
                s.stack.get_active_ids_ordered_by_layer()
            };
            for id in &active_ids {
                let table = {
                    let s = st.borrow();
                    if !s.stack.is_late_enabled(*id) {
                        None
                    } else {
                    s.scene_refs
                        .get(id)
                        .and_then(|key| lua.registry_value::<LuaTable>(key).ok())
                    }
                };
                if let Some(table) = table {
                    let _ = call_scene_table_method(table, "process_late", dt);
                }
            }
            Ok(())
        })?,
    )?;
    // -- draw --
    /// Call `draw(self)` on render-active scenes ordered by layer (lowest first).
    /// Engine-level render policy is single-scene: only the current top scene is rendered.
    /// This is the legacy draw callback — prefer `render` and `renderUi` for world-space and screen-space separation.
    let st = state.clone();
    tbl.set(
        "draw",
        lua.create_function(move |lua, ()| {
            let active_ids: Vec<SceneId> = {
                let s = st.borrow();
                s.stack.get_render_ids_ordered_by_layer()
            };
            for id in &active_ids {
                let table = {
                    let s = st.borrow();
                    s.scene_refs
                        .get(id)
                        .and_then(|scene_key| lua.registry_value::<LuaTable>(scene_key).ok())
                };
                if let Some(table) = table {
                    let _ = call_scene_table_method(table, "draw", ());
                }
            }
            Ok(())
        })?,
    )?;
    // -- render --
    /// Call `render(self)` on render-active scenes ordered by layer (lowest first).
    /// Engine-level render policy is single-scene: only the current top scene is rendered.
    /// This is the preferred world-space rendering callback — draw sprites, tilemaps, particles, and other in-world visuals here. Runs before `renderUi`.
    let st = state.clone();
    tbl.set(
        "render",
        lua.create_function(move |lua, ()| {
            let active_ids: Vec<SceneId> = {
                let s = st.borrow();
                s.stack.get_render_ids_ordered_by_layer()
            };
            for id in &active_ids {
                let table = {
                    let s = st.borrow();
                    s.scene_refs
                        .get(id)
                        .and_then(|scene_key| lua.registry_value::<LuaTable>(scene_key).ok())
                };
                if let Some(table) = table {
                    let _ = call_scene_table_method(table, "render", ());
                }
            }
            Ok(())
        })?,
    )?;
    // -- renderUi --
    /// Call `render_ui(self)` on render-active scenes ordered by layer (lowest first).
    /// Engine-level render policy is single-scene: only the current top scene is rendered.
    /// Use this for screen-space HUD elements, health bars, score displays, menus, and overlays that should draw on top of the world after `render`.
    let st = state.clone();
    tbl.set(
        "renderUi",
        lua.create_function(move |lua, ()| {
            let active_ids: Vec<SceneId> = {
                let s = st.borrow();
                s.stack.get_render_ids_ordered_by_layer()
            };
            for id in &active_ids {
                let table = {
                    let s = st.borrow();
                    s.scene_refs
                        .get(id)
                        .and_then(|scene_key| lua.registry_value::<LuaTable>(scene_key).ok())
                };
                if let Some(table) = table {
                    let _ = call_scene_table_method(table, "render_ui", ());
                }
            }
            Ok(())
        })?,
    )?;
    // -- getStackSize --
    /// Returns the total number of scenes currently on the stack, including overlays. Useful for asserting expected navigation depth or debugging scene flow.
    /// @return | number | The current stack depth (0 when empty).
    let st = state.clone();
    tbl.set(
        "getStackSize",
        lua.create_function(move |_, ()| Ok(st.borrow().stack.get_stack_size()))?,
    )?;
    // -- depth --
    /// Alias for `getStackSize`. Returns the total number of scenes currently on the stack.
    /// @return | number | The current stack depth (0 when empty).
    let st = state.clone();
    tbl.set(
        "depth",
        lua.create_function(move |_, ()| Ok(st.borrow().stack.get_stack_size()))?,
    )?;
    // -- isEmpty --
    /// Returns true if the scene stack contains no scenes at all. Useful for guarding against calling `pop` on an empty stack or for detecting when the game should quit.
    /// @return | boolean | True when the stack is empty (depth == 0).
    let st = state.clone();
    tbl.set(
        "isEmpty",
        lua.create_function(move |_, ()| Ok(st.borrow().stack.is_empty()))?,
    )?;
    // -- getCurrent --
    /// Returns the scene table currently on top of the stack, or nil if the stack is empty. Use this to inspect or call methods on the active scene directly.
    /// @return | table|nil | The active top scene table, or nil if no scene is on the stack.
    let st = state.clone();
    tbl.set(
        "getCurrent",
        lua.create_function(move |lua, ()| {
            let s = st.borrow();
            if let Some(top_id) = s.stack.get_current() {
                if let Some(key) = s.scene_refs.get(&top_id) {
                    return Ok(Some(lua.registry_value::<LuaTable>(key)?));
                }
            }
            Ok(None)
        })?,
    )?;
    // -- setCurrentLayer --
    /// Set the rendering layer of the current top scene. Scenes with higher layer values are processed and drawn after lower-layer scenes. Use layers to control draw order when multiple scenes are active (e.g. game world at layer 0, HUD overlay at layer 10).
    /// @param | layer | integer | Integer layer value to assign (higher = drawn later / on top).
    /// @return | boolean | True if a scene was on top and the layer was set, false if the stack is empty.
    let st = state.clone();
    tbl.set(
        "setCurrentLayer",
        lua.create_function(move |_, layer: i32| {
            let mut s = st.borrow_mut();
            if let Some(top_id) = s.stack.get_current() {
                s.stack.set_scene_layer(top_id, layer);
                return Ok(true);
            }
            Ok(false)
        })?,
    )?;
    // -- getCurrentLayer --
    /// Get the rendering layer of the current top scene. Returns 0 if the stack is empty or if no layer was explicitly set.
    /// @return | number | The integer layer value of the top scene, or 0 if empty.
    let st = state.clone();
    tbl.set(
        "getCurrentLayer",
        lua.create_function(move |_, ()| {
            let s = st.borrow();
            if let Some(top_id) = s.stack.get_current() {
                return Ok(s.stack.get_scene_layer(top_id));
            }
            Ok(0)
        })?,
    )?;
    // -- isTransitioning --
    /// Returns true if a scene transition animation is currently playing. Use this to block input or skip certain logic during transitions.
    /// @return | boolean | True while a transition animation is in progress.
    let st = state.clone();
    tbl.set(
        "isTransitioning",
        lua.create_function(move |_, ()| Ok(st.borrow().stack.is_transitioning()))?,
    )?;
    // -- getTransitionProgress --
    /// Returns the raw linear progress (0.0 to 1.0) of the current transition animation, ignoring easing. Returns 0 when no transition is active. Use `getTransitionProgressEased` for the eased value.
    /// @return | number | Linear progress from 0 (start) to 1 (complete).
    let st = state.clone();
    tbl.set(
        "getTransitionProgress",
        lua.create_function(move |_, ()| Ok(st.borrow().stack.get_transition_progress()))?,
    )?;
    // -- queueTransition --
    /// Queue a transition to play automatically after the current one finishes. Multiple queued transitions execute in FIFO order, enabling multi-step cinematic sequences (e.g. fade-out then slide-in).
    /// @param | transition | string | Transition type name (e.g. `"fade"`, `"iris"`, `"wipe"`).
    /// @param | duration | number | Duration in seconds.
    /// @param | easing | string? | Easing curve name. Defaults to `"linear"`.
    let st = state.clone();
    tbl.set(
        "queueTransition",
        lua.create_function(
            move |_, (transition, duration, easing): (String, f32, Option<String>)| {
                let trans = TransitionType::from_lua_str(transition.as_str());
                let eas = easing
                    .as_deref()
                    .map(EasingType::from_lua_str)
                    .unwrap_or_default();
                st.borrow_mut().stack.queue_transition(trans, duration, eas);
                Ok(())
            },
        )?,
    )?;
    // -- getQueuedTransitionCount --
    /// Returns the number of transitions waiting in the queue behind the currently-playing transition.
    /// @return | number | Number of queued (not yet started) transitions.
    let st = state.clone();
    tbl.set(
        "getQueuedTransitionCount",
        lua.create_function(move |_, ()| Ok(st.borrow().stack.queued_transition_count()))?,
    )?;
    // -- clearQueuedTransitions --
    /// Discard all queued transitions without affecting the currently-playing transition (if any). Use this to cancel a planned transition sequence mid-way.
    let st = state.clone();
    tbl.set(
        "clearQueuedTransitions",
        lua.create_function(move |_, ()| {
            st.borrow_mut().stack.clear_transition_queue();
            Ok(())
        })?,
    )?;
    // -- registerScene --
    /// Register a scene table under a unique name for later retrieval via `getRegistered`, navigation via `popTo`, or deferred push via `pushPreloaded`. Registering does not push the scene onto the stack.
    /// @param | name | string | Unique name to associate with this scene (e.g. `"mainMenu"`, `"gameplay"`).
    /// @param | scene | table | The scene table to register.
    let st = state.clone();
    tbl.set(
        "registerScene",
        lua.create_function(move |lua, (name, scene): (String, LuaTable)| {
            let mut s = st.borrow_mut();
            let scene_id = s.stack.next_scene_id();
            let key = lua.create_registry_value(scene)?;
            s.stack.register_scene(name, scene_id);
            s.scene_refs.insert(scene_id, key);
            Ok(())
        })?,
    )?;
    // -- getRegistered --
    /// Retrieve a previously registered scene table by its name, or nil if no scene is registered under that name. Does not affect the stack.
    /// @param | name | string | The registered scene name to look up.
    /// @return | table|nil | The scene table, or nil if not found.
    let st = state.clone();
    tbl.set(
        "getRegistered",
        lua.create_function(move |lua, name: String| {
            let s = st.borrow();
            if let Some(scene_id) = s.stack.get_registered(&name) {
                if let Some(key) = s.scene_refs.get(&scene_id) {
                    let table: LuaTable = lua.registry_value(key)?;
                    return Ok(LuaValue::Table(table));
                }
            }
            Ok(LuaValue::Nil)
        })?,
    )?;
    // -- hasRegistered --
    /// Check whether a scene is registered under the given name.
    /// @param | name | string | The scene name to look up.
    /// @return | boolean | True if a scene is registered with that name.
    let st = state.clone();
    tbl.set(
        "hasRegistered",
        lua.create_function(move |_, name: String| Ok(st.borrow().stack.has_registered(&name)))?,
    )?;
    // -- unregisterScene --
    /// Remove a scene registration by name. Does not pop the scene if it is currently active on the stack — it only removes the name mapping.
    /// @param | name | string | The registered name to remove.
    let st = state.clone();
    tbl.set(
        "unregisterScene",
        lua.create_function(move |_, name: String| {
            st.borrow_mut().stack.unregister_scene(&name);
            Ok(())
        })?,
    )?;
    // -- getRegisteredNames --
    /// Returns an array of all currently registered scene name strings. Useful for debugging or building dynamic scene-selection UIs.
    /// @return | string[] | Lua array of registered name strings.
    let st = state.clone();
    tbl.set(
        "getRegisteredNames",
        lua.create_function(move |_, ()| Ok(st.borrow().stack.get_registered_names()))?,
    )?;
    // -- setData --
    /// Store an arbitrary Lua value in the scene module's shared data map, keyed by a string name. Scenes can use this to pass information between each other without direct references — for example, passing a selected level index from a menu scene to a gameplay scene.
    /// @param | key | string | The key to store data under (e.g. `"selectedLevel"`, `"playerName"`).
    /// @param | value | any | Value to store under the scene data key.
    let st = state.clone();
    tbl.set(
        "setData",
        lua.create_function(move |lua, (key, value): (String, LuaValue)| {
            let mut s = st.borrow_mut();
            let value_id = s.stack.next_scene_id();
            let reg_key = lua.create_registry_value(value)?;
            s.stack.set_data(key.clone(), value_id);
            s.data_refs.insert(key, reg_key);
            Ok(())
        })?,
    )?;
    // -- getData --
    /// Retrieve a value from the shared data map by key, or nil if the key has not been set. Commonly used in a scene's `enter` callback to read parameters set by the previous scene.
    /// @param | key | string | The data key to look up.
    /// @return | LuaValue | The stored value, or nil if the key does not exist.
    let st = state.clone();
    tbl.set(
        "getData",
        lua.create_function(move |lua, key: String| {
            let s = st.borrow();
            if let Some(reg_key) = s.data_refs.get(&key) {
                let value: LuaValue = lua.registry_value(reg_key)?;
                return Ok(value);
            }
            Ok(LuaValue::Nil)
        })?,
    )?;
    // -- hasData --
    /// Check whether a key exists in the shared scene data map without retrieving its value.
    /// @param | key | string | The data key to check for.
    /// @return | boolean | True if a value is stored under this key.
    let st = state.clone();
    tbl.set(
        "hasData",
        lua.create_function(move |_, key: String| Ok(st.borrow().stack.has_data(&key)))?,
    )?;
    // -- removeData --
    /// Remove a key and its associated value from the shared scene data map. No-op if the key does not exist.
    /// @param | key | string | The data key to remove.
    let st = state.clone();
    tbl.set(
        "removeData",
        lua.create_function(move |_, key: String| {
            let mut s = st.borrow_mut();
            s.stack.remove_data(&key);
            s.data_refs.remove(&key);
            Ok(())
        })?,
    )?;
    // -- newDepthSorter --
    /// Create a new `LDepthSorter` instance for collecting drawable items and flushing them in depth-sorted (painter's algorithm) order. Allocate one per scene or per rendering pass.
    /// @return | LDepthSorter | A fresh depth sorter with no queued entries.
    tbl.set(
        "newDepthSorter",
        lua.create_function(|_, ()| {
            Ok(LuaDepthSorter {
                inner: Rc::new(RefCell::new(DepthSorter::new())),
                callbacks: Rc::new(RefCell::new(Vec::new())),
            })
        })?,
    )?;
    // -- new --
    /// Create a new scene instance from an optional prototype table. Sets up metatables so the instance inherits methods from the prototype. Use this for one-off scene creation; use `define` when you need a reusable scene constructor.
    /// @param | def | table? | A prototype table containing scene lifecycle methods (`enter`, `leave`, `update`, `draw`, etc.). If omitted, an empty table is used.
    /// @return | table | A new instance table with `def` as its metatable `__index`.
    /// @field | __index | table | Prototype table (the def parameter).
    tbl.set(
        "new",
        lua.create_function(|lua, def: Option<LuaTable>| {
            let def = match def {
                Some(t) => t,
                None => lua.create_table()?,
            };
            /// Performs the '__index' operation.
            def.set("__index", def.clone())?;
            let instance: LuaTable = lua.create_table()?;
            instance.set_metatable(Some(def));
            Ok(instance)
        })?,
    )?;
    // -- newScene --
    /// Alias for `lurek.scene.new`. Creates a new scene instance from an optional prototype table while preserving the older API name still used by tests, examples, and existing game scripts.
    /// @param | def | table? | A prototype table containing scene lifecycle methods (`enter`, `leave`, `update`, `draw`, etc.). If omitted, an empty table is used.
    /// @return | table | A new instance table with `def` as its metatable `__index`.
    /// @field | __index | table | Prototype table (the def parameter).
    tbl.set(
        "newScene",
        lua.create_function(|lua, def: Option<LuaTable>| {
            let def = match def {
                Some(t) => t,
                None => lua.create_table()?,
            };
            /// Performs the '__index' operation.
            def.set("__index", def.clone())?;
            let instance: LuaTable = lua.create_table()?;
            instance.set_metatable(Some(def));
            Ok(instance)
        })?,
    )?;
    // -- define --
    /// Create a reusable scene constructor function from a prototype table. Each call to the returned factory produces a fresh instance that inherits methods from the prototype via metatables. Ideal for defining scene "classes" that can be instantiated multiple times.
    /// @param | def | table? | A prototype table with scene lifecycle methods.
    /// @return | function | A zero-argument factory function that creates new instances inheriting from `def`.
    tbl.set(
        "define",
        lua.create_function(|lua, def: Option<LuaTable>| {
            let def = match def {
                Some(t) => t,
                None => lua.create_table()?,
            };
            /// Performs the '__index' operation.
            def.set("__index", def.clone())?;
            let key = lua.create_registry_value(def)?;
            let ctor = lua.create_function(move |inner_lua, ()| {
                let def: LuaTable = inner_lua.registry_value(&key)?;
                let instance: LuaTable = inner_lua.create_table()?;
                instance.set_metatable(Some(def));
                Ok(instance)
            })?;
            Ok(ctor)
        })?,
    )?;
    // -- getTransitionProgressEased --
    /// Returns the eased progress (0.0 to 1.0) of the current transition, with the selected easing curve applied. Returns 0 when no transition is active. Use this instead of `getTransitionProgress` when you want smooth, non-linear animation values.
    /// @return | number | Eased progress from 0 (start) to 1 (complete).
    let st = state.clone();
    tbl.set(
        "getTransitionProgressEased",
        lua.create_function(move |_, ()| Ok(st.borrow().stack.get_transition_progress_eased()))?,
    )?;
    // -- pushOverlay --
    /// Push a scene as an overlay on top of the current scene. Unlike `push`, the underlying scene is NOT paused — it can continue to receive `process` callbacks unless frozen. Rendering remains single-scene (top scene only) at engine level.
    /// @param | scene | table | The overlay scene table.
    /// @param | transition | string? | Transition type name. Defaults to `"none"`.
    /// @param | duration | number? | Transition animation duration in seconds. Defaults to 0.
    /// @param | easing | string? | Easing curve name. Defaults to `"linear"`.
    /// @param | params | table? | Arbitrary data forwarded to the overlay's `enter(self, params)` callback.
    let st = state.clone();
    tbl.set(
        "pushOverlay",
        lua.create_function(
            move |lua,
                  (scene, transition, duration, easing, params): (
                LuaTable,
                Option<String>,
                Option<f32>,
                Option<String>,
                Option<LuaValue>,
            )| {
                let trans = transition
                    .as_deref()
                    .map(TransitionType::from_lua_str)
                    .unwrap_or(TransitionType::None);
                let dur = duration.unwrap_or(0.0);
                let eas = easing
                    .as_deref()
                    .map(EasingType::from_lua_str)
                    .unwrap_or_default();
                let params_arg = params.unwrap_or(LuaValue::Nil);
                let new_table = {
                    let mut s = st.borrow_mut();
                    let scene_id = s.stack.next_scene_id();
                    let key = lua.create_registry_value(scene)?;
                    let _prev = s.stack.push_overlay(scene_id, trans, dur, eas);
                    s.scene_refs.insert(scene_id, key);
                    s.scene_ready_pending.insert(scene_id);
                    s.scene_refs
                        .get(&scene_id)
                        .and_then(|new_key| lua.registry_value::<LuaTable>(new_key).ok())
                };
                if let Some(new_table) = new_table {
                    let _ = call_scene_table_method(new_table, "enter", params_arg);
                }
                Ok(())
            },
        )?,
    )?;
    // -- isOverlay --
    /// Returns true if the current top scene was pushed via `pushOverlay`. Overlay scenes do not pause the scene beneath them, allowing both scenes to remain process-active unless explicitly frozen.
    /// @return | boolean | True if the top scene is an overlay, false otherwise.
    let st = state.clone();
    tbl.set(
        "isOverlay",
        lua.create_function(move |_, ()| {
            let s = st.borrow();
            let is_ov = s
                .stack
                .get_current()
                .map(|id| s.stack.is_overlay(id))
                .unwrap_or(false);
            Ok(is_ov)
        })?,
    )?;
    // -- getActiveScenes --
    /// Returns a Lua array of all process-active scene tables ordered by their layer value (lowest layer first). Includes regular scenes and overlays.
    /// @return | table | Lua array of active scene tables sorted by layer.
    /// @field | __index | table | Prototype table (the scene definition used to create this instance).
    let st = state.clone();
    tbl.set(
        "getActiveScenes",
        lua.create_function(move |lua, ()| {
            let s = st.borrow();
            let active_ids: Vec<SceneId> = s.stack.get_active_ids_ordered_by_layer();
            let result = lua.create_table()?;
            let mut out_index = 1;
            for id in &active_ids {
                if !s.stack.is_process_enabled(*id) {
                    continue;
                }
                if let Some(key) = s.scene_refs.get(id) {
                    let table: LuaTable = lua.registry_value(key)?;
                    result.raw_set(out_index, table)?;
                    out_index += 1;
                }
            }
            Ok(result)
        })?,
    )?;
    // -- getRenderActiveScenes --
    /// Returns the scene table(s) that are render-active this frame.
    /// Engine-level render policy is single-scene, so this returns either an empty table or a table with one element (top scene).
    /// @return | table | Lua array of render-active scene tables.
    let st = state.clone();
    tbl.set(
        "getRenderActiveScenes",
        lua.create_function(move |lua, ()| {
            let s = st.borrow();
            let render_ids: Vec<SceneId> = s.stack.get_render_ids_ordered_by_layer();
            let result = lua.create_table()?;
            for (i, id) in render_ids.iter().enumerate() {
                if let Some(key) = s.scene_refs.get(id) {
                    let table: LuaTable = lua.registry_value(key)?;
                    result.raw_set(i + 1, table)?;
                }
            }
            Ok(result)
        })?,
    )?;

    // -- setProcessEnabled --
    /// Enable or disable `process(self, dt)` execution for a selected scene.
    /// Target selector supports nil (current top), registered name string, or 1-based stack index.
    /// @param | target | any? | nil/current, registered scene name, or 1-based stack index.
    /// @param | enabled | boolean | True to run process, false to freeze it.
    /// @return | boolean | True when target scene was resolved and updated.
    let st = state.clone();
    tbl.set(
        "setProcessEnabled",
        lua.create_function(move |_, (target, enabled): (Option<LuaValue>, bool)| {
            let mut s = st.borrow_mut();
            if let Some(id) = resolve_target_scene_id(&s, target) {
                s.stack.set_process_enabled(id, enabled);
                return Ok(true);
            }
            Ok(false)
        })?,
    )?;

    // -- setPhysicsEnabled --
    /// Enable or disable `process_physics(self, dt)` execution for a selected scene.
    /// Target selector supports nil (current top), registered name string, or 1-based stack index.
    /// @param | target | any? | nil/current, registered scene name, or 1-based stack index.
    /// @param | enabled | boolean | True to run physics callback, false to freeze it.
    /// @return | boolean | True when target scene was resolved and updated.
    let st = state.clone();
    tbl.set(
        "setPhysicsEnabled",
        lua.create_function(move |_, (target, enabled): (Option<LuaValue>, bool)| {
            let mut s = st.borrow_mut();
            if let Some(id) = resolve_target_scene_id(&s, target) {
                s.stack.set_physics_enabled(id, enabled);
                return Ok(true);
            }
            Ok(false)
        })?,
    )?;

    // -- setLateEnabled --
    /// Enable or disable `process_late(self, dt)` execution for a selected scene.
    /// Target selector supports nil (current top), registered name string, or 1-based stack index.
    /// @param | target | any? | nil/current, registered scene name, or 1-based stack index.
    /// @param | enabled | boolean | True to run late callback, false to freeze it.
    /// @return | boolean | True when target scene was resolved and updated.
    let st = state.clone();
    tbl.set(
        "setLateEnabled",
        lua.create_function(move |_, (target, enabled): (Option<LuaValue>, bool)| {
            let mut s = st.borrow_mut();
            if let Some(id) = resolve_target_scene_id(&s, target) {
                s.stack.set_late_enabled(id, enabled);
                return Ok(true);
            }
            Ok(false)
        })?,
    )?;

    // -- setUpdateEnabled --
    /// Enable or disable `update(self, dt)` execution for a selected scene.
    /// Target selector supports nil (current top), registered name string, or 1-based stack index.
    /// @param | target | any? | nil/current, registered scene name, or 1-based stack index.
    /// @param | enabled | boolean | True to run update callback, false to freeze it.
    /// @return | boolean | True when target scene was resolved and updated.
    let st = state.clone();
    tbl.set(
        "setUpdateEnabled",
        lua.create_function(move |_, (target, enabled): (Option<LuaValue>, bool)| {
            let mut s = st.borrow_mut();
            if let Some(id) = resolve_target_scene_id(&s, target) {
                s.stack.set_update_enabled(id, enabled);
                return Ok(true);
            }
            Ok(false)
        })?,
    )?;

    // -- isProcessEnabled --
    /// Returns whether `process` is enabled for a selected scene.
    /// Target selector supports nil (current top), registered name string, or 1-based stack index.
    /// @param | target | any? | nil/current, registered scene name, or 1-based stack index.
    /// @return | boolean | True when enabled, false when frozen or target not found.
    let st = state.clone();
    tbl.set(
        "isProcessEnabled",
        lua.create_function(move |_, target: Option<LuaValue>| {
            let s = st.borrow();
            if let Some(id) = resolve_target_scene_id(&s, target) {
                return Ok(s.stack.is_process_enabled(id));
            }
            Ok(false)
        })?,
    )?;

    // -- isPhysicsEnabled --
    /// Returns whether `process_physics` is enabled for a selected scene.
    /// Target selector supports nil (current top), registered name string, or 1-based stack index.
    /// @param | target | any? | nil/current, registered scene name, or 1-based stack index.
    /// @return | boolean | True when enabled, false when frozen or target not found.
    let st = state.clone();
    tbl.set(
        "isPhysicsEnabled",
        lua.create_function(move |_, target: Option<LuaValue>| {
            let s = st.borrow();
            if let Some(id) = resolve_target_scene_id(&s, target) {
                return Ok(s.stack.is_physics_enabled(id));
            }
            Ok(false)
        })?,
    )?;

    // -- isLateEnabled --
    /// Returns whether `process_late` is enabled for a selected scene.
    /// Target selector supports nil (current top), registered name string, or 1-based stack index.
    /// @param | target | any? | nil/current, registered scene name, or 1-based stack index.
    /// @return | boolean | True when enabled, false when frozen or target not found.
    let st = state.clone();
    tbl.set(
        "isLateEnabled",
        lua.create_function(move |_, target: Option<LuaValue>| {
            let s = st.borrow();
            if let Some(id) = resolve_target_scene_id(&s, target) {
                return Ok(s.stack.is_late_enabled(id));
            }
            Ok(false)
        })?,
    )?;

    // -- isUpdateEnabled --
    /// Returns whether `update` is enabled for a selected scene.
    /// Target selector supports nil (current top), registered name string, or 1-based stack index.
    /// @param | target | any? | nil/current, registered scene name, or 1-based stack index.
    /// @return | boolean | True when enabled, false when frozen or target not found.
    let st = state.clone();
    tbl.set(
        "isUpdateEnabled",
        lua.create_function(move |_, target: Option<LuaValue>| {
            let s = st.borrow();
            if let Some(id) = resolve_target_scene_id(&s, target) {
                return Ok(s.stack.is_update_enabled(id));
            }
            Ok(false)
        })?,
    )?;
    // -- preload --
    /// Register a deferred-loading function for a scene. The loader function is NOT called immediately — it runs the first time `pushPreloaded` is called with this name. Use this to spread scene initialization (asset loading, table setup) across loading screens or lazy-load heavy scenes on demand.
    /// @param | name | string | Name to associate with the loader (must match the name used in `pushPreloaded`).
    /// @param | loader | function | A zero-argument function that creates and registers the scene via `registerScene` when called.
    let st = state.clone();
    tbl.set(
        "preload",
        lua.create_function(move |lua, (name, loader): (String, LuaFunction)| {
            let mut s = st.borrow_mut();
            let key = lua.create_registry_value(loader)?;
            s.preload_callbacks.insert(name, key);
            Ok(())
        })?,
    )?;
    // -- isPreloaded --
    /// Returns true if the named preload loader has already been executed at least once. Once a loader runs, subsequent `pushPreloaded` calls skip the loader and push the already-registered scene directly.
    /// @param | name | string | The preload name to check.
    /// @return | boolean | True if the loader has already executed.
    let st = state.clone();
    tbl.set(
        "isPreloaded",
        lua.create_function(move |_, name: String| {
            Ok(st.borrow().preloaded_names.contains(&name))
        })?,
    )?;
    // -- pushPreloaded --
    /// Push a preloaded scene onto the stack by name. If the loader registered via `preload` has not yet run, it executes first to create and register the scene. Then the registered scene is pushed with the specified transition. Combines deferred loading with stack navigation in a single call.
    /// @param | name | string | The preload/registration name (must match a prior `preload` or `registerScene` call).
    /// @param | transition | string? | Transition type name. Defaults to `"none"`.
    /// @param | duration | number? | Transition animation duration in seconds. Defaults to 0.
    /// @param | easing | string? | Easing curve name. Defaults to `"linear"`.
    /// @param | params | table? | Arbitrary data forwarded to the scene's `enter(self, params)` callback.
    let st = state.clone();
    tbl.set(
        "pushPreloaded",
        lua.create_function(
            move |lua,
                  (name, transition, duration, easing, params): (
                String,
                Option<String>,
                Option<f32>,
                Option<String>,
                Option<LuaValue>,
            )| {
                let trans = transition
                    .as_deref()
                    .map(TransitionType::from_lua_str)
                    .unwrap_or(TransitionType::None);
                let dur = duration.unwrap_or(0.0);
                let eas = easing
                    .as_deref()
                    .map(EasingType::from_lua_str)
                    .unwrap_or_default();
                let params_val = params.unwrap_or(LuaValue::Nil);
                let loader_opt: Option<LuaFunction> = {
                    let s = st.borrow();
                    if !s.preloaded_names.contains(&name) {
                        if let Some(key) = s.preload_callbacks.get(&name) {
                            lua.registry_value::<LuaFunction>(key).ok()
                        } else {
                            None
                        }
                    } else {
                        None
                    }
                };
                if loader_opt.is_some() {
                    st.borrow_mut().preloaded_names.insert(name.clone());
                }
                if let Some(loader) = &loader_opt {
                    let _ = loader.call::<_, ()>(());
                }
                let (prev_table, new_table) = {
                    let mut s = st.borrow_mut();
                    if let Some(scene_id) = s.stack.get_registered(&name) {
                        let prev_id = s.stack.push(scene_id, trans, dur, eas);
                        let prev_table = prev_id
                            .and_then(|pid| s.scene_refs.get(&pid))
                            .and_then(|prev_key| lua.registry_value::<LuaTable>(prev_key).ok());
                        s.scene_ready_pending.insert(scene_id);
                        let new_table = s
                            .scene_refs
                            .get(&scene_id)
                            .and_then(|key| lua.registry_value::<LuaTable>(key).ok());
                        (prev_table, new_table)
                    } else {
                        (None, None)
                    }
                };
                if let Some(prev_table) = prev_table {
                    let _ = call_scene_table_method(prev_table, "pause", ());
                }
                if let Some(new_table) = new_table {
                    let _ = call_scene_table_method(new_table, "enter", params_val);
                }
                Ok(())
            },
        )?,
    )?;
    // -- getTransitionTypes --
    /// Returns a Lua array of all supported transition type name strings. Use this to discover available transitions at runtime or build a transition picker UI.
    /// @return | string[] | Lua array of strings: `"none"`, `"fade"`, `"slideleft"`, `"slideright"`, `"slideup"`, `"slidedown"`, `"wipe"`, `"iris"`, `"zoom"`, `"crossfade"`.
    tbl.set(
        "getTransitionTypes",
        lua.create_function(|lua, ()| {
            let tbl = lua.create_table()?;
            let types = [
                "none",
                "fade",
                "slideleft",
                "slideright",
                "slideup",
                "slidedown",
                "wipe",
                "iris",
                "zoom",
                "crossfade",
            ];
            for (i, t) in types.iter().enumerate() {
                tbl.set(i + 1, *t)?;
            }
            Ok(tbl)
        })?,
    )?;
    // -- serializeScene --
    /// Capture the current scene stack state as a serializable snapshot table. The snapshot contains a `stack` array of registered scene names (in stack order) and a `data` map of shared data key-value pairs. Use this for save/load systems to persist the player's navigation state.
    /// @return | table | A snapshot table with `stack` (array of scene name strings) and `data` (key-value map) fields.
    /// @field | stack | string[] | Scene stack as ordered array of registered name strings.
    /// @field | data | table | Key-value map of shared scene data.
    let st = state.clone();
    tbl.set(
        "serializeScene",
        lua.create_function(move |lua, ()| {
            let s = st.borrow();
            let snap = lua.create_table()?;
            let stack_names = lua.create_table()?;
            let mut id_to_name: std::collections::HashMap<crate::scene::stack::SceneId, String> =
                std::collections::HashMap::new();
            for name in s.stack.get_registered_names() {
                if let Some(id) = s.stack.get_registered(&name) {
                    id_to_name.insert(id, name);
                }
            }
            for (i, &id) in s.stack.get_all().iter().enumerate() {
                if let Some(name) = id_to_name.get(&id) {
                    stack_names.set(i + 1, name.as_str())?;
                }
            }
            /// Performs the 'stack' operation.
            snap.set("stack", stack_names)?;
            let data_snap = lua.create_table()?;
            for (key, reg_key) in &s.data_refs {
                if let Ok(val) = lua.registry_value::<LuaValue>(reg_key) {
                    data_snap.set(key.as_str(), val)?;
                }
            }
            /// Performs the 'data' operation.
            snap.set("data", data_snap)?;
            Ok(snap)
        })?,
    )?;
    // -- deserializeScene --
    /// Restore shared scene data from a previously-serialized snapshot table. Only the `data` key-value map is restored; the scene stack itself must be rebuilt manually by pushing or registering scenes. Pair with `serializeScene` for save/load workflows.
    /// @param | snapshot | table | A snapshot table as returned by `serializeScene` (must contain a `data` field).
    let st = state.clone();
    tbl.set(
        "deserializeScene",
        lua.create_function(move |lua, snapshot: LuaTable| {
            let mut s = st.borrow_mut();
            if let Ok(data) = snapshot.get::<_, LuaTable>("data") {
                for pair in data.pairs::<String, LuaValue>() {
                    let (k, v) = pair?;
                    let reg_key = lua.create_registry_value(v)?;
                    if let Some(old) = s.data_refs.remove(&k) {
                        lua.remove_registry_value(old)?;
                    }
                    s.data_refs.insert(k, reg_key);
                }
            }
            Ok(())
        })?,
    )?;
    // -- transitions (sub-table) --
    /// Helper sub-table `lurek.scene.transitions` with convenience factory functions that build transition descriptor tables for use with transition-aware APIs.
    let trans_tbl = lua.create_table()?;
    // -- transitions.fade --
    /// Create a fade-to-black transition descriptor table. The screen fades to black, then fades back in on the new scene.
    /// @param | duration | number? | Total fade duration in seconds. Defaults to 0.5.
    /// @return | table | Transition descriptor `{type="fade", duration=...}` for use with scene functions.
    /// @field | type | string | Transition type name.
    /// @field | duration | number | Duration in seconds.
    trans_tbl.set(
        "fade",
        lua.create_function(|lua, duration: Option<f32>| {
            let t = lua.create_table()?;
            /// Performs the 'type' operation.
            t.set("type", "fade")?;
            /// Performs the 'duration' operation.
            t.set("duration", duration.unwrap_or(0.5))?;
            Ok(t)
        })?,
    )?;
    // -- transitions.slide --
    /// Create a directional slide transition descriptor table. The new scene slides in from the specified direction, pushing the old scene out.
    /// @param | direction | string? | Slide direction: `"left"`, `"right"`, `"up"`, or `"down"`. Defaults to `"left"`.
    /// @param | duration | number? | Slide animation duration in seconds. Defaults to 0.4.
    /// @return | table | Transition descriptor `{type="slide...", duration=...}` for use with scene functions.
    /// @field | type | string | Transition type name.
    /// @field | duration | number | Duration in seconds.
    trans_tbl.set(
        "slide",
        lua.create_function(
            |lua, (direction, duration): (Option<String>, Option<f32>)| {
                let t = lua.create_table()?;
                let dir = match direction.as_deref().unwrap_or("left") {
                    "left" | "slideleft" => "slideleft",
                    "right" | "slideright" => "slideright",
                    "up" | "slideup" => "slideup",
                    "down" | "slidedown" => "slidedown",
                    _ => "slideleft",
                };
                /// Performs the 'type' operation.
                t.set("type", dir)?;
                /// Performs the 'duration' operation.
                t.set("duration", duration.unwrap_or(0.4))?;
                Ok(t)
            },
        )?,
    )?;
    // -- transitions.wipe --
    /// Create a horizontal wipe transition descriptor table. A wipe bar sweeps across the screen to reveal the new scene.
    /// @param | duration | number? | Wipe animation duration in seconds. Defaults to 0.5.
    /// @return | table | Transition descriptor `{type="wipe", duration=...}` for use with scene functions.
    /// @field | type | string | Transition type name.
    /// @field | duration | number | Duration in seconds.
    trans_tbl.set(
        "wipe",
        lua.create_function(|lua, duration: Option<f32>| {
            let t = lua.create_table()?;
            /// Performs the 'type' operation.
            t.set("type", "wipe")?;
            /// Performs the 'duration' operation.
            t.set("duration", duration.unwrap_or(0.5))?;
            Ok(t)
        })?,
    )?;
    // -- transitions.iris --
    /// Create an iris (circle) transition descriptor table. A circular aperture opens or closes to reveal the new scene, similar to classic cartoon transitions.
    /// @param | duration | number? | Iris animation duration in seconds. Defaults to 0.6.
    /// @return | table | Transition descriptor `{type="iris", duration=...}` for use with scene functions.
    /// @field | type | string | Transition type name.
    /// @field | duration | number | Duration in seconds.
    trans_tbl.set(
        "iris",
        lua.create_function(|lua, duration: Option<f32>| {
            let t = lua.create_table()?;
            /// Performs the 'type' operation.
            t.set("type", "iris")?;
            /// Performs the 'duration' operation.
            t.set("duration", duration.unwrap_or(0.6))?;
            Ok(t)
        })?,
    )?;
    // transitions: subtable of built-in transition descriptor constructor functions.
    /// Performs the 'transitions' operation.
    tbl.set("transitions", trans_tbl)?;
    /// Performs the 'scene' operation.
    lurek.set("scene", tbl)?;
    Ok(())
}
