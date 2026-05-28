//! Exports the release-safe Lua REPL core: session, commands, completer, and value formatter.
//!
//! - Re-exports top-level symbols for convenient use by `lua_api` bindings and `devtools`.
//! - All REPL state is pure Rust with no wgpu or winit dependencies; safe for headless and test contexts.

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
