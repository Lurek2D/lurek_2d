//! Defines the automation module boundary for deterministic input replay and scripted verification flows.
//! Groups script parsing, playback simulation, and typed step contracts under one coherent runtime surface.
//! Serves as the composition entry for test-like interaction automation inside engine execution.

/// `Script`: ordered, time-sorted step sequences with TOML parsing and repeat expansion.
pub mod script;
/// `Simulator`: drives script playback, macro inlining, condition evaluation, and visual asserts.
pub mod simulator;
/// `Action` and `Step` types: timed input event descriptors for automation scripts.
pub mod step;
pub use script::Script;
pub use simulator::Simulator;
pub use step::{Action, Step};
