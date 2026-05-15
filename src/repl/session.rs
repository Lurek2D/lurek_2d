//! - Implements `ReplSession`, a stateful Lua evaluator with bounded command history.
//! - `ReplResult` captures value output, silent success, structured error text, or a parsed colon command.
//! - Eval dispatches colon commands first; expression input tries `return <input>` then falls back to statement execution.
//! - History is capped at `max_history` entries; oldest entries are evicted when the cap is reached; default capacity is 200.
//! - `:load` reads a file from disk and executes it inside the current Lua VM, returning a command or error result.
//! - Session state is pure Rust; the Lua reference is borrowed per call and never stored on the struct.

use crate::repl::commands::ReplCommand;
use crate::repl::completer::complete_prefix;
use crate::repl::value::value_to_string;
use mlua::prelude::*;

#[derive(Debug, Clone, PartialEq, Eq)]
/// Result of evaluating one REPL line.
pub enum ReplResult {
    /// Lua expression returned displayable values.
    Value(String),
    /// Lua statement executed successfully without return values.
    Ok,
    /// Lua parsing, runtime, or file loading failed.
    Error(String),
    /// A colon command was accepted.
    Command(ReplCommand),
}

impl ReplResult {
    /// Convert the result into the text shown by devtools and CLI views.
    pub fn display_text(&self) -> String {
        match self {
            Self::Value(value) => value.clone(),
            Self::Ok => "(ok)".to_string(),
            Self::Error(error) => format!("error: {}", error),
            Self::Command(command) => command.display_text(),
        }
    }
}

#[derive(Debug, Clone)]
/// Release-safe Lua REPL session with bounded command history.
pub struct ReplSession {
    /// Stored input history in oldest-to-newest order.
    history: Vec<String>,
    /// Maximum number of history entries retained.
    max_history: usize,
}

/// Provides a 200-entry history capacity as the sensible startup default.
impl Default for ReplSession {
    fn default() -> Self {
        Self::new(200)
    }
}

impl ReplSession {
    /// Create a REPL session with bounded history capacity.
    pub fn new(max_history: usize) -> Self {
        let capacity = max_history.max(1);
        Self {
            history: Vec::with_capacity(capacity.min(64)),
            max_history: capacity,
        }
    }

    /// Evaluate one line as a command, expression, or statement.
    pub fn eval_line(&mut self, line: &str, lua: &Lua) -> ReplResult {
        let input = line.trim();
        if input.is_empty() {
            return ReplResult::Ok;
        }
        self.push_history(input.to_string());
        if let Some(command) = self.handle_command(input, lua) {
            return command;
        }
        let expression = format!("return {}", input);
        match lua.load(&expression).eval::<mlua::MultiValue>() {
            Ok(values) => values_to_result(values),
            Err(_) => match lua.load(input).exec() {
                Ok(()) => ReplResult::Ok,
                Err(error) => ReplResult::Error(error.to_string()),
            },
        }
    }

    /// Return an immutable view of recorded history entries.
    pub fn history(&self) -> &[String] {
        &self.history
    }

    /// Clear all recorded REPL command history entries.
    pub fn clear(&mut self) {
        self.history.clear();
    }

    /// Return the number of retained history entries.
    pub fn len(&self) -> usize {
        self.history.len()
    }

    /// Return true when no history entries are stored.
    pub fn is_empty(&self) -> bool {
        self.history.is_empty()
    }

    /// Return sorted completions for a prefix using static and Lua table candidates.
    pub fn completions_for(&self, prefix: &str, lua: Option<&Lua>) -> Vec<String> {
        complete_prefix(prefix, lua)
    }

    /// Detect colon commands and dispatch them; return `None` for plain Lua input.
    fn handle_command(&mut self, input: &str, lua: &Lua) -> Option<ReplResult> {
        if !input.starts_with(':') {
            return None;
        }
        match input {
            ":help" => Some(ReplResult::Command(ReplCommand::Help)),
            ":quit" => Some(ReplResult::Command(ReplCommand::Quit)),
            ":clear" => {
                self.clear();
                Some(ReplResult::Command(ReplCommand::Clear))
            }
            ":reset" => {
                self.clear();
                Some(ReplResult::Command(ReplCommand::Reset))
            }
            _ => input
                .strip_prefix(":load ")
                .map(str::trim)
                .map(|path| self.load_file(path, lua)),
        }
    }

    /// Read, compile, and execute the file at `path` and return a command or error result.
    fn load_file(&mut self, path: &str, lua: &Lua) -> ReplResult {
        if path.is_empty() {
            return ReplResult::Error(":load requires a file path".to_string());
        }
        let code = match std::fs::read_to_string(path) {
            Ok(code) => code,
            Err(error) => return ReplResult::Error(format!("{}: {}", path, error)),
        };
        match lua.load(&code).set_name(path).exec() {
            Ok(()) => ReplResult::Command(ReplCommand::Load {
                path: path.to_string(),
            }),
            Err(error) => ReplResult::Error(format!("{}: {}", path, error)),
        }
    }

    /// Append `entry` and evict the oldest entry when the capacity is exceeded.
    fn push_history(&mut self, entry: String) {
        if self.history.len() >= self.max_history {
            self.history.remove(0);
        }
        self.history.push(entry);
    }
}

/// Convert multi-value Lua output to `ReplResult::Value` or `ReplResult::Ok` for empty returns.
fn values_to_result(values: mlua::MultiValue) -> ReplResult {
    if values.is_empty() {
        return ReplResult::Ok;
    }
    let parts: Vec<String> = values.iter().map(value_to_string).collect();
    ReplResult::Value(parts.join("\t"))
}
