//! This module provides the headless REPL stack for evaluating Lua, formatting results, and assisting interactive input.
//! It keeps the feature independent from rendering concerns so terminals, tests, and tools can all reuse the same session core.
//! At the top level this is the engine's embeddable interactive console backend rather than a UI implementation.

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
