# `color`

## TL;DR
- RGBA color primitives with color-space conversions, blending modes, and predefined palettes for 2D rendering.

## General Info
- Module group: `Foundations`
- Source path: `src/color/`
- Lua API path(s): `src/lua_api/color_api.rs`
- Primary Lua namespace: `lurek.color`
- Rust test path(s): `tests/rust/unit/color_tests.rs`
- Lua test path(s): `tests/lua/unit/test_color_core_unit.lua`

## Summary
The color module provides linear RGBA float color types, constructors from multiple color spaces (hex, HSL, HSV, u8), blending operations (lerp, multiply, screen, overlay, additive, alpha blend), and predefined palettes (CSS named colors, PICO-8, Game Boy, NES). Colors in Lua are plain tables `{r, g, b, a}` indexed 1–4 for maximum interop with rendering APIs. The module also exposes gamma↔linear conversion utilities and a brightness calculator.

## Files
- `mod.rs`: Module root and public re-exports.
- `color_core.rs`: Core RGBA Color struct with constants, constructors, and color-space conversions.
- `palette.rs`: Predefined palettes (CSS named, retro consoles: PICO-8, Game Boy, NES).
- `blend.rs`: Color blending and interpolation (lerp, multiply, screen, overlay, additive, alpha).

## Types
- `Color` (`struct`, `color_core.rs`): Linear RGBA float color with channels in [0,1]. Named constants for common colors.
- `Palette` (`struct`, `palette.rs`): Named collection of Color references.

## Functions
- `Color::new` (`color_core.rs`): Construct from four f32 channels.
- `Color::from_u8` (`color_core.rs`): Construct from four u8 channels (0–255).
- `Color::from_hex` (`color_core.rs`): Parse a hex string (`#RRGGBB` or `#RRGGBBAA`).
- `Color::from_hsl` (`color_core.rs`): Construct from HSL (hue 0–360, saturation/lightness 0–1).
- `Color::from_hsv` (`color_core.rs`): Construct from HSV (hue 0–360, saturation/value 0–1).
- `Color::to_hsl` (`color_core.rs`): Convert to HSL tuple.
- `Color::to_hex` (`color_core.rs`): Convert to hex string.
- `Color::with_alpha` (`color_core.rs`): Return a copy with a new alpha value.
- `Color::brightness` (`color_core.rs`): Perceived luminance (0–1).
- `Color::invert` (`color_core.rs`): Invert RGB channels, preserving alpha.
- `Color::mix` (`color_core.rs`): Blend with another color at a given ratio.
- `hsl_to_rgb` (`color_core.rs`): Standalone HSL→RGB conversion.
- `hsv_to_rgb` (`color_core.rs`): Standalone HSV→RGB conversion.
- `gamma_to_linear` (`color_core.rs`): sRGB gamma to linear conversion for a single channel.
- `linear_to_gamma` (`color_core.rs`): Linear to sRGB gamma conversion for a single channel.
- `lerp_color` (`blend.rs`): Linear interpolation between two colors.
- `multiply` (`blend.rs`): Multiply blend mode.
- `screen` (`blend.rs`): Screen blend mode.
- `overlay` (`blend.rs`): Overlay blend mode.
- `additive` (`blend.rs`): Additive blend mode.
- `alpha_blend` (`blend.rs`): Standard alpha compositing (foreground over background).

## Lua API Reference
- Binding path(s): `src/lua_api/color_api.rs`
- Namespace: `lurek.color`

### Module Functions
- `lurek.color.new(r, g, b, a)` → table: Construct a color from float channels [0,1].
- `lurek.color.fromU8(r, g, b, a)` → table: Construct from integer channels [0,255].
- `lurek.color.fromHex(hex)` → table|nil: Parse a hex color string; nil on invalid input.
- `lurek.color.fromHsl(h, s, l)` → table: Construct from HSL values.
- `lurek.color.fromHsv(h, s, v)` → table: Construct from HSV values.
- `lurek.color.toHsl(r, g, b)` → h, s, l: Convert RGB to HSL components.
- `lurek.color.toHex(r, g, b, a)` → string: Convert to hex string representation.
- `lurek.color.lerp(c1, c2, t)` → table: Linear interpolation between two colors.
- `lurek.color.multiply(c1, c2)` → table: Multiply blend of two colors.
- `lurek.color.screen(c1, c2)` → table: Screen blend of two colors.
- `lurek.color.overlay(base, blend)` → table: Overlay blend mode.
- `lurek.color.additive(c1, c2)` → table: Additive blend of two colors.
- `lurek.color.alphaBlend(fg, bg)` → table: Alpha-composite foreground over background.
- `lurek.color.invert(r, g, b, a)` → table: Invert RGB channels, keep alpha.
- `lurek.color.brightness(r, g, b)` → number: Perceived luminance of an RGB color.
- `lurek.color.withAlpha(r, g, b, a, newA)` → table: Return color with replaced alpha.
- `lurek.color.gammaToLinear(c)` → number: Convert a single sRGB gamma channel to linear.
- `lurek.color.linearToGamma(c)` → number: Convert a single linear channel to sRGB gamma.
- `lurek.color.palette(name)` → table: Retrieve a named palette as a table of color tables.

### Constants
- `lurek.color.WHITE`, `BLACK`, `RED`, `GREEN`, `BLUE`, `YELLOW`, `CYAN`, `MAGENTA`, `TRANSPARENT`

## Notes
- Extracted from `src/math/color.rs`. The original color.rs remains for backward compatibility. New code should use `crate::color::*`.
- Colors in Lua are plain tables `{r, g, b, a}` indexed 1–4 for maximum interop with existing rendering APIs.
- Palettes are returned as tables of color tables.

## References
- [math.md](math.md) — original home of color types.
- [render.md](render.md) — consumer of Color in draw commands.
- Example: `content/examples/color.lua`
