//! Wire-format value type (`NetValue`) mirroring Lua's dynamic type system for cross-peer messaging.
//!
//! - MessagePack serialization and deserialization via `pack`/`unpack`.
//! - Zero-allocation size estimation for budget checks before sending.

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

/// Deserialize a `NetValue` from a MessagePack byte slice; returns `Serialization` error on failure.
pub fn unpack(data: &[u8]) -> Result<NetValue, NetworkError> {
    rmp_serde::from_slice(data).map_err(|e| NetworkError::Serialization(e.to_string()))
}

/// Estimate the MessagePack wire size of `value` without allocating; matches msgpack primitive encoding.
pub fn estimate_size(value: &NetValue) -> usize {
    match value {
        NetValue::Nil => 1,
        NetValue::Bool(_) => 1,
        NetValue::Integer(n) => {
            let n = *n;
            if (-32..=127).contains(&n) { 1 }
            else if n >= i8::MIN as i64 && n <= i8::MAX as i64 { 2 }
            else if n >= i16::MIN as i64 && n <= i16::MAX as i64 { 3 }
            else if n >= i32::MIN as i64 && n <= i32::MAX as i64 { 5 }
            else { 9 }
        }
        NetValue::Float(_) => 9,
        NetValue::String(s) => {
            let len = s.len();
            if len <= 31 { 1 + len }
            else if len <= 255 { 2 + len }
            else if len <= 65535 { 3 + len }
            else { 5 + len }
        }
        NetValue::Array(a) => {
            let len = a.len();
            let overhead = if len <= 15 { 1 } else if len <= 65535 { 3 } else { 5 };
            overhead + a.iter().map(estimate_size).sum::<usize>()
        }
        NetValue::Map(m) => {
            let len = m.len();
            let overhead = if len <= 15 { 1 } else if len <= 65535 { 3 } else { 5 };
            overhead + m.iter().map(|(k, v)| {
                let klen = k.len();
                let key_size = if klen <= 31 { 1 + klen } else if klen <= 255 { 2 + klen } else { 3 + klen };
                key_size + estimate_size(v)
            }).sum::<usize>()
        }
    }
}

