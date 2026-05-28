//! Smooth value interpolation with configurable easing curves.
//!
//! - Sequence and parallel combinators for complex multi-step animations.
//! - Spring-based physics tweening for natural motion.
//! - Shared tween engine driving all active tweens each frame.
//! - Multi-channel interpolator driven by easing functions over a fixed duration.

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
