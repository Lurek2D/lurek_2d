//! This module delivers the motion interpolation stack used for scripted and systemic animation. `tween/mod` is the tween module index, declaring `engine`, `handle`, `interpolator`, `spring`, `state`, and 1 more so agents can identify which files own each feature slice before opening implementation code.
//! It combines timed easing, spring dynamics, and composition primitives in one cohesive surface. `src/tween/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `engine::TweenEngine`, `handle::{LuaTween, LuaTweenParallel, LuaTweenSequence, ParallelEntry, SequenceStep}`, `interpolator::{Tween, TweenValue}`, `spring::{SpringAxis, SpringSystem}`, and 2 more centralized for the tween subsystem.

/// Core tween engine that ticks and manages active tween instances.
pub mod engine;
/// Lua-visible tween handles: single, sequence, and parallel combinators.
pub mod handle;
/// Multi-channel tween interpolator with easing and clock control.
pub mod interpolator;
/// Spring-based axis interpolation for physics-style easing.
pub mod spring;
/// Tween state, easing resolution, and built-in easing name registry.
pub mod state;
pub use engine::TweenEngine;
pub use handle::{LuaTween, LuaTweenParallel, LuaTweenSequence, ParallelEntry, SequenceStep};
pub use interpolator::{Tween, TweenValue};
pub use spring::{SpringAxis, SpringSystem};
pub use state::{builtin_easing_names, TweenState};
/// Sequential tween chain with labels, loop support, and fluent playback controls.
pub mod chain;
pub use chain::{ChainEvent, ChainStep, TweenChain};
