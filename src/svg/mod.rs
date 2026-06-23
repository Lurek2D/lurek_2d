//! `src/svg/mod.rs` is the SVG module index, exposing SVG document types and loading surfaces for runtime rendering.
//! It reexports `SvgElement`, `SvgImage`, and `SvgPath` so callers reach vector scene data through one stable boundary.
//! No parsed vector state lives here; this file defines visibility while parsing logic stays in `svg_image.rs`.
//! Read this index when wiring vector features, because it shows which SVG-facing contracts are public and shared.
//! Changes here alter the vector boundary, since reexports decide what runtime systems and bindings may import directly.
//! This module keeps scene representation and vector loading separate from higher-level render and Lua binding layers.

/// SVG image document model, parser output structs, and render command conversion helpers.
pub mod svg_image;
pub use svg_image::{SvgElement, SvgImage, SvgPath};
