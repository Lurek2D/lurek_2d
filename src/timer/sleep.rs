//! Thread-blocking sleep helper used by `lurek.timer.sleep`.

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
