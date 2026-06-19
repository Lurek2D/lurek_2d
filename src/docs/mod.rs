//! `src/docs/mod.rs` is the module index for documentation entries, catalogs, exports, reports, and schema reexports.
//! It declares storage, record, export, validation, and schema files while keeping docs pipeline ownership explicit.
//! This file reexports the main types and functions so tooling can consume the docs subsystem from one stable boundary.
//! No catalog state or export logic lives here; it only defines visibility and the public module surface.
//! Read this index first when tracing docs flow, because it shows where entry models end and output stages begin.
//! Changes here affect reachability and API shape, not schema rules, quality scoring, or JSON export behavior.

/// Expose catalog storage and query operations for documentation entries.
pub mod catalog;
/// Expose normalized entry types for parameters, returns, and metadata.
pub mod entry;
/// Expose shared typed errors used across docs catalog, export, and reporting stages.
pub mod error;
/// Expose JSON export builders for completion, hover, and signature payloads.
pub mod export;
/// Expose quality and validation report models for doc coverage analysis.
pub mod report;
/// Re-export shared schema model types used by documentation tooling.
pub mod schema;
/// Re-export the catalog type for callers that aggregate documentation records.
pub use catalog::{Catalog, SearchOptions};
/// Re-export entry model types shared across docs tooling modules.
pub use entry::{DocEntry, ParamInfo, ReturnInfo};
/// Re-export shared typed docs errors for callers that need structured failure handling.
pub use error::{DocsError, DocsResult};
/// Re-export export functions for writing documentation JSON artifacts.
pub use export::{
    export_all, export_all_with_options, export_completions, export_completions_with_options,
    export_hover, export_hover_with_options, export_signatures, export_signatures_with_options,
    DocsExportFileReport, DocsExportOptions, DocsExportReport, DocsLimits,
};
/// Re-export quality and validation report helpers for documentation checks.
pub use report::{
    quality_grade, quality_score, quality_score_with_policy, DocsIssue, DocsIssueKind,
    IssueSeverity, QualityPolicy, QualityReport, ValidationReport,
};
/// Re-export schema types so callers can validate field contracts consistently.
pub use schema::{FieldRule, FieldType, Schema, SchemaError, SchemaResult};
