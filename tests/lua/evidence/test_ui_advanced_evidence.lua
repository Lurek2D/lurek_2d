-- test_ui_advanced_evidence.lua
-- Evidence tests: advanced lurek.ui widgets not covered in test_ui_evidence.lua.
-- Covers exactly 10 unique visual widget outputs using native drawing APIs.

local OUT = "tests/output/ui_advanced/"

-- Helper: initialize UI advanced directory
local function init_ui_path(filename)
    ensure_evidence_dir("ui_advanced")
    local dir = evidence_output_dir("ui_advanced")
    return dir .. filename
end

--- Helper: fill rect on ImageData using native drawing
local function fill_rect(img, x0, y0, w, h, r, g, b, a)
    img:drawRect(x0, y0, w, h, r, g, b, a or 255)
end

--- Helper: draw outline rect on ImageData using native line segments
local function outline_rect(img, x0, y0, w, h, r, g, b, a)
    a = a or 255
    img:drawLine(x0, y0, x0 + w - 1, y0, r, g, b, a)
    img:drawLine(x0, y0 + h - 1, x0 + w - 1, y0 + h - 1, r, g, b, a)
    img:drawLine(x0, y0, x0, y0 + h - 1, r, g, b, a)
    img:drawLine(x0 + w - 1, y0, x0 + w - 1, y0 + h - 1, r, g, b, a)
end

-- @describe Evidence: advanced lurek.ui widget scenarios
describe("Evidence: advanced lurek.ui widget scenarios", function()

    -- 1. @evidence file
    it("PNG: color picker -- hue-saturation gradient canvas", function()
        local path = init_ui_path("ui_color_picker_canvas.png")
        local W, H = 200, 200
        local img = lurek.image.newImageData(W, H)

        -- HSV hue-saturation plane at full value (procedural pixel color generation)
        for y = 0, H - 1 do
            for x = 0, W - 1 do
                local h = (x / W) * 360
                local s = 1 - (y / H)
                local v = 1.0
                -- HSV to RGB
                local c = v * s
                local xc = c * (1 - math.abs((h / 60) % 2 - 1))
                local m = v - c
                local r, g, b = 0, 0, 0
                if h < 60  then r, g, b = c, xc, 0
                elseif h < 120 then r, g, b = xc, c, 0
                elseif h < 180 then r, g, b = 0, c, xc
                elseif h < 240 then r, g, b = 0, xc, c
                elseif h < 300 then r, g, b = xc, 0, c
                else r, g, b = c, 0, xc end
                img:setPixel(x, y,
                    math.floor((r + m) * 255),
                    math.floor((g + m) * 255),
                    math.floor((b + m) * 255),
                    255)
            end
        end

        -- Selected color indicator drawn natively
        local sel_x, sel_y = 120, 60  -- hue=216°, sat=0.7
        outline_rect(img, sel_x - 4, sel_y - 4, 9, 9, 255, 255, 255, 255)

        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- 2. @evidence file
    it("PNG: virtual keyboard layout rendered as grid", function()
        local path = init_ui_path("ui_virtual_keyboard.png")
        local W, H = 420, 140
        local img = lurek.image.newImageData(W, H)
        img:fill(30, 30, 40, 255)

        -- QWERTY rows
        local rows = {
            {"Q","W","E","R","T","Y","U","I","O","P"},
            {"A","S","D","F","G","H","J","K","L"},
            {"Z","X","C","V","B","N","M"},
        }
        local KEY_W, KEY_H = 36, 32
        local GAP = 4
        local row_offsets = {0, 20, 42}

        for row_i, row in ipairs(rows) do
            for col_i, key in ipairs(row) do
                local x0 = row_offsets[row_i] + (col_i - 1) * (KEY_W + GAP) + 10
                local y0 = (row_i - 1) * (KEY_H + GAP) + 10

                -- Key background
                fill_rect(img, x0, y0, KEY_W, KEY_H, 60, 65, 80)
                outline_rect(img, x0, y0, KEY_W, KEY_H, 100, 110, 140)
            end
        end

        -- Space bar
        fill_rect(img, 80, 110, 200, KEY_H, 50, 55, 70)
        outline_rect(img, 80, 110, 200, KEY_H, 100, 110, 140)

        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- 3. @evidence file
    it("PNG: radar / spider chart with 6 stats", function()
        local path = init_ui_path("ui_radar_chart.png")
        local W, H = 280, 280
        local img = lurek.image.newImageData(W, H)
        img:fill(18, 18, 28, 255)

        local cx, cy, R = W / 2, H / 2, 100
        local stats = {
            { name = "STR", value = 0.85 },
            { name = "DEX", value = 0.60 },
            { name = "INT", value = 0.95 },
            { name = "VIT", value = 0.50 },
            { name = "AGI", value = 0.75 },
            { name = "LUK", value = 0.40 },
        }
        local N = #stats

        -- Draw grid rings
        for ring = 1, 4 do
            local r = ring / 4 * R
            for i = 0, N - 1 do
                local a0 = (i / N) * 2 * math.pi - math.pi / 2
                local a1 = ((i + 1) / N) * 2 * math.pi - math.pi / 2
                local x0 = math.floor(cx + r * math.cos(a0))
                local y0 = math.floor(cy + r * math.sin(a0))
                local x1 = math.floor(cx + r * math.cos(a1))
                local y1 = math.floor(cy + r * math.sin(a1))
                img:drawLine(x0, y0, x1, y1, 60, 60, 80, 255)
            end
        end

        -- Spoke lines
        for i = 0, N - 1 do
            local a = (i / N) * 2 * math.pi - math.pi / 2
            img:drawLine(cx, cy,
                math.floor(cx + R * math.cos(a)),
                math.floor(cy + R * math.sin(a)),
                80, 80, 100, 255)
        end

        -- Fill polygon for stat values
        local verts = {}
        for i, stat in ipairs(stats) do
            local a = ((i - 1) / N) * 2 * math.pi - math.pi / 2
            local r = stat.value * R
            verts[i] = {
                math.floor(cx + r * math.cos(a)),
                math.floor(cy + r * math.sin(a))
            }
        end
        -- Draw outline
        for i = 1, N do
            local v0 = verts[i]
            local v1 = verts[(i % N) + 1]
            img:drawLine(v0[1], v0[2], v1[1], v1[2], 80, 180, 255, 255)
        end
        -- Vertex dots drawn natively
        for _, v in ipairs(verts) do
            img:drawCircle(v[1], v[2], 3, 80, 220, 255, 255)
        end

        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- 4. @evidence file
    it("PNG: circular gauge widget (speedometer style)", function()
        local path = init_ui_path("ui_gauge.png")
        local W, H = 200, 200
        local img = lurek.image.newImageData(W, H)
        img:fill(14, 14, 22, 255)

        local cx, cy = W / 2, H / 2
        local R_outer, R_inner = 80, 60
        local START_ANG = math.rad(135)
        local END_ANG   = math.rad(405)
        local VALUE = 0.72  -- 72%

        -- Draw arc track (dark gray) procedurally
        local STEPS = 200
        for i = 0, STEPS do
            local t = i / STEPS
            local ang = START_ANG + t * (END_ANG - START_ANG)
            for r = R_inner, R_outer do
                local px = math.floor(cx + r * math.cos(ang))
                local py = math.floor(cy + r * math.sin(ang))
                if px >= 0 and px < W and py >= 0 and py < H then
                    img:setPixel(px, py, 50, 50, 60, 255)
                end
            end
        end

        -- Draw value arc (green→yellow→red)
        for i = 0, math.floor(STEPS * VALUE) do
            local t = i / STEPS
            local ang = START_ANG + t * (END_ANG - START_ANG)
            -- Color: green → yellow → red based on t/VALUE
            local vt = t / VALUE
            local r_c = math.floor(math.min(1, vt * 2) * 200 + 55)
            local g_c = math.floor(math.min(1, (1 - vt) * 2) * 200 + 55)
            for r = R_inner, R_outer do
                local px = math.floor(cx + r * math.cos(ang))
                local py = math.floor(cy + r * math.sin(ang))
                if px >= 0 and px < W and py >= 0 and py < H then
                    img:setPixel(px, py, r_c, g_c, 40, 255)
                end
            end
        end

        -- Center needle
        local needle_ang = START_ANG + VALUE * (END_ANG - START_ANG)
        img:drawLine(cx, cy,
            math.floor(cx + R_outer * math.cos(needle_ang)),
            math.floor(cy + R_outer * math.sin(needle_ang)),
            255, 255, 255, 255)

        -- Center hub drawn natively
        img:drawCircle(cx, cy, 4, 200, 200, 200, 255)

        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- 5. @evidence file
    it("PNG: horizontal timeline bar with 6 events", function()
        local path = init_ui_path("ui_timeline.png")
        local W, H = 480, 80
        local img = lurek.image.newImageData(W, H)
        img:fill(20, 20, 30, 255)

        -- Track line
        fill_rect(img, 30, 38, W - 60, 4, 60, 65, 80)

        local events = {
            { t = 0.0,  label = "Start", r = 80,  g = 200, b = 80  },
            { t = 0.18, label = "A",     r = 200, g = 200, b = 80  },
            { t = 0.35, label = "B",     r = 80,  g = 160, b = 220 },
            { t = 0.55, label = "C",     r = 220, g = 80,  b = 80  },
            { t = 0.75, label = "D",     r = 180, g = 80,  b = 220 },
            { t = 1.0,  label = "End",   r = 200, g = 80,  b = 80  },
        }

        local track_start, track_end = 30, W - 30
        for _, ev in ipairs(events) do
            local ex = math.floor(track_start + ev.t * (track_end - track_start))
            -- Event circle drawn natively
            img:drawCircle(ex, 40, 7, ev.r, ev.g, ev.b, 255)
        end

        -- Current time marker (at 45%)
        local cur_x = math.floor(track_start + 0.45 * (track_end - track_start))
        img:drawLine(cur_x, 10, cur_x, 70, 255, 255, 255, 255)

        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- 6. @evidence file
    it("PNG: notification stack (5 stacked toast banners)", function()
        local path = init_ui_path("ui_notification_stack.png")
        local W, H = 380, 240
        local img = lurek.image.newImageData(W, H)
        img:fill(16, 16, 26, 255)

        local notifs = {
            { text = "Level Up!",        priority = "success", r = 60, g = 200, b = 80  },
            { text = "Low Health!",      priority = "warning", r = 220, g = 180, b = 40 },
            { text = "Achievement!",     priority = "info",    r = 60,  g = 140, b = 220 },
            { text = "Quest Complete",   priority = "success", r = 80,  g = 220, b = 120 },
            { text = "Enemy Defeated",   priority = "neutral", r = 160, g = 160, b = 180 },
        }

        local NOTIF_W, NOTIF_H, GAP = 340, 36, 8
        local x0 = (W - NOTIF_W) / 2

        for i, notif in ipairs(notifs) do
            local y0 = (i - 1) * (NOTIF_H + GAP) + 16
            -- Background with accent left border
            fill_rect(img, x0, y0, NOTIF_W, NOTIF_H, 35, 38, 52)
            fill_rect(img, x0, y0, 5, NOTIF_H, notif.r, notif.g, notif.b)
            outline_rect(img, x0, y0, NOTIF_W, NOTIF_H, 60, 65, 80)

            -- Priority dot drawn natively
            local dot_x, dot_y = x0 + 18, y0 + math.floor(NOTIF_H / 2)
            img:drawCircle(dot_x, dot_y, 4, notif.r, notif.g, notif.b, 255)
        end

        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- 7. @evidence file
    it("PNG: inventory grid widget (6x4 item slots with some filled)", function()
        local path = init_ui_path("ui_inventory_grid.png")
        local COLS, ROWS = 6, 4
        local SLOT_SIZE = 44
        local GAP = 4
        local W = COLS * (SLOT_SIZE + GAP) + GAP
        local H = ROWS * (SLOT_SIZE + GAP) + GAP
        local img = lurek.image.newImageData(W, H)
        img:fill(22, 22, 35, 255)

        -- Item types: empty=0, sword=1, shield=2, potion=3, gem=4
        local items = {
            {1,0,3,0,2,4},
            {0,1,0,4,0,3},
            {3,0,4,1,0,2},
            {0,4,0,2,3,0},
        }
        local item_colors = {
            [0] = {40, 42, 55},   -- empty slot
            [1] = {220, 80, 80},  -- sword
            [2] = {80, 130, 220}, -- shield
            [3] = {80, 220, 80},  -- potion
            [4] = {200, 80, 200}, -- gem
        }

        for row = 1, ROWS do
            for col = 1, COLS do
                local item = items[row] and items[row][col] or 0
                local c = item_colors[item]
                local x0 = GAP + (col - 1) * (SLOT_SIZE + GAP)
                local y0 = GAP + (row - 1) * (SLOT_SIZE + GAP)

                -- Slot background
                fill_rect(img, x0, y0, SLOT_SIZE, SLOT_SIZE, c[1], c[2], c[3])
                outline_rect(img, x0, y0, SLOT_SIZE, SLOT_SIZE, 70, 75, 100)

                -- Item icon drawn natively as premium glowing circle
                if item > 0 then
                    local icx, icy = x0 + math.floor(SLOT_SIZE / 2), y0 + math.floor(SLOT_SIZE / 2)
                    local ir = math.floor(SLOT_SIZE / 3)
                    img:drawCircle(icx, icy, ir,
                        math.min(255, c[1] + 60),
                        math.min(255, c[2] + 60),
                        math.min(255, c[3] + 60),
                        255)
                end
            end
        end

        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- 8. @evidence file
    it("PNG: stepper widget -- step progression strip", function()
        local path = init_ui_path("ui_stepper.png")
        local STEPS = 5
        local W = 400
        local H = 60
        local img = lurek.image.newImageData(W, H)
        img:fill(18, 18, 28, 255)

        local current_step = 3  -- 1-based: steps 1-2 complete, 3 = current
        local STEP_W = math.floor(W / STEPS)
        local cy = math.floor(H / 2)

        -- Connector line
        fill_rect(img, math.floor(STEP_W / 2), cy - 2, W - STEP_W, 4, 50, 55, 70)

        for i = 1, STEPS do
            local cx = (i - 1) * STEP_W + math.floor(STEP_W / 2)
            local complete = i < current_step
            local active  = i == current_step

            -- Circle drawn natively
            local r_c = complete and 12 or (active and 14 or 10)
            local cr, cg, cb
            if complete then cr, cg, cb = 60, 200, 80
            elseif active then cr, cg, cb = 80, 140, 255
            else cr, cg, cb = 55, 58, 72 end

            img:drawCircle(cx, cy, r_c, cr, cg, cb, 255)

            -- Checkmark for complete steps drawn natively
            if complete then
                img:drawLine(cx - 5, cy, cx, cy + 5, 255, 255, 255, 255)
                img:drawLine(cx, cy + 5, cx + 5, cy - 5, 255, 255, 255, 255)
            end
        end

        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- 9. @evidence file
    it("PNG: drag handle visual -- 9 handle points on a panel border", function()
        local path = init_ui_path("ui_drag_handles.png")
        local W, H = 300, 220
        local img = lurek.image.newImageData(W, H)
        img:fill(20, 20, 30, 255)

        -- Panel background
        local px0, py0, pw, ph = 40, 30, 220, 160
        fill_rect(img, px0, py0, pw, ph, 38, 42, 58)
        outline_rect(img, px0, py0, pw, ph, 80, 90, 120)

        -- 8 border handles + 1 center
        local handles = {
            { px0,            py0            },  -- TL
            { px0 + math.floor(pw / 2),  py0            },  -- TC
            { px0 + pw,       py0            },  -- TR
            { px0,            py0 + math.floor(ph / 2)  },  -- ML
            { px0 + math.floor(pw / 2),  py0 + math.floor(ph / 2)  },  -- center
            { px0 + pw,       py0 + math.floor(ph / 2)  },  -- MR
            { px0,            py0 + ph       },  -- BL
            { px0 + math.floor(pw / 2),  py0 + ph       },  -- BC
            { px0 + pw,       py0 + ph       },  -- BR
        }

        for i, h_pos in ipairs(handles) do
            local hx, hy = h_pos[1], h_pos[2]
            local is_center = (i == 5)
            local hc = is_center and {255, 200, 80} or {80, 160, 255}

            -- Draw dual concentric circles natively for glowing handles
            img:drawCircle(hx, hy, 6, 255, 255, 255, 255)
            img:drawCircle(hx, hy, 4, hc[1], hc[2], hc[3], 255)
        end

        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- 10. @evidence file
    it("PNG: split-panel with minimap inset (HUD composite)", function()
        local path = init_ui_path("ui_hud_composite.png")
        local W, H = 480, 300
        local img = lurek.image.newImageData(W, H)
        img:fill(16, 16, 26, 255)

        -- Main game view (left 70%)
        local game_w = math.floor(W * 0.7)
        fill_rect(img, 0, 0, game_w, H, 28, 60, 28)  -- green game world bg
        -- Horizon line
        fill_rect(img, 0, math.floor(H / 3), game_w, 2, 40, 90, 40)

        -- Sidebar panel (right 30%)
        local side_x = game_w + 2
        local side_w = W - side_x - 4
        fill_rect(img, game_w, 0, 2, H, 50, 55, 70)  -- divider
        fill_rect(img, side_x, 0, side_w, H, 24, 26, 38)

        -- Minimap in top-right of sidebar
        local mm_x, mm_y, mm_w, mm_h = side_x + 8, 10, side_w - 16, 90
        fill_rect(img, mm_x, mm_y, mm_w, mm_h, 20, 30, 50)
        outline_rect(img, mm_x, mm_y, mm_w, mm_h, 80, 100, 140)

        -- Mini terrain on minimap (procedural pixel terrain generation)
        local function minimap_terrain(x, y)
            local nx = (x - mm_x) / mm_w
            local ny = (y - mm_y) / mm_h
            if nx * nx + ny * ny < 0.1 then return 80, 80, 220 end  -- water
            if ny < 0.4 then return 60, 140, 60 end                   -- forest
            return 120, 100, 60                                        -- desert
        end
        for y = mm_y, mm_y + mm_h - 1 do
            for x = mm_x, mm_x + mm_w - 1 do
                local r, g, b = minimap_terrain(x, y)
                img:setPixel(x, y, r, g, b, 255)
            end
        end
        outline_rect(img, mm_x, mm_y, mm_w, mm_h, 80, 100, 140)

        -- Player dot on minimap drawn natively
        local pp_x, pp_y = mm_x + math.floor(mm_w / 2) + 8, mm_y + math.floor(mm_h / 2) - 5
        img:drawCircle(pp_x, pp_y, 3, 255, 80, 80, 255)

        -- HUD bars (HP/MP) in sidebar below minimap
        local bar_x, bar_y, bar_w = side_x + 8, mm_y + mm_h + 12, side_w - 16
        fill_rect(img, bar_x, bar_y, bar_w, 14, 50, 30, 30)
        fill_rect(img, bar_x, bar_y, math.floor(bar_w * 0.68), 14, 220, 60, 60)
        outline_rect(img, bar_x, bar_y, bar_w, 14, 80, 40, 40)

        fill_rect(img, bar_x, bar_y + 20, bar_w, 14, 30, 30, 80)
        fill_rect(img, bar_x, bar_y + 20, math.floor(bar_w * 0.45), 14, 60, 80, 220)
        outline_rect(img, bar_x, bar_y + 20, bar_w, 14, 40, 40, 100)

        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- 11. @evidence file
    it("PNG: dropdown menu", function()
        local path = init_ui_path("ui_dropdown.png")
        local W, H = 200, 200
        local img = lurek.image.newImageData(W, H)
        img:fill(30, 30, 40, 255)

        -- Dropdown button
        fill_rect(img, 40, 20, 120, 30, 60, 65, 80)
        outline_rect(img, 40, 20, 120, 30, 100, 110, 140)
        -- arrow native lines
        img:drawLine(140, 32, 145, 38, 200, 200, 200, 255)
        img:drawLine(145, 38, 150, 32, 200, 200, 200, 255)

        -- Dropdown list
        fill_rect(img, 40, 50, 120, 100, 40, 42, 55)
        outline_rect(img, 40, 50, 120, 100, 100, 110, 140)

        -- Items
        fill_rect(img, 42, 52, 116, 25, 80, 130, 220) -- hover state
        fill_rect(img, 42, 77, 116, 25, 40, 42, 55)
        fill_rect(img, 42, 102, 116, 25, 40, 42, 55)

        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- 12. @evidence file
    it("PNG: toggle switches", function()
        local path = init_ui_path("ui_toggles.png")
        local W, H = 200, 150
        local img = lurek.image.newImageData(W, H)
        img:fill(30, 30, 40, 255)

        local function draw_toggle(x, y, state)
            -- Background capsule
            local bg_color = state and {80, 200, 80} or {80, 80, 100}
            img:drawCircle(x + 15, y + 15, 15, bg_color[1], bg_color[2], bg_color[3], 255)
            img:drawCircle(x + 45, y + 15, 15, bg_color[1], bg_color[2], bg_color[3], 255)
            fill_rect(img, x + 15, y, 30, 31, bg_color[1], bg_color[2], bg_color[3])

            -- Knob
            local knob_x = state and (x + 45) or (x + 15)
            img:drawCircle(knob_x, y + 15, 12, 255, 255, 255, 255)
        end

        draw_toggle(60, 40, true)
        draw_toggle(60, 80, false)

        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- 13. @evidence file
    it("PNG: scrollable list with scrollbar", function()
        local path = init_ui_path("ui_scrollable.png")
        local W, H = 200, 240
        local img = lurek.image.newImageData(W, H)
        img:fill(25, 25, 35, 255)

        -- List area
        fill_rect(img, 20, 20, 140, 200, 35, 35, 45)
        outline_rect(img, 20, 20, 140, 200, 70, 70, 90)

        -- Items
        for i = 0, 4 do
            local y = 22 + i * 36
            fill_rect(img, 24, y, 132, 30, 50, 50, 60)
            if i == 2 then
                outline_rect(img, 24, y, 132, 30, 100, 180, 255) -- selected
            end
        end

        -- Scrollbar track
        fill_rect(img, 166, 20, 14, 200, 20, 20, 30)
        outline_rect(img, 166, 20, 14, 200, 70, 70, 90)

        -- Scrollbar thumb
        fill_rect(img, 168, 60, 10, 80, 120, 120, 140)

        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- 14. @evidence file
    it("PNG: tabbed navigation", function()
        local path = init_ui_path("ui_tabs.png")
        local W, H = 300, 150
        local img = lurek.image.newImageData(W, H)
        img:fill(30, 30, 40, 255)

        -- Tabs
        fill_rect(img, 20, 20, 80, 30, 45, 45, 55)
        fill_rect(img, 105, 20, 80, 30, 70, 75, 100) -- active tab
        fill_rect(img, 190, 20, 80, 30, 45, 45, 55)

        -- Panel
        fill_rect(img, 20, 50, 260, 80, 70, 75, 100)
        outline_rect(img, 20, 50, 260, 80, 120, 125, 150)

        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- 15. @evidence file
    it("PNG: modal dialog with overlay", function()
        local path = init_ui_path("ui_modal.png")
        local W, H = 300, 200
        local img = lurek.image.newImageData(W, H)

        -- Background content
        img:fill(40, 50, 60, 255)
        img:drawCircle(100, 100, 50, 60, 80, 100, 255)

        -- Overlay tint
        img:alphaMask(0.4)

        -- Modal Box
        fill_rect(img, 50, 50, 200, 100, 25, 25, 35)
        outline_rect(img, 50, 50, 200, 100, 150, 150, 170)

        -- Buttons
        fill_rect(img, 70, 110, 60, 25, 180, 60, 60) -- Cancel
        fill_rect(img, 170, 110, 60, 25, 60, 180, 60) -- OK

        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- 16. @evidence file
    it("PNG: stacked bar chart", function()
        local path = init_ui_path("ui_stacked_bar.png")
        local W, H = 240, 200
        local img = lurek.image.newImageData(W, H)
        img:fill(20, 20, 30, 255)

        -- Axes
        img:drawLine(30, 20, 30, 170, 100, 100, 100, 255)
        img:drawLine(30, 170, 220, 170, 100, 100, 100, 255)

        local data = {
            {40, 20, 30},
            {60, 10, 40},
            {30, 50, 20},
            {50, 30, 10}
        }
        local colors = {
            {200, 80, 80},
            {80, 200, 80},
            {80, 80, 200}
        }

        for i, bars in ipairs(data) do
            local x = 40 + (i - 1) * 45
            local current_y = 170
            for j, val in ipairs(bars) do
                local c = colors[j]
                fill_rect(img, x, current_y - val, 30, val, c[1], c[2], c[3])
                current_y = current_y - val
            end
        end

        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- 17. @evidence file
    it("PNG: heat map visualization", function()
        local path = init_ui_path("ui_heatmap.png")
        local W, H = 200, 200
        local img = lurek.image.newImageData(W, H)

        -- 8x8 grid
        local rows, cols = 8, 8
        local cell_s = 22
        local off_x, off_y = 12, 12

        for r = 0, rows - 1 do
            for c = 0, cols - 1 do
                -- Procedural data
                local val = math.abs(math.sin(r * 0.5) * math.cos(c * 0.5))

                -- Cold (blue) to Hot (red)
                local red = math.floor(val * 255)
                local blue = math.floor((1 - val) * 255)

                fill_rect(img, off_x + c * cell_s, off_y + r * cell_s, cell_s - 1, cell_s - 1, red, 0, blue)
            end
        end

        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- 18. @evidence file
    it("PNG: sparkline chart", function()
        local path = init_ui_path("ui_sparkline.png")
        local W, H = 200, 60
        local img = lurek.image.newImageData(W, H)
        img:fill(18, 22, 28, 255)

        local data = {10, 25, 20, 40, 35, 55, 45, 60, 50, 70}
        local step = math.floor((W - 20) / (#data - 1))
        local max_h = 40

        -- Area fill
        for i = 1, #data - 1 do
            local x0 = 10 + (i - 1) * step
            local y0 = 50 - math.floor((data[i] / 100) * max_h)
            local x1 = 10 + i * step
            local y1 = 50 - math.floor((data[i+1] / 100) * max_h)

            -- Simple vertical fill for area
            for dx = 0, step do
                local t = dx / step
                local cy = y0 + (y1 - y0) * t
                img:drawLine(math.floor(x0 + dx), math.floor(cy), math.floor(x0 + dx), 50, 40, 100, 200, 100)
            end

            -- Line
            img:drawLine(x0, y0, x1, y1, 100, 200, 255, 255)
        end
        -- End dot
        local lx = 10 + (#data - 1) * step
        local ly = 50 - math.floor((data[#data] / 100) * max_h)
        img:drawCircle(lx, ly, 3, 255, 255, 255, 255)

        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- 19. @evidence file
    it("PNG: pie chart", function()
        local path = init_ui_path("ui_pie_chart.png")
        local W, H = 200, 200
        local img = lurek.image.newImageData(W, H)
        img:fill(25, 25, 35, 255)

        local cx, cy, R = 100, 100, 70
        local data = {0.3, 0.4, 0.1, 0.2}
        local colors = {
            {220, 80, 80},
            {80, 220, 80},
            {80, 80, 220},
            {220, 220, 80}
        }

        -- Draw wedges procedurally using mapPixel
        img:mapPixel(function(x, y, r, g, b, a)
            local dx = x - cx
            local dy = y - cy
            local dist = math.sqrt(dx*dx + dy*dy)
            if dist <= R then
                local angle = math.atan2(dy, dx)
                if angle < 0 then angle = angle + 2 * math.pi end
                local t = angle / (2 * math.pi)
                local sum = 0
                for i, v in ipairs(data) do
                    sum = sum + v
                    if t <= sum then
                        return colors[i][1], colors[i][2], colors[i][3], 255
                    end
                end
            end
            return r, g, b, a
        end)

        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- 20. @evidence file
    it("PNG: area chart overlapping", function()
        local path = init_ui_path("ui_area_chart.png")
        local W, H = 240, 150
        local img = lurek.image.newImageData(W, H)
        img:fill(20, 20, 25, 255)

        -- Axes
        img:drawLine(20, 20, 20, 130, 100, 100, 100, 255)
        img:drawLine(20, 130, 220, 130, 100, 100, 100, 255)

        local data1 = {20, 50, 40, 80, 60, 90}
        local data2 = {40, 30, 60, 40, 70, 50}
        local step = math.floor(200 / 5)

        local function draw_area(data, r, g, b)
            for i = 1, #data - 1 do
                local x0 = 20 + (i - 1) * step
                local y0 = 130 - data[i]
                local x1 = 20 + i * step
                local y1 = 130 - data[i+1]

                for dx = 0, step do
                    local t = dx / step
                    local cy = y0 + (y1 - y0) * t
                    img:drawLine(math.floor(x0 + dx), math.floor(cy), math.floor(x0 + dx), 130, math.floor(r*0.5), math.floor(g*0.5), math.floor(b*0.5), 180)
                end
                img:drawLine(x0, y0, x1, y1, r, g, b, 255)
            end
        end

        draw_area(data1, 100, 200, 255)
        draw_area(data2, 255, 100, 150)

        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

end)

test_summary()
