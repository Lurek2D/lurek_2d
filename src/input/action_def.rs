//! Defines action-binding data shapes used to map logical actions onto multiple physical inputs. `input/action_def` delivers the action def implementation for the input subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Stores ordered binding strings and optional category grouping for tooling and menu presentation. The file owns or coordinates data contracts including `ActionDef`, `ActionMap`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Provides serializable action-map structures for loading, saving, and sharing binding presets. Public callable behavior is centered on no named public items, while method-level behavior such as `new` stays attached to the local data model and invariants.

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
