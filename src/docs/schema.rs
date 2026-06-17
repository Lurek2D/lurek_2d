//! Provides the schema bridge that exposes shared validation contracts used by the docs pipeline. `docs/schema` delivers the schema implementation for the docs subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.

/// Re-export schema model types and helpers consumed by docs modules.
pub use lurek_schema::*;
