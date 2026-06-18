//! This file owns `TimeAnchor`, the monotonic clock wrapper used to measure elapsed devtools time in seconds.
//! It stores one `Instant` and exposes lightweight construction plus elapsed reads for loggers and profilers.
//! Open this file when shared elapsed-time semantics change; higher-level history and capture logic lives in siblings.

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
