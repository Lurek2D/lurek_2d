//! Provides a bounded, transport-neutral replicated key/value state handle for Lua games.
//! `LNetworkState` owns only serializable state, change notifications, and deterministic payloads.
//! Lua decides when and how to send `takeDirty` or `takeRequest` payloads through a network host.
//! This module deliberately does not bind ECS, physics, or game-specific state to networking.
//! Callbacks are dispatched after mutable state borrows have been released.

use crate::network::message::{pack, unpack, NetValue};
use mlua::prelude::*;
use std::cell::RefCell;
use std::collections::{BTreeMap, BTreeSet};

const DEFAULT_MAX_DIRTY_KEYS: usize = 1024;
const MAX_STATE_KEYS: usize = 4096;

/// Shared state behind a Lua network-state userdata.
struct NetworkStateInner {
    values: BTreeMap<String, LuaRegistryKey>,
    callbacks: BTreeMap<String, Vec<LuaRegistryKey>>,
    turn_callbacks: Vec<LuaRegistryKey>,
    dirty_keys: BTreeSet<String>,
    pending_changes: BTreeSet<String>,
    pending_turn: bool,
    full_requested: bool,
    authority: bool,
    turn_based: bool,
    current_turn: u32,
    max_dirty_keys: usize,
}

impl NetworkStateInner {
    /// Creates bounded empty state with explicit authority and turn-mode policy.
    fn new(authority: bool, turn_based: bool, max_dirty_keys: usize) -> Self {
        Self {
            values: BTreeMap::new(),
            callbacks: BTreeMap::new(),
            turn_callbacks: Vec::new(),
            dirty_keys: BTreeSet::new(),
            pending_changes: BTreeSet::new(),
            pending_turn: false,
            full_requested: false,
            authority,
            turn_based,
            current_turn: 0,
            max_dirty_keys,
        }
    }
}

/// Wraps transport-neutral, serializable state used by Lua-owned replication protocols.
pub struct LNetworkState {
    inner: RefCell<NetworkStateInner>,
}

/// Converts a Lua table into a serializable network value.
fn table_to_netvalue(table: &LuaTable, depth: usize) -> LuaResult<NetValue> {
    if depth > 32 {
        return Err(LuaError::RuntimeError(
            "lurek.network.newNetState: state nesting exceeds 32 levels".to_string(),
        ));
    }
    if !matches!(table.raw_get::<_, LuaValue>(1i64)?, LuaValue::Nil) {
        let mut values = Vec::new();
        for value in table.clone().sequence_values::<LuaValue>() {
            values.push(value_to_netvalue(&value?, depth + 1)?);
        }
        return Ok(NetValue::Array(values));
    }

    let mut values = Vec::new();
    for pair in table.clone().pairs::<LuaValue, LuaValue>() {
        let (key, value) = pair?;
        let key = match key {
            LuaValue::String(value) => value.to_str()?.to_string(),
            LuaValue::Integer(value) => value.to_string(),
            LuaValue::Number(value) if value.is_finite() => value.to_string(),
            _ => {
                return Err(LuaError::RuntimeError(
                    "lurek.network.newNetState: map keys must be finite strings or numbers"
                        .to_string(),
                ))
            }
        };
        values.push((key, value_to_netvalue(&value, depth + 1)?));
    }
    values.sort_by(|left, right| left.0.cmp(&right.0));
    Ok(NetValue::Map(values))
}

/// Converts one Lua value into the supported deterministic state representation.
pub(crate) fn value_to_netvalue(value: &LuaValue, depth: usize) -> LuaResult<NetValue> {
    match value {
        LuaValue::Nil => Ok(NetValue::Nil),
        LuaValue::Boolean(value) => Ok(NetValue::Bool(*value)),
        LuaValue::Integer(value) => Ok(NetValue::Integer(*value)),
        LuaValue::Number(value) if value.is_finite() => Ok(NetValue::Float(*value)),
        LuaValue::Number(_) => Err(LuaError::RuntimeError(
            "lurek.network.newNetState: numbers must be finite".to_string(),
        )),
        LuaValue::String(value) => Ok(NetValue::String(value.to_str()?.to_string())),
        LuaValue::Table(value) => table_to_netvalue(value, depth),
        _ => Err(LuaError::RuntimeError(format!(
            "lurek.network.newNetState: unsupported state value type {}",
            value.type_name()
        ))),
    }
}

/// Converts a deterministic state value back into Lua data.
pub(crate) fn netvalue_to_lua<'lua>(lua: &'lua Lua, value: &NetValue) -> LuaResult<LuaValue<'lua>> {
    match value {
        NetValue::Nil => Ok(LuaValue::Nil),
        NetValue::Bool(value) => Ok(LuaValue::Boolean(*value)),
        NetValue::Integer(value) => Ok(LuaValue::Integer(*value)),
        NetValue::Float(value) if value.is_finite() => Ok(LuaValue::Number(*value)),
        NetValue::Float(_) => Err(LuaError::RuntimeError(
            "lurek.network.LNetworkState: received a non-finite number".to_string(),
        )),
        NetValue::String(value) => Ok(LuaValue::String(lua.create_string(value)?)),
        NetValue::Array(values) => {
            let table = lua.create_table()?;
            for (index, value) in values.iter().enumerate() {
                table.raw_set(index + 1, netvalue_to_lua(lua, value)?)?;
            }
            Ok(LuaValue::Table(table))
        }
        NetValue::Map(values) => {
            let table = lua.create_table()?;
            for (key, value) in values {
                table.raw_set(key.as_str(), netvalue_to_lua(lua, value)?)?;
            }
            Ok(LuaValue::Table(table))
        }
    }
}

/// Extracts a named map member from a decoded state payload.
fn map_member<'a>(values: &'a [(String, NetValue)], name: &str) -> Option<&'a NetValue> {
    values
        .iter()
        .find_map(|(key, value)| (key == name).then_some(value))
}

/// Hashes a byte slice with stable FNV-1a 64-bit semantics.
fn fnv1a64(bytes: &[u8]) -> u64 {
    let mut hash = 0xcbf29ce484222325_u64;
    for byte in bytes {
        hash ^= u64::from(*byte);
        hash = hash.wrapping_mul(0x100000001b3);
    }
    hash
}

impl LNetworkState {
    /// Creates a state handle; `host` remains an accepted compatibility argument but transport is explicit in Lua.
    pub fn new(_lua: &Lua, _host: LuaValue, opts: Option<LuaTable>) -> LuaResult<Self> {
        let authority = opts
            .as_ref()
            .map(|opts| opts.get::<_, Option<bool>>("authority"))
            .transpose()?
            .flatten()
            .unwrap_or(true);
        let turn_based = opts
            .as_ref()
            .map(|opts| opts.get::<_, Option<bool>>("turnBased"))
            .transpose()?
            .flatten()
            .unwrap_or(false);
        let max_dirty_keys = opts
            .as_ref()
            .map(|opts| opts.get::<_, Option<usize>>("maxDirtyKeys"))
            .transpose()?
            .flatten()
            .unwrap_or(DEFAULT_MAX_DIRTY_KEYS);
        if max_dirty_keys == 0 || max_dirty_keys > MAX_STATE_KEYS {
            return Err(LuaError::RuntimeError(format!(
                "lurek.network.newNetState: maxDirtyKeys must be in 1..={MAX_STATE_KEYS}"
            )));
        }
        Ok(Self {
            inner: RefCell::new(NetworkStateInner::new(
                authority,
                turn_based,
                max_dirty_keys,
            )),
        })
    }

    /// Applies decoded values as an incoming replication update and queues local notifications.
    fn apply_values(&self, lua: &Lua, values: &[(String, NetValue)]) -> LuaResult<()> {
        if values.len() > MAX_STATE_KEYS {
            return Err(LuaError::RuntimeError(format!(
                "lurek.network.LNetworkState: payload exceeds {MAX_STATE_KEYS} keys"
            )));
        }
        let mut replacements = Vec::with_capacity(values.len());
        for (key, value) in values {
            if key.is_empty() || key.len() > 256 {
                return Err(LuaError::RuntimeError(
                    "lurek.network.LNetworkState: state keys must contain 1..=256 bytes"
                        .to_string(),
                ));
            }
            replacements.push((
                key.clone(),
                lua.create_registry_value(netvalue_to_lua(lua, value)?)?,
            ));
        }
        let old_values = {
            let mut inner = self.inner.borrow_mut();
            let mut old_values = Vec::new();
            for (key, value) in replacements {
                if let Some(old) = inner.values.insert(key.clone(), value) {
                    old_values.push(old);
                }
                inner.pending_changes.insert(key);
            }
            old_values
        };
        for value in old_values {
            lua.remove_registry_value(value)?;
        }
        Ok(())
    }
}

impl LuaUserData for LNetworkState {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        /// Sets one authority-owned serializable state value and marks it for explicit transmission.
        methods.add_method("set", |lua, this, (key, value): (String, LuaValue)| {
            if key.is_empty() || key.len() > 256 {
                return Err(LuaError::RuntimeError(
                    "lurek.network.LNetworkState:set: key must contain 1..=256 bytes".to_string(),
                ));
            }
            let serialized = value_to_netvalue(&value, 0)?;
            let replacement = lua.create_registry_value(netvalue_to_lua(lua, &serialized)?)?;
            let old = {
                let mut inner = this.inner.borrow_mut();
                if !inner.authority {
                    return Err(LuaError::RuntimeError(
                        "lurek.network.LNetworkState:set: only an authority state may set values"
                            .to_string(),
                    ));
                }
                if !inner.values.contains_key(&key) && inner.values.len() >= MAX_STATE_KEYS {
                    return Err(LuaError::RuntimeError(format!(
                        "lurek.network.LNetworkState:set: state exceeds {MAX_STATE_KEYS} keys"
                    )));
                }
                if !inner.dirty_keys.contains(&key)
                    && inner.dirty_keys.len() >= inner.max_dirty_keys
                {
                    return Err(LuaError::RuntimeError(format!(
                        "lurek.network.LNetworkState:set: dirty state exceeds {} keys",
                        inner.max_dirty_keys
                    )));
                }
                let old = inner.values.insert(key.clone(), replacement);
                inner.dirty_keys.insert(key.clone());
                inner.pending_changes.insert(key);
                old
            };
            if let Some(old) = old {
                lua.remove_registry_value(old)?;
            }
            Ok(())
        });

        /// Gets the current value for one state key, or nil when no value is present.
        methods.add_method("get", |lua, this, key: String| {
            let inner = this.inner.borrow();
            match inner.values.get(&key) {
                Some(value) => lua.registry_value(value),
                None => Ok(LuaValue::Nil),
            }
        });

        /// Returns a shallow table containing all current serializable state values.
        methods.add_method("getAll", |lua, this, ()| {
            let table = lua.create_table()?;
            let inner = this.inner.borrow();
            for (key, value) in &inner.values {
                table.raw_set(key.as_str(), lua.registry_value::<LuaValue>(value)?)?;
            }
            Ok(table)
        });

        /// Marks that this peer needs a full authoritative state payload.
        methods.add_method("requestFullState", |_lua, this, ()| {
            this.inner.borrow_mut().full_requested = true;
            Ok(())
        });

        /// Takes a compact request payload for Lua to route through its chosen network protocol.
        methods.add_method("takeRequest", |lua, this, ()| {
            let requested = {
                let mut inner = this.inner.borrow_mut();
                std::mem::take(&mut inner.full_requested)
            };
            if !requested {
                return Ok(LuaValue::Nil);
            }
            let payload = NetValue::Map(vec![(
                "type".to_string(),
                NetValue::String("netstate_request".to_string()),
            )]);
            let bytes = pack(&payload).map_err(LuaError::external)?;
            Ok(LuaValue::String(lua.create_string(&bytes)?))
        });

        /// Takes a deterministic dirty-state payload for explicit transport from Lua.
        methods.add_method("takeDirty", |lua, this, ()| {
            let payload = {
                let mut inner = this.inner.borrow_mut();
                let dirty = std::mem::take(&mut inner.dirty_keys);
                if dirty.is_empty() {
                    None
                } else {
                    let mut values = Vec::with_capacity(dirty.len());
                    for key in dirty {
                        let value = inner.values.get(&key).ok_or_else(|| {
                            LuaError::RuntimeError(
                                "lurek.network.LNetworkState: dirty key has no value".to_string(),
                            )
                        })?;
                        values.push((key, value_to_netvalue(&lua.registry_value(value)?, 0)?));
                    }
                    Some(NetValue::Map(vec![
                        ("type".to_string(), NetValue::String("netstate".to_string())),
                        (
                            "turn".to_string(),
                            NetValue::Integer(i64::from(inner.current_turn)),
                        ),
                        ("values".to_string(), NetValue::Map(values)),
                    ]))
                }
            };
            match payload {
                Some(payload) => Ok(LuaValue::String(
                    lua.create_string(&pack(&payload).map_err(LuaError::external)?)?,
                )),
                None => Ok(LuaValue::Nil),
            }
        });

        /// Applies a payload produced by `takeDirty`; callers choose transport and event routing in Lua.
        methods.add_method("apply", |lua, this, payload: LuaString| {
            let decoded = unpack(payload.as_bytes()).map_err(LuaError::external)?;
            let NetValue::Map(fields) = decoded else {
                return Err(LuaError::RuntimeError(
                    "lurek.network.LNetworkState: payload must be a map".to_string(),
                ));
            };
            let Some(NetValue::String(kind)) = map_member(&fields, "type") else {
                return Err(LuaError::RuntimeError(
                    "lurek.network.LNetworkState: payload has no type".to_string(),
                ));
            };
            if kind != "netstate" {
                return Err(LuaError::RuntimeError(format!(
                    "lurek.network.LNetworkState: unsupported payload type {kind}"
                )));
            }
            let Some(NetValue::Map(values)) = map_member(&fields, "values") else {
                return Err(LuaError::RuntimeError(
                    "lurek.network.LNetworkState: payload has no values map".to_string(),
                ));
            };
            if let Some(NetValue::Integer(turn)) = map_member(&fields, "turn") {
                let turn = u32::try_from(*turn).map_err(|_| {
                    LuaError::RuntimeError(
                        "lurek.network.LNetworkState: turn must be an unsigned 32-bit value"
                            .to_string(),
                    )
                })?;
                let mut inner = this.inner.borrow_mut();
                if turn > inner.current_turn {
                    inner.current_turn = turn;
                    inner.pending_turn = true;
                }
            }
            this.apply_values(lua, values)
        });

        /// Advances the authority-owned turn counter and queues the turn notification.
        methods.add_method("beginTurn", |_lua, this, ()| {
            let mut inner = this.inner.borrow_mut();
            if !inner.authority || !inner.turn_based {
                return Err(LuaError::RuntimeError(
                    "lurek.network.LNetworkState:beginTurn requires turnBased authority state"
                        .to_string(),
                ));
            }
            inner.current_turn = inner.current_turn.saturating_add(1);
            inner.pending_turn = true;
            Ok(())
        });

        /// Gets the current replicated turn number.
        methods.add_method("getCurrentTurn", |_lua, this, ()| {
            Ok(this.inner.borrow().current_turn)
        });

        /// Returns a stable FNV-1a hash of all keys and current serializable values.
        methods.add_method("hashState", |lua, this, ()| {
            let encoded = {
                let inner = this.inner.borrow();
                let mut values = Vec::with_capacity(inner.values.len());
                for (key, value) in &inner.values {
                    values.push((
                        key.clone(),
                        value_to_netvalue(&lua.registry_value(value)?, 0)?,
                    ));
                }
                pack(&NetValue::Map(values)).map_err(LuaError::external)?
            };
            Ok(format!("{:016x}", fnv1a64(&encoded)))
        });

        /// Registers a callback that `poll` invokes after the named key changes.
        methods.add_method(
            "onChange",
            |lua, this, (key, callback): (String, LuaFunction)| {
                let callback = lua.create_registry_value(callback)?;
                this.inner
                    .borrow_mut()
                    .callbacks
                    .entry(key)
                    .or_default()
                    .push(callback);
                Ok(())
            },
        );

        /// Registers a callback that `poll` invokes after the turn counter changes.
        methods.add_method("onTurn", |lua, this, callback: LuaFunction| {
            let callback = lua.create_registry_value(callback)?;
            this.inner.borrow_mut().turn_callbacks.push(callback);
            Ok(())
        });

        /// Dispatches queued change notifications without holding state borrows across Lua callbacks.
        methods.add_method("poll", |lua, this, ()| {
            let changes = {
                let mut inner = this.inner.borrow_mut();
                std::mem::take(&mut inner.pending_changes)
                    .into_iter()
                    .collect::<Vec<_>>()
            };
            for key in changes {
                let callbacks = this
                    .inner
                    .borrow_mut()
                    .callbacks
                    .remove(&key)
                    .unwrap_or_default();
                let value = {
                    let inner = this.inner.borrow();
                    match inner.values.get(&key) {
                        Some(value) => lua.registry_value::<LuaValue>(value)?,
                        None => LuaValue::Nil,
                    }
                };
                for callback in &callbacks {
                    let callback: LuaFunction = lua.registry_value(callback)?;
                    callback.call::<_, ()>((key.as_str(), value.clone()))?;
                }
                this.inner
                    .borrow_mut()
                    .callbacks
                    .entry(key)
                    .or_default()
                    .extend(callbacks);
            }

            let (notify_turn, turn_callbacks, turn) = {
                let mut inner = this.inner.borrow_mut();
                let notify_turn = std::mem::take(&mut inner.pending_turn);
                let callbacks = if notify_turn {
                    std::mem::take(&mut inner.turn_callbacks)
                } else {
                    Vec::new()
                };
                (notify_turn, callbacks, inner.current_turn)
            };
            if notify_turn {
                for callback in &turn_callbacks {
                    let callback: LuaFunction = lua.registry_value(callback)?;
                    callback.call::<_, ()>(turn)?;
                }
                this.inner
                    .borrow_mut()
                    .turn_callbacks
                    .extend(turn_callbacks);
            }
            Ok(())
        });

        /// Returns the userdata type name.
        methods.add_method("type", |_lua, _this, ()| Ok("LNetworkState"));
        /// Checks this userdata against the public network-state type names.
        methods.add_method("typeOf", |_lua, _this, name: String| {
            Ok(name == "LNetworkState" || name == "LObject")
        });
    }
}
