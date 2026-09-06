//! Owns the province types implementation for the province subsystem and keeps related runtime rules local here.
//! Keeps province data, render helpers, and map-facing transforms so helpers stay close to invariants this file updates.
//! Defines how province types data is validated, transformed, or stored before neighboring systems consume it.
//! Separates province types behavior from Lua bindings, tests, and sibling owners so integration stays readable.
//! Documents the boundary where province code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing province types defaults, lifecycle handling, validation, or data ownership rules.
//! Keeps failure paths and edge cases near the province types state that explains them instead of spreading rules outward.

use std::collections::HashMap;

/// Authoring geometry used by a province registry.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ProvinceGeometryKind {
    /// Dense cell IDs extracted from a color-coded image.
    Raster,
    /// Authored polygon components imported from Tiled.
    Polygon,
}

impl ProvinceGeometryKind {
    /// Return the stable Lua-facing name for this geometry kind.
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Raster => "raster",
            Self::Polygon => "polygon",
        }
    }
}

/// Unique identifier for a province in the map system; 0 is reserved for "no province" / ocean pixels.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
pub struct ProvinceId(pub u32);

impl ProvinceId {
    /// Creates a new ProvinceId from a raw u32.
    pub fn new(id: u32) -> Self {
        Self(id)
    }
    /// Returns the raw u32 underlying value.
    pub fn raw(self) -> u32 {
        self.0
    }
}

impl std::fmt::Display for ProvinceId {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.0)
    }
}

impl From<u32> for ProvinceId {
    fn from(v: u32) -> Self {
        Self(v)
    }
}

impl From<ProvinceId> for u32 {
    fn from(id: ProvinceId) -> Self {
        id.0
    }
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

/// Built-in climate ids used by province-map shading when Lua passes symbolic names.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u16)]
pub enum ProvinceClimateKind {
    /// No climate tinting.
    None = 0,
    /// Open-ocean or sea province.
    Ocean = 1,
    /// Cold polar climate.
    Arctic = 2,
    /// Transitional cold climate.
    Subarctic = 3,
    /// Mild default climate.
    Temperate = 4,
    /// Inland seasonal climate.
    Continental = 5,
    /// Hot wet climate.
    Tropical = 6,
    /// Dry arid or desert climate.
    Arid = 7,
    /// Dry grassland climate.
    Steppe = 8,
    /// High-altitude climate.
    Mountain = 9,
    /// Sparse or inhospitable climate.
    Wasteland = 10,
}

impl ProvinceClimateKind {
    /// Parse a built-in climate token used by Lua convenience APIs.
    pub fn from_name(name: &str) -> Option<Self> {
        match name {
            "none" => Some(Self::None),
            "ocean" => Some(Self::Ocean),
            "arctic" => Some(Self::Arctic),
            "subarctic" | "sub_arctic" | "sub-arctic" => Some(Self::Subarctic),
            "temperate" => Some(Self::Temperate),
            "continental" => Some(Self::Continental),
            "tropical" => Some(Self::Tropical),
            "arid" | "desert" | "arid_desert" | "arid-desert" => Some(Self::Arid),
            "steppe" => Some(Self::Steppe),
            "mountain" => Some(Self::Mountain),
            "wasteland" => Some(Self::Wasteland),
            _ => None,
        }
    }

    /// Return the compact numeric id used in GPU records.
    pub fn id(self) -> u16 {
        self as u16
    }
}

/// Built-in weather ids used by province-map shading when Lua passes symbolic names.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u16)]
pub enum ProvinceWeatherKind {
    /// No weather overlay.
    None = 0,
    /// Diagonal rain streaks and darker tint.
    Rain = 1,
    /// Snow accumulation and bright speckle.
    Snow = 2,
    /// Storm darkening plus deterministic flashes.
    Storm = 3,
    /// Low-frequency fog or mist overlay.
    Fog = 4,
    /// Warm directional dust or sand overlay.
    Sandstorm = 5,
    /// Tactical-zoom heat distortion.
    HeatHaze = 6,
    /// Ash or smoke tint overlay.
    Ash = 7,
}

impl ProvinceWeatherKind {
    /// Parse a built-in weather token used by Lua convenience APIs.
    pub fn from_name(name: &str) -> Option<Self> {
        match name {
            "none" => Some(Self::None),
            "rain" => Some(Self::Rain),
            "snow" => Some(Self::Snow),
            "storm" => Some(Self::Storm),
            "fog" | "mist" => Some(Self::Fog),
            "sandstorm" | "dust" => Some(Self::Sandstorm),
            "heat_haze" | "heat-haze" | "heat haze" => Some(Self::HeatHaze),
            "ash" | "smoke" => Some(Self::Ash),
            _ => None,
        }
    }

    /// Return the compact numeric id used in GPU records.
    pub fn id(self) -> u16 {
        self as u16
    }
}

/// Province visual-effect bit for animated water or coastal shimmer.
pub const PROVINCE_EFFECT_WAVES: u32 = 0x01;
/// Province visual-effect bit for stronger conflict/frontline highlight.
pub const PROVINCE_EFFECT_CONFLICT: u32 = 0x02;
/// Province visual-effect bit for additional fog-noise treatment.
pub const PROVINCE_EFFECT_FOG_NOISE: u32 = 0x04;
/// Province visual-effect bit for explicit heat-haze emphasis.
pub const PROVINCE_EFFECT_HEAT_HAZE: u32 = 0x08;
/// Province visual-effect bit for coastal foam emphasis.
pub const PROVINCE_EFFECT_COAST_FOAM: u32 = 0x10;
/// Province visual-effect bit for diagonal hatch or occupation stripes.
pub const PROVINCE_EFFECT_STRIPES: u32 = 0x20;

/// Parse a canonical province visual-effect flag token into a bitmask.
pub fn parse_province_effect_flag_token(token: &str) -> Option<u32> {
    match token {
        "waves" => Some(PROVINCE_EFFECT_WAVES),
        "conflict" | "frontline" | "alert" => Some(PROVINCE_EFFECT_CONFLICT),
        "fog_noise" | "fog-noise" | "mist" => Some(PROVINCE_EFFECT_FOG_NOISE),
        "heat_haze" | "heat-haze" | "heat haze" => Some(PROVINCE_EFFECT_HEAT_HAZE),
        "coast_foam" | "coast-foam" | "foam" => Some(PROVINCE_EFFECT_COAST_FOAM),
        "stripe" | "stripes" | "hatch" | "hatched" => Some(PROVINCE_EFFECT_STRIPES),
        _ => None,
    }
}

/// Compact shader-facing visual state attached to a province without owning gameplay simulation.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct ProvinceVisualState {
    /// Climate classification id; 0 disables climate tinting.
    pub climate_type: u16,
    /// Weather classification id; 0 disables weather overlays.
    pub weather_type: u16,
    /// Overlay strength in the normalized [0, 1] range.
    pub weather_strength: f32,
    /// Semantic effect flags such as waves, fog noise, or heat haze.
    pub effect_flags: u32,
    /// Deterministic seed used by map shader noise for this province.
    pub visual_seed: u32,
}

impl Default for ProvinceVisualState {
    fn default() -> Self {
        Self {
            climate_type: ProvinceClimateKind::None.id(),
            weather_type: ProvinceWeatherKind::None.id(),
            weather_strength: 0.0,
            effect_flags: 0,
            visual_seed: 0,
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
    /// Optional shader-oriented climate, weather, and effect metadata.
    pub visual_state: ProvinceVisualState,
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
            visual_state: ProvinceVisualState::default(),
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
    /// Capital marker imported from marker metadata; None if province has no capital.
    pub capital: Option<(f32, f32)>,
    /// Arbitrary key-value metadata set via set_attr.
    pub attrs: HashMap<String, String>,
}
