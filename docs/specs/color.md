# color

## TL;DR

- RGBA color primitives with color-space conversions, blending modes, and predefined palettes for 2D rendering.

## General Info

- Module group: `Foundations`
- Source path: `src/color/`
- Binding: `src/lua_api/color_api.rs`
- Namespace: `lurek.color`
- Lua API surface: `19` functions, `0` types, `0` methods
- Rust test path(s): tests/rust/unit/color_tests.rs
- Lua test path(s): tests/lua/unit/test_color_core_unit.lua

## Summary

The `color` module is the foundational color utility layer for linear RGBA operations, palette access, blending, and color-space conversion. Its core `Color` model and helpers provide a stable contract used by rendering, effects, UI, and tooling paths.

Submodules separate concerns cleanly: `color_core` handles representation and transforms (including HSL/HSV and gamma-linear conversions), `palette` provides named and retro palette catalogs, and `blend` provides compositing/interpolation operations such as lerp, multiply, screen, overlay, additive, and alpha blend.

The module's value is consistency across engine systems. Instead of ad-hoc formulas repeated in many places, color math is centralized here so behavior remains predictable and testable.

As a foundations module, its APIs should remain small, explicit, and deterministic. Higher-level artistic policy belongs elsewhere; this module should continue to provide the reusable primitives those policies rely on.

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Files

### blend.rs

- Implements color blending helpers for interpolation and compositing-style channel math.
- Provides clamped linear interpolation between RGBA values for smooth visual transitions.
- Keeps operations lightweight and deterministic for per-frame use in effects and tween flows.
- Serves as the core blend-utility layer consumed by rendering-adjacent systems.

### color_core.rs

- Implements core color representation and conversion utilities across RGB, HSL, and HSV domains.
- Parses hex color strings into structured channel values with support for common shorthand forms.
- Serializes RGBA channel values back to canonical hexadecimal text for interchange and debugging.
- Provides pure color-space transforms suitable for runtime use without hidden global state.
- Exposes stable conversion behavior reused by palettes, blending, and Lua-visible color APIs.
- Serves as the foundational color math and parsing layer for the full color module.

### mod.rs

- Defines the color module boundary for channel types, conversion logic, palettes, and blending helpers.
- Groups core color math and curated palette sources into one reusable runtime surface.
- Serves as the composition entry for engine-side and Lua-side color workflows.

### palette.rs

- Implements named color-palette collections for retro, utility, and designer-oriented presets.
- Stores curated palette definitions as static data for low-overhead runtime access.
- Provides lookup and conversion helpers that map palette entries into structured color values.
- Supports extension flows where new palette sets can be surfaced through higher API layers.
- Serves as the canonical palette source used by rendering tools and script-facing color features.

## Lua API Ref

### Functions

- `lurek.color.additive`: Additive blend of two colors (clamped to 0â€“1 per channel).
- `lurek.color.alphaBlend`: Alpha compositing (Porter-Duff "over") of foreground over background.
- `lurek.color.brightness`: Computes perceived luminance (ITU-R BT.601) of an RGB color.
- `lurek.color.fromHex`: Parses a hex color string ("#RRGGBB" or "#RRGGBBAA") into a color table. Returns nil on invalid input.
- `lurek.color.fromHsl`: Creates a color from HSL components. Returns an opaque color (alpha = 1).
- `lurek.color.fromHsv`: Creates a color from HSV components. Returns an opaque color (alpha = 1).
- `lurek.color.fromU8`: Creates a color from 0â€“255 integer components. Alpha defaults to 255.
- `lurek.color.gammaToLinear`: Converts a single sRGB gamma-encoded component to linear space.
- `lurek.color.invert`: Inverts the RGB channels of a color, keeping alpha unchanged.
- `lurek.color.lerp`: Linearly interpolates between two color tables by factor t (clamped to 0â€“1).
- `lurek.color.linearToGamma`: Converts a single linear component to sRGB gamma-encoded space.
- `lurek.color.multiply`: Channel-wise multiply blend of two colors.
- `lurek.color.new`: Creates an RGBA color from 0â€“1 float components. Alpha defaults to 1.0.
- `lurek.color.overlay`: Overlay blend of two colors exposed by the lurek engine.
- `lurek.color.palette`: Returns a named retro palette as a table of color tables. Supported: "pico8", "gameboy", "nes".
- `lurek.color.screen`: Apply screen blend mode to combine two color values.
- `lurek.color.toHex`: Converts RGBA components to a hex string ("#RRGGBB" or "#RRGGBBAA" if alpha < 1).
- `lurek.color.toHsl`: Convert RGB color components to HSL color representation.
- `lurek.color.withAlpha`: Returns a color with the alpha channel replaced.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

- No documented module types.
