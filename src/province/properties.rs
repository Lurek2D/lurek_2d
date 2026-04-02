//! Custom province properties and state system.
//!
//! Provides a dynamic key-value store ([`ProvinceProperties`]) for arbitrary
//! per-province data, and a timed state system ([`ProvinceState`]) for
//! temporary effects like plague, fire, or winter.

use std::collections::HashMap;

/// A dynamic value that can be stored as a province property.
#[derive(Debug, Clone, PartialEq)]
pub enum ProvinceValue {
    /// Integer value.
    Int(i64),
    /// Floating-point value.
    Float(f64),
    /// String value.
    Str(String),
    /// Boolean value.
    Bool(bool),
}

/// Collection of custom key-value properties for a province.
#[derive(Debug, Clone, Default)]
pub struct ProvinceProperties {
    values: HashMap<String, ProvinceValue>,
}

impl ProvinceProperties {
    /// Create an empty property collection.
    pub fn new() -> Self {
        Self::default()
    }

    /// Set a property value, overwriting any existing value for the key.
    pub fn set(&mut self, key: impl Into<String>, value: ProvinceValue) {
        self.values.insert(key.into(), value);
    }

    /// Get a property value by key.
    pub fn get(&self, key: &str) -> Option<&ProvinceValue> {
        self.values.get(key)
    }

    /// Remove a property and return its value.
    pub fn remove(&mut self, key: &str) -> Option<ProvinceValue> {
        self.values.remove(key)
    }

    /// Iterate over all property keys.
    pub fn keys(&self) -> impl Iterator<Item = &String> {
        self.values.keys()
    }

    /// Extract the value as `f64` if the property is a [`ProvinceValue::Float`].
    pub fn get_float(&self, key: &str) -> Option<f64> {
        match self.values.get(key) {
            Some(ProvinceValue::Float(v)) => Some(*v),
            _ => None,
        }
    }

    /// Extract the value as `i64` if the property is a [`ProvinceValue::Int`].
    pub fn get_int(&self, key: &str) -> Option<i64> {
        match self.values.get(key) {
            Some(ProvinceValue::Int(v)) => Some(*v),
            _ => None,
        }
    }

    /// Extract the value as `&str` if the property is a [`ProvinceValue::Str`].
    pub fn get_str(&self, key: &str) -> Option<&str> {
        match self.values.get(key) {
            Some(ProvinceValue::Str(v)) => Some(v.as_str()),
            _ => None,
        }
    }

    /// Extract the value as an owned `String` if the property is a [`ProvinceValue::Str`].
    pub fn get_string(&self, key: &str) -> Option<String> {
        match self.values.get(key) {
            Some(ProvinceValue::Str(v)) => Some(v.clone()),
            _ => None,
        }
    }
}

/// A temporary state applied to a province (e.g., plague, fire, winter).
#[derive(Debug, Clone)]
pub struct ProvinceState {
    /// Name identifying this state type.
    pub name: String,
    /// Arbitrary data associated with the state.
    pub data: HashMap<String, ProvinceValue>,
    /// Duration in seconds. `None` means permanent.
    pub duration: Option<f32>,
    /// Elapsed time in seconds since the state was applied.
    pub elapsed: f32,
}

/// Manages all province properties and temporary states.
#[derive(Debug, Clone, Default)]
pub struct ProvinceData {
    properties: HashMap<u32, ProvinceProperties>,
    states: HashMap<u32, Vec<ProvinceState>>,
}

impl ProvinceData {
    /// Create an empty province data store.
    pub fn new() -> Self {
        Self::default()
    }

    /// Get the properties for a province, if any exist.
    pub fn get_properties(&self, id: u32) -> Option<&ProvinceProperties> {
        self.properties.get(&id)
    }

    /// Get or create the mutable properties for a province.
    pub fn get_properties_mut(&mut self, id: u32) -> &mut ProvinceProperties {
        self.properties.entry(id).or_default()
    }

    /// Set a single property on a province.
    pub fn set_property(&mut self, id: u32, key: impl Into<String>, value: ProvinceValue) {
        self.get_properties_mut(id).set(key, value);
    }

    /// Get a single property from a province.
    pub fn get_property(&self, id: u32, key: &str) -> Option<&ProvinceValue> {
        self.properties.get(&id).and_then(|p| p.get(key))
    }

    /// Add a temporary state to a province.
    pub fn add_state(&mut self, id: u32, state: ProvinceState) {
        self.states.entry(id).or_default().push(state);
    }

    /// Remove a state by name from a province. Returns `true` if it was found.
    pub fn remove_state(&mut self, id: u32, name: &str) -> bool {
        if let Some(states) = self.states.get_mut(&id) {
            let before = states.len();
            states.retain(|s| s.name != name);
            states.len() < before
        } else {
            false
        }
    }

    /// Check whether a province has a state with the given name.
    pub fn has_state(&self, id: u32, name: &str) -> bool {
        self.states
            .get(&id)
            .is_some_and(|states| states.iter().any(|s| s.name == name))
    }

    /// Get all active states on a province. Returns an empty slice if none.
    pub fn get_states(&self, id: u32) -> &[ProvinceState] {
        match self.states.get(&id) {
            Some(states) => states.as_slice(),
            None => &[],
        }
    }

    /// Tick all state durations and remove expired states.
    pub fn update_states(&mut self, dt: f32) {
        for states in self.states.values_mut() {
            for state in states.iter_mut() {
                state.elapsed += dt;
            }
            states.retain(|s| match s.duration {
                None => true,              // permanent — always keep
                Some(d) => s.elapsed < d,  // timed — keep while not expired
            });
        }
        // Clean up empty entries
        self.states.retain(|_, v| !v.is_empty());
    }
}
