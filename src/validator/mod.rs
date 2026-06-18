//! This module re-exports the validator subsystem surface for rules, reports, config, execution, and extensions.
//! It keeps navigation explicit by mapping which sibling files own API checks, asset checks, imports, and walkers.
//! Public exports here route callers toward `ValidationEngine` for orchestration and `ValidatorConfig` for policy.
//! `report.rs` owns severities and violation records, while `rule.rs` defines the trait every checker implements.
//! `rules_lua.rs` and `rules_toml.rs` extend the subsystem with data-defined checks without engine call-site churn.
//! Change this file when the validator symbol map moves; change siblings when scan behavior or rule logic changes.

/// Mod API compliance checker against registered type schemas and field contracts.
pub mod api_check;
/// Asset existence checker: validates images, sounds, and fonts referenced in scripts.
pub mod asset_check;
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
pub use report::{Severity, ValidationReport, Violation};
pub use rule::ValidationRule;
