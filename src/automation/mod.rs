//! Defines the automation module boundary for deterministic input replay and scripted verification flows. `automation/mod` is the automation module index, declaring `script`, `simulator`, `step` so agents can identify which files own each feature slice before opening implementation code.
//! Groups script parsing, playback simulation, and typed step contracts under one coherent runtime surface. `src/automation/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `script::Script`, `simulator::Simulator`, `step::{Action, Step}` centralized for the automation subsystem.

/// `Script`: ordered, time-sorted step sequences with TOML parsing and repeat expansion.
pub mod script;
/// `Simulator`: drives script playback, macro inlining, condition evaluation, and visual asserts.
pub mod simulator;
/// `Action` and `Step` types: timed input event descriptors for automation scripts.
pub mod step;
pub use script::Script;
pub use simulator::Simulator;
pub use step::{Action, Step};
