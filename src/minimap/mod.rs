//! `src/minimap/mod.rs` is the module index for the minimap subsystem, covering state, render helpers, types, and adapters.
//! It declares the core `minimap` model, province adapter, renderer bridge, and raycaster overlay as separate files.
//! This file also reexports `Minimap`, overlay sampling helpers, and shared minimap types so callers avoid deep paths.
//! No runtime minimap state lives here; its job is to define the public boundary and keep subsystem ownership visible.
//! Read this index first when tracing minimap features, because it shows where data, rendering, and map import split.
//! Changes here affect module reachability and public surface, not minimap behavior, storage, or per-frame update rules.

#[allow(clippy::module_inception)]
/// Core minimap state and update logic.
pub mod minimap;
/// Adapter that bridges province-map data into minimap layer format.
pub mod province_adapter;
/// Raycaster-specific minimap overlay rendering.
pub mod raycaster_overlay;
/// Pixel-buffer rendering for the minimap texture.
pub mod render;
/// Shared data types for markers, layers, overlays, fog, and pings.
pub mod types;

pub use minimap::Minimap;
pub use raycaster_overlay::{
    build_minimap_tile_window, compute_tile_light, draw_player_arrow, extract_minimap,
    reveal_cells_from_rays, MinimapTileSample,
};
pub use types::{
    ColorMode, FogLevel, LayerData, MarkerAnimation, MinimapMarker, MinimapObject,
    MinimapObjectType, MinimapPing, OverlayPath, OverlayShape,
};
