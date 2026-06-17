# font

## TL;DR

- Manages font loading, metrics caching, and text wrapping.

## General Info

- Module group: `Platform Services`
- Source path: `src/font/`
- Binding: `src/lua_api/font_api.rs`
- Namespace: `lurek.font`
- Lua API surface: `11` functions, `1` types, `8` methods
- Rust test path(s): tests/rust/unit/font_tests.rs
- Lua test path(s): tests/lua/unit/test_font_unit.lua

## Summary

- The font module gives users a stable typography layer for loading fonts and measuring text reliably.
- It supports vector and bitmap font workflows, making UI and retro text rendering equally practical.
- Registry-based lookup keeps font usage consistent across menus, HUDs, and overlays.
- Measurement and shaping helpers provide kerning-aware dimensions for accurate layout decisions.
- Wrap modes support fitting long text into constrained UI regions without manual splitting.
- Script APIs expose line height, glyph availability, and metadata for fallback logic.
- The module keeps text layout predictable and easier to iterate on.

This module is mostly self-contained inside the `Platform Services` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Files

### bitmap_font.rs

- Provides bitmap-font loading and atlas-backed glyph lookup for pre-rasterized text rendering workflows. `font/bitmap_font` delivers the bitmap font implementation for the font subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Parses descriptor data to build codepoint-to-glyph mappings with stable UV and metric records. The file owns or coordinates data contracts including `BitmapFontAtlas`, `BitmapFont`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Preserves kerning and sizing information needed for accurate spacing during layout and shaping. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `glyph_info`, `contains_glyph`, `line_height`, `point_size`, `is_bold` stays attached to the local data model and invariants.
- Delivers fixed-size sprite font support for pipelines that prefer atlas sampling over runtime rasterization. Runtime integration reaches sibling engine areas through crate modules `font`, which explains the subsystem dependencies an agent should inspect before changing behavior.

### metrics.rs

- Provides glyph and line metric structures used to measure text blocks in logical pixel space. `font/metrics` delivers the metrics implementation for the font subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Computes single-line and multiline dimensions with kerning-aware advance accumulation. The file owns or coordinates data contracts including `GlyphMetrics`, `LineMetrics`, `TextMetrics`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Tracks per-line width and source ranges so layout systems can map metrics back to input text. Public callable behavior is centered on `measure_text`, `measure_line`, `char_advance`, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- Exposes aggregate text bounds including line count and total height for UI sizing flows. Runtime integration reaches sibling engine areas through crate modules `font`, which explains the subsystem dependencies an agent should inspect before changing behavior.

### mod.rs

- Provides the high-level font module boundary for glyph data, layout shaping, and registry access. `font/mod` is the font module index, declaring `bitmap_font`, `metrics`, `registry`, `shaping` so agents can identify which files own each feature slice before opening implementation code.
- Connects bitmap atlas handling, metrics evaluation, and wrap logic into one typography service surface. `src/font/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `bitmap_font::{BitmapFont, BitmapFontAtlas, AVAILABLE_SIZES}`, `metrics::{GlyphMetrics, TextMetrics}`, `registry::{FontHandle, FontRegistry, FontStyle}`, `shaping::{shape_text, LineBreak, ShapedText, TextAlign, WordWrap}` centralized for the font subsystem.

### registry.rs

- Provides the runtime font registry that stores, resolves, and returns loaded font handles by name. `font/registry` delivers the lookup registry and handle ownership for the font subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Maps style and size metadata onto cached font assets for consistent lookup semantics. The file owns or coordinates data contracts including `FontStyle`, `FontHandle`, `FontRegistry`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Supports registration and replacement flows while maintaining stable handle-based access patterns. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `register`, `get`, `get_by_name`, `default_font`, `list_fonts` stays attached to the local data model and invariants.
- Centralizes font ownership so rendering systems consume one authoritative source of text assets. Runtime integration reaches sibling engine areas through crate modules `font`, which explains the subsystem dependencies an agent should inspect before changing behavior.

### shaping.rs

- Provides text-shaping and wrapping behavior that transforms raw strings into render-ready line layouts. `font/shaping` delivers the shaping implementation for the font subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Supports no-wrap, word-wrap, and character-wrap strategies to match varied language and UI needs. The file owns or coordinates data contracts including `TextAlign`, `WordWrap`, `LineBreak`, `ShapedLine`, `ShapedText`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Computes aligned line placement using measured advances and target width constraints. Public callable behavior is centered on `shape_text`, `wrap_words`, `wrap_characters`, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- Emits shaped line collections with offsets and widths for downstream rendering stages. Runtime integration reaches sibling engine areas through crate modules `font`, which explains the subsystem dependencies an agent should inspect before changing behavior.



## Lua API Ref

### Functions

- `lurek.font.availableSizes() -> table`: Returns the array of built-in bitmap font point sizes available in the engine.
- `lurek.font.charAdvance(font, char, scale?) -> number`: Returns the horizontal advance width in pixels of a single character using the given font.
- `lurek.font.getDefault() -> LFont`: Returns the default engine font as an LFont userdata handle.
- `lurek.font.lineHeight(font) -> number`: Returns the line height of the given font in pixels.
- `lurek.font.list() -> table`: Lists all registered fonts with their name, size, and style metadata.
- `lurek.font.load(path, size) -> LFont`: Loads a TTF/OTF/PNG font file at the given point size and returns an LFont handle.
- `lurek.font.loadBitmap(path, cellWidth, cellHeight) -> LFont`: Loads a bitmap font atlas PNG with the given cell dimensions and returns an LFont handle.
- `lurek.font.measure(font, text, scale?) -> number`: Measures the pixel dimensions of a text string using the given font handle and scale.
- `lurek.font.measureLine(font, text, scale?) -> number`: Measures the pixel width and height of a single line of text with the given font.
- `lurek.font.shapeText(font, text, maxWidth, scale, align, wrap) -> table`: Shapes and aligns text into wrapped lines with x-offset data for rendering.
- `lurek.font.wrapText(font, text, maxWidth, scale, mode) -> table`: Wraps a text string into lines that fit within the given maximum pixel width.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

#### LFont Type

- Lua-visible font handle storing the slot key and cached metadata.

##### Fields

- No documented fields.

##### Methods

- `LFont:containsGlyph(char) -> boolean`: Returns whether the font contains a glyph for the given character. This method is available to Lua scripts.
- `LFont:getName() -> string`: Returns the human-readable name of this font. This method is available to Lua scripts.
- `LFont:getSize() -> number`: Returns the point size of this font. This method is available to Lua scripts.
- `LFont:getStyle() -> string`: Returns the style string of this font. This method is available to Lua scripts.
- `LFont:isBold() -> boolean`: Returns whether this font is the bold variant. This method is available to Lua scripts.
- `LFont:lineHeight() -> number`: Returns the line height of this font in pixels. This method is available to Lua scripts.
- `LFont:measure(text, scale?) -> number, number`: Measures the pixel dimensions of a text string at the given scale. This method is available to Lua scripts.
- `LFont:wrapText(text, maxWidth, scale?) -> table`: Wraps text into lines fitting within the given max width. This method is available to Lua scripts.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Notes

- No additional module-specific notes.
