//! `src/font/mod.rs` is the font module index, exposing atlas, metrics, registry, and shaping surfaces in one place.
//! It reexports the public text stack so renderers, UI systems, and bindings can reach font services through one boundary.
//! No runtime font state lives here; this file defines visibility and navigation while implementation stays in child files.
//! Read this index when wiring text features, because it shows which font symbols are intentionally public and stable.
//! Changes here alter the typography boundary, since reexports decide what the engine and Lua-facing layers may import.
//! This module groups loading, measurement, shaping, and lookup concerns without collapsing them into one file.

/// Bitmap font atlas data and glyph lookup.
pub mod bitmap_font;
/// Glyph metrics and text measurement.
pub mod metrics;
/// Font registry and handle management.
pub mod registry;
/// Text shaping: word wrapping, line breaking, alignment.
pub mod shaping;

pub use bitmap_font::{BitmapFont, BitmapFontAtlas, AVAILABLE_SIZES};
pub use metrics::{GlyphMetrics, TextMetrics};
pub use registry::{FontHandle, FontRegistry, FontStyle};
pub use shaping::{shape_text, LineBreak, ShapedText, TextAlign, WordWrap};
