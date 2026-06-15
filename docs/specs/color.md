# color

## TL;DR

- Manages color spaces, blends, and retro palettes.

## General Info

- Module group: `Foundations`
- Source path: `src/color/`
- Binding: `src/lua_api/color_api.rs`
- Namespace: `lurek.color`
- Lua API surface: `19` functions, `0` types, `0` methods
- Rust test path(s): tests/rust/unit/color_tests.rs
- Lua test path(s): tests/lua/unit/test_color_unit.lua

## Summary

- The color module gives scripts one toolbox for creation, conversion, blending, and palette-based styling.
- It supports RGB, HSL, HSV, and hex workflows so designers can work in the representation that fits the task.
- Predictable interpolation and compositing support fades, highlights, and layered UI rendering.
- Blend modes and luminance helpers help with effects tuning and contrast-aware presentation.
- Retro palettes accelerate thematic prototyping without manual color picking.
- The module bridges art-facing color intent with runtime-safe numeric operations.

This module is mostly self-contained inside the `Foundations` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

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

- `lurek.color.additive(c1, c2) -> table`: Additive blend of two colors (clamped to 0â€“1 per channel).
- `lurek.color.alphaBlend(fg, bg) -> table`: Alpha compositing (Porter-Duff "over") of foreground over background.
- `lurek.color.brightness(r, g, b) -> number`: Computes perceived luminance (ITU-R BT.601) of an RGB color.
- `lurek.color.fromHex(hex) -> table|nil`: Parses a hex color string ("#RGB", "#RGBA", "#RRGGBB", or "#RRGGBBAA") into a color table. Returns nil on invalid input.
- `lurek.color.fromHsl(h, s, l) -> table`: Creates a color from HSL components. Returns an opaque color (alpha = 1).
- `lurek.color.fromHsv(h, s, v) -> table`: Creates a color from HSV components. Returns an opaque color (alpha = 1).
- `lurek.color.fromU8(r, g, b, a?) -> table`: Creates a color from 0â€“255 integer components. Alpha defaults to 255.
- `lurek.color.gammaToLinear(c) -> number`: Converts a single sRGB gamma-encoded component to linear space.
- `lurek.color.invert(r, g, b, a?) -> table`: Inverts the RGB channels of a color, keeping alpha unchanged.
- `lurek.color.lerp(c1, c2, t) -> table`: Linearly interpolates between two color tables by factor t (clamped to 0â€“1).
- `lurek.color.linearToGamma(c) -> number`: Converts a single linear component to sRGB gamma-encoded space.
- `lurek.color.multiply(c1, c2) -> table`: Channel-wise multiply blend of two colors.
- `lurek.color.new(r, g, b, a?) -> table`: Creates an RGBA color from 0â€“1 float components. Alpha defaults to 1.0.
- `lurek.color.overlay(base, blend) -> table`: Overlay blend of two colors exposed by the lurek engine.
- `lurek.color.palette(name) -> table`: Returns a named retro palette as a table of color tables. Supported: "pico8", "gameboy", "nes".
- `lurek.color.screen(c1, c2) -> table`: Apply screen blend mode to combine two color values.
- `lurek.color.toHex(r, g, b, a?) -> string`: Converts RGBA components to a hex string ("#RRGGBB" or "#RRGGBBAA" if alpha < 1).
- `lurek.color.toHsl(r, g, b) -> number, number, number`: Convert RGB color components to HSL color representation.
- `lurek.color.withAlpha(r, g, b, a, newAlpha) -> table`: Returns a color with the alpha channel replaced.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

- No documented module types.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Notes

- No additional module-specific notes.
