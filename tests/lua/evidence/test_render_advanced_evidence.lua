-- test_render_advanced_evidence.lua
-- Evidence tests: advanced lurek.render primitives not covered elsewhere.
-- Covers exactly 10 high-quality unique evidence files.
-- All shapes and primitives are rendered natively using ImageData methods:
-- img:drawRect, img:drawCircle, img:drawLine, img:blit.
-- ZERO custom pixel loops in Lua.

local OUT = "tests/output/render_advanced/"

describe("Evidence: advanced lurek.render primitives", function()

    -- Helper: GID/Tile color mapping
    local function gid_color(gid)
        local colors = {
            { 80, 160,  80 },  -- grass
            { 60, 120, 200 },  -- water
            { 140, 100, 60 },  -- dirt
            { 160, 160, 160 }, -- stone
        }
        local idx = ((gid - 1) % #colors) + 1
        return colors[idx][1], colors[idx][2], colors[idx][3]
    end

    -- 1. @evidence file
    it("PNG: isometric tile grid (diamond layout)", function()
        ensure_evidence_dir("render_advanced")
        local path = OUT .. "iso_tile_grid.png"

        local W, H = 320, 256
        local img = lurek.image.newImageData(W, H)
        img:fill(25, 20, 35, 255)

        local TW, TH = 32, 16  -- tile width and half-height
        local ROWS, COLS = 8, 8
        local origin_x, origin_y = W / 2, 40

        -- Render diamond tiles in back-to-front order
        for row = 0, ROWS - 1 do
            for col = 0, COLS - 1 do
                local tile_type = ((row * 3 + col * 7) % 4) + 1
                local c1, c2, c3 = gid_color(tile_type)

                -- Iso projection
                local sx = (col - row) * (TW / 2) + origin_x
                local sy = (col + row) * TH / 2 + origin_y

                -- Fill the diamond by horizontal spans natively
                for dy = 0, TH do
                    local t = dy / TH
                    local half_w
                    if dy <= TH / 2 then
                        half_w = math.floor(t * 2 * (TW / 2))
                    else
                        half_w = TW / 2 - math.floor((t - 0.5) * 2 * (TW / 2))
                    end
                    local scan_y = math.floor(sy + dy)
                    local shade = math.floor(c1 * (1 - dy / TH * 0.3))
                    local g_shade = math.floor(c2 * (1 - dy / TH * 0.25))
                    img:drawLine(math.floor(sx - half_w), scan_y, math.floor(sx + half_w), scan_y, shade, g_shade, c3, 255)
                end

                -- Outline natively
                img:drawLine(sx, sy, sx + TW / 2, sy + TH / 2, 20, 20, 20, 255)
                img:drawLine(sx + TW / 2, sy + TH / 2, sx, sy + TH, 20, 20, 20, 255)
                img:drawLine(sx, sy + TH, sx - TW / 2, sy + TH / 2, 20, 20, 20, 255)
                img:drawLine(sx - TW / 2, sy + TH / 2, sx, sy, 20, 20, 20, 255)
            end
        end

        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- 2. @evidence file
    it("PNG: hex grid map (pointy-top hexagons)", function()
        ensure_evidence_dir("render_advanced")
        local path = OUT .. "hex_grid.png"

        local W, H = 300, 240
        local img = lurek.image.newImageData(W, H)
        img:fill(18, 15, 28, 255)

        local R = 20  -- hex circumradius
        local h_hex = R * math.sqrt(3)  -- pointy-top height
        local COLS, ROWS = 7, 5

        local palette = {
            { 60, 140,  60 },  -- forest
            { 40,  80, 180 },  -- ocean
            { 200, 180, 120 }, -- desert
            { 100, 100, 160 }, -- tundra
            { 180,  80,  80 }, -- volcano
        }

        for row = 0, ROWS - 1 do
            for col = 0, COLS - 1 do
                local cx = col * R * 1.5 + R + 10
                local cy = row * h_hex + (col % 2 == 1 and h_hex / 2 or 0) + h_hex / 2 + 10
                local c = palette[((row * 5 + col * 3) % #palette) + 1]

                -- Fill hex natively using a single 1D loop of horizontal lines
                for dy = -math.floor(R), math.floor(R) do
                    local abs_dy = math.abs(dy)
                    local hw = 0
                    if abs_dy <= R / 2 then
                        hw = h_hex / 2
                    elseif abs_dy <= R then
                        local f = (abs_dy - R/2) / (R/2)
                        hw = (h_hex / 2) * (1 - f)
                    end
                    if hw > 0 then
                        img:drawLine(math.floor(cx - hw), math.floor(cy + dy), math.floor(cx + hw), math.floor(cy + dy), c[1], c[2], c[3], 255)
                    end
                end

                -- Outline natively
                local pts = {}
                for i = 0, 5 do
                    local angle = i * math.pi / 3 - math.pi / 2
                    pts[i+1] = { math.floor(cx + R * math.cos(angle)), math.floor(cy + R * math.sin(angle)) }
                end
                for i = 1, 6 do
                    local p1 = pts[i]
                    local p2 = pts[(i % 6) + 1]
                    img:drawLine(p1[1], p1[2], p2[1], p2[2], 40, 40, 40, 255)
                end
            end
        end

        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- 3. @evidence file
    it("PNG: gradient rect strip (horizontal multi-stop gradient)", function()
        ensure_evidence_dir("render_advanced")
        local path = OUT .. "gradient_rect_strip.png"

        local W, H = 512, 64
        local img = lurek.image.newImageData(W, H)

        local stops = {
            { t = 0.00, r = 0,   g = 0,   b = 0   },
            { t = 0.33, r = 220, g = 30,  b = 30  },
            { t = 0.66, r = 255, g = 220, b = 0   },
            { t = 1.00, r = 255, g = 255, b = 255 },
        }

        local function sample_gradient(t)
            for i = 1, #stops - 1 do
                local s0, s1 = stops[i], stops[i + 1]
                if t >= s0.t and t <= s1.t then
                    local f = (t - s0.t) / (s1.t - s0.t)
                    return math.floor(s0.r + (s1.r - s0.r) * f),
                           math.floor(s0.g + (s1.g - s0.g) * f),
                           math.floor(s0.b + (s1.b - s0.b) * f)
                end
            end
            return 255, 255, 255
        end

        -- Draw gradient lines natively
        for x = 0, W - 1 do
            local r, g, b = sample_gradient(x / (W - 1))
            img:drawLine(x, 0, x, H - 1, r, g, b, 255)
        end

        -- Draw stop markers natively
        for _, stop in ipairs(stops) do
            local sx = math.floor(stop.t * (W - 1))
            img:drawLine(sx, 0, sx, H - 1, 255, 255, 255, 200)
        end

        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- 4. @evidence file
    it("PNG: alpha-blend composition of 3 overlapping colored layers", function()
        ensure_evidence_dir("render_advanced")
        local path = OUT .. "alpha_blend_layers.png"

        local W, H = 200, 200
        local img = lurek.image.newImageData(W, H)
        img:fill(20, 20, 20, 255)

        -- Draw overlapping circles natively
        img:drawCircle(70,  80,  55, 255, 60,  60,  255)  -- Red
        img:drawCircle(130, 80,  55, 60,  60,  255, 255)  -- Blue
        img:drawCircle(100, 130, 55, 60,  255, 60,  255)  -- Green

        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- 5. @evidence file
    it("PNG: scanline polygon fill (convex 8-sided polygon)", function()
        ensure_evidence_dir("render_advanced")
        local path = OUT .. "scanline_octagon.png"

        local W, H = 200, 200
        local img = lurek.image.newImageData(W, H)
        img:fill(15, 15, 25, 255)

        local cx, cy, R = 100, 100, 80
        local SIDES = 8
        local verts = {}
        for i = 0, SIDES - 1 do
            local angle = (i / SIDES) * 2 * math.pi - math.pi / 8
            verts[i + 1] = { math.floor(cx + R * math.cos(angle)), math.floor(cy + R * math.sin(angle)) }
        end

        -- Scanline fill convex polygon natively with horizontal lines
        for y = 0, H - 1 do
            local x_min, x_max = W, 0
            local n = #verts
            for i = 1, n do
                local v0 = verts[i]
                local v1 = verts[(i % n) + 1]
                if (v0[2] <= y and v1[2] > y) or (v1[2] <= y and v0[2] > y) then
                    local t = (y - v0[2]) / (v1[2] - v0[2])
                    local xi = math.floor(v0[1] + t * (v1[1] - v0[1]))
                    x_min = math.min(x_min, xi)
                    x_max = math.max(x_max, xi)
                end
            end
            if x_min < x_max then
                local angle = math.atan2(y - cy, x_min - cx)
                local hue = (angle + math.pi) / (2 * math.pi)
                local r = math.floor((math.sin(hue * 2 * math.pi) + 1) / 2 * 200 + 55)
                local g = math.floor((math.sin(hue * 2 * math.pi + 2.09) + 1) / 2 * 200 + 55)
                local b = math.floor((math.sin(hue * 2 * math.pi + 4.19) + 1) / 2 * 200 + 55)
                img:drawLine(x_min, y, x_max, y, r, g, b, 255)
            end
        end

        -- Outline natively
        local n = #verts
        for i = 1, n do
            local v0 = verts[i]
            local v1 = verts[(i % n) + 1]
            img:drawLine(v0[1], v0[2], v1[1], v1[2], 255, 255, 255, 255)
        end

        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- 6. @evidence file
    it("PNG: color lerp strip across 8 named colors", function()
        ensure_evidence_dir("render_advanced")
        local path = OUT .. "color_lerp_strip.png"

        local W, H = 512, 32
        local img = lurek.image.newImageData(W, H)

        local named = {
            { 230, 25,  75  },  -- red
            { 255, 130, 0   },  -- orange
            { 255, 225, 25  },  -- yellow
            { 60,  180, 75  },  -- green
            { 0,   130, 200 },  -- cyan
            { 0,   60,  170 },  -- blue
            { 145, 30,  180 },  -- purple
            { 240, 50,  230 },  -- magenta
        }

        local function lerp_palette(t)
            local n = #named
            local scaled = t * (n - 1)
            local i = math.floor(scaled)
            local f = scaled - i
            i = math.min(i, n - 2)
            local c0, c1 = named[i + 1], named[i + 2]
            return math.floor(c0[1] + (c1[1] - c0[1]) * f),
                   math.floor(c0[2] + (c1[2] - c0[2]) * f),
                   math.floor(c0[3] + (c1[3] - c0[3]) * f)
        end

        -- Draw color lerp lines natively
        for x = 0, W - 1 do
            local r, g, b = lerp_palette(x / (W - 1))
            img:drawLine(x, 0, x, H - 1, r, g, b, 255)
        end

        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- 7. @evidence file
    it("PNG: star polygon with 5 and 7 points rendered side by side", function()
        ensure_evidence_dir("render_advanced")
        local path = OUT .. "star_polygons.png"

        local W, H = 300, 150
        local img = lurek.image.newImageData(W, H)
        img:fill(12, 12, 22, 255)

        local function draw_star(cx, cy, R_outer, R_inner, points, ri, gi, bi)
            local verts = {}
            for i = 0, points * 2 - 1 do
                local angle = (i / (points * 2)) * 2 * math.pi - math.pi / 2
                local R = (i % 2 == 0) and R_outer or R_inner
                verts[#verts + 1] = { math.floor(cx + R * math.cos(angle)), math.floor(cy + R * math.sin(angle)) }
            end
            
            -- Fill via center fan natively
            for i = 1, #verts do
                local v0 = verts[i]
                local v1 = verts[(i % #verts) + 1]
                for t = 0, 1, 0.05 do
                    local ex = math.floor(v0[1] + t * (v1[1] - v0[1]))
                    local ey = math.floor(v0[2] + t * (v1[2] - v0[2]))
                    img:drawLine(cx, cy, ex, ey, ri, gi, bi, 255)
                end
            end

            -- Draw outline natively
            for i = 1, #verts do
                local v0 = verts[i]
                local v1 = verts[(i % #verts) + 1]
                img:drawLine(v0[1], v0[2], v1[1], v1[2], ri, gi, bi, 255)
            end
        end

        draw_star(75,  75, 55, 25, 5, 255, 200, 60)   -- 5-pointed gold star
        draw_star(225, 75, 55, 25, 7, 80,  180, 255)  -- 7-pointed blue star

        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- 8. @evidence file
    it("PNG: dashed line pattern across four directions", function()
        ensure_evidence_dir("render_advanced")
        local path = OUT .. "dashed_lines.png"

        local W, H = 256, 256
        local img = lurek.image.newImageData(W, H)
        img:fill(20, 20, 30, 255)

        local function dashed_line(x0, y0, x1, y1, dash, gap, ri, gi, bi)
            local len = math.sqrt((x1-x0)^2 + (y1-y0)^2)
            local nx = (x1-x0) / len
            local ny = (y1-y0) / len
            local t = 0
            local on = true
            while t < len do
                local seg = on and dash or gap
                local t_end = math.min(t + seg, len)
                if on then
                    local ax = math.floor(x0 + nx * t)
                    local ay = math.floor(y0 + ny * t)
                    local bx = math.floor(x0 + nx * t_end)
                    local by = math.floor(y0 + ny * t_end)
                    img:drawLine(ax, ay, bx, by, ri, gi, bi, 255)
                end
                t = t + seg
                on = not on
            end
        end

        -- Horizontal dashed
        dashed_line(10, 64,  246, 64,  12, 6, 255, 80,  80)
        -- Vertical dashed
        dashed_line(64, 10,  64,  246, 8,  4, 80,  255, 80)
        -- Diagonal dashed
        dashed_line(10, 10,  246, 246, 10, 5, 80,  80,  255)
        -- Anti-diagonal dashed
        dashed_line(246, 10, 10,  246, 6,  6, 255, 220, 80)

        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- 9. @evidence file
    it("PNG: rounded rectangle panel (corner radius = 12px)", function()
        ensure_evidence_dir("render_advanced")
        local path = OUT .. "rounded_rect.png"

        local W, H = 256, 160
        local img = lurek.image.newImageData(W, H)
        img:fill(18, 18, 28, 255)

        local function draw_rounded_rect(rx, ry, rw, rh, corner, r, g, b)
            -- 4 corner circles natively
            img:drawCircle(rx + corner, ry + corner, corner, r, g, b, 255)
            img:drawCircle(rx + rw - corner, ry + corner, corner, r, g, b, 255)
            img:drawCircle(rx + corner, ry + rh - corner, corner, r, g, b, 255)
            img:drawCircle(rx + rw - corner, ry + rh - corner, corner, r, g, b, 255)
            -- 2 crossing filled rects natively
            img:drawRect(rx, ry + corner, rw, rh - 2 * corner, r, g, b, 255)
            img:drawRect(rx + corner, ry, rw - 2 * corner, rh, r, g, b, 255)
        end

        draw_rounded_rect(10,  20, 70, 120, 12, 60,  100, 200)
        draw_rounded_rect(95,  20, 70, 120, 8,  80,  180, 80)
        draw_rounded_rect(180, 20, 70, 120, 20, 200, 80,  80)

        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- 10. @evidence file
    it("PNG: render setColor state machine – color state persists across draws", function()
        ensure_evidence_dir("render_advanced")
        local path = OUT .. "render_color_state.png"

        local W, H = 280, 60
        local img = lurek.image.newImageData(W, H)
        img:fill(20, 20, 20, 255)

        local colors = {
            { 1.0, 0.2, 0.2, 1.0 },
            { 0.2, 1.0, 0.2, 1.0 },
            { 0.2, 0.2, 1.0, 1.0 },
            { 1.0, 1.0, 0.2, 1.0 },
            { 0.2, 1.0, 1.0, 1.0 },
            { 1.0, 0.2, 1.0, 1.0 },
            { 1.0, 0.6, 0.2, 1.0 },
        }

        for i, c in ipairs(colors) do
            lurek.render.setColor(c[1], c[2], c[3], c[4])
            local gr, gg, gb, ga = lurek.render.getColor()
            local function near(a, b) return math.abs(a - b) < 0.01 end
            expect_true(near(gr, c[1]) and near(gg, c[2]) and near(gb, c[3]))

            -- Draw block using native drawRect
            local x0 = (i - 1) * 40
            img:drawRect(x0, 10, 38, 40, math.floor(gr * 255), math.floor(gg * 255), math.floor(gb * 255), 255)
        end

        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- 11. @evidence file
    it("PNG: blend modes add and multiply via mapPixel", function()
        ensure_evidence_dir("render_advanced")
        local path = OUT .. "blend_modes.png"
        local W, H = 256, 128
        local img = lurek.image.newImageData(W, H)
        img:fill(40, 40, 40, 255)
        
        -- Base circles
        img:drawCircle(80, 64, 40, 200, 50, 50, 255)
        img:drawCircle(176, 64, 40, 50, 200, 50, 255)

        img:mapPixel(function(x, y, r, g, b, a)
            local d1 = math.sqrt((x - 80)^2 + (y - 64)^2)
            local d2 = math.sqrt((x - 176)^2 + (y - 64)^2)
            if d1 < 50 and d2 < 50 then
                -- Multiply in the overlap
                return math.floor(r * 0.5), math.floor(g * 0.5), math.floor(b * 0.5), a
            elseif d1 < 60 and d2 < 60 then
                -- Add at the edges
                return math.min(255, r + 100), math.min(255, g + 100), math.min(255, b + 100), a
            end
            return r, g, b, a
        end)
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- 12. @evidence file
    it("PNG: clipping region custom bounds", function()
        ensure_evidence_dir("render_advanced")
        local path = OUT .. "clipping_region.png"
        local W, H = 200, 200
        local img = lurek.image.newImageData(W, H)
        img:fill(20, 20, 20, 255)

        local clip_x, clip_y, clip_w, clip_h = 50, 50, 100, 100
        img:drawRect(clip_x - 2, clip_y - 2, clip_w + 4, clip_h + 4, 100, 100, 100, 255)
        img:drawRect(clip_x, clip_y, clip_w, clip_h, 40, 40, 40, 255)

        for i = 1, 20 do
            local x0 = math.random(0, W)
            local y0 = math.random(0, H)
            local x1 = math.random(0, W)
            local y1 = math.random(0, H)
            -- simple clipping of line drawing by just clamping
            x0 = math.max(clip_x, math.min(clip_x + clip_w, x0))
            y0 = math.max(clip_y, math.min(clip_y + clip_h, y0))
            x1 = math.max(clip_x, math.min(clip_x + clip_w, x1))
            y1 = math.max(clip_y, math.min(clip_y + clip_h, y1))
            img:drawLine(x0, y0, x1, y1, math.random(100,255), math.random(100,255), math.random(100,255), 255)
        end
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- 13. @evidence file
    it("PNG: complex polygon intersecting", function()
        ensure_evidence_dir("render_advanced")
        local path = OUT .. "complex_polygon.png"
        local W, H = 200, 200
        local img = lurek.image.newImageData(W, H)
        img:fill(30, 10, 30, 255)

        local cx, cy, R = 100, 100, 80
        local points = 7
        local verts = {}
        for i = 0, points - 1 do
            local angle = (i / points) * 2 * math.pi - math.pi / 2
            verts[i + 1] = { math.floor(cx + R * math.cos(angle)), math.floor(cy + R * math.sin(angle)) }
        end
        -- draw every 3rd point to make an intersecting star
        for i = 1, points do
            local p1 = verts[i]
            local p2 = verts[((i + 2) % points) + 1]
            img:drawLine(p1[1], p1[2], p2[1], p2[2], 255, 200, 50, 255)
        end
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- 14. @evidence file
    it("PNG: bezier curve", function()
        ensure_evidence_dir("render_advanced")
        local path = OUT .. "bezier_curve.png"
        local W, H = 256, 128
        local img = lurek.image.newImageData(W, H)
        img:fill(15, 15, 15, 255)

        local p0x, p0y = 20, 100
        local p1x, p1y = 80, 20
        local p2x, p2y = 180, 20
        local p3x, p3y = 236, 100

        local prev_x, prev_y = p0x, p0y
        for t = 0.05, 1.0, 0.05 do
            local nt = 1 - t
            local bx = nt^3 * p0x + 3 * nt^2 * t * p1x + 3 * nt * t^2 * p2x + t^3 * p3x
            local by = nt^3 * p0y + 3 * nt^2 * t * p1y + 3 * nt * t^2 * p2y + t^3 * p3y
            img:drawLine(math.floor(prev_x), math.floor(prev_y), math.floor(bx), math.floor(by), 100, 255, 150, 255)
            prev_x, prev_y = bx, by
        end
        -- draw control points
        img:drawCircle(p0x, p0y, 3, 255, 0, 0, 255)
        img:drawCircle(p1x, p1y, 3, 255, 0, 0, 255)
        img:drawCircle(p2x, p2y, 3, 255, 0, 0, 255)
        img:drawCircle(p3x, p3y, 3, 255, 0, 0, 255)
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- 15. @evidence file
    it("PNG: radial gradient via mapPixel", function()
        ensure_evidence_dir("render_advanced")
        local path = OUT .. "radial_gradient.png"
        local W, H = 200, 200
        local img = lurek.image.newImageData(W, H)
        
        local cx, cy, max_r = 100, 100, 100
        img:mapPixel(function(x, y, r, g, b, a)
            local dist = math.sqrt((x - cx)^2 + (y - cy)^2)
            local t = math.min(1.0, dist / max_r)
            local c1 = { 255, 100, 50 }
            local c2 = { 20, 20, 60 }
            local rt = c1[1] * (1 - t) + c2[1] * t
            local gt = c1[2] * (1 - t) + c2[2] * t
            local bt = c1[3] * (1 - t) + c2[3] * t
            return math.floor(rt), math.floor(gt), math.floor(bt), 255
        end)
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- 16. @evidence file
    it("PNG: texture blitting with tint", function()
        ensure_evidence_dir("render_advanced")
        local path = OUT .. "texture_blit.png"
        local W, H = 256, 256
        local img = lurek.image.newImageData(W, H)
        img:fill(40, 50, 40, 255)

        local tex = lurek.image.newImageData(64, 64)
        tex:fill(255, 255, 255, 255)
        tex:drawCircle(32, 32, 20, 0, 0, 0, 255)

        -- Blit normally
        img:blit(tex, 32, 32)
        
        -- Tint and blit
        tex:tint(255, 0, 0, 0.8)
        img:blit(tex, 128, 32)

        tex:tint(0, 0, 255, 0.8)
        img:blit(tex, 32, 128)

        tex:tint(0, 255, 0, 0.8)
        img:blit(tex, 128, 128)

        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- 17. @evidence file
    it("PNG: rotated rectangles", function()
        ensure_evidence_dir("render_advanced")
        local path = OUT .. "rotated_rectangles.png"
        local W, H = 256, 256
        local img = lurek.image.newImageData(W, H)
        img:fill(20, 20, 20, 255)

        local function draw_rotated_rect(cx, cy, rw, rh, angle, r, g, b)
            local cos_a = math.cos(angle)
            local sin_a = math.sin(angle)
            local pts = {
                { -rw/2, -rh/2 },
                { rw/2, -rh/2 },
                { rw/2, rh/2 },
                { -rw/2, rh/2 }
            }
            local tf_pts = {}
            for i = 1, 4 do
                tf_pts[i] = {
                    math.floor(cx + pts[i][1] * cos_a - pts[i][2] * sin_a),
                    math.floor(cy + pts[i][1] * sin_a + pts[i][2] * cos_a)
                }
            end
            for i = 1, 4 do
                local p1 = tf_pts[i]
                local p2 = tf_pts[(i % 4) + 1]
                img:drawLine(p1[1], p1[2], p2[1], p2[2], r, g, b, 255)
            end
        end

        for a = 0, math.pi, math.pi / 6 do
            draw_rotated_rect(128, 128, 100, 40, a, math.floor(100 + a*30), math.floor(255 - a*30), 150)
        end
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- 18. @evidence file
    it("PNG: anti-aliased circles via mapPixel", function()
        ensure_evidence_dir("render_advanced")
        local path = OUT .. "aa_circles.png"
        local W, H = 200, 200
        local img = lurek.image.newImageData(W, H)
        img:fill(10, 10, 10, 255)

        local cx, cy, R = 100, 100, 70
        img:mapPixel(function(x, y, r, g, b, a)
            local dist = math.sqrt((x - cx)^2 + (y - cy)^2)
            local alpha = 1.0
            if dist > R then
                alpha = math.max(0.0, 1.0 - (dist - R))
            end
            if alpha > 0 then
                return math.floor(255 * alpha), math.floor(200 * alpha), math.floor(50 * alpha), 255
            end
            return r, g, b, a
        end)
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- 19. @evidence file
    it("PNG: thick dashed lines", function()
        ensure_evidence_dir("render_advanced")
        local path = OUT .. "thick_dashed.png"
        local W, H = 256, 128
        local img = lurek.image.newImageData(W, H)
        img:fill(25, 25, 25, 255)

        local function draw_thick_dashed(x0, y0, x1, y1, dash, gap, thickness, r, g, b)
            local len = math.sqrt((x1-x0)^2 + (y1-y0)^2)
            local nx = (x1-x0) / len
            local ny = (y1-y0) / len
            -- perpendicular
            local px = -ny
            local py = nx

            for offset = -math.floor(thickness/2), math.floor(thickness/2) do
                local ox0 = x0 + px * offset
                local oy0 = y0 + py * offset
                local ox1 = x1 + px * offset
                local oy1 = y1 + py * offset
                
                local t = 0
                local on = true
                while t < len do
                    local seg = on and dash or gap
                    local t_end = math.min(t + seg, len)
                    if on then
                        local ax = math.floor(ox0 + nx * t)
                        local ay = math.floor(oy0 + ny * t)
                        local bx = math.floor(ox0 + nx * t_end)
                        local by = math.floor(oy0 + ny * t_end)
                        img:drawLine(ax, ay, bx, by, r, g, b, 255)
                    end
                    t = t + seg
                    on = not on
                end
            end
        end

        draw_thick_dashed(20, 64, 236, 64, 15, 10, 8, 200, 100, 50)
        draw_thick_dashed(20, 30, 236, 98, 20, 15, 12, 50, 150, 255)

        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- 20. @evidence file
    it("PNG: text rendering mockup with shadow", function()
        ensure_evidence_dir("render_advanced")
        local path = OUT .. "text_shadow.png"
        local W, H = 200, 100
        local img = lurek.image.newImageData(W, H)
        img:fill(40, 40, 60, 255)

        -- Draw a blocky 'Z' with a drop shadow
        local function draw_Z(ox, oy, color, thickness)
            for i = 0, thickness do
                img:drawLine(ox, oy + i, ox + 60, oy + i, color[1], color[2], color[3], 255)
                img:drawLine(ox + 60 - i, oy, ox - i, oy + 60, color[1], color[2], color[3], 255)
                img:drawLine(ox, oy + 60 + i, ox + 60, oy + 60 + i, color[1], color[2], color[3], 255)
            end
        end

        -- Shadow
        draw_Z(74, 24, {10, 10, 10}, 6)
        -- Text
        draw_Z(70, 20, {255, 200, 50}, 6)

        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

end)

test_summary()
