//! MessagePack serialization and deserialization for Lurek2D.
//!
//! Provides `to_msgpack` and `from_msgpack` using the `rmp-serde` crate.
//! All Lua-visible values travel through `serde_json::Value` as the
//! intermediate representation so the full JSON type system (null, bool,
//! int, float, string, array, object) is preserved across a roundtrip.
//!
//! # Usage
//! ```no_run
//! let json_val = serde_json::json!({"x": 1, "y": 2});
//! let bytes = msgpack::to_msgpack(&json_val).unwrap();
//! let back: serde_json::Value = msgpack::from_msgpack(&bytes).unwrap();
//! assert_eq!(json_val, back);
//! ```

/// Serializes a `serde_json::Value` to MessagePack bytes.
///
/// # Parameters
/// - `value` — `&serde_json::Value`. The value to encode.
///
/// # Returns
/// `Result<Vec<u8>, String>`. The MessagePack byte representation or an error description.
pub fn to_msgpack(value: &serde_json::Value) -> Result<Vec<u8>, String> {
    rmp_serde::to_vec(value).map_err(|e| format!("MessagePack encode error: {e}"))
}

/// Deserializes MessagePack bytes into a `serde_json::Value`.
///
/// # Parameters
/// - `bytes` — `&[u8]`. The MessagePack-encoded bytes.
///
/// # Returns
/// `Result<serde_json::Value, String>`. The decoded value or an error description.
pub fn from_msgpack(bytes: &[u8]) -> Result<serde_json::Value, String> {
    use serde::Deserialize;

    let mut deserializer = rmp_serde::Deserializer::new(std::io::Cursor::new(bytes));
    let value = serde_json::Value::deserialize(&mut deserializer)
        .map_err(|e| format!("MessagePack decode error: {e}"))?;

    let consumed = deserializer.get_ref().position() as usize;
    if consumed != bytes.len() {
        return Err("MessagePack decode error: trailing bytes after root value".to_string());
    }

    Ok(value)
}
