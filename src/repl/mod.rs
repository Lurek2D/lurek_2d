//! `src/repl/mod.rs` is the REPL module index, exposing the headless interactive stack used by CLI, tools, and tests.
//! It reexports command parsing, completion, session state, and value formatting so callers build a REPL from one surface.
//! No execution state lives here; this file defines the public boundary while implementation stays split by concern below.
//! Read this index when wiring REPL features, because it shows which pieces are public and how they are grouped.
//! This module keeps evaluation independent from rendering, so terminals and automation can share one session core.
//! Changes here alter the REPL boundary, since reexports decide what runtime code and developer tools may import.

/// REPL command parsing and command result types.
pub mod commands;
/// Static and Lua-aware completion helpers.
pub mod completer;
/// Stateful Lua REPL session implementation.
pub mod session;
/// Lua value formatting for REPL and headless stdout output.
pub mod value;
pub use commands::ReplCommand;
pub use completer::complete_prefix;
pub use session::{ReplResult, ReplSession};
pub use value::value_to_string;
