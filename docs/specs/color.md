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

The color module provides linear RGBA float color types, constructors from multiple color spaces (hex, HSL, HSV, u8), blending operations (lerp, multiply, screen, overlay, additive, alpha blend), and predefined palettes (CSS named colors, PICO-8, Game Boy, NES). Colors in Lua are plain tables `{r, g, b, a}` indexed 1–4 for maximum interop with rendering APIs. The module also exposes gamma↔linear conversion utilities and a brightness calculator.

This module is mostly self-contained inside the `Foundations` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Source Documentation

### `blend.rs`
- Colour blending helpers: linear interpolation and compositing operations.
- `lerp_color` — interpolates two RGBA colours by factor `t` (clamped 0–1).
- Used internally by tween, particle, and effect systems for smooth transitions.
- All operations stay in `[u8; 4]` RGBA to avoid intermediate float allocations.

### `color_core.rs`
- Core colour conversion and manipulation: RGB, HSL, HSV, and hex parsing.
- `hsl_to_rgb` / `hsv_to_rgb` — convert hue-based spaces to RGBA bytes.
- `parse_hex_color` — parses `#RGB`, `#RRGGBB`, `#RRGGBBAA` strings.
- `rgba_to_hex` — serialises an RGBA byte array to a `#RRGGBBAA` string.
- All public functions are pure and allocation-free where possible.
- Exposed to Lua via `lurek.color.*` through `color_api.rs`.

### `mod.rs`
- RGBA color types, palettes, blending, and color-space conversions.
- Linear RGBA float color with named constants and brand palette.
- Color-space transforms: RGB↔HSL, HSV→RGB, sRGB gamma↔linear.
- Predefined palettes: CSS named colors, retro consoles, game-dev common.
- Blending modes: lerp, multiply, screen, overlay, additive.

### `palette.rs`
- Named colour palettes: retro console, web-safe, and designer presets.
- `retro` sub-module provides PICO-8, Game Boy, CGA, and ZX Spectrum palettes.
- Each palette is a static `&[&str]` of hex strings; no heap allocation.
- Exposed to Lua via `lurek.color.palette.*`.
- Palettes are additive — new sets can be registered via the Lua API.

## Types

- `Color` (`struct`, `color_core.rs`): Linear RGBA float color with channels in [0,1]. Named constants for common colors.
- `Palette` (`struct`, `palette.rs`): Named collection of Color references.

## Functions

- `lerp_color` (`blend.rs`): Linear interpolation between two colors.
- `multiply` (`blend.rs`): Multiply blend mode.
- `screen` (`blend.rs`): Screen blend mode.
- `overlay` (`blend.rs`): Overlay blend mode.
- `additive` (`blend.rs`): Additive blend mode.
- `alpha_blend` (`blend.rs`): Standard alpha compositing (foreground over background).
- `Color::new` (`color_core.rs`): Construct a Color from four f32 components.
- `Color::from_u8` (`color_core.rs`): Construct a Color from four u8 components, normalising each to [0, 1].
- `Color::from_hsl` (`color_core.rs`): Construct an opaque Color from HSL values (hue 0–360, saturation 0–1, lightness 0–1).
- `Color::from_hsv` (`color_core.rs`): Construct an opaque Color from HSV values (hue 0–360, saturation 0–1, value 0–1).
- `Color::from_hex` (`color_core.rs`): Parse a hex color string (`#RRGGBB` or `#RRGGBBAA`); returns None on parse failure.
- `Color::to_u8` (`color_core.rs`): Return the four components as clamped u8 values (r, g, b, a).
- `Color::to_rgb_u32` (`color_core.rs`): Return the color packed as a 24-bit RGB u32 (alpha discarded).
- `Color::to_hex` (`color_core.rs`): Return a hex string representation (`#RRGGBB` or `#RRGGBBAA` if alpha < 1).
- `Color::to_hsl` (`color_core.rs`): Return this color converted to `(hue_degrees, saturation, lightness)` tuple.
- `Color::with_alpha` (`color_core.rs`): Return a copy of this color with a different alpha value.
- `Color::brightness` (`color_core.rs`): Perceived brightness using ITU-R BT.601 luma coefficients.
- `Color::invert` (`color_core.rs`): Invert the RGB channels, keeping alpha unchanged.
- `Color::mix` (`color_core.rs`): Linearly interpolate between two colors by factor `t` (clamped to [0, 1]).
- `hsv_to_rgb` (`color_core.rs`): Standalone HSV→RGB conversion.
- `gamma_to_linear` (`color_core.rs`): sRGB gamma to linear conversion for a single channel.
- `linear_to_gamma` (`color_core.rs`): Linear to sRGB gamma conversion for a single channel.
- `hsl_to_rgb` (`color_core.rs`): Standalone HSL→RGB conversion.

## Lua API Reference

- Binding path(s): `src/lua_api/color_api.rs`
- Namespace: `lurek.color`

### Module Functions
- `lurek.color.new`: Creates an RGBA color from 0–1 float components. Alpha defaults to 1.0.
- `lurek.color.fromU8`: Creates a color from 0–255 integer components. Alpha defaults to 255.
- `lurek.color.fromHex`: Parses a hex color string ("#RRGGBB" or "#RRGGBBAA") into a color table. Returns nil on invalid input.
- `lurek.color.fromHsl`: Creates a color from HSL components. Returns an opaque color (alpha = 1).
- `lurek.color.fromHsv`: Creates a color from HSV components. Returns an opaque color (alpha = 1).
- `lurek.color.toHsl`: Convert RGB color components to HSL color representation.
- `lurek.color.toHex`: Converts RGBA components to a hex string ("#RRGGBB" or "#RRGGBBAA" if alpha < 1).
- `lurek.color.lerp`: Linearly interpolates between two color tables by factor t (clamped to 0–1).
- `lurek.color.multiply`: Channel-wise multiply blend of two colors.
- `lurek.color.screen`: Apply screen blend mode to combine two color values.
- `lurek.color.overlay`: Overlay blend of two colors exposed by the lurek engine.
- `lurek.color.additive`: Additive blend of two colors (clamped to 0–1 per channel).
- `lurek.color.alphaBlend`: Alpha compositing (Porter-Duff "over") of foreground over background.
- `lurek.color.invert`: Inverts the RGB channels of a color, keeping alpha unchanged.
- `lurek.color.brightness`: Computes perceived luminance (ITU-R BT.601) of an RGB color.
- `lurek.color.withAlpha`: Returns a color with the alpha channel replaced.
- `lurek.color.gammaToLinear`: Converts a single sRGB gamma-encoded component to linear space.
- `lurek.color.linearToGamma`: Converts a single linear component to sRGB gamma-encoded space.
- `lurek.color.palette`: Returns a named retro palette as a table of color tables. Supported: "pico8", "gameboy", "nes".

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Notes

- Extracted from `src/math/color.rs`. The original color.rs remains for backward compatibility. New code should use `crate::color::*`.
- Colors in Lua are plain tables `{r, g, b, a}` indexed 1–4 for maximum interop with existing rendering APIs.
- Palettes are returned as tables of color tables.
