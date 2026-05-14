//! - Thread-blocking sleep utility for the timer subsystem.
//! - Clamps non-positive durations to a no-op, preventing panics from negative `Duration`.
//! - Delegates to `std::thread::sleep` with no spin-wait or busy-loop overhead.

/// Block the calling thread for `seconds` and return nothing; no-op for values <= 0.0.
pub fn sleep(seconds: f64) {
    if seconds > 0.0 {
        std::thread::sleep(std::time::Duration::from_secs_f64(seconds));
    }
}
