# Render

- The `render` module is a core Platform Services tier subsystem that powers the entire visual output of Lurek2D.

Backed by `wgpu 22`, it utilizes a deferred `RenderCommand` queue architecture. Rather than executing GPU commands immediately during game logic, Lua scripts emit draw commands (for rectangles, circles, lines, polygons, text, textures, and meshes) into a frame-local buffer. At the end of the frame, the `GpuRenderer` sorts these commands by z-order using the `DrawLayer` system, batches compatible operations to minimize state changes, and encodes highly optimized wgpu render passes. This deferred approach ensures that no heavy GPU work stalls the Lua execution thread.

The module supports an extensive array of rendering primitives and techniques. It handles both flat-color and textured geometry, advanced compositing via blend modes and stencil write/test operations, and complex nested draw layers. The `Font` system provides built-in Courier New bitmap atlases alongside dynamic TTF/OTF rasterization (via `fontdue`), complete with rich-text styling, word wrapping, and alignment controls. For 3D workflows, the `ObjLoader` seamlessly parses Wavefront OBJ models and MTL materials, projecting them into 2D `Mesh` geometry with back-face culling and Z-buffering. Rendering can target the main window swapchain or off-screen `Canvas` textures, which are essential for layered compositing and UI workflows.

A standout feature of the `render` module is its robust `PostFxPipeline`. This full-screen post-processing system supports over 20 built-in WGSL fragment shaders (including bloom, blur, vignette, CRT scanlines, chromatic aberration, pixelation, and depth-of-field). Developers can effortlessly chain these effects using cached ping-pong intermediate textures and even compile and register custom WGSL shaders at runtime via the `Shader` manager, with automatic uniform injection for time and resolution. All GPU resource lifecycles—textures, geometry buffers, and pipelines—are managed automatically and garbage-collected by the engine. The comprehensive `lurek.render.*` Lua API gives script developers complete control over this high-performance rendering pipeline, from simple shapes to complex post-processing stacks.

## Functions

### `lurek.render.applyTransform`

Multiplies the current transformation matrix by a 3x3 matrix (9 values in row-major order).

```lua
-- signature
lurek.render.applyTransform(mat)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mat` | `table` | Flat table of 9 numbers representing a 3x3 transform matrix. |

**Example**

```lua
do
    local matrix = { 1, 0, 0, 0, 1, 0, 60, 120, 1 }
    lurek.render.push()
    lurek.render.applyTransform(matrix)
    lurek.render.rectangle("fill", 0, 0, 36, 36)
    lurek.render.pop()
    print("applyTransform matrix entries = " .. #matrix)
    print("flat 3x3 matrix applied")
end
```

---

### `lurek.render.arc`

Draws a filled or outlined circular arc segment.

```lua
-- signature
lurek.render.arc(mode, x, y, radius, angle1, angle2, segments)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | `string` | "fill" or "line". |
| `x` | `number` | Center X. |
| `y` | `number` | Center Y. |
| `radius` | `number` | Arc radius. |
| `angle1` | `number` | Start angle in radians. |
| `angle2` | `number` | End angle in radians. |
| `segments?` | `number` | Number of arc segments (default 32). |

**Example**

```lua
do
    lurek.render.setColor(1, 0.8, 0.1, 1)
    lurek.render.arc("fill", 360, 250, 36, 0, math.pi)
    lurek.render.setColor(0.2, 0.9, 0.4, 1)
    lurek.render.arc("line", 450, 250, 36, math.pi, math.pi * 1.75, 20)
    lurek.render.setColor(1, 1, 1, 1)
    print("arc segments = 20 on line arc")
    print("arc examples drawn")
end
```

---

### `lurek.render.beginSortGroup`

Begins a depth-sorted rendering group. Draw calls within this group are sorted by pushSortKey values.

```lua
-- signature
lurek.render.beginSortGroup(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Group identifier. |

**Example**

```lua
do
    lurek.render.beginSortGroup(1)
    lurek.render.pushSortKey(10)
    lurek.render.rectangle("fill", 400, 140, 30, 30)
    lurek.render.pushSortKey(5)
    lurek.render.rectangle("fill", 410, 150, 30, 30)
    lurek.render.flushSortGroup(1)
    print("sort group id = 1")
    print("sort keys 10 and 5 queued")
end
```

---

### `lurek.render.captureScreenshot`

Captures a screenshot as ImageData and passes it to a callback (stub: returns 1x1 placeholder).

```lua
-- signature
lurek.render.captureScreenshot(callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `callback` | `function` | Called with an LImageData argument. |

**Example**

```lua
do
    lurek.render.captureScreenshot(function(data)
        print("captureScreenshot size = " .. data:getWidth() .. "x" .. data:getHeight())
    end)
    lurek.render.saveScreenshot("save/render_capture.png")
    print("captureScreenshot callback invoked")
    print("saveScreenshot requested")
end
```

---

### `lurek.render.circle`

Draws a filled or outlined circle at the given position.

```lua
-- signature
lurek.render.circle(mode, x, y, radius)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | `string` | "fill" or "line". |
| `x` | `number` | Center X. |
| `y` | `number` | Center Y. |
| `radius` | `number` | Circle radius in pixels. |

**Example**

```lua
do
    lurek.render.setColor(1, 0.6, 0.1, 1)
    lurek.render.circle("fill", 340, 180, 30)
    lurek.render.setColor(0.2, 0.9, 1, 1)
    lurek.render.circle("line", 410, 180, 30)
    lurek.render.setColor(1, 1, 1, 1)
    print("circle radius = 30")
    print("circle fill and line drawn")
end
```

---

### `lurek.render.clear`

Clears all queued render commands for the current frame.

```lua
-- signature
lurek.render.clear(r, g, b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r?` | `number` | Unused (reserved for future clear-color override). |
| `g?` | `number` | Unused. |
| `b?` | `number` | Unused. |

**Example**

```lua
do
    lurek.render.rectangle("fill", 0, 0, 10, 10)
    lurek.render.clear()
    print("render command queue cleared")
    print("clear called after a draw")
end
```

---

### `lurek.render.clearStencil`

Resets the stencil state to defaults (no stencil operations).

```lua
-- signature
lurek.render.clearStencil()
```

**Example**

```lua
do
    lurek.render.setStencilMode("replace", "always", 2)
    lurek.render.clearStencil()
    local action, compare, value = lurek.render.getStencilMode()
    print("stencil mode after clear = " .. action .. "," .. compare .. "," .. value)
end
```

---

### `lurek.render.currentLayer`

Returns the name of the currently active rendering layer.

```lua
-- signature
lurek.render.currentLayer()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Active layer name. |

**Example**

```lua
do
    lurek.render.newLayer("current_layer_stub", 12)
    lurek.render.setLayer("current_layer_stub")
    print("current layer = " .. lurek.render.currentLayer())
    lurek.render.setLayer("default")
end
```

---

### `lurek.render.draw`

Draws a drawable object (Image, Canvas, SpriteBatch, or Mesh) at the given position with optional transform.

```lua
-- signature
lurek.render.draw(drawable, x, y, r, sx, sy, ox, oy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `drawable` | `LImage|LCanvas|LSpriteBatch|LMesh` | The drawable object to render. |
| `x?` | `number` | X position (default 0). |
| `y?` | `number` | Y position (default 0). |
| `r?` | `number` | Rotation in radians (default 0). |
| `sx?` | `number` | Scale X (default 1). |
| `sy?` | `number` | Scale Y (default 1). |
| `ox?` | `number` | Origin offset X (default 0). |
| `oy?` | `number` | Origin offset Y (default 0). |

**Returns**

| Type | Description |
|------|-------------|
| `nil` | No return value. |

**Example**

```lua
do
    local canvas = lurek.render.newCanvas(96, 96)
    lurek.render.setCanvas(canvas)
    lurek.render.rectangle("fill", 0, 0, 96, 96)
    lurek.render.setCanvas(nil)
    lurek.render.draw(canvas, 280, 430, 0, 0.75, 0.75)
    print("draw used a canvas handle")
    print("draw scale = 0.75")
end
```

---

### `lurek.render.drawBatch`

Draws a SpriteBatch using the same queued DrawBatch command as lurek.render.draw(batch).

```lua
-- signature
lurek.render.drawBatch(batch)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `batch` | `LSpriteBatch` | Sprite batch handle to draw. |

**Returns**

| Type | Description |
|------|-------------|
| `nil` | No return value. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local batch = lurek.render.newSpriteBatch(image, 8)
    batch:add(120, 220, 0, 0.5, 0.5, 0, 0)
    lurek.render.drawBatch(batch)
    print("drawBatch sprite count = " .. batch:getCount())
    print("drawBatch issued")
end
```

---

### `lurek.render.drawBevelRect`

Draws a beveled rectangle with highlight, shadow, and fill colors for 3D-style UI elements.

```lua
-- signature
lurek.render.drawBevelRect(x, y, w, h, bevelW, style, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | Left edge X. |
| `y` | `number` | Top edge Y. |
| `w` | `number` | Width (must be positive). |
| `h` | `number` | Height (must be positive). |
| `bevelW?` | `number` | Bevel border width (default 2). |
| `style?` | `string` | Bevel style: "raised" (default), "sunken", "ridge", "groove", "flat". |
| `opts?` | `table` | Options: highlight, shadow, fillColor (each a {r,g,b,a} table). |

**Example**

```lua
do
    lurek.render.drawBevelRect(10, 560, 90, 32, 3, "raised")
    lurek.render.drawBevelRect(120, 560, 90, 32, 3, "sunken")
    lurek.render.drawBevelRect(230, 560, 90, 32, 2, "flat", {
        fillColor = { 0.2, 0.3, 0.8, 1 },
        highlight = { 1, 1, 1, 1 },
        shadow = { 0.2, 0.2, 0.3, 1 },
    })
    print("bevel styles = raised, sunken, flat")
    print("bevel rectangles drawn")
end
```

---

### `lurek.render.drawColoredPolygon`

Draws a polygon with per-vertex colors.

```lua
-- signature
lurek.render.drawColoredPolygon(vertices, colors, mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `vertices` | `table` | Flat array of x,y coordinates: {x1, y1, x2, y2, ...}. |
| `colors` | `table` | Array of color tables: {{r, g, b, a}, ...}, one per vertex. |
| `mode?` | `string` | "fill" (default) or "line". |

**Example**

```lua
do
    local vertices = { 320, 500, 380, 500, 400, 540, 300, 540 }
    local colors = {
        { 1, 0, 0, 1 },
        { 0, 1, 0, 1 },
        { 0, 0, 1, 1 },
        { 1, 1, 0, 1 },
    }
    lurek.render.drawColoredPolygon(vertices, colors, "fill")
    print("colored polygon vertices = 4")
    print("colored polygon drawn")
end
```

---

### `lurek.render.drawCubicBezier`

Draws a cubic Bezier curve through start, two control points, and end.

```lua
-- signature
lurek.render.drawCubicBezier(x1, y1, cx1, cy1, cx2, cy2, x2, y2, segs)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x1` | `number` | Start X. |
| `y1` | `number` | Start Y. |
| `cx1` | `number` | First control point X. |
| `cy1` | `number` | First control point Y. |
| `cx2` | `number` | Second control point X. |
| `cy2` | `number` | Second control point Y. |
| `x2` | `number` | End X. |
| `y2` | `number` | End Y. |
| `segs?` | `number` | Number of line segments (default 16). |

**Example**

```lua
do
    lurek.render.setColor(1, 0.5, 0.1, 1)
    lurek.render.drawCubicBezier(20, 440, 60, 390, 120, 490, 160, 440, 24)
    lurek.render.setColor(1, 1, 1, 1)
    print("cubic bezier segments = 24")
    print("cubic bezier drawn")
end
```

---

### `lurek.render.drawGradientRect`

Draws a rectangle with a two-color gradient fill.

```lua
-- signature
lurek.render.drawGradientRect(x, y, w, h, c1, c2, dir)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | Left edge X. |
| `y` | `number` | Top edge Y. |
| `w` | `number` | Width (must be positive). |
| `h` | `number` | Height (must be positive). |
| `c1` | `table` | Start color {r, g, b [, a]}. |
| `c2` | `table` | End color {r, g, b [, a]}. |
| `dir?` | `string` | Direction: "vertical" (default), "horizontal", "diagDown", "diagUp", "radial". |

**Example**

```lua
do
    lurek.render.drawGradientRect(10, 500, 120, 36, { 1, 0, 0, 1 }, { 0, 0, 1, 1 }, "horizontal")
    lurek.render.drawGradientRect(150, 500, 120, 36, { 0, 1, 0, 1 }, { 1, 1, 0, 1 }, "vertical")
    print("gradient directions = horizontal, vertical")
    print("gradient rectangles drawn")
end
```

---

### `lurek.render.drawHexTile`

Draws a regular hexagonal tile at the given center position.

```lua
-- signature
lurek.render.drawHexTile(cx, cy, size, orientation, mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cx` | `number` | Center X. |
| `cy` | `number` | Center Y. |
| `size` | `number` | Hex radius (must be positive). |
| `orientation?` | `string` | "pointyTop" (default) or "flatTop". |
| `mode?` | `string` | "line" (default) or "fill". |

**Example**

```lua
do
    lurek.render.setColor(0.1, 0.7, 0.5, 1)
    lurek.render.drawHexTile(480, 520, 24, "pointyTop", "fill")
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.drawHexTile(550, 520, 24, "flatTop", "line")
    print("hex tile orientations = pointyTop, flatTop")
    print("hex tiles drawn")
end
```

---

### `lurek.render.drawIsoCubeTile`

Draws an isometric cube tile with configurable face colors and optional textures.

```lua
-- signature
lurek.render.drawIsoCubeTile(sx, sy, halfW, halfH, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sx` | `number` | Screen X position of the tile center. |
| `sy` | `number` | Screen Y position of the tile center. |
| `halfW` | `number` | Half-width of the tile diamond. |
| `halfH` | `number` | Half-height of the tile diamond. |
| `opts?` | `table` | Options: depth, topColor, leftColor, rightColor, topTexture, leftTexture, rightTexture. |

**Example**

```lua
do
    lurek.render.drawIsoCubeTile(300, 330, 28, 14, {
        depth = 18,
        topColor = { 0.8, 0.8, 0.9, 1 },
        leftColor = { 0.5, 0.5, 0.6, 1 },
        rightColor = { 0.3, 0.3, 0.4, 1 },
    })
    print("iso cube tile depth = 18")
    print("iso cube tile drawn")
end
```

---

### `lurek.render.drawMany`

Batch-draws multiple images in one call. Each entry is a table: {image, x, y, r, sx, sy, ox, oy}.

```lua
-- signature
lurek.render.drawMany(list)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `list` | `table` | Array of draw entry tables. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local list = {
        { image, 10, 270, 0, 0.3, 0.3, 0, 0 },
        { image, 40, 270, math.pi / 8, 0.3, 0.3, 0, 0 },
        { image, 70, 270, math.pi / 4, 0.3, 0.3, 0, 0 },
    }
    lurek.render.drawMany(list)
    print("drawMany entries = " .. #list)
    print("drawMany issued")
end
```

---

### `lurek.render.drawNineSlice`

Draws a 9-slice image stretched to fill the given rectangle, keeping borders unscaled.

```lua
-- signature
lurek.render.drawNineSlice(slice, x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `slice` | `LNineSlice` | The 9-slice handle to draw. |
| `x` | `number` | Left edge X. |
| `y` | `number` | Top edge Y. |
| `w` | `number` | Target width. |
| `h` | `number` | Target height. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local slice = lurek.render.newNineSlice(image, 4, 4, 4, 4)
    lurek.render.drawNineSlice(slice, 100, 100, 80, 60)
    print("drawNineSlice target size = 80x60")
    image:release()
end
```

---

### `lurek.render.drawPath`

Draws a vector path composed of moveTo, lineTo, quadTo, and cubicTo segments.

```lua
-- signature
lurek.render.drawPath(path, mode, close)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `table` | Array of segment tables, each with a "type" field and coordinates. |
| `mode?` | `string` | "line" (default) or "fill". |
| `close?` | `boolean` | Close the path back to start (default false). |

**Example**

```lua
do
    local path = {
        { type = "moveTo", x = 380, y = 430 },
        { type = "lineTo", x = 430, y = 410 },
        { type = "quadTo", cx = 470, cy = 390, x = 500, y = 430 },
        { type = "cubicTo", cx1 = 500, cy1 = 470, cx2 = 420, cy2 = 470, x = 380, y = 450 },
    }
    lurek.render.setColor(0.6, 0.2, 1, 1)
    lurek.render.drawPath(path, "line", true)
    lurek.render.setColor(1, 1, 1, 1)
    print("path segments = " .. #path)
    print("path closed = true")
end
```

---

### `lurek.render.drawQuadBezier`

Draws a quadratic Bezier curve through start, control, and end points.

```lua
-- signature
lurek.render.drawQuadBezier(x1, y1, cx, cy, x2, y2, segs)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x1` | `number` | Start X. |
| `y1` | `number` | Start Y. |
| `cx` | `number` | Control point X. |
| `cy` | `number` | Control point Y. |
| `x2` | `number` | End X. |
| `y2` | `number` | End Y. |
| `segs?` | `number` | Number of line segments (default 16). |

**Example**

```lua
do
    lurek.render.setColor(0.1, 1, 0.5, 1)
    lurek.render.drawQuadBezier(210, 440, 270, 390, 330, 440, 18)
    lurek.render.setColor(1, 1, 1, 1)
    print("quad bezier segments = 18")
    print("quad bezier drawn")
end
```

---

### `lurek.render.drawq`

Draws a sub-region of an image defined by a Quad, with optional transform.

```lua
-- signature
lurek.render.drawq(image, quad, x, y, r, sx, sy, ox, oy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `image` | `LImage` | Source image to draw from. |
| `quad` | `LQuad` | Quad defining the source rectangle within the image. |
| `x?` | `number` | X position (default 0). |
| `y?` | `number` | Y position (default 0). |
| `r?` | `number` | Rotation in radians (default 0). |
| `sx?` | `number` | Scale X (default 1). |
| `sy?` | `number` | Scale Y (default 1). |
| `ox?` | `number` | Origin offset X (default 0). |
| `oy?` | `number` | Origin offset Y (default 0). |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local quad = lurek.render.newQuad(0, 0, 16, 16, 64, 64)
    lurek.render.draw(image, 10, 10, 0, 1, 1)
    lurek.render.drawq(image, quad, 50, 50, 0, 1, 1)
    print("drawq used a 16x16 quad")
    image:release()
end
```

---

### `lurek.render.ellipse`

Draws a filled or outlined ellipse at the given position.

```lua
-- signature
lurek.render.ellipse(mode, x, y, rx, ry)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | `string` | "fill" or "line". |
| `x` | `number` | Center X. |
| `y` | `number` | Center Y. |
| `rx` | `number` | Horizontal radius. |
| `ry` | `number` | Vertical radius. |

**Example**

```lua
do
    lurek.render.setColor(0.2, 0.6, 0.9, 1)
    lurek.render.ellipse("fill", 110, 250, 60, 30)
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.ellipse("line", 240, 250, 40, 60)
    print("ellipse examples drawn")
    print("ellipse radii = 60x30 and 40x60")
end
```

---

### `lurek.render.flushSortGroup`

Ends a sort group and emits all accumulated draw calls in sorted order.

```lua
-- signature
lurek.render.flushSortGroup(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Group identifier matching the beginSortGroup call. |

**Example**

```lua
do
    lurek.render.beginSortGroup(7)
    lurek.render.pushSortKey(5)
    lurek.render.circle("fill", 100, 100, 10)
    lurek.render.flushSortGroup(7)
    print("flushSortGroup id = 7")
end
```

---

### `lurek.render.getBackgroundColor`

Returns the current background clear color.

```lua
-- signature
lurek.render.getBackgroundColor()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Red, green, blue, alpha channels (0–1). |
| `number` | b Red, green, blue, alpha channels (0–1). |
| `number` | c Red, green, blue, alpha channels (0–1). |
| `number` | d Red, green, blue, alpha channels (0–1). |

**Example**

```lua
do
    lurek.render.setBackgroundColor(0.2, 0.2, 0.3)
    local r, g, b, a = lurek.render.getBackgroundColor()
    print("background = " .. r .. "," .. g .. "," .. b .. "," .. a)
    lurek.render.setBackgroundColor(0, 0, 0)
end
```

---

### `lurek.render.getBlendMode`

Returns the current blend mode name.

```lua
-- signature
lurek.render.getBlendMode()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Current blend mode: "alpha", "add", "multiply", "replace", or "screen". |

**Example**

```lua
do
    lurek.render.setBlendMode("alpha")
    print("blend mode = " .. lurek.render.getBlendMode())
end
```

---

### `lurek.render.getBuiltInFontNames`

Returns all stable built-in font names.

```lua
-- signature
lurek.render.getBuiltInFontNames()
```

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Array of bundled font names such as font_8 and fontb_8. |

**Example**

```lua
do
    local names = lurek.render.getBuiltInFontNames()
    print("built-in font name count = " .. #names)
    print("first built-in font = " .. tostring(names[1]))
end
```

---

### `lurek.render.getCanvas`

Returns the currently active canvas, or nil if drawing to the screen.

```lua
-- signature
lurek.render.getCanvas()
```

**Returns**

| Type | Description |
|------|-------------|
| `LCanvas` | The active canvas handle. |

**Example**

```lua
do
    local canvas = lurek.render.newCanvas(120, 80)
    lurek.render.setCanvas(canvas)
    local active = lurek.render.getCanvas()
    local w, h = lurek.render.getCanvasSize(canvas)
    lurek.render.setCanvas(nil)
    lurek.render.resetCanvas(canvas)
    print("active canvas exists = " .. tostring(active ~= nil))
    print("canvas size = " .. w .. "x" .. h)
end
```

---

### `lurek.render.getCanvasSize`

Returns the pixel dimensions of a canvas.

```lua
-- signature
lurek.render.getCanvasSize(canvas)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `canvas` | `LCanvas` | Canvas handle to query. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Width and height in pixels. |
| `number` | b Width and height in pixels. |

**Example**

```lua
do
    local canvas = lurek.render.newCanvas(200, 100)
    local w, h = lurek.render.getCanvasSize(canvas)
    print("canvas size = " .. w .. "x" .. h)
    print("color mask red enabled = " .. tostring(select(1, lurek.render.getColorMask())))
    canvas:release()
end
```

---

### `lurek.render.getColor`

Returns the current drawing color.

```lua
-- signature
lurek.render.getColor()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Red, green, blue, alpha channels (0–1). |
| `number` | b Red, green, blue, alpha channels (0–1). |
| `number` | c Red, green, blue, alpha channels (0–1). |
| `number` | d Red, green, blue, alpha channels (0–1). |

**Example**

```lua
do
    lurek.render.setColor(1, 0, 0, 1)
    local r, g, b, a = lurek.render.getColor()
    print("color = " .. r .. "," .. g .. "," .. b .. "," .. a)
    lurek.render.setColor(1, 1, 1, 1)
end
```

---

### `lurek.render.getColorMask`

Returns the current color write mask.

```lua
-- signature
lurek.render.getColorMask()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | a Red, green, blue, alpha channel write states. |
| `boolean` | b Red, green, blue, alpha channel write states. |
| `boolean` | c Red, green, blue, alpha channel write states. |
| `boolean` | d Red, green, blue, alpha channel write states. |

**Example**

```lua
do
    lurek.render.setColorMask(true, false, true, true)
    local r, g, b, a = lurek.render.getColorMask()
    print("color mask = " .. tostring(r) .. "," .. tostring(g) .. "," .. tostring(b) .. "," .. tostring(a))
    lurek.render.setColorMask()
end
```

---

### `lurek.render.getDefaultFilter`

Returns the current default texture filtering settings.

```lua
-- signature
lurek.render.getDefaultFilter()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | a Min filter, mag filter, anisotropy level. |
| `string` | b Min filter, mag filter, anisotropy level. |
| `number` | c Min filter, mag filter, anisotropy level. |

**Example**

```lua
do
    local min_filter, mag_filter, aniso = lurek.render.getDefaultFilter()
    print("default filter = " .. min_filter .. "," .. mag_filter .. "," .. aniso)
end
```

---

### `lurek.render.getDefaultFont`

Returns a built-in default font at the nearest available bundled point size.

```lua
-- signature
lurek.render.getDefaultFont(pointSize, bold)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `pointSize?` | `number` | Desired built-in point size. When omitted, returns the current configured default. |
| `bold?` | `boolean` | When true, returns the bold variant. When omitted, uses the current bold selection. |

**Returns**

| Type | Description |
|------|-------------|
| `LFont` | The built-in font handle. |

**Example**

```lua
do
    local font = lurek.render.getDefaultFont(24)
    lurek.render.setFont(font)
    lurek.render.print("Default font size 24", 10, 455)
    print("default font height = " .. font:getHeight())
    print("default font fetched by point size")
end
```

---

### `lurek.render.getDepthMode`

Returns the current depth comparison mode and write-enable flag.

```lua
-- signature
lurek.render.getDepthMode()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | a Depth mode name and whether depth writes are enabled. |
| `boolean` | b Depth mode name and whether depth writes are enabled. |

**Example**

```lua
do
    local mode, write = lurek.render.getDepthMode()
    print("depth mode = " .. mode)
    print("depth write = " .. tostring(write))
end
```

---

### `lurek.render.getDimensions`

Returns the current window width and height.

```lua
-- signature
lurek.render.getDimensions()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Width and height in pixels. |
| `number` | b Width and height in pixels. |

**Example**

```lua
do
    local w, h = lurek.render.getDimensions()
    print("dimensions = " .. w .. "x" .. h)
    print("width = " .. lurek.render.getWidth() .. ", height = " .. lurek.render.getHeight())
end
```

---

### `lurek.render.getFont`

Returns the currently active font, or nil if none is set.

```lua
-- signature
lurek.render.getFont()
```

**Returns**

| Type | Description |
|------|-------------|
| `LFont` | The active font handle. |

**Example**

```lua
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 14)
    lurek.render.setFont(font)
    print("active font exists = " .. tostring(lurek.render.getFont() ~= nil))
    print("active font width of test = " .. font:getWidth("test"))
    font:release()
end
```

---

### `lurek.render.getFontAscent`

Returns the ascent (pixels above baseline) of the given font.

```lua
-- signature
lurek.render.getFontAscent(font)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `font` | `LFont` | Font handle to query. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Ascent in pixels. |

**Example**

```lua
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 16)
    print("module ascent = " .. lurek.render.getFontAscent(font))
    print("module descent = " .. lurek.render.getFontDescent(font))
end
```

---

### `lurek.render.getFontCellWidth`

Returns the fixed cell width of a bitmap font.

```lua
-- signature
lurek.render.getFontCellWidth(font)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `font` | `LFont` | Font handle to query. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Cell width in pixels. |

**Example**

```lua
do
    local font = lurek.render.getDefaultFont(14)
    print("font cell width = " .. lurek.render.getFontCellWidth(font))
    print("font descent = " .. lurek.render.getFontDescent(font))
end
```

---

### `lurek.render.getFontDescent`

Returns the descent (pixels below baseline) of the given font.

```lua
-- signature
lurek.render.getFontDescent(font)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `font` | `LFont` | Font handle to query. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Descent in pixels. |

**Example**

```lua
do
    local font = lurek.render.getDefaultFont(14)
    print("font descent = " .. lurek.render.getFontDescent(font))
    print("font ascent = " .. lurek.render.getFontAscent(font))
end
```

---

### `lurek.render.getFontHeight`

Returns the line height of the given font.

```lua
-- signature
lurek.render.getFontHeight(font)
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
    local font = lurek.render.getDefaultFont(14)
    print("font height = " .. lurek.render.getFontHeight(font))
    print("font line height = " .. lurek.render.getFontLineHeight(font))
end
```

---

### `lurek.render.getFontLineHeight`

Returns the line spacing of the given font.

```lua
-- signature
lurek.render.getFontLineHeight(font)
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
    local font = lurek.render.getDefaultFont(14)
    print("font line height = " .. lurek.render.getFontLineHeight(font))
    print("line width = " .. lurek.render.getLineWidth())
end
```

---

### `lurek.render.getFontSizes`

Returns all available built-in point sizes.

```lua
-- signature
lurek.render.getFontSizes()
```

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Array of bundled font sizes such as 8, 10, 12, 16, 20, 24, and 30. |

**Example**

```lua
do
    local sizes = lurek.render.getFontSizes()
    print("font sizes count = " .. #sizes)
    print("first bundled size = " .. tostring(sizes[1]))
end
```

---

### `lurek.render.getFontWidth`

Measures the pixel width of text using the given font.

```lua
-- signature
lurek.render.getFontWidth(font, text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `font` | `LFont` | Font handle to measure with. |
| `text` | `string` | Text to measure. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Width in pixels. |

**Example**

```lua
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 14)
    print("module getFontWidth = " .. lurek.render.getFontWidth(font, "Measure"))
    print("module getFontHeight = " .. lurek.render.getFontHeight(font))
end
```

---

### `lurek.render.getFontWrap`

Word-wraps text using the active font and returns the resulting lines and widest line width.

```lua
-- signature
lurek.render.getFontWrap(text, limit)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `string` | Text to wrap. |
| `limit` | `number` | Maximum line width in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| `LuaValue` | a Wrapped lines as a table when a font is active, or nil otherwise, followed by the widest line width. |
| `number` | b Wrapped lines as a table when a font is active, or nil otherwise, followed by the widest line width. |

**Example**

```lua
do
    local font = lurek.render.getDefaultFont(12)
    lurek.render.setFont(font)
    local lines, width = lurek.render.getFontWrap("A long sentence for wrap testing at 200 px limit.", 200)
    print("module wrapped lines = " .. #lines)
    print("module wrap width = " .. width)
end
```

---

### `lurek.render.getHeight`

Returns the current window height in pixels.

```lua
-- signature
lurek.render.getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Window height. |

**Example**

```lua
do
    local w, h = lurek.render.getDimensions()
    print("dimensions = " .. w .. "x" .. h)
    print("height = " .. lurek.render.getHeight())
end
```

---

### `lurek.render.getLayerZOrder`

Returns the z-order value of a named rendering layer.

```lua
-- signature
lurek.render.getLayerZOrder(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Layer name. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Z-order value (default 0 if unset). |

**Example**

```lua
do
    lurek.render.newLayer("midground", 5)
    print("midground z before = " .. lurek.render.getLayerZOrder("midground"))
    lurek.render.setLayerZOrder("midground", 15)
    print("midground z after = " .. lurek.render.getLayerZOrder("midground"))
end
```

---

### `lurek.render.getLineWidth`

Returns the current line width used for line-mode drawing.

```lua
-- signature
lurek.render.getLineWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Line width in pixels. |

**Example**

```lua
do
    lurek.render.setLineWidth(3)
    local width = lurek.render.getLineWidth()
    print("line width = " .. tostring(width))
    lurek.render.setLineWidth(1)
    print("line width restored")
end
```

---

### `lurek.render.getPointSize`

Returns the current point diameter used for point drawing.

```lua
-- signature
lurek.render.getPointSize()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Point diameter in pixels. |

**Example**

```lua
do
    lurek.render.setPointSize(7)
    local size = lurek.render.getPointSize()
    print("point size = " .. tostring(size))
    lurek.render.setPointSize(1)
    print("point size restored")
end
```

---

### `lurek.render.getScissor`

Returns the current scissor rectangle, or nothing if no scissor is set.

```lua
-- signature
lurek.render.getScissor()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a x, y, w, h of the scissor rect (empty if none). |
| `number` | b x, y, w, h of the scissor rect (empty if none). |
| `number` | c x, y, w, h of the scissor rect (empty if none). |
| `number` | d x, y, w, h of the scissor rect (empty if none). |

**Example**

```lua
do
    lurek.render.setScissor(10, 10, 200, 100)
    local x, y, w, h = lurek.render.getScissor()
    print("scissor = " .. x .. "," .. y .. "," .. w .. "," .. h)
    lurek.render.setScissor()
end
```

---

### `lurek.render.getShader`

Returns the currently active shader, or nil if using the default.

```lua
-- signature
lurek.render.getShader()
```

**Returns**

| Type | Description |
|------|-------------|
| `LShader` | The active shader handle. |

**Example**

```lua
do
    local code = "@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); }"
    local shader = lurek.render.newShader(code)
    lurek.render.setShader(shader)
    print("getShader returned handle = " .. tostring(lurek.render.getShader() ~= nil))
    lurek.render.setShader(nil)
    shader:release()
end
```

---

### `lurek.render.getStats`

Returns a table of rendering statistics for the current frame.

```lua
-- signature
lurek.render.getStats()
```

**Returns**

| Type | Description |
|------|-------------|
| `RenderGetStatsResult` | Stats table with rendering counters. |

**Example**

```lua
do
    local stats = lurek.render.getStats()
    print("drawcalls = " .. tostring(stats.drawcalls))
    print("textures = " .. tostring(stats.textures) .. ", canvases = " .. tostring(stats.canvases))
    print("gpu_draw_calls = " .. tostring(stats.gpu_draw_calls))
end
```

---

### `lurek.render.getStencilMode`

Returns the current stencil action, compare mode, and reference value.

```lua
-- signature
lurek.render.getStencilMode()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | a Action name, compare mode name, and reference value. |
| `string` | b Action name, compare mode name, and reference value. |
| `number` | c Action name, compare mode name, and reference value. |

**Example**

```lua
do
    lurek.render.setStencilMode("replace", "always", 4)
    local action, compare, value = lurek.render.getStencilMode()
    print("stencil mode = " .. action .. "," .. compare .. "," .. value)
    lurek.render.clearStencil()
end
```

---

### `lurek.render.getWidth`

Returns the current window width in pixels.

```lua
-- signature
lurek.render.getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Window width. |

**Example**

```lua
do
    local w, h = lurek.render.getDimensions()
    print("dimensions = " .. w .. "x" .. h)
    print("width = " .. lurek.render.getWidth())
end
```

---

### `lurek.render.intersectScissor`

Intersects the given rectangle with the current scissor, narrowing the drawable region.

```lua
-- signature
lurek.render.intersectScissor(x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | Left edge. |
| `y` | `number` | Top edge. |
| `w` | `number` | Width. |
| `h` | `number` | Height. |

**Example**

```lua
do
    lurek.render.setScissor(0, 0, 800, 600)
    lurek.render.intersectScissor(100, 100, 400, 300)
    local x, y, w, h = lurek.render.getScissor()
    print("intersected scissor = " .. x .. "," .. y .. "," .. w .. "," .. h)
    lurek.render.setScissor()
end
```

---

### `lurek.render.isBold`

Returns true if the current default font selection uses the bold variant.

```lua
-- signature
lurek.render.isBold()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when bold is active. |

**Example**

```lua
do
    local v = lurek.render.isBold()
    print("isBold = " .. tostring(v))
end
```

---

### `lurek.render.isLayerVisible`

Returns whether a named rendering layer is currently visible.

```lua
-- signature
lurek.render.isLayerVisible(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Layer name. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the layer is visible. |

**Example**

```lua
do
    lurek.render.newLayer("visibility_stub", 2)
    lurek.render.setLayerVisible("visibility_stub", true)
    print("layer visible = " .. tostring(lurek.render.isLayerVisible("visibility_stub")))
    lurek.render.setLayerVisible("visibility_stub", false)
    print("layer visible after hide = " .. tostring(lurek.render.isLayerVisible("visibility_stub")))
end
```

---

### `lurek.render.isWireframe`

Returns whether wireframe rendering is currently active.

```lua
-- signature
lurek.render.isWireframe()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if wireframe mode is on. |

**Example**

```lua
do
    lurek.render.setWireframe(true)
    print("wireframe enabled = " .. tostring(lurek.render.isWireframe()))
    lurek.render.setWireframe(false)
    print("wireframe enabled after reset = " .. tostring(lurek.render.isWireframe()))
end
```

---

### `lurek.render.line`

Draws a line between two points, or a polyline through multiple points.

```lua
-- signature
lurek.render.line(...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| — | — | @param ... number Coordinate values: x1, y1, x2, y2 for a line, or more for a polyline. |

**Example**

```lua
do
    lurek.render.setColor(1, 1, 0.2, 1)
    lurek.render.line(10, 320, 160, 320)
    lurek.render.setColor(0.1, 0.9, 1, 1)
    lurek.render.line(10, 340, 40, 360, 70, 340, 100, 360, 130, 340, 160, 360)
    lurek.render.setColor(1, 1, 1, 1)
    print("line and polyline drawn")
    print("polyline points = 6")
end
```

---

### `lurek.render.loadModel`

Loads a 3D model file (OBJ format) and returns a handle for 2D projection and sprite rendering.

```lua
-- signature
lurek.render.loadModel(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | File path to the model file relative to the game directory. |

**Returns**

| Type | Description |
|------|-------------|
| `LObjModel` | The loaded model handle. |

**Example**

```lua
do
    local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
    print("loadModel face count = " .. model:getFaceCount())
    print("loadModel normal count = " .. model:getNormalCount())
end
```

---

### `lurek.render.loadObj`

Loads a Wavefront OBJ model file and returns a model handle for projection and rendering.

```lua
-- signature
lurek.render.loadObj(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | File path to the .obj file relative to the game directory. |

**Returns**

| Type | Description |
|------|-------------|
| `LObjModel` | The loaded OBJ model handle. |

**Example**

```lua
do
    local model = lurek.render.loadObj("content/examples/assets/models/sample_tank.obj")
    print("obj faces = " .. model:getFaceCount())
    print("obj vertices = " .. model:getVertexCount())
end
```

---

### `lurek.render.newCanvas`

Creates a new off-screen render target with the given dimensions.

```lua
-- signature
lurek.render.newCanvas(width, height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | `number` | Canvas width in pixels (must be > 0). |
| `height` | `number` | Canvas height in pixels (must be > 0). |

**Returns**

| Type | Description |
|------|-------------|
| `LCanvas` | The created canvas handle. |

**Example**

```lua
do
    local canvas = lurek.render.newCanvas(96, 96)
    local w, h = canvas:getDimensions()
    lurek.render.setCanvas(canvas)
    lurek.render.rectangle("fill", 0, 0, 96, 96)
    lurek.render.circle("line", 48, 48, 24)
    lurek.render.setCanvas(nil)
    lurek.render.draw(canvas, 10, 70)
    print("canvas size = " .. w .. "x" .. h)
    print("canvas rendered and drawn back")
end
```

---

### `lurek.render.newDepthSorter`

Performs the 'render' operation.

```lua
-- signature
lurek.render.newDepthSorter()
```

**Returns**

| Type | Description |
|------|-------------|
| `LDepthSorter` | A fresh depth sorter with no queued entries. |

---

### `lurek.render.newDrawLayer`

Creates a new z-ordered draw layer for sorting draw callbacks by depth.

```lua
-- signature
lurek.render.newDrawLayer()
```

**Returns**

| Type | Description |
|------|-------------|
| `LDrawLayer` | The created draw layer. |

**Example**

```lua
do
    local layer = lurek.render.newDrawLayer()
    layer:queue(10, function()
        lurek.render.rectangle("fill", 180, 310, 20, 20)
    end)
    layer:queue(5, function()
        lurek.render.rectangle("fill", 190, 320, 20, 20)
    end)
    print("queued callbacks = " .. layer:getCount())
    layer:flush()
    print("queued callbacks after flush = " .. layer:getCount())
end
```

---

### `lurek.render.newFont`

Creates a font from a built-in font name, a font file path, or a numeric built-in point-size selector.

```lua
-- signature
lurek.render.newFont(pathOrSize, size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `pathOrSize` | `any` | Built-in font name, font file path, or numeric built-in point-size selector. |
| `size?` | `number` | Point size for TTF/OTF files, or cell height for PNG atlases. |

**Returns**

| Type | Description |
|------|-------------|
| `LFont` | The created font handle. |

**Example**

```lua
do
    local font = lurek.render.newFont(16)
    lurek.render.setFont(font)
    lurek.render.print("newFont built-in size 16", 10, 430)
    print("newFont type = " .. font:type())
    print("newFont built from bundled size selector")
end
```

---

### `lurek.render.newImage`

Loads a texture from a file path or creates one from an ImageData object.

```lua
-- signature
lurek.render.newImage(pathOrData, colorSpace)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `pathOrData` | `string|LImageData` | File path to an image, or an ImageData object. |
| `colorSpace?` | `string` | Color space: "srgb" (default) or "linear". |

**Returns**

| Type | Description |
|------|-------------|
| `LImage` | The loaded image handle. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local w, h = image:getDimensions()
    lurek.render.draw(image, 10, 10)
    lurek.render.draw(image, 90, 10, math.pi / 8, 0.5, 0.5)
    print("image size = " .. w .. "x" .. h)
    print("newImage handle ready")
end
```

---

### `lurek.render.newLayer`

Creates a named rendering layer with an optional z-order for draw call organization.

```lua
-- signature
lurek.render.newLayer(name, zOrder)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Layer name. |
| `zOrder?` | `number` | Z-order for layer sorting (default 0). |

**Example**

```lua
do
    lurek.render.newLayer("background", 0)
    lurek.render.newLayer("foreground", 10)
    lurek.render.setLayer("foreground")
    print("current layer = " .. lurek.render.currentLayer())
    print("foreground z = " .. lurek.render.getLayerZOrder("foreground"))
end
```

---

### `lurek.render.newMesh`

Creates a custom vertex mesh from an array of vertex data tables.

```lua
-- signature
lurek.render.newMesh(verts, mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `verts` | `table` | Array of vertex tables: {{x, y, u, v, r, g, b, a}, ...}. |
| `mode?` | `string` | Draw mode: "triangles" (default), "fan", or "strip". |

**Returns**

| Type | Description |
|------|-------------|
| `LMesh` | The created mesh handle. |

**Example**

```lua
do
    local verts = {
        { 0, 0, 0, 0, 1, 0, 0, 1 },
        { 60, 0, 1, 0, 0, 1, 0, 1 },
        { 30, 50, 0.5, 1, 0, 0, 1, 1 },
    }
    local mesh = lurek.render.newMesh(verts, "triangles")
    lurek.render.draw(mesh, 70, 380)
    print("mesh vertex count = " .. mesh:getVertexCount())
    print("newMesh created triangles mesh")
end
```

---

### `lurek.render.newNineSlice`

Creates a 9-slice definition from an image and four border insets for scalable UI rendering.

```lua
-- signature
lurek.render.newNineSlice(image, top, right, bottom, left)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `image` | `LImage` | Source texture. |
| `top` | `number` | Top border inset in pixels. |
| `right` | `number` | Right border inset. |
| `bottom` | `number` | Bottom border inset. |
| `left` | `number` | Left border inset. |

**Returns**

| Type | Description |
|------|-------------|
| `LNineSlice` | The 9-slice handle. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local slice = lurek.render.newNineSlice(image, 4, 4, 4, 4)
    local top, right, bottom, left = slice:getInsets()
    lurek.render.drawNineSlice(slice, 10, 310, 140, 48)
    print("nine-slice insets = " .. top .. "," .. right .. "," .. bottom .. "," .. left)
    print("nine-slice drawn")
end
```

---

### `lurek.render.newQuad`

Creates a Quad defining a rectangular sub-region of a texture for sprite-sheet rendering.

```lua
-- signature
lurek.render.newQuad(x, y, w, h, sw, sh)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | Left edge in texture pixels. |
| `y` | `number` | Top edge in texture pixels. |
| `w` | `number` | Width in texture pixels. |
| `h` | `number` | Height in texture pixels. |
| `sw` | `number` | Full source texture width. |
| `sh` | `number` | Full source texture height. |

**Returns**

| Type | Description |
|------|-------------|
| `LQuad` | The created quad. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local sw, sh = image:getDimensions()
    local quad = lurek.render.newQuad(0, 0, 16, 16, sw, sh)
    local x, y, w, h = quad:getViewport()
    lurek.render.drawq(image, quad, 10, 170)
    print("quad viewport = " .. x .. "," .. y .. "," .. w .. "," .. h)
    print("quad texture dims = " .. sw .. "x" .. sh)
end
```

---

### `lurek.render.newShader`

Compiles a WGSL shader program from source code and returns a handle.

```lua
-- signature
lurek.render.newShader(code)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `code` | `string` | WGSL shader source code. |

**Returns**

| Type | Description |
|------|-------------|
| `LShader` | The compiled shader handle. |

**Example**

```lua
do
    local code = "@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); }"
    local shader = lurek.render.newShader(code)
    print("shader type = " .. shader:type())
    print("newShader compiled minimal fragment shader")
end
```

---

### `lurek.render.newShape`

Creates a new retained compound shape for accumulating draw commands.

```lua
-- signature
lurek.render.newShape()
```

**Returns**

| Type | Description |
|------|-------------|
| `LShape` | The created shape handle. |

**Example**

```lua
do
    local shape = lurek.render.newShape()
    shape:setColor(1, 0, 0, 1)
    shape:rectangle("fill", 0, 0, 40, 24)
    shape:setColor(0, 1, 0, 1)
    shape:circle("line", 60, 12, 12)
    shape:draw(170, 380)
    print("shape command count = " .. shape:getCommandCount())
    print("newShape drew retained commands")
end
```

---

### `lurek.render.newSpriteBatch`

Creates a batched sprite renderer for efficiently drawing many copies of the same texture.

```lua
-- signature
lurek.render.newSpriteBatch(image, max)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `image` | `LImage` | Source texture for all sprites in the batch. |
| `max?` | `number` | Maximum number of entries (default 1000). |

**Returns**

| Type | Description |
|------|-------------|
| `LSpriteBatch` | The created sprite batch handle. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local batch = lurek.render.newSpriteBatch(image, 16)
    local last = batch:add(60, 220, 0, 0.5, 0.5, 0, 0)
    batch:add(90, 220, math.pi / 8, 0.5, 0.5, 0, 0)
    lurek.render.draw(batch, 0, 0)
    print("sprite batch count = " .. batch:getCount())
    print("last sprite index = " .. tostring(last))
end
```

---

### `lurek.render.origin`

Resets the current transformation matrix to the identity (no transform).

```lua
-- signature
lurek.render.origin()
```

**Example**

```lua
do
    lurek.render.push()
    lurek.render.translate(999, 999)
    lurek.render.origin()
    lurek.render.rectangle("line", 0, 0, 12, 12)
    lurek.render.pop()
    print("origin reset applied")
    print("origin rectangle drawn at screen origin")
end
```

---

### `lurek.render.points`

Draws one or more points. Accepts either a table of {x,y} pairs or flat x,y coordinate values.

```lua
-- signature
lurek.render.points(...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| — | — | @param ... table|number Point data as a table of {x,y} sub-tables, or flat x1,y1,x2,y2,... values. |

**Example**

```lua
do
    lurek.render.setPointSize(5)
    lurek.render.setColor(1, 0.1, 0.1, 1)
    lurek.render.points(20, 390, 40, 390, 60, 390, 80, 390)
    lurek.render.setColor(0.1, 0.1, 1, 1)
    lurek.render.points({ { 120, 390 }, { 140, 390 }, { 160, 390 } })
    lurek.render.setPointSize(1)
    lurek.render.setColor(1, 1, 1, 1)
    print("point size reset to 1")
    print("points drawn with flat and table inputs")
end
```

---

### `lurek.render.polygon`

Draws a polygon from a flat list of x,y vertex coordinates.

```lua
-- signature
lurek.render.polygon(mode, ...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | `string` | "fill" or "line". |
| — | — | @param ... number Flat vertex coordinates: x1, y1, x2, y2, ... (minimum 3 vertices). |

**Example**

```lua
do
    lurek.render.setColor(0.8, 0.1, 0.5, 1)
    lurek.render.polygon("fill", 210, 300, 260, 280, 310, 300, 290, 350, 230, 350)
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.polygon("line", 210, 300, 260, 280, 310, 300, 290, 350, 230, 350)
    print("polygon vertices = 5")
    print("polygon fill and line drawn")
end
```

---

### `lurek.render.pop`

Pops the top transformation matrix from the transform stack, restoring the previous one.

```lua
-- signature
lurek.render.pop()
```

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    lurek.render.push()
    lurek.render.translate(50, 50)
    lurek.render.rotate(math.pi / 4)
    lurek.render.scale(2, 2)
    lurek.render.shear(0.1, 0.0)
    lurek.render.draw(image, 0, 0)
    lurek.render.pop()
    print("transform stack pop completed")
end
```

---

### `lurek.render.popLayer`

Ends a compositing layer and composites it with the previous content.

```lua
-- signature
lurek.render.popLayer(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Layer identifier matching the pushLayer call. |

**Example**

```lua
do
    lurek.render.pushLayer(99, 1.0, "alpha")
    lurek.render.circle("fill", 140, 100, 10)
    lurek.render.popLayer(99)
    print("popLayer id = 99")
end
```

---

### `lurek.render.print`

Draws text using the active font at the given position.

```lua
-- signature
lurek.render.print(text, x, y, scale)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `string` | Text to render. |
| `x?` | `number` | X position (default 0). |
| `y?` | `number` | Y position (default 0). |
| `scale?` | `number` | Text scale factor (default 1). |

**Example**

```lua
do
    local font = lurek.render.getDefaultFont(16)
    lurek.render.setFont(font)
    lurek.render.print("Hello from lurek.render.print", 10, 10)
    print("print font type = " .. font:type())
    print("printed plain text")
end
```

---

### `lurek.render.printRich`

Draws rich text composed of individually styled spans at the given position.

```lua
-- signature
lurek.render.printRich(spans, x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `spans` | `table` | Array of span tables, each with fields: text, r, g, b, a, scale. |
| `x` | `number` | X position. |
| `y` | `number` | Y position. |

**Example**

```lua
do
    local font = lurek.render.getDefaultFont(16)
    local spans = {
        { text = "Red ", r = 255, g = 80, b = 80, a = 255, scale = 1.0 },
        { text = "Green ", r = 80, g = 220, b = 120, a = 255, scale = 1.0 },
        { text = "Blue", r = 80, g = 120, b = 255, a = 255, scale = 1.2 },
    }
    lurek.render.setFont(font)
    lurek.render.printRich(spans, 10, 120)
    print("rich spans = " .. #spans)
    print("rich text uses u8 colors")
end
```

---

### `lurek.render.printRichWithFont`

Draws rich text using a specific font without changing the global active font.

```lua
-- signature
lurek.render.printRichWithFont(font, spans, x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `font` | `LFont` | Font handle to use for this draw. |
| `spans` | `table` | Array of span tables, each with fields: text, r, g, b, a, scale. |
| `x` | `number` | X position. |
| `y` | `number` | Y position. |

**Example**

```lua
do
    local font = lurek.render.getDefaultFont(16)
    local spans = {
        { text = "Red", r = 255, g = 0, b = 0, a = 255, scale = 1 },
        { text = " and ", r = 255, g = 255, b = 255, a = 255, scale = 1 },
        { text = "Green", r = 0, g = 255, b = 0, a = 255, scale = 1 },
    }
    lurek.render.printRichWithFont(font, spans, 10, 250)
    print("printRichWithFont spans = " .. #spans)
    print("printRichWithFont uses byte colors")
end
```

---

### `lurek.render.printRotated`

Draws text centered and rotated around its midpoint.

```lua
-- signature
lurek.render.printRotated(text, x, y, angle, scale)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `string` | Text to render. |
| `x` | `number` | Center X position. |
| `y` | `number` | Center Y position. |
| `angle` | `number` | Rotation angle in radians. |
| `scale?` | `number` | Text scale factor (default 1). |

**Example**

```lua
do
    local font = lurek.render.getDefaultFont(16)
    lurek.render.setFont(font)
    lurek.render.printRotated("Rotated text", 180, 90, math.pi / 6, 1.0)
    print("printRotated angle = " .. tostring(math.pi / 6))
    print("rotated text drawn")
end
```

---

### `lurek.render.printRotatedWithFont`

Draws text centered and rotated around its midpoint using a specific font without changing the global active font.

```lua
-- signature
lurek.render.printRotatedWithFont(font, text, x, y, angle, scale)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `font` | `LFont` | Font handle to use for this draw. |
| `text` | `string` | Text to render. |
| `x` | `number` | Center X position. |
| `y` | `number` | Center Y position. |
| `angle` | `number` | Rotation angle in radians. |
| `scale?` | `number` | Text scale factor (default 1). |

**Example**

```lua
do
    local font = lurek.render.getDefaultFont(16)
    lurek.render.printRotatedWithFont(font, "Rotated text", 100, 100, math.pi / 4, 1.0)
    print("printRotatedWithFont angle = " .. tostring(math.pi / 4))
end
```

---

### `lurek.render.printWithFont`

Draws text using a specific font without changing the global active font.

```lua
-- signature
lurek.render.printWithFont(font, text, x, y, scale)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `font` | `LFont` | Font handle to use for this draw. |
| `text` | `string` | Text to render. |
| `x?` | `number` | X position (default 0). |
| `y?` | `number` | Y position (default 0). |
| `scale?` | `number` | Text scale factor (default 1). |

**Example**

```lua
do
    local font = lurek.render.getDefaultFont(16)
    lurek.render.printWithFont(font, "Standard text override", 10, 150)
    print("printWithFont used default font size 16")
end
```

---

### `lurek.render.printf`

Draws word-wrapped and aligned text within a pixel-width limit.

```lua
-- signature
lurek.render.printf(text, x, y, limit, align)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `string` | Text to render. |
| `x` | `number` | X position. |
| `y` | `number` | Y position. |
| `limit` | `number` | Maximum line width in pixels for wrapping. |
| `align?` | `string` | Alignment: "left" (default), "center", "right", or "justify". |

**Example**

```lua
do
    local font = lurek.render.getDefaultFont(16)
    lurek.render.setFont(font)
    lurek.render.printf("Centered text inside a 220 px box.", 10, 40, 220, "center")
    print("printf limit = 220")
    print("printf align = center")
end
```

---

### `lurek.render.printfWithFont`

Draws word-wrapped and aligned text with a specific font without changing the global active font.

```lua
-- signature
lurek.render.printfWithFont(font, text, x, y, limit, align)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `font` | `LFont` | Font handle to use for this draw. |
| `text` | `string` | Text to render. |
| `x` | `number` | X position. |
| `y` | `number` | Y position. |
| `limit` | `number` | Maximum line width in pixels for wrapping. |
| `align?` | `string` | Alignment: "left" (default), "center", "right", or "justify". |

**Example**

```lua
do
    local font = lurek.render.getDefaultFont(16)
    lurek.render.printfWithFont(font, "Formatted text inside a 160 px box.", 10, 200, 160, "left")
    print("printfWithFont limit = 160")
    print("printfWithFont align = left")
end
```

---

### `lurek.render.push`

Pushes the current transformation matrix onto the transform stack.

```lua
-- signature
lurek.render.push()
```

**Example**

```lua
do
    lurek.render.push()
    lurek.render.translate(80, 80)
    lurek.render.rotate(math.pi / 8)
    lurek.render.scale(1.2, 0.8)
    lurek.render.rectangle("line", -20, -20, 40, 40)
    lurek.render.pop()
    print("transform stack push/pop used")
    print("translated, rotated, and scaled rectangle")
end
```

---

### `lurek.render.pushLayer`

Begins a compositing layer with the given alpha and blend mode. Must be paired with popLayer.

```lua
-- signature
lurek.render.pushLayer(id, alpha, blendMode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Layer identifier (must match the popLayer call). |
| `alpha?` | `number` | Layer opacity (0–1, default 1). |
| `blendMode?` | `string` | Blend mode: "alpha" (default), "add", "multiply", "replace", "screen". |

**Example**

```lua
do
    lurek.render.pushLayer(1, 0.65, "alpha")
    lurek.render.rectangle("fill", 320, 140, 60, 40)
    lurek.render.popLayer(1)
    print("pushLayer id = 1")
    print("popLayer matched id = 1")
end
```

---

### `lurek.render.pushSortKey`

Sets the depth sort key for subsequent draw calls within the current sort group.

```lua
-- signature
lurek.render.pushSortKey(depth)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `depth` | `number` | Sort depth value (lower draws first). |

**Example**

```lua
do
    lurek.render.beginSortGroup(8)
    lurek.render.pushSortKey(3)
    lurek.render.circle("fill", 120, 100, 10)
    lurek.render.flushSortGroup(8)
    print("pushSortKey depth = 3")
end
```

---

### `lurek.render.rectangle`

Draws a rectangle. If rx is provided, draws a rounded rectangle.

```lua
-- signature
lurek.render.rectangle(mode, x, y, w, h, rx, ry)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | `string` | "fill" or "line". |
| `x` | `number` | Left edge X. |
| `y` | `number` | Top edge Y. |
| `w` | `number` | Width. |
| `h` | `number` | Height. |
| `rx?` | `number` | Horizontal corner radius for rounded rectangle. |
| `ry?` | `number` | Vertical corner radius (defaults to rx). |

**Example**

```lua
do
    lurek.render.setColor(1, 0.2, 0.2, 1)
    lurek.render.rectangle("fill", 40, 150, 100, 60)
    lurek.render.rectangle("line", 160, 150, 100, 60, 8)
    lurek.render.setColor(1, 1, 1, 1)
    print("rectangle fill and rounded line drawn")
    print("rectangle width = 100")
end
```

---

### `lurek.render.resetCanvas`

Marks a canvas as needing a full clear before its next render pass. Use before re-rendering to avoid content accumulation.

```lua
-- signature
lurek.render.resetCanvas(canvas)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `canvas` | `LCanvas` | Canvas to reset. |

**Returns**

| Type | Description |
|------|-------------|
| `nil` | No return value. |

**Example**

```lua
do
    local canvas = lurek.render.newCanvas(64, 64)
    lurek.render.resetCanvas(canvas)
    print("resetCanvas called on 64x64 canvas")
    canvas:release()
end
```

---

### `lurek.render.rotate`

Applies a rotation to the current transformation matrix.

```lua
-- signature
lurek.render.rotate(angle)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `angle` | `number` | Rotation angle in radians. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    lurek.render.push()
    lurek.render.translate(50, 50)
    lurek.render.rotate(math.pi / 4)
    lurek.render.draw(image, 0, 0)
    lurek.render.pop()
    print("rotation angle = " .. tostring(math.pi / 4))
end
```

---

### `lurek.render.saveScreenshot`

Saves a screenshot of the current frame to a file under the save/ directory.

```lua
-- signature
lurek.render.saveScreenshot(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | Output path (must start with "save/"). |

**Example**

```lua
do
    lurek.render.saveScreenshot("save/test_screenshot.png")
    print("saveScreenshot requested for save/test_screenshot.png")
end
```

---

### `lurek.render.scale`

Applies scaling to the current transformation matrix.

```lua
-- signature
lurek.render.scale(sx, sy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sx` | `number` | Horizontal scale factor. |
| `sy?` | `number` | Vertical scale factor (defaults to sx for uniform scaling). |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    lurek.render.push()
    lurek.render.translate(50, 50)
    lurek.render.scale(2, 2)
    lurek.render.draw(image, 0, 0)
    lurek.render.pop()
    print("scale = 2x2")
end
```

---

### `lurek.render.setBackgroundColor`

Sets the background clear color used at the start of each frame.

```lua
-- signature
lurek.render.setBackgroundColor(r, g, b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | `number` | Red channel (0–1). |
| `g` | `number` | Green channel (0–1). |
| `b` | `number` | Blue channel (0–1). |

**Example**

```lua
do
    lurek.render.setBackgroundColor(0.1, 0.1, 0.2)
    local r, g, b, a = lurek.render.getBackgroundColor()
    print("background = " .. r .. "," .. g .. "," .. b .. "," .. a)
    lurek.render.setBackgroundColor(0, 0, 0)
    print("background restored to black")
end
```

---

### `lurek.render.setBlendMode`

Sets the blend mode for subsequent draw operations.

```lua
-- signature
lurek.render.setBlendMode(mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | `string` | One of: "alpha", "add", "multiply", "replace", "screen". |

**Example**

```lua
do
    local before = lurek.render.getBlendMode()
    lurek.render.setBlendMode("add")
    lurek.render.rectangle("fill", 180, 140, 40, 40)
    lurek.render.setBlendMode("multiply")
    lurek.render.rectangle("fill", 200, 160, 40, 40)
    lurek.render.setBlendMode("alpha")
    print("blend before = " .. before)
    print("blend restored to alpha")
end
```

---

### `lurek.render.setBold`

Sets whether subsequent font size lookups use the bold Courier New variant.

```lua
-- signature
lurek.render.setBold(bold)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bold` | `boolean` | True to enable bold, false for regular. |

**Example**

```lua
do
    local previous = lurek.render.isBold()
    lurek.render.setBold(true)
    lurek.render.print("Bold text", 10, 10)
    print("bold after set = " .. tostring(lurek.render.isBold()))
    lurek.render.setBold(previous)
    print("bold restored = " .. tostring(lurek.render.isBold()))
end
```

---

### `lurek.render.setCanvas`

Redirects all subsequent drawing to the given canvas. Pass nil to draw to the screen again.

```lua
-- signature
lurek.render.setCanvas(canvas)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `canvas?` | `LCanvas` | Canvas to draw to, or nil for the main screen. |

**Example**

```lua
do
    local canvas = lurek.render.newCanvas(96, 96)
    lurek.render.setCanvas(canvas)
    lurek.render.rectangle("fill", 0, 0, 96, 96)
    lurek.render.circle("line", 48, 48, 20)
    lurek.render.setCanvas(nil)
    print("setCanvas switched to off-screen target")
    print("setCanvas restored to screen")
end
```

---

### `lurek.render.setColor`

Sets the active drawing color for all subsequent draw operations.

```lua
-- signature
lurek.render.setColor(r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | `number` | Red channel (0–1). |
| `g` | `number` | Green channel (0–1). |
| `b` | `number` | Blue channel (0–1). |
| `a?` | `number` | Alpha channel (0–1, default 1). |

**Example**

```lua
do
    lurek.render.setColor(1, 0, 0, 1)
    local r, g, b, a = lurek.render.getColor()
    print("color = " .. r .. "," .. g .. "," .. b .. "," .. a)
    lurek.render.rectangle("fill", 340, 10, 40, 20)
    lurek.render.setColor(1, 1, 1, 1)
    print("color restored to white")
end
```

---

### `lurek.render.setColorMask`

Sets which color channels are written during draw calls. Call with no args to enable all.

```lua
-- signature
lurek.render.setColorMask(r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r?` | `boolean` | Enable red channel. |
| `g?` | `boolean` | Enable green channel. |
| `b?` | `boolean` | Enable blue channel. |
| `a?` | `boolean` | Enable alpha channel. |

**Example**

```lua
do
    lurek.render.setColorMask(true, true, false, true)
    local r, g, b, a = lurek.render.getColorMask()
    print("mask = " .. tostring(r) .. "," .. tostring(g) .. "," .. tostring(b) .. "," .. tostring(a))
    lurek.render.setColorMask()
    print("color mask restored")
end
```

---

### `lurek.render.setDefaultFilter`

Sets the default texture filtering mode for newly created images.

```lua
-- signature
lurek.render.setDefaultFilter(min, mag, anisotropy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min` | `string` | Minification filter: "nearest" or "linear". |
| `mag` | `string` | Magnification filter: "nearest" or "linear". |
| `anisotropy?` | `number` | Anisotropy level (default 1). |

**Example**

```lua
do
    local min_before, mag_before, aniso_before = lurek.render.getDefaultFilter()
    lurek.render.setDefaultFilter("nearest", "nearest", 1)
    local min_after, mag_after, aniso_after = lurek.render.getDefaultFilter()
    print("filter before = " .. min_before .. "," .. mag_before .. "," .. aniso_before)
    print("filter after = " .. min_after .. "," .. mag_after .. "," .. aniso_after)
    lurek.render.setDefaultFilter("linear", "linear", 1)
end
```

---

### `lurek.render.setDefaultFont`

Selects a built-in default font by bundled point size and makes it the active render font.

```lua
-- signature
lurek.render.setDefaultFont(pointSize, bold)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `pointSize?` | `number` | Desired built-in point size. When omitted, reuses the configured default size. |
| `bold?` | `boolean` | When true, selects the bold variant. When omitted, reuses the current bold selection. |

**Returns**

| Type | Description |
|------|-------------|
| `LFont` | The selected built-in font handle. |

**Example**

```lua
do
    local regular = lurek.render.setDefaultFont(10, false)
    local bold = lurek.render.setDefaultFont(10, true)
    lurek.render.setFont(regular)
    print("regular height = " .. regular:getHeight())
    print("bold height = " .. bold:getHeight())
end
```

---

### `lurek.render.setDepthMode`

Sets the depth comparison mode and whether depth writes are enabled.

```lua
-- signature
lurek.render.setDepthMode(mode, write)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | `string` | Compare mode: "always", "never", "less", "lequal", "equal", "notequal", "greater", "gequal". |
| `write?` | `boolean` | Enable depth buffer writes (default false). |

**Example**

```lua
do
    local mode_before, write_before = lurek.render.getDepthMode()
    lurek.render.setDepthMode("lequal", true)
    local mode_after, write_after = lurek.render.getDepthMode()
    print("depth before = " .. mode_before .. "," .. tostring(write_before))
    print("depth after = " .. mode_after .. "," .. tostring(write_after))
    lurek.render.setDepthMode("always", false)
end
```

---

### `lurek.render.setFont`

Sets the active font used by print, printf, and other text rendering calls.

```lua
-- signature
lurek.render.setFont(font)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `font` | `LFont` | Font handle to make active. |

**Example**

```lua
do
    local font = lurek.render.newFont(16)
    lurek.render.setFont(font)
    lurek.render.print("setFont switched active font", 10, 500)
    print("active font exists = " .. tostring(lurek.render.getFont() ~= nil))
    print("setFont tested with built-in font")
end
```

---

### `lurek.render.setFontLineHeight`

Sets the line height override for a font (currently a no-op stub).

```lua
-- signature
lurek.render.setFontLineHeight(font, lh)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `font` | `LFont` | Font handle. |
| `lh` | `number` | Line height value. |

**Example**

```lua
do
    local font = lurek.render.getDefaultFont(14)
    lurek.render.setFontLineHeight(font, 1.2)
    print("setFontLineHeight called with 1.2")
    print("font line height now = " .. lurek.render.getFontLineHeight(font))
end
```

---

### `lurek.render.setLayer`

Sets the active rendering layer by name. Creates the layer if it does not exist.

```lua
-- signature
lurek.render.setLayer(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Layer name to activate. |

**Example**

```lua
do
    lurek.render.newLayer("set_layer_stub", 1)
    lurek.render.setLayer("set_layer_stub")
    print("current layer = " .. lurek.render.currentLayer())
    lurek.render.setLayer("default")
end
```

---

### `lurek.render.setLayerVisible`

Sets whether a named rendering layer is visible.

```lua
-- signature
lurek.render.setLayerVisible(name, visible)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Layer name. |
| `visible` | `boolean` | True to show, false to hide. |

**Example**

```lua
do
    lurek.render.newLayer("visible_layer_stub", 1)
    lurek.render.setLayerVisible("visible_layer_stub", false)
    print("layer visible = " .. tostring(lurek.render.isLayerVisible("visible_layer_stub")))
    lurek.render.setLayerVisible("visible_layer_stub", true)
end
```

---

### `lurek.render.setLayerZOrder`

Sets the z-order value of a named rendering layer.

```lua
-- signature
lurek.render.setLayerZOrder(name, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Layer name. |
| `z` | `number` | New z-order value. |

**Example**

```lua
do
    lurek.render.newLayer("zorder_layer_stub", 1)
    lurek.render.setLayerZOrder("zorder_layer_stub", 9)
    print("layer z order = " .. lurek.render.getLayerZOrder("zorder_layer_stub"))
end
```

---

### `lurek.render.setLineWidth`

Sets the line width for subsequent line-mode draw calls.

```lua
-- signature
lurek.render.setLineWidth(w)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | `number` | Line width in pixels. |

**Example**

```lua
do
    lurek.render.setLineWidth(4)
    lurek.render.line(200, 390, 280, 390)
    print("line width set to 4")
    lurek.render.setLineWidth(1)
    print("line width restored to 1")
end
```

---

### `lurek.render.setPointSize`

Sets the point size for subsequent point draw calls.

```lua
-- signature
lurek.render.setPointSize(size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `size` | `number` | Point diameter in pixels. |

**Example**

```lua
do
    lurek.render.setPointSize(6)
    lurek.render.points(320, 390, 340, 390, 360, 390)
    print("point size set to 6")
    lurek.render.setPointSize(1)
    print("point size restored")
end
```

---

### `lurek.render.setScissor`

Sets or clears the scissor rectangle. Only pixels inside this region are drawn. Call with no args to clear.

```lua
-- signature
lurek.render.setScissor(x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x?` | `number` | Left edge of the scissor rectangle. |
| `y?` | `number` | Top edge. |
| `w?` | `number` | Width. |
| `h?` | `number` | Height. |

**Example**

```lua
do
    lurek.render.setScissor(20, 140, 120, 60)
    local x, y, w, h = lurek.render.getScissor()
    lurek.render.rectangle("fill", 0, 120, 180, 90)
    lurek.render.intersectScissor(50, 150, 70, 30)
    lurek.render.rectangle("line", 0, 120, 180, 90)
    lurek.render.setScissor()
    print("scissor = " .. x .. "," .. y .. "," .. w .. "," .. h)
    print("scissor cleared")
end
```

---

### `lurek.render.setShader`

Activates a shader for subsequent draw calls. Pass nil to restore the default shader.

```lua
-- signature
lurek.render.setShader(shader)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `shader?` | `LShader` | Shader handle to activate, or nil for default. |

**Example**

```lua
do
    local code = "@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); }"
    local shader = lurek.render.newShader(code)
    lurek.render.setShader(shader)
    lurek.render.rectangle("fill", 10, 540, 24, 16)
    print("setShader activated custom shader")
    lurek.render.setShader(nil)
    print("shader restored to default")
    shader:release()
end
```

---

### `lurek.render.setStencilMode`

Sets the stencil write action, compare function, and reference value at once.

```lua
-- signature
lurek.render.setStencilMode(action, compare, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `action` | `string` | Stencil action: "keep", "zero", "replace", "increment", "decrement", etc. |
| `compare?` | `string` | Compare function (default "always"). |
| `value?` | `number` | Reference value (default 0). |

**Example**

```lua
do
    lurek.render.setStencilMode("replace", "always", 2)
    local action, compare, value = lurek.render.getStencilMode()
    print("stencil mode = " .. action .. "," .. compare .. "," .. value)
    lurek.render.clearStencil()
    print("stencil state cleared")
end
```

---

### `lurek.render.setStencilTest`

Configures the stencil comparison test for subsequent draws. Pass nil to disable.

```lua
-- signature
lurek.render.setStencilTest(compare, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `compare?` | `string` | Compare function: "equal", "notequal", "less", "greater", etc. Nil disables. |
| `value?` | `number` | Reference value to compare against (default 1). |

**Example**

```lua
do
    lurek.render.setStencilTest("always", 0)
    lurek.render.circle("fill", 100, 100, 30)
    lurek.render.setStencilTest()
    print("setStencilTest enabled and cleared")
end
```

---

### `lurek.render.setWireframe`

Enables or disables wireframe rendering mode.

```lua
-- signature
lurek.render.setWireframe(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | `boolean` | True for wireframe, false for solid. |

**Example**

```lua
do
    print("wireframe before = " .. tostring(lurek.render.isWireframe()))
    lurek.render.setWireframe(true)
    lurek.render.rectangle("fill", 260, 140, 50, 50)
    lurek.render.setWireframe(false)
    print("wireframe restored = " .. tostring(lurek.render.isWireframe()))
end
```

---

### `lurek.render.shear`

Applies a shear (skew) to the current transformation matrix.

```lua
-- signature
lurek.render.shear(kx, ky)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `kx` | `number` | Horizontal shear factor. |
| `ky` | `number` | Vertical shear factor. |

**Example**

```lua
do
    lurek.render.push()
    lurek.render.translate(180, 80)
    lurek.render.shear(0.3, 0.0)
    lurek.render.rectangle("fill", 0, 0, 70, 30)
    lurek.render.pop()
    print("shear kx = 0.3")
    print("sheared rectangle drawn")
end
```

---

### `lurek.render.stencil`

Begins a stencil write pass with the given action and reference value.

```lua
-- signature
lurek.render.stencil(action, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `action?` | `string` | Stencil action: "replace" (default), "zero", "increment", "decrement", etc. |
| `value?` | `number` | Stencil reference value (default 1). |

**Example**

```lua
do
    lurek.render.stencil("replace", 1)
    lurek.render.circle("fill", 220, 470, 24)
    lurek.render.setStencilTest("equal", 1)
    lurek.render.rectangle("fill", 190, 445, 60, 60)
    lurek.render.setStencilTest()
    print("stencil write value = 1")
    print("stencil test cleared")
end
```

---

### `lurek.render.translate`

Applies a translation to the current transformation matrix.

```lua
-- signature
lurek.render.translate(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | Horizontal translation in pixels. |
| `y` | `number` | Vertical translation in pixels. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    lurek.render.push()
    lurek.render.translate(50, 50)
    lurek.render.draw(image, 0, 0)
    lurek.render.pop()
    print("translation = 50,50")
end
```

---

### `lurek.render.triangle`

Draws a triangle from three vertex positions.

```lua
-- signature
lurek.render.triangle(mode, x1, y1, x2, y2, x3, y3)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | `string` | "fill" or "line". |
| `x1` | `number` | First vertex X. |
| `y1` | `number` | First vertex Y. |
| `x2` | `number` | Second vertex X. |
| `y2` | `number` | Second vertex Y. |
| `x3` | `number` | Third vertex X. |
| `y3` | `number` | Third vertex Y. |

**Example**

```lua
do
    lurek.render.setColor(0.1, 0.7, 0.3, 1)
    lurek.render.triangle("fill", 360, 350, 410, 280, 460, 350)
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.triangle("line", 480, 350, 530, 280, 580, 350)
    print("triangle fill and line drawn")
    print("triangle count = 2")
end
```

---

## LCanvas

### `LCanvas:getDimensions`

Returns both width and height of this canvas.

```lua
-- signature
LCanvas:getDimensions()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Width and height in pixels. |
| `number` | b Width and height in pixels. |

**Example**

```lua
do
    local canvas = lurek.render.newCanvas(128, 64)
    local w, h = canvas:getDimensions()
    print("canvas dimensions = " .. w .. "x" .. h)
    print("canvas type = " .. canvas:type())
    canvas:release()
end
```

---

### `LCanvas:getHeight`

Returns the height of this canvas in pixels.

```lua
-- signature
LCanvas:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Height in pixels. |

**Example**

```lua
do
    local canvas = lurek.render.newCanvas(128, 64)
    print("canvas height = " .. canvas:getHeight())
    print("canvas dimensions = " .. canvas:getWidth() .. "x" .. canvas:getHeight())
    canvas:release()
end
```

---

### `LCanvas:getWidth`

Returns the width of this canvas in pixels.

```lua
-- signature
LCanvas:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Width in pixels. |

**Example**

```lua
do
    local canvas = lurek.render.newCanvas(128, 64)
    print("canvas width = " .. canvas:getWidth())
    print("canvas typeOf LCanvas = " .. tostring(canvas:typeOf("LCanvas")))
    canvas:release()
end
```

---

### `LCanvas:release`

Releases the canvas GPU resource. If this canvas is currently active, drawing reverts to the screen.

```lua
-- signature
LCanvas:release()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the canvas was still valid and was released. |

**Example**

```lua
do
    local canvas = lurek.render.newCanvas(64, 64)
    local released = canvas:release()
    print("canvas released = " .. tostring(released))
    print("canvas release tested")
end
```

---

### `LCanvas:type`

Returns the type name string for this canvas object.

```lua
-- signature
LCanvas:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Always "LCanvas". |

**Example**

```lua
do
    local canvas = lurek.render.newCanvas(64, 64)
    print("canvas type = " .. canvas:type())
    print("is LCanvas = " .. tostring(canvas:typeOf("LCanvas")))
    canvas:release()
end
```

---

### `LCanvas:typeOf`

Checks whether this object matches the given type name.

```lua
-- signature
LCanvas:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to check ("Canvas" or "Object"). |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the name matches. |

**Example**

```lua
do
    local canvas = lurek.render.newCanvas(64, 64)
    print("canvas typeOf LCanvas = " .. tostring(canvas:typeOf("LCanvas")))
    print("canvas typeOf LObject = " .. tostring(canvas:typeOf("LObject")))
    canvas:release()
end
```

---

## LDrawLayer

### `LDrawLayer:clear`

Discards all queued callbacks without executing them.

```lua
-- signature
LDrawLayer:clear()
```

**Example**

```lua
do
    local layer = lurek.render.newDrawLayer()
    layer:queue(1, function() end)
    layer:queue(2, function() end)
    layer:clear()
    print("draw layer count after clear = " .. layer:getCount())
    print("draw layer type = " .. layer:type())
end
```

---

### `LDrawLayer:flush`

Sorts all queued callbacks by z-depth and executes them in order, then empties the layer.

```lua
-- signature
LDrawLayer:flush()
```

**Example**

```lua
do
    local layer = lurek.render.newDrawLayer()
    layer:queue(1.0, function()
        lurek.render.circle("fill", 100, 100, 20)
    end)
    layer:queue(2.0, function()
        lurek.render.circle("fill", 200, 100, 20)
    end)
    print("draw layer count before flush = " .. layer:getCount())
    layer:flush()
    print("draw layer count after flush = " .. layer:getCount())
end
```

---

### `LDrawLayer:getCount`

Returns the number of callbacks currently queued.

```lua
-- signature
LDrawLayer:getCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Queue length. |

**Example**

```lua
do
    local layer = lurek.render.newDrawLayer()
    layer:queue(1.0, function() end)
    layer:queue(2.0, function() end)
    print("draw layer count = " .. layer:getCount())
    layer:clear()
end
```

---

### `LDrawLayer:queue`

Enqueues a draw callback at the given z-depth. Callbacks execute when flush() is called.

```lua
-- signature
LDrawLayer:queue(z, f)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `z` | `number` | Z-depth value used for sorting (lower draws first). |
| `f` | `function` | Callback to invoke during flush. |

**Example**

```lua
do
    local layer = lurek.render.newDrawLayer()
    layer:queue(1.0, function() end)
    layer:queue(2.0, function() end)
    print("draw layer count after queue = " .. layer:getCount())
    layer:clear()
end
```

---

### `LDrawLayer:type`

Returns the type name string for this draw layer.

```lua
-- signature
LDrawLayer:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Always "LDrawLayer". |

**Example**

```lua
do
    local layer = lurek.render.newDrawLayer()
    print("draw layer type = " .. layer:type())
    print("draw layer typeOf LDrawLayer = " .. tostring(layer:typeOf("LDrawLayer")))
end
```

---

### `LDrawLayer:typeOf`

Checks whether this object matches the given type name.

```lua
-- signature
LDrawLayer:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to check ("LDrawLayer", "DrawLayer", or "Object"). |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the name matches. |

**Example**

```lua
do
    local layer = lurek.render.newDrawLayer()
    print("draw layer typeOf LDrawLayer = " .. tostring(layer:typeOf("LDrawLayer")))
    print("draw layer typeOf LObject = " .. tostring(layer:typeOf("LObject")))
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

**Example**

```lua
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 14)
    print("font ascent = " .. font:getAscent())
    print("font descent = " .. font:getDescent())
end
```

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

**Example**

```lua
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 14)
    print("font descent = " .. font:getDescent())
    print("font width of Test = " .. font:getWidth("Test"))
end
```

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

**Example**

```lua
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 14)
    print("font height = " .. font:getHeight())
    print("font line height = " .. font:getLineHeight())
end
```

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

**Example**

```lua
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 14)
    print("font line height = " .. font:getLineHeight())
    print("font ascent = " .. font:getAscent())
end
```

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

**Example**

```lua
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 14)
    print("font width of Hello = " .. font:getWidth("Hello"))
    print("font height = " .. font:getHeight())
end
```

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

**Example**

```lua
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 12)
    local lines, width = font:getWrap("This is a wrapped sentence for the font object.", 120)
    print("wrapped lines = " .. #lines)
    print("wrapped width = " .. width)
end
```

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

**Example**

```lua
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 18)
    print("font released = " .. tostring(font:release()))
    print("font release tested")
end
```

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

**Example**

```lua
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 12)
    font:setLineHeight(1.5)
    print("font line height = " .. font:getLineHeight())
    print("font setLineHeight applied")
end
```

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

**Example**

```lua
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 16)
    print("font type = " .. font:type())
    print("font height = " .. font:getHeight())
    font:release()
end
```

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

**Example**

```lua
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 16)
    print("font typeOf LFont = " .. tostring(font:typeOf("LFont")))
    print("font typeOf LObject = " .. tostring(font:typeOf("LObject")))
    font:release()
end
```

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

---

## LImage

### `LImage:getDimensions`

Returns both width and height of this image.

```lua
-- signature
LImage:getDimensions()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Width and height in pixels. |
| `number` | b Width and height in pixels. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local w, h = image:getDimensions()
    print("image dimensions = " .. w .. "x" .. h)
    print("image type = " .. image:type())
    image:release()
end
```

---

### `LImage:getHeight`

Returns the height of this image in pixels.

```lua
-- signature
LImage:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Height in pixels. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    print("image height = " .. image:getHeight())
    print("image width = " .. image:getWidth())
    image:release()
end
```

---

### `LImage:getId`

Returns the internal numeric handle ID for this image.

```lua
-- signature
LImage:getId()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Opaque image handle identifier. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    print("image id = " .. image:getId())
    print("image type = " .. image:type())
    image:release()
end
```

---

### `LImage:getWidth`

Returns the width of this image in pixels.

```lua
-- signature
LImage:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Width in pixels. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    print("image width = " .. image:getWidth())
    print("image height = " .. image:getHeight())
    image:release()
end
```

---

### `LImage:release`

Releases the GPU memory for this image. The handle becomes invalid after this call.

```lua
-- signature
LImage:release()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the image was still valid and was released. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local released = image:release()
    print("image released = " .. tostring(released))
    print("release tested on LImage")
end
```

---

### `LImage:type`

Returns the type name string for this image object.

```lua
-- signature
LImage:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Always "LImage". |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    print("image type = " .. image:type())
    print("is LImage = " .. tostring(image:typeOf("LImage")))
    image:release()
end
```

---

### `LImage:typeOf`

Checks whether this object matches the given type name.

```lua
-- signature
LImage:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to check ("Image" or "Object"). |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the name matches. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    print("image typeOf LImage = " .. tostring(image:typeOf("LImage")))
    print("image typeOf LObject = " .. tostring(image:typeOf("LObject")))
    image:release()
end
```

---

## LMesh

### `LMesh:getVertex`

Returns the data for a single vertex by 1-based index.

```lua
-- signature
LMesh:getVertex(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | `number` | 1-based vertex index. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | a x, y, u, v, r, g, b, a. |
| `number` | b x, y, u, v, r, g, b, a. |
| `number` | c x, y, u, v, r, g, b, a. |
| `number` | d x, y, u, v, r, g, b, a. |
| `number` | e x, y, u, v, r, g, b, a. |
| `number` | f x, y, u, v, r, g, b, a. |
| `number` | g x, y, u, v, r, g, b, a. |
| `number` | h x, y, u, v, r, g, b, a. |

**Example**

```lua
do
    local mesh = lurek.render.newMesh({
        { 0, 0, 0, 0, 1, 1, 1, 1 },
        { 50, 0, 1, 0, 1, 1, 1, 1 },
        { 25, 40, 0.5, 1, 1, 1, 1, 1 },
    })
    local x, y, u, v, r, g, b, a = mesh:getVertex(2)
    print("mesh v2 = " .. x .. "," .. y .. "," .. u .. "," .. v)
    print("mesh v2 color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

### `LMesh:getVertexCount`

Returns the number of vertices in this mesh.

```lua
-- signature
LMesh:getVertexCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Vertex count. |

**Example**

```lua
do
    local mesh = lurek.render.newMesh({
        { 0, 0, 0, 0, 1, 1, 1, 1 },
        { 100, 0, 1, 0, 1, 1, 1, 1 },
        { 50, 100, 0.5, 1, 1, 1, 1, 1 },
    }, "triangles")
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    mesh:setTexture(image)
    mesh:setVertex(1, { 10, 10, 0.1, 0.1, 1, 0.5, 0.5, 1 })
    print("mesh vertex count = " .. mesh:getVertexCount())
    print("mesh type = " .. mesh:type())
    mesh:release()
end
```

---

### `LMesh:release`

Releases the mesh GPU resource and invalidates the handle.

```lua
-- signature
LMesh:release()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the mesh was valid and was released. |

**Example**

```lua
do
    local mesh = lurek.render.newMesh({
        { 0, 0, 0, 0, 1, 1, 1, 1 },
        { 64, 0, 1, 0, 1, 1, 1, 1 },
        { 64, 64, 1, 1, 1, 1, 1, 1 },
        { 0, 64, 0, 1, 1, 1, 1, 1 },
    }, "fan")
    print("mesh released = " .. tostring(mesh:release()))
    print("mesh release tested")
end
```

---

### `LMesh:setTexture`

Assigns or removes a texture for this mesh. Pass nil to clear the texture.

```lua
-- signature
LMesh:setTexture(image)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `image?` | `LImage` | Image to use as the mesh texture, or nil to remove. |

**Example**

```lua
do
    local mesh = lurek.render.newMesh({
        { 0, 0, 0, 0, 1, 1, 1, 1 },
        { 64, 0, 1, 0, 1, 1, 1, 1 },
        { 64, 64, 1, 1, 1, 1, 1, 1 },
        { 0, 64, 0, 1, 1, 1, 1, 1 },
    }, "fan")
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    mesh:setTexture(image)
    print("mesh texture set from image")
    print("mesh type = " .. mesh:type())
end
```

---

### `LMesh:setVertex`

Updates a single vertex by 1-based index. Table format: {x, y, u, v, r, g, b, a}.

```lua
-- signature
LMesh:setVertex(index, data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | `number` | 1-based vertex index. |
| `data` | `table` | Vertex data: {x, y, u, v, r, g, b, a}. |

**Example**

```lua
do
    local mesh = lurek.render.newMesh({
        { 0, 0, 0, 0, 1, 1, 1, 1 },
        { 50, 0, 1, 0, 1, 1, 1, 1 },
        { 25, 40, 0.5, 1, 1, 1, 1, 1 },
    })
    mesh:setVertex(1, { 10, 10, 0, 0, 1, 0, 0, 1 })
    local x, y, u, v, r, g, b, a = mesh:getVertex(1)
    print("mesh v1 = " .. x .. "," .. y .. "," .. r .. "," .. g .. "," .. b .. "," .. a)
    print("setVertex applied to index 1")
end
```

---

### `LMesh:type`

Returns the type name string for this mesh object.

```lua
-- signature
LMesh:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Always "LMesh". |

**Example**

```lua
do
    local mesh = lurek.render.newMesh({
        { 0, 0, 0, 0, 1, 1, 1, 1 },
        { 64, 0, 1, 0, 1, 1, 1, 1 },
        { 64, 64, 1, 1, 1, 1, 1, 1 },
        { 0, 64, 0, 1, 1, 1, 1, 1 },
    }, "fan")
    print("mesh type = " .. mesh:type())
    print("mesh typeOf LMesh = " .. tostring(mesh:typeOf("LMesh")))
end
```

---

### `LMesh:typeOf`

Checks whether this object matches the given type name.

```lua
-- signature
LMesh:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to check ("Mesh" or "Object"). |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the name matches. |

**Example**

```lua
do
    local mesh = lurek.render.newMesh({
        { 0, 0, 0, 0, 1, 1, 1, 1 },
        { 64, 0, 1, 0, 1, 1, 1, 1 },
        { 64, 64, 1, 1, 1, 1, 1, 1 },
        { 0, 64, 0, 1, 1, 1, 1, 1 },
    }, "fan")
    print("mesh typeOf LMesh = " .. tostring(mesh:typeOf("LMesh")))
    print("mesh typeOf LObject = " .. tostring(mesh:typeOf("LObject")))
end
```

---

## LNineSlice

### `LNineSlice:getInsets`

Returns the border insets (top, right, bottom, left) that define the stretchable regions.

```lua
-- signature
LNineSlice:getInsets()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Top, right, bottom, left inset values. |
| `number` | b Top, right, bottom, left inset values. |
| `number` | c Top, right, bottom, left inset values. |
| `number` | d Top, right, bottom, left inset values. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local slice = lurek.render.newNineSlice(image, 4, 4, 4, 4)
    local top, right, bottom, left = slice:getInsets()
    print("nine-slice insets = " .. top .. "," .. right .. "," .. bottom .. "," .. left)
    print("nine-slice type = " .. slice:type())
    image:release()
end
```

---

### `LNineSlice:getTextureSize`

Returns the pixel dimensions of the underlying source texture.

```lua
-- signature
LNineSlice:getTextureSize()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Width and height in pixels. |
| `number` | b Width and height in pixels. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local slice = lurek.render.newNineSlice(image, 4, 4, 4, 4)
    local w, h = slice:getTextureSize()
    print("nine-slice texture size = " .. w .. "x" .. h)
    print("nine-slice typeOf = " .. tostring(slice:typeOf("LNineSlice")))
    image:release()
end
```

---

### `LNineSlice:type`

Returns the type name of this object.

```lua
-- signature
LNineSlice:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Always "LNineSlice". |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local slice = lurek.render.newNineSlice(image, 4, 4, 4, 4)
    print("nine-slice type = " .. slice:type())
    print("nine-slice texture width = " .. select(1, slice:getTextureSize()))
    image:release()
end
```

---

### `LNineSlice:typeOf`

Checks whether this object matches the given type name.

```lua
-- signature
LNineSlice:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to check ("NineSlice" or "Object"). |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the name matches. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local slice = lurek.render.newNineSlice(image, 2, 2, 2, 2)
    print("nine-slice typeOf LNineSlice = " .. tostring(slice:typeOf("LNineSlice")))
    print("nine-slice typeOf LObject = " .. tostring(slice:typeOf("LObject")))
    image:release()
end
```

---

## LObjModel

### `LObjModel:getFaceCount`

Returns the number of faces (triangles) in this OBJ model.

```lua
-- signature
LObjModel:getFaceCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Face count. |

**Example**

```lua
do
    local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
    print("model face count = " .. model:getFaceCount())
    print("model vertex count = " .. model:getVertexCount())
end
```

---

### `LObjModel:getNormalCount`

Returns the number of vertex normals in this OBJ model.

```lua
-- signature
LObjModel:getNormalCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Normal count. |

**Example**

```lua
do
    local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
    print("model normal count = " .. model:getNormalCount())
    print("model face count = " .. model:getFaceCount())
end
```

---

### `LObjModel:getUvCount`

Returns the number of UV texture coordinates in this OBJ model.

```lua
-- signature
LObjModel:getUvCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | UV coordinate count. |

**Example**

```lua
do
    local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
    print("model uv count = " .. model:getUvCount())
    print("model vertex count = " .. model:getVertexCount())
end
```

---

### `LObjModel:getVertexCount`

Returns the number of vertices in this OBJ model.

```lua
-- signature
LObjModel:getVertexCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Vertex count. |

**Example**

```lua
do
    local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
    print("model vertex count = " .. model:getVertexCount())
    print("model uv count = " .. model:getUvCount())
end
```

---

### `LObjModel:projectToMesh`

Projects the OBJ model into 2D vertex data using a virtual camera, returning a table of vertex rows.

```lua
-- signature
LObjModel:projectToMesh(camera, screenW, screenH)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `camera` | `table` | Camera parameters: {x, y, z, tx, ty, tz, fov}. |
| `screenW` | `number` | Screen width for projection. |
| `screenH` | `number` | Screen height for projection. |

**Returns**

| Type | Description |
|------|-------------|
| `LObjModelProjectToMeshResult` | Array of vertex tables: {{x, y, u, v, r, g, b, a}, ...}. |

**Example**

```lua
do
    local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
    local camera = { x = 0, y = 0, z = -5, tx = 0, ty = 0, tz = 0, fov = 60 }
    local vertices = model:projectToMesh(camera, 320, 240)
    print("projected vertex rows = " .. #vertices)
    print("projectToMesh camera fov = " .. camera.fov)
end
```

---

### `LObjModel:renderToImage`

Renders the OBJ model to a GPU texture at the given resolution with optional 90-degree rotation.

```lua
-- signature
LObjModel:renderToImage(width, height, rotation)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | `number` | Output image width in pixels. |
| `height` | `number` | Output image height in pixels. |
| `rotation?` | `number` | Rotation step (0–3, each step = 90 degrees, default 0). |

**Returns**

| Type | Description |
|------|-------------|
| `LImage` | The rendered image handle. |

**Example**

```lua
do
    local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
    local image = model:renderToImage(64, 64, 0)
    lurek.render.draw(image, 500, 370)
    print("rendered model image = " .. image:getWidth() .. "x" .. image:getHeight())
    print("renderToImage rotation step = 0")
end
```

---

## LQuad

### `LQuad:getTextureDimensions`

Returns the full dimensions of the source texture this quad references.

```lua
-- signature
LQuad:getTextureDimensions()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Source texture width and height. |
| `number` | b Source texture width and height. |

**Example**

```lua
do
    local quad = lurek.render.newQuad(0, 0, 16, 16, 64, 64)
    local w, h = quad:getTextureDimensions()
    print("quad texture dimensions = " .. w .. "x" .. h)
    print("quad type = " .. quad:type())
end
```

---

### `LQuad:getViewport`

Returns the quad's viewport rectangle within the source texture.

```lua
-- signature
LQuad:getViewport()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a x, y, width, height in texture pixels. |
| `number` | b x, y, width, height in texture pixels. |
| `number` | c x, y, width, height in texture pixels. |
| `number` | d x, y, width, height in texture pixels. |

**Example**

```lua
do
    local quad = lurek.render.newQuad(0, 0, 32, 32, 128, 128)
    local x, y, w, h = quad:getViewport()
    print("quad viewport = " .. x .. "," .. y .. "," .. w .. "," .. h)
    print("quad type = " .. quad:type())
end
```

---

### `LQuad:setViewport`

Updates the quad's viewport rectangle.

```lua
-- signature
LQuad:setViewport(x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | Left edge in texture pixels. |
| `y` | `number` | Top edge in texture pixels. |
| `w` | `number` | Width in texture pixels. |
| `h` | `number` | Height in texture pixels. |

**Example**

```lua
do
    local quad = lurek.render.newQuad(0, 0, 16, 16, 128, 128)
    quad:setViewport(0, 0, 32, 32)
    local x, y, w, h = quad:getViewport()
    print("quad viewport after set = " .. x .. "," .. y .. "," .. w .. "," .. h)
end
```

---

### `LQuad:type`

Returns the type name string for this quad object.

```lua
-- signature
LQuad:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Always "LQuad". |

**Example**

```lua
do
    local quad = lurek.render.newQuad(0, 0, 8, 8, 64, 64)
    print("quad type = " .. quad:type())
    print("quad typeOf LQuad = " .. tostring(quad:typeOf("LQuad")))
end
```

---

### `LQuad:typeOf`

Checks whether this object matches the given type name.

```lua
-- signature
LQuad:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to check ("Quad" or "Object"). |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the name matches. |

**Example**

```lua
do
    local quad = lurek.render.newQuad(0, 0, 8, 8, 64, 64)
    print("quad typeOf LQuad = " .. tostring(quad:typeOf("LQuad")))
    print("quad typeOf LObject = " .. tostring(quad:typeOf("LObject")))
end
```

---

## LShader

### `LShader:hasUniform`

Checks whether this shader declares a uniform with the given name.

```lua
-- signature
LShader:hasUniform(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Uniform name to check. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the uniform exists. |

**Example**

```lua
do
    local code = "@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); }"
    local shader = lurek.render.newShader(code)
    print("has u_time before send = " .. tostring(shader:hasUniform("u_time")))
    shader:send("u_time", 0.5)
    print("has u_time after send = " .. tostring(shader:hasUniform("u_time")))
    shader:release()
end
```

---

### `LShader:release`

Releases the shader resource. If active, the default shader is restored.

```lua
-- signature
LShader:release()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the shader was valid and was released. |

**Example**

```lua
do
    local code = "@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); }"
    local shader = lurek.render.newShader(code)
    local released = shader:release()
    print("shader released = " .. tostring(released))
    print("shader release tested")
end
```

---

### `LShader:send`

Sends a uniform value to this shader by name. Supported types: number, boolean, or table (vec2/vec3/vec4).

```lua
-- signature
LShader:send(name, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Uniform variable name declared in the shader. |
| `value` | `number|boolean|table` | The value to send. |

**Example**

```lua
do
    local code = "@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); }"
    local shader = lurek.render.newShader(code)
    print("has u_time before send = " .. tostring(shader:hasUniform("u_time")))
    shader:send("u_time", 1.5)
    print("has u_time after send = " .. tostring(shader:hasUniform("u_time")))
end
```

---

### `LShader:type`

Returns the type name string for this shader object.

```lua
-- signature
LShader:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Always "LShader". |

**Example**

```lua
do
    local code = "@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); }"
    local shader = lurek.render.newShader(code)
    shader:send("u_time", 0.5)
    print("shader type = " .. shader:type())
    print("shader has u_time = " .. tostring(shader:hasUniform("u_time")))
    shader:release()
end
```

---

### `LShader:typeOf`

Checks whether this object matches the given type name.

```lua
-- signature
LShader:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to check ("Shader" or "Object"). |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the name matches. |

**Example**

```lua
do
    local code = "@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); }"
    local shader = lurek.render.newShader(code)
    shader:send("u_time", 0.5)
    print("shader typeOf LShader = " .. tostring(shader:typeOf("LShader")))
    print("shader typeOf LObject = " .. tostring(shader:typeOf("LObject")))
    shader:release()
end
```

---

## LShape

### `LShape:arc`

Adds a filled or outlined arc command to the shape.

```lua
-- signature
LShape:arc(mode, x, y, r, astart, aend, segments)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | `string` | "fill" or "line". |
| `x` | `number` | Center X. |
| `y` | `number` | Center Y. |
| `r` | `number` | Radius. |
| `astart` | `number` | Start angle in radians. |
| `aend` | `number` | End angle in radians. |
| `segments?` | `number` | Number of arc segments (default 32). |

**Example**

```lua
do
    local shape = lurek.render.newShape()
    shape:setColor(1, 0.5, 0, 1)
    shape:arc("fill", 100, 100, 40, 0, math.pi)
    print("shape command count = " .. shape:getCommandCount())
    print("shape arc added")
end
```

---

### `LShape:circle`

Adds a filled or outlined circle command to the shape.

```lua
-- signature
LShape:circle(mode, x, y, r)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | `string` | "fill" or "line". |
| `x` | `number` | Center X. |
| `y` | `number` | Center Y. |
| `r` | `number` | Radius. |

**Example**

```lua
do
    local shape = lurek.render.newShape()
    shape:setColor(0.2, 0.8, 0.4, 1)
    shape:circle("line", 80, 80, 24)
    print("shape command count = " .. shape:getCommandCount())
    print("shape circle added")
end
```

---

### `LShape:clear`

Removes all drawing commands from this shape, making it empty.

```lua
-- signature
LShape:clear()
```

**Example**

```lua
do
    local shape = lurek.render.newShape()
    shape:rectangle("fill", 0, 0, 10, 10)
    shape:circle("fill", 20, 20, 5)
    print("shape commands before clear = " .. shape:getCommandCount())
    shape:clear()
    print("shape commands after clear = " .. shape:getCommandCount())
end
```

---

### `LShape:draw`

Renders the accumulated shape commands to the screen with optional transform.

```lua
-- signature
LShape:draw(x, y, rotation, sx, sy, ox, oy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | X position. |
| `y` | `number` | Y position. |
| `rotation?` | `number` | Rotation in radians (default 0). |
| `sx?` | `number` | Scale X (default 1). |
| `sy?` | `number` | Scale Y (default 1). |
| `ox?` | `number` | Origin offset X (default 0). |
| `oy?` | `number` | Origin offset Y (default 0). |

**Example**

```lua
do
    local shape = lurek.render.newShape()
    shape:setLineWidth(2)
    shape:triangle("line", 0, 0, 50, 0, 25, 50)
    shape:draw(100, 100, 0, 1, 1, 0, 0)
    print("shape command count = " .. shape:getCommandCount())
    print("shape draw called")
end
```

---

### `LShape:ellipse`

Adds an ellipse command to the shape.

```lua
-- signature
LShape:ellipse(mode, x, y, rx, ry)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | `string` | "fill" or "line". |
| `x` | `number` | Center X. |
| `y` | `number` | Center Y. |
| `rx` | `number` | Horizontal radius. |
| `ry` | `number` | Vertical radius. |

**Example**

```lua
do
    local shape = lurek.render.newShape()
    shape:ellipse("fill", 100, 100, 50, 30)
    print("shape command count = " .. shape:getCommandCount())
    print("shape ellipse added")
end
```

---

### `LShape:getCommandCount`

Returns the number of drawing commands accumulated in this shape.

```lua
-- signature
LShape:getCommandCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Command count. |

**Example**

```lua
do
    local shape = lurek.render.newShape()
    shape:circle("fill", 0, 0, 10)
    shape:circle("fill", 50, 50, 10)
    local before = shape:getCommandCount()
    shape:clear()
    local after = shape:getCommandCount()
    print("shape commands before clear = " .. before)
    print("shape commands after clear = " .. after)
end
```

---

### `LShape:line`

Adds a line segment command to the shape.

```lua
-- signature
LShape:line(x1, y1, x2, y2)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x1` | `number` | Start X. |
| `y1` | `number` | Start Y. |
| `x2` | `number` | End X. |
| `y2` | `number` | End Y. |

**Example**

```lua
do
    local shape = lurek.render.newShape()
    shape:line(10, 10, 90, 90)
    print("shape command count = " .. shape:getCommandCount())
    print("shape line added")
end
```

---

### `LShape:polygon`

Adds a polygon command to the shape from a flat list of x,y coordinate pairs.

```lua
-- signature
LShape:polygon(mode, ...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | `string` | "fill" or "line". |
| — | — | @param ... number Flat coordinate values: x1, y1, x2, y2, ... (minimum 3 vertices / 6 values). |

**Example**

```lua
do
    local shape = lurek.render.newShape()
    shape:setColor(0.8, 0.3, 0, 1)
    shape:polygon("fill", 0, 0, 40, -10, 50, 30, 20, 50, -10, 30)
    shape:draw(250, 380)
    print("shape polygon commands = " .. shape:getCommandCount())
    print("shape polygon drawn")
end
```

---

### `LShape:polyline`

Adds a connected polyline command to the shape from a flat list of x,y coordinate pairs.

```lua
-- signature
LShape:polyline(...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| — | — | @param ... number Flat coordinate values: x1, y1, x2, y2, ... (minimum 2 points / 4 values). |

**Example**

```lua
do
    local shape = lurek.render.newShape()
    shape:setLineWidth(3)
    shape:polyline(0, 0, 20, 20, 40, 0, 60, 20)
    shape:draw(330, 380)
    print("shape polyline commands = " .. shape:getCommandCount())
    print("shape polyline drawn")
end
```

---

### `LShape:rectangle`

Adds a rectangle command to the shape.

```lua
-- signature
LShape:rectangle(mode, x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | `string` | "fill" or "line". |
| `x` | `number` | Left edge X. |
| `y` | `number` | Top edge Y. |
| `w` | `number` | Width. |
| `h` | `number` | Height. |

**Example**

```lua
do
    local shape = lurek.render.newShape()
    shape:rectangle("fill", 20, 20, 60, 40)
    print("shape command count = " .. shape:getCommandCount())
    print("shape rectangle added")
end
```

---

### `LShape:roundedRectangle`

Adds a rounded rectangle command to the shape.

```lua
-- signature
LShape:roundedRectangle(mode, x, y, w, h, rx, ry)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | `string` | "fill" or "line". |
| `x` | `number` | Left edge X. |
| `y` | `number` | Top edge Y. |
| `w` | `number` | Width. |
| `h` | `number` | Height. |
| `rx` | `number` | Horizontal corner radius. |
| `ry?` | `number` | Vertical corner radius (defaults to rx). |

**Example**

```lua
do
    local shape = lurek.render.newShape()
    shape:setColor(0.5, 0.5, 1, 1)
    shape:roundedRectangle("line", 0, 0, 70, 36, 8)
    shape:draw(410, 380)
    print("shape rounded rectangle commands = " .. shape:getCommandCount())
    print("shape rounded rectangle drawn")
end
```

---

### `LShape:setColor`

Sets the drawing color for subsequent shape commands.

```lua
-- signature
LShape:setColor(r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | `number` | Red channel (0–1). |
| `g` | `number` | Green channel (0–1). |
| `b` | `number` | Blue channel (0–1). |
| `a?` | `number` | Alpha channel (0–1, default 1). |

**Example**

```lua
do
    local shape = lurek.render.newShape()
    shape:setColor(0.8, 0.2, 0.8, 1)
    shape:rectangle("fill", 0, 0, 20, 20)
    print("shape command count = " .. shape:getCommandCount())
    print("shape color set before rectangle")
end
```

---

### `LShape:setLineWidth`

Sets the line width for subsequent line-mode shape commands.

```lua
-- signature
LShape:setLineWidth(w)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | `number` | Line width in pixels. |

**Example**

```lua
do
    local shape = lurek.render.newShape()
    shape:setLineWidth(2)
    shape:triangle("line", 0, 0, 50, 0, 25, 50)
    print("shape command count = " .. shape:getCommandCount())
    print("shape line width set to 2")
end
```

---

### `LShape:triangle`

Adds a triangle command to the shape.

```lua
-- signature
LShape:triangle(mode, x1, y1, x2, y2, x3, y3)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | `string` | "fill" or "line". |
| `x1` | `number` | First vertex X. |
| `y1` | `number` | First vertex Y. |
| `x2` | `number` | Second vertex X. |
| `y2` | `number` | Second vertex Y. |
| `x3` | `number` | Third vertex X. |
| `y3` | `number` | Third vertex Y. |

**Example**

```lua
do
    local shape = lurek.render.newShape()
    shape:setLineWidth(2)
    shape:triangle("line", 0, 0, 50, 0, 25, 50)
    print("shape command count = " .. shape:getCommandCount())
    print("shape triangle added")
end
```

---

### `LShape:type`

Returns the type name string for this shape object.

```lua
-- signature
LShape:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Always "LShape". |

**Example**

```lua
do
    local shape = lurek.render.newShape()
    print("shape type = " .. shape:type())
    print("shape typeOf LShape = " .. tostring(shape:typeOf("LShape")))
end
```

---

### `LShape:typeOf`

Checks whether this object matches the given type name.

```lua
-- signature
LShape:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to check ("Shape" or "Object"). |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the name matches. |

**Example**

```lua
do
    local shape = lurek.render.newShape()
    print("shape typeOf LShape = " .. tostring(shape:typeOf("LShape")))
    print("shape typeOf LObject = " .. tostring(shape:typeOf("LObject")))
end
```

---

## LSpriteBatch

### `LSpriteBatch:add`

Adds a sprite entry to the batch at the given position with optional transform.

```lua
-- signature
LSpriteBatch:add(x, y, r, sx, sy, ox, oy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | X position. |
| `y` | `number` | Y position. |
| `r?` | `number` | Rotation in radians. |
| `sx?` | `number` | Scale X (default 1). |
| `sy?` | `number` | Scale Y (default 1). |
| `ox?` | `number` | Origin offset X. |
| `oy?` | `number` | Origin offset Y. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Index of the added entry. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local batch = lurek.render.newSpriteBatch(image, 100)
    local id = batch:add(0, 0, 0, 1, 1, 0, 0)
    batch:add(100, 0, 0, 1, 1, 0, 0)
    print("sprite id = " .. tostring(id))
    print("sprite count = " .. batch:getCount())
    batch:release()
end
```

---

### `LSpriteBatch:clear`

Removes all entries from the sprite batch.

```lua
-- signature
LSpriteBatch:clear()
```

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local batch = lurek.render.newSpriteBatch(image, 100)
    batch:add(0, 0, 0, 1, 1, 0, 0)
    batch:add(100, 0, 0, 1, 1, 0, 0)
    batch:clear()
    print("sprite count after clear = " .. batch:getCount())
    print("sprite batch type = " .. batch:type())
    batch:release()
end
```

---

### `LSpriteBatch:getBufferSize`

Returns the maximum number of entries this batch can hold.

```lua
-- signature
LSpriteBatch:getBufferSize()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Buffer capacity. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local batch = lurek.render.newSpriteBatch(image, 100)
    batch:add(0, 0, 0, 1, 1, 0, 0)
    print("sprite batch buffer size = " .. batch:getBufferSize())
    print("sprite batch count = " .. batch:getCount())
    batch:release()
end
```

---

### `LSpriteBatch:getCount`

Returns the number of sprite entries currently in the batch.

```lua
-- signature
LSpriteBatch:getCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Entry count. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local batch = lurek.render.newSpriteBatch(image, 100)
    batch:add(0, 0, 0, 1, 1, 0, 0)
    batch:add(100, 0, 0, 1, 1, 0, 0)
    print("sprite batch count = " .. batch:getCount())
    print("sprite batch typeOf = " .. tostring(batch:typeOf("LSpriteBatch")))
    batch:release()
end
```

---

### `LSpriteBatch:release`

Releases the sprite batch resource.

```lua
-- signature
LSpriteBatch:release()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the batch was valid and was released. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local batch = lurek.render.newSpriteBatch(image, 8)
    local released = batch:release()
    print("batch released = " .. tostring(released))
    print("batch release tested")
end
```

---

### `LSpriteBatch:type`

Returns the type name string for this sprite batch.

```lua
-- signature
LSpriteBatch:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Always "LSpriteBatch". |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local batch = lurek.render.newSpriteBatch(image, 8)
    print("batch type = " .. batch:type())
    print("batch typeOf LSpriteBatch = " .. tostring(batch:typeOf("LSpriteBatch")))
    batch:release()
end
```

---

### `LSpriteBatch:typeOf`

Checks whether this object matches the given type name.

```lua
-- signature
LSpriteBatch:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to check ("SpriteBatch" or "Object"). |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the name matches. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local batch = lurek.render.newSpriteBatch(image, 8)
    print("batch typeOf LSpriteBatch = " .. tostring(batch:typeOf("LSpriteBatch")))
    print("batch typeOf LObject = " .. tostring(batch:typeOf("LObject")))
    batch:release()
end
```

---
