//! - Compatibility wrapper around the release-safe REPL core
//! - Preserves the devtools `ReplConsole` API and bounded history behavior
//! - Returns expression results, success markers, command text, or formatted error text

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
    /// Return an immutable slice of stored history entries.
    pub fn history(&self) -> &[String] {
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
