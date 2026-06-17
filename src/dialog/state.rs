//! Provides mutable dialogue runtime state that tracks active position, visit history, and per-run variables. `dialog/state` delivers the state container and transition helpers for the dialog subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Supports conversation lifecycle transitions for start, advance, end, and subsequent re-entry handling. The file owns or coordinates data contracts including `DialogueState`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Preserves continuity data in a compact snapshot that dependent systems can query every frame. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `start`, `advance`, `end`, `current`, `has_visited`, and 5 more stays attached to the local data model and invariants.
//! Delivers the authoritative progression record used to keep branching dialogue behavior coherent over time. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

use std::collections::{HashMap, HashSet};

/// Tracks the current state of an active dialog conversation.
#[derive(Debug, Clone)]
pub struct DialogueState {
    /// ID of the current node being displayed.
    current_node: Option<String>,
    /// Set of visited node IDs.
    visited: HashSet<String>,
    /// Named variables stored during conversation.
    variables: HashMap<String, String>,
    /// Whether the conversation is active.
    active: bool,
}

impl DialogueState {
    /// Create a new inactive dialogue state.
    pub fn new() -> Self {
        Self {
            current_node: None,
            visited: HashSet::new(),
            variables: HashMap::new(),
            active: false,
        }
    }

    /// Start a conversation at the given node.
    pub fn start(&mut self, node_id: impl Into<String>) {
        let id = node_id.into();
        self.current_node = Some(id.clone());
        self.visited.insert(id);
        self.active = true;
    }

    /// Advance the conversation to a new dialog node.
    pub fn advance(&mut self, node_id: impl Into<String>) {
        let id = node_id.into();
        self.current_node = Some(id.clone());
        self.visited.insert(id);
    }

    /// End the active conversation and clear current node.
    pub fn end(&mut self) {
        self.active = false;
        self.current_node = None;
    }

    /// Get the current active dialog node ID.
    pub fn current(&self) -> Option<&str> {
        self.current_node.as_deref()
    }

    /// Check if a node has been visited.
    pub fn has_visited(&self, node_id: &str) -> bool {
        self.visited.contains(node_id)
    }

    /// Get the number of visited nodes.
    pub fn visit_count(&self) -> usize {
        self.visited.len()
    }

    /// Whether conversation is active.
    pub fn is_active(&self) -> bool {
        self.active
    }

    /// Set a conversation variable.
    pub fn set_variable(&mut self, key: impl Into<String>, value: impl Into<String>) {
        self.variables.insert(key.into(), value.into());
    }

    /// Get a conversation variable.
    pub fn get_variable(&self, key: &str) -> Option<&str> {
        self.variables.get(key).map(|s| s.as_str())
    }

    /// Reset all conversation state and variables.
    pub fn reset(&mut self) {
        self.current_node = None;
        self.visited.clear();
        self.variables.clear();
        self.active = false;
    }
}

impl Default for DialogueState {
    fn default() -> Self {
        Self::new()
    }
}
