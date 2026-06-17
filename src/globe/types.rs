//! Provides the shared globe data model defining regions, overlays, markers, labels, arcs, and view artifacts. `globe/types` delivers the shared type definitions and data contracts for the globe subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Encodes geographic geometry with centroids, adjacency, edge tags, and per-region render attributes. The file owns or coordinates data contracts including `RegionId`, `RegionPart`, `Region`, `FogState`, `HeatLayer`, and 14 more, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Defines globe specification parameters that drive atmosphere, lighting, rotation, and border behavior. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `raw`, `with_data`, `with_parts_data`, `from_parts`, `primary_vertices`, and 2 more stays attached to the local data model and invariants.
//! Supplies layer and heat-overlay structures used to blend thematic map information at runtime. Runtime integration reaches sibling engine areas through crate modules `globe`, `math`, which explains the subsystem dependencies an agent should inspect before changing behavior.
//! Models marker and label style data with visibility, pulse, and level-of-detail controls. External integration uses `std`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.
//! Includes projection result types for screen-space rendering and interaction pipelines. The file boundary separates globe implementation details from Lua bindings, generated specs, and examples, so public behavior remains documented at the owning source.

use crate::globe::sphere::{lat_lon_to_unit, unit_to_lat_lon};
use crate::math::{Vec2, Vec3};
use std::collections::{HashMap, HashSet};
/// Maximum region count supported by globe data structures.
pub const MAX_REGIONS: usize = 8192;
/// Unique identifier for a region on the globe.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
pub struct RegionId(pub u32);

impl RegionId {
    /// Creates a new RegionId from a raw u32.
    pub fn new(id: u32) -> Self {
        Self(id)
    }
    /// Returns the raw u32 underlying value.
    pub fn raw(self) -> u32 {
        self.0
    }
}

impl std::fmt::Display for RegionId {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.0)
    }
}

impl From<u32> for RegionId {
    fn from(v: u32) -> Self {
        Self(v)
    }
}

impl From<RegionId> for u32 {
    fn from(id: RegionId) -> Self {
        id.0
    }
}

impl mlua::IntoLua<'_> for RegionId {
    fn into_lua(self, lua: &mlua::Lua) -> mlua::Result<mlua::Value<'_>> {
        lua.pack(self.0 as i64)
    }
}

impl mlua::FromLua<'_> for RegionId {
    fn from_lua(val: mlua::Value, lua: &mlua::Lua) -> mlua::Result<Self> {
        let n = i64::from_lua(val, lua)?;
        let raw = u32::try_from(n).map_err(|_| {
            mlua::Error::RuntimeError(format!(
                "region id must be an integer in the 0..={} range",
                u32::MAX
            ))
        })?;
        Ok(RegionId(raw))
    }
}
/// One connected geographic part of a region, with one outer ring and optional holes.
#[derive(Debug, Clone, Default)]
pub struct RegionPart {
    /// Outer boundary vertices in latitude/longitude space.
    pub outer: Vec<(f32, f32)>,
    /// Inner hole rings in latitude/longitude space.
    pub holes: Vec<Vec<(f32, f32)>>,
}
impl RegionPart {
    /// Create a part from one outer ring and no holes.
    pub fn new(outer: Vec<(f32, f32)>) -> Self {
        Self {
            outer,
            holes: Vec::new(),
        }
    }
}

fn derive_centroid_from_vertices(vertices: &[(f32, f32)]) -> (f32, f32) {
    if vertices.is_empty() {
        return (0.0, 0.0);
    }
    let mut accum = Vec3::new(0.0, 0.0, 0.0);
    let mut count = 0.0_f32;
    for &(lat, lon) in vertices {
        let v = lat_lon_to_unit(lat, lon);
        accum.x += v.x;
        accum.y += v.y;
        accum.z += v.z;
        count += 1.0;
    }
    if count <= 0.0 || accum.length() < 1e-6 {
        return vertices[0];
    }
    unit_to_lat_lon(Vec3::new(accum.x / count, accum.y / count, accum.z / count))
}

fn derive_centroid_from_parts(parts: &[RegionPart]) -> (f32, f32) {
    let mut accum = Vec3::new(0.0, 0.0, 0.0);
    let mut count = 0.0_f32;
    for part in parts {
        for &(lat, lon) in &part.outer {
            let v = lat_lon_to_unit(lat, lon);
            accum.x += v.x;
            accum.y += v.y;
            accum.z += v.z;
            count += 1.0;
        }
    }
    if count <= 0.0 || accum.length() < 1e-6 {
        return (0.0, 0.0);
    }
    unit_to_lat_lon(Vec3::new(accum.x / count, accum.y / count, accum.z / count))
}
/// Geographic region with polygon geometry, adjacency, and render attributes.
#[derive(Debug, Clone)]
pub struct Region {
    /// Stable region identifier.
    pub id: RegionId,
    /// Polygon vertices in latitude/longitude space.
    pub vertices: Vec<(f32, f32)>,
    /// Connected region parts with optional holes. When empty, `vertices` remains the canonical outer ring.
    pub parts: Vec<RegionPart>,
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
        let centroid = derive_centroid_from_vertices(&vertices);
        let parts = if vertices.is_empty() {
            Vec::new()
        } else {
            vec![RegionPart::new(vertices.clone())]
        };
        Self {
            id,
            vertices,
            parts,
            centroid,
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
        let parts = if vertices.is_empty() {
            Vec::new()
        } else {
            vec![RegionPart::new(vertices.clone())]
        };
        Self {
            id,
            centroid,
            vertices,
            parts,
            neighbors,
            attrs: HashMap::new(),
            edge_tags: HashMap::new(),
            texture: None,
            texture_uv_rect: None,
            base_color,
        }
    }
    /// Create a region from explicit multipart geometry.
    pub fn with_parts_data(
        id: RegionId,
        centroid: (f32, f32),
        parts: Vec<RegionPart>,
        neighbors: Vec<RegionId>,
        base_color: [f32; 4],
    ) -> Self {
        let vertices = parts
            .first()
            .map(|part| part.outer.clone())
            .unwrap_or_default();
        Self {
            id,
            vertices,
            parts,
            centroid,
            neighbors,
            attrs: HashMap::new(),
            edge_tags: HashMap::new(),
            texture: None,
            texture_uv_rect: None,
            base_color,
        }
    }
    /// Create a multipart region and derive its centroid from outer-ring vertices on the sphere.
    pub fn from_parts(id: RegionId, parts: Vec<RegionPart>) -> Self {
        let centroid = derive_centroid_from_parts(&parts);
        Self::with_parts_data(id, centroid, parts, Vec::new(), [0.5, 0.5, 0.5, 1.0])
    }
    /// Return the primary outer ring used by legacy rendering paths.
    pub fn primary_vertices(&self) -> &[(f32, f32)] {
        self.parts
            .first()
            .map(|part| part.outer.as_slice())
            .filter(|outer| !outer.is_empty())
            .unwrap_or(self.vertices.as_slice())
    }
    /// Return all outer rings that make up the visible solid geometry of this region.
    pub fn outer_loops(&self) -> Vec<&[(f32, f32)]> {
        if !self.parts.is_empty() {
            return self
                .parts
                .iter()
                .filter(|part| !part.outer.is_empty())
                .map(|part| part.outer.as_slice())
                .collect();
        }
        if self.vertices.is_empty() {
            Vec::new()
        } else {
            vec![self.vertices.as_slice()]
        }
    }
    /// Return all hole loops that should be subtracted from the region fill.
    pub fn hole_loops(&self) -> Vec<&[(f32, f32)]> {
        self.parts
            .iter()
            .flat_map(|part| part.holes.iter().map(Vec::as_slice))
            .filter(|hole| !hole.is_empty())
            .collect()
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
    /// Time of day in hours on the 0.0 through 24.0 clock.
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
            time_of_day: 12.0,
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
    /// Unit-sphere points corresponding to the projected polygon vertices.
    pub surface_points: Vec<Vec3>,
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
            GlobeError::TooManyRegions => {
                write!(f, "region count exceeds MAX_REGIONS ({})", MAX_REGIONS)
            }
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
