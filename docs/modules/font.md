# Font

- CPU-side font loading, glyph metrics, text measurement, and shaping for bitmap fonts.

The font module provides the CPU-side data layer for text rendering: bitmap font atlas loading with Latin-1 glyph coverage, per-glyph and per-text metrics, text alignment, word and character wrapping, and a central font registry for named handles. The module does not own GPU resources — texture management for font atlases remains in the render module. Fourteen bundled Courier New bitmap atlases are shipped in `assets/fonts/`.

This module is mostly self-contained inside the `Platform Services` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Functions

### `lurek.font.availableSizes`

Returns the array of built-in bitmap font point sizes available in the engine.

```lua
-- signature
lurek.font.availableSizes()
```

**Returns**

| Type | Description |
|------|-------------|
| `table` | Array of integer point sizes available as built-in fonts. |

**Example**

```lua
do
    local sizes = lurek.font.availableSizes()
    print("available sizes = " .. #sizes)
    print("first size = " .. tostring(sizes[1]))
end
```

---

### `lurek.font.charAdvance`

Returns the horizontal advance width in pixels of a single character using the given font.

```lua
-- signature
lurek.font.charAdvance(font, char, scale)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `font` | `LFont` | Font handle. |
| `char` | `string` | A single-character string. |
| `scale?` | `number` | Scale factor (default 1.0). |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Horizontal advance width in pixels. |

**Example**

```lua
do
    local font = lurek.font.getDefault()
    local adv = lurek.font.charAdvance(font, "W", 1.0)
    print("charAdvance W = " .. adv)
end
```

---

### `lurek.font.getDefault`

Returns the default engine font as an LFont userdata handle.

```lua
-- signature
lurek.font.getDefault()
```

**Returns**

| Type | Description |
|------|-------------|
| `LFont` | The default engine font handle. |

**Example**

```lua
do
    local font = lurek.font.getDefault()
    print("default font = " .. tostring(font ~= nil))
end
```

---

### `lurek.font.lineHeight`

Returns the line height of the given font in pixels.

```lua
-- signature
lurek.font.lineHeight(font)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `font` | `LFont` | Font handle to query. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Line height in pixels. |

**Example**

```lua
do
    local font = lurek.font.getDefault()
    local lh = lurek.font.lineHeight(font)
    print("lineHeight = " .. lh)
end
```

---

### `lurek.font.list`

Lists all registered fonts with their name, size, and style metadata.

```lua
-- signature
lurek.font.list()
```

**Returns**

| Type | Description |
|------|-------------|
| `table` | Array of tables with fields: name (string), size (number), style (string). |

**Example**

```lua
do
    local fonts = lurek.font.list()
    print("registered fonts = " .. #fonts)
end
```

---

### `lurek.font.load`

Loads a TTF/OTF/PNG font file at the given point size and returns an LFont handle.

```lua
-- signature
lurek.font.load(path, size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | Relative path to the font file. |
| `size` | `number` | Point size for rasterisation. |

**Returns**

| Type | Description |
|------|-------------|
| `LFont` | The loaded font handle. |

**Example**

```lua
do
    local ok, font = pcall(lurek.font.load, "assets/fonts/default.ttf", 16)
    if ok then
        print("loaded font = " .. font:getName())
    else
        print("load error (expected if file missing): " .. tostring(font))
    end
end
```

---

### `lurek.font.loadBitmap`

Loads a bitmap font atlas PNG with the given cell dimensions and returns an LFont handle.

```lua
-- signature
lurek.font.loadBitmap(path, cellWidth, cellHeight)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | Relative path to the PNG atlas. |
| `cellWidth` | `number` | Cell width in pixels. |
| `cellHeight` | `number` | Cell height in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| `LFont` | The loaded bitmap font handle. |

**Example**

```lua
do
    local ok, font = pcall(lurek.font.loadBitmap, "assets/fonts/bitmap8x8.png", 8, 8)
    if ok then
        print("bitmap font = " .. tostring(font ~= nil))
    else
        print("bitmap load error (expected if file missing): " .. tostring(font))
    end
end
```

---

### `lurek.font.measure`

Measures the pixel dimensions of a text string using the given font handle and scale.

```lua
-- signature
lurek.font.measure(font, text, scale)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `font` | `LFont` | Font handle to measure with. |
| `text` | `string` | Text string to measure. |
| `scale?` | `number` | Scale factor (default 1.0). |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Width in pixels (height returned as second value). |

**Example**

```lua
do
    local font = lurek.font.getDefault()
    local w, h = lurek.font.measure(font, "Hello, Lurek!", 1.0)
    print("measure w=" .. w .. " h=" .. h)
end
```

---

### `lurek.font.measureLine`

Measures the pixel width and height of a single line of text with the given font.

```lua
-- signature
lurek.font.measureLine(font, text, scale)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `font` | `LFont` | Font handle to measure with. |
| `text` | `string` | Single-line text string to measure. |
| `scale?` | `number` | Scale factor (default 1.0). |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Width in pixels (height returned as second value). |

**Example**

```lua
do
    local font = lurek.font.getDefault()
    local w, h = lurek.font.measureLine(font, "Single line text", 1.0)
    print("measureLine w=" .. w .. " h=" .. h)
end
```

---

### `lurek.font.shapeText`

Shapes and aligns text into wrapped lines with x-offset data for rendering.

```lua
-- signature
lurek.font.shapeText(font, text, maxWidth, scale, align, wrap)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `font` | `LFont` | Font handle used for shaping. |
| `text` | `string` | Text to shape. |
| `maxWidth` | `number` | Maximum line width in pixels. |
| `scale` | `number` | Scale factor (default 1.0). |
| `align` | `string` | Alignment: "left", "center", "right", or "justify". |
| `wrap` | `string` | Wrap mode: "none", "word", or "char". |

**Returns**

| Type | Description |
|------|-------------|
| `table` | Array of tables with fields: text (string), width (number), xOffset (number). |

**Example**

```lua
do
    local font = lurek.font.getDefault()
    local shaped = lurek.font.shapeText(
        font,
        "Centered text for layout",
        200,
        1.0,
        lurek.font.ALIGN_CENTER,
        lurek.font.WRAP_WORD
    )
    print("shaped lines = " .. #shaped)
    if #shaped > 0 then
        print("first line width = " .. shaped[1].width)
    end
end
```

---

### `lurek.font.wrapText`

Wraps a text string into lines that fit within the given maximum pixel width.

```lua
-- signature
lurek.font.wrapText(font, text, maxWidth, scale, mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `font` | `LFont` | Font handle used for measurement. |
| `text` | `string` | Text to wrap. |
| `maxWidth` | `number` | Maximum line width in pixels. |
| `scale` | `number` | Scale factor (default 1.0). |
| `mode` | `string` | Wrap mode: "none", "word", or "char". |

**Returns**

| Type | Description |
|------|-------------|
| `table` | Array of wrapped line strings. |

**Example**

```lua
do
    local font = lurek.font.getDefault()
    local lines = lurek.font.wrapText(
        font,
        "This is a long text that should wrap at a reasonable width for display.",
        100,
        1.0,
        lurek.font.WRAP_WORD
    )
    print("wrapped lines = " .. #lines)
end
```

---

## LFont

### `LFont:containsGlyph`

Returns whether the font contains a glyph for the given character. This method is available to Lua scripts.

```lua
-- signature
LFont:containsGlyph(char)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `char` | `string` | A single-character string to check. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the font has a glyph for this character. |

**Example**

```lua
do
    local fnt = lurek.font.getDefault()
    print("font name = " .. fnt:getName())
    print("LFont:containsGlyph A=" .. tostring(fnt:containsGlyph("A")))
end
```

---

### `LFont:getAscent`

Returns the ascent (pixels above the baseline) of this font.

```lua
-- signature
LFont:getAscent()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Ascent in pixels. |

---

### `LFont:getDescent`

Returns the descent (pixels below the baseline) of this font.

```lua
-- signature
LFont:getDescent()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Descent in pixels (positive value extending downward). |

---

### `LFont:getHeight`

Returns the line height of this font in pixels.

```lua
-- signature
LFont:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Line height in pixels. |

---

### `LFont:getLineHeight`

Returns the spacing between consecutive lines of text.

```lua
-- signature
LFont:getLineHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Line height in pixels. |

---

### `LFont:getName`

Returns the human-readable name of this font. This method is available to Lua scripts.

```lua
-- signature
LFont:getName()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Font name. |

**Example**

```lua
do
    local fnt = lurek.font.getDefault()
    print("font handle = " .. tostring(fnt ~= nil))
    print("LFont:getName=" .. fnt:getName())
end
```

---

### `LFont:getSize`

Returns the point size of this font. This method is available to Lua scripts.

```lua
-- signature
LFont:getSize()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Point size. |

**Example**

```lua
do
    local fnt = lurek.font.getDefault()
    print("font name = " .. fnt:getName())
    print("LFont:getSize=" .. fnt:getSize())
end
```

---

### `LFont:getStyle`

Returns the style string of this font. This method is available to Lua scripts.

```lua
-- signature
LFont:getStyle()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Style name ("regular", "bold"). |

**Example**

```lua
do
    local fnt = lurek.font.getDefault()
    print("font size = " .. fnt:getSize())
    print("LFont:getStyle=" .. fnt:getStyle())
end
```

---

### `LFont:getWidth`

Measures the pixel width of a string when rendered with this font.

```lua
-- signature
LFont:getWidth(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `string` | The text to measure. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Width in pixels. |

---

### `LFont:getWrap`

Word-wraps text to fit within a pixel width limit and returns the resulting lines.

```lua
-- signature
LFont:getWrap(text, limit)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `string` | The text to wrap. |
| `limit` | `number` | Maximum line width in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| `table` | a Array of wrapped line strings, and the widest line width. |
| `number` | b Array of wrapped line strings, and the widest line width. |

---

### `LFont:isBold`

Returns whether this font is the bold variant. This method is available to Lua scripts.

```lua
-- signature
LFont:isBold()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if font style is bold. |

**Example**

```lua
do
    local fnt = lurek.font.getDefault()
    print("font style = " .. fnt:getStyle())
    print("LFont:isBold=" .. tostring(fnt:isBold()))
end
```

---

### `LFont:lineHeight`

Returns the line height of this font in pixels. This method is available to Lua scripts.

```lua
-- signature
LFont:lineHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Line height in pixels. |

**Example**

```lua
do
    local fnt = lurek.font.getDefault()
    print("font size = " .. fnt:getSize())
    print("LFont:lineHeight=" .. fnt:lineHeight())
end
```

---

### `LFont:measure`

Measures the pixel dimensions of a text string at the given scale. This method is available to Lua scripts.

```lua
-- signature
LFont:measure(text, scale)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `string` | Text to measure. |
| `scale?` | `number` | Scale factor applied to dimensions. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Width and height in pixels. |
| `number` | b Width and height in pixels. |

**Example**

```lua
do
    local fnt = lurek.font.getDefault()
    local w, h = fnt:measure("Hello, World!", 1.0)
    print("LFont:measure w=" .. w .. " h=" .. h)
end
```

---

### `LFont:release`

Releases the font resource. The handle becomes invalid after this call.

```lua
-- signature
LFont:release()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the font was still valid and was released. |

---

### `LFont:setLineHeight`

Overrides the line height used for multi-line text rendering.

```lua
-- signature
LFont:setLineHeight(height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `height` | `number` | New line height in pixels. |

---

### `LFont:type`

Returns the type name string for this font object.

```lua
-- signature
LFont:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Always "LFont". |

---

### `LFont:typeOf`

Checks whether this object matches the given type name.

```lua
-- signature
LFont:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to check ("Font" or "Object"). |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the name matches. |

---

### `LFont:wrapText`

Wraps text into lines fitting within the given max width. This method is available to Lua scripts.

```lua
-- signature
LFont:wrapText(text, maxWidth, scale)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `string` | Text to wrap. |
| `maxWidth` | `number` | Maximum line width in pixels. |
| `scale?` | `number` | Scale factor. |

**Returns**

| Type | Description |
|------|-------------|
| `table` | Array of wrapped line strings. |

**Example**

```lua
do
    local fnt = lurek.font.getDefault()
    local lines = fnt:wrapText("This is a long line that needs wrapping.", 200, 1.0)
    print("LFont:wrapText lines=" .. #lines)
end
```

---
