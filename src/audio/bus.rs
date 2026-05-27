//! Named audio routing bus with per-bus volume, pitch, pause, and duck-target controls.
//!
//! - Shared DSP effect chain stored as `Arc<RwLock<Vec<Arc<EffectParams>>>>` for lock-free audio-thread reads.
//! - Duck-target assignment enabling automatic cross-bus volume suppression.
//! - Boundary clamping on volume, pitch, and duck volume values.

use crate::log_msg;
use crate::runtime::log_messages::{BU01, BU02, BU03};
#[derive(Debug, Clone)]
/// Named audio routing channel that applies volume, pitch, effects, and ducking to its sources.
///
/// # Fields
pub struct Bus {
    /// Human-readable identifier used as the registry key in `Mixer`.
    name: String,
    /// Volume multiplier applied to all sources on this bus; clamped to >= 0.0.
    volume: f32,
    /// Pitch multiplier applied to all sources on this bus; clamped to >= 0.0.
    pitch: f32,
    /// When true, all sources assigned to this bus are suspended from playback.
    paused: bool,
    /// Shared DSP effect chain applied by `DynamicEffectSource` on every source in this bus.
    pub effects: std::sync::Arc<std::sync::RwLock<Vec<std::sync::Arc<crate::dsp::EffectParams>>>>,
    /// Optional duck target: `(bus_name, duck_volume)` to suppress when this bus is active.
    pub duck_target: Option<(String, f32)>,
}
impl Bus {
    /// Create a new bus with the given name, volume=1.0, pitch=1.0, unpaused, and no effects.
    pub fn new(name: impl Into<String>) -> Self {
        let name = name.into();
        log_msg!(debug, BU01, "{}", name);
        Bus {
            name,
            volume: 1.0,
            pitch: 1.0,
            paused: false,
            effects: std::sync::Arc::new(std::sync::RwLock::new(Vec::new())),
            duck_target: None,
        }
    }
    /// Return the name of this bus. This function is part of the public API.
    pub fn name(&self) -> &str {
        &self.name
    }
    /// Return the current volume multiplier for this bus.
    pub fn volume(&self) -> f32 {
        self.volume
    }
    /// Set the volume multiplier; values below 0.0 are clamped to 0.0.
    pub fn set_volume(&mut self, volume: f32) {
        self.volume = volume.max(0.0);
    }
    /// Return the current pitch multiplier for this bus.
    pub fn pitch(&self) -> f32 {
        self.pitch
    }
    /// Set the pitch multiplier; values below 0.0 are clamped to 0.0.
    pub fn set_pitch(&mut self, pitch: f32) {
        self.pitch = pitch.max(0.0);
    }
    /// Pause all sources on this bus; no-op if already paused.
    pub fn pause(&mut self) {
        log_msg!(debug, BU02, "{}", self.name);
        self.paused = true;
    }
    /// Resume all sources on this bus; no-op if already playing.
    pub fn resume(&mut self) {
        log_msg!(debug, BU03, "{}", self.name);
        self.paused = false;
    }
    /// Return `true` when this bus is paused.
    pub fn is_paused(&self) -> bool {
        self.paused
    }
    /// Set the duck target bus name and duck volume; volume is clamped to 0.0..=1.0.
    pub fn set_duck_target(&mut self, target_bus_name: impl Into<String>, duck_volume: f32) {
        log_msg!(debug, BU02, "{}", duck_volume);
        self.duck_target = Some((target_bus_name.into(), duck_volume.clamp(0.0, 1.0)));
    }
    /// Remove configured duck target from this bus.
    pub fn clear_duck_target(&mut self) {
        log_msg!(debug, BU03, "duck target cleared");
        self.duck_target = None;
    }
}
