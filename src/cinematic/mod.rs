//! `src/cinematic/mod.rs` is the module index that exposes both the legacy cut API and the newer timeline system.
//! It reexports `Cinematic`, `Cut`, `CinematicTimeline`, `ClipType`, `Track`, and `TimelineState` in one surface.
//! No active playback state lives here; this file only declares child modules and defines public cinematic symbols.
//! Read this index when wiring sequence features, because it shows where legacy support ends and timeline playback begins.
//! Changes here reshape the cinematic boundary, since reexports decide what runtime code may import without deep paths.
//! This module keeps the simple legacy cut model separate from the multi-track timeline owner for newer cinematic flows.

/// Legacy cut-based timeline (single-track, descriptive cuts).
pub mod cinematic_legacy;
/// Modern multi-track timeline system.
pub mod timeline;

// Re-export legacy API for backward compat
pub use cinematic_legacy::{Cinematic, Cut};
pub use timeline::{CinematicClip, CinematicTimeline, ClipType, TimelineState, Track};
