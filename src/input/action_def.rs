//! Defines action-binding data shapes used to map logical actions onto multiple physical inputs.
//! Stores ordered binding strings and optional category grouping for tooling and menu presentation.
//! Provides serializable action-map structures for loading, saving, and sharing binding presets.

use serde::{Deserialize, Serialize};
use std::collections::HashMap;

/// Extended action definition with ordered binding strings and a grouping category.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ActionDef {
    /// Binding strings such as `"space"` or `"gamepad:0:1"`.
    pub bindings: Vec<String>,
    /// User category for grouping actions; empty string when uncategorised.
    pub category: String,
}

impl ActionDef {
    /// Creates an action definition with the given bindings and category.
    pub fn new(bindings: Vec<String>, category: String) -> Self {
        Self { bindings, category }
    }
}

impl Default for ActionDef {
    /// Returns an empty action definition with no bindings and no category.
    fn default() -> Self {
        Self {
            bindings: Vec::new(),
            category: String::new(),
        }
    }
}

/// Full action map from action name to its extended definition.
pub type ActionMap = HashMap<String, ActionDef>;
