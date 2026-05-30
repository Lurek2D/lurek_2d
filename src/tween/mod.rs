//! This module delivers the motion interpolation stack used for scripted and systemic animation.
//! It combines timed easing, spring dynamics, and composition primitives in one cohesive surface.
//! It gives the runtime one predictable path for updating all active tween workflows.

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
pub use state::{builtin_easing_names, TweenState};
pub use interpolator::{Tween, TweenValue};
pub use spring::{SpringAxis, SpringSystem};
/// Sequential tween chain with labels, loop support, and fluent playback controls.
pub mod chain;
pub use chain::{ChainEvent, ChainStep, TweenChain};
