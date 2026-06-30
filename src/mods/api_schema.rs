//! Compatibility reexports for mod schema types backed by the shared `lurek_schema` crate.
//! Keep this file as the mod-facing import boundary while docs, mods, and validator converge on one schema model.
//! These reexports preserve existing module paths so internal callers can migrate without a flag day.
//! Runtime validation logic still lives in `api_registry.rs`; this file only defines the shared contract types.

pub use lurek_schema::{AssetRequirement, FieldDef, FieldType, MethodDef};
