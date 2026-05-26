//! Core data types for the globe subsystem: regions, markers, labels, arcs, and layers.
//!
//! - Region geometry with polygon vertices, centroids, adjacency, and per-edge tags.
//! - Render parameters via GlobeSpec: lighting, atmosphere, borders, rotation.
//! - Overlay and heat-map layers with per-region color overrides.
//! - Marker and label types with style, LOD gating, and pulse animation.
//! - Projection output types for screen-space rendering of regions and arcs.
//! - Globe-level error enum for load, lookup, and pathfinding failures.

use crate::math::Vec2;
use std::collections::{HashMap, HashSet};
/// Maximum region count supported by globe data structures.
pub const MAX_REGIONS: usize = 8192;
/// Unique identifier for a region on the globe.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
pub struct RegionId(pub u32);

impl RegionId {
    /// Creates a new RegionId from a raw u32.
    pub fn new(id: u32) -> Self { Self(id) }
    /// Returns the raw u32 underlying value.
    pub fn raw(self) -> u32 { self.0 }
}

impl std::fmt::Display for RegionId {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.0)
    }
}

impl From<u32> for RegionId {
    fn from(v: u32) -> Self { Self(v) }
}

impl From<RegionId> for u32 {
    fn from(id: RegionId) -> Self { id.0 }
}
/// Geographic region with polygon geometry, adjacency, and render attributes.
#[derive(Debug, Clone)]
pub struct Region {
    /// Stable region identifier.
    pub id: RegionId,
    /// Polygon vertices in latitude/longitude space.
    pub vertices: Vec<(f32, f32)>,
    /// Cached geographic centroid in latitude/longitude space.
    pub centroid: (f32, f32),
    /// Neighboring region ids for adjacency traversal.
    pub neighbors: Vec<RegionId>,
    /// Arbitrary string attributes attached to the region.
    pub attrs: HashMap<String, String>,
    /// Per-edge tags keyed by ordered region id pairs.
    pub edge_tags: HashMap<(RegionId, RegionId), HashSet<String>>,
    /// Optional texture name used when rendering the region.
    pub texture: Option<String>,
    /// Optional normalized texture rectangle in UV space.
    pub texture_uv_rect: Option<[f32; 4]>,
    /// Base RGBA color used when no overlay overrides it.
    pub base_color: [f32; 4],
}
impl Region {
    /// Create a region from vertices and derive a centroid from them.
    pub fn new(id: RegionId, vertices: Vec<(f32, f32)>) -> Self {
        let (lat_sum, lon_sum) = vertices
            .iter()
            .fold((0.0_f32, 0.0_f32), |(la, lo), (vla, vlo)| {
                (la + vla, lo + vlo)
            });
        let n = vertices.len().max(1) as f32;
        Self {
            id,
            centroid: (lat_sum / n, lon_sum / n),
            vertices,
            neighbors: Vec::new(),
            attrs: HashMap::new(),
            edge_tags: HashMap::new(),
            texture: None,
            texture_uv_rect: None,
            base_color: [0.5, 0.5, 0.5, 1.0],
        }
    }
    /// Create a region from explicit cached data.
    pub fn with_data(
        id: RegionId,
        centroid: (f32, f32),
        vertices: Vec<(f32, f32)>,
        neighbors: Vec<RegionId>,
        base_color: [f32; 4],
    ) -> Self {
        Self {
            id,
            centroid,
            vertices,
            neighbors,
            attrs: HashMap::new(),
            edge_tags: HashMap::new(),
            texture: None,
            texture_uv_rect: None,
            base_color,
        }
    }
}
/// Fog-of-war state for a region.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum FogState {
    /// Region is hidden and not visible.
    Hidden = 0,
    /// Region has been seen before but is not visible now.
    Explored = 1,
    /// Region is visible right now.
    Visible = 2,
}
/// Heat overlay parameters used by globe color mapping.
#[derive(Debug, Clone)]
pub struct HeatLayer {
    /// Layer name used for lookup and UI.
    pub name: String,
    /// Region attribute key used for numeric sampling.
    pub attr_key: String,
    /// Minimum sampled value mapped to the cold color.
    pub min_value: f32,
    /// Maximum sampled value mapped to the hot color.
    pub max_value: f32,
    /// RGBA color used at the low end of the gradient.
    pub cold_color: [f32; 4],
    /// RGBA color used at the high end of the gradient.
    pub hot_color: [f32; 4],
    /// Alpha multiplier applied to the overlay.
    pub alpha: f32,
    /// Visibility flag for the overlay.
    pub visible: bool,
    /// Z-order used when stacking overlays.
    pub z_order: i32,
}
/// Render-time globe parameters shared by loaders and draw code.
#[derive(Debug, Clone)]
pub struct GlobeSpec {
    /// Globe radius in render units.
    pub radius: f32,
    /// Axial tilt in degrees.
    pub axial_tilt_deg: f32,
    /// Current globe rotation in degrees.
    pub rotation_deg: f32,
    /// Fractional time of day used by lighting.
    pub time_of_day: f32,
    /// Flag that controls border rendering.
    pub render_borders: bool,
    /// Border RGBA color.
    pub border_color: [f32; 4],
    /// Border thickness in screen units.
    pub border_width: f32,
    /// Ambient light factor used for shading.
    pub ambient: f32,
    /// Flag that controls atmosphere rendering.
    pub show_atmosphere: bool,
    /// Atmosphere RGBA color.
    pub atmosphere_color: [f32; 4],
    /// Atmosphere band width in screen units.
    pub atmosphere_width: f32,
    /// Number of smoothing passes for region borders.
    pub border_smoothing_passes: u8,
    /// Automatic rotation speed in degrees per second.
    pub auto_rotation_deg_per_sec: f32,
    /// Background RGBA color used behind the globe.
    pub background_color: [f32; 4],
}
impl Default for GlobeSpec {
    fn default() -> Self {
        Self {
            radius: 300.0,
            axial_tilt_deg: 23.5,
            rotation_deg: 0.0,
            time_of_day: 0.25,
            render_borders: true,
            border_color: [0.0, 0.0, 0.0, 0.6],
            border_width: 1.0,
            ambient: 0.08,
            show_atmosphere: true,
            atmosphere_color: [0.30, 0.55, 0.95, 0.35],
            atmosphere_width: 14.0,
            border_smoothing_passes: 1,
            auto_rotation_deg_per_sec: 0.01,
            background_color: [0.02, 0.02, 0.08, 1.0],
        }
    }
}
/// Globe marker with position, label, style, and custom attributes.
#[derive(Debug, Clone)]
pub struct Marker {
    /// Stable marker identifier.
    pub id: u32,
    /// Marker category used by lookup and styling.
    pub marker_type: String,
    /// Latitude in degrees.
    pub lat_deg: f32,
    /// Longitude in degrees.
    pub lon_deg: f32,
    /// Optional marker label text.
    pub label: Option<String>,
    /// Visibility flag for rendering.
    pub visible: bool,
    /// Visual style used when drawing the marker.
    pub style: MarkerStyle,
    /// Arbitrary string attributes attached to the marker.
    pub attrs: HashMap<String, String>,
}
/// Marker drawing style shared by globe markers.
#[derive(Debug, Clone)]
pub struct MarkerStyle {
    /// RGBA tint for the marker.
    pub color: [f32; 4],
    /// Marker size in screen units.
    pub size: f32,
    /// Optional icon texture name.
    pub icon_texture: Option<String>,
    /// Shape used when no icon texture is present.
    pub shape: MarkerShape,
    /// Pulse frequency in hertz.
    pub pulse_hz: f32,
    /// Pulse amplitude multiplier.
    pub pulse_amplitude: f32,
    /// Rotation speed in degrees per second.
    pub rotation_deg_per_sec: f32,
}
/// Marker shape selection used by the renderer.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum MarkerShape {
    /// Circular marker.
    Circle,
    /// Square marker.
    Square,
    /// Diamond marker.
    Diamond,
    /// Triangle marker.
    Triangle,
    /// Cross marker.
    Cross,
}
/// Default marker style with a yellow circular marker.
impl Default for MarkerStyle {
    fn default() -> Self {
        Self {
            color: [1.0, 1.0, 0.0, 1.0],
            size: 8.0,
            icon_texture: None,
            shape: MarkerShape::Circle,
            pulse_hz: 0.0,
            pulse_amplitude: 0.0,
            rotation_deg_per_sec: 0.0,
        }
    }
}
/// Globe label with text, position, style, and LOD gating.
#[derive(Debug, Clone)]
pub struct Label {
    /// Stable label identifier.
    pub id: u32,
    /// Label category used by lookup and styling.
    pub label_type: String,
    /// Latitude in degrees.
    pub lat_deg: f32,
    /// Longitude in degrees.
    pub lon_deg: f32,
    /// Text rendered for the label.
    pub text: String,
    /// Visibility flag for rendering.
    pub visible: bool,
    /// Visual style used when drawing the label.
    pub style: LabelStyle,
    /// Minimum level of detail tier required for visibility.
    pub min_lod: u8,
}
/// Label styling shared by globe labels.
#[derive(Debug, Clone)]
pub struct LabelStyle {
    /// RGBA tint for the text.
    pub color: [f32; 4],
    /// Font size in screen units.
    pub font_size: f32,
    /// Optional font name.
    pub font: Option<String>,
}
/// Default label style with white 12-point text and no font override.
impl Default for LabelStyle {
    fn default() -> Self {
        Self {
            color: [1.0, 1.0, 1.0, 1.0],
            font_size: 12.0,
            font: None,
        }
    }
}
/// Named globe overlay layer with per-region color overrides.
#[derive(Debug, Clone)]
pub struct Layer {
    /// Layer name used for lookup and UI.
    pub name: String,
    /// Visibility flag for the layer.
    pub visible: bool,
    /// Alpha multiplier applied during rendering.
    pub alpha: f32,
    /// Z-order used when sorting layers.
    pub z_order: i32,
    /// Layer kind string used for categorization.
    pub kind: String,
    /// Per-region RGBA overrides keyed by region id.
    pub region_colors: HashMap<RegionId, [f32; 4]>,
}
impl Layer {
    /// Create a visible overlay layer with the supplied name, kind, and z-order.
    pub fn new(name: impl Into<String>, kind: impl Into<String>, z_order: i32) -> Self {
        Self {
            name: name.into(),
            visible: true,
            alpha: 1.0,
            z_order,
            kind: kind.into(),
            region_colors: HashMap::new(),
        }
    }
}
/// Level-of-detail tier used by globe render decisions.
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
pub enum LodTier {
    /// Distant view tier.
    Far = 0,
    /// Medium-distance view tier.
    Mid = 1,
    /// Close view tier.
    Near = 2,
}
/// Projected region with screen-space geometry and lighting state.
#[derive(Debug, Clone)]
pub struct ProjectedRegion {
    /// Region identifier.
    pub id: RegionId,
    /// Screen-space polygon vertices.
    pub screen_verts: Vec<Vec2>,
    /// Screen-space centroid.
    pub centroid_screen: Vec2,
    /// Lighting value applied to the region.
    pub light_intensity: f32,
    /// Visibility flag after projection.
    pub visible: bool,
}
/// Projected arc with path geometry and render parameters.
#[derive(Debug, Clone)]
pub struct Arc {
    /// Stable arc identifier.
    pub id: u32,
    /// Arc category used by lookup and styling.
    pub arc_type: String,
    /// Screen-space points used to draw the arc.
    pub screen_points: Vec<Vec2>,
    /// RGBA color used for the arc.
    pub color: [f32; 4],
    /// Line width in screen units.
    pub width: f32,
    /// Arc start position in latitude/longitude degrees.
    pub from: (f32, f32),
    /// Arc end position in latitude/longitude degrees.
    pub to: (f32, f32),
    /// Number of interpolation steps used to build the path.
    pub steps: u32,
    /// Visibility flag for rendering.
    pub visible: bool,
}
/// Globe-level errors for loading, lookup, and pathfinding failures.
#[derive(Debug)]
pub enum GlobeError {
    /// Region id was not found.
    RegionNotFound(RegionId),
    /// Input exceeded the supported region count.
    TooManyRegions,
    /// Loading failed with a message.
    LoadError(String),
    /// Requested globe name was not registered.
    GlobeNotFound(String),
    /// No path exists between the two regions.
    NoPath(RegionId, RegionId),
}
/// Format globe errors for human-readable diagnostics.
impl std::fmt::Display for GlobeError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            GlobeError::RegionNotFound(id) => write!(f, "region {} not found", id),
            GlobeError::TooManyRegions => write!(
                f,
                "region count exceeds MAX_REGIONS ({})",
                MAX_REGIONS
            ),
            GlobeError::LoadError(s) => write!(f, "load error: {}", s),
            GlobeError::GlobeNotFound(s) => write!(f, "globe '{}' not registered", s),
            GlobeError::NoPath(a, b) => write!(f, "no path between {} and {}", a, b),
        }
    }
}
/// Allow globe errors to use the standard error trait.
impl std::error::Error for GlobeError {}

/// Backward compatibility aliases.
pub type Province = Region;
/// Backward-compatible type alias for `RegionId`.
pub type ProvinceId = RegionId;
/// Backward-compatible type alias for `ProjectedRegion`.
pub type ProjectedProvince = ProjectedRegion;
/// Maximum number of provinces (regions) supported per globe — backward-compat alias for `MAX_REGIONS`.
pub const MAX_PROVINCES: usize = MAX_REGIONS;
