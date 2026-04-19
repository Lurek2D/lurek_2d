//! Structured log level management and configurable log sinks for Lurek2D scripts.
//!
//! This module is the Foundations-tier logging facade exposed to Lua through
//! `lurek.log.*`.  It delegates to Rust's [`log`] crate via
//! `crate::runtime::log_messages` so that game-script output appears alongside
//! engine log output, all controlled by the `RUST_LOG` environment variable.
//!
//! ## Architecture
//!
//! * **Global level management** — [`set_level`], [`get_level`], and
//!   [`enabled_for`] wrap `crate::runtime::log_messages` to provide a
//!   single Lua-accessible knob for the global `log` filter.
//! * **Structured logging** — [`log_structured`] emits `msg { k1=v1, … }`
//!   through the Rust `log` crate.  The caller is responsible for also
//!   dispatching to [`SinkRegistry`] for VM-local sinks.
//! * **Configurable sinks** — the [`sinks`] submodule lets Lua scripts add
//!   file, rotating-file, and in-memory ring-buffer destinations beyond the
//!   default stderr channel.

/// Configurable log sink registry for file and in-memory log destinations.
pub mod sinks;

pub use sinks::{MemoryEntry, RotatingFileSink, Sink, SinkLevel, SinkRegistry};

use std::collections::BTreeMap;
use crate::runtime::log_messages;

/// Sorted map of structured key-value log fields.
///
/// Used with [`log_structured`] to attach machine-readable context to a log message.
pub type LogFields = BTreeMap<String, String>;

/// Emits a structured log message with key-value `fields` through the Rust `log` crate.
///
/// The formatted message sent to the logger is `"msg { k1=v1, k2=v2 }"`.
/// Sink dispatch (file / memory ring buffers) must be done separately by the caller
/// via [`SinkRegistry::dispatch_structured`] because sinks are VM-local.
///
/// # Parameters
/// - `level` — `log::Level`.
/// - `tag` — `Option<&str>`. Defaults to `"Lua"` when `None`.
/// - `msg` — `&str`.
/// - `fields` — `&LogFields`.
pub fn log_structured(level: ::log::Level, tag: Option<&str>, msg: &str, fields: &LogFields) {
    // Default tag to "Lua" so game-script messages are identifiable in mixed output.
    let t = tag.unwrap_or("Lua");

    // Format body: plain message when no fields, otherwise "msg { k1=v1, k2=v2 }".
    let body = if fields.is_empty() {
        msg.to_string()
    } else {
        let kvs: Vec<String> = fields.iter().map(|(k, v)| format!("{k}={v}")).collect();
        format!("{} {{ {} }}", msg, kvs.join(", "))
    };

    // Dispatch through the Rust `log` crate at the requested severity.
    match level {
        ::log::Level::Error => log::error!("[{}] {}", t, body),
        ::log::Level::Warn  => log::warn!("[{}] {}", t, body),
        ::log::Level::Info  => log::info!("[{}] {}", t, body),
        ::log::Level::Debug => log::debug!("[{}] {}", t, body),
        ::log::Level::Trace => log::trace!("[{}] {}", t, body),
    }
}

/// Sets the active log level to the named value.
///
/// `level` must be one of `"off"`, `"error"`, `"warn"`, `"info"`, `"debug"`, or `"trace"`.
/// Unrecognised values are silently ignored.
///
/// # Parameters
/// - `level` — `&str`.
pub fn set_level(level: &str) {
    log_messages::set_log_level(level);
}

/// Returns the current log level name as a static string (e.g. `"info"`).
///
/// # Returns
/// `String`.
pub fn get_level() -> String {
    log_messages::get_log_level().to_string()
}

/// Returns `true` when messages at `level` would be emitted under the current filter.
///
/// Compares the requested level against the `log` crate's global
/// [`log::max_level()`].  Unrecognised level strings and the special
/// values `"off"` / `"none"` always return `false`.
///
/// # Parameters
/// - `level` — `&str` — one of `"error"`, `"warn"` / `"warning"`,
///   `"info"`, `"debug"`, `"trace"`, `"off"` / `"none"`.
///
/// # Returns
/// `bool` — `true` if the current max-level permits this severity.
pub fn enabled_for(level: &str) -> bool {
    use ::log::LevelFilter;
    // Map the string to a LevelFilter; short-circuit on special / unknown values.
    let filter = match level.to_lowercase().as_str() {
        "error" => LevelFilter::Error,
        "warn" | "warning" => LevelFilter::Warn,
        "info" => LevelFilter::Info,
        "debug" => LevelFilter::Debug,
        "trace" => LevelFilter::Trace,
        "off" | "none" => return false,
        _ => return false,
    };
    ::log::max_level() >= filter
}
