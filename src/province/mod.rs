//! Exports the province subsystem surface that groups grid extraction, registry state, rendering, import, and helpers.
//! Acts as the navigation entry for province ownership, borders, labels, map modes, and GPU support modules below.
//! Keeps the module boundary explicit so callers can find whether a province concern belongs to data, import, or draw.
//! Open this file when adding or retiring province submodules or when the public organization of province code shifts.
//! Neighboring work usually spans ProvinceRegistry, ProvinceGrid, render generation, and metadata import pipelines.
//! The exported set here defines which province owners are considered part of the supported internal engine surface.
//! Agents should start here when tracing province features because it reveals the authoritative file split by concern.
//! This file stays thin by contract, so substantive province behavior belongs in the concrete owners it re-exports.

/// Precomputed border-pair index map for shader and thick-border pipelines.
pub mod border_index;
/// Binary-format geometry cache for province spans and border segments.
pub mod cache;
/// Distance-to-border field precompute for province shading.
pub mod distance_field;
/// Change and event enums emitted by ProvinceRegistry mutations.
pub mod events;
/// GPU record builder: packs province styles into upload-ready structs.
pub mod gpu_bridge;
/// Metadata import pipeline: colour-map PNG + CSV/TOML → ProvinceRegistry.
pub mod import;
/// Label centroid computation from province span runs.
pub mod labels;
/// Config-driven map mode registry and per-mode colour resolver.
pub mod map_modes;
/// Generic per-province property store for game-defined key-value data.
pub mod properties;
/// Authoritative store for all province state, geometry, and change history.
pub mod registry;
/// RenderCommand generation for fills, borders, capitals, and text labels.
pub mod render;
/// CPU-only snapshot bridge from province semantics to renderer uploads.
pub mod render_snapshot;
/// Province routing adapters plus owner-attribute aggregation.
pub mod routing;
/// Province adjacency graph built from pixel-scan output.
pub mod topology;
/// Core types: ProvinceId, BorderType, BorderTypeConfig, ProvinceStyle, ProvinceSnapshot.
pub mod types;
/// Province-grid view adapter: fit, screen-to-map, cell lookup, zoom-at-point.
pub mod view_transform;

/// Province-grid extraction and adjacency helpers.
pub mod province_grid;
/// Province grid type and adjacency pair type.
pub use province_grid::{AdjacencyPair, ProvinceGrid, ProvinceShapeCacheEntry};

pub use events::{ProvinceChange, ProvinceEvent};
pub use import::{
    import_metadata_from_files, sanitize_marked_png, MarkerSanitizeOptions, MarkerSanitizeSummary,
    ProvinceMetadataImportOptions, ProvinceMetadataImportSummary,
};
pub use properties::ProvinceProperties;
pub use registry::ProvinceRegistry;
pub use render_snapshot::ProvinceRenderSnapshot;
pub use types::{
    parse_province_effect_flag_token, BorderPairFlags, BorderPairStyle, BorderType,
    BorderTypeConfig, ProvinceClimateKind, ProvinceId, ProvinceSnapshot, ProvinceStyle,
    ProvinceVisualState, ProvinceWeatherKind, PROVINCE_EFFECT_COAST_FOAM, PROVINCE_EFFECT_CONFLICT,
    PROVINCE_EFFECT_FOG_NOISE, PROVINCE_EFFECT_HEAT_HAZE, PROVINCE_EFFECT_WAVES,
};
pub use view_transform::{fit_camera_to_screen, map_to_cell, screen_to_map, zoom_camera_at};
