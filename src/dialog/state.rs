//! Dialog FSM state: tracks the current node, visited history, and variable bindings.
//!
//! - Data type: `DialogueState`.
//! - Implementation: `DialogueState`.

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
