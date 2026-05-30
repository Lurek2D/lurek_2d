//! This file defines the small command language for colon-prefixed REPL control actions.
//! It keeps command intent separate from evaluation logic so parsing and execution stay cleanly divided.
//! The result is a lightweight vocabulary for session management layered on top of ordinary Lua input.

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
