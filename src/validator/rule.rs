//! This file provides the rule trait contract that all validator checks implement.
//! It defines the required identity, severity, and check interface for rule execution.
//! It keeps rules composable across built-in logic and externally supplied adapters.

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
