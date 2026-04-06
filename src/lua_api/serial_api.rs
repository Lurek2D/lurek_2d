//! `luna.serial` — Format-agnostic string serialization: JSON, TOML, and CSV.

use super::SharedState;
use mlua::prelude::*;
use std::cell::RefCell;
use std::rc::Rc;

use crate::serial::{CsvOptions, SerialValue};
use indexmap::IndexMap;

// -------------------------------------------------------------------------------
// Conversion helpers
// -------------------------------------------------------------------------------

/// Convert a [`SerialValue`] tree to a Lua value.
fn serial_value_to_lua<'lua>(lua: &'lua Lua, val: &SerialValue) -> LuaResult<LuaValue<'lua>> {
    match val {
        SerialValue::Null => Ok(LuaValue::Nil),
        SerialValue::Bool(b) => Ok(LuaValue::Boolean(*b)),
        SerialValue::Int(n) => Ok(LuaValue::Integer(*n)),
        SerialValue::Float(f) => Ok(LuaValue::Number(*f)),
        SerialValue::Str(s) => Ok(LuaValue::String(lua.create_string(s)?)),
        SerialValue::Seq(arr) => {
            let t = lua.create_table()?;
            for (i, v) in arr.iter().enumerate() {
                t.set(i as i64 + 1, serial_value_to_lua(lua, v)?)?;
            }
            Ok(LuaValue::Table(t))
        }
        SerialValue::Map(map) => {
            let t = lua.create_table()?;
            for (k, v) in map {
                t.set(k.as_str(), serial_value_to_lua(lua, v)?)?;
            }
            Ok(LuaValue::Table(t))
        }
    }
}

/// Convert a Lua value to a [`SerialValue`] tree.
fn lua_value_to_serial(val: &LuaValue) -> LuaResult<SerialValue> {
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
                .map_err(|e| LuaError::RuntimeError(format!("Invalid UTF-8: {e}")))?
                .to_string(),
        )),
        LuaValue::Table(t) => {
            let raw_len = t.raw_len();
            if raw_len > 0 {
                let mut is_seq = true;
                for i in 1..=raw_len as i64 {
                    let v: LuaValue = t.get(i)?;
                    if v == LuaValue::Nil {
                        is_seq = false;
                        break;
                    }
                }
                if is_seq {
                    let mut arr = Vec::with_capacity(raw_len);
                    for i in 1..=raw_len as i64 {
                        let v: LuaValue = t.get(i)?;
                        arr.push(lua_value_to_serial(&v)?);
                    }
                    return Ok(SerialValue::Seq(arr));
                }
            }
            let mut map = IndexMap::new();
            for pair in t.clone().pairs::<LuaValue, LuaValue>() {
                let (k, v) = pair?;
                let key = match &k {
                    LuaValue::String(s) => s
                        .to_str()
                        .map_err(|e| LuaError::RuntimeError(format!("Invalid UTF-8 key: {e}")))?
                        .to_string(),
                    LuaValue::Integer(n) => n.to_string(),
                    LuaValue::Number(f) => f.to_string(),
                    _ => {
                        return Err(LuaError::RuntimeError(
                            "serial: table keys must be strings or numbers".to_string(),
                        ))
                    }
                };
                map.insert(key, lua_value_to_serial(&v)?);
            }
            Ok(SerialValue::Map(map))
        }
        _ => Err(LuaError::RuntimeError(
            "serial: unsupported Lua value type".to_string(),
        )),
    }
}

/// Extract the first byte from an optional delimiter string, defaulting to comma.
fn parse_delimiter(delim: Option<String>) -> u8 {
    delim
        .as_deref()
        .and_then(|d| d.as_bytes().first().copied())
        .unwrap_or(b',')
}

// -------------------------------------------------------------------------------
// Register
// -------------------------------------------------------------------------------

/// Registers the `luna.serial` API table with the Lua VM.
pub fn register(lua: &Lua, luna: &LuaTable, _state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let tbl = lua.create_table()?;

    // -- fromJson --
    /// Parses a JSON string and returns a Lua table.
    /// @param s : string
    /// @return table
    tbl.set(
        "fromJson",
        lua.create_function(|lua, s: String| {
            let val = crate::serial::from_json(&s).map_err(LuaError::RuntimeError)?;
            serial_value_to_lua(lua, &val)
        })?,
    )?;

    // -- toJson --
    /// Serializes a Lua value to a JSON string.
    /// @param value : table
    /// @param pretty : boolean?
    /// @return string
    tbl.set(
        "toJson",
        lua.create_function(|_, (value, pretty): (LuaValue, Option<bool>)| {
            let val = lua_value_to_serial(&value)?;
            crate::serial::to_json(&val, pretty.unwrap_or(false)).map_err(LuaError::RuntimeError)
        })?,
    )?;

    // -- fromToml --
    /// Parses a TOML string and returns a Lua table.
    /// @param s : string
    /// @return table
    tbl.set(
        "fromToml",
        lua.create_function(|lua, s: String| {
            let val = crate::serial::from_toml(&s).map_err(LuaError::RuntimeError)?;
            serial_value_to_lua(lua, &val)
        })?,
    )?;

    // -- toToml --
    /// Serializes a Lua table to a TOML string.
    /// @param value : table
    /// @return string
    tbl.set(
        "toToml",
        lua.create_function(|_, value: LuaValue| {
            let val = lua_value_to_serial(&value)?;
            crate::serial::to_toml(&val).map_err(LuaError::RuntimeError)
        })?,
    )?;

    // -- fromCsv --
    /// Parses a CSV string and returns a sequence of row tables.
    /// @param s : string
    /// @param delimiter : string?
    /// @param has_headers : boolean?
    /// @return table
    tbl.set(
        "fromCsv",
        lua.create_function(
            |lua, (s, delim, headers): (String, Option<String>, Option<bool>)| {
                let opts = CsvOptions {
                    delimiter: parse_delimiter(delim),
                    has_headers: headers.unwrap_or(true),
                };
                let val = crate::serial::from_csv(&s, opts).map_err(LuaError::RuntimeError)?;
                serial_value_to_lua(lua, &val)
            },
        )?,
    )?;

    // -- toCsv --
    /// Serializes a sequence of row tables to a CSV string.
    /// @param value : table
    /// @param delimiter : string?
    /// @param has_headers : boolean?
    /// @return string
    tbl.set(
        "toCsv",
        lua.create_function(
            |_, (value, delim, headers): (LuaValue, Option<String>, Option<bool>)| {
                let opts = CsvOptions {
                    delimiter: parse_delimiter(delim),
                    has_headers: headers.unwrap_or(true),
                };
                let val = lua_value_to_serial(&value)?;
                crate::serial::to_csv(&val, opts).map_err(LuaError::RuntimeError)
            },
        )?,
    )?;

    luna.set("serial", tbl)?;
    Ok(())
}
