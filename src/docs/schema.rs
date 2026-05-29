//! Provides the schema bridge that exposes shared validation contracts used by the docs pipeline.
//! Connects documentation tooling with canonical field and type rules defined in the schema crate.
//! Delivers one access point that keeps schema usage consistent across docs modules.

/// Re-export schema model types and helpers consumed by docs modules.
pub use lurek_schema::*;
