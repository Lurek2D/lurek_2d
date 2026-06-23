//! `src/font/mod.rs` is the font module index, exposing atlas, metrics, registry, and shaping surfaces in one place.
//! It reexports the public text stack so renderers, UI systems, and bindings can reach font services through one boundary.
//! Runtime font atlas state lives in `runtime_font`, while this file defines visibility and navigation.
//! Read this index when wiring text features, because it shows which font symbols are intentionally public and stable.
//! Changes here alter the typography boundary, since reexports decide what the engine and Lua-facing layers may import.
//! This module groups loading, measurement, shaping, and lookup concerns without collapsing them into one file.

/// Bitmap font atlas data and glyph lookup.
pub mod bitmap_font;
/// Glyph metrics and text measurement.
pub mod metrics;
/// Font registry and handle management.
pub mod registry;
/// Runtime font atlas loading, glyph UVs, and dynamic rasterization.
pub mod runtime_font;
/// Text shaping: word wrapping, line breaking, alignment.
pub mod shaping;

pub use bitmap_font::{BitmapFont, BitmapFontAtlas, AVAILABLE_SIZES};
pub use metrics::{GlyphMetrics, TextMetrics};
pub use registry::{FontHandle, FontRegistry, FontStyle};
pub use runtime_font::{
    validate_dynamic_font_atlas_dimensions, validate_dynamic_font_point_size, Font,
    FontGlyphMetrics, GlyphInfo, AVAILABLE_BOLD_NAMES, AVAILABLE_CELL_SIZES, AVAILABLE_HEIGHTS,
    AVAILABLE_POINT_SIZES, AVAILABLE_REGULAR_NAMES, BUILTIN_FONT_NAMES, FIRST_CODEPOINT,
    GLYPH_COUNT, LAST_CODEPOINT, MAX_DYNAMIC_FONT_ATLAS_BYTES, MAX_DYNAMIC_FONT_ATLAS_DIMENSION,
    MAX_DYNAMIC_FONT_POINT_SIZE, NUM_SIZES,
};
pub use shaping::{shape_text, LineBreak, ShapedText, TextAlign, WordWrap};
