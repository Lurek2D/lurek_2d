# font

## TL;DR

- CPU-side font loading, glyph metrics, text measurement, and shaping for bitmap fonts.

## General Info

- Module group: `Platform Services`
- Source path: `src/font/`
- Lua API path(s): `src/lua_api/font_api.rs`
- Primary Lua namespace: `lurek.font`
- Rust test path(s): tests/rust/unit/font_tests.rs
- Lua test path(s): tests/lua/unit/test_font_core_unit.lua

## Summary

The font module provides the CPU-side data layer for text rendering: bitmap font atlas loading with Latin-1 glyph coverage, per-glyph and per-text metrics, text alignment, word and character wrapping, and a central font registry for named handles. The module does not own GPU resources — texture management for font atlases remains in the render module. Fourteen bundled Courier New bitmap atlases are shipped in `assets/fonts/`.

This module is mostly self-contained inside the `Platform Services` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Files

### bitmap_font.rs

- Bitmap font loader and glyph atlas builder for fixed-size sprite fonts.
- Parses BMFont `.fnt` descriptor files (text and binary formats).
- Builds a glyph atlas mapping codepoints to UV rectangles in a texture.
- Kerning pairs are stored and applied during layout for tighter spacing.
- Atlas textures are loaded through `GameFS` and cached in the font registry.
- Used when the game explicitly requests a bitmap font over a TTF/OTF font.

### metrics.rs

- Font metrics and multi-line text measurement utilities.
- `measure_text` splits on `\n` and returns a `TextMetrics` with width/height.
- `measure_line` operates on a single line and accounts for kerning pairs.
- Line height includes ascender, descender, and the configurable line-gap.
- Results are in logical pixels; caller must apply DPI scale if needed.

### mod.rs

- Font subsystem: glyph metrics, text measurement, word wrapping, and font registry.
- Bitmap font atlas loading and glyph lookup.
- Runtime TTF/OTF rasterisation into atlas format via fontdue.
- Text measurement and word wrapping without GPU dependency.
- Font registry for named font handles.

### registry.rs

- Font registry: loads, caches, and resolves TTF/OTF and bitmap fonts by name.
- `FontRegistry` maps `(name, FontStyle)` pairs to loaded `FontHandle` values.
- Fonts are loaded on first request and cached; duplicates share the same handle.
- `FontStyle` (Regular, Bold, Italic, BoldItalic) is independent of the file path.
- File I/O is routed through `GameFS` — no direct filesystem access here.
- A fallback font is always present; missing fonts degrade gracefully.

### shaping.rs

- Text shaping and word-wrap algorithms for multi-line layout.
- `wrap_words` wraps at word boundaries to fit `max_width` in logical pixels.
- `wrap_characters` wraps at character boundaries for CJK and monospace fonts.
- `WordWrap` enum selects the strategy; `None` disables wrapping entirely.
- Both functions return a `Vec<&str>` of lines; no allocation of the text itself.
- Called by `measure_text` and the UI text widget before rasterisation.

## Lua API Ref

- Binding: `src/lua_api/font_api.rs`
- Namespace: `lurek.font`

### Functions

- `lurek.font.availableSizes`: Returns the array of built-in bitmap font point sizes available in the engine.
- `lurek.font.charAdvance`: Returns the horizontal advance width in pixels of a single character using the given font.
- `lurek.font.getDefault`: Returns the default engine font as an LFont userdata handle.
- `lurek.font.lineHeight`: Returns the line height of the given font in pixels.
- `lurek.font.list`: Lists all registered fonts with their name, size, and style metadata.
- `lurek.font.load`: Loads a TTF/OTF/PNG font file at the given point size and returns an LFont handle.
- `lurek.font.loadBitmap`: Loads a bitmap font atlas PNG with the given cell dimensions and returns an LFont handle.
- `lurek.font.measure`: Measures the pixel dimensions of a text string using the given font handle and scale.
- `lurek.font.measureLine`: Measures the pixel width and height of a single line of text with the given font.
- `lurek.font.shapeText`: Shapes and aligns text into wrapped lines with x-offset data for rendering.
- `lurek.font.wrapText`: Wraps a text string into lines that fit within the given maximum pixel width.

### Enums

- No documented module-level enums/constants.

### Types


#### LFont Type


##### Fields

- No documented fields.

##### Methods

- `LFont:containsGlyph`: Returns whether the font contains a glyph for the given character. This method is available to Lua scripts.
- `LFont:getName`: Returns the human-readable name of this font. This method is available to Lua scripts.
- `LFont:getSize`: Returns the point size of this font. This method is available to Lua scripts.
- `LFont:getStyle`: Returns the style string of this font. This method is available to Lua scripts.
- `LFont:isBold`: Returns whether this font is the bold variant. This method is available to Lua scripts.
- `LFont:lineHeight`: Returns the line height of this font in pixels. This method is available to Lua scripts.
- `LFont:measure`: Measures the pixel dimensions of a text string at the given scale. This method is available to Lua scripts.
- `LFont:wrapText`: Wraps text into lines fitting within the given max width. This method is available to Lua scripts.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.
