//! `src/timer/mod.rs` is the module index that exposes clocks, scheduling, sleep helpers, and accumulation support.
//! It reexports `Clock`, `Scheduler`, and `sleep` so runtime code and Lua bindings consume one stable timing surface.
//! No live timer state lives here; this file only declares child modules and chooses which timing symbols become public.
//! Read this index when wiring frame progression, because it shows where clock metrics, delayed work, and sleeps are split.
//! Changes here reshape the timing boundary, since reexports decide what engine code may import without deep module paths.
//! This module keeps accumulation internals private while exposing the timing tools other engine systems are meant to use.

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
