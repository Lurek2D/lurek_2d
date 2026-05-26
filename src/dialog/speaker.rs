//! Speaker registry and character metadata used across dialog trees.
//!
//! - `Speaker` holds a display name, portrait asset path, and voice bank key.
//! - The global `SpeakerRegistry` maps speaker IDs to `Speaker` values.
//! - Speakers are registered from TOML at load time or dynamically via `lurek.dialog`.
//! - Speaker IDs are stable string slugs (e.g. `"npc_merchant"`) not numeric indices.

use std::collections::HashMap;

/// Information about a dialog speaker/character.
#[derive(Debug, Clone)]
pub struct Speaker {
    /// Unique identifier.
    pub id: String,
    /// Display name.
    pub name: String,
    /// Optional portrait asset path.
    pub portrait: Option<String>,
    /// Optional voice identifier for audio.
    pub voice_id: Option<String>,
    /// Arbitrary tags (e.g., "friendly", "merchant").
    pub tags: Vec<String>,
}

impl Speaker {
    /// Create a new speaker with the given id and display name.
    pub fn new(id: impl Into<String>, name: impl Into<String>) -> Self {
        Self {
            id: id.into(),
            name: name.into(),
            portrait: None,
            voice_id: None,
            tags: Vec::new(),
        }
    }
}

/// Registry of all known speakers in a dialog system.
#[derive(Debug, Clone, Default)]
pub struct SpeakerRegistry {
    speakers: HashMap<String, Speaker>,
}

impl SpeakerRegistry {
    /// Create an empty speaker registry.
    pub fn new() -> Self {
        Self::default()
    }

    /// Register a speaker in the registry.
    pub fn add(&mut self, speaker: Speaker) {
        self.speakers.insert(speaker.id.clone(), speaker);
    }

    /// Get a registered speaker by its ID.
    pub fn get(&self, id: &str) -> Option<&Speaker> {
        self.speakers.get(id)
    }

    /// Remove and return a speaker by its ID.
    pub fn remove(&mut self, id: &str) -> Option<Speaker> {
        self.speakers.remove(id)
    }

    /// Number of registered speakers.
    pub fn count(&self) -> usize {
        self.speakers.len()
    }

    /// Check if a speaker ID exists in the registry.
    pub fn contains(&self, id: &str) -> bool {
        self.speakers.contains_key(id)
    }

    /// Get all registered speaker ID strings.
    pub fn ids(&self) -> Vec<&str> {
        self.speakers.keys().map(|s| s.as_str()).collect()
    }
}
