//! Named audio bus for grouping sources under shared volume, pitch, and pause controls.
//!
//! This module is part of Luna2D's `audio` subsystem and provides the implementation
//! details for bus-related operations and data management.
//! Key types exported from this module: `Bus`.
//! Primary functions: `new()`, `name()`, `volume()`, `set_volume()`.
//!
//! All public items are documented. See the parent module for architectural context
//! and the `luna.*` Lua API for the scripting interface.

/// A named audio bus that applies volume, pitch, and pause overrides to all
/// sources assigned to it.
///
/// Buses are pure data containers — they hold no rodio resources.
/// The `Mixer` multiplies a source's per-source volume/pitch by its assigned
/// bus values. Setting a bus to paused suppresses playback of all assigned
/// sources until the bus is resumed.
///
/// # Fields
/// - `name` — `String`.
/// - `volume` — `f32`.
/// - `pitch` — `f32`.
/// - `paused` — `bool`.
#[derive(Debug, Clone)]
pub struct Bus {
    pub effects: std::sync::Arc<std::sync::RwLock<Vec<std::sync::Arc<crate::audio::dsp::EffectParams>>>>,
    name: String,
    volume: f32,
    pitch: f32,
    paused: bool,
}

impl Bus {
    /// Creates a new bus with the given name, volume `1.0`, pitch `1.0`, and not paused.
    ///
    /// # Parameters
    /// - `name` — `impl Into<String>`.
    ///
    /// # Returns
    /// `Self`.
    pub fn new(name: impl Into<String>) -> Self {
        Bus {
            name: name.into(),
            volume: 1.0,
            pitch: 1.0,
            paused: false,
            effects: std::sync::Arc::new(std::sync::RwLock::new(Vec::new())),
        }
    }

    /// Returns the bus name. Consult the module-level documentation for the broader usage context and preconditions.
    ///
    /// # Returns
    /// `&str`.
    pub fn name(&self) -> &str {
        &self.name
    }

    /// Returns the bus volume (always `>= 0.0`).
    ///
    /// # Returns
    /// `f32`.
    pub fn volume(&self) -> f32 {
        self.volume
    }

    /// Sets the bus volume, clamped to `>= 0.0`.
    ///
    /// # Parameters
    /// - `volume` — `f32`.
    pub fn set_volume(&mut self, volume: f32) {
        self.volume = volume.max(0.0);
    }

    /// Returns the bus pitch multiplier (always `>= 0.0`).
    ///
    /// # Returns
    /// `f32`.
    pub fn pitch(&self) -> f32 {
        self.pitch
    }

    /// Sets the bus pitch multiplier, clamped to `>= 0.0`.
    ///
    /// # Parameters
    /// - `pitch` — `f32`.
    pub fn set_pitch(&mut self, pitch: f32) {
        self.pitch = pitch.max(0.0);
    }

    /// Pauses the bus. All sources assigned to this bus will be suppressed.
    pub fn pause(&mut self) {
        self.paused = true;
    }

    /// Resumes the bus. Consult the module-level documentation for the broader usage context and preconditions.
    pub fn resume(&mut self) {
        self.paused = false;
    }

    /// Returns whether the bus is paused. This accessor incurs no allocation; call it freely in hot paths.
    ///
    /// # Returns
    /// `bool`.
    pub fn is_paused(&self) -> bool {
        self.paused
    }
}
