//! `src/docs/error.rs` owns typed errors shared by catalog, export, schema, and quality-report workflows.
//! It keeps failure reasons stable so tooling can distinguish duplicate entries, sandbox violations, size limits, and rule failures.
//! Cross-cutting docs pipeline operations depend on these errors instead of ad hoc strings, while file I/O and JSON details are normalized here.
//! Read this file when documentation pipeline failure semantics or caller-facing diagnostics need to change.

/// Shared result type for docs subsystem operations that can fail with structured diagnostics.
pub type DocsResult<T> = Result<T, DocsError>;

/// Typed error raised by docs catalog, export, validation, and quality workflows.
#[derive(Debug, Clone, thiserror::Error, PartialEq, Eq)]
pub enum DocsError {
    /// A catalog mutation attempted to introduce a duplicate qualified name in checked mode.
    #[error("duplicate docs entry for qualified name `{qualified_name}`")]
    DuplicateQualifiedName { qualified_name: String },
    /// An export path resolved outside the configured safe root.
    #[error("docs export path `{path}` is outside safe root `{root}`")]
    PathDenied { path: String, root: String },
    /// A target file already exists and overwrite mode was disabled.
    #[error("docs export target already exists: `{path}`")]
    OverwriteDenied { path: String },
    /// An export payload exceeded the configured byte budget.
    #[error("docs export `{context}` produced {bytes} bytes, exceeding limit {max_bytes}")]
    OutputTooLarge {
        context: &'static str,
        bytes: usize,
        max_bytes: usize,
    },
    /// A path could not be normalized into a file target.
    #[error("invalid docs export path `{path}`")]
    InvalidPath { path: String },
    /// A file target used an unsupported extension for the export format.
    #[error("docs export path `{path}` must use `{expected_extension}`")]
    InvalidExtension {
        path: String,
        expected_extension: String,
    },
    /// A schema-aware validation or conversion step failed.
    #[error("docs schema mismatch for `{qualified_name}`: {message}")]
    SchemaMismatch {
        qualified_name: String,
        message: String,
    },
    /// A quality policy rule failed in strict callers.
    #[error("docs quality rule `{rule_id}` failed{qualified_name_suffix}: {message}")]
    QualityFailure {
        rule_id: String,
        qualified_name_suffix: String,
        message: String,
    },
    /// File system I/O failed while reading or writing a docs artifact.
    #[error("docs I/O error for `{path}`: {message}")]
    Io { path: String, message: String },
    /// JSON serialization failed while preparing a docs payload.
    #[error("docs JSON error for `{context}`: {message}")]
    Json {
        context: &'static str,
        message: String,
    },
}

impl DocsError {
    /// Build a strict quality failure error with an optional qualified-name suffix.
    pub fn quality_failure(
        rule_id: impl Into<String>,
        qualified_name: Option<&str>,
        message: impl Into<String>,
    ) -> Self {
        let suffix = qualified_name
            .map(|name| format!(" for `{name}`"))
            .unwrap_or_default();
        Self::QualityFailure {
            rule_id: rule_id.into(),
            qualified_name_suffix: suffix,
            message: message.into(),
        }
    }
}
