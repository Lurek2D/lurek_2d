//! `src/automation/mod.rs` is the module index that exposes script parsing, playback simulation, and automation steps.
//! It reexports `Script`, `Simulator`, `Action`, and `Step` so callers consume one stable automation surface.
//! No active script or playback state lives here; this file only declares child modules and chooses public symbols.
//! Read this index when wiring replay or verification flows, because it shows where script data ends and execution begins.
//! Changes here reshape the automation boundary, since reexports decide what runtime code may import without deep paths.
//! This module keeps step contracts, TOML loading, and playback logic separated for clearer ownership and testability.

/// `Script`: ordered, time-sorted step sequences with TOML parsing and repeat expansion.
pub mod script;
/// `Simulator`: drives script playback, macro inlining, condition evaluation, and visual asserts.
pub mod simulator;
/// `Action` and `Step` types: timed input event descriptors for automation scripts.
pub mod step;
pub use script::Script;
pub use simulator::Simulator;
pub use step::{Action, Step};
