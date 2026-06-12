//! High-level vector graphics module that implements SVG loading, parsing, state management, and GP-accelerated rendering.
//! Bridges parsed XML vector trees and Lurek2D's RenderCommand drawing pipeline.

/// SVG image document model, parser output structs, and render command conversion helpers.
pub mod svg_image;
pub use svg_image::{SvgElement, SvgImage, SvgPath};
