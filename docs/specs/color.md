<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/color.md or source docstrings instead. -->

# color

## TL;DR

- Manages color spaces, blends, and retro palettes.

## General Info

- Module group: `Foundations`
- Source path: `src/color`
- Binding: `src/lua_api/color_api.rs`
- Namespace: `lurek.color`
- Lua API surface: `19` functions, `0` types, `0` methods
- User-facing: `true`
- Plugin tier: `not_evaluated`

## Summary

- The `color` module is the shared toolbox for defining, converting, and reusing runtime color values across the engine.
- It combines low-level color math with practical authoring workflows, so scripts can move between RGB, HSL, HSV, hex, blending, and interpolation without custom conversion helpers.
- That makes it useful for themes, fades, highlights, palette work, and effect tuning.
- Read it as the common color language for the engine: other systems decide where color is used, but `color` keeps conversion, composition, and palette logic consistent.

This module is mostly self-contained inside the `Foundations` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Ownership

- Canonical source: `src/color`
- Owning tier: `Foundations`
- Plugin tier: `not_evaluated`
- Lua binding owner: `src/lua_api/color_api.rs`
- Referenced engine modules: None detected from Rust imports.

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Source Files

### blend.rs

- `src/color/blend.rs` owns lightweight RGBA blend operators and interpolation helpers used by rendering-side color math.
- `lerp_color`, `multiply`, `screen`, `overlay`, `additive`, and `alpha_blend` live here under one blend-focused owner.
- These functions keep compositing and transition rules separate from color representation, simplifying effect code reuse.
- Read this file when blend equations, clamping rules, or alpha-compositing behavior for runtime visuals need to change.

### color_core.rs

- `src/color/color_core.rs` owns the `Color` type plus the core RGB, HSL, HSV, gamma, and hex conversion routines.
- It defines channel constants, constructors, packing helpers, parsing, serialization, and utility methods together.
- Hex parsing and formatting live here alongside HSL and HSV transforms, keeping interchange and editing rules consistent.
- Brightness, inversion, alpha replacement, and color mixing also live here so higher layers reuse one color model.
- This file is the boundary for color semantics; palettes and blend equations should depend on it, not replace it.
- Read it when channel storage, conversion policy, or text-to-color and color-to-text behavior must change.
- It also centralizes gamma conversion helpers, so renderer-facing color-space policy changes should start in this file.

### mod.rs

- `src/color/mod.rs` is the module index that exposes core color math, blending helpers, and curated palettes.
- It reexports `Color`, conversion functions, blend operators, and palette accessors through one stable color surface.
- No color instances or palette storage live here; this file only declares child modules and defines public visibility.
- Read this index when wiring rendering or styling code, because it shows where color math ends and palette data begins.
- Changes here reshape the color boundary, since reexports decide which helpers other systems import without deep paths.
- This module keeps channel math, conversion logic, and preset palette data separated for clearer ownership and reuse.

### palette.rs

- `src/color/palette.rs` owns named palette datasets and the `Palette` type used to package curated color collections.
- It stores CSS named colors and retro console presets as static data, keeping reusable swatches separate from color math.
- Open this file when preset color libraries, palette naming, or exported curated swatch collections need to change.
- Higher layers should treat it as the palette-data boundary, while conversions and blending stay in sibling color files.
- This file provides reusable color libraries for tooling and styling without mixing preset data into math helpers.



## Lua API Ref

### Functions

- `lurek.color.additive(c1, c2) -> table`: Additive blend of two colors (clamped to 0â€“1 per channel).
- `lurek.color.alphaBlend(fg, bg) -> table`: Alpha compositing (Porter-Duff "over") of foreground over background.
- `lurek.color.brightness(r, g, b) -> number`: Computes perceived luminance (ITU-R BT.601) of an RGB color.
- `lurek.color.fromHex(hex) -> table|nil`: Parses a hex color string ("#RGB", "#RGBA", "#RRGGBB", or "#RRGGBBAA") into a color table.
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

## Examples

- `content/examples/color.lua` (present)

## Architecture Links

- Intentionally empty.

## Notes

- No additional module-specific notes.
