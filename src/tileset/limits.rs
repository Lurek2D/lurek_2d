//! Owns conservative allocation and numeric ceilings for atlas-local tileset metadata.
//!
//! These limits are deliberately tileset-specific. They are not borrowed from `tilemap`,
//! because a tileset has different hostile-input risks: atlas arithmetic, nested author
//! records, rule tables, and copied catalog snapshots all need independent bounds.

/// Conservative limits applied to one tileset and its nested author metadata.
///
/// # Fields
///
/// The fields cover atlas geometry, nested metadata counts, string sizes, and
/// finite author numeric defaults.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct TilesetLimits {
    /// Maximum number of local tile entries.
    pub max_tile_count: u32,
    /// Maximum atlas column count.
    pub max_columns: u32,
    /// Maximum computed atlas width or height in pixels.
    pub max_atlas_dimension: u32,
    /// Maximum spacing in pixels.
    pub max_spacing: u32,
    /// Maximum margin in pixels.
    pub max_margin: u32,
    /// Maximum number of object archetypes.
    pub max_archetypes: usize,
    /// Maximum number of tileset catalog entries.
    pub max_catalog_entries: usize,
    /// Maximum custom properties on one tile or archetype.
    pub max_properties_per_owner: usize,
    /// Maximum total custom properties in one tileset.
    pub max_total_properties: usize,
    /// Maximum animation sequences in one tileset.
    pub max_animation_sequences: usize,
    /// Maximum frames in one animation sequence.
    pub max_animation_frames: usize,
    /// Maximum four-neighbor autotile rules.
    pub max_autotile_rules_4: usize,
    /// Maximum eight-neighbor autotile rules.
    pub max_autotile_rules_8: usize,
    /// Maximum named terrain profiles.
    pub max_terrain_profiles: usize,
    /// Maximum bytes in an author-facing name.
    pub max_name_bytes: usize,
    /// Maximum bytes in a custom string value or opaque enum-like string.
    pub max_string_bytes: usize,
    /// Maximum footprint width or height in cells.
    pub max_footprint_dimension: u32,
    /// Maximum finite magnitude for author numeric defaults.
    pub max_numeric_value: f32,
}

impl Default for TilesetLimits {
    fn default() -> Self {
        Self {
            max_tile_count: 1_000_000,
            max_columns: 65_536,
            max_atlas_dimension: 16_777_216,
            max_spacing: 65_536,
            max_margin: 65_536,
            max_archetypes: 65_536,
            max_catalog_entries: 65_536,
            max_properties_per_owner: 256,
            max_total_properties: 1_000_000,
            max_animation_sequences: 1_000_000,
            max_animation_frames: 256,
            max_autotile_rules_4: 65_536,
            max_autotile_rules_8: 65_536,
            max_terrain_profiles: 65_536,
            max_name_bytes: 256,
            max_string_bytes: 4_096,
            max_footprint_dimension: 4_096,
            max_numeric_value: 1_000_000.0,
        }
    }
}
