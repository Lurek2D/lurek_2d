//! Wire-format value type mirroring Lua's dynamic type system for peer messaging. `network/message` delivers the message implementation for the network subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Uses MessagePack serialization and deserialization for packed transport. The file owns or coordinates data contracts including `NetValue`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Provides zero-allocation size estimation before a message is sent. Public callable behavior is centered on `pack`, `unpack`, while method-level behavior such as no named public items stays attached to the local data model and invariants.

use super::error::NetworkError;
use serde::{Deserialize, Serialize};

/// Dynamically-typed wire value that mirrors Lua's type system for cross-peer messaging.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum NetValue {
    /// Represents a Lua `nil` or absent value on the wire.
    Nil,
    /// Boolean `true` or `false`.
    Bool(bool),
    /// 64-bit signed integer.
    Integer(i64),
    /// 64-bit IEEE-754 float.
    Float(f64),
    /// UTF-8 string payload.
    String(String),
    /// Ordered sequence of `NetValue` items, analogous to a Lua array.
    Array(Vec<NetValue>),
    /// String-keyed map of `NetValue` entries, analogous to a Lua table.
    Map(Vec<(String, NetValue)>),
}

/// Serialize `value` into a MessagePack byte vector; returns `Serialization` error on failure.
pub fn pack(value: &NetValue) -> Result<Vec<u8>, NetworkError> {
    rmp_serde::to_vec(value).map_err(|e| NetworkError::Serialization(e.to_string()))
}

fn check_nesting(value: &NetValue, depth: usize) -> Result<(), NetworkError> {
    if depth > 32 {
        return Err(NetworkError::Serialization(
            "maximum nesting depth exceeded".into(),
        ));
    }
    match value {
        NetValue::Array(arr) => {
            for val in arr {
                check_nesting(val, depth + 1)?;
            }
        }
        NetValue::Map(map) => {
            for (_, val) in map {
                check_nesting(val, depth + 1)?;
            }
        }
        _ => {}
    }
    Ok(())
}

/// Deserialize a `NetValue` from a MessagePack byte slice; returns `Serialization` error on failure.
pub fn unpack(data: &[u8]) -> Result<NetValue, NetworkError> {
    if data.len() > 65536 {
        return Err(NetworkError::Serialization("payload too large".into()));
    }
    let val: NetValue =
        rmp_serde::from_slice(data).map_err(|e| NetworkError::Serialization(e.to_string()))?;
    check_nesting(&val, 1)?;
    Ok(val)
}
