# Font

## Purpose

Manages font loading, metrics caching, and text wrapping.

## When To Use

- It covers loading and registering fonts, so scripts can reuse named font resources instead of rebuilding text setup at every draw site.
- Measurement and shaping are just as important as loading here: glyph metrics, wrapping, line sizing, and text geometry helpers let layout code make reliable decisions before anything is rendered.
- Read this module as the place where text data becomes stable and reusable. Rendering and UI systems still decide where text appears, but font keeps measurement consistent.

## Minimal Example

Example block: `lurek.font.getDefault`

```lua
do
    local function font_log(message)
        lurek.log.info("[font.example] " .. tostring(message))
    end
    local function ui_title()
        return "Province Ledger"
    end
    local function ui_briefing()
        return "Northern provinces need supply wagons before winter roads close."
    end
    local function sample_font_path()
        return "content/examples/assets/fonts/sample_font.ttf"
    end

    local font = lurek.font.getDefault()
    local name = font:getName()
    local size = font:getSize()
    local line_height = font:lineHeight()
    local title_width = select(1, font:measure(ui_title(), 1.0))
    font_log("default ui font name=" .. tostring(name) .. " size=" .. tostring(size) .. " line_height=" .. tostring(line_height) .. " title_width=" .. tostring(title_width))
end
```

## Common Patterns

- Start with `lurek.font.availableSizes` when exploring this module.
- Start with `lurek.font.charAdvance` when exploring this module.
- Start with `lurek.font.getDefault` when exploring this module.
- Start with `lurek.font.lineHeight` when exploring this module.
- Start with `lurek.font.list` when exploring this module.

## API Reference

- This page is the generated API reference for this module.

## Summary

- The `font` module is the typography layer for users who need predictable text behavior in UI, HUDs, overlays, or retro-style screens.
- It covers loading and registering fonts, so scripts can reuse named font resources instead of rebuilding text setup at every draw site.
- Measurement and shaping are just as important as loading here: glyph metrics, wrapping, line sizing, and text geometry helpers let layout code make reliable decisions before anything is rendered.
- Read this module as the place where text data becomes stable and reusable. Rendering and UI systems still decide where text appears, but `font` keeps measurement consistent.

This module is mostly self-contained inside the `Platform Services` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Functions

### `lurek.font.availableSizes`

Returns the array of built-in bitmap font point sizes available in the engine.

```lua
lurek.font.availableSizes()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Array of integer point sizes available as built-in fonts. |

**Example**

```lua
do
    local function font_log(message)
        lurek.log.info("[font.example] " .. tostring(message))
    end
    local function ui_title()
        return "Province Ledger"
    end
    local function ui_briefing()
        return "Northern provinces need supply wagons before winter roads close."
    end
    local function sample_font_path()
        return "content/examples/assets/fonts/sample_font.ttf"
    end

    local sizes = lurek.font.availableSizes()
    local smallest = sizes[1]
    local largest = sizes[#sizes]
    local requested = 14
    local fallback = largest and math.min(requested, largest) or requested
    font_log("built-in menu sizes count=" .. tostring(#sizes) .. " smallest=" .. tostring(smallest) .. " largest=" .. tostring(largest) .. " fallback_for_14=" .. tostring(fallback))
end
```

---

### `lurek.font.charAdvance`

Returns the horizontal advance width in pixels of a single character using the given font.

```lua
lurek.font.charAdvance(font, char, scale)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `font` | [LFont](#lfont) | Font handle. |
| `char` | string | A single-character string. |
| `scale?` | number | Scale factor (default 1.0). |

**Returns**

| Type | Description |
|------|-------------|
| number | Horizontal advance width in pixels. |

**Example**

```lua
do
    local function font_log(message)
        lurek.log.info("[font.example] " .. tostring(message))
    end
    local function ui_title()
        return "Province Ledger"
    end
    local function ui_briefing()
        return "Northern provinces need supply wagons before winter roads close."
    end
    local function sample_font_path()
        return "content/examples/assets/fonts/sample_font.ttf"
    end

    local font = lurek.font.getDefault()
    local advance_w = lurek.font.charAdvance(font, "W", 1.0)
    local advance_space = lurek.font.charAdvance(font, " ", 1.0)
    local cursor_after = advance_w + advance_space + advance_w
    local initials = "W W"
    font_log("nameplate cursor advance text=" .. initials .. " first=" .. tostring(advance_w) .. " space=" .. tostring(advance_space) .. " cursor_after=" .. tostring(cursor_after))
end
```

---

### `lurek.font.getDefault`

Returns the default engine font as an [LFont](#lfont) userdata handle.

```lua
lurek.font.getDefault()
```

**Returns**

| Type | Description |
|------|-------------|
| [LFont](#lfont) | The default engine font handle. |

**Example**

```lua
do
    local function font_log(message)
        lurek.log.info("[font.example] " .. tostring(message))
    end
    local function ui_title()
        return "Province Ledger"
    end
    local function ui_briefing()
        return "Northern provinces need supply wagons before winter roads close."
    end
    local function sample_font_path()
        return "content/examples/assets/fonts/sample_font.ttf"
    end

    local font = lurek.font.getDefault()
    local name = font:getName()
    local size = font:getSize()
    local line_height = font:lineHeight()
    local title_width = select(1, font:measure(ui_title(), 1.0))
    font_log("default ui font name=" .. tostring(name) .. " size=" .. tostring(size) .. " line_height=" .. tostring(line_height) .. " title_width=" .. tostring(title_width))
end
```

---

### `lurek.font.lineHeight`

Returns the line height of the given font in pixels.

```lua
lurek.font.lineHeight(font)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `font` | [LFont](#lfont) | Font handle to query. |

**Returns**

| Type | Description |
|------|-------------|
| number | Line height in pixels. |

**Example**

```lua
do
    local function font_log(message)
        lurek.log.info("[font.example] " .. tostring(message))
    end
    local function ui_title()
        return "Province Ledger"
    end
    local function ui_briefing()
        return "Northern provinces need supply wagons before winter roads close."
    end
    local function sample_font_path()
        return "content/examples/assets/fonts/sample_font.ttf"
    end

    local font = lurek.font.getDefault()
    local line_height = lurek.font.lineHeight(font)
    local visible_rows = math.floor(160 / math.max(line_height, 1))
    local title_height = select(2, lurek.font.measure(font, ui_title(), 1.0))
    local spacing_budget = visible_rows * line_height
    font_log("quest log spacing line_height=" .. tostring(line_height) .. " rows_in_160px=" .. tostring(visible_rows) .. " title_height=" .. tostring(title_height) .. " budget=" .. tostring(spacing_budget))
end
```

---

### `lurek.font.list`

Lists all registered fonts with their name, size, and style metadata.

```lua
lurek.font.list()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Array of tables with fields: name (string), size (number), style (string). |

**Example**

```lua
do
    local function font_log(message)
        lurek.log.info("[font.example] " .. tostring(message))
    end
    local function ui_title()
        return "Province Ledger"
    end
    local function ui_briefing()
        return "Northern provinces need supply wagons before winter roads close."
    end
    local function sample_font_path()
        return "content/examples/assets/fonts/sample_font.ttf"
    end

    local before = lurek.font.list()
    local runtime_font = lurek.font.load(sample_font_path(), 16)
    local after = lurek.font.list()
    local first = after[1] or {}
    local grew = #after > #before
    font_log("font catalog refresh count_before=" .. tostring(#before) .. " count_after=" .. tostring(#after) .. " grew=" .. tostring(grew) .. " first_name=" .. tostring(first.name or runtime_font:getName()))
end
```

---

### `lurek.font.load`

Loads a TTF/OTF/PNG font file at the given point size and returns an [LFont](#lfont) handle.

```lua
lurek.font.load(path, size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | Relative path to the font file. |
| `size` | number | Point size for rasterisation. |

**Returns**

| Type | Description |
|------|-------------|
| [LFont](#lfont) | The loaded font handle. |

**Example**

```lua
do
    local function font_log(message)
        lurek.log.info("[font.example] " .. tostring(message))
    end
    local function ui_title()
        return "Province Ledger"
    end
    local function ui_briefing()
        return "Northern provinces need supply wagons before winter roads close."
    end
    local function sample_font_path()
        return "content/examples/assets/fonts/sample_font.ttf"
    end

    local font = lurek.font.load(sample_font_path(), 14)
    local name = font:getName()
    local style = font:getStyle()
    local preview_width = select(1, font:measure("Campaign report", 1.0))
    local preview_height = select(2, font:measure("Campaign report", 1.0))
    font_log("loaded ttf for codex preview name=" .. tostring(name) .. " style=" .. tostring(style) .. " preview=" .. tostring(preview_width) .. "x" .. tostring(preview_height))
end
```

---

### `lurek.font.loadBitmap`

Loads a bitmap font atlas PNG with the given cell dimensions and returns an [LFont](#lfont) handle.

```lua
lurek.font.loadBitmap(path, cellWidth, cellHeight)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | Relative path to the PNG atlas. |
| `cellWidth` | number | Cell width in pixels. |
| `cellHeight` | number | Cell height in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| [LFont](#lfont) | The loaded bitmap font handle. |

**Example**

```lua
do
    local function font_log(message)
        lurek.log.info("[font.example] " .. tostring(message))
    end
    local function ui_title()
        return "Province Ledger"
    end
    local function ui_briefing()
        return "Northern provinces need supply wagons before winter roads close."
    end
    local function sample_font_path()
        return "content/examples/assets/fonts/sample_font.ttf"
    end

    local atlas_path = "content/examples/assets/fonts/missing_bitmap_font.png"
    local cell_width = 8
    local cell_height = 8
    local ok, result = pcall(lurek.font.loadBitmap, atlas_path, cell_width, cell_height)
    local reason = ok and "loaded" or tostring(result)
    font_log("bitmap atlas import for retro hud path=" .. atlas_path .. " cell=" .. tostring(cell_width) .. "x" .. tostring(cell_height) .. " ok=" .. tostring(ok) .. " result=" .. reason)
end
```

---

### `lurek.font.measure`

Measures the pixel dimensions of a text string using the given font handle and scale.

```lua
lurek.font.measure(font, text, scale)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `font` | [LFont](#lfont) | Font handle to measure with. |
| `text` | string | Text string to measure. |
| `scale?` | number | Scale factor (default 1.0). |

**Returns**

| Type | Description |
|------|-------------|
| number | Width in pixels (height returned as second value). |

**Example**

```lua
do
    local function font_log(message)
        lurek.log.info("[font.example] " .. tostring(message))
    end
    local function ui_title()
        return "Province Ledger"
    end
    local function ui_briefing()
        return "Northern provinces need supply wagons before winter roads close."
    end
    local function sample_font_path()
        return "content/examples/assets/fonts/sample_font.ttf"
    end

    local font = lurek.font.getDefault()
    local title = ui_title()
    local width, height = lurek.font.measure(font, title, 1.0)
    local scale = 1.5
    local scaled_width = select(1, lurek.font.measure(font, title, scale))
    font_log("panel title measurement text=" .. title .. " width=" .. tostring(width) .. " height=" .. tostring(height) .. " scaled_width=" .. tostring(scaled_width))
end
```

---

### `lurek.font.measureLine`

Measures the pixel width and height of a single line of text with the given font.

```lua
lurek.font.measureLine(font, text, scale)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `font` | [LFont](#lfont) | Font handle to measure with. |
| `text` | string | Single-line text string to measure. |
| `scale?` | number | Scale factor (default 1.0). |

**Returns**

| Type | Description |
|------|-------------|
| number | Width in pixels (height returned as second value). |

**Example**

```lua
do
    local function font_log(message)
        lurek.log.info("[font.example] " .. tostring(message))
    end
    local function ui_title()
        return "Province Ledger"
    end
    local function ui_briefing()
        return "Northern provinces need supply wagons before winter roads close."
    end
    local function sample_font_path()
        return "content/examples/assets/fonts/sample_font.ttf"
    end

    local font = lurek.font.getDefault()
    local status_line = "Supply 120  Morale 78%"
    local width, height = lurek.font.measureLine(font, status_line, 1.0)
    local per_char = width / math.max(#status_line, 1)
    local line_height = lurek.font.lineHeight(font)
    font_log("status bar line text_width=" .. tostring(width) .. " height=" .. tostring(height) .. " avg_char=" .. tostring(per_char) .. " line_height=" .. tostring(line_height))
end
```

---

### `lurek.font.shapeText`

Shapes and aligns text into wrapped lines with x-offset data for rendering.

```lua
lurek.font.shapeText(font, text, maxWidth, scale, align, wrap)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `font` | [LFont](#lfont) | Font handle used for shaping. |
| `text` | string | Text to shape. |
| `maxWidth` | number | Maximum line width in pixels. |
| `scale` | number | Scale factor (default 1.0). |
| `align` | string | Alignment: "left", "center", "right", or "justify". |
| `wrap` | string | Wrap mode: "none", "word", or "char". |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of tables with fields: text (string), width (number), xOffset (number). |

**Example**

```lua
do
    local function font_log(message)
        lurek.log.info("[font.example] " .. tostring(message))
    end
    local function ui_title()
        return "Province Ledger"
    end
    local function ui_briefing()
        return "Northern provinces need supply wagons before winter roads close."
    end
    local function sample_font_path()
        return "content/examples/assets/fonts/sample_font.ttf"
    end

    local font = lurek.font.getDefault()
    local banner = "Victory Forecast"
    local shaped = lurek.font.shapeText(font, banner, 180, 1.0, "center", "word")
    local first = shaped[1] or {}
    local offset = first.xOffset or 0
    local width = first.width or 0
    font_log("dialog banner shaping lines=" .. tostring(#shaped) .. " first_width=" .. tostring(width) .. " center_offset=" .. tostring(offset))
end
```

---

### `lurek.font.wrapText`

Wraps a text string into lines that fit within the given maximum pixel width.

```lua
lurek.font.wrapText(font, text, maxWidth, scale, mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `font` | [LFont](#lfont) | Font handle used for measurement. |
| `text` | string | Text to wrap. |
| `maxWidth` | number | Maximum line width in pixels. |
| `scale` | number | Scale factor (default 1.0). |
| `mode` | string | Wrap mode: "none", "word", or "char". |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of wrapped line strings. |

**Example**

```lua
do
    local function font_log(message)
        lurek.log.info("[font.example] " .. tostring(message))
    end
    local function ui_title()
        return "Province Ledger"
    end
    local function ui_briefing()
        return "Northern provinces need supply wagons before winter roads close."
    end
    local function sample_font_path()
        return "content/examples/assets/fonts/sample_font.ttf"
    end

    local font = lurek.font.getDefault()
    local briefing = ui_briefing()
    local max_width = 120
    local lines = lurek.font.wrapText(font, briefing, max_width, 1.0, "word")
    local first_line = lines[1] or ""
    font_log("briefing wrap width=" .. tostring(max_width) .. " lines=" .. tostring(#lines) .. " first_line=" .. tostring(first_line))
end
```

---

## Module Fields

*No module-level fields documented.*

## Enums

*No module-specific enums documented.*

## Types

- [LFont](#lfont)

## LFont

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LFont:containsGlyph`

Returns whether the font contains a glyph for the given character. This method is available to Lua scripts.

```lua
LFont:containsGlyph(char)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `char` | string | A single-character string to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the font has a glyph for this character. |

**Example**

```lua
do
    local function font_log(message)
        lurek.log.info("[font.example] " .. tostring(message))
    end
    local function ui_title()
        return "Province Ledger"
    end
    local function ui_briefing()
        return "Northern provinces need supply wagons before winter roads close."
    end
    local function sample_font_path()
        return "content/examples/assets/fonts/sample_font.ttf"
    end

    local font = lurek.font.load(sample_font_path(), 18)
    local has_r = font:containsGlyph("R")
    local has_dash = font:containsGlyph("-")
    local has_control = font:containsGlyph(string.char(1))
    local name = font:getName()
    font_log("loaded handle glyph scan name=" .. tostring(name) .. " R=" .. tostring(has_r) .. " dash=" .. tostring(has_dash) .. " control=" .. tostring(has_control))
end
```

---

#### `LFont:getAscent`

Returns the ascent (pixels above the baseline) of this font.

```lua
LFont:getAscent()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Ascent in pixels. |

---

#### `LFont:getDescent`

Returns the descent (pixels below the baseline) of this font.

```lua
LFont:getDescent()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Descent in pixels (positive value extending downward). |

---

#### `LFont:getHeight`

Returns the line height of this font in pixels.

```lua
LFont:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Line height in pixels. |

---

#### `LFont:getLineHeight`

Returns the spacing between consecutive lines of text.

```lua
LFont:getLineHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Line height in pixels. |

---

#### `LFont:getName`

Returns the human-readable name of this font. This method is available to Lua scripts.

```lua
LFont:getName()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Font name. |

**Example**

```lua
do
    local function font_log(message)
        lurek.log.info("[font.example] " .. tostring(message))
    end
    local function ui_title()
        return "Province Ledger"
    end
    local function ui_briefing()
        return "Northern provinces need supply wagons before winter roads close."
    end
    local function sample_font_path()
        return "content/examples/assets/fonts/sample_font.ttf"
    end

    local font = lurek.font.load(sample_font_path(), 18)
    local name = font:getName()
    local size = font:getSize()
    local preview = select(1, font:measure("Council", 1.0))
    local summary = name .. "@" .. tostring(size)
    font_log("loaded handle name=" .. tostring(name) .. " size=" .. tostring(size) .. " preview_width=" .. tostring(preview) .. " summary=" .. summary)
end
```

---

#### `LFont:getSize`

Returns the point size of this font. This method is available to Lua scripts.

```lua
LFont:getSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Point size. |

**Example**

```lua
do
    local function font_log(message)
        lurek.log.info("[font.example] " .. tostring(message))
    end
    local function ui_title()
        return "Province Ledger"
    end
    local function ui_briefing()
        return "Northern provinces need supply wagons before winter roads close."
    end
    local function sample_font_path()
        return "content/examples/assets/fonts/sample_font.ttf"
    end

    local font = lurek.font.load(sample_font_path(), 18)
    local size = font:getSize()
    local line_height = font:lineHeight()
    local style = font:getStyle()
    local rows = math.floor(220 / math.max(line_height, 1))
    font_log("loaded handle size=" .. tostring(size) .. " style=" .. tostring(style) .. " line_height=" .. tostring(line_height) .. " rows_in_220px=" .. tostring(rows))
end
```

---

#### `LFont:getStyle`

Returns the style string of this font. This method is available to Lua scripts.

```lua
LFont:getStyle()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Style name ("regular", "bold"). |

**Example**

```lua
do
    local function font_log(message)
        lurek.log.info("[font.example] " .. tostring(message))
    end
    local function ui_title()
        return "Province Ledger"
    end
    local function ui_briefing()
        return "Northern provinces need supply wagons before winter roads close."
    end
    local function sample_font_path()
        return "content/examples/assets/fonts/sample_font.ttf"
    end

    local font = lurek.font.load(sample_font_path(), 18)
    local style = font:getStyle()
    local bold = font:isBold()
    local title_width = select(1, font:measure("Operations", 1.0))
    local usage = bold and "headline" or "body"
    font_log("loaded handle style=" .. tostring(style) .. " bold=" .. tostring(bold) .. " title_width=" .. tostring(title_width) .. " usage=" .. usage)
end
```

---

#### `LFont:getWidth`

Measures the pixel width of a string when rendered with this font.

```lua
LFont:getWidth(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | string | The text to measure. |

**Returns**

| Type | Description |
|------|-------------|
| number | Width in pixels. |

---

#### `LFont:getWrap`

Word-wraps text to fit within a pixel width limit and returns the resulting lines.

```lua
LFont:getWrap(text, limit)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | string | The text to wrap. |
| `limit` | number | Maximum line width in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of wrapped line strings; and the widest line width. (value 1). |
| number | Array of wrapped line strings; and the widest line width. (value 2). |

---

#### `LFont:isBold`

Returns whether this font is the bold variant. This method is available to Lua scripts.

```lua
LFont:isBold()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if font style is bold. |

**Example**

```lua
do
    local function font_log(message)
        lurek.log.info("[font.example] " .. tostring(message))
    end
    local function ui_title()
        return "Province Ledger"
    end
    local function ui_briefing()
        return "Northern provinces need supply wagons before winter roads close."
    end
    local function sample_font_path()
        return "content/examples/assets/fonts/sample_font.ttf"
    end

    local font = lurek.font.load(sample_font_path(), 18)
    local bold = font:isBold()
    local style = font:getStyle()
    local emphasis = bold and "warning_banner" or "ledger_body"
    local glyph_ok = font:containsGlyph("W")
    font_log("loaded handle bold=" .. tostring(bold) .. " style=" .. tostring(style) .. " emphasis=" .. emphasis .. " glyph_W=" .. tostring(glyph_ok))
end
```

---

#### `LFont:lineHeight`

Returns the line height of this font in pixels. This method is available to Lua scripts.

```lua
LFont:lineHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Line height in pixels. |

**Example**

```lua
do
    local function font_log(message)
        lurek.log.info("[font.example] " .. tostring(message))
    end
    local function ui_title()
        return "Province Ledger"
    end
    local function ui_briefing()
        return "Northern provinces need supply wagons before winter roads close."
    end
    local function sample_font_path()
        return "content/examples/assets/fonts/sample_font.ttf"
    end

    local font = lurek.font.load(sample_font_path(), 18)
    local line_height = font:lineHeight()
    local paragraph = font:wrapText(ui_briefing(), 160, 1.0)
    local paragraph_height = #paragraph * line_height
    local visible_rows = math.floor(240 / math.max(line_height, 1))
    font_log("loaded handle line height=" .. tostring(line_height) .. " paragraph_lines=" .. tostring(#paragraph) .. " paragraph_height=" .. tostring(paragraph_height) .. " rows_in_240px=" .. tostring(visible_rows))
end
```

---

#### `LFont:measure`

Measures the pixel dimensions of a text string at the given scale. This method is available to Lua scripts.

```lua
LFont:measure(text, scale)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | string | Text to measure. |
| `scale?` | number | Scale factor applied to dimensions. |

**Returns**

| Type | Description |
|------|-------------|
| number | Width and height in pixels. (value 1). |
| number | Width and height in pixels. (value 2). |

**Example**

```lua
do
    local function font_log(message)
        lurek.log.info("[font.example] " .. tostring(message))
    end
    local function ui_title()
        return "Province Ledger"
    end
    local function ui_briefing()
        return "Northern provinces need supply wagons before winter roads close."
    end
    local function sample_font_path()
        return "content/examples/assets/fonts/sample_font.ttf"
    end

    local font = lurek.font.load(sample_font_path(), 18)
    local label = "Treasury Update"
    local width, height = font:measure(label, 1.0)
    local scaled_width = select(1, font:measure(label, 0.75))
    local shorter = scaled_width < width
    font_log("loaded handle measure label=" .. label .. " width=" .. tostring(width) .. " height=" .. tostring(height) .. " scaled_width=" .. tostring(scaled_width) .. " scaled_shorter=" .. tostring(shorter))
end
```

---

#### `LFont:release`

Releases the font resource. The handle becomes invalid after this call.

```lua
LFont:release()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the font was still valid and was released. |

---

#### `LFont:setLineHeight`

Overrides the line height used for multi-line text rendering.

```lua
LFont:setLineHeight(height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `height` | number | New line height in pixels. |

---

#### `LFont:type`

Returns the type name string for this font object.

```lua
LFont:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always "[LFont](#lfont)". |

---

#### `LFont:typeOf`

Checks whether this object matches the given type name.

```lua
LFont:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check ("Font" or "Object"). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the name matches. |

---

#### `LFont:wrapText`

Wraps text into lines fitting within the given max width. This method is available to Lua scripts.

```lua
LFont:wrapText(text, maxWidth, scale)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | string | Text to wrap. |
| `maxWidth` | number | Maximum line width in pixels. |
| `scale?` | number | Scale factor. |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of wrapped line strings. |

**Example**

```lua
do
    local function font_log(message)
        lurek.log.info("[font.example] " .. tostring(message))
    end
    local function ui_title()
        return "Province Ledger"
    end
    local function ui_briefing()
        return "Northern provinces need supply wagons before winter roads close."
    end
    local function sample_font_path()
        return "content/examples/assets/fonts/sample_font.ttf"
    end

    local font = lurek.font.load(sample_font_path(), 18)
    local width = 150
    local lines = font:wrapText("Reinforcements arrive tomorrow if the northern road stays open.", width, 1.0)
    local first = lines[1] or ""
    local last = lines[#lines] or ""
    font_log("loaded handle wrap width=" .. tostring(width) .. " lines=" .. tostring(#lines) .. " first=" .. tostring(first) .. " last=" .. tostring(last))
end
```

---
