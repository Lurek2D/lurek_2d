//! Font metrics and multi-line text measurement utilities.
//!
//! - Data types: `GlyphMetrics`, `LineMetrics`, `TextMetrics`.
//! - Functions: `measure_text`, `measure_line`, `char_advance`.

use crate::font::bitmap_font::BitmapFont;

/// Per-glyph metric data including UV coordinates and pixel dimensions.
#[derive(Debug, Clone, Copy)]
pub struct GlyphMetrics {
    /// Horizontal advance width in pixels.
    pub advance_width: f32,
    /// Horizontal bearing (offset from cursor to glyph left edge).
    pub bearing_x: f32,
    /// Vertical bearing (offset from baseline to glyph top edge).
    pub bearing_y: f32,
    /// Glyph bitmap width in pixels.
    pub width: u32,
    /// Glyph bitmap height in pixels.
    pub height: u32,
    /// U coordinate of the glyph in the atlas (normalised 0..1).
    pub uv_x: f32,
    /// V coordinate of the glyph in the atlas (normalised 0..1).
    pub uv_y: f32,
    /// Width of the glyph region in the atlas (normalised 0..1).
    pub uv_w: f32,
    /// Height of the glyph region in the atlas (normalised 0..1).
    pub uv_h: f32,
}

/// Metrics for a single line of measured text.
#[derive(Debug, Clone)]
pub struct LineMetrics {
    /// Total width of the line in pixels.
    pub width: f32,
    /// Number of glyphs in the line.
    pub glyph_count: u32,
    /// Start byte index in the source string.
    pub start_index: usize,
    /// End byte index (exclusive) in the source string.
    pub end_index: usize,
}

/// Result of measuring a block of text.
#[derive(Debug, Clone)]
pub struct TextMetrics {
    /// Maximum width across all lines.
    pub width: f32,
    /// Total height of all lines.
    pub height: f32,
    /// Number of lines.
    pub line_count: u32,
    /// Per-line metric data.
    pub lines: Vec<LineMetrics>,
}

/// Measures a full block of text, splitting on newline characters.
///
/// Returns aggregate dimensions and per-line metrics.
pub fn measure_text(font: &BitmapFont, text: &str, scale: f32) -> TextMetrics {
    let mut lines = Vec::new();
    let mut max_width: f32 = 0.0;
    let mut offset = 0usize;

    for line_str in text.split('\n') {
        let start = offset;
        let end = offset + line_str.len();
        let (w, _h) = measure_line(font, line_str, scale);
        let glyph_count = line_str.chars().count() as u32;

        max_width = max_width.max(w);
        lines.push(LineMetrics {
            width: w,
            glyph_count,
            start_index: start,
            end_index: end,
        });

        // +1 for the newline character itself (except at the very end)
        offset = end + 1;
    }

    let line_count = lines.len() as u32;
    let height = line_count as f32 * font.line_height() * scale;

    TextMetrics {
        width: max_width,
        height,
        line_count,
        lines,
    }
}

/// Measures a single line of text, returning (width, height).
///
/// Does not handle newline characters — use [`measure_text`] for multi-line.
pub fn measure_line(font: &BitmapFont, text: &str, scale: f32) -> (f32, f32) {
    let mut width = 0.0f32;
    for ch in text.chars() {
        width += char_advance(font, ch, scale);
    }
    let height = font.line_height() * scale;
    (width, height)
}

/// Returns the horizontal advance for a single character at the given scale.
///
/// Falls back to the space character advance if the glyph is missing.
pub fn char_advance(font: &BitmapFont, ch: char, scale: f32) -> f32 {
    let codepoint = ch as u32;
    if let Some(glyph) = font.glyph_info(codepoint) {
        glyph.advance_width * scale
    } else {
        // Fallback: use space advance or zero
        font.glyph_info(0x20)
            .map(|g| g.advance_width * scale)
            .unwrap_or(0.0)
    }
}
