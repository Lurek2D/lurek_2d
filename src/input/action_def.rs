//! Action definition types for the extended action-binding system.
//! - Defines ActionDef with bindings and a grouping category string.
//! - Provides ActionMap type alias for the full action map.
//! - Derives Serialize/Deserialize for JSON round-trip via serializeBindings and deserializeBindings.

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
