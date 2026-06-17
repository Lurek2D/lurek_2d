//! High-level vector graphics module that implements SVG loading, parsing, state management, and GP-accelerated rendering. `vector/mod` is the vector module index, declaring `svg_image` so agents can identify which files own each feature slice before opening implementation code.
//! Bridges parsed XML vector trees and Lurek2D's RenderCommand drawing pipeline. `src/vector/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `svg_image::{SvgElement, SvgImage, SvgPath}` centralized for the vector subsystem.

/// SVG image document model, parser output structs, and render command conversion helpers.
pub mod svg_image;
pub use svg_image::{SvgElement, SvgImage, SvgPath};
