//! This file provides the rule trait contract that all validator checks implement. `validator/rule` delivers the rule implementation for the validator subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.

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
