//! This file owns `QueryView`, the cached component-set view used by Lua-facing ECS query handles.
//! It stores normalized include and exclude names, cached ids, and the universe tick that produced them.
//! Refresh logic reuses cached results until `Universe` bumps its coarse query invalidation counter.
//! Open it when query-cache behavior changes; world mutations and component matching live in `universe.rs`.

use crate::ecs::universe::Universe;
use mlua::{Lua, Result as LuaResult};

/// Cached component query view used by the Lua ECS query-view handle.
pub(crate) struct QueryView {
    /// Required component names every matched entity must contain.
    include_names: Vec<String>,
    /// Forbidden component names that exclude an entity from the result.
    exclude_names: Vec<String>,
    /// Last cached entity-id result set.
    cached_ids: Vec<u32>,
    /// Universe query-change tick used to build `cached_ids`.
    last_change_tick: u64,
    /// Whether the cache has been populated at least once.
    initialized: bool,
}

impl QueryView {
    /// Creates a new query view from include and exclude component-name lists.
    pub(crate) fn new(include_names: Vec<String>, exclude_names: Vec<String>) -> Self {
        Self {
            include_names: normalize_names(include_names),
            exclude_names: normalize_names(exclude_names),
            cached_ids: Vec::new(),
            last_change_tick: 0,
            initialized: false,
        }
    }

    /// Returns the cached entity ids, refreshing when the universe change tick has advanced.
    pub(crate) fn ids<'a>(&'a mut self, universe: &Universe, lua: &Lua) -> LuaResult<&'a [u32]> {
        self.refresh(universe, lua)?;
        Ok(&self.cached_ids)
    }

    /// Refreshes the cached ids when the universe tick changed or when never initialized.
    pub(crate) fn refresh(&mut self, universe: &Universe, lua: &Lua) -> LuaResult<()> {
        let world_tick = universe.get_query_change_tick();
        if self.initialized && self.last_change_tick == world_tick {
            return Ok(());
        }
        self.cached_ids =
            universe.query_component_sets(lua, &self.include_names, &self.exclude_names)?;
        self.last_change_tick = world_tick;
        self.initialized = true;
        Ok(())
    }

    /// Returns the cached universe tick that produced the current ids.
    pub(crate) fn last_change_tick(&self) -> u64 {
        self.last_change_tick
    }
}

/// Sorts and deduplicates component-name lists so query views stay deterministic.
fn normalize_names(mut names: Vec<String>) -> Vec<String> {
    names.retain(|name| !name.is_empty());
    names.sort();
    names.dedup();
    names
}
