//! Provides canonical speaker identity records used by dialogue flow to resolve who is talking at each step. `dialog/speaker` delivers the speaker implementation for the dialog subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Centralizes speaker lookup in a stable registry keyed by durable identifiers shared across a session. The file owns or coordinates data contracts including `Speaker`, `SpeakerRegistry`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Keeps narrative content decoupled from presentation metadata like portraits, voices, and character tags. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `add`, `get`, `remove`, `count`, `contains`, and 1 more stays attached to the local data model and invariants.

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
