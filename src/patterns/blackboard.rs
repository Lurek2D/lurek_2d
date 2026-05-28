//! Shared key-value store for passing typed state between AI and game systems.
//!
//! - Data type: `Blackboard`.
//! - Enum: `BlackboardValue`.

use crate::log_msg;
use crate::runtime::log_messages::{BB01, BB02, BB03};
use std::collections::HashMap;
use std::fmt;
/// Typed value stored in a `Blackboard` entry.
#[derive(Debug, Clone, PartialEq)]
pub enum BlackboardValue {
    /// Boolean flag.
    Bool(bool),
    /// Floating-point number.
    Number(f64),
    /// UTF-8 text.
    Text(String),
    /// Explicit absent value.
    Nil,
}
/// Human-readable string formatting for `BlackboardValue`.
impl fmt::Display for BlackboardValue {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            BlackboardValue::Bool(b) => write!(f, "{b}"),
            BlackboardValue::Number(n) => write!(f, "{n}"),
            BlackboardValue::Text(s) => write!(f, "{s}"),
            BlackboardValue::Nil => write!(f, "nil"),
        }
    }
}
/// Shared key-value store with revision tracking and optional parent hierarchy.
///
/// Used as the canonical blackboard type by both `crate::patterns` and `crate::ai`.
/// The patterns layer provides structural storage and revision tracking.
/// The AI layer adds runtime parent-chain semantics via [`set_parent`](Blackboard::set_parent).
#[derive(Debug, Clone)]
pub struct Blackboard {
    /// Debug name for the board instance.
    pub name: String,
    /// Monotonically increasing counter incremented on every write.
    pub revision: u64,
    /// Typed key-value store.
    data: HashMap<String, BlackboardValue>,
    /// Per-key revision at the last write for change detection.
    key_revisions: HashMap<String, u64>,
    /// Optional parent board consulted when a key is absent locally.
    pub(crate) parent: Option<Box<Blackboard>>,
}
/// Read and write methods for `Blackboard`.
impl Blackboard {
    /// Create an empty blackboard with `name`.
    pub fn new(name: &str) -> Self {
        log_msg!(debug, BB01);
        Self {
            name: name.to_string(),
            revision: 0,
            data: HashMap::new(),
            key_revisions: HashMap::new(),
            parent: None,
        }
    }
    /// Write a `bool` to `key`, advancing revision counters.
    pub fn set_bool(&mut self, key: &str, value: bool) {
        self.revision += 1;
        self.key_revisions.insert(key.to_string(), self.revision);
        self.data
            .insert(key.to_string(), BlackboardValue::Bool(value));
    }
    /// Write a `f64` to `key`, advancing revision counters.
    pub fn set_number(&mut self, key: &str, value: f64) {
        self.revision += 1;
        self.key_revisions.insert(key.to_string(), self.revision);
        self.data
            .insert(key.to_string(), BlackboardValue::Number(value));
    }
    /// Write a `String` to `key`, advancing revision counters.
    pub fn set_text(&mut self, key: &str, value: String) {
        self.revision += 1;
        self.key_revisions.insert(key.to_string(), self.revision);
        self.data
            .insert(key.to_string(), BlackboardValue::Text(value));
    }
    /// Write a string to `key` (convenience wrapper over [`set_text`](Self::set_text)).
    pub fn set_string(&mut self, key: &str, value: &str) {
        self.set_text(key, value.to_string());
    }
    /// Remove a single `key` and advance revision counters.
    pub fn remove(&mut self, key: &str) {
        log_msg!(trace, BB02, "{}", key);
        self.revision += 1;
        self.key_revisions.insert(key.to_string(), self.revision);
        self.data.remove(key);
    }
    /// Return the raw value for `key`, or `None` if not set locally.
    pub fn get(&self, key: &str) -> Option<&BlackboardValue> {
        self.data.get(key)
    }
    /// Read a `Number` by key; walks the parent chain, returns `default` if absent.
    pub fn get_number(&self, key: &str, default: f64) -> f64 {
        if let Some(BlackboardValue::Number(v)) = self.data.get(key) {
            return *v;
        }
        if let Some(ref parent) = self.parent {
            return parent.get_number(key, default);
        }
        default
    }
    /// Read a `Bool` by key; walks the parent chain, returns `default` if absent.
    pub fn get_bool(&self, key: &str, default: bool) -> bool {
        if let Some(BlackboardValue::Bool(v)) = self.data.get(key) {
            return *v;
        }
        if let Some(ref parent) = self.parent {
            return parent.get_bool(key, default);
        }
        default
    }
    /// Read a `Text` by key; walks the parent chain, returns `default` if absent.
    pub fn get_string(&self, key: &str, default: &str) -> String {
        if let Some(BlackboardValue::Text(v)) = self.data.get(key) {
            return v.clone();
        }
        if let Some(ref parent) = self.parent {
            return parent.get_string(key, default);
        }
        default.to_string()
    }
    /// Return all local keys as owned strings.
    pub fn keys(&self) -> Vec<String> {
        self.data.keys().cloned().collect()
    }
    /// Return all `(key, value)` pairs as a vector (local entries only).
    pub fn snapshot(&self) -> Vec<(&str, &BlackboardValue)> {
        self.data.iter().map(|(k, v)| (k.as_str(), v)).collect()
    }
    /// Return true when `key` is set locally or in any ancestor.
    pub fn has(&self, key: &str) -> bool {
        if self.data.contains_key(key) {
            return true;
        }
        if let Some(ref parent) = self.parent {
            return parent.has(key);
        }
        false
    }
    /// Return the global revision at which `key` was last written, or `0` if never written.
    pub fn key_revision(&self, key: &str) -> u64 {
        self.key_revisions.get(key).copied().unwrap_or(0)
    }
    /// Remove all local keys and advance the global revision.
    pub fn clear(&mut self) {
        let count = self.data.len();
        self.revision += 1;
        self.data.clear();
        self.key_revisions.clear();
        log_msg!(debug, BB03, "{}", count);
    }
    /// Alias for [`clear`](Self::clear).
    pub fn clear_all(&mut self) {
        self.clear();
    }
    /// Return the number of local entries currently set.
    pub fn len(&self) -> usize {
        self.data.len()
    }
    /// Alias for [`len`](Self::len).
    pub fn size(&self) -> usize {
        self.data.len()
    }
    /// Return true when no local keys are set.
    pub fn is_empty(&self) -> bool {
        self.data.is_empty()
    }
    /// Attach a parent board; looked up when a local key is missing.
    pub fn set_parent(&mut self, parent: Blackboard) {
        self.parent = Some(Box::new(parent));
    }
    /// Return a reference to the parent board, or `None` if none is set.
    pub fn parent(&self) -> Option<&Blackboard> {
        self.parent.as_deref()
    }
}
/// `Default` creates an anonymous empty blackboard.
impl Default for Blackboard {
    fn default() -> Self {
        Self {
            name: String::new(),
            revision: 0,
            data: HashMap::new(),
            key_revisions: HashMap::new(),
            parent: None,
        }
    }
}
