# color

## TL;DR

- RGBA color primitives with color-space conversions, blending modes, and predefined palettes for 2D rendering.

## General Info

- Module group: `Foundations`
- Source path: `src/color/`
- Lua API path(s): `src/lua_api/color_api.rs`
- Primary Lua namespace: `lurek.color`
- Rust test path(s): tests/rust/unit/color_tests.rs
- Lua test path(s): tests/lua/unit/test_color_core_unit.lua

## Summary

The `color` module is the foundational color utility layer for linear RGBA operations, palette access, blending, and color-space conversion. Its core `Color` model and helpers provide a stable contract used by rendering, effects, UI, and tooling paths.

Submodules separate concerns cleanly: `color_core` handles representation and transforms (including HSL/HSV and gamma-linear conversions), `palette` provides named and retro palette catalogs, and `blend` provides compositing/interpolation operations such as lerp, multiply, screen, overlay, additive, and alpha blend.

The module's value is consistency across engine systems. Instead of ad-hoc formulas repeated in many places, color math is centralized here so behavior remains predictable and testable.

As a foundations module, its APIs should remain small, explicit, and deterministic. Higher-level artistic policy belongs elsewhere; this module should continue to provide the reusable primitives those policies rely on.

## Files

### blend.rs

- Colour blending helpers: linear interpolation and compositing operations.
- `lerp_color` — interpolates two RGBA colours by factor `t` (clamped 0–1).
- Used internally by tween, particle, and effect systems for smooth transitions.
- All operations stay in `[u8; 4]` RGBA to avoid intermediate float allocations.

### color_core.rs

- Core colour conversion and manipulation: RGB, HSL, HSV, and hex parsing.
- `hsl_to_rgb` / `hsv_to_rgb` — convert hue-based spaces to RGBA bytes.
- `parse_hex_color` — parses `#RGB`, `#RRGGBB`, `#RRGGBBAA` strings.
- `rgba_to_hex` — serialises an RGBA byte array to a `#RRGGBBAA` string.
- All public functions are pure and allocation-free where possible.
- Exposed to Lua via `lurek.color.*` through `color_api.rs`.

### mod.rs

- RGBA color types, palettes, blending, and color-space conversions.
- Linear RGBA float color with named constants and brand palette.
- Color-space transforms: RGB↔HSL, HSV→RGB, sRGB gamma↔linear.
- Predefined palettes: CSS named colors, retro consoles, game-dev common.
- Blending modes: lerp, multiply, screen, overlay, additive.

### palette.rs

- Named colour palettes: retro console, web-safe, and designer presets.
- `retro` sub-module provides PICO-8, Game Boy, CGA, and ZX Spectrum palettes.
- Each palette is a static `&[&str]` of hex strings; no heap allocation.
- Exposed to Lua via `lurek.color.palette.*`.
- Palettes are additive — new sets can be registered via the Lua API.

## Lua API Ref

- Binding: `src/lua_api/color_api.rs`
- Namespace: `lurek.color`

### Functions

- `lurek.color.additive`: Additive blend of two colors (clamped to 0–1 per channel).
- `lurek.color.alphaBlend`: Alpha compositing (Porter-Duff "over") of foreground over background.
- `lurek.color.brightness`: Computes perceived luminance (ITU-R BT.601) of an RGB color.
- `lurek.color.fromHex`: Parses a hex color string ("#RRGGBB" or "#RRGGBBAA") into a color table. Returns nil on invalid input.
- `lurek.color.fromHsl`: Creates a color from HSL components. Returns an opaque color (alpha = 1).
- `lurek.color.fromHsv`: Creates a color from HSV components. Returns an opaque color (alpha = 1).
- `lurek.color.fromU8`: Creates a color from 0–255 integer components. Alpha defaults to 255.
- `lurek.color.gammaToLinear`: Converts a single sRGB gamma-encoded component to linear space.
- `lurek.color.invert`: Inverts the RGB channels of a color, keeping alpha unchanged.
- `lurek.color.lerp`: Linearly interpolates between two color tables by factor t (clamped to 0–1).
- `lurek.color.linearToGamma`: Converts a single linear component to sRGB gamma-encoded space.
- `lurek.color.multiply`: Channel-wise multiply blend of two colors.
- `lurek.color.new`: Creates an RGBA color from 0–1 float components. Alpha defaults to 1.0.
- `lurek.color.overlay`: Overlay blend of two colors exposed by the lurek engine.
- `lurek.color.palette`: Returns a named retro palette as a table of color tables. Supported: "pico8", "gameboy", "nes".
- `lurek.color.screen`: Apply screen blend mode to combine two color values.
- `lurek.color.toHex`: Converts RGBA components to a hex string ("#RRGGBB" or "#RRGGBBAA" if alpha < 1).
- `lurek.color.toHsl`: Convert RGB color components to HSL color representation.
- `lurek.color.withAlpha`: Returns a color with the alpha channel replaced.

### Enums

- No documented module-level enums/constants.

### Types

- No documented module types.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.
