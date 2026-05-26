//! Validation rule trait and standard built-in rule implementations.
//!
//! - `ValidationRule` trait: `fn check(path, content) -> Vec<Violation>`.
//! - All built-in rules implement this trait; Lua custom rules are adapter-wrapped.
//! - Rules are stateless and `Send + Sync` so they can be used from any thread.
//! - The engine constructs the rule set once from config and reuses it across files.
use super::report::{Severity, Violation};
use std::path::Path;

/// A validation rule that checks a file or content.
pub trait ValidationRule: Send + Sync {
    /// Unique rule identifier.
    fn id(&self) -> &str;

    /// Human-readable description.
    fn description(&self) -> &str;

    /// Default severity for violations.
    fn severity(&self) -> Severity;

    /// Validate a file, returning any violations found.
    fn validate(&self, path: &Path, content: &str) -> Vec<Violation>;
}
