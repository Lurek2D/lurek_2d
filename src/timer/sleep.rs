//! This file provides the blocking sleep primitive used by timer-facing runtime code. `timer/sleep` delivers the sleep implementation for the timer subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.

/// Block the calling thread for `seconds` and return nothing; no-op for values <= 0.0.
pub fn sleep(seconds: f64) {
    if seconds > 0.0 {
        std::thread::sleep(std::time::Duration::from_secs_f64(seconds));
    }
}
