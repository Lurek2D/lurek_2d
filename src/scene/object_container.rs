//! Provides `LSceneObjectContainer` userdata wrapping the pure-Lua scene-objects. `scene/object_container` delivers the object container implementation for the scene subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! library. Supports add/remove/clear operations, per-frame update and draw cycles,. The file owns or coordinates data contracts including `LSceneObjectContainer`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! and layer-based depth sorting for painter-style rendering, plus object query. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `get_container` stays attached to the local data model and invariants.

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
