<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/font.md or source docstrings instead. -->

# font

## TL;DR

- Manages font loading, metrics caching, and text wrapping.

## General Info

- Module group: `Platform Services`
- Source path: `src/font`
- Binding: `src/lua_api/font_api.rs`
- Namespace: `lurek.font`
- Lua API surface: `11` functions, `1` types, `8` methods
- User-facing: `true`
- Plugin tier: `not_evaluated`

## Summary

- The `font` module is the typography layer for users who need predictable text behavior in UI, HUDs, overlays, or retro-style screens.
- It covers loading and registering fonts, so scripts can reuse named font resources instead of rebuilding text setup at every draw site.
- Measurement and shaping are just as important as loading here: glyph metrics, wrapping, line sizing, and text geometry helpers let layout code make reliable decisions before anything is rendered.
- Read this module as the place where text data becomes stable and reusable. Rendering and UI systems still decide where text appears, but `font` keeps measurement consistent.

This module is mostly self-contained inside the `Platform Services` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Ownership

- Canonical source: `src/font`
- Owning tier: `Platform Services`
- Plugin tier: `not_evaluated`
- Lua binding owner: `src/lua_api/font_api.rs`
- Referenced engine modules: None detected from Rust imports.

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Source Files

### bitmap_font.rs

- `src/font/bitmap_font.rs` owns atlas-backed bitmap font data, glyph lookup, and fixed-size raster font metadata.
- It defines `BitmapFontAtlas` and `BitmapFont`, keeping glyph tables, point size, bold state, and line height together.
- Supported codepoint range and available baked sizes live here, so callers can reason about which bitmap assets exist.
- Open this file when atlas layout, glyph presence rules, or bitmap font identity and sizing behavior need to change.

### metrics.rs

- `src/font/metrics.rs` owns glyph and text measurement data used to size strings, lines, and wrapped text blocks.
- It defines `GlyphMetrics`, `LineMetrics`, and `TextMetrics`, keeping measurement outputs under one typography owner.
- `measure_text`, `measure_line`, and `char_advance` live here so width and height calculations stay out of shaping.
- Per-line source ranges are tracked here, letting downstream layout code map measured spans back to original text.
- Open this file when text sizing semantics, fallback advances, or metric structures for rendering and UI need changes.

### mod.rs

- `src/font/mod.rs` is the font module index, exposing atlas, metrics, registry, and shaping surfaces in one place.
- It reexports the public text stack so renderers, UI systems, and bindings can reach font services through one boundary.
- No runtime font state lives here; this file defines visibility and navigation while implementation stays in child files.
- Read this index when wiring text features, because it shows which font symbols are intentionally public and stable.
- Changes here alter the typography boundary, since reexports decide what the engine and Lua-facing layers may import.
- This module groups loading, measurement, shaping, and lookup concerns without collapsing them into one file.

### registry.rs

- `src/font/registry.rs` owns runtime font registration, handle allocation, and lookup by name for loaded bitmap fonts.
- It defines `FontStyle`, `FontHandle`, and `FontRegistry`, keeping public font identity separate from raw font storage.
- Replacement, default-font selection, and registration order live here so text consumers share one asset authority.
- Open this file when font ownership, lookup semantics, or public handle metadata for runtime text assets must change.
- Neighboring systems should treat this file as the font boundary for asset access, not the place for shaping or metrics.

### shaping.rs

- `src/font/shaping.rs` owns line shaping, alignment, and wrapping that turns raw strings into render-ready text layout.
- It defines alignment and wrap enums plus shaped output types, keeping text layout contracts under one owner.
- `shape_text`, `wrap_words`, and `wrap_characters` live here so layout decisions stay separate from glyph measurement.
- This file computes per-line widths and horizontal offsets, giving renderers positioned lines instead of raw source text.
- Open this file when wrapping policy, alignment behavior, or shaped line structure needs to change for UI or rendering.



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

## Examples

- `content/examples/font.lua` (present)

## Tests

- Lua unit: `tests/lua/unit/test_font_unit.lua` (present)
- Rust: `tests/rust/unit/font_tests.rs`

## Evidence / Golden

- No evidence or golden artifacts registered.

## Architecture Links

- Intentionally empty.

## Notes

- No additional module-specific notes.
