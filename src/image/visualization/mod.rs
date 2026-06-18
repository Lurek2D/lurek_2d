//! Exports the image-visualization surface that groups debug renderers for animation, audio, camera, and UI.
//! Acts as the index for raster helpers that turn engine data into screenshots and proof images for tooling.
//! Re-exports the facade helper internally so sibling visualization files can share one HSV color conversion.
//! Points readers to geometry, graph, image-op, noise, and procgen views instead of mixing those concerns here.
//! Keeps visualization module visibility centralized, which makes spec generation and ownership tracing simpler.
//! Open this file first when adding a new debug image module or when public visualization exports must change.
//! This index owns composition of visualization helpers rather than the sampled drawing logic inside each file.
//! Use it to see the complete visualization feature set before editing a specific owner like camera or audio.

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
