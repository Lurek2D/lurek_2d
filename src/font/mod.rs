//! Font subsystem: glyph metrics, text measurement, word wrapping, and font registry.

/// Bitmap font atlas data and glyph lookup.
pub mod bitmap_font;
/// Glyph metrics and text measurement.
pub mod metrics;
/// Text shaping: word wrapping, line breaking, alignment.
pub mod shaping;
/// Font registry and handle management.
pub mod registry;

pub use bitmap_font::{BitmapFont, BitmapFontAtlas, AVAILABLE_SIZES};
pub use metrics::{GlyphMetrics, TextMetrics};
pub use shaping::{LineBreak, ShapedText, TextAlign, WordWrap, shape_text};
pub use registry::{FontHandle, FontRegistry, FontStyle};
