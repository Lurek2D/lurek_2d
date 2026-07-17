//! `src/event/event_queue.rs` owns queued runtime events, their portable payload shapes, and Rust-Lua marshalling helpers.
//! It defines `EventPriority`, `EventTableKey`, `EventArg`, `Event`, and `EventQueue` under one event-delivery owner.
//! High and normal priority lanes live here, preserving FIFO order within each lane while dispatch prefers urgent traffic.
//! The queue also exposes blocking wait semantics with wake epochs and a condition variable for producer-consumer flows.
//! Shallow Lua table copying and conversion back to Lua values are implemented here so payload rules stay local.
//! Read this file when queue ordering, timeout behavior, marshalling limits, or payload shape rules need to change.
//! Higher layers should treat it as the queued-event boundary, while signal name matching lives separately in `signal.rs`.

use serde::{Deserialize, Serialize};
use std::collections::VecDeque;
use std::sync::{Condvar, Mutex};
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
/// Selects which internal queue receives a queued event first.
pub enum EventPriority {
    /// Enqueues into the high-priority queue.
    High,
    /// Enqueues into the normal-priority queue.
    Normal,
}
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
/// Key types supported when copying Lua tables into event payloads.
pub enum EventTableKey {
    /// String key copied from Lua.
    Str(String),
    /// Numeric key copied from Lua.
    Num(f64),
    /// Boolean key copied from Lua.
    Bool(bool),
}
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
/// Payload value types supported by queued events.
pub enum EventArg {
    /// String payload copied from Lua.
    Str(String),
    /// Numeric payload copied from Lua.
    Num(f64),
    /// Boolean payload copied from Lua.
    Bool(bool),
    /// Explicit Lua `nil` payload.
    Nil,
    /// Shallow table payload copied as key-value pairs.
    Table(Vec<(EventTableKey, EventArg)>),
}
#[derive(Debug, Clone)]
/// One queued event with a name and positional argument list.
pub struct Event {
    /// Event name delivered to Lua listeners.
    pub name: String,
    /// Positional payload arguments carried by the event.
    pub args: Vec<EventArg>,
}
#[derive(Debug)]
/// Stores pending events in separate high- and normal-priority FIFO queues.
pub struct EventQueue {
    /// High-priority events polled before normal ones.
    high_events: VecDeque<Event>,
    /// Normal-priority events polled after the high-priority queue is empty.
    normal_events: VecDeque<Event>,
    /// Monotonic wake counter used to detect queue activity while waiting.
    wait_epoch: Mutex<u64>,
    /// Condition variable used to wake threads blocked in `wait`.
    wait_condvar: Condvar,
}
impl EventQueue {
    /// Creates an empty event queue with fresh wait state.
    pub fn new() -> Self {
        Self {
            high_events: VecDeque::new(),
            normal_events: VecDeque::new(),
            wait_epoch: Mutex::new(0),
            wait_condvar: Condvar::new(),
        }
    }
    /// Enqueues an event at normal priority.
    pub fn push(&mut self, event: Event) {
        self.push_with_priority(event, EventPriority::Normal);
    }
    /// Enqueues an event into the queue selected by the supplied priority.
    pub fn push_with_priority(&mut self, event: Event, priority: EventPriority) {
        match priority {
            EventPriority::High => self.high_events.push_back(event),
            EventPriority::Normal => self.normal_events.push_back(event),
        }
        self.notify_waiters();
    }
    /// Constructs and enqueues a normal-priority event from raw parts.
    pub fn push_event(&mut self, name: &str, args: Vec<EventArg>) {
        self.push_event_with_priority(name, args, EventPriority::Normal);
    }
    /// Constructs and enqueues an event from raw parts using the supplied priority.
    pub fn push_event_with_priority(
        &mut self,
        name: &str,
        args: Vec<EventArg>,
        priority: EventPriority,
    ) {
        self.push_with_priority(
            Event {
                name: name.to_string(),
                args,
            },
            priority,
        );
    }
    /// Pops the next event, preferring the high-priority queue.
    pub fn poll(&mut self) -> Option<Event> {
        self.high_events
            .pop_front()
            .or_else(|| self.normal_events.pop_front())
    }
    /// Removes every pending event from both priority queues.
    pub fn clear(&mut self) {
        self.high_events.clear();
        self.normal_events.clear();
    }
    /// Returns whether both priority queues are empty.
    pub fn is_empty(&self) -> bool {
        self.high_events.is_empty() && self.normal_events.is_empty()
    }
    /// Returns the total number of pending events across both queues.
    pub fn len(&self) -> usize {
        self.high_events.len() + self.normal_events.len()
    }
    /// Placeholder pump hook kept for API symmetry.
    pub fn pump(&self) {}
    /// Waits for queue activity until timeout and then returns the next event if one is available.
    pub fn wait(&mut self, timeout_ms: Option<u64>) -> Option<Event> {
        if let Some(evt) = self.poll() {
            return Some(evt);
        }
        let mut seen_epoch = {
            let epoch_guard = match self.wait_epoch.lock() {
                Ok(guard) => guard,
                Err(poisoned) => poisoned.into_inner(),
            };
            *epoch_guard
        };
        match timeout_ms {
            Some(ms) => {
                if ms == 0 {
                    return None;
                }
                let deadline = std::time::Instant::now() + std::time::Duration::from_millis(ms);
                while std::time::Instant::now() < deadline {
                    let remaining = deadline.saturating_duration_since(std::time::Instant::now());
                    if self.wait_for_epoch_change(&mut seen_epoch, Some(remaining)) {
                        if let Some(evt) = self.poll() {
                            return Some(evt);
                        }
                    } else {
                        return self.poll();
                    }
                }
                None
            }
            None => loop {
                if self.wait_for_epoch_change(&mut seen_epoch, None) {
                    if let Some(evt) = self.poll() {
                        return Some(evt);
                    }
                }
            },
        }
    }
    /// Blocks until the wake epoch changes or the optional timeout expires.
    fn wait_for_epoch_change(
        &self,
        seen_epoch: &mut u64,
        timeout: Option<std::time::Duration>,
    ) -> bool {
        let guard = match self.wait_epoch.lock() {
            Ok(guard) => guard,
            Err(poisoned) => poisoned.into_inner(),
        };
        if *guard != *seen_epoch {
            *seen_epoch = *guard;
            return true;
        }
        match timeout {
            Some(duration) => {
                let result = self
                    .wait_condvar
                    .wait_timeout_while(guard, duration, |epoch| *epoch == *seen_epoch);
                let (guard, timeout_result) = match result {
                    Ok(pair) => pair,
                    Err(poisoned) => poisoned.into_inner(),
                };
                if *guard != *seen_epoch {
                    *seen_epoch = *guard;
                    true
                } else {
                    !timeout_result.timed_out()
                }
            }
            None => {
                let result = self
                    .wait_condvar
                    .wait_while(guard, |epoch| *epoch == *seen_epoch);
                let guard = match result {
                    Ok(guard) => guard,
                    Err(poisoned) => poisoned.into_inner(),
                };
                *seen_epoch = *guard;
                true
            }
        }
    }
    /// Increments the wake epoch and notifies all waiting threads.
    fn notify_waiters(&self) {
        let mut epoch_guard = match self.wait_epoch.lock() {
            Ok(guard) => guard,
            Err(poisoned) => poisoned.into_inner(),
        };
        *epoch_guard = epoch_guard.wrapping_add(1);
        self.wait_condvar.notify_all();
    }
}
/// Provide a zero-argument constructor as the `Default` trait implementation.
impl Default for EventQueue {
    /// Create an empty event queue.
    fn default() -> Self {
        Self::new()
    }
}
use mlua::prelude::*;
impl EventArg {
    /// Converts a Lua value into the shallow event payload representation.
    pub fn from_lua_val(val: &LuaValue) -> LuaResult<Self> {
        match val {
            LuaValue::String(s) => Ok(EventArg::Str(
                s.to_str()
                    .map_err(|e| LuaError::RuntimeError(e.to_string()))?
                    .to_string(),
            )),
            LuaValue::Integer(n) => Ok(EventArg::Num(*n as f64)),
            LuaValue::Number(n) => Ok(EventArg::Num(*n)),
            LuaValue::Boolean(b) => Ok(EventArg::Bool(*b)),
            LuaValue::Table(tbl) => Self::from_lua_table_shallow(tbl),
            _ => Ok(EventArg::Nil),
        }
    }
    /// Copies a Lua table into a shallow event payload table.
    fn from_lua_table_shallow(table: &LuaTable) -> LuaResult<Self> {
        let mut out = Vec::new();
        for pair in table.clone().pairs::<LuaValue, LuaValue>() {
            let (key, value) = pair?;
            if let Some(converted_key) = Self::table_key_from_lua(&key)? {
                out.push((converted_key, Self::table_value_from_lua_shallow(&value)?));
            }
        }
        Ok(EventArg::Table(out))
    }
    /// Converts one Lua table key into a supported event table key type.
    fn table_key_from_lua(value: &LuaValue) -> LuaResult<Option<EventTableKey>> {
        match value {
            LuaValue::String(s) => Ok(Some(EventTableKey::Str(
                s.to_str()
                    .map_err(|e| LuaError::RuntimeError(e.to_string()))?
                    .to_string(),
            ))),
            LuaValue::Integer(n) => Ok(Some(EventTableKey::Num(*n as f64))),
            LuaValue::Number(n) => Ok(Some(EventTableKey::Num(*n))),
            LuaValue::Boolean(b) => Ok(Some(EventTableKey::Bool(*b))),
            _ => Ok(None),
        }
    }
    /// Converts one Lua table value while collapsing nested tables to `Nil`.
    fn table_value_from_lua_shallow(value: &LuaValue) -> LuaResult<EventArg> {
        match value {
            LuaValue::String(_)
            | LuaValue::Integer(_)
            | LuaValue::Number(_)
            | LuaValue::Boolean(_) => Self::from_lua_val(value),
            LuaValue::Table(_) => Ok(EventArg::Nil),
            _ => Ok(EventArg::Nil),
        }
    }

    /// Converts a Lua value into a bounded, recursively serializable change payload.
    ///
    /// The regular event queue intentionally keeps nested tables shallow. ChangeSets are
    /// durable data, so they use this separate conversion path and reject non-finite numbers
    /// and values deeper than 32 levels instead of silently losing nested state.
    pub fn from_lua_change_value(value: &LuaValue, depth: usize) -> LuaResult<EventArg> {
        if depth > 32 {
            return Err(LuaError::RuntimeError(
                "event ChangeSet payload exceeds maximum depth 32".to_string(),
            ));
        }
        match value {
            LuaValue::Number(number) if !number.is_finite() => Err(LuaError::RuntimeError(
                "event ChangeSet payload cannot contain NaN or infinity".to_string(),
            )),
            LuaValue::Table(table) => {
                let mut entries = Vec::new();
                for pair in table.clone().pairs::<LuaValue, LuaValue>() {
                    let (key, value) = pair?;
                    if let Some(converted_key) = Self::table_key_from_lua(&key)? {
                        entries.push((
                            converted_key,
                            Self::from_lua_change_value(&value, depth + 1)?,
                        ));
                    }
                }
                entries.sort_by(|(left, _), (right, _)| {
                    Self::change_key_sort_key(left).cmp(&Self::change_key_sort_key(right))
                });
                Ok(EventArg::Table(entries))
            }
            _ => Self::from_lua_val(value),
        }
    }

    fn change_key_sort_key(key: &EventTableKey) -> String {
        match key {
            EventTableKey::Str(value) => format!("s:{value}"),
            EventTableKey::Num(value) => format!("n:{value:.17}"),
            EventTableKey::Bool(value) => format!("b:{value}"),
        }
    }
}

/// One durable object/component mutation carried by a [`ChangeSet`].
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct ChangeRecord {
    /// Stable object ID owned by the caller.
    pub object_id: u64,
    /// Caller-defined component or state namespace.
    pub component: String,
    /// Caller-defined operation, for example `"set"` or `"remove"`.
    pub operation: String,
    /// Recursively serializable operation payload.
    pub payload: EventArg,
}

/// Versioned, deterministic collection of neutral state changes.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct ChangeSet {
    schema: String,
    revision: u64,
    max_changes: usize,
    changes: Vec<ChangeRecord>,
}

/// Serializable ChangeSet representation used by Lua snapshot/restore APIs.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct ChangeSetSnapshot {
    /// Schema identifier expected by the consumer.
    pub schema: String,
    /// Monotonic caller-defined revision.
    pub revision: u64,
    /// Ordered state changes.
    pub changes: Vec<ChangeRecord>,
}

impl ChangeSet {
    /// Creates an empty ChangeSet with a bounded change count.
    pub fn new(schema: String, revision: u64, max_changes: usize) -> Result<Self, String> {
        if schema.trim().is_empty() || schema.len() > 128 {
            return Err("event ChangeSet schema must contain 1..=128 characters".to_string());
        }
        if max_changes == 0 || max_changes > 100_000 {
            return Err("event ChangeSet maxChanges must be in the range 1..=100000".to_string());
        }
        Ok(Self {
            schema,
            revision,
            max_changes,
            changes: Vec::new(),
        })
    }

    /// Appends one validated mutation and returns the new change count.
    pub fn append(&mut self, record: ChangeRecord) -> Result<usize, String> {
        if record.object_id == 0 {
            return Err("event ChangeSet objectId must be greater than zero".to_string());
        }
        if record.component.trim().is_empty() || record.component.len() > 128 {
            return Err("event ChangeSet component must contain 1..=128 characters".to_string());
        }
        if record.operation.trim().is_empty() || record.operation.len() > 64 {
            return Err("event ChangeSet operation must contain 1..=64 characters".to_string());
        }
        if self.changes.len() >= self.max_changes {
            return Err(format!(
                "event ChangeSet reached maxChanges ({})",
                self.max_changes
            ));
        }
        self.changes.push(record);
        Ok(self.changes.len())
    }

    /// Returns the schema identifier.
    pub fn schema(&self) -> &str {
        &self.schema
    }

    /// Returns the caller-defined revision.
    pub fn revision(&self) -> u64 {
        self.revision
    }

    /// Returns the number of pending changes.
    pub fn len(&self) -> usize {
        self.changes.len()
    }

    /// Returns the configured maximum number of records.
    pub fn max_changes(&self) -> usize {
        self.max_changes
    }

    /// Returns true when the ChangeSet contains no changes.
    pub fn is_empty(&self) -> bool {
        self.changes.is_empty()
    }

    /// Removes all changes and returns the number removed.
    pub fn clear(&mut self) -> usize {
        let count = self.changes.len();
        self.changes.clear();
        count
    }

    /// Returns an immutable view of ordered changes.
    pub fn changes(&self) -> &[ChangeRecord] {
        &self.changes
    }

    /// Produces a deterministic snapshot without the derived hash field.
    pub fn snapshot(&self) -> ChangeSetSnapshot {
        ChangeSetSnapshot {
            schema: self.schema.clone(),
            revision: self.revision,
            changes: self.changes.clone(),
        }
    }

    /// Validates a snapshot and replaces this ChangeSet's contents.
    pub fn restore(&mut self, snapshot: ChangeSetSnapshot) -> Result<(), String> {
        if snapshot.schema != self.schema {
            return Err(format!(
                "event ChangeSet schema mismatch: expected `{}`, got `{}`",
                self.schema, snapshot.schema
            ));
        }
        if snapshot.changes.len() > self.max_changes {
            return Err("event ChangeSet snapshot exceeds maxChanges".to_string());
        }
        for record in &snapshot.changes {
            if record.object_id == 0
                || record.component.trim().is_empty()
                || record.component.len() > 128
                || record.operation.trim().is_empty()
                || record.operation.len() > 64
            {
                return Err("event ChangeSet snapshot contains an invalid record".to_string());
            }
        }
        self.revision = snapshot.revision;
        self.changes = snapshot.changes;
        Ok(())
    }

    /// Returns a deterministic FNV-1a hash over schema, revision, and ordered changes.
    pub fn hash(&self) -> u64 {
        let bytes = serde_json::to_vec(&self.snapshot()).unwrap_or_default();
        let mut hash = 14_695_981_039_346_656_037u64;
        for byte in bytes {
            hash ^= u64::from(byte);
            hash = hash.wrapping_mul(1_099_511_628_211);
        }
        hash
    }
}
/// Converts an event payload value back into a Lua value.
pub fn event_arg_to_lua_value<'lua>(lua: &'lua Lua, arg: &EventArg) -> LuaResult<LuaValue<'lua>> {
    match arg {
        EventArg::Str(s) => Ok(LuaValue::String(lua.create_string(s)?)),
        EventArg::Num(n) => Ok(LuaValue::Number(*n)),
        EventArg::Bool(b) => Ok(LuaValue::Boolean(*b)),
        EventArg::Nil => Ok(LuaValue::Nil),
        EventArg::Table(entries) => {
            let table = lua.create_table()?;
            for (key, value) in entries {
                let lua_key = match key {
                    EventTableKey::Str(s) => LuaValue::String(lua.create_string(s)?),
                    EventTableKey::Num(n) => LuaValue::Number(*n),
                    EventTableKey::Bool(b) => LuaValue::Boolean(*b),
                };
                let lua_value = event_arg_to_lua_value(lua, value)?;
                table.set(lua_key, lua_value)?;
            }
            Ok(LuaValue::Table(table))
        }
    }
}
/// Converts an event into the Lua multi-value form used by dispatch code.
pub fn event_to_lua_multi<'lua>(lua: &'lua Lua, event: &Event) -> LuaResult<LuaMultiValue<'lua>> {
    let mut values = Vec::with_capacity(1 + event.args.len());
    values.push(LuaValue::String(lua.create_string(&event.name)?));
    for arg in &event.args {
        values.push(event_arg_to_lua_value(lua, arg)?);
    }
    Ok(LuaMultiValue::from_vec(values))
}
