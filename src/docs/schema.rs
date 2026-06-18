//! `src/docs/schema.rs` reexports shared `lurek_schema` contracts used by the documentation pipeline and validators.
//! It owns the docs-facing schema boundary so catalog, export, and report code depend on one stable import location.
//! Read it when schema types, validator wiring, or docs-tool contracts need to change without touching downstream modules.

/// Re-export schema model types and helpers consumed by docs modules.
pub use lurek_schema::*;
