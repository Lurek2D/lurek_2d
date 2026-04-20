//! Standalone visualization helpers for Tier 1 modules.
//!
//! Because Tier 1 modules (animation, camera) cannot import `crate::image`,
//! render helpers that produce `ImageData` from their structs live here,
//! accepting the domain object by reference.
//!
//! Submodules are organized by domain: animation, audio, camera, easing/bezier,
//! geometry, graph, image operations, noise/terrain, procedural generation, and UI.

pub mod animation;
pub mod audio;
pub mod camera;
pub mod easing;
pub mod facade;
pub mod geometry;
pub mod graph;
pub mod image_ops;
pub mod noise;
pub mod procgen;
pub mod ui;

pub use animation::*;
pub use audio::*;
pub use camera::*;
pub use easing::*;
pub(crate) use facade::*;
pub use geometry::*;
pub use graph::*;
pub use image_ops::*;
pub use noise::*;
pub use procgen::*;
pub use ui::*;

