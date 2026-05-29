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

