//! Implements a monotonic timing anchor used to compute elapsed seconds on demand. `devtools/time_anchor` delivers the time anchor implementation for the devtools subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.

use std::time::Instant;
#[derive(Debug, Clone)]
/// Hold a monotonic start instant used to measure elapsed seconds.
pub struct TimeAnchor {
    /// Store the reference instant from which elapsed time is computed.
    start: Instant,
}
impl TimeAnchor {
    /// Create a new anchor from the current instant and return it.
    pub fn new() -> Self {
        Self {
            start: Instant::now(),
        }
    }
    /// Return elapsed time in seconds since this anchor was created.
    pub fn elapsed_seconds(&self) -> f64 {
        self.start.elapsed().as_secs_f64()
    }
}
/// Provide a default anchor initialized at construction time.
impl Default for TimeAnchor {
    fn default() -> Self {
        Self::new()
    }
}
