-- Canonical evidence file for lurek.raycaster visual outputs.

local OUT = evidence_output_dir("raycaster")

local function save_png(img, name)
    local path = OUT .. name
    lurek.image.savePNG(img, path)
    expect_evidence_created(path)
end

local function make_room(w, h)
    local rc = lurek.raycaster.new(w, h)
    for x = 0, w - 1 do
        rc:setCell(x, 0, 1)
        rc:setCell(x, h - 1, 1)
    end
    for y = 0, h - 1 do
        rc:setCell(0, y, 1)
        rc:setCell(w - 1, y, 1)
    end
    return rc
end

local function make_corridor()
    local rc = make_room(18, 18)
    for y = 2, 15 do
        rc:setCell(5, y, 2)
        rc:setCell(12, y, 3)
    end
    for x = 5, 12 do
        rc:setCell(x, 3, 2)
        rc:setCell(x, 14, 3)
    end
    rc:setCell(8, 7, 1)
    rc:setCell(9, 8, 2)
    rc:setCell(10, 10, 3)
    rc:setCell(11, 6, 2)
    return rc
end

local function make_feature_map(kind, amount)
    local rc = make_room(14, 11)
    rc:setCell(8, 5, 2)
    rc:setCell(12, 5, 3)
    if kind == "half" then
        rc:setWallFeatureCell(8, 5, { kind = "half", height = 0.48 })
    elseif kind == "window" then
        rc:setWallFeatureCell(8, 5, { kind = "window", sill_height = 0.25, lintel_height = 0.78, alpha = 0.35 })
    elseif kind == "door" then
        rc:setWallFeatureCell(8, 5, { kind = "door", direction = "vertical", open_amount = amount or 0.0, alpha = 0.82 })
    end
    return rc
end

local function params(px, py, angle, w, h)
    return {
        px = px or 8.5,
        py = py or 8.5,
        angle = angle or 0.0,
        fov = math.pi / 3,
        rays = 96,
        max_dist = 18.0,
        screen_w = w or 320,
        screen_h = h or 180,
    }
end

local function draw_cell(img, x, y, scale, val)
    local r, g, b = 26, 30, 40
    if val == 1 then
        r, g, b = 198, 207, 218
    elseif val == 2 then
        r, g, b = 54, 154, 225
    elseif val == 3 then
        r, g, b = 230, 142, 64
    elseif val == 4 then
        r, g, b = 150, 88, 220
    end
    img:drawRect(x * scale, y * scale, scale - 1, scale - 1, r, g, b, 255)
end

local function draw_grid(img, rc, scale, ox, oy)
    ox = ox or 0
    oy = oy or 0
    for y = 0, rc:height() - 1 do
        for x = 0, rc:width() - 1 do
            local before = lurek.image.newImageData(scale, scale)
            before:fill(0, 0, 0, 0)
            draw_cell(before, 0, 0, scale, rc:getCell(x, y))
            img:blit(before, ox + x * scale, oy + y * scale)
        end
    end
end

local function mark(img, x, y, scale, r, g, b, ox, oy)
    ox = ox or 0
    oy = oy or 0
    local px = ox + math.floor(x * scale)
    local py = oy + math.floor(y * scale)
    img:drawCircle(px, py, 4, r, g, b, 255)
    img:drawLine(px - 8, py, px + 8, py, r, g, b, 255)
    img:drawLine(px, py - 8, px, py + 8, r, g, b, 255)
end

local function ray(img, x, y, angle, distance, scale, r, g, b, ox, oy)
    ox = ox or 0
    oy = oy or 0
    img:drawLine(
        ox + math.floor(x * scale),
        oy + math.floor(y * scale),
        ox + math.floor((x + math.cos(angle) * distance) * scale),
        oy + math.floor((y + math.sin(angle) * distance) * scale),
        r,
        g,
        b,
        230
    )
end

local function draw_fov_rays(img, rc, px, py, angle, fov, count, max_dist, scale, ox, oy)
    local rays = rc:castRays(px, py, angle, fov, count, max_dist)
    for i, hit in ipairs(rays) do
        local t = (i - 1) / math.max(1, count - 1)
        local a = angle - fov * 0.5 + fov * t
        ray(img, px, py, a, hit.distance or max_dist, scale, 60, 210, 255, ox, oy)
        if hit.hit then
            mark(img, hit.hit_x, hit.hit_y, scale, 255, 230, 90, ox, oy)
        end
    end
    mark(img, px, py, scale, 255, 255, 255, ox, oy)
end

local function screen_marker(img, sx, sy, r, g, b)
    img:drawCircle(sx, sy, 6, r, g, b, 255)
    img:drawLine(sx - 12, sy, sx + 12, sy, r, g, b, 255)
    img:drawLine(sx, sy - 12, sx, sy + 12, r, g, b, 255)
end

local function draw_pick_world(img, pick, scale, r, g, b, ox, oy)
    if pick then
        mark(img, pick.hit_x or (pick.x + 0.5), pick.hit_y or (pick.y + 0.5), scale, r, g, b, ox, oy)
    end
end

-- @describe Evidence: lurek.raycaster
describe("Evidence: lurek.raycaster", function()
    before_each(function()
        ensure_evidence_dir("raycaster")
    end)

    -- Does: Renders a first-person corridor and pairs it with the exact top-down FOV rays that produced the columns.
    -- Shows: A real wall-column raycaster view plus the same camera footprint in grid space.
    -- Artifact: tests/artifacts/current/raycaster/raycaster_corridor_view_with_fov.png
    -- Why: This demonstrates drawView and castRays as one coherent pseudo-3D projection.
    it("PNG: corridor view with FOV rays", function()
        local rc = make_corridor()
        local angle = math.pi / 2
        local view = rc:drawView(8.5, 8.5, angle, math.pi / 3, 320, 180, 18.0)
        local img = lurek.image.newImageData(520, 220)
        img:fill(8, 10, 16, 255)
        img:blit(view, 0, 0)
        draw_grid(img, rc, 10, 334, 18)
        draw_fov_rays(img, rc, 8.5, 8.5, angle, math.pi / 3, 17, 18.0, 10, 334, 18)
        save_png(img, "raycaster_corridor_view_with_fov.png")
    end)

    -- Does: Renders the same camera as flat columns and as a depth-column buffer.
    -- Shows: The top row is the view; the bottom row is the per-column distance field used by the projection.
    -- Artifact: tests/artifacts/current/raycaster/raycaster_depth_columns_vs_view.png
    -- Why: This demonstrates drawDepthMap as raycaster depth output, not a generic chart.
    it("PNG: depth columns versus view", function()
        local rc = make_corridor()
        local angle = math.pi / 2 + 0.18
        local view = rc:drawView(8.5, 8.5, angle, math.pi / 3, 320, 140, 18.0)
        local depth = rc:drawDepthMap(8.5, 8.5, angle, math.pi / 3, 192, 320, 80, 18.0)
        local img = lurek.image.newImageData(320, 230)
        img:fill(6, 8, 14, 255)
        img:blit(view, 0, 0)
        img:blit(depth, 0, 148)
        save_png(img, "raycaster_depth_columns_vs_view.png")
    end)

    -- Does: Renders a multi-frame camera rotation sweep from one tile.
    -- Shows: Adjacent first-person frames should rotate through different corridor walls.
    -- Artifact: tests/artifacts/current/raycaster/raycaster_camera_sweep_atlas.png
    -- Why: This demonstrates drawCameraSweep as a raycaster preview generator for rotating views.
    it("PNG: camera sweep atlas", function()
        local rc = make_corridor()
        local img = rc:drawCameraSweep(8.5, 8.5, math.pi / 3, 18.0, 8, 120, 80)
        save_png(img, "raycaster_camera_sweep_atlas.png")
    end)

    -- Does: Draws a top-down raycaster debug map and overlays the same render rays used by the camera.
    -- Shows: The player FOV rays in grid space without deriving gameplay visibility masks.
    -- Artifact: tests/artifacts/current/raycaster/raycaster_topdown_cast_rays.png
    -- Why: This demonstrates drawTopDown and castRays as render-space inspection.
    it("PNG: top-down cast rays", function()
        local rc = make_corridor()
        local angle = math.pi / 2
        local img = rc:drawTopDown(8.5, 8.5, angle, 14)
        draw_fov_rays(img, rc, 8.5, 8.5, angle, math.pi / 3, 11, 10.0, 14, 0, 0)
        save_png(img, "raycaster_topdown_cast_rays.png")
    end)

    -- Does: Casts one ray through two transparent wall layers before the final opaque wall.
    -- Shows: Multiple hit points appear on the same ray, proving layered transparent traversal.
    -- Artifact: tests/artifacts/current/raycaster/raycaster_transparent_layered_hits.png
    -- Why: This demonstrates setWallAlpha and castRayMulti as a ray traversal feature.
    it("PNG: transparent layered hits", function()
        local rc = make_room(18, 10)
        rc:setCell(5, 5, 2)
        rc:setCell(9, 5, 3)
        rc:setCell(14, 5, 1)
        rc:setWallAlpha(2, 0.35)
        rc:setWallAlpha(3, 0.55)

        local img = lurek.image.newImageData(360, 180)
        img:fill(8, 10, 16, 255)
        draw_grid(img, rc, 16, 0, 0)
        local hits = rc:castRayMulti(2.5, 5.5, 0.0, 20.0, 5)
        for i, hit in ipairs(hits) do
            ray(img, 2.5, 5.5, 0.0, hit.distance, 16, 255, 220 - i * 30, 70 + i * 35, 0, 0)
            mark(img, hit.hit_x, hit.hit_y, 16, 255, 235 - i * 25, 90 + i * 35, 0, 0)
        end
        img:blit(rc:drawView(2.5, 5.5, 0.0, math.pi / 4, 160, 90, 20.0), 192, 24)
        save_png(img, "raycaster_transparent_layered_hits.png")
    end)

    -- Does: Renders half-wall, window, closed door, and open door cases from the same camera.
    -- Shows: Four first-person panels with pick markers showing which screen band hits the feature or passes through.
    -- Artifact: tests/artifacts/current/raycaster/raycaster_feature_walls_view_pick.png
    -- Why: This demonstrates feature cells as first-person wall/picker behavior, not just stored metadata.
    it("PNG: feature wall view and pick", function()
        local sheet = lurek.image.newImageData(640, 240)
        sheet:fill(8, 10, 16, 255)
        local kinds = {
            { "half", nil, 255, 210, 80 },
            { "window", nil, 90, 210, 255 },
            { "door", 0.0, 255, 90, 90 },
            { "door", 0.75, 120, 240, 150 },
        }
        for i, item in ipairs(kinds) do
            local rc = make_feature_map(item[1], item[2])
            local p = params(4.5, 5.5, 0.0, 160, 120)
            local view = rc:drawView(p.px, p.py, p.angle, p.fov, 160, 120, p.max_dist)
            local x0 = (i - 1) * 160
            sheet:blit(view, x0, 0)
            local center = rc:pickScreen(80, 60, p)
            local upper = rc:pickScreen(80, 38, p)
            local lower = rc:pickScreen(80, 82, p)
            screen_marker(sheet, x0 + 80, 60, item[3], item[4], item[5])
            screen_marker(sheet, x0 + 80, 38, 230, 230, 235)
            screen_marker(sheet, x0 + 80, 82, 230, 230, 235)
            draw_grid(sheet, rc, 7, x0 + 18, 136)
            draw_pick_world(sheet, center, 7, item[3], item[4], item[5], x0 + 18, 136)
            draw_pick_world(sheet, upper, 7, 230, 230, 235, x0 + 18, 136)
            draw_pick_world(sheet, lower, 7, 230, 230, 235, x0 + 18, 136)
        end
        save_png(sheet, "raycaster_feature_walls_view_pick.png")
    end)

    -- Does: Uses screen picking and floor-row UV casting on the same first-person camera.
    -- Shows: Crosshairs hit wall/floor/ceiling while the UV strip shows floor projection changing across a scanline.
    -- Artifact: tests/artifacts/current/raycaster/raycaster_floor_ceiling_pick_uv.png
    -- Why: This demonstrates pickScreen and castFloorRow as floor/ceiling projection APIs.
    it("PNG: floor and ceiling pick UV", function()
        local rc = make_corridor()
        rc:setFloorTextureCell(9, 10, 4)
        rc:setCeilingTextureCell(9, 5, 7)
        local p = params(8.5, 8.5, math.pi / 2, 320, 180)
        local img = lurek.image.newImageData(360, 250)
        img:fill(8, 10, 16, 255)
        img:blit(rc:drawView(p.px, p.py, p.angle, p.fov, 320, 180, p.max_dist), 0, 0)
        local floor_hit = rc:pickScreen(160, 150, p)
        local ceil_hit = rc:pickScreen(160, 24, p)
        local wall_hit = rc:pickScreen(160, 90, p)
        screen_marker(img, 160, 150, 120, 240, 150)
        screen_marker(img, 160, 24, 90, 170, 255)
        screen_marker(img, 160, 90, 255, 210, 80)
        local uvs = rc:castFloorRow(p.px, p.py, 0.0, 1.0, -0.66, 0.0, 150)
        for i, uv in ipairs(uvs) do
            if i <= 320 then
                local r = math.floor((uv.u % 1.0) * 255)
                local g = math.floor((uv.v % 1.0) * 255)
                img:drawRect(i - 1, 202, 1, 28, r, g, 180, 255)
            end
        end
        draw_grid(img, rc, 8, 320, 96)
        draw_pick_world(img, floor_hit, 8, 120, 240, 150, 320, 96)
        draw_pick_world(img, ceil_hit, 8, 90, 170, 255, 320, 96)
        draw_pick_world(img, wall_hit, 8, 255, 210, 80, 320, 96)
        save_png(img, "raycaster_floor_ceiling_pick_uv.png")
    end)

    -- Does: Builds a two-level raycaster grid with holes and a lowered floor, then visualizes the picked level.
    -- Shows: Two stacked maps, a cross-level opening, active camera ray, and the screen pick target.
    -- Artifact: tests/artifacts/current/raycaster/raycaster_multilevel_hole_pick.png
    -- Why: This demonstrates MultiLevelGrid authoring plus buildScene/pickScreen as stacked raycaster space.
    it("PNG: multilevel hole pick", function()
        local grid = lurek.raycaster.newMultiLevelGrid({
            {
                width = 6,
                height = 6,
                cells = {
                    1, 1, 1, 1, 1, 1,
                    1, 0, 0, 0, 0, 1,
                    1, 0, 0, 0, 0, 1,
                    1, 0, 0, 0, 0, 1,
                    1, 0, 0, 0, 0, 1,
                    1, 1, 1, 1, 1, 1,
                },
                floor_offset = 0.0,
                ceiling_height = 1.0,
            },
            {
                width = 6,
                height = 6,
                cells = {
                    1, 1, 1, 1, 1, 1,
                    1, 0, 0, 0, 0, 1,
                    1, 0, 0, 1, 0, 1,
                    1, 0, 0, 0, 0, 1,
                    1, 0, 0, 0, 0, 1,
                    1, 1, 1, 1, 1, 1,
                },
                floor_offset = 1.0,
                ceiling_height = 2.0,
            },
        })
        grid:setActiveLevel(1)
        grid:setFloorHole(2, 2, true)
        grid:setCeilingHole(2, 2, true)
        grid:setLoweredFloorCell(3, 3, { texture = 1, depth = 0.35, blocked = false, r = 0.45, g = 0.65, b = 1.0 })
        local p = params(2.5, 2.5, 0.0, 180, 110)
        p.active_level = 1
        grid:buildScene(p, { { x = 2.5, y = 2.5, r = 1.0, g = 0.9, b = 0.7, radius = 5.0, intensity = 1.2, level = 1 } }, {}, {})
        local pick = grid:pickScreen(90, 55, p, {})

        local img = lurek.image.newImageData(300, 180)
        img:fill(8, 10, 16, 255)
        local lower = make_room(6, 6)
        local upper = make_room(6, 6)
        upper:setCell(3, 2, 3)
        draw_grid(img, lower, 20, 18, 24)
        draw_grid(img, upper, 20, 160, 24)
        img:drawRect(18 + 2 * 20 + 4, 24 + 2 * 20 + 4, 12, 12, 90, 210, 255, 255)
        img:drawRect(160 + 2 * 20 + 4, 24 + 2 * 20 + 4, 12, 12, 255, 210, 90, 255)
        img:drawRect(160 + 3 * 20 + 4, 24 + 3 * 20 + 4, 12, 12, 80, 140, 255, 255)
        ray(img, 2.5, 2.5, 0.0, 3.0, 20, 255, 255, 255, 160, 24)
        if pick then
            mark(img, (pick.x or 0) + 0.5, (pick.y or 0) + 0.5, 20, 255, 90, 90, 160, 24)
        end
        save_png(img, "raycaster_multilevel_hole_pick.png")
    end)
end)

test_summary()
