//! Provides the high-level font module boundary for glyph data, layout shaping, and registry access. `font/mod` is the font module index, declaring `bitmap_font`, `metrics`, `registry`, `shaping` so agents can identify which files own each feature slice before opening implementation code.
//! Connects bitmap atlas handling, metrics evaluation, and wrap logic into one typography service surface. `src/font/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `bitmap_font::{BitmapFont, BitmapFontAtlas, AVAILABLE_SIZES}`, `metrics::{GlyphMetrics, TextMetrics}`, `registry::{FontHandle, FontRegistry, FontStyle}`, `shaping::{shape_text, LineBreak, ShapedText, TextAlign, WordWrap}` centralized for the font subsystem.

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
