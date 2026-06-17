//! This module provides the headless REPL stack for evaluating Lua, formatting results, and assisting interactive input. `repl/mod` is the repl module index, declaring `commands`, `completer`, `session`, `value` so agents can identify which files own each feature slice before opening implementation code.
//! It keeps the feature independent from rendering concerns so terminals, tests, and tools can all reuse the same session core.

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
