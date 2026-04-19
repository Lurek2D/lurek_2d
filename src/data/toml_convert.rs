//! TOML parsing and encoding for Lurek2D.
//!
//! Converts between TOML strings and `toml::Value` trees. The Lua bridge
//! (`lurek.data.parseToml` / `lurek.data.encodeToml`) maps `toml::Value`
//! to/from Lua tables. Supports the full TOML v1.0 spec via the `toml` crate.

/// Parse a TOML string into a `toml::Value`.
///
/// # Parameters
/// - `input` — `&str`.
///
/// # Returns
/// `Result<toml::Value, String>`.
pub fn parse_toml(input: &str) -> Result<toml::Value, String> {
    input
        .parse::<toml::Value>()
        .map_err(|e| format!("TOML parse error: {e}"))
}

/// Encode a `toml::Value` into a TOML string.
///
/// Only table values are accepted at the top level because the TOML spec
/// requires documents to be tables. Non-table values produce an error.
///
/// # Parameters
/// - `value` — `&toml::Value`.
///
/// # Returns
/// `Result<String, String>`.
pub fn encode_toml(value: &toml::Value) -> Result<String, String> {
    match value {
        toml::Value::Table(t) => toml::to_string(t).map_err(|e| format!("TOML encode error: {e}")),
        _ => Err("encodeToml expects a table value".into()),
    }
}
