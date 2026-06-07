# Render

## Summary

This module serves as the primary visual execution backend for Lurek2D, orchestrating all deferred draw operations to produce final frame outputs. It establishes a robust 2D rendering pipeline that supports basic vector shapes, dynamically rasterized text, custom vertex meshes, and complex fullscreen post-processing layers. By acting as a central gateway, it unifies diverse presentation requests from scripting and internal systems into a single frame lifecycle.

At the mechanical heart of this pipeline is a device-facing wgpu renderer. This backend translates the engine's high-level command vocabulary into encoded GPU commands, managing pipelines, buffers, and shader attachments. It tessellates shapes like circles, arcs, and rounded rectangles on demand, and maintains separate flat and textured render paths to ensure that color-only operations do not incur unwanted texture overhead.

For structured and high-frequency rendering, the toolkit supports both retained-mode shapes and instanced batches. Retained compound shapes package multiple vector strokes into named assets for fast replay. Sprite batches collect massive sets of identical texture references to draw thousands of particles or tiles in a single draw call. Additionally, off-screen canvases and splat surfaces facilitate layered compositions.

The typography engine bridges raw text assets with GPU-rendered quads. It handles bundled bitmap atlases alongside custom font files dynamically rasterized at runtime. The system tracks precise glyph metrics, atlas placements, and text wraps, ensuring that multi-line formatting remains visually stable. It also supports terminal-style retro symbols and character lookups to accommodate classic user interface grids.

Advanced graphic styling is achieved through custom shader programs. Developers can compile user-authored fragment programs, sending typed parameters such as vectors or textures directly to the GPU. The engine automatically inspects shader inputs to ensure coordinate compatibility, and ordered uniform uploads at the start of each frame, providing a safe, script-driven environment for custom visual filters.

Chained visual finishes are managed by a dedicated post-processing pipeline. By utilizing fullscreen geometry and ping-pong render targets, it applies multi-pass effects like bloom, blur, depth-of-field, color grading, and screen distortion. The pipeline automatically feeds dynamic time, frame count, and resolution variables into the active fragment shaders, degrading gracefully to a direct copy when no treatments are enabled.

For intricate scene layouts, the subsystem exposes fine-grained layering and stencil controls. Z-depth sorted groups schedule draw callbacks in priority order, preventing visual conflicts when enqueuing overlays. The stencil engine configures comparison tests, masks, and write actions, allowing developers to implement circular portals, clipping boundaries, and masked user interface frames with hardware-accelerated precision.

Finally, the module provides a specialized Wavefront OBJ 3D model adapter. This utility projects 3D mesh coordinates through a virtual camera into 2D triangles, drawing detailed silhouettes and animated mesh structures without requiring a full 3D pipeline. It also supports CPU-side software rasterization stubs, allowing tools to generate thumbnails, save screenshots, and gather rendering stats in headless environments.

## Functions

### `lurek.render.applyTransform`

Multiplies the current transformation matrix by a 3x3 matrix (9 values in row-major order).

```lua
lurek.render.applyTransform(mat)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mat` | table | Flat table of 9 numbers representing a 3x3 transform matrix. |

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
lurek.render.arc(mode, x, y, radius, angle1, angle2, segments)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | string | "fill" or "line". |
| `x` | number | Center X. |
| `y` | number | Center Y. |
| `radius` | number | Arc radius. |
| `angle1` | number | Start angle in radians. |
| `angle2` | number | End angle in radians. |
| `segments?` | number | Number of arc segments (default 32). |

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
lurek.render.beginSortGroup(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Group identifier. |

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
lurek.render.captureScreenshot(callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `callback` | function | Called with an [LImageData](#limagedata) argument. |

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
lurek.render.circle(mode, x, y, radius)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | string | "fill" or "line". |
| `x` | number | Center X. |
| `y` | number | Center Y. |
| `radius` | number | Circle radius in pixels. |

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
lurek.render.clear(r, g, b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r?` | number | Unused (reserved for future clear-color override). |
| `g?` | number | Unused. |
| `b?` | number | Unused. |

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
lurek.render.currentLayer()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Active layer name. |

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
lurek.render.draw(drawable, x, y, r, sx, sy, ox, oy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `drawable` | [LImage](#limage)|[LCanvas](#lcanvas)|[LSpriteBatch](#lspritebatch)|[LMesh](#lmesh) | The drawable object to render. |
| `x?` | number | X position (default 0). |
| `y?` | number | Y position (default 0). |
| `r?` | number | Rotation in radians (default 0). |
| `sx?` | number | Scale X (default 1). |
| `sy?` | number | Scale Y (default 1). |
| `ox?` | number | Origin offset X (default 0). |
| `oy?` | number | Origin offset Y (default 0). |

**Returns**

| Type | Description |
|------|-------------|
| nil | No return value. |

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
lurek.render.drawBatch(batch)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `batch` | [LSpriteBatch](#lspritebatch) | Sprite batch handle to draw. |

**Returns**

| Type | Description |
|------|-------------|
| nil | No return value. |

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
lurek.render.drawBevelRect(x, y, w, h, bevelW, style, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Left edge X. |
| `y` | number | Top edge Y. |
| `w` | number | Width (must be positive). |
| `h` | number | Height (must be positive). |
| `bevelW?` | number | Bevel border width (default 2). |
| `style?` | string | Bevel style: "raised" (default), "sunken", "ridge", "groove", "flat". |
| `opts?` | table | Options: highlight, shadow, fillColor (each a {r,g,b,a} table). |

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
lurek.render.drawColoredPolygon(vertices, colors, mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `vertices` | table | Flat array of x,y coordinates: {x1, y1, x2, y2, ...}. |
| `colors` | table | Array of color tables: {{r, g, b, a}, ...}, one per vertex. |
| `mode?` | string | "fill" (default) or "line". |

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
lurek.render.drawCubicBezier(x1, y1, cx1, cy1, cx2, cy2, x2, y2, segments)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x1` | number | Start X. |
| `y1` | number | Start Y. |
| `cx1` | number | First control point X. |
| `cy1` | number | First control point Y. |
| `cx2` | number | Second control point X. |
| `cy2` | number | Second control point Y. |
| `x2` | number | End X. |
| `y2` | number | End Y. |
| `segments?` | number | Number of line segments (default 16). |

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
lurek.render.drawGradientRect(x, y, w, h, c1, c2, dir)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Left edge X. |
| `y` | number | Top edge Y. |
| `w` | number | Width (must be positive). |
| `h` | number | Height (must be positive). |
| `c1` | table | Start color {r, g, b [, a]}. |
| `c2` | table | End color {r, g, b [, a]}. |
| `dir?` | string | Direction: "vertical" (default), "horizontal", "diagDown", "diagUp", "radial". |

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
lurek.render.drawHexTile(cx, cy, size, orientation, mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cx` | number | Center X. |
| `cy` | number | Center Y. |
| `size` | number | Hex radius (must be positive). |
| `orientation?` | string | "pointyTop" (default) or "flatTop". |
| `mode?` | string | "line" (default) or "fill". |

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
lurek.render.drawIsoCubeTile(sx, sy, halfW, halfH, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sx` | number | Screen X position of the tile center. |
| `sy` | number | Screen Y position of the tile center. |
| `halfW` | number | Half-width of the tile diamond. |
| `halfH` | number | Half-height of the tile diamond. |
| `opts?` | table | Options: depth, topColor, leftColor, rightColor, topTexture, leftTexture, rightTexture. |

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
lurek.render.drawMany(list)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `list` | table | Array of draw entry tables. |

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
lurek.render.drawNineSlice(slice, x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `slice` | [LNineSlice](#lnineslice) | The 9-slice handle to draw. |
| `x` | number | Left edge X. |
| `y` | number | Top edge Y. |
| `w` | number | Target width. |
| `h` | number | Target height. |

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
lurek.render.drawPath(path, mode, close)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | table | Array of segment tables, each with a "type" field and coordinates. |
| `mode?` | string | "line" (default) or "fill". |
| `close?` | boolean | Close the path back to start (default false). |

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
lurek.render.drawQuadBezier(x1, y1, cx, cy, x2, y2, segments)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x1` | number | Start X. |
| `y1` | number | Start Y. |
| `cx` | number | Control point X. |
| `cy` | number | Control point Y. |
| `x2` | number | End X. |
| `y2` | number | End Y. |
| `segments?` | number | Number of line segments (default 16). |

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
lurek.render.drawq(image, quad, x, y, r, sx, sy, ox, oy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `image` | [LImage](#limage) | Source image to draw from. |
| `quad` | [LQuad](#lquad) | Quad defining the source rectangle within the image. |
| `x?` | number | X position (default 0). |
| `y?` | number | Y position (default 0). |
| `r?` | number | Rotation in radians (default 0). |
| `sx?` | number | Scale X (default 1). |
| `sy?` | number | Scale Y (default 1). |
| `ox?` | number | Origin offset X (default 0). |
| `oy?` | number | Origin offset Y (default 0). |

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
lurek.render.ellipse(mode, x, y, rx, ry)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | string | "fill" or "line". |
| `x` | number | Center X. |
| `y` | number | Center Y. |
| `rx` | number | Horizontal radius. |
| `ry` | number | Vertical radius. |

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
lurek.render.flushSortGroup(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Group identifier matching the beginSortGroup call. |

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
lurek.render.getBackgroundColor()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Red; green; blue; alpha channels (0â€“1). (value 1). |
| number | Red; green; blue; alpha channels (0â€“1). (value 2). |
| number | Red; green; blue; alpha channels (0â€“1). (value 3). |
| number | Red; green; blue; alpha channels (0â€“1). (value 4). |

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
lurek.render.getBlendMode()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Current blend mode: "alpha", "add", "multiply", "replace", or "screen". |

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
lurek.render.getBuiltInFontNames()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Array of bundled font names such as font_8 and fontb_8. |

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
lurek.render.getCanvas()
```

**Returns**

| Type | Description |
|------|-------------|
| [LCanvas](#lcanvas) | The active canvas handle. |

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
lurek.render.getCanvasSize(canvas)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `canvas` | [LCanvas](#lcanvas) | Canvas handle to query. |

**Returns**

| Type | Description |
|------|-------------|
| number | Width and height in pixels. (value 1). |
| number | Width and height in pixels. (value 2). |

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
lurek.render.getColor()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Red; green; blue; alpha channels (0â€“1). (value 1). |
| number | Red; green; blue; alpha channels (0â€“1). (value 2). |
| number | Red; green; blue; alpha channels (0â€“1). (value 3). |
| number | Red; green; blue; alpha channels (0â€“1). (value 4). |

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
lurek.render.getColorMask()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | Red; green; blue; alpha channel write states. (value 1). |
| boolean | Red; green; blue; alpha channel write states. (value 2). |
| boolean | Red; green; blue; alpha channel write states. (value 3). |
| boolean | Red; green; blue; alpha channel write states. (value 4). |

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
lurek.render.getDefaultFilter()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Min filter; mag filter; anisotropy level. (value 1). |
| string | Min filter; mag filter; anisotropy level. (value 2). |
| number | Min filter; mag filter; anisotropy level. (value 3). |

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
lurek.render.getDefaultFont(pointSize, bold)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `pointSize?` | number | Desired built-in point size. When omitted, returns the current configured default. |
| `bold?` | boolean | When true, returns the bold variant. When omitted, uses the current bold selection. |

**Returns**

| Type | Description |
|------|-------------|
| [LFont](#lfont) | The built-in font handle. |

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
lurek.render.getDepthMode()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Depth mode name and whether depth writes are enabled. (value 1). |
| boolean | Depth mode name and whether depth writes are enabled. (value 2). |

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
lurek.render.getDimensions()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width and height in pixels. (value 1). |
| number | Width and height in pixels. (value 2). |

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
lurek.render.getFont()
```

**Returns**

| Type | Description |
|------|-------------|
| [LFont](#lfont) | The active font handle. |

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
lurek.render.getFontAscent(font)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `font` | [LFont](#lfont) | Font handle to query. |

**Returns**

| Type | Description |
|------|-------------|
| number | Ascent in pixels. |

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
lurek.render.getFontCellWidth(font)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `font` | [LFont](#lfont) | Font handle to query. |

**Returns**

| Type | Description |
|------|-------------|
| number | Cell width in pixels. |

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
lurek.render.getFontDescent(font)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `font` | [LFont](#lfont) | Font handle to query. |

**Returns**

| Type | Description |
|------|-------------|
| number | Descent in pixels. |

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
lurek.render.getFontHeight(font)
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
    local font = lurek.render.getDefaultFont(14)
    print("font height = " .. lurek.render.getFontHeight(font))
    print("font line height = " .. lurek.render.getFontLineHeight(font))
end
```

---

### `lurek.render.getFontLineHeight`

Returns the line spacing of the given font.

```lua
lurek.render.getFontLineHeight(font)
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
    local font = lurek.render.getDefaultFont(14)
    print("font line height = " .. lurek.render.getFontLineHeight(font))
    print("line width = " .. lurek.render.getLineWidth())
end
```

---

### `lurek.render.getFontSizes`

Returns all available built-in point sizes.

```lua
lurek.render.getFontSizes()
```

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array of bundled font sizes such as 8, 10, 12, 16, 20, 24, and 30. |

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
lurek.render.getFontWidth(font, text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `font` | [LFont](#lfont) | Font handle to measure with. |
| `text` | string | Text to measure. |

**Returns**

| Type | Description |
|------|-------------|
| number | Width in pixels. |

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
lurek.render.getFontWrap(text, limit)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | string | Text to wrap. |
| `limit` | number | Maximum line width in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | Wrapped lines as a table when a font is active; or nil otherwise; followed by the widest line width. (value 1). |
| number | Wrapped lines as a table when a font is active; or nil otherwise; followed by the widest line width. (value 2). |

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
lurek.render.getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Window height. |

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
lurek.render.getLayerZOrder(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Layer name. |

**Returns**

| Type | Description |
|------|-------------|
| number | Z-order value (default 0 if unset). |

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
lurek.render.getLineWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Line width in pixels. |

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
lurek.render.getPointSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Point diameter in pixels. |

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
lurek.render.getScissor()
```

**Returns**

| Type | Description |
|------|-------------|
| number | x; y; w; h of the scissor rect (empty if none). (value 1). |
| number | x; y; w; h of the scissor rect (empty if none). (value 2). |
| number | x; y; w; h of the scissor rect (empty if none). (value 3). |
| number | x; y; w; h of the scissor rect (empty if none). (value 4). |

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
lurek.render.getShader()
```

**Returns**

| Type | Description |
|------|-------------|
| [LShader](#lshader) | The active shader handle. |

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
lurek.render.getStats()
```

**Returns**

| Type | Description |
|------|-------------|
| LRenderGetStatsResult | Stats table with rendering counters. |

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
lurek.render.getStencilMode()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Action name; compare mode name; and reference value. (value 1). |
| string | Action name; compare mode name; and reference value. (value 2). |
| number | Action name; compare mode name; and reference value. (value 3). |

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
lurek.render.getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Window width. |

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
lurek.render.intersectScissor(x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Left edge. |
| `y` | number | Top edge. |
| `w` | number | Width. |
| `h` | number | Height. |

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
lurek.render.isBold()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when bold is active. |

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
lurek.render.isLayerVisible(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Layer name. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the layer is visible. |

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
lurek.render.isWireframe()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if wireframe mode is on. |

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
lurek.render.loadModel(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | File path to the model file relative to the game directory. |

**Returns**

| Type | Description |
|------|-------------|
| [LObjModel](#lobjmodel) | The loaded model handle. |

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
lurek.render.loadObj(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | File path to the .obj file relative to the game directory. |

**Returns**

| Type | Description |
|------|-------------|
| [LObjModel](#lobjmodel) | The loaded OBJ model handle. |

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
lurek.render.newCanvas(width, height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | number | Canvas width in pixels (must be > 0). |
| `height` | number | Canvas height in pixels (must be > 0). |

**Returns**

| Type | Description |
|------|-------------|
| [LCanvas](#lcanvas) | The created canvas handle. |

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

Registers the depth-sorted drawing helper constructor in the render module.

```lua
lurek.render.newDepthSorter()
```

**Returns**

| Type | Description |
|------|-------------|
| [LDepthSorter](#ldepthsorter) | A fresh depth sorter with no queued entries. |

**Example**

```lua
do
    local sorter = lurek.render.newDepthSorter()
    sorter:add(function() print("draw layer A") end, 10)
    sorter:add(function() print("draw layer B") end, 5)
    sorter:flush()
    print("depth sorter type = " .. sorter:type())
end
```

---

### `lurek.render.newDrawLayer`

Creates a new z-ordered draw layer for sorting draw callbacks by depth.

```lua
lurek.render.newDrawLayer()
```

**Returns**

| Type | Description |
|------|-------------|
| [LDrawLayer](#ldrawlayer) | The created draw layer. |

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
lurek.render.newFont(pathOrSize, size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `pathOrSize` | any | Built-in font name, font file path, or numeric built-in point-size selector. |
| `size?` | number | Point size for TTF/OTF files, or cell height for PNG atlases. |

**Returns**

| Type | Description |
|------|-------------|
| [LFont](#lfont) | The created font handle. |

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
lurek.render.newImage(pathOrData, colorSpace)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `pathOrData` | string|[LImageData](#limagedata) | File path to an image, or an ImageData object. |
| `colorSpace?` | string | Color space: "srgb" (default) or "linear". |

**Returns**

| Type | Description |
|------|-------------|
| [LImage](#limage) | The loaded image handle. |

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
lurek.render.newLayer(name, zOrder)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Layer name. |
| `zOrder?` | number | Z-order for layer sorting (default 0). |

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
lurek.render.newMesh(verts, mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `verts` | table | Array of vertex tables: {{x, y, u, v, r, g, b, a}, ...}. |
| `mode?` | string | Draw mode: "triangles" (default), "fan", or "strip". |

**Returns**

| Type | Description |
|------|-------------|
| [LMesh](#lmesh) | The created mesh handle. |

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
lurek.render.newNineSlice(image, top, right, bottom, left)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `image` | [LImage](#limage) | Source texture. |
| `top` | number | Top border inset in pixels. |
| `right` | number | Right border inset. |
| `bottom` | number | Bottom border inset. |
| `left` | number | Left border inset. |

**Returns**

| Type | Description |
|------|-------------|
| [LNineSlice](#lnineslice) | The 9-slice handle. |

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
lurek.render.newQuad(x, y, w, h, sw, sh)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Left edge in texture pixels. |
| `y` | number | Top edge in texture pixels. |
| `w` | number | Width in texture pixels. |
| `h` | number | Height in texture pixels. |
| `sw` | number | Full source texture width. |
| `sh` | number | Full source texture height. |

**Returns**

| Type | Description |
|------|-------------|
| [LQuad](#lquad) | The created quad. |

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
lurek.render.newShader(code)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `code` | string | WGSL shader source code. |

**Returns**

| Type | Description |
|------|-------------|
| [LShader](#lshader) | The compiled shader handle. |

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
lurek.render.newShape()
```

**Returns**

| Type | Description |
|------|-------------|
| [LShape](#lshape) | The created shape handle. |

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
lurek.render.newSpriteBatch(image, max)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `image` | [LImage](#limage) | Source texture for all sprites in the batch. |
| `max?` | number | Maximum number of entries (default 1000). |

**Returns**

| Type | Description |
|------|-------------|
| [LSpriteBatch](#lspritebatch) | The created sprite batch handle. |

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
lurek.render.polygon(mode, ...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | string | "fill" or "line". |
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
lurek.render.popLayer(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Layer identifier matching the pushLayer call. |

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
lurek.render.print(text, x, y, scale)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | string | Text to render. |
| `x?` | number | X position (default 0). |
| `y?` | number | Y position (default 0). |
| `scale?` | number | Text scale factor (default 1). |

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
lurek.render.printRich(spans, x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `spans` | table | Array of span tables, each with fields: text, r, g, b, a, scale. |
| `x` | number | X position. |
| `y` | number | Y position. |

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
lurek.render.printRichWithFont(font, spans, x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `font` | [LFont](#lfont) | Font handle to use for this draw. |
| `spans` | table | Array of span tables, each with fields: text, r, g, b, a, scale. |
| `x` | number | X position. |
| `y` | number | Y position. |

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
lurek.render.printRotated(text, x, y, angle, scale)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | string | Text to render. |
| `x` | number | Center X position. |
| `y` | number | Center Y position. |
| `angle` | number | Rotation angle in radians. |
| `scale?` | number | Text scale factor (default 1). |

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
lurek.render.printRotatedWithFont(font, text, x, y, angle, scale)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `font` | [LFont](#lfont) | Font handle to use for this draw. |
| `text` | string | Text to render. |
| `x` | number | Center X position. |
| `y` | number | Center Y position. |
| `angle` | number | Rotation angle in radians. |
| `scale?` | number | Text scale factor (default 1). |

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
lurek.render.printWithFont(font, text, x, y, scale)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `font` | [LFont](#lfont) | Font handle to use for this draw. |
| `text` | string | Text to render. |
| `x?` | number | X position (default 0). |
| `y?` | number | Y position (default 0). |
| `scale?` | number | Text scale factor (default 1). |

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
lurek.render.printf(text, x, y, limit, align)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | string | Text to render. |
| `x` | number | X position. |
| `y` | number | Y position. |
| `limit` | number | Maximum line width in pixels for wrapping. |
| `align?` | string | Alignment: "left" (default), "center", "right", or "justify". |

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
lurek.render.printfWithFont(font, text, x, y, limit, align)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `font` | [LFont](#lfont) | Font handle to use for this draw. |
| `text` | string | Text to render. |
| `x` | number | X position. |
| `y` | number | Y position. |
| `limit` | number | Maximum line width in pixels for wrapping. |
| `align?` | string | Alignment: "left" (default), "center", "right", or "justify". |

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
lurek.render.pushLayer(id, alpha, blendMode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Layer identifier (must match the popLayer call). |
| `alpha?` | number | Layer opacity (0â€“1, default 1). |
| `blendMode?` | string | Blend mode: "alpha" (default), "add", "multiply", "replace", "screen". |

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
lurek.render.pushSortKey(depth)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `depth` | number | Sort depth value (lower draws first). |

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
lurek.render.rectangle(mode, x, y, w, h, rx, ry)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | string | "fill" or "line". |
| `x` | number | Left edge X. |
| `y` | number | Top edge Y. |
| `w` | number | Width. |
| `h` | number | Height. |
| `rx?` | number | Horizontal corner radius for rounded rectangle. |
| `ry?` | number | Vertical corner radius (defaults to rx). |

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
lurek.render.resetCanvas(canvas)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `canvas` | [LCanvas](#lcanvas) | Canvas to reset. |

**Returns**

| Type | Description |
|------|-------------|
| nil | No return value. |

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
lurek.render.rotate(angle)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `angle` | number | Rotation angle in radians. |

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
lurek.render.saveScreenshot(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | Output path (must start with "save/"). |

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
lurek.render.scale(sx, sy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sx` | number | Horizontal scale factor. |
| `sy?` | number | Vertical scale factor (defaults to sx for uniform scaling). |

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
lurek.render.setBackgroundColor(r, g, b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | number | Red channel (0â€“1). |
| `g` | number | Green channel (0â€“1). |
| `b` | number | Blue channel (0â€“1). |

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
lurek.render.setBlendMode(mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | string | One of: "alpha", "add", "multiply", "replace", "screen". |

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
lurek.render.setBold(bold)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bold` | boolean | True to enable bold, false for regular. |

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
lurek.render.setCanvas(canvas)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `canvas?` | [LCanvas](#lcanvas) | Canvas to draw to, or nil for the main screen. |

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
lurek.render.setColor(r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | number | Red channel (0â€“1). |
| `g` | number | Green channel (0â€“1). |
| `b` | number | Blue channel (0â€“1). |
| `a?` | number | Alpha channel (0â€“1, default 1). |

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
lurek.render.setColorMask(r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r?` | boolean | Enable red channel. |
| `g?` | boolean | Enable green channel. |
| `b?` | boolean | Enable blue channel. |
| `a?` | boolean | Enable alpha channel. |

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
lurek.render.setDefaultFilter(min, mag, anisotropy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min` | string | Minification filter: "nearest" or "linear". |
| `mag` | string | Magnification filter: "nearest" or "linear". |
| `anisotropy?` | number | Anisotropy level (default 1). |

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
lurek.render.setDefaultFont(pointSize, bold)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `pointSize?` | number | Desired built-in point size. When omitted, reuses the configured default size. |
| `bold?` | boolean | When true, selects the bold variant. When omitted, reuses the current bold selection. |

**Returns**

| Type | Description |
|------|-------------|
| [LFont](#lfont) | The selected built-in font handle. |

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
lurek.render.setDepthMode(mode, write)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | string | Compare mode: "always", "never", "less", "lequal", "equal", "notequal", "greater", "gequal". |
| `write?` | boolean | Enable depth buffer writes (default false). |

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
lurek.render.setFont(font)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `font` | [LFont](#lfont) | Font handle to make active. |

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
lurek.render.setFontLineHeight(font, lh)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `font` | [LFont](#lfont) | Font handle. |
| `lh` | number | Line height value. |

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
lurek.render.setLayer(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Layer name to activate. |

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
lurek.render.setLayerVisible(name, visible)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Layer name. |
| `visible` | boolean | True to show, false to hide. |

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
lurek.render.setLayerZOrder(name, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Layer name. |
| `z` | number | New z-order value. |

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
lurek.render.setLineWidth(w)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | number | Line width in pixels. |

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
lurek.render.setPointSize(size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `size` | number | Point diameter in pixels. |

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
lurek.render.setScissor(x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x?` | number | Left edge of the scissor rectangle. |
| `y?` | number | Top edge. |
| `w?` | number | Width. |
| `h?` | number | Height. |

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
lurek.render.setShader(shader)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `shader?` | [LShader](#lshader) | Shader handle to activate, or nil for default. |

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
lurek.render.setStencilMode(action, compare, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `action` | string | Stencil action: "keep", "zero", "replace", "increment", "decrement", etc. |
| `compare?` | string | Compare function (default "always"). |
| `value?` | number | Reference value (default 0). |

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
lurek.render.setStencilTest(compare, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `compare?` | string | Compare function: "equal", "notequal", "less", "greater", etc. Nil disables. |
| `value?` | number | Reference value to compare against (default 1). |

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
lurek.render.setWireframe(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | boolean | True for wireframe, false for solid. |

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
lurek.render.shear(kx, ky)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `kx` | number | Horizontal shear factor. |
| `ky` | number | Vertical shear factor. |

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
lurek.render.stencil(action, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `action?` | string | Stencil action: "replace" (default), "zero", "increment", "decrement", etc. |
| `value?` | number | Stencil reference value (default 1). |

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
lurek.render.translate(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Horizontal translation in pixels. |
| `y` | number | Vertical translation in pixels. |

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
lurek.render.triangle(mode, x1, y1, x2, y2, x3, y3)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | string | "fill" or "line". |
| `x1` | number | First vertex X. |
| `y1` | number | First vertex Y. |
| `x2` | number | Second vertex X. |
| `y2` | number | Second vertex Y. |
| `x3` | number | Third vertex X. |
| `y3` | number | Third vertex Y. |

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

## Module Fields

*No module-level fields documented.*

## Callbacks

- `lurek.render.captureScreenshot` param `callback` (`function`): Called with an LImageData argument.

## Enums

*No module-specific enums documented.*

## Types

- [LCanvas](#lcanvas)
- [LDepthSorter](#ldepthsorter)
- [LDrawLayer](#ldrawlayer)
- [LFont](#lfont)
- [LImage](#limage)
- [LImageData](#limagedata)
- [LMesh](#lmesh)
- [LNineSlice](#lnineslice)
- [LObjModel](#lobjmodel)
- [LQuad](#lquad)
- [LShader](#lshader)
- [LShape](#lshape)
- [LSpriteBatch](#lspritebatch)

## LCanvas

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LCanvas:getDimensions`

Returns both width and height of this canvas.

```lua
LCanvas:getDimensions()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width and height in pixels. (value 1). |
| number | Width and height in pixels. (value 2). |

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

#### `LCanvas:getHeight`

Returns the height of this canvas in pixels.

```lua
LCanvas:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Height in pixels. |

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

#### `LCanvas:getWidth`

Returns the width of this canvas in pixels.

```lua
LCanvas:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width in pixels. |

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

#### `LCanvas:release`

Releases the canvas GPU resource. If this canvas is currently active, drawing reverts to the screen.

```lua
LCanvas:release()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the canvas was still valid and was released. |

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

#### `LCanvas:type`

Returns the type name string for this canvas object.

```lua
LCanvas:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always "[LCanvas](#lcanvas)". |

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

#### `LCanvas:typeOf`

Checks whether this object matches the given type name.

```lua
LCanvas:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check ("Canvas" or "Object"). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the name matches. |

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

## LDepthSorter

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LDepthSorter:add`

Register a draw callback at a given depth value. When `flush` is called, all registered callbacks execute in back-to-front order (lowest depth drawn first, highest depth drawn last / on top). Use this for simple draw calls like sprite rendering where each entity has a depth/z-layer.

```lua
LDepthSorter:add(callback, depth)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `callback` | function | A zero-argument draw function invoked during flush. |
| `depth` | number | Numeric z-depth controlling draw order â€” lower values are drawn behind higher values. |

---

#### `LDepthSorter:addObject`

Register a game object table for depth-sorted rendering. The object must expose a numeric `depth` field and a `drawSorted(self)` method. During `flush`, each object's `drawSorted` is called in depth order, making this ideal for entity-based architectures where objects manage their own drawing.

```lua
LDepthSorter:addObject(obj)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `obj` | table | A game object table with a numeric `depth` field and a `drawSorted(self)` method. |

---

#### `LDepthSorter:clear`

Discard all pending entries without executing any draw callbacks. Use this when a scene is interrupted, reset, or destroyed before its normal `flush` call.

```lua
LDepthSorter:clear()
```

---

#### `LDepthSorter:flush`

Sort all entries by depth, execute every callback or object's `drawSorted` method in back-to-front order, then clear the sorter for the next frame. This is the standard one-call render path â€” call it once per frame inside your scene's `draw` or `render` callback.

```lua
LDepthSorter:flush()
```

---

#### `LDepthSorter:getCount`

Returns the number of draw entries currently queued for the next `flush` call. Useful for debugging or deciding whether to skip an empty render pass.

```lua
LDepthSorter:getCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Count of pending draw entries. |

---

#### `LDepthSorter:isStable`

Returns whether the sorter uses stable sorting.

```lua
LDepthSorter:isStable()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if stable sort is enabled. |

---

#### `LDepthSorter:setStable`

Enable or disable stable sorting. When stable, items sharing the same depth value retain their insertion order, which prevents visual flickering between overlapping sprites at the same layer. Unstable sort is slightly faster but may swap equal-depth items between frames.

```lua
LDepthSorter:setStable(stable)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `stable` | boolean | True for stable sort (deterministic order at equal depth), false for unstable (faster but may flicker). |

---

#### `LDepthSorter:sort`

Sort all registered entries by depth without executing any callbacks. Call this only if you need to inspect the sorted order before drawing; `flush` already sorts automatically.

```lua
LDepthSorter:sort()
```

---

#### `LDepthSorter:type`

Returns the type name string `"[LDepthSorter](#ldepthsorter)"`.

```lua
LDepthSorter:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The literal `"[LDepthSorter](#ldepthsorter)"`. |

---

#### `LDepthSorter:typeOf`

Check whether this object matches a given type name. Accepts `"[LDepthSorter](#ldepthsorter)"` or `"Object"`.

```lua
LDepthSorter:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | The type name to test against. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the name matches. |

---

## LDrawLayer

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LDrawLayer:clear`

Discards all queued callbacks without executing them.

```lua
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

#### `LDrawLayer:flush`

Sorts all queued callbacks by z-depth and executes them in order, then empties the layer.

```lua
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

#### `LDrawLayer:getCount`

Returns the number of callbacks currently queued.

```lua
LDrawLayer:getCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Queue length. |

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

#### `LDrawLayer:queue`

Enqueues a draw callback at the given z-depth. Callbacks execute when flush() is called.

```lua
LDrawLayer:queue(z, f)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `z` | number | Z-depth value used for sorting (lower draws first). |
| `f` | function | Callback to invoke during flush. |

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

#### `LDrawLayer:type`

Returns the type name string for this draw layer.

```lua
LDrawLayer:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always "[LDrawLayer](#ldrawlayer)". |

**Example**

```lua
do
    local layer = lurek.render.newDrawLayer()
    print("draw layer type = " .. layer:type())
    print("draw layer typeOf LDrawLayer = " .. tostring(layer:typeOf("LDrawLayer")))
end
```

---

#### `LDrawLayer:typeOf`

Checks whether this object matches the given type name.

```lua
LDrawLayer:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check ("[LDrawLayer](#ldrawlayer)", "DrawLayer", or "Object"). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the name matches. |

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

**Example**

```lua
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 14)
    print("font ascent = " .. font:getAscent())
    print("font descent = " .. font:getDescent())
end
```

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

**Example**

```lua
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 14)
    print("font descent = " .. font:getDescent())
    print("font width of Test = " .. font:getWidth("Test"))
end
```

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

**Example**

```lua
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 14)
    print("font height = " .. font:getHeight())
    print("font line height = " .. font:getLineHeight())
end
```

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

**Example**

```lua
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 14)
    print("font line height = " .. font:getLineHeight())
    print("font ascent = " .. font:getAscent())
end
```

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

**Example**

```lua
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 14)
    print("font width of Hello = " .. font:getWidth("Hello"))
    print("font height = " .. font:getHeight())
end
```

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

#### `LFont:isBold`

Returns whether this font is the bold variant. This method is available to Lua scripts.

```lua
LFont:isBold()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if font style is bold. |

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

**Example**

```lua
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 18)
    print("font released = " .. tostring(font:release()))
    print("font release tested")
end
```

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

#### `LFont:type`

Returns the type name string for this font object.

```lua
LFont:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always "[LFont](#lfont)". |

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

---

## LImage

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LImage:getDimensions`

Returns both width and height of this image.

```lua
LImage:getDimensions()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width and height in pixels. (value 1). |
| number | Width and height in pixels. (value 2). |

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

#### `LImage:getHeight`

Returns the height of this image in pixels.

```lua
LImage:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Height in pixels. |

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

#### `LImage:getId`

Returns the internal numeric handle ID for this image.

```lua
LImage:getId()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Opaque image handle identifier. |

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

#### `LImage:getWidth`

Returns the width of this image in pixels.

```lua
LImage:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width in pixels. |

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

#### `LImage:release`

Releases the GPU memory for this image. The handle becomes invalid after this call.

```lua
LImage:release()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the image was still valid and was released. |

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

#### `LImage:type`

Returns the type name string for this image object.

```lua
LImage:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always "[LImage](#limage)". |

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

#### `LImage:typeOf`

Checks whether this object matches the given type name.

```lua
LImage:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check ("Image" or "Object"). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the name matches. |

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

## LImageData

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LImageData:alphaMask`

Multiplies this image alpha channel by a factor in place.

```lua
LImageData:alphaMask(factor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `factor` | number | Alpha multiplier. |

---

#### `LImageData:applyPaletteLut`

Applies a palette lookup table to this image in place.

```lua
LImageData:applyPaletteLut(lut_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `lut_ud` | [LPaletteLUT](image.md#lpalettelut) | Palette lookup table handle. |

---

#### `LImageData:blit`

Copies a source image into this image at a destination coordinate.

```lua
LImageData:blit(src_ud, dst_x, dst_y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `src_ud` | [LImageData](#limagedata) | Source image data handle. |
| `dst_x` | number | Destination x coordinate. |
| `dst_y` | number | Destination y coordinate. |

---

#### `LImageData:blur`

Returns a blurred copy of this image.

```lua
LImageData:blur(radius)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `radius` | number | Blur radius. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Blurred image data handle. |

---

#### `LImageData:brightness`

Applies a brightness factor to this image in place.

```lua
LImageData:brightness(factor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `factor` | number | Brightness multiplier or adjustment factor. |

---

#### `LImageData:contrast`

Applies a contrast factor to this image in place.

```lua
LImageData:contrast(factor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `factor` | number | Contrast factor. |

---

#### `LImageData:convolve`

Applies a convolution kernel and returns the filtered image.

```lua
LImageData:convolve(kernel_t, ksize)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `kernel_t` | table | Array table of numeric kernel weights. |
| `ksize` | number | Kernel width and height. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Convolved image data handle. |

---

#### `LImageData:crop`

Returns a cropped image region. This method is available to Lua scripts.

```lua
LImageData:crop(x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Source x coordinate. |
| `y` | number | Source y coordinate. |
| `w` | number | Crop width. |
| `h` | number | Crop height. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Cropped image data handle. |

---

#### `LImageData:diff`

Computes a difference metric against another image.

```lua
LImageData:diff(other_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other_ud` | [LImageData](#limagedata) | Image data handle to compare with this image. |

**Returns**

| Type | Description |
|------|-------------|
| number | Difference score. |

---

#### `LImageData:drawCircle`

Draws a filled circle into this image.

```lua
LImageData:drawCircle(cx, cy, radius, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cx` | number | Circle center x coordinate. |
| `cy` | number | Circle center y coordinate. |
| `radius` | number | Circle radius. |
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a` | number | Alpha channel. |

---

#### `LImageData:drawLine`

Draws a line into this image. This method is available to Lua scripts.

```lua
LImageData:drawLine(x0, y0, x1, y1, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x0` | number | Start x coordinate. |
| `y0` | number | Start y coordinate. |
| `x1` | number | End x coordinate. |
| `y1` | number | End y coordinate. |
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a` | number | Alpha channel. |

---

#### `LImageData:drawNineSlice`

Draws a nine-slice region from a source image into this image.

```lua
LImageData:drawNineSlice(src_ud, src_x, src_y, src_w, src_h, dst_x, dst_y, dst_w, dst_h, inset_left, inset_right, inset_top, inset_bottom)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `src_ud` | [LImageData](#limagedata) | Source image data handle. |
| `src_x` | number | Source region x coordinate. |
| `src_y` | number | Source region y coordinate. |
| `src_w` | number | Source region width. |
| `src_h` | number | Source region height. |
| `dst_x` | number | Destination x coordinate. |
| `dst_y` | number | Destination y coordinate. |
| `dst_w` | number | Destination width. |
| `dst_h` | number | Destination height. |
| `inset_left` | number | Left inset width. |
| `inset_right` | number | Right inset width. |
| `inset_top` | number | Top inset height. |
| `inset_bottom` | number | Bottom inset height. |

---

#### `LImageData:drawRect`

Draws a filled rectangle into this image.

```lua
LImageData:drawRect(x, y, w, h, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Rectangle x coordinate. |
| `y` | number | Rectangle y coordinate. |
| `w` | number | Rectangle width. |
| `h` | number | Rectangle height. |
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a` | number | Alpha channel. |

---

#### `LImageData:encode`

Encodes image data in a supported format.

```lua
LImageData:encode(format)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `format` | string | Format name; currently `png`. |

**Returns**

| Type | Description |
|------|-------------|
| string | Encoded image bytes. |

---

#### `LImageData:fill`

Fills the whole image with one RGBA color.

```lua
LImageData:fill(r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a` | number | Alpha channel. |

---

#### `LImageData:flipHorizontal`

Flips this image horizontally in place.

```lua
LImageData:flipHorizontal()
```

---

#### `LImageData:flipVertical`

Flips this image vertically in place.

```lua
LImageData:flipVertical()
```

---

#### `LImageData:gamma`

Applies gamma correction to this image in place.

```lua
LImageData:gamma(gamma)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `gamma` | number | Gamma value. |

---

#### `LImageData:getDimensions`

Returns image dimensions. This method is available to Lua scripts.

```lua
LImageData:getDimensions()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width in pixels. |
| number | Height in pixels. |

---

#### `LImageData:getHeight`

Returns image height. This method is available to Lua scripts.

```lua
LImageData:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Height in pixels. |

---

#### `LImageData:getPixel`

Returns RGBA channels at a pixel coordinate.

```lua
LImageData:getPixel(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X coordinate. |
| `y` | number | Y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| number | Red channel. |
| number | Green channel. |
| number | Blue channel. |
| number | Alpha channel. |

---

#### `LImageData:getRawBytes`

Returns raw image bytes as a Lua string.

```lua
LImageData:getRawBytes()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Raw image byte string. |

---

#### `LImageData:getRegion`

Returns an image region when the requested rectangle is inside bounds.

```lua
LImageData:getRegion(x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Region x coordinate. |
| `y` | number | Region y coordinate. |
| `w` | number | Region width. |
| `h` | number | Region height. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | nil | `[LImageData](#limagedata)` handle, or nil when the region is out of bounds. |

---

#### `LImageData:getString`

Returns raw image bytes as a Lua string.

```lua
LImageData:getString()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Raw image byte string. |

---

#### `LImageData:getWidth`

Returns image width. This method is available to Lua scripts.

```lua
LImageData:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width in pixels. |

---

#### `LImageData:grayscale`

Converts this image to grayscale in place.

```lua
LImageData:grayscale()
```

---

#### `LImageData:invert`

Inverts image color channels in place.

```lua
LImageData:invert()
```

---

#### `LImageData:mapPixel`

Applies a Lua callback to every pixel and replaces each pixel with returned RGBA values.

```lua
LImageData:mapPixel(func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `func` | function | Callback receiving `(x, y, r, g, b, a)` and returning replacement channels. |

---

#### `LImageData:mapPixels`

Applies a Lua callback to every pixel and replaces each pixel with returned RGBA values.

```lua
LImageData:mapPixels(func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `func` | function | Callback receiving `(x, y, r, g, b, a)` and returning replacement channels. |

---

#### `LImageData:noise`

Adds noise to this image in place. This method is available to Lua scripts.

```lua
LImageData:noise(amount)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `amount` | number | Noise amount. |

---

#### `LImageData:paste`

Pastes a source image into this image at unsigned destination coordinates.

```lua
LImageData:paste(src_ud, dx, dy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `src_ud` | [LImageData](#limagedata) | Source image data handle. |
| `dx` | number | Destination x coordinate. |
| `dy` | number | Destination y coordinate. |

---

#### `LImageData:posterize`

Reduces image colors to a fixed number of levels in place.

```lua
LImageData:posterize(levels)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `levels` | number | Number of posterization levels. |

---

#### `LImageData:resize`

Returns a resized image using an optional named filter.

```lua
LImageData:resize(width, height, filter)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | number | Output width. |
| `height` | number | Output height. |
| `filter` | string | Optional filter name, defaulting to `bilinear`. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | nil | Resized `[LImageData](#limagedata)` handle, or nil when resizing fails. |

---

#### `LImageData:resizeNearest`

Returns a resized image using nearest-neighbor sampling.

```lua
LImageData:resizeNearest(new_w, new_h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `new_w` | number | Output width. |
| `new_h` | number | Output height. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Resized image data handle. |

---

#### `LImageData:rotate90cw`

Returns a new image rotated ninety degrees clockwise.

```lua
LImageData:rotate90cw()
```

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Rotated image data handle. |

---

#### `LImageData:saturation`

Applies a saturation factor to this image in place.

```lua
LImageData:saturation(factor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `factor` | number | Saturation factor. |

---

#### `LImageData:sepia`

Applies a sepia filter to this image in place.

```lua
LImageData:sepia()
```

---

#### `LImageData:setPixel`

Sets RGBA channels at a pixel coordinate.

```lua
LImageData:setPixel(x, y, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X coordinate. |
| `y` | number | Y coordinate. |
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a` | number | Alpha channel. |

---

#### `LImageData:setRawData`

Replaces the image byte buffer with raw bytes.

```lua
LImageData:setRawData(bytes)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bytes` | string | Raw byte string matching the image storage size. |

---

#### `LImageData:sharpen`

Returns a sharpened copy of this image.

```lua
LImageData:sharpen()
```

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Sharpened image data handle. |

---

#### `LImageData:threshold`

Applies a threshold filter to this image in place.

```lua
LImageData:threshold(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | number | Threshold channel value. |

---

#### `LImageData:tint`

Blends this image toward a tint color in place.

```lua
LImageData:tint(tr, tg, tb, factor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tr` | number | Tint red channel. |
| `tg` | number | Tint green channel. |
| `tb` | number | Tint blue channel. |
| `factor` | number | Tint blend factor. |

---

#### `LImageData:type`

Returns the Lua-visible type name for this image data handle.

```lua
LImageData:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LImageData](#limagedata)`. |

---

#### `LImageData:typeOf`

Returns whether this image data handle matches the `[LImageData](#limagedata)` type name.

```lua
LImageData:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LImageData](#limagedata)` or `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches. |

---

## LMesh

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LMesh:getVertex`

Returns the data for a single vertex by 1-based index.

```lua
LMesh:getVertex(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | 1-based vertex index. |

**Returns**

| Type | Description |
|------|-------------|
| number | x; y; u; v; r; g; b; a. (value 1). |
| number | x; y; u; v; r; g; b; a. (value 2). |
| number | x; y; u; v; r; g; b; a. (value 3). |
| number | x; y; u; v; r; g; b; a. (value 4). |
| number | x; y; u; v; r; g; b; a. (value 5). |
| number | x; y; u; v; r; g; b; a. (value 6). |
| number | x; y; u; v; r; g; b; a. (value 7). |
| number | x; y; u; v; r; g; b; a. (value 8). |

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

#### `LMesh:getVertexCount`

Returns the number of vertices in this mesh.

```lua
LMesh:getVertexCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Vertex count. |

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

#### `LMesh:release`

Releases the mesh GPU resource and invalidates the handle.

```lua
LMesh:release()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the mesh was valid and was released. |

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

#### `LMesh:setTexture`

Assigns or removes a texture for this mesh. Pass nil to clear the texture.

```lua
LMesh:setTexture(image)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `image?` | [LImage](#limage) | Image to use as the mesh texture, or nil to remove. |

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

#### `LMesh:setVertex`

Updates a single vertex by 1-based index. Table format: {x, y, u, v, r, g, b, a}.

```lua
LMesh:setVertex(index, data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | 1-based vertex index. |
| `data` | table | Vertex data: {x, y, u, v, r, g, b, a}. |

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

#### `LMesh:type`

Returns the type name string for this mesh object.

```lua
LMesh:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always "[LMesh](#lmesh)". |

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

#### `LMesh:typeOf`

Checks whether this object matches the given type name.

```lua
LMesh:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check ("Mesh" or "Object"). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the name matches. |

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

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LNineSlice:getInsets`

Returns the border insets (top, right, bottom, left) that define the stretchable regions.

```lua
LNineSlice:getInsets()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Top; right; bottom; left inset values. (value 1). |
| number | Top; right; bottom; left inset values. (value 2). |
| number | Top; right; bottom; left inset values. (value 3). |
| number | Top; right; bottom; left inset values. (value 4). |

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

#### `LNineSlice:getTextureSize`

Returns the pixel dimensions of the underlying source texture.

```lua
LNineSlice:getTextureSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width and height in pixels. (value 1). |
| number | Width and height in pixels. (value 2). |

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

#### `LNineSlice:type`

Returns the type name of this object.

```lua
LNineSlice:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always "[LNineSlice](#lnineslice)". |

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

#### `LNineSlice:typeOf`

Checks whether this object matches the given type name.

```lua
LNineSlice:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check ("NineSlice" or "Object"). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the name matches. |

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

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LObjModel:getFaceCount`

Returns the number of faces (triangles) in this OBJ model.

```lua
LObjModel:getFaceCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Face count. |

**Example**

```lua
do
    local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
    print("model face count = " .. model:getFaceCount())
    print("model vertex count = " .. model:getVertexCount())
end
```

---

#### `LObjModel:getNormalCount`

Returns the number of vertex normals in this OBJ model.

```lua
LObjModel:getNormalCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Normal count. |

**Example**

```lua
do
    local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
    print("model normal count = " .. model:getNormalCount())
    print("model face count = " .. model:getFaceCount())
end
```

---

#### `LObjModel:getUvCount`

Returns the number of UV texture coordinates in this OBJ model.

```lua
LObjModel:getUvCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | UV coordinate count. |

**Example**

```lua
do
    local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
    print("model uv count = " .. model:getUvCount())
    print("model vertex count = " .. model:getVertexCount())
end
```

---

#### `LObjModel:getVertexCount`

Returns the number of vertices in this OBJ model.

```lua
LObjModel:getVertexCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Vertex count. |

**Example**

```lua
do
    local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
    print("model vertex count = " .. model:getVertexCount())
    print("model uv count = " .. model:getUvCount())
end
```

---

#### `LObjModel:projectToMesh`

Projects the OBJ model into 2D vertex data using a virtual camera, returning a table of vertex rows.

```lua
LObjModel:projectToMesh(camera, screenW, screenH)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `camera` | table | Camera parameters: {x, y, z, tx, ty, tz, fov}. |
| `screenW` | number | Screen width for projection. |
| `screenH` | number | Screen height for projection. |

**Returns**

| Type | Description |
|------|-------------|
| LObjModelProjectToMeshResult | Array of vertex tables: {{x, y, u, v, r, g, b, a}, ...}. |

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

#### `LObjModel:renderToImage`

Renders the OBJ model to a GPU texture at the given resolution with optional 90-degree rotation.

```lua
LObjModel:renderToImage(width, height, rotation)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | number | Output image width in pixels. |
| `height` | number | Output image height in pixels. |
| `rotation?` | number | Rotation step (0â€“3, each step = 90 degrees, default 0). |

**Returns**

| Type | Description |
|------|-------------|
| [LImage](#limage) | The rendered image handle. |

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

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LQuad:getTextureDimensions`

Returns the full dimensions of the source texture this quad references.

```lua
LQuad:getTextureDimensions()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Source texture width and height. (value 1). |
| number | Source texture width and height. (value 2). |

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

#### `LQuad:getViewport`

Returns the quad's viewport rectangle within the source texture.

```lua
LQuad:getViewport()
```

**Returns**

| Type | Description |
|------|-------------|
| number | x; y; width; height in texture pixels. (value 1). |
| number | x; y; width; height in texture pixels. (value 2). |
| number | x; y; width; height in texture pixels. (value 3). |
| number | x; y; width; height in texture pixels. (value 4). |

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

#### `LQuad:setViewport`

Updates the quad's viewport rectangle.

```lua
LQuad:setViewport(x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Left edge in texture pixels. |
| `y` | number | Top edge in texture pixels. |
| `w` | number | Width in texture pixels. |
| `h` | number | Height in texture pixels. |

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

#### `LQuad:type`

Returns the type name string for this quad object.

```lua
LQuad:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always "[LQuad](#lquad)". |

**Example**

```lua
do
    local quad = lurek.render.newQuad(0, 0, 8, 8, 64, 64)
    print("quad type = " .. quad:type())
    print("quad typeOf LQuad = " .. tostring(quad:typeOf("LQuad")))
end
```

---

#### `LQuad:typeOf`

Checks whether this object matches the given type name.

```lua
LQuad:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check ("Quad" or "Object"). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the name matches. |

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

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LShader:hasUniform`

Checks whether this shader declares a uniform with the given name.

```lua
LShader:hasUniform(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Uniform name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the uniform exists. |

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

#### `LShader:release`

Releases the shader resource. If active, the default shader is restored.

```lua
LShader:release()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the shader was valid and was released. |

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

#### `LShader:send`

Sends a uniform value to this shader by name. Supported types: number, boolean, or table (vec2/vec3/vec4).

```lua
LShader:send(name, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Uniform variable name declared in the shader. |
| `value` | number|boolean|table | The value to send. |

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

#### `LShader:type`

Returns the type name string for this shader object.

```lua
LShader:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always "[LShader](#lshader)". |

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

#### `LShader:typeOf`

Checks whether this object matches the given type name.

```lua
LShader:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check ("Shader" or "Object"). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the name matches. |

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

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LShape:arc`

Adds a filled or outlined arc command to the shape.

```lua
LShape:arc(mode, x, y, r, astart, aend, segments)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | string | "fill" or "line". |
| `x` | number | Center X. |
| `y` | number | Center Y. |
| `r` | number | Radius. |
| `astart` | number | Start angle in radians. |
| `aend` | number | End angle in radians. |
| `segments?` | number | Number of arc segments (default 32). |

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

#### `LShape:circle`

Adds a filled or outlined circle command to the shape.

```lua
LShape:circle(mode, x, y, r)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | string | "fill" or "line". |
| `x` | number | Center X. |
| `y` | number | Center Y. |
| `r` | number | Radius. |

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

#### `LShape:clear`

Removes all drawing commands from this shape, making it empty.

```lua
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

#### `LShape:draw`

Renders the accumulated shape commands to the screen with optional transform.

```lua
LShape:draw(x, y, rotation, sx, sy, ox, oy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X position. |
| `y` | number | Y position. |
| `rotation?` | number | Rotation in radians (default 0). |
| `sx?` | number | Scale X (default 1). |
| `sy?` | number | Scale Y (default 1). |
| `ox?` | number | Origin offset X (default 0). |
| `oy?` | number | Origin offset Y (default 0). |

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

#### `LShape:ellipse`

Adds an ellipse command to the shape.

```lua
LShape:ellipse(mode, x, y, rx, ry)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | string | "fill" or "line". |
| `x` | number | Center X. |
| `y` | number | Center Y. |
| `rx` | number | Horizontal radius. |
| `ry` | number | Vertical radius. |

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

#### `LShape:getCommandCount`

Returns the number of drawing commands accumulated in this shape.

```lua
LShape:getCommandCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Command count. |

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

#### `LShape:line`

Adds a line segment command to the shape.

```lua
LShape:line(x1, y1, x2, y2)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x1` | number | Start X. |
| `y1` | number | Start Y. |
| `x2` | number | End X. |
| `y2` | number | End Y. |

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

#### `LShape:polygon`

Adds a polygon command to the shape from a flat list of x,y coordinate pairs.

```lua
LShape:polygon(mode, ...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | string | "fill" or "line". |
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

#### `LShape:polyline`

Adds a connected polyline command to the shape from a flat list of x,y coordinate pairs.

```lua
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

#### `LShape:rectangle`

Adds a rectangle command to the shape.

```lua
LShape:rectangle(mode, x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | string | "fill" or "line". |
| `x` | number | Left edge X. |
| `y` | number | Top edge Y. |
| `w` | number | Width. |
| `h` | number | Height. |

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

#### `LShape:roundedRectangle`

Adds a rounded rectangle command to the shape.

```lua
LShape:roundedRectangle(mode, x, y, w, h, rx, ry)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | string | "fill" or "line". |
| `x` | number | Left edge X. |
| `y` | number | Top edge Y. |
| `w` | number | Width. |
| `h` | number | Height. |
| `rx` | number | Horizontal corner radius. |
| `ry?` | number | Vertical corner radius (defaults to rx). |

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

#### `LShape:setColor`

Sets the drawing color for subsequent shape commands.

```lua
LShape:setColor(r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | number | Red channel (0â€“1). |
| `g` | number | Green channel (0â€“1). |
| `b` | number | Blue channel (0â€“1). |
| `a?` | number | Alpha channel (0â€“1, default 1). |

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

#### `LShape:setLineWidth`

Sets the line width for subsequent line-mode shape commands.

```lua
LShape:setLineWidth(w)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | number | Line width in pixels. |

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

#### `LShape:triangle`

Adds a triangle command to the shape.

```lua
LShape:triangle(mode, x1, y1, x2, y2, x3, y3)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | string | "fill" or "line". |
| `x1` | number | First vertex X. |
| `y1` | number | First vertex Y. |
| `x2` | number | Second vertex X. |
| `y2` | number | Second vertex Y. |
| `x3` | number | Third vertex X. |
| `y3` | number | Third vertex Y. |

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

#### `LShape:type`

Returns the type name string for this shape object.

```lua
LShape:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always "[LShape](#lshape)". |

**Example**

```lua
do
    local shape = lurek.render.newShape()
    print("shape type = " .. shape:type())
    print("shape typeOf LShape = " .. tostring(shape:typeOf("LShape")))
end
```

---

#### `LShape:typeOf`

Checks whether this object matches the given type name.

```lua
LShape:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check ("Shape" or "Object"). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the name matches. |

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

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LSpriteBatch:add`

Adds a sprite entry to the batch at the given position with optional transform.

```lua
LSpriteBatch:add(x, y, r, sx, sy, ox, oy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X position. |
| `y` | number | Y position. |
| `r?` | number | Rotation in radians. |
| `sx?` | number | Scale X (default 1). |
| `sy?` | number | Scale Y (default 1). |
| `ox?` | number | Origin offset X. |
| `oy?` | number | Origin offset Y. |

**Returns**

| Type | Description |
|------|-------------|
| number | Index of the added entry. |

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

#### `LSpriteBatch:clear`

Removes all entries from the sprite batch.

```lua
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

#### `LSpriteBatch:getBufferSize`

Returns the maximum number of entries this batch can hold.

```lua
LSpriteBatch:getBufferSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Buffer capacity. |

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

#### `LSpriteBatch:getCount`

Returns the number of sprite entries currently in the batch.

```lua
LSpriteBatch:getCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Entry count. |

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

#### `LSpriteBatch:release`

Releases the sprite batch resource.

```lua
LSpriteBatch:release()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the batch was valid and was released. |

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

#### `LSpriteBatch:type`

Returns the type name string for this sprite batch.

```lua
LSpriteBatch:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always "[LSpriteBatch](#lspritebatch)". |

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

#### `LSpriteBatch:typeOf`

Checks whether this object matches the given type name.

```lua
LSpriteBatch:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check ("SpriteBatch" or "Object"). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the name matches. |

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
