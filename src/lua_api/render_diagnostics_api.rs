//! Registers bounded render diagnostics on the canonical `lurek.render` table.

use super::SharedState;
use mlua::prelude::*;
use std::cell::RefCell;
use std::rc::Rc;

/// Register resource, budget, and capability observations without owning state.
pub(super) fn register_diagnostics_api(
    lua: &Lua,
    graphics: &LuaTable,
    state: Rc<RefCell<SharedState>>,
) -> LuaResult<()> {
    let s = state.clone();
    // -- getResourceStats --
    /// Returns render-resource residency and pressure counters without mutating ownership.
    /// @return | table | Current retained bytes, counts, and effective resource budget.
    graphics.set(
        "getResourceStats",
        lua.create_function(move |lua, ()| {
            let stats = s.borrow().resource_memory_stats();
            let table = lua.create_table()?;
            table.set("texture_bytes", stats.texture_bytes)?;
            table.set("font_bytes", stats.font_bytes)?;
            table.set("canvas_bytes", stats.canvas_bytes)?;
            table.set("shader_bytes", stats.shader_bytes)?;
            table.set("evictable_bytes", stats.evictable_bytes)?;
            table.set("non_evictable_bytes", stats.non_evictable_bytes)?;
            table.set("total_bytes", stats.total_bytes)?;
            table.set("budget_bytes", stats.budget_bytes)?;
            table.set("texture_count", stats.texture_count)?;
            table.set("font_count", stats.font_count)?;
            table.set("canvas_count", stats.canvas_count)?;
            table.set("shader_count", stats.shader_count)?;
            Ok(table)
        })?,
    )?;
    let s = state.clone();
    // -- getBudgetLimits --
    /// Returns the effective, read-only aggregate render limits selected by the engine and active GPU.
    /// @return | table | Effective render budget limits. These values cannot be changed from Lua.
    graphics.set(
        "getBudgetLimits",
        lua.create_function(move |lua, ()| {
            let limits = s.borrow().render_budget_limits;
            let table = lua.create_table()?;
            table.set("commands", limits.max_commands)?;
            table.set("commands_per_family", limits.max_commands_per_family)?;
            table.set("geometry_vertices", limits.max_geometry_vertices)?;
            table.set("geometry_indices", limits.max_geometry_indices)?;
            table.set("text_bytes", limits.max_text_bytes)?;
            table.set("text_spans", limits.max_text_spans)?;
            table.set("glyphs", limits.max_glyphs)?;
            table.set("postfx_passes", limits.max_postfx_passes)?;
            table.set("sprite_batch_items", limits.max_sprite_batch_items)?;
            table.set("light_quads", limits.max_light_quads)?;
            table.set("shadow_lights", limits.max_shadow_lights)?;
            table.set("uploads", limits.max_uploads)?;
            table.set("upload_bytes", limits.max_upload_bytes)?;
            Ok(table)
        })?,
    )?;
    let s = state.clone();
    // -- getCapabilities --
    /// Returns stable, read-only capabilities and normalized active-device limits.
    /// @return | table | Capability snapshot; no raw backend identifiers or GPU objects are exposed.
    graphics.set(
        "getCapabilities",
        lua.create_function(move |lua, ()| {
            let capabilities = s.borrow().render_capabilities;
            let table = lua.create_table()?;
            table.set(
                "max_texture_dimension_2d",
                capabilities.max_texture_dimension_2d,
            )?;
            table.set("max_buffer_size", capabilities.max_buffer_size)?;
            table.set(
                "max_bindings_per_bind_group",
                capabilities.max_bindings_per_bind_group,
            )?;
            table.set("timestamp_queries", capabilities.timestamp_queries)?;
            table.set("asynchronous_readback", capabilities.asynchronous_readback)?;
            table.set(
                "deterministic_software_replay",
                capabilities.deterministic_software_replay,
            )?;
            table.set("shader_trust_mode", "project_fragment_only")?;
            Ok(table)
        })?,
    )?;
    Ok(())
}
