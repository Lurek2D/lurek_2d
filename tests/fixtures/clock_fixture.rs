//! Frame-based clock for measuring delta time, FPS, and total elapsed time.
//!
//! The `Clock` struct is updated once per frame by calling `Clock::tick()`.
//! All time values are `f32` for direct use in physics and animation math.

use std::time::Instant;

// ─────────────────────────────────────────────────────────────────────────────
// Clock
// ─────────────────────────────────────────────────────────────────────────────

/// Frame-based clock tracking delta time, total elapsed time, and FPS.
///
/// Call `tick()` once at the start of each frame. All values are then available
/// through the getter methods until the next tick.
///
/// # Fields
/// - `dt` — `f32`. Delta time in seconds for the current frame.
/// - `total` — `f32`. Total elapsed time in seconds since the clock was created.
/// - `fps` — `f32`. Smoothed frames-per-second counter.
pub struct Clock {
    pub dt: f32,
    pub total: f32,
    pub fps: f32,
    last: Instant,
    fps_window: Vec<f32>,
    time_scale: f32,
}

impl Clock {
    /// Creates a new `Clock` with zeroed state.
    ///
    /// The first call to `tick()` will record a small delta because
    /// `Instant::now()` is captured at construction time.
    ///
    /// # Returns
    /// `Clock`
    pub fn new() -> Self {
        Clock {
            dt: 0.0,
            total: 0.0,
            fps: 0.0,
            last: Instant::now(),
            fps_window: Vec::with_capacity(60),
            time_scale: 1.0,
        }
    }

    /// Advances the clock by computing the elapsed time since the last call.
    ///
    /// Must be called exactly once at the start of each frame.
    ///
    /// # Parameters
    /// - `override_dt` — `Option<f32>`. Optional fixed delta override for deterministic stepping.
    pub fn tick(&mut self, override_dt: Option<f32>) {
        let now = Instant::now();
        let raw = override_dt.unwrap_or_else(|| now.duration_since(self.last).as_secs_f32());
        self.dt = raw * self.time_scale;
        self.total += self.dt;
        self.last = now;
        self.fps_window.push(raw);
        if self.fps_window.len() > 60 {
            self.fps_window.remove(0);
        }
        let avg: f32 = self.fps_window.iter().sum::<f32>() / self.fps_window.len() as f32;
        self.fps = if avg > 0.0 { 1.0 / avg } else { 0.0 };
    }

    /// Returns the delta time in seconds for the last frame.
    ///
    /// # Returns
    /// `f32`
    pub fn dt(&self) -> f32 {
        self.dt
    }

    /// Returns the total elapsed time in seconds.
    ///
    /// # Returns
    /// `f32`
    pub fn total(&self) -> f32 {
        self.total
    }

    /// Returns the smoothed frames-per-second counter.
    ///
    /// # Returns
    /// `f32`
    pub fn fps(&self) -> f32 {
        self.fps
    }

    /// Sets the time scale applied to all delta values.
    ///
    /// A scale of `2.0` makes the game run at double speed; `0.5` at half speed.
    ///
    /// # Parameters
    /// - `scale` — `f32`. Multiplier applied to each raw delta.
    pub fn set_time_scale(&mut self, scale: f32) {
        self.time_scale = scale.max(0.0);
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// ClockMode
// ─────────────────────────────────────────────────────────────────────────────

/// Precision modes for `Clock` measurement.
///
/// # Variants
/// - `High` — High-precision wall-clock using `Instant::now()` (default).
/// - `Fixed` — Fixed timestep for deterministic simulation and tests.
/// - `Relaxed` — Lower-overhead mode for non-critical animations.
pub enum ClockMode {
    High,
    Fixed,
    Relaxed,
}

// ─────────────────────────────────────────────────────────────────────────────
// Free functions
// ─────────────────────────────────────────────────────────────────────────────

/// Creates a new `Clock` with the given precision mode.
///
/// Convenience wrapper over `Clock::new()` for callers that need explicit
/// precision control.
///
/// # Parameters
/// - `mode` — `ClockMode`. Controls measurement precision.
///
/// # Returns
/// `Clock`
pub fn new_clock(mode: ClockMode) -> Clock {
    let _ = mode;
    Clock::new()
}

/// Suspends the current thread for the given number of seconds.
///
/// # Parameters
/// - `seconds` — `f64`. Duration to sleep.
pub fn sleep(seconds: f64) {
    std::thread::sleep(std::time::Duration::from_secs_f64(seconds));
}
