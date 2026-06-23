//! Indexes the passive minimap subsystem, naming the model, renderer, province adapter, and type owners.
//! Reexports `Minimap` plus layer, marker, fog, ping, overlay, error, and validation data contracts.
//! Keeps minimap ownership scoped to visualization of supplied terrain, fog, light, and overlay inputs only.
//! Declares no runtime state here; concrete storage, render buffers, and import adapters live in sibling files.
//! Guides agents toward the correct owner before changing ingestion, rendering, validation, or overlay behavior.
//! Changes here affect module reachability and public symbol routing, not gameplay LOS, lighting, or movement.

#[allow(clippy::module_inception)]
/// Core minimap state and update logic.
pub mod minimap;
/// Adapter that bridges province-map data into minimap layer format.
pub mod province_adapter;
/// Pixel-buffer rendering for the minimap texture.
pub mod render;
/// Shared data types for markers, layers, overlays, fog, and pings.
pub mod types;

pub use minimap::Minimap;
pub use types::{
    ColorMode, FogLevel, LayerBlendMode, LayerData, LayerStyle, MarkerAnimation, MinimapError,
    MinimapLimits, MinimapMarker, MinimapObject, MinimapObjectType, MinimapPing,
    MinimapRenderStats, MinimapValidationLimits, OverlayPath, OverlayShape,
};
