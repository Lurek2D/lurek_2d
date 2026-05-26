//! Multi-layer parallax scrolling system with per-layer speed, tiling, and draw-batch accumulation.
//!
//! - Preset constructors for common configurations (sky, mountains, clouds).
//! - Tile-column iterator and stateless draw-call generation into `RenderCommand` payloads.

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
