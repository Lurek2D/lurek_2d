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
- Lua test path(s): tests/lua/unit/test_font_core_unit.lua

## Summary

- The font module gives users a stable typography layer for loading fonts and measuring text reliably.
- It supports vector and bitmap font workflows, making UI and retro text rendering equally practical.
- Registry-based lookup keeps font usage consistent across menus, HUDs, and overlays.
- Measurement and shaping helpers provide kerning-aware dimensions for accurate layout decisions.
- Wrap modes support fitting long text into constrained UI regions without manual splitting.
- Script APIs expose line height, glyph availability, and metadata for fallback logic.
- The module keeps text layout predictable and easier to iterate on.

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Files

### bitmap_font.rs

- Provides bitmap-font loading and atlas-backed glyph lookup for pre-rasterized text rendering workflows.
- Parses descriptor data to build codepoint-to-glyph mappings with stable UV and metric records.
- Preserves kerning and sizing information needed for accurate spacing during layout and shaping.
- Delivers fixed-size sprite font support for pipelines that prefer atlas sampling over runtime rasterization.

### metrics.rs

- Provides glyph and line metric structures used to measure text blocks in logical pixel space.
- Computes single-line and multiline dimensions with kerning-aware advance accumulation.
- Tracks per-line width and source ranges so layout systems can map metrics back to input text.
- Exposes aggregate text bounds including line count and total height for UI sizing flows.
- Delivers measurement primitives required by shaping, wrapping, and render preparation paths.

### mod.rs

- Provides the high-level font module boundary for glyph data, layout shaping, and registry access.
- Connects bitmap atlas handling, metrics evaluation, and wrap logic into one typography service surface.
- Delivers stable text-measurement and font-resolution capabilities for rendering and UI systems.

### registry.rs

- Provides the runtime font registry that stores, resolves, and returns loaded font handles by name.
- Maps style and size metadata onto cached font assets for consistent lookup semantics.
- Supports registration and replacement flows while maintaining stable handle-based access patterns.
- Centralizes font ownership so rendering systems consume one authoritative source of text assets.
- Delivers the font-management layer that coordinates typography resources across the engine.

### shaping.rs

- Provides text-shaping and wrapping behavior that transforms raw strings into render-ready line layouts.
- Supports no-wrap, word-wrap, and character-wrap strategies to match varied language and UI needs.
- Computes aligned line placement using measured advances and target width constraints.
- Emits shaped line collections with offsets and widths for downstream rendering stages.
- Delivers the layout layer that bridges font metrics and final text draw preparation.

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
