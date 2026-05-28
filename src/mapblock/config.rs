//! Map block generator configuration: grid dimensions, seed, and global assembly rules.
//!
//! - Data types: `MapBlockConfig`, `SlotDef`.
//! - Implementation: `MapBlockConfig`.

/// Configuration defining which tile slots exist in a map block system.
///
/// Slots are user-defined (not hardcoded). Defaults: floor, roof, object, left_wall, right_wall.
#[derive(Debug, Clone)]
pub struct MapBlockConfig {
    /// Slot definitions — order matters for rendering.
    pub slots: Vec<SlotDef>,
    /// Maximum number of layers per block (1..=10).
    pub max_layers: u32,
    /// Default segment size for blocks.
    pub default_segment_size: u32,
}

/// A single slot definition within a tile.
#[derive(Debug, Clone)]
pub struct SlotDef {
    /// Slot name (e.g. "floor", "roof", "object").
    pub name: String,
    /// Whether this slot is required (must have a value) or optional.
    pub required: bool,
    /// Default GID when slot is empty (0 = transparent/none).
    pub default_gid: u32,
}

impl MapBlockConfig {
    /// Create a new config with default slots: floor, roof, object, left_wall, right_wall.
    pub fn new() -> Self {
        Self {
            slots: vec![
                SlotDef {
                    name: "floor".to_string(),
                    required: false,
                    default_gid: 0,
                },
                SlotDef {
                    name: "roof".to_string(),
                    required: false,
                    default_gid: 0,
                },
                SlotDef {
                    name: "object".to_string(),
                    required: false,
                    default_gid: 0,
                },
                SlotDef {
                    name: "left_wall".to_string(),
                    required: false,
                    default_gid: 0,
                },
                SlotDef {
                    name: "right_wall".to_string(),
                    required: false,
                    default_gid: 0,
                },
            ],
            max_layers: 10,
            default_segment_size: 8,
        }
    }

    /// Create an empty config with no predefined slots.
    pub fn empty() -> Self {
        Self {
            slots: Vec::new(),
            max_layers: 10,
            default_segment_size: 8,
        }
    }

    /// Add a custom slot definition.
    pub fn add_slot(&mut self, name: &str, required: bool, default_gid: u32) {
        self.slots.push(SlotDef {
            name: name.to_string(),
            required,
            default_gid,
        });
    }

    /// Remove a slot by name. Returns true if found and removed.
    pub fn remove_slot(&mut self, name: &str) -> bool {
        let len_before = self.slots.len();
        self.slots.retain(|s| s.name != name);
        self.slots.len() < len_before
    }

    /// Get the position index of a named slot.
    pub fn slot_index(&self, name: &str) -> Option<usize> {
        self.slots.iter().position(|s| s.name == name)
    }

    /// Get the number of defined slots.
    pub fn slot_count(&self) -> usize {
        self.slots.len()
    }

    /// Set maximum layers per block.
    pub fn set_max_layers(&mut self, max: u32) {
        self.max_layers = max.clamp(1, 10);
    }

    /// Set the default edge segment size.
    pub fn set_default_segment_size(&mut self, size: u32) {
        self.default_segment_size = size.max(1);
    }
}

impl Default for MapBlockConfig {
    fn default() -> Self {
        Self::new()
    }
}
