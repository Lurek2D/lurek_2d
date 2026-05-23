//! - Core type definitions for the province map system.
//! - ProvinceId alias, BorderClass enum for adjacency classification, and ProvinceStyle for per-province visuals.
//! - ProvinceSnapshot provides an immutable point-in-time view of province state.

use std::collections::HashMap;

/// Numeric identifier for a province; 0 is reserved for "no province" / ocean pixels.
pub type ProvinceId = u32;

/// Classification of the terrain relationship across a shared border.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum BorderClass {
    /// Border between two land provinces.
    LandLand,
    /// Border between a land and a sea province.
    Coast,
    /// Border between two sea provinces.
    SeaSea,
    /// Manually flagged border; renderer applies a distinct colour.
    Special,
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
    /// War border visual marker.
    pub const WAR: u8 = 0x04;
    /// Truce border visual marker.
    pub const TRUCE: u8 = 0x08;

    /// Create an empty flag set.
    pub fn empty() -> Self {
        Self { bits: 0 }
    }

    /// Return the raw bit pattern.
    pub fn bits(self) -> u8 {
        self.bits
    }

    /// Build a flag set from raw bits.
    pub fn from_bits(bits: u8) -> Self {
        Self { bits }
    }

    /// Insert a raw flag mask.
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

impl BorderClass {
    /// Return the canonical string token used in TOML and CSV exports.
    pub fn as_str(self) -> &'static str {
        match self {
            BorderClass::LandLand => "land_land",
            BorderClass::Coast => "coast",
            BorderClass::SeaSea => "sea_sea",
            BorderClass::Special => "special",
        }
    }

    /// Parse a string token back to a variant; return None on unknown input.
    pub fn parse_str(value: &str) -> Option<Self> {
        match value {
            "land_land" => Some(BorderClass::LandLand),
            "coast" => Some(BorderClass::Coast),
            "sea_sea" => Some(BorderClass::SeaSea),
            "special" => Some(BorderClass::Special),
            _ => None,
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
