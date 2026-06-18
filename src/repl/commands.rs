//! `src/repl/commands.rs` defines the colon-command vocabulary that controls REPL behavior without entering plain Lua code.
//! `ReplCommand` captures help, quit, clear, reset, and file-load intents so session control stays typed and explicit.
//! Open this file when REPL control syntax or command result text changes, not when Lua evaluation semantics change.

#[derive(Debug, Clone, PartialEq, Eq)]
/// Special colon command recognised by `ReplSession`.
pub enum ReplCommand {
    /// Display command help.
    Help,
    /// Request REPL shutdown.
    Quit,
    /// Clear the current REPL display or history.
    Clear,
    /// Request a fresh Lua VM from the embedding CLI.
    Reset,
    /// Load and execute a Lua source file.
    Load { path: String },
}

impl ReplCommand {
    /// Return a short human-readable command result.
    pub fn display_text(&self) -> String {
        match self {
            Self::Help => ":help, :quit, :clear, :reset, :load <file>".to_string(),
            Self::Quit => "(quit)".to_string(),
            Self::Clear => "(cleared)".to_string(),
            Self::Reset => "(reset)".to_string(),
            Self::Load { path } => format!("(ok) loaded {}", path),
        }
    }
}
