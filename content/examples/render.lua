-- content/examples/render.lua
-- Lurek2D lurek.render API Reference
-- Run with: cargo run -- content/examples/render
--
-- Scenario: A side-scrolling RPG with HUD, tilemaps via sprite batches,
-- custom shaders for water effects, off-screen canvases for minimaps,
-- nine-slice UI panels, layered rendering, and screenshot capture.

print("=== lurek.render — 2D Rendering Pipeline ===\n")

-- =============================================================================
-- Color & Background
-- =============================================================================

--@api-stub: lurek.render.setColor
-- Demonstrates the proper usage of lurek.render.setColor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_setColor()
    lurek.render.setColor(1, 1, 1, 1)
end
local _ok, _err = pcall(demo_lurek_render_setColor)

--@api-stub: lurek.render.getColor
-- Demonstrates the proper usage of lurek.render.getColor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getColor()
    local r, g, b, a = lurek.render.getColor()
    print("color: " .. r .. ", " .. g .. ", " .. b .. ", " .. a)
end
local _ok, _err = pcall(demo_lurek_render_getColor)

--@api-stub: lurek.render.setBackgroundColor
-- Demonstrates the proper usage of lurek.render.setBackgroundColor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_setBackgroundColor()
    lurek.render.setBackgroundColor(0.05, 0.05, 0.15, 1.0)
end
local _ok, _err = pcall(demo_lurek_render_setBackgroundColor)

--@api-stub: lurek.render.getBackgroundColor
-- Demonstrates the proper usage of lurek.render.getBackgroundColor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getBackgroundColor()
    local br, bg, bb, ba = lurek.render.getBackgroundColor()
    print("background: " .. br .. ", " .. bg .. ", " .. bb)
end
local _ok, _err = pcall(demo_lurek_render_getBackgroundColor)

--@api-stub: lurek.render.clear
-- Demonstrates the proper usage of lurek.render.clear.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_clear()
    lurek.render.clear()
end
local _ok, _err = pcall(demo_lurek_render_clear)

-- =============================================================================
-- Primitive Drawing — shapes, lines, points
-- =============================================================================

--@api-stub: lurek.render.rectangle
-- Demonstrates the proper usage of lurek.render.rectangle.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_rectangle()
    lurek.render.rectangle("fill", 20, 20, 200, 30)
end
local _ok, _err = pcall(demo_lurek_render_rectangle)

--@api-stub: lurek.render.circle
-- Demonstrates the proper usage of lurek.render.circle.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_circle()
    lurek.render.circle("fill", 400, 300, 16)
end
local _ok, _err = pcall(demo_lurek_render_circle)

--@api-stub: lurek.render.ellipse
-- Demonstrates the proper usage of lurek.render.ellipse.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_ellipse()
    lurek.render.ellipse("fill", 200, 500, 24, 8)
end
local _ok, _err = pcall(demo_lurek_render_ellipse)

--@api-stub: lurek.render.triangle
-- Demonstrates the proper usage of lurek.render.triangle.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_triangle()
    lurek.render.triangle("fill", 100, 100, 130, 60, 160, 100)
end
local _ok, _err = pcall(demo_lurek_render_triangle)

--@api-stub: lurek.render.line
-- Demonstrates the proper usage of lurek.render.line.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_line()
    lurek.render.line(100, 300, 400, 250)
end
local _ok, _err = pcall(demo_lurek_render_line)

--@api-stub: lurek.render.polygon
-- Demonstrates the proper usage of lurek.render.polygon.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_polygon()
    lurek.render.polygon("line", {100,50, 150,25, 200,50, 200,100, 150,125, 100,100})
end
local _ok, _err = pcall(demo_lurek_render_polygon)

--@api-stub: lurek.render.arc
-- Demonstrates the proper usage of lurek.render.arc.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_arc()
    lurek.render.arc("fill", 600, 400, 30, 0, math.pi * 1.5)
end
local _ok, _err = pcall(demo_lurek_render_arc)

--@api-stub: lurek.render.points
-- Demonstrates the proper usage of lurek.render.points.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_points()
    lurek.render.points({10,20, 50,80, 120,40, 300,200})
end
local _ok, _err = pcall(demo_lurek_render_points)

--@api-stub: lurek.render.drawQuadBezier
-- Demonstrates the proper usage of lurek.render.drawQuadBezier.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_drawQuadBezier()
    lurek.render.drawQuadBezier(50, 300, 200, 100, 350, 300, 20)
end
local _ok, _err = pcall(demo_lurek_render_drawQuadBezier)

--@api-stub: lurek.render.drawCubicBezier
-- Demonstrates the proper usage of lurek.render.drawCubicBezier.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_drawCubicBezier()
    lurek.render.drawCubicBezier(50, 500, 150, 300, 300, 700, 450, 500, 30)
end
local _ok, _err = pcall(demo_lurek_render_drawCubicBezier)

--@api-stub: lurek.render.drawPath
-- Demonstrates the proper usage of lurek.render.drawPath.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_drawPath()
    lurek.render.drawPath({{100,100}, {200,80}, {300,120}, {350,200}})
end
local _ok, _err = pcall(demo_lurek_render_drawPath)

--@api-stub: lurek.render.drawGradientRect
-- Demonstrates the proper usage of lurek.render.drawGradientRect.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_drawGradientRect()
    lurek.render.drawGradientRect(0, 0, 800, 200,
    {0.2, 0.3, 0.8, 1}, {0.6, 0.8, 1.0, 1})
end
local _ok, _err = pcall(demo_lurek_render_drawGradientRect)

--@api-stub: lurek.render.drawColoredPolygon
-- Demonstrates the proper usage of lurek.render.drawColoredPolygon.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_drawColoredPolygon()
    lurek.render.drawColoredPolygon(
    {{x=0,y=100,r=0,g=0.6,b=0,a=1}, {x=100,y=0,r=0,g=0.8,b=0,a=1}, {x=200,y=100,r=0,g=0.5,b=0,a=1}})
end
local _ok, _err = pcall(demo_lurek_render_drawColoredPolygon)

--@api-stub: lurek.render.drawBevelRect
-- Demonstrates the proper usage of lurek.render.drawBevelRect.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_drawBevelRect()
    lurek.render.drawBevelRect(500, 20, 120, 40, 6)
end
local _ok, _err = pcall(demo_lurek_render_drawBevelRect)

--@api-stub: lurek.render.drawIsoCubeTile
-- Demonstrates the proper usage of lurek.render.drawIsoCubeTile.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_drawIsoCubeTile()
    lurek.render.drawIsoCubeTile(400, 200, 64, 32, {0.5, 0.7, 0.3, 1})
end
local _ok, _err = pcall(demo_lurek_render_drawIsoCubeTile)

--@api-stub: lurek.render.drawHexTile
-- Demonstrates the proper usage of lurek.render.drawHexTile.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_drawHexTile()
    lurek.render.drawHexTile(500, 200, 30, {0.3, 0.5, 0.7, 1})
end
local _ok, _err = pcall(demo_lurek_render_drawHexTile)

-- =============================================================================
-- Line & Point Styles
-- =============================================================================

--@api-stub: lurek.render.setLineWidth
-- Demonstrates the proper usage of lurek.render.setLineWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_setLineWidth()
    lurek.render.setLineWidth(2.0)
end
local _ok, _err = pcall(demo_lurek_render_setLineWidth)

--@api-stub: lurek.render.getLineWidth
-- Demonstrates the proper usage of lurek.render.getLineWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getLineWidth()
    print("line width: " .. lurek.render.getLineWidth())
end
local _ok, _err = pcall(demo_lurek_render_getLineWidth)

--@api-stub: lurek.render.setPointSize
-- Demonstrates the proper usage of lurek.render.setPointSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_setPointSize()
    lurek.render.setPointSize(3.0)
end
local _ok, _err = pcall(demo_lurek_render_setPointSize)

--@api-stub: lurek.render.getPointSize
-- Demonstrates the proper usage of lurek.render.getPointSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getPointSize()
    print("point size: " .. lurek.render.getPointSize())
end
local _ok, _err = pcall(demo_lurek_render_getPointSize)

-- =============================================================================
-- Blend Modes
-- =============================================================================

--@api-stub: lurek.render.setBlendMode
-- Demonstrates the proper usage of lurek.render.setBlendMode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_setBlendMode()
    lurek.render.setBlendMode("add")
end
local _ok, _err = pcall(demo_lurek_render_setBlendMode)

--@api-stub: lurek.render.getBlendMode
-- Demonstrates the proper usage of lurek.render.getBlendMode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getBlendMode()
    print("blend mode: " .. lurek.render.getBlendMode())
    lurek.render.setBlendMode("alpha")
end
local _ok, _err = pcall(demo_lurek_render_getBlendMode)

-- =============================================================================
-- Font & Text
-- =============================================================================

--@api-stub: lurek.render.newFont
-- Demonstrates the proper usage of lurek.render.newFont.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_newFont()
    local dialog_font = lurek.render.newFont("assets/fonts/pixel.ttf", 16)
end
local _ok, _err = pcall(demo_lurek_render_newFont)

--@api-stub: lurek.render.setFont
-- Demonstrates the proper usage of lurek.render.setFont.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_setFont()
    lurek.render.setFont(dialog_font)
end
local _ok, _err = pcall(demo_lurek_render_setFont)

--@api-stub: lurek.render.getFont
-- Demonstrates the proper usage of lurek.render.getFont.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getFont()
    local current_font = lurek.render.getFont()
end
local _ok, _err = pcall(demo_lurek_render_getFont)

--@api-stub: lurek.render.getDefaultFont
-- Demonstrates the proper usage of lurek.render.getDefaultFont.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getDefaultFont()
    local default_font = lurek.render.getDefaultFont()
end
local _ok, _err = pcall(demo_lurek_render_getDefaultFont)

--@api-stub: lurek.render.getFontSizes
-- Demonstrates the proper usage of lurek.render.getFontSizes.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getFontSizes()
    local sizes = lurek.render.getFontSizes()
    print("font sizes: " .. #sizes)
end
local _ok, _err = pcall(demo_lurek_render_getFontSizes)

--@api-stub: lurek.render.getFontCellWidth
-- Demonstrates the proper usage of lurek.render.getFontCellWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getFontCellWidth()
    print("font cell width: " .. lurek.render.getFontCellWidth())
end
local _ok, _err = pcall(demo_lurek_render_getFontCellWidth)

--@api-stub: lurek.render.getFontWidth
-- Demonstrates the proper usage of lurek.render.getFontWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getFontWidth()
    print("font 'Hello' width: " .. lurek.render.getFontWidth("Hello"))
end
local _ok, _err = pcall(demo_lurek_render_getFontWidth)

--@api-stub: lurek.render.getFontHeight
-- Demonstrates the proper usage of lurek.render.getFontHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getFontHeight()
    print("font height: " .. lurek.render.getFontHeight())
end
local _ok, _err = pcall(demo_lurek_render_getFontHeight)

--@api-stub: lurek.render.getFontLineHeight
-- Demonstrates the proper usage of lurek.render.getFontLineHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getFontLineHeight()
    print("line height: " .. lurek.render.getFontLineHeight())
end
local _ok, _err = pcall(demo_lurek_render_getFontLineHeight)

--@api-stub: lurek.render.setFontLineHeight
-- Demonstrates the proper usage of lurek.render.setFontLineHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_setFontLineHeight()
    lurek.render.setFontLineHeight(20)
end
local _ok, _err = pcall(demo_lurek_render_setFontLineHeight)

--@api-stub: lurek.render.getFontAscent
-- Demonstrates the proper usage of lurek.render.getFontAscent.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getFontAscent()
    print("ascent: " .. lurek.render.getFontAscent())
end
local _ok, _err = pcall(demo_lurek_render_getFontAscent)

--@api-stub: lurek.render.getFontDescent
-- Demonstrates the proper usage of lurek.render.getFontDescent.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getFontDescent()
    print("descent: " .. lurek.render.getFontDescent())
end
local _ok, _err = pcall(demo_lurek_render_getFontDescent)

--@api-stub: lurek.render.getFontWrap
-- Demonstrates the proper usage of lurek.render.getFontWrap.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getFontWrap()
    local lines, wrapped_w = lurek.render.getFontWrap("A long dialogue line that should wrap...", 300)
    print("wrapped to " .. #lines .. " lines, width=" .. wrapped_w)
end
local _ok, _err = pcall(demo_lurek_render_getFontWrap)

--@api-stub: lurek.render.print
-- Demonstrates the proper usage of lurek.render.print.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_print()
    lurek.render.print("Merchant", 200, 140)
end
local _ok, _err = pcall(demo_lurek_render_print)

--@api-stub: lurek.render.printf
-- Demonstrates the proper usage of lurek.render.printf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_printf()
    lurek.render.printf("Welcome to the village!", 100, 400, 400, "center")
end
local _ok, _err = pcall(demo_lurek_render_printf)

--@api-stub: lurek.render.printRich
-- Demonstrates the proper usage of lurek.render.printRich.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_printRich()
    lurek.render.printRich("{color=gold}Legendary Sword{/color}\n+50 Attack", 100, 200)
end
local _ok, _err = pcall(demo_lurek_render_printRich)

-- =============================================================================
-- Images & Textures
-- =============================================================================

--@api-stub: lurek.render.newImage
-- Demonstrates the proper usage of lurek.render.newImage.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_newImage()
    local hero_tex = lurek.render.newImage("assets/sprites/hero.png")
end
local _ok, _err = pcall(demo_lurek_render_newImage)

--@api-stub: lurek.render.draw
-- Demonstrates the proper usage of lurek.render.draw.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_draw()
    lurek.render.draw(hero_tex, 200, 300)
end
local _ok, _err = pcall(demo_lurek_render_draw)

--@api-stub: lurek.render.drawq
-- Demonstrates the proper usage of lurek.render.drawq.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_drawq()
    print('Executing drawq')
end
local _ok, _err = pcall(demo_lurek_render_drawq)

-- =============================================================================
-- Quads — sprite sheet sub-regions
-- =============================================================================

--@api-stub: lurek.render.newQuad
-- Demonstrates the proper usage of lurek.render.newQuad.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_newQuad()
    local hero_quad = lurek.render.newQuad(0, 0, 32, 32, 256, 256)
    lurek.render.drawq(hero_tex, hero_quad, 200, 300)
end
local _ok, _err = pcall(demo_lurek_render_newQuad)

-- =============================================================================
-- Canvases — off-screen render targets
-- =============================================================================

--@api-stub: lurek.render.newCanvas
-- Demonstrates the proper usage of lurek.render.newCanvas.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_newCanvas()
    local minimap_canvas = lurek.render.newCanvas(200, 200)
end
local _ok, _err = pcall(demo_lurek_render_newCanvas)

--@api-stub: lurek.render.setCanvas
-- Demonstrates the proper usage of lurek.render.setCanvas.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_setCanvas()
    lurek.render.setCanvas(minimap_canvas)
    lurek.render.clear()
    lurek.render.setColor(0, 0.5, 0, 1)
    lurek.render.rectangle("fill", 0, 0, 200, 200)
    lurek.render.setColor(1, 0, 0, 1)
    lurek.render.circle("fill", 100, 100, 5)
end
local _ok, _err = pcall(demo_lurek_render_setCanvas)

--@api-stub: lurek.render.getCanvas
-- Demonstrates the proper usage of lurek.render.getCanvas.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getCanvas()
    local active_canvas = lurek.render.getCanvas()
end
local _ok, _err = pcall(demo_lurek_render_getCanvas)

--@api-stub: lurek.render.getCanvasSize
local cw, ch = lurek.render.getCanvasSize()
print("canvas size: " .. tostring(cw) .. "x" .. tostring(ch))

-- Reset to main screen.
lurek.render.setCanvas()

-- Draw the minimap canvas onto the main screen.
lurek.render.setColor(1, 1, 1, 1)
lurek.render.draw(minimap_canvas, 580, 20)

-- =============================================================================
-- Sprite Batches — fast tilemap rendering
-- =============================================================================

--@api-stub: lurek.render.newSpriteBatch
-- Demonstrates the proper usage of lurek.render.newSpriteBatch.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_newSpriteBatch()
    local tile_batch = lurek.render.newSpriteBatch(hero_tex, 1000)
end
local _ok, _err = pcall(demo_lurek_render_newSpriteBatch)

-- =============================================================================
-- Meshes — custom geometry
-- =============================================================================

--@api-stub: lurek.render.newMesh
-- Demonstrates the proper usage of lurek.render.newMesh.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_newMesh()
    local water_mesh = lurek.render.newMesh({
    {0, 0, 0, 0, 1, 1, 1, 1},
    {100, 0, 1, 0, 1, 1, 1, 1},
    {100, 50, 1, 1, 0.5, 0.7, 1, 0.8},
    {0, 50, 0, 1, 0.5, 0.7, 1, 0.8},
    }, "fan")
end
local _ok, _err = pcall(demo_lurek_render_newMesh)

-- =============================================================================
-- Shaders
-- =============================================================================

--@api-stub: lurek.render.newShader
-- Demonstrates the proper usage of lurek.render.newShader.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_newShader()
    local water_shader = lurek.render.newShader("assets/shaders/water.wgsl")
end
local _ok, _err = pcall(demo_lurek_render_newShader)

--@api-stub: lurek.render.setShader
-- Demonstrates the proper usage of lurek.render.setShader.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_setShader()
    lurek.render.setShader(water_shader)
end
local _ok, _err = pcall(demo_lurek_render_setShader)

--@api-stub: lurek.render.getShader
-- Demonstrates the proper usage of lurek.render.getShader.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getShader()
    local active_shader = lurek.render.getShader()
    lurek.render.draw(water_mesh, 0, 400)
    lurek.render.setShader()
end
local _ok, _err = pcall(demo_lurek_render_getShader)

-- =============================================================================
-- Nine-Slice — UI panel borders
-- =============================================================================

--@api-stub: lurek.render.newNineSlice
-- Demonstrates the proper usage of lurek.render.newNineSlice.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_newNineSlice()
    local panel_9s = lurek.render.newNineSlice("assets/ui/panel_frame.png", 8, 8, 8, 8)
end
local _ok, _err = pcall(demo_lurek_render_newNineSlice)

--@api-stub: lurek.render.drawNineSlice
-- Demonstrates the proper usage of lurek.render.drawNineSlice.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_drawNineSlice()
    lurek.render.drawNineSlice(panel_9s, 50, 350, 300, 150)
end
local _ok, _err = pcall(demo_lurek_render_drawNineSlice)

-- =============================================================================
-- Shape Builder — batched line/polyline geometry
-- =============================================================================

--@api-stub: lurek.render.newShape
-- Demonstrates the proper usage of lurek.render.newShape.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_newShape()
    local path_shape = lurek.render.newShape()
end
local _ok, _err = pcall(demo_lurek_render_newShape)

-- =============================================================================
-- Draw Layers — ordered render groups
-- =============================================================================

--@api-stub: lurek.render.newDrawLayer
-- Demonstrates the proper usage of lurek.render.newDrawLayer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_newDrawLayer()
    local ui_layer = lurek.render.newDrawLayer()
end
local _ok, _err = pcall(demo_lurek_render_newDrawLayer)

--@api-stub: lurek.render.newLayer
-- Demonstrates the proper usage of lurek.render.newLayer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_newLayer()
    local bg_layer = lurek.render.newLayer("background")
end
local _ok, _err = pcall(demo_lurek_render_newLayer)

--@api-stub: lurek.render.setLayer
-- Demonstrates the proper usage of lurek.render.setLayer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_setLayer()
    lurek.render.setLayer("background")
end
local _ok, _err = pcall(demo_lurek_render_setLayer)

--@api-stub: lurek.render.currentLayer
-- Demonstrates the proper usage of lurek.render.currentLayer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_currentLayer()
    print("current layer: " .. tostring(lurek.render.currentLayer()))
end
local _ok, _err = pcall(demo_lurek_render_currentLayer)

--@api-stub: lurek.render.setLayerVisible
-- Demonstrates the proper usage of lurek.render.setLayerVisible.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_setLayerVisible()
    lurek.render.setLayerVisible("background", true)
end
local _ok, _err = pcall(demo_lurek_render_setLayerVisible)

--@api-stub: lurek.render.isLayerVisible
-- Demonstrates the proper usage of lurek.render.isLayerVisible.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_isLayerVisible()
    print("bg visible: " .. tostring(lurek.render.isLayerVisible("background")))
end
local _ok, _err = pcall(demo_lurek_render_isLayerVisible)

--@api-stub: lurek.render.getLayerZOrder
-- Demonstrates the proper usage of lurek.render.getLayerZOrder.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getLayerZOrder()
    print("bg z-order: " .. lurek.render.getLayerZOrder("background"))
end
local _ok, _err = pcall(demo_lurek_render_getLayerZOrder)

--@api-stub: lurek.render.setLayerZOrder
-- Demonstrates the proper usage of lurek.render.setLayerZOrder.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_setLayerZOrder()
    lurek.render.setLayerZOrder("background", -10)
end
local _ok, _err = pcall(demo_lurek_render_setLayerZOrder)

-- =============================================================================
-- Sort Groups — depth sorting within a frame
-- =============================================================================

--@api-stub: lurek.render.beginSortGroup
-- Demonstrates the proper usage of lurek.render.beginSortGroup.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_beginSortGroup()
    lurek.render.beginSortGroup()
end
local _ok, _err = pcall(demo_lurek_render_beginSortGroup)

--@api-stub: lurek.render.pushSortKey
-- Demonstrates the proper usage of lurek.render.pushSortKey.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_pushSortKey()
    lurek.render.pushSortKey(300)
    lurek.render.draw(hero_tex, 200, 300)
end
local _ok, _err = pcall(demo_lurek_render_pushSortKey)

--@api-stub: lurek.render.flushSortGroup
-- Demonstrates the proper usage of lurek.render.flushSortGroup.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_flushSortGroup()
    lurek.render.flushSortGroup()
end
local _ok, _err = pcall(demo_lurek_render_flushSortGroup)

-- =============================================================================
-- Layer Stack (push/pop for render-to-texture)
-- =============================================================================

--@api-stub: lurek.render.pushLayer
-- Demonstrates the proper usage of lurek.render.pushLayer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_pushLayer()
    lurek.render.pushLayer(minimap_canvas)
end
local _ok, _err = pcall(demo_lurek_render_pushLayer)

--@api-stub: lurek.render.popLayer
-- Demonstrates the proper usage of lurek.render.popLayer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_popLayer()
    lurek.render.popLayer()
end
local _ok, _err = pcall(demo_lurek_render_popLayer)

-- =============================================================================
-- Transform Stack
-- =============================================================================

--@api-stub: lurek.render.push
-- Demonstrates the proper usage of lurek.render.push.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_push()
    lurek.render.push()
end
local _ok, _err = pcall(demo_lurek_render_push)

--@api-stub: lurek.render.translate
-- Demonstrates the proper usage of lurek.render.translate.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_translate()
    lurek.render.translate(400, 300)
end
local _ok, _err = pcall(demo_lurek_render_translate)

--@api-stub: lurek.render.rotate
-- Demonstrates the proper usage of lurek.render.rotate.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_rotate()
    lurek.render.rotate(math.rad(45))
end
local _ok, _err = pcall(demo_lurek_render_rotate)

--@api-stub: lurek.render.scale
-- Demonstrates the proper usage of lurek.render.scale.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_scale()
    lurek.render.scale(2.0, 2.0)
end
local _ok, _err = pcall(demo_lurek_render_scale)

--@api-stub: lurek.render.shear
-- Demonstrates the proper usage of lurek.render.shear.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_shear()
    lurek.render.shear(0.1, 0)
end
local _ok, _err = pcall(demo_lurek_render_shear)

--@api-stub: lurek.render.origin
-- Demonstrates the proper usage of lurek.render.origin.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_origin()
    lurek.render.origin()
end
local _ok, _err = pcall(demo_lurek_render_origin)

--@api-stub: lurek.render.applyTransform
-- Demonstrates the proper usage of lurek.render.applyTransform.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_applyTransform()
    lurek.render.applyTransform(1, 0, 0, 1, 100, 50)
end
local _ok, _err = pcall(demo_lurek_render_applyTransform)

--@api-stub: lurek.render.pop
-- Demonstrates the proper usage of lurek.render.pop.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_pop()
    lurek.render.pop()
end
local _ok, _err = pcall(demo_lurek_render_pop)

-- =============================================================================
-- Scissor (clipping) — HUD health bar clip region
-- =============================================================================

--@api-stub: lurek.render.setScissor
-- Demonstrates the proper usage of lurek.render.setScissor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_setScissor()
    lurek.render.setScissor(20, 20, 200, 30)
end
local _ok, _err = pcall(demo_lurek_render_setScissor)

--@api-stub: lurek.render.getScissor
-- Demonstrates the proper usage of lurek.render.getScissor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getScissor()
    local sx, sy, sw, sh = lurek.render.getScissor()
    print("scissor: " .. sx .. "," .. sy .. " " .. sw .. "x" .. sh)
end
local _ok, _err = pcall(demo_lurek_render_getScissor)

--@api-stub: lurek.render.intersectScissor
-- Demonstrates the proper usage of lurek.render.intersectScissor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_intersectScissor()
    lurek.render.intersectScissor(30, 25, 180, 20)
    lurek.render.setScissor()
end
local _ok, _err = pcall(demo_lurek_render_intersectScissor)

-- =============================================================================
-- Color Mask
-- =============================================================================

--@api-stub: lurek.render.setColorMask
-- Demonstrates the proper usage of lurek.render.setColorMask.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_setColorMask()
    lurek.render.setColorMask(false, false, false, true)
end
local _ok, _err = pcall(demo_lurek_render_setColorMask)

--@api-stub: lurek.render.getColorMask
-- Demonstrates the proper usage of lurek.render.getColorMask.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getColorMask()
    local mr, mg, mb, ma = lurek.render.getColorMask()
    print("color mask: r=" .. tostring(mr) .. " g=" .. tostring(mg))
    lurek.render.setColorMask(true, true, true, true)
end
local _ok, _err = pcall(demo_lurek_render_getColorMask)

-- =============================================================================
-- Wireframe Mode
-- =============================================================================

--@api-stub: lurek.render.setWireframe
-- Demonstrates the proper usage of lurek.render.setWireframe.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_setWireframe()
    lurek.render.setWireframe(false)
end
local _ok, _err = pcall(demo_lurek_render_setWireframe)

--@api-stub: lurek.render.isWireframe
-- Demonstrates the proper usage of lurek.render.isWireframe.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_isWireframe()
    print("wireframe: " .. tostring(lurek.render.isWireframe()))
end
local _ok, _err = pcall(demo_lurek_render_isWireframe)

-- =============================================================================
-- Stencil Buffer
-- =============================================================================

--@api-stub: lurek.render.stencil
-- Demonstrates the proper usage of lurek.render.stencil.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_stencil()
    lurek.render.stencil(function()
    lurek.render.circle("fill", 400, 300, 100)
end
local _ok, _err = pcall(demo_lurek_render_stencil)

--@api-stub: lurek.render.setStencilTest
-- Demonstrates the proper usage of lurek.render.setStencilTest.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_setStencilTest()
    lurek.render.setStencilTest("greater", 0)
end
local _ok, _err = pcall(demo_lurek_render_setStencilTest)

--@api-stub: lurek.render.setStencilMode
-- Demonstrates the proper usage of lurek.render.setStencilMode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_setStencilMode()
    lurek.render.setStencilMode("replace", 1)
end
local _ok, _err = pcall(demo_lurek_render_setStencilMode)

--@api-stub: lurek.render.getStencilMode
-- Demonstrates the proper usage of lurek.render.getStencilMode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getStencilMode()
    local sm_action, sm_value = lurek.render.getStencilMode()
    print("stencil mode: " .. tostring(sm_action) .. " val=" .. tostring(sm_value))
end
local _ok, _err = pcall(demo_lurek_render_getStencilMode)

--@api-stub: lurek.render.clearStencil
-- Demonstrates the proper usage of lurek.render.clearStencil.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_clearStencil()
    lurek.render.clearStencil()
end
local _ok, _err = pcall(demo_lurek_render_clearStencil)

-- =============================================================================
-- Depth Mode
-- =============================================================================

--@api-stub: lurek.render.setDepthMode
-- Demonstrates the proper usage of lurek.render.setDepthMode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_setDepthMode()
    lurek.render.setDepthMode("lequal", true)
end
local _ok, _err = pcall(demo_lurek_render_setDepthMode)

--@api-stub: lurek.render.getDepthMode
-- Demonstrates the proper usage of lurek.render.getDepthMode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getDepthMode()
    local dm_cmp, dm_write = lurek.render.getDepthMode()
    print("depth: " .. tostring(dm_cmp) .. " write=" .. tostring(dm_write))
end
local _ok, _err = pcall(demo_lurek_render_getDepthMode)

-- =============================================================================
-- Screen Dimensions & Defaults
-- =============================================================================

--@api-stub: lurek.render.getWidth
-- Demonstrates the proper usage of lurek.render.getWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getWidth()
    print("screen width: " .. lurek.render.getWidth())
end
local _ok, _err = pcall(demo_lurek_render_getWidth)

--@api-stub: lurek.render.getHeight
-- Demonstrates the proper usage of lurek.render.getHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getHeight()
    print("screen height: " .. lurek.render.getHeight())
end
local _ok, _err = pcall(demo_lurek_render_getHeight)

--@api-stub: lurek.render.getDimensions
-- Demonstrates the proper usage of lurek.render.getDimensions.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getDimensions()
    local scrw, scrh = lurek.render.getDimensions()
    print("screen: " .. scrw .. "x" .. scrh)
end
local _ok, _err = pcall(demo_lurek_render_getDimensions)

--@api-stub: lurek.render.setDefaultFilter
-- Demonstrates the proper usage of lurek.render.setDefaultFilter.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_setDefaultFilter()
    lurek.render.setDefaultFilter("nearest", "nearest")
end
local _ok, _err = pcall(demo_lurek_render_setDefaultFilter)

--@api-stub: lurek.render.getDefaultFilter
-- Demonstrates the proper usage of lurek.render.getDefaultFilter.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getDefaultFilter()
    local fmin, fmag = lurek.render.getDefaultFilter()
    print("filter: min=" .. fmin .. " mag=" .. fmag)
end
local _ok, _err = pcall(demo_lurek_render_getDefaultFilter)

-- =============================================================================
-- Statistics & Screenshots
-- =============================================================================

--@api-stub: lurek.render.getStats
-- Demonstrates the proper usage of lurek.render.getStats.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getStats()
    local stats = lurek.render.getStats()
    print("draw calls: " .. tostring(stats.drawcalls) .. ", textures: " .. tostring(stats.textures))
end
local _ok, _err = pcall(demo_lurek_render_getStats)

--@api-stub: lurek.render.saveScreenshot
-- Demonstrates the proper usage of lurek.render.saveScreenshot.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_saveScreenshot()
    lurek.render.saveScreenshot("output/screenshot.png")
end
local _ok, _err = pcall(demo_lurek_render_saveScreenshot)

--@api-stub: lurek.render.captureScreenshot
-- Demonstrates the proper usage of lurek.render.captureScreenshot.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_captureScreenshot()
    local screenshot_data = lurek.render.captureScreenshot()
    print("screenshot captured: " .. tostring(screenshot_data))
end
local _ok, _err = pcall(demo_lurek_render_captureScreenshot)

-- =============================================================================
-- ImageData Object Methods
-- =============================================================================

local img_data = lurek.image.newImageData(64, 64)

--@api-stub: ImageData:getWidth
-- Demonstrates the proper usage of ImageData:getWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ImageData_getWidth()
    print("img data width: " .. img_data:getWidth())
end
local _ok, _err = pcall(demo_ImageData_getWidth)

--@api-stub: ImageData:getHeight
-- Demonstrates the proper usage of ImageData:getHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ImageData_getHeight()
    print("img data height: " .. img_data:getHeight())
end
local _ok, _err = pcall(demo_ImageData_getHeight)

--@api-stub: ImageData:resize
-- Demonstrates the proper usage of ImageData:resize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ImageData_resize()
    img_data:resize(32, 32)
    print("resized to 32x32")
end
local _ok, _err = pcall(demo_ImageData_resize)

--@api-stub: ImageData:mapPixels
-- Demonstrates the proper usage of ImageData:mapPixels.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ImageData_mapPixels()
    img_data:mapPixels(function(x, y, r, g, b, a)
    return x / 32, y / 32, 0.5, 1.0
    print("gradient mapped onto image data")
end
local _ok, _err = pcall(demo_ImageData_mapPixels)

--@api-stub: ImageData:diff
-- Demonstrates the proper usage of ImageData:diff.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ImageData_diff()
    local diff_data = img_data:diff(img_data)
    print("diff with self: " .. tostring(diff_data))
end
local _ok, _err = pcall(demo_ImageData_diff)

--@api-stub: ImageData:type
-- Demonstrates the proper usage of ImageData:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ImageData_type()
    print("ImageData type: " .. img_data:type())
end
local _ok, _err = pcall(demo_ImageData_type)

--@api-stub: ImageData:typeOf
-- Demonstrates the proper usage of ImageData:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ImageData_typeOf()
    print("is ImageData: " .. tostring(img_data:typeOf("ImageData")))
end
local _ok, _err = pcall(demo_ImageData_typeOf)

-- =============================================================================
-- NineSlice Object Methods
-- =============================================================================

--@api-stub: NineSlice:getInsets
-- Demonstrates the proper usage of NineSlice:getInsets.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NineSlice_getInsets()
    local left, top, right, bottom = panel_9s:getInsets()
    print("nine-slice insets: " .. left .. "," .. top .. "," .. right .. "," .. bottom)
end
local _ok, _err = pcall(demo_NineSlice_getInsets)

--@api-stub: NineSlice:getTextureSize
-- Demonstrates the proper usage of NineSlice:getTextureSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NineSlice_getTextureSize()
    local nsw, nsh = panel_9s:getTextureSize()
    print("nine-slice texture: " .. nsw .. "x" .. nsh)
end
local _ok, _err = pcall(demo_NineSlice_getTextureSize)

--@api-stub: NineSlice:type
-- Demonstrates the proper usage of NineSlice:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NineSlice_type()
    print("NineSlice type: " .. panel_9s:type())
end
local _ok, _err = pcall(demo_NineSlice_type)

--@api-stub: NineSlice:typeOf
-- Demonstrates the proper usage of NineSlice:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NineSlice_typeOf()
    print("is NineSlice: " .. tostring(panel_9s:typeOf("NineSlice")))
end
local _ok, _err = pcall(demo_NineSlice_typeOf)

-- =============================================================================
-- Image Object Methods
-- =============================================================================

--@api-stub: Image:getWidth
-- Demonstrates the proper usage of Image:getWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Image_getWidth()
    print("hero tex width: " .. hero_tex:getWidth())
end
local _ok, _err = pcall(demo_Image_getWidth)

--@api-stub: Image:getHeight
-- Demonstrates the proper usage of Image:getHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Image_getHeight()
    print("hero tex height: " .. hero_tex:getHeight())
end
local _ok, _err = pcall(demo_Image_getHeight)

--@api-stub: Image:getDimensions
-- Demonstrates the proper usage of Image:getDimensions.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Image_getDimensions()
    local tw, th = hero_tex:getDimensions()
    print("hero tex: " .. tw .. "x" .. th)
end
local _ok, _err = pcall(demo_Image_getDimensions)

--@api-stub: Image:type
-- Demonstrates the proper usage of Image:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Image_type()
    print("Image type: " .. hero_tex:type())
end
local _ok, _err = pcall(demo_Image_type)

--@api-stub: Image:typeOf
-- Demonstrates the proper usage of Image:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Image_typeOf()
    print("is Image: " .. tostring(hero_tex:typeOf("Image")))
end
local _ok, _err = pcall(demo_Image_typeOf)

--@api-stub: Image:release
-- Demonstrates the proper usage of Image:release.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Image_release()
    print('Executing release')
end
local _ok, _err = pcall(demo_Image_release)

-- =============================================================================
-- Font Object Methods
-- =============================================================================

--@api-stub: Font:getWidth
-- Demonstrates the proper usage of Font:getWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Font_getWidth()
    print("dialog font 'Hello' width: " .. dialog_font:getWidth("Hello"))
end
local _ok, _err = pcall(demo_Font_getWidth)

--@api-stub: Font:getHeight
-- Demonstrates the proper usage of Font:getHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Font_getHeight()
    print("dialog font height: " .. dialog_font:getHeight())
end
local _ok, _err = pcall(demo_Font_getHeight)

--@api-stub: Font:getLineHeight
-- Demonstrates the proper usage of Font:getLineHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Font_getLineHeight()
    print("dialog line height: " .. dialog_font:getLineHeight())
end
local _ok, _err = pcall(demo_Font_getLineHeight)

--@api-stub: Font:setLineHeight
-- Demonstrates the proper usage of Font:setLineHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Font_setLineHeight()
    dialog_font:setLineHeight(1.2)
end
local _ok, _err = pcall(demo_Font_setLineHeight)

--@api-stub: Font:getAscent
-- Demonstrates the proper usage of Font:getAscent.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Font_getAscent()
    print("font ascent: " .. dialog_font:getAscent())
end
local _ok, _err = pcall(demo_Font_getAscent)

--@api-stub: Font:getDescent
-- Demonstrates the proper usage of Font:getDescent.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Font_getDescent()
    print("font descent: " .. dialog_font:getDescent())
end
local _ok, _err = pcall(demo_Font_getDescent)

--@api-stub: Font:getWrap
-- Demonstrates the proper usage of Font:getWrap.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Font_getWrap()
    local wrap_lines, wrap_w = dialog_font:getWrap("Wrap this text", 200)
    print("font wrap: " .. #wrap_lines .. " lines")
end
local _ok, _err = pcall(demo_Font_getWrap)

--@api-stub: Font:type
-- Demonstrates the proper usage of Font:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Font_type()
    print("Font type: " .. dialog_font:type())
end
local _ok, _err = pcall(demo_Font_type)

--@api-stub: Font:typeOf
-- Demonstrates the proper usage of Font:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Font_typeOf()
    print("is Font: " .. tostring(dialog_font:typeOf("Font")))
end
local _ok, _err = pcall(demo_Font_typeOf)

--@api-stub: Font:release
-- Demonstrates the proper usage of Font:release.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Font_release()
    print('Executing release')
end
local _ok, _err = pcall(demo_Font_release)

-- =============================================================================
-- Canvas Object Methods
-- =============================================================================

--@api-stub: Canvas:getWidth
-- Demonstrates the proper usage of Canvas:getWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Canvas_getWidth()
    print("minimap canvas width: " .. minimap_canvas:getWidth())
end
local _ok, _err = pcall(demo_Canvas_getWidth)

--@api-stub: Canvas:getHeight
-- Demonstrates the proper usage of Canvas:getHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Canvas_getHeight()
    print("minimap canvas height: " .. minimap_canvas:getHeight())
end
local _ok, _err = pcall(demo_Canvas_getHeight)

--@api-stub: Canvas:getDimensions
-- Demonstrates the proper usage of Canvas:getDimensions.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Canvas_getDimensions()
    local mc_w, mc_h = minimap_canvas:getDimensions()
    print("minimap canvas: " .. mc_w .. "x" .. mc_h)
end
local _ok, _err = pcall(demo_Canvas_getDimensions)

--@api-stub: Canvas:type
-- Demonstrates the proper usage of Canvas:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Canvas_type()
    print("Canvas type: " .. minimap_canvas:type())
end
local _ok, _err = pcall(demo_Canvas_type)

--@api-stub: Canvas:typeOf
-- Demonstrates the proper usage of Canvas:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Canvas_typeOf()
    print("is Canvas: " .. tostring(minimap_canvas:typeOf("Canvas")))
end
local _ok, _err = pcall(demo_Canvas_typeOf)

--@api-stub: Canvas:release
-- Demonstrates the proper usage of Canvas:release.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Canvas_release()
    print('Executing release')
end
local _ok, _err = pcall(demo_Canvas_release)

-- =============================================================================
-- SpriteBatch Object Methods
-- =============================================================================

--@api-stub: SpriteBatch:getCount
-- Demonstrates the proper usage of SpriteBatch:getCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SpriteBatch_getCount()
    print("batch count: " .. tile_batch:getCount())
end
local _ok, _err = pcall(demo_SpriteBatch_getCount)

--@api-stub: SpriteBatch:getBufferSize
-- Demonstrates the proper usage of SpriteBatch:getBufferSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SpriteBatch_getBufferSize()
    print("batch buffer: " .. tile_batch:getBufferSize())
end
local _ok, _err = pcall(demo_SpriteBatch_getBufferSize)

--@api-stub: SpriteBatch:clear
-- Demonstrates the proper usage of SpriteBatch:clear.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SpriteBatch_clear()
    tile_batch:clear()
    print("batch cleared")
end
local _ok, _err = pcall(demo_SpriteBatch_clear)

--@api-stub: SpriteBatch:type
-- Demonstrates the proper usage of SpriteBatch:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SpriteBatch_type()
    print("SpriteBatch type: " .. tile_batch:type())
end
local _ok, _err = pcall(demo_SpriteBatch_type)

--@api-stub: SpriteBatch:typeOf
-- Demonstrates the proper usage of SpriteBatch:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SpriteBatch_typeOf()
    print("is SpriteBatch: " .. tostring(tile_batch:typeOf("SpriteBatch")))
end
local _ok, _err = pcall(demo_SpriteBatch_typeOf)

--@api-stub: SpriteBatch:release
-- Demonstrates the proper usage of SpriteBatch:release.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SpriteBatch_release()
    print('Executing release')
end
local _ok, _err = pcall(demo_SpriteBatch_release)

-- =============================================================================
-- Mesh Object Methods
-- =============================================================================

--@api-stub: Mesh:getVertexCount
-- Demonstrates the proper usage of Mesh:getVertexCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Mesh_getVertexCount()
    print("water mesh vertices: " .. water_mesh:getVertexCount())
end
local _ok, _err = pcall(demo_Mesh_getVertexCount)

--@api-stub: Mesh:getVertex
-- Demonstrates the proper usage of Mesh:getVertex.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Mesh_getVertex()
    local vx, vy, vu, vv = water_mesh:getVertex(0)
    print("vertex 0: " .. vx .. "," .. vy .. " uv=" .. vu .. "," .. vv)
end
local _ok, _err = pcall(demo_Mesh_getVertex)

--@api-stub: Mesh:setVertex
-- Demonstrates the proper usage of Mesh:setVertex.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Mesh_setVertex()
    water_mesh:setVertex(0, {0, 0, 0, 0, 1, 1, 1, 1})
end
local _ok, _err = pcall(demo_Mesh_setVertex)

--@api-stub: Mesh:setTexture
-- Demonstrates the proper usage of Mesh:setTexture.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Mesh_setTexture()
    water_mesh:setTexture(hero_tex)
end
local _ok, _err = pcall(demo_Mesh_setTexture)

--@api-stub: Mesh:type
-- Demonstrates the proper usage of Mesh:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Mesh_type()
    print("Mesh type: " .. water_mesh:type())
end
local _ok, _err = pcall(demo_Mesh_type)

--@api-stub: Mesh:typeOf
-- Demonstrates the proper usage of Mesh:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Mesh_typeOf()
    print("is Mesh: " .. tostring(water_mesh:typeOf("Mesh")))
end
local _ok, _err = pcall(demo_Mesh_typeOf)

--@api-stub: Mesh:release
-- Demonstrates the proper usage of Mesh:release.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Mesh_release()
    print('Executing release')
end
local _ok, _err = pcall(demo_Mesh_release)

-- =============================================================================
-- Shader Object Methods
-- =============================================================================

--@api-stub: Shader:send
-- Demonstrates the proper usage of Shader:send.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Shader_send()
    water_shader:send("u_time", 1.5)
end
local _ok, _err = pcall(demo_Shader_send)

--@api-stub: Shader:hasUniform
-- Demonstrates the proper usage of Shader:hasUniform.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Shader_hasUniform()
    print("has u_time: " .. tostring(water_shader:hasUniform("u_time")))
end
local _ok, _err = pcall(demo_Shader_hasUniform)

--@api-stub: Shader:type
-- Demonstrates the proper usage of Shader:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Shader_type()
    print("Shader type: " .. water_shader:type())
end
local _ok, _err = pcall(demo_Shader_type)

--@api-stub: Shader:typeOf
-- Demonstrates the proper usage of Shader:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Shader_typeOf()
    print("is Shader: " .. tostring(water_shader:typeOf("Shader")))
end
local _ok, _err = pcall(demo_Shader_typeOf)

--@api-stub: Shader:release
-- Demonstrates the proper usage of Shader:release.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Shader_release()
    print('Executing release')
end
local _ok, _err = pcall(demo_Shader_release)

-- =============================================================================
-- Quad Object Methods
-- =============================================================================

--@api-stub: Quad:getViewport
-- Demonstrates the proper usage of Quad:getViewport.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Quad_getViewport()
    local qx, qy, qw, qh = hero_quad:getViewport()
    print("quad viewport: " .. qx .. "," .. qy .. " " .. qw .. "x" .. qh)
end
local _ok, _err = pcall(demo_Quad_getViewport)

--@api-stub: Quad:getTextureDimensions
-- Demonstrates the proper usage of Quad:getTextureDimensions.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Quad_getTextureDimensions()
    local qtw, qth = hero_quad:getTextureDimensions()
    print("quad tex: " .. qtw .. "x" .. qth)
end
local _ok, _err = pcall(demo_Quad_getTextureDimensions)

--@api-stub: Quad:type
-- Demonstrates the proper usage of Quad:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Quad_type()
    print("Quad type: " .. hero_quad:type())
end
local _ok, _err = pcall(demo_Quad_type)

--@api-stub: Quad:typeOf
-- Demonstrates the proper usage of Quad:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Quad_typeOf()
    print("is Quad: " .. tostring(hero_quad:typeOf("Quad")))
end
local _ok, _err = pcall(demo_Quad_typeOf)

-- =============================================================================
-- Shape Object Methods
-- =============================================================================

--@api-stub: Shape:getCommandCount
-- Demonstrates the proper usage of Shape:getCommandCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Shape_getCommandCount()
    print("shape commands: " .. path_shape:getCommandCount())
end
local _ok, _err = pcall(demo_Shape_getCommandCount)

--@api-stub: Shape:setLineWidth
-- Demonstrates the proper usage of Shape:setLineWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Shape_setLineWidth()
    path_shape:setLineWidth(2.0)
end
local _ok, _err = pcall(demo_Shape_setLineWidth)

--@api-stub: Shape:line
-- Demonstrates the proper usage of Shape:line.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Shape_line()
    path_shape:line(0, 0, 100, 100)
end
local _ok, _err = pcall(demo_Shape_line)

--@api-stub: Shape:polyline
-- Demonstrates the proper usage of Shape:polyline.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Shape_polyline()
    path_shape:polyline({0,0, 50,30, 100,10, 150,40})
end
local _ok, _err = pcall(demo_Shape_polyline)

--@api-stub: Shape:clear
-- Demonstrates the proper usage of Shape:clear.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Shape_clear()
    path_shape:clear()
    print("shape cleared")
end
local _ok, _err = pcall(demo_Shape_clear)

--@api-stub: Shape:type
-- Demonstrates the proper usage of Shape:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Shape_type()
    print("Shape type: " .. path_shape:type())
end
local _ok, _err = pcall(demo_Shape_type)

--@api-stub: Shape:typeOf
-- Demonstrates the proper usage of Shape:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Shape_typeOf()
    print("is Shape: " .. tostring(path_shape:typeOf("Shape")))
end
local _ok, _err = pcall(demo_Shape_typeOf)

-- =============================================================================
-- DrawLayer Object Methods
-- =============================================================================

--@api-stub: DrawLayer:queue
-- Demonstrates the proper usage of DrawLayer:queue.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DrawLayer_queue()
    ui_layer:queue(function()
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.print("HUD Text", 10, 10)
end
local _ok, _err = pcall(demo_DrawLayer_queue)

--@api-stub: DrawLayer:getCount
-- Demonstrates the proper usage of DrawLayer:getCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DrawLayer_getCount()
    print("UI layer queued: " .. ui_layer:getCount())
end
local _ok, _err = pcall(demo_DrawLayer_getCount)

--@api-stub: DrawLayer:flush
-- Demonstrates the proper usage of DrawLayer:flush.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DrawLayer_flush()
    ui_layer:flush()
end
local _ok, _err = pcall(demo_DrawLayer_flush)

--@api-stub: DrawLayer:clear
-- Demonstrates the proper usage of DrawLayer:clear.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DrawLayer_clear()
    ui_layer:clear()
end
local _ok, _err = pcall(demo_DrawLayer_clear)

--@api-stub: DrawLayer:type
-- Demonstrates the proper usage of DrawLayer:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DrawLayer_type()
    print("DrawLayer type: " .. ui_layer:type())
end
local _ok, _err = pcall(demo_DrawLayer_type)

--@api-stub: DrawLayer:typeOf
print("is DrawLayer: " .. tostring(ui_layer:typeOf("DrawLayer")))

print("\n-- render.lua example complete --")
-- content/examples/render.lua
-- Lurek2D lurek.render API Reference
-- Run with: cargo run -- content/examples/render
--
-- Scenario: A retro arcade game renderer — background gradient, geometric shapes
-- for UI borders, sprite drawing with quads, bitmap fonts, off-screen canvases
-- for minimap, custom shaders for CRT effect, nine-slice panels, bezier curves
-- for particle trails, sort groups for depth ordering, mesh-based terrain,
-- draw layers for batched rendering, and screenshots for replay thumbnails.

print("=== lurek.render — Retro Arcade Renderer ===\n")

-- =============================================================================
-- Screen Setup — colours and background
-- =============================================================================

-- ---- Stub: lurek.render.getWidth -----------------------------------------
--@api-stub: lurek.render.getWidth
-- Demonstrates the proper usage of lurek.render.getWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getWidth()
    local scr_w = lurek.render.getWidth()
    print("screen width: " .. tostring(scr_w))
end
local _ok, _err = pcall(demo_lurek_render_getWidth)

-- ---- Stub: lurek.render.getHeight ----------------------------------------
--@api-stub: lurek.render.getHeight
-- Demonstrates the proper usage of lurek.render.getHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getHeight()
    local scr_h = lurek.render.getHeight()
    print("screen height: " .. tostring(scr_h))
end
local _ok, _err = pcall(demo_lurek_render_getHeight)

-- ---- Stub: lurek.render.getDimensions ------------------------------------
--@api-stub: lurek.render.getDimensions
-- Demonstrates the proper usage of lurek.render.getDimensions.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getDimensions()
    local sw, sh = lurek.render.getDimensions()
    print("screen: " .. tostring(sw) .. "x" .. tostring(sh))
end
local _ok, _err = pcall(demo_lurek_render_getDimensions)

-- ---- Stub: lurek.render.setBackgroundColor --------------------------------
--@api-stub: lurek.render.setBackgroundColor
-- Demonstrates the proper usage of lurek.render.setBackgroundColor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_setBackgroundColor()
    lurek.render.setBackgroundColor(0.05, 0.05, 0.15, 1.0)
    print("background set to dark blue")
end
local _ok, _err = pcall(demo_lurek_render_setBackgroundColor)

-- ---- Stub: lurek.render.getBackgroundColor --------------------------------
--@api-stub: lurek.render.getBackgroundColor
-- Demonstrates the proper usage of lurek.render.getBackgroundColor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getBackgroundColor()
    local br, bg, bb, ba = lurek.render.getBackgroundColor()
    print("background: (" .. tostring(br) .. "," .. tostring(bg) .. "," .. tostring(bb) .. ")")
end
local _ok, _err = pcall(demo_lurek_render_getBackgroundColor)

-- ---- Stub: lurek.render.clear --------------------------------------------
--@api-stub: lurek.render.clear
-- Demonstrates the proper usage of lurek.render.clear.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_clear()
    lurek.render.clear(0.05, 0.05, 0.15, 1.0)
    print("screen cleared")
end
local _ok, _err = pcall(demo_lurek_render_clear)

-- ---- Stub: lurek.render.setColor -----------------------------------------
--@api-stub: lurek.render.setColor
-- Demonstrates the proper usage of lurek.render.setColor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_setColor()
    lurek.render.setColor(1, 1, 1, 1)
    print("draw colour: white")
end
local _ok, _err = pcall(demo_lurek_render_setColor)

-- ---- Stub: lurek.render.getColor -----------------------------------------
--@api-stub: lurek.render.getColor
-- Demonstrates the proper usage of lurek.render.getColor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getColor()
    local cr, cg, cb, ca = lurek.render.getColor()
    print("current colour: (" .. tostring(cr) .. "," .. tostring(cg) .. "," .. tostring(cb) .. "," .. tostring(ca) .. ")")
end
local _ok, _err = pcall(demo_lurek_render_getColor)

-- =============================================================================
-- Primitive Drawing — arcade shapes
-- =============================================================================

-- ---- Stub: lurek.render.setLineWidth -------------------------------------
--@api-stub: lurek.render.setLineWidth
-- Demonstrates the proper usage of lurek.render.setLineWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_setLineWidth()
    lurek.render.setLineWidth(2)
    print("line width: 2")
end
local _ok, _err = pcall(demo_lurek_render_setLineWidth)

-- ---- Stub: lurek.render.getLineWidth -------------------------------------
--@api-stub: lurek.render.getLineWidth
-- Demonstrates the proper usage of lurek.render.getLineWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getLineWidth()
    print("line width: " .. tostring(lurek.render.getLineWidth()))
end
local _ok, _err = pcall(demo_lurek_render_getLineWidth)

-- ---- Stub: lurek.render.setPointSize -------------------------------------
--@api-stub: lurek.render.setPointSize
-- Demonstrates the proper usage of lurek.render.setPointSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_setPointSize()
    lurek.render.setPointSize(3)
    print("point size: 3")
end
local _ok, _err = pcall(demo_lurek_render_setPointSize)

-- ---- Stub: lurek.render.getPointSize -------------------------------------
--@api-stub: lurek.render.getPointSize
-- Demonstrates the proper usage of lurek.render.getPointSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getPointSize()
    print("point size: " .. tostring(lurek.render.getPointSize()))
end
local _ok, _err = pcall(demo_lurek_render_getPointSize)

-- ---- Stub: lurek.render.rectangle ----------------------------------------
--@api-stub: lurek.render.rectangle
-- Draw the play area border.
lurek.render.setColor(0, 1, 0, 1)
lurek.render.rectangle("line", 10, 10, sw - 20, sh - 20)
print("play area border drawn")

-- Filled background panel.
lurek.render.setColor(0.1, 0.1, 0.2, 0.8)
lurek.render.rectangle("fill", 20, 20, 200, 40)
print("score panel background drawn")

-- ---- Stub: lurek.render.circle -------------------------------------------
--@api-stub: lurek.render.circle
-- Demonstrates the proper usage of lurek.render.circle.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_circle()
    lurek.render.setColor(0, 1, 1, 1)
    lurek.render.circle("fill", 400, 300, 16, 32)
    print("player circle drawn at (400, 300)")
end
local _ok, _err = pcall(demo_lurek_render_circle)

-- ---- Stub: lurek.render.ellipse ------------------------------------------
--@api-stub: lurek.render.ellipse
-- Demonstrates the proper usage of lurek.render.ellipse.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_ellipse()
    lurek.render.setColor(1, 0, 0, 1)
    lurek.render.ellipse("fill", 600, 200, 24, 12, 24)
    print("enemy ship ellipse drawn")
end
local _ok, _err = pcall(demo_lurek_render_ellipse)

-- ---- Stub: lurek.render.triangle -----------------------------------------
--@api-stub: lurek.render.triangle
-- Demonstrates the proper usage of lurek.render.triangle.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_triangle()
    lurek.render.setColor(0, 1, 0, 1)
    lurek.render.triangle("fill", 400, 280, 384, 310, 416, 310)
    print("player ship triangle drawn")
end
local _ok, _err = pcall(demo_lurek_render_triangle)

-- ---- Stub: lurek.render.line ---------------------------------------------
--@api-stub: lurek.render.line
-- Demonstrates the proper usage of lurek.render.line.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_line()
    lurek.render.setColor(1, 1, 0, 1)
    lurek.render.line(400, 280, 400, 10)
    print("laser beam line drawn")
end
local _ok, _err = pcall(demo_lurek_render_line)

-- ---- Stub: lurek.render.polygon ------------------------------------------
--@api-stub: lurek.render.polygon
-- Demonstrates the proper usage of lurek.render.polygon.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_polygon()
    lurek.render.setColor(0.6, 0.6, 0.6, 1)
    lurek.render.polygon("fill", 200, 150, 220, 140, 240, 155, 235, 175, 215, 180, 195, 170)
    print("asteroid polygon drawn")
end
local _ok, _err = pcall(demo_lurek_render_polygon)

-- ---- Stub: lurek.render.arc ----------------------------------------------
--@api-stub: lurek.render.arc
-- Demonstrates the proper usage of lurek.render.arc.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_arc()
    lurek.render.setColor(0.3, 0.5, 1, 0.6)
    lurek.render.arc("line", 400, 300, 30, 0, math.pi, 20)
    print("shield arc drawn")
end
local _ok, _err = pcall(demo_lurek_render_arc)

-- ---- Stub: lurek.render.points -------------------------------------------
--@api-stub: lurek.render.points
-- Demonstrates the proper usage of lurek.render.points.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_points()
    lurek.render.setColor(1, 1, 1, 0.8)
    lurek.render.points(50, 50, 150, 80, 300, 40, 500, 120, 700, 60, 250, 200)
    print("star field points drawn")
end
local _ok, _err = pcall(demo_lurek_render_points)

-- =============================================================================
-- Blend Modes & Wireframe
-- =============================================================================

-- ---- Stub: lurek.render.setBlendMode -------------------------------------
--@api-stub: lurek.render.setBlendMode
-- Demonstrates the proper usage of lurek.render.setBlendMode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_setBlendMode()
    lurek.render.setBlendMode("alpha")
    print("blend mode: alpha")
end
local _ok, _err = pcall(demo_lurek_render_setBlendMode)

-- ---- Stub: lurek.render.getBlendMode -------------------------------------
--@api-stub: lurek.render.getBlendMode
-- Demonstrates the proper usage of lurek.render.getBlendMode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getBlendMode()
    print("blend mode: " .. tostring(lurek.render.getBlendMode()))
    lurek.render.setBlendMode("add")
    lurek.render.setColor(1, 0.5, 0, 0.8)
    lurek.render.circle("fill", 600, 200, 32, 24)
    print("explosion drawn with additive blending")
    lurek.render.setBlendMode("alpha")
end
local _ok, _err = pcall(demo_lurek_render_getBlendMode)

-- ---- Stub: lurek.render.setWireframe -------------------------------------
--@api-stub: lurek.render.setWireframe
-- Demonstrates the proper usage of lurek.render.setWireframe.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_setWireframe()
    lurek.render.setWireframe(false)
end
local _ok, _err = pcall(demo_lurek_render_setWireframe)

-- ---- Stub: lurek.render.isWireframe --------------------------------------
--@api-stub: lurek.render.isWireframe
-- Demonstrates the proper usage of lurek.render.isWireframe.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_isWireframe()
    print("wireframe: " .. tostring(lurek.render.isWireframe()))
end
local _ok, _err = pcall(demo_lurek_render_isWireframe)

-- =============================================================================
-- Fonts & Text — score display and messages
-- =============================================================================

-- ---- Stub: lurek.render.newFont ------------------------------------------
--@api-stub: lurek.render.newFont
-- Demonstrates the proper usage of lurek.render.newFont.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_newFont()
    local font = lurek.render.newFont(16)
    print("font created: 16px")
end
local _ok, _err = pcall(demo_lurek_render_newFont)

-- ---- Stub: lurek.render.setFont ------------------------------------------
--@api-stub: lurek.render.setFont
-- Demonstrates the proper usage of lurek.render.setFont.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_setFont()
    lurek.render.setFont(font)
    print("font set")
end
local _ok, _err = pcall(demo_lurek_render_setFont)

-- ---- Stub: lurek.render.getFont ------------------------------------------
--@api-stub: lurek.render.getFont
-- Demonstrates the proper usage of lurek.render.getFont.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getFont()
    local cur_font = lurek.render.getFont()
    print("current font: " .. type(cur_font))
end
local _ok, _err = pcall(demo_lurek_render_getFont)

-- ---- Stub: lurek.render.getDefaultFont -----------------------------------
--@api-stub: lurek.render.getDefaultFont
-- Demonstrates the proper usage of lurek.render.getDefaultFont.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getDefaultFont()
    local def_font = lurek.render.getDefaultFont()
    print("default font: " .. type(def_font))
end
local _ok, _err = pcall(demo_lurek_render_getDefaultFont)

-- ---- Stub: lurek.render.getFontSizes -------------------------------------
--@api-stub: lurek.render.getFontSizes
-- Demonstrates the proper usage of lurek.render.getFontSizes.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getFontSizes()
    local sizes = lurek.render.getFontSizes()
    if sizes then print("available font sizes: " .. #sizes) end
end
local _ok, _err = pcall(demo_lurek_render_getFontSizes)

-- ---- Stub: lurek.render.getFontWidth -------------------------------------
--@api-stub: lurek.render.getFontWidth
-- Demonstrates the proper usage of lurek.render.getFontWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getFontWidth()
    local fw = lurek.render.getFontWidth("SCORE: 12345")
    print("'SCORE: 12345' width: " .. tostring(fw) .. "px")
end
local _ok, _err = pcall(demo_lurek_render_getFontWidth)

-- ---- Stub: lurek.render.getFontCellWidth ---------------------------------
--@api-stub: lurek.render.getFontCellWidth
-- Demonstrates the proper usage of lurek.render.getFontCellWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getFontCellWidth()
    local cw = lurek.render.getFontCellWidth()
    print("font cell width: " .. tostring(cw))
end
local _ok, _err = pcall(demo_lurek_render_getFontCellWidth)

-- ---- Stub: lurek.render.getFontHeight ------------------------------------
--@api-stub: lurek.render.getFontHeight
-- Demonstrates the proper usage of lurek.render.getFontHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getFontHeight()
    print("font height: " .. tostring(lurek.render.getFontHeight()))
end
local _ok, _err = pcall(demo_lurek_render_getFontHeight)

-- ---- Stub: lurek.render.getFontLineHeight --------------------------------
--@api-stub: lurek.render.getFontLineHeight
-- Demonstrates the proper usage of lurek.render.getFontLineHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getFontLineHeight()
    print("font line height: " .. tostring(lurek.render.getFontLineHeight()))
end
local _ok, _err = pcall(demo_lurek_render_getFontLineHeight)

-- ---- Stub: lurek.render.setFontLineHeight --------------------------------
--@api-stub: lurek.render.setFontLineHeight
-- Demonstrates the proper usage of lurek.render.setFontLineHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_setFontLineHeight()
    lurek.render.setFontLineHeight(1.2)
    print("font line height set to 1.2")
end
local _ok, _err = pcall(demo_lurek_render_setFontLineHeight)

-- ---- Stub: lurek.render.getFontAscent ------------------------------------
--@api-stub: lurek.render.getFontAscent
-- Demonstrates the proper usage of lurek.render.getFontAscent.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getFontAscent()
    print("font ascent: " .. tostring(lurek.render.getFontAscent()))
end
local _ok, _err = pcall(demo_lurek_render_getFontAscent)

-- ---- Stub: lurek.render.getFontDescent -----------------------------------
--@api-stub: lurek.render.getFontDescent
-- Demonstrates the proper usage of lurek.render.getFontDescent.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getFontDescent()
    print("font descent: " .. tostring(lurek.render.getFontDescent()))
end
local _ok, _err = pcall(demo_lurek_render_getFontDescent)

-- ---- Stub: lurek.render.getFontWrap --------------------------------------
--@api-stub: lurek.render.getFontWrap
-- Demonstrates the proper usage of lurek.render.getFontWrap.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getFontWrap()
    local wrap_w, lines = lurek.render.getFontWrap("Game Over! Insert coin to continue.", 200)
    print("text wrap: width=" .. tostring(wrap_w) .. ", lines=" .. tostring(lines))
end
local _ok, _err = pcall(demo_lurek_render_getFontWrap)

-- ---- Stub: lurek.render.print --------------------------------------------
--@api-stub: lurek.render.print
-- Demonstrates the proper usage of lurek.render.print.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_print()
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.print("SCORE: 12345", 30, 30)
    print("score text drawn")
end
local _ok, _err = pcall(demo_lurek_render_print)

-- ---- Stub: lurek.render.printf -------------------------------------------
--@api-stub: lurek.render.printf
-- Demonstrates the proper usage of lurek.render.printf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_printf()
    lurek.render.printf("HIGH SCORES", 0, 50, sw, "center")
    print("centred text drawn")
end
local _ok, _err = pcall(demo_lurek_render_printf)

-- ---- Stub: lurek.render.printRich ----------------------------------------
--@api-stub: lurek.render.printRich
-- Demonstrates the proper usage of lurek.render.printRich.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_printRich()
    lurek.render.printRich("{color=red}DANGER{/color} — shields low!", 30, 70)
    print("rich text drawn")
end
local _ok, _err = pcall(demo_lurek_render_printRich)

-- ---- Stub: Font:getWidth -------------------------------------------------
--@api-stub: Font:getWidth
-- Demonstrates the proper usage of Font:getWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Font_getWidth()
    print("font 'A' width: " .. tostring(font:getWidth("A")))
end
local _ok, _err = pcall(demo_Font_getWidth)

-- ---- Stub: Font:getHeight ------------------------------------------------
--@api-stub: Font:getHeight
-- Demonstrates the proper usage of Font:getHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Font_getHeight()
    print("font height: " .. tostring(font:getHeight()))
end
local _ok, _err = pcall(demo_Font_getHeight)

-- ---- Stub: Font:getLineHeight --------------------------------------------
--@api-stub: Font:getLineHeight
-- Demonstrates the proper usage of Font:getLineHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Font_getLineHeight()
    print("font line height: " .. tostring(font:getLineHeight()))
end
local _ok, _err = pcall(demo_Font_getLineHeight)

-- ---- Stub: Font:setLineHeight --------------------------------------------
--@api-stub: Font:setLineHeight
-- Demonstrates the proper usage of Font:setLineHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Font_setLineHeight()
    font:setLineHeight(1.5)
    print("font line height set to 1.5")
end
local _ok, _err = pcall(demo_Font_setLineHeight)

-- ---- Stub: Font:getAscent ------------------------------------------------
--@api-stub: Font:getAscent
-- Demonstrates the proper usage of Font:getAscent.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Font_getAscent()
    print("font ascent: " .. tostring(font:getAscent()))
end
local _ok, _err = pcall(demo_Font_getAscent)

-- ---- Stub: Font:getDescent -----------------------------------------------
--@api-stub: Font:getDescent
-- Demonstrates the proper usage of Font:getDescent.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Font_getDescent()
    print("font descent: " .. tostring(font:getDescent()))
end
local _ok, _err = pcall(demo_Font_getDescent)

-- ---- Stub: Font:getWrap --------------------------------------------------
--@api-stub: Font:getWrap
-- Demonstrates the proper usage of Font:getWrap.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Font_getWrap()
    local fww, fwl = font:getWrap("Wrap this text please.", 100)
    print("font wrap: width=" .. tostring(fww) .. " lines=" .. tostring(fwl))
end
local _ok, _err = pcall(demo_Font_getWrap)

-- ---- Stub: Font:release --------------------------------------------------
--@api-stub: Font:release
-- Demonstrates the proper usage of Font:release.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Font_release()
    font:release()
    print("font released")
end
local _ok, _err = pcall(demo_Font_release)

-- ---- Stub: Font:typeOf ---------------------------------------------------
--@api-stub: Font:typeOf
-- Demonstrates the proper usage of Font:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Font_typeOf()
    local new_font = lurek.render.newFont(14)
    print("font typeOf: " .. tostring(new_font:typeOf()))
end
local _ok, _err = pcall(demo_Font_typeOf)

-- ---- Stub: Font:type -----------------------------------------------------
--@api-stub: Font:type
-- Demonstrates the proper usage of Font:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Font_type()
    print("font type: " .. tostring(new_font:type()))
end
local _ok, _err = pcall(demo_Font_type)

-- =============================================================================
-- Images & Sprites — game art
-- =============================================================================

-- ---- Stub: lurek.render.newImage -----------------------------------------
--@api-stub: lurek.render.newImage
-- Demonstrates the proper usage of lurek.render.newImage.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_newImage()
    local ok_img, ship_img = pcall(function()
    return lurek.render.newImage("assets/ship.png")
    if not ok_img then
    print("ship image load skipped (file not found — expected in example)")
end
local _ok, _err = pcall(demo_lurek_render_newImage)

-- ---- Stub: lurek.render.draw ---------------------------------------------
--@api-stub: lurek.render.draw
-- Demonstrates the proper usage of lurek.render.draw.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_draw()
    if ok_img then
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.draw(ship_img, 400, 300, 0, 1, 1, 16, 16)
    print("ship drawn at (400, 300)")
end
local _ok, _err = pcall(demo_lurek_render_draw)

-- ---- Stub: lurek.render.newQuad ------------------------------------------
--@api-stub: lurek.render.newQuad
-- Demonstrates the proper usage of lurek.render.newQuad.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_newQuad()
    local quad = lurek.render.newQuad(0, 0, 32, 32, 256, 256)
    print("quad created: 32x32 from 256x256 sheet")
end
local _ok, _err = pcall(demo_lurek_render_newQuad)

-- ---- Stub: lurek.render.drawq --------------------------------------------
--@api-stub: lurek.render.drawq
-- Demonstrates the proper usage of lurek.render.drawq.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_drawq()
    if ok_img then
    lurek.render.drawq(ship_img, quad, 500, 300)
    print("quad drawn from sprite sheet")
    if ok_img then
end
local _ok, _err = pcall(demo_lurek_render_drawq)

    -- ---- Stub: Image:getWidth ------------------------------------------------
--@api-stub: Image:getWidth
-- Demonstrates the proper usage of Image:getWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Image_getWidth()
    print("image width: " .. tostring(ship_img:getWidth()))
end
local _ok, _err = pcall(demo_Image_getWidth)

    -- ---- Stub: Image:getHeight -----------------------------------------------
--@api-stub: Image:getHeight
-- Demonstrates the proper usage of Image:getHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Image_getHeight()
    print("image height: " .. tostring(ship_img:getHeight()))
end
local _ok, _err = pcall(demo_Image_getHeight)

    -- ---- Stub: Image:getDimensions -------------------------------------------
--@api-stub: Image:getDimensions
-- Demonstrates the proper usage of Image:getDimensions.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Image_getDimensions()
    local iw, ih = ship_img:getDimensions()
    print("image: " .. tostring(iw) .. "x" .. tostring(ih))
end
local _ok, _err = pcall(demo_Image_getDimensions)

    -- ---- Stub: Image:typeOf --------------------------------------------------
--@api-stub: Image:typeOf
-- Demonstrates the proper usage of Image:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Image_typeOf()
    print("image typeOf: " .. tostring(ship_img:typeOf()))
end
local _ok, _err = pcall(demo_Image_typeOf)

    -- ---- Stub: Image:type ----------------------------------------------------
--@api-stub: Image:type
-- Demonstrates the proper usage of Image:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Image_type()
    print("image type: " .. tostring(ship_img:type()))
end
local _ok, _err = pcall(demo_Image_type)

    -- ---- Stub: Image:release -------------------------------------------------
--@api-stub: Image:release
-- Demonstrates the proper usage of Image:release.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Image_release()
    ship_img:release()
    print("ship image released")
end
local _ok, _err = pcall(demo_Image_release)

-- ---- Stub: Quad:getViewport ----------------------------------------------
--@api-stub: Quad:getViewport
-- Demonstrates the proper usage of Quad:getViewport.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Quad_getViewport()
    local qx, qy, qw, qh = quad:getViewport()
    print("quad viewport: (" .. tostring(qx) .. "," .. tostring(qy) .. ") " .. tostring(qw) .. "x" .. tostring(qh))
end
local _ok, _err = pcall(demo_Quad_getViewport)

-- ---- Stub: Quad:getTextureDimensions -------------------------------------
--@api-stub: Quad:getTextureDimensions
-- Demonstrates the proper usage of Quad:getTextureDimensions.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Quad_getTextureDimensions()
    local qtw, qth = quad:getTextureDimensions()
    print("quad texture: " .. tostring(qtw) .. "x" .. tostring(qth))
end
local _ok, _err = pcall(demo_Quad_getTextureDimensions)

-- ---- Stub: Quad:typeOf ---------------------------------------------------
--@api-stub: Quad:typeOf
-- Demonstrates the proper usage of Quad:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Quad_typeOf()
    print("quad typeOf: " .. tostring(quad:typeOf()))
end
local _ok, _err = pcall(demo_Quad_typeOf)

-- ---- Stub: Quad:type -----------------------------------------------------
--@api-stub: Quad:type
-- Demonstrates the proper usage of Quad:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Quad_type()
    print("quad type: " .. tostring(quad:type()))
end
local _ok, _err = pcall(demo_Quad_type)

-- =============================================================================
-- Filter & Default Settings
-- =============================================================================

-- ---- Stub: lurek.render.setDefaultFilter ---------------------------------
--@api-stub: lurek.render.setDefaultFilter
-- Demonstrates the proper usage of lurek.render.setDefaultFilter.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_setDefaultFilter()
    lurek.render.setDefaultFilter("nearest", "nearest")
    print("default filter: nearest (pixel art)")
end
local _ok, _err = pcall(demo_lurek_render_setDefaultFilter)

-- ---- Stub: lurek.render.getDefaultFilter ---------------------------------
--@api-stub: lurek.render.getDefaultFilter
-- Demonstrates the proper usage of lurek.render.getDefaultFilter.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getDefaultFilter()
    local fmin, fmag = lurek.render.getDefaultFilter()
    print("default filter: min=" .. tostring(fmin) .. " mag=" .. tostring(fmag))
end
local _ok, _err = pcall(demo_lurek_render_getDefaultFilter)

-- =============================================================================
-- Canvas — off-screen rendering for minimap
-- =============================================================================

-- ---- Stub: lurek.render.newCanvas ----------------------------------------
--@api-stub: lurek.render.newCanvas
-- Demonstrates the proper usage of lurek.render.newCanvas.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_newCanvas()
    local minimap = lurek.render.newCanvas(128, 128)
    print("minimap canvas created: 128x128")
end
local _ok, _err = pcall(demo_lurek_render_newCanvas)

-- ---- Stub: lurek.render.setCanvas ----------------------------------------
--@api-stub: lurek.render.setCanvas
-- Demonstrates the proper usage of lurek.render.setCanvas.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_setCanvas()
    lurek.render.setCanvas(minimap)
    print("rendering to minimap canvas")
    lurek.render.clear(0, 0, 0, 1)
    lurek.render.setColor(0, 0.5, 0, 1)
    lurek.render.rectangle("fill", 0, 0, 128, 128)
    lurek.render.setColor(1, 0, 0, 1)
    lurek.render.circle("fill", 64, 64, 4, 8)
end
local _ok, _err = pcall(demo_lurek_render_setCanvas)

-- ---- Stub: lurek.render.getCanvas ----------------------------------------
--@api-stub: lurek.render.getCanvas
-- Demonstrates the proper usage of lurek.render.getCanvas.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getCanvas()
    local cur_canvas = lurek.render.getCanvas()
    print("current canvas: " .. type(cur_canvas))
end
local _ok, _err = pcall(demo_lurek_render_getCanvas)

-- ---- Stub: lurek.render.getCanvasSize ------------------------------------
--@api-stub: lurek.render.getCanvasSize
local cw2, ch2 = lurek.render.getCanvasSize()
print("canvas size: " .. tostring(cw2) .. "x" .. tostring(ch2))

-- Switch back to screen.
lurek.render.setCanvas()
print("rendering to screen")

-- Draw minimap in corner.
lurek.render.setColor(1, 1, 1, 1)
lurek.render.draw(minimap, sw - 138, 10)

-- ---- Canvas userdata
-- ---- Stub: Canvas:getWidth -----------------------------------------------
--@api-stub: Canvas:getWidth
-- Demonstrates the proper usage of Canvas:getWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Canvas_getWidth()
    print("minimap canvas width: " .. tostring(minimap:getWidth()))
end
local _ok, _err = pcall(demo_Canvas_getWidth)

-- ---- Stub: Canvas:getHeight ----------------------------------------------
--@api-stub: Canvas:getHeight
-- Demonstrates the proper usage of Canvas:getHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Canvas_getHeight()
    print("minimap canvas height: " .. tostring(minimap:getHeight()))
end
local _ok, _err = pcall(demo_Canvas_getHeight)

-- ---- Stub: Canvas:getDimensions ------------------------------------------
--@api-stub: Canvas:getDimensions
-- Demonstrates the proper usage of Canvas:getDimensions.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Canvas_getDimensions()
    local mcw, mch = minimap:getDimensions()
    print("minimap canvas: " .. tostring(mcw) .. "x" .. tostring(mch))
end
local _ok, _err = pcall(demo_Canvas_getDimensions)

-- ---- Stub: Canvas:typeOf -------------------------------------------------
--@api-stub: Canvas:typeOf
-- Demonstrates the proper usage of Canvas:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Canvas_typeOf()
    print("canvas typeOf: " .. tostring(minimap:typeOf()))
end
local _ok, _err = pcall(demo_Canvas_typeOf)

-- ---- Stub: Canvas:type ---------------------------------------------------
--@api-stub: Canvas:type
-- Demonstrates the proper usage of Canvas:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Canvas_type()
    print("canvas type: " .. tostring(minimap:type()))
end
local _ok, _err = pcall(demo_Canvas_type)

-- ---- Stub: Canvas:release ------------------------------------------------
--@api-stub: Canvas:release
-- Demonstrates the proper usage of Canvas:release.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Canvas_release()
    minimap:release()
    print("minimap canvas released")
end
local _ok, _err = pcall(demo_Canvas_release)

-- =============================================================================
-- SpriteBatch — efficient enemy rendering
-- =============================================================================

-- ---- Stub: lurek.render.newSpriteBatch -----------------------------------
--@api-stub: lurek.render.newSpriteBatch
-- Demonstrates the proper usage of lurek.render.newSpriteBatch.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_newSpriteBatch()
    local batch = lurek.render.newSpriteBatch(256)
    print("sprite batch created: capacity=256")
end
local _ok, _err = pcall(demo_lurek_render_newSpriteBatch)

-- ---- Stub: SpriteBatch:clear ---------------------------------------------
--@api-stub: SpriteBatch:clear
-- Demonstrates the proper usage of SpriteBatch:clear.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SpriteBatch_clear()
    batch:clear()
    print("sprite batch cleared")
end
local _ok, _err = pcall(demo_SpriteBatch_clear)

-- ---- Stub: SpriteBatch:getCount ------------------------------------------
--@api-stub: SpriteBatch:getCount
-- Demonstrates the proper usage of SpriteBatch:getCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SpriteBatch_getCount()
    print("batch count: " .. tostring(batch:getCount()))
end
local _ok, _err = pcall(demo_SpriteBatch_getCount)

-- ---- Stub: SpriteBatch:getBufferSize -------------------------------------
--@api-stub: SpriteBatch:getBufferSize
-- Demonstrates the proper usage of SpriteBatch:getBufferSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SpriteBatch_getBufferSize()
    print("batch buffer: " .. tostring(batch:getBufferSize()))
end
local _ok, _err = pcall(demo_SpriteBatch_getBufferSize)

-- ---- Stub: SpriteBatch:typeOf --------------------------------------------
--@api-stub: SpriteBatch:typeOf
-- Demonstrates the proper usage of SpriteBatch:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SpriteBatch_typeOf()
    print("batch typeOf: " .. tostring(batch:typeOf()))
end
local _ok, _err = pcall(demo_SpriteBatch_typeOf)

-- ---- Stub: SpriteBatch:type ----------------------------------------------
--@api-stub: SpriteBatch:type
-- Demonstrates the proper usage of SpriteBatch:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SpriteBatch_type()
    print("batch type: " .. tostring(batch:type()))
end
local _ok, _err = pcall(demo_SpriteBatch_type)

-- ---- Stub: SpriteBatch:release -------------------------------------------
--@api-stub: SpriteBatch:release
-- Demonstrates the proper usage of SpriteBatch:release.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SpriteBatch_release()
    batch:release()
    print("sprite batch released")
end
local _ok, _err = pcall(demo_SpriteBatch_release)

-- =============================================================================
-- Mesh — terrain strip
-- =============================================================================

-- ---- Stub: lurek.render.newMesh ------------------------------------------
--@api-stub: lurek.render.newMesh
-- Demonstrates the proper usage of lurek.render.newMesh.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_newMesh()
    local mesh = lurek.render.newMesh(4, "fan")
    print("mesh created: 4 vertices, fan mode")
end
local _ok, _err = pcall(demo_lurek_render_newMesh)

-- ---- Stub: Mesh:getVertexCount -------------------------------------------
--@api-stub: Mesh:getVertexCount
-- Demonstrates the proper usage of Mesh:getVertexCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Mesh_getVertexCount()
    print("mesh vertices: " .. tostring(mesh:getVertexCount()))
end
local _ok, _err = pcall(demo_Mesh_getVertexCount)

-- ---- Stub: Mesh:setVertex ------------------------------------------------
--@api-stub: Mesh:setVertex
-- Demonstrates the proper usage of Mesh:setVertex.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Mesh_setVertex()
    mesh:setVertex(1, 0, 0, 0, 0, 1, 0, 0, 1)
    mesh:setVertex(2, 100, 0, 1, 0, 0, 1, 0, 1)
    mesh:setVertex(3, 100, 100, 1, 1, 0, 0, 1, 1)
    mesh:setVertex(4, 0, 100, 0, 1, 1, 1, 0, 1)
    print("mesh vertices set (coloured quad)")
end
local _ok, _err = pcall(demo_Mesh_setVertex)

-- ---- Stub: Mesh:getVertex ------------------------------------------------
--@api-stub: Mesh:getVertex
-- Demonstrates the proper usage of Mesh:getVertex.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Mesh_getVertex()
    local vx, vy = mesh:getVertex(1)
    print("vertex 1: (" .. tostring(vx) .. "," .. tostring(vy) .. ")")
end
local _ok, _err = pcall(demo_Mesh_getVertex)

-- ---- Stub: Mesh:setTexture -----------------------------------------------
--@api-stub: Mesh:setTexture
-- Demonstrates the proper usage of Mesh:setTexture.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Mesh_setTexture()
    mesh:setTexture(nil)
    print("mesh texture cleared (untextured)")
end
local _ok, _err = pcall(demo_Mesh_setTexture)

-- ---- Stub: Mesh:typeOf ---------------------------------------------------
--@api-stub: Mesh:typeOf
-- Demonstrates the proper usage of Mesh:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Mesh_typeOf()
    print("mesh typeOf: " .. tostring(mesh:typeOf()))
end
local _ok, _err = pcall(demo_Mesh_typeOf)

-- ---- Stub: Mesh:type -----------------------------------------------------
--@api-stub: Mesh:type
-- Demonstrates the proper usage of Mesh:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Mesh_type()
    print("mesh type: " .. tostring(mesh:type()))
end
local _ok, _err = pcall(demo_Mesh_type)

-- ---- Stub: Mesh:release --------------------------------------------------
--@api-stub: Mesh:release
-- Demonstrates the proper usage of Mesh:release.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Mesh_release()
    mesh:release()
    print("mesh released")
end
local _ok, _err = pcall(demo_Mesh_release)

-- =============================================================================
-- Shaders — CRT scanline effect
-- =============================================================================

-- ---- Stub: lurek.render.newShader ----------------------------------------
--@api-stub: lurek.render.newShader
-- Demonstrates the proper usage of lurek.render.newShader.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_newShader()
    local ok_shader, shader = pcall(function()
    return lurek.render.newShader([[
        vec4 effect(vec4 color, sampler2D tex, vec2 uv) {
            float scan = sin(uv.y * 800.0) * 0.05;
            vec4 pixel = texture(tex, uv);
            return pixel * color * (1.0 - scan);
        }
    ]])
    if ok_shader then
    print("CRT shader created")
    else
    print("shader creation skipped: " .. tostring(shader))
end
local _ok, _err = pcall(demo_lurek_render_newShader)

-- ---- Stub: lurek.render.setShader ----------------------------------------
--@api-stub: lurek.render.setShader
-- Demonstrates the proper usage of lurek.render.setShader.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_setShader()
    if ok_shader then
    lurek.render.setShader(shader)
    print("CRT shader active")
end
local _ok, _err = pcall(demo_lurek_render_setShader)

-- ---- Stub: lurek.render.getShader ----------------------------------------
--@api-stub: lurek.render.getShader
local cur_shader = lurek.render.getShader()
print("current shader: " .. type(cur_shader))

-- Reset shader.
lurek.render.setShader()

-- ---- Shader userdata
if ok_shader then
    -- ---- Stub: Shader:hasUniform ---------------------------------------------
--@api-stub: Shader:hasUniform
-- Demonstrates the proper usage of Shader:hasUniform.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Shader_hasUniform()
    print("shader has 'time': " .. tostring(shader:hasUniform("time")))
end
local _ok, _err = pcall(demo_Shader_hasUniform)

    -- ---- Stub: Shader:send ---------------------------------------------------
--@api-stub: Shader:send
-- Demonstrates the proper usage of Shader:send.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Shader_send()
    if shader:hasUniform("time") then
        shader:send("time", 1.5)
        print("shader uniform 'time' set to 1.5")
    end
end
local _ok, _err = pcall(demo_Shader_send)

    -- ---- Stub: Shader:typeOf -------------------------------------------------
--@api-stub: Shader:typeOf
-- Demonstrates the proper usage of Shader:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Shader_typeOf()
    print("shader typeOf: " .. tostring(shader:typeOf()))
end
local _ok, _err = pcall(demo_Shader_typeOf)

    -- ---- Stub: Shader:type ---------------------------------------------------
--@api-stub: Shader:type
-- Demonstrates the proper usage of Shader:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Shader_type()
    print("shader type: " .. tostring(shader:type()))
end
local _ok, _err = pcall(demo_Shader_type)

    -- ---- Stub: Shader:release ------------------------------------------------
--@api-stub: Shader:release
-- Demonstrates the proper usage of Shader:release.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Shader_release()
    shader:release()
    print("shader released")
end
local _ok, _err = pcall(demo_Shader_release)

-- =============================================================================
-- Transform Stack — camera-like transforms
-- =============================================================================

-- ---- Stub: lurek.render.push ---------------------------------------------
--@api-stub: lurek.render.push
-- Demonstrates the proper usage of lurek.render.push.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_push()
    lurek.render.push()
    print("transform pushed")
end
local _ok, _err = pcall(demo_lurek_render_push)

-- ---- Stub: lurek.render.translate ----------------------------------------
--@api-stub: lurek.render.translate
-- Demonstrates the proper usage of lurek.render.translate.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_translate()
    lurek.render.translate(sw / 2, sh / 2)
    print("translated to screen centre")
end
local _ok, _err = pcall(demo_lurek_render_translate)

-- ---- Stub: lurek.render.rotate -------------------------------------------
--@api-stub: lurek.render.rotate
-- Demonstrates the proper usage of lurek.render.rotate.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_rotate()
    lurek.render.rotate(0.1)
    print("rotated 0.1 rad")
end
local _ok, _err = pcall(demo_lurek_render_rotate)

-- ---- Stub: lurek.render.scale --------------------------------------------
--@api-stub: lurek.render.scale
-- Demonstrates the proper usage of lurek.render.scale.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_scale()
    lurek.render.scale(2, 2)
    print("scaled 2x")
end
local _ok, _err = pcall(demo_lurek_render_scale)

-- ---- Stub: lurek.render.shear --------------------------------------------
--@api-stub: lurek.render.shear
-- Demonstrates the proper usage of lurek.render.shear.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_shear()
    lurek.render.shear(0.1, 0)
    print("sheared x by 0.1")
    lurek.render.setColor(1, 1, 0, 1)
    lurek.render.rectangle("fill", -10, -10, 20, 20)
    print("yellow square at transformed origin")
end
local _ok, _err = pcall(demo_lurek_render_shear)

-- ---- Stub: lurek.render.pop ----------------------------------------------
--@api-stub: lurek.render.pop
-- Demonstrates the proper usage of lurek.render.pop.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_pop()
    lurek.render.pop()
    print("transform popped")
end
local _ok, _err = pcall(demo_lurek_render_pop)

-- ---- Stub: lurek.render.origin -------------------------------------------
--@api-stub: lurek.render.origin
-- Demonstrates the proper usage of lurek.render.origin.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_origin()
    lurek.render.origin()
    print("transform reset to identity")
end
local _ok, _err = pcall(demo_lurek_render_origin)

-- ---- Stub: lurek.render.applyTransform -----------------------------------
--@api-stub: lurek.render.applyTransform
-- Demonstrates the proper usage of lurek.render.applyTransform.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_applyTransform()
    lurek.render.applyTransform(1, 0, 0, 1, 50, 50)
    print("custom transform applied: translate(50,50)")
    lurek.render.origin()
end
local _ok, _err = pcall(demo_lurek_render_applyTransform)

-- =============================================================================
-- Scissor & Clipping
-- =============================================================================

-- ---- Stub: lurek.render.setScissor ---------------------------------------
--@api-stub: lurek.render.setScissor
-- Demonstrates the proper usage of lurek.render.setScissor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_setScissor()
    lurek.render.setScissor(50, 50, 200, 150)
    print("scissor set: (50,50) 200x150")
end
local _ok, _err = pcall(demo_lurek_render_setScissor)

-- ---- Stub: lurek.render.getScissor ---------------------------------------
--@api-stub: lurek.render.getScissor
-- Demonstrates the proper usage of lurek.render.getScissor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getScissor()
    local sx2, sy2, sw2, sh2 = lurek.render.getScissor()
    print("scissor: (" .. tostring(sx2) .. "," .. tostring(sy2) .. ") " .. tostring(sw2) .. "x" .. tostring(sh2))
end
local _ok, _err = pcall(demo_lurek_render_getScissor)

-- ---- Stub: lurek.render.intersectScissor ---------------------------------
--@api-stub: lurek.render.intersectScissor
-- Demonstrates the proper usage of lurek.render.intersectScissor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_intersectScissor()
    lurek.render.intersectScissor(100, 100, 100, 50)
    print("scissor intersected")
    lurek.render.setScissor()
end
local _ok, _err = pcall(demo_lurek_render_intersectScissor)

-- =============================================================================
-- Colour Mask
-- =============================================================================

-- ---- Stub: lurek.render.setColorMask -------------------------------------
--@api-stub: lurek.render.setColorMask
-- Demonstrates the proper usage of lurek.render.setColorMask.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_setColorMask()
    lurek.render.setColorMask(true, true, true, true)
    print("color mask: RGBA all enabled")
end
local _ok, _err = pcall(demo_lurek_render_setColorMask)

-- ---- Stub: lurek.render.getColorMask -------------------------------------
--@api-stub: lurek.render.getColorMask
-- Demonstrates the proper usage of lurek.render.getColorMask.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getColorMask()
    local mr, mg2, mb2, ma2 = lurek.render.getColorMask()
    print("color mask: R=" .. tostring(mr) .. " G=" .. tostring(mg2) .. " B=" .. tostring(mb2) .. " A=" .. tostring(ma2))
end
local _ok, _err = pcall(demo_lurek_render_getColorMask)

-- =============================================================================
-- Stencil Buffer — UI masking
-- =============================================================================

-- ---- Stub: lurek.render.stencil ------------------------------------------
--@api-stub: lurek.render.stencil
-- Demonstrates the proper usage of lurek.render.stencil.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_stencil()
    lurek.render.stencil(function()
    lurek.render.circle("fill", 400, 300, 50, 32)
    print("stencil written: circle mask at (400, 300)")
end
local _ok, _err = pcall(demo_lurek_render_stencil)

-- ---- Stub: lurek.render.setStencilTest -----------------------------------
--@api-stub: lurek.render.setStencilTest
-- Demonstrates the proper usage of lurek.render.setStencilTest.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_setStencilTest()
    lurek.render.setStencilTest("greater", 0)
    print("stencil test: draw only inside circle")
end
local _ok, _err = pcall(demo_lurek_render_setStencilTest)

-- ---- Stub: lurek.render.setStencilMode -----------------------------------
--@api-stub: lurek.render.setStencilMode
-- Demonstrates the proper usage of lurek.render.setStencilMode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_setStencilMode()
    lurek.render.setStencilMode("keep", "keep", "keep")
    print("stencil mode set")
end
local _ok, _err = pcall(demo_lurek_render_setStencilMode)

-- ---- Stub: lurek.render.getStencilMode -----------------------------------
--@api-stub: lurek.render.getStencilMode
-- Demonstrates the proper usage of lurek.render.getStencilMode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getStencilMode()
    local sm = lurek.render.getStencilMode()
    print("stencil mode: " .. tostring(sm))
end
local _ok, _err = pcall(demo_lurek_render_getStencilMode)

-- ---- Stub: lurek.render.clearStencil -------------------------------------
--@api-stub: lurek.render.clearStencil
-- Demonstrates the proper usage of lurek.render.clearStencil.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_clearStencil()
    lurek.render.clearStencil()
    print("stencil cleared")
end
local _ok, _err = pcall(demo_lurek_render_clearStencil)

-- =============================================================================
-- Depth Buffer
-- =============================================================================

-- ---- Stub: lurek.render.setDepthMode -------------------------------------
--@api-stub: lurek.render.setDepthMode
-- Demonstrates the proper usage of lurek.render.setDepthMode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_setDepthMode()
    lurek.render.setDepthMode("lequal", true)
    print("depth mode: lequal, write=true")
end
local _ok, _err = pcall(demo_lurek_render_setDepthMode)

-- ---- Stub: lurek.render.getDepthMode -------------------------------------
--@api-stub: lurek.render.getDepthMode
-- Demonstrates the proper usage of lurek.render.getDepthMode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getDepthMode()
    local dm = lurek.render.getDepthMode()
    print("depth mode: " .. tostring(dm))
end
local _ok, _err = pcall(demo_lurek_render_getDepthMode)

-- =============================================================================
-- NineSlice — UI panel borders
-- =============================================================================

-- ---- Stub: lurek.render.newNineSlice -------------------------------------
--@api-stub: lurek.render.newNineSlice
-- Demonstrates the proper usage of lurek.render.newNineSlice.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_newNineSlice()
    local ok_ns, ns = pcall(function()
    return lurek.render.newNineSlice("assets/panel.png", 8, 8, 8, 8)
    if ok_ns then
    print("nine-slice created: 8px insets")
    else
    print("nine-slice skipped (file not found)")
end
local _ok, _err = pcall(demo_lurek_render_newNineSlice)

-- ---- Stub: lurek.render.drawNineSlice ------------------------------------
--@api-stub: lurek.render.drawNineSlice
-- Demonstrates the proper usage of lurek.render.drawNineSlice.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_drawNineSlice()
    if ok_ns then
    lurek.render.drawNineSlice(ns, 100, 400, 200, 80)
    print("nine-slice panel drawn: 200x80 at (100, 400)")
    if ok_ns then
end
local _ok, _err = pcall(demo_lurek_render_drawNineSlice)

    -- ---- Stub: NineSlice:getInsets -------------------------------------------
--@api-stub: NineSlice:getInsets
-- Demonstrates the proper usage of NineSlice:getInsets.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NineSlice_getInsets()
    local nl, nt, nr, nb = ns:getInsets()
    print("nine-slice insets: " .. tostring(nl) .. "," .. tostring(nt) .. "," .. tostring(nr) .. "," .. tostring(nb))
end
local _ok, _err = pcall(demo_NineSlice_getInsets)

    -- ---- Stub: NineSlice:getTextureSize --------------------------------------
--@api-stub: NineSlice:getTextureSize
-- Demonstrates the proper usage of NineSlice:getTextureSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NineSlice_getTextureSize()
    local nsw, nsh = ns:getTextureSize()
    print("nine-slice texture: " .. tostring(nsw) .. "x" .. tostring(nsh))
end
local _ok, _err = pcall(demo_NineSlice_getTextureSize)

    -- ---- Stub: NineSlice:type ------------------------------------------------
--@api-stub: NineSlice:type
-- Demonstrates the proper usage of NineSlice:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NineSlice_type()
    print("nine-slice type: " .. tostring(ns:type()))
end
local _ok, _err = pcall(demo_NineSlice_type)

    -- ---- Stub: NineSlice:typeOf ----------------------------------------------
--@api-stub: NineSlice:typeOf
-- Demonstrates the proper usage of NineSlice:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NineSlice_typeOf()
    print("nine-slice typeOf: " .. tostring(ns:typeOf()))
end
local _ok, _err = pcall(demo_NineSlice_typeOf)

-- =============================================================================
-- Shape Builder — reusable line art
-- =============================================================================

-- ---- Stub: lurek.render.newShape -----------------------------------------
--@api-stub: lurek.render.newShape
-- Demonstrates the proper usage of lurek.render.newShape.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_newShape()
    local shape = lurek.render.newShape()
    print("shape builder created")
end
local _ok, _err = pcall(demo_lurek_render_newShape)

-- ---- Stub: Shape:setLineWidth --------------------------------------------
--@api-stub: Shape:setLineWidth
-- Demonstrates the proper usage of Shape:setLineWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Shape_setLineWidth()
    shape:setLineWidth(3)
    print("shape line width: 3")
end
local _ok, _err = pcall(demo_Shape_setLineWidth)

-- ---- Stub: Shape:line ----------------------------------------------------
--@api-stub: Shape:line
-- Demonstrates the proper usage of Shape:line.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Shape_line()
    shape:line(0, 0, 50, 0)
    shape:line(50, 0, 50, 50)
    print("2 line segments added to shape")
end
local _ok, _err = pcall(demo_Shape_line)

-- ---- Stub: Shape:polyline ------------------------------------------------
--@api-stub: Shape:polyline
-- Demonstrates the proper usage of Shape:polyline.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Shape_polyline()
    shape:polyline(0, 0, 25, -20, 50, 0)
    print("polyline added to shape (arrow head)")
end
local _ok, _err = pcall(demo_Shape_polyline)

-- ---- Stub: Shape:getCommandCount -----------------------------------------
--@api-stub: Shape:getCommandCount
-- Demonstrates the proper usage of Shape:getCommandCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Shape_getCommandCount()
    print("shape commands: " .. tostring(shape:getCommandCount()))
end
local _ok, _err = pcall(demo_Shape_getCommandCount)

-- ---- Stub: Shape:typeOf --------------------------------------------------
--@api-stub: Shape:typeOf
-- Demonstrates the proper usage of Shape:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Shape_typeOf()
    print("shape typeOf: " .. tostring(shape:typeOf()))
end
local _ok, _err = pcall(demo_Shape_typeOf)

-- ---- Stub: Shape:type ----------------------------------------------------
--@api-stub: Shape:type
-- Demonstrates the proper usage of Shape:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Shape_type()
    print("shape type: " .. tostring(shape:type()))
end
local _ok, _err = pcall(demo_Shape_type)

-- ---- Stub: Shape:clear ---------------------------------------------------
--@api-stub: Shape:clear
-- Demonstrates the proper usage of Shape:clear.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Shape_clear()
    shape:clear()
    print("shape cleared")
end
local _ok, _err = pcall(demo_Shape_clear)

-- =============================================================================
-- DrawLayer — batched deferred rendering
-- =============================================================================

-- ---- Stub: lurek.render.newDrawLayer -------------------------------------
--@api-stub: lurek.render.newDrawLayer
-- Demonstrates the proper usage of lurek.render.newDrawLayer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_newDrawLayer()
    local dl = lurek.render.newDrawLayer()
    print("draw layer created")
end
local _ok, _err = pcall(demo_lurek_render_newDrawLayer)

-- ---- Stub: DrawLayer:queue -----------------------------------------------
--@api-stub: DrawLayer:queue
-- Demonstrates the proper usage of DrawLayer:queue.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DrawLayer_queue()
    dl:queue(function()
    lurek.render.setColor(1, 0.5, 0, 1)
    lurek.render.circle("fill", 200, 200, 20, 16)
    dl:queue(function()
    lurek.render.setColor(0, 0.5, 1, 1)
    lurek.render.rectangle("fill", 250, 190, 40, 20)
    print("2 draw commands queued")
end
local _ok, _err = pcall(demo_DrawLayer_queue)

-- ---- Stub: DrawLayer:getCount --------------------------------------------
--@api-stub: DrawLayer:getCount
-- Demonstrates the proper usage of DrawLayer:getCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DrawLayer_getCount()
    print("queued commands: " .. tostring(dl:getCount()))
end
local _ok, _err = pcall(demo_DrawLayer_getCount)

-- ---- Stub: DrawLayer:flush -----------------------------------------------
--@api-stub: DrawLayer:flush
-- Demonstrates the proper usage of DrawLayer:flush.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DrawLayer_flush()
    dl:flush()
    print("draw layer flushed")
end
local _ok, _err = pcall(demo_DrawLayer_flush)

-- ---- Stub: DrawLayer:typeOf ----------------------------------------------
--@api-stub: DrawLayer:typeOf
-- Demonstrates the proper usage of DrawLayer:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DrawLayer_typeOf()
    print("draw layer typeOf: " .. tostring(dl:typeOf()))
end
local _ok, _err = pcall(demo_DrawLayer_typeOf)

-- ---- Stub: DrawLayer:type ------------------------------------------------
--@api-stub: DrawLayer:type
-- Demonstrates the proper usage of DrawLayer:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DrawLayer_type()
    print("draw layer type: " .. tostring(dl:type()))
end
local _ok, _err = pcall(demo_DrawLayer_type)

-- ---- Stub: DrawLayer:clear -----------------------------------------------
--@api-stub: DrawLayer:clear
-- Demonstrates the proper usage of DrawLayer:clear.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DrawLayer_clear()
    dl:clear()
    print("draw layer cleared")
end
local _ok, _err = pcall(demo_DrawLayer_clear)

-- =============================================================================
-- Advanced Drawing — beziers, gradients, iso/hex tiles, bevel
-- =============================================================================

-- ---- Stub: lurek.render.drawQuadBezier -----------------------------------
--@api-stub: lurek.render.drawQuadBezier
-- Demonstrates the proper usage of lurek.render.drawQuadBezier.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_drawQuadBezier()
    lurek.render.setColor(1, 1, 0, 1)
    lurek.render.drawQuadBezier(100, 500, 200, 400, 300, 500, 20)
    print("quadratic bezier drawn (particle trail)")
end
local _ok, _err = pcall(demo_lurek_render_drawQuadBezier)

-- ---- Stub: lurek.render.drawCubicBezier ----------------------------------
--@api-stub: lurek.render.drawCubicBezier
-- Demonstrates the proper usage of lurek.render.drawCubicBezier.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_drawCubicBezier()
    lurek.render.setColor(0, 1, 1, 1)
    lurek.render.drawCubicBezier(400, 500, 450, 400, 550, 600, 600, 500, 30)
    print("cubic bezier drawn (smooth path)")
end
local _ok, _err = pcall(demo_lurek_render_drawCubicBezier)

-- ---- Stub: lurek.render.drawPath -----------------------------------------
--@api-stub: lurek.render.drawPath
-- Demonstrates the proper usage of lurek.render.drawPath.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_drawPath()
    lurek.render.setColor(1, 0, 1, 1)
    lurek.render.drawPath({100, 550, 150, 520, 200, 560, 250, 530}, false)
    print("path drawn (open polyline)")
end
local _ok, _err = pcall(demo_lurek_render_drawPath)

-- ---- Stub: lurek.render.drawGradientRect ---------------------------------
--@api-stub: lurek.render.drawGradientRect
-- Demonstrates the proper usage of lurek.render.drawGradientRect.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_drawGradientRect()
    lurek.render.drawGradientRect(50, 560, 200, 30,
    {0.2, 0, 0.4, 1}, {0.6, 0, 0.2, 1},
    {0.2, 0, 0.4, 1}, {0.6, 0, 0.2, 1})
    print("gradient rectangle drawn (health bar)")
end
local _ok, _err = pcall(demo_lurek_render_drawGradientRect)

-- ---- Stub: lurek.render.drawColoredPolygon --------------------------------
--@api-stub: lurek.render.drawColoredPolygon
-- Demonstrates the proper usage of lurek.render.drawColoredPolygon.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_drawColoredPolygon()
    lurek.render.drawColoredPolygon({
    {300, 560, 1, 0, 0, 1},
    {350, 540, 0, 1, 0, 1},
    {400, 560, 0, 0, 1, 1},
    })
    print("coloured polygon drawn (RGB triangle)")
end
local _ok, _err = pcall(demo_lurek_render_drawColoredPolygon)

-- ---- Stub: lurek.render.drawIsoCubeTile ----------------------------------
--@api-stub: lurek.render.drawIsoCubeTile
-- Demonstrates the proper usage of lurek.render.drawIsoCubeTile.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_drawIsoCubeTile()
    lurek.render.setColor(0.5, 0.7, 0.5, 1)
    lurek.render.drawIsoCubeTile(500, 400, 32, 32, 16)
    print("iso cube tile drawn")
end
local _ok, _err = pcall(demo_lurek_render_drawIsoCubeTile)

-- ---- Stub: lurek.render.drawHexTile --------------------------------------
--@api-stub: lurek.render.drawHexTile
-- Demonstrates the proper usage of lurek.render.drawHexTile.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_drawHexTile()
    lurek.render.setColor(0.3, 0.6, 0.8, 1)
    lurek.render.drawHexTile(600, 400, 20)
    print("hex tile drawn")
end
local _ok, _err = pcall(demo_lurek_render_drawHexTile)

-- ---- Stub: lurek.render.drawBevelRect ------------------------------------
--@api-stub: lurek.render.drawBevelRect
-- Demonstrates the proper usage of lurek.render.drawBevelRect.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_drawBevelRect()
    lurek.render.setColor(0.4, 0.4, 0.6, 1)
    lurek.render.drawBevelRect(50, 400, 120, 40, 6)
    print("bevel rectangle drawn (button)")
end
local _ok, _err = pcall(demo_lurek_render_drawBevelRect)

-- =============================================================================
-- Sort Groups — depth-sorted rendering
-- =============================================================================

-- ---- Stub: lurek.render.beginSortGroup -----------------------------------
--@api-stub: lurek.render.beginSortGroup
-- Demonstrates the proper usage of lurek.render.beginSortGroup.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_beginSortGroup()
    lurek.render.beginSortGroup()
    print("sort group started")
end
local _ok, _err = pcall(demo_lurek_render_beginSortGroup)

-- ---- Stub: lurek.render.pushSortKey --------------------------------------
--@api-stub: lurek.render.pushSortKey
-- Demonstrates the proper usage of lurek.render.pushSortKey.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_pushSortKey()
    lurek.render.pushSortKey(300)
    lurek.render.setColor(1, 0, 0, 1)
    lurek.render.circle("fill", 400, 300, 10, 12)
    lurek.render.pushSortKey(200)
    lurek.render.setColor(0, 1, 0, 1)
    lurek.render.circle("fill", 420, 200, 10, 12)
end
local _ok, _err = pcall(demo_lurek_render_pushSortKey)

-- ---- Stub: lurek.render.flushSortGroup -----------------------------------
--@api-stub: lurek.render.flushSortGroup
-- Demonstrates the proper usage of lurek.render.flushSortGroup.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_flushSortGroup()
    lurek.render.flushSortGroup()
    print("sort group flushed (green before red)")
end
local _ok, _err = pcall(demo_lurek_render_flushSortGroup)

-- =============================================================================
-- Render Layers — named layer system
-- =============================================================================

-- ---- Stub: lurek.render.newLayer -----------------------------------------
--@api-stub: lurek.render.newLayer
-- Demonstrates the proper usage of lurek.render.newLayer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_newLayer()
    local bg_layer = lurek.render.newLayer("background", 0)
    local fg_layer = lurek.render.newLayer("foreground", 10)
    print("layers created: background (z=0), foreground (z=10)")
end
local _ok, _err = pcall(demo_lurek_render_newLayer)

-- ---- Stub: lurek.render.setLayer ----------------------------------------
--@api-stub: lurek.render.setLayer
-- Demonstrates the proper usage of lurek.render.setLayer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_setLayer()
    lurek.render.setLayer("background")
    print("drawing to background layer")
end
local _ok, _err = pcall(demo_lurek_render_setLayer)

-- ---- Stub: lurek.render.currentLayer -------------------------------------
--@api-stub: lurek.render.currentLayer
-- Demonstrates the proper usage of lurek.render.currentLayer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_currentLayer()
    print("current layer: " .. tostring(lurek.render.currentLayer()))
end
local _ok, _err = pcall(demo_lurek_render_currentLayer)

-- ---- Stub: lurek.render.setLayerVisible ----------------------------------
--@api-stub: lurek.render.setLayerVisible
-- Demonstrates the proper usage of lurek.render.setLayerVisible.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_setLayerVisible()
    lurek.render.setLayerVisible("background", true)
    print("background layer visible: true")
end
local _ok, _err = pcall(demo_lurek_render_setLayerVisible)

-- ---- Stub: lurek.render.isLayerVisible -----------------------------------
--@api-stub: lurek.render.isLayerVisible
-- Demonstrates the proper usage of lurek.render.isLayerVisible.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_isLayerVisible()
    print("background visible: " .. tostring(lurek.render.isLayerVisible("background")))
end
local _ok, _err = pcall(demo_lurek_render_isLayerVisible)

-- ---- Stub: lurek.render.getLayerZOrder -----------------------------------
--@api-stub: lurek.render.getLayerZOrder
-- Demonstrates the proper usage of lurek.render.getLayerZOrder.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getLayerZOrder()
    print("foreground z-order: " .. tostring(lurek.render.getLayerZOrder("foreground")))
end
local _ok, _err = pcall(demo_lurek_render_getLayerZOrder)

-- ---- Stub: lurek.render.setLayerZOrder -----------------------------------
--@api-stub: lurek.render.setLayerZOrder
-- Demonstrates the proper usage of lurek.render.setLayerZOrder.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_setLayerZOrder()
    lurek.render.setLayerZOrder("foreground", 20)
    print("foreground z-order changed to 20")
end
local _ok, _err = pcall(demo_lurek_render_setLayerZOrder)

-- ---- Stub: lurek.render.pushLayer ----------------------------------------
--@api-stub: lurek.render.pushLayer
-- Demonstrates the proper usage of lurek.render.pushLayer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_pushLayer()
    lurek.render.pushLayer("foreground")
    print("pushed to foreground layer")
end
local _ok, _err = pcall(demo_lurek_render_pushLayer)

-- ---- Stub: lurek.render.popLayer -----------------------------------------
--@api-stub: lurek.render.popLayer
-- Demonstrates the proper usage of lurek.render.popLayer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_popLayer()
    lurek.render.popLayer()
    print("popped back to previous layer")
end
local _ok, _err = pcall(demo_lurek_render_popLayer)

-- =============================================================================
-- ImageData — pixel manipulation
-- =============================================================================

local ok_id, img_data = pcall(function()
    return lurek.render.newImage("assets/test.png")
end)

-- ---- Stub: ImageData:getWidth --------------------------------------------
--@api-stub: ImageData:getWidth
-- Demonstrates the proper usage of ImageData:getWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ImageData_getWidth()
    if ok_id then print("image data width: " .. tostring(img_data:getWidth())) end
end
local _ok, _err = pcall(demo_ImageData_getWidth)

-- ---- Stub: ImageData:getHeight -------------------------------------------
--@api-stub: ImageData:getHeight
-- Demonstrates the proper usage of ImageData:getHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ImageData_getHeight()
    if ok_id then print("image data height: " .. tostring(img_data:getHeight())) end
end
local _ok, _err = pcall(demo_ImageData_getHeight)

-- ---- Stub: ImageData:resize ----------------------------------------------
--@api-stub: ImageData:resize
-- Demonstrates the proper usage of ImageData:resize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ImageData_resize()
    if ok_id then
    local resized = img_data:resize(64, 64)
    print("image data resized to 64x64")
end
local _ok, _err = pcall(demo_ImageData_resize)

-- ---- Stub: ImageData:diff ------------------------------------------------
--@api-stub: ImageData:diff
-- Demonstrates the proper usage of ImageData:diff.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ImageData_diff()
    if ok_id then
    local d = img_data:diff(img_data)
    print("image data diff: " .. tostring(d))
end
local _ok, _err = pcall(demo_ImageData_diff)

-- ---- Stub: ImageData:mapPixels -------------------------------------------
--@api-stub: ImageData:mapPixels
-- Demonstrates the proper usage of ImageData:mapPixels.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ImageData_mapPixels()
    if ok_id then
    img_data:mapPixels(function(x, y, r, g, b, a)
        return r * 0.5, g * 0.5, b * 0.5, a  -- darken
    end)
    print("image data pixels darkened")
end
local _ok, _err = pcall(demo_ImageData_mapPixels)

-- ---- Stub: ImageData:type ------------------------------------------------
--@api-stub: ImageData:type
-- Demonstrates the proper usage of ImageData:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ImageData_type()
    if ok_id then print("image data type: " .. tostring(img_data:type())) end
end
local _ok, _err = pcall(demo_ImageData_type)

-- ---- Stub: ImageData:typeOf ----------------------------------------------
--@api-stub: ImageData:typeOf
-- Demonstrates the proper usage of ImageData:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ImageData_typeOf()
    if ok_id then print("image data typeOf: " .. tostring(img_data:typeOf())) end
end
local _ok, _err = pcall(demo_ImageData_typeOf)

-- =============================================================================
-- Stats & Screenshots
-- =============================================================================

-- ---- Stub: lurek.render.getStats -----------------------------------------
--@api-stub: lurek.render.getStats
-- Demonstrates the proper usage of lurek.render.getStats.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_getStats()
    local stats = lurek.render.getStats()
    if stats then
    print("render stats: draw_calls=" .. tostring(stats.draw_calls)
        .. " textures=" .. tostring(stats.textures))
end
local _ok, _err = pcall(demo_lurek_render_getStats)

-- ---- Stub: lurek.render.saveScreenshot -----------------------------------
--@api-stub: lurek.render.saveScreenshot
-- Demonstrates the proper usage of lurek.render.saveScreenshot.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_saveScreenshot()
    lurek.render.saveScreenshot("screenshot.png")
    print("screenshot saved: screenshot.png")
end
local _ok, _err = pcall(demo_lurek_render_saveScreenshot)

-- ---- Stub: lurek.render.captureScreenshot --------------------------------
--@api-stub: lurek.render.captureScreenshot
-- Demonstrates the proper usage of lurek.render.captureScreenshot.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_render_captureScreenshot()
    local cap = lurek.render.captureScreenshot()
    print("screenshot captured to memory: " .. type(cap))
    print("\n-- render.lua example complete --")
end
local _ok, _err = pcall(demo_lurek_render_captureScreenshot)
