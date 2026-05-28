//! Animated cursor: frame sequences with per-frame timing and pulse scale effects.
//!
//! - `AnimatedCursor` holds a `Vec<CustomCursor>` of frames and an index.
//! - `PulseConfig` drives a sine-based scale animation independent of frame advance.
//! - Frame advance is time-driven; `duration_ms` per frame is set at construction.
//! - Used by `CursorState::Animated` and updated each tick in the cursor manager.

use super::custom_cursor::CustomCursor;

/// Configuration for pulsing scale animation.
#[derive(Debug, Clone)]
pub struct PulseConfig {
    /// Minimum scale factor for the animation.
    pub min_scale: f32,
    /// Maximum scale factor for the animation.
    pub max_scale: f32,
    /// Animation speed in units per second.
    pub speed: f32,
}

impl Default for PulseConfig {
    fn default() -> Self {
        Self { min_scale: 0.8, max_scale: 1.2, speed: 2.0 }
    }
}

/// A single frame in an animated cursor.
#[derive(Debug, Clone)]
pub struct CursorFrame {
    /// Cursor image pixel data.
    pub image: CustomCursor,
    /// Frame display duration in milliseconds.
    pub duration_ms: u32,
}

/// An animated cursor cycling through frames.
#[derive(Debug, Clone)]
pub struct AnimatedCursor {
    frames: Vec<CursorFrame>,
    current: usize,
    timer_ms: f32,
    looping: bool,
    pulse: Option<PulseConfig>,
    pulse_phase: f32,
}

impl AnimatedCursor {
    /// Create a new animated cursor; `looping` controls whether playback wraps.
    pub fn new(looping: bool) -> Self {
        Self {
            frames: Vec::new(),
            current: 0,
            timer_ms: 0.0,
            looping,
            pulse: None,
            pulse_phase: 0.0,
        }
    }

    /// Add a frame to the animation with the given display duration in milliseconds.
    pub fn add_frame(&mut self, image: CustomCursor, duration_ms: u32) {
        self.frames.push(CursorFrame { image, duration_ms });
    }

    /// Advance the animation by `dt` seconds, updating the current frame and pulse phase.
    pub fn update(&mut self, dt: f32) {
        if self.frames.is_empty() {
            return;
        }
        let dt_ms = dt * 1000.0;
        self.timer_ms += dt_ms;

        let frame_dur = self.frames[self.current].duration_ms as f32;
        while self.timer_ms >= frame_dur && frame_dur > 0.0 {
            self.timer_ms -= frame_dur;
            self.current += 1;
            if self.current >= self.frames.len() {
                if self.looping {
                    self.current = 0;
                } else {
                    self.current = self.frames.len() - 1;
                    self.timer_ms = 0.0;
                    break;
                }
            }
        }

        if let Some(ref pulse) = self.pulse {
            self.pulse_phase += dt * pulse.speed;
            if self.pulse_phase > std::f32::consts::TAU {
                self.pulse_phase -= std::f32::consts::TAU;
            }
        }
    }

    /// Return the currently displayed frame, or `None` if there are no frames.
    pub fn current_frame(&self) -> Option<&CursorFrame> {
        self.frames.get(self.current)
    }

    /// Return the current scale multiplier driven by the pulse animation (1.0 when no pulse).
    pub fn current_scale(&self) -> f32 {
        match &self.pulse {
            Some(p) => {
                let t = (self.pulse_phase.sin() + 1.0) * 0.5;
                p.min_scale + t * (p.max_scale - p.min_scale)
            }
            None => 1.0,
        }
    }

    /// Configure or clear the pulse scale animation applied on top of frame playback.
    pub fn set_pulse(&mut self, config: Option<PulseConfig>) {
        self.pulse = config;
        self.pulse_phase = 0.0;
    }

    /// Reset playback to frame 0 and clear timer and pulse phase.
    pub fn reset(&mut self) {
        self.current = 0;
        self.timer_ms = 0.0;
        self.pulse_phase = 0.0;
    }

    /// Return the total number of frames in the animation.
    pub fn frame_count(&self) -> usize {
        self.frames.len()
    }

    /// Return the zero-based index of the currently active frame.
    pub fn current_index(&self) -> usize {
        self.current
    }

    /// Return `true` if the animation restarts from frame 0 after the last frame.
    pub fn is_looping(&self) -> bool {
        self.looping
    }
}
