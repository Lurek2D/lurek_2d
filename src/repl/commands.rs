//! This file defines the small command language for colon-prefixed REPL control actions. `repl/commands` delivers the commands implementation for the repl subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! It keeps command intent separate from evaluation logic so parsing and execution stay cleanly divided. The file owns or coordinates data contracts including `ReplCommand`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! The result is a lightweight vocabulary for session management layered on top of ordinary Lua input. Public callable behavior is centered on no named public items, while method-level behavior such as `display_text` stays attached to the local data model and invariants.

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
