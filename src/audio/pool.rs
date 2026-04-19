//! Polyphonic sound pool for round-robin voice allocation.
//!
//! `SoundPool` pre-loads `N` copies of the same audio file into the [`crate::audio::mixer::Mixer`]
//! and hands them out in a round-robin cycle.  When all voices are busy the oldest voice is
//! silently re-triggered, giving predictable polyphony without dynamic allocations at play time.
//!
//! The `SoundPool` owns only the `SoundKey` slice and metadata; all actual audio work is
//! delegated to the `Mixer`.  Game code accesses pools exclusively through `lurek.audio.newPool`
//! and the returned `LuaSoundPool` UserData.

use crate::runtime::resource_keys::SoundKey;

/// A round-robin voice pool for polyphonic playback of a single audio file.
///
/// Holds `voice_count` pre-loaded [`SoundKey`] handles and cycles through them on each
/// `next_voice` call.  The mapping to physical audio operations is performed by the caller
/// (typically the `LuaSoundPool` Lua UserData registered in `src/lua_api/audio_api.rs`).
///
/// # Fields
/// - `keys`        — `Vec<SoundKey>`. Pre-loaded voice handles.
/// - `next`        — `usize`. Ring-buffer cursor; advances modulo `voice_count` on each play.
/// - `file_path`   — `String`. Path used when the keys were loaded.
/// - `volume`      — `f32`. Shared base volume applied to all voices on next play.
/// - `bus_name`    — `Option<String>`. Named bus to route all voices to.
pub struct SoundPool {
    keys: Vec<SoundKey>,
    next: usize,
    file_path: String,
    volume: f32,
    bus_name: Option<String>,
}

impl SoundPool {
    /// Creates a new `SoundPool` from a set of pre-loaded voice keys.
    ///
    /// Call `Mixer::load_pool` rather than constructing this directly; it handles the
    /// actual `load_source` calls.
    ///
    /// # Parameters
    /// - `keys`      — `Vec<SoundKey>`. Pre-loaded voice handles (length = voice count).
    /// - `file_path` — `String`. The original source path (stored for diagnostics).
    ///
    /// # Returns
    /// `Self`.
    pub fn new(keys: Vec<SoundKey>, file_path: String) -> Self {
        Self {
            keys,
            next: 0,
            file_path,
            volume: 1.0,
            bus_name: None,
        }
    }

    /// Returns the number of voices in the pool.
    ///
    /// # Returns
    /// `usize`.
    pub fn voice_count(&self) -> usize {
        self.keys.len()
    }

    /// Returns the source path originally used to create this pool.
    ///
    /// # Returns
    /// `&str`.
    pub fn file_path(&self) -> &str {
        &self.file_path
    }

    /// Returns the shared volume applied to all voices.
    ///
    /// # Returns
    /// `f32`.
    pub fn volume(&self) -> f32 {
        self.volume
    }

    /// Sets the shared volume for all future plays.
    ///
    /// # Parameters
    /// - `vol` — `f32`. Volume multiplier in `[0.0, ∞)`.
    pub fn set_volume(&mut self, vol: f32) {
        self.volume = vol.max(0.0);
    }

    /// Returns the bus assignment for all voices, if any.
    ///
    /// # Returns
    /// `Option<&str>`.
    pub fn bus_name(&self) -> Option<&str> {
        self.bus_name.as_deref()
    }

    /// Sets the named audio bus that all voices will be routed to.
    ///
    /// The assignment is applied when voices are played.
    ///
    /// # Parameters
    /// - `name` — `&str`. Bus name.
    pub fn set_bus(&mut self, name: &str) {
        self.bus_name = Some(name.to_owned());
    }

    /// Clears the bus assignment.
    pub fn clear_bus(&mut self) {
        self.bus_name = None;
    }

    /// Advances the cursor and returns the next voice key for playback.
    ///
    /// Wraps around when all voices have been used.
    ///
    /// # Returns
    /// `SoundKey`. The key to pass to `Mixer::play`.
    pub fn next_voice(&mut self) -> SoundKey {
        let key = self.keys[self.next % self.keys.len()];
        self.next = (self.next + 1) % self.keys.len();
        key
    }

    /// Returns a slice of all voice keys.
    ///
    /// # Returns
    /// `&[SoundKey]`.
    pub fn all_keys(&self) -> &[SoundKey] {
        &self.keys
    }

    /// Returns `true` if the pool was created with at least one voice.
    ///
    /// # Returns
    /// `bool`.
    pub fn is_valid(&self) -> bool {
        !self.keys.is_empty()
    }
}

// Tests migrated to tests/rust/unit/audio_tests.rs
