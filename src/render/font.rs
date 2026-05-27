//! Bitmap font atlas loading and runtime font rasterisation.
//!
//! This module provides:
//! - Bundled Courier New bitmap atlases in regular and bold variants.
//! - Latin-1 coverage for 0x20..=0xFF.
//! - Terminal-symbol aliases for 0x80..=0x9F and direct Unicode lookups.
//! - Runtime rasterisation of TTF/OTF fonts into the same atlas format.
//! - Glyph metrics, text measurement, and word wrapping.

// Re-export the CPU-side font types from the font module for backward compatibility.
pub use crate::font::{TextMetrics, TextAlign, WordWrap, FontStyle};
pub use crate::font::GlyphMetrics as FontGlyphMetrics;

use crate::runtime::error::{EngineError, EngineResult};
use fontdue::{Font as RuntimeFont, FontSettings};
use std::cmp::{max, min};

const FONT_PT_TO_PX: f32 = 96.0 / 72.0;
const CELL_PADDING: i32 = 1;
const GLYPH_COLUMNS: u32 = 16;

/// First Unicode codepoint included in the bundled bitmap atlas range.
pub const FIRST_CODEPOINT: u32 = 0x20;
/// Last Unicode codepoint included in the bundled bitmap atlas range.
pub const LAST_CODEPOINT: u32 = 0xFF;
/// Total number of glyph slots covered by the bundled bitmap atlas range.
pub const GLYPH_COUNT: usize = (LAST_CODEPOINT - FIRST_CODEPOINT + 1) as usize;

// --- Courier New regular (7 sizes: 8/10/12/16/20/24/30 pt at 96 DPI) ---
const FONT_R_8: &[u8] = include_bytes!("../../assets/fonts/font_8.png");
const FONT_R_10: &[u8] = include_bytes!("../../assets/fonts/font_10.png");
const FONT_R_12: &[u8] = include_bytes!("../../assets/fonts/font_12.png");
const FONT_R_16: &[u8] = include_bytes!("../../assets/fonts/font_16.png");
const FONT_R_20: &[u8] = include_bytes!("../../assets/fonts/font_20.png");
const FONT_R_24: &[u8] = include_bytes!("../../assets/fonts/font_24.png");
const FONT_R_30: &[u8] = include_bytes!("../../assets/fonts/font_30.png");

// --- Courier New bold (7 sizes: 8/10/12/16/20/24/30 pt at 96 DPI) ---
const FONT_B_8: &[u8] = include_bytes!("../../assets/fonts/fontb_8.png");
const FONT_B_10: &[u8] = include_bytes!("../../assets/fonts/fontb_10.png");
const FONT_B_12: &[u8] = include_bytes!("../../assets/fonts/fontb_12.png");
const FONT_B_16: &[u8] = include_bytes!("../../assets/fonts/fontb_16.png");
const FONT_B_20: &[u8] = include_bytes!("../../assets/fonts/fontb_20.png");
const FONT_B_24: &[u8] = include_bytes!("../../assets/fonts/fontb_24.png");
const FONT_B_30: &[u8] = include_bytes!("../../assets/fonts/fontb_30.png");

/// Number of bundled font sizes.
pub const NUM_SIZES: usize = 7;
/// Point sizes used to generate the bundled atlases.
pub const AVAILABLE_POINT_SIZES: [u32; NUM_SIZES] = [8, 10, 12, 16, 20, 24, 30];
/// Cell heights (pixels) for each bundled size slot.
pub const AVAILABLE_HEIGHTS: [u32; NUM_SIZES] = [16, 17, 21, 27, 34, 39, 49];
/// `(cell_width, cell_height)` pairs for each bundled size slot.
pub const AVAILABLE_CELL_SIZES: [(u32, u32); NUM_SIZES] = [
    (9, 16),
    (10, 17),
    (12, 21),
    (15, 27),
    (18, 34),
    (21, 39),
    (26, 49),
];
/// Stable built-in names for regular bundled fonts.
pub const AVAILABLE_REGULAR_NAMES: [&str; NUM_SIZES] = [
    "font_8", "font_10", "font_12", "font_16", "font_20", "font_24", "font_30",
];
/// Stable built-in names for bold bundled fonts.
pub const AVAILABLE_BOLD_NAMES: [&str; NUM_SIZES] = [
    "fontb_8", "fontb_10", "fontb_12", "fontb_16", "fontb_20", "fontb_24", "fontb_30",
];
/// Full built-in font list in regular-then-bold order.
pub const BUILTIN_FONT_NAMES: [&str; NUM_SIZES * 2] = [
    "font_8", "font_10", "font_12", "font_16", "font_20", "font_24", "font_30", "fontb_8",
    "fontb_10", "fontb_12", "fontb_16", "fontb_20", "fontb_24", "fontb_30",
];

const C1_SUBSTITUTES: [char; 32] = [
    '─', '│', '┌', '┐', '└', '┘', '├', '┤', '┬', '┴', '┼', '═', '║', '╔', '╗', '╚', '╝', '╠', '╣',
    '╦', '╩', '╬', '░', '▒', '▓', '█', '▀', '▄', '▲', '▼', '◄', '►',
];

#[derive(Debug, Clone, Copy)]
struct GlyphMetrics {
    atlas_offset_x: u32,
    atlas_offset_y: u32,
    width: u32,
    height: u32,
    advance_width: f32,
    offset_x: f32,
    offset_y: f32,
}

/// UV-space coordinates and pixel metrics for a single bitmap glyph.
#[derive(Debug, Clone, Copy)]
pub struct GlyphInfo {
    /// Left UV edge of the glyph in the atlas, 0.0..1.0.
    pub uv_x: f32,
    /// Top UV edge of the glyph in the atlas, 0.0..1.0.
    pub uv_y: f32,
    /// UV width of the glyph, 0.0..1.0.
    pub uv_w: f32,
    /// UV height of the glyph, 0.0..1.0.
    pub uv_h: f32,
    /// Pixel width of the glyph bitmap.
    pub width: u32,
    /// Pixel height of the glyph bitmap.
    pub height: u32,
    /// Pixel advance width after this glyph.
    pub advance_width: f32,
    /// Pixel X offset from pen position to glyph origin.
    pub offset_x: f32,
    /// Pixel Y offset encoded in the renderer's expected atlas space.
    pub offset_y: f32,
}

/// Bitmap font atlas queried for per-character UVs and text metrics.
pub struct Font {
    atlas_bitmap: Vec<u8>,
    atlas_width: u32,
    atlas_height: u32,
    cell_width: u32,
    cell_height: u32,
    glyphs: Vec<Option<GlyphMetrics>>,
    ascent: f32,
    descent: f32,
    line_height_mul: f32,
    dirty: bool,
}

fn atlas_rows() -> u32 {
    GLYPH_COUNT.div_ceil(GLYPH_COLUMNS as usize) as u32
}

fn c1_substitute_for_codepoint(cp: u32) -> Option<char> {
    if (0x80..=0x9F).contains(&cp) {
        Some(C1_SUBSTITUTES[(cp - 0x80) as usize])
    } else {
        None
    }
}

fn substitute_slot_for_char(ch: char) -> Option<u32> {
    C1_SUBSTITUTES
        .iter()
        .position(|candidate| *candidate == ch)
        .map(|idx| 0x80 + idx as u32)
}

fn atlas_char_for_codepoint(cp: u32) -> Option<char> {
    if let Some(ch) = c1_substitute_for_codepoint(cp) {
        return Some(ch);
    }
    char::from_u32(cp)
}

impl Font {
    /// Returns the built-in slot and bold flag for a stable built-in font name.
    pub fn builtin_slot_by_name(name: &str) -> Option<(usize, bool)> {
        if let Some(slot) = AVAILABLE_REGULAR_NAMES
            .iter()
            .position(|candidate| *candidate == name)
        {
            return Some((slot, false));
        }
        AVAILABLE_BOLD_NAMES
            .iter()
            .position(|candidate| *candidate == name)
            .map(|slot| (slot, true))
    }

    /// Loads a PNG atlas with fixed-size cells.
    pub fn from_png_bytes(
        data: &[u8],
        cell_w: u32,
        cell_h: u32,
        _has_box: bool,
    ) -> EngineResult<Font> {
        let img = image::load_from_memory(data)
            .map_err(|e| {
                EngineError::RenderError(format!("Failed to decode bitmap font PNG: {e}"))
            })?
            .to_rgba8();
        let atlas_width = img.width();
        let atlas_height = img.height();
        let atlas_bitmap = img.into_raw();
        let glyph = GlyphMetrics {
            atlas_offset_x: 0,
            atlas_offset_y: 0,
            width: cell_w,
            height: cell_h,
            advance_width: (cell_w as f32 - 1.0).max(1.0),
            offset_x: 0.0,
            offset_y: 0.0,
        };
        Ok(Font {
            atlas_bitmap,
            atlas_width,
            atlas_height,
            cell_width: cell_w,
            cell_height: cell_h,
            glyphs: vec![Some(glyph); GLYPH_COUNT],
            ascent: cell_h as f32,
            descent: 0.0,
            line_height_mul: 1.0,
            dirty: true,
        })
    }

    /// Rasterises TTF/OTF bytes into the same atlas format used by bundled fonts.
    pub fn from_font_bytes(data: &[u8], point_size: f32) -> EngineResult<Font> {
        let font = RuntimeFont::from_bytes(data, FontSettings::default())
            .map_err(|e| EngineError::RenderError(format!("Failed to parse font bytes: {e}")))?;
        let pixel_size = (point_size.max(1.0) * FONT_PT_TO_PX).round().max(1.0);
        let display_chars: Vec<char> = (FIRST_CODEPOINT..=LAST_CODEPOINT)
            .filter_map(atlas_char_for_codepoint)
            .collect();

        let mut min_left = 0i32;
        let mut max_right = 0i32;
        let mut max_above_baseline = 0i32;
        let mut max_below_baseline = 0i32;
        let mut rasterized = Vec::with_capacity(GLYPH_COUNT);

        for ch in &display_chars {
            let (metrics, bitmap) = font.rasterize(*ch, pixel_size);
            let left = metrics.xmin;
            let right = metrics.xmin + metrics.width as i32;
            let above_baseline = max(0, metrics.height as i32 + metrics.ymin);
            let below_baseline = max(0, -metrics.ymin);
            min_left = min(min_left, left);
            max_right = max(max_right, right);
            max_above_baseline = max(max_above_baseline, above_baseline);
            max_below_baseline = max(max_below_baseline, below_baseline);
            rasterized.push((metrics, bitmap));
        }

        let cell_w = (max_right - min_left + CELL_PADDING * 2).max(1) as u32;
        let cell_h = (max_above_baseline + max_below_baseline + CELL_PADDING * 2).max(1) as u32;
        let atlas_width = cell_w * GLYPH_COLUMNS;
        let atlas_height = cell_h * atlas_rows();
        let mut atlas_bitmap = vec![0u8; (atlas_width * atlas_height * 4) as usize];
        let mut glyphs = Vec::with_capacity(GLYPH_COUNT);

        for (idx, (metrics, bitmap)) in rasterized.into_iter().enumerate() {
            let col = idx as u32 % GLYPH_COLUMNS;
            let row = idx as u32 / GLYPH_COLUMNS;
            let draw_x = CELL_PADDING + (metrics.xmin - min_left);
            let above_baseline = max(0, metrics.height as i32 + metrics.ymin);
            let draw_y = CELL_PADDING + (max_above_baseline - above_baseline);

            if metrics.width > 0 && metrics.height > 0 {
                for py in 0..metrics.height {
                    for px in 0..metrics.width {
                        let src = bitmap[py * metrics.width + px];
                        if src == 0 {
                            continue;
                        }
                        let atlas_x = col * cell_w + draw_x as u32 + px as u32;
                        let atlas_y = row * cell_h + draw_y as u32 + py as u32;
                        let atlas_idx = ((atlas_y * atlas_width + atlas_x) * 4) as usize;
                        atlas_bitmap[atlas_idx] = 255;
                        atlas_bitmap[atlas_idx + 1] = 255;
                        atlas_bitmap[atlas_idx + 2] = 255;
                        atlas_bitmap[atlas_idx + 3] = 255;
                    }
                }
            }

            glyphs.push(Some(GlyphMetrics {
                atlas_offset_x: draw_x.max(0) as u32,
                atlas_offset_y: draw_y.max(0) as u32,
                width: metrics.width as u32,
                height: metrics.height as u32,
                advance_width: metrics.advance_width.max(1.0),
                offset_x: metrics.xmin as f32,
                offset_y: cell_h as f32 - metrics.height as f32 - draw_y as f32,
            }));
        }

        Ok(Font {
            atlas_bitmap,
            atlas_width,
            atlas_height,
            cell_width: cell_w,
            cell_height: cell_h,
            glyphs,
            ascent: (max_above_baseline + CELL_PADDING) as f32,
            descent: (max_below_baseline + CELL_PADDING) as f32,
            line_height_mul: 1.0,
            dirty: true,
        })
    }

    /// Loads all bundled regular fonts.
    pub fn load_all_sizes() -> Vec<(Font, u32, u32)> {
        let specs: [(u32, u32, &[u8]); NUM_SIZES] = [
            (9, 16, FONT_R_8),
            (10, 17, FONT_R_10),
            (12, 21, FONT_R_12),
            (15, 27, FONT_R_16),
            (18, 34, FONT_R_20),
            (21, 39, FONT_R_24),
            (26, 49, FONT_R_30),
        ];
        Self::load_specs(&specs)
    }

    /// Loads all bundled bold fonts.
    pub fn load_all_bold() -> Vec<(Font, u32, u32)> {
        let specs: [(u32, u32, &[u8]); NUM_SIZES] = [
            (9, 16, FONT_B_8),
            (10, 17, FONT_B_10),
            (12, 21, FONT_B_12),
            (15, 27, FONT_B_16),
            (18, 34, FONT_B_20),
            (21, 39, FONT_B_24),
            (26, 49, FONT_B_30),
        ];
        Self::load_specs(&specs)
    }

    fn load_specs(specs: &[(u32, u32, &[u8])]) -> Vec<(Font, u32, u32)> {
        specs
            .iter()
            .filter_map(
                |&(cw, ch, data)| match Font::from_png_bytes(data, cw, ch, false) {
                    Ok(font) => Some((font, cw, ch)),
                    Err(e) => {
                        log::warn!("Failed to load bitmap font {}x{}: {}", cw, ch, e);
                        None
                    }
                },
            )
            .collect()
    }

    /// Returns the slot whose height is closest to `pixel_height`.
    pub fn nearest_size(pixel_height: u32) -> usize {
        let mut best = 0;
        let mut best_diff = u32::MAX;
        for (i, &h) in AVAILABLE_HEIGHTS.iter().enumerate() {
            let diff = pixel_height.abs_diff(h);
            if diff < best_diff {
                best_diff = diff;
                best = i;
            }
        }
        best
    }

    /// Returns the slot whose built-in point size is closest to `point_size`.
    pub fn nearest_point_size(point_size: u32) -> usize {
        let mut best = 0;
        let mut best_diff = u32::MAX;
        for (i, &size) in AVAILABLE_POINT_SIZES.iter().enumerate() {
            let diff = point_size.abs_diff(size);
            if diff < best_diff {
                best_diff = diff;
                best = i;
            }
        }
        best
    }

    fn glyph_index(&self, ch: char) -> Option<usize> {
        let cp = ch as u32;
        if (FIRST_CODEPOINT..=LAST_CODEPOINT).contains(&cp) {
            return Some((cp - FIRST_CODEPOINT) as usize);
        }
        substitute_slot_for_char(ch).map(|alias_cp| (alias_cp - FIRST_CODEPOINT) as usize)
    }

    /// Returns glyph info for `ch`, or `None` if the character is not present.
    pub fn glyph(&self, ch: char) -> Option<GlyphInfo> {
        let glyph_idx = self.glyph_index(ch)?;
        let metrics = self.glyphs.get(glyph_idx).copied().flatten()?;
        let col = glyph_idx as u32 % GLYPH_COLUMNS;
        let row = glyph_idx as u32 / GLYPH_COLUMNS;
        let px_x = col * self.cell_width + metrics.atlas_offset_x;
        let px_y = row * self.cell_height + metrics.atlas_offset_y;
        Some(GlyphInfo {
            uv_x: px_x as f32 / self.atlas_width as f32,
            uv_y: px_y as f32 / self.atlas_height as f32,
            uv_w: metrics.width as f32 / self.atlas_width as f32,
            uv_h: metrics.height as f32 / self.atlas_height as f32,
            width: metrics.width,
            height: metrics.height,
            advance_width: metrics.advance_width,
            offset_x: metrics.offset_x,
            offset_y: metrics.offset_y,
        })
    }

    /// Returns the summed advance width for `text`.
    pub fn text_width(&self, text: &str) -> f32 {
        let mut width = 0.0;
        for ch in text.chars() {
            if let Some(info) = self.glyph(ch) {
                width += info.advance_width;
            }
        }
        width
    }

    /// Returns the effective line height in pixels.
    pub fn line_height(&self) -> f32 {
        self.cell_height as f32 * self.line_height_mul
    }

    /// Sets the line-height multiplier.
    pub fn set_line_height(&mut self, mul: f32) {
        self.line_height_mul = mul.max(0.01);
    }

    /// Returns the font ascent in pixels.
    pub fn ascent(&self) -> f32 {
        self.ascent
    }

    /// Returns the font descent in pixels.
    pub fn descent(&self) -> f32 {
        self.descent
    }

    /// Returns atlas upload data as `(pixel_data, width, height)`.
    pub fn atlas_data(&self) -> (&[u8], u32, u32) {
        (&self.atlas_bitmap, self.atlas_width, self.atlas_height)
    }

    /// Returns true when the atlas still needs GPU upload.
    pub fn is_dirty(&self) -> bool {
        self.dirty
    }

    /// Clears the dirty flag after upload.
    pub fn mark_clean(&mut self) {
        self.dirty = false;
    }

    /// Returns the nominal cell height in pixels.
    pub fn size(&self) -> f32 {
        self.cell_height as f32
    }

    /// Returns the nominal cell width in pixels.
    pub fn cell_width(&self) -> u32 {
        self.cell_width
    }

    /// Wraps text by pixel width while honoring explicit newlines.
    pub fn wrap_text(&self, text: &str, limit: f32) -> Vec<String> {
        let mut lines = Vec::new();
        for line in text.split('\n') {
            if line.is_empty() {
                lines.push(String::new());
                continue;
            }
            let words: Vec<&str> = line.split_whitespace().collect();
            if words.is_empty() {
                lines.push(String::new());
                continue;
            }
            let mut current_line = String::new();
            for word in words {
                let test = if current_line.is_empty() {
                    word.to_string()
                } else {
                    format!("{} {}", current_line, word)
                };
                if self.text_width(&test) > limit && !current_line.is_empty() {
                    lines.push(current_line);
                    current_line = word.to_string();
                } else {
                    current_line = test;
                }
            }
            if !current_line.is_empty() {
                lines.push(current_line);
            }
        }
        if lines.is_empty() {
            lines.push(String::new());
        }
        lines
    }
}
