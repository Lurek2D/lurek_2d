//! Per-session and persistent memory primitives for LLM agents.
//!
//! - `WorkingMemory` is a bounded FIFO key-value store with configurable capacity (FIFO eviction when full).
//! - `EpisodicMemory` records time-stamped events and supports simple key-match queries and age-based pruning.
//! - `SemanticMemory` is an unbounded key-value fact store.
//! - `AgentMemory` bundles all three types and optionally serialises to disk via `save()` / `load()`.

use std::collections::{HashMap, VecDeque};

// ─── WorkingMemory ────────────────────────────────────────────────────────────

/// Bounded FIFO key-value working memory.
///
/// When the capacity is exceeded the oldest entry is evicted first.
pub struct WorkingMemory {
    /// Maximum number of key-value slots.
    capacity: usize,
    /// Entries stored in insertion order; the front is the oldest.
    slots: VecDeque<(String, serde_json::Value)>,
}

impl WorkingMemory {
    /// Creates a new `WorkingMemory` with the given `capacity`.
    ///
    /// A capacity of 0 means unlimited.
    pub fn new(capacity: usize) -> Self {
        Self { capacity, slots: VecDeque::new() }
    }

    /// Returns the configured capacity (0 = unlimited).
    pub fn capacity(&self) -> usize {
        self.capacity
    }

    /// Returns the current number of entries.
    pub fn len(&self) -> usize {
        self.slots.len()
    }

    /// Returns `true` if there are no entries.
    pub fn is_empty(&self) -> bool {
        self.slots.is_empty()
    }

    /// Inserts or updates an entry; evicts the oldest entry if capacity is exceeded.
    pub fn push(&mut self, key: String, value: serde_json::Value) {
        // Remove existing entry with the same key to avoid duplicates.
        self.slots.retain(|(k, _)| k != &key);
        self.slots.push_back((key, value));
        if self.capacity > 0 {
            while self.slots.len() > self.capacity {
                self.slots.pop_front();
            }
        }
    }

    /// Returns the value for `key`, or `None` if not present.
    pub fn get(&self, key: &str) -> Option<&serde_json::Value> {
        self.slots.iter().rev().find(|(k, _)| k == key).map(|(_, v)| v)
    }

    /// Removes the entry with `key`.  Returns `true` if it existed.
    pub fn forget(&mut self, key: &str) -> bool {
        let before = self.slots.len();
        self.slots.retain(|(k, _)| k != key);
        self.slots.len() < before
    }

    /// Returns the `n` most recently inserted entries as `(key, value)` pairs, newest last.
    pub fn get_recent(&self, n: usize) -> Vec<(&str, &serde_json::Value)> {
        self.slots.iter().rev().take(n).rev().map(|(k, v)| (k.as_str(), v)).collect()
    }
}

// ─── EpisodicMemory ───────────────────────────────────────────────────────────

/// A single recorded episode.
#[derive(Clone)]
pub struct Episode {
    /// Logical tick / frame at which this episode was recorded.
    pub tick: i64,
    /// Episode payload stored as a JSON object.
    pub data: HashMap<String, serde_json::Value>,
}

/// Append-only episodic memory with tick-based pruning and field-equality queries.
pub struct EpisodicMemory {
    /// All stored episodes, in recording order.
    episodes: Vec<Episode>,
}

impl EpisodicMemory {
    /// Creates an empty `EpisodicMemory`.
    pub fn new() -> Self {
        Self { episodes: Vec::new() }
    }

    /// Returns the number of stored episodes.
    pub fn len(&self) -> usize {
        self.episodes.len()
    }

    /// Returns `true` if there are no episodes.
    pub fn is_empty(&self) -> bool {
        self.episodes.is_empty()
    }

    /// Records a new episode at `tick` with the given data map.
    pub fn record(&mut self, tick: i64, data: HashMap<String, serde_json::Value>) {
        self.episodes.push(Episode { tick, data });
    }

    /// Returns all episodes whose data contains every key-value pair in `filter`.
    ///
    /// An empty `filter` returns all episodes.
    pub fn query(&self, filter: &HashMap<String, serde_json::Value>) -> Vec<&Episode> {
        self.episodes.iter().filter(|ep| {
            filter.iter().all(|(k, v)| ep.data.get(k) == Some(v))
        }).collect()
    }

    /// Removes all episodes with `tick < cutoff`.
    pub fn forget_before(&mut self, cutoff: i64) {
        self.episodes.retain(|ep| ep.tick >= cutoff);
    }
}

impl Default for EpisodicMemory {
    fn default() -> Self {
        Self::new()
    }
}

// ─── SemanticMemory ───────────────────────────────────────────────────────────

/// Unbounded key → JSON fact store.
pub struct SemanticMemory {
    /// Named facts stored as JSON values.
    facts: HashMap<String, serde_json::Value>,
}

impl SemanticMemory {
    /// Creates an empty `SemanticMemory`.
    pub fn new() -> Self {
        Self { facts: HashMap::new() }
    }

    /// Returns the number of stored facts.
    pub fn len(&self) -> usize {
        self.facts.len()
    }

    /// Returns `true` if there are no facts.
    pub fn is_empty(&self) -> bool {
        self.facts.is_empty()
    }

    /// Inserts or replaces the fact at `key`.
    pub fn learn(&mut self, key: String, value: serde_json::Value) {
        self.facts.insert(key, value);
    }

    /// Returns the fact for `key`, or `None`.
    pub fn recall(&self, key: &str) -> Option<&serde_json::Value> {
        self.facts.get(key)
    }

    /// Removes the fact at `key`.  Returns `true` if it existed.
    pub fn forget(&mut self, key: &str) -> bool {
        self.facts.remove(key).is_some()
    }

    /// Returns all facts whose value contains every key-value pair in `filter`.
    ///
    /// If the stored value is not a JSON object it only matches an empty `filter`.
    pub fn query(&self, filter: &HashMap<String, serde_json::Value>) -> Vec<(&str, &serde_json::Value)> {
        if filter.is_empty() {
            return self.facts.iter().map(|(k, v)| (k.as_str(), v)).collect();
        }
        self.facts.iter().filter(|(_, v)| {
            if let serde_json::Value::Object(map) = v {
                filter.iter().all(|(fk, fv)| map.get(fk) == Some(fv))
            } else {
                false
            }
        }).map(|(k, v)| (k.as_str(), v)).collect()
    }
}

impl Default for SemanticMemory {
    fn default() -> Self {
        Self::new()
    }
}

// ─── AgentMemory ──────────────────────────────────────────────────────────────

/// Bundled working, episodic, and semantic memory with optional disk persistence.
pub struct AgentMemory {
    /// Short-term bounded key-value cache.
    pub working: WorkingMemory,
    /// Time-stamped event log.
    pub episodic: EpisodicMemory,
    /// Long-term fact store.
    pub semantic: SemanticMemory,
    /// Optional file path for `save()` / `load()`.
    pub persist_path: Option<String>,
}

impl AgentMemory {
    /// Creates an `AgentMemory` with the given working-memory capacity.
    pub fn new(working_capacity: usize, persist_path: Option<String>) -> Self {
        Self {
            working: WorkingMemory::new(working_capacity),
            episodic: EpisodicMemory::new(),
            semantic: SemanticMemory::new(),
            persist_path,
        }
    }

    /// Serialises all three memory banks to the configured `persist_path`.
    ///
    /// Returns `Err` if no path is set or the write fails.
    pub fn save(&self) -> Result<(), String> {
        let path = self.persist_path.as_deref().ok_or("no persist_path configured")?;

        let mut working_arr = serde_json::Map::new();
        for (k, v) in &self.working.slots {
            working_arr.insert(k.clone(), v.clone());
        }

        let episodic_arr: Vec<serde_json::Value> = self.episodic.episodes.iter().map(|ep| {
            let mut obj = serde_json::Map::new();
            obj.insert("tick".to_string(), serde_json::json!(ep.tick));
            obj.insert("data".to_string(), serde_json::Value::Object(ep.data.iter().map(|(k, v)| (k.clone(), v.clone())).collect()));
            serde_json::Value::Object(obj)
        }).collect();

        let semantic_obj: serde_json::Map<String, serde_json::Value> = self.semantic.facts.iter().map(|(k, v)| (k.clone(), v.clone())).collect();

        let doc = serde_json::json!({
            "working": working_arr,
            "episodic": episodic_arr,
            "semantic": semantic_obj,
        });

        std::fs::write(path, doc.to_string()).map_err(|e| e.to_string())
    }

    /// Deserialises memory state from `persist_path`, replacing the current contents.
    ///
    /// Returns `Err` if no path is set, the file does not exist, or parsing fails.
    pub fn load(&mut self) -> Result<(), String> {
        let path = self.persist_path.as_deref().ok_or("no persist_path configured")?;
        let raw = std::fs::read_to_string(path).map_err(|e| e.to_string())?;
        let doc: serde_json::Value = serde_json::from_str(&raw).map_err(|e| e.to_string())?;

        // Restore working memory
        self.working.slots.clear();
        if let Some(wobj) = doc["working"].as_object() {
            for (k, v) in wobj {
                self.working.slots.push_back((k.clone(), v.clone()));
            }
        }

        // Restore episodic memory
        self.episodic.episodes.clear();
        if let Some(arr) = doc["episodic"].as_array() {
            for item in arr {
                let tick = item["tick"].as_i64().unwrap_or(0);
                let data = item["data"].as_object().map(|m| m.iter().map(|(k, v)| (k.clone(), v.clone())).collect()).unwrap_or_default();
                self.episodic.episodes.push(Episode { tick, data });
            }
        }

        // Restore semantic memory
        self.semantic.facts.clear();
        if let Some(sobj) = doc["semantic"].as_object() {
            for (k, v) in sobj {
                self.semantic.facts.insert(k.clone(), v.clone());
            }
        }

        Ok(())
    }
}
