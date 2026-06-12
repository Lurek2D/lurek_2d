//! File: src/cinematic/mod.rs
//!
//! Cinematic engine module — pure Rust logic, no Lua dependencies.
//! Provides two APIs:
//! - Legacy Cut-based timeline (Cinematic struct) for backward compatibility
//! - Modern multi-track timeline (CinematicTimeline) with Tween/Camera/Audio/Signal tracks
//! Lua bindings live in `src/lua_api/cinematic_api.rs`.

/// Legacy cut-based timeline (single-track, descriptive cuts).
pub mod cinematic_legacy;
/// Modern multi-track timeline system.
pub mod timeline;

// Re-export legacy API for backward compat
pub use cinematic_legacy::{Cinematic, Cut};
pub use timeline::{CinematicClip, CinematicTimeline, ClipType, TimelineState, Track};
