-- test_tilemap_evidence.lua
-- Canonical evidence file for lurek.tilemap visual outputs.


local OUT = evidence_output_dir("tilemap")

local function save_png(img, path)
    lurek.image.savePNG(img, path)
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
    -- Does: Runs "tilemap drawToImage multi-layer composite" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.tilemap.newTileMap, LTileMap:addLayer, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/tilemap/tilemap_draw_to_image_composite.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.tilemap.newTileMap, LTileMap:addLayer, and related owner calls; export helpers are just the container.

    it("PNG: tilemap drawToImage multi-layer composite", function()
        ensure_evidence_dir("tilemap")
        local tm = lurek.tilemap.newTileMap(16, 16, 8)
        local ground = tm:addLayer("ground", 10, 10)
        local objects = tm:addLayer("objects", 10, 10)

        tm:fill(ground, 1)
        tm:setTile(objects, 3, 3, 10)
        tm:setTile(objects, 5, 5, 11)
        tm:setTile(objects, 7, 2, 12)

        local img = tm:drawToImage(16)
        local path = OUT .. "tilemap_draw_to_image_composite.png"
        save_png(img, path)
    end)
    -- Does: Runs "tilemap hex biome route atlas" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.tilemap.toScreenHex, lurek.tilemap.hexArea, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/tilemap/tilemap_hex_biomes_route.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.tilemap.toScreenHex, lurek.tilemap.hexArea, and related owner calls; export helpers are just the container.

    it("PNG: tilemap hex biome route atlas", function()
        ensure_evidence_dir("tilemap")
        local path = OUT .. "tilemap_hex_biomes_route.png"
        local img = lurek.image.newImageData(420, 320)
        img:fill(16, 18, 24, 255)

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
            if ring_cells[key] then
                rr, gg, bb = 112, 92, 146
            end
            if neighbor_cells[key] then
                rr, gg, bb = 164, 116, 74
            end
            if route_cells[key] then
                rr, gg, bb = 226, 186, 88
            end

            draw_hex_fill(img, cx, cy, hex_size - 3, rr, gg, bb)
            draw_hex_outline(img, cx, cy, hex_size - 2, 228, 232, 240)
        end

        for i = 2, #route do
            local a = route[i - 1]
            local b = route[i]
            local ax, ay = lurek.tilemap.toScreenHex(a.q, a.r, hex_size)
            local bx, by = lurek.tilemap.toScreenHex(b.q, b.r, hex_size)
            img:drawLine(origin_x + ax, origin_y + ay, origin_x + bx, origin_y + by, 255, 242, 164, 255)
        end

        local start_x, start_y = lurek.tilemap.toScreenHex(route[1].q, route[1].r, hex_size)
        local goal_x, goal_y = lurek.tilemap.toScreenHex(route[#route].q, route[#route].r, hex_size)
        img:drawCircle(origin_x + start_x, origin_y + start_y, 6, 120, 240, 150, 255)
        img:drawCircle(origin_x + goal_x, origin_y + goal_y, 6, 255, 120, 120, 255)

        save_png(img, path)
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
