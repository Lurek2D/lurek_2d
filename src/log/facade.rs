//! Structured log dispatch with level, tag, and key-value fields.
//!
//! - Runtime log-level query and mutation via string names.
//! - Level-filter check without emitting a message.

use crate::runtime::log_messages;
use std::collections::BTreeMap;

/// Ordered key-value pairs appended to structured log messages.
pub type LogFields = BTreeMap<String, String>;

/// Dispatch a structured log message at `level` with optional `tag` and `fields`; tag defaults to "Lua".
pub fn log_structured(level: ::log::Level, tag: Option<&str>, msg: &str, fields: &LogFields) {
    let t = tag.unwrap_or("Lua");
    let body = if fields.is_empty() {
        msg.to_string()
    } else {
        let kvs: Vec<String> = fields.iter().map(|(k, v)| format!("{k}={v}")).collect();
        format!("{} {{ {} }}", msg, kvs.join(", "))
    };
    match level {
        ::log::Level::Error => log::error!("[{}] {}", t, body),
        ::log::Level::Warn => log::warn!("[{}] {}", t, body),
        ::log::Level::Info => log::info!("[{}] {}", t, body),
        ::log::Level::Debug => log::debug!("[{}] {}", t, body),
        ::log::Level::Trace => log::trace!("[{}] {}", t, body),
    }
}

/// Set the global log level from a string ("error", "warn", "info", "debug", "trace").
pub fn set_level(level: &str) {
    log_messages::set_log_level(level);
}

/// Return the current global log level as a string.
pub fn get_level() -> String {
    log_messages::get_log_level().to_string()
}

/// Returns true if `level` is a recognized, non-disabled log level name.
pub fn enabled_for(level: &str) -> bool {
    matches!(
        level.to_ascii_lowercase().as_str(),
        "trace" | "debug" | "info" | "warn" | "warning" | "error" | "err"
    )
}

