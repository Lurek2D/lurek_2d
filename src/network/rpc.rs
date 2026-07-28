//! Provides a bounded, transport-neutral RPC protocol handle for Lua games.
//! `LNetworkRpc` serializes calls, notifications, and responses but never selects peers or sends packets.
//! Lua routes `takeOutgoing` payloads through an `LNetworkHost` and feeds received payloads to `process`.
//! The handle owns handlers, pending completion callbacks, and timeout policy only.
//! It intentionally does not bridge RPC calls to ECS, physics, or gameplay systems.

use crate::network::message::{pack, unpack, NetValue};
use crate::network::netstate::{netvalue_to_lua, value_to_netvalue};
use mlua::prelude::*;
use std::cell::RefCell;
use std::collections::{BTreeMap, VecDeque};
use std::time::{Duration, Instant};

const MAX_RPC_NAME_BYTES: usize = 128;
const MAX_PENDING_CALLS: usize = 1024;
const MAX_OUTGOING_MESSAGES: usize = 1024;

/// Mutable state behind a transport-neutral RPC userdata.
struct RpcInner {
    handlers: BTreeMap<String, LuaRegistryKey>,
    error_callbacks: Vec<LuaRegistryKey>,
    pending: BTreeMap<u64, PendingCall>,
    outgoing: VecDeque<NetValue>,
    next_id: u64,
    timeout: Duration,
    logging: bool,
}

/// One caller callback waiting for a matching response envelope.
struct PendingCall {
    callback: Option<LuaRegistryKey>,
    created_at: Instant,
}

impl RpcInner {
    /// Creates a protocol state with an intentionally finite queue and pending-call limit.
    fn new(timeout: Duration) -> Self {
        Self {
            handlers: BTreeMap::new(),
            error_callbacks: Vec::new(),
            pending: BTreeMap::new(),
            outgoing: VecDeque::new(),
            next_id: 1,
            timeout,
            logging: false,
        }
    }
}

/// RPC manager that exposes protocol messages for Lua-owned network routing.
pub struct LNetworkRpc {
    inner: RefCell<RpcInner>,
}

/// Looks up a named field in an RPC wire envelope.
fn member<'a>(fields: &'a [(String, NetValue)], name: &str) -> Option<&'a NetValue> {
    fields
        .iter()
        .find_map(|(key, value)| (key == name).then_some(value))
}

/// Validates a public procedure name before it reaches the wire.
fn validate_name(name: &str) -> LuaResult<()> {
    if name.is_empty() || name.len() > MAX_RPC_NAME_BYTES {
        return Err(LuaError::RuntimeError(format!(
            "lurek.network.LNetworkRpc: procedure names must contain 1..={MAX_RPC_NAME_BYTES} bytes"
        )));
    }
    if !name
        .bytes()
        .all(|byte| byte.is_ascii_alphanumeric() || matches!(byte, b'_' | b'.' | b'-'))
    {
        return Err(LuaError::RuntimeError(
            "lurek.network.LNetworkRpc: procedure names may contain only letters, digits, '_', '.', or '-'"
                .to_string(),
        ));
    }
    Ok(())
}

/// Converts a Lua arguments table into a bounded wire-ready array.
fn arguments_to_netvalue(args: Option<LuaTable>) -> LuaResult<NetValue> {
    match args {
        Some(args) => value_to_netvalue(&LuaValue::Table(args), 0),
        None => Ok(NetValue::Array(Vec::new())),
    }
}

/// Converts a wire argument value into the Lua table passed to registered handlers.
fn arguments_to_lua<'lua>(lua: &'lua Lua, args: &NetValue) -> LuaResult<LuaValue<'lua>> {
    match args {
        NetValue::Array(_) | NetValue::Map(_) => netvalue_to_lua(lua, args),
        _ => Err(LuaError::RuntimeError(
            "lurek.network.LNetworkRpc: RPC args must be an array or map".to_string(),
        )),
    }
}

impl LNetworkRpc {
    /// Creates an RPC handle; `host` and `channel` remain compatibility arguments while routing stays explicit in Lua.
    pub fn new(
        _lua: &Lua,
        _host: LuaValue,
        _channel: Option<u8>,
        timeout_seconds: Option<f64>,
    ) -> LuaResult<Self> {
        let timeout_seconds = timeout_seconds.unwrap_or(30.0);
        if !timeout_seconds.is_finite() || timeout_seconds <= 0.0 || timeout_seconds > 3600.0 {
            return Err(LuaError::RuntimeError(
                "lurek.network.newRpc: timeout_seconds must be a finite value in (0, 3600] seconds"
                    .to_string(),
            ));
        }
        Ok(Self {
            inner: RefCell::new(RpcInner::new(Duration::from_secs_f64(timeout_seconds))),
        })
    }

    /// Appends one message to the finite outgoing queue.
    fn queue(&self, message: NetValue) -> LuaResult<()> {
        let mut inner = self.inner.borrow_mut();
        if inner.outgoing.len() >= MAX_OUTGOING_MESSAGES {
            return Err(LuaError::RuntimeError(format!(
                "lurek.network.LNetworkRpc: outgoing queue exceeds {MAX_OUTGOING_MESSAGES} messages"
            )));
        }
        inner.outgoing.push_back(message);
        Ok(())
    }

    /// Invokes registered error callbacks without retaining the mutable protocol borrow.
    fn emit_error(&self, lua: &Lua, message: &str) -> LuaResult<()> {
        let callbacks = std::mem::take(&mut self.inner.borrow_mut().error_callbacks);
        let mut result = Ok(());
        for callback in &callbacks {
            let callback: LuaFunction = lua.registry_value(callback)?;
            if let Err(error) = callback.call::<_, ()>(message) {
                result = Err(error);
                break;
            }
        }
        self.inner.borrow_mut().error_callbacks.extend(callbacks);
        result
    }

    /// Calls one registered handler while leaving its registry entry available after the call returns.
    fn invoke_handler(&self, lua: &Lua, name: &str, args: &NetValue) -> LuaResult<NetValue> {
        let handler = self.inner.borrow_mut().handlers.remove(name);
        let Some(handler) = handler else {
            return Err(LuaError::RuntimeError(format!(
                "lurek.network.LNetworkRpc: no handler is registered for {name}"
            )));
        };
        let result = {
            let handler_fn: LuaFunction = lua.registry_value(&handler)?;
            handler_fn.call::<_, LuaValue>(arguments_to_lua(lua, args)?)
        };
        self.inner
            .borrow_mut()
            .handlers
            .entry(name.to_string())
            .or_insert(handler);
        value_to_netvalue(&result?, 0)
    }

    /// Completes a locally pending call and drops the registry callback after dispatch.
    fn complete_pending(
        &self,
        lua: &Lua,
        id: u64,
        result: Option<&NetValue>,
        error: Option<&str>,
    ) -> LuaResult<()> {
        let pending = self.inner.borrow_mut().pending.remove(&id);
        let Some(pending) = pending else {
            return self.emit_error(
                lua,
                &format!("lurek.network.LNetworkRpc: unknown response id {id}"),
            );
        };
        let Some(callback_key) = pending.callback else {
            return Ok(());
        };
        let callback: LuaFunction = lua.registry_value(&callback_key)?;
        let result = match result {
            Some(value) => netvalue_to_lua(lua, value)?,
            None => LuaValue::Nil,
        };
        callback.call::<_, ()>((result, error.map(str::to_string)))?;
        lua.remove_registry_value(callback_key)?;
        Ok(())
    }
}

impl LuaUserData for LNetworkRpc {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        /// Registers a named local RPC handler receiving one serializable args table.
        methods.add_method(
            "register",
            |lua, this, (name, callback): (String, LuaFunction)| {
                validate_name(&name)?;
                let callback = lua.create_registry_value(callback)?;
                let old = this.inner.borrow_mut().handlers.insert(name, callback);
                if let Some(old) = old {
                    lua.remove_registry_value(old)?;
                }
                Ok(())
            },
        );

        /// Queues a request and returns its id; Lua routes `takeOutgoing` through its chosen host and peer.
        methods.add_method(
            "call",
            |lua, this, (name, args, callback): (String, Option<LuaTable>, Option<LuaFunction>)| {
                validate_name(&name)?;
                let args = arguments_to_netvalue(args)?;
                let callback = callback
                    .map(|callback| lua.create_registry_value(callback))
                    .transpose()?;
                let id = {
                    let mut inner = this.inner.borrow_mut();
                    if inner.pending.len() >= MAX_PENDING_CALLS {
                        return Err(LuaError::RuntimeError(format!(
                            "lurek.network.LNetworkRpc: pending call limit is {MAX_PENDING_CALLS}"
                        )));
                    }
                    let id = inner.next_id;
                    inner.next_id = inner.next_id.checked_add(1).ok_or_else(|| {
                        LuaError::RuntimeError(
                            "lurek.network.LNetworkRpc: request id space is exhausted".to_string(),
                        )
                    })?;
                    inner.pending.insert(
                        id,
                        PendingCall {
                            callback,
                            created_at: Instant::now(),
                        },
                    );
                    id
                };
                this.queue(NetValue::Map(vec![
                    ("type".to_string(), NetValue::String("call".to_string())),
                    ("id".to_string(), NetValue::Integer(id as i64)),
                    ("name".to_string(), NetValue::String(name)),
                    ("args".to_string(), args),
                ]))?;
                Ok(id)
            },
        );

        /// Queues a one-way named notification for Lua-owned transport routing.
        methods.add_method(
            "notify",
            |_lua, this, (name, args): (String, Option<LuaTable>)| {
                validate_name(&name)?;
                this.queue(NetValue::Map(vec![
                    ("type".to_string(), NetValue::String("notify".to_string())),
                    ("name".to_string(), NetValue::String(name)),
                    ("args".to_string(), arguments_to_netvalue(args)?),
                ]))
            },
        );

        /// Queues a one-way notification annotated for the game's chosen broadcast routing policy.
        methods.add_method(
            "broadcast",
            |_lua, this, (name, args): (String, Option<LuaTable>)| {
                validate_name(&name)?;
                this.queue(NetValue::Map(vec![
                    ("type".to_string(), NetValue::String("notify".to_string())),
                    ("broadcast".to_string(), NetValue::Bool(true)),
                    ("name".to_string(), NetValue::String(name)),
                    ("args".to_string(), arguments_to_netvalue(args)?),
                ]))
            },
        );

        /// Takes one packed outgoing protocol message, or nil when the queue is empty.
        methods.add_method("takeOutgoing", |lua, this, ()| {
            let message = this.inner.borrow_mut().outgoing.pop_front();
            match message {
                Some(message) => Ok(LuaValue::String(
                    lua.create_string(&pack(&message).map_err(LuaError::external)?)?,
                )),
                None => Ok(LuaValue::Nil),
            }
        });

        /// Processes one packed protocol message after Lua receives it from a host event.
        methods.add_method("process", |lua, this, payload: LuaString| {
            let decoded = unpack(payload.as_bytes()).map_err(LuaError::external)?;
            let NetValue::Map(fields) = decoded else {
                return Err(LuaError::RuntimeError(
                    "lurek.network.LNetworkRpc: payload must be a map".to_string(),
                ));
            };
            let Some(NetValue::String(kind)) = member(&fields, "type") else {
                return Err(LuaError::RuntimeError(
                    "lurek.network.LNetworkRpc: payload has no type".to_string(),
                ));
            };
            match kind.as_str() {
                "notify" => {
                    let Some(NetValue::String(name)) = member(&fields, "name") else {
                        return Err(LuaError::RuntimeError(
                            "lurek.network.LNetworkRpc: notification has no name".to_string(),
                        ));
                    };
                    let Some(args) = member(&fields, "args") else {
                        return Err(LuaError::RuntimeError(
                            "lurek.network.LNetworkRpc: notification has no args".to_string(),
                        ));
                    };
                    if let Err(error) = this.invoke_handler(lua, name, args) {
                        this.emit_error(lua, &error.to_string())?;
                    }
                    Ok(())
                }
                "call" => {
                    let id = member(&fields, "id")
                        .and_then(|value| match value {
                            NetValue::Integer(id) => u64::try_from(*id).ok(),
                            _ => None,
                        })
                        .ok_or_else(|| {
                            LuaError::RuntimeError(
                                "lurek.network.LNetworkRpc: call has no valid id".to_string(),
                            )
                        })?;
                    let Some(NetValue::String(name)) = member(&fields, "name") else {
                        return Err(LuaError::RuntimeError(
                            "lurek.network.LNetworkRpc: call has no name".to_string(),
                        ));
                    };
                    let Some(args) = member(&fields, "args") else {
                        return Err(LuaError::RuntimeError(
                            "lurek.network.LNetworkRpc: call has no args".to_string(),
                        ));
                    };
                    let reply = match this.invoke_handler(lua, name, args) {
                        Ok(result) => NetValue::Map(vec![
                            ("type".to_string(), NetValue::String("response".to_string())),
                            ("id".to_string(), NetValue::Integer(id as i64)),
                            ("result".to_string(), result),
                        ]),
                        Err(error) => NetValue::Map(vec![
                            ("type".to_string(), NetValue::String("response".to_string())),
                            ("id".to_string(), NetValue::Integer(id as i64)),
                            ("error".to_string(), NetValue::String(error.to_string())),
                        ]),
                    };
                    this.queue(reply)
                }
                "response" => {
                    let id = member(&fields, "id")
                        .and_then(|value| match value {
                            NetValue::Integer(id) => u64::try_from(*id).ok(),
                            _ => None,
                        })
                        .ok_or_else(|| {
                            LuaError::RuntimeError(
                                "lurek.network.LNetworkRpc: response has no valid id".to_string(),
                            )
                        })?;
                    let error = member(&fields, "error").and_then(|value| match value {
                        NetValue::String(message) => Some(message.as_str()),
                        _ => None,
                    });
                    this.complete_pending(lua, id, member(&fields, "result"), error)
                }
                _ => Err(LuaError::RuntimeError(format!(
                    "lurek.network.LNetworkRpc: unsupported payload type {kind}"
                ))),
            }
        });

        /// Expires stale pending calls and invokes their callbacks with a timeout error.
        methods.add_method("poll", |lua, this, ()| {
            let expired = {
                let mut inner = this.inner.borrow_mut();
                let now = Instant::now();
                let ids = inner
                    .pending
                    .iter()
                    .filter_map(|(id, pending)| {
                        (now.duration_since(pending.created_at) >= inner.timeout).then_some(*id)
                    })
                    .collect::<Vec<_>>();
                ids.into_iter()
                    .filter_map(|id| inner.pending.remove(&id))
                    .collect::<Vec<_>>()
            };
            for pending in expired {
                if let Some(callback_key) = pending.callback {
                    let callback: LuaFunction = lua.registry_value(&callback_key)?;
                    callback.call::<_, ()>((LuaValue::Nil, "timeout"))?;
                    lua.remove_registry_value(callback_key)?;
                }
            }
            Ok(())
        });

        /// Registers a callback invoked for protocol errors that cannot be delivered to a pending call.
        methods.add_method("onError", |lua, this, callback: LuaFunction| {
            this.inner
                .borrow_mut()
                .error_callbacks
                .push(lua.create_registry_value(callback)?);
            Ok(())
        });

        /// Sets whether the application marks this protocol handle as verbose and returns the resulting flag.
        methods.add_method("setLogging", |_lua, this, enabled: bool| {
            let mut inner = this.inner.borrow_mut();
            inner.logging = enabled;
            Ok(inner.logging)
        });

        /// Sets the pending-call timeout in seconds.
        methods.add_method("setTimeout", |_lua, this, seconds: f64| {
            if !seconds.is_finite() || seconds <= 0.0 || seconds > 3600.0 {
                return Err(LuaError::RuntimeError(
                    "lurek.network.LNetworkRpc:setTimeout: seconds must be in (0, 3600]"
                        .to_string(),
                ));
            }
            this.inner.borrow_mut().timeout = Duration::from_secs_f64(seconds);
            Ok(())
        });

        /// Resets the request-id allocator when no calls are pending.
        methods.add_method("resetIdCounter", |_lua, this, ()| {
            let mut inner = this.inner.borrow_mut();
            if !inner.pending.is_empty() {
                return Err(LuaError::RuntimeError(
                    "lurek.network.LNetworkRpc:resetIdCounter requires no pending calls"
                        .to_string(),
                ));
            }
            inner.next_id = 1;
            Ok(())
        });

        /// Returns the id that will be allocated by the next call.
        methods.add_method("getNextId", |_lua, this, ()| {
            Ok(this.inner.borrow().next_id)
        });

        /// Returns the number of requests awaiting a response.
        methods.add_method("getPendingCount", |_lua, this, ()| {
            Ok(this.inner.borrow().pending.len())
        });

        /// Returns the userdata type name.
        methods.add_method("type", |_lua, _this, ()| Ok("LNetworkRpc"));
        /// Checks this userdata against the public RPC type names.
        methods.add_method("typeOf", |_lua, _this, name: String| {
            Ok(name == "LNetworkRpc" || name == "LObject")
        });
    }
}
