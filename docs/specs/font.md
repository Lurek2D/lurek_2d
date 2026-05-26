# `font`

## TL;DR
- CPU-side font loading, glyph metrics, text measurement, and shaping for bitmap fonts.

## General Info
- Module group: `Platform Services`
- Source path: `src/font/`
- Lua API path(s): `src/lua_api/font_api.rs`
- Primary Lua namespace: `lurek.font`
- Rust test path(s): `tests/rust/unit/font_tests.rs`
- Lua test path(s): `tests/lua/unit/test_font_core_unit.lua`

## Summary
The font module provides the CPU-side data layer for text rendering: bitmap font atlas loading with Latin-1 glyph coverage, per-glyph and per-text metrics, text alignment, word and character wrapping, and a central font registry for named handles. The module does not own GPU resources — texture management for font atlases remains in the render module. Fourteen bundled Courier New bitmap atlases are shipped in `assets/fonts/`.

## Files
- `mod.rs`: Module root and public re-exports.
- `bitmap_font.rs`: Bitmap font atlas loading and glyph lookup. Latin-1 coverage (0x20–0xFF).
- `metrics.rs`: GlyphMetrics, TextMetrics, text measurement without GPU.
- `shaping.rs`: Text alignment, word wrapping, character wrapping, shaped text.
- `registry.rs`: FontRegistry for named font handles, style management.

## Types
- `BitmapFont` (`struct`, `bitmap_font.rs`): Font atlas with glyph lookup.
- `BitmapFontAtlas` (`struct`, `bitmap_font.rs`): Raw atlas metadata (dimensions, cell size, codepoint range).
- `GlyphMetrics` (`struct`, `metrics.rs`): Per-glyph metrics: advance, bearing, UV coords.
- `TextMetrics` (`struct`, `metrics.rs`): Measured text: width, height, line count.
- `TextAlign` (`enum`, `shaping.rs`): Left, Center, Right, Justify.
- `WordWrap` (`enum`, `shaping.rs`): None, Word, Character.
- `FontRegistry` (`struct`, `registry.rs`): Central font handle manager.
- `FontHandle` (`struct`, `registry.rs`): Opaque reference to a loaded font.
- `FontStyle` (`enum`, `registry.rs`): Regular, Bold, Italic, BoldItalic.

## Functions
- `BitmapFont::glyph_info` (`bitmap_font.rs`): Look up glyph metrics for a codepoint.
- `BitmapFont::contains_glyph` (`bitmap_font.rs`): Check if a codepoint is present in the atlas.
- `BitmapFont::line_height` (`bitmap_font.rs`): Vertical advance between lines.
- `BitmapFont::point_size` (`bitmap_font.rs`): Nominal point size of the font.
- `BitmapFont::is_bold` (`bitmap_font.rs`): Whether this atlas represents a bold weight.
- `measure_text` (`metrics.rs`): Measure a multi-line string's bounding box.
- `measure_line` (`metrics.rs`): Measure a single line's width.
- `char_advance` (`metrics.rs`): Horizontal advance for a single character.
- `shape_text` (`shaping.rs`): Produce a shaped text layout with alignment and wrapping applied.
- `wrap_words` (`shaping.rs`): Break text into lines by word boundaries.
- `wrap_characters` (`shaping.rs`): Break text into lines by character limit.
- `FontRegistry::register` (`registry.rs`): Add a font to the registry under a name.
- `FontRegistry::get` (`registry.rs`): Retrieve a font handle by ID.
- `FontRegistry::get_by_name` (`registry.rs`): Retrieve a font handle by registered name.
- `FontRegistry::default_font` (`registry.rs`): Return the engine default font handle.
- `FontRegistry::list_fonts` (`registry.rs`): List all registered font names.

## Lua API Reference
- Binding path(s): `src/lua_api/font_api.rs`
- Namespace: `lurek.font`

### Module Functions
- `lurek.font.getDefault()` → LuaFont: Return the engine default font.
- `lurek.font.load(name, size)` → LuaFont: Load a registered font at the given pixel size.
- `lurek.font.loadBitmap(path, cellW, cellH)` → LuaFont: Load a bitmap font from an atlas image.
- `lurek.font.list()` → table: List all registered font names.
- `lurek.font.availableSizes(name)` → table: List available pixel sizes for a named font.
- `lurek.font.measure(font, text)` → width, height: Measure text with a font.
- `lurek.font.measureLine(font, text)` → number: Measure a single line's width.
- `lurek.font.wrapText(font, text, maxWidth, mode)` → table: Wrap text into lines.
- `lurek.font.shapeText(font, text, opts)` → table: Shape text with alignment and wrapping.
- `lurek.font.charAdvance(font, char)` → number: Horizontal advance for a character.
- `lurek.font.lineHeight(font)` → number: Line height for a font.

### Constants
- `lurek.font.ALIGN_LEFT`, `ALIGN_CENTER`, `ALIGN_RIGHT`, `ALIGN_JUSTIFY`
- `lurek.font.WRAP_NONE`, `WRAP_WORD`, `WRAP_CHAR`
- `lurek.font.STYLE_REGULAR`, `STYLE_BOLD`

### Userdata Methods
- `font:getName()` → string: Return the font's registered name.
- `font:getSize()` → number: Return the font's pixel size.
- `font:getStyle()` → string: Return the font style (regular, bold, etc.).
- `font:isBold()` → boolean: Whether this font is bold.
- `font:lineHeight()` → number: Line height for this font.
- `font:measure(text)` → width, height: Measure text with this font.
- `font:wrapText(text, maxWidth, mode)` → table: Wrap text into lines.
- `font:containsGlyph(char)` → boolean: Check if the font contains a glyph.

## Notes
- The `src/font/` module owns the CPU-side font data layer: metrics, measurement, shaping, registry.
- The `src/render/font.rs` module owns the GPU-facing Font struct (atlas textures, glyph rendering).
- `render/font.rs` re-exports shared data types from `src/font/` for backward compatibility.
- New code should import font data types from `crate::font::*` directly.
- 14 bundled Courier New bitmap atlases remain in `assets/fonts/`.

## References
- [render.md](render.md) — GPU texture management for font atlases.
- [ui.md](ui.md) — primary consumer of text shaping for widget layout.
- Example: `content/examples/font.lua`
