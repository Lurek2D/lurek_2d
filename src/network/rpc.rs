//! Remote Procedure Call (RPC) manager for networked function invocation.
//!
//! Provides request/response patterns, fire-and-forget notifications, and broadcasts
//! over network connections. Manages pending calls with timeout, automatic request ID
//! generation, and response callback dispatch.

use mlua::prelude::*;

/// RPC manager for network-based remote function invocation.
///
/// Wraps a Lua-implemented RPC protocol that manages:
/// - Request ID generation and timeout tracking
/// - Handler registration by function name
/// - Pending call registry and callback dispatch
/// - Request/response message encoding via `lurek.network.pack`
pub struct LNetworkRpc {
    /// Registry key pointing to the Lua RPC manager table.
    inner: LuaRegistryKey,
}

impl LNetworkRpc {
    /// Creates a new network RPC manager attached to a host.
    pub fn new(
        lua: &Lua,
        host: LuaValue,
        channel: Option<u8>,
        timeout: Option<f64>,
    ) -> LuaResult<Self> {
        // Load and execute the RPC library code in Lua
        // let rpc_module = include_str!("../../library/rpc/init.lua");
        // let rpc_lib: LuaTable = lua.load(rpc_module).eval()?;
        let rpc_lib: LuaTable = lua.create_table()?;

        // Call the library's .new() function
        let new_fn: LuaFunction = rpc_lib.get("new")?;
        let rpc_instance = match (channel, timeout) {
            (Some(ch), Some(to)) => new_fn.call::<_, LuaValue>((host, ch, to))?,
            (Some(ch), None) => new_fn.call::<_, LuaValue>((host, ch))?,
            (None, Some(to)) => new_fn.call::<_, LuaValue>((host, 0, to))?,
            (None, None) => new_fn.call::<_, LuaValue>((host, 0))?,
        };

        let inner = lua.create_registry_value(rpc_instance)?;
        Ok(Self { inner })
    }

    /// Gets the inner Lua RPC manager value for method dispatch.
    fn get_rpc<'lua>(&self, lua: &'lua Lua) -> LuaResult<LuaTable<'lua>> {
        let val: LuaValue = lua.registry_value(&self.inner)?;
        match val {
            LuaValue::Table(t) => Ok(t),
            _ => Err(LuaError::RuntimeError(
                "RPC instance is not a table".to_string(),
            )),
        }
    }
}

impl LuaUserData for LNetworkRpc {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        methods.add_method(
            "register",
            |lua, this, (name, fn_): (String, LuaFunction)| {
                let rpc = this.get_rpc(lua)?;
                let register_fn: LuaFunction = rpc.get("register")?;
                register_fn.call::<_, ()>((name, fn_))?;
                Ok(())
            },
        );

        methods.add_method("call", |lua, this, args: LuaMultiValue| {
            let rpc = this.get_rpc(lua)?;
            let call_fn: LuaFunction = rpc.get("call")?;
            call_fn.call::<_, ()>(args)?;
            Ok(())
        });

        methods.add_method("notify", |lua, this, args: LuaMultiValue| {
            let rpc = this.get_rpc(lua)?;
            let notify_fn: LuaFunction = rpc.get("notify")?;
            notify_fn.call::<_, ()>(args)?;
            Ok(())
        });

        methods.add_method("broadcast", |lua, this, args: LuaMultiValue| {
            let rpc = this.get_rpc(lua)?;
            let broadcast_fn: LuaFunction = rpc.get("broadcast")?;
            broadcast_fn.call::<_, ()>(args)?;
            Ok(())
        });

        methods.add_method("poll", |lua, this, ()| {
            let rpc = this.get_rpc(lua)?;
            let poll_fn: LuaFunction = rpc.get("poll")?;
            poll_fn.call::<_, LuaValue>(())
        });

        methods.add_method("onError", |lua, this, fn_: LuaFunction| {
            let rpc = this.get_rpc(lua)?;
            let on_error_fn: LuaFunction = rpc.get("onError")?;
            on_error_fn.call::<_, ()>(fn_)?;
            Ok(())
        });

        methods.add_method("setLogging", |lua, this, enabled: bool| {
            let rpc = this.get_rpc(lua)?;
            let set_log_fn: LuaFunction = rpc.get("setLogging")?;
            set_log_fn.call::<_, ()>(enabled)?;
            Ok(())
        });

        methods.add_method("setTimeout", |lua, this, seconds: f64| {
            let rpc = this.get_rpc(lua)?;
            let set_timeout_fn: LuaFunction = rpc.get("setTimeout")?;
            set_timeout_fn.call::<_, ()>(seconds)?;
            Ok(())
        });

        methods.add_method("resetIdCounter", |lua, this, ()| {
            let rpc = this.get_rpc(lua)?;
            let reset_fn: LuaFunction = rpc.get("resetIdCounter")?;
            reset_fn.call::<_, ()>(())?;
            Ok(())
        });

        methods.add_method("getNextId", |lua, this, ()| {
            let rpc = this.get_rpc(lua)?;
            let get_next_fn: LuaFunction = rpc.get("getNextId")?;
            get_next_fn.call::<_, u64>(())
        });

        methods.add_method("getPendingCount", |lua, this, ()| {
            let rpc = this.get_rpc(lua)?;
            let get_pending_fn: LuaFunction = rpc.get("getPendingCount")?;
            get_pending_fn.call::<_, usize>(())
        });

        methods.add_method("type", |_, _, ()| Ok("LNetworkRpc"));
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LNetworkRpc" || name == "LObject")
        });
    }
}
