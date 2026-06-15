//! Province runtime module for irregular region maps that need authoritative state, import tooling, geometry extraction, GPU preparation, and on-screen rendering in one connected system.
//! It treats provinces as semantic map entities rather than tilemap cells, combining topology, styling, labels, capitals, and change tracking into a single map stack.
//! The module also owns the bridges that move province data from imported assets through cached geometry and into renderable outputs.
//! Functionally this file is the high-level entry point for province-based cartography, visualization, and region-centric gameplay support.

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
/// GPU texture upload helpers for province id, border index, and distance field maps.
pub mod gpu_upload;
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
/// Province graph routing helpers: shortest path, components, connectivity.
pub mod routing;
/// Province adjacency graph built from pixel-scan output.
pub mod topology;
/// Core types: ProvinceId, BorderType, BorderTypeConfig, ProvinceStyle, ProvinceSnapshot.
pub mod types;
/// Camera/view-transform helpers: fit, screen-to-map, cell lookup, zoom-at-point.
pub mod view_transform;

/// Province-grid extraction and adjacency helpers.
pub mod province_grid;
/// Province grid type and adjacency pair type.
pub use province_grid::{AdjacencyPair, ProvinceGrid, ProvinceShapeCacheEntry};

pub use events::{ProvinceChange, ProvinceEvent};
pub use import::{import_metadata_from_files, sanitize_marked_png, MarkerSanitizeOptions, MarkerSanitizeSummary, ProvinceMetadataImportOptions, ProvinceMetadataImportSummary};
pub use properties::ProvinceProperties;
pub use registry::ProvinceRegistry;
pub use types::{BorderPairFlags, BorderPairStyle, BorderType, BorderTypeConfig, ProvinceId, ProvinceSnapshot, ProvinceStyle};
pub use view_transform::{fit_camera_to_screen, map_to_cell, screen_to_map, zoom_camera_at};
