# font

## General Info

- Module group: `Platform Services`
- Source path: `src/font/`
- Binding: `src/lua_api/font_api.rs`
- Namespace: `lurek.font`
- Lua API surface: `11` functions, `1` types, `8` methods
- Rust test path(s): tests/rust/unit/font_tests.rs
- Lua test path(s): tests/lua/unit/test_font_core_unit.lua

## Summary

This module provides typography runtime services to load, resolve, and manage fonts. It operates a central registry caching styles and point sizes for TTF, OTF, and pre-rasterized bitmap fonts. This ensures that UI and render steps can query consistent font metrics on demand to size components.

For text layouts, the module handles kerning-aware measurements and shaping operations. It supports multiple wrapping strategies to fit text strings within pixel width limits, computing line placements and glyph advances to produce formatted, multi-line layouts for rendering.

## Files

### [bitmap_font.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/font/bitmap_font.rs)

- Provides bitmap-font loading and atlas-backed glyph lookup for pre-rasterized text rendering workflows.
- Parses descriptor data to build codepoint-to-glyph mappings with stable UV and metric records.
- Preserves kerning and sizing information needed for accurate spacing during layout and shaping.
- Delivers fixed-size sprite font support for pipelines that prefer atlas sampling over runtime rasterization.

### [metrics.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/font/metrics.rs)

- Provides glyph and line metric structures used to measure text blocks in logical pixel space.
- Computes single-line and multiline dimensions with kerning-aware advance accumulation.
- Tracks per-line width and source ranges so layout systems can map metrics back to input text.
- Exposes aggregate text bounds including line count and total height for UI sizing flows.
- Delivers measurement primitives required by shaping, wrapping, and render preparation paths.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/font/mod.rs)

- Provides the high-level font module boundary for glyph data, layout shaping, and registry access.
- Connects bitmap atlas handling, metrics evaluation, and wrap logic into one typography service surface.
- Delivers stable text-measurement and font-resolution capabilities for rendering and UI systems.

### [registry.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/font/registry.rs)

- Provides the runtime font registry that stores, resolves, and returns loaded font handles by name.
- Maps style and size metadata onto cached font assets for consistent lookup semantics.
- Supports registration and replacement flows while maintaining stable handle-based access patterns.
- Centralizes font ownership so rendering systems consume one authoritative source of text assets.
- Delivers the font-management layer that coordinates typography resources across the engine.

### [shaping.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/font/shaping.rs)

- Provides text-shaping and wrapping behavior that transforms raw strings into render-ready line layouts.
- Supports no-wrap, word-wrap, and character-wrap strategies to match varied language and UI needs.
- Computes aligned line placement using measured advances and target width constraints.
- Emits shaped line collections with offsets and widths for downstream rendering stages.
- Delivers the layout layer that bridges font metrics and final text draw preparation.
