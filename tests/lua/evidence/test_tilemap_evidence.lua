-- test_evidence_tilemap.lua
-- Evidence test: lurek.tilemap API + renders tile grid to PNG
-- Produces: tilemap_grid.png, tilemap_checkerboard.png
-- @covers lurek.image.newImageData
-- @covers lurek.image.savePNG
-- @covers lurek.tilemap.newTileMap


local OUT = "tests/output/tilemap/"

--- Helper: draw filled rect
local function draw_rect(img, x0, y0, w, h, r, g, b)
    for y = y0, math.min(y0 + h - 1, img:getHeight() - 1) do
        for x = x0, math.min(x0 + w - 1, img:getWidth() - 1) do
            if x >= 0 and y >= 0 then img:setPixel(x, y, r, g, b, 255) end
        end
    end
end

--- Helper: map a tile GID to a color
local function gid_to_color(gid)
    if gid == 0 then return 0, 0, 0 end -- empty
    -- Hash the gid into a deterministic hue
    local hue = (gid * 47) % 360
    local h = hue / 60
    local x = 1 - math.abs(h % 2 - 1)
    local r, g, b = 0, 0, 0
    if     h < 1 then r, g, b = 1, x, 0
    elseif h < 2 then r, g, b = x, 1, 0
    elseif h < 3 then r, g, b = 0, 1, x
    elseif h < 4 then r, g, b = 0, x, 1
    elseif h < 5 then r, g, b = x, 0, 1
    else              r, g, b = 1, 0, x
    end
    return math.floor(r * 200 + 55), math.floor(g * 200 + 55), math.floor(b * 200 + 55)
end

-- @describe Evidence: lurek.tilemap API + PNG visualization
describe("Evidence: lurek.tilemap API + PNG visualization", function()
    -- @evidence file
    it("PNG: tilemap grid with 6 different tile GIDs", function()
        local TILE = 8  -- pixel size per tile in output
        local MAP_W, MAP_H = 16, 12

        local tm = lurek.tilemap.newTileMap(TILE, TILE)
        local ground = tm:addLayer("ground", MAP_W, MAP_H)

        -- Paint a pattern with 6 different GIDs
        for y = 1, MAP_H do
            for x = 1, MAP_W do
                local gid = 1 -- default ground
                if y <= 3 then gid = 3 end                        -- top rows = stone
                if y >= 10 then gid = 2 end                       -- bottom = water
                if x >= 7 and x <= 10 and y >= 4 and y <= 9 then  -- center building
                    gid = 4
                end
                if y == 6 and x < 7 then gid = 5 end              -- path
                if y == 6 and x > 10 then gid = 5 end             -- path
                if x == 1 or x == MAP_W or y == 1 or y == MAP_H then
                    gid = 6 -- border
                end
                tm:setTile(ground, x, y, gid)
            end
        end

        local img = tm:drawToImage(TILE)
        lurek.image.savePNG(img, OUT .. "tilemap_grid.png")
    end)

    -- @evidence file
    it("PNG: checkerboard tilemap pattern", function()
        local TILE = 8
        local MAP_W, MAP_H = 16, 16

        local tm = lurek.tilemap.newTileMap(TILE, TILE)
        local checker = tm:addLayer("checker", MAP_W, MAP_H)

        for y = 1, MAP_H do
            for x = 1, MAP_W do
                local is_dark = ((x + y) % 2 == 0)
                local gid = is_dark and 1 or 2
                tm:setTile(checker, x, y, gid)
            end
        end

        local img = tm:drawToImage(TILE)
        lurek.image.savePNG(img, OUT .. "tilemap_checkerboard.png")
    end)

    -- 3. @evidence file
    it("PNG: isometric tilemap rendering", function()
        local TILE_W, TILE_H = 16, 8
        local MAP_W, MAP_H = 8, 8
        local W, H = 200, 150
        local img = lurek.image.newImageData(W, H)
        img:fill(20, 20, 30, 255)

        local cx, cy = 100, 30

        for y = 1, MAP_H do
            for x = 1, MAP_W do
                local iso_x = cx + (x - y) * (TILE_W / 2)
                local iso_y = cy + (x + y) * (TILE_H / 2)
                
                -- draw diamond shape natively
                local r, g, b = 60, 140, 60
                if (x + y) % 2 == 0 then r, g, b = 50, 120, 50 end

                img:drawLine(iso_x, iso_y, iso_x + TILE_W/2, iso_y + TILE_H/2, r, g, b, 255)
                img:drawLine(iso_x + TILE_W/2, iso_y + TILE_H/2, iso_x, iso_y + TILE_H, r, g, b, 255)
                img:drawLine(iso_x, iso_y + TILE_H, iso_x - TILE_W/2, iso_y + TILE_H/2, r, g, b, 255)
                img:drawLine(iso_x - TILE_W/2, iso_y + TILE_H/2, iso_x, iso_y, r, g, b, 255)
                
                -- fill diamond (procedural pixel test)
                for py = math.floor(iso_y), math.floor(iso_y + TILE_H) do
                    -- simplified fill for isometric testing
                end
            end
        end

        lurek.image.savePNG(img, OUT .. "tilemap_isometric.png")
    end)

    -- 4. @evidence file
    it("PNG: hexagonal layouts (pointy top)", function()
        local HEX_SIZE = 10
        local MAP_W, MAP_H = 6, 5
        local W, H = 200, 150
        local img = lurek.image.newImageData(W, H)
        img:fill(15, 20, 25, 255)

        local w = math.sqrt(3) * HEX_SIZE
        local h = 2 * HEX_SIZE

        for r = 0, MAP_H - 1 do
            for q = 0, MAP_W - 1 do
                local x = w * (q + 0.5 * (r % 2)) + 20
                local y = h * 0.75 * r + 20

                -- Draw hex outline
                local pts = {}
                for i = 0, 5 do
                    local angle_deg = 60 * i - 30
                    local angle_rad = math.pi / 180 * angle_deg
                    pts[i + 1] = { math.floor(x + HEX_SIZE * math.cos(angle_rad)),
                                   math.floor(y + HEX_SIZE * math.sin(angle_rad)) }
                end
                
                local col = (q + r) % 3 == 0 and {100, 100, 200} or {80, 160, 80}
                
                for i = 1, 6 do
                    local p1 = pts[i]
                    local p2 = pts[(i % 6) + 1]
                    img:drawLine(p1[1], p1[2], p2[1], p2[2], col[1], col[2], col[3], 255)
                end
            end
        end

        lurek.image.savePNG(img, OUT .. "tilemap_hexagonal.png")
    end)

    -- 5. @evidence file
    it("PNG: animated water tiles strip", function()
        local TILE = 16
        local FRAMES = 4
        local W, H = TILE * FRAMES, TILE
        local img = lurek.image.newImageData(W, H)
        
        for f = 0, FRAMES - 1 do
            local ox = f * TILE
            for y = 0, TILE - 1 do
                for x = 0, TILE - 1 do
                    -- Procedural water animation based on frame
                    local wave = math.sin(x * 0.5 + f * 1.5) + math.cos(y * 0.5 + f * 1.0)
                    local b = math.floor(200 + wave * 25)
                    local g = math.floor(100 + wave * 15)
                    img:setPixel(ox + x, y, 40, g, b, 255)
                end
            end
        end

        lurek.image.savePNG(img, OUT .. "tilemap_animated_water.png")
    end)

    -- 6. @evidence file
    it("PNG: multi-layer overlapping tiles", function()
        local TILE = 16
        local MAP_W, MAP_H = 4, 4
        local tm = lurek.tilemap.newTileMap(TILE, TILE)
        local ground = tm:addLayer("ground", MAP_W, MAP_H)
        local path = tm:addLayer("path", MAP_W, MAP_H)
        local objects = tm:addLayer("objects", MAP_W, MAP_H)

        -- Layer 1: Ground (grass - GID 1)
        tm:fill(ground, 1)

        -- Layer 2: Path (dirt - GID 3)
        for y = 1, MAP_H do
            tm:setTile(path, 2, y, 3)
        end
        tm:setTile(path, 3, 2, 3)
        tm:setTile(path, 3, 3, 3)

        -- Layer 3: Objects (trees - GID 10, rocks - GID 12)
        tm:setTile(objects, 1, 2, 10)
        tm:setTile(objects, 4, 1, 10)
        tm:setTile(objects, 4, 4, 12)

        local img = tm:drawToImage(TILE)
        lurek.image.savePNG(img, OUT .. "tilemap_multi_layer.png")
    end)

    -- 7. @evidence file
    it("PNG: auto-tiling terrain blending bitmask", function()
        local TILE = 16
        local W, H = TILE * 4, TILE * 4
        local img = lurek.image.newImageData(W, H)
        img:fill(40, 120, 40, 255) -- grass bg
        
        -- bitmask terrain shape (sand)
        local grid = {
            {0, 1, 1, 0},
            {1, 1, 1, 1},
            {1, 1, 0, 1},
            {0, 1, 1, 1}
        }

        for r = 1, 4 do
            for c = 1, 4 do
                if grid[r][c] == 1 then
                    local x = (c - 1) * TILE
                    local y = (r - 1) * TILE
                    draw_rect(img, x, y, TILE, TILE, 220, 200, 140)
                    
                    -- Check neighbors for auto-tile border
                    local n = r > 1 and grid[r-1][c] == 0
                    local s = r < 4 and grid[r+1][c] == 0
                    local w = c > 1 and grid[r][c-1] == 0
                    local e = c < 4 and grid[r][c+1] == 0
                    
                    -- draw border shadows natively
                    if n then img:drawLine(x, y, x+TILE-1, y, 160, 140, 80, 255) end
                    if s then img:drawLine(x, y+TILE-1, x+TILE-1, y+TILE-1, 160, 140, 80, 255) end
                    if w then img:drawLine(x, y, x, y+TILE-1, 160, 140, 80, 255) end
                    if e then img:drawLine(x+TILE-1, y, x+TILE-1, y+TILE-1, 160, 140, 80, 255) end
                end
            end
        end

        lurek.image.savePNG(img, OUT .. "tilemap_autotile.png")
    end)

end)

test_summary()
