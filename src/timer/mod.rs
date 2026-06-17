//! This module delivers the runtime time backbone for clocks, accumulation, sleeping, and scheduling. `timer/mod` is the timer module index, declaring `clock`, `scheduler`, `sleep` so agents can identify which files own each feature slice before opening implementation code.
//! It keeps frame progression measurable and controllable across gameplay and engine services. `src/timer/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `clock::Clock`, `scheduler::Scheduler`, `sleep::sleep` centralized for the timer subsystem.

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
