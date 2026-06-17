//! Multi-layer parallax scrolling system with per-layer speed, tiling, and draw-batch accumulation. `parallax/mod` is the parallax module index, declaring `draw`, `layer`, `presets`, `render`, `tile_iter` so agents can identify which files own each feature slice before opening implementation code.
//! Provides preset constructors for common depth planes and tile iteration helpers for rendering. `src/parallax/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `layer::{ParallaxDrawBatch, ParallaxLayer}` centralized for the parallax subsystem.

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
