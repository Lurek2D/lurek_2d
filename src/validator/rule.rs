//! This file owns `ValidationRule`, the trait contract every validator check implements against file content.
//! It defines the required rule identity, human description, default severity, and validation entrypoint shape.
//! Open this file when rule plugin boundaries change; concrete checks, configs, and reports live in siblings.

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
