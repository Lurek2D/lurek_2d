//! Owns the memory store for the agent subsystem and keeps its rules local to this file while keeping call sites explicit.
//! Keeps agent data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
//! Defines how memory data is validated, transformed, or stored before neighboring systems use it.
//! Owns agent behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps public crate helpers focused on memory behavior while Lua registration stays elsewhere.
//! Documents where agent callers should change defaults, errors, or lifecycle behavior. with focused crate-local behavior.
//! Use this file when changing memory defaults, lifecycle handling, validation, or data ownership.
//! Keeps failure paths and edge cases near the agent state that can explain them while keeping call sites explicit.

use std::collections::{HashMap, VecDeque};
use std::path::{Path, PathBuf};
use std::time::{SystemTime, UNIX_EPOCH};

const DEFAULT_WORKING_MEMORY_CAPACITY: usize = 64;
const AGENT_MEMORY_SCHEMA_VERSION: u32 = 1;
const DEFAULT_MAX_MEMORY_BYTES: u64 = 1_048_576;
const DEFAULT_MAX_MEMORY_ENTRIES: usize = 4096;

/// Persistence policy applied to bundled agent-memory save/load operations.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct AgentMemoryStoragePolicy {
    /// Canonical root directory that persisted memory paths must stay under.
    pub sandbox_root: PathBuf,
    /// Maximum file size accepted for load and produced by save.
    pub max_bytes: u64,
    /// Maximum entries accepted per memory bank during load.
    pub max_entries_per_bank: usize,
}

impl Default for AgentMemoryStoragePolicy {
    fn default() -> Self {
        Self {
            sandbox_root: default_memory_sandbox_root(),
            max_bytes: DEFAULT_MAX_MEMORY_BYTES,
            max_entries_per_bank: DEFAULT_MAX_MEMORY_ENTRIES,
        }
    }
}

/// Read-only diagnostics snapshot for one bundled agent-memory instance.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct AgentMemoryDiagnosticsSnapshot {
    /// Working-memory entry count.
    pub working_entries: usize,
    /// Episodic-memory entry count.
    pub episodic_entries: usize,
    /// Semantic-memory entry count.
    pub semantic_entries: usize,
    /// Approximate serialized size of the current memory envelope.
    pub approx_bytes: u64,
    /// Maximum configured persisted file size.
    pub max_bytes: u64,
    /// Canonical sandbox root used by save/load operations.
    pub sandbox_root: PathBuf,
}

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
    /// A capacity of 0 maps to the default safe bounded capacity.
    pub fn new(capacity: usize) -> Self {
        Self {
            capacity: normalize_capacity(capacity),
            slots: VecDeque::new(),
        }
    }

    /// Returns the configured safe bounded capacity.
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
        self.slots.retain(|(existing_key, _)| existing_key != &key);
        self.slots.push_back((key, value));
        while self.slots.len() > self.capacity {
            self.slots.pop_front();
        }
    }

    /// Returns the value for `key`, or `None` if not present.
    pub fn get(&self, key: &str) -> Option<&serde_json::Value> {
        self.slots
            .iter()
            .rev()
            .find(|(existing_key, _)| existing_key == key)
            .map(|(_, value)| value)
    }

    /// Removes the entry with `key`. Returns `true` if it existed.
    pub fn forget(&mut self, key: &str) -> bool {
        let before = self.slots.len();
        self.slots.retain(|(existing_key, _)| existing_key != key);
        self.slots.len() < before
    }

    /// Returns the `n` most recently inserted entries as `(key, value)` pairs, newest last.
    pub fn get_recent(&self, n: usize) -> Vec<(&str, &serde_json::Value)> {
        self.slots
            .iter()
            .rev()
            .take(n)
            .rev()
            .map(|(key, value)| (key.as_str(), value))
            .collect()
    }
}

/// A single recorded episodic-memory event snapshot.
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
        Self {
            episodes: Vec::new(),
        }
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
    pub fn query(&self, filter: &HashMap<String, serde_json::Value>) -> Vec<&Episode> {
        self.episodes
            .iter()
            .filter(|episode| {
                filter
                    .iter()
                    .all(|(key, value)| episode.data.get(key) == Some(value))
            })
            .collect()
    }

    /// Removes all episodes with `tick < cutoff`.
    pub fn forget_before(&mut self, cutoff: i64) {
        self.episodes.retain(|episode| episode.tick >= cutoff);
    }
}

impl Default for EpisodicMemory {
    fn default() -> Self {
        Self::new()
    }
}

/// Unbounded key → JSON fact store.
pub struct SemanticMemory {
    /// Named facts stored as JSON values.
    facts: HashMap<String, serde_json::Value>,
}

impl SemanticMemory {
    /// Creates an empty `SemanticMemory`.
    pub fn new() -> Self {
        Self {
            facts: HashMap::new(),
        }
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

    /// Removes the fact at `key`. Returns `true` if it existed.
    pub fn forget(&mut self, key: &str) -> bool {
        self.facts.remove(key).is_some()
    }

    /// Returns all facts whose value contains every key-value pair in `filter`.
    pub fn query(
        &self,
        filter: &HashMap<String, serde_json::Value>,
    ) -> Vec<(&str, &serde_json::Value)> {
        if filter.is_empty() {
            return self
                .facts
                .iter()
                .map(|(key, value)| (key.as_str(), value))
                .collect();
        }
        self.facts
            .iter()
            .filter(|(_, value)| {
                if let serde_json::Value::Object(map) = value {
                    filter
                        .iter()
                        .all(|(filter_key, filter_value)| map.get(filter_key) == Some(filter_value))
                } else {
                    false
                }
            })
            .map(|(key, value)| (key.as_str(), value))
            .collect()
    }
}

impl Default for SemanticMemory {
    fn default() -> Self {
        Self::new()
    }
}

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
    /// Safe persistence policy applied to disk operations.
    pub storage_policy: AgentMemoryStoragePolicy,
}

impl AgentMemory {
    /// Creates an `AgentMemory` with the given working-memory capacity.
    pub fn new(working_capacity: usize, persist_path: Option<String>) -> Self {
        Self {
            working: WorkingMemory::new(working_capacity),
            episodic: EpisodicMemory::new(),
            semantic: SemanticMemory::new(),
            persist_path,
            storage_policy: AgentMemoryStoragePolicy::default(),
        }
    }

    /// Serialises all three memory banks to the configured `persist_path`.
    pub fn save(&self) -> Result<(), String> {
        let resolved_path = self.resolve_persist_path()?;
        let working_entries: Vec<serde_json::Value> = self
            .working
            .slots
            .iter()
            .map(|(key, value)| serde_json::json!({ "key": key, "value": value }))
            .collect();

        let episodic_entries: Vec<serde_json::Value> = self
            .episodic
            .episodes
            .iter()
            .map(|episode| {
                serde_json::json!({
                    "tick": episode.tick,
                    "data": episode.data,
                })
            })
            .collect();

        let semantic_entries: serde_json::Map<String, serde_json::Value> = self
            .semantic
            .facts
            .iter()
            .map(|(key, value)| (key.clone(), value.clone()))
            .collect();

        let envelope = serde_json::json!({
            "version": AGENT_MEMORY_SCHEMA_VERSION,
            "working_capacity": self.working.capacity(),
            "working": working_entries,
            "episodic": episodic_entries,
            "semantic": semantic_entries,
        });
        let serialized = serde_json::to_vec_pretty(&envelope).map_err(|error| error.to_string())?;
        if serialized.len() as u64 > self.storage_policy.max_bytes {
            return Err(format!(
                "agent memory payload exceeds max_bytes {}",
                self.storage_policy.max_bytes
            ));
        }
        atomic_write(&resolved_path, &serialized)
    }

    /// Deserialises memory state from `persist_path`, replacing the current contents.
    pub fn load(&mut self) -> Result<(), String> {
        let resolved_path = self.resolve_persist_path()?;
        let metadata = std::fs::metadata(&resolved_path).map_err(|error| error.to_string())?;
        if metadata.len() > self.storage_policy.max_bytes {
            return Err(format!(
                "agent memory file '{}' exceeds max_bytes {}",
                resolved_path.display(),
                self.storage_policy.max_bytes
            ));
        }

        let raw = std::fs::read_to_string(&resolved_path).map_err(|error| error.to_string())?;
        let envelope: serde_json::Value =
            serde_json::from_str(&raw).map_err(|error| error.to_string())?;
        let version = envelope
            .get("version")
            .and_then(|value| value.as_u64())
            .ok_or_else(|| "agent memory envelope is missing a numeric version".to_string())?;
        if version != u64::from(AGENT_MEMORY_SCHEMA_VERSION) {
            return Err(format!(
                "unsupported agent memory schema version {}",
                version
            ));
        }

        let working_capacity = envelope
            .get("working_capacity")
            .and_then(|value| value.as_u64())
            .map(|value| normalize_capacity(value as usize))
            .unwrap_or(DEFAULT_WORKING_MEMORY_CAPACITY);
        self.working.capacity = working_capacity;
        self.working.slots.clear();
        let working = envelope
            .get("working")
            .and_then(|value| value.as_array())
            .ok_or_else(|| "agent memory envelope is missing a working array".to_string())?;
        if working.len() > self.storage_policy.max_entries_per_bank {
            return Err(format!(
                "working memory entry count {} exceeds max_entries_per_bank {}",
                working.len(),
                self.storage_policy.max_entries_per_bank
            ));
        }
        for entry in working {
            let key = entry
                .get("key")
                .and_then(|value| value.as_str())
                .ok_or_else(|| "working memory entry is missing a string key".to_string())?;
            let value = entry
                .get("value")
                .ok_or_else(|| "working memory entry is missing a value".to_string())?;
            self.working
                .slots
                .push_back((key.to_string(), value.clone()));
        }

        self.episodic.episodes.clear();
        let episodic = envelope
            .get("episodic")
            .and_then(|value| value.as_array())
            .ok_or_else(|| "agent memory envelope is missing an episodic array".to_string())?;
        if episodic.len() > self.storage_policy.max_entries_per_bank {
            return Err(format!(
                "episodic memory entry count {} exceeds max_entries_per_bank {}",
                episodic.len(),
                self.storage_policy.max_entries_per_bank
            ));
        }
        for entry in episodic {
            let tick = entry
                .get("tick")
                .and_then(|value| value.as_i64())
                .unwrap_or(0);
            let data = entry
                .get("data")
                .and_then(|value| value.as_object())
                .map(|object| {
                    object
                        .iter()
                        .map(|(key, value)| (key.clone(), value.clone()))
                        .collect()
                })
                .unwrap_or_default();
            self.episodic.episodes.push(Episode { tick, data });
        }

        self.semantic.facts.clear();
        let semantic = envelope
            .get("semantic")
            .and_then(|value| value.as_object())
            .ok_or_else(|| "agent memory envelope is missing a semantic object".to_string())?;
        if semantic.len() > self.storage_policy.max_entries_per_bank {
            return Err(format!(
                "semantic memory entry count {} exceeds max_entries_per_bank {}",
                semantic.len(),
                self.storage_policy.max_entries_per_bank
            ));
        }
        for (key, value) in semantic {
            self.semantic.facts.insert(key.clone(), value.clone());
        }

        Ok(())
    }

    /// Returns a diagnostics snapshot for the current in-memory state and storage policy.
    pub fn diagnostics_snapshot(&self) -> AgentMemoryDiagnosticsSnapshot {
        let approx_bytes = self
            .serialize_envelope()
            .ok()
            .map(|bytes| bytes.len() as u64)
            .unwrap_or(0);
        AgentMemoryDiagnosticsSnapshot {
            working_entries: self.working.len(),
            episodic_entries: self.episodic.len(),
            semantic_entries: self.semantic.len(),
            approx_bytes,
            max_bytes: self.storage_policy.max_bytes,
            sandbox_root: self.storage_policy.sandbox_root.clone(),
        }
    }

    fn resolve_persist_path(&self) -> Result<PathBuf, String> {
        let persist_path = self
            .persist_path
            .as_deref()
            .ok_or_else(|| "no persist_path configured".to_string())?;
        resolve_sandboxed_path(&self.storage_policy.sandbox_root, persist_path)
    }

    fn serialize_envelope(&self) -> Result<Vec<u8>, String> {
        let working_entries: Vec<serde_json::Value> = self
            .working
            .slots
            .iter()
            .map(|(key, value)| serde_json::json!({ "key": key, "value": value }))
            .collect();

        let episodic_entries: Vec<serde_json::Value> = self
            .episodic
            .episodes
            .iter()
            .map(|episode| {
                serde_json::json!({
                    "tick": episode.tick,
                    "data": episode.data,
                })
            })
            .collect();

        let semantic_entries: serde_json::Map<String, serde_json::Value> = self
            .semantic
            .facts
            .iter()
            .map(|(key, value)| (key.clone(), value.clone()))
            .collect();

        let envelope = serde_json::json!({
            "version": AGENT_MEMORY_SCHEMA_VERSION,
            "working_capacity": self.working.capacity(),
            "working": working_entries,
            "episodic": episodic_entries,
            "semantic": semantic_entries,
        });
        serde_json::to_vec_pretty(&envelope).map_err(|error| error.to_string())
    }
}

fn normalize_capacity(capacity: usize) -> usize {
    if capacity == 0 {
        DEFAULT_WORKING_MEMORY_CAPACITY
    } else {
        capacity
    }
}

fn default_memory_sandbox_root() -> PathBuf {
    std::env::current_dir()
        .ok()
        .and_then(|path| std::fs::canonicalize(path).ok())
        .unwrap_or_else(|| PathBuf::from("."))
}

fn resolve_sandboxed_path(root: &Path, candidate: &str) -> Result<PathBuf, String> {
    let canonical_root = std::fs::canonicalize(root).map_err(|error| {
        format!(
            "failed to resolve agent memory sandbox root '{}': {}",
            root.display(),
            error
        )
    })?;

    let candidate_path = PathBuf::from(candidate);
    let absolute = if candidate_path.is_absolute() {
        candidate_path
    } else {
        canonical_root.join(candidate_path)
    };

    let parent = absolute.parent().ok_or_else(|| {
        format!(
            "agent memory path '{}' does not have a parent directory",
            absolute.display()
        )
    })?;
    std::fs::create_dir_all(parent).map_err(|error| error.to_string())?;
    let canonical_parent = std::fs::canonicalize(parent).map_err(|error| error.to_string())?;
    if !canonical_parent.starts_with(&canonical_root) {
        return Err(format!(
            "agent memory path '{}' is outside sandbox root '{}'",
            absolute.display(),
            canonical_root.display()
        ));
    }

    let filename = absolute.file_name().ok_or_else(|| {
        format!(
            "agent memory path '{}' does not contain a final file name",
            absolute.display()
        )
    })?;
    Ok(canonical_parent.join(filename))
}

fn atomic_write(path: &Path, bytes: &[u8]) -> Result<(), String> {
    let parent = path.parent().ok_or_else(|| {
        format!(
            "agent memory path '{}' does not have a parent directory",
            path.display()
        )
    })?;
    let timestamp = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|duration| duration.as_nanos())
        .unwrap_or(0);
    let temp_path = parent.join(format!(
        ".{}.agent-tmp-{}-{}",
        path.file_name()
            .and_then(|value| value.to_str())
            .unwrap_or("memory"),
        std::process::id(),
        timestamp
    ));

    std::fs::write(&temp_path, bytes).map_err(|error| error.to_string())?;
    match std::fs::rename(&temp_path, path) {
        Ok(()) => Ok(()),
        Err(rename_error) => {
            let _ = std::fs::remove_file(path);
            std::fs::rename(&temp_path, path).map_err(|fallback_error| {
                format!(
                    "agent memory atomic rename failed: {}; fallback rename failed: {}",
                    rename_error, fallback_error
                )
            })
        }
    }
}
