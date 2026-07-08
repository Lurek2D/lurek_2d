//! Registers the `lurek.ai` Lua API for AI command helpers, option parsing, and thin bindings over engine logic.

use super::SharedState;
use crate::lua_api::pathfind_api::{next_async_path_request_id, submit_async_query, LuaNavGrid};
use crate::ai::validation::{finite_f32, finite_f64, non_negative, positive_nonzero};
use crate::ai::{
    AIOrderRuntimeStats, AIDirector, AILod, AISpatialQueryStats, AIWorld, AgentStance,
    AiValidationLimits, BTNode, BehaviorTree, Blackboard, CallbackErrorTrace, CommandEvent,
    CommandQueue, CommandSnapshot, Consideration, DecisionBiasSet, DecisionModel, DialogueAI,
    Emotion, EmotionModel, FormationFallbackMode, FormationLayout, FormationSortMode,
    FormationType, GOAPPlanner, HTNDomain, HTNMethod, HTNPlanner, MCTSConfig, MCTSEngine, Need,
    NeedSystem, OrderRuntimeState, ParallelPolicy, ResponseCurve, SpatialQueryOptions, Squad,
    SquadMemberProfile, StanceProfile, StimulusWorld, StrategyAI, TraitArchetypes, TraitProfile,
    UtilityAI, WorldState,
};
use crate::lua_api::callback_registry::CallbackRegistry;
use crate::pathfind::{AsyncPathRequest, FootprintSpec};
use mlua::prelude::*;
use std::cell::RefCell;
use std::collections::HashMap;
use std::rc::Rc;

fn lua_ai_runtime_error(message: impl Into<String>) -> LuaError {
    LuaError::RuntimeError(message.into())
}

fn lua_require_finite_f32(field: &'static str, value: f32) -> LuaResult<f32> {
    finite_f32(field, value).map_err(|err| lua_ai_runtime_error(err.to_string()))
}

fn lua_require_finite_f64(field: &'static str, value: f64) -> LuaResult<f64> {
    finite_f64(field, value).map_err(|err| lua_ai_runtime_error(err.to_string()))
}

fn lua_require_non_negative_f64(field: &'static str, value: f64) -> LuaResult<f64> {
    non_negative(field, value).map_err(|err| lua_ai_runtime_error(err.to_string()))
}

fn lua_require_positive_f32(field: &'static str, value: f32) -> LuaResult<f32> {
    positive_nonzero(field, f64::from(value), &AiValidationLimits::default())
        .map(|_| value)
        .map_err(|err| lua_ai_runtime_error(err.to_string()))
}

fn lua_table_to_f32_map(table: LuaTable) -> LuaResult<HashMap<String, f32>> {
    let mut out = HashMap::new();
    for pair in table.pairs::<String, f32>() {
        let (key, value) = pair?;
        out.insert(key, lua_require_finite_f32("ai trait value", value)?);
    }
    Ok(out)
}

fn callback_errors_to_lua<'lua>(
    lua: &'lua Lua,
    errors: &[CallbackErrorTrace],
) -> LuaResult<LuaTable<'lua>> {
    let out = lua.create_table()?;
    for (i, error) in errors.iter().enumerate() {
        let entry = lua.create_table()?;
        entry.set("context", error.context.as_str())?;
        entry.set("message", error.message.as_str())?;
        out.set(i + 1, entry)?;
    }
    Ok(out)
}

fn command_snapshot_to_lua<'lua>(
    lua: &'lua Lua,
    snapshot: &CommandSnapshot,
) -> LuaResult<LuaTable<'lua>> {
    let out = lua.create_table()?;
    out.set("id", snapshot.id)?;
    out.set("kind", snapshot.kind.as_str())?;
    out.set("targetX", snapshot.target_x)?;
    out.set("targetY", snapshot.target_y)?;
    out.set("priority", snapshot.priority)?;
    out.set("interruptible", snapshot.interruptible)?;
    Ok(out)
}

fn command_snapshots_to_lua<'lua>(
    lua: &'lua Lua,
    snapshots: &[CommandSnapshot],
) -> LuaResult<LuaTable<'lua>> {
    let out = lua.create_table()?;
    for (i, snapshot) in snapshots.iter().enumerate() {
        out.set(i + 1, command_snapshot_to_lua(lua, snapshot)?)?;
    }
    Ok(out)
}

fn command_events_to_lua<'lua>(lua: &'lua Lua, events: &[CommandEvent]) -> LuaResult<LuaTable<'lua>> {
    let out = lua.create_table()?;
    for (i, event) in events.iter().enumerate() {
        let entry = lua.create_table()?;
        entry.set("id", event.command_id)?;
        entry.set("kind", event.kind.as_str())?;
        entry.set("event", event.event.as_str())?;
        entry.set("targetX", event.target_x)?;
        entry.set("targetY", event.target_y)?;
        entry.set("priority", event.priority)?;
        entry.set("interruptible", event.interruptible)?;
        entry.set("detail", event.detail.clone())?;
        out.set(i + 1, entry)?;
    }
    Ok(out)
}

fn squad_member_profile_from_lua(table: &LuaTable) -> LuaResult<SquadMemberProfile> {
    let footprint_w: u32 = table.get("footprintW").unwrap_or(1);
    let footprint_h: u32 = table.get("footprintH").unwrap_or(1);
    let subgroup: Option<String> = table.get("subgroup").ok();
    Ok(SquadMemberProfile {
        footprint_w: footprint_w.max(1),
        footprint_h: footprint_h.max(1),
        subgroup,
    })
}

fn squad_member_profile_to_lua<'lua>(
    lua: &'lua Lua,
    profile: &SquadMemberProfile,
) -> LuaResult<LuaTable<'lua>> {
    let out = lua.create_table()?;
    out.set("footprintW", profile.footprint_w)?;
    out.set("footprintH", profile.footprint_h)?;
    out.set("subgroup", profile.subgroup.clone())?;
    Ok(out)
}

fn squad_member_positions_from_lua(
    table: Option<LuaTable>,
) -> LuaResult<Option<HashMap<String, (f32, f32)>>> {
    let Some(table) = table else {
        return Ok(None);
    };
    let mut out = HashMap::new();
    for pair in table.pairs::<String, LuaTable>() {
        let (name, position) = pair?;
        let x: f32 = lua_require_finite_f32("squad member position.x", position.get("x").unwrap_or(0.0))?;
        let y: f32 = lua_require_finite_f32("squad member position.y", position.get("y").unwrap_or(0.0))?;
        out.insert(name, (x, y));
    }
    Ok(Some(out))
}

fn formation_layout_slots_to_lua<'lua>(
    lua: &'lua Lua,
    layout: &FormationLayout,
) -> LuaResult<LuaTable<'lua>> {
    let out = lua.create_table()?;
    for (i, slot) in layout.slots.iter().enumerate() {
        let entry = lua.create_table()?;
        entry.set("member", slot.member.as_str())?;
        entry.set("slotIndex", slot.slot_index as u32)?;
        entry.set("x", slot.x)?;
        entry.set("y", slot.y)?;
        entry.set("row", slot.row)?;
        entry.set("col", slot.col)?;
        entry.set("footprintW", slot.footprint_w)?;
        entry.set("footprintH", slot.footprint_h)?;
        entry.set("subgroup", slot.subgroup.clone())?;
        out.set(i + 1, entry)?;
    }
    Ok(out)
}

fn formation_layout_summary_to_lua<'lua>(
    lua: &'lua Lua,
    layout: &FormationLayout,
) -> LuaResult<LuaTable<'lua>> {
    let out = lua.create_table()?;
    out.set("requestedFormation", layout.requested_formation.as_str())?;
    out.set("activeFormation", layout.active_formation.as_str())?;
    out.set("fallbackApplied", layout.fallback_applied)?;
    out.set("width", layout.width)?;
    out.set("height", layout.height)?;
    out.set("slotCount", layout.slots.len() as u32)?;
    Ok(out)
}

fn stance_profile_to_lua<'lua>(
    lua: &'lua Lua,
    profile: &StanceProfile,
) -> LuaResult<LuaTable<'lua>> {
    let out = lua.create_table()?;
    out.set("stance", profile.stance.as_str())?;
    out.set("acquireEnabled", profile.acquire_enabled)?;
    out.set("holdFire", profile.hold_fire)?;
    out.set("acquireRadius", profile.acquire_radius)?;
    out.set("guardRadius", profile.guard_radius)?;
    out.set("chaseRadius", profile.chase_radius)?;
    out.set("interruptsMove", profile.interrupts_move)?;
    out.set("abandonFormation", profile.abandon_formation)?;
    Ok(out)
}

fn apply_stance_overrides(profile: &mut StanceProfile, opts: Option<&LuaTable>) -> LuaResult<()> {
    let Some(opts) = opts else {
        return Ok(());
    };
    if let Some(value) = opts.get::<_, Option<bool>>("acquireEnabled")? {
        profile.acquire_enabled = value;
    }
    if let Some(value) = opts.get::<_, Option<bool>>("holdFire")? {
        profile.hold_fire = value;
    }
    if let Some(value) = opts.get::<_, Option<f32>>("acquireRadius")? {
        profile.acquire_radius = lua_require_finite_f32("stance acquireRadius", value)?.max(0.0);
    }
    if let Some(value) = opts.get::<_, Option<f32>>("guardRadius")? {
        profile.guard_radius = lua_require_finite_f32("stance guardRadius", value)?.max(0.0);
    }
    if let Some(value) = opts.get::<_, Option<f32>>("chaseRadius")? {
        profile.chase_radius = lua_require_finite_f32("stance chaseRadius", value)?.max(0.0);
    }
    if let Some(value) = opts.get::<_, Option<bool>>("interruptsMove")? {
        profile.interrupts_move = value;
    }
    if let Some(value) = opts.get::<_, Option<bool>>("abandonFormation")? {
        profile.abandon_formation = value;
    }
    Ok(())
}

fn spatial_query_stats_to_lua<'lua>(
    lua: &'lua Lua,
    stats: &AISpatialQueryStats,
) -> LuaResult<LuaTable<'lua>> {
    let out = lua.create_table()?;
    out.set("activeAgents", stats.active_agents as i64)?;
    out.set("spatialCells", stats.spatial_cells as i64)?;
    out.set("queryCount", stats.query_count as i64)?;
    out.set("candidateChecks", stats.candidate_checks as i64)?;
    out.set("returnedAgents", stats.returned_agents as i64)?;
    out.set("lastRadius", stats.last_radius)?;
    Ok(out)
}

fn order_runtime_stats_to_lua<'lua>(
    lua: &'lua Lua,
    stats: &AIOrderRuntimeStats,
) -> LuaResult<LuaTable<'lua>> {
    let out = lua.create_table()?;
    out.set("activeAgents", stats.active_agents as i64)?;
    out.set("moveOrdersSteered", stats.move_orders_steered as i64)?;
    out.set("moveOrdersCompleted", stats.move_orders_completed as i64)?;
    out.set("acquireQueries", stats.acquire_queries as i64)?;
    out.set("targetsAcquired", stats.targets_acquired as i64)?;
    out.set("softInterrupts", stats.soft_interrupts as i64)?;
    out.set("resumedOrders", stats.resumed_orders as i64)?;
    out.set("activeEngagements", stats.active_engagements as i64)?;
    out.set("formationBreaks", stats.formation_breaks as i64)?;
    out.set("budgetSkips", stats.budget_skips as i64)?;
    Ok(out)
}

fn order_runtime_state_to_lua<'lua>(
    lua: &'lua Lua,
    state: &OrderRuntimeState,
) -> LuaResult<LuaTable<'lua>> {
    let out = lua.create_table()?;
    out.set("active", state.engage_target.is_some())?;
    out.set("engageTarget", state.engage_target.clone())?;
    out.set("suspendedOrderId", state.suspended_order_id)?;
    out.set("formationAbandoned", state.formation_abandoned)?;
    out.set(
        "engageOriginX",
        state.engage_origin.map(|origin| origin.0),
    )?;
    out.set(
        "engageOriginY",
        state.engage_origin.map(|origin| origin.1),
    )?;
    Ok(out)
}

fn bot_names_to_lua<'lua>(
    lua: &'lua Lua,
    world: Rc<RefCell<AIWorld>>,
    callbacks: Rc<RefCell<CallbackRegistry>>,
    names: &[String],
) -> LuaResult<LuaTable<'lua>> {
    let out = lua.create_table()?;
    for (i, name) in names.iter().enumerate() {
        out.set(
            i + 1,
            LuaAgent {
                world: world.clone(),
                name: name.clone(),
                callbacks: callbacks.clone(),
            },
        )?;
    }
    Ok(out)
}

fn squad_member_positions_from_world(
    squad: &Squad,
    world: &AIWorld,
) -> HashMap<String, (f32, f32)> {
    let mut out = HashMap::new();
    for member in &squad.members {
        if let Some(agent) = world.agent(member) {
            out.insert(member.clone(), agent.position);
        }
    }
    out
}

fn world_point_to_nav_cell(
    position: (f32, f32),
    origin: (f32, f32),
    cell_size: f32,
    dims: (u32, u32),
) -> Option<(u32, u32)> {
    let local_x = position.0 - origin.0;
    let local_y = position.1 - origin.1;
    if !local_x.is_finite() || !local_y.is_finite() || cell_size <= 0.0 {
        return None;
    }
    let cell_x = (local_x / cell_size).floor();
    let cell_y = (local_y / cell_size).floor();
    if cell_x < 0.0 || cell_y < 0.0 {
        return None;
    }
    let cell = (cell_x as u32, cell_y as u32);
    if cell.0 >= dims.0 || cell.1 >= dims.1 {
        None
    } else {
        Some(cell)
    }
}

fn utility_trace_to_lua<'lua>(
    lua: &'lua Lua,
    trace: &crate::ai::UtilityDecisionTrace,
) -> LuaResult<LuaTable<'lua>> {
    let out = lua.create_table()?;
    out.set("chosen_action", trace.chosen_action.clone())?;
    out.set("callbacks_used", trace.callbacks_used as u32)?;
    out.set(
        "callback_errors",
        callback_errors_to_lua(lua, &trace.callback_errors)?,
    )?;
    let actions = lua.create_table()?;
    for (i, action) in trace.actions.iter().enumerate() {
        let entry = lua.create_table()?;
        entry.set("name", action.name.as_str())?;
        entry.set("raw_score", action.raw_score)?;
        entry.set("consideration_score", action.consideration_score)?;
        entry.set("momentum_multiplier", action.momentum_multiplier)?;
        entry.set("final_score", action.final_score)?;
        entry.set("invalid_scorer", action.invalid_scorer)?;
        let considerations = lua.create_table()?;
        for (j, consideration) in action.considerations.iter().enumerate() {
            let c = lua.create_table()?;
            c.set("name", consideration.name.as_str())?;
            c.set("raw_score", consideration.raw_score)?;
            c.set("final_score", consideration.final_score)?;
            c.set("weight", consideration.weight)?;
            c.set("invalid_input", consideration.invalid_input)?;
            considerations.set(j + 1, c)?;
        }
        entry.set("considerations", considerations)?;
        actions.set(i + 1, entry)?;
    }
    out.set("actions", actions)?;
    Ok(out)
}

fn goap_trace_to_lua<'lua>(
    lua: &'lua Lua,
    trace: &crate::ai::GoapPlanTrace,
) -> LuaResult<LuaTable<'lua>> {
    let out = lua.create_table()?;
    out.set("selected_goal", trace.selected_goal.clone())?;
    let plan = lua.create_table()?;
    for (i, action) in trace.chosen_plan.iter().enumerate() {
        plan.set(i + 1, action.as_str())?;
    }
    out.set("chosen_plan", plan)?;
    out.set("iterations", trace.iterations as u32)?;
    out.set("expanded_nodes", trace.expanded_nodes as u32)?;
    out.set("failure_reason", trace.failure_reason.clone())?;
    Ok(out)
}

fn mcts_trace_to_lua<'lua>(
    lua: &'lua Lua,
    trace: &crate::ai::MctsDecisionTrace,
) -> LuaResult<LuaTable<'lua>> {
    let out = lua.create_table()?;
    out.set("chosen_action", trace.chosen_action.map(i64::from))?;
    out.set("iterations_run", trace.iterations_run)?;
    out.set("nodes_expanded", trace.nodes_expanded as u32)?;
    out.set("invalid_score_count", trace.invalid_score_count as u32)?;
    out.set(
        "callback_errors",
        callback_errors_to_lua(lua, &trace.callback_errors)?,
    )?;
    out.set("failure_reason", trace.failure_reason.clone())?;
    Ok(out)
}
/// Lua handle for an AI world that owns named agents, global blackboard data, and custom callback registrations.
#[derive(Clone)]
struct LuaAIWorld {
    /// Shared AI world state used by every world, agent, and blackboard wrapper cloned from this handle.
    inner: Rc<RefCell<AIWorld>>,
    /// Registry of Lua callbacks used by custom agent decision models created through this world.
    custom_callbacks: Rc<RefCell<CallbackRegistry>>,
    /// Callback errors recorded during the most recent world update.
    last_callback_errors: Rc<RefCell<Vec<CallbackErrorTrace>>>,
}
impl LuaUserData for LuaAIWorld {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- addAgent --
        /// Creates a named agent in this world and returns a handle that can edit its movement and decision state.
        /// @param | name | string | Unique agent name used by later lookup, tags, custom callbacks, and squad membership references.
        /// @return | LBot | Lua handle for the newly inserted bot.
        methods.add_method("addAgent", |_, this, name: String| {
            let mut w = this.inner.borrow_mut();
            w.add_agent(&name).map_err(LuaError::RuntimeError)?;
            Ok(LuaAgent {
                world: this.inner.clone(),
                name,
                callbacks: this.custom_callbacks.clone(),
            })
        });
        // -- getAgent --
        /// Returns the named agent handle when it exists in this world.
        /// @param | name | string | Agent name previously passed to `addAgent`.
        /// @return | LuaValue | Agent handle when found, or nil when the world has no agent with that name.
        methods.add_method("getAgent", |_, this, name: String| {
            let w = this.inner.borrow();
            if w.get_agent_index(&name).is_some() {
                Ok(Some(LuaAgent {
                    world: this.inner.clone(),
                    name,
                    callbacks: this.custom_callbacks.clone(),
                }))
            } else {
                Ok(None)
            }
        });
        // -- removeAgent --
        /// Removes an agent from this world by using an existing agent handle.
        /// @param | agent | LBot | Bot handle whose stored name identifies the world entry to remove.
        methods.add_method("removeAgent", |_, this, agent: LuaAnyUserData| {
            let a = agent.borrow::<LuaAgent>()?;
            this.inner.borrow_mut().remove_agent(&a.name);
            Ok(())
        });
        // -- getAgentCount --
        /// Returns the number of agents currently stored in this world.
        /// @return | integer | Current agent count.
        methods.add_method("getAgentCount", |_, this, ()| {
            Ok(this.inner.borrow().agent_count())
        });
        // -- getGlobalBlackboard --
        /// Returns a blackboard snapshot containing the world's shared AI facts.
        /// @return | LAIBlackboard | Blackboard handle initialized from the world's global blackboard values at call time.
        methods.add_method("getGlobalBlackboard", |_, this, ()| {
            let w = this.inner.borrow();
            Ok(LuaAIBlackboard {
                inner: Rc::new(RefCell::new(w.global_blackboard().clone())),
            })
        });
        // -- setSpatialCellSize --
        /// Sets the spatial-hash cell size used by nearby-agent queries in this world.
        /// @param | size | number | Spatial-hash cell size in world units.
        methods.add_method("setSpatialCellSize", |_, this, size: f32| {
            let size = lua_require_positive_f32("ai world spatial cell size", size)?;
            this.inner.borrow_mut().set_spatial_cell_size(size);
            Ok(())
        });
        // -- getSpatialCellSize --
        /// Returns the spatial-hash cell size used by nearby-agent queries in this world.
        /// @return | number | Spatial-hash cell size in world units.
        methods.add_method("getSpatialCellSize", |_, this, ()| {
            Ok(this.inner.borrow().spatial_cell_size())
        });
        // -- getSpatialQueryStats --
        /// Returns statistics from the most recent nearby-agent query.
        /// @return | table | Table with active-agent, cell, candidate-check, and returned-agent counters.
        methods.add_method("getSpatialQueryStats", |lua, this, ()| {
            let world = this.inner.borrow();
            spatial_query_stats_to_lua(lua, world.spatial_query_stats())
        });
        // -- setOrderArrivalRadius --
        /// Sets the move-order arrival threshold used by world update when completing queued move orders.
        /// @param | radius | number | Arrival threshold in world units.
        methods.add_method("setOrderArrivalRadius", |_, this, radius: f32| {
            let radius = lua_require_finite_f32("ai world order arrival radius", radius)?.max(0.0);
            this.inner.borrow_mut().set_order_arrival_radius(radius);
            Ok(())
        });
        // -- getOrderArrivalRadius --
        /// Returns the move-order arrival threshold used by world update.
        /// @return | number | Arrival threshold in world units.
        methods.add_method("getOrderArrivalRadius", |_, this, ()| {
            Ok(this.inner.borrow().order_arrival_radius())
        });
        // -- setAutoAcquireBudget --
        /// Sets the maximum number of stance-driven hostile-acquisition queries attempted in one update.
        /// @param | budget | integer | Per-update auto-acquisition query budget; zero disables new acquisition work.
        methods.add_method("setAutoAcquireBudget", |_, this, budget: usize| {
            this.inner.borrow_mut().set_auto_acquire_budget(budget);
            Ok(())
        });
        // -- getAutoAcquireBudget --
        /// Returns the per-update budget used for stance-driven hostile-acquisition queries.
        /// @return | integer | Current auto-acquisition query budget.
        methods.add_method("getAutoAcquireBudget", |_, this, ()| {
            Ok(this.inner.borrow().auto_acquire_budget() as i64)
        });
        // -- getOrderRuntimeStats --
        /// Returns statistics from the most recent world update's order execution and acquisition work.
        /// @return | table | Table with move-order, acquisition, interruption, and budget counters.
        methods.add_method("getOrderRuntimeStats", |lua, this, ()| {
            let world = this.inner.borrow();
            order_runtime_stats_to_lua(lua, world.order_runtime_stats())
        });
        // -- queryAgentsInRadius --
        /// Returns nearby agents by using the world's persistent spatial index instead of a full Lua scan.
        /// @param | x | number | Query center X position in world units.
        /// @param | y | number | Query center Y position in world units.
        /// @param | radius | number | Query radius in world units.
        /// @param | opts | table? | Optional table with `limit`, `exclude`, `team`, `hostileTo`, `tag`, and `notTag`.
        /// @return | table | Array of nearest-first `LBot` handles.
        methods.add_method("queryAgentsInRadius", |lua, this, (x, y, radius, opts): (f32, f32, f32, Option<LuaTable>)| {
            let x = lua_require_finite_f32("ai world query x", x)?;
            let y = lua_require_finite_f32("ai world query y", y)?;
            let radius = lua_require_finite_f32("ai world query radius", radius)?.max(0.0);
            let exclude = match &opts {
                Some(opts) => opts.get::<_, Option<String>>("exclude")?,
                None => None,
            };
            let team = match &opts {
                Some(opts) => opts.get::<_, Option<i32>>("team")?,
                None => None,
            };
            let hostile_to = match &opts {
                Some(opts) => opts.get::<_, Option<i32>>("hostileTo")?,
                None => None,
            };
            let limit = match &opts {
                Some(opts) => opts.get::<_, Option<usize>>("limit")?,
                None => None,
            };
            let tag = match &opts {
                Some(opts) => opts.get::<_, Option<String>>("tag")?,
                None => None,
            };
            let not_tag = match &opts {
                Some(opts) => opts.get::<_, Option<String>>("notTag")?,
                None => None,
            };
            let names = this.inner.borrow_mut().query_agents_in_radius(
                (x, y),
                radius,
                SpatialQueryOptions {
                    exclude_name: exclude.as_deref(),
                    team_filter: team,
                    hostile_to_team: hostile_to,
                    limit,
                    required_tag: tag.as_deref(),
                    blocked_tag: not_tag.as_deref(),
                },
            );
            bot_names_to_lua(lua, this.inner.clone(), this.custom_callbacks.clone(), &names)
        });
        // -- update --
        /// Advances the world simulation and invokes custom decision callbacks for agents that use a custom model.
        /// @param | dt | number | Elapsed simulation time in seconds for this update step.
        methods.add_method("update", |lua, this, dt: f32| {
            lua_require_finite_f32("ai world dt", dt)?;
            this.inner.borrow_mut().update(dt);
            this.last_callback_errors.borrow_mut().clear();
            let custom_agents: Vec<(String, u32)> = {
                let w = this.inner.borrow();
                w.agents
                    .iter()
                    .filter_map(|a| {
                        if let crate::ai::DecisionModel::Custom { callback_id } = a.decision_model {
                            Some((a.name.clone(), callback_id))
                        } else {
                            None
                        }
                    })
                    .collect()
            };
            for (name, callback_id) in custom_agents {
                let lua_agent = LuaAgent {
                    world: this.inner.clone(),
                    name: name.clone(),
                    callbacks: this.custom_callbacks.clone(),
                };
                let lua_bb = {
                    let w = this.inner.borrow();
                    match w.agent(&name) {
                        Some(agent) => LuaAIBlackboard {
                            inner: Rc::new(RefCell::new(agent.blackboard.clone())),
                        },
                        None => continue,
                    }
                };
                let func_opt: Option<LuaFunction> = {
                    let cb = this.custom_callbacks.borrow();
                    cb.get(callback_id)
                        .and_then(|key| lua.registry_value(key).ok())
                };
                if let Some(func) = func_opt {
                    if let Err(e) = func.call::<_, ()>((lua_agent, lua_bb, dt)) {
                        this.last_callback_errors
                            .borrow_mut()
                            .push(CallbackErrorTrace {
                                context: format!("world.custom.{name}"),
                                message: e.to_string(),
                            });
                    }
                }
            }
            Ok(())
        });
        // -- getLastCallbackErrors --
        /// Returns callback errors recorded during the most recent `update` call.
        /// @return | table | Array of `{ context, message }` tables.
        methods.add_method("getLastCallbackErrors", |lua, this, ()| {
            let out = lua.create_table()?;
            for (i, error) in this.last_callback_errors.borrow().iter().enumerate() {
                let entry = lua.create_table()?;
                entry.set("context", error.context.as_str())?;
                entry.set("message", error.message.as_str())?;
                out.set(i + 1, entry)?;
            }
            Ok(out)
        });
        // -- type --
        /// Returns the Lua-visible type name for this AI world handle.
        /// @return | string | The string `LAIWorld`.
        methods.add_method("type", |_, _, ()| Ok("LAIWorld"));
        // -- typeOf --
        /// Returns whether this AI world handle matches a supported type name.
        /// @param | name | string | Type name to compare against `AIWorld` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LAIWorld" || name == "LObject")
        });
    }
}
/// Lua handle for a named agent stored inside an AI world.
#[derive(Clone)]
struct LuaAgent {
    /// Shared world containing the agent entry referenced by `name`.
    world: Rc<RefCell<AIWorld>>,
    /// Stable agent name used to find the current world entry on each method call.
    name: String,
    /// Registry used when this agent installs a Lua callback as its decision model.
    callbacks: Rc<RefCell<CallbackRegistry>>,
}
impl LuaUserData for LuaAgent {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- getName --
        /// Returns this agent's stable world name.
        /// @return | string | Agent name stored in the handle.
        methods.add_method("getName", |_, this, ()| Ok(this.name.clone()));
        // -- setPosition --
        /// Sets this agent's world position when the agent still exists in its world.
        /// @param | x | number | New X position in world units.
        /// @param | y | number | New Y position in world units.
        methods.add_method("setPosition", |_, this, (x, y): (f32, f32)| {
            let x = lua_require_finite_f32("agent position.x", x)?;
            let y = lua_require_finite_f32("agent position.y", y)?;
            let mut world = this.world.borrow_mut();
            let updated = if let Some(agent) = world.agent_mut(&this.name) {
                agent.position = (x, y);
                true
            } else {
                false
            };
            if updated {
                world.mark_spatial_dirty();
            }
            Ok(())
        });
        // -- getPosition --
        /// Returns this agent's world position or the origin when the agent has been removed.
        /// @return | number, number | X and Y position in world units.
        methods.add_method("getPosition", |_, this, ()| {
            if let Some(agent) = this.world.borrow().agent(&this.name) {
                Ok(agent.position)
            } else {
                Ok((0.0, 0.0))
            }
        });
        // -- setVelocity --
        /// Sets this agent's velocity vector when the agent still exists in its world.
        /// @param | x | number | New X velocity in world units per second.
        /// @param | y | number | New Y velocity in world units per second.
        methods.add_method("setVelocity", |_, this, (x, y): (f32, f32)| {
            let x = lua_require_finite_f32("agent velocity.x", x)?;
            let y = lua_require_finite_f32("agent velocity.y", y)?;
            if let Some(agent) = this.world.borrow_mut().agent_mut(&this.name) {
                agent.velocity = (x, y);
            }
            Ok(())
        });
        // -- getVelocity --
        /// Returns this agent's velocity vector or zero velocity when the agent has been removed.
        /// @return | number, number | X and Y velocity in world units per second.
        methods.add_method("getVelocity", |_, this, ()| {
            if let Some(agent) = this.world.borrow().agent(&this.name) {
                Ok(agent.velocity)
            } else {
                Ok((0.0, 0.0))
            }
        });
        // -- setMaxSpeed --
        /// Sets this agent's maximum movement speed when the agent still exists in its world.
        /// @param | v | number | Maximum speed in world units per second.
        methods.add_method("setMaxSpeed", |_, this, v: f32| {
            let v = lua_require_positive_f32("agent max_speed", v)?;
            if let Some(agent) = this.world.borrow_mut().agent_mut(&this.name) {
                agent.max_speed = v;
            }
            Ok(())
        });
        // -- getMaxSpeed --
        /// Returns this agent's maximum movement speed or the default speed for a missing agent.
        /// @return | number | Maximum speed in world units per second.
        methods.add_method("getMaxSpeed", |_, this, ()| {
            if let Some(agent) = this.world.borrow().agent(&this.name) {
                Ok(agent.max_speed)
            } else {
                Ok(100.0)
            }
        });
        // -- setMaxForce --
        /// Sets this agent's maximum steering force when the agent still exists in its world.
        /// @param | v | number | Maximum steering force applied during steering calculations.
        methods.add_method("setMaxForce", |_, this, v: f32| {
            let v = lua_require_positive_f32("agent max_force", v)?;
            if let Some(agent) = this.world.borrow_mut().agent_mut(&this.name) {
                agent.max_force = v;
            }
            Ok(())
        });
        // -- getMaxForce --
        /// Returns this agent's maximum steering force or the default force for a missing agent.
        /// @return | number | Maximum steering force value.
        methods.add_method("getMaxForce", |_, this, ()| {
            if let Some(agent) = this.world.borrow().agent(&this.name) {
                Ok(agent.max_force)
            } else {
                Ok(200.0)
            }
        });
        // -- setPriority --
        /// Sets this agent's integer priority when the agent still exists in its world.
        /// @param | p | integer | Priority value used by game-side AI scheduling or ordering logic.
        methods.add_method("setPriority", |_, this, p: i32| {
            if let Some(agent) = this.world.borrow_mut().agent_mut(&this.name) {
                agent.priority = p;
            }
            Ok(())
        });
        // -- getPriority --
        /// Returns this agent's integer priority or zero when the agent has been removed.
        /// @return | integer | Current priority value.
        methods.add_method("getPriority", |_, this, ()| {
            if let Some(agent) = this.world.borrow().agent(&this.name) {
                Ok(agent.priority)
            } else {
                Ok(0)
            }
        });
        // -- setTeam --
        /// Sets this agent's integer team identifier used by hostile-acquisition queries.
        /// @param | team | integer | Team identifier compared by world-backed hostile queries.
        methods.add_method("setTeam", |_, this, team: i32| {
            if let Some(agent) = this.world.borrow_mut().agent_mut(&this.name) {
                agent.team = team;
            }
            Ok(())
        });
        // -- getTeam --
        /// Returns this agent's integer team identifier or zero when the agent has been removed.
        /// @return | integer | Current team identifier.
        methods.add_method("getTeam", |_, this, ()| {
            if let Some(agent) = this.world.borrow().agent(&this.name) {
                Ok(agent.team)
            } else {
                Ok(0)
            }
        });
        // -- setStance --
        /// Sets this agent's built-in RTS stance and optionally overrides its acquisition settings.
        /// @param | stance | string | Built-in stance name such as `passive`, `hold_fire`, `defensive`, `aggressive`, or `berserk`.
        /// @param | opts | table? | Optional overrides for `acquireEnabled`, `holdFire`, `acquireRadius`, `guardRadius`, `chaseRadius`, `interruptsMove`, and `abandonFormation`.
        methods.add_method("setStance", |_, this, (stance, opts): (String, Option<LuaTable>)| {
            let stance = AgentStance::parse_str(&stance).ok_or_else(|| {
                lua_ai_runtime_error(format!("lurek.ai.LBot:setStance: unknown stance '{stance}'"))
            })?;
            let mut profile = stance.default_profile();
            apply_stance_overrides(&mut profile, opts.as_ref())?;
            if let Some(agent) = this.world.borrow_mut().agent_mut(&this.name) {
                agent.stance = profile;
            }
            Ok(())
        });
        // -- getStance --
        /// Returns this agent's current stance profile, including built-in name and effective override values.
        /// @return | table | Table containing `stance`, acquisition radii, and interruption flags.
        methods.add_method("getStance", |lua, this, ()| {
            if let Some(agent) = this.world.borrow().agent(&this.name) {
                stance_profile_to_lua(lua, &agent.stance)
            } else {
                stance_profile_to_lua(lua, &AgentStance::Aggressive.default_profile())
            }
        });
        // -- setDecisionModel --
        /// Sets this agent's built-in decision model from a string name when the name is recognized.
        /// @param | model | string | Decision model name such as `fsm`, `bt`, `utility`, or another engine-supported model string.
        methods.add_method("setDecisionModel", |_, this, model: String| {
            let mut w = this.world.borrow_mut();
            if let Some(idx) = w.get_agent_index(&this.name) {
                if let Some(dm) = DecisionModel::parse_str(&model) {
                    w.agents[idx].decision_model = dm;
                }
            }
            Ok(())
        });
        // -- getDecisionModel --
        /// Returns this agent's decision model name or the default model name for a missing agent.
        /// @return | string | Current decision model name.
        methods.add_method("getDecisionModel", |_, this, ()| {
            if let Some(agent) = this.world.borrow().agent(&this.name) {
                Ok(agent.decision_model.as_str().to_string())
            } else {
                Ok("fsm".to_string())
            }
        });
        // -- setCustomModel --
        /// Installs a Lua callback as this agent's decision model and stores it in the callback registry.
        /// @param | callback | function | Function called during world updates with `(agent, blackboard, dt)` for this agent.
        methods.add_method("setCustomModel", |lua, this, callback: LuaFunction| {
            let key = lua.create_registry_value(callback)?;
            let callback_id = this.callbacks.borrow_mut().register(key);
            if let Some(agent) = this.world.borrow_mut().agent_mut(&this.name) {
                agent.decision_model = crate::ai::DecisionModel::Custom { callback_id };
            }
            Ok(())
        });
        // -- setTraitProfile --
        /// Copies a trait profile onto this agent so future agent decisions can read commander personality values.
        /// @param | profile | LTraitProfile | Trait profile copied into the agent state.
        methods.add_method("setTraitProfile", |_, this, profile_ud: LuaAnyUserData| {
            let profile = profile_ud.borrow::<LuaTraitProfile>()?;
            if let Some(agent) = this.world.borrow_mut().agent_mut(&this.name) {
                agent.trait_profile = Some(profile.inner.borrow().clone());
            }
            Ok(())
        });
        // -- getTraitProfile --
        /// Returns a snapshot copy of this agent's trait profile when one is assigned.
        /// @return | LuaValue | Trait profile snapshot, or nil when this agent has no profile.
        methods.add_method("getTraitProfile", |_, this, ()| {
            let w = this.world.borrow();
            if let Some(agent) = w.agent(&this.name) {
                if let Some(profile) = &agent.trait_profile {
                    return Ok(Some(LuaTraitProfile {
                        inner: Rc::new(RefCell::new(profile.clone())),
                    }));
                }
            }
            Ok(None)
        });
        // -- hasTraitProfile --
        /// Returns whether this agent currently has an assigned trait profile.
        /// @return | boolean | True when a trait profile exists on the agent.
        methods.add_method("hasTraitProfile", |_, this, ()| {
            Ok(this
                .world
                .borrow()
                .agent(&this.name)
                .and_then(|agent| agent.trait_profile.as_ref())
                .is_some())
        });
        // -- setTrait --
        /// Sets one trait on this agent, creating an empty profile first when needed.
        /// @param | name | string | Trait key to create or update.
        /// @param | value | number | Base trait value clamped by the engine to `[0, 1]`.
        methods.add_method("setTrait", |_, this, (name, value): (String, f32)| {
            let value = lua_require_finite_f32("agent trait value", value)?;
            if let Some(agent) = this.world.borrow_mut().agent_mut(&this.name) {
                let profile = agent.trait_profile.get_or_insert_with(TraitProfile::new);
                profile.set(&name, value);
            }
            Ok(())
        });
        // -- getTrait --
        /// Returns one effective trait value from this agent's profile.
        /// @param | name | string | Trait key to read.
        /// @return | number | Effective trait value, or zero when unset.
        methods.add_method("getTrait", |_, this, name: String| {
            Ok(this
                .world
                .borrow()
                .agent(&this.name)
                .and_then(|agent| agent.trait_profile.as_ref())
                .map(|profile| profile.get(&name))
                .unwrap_or(0.0))
        });
        // -- addTraitModifier --
        /// Adds a temporary or permanent modifier to one trait on this agent.
        /// @param | trait_name | string | Trait key affected by the modifier.
        /// @param | delta | number | Additive value applied while the modifier is active.
        /// @param | duration | number? | Modifier lifetime in seconds, or nil for permanent.
        /// @param | source | string | Source label used for later removal.
        methods.add_method(
            "addTraitModifier",
            |_, this, (trait_name, delta, duration, source): (String, f32, Option<f32>, String)| {
                let delta = lua_require_finite_f32("agent trait modifier delta", delta)?;
                let duration = duration
                    .map(|value| lua_require_finite_f32("agent trait modifier duration", value))
                    .transpose()?;
                if let Some(agent) = this.world.borrow_mut().agent_mut(&this.name) {
                    let profile = agent.trait_profile.get_or_insert_with(TraitProfile::new);
                    profile.add_modifier(&trait_name, delta, duration, &source);
                }
                Ok(())
            },
        );
        // -- addTag --
        /// Adds a tag string to this agent when the agent still exists in its world.
        /// @param | tag | string | Tag name to insert into the agent tag set.
        methods.add_method("addTag", |_, this, tag: String| {
            if let Some(agent) = this.world.borrow_mut().agent_mut(&this.name) {
                agent.tags.insert(tag);
            }
            Ok(())
        });
        // -- removeTag --
        /// Removes a tag string from this agent when the agent still exists in its world.
        /// @param | tag | string | Tag name to remove from the agent tag set.
        methods.add_method("removeTag", |_, this, tag: String| {
            if let Some(agent) = this.world.borrow_mut().agent_mut(&this.name) {
                agent.tags.remove(&tag);
            }
            Ok(())
        });
        // -- hasTag --
        /// Returns whether this agent currently has the given tag.
        /// @param | tag | string | Tag name to check in the agent tag set.
        /// @return | boolean | True when the tag exists on the agent.
        methods.add_method("hasTag", |_, this, tag: String| {
            if let Some(agent) = this.world.borrow().agent(&this.name) {
                Ok(agent.tags.contains(&tag))
            } else {
                Ok(false)
            }
        });
        // -- findHostilesInRange --
        /// Returns nearby hostile agents by using the world's spatial index and this agent's team as the hostile reference.
        /// @param | radius | number? | Optional explicit acquisition radius in world units; defaults to the stance profile radius.
        /// @param | opts | table? | Optional table with `limit`, `tag`, and `notTag`.
        /// @return | table | Array of nearest-first hostile `LBot` handles.
        methods.add_method("findHostilesInRange", |lua, this, (radius, opts): (Option<f32>, Option<LuaTable>)| {
            let radius = radius
                .map(|value| lua_require_finite_f32("agent hostile query radius", value))
                .transpose()?;
            let limit = match &opts {
                Some(opts) => opts.get::<_, Option<usize>>("limit")?,
                None => None,
            };
            let tag = match &opts {
                Some(opts) => opts.get::<_, Option<String>>("tag")?,
                None => None,
            };
            let not_tag = match &opts {
                Some(opts) => opts.get::<_, Option<String>>("notTag")?,
                None => None,
            };
            let (position, team, stance_radius) = {
                let world = this.world.borrow();
                let Some(agent) = world.agent(&this.name) else {
                    return lua.create_table();
                };
                (
                    agent.position,
                    agent.team,
                    agent
                        .stance
                        .acquire_radius
                        .max(agent.stance.guard_radius)
                        .max(agent.stance.chase_radius),
                )
            };
            let names = this.world.borrow_mut().query_agents_in_radius(
                position,
                radius.unwrap_or(stance_radius),
                SpatialQueryOptions {
                    exclude_name: Some(&this.name),
                    hostile_to_team: Some(team),
                    limit,
                    required_tag: tag.as_deref(),
                    blocked_tag: not_tag.as_deref(),
                    ..SpatialQueryOptions::default()
                },
            );
            bot_names_to_lua(lua, this.world.clone(), this.callbacks.clone(), &names)
        });
        // -- acquireTarget --
        /// Returns the nearest target selected from this agent's stance-driven hostile-acquisition query.
        /// @param | opts | table? | Optional table with `radius`, `limit`, `tag`, and `notTag`.
        /// @return | LuaValue | Nearest hostile `LBot` handle, or nil when no target matches the query.
        methods.add_method("acquireTarget", |_, this, opts: Option<LuaTable>| {
            let radius = match &opts {
                Some(opts) => opts.get::<_, Option<f32>>("radius")?,
                None => None,
            };
            let radius = radius
                .map(|value| lua_require_finite_f32("agent acquireTarget radius", value))
                .transpose()?;
            let limit = match &opts {
                Some(opts) => opts.get::<_, Option<usize>>("limit")?,
                None => None,
            };
            let tag = match &opts {
                Some(opts) => opts.get::<_, Option<String>>("tag")?,
                None => None,
            };
            let not_tag = match &opts {
                Some(opts) => opts.get::<_, Option<String>>("notTag")?,
                None => None,
            };
            let target = this.world.borrow_mut().acquire_target_for_agent(
                &this.name,
                radius,
                limit,
                tag.as_deref(),
                not_tag.as_deref(),
            );
            Ok(target.map(|name| LuaAgent {
                world: this.world.clone(),
                name,
                callbacks: this.callbacks.clone(),
            }))
        });
        // -- getBlackboard --
        /// Returns a blackboard snapshot for this agent or an empty blackboard when the agent has been removed.
        /// @return | LAIBlackboard | Blackboard handle initialized from the agent's local blackboard values at call time.
        methods.add_method("getBlackboard", |_, this, ()| {
            let w = this.world.borrow();
            if let Some(idx) = w.get_agent_index(&this.name) {
                Ok(LuaAIBlackboard {
                    inner: Rc::new(RefCell::new(w.agents[idx].blackboard.clone())),
                })
            } else {
                Ok(LuaAIBlackboard {
                    inner: Rc::new(RefCell::new(Blackboard::default())),
                })
            }
        });
        // -- getCommandQueue --
        /// Returns this agent's owned command queue handle for order staging and inspection.
        /// @return | LCommandQueue | Queue handle bound to the current agent entry inside its AI world.
        methods.add_method("getCommandQueue", |_, this, ()| {
            Ok(LuaCommandQueue {
                inner: CommandQueueBinding::Agent {
                    world: this.world.clone(),
                    name: this.name.clone(),
                },
            })
        });
        // -- getCurrentOrder --
        /// Returns the current queued order snapshot for this agent when one exists.
        /// @return | LuaValue | Table with `id`, `kind`, `targetX`, `targetY`, `priority`, and `interruptible`, or nil when this agent has no pending order.
        methods.add_method("getCurrentOrder", |lua, this, ()| {
            let snapshot = this
                .world
                .borrow()
                .agent(&this.name)
                .and_then(|agent| agent.command_queue.current());
            snapshot
                .as_ref()
                .map(|snapshot| command_snapshot_to_lua(lua, snapshot))
                .transpose()
        });
        // -- getOrderRuntimeState --
        /// Returns the live soft-interruption state used by world update for temporary engagement overrides.
        /// @return | table | Table with `active`, `engageTarget`, `engageOriginX`, `engageOriginY`, `suspendedOrderId`, and `formationAbandoned`.
        methods.add_method("getOrderRuntimeState", |lua, this, ()| {
            let state = this
                .world
                .borrow()
                .agent(&this.name)
                .map(|agent| agent.order_runtime.clone())
                .unwrap_or_default();
            order_runtime_state_to_lua(lua, &state)
        });
        // -- clearOrders --
        /// Clears every queued order owned by this agent.
        /// @param | reason | string? | Optional lifecycle detail string recorded on emitted clear events.
        /// @return | integer | Number of cleared orders.
        methods.add_method("clearOrders", |_, this, reason: Option<String>| {
            if let Some(agent) = this.world.borrow_mut().agent_mut(&this.name) {
                Ok(agent.command_queue.clear_with_reason(reason))
            } else {
                Ok(0)
            }
        });
        // -- drainCommandEvents --
        /// Returns and clears queued order lifecycle events for this agent.
        /// @return | table | Array of `{ id, kind, event, targetX, targetY, priority, interruptible, detail }` tables in emit order.
        methods.add_method("drainCommandEvents", |lua, this, ()| {
            let events = if let Some(agent) = this.world.borrow_mut().agent_mut(&this.name) {
                agent.command_queue.drain_events()
            } else {
                Vec::new()
            };
            command_events_to_lua(lua, &events)
        });
        // -- type --
        /// Returns the Lua-visible type name for this agent handle.
        /// @return | string | The string `LBot`.
        methods.add_method("type", |_, _, ()| Ok("LBot"));
        // -- typeOf --
        /// Returns whether this agent handle matches a supported type name.
        /// @param | name | string | Type name to compare against `Agent` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LBot" || name == "LAgent" || name == "LObject")
        });
    }
}
/// Lua handle for a typed AI blackboard storing local key-value facts.
#[derive(Clone)]
struct LuaAIBlackboard {
    /// Shared blackboard values exposed through typed setter and getter methods.
    inner: Rc<RefCell<Blackboard>>,
}
impl LuaUserData for LuaAIBlackboard {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- setNumber --
        /// Stores a numeric fact under the given blackboard key.
        /// @param | key | string | Blackboard key to write.
        /// @param | value | number | Numeric value stored for later numeric reads.
        methods.add_method("setNumber", |_, this, (key, value): (String, f64)| {
            this.inner.borrow_mut().set_number(&key, value);
            Ok(())
        });
        // -- getNumber --
        /// Returns a numeric blackboard fact or the provided fallback when the key is missing or not numeric.
        /// @param | key | string | Blackboard key to read.
        /// @param | default | number? | Fallback value used when the key has no numeric entry; defaults to zero.
        /// @return | number | Stored numeric value or fallback value.
        methods.add_method(
            "getNumber",
            |_, this, (key, default): (String, Option<f64>)| {
                Ok(this.inner.borrow().get_number(&key, default.unwrap_or(0.0)))
            },
        );
        // -- setBool --
        /// Stores a boolean fact under the given blackboard key.
        /// @param | key | string | Blackboard key to write.
        /// @param | value | boolean | Boolean value stored for later boolean reads.
        methods.add_method("setBool", |_, this, (key, value): (String, bool)| {
            this.inner.borrow_mut().set_bool(&key, value);
            Ok(())
        });
        // -- getBool --
        /// Returns a boolean blackboard fact or the provided fallback when the key is missing or not boolean.
        /// @param | key | string | Blackboard key to read.
        /// @param | default | boolean? | Fallback value used when the key has no boolean entry; defaults to false.
        /// @return | boolean | Stored boolean value or fallback value.
        methods.add_method(
            "getBool",
            |_, this, (key, default): (String, Option<bool>)| {
                Ok(this.inner.borrow().get_bool(&key, default.unwrap_or(false)))
            },
        );
        // -- setString --
        /// Stores a string fact under the given blackboard key.
        /// @param | key | string | Blackboard key to write.
        /// @param | value | string | String value stored for later string reads.
        methods.add_method("setString", |_, this, (key, value): (String, String)| {
            this.inner.borrow_mut().set_string(&key, &value);
            Ok(())
        });
        // -- getString --
        /// Returns a string blackboard fact or the provided fallback when the key is missing or not a string.
        /// @param | key | string | Blackboard key to read.
        /// @param | default | string? | Fallback value used when the key has no string entry; defaults to an empty string.
        /// @return | string | Stored string value or fallback value.
        methods.add_method(
            "getString",
            |_, this, (key, default): (String, Option<String>)| {
                let def = default.unwrap_or_default();
                Ok(this.inner.borrow().get_string(&key, &def))
            },
        );
        // -- has --
        /// Returns whether the blackboard contains any entry for the given key.
        /// @param | key | string | Blackboard key to check.
        /// @return | boolean | True when any typed value is stored at the key.
        methods.add_method("has", |_, this, key: String| {
            Ok(this.inner.borrow().has(&key))
        });
        // -- remove --
        /// Removes the given key from the blackboard if it exists.
        /// @param | key | string | Blackboard key to remove.
        methods.add_method("remove", |_, this, key: String| {
            this.inner.borrow_mut().remove(&key);
            Ok(())
        });
        // -- clear --
        /// Removes every local entry from this blackboard.
        methods.add_method("clear", |_, this, ()| {
            this.inner.borrow_mut().clear();
            Ok(())
        });
        // -- getKeys --
        /// Returns every local blackboard key in an array-style Lua table.
        /// @return | string[] | Array table containing all stored key names as strings.
        methods.add_method("getKeys", |lua, this, ()| {
            let keys = this.inner.borrow().keys();
            let tbl = lua.create_table()?;
            for (i, k) in keys.iter().enumerate() {
                tbl.set(i as i64 + 1, k.as_str())?;
            }
            Ok(tbl)
        });
        // -- getSize --
        /// Returns the number of entries currently stored in this blackboard.
        /// @return | integer | Current blackboard entry count.
        methods.add_method("getSize", |_, this, ()| Ok(this.inner.borrow().size()));
        // -- type --
        /// Returns the Lua-visible type name for this blackboard handle.
        /// @return | string | The string `LAIBlackboard`.
        methods.add_method("type", |_, _, ()| Ok("LAIBlackboard"));
        // -- typeOf --
        /// Returns whether this blackboard handle matches a supported type name.
        /// @param | name | string | Type name to compare against `AIBlackboard`, `Blackboard`, and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LAIBlackboard" || name == "LBlackboard" || name == "LObject")
        });
    }
}
/// Lua handle for a finite state machine with Lua-backed state callbacks and transition guards.
#[derive(Clone)]
struct LuaStateMachine {
    /// Shared state machine containing states, transitions, current state, and timing data.
    inner: Rc<RefCell<crate::ai::StateMachine>>,
}
impl LuaUserData for LuaStateMachine {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- addState --
        /// Adds a state with optional Lua lifecycle callbacks.
        /// @param | name | string | State name used by transitions and direct state changes.
        /// @param | opts | table | Optional table with `onEnter`, `onUpdate`, and `onExit` callback functions.
        methods.add_method("addState", |lua, this, (name, opts): (String, LuaTable)| {
            let on_enter: Option<LuaFunction> = opts.get("onEnter").ok();
            let on_update: Option<LuaFunction> = opts.get("onUpdate").ok();
            let on_exit: Option<LuaFunction> = opts.get("onExit").ok();
            let enter_key = on_enter.map(|f| lua.create_registry_value(f)).transpose()?;
            let update_key = on_update
                .map(|f| lua.create_registry_value(f))
                .transpose()?;
            let exit_key = on_exit.map(|f| lua.create_registry_value(f)).transpose()?;
            this.inner
                .borrow_mut()
                .add_state_raw(name, enter_key, update_key, exit_key);
            Ok(())
        });
        // -- addTransition --
        /// Adds a transition between two states with an optional guard callback and priority.
        /// @param | from | string | Source state name.
        /// @param | to | string | Destination state name.
        /// @param | guard | function? | Optional function that must return true for the transition to run.
        /// @param | priority | integer? | Transition priority used when multiple transitions are available; defaults to zero.
        methods.add_method("addTransition", |lua, this, (from, to, guard, priority): (String, String, Option<LuaFunction>, Option<i32>)| {
                let guard_key = guard.map(|f| lua.create_registry_value(f)).transpose()?;
                this.inner.borrow_mut().add_transition_raw(from, to, priority.unwrap_or(0), guard_key);
                Ok(())
            },
        );
        // -- setInitialState --
        /// Sets the initial state and also enters it when the machine has no current state yet.
        /// @param | name | string | State name to use as the initial state.
        methods.add_method("setInitialState", |_, this, name: String| {
            let mut fsm = this.inner.borrow_mut();
            fsm.initial_state = Some(name.clone());
            if fsm.current_state.is_none() {
                fsm.current_state = Some(name);
            }
            Ok(())
        });
        // -- getCurrentState --
        /// Returns the current state name when the state machine has entered a state.
        /// @return | LuaValue | Current state name, or nil before any state is active.
        methods.add_method("getCurrentState", |_, this, ()| {
            Ok(this.inner.borrow().current_state().map(|s| s.to_string()))
        });
        // -- forceState --
        /// Immediately switches the current state and resets the time spent in state.
        /// @param | name | string | State name to set as current without transition checks.
        methods.add_method("forceState", |_, this, name: String| {
            let mut fsm = this.inner.borrow_mut();
            fsm.current_state = Some(name);
            fsm.time_in_state = 0.0;
            Ok(())
        });
        // -- getTimeInState --
        /// Returns how long the machine has spent in the current state.
        /// @return | number | Elapsed time in seconds since the current state was entered.
        methods.add_method("getTimeInState", |_, this, ()| {
            Ok(this.inner.borrow().time_in_state())
        });
        // -- type --
        /// Returns the Lua-visible type name for this state machine handle.
        /// @return | string | The string `LStateMachine`.
        methods.add_method("type", |_, _, ()| Ok("LStateMachine"));
        // -- typeOf --
        /// Returns whether this state machine handle matches a supported type name.
        /// @param | name | string | Type name to compare against `StateMachine` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LStateMachine" || name == "LObject")
        });
    }
}
/// Lua handle for a behavior tree root and its most recent execution status.
#[derive(Clone)]
struct LuaBehaviorTree {
    /// Shared behavior tree that owns the root node and debug status.
    inner: Rc<RefCell<BehaviorTree>>,
}
impl LuaUserData for LuaBehaviorTree {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- setRoot --
        /// Sets the behavior tree root by moving a node handle into the tree.
        /// @param | node | LBTNode | Node handle to consume as the new tree root.
        methods.add_method("setRoot", |_, this, node_ud: LuaAnyUserData| {
            let node = node_ud.borrow::<LuaBTNode>()?;
            let taken = std::mem::replace(
                &mut *node.inner.borrow_mut(),
                BTNode::Sequence {
                    children: Vec::new(),
                    running_idx: 0,
                },
            );
            this.inner
                .borrow_mut()
                .set_root_checked(taken)
                .map_err(lua_ai_runtime_error)?;
            Ok(())
        });
        // -- getLastStatus --
        /// Returns the last behavior tree status string recorded by the tree.
        /// @return | string | Last status such as `success`, `failure`, or `running`.
        methods.add_method("getLastStatus", |_, this, ()| {
            Ok(this.inner.borrow().last_status.as_str().to_string())
        });
        // -- getDebugState --
        /// Returns behavior tree debug counters and status in a Lua table.
        /// @return | table | Table containing `node_count` and `last_status` fields.
        /// @field | node_count | integer | Node count.
        /// @field | last_status | string | Last status.
        methods.add_method("getDebugState", |lua, this, ()| {
            let dbg = this.inner.borrow().debug_state();
            let t = lua.create_table()?;
            /// Performs the 'node_count' operation.
            t.set("node_count", dbg.node_count as u32)?;
            /// Performs the 'max_depth' operation.
            t.set("max_depth", dbg.max_depth as u32)?;
            /// Performs the 'last_status' operation.
            t.set("last_status", dbg.last_status)?;
            /// Performs the 'limit_exceeded' operation.
            t.set("limit_exceeded", dbg.limit_exceeded)?;
            /// Performs the 'validation_error' operation.
            t.set(
                "validation_error",
                this.inner.borrow().last_validation_error.clone(),
            )?;
            Ok(t)
        });
        // -- type --
        /// Returns the Lua-visible type name for this behavior tree handle.
        /// @return | string | The string `LBehaviorTree`.
        methods.add_method("type", |_, _, ()| Ok("LBehaviorTree"));
        // -- typeOf --
        /// Returns whether this behavior tree handle matches a supported type name.
        /// @param | name | string | Type name to compare against `BehaviorTree` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LBehaviorTree" || name == "LObject")
        });
    }
}
/// Lua handle for a behavior tree node that can be assembled into composites and decorators.
#[derive(Clone)]
struct LuaBTNode {
    /// Shared node storage moved between handles when nodes are attached to parents.
    inner: Rc<RefCell<BTNode>>,
}
impl LuaUserData for LuaBTNode {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- addChild --
        /// Adds a child node to a composite selector, sequence, or parallel node.
        /// @param | child | LBTNode | Child node handle to move into this composite node.
        methods.add_method("addChild", |_, this, child_ud: LuaAnyUserData| {
            let child = child_ud.borrow::<LuaBTNode>()?;
            let taken = std::mem::replace(
                &mut *child.inner.borrow_mut(),
                BTNode::Sequence {
                    children: Vec::new(),
                    running_idx: 0,
                },
            );
            let mut node = this.inner.borrow_mut();
            match &mut *node {
                BTNode::Selector { children, .. }
                | BTNode::Sequence { children, .. }
                | BTNode::Parallel { children, .. } => {
                    children.push(taken);
                }
                _ => {
                    return Err(LuaError::RuntimeError(
                        "addChild is only valid for Selector, Sequence, or Parallel nodes"
                            .to_string(),
                    ));
                }
            }
            Ok(())
        });
        // -- getChildCount --
        /// Returns the number of children owned by this behavior tree node.
        /// @return | integer | Child count for composite nodes, or zero for leaf and decorator nodes without child lists.
        methods.add_method("getChildCount", |_, this, ()| {
            Ok(this.inner.borrow().child_count())
        });
        // -- reset --
        /// Resets this behavior tree node's runtime state.
        methods.add_method("reset", |_, this, ()| {
            this.inner.borrow_mut().reset();
            Ok(())
        });
        // -- setChild --
        /// Sets the single child of a decorator node such as inverter, repeater, or succeeder.
        /// @param | child | LBTNode | Child node handle to move into this decorator node.
        methods.add_method("setChild", |_, this, child_ud: LuaAnyUserData| {
            let child = child_ud.borrow::<LuaBTNode>()?;
            let taken = std::mem::replace(
                &mut *child.inner.borrow_mut(),
                BTNode::Sequence {
                    children: Vec::new(),
                    running_idx: 0,
                },
            );
            let mut node = this.inner.borrow_mut();
            match &mut *node {
                BTNode::Inverter { child } => {
                    **child = taken;
                }
                BTNode::Repeater { child, .. } => {
                    **child = taken;
                }
                BTNode::Succeeder { child } => {
                    **child = taken;
                }
                _ => {
                    return Err(LuaError::RuntimeError(
                        "setChild is only valid for Inverter, Repeater, or Succeeder nodes"
                            .to_string(),
                    ));
                }
            }
            Ok(())
        });
        // -- setCount --
        /// Sets the repeat count when this node is a repeater.
        /// @param | n | integer | Number of successful child executions before the repeater stops; zero means engine-defined repeat behavior.
        methods.add_method("setCount", |_, this, n: u32| {
            let mut node = this.inner.borrow_mut();
            if let BTNode::Repeater { count, .. } = &mut *node {
                *count = n;
            }
            Ok(())
        });
        // -- getCount --
        /// Returns the repeat count for repeater nodes or zero for other node kinds.
        /// @return | integer | Repeater count value.
        methods.add_method("getCount", |_, this, ()| {
            let node = this.inner.borrow();
            if let BTNode::Repeater { count, .. } = &*node {
                Ok(*count)
            } else {
                Ok(0)
            }
        });
        // -- setSuccessPolicy --
        /// Sets the success policy for a parallel node.
        /// @param | policy | string | Parallel success policy name parsed by the engine.
        methods.add_method("setSuccessPolicy", |_, this, policy: String| {
            let mut node = this.inner.borrow_mut();
            if let BTNode::Parallel { success_policy, .. } = &mut *node {
                *success_policy = ParallelPolicy::parse_str(&policy);
            }
            Ok(())
        });
        // -- setFailurePolicy --
        /// Sets the failure policy for a parallel node.
        /// @param | policy | string | Parallel failure policy name parsed by the engine.
        methods.add_method("setFailurePolicy", |_, this, policy: String| {
            let mut node = this.inner.borrow_mut();
            if let BTNode::Parallel { failure_policy, .. } = &mut *node {
                *failure_policy = ParallelPolicy::parse_str(&policy);
            }
            Ok(())
        });
        // -- getNodeType --
        /// Returns the behavior tree node kind as a lowercase string.
        /// @return | string | Node kind such as `selector`, `sequence`, `parallel`, `action`, or `condition`.
        methods.add_method("getNodeType", |_, this, ()| {
            let node = this.inner.borrow();
            let name = match &*node {
                BTNode::Selector { .. } => "selector",
                BTNode::Sequence { .. } => "sequence",
                BTNode::Parallel { .. } => "parallel",
                BTNode::Inverter { .. } => "inverter",
                BTNode::Repeater { .. } => "repeater",
                BTNode::Succeeder { .. } => "succeeder",
                BTNode::Guard { .. } => "guard",
                BTNode::Action { .. } => "action",
                BTNode::Condition { .. } => "condition",
            };
            Ok(name.to_string())
        });
        // -- type --
        /// Returns the Lua-visible type name for this behavior tree node handle.
        /// @return | string | The string `LBTNode`.
        methods.add_method("type", |_, _, ()| Ok("LBTNode"));
        // -- typeOf --
        /// Returns whether this behavior tree node handle matches a supported type name.
        /// @param | name | string | Type name to compare against `BTNode` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LBTNode" || name == "LObject")
        });
    }
}
/// Re-use the dialogue AI handle from the dialog_api module for backward compatibility.
use super::dialog_api::LuaDialogueAI;
/// Lua handle for utility AI action scoring and consideration curves.
#[derive(Clone)]
struct LuaUtilityAI {
    /// Shared utility AI model containing actions and their scorer callbacks.
    inner: Rc<RefCell<UtilityAI>>,
    /// Registry used for custom response curve callbacks.
    custom_callbacks: Rc<RefCell<CallbackRegistry>>,
}
impl LuaUserData for LuaUtilityAI {
    #[allow(clippy::type_complexity)]
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- addAction --
        /// Adds an action scored by a Lua callback and optional momentum weight.
        /// @param | name | string | Action name returned when this action wins evaluation.
        /// @param | scorer_fn | function | Function called by evaluation to score this action.
        /// @param | weight | number? | Momentum bonus or base weighting value; defaults to 1.0.
        methods.add_method(
            "addAction",
            |lua, this, (name, scorer_fn, weight): (String, LuaFunction, Option<f64>)| {
                let key = lua.create_registry_value(scorer_fn)?;
                let momentum_bonus =
                    lua_require_non_negative_f64("utility momentum_bonus", weight.unwrap_or(1.0))?;
                this.inner
                    .borrow_mut()
                    .add_action(name, key, momentum_bonus)
                    .map_err(lua_ai_runtime_error)?;
                Ok(())
            },
        );
        // -- evaluate --
        /// Evaluates all actions and returns the winning action name when one is available.
        /// @return | LuaValue | Winning action name, or nil when no action can be selected.
        methods.add_method("evaluate", |lua, this, ()| {
            match this.inner.borrow_mut().evaluate(lua)? {
                Some(name) => Ok(LuaValue::String(lua.create_string(&name)?)),
                None => Ok(LuaValue::Nil),
            }
        });
        // -- evaluateWithProfile --
        /// Evaluates all actions after applying trait-profile decision bias rules to each action score.
        /// @param | profile | LTraitProfile | Trait profile that supplies personality values.
        /// @param | biases | LDecisionBiasSet | Bias rules keyed by action name.
        /// @return | LuaValue | Winning action name, or nil when no action can be selected.
        methods.add_method(
            "evaluateWithProfile",
            |lua, this, (profile_ud, bias_ud): (LuaAnyUserData, LuaAnyUserData)| {
                let profile = profile_ud.borrow::<LuaTraitProfile>()?;
                let biases = bias_ud.borrow::<LuaDecisionBiasSet>()?;
                let chosen = {
                    let profile_ref = profile.inner.borrow();
                    let biases_ref = biases.inner.borrow();
                    this.inner
                        .borrow_mut()
                        .evaluate_with_profile(lua, &profile_ref, &biases_ref)?
                };
                match chosen {
                    Some(name) => Ok(LuaValue::String(lua.create_string(&name)?)),
                    None => Ok(LuaValue::Nil),
                }
            },
        );
        // -- getActionCount --
        /// Returns the number of actions registered in this utility AI.
        /// @return | integer | Current action count.
        methods.add_method("getActionCount", |_, this, ()| {
            Ok(this.inner.borrow().actions.len())
        });
        // -- getLastAction --
        /// Returns the last winning action name when evaluation has selected one.
        /// @return | LuaValue | Last action name, or nil before an action has won.
        methods.add_method("getLastAction", |_, this, ()| {
            let ai = this.inner.borrow();
            Ok(ai.last_action.map(|i| ai.actions[i].name.clone()))
        });
        // -- getLastTrace --
        /// Returns the last structured utility evaluation trace.
        /// @return | table | Table containing `chosen_action`, `callbacks_used`, `actions`, and `callback_errors`.
        methods.add_method("getLastTrace", |lua, this, ()| {
            let trace = this.inner.borrow().last_trace.clone();
            utility_trace_to_lua(lua, &trace)
        });
        // -- addConsideration --
        /// Adds a consideration scorer and response curve to an existing utility action.
        /// @param | action_name | string | Name of the action that receives the consideration.
        /// @param | name | string | Consideration name used for debugging and documentation.
        /// @param | scorer_fn | function | Function that returns the raw consideration score.
        /// @param | curve_arg | LuaValue | Curve name string, custom curve function, or another value to use the linear fallback.
        /// @param | p1 | number? | First curve parameter; defaults to 1.0.
        /// @param | p2 | number? | Second curve parameter; defaults to 0.0.
        /// @param | p3 | number? | Third curve parameter; defaults to 0.0.
        /// @param | weight | number? | Consideration weight; defaults to 1.0.
        methods.add_method(
            "addConsideration",
            |lua,
             this,
             (action_name, name, scorer_fn, curve_arg, p1, p2, p3, weight): (
                String,
                String,
                LuaFunction,
                LuaValue,
                Option<f64>,
                Option<f64>,
                Option<f64>,
                Option<f64>,
            )| {
                let scorer_key = lua.create_registry_value(scorer_fn)?;
                match curve_arg {
                    LuaValue::Function(f) => {
                        let curve_key = lua.create_registry_value(f)?;
                        let callback_id = this.custom_callbacks.borrow_mut().register(curve_key);
                        let curve = ResponseCurve::Custom { callback_id };
                        let p1 =
                            lua_require_finite_f64("utility consideration p1", p1.unwrap_or(1.0))?;
                        let p2 =
                            lua_require_finite_f64("utility consideration p2", p2.unwrap_or(0.0))?;
                        let p3 =
                            lua_require_finite_f64("utility consideration p3", p3.unwrap_or(0.0))?;
                        let weight = lua_require_non_negative_f64(
                            "utility consideration weight",
                            weight.unwrap_or(1.0),
                        )?;
                        let mut ua = this.inner.borrow_mut();
                        let max_considerations = ua.limits.max_utility_considerations;
                        if let Some(action) = ua.actions.iter_mut().find(|a| a.name == action_name)
                        {
                            if action.considerations.len() >= max_considerations {
                                return Err(lua_ai_runtime_error(format!(
                                    "utility considerations exceed limit {}",
                                    max_considerations
                                )));
                            }
                            action.considerations.push(Consideration {
                                name,
                                callback: scorer_key,
                                curve,
                                p1,
                                p2,
                                p3,
                                weight,
                            });
                        }
                    }
                    LuaValue::String(s) => {
                        let curve_str = s.to_str().unwrap_or("linear").to_string();
                        this.inner
                            .borrow_mut()
                            .add_consideration(
                                &action_name,
                                name,
                                scorer_key,
                                &curve_str,
                                p1.unwrap_or(1.0),
                                p2.unwrap_or(0.0),
                                p3.unwrap_or(0.0),
                                weight.unwrap_or(1.0),
                            )
                            .map_err(lua_ai_runtime_error)?;
                    }
                    _ => {
                        this.inner
                            .borrow_mut()
                            .add_consideration(
                                &action_name,
                                name,
                                scorer_key,
                                "linear",
                                p1.unwrap_or(1.0),
                                p2.unwrap_or(0.0),
                                p3.unwrap_or(0.0),
                                weight.unwrap_or(1.0),
                            )
                            .map_err(lua_ai_runtime_error)?;
                    }
                }
                Ok(())
            },
        );
        // -- type --
        /// Returns the Lua-visible type name for this utility AI handle.
        /// @return | string | The string `LUtilityAI`.
        methods.add_method("type", |_, _, ()| Ok("LUtilityAI"));
        // -- typeOf --
        /// Returns whether this utility AI handle matches a supported type name.
        /// @param | name | string | Type name to compare against `UtilityAI` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LUtilityAI" || name == "LObject")
        });
    }
}
/// Lua handle for a GOAP planner with boolean preconditions, effects, and goals.
#[derive(Clone)]
struct LuaGOAPPlanner {
    /// Shared GOAP planner containing actions, goals, and iteration limits.
    inner: Rc<RefCell<GOAPPlanner>>,
}
impl LuaUserData for LuaGOAPPlanner {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- addAction --
        /// Adds a GOAP action with optional cost and completion callback.
        /// @param | name | string | Action name emitted in generated plans.
        /// @param | cost | number? | Planning cost for the action; defaults to 1.0.
        /// @param | callback | function? | Optional callback stored with the action for game-side execution.
        methods.add_method(
            "addAction",
            |lua, this, (name, cost, callback): (String, Option<f64>, Option<LuaFunction>)| {
                let cb_key = callback.map(|f| lua.create_registry_value(f)).transpose()?;
                let cost = lua_require_non_negative_f64("goap action cost", cost.unwrap_or(1.0))?;
                this.inner
                    .borrow_mut()
                    .add_action(name, cost, cb_key)
                    .map_err(lua_ai_runtime_error)?;
                Ok(())
            },
        );
        // -- setPrecondition --
        /// Sets one boolean precondition for an existing GOAP action.
        /// @param | action_name | string | Name of the action to update.
        /// @param | key | string | World-state key required by the action.
        /// @param | value | boolean | Required boolean value for the key.
        methods.add_method(
            "setPrecondition",
            |_, this, (action_name, key, value): (String, String, bool)| {
                let mut planner = this.inner.borrow_mut();
                if let Some(action) = planner.actions.iter_mut().find(|a| a.name == action_name) {
                    action.preconditions.insert(key, value);
                }
                Ok(())
            },
        );
        // -- setEffect --
        /// Sets one boolean effect produced by an existing GOAP action.
        /// @param | action_name | string | Name of the action to update.
        /// @param | key | string | World-state key changed by the action.
        /// @param | value | boolean | Boolean value written by the effect.
        methods.add_method(
            "setEffect",
            |_, this, (action_name, key, value): (String, String, bool)| {
                let mut planner = this.inner.borrow_mut();
                if let Some(action) = planner.actions.iter_mut().find(|a| a.name == action_name) {
                    action.effects.insert(key, value);
                }
                Ok(())
            },
        );
        // -- addGoal --
        /// Adds a GOAP goal with an optional priority weight.
        /// @param | name | string | Goal name used for planning and debugging.
        /// @param | priority | number? | Goal priority; defaults to 1.0.
        methods.add_method(
            "addGoal",
            |_, this, (name, priority): (String, Option<f64>)| {
                let priority =
                    lua_require_non_negative_f64("goap goal priority", priority.unwrap_or(1.0))?;
                this.inner
                    .borrow_mut()
                    .add_goal(name, priority)
                    .map_err(lua_ai_runtime_error)?;
                Ok(())
            },
        );
        // -- setGoalState --
        /// Sets one desired world-state key for an existing GOAP goal.
        /// @param | goal_name | string | Name of the goal to update.
        /// @param | key | string | World-state key required by the goal.
        /// @param | value | boolean | Desired boolean value for the key.
        methods.add_method(
            "setGoalState",
            |_, this, (goal_name, key, value): (String, String, bool)| {
                let mut planner = this.inner.borrow_mut();
                if let Some(goal) = planner.goals.iter_mut().find(|g| g.name == goal_name) {
                    goal.state.insert(key, value);
                }
                Ok(())
            },
        );
        // -- plan --
        /// Builds a plan from the supplied boolean world state and returns action names in execution order.
        /// @param | world_state_tbl | table | Map table from string world-state keys to boolean values.
        /// @param | max_depth | integer? | Maximum search depth; defaults to 10.
        /// @return | string[] | Action names selected by the planner.
        methods.add_method(
            "plan",
            |lua, this, (world_state_tbl, max_depth): (LuaTable, Option<usize>)| {
                let mut world_state = HashMap::new();
                for pair in world_state_tbl.pairs::<String, bool>() {
                    let (k, v) = pair?;
                    world_state.insert(k, v);
                }
                let plan = this
                    .inner
                    .borrow_mut()
                    .plan(&world_state, max_depth.unwrap_or(10));
                let tbl = lua.create_table()?;
                for (i, name) in plan.iter().enumerate() {
                    tbl.set(i as i64 + 1, name.as_str())?;
                }
                Ok(tbl)
            },
        );
        // -- getActionCount --
        /// Returns the number of GOAP actions registered in this planner.
        /// @return | integer | Current action count.
        methods.add_method("getActionCount", |_, this, ()| {
            Ok(this.inner.borrow().actions.len())
        });
        // -- getGoalCount --
        /// Returns the number of GOAP goals registered in this planner.
        /// @return | integer | Current goal count.
        methods.add_method("getGoalCount", |_, this, ()| {
            Ok(this.inner.borrow().goals.len())
        });
        // -- getMaxIterations --
        /// Returns the maximum number of planner iterations allowed during search.
        /// @return | integer | Current maximum iteration count.
        methods.add_method("getMaxIterations", |_, this, ()| {
            Ok(this.inner.borrow().get_max_iterations() as u64)
        });
        // -- setMaxIterations --
        /// Sets the maximum number of planner iterations allowed during search.
        /// @param | n | integer | Maximum iteration count.
        methods.add_method_mut("setMaxIterations", |_, this, n: u64| {
            this.inner.borrow_mut().set_max_iterations(n as usize);
            Ok(())
        });
        // -- getLastFailureReason --
        /// Returns the last planner failure reason string when planning did not succeed.
        /// @return | LuaValue | Failure reason string, or nil when the last plan succeeded.
        methods.add_method("getLastFailureReason", |_, this, ()| {
            Ok(this
                .inner
                .borrow()
                .last_failure_reason
                .as_ref()
                .map(|reason| reason.as_str()))
        });
        // -- getLastTrace --
        /// Returns the last structured GOAP planning trace.
        /// @return | table | Table containing `selected_goal`, `chosen_plan`, `iterations`, `expanded_nodes`, and `failure_reason`.
        methods.add_method("getLastTrace", |lua, this, ()| {
            goap_trace_to_lua(lua, &this.inner.borrow().last_trace)
        });
        // -- type --
        /// Returns the Lua-visible type name for this GOAP planner handle.
        /// @return | string | The string `LGOAPPlanner`.
        methods.add_method("type", |_, _, ()| Ok("LGOAPPlanner"));
        // -- typeOf --
        /// Returns whether this GOAP planner handle matches a supported type name.
        /// @param | name | string | Type name to compare against `GOAPPlanner` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LGOAPPlanner" || name == "LObject")
        });
    }
}
/// Lua handle for a named squad with members, leader, formation, and shared blackboard.
#[derive(Clone)]
struct LuaSquad {
    /// Shared squad data exposed to Lua.
    inner: Rc<RefCell<Squad>>,
}
impl LuaUserData for LuaSquad {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- getName --
        /// Returns the squad name. This method is available to Lua scripts.
        /// @return | string | Squad name supplied at construction.
        methods.add_method("getName", |_, this, ()| {
            Ok(this.inner.borrow().name.clone())
        });
        // -- addMember --
        /// Adds a member name to the squad member list.
        /// @param | name | string | Agent or game object name to append as a squad member.
        methods.add_method("addMember", |_, this, name: String| {
            this.inner.borrow_mut().add_member(&name);
            Ok(())
        });
        // -- removeMember --
        /// Removes every member entry with the given name.
        /// @param | name | string | Member name to remove.
        methods.add_method("removeMember", |_, this, name: String| {
            this.inner.borrow_mut().remove_member(&name);
            Ok(())
        });
        // -- getMemberCount --
        /// Returns the number of members in this squad.
        /// @return | integer | Current member count.
        methods.add_method("getMemberCount", |_, this, ()| {
            Ok(this.inner.borrow().members.len())
        });
        // -- getMembers --
        /// Returns all squad members in an array-style Lua table.
        /// @return | string[] | Member names.
        methods.add_method("getMembers", |lua, this, ()| {
            let sq = this.inner.borrow();
            let tbl = lua.create_table()?;
            for (i, m) in sq.members.iter().enumerate() {
                tbl.set(i as i64 + 1, m.as_str())?;
            }
            Ok(tbl)
        });
        // -- setLeader --
        /// Sets the squad leader name. This method is available to Lua scripts.
        /// @param | name | string | Member or agent name to store as leader.
        methods.add_method("setLeader", |_, this, name: String| {
            this.inner.borrow_mut().set_leader(Some(name));
            Ok(())
        });
        // -- getLeader --
        /// Returns the squad leader name when one is assigned.
        /// @return | LuaValue | Leader name, or nil when no leader is assigned.
        methods.add_method("getLeader", |_, this, ()| {
            Ok(this.inner.borrow().leader.clone())
        });
        // -- setFormation --
        /// Sets the squad formation type and optionally updates spacing.
        /// @param | ftype | string | Formation type name parsed by the engine.
        /// @param | spacing | number? | Optional spacing between formation slots.
        methods.add_method(
            "setFormation",
            |_, this, (ftype, spacing): (String, Option<f32>)| {
                this.inner
                    .borrow_mut()
                    .set_formation(FormationType::parse_str(&ftype), spacing);
                Ok(())
            },
        );
        // -- getFormation --
        /// Returns the current squad formation type name.
        /// @return | string | Formation type name.
        methods.add_method("getFormation", |_, this, ()| {
            Ok(this.inner.borrow().formation.as_str().to_string())
        });
        // -- getFormationSpacing --
        /// Returns the spacing used by squad formation positioning.
        /// @return | number | Formation spacing in world units.
        methods.add_method("getFormationSpacing", |_, this, ()| {
            Ok(this.inner.borrow().formation_spacing)
        });
        // -- getFormationPosition --
        /// Returns a member's target formation position relative to the leader position.
        /// @param | member_idx | integer | One-based member index in the squad.
        /// @param | leader_x | number | Leader X position in world units.
        /// @param | leader_y | number | Leader Y position in world units.
        /// @return | number, number | X and Y formation target position.
        methods.add_method(
            "getFormationPosition",
            |_, this, (member_idx, leader_x, leader_y): (usize, f32, f32)| {
                Ok(this
                    .inner
                    .borrow()
                    .get_formation_position(member_idx.saturating_sub(1), (leader_x, leader_y)))
            },
        );
        // -- setMemberProfile --
        /// Stores footprint and subgroup metadata used during formation slot assignment.
        /// @param | name | string | Member name whose formation profile should be stored.
        /// @param | opts | table | Table with `footprintW`, `footprintH`, and optional `subgroup`.
        methods.add_method("setMemberProfile", |_, this, (name, opts): (String, LuaTable)| {
            let profile = squad_member_profile_from_lua(&opts)?;
            this.inner.borrow_mut().set_member_profile(&name, profile);
            Ok(())
        });
        // -- getMemberProfile --
        /// Returns the stored footprint and subgroup metadata for one member.
        /// @param | name | string | Member name to inspect.
        /// @return | table | Table containing `footprintW`, `footprintH`, and optional `subgroup`.
        methods.add_method("getMemberProfile", |lua, this, name: String| {
            let profile = this.inner.borrow().member_profile(&name);
            squad_member_profile_to_lua(lua, &profile)
        });
        // -- setFormationBehavior --
        /// Sets formation assignment behavior knobs used for slot ordering and chokepoint fallback.
        /// @param | sort_mode | string | Ordering strategy such as `roster` or `distance`.
        /// @param | fallback_mode | string? | Fallback strategy such as `keep` or `column`; defaults to `keep`.
        /// @param | preserve_subgroups | boolean? | Whether subgroup labels should stay clustered; defaults to false.
        methods.add_method(
            "setFormationBehavior",
            |_, this, (sort_mode, fallback_mode, preserve_subgroups): (String, Option<String>, Option<bool>)| {
                this.inner.borrow_mut().set_formation_behavior(
                    FormationSortMode::parse_str(&sort_mode),
                    FormationFallbackMode::parse_str(
                        fallback_mode.as_deref().unwrap_or("keep"),
                    ),
                    preserve_subgroups.unwrap_or(false),
                );
                Ok(())
            },
        );
        // -- getFormationBehavior --
        /// Returns the current formation assignment behavior settings.
        /// @return | table | Table containing `sortMode`, `fallbackMode`, and `preserveSubgroups`.
        methods.add_method("getFormationBehavior", |lua, this, ()| {
            let squad = this.inner.borrow();
            let out = lua.create_table()?;
            out.set("sortMode", squad.sort_mode.as_str())?;
            out.set("fallbackMode", squad.fallback_mode.as_str())?;
            out.set("preserveSubgroups", squad.preserve_subgroups)?;
            Ok(out)
        });
        // -- getFormationSlots --
        /// Returns resolved formation slot assignments for every member, optionally using current member positions and lane width.
        /// @param | leader_x | number | Leader X position in world units.
        /// @param | leader_y | number | Leader Y position in world units.
        /// @param | opts | table? | Optional table with `laneWidth` and `positions = { member = { x = ..., y = ... } }`.
        /// @return | table | Array of slot tables containing `member`, `slotIndex`, `x`, `y`, `row`, `col`, `footprintW`, `footprintH`, and `subgroup`.
        methods.add_method(
            "getFormationSlots",
            |lua, this, (leader_x, leader_y, opts): (f32, f32, Option<LuaTable>)| {
                let leader_x = lua_require_finite_f32("squad leader_x", leader_x)?;
                let leader_y = lua_require_finite_f32("squad leader_y", leader_y)?;
                let lane_width = match &opts {
                    Some(opts) => opts
                        .get::<_, Option<f32>>("laneWidth")?
                        .map(|value| lua_require_finite_f32("squad laneWidth", value))
                        .transpose()?,
                    None => None,
                };
                let member_positions = match opts {
                    Some(opts) => squad_member_positions_from_lua(opts.get("positions").ok())?,
                    None => None,
                };
                let layout = this.inner.borrow().get_formation_layout(
                    (leader_x, leader_y),
                    lane_width,
                    member_positions.as_ref(),
                );
                formation_layout_slots_to_lua(lua, &layout)
            },
        );
        // -- getFormationSummary --
        /// Returns formation layout metadata after slot assignment and fallback policy are resolved.
        /// @param | leader_x | number | Leader X position in world units.
        /// @param | leader_y | number | Leader Y position in world units.
        /// @param | opts | table? | Optional table with `laneWidth` and `positions = { member = { x = ..., y = ... } }`.
        /// @return | table | Table containing `requestedFormation`, `activeFormation`, `fallbackApplied`, `width`, `height`, and `slotCount`.
        methods.add_method(
            "getFormationSummary",
            |lua, this, (leader_x, leader_y, opts): (f32, f32, Option<LuaTable>)| {
                let leader_x = lua_require_finite_f32("squad leader_x", leader_x)?;
                let leader_y = lua_require_finite_f32("squad leader_y", leader_y)?;
                let lane_width = match &opts {
                    Some(opts) => opts
                        .get::<_, Option<f32>>("laneWidth")?
                        .map(|value| lua_require_finite_f32("squad laneWidth", value))
                        .transpose()?,
                    None => None,
                };
                let member_positions = match opts {
                    Some(opts) => squad_member_positions_from_lua(opts.get("positions").ok())?,
                    None => None,
                };
                let layout = this.inner.borrow().get_formation_layout(
                    (leader_x, leader_y),
                    lane_width,
                    member_positions.as_ref(),
                );
                formation_layout_summary_to_lua(lua, &layout)
            },
        );
        // -- assignFormationMove --
        /// Resolves formation slots and applies queued `move` orders to matching agents in the supplied world.
        /// @param | world | LAIWorld | AI world whose agent names are matched against squad members.
        /// @param | leader_x | number | Leader or anchor X position in world units.
        /// @param | leader_y | number | Leader or anchor Y position in world units.
        /// @param | opts | table? | Optional table with `laneWidth`, `positions`, `mode = replace|push_front|enqueue`, `priority`, and `interruptible`.
        /// @return | table | Table with formation summary fields plus `assignedCount`, `missingMembers`, and `slots` that include `commandId` and `applied`.
        methods.add_method(
            "assignFormationMove",
            |lua, this, (world_ud, leader_x, leader_y, opts): (LuaAnyUserData, f32, f32, Option<LuaTable>)| {
                let leader_x = lua_require_finite_f32("squad leader_x", leader_x)?;
                let leader_y = lua_require_finite_f32("squad leader_y", leader_y)?;
                let lane_width = match &opts {
                    Some(opts) => opts
                        .get::<_, Option<f32>>("laneWidth")?
                        .map(|value| lua_require_finite_f32("squad laneWidth", value))
                        .transpose()?,
                    None => None,
                };
                let mode = match &opts {
                    Some(opts) => {
                        let mode = opts
                            .get::<_, Option<String>>("mode")?
                            .unwrap_or_else(|| "replace".to_string());
                        match mode.as_str() {
                            "replace" | "push_front" | "enqueue" => mode,
                            _ => {
                                return Err(lua_ai_runtime_error(format!(
                                    "lurek.ai.LSquad:assignFormationMove invalid mode '{mode}'"
                                )))
                            }
                        }
                    }
                    None => "replace".to_string(),
                };
                let priority = match &opts {
                    Some(opts) => opts.get::<_, Option<i32>>("priority")?.unwrap_or(0),
                    None => 0,
                };
                let interruptible = match &opts {
                    Some(opts) => opts.get::<_, Option<bool>>("interruptible")?.unwrap_or(true),
                    None => true,
                };
                let world_handle = {
                    let world = world_ud.borrow::<LuaAIWorld>()?;
                    world.inner.clone()
                };
                let member_positions = match opts {
                    Some(opts) => match opts
                        .get::<_, Option<LuaTable>>("positions")
                        .map_err(|err| {
                            lua_ai_runtime_error(format!(
                                "lurek.ai.LSquad:assignFormationMove positions must be a table: {err}"
                            ))
                        })? {
                        Some(table) => squad_member_positions_from_lua(Some(table))?,
                        None => {
                            let squad = this.inner.borrow();
                            let world = world_handle.borrow();
                            Some(squad_member_positions_from_world(&squad, &world))
                        }
                    },
                    None => {
                        let squad = this.inner.borrow();
                        let world = world_handle.borrow();
                        Some(squad_member_positions_from_world(&squad, &world))
                    }
                };
                let layout = this.inner.borrow().get_formation_layout(
                    (leader_x, leader_y),
                    lane_width,
                    member_positions.as_ref(),
                );
                let mut command_ids: HashMap<String, u64> = HashMap::new();
                let mut missing_members: Vec<String> = Vec::new();
                {
                    let mut world = world_handle.borrow_mut();
                    for slot in &layout.slots {
                        let Some(agent) = world.agent_mut(&slot.member) else {
                            missing_members.push(slot.member.clone());
                            continue;
                        };
                        let queue = &mut agent.command_queue;
                        let id = match mode.as_str() {
                            "enqueue" => {
                                queue.enqueue_raw(
                                    "move".to_string(),
                                    slot.x,
                                    slot.y,
                                    priority,
                                    interruptible,
                                    None,
                                )
                            }
                            "push_front" => {
                                queue.push_front_raw(
                                    "move".to_string(),
                                    slot.x,
                                    slot.y,
                                    priority,
                                    interruptible,
                                    None,
                                )
                            }
                            _ => {
                                queue.replace_raw(
                                    "move".to_string(),
                                    slot.x,
                                    slot.y,
                                    priority,
                                    interruptible,
                                    None,
                                )
                            }
                        };
                        command_ids.insert(slot.member.clone(), id);
                    }
                }
                let out = formation_layout_summary_to_lua(lua, &layout)?;
                out.set("assignedCount", command_ids.len() as i64)?;
                let missing_tbl = lua.create_table()?;
                for (i, member) in missing_members.iter().enumerate() {
                    missing_tbl.set(i + 1, member.as_str())?;
                }
                out.set("missingMembers", missing_tbl)?;
                let slots_tbl = lua.create_table()?;
                for (i, slot) in layout.slots.iter().enumerate() {
                    let entry = lua.create_table()?;
                    entry.set("member", slot.member.as_str())?;
                    entry.set("slotIndex", slot.slot_index as u32)?;
                    entry.set("x", slot.x)?;
                    entry.set("y", slot.y)?;
                    entry.set("row", slot.row)?;
                    entry.set("col", slot.col)?;
                    entry.set("footprintW", slot.footprint_w)?;
                    entry.set("footprintH", slot.footprint_h)?;
                    entry.set("subgroup", slot.subgroup.clone())?;
                    entry.set("commandId", command_ids.get(&slot.member).copied())?;
                    entry.set("applied", command_ids.contains_key(&slot.member))?;
                    slots_tbl.set(i + 1, entry)?;
                }
                out.set("slots", slots_tbl)?;
                Ok(out)
            },
        );
        // -- submitFormationPaths --
        /// Resolves formation slots, converts world positions into navigation cells, and submits one async paired path batch.
        /// @param | world | LAIWorld | AI world whose agent positions provide the path start cells.
        /// @param | grid | LNavGrid | Navigation grid cloned for the async worker.
        /// @param | leader_x | number | Leader or anchor X position in world units.
        /// @param | leader_y | number | Leader or anchor Y position in world units.
        /// @param | opts | table | Options with `cellSize`, optional `originX`,`originY`,`laneWidth`,`positions`,`requestId`,`ownerId`,`version`,`priority`,`footprint`,`unitSize`, and `maxSteps`.
        /// @return | table | Table with formation summary fields plus async request metadata, slot-cell mappings, and skipped-member diagnostics.
        methods.add_method(
            "submitFormationPaths",
            |lua, this, (world_ud, grid_ud, leader_x, leader_y, opts): (LuaAnyUserData, LuaAnyUserData, f32, f32, LuaTable)| {
                let leader_x = lua_require_finite_f32("squad leader_x", leader_x)?;
                let leader_y = lua_require_finite_f32("squad leader_y", leader_y)?;
                let cell_size = lua_require_positive_f32(
                    "squad submitFormationPaths cellSize",
                    opts.get::<_, f32>("cellSize")?,
                )?;
                let origin_x = lua_require_finite_f32(
                    "squad submitFormationPaths originX",
                    opts.get::<_, Option<f32>>("originX")?.unwrap_or(0.0),
                )?;
                let origin_y = lua_require_finite_f32(
                    "squad submitFormationPaths originY",
                    opts.get::<_, Option<f32>>("originY")?.unwrap_or(0.0),
                )?;
                let lane_width = opts
                    .get::<_, Option<f32>>("laneWidth")?
                    .map(|value| lua_require_finite_f32("squad laneWidth", value))
                    .transpose()?;
                let priority = opts.get::<_, Option<i32>>("priority")?.unwrap_or(0);
                let max_steps = opts.get::<_, Option<u32>>("maxSteps")?.unwrap_or(0);
                let request_id = opts
                    .get::<_, Option<u64>>("requestId")?
                    .unwrap_or_else(next_async_path_request_id);
                let (owner_id, version) = {
                    let squad = this.inner.borrow();
                    let owner_id = opts
                        .get::<_, Option<u64>>("ownerId")?
                        .unwrap_or_else(|| squad.default_path_request_owner_id());
                    let version = opts
                        .get::<_, Option<u64>>("version")?
                        .unwrap_or_else(|| squad.next_path_request_version());
                    (owner_id, version)
                };
                let (grid_snapshot, dims, footprint) = {
                    let grid = grid_ud.borrow::<LuaNavGrid>()?;
                    let footprint =
                        if let Some(name) = opts.get::<_, Option<String>>("footprint")? {
                            grid.footprint(&name).ok_or_else(|| {
                                lua_ai_runtime_error(format!(
                                    "lurek.ai.LSquad:submitFormationPaths unknown footprint '{name}'"
                                ))
                            })?
                        } else {
                            let unit_size = opts.get::<_, Option<u32>>("unitSize")?.unwrap_or(1);
                            FootprintSpec::new(unit_size, unit_size)
                        };
                    (grid.cloned_grid(), grid.dimensions(), footprint)
                };
                let world_handle = {
                    let world = world_ud.borrow::<LuaAIWorld>()?;
                    world.inner.clone()
                };
                let member_positions = match opts
                    .get::<_, Option<LuaTable>>("positions")
                    .map_err(|err| {
                        lua_ai_runtime_error(format!(
                            "lurek.ai.LSquad:submitFormationPaths positions must be a table: {err}"
                        ))
                    })? {
                    Some(table) => squad_member_positions_from_lua(Some(table))?,
                    None => {
                        let squad = this.inner.borrow();
                        let world = world_handle.borrow();
                        Some(squad_member_positions_from_world(&squad, &world))
                    }
                };
                let layout = this.inner.borrow().get_formation_layout(
                    (leader_x, leader_y),
                    lane_width,
                    member_positions.as_ref(),
                );
                let mut pairs = Vec::new();
                let mut slot_cells = Vec::with_capacity(layout.slots.len());
                let mut missing_members: Vec<String> = Vec::new();
                let mut out_of_bounds = Vec::new();
                {
                    let world = world_handle.borrow();
                    for slot in &layout.slots {
                        let Some(agent) = world.agent(&slot.member) else {
                            missing_members.push(slot.member.clone());
                            continue;
                        };
                        let start_cell = world_point_to_nav_cell(
                            agent.position,
                            (origin_x, origin_y),
                            cell_size,
                            dims,
                        );
                        let target_cell = world_point_to_nav_cell(
                            (slot.x, slot.y),
                            (origin_x, origin_y),
                            cell_size,
                            dims,
                        );
                        if start_cell.is_none() {
                            out_of_bounds.push((slot.member.clone(), "start".to_string(), agent.position));
                        }
                        if target_cell.is_none() {
                            out_of_bounds.push((slot.member.clone(), "target".to_string(), (slot.x, slot.y)));
                        }
                        if let (Some(start_cell), Some(target_cell)) = (start_cell, target_cell) {
                            pairs.push((start_cell, target_cell));
                            slot_cells.push((slot, Some(start_cell), Some(target_cell), true));
                        } else {
                            slot_cells.push((slot, start_cell, target_cell, false));
                        }
                    }
                }
                if pairs.is_empty() {
                    return Err(lua_ai_runtime_error(
                        "lurek.ai.LSquad:submitFormationPaths produced no valid start/target cell pairs",
                    ));
                }

                submit_async_query(AsyncPathRequest {
                    id: request_id,
                    owner_id,
                    version,
                    priority,
                    grid: grid_snapshot,
                    start: (0, 0),
                    goal: (0, 0),
                    unit_size: footprint.width.max(footprint.height),
                    stream_budget: 0,
                    batch_starts: None,
                    batch_targets: None,
                    batch_pairs: Some(pairs),
                    batch_footprint: Some(footprint),
                    batch_max_steps: max_steps,
                });

                let out = formation_layout_summary_to_lua(lua, &layout)?;
                out.set("requestId", request_id)?;
                out.set("ownerId", owner_id)?;
                out.set("version", version)?;
                out.set(
                    "submittedCount",
                    slot_cells
                        .iter()
                        .filter(|(_, _, _, submitted)| *submitted)
                        .count() as i64,
                )?;
                out.set("cellSize", cell_size)?;
                out.set("originX", origin_x)?;
                out.set("originY", origin_y)?;
                let missing_tbl = lua.create_table()?;
                for (i, member) in missing_members.iter().enumerate() {
                    missing_tbl.set(i + 1, member.as_str())?;
                }
                out.set("missingMembers", missing_tbl)?;
                let out_of_bounds_tbl = lua.create_table()?;
                for (i, (member, which, position)) in out_of_bounds.iter().enumerate() {
                    let entry = lua.create_table()?;
                    entry.set("member", member.as_str())?;
                    entry.set("which", which.as_str())?;
                    entry.set("x", position.0)?;
                    entry.set("y", position.1)?;
                    out_of_bounds_tbl.set(i + 1, entry)?;
                }
                out.set("outOfBoundsMembers", out_of_bounds_tbl)?;
                let slots_tbl = lua.create_table()?;
                for (i, (slot, start_cell, target_cell, submitted)) in slot_cells.iter().enumerate() {
                    let entry = lua.create_table()?;
                    entry.set("member", slot.member.as_str())?;
                    entry.set("slotIndex", slot.slot_index as u32)?;
                    entry.set("x", slot.x)?;
                    entry.set("y", slot.y)?;
                    entry.set("row", slot.row)?;
                    entry.set("col", slot.col)?;
                    entry.set("footprintW", slot.footprint_w)?;
                    entry.set("footprintH", slot.footprint_h)?;
                    entry.set("subgroup", slot.subgroup.clone())?;
                    entry.set("submitted", *submitted)?;
                    entry.set("startCellX", start_cell.map(|cell| cell.0 + 1))?;
                    entry.set("startCellY", start_cell.map(|cell| cell.1 + 1))?;
                    entry.set("targetCellX", target_cell.map(|cell| cell.0 + 1))?;
                    entry.set("targetCellY", target_cell.map(|cell| cell.1 + 1))?;
                    slots_tbl.set(i + 1, entry)?;
                }
                out.set("slots", slots_tbl)?;
                Ok(out)
            },
        );
        // -- getBlackboard --
        /// Returns a blackboard snapshot for this squad.
        /// @return | LAIBlackboard | Blackboard handle initialized from the squad blackboard values at call time.
        methods.add_method("getBlackboard", |_, this, ()| {
            let sq = this.inner.borrow();
            Ok(LuaAIBlackboard {
                inner: Rc::new(RefCell::new(sq.blackboard.clone())),
            })
        });
        // -- type --
        /// Returns the Lua-visible type name for this squad handle.
        /// @return | string | The string `LSquad`.
        methods.add_method("type", |_, _, ()| Ok("LSquad"));
        // -- typeOf --
        /// Returns whether this squad handle matches a supported type name.
        /// @param | name | string | Type name to compare against `Squad` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LSquad" || name == "LObject")
        });
    }
}
/// Storage variants for standalone and agent-owned command queues exposed to Lua.
#[derive(Clone)]
enum CommandQueueBinding {
    /// Standalone queue created through `lurek.ai.newCommandQueue()`.
    Standalone(Rc<RefCell<CommandQueue>>),
    /// Queue owned by one agent in an AI world.
    Agent {
        /// Shared AI world storing the referenced agent.
        world: Rc<RefCell<AIWorld>>,
        /// Stable agent name used for lookup on each command-queue operation.
        name: String,
    },
}

/// Lua handle for a command queue that stores ordered callback-backed commands.
#[derive(Clone)]
struct LuaCommandQueue {
    /// Queue binding that resolves either to a standalone queue or an agent-owned queue.
    inner: CommandQueueBinding,
}

impl LuaCommandQueue {
    fn with_queue<R>(&self, f: impl FnOnce(&CommandQueue) -> R) -> Option<R> {
        match &self.inner {
            CommandQueueBinding::Standalone(inner) => Some(f(&inner.borrow())),
            CommandQueueBinding::Agent { world, name } => {
                let world = world.borrow();
                world.agent(name).map(|agent| f(&agent.command_queue))
            }
        }
    }

    fn with_queue_mut<R>(&self, f: impl FnOnce(&mut CommandQueue) -> R) -> Option<R> {
        match &self.inner {
            CommandQueueBinding::Standalone(inner) => Some(f(&mut inner.borrow_mut())),
            CommandQueueBinding::Agent { world, name } => {
                let mut world = world.borrow_mut();
                world.agent_mut(name).map(|agent| f(&mut agent.command_queue))
            }
        }
    }
}
/// Parses command option tables and returns target coordinates, priority, and interruptibility defaults.
fn parse_command_opts(opts: &Option<LuaTable>) -> LuaResult<(f32, f32, i32, bool)> {
    match opts {
        Some(tbl) => {
            let tx: f32 = tbl.get("targetX").unwrap_or(0.0);
            let ty: f32 = tbl.get("targetY").unwrap_or(0.0);
            let priority: i32 = tbl.get("priority").unwrap_or(0);
            let interruptible: bool = tbl.get("interruptible").unwrap_or(true);
            Ok((tx, ty, priority, interruptible))
        }
        None => Ok((0.0, 0.0, 0, true)),
    }
}
impl LuaUserData for LuaCommandQueue {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- enqueue --
        /// Adds a command callback to the back of the queue.
        /// @param | kind | string | Command type label stored for inspection.
        /// @param | callback | function | Callback invoked by command execution logic outside this wrapper.
        /// @param | opts | table? | Optional table with `targetX`, `targetY`, `priority`, and `interruptible` fields.
        /// @return | integer | Stable command id assigned by this queue.
        methods.add_method(
            "enqueue",
            |lua, this, (kind, callback, opts): (String, LuaFunction, Option<LuaTable>)| {
                let key = lua.create_registry_value(callback)?;
                let (tx, ty, priority, interruptible) = parse_command_opts(&opts)?;
                let id = this
                    .with_queue_mut(|queue| {
                        queue.enqueue_raw(kind, tx, ty, priority, interruptible, Some(key))
                    })
                    .unwrap_or(0);
                Ok(id as i64)
            },
        );
        // -- pushFront --
        /// Adds a command callback to the front of the queue.
        /// @param | kind | string | Command type label stored for inspection.
        /// @param | callback | function | Callback invoked by command execution logic outside this wrapper.
        /// @param | opts | table? | Optional table with `targetX`, `targetY`, `priority`, and `interruptible` fields.
        /// @return | integer | Stable command id assigned by this queue.
        methods.add_method(
            "pushFront",
            |lua, this, (kind, callback, opts): (String, LuaFunction, Option<LuaTable>)| {
                let key = lua.create_registry_value(callback)?;
                let (tx, ty, priority, interruptible) = parse_command_opts(&opts)?;
                let id = this
                    .with_queue_mut(|queue| {
                        queue.push_front_raw(kind, tx, ty, priority, interruptible, Some(key))
                    })
                    .unwrap_or(0);
                Ok(id as i64)
            },
        );
        // -- replace --
        /// Replaces the queue contents with one command callback.
        /// @param | kind | string | Command type label stored for inspection.
        /// @param | callback | function | Callback invoked by command execution logic outside this wrapper.
        /// @param | opts | table? | Optional table with `targetX`, `targetY`, `priority`, and `interruptible` fields.
        /// @return | integer | Stable command id assigned to the replacement command.
        methods.add_method(
            "replace",
            |lua, this, (kind, callback, opts): (String, LuaFunction, Option<LuaTable>)| {
                let key = lua.create_registry_value(callback)?;
                let (tx, ty, priority, interruptible) = parse_command_opts(&opts)?;
                let id = this
                    .with_queue_mut(|queue| {
                        queue.replace_raw(kind, tx, ty, priority, interruptible, Some(key))
                    })
                    .unwrap_or(0);
                Ok(id as i64)
            },
        );
        // -- cancelCurrent --
        /// Cancels the currently active command when one exists.
        /// @param | reason | string? | Optional lifecycle detail string recorded on cancellation events.
        /// @return | boolean | True when a current command was cancelled.
        methods.add_method("cancelCurrent", |_, this, reason: Option<String>| {
            Ok(this
                .with_queue_mut(|queue| queue.cancel_current_with_reason(reason))
                .unwrap_or(false))
        });
        // -- clear --
        /// Removes every queued command. This method is available to Lua scripts.
        /// @param | reason | string? | Optional lifecycle detail string recorded on clear events.
        /// @return | integer | Number of cleared commands.
        methods.add_method("clear", |_, this, reason: Option<String>| {
            Ok(this
                .with_queue_mut(|queue| queue.clear_with_reason(reason))
                .unwrap_or(0))
        });
        // -- getCount --
        /// Returns the number of commands currently queued.
        /// @return | integer | Current queue length.
        methods.add_method("getCount", |_, this, ()| {
            Ok(this.with_queue(|queue| queue.count()).unwrap_or(0))
        });
        // -- isEmpty --
        /// Returns whether the command queue has no commands.
        /// @return | boolean | True when the queue is empty.
        methods.add_method("isEmpty", |_, this, ()| {
            Ok(this.with_queue(|queue| queue.is_empty()).unwrap_or(true))
        });
        // -- getCurrentType --
        /// Returns the type label of the current command when one exists.
        /// @return | LuaValue | Current command type label, or nil when no command is active.
        methods.add_method("getCurrentType", |_, this, ()| {
            Ok(this
                .with_queue(|queue| queue.current_type().map(str::to_string))
                .flatten())
        });
        // -- getCurrentTarget --
        /// Returns the current command target coordinates.
        /// @return | number, number | Target X and Y coordinates for the current command, or queue defaults.
        methods.add_method("getCurrentTarget", |_, this, ()| {
            Ok(this
                .with_queue(|queue| queue.current_target())
                .unwrap_or((0.0, 0.0)))
        });
        // -- getCurrent --
        /// Returns the full current command snapshot when one exists.
        /// @return | LuaValue | Table with `id`, `kind`, `targetX`, `targetY`, `priority`, and `interruptible`, or nil when no command is active.
        methods.add_method("getCurrent", |lua, this, ()| {
            let snapshot = this.with_queue(|queue| queue.current()).flatten();
            snapshot
                .as_ref()
                .map(|snapshot| command_snapshot_to_lua(lua, snapshot))
                .transpose()
        });
        // -- getPending --
        /// Returns every pending command snapshot in queue order.
        /// @return | table | Array of `{ id, kind, targetX, targetY, priority, interruptible }` tables.
        methods.add_method("getPending", |lua, this, ()| {
            let snapshots = this.with_queue(|queue| queue.pending()).unwrap_or_default();
            command_snapshots_to_lua(lua, &snapshots)
        });
        // -- completeCurrent --
        /// Marks the current command as completed and advances the queue.
        /// @param | reason | string? | Optional lifecycle detail string recorded on the completion event.
        /// @return | LuaValue | Completed command id, or nil when the queue is empty.
        methods.add_method("completeCurrent", |_, this, reason: Option<String>| {
            Ok(this
                .with_queue_mut(|queue| queue.complete_current(reason))
                .flatten()
                .map(|id| id as i64))
        });
        // -- failCurrent --
        /// Marks the current command as failed and advances the queue.
        /// @param | reason | string? | Optional lifecycle detail string recorded on the failure event.
        /// @return | boolean | True when a command was marked failed.
        methods.add_method("failCurrent", |_, this, reason: Option<String>| {
            Ok(this
                .with_queue_mut(|queue| queue.fail_current(reason))
                .unwrap_or(false))
        });
        // -- drainEvents --
        /// Returns and clears queued lifecycle events.
        /// @return | table | Array of `{ id, kind, event, targetX, targetY, priority, interruptible, detail }` tables in emit order.
        methods.add_method("drainEvents", |lua, this, ()| {
            let events = this
                .with_queue_mut(|queue| queue.drain_events())
                .unwrap_or_default();
            command_events_to_lua(lua, &events)
        });
        // -- type --
        /// Returns the Lua-visible type name for this command queue handle.
        /// @return | string | The string `LCommandQueue`.
        methods.add_method("type", |_, _, ()| Ok("LCommandQueue"));
        // -- typeOf --
        /// Returns whether this command queue handle matches a supported type name.
        /// @param | name | string | Type name to compare against `CommandQueue` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LCommandQueue" || name == "LObject")
        });
    }
}
/// Lua handle for named trait archetypes used to create reusable AI personalities.
#[derive(Clone)]
struct LuaTraitArchetypes {
    /// Shared archetype registry.
    inner: Rc<RefCell<TraitArchetypes>>,
}
impl LuaUserData for LuaTraitArchetypes {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- register --
        /// Registers or replaces one named archetype from a table of trait values.
        /// @param | name | string | Archetype name.
        /// @param | traits | table | Map of trait names to numeric values.
        methods.add_method_mut("register", |_, this, (name, traits): (String, LuaTable)| {
            this.inner
                .borrow_mut()
                .register(&name, lua_table_to_f32_map(traits)?);
            Ok(())
        });
        // -- createProfile --
        /// Creates a trait profile from a registered archetype and optional deterministic variance.
        /// @param | name | string | Archetype name to copy.
        /// @param | variance | number? | Maximum deterministic trait jitter; defaults to zero.
        /// @return | LuaValue | New trait profile, or nil when the archetype is unknown.
        methods.add_method(
            "createProfile",
            |_, this, (name, variance): (String, Option<f32>)| {
                let variance = variance.unwrap_or(0.0).max(0.0);
                Ok(
                    TraitProfile::from_archetype(&this.inner.borrow(), &name, variance).map(
                        |profile| LuaTraitProfile {
                            inner: Rc::new(RefCell::new(profile)),
                        },
                    ),
                )
            },
        );
        // -- names --
        /// Returns registered archetype names.
        /// @return | table | Array of archetype names.
        methods.add_method("names", |lua, this, ()| {
            let out = lua.create_table()?;
            for (i, name) in this.inner.borrow().names().iter().enumerate() {
                out.set(i + 1, *name)?;
            }
            Ok(out)
        });
        // -- count --
        /// Returns the number of registered archetypes.
        /// @return | integer | Archetype count.
        methods.add_method(
            "count",
            |_, this, ()| Ok(this.inner.borrow().count() as i64),
        );
        // -- type --
        /// Returns the Lua-visible type name for this archetype registry handle.
        /// @return | string | The string `LTraitArchetypes`.
        methods.add_method("type", |_, _, ()| Ok("LTraitArchetypes"));
        // -- typeOf --
        /// Returns whether this archetype registry handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LTraitArchetypes` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LTraitArchetypes" || name == "LObject")
        });
    }
}

/// Lua handle for open-ended rules that map traits to action or goal score changes.
#[derive(Clone)]
struct LuaDecisionBiasSet {
    /// Shared decision bias rules.
    inner: Rc<RefCell<DecisionBiasSet>>,
}
impl LuaUserData for LuaDecisionBiasSet {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- addRule --
        /// Adds one rule that adjusts a named decision score using one trait.
        /// @param | trait_name | string | Trait key read from a profile.
        /// @param | decision_key | string | Action or goal key affected by this rule; `*` applies to every key.
        /// @param | weight | number | Adjustment strength; negative values reduce the score.
        /// @param | mode | string? | `add` or `multiply`; defaults to `add`.
        methods.add_method_mut(
            "addRule",
            |_, this, (trait_name, decision_key, weight, mode): (String, String, f32, Option<String>)| {
                let weight = lua_require_finite_f32("decision bias weight", weight)?;
                this.inner.borrow_mut().add_rule(
                    &trait_name,
                    &decision_key,
                    weight,
                    mode.as_deref().unwrap_or("add"),
                );
                Ok(())
            },
        );
        // -- score --
        /// Scores one decision using a profile and this bias set.
        /// @param | profile | LTraitProfile | Profile that supplies trait values.
        /// @param | decision_key | string | Decision key to score.
        /// @param | base_score | number | Base score before bias rules.
        /// @return | number | Biased score clamped to `[0, 1]`.
        methods.add_method(
            "score",
            |_, this, (profile_ud, decision_key, base_score): (LuaAnyUserData, String, f32)| {
                let base_score = lua_require_finite_f32("decision bias base_score", base_score)?;
                let profile = profile_ud.borrow::<LuaTraitProfile>()?;
                let score = {
                    let profile_ref = profile.inner.borrow();
                    this.inner
                        .borrow()
                        .score_decision(&profile_ref, &decision_key, base_score)
                };
                Ok(score)
            },
        );
        // -- ruleCount --
        /// Returns the number of stored bias rules.
        /// @return | integer | Rule count.
        methods.add_method("ruleCount", |_, this, ()| {
            Ok(this.inner.borrow().rule_count() as i64)
        });
        // -- type --
        /// Returns the Lua-visible type name for this decision bias handle.
        /// @return | string | The string `LDecisionBiasSet`.
        methods.add_method("type", |_, _, ()| Ok("LDecisionBiasSet"));
        // -- typeOf --
        /// Returns whether this decision bias handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LDecisionBiasSet` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LDecisionBiasSet" || name == "LObject")
        });
    }
}

/// Lua handle for trait values with temporary modifiers and archetype lookup.
#[derive(Clone)]
struct LuaTraitProfile {
    /// Shared trait profile containing base traits and active modifiers.
    inner: Rc<RefCell<TraitProfile>>,
}
impl LuaUserData for LuaTraitProfile {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- set --
        /// Sets the base value for a named trait.
        /// @param | name | string | Trait name to create or update.
        /// @param | value | number | Base trait value.
        methods.add_method_mut("set", |_, this, (name, value): (String, f32)| {
            this.inner.borrow_mut().set(&name, value);
            Ok(())
        });
        // -- get --
        /// Returns the current value of a named trait including active modifiers.
        /// @param | name | string | Trait name to read.
        /// @return | number | Effective trait value.
        methods.add_method("get", |_, this, name: String| {
            Ok(this.inner.borrow().get(&name))
        });
        // -- getBase --
        /// Returns the base value of a named trait without temporary modifiers.
        /// @param | name | string | Trait name to read.
        /// @return | number | Base trait value.
        methods.add_method("getBase", |_, this, name: String| {
            Ok(this.inner.borrow().get_base(&name))
        });
        // -- addModifier --
        /// Adds a temporary or permanent modifier to a named trait.
        /// @param | trait_name | string | Trait name affected by the modifier.
        /// @param | delta | number | Value added to the trait while the modifier is active.
        /// @param | duration | number? | Modifier lifetime in seconds, or nil for engine-defined permanent duration.
        /// @param | source | string | Source label used to remove related modifiers later.
        methods.add_method_mut(
            "addModifier",
            |_, this, (trait_name, delta, duration, source): (String, f32, Option<f32>, String)| {
                this.inner
                    .borrow_mut()
                    .add_modifier(&trait_name, delta, duration, &source);
                Ok(())
            },
        );
        // -- removeModifiers --
        /// Removes all trait modifiers that match a source label.
        /// @param | source | string | Source label to remove.
        methods.add_method_mut("removeModifiers", |_, this, source: String| {
            this.inner.borrow_mut().remove_modifiers_by_source(&source);
            Ok(())
        });
        // -- update --
        /// Advances modifier timers and removes expired modifiers.
        /// @param | dt | number | Elapsed time in seconds.
        methods.add_method_mut("update", |_, this, dt: f32| {
            this.inner.borrow_mut().update(dt);
            Ok(())
        });
        // -- has --
        /// Returns whether the profile has a named trait.
        /// @param | name | string | Trait name to check.
        /// @return | boolean | True when the trait exists.
        methods.add_method("has", |_, this, name: String| {
            Ok(this.inner.borrow().has(&name))
        });
        // -- names --
        /// Returns this profile's trait names.
        /// @return | table | Array of trait names.
        methods.add_method("names", |lua, this, ()| {
            let out = lua.create_table()?;
            for (i, name) in this.inner.borrow().trait_names_owned().iter().enumerate() {
                out.set(i + 1, name.as_str())?;
            }
            Ok(out)
        });
        // -- scoreDecision --
        /// Scores one decision by applying a decision bias set to this profile.
        /// @param | biases | LDecisionBiasSet | Bias rules to apply.
        /// @param | decision_key | string | Action or goal key to score.
        /// @param | base_score | number | Base score before bias rules.
        /// @return | number | Biased score clamped to `[0, 1]`.
        methods.add_method(
            "scoreDecision",
            |_, this, (bias_ud, decision_key, base_score): (LuaAnyUserData, String, f32)| {
                let base_score =
                    lua_require_finite_f32("trait profile decision base_score", base_score)?;
                let bias = bias_ud.borrow::<LuaDecisionBiasSet>()?;
                let score = {
                    let profile_ref = this.inner.borrow();
                    bias.inner
                        .borrow()
                        .score_decision(&profile_ref, &decision_key, base_score)
                };
                Ok(score)
            },
        );
        // -- traitCount --
        /// Returns the number of traits stored in the profile.
        /// @return | integer | Current trait count.
        methods.add_method("traitCount", |_, this, ()| {
            Ok(this.inner.borrow().trait_count() as i64)
        });
        // -- archetype --
        /// Returns the best matching archetype name when the profile can classify one.
        /// @return | LuaValue | Archetype name, or nil when no archetype matches.
        methods.add_method("archetype", |_, this, ()| {
            Ok(this.inner.borrow().archetype().map(|s| s.to_string()))
        });
        // -- type --
        /// Returns the Lua-visible type name for this trait profile handle.
        /// @return | string | The string `LTraitProfile`.
        methods.add_method("type", |_, _, ()| Ok("LTraitProfile"));
        // -- typeOf --
        /// Returns whether this trait profile handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LTraitProfile` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LTraitProfile" || name == "LObject")
        });
    }
}
/// Lua handle for sensory stimuli tracked in world space.
#[derive(Clone)]
struct LuaStimulusWorld {
    /// Shared stimulus world containing active visual and auditory stimuli.
    inner: Rc<RefCell<StimulusWorld>>,
}
impl LuaUserData for LuaStimulusWorld {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- addVisual --
        /// Adds a visual stimulus and returns its identifier.
        /// @param | x | number | Stimulus X position in world units.
        /// @param | y | number | Stimulus Y position in world units.
        /// @param | intensity | number | Initial stimulus intensity.
        /// @param | radius | number | Stimulus radius in world units.
        /// @param | tag | string? | Optional category tag for game-side filtering.
        /// @return | integer | New stimulus identifier.
        methods.add_method_mut(
            "addVisual",
            |_, this, (x, y, intensity, radius, tag): (f32, f32, f32, f32, Option<String>)| {
                Ok(this
                    .inner
                    .borrow_mut()
                    .add_visual(x, y, intensity, radius, tag) as i64)
            },
        );
        // -- addAuditory --
        /// Adds an auditory stimulus with decay and returns its identifier.
        /// @param | x | number | Stimulus X position in world units.
        /// @param | y | number | Stimulus Y position in world units.
        /// @param | intensity | number | Initial stimulus intensity.
        /// @param | radius | number | Stimulus radius in world units.
        /// @param | decay_rate | number | Intensity decay rate applied during updates.
        /// @param | tag | string? | Optional category tag for game-side filtering.
        /// @return | integer | New stimulus identifier.
        methods.add_method_mut(
            "addAuditory",
            |_,
             this,
             (x, y, intensity, radius, decay_rate, tag): (
                f32,
                f32,
                f32,
                f32,
                f32,
                Option<String>,
            )| {
                Ok(this
                    .inner
                    .borrow_mut()
                    .add_auditory(x, y, intensity, radius, decay_rate, tag)
                    as i64)
            },
        );
        // -- remove --
        /// Removes a stimulus by identifier. This method is available to Lua scripts.
        /// @param | id | integer | Stimulus identifier returned by `addVisual` or `addAuditory`.
        /// @return | boolean | True when a stimulus was removed.
        methods.add_method_mut("remove", |_, this, id: u64| {
            Ok(this.inner.borrow_mut().remove(id))
        });
        // -- update --
        /// Advances stimulus decay and lifetime state.
        /// @param | dt | number | Elapsed time in seconds.
        methods.add_method_mut("update", |_, this, dt: f32| {
            this.inner.borrow_mut().update(dt);
            Ok(())
        });
        // -- count --
        /// Returns the number of active stimuli.
        /// @return | integer | Active stimulus count.
        methods.add_method(
            "count",
            |_, this, ()| Ok(this.inner.borrow().count() as i64),
        );
        // -- clear --
        /// Removes every active stimulus. This method is available to Lua scripts.
        methods.add_method_mut("clear", |_, this, ()| {
            this.inner.borrow_mut().clear();
            Ok(())
        });
        // -- type --
        /// Returns the Lua-visible type name for this stimulus world handle.
        /// @return | string | The string `LStimulusWorld`.
        methods.add_method("type", |_, _, ()| Ok("LStimulusWorld"));
        // -- typeOf --
        /// Returns whether this stimulus world handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LStimulusWorld` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LStimulusWorld" || name == "LObject")
        });
    }
}
/// Lua handle for decaying needs and urgency selection.
#[derive(Clone)]
struct LuaNeedSystem {
    /// Shared need system containing named need values and urgency settings.
    inner: Rc<RefCell<NeedSystem>>,
}
impl LuaUserData for LuaNeedSystem {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- addNeed --
        /// Adds a need with decay and urgency tuning values.
        /// @param | name | string | Need name used by satisfaction and lookup calls.
        /// @param | decay_rate | number | Value decay rate applied during updates.
        /// @param | urgency_threshold | number | Value threshold where the need becomes urgent.
        /// @param | urgency_factor | number | Weight applied to urgent needs.
        methods.add_method_mut("addNeed", |_, this, (name, decay_rate, urgency_threshold, urgency_factor): (String, f32, f32, f32)| {
            this.inner.borrow_mut().add_need(Need::new(&name, decay_rate, urgency_threshold, urgency_factor));
            Ok(())
        });
        // -- update --
        /// Advances need decay over elapsed time.
        /// @param | dt | number | Elapsed time in seconds.
        methods.add_method_mut("update", |_, this, dt: f32| {
            this.inner.borrow_mut().update(dt);
            Ok(())
        });
        // -- mostUrgent --
        /// Returns the name of the most urgent need when any need is active.
        /// @return | LuaValue | Need name, or nil when no urgent need is available.
        methods.add_method("mostUrgent", |_, this, ()| {
            Ok(this.inner.borrow().most_urgent().map(|s| s.to_string()))
        });
        // -- satisfy --
        /// Reduces or satisfies a named need by the supplied amount.
        /// @param | name | string | Need name to satisfy.
        /// @param | amount | number | Amount applied to the need value.
        methods.add_method_mut("satisfy", |_, this, (name, amount): (String, f32)| {
            this.inner.borrow_mut().satisfy(&name, amount);
            Ok(())
        });
        // -- valueOf --
        /// Returns the current value of a named need.
        /// @param | name | string | Need name to read.
        /// @return | number | Current need value.
        methods.add_method("valueOf", |_, this, name: String| {
            Ok(this.inner.borrow().value_of(&name))
        });
        // -- type --
        /// Returns the Lua-visible type name for this need system handle.
        /// @return | string | The string `LNeedSystem`.
        methods.add_method("type", |_, _, ()| Ok("LNeedSystem"));
        // -- typeOf --
        /// Returns whether this need system handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LNeedSystem` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LNeedSystem" || name == "LObject")
        });
    }
}
/// Lua handle for an AI director that tracks encounter tension and pacing factors.
#[derive(Clone)]
struct LuaAIDirector {
    /// Shared AI director containing tension, phase, and derived pacing values.
    inner: Rc<RefCell<AIDirector>>,
}
impl LuaUserData for LuaAIDirector {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- pushEvent --
        /// Adds an event intensity sample to the director tension model.
        /// @param | intensity | number | Event intensity added to current tension.
        methods.add_method_mut("pushEvent", |_, this, intensity: f32| {
            this.inner.borrow_mut().push_event(intensity);
            Ok(())
        });
        // -- update --
        /// Advances director tension decay and phase evaluation.
        /// @param | dt | number | Elapsed time in seconds.
        methods.add_method_mut("update", |_, this, dt: f32| {
            this.inner.borrow_mut().update(dt);
            Ok(())
        });
        // -- tension --
        /// Returns the current director tension value.
        /// @return | number | Current tension.
        methods.add_method("tension", |_, this, ()| Ok(this.inner.borrow().tension()));
        // -- phase --
        /// Returns the current director phase name.
        /// @return | string | Current pacing phase.
        methods.add_method("phase", |_, this, ()| {
            Ok(this.inner.borrow().phase_str().to_string())
        });
        // -- spawnRateFactor --
        /// Returns the spawn-rate multiplier derived from current tension and phase.
        /// @return | number | Spawn rate factor.
        methods.add_method("spawnRateFactor", |_, this, ()| {
            Ok(this.inner.borrow().spawn_rate_factor())
        });
        // -- lootFactor --
        /// Returns the loot multiplier derived from current tension and phase.
        /// @return | number | Loot factor.
        methods.add_method("lootFactor", |_, this, ()| {
            Ok(this.inner.borrow().loot_factor())
        });
        // -- ambientIntensity --
        /// Returns the ambient intensity derived from current tension and phase.
        /// @return | number | Ambient intensity factor.
        methods.add_method("ambientIntensity", |_, this, ()| {
            Ok(this.inner.borrow().ambient_intensity())
        });
        // -- setTension --
        /// Directly sets the director tension value.
        /// @param | value | number | New tension value.
        methods.add_method_mut("setTension", |_, this, value: f32| {
            this.inner.borrow_mut().set_tension(value);
            Ok(())
        });
        // -- reset --
        /// Resets director tension and phase state to defaults.
        methods.add_method_mut("reset", |_, this, ()| {
            this.inner.borrow_mut().reset();
            Ok(())
        });
        // -- type --
        /// Returns the Lua-visible type name for this AI director handle.
        /// @return | string | The string `LAIDirector`.
        methods.add_method("type", |_, _, ()| Ok("LAIDirector"));
        // -- typeOf --
        /// Returns whether this AI director handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LAIDirector` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LAIDirector" || name == "LObject")
        });
    }
}
/// Lua handle for a hierarchical task network domain.
#[derive(Clone)]
struct LuaHTNDomain {
    /// Shared HTN domain containing primitive and compound task definitions.
    inner: Rc<RefCell<HTNDomain>>,
}
impl LuaUserData for LuaHTNDomain {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- addPrimitive --
        /// Adds a primitive HTN task with preconditions, effects, and cleared facts.
        /// @param | name | string | Primitive task name.
        /// @param | preconds | table | Array of fact names required before the task can run.
        /// @param | effects | table | Array of fact names added by the task.
        /// @param | clears | table | Array of fact names removed by the task.
        methods.add_method_mut("addPrimitive", |_, this, (name, preconds, effects, clears): (String, Vec<String>, Vec<String>, Vec<String>)| {
            let p: Vec<&str> = preconds.iter().map(|s| s.as_str()).collect();
            let e: Vec<&str> = effects.iter().map(|s| s.as_str()).collect();
            let c: Vec<&str> = clears.iter().map(|s| s.as_str()).collect();
            this.inner.borrow_mut().add_primitive(&name, p, e, c);
            Ok(())
        });
        // -- addCompound --
        /// Adds a compound HTN task with one or more ordered method definitions.
        /// @param | comp_name | string | Compound task name.
        /// @param | methods_table | table | Array of method tables with `name`, `preconditions`, and `sub_tasks` fields.
        methods.add_method_mut(
            "addCompound",
            |lua, this, (comp_name, methods_table): (String, LuaTable)| {
                let mut htn_methods: Vec<HTNMethod> = Vec::new();
                for i in 1..=methods_table.raw_len() {
                    let m: LuaTable = methods_table.raw_get(i)?;
                    let preconds: Vec<String> = m
                        .raw_get::<_, Vec<String>>("preconditions")
                        .unwrap_or_default();
                    let sub_tasks: Vec<String> =
                        m.raw_get::<_, Vec<String>>("sub_tasks").unwrap_or_default();
                    let mname: String = m
                        .raw_get::<_, String>("name")
                        .unwrap_or_else(|_| format!("method_{i}"));
                    let p: Vec<&str> = preconds.iter().map(|s| s.as_str()).collect();
                    let s: Vec<&str> = sub_tasks.iter().map(|s| s.as_str()).collect();
                    htn_methods.push(HTNMethod::with_preconditions(&mname, p, s));
                }
                this.inner
                    .borrow_mut()
                    .add_compound(&comp_name, htn_methods);
                let _ = lua;
                Ok(())
            },
        );
        // -- plan --
        /// Plans from a root HTN task and numeric world state facts.
        /// @param | root_task | string | Root task name to decompose.
        /// @param | state_table | table | Map table from fact names to numeric values.
        /// @return | LuaValue | Array table of primitive task names, or nil when no plan is found.
        methods.add_method(
            "plan",
            |lua, this, (root_task, state_table): (String, LuaTable)| {
                let mut state: WorldState = std::collections::HashMap::new();
                for pair in state_table.pairs::<String, f32>() {
                    let (k, v) = pair?;
                    state.insert(k, v);
                }
                let result = HTNPlanner::plan(&this.inner.borrow(), &root_task, &state);
                match result {
                    None => Ok(LuaValue::Nil),
                    Some(plan) => {
                        let t = lua.create_table()?;
                        for (i, step) in plan.into_iter().enumerate() {
                            t.raw_set(i + 1, step)?;
                        }
                        Ok(LuaValue::Table(t))
                    }
                }
            },
        );
        // -- taskCount --
        /// Returns the number of tasks defined in this HTN domain.
        /// @return | integer | Current task count.
        methods.add_method("taskCount", |_, this, ()| {
            Ok(this.inner.borrow().task_count() as i64)
        });
        // -- type --
        /// Returns the Lua-visible type name for this HTN domain handle.
        /// @return | string | The string `LHTNDomain`.
        methods.add_method("type", |_, _, ()| Ok("LHTNDomain"));
        // -- typeOf --
        /// Returns whether this HTN domain handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LHTNDomain` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LHTNDomain" || name == "LObject")
        });
    }
}
/// Lua handle for Monte Carlo tree search over Lua-defined game states and actions.
#[derive(Clone)]
struct LuaMCTSEngine {
    /// Shared MCTS engine containing search configuration and deterministic state.
    inner: Rc<RefCell<MCTSEngine>>,
}
impl LuaUserData for LuaMCTSEngine {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- search --
        /// Runs MCTS from a root state using Lua callbacks for actions, transitions, and evaluation.
        /// @param | root_state | integer | Opaque integer state identifier supplied by game code.
        /// @param | get_actions_fn | function | Function called with a state and returning an array of integer actions.
        /// @param | apply_fn | function | Function called with `(state, action)` and returning the next state integer.
        /// @param | eval_fn | function | Function called with a state and returning a numeric score.
        /// @return | LuaValue | Selected action integer, or nil when search cannot choose an action.
        methods.add_method_mut(
            "search",
            |_,
             this,
             (root_state, get_actions_fn, apply_fn, eval_fn): (
                i64,
                LuaFunction,
                LuaFunction,
                LuaFunction,
            )| {
                let mut engine = this.inner.borrow_mut();
                let callback_errors = Rc::new(RefCell::new(Vec::<CallbackErrorTrace>::new()));
                let mut get_actions = |s: &i64| -> Vec<i32> {
                    match get_actions_fn.call::<_, Vec<i32>>(*s) {
                        Ok(actions) => actions,
                        Err(err) => {
                            callback_errors.borrow_mut().push(CallbackErrorTrace {
                                context: "mcts.get_actions".to_string(),
                                message: err.to_string(),
                            });
                            Vec::new()
                        }
                    }
                };
                let mut apply_action = |s: &i64, action: i32| -> i64 {
                    match apply_fn.call::<_, i64>((*s, action)) {
                        Ok(next_state) => next_state,
                        Err(err) => {
                            callback_errors.borrow_mut().push(CallbackErrorTrace {
                                context: format!("mcts.apply_action.{action}"),
                                message: err.to_string(),
                            });
                            *s
                        }
                    }
                };
                let mut evaluate = |s: &i64| -> f32 {
                    match eval_fn.call::<_, f32>(*s) {
                        Ok(score) => score,
                        Err(err) => {
                            callback_errors.borrow_mut().push(CallbackErrorTrace {
                                context: "mcts.evaluate".to_string(),
                                message: err.to_string(),
                            });
                            0.0
                        }
                    }
                };
                let result = engine.search(
                    root_state,
                    &mut get_actions,
                    &mut apply_action,
                    &mut evaluate,
                );
                engine.set_last_callback_errors(callback_errors.borrow().clone());
                Ok(result.map(|a| a as i64))
            },
        );
        // -- getLastTrace --
        /// Returns the last structured MCTS search trace.
        /// @return | table | Table containing `chosen_action`, `iterations_run`, `nodes_expanded`, `invalid_score_count`, `callback_errors`, and `failure_reason`.
        methods.add_method("getLastTrace", |lua, this, ()| {
            mcts_trace_to_lua(lua, &this.inner.borrow().last_trace)
        });
        // -- type --
        /// Returns the Lua-visible type name for this MCTS engine handle.
        /// @return | string | The string `LMCTSEngine`.
        methods.add_method("type", |_, _, ()| Ok("LMCTSEngine"));
        // -- typeOf --
        /// Returns whether this MCTS engine handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LMCTSEngine` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LMCTSEngine" || name == "LObject")
        });
    }
}
/// Lua handle for decaying named emotion intensities.
#[derive(Clone)]
struct LuaEmotionModel {
    /// Shared emotion model containing emotion definitions and current intensities.
    inner: Rc<RefCell<EmotionModel>>,
}
impl LuaUserData for LuaEmotionModel {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- add --
        /// Adds an emotion definition with resting value, decay, and visibility threshold.
        /// @param | name | string | Emotion name.
        /// @param | rest | number | Resting emotion value.
        /// @param | decay | number | Decay rate back toward rest.
        /// @param | min_vis | number | Minimum value considered visible or active.
        methods.add_method_mut(
            "add",
            |_, this, (name, rest, decay, min_vis): (String, f32, f32, f32)| {
                this.inner
                    .borrow_mut()
                    .add(Emotion::new(&name, rest, decay, min_vis));
                Ok(())
            },
        );
        // -- trigger --
        /// Adds an amount to a named emotion. This method is available to Lua scripts.
        /// @param | name | string | Emotion name to trigger.
        /// @param | amount | number | Amount added to the current emotion value.
        methods.add_method_mut("trigger", |_, this, (name, amount): (String, f32)| {
            this.inner.borrow_mut().trigger(&name, amount);
            Ok(())
        });
        // -- get --
        /// Returns the current value of a named emotion.
        /// @param | name | string | Emotion name to read.
        /// @return | number | Current emotion value.
        methods.add_method("get", |_, this, name: String| {
            Ok(this.inner.borrow().get(&name))
        });
        // -- dominant --
        /// Returns the strongest active emotion name when one is available.
        /// @return | LuaValue | Dominant emotion name, or nil when no emotion is active.
        methods.add_method("dominant", |_, this, ()| {
            Ok(this.inner.borrow().dominant().map(|s| s.to_string()))
        });
        // -- isActive --
        /// Returns whether a named emotion is currently active.
        /// @param | name | string | Emotion name to check.
        /// @return | boolean | True when the emotion is above its active threshold.
        methods.add_method("isActive", |_, this, name: String| {
            Ok(this.inner.borrow().is_active(&name))
        });
        // -- update --
        /// Advances emotion decay over elapsed time.
        /// @param | dt | number | Elapsed time in seconds.
        methods.add_method_mut("update", |_, this, dt: f32| {
            this.inner.borrow_mut().update(dt);
            Ok(())
        });
        // -- reset --
        /// Resets all emotions toward their default state.
        methods.add_method_mut("reset", |_, this, ()| {
            this.inner.borrow_mut().reset();
            Ok(())
        });
        // -- type --
        /// Returns the Lua-visible type name for this emotion model handle.
        /// @return | string | The string `LEmotionModel`.
        methods.add_method("type", |_, _, ()| Ok("LEmotionModel"));
        // -- typeOf --
        /// Returns whether this emotion model handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LEmotionModel` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LEmotionModel" || name == "LObject")
        });
    }
}
/// Lua handle for interval-based strategic goal selection.
#[derive(Clone)]
struct LuaStrategyAI {
    /// Shared strategy AI model containing goals, tags, timing, and active selection.
    inner: Rc<RefCell<StrategyAI>>,
}
impl LuaUserData for LuaStrategyAI {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- addGoal --
        /// Adds a named strategic goal. This method is available to Lua scripts.
        /// @param | name | string | Goal name scored by update callbacks.
        methods.add_method_mut("addGoal", |_, this, name: String| {
            this.inner.borrow_mut().add_goal_named(&name);
            Ok(())
        });
        // -- addTag --
        /// Adds a context tag to this strategy AI.
        /// @param | tag | string | Tag name to add.
        methods.add_method_mut("addTag", |_, this, tag: String| {
            this.inner.borrow_mut().add_tag(&tag);
            Ok(())
        });
        // -- removeTag --
        /// Removes a context tag from this strategy AI.
        /// @param | tag | string | Tag name to remove.
        methods.add_method_mut("removeTag", |_, this, tag: String| {
            this.inner.borrow_mut().remove_tag(&tag);
            Ok(())
        });
        // -- update --
        /// Advances strategy timing and scores goals when the update interval has elapsed.
        /// @param | dt | number | Elapsed time in seconds.
        /// @param | scorer_fn | function | Function called with a goal name and returning a numeric score.
        methods.add_method_mut("update", |_, this, (dt, scorer_fn): (f32, LuaFunction)| {
            let mut scorer =
                |goal: &str| -> f32 { scorer_fn.call::<_, f32>(goal.to_string()).unwrap_or(0.0) };
            this.inner.borrow_mut().update(dt, &mut scorer);
            Ok(())
        });
        // -- forceEvaluate --
        /// Immediately scores all goals and updates the active goal.
        /// @param | scorer_fn | function | Function called with a goal name and returning a numeric score.
        methods.add_method_mut("forceEvaluate", |_, this, scorer_fn: LuaFunction| {
            let mut scorer =
                |goal: &str| -> f32 { scorer_fn.call::<_, f32>(goal.to_string()).unwrap_or(0.0) };
            this.inner.borrow_mut().force_evaluate(&mut scorer);
            Ok(())
        });
        // -- activeGoal --
        /// Returns the currently active strategic goal when one is selected.
        /// @return | LuaValue | Active goal name, or nil before selection.
        methods.add_method("activeGoal", |_, this, ()| {
            Ok(this.inner.borrow().active_goal().map(|s| s.to_string()))
        });
        // -- timeUntilNext --
        /// Returns time remaining until the next scheduled strategy evaluation.
        /// @return | number | Seconds until the next interval evaluation.
        methods.add_method("timeUntilNext", |_, this, ()| {
            Ok(this.inner.borrow().time_until_next())
        });
        // -- type --
        /// Returns the Lua-visible type name for this strategy AI handle.
        /// @return | string | The string `LStrategyAI`.
        methods.add_method("type", |_, _, ()| Ok("LStrategyAI"));
        // -- typeOf --
        /// Returns whether this strategy AI handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LStrategyAI` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LStrategyAI" || name == "LObject")
        });
    }
}
/// Lua handle for distance-based AI level-of-detail tier selection.
#[derive(Clone)]
struct LuaAILod {
    /// Shared AI LOD tier table and update cadence rules.
    inner: Rc<RefCell<AILod>>,
}
impl LuaUserData for LuaAILod {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- tierFor --
        /// Returns the LOD tier for an agent position relative to a reference position.
        /// @param | ax | number | Agent X position.
        /// @param | ay | number | Agent Y position.
        /// @param | rx | number | Reference X position, usually camera or player position.
        /// @param | ry | number | Reference Y position, usually camera or player position.
        /// @return | integer | Zero-based LOD tier index.
        methods.add_method(
            "tierFor",
            |_, this, (ax, ay, rx, ry): (f32, f32, f32, f32)| {
                Ok(this.inner.borrow().tier_for((ax, ay), (rx, ry)) as i64)
            },
        );
        // -- shouldUpdate --
        /// Returns whether a tier should update on a given frame counter.
        /// @param | tier | integer | Zero-based LOD tier index.
        /// @param | frame | integer | Current frame counter.
        /// @return | boolean | True when agents in the tier should update this frame.
        methods.add_method("shouldUpdate", |_, this, (tier, frame): (usize, u64)| {
            Ok(this.inner.borrow().should_update(tier, frame))
        });
        // -- tierCount --
        /// Returns the number of configured AI LOD tiers.
        /// @return | integer | LOD tier count.
        methods.add_method("tierCount", |_, this, ()| {
            Ok(this.inner.borrow().tier_count() as i64)
        });
        // -- tierName --
        /// Returns the name of an AI LOD tier when the index is valid.
        /// @param | tier | integer | Zero-based LOD tier index.
        /// @return | LuaValue | Tier name, or nil when the tier index is invalid.
        methods.add_method("tierName", |_, this, tier: usize| {
            Ok(this.inner.borrow().tier(tier).map(|t| t.name.clone()))
        });
        // -- type --
        /// Returns the Lua-visible type name for this AI LOD handle.
        /// @return | string | The string `LAILod`.
        methods.add_method("type", |_, _, ()| Ok("LAILod"));
        // -- typeOf --
        /// Returns whether this AI LOD handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LAILod` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LAILod" || name == "LObject")
        });
    }
}
/// Registers the `lurek.ai` API table with the Lua VM.
pub fn register(lua: &Lua, lurek: &LuaTable, _state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let tbl = lua.create_table()?;
    // -- newWorld --
    /// Creates an isolated AI world for agents, blackboards, and custom decision callbacks.
    /// @return | LAIWorld | New AI world handle.
    tbl.set(
        "newWorld",
        lua.create_function(|_, ()| {
            Ok(LuaAIWorld {
                inner: Rc::new(RefCell::new(AIWorld::new())),
                custom_callbacks: Rc::new(RefCell::new(CallbackRegistry::new())),
                last_callback_errors: Rc::new(RefCell::new(Vec::new())),
            })
        })?,
    )?;
    // -- newBlackboard --
    /// Creates an empty AI blackboard for typed local facts.
    /// @return | LAIBlackboard | New blackboard handle.
    tbl.set(
        "newBlackboard",
        lua.create_function(|_, ()| {
            Ok(LuaAIBlackboard {
                inner: Rc::new(RefCell::new(Blackboard::default())),
            })
        })?,
    )?;
    // -- newStateMachine --
    /// Creates an empty finite state machine with Lua-backed states and transitions.
    /// @return | LStateMachine | New state machine handle.
    tbl.set(
        "newStateMachine",
        lua.create_function(|_, ()| {
            Ok(LuaStateMachine {
                inner: Rc::new(RefCell::new(crate::ai::StateMachine::new())),
            })
        })?,
    )?;
    // -- newBehaviorTree --
    /// Creates an empty behavior tree that can receive a root node.
    /// @return | LBehaviorTree | New behavior tree handle.
    tbl.set(
        "newBehaviorTree",
        lua.create_function(|_, ()| {
            Ok(LuaBehaviorTree {
                inner: Rc::new(RefCell::new(BehaviorTree::new())),
            })
        })?,
    )?;
    // -- newSelector --
    /// Creates a behavior tree selector node with no children.
    /// @return | LBTNode | New selector node handle.
    tbl.set(
        "newSelector",
        lua.create_function(|_, ()| {
            Ok(LuaBTNode {
                inner: Rc::new(RefCell::new(BTNode::Selector {
                    children: Vec::new(),
                    running_idx: 0,
                })),
            })
        })?,
    )?;
    // -- newSequence --
    /// Creates a behavior tree sequence node with no children.
    /// @return | LBTNode | New sequence node handle.
    tbl.set(
        "newSequence",
        lua.create_function(|_, ()| {
            Ok(LuaBTNode {
                inner: Rc::new(RefCell::new(BTNode::Sequence {
                    children: Vec::new(),
                    running_idx: 0,
                })),
            })
        })?,
    )?;
    // -- newParallel --
    /// Creates a behavior tree parallel node with optional success and failure policies.
    /// @param | sp | string? | Success policy name; defaults to the engine's require-one policy.
    /// @param | fp | string? | Failure policy name; defaults to the engine's require-one policy.
    /// @return | LBTNode | New parallel node handle.
    tbl.set(
        "newParallel",
        lua.create_function(|_, (sp, fp): (Option<String>, Option<String>)| {
            Ok(LuaBTNode {
                inner: Rc::new(RefCell::new(BTNode::Parallel {
                    children: Vec::new(),
                    success_policy: sp
                        .map(|s| ParallelPolicy::parse_str(&s))
                        .unwrap_or(ParallelPolicy::RequireOne),
                    failure_policy: fp
                        .map(|s| ParallelPolicy::parse_str(&s))
                        .unwrap_or(ParallelPolicy::RequireOne),
                })),
            })
        })?,
    )?;
    // -- newInverter --
    /// Creates a behavior tree inverter decorator with an empty sequence child.
    /// @return | LBTNode | New inverter node handle.
    tbl.set(
        "newInverter",
        lua.create_function(|_, ()| {
            Ok(LuaBTNode {
                inner: Rc::new(RefCell::new(BTNode::Inverter {
                    child: Box::new(BTNode::Sequence {
                        children: Vec::new(),
                        running_idx: 0,
                    }),
                })),
            })
        })?,
    )?;
    // -- newRepeater --
    /// Creates a behavior tree repeater decorator with an optional repeat count.
    /// @param | count | integer? | Repeat count stored on the node; defaults to zero.
    /// @return | LBTNode | New repeater node handle.
    tbl.set(
        "newRepeater",
        lua.create_function(|_, count: Option<u32>| {
            Ok(LuaBTNode {
                inner: Rc::new(RefCell::new(BTNode::Repeater {
                    child: Box::new(BTNode::Sequence {
                        children: Vec::new(),
                        running_idx: 0,
                    }),
                    count: count.unwrap_or(0),
                    done: 0,
                })),
            })
        })?,
    )?;
    // -- newSucceeder --
    /// Creates a behavior tree succeeder decorator with an empty sequence child.
    /// @return | LBTNode | New succeeder node handle.
    tbl.set(
        "newSucceeder",
        lua.create_function(|_, ()| {
            Ok(LuaBTNode {
                inner: Rc::new(RefCell::new(BTNode::Succeeder {
                    child: Box::new(BTNode::Sequence {
                        children: Vec::new(),
                        running_idx: 0,
                    }),
                })),
            })
        })?,
    )?;
    // -- newAction --
    /// Creates a behavior tree action leaf backed by a Lua callback.
    /// @param | callback | function | Callback invoked when the action node ticks.
    /// @return | LBTNode | New action node handle.
    tbl.set(
        "newAction",
        lua.create_function(|lua, callback: LuaFunction| {
            let key = lua.create_registry_value(callback)?;
            Ok(LuaBTNode {
                inner: Rc::new(RefCell::new(BTNode::Action { callback: key })),
            })
        })?,
    )?;
    // -- newCondition --
    /// Creates a behavior tree condition leaf backed by a Lua callback.
    /// @param | callback | function | Callback invoked when the condition node ticks.
    /// @return | LBTNode | New condition node handle.
    tbl.set(
        "newCondition",
        lua.create_function(|lua, callback: LuaFunction| {
            let key = lua.create_registry_value(callback)?;
            Ok(LuaBTNode {
                inner: Rc::new(RefCell::new(BTNode::Condition { callback: key })),
            })
        })?,
    )?;
    // -- newGuard --
    /// Creates a guard decorator that runs a predicate before ticking its child.
    /// @param | predicate | function | Callback that decides whether the child may run.
    /// @param | child | LBTNode | Child node handle consumed by the guard.
    /// @return | LBTNode | New guard node handle.
    tbl.set(
        "newGuard",
        lua.create_function(
            |lua, (predicate, child_ud): (LuaFunction, LuaAnyUserData)| {
                let key = lua.create_registry_value(predicate)?;
                let child = child_ud.borrow::<LuaBTNode>()?;
                let taken = std::mem::replace(
                    &mut *child.inner.borrow_mut(),
                    BTNode::Sequence {
                        children: Vec::new(),
                        running_idx: 0,
                    },
                );
                Ok(LuaBTNode {
                    inner: Rc::new(RefCell::new(BTNode::Guard {
                        predicate: key,
                        child: Box::new(taken),
                    })),
                })
            },
        )?,
    )?;
    // -- newUtilityAI --
    /// Creates an empty utility AI action scorer.
    /// @return | LUtilityAI | New utility AI handle.
    tbl.set(
        "newUtilityAI",
        lua.create_function(|_, ()| {
            Ok(LuaUtilityAI {
                inner: Rc::new(RefCell::new(UtilityAI::new())),
                custom_callbacks: Rc::new(RefCell::new(CallbackRegistry::new())),
            })
        })?,
    )?;
    // -- newDialogueAI --
    /// Creates an empty dialogue selector for weighted topics and branches.
    /// @return | LDialogueAI | New dialogue AI handle.
    tbl.set(
        "newDialogueAI",
        lua.create_function(|_, ()| {
            Ok(LuaDialogueAI {
                inner: Rc::new(RefCell::new(DialogueAI::new())),
            })
        })?,
    )?;
    // -- newGOAPPlanner --
    /// Creates an empty GOAP planner for boolean world-state planning.
    /// @return | LGOAPPlanner | New GOAP planner handle.
    tbl.set(
        "newGOAPPlanner",
        lua.create_function(|_, ()| {
            Ok(LuaGOAPPlanner {
                inner: Rc::new(RefCell::new(GOAPPlanner::new())),
            })
        })?,
    )?;
    // -- newSquad --
    /// Creates an empty named squad. This function is exposed to Lua scripts.
    /// @param | name | string | Squad name stored on the handle.
    /// @return | LSquad | New squad handle.
    tbl.set(
        "newSquad",
        lua.create_function(|_, name: String| {
            Ok(LuaSquad {
                inner: Rc::new(RefCell::new(Squad::new(&name))),
            })
        })?,
    )?;
    // -- newCommandQueue --
    /// Creates an empty command queue for callback-backed AI commands.
    /// @return | LCommandQueue | New command queue handle.
    tbl.set(
        "newCommandQueue",
        lua.create_function(|_, ()| {
            Ok(LuaCommandQueue {
                inner: CommandQueueBinding::Standalone(Rc::new(RefCell::new(CommandQueue::new()))),
            })
        })?,
    )?;
    // -- newTraitProfile --
    /// Creates an empty trait profile with modifier support.
    /// @return | LTraitProfile | New trait profile handle.
    tbl.set(
        "newTraitProfile",
        lua.create_function(|_, ()| {
            Ok(LuaTraitProfile {
                inner: Rc::new(RefCell::new(TraitProfile::new())),
            })
        })?,
    )?;
    // -- newTraitArchetypes --
    /// Creates a trait archetype registry populated with engine-provided commander presets.
    /// @return | LTraitArchetypes | New archetype registry handle.
    tbl.set(
        "newTraitArchetypes",
        lua.create_function(|_, ()| {
            Ok(LuaTraitArchetypes {
                inner: Rc::new(RefCell::new(TraitArchetypes::with_builtins())),
            })
        })?,
    )?;
    // -- newDecisionBiasSet --
    /// Creates an empty set of rules that map profile traits onto named decision scores.
    /// @return | LDecisionBiasSet | New decision bias handle.
    tbl.set(
        "newDecisionBiasSet",
        lua.create_function(|_, ()| {
            Ok(LuaDecisionBiasSet {
                inner: Rc::new(RefCell::new(DecisionBiasSet::new())),
            })
        })?,
    )?;
    // -- newStimulusWorld --
    /// Creates an empty stimulus world for visual and auditory stimulus records.
    /// @return | LStimulusWorld | New stimulus world handle.
    tbl.set(
        "newStimulusWorld",
        lua.create_function(|_, ()| {
            Ok(LuaStimulusWorld {
                inner: Rc::new(RefCell::new(StimulusWorld::new())),
            })
        })?,
    )?;
    // -- newNeedSystem --
    /// Creates an empty need system for decaying named needs.
    /// @return | LNeedSystem | New need system handle.
    tbl.set(
        "newNeedSystem",
        lua.create_function(|_, ()| {
            Ok(LuaNeedSystem {
                inner: Rc::new(RefCell::new(NeedSystem::new())),
            })
        })?,
    )?;
    // -- newAIDirector --
    /// Creates an AI director for tension, phase, and pacing factor calculations.
    /// @return | LAIDirector | New AI director handle.
    tbl.set(
        "newAIDirector",
        lua.create_function(|_, ()| {
            Ok(LuaAIDirector {
                inner: Rc::new(RefCell::new(AIDirector::new())),
            })
        })?,
    )?;
    // -- newHTNDomain --
    /// Creates an empty hierarchical task network domain.
    /// @return | LHTNDomain | New HTN domain handle.
    tbl.set(
        "newHTNDomain",
        lua.create_function(|_, ()| {
            Ok(LuaHTNDomain {
                inner: Rc::new(RefCell::new(HTNDomain::new())),
            })
        })?,
    )?;
    // -- newMCTSEngine --
    /// Creates a Monte Carlo tree search engine with deterministic configuration.
    /// @param | iters | integer | Search iteration count.
    /// @param | uct_c | number | UCT exploration constant.
    /// @param | depth | integer | Rollout depth limit.
    /// @param | seed | integer | Random seed used by the engine.
    /// @return | LMCTSEngine | New MCTS engine handle.
    tbl.set(
        "newMCTSEngine",
        lua.create_function(|_, (iters, uct_c, depth, seed): (u32, f32, usize, u64)| {
            let cfg = MCTSConfig {
                iterations: iters,
                uct_c,
                rollout_depth: depth,
                seed,
            };
            Ok(LuaMCTSEngine {
                inner: Rc::new(RefCell::new(
                    MCTSEngine::try_new(cfg).map_err(lua_ai_runtime_error)?,
                )),
            })
        })?,
    )?;
    // -- newEmotionModel --
    /// Creates an empty emotion model for named decaying emotion values.
    /// @return | LEmotionModel | New emotion model handle.
    tbl.set(
        "newEmotionModel",
        lua.create_function(|_, ()| {
            Ok(LuaEmotionModel {
                inner: Rc::new(RefCell::new(EmotionModel::new())),
            })
        })?,
    )?;
    // -- newStrategyAI --
    /// Creates a strategy AI that reevaluates goals on a fixed interval.
    /// @param | update_interval | number | Seconds between automatic strategy evaluations.
    /// @return | LStrategyAI | New strategy AI handle.
    tbl.set(
        "newStrategyAI",
        lua.create_function(|_, update_interval: f32| {
            Ok(LuaStrategyAI {
                inner: Rc::new(RefCell::new(StrategyAI::new(update_interval))),
            })
        })?,
    )?;
    // -- newAILod --
    /// Creates a default AI level-of-detail tier selector.
    /// @return | LAILod | New AI LOD handle.
    tbl.set(
        "newAILod",
        lua.create_function(|_, ()| {
            Ok(LuaAILod {
                inner: Rc::new(RefCell::new(AILod::default())),
            })
        })?,
    )?;
    /// The 'ai' field value exposed to Lua scripts.
    lurek.set("ai", tbl)?;
    Ok(())
}
