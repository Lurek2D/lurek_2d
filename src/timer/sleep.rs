//! This file provides the blocking sleep primitive used by timer-facing runtime code.
//! It treats non-positive durations as no-op calls to preserve predictable behavior.
//! It delegates to standard thread sleeping without busy waiting or spin loops.

/// Block the calling thread for `seconds` and return nothing; no-op for values <= 0.0.
pub fn sleep(seconds: f64) {
    if seconds > 0.0 {
        std::thread::sleep(std::time::Duration::from_secs_f64(seconds));
    }
}
