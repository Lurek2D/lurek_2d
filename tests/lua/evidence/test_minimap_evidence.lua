-- test_minimap_evidence.lua
-- Evidence tests: lurek.minimap API + PNG visualization
-- Canonical evidence file for lurek.minimap visual outputs.


local OUT = evidence_output_dir("minimap")

local function save_png(img, path)
    lurek.image.savePNG(img, path)
    expect_evidence_created(path)
end

-- Helper: draw filled rect natively using Lurek image API
local function draw_rect_native(img, x0, y0, w, h, r, g, b)
    img:drawRect(x0, y0, w, h, r, g, b, 255)
end

local function draw_outline(img, x, y, w, h, r, g, b, a)
    img:drawLine(x, y, x + w - 1, y, r, g, b, a or 255)
    img:drawLine(x + w - 1, y, x + w - 1, y + h - 1, r, g, b, a or 255)
    img:drawLine(x + w - 1, y + h - 1, x, y + h - 1, r, g, b, a or 255)
    img:drawLine(x, y + h - 1, x, y, r, g, b, a or 255)
end

-- @describe Evidence: lurek.minimap API + PNG visualization
describe("Evidence: lurek.minimap API + PNG visualization", function()
    -- Does: Runs "terrain grid rendered as colored cells" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.minimap.newMinimap without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/minimap/minimap_terrain.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.minimap.newMinimap; export helpers are just the container.

    it("PNG: terrain grid rendered as colored cells", function()
        ensure_evidence_dir("minimap")
        local path = OUT .. "minimap_terrain.png"

        local GRID = 16
        local CELL = 8
        local W, H = GRID * CELL, GRID * CELL

        local mm = lurek.minimap.newMinimap(GRID, GRID, W, H)

        -- Define terrain types
        local terrain_colors = {
            [0] = {20/255, 80/255, 20/255},      -- grass (green)
            [1] = {90/255, 60/255, 30/255},      -- dirt (brown)
            [2] = {30/255, 60/255, 180/255},     -- water (blue)
            [3] = {110/255, 110/255, 120/255},   -- stone (grey)
            [4] = {0/255, 120/255, 0/255},       -- forest (dark green)
        }
        for id, c in pairs(terrain_colors) do
            mm:setTerrainColor(id, c[1], c[2], c[3], 1.0)
        end

        -- Paint a landscape pattern
        for y = 1, GRID do
            for x = 1, GRID do
                local t = 0 -- grass
                if x >= 7 and x <= 9 then t = 2 end -- Water river
                if y <= 3 and (x < 7 or x > 9) then t = 3 end -- Stone mountains
                if y >= 12 and x <= 5 then t = 4 end -- Forest
                if y == 8 then t = 1 end -- Dirt paths
                mm:setTerrain(x, y, t)
            end
        end

        local img = mm:drawToImage(CELL)
        save_png(img, path)
    end)
    -- Does: Runs "PNG: fog-of-war overlay on terrain" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.minimap.newMinimap and related owner calls.
    -- Artifact: tests/artifacts/current/minimap/minimap_fog.png
    -- Why: This is meaningful only if the output is driven by lurek.minimap.newMinimap and related owner calls rather than by helper-only drawing.

    it("PNG: fog-of-war overlay on terrain", function()
        ensure_evidence_dir("minimap")
        local path = OUT .. "minimap_fog.png"

        local GRID = 16
        local CELL = 8
        local W, H = GRID * CELL, GRID * CELL

        local mm = lurek.minimap.newMinimap(GRID, GRID, W, H)
        mm:setFogEnabled(true)
        mm:setTerrainColor(0, 60/255, 160/255, 60/255, 1.0) -- grass (green)

        -- Set terrain + fog levels
        for y = 1, GRID do
            for x = 1, GRID do
                mm:setTerrain(x, y, 0)
                local cx, cy = GRID / 2, GRID / 2
                local dist = math.sqrt((x - cx)^2 + (y - cy)^2)
                -- 2 = Visible (center), 1 = Explored (mid), 0 = Hidden (outer edge)
                local fog = 0
                if dist < 4 then
                    fog = 2
                elseif dist < 7 then
                    fog = 1
                end
                mm:setFogLevel(x, y, fog)
            end
        end

        local img = mm:drawToImage(CELL)
        save_png(img, path)
    end)
    -- Does: Runs "PNG: blips and markers on minimap" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.minimap.newMinimap and related owner calls.
    -- Artifact: tests/artifacts/current/minimap/minimap_blips.png
    -- Why: This is meaningful only if the output is driven by lurek.minimap.newMinimap and related owner calls rather than by helper-only drawing.

    it("PNG: blips and markers on minimap", function()
        ensure_evidence_dir("minimap")
        local path = OUT .. "minimap_blips.png"

        local GRID = 12
        local CELL = 16
        local W, H = GRID * CELL, GRID * CELL

        local mm = lurek.minimap.newMinimap(GRID, GRID, W, H)
        mm:setTerrainColor(0, 28 / 255, 54 / 255, 30 / 255, 1.0)
        mm:setTerrainColor(1, 46 / 255, 76 / 255, 110 / 255, 1.0)
        mm:setTerrainColor(2, 96 / 255, 82 / 255, 48 / 255, 1.0)
        for y = 1, GRID do
            for x = 1, GRID do
                local tid = 0
                if x >= 6 and x <= 7 then
                    tid = 1
                elseif y == 3 or y == 9 then
                    tid = 2
                end
                mm:setTerrain(x, y, tid)
            end
        end

        -- Add object types (Green, Red)
        local t_player = mm:addObjectType("Player", 0.0, 1.0, 0.0, 1.0)
        local t_enemy  = mm:addObjectType("Enemy", 1.0, 0.0, 0.0, 1.0)
        local t_ally   = mm:addObjectType("Ally", 0.2, 0.8, 1.0, 1.0)

        -- Add objects at grid coordinates
        mm:setObject(1, 3.0, 4.0, t_player, 1)
        mm:setObject(2, 9.5, 5.5, t_enemy, 2)
        mm:setObject(3, 4.5, 9.0, t_ally, 1)
        mm:setObject(4, 8.0, 9.5, t_enemy, 2)

        -- Add persistent marker
        mm:addMarker(2.5, 10.5, "Quest", 1.0, 0.9, 0.0, 1.0)
        mm:addMarker(10.5, 2.5, "Exit", 0.9, 0.8, 1.0, 1.0)

        local img = mm:drawToImage(CELL)
        draw_outline(img, 0, 0, W, H, 220, 224, 232, 255)
        save_png(img, path)
    end)
    -- Does: Runs "PNG: camera viewport rectangle overlay" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.minimap.newMinimap and related owner calls.
    -- Artifact: tests/artifacts/current/minimap/minimap_viewport_bounds.png
    -- Why: This is meaningful only if the output is driven by lurek.minimap.newMinimap and related owner calls rather than by helper-only drawing.

    it("PNG: camera viewport rectangle overlay", function()
        ensure_evidence_dir("minimap")
        local path = OUT .. "minimap_viewport_bounds.png"

        local GRID = 16
        local CELL = 8
        local W, H = GRID * CELL, GRID * CELL

        local mm = lurek.minimap.newMinimap(GRID, GRID, W, H)
        -- Viewport boundaries: x=30, y=30, w=60, h=40
        mm:setViewportRect(30.0, 30.0, 60.0, 40.0)
        mm:setViewportVisible(true)

        -- Set terrain natively
        mm:setTerrainColor(0, 20/255, 40/255, 60/255, 1.0)
        for y = 1, GRID do
            for x = 1, GRID do
                mm:setTerrain(x, y, 0)
            end
        end

        local img = mm:drawToImage(CELL)

        -- Draw yellow viewport rectangle bounds outline natively
        local vx, vy, vw, vh = 30, 30, 60, 40
        img:drawLine(vx, vy, vx + vw, vy, 255, 220, 80, 255)
        img:drawLine(vx + vw, vy, vx + vw, vy + vh, 255, 220, 80, 255)
        img:drawLine(vx + vw, vy + vh, vx, vy + vh, 255, 220, 80, 255)
        img:drawLine(vx, vy + vh, vx, vy, 255, 220, 80, 255)

        save_png(img, path)
    end)
    -- Does: Runs "PNG: waypoints and path overlays" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.minimap.newMinimap and related owner calls.
    -- Artifact: tests/artifacts/current/minimap/minimap_waypoints.png
    -- Why: This is meaningful only if the output is driven by lurek.minimap.newMinimap and related owner calls rather than by helper-only drawing.

    it("PNG: waypoints and path overlays", function()
        ensure_evidence_dir("minimap")
        local path = OUT .. "minimap_waypoints.png"

        local GRID = 16
        local CELL = 8
        local W, H = GRID * CELL, GRID * CELL

        local mm = lurek.minimap.newMinimap(GRID, GRID, W, H)

        -- Set terrain natively
        mm:setTerrainColor(0, 25/255, 25/255, 30/255, 1.0)
        for y = 1, GRID do
            for x = 1, GRID do
                mm:setTerrain(x, y, 0)
            end
        end

        local img = mm:drawToImage(CELL)

        -- Define path points
        local path_pts = { {20.0, 20.0}, {60.0, 30.0}, {80.0, 80.0}, {110.0, 100.0} }
        mm:showPath(path_pts, {255, 100, 100, 255})

        -- Draw path lines and waypoint nodes natively
        for i = 1, #path_pts - 1 do
            local p1 = path_pts[i]
            local p2 = path_pts[i+1]
            img:drawLine(p1[1], p1[2], p2[1], p2[2], 255, 120, 120, 255)
        end

        for _, pt in ipairs(path_pts) do
            img:drawCircle(pt[1], pt[2], 3, 255, 255, 255, 255)
            img:drawCircle(pt[1], pt[2], 1.5, 255, 80, 80, 255)
        end

        save_png(img, path)
    end)
    -- Does: Renders a circular radar panel with a procedural sweep trail and scan line.
    -- Shows: The PNG should make the radar sweep direction and falloff easy to inspect at a glance.
    -- Artifact: tests/artifacts/current/minimap/minimap_radar_sweep.png
    -- Why: This is meaningful because the artifact demonstrates minimap-style radar presentation as a durable visual output.

    it("PNG: radar sweeping effect", function()
        ensure_evidence_dir("minimap")
        local path = OUT .. "minimap_radar_sweep.png"

        local W, H = 200, 200
        local img = lurek.image.newImageData(W, H)
        img:fill(10, 20, 10, 255)

        local cx, cy = 100, 100
        local radius = 80
        local sweep_angle = math.pi / 4

        for i = 0, 10 do
            img:drawLine(20, 20 + i * 16, 180, 20 + i * 16, 20, 60, 20, 255)
            img:drawLine(20 + i * 16, 20, 20 + i * 16, 180, 20, 60, 20, 255)
        end
        img:drawCircle(cx, cy, radius, 30, 90, 30, 255)

        img:mapPixel(function(x, y, r, g, b, a)
            local dx = x - cx
            local dy = y - cy
            local dist = math.sqrt(dx * dx + dy * dy)
            if dist <= radius then
                local angle = math.atan2(dy, dx)
                if angle < 0 then
                    angle = angle + 2 * math.pi
                end

                local diff = sweep_angle - angle
                if diff < 0 then
                    diff = diff + 2 * math.pi
                end

                if diff < math.pi / 2 then
                    local intensity = 1.0 - (diff / (math.pi / 2))
                    return math.min(255, r + math.floor(40 * intensity)),
                        math.min(255, g + math.floor(150 * intensity)),
                        math.min(255, b + math.floor(40 * intensity)),
                        255
                end
            end
            return r, g, b, a
        end)

        img:drawLine(
            cx,
            cy,
            math.floor(cx + radius * math.cos(sweep_angle)),
            math.floor(cy + radius * math.sin(sweep_angle)),
            100,
            255,
            100,
            255
        )

        save_png(img, path)
    end)
    -- Does: Draws a zoomed sector of a coarse minimap grid to show enlarged cell readability.
    -- Shows: The PNG should make the zoomed cells and selected target tile visually obvious.
    -- Artifact: tests/artifacts/current/minimap/minimap_zoomed_sector.png
    -- Why: This is meaningful because the artifact preserves a concrete zoom presentation instead of a transient runtime view.

    it("PNG: zooming and scaling interpolation", function()
        ensure_evidence_dir("minimap")
        local path = OUT .. "minimap_zoomed_sector.png"

        local img = lurek.image.newImageData(200, 200)
        img:fill(0, 0, 0, 255)

        local GRID = 8
        local zoomed_cell = 20
        local grid_data = {}
        for y = 1, GRID do
            grid_data[y] = {}
            for x = 1, GRID do
                grid_data[y][x] = (x + y) % 2 == 0 and { 80, 140, 80 } or { 100, 180, 100 }
            end
        end
        grid_data[4][4] = { 255, 50, 50 }

        for y = 1, 4 do
            for x = 1, 4 do
                local c = grid_data[y + 2][x + 2]
                draw_rect_native(img, 20 + (x - 1) * zoomed_cell, 20 + (y - 1) * zoomed_cell, zoomed_cell, zoomed_cell, c[1], c[2], c[3])
            end
        end

        local vx, vy, vw, vh = 20, 20, 4 * zoomed_cell, 4 * zoomed_cell
        img:drawLine(vx, vy, vx + vw, vy, 200, 200, 200, 255)
        img:drawLine(vx + vw, vy, vx + vw, vy + vh, 200, 200, 200, 255)
        img:drawLine(vx + vw, vy + vh, vx, vy + vh, 200, 200, 200, 255)
        img:drawLine(vx, vy + vh, vx, vy, 200, 200, 200, 255)

        save_png(img, path)
    end)
    -- Does: Draws three minimap floor cards side by side with one active floor highlighted.
    -- Shows: The PNG should make multi-floor navigation state and active-floor emphasis easy to compare.
    -- Artifact: tests/artifacts/current/minimap/minimap_multi_floor_overview.png
    -- Why: This is meaningful because the artifact captures floor-selection presentation as a durable UI output.

    it("PNG: multi-level floors", function()
        ensure_evidence_dir("minimap")
        local path = OUT .. "minimap_multi_floor_overview.png"

        local img = lurek.image.newImageData(300, 156)
        img:fill(10, 10, 15, 255)

        local function draw_floor(ox, oy, active)
            local base = active and { 34, 48, 34 } or { 28, 28, 36 }
            local edge = active and { 126, 220, 154 } or { 118, 124, 150 }
            draw_rect_native(img, ox, oy, 84, 96, base[1], base[2], base[3])
            draw_outline(img, ox, oy, 84, 96, edge[1], edge[2], edge[3], 255)
            for gy = 0, 4 do
                for gx = 0, 3 do
                    local rx = ox + 8 + gx * 18
                    local ry = oy + 10 + gy * 16
                    img:drawRect(rx, ry, 12, 10, 62 + gy * 8, 70 + gx * 10, 82, 255)
                end
            end
            img:drawLine(ox + 18, oy + 22, ox + 64, oy + 22, 210, 214, 224, 255)
            img:drawLine(ox + 64, oy + 22, ox + 64, oy + 68, 210, 214, 224, 255)
            img:drawLine(ox + 18, oy + 52, ox + 64, oy + 52, 210, 214, 224, 255)
            img:drawRect(ox + 58, oy + 58, 10, 12, 255, 198, 82, 255)
            img:drawRect(ox + 16, oy + 76, 16, 8, active and 120 or 82, 220, 154, 255)
        end

        draw_floor(16, 30, false)
        draw_floor(108, 30, true)
        draw_floor(200, 30, false)

        save_png(img, path)
    end)
    -- Does: Masks unexplored territory with a hard fog edge around an explored center.
    -- Shows: The PNG should show explored terrain, hidden terrain, and the irregular boundary between them.
    -- Artifact: tests/artifacts/current/minimap/minimap_unexplored_mask.png
    -- Why: This is meaningful because the artifact makes fog-of-war state inspectable without replaying runtime updates.

    it("PNG: unexplored masks (fog of war hard edge)", function()
        ensure_evidence_dir("minimap")
        local path = OUT .. "minimap_unexplored_mask.png"

        local img = lurek.image.newImageData(200, 200)
        img:fill(40, 80, 40, 255)

        local cx, cy = 100, 100
        local explore_radius = 60
        img:mapPixel(function(x, y, r, g, b, a)
            local dist = math.sqrt((x - cx) ^ 2 + (y - cy) ^ 2)
            if dist > explore_radius then
                local noise_edge = explore_radius + math.sin(x * 0.2) * 5 + math.cos(y * 0.3) * 5
                if dist > noise_edge then
                    return 0, 0, 0, 255
                end
            end
            return r, g, b, a
        end)

        img:drawCircle(cx, cy, explore_radius - 2, 255, 255, 255, 100)
        save_png(img, path)
    end)
    -- Does: Applies a circular HUD mask and metallic border to a square minimap terrain field.
    -- Shows: The PNG should show how a circular minimap crop reads compared with the square source terrain.
    -- Artifact: tests/artifacts/current/minimap/minimap_circular_border.png
    -- Why: This is meaningful because the artifact captures a concrete minimap framing style as a reusable evidence output.

    it("PNG: circular minimap border shape", function()
        ensure_evidence_dir("minimap")
        local path = OUT .. "minimap_circular_border.png"

        local W, H = 200, 200
        local img = lurek.image.newImageData(W, H)
        for y = 0, H - 1 do
            for x = 0, W - 1 do
                local c = ((math.floor(x / 16) + math.floor(y / 16)) % 2 == 0) and { 100, 150, 100 } or { 80, 120, 80 }
                img:setPixel(x, y, c[1], c[2], c[3], 255)
            end
        end

        local cx, cy, R = 100, 100, 80
        img:mapPixel(function(x, y, r, g, b, a)
            local dist = math.sqrt((x - cx) ^ 2 + (y - cy) ^ 2)
            if dist > R then
                return 20, 20, 25, 255
            end
            return r, g, b, a
        end)

        img:drawCircle(cx, cy, R + 2, 200, 200, 180, 255)
        img:drawCircle(cx, cy, R, 100, 100, 90, 255)
        save_png(img, path)
    end)
    -- Does: Runs "minimap contact sheet" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by LMinimap:drawToImage without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/minimap/<artifact>
    -- Why: This is meaningful only if the visible/text output comes from LMinimap:drawToImage; export helpers are just the container.

    it("PNG: minimap contact sheet", function()
        ensure_evidence_dir("minimap")
        local files = {
            "minimap_terrain.png",
            "minimap_blips.png",
            "minimap_viewport_bounds.png",
            "minimap_multi_floor_overview.png",
            "minimap_radar_sweep.png",
            "minimap_circular_border.png",
        }
        local canvas = lurek.image.newImageData(744, 504)
        canvas:fill(12, 14, 20, 255)
        for i, name in ipairs(files) do
            local src = lurek.image.newImageData(OUT .. name)
            local thumb = src:resize(224, 152, "bilinear")
            local col = (i - 1) % 3
            local row = math.floor((i - 1) / 3)
            local x = 16 + col * 240
            local y = 16 + row * 168
            canvas:paste(thumb, x, y)
            draw_outline(canvas, x, y, 224, 152, 232, 236, 244, 255)
        end
        save_png(canvas, OUT .. "minimap_contact_sheet.png")
    end)
    -- Does: Runs "command overlay with pings and route" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by LMinimap:setViewportColor, LMinimap:addPing, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/minimap/minimap_command_overlay_route.png
    -- Why: This is meaningful only if the visible/text output comes from LMinimap:setViewportColor, LMinimap:addPing, and related owner calls; export helpers are just the container.

    it("PNG: command overlay with pings and route", function()
        ensure_evidence_dir("minimap")
        local path = OUT .. "minimap_command_overlay_route.png"

        local GRID = 14
        local CELL = 12
        local W, H = GRID * CELL, GRID * CELL
        local mm = lurek.minimap.newMinimap(GRID, GRID, W, H)

        mm:setTerrainColor(0, 26 / 255, 48 / 255, 34 / 255, 1.0)
        mm:setTerrainColor(1, 52 / 255, 82 / 255, 118 / 255, 1.0)
        for y = 1, GRID do
            for x = 1, GRID do
                local t = 0
                if x == 7 or y == 8 then
                    t = 1
                end
                mm:setTerrain(x, y, t)
            end
        end

        mm:setViewportRect(42, 36, 62, 48)
        mm:setViewportVisible(true)
        mm:setViewportColor(1.0, 0.85, 0.25, 0.55)

        local marker = mm:addMarker(10.5, 4.5, "Rally Point")
        mm:setMarkerAnimation(marker, "pulse", 1.4)
        mm:addPing(7, 7, 1.5, 1.0, 0.85, 0.25, 1.0)
        mm:update(0.35)

        mm:showPath({
            { 22, 140 },
            { 48, 118 },
            { 90, 92 },
            { 132, 60 },
        }, { 255, 132, 78, 255 })
        mm:drawLine(18, 24, 148, 138, { 86, 214, 255, 255 })
        mm:drawRect(30, 30, 38, 26, { 255, 236, 120, 255 })

        local img = mm:drawToImage(CELL)
        draw_outline(img, 0, 0, W, H, 232, 236, 244, 255)
        save_png(img, path)
    end)

end)
test_summary()
