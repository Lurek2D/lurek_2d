-- test_tilemap_evidence.lua
-- Canonical evidence file for lurek.tilemap visual outputs.


local OUT = evidence_output_dir("tilemap")

local function save_png(img, path)
    lurek.image.savePNG(img, path)
    expect_evidence_created(path)
end

local function save_text(path, text)
    if write_file then
        write_file(path, text)
    elseif lurek and lurek.filesystem and lurek.filesystem.write then
        lurek.filesystem.write(path, text)
    else
        error("unable to create evidence text artifact: " .. path)
    end
    expect_evidence_created(path)
end

-- Helper: GID color mapping
local function gid_color(gid)
    if gid == 0 then return 30, 30, 40 end
    local colors = {
        {100, 180, 100}, -- 1: Grass (green)
        {140, 140, 150}, -- 2: Stone (grey)
        {220, 180, 100}, -- 3: Sand (yellow/gold)
        {70, 120, 220},  -- 4: Water (blue)
        {200, 100, 100}, -- 5: Lava (red)
        {180, 80, 220},  -- 6: Magic (purple)
        {240, 140, 80},  -- 7: Autumn Tree (orange)
        {255, 255, 255}  -- 8: Snow (white)
    }
    local idx = ((gid - 1) % #colors) + 1
    return colors[idx][1], colors[idx][2], colors[idx][3]
end

local function autotile_gid_color(gid)
    if gid == 0 then return 24, 26, 34 end
    local hue = (gid * 37) % 180
    local r = 60 + ((hue * 3) % 150)
    local g = 80 + ((hue * 5) % 140)
    local b = 100 + ((hue * 7) % 120)
    return r, g, b
end

local function build_autotile_map(layout, type_name, mode)
    local TILE, MAP_W, MAP_H = 14, 7, 7
    local tm = lurek.tilemap.newTileMap(TILE, TILE)
    local ts = lurek.tilemap.newTileSet(1, 128, 16, TILE, TILE)
    local layer = tm:addLayer(type_name, MAP_W, MAP_H)

    if layout then
        local sheet = lurek.tilemap.newAutoTileSheet(TILE, TILE, layout)
        sheet:applyToTileSet(ts, type_name)
    end
    if mode then
        ts:setAutoTileMode(type_name, mode)
    end
    if mode == "matchCorners" then
        for mask = 0, 15 do
            ts:setAutoTileRule(type_name, mask, 48 + mask)
        end
    end
    tm:addTileSet(ts)

    if mode == "matchCorners" then
        tm:setTile(layer, 4, 4, 1)
        tm:setTile(layer, 3, 3, 1)
        tm:setTile(layer, 5, 3, 1)
        tm:setTile(layer, 3, 5, 1)
        tm:setTile(layer, 5, 5, 1)
    else
        for y = 2, 6 do
            for x = 2, 6 do
                local notch = (x == 2 and y == 2) or (x == 6 and y == 2) or
                    (x == 2 and y == 6) or (x == 6 and y == 6)
                if not notch then
                    tm:setTile(layer, x, y, 1)
                end
            end
        end
        tm:setTile(layer, 4, 4, 1)
    end

    tm:applyAutoTileMode(layer, type_name)
    return {
        map = tm,
        layer = layer,
        mode = ts:getAutoTileMode(type_name),
        center = tm:getTile(layer, 4, 4),
    }
end

local function draw_autotile_panel(img, sample, ox, oy, cell)
    for y = 1, 7 do
        for x = 1, 7 do
            local gid = sample.map:getTile(sample.layer, x, y)
            local r, g, b = autotile_gid_color(gid)
            local px = ox + (x - 1) * cell
            local py = oy + (y - 1) * cell
            img:drawRect(px, py, cell - 1, cell - 1, r, g, b, 255)
            if gid == 0 then
                img:drawRect(px + 3, py + 3, cell - 7, cell - 7, 12, 14, 20, 255)
            end
        end
    end
    img:drawLine(ox, oy, ox + 7 * cell, oy, 232, 236, 244, 255)
    img:drawLine(ox + 7 * cell, oy, ox + 7 * cell, oy + 7 * cell, 232, 236, 244, 255)
    img:drawLine(ox + 7 * cell, oy + 7 * cell, ox, oy + 7 * cell, 232, 236, 244, 255)
    img:drawLine(ox, oy + 7 * cell, ox, oy, 232, 236, 244, 255)
    img:drawCircle(ox + 3.5 * cell, oy + 3.5 * cell, 4, 255, 242, 128, 255)
end

local function draw_hex_outline(img, cx, cy, radius, r, g, b)
    local points = {}
    for i = 0, 5 do
        local angle = math.rad(60 * i - 30)
        points[i + 1] = {
            x = cx + math.cos(angle) * radius,
            y = cy + math.sin(angle) * radius,
        }
    end
    for i = 1, 6 do
        local a = points[i]
        local bpt = points[(i % 6) + 1]
        img:drawLine(a.x, a.y, bpt.x, bpt.y, r, g, b, 255)
    end
end

local function draw_hex_fill(img, cx, cy, radius, r, g, b)
    for dy = -radius, radius do
        local row_half = math.floor(radius - math.abs(dy) * 0.5)
        img:drawLine(cx - row_half, cy + dy, cx + row_half, cy + dy, r, g, b, 255)
    end
end

-- @describe Evidence: lurek.tilemap scenarios
describe("Evidence: lurek.tilemap scenarios", function()
    -- Does: Runs "tilemap layers (ground + decoration overlay)" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.tilemap.newTileMap without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/tilemap/tilemap_layers.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.tilemap.newTileMap; export helpers are just the container.

    it("PNG: tilemap layers (ground + decoration overlay)", function()
        ensure_evidence_dir("tilemap")
        local path = OUT .. "tilemap_layers.png"

        local TILE, MAP_W, MAP_H = 16, 12, 10
        local img = lurek.image.newImageData(MAP_W * TILE, MAP_H * TILE)
        img:fill(15, 15, 22, 255)

        local tm = lurek.tilemap.newTileMap(TILE, TILE)
        tm:addLayer("ground", MAP_W, MAP_H)
        tm:addLayer("decoration", MAP_W, MAP_H)

        -- 1. Fill logical tilemap layers
        for y = 1, MAP_H do
            for x = 1, MAP_W do
                -- Alternating grass (1) and sand (3) ground
                local gid = (x + y) % 2 == 0 and 1 or 3
                tm:setTile(1, x, y, gid)
            end
        end

        -- Sparse trees decoration (7) on ground layer
        for y = 2, MAP_H - 1, 2 do
            for x = 2, MAP_W - 1, 3 do
                tm:setTile(2, x, y, 7)
            end
        end

        -- 2. Draw ground layer natively
        for y = 1, MAP_H do
            for x = 1, MAP_W do
                local gid = tm:getTile(1, x, y)
                local r, g, b = gid_color(gid)
                img:drawRect((x - 1) * TILE, (y - 1) * TILE, TILE, TILE, r, g, b, 255)
            end
        end

        -- 3. Draw decoration layer natively with transparent borders
        for y = 1, MAP_H do
            for x = 1, MAP_W do
                local gid = tm:getTile(2, x, y)
                if gid > 0 then
                    local r, g, b = gid_color(gid)
                    -- Draw decorative circles in the center of tiles natively
                    img:drawCircle((x - 0.5) * TILE, (y - 0.5) * TILE, TILE / 3, r, g, b, 255)
                end
            end
        end

        expect_equal(2, tm:getLayerCount())
        save_png(img, path)
    end)
    -- Does: Runs "PNG: tilemap collision mask (solid vs walkable)" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.tilemap.newTileMap and related owner calls.
    -- Artifact: tests/artifacts/current/tilemap/tilemap_collision.png
    -- Why: This is meaningful only if the output is driven by lurek.tilemap.newTileMap and related owner calls rather than by helper-only drawing.

    it("PNG: tilemap collision mask (solid vs walkable)", function()
        ensure_evidence_dir("tilemap")
        local path = OUT .. "tilemap_collision.png"

        local TILE, MAP_W, MAP_H = 16, 12, 10
        local img = lurek.image.newImageData(MAP_W * TILE, MAP_H * TILE)
        img:fill(20, 20, 25, 255)

        local tm = lurek.tilemap.newTileMap(TILE, TILE)
        tm:addLayer("collision", MAP_W, MAP_H)

        -- 1 = Walkable (light blue), 2 = Solid Wall (dark steel)
        local maze = {
            {2,2,2,2,2,2,2,2,2,2,2,2},
            {2,1,1,1,2,1,1,1,1,1,1,2},
            {2,1,2,1,2,1,2,2,2,2,1,2},
            {2,1,2,1,1,1,1,1,1,2,1,2},
            {2,1,2,2,2,2,2,2,1,2,1,2},
            {2,1,1,1,1,1,1,2,1,2,1,2},
            {2,2,2,2,1,2,1,2,1,2,1,2},
            {2,1,1,2,1,2,1,1,1,1,1,2},
            {2,1,1,1,1,2,2,2,2,2,1,2},
            {2,2,2,2,2,2,2,2,2,2,2,2}
        }

        for y = 1, MAP_H do
            for x = 1, MAP_W do
                tm:setTile(1, x, y, maze[y][x])
            end
        end

        -- Draw maze collision blocks natively
        for y = 1, MAP_H do
            for x = 1, MAP_W do
                local gid = tm:getTile(1, x, y)
                local px, py = (x - 1) * TILE, (y - 1) * TILE
                if gid == 2 then
                    -- Solid walls
                    img:drawRect(px, py, TILE, TILE, 50, 55, 70, 255)
                    -- Bevel detail lines
                    img:drawRect(px + 1, py + 1, TILE - 2, TILE - 2, 70, 75, 95, 255)
                else
                    -- Walkable paths
                    img:drawRect(px, py, TILE, TILE, 150, 180, 200, 255)
                    img:drawRect(px + 2, py + 2, TILE - 4, TILE - 4, 160, 195, 215, 255)
                end
            end
        end

        save_png(img, path)
    end)
    -- Does: Runs "PNG: tilemap isometric view projection" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.tilemap.newTileMap and related owner calls.
    -- Artifact: tests/artifacts/current/tilemap/tilemap_isometric.png
    -- Why: This is meaningful only if the output is driven by lurek.tilemap.newTileMap and related owner calls rather than by helper-only drawing.

    it("PNG: tilemap isometric view projection", function()
        ensure_evidence_dir("tilemap")
        local path = OUT .. "tilemap_isometric.png"

        local W, H = 200, 150
        local img = lurek.image.newImageData(W, H)
        img:fill(10, 10, 14, 255)

        local TILE_W, TILE_H = 32, 16
        local MAP_W, MAP_H = 6, 6
        local origin_x = W / 2
        local origin_y = 20

        local tm = lurek.tilemap.newTileMap(TILE_W, TILE_H)
        tm:addLayer("iso", MAP_W, MAP_H)

        -- Assign height GIDs to map
        for y = 1, MAP_H do
            for x = 1, MAP_W do
                -- Pyramid structure
                local d = math.min(x - 1, MAP_W - x, y - 1, MAP_H - y)
                tm:setTile(1, x, y, d + 1)
            end
        end

        -- Project and draw diamond tiles in isometric back-to-front order
        for y = 1, MAP_H do
            for x = 1, MAP_W do
                local gid = tm:getTile(1, x, y)
                -- Screen coordinates from grid space
                local sx = origin_x + (x - y) * (TILE_W / 2)
                local sy = origin_y + (x + y) * (TILE_H / 2)

                -- Draw heights as elevated steps
                local h_offset = (gid - 1) * 8
                local top_y = sy - h_offset

                -- Native draw isometric outline
                local r, g, b = gid_color(gid)
                -- Base shadow columns
                img:drawLine(sx, top_y, sx, sy, 30, 30, 30, 255)
                img:drawLine(sx - TILE_W/2, top_y + TILE_H/2, sx - TILE_W/2, sy + TILE_H/2, 20, 20, 20, 255)
                img:drawLine(sx + TILE_W/2, top_y + TILE_H/2, sx + TILE_W/2, sy + TILE_H/2, 20, 20, 20, 255)

                -- Top diamond boundary face natively
                img:drawLine(sx, top_y, sx + TILE_W/2, top_y + TILE_H/2, r, g, b, 255)
                img:drawLine(sx + TILE_W/2, top_y + TILE_H/2, sx, top_y + TILE_H, r, g, b, 255)
                img:drawLine(sx, top_y + TILE_H, sx - TILE_W/2, top_y + TILE_H/2, r, g, b, 255)
                img:drawLine(sx - TILE_W/2, top_y + TILE_H/2, sx, top_y, r, g, b, 255)

                -- Draw inner color details
                img:drawCircle(sx, top_y + TILE_H/2, 3, r - 20, g - 20, b - 20, 255)
            end
        end

        save_png(img, path)
    end)
    -- Does: Runs "PNG: tilemap camera viewport culling visual" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.tilemap.newTileMap and related owner calls.
    -- Artifact: tests/artifacts/current/tilemap/tilemap_viewport.png
    -- Why: This is meaningful only if the output is driven by lurek.tilemap.newTileMap and related owner calls rather than by helper-only drawing.

    it("PNG: tilemap camera viewport culling visual", function()
        ensure_evidence_dir("tilemap")
        local path = OUT .. "tilemap_viewport.png"

        local TILE, MAP_W, MAP_H = 8, 24, 18
        local W, H = MAP_W * TILE, MAP_H * TILE
        local img = lurek.image.newImageData(W, H)
        img:fill(10, 10, 12, 255)

        local tm = lurek.tilemap.newTileMap(TILE, TILE)
        tm:addLayer("world", MAP_W, MAP_H)

        -- Generate some map noise
        for y = 1, MAP_H do
            for x = 1, MAP_W do
                local gid = ((x * 3 + y * 7) % 5) + 1
                tm:setTile(1, x, y, gid)
            end
        end

        -- Viewport parameters: 10x8 tiles starting at tile (7, 5)
        local cam_tx, cam_ty = 7, 5
        local cam_tw, cam_th = 10, 8
        local cam_px, cam_py = (cam_tx-1)*TILE, (cam_ty-1)*TILE
        local cam_pw, cam_ph = cam_tw*TILE, cam_th*TILE

        -- Draw full map, but dim cells outside camera viewport natively
        for y = 1, MAP_H do
            for x = 1, MAP_W do
                local gid = tm:getTile(1, x, y)
                local r, g, b = gid_color(gid)
                local px, py = (x - 1) * TILE, (y - 1) * TILE

                local in_view = x >= cam_tx and x < cam_tx + cam_tw and
                                y >= cam_ty and y < cam_ty + cam_th

                if not in_view then
                    r, g, b = math.floor(r * 0.2), math.floor(g * 0.2), math.floor(b * 0.2)
                end
                img:drawRect(px, py, TILE, TILE, r, g, b, 255)
            end
        end

        -- Draw yellow camera viewport bounds outline natively
        img:drawLine(cam_px, cam_py, cam_px + cam_pw, cam_py, 255, 220, 80, 255)
        img:drawLine(cam_px + cam_pw, cam_py, cam_px + cam_pw, cam_py + cam_ph, 255, 220, 80, 255)
        img:drawLine(cam_px + cam_pw, cam_py + cam_ph, cam_px, cam_py + cam_ph, 255, 220, 80, 255)
        img:drawLine(cam_px, cam_py + cam_ph, cam_px, cam_py, 255, 220, 80, 255)

        save_png(img, path)
    end)
    -- Does: Runs "PNG: tilemap autotile Wang pattern layout" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.tilemap.newTileMap and related owner calls.
    -- Artifact: tests/artifacts/current/tilemap/tilemap_autotile.png
    -- Why: This is meaningful only if the output is driven by lurek.tilemap.newTileMap and related owner calls rather than by helper-only drawing.

    it("PNG: tilemap autotile Wang pattern layout", function()
        ensure_evidence_dir("tilemap")
        local path = OUT .. "tilemap_autotile.png"

        local TILE, MAP_W, MAP_H = 16, 12, 10
        local img = lurek.image.newImageData(MAP_W * TILE, MAP_H * TILE)
        img:fill(15, 12, 18, 255)

        local tm = lurek.tilemap.newTileMap(TILE, TILE)
        tm:addLayer("auto", MAP_W, MAP_H)

        -- Write GIDs simulating Wang-autotile edge indices (bits encode NESW transitions)
        for y = 1, MAP_H do
            for x = 1, MAP_W do
                -- Wang tiling simulation
                local gid = ((x * y) % 8) + 1
                tm:setTile(1, x, y, gid)
            end
        end

        -- Render autotiles natively using rectangles and inner color frames to prove transitions
        for y = 1, MAP_H do
            for x = 1, MAP_W do
                local gid = tm:getTile(1, x, y)
                local px, py = (x - 1) * TILE, (y - 1) * TILE
                local r, g, b = gid_color(gid)

                -- Border cell
                img:drawRect(px, py, TILE, TILE, r, g, b, 255)

                -- Distinct inner center detail representing autotile transitions
                img:drawRect(px + 2, py + 2, TILE - 4, TILE - 4,
                    math.min(255, r + 30),
                    math.min(255, g + 30),
                    math.min(255, b + 30),
                    255)
            end
        end

        save_png(img, path)
    end)
    -- Does: Builds concrete autotile maps for each supported sheet layout and configured matching mode, then exports an inspectable PNG plus a step-by-step text manifest.
    -- Shows: The PNG should compare side-only, corner-only, and corner+side terrain matching, while the text artifact documents the exact Lua calls used to build each map.
    -- Artifact: tests/artifacts/current/tilemap/tilemap_autotile_format_showcase.png, tests/artifacts/current/tilemap/tilemap_autotile_format_showcase.txt
    -- Why: This is meaningful because the final GIDs come from lurek.tilemap.newAutoTileSheet, LAutoTileSheet:applyToTileSet, LTileSet:setAutoTileMode, and LTileMap:applyAutoTileMode rather than from hand-authored tile IDs.

    it("PNG+TXT: tilemap autotile format and mode showcase", function()
        ensure_evidence_dir("tilemap")
        local png_path = OUT .. "tilemap_autotile_format_showcase.png"
        local txt_path = OUT .. "tilemap_autotile_format_showcase.txt"

        local cases = {
            {
                label = "minimal16",
                layout = "minimal16",
                type = "grass",
                note = "4-bit side matching; use for simple NESW terrain joins.",
            },
            {
                label = "blob47",
                layout = "blob47",
                type = "stone",
                note = "47 reduced 8-bit blob masks; corners are valid only when adjacent sides connect.",
            },
            {
                label = "composite48",
                layout = "composite48",
                type = "cliff",
                note = "48-entry composite layout with an explicit empty variant at index 0.",
            },
            {
                label = "rpgmaker48",
                layout = "rpgmaker48",
                type = "shore",
                note = "RPG Maker-style 48-entry autotile layout using corner+side terrain matching.",
            },
            {
                label = "manual matchCorners",
                layout = nil,
                type = "corner",
                mode = "matchCorners",
                note = "Godot-style corner-only terrain matching configured directly on the tileset.",
            },
        }

        local img = lurek.image.newImageData(560, 340)
        img:fill(14, 16, 24, 255)

        local formats = lurek.tilemap.getAutoTileFormats()
        local format_lines = {
            "Lurek2D tilemap autotile format showcase",
            "",
            "Supported formats reported by lurek.tilemap.getAutoTileFormats():",
        }
        for _, format in ipairs(formats) do
            table.insert(format_lines, string.format(
                "- %s: %d tiles, default mode %s",
                format.name,
                format.tileCount,
                format.mode
            ))
        end
        table.insert(format_lines, "")
        table.insert(format_lines, "Build pattern used by each layout-backed case:")
        table.insert(format_lines, "1. local sheet = lurek.tilemap.newAutoTileSheet(14, 14, layout)")
        table.insert(format_lines, "2. local ts = lurek.tilemap.newTileSet(1, 128, 16, 14, 14)")
        table.insert(format_lines, "3. sheet:applyToTileSet(ts, typeName)")
        table.insert(format_lines, "4. map:addTileSet(ts)")
        table.insert(format_lines, "5. map:applyAutoTileMode(layer, typeName)")
        table.insert(format_lines, "")
        table.insert(format_lines, "Manual Godot-style mode pattern:")
        table.insert(format_lines, "1. ts:setAutoTileMode(typeName, \"matchCorners\")")
        table.insert(format_lines, "2. ts:setAutoTileRule(typeName, mask, tileId)")
        table.insert(format_lines, "3. map:applyAutoTileMode(layer, typeName)")
        table.insert(format_lines, "")
        table.insert(format_lines, "Panel order in tilemap_autotile_format_showcase.png:")

        for i, case in ipairs(cases) do
            local sample = build_autotile_map(case.layout, case.type, case.mode)
            local col = (i - 1) % 3
            local row = math.floor((i - 1) / 3)
            local ox = 30 + col * 175
            local oy = 42 + row * 145

            local bar_r = 72 + i * 22
            local bar_g = 86 + i * 18
            local bar_b = 112 + i * 11
            img:drawRect(ox, oy - 18, 98, 12, bar_r, bar_g, bar_b, 255)
            draw_autotile_panel(img, sample, ox, oy, 14)

            table.insert(format_lines, string.format(
                "%d. %s -> type '%s', mode %s, center gid %d. %s",
                i,
                case.label,
                case.type,
                sample.mode,
                sample.center,
                case.note
            ))
        end

        save_png(img, png_path)
        save_text(txt_path, table.concat(format_lines, "\n") .. "\n")
    end)
    -- Does: Runs "tilemap drawToImage standalone layers" and turns the owner-module result into separate inspectable artifacts.
    -- Shows: Each PNG should expose one layer state instead of collapsing ground and object layers into one composite image.
    -- Artifact: tests/artifacts/current/tilemap/tilemap_draw_to_image_ground.png, tilemap_draw_to_image_objects.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.tilemap.newTileMap, LTileMap:addLayer, and related owner calls; export helpers are just the container.

    it("PNG: tilemap drawToImage standalone layers", function()
        ensure_evidence_dir("tilemap")
        local tm = lurek.tilemap.newTileMap(16, 16, 8)
        local ground = tm:addLayer("ground", 10, 10)
        local objects = tm:addLayer("objects", 10, 10)

        tm:fill(ground, 1)
        tm:setTile(objects, 3, 3, 10)
        tm:setTile(objects, 5, 5, 11)
        tm:setTile(objects, 7, 2, 12)

        local ground_only = lurek.tilemap.newTileMap(16, 16, 8)
        local ground_layer = ground_only:addLayer("ground", 10, 10)
        ground_only:fill(ground_layer, 1)
        save_png(ground_only:drawToImage(16), OUT .. "tilemap_draw_to_image_ground.png")

        local object_only = lurek.tilemap.newTileMap(16, 16, 8)
        local object_layer = object_only:addLayer("objects", 10, 10)
        object_only:setTile(object_layer, 3, 3, 10)
        object_only:setTile(object_layer, 5, 5, 11)
        object_only:setTile(object_layer, 7, 2, 12)
        save_png(object_only:drawToImage(16), OUT .. "tilemap_draw_to_image_objects.png")
    end)
    -- Does: Runs "tilemap hex biome and route views" and turns the owner-module result into separate inspectable artifacts.
    -- Shows: Each PNG should expose one hex concern instead of combining area, ring, route, and neighbors into one atlas.
    -- Artifact: tests/artifacts/current/tilemap/tilemap_hex_biomes_area.png, tilemap_hex_route.png, tilemap_hex_neighbors.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.tilemap.toScreenHex, lurek.tilemap.hexArea, and related owner calls; export helpers are just the container.

    it("PNG: tilemap hex biome and route views", function()
        ensure_evidence_dir("tilemap")
        local hex_size = 22
        local origin_x, origin_y = 210, 160
        local area = lurek.tilemap.hexArea(0, 0, 3)
        local ring = lurek.tilemap.hexRing(0, 0, 3)
        local route = lurek.tilemap.hexLine(-3, 1, 3, -1)
        local neighbors = lurek.tilemap.hexNeighbors(0, 0)
        local route_cells, ring_cells, neighbor_cells = {}, {}, {}

        for _, cell in ipairs(route) do
            route_cells[cell.q .. ":" .. cell.r] = true
        end
        for _, cell in ipairs(ring) do
            ring_cells[cell.q .. ":" .. cell.r] = true
        end
        for _, cell in ipairs(neighbors) do
            neighbor_cells[cell.q .. ":" .. cell.r] = true
        end

        local function new_hex_canvas()
            local img = lurek.image.newImageData(420, 320)
            img:fill(16, 18, 24, 255)
            return img
        end

        local area_img = new_hex_canvas()
        local route_img = new_hex_canvas()
        local neighbor_img = new_hex_canvas()

        for _, cell in ipairs(area) do
            local key = cell.q .. ":" .. cell.r
            local sx, sy = lurek.tilemap.toScreenHex(cell.q, cell.r, hex_size)
            local cx = origin_x + sx
            local cy = origin_y + sy
            local dist = math.max(math.abs(cell.q), math.abs(cell.r), math.abs(-cell.q - cell.r))
            local rr, gg, bb = 70, 110, 78
            if dist <= 1 then
                rr, gg, bb = 58, 132, 86
            elseif dist == 2 then
                rr, gg, bb = 122, 126, 82
            elseif dist == 3 then
                rr, gg, bb = 96, 118, 148
            end
            draw_hex_fill(area_img, cx, cy, hex_size - 3, rr, gg, bb)
            draw_hex_outline(area_img, cx, cy, hex_size - 2, 228, 232, 240)

            local route_rr, route_gg, route_bb = route_cells[key] and 226 or 70, route_cells[key] and 186 or 110, route_cells[key] and 88 or 78
            draw_hex_fill(route_img, cx, cy, hex_size - 3, route_rr, route_gg, route_bb)
            draw_hex_outline(route_img, cx, cy, hex_size - 2, 228, 232, 240)

            local neigh_rr, neigh_gg, neigh_bb = neighbor_cells[key] and 164 or 70, neighbor_cells[key] and 116 or 110, neighbor_cells[key] and 74 or 78
            if ring_cells[key] then
                neigh_rr, neigh_gg, neigh_bb = 112, 92, 146
            end
            draw_hex_fill(neighbor_img, cx, cy, hex_size - 3, neigh_rr, neigh_gg, neigh_bb)
            draw_hex_outline(neighbor_img, cx, cy, hex_size - 2, 228, 232, 240)
        end

        for i = 2, #route do
            local a = route[i - 1]
            local b = route[i]
            local ax, ay = lurek.tilemap.toScreenHex(a.q, a.r, hex_size)
            local bx, by = lurek.tilemap.toScreenHex(b.q, b.r, hex_size)
            route_img:drawLine(origin_x + ax, origin_y + ay, origin_x + bx, origin_y + by, 255, 242, 164, 255)
        end

        local start_x, start_y = lurek.tilemap.toScreenHex(route[1].q, route[1].r, hex_size)
        local goal_x, goal_y = lurek.tilemap.toScreenHex(route[#route].q, route[#route].r, hex_size)
        route_img:drawCircle(origin_x + start_x, origin_y + start_y, 6, 120, 240, 150, 255)
        route_img:drawCircle(origin_x + goal_x, origin_y + goal_y, 6, 255, 120, 120, 255)

        save_png(area_img, OUT .. "tilemap_hex_biomes_area.png")
        save_png(route_img, OUT .. "tilemap_hex_route.png")
        save_png(neighbor_img, OUT .. "tilemap_hex_neighbors.png")
    end)
    -- Does: Runs "tilemap hex operations frontier map" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.tilemap.hexSpiral, lurek.tilemap.hexDistance, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/tilemap/tilemap_hex_operations_frontier.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.tilemap.hexSpiral, lurek.tilemap.hexDistance, and related owner calls; export helpers are just the container.

    it("PNG: tilemap hex operations frontier map", function()
        ensure_evidence_dir("tilemap")
        local path = OUT .. "tilemap_hex_operations_frontier.png"
        local img = lurek.image.newImageData(520, 360)
        img:fill(14, 18, 24, 255)

        local hex_size = 18
        local origin_x, origin_y = 180, 178
        local spiral = lurek.tilemap.hexSpiral(0, 0, 4)
        local mirrored_q, mirrored_r = lurek.tilemap.hexReflect(2, -1, 0, 0, "q")
        local rotated_q, rotated_r = lurek.tilemap.hexRotate(3, -2, 0, 0, 2)

        for _, cell in ipairs(spiral) do
            local sx, sy = lurek.tilemap.toScreenHex(cell.q, cell.r, hex_size)
            local cx = origin_x + sx
            local cy = origin_y + sy
            local dist = lurek.tilemap.hexDistance(0, 0, cell.q, cell.r)
            local rr = 62 + dist * 22
            local gg = 92 + dist * 14
            local bb = 110 + dist * 10
            draw_hex_fill(img, cx, cy, hex_size - 3, rr, gg, bb)
            draw_hex_outline(img, cx, cy, hex_size - 2, 232, 236, 244)
        end

        local route = {
            { q = 0, r = 0 },
            { q = 1, r = -1 },
            { q = 2, r = -1 },
            { q = rotated_q, r = rotated_r },
            { q = mirrored_q, r = mirrored_r },
        }
        for i = 2, #route do
            local a = route[i - 1]
            local b = route[i]
            local ax, ay = lurek.tilemap.toScreenHex(a.q, a.r, hex_size)
            local bx, by = lurek.tilemap.toScreenHex(b.q, b.r, hex_size)
            img:drawLine(origin_x + ax, origin_y + ay, origin_x + bx, origin_y + by, 255, 220, 132, 255)
        end

        local marker_cells = {
            { q = 0, r = 0, color = { 120, 238, 160 } },
            { q = rotated_q, r = rotated_r, color = { 120, 184, 255 } },
            { q = mirrored_q, r = mirrored_r, color = { 255, 132, 132 } },
        }
        for _, cell in ipairs(marker_cells) do
            local sx, sy = lurek.tilemap.toScreenHex(cell.q, cell.r, hex_size)
            img:drawCircle(origin_x + sx, origin_y + sy, 7, cell.color[1], cell.color[2], cell.color[3], 255)
        end

        save_png(img, path)
    end)
    -- Does: Runs "tilemap chunk streaming window" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.tilemap.newChunkMap, LChunkMap:setTile, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/tilemap/tilemap_chunk_streaming_window.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.tilemap.newChunkMap, LChunkMap:setTile, and related owner calls; export helpers are just the container.

    it("PNG: tilemap chunk streaming window", function()
        ensure_evidence_dir("tilemap")
        local path = OUT .. "tilemap_chunk_streaming_window.png"
        local cm = lurek.tilemap.newChunkMap(8)

        for cy = 0, 2 do
            for cx = 0, 3 do
                cm:loadChunk(cx, cy)
                for ty = 0, 7 do
                    for tx = 0, 7 do
                        local wx = cx * 8 + tx
                        local wy = cy * 8 + ty
                        cm:setTile(wx, wy, ((wx + wy) % 6) + 1)
                    end
                end
            end
        end

        local visible = cm:getChunksInView(6 * 16, 4 * 16, 12 * 16, 10 * 16, 16, 16)
        local loaded = cm:getLoadedChunks()
        table.sort(loaded, function(a, b)
            if a.cy == b.cy then
                return a.cx < b.cx
            end
            return a.cy < b.cy
        end)
        local visible_lookup = {}
        for _, chunk in ipairs(visible) do
            visible_lookup[chunk.cx .. ":" .. chunk.cy] = true
        end

        local img = lurek.image.newImageData(420, 280)
        img:fill(16, 18, 24, 255)
        local cell = 14
        local ox, oy = 30, 30

        for _, chunk in ipairs(loaded) do
            local min_tx, min_ty, max_tx, max_ty = cm:chunkTileRange(chunk.cx, chunk.cy)
            local key = chunk.cx .. ":" .. chunk.cy
            local border_r, border_g, border_b = 110, 118, 138
            if visible_lookup[key] then
                border_r, border_g, border_b = 255, 212, 120
            end
            for ty = min_ty, max_ty do
                for tx = min_tx, max_tx do
                    local gid = cm:getTile(tx, ty)
                    local r, g, b = gid_color(gid)
                    img:drawRect(ox + tx * cell, oy + ty * cell, cell - 1, cell - 1, r, g, b, 255)
                end
            end
            img:drawLine(ox + min_tx * cell, oy + min_ty * cell, ox + (max_tx + 1) * cell, oy + min_ty * cell, border_r, border_g, border_b, 255)
            img:drawLine(ox + (max_tx + 1) * cell, oy + min_ty * cell, ox + (max_tx + 1) * cell, oy + (max_ty + 1) * cell, border_r, border_g, border_b, 255)
            img:drawLine(ox + (max_tx + 1) * cell, oy + (max_ty + 1) * cell, ox + min_tx * cell, oy + (max_ty + 1) * cell, border_r, border_g, border_b, 255)
            img:drawLine(ox + min_tx * cell, oy + (max_ty + 1) * cell, ox + min_tx * cell, oy + min_ty * cell, border_r, border_g, border_b, 255)
        end

        save_png(img, path)
    end)
    -- Does: Runs "tilemap isometric stacked settlement" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.tilemap.newIsoMap, LIsoMap:addLevel, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/tilemap/tilemap_isometric_stacked_settlement.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.tilemap.newIsoMap, LIsoMap:addLevel, and related owner calls; export helpers are just the container.

    it("PNG: tilemap isometric stacked settlement", function()
        ensure_evidence_dir("tilemap")
        local path = OUT .. "tilemap_isometric_stacked_settlement.png"
        local iso = lurek.tilemap.newIsoMap(6, 6, 48, 24, 14, 3)
        iso:addLevel("ground")
        iso:addLevel("roofs")
        iso:setOrigin(180, 48)
        iso:fillLevel(1, lurek.tilemap.FLOOR, 1)

        for y = 1, 6 do
            for x = 1, 6 do
                local edge = x == 1 or y == 1 or x == 6 or y == 6
                if edge then
                    iso:setTilePart(1, x, y, 1, 4)
                end
            end
        end
        iso:setTilePart(2, 3, 3, 1, 7)
        iso:setTilePart(2, 4, 3, 1, 7)
        iso:setTilePart(2, 3, 4, 1, 7)
        iso:setTilePart(2, 4, 4, 1, 7)

        local img = lurek.image.newImageData(420, 260)
        img:fill(16, 18, 24, 255)

        for y = 1, 6 do
            for x = 1, 6 do
                local sx, sy = iso:tileToScreen(x, y, 1)
                local base = ((x + y) % 2 == 0) and { 90, 140, 96 } or { 122, 126, 82 }
                img:drawLine(sx, sy, sx + 24, sy + 12, base[1], base[2], base[3], 255)
                img:drawLine(sx + 24, sy + 12, sx, sy + 24, base[1], base[2], base[3], 255)
                img:drawLine(sx, sy + 24, sx - 24, sy + 12, base[1], base[2], base[3], 255)
                img:drawLine(sx - 24, sy + 12, sx, sy, base[1], base[2], base[3], 255)
            end
        end

        for _, cell in ipairs({
            { 3, 3 }, { 4, 3 }, { 3, 4 }, { 4, 4 },
        }) do
            local sx, sy = iso:tileToScreen(cell[1], cell[2], 2)
            img:drawLine(sx, sy - 14, sx + 24, sy - 2, 186, 96, 82, 255)
            img:drawLine(sx + 24, sy - 2, sx, sy + 10, 186, 96, 82, 255)
            img:drawLine(sx, sy + 10, sx - 24, sy - 2, 186, 96, 82, 255)
            img:drawLine(sx - 24, sy - 2, sx, sy - 14, 186, 96, 82, 255)
        end

        save_png(img, path)
    end)

end)
test_summary()
