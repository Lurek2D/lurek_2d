//! This module delivers the runtime time backbone for clocks, accumulation, sleeping, and scheduling.
//! It keeps frame progression measurable and controllable across gameplay and engine services.
//! It unifies timing primitives so deferred logic behaves consistently under load.

/// Exposes the accumulator module.
pub(crate) mod accumulator;
/// Game clock with delta time, elapsed time, and time-scale support.
pub mod clock;
/// Tick-based scheduler for delayed, repeating, and one-shot callbacks.
pub mod scheduler;
/// Thread-sleep utilities with platform-appropriate precision.
pub mod sleep;
pub(crate) use accumulator::accumulate_scaled_micros;
pub use clock::Clock;
pub use scheduler::Scheduler;
pub use sleep::sleep;
