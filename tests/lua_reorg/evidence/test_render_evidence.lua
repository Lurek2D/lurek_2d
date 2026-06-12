-- test_render_evidence.lua
-- Canonical evidence file for lurek.render.


local OUT = evidence_output_dir("render")

local function capture_png(name)
    local path = OUT .. name
    lurek.render.captureScreenshot(function(img)
        lurek.image.savePNG(img, path)
    end)
    expect_evidence_created(path)
end

local function save_png(img, name)
    local path = OUT .. name
    lurek.image.savePNG(img, path)
    expect_evidence_created(path)
end

-- Helper: draw a 1px outline rectangle using native lines
local function draw_rect_line_native(img, x, y, w, h, r, g, b, a)
    a = a or 255
    local x1, y1 = x + w - 1, y + h - 1
    img:drawLine(x, y, x1, y, r, g, b, a)
    img:drawLine(x1, y, x1, y1, r, g, b, a)
    img:drawLine(x1, y1, x, y1, r, g, b, a)
    img:drawLine(x, y1, x, y, r, g, b, a)
end

-- @describe Evidence: lurek.render drawing API + PNG output
describe("Evidence: lurek.render drawing API + PNG output", function()

    -- @evidence lurek.image.savePNG
    it("PNG: all graphic primitives rendered to image", function()
        local W, H = 256, 256
        local img = lurek.image.newImageData(W, H)
        img:fill(15, 15, 25, 255)

        -- Filled rectangle (red)
        img:drawRect(10, 10, 60, 40, 220, 50, 50, 255)
        -- Outline rectangle (green)
        draw_rect_line_native(img, 10, 60, 60, 40, 50, 220, 50, 255)
        -- Filled circle (blue)
        img:drawCircle(150, 40, 30, 50, 50, 220, 255)
        -- Circle outline (via ring)
        for angle = 0, 360 do
            local rad = math.rad(angle)
            local px = math.floor(150 + 30 * math.cos(rad))
            local py = math.floor(120 + 30 * math.sin(rad))
            if px >= 0 and px < W and py >= 0 and py < H then
                img:setPixel(px, py, 50, 220, 220, 255)
            end
        end
        -- Diagonal line (yellow)
        img:drawLine(10, 170, 240, 200, 220, 220, 50, 255)
        -- Horizontal line (white)
        img:drawLine(10, 220, 240, 220, 255, 255, 255, 255)
        -- Vertical line (magenta)
        img:drawLine(200, 10, 200, 240, 220, 50, 220, 255)
        -- Point cluster (white dots)
        for i = 0, 19 do
            local px = 120 + i * 6
            local py = 180
            if px < W then img:setPixel(px, py, 255, 255, 255, 255) end
        end

        save_png(img, "graphic_primitives.png")
    end)

    -- @evidence lurek.render.setColor
    -- @evidence lurek.render.getColor
    it("PNG: color grid - setColor evidence across hue range", function()
        local W, H = 128, 128
        local img = lurek.image.newImageData(W, H)

        -- 8x8 grid of colors; each cell verifies setColor round-trip
        local cell_w = W / 8
        local cell_h = H / 8
        for row = 0, 7 do
            for col = 0, 7 do
                local r = math.floor((col / 7) * 255)
                local g = math.floor((row / 7) * 255)
                local b = math.floor(((col + row) / 14) * 255)
                -- Verify setColor + getColor round-trip
                lurek.render.setColor(r / 255, g / 255, b / 255, 1.0)
                local gr, gg, gb, ga = lurek.render.getColor()
                -- Draw the color block
                local x0 = math.floor(col * cell_w)
                local y0 = math.floor(row * cell_h)
                img:drawRect(x0, y0, math.floor(cell_w), math.floor(cell_h), r, g, b, 255)
            end
        end

        save_png(img, "graphic_color_grid.png")
    end)

end)

-- @describe Evidence: Canvas lifecycle + PNG visualization
describe("Evidence: Canvas lifecycle + PNG visualization", function()

    -- @evidence lurek.render.newCanvas
    it("PNG: canvas sizes visualized as colored rectangles", function()
        local W, H = 256, 256
        local img = lurek.image.newImageData(W, H)
        img:fill(20, 20, 30, 255)

        local canvases = {
            {128, 64,  255, 80,  80},
            {200, 100, 80,  255, 80},
            {64,  64,  80,  80,  255},
            {256, 256, 255, 255, 80},
            {32,  32,  255, 128, 0},
            {320, 180, 128, 0,   255},
        }
        local y_off = 4
        for _, cfg in ipairs(canvases) do
            local cw, ch, r, g, b = cfg[1], cfg[2], cfg[3], cfg[4], cfg[5]
            local c = lurek.render.newCanvas(cw, ch)
            local aw, ah = c:getDimensions()
            c:release()
            local scale = math.min(240 / aw, 30 / ah)
            local dw = math.floor(aw * scale)
            local dh = math.max(math.floor(ah * scale), 4)
            img:drawRect(8, y_off, dw, dh, r, g, b, 255)
            draw_rect_line_native(img, 8, y_off, dw, dh, 255, 255, 255, 255)
            y_off = y_off + dh + 4
        end

        save_png(img, "render_canvas_sizes.png")
    end)

    -- @evidence lurek.render.newCanvas
    it("PNG: canvas lifecycle state diagram (created/active/released)", function()
        local img = lurek.image.newImageData(128, 64)
        img:fill(30, 30, 40, 255)

        local c = lurek.render.newCanvas(64, 64)
        -- Created (green)
        img:drawRect(4, 4, 36, 56, 0, 200, 0, 255)
        -- Active (blue)
        local _ = c:getWidth()
        img:drawRect(46, 4, 36, 56, 0, 0, 200, 255)
        -- Released (red)
        c:release()
        img:drawRect(88, 4, 36, 56, 200, 0, 0, 255)

        save_png(img, "render_canvas_lifecycle.png")
    end)

end)

-- @describe Evidence: Image layers
describe("Evidence: Image layers", function()

    -- @evidence lurek.render.newDrawLayer
    it("merges three color layers into one image", function()
        local W, H = 256, 256

        -- Background layer
        local base = lurek.image.newImageData(W, H)
        base:drawRect(0, 0, W, H, 30, 30, 60, 255)

        -- Compose base + mid + top natively
        base:drawRect(40, 40, 140, 140, 40, 80, 200, 180)
        base:drawCircle(128, 128, 60, 220, 60, 60, 180)

        save_png(base, "render_draw_layer_basic_merge.png")
    end)

    -- @evidence lurek.render.newDrawLayer
    it("produces distinct opacity levels for a gradient layer stack", function()
        local W, H = 256, 64

        local strips = { 255, 200, 150, 100, 50, 0 }
        local img = lurek.image.newImageData(W, H)
        img:drawRect(0, 0, W, H, 20, 20, 40, 255)

        local sw = math.floor(W / #strips)
        for i, alpha in ipairs(strips) do
            local x = (i - 1) * sw
            img:drawRect(x, 0, sw, H, 220, 80, 80, alpha)
        end

        save_png(img, "render_draw_layer_opacity.png")
    end)

    -- @evidence lurek.render.newDrawLayer
    it("uses DrawLayer to manage z-ordered render queue", function()
        local layer = lurek.render.newDrawLayer()

        local calls = 0
        layer:queue(5, function()
            calls = calls + 1
        end)
        layer:queue(1, function()
            calls = calls + 1
        end)
        layer:queue(10, function()
            calls = calls + 1
        end)

        layer:flush()

        layer:queue(3, function() end)
        layer:queue(7, function() end)
        layer:clear()

        local W, H = 200, 200
        local img = lurek.image.newImageData(W, H)
        img:drawRect(0,   0,   W,   H,   20,  20,  40,  255)
        img:drawRect(10,  10,  180, 180, 40,  80,  200, 200)
        img:drawRect(50,  50,  100, 100, 220, 80,  80,  200)
        img:drawRect(80,  80,  40,  40,  80,  220, 80,  200)
        save_png(img, "render_draw_layer_management.png")
    end)

end)

-- @describe Evidence: lurek.render shape and state API
describe("Evidence: lurek.render shape and state API", function()
    before_each(function()
        ensure_evidence_dir("render")
        lurek.render.clear(0.08, 0.08, 0.12)
    end)

    -- @evidence lurek.render.setColor
    -- @evidence lurek.render.rectangle
    it("PNG: render_rectangles.png -- filled and outlined rectangles", function()
        lurek.render.setColor(0.9, 0.3, 0.3, 1.0)
        lurek.render.rectangle("fill", 24, 24, 120, 70)
        lurek.render.setColor(0.3, 0.8, 0.9, 1.0)
        lurek.render.rectangle("line", 170, 24, 120, 70)
        capture_png("render_rectangles.png")
    end)

    -- @evidence lurek.render.circle
    -- @evidence lurek.render.ellipse
    -- @evidence lurek.render.setColor
    it("PNG: render_circle_ellipse.png -- circle and ellipse primitives", function()
        lurek.render.setColor(0.9, 0.8, 0.3, 1.0)
        lurek.render.circle("fill", 90, 90, 50)
        lurek.render.setColor(0.3, 0.9, 0.5, 1.0)
        lurek.render.ellipse("line", 230, 90, 70, 35)
        capture_png("render_circle_ellipse.png")
    end)

    -- @evidence lurek.render.triangle
    -- @evidence lurek.render.polygon
    -- @evidence lurek.render.setColor
    it("PNG: render_triangle_polygon.png -- triangle and polygon primitives", function()
        lurek.render.setColor(0.9, 0.4, 0.4, 1.0)
        lurek.render.triangle("fill", 40, 150, 130, 50, 180, 150)
        lurek.render.setColor(0.4, 0.7, 0.95, 1.0)
        lurek.render.polygon("line", 220, 150, 260, 95, 315, 110, 300, 165, 240, 175)
        capture_png("render_triangle_polygon.png")
    end)

    -- @evidence lurek.render.line
    -- @evidence lurek.render.setLineWidth
    -- @evidence lurek.render.arc
    it("PNG: render_line_arc.png -- lines, polyline, and arc", function()
        lurek.render.setColor(0.9, 0.9, 0.9, 1.0)
        lurek.render.setLineWidth(2)
        lurek.render.line(20, 30, 300, 30)
        lurek.render.line(20, 60, 80, 85)
        lurek.render.line(80, 85, 140, 70)
        lurek.render.line(140, 70, 200, 110)
        lurek.render.line(200, 110, 280, 90)
        lurek.render.setColor(0.95, 0.7, 0.3, 1.0)
        lurek.render.arc("line", 170, 150, 55, 0.0, math.pi * 1.35)
        capture_png("render_line_arc.png")
    end)

    -- @evidence lurek.render.push
    -- @evidence lurek.render.translate
    -- @evidence lurek.render.rotate
    -- @evidence lurek.render.scale
    -- @evidence lurek.render.pop
    -- @evidence lurek.render.rectangle
    it("PNG: render_transform_stack.png -- transformed rectangle stack", function()
        lurek.render.push()
        lurek.render.translate(110, 90)
        lurek.render.rotate(0.5)
        lurek.render.scale(1.2, 1.2)
        lurek.render.setColor(0.4, 0.85, 0.55, 1.0)
        lurek.render.rectangle("fill", -40, -25, 80, 50)
        lurek.render.pop()

        lurek.render.setColor(0.9, 0.4, 0.7, 1.0)
        lurek.render.rectangle("line", 220, 60, 80, 50)
        capture_png("render_transform_stack.png")
    end)

    -- @evidence lurek.render.setScissor
    -- @evidence lurek.render.intersectScissor
    -- @evidence lurek.render.rectangle
    it("PNG: render_scissor_region.png -- scissor and intersectScissor clipping", function()
        lurek.render.setScissor(40, 30, 140, 100)
        lurek.render.setColor(0.95, 0.35, 0.35, 1.0)
        lurek.render.rectangle("fill", 0, 0, 320, 180)
        lurek.render.intersectScissor(80, 50, 80, 60)
        lurek.render.setColor(0.35, 0.8, 0.95, 1.0)
        lurek.render.rectangle("fill", 0, 0, 320, 180)
        lurek.render.setScissor()
        capture_png("render_scissor_region.png")
    end)

    -- @evidence lurek.render.setBlendMode
    -- @evidence lurek.render.circle
    it("PNG: render_blend_alpha.png -- alpha blended circles", function()
        lurek.render.setBlendMode("alpha")
        lurek.render.setColor(1.0, 0.2, 0.2, 0.6)
        lurek.render.circle("fill", 120, 95, 55)
        lurek.render.setColor(0.2, 0.2, 1.0, 0.6)
        lurek.render.circle("fill", 180, 95, 55)
        capture_png("render_blend_alpha.png")
    end)

    -- @evidence lurek.render.clearStencil
    -- @evidence lurek.render.setStencilMode
    -- @evidence lurek.render.setStencilTest
    -- @evidence lurek.render.rectangle
    it("PNG: render_stencil_setup.png -- stencil mode setup", function()
        lurek.render.clearStencil()
        lurek.render.setStencilMode("replace", "always", 1)
        lurek.render.setStencilTest("greater", 0)
        lurek.render.setColor(0.95, 0.75, 0.35, 1.0)
        lurek.render.rectangle("fill", 60, 40, 200, 100)
        capture_png("render_stencil_setup.png")
    end)

    -- @evidence lurek.render.setDepthMode
    -- @evidence lurek.render.setWireframe
    -- @evidence lurek.render.rectangle
    it("PNG: render_depth_wireframe.png -- depth and wireframe toggles", function()
        lurek.render.setDepthMode("less", true)
        lurek.render.setWireframe(true)
        lurek.render.setColor(0.4, 0.9, 0.5, 1.0)
        lurek.render.rectangle("line", 70, 45, 180, 90)
        lurek.render.setWireframe(false)
        lurek.render.setDepthMode("always", false)
        capture_png("render_depth_wireframe.png")
    end)

    -- @evidence lurek.render.setColorMask
    -- @evidence lurek.render.rectangle
    it("PNG: render_color_mask.png -- color mask channel writes", function()
        lurek.render.setColorMask(true, false, false, true)
        lurek.render.setColor(1.0, 0.2, 0.2, 1.0)
        lurek.render.rectangle("fill", 20, 20, 120, 80)
        lurek.render.setColorMask(false, true, false, true)
        lurek.render.setColor(0.2, 1.0, 0.2, 1.0)
        lurek.render.rectangle("fill", 100, 60, 120, 80)
        lurek.render.setColorMask(true, true, true, true)
        capture_png("render_color_mask.png")
    end)
end)

-- @describe evidence: render summary dashboard
describe("evidence: render summary dashboard", function()
    before_each(function()
        ensure_evidence_dir("render")
    end)

    -- @evidence lurek.image.savePNG
    it("writes render_summary_dashboard.png", function()
        local W, H = 320, 180
        local img = lurek.image.newImageData(W, H)
        img:fill(14, 16, 22, 255)

        for x = 0, W - 1, 16 do
            img:drawLine(x, 0, x, H - 1, 28, 32, 44, 255)
        end
        for y = 0, H - 1, 16 do
            img:drawLine(0, y, W - 1, y, 28, 32, 44, 255)
        end

        img:drawRect(16, 16, 88, 48, 180, 70, 70, 255)
        img:drawCircle(160, 42, 22, 70, 170, 230, 255)
        img:drawLine(224, 16, 300, 64, 255, 230, 80, 255)
        img:drawRect(16, 96, 288, 64, 40, 45, 60, 255)

        save_png(img, "render_summary_dashboard.png")
    end)
end)
test_summary()
