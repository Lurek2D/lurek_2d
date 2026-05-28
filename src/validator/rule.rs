//! Validation rule trait and standard built-in rule implementations.

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
