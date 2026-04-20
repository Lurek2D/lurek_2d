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

/// Structured log emission and level facade (`log_structured`, `set_level`, `get_level`, `enabled_for`).
pub mod facade;

pub use sinks::{MemoryEntry, RotatingFileSink, Sink, SinkLevel, SinkRegistry};
pub use facade::{enabled_for, get_level, log_structured, set_level, LogFields};
