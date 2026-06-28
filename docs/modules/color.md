# Color

## Purpose

Manages color spaces, blends, and retro palettes.

## Summary

- The `color` module is the shared toolbox for defining, converting, and reusing runtime color values across the engine.
- It combines low-level color math with practical authoring workflows, so scripts can move between RGB, HSL, HSV, hex, blending, and interpolation without custom conversion helpers.
- That makes it useful for themes, fades, highlights, palette work, and effect tuning.
- Read it as the common color language for the engine: other systems decide where color is used, but `color` keeps conversion, composition, and palette logic consistent.

This module is mostly self-contained inside the `Foundations` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## API Reference

- This page is the generated API reference for this module.

## Functions

### `lurek.color.additive`

Additive blend of two colors (clamped to 0-1 per channel).

```lua
lurek.color.additive(c1, c2)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `c1` | table | First color {r, g, b, a}. |
| `c2` | table | Second color {r, g, b, a}. |

**Returns**

| Type | Description |
|------|-------------|
| table | Additively blended color table. |

**Example**

```lua
do
    local a = lurek.color.new(0.5, 0.3, 0.1)
    local b = lurek.color.new(0.3, 0.4, 0.2)
    local result = lurek.color.additive(a, b)
    lurek.log.info(tostring("additive r=" .. string.format("%.2f", result[1]) .. " g=" .. string.format("%.2f", result[2])))
    lurek.log.info(tostring("additive b=" .. string.format("%.2f", result[3])))
end
```

---

### `lurek.color.alphaBlend`

Alpha compositing (Porter-Duff "over") of foreground over background.

```lua
lurek.color.alphaBlend(fg, bg)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `fg` | table | Foreground color {r, g, b, a}. |
| `bg` | table | Background color {r, g, b, a}. |

**Returns**

| Type | Description |
|------|-------------|
| table | Composited color table. |

**Example**

```lua
do
    local fg = lurek.color.new(1, 0, 0, 0.5)
    local bg = lurek.color.new(0, 0, 1, 1.0)
    local result = lurek.color.alphaBlend(fg, bg)
    lurek.log.info(tostring("alphaBlend r=" .. string.format("%.2f", result[1]) .. " b=" .. string.format("%.2f", result[3])))
    lurek.log.info(tostring("alphaBlend a=" .. string.format("%.2f", result[4])))
end
```

---

### `lurek.color.brightness`

Computes perceived luminance (ITU-R BT.601) of an RGB color.

```lua
lurek.color.brightness(r, g, b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | number | Red channel (0-1). |
| `g` | number | Green channel (0-1). |
| `b` | number | Blue channel (0-1). |

**Returns**

| Type | Description |
|------|-------------|
| number | Perceived brightness (0-1). |

**Example**

```lua
do
    local lum = lurek.color.brightness(0.5, 0.5, 0.5)
    local dark = lurek.color.brightness(0.1, 0.1, 0.1)
    local bright = lurek.color.brightness(0.9, 0.9, 0.9)
    lurek.log.info(tostring("brightness = " .. string.format("%.3f", lum)))
    lurek.log.info(tostring("dark brightness = " .. string.format("%.3f", dark)))
    lurek.log.info(tostring("bright brightness = " .. string.format("%.3f", bright)))
end
```

---

### `lurek.color.fromHex`

Parses a hex color string ("#RGB", "#RGBA", "#RRGGBB", or "#RRGGBBAA") into a color table.

```lua
lurek.color.fromHex(hex)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `hex` | string | Hex color string with leading '#'. |

**Returns**

| Type | Description |
|------|-------------|
| table | nil | Color table or nil if parsing fails. |

**Example**

```lua
do
    local c = lurek.color.fromHex("#FF6600")
    if c then
        lurek.log.info(tostring("fromHex r=" .. string.format("%.2f", c[1]) .. " g=" .. string.format("%.2f", c[2]) .. " b=" .. string.format("%.2f", c[3])))
        lurek.log.info(tostring("fromHex alpha=" .. string.format("%.2f", c[4])))
    end
end
```

---

### `lurek.color.fromHsl`

Creates a color from HSL components. Returns an opaque color (alpha = 1).

```lua
lurek.color.fromHsl(h, s, l)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `h` | number | Hue in degrees (0-360). |
| `s` | number | Saturation (0-1). |
| `l` | number | Lightness (0-1). |

**Returns**

| Type | Description |
|------|-------------|
| table | Color table {r, g, b, a}. |

**Example**

```lua
do
    local c = lurek.color.fromHsl(210, 0.8, 0.5)
    local h, s, l = lurek.color.toHsl(c[1], c[2], c[3])
    lurek.log.info(tostring("fromHsl r=" .. string.format("%.2f", c[1]) .. " g=" .. string.format("%.2f", c[2]) .. " b=" .. string.format("%.2f", c[3])))
    lurek.log.info(tostring("fromHsl hex=" .. lurek.color.toHex(c[1], c[2], c[3], c[4])))
    lurek.log.info(tostring("fromHsl back hsl=" .. string.format("%.1f, %.2f, %.2f", h, s, l)))
end
```

---

### `lurek.color.fromHsv`

Creates a color from HSV components. Returns an opaque color (alpha = 1).

```lua
lurek.color.fromHsv(h, s, v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `h` | number | Hue in degrees (0-360). |
| `s` | number | Saturation (0-1). |
| `v` | number | Value/brightness (0-1). |

**Returns**

| Type | Description |
|------|-------------|
| table | Color table {r, g, b, a}. |

**Example**

```lua
do
    local c = lurek.color.fromHsv(120, 1.0, 0.8)
    local lum = lurek.color.brightness(c[1], c[2], c[3])
    lurek.log.info(tostring("fromHsv r=" .. string.format("%.2f", c[1]) .. " g=" .. string.format("%.2f", c[2]) .. " b=" .. string.format("%.2f", c[3])))
    lurek.log.info(tostring("fromHsv alpha=" .. string.format("%.2f", c[4])))
    lurek.log.info(tostring("fromHsv brightness=" .. string.format("%.3f", lum)))
end
```

---

### `lurek.color.fromU8`

Creates a color from 0-255 integer components. Alpha defaults to 255.

```lua
lurek.color.fromU8(r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | number | Red channel (0-255). |
| `g` | number | Green channel (0-255). |
| `b` | number | Blue channel (0-255). |
| `a?` | number | Alpha channel (0-255); defaults to 255. |

**Returns**

| Type | Description |
|------|-------------|
| table | Color table {r, g, b, a} with values normalised to 0-1. |

**Example**

```lua
do
    local c = lurek.color.fromU8(255, 128, 0, 255)
    local hex = lurek.color.toHex(c[1], c[2], c[3], c[4])
    lurek.log.info(tostring("fromU8 r=" .. string.format("%.2f", c[1]) .. " g=" .. string.format("%.2f", c[2]) .. " b=" .. string.format("%.2f", c[3])))
    lurek.log.info(tostring("fromU8 a=" .. string.format("%.2f", c[4])))
    lurek.log.info(tostring("fromU8 hex=" .. hex))
end
```

---

### `lurek.color.gammaToLinear`

Converts a single sRGB gamma-encoded component to linear space.

```lua
lurek.color.gammaToLinear(c)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `c` | number | Gamma-encoded value (0-1). |

**Returns**

| Type | Description |
|------|-------------|
| number | Linear value. |

**Example**

```lua
do
    local linear = lurek.color.gammaToLinear(0.5)
    local gamma = lurek.color.linearToGamma(linear)
    local boosted = lurek.color.withAlpha(linear, linear, linear, 1.0, 0.75)
    lurek.log.info(tostring("gammaToLinear = " .. string.format("%.4f", linear)))
    lurek.log.info(tostring("roundtrip gamma = " .. string.format("%.4f", gamma)))
    lurek.log.info(tostring("boosted alpha = " .. string.format("%.2f", boosted[4])))
end
```

---

### `lurek.color.invert`

Inverts the RGB channels of a color, keeping alpha unchanged.

```lua
lurek.color.invert(r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | number | Red channel (0-1). |
| `g` | number | Green channel (0-1). |
| `b` | number | Blue channel (0-1). |
| `a?` | number | Alpha channel (0-1); defaults to 1.0. |

**Returns**

| Type | Description |
|------|-------------|
| table | Inverted color table. |

**Example**

```lua
do
    local inv = lurek.color.invert(0.2, 0.8, 0.4)
    local restored = lurek.color.invert(inv[1], inv[2], inv[3], inv[4])
    lurek.log.info(tostring("invert r=" .. string.format("%.2f", inv[1]) .. " g=" .. string.format("%.2f", inv[2]) .. " b=" .. string.format("%.2f", inv[3])))
    lurek.log.info(tostring("invert a=" .. string.format("%.2f", inv[4])))
    lurek.log.info(tostring("double invert r=" .. string.format("%.2f", restored[1])))
end
```

---

### `lurek.color.lerp`

Linearly interpolates between two color tables by factor t (clamped to 0-1).

```lua
lurek.color.lerp(c1, c2, t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `c1` | table | Start color {r, g, b, a}. |
| `c2` | table | End color {r, g, b, a}. |
| `t` | number | Interpolation factor (0-1). |

**Returns**

| Type | Description |
|------|-------------|
| table | Interpolated color table. |

**Example**

```lua
do
    local red = lurek.color.new(1, 0, 0)
    local blue = lurek.color.new(0, 0, 1)
    local mid = lurek.color.lerp(red, blue, 0.5)
    lurek.log.info(tostring("lerp r=" .. string.format("%.2f", mid[1]) .. " b=" .. string.format("%.2f", mid[3])))
    lurek.log.info(tostring("lerp alpha=" .. string.format("%.2f", mid[4])))
end
```

---

### `lurek.color.linearToGamma`

Converts a single linear component to sRGB gamma-encoded space.

```lua
lurek.color.linearToGamma(c)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `c` | number | Linear value (0-1). |

**Returns**

| Type | Description |
|------|-------------|
| number | Gamma-encoded value. |

**Example**

```lua
do
    local gamma = lurek.color.linearToGamma(0.2)
    local linear = lurek.color.gammaToLinear(gamma)
    local hex = lurek.color.toHex(gamma, gamma, gamma, 1.0)
    lurek.log.info(tostring("linearToGamma = " .. string.format("%.4f", gamma)))
    lurek.log.info(tostring("roundtrip linear = " .. string.format("%.4f", linear)))
    lurek.log.info(tostring("gray hex = " .. hex))
end
```

---

### `lurek.color.multiply`

Channel-wise multiply blend of two colors.

```lua
lurek.color.multiply(c1, c2)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `c1` | table | First color {r, g, b, a}. |
| `c2` | table | Second color {r, g, b, a}. |

**Returns**

| Type | Description |
|------|-------------|
| table | Multiplied color table. |

**Example**

```lua
do
    local a = lurek.color.new(0.8, 0.6, 0.4)
    local b = lurek.color.new(0.5, 0.5, 0.5)
    local result = lurek.color.multiply(a, b)
    lurek.log.info(tostring("multiply r=" .. string.format("%.2f", result[1]) .. " g=" .. string.format("%.2f", result[2])))
    lurek.log.info(tostring("multiply b=" .. string.format("%.2f", result[3])))
end
```

---

### `lurek.color.new`

Creates an RGBA color from 0-1 float components. Alpha defaults to 1.0.

```lua
lurek.color.new(r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | number | Red channel (0-1). |
| `g` | number | Green channel (0-1). |
| `b` | number | Blue channel (0-1). |
| `a?` | number | Alpha channel (0-1); defaults to 1.0. |

**Returns**

| Type | Description |
|------|-------------|
| table | Color table {r, g, b, a}. |

**Example**

```lua
do
    local c = lurek.color.new(0.2, 0.6, 0.9, 1.0)
    local h, s, l = lurek.color.toHsl(c[1], c[2], c[3])
    lurek.log.info(tostring("color r=" .. c[1] .. " g=" .. c[2] .. " b=" .. c[3] .. " a=" .. c[4]))
    lurek.log.info(tostring("hex = " .. lurek.color.toHex(c[1], c[2], c[3], c[4])))
    lurek.log.info(tostring("hsl = " .. string.format("%.1f, %.2f, %.2f", h, s, l)))
end
```

---

### `lurek.color.overlay`

Overlay blend of two colors exposed by the lurek engine.

```lua
lurek.color.overlay(base, blend)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `base` | table | Base color {r, g, b, a}. |
| `blend` | table | Blend color {r, g, b, a}. |

**Returns**

| Type | Description |
|------|-------------|
| table | Overlay-blended color table. |

**Example**

```lua
do
    local base = lurek.color.new(0.4, 0.4, 0.4)
    local blend = lurek.color.new(0.8, 0.2, 0.6)
    local result = lurek.color.overlay(base, blend)
    lurek.log.info(tostring("overlay r=" .. string.format("%.2f", result[1]) .. " g=" .. string.format("%.2f", result[2])))
    lurek.log.info(tostring("overlay b=" .. string.format("%.2f", result[3])))
end
```

---

### `lurek.color.palette`

Returns a named retro palette as a table of color tables. Supported: "pico8", "gameboy", "nes".

```lua
lurek.color.palette(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Palette name ("pico8", "gameboy", or "nes"). |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of color tables, or empty table if name is unknown. |

**Example**

```lua
do
    local pal = lurek.color.palette("pico8")
    lurek.log.info(tostring("pico8 palette count = " .. #pal))
    if #pal > 0 then
        lurek.log.info(tostring("first pico8 color = " .. string.format("%.2f", pal[1][1]) .. ", " .. string.format("%.2f", pal[1][2]) .. ", " .. string.format("%.2f", pal[1][3])))
    end
end
```

---

### `lurek.color.screen`

Apply screen blend mode to combine two color values.

```lua
lurek.color.screen(c1, c2)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `c1` | table | First color {r, g, b, a}. |
| `c2` | table | Second color {r, g, b, a}. |

**Returns**

| Type | Description |
|------|-------------|
| table | Screen-blended color table. |

**Example**

```lua
do
    local a = lurek.color.new(0.3, 0.3, 0.3)
    local b = lurek.color.new(0.6, 0.6, 0.6)
    local result = lurek.color.screen(a, b)
    lurek.log.info(tostring("screen r=" .. string.format("%.2f", result[1])))
    lurek.log.info(tostring("screen g=" .. string.format("%.2f", result[2])))
end
```

---

### `lurek.color.toHex`

Converts RGBA components to a hex string ("#RRGGBB" or "#RRGGBBAA" if alpha < 1).

```lua
lurek.color.toHex(r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | number | Red channel (0-1). |
| `g` | number | Green channel (0-1). |
| `b` | number | Blue channel (0-1). |
| `a?` | number | Alpha channel (0-1); defaults to 1.0. |

**Returns**

| Type | Description |
|------|-------------|
| string | Hex color string. |

**Example**

```lua
do
    local hex = lurek.color.toHex(1.0, 0.5, 0.0)
    local c = lurek.color.fromHex(hex)
    local brightness = lurek.color.brightness(c[1], c[2], c[3])
    lurek.log.info(tostring("toHex = " .. hex))
    lurek.log.info(tostring("roundtrip r=" .. string.format("%.2f", c[1]) .. " g=" .. string.format("%.2f", c[2])))
    lurek.log.info(tostring("brightness = " .. string.format("%.3f", brightness)))
end
```

---

### `lurek.color.toHsl`

Convert RGB color components to HSL color representation.

```lua
lurek.color.toHsl(r, g, b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | number | Red channel (0-1). |
| `g` | number | Green channel (0-1). |
| `b` | number | Blue channel (0-1). |

**Returns**

| Type | Description |
|------|-------------|
| number | Hue (0-360); saturation (0-1); lightness (0-1). (value 1). |
| number | Hue (0-360); saturation (0-1); lightness (0-1). (value 2). |
| number | Hue (0-360); saturation (0-1); lightness (0-1). (value 3). |

**Example**

```lua
do
    local h, s, l = lurek.color.toHsl(0.2, 0.6, 0.9)
    local c = lurek.color.fromHsl(h, s, l)
    local hex = lurek.color.toHex(c[1], c[2], c[3], c[4])
    lurek.log.info(tostring("toHsl h=" .. string.format("%.1f", h) .. " s=" .. string.format("%.2f", s) .. " l=" .. string.format("%.2f", l)))
    lurek.log.info(tostring("roundtrip hex=" .. hex))
end
```

---

### `lurek.color.withAlpha`

Returns a color with the alpha channel replaced.

```lua
lurek.color.withAlpha(r, g, b, a, newAlpha)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | number | Red channel (0-1). |
| `g` | number | Green channel (0-1). |
| `b` | number | Blue channel (0-1). |
| `a` | number | Original alpha (ignored in output). |
| `newAlpha` | number | New alpha channel value (0-1). |

**Returns**

| Type | Description |
|------|-------------|
| table | Color table with the new alpha. |

**Example**

```lua
do
    local c = lurek.color.withAlpha(0.9, 0.2, 0.3, 1.0, 0.5)
    local hex = lurek.color.toHex(c[1], c[2], c[3], c[4])
    lurek.log.info(tostring("withAlpha a=" .. string.format("%.1f", c[4])))
    lurek.log.info(tostring("withAlpha rgb = " .. string.format("%.1f", c[1]) .. ", " .. string.format("%.1f", c[2]) .. ", " .. string.format("%.1f", c[3])))
    lurek.log.info(tostring("withAlpha hex = " .. hex))
end
```

---

## Module Fields

*No module-level fields documented.*

## Enums

*No module-specific enums documented.*

## Types

*No Lua userdata types detected for this module.*
