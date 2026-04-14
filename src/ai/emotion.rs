//! AI Emotion Model — simulated affective state for expressive agents.
//!
//! Implements a simple dimensional emotion model: each [`Emotion`] is a named
//! float value in `[0.0, 1.0]` that decays toward a resting level per frame.
//! External triggers bump emotions up instantaneously. The dominant emotion is
//! the one with the highest current value above its `min_visible` threshold.
//!
//! ## Architecture
//!
//! - [`Emotion`] is one affective dimension with current value, resting level,
//!   decay rate, and a minimum visibility threshold.
//! - [`EmotionModel`] owns a collection of emotions for one agent. Game code
//!   reads `dominant()` to drive animations, dialogue, and FSM transitions.
//!
//! ## Typical Usage Sequence
//!
//! 1. At agent creation, build an `EmotionModel` with the desired emotion set.
//! 2. Call `trigger("anger", 0.8)` when anger-inducing events happen.
//! 3. Call `update(dt)` each frame to decay emotions toward their resting levels.
//! 4. Call `dominant()` to get the strongest active emotion name.
//! 5. Store the dominant emotion in the agent's blackboard for FSM/dialogue use.

// ────────────────────────────────────────────────────────────────────────────
// Emotion
// ────────────────────────────────────────────────────────────────────────────

/// A single named affective dimension.
///
/// # Fields
/// - `name` — `String`.
/// - `value` — `f32`.
/// - `resting_level` — `f32`.
/// - `decay_rate` — `f32`.
/// - `min_visible` — `f32`.
pub struct Emotion {
    /// Unique name of this emotion (e.g. `"anger"`, `"fear"`, `"joy"`).
    pub name: String,
    /// Current arousal level in `[0.0, 1.0]`.
    pub value: f32,
    /// Resting/baseline level — the value decays toward this, not toward zero.
    pub resting_level: f32,
    /// Arousal lost per second decaying toward `resting_level`.
    pub decay_rate: f32,
    /// Minimum value for this emotion to be considered "active" for `dominant()`.
    pub min_visible: f32,
}

impl Emotion {
    /// Creates a new emotion starting at its resting level.
    ///
    /// # Parameters
    /// - `name` — `&str`.
    /// - `resting_level` — `f32`.
    /// - `decay_rate` — `f32`.
    /// - `min_visible` — `f32`.
    ///
    /// # Returns
    /// `Self`.
    pub fn new(name: &str, resting_level: f32, decay_rate: f32, min_visible: f32) -> Self {
        Self {
            name: name.to_string(),
            value: resting_level,
            resting_level: resting_level.clamp(0.0, 1.0),
            decay_rate,
            min_visible: min_visible.clamp(0.0, 1.0),
        }
    }

    /// Returns `true` when this emotion's value is at or above `min_visible`.
    ///
    /// # Returns
    /// `bool`.
    pub fn is_active(&self) -> bool {
        self.value >= self.min_visible
    }

    /// Bumps the emotion up by `amount`, clamped to `[0.0, 1.0]`.
    ///
    /// # Parameters
    /// - `amount` — `f32`.
    pub fn trigger(&mut self, amount: f32) {
        self.value = (self.value + amount).clamp(0.0, 1.0);
    }

    /// Sets the emotion to an exact value, clamped to `[0.0, 1.0]`.
    ///
    /// # Parameters
    /// - `value` — `f32`.
    pub fn set(&mut self, value: f32) {
        self.value = value.clamp(0.0, 1.0);
    }

    /// Advances decay by `dt` seconds, moving toward `resting_level`.
    ///
    /// # Parameters
    /// - `dt` — `f32`.
    pub fn update(&mut self, dt: f32) {
        if self.value > self.resting_level {
            self.value = (self.value - self.decay_rate * dt).max(self.resting_level);
        } else if self.value < self.resting_level {
            self.value = (self.value + self.decay_rate * dt).min(self.resting_level);
        }
    }
}

// ────────────────────────────────────────────────────────────────────────────
// EmotionModel
// ────────────────────────────────────────────────────────────────────────────

/// Affective state model for an AI agent.
///
/// Owns a collection of [`Emotion`]s. Provides `trigger`, `update`, and
/// `dominant` accessors to drive expressive NPC behaviour.
///
/// # Fields
/// - `emotions` — `Vec<Emotion>`.
#[derive(Default)]
pub struct EmotionModel {
    emotions: Vec<Emotion>,
}

impl EmotionModel {
    /// Creates an empty emotion model.
    ///
    /// # Returns
    /// `Self`.
    pub fn new() -> Self {
        Self::default()
    }

    /// Adds or replaces an emotion by name.
    ///
    /// # Parameters
    /// - `emotion` — `Emotion`.
    pub fn add(&mut self, emotion: Emotion) {
        if let Some(e) = self.emotions.iter_mut().find(|e| e.name == emotion.name) {
            *e = emotion;
        } else {
            self.emotions.push(emotion);
        }
    }

    /// Returns the current value of a named emotion, or `0.0` if not found.
    ///
    /// # Parameters
    /// - `name` — `&str`.
    ///
    /// # Returns
    /// `f32`.
    pub fn get(&self, name: &str) -> f32 {
        self.emotions.iter().find(|e| e.name == name).map(|e| e.value).unwrap_or(0.0)
    }

    /// Triggers a named emotion by adding `amount` to its current value.
    /// Silently ignores unknown emotions.
    ///
    /// # Parameters
    /// - `name` — `&str`.
    /// - `amount` — `f32`.
    pub fn trigger(&mut self, name: &str, amount: f32) {
        if let Some(e) = self.emotions.iter_mut().find(|e| e.name == name) {
            e.trigger(amount);
        }
    }

    /// Sets a named emotion to an exact value. Silently ignores unknown emotions.
    ///
    /// # Parameters
    /// - `name` — `&str`.
    /// - `value` — `f32`.
    pub fn set(&mut self, name: &str, value: f32) {
        if let Some(e) = self.emotions.iter_mut().find(|e| e.name == name) {
            e.set(value);
        }
    }

    /// Advances all emotions' decay by `dt` seconds.
    ///
    /// # Parameters
    /// - `dt` — `f32`.
    pub fn update(&mut self, dt: f32) {
        for e in &mut self.emotions { e.update(dt); }
    }

    /// Returns the name of the dominant (highest active) emotion, or `None`
    /// if no emotion is above its `min_visible` threshold.
    ///
    /// # Returns
    /// `Option<&str>`.
    pub fn dominant(&self) -> Option<&str> {
        self.emotions.iter()
            .filter(|e| e.is_active())
            .max_by(|a, b| a.value.partial_cmp(&b.value).unwrap())
            .map(|e| e.name.as_str())
    }

    /// Returns `true` when a named emotion is at or above its `min_visible` threshold.
    ///
    /// # Parameters
    /// - `name` — `&str`.
    ///
    /// # Returns
    /// `bool`.
    pub fn is_active(&self, name: &str) -> bool {
        self.emotions.iter().find(|e| e.name == name).map(|e| e.is_active()).unwrap_or(false)
    }

    /// Returns the names of all emotions currently active (above `min_visible`).
    ///
    /// # Returns
    /// `Vec<&str>`.
    pub fn active_names(&self) -> Vec<&str> {
        self.emotions.iter().filter(|e| e.is_active()).map(|e| e.name.as_str()).collect()
    }

    /// Returns the number of emotions registered in this model.
    ///
    /// # Returns
    /// `usize`.
    pub fn count(&self) -> usize {
        self.emotions.len()
    }

    /// Resets all emotions to their resting levels.
    pub fn reset(&mut self) {
        for e in &mut self.emotions { e.value = e.resting_level; }
    }
}
