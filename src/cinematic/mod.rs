//! Cinematic engine module — pure Rust logic, no Lua dependencies. `cinematic/mod` is the cinematic module index, declaring `cinematic_legacy`, `timeline` so agents can identify which files own each feature slice before opening implementation code.
//! Legacy Cut-based timeline (Cinematic struct) for backward compatibility. `src/cinematic/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `cinematic_legacy::{Cinematic, Cut}`, `timeline::{CinematicClip, CinematicTimeline, ClipType, TimelineState, Track}` centralized for the cinematic subsystem.

/// Legacy cut-based timeline (single-track, descriptive cuts).
pub mod cinematic_legacy;
/// Modern multi-track timeline system.
pub mod timeline;

// Re-export legacy API for backward compat
pub use cinematic_legacy::{Cinematic, Cut};
pub use timeline::{CinematicClip, CinematicTimeline, ClipType, TimelineState, Track};
