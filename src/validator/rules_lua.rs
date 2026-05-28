//! Lua-defined custom validation rules registered via pattern and callback config.
//!
//! - `LuaPatternRule` wraps a Lua callback and a file-extension filter.
//! - Called from `validation_engine` with `(path, content)` as string arguments.
//! - Lua callback must return a table of `{line, severity, message}` entries.
//! - Custom rules run in the same validator pass as built-in rules; no ordering guarantee.

use super::report::{Severity, Violation};
use super::rule::ValidationRule;
use std::path::Path;

/// A custom Lua-based validation rule (stored as a pattern + message).
pub struct LuaPatternRule {
    /// Id str.
    pub id_str: String,
    /// Desc.
    pub desc: String,
    /// Search pattern string.
    pub pattern: String,
    /// Log message text.
    pub message: String,
    /// Sev.
    pub sev: Severity,
    /// Invert.
    pub invert: bool,
}

impl LuaPatternRule {
    /// Create a new `LuaPatternRule` with the given id, pattern string, violation message, and severity.
    pub fn new(id: impl Into<String>, pattern: impl Into<String>, message: impl Into<String>, severity: Severity) -> Self {
        Self {
            id_str: id.into(),
            desc: String::new(),
            pattern: pattern.into(),
            message: message.into(),
            sev: severity,
            invert: false,
        }
    }

    /// If invert is true, violation triggers when pattern is NOT found (required pattern).
    pub fn set_invert(&mut self, invert: bool) {
        self.invert = invert;
    }
}

impl ValidationRule for LuaPatternRule {
    fn id(&self) -> &str { &self.id_str }
    fn description(&self) -> &str { &self.desc }
    fn severity(&self) -> Severity { self.sev }

    fn validate(&self, path: &Path, content: &str) -> Vec<Violation> {
        let mut violations = Vec::new();

        if self.invert {
            // Required pattern: violation if NOT found anywhere
            if !content.contains(&self.pattern) {
                violations.push(
                    Violation::new(&self.id_str, self.sev, path.to_path_buf(), &self.message)
                );
            }
        } else {
            // Forbidden pattern: violation on each line containing it
            for (line_num, line) in content.lines().enumerate() {
                if line.contains(&self.pattern) {
                    violations.push(
                        Violation::new(&self.id_str, self.sev, path.to_path_buf(), &self.message)
                            .with_line(line_num + 1)
                    );
                }
            }
        }

        violations
    }
}
