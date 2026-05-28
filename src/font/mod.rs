//! Font subsystem: glyph metrics, text measurement, word wrapping, and font registry.
//!
//! - Bitmap font atlas loading and glyph lookup.
//! - Runtime TTF/OTF rasterisation into atlas format via fontdue.
//! - Text measurement and word wrapping without GPU dependency.
//! - Font registry for named font handles.

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
