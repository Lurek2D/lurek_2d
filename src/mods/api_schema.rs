//! Owns the mods API schema implementation for the mods subsystem and keeps related runtime rules local here.
//! Keeps mod metadata, schema state, and extension-facing boundaries so helpers stay close to invariants this file updates.
//! Defines how mods API schema data is validated, transformed, or stored before neighboring systems consume it.

pub use lurek_schema::{AssetRequirement, FieldDef, FieldType, MethodDef};
