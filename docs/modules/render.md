# Render

## Purpose

Orchestrates the engine's visual backend using a device-facing wgpu renderer. - Supports shapes, batched textures, off-screen canvases, and dynamic font rasterization. - Enables custom WGSL shaders, chained post-processing filters, and stencil portal masks. - Projects 3D Wavefront models into 2D vertex meshes with software screenshot readbacks.

## Summary

- The `render` module is the engine's central visual execution layer, responsible for turning high-level drawing intent from many other systems into concrete frame output on GPU-backed and software-backed paths.
- Its most important user-facing role is normalization. Different modules can describe sprites, shapes, text, overlays, tiles, provinces, lights, effects, or custom geometry in their own terms while still relying on one shared renderer to decide how those requests become final pixels.
- This makes `render` less like one feature among many and more like the final translation authority for visual state. Other modules decide what should exist visually, but `render` decides how that existence is encoded, ordered, shaded, and emitted.
- The module spans several rendering families at once: sprite and texture drawing, text output, shape drawing, mesh and geometry support, canvas-like targets, shader pipelines, post-processing, lighting, shadows, decals, screenshots, and software-render evidence paths.
- GPU resource ownership is a core part of that responsibility. Buffers, textures, samplers, shader modules, bind groups, pipelines, intermediate targets, typed GPU-side records, and staging resources live here so the rest of the engine does not fragment backend management.
- Resource inputs are validated before backend allocation or shader-source generation: texture and canvas dimensions must be non-zero and within device limits, RGBA uploads must match exact byte length, dynamic font atlases are bounded, OBJ material paths must stay under their base directory, and shader uniform names must be valid non-reserved WGSL identifiers.
- Centralizing those resources matters because otherwise each visual feature would invent its own backend conventions, lifetime rules, and upload paths. `render` provides one stable home for those concerns and reduces backend duplication.
- Rendering commands and pipeline structures give the engine a common language between feature modules and execution code. This shared command vocabulary is what allows gameplay-facing APIs to remain expressive while still mapping onto a disciplined backend.
- The module is broader than simple 2D quad drawing. Mesh support, OBJ loading, tessellation, decals, shape batching, and specialized pipelines show that it can represent both standard 2D workflows and richer geometric or stylized visual features without leaving the engine's main render authority.
- Text and font integration are part of the same visual surface, not a parallel universe. Menus, labels, debug overlays, editor tools, and evidence images all need text rendering that cooperates with layers, transforms, clipping, and final composition.
- Post-processing support matters after scene composition has already happened. Once a view exists, users often want bloom-like treatments, color transforms, blur-like effects, or custom shader passes, and `render` provides the controlled place where those frame-wide or target-specific effects belong.
- Lighting and shadow support connect scene-level illumination data to actual frame execution. Neighboring modules define lights, occluders, and light-world state, but `render` owns how those concepts become shaded images, masks, and composited outputs.
- Camera-aware and viewport-aware composition are part of the same boundary. Data coming from tilemaps, particles, raycasters, provinces, overlays, and UI all eventually has to agree on transforms, clipping regions, target sizes, and layer order, and `render` is where that agreement is enforced.
- Software-render and capture paths are a major practical capability, not an afterthought. They make it possible to generate deterministic screenshots, evidence images, docs artifacts, test outputs, and headless previews without relying on an interactive GPU session.
- The module therefore serves both runtime presentation and development workflow needs. It is equally relevant when the goal is shipping a frame to the screen and when the goal is extracting a reproducible image for debugging or documentation.
- Render-target management matters for the same reason, because complex scenes often need offscreen surfaces, intermediate passes, and controlled composition order to stay inspectable and stable.
- The renderer is therefore not just a drawer of primitives, but the arbiter of when and where visual work becomes final output.
- That backend discipline is what lets several higher-level modules share one frame pipeline without each inventing its own incompatible render lifecycle.
- For users, the important boundary is that `render` does not usually define domain meaning. It does not decide enemy AI, tile adjacency, or UI layout policy. Instead, it owns the visual execution model that allows those domains to appear consistently.
- Read `render` as the final visual translation layer of the engine. Feature modules describe visual state and intent, and `render` turns that intent into frames, captures, shadows, text, effects, and finished composited output for a shared frame contract.

This module primarily collaborates with `font`, `image`, `light`, `math`, `runtime`, `sprite`. Its responsibility should stay inside the Platform Services group rather than absorb behavior owned by those neighbors.

### Render Input Invariants

- Texture uploads require non-zero width and height, exact RGBA8 byte length, checked pixel arithmetic, and dimensions no larger than the active wgpu device limit.
- Canvas GPU allocations require non-zero width and height within the same 2D texture dimension limit; changing a canvas size under the same key recreates its GPU backing texture.
- Dynamic font creation clamps very small point sizes upward and rejects non-finite, oversized, zero-dimension, or oversized atlas allocations before CPU buffer growth.
- Mesh upload and Lua-facing mesh construction reject non-finite vertex fields, out-of-range indices, and incomplete triangle-list topology before static geometry is synchronized.
- OBJ face indices are bounded after 1-based or negative-index normalization, index zero is invalid, and material-library paths must stay under the supplied base directory.
- Shader uniform names must be valid, non-reserved WGSL identifiers before they can participate in wrapper-source generation.
- Render commands and registered compound shapes pass through a central input sanitizer before backend work; non-finite floats, invalid sizes, out-of-range colors, excessive segments, and malformed point arrays are rejected and counted.
- Arc tessellation clamps zero segment counts to a safe minimum before vertex generation.
- Draw-layer ordering uses total floating-point ordering and callback ID tie-breaks, so NaN and equal depths flush deterministically.
- `RenderDiagnostics` records skipped render commands, missing GPU or shape resources, invalid uploads, invalid meshes, GPU buffer growth, and shader or pipeline cache fallback events without turning the frame into a hard error.
- Frame-local color, texture, draw, instance, merge, and command scratch buffers clear between frames without shrinking; hot flat-color primitives tessellate directly into shared frame buffers and textured paths reuse scratch buffers instead of allocating per command.
- Shadow edge collection filters disabled, masked-out, and out-of-radius occluders before GPU upload, reuses per-occluder world-space edge caches for shadow lights in the same frame, and records rendered shadow rows plus collected and culled edge counts.
- `SoftwareCaptureDiagnostics` records unsupported capture commands and bounded polygon fill behavior; software capture is evidence-oriented and does not promise pixel parity for GPU-only texture, shader, post-fx, layer, batch, or registered-resource commands.

## API Reference

- This page is the generated API reference for this module.

## Functions

### `lurek.render.applyShaderToCanvas`

Queues a postfx shader pass that mutates a canvas render target after queued canvas draws in the current frame.

```lua
lurek.render.applyShaderToCanvas(canvas, shader, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `canvas` | [LCanvas](#lcanvas) | Canvas render target to process. |
| `shader` | [LShader](#lshader) | Shader created with `lurek.render.newShader(code, { target = "postfx" })`. |
| `opts?` | table | Reserved options table for future pass parameters. |

**Returns**

| Type | Description |
|------|-------------|
| [LCanvas](#lcanvas) | The processed canvas handle. |

**Example**

```lua
do

    local code = [[
@fragment
fn fs_main(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>) -> @location(0) vec4<f32> {
    let vignette = smoothstep(0.85, 0.2, distance(uv, vec2<f32>(0.5, 0.5)));
    return vec4<f32>(color.rgb * (0.35 + vignette), color.a);
}
]]
    local shader = lurek.render.newShader(code, { target = "postfx" })
    local canvas = lurek.render.newCanvas(96, 96)
    lurek.render.setCanvas(canvas)
    lurek.render.rectangle("fill", 0, 0, 96, 96)
    lurek.render.setCanvas(nil)
    lurek.render.applyShaderToCanvas(canvas, shader)
    lurek.render.draw(canvas, 120, 70)
    lurek.log.info("canvas postfx shader target = " .. shader:getTarget())
    lurek.log.info("queued render.applyShaderToCanvas")
end
```

---

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
    lurek.log.info("applyTransform matrix entries = " .. #matrix)
    lurek.log.info("flat 3x3 matrix applied")
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
    lurek.log.info("arc segments = 20 on line arc")
    lurek.log.info("arc examples drawn")
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
    lurek.log.info("sort group id = 1")
    lurek.log.info("sort keys 10 and 5 queued")
end
```

---

### `lurek.render.captureScreenshot`

Captures the queued 2D render commands into an ImageData fallback and passes it to a callback.

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
        lurek.log.info("captureScreenshot size = " .. data:getWidth() .. "x" .. data:getHeight())
    end)
    lurek.render.saveScreenshot("save/render_capture.png")
    lurek.log.info("captureScreenshot callback invoked")
    lurek.log.info("saveScreenshot requested")
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
    lurek.log.info("circle radius = 30")
    lurek.log.info("circle fill and line drawn")
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
    lurek.render.circle("line", 24, 24, 8)
    local mode = lurek.render.getBlendMode()
    lurek.log.info("render queue cleared and resumed in blend mode " .. mode)
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
    lurek.render.rectangle("line", 0, 0, 8, 8)
    lurek.log.info("stencil mode after clear = " .. action .. "," .. compare .. "," .. value)
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
    local current = lurek.render.currentLayer()
    local z = lurek.render.getLayerZOrder("current_layer_stub")
    lurek.log.info("current layer = " .. current .. " z=" .. z)
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
    lurek.log.info("draw used a canvas handle")
    lurek.log.info("draw scale = 0.75")
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
    lurek.log.info("drawBatch sprite count = " .. batch:getCount())
    lurek.log.info("drawBatch issued")
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
    lurek.log.info("bevel styles = raised, sunken, flat")
    lurek.log.info("bevel rectangles drawn")
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
    lurek.log.info("colored polygon vertices = 4")
    lurek.log.info("colored polygon drawn")
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
    lurek.log.info("cubic bezier segments = 24")
    lurek.log.info("cubic bezier drawn")
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
    lurek.render.rectangle("line", 10, 500, 120, 36)
    local r, g, b, a = lurek.render.getColor()
    lurek.log.info("gradient cards drawn with active color " .. r .. "," .. g .. "," .. b .. "," .. a)
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
    lurek.log.info("hex tile orientations = pointyTop, flatTop")
    lurek.log.info("hex tiles drawn")
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
    lurek.log.info("iso cube tile depth = 18")
    lurek.log.info("iso cube tile drawn")
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
    lurek.log.info("drawMany entries = " .. #list)
    lurek.log.info("drawMany issued")
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
    local slice = lurek.sprite.newNineSlice(image, 4, 4, 4, 4)
    lurek.render.drawNineSlice(slice, 100, 100, 80, 60)
    lurek.log.info("drawNineSlice target size = 80x60")
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
    lurek.log.info("path segments = " .. #path)
    lurek.log.info("path closed = true")
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
    lurek.log.info("quad bezier segments = 18")
    lurek.log.info("quad bezier drawn")
end
```

---

### `lurek.render.drawText`

Draws text using the active font with image-like transform parameters on the GPU.

```lua
lurek.render.drawText(text, x, y, rotation, sx, sy, ox, oy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | string | Text to render. |
| `x` | number | X position. |
| `y` | number | Y position. |
| `rotation?` | number | Rotation in radians (default 0). |
| `sx?` | number | X scale factor (default 1). |
| `sy?` | number | Y scale factor (defaults to sx). |
| `ox?` | number | Origin offset X in text-local pixels (default 0). |
| `oy?` | number | Origin offset Y in text-local pixels (default 0). |

**Example**

```lua
do

    local font = lurek.render.getDefaultFont(16)
    lurek.render.setFont(font)
    lurek.render.setColor(0.65, 0.9, 1.0, 0.9)
    lurek.render.drawText("GPU transformed text", 260, 92, -0.2, 1.4, 1.1, 20, 8)
    lurek.render.setColor(1, 1, 1, 1)
    lurek.log.info("drawText rotation = -0.2")
    lurek.log.info("drawText uses tint from setColor")
end
```

---

### `lurek.render.drawTextWithFont`

Draws text using a specific font with image-like transform parameters on the GPU.

```lua
lurek.render.drawTextWithFont(font, text, x, y, rotation, sx, sy, ox, oy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `font` | [LFont](#lfont) | Font handle to use for this draw. |
| `text` | string | Text to render. |
| `x` | number | X position. |
| `y` | number | Y position. |
| `rotation?` | number | Rotation in radians (default 0). |
| `sx?` | number | X scale factor (default 1). |
| `sy?` | number | Y scale factor (defaults to sx). |
| `ox?` | number | Origin offset X in text-local pixels (default 0). |
| `oy?` | number | Origin offset Y in text-local pixels (default 0). |

**Example**

```lua
do

    local font = lurek.render.getDefaultFont(16)
    lurek.render.setColor(0.8, 1.0, 0.7, 0.9)
    lurek.render.drawTextWithFont(font, "Font handle transform", 220, 152, 0.18, 1.25, 1.0, 16, 6)
    lurek.render.setColor(1, 1, 1, 1)
    local width = lurek.render.getFontWidth(font, "Font handle transform")
    lurek.log.info("drawTextWithFont width=" .. width .. " rotation=0.18")
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
    lurek.log.info("drawq used a 16x16 quad")
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
    lurek.log.info("ellipse examples drawn")
    lurek.log.info("ellipse radii = 60x30 and 40x60")
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
    lurek.log.info("flushSortGroup id = 7")
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
| number | Red; green; blue; alpha channels (0-1). (value 1). |
| number | Red; green; blue; alpha channels (0-1). (value 2). |
| number | Red; green; blue; alpha channels (0-1). (value 3). |
| number | Red; green; blue; alpha channels (0-1). (value 4). |

**Example**

```lua
do

    lurek.render.setBackgroundColor(0.2, 0.2, 0.3)
    local r, g, b, a = lurek.render.getBackgroundColor()
    lurek.render.rectangle("line", 0, 0, 10, 10)
    lurek.log.info("background=" .. r .. "," .. g .. "," .. b .. "," .. a)
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
    local mode = lurek.render.getBlendMode()
    lurek.render.rectangle("fill", 0, 0, 4, 4)
    lurek.render.setBlendMode("add")
    lurek.log.info("blend mode=" .. mode)
    lurek.render.setBlendMode("alpha")
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
    local first = names[1] or "none"
    local last = names[#names] or "none"
    local count = #names
    lurek.log.info("built-in font names=" .. count .. " first=" .. tostring(first) .. " last=" .. tostring(last))
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
    lurek.log.info("active canvas exists = " .. tostring(active ~= nil))
    lurek.log.info("canvas size = " .. w .. "x" .. h)
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
    lurek.log.info("canvas size = " .. w .. "x" .. h)
    lurek.log.info("color mask red enabled = " .. tostring(select(1, lurek.render.getColorMask())))
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
| number | Red; green; blue; alpha channels (0-1). (value 1). |
| number | Red; green; blue; alpha channels (0-1). (value 2). |
| number | Red; green; blue; alpha channels (0-1). (value 3). |
| number | Red; green; blue; alpha channels (0-1). (value 4). |

**Example**

```lua
do

    lurek.render.setColor(1, 0, 0, 1)
    local r, g, b, a = lurek.render.getColor()
    lurek.render.rectangle("fill", 6, 6, 8, 8)
    lurek.log.info("color=" .. r .. "," .. g .. "," .. b .. "," .. a)
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
    lurek.render.rectangle("fill", 0, 0, 6, 6)
    lurek.log.info("color mask = " .. tostring(r) .. "," .. tostring(g) .. "," .. tostring(b) .. "," .. tostring(a))
    lurek.render.setColorMask()
end
```

---

### `lurek.render.getDebugShader`

Returns the active debug visualization shader, or nil if debug draws use the normal/default render shader path.

```lua
lurek.render.getDebugShader()
```

**Returns**

| Type | Description |
|------|-------------|
| [LShader](#lshader)? | The active debug visualization shader handle. |

**Example**

```lua
do

    local shader = lurek.render.newShader([[
@fragment
fn fs(@location(0) color: vec4<f32>, @location(3) resolution: vec2<f32>) -> @location(0) vec4<f32> {
    let scale = clamp(resolution.x / max(resolution.x, 1.0), 0.0, 1.0);
    return vec4<f32>(color.rgb * vec3<f32>(1.0, scale, 0.35), color.a);
}
]], { target = "debugviz" })
    lurek.render.setDebugShader(shader)
    local active = lurek.render.getDebugShader()
    lurek.render.line(8, 96, 128, 96)
    lurek.log.info("active debug shader=" .. tostring(active and active:getTarget() or "nil"))
    lurek.render.setDebugShader(nil)
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
    lurek.render.setDefaultFilter(min_filter, mag_filter, aniso)
    local min_again, mag_again, aniso_again = lurek.render.getDefaultFilter()
    local summary = min_again .. "/" .. mag_again
    lurek.log.info("default filter = " .. summary .. "," .. aniso_again)
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
    lurek.log.info("default font height = " .. font:getHeight())
    lurek.log.info("default font fetched by point size")
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
    lurek.render.setDepthMode(mode, write)
    local confirm_mode, confirm_write = lurek.render.getDepthMode()
    local width = lurek.render.getWidth()
    lurek.log.info("depth mode = " .. confirm_mode .. " write=" .. tostring(confirm_write) .. " width=" .. width)
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
    local width = lurek.render.getWidth()
    local height = lurek.render.getHeight()
    local area = width * height
    lurek.log.info("framebuffer " .. w .. "x" .. h .. " width=" .. width .. " height=" .. height .. " area=" .. area)
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
    lurek.log.info("active font exists = " .. tostring(lurek.render.getFont() ~= nil))
    lurek.log.info("active font width of test = " .. font:getWidth("test"))
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
    local ascent = lurek.render.getFontAscent(font)
    local descent = lurek.render.getFontDescent(font)
    local height = lurek.render.getFontHeight(font)
    lurek.log.info("module ascent=" .. ascent .. " descent=" .. descent .. " height=" .. height)
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
    local cell_width = lurek.render.getFontCellWidth(font)
    local descent = lurek.render.getFontDescent(font)
    local ascent = lurek.render.getFontAscent(font)
    lurek.log.info("font cell width = " .. cell_width .. " descent=" .. descent .. " ascent=" .. ascent)
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
    local descent = lurek.render.getFontDescent(font)
    local ascent = lurek.render.getFontAscent(font)
    local height = lurek.render.getFontHeight(font)
    lurek.log.info("font descent = " .. descent .. " ascent=" .. ascent .. " height=" .. height)
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
    local height = lurek.render.getFontHeight(font)
    local line_height = lurek.render.getFontLineHeight(font)
    local cell_width = lurek.render.getFontCellWidth(font)
    lurek.log.info("font height = " .. height .. " line_height=" .. line_height .. " cell_width=" .. cell_width)
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
    local line_height = lurek.render.getFontLineHeight(font)
    local line_width = lurek.render.getLineWidth()
    local height = lurek.render.getFontHeight(font)
    lurek.log.info("font line height = " .. line_height .. " line_width=" .. line_width .. " height=" .. height)
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
    local first = sizes[1] or -1
    local last = sizes[#sizes] or -1
    local count = #sizes
    lurek.log.info("font sizes=" .. count .. " range=" .. tostring(first) .. "-" .. tostring(last))
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
    local width = lurek.render.getFontWidth(font, "Measure")
    local height = lurek.render.getFontHeight(font)
    local line_height = lurek.render.getFontLineHeight(font)
    lurek.log.info("module font width=" .. width .. " height=" .. height .. " line_height=" .. line_height)
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
    lurek.log.info("module wrapped lines = " .. #lines)
    lurek.log.info("module wrap width = " .. width)
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
    local height = lurek.render.getHeight()
    local width = lurek.render.getWidth()
    local area = width * height
    lurek.log.info("dimensions=" .. w .. "x" .. h .. " height=" .. height .. " width=" .. width .. " area=" .. area)
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
    lurek.render.setLayer("midground")
    local before = lurek.render.getLayerZOrder("midground")
    lurek.render.setLayerZOrder("midground", 15)
    local after = lurek.render.getLayerZOrder("midground")
    lurek.log.info("midground z changed " .. before .. " -> " .. after)
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
    lurek.log.info("line width = " .. tostring(width))
    lurek.render.setLineWidth(1)
    lurek.log.info("line width restored")
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
    lurek.log.info("point size = " .. tostring(size))
    lurek.render.setPointSize(1)
    lurek.log.info("point size restored")
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
    lurek.render.rectangle("line", x, y, w, h)
    lurek.log.info("scissor=" .. x .. "," .. y .. "," .. w .. "," .. h)
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
    lurek.log.info("getShader returned handle = " .. tostring(lurek.render.getShader() ~= nil))
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
    lurek.render.rectangle("fill", 0, 0, 8, 8)
    local draws = tostring(stats.drawcalls)
    local textures = tostring(stats.textures)
    local gpu = tostring(stats.gpu_draw_calls)
    lurek.log.info("stats drawcalls=" .. draws .. " textures=" .. textures .. " gpu=" .. gpu)
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
    lurek.render.circle("line", 8, 8, 4)
    lurek.log.info("stencil mode = " .. action .. "," .. compare .. "," .. value)
    lurek.render.clearStencil()
end
```

---

### `lurek.render.getTextShader`

Returns the active text shader, or nil if font-atlas text uses the default/fallback shader path.

```lua
lurek.render.getTextShader()
```

**Returns**

| Type | Description |
|------|-------------|
| [LShader](#lshader)? | The active text shader handle. |

**Example**

```lua
do

    local shader = lurek.render.newShader([[
@fragment
fn fs(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(color.rgb + uv.xyx * 0.0, color.a);
}
]], { target = "text" })
    lurek.render.setTextShader(shader)
    local active = lurek.render.getTextShader()
    lurek.log.info("active text shader=" .. tostring(active and active:getTarget() or "nil"))
    lurek.render.setTextShader(nil)
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
    local width = lurek.render.getWidth()
    local height = lurek.render.getHeight()
    local area = width * height
    lurek.log.info("dimensions=" .. w .. "x" .. h .. " width=" .. width .. " height=" .. height .. " area=" .. area)
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
    lurek.log.info("intersected scissor = " .. x .. "," .. y .. "," .. w .. "," .. h)
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
    local font_names = lurek.render.getBuiltInFontNames()
    local first = font_names[1] or "none"
    local count = #font_names
    lurek.log.info("isBold = " .. tostring(v) .. " built_in_fonts=" .. count .. " first=" .. first)
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
    lurek.log.info("layer visible = " .. tostring(lurek.render.isLayerVisible("visibility_stub")))
    lurek.render.setLayerVisible("visibility_stub", false)
    lurek.log.info("layer visible after hide = " .. tostring(lurek.render.isLayerVisible("visibility_stub")))
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
    local enabled = lurek.render.isWireframe()
    lurek.render.rectangle("line", 0, 0, 10, 10)
    lurek.log.info("wireframe enabled = " .. tostring(enabled))
    lurek.render.setWireframe(false)
    lurek.log.info("wireframe enabled after reset = " .. tostring(lurek.render.isWireframe()))
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
    lurek.log.info("line and polyline drawn")
    lurek.log.info("polyline points = 6")
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
    local faces = model:getFaceCount()
    local normals = model:getNormalCount()
    local verts = model:getVertexCount()
    lurek.log.info("loadModel faces=" .. faces .. " normals=" .. normals .. " verts=" .. verts)
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
    local faces = model:getFaceCount()
    local verts = model:getVertexCount()
    local normals = model:getNormalCount()
    lurek.log.info("obj faces=" .. faces .. " verts=" .. verts .. " normals=" .. normals)
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
    lurek.log.info("canvas size = " .. w .. "x" .. h)
    lurek.log.info("canvas rendered and drawn back")
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
| [LDepthSorter](scene.md#ldepthsorter) | A fresh depth sorter with no queued entries. |

**Example**

```lua
do

    local sorter = lurek.render.newDepthSorter()
    sorter:add(function() lurek.log.info("draw layer A") end, 10)
    sorter:add(function() lurek.log.info("draw layer B") end, 5)
    sorter:flush()
    lurek.log.info("depth sorter type = " .. sorter:type())
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
    lurek.log.info("queued callbacks = " .. layer:getCount())
    layer:flush()
    lurek.log.info("queued callbacks after flush = " .. layer:getCount())
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
    lurek.log.info("newFont type = " .. font:type())
    lurek.log.info("newFont built from bundled size selector")
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
    lurek.log.info("image size = " .. w .. "x" .. h)
    lurek.log.info("newImage handle ready")
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
    lurek.log.info("current layer = " .. lurek.render.currentLayer())
    lurek.log.info("foreground z = " .. lurek.render.getLayerZOrder("foreground"))
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
    lurek.log.info("mesh vertex count = " .. mesh:getVertexCount())
    lurek.log.info("newMesh created triangles mesh")
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
    lurek.log.info("quad viewport = " .. x .. "," .. y .. "," .. w .. "," .. h)
    lurek.log.info("quad texture dims = " .. sw .. "x" .. sh)
end
```

---

### `lurek.render.newShader`

Compiles a target-aware WGSL fragment shader through the render module and returns a shader handle.

```lua
lurek.render.newShader(code, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `code` | string | WGSL fragment shader source. |
| `opts?` | table | Options table with optional `target` string: draw, postfx, image, overlay, particle, light, sprite, tilemap, mapviz, text, ui, or debugviz. Defaults to draw. |

**Returns**

| Type | Description |
|------|-------------|
| [LShader](#lshader) | The compiled shader handle. |

**Example**

```lua
do

    local code = "@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); }"
    local shader = lurek.render.newShader(code)
    shader:send("u_time", 0.25)
    local type_name = shader:type()
    lurek.log.info("compiled shader type=" .. type_name .. " has_u_time=" .. tostring(shader:hasUniform("u_time")))
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
    lurek.log.info("shape command count = " .. shape:getCommandCount())
    lurek.log.info("newShape drew retained commands")
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
    lurek.log.info("sprite batch count = " .. batch:getCount())
    lurek.log.info("last sprite index = " .. tostring(last))
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
    lurek.log.info("origin reset applied")
    lurek.log.info("origin rectangle drawn at screen origin")
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
    lurek.log.info("point size reset to 1")
    lurek.log.info("points drawn with flat and table inputs")
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
    lurek.log.info("polygon vertices = 5")
    lurek.log.info("polygon fill and line drawn")
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
    lurek.log.info("transform stack pop completed")
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
    local mode = lurek.render.getBlendMode()
    lurek.log.info("popLayer id=99 blend=" .. mode)
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
    lurek.log.info("print font type = " .. font:type())
    lurek.log.info("printed plain text")
end
```

---

### `lurek.render.printRich`

Draws rich text composed of individually styled spans at the given position.

```lua
lurek.render.printRich(spans, x, y, rotation, sx, sy, ox, oy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `spans` | table | Array of span tables, each with fields: text, r, g, b, a, scale. |
| `x` | number | X position. |
| `y` | number | Y position. |
| `rotation?` | number | Rotation in radians (default 0). |
| `sx?` | number | X scale factor (default 1). |
| `sy?` | number | Y scale factor (defaults to sx). |
| `ox?` | number | Origin offset X in text-local pixels (default 0). |
| `oy?` | number | Origin offset Y in text-local pixels (default 0). |

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
    lurek.log.info("rich spans = " .. #spans)
    lurek.log.info("rich text uses u8 colors")
end
```

---

### `lurek.render.printRichWithFont`

Draws rich text using a specific font without changing the global active font.

```lua
lurek.render.printRichWithFont(font, spans, x, y, rotation, sx, sy, ox, oy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `font` | [LFont](#lfont) | Font handle to use for this draw. |
| `spans` | table | Array of span tables, each with fields: text, r, g, b, a, scale. |
| `x` | number | X position. |
| `y` | number | Y position. |
| `rotation?` | number | Rotation in radians (default 0). |
| `sx?` | number | X scale factor (default 1). |
| `sy?` | number | Y scale factor (defaults to sx). |
| `ox?` | number | Origin offset X in text-local pixels (default 0). |
| `oy?` | number | Origin offset Y in text-local pixels (default 0). |

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
    lurek.log.info("printRichWithFont spans = " .. #spans)
    lurek.log.info("printRichWithFont uses byte colors")
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
    lurek.log.info("printRotated angle = " .. tostring(math.pi / 6))
    lurek.log.info("rotated text drawn")
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
    local ascent = lurek.render.getFontAscent(font)
    local width = lurek.render.getFontWidth(font, "Rotated text")
    lurek.log.info("printRotatedWithFont angle=" .. tostring(math.pi / 4) .. " ascent=" .. ascent .. " width=" .. width)
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
    local width = lurek.render.getFontWidth(font, "Standard text override")
    local height = lurek.render.getFontHeight(font)
    lurek.log.info("printWithFont width=" .. width .. " height=" .. height)
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
    lurek.log.info("printf limit = 220")
    lurek.log.info("printf align = center")
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
    local wrap_lines, wrap_width = font:getWrap("Formatted text inside a 160 px box.", 160)
    local first = wrap_lines[1] or ""
    lurek.log.info("printfWithFont limit=160 align=left lines=" .. #wrap_lines .. " width=" .. wrap_width .. " first=" .. first)
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
    lurek.log.info("transform stack push/pop used")
    lurek.log.info("translated, rotated, and scaled rectangle")
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
| `alpha?` | number | Layer opacity (0-1, default 1). |
| `blendMode?` | string | Blend mode: "alpha" (default), "add", "multiply", "replace", "screen". |

**Example**

```lua
do

    lurek.render.pushLayer(1, 0.65, "alpha")
    lurek.render.rectangle("fill", 320, 140, 60, 40)
    lurek.render.popLayer(1)
    lurek.log.info("pushLayer id = 1")
    lurek.log.info("popLayer matched id = 1")
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
    lurek.log.info("pushSortKey depth = 3")
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
    lurek.log.info("rectangle fill and rounded line drawn")
    lurek.log.info("rectangle width = 100")
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
    local w, h = canvas:getDimensions()
    lurek.log.info("resetCanvas called on " .. w .. "x" .. h .. " canvas")
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
    lurek.log.info("rotation angle = " .. tostring(math.pi / 4))
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
    local width = lurek.render.getWidth()
    local height = lurek.render.getHeight()
    local path = "save/test_screenshot.png"
    lurek.log.info("saveScreenshot requested for " .. path .. " from " .. width .. "x" .. height)
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
    lurek.log.info("scale = 2x2")
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
| `r` | number | Red channel (0-1). |
| `g` | number | Green channel (0-1). |
| `b` | number | Blue channel (0-1). |

**Example**

```lua
do

    lurek.render.setBackgroundColor(0.1, 0.1, 0.2)
    local r, g, b, a = lurek.render.getBackgroundColor()
    lurek.log.info("background = " .. r .. "," .. g .. "," .. b .. "," .. a)
    lurek.render.setBackgroundColor(0, 0, 0)
    lurek.log.info("background restored to black")
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
    lurek.log.info("blend before = " .. before)
    lurek.log.info("blend restored to alpha")
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
    lurek.log.info("bold after set = " .. tostring(lurek.render.isBold()))
    lurek.render.setBold(previous)
    lurek.log.info("bold restored = " .. tostring(lurek.render.isBold()))
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
    lurek.log.info("setCanvas switched to off-screen target")
    lurek.log.info("setCanvas restored to screen")
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
| `r` | number | Red channel (0-1). |
| `g` | number | Green channel (0-1). |
| `b` | number | Blue channel (0-1). |
| `a?` | number | Alpha channel (0-1, default 1). |

**Example**

```lua
do

    lurek.render.setColor(1, 0, 0, 1)
    local r, g, b, a = lurek.render.getColor()
    lurek.log.info("color = " .. r .. "," .. g .. "," .. b .. "," .. a)
    lurek.render.rectangle("fill", 340, 10, 40, 20)
    lurek.render.setColor(1, 1, 1, 1)
    lurek.log.info("color restored to white")
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
    lurek.log.info("mask = " .. tostring(r) .. "," .. tostring(g) .. "," .. tostring(b) .. "," .. tostring(a))
    lurek.render.setColorMask()
    lurek.log.info("color mask restored")
end
```

---

### `lurek.render.setDebugShader`

Activates a debugviz-target WGSL shader for subsequent diagnostic/debug draw commands. Pass nil to restore the normal draw shader state.

```lua
lurek.render.setDebugShader(shader)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `shader?` | [LShader](#lshader) | Shader created with `lurek.render.newShader(code, { target = "debugviz" })`, or nil for default debug rendering. |

**Example**

```lua
do

    local shader = lurek.render.newShader([[
@fragment
fn fs(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>, @location(2) pixel: vec2<f32>) -> @location(0) vec4<f32> {
    let heat = vec3<f32>(uv.x, 0.2 + uv.y * 0.5, 1.0 - uv.x);
    return vec4<f32>(mix(color.rgb, heat, 0.6 + pixel.x * 0.0), color.a);
}
]], { target = "debugviz" })
    lurek.render.setDebugShader(shader)
    lurek.render.rectangle("fill", 24, 24, 64, 20)
    lurek.render.circle("line", 56, 56, 18)
    lurek.render.setDebugShader(nil)
    lurek.log.info("debug shader target=" .. shader:getTarget())
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
    lurek.log.info("filter before = " .. min_before .. "," .. mag_before .. "," .. aniso_before)
    lurek.log.info("filter after = " .. min_after .. "," .. mag_after .. "," .. aniso_after)
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
    lurek.log.info("regular height = " .. regular:getHeight())
    lurek.log.info("bold height = " .. bold:getHeight())
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
    lurek.log.info("depth before = " .. mode_before .. "," .. tostring(write_before))
    lurek.log.info("depth after = " .. mode_after .. "," .. tostring(write_after))
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
    lurek.log.info("active font exists = " .. tostring(lurek.render.getFont() ~= nil))
    lurek.log.info("setFont tested with built-in font")
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
    local line_height = lurek.render.getFontLineHeight(font)
    local cell_width = lurek.render.getFontCellWidth(font)
    lurek.log.info("setFontLineHeight line_height=" .. line_height .. " cell_width=" .. cell_width)
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
    local current = lurek.render.currentLayer()
    local visible = lurek.render.isLayerVisible("set_layer_stub")
    lurek.log.info("current layer = " .. current .. " visible=" .. tostring(visible))
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
    local hidden = lurek.render.isLayerVisible("visible_layer_stub")
    lurek.log.info("layer visible after hide = " .. tostring(hidden))
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
    local z = lurek.render.getLayerZOrder("zorder_layer_stub")
    local visible = lurek.render.isLayerVisible("zorder_layer_stub")
    lurek.log.info("layer z order = " .. z .. " visible=" .. tostring(visible))
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
    lurek.log.info("line width set to 4")
    lurek.render.setLineWidth(1)
    lurek.log.info("line width restored to 1")
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
    lurek.log.info("point size set to 6")
    lurek.render.setPointSize(1)
    lurek.log.info("point size restored")
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
    lurek.log.info("scissor = " .. x .. "," .. y .. "," .. w .. "," .. h)
    lurek.log.info("scissor cleared")
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
    lurek.log.info("setShader activated custom shader")
    lurek.render.setShader(nil)
    lurek.log.info("shader restored to default")
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
    lurek.log.info("stencil mode = " .. action .. "," .. compare .. "," .. value)
    lurek.render.clearStencil()
    lurek.log.info("stencil state cleared")
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
    local action, compare, value = lurek.render.getStencilMode()
    lurek.log.info("setStencilTest enabled and cleared with mode " .. action .. "," .. compare .. "," .. value)
end
```

---

### `lurek.render.setTextShader`

Activates a text-target WGSL shader for subsequent font-atlas text draws. Pass nil to restore default text rendering.

```lua
lurek.render.setTextShader(shader)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `shader?` | [LShader](#lshader) | Shader created with `lurek.render.newShader(code, { target = "text" })`, or nil for default. |

**Example**

```lua
do

    local shader = lurek.render.newShader([[
@fragment
fn fs(
    @location(0) color: vec4<f32>,
    @location(1) uv: vec2<f32>,
    @location(2) pixel: vec2<f32>,
    @location(3) resolution: vec2<f32>,
    @location(4) texel: vec2<f32>
) -> @location(0) vec4<f32> {
    return vec4<f32>(color.rgb * vec3<f32>(0.7, 0.95, 1.2) + uv.xyx * 0.0 + pixel.xyx * 0.0 + resolution.xyx * texel.x * 0.0, color.a);
}
]], { target = "text" })
    lurek.render.setTextShader(shader)
    lurek.render.print("text shader", 24, 48)
    lurek.render.setTextShader(nil)
    lurek.log.info("text shader target=" .. shader:getTarget())
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

    lurek.log.info("wireframe before = " .. tostring(lurek.render.isWireframe()))
    lurek.render.setWireframe(true)
    lurek.render.rectangle("fill", 260, 140, 50, 50)
    lurek.render.setWireframe(false)
    lurek.log.info("wireframe restored = " .. tostring(lurek.render.isWireframe()))
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
    lurek.log.info("shear kx = 0.3")
    lurek.log.info("sheared rectangle drawn")
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
    lurek.log.info("stencil write value = 1")
    lurek.log.info("stencil test cleared")
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
    lurek.log.info("translation = 50,50")
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
    lurek.log.info("triangle fill and line drawn")
    lurek.log.info("triangle count = 2")
end
```

---

## Module Fields

*No module-level fields documented.*

## Callback Parameters

- `lurek.render.captureScreenshot` param `callback` (`function`): Called with an LImageData argument.

## Enums

*No module-specific enums documented.*

## Types

- [LCanvas](#lcanvas)
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

#### `LCanvas:applyShader`

Queues a postfx shader pass that mutates this canvas render target after queued canvas draws in the current frame.

```lua
LCanvas:applyShader(shader, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `shader` | [LShader](#lshader) | Shader created with `lurek.render.newShader(code, { target = "postfx" })`. |
| `opts?` | table | Reserved options table for future pass parameters. |

**Returns**

| Type | Description |
|------|-------------|
| [LCanvas](#lcanvas) | This canvas handle. |

**Example**

```lua
do

    local code = [[
@fragment
fn fs_main(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>) -> @location(0) vec4<f32> {
    let tint = vec3<f32>(uv.x, 0.4, 1.0 - uv.y);
    return vec4<f32>(mix(color.rgb, tint, 0.35), color.a);
}
]]
    local shader = lurek.render.newShader(code, { target = "postfx" })
    local canvas = lurek.render.newCanvas(96, 96)
    lurek.render.setCanvas(canvas)
    lurek.render.circle("fill", 48, 48, 32)
    lurek.render.setCanvas(nil)
    canvas:applyShader(shader)
    lurek.render.draw(canvas, 230, 70)
    lurek.log.info("LCanvas shader target = " .. shader:getTarget())
    lurek.log.info("queued LCanvas:applyShader")
end
```

---

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
    lurek.log.info("canvas dimensions = " .. w .. "x" .. h)
    lurek.log.info("canvas type = " .. canvas:type())
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
    local height = canvas:getHeight()
    local width = canvas:getWidth()
    local dims = width .. "x" .. height
    lurek.log.info("canvas height=" .. height .. " dims=" .. dims)
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
    local width = canvas:getWidth()
    local is_canvas = canvas:typeOf("LCanvas")
    local height = canvas:getHeight()
    lurek.log.info("canvas width=" .. width .. " height=" .. height .. " is_canvas=" .. tostring(is_canvas))
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
    local w, h = canvas:getDimensions()
    local released = canvas:release()
    local pixels = w * h
    lurek.log.info("canvas " .. w .. "x" .. h .. " pixels=" .. pixels .. " released=" .. tostring(released))
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
    local type_name = canvas:type()
    local is_canvas = canvas:typeOf("LCanvas")
    local w, h = canvas:getDimensions()
    lurek.log.info(type_name .. " is_canvas=" .. tostring(is_canvas) .. " size=" .. w .. "x" .. h)
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
    local is_canvas = canvas:typeOf("LCanvas")
    local is_object = canvas:typeOf("LObject")
    local w = canvas:getWidth()
    lurek.log.info("canvas typeOf LCanvas=" .. tostring(is_canvas) .. " LObject=" .. tostring(is_object) .. " width=" .. w)
    canvas:release()
end
```

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
    lurek.log.info("draw layer count after clear = " .. layer:getCount())
    lurek.log.info("draw layer type = " .. layer:type())
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
    lurek.log.info("draw layer count before flush = " .. layer:getCount())
    layer:flush()
    lurek.log.info("draw layer count after flush = " .. layer:getCount())
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
    lurek.log.info("draw layer count = " .. layer:getCount())
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
    lurek.log.info("draw layer count after queue = " .. layer:getCount())
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
    layer:queue(1, function() lurek.render.rectangle("fill", 0, 0, 4, 4) end)
    local type_name = layer:type()
    local is_layer = layer:typeOf("LDrawLayer")
    lurek.log.info(type_name .. " is_layer=" .. tostring(is_layer) .. " queued=" .. layer:getCount())
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
    layer:queue(2, function() lurek.render.circle("fill", 4, 4, 2) end)
    local is_layer = layer:typeOf("LDrawLayer")
    local is_object = layer:typeOf("LObject")
    lurek.log.info("draw layer typeOf LDrawLayer=" .. tostring(is_layer) .. " LObject=" .. tostring(is_object) .. " queued=" .. layer:getCount())
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
    local ascent = font:getAscent()
    local descent = font:getDescent()
    local height = font:getHeight()
    lurek.log.info("font ascent=" .. ascent .. " descent=" .. descent .. " height=" .. height)
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
    local descent = font:getDescent()
    local width = font:getWidth("Test")
    local ascent = font:getAscent()
    lurek.log.info("font descent=" .. descent .. " ascent=" .. ascent .. " sample_width=" .. width)
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
    local height = font:getHeight()
    local line_height = font:getLineHeight()
    local sample_width = font:getWidth("HUD")
    lurek.log.info("font height=" .. height .. " line_height=" .. line_height .. " sample_width=" .. sample_width)
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
    local line_height = font:getLineHeight()
    local ascent = font:getAscent()
    local descent = font:getDescent()
    lurek.log.info("font line height=" .. line_height .. " ascent=" .. ascent .. " descent=" .. descent)
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
    local width = font:getWidth("Inventory")
    local height = font:getHeight()
    local line_height = font:getLineHeight()
    lurek.log.info("font width=" .. width .. " height=" .. height .. " line_height=" .. line_height)
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
    local first = lines[1] or ""
    local line_height = font:getLineHeight()
    lurek.log.info("wrapped lines=" .. #lines .. " width=" .. width .. " line_height=" .. line_height .. " first=" .. first)
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
    local width = font:getWidth("HUD")
    local released = font:release()
    local alive_type = font:type()
    lurek.log.info("font type=" .. alive_type .. " width before release=" .. width .. " released=" .. tostring(released))
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
    local line_height = font:getLineHeight()
    local height = font:getHeight()
    lurek.log.info("font line height=" .. line_height .. " height=" .. height)
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
    local type_name = font:type()
    local height = font:getHeight()
    local ascent = font:getAscent()
    lurek.log.info(type_name .. " height=" .. height .. " ascent=" .. ascent)
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
    local is_font = font:typeOf("LFont")
    local is_object = font:typeOf("LObject")
    local line_height = font:getLineHeight()
    lurek.log.info("font typeOf LFont=" .. tostring(is_font) .. " LObject=" .. tostring(is_object) .. " line_height=" .. line_height)
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
    lurek.log.info("image dimensions = " .. w .. "x" .. h)
    lurek.log.info("image type = " .. image:type())
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
    local height = image:getHeight()
    local width = image:getWidth()
    local id = image:getId()
    lurek.log.info("image height=" .. height .. " width=" .. width .. " id=" .. id)
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
    local id = image:getId()
    local w, h = image:getDimensions()
    lurek.log.info("texture id=" .. id .. " size=" .. w .. "x" .. h)
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
    local width = image:getWidth()
    local height = image:getHeight()
    local id = image:getId()
    lurek.log.info("image width=" .. width .. " height=" .. height .. " id=" .. id)
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
    local before_id = image:getId()
    local before_w = image:getWidth()
    local released = image:release()
    lurek.log.info("image " .. before_id .. " width=" .. before_w .. " released=" .. tostring(released))
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
    local type_name = image:type()
    local is_image = image:typeOf("LImage")
    local id = image:getId()
    lurek.log.info(type_name .. " is_image=" .. tostring(is_image) .. " id=" .. id)
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
    local is_image = image:typeOf("LImage")
    local is_object = image:typeOf("LObject")
    local w = image:getWidth()
    lurek.log.info("image typeOf LImage=" .. tostring(is_image) .. " LObject=" .. tostring(is_object) .. " width=" .. w)
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

#### `LImageData:applyEffect`

Applies a named image effect in place, or returns a new image when the effect changes size.

```lua
LImageData:applyEffect(name, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Effect name. |
| `opts?` | table | Effect options such as `factor`, `amount`, `radius`, `levels`, `region`, or `color`. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | nil | New image for size-changing effects, otherwise nil. |

---

#### `LImageData:applyEffects`

Applies a sequence of named effects in order.

```lua
LImageData:applyEffects(effects, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `effects` | table | Array of effect names or `{name=..., opts=...}` tables. |
| `opts?` | table | Default options used by string entries. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | nil | Last new image returned by a size-changing effect, otherwise nil. |

---

#### `LImageData:applyMask`

Multiplies this image alpha by another image's alpha channel.

```lua
LImageData:applyMask(mask)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mask` | [LImageData](#limagedata) | Same-sized alpha mask image. |

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

#### `LImageData:applyShader`

Applies an offline image shader and returns the processed image.

```lua
LImageData:applyShader(shader, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `shader` | [LShader](#lshader) | Image-target shader. |
| `opts?` | table | Optional processing options. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Processed image. |

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

#### `LImageData:clone`

Returns a deep copy of this image data.

```lua
LImageData:clone()
```

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Copied image data. |

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

#### `LImageData:copyRegion`

Copies a rectangular region into a new image.

```lua
LImageData:copyRegion(x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Source x coordinate. |
| `y` | number | Source y coordinate. |
| `w` | number | Region width. |
| `h` | number | Region height. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Copied region. |

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

#### `LImageData:transform`

Returns a transformed image, currently supporting high-quality resize through `width`, `height`, and `filter`.

```lua
LImageData:transform(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts?` | table | Transform options. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Transformed image. |

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
    lurek.log.info("mesh v2 = " .. x .. "," .. y .. "," .. u .. "," .. v)
    lurek.log.info("mesh v2 color = " .. r .. "," .. g .. "," .. b .. "," .. a)
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
    lurek.log.info("mesh vertex count = " .. mesh:getVertexCount())
    lurek.log.info("mesh type = " .. mesh:type())
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
    lurek.log.info("mesh released = " .. tostring(mesh:release()))
    lurek.log.info("mesh release tested")
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
    lurek.log.info("mesh texture set from image")
    lurek.log.info("mesh type = " .. mesh:type())
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
    lurek.log.info("mesh v1 = " .. x .. "," .. y .. "," .. r .. "," .. g .. "," .. b .. "," .. a)
    lurek.log.info("setVertex applied to index 1")
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
    lurek.log.info("mesh type = " .. mesh:type())
    lurek.log.info("mesh typeOf LMesh = " .. tostring(mesh:typeOf("LMesh")))
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
    lurek.log.info("mesh typeOf LMesh = " .. tostring(mesh:typeOf("LMesh")))
    lurek.log.info("mesh bounds ready = " .. tostring(mesh:getVertexCount() > 0))
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
    local slice = lurek.sprite.newNineSlice(image, 4, 4, 4, 4)
    local top, right, bottom, left = slice:getInsets()
    lurek.log.info("nine-slice insets = " .. top .. "," .. right .. "," .. bottom .. "," .. left)
    lurek.log.info("nine-slice type = " .. slice:type())
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
    local slice = lurek.sprite.newNineSlice(image, 4, 4, 4, 4)
    local w, h = slice:getTextureSize()
    lurek.log.info("nine-slice texture size = " .. w .. "x" .. h)
    lurek.log.info("nine-slice typeOf = " .. tostring(slice:typeOf("LNineSlice")))
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
    local slice = lurek.sprite.newNineSlice(image, 4, 4, 4, 4)
    lurek.log.info("nine-slice type = " .. slice:type())
    lurek.log.info("nine-slice texture width = " .. select(1, slice:getTextureSize()))
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
    local slice = lurek.sprite.newNineSlice(image, 2, 2, 2, 2)
    lurek.log.info("nine-slice typeOf LNineSlice = " .. tostring(slice:typeOf("LNineSlice")))
    lurek.log.info("nine-slice width sample = 140")
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
    local faces = model:getFaceCount()
    local verts = model:getVertexCount()
    local normals = model:getNormalCount()
    lurek.log.info("model faces=" .. faces .. " verts=" .. verts .. " normals=" .. normals)
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
    local normals = model:getNormalCount()
    local faces = model:getFaceCount()
    local uvs = model:getUvCount()
    lurek.log.info("model normals=" .. normals .. " faces=" .. faces .. " uvs=" .. uvs)
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
    local uvs = model:getUvCount()
    local verts = model:getVertexCount()
    local faces = model:getFaceCount()
    lurek.log.info("model uvs=" .. uvs .. " verts=" .. verts .. " faces=" .. faces)
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
    local verts = model:getVertexCount()
    local uvs = model:getUvCount()
    local normals = model:getNormalCount()
    lurek.log.info("model verts=" .. verts .. " uvs=" .. uvs .. " normals=" .. normals)
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
    lurek.log.info("projected vertex rows = " .. #vertices)
    lurek.log.info("projectToMesh camera fov = " .. camera.fov)
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
| `rotation?` | number | Rotation step (0-3, each step = 90 degrees, default 0). |

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
    lurek.log.info("rendered model image = " .. image:getWidth() .. "x" .. image:getHeight())
    lurek.log.info("renderToImage rotation step = 0")
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
    local vx, vy, vw, vh = quad:getViewport()
    local area = vw * vh
    lurek.log.info("quad texture=" .. w .. "x" .. h .. " viewport=" .. vx .. "," .. vy .. "," .. vw .. "," .. vh .. " area=" .. area)
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
    local tex_w, tex_h = quad:getTextureDimensions()
    local area = w * h
    lurek.log.info("quad viewport=" .. x .. "," .. y .. "," .. w .. "," .. h .. " tex=" .. tex_w .. "x" .. tex_h .. " area=" .. area)
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
    local tex_w, tex_h = quad:getTextureDimensions()
    lurek.log.info("quad viewport after set=" .. x .. "," .. y .. "," .. w .. "," .. h .. " tex=" .. tex_w .. "x" .. tex_h)
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
    local type_name = quad:type()
    local is_quad = quad:typeOf("LQuad")
    local x, y, w, h = quad:getViewport()
    lurek.log.info(type_name .. " is_quad=" .. tostring(is_quad) .. " viewport=" .. x .. "," .. y .. "," .. w .. "," .. h)
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
    local is_quad = quad:typeOf("LQuad")
    local is_object = quad:typeOf("LObject")
    local tex_w, tex_h = quad:getTextureDimensions()
    lurek.log.info("quad typeOf LQuad=" .. tostring(is_quad) .. " LObject=" .. tostring(is_object) .. " tex=" .. tex_w .. "x" .. tex_h)
end
```

---

## LShader

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LShader:getDiagnostics`

Returns shader validation diagnostics.

```lua
LShader:getDiagnostics()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Array of diagnostic strings. |

**Example**

```lua
do

    local code = "@fragment fn fs(@location(0) color: vec4<f32>) -> @location(0) vec4<f32> { return color; }"
    local shader = lurek.render.newShader(code)
    local diagnostics = shader:getDiagnostics()
    local first = diagnostics[1] or ""
    lurek.log.info("shader diagnostics = " .. first)
end
```

---

#### `LShader:getId`

Returns the internal numeric handle ID for this shader.

```lua
LShader:getId()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Opaque shader handle identifier. |

**Example**

```lua
do

    local code = "@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); }"
    local shader = lurek.render.newShader(code)
    local id = shader:getId()
    lurek.log.info("shader id = " .. tostring(id))
    lurek.log.info("shader id numeric = " .. tostring(type(id) == "number"))
end
```

---

#### `LShader:getTarget`

Returns the target this shader was validated for.

```lua
LShader:getTarget()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Shader target name. |

**Example**

```lua
do

    local code = "@fragment fn fs(@location(0) color: vec4<f32>) -> @location(0) vec4<f32> { return color; }"
    local shader = lurek.render.newShader(code, { target = "draw" })
    local target = shader:getTarget()
    local id = shader:getId()
    lurek.log.info("shader target = " .. target .. " id=" .. tostring(id))
end
```

---

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
    lurek.log.info("has u_time before send = " .. tostring(shader:hasUniform("u_time")))
    shader:send("u_time", 0.5)
    lurek.log.info("has u_time after send = " .. tostring(shader:hasUniform("u_time")))
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
    lurek.log.info("shader released = " .. tostring(released))
    lurek.log.info("shader release tested")
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
    lurek.log.info("has u_time before send = " .. tostring(shader:hasUniform("u_time")))
    shader:send("u_time", 1.5)
    lurek.log.info("has u_time after send = " .. tostring(shader:hasUniform("u_time")))
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
    lurek.log.info("shader type = " .. shader:type())
    lurek.log.info("shader has u_time = " .. tostring(shader:hasUniform("u_time")))
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
    lurek.log.info("shader typeOf LShader = " .. tostring(shader:typeOf("LShader")))
    lurek.log.info("shader source bytes = " .. tostring(#code))
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
    lurek.log.info("shape command count = " .. shape:getCommandCount())
    lurek.log.info("shape arc added")
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
    lurek.log.info("shape command count = " .. shape:getCommandCount())
    lurek.log.info("shape circle added")
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
    lurek.log.info("shape commands before clear = " .. shape:getCommandCount())
    shape:clear()
    lurek.log.info("shape commands after clear = " .. shape:getCommandCount())
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
    lurek.log.info("shape command count = " .. shape:getCommandCount())
    lurek.log.info("shape draw called")
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
    shape:setColor(0.4, 0.8, 1.0, 1.0)
    local count = shape:getCommandCount()
    lurek.log.info("shape ellipse commands=" .. count)
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
    lurek.log.info("shape commands before clear = " .. before)
    lurek.log.info("shape commands after clear = " .. after)
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
    shape:setLineWidth(3)
    local count = shape:getCommandCount()
    lurek.log.info("shape line commands=" .. count)
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
    lurek.log.info("shape polygon commands = " .. shape:getCommandCount())
    lurek.log.info("shape polygon drawn")
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
    lurek.log.info("shape polyline commands = " .. shape:getCommandCount())
    lurek.log.info("shape polyline drawn")
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
    shape:setColor(0.9, 0.4, 0.2, 1.0)
    local count = shape:getCommandCount()
    lurek.log.info("shape rectangle commands=" .. count)
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
    lurek.log.info("shape rounded rectangle commands = " .. shape:getCommandCount())
    lurek.log.info("shape rounded rectangle drawn")
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
| `r` | number | Red channel (0-1). |
| `g` | number | Green channel (0-1). |
| `b` | number | Blue channel (0-1). |
| `a?` | number | Alpha channel (0-1, default 1). |

**Example**

```lua
do

    local shape = lurek.render.newShape()
    shape:setColor(0.8, 0.2, 0.8, 1)
    shape:rectangle("fill", 0, 0, 20, 20)
    lurek.log.info("shape command count = " .. shape:getCommandCount())
    lurek.log.info("shape color set before rectangle")
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
    lurek.log.info("shape command count = " .. shape:getCommandCount())
    lurek.log.info("shape line width set to 2")
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
    lurek.log.info("shape command count = " .. shape:getCommandCount())
    lurek.log.info("shape triangle added")
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
    shape:rectangle("fill", 0, 0, 16, 12)
    local type_name = shape:type()
    local count = shape:getCommandCount()
    lurek.log.info(type_name .. " commands=" .. count .. " is_shape=" .. tostring(shape:typeOf("LShape")))
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
    shape:line(0, 0, 12, 12)
    local is_shape = shape:typeOf("LShape")
    local is_object = shape:typeOf("LObject")
    lurek.log.info("shape typeOf LShape=" .. tostring(is_shape) .. " LObject=" .. tostring(is_object) .. " commands=" .. shape:getCommandCount())
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
    lurek.log.info("sprite id = " .. tostring(id))
    lurek.log.info("sprite count = " .. batch:getCount())
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
    lurek.log.info("sprite count after clear = " .. batch:getCount())
    lurek.log.info("sprite batch type = " .. batch:type())
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
    lurek.log.info("sprite batch buffer size = " .. batch:getBufferSize())
    lurek.log.info("sprite batch count = " .. batch:getCount())
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
    lurek.log.info("sprite batch count = " .. batch:getCount())
    lurek.log.info("sprite batch typeOf = " .. tostring(batch:typeOf("LSpriteBatch")))
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
    lurek.log.info("batch released = " .. tostring(released))
    lurek.log.info("batch release tested")
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
    lurek.log.info("batch type = " .. batch:type())
    lurek.log.info("batch typeOf LSpriteBatch = " .. tostring(batch:typeOf("LSpriteBatch")))
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
    lurek.log.info("batch typeOf LSpriteBatch = " .. tostring(batch:typeOf("LSpriteBatch")))
    lurek.log.info("batch capacity = 8")
    batch:release()
end
```

---
