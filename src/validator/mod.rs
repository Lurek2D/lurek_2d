//! This module delivers the validation surface for script content, assets, imports, and API usage. `validator/mod` is the validator module index, declaring `api_check`, `asset_check`, `config`, `engine`, `import_check`, and 5 more so agents can identify which files own each feature slice before opening implementation code.
//! It combines built-in and custom rule paths into one extensible quality-check pipeline. `src/validator/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `config::ValidatorConfig`, `engine::ValidationEngine`, `report::{Severity, ValidationReport, Violation}`, `rule::ValidationRule` centralized for the validator subsystem.

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
