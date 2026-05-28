//! Core type definitions for the province map system.
//!
//! - ProvinceId newtype, BorderType (u8) for game-defined adjacency classification, and ProvinceStyle for per-province visuals.
//! - ProvinceSnapshot provides an immutable point-in-time view of province state.

use std::collections::HashMap;

/// Unique identifier for a province in the map system; 0 is reserved for "no province" / ocean pixels.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
pub struct ProvinceId(pub u32);

impl ProvinceId {
    /// Creates a new ProvinceId from a raw u32.
    pub fn new(id: u32) -> Self { Self(id) }
    /// Returns the raw u32 underlying value.
    pub fn raw(self) -> u32 { self.0 }
}

impl std::fmt::Display for ProvinceId {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.0)
    }
}

impl From<u32> for ProvinceId {
    fn from(v: u32) -> Self { Self(v) }
}

impl From<ProvinceId> for u32 {
    fn from(id: ProvinceId) -> Self { id.0 }
}

/// Game-defined border type identifier. Games register types via `registerBorderType` from Lua.
pub type BorderType = u8;

/// Per border-type visual config, registered from Lua at runtime.
#[derive(Debug, Clone, PartialEq)]
pub struct BorderTypeConfig {
    /// Display name for this border type (e.g. "land", "coast", "river").
    pub name: String,
    /// RGBA color for borders of this type.
    pub color: [f32; 4],
    /// Line thickness in map pixels.
    pub thickness: f32,
    /// Draw priority; higher values render on top.
    pub draw_priority: u8,
}

/// Bit-flag set controlling semantic styling of a border pair override.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Default)]
pub struct BorderPairFlags {
    bits: u8,
}

impl BorderPairFlags {
    /// Country border visual marker.
    pub const COUNTRY: u8 = 0x01;
    /// Alliance border visual marker.
    pub const ALLIANCE: u8 = 0x02;
    /// War state border visual flag marker.
    pub const WAR: u8 = 0x04;
    /// Truce state border visual flag marker.
    pub const TRUCE: u8 = 0x08;

    /// Create a new empty border flag set.
    pub fn empty() -> Self {
        Self { bits: 0 }
    }

    /// Return the raw flag bit pattern.
    pub fn bits(self) -> u8 {
        self.bits
    }

    /// Build a flag set from raw bits.
    pub fn from_bits(bits: u8) -> Self {
        Self { bits }
    }

    /// Insert a raw flag bitmask into this set.
    pub fn insert_bits(&mut self, mask: u8) {
        self.bits |= mask;
    }

    /// Return true if all bits from mask are present.
    pub fn contains_bits(self, mask: u8) -> bool {
        (self.bits & mask) == mask
    }

    /// Parse a single canonical flag token.
    pub fn parse_token(token: &str) -> Option<u8> {
        match token {
            "country" => Some(Self::COUNTRY),
            "alliance" => Some(Self::ALLIANCE),
            "war" => Some(Self::WAR),
            "truce" => Some(Self::TRUCE),
            _ => None,
        }
    }

    /// Return canonical tokens for all set bits.
    pub fn to_tokens(self) -> Vec<&'static str> {
        let mut out = Vec::new();
        if self.contains_bits(Self::COUNTRY) {
            out.push("country");
        }
        if self.contains_bits(Self::ALLIANCE) {
            out.push("alliance");
        }
        if self.contains_bits(Self::WAR) {
            out.push("war");
        }
        if self.contains_bits(Self::TRUCE) {
            out.push("truce");
        }
        out
    }
}

/// Per-adjacency border style override keyed by ordered province pair.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct BorderPairStyle {
    /// Optional RGBA color override. When None, renderer uses the class default color.
    pub color: Option<[f32; 4]>,
    /// Line width in map pixels for this border pair.
    pub thickness: f32,
    /// Semantic flags (country/alliance/war/truce) used for mode filtering.
    pub flags: BorderPairFlags,
}

impl Default for BorderPairStyle {
    fn default() -> Self {
        Self {
            color: None,
            thickness: 1.0,
            flags: BorderPairFlags::empty(),
        }
    }
}

/// Visual and gameplay state attached to a single province, stored in ProvinceRegistry.
#[derive(Debug, Clone, PartialEq)]
pub struct ProvinceStyle {
    /// RGBA fill colour used in political map mode; default grey [0.5, 0.5, 0.5, 1.0].
    pub political_color: [f32; 4],
    /// Terrain index: 0 = water/sea, non-zero = land class.
    pub terrain_type: u32,
    /// Border style index forwarded to the renderer for line variant selection.
    pub border_style: u32,
    /// Fog-of-war state byte; 0 = fully fogged.
    pub fog_state: u8,
    /// Visibility state byte; 0 = hidden, 1 = discovered, 2+ = fully visible.
    pub visibility_state: u8,
}

/// Default ProvinceStyle: grey political color, water terrain, no fog, visible.
impl Default for ProvinceStyle {
    fn default() -> Self {
        Self {
            political_color: [0.5, 0.5, 0.5, 1.0],
            terrain_type: 0,
            border_style: 0,
            fog_state: 0,
            visibility_state: 2,
        }
    }
}

/// Immutable point-in-time view of a province returned by ProvinceRegistry::get_province.
#[derive(Debug, Clone, PartialEq)]
pub struct ProvinceSnapshot {
    /// Identifier of the province this snapshot describes.
    pub province_id: ProvinceId,
    /// Visual and gameplay style at snapshot time.
    pub style: ProvinceStyle,
    /// Registry revision counter at the time of snapshot creation.
    pub revision: u64,
    /// Weighted pixel centroid; None if province has no spans.
    pub centroid: Option<(f32, f32)>,
    /// Arbitrary key-value metadata set via set_attr.
    pub attrs: HashMap<String, String>,
}
