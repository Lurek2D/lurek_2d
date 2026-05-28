//! MessagePack binary encoding and decoding for SerialValue trees.
//!
//! - Enum: `MsgValue`.
//! - Functions: `encode`, `decode`, `encode_json`, `decode_json`.

use super::lua_table::SerialValue;
use crate::log_msg;
use crate::runtime::log_messages::{SR04_MSGPACK_DEC, SR05_MSGPACK_ENC};
use indexmap::IndexMap;
use rmp_serde as rmps;
use serde::{Deserialize, Serialize};

/// Intermediate value type used for MessagePack serialization roundtrips.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(untagged)]
pub(super) enum MsgValue {
    /// Nil / null value.
    Null,
    /// Boolean value.
    Bool(bool),
    /// Signed 64-bit integer.
    Int(i64),
    /// 64-bit floating-point number.
    Float(f64),
    /// UTF-8 string.
    Str(String),
    /// Ordered sequence of values.
    Seq(Vec<MsgValue>),
    /// String-keyed map of values.
    Map(std::collections::HashMap<String, MsgValue>),
}
/// Convert a SerialValue tree into the MsgValue intermediate representation.
fn serial_to_msg(val: &SerialValue) -> MsgValue {
    match val {
        SerialValue::Null => MsgValue::Null,
        SerialValue::Bool(b) => MsgValue::Bool(*b),
        SerialValue::Int(n) => MsgValue::Int(*n),
        SerialValue::Float(f) => MsgValue::Float(*f),
        SerialValue::Str(s) => MsgValue::Str(s.clone()),
        SerialValue::Seq(arr) => MsgValue::Seq(arr.iter().map(serial_to_msg).collect()),
        SerialValue::Map(map) => {
            let mut hm = std::collections::HashMap::with_capacity(map.len());
            for (k, v) in map {
                hm.insert(k.clone(), serial_to_msg(v));
            }
            MsgValue::Map(hm)
        }
    }
}
/// Estimate the encoded byte size of a MsgValue for buffer pre-allocation.
fn estimate_msg_size(val: &MsgValue) -> usize {
    match val {
        MsgValue::Null => 1,
        MsgValue::Bool(_) => 1,
        MsgValue::Int(_) => 9,
        MsgValue::Float(_) => 9,
        MsgValue::Str(s) => 5 + s.len(),
        MsgValue::Seq(items) => 5 + items.iter().map(estimate_msg_size).sum::<usize>(),
        MsgValue::Map(map) => {
            5 + map
                .iter()
                .map(|(k, v)| 5 + k.len() + estimate_msg_size(v))
                .sum::<usize>()
        }
    }
}
/// Convert a decoded MsgValue back into a SerialValue tree.
fn msg_to_serial(val: MsgValue) -> SerialValue {
    match val {
        MsgValue::Null => SerialValue::Null,
        MsgValue::Bool(b) => SerialValue::Bool(b),
        MsgValue::Int(n) => SerialValue::Int(n),
        MsgValue::Float(f) => SerialValue::Float(f),
        MsgValue::Str(s) => SerialValue::Str(s),
        MsgValue::Seq(arr) => SerialValue::Seq(arr.into_iter().map(msg_to_serial).collect()),
        MsgValue::Map(map) => {
            let mut ordered = IndexMap::new();
            for (k, v) in map {
                ordered.insert(k, msg_to_serial(v));
            }
            SerialValue::Map(ordered)
        }
    }
}
/// Encode a SerialValue tree into MessagePack bytes.
pub fn encode(val: &SerialValue) -> Result<Vec<u8>, String> {
    let mv = serial_to_msg(val);
    let mut bytes = Vec::with_capacity(estimate_msg_size(&mv));
    let mut serializer = rmps::Serializer::new(&mut bytes).with_struct_map();
    mv.serialize(&mut serializer)
        .map_err(|e| format!("MessagePack encode error: {e}"))?;
    log_msg!(debug, SR05_MSGPACK_ENC);
    Ok(bytes)
}
/// Decode MessagePack bytes into a SerialValue tree.
pub fn decode(bytes: &[u8]) -> Result<SerialValue, String> {
    let mv: MsgValue = {
        let mut deserializer = rmps::Deserializer::new(std::io::Cursor::new(bytes));
        let value = MsgValue::deserialize(&mut deserializer)
            .map_err(|e| format!("MessagePack decode error: {e}"))?;
        let consumed = deserializer.get_ref().position() as usize;
        if consumed != bytes.len() {
            return Err("MessagePack decode error: trailing bytes after root value".to_string());
        }
        value
    };
    log_msg!(debug, SR04_MSGPACK_DEC);
    Ok(msg_to_serial(mv))
}
/// Encode a serde_json Value into MessagePack bytes.
pub fn encode_json(value: &serde_json::Value) -> Result<Vec<u8>, String> {
    let bytes = rmps::to_vec(value).map_err(|e| format!("MessagePack encode error: {e}"))?;
    Ok(bytes)
}
/// Decode MessagePack bytes into a serde_json Value.
pub fn decode_json(bytes: &[u8]) -> Result<serde_json::Value, String> {
    use serde::Deserialize;
    let mut deserializer = rmps::Deserializer::new(std::io::Cursor::new(bytes));
    let value = serde_json::Value::deserialize(&mut deserializer)
        .map_err(|e| format!("MessagePack decode error: {e}"))?;
    let consumed = deserializer.get_ref().position() as usize;
    if consumed != bytes.len() {
        return Err("MessagePack decode error: trailing bytes after root value".to_string());
    }
    Ok(value)
}
