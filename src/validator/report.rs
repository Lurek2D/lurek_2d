//! Structured violation report: aggregates, formats, and summarises validation results.
//!
//! - `Violation` carries file path, line number, `Severity`, rule name, and message.
//! - `ValidationReport` holds `Vec<Violation>` and provides filter/sort helpers.
//! - `Severity` enum: `Info`, `Warning`, `Error` — ordered by increasing severity.
//! - `ValidationReport::display_summary()` prints a compact human-readable table.
use std::path::PathBuf;

/// Severity level of a validation violation.
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub enum Severity {
    Hint,
    Warning,
    Error,
    Critical,
}

impl Severity {
    /// Parse a `Severity` level from a string; unknown values map to `Warning`.
    pub fn from_str(s: &str) -> Self {
        match s.to_lowercase().as_str() {
            "hint" | "info" => Self::Hint,
            "warning" | "warn" => Self::Warning,
            "error" | "err" => Self::Error,
            "critical" | "fatal" => Self::Critical,
            _ => Self::Warning,
        }
    }

    /// Return the lowercase canonical string name of this severity level.
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Hint => "hint",
            Self::Warning => "warning",
            Self::Error => "error",
            Self::Critical => "critical",
        }
    }
}

/// A single validation violation.
#[derive(Debug, Clone)]
pub struct Violation {
    /// Rule id.
    pub rule_id: String,
    /// Severity.
    pub severity: Severity,
    /// File.
    pub file: PathBuf,
    /// Line.
    pub line: Option<usize>,
    /// Column.
    pub column: Option<usize>,
    /// Log message text.
    pub message: String,
    /// Suggestion.
    pub suggestion: Option<String>,
}

impl Violation {
    /// Create a new `Violation` for the given rule, severity, file, and message.
    pub fn new(rule_id: impl Into<String>, severity: Severity, file: PathBuf, message: impl Into<String>) -> Self {
        Self {
            rule_id: rule_id.into(),
            severity,
            file,
            line: None,
            column: None,
            message: message.into(),
            suggestion: None,
        }
    }

    /// Attach a source line number to this violation.
    pub fn with_line(mut self, line: usize) -> Self {
        self.line = Some(line);
        self
    }

    /// Attach a source column number to this violation.
    pub fn with_column(mut self, col: usize) -> Self {
        self.column = Some(col);
        self
    }

    /// Attach a suggested fix message to this violation.
    pub fn with_suggestion(mut self, suggestion: impl Into<String>) -> Self {
        self.suggestion = Some(suggestion.into());
        self
    }
}

/// Complete validation report.
#[derive(Debug, Clone)]
pub struct ValidationReport {
    /// Violations.
    pub violations: Vec<Violation>,
    /// Files checked.
    pub files_checked: usize,
    /// Frame display duration in milliseconds.
    pub duration_ms: u64,
}

impl ValidationReport {
    /// Create an empty report with no violations and zero counters.
    pub fn empty() -> Self {
        Self { violations: Vec::new(), files_checked: 0, duration_ms: 0 }
    }

    /// Return the count of violations at `Error` severity or higher.
    pub fn error_count(&self) -> usize {
        self.violations.iter().filter(|v| v.severity >= Severity::Error).count()
    }

    /// Return the count of violations at exactly `Warning` severity.
    pub fn warning_count(&self) -> usize {
        self.violations.iter().filter(|v| v.severity == Severity::Warning).count()
    }

    /// Return `true` if any violation is at `Error` or `Critical` severity.
    pub fn has_errors(&self) -> bool {
        self.violations.iter().any(|v| v.severity >= Severity::Error)
    }

    /// Return `true` if the report contains no violations at any severity.
    pub fn is_clean(&self) -> bool {
        self.violations.is_empty()
    }

    /// Return all violations that match the given severity level.
    pub fn by_severity(&self, sev: Severity) -> Vec<&Violation> {
        self.violations.iter().filter(|v| v.severity == sev).collect()
    }

    /// Return all violations that were raised against the given file path.
    pub fn by_file(&self, file: &std::path::Path) -> Vec<&Violation> {
        self.violations.iter().filter(|v| v.file == file).collect()
    }
}
