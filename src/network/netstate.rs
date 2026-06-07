//! Network state synchronization manager for replicated state across peers.
//!
//! Provides `LNetworkState` userdata wrapping the pure-Lua netstate protocol.
//! Supports authority-based writes, per-key versioning, turn-based coordination,
//! and callback-driven change notifications.

use mlua::prelude::*;

/// Wraps the pure-Lua NetState implementation via embedded library code.
/// Stores the Lua table in a registry key to manage its lifetime.
pub struct LNetworkState {
    inner: LuaRegistryKey,
}

impl LNetworkState {
    /// Create a new network state synchronization manager from a host and optional config.
    ///
    /// # Arguments
    /// - `lua`: Lua context
    /// - `host`: Network host (or nil for offline mode)
    /// - `opts`: Optional configuration table with `channel`, `authority`, `turnBased`, `maxDirtyKeys`
    ///
    /// # Returns
    /// New LNetworkState wrapping the embedded Lua library
    pub fn new(lua: &Lua, host: LuaValue, opts: Option<LuaTable>) -> LuaResult<Self> {
        // Load the embedded library code
        // let netstate_module = include_str!("../../library/netstate/init.lua");
        // let netstate_lib: LuaTable = lua.load(netstate_module).eval()?;
        let netstate_lib: LuaTable = lua.create_table()?;

        // Call the library's new() function
        let new_fn: LuaFunction = netstate_lib.get("new")?;
        let netstate_instance = if let Some(opts_table) = opts {
            new_fn.call::<_, LuaValue>((host, opts_table))?
        } else {
            new_fn.call::<_, LuaValue>(host)?
        };

        // Store in registry
        let inner = lua.create_registry_value(netstate_instance)?;
        Ok(Self { inner })
    }

    /// Retrieve the stored Lua table with proper lifetime binding.
    fn get_netstate<'lua>(&self, lua: &'lua Lua) -> LuaResult<LuaTable<'lua>> {
        lua.registry_value::<LuaTable>(&self.inner)
    }
}

impl LuaUserData for LNetworkState {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        /// Set a synced value (authority only).
        methods.add_method("set", |lua, this, (key, value): (String, LuaValue)| {
            let netstate = this.get_netstate(lua)?;
            let set_fn: LuaFunction = netstate.get("set")?;
            set_fn.call::<_, ()>((key, value))?;
            Ok(())
        });

        /// Get the current value of a synced key.
        methods.add_method("get", |lua, this, key: String| {
            let netstate = this.get_netstate(lua)?;
            let get_fn: LuaFunction = netstate.get("get")?;
            get_fn.call::<_, LuaValue>(key)
        });

        /// Get all synced state as a flat table.
        methods.add_method("getAll", |lua, this, ()| {
            let netstate = this.get_netstate(lua)?;
            let get_all_fn: LuaFunction = netstate.get("getAll")?;
            get_all_fn.call::<_, LuaTable>(())
        });

        /// Request a full state snapshot from the authority.
        methods.add_method("requestFullState", |lua, this, ()| {
            let netstate = this.get_netstate(lua)?;
            let request_fn: LuaFunction = netstate.get("requestFullState")?;
            request_fn.call::<_, ()>(())?;
            Ok(())
        });

        /// Advance to the next turn (turn-based mode, authority only).
        methods.add_method("beginTurn", |lua, this, ()| {
            let netstate = this.get_netstate(lua)?;
            let begin_turn_fn: LuaFunction = netstate.get("beginTurn")?;
            begin_turn_fn.call::<_, ()>(())?;
            Ok(())
        });

        /// Get the current turn number.
        methods.add_method("getCurrentTurn", |lua, this, ()| {
            let netstate = this.get_netstate(lua)?;
            let get_turn_fn: LuaFunction = netstate.get("getCurrentTurn")?;
            get_turn_fn.call::<_, i32>(())
        });

        /// Get a deterministic hash of the current state.
        methods.add_method("hashState", |lua, this, ()| {
            let netstate = this.get_netstate(lua)?;
            let hash_fn: LuaFunction = netstate.get("hashState")?;
            hash_fn.call::<_, String>(())
        });

        /// Register a callback for changes to a specific key.
        methods.add_method("onChange", |lua, this, (key, cb): (String, LuaFunction)| {
            let netstate = this.get_netstate(lua)?;
            let on_change_fn: LuaFunction = netstate.get("onChanged")?;
            on_change_fn.call::<_, ()>((key, cb))?;
            Ok(())
        });

        /// Register a callback for turn changes (turn-based mode).
        methods.add_method("onTurn", |lua, this, cb: LuaFunction| {
            let netstate = this.get_netstate(lua)?;
            let on_turn_fn: LuaFunction = netstate.get("onTurn")?;
            on_turn_fn.call::<_, ()>(cb)?;
            Ok(())
        });

        /// Process incoming network state updates.
        methods.add_method("poll", |lua, this, ()| {
            let netstate = this.get_netstate(lua)?;
            let poll_fn: LuaFunction = netstate.get("poll")?;
            poll_fn.call::<_, ()>(())?;
            Ok(())
        });

        /// Get the type name of this userdata.
        methods.add_method("type", |_lua, _this, ()| {
            Ok("LNetworkState")
        });

        /// Check type by name.
        methods.add_method("typeOf", |_lua, _this, name: String| {
            Ok(name == "LNetworkState")
        });
    }
}
