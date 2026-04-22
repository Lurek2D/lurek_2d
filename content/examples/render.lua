-- content/examples/render.lua
-- love2d-style usage snippets for the lurek.render API (183 items).
-- Each --@api-stub: block is a copy-pastable snippet showing the API
-- in real context (callbacks, conditionals, real arg values).
-- Run: cargo run -- content/examples/render.lua

-- ── lurek.render.* functions ──

--@api-stub: lurek.render.setColor
-- Sets the current drawing color.
-- Apply at startup or in response to user input.
function lurek.render()
  lurek.render.setColor(1, 0.5, 0, 1)  -- orange
  lurek.render.rectangle("fill", 0, 0, 100, 100)
  lurek.render.setColor(1, 1, 1, 1)    -- reset
end

--@api-stub: lurek.render.getColor
-- Returns the current drawing color.
-- Cheap to call; safe inside callbacks.
local value = lurek.render.getColor()
print("getColor:", value)
return value

--@api-stub: lurek.render.setBackgroundColor
-- Sets the background clear color.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.render.setBackgroundColor(1, 0.5, 0)
print("setBackgroundColor applied")
print("ok")

--@api-stub: lurek.render.getBackgroundColor
-- Returns the current background color.
-- Cheap to call; safe inside callbacks.
local value = lurek.render.getBackgroundColor()
print("getBackgroundColor:", value)
return value

--@api-stub: lurek.render.rectangle
-- Draws a filled or outlined axis-aligned rectangle at the given position.
-- Place inside `function lurek.render() ... end`.
function lurek.render()
  lurek.render.setColor(1, 0.5, 0, 1)
  lurek.render.rectangle("fill", 100, 100, 64, 64)
  lurek.render.rectangle("line", 100, 200, 64, 64)
end

--@api-stub: lurek.render.circle
-- Draws a filled or outlined circle at the given world-space position.
-- Place inside `function lurek.render() ... end`.
function lurek.render()
  lurek.render.setColor(0, 1, 0, 1)
  lurek.render.circle("line", 200, 200, 32)
end

--@api-stub: lurek.render.ellipse
-- Draws a filled or outlined ellipse with independent x/y radii.
-- Place inside `function lurek.render() ... end`.
function lurek.render()
  lurek.render.ellipse(mode, 100, 100, rx, ry)
end

--@api-stub: lurek.render.triangle
-- Draws a filled or outlined triangle connecting three world-space vertices.
-- See the module spec for detailed semantics.
local result = lurek.render.triangle(mode, x1, y1, x2, y2, x3, y3)
print("triangle:", result)
return result

--@api-stub: lurek.render.line
-- Draws a line between two points.
-- Place inside `function lurek.render() ... end`.
function lurek.render()
  lurek.render.setColor(1, 1, 1, 1)
  lurek.render.line(0, 0, 800, 600)
end

--@api-stub: lurek.render.polygon
-- Draws a polygon from a list of vertices.
-- Place inside `function lurek.render() ... end`.
function lurek.render()
  lurek.render.polygon({ x = 0, y = 0 })
end

--@api-stub: lurek.render.arc
-- Draws a partial circle arc at the given position with specified radius and angle range.
-- Place inside `function lurek.render() ... end`.
function lurek.render()
  lurek.render.arc()
end

--@api-stub: lurek.render.points
-- Draws a batch of individual points at the specified world-space coordinates.
-- Place inside `function lurek.render() ... end`.
function lurek.render()
  lurek.render.points({ x = 0, y = 0 })
end

--@api-stub: lurek.render.draw
-- Draws a drawable (Image, Canvas, SpriteBatch, Mesh) at the given position.
-- Place inside `function lurek.render() ... end`.
local img = lurek.image.newImage("img/player.png")
function lurek.render()
  lurek.render.draw(img, 100, 100)
end

--@api-stub: lurek.render.drawq
-- Draws a portion of an image defined by a Quad.
-- See the module spec for detailed semantics.
local result = lurek.render.drawq()
print("drawq:", result)
return result

--@api-stub: lurek.render.print
-- Draws text at the given position.
-- Place inside `function lurek.render() ... end`.
function lurek.render()
  lurek.render.setColor(1, 1, 1, 1)
  lurek.render.print("Score: " .. score, 10, 10)
end

--@api-stub: lurek.render.printf
-- Draws word-wrapped text within a given width.
-- See the module spec for detailed semantics.
local result = lurek.render.printf("hello", 100, 100, limit, align)
print("printf:", result)
return result

--@api-stub: lurek.render.printRich
-- Draws a sequence of individually-styled text spans at `(x, y)`.
-- See the module spec for detailed semantics.
local result = lurek.render.printRich({ x = 0, y = 0 }, 100, 100)
print("printRich:", result)
return result

--@api-stub: lurek.render.clear
-- Clears the draw command queue (resets the screen).
-- Pair with the matching constructor to free resources.
function lurek.render()
  lurek.render.clear(0, 0, 0.1, 1)  -- dark blue
  drawWorld()
end

--@api-stub: lurek.render.setLineWidth
-- Sets the line width for outline drawing.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.render.setLineWidth(64)
print("setLineWidth applied")
print("ok")

--@api-stub: lurek.render.getLineWidth
-- Returns the current line width.
-- Cheap to call; safe inside callbacks.
local value = lurek.render.getLineWidth()
print("getLineWidth:", value)
return value

--@api-stub: lurek.render.setPointSize
-- Sets the point diameter in pixels.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.render.setPointSize(10)
print("setPointSize applied")
print("ok")

--@api-stub: lurek.render.getPointSize
-- Returns the current point size.
-- Cheap to call; safe inside callbacks.
local value = lurek.render.getPointSize()
print("getPointSize:", value)
return value

--@api-stub: lurek.render.setBlendMode
-- Sets the blend mode for drawing.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.render.setBlendMode(mode)
print("setBlendMode applied")
print("ok")

--@api-stub: lurek.render.getBlendMode
-- Returns the current blend mode as a string.
-- Cheap to call; safe inside callbacks.
local value = lurek.render.getBlendMode()
print("getBlendMode:", value)
return value

--@api-stub: lurek.render.newFont
-- Loads a bitmap font PNG from a file, or selects a built-in size by pixel height.
-- Build once at startup; reuse across frames.
local font = lurek.render.newFont({ x = 0, y = 0 })
print("created", font)
return font

--@api-stub: lurek.render.setFont
-- Sets the active font for print calls.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.render.setFont(ud)
print("setFont applied")
print("ok")

--@api-stub: lurek.render.getFont
-- Returns the currently active font, or nil.
-- Cheap to call; safe inside callbacks.
local value = lurek.render.getFont()
print("getFont:", value)
return value

--@api-stub: lurek.render.getFontSizes
-- Returns a table of available built-in font pixel heights.
-- Cheap to call; safe inside callbacks.
local value = lurek.render.getFontSizes()
print("getFontSizes:", value)
return value

--@api-stub: lurek.render.getDefaultFont
-- Returns a built-in font by pixel height (snaps to nearest available size).
-- Cheap to call; safe inside callbacks.
local value = lurek.render.getDefaultFont(pixel_height)
print("getDefaultFont:", value)
return value

--@api-stub: lurek.render.getFontCellWidth
-- Returns the cell width of the given font (for monospaced bitmap fonts).
-- Cheap to call; safe inside callbacks.
local value = lurek.render.getFontCellWidth(ud)
print("getFontCellWidth:", value)
return value

--@api-stub: lurek.render.getFontWidth
-- Returns the pixel width of text in the given font.
-- Cheap to call; safe inside callbacks.
local value = lurek.render.getFontWidth(ud, "hello")
print("getFontWidth:", value)
return value

--@api-stub: lurek.render.getFontHeight
-- Returns the line height of the given font.
-- Cheap to call; safe inside callbacks.
local value = lurek.render.getFontHeight(ud)
print("getFontHeight:", value)
return value

--@api-stub: lurek.render.getFontLineHeight
-- Returns the line height of the given font (alias for getFontHeight).
-- Cheap to call; safe inside callbacks.
local value = lurek.render.getFontLineHeight(ud)
print("getFontLineHeight:", value)
return value

--@api-stub: lurek.render.setFontLineHeight
-- Sets the line height of the given font (stub â€” returns nil; fonts are immutable in headless mode).
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.render.setFontLineHeight(font, lh)
print("setFontLineHeight applied")
print("ok")

--@api-stub: lurek.render.getFontAscent
-- Returns the ascent of the given font.
-- Cheap to call; safe inside callbacks.
local value = lurek.render.getFontAscent(ud)
print("getFontAscent:", value)
return value

--@api-stub: lurek.render.getFontDescent
-- Returns the descent of the given font.
-- Cheap to call; safe inside callbacks.
local value = lurek.render.getFontDescent(ud)
print("getFontDescent:", value)
return value

--@api-stub: lurek.render.getFontWrap
-- Returns wrapped lines and the maximum line width.
-- Cheap to call; safe inside callbacks.
local value = lurek.render.getFontWrap("hello", limit)
print("getFontWrap:", value)
return value

--@api-stub: lurek.render.newImage
-- Loads an image from a file path or creates one from ImageData.
-- Build once at startup; reuse across frames.
local image = lurek.render.newImage(arg)
print("created", image)
return image

--@api-stub: lurek.render.newCanvas
-- Creates an off-screen render canvas.
-- Build once at startup; reuse across frames.
local canvas = lurek.render.newCanvas(64, 64)
print("created", canvas)
return canvas

--@api-stub: lurek.render.setCanvas
-- Sets the active render target to a Canvas, or back to the screen.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.render.setCanvas(ud)
print("setCanvas applied")
print("ok")

--@api-stub: lurek.render.getCanvas
-- Returns the current canvas, or nil if drawing to screen.
-- Cheap to call; safe inside callbacks.
local value = lurek.render.getCanvas()
print("getCanvas:", value)
return value

--@api-stub: lurek.render.getCanvasSize
-- Returns the dimensions of a canvas.
-- Cheap to call; safe inside callbacks.
local value = lurek.render.getCanvasSize(ud)
print("getCanvasSize:", value)
return value

--@api-stub: lurek.render.newSpriteBatch
-- Creates a new sprite batch for the given image.
-- Build once at startup; reuse across frames.
local spritebatch = lurek.render.newSpriteBatch(ud, 100)
print("created", spritebatch)
return spritebatch

--@api-stub: lurek.render.newMesh
-- Creates a custom mesh from vertex data.
-- Build once at startup; reuse across frames.
local mesh = lurek.render.newMesh(verts, mode)
print("created", mesh)
return mesh

--@api-stub: lurek.render.newShader
-- Compiles a custom WGSL shader and returns its handle.
-- Build once at startup; reuse across frames.
local shader = lurek.render.newShader(code)
print("created", shader)
return shader

--@api-stub: lurek.render.setShader
-- Sets the active shader, or clears it.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.render.setShader(ud)
print("setShader applied")
print("ok")

--@api-stub: lurek.render.getShader
-- Returns the active shader, or nil.
-- Cheap to call; safe inside callbacks.
local value = lurek.render.getShader()
print("getShader:", value)
return value

--@api-stub: lurek.render.newQuad
-- Creates a new Quad viewport into a texture.
-- Build once at startup; reuse across frames.
local quad = lurek.render.newQuad(100, 100, 64, 64, sw, sh)
print("created", quad)
return quad

--@api-stub: lurek.render.push
-- Pushes the current transform onto the stack.
-- Side-effecting; safe to call any time after init.
lurek.render.push()
-- mutator; side effect applied
print("push done")
print("ok")

--@api-stub: lurek.render.pop
-- Pops the transform from the stack.
-- Pair with the matching constructor to free resources.
-- release the resource and forget the handle
lurek.render.pop()
print("pop done")
print("ok")

--@api-stub: lurek.render.translate
-- Translates the coordinate system.
-- See the module spec for detailed semantics.
function lurek.render()
  lurek.render.translate(-camera.x, -camera.y)
  drawWorld()
end

--@api-stub: lurek.render.rotate
-- Rotates the coordinate system.
-- See the module spec for detailed semantics.
local result = lurek.render.rotate(0)
print("rotate:", result)
return result

--@api-stub: lurek.render.scale
-- Scales the coordinate system.
-- See the module spec for detailed semantics.
local result = lurek.render.scale(sx, sy)
print("scale:", result)
return result

--@api-stub: lurek.render.shear
-- Shears the coordinate system.
-- See the module spec for detailed semantics.
local result = lurek.render.shear(kx, ky)
print("shear:", result)
return result

--@api-stub: lurek.render.origin
-- Resets the transform to the identity.
-- See the module spec for detailed semantics.
local result = lurek.render.origin()
print("origin:", result)
return result

--@api-stub: lurek.render.applyTransform
-- Applies an affine transform matrix.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.render.applyTransform(mat)
print("applyTransform applied")
print("ok")

--@api-stub: lurek.render.setScissor
-- Restricts drawing to a rectangle, or clears scissor if no args.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.render.setScissor({ x = 0, y = 0 })
print("setScissor applied")
print("ok")

--@api-stub: lurek.render.getScissor
-- Returns the active scissor rectangle, or nothing.
-- Cheap to call; safe inside callbacks.
local value = lurek.render.getScissor()
print("getScissor:", value)
return value

--@api-stub: lurek.render.intersectScissor
-- Intersects the current scissor with a new rectangle.
-- See the module spec for detailed semantics.
local result = lurek.render.intersectScissor(100, 100, 64, 64)
print("intersectScissor:", result)
return result

--@api-stub: lurek.render.setColorMask
-- Sets which RGBA channels are written.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.render.setColorMask({ x = 0, y = 0 })
print("setColorMask applied")
print("ok")

--@api-stub: lurek.render.getColorMask
-- Returns the current color mask.
-- Cheap to call; safe inside callbacks.
local value = lurek.render.getColorMask()
print("getColorMask:", value)
return value

--@api-stub: lurek.render.setWireframe
-- Enables or disables wireframe rendering.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.render.setWireframe(enabled)
print("setWireframe applied")
print("ok")

--@api-stub: lurek.render.isWireframe
-- Returns whether wireframe mode is active.
-- Use as a guard inside lurek.update or event handlers.
if lurek.render.isWireframe() then
  print("isWireframe -> true")
end

--@api-stub: lurek.render.stencil
-- Begins stencil writing with the given action and value.
-- See the module spec for detailed semantics.
local result = lurek.render.stencil(action, value)
print("stencil:", result)
return result

--@api-stub: lurek.render.setStencilTest
-- Sets the stencil comparison test, or disables stencil testing.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.render.setStencilTest(compare, value)
print("setStencilTest applied")
print("ok")

--@api-stub: lurek.render.setStencilMode
-- Sets the stencil buffer write/test mode.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.render.setStencilMode(action, compare, value)
print("setStencilMode applied")
print("ok")

--@api-stub: lurek.render.getStencilMode
-- Returns the current stencil mode as (action, compare, value).
-- Cheap to call; safe inside callbacks.
local value = lurek.render.getStencilMode()
print("getStencilMode:", value)
return value

--@api-stub: lurek.render.clearStencil
-- Resets the stencil mode to the default (keep / always / 0).
-- Pair with the matching constructor to free resources.
-- release the resource and forget the handle
lurek.render.clearStencil()
print("clearStencil done")
print("ok")

--@api-stub: lurek.render.setDepthMode
-- Sets the depth test comparison and write enable.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.render.setDepthMode(mode, write)
print("setDepthMode applied")
print("ok")

--@api-stub: lurek.render.getDepthMode
-- Returns the current depth mode as (mode, write).
-- Cheap to call; safe inside callbacks.
local value = lurek.render.getDepthMode()
print("getDepthMode:", value)
return value

--@api-stub: lurek.render.getWidth
-- Returns the window width in pixels.
-- Cheap to call; safe inside callbacks.
local value = lurek.render.getWidth()
print("getWidth:", value)
return value

--@api-stub: lurek.render.getHeight
-- Returns the window height in pixels.
-- Cheap to call; safe inside callbacks.
local value = lurek.render.getHeight()
print("getHeight:", value)
return value

--@api-stub: lurek.render.getDimensions
-- Returns window width and height.
-- Cheap to call; safe inside callbacks.
local value = lurek.render.getDimensions()
print("getDimensions:", value)
return value

--@api-stub: lurek.render.setDefaultFilter
-- Sets the default texture filter mode.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.render.setDefaultFilter(0, mag, anisotropy)
print("setDefaultFilter applied")
print("ok")

--@api-stub: lurek.render.getDefaultFilter
-- Returns the default texture filter mode.
-- Cheap to call; safe inside callbacks.
local value = lurek.render.getDefaultFilter()
print("getDefaultFilter:", value)
return value

--@api-stub: lurek.render.getStats
-- Returns a table of renderer statistics.
-- Cheap to call; safe inside callbacks.
local value = lurek.render.getStats()
print("getStats:", value)
return value

--@api-stub: lurek.render.saveScreenshot
-- Queues a screenshot to be saved after the current frame.
-- May block — call from a worker thread for large payloads.
local result = lurek.render.saveScreenshot("data/file.txt")
-- may block; consider lurek.thread for large payloads
print("saveScreenshot:", result)
print("ok")

--@api-stub: lurek.render.captureScreenshot
-- Calls the given callback with an ImageData captured from the current frame (stub: creates blank).
-- See the module spec for detailed semantics.
local result = lurek.render.captureScreenshot(function() print("captureScreenshot fired") end)
print("captureScreenshot:", result)
return result

--@api-stub: lurek.render.newNineSlice
-- Creates a 9-slice descriptor from a texture and inset values.
-- Build once at startup; reuse across frames.
local nineslice = lurek.render.newNineSlice(image, top, right, bottom, left)
print("created", nineslice)
return nineslice

--@api-stub: lurek.render.drawNineSlice
-- Queues a 9-slice draw call inside lurek.render / lurek.render_ui.
-- Place inside `function lurek.render() ... end`.
function lurek.render()
  lurek.render.drawNineSlice(slice, 100, 100, 64, 64)
end

--@api-stub: lurek.render.newShape
-- Creates a new empty [`CompoundShape`] stored in the resource pool.
-- Build once at startup; reuse across frames.
local shape = lurek.render.newShape()
print("created", shape)
return shape

--@api-stub: lurek.render.newDrawLayer
-- Creates a new z-ordered draw-call queue.
-- Build once at startup; reuse across frames.
local drawlayer = lurek.render.newDrawLayer()
print("created", drawlayer)
return drawlayer

--@api-stub: lurek.render.drawQuadBezier
-- Queues a quadratic BĂ©zier curve from (x1,y1) to (x2,y2) with one control point.
-- Place inside `function lurek.render() ... end`.
function lurek.render()
  lurek.render.drawQuadBezier()
end

--@api-stub: lurek.render.drawCubicBezier
-- Queues a cubic BĂ©zier curve from (x1,y1) to (x2,y2) with two control points.
-- Place inside `function lurek.render() ... end`.
function lurek.render()
  lurek.render.drawCubicBezier()
end

--@api-stub: lurek.render.drawPath
-- Queues a multi-segment vector path.
-- Place inside `function lurek.render() ... end`.
function lurek.render()
  lurek.render.drawPath("data/file.txt", mode, close)
end

--@api-stub: lurek.render.drawGradientRect
-- Queues a gradient-filled rectangle.
-- Place inside `function lurek.render() ... end`.
function lurek.render()
  lurek.render.drawGradientRect()
end

--@api-stub: lurek.render.drawColoredPolygon
-- Queues a convex polygon with per-vertex colours.
-- Place inside `function lurek.render() ... end`.
function lurek.render()
  lurek.render.drawColoredPolygon(vertices, {1, 0.5, 0, 1}, mode)
end

--@api-stub: lurek.render.drawIsoCubeTile
-- Queues a three-face isometric cube tile at screen position (sx, sy).
-- Place inside `function lurek.render() ... end`.
function lurek.render()
  lurek.render.drawIsoCubeTile()
end

--@api-stub: lurek.render.drawHexTile
-- Queues a hexagonal tile at centre (cx, cy) with given circumradius.
-- Place inside `function lurek.render() ... end`.
function lurek.render()
  lurek.render.drawHexTile()
end

--@api-stub: lurek.render.beginSortGroup
-- Begins a Y/Z depth sort group.
-- See the module spec for detailed semantics.
local result = lurek.render.beginSortGroup(1)
print("beginSortGroup:", result)
return result

--@api-stub: lurek.render.pushSortKey
-- Associates the previous draw command with a depth value within the active sort group.
-- Side-effecting; safe to call any time after init.
lurek.render.pushSortKey(depth)
-- mutator; side effect applied
print("pushSortKey done")
print("ok")

--@api-stub: lurek.render.flushSortGroup
-- Sorts and flushes all draw commands in the sort group.
-- See the module spec for detailed semantics.
local result = lurek.render.flushSortGroup(1)
print("flushSortGroup:", result)
return result

--@api-stub: lurek.render.drawBevelRect
-- Queues a beveled border rectangle with inner fill.
-- Place inside `function lurek.render() ... end`.
function lurek.render()
  lurek.render.drawBevelRect()
end

--@api-stub: lurek.render.pushLayer
-- Begins a named compositing layer with optional alpha and blend mode.
-- Side-effecting; safe to call any time after init.
lurek.render.pushLayer(1, 1, blend_mode)
-- mutator; side effect applied
print("pushLayer done")
print("ok")

--@api-stub: lurek.render.popLayer
-- Ends and composites the named layer back to its parent.
-- Pair with the matching constructor to free resources.
-- release the resource and forget the handle
lurek.render.popLayer(1)
print("popLayer done")
print("ok")

--@api-stub: lurek.render.drawQuadBezier
-- Must be called inside lurek.render or lurek.render_ui.
-- Place inside `function lurek.render() ... end`.
function lurek.render()
  lurek.render.drawQuadBezier(x1, y1, cx, cy, x2, y2, segments)
end

--@api-stub: lurek.render.drawCubicBezier
-- Queues a cubic BĂ©zier curve from (x1,y1) to (x2,y2) with two control points.
-- Place inside `function lurek.render() ... end`.
function lurek.render()
  lurek.render.drawCubicBezier(x1, y1, cx1, cy1, cx2, cy2, x2, y2, segments)
end

--@api-stub: lurek.render.drawPath
-- Queues a multi-segment vector path.
-- Place inside `function lurek.render() ... end`.
function lurek.render()
  lurek.render.drawPath("data/file.txt", mode, close)
end

--@api-stub: lurek.render.drawGradientRect
-- Queues a gradient-filled rectangle.
-- Place inside `function lurek.render() ... end`.
function lurek.render()
  lurek.render.drawGradientRect(100, 100, 64, 64, c1, c2, "data/file.txt")
end

--@api-stub: lurek.render.drawColoredPolygon
-- Queues a convex polygon with per-vertex colours.
-- Place inside `function lurek.render() ... end`.
function lurek.render()
  lurek.render.drawColoredPolygon(vertices, {1, 0.5, 0, 1}, mode)
end

--@api-stub: lurek.render.drawIsoCubeTile
-- Queues a three-face isometric cube tile at screen position (sx, sy).
-- Place inside `function lurek.render() ... end`.
function lurek.render()
  lurek.render.drawIsoCubeTile(sx, sy, half_w, half_h, { x = 0, y = 0 })
end

--@api-stub: lurek.render.drawHexTile
-- Queues a hexagonal tile at centre (cx, cy) with given circumradius.
-- Place inside `function lurek.render() ... end`.
function lurek.render()
  lurek.render.drawHexTile(cx, cy, 10, orientation, mode)
end

--@api-stub: lurek.render.beginSortGroup
-- Begins a Y/Z depth sort group identified by id.
-- See the module spec for detailed semantics.
local result = lurek.render.beginSortGroup(1)
print("beginSortGroup:", result)
return result

--@api-stub: lurek.render.pushSortKey
-- Associates the previous draw command with a depth value within the active sort group.
-- Side-effecting; safe to call any time after init.
lurek.render.pushSortKey(depth)
-- mutator; side effect applied
print("pushSortKey done")
print("ok")

--@api-stub: lurek.render.flushSortGroup
-- Sorts and flushes all draw commands in the sort group.
-- See the module spec for detailed semantics.
local result = lurek.render.flushSortGroup(1)
print("flushSortGroup:", result)
return result

--@api-stub: lurek.render.drawBevelRect
-- Queues a beveled border rectangle.
-- Place inside `function lurek.render() ... end`.
function lurek.render()
  lurek.render.drawBevelRect(100, 100, 64, 64, bevel_w, style, { x = 0, y = 0 })
end

--@api-stub: lurek.render.pushLayer
-- Begins a named compositing layer.
-- Side-effecting; safe to call any time after init.
lurek.render.pushLayer(1, 1, blend_mode)
-- mutator; side effect applied
print("pushLayer done")
print("ok")

--@api-stub: lurek.render.popLayer
-- Ends and composites the named layer.
-- Pair with the matching constructor to free resources.
-- release the resource and forget the handle
lurek.render.popLayer(1)
print("popLayer done")
print("ok")

--@api-stub: lurek.render.newLayer
-- Registers a named render layer with an optional z-order (default 0).
-- Build once at startup; reuse across frames.
local layer = lurek.render.newLayer("main", z_order)
print("created", layer)
return layer

--@api-stub: lurek.render.setLayer
-- Sets the active named layer.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.render.setLayer("main")
print("setLayer applied")
print("ok")

--@api-stub: lurek.render.currentLayer
-- Returns the name of the currently active named layer.
-- See the module spec for detailed semantics.
local result = lurek.render.currentLayer()
print("currentLayer:", result)
return result

--@api-stub: lurek.render.setLayerVisible
-- Shows or hides the named layer.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.render.setLayerVisible("main", visible)
print("setLayerVisible applied")
print("ok")

--@api-stub: lurek.render.isLayerVisible
-- Returns `true` if the named layer is visible (default: `true`).
-- Use as a guard inside lurek.update or event handlers.
if lurek.render.isLayerVisible("main") then
  print("isLayerVisible -> true")
end

--@api-stub: lurek.render.getLayerZOrder
-- Returns the z-order of the named layer, or `0` if unregistered.
-- Cheap to call; safe inside callbacks.
local value = lurek.render.getLayerZOrder("main")
print("getLayerZOrder:", value)
return value

--@api-stub: lurek.render.setLayerZOrder
-- Updates the z-order of the named layer.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.render.setLayerZOrder("main", 0)
print("setLayerZOrder applied")
print("ok")

-- ── ImageData methods ──

--@api-stub: ImageData:getWidth
-- Returns the pixel width of this image buffer.
-- Cheap to call; safe inside callbacks.
local imageData = lurek.render.newImageData()  -- or your existing handle
local value = imageData:getWidth()
print("ImageData:getWidth ->", value)

--@api-stub: ImageData:getHeight
-- Returns the pixel height of this image buffer.
-- Cheap to call; safe inside callbacks.
local imageData = lurek.render.newImageData()  -- or your existing handle
local value = imageData:getHeight()
print("ImageData:getHeight ->", value)

--@api-stub: ImageData:resize
-- Returns a new ImageData scaled to the given dimensions using bilinear interpolation.
-- See the module spec for detailed semantics.
local imageData = lurek.render.newImageData()
imageData:resize(64, 64)
print("ImageData:resize done")

--@api-stub: ImageData:diff
-- Returns the sum of absolute per-channel differences between this image and `other`.
-- See the module spec for detailed semantics.
local imageData = lurek.render.newImageData()
imageData:diff(other_ud)
print("ImageData:diff done")

--@api-stub: ImageData:mapPixels
-- Applies a Lua function to every pixel in-place.
-- See the module spec for detailed semantics.
local imageData = lurek.render.newImageData()
imageData:mapPixels(function() print("mapPixels fired") end)
print("ImageData:mapPixels done")

--@api-stub: ImageData:type
-- Returns the type name "ImageData".
-- See the module spec for detailed semantics.
local imageData = lurek.render.newImageData()
imageData:type()
print("ImageData:type done")

--@api-stub: ImageData:typeOf
-- Returns true when the given name matches "ImageData" or a parent type.
-- See the module spec for detailed semantics.
local imageData = lurek.render.newImageData()
imageData:typeOf("main")
print("ImageData:typeOf done")

-- ── NineSlice methods ──

--@api-stub: NineSlice:getInsets
-- Returns the four inset values as (top, right, bottom, left).
-- Cheap to call; safe inside callbacks.
local nineSlice = lurek.render.newNineSlice()  -- or your existing handle
local value = nineSlice:getInsets()
print("NineSlice:getInsets ->", value)

--@api-stub: NineSlice:getTextureSize
-- Returns the width and height of the source texture.
-- Cheap to call; safe inside callbacks.
local nineSlice = lurek.render.newNineSlice()  -- or your existing handle
local value = nineSlice:getTextureSize()
print("NineSlice:getTextureSize ->", value)

--@api-stub: NineSlice:type
-- Returns the type name "NineSlice".
-- See the module spec for detailed semantics.
local nineSlice = lurek.render.newNineSlice()
nineSlice:type()
print("NineSlice:type done")

--@api-stub: NineSlice:typeOf
-- Returns true when the given name matches "NineSlice" or a parent type.
-- See the module spec for detailed semantics.
local nineSlice = lurek.render.newNineSlice()
nineSlice:typeOf("main")
print("NineSlice:typeOf done")

-- ── Image methods ──

--@api-stub: Image:getWidth
-- Returns the width of this image in pixels.
-- Cheap to call; safe inside callbacks.
local image = lurek.render.newImage()  -- or your existing handle
local value = image:getWidth()
print("Image:getWidth ->", value)

--@api-stub: Image:getHeight
-- Returns the height of this image in pixels.
-- Cheap to call; safe inside callbacks.
local image = lurek.render.newImage()  -- or your existing handle
local value = image:getHeight()
print("Image:getHeight ->", value)

--@api-stub: Image:getDimensions
-- Returns width and height of this image.
-- Cheap to call; safe inside callbacks.
local image = lurek.render.newImage()  -- or your existing handle
local value = image:getDimensions()
print("Image:getDimensions ->", value)

--@api-stub: Image:release
-- Releases the GPU texture memory for this image.
-- See the module spec for detailed semantics.
local image = lurek.render.newImage()
image:release()
print("Image:release done")

--@api-stub: Image:typeOf
-- Returns the type name of this object.
-- See the module spec for detailed semantics.
local image = lurek.render.newImage()
image:typeOf()
print("Image:typeOf done")

--@api-stub: Image:type
-- Returns the type name of this object.
-- See the module spec for detailed semantics.
local image = lurek.render.newImage()
image:type()
print("Image:type done")

-- ── Font methods ──

--@api-stub: Font:getWidth
-- Returns the rendered width of the given text string.
-- Cheap to call; safe inside callbacks.
local font = lurek.render.newFont()  -- or your existing handle
local value = font:getWidth("hello")
print("Font:getWidth ->", value)

--@api-stub: Font:getHeight
-- Returns the line height of this font.
-- Cheap to call; safe inside callbacks.
local font = lurek.render.newFont()  -- or your existing handle
local value = font:getHeight()
print("Font:getHeight ->", value)

--@api-stub: Font:getLineHeight
-- Returns the line height multiplier of this font.
-- Cheap to call; safe inside callbacks.
local font = lurek.render.newFont()  -- or your existing handle
local value = font:getLineHeight()
print("Font:getLineHeight ->", value)

--@api-stub: Font:setLineHeight
-- Sets the line height multiplier for this font.
-- Apply at startup or in response to user input.
local font = lurek.render.newFont()
font:setLineHeight(64)
print("Font:setLineHeight applied")

--@api-stub: Font:getAscent
-- Returns the ascent of this font in pixels.
-- Cheap to call; safe inside callbacks.
local font = lurek.render.newFont()  -- or your existing handle
local value = font:getAscent()
print("Font:getAscent ->", value)

--@api-stub: Font:getDescent
-- Returns the descent of this font in pixels.
-- Cheap to call; safe inside callbacks.
local font = lurek.render.newFont()  -- or your existing handle
local value = font:getDescent()
print("Font:getDescent ->", value)

--@api-stub: Font:getWrap
-- Wraps text to the given width and returns the lines.
-- Cheap to call; safe inside callbacks.
local font = lurek.render.newFont()  -- or your existing handle
local value = font:getWrap("hello", limit)
print("Font:getWrap ->", value)

--@api-stub: Font:release
-- Releases this font and frees its atlas memory.
-- See the module spec for detailed semantics.
local font = lurek.render.newFont()
font:release()
print("Font:release done")

--@api-stub: Font:typeOf
-- Returns the type name of this object.
-- See the module spec for detailed semantics.
local font = lurek.render.newFont()
font:typeOf()
print("Font:typeOf done")

--@api-stub: Font:type
-- Returns the type name of this object.
-- See the module spec for detailed semantics.
local font = lurek.render.newFont()
font:type()
print("Font:type done")

-- ── Canvas methods ──

--@api-stub: Canvas:getWidth
-- Returns the width of this canvas in pixels.
-- Cheap to call; safe inside callbacks.
local canvas = lurek.render.newCanvas()  -- or your existing handle
local value = canvas:getWidth()
print("Canvas:getWidth ->", value)

--@api-stub: Canvas:getHeight
-- Returns the height of this canvas in pixels.
-- Cheap to call; safe inside callbacks.
local canvas = lurek.render.newCanvas()  -- or your existing handle
local value = canvas:getHeight()
print("Canvas:getHeight ->", value)

--@api-stub: Canvas:getDimensions
-- Returns width and height of this canvas.
-- Cheap to call; safe inside callbacks.
local canvas = lurek.render.newCanvas()  -- or your existing handle
local value = canvas:getDimensions()
print("Canvas:getDimensions ->", value)

--@api-stub: Canvas:release
-- Releases GPU framebuffer memory for this canvas.
-- See the module spec for detailed semantics.
local canvas = lurek.render.newCanvas()
canvas:release()
print("Canvas:release done")

--@api-stub: Canvas:typeOf
-- Returns the type name of this object.
-- See the module spec for detailed semantics.
local canvas = lurek.render.newCanvas()
canvas:typeOf()
print("Canvas:typeOf done")

--@api-stub: Canvas:type
-- Returns the type name of this object.
-- See the module spec for detailed semantics.
local canvas = lurek.render.newCanvas()
canvas:type()
print("Canvas:type done")

-- ── SpriteBatch methods ──

--@api-stub: SpriteBatch:clear
-- Removes all sprites from this batch.
-- Pair with the matching constructor to free resources.
local spriteBatch = lurek.render.newSpriteBatch()
spriteBatch:clear()
-- spriteBatch is now released
print("ok")

--@api-stub: SpriteBatch:getCount
-- Returns the number of sprites in this batch.
-- Cheap to call; safe inside callbacks.
local spriteBatch = lurek.render.newSpriteBatch()  -- or your existing handle
local value = spriteBatch:getCount()
print("SpriteBatch:getCount ->", value)

--@api-stub: SpriteBatch:getBufferSize
-- Returns the maximum capacity of this batch.
-- Cheap to call; safe inside callbacks.
local spriteBatch = lurek.render.newSpriteBatch()  -- or your existing handle
local value = spriteBatch:getBufferSize()
print("SpriteBatch:getBufferSize ->", value)

--@api-stub: SpriteBatch:release
-- Releases this sprite batch.
-- See the module spec for detailed semantics.
local spriteBatch = lurek.render.newSpriteBatch()
spriteBatch:release()
print("SpriteBatch:release done")

--@api-stub: SpriteBatch:typeOf
-- Returns the type name of this object.
-- See the module spec for detailed semantics.
local spriteBatch = lurek.render.newSpriteBatch()
spriteBatch:typeOf()
print("SpriteBatch:typeOf done")

--@api-stub: SpriteBatch:type
-- Returns the type name of this object.
-- See the module spec for detailed semantics.
local spriteBatch = lurek.render.newSpriteBatch()
spriteBatch:type()
print("SpriteBatch:type done")

-- ── Mesh methods ──

--@api-stub: Mesh:getVertexCount
-- Returns the number of vertices in this mesh.
-- Cheap to call; safe inside callbacks.
local mesh = lurek.render.newMesh()  -- or your existing handle
local value = mesh:getVertexCount()
print("Mesh:getVertexCount ->", value)

--@api-stub: Mesh:getVertex
-- Returns vertex data at the given 1-based index.
-- Cheap to call; safe inside callbacks.
local mesh = lurek.render.newMesh()  -- or your existing handle
local value = mesh:getVertex(1)
print("Mesh:getVertex ->", value)

--@api-stub: Mesh:setVertex
-- Sets vertex data at the given 1-based index.
-- Apply at startup or in response to user input.
local mesh = lurek.render.newMesh()
mesh:setVertex(1, { x = 0, y = 0 })
print("Mesh:setVertex applied")

--@api-stub: Mesh:setTexture
-- Assigns a texture to this mesh.
-- Apply at startup or in response to user input.
local mesh = lurek.render.newMesh()
mesh:setTexture(ud)
print("Mesh:setTexture applied")

--@api-stub: Mesh:release
-- Releases the GPU mesh resource, freeing VRAM immediately.
-- See the module spec for detailed semantics.
local mesh = lurek.render.newMesh()
mesh:release()
print("Mesh:release done")

--@api-stub: Mesh:typeOf
-- Returns the type name of this object.
-- See the module spec for detailed semantics.
local mesh = lurek.render.newMesh()
mesh:typeOf()
print("Mesh:typeOf done")

--@api-stub: Mesh:type
-- Returns the type name of this object.
-- See the module spec for detailed semantics.
local mesh = lurek.render.newMesh()
mesh:type()
print("Mesh:type done")

-- ── Shader methods ──

--@api-stub: Shader:send
-- Sends a uniform value to this shader.
-- See the module spec for detailed semantics.
local shader = lurek.render.newShader()
shader:send("main", value)
print("Shader:send done")

--@api-stub: Shader:hasUniform
-- Returns whether this shader has a uniform with the given name.
-- Use as a guard inside lurek.update or event handlers.
local shader = lurek.render.newShader()
if shader:hasUniform("main") then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Shader:release
-- Releases the compiled GPU shader, freeing VRAM and shader slots.
-- See the module spec for detailed semantics.
local shader = lurek.render.newShader()
shader:release()
print("Shader:release done")

--@api-stub: Shader:typeOf
-- Returns the type name of this object.
-- See the module spec for detailed semantics.
local shader = lurek.render.newShader()
shader:typeOf()
print("Shader:typeOf done")

--@api-stub: Shader:type
-- Returns the type name of this object.
-- See the module spec for detailed semantics.
local shader = lurek.render.newShader()
shader:type()
print("Shader:type done")

-- ── Quad methods ──

--@api-stub: Quad:getViewport
-- Returns the quad viewport rectangle.
-- Cheap to call; safe inside callbacks.
local quad = lurek.render.newQuad()  -- or your existing handle
local value = quad:getViewport()
print("Quad:getViewport ->", value)

--@api-stub: Quad:getTextureDimensions
-- Returns the reference texture dimensions.
-- Cheap to call; safe inside callbacks.
local quad = lurek.render.newQuad()  -- or your existing handle
local value = quad:getTextureDimensions()
print("Quad:getTextureDimensions ->", value)

--@api-stub: Quad:typeOf
-- Returns the type name of this object.
-- See the module spec for detailed semantics.
local quad = lurek.render.newQuad()
quad:typeOf()
print("Quad:typeOf done")

--@api-stub: Quad:type
-- Returns the type name of this object.
-- See the module spec for detailed semantics.
local quad = lurek.render.newQuad()
quad:type()
print("Quad:type done")

-- ── Shape methods ──

--@api-stub: Shape:getCommandCount
-- Returns the number of drawing commands currently stored.
-- Cheap to call; safe inside callbacks.
local shape = lurek.render.newShape()  -- or your existing handle
local value = shape:getCommandCount()
print("Shape:getCommandCount ->", value)

--@api-stub: Shape:clear
-- Removes all commands and resets the shape to empty.
-- Pair with the matching constructor to free resources.
local shape = lurek.render.newShape()
shape:clear()
-- shape is now released
print("ok")

--@api-stub: Shape:setLineWidth
-- Sets the stroke width for subsequent outlined primitives.
-- Apply at startup or in response to user input.
local shape = lurek.render.newShape()
shape:setLineWidth(64)
print("Shape:setLineWidth applied")

--@api-stub: Shape:line
-- Queues a line segment command.
-- Place inside `function lurek.render() ... end`.
local shape = lurek.render.newShape()
shape:line(x1, y1, x2, y2)
print("Shape:line done")

--@api-stub: Shape:polyline
-- Queues a polyline command from variadic (x, y) coordinate pairs.
-- See the module spec for detailed semantics.
local shape = lurek.render.newShape()
shape:polyline()
print("Shape:polyline done")

--@api-stub: Shape:typeOf
-- Returns true if the given type name matches this object's type or any parent type.
-- See the module spec for detailed semantics.
local shape = lurek.render.newShape()
shape:typeOf("main")
print("Shape:typeOf done")

--@api-stub: Shape:type
-- Returns the type name of this object.
-- See the module spec for detailed semantics.
local shape = lurek.render.newShape()
shape:type()
print("Shape:type done")

-- ── DrawLayer methods ──

--@api-stub: DrawLayer:queue
-- Queues a draw callback at the given z-order.
-- See the module spec for detailed semantics.
local drawLayer = lurek.render.newDrawLayer()
drawLayer:queue(0, f)
print("DrawLayer:queue done")

--@api-stub: DrawLayer:flush
-- Sorts and calls all queued callbacks, then empties the queue.
-- See the module spec for detailed semantics.
local drawLayer = lurek.render.newDrawLayer()
drawLayer:flush()
print("DrawLayer:flush done")

--@api-stub: DrawLayer:clear
-- Removes all queued callbacks without calling them.
-- Pair with the matching constructor to free resources.
local drawLayer = lurek.render.newDrawLayer()
drawLayer:clear()
-- drawLayer is now released
print("ok")

--@api-stub: DrawLayer:getCount
-- Returns the number of queued callbacks.
-- Cheap to call; safe inside callbacks.
local drawLayer = lurek.render.newDrawLayer()  -- or your existing handle
local value = drawLayer:getCount()
print("DrawLayer:getCount ->", value)

--@api-stub: DrawLayer:type
-- Returns the string type identifier of this draw layer (e.g.
-- See the module spec for detailed semantics.
local drawLayer = lurek.render.newDrawLayer()
drawLayer:type()
print("DrawLayer:type done")

--@api-stub: DrawLayer:typeOf
-- Returns true if this object is an instance of the given type name.
-- See the module spec for detailed semantics.
local drawLayer = lurek.render.newDrawLayer()
drawLayer:typeOf("main")
print("DrawLayer:typeOf done")

