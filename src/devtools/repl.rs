//! Implements a compatibility wrapper around the release-safe REPL session core. `devtools/repl` delivers the repl implementation for the devtools subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Preserves devtools console API shape with bounded command-history behavior. The file owns or coordinates data contracts including `ReplConsole`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Returns evaluation outcomes as success markers, value strings, or formatted errors. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `eval`, `history`, `clear`, `len`, `is_empty` stays attached to the local data model and invariants.

use crate::repl::ReplSession;
#[derive(Debug, Clone)]
/// Store REPL command history and capacity limits for local dev sessions.
pub struct ReplConsole {
    /// Shared release-safe REPL implementation.
    inner: ReplSession,
}
/// Provide default REPL history capacity for convenience construction.
impl Default for ReplConsole {
    fn default() -> Self {
        Self::new(200)
    }
}
impl ReplConsole {
    /// Create a REPL console with bounded history and return the instance.
    pub fn new(max_history: usize) -> Self {
        Self {
            inner: ReplSession::new(max_history),
        }
    }
    /// Evaluate input and return expression result, ok marker, or error text.
    pub fn eval(&mut self, input: &str, lua: &mlua::Lua) -> String {
        let result = self.inner.eval_line(input, lua).display_text();
        log::debug!("devtools: repl eval → {result}");
        result
    }
    /// Return an iterator over stored history entries from oldest to newest.
    pub fn history(&self) -> impl Iterator<Item = &String> {
        self.inner.history()
    }
    /// Clear command history and return unit.
    pub fn clear(&mut self) {
        self.inner.clear();
        log::debug!("devtools: repl history cleared");
    }
    /// Return the number of stored history entries.
    pub fn len(&self) -> usize {
        self.inner.len()
    }
    /// Return true when history contains no entries.
    pub fn is_empty(&self) -> bool {
        self.inner.is_empty()
    }
}
