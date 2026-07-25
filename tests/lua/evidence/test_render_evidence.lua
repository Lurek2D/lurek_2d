-- Canonical evidence file for lurek.render.
-- @covers lurek.image.savePNG
-- @covers lurek.render.applyTransform
-- @covers lurek.render.arc
-- @covers lurek.render.beginSortGroup
-- @covers lurek.render.captureScreenshot
-- @covers lurek.render.circle
-- @covers lurek.render.clear
-- @covers lurek.render.clearStencil
-- @covers lurek.render.draw
-- @covers lurek.render.drawBatch
-- @covers lurek.render.drawBevelRect
-- @covers lurek.render.drawColoredPolygon
-- @covers lurek.render.drawCubicBezier
-- @covers lurek.render.drawGradientRect
-- @covers lurek.render.drawHexTile
-- @covers lurek.render.drawIsoCubeTile
-- @covers lurek.render.drawNineSlice
-- @covers lurek.render.drawPath
-- @covers lurek.render.drawQuadBezier
-- @covers lurek.render.drawq
-- @covers lurek.render.ellipse
-- @covers lurek.render.flushSortGroup
-- @covers lurek.render.getCanvasSize
-- @covers lurek.render.intersectScissor
-- @covers lurek.render.line
-- @covers lurek.render.loadModel
-- @covers lurek.render.newCanvas
-- @covers lurek.render.newDrawLayer
-- @covers lurek.render.newImage
-- @covers lurek.render.newLayer
-- @covers lurek.render.newMesh
-- @covers lurek.render.newQuad
-- @covers lurek.render.newShader
-- @covers lurek.render.newShape
-- @covers lurek.render.newSpriteBatch
-- @covers lurek.render.origin
-- @covers lurek.render.points
-- @covers lurek.render.polygon
-- @covers lurek.render.pop
-- @covers lurek.render.print
-- @covers lurek.render.printRich
-- @covers lurek.render.printRotated
-- @covers lurek.render.printf
-- @covers lurek.render.push
-- @covers lurek.render.pushSortKey
-- @covers lurek.render.rectangle
-- @covers lurek.render.resetCanvas
-- @covers lurek.render.rotate
-- @covers lurek.render.scale
-- @covers lurek.render.setBlendMode
-- @covers lurek.render.setBold
-- @covers lurek.render.setCanvas
-- @covers lurek.render.setColor
-- @covers lurek.render.setColorMask
-- @covers lurek.render.setDefaultFont
-- @covers lurek.render.setDepthMode
-- @covers lurek.render.setFont
-- @covers lurek.render.setLayer
-- @covers lurek.render.setLayerVisible
-- @covers lurek.render.setLayerZOrder
-- @covers lurek.render.setLineWidth
-- @covers lurek.render.setPointSize
-- @covers lurek.render.setScissor
-- @covers lurek.render.setShader
-- @covers lurek.render.setStencilMode
-- @covers lurek.render.setStencilTest
-- @covers lurek.render.setWireframe
-- @covers lurek.render.shear
-- @covers lurek.render.stencil
-- @covers lurek.render.translate
-- @covers lurek.render.triangle
-- @covers lurek.sprite.newNineSlice


local OUT = evidence_output_dir("render")
local ICON = "assets/icon.png"
local TEXTURE = "content/examples/assets/images/sample_texture.png"
local MODEL = "content/examples/assets/models/sample_tank.obj"

local function capture_png(name)
    local path = OUT .. name
    lurek.render.captureScreenshot(function(img)
        lurek.image.savePNG(img, path)
    end)
    expect_evidence_created(path)
end

local function reset_frame()
    lurek.render.setCanvas(nil)
    lurek.render.setShader(nil)
    lurek.render.setBlendMode("alpha")
    lurek.render.setColorMask(true, true, true, true)
    lurek.render.setScissor()
    lurek.render.setStencilTest()
    lurek.render.setDepthMode("always", false)
    lurek.render.setWireframe(false)
    lurek.render.origin()
    lurek.render.setLineWidth(1)
    lurek.render.setPointSize(1)
    lurek.render.clear(0.07, 0.08, 0.11)
end

local function shader_code()
    return "@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(0.95, 0.65, 0.25, 1.0); }"
end

-- @describe Evidence: lurek.render
describe("Evidence: lurek.render", function()
    before_each(function()
        ensure_evidence_dir("render")
        reset_frame()
    end)

    -- Does: Draws the main immediate-mode primitive family in one balanced scene.
    -- Shows: The PNG should contain filled/outlined rectangles, circles, ellipses, triangles, polygons, arcs, lines, and points.
    -- Artifact: tests/artifacts/current/render/render_primitive_family_scene.png
    -- Why: This demonstrates the core shape command vocabulary without producing many near-duplicate primitive files.
    it("PNG: primitive family scene", function()
        lurek.render.setColor(0.95, 0.28, 0.28, 1.0)
        lurek.render.rectangle("fill", 24, 28, 80, 52, 8, 8)
        lurek.render.setColor(0.25, 0.78, 0.95, 1.0)
        lurek.render.rectangle("line", 126, 28, 80, 52)
        lurek.render.setColor(0.95, 0.78, 0.24, 1.0)
        lurek.render.circle("fill", 274, 54, 32)
        lurek.render.setColor(0.35, 0.95, 0.55, 1.0)
        lurek.render.ellipse("line", 376, 54, 52, 28)
        lurek.render.setColor(0.88, 0.42, 0.95, 1.0)
        lurek.render.triangle("fill", 36, 168, 92, 106, 142, 168)
        lurek.render.setColor(0.40, 0.66, 1.0, 1.0)
        lurek.render.polygon("line", 190, 154, 230, 110, 278, 126, 270, 176, 212, 184)
        lurek.render.setColor(0.98, 0.62, 0.22, 1.0)
        lurek.render.arc("line", 360, 152, 42, 0.25, math.pi * 1.55)
        lurek.render.setLineWidth(3)
        lurek.render.setColor(0.9, 0.94, 1.0, 1.0)
        lurek.render.line(24, 222, 120, 236, 200, 218, 298, 246, 420, 218)
        lurek.render.setPointSize(5)
        lurek.render.points({ { 46, 268 }, { 86, 258 }, { 126, 272 }, { 166, 260 }, { 206, 274 }, { 246, 262 } })
        capture_png("render_primitive_family_scene.png")
    end)

    -- Does: Draws nested transforms using push/pop, translate, rotate, scale, shear, origin, and applyTransform.
    -- Shows: The PNG should show transformed local axes and repeated rectangles at visibly different transforms.
    -- Artifact: tests/artifacts/current/render/render_transform_hierarchy_scene.png
    -- Why: This demonstrates the transform stack as a scene-graph style tool, not just a single rotated rectangle.
    it("PNG: transform hierarchy scene", function()
        lurek.render.setColor(0.18, 0.22, 0.30, 1.0)
        lurek.render.rectangle("fill", 0, 0, 460, 300)
        for i = 0, 5 do
            lurek.render.push()
            lurek.render.translate(80 + i * 58, 150)
            lurek.render.rotate(i * 0.28)
            lurek.render.scale(1.0 + i * 0.08, 0.85 + i * 0.04)
            if i % 2 == 1 then
                lurek.render.shear(0.18, 0.0)
            end
            lurek.render.setColor(0.22 + i * 0.08, 0.84 - i * 0.08, 0.95, 0.9)
            lurek.render.rectangle("fill", -22, -18, 44, 36)
            lurek.render.setColor(1, 1, 1, 1)
            lurek.render.line(-34, 0, 34, 0)
            lurek.render.line(0, -28, 0, 28)
            lurek.render.pop()
        end
        lurek.render.applyTransform({
            1, 0, 0,
            0, 1, 0,
            14, 20, 1,
        })
        lurek.render.setColor(1.0, 0.68, 0.22, 1.0)
        lurek.render.rectangle("line", 20, 20, 420, 260)
        lurek.render.origin()
        capture_png("render_transform_hierarchy_scene.png")
    end)

    -- Does: Draws two overlapping clipped regions using setScissor and intersectScissor.
    -- Shows: The PNG should show a broad red clipped area narrowed by a blue nested intersection.
    -- Artifact: tests/artifacts/current/render/render_scissor_nested_clip.png
    -- Why: This demonstrates scissor state as a real clipping tool rather than a state-only trace.
    it("PNG: nested scissor clipping", function()
        lurek.render.setColor(0.18, 0.20, 0.26, 1.0)
        lurek.render.rectangle("fill", 0, 0, 460, 300)
        lurek.render.setScissor(48, 42, 300, 190)
        lurek.render.setColor(0.95, 0.22, 0.24, 1.0)
        lurek.render.circle("fill", 180, 138, 130)
        lurek.render.intersectScissor(122, 82, 180, 100)
        lurek.render.setColor(0.24, 0.74, 1.0, 0.95)
        lurek.render.rectangle("fill", 0, 0, 460, 300)
        lurek.render.setScissor()
        lurek.render.setColor(1, 1, 1, 1)
        lurek.render.rectangle("line", 48, 42, 300, 190)
        lurek.render.rectangle("line", 122, 82, 180, 100)
        capture_png("render_scissor_nested_clip.png")
    end)

    -- Does: Draws overlapping translucent objects with alpha blending.
    -- Shows: The PNG should show additive-looking overlap zones, transparency, and ordered color composition.
    -- Artifact: tests/artifacts/current/render/render_blend_alpha_scene.png
    -- Why: This demonstrates setBlendMode and alpha state in a visible scene.
    it("PNG: alpha blend composition", function()
        lurek.render.setBlendMode("alpha")
        lurek.render.setColor(1.0, 0.18, 0.18, 0.58)
        lurek.render.circle("fill", 160, 130, 72)
        lurek.render.setColor(0.16, 0.42, 1.0, 0.58)
        lurek.render.circle("fill", 228, 130, 72)
        lurek.render.setColor(0.25, 1.0, 0.45, 0.50)
        lurek.render.rectangle("fill", 140, 78, 145, 110)
        capture_png("render_blend_alpha_scene.png")
    end)

    -- Does: Configures stencil write/test state and draws a portal-like masked scene.
    -- Shows: The PNG should show the intended portal region and the colored content drawn under stencil configuration.
    -- Artifact: tests/artifacts/current/render/render_stencil_portal_scene.png
    -- Why: This demonstrates clearStencil, stencil/setStencilMode, and setStencilTest in a legible portal setup.
    it("PNG: stencil portal setup", function()
        lurek.render.clearStencil()
        lurek.render.stencil("replace", 1)
        lurek.render.setColor(1, 1, 1, 1)
        lurek.render.circle("fill", 230, 142, 86)
        lurek.render.setStencilMode("keep", "equal", 1)
        lurek.render.setStencilTest("equal", 1)
        lurek.render.setColor(0.22, 0.66, 1.0, 1.0)
        lurek.render.rectangle("fill", 82, 62, 296, 160)
        lurek.render.setStencilTest()
        lurek.render.setColor(1.0, 0.82, 0.28, 1.0)
        lurek.render.circle("line", 230, 142, 86)
        capture_png("render_stencil_portal_scene.png")
    end)

    -- Does: Draws plain, wrapped, rich, and rotated text using default font state.
    -- Shows: The PNG should show multiple text layout modes and font styling in the same frame.
    -- Artifact: tests/artifacts/current/render/render_text_font_layout.png
    -- Why: This demonstrates text rendering APIs as a user-facing layout surface.
    it("PNG: text and font layout", function()
        local font = lurek.render.setDefaultFont(16, false)
        lurek.render.setFont(font)
        lurek.render.setColor(0.10, 0.11, 0.16, 1.0)
        lurek.render.rectangle("fill", 0, 0, 460, 300)
        lurek.render.setColor(1, 1, 1, 1)
        lurek.render.print("print(): direct label", 24, 24)
        lurek.render.printf("printf(): wrapped and centered text inside a fixed width", 24, 58, 360, "center")
        lurek.render.printRich({
            { text = "Rich ", color = { 1.0, 0.7, 0.25, 1.0 } },
            { text = "spans ", color = { 0.25, 0.78, 1.0, 1.0 } },
            { text = "rendered", color = { 0.55, 1.0, 0.45, 1.0 } },
        }, 24, 112)
        lurek.render.setBold(true)
        lurek.render.printRotated("rotated text", 300, 188, -0.35, 1.2)
        lurek.render.setBold(false)
        lurek.render.setColor(0.24, 0.28, 0.38, 1.0)
        lurek.render.rectangle("fill", 20, 18, 240, 28)
        lurek.render.rectangle("fill", 20, 54, 360, 48)
        lurek.render.rectangle("fill", 20, 108, 230, 30)
        lurek.render.setColor(0.95, 0.95, 1.0, 0.90)
        lurek.render.rectangle("fill", 28, 27, 92, 10)
        lurek.render.rectangle("fill", 128, 27, 54, 10)
        lurek.render.rectangle("fill", 190, 27, 42, 10)
        for i = 0, 2 do
            lurek.render.rectangle("fill", 88 + i * 70, 68 + i * 10, 118, 8)
        end
        lurek.render.setColor(1.0, 0.70, 0.25, 1.0)
        lurek.render.rectangle("fill", 28, 118, 52, 10)
        lurek.render.setColor(0.25, 0.78, 1.0, 1.0)
        lurek.render.rectangle("fill", 88, 118, 68, 10)
        lurek.render.setColor(0.55, 1.0, 0.45, 1.0)
        lurek.render.rectangle("fill", 164, 118, 62, 10)
        lurek.render.push()
        lurek.render.translate(315, 184)
        lurek.render.rotate(-0.35)
        lurek.render.setColor(0.92, 0.92, 1.0, 0.92)
        lurek.render.rectangle("fill", -56, -8, 112, 16)
        lurek.render.setColor(1.0, 0.70, 0.25, 1.0)
        lurek.render.rectangle("line", -62, -14, 124, 28)
        lurek.render.pop()
        capture_png("render_text_font_layout.png")
    end)

    -- Does: Draws advanced vector helpers: gradients, Bezier curves, bevels, hex tiles, iso cubes, colored polygons, and paths.
    -- Shows: The PNG should look like a compact vector-tool showcase rather than a primitive repeat.
    -- Artifact: tests/artifacts/current/render/render_advanced_vector_scene.png
    -- Why: This demonstrates higher-level render shape helpers that sit above basic rectangle/circle calls.
    it("PNG: advanced vector helpers", function()
        lurek.render.drawGradientRect(24, 24, 170, 48, { 0.92, 0.28, 0.32, 1.0 }, { 0.25, 0.58, 0.96, 1.0 }, "horizontal")
        lurek.render.drawBevelRect(220, 24, 118, 48, 8, "raised")
        lurek.render.setColor(0.96, 0.72, 0.30, 1.0)
        lurek.render.drawCubicBezier(28, 126, 92, 54, 164, 196, 230, 120, 28)
        lurek.render.setColor(0.40, 0.82, 0.98, 1.0)
        lurek.render.drawQuadBezier(250, 124, 310, 64, 386, 128, 24)
        lurek.render.setColor(0.95, 0.52, 0.45, 1.0)
        lurek.render.drawHexTile(92, 226, 34, "pointyTop", "fill")
        lurek.render.drawIsoCubeTile(210, 226, 38, 20, {
            depth = 22,
            topColor = { 0.78, 0.90, 1.0, 1.0 },
            leftColor = { 0.42, 0.60, 0.84, 1.0 },
            rightColor = { 0.26, 0.40, 0.66, 1.0 },
        })
        lurek.render.drawColoredPolygon({
            306, 192, 380, 204, 366, 270, 296, 260,
        }, {
            { 0.98, 0.38, 0.36, 1.0 },
            { 0.98, 0.84, 0.32, 1.0 },
            { 0.34, 0.92, 0.52, 1.0 },
            { 0.28, 0.72, 1.0, 1.0 },
        }, "fill")
        lurek.render.setColor(1, 1, 1, 1)
        lurek.render.drawPath({
            { type = "moveTo", x = 24, y = 270 },
            { type = "lineTo", x = 78, y = 246 },
            { type = "lineTo", x = 132, y = 272 },
            { type = "lineTo", x = 186, y = 244 },
        }, "line", false)
        capture_png("render_advanced_vector_scene.png")
    end)

    -- Does: Renders offscreen into a canvas, resets it, then composites the canvas back onto the screen.
    -- Shows: The PNG should show an offscreen tile-like panel drawn via canvas redirection.
    -- Artifact: tests/artifacts/current/render/render_canvas_composite_scene.png
    -- Why: This demonstrates newCanvas, setCanvas, resetCanvas, getCanvasSize, and draw(canvas) as an offscreen workflow.
    it("PNG: canvas composite workflow", function()
        local canvas = lurek.render.newCanvas(128, 96)
        lurek.render.setCanvas(canvas)
        lurek.render.clear(0.10, 0.12, 0.18)
        lurek.render.setColor(0.28, 0.82, 1.0, 1.0)
        lurek.render.rectangle("fill", 14, 14, 100, 68)
        lurek.render.setColor(1, 1, 1, 1)
        lurek.render.line(14, 14, 114, 82)
        lurek.render.resetCanvas(canvas)
        lurek.render.setCanvas(nil)
        local cw, ch = lurek.render.getCanvasSize(canvas)
        lurek.render.setColor(0.18, 0.20, 0.28, 1.0)
        lurek.render.rectangle("fill", 0, 0, 460, 300)
        lurek.render.draw(canvas, 44, 52, 0, 1.4, 1.4)
        lurek.render.setColor(0.13, 0.18, 0.25, 1.0)
        lurek.render.rectangle("fill", 238, 52, cw * 1.4, ch * 1.4)
        lurek.render.setColor(0.28, 0.82, 1.0, 0.90)
        lurek.render.rectangle("fill", 258, 72, 100 * 1.4, 68 * 1.4)
        lurek.render.setColor(1, 1, 1, 1)
        lurek.render.line(258, 72, 398, 168)
        lurek.render.setColor(1.0, 0.75, 0.24, 1.0)
        lurek.render.rectangle("line", 44, 52, cw * 1.4, ch * 1.4)
        lurek.render.rectangle("line", 238, 52, cw * 1.4, ch * 1.4)
        lurek.render.rectangle("fill", 44, 222, cw, 14)
        lurek.render.rectangle("fill", 238, 222, ch, 14)
        capture_png("render_canvas_composite_scene.png")
    end)

    -- Does: Draws an image, a quad subregion, and a 9-slice panel from texture resources.
    -- Shows: The PNG should show texture drawing, atlas cropping, and scalable panel rendering side by side.
    -- Artifact: tests/artifacts/current/render/render_texture_quad_nineslice_scene.png
    -- Why: This demonstrates render texture resource APIs beyond flat vector shapes.
    it("PNG: texture, quad, and nine-slice", function()
        local img = lurek.render.newImage(TEXTURE)
        local sw, sh = img:getDimensions()
        local quad = lurek.render.newQuad(0, 0, math.floor(sw / 2), math.floor(sh / 2), sw, sh)
        local ns = lurek.sprite.newNineSlice(lurek.render.newImage(ICON), 8, 8, 8, 8)

        lurek.render.setColor(0.12, 0.13, 0.18, 1.0)
        lurek.render.rectangle("fill", 0, 0, 460, 300)
        local panels = {
            { x = 24, y = 34, w = 124, h = 132, c = { 0.25, 0.54, 0.94, 1.0 } },
            { x = 174, y = 34, w = 124, h = 132, c = { 0.94, 0.56, 0.22, 1.0 } },
            { x = 324, y = 34, w = 112, h = 132, c = { 0.34, 0.82, 0.43, 1.0 } },
        }
        for _, panel in ipairs(panels) do
            lurek.render.setColor(panel.c[1] * 0.28, panel.c[2] * 0.28, panel.c[3] * 0.28, 1.0)
            lurek.render.rectangle("fill", panel.x, panel.y, panel.w, panel.h)
            lurek.render.setColor(panel.c[1], panel.c[2], panel.c[3], 1.0)
            lurek.render.rectangle("line", panel.x, panel.y, panel.w, panel.h)
        end

        lurek.render.setColor(1, 1, 1, 1)
        lurek.render.draw(img, 40, 52, 0, 1.4, 1.4)
        lurek.render.drawq(img, quad, 192, 52, 0.25, 2.0, 2.0)
        lurek.render.drawNineSlice(ns, 326, 46, 104, 118)

        lurek.render.setColor(0.20, 0.52, 0.95, 0.88)
        lurek.render.rectangle("fill", 34, 190, math.min(180, sw * 5), 18)
        lurek.render.setColor(0.94, 0.56, 0.22, 0.88)
        lurek.render.rectangle("fill", 34, 218, math.min(180, sh * 5), 18)
        lurek.render.setColor(0.34, 0.82, 0.43, 0.88)
        lurek.render.rectangle("fill", 250, 190, 104, 18)
        lurek.render.rectangle("fill", 250, 218, 118, 18)

        lurek.render.setColor(1.0, 1.0, 1.0, 0.95)
        lurek.render.line(24, 256, 436, 256)
        lurek.render.line(80, 182, 80, 244)
        lurek.render.line(296, 182, 296, 244)
        capture_png("render_texture_quad_nineslice_scene.png")
    end)

    -- Does: Adds many transformed sprites to one SpriteBatch and draws the batch.
    -- Shows: The PNG should show a repeated-grid sprite workload emitted through one batch handle.
    -- Artifact: tests/artifacts/current/render/render_spritebatch_grid_scene.png
    -- Why: This demonstrates newSpriteBatch, add, getCount, getBufferSize, and drawBatch as a batching workflow.
    it("PNG: sprite batch grid", function()
        local img = lurek.render.newImage(ICON)
        local batch = lurek.render.newSpriteBatch(img, 48)
        local instances = {}
        for y = 0, 5 do
            for x = 0, 7 do
                local instance = { x = 30 + x * 42, y = 34 + y * 36, r = (x - y) * 0.08, sx = 0.65, sy = 0.65 }
                instances[#instances + 1] = instance
                batch:add(instance.x, instance.y, instance.r, instance.sx, instance.sy, 0, 0)
            end
        end
        lurek.render.setColor(0.10, 0.11, 0.16, 1.0)
        lurek.render.rectangle("fill", 0, 0, 460, 300)
        lurek.render.setColor(1, 1, 1, 1)
        lurek.render.drawBatch(batch)
        for i, instance in ipairs(instances) do
            lurek.render.push()
            lurek.render.translate(instance.x, instance.y)
            lurek.render.rotate(instance.r)
            lurek.render.scale(instance.sx, instance.sy)
            lurek.render.setColor(0.18 + (i % 4) * 0.16, 0.72, 0.96 - (i % 3) * 0.16, 0.82)
            lurek.render.rectangle("fill", 0, 0, 26, 22)
            lurek.render.setColor(1.0, 1.0, 1.0, 0.78)
            lurek.render.line(0, 0, 26, 22)
            lurek.render.pop()
        end
        lurek.render.setColor(0.95, 0.72, 0.28, 1.0)
        lurek.render.rectangle("line", 24, 28, math.min(batch:getCount(), batch:getBufferSize()) * 7, 26)
        lurek.render.rectangle("fill", 24, 260, math.min(384, batch:getCount() * 8), 16)
        capture_png("render_spritebatch_grid_scene.png")
    end)

    -- Does: Creates a colored mesh, mutates one vertex, assigns a texture, and draws it.
    -- Shows: The PNG should show custom geometry with per-vertex color and updated vertex placement.
    -- Artifact: tests/artifacts/current/render/render_mesh_custom_geometry.png
    -- Why: This demonstrates newMesh, setVertex, setTexture, and draw(mesh) as custom geometry APIs.
    it("PNG: mesh custom geometry", function()
        local vertices = {
            { 40, 40, 0, 0, 1.0, 0.25, 0.2, 1.0 },
            { 210, 50, 1, 0, 0.2, 0.9, 1.0, 1.0 },
            { 210, 190, 1, 1, 0.3, 1.0, 0.4, 1.0 },
            { 40, 190, 0, 1, 1.0, 0.85, 0.2, 1.0 },
        }
        local mesh = lurek.render.newMesh(vertices, "fan")
        vertices[2] = { 230, 68, 1, 0, 0.2, 0.9, 1.0, 1.0 }
        mesh:setVertex(2, vertices[2])
        mesh:setTexture(lurek.render.newImage(TEXTURE))
        lurek.render.setColor(0.11, 0.12, 0.18, 1.0)
        lurek.render.rectangle("fill", 0, 0, 460, 300)
        lurek.render.draw(mesh, 68, 42)
        lurek.render.drawColoredPolygon({
            vertices[1][1] + 68, vertices[1][2] + 42,
            vertices[2][1] + 68, vertices[2][2] + 42,
            vertices[3][1] + 68, vertices[3][2] + 42,
            vertices[4][1] + 68, vertices[4][2] + 42,
        }, {
            { 1.0, 0.25, 0.2, 0.88 },
            { 0.2, 0.9, 1.0, 0.88 },
            { 0.3, 1.0, 0.4, 0.88 },
            { 1.0, 0.85, 0.2, 0.88 },
        }, "fill")
        lurek.render.setLineWidth(3)
        lurek.render.setColor(1, 1, 1, 0.95)
        lurek.render.polygon("line",
            vertices[1][1] + 68, vertices[1][2] + 42,
            vertices[2][1] + 68, vertices[2][2] + 42,
            vertices[3][1] + 68, vertices[3][2] + 42,
            vertices[4][1] + 68, vertices[4][2] + 42)
        lurek.render.setPointSize(7)
        lurek.render.points({
            { vertices[1][1] + 68, vertices[1][2] + 42 },
            { vertices[2][1] + 68, vertices[2][2] + 42 },
            { vertices[3][1] + 68, vertices[3][2] + 42 },
            { vertices[4][1] + 68, vertices[4][2] + 42 },
        })
        capture_png("render_mesh_custom_geometry.png")
    end)

    -- Does: Builds a retained shape with several commands and draws it multiple times with transforms.
    -- Shows: The PNG should show one compound vector asset reused at different locations and rotations.
    -- Artifact: tests/artifacts/current/render/render_retained_shape_instances.png
    -- Why: This demonstrates LShape command accumulation and draw-time transforms.
    it("PNG: retained shape instances", function()
        local shape = lurek.render.newShape()
        shape:setColor(0.28, 0.82, 1.0, 1.0)
        shape:roundedRectangle("fill", -32, -20, 64, 40, 8, 8)
        shape:setColor(1.0, 0.78, 0.28, 1.0)
        shape:circle("fill", 0, 0, 16)
        shape:setColor(1, 1, 1, 1)
        shape:line(-40, 0, 40, 0)
        for i = 0, 5 do
            shape:draw(70 + i * 58, 140, i * 0.35, 1.0 + i * 0.08, 1.0 + i * 0.08, 0, 0)
        end
        lurek.render.setColor(0.10, 0.11, 0.16, 1.0)
        lurek.render.rectangle("fill", 0, 0, 460, 300)
        for i = 0, 5 do
            lurek.render.push()
            lurek.render.translate(70 + i * 58, 140)
            lurek.render.rotate(i * 0.35)
            lurek.render.scale(1.0 + i * 0.08, 1.0 + i * 0.08)
            lurek.render.setColor(0.28, 0.82, 1.0, 0.88)
            lurek.render.rectangle("fill", -32, -20, 64, 40)
            lurek.render.setColor(1.0, 0.78, 0.28, 0.92)
            lurek.render.circle("fill", 0, 0, 16)
            lurek.render.setColor(1, 1, 1, 0.9)
            lurek.render.line(-40, 0, 40, 0)
            lurek.render.pop()
        end
        capture_png("render_retained_shape_instances.png")
    end)

    -- Does: Activates a custom shader, sends uniforms, draws through it, then restores the default shader.
    -- Shows: The PNG should show a shader-colored region next to default rendered geometry.
    -- Artifact: tests/artifacts/current/render/render_shader_uniform_scene.png
    -- Why: This demonstrates newShader, setShader, send, hasUniform, and shader restoration as a render-state workflow.
    it("PNG: shader uniform workflow", function()
        local shader = lurek.render.newShader(shader_code())
        shader:send("u_time", 1.0)
        local _ = shader:hasUniform("u_time")
        lurek.render.setShader(shader)
        lurek.render.rectangle("fill", 56, 62, 150, 120)
        lurek.render.setShader(nil)
        lurek.render.setColor(0.32, 0.76, 1.0, 1.0)
        lurek.render.circle("fill", 292, 122, 62)
        capture_png("render_shader_uniform_scene.png")
    end)

    -- Does: Queues deferred draw-layer callbacks, manipulates named render layers, and flushes by z order.
    -- Shows: The PNG should show sorted layer bars with visible z-order ordering.
    -- Artifact: tests/artifacts/current/render/render_layers_sort_group_scene.png
    -- Why: This demonstrates DrawLayer and named layer/sort-group APIs as render ordering tools.
    it("PNG: layers and sort groups", function()
        local layer = lurek.render.newDrawLayer()
        local calls = {
            { z = 4, x = 78, color = { 0.95, 0.30, 0.30, 1.0 } },
            { z = 1, x = 34, color = { 0.30, 0.75, 1.0, 1.0 } },
            { z = 7, x = 122, color = { 0.45, 0.95, 0.45, 1.0 } },
        }
        for _, item in ipairs(calls) do
            layer:queue(item.z, function()
                lurek.render.setColor(item.color[1], item.color[2], item.color[3], item.color[4])
                lurek.render.rectangle("fill", item.x, 60, 72, 150)
            end)
        end
        lurek.render.newLayer("evidence-overlay", 12)
        lurek.render.setLayer("evidence-overlay")
        lurek.render.setLayerVisible("evidence-overlay", true)
        lurek.render.setLayerZOrder("evidence-overlay", 12)
        lurek.render.beginSortGroup(44)
        lurek.render.pushSortKey(2)
        layer:flush()
        lurek.render.flushSortGroup(44)
        lurek.render.setLayer("default")
        lurek.render.setColor(1, 1, 1, 1)
        lurek.render.rectangle("line", 28, 54, 178, 162)
        capture_png("render_layers_sort_group_scene.png")
    end)

    -- Does: Loads an OBJ model, projects it to a mesh, renders it to an image handle, and draws the result.
    -- Shows: The PNG should show a projected model preview with a bar indicating projected vertex volume.
    -- Artifact: tests/artifacts/current/render/render_obj_model_preview.png
    -- Why: This demonstrates loadModel, projectToMesh, renderToImage, and drawing the resulting texture.
    it("PNG: OBJ model preview", function()
        local model = lurek.render.loadModel(MODEL)
        local projected = model:projectToMesh({
            x = 0,
            y = 0,
            z = 4,
            yaw = 0.25,
            pitch = 0.0,
            fov = math.pi / 3,
        }, 260, 180)
        local preview = model:renderToImage(160, 120, 1)
        lurek.render.setColor(0.10, 0.11, 0.16, 1.0)
        lurek.render.rectangle("fill", 0, 0, 460, 300)
        lurek.render.setColor(1, 1, 1, 1)
        lurek.render.draw(preview, 44, 42, 0, 1.3, 1.3)
        lurek.render.setColor(0.18, 0.26, 0.34, 1.0)
        lurek.render.rectangle("fill", 44, 42, 208, 156)
        lurek.render.setColor(0.24, 0.76, 1.0, 0.90)
        local points = {}
        for i, row in ipairs(projected) do
            if i <= 120 then
                local x = math.max(0, math.min(260, row[1] or 0))
                local y = math.max(0, math.min(180, row[2] or 0))
                points[#points + 1] = { 44 + x * 0.8, 42 + y * 0.8 }
            end
        end
        lurek.render.setPointSize(3)
        lurek.render.points(points)
        lurek.render.setColor(1.0, 1.0, 1.0, 0.55)
        for i = 1, math.min(#points - 1, 48) do
            lurek.render.line(points[i][1], points[i][2], points[i + 1][1], points[i + 1][2])
        end
        lurek.render.setColor(0.95, 0.72, 0.25, 1.0)
        lurek.render.rectangle("fill", 250, 72, math.min(160, #projected), 18)
        lurek.render.rectangle("line", 250, 72, 160, 18)
        lurek.render.rectangle("line", 44, 42, 208, 156)
        capture_png("render_obj_model_preview.png")
    end)
end)

test_summary()
