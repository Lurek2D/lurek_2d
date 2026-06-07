//! Provides `LSceneObjectContainer` userdata wrapping the pure-Lua scene-objects
//! library. Supports add/remove/clear operations, per-frame update and draw cycles,
//! and layer-based depth sorting for painter-style rendering, plus object query
//! helpers (`getByLayer`, `has`).

use mlua::prelude::*;

/// Wraps the pure-Lua ObjectContainer implementation via embedded library code.
/// Stores the Lua table in a registry key to manage its lifetime.
pub struct LSceneObjectContainer {
    inner: LuaRegistryKey,
}

impl LSceneObjectContainer {
    /// Create a new scene object container.
    ///
    /// # Arguments
    /// - `lua`: Lua context
    ///
    /// # Returns
    /// New LSceneObjectContainer wrapping the embedded Lua library
    pub fn new(lua: &Lua) -> LuaResult<Self> {
        // Load the embedded library code
        let scene_objects_module = include_str!("../../library/scene-objects/init.lua");
        let scene_objects_lib: LuaTable = lua.load(scene_objects_module).eval()?;

        // Call the library's new() function
        let new_fn: LuaFunction = scene_objects_lib.get("new")?;
        let container_instance = new_fn.call::<_, LuaValue>(())?;

        // Store in registry
        let inner = lua.create_registry_value(container_instance)?;
        Ok(Self { inner })
    }

    /// Retrieve the stored Lua table with proper lifetime binding.
    pub fn get_container<'lua>(&self, lua: &'lua Lua) -> LuaResult<LuaTable<'lua>> {
        lua.registry_value::<LuaTable>(&self.inner)
    }
}


