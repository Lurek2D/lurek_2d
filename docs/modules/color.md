# Color

- RGBA color primitives with color-space conversions, blending modes, and predefined palettes for 2D rendering.

The color module provides linear RGBA float color types, constructors from multiple color spaces (hex, HSL, HSV, u8), blending operations (lerp, multiply, screen, overlay, additive, alpha blend), and predefined palettes (CSS named colors, PICO-8, Game Boy, NES). Colors in Lua are plain tables `{r, g, b, a}` indexed 1–4 for maximum interop with rendering APIs. The module also exposes gamma↔linear conversion utilities and a brightness calculator.

This module is mostly self-contained inside the `Foundations` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Functions

### `lurek.color.additive`

Additive blend of two colors (clamped to 0–1 per channel).

```lua
-- signature
lurek.color.additive(c1, c2)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `c1` | `table` | First color {r, g, b, a}. |
| `c2` | `table` | Second color {r, g, b, a}. |

**Returns**

| Type | Description |
|------|-------------|
| `table` | Additively blended color table. |

**Example**

```lua
do
    local a = lurek.color.new(0.5, 0.3, 0.1)
    local b = lurek.color.new(0.3, 0.4, 0.2)
    local result = lurek.color.additive(a, b)
    print("additive r=" .. string.format("%.2f", result[1]) .. " g=" .. string.format("%.2f", result[2]))
    print("additive b=" .. string.format("%.2f", result[3]))
end
```

---

### `lurek.color.alphaBlend`

Alpha compositing (Porter-Duff "over") of foreground over background.

```lua
-- signature
lurek.color.alphaBlend(fg, bg)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `fg` | `table` | Foreground color {r, g, b, a}. |
| `bg` | `table` | Background color {r, g, b, a}. |

**Returns**

| Type | Description |
|------|-------------|
| `table` | Composited color table. |

**Example**

```lua
do
    local fg = lurek.color.new(1, 0, 0, 0.5)
    local bg = lurek.color.new(0, 0, 1, 1.0)
    local result = lurek.color.alphaBlend(fg, bg)
    print("alphaBlend r=" .. string.format("%.2f", result[1]) .. " b=" .. string.format("%.2f", result[3]))
    print("alphaBlend a=" .. string.format("%.2f", result[4]))
end
```

---

### `lurek.color.brightness`

Computes perceived luminance (ITU-R BT.601) of an RGB color.

```lua
-- signature
lurek.color.brightness(r, g, b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | `number` | Red channel (0–1). |
| `g` | `number` | Green channel (0–1). |
| `b` | `number` | Blue channel (0–1). |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Perceived brightness (0–1). |

**Example**

```lua
do
    local lum = lurek.color.brightness(0.5, 0.5, 0.5)
    print("brightness = " .. string.format("%.3f", lum))
end
```

---

### `lurek.color.fromHex`

Parses a hex color string ("#RRGGBB" or "#RRGGBBAA") into a color table. Returns nil on invalid input.

```lua
-- signature
lurek.color.fromHex(hex)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `hex` | `string` | Hex color string with leading '#'. |

**Returns**

| Type | Description |
|------|-------------|
| `table` | nil | Color table or nil if parsing fails. |

**Example**

```lua
do
    local c = lurek.color.fromHex("#FF6600")
    if c then
        print("fromHex r=" .. string.format("%.2f", c[1]) .. " g=" .. string.format("%.2f", c[2]) .. " b=" .. string.format("%.2f", c[3]))
        print("fromHex alpha=" .. string.format("%.2f", c[4]))
    end
end
```

---

### `lurek.color.fromHsl`

Creates a color from HSL components. Returns an opaque color (alpha = 1).

```lua
-- signature
lurek.color.fromHsl(h, s, l)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `h` | `number` | Hue in degrees (0–360). |
| `s` | `number` | Saturation (0–1). |
| `l` | `number` | Lightness (0–1). |

**Returns**

| Type | Description |
|------|-------------|
| `table` | Color table {r, g, b, a}. |

**Example**

```lua
do
    local c = lurek.color.fromHsl(210, 0.8, 0.5)
    print("fromHsl r=" .. string.format("%.2f", c[1]) .. " g=" .. string.format("%.2f", c[2]) .. " b=" .. string.format("%.2f", c[3]))
    print("fromHsl hex=" .. lurek.color.toHex(c[1], c[2], c[3], c[4]))
end
```

---

### `lurek.color.fromHsv`

Creates a color from HSV components. Returns an opaque color (alpha = 1).

```lua
-- signature
lurek.color.fromHsv(h, s, v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `h` | `number` | Hue in degrees (0–360). |
| `s` | `number` | Saturation (0–1). |
| `v` | `number` | Value/brightness (0–1). |

**Returns**

| Type | Description |
|------|-------------|
| `table` | Color table {r, g, b, a}. |

**Example**

```lua
do
    local c = lurek.color.fromHsv(120, 1.0, 0.8)
    print("fromHsv r=" .. string.format("%.2f", c[1]) .. " g=" .. string.format("%.2f", c[2]) .. " b=" .. string.format("%.2f", c[3]))
    print("fromHsv alpha=" .. string.format("%.2f", c[4]))
end
```

---

### `lurek.color.fromU8`

Creates a color from 0–255 integer components. Alpha defaults to 255.

```lua
-- signature
lurek.color.fromU8(r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | `number` | Red channel (0–255). |
| `g` | `number` | Green channel (0–255). |
| `b` | `number` | Blue channel (0–255). |
| `a?` | `number` | Alpha channel (0–255); defaults to 255. |

**Returns**

| Type | Description |
|------|-------------|
| `table` | Color table {r, g, b, a} with values normalised to 0–1. |

**Example**

```lua
do
    local c = lurek.color.fromU8(255, 128, 0, 255)
    print("fromU8 r=" .. string.format("%.2f", c[1]) .. " g=" .. string.format("%.2f", c[2]) .. " b=" .. string.format("%.2f", c[3]))
    print("fromU8 a=" .. string.format("%.2f", c[4]))
end
```

---

### `lurek.color.gammaToLinear`

Converts a single sRGB gamma-encoded component to linear space.

```lua
-- signature
lurek.color.gammaToLinear(c)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `c` | `number` | Gamma-encoded value (0–1). |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Linear value. |

**Example**

```lua
do
    local linear = lurek.color.gammaToLinear(0.5)
    print("gammaToLinear = " .. string.format("%.4f", linear))
end
```

---

### `lurek.color.invert`

Inverts the RGB channels of a color, keeping alpha unchanged.

```lua
-- signature
lurek.color.invert(r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | `number` | Red channel (0–1). |
| `g` | `number` | Green channel (0–1). |
| `b` | `number` | Blue channel (0–1). |
| `a?` | `number` | Alpha channel (0–1); defaults to 1.0. |

**Returns**

| Type | Description |
|------|-------------|
| `table` | Inverted color table. |

**Example**

```lua
do
    local inv = lurek.color.invert(0.2, 0.8, 0.4)
    print("invert r=" .. string.format("%.2f", inv[1]) .. " g=" .. string.format("%.2f", inv[2]) .. " b=" .. string.format("%.2f", inv[3]))
    print("invert a=" .. string.format("%.2f", inv[4]))
end
```

---

### `lurek.color.lerp`

Linearly interpolates between two color tables by factor t (clamped to 0–1).

```lua
-- signature
lurek.color.lerp(c1, c2, t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `c1` | `table` | Start color {r, g, b, a}. |
| `c2` | `table` | End color {r, g, b, a}. |
| `t` | `number` | Interpolation factor (0–1). |

**Returns**

| Type | Description |
|------|-------------|
| `table` | Interpolated color table. |

**Example**

```lua
do
    local red = lurek.color.new(1, 0, 0)
    local blue = lurek.color.new(0, 0, 1)
    local mid = lurek.color.lerp(red, blue, 0.5)
    print("lerp r=" .. string.format("%.2f", mid[1]) .. " b=" .. string.format("%.2f", mid[3]))
    print("lerp alpha=" .. string.format("%.2f", mid[4]))
end
```

---

### `lurek.color.linearToGamma`

Converts a single linear component to sRGB gamma-encoded space.

```lua
-- signature
lurek.color.linearToGamma(c)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `c` | `number` | Linear value (0–1). |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Gamma-encoded value. |

**Example**

```lua
do
    local gamma = lurek.color.linearToGamma(0.2)
    print("linearToGamma = " .. string.format("%.4f", gamma))
end
```

---

### `lurek.color.multiply`

Channel-wise multiply blend of two colors.

```lua
-- signature
lurek.color.multiply(c1, c2)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `c1` | `table` | First color {r, g, b, a}. |
| `c2` | `table` | Second color {r, g, b, a}. |

**Returns**

| Type | Description |
|------|-------------|
| `table` | Multiplied color table. |

**Example**

```lua
do
    local a = lurek.color.new(0.8, 0.6, 0.4)
    local b = lurek.color.new(0.5, 0.5, 0.5)
    local result = lurek.color.multiply(a, b)
    print("multiply r=" .. string.format("%.2f", result[1]) .. " g=" .. string.format("%.2f", result[2]))
    print("multiply b=" .. string.format("%.2f", result[3]))
end
```

---

### `lurek.color.new`

Creates an RGBA color from 0–1 float components. Alpha defaults to 1.0.

```lua
-- signature
lurek.color.new(r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | `number` | Red channel (0–1). |
| `g` | `number` | Green channel (0–1). |
| `b` | `number` | Blue channel (0–1). |
| `a?` | `number` | Alpha channel (0–1); defaults to 1.0. |

**Returns**

| Type | Description |
|------|-------------|
| `table` | Color table {r, g, b, a}. |

**Example**

```lua
do
    local c = lurek.color.new(0.2, 0.6, 0.9, 1.0)
    print("color r=" .. c[1] .. " g=" .. c[2] .. " b=" .. c[3] .. " a=" .. c[4])
    print("hex = " .. lurek.color.toHex(c[1], c[2], c[3], c[4]))
end
```

---

### `lurek.color.overlay`

Overlay blend of two colors exposed by the lurek engine.

```lua
-- signature
lurek.color.overlay(base, blend)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `base` | `table` | Base color {r, g, b, a}. |
| `blend` | `table` | Blend color {r, g, b, a}. |

**Returns**

| Type | Description |
|------|-------------|
| `table` | Overlay-blended color table. |

**Example**

```lua
do
    local base = lurek.color.new(0.4, 0.4, 0.4)
    local blend = lurek.color.new(0.8, 0.2, 0.6)
    local result = lurek.color.overlay(base, blend)
    print("overlay r=" .. string.format("%.2f", result[1]) .. " g=" .. string.format("%.2f", result[2]))
    print("overlay b=" .. string.format("%.2f", result[3]))
end
```

---

### `lurek.color.palette`

Returns a named retro palette as a table of color tables. Supported: "pico8", "gameboy", "nes".

```lua
-- signature
lurek.color.palette(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Palette name ("pico8", "gameboy", or "nes"). |

**Returns**

| Type | Description |
|------|-------------|
| `table` | Array of color tables, or empty table if name is unknown. |

**Example**

```lua
do
    local pal = lurek.color.palette("pico8")
    print("pico8 palette count = " .. #pal)
    if #pal > 0 then
        print("first pico8 color = " .. string.format("%.2f", pal[1][1]) .. ", " .. string.format("%.2f", pal[1][2]) .. ", " .. string.format("%.2f", pal[1][3]))
    end
end
```

---

### `lurek.color.screen`

Apply screen blend mode to combine two color values.

```lua
-- signature
lurek.color.screen(c1, c2)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `c1` | `table` | First color {r, g, b, a}. |
| `c2` | `table` | Second color {r, g, b, a}. |

**Returns**

| Type | Description |
|------|-------------|
| `table` | Screen-blended color table. |

**Example**

```lua
do
    local a = lurek.color.new(0.3, 0.3, 0.3)
    local b = lurek.color.new(0.6, 0.6, 0.6)
    local result = lurek.color.screen(a, b)
    print("screen r=" .. string.format("%.2f", result[1]))
    print("screen g=" .. string.format("%.2f", result[2]))
end
```

---

### `lurek.color.toHex`

Converts RGBA components to a hex string ("#RRGGBB" or "#RRGGBBAA" if alpha < 1).

```lua
-- signature
lurek.color.toHex(r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | `number` | Red channel (0–1). |
| `g` | `number` | Green channel (0–1). |
| `b` | `number` | Blue channel (0–1). |
| `a?` | `number` | Alpha channel (0–1); defaults to 1.0. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | Hex color string. |

**Example**

```lua
do
    local hex = lurek.color.toHex(1.0, 0.5, 0.0)
    print("toHex = " .. hex)
end
```

---

### `lurek.color.toHsl`

Convert RGB color components to HSL color representation.

```lua
-- signature
lurek.color.toHsl(r, g, b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | `number` | Red channel (0–1). |
| `g` | `number` | Green channel (0–1). |
| `b` | `number` | Blue channel (0–1). |

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Hue (0–360), saturation (0–1), lightness (0–1). |
| `number` | b Hue (0–360), saturation (0–1), lightness (0–1). |
| `number` | c Hue (0–360), saturation (0–1), lightness (0–1). |

**Example**

```lua
do
    local h, s, l = lurek.color.toHsl(0.2, 0.6, 0.9)
    print("toHsl h=" .. string.format("%.1f", h) .. " s=" .. string.format("%.2f", s) .. " l=" .. string.format("%.2f", l))
end
```

---

### `lurek.color.withAlpha`

Returns a color with the alpha channel replaced.

```lua
-- signature
lurek.color.withAlpha(r, g, b, a, newAlpha)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | `number` | Red channel (0–1). |
| `g` | `number` | Green channel (0–1). |
| `b` | `number` | Blue channel (0–1). |
| `a` | `number` | Original alpha (ignored in output). |
| `newAlpha` | `number` | New alpha channel value (0–1). |

**Returns**

| Type | Description |
|------|-------------|
| `table` | Color table with the new alpha. |

**Example**

```lua
do
    local c = lurek.color.withAlpha(0.9, 0.2, 0.3, 1.0, 0.5)
    print("withAlpha a=" .. string.format("%.1f", c[4]))
    print("withAlpha rgb = " .. string.format("%.1f", c[1]) .. ", " .. string.format("%.1f", c[2]) .. ", " .. string.format("%.1f", c[3]))
end
```

---
