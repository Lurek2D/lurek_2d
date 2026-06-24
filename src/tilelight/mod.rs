//! Exports the tile-based lighting subsystem surface.
//! The module computes light maps over `TileField` data without owning render submission or player awareness.

pub mod color;
pub mod map;
pub mod source;

pub use color::LightColor;
pub use map::TileLightMap;
pub use source::{
    LightModulation, LineLight, LineLightUpdate, PointLight, PointLightUpdate, SunLight,
    SunLightMode,
};
