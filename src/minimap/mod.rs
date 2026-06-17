//! Minimap subsystem for terrain layers, fog, markers, overlays, and export rendering. `minimap/mod` is the minimap module index, declaring `minimap`, `province_adapter`, `raycaster_overlay`, `render`, `types` so agents can identify which files own each feature slice before opening implementation code.
//! Connects the grid model with renderer output, province data, and raycaster-specific views. `src/minimap/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `minimap::Minimap`, `raycaster_overlay::{ build_minimap_tile_window, compute_tile_light, draw_player_arrow, extract_minimap, reveal_cells_from_rays, MinimapTileSample, }`, `types::{ ColorMode, FogLevel, LayerData, MarkerAnimation, MinimapMarker, MinimapObject, MinimapObjectType, MinimapPing, OverlayPath, OverlayShape, }` centralized for the minimap subsystem.

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
