//! `src/timer/sleep.rs` owns the blocking sleep helper used when runtime code needs wall-clock delay on the current thread.
//! It intentionally stays minimal: non-positive durations are ignored, and positive values forward to `std::thread::sleep`.
//! Read this file when blocking-delay semantics, no-op guards, or platform-facing sleep behavior need to change.

/// Block the calling thread for `seconds` and return nothing; no-op for values <= 0.0.
pub fn sleep(seconds: f64) {
    if seconds > 0.0 {
        std::thread::sleep(std::time::Duration::from_secs_f64(seconds));
    }
}
