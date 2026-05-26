//! Bitmap font loader and glyph atlas builder for fixed-size sprite fonts.
//!
//! - Parses BMFont `.fnt` descriptor files (text and binary formats).
//! - Builds a glyph atlas mapping codepoints to UV rectangles in a texture.
//! - Kerning pairs are stored and applied during layout for tighter spacing.
//! - Atlas textures are loaded through `GameFS` and cached in the font registry.
//! - Used when the game explicitly requests a bitmap font over a TTF/OTF font.

use crate::font::metrics::GlyphMetrics;

/// First codepoint in the bitmap atlas (space character).
pub const FIRST_CODEPOINT: u32 = 0x20;

/// Last codepoint in the bitmap atlas (Latin-1 supplement end).
pub const LAST_CODEPOINT: u32 = 0xFF;

/// Available pre-built bitmap font point sizes.
pub const AVAILABLE_SIZES: &[u32] = &[8, 10, 12, 16, 20, 24, 30];

/// Atlas metadata describing the texture layout.
#[derive(Debug, Clone)]
pub struct BitmapFontAtlas {
    /// Atlas texture width in pixels.
    pub width: u32,
    /// Atlas texture height in pixels.
    pub height: u32,
    /// Cell width in pixels (uniform grid).
    pub cell_width: u32,
    /// Cell height in pixels (uniform grid).
    pub cell_height: u32,
    /// Number of columns in the atlas grid.
    pub columns: u32,
}

/// A bitmap font with pre-rasterised glyphs and lookup table.
#[derive(Debug, Clone)]
pub struct BitmapFont {
    /// Atlas layout metadata.
    pub atlas: BitmapFontAtlas,
    /// Glyph metrics indexed by (codepoint - FIRST_CODEPOINT).
    glyphs: Vec<GlyphMetrics>,
    /// Font point size.
    size: u32,
    /// Whether this is the bold variant.
    bold: bool,
    /// Line height in pixels.
    line_height: f32,
}

impl BitmapFont {
    /// Creates a new bitmap font from atlas metadata and glyph table.
    pub fn new(
        atlas: BitmapFontAtlas,
        glyphs: Vec<GlyphMetrics>,
        size: u32,
        bold: bool,
        line_height: f32,
    ) -> Self {
        Self {
            atlas,
            glyphs,
            size,
            bold,
            line_height,
        }
    }

    /// Retrieves glyph metrics for the given codepoint.
    ///
    /// Returns `None` if the codepoint is outside the supported range.
    pub fn glyph_info(&self, codepoint: u32) -> Option<&GlyphMetrics> {
        if codepoint < FIRST_CODEPOINT || codepoint > LAST_CODEPOINT {
            return None;
        }
        let index = (codepoint - FIRST_CODEPOINT) as usize;
        self.glyphs.get(index)
    }

    /// Returns `true` if the font contains a glyph for the given codepoint.
    pub fn contains_glyph(&self, codepoint: u32) -> bool {
        codepoint >= FIRST_CODEPOINT
            && codepoint <= LAST_CODEPOINT
            && ((codepoint - FIRST_CODEPOINT) as usize) < self.glyphs.len()
    }

    /// Returns the line height in pixels.
    pub fn line_height(&self) -> f32 {
        self.line_height
    }

    /// Returns the current font point size.
    pub fn point_size(&self) -> u32 {
        self.size
    }

    /// Returns `true` if this is the bold variant.
    pub fn is_bold(&self) -> bool {
        self.bold
    }
}
