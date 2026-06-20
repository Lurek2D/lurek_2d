//! `src/minimap/types.rs` defines the shared enums and data structs that every minimap state and render file reuses.
//! It owns color mode, fog level, markers, pings, overlay geometry, raw layers, and object descriptors in one contract set.
//! Small parsing and conversion helpers also live here so value semantics stay close to the types they interpret.
//! This file carries data shapes only; it does not own minimap mutation, rendering order, or province import behavior.
//! Read it when minimap payload fields, cross-file data contracts, or serialized marker and overlay semantics need changes.

use thiserror::Error;

/// Whether minimap cells are coloured by terrain type or by political owner.
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum ColorMode {
    /// Colour each cell by its terrain type's registered colour.
    Terrain,
    /// Colour each cell by the owning player's registered colour.
    Political,
}

impl ColorMode {
    /// Parse `"terrain"` or `"political"` to a `ColorMode`; returns `None` on unknown strings.
    pub fn parse_mode(s: &str) -> Option<Self> {
        match s {
            "terrain" => Some(ColorMode::Terrain),
            "political" => Some(ColorMode::Political),
            _ => None,
        }
    }

    /// Return the canonical string name for this colour mode.
    pub fn as_str(self) -> &'static str {
        match self {
            ColorMode::Terrain => "terrain",
            ColorMode::Political => "political",
        }
    }
}

/// Fog-of-war visibility level for a single minimap cell.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
#[repr(u8)]
pub enum FogLevel {
    /// Cell has never been seen; rendered with full fog tint.
    Hidden = 0,
    /// Cell was seen in a past turn; rendered at reduced brightness.
    Explored = 1,
    /// Cell is currently visible; rendered at full brightness.
    Visible = 2,
}

impl FogLevel {
    /// Convert a raw `u8` byte to a `FogLevel`; values >= 2 map to `Visible`.
    pub fn from_u8(val: u8) -> Self {
        match val {
            0 => FogLevel::Hidden,
            1 => FogLevel::Explored,
            _ => FogLevel::Visible,
        }
    }
}

/// Descriptor for a category of minimap objects (units, buildings, etc.).
#[derive(Debug, Clone)]
pub struct MinimapObjectType {
    /// Human-readable name of this object type.
    pub name: String,
    /// Default RGBA colour used when no custom icon is set.
    pub color: [f32; 4],
    /// Whether objects of this type are shown on the minimap.
    pub visible: bool,
}

/// A single live minimap object placed at a world-space grid position.
#[derive(Debug, Clone)]
pub struct MinimapObject {
    /// World-space X position in grid units.
    pub x: f32,
    /// World-space Y position in grid units.
    pub y: f32,
    /// Index into the `object_types` list on `Minimap`.
    pub type_index: usize,
    /// Owner id used for political colour mode.
    pub owner: u32,
}

/// A timed visual indicator that fades over its `duration`.
#[derive(Debug, Clone)]
pub struct MinimapPing {
    /// World-space X position in grid units.
    pub x: f32,
    /// World-space Y position in grid units.
    pub y: f32,
    /// Seconds remaining before the ping is removed.
    pub remaining: f32,
    /// Total duration in seconds; used to compute fade ratio.
    pub duration: f32,
    /// RGBA colour of the ping circle.
    pub color: [f32; 4],
}

/// A persistent named marker placed at a world-space grid position.
#[derive(Debug, Clone)]
pub struct MinimapMarker {
    /// World-space X position in grid units.
    pub x: f32,
    /// World-space Y position in grid units.
    pub y: f32,
    /// Tooltip or label text for hover and Lua queries.
    pub description: String,
    /// RGBA colour when drawn without a custom icon.
    pub color: [f32; 4],
    /// Optional animation applied to the marker each frame.
    pub animation: Option<MarkerAnimation>,
}

/// Per-frame animation state for a minimap marker.
#[derive(Debug, Clone)]
pub enum MarkerAnimation {
    /// Blink at `speed` Hz; `phase` is the current oscillation phase in [0, 1).
    Blink { speed: f32, phase: f32 },
    /// Pulse-scale at `speed` Hz; `phase` is the current oscillation phase in [0, 1).
    Pulse { speed: f32, phase: f32 },
    /// Spin at `speed` radians/second; `angle` is the current angle in [0, TAU).
    Rotate { speed: f32, angle: f32 },
}

/// A vector overlay shape drawn on top of the terrain grid.
#[derive(Debug, Clone)]
pub enum OverlayShape {
    /// A line segment from `(x1, y1)` to `(x2, y2)` in grid coordinates.
    Line {
        /// Start X in grid units.
        x1: f32,
        /// Start Y in grid units.
        y1: f32,
        /// End X in grid units.
        x2: f32,
        /// End Y in grid units.
        y2: f32,
        /// RGBA colour as bytes.
        color: [u8; 4],
    },
    /// An axis-aligned rectangle outline at `(x, y)` with size `(w, h)` in grid units.
    Rect {
        /// Left edge in grid units.
        x: f32,
        /// Top edge in grid units.
        y: f32,
        /// Width in grid units.
        w: f32,
        /// Height in grid units.
        h: f32,
        /// RGBA colour as bytes.
        color: [u8; 4],
    },
}

/// A named polyline path drawn over the terrain.
#[derive(Debug, Clone)]
pub struct OverlayPath {
    /// Auto-assigned path id used for removal.
    pub id: u32,
    /// Ordered list of `(x, y)` grid-coordinate waypoints.
    pub points: Vec<(f32, f32)>,
    /// RGBA colour as bytes.
    pub color: [u8; 4],
}

/// Raw cell data for one named minimap layer.
#[derive(Debug, Clone)]
pub struct LayerData {
    /// Flat byte array of cell values indexed by `y * width + x`.
    pub cells: Vec<u8>,
    /// Number of columns in this layer grid.
    pub width: u32,
    /// Number of rows in this layer grid.
    pub height: u32,
}

/// Hard limits that prevent oversized minimap allocations and unbounded overlay growth.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct MinimapLimits {
    /// Maximum allowed grid cell count for one minimap.
    pub max_grid_cells: usize,
    /// Maximum allowed display or output pixel count.
    pub max_display_pixels: u64,
    /// Maximum allowed raw RGBA output byte count.
    pub max_output_bytes: u64,
    /// Maximum number of layers stored on one minimap.
    pub max_layers: usize,
    /// Maximum number of live marker entries.
    pub max_markers: usize,
    /// Maximum number of live objects.
    pub max_objects: usize,
    /// Maximum number of live ping entries.
    pub max_pings: usize,
    /// Maximum number of overlay shapes.
    pub max_overlay_shapes: usize,
    /// Maximum number of overlay paths.
    pub max_paths: usize,
    /// Maximum number of points in one overlay path.
    pub max_path_points: usize,
    /// Maximum number of cells one reveal call may touch.
    pub max_reveal_cells_per_call: usize,
    /// Maximum tile radius accepted by raycaster minimap extraction helpers.
    pub max_view_radius: u32,
}

impl Default for MinimapLimits {
    fn default() -> Self {
        Self {
            max_grid_cells: 16_777_216,
            max_display_pixels: 67_108_864,
            max_output_bytes: 268_435_456,
            max_layers: 256,
            max_markers: 65_536,
            max_objects: 65_536,
            max_pings: 16_384,
            max_overlay_shapes: 16_384,
            max_paths: 4_096,
            max_path_points: 65_536,
            max_reveal_cells_per_call: 1_048_576,
            max_view_radius: 4_096,
        }
    }
}

/// Validation policy for Lua-facing floats, colors, and free-form text.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct MinimapValidationLimits {
    /// Smallest accepted finite zoom factor.
    pub min_zoom: f32,
    /// Largest accepted finite zoom factor.
    pub max_zoom: f32,
    /// Maximum absolute coordinate magnitude for public setters.
    pub max_coordinate_abs: f32,
    /// Largest accepted finite ping duration in seconds.
    pub max_duration: f32,
    /// Maximum UTF-8 byte length for marker descriptions.
    pub max_description_len: usize,
}

impl Default for MinimapValidationLimits {
    fn default() -> Self {
        Self {
            min_zoom: 0.1,
            max_zoom: 64.0,
            max_coordinate_abs: 1_000_000.0,
            max_duration: 86_400.0,
            max_description_len: 512,
        }
    }
}

/// Debug counters for one minimap render-command generation pass.
#[derive(Debug, Clone, Copy, Default, PartialEq, Eq)]
pub struct MinimapRenderStats {
    /// Number of grid cells considered for terrain rendering.
    pub visible_cells: usize,
    /// Number of horizontal terrain runs emitted after batching.
    pub terrain_runs_batched: usize,
    /// Total render commands emitted for the full minimap pass.
    pub commands_generated: usize,
}

/// Structured minimap failure reasons surfaced through Rust and Lua strict paths.
#[derive(Debug, Clone, Error, PartialEq)]
pub enum MinimapError {
    /// Grid dimensions must be non-zero.
    #[error("minimap grid dimensions must be greater than zero")]
    GridDimensionsZero,
    /// Display dimensions must be non-zero.
    #[error("minimap display dimensions must be greater than zero (got {width}x{height})")]
    DisplayDimensionsZero { width: u32, height: u32 },
    /// Grid cell count arithmetic overflowed.
    #[error("minimap grid dimensions {grid_width}x{grid_height} overflow the cell count")]
    GridCellOverflow { grid_width: u32, grid_height: u32 },
    /// Grid cell count exceeds the configured cap.
    #[error("minimap grid has {cell_count} cells but the limit is {limit}")]
    GridCellLimitExceeded { cell_count: usize, limit: usize },
    /// Pixel count exceeds the configured cap.
    #[error("minimap output has {pixel_count} pixels but the limit is {limit}")]
    PixelLimitExceeded { pixel_count: u64, limit: u64 },
    /// RGBA byte count exceeds the configured cap.
    #[error("minimap output requires {byte_count} bytes but the limit is {limit}")]
    OutputByteLimitExceeded { byte_count: u64, limit: u64 },
    /// A bulk data load received the wrong element count.
    #[error("{context} expected exactly {expected} values but received {actual}")]
    DataLengthMismatch {
        context: &'static str,
        expected: usize,
        actual: usize,
    },
    /// A public float input was NaN or infinite.
    #[error("{field} must be a finite number")]
    InvalidFloat { field: &'static str },
    /// A public zoom input was outside the accepted range.
    #[error("zoom {zoom} is outside the supported range {min}..={max}")]
    InvalidZoom { zoom: f32, min: f32, max: f32 },
    /// A public color table contained NaN or infinity.
    #[error("{field} must contain only finite color components")]
    InvalidColor { field: &'static str },
    /// A string field exceeded the configured byte length.
    #[error("{field} length {len} exceeds the limit {limit}")]
    DescriptionTooLong {
        field: &'static str,
        len: usize,
        limit: usize,
    },
    /// A requested object type index does not exist.
    #[error("object type index {index} does not exist")]
    MissingObjectType { index: usize },
    /// A requested marker id does not exist.
    #[error("marker id {id} does not exist")]
    MissingMarker { id: u32 },
    /// A requested layer index is unavailable.
    #[error("layer {layer} does not exist")]
    InvalidLayer { layer: usize },
    /// A layer exists but has no usable cell payload.
    #[error("layer {layer} has no cell data")]
    EmptyLayer { layer: usize },
    /// Layer creation exceeded the configured cap.
    #[error("layer index {layer} exceeds the layer limit {limit}")]
    LayerLimitExceeded { layer: usize, limit: usize },
    /// One of the auto-increment ids reached the integer limit.
    #[error("{kind} id counter overflowed")]
    IdOverflow { kind: &'static str },
    /// Marker count exceeded the configured cap.
    #[error("marker limit {limit} reached")]
    MarkerLimitExceeded { limit: usize },
    /// Object count exceeded the configured cap.
    #[error("object limit {limit} reached")]
    ObjectLimitExceeded { limit: usize },
    /// Ping count exceeded the configured cap.
    #[error("ping limit {limit} reached")]
    PingLimitExceeded { limit: usize },
    /// Overlay shape count exceeded the configured cap.
    #[error("overlay shape limit {limit} reached")]
    OverlayLimitExceeded { limit: usize },
    /// Overlay path count exceeded the configured cap.
    #[error("path limit {limit} reached")]
    PathLimitExceeded { limit: usize },
    /// Overlay path point count exceeded the configured cap.
    #[error("path has {points} points but the limit is {limit}")]
    PathPointLimitExceeded { points: usize, limit: usize },
    /// A reveal request would iterate too many cells in one call.
    #[error("reveal would visit {requested} cells but the limit is {limit}")]
    RevealAreaTooLarge { requested: usize, limit: usize },
    /// Coordinate conversion could not run with the current grid/display/zoom state.
    #[error("minimap transform is unavailable: {reason}")]
    TransformUnavailable { reason: &'static str },
    /// Raycaster minimap extraction requires a positive cell size.
    #[error("minimap extraction cell size must be greater than zero")]
    CellSizeZero,
    /// One of the helper image buffers does not match its declared dimensions.
    #[error(
        "image buffer length {len} does not match {width}x{height} RGBA storage ({expected} bytes)"
    )]
    InvalidImageBuffer {
        width: u32,
        height: u32,
        len: usize,
        expected: usize,
    },
}
