//! This file bridges the dynamic world of Lua tables and values into the typed intermediate tree used by the serialization subsystem.
//! It decides when Lua data should be treated as sequences, maps, scalars, or explicit null-like values for downstream codecs.
//! Array-like tables are recognized structurally so callers do not have to tag them manually before encoding.
//! The reverse path also lives here, turning decoded serial values back into Lua-friendly tables and primitives.
//! This file is the language boundary where loose script data becomes format-ready structured data.

use indexmap::IndexMap;
use mlua::prelude::{Lua, LuaResult, LuaValue};
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
#[derive(Debug, Clone)]
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
/// Convert a Lua value into a `SerialValue` tree, detecting arrays automatically.
pub fn from_lua(val: &LuaValue) -> LuaResult<SerialValue> {
    match val {
        LuaValue::Nil => Ok(SerialValue::Null),
        LuaValue::Boolean(b) => Ok(SerialValue::Bool(*b)),
        LuaValue::Integer(n) => Ok(SerialValue::Int(*n)),
        LuaValue::Number(f) => {
            if f.fract() == 0.0 && *f >= i64::MIN as f64 && *f <= i64::MAX as f64 {
                Ok(SerialValue::Int(*f as i64))
            } else {
                Ok(SerialValue::Float(*f))
            }
        }
        LuaValue::String(s) => Ok(SerialValue::Str(
            s.to_str()
                .map_err(|e| mlua::Error::RuntimeError(format!("Invalid UTF-8: {e}")))?
                .to_string(),
        )),
        LuaValue::Table(t) => {
            let raw_len = t.raw_len();
            if raw_len > 0 {
                let mut seq_values = vec![None; raw_len];
                let mut map = IndexMap::new();
                let mut total_entries = 0usize;
                let mut is_seq = true;

                for pair in t.clone().pairs::<LuaValue, LuaValue>() {
                    let (k, v) = pair?;
                    total_entries += 1;
                    let converted = from_lua(&v)?;
                    match &k {
                        LuaValue::Integer(n) if *n >= 1 && (*n as usize) <= raw_len => {
                            seq_values[*n as usize - 1] = Some(converted.clone());
                            map.insert(n.to_string(), converted);
                        }
                        LuaValue::String(s) => {
                            is_seq = false;
                            let key = s
                                .to_str()
                                .map_err(|e| {
                                    mlua::Error::RuntimeError(format!("Invalid UTF-8 key: {e}"))
                                })?
                                .to_string();
                            map.insert(key, converted);
                        }
                        LuaValue::Number(f) => {
                            is_seq = false;
                            map.insert(f.to_string(), converted);
                        }
                        _ => {
                            return Err(mlua::Error::RuntimeError(
                                "serial: table keys must be strings or numbers".to_string(),
                            ));
                        }
                    }
                }

                if is_seq && total_entries == raw_len && seq_values.iter().all(Option::is_some) {
                    let sequence = seq_values
                        .into_iter()
                        .collect::<Option<Vec<_>>>()
                        .ok_or_else(|| {
                            mlua::Error::RuntimeError(
                                "serial: sequence table validation drifted during conversion"
                                    .to_string(),
                            )
                        })?;
                    return Ok(SerialValue::Seq(sequence));
                }
                return Ok(SerialValue::Map(map));
            }
            let mut map = IndexMap::new();
            for pair in t.clone().pairs::<LuaValue, LuaValue>() {
                let (k, v) = pair?;
                let key = match &k {
                    LuaValue::String(s) => s
                        .to_str()
                        .map_err(|e| mlua::Error::RuntimeError(format!("Invalid UTF-8 key: {e}")))?
                        .to_string(),
                    LuaValue::Integer(n) => n.to_string(),
                    LuaValue::Number(f) => f.to_string(),
                    _ => {
                        return Err(mlua::Error::RuntimeError(
                            "serial: table keys must be strings or numbers".to_string(),
                        ))
                    }
                };
                map.insert(key, from_lua(&v)?);
            }
            Ok(SerialValue::Map(map))
        }
        _ => Err(mlua::Error::RuntimeError(
            "serial: unsupported Lua value type".to_string(),
        )),
    }
}
