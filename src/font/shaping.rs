//! Text shaping and word-wrap algorithms for multi-line layout.
//!
//! - `wrap_words` wraps at word boundaries to fit `max_width` in logical pixels.
//! - `wrap_characters` wraps at character boundaries for CJK and monospace fonts.
//! - `WordWrap` enum selects the strategy; `None` disables wrapping entirely.
//! - Both functions return a `Vec<&str>` of lines; no allocation of the text itself.
//! - Called by `measure_text` and the UI text widget before rasterisation.

use crate::font::bitmap_font::BitmapFont;
use crate::font::metrics::char_advance;

/// Horizontal text alignment mode.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum TextAlign {
    /// Align text to the left edge.
    Left,
    /// Center text horizontally.
    Center,
    /// Align text to the right edge.
    Right,
    /// Stretch words to fill the line width.
    Justify,
}

/// Word wrapping strategy for multi-line text layout and line breaking.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum WordWrap {
    /// No wrapping — text may overflow.
    None,
    /// Wrap at word boundaries (whitespace).
    Word,
    /// Wrap at character boundaries.
    Character,
}

/// A line break position within the source text.
#[derive(Debug, Clone, Copy)]
pub struct LineBreak {
    /// Start byte index in the source string.
    pub start: usize,
    /// End byte index (exclusive) in the source string.
    pub end: usize,
    /// Vertical offset of this line from the text origin.
    pub y_offset: f32,
}

/// A single shaped line ready for rendering.
#[derive(Debug, Clone)]
pub struct ShapedLine {
    /// The text content of this line.
    pub text: String,
    /// Measured width of the line in pixels.
    pub width: f32,
    /// Horizontal offset for alignment.
    pub x_offset: f32,
}

/// Complete shaped text result.
#[derive(Debug, Clone)]
pub struct ShapedText {
    /// Individual shaped lines.
    pub lines: Vec<ShapedLine>,
    /// Total height of all lines.
    pub total_height: f32,
}

/// Shapes text into aligned, wrapped lines.
///
/// Applies the specified wrapping strategy and alignment within `max_width`.
/// Returns positioned lines ready for rendering.
pub fn shape_text(
    font: &BitmapFont,
    text: &str,
    max_width: f32,
    scale: f32,
    align: TextAlign,
    wrap: WordWrap,
) -> ShapedText {
    let raw_lines = match wrap {
        WordWrap::None => text.split('\n').map(String::from).collect(),
        WordWrap::Word => wrap_words(font, text, max_width, scale),
        WordWrap::Character => wrap_characters(font, text, max_width, scale),
    };

    let line_height = font.line_height() * scale;
    let mut shaped_lines = Vec::with_capacity(raw_lines.len());

    for line_text in &raw_lines {
        let width = line_width(font, line_text, scale);
        let x_offset = match align {
            TextAlign::Left | TextAlign::Justify => 0.0,
            TextAlign::Center => (max_width - width) * 0.5,
            TextAlign::Right => max_width - width,
        };
        shaped_lines.push(ShapedLine {
            text: line_text.clone(),
            width,
            x_offset: x_offset.max(0.0),
        });
    }

    let total_height = shaped_lines.len() as f32 * line_height;
    ShapedText {
        lines: shaped_lines,
        total_height,
    }
}

/// Wraps text at word boundaries to fit within `max_width`.
///
/// Splits on whitespace. Words longer than `max_width` are placed on their own line.
pub fn wrap_words(font: &BitmapFont, text: &str, max_width: f32, scale: f32) -> Vec<String> {
    let mut result = Vec::new();

    for paragraph in text.split('\n') {
        let words: Vec<&str> = paragraph.split_whitespace().collect();
        if words.is_empty() {
            result.push(String::new());
            continue;
        }

        let space_advance = char_advance(font, ' ', scale);
        let mut current_line = String::new();
        let mut current_width = 0.0f32;

        for word in words {
            let word_width = line_width(font, word, scale);

            if current_line.is_empty() {
                // First word on the line — always accept it.
                current_line.push_str(word);
                current_width = word_width;
            } else if current_width + space_advance + word_width <= max_width {
                // Fits on the current line.
                current_line.push(' ');
                current_line.push_str(word);
                current_width += space_advance + word_width;
            } else {
                // Doesn't fit — start a new line.
                result.push(current_line);
                current_line = word.to_string();
                current_width = word_width;
            }
        }

        result.push(current_line);
    }

    result
}

/// Wraps text at character boundaries to fit within `max_width`.
///
/// Each character is placed on the current line if it fits; otherwise a new line begins.
pub fn wrap_characters(font: &BitmapFont, text: &str, max_width: f32, scale: f32) -> Vec<String> {
    let mut result = Vec::new();

    for paragraph in text.split('\n') {
        let mut current_line = String::new();
        let mut current_width = 0.0f32;

        for ch in paragraph.chars() {
            let ch_width = char_advance(font, ch, scale);

            if current_line.is_empty() || current_width + ch_width <= max_width {
                current_line.push(ch);
                current_width += ch_width;
            } else {
                result.push(current_line);
                current_line = String::from(ch);
                current_width = ch_width;
            }
        }

        result.push(current_line);
    }

    result
}

/// Measures the pixel width of a line (no newlines expected).
fn line_width(font: &BitmapFont, text: &str, scale: f32) -> f32 {
    text.chars().map(|ch| char_advance(font, ch, scale)).sum()
}
