//! Config-driven map mode system for the province renderer.
//!
//! - Map modes are registered from Lua at runtime with per-mode display settings.
//! - Color resolution uses the color_property field from the active map mode config.

use std::collections::HashMap;

use crate::province::types::ProvinceStyle;

/// Configuration for a named map display mode, registered from Lua.
#[derive(Debug, Clone, PartialEq)]
pub struct MapModeConfig {
    /// Display name of the map mode.
    pub name: String,
    /// Whether province text labels are shown in this mode.
    pub show_labels: bool,
    /// Whether border lines are drawn in this mode.
    pub show_borders: bool,
    /// Whether adjacency roads are drawn in this mode.
    pub show_roads: bool,
    /// Whether capital markers are drawn in this mode.
    pub show_capitals: bool,
    /// Whether numeric values are overlaid on provinces.
    pub show_values: bool,
    /// Which province property drives numeric overlay (if show_values = true).
    pub value_property: Option<String>,
    /// Which province property drives fill color (looked up via ProvinceProperties).
    pub color_property: Option<String>,
    /// Fog-of-war intensity multiplier for this mode (0.0 = no fog, 1.0 = full).
    pub fog_intensity: f32,
    /// Which border types to display (empty = show all).
    pub border_filter: Vec<u8>,
}

impl Default for MapModeConfig {
    fn default() -> Self {
        Self {
            name: "political".to_string(),
            show_labels: true,
            show_borders: true,
            show_roads: true,
            show_capitals: true,
            show_values: false,
            value_property: None,
            color_property: None,
            fog_intensity: 1.0,
            border_filter: Vec::new(),
        }
    }
}

/// Registry of map modes, keyed by name string.
#[derive(Debug, Clone)]
pub struct MapModeRegistry {
    modes: HashMap<String, MapModeConfig>,
    active: String,
}

impl Default for MapModeRegistry {
    fn default() -> Self {
        let mut modes = HashMap::new();
        modes.insert("political".to_string(), MapModeConfig::default());
        Self {
            modes,
            active: "political".to_string(),
        }
    }
}

impl MapModeRegistry {
    /// Create a new registry with a default "political" mode.
    pub fn new() -> Self {
        Self::default()
    }

    /// Register a named map mode config. Overwrites existing config for same name.
    pub fn register(&mut self, name: &str, config: MapModeConfig) {
        self.modes.insert(name.to_string(), config);
    }

    /// Set the active map mode by name. Returns true if mode exists.
    pub fn set_active(&mut self, name: &str) -> bool {
        if self.modes.contains_key(name) {
            self.active = name.to_string();
            true
        } else {
            false
        }
    }

    /// Get the currently active map mode name.
    pub fn active_name(&self) -> &str {
        &self.active
    }

    /// Get the active map mode config.
    pub fn active_config(&self) -> &MapModeConfig {
        self.modes.get(&self.active).unwrap_or_else(|| {
            self.modes.get("political").expect("political mode must exist")
        })
    }

    /// Get config for a named map mode.
    pub fn get_config(&self, name: &str) -> Option<&MapModeConfig> {
        self.modes.get(name)
    }

    /// List all registered mode names.
    pub fn mode_names(&self) -> Vec<&str> {
        self.modes.keys().map(|k| k.as_str()).collect()
    }
}

/// Resolve fill colour for a province given the active mode's config and the province style.
/// If color_property is set, the caller should look it up via ProvinceProperties.
/// This fallback provides basic color resolution when no color_property is configured.
pub fn resolve_color_fallback(_config: &MapModeConfig, style: &ProvinceStyle) -> [f32; 4] {
    // When no color_property is defined, fall back to political color.
    // Future: use _config.color_property to look up from ProvinceProperties.
    style.political_color
}
