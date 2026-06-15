//! Legacy compatibility shim for director-facing types.
//! Re-exports the active AI director API from `crate::ai::director` under
//! `crate::director`.

pub use crate::ai::director::{AIDirector, DirectorConfig, DirectorPhase};
