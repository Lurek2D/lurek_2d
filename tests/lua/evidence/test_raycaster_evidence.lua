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

    -- Does: Renders textured first-person day/night views from a tilefield-authored scene and pairs them with the same scene's top-down layout.
    -- Shows: Tilefield slots drive walls, floors, holes, doors, windows, half-wall objects, billboard objects, lights, skybox/background, and overlay weather; the raycaster renders all of it in first person under different ambient lighting.
    -- Artifact: tests/artifacts/current/raycaster/raycaster_full_scene_day_night.png
    -- Why: This demonstrates the full tilefield + tileset + tile light configuration feeding the first-person raycaster output, with a map-side proof of the source data.
    it("PNG: full scene day and night render", function()
        local function make_texture(kind)
            local texture_paths = {
                wall = "content/games/dungeon_crawler/assets/textures/wall_stone_64.png",
                floor = "content/games/dungeon_crawler/assets/textures/wall_cobble_64.png",
                ceiling = "content/games/dungeon_crawler/assets/textures/wall_grass_64.png",
                door = "content/games/dungeon_crawler/assets/textures/wall_wood_64.png",
                crate = "content/games/dungeon_crawler/assets/textures/wall_wood_64.png",
                window = "content/games/dungeon_crawler/assets/textures/ray_water.png",
            }
            if texture_paths[kind] then
                return lurek.render.newImage(texture_paths[kind])
            end
            local img = lurek.image.newImageData(32, 32)
            if kind == "skybox" then
                local sky = lurek.image.newImageData(64, 64)
                for y = 0, 63 do
                    local t = y / 63
                    sky:drawLine(0, y, 63, y, math.floor(110 + 90 * t), math.floor(158 + 62 * t), math.floor(224 + 22 * t), 255)
                end
                sky:drawCircle(48, 12, 7, 255, 232, 148, 230)
                sky:drawCircle(18, 24, 10, 235, 244, 255, 180)
                sky:drawCircle(28, 22, 8, 235, 244, 255, 160)
                return lurek.render.newImage(sky)
            elseif kind == "torch" then
                img:fill(0, 0, 0, 0)
                img:drawRect(14, 12, 4, 18, 88, 54, 28, 255)
                img:drawCircle(16, 10, 8, 255, 112, 28, 220)
                img:drawCircle(16, 8, 4, 255, 224, 92, 255)
            else
                img:fill(0, 0, 0, 0)
                img:drawRect(11, 10, 10, 18, 92, 100, 132, 255)
                img:drawCircle(16, 8, 5, 160, 170, 210, 255)
                img:drawLine(8, 28, 24, 28, 58, 62, 82, 255)
            end
            return lurek.render.newImage(img)
        end

        local textures = {
            wall = make_texture("wall"),
            floor = make_texture("floor"),
            ceiling = make_texture("ceiling"),
            door = make_texture("door"),
            window = make_texture("window"),
            crate = make_texture("crate"),
            torch = make_texture("torch"),
            statue = make_texture("statue"),
            skybox = make_texture("skybox"),
        }

        local width, height = 10, 8
        local field = lurek.tilefield.new({ width = width, height = height, levels = 1 })
        for y = 1, height do
            for x = 1, width do
                field:setRef(x, y, 1, "floor", { tileset = "dungeon", object = "stone_floor" })
                field:setRef(x, y, 1, "ceiling", { tileset = "dungeon", object = "beam_ceiling" })
                field:setRef(x, y, 1, "ceilingHole", { tileset = "dungeon", object = "sky_open" })
            end
        end
        field:setRef(2, 2, 1, "skybox", { tileset = "dungeon", object = "day_skybox" })
        field:setRef(3, 2, 1, "overlay", { tileset = "dungeon", object = "snow_overlay" })
        for x = 1, width do
            field:setRef(x, 1, 1, "wall", { tileset = "dungeon", object = "stone_wall" })
            field:setRef(x, height, 1, "wall", { tileset = "dungeon", object = "stone_wall" })
        end
        for y = 1, height do
            field:setRef(1, y, 1, "wall", { tileset = "dungeon", object = "stone_wall" })
            field:setRef(width, y, 1, "wall", { tileset = "dungeon", object = "stone_wall" })
        end
        field:setRef(7, 3, 1, "wall", { tileset = "dungeon", object = "stone_wall" })
        field:setRef(7, 6, 1, "wall", { tileset = "dungeon", object = "stone_wall" })
        field:setRef(8, 4, 1, "door", { tileset = "dungeon", object = "oak_door" })
        field:setRef(8, 5, 1, "window", { tileset = "dungeon", object = "blue_window" })
        field:setRef(5, 4, 1, "solidObject", { tileset = "dungeon", object = "crate_block" })
        field:setRef(6, 5, 1, "solidObject", { tileset = "dungeon", object = "crate_block" })
        field:setRef(4, 4, 1, "object", { tileset = "dungeon", object = "torch_sprite" })
        field:setRef(6, 4, 1, "object", { tileset = "dungeon", object = "statue_sprite" })
        field:setModifier("torch_light", { light = { radius = 6.8, intensity = 22.0, color = { 1.0, 0.42, 0.06 } } })
        field:setModifier("moon_light", { light = { radius = 6.0, intensity = 6.0, color = { 0.16, 0.36, 1.0 } } })
        field:applyModifier(4, 4, 1, "torch_light")
        field:applyModifier(3, 6, 1, "moon_light")

        local catalog = lurek.tileset.newCatalog({
            dungeon = lurek.tileset.fromProvider({
                firstGid = 1,
                tileCount = 10,
                columns = 4,
                tileWidth = 16,
                tileHeight = 16,
                objects = {
                    stone_wall = {
                        slot = "wall",
                        tileId = 1,
                        visual = { textureId = textures.wall:getId(), tileId = 1 },
                    },
                    stone_floor = {
                        slot = "floor",
                        tileId = 2,
                        visual = { textureId = textures.floor:getId(), tileId = 2 },
                    },
                    beam_ceiling = {
                        slot = "ceiling",
                        tileId = 3,
                        visual = { textureId = textures.ceiling:getId(), tileId = 3 },
                    },
                    oak_door = {
                        slot = "door",
                        tileId = 4,
                        visual = { textureId = textures.door:getId(), tileId = 4 },
                    },
                    blue_window = {
                        slot = "window",
                        tileId = 5,
                        visual = { textureId = textures.window:getId(), tileId = 5 },
                    },
                    crate_block = {
                        slot = "solidObject",
                        tileId = 6,
                        visual = { textureId = textures.crate:getId(), tileId = 6 },
                    },
                    torch_sprite = {
                        slot = "object",
                        tileId = 7,
                        visual = { textureId = textures.torch:getId(), tileId = 7 },
                    },
                    statue_sprite = {
                        slot = "object",
                        tileId = 8,
                        visual = { textureId = textures.statue:getId(), tileId = 8 },
                    },
                    day_skybox = {
                        slot = "skybox",
                        tileId = 9,
                        visual = { textureId = textures.skybox:getId(), tileId = 9 },
                        properties = { type = "skybox", tint = "1,1,1,1", offset = "0.03" },
                    },
                    snow_overlay = {
                        slot = "overlay",
                        tileId = 10,
                        properties = { effect = "snow", density = "0.34", wind = "0.45", color = "1,1,1,0.70" },
                    },
                },
            }),
        })

        local function render_scene(params_extra, extra_lights)
            local p = {
                px = 2.5,
                py = 5.35,
                angle = -0.28,
                fov = math.pi / 2.6,
                rays = 320,
                max_dist = 11.0,
                screen_w = 560,
                screen_h = 230,
                active_level = 0,
                shade_dist = 10.5,
                floor_r = 0.24,
                floor_g = 0.20,
                floor_b = 0.15,
                ceiling_r = 0.82,
                ceiling_g = 0.92,
                ceiling_b = 1.0,
            }
            for k, v in pairs(params_extra) do p[k] = v end
            lurek.raycaster.buildMultiLevelSceneFromField(p, field, {
                catalog = catalog,
                wallChannel = "vision",
                wallSlot = "wall",
                doorSlot = "door",
                windowSlot = "window",
                halfWallSlot = "solidObject",
                halfWallHeight = 0.48,
                floorSlot = "floor",
                ceilingHoleSlot = "ceilingHole",
                skyboxSlot = "skybox",
                overlaySlot = "overlay",
                objectSlot = "object",
                objectSize = 0.70,
                tileLights = true,
                doorOpenAmount = 0.45,
                windowAlpha = 0.50,
            }, extra_lights or {}, nil, nil)
            return lurek.raycaster.drawLastScene(560, 230)
        end

        local day = render_scene({
            ambient = 0.86,
            sun_r = 1.0,
            sun_g = 0.94,
            sun_b = 0.76,
            sun_intensity = 1.18,
            sun_angle = -0.2,
            roof_darkness = 0.02,
        }, {
            { x = 4.0, y = 4.0, radius = 6.2, intensity = 11.0, color = { 1.0, 0.62, 0.18 } },
        })
        local night = render_scene({
            ambient = 0.20,
            sun_r = 0.34,
            sun_g = 0.48,
            sun_b = 1.0,
            sun_intensity = 0.45,
            sun_angle = 2.6,
            roof_darkness = 0.72,
            floor_r = 0.08,
            floor_g = 0.10,
            floor_b = 0.18,
            ceiling_r = 0.05,
            ceiling_g = 0.08,
            ceiling_b = 0.20,
            background = {
                type = "gradient",
                top = { 0.02, 0.06, 0.18, 1.0 },
                bottom = { 0.10, 0.16, 0.30, 1.0 },
            },
            overlays = {
                { type = "fog", color = { 0.06, 0.10, 0.22, 0.42 }, density = 0.75 },
            },
        }, {
            { x = 4.0, y = 4.0, radius = 7.2, intensity = 28.0, color = { 1.0, 0.34, 0.06 } },
            { x = 3.0, y = 6.0, radius = 5.4, intensity = 8.0, color = { 0.12, 0.34, 1.0 } },
        })

        local img = lurek.image.newImageData(980, 540)
        img:fill(7, 9, 14, 255)
        img:drawRect(10, 10, 564, 234, 28, 34, 44, 255)
        img:drawRect(10, 264, 564, 234, 28, 34, 44, 255)
        img:blit(day, 12, 12)
        img:blit(night, 12, 266)

        local ox, oy, scale = 620, 32, 30
        for y = 1, height do
            for x = 1, width do
                local r, g, b = 74, 66, 54
                local is_wall = x == 1 or x == width or y == 1 or y == height or (x == 7 and (y == 3 or y == 6))
                if is_wall then r, g, b = 132, 138, 146 end
                if x == 8 and y == 4 then r, g, b = 144, 82, 36 end
                if x == 8 and y == 5 then r, g, b = 66, 150, 216 end
                if (x == 5 and y == 4) or (x == 6 and y == 5) then r, g, b = 166, 104, 48 end
                if x == 2 and y == 2 then r, g, b = 92, 148, 224 end
                if x == 3 and y == 2 then r, g, b = 222, 232, 246 end
                img:drawRect(ox + (x - 1) * scale, oy + (y - 1) * scale, scale - 2, scale - 2, r, g, b, 255)
            end
        end
        local player_x, player_y, view_angle = 2.5, 5.35, -0.28
        img:drawCircle(ox + math.floor((player_x - 1) * scale), oy + math.floor((player_y - 1) * scale), 6, 245, 245, 245, 255)
        for _, a in ipairs({ -math.pi / 6, 0.0, math.pi / 6 }) do
            img:drawLine(
                ox + math.floor((player_x - 1) * scale),
                oy + math.floor((player_y - 1) * scale),
                ox + math.floor((player_x - 1 + math.cos(view_angle + a) * 6.0) * scale),
                oy + math.floor((player_y - 1 + math.sin(view_angle + a) * 6.0) * scale),
                245,
                245,
                245,
                180
            )
        end
        img:drawCircle(ox + math.floor((4.0 - 1) * scale), oy + math.floor((4.0 - 1) * scale), 16, 255, 118, 28, 90)
        img:drawCircle(ox + math.floor((3.0 - 1) * scale), oy + math.floor((6.0 - 1) * scale), 8, 60, 126, 255, 220)
        img:drawCircle(ox + math.floor((4.0 - 1) * scale), oy + math.floor((4.0 - 1) * scale), 5, 255, 235, 90, 255)
        img:drawCircle(ox + math.floor((6.0 - 1) * scale), oy + math.floor((4.0 - 1) * scale), 5, 178, 184, 220, 255)

        img:drawRect(620, 306, 32, 22, 132, 138, 146, 255)
        img:drawRect(660, 306, 32, 22, 74, 66, 54, 255)
        img:drawRect(700, 306, 32, 22, 28, 40, 58, 255)
        img:drawRect(740, 306, 32, 22, 144, 82, 36, 255)
        img:drawRect(780, 306, 32, 22, 66, 150, 216, 255)
        img:drawRect(820, 306, 32, 22, 166, 104, 48, 255)
        img:drawRect(860, 306, 32, 22, 92, 148, 224, 255)
        img:drawRect(900, 306, 32, 22, 222, 232, 246, 255)
        img:drawCircle(636, 366, 10, 255, 118, 28, 220)
        img:drawCircle(676, 366, 10, 60, 126, 255, 220)
        img:drawCircle(716, 366, 8, 255, 235, 90, 255)
        img:drawCircle(756, 366, 8, 178, 184, 220, 255)
        save_png(img, "raycaster_full_scene_day_night.png")
    end)

    -- Does: Binds a draw-target shader to the stored raycaster scene presentation path and records getter/cleanup behavior.
    -- Shows: Raycaster keeps only a shader handle while render owns WGSL validation and command execution.
    -- Artifact: tests/artifacts/current/raycaster/raycaster_shader_binding_contract.txt
    -- Why: The roadmap calls out raycaster surfaces as shader hook candidates, and this proves the public binding contract.
    it("TXT: shader binding contract", function()
        local shader = lurek.render.newShader([[
@fragment
fn fs(@location(0) color: vec4<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(color.rgb * vec3<f32>(1.0, 0.92, 0.84), color.a);
}
]], { target = "draw" })
        lurek.raycaster.setShader(shader)
        local bound = lurek.raycaster.getShader()
        local rc = make_room(8, 8)
        rc:setCell(6, 4, 2)
        rc:buildScene(params(3.0, 4.0, 0.0, 160, 90), {}, {}, {})
        lurek.raycaster.setShader(nil)
        local text = table.concat({
            "Raycaster shader binding evidence",
            "constructor=lurek.render.newShader",
            "target=draw",
            "shader_id=" .. tostring(shader:getId()),
            "module.setShader.accepted=" .. tostring(bound ~= nil),
            "module.getShader.id=" .. tostring(bound and bound:getId()),
            "scene.build.queued_for_render=true",
            "module.shader.cleared=" .. tostring(lurek.raycaster.getShader() == nil),
        }, "\n")
        local path = OUT .. "raycaster_shader_binding_contract.txt"
        if write_file then write_file(path, text) else lurek.filesystem.write(path, text) end
        expect_evidence_created(path)
    end)
end)

test_summary()
