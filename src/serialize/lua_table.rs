//! This file owns `SerialValue` plus Lua conversion helpers that bridge dynamic Lua values into serializable Rust data.
//! It decides whether Lua tables become sequences or maps, while preserving scalars, nulls, and string-keyed content.
//! `to_lua` rebuilds Lua primitives and tables from decoded values so serialized data can round-trip through scripts.
//! Array detection is structural and automatic, which keeps callers from tagging plain Lua tables before encoding.
//! Open this file when shared value semantics change; concrete text and binary codecs live in sibling modules.

use super::codec::{SerializeError, SerializeLimitKind, SerializeLimits};
use indexmap::IndexMap;
use mlua::prelude::{Lua, LuaResult, LuaValue};
use std::collections::HashSet;
use std::ffi::c_void;
use std::fmt;

/// Type-erased value tree used for Lua-to-Rust serialization.
///
/// # Variants
/// - `Null`: Nil / absent value.
/// - `Bool`: Boolean value.
/// - `Int`: Integer numeric value.
/// - `Float`: Floating-point numeric value.
/// - `Str`: UTF-8 string value.
/// - `Seq`: Dense array-style table.
/// - `Map`: String-keyed or mixed Lua table.
#[derive(Debug, Clone, PartialEq)]
pub enum SerialValue {
    /// Nil / absent value.
    Null,
    /// Boolean value.
    Bool(bool),
    /// Integer value (whole numbers stored losslessly).
    Int(i64),
    /// Floating-point value.
    Float(f64),
    /// UTF-8 string value.
    Str(String),
    /// Ordered sequence (array-like Lua table).
    Seq(Vec<SerialValue>),
    /// String-keyed map (non-sequential Lua table).
    Map(IndexMap<String, SerialValue>),
}

/// Display scalar values inline; complex values show `[complex]`.
impl fmt::Display for SerialValue {
    /// Format this value for user-facing display.
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            SerialValue::Null => write!(f, ""),
            SerialValue::Bool(b) => write!(f, "{b}"),
            SerialValue::Int(n) => write!(f, "{n}"),
            SerialValue::Float(v) => write!(f, "{v}"),
            SerialValue::Str(s) => write!(f, "{s}"),
            SerialValue::Seq(_) | SerialValue::Map(_) => write!(f, "[complex]"),
        }
    }
}

/// Convert a `SerialValue` tree into a Lua value (tables for Seq/Map).
pub fn to_lua<'lua>(lua: &'lua Lua, val: &SerialValue) -> LuaResult<LuaValue<'lua>> {
    match val {
        SerialValue::Null => Ok(LuaValue::Nil),
        SerialValue::Bool(b) => Ok(LuaValue::Boolean(*b)),
        SerialValue::Int(n) => Ok(LuaValue::Integer(*n)),
        SerialValue::Float(f) => Ok(LuaValue::Number(*f)),
        SerialValue::Str(s) => Ok(LuaValue::String(lua.create_string(s)?)),
        SerialValue::Seq(arr) => {
            let t = lua.create_table()?;
            for (i, v) in arr.iter().enumerate() {
                t.set(i as i64 + 1, to_lua(lua, v)?)?;
            }
            Ok(LuaValue::Table(t))
        }
        SerialValue::Map(map) => {
            let t = lua.create_table()?;
            for (k, v) in map {
                t.set(k.as_str(), to_lua(lua, v)?)?;
            }
            Ok(LuaValue::Table(t))
        }
    }
}

#[derive(Default)]
struct TraversalState {
    nodes: usize,
    visited_tables: HashSet<*const c_void>,
}

fn bump_node(
    state: &mut TraversalState,
    limits: &SerializeLimits,
    context: &str,
) -> Result<(), SerializeError> {
    state.nodes += 1;
    if state.nodes > limits.max_nodes {
        return Err(SerializeError::limit(
            context,
            SerializeLimitKind::Nodes,
            state.nodes,
            limits.max_nodes,
        ));
    }
    Ok(())
}

fn lua_value_type_name(value: &LuaValue) -> &'static str {
    match value {
        LuaValue::Nil => "nil",
        LuaValue::Boolean(_) => "boolean",
        LuaValue::LightUserData(_) => "lightuserdata",
        LuaValue::Integer(_) => "integer",
        LuaValue::Number(_) => "number",
        LuaValue::String(_) => "string",
        LuaValue::Table(_) => "table",
        LuaValue::Function(_) => "function",
        LuaValue::Thread(_) => "thread",
        LuaValue::UserData(_) => "userdata",
        LuaValue::Error(_) => "error",
    }
}

fn string_context(path: &str) -> String {
    format!("from_lua {path}")
}

fn value_context(context: &str, path: &str) -> String {
    if path.is_empty() {
        context.to_string()
    } else {
        format!("{context} {path}")
    }
}

fn sequence_slot_path(path: &str, index: usize) -> String {
    format!("{path}[{}]", index + 1)
}

fn map_field_path(path: &str, key: &str) -> String {
    format!("{path}.{key}")
}

fn from_lua_inner(
    val: &LuaValue,
    limits: &SerializeLimits,
    state: &mut TraversalState,
    depth: usize,
    path: &str,
) -> Result<SerialValue, SerializeError> {
    if depth > limits.max_depth {
        return Err(SerializeError::limit(
            value_context("from_lua", path),
            SerializeLimitKind::Depth,
            depth,
            limits.max_depth,
        ));
    }
    bump_node(state, limits, &value_context("from_lua", path))?;

    match val {
        LuaValue::Nil => Ok(SerialValue::Null),
        LuaValue::Boolean(b) => Ok(SerialValue::Bool(*b)),
        LuaValue::Integer(n) => Ok(SerialValue::Int(*n)),
        LuaValue::Number(f) => {
            if !f.is_finite() {
                return Err(SerializeError::NonFiniteNumber {
                    context: value_context("from_lua", path),
                });
            }
            if f.fract() == 0.0 && *f >= i64::MIN as f64 && *f <= i64::MAX as f64 {
                Ok(SerialValue::Int(*f as i64))
            } else {
                Ok(SerialValue::Float(*f))
            }
        }
        LuaValue::String(s) => {
            let text = s.to_str().map_err(|e| {
                SerializeError::codec(string_context(path), format!("invalid UTF-8: {e}"))
            })?;
            let char_len = text.chars().count();
            if char_len > limits.max_string_chars {
                return Err(SerializeError::limit(
                    string_context(path),
                    SerializeLimitKind::StringChars,
                    char_len,
                    limits.max_string_chars,
                ));
            }
            Ok(SerialValue::Str(text.to_string()))
        }
        LuaValue::Table(t) => {
            let table_ptr = t.to_pointer();
            if !state.visited_tables.insert(table_ptr) {
                return Err(SerializeError::CyclicLuaTable {
                    context: value_context("from_lua", path),
                });
            }

            let raw_len = t.raw_len();
            if raw_len > limits.max_sequence_len {
                state.visited_tables.remove(&table_ptr);
                return Err(SerializeError::limit(
                    value_context("from_lua", path),
                    SerializeLimitKind::SequenceLength,
                    raw_len,
                    limits.max_sequence_len,
                ));
            }

            let result = (|| {
                let mut map = IndexMap::new();
                let mut total_entries = 0usize;
                let mut is_sequence = raw_len > 0;
                let mut sequence_values: Vec<Option<SerialValue>> = vec![None; raw_len];

                for pair in t.clone().pairs::<LuaValue, LuaValue>() {
                    let (key, value) = pair.map_err(|e| {
                        SerializeError::codec(value_context("from_lua", path), e.to_string())
                    })?;
                    total_entries += 1;
                    if total_entries > limits.max_table_entries {
                        return Err(SerializeError::limit(
                            value_context("from_lua", path),
                            SerializeLimitKind::TableEntries,
                            total_entries,
                            limits.max_table_entries,
                        ));
                    }

                    match &key {
                        LuaValue::Integer(index) if *index >= 1 && (*index as usize) <= raw_len => {
                            let child = from_lua_inner(
                                &value,
                                limits,
                                state,
                                depth + 1,
                                &sequence_slot_path(path, *index as usize - 1),
                            )?;
                            sequence_values[*index as usize - 1] = Some(child.clone());
                            map.insert(index.to_string(), child);
                        }
                        LuaValue::String(s) => {
                            let key_text = s.to_str().map_err(|e| {
                                SerializeError::codec(
                                    value_context("from_lua", path),
                                    format!("invalid UTF-8 key: {e}"),
                                )
                            })?;
                            let child = from_lua_inner(
                                &value,
                                limits,
                                state,
                                depth + 1,
                                &map_field_path(path, key_text),
                            )?;
                            is_sequence = false;
                            map.insert(key_text.to_string(), child);
                        }
                        LuaValue::Number(number_key) => {
                            if !number_key.is_finite() {
                                return Err(SerializeError::NonFiniteNumber {
                                    context: value_context("from_lua", path),
                                });
                            }
                            let child = from_lua_inner(
                                &value,
                                limits,
                                state,
                                depth + 1,
                                &map_field_path(path, &number_key.to_string()),
                            )?;
                            is_sequence = false;
                            map.insert(number_key.to_string(), child);
                        }
                        _ => {
                            return Err(SerializeError::UnsupportedLuaType {
                                context: value_context("from_lua", path),
                                type_name: lua_value_type_name(&key),
                            })
                        }
                    }
                }

                if is_sequence
                    && total_entries == raw_len
                    && sequence_values.iter().all(Option::is_some)
                {
                    let sequence = sequence_values
                        .into_iter()
                        .collect::<Option<Vec<_>>>()
                        .ok_or_else(|| {
                            SerializeError::codec(
                                value_context("from_lua", path),
                                "sequence validation drifted during conversion",
                            )
                        })?;
                    return Ok(SerialValue::Seq(sequence));
                }
                Ok(SerialValue::Map(map))
            })();

            state.visited_tables.remove(&table_ptr);
            result
        }
        _ => Err(SerializeError::UnsupportedLuaType {
            context: value_context("from_lua", path),
            type_name: lua_value_type_name(val),
        }),
    }
}

/// Convert a Lua value into a `SerialValue` tree, detecting arrays automatically.
pub fn from_lua(val: &LuaValue) -> LuaResult<SerialValue> {
    from_lua_with_limits(val, &SerializeLimits::default())
        .map_err(|err| mlua::Error::RuntimeError(err.to_string()))
}

/// Convert a Lua value into a `SerialValue` tree using explicit limits.
pub fn from_lua_with_limits(
    val: &LuaValue,
    limits: &SerializeLimits,
) -> Result<SerialValue, SerializeError> {
    let mut state = TraversalState::default();
    from_lua_inner(val, limits, &mut state, 0, "$")
}

fn validate_serial_inner(
    value: &SerialValue,
    limits: &SerializeLimits,
    state: &mut TraversalState,
    depth: usize,
    path: &str,
    context: &str,
) -> Result<(), SerializeError> {
    if depth > limits.max_depth {
        return Err(SerializeError::limit(
            value_context(context, path),
            SerializeLimitKind::Depth,
            depth,
            limits.max_depth,
        ));
    }
    bump_node(state, limits, &value_context(context, path))?;

    match value {
        SerialValue::Null | SerialValue::Bool(_) | SerialValue::Int(_) => Ok(()),
        SerialValue::Float(f) => {
            if !f.is_finite() {
                return Err(SerializeError::NonFiniteNumber {
                    context: value_context(context, path),
                });
            }
            Ok(())
        }
        SerialValue::Str(text) => {
            let char_len = text.chars().count();
            if char_len > limits.max_string_chars {
                return Err(SerializeError::limit(
                    value_context(context, path),
                    SerializeLimitKind::StringChars,
                    char_len,
                    limits.max_string_chars,
                ));
            }
            Ok(())
        }
        SerialValue::Seq(items) => {
            if items.len() > limits.max_sequence_len {
                return Err(SerializeError::limit(
                    value_context(context, path),
                    SerializeLimitKind::SequenceLength,
                    items.len(),
                    limits.max_sequence_len,
                ));
            }
            for (index, item) in items.iter().enumerate() {
                validate_serial_inner(
                    item,
                    limits,
                    state,
                    depth + 1,
                    &sequence_slot_path(path, index),
                    context,
                )?;
            }
            Ok(())
        }
        SerialValue::Map(map) => {
            if map.len() > limits.max_table_entries {
                return Err(SerializeError::limit(
                    value_context(context, path),
                    SerializeLimitKind::TableEntries,
                    map.len(),
                    limits.max_table_entries,
                ));
            }
            for (key, item) in map {
                validate_serial_inner(
                    item,
                    limits,
                    state,
                    depth + 1,
                    &map_field_path(path, key),
                    context,
                )?;
            }
            Ok(())
        }
    }
}

/// Validate an existing `SerialValue` tree against the configured limits.
pub fn validate_serial_value(
    value: &SerialValue,
    limits: &SerializeLimits,
    context: &str,
) -> Result<(), SerializeError> {
    let mut state = TraversalState::default();
    validate_serial_inner(value, limits, &mut state, 0, "$", context)
}
