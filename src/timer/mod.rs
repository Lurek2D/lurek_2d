//! Frame timing, scheduled events, and sleep utilities.
//!
//! This module is part of Lurek2D's **Core Runtime** tier and provides two complementary
//! types plus a convenience sleep helper:
//!
//! - [`Clock`]: per-frame delta-time tracking, rolling FPS measurement, total elapsed
//!   time, and frame counting. Called once per frame by `App` at the top of the game loop.
//! - [`Scheduler`]: one-shot (`after`) and repeating (`every`) timed events with
//!   individual pause/resume, cancellation handles, named events, and a global
//!   time-scale multiplier.
//! - [`sleep`]: suspends the calling OS thread — intended **only** for worker VM threads;
//!   calling from the main VM stalls the engine frame loop.
//!
//! ## Threading constraint
//! Both `Clock` and `Scheduler` live on the main thread inside `SharedState`.
//! Background threads should use `lurek.thread.Channel` for timed coordination.
//!
//! All public items are documented. Lua bridge: `src/lua_api/timer_api.rs`.

/// Frame-based clock providing delta time, total time, and FPS.
pub mod clock;
/// Scheduled event manager for delayed and repeating timed callbacks.
pub mod scheduler;

pub use clock::Clock;
pub use scheduler::Scheduler;

/// Suspends the current thread for the given number of seconds.
///
/// Values ≤ 0 are ignored. This is a simple convenience wrapper around
/// [`std::thread::sleep`].
///
/// # Parameters
/// - `seconds` — `f64`.
pub fn sleep(seconds: f64) {
    if seconds > 0.0 {
        std::thread::sleep(std::time::Duration::from_secs_f64(seconds));
    }
}
