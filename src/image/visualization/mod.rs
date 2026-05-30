//! High-level visualization module wiring that groups image-debug renderers by domain.
//! Re-exports category entry points to provide one flat surface for visualization consumers.
//! Shares internal facade utilities while keeping submodule responsibilities clearly separated.

/// Animation visualizations. This module is publicly re-exported.
pub mod animation;
/// Audio visualizations. This module is publicly re-exported.
pub mod audio;
/// Camera visualizations. This module is publicly re-exported.
pub mod camera;
/// Easing visualizations. This module is publicly re-exported.
pub mod easing;
/// Shared visualization helpers.
pub mod facade;
/// Geometry visualizations. This module is publicly re-exported.
pub mod geometry;
/// Graph visualizations. This module is publicly re-exported.
pub mod graph;
/// Image-operation visualizations.
pub mod image_ops;
/// Noise visualizations. This module is publicly re-exported.
pub mod noise;
/// Procedural-generation visualizations.
pub mod procgen;
/// UI visualizations. This module is publicly re-exported.
pub mod ui;
/// Re-export animation visualization entry points.
pub use animation::*;
/// Re-export audio visualization entry points.
pub use audio::*;
/// Re-export camera visualization entry points.
pub use camera::*;
/// Re-export easing visualization entry points.
pub use easing::*;
/// Re-export shared visualization helpers within the module.
pub(crate) use facade::*;
/// Re-export geometry visualization entry points.
pub use geometry::*;
/// Re-export graph visualization entry points.
pub use graph::*;
/// Re-export image-operation visualization entry points.
pub use image_ops::*;
/// Re-export noise visualization entry points.
pub use noise::*;
/// Re-export procedural-generation visualization entry points.
pub use procgen::*;
/// Re-export UI visualization entry points.
pub use ui::*;
