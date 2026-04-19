//! REPL console for interactive Lua evaluation inside a running game session.
//!
//! [`ReplConsole`] wraps a Lua VM handle and provides:
//!
//! - `eval(input, lua)` — execute a Lua snippet; returns the result as a string.
//! - `history()` — ordered list of evaluated inputs (most recent last).
//! - `clear()` — wipe the history buffer.
//!
//! History is bounded to `max_history` entries (default 200).  When the limit
//! is reached the oldest entry is dropped automatically.
//!
//! This module is pure-Rust data.  The Lua-side API lives in
//! `src/lua_api/devtools_api.rs`.

/// Interactive Lua REPL with a bounded input history buffer.
///
/// # Fields
/// - `history` — `Vec<String>` — evaluated inputs, oldest first.
/// - `max_history` — `usize` — maximum number of history entries kept.
#[derive(Debug, Clone)]
pub struct ReplConsole {
    history: Vec<String>,
    max_history: usize,
}

impl Default for ReplConsole {
    fn default() -> Self {
        Self::new(200)
    }
}

impl ReplConsole {
    /// Creates a new REPL console with the given history limit.
    ///
    /// # Parameters
    /// - `max_history` — `usize` — maximum entries to keep (min 1).
    ///
    /// # Returns
    /// `ReplConsole`.
    pub fn new(max_history: usize) -> Self {
        let cap = max_history.max(1);
        Self {
            history: Vec::with_capacity(cap.min(64)),
            max_history: cap,
        }
    }

    /// Evaluates a Lua snippet and records the input in history.
    ///
    /// The Lua chunk is wrapped in `tostring(...)` so that single-expression
    /// inputs (e.g. `1 + 1`) return their value as a string.  Multi-statement
    /// inputs are run without the wrapper; if the chunk raises an error the
    /// error message is returned rather than propagating as a Rust error.
    ///
    /// # Parameters
    /// - `input` — `&str` — Lua snippet to evaluate.
    /// - `lua` — `&mlua::Lua` — live Lua VM to evaluate against.
    ///
    /// # Returns
    /// `String` — result or error text.
    pub fn eval(&mut self, input: &str, lua: &mlua::Lua) -> String {
        // Record the input first, before evaluation.
        self.push_history(input.to_string());

        // Try to eval as an expression first (prepend "return").
        let expr = format!("return {input}");
        let result: String = match lua.load(&expr).eval::<mlua::Value>() {
            Ok(v) => lua_value_to_string(&v),
            Err(_) => {
                // Fall back to running as a statement block.
                match lua.load(input).exec() {
                    Ok(()) => "(ok)".to_string(),
                    Err(e) => format!("error: {e}"),
                }
            }
        };

        log::debug!("devtools: repl eval → {result}");
        result
    }

    /// Returns a read-only slice of the history buffer (oldest first).
    ///
    /// # Returns
    /// `&[String]`.
    pub fn history(&self) -> &[String] {
        &self.history
    }

    /// Clears the history buffer.
    pub fn clear(&mut self) {
        self.history.clear();
        log::debug!("devtools: repl history cleared");
    }

    /// Returns the current number of history entries.
    ///
    /// # Returns
    /// `usize`.
    pub fn len(&self) -> usize {
        self.history.len()
    }

    /// Returns `true` if the history is empty.
    ///
    /// # Returns
    /// `bool`.
    pub fn is_empty(&self) -> bool {
        self.history.is_empty()
    }

    // ------------------------------------------------------------------
    // Internal helpers
    // ------------------------------------------------------------------

    fn push_history(&mut self, entry: String) {
        if self.history.len() >= self.max_history {
            self.history.remove(0);
        }
        self.history.push(entry);
    }
}

// ---------------------------------------------------------------------------
// Internal display helper
// ---------------------------------------------------------------------------

fn lua_value_to_string(v: &mlua::Value) -> String {
    match v {
        mlua::Value::Nil => "nil".to_string(),
        mlua::Value::Boolean(b) => b.to_string(),
        mlua::Value::Integer(i) => i.to_string(),
        mlua::Value::Number(n) => format!("{n}"),
        mlua::Value::String(s) => s.to_str().unwrap_or("<string>").to_string(),
        mlua::Value::Table(_) => "<table>".to_string(),
        mlua::Value::Function(_) => "<function>".to_string(),
        mlua::Value::UserData(_) => "<userdata>".to_string(),
        _ => "<value>".to_string(),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn new_repl_is_empty() {
        let r = ReplConsole::new(50);
        assert!(r.is_empty());
        assert_eq!(r.len(), 0);
    }

    #[test]
    fn push_history_and_retrieve() {
        let mut r = ReplConsole::new(10);
        r.push_history("print(1)".to_string());
        r.push_history("print(2)".to_string());
        assert_eq!(r.len(), 2);
        assert_eq!(r.history()[0], "print(1)");
    }

    #[test]
    fn max_history_eviction() {
        let mut r = ReplConsole::new(3);
        for i in 0..5 {
            r.push_history(format!("cmd{i}"));
        }
        assert_eq!(r.len(), 3);
        assert_eq!(r.history()[0], "cmd2");
    }

    #[test]
    fn clear_empties_history() {
        let mut r = ReplConsole::new(10);
        r.push_history("x".to_string());
        r.clear();
        assert!(r.is_empty());
    }

    #[test]
    fn default_repl_has_capacity_200() {
        let r = ReplConsole::default();
        assert_eq!(r.max_history, 200);
    }
}
