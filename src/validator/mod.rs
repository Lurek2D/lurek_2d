//! Asset and content validation engine.
//!
//! - Asset existence checking (images, sounds, fonts referenced in scripts).
//! - Lua import resolution validation.
//! - Mod API compliance checking.
//! - Custom validation rules from Lua callbacks or TOML rule files.
//! - Parallel execution across file trees.
//! - Structured violation reports with severity and suggestions.

/// Asset existence checker: validates images, sounds, and fonts referenced in scripts.
pub mod asset_check;
/// Mod API compliance checker against registered type schemas and field contracts.
pub mod api_check;
/// Validator configuration: search paths, rule sets, and file extension filters.
pub mod config;
/// Validation engine orchestrating rule execution across file trees.
pub mod engine;
/// Lua import resolver: validates that all require() call targets exist on disk.
pub mod import_check;
/// Parallel file-tree runner distributing validation rules across worker threads.
pub mod parallel;
/// Structured violation report with severity level, file path, and message.
pub mod report;
/// Validation rule trait and standard built-in rule implementations.
pub mod rule;
/// Lua-defined custom validation rules registered via pattern callbacks.
pub mod rules_lua;
/// TOML-file-defined validation rules loaded from disk at engine startup.
pub mod rules_toml;

pub use config::ValidatorConfig;
pub use engine::ValidationEngine;
pub use report::{ValidationReport, Violation, Severity};
pub use rule::ValidationRule;
