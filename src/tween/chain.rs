//! Tween chain — sequential and parallel tween composition for cinematic sequences.
//!
//! - `TweenChain` plays tweens one after another (or in parallel groups).
//! - Each step carries an optional label for event-based Lua callbacks.
//! - `tick(dt)` advances the chain and returns completed step labels.

use crate::math::easing;

/// A single step in a tween chain.
pub struct ChainStep {
    /// Optional label emitted when this step completes.
    pub label: Option<String>,
    /// Total duration of this step in seconds.
    pub duration: f64,
    /// Easing function name (matches `easing` module).
    pub easing: String,
    /// Start value.
    pub from: f64,
    /// End value.
    pub to: f64,
    /// Time elapsed within this step.
    elapsed: f64,
}

impl ChainStep {
    /// Create a new step.
    pub fn new(
        from: f64,
        to: f64,
        duration: f64,
        easing: &str,
        label: Option<String>,
    ) -> Self {
        Self {
            label,
            duration: duration.max(f64::EPSILON),
            easing: easing.to_string(),
            from,
            to,
            elapsed: 0.0,
        }
    }

    /// Current interpolated value for this step.
    pub fn value(&self) -> f64 {
        let t = (self.elapsed / self.duration).clamp(0.0, 1.0) as f32;
        let t_eased = easing::apply(&self.easing, t).unwrap_or(t) as f64;
        self.from + (self.to - self.from) * t_eased
    }

    /// True when this step has finished.
    pub fn is_done(&self) -> bool {
        self.elapsed >= self.duration
    }
}

/// Completion event emitted when a step finishes.
#[derive(Clone, Debug)]
pub struct ChainEvent {
    /// Zero-based index of the completed step.
    pub step: usize,
    /// Label attached to the step, if any.
    pub label: Option<String>,
    /// Final interpolated value.
    pub value: f64,
}

/// Sequential tween chain.
pub struct TweenChain {
    /// Ordered steps.
    steps: Vec<ChainStep>,
    /// Index of the currently active step.
    cursor: usize,
    /// Whether the chain loops back to the start on completion.
    looping: bool,
    /// Whether the chain has finished (non-looping only).
    finished: bool,
    /// Whether the chain is currently active.
    active: bool,
    /// Whether the active chain is paused.
    paused: bool,
    /// Completed loop iterations. Starts at 0 before first run.
    iteration: u32,
}

impl TweenChain {
    /// Create an empty non-looping chain.
    pub fn new() -> Self {
        Self {
            steps: Vec::new(),
            cursor: 0,
            looping: false,
            finished: false,
            active: true,
            paused: false,
            iteration: 1,
        }
    }

    /// Start playback from the beginning.
    pub fn start(&mut self) {
        self.reset();
        self.active = true;
        self.paused = false;
        self.iteration = 1;
    }

    /// Stop playback immediately.
    pub fn stop(&mut self) {
        self.active = false;
        self.paused = false;
    }

    /// Pause playback.
    pub fn pause(&mut self) {
        self.paused = true;
    }

    /// Resume playback.
    pub fn resume(&mut self) {
        self.paused = false;
    }

    /// Set whether the chain should restart after the last step.
    pub fn set_looping(&mut self, looping: bool) {
        self.looping = looping;
    }

    /// True when the chain loops.
    pub fn is_looping(&self) -> bool {
        self.looping
    }

    /// Append a step. Returns the (0-based) index of the appended step.
    pub fn push(&mut self, step: ChainStep) -> usize {
        let idx = self.steps.len();
        self.steps.push(step);
        self.finished = false;
        self.active = true;
        if self.iteration == 0 {
            self.iteration = 1;
        }
        idx
    }

    /// Remove all steps and reset the cursor.
    pub fn clear(&mut self) {
        self.steps.clear();
        self.cursor = 0;
        self.finished = false;
        self.active = false;
        self.paused = false;
        self.iteration = 0;
    }

    /// True when the chain has no steps.
    pub fn is_empty(&self) -> bool {
        self.steps.is_empty()
    }

    /// Return the number of steps.
    pub fn len(&self) -> usize {
        self.steps.len()
    }

    /// Reset the chain to step 0.
    pub fn reset(&mut self) {
        self.cursor = 0;
        self.finished = false;
        for step in &mut self.steps {
            step.elapsed = 0.0;
        }
    }

    /// Jump to step `index` (clamped to valid range).
    pub fn jump_to(&mut self, index: usize) {
        self.cursor = index.min(self.steps.len().saturating_sub(1));
        self.finished = false;
        if let Some(step) = self.steps.get_mut(self.cursor) {
            step.elapsed = 0.0;
        }
    }

    /// Return the current value of the active step (or 0.0 when empty/finished).
    pub fn value(&self) -> f64 {
        if self.finished || self.steps.is_empty() {
            return self.steps.last().map(|s| s.to).unwrap_or(0.0);
        }
        self.steps.get(self.cursor).map(|s| s.value()).unwrap_or(0.0)
    }

    /// Current step index.
    pub fn cursor(&self) -> usize {
        self.cursor
    }

    /// True when the chain has finished all steps (non-looping only).
    pub fn is_finished(&self) -> bool {
        self.finished
    }

    /// True when the chain is currently active.
    pub fn is_active(&self) -> bool {
        self.active
    }

    /// Current iteration (1-based while running, 0 before start).
    pub fn iteration(&self) -> u32 {
        self.iteration
    }

    /// Overall progress in [0.0, 1.0] for the current pass.
    pub fn progress(&self) -> f64 {
        if self.steps.is_empty() {
            return if self.finished { 1.0 } else { 0.0 };
        }
        if self.finished {
            return 1.0;
        }
        let total: f64 = self.steps.iter().map(|s| s.duration).sum();
        if total <= f64::EPSILON {
            return if self.cursor >= self.steps.len().saturating_sub(1) {
                1.0
            } else {
                0.0
            };
        }
        let mut elapsed = 0.0;
        for (idx, step) in self.steps.iter().enumerate() {
            if idx < self.cursor {
                elapsed += step.duration;
            } else if idx == self.cursor {
                elapsed += step.elapsed.min(step.duration);
                break;
            }
        }
        (elapsed / total).clamp(0.0, 1.0)
    }

    /// Advance the chain by `dt` seconds. Returns events for all steps completed
    /// during this tick (multiple if `dt` spans more than one short step).
    pub fn tick(&mut self, dt: f64) -> Vec<ChainEvent> {
        if self.finished || self.steps.is_empty() || !self.active || self.paused {
            return Vec::new();
        }

        let mut events = Vec::new();
        let mut remaining = dt;

        while remaining > 0.0 && !self.finished {
            let Some(step) = self.steps.get_mut(self.cursor) else { break };

            let leftover = (step.duration - step.elapsed).max(0.0);
            if remaining >= leftover {
                step.elapsed = step.duration;
                remaining -= leftover;

                let value = step.value();
                events.push(ChainEvent {
                    step: self.cursor,
                    label: step.label.clone(),
                    value,
                });

                self.cursor += 1;
                if self.cursor >= self.steps.len() {
                    if self.looping {
                        self.iteration = self.iteration.saturating_add(1);
                        self.reset();
                    } else {
                        self.cursor = self.steps.len() - 1;
                        self.finished = true;
                        self.active = false;
                    }
                } else if let Some(next) = self.steps.get_mut(self.cursor) {
                    next.elapsed = 0.0;
                }
            } else {
                step.elapsed += remaining;
                remaining = 0.0;
            }
        }

        events
    }
}

impl Default for TweenChain {
    fn default() -> Self {
        Self::new()
    }
}
