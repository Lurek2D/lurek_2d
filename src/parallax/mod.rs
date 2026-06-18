//! `src/parallax/mod.rs` is the module index for parallax state, draw helpers, presets, rendering, and tile iteration.
//! It declares files for layer ownership, renderer bridging, bitmap export, presets, and tiled viewport coverage helpers.
//! This file reexports `ParallaxLayer` and `ParallaxDrawBatch` so callers can use the subsystem without deep imports.
//! No scrolling state or camera math lives here; it only defines the public boundary and file ownership map.
//! Read this index first when tracing parallax features, because it shows where layer logic ends and helpers begin.
//! Changes here affect module reachability and API shape, not scroll behavior, batching, or render-command generation.

/// Stateless draw-call helpers: converts layer data into renderer `RenderCommand` payloads.
pub mod draw;
/// `ParallaxLayer` definition and `ParallaxDrawBatch` accumulator used by game code.
pub mod layer;
/// Named preset constructors for common parallax configurations (sky, mountains, clouds).
pub mod presets;
/// Integration point that calls `draw` for each active layer on every frame.
pub mod render;
/// Iterator over visible tile columns for a given layer scroll offset and screen width.
pub mod tile_iter;

/// Re-export primary types for convenient access.
pub use layer::{ParallaxDrawBatch, ParallaxLayer};
