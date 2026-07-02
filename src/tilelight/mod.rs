//! This module index owns the public shape of the tilelight subsystem and its source navigation map.
//! It declares which sibling files participate in tilelight behavior and which names are reexported outward.
//! Reexports here are intentionally narrow so callers do not depend on private implementation modules.
//! Agents should start here to understand subsystem boundaries before opening deeper implementation files.
//! New submodules belong here only when they add durable behavior rather than temporary test scaffolding.
//! Keep this index synchronized with specs, examples, and Lua bindings whenever public ownership changes.

/// Color value and conversion helpers for tile-light calculations.
pub mod color;
/// Grid storage and traversal types for tile-light maps.
pub mod map;
/// Light source models, modulation, and propagation policies.
pub mod source;

pub use color::LightColor;
pub use map::TileLightMap;
pub use source::{
    AreaLight, AreaLightUpdate, LightModulation, LineLight, LineLightUpdate, PointLight,
    PointLightUpdate, SunLight, SunLightMode,
};

/// Compatibility alias for the global top-light source.
pub type GlobalLight = SunLight;
