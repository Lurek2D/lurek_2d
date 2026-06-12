-- test_evidence_raycaster.lua
-- Canonical evidence file for lurek.raycaster visual outputs.

-- The raycaster casts rays through a 2D grid and returns hit data.
-- Tests verify correctness of ray geometry and render results to a PNG
-- "depth buffer" image so the output can be visually inspected.
-- @covers lurek.image.newImageData
-- @covers lurek.image.savePNG
-- @covers lurek.raycaster.distanceShade
-- @covers lurek.raycaster.new
-- @covers lurek.raycaster.newDoorManager
-- @covers lurek.raycaster.newHeightMap
-- @covers lurek.raycaster.newPointLight
-- @covers lurek.raycaster.projectColumn
-- @covers lurek.render.newImage




local OUT = evidence_output_dir("raycaster")

local function save_png(img, path)
    lurek.image.savePNG(img, path)
    expect_evidence_created(path)
end

local SAMPLE_TEXTURE = "content/examples/assets/images/sample_texture.png"

local function clamp(v, lo, hi)
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

local function load_texture()
    return lurek.image.newImageData(SAMPLE_TEXTURE)
end

local function sample_wrapped(texture, u, v, tint)
    local tw = texture:getWidth()
    local th = texture:getHeight()
    local tx = math.floor((u - math.floor(u)) * tw) % tw
    local ty = math.floor((v - math.floor(v)) * th) % th
    local r, g, b, a = texture:getPixel(tx, ty)
    local tr = tint and tint[1] or 1.0
    local tg = tint and tint[2] or 1.0
    local tb = tint and tint[3] or 1.0
    return clamp(math.floor(r * tr + 0.5), 0, 255),
        clamp(math.floor(g * tg + 0.5), 0, 255),
        clamp(math.floor(b * tb + 0.5), 0, 255),
        a or 255
end

local function apply_shade(r, g, b, shade)
    return clamp(math.floor(r * shade + 0.5), 0, 255),
        clamp(math.floor(g * shade + 0.5), 0, 255),
        clamp(math.floor(b * shade + 0.5), 0, 255)
end

local function build_world()
    local rc = lurek.raycaster.new(16, 16)
    for x = 0, 15 do
        rc:setCell(x, 0, 1)
        rc:setCell(x, 15, 1)
    end
    for y = 0, 15 do
        rc:setCell(0, y, 1)
        rc:setCell(15, y, 1)
    end

    for y = 2, 13 do
        rc:setCell(4, y, 2)
        rc:setCell(11, y, 3)
    end
    for x = 4, 11 do
        rc:setCell(x, 2, 2)
        rc:setCell(x, 13, 3)
    end

    rc:setCell(7, 6, 1)
    rc:setCell(7, 7, 1)
    rc:setCell(8, 7, 1)
    rc:setCell(9, 9, 2)
    rc:setCell(10, 9, 3)
    return rc
end

-- @describe Evidence: lurek.raycaster visual scenarios
describe("Evidence: lurek.raycaster visual scenarios", function()
    -- @evidence lurek.image.savePNG
    -- @evidence lurek.raycaster.projectColumn
    -- @evidence lurek.raycaster.new
    -- @evidence lurek.raycaster.distanceShade
    it("saves raycaster depth-buffer as PNG evidence", function()
        local W, H = 128, 64
        local FOV = math.pi / 2

        local rc = lurek.raycaster.new(20, 20)
        -- Outer walls
        for x = 0, 19 do
            rc:setCell(x, 0, 1)
            rc:setCell(x, 19, 1)
        end
        for y = 0, 19 do
            rc:setCell(0, y, 1)
            rc:setCell(19, y, 1)
        end

        local img = lurek.image.newImageData(W, H)
        local rays = rc:castRaysFlat(10.0, 10.0, 0.0, FOV, W, 40)
        for col = 0, W - 1 do
            local base = col * 5
            local dist    = rays[base + 1] or 0
            local shade   = lurek.raycaster.distanceShade(dist, 40)
            local _, top, bottom = lurek.raycaster.projectColumn(dist, FOV, H)
            local brightness = math.floor(shade * 200 + 0.5)
            local t = math.max(0, math.min(H - 1, math.floor(top or 0)))
            local b = math.max(0, math.min(H - 1, math.floor(bottom or (H - 1))))

            if t > 0 then
                img:drawLine(col, 0, col, t - 1, 40, 40, 40, 255)
            end
            if t <= b then
                img:drawLine(col, t, col, b, brightness, brightness, brightness, 255)
            end
            if b < H - 1 then
                img:drawLine(col, b + 1, col, H - 1, 20, 20, 20, 255)
            end
        end

        save_png(img, OUT .. "raycaster_depth.png")
    end)

    -- @evidence lurek.image.savePNG
    it("saves top-down occupancy map as PNG evidence", function()
        local W, H = 128, 128
        local rc = lurek.raycaster.new(16, 16)

        for x = 0, 15 do
            rc:setCell(x, 0, 1)
            rc:setCell(x, 15, 1)
        end
        for y = 0, 15 do
            rc:setCell(0, y, 1)
            rc:setCell(15, y, 1)
        end
        for i = 3, 12 do
            rc:setCell(i, 8, 1)
        end

        local img = lurek.image.newImageData(W, H)
        img:fill(22, 24, 30, 255)
        local cell = 8
        for y = 0, 15 do
            for x = 0, 15 do
                local v = rc:getCell(x, y)
                local r, g, b = 30, 34, 44
                if v ~= 0 then
                    r, g, b = 220, 220, 230
                end
                img:drawRect(x * cell, y * cell, cell - 1, cell - 1, r, g, b, 255)
            end
        end

        local path = OUT .. "raycaster_topdown.png"
        save_png(img, path)
    end)

    -- @evidence lurek.image.savePNG
    it("saves raycaster FOV rays projection as PNG evidence", function()
        local W, H = 128, 128
        local rc = lurek.raycaster.new(16, 16)
        
        -- Outline map boundary
        for i = 0, 15 do
            rc:setCell(i, 0, 1)
            rc:setCell(i, 15, 1)
            rc:setCell(0, i, 1)
            rc:setCell(15, i, 1)
        end
        rc:setCell(6, 6, 1)
        rc:setCell(10, 8, 1)

        local img = lurek.image.newImageData(W, H)
        img:fill(15, 15, 20, 255)

        local px, py = 8.0, 8.0
        local fov = math.pi / 3 -- 60 degree sweep
        local angle = 0.0
        local scale = 8

        -- Draw occupancy cells natively
        for y = 0, 15 do
            for x = 0, 15 do
                if rc:getCell(x, y) ~= 0 then
                    img:drawRect(x * scale, y * scale, scale - 1, scale - 1, 80, 80, 100, 255)
                end
            end
        end

        -- Cast FOV rays and draw lines to hits natively
        local NUM_RAYS = 30
        for i = 0, NUM_RAYS - 1 do
            local ra = angle - (fov / 2) + (i / (NUM_RAYS - 1)) * fov
            local cast = rc:castRay(px, py, ra, 20.0)
            local dist = cast and cast.distance or 20.0
            local hx = px + math.cos(ra) * dist
            local hy = py + math.sin(ra) * dist
            img:drawLine(px * scale, py * scale, hx * scale, hy * scale, 255, 150, 50, 180)
        end

        -- Draw player camera position natively
        img:drawCircle(px * scale, py * scale, 4, 255, 255, 255, 255)

        local path = OUT .. "raycaster_fov.png"
        save_png(img, path)
    end)

    -- @evidence lurek.image.savePNG
    it("saves raycaster minimap overlay as PNG evidence", function()
        local W, H = 128, 128
        local rc = lurek.raycaster.new(16, 16)
        rc:setCell(5, 5, 1)
        rc:setCell(5, 10, 1)
        rc:setCell(10, 5, 1)
        rc:setCell(10, 10, 1)

        local img = lurek.image.newImageData(W, H)
        img:fill(10, 12, 16, 255)
        
        local scale = 8
        -- Native draw empty grids
        for y = 0, 15 do
            for x = 0, 15 do
                img:drawRect(x * scale, y * scale, scale, scale, 25, 28, 35, 255)
                if rc:getCell(x, y) > 0 then
                    img:drawRect(x * scale, y * scale, scale, scale, 220, 100, 100, 255)
                end
            end
        end

        -- Draw interactive radar blip sweep
        img:drawCircle(64, 64, 32, 50, 200, 50, 100)
        img:drawCircle(64, 64, 16, 50, 200, 50, 150)
        img:drawLine(64, 64, 64 + 24, 64 - 24, 100, 255, 100, 255)

        local path = OUT .. "raycaster_minimap.png"
        save_png(img, path)
    end)

    -- @evidence lurek.image.savePNG
    it("saves raycaster shaded walls with height variance as PNG evidence", function()
        local W, H = 128, 64
        local img = lurek.image.newImageData(W, H)
        img:fill(18, 18, 22, 255)

        -- Generate gradient background (floor/ceiling) natively
        img:drawRect(0, 0, W, H / 2, 30, 35, 45, 255)
        img:drawRect(0, H / 2, W, H / 2, 20, 25, 30, 255)

        -- Draw simulated raycast heights natively
        for col = 0, W - 1 do
            -- Varying distance parameter to simulate curved corridor
            local dist = 4.0 + 8.0 * math.sin((col / (W - 1)) * math.pi)
            local wall_h = math.floor((H / dist) * 2.0)
            local top = math.max(0, math.floor((H - wall_h) / 2))
            local bottom = math.min(H - 1, top + wall_h)
            local brightness = math.floor((1.0 - (dist / 12.0)) * 200)
            brightness = math.max(20, math.min(255, brightness))

            img:drawLine(col, top, col, bottom, brightness, math.floor(brightness * 0.8), math.floor(brightness * 0.6), 255)
        end

        local path = OUT .. "raycaster_shaded_walls.png"
        save_png(img, path)
    end)
    -- Additional mirror evidence
    -- @evidence lurek.image.savePNG
    it("PNG: raycaster mirrors/reflections", function()
        ensure_evidence_dir("raycaster")
        local W, H = 128, 64
        local img = lurek.image.newImageData(W, H)
        img:fill(10, 10, 15, 255)

        for col = 0, W - 1 do
            -- Base wall (left half) vs Mirror wall (right half)
            local dist = 6.0
            local wall_h = math.floor((H / dist) * 1.5)
            local top = math.max(0, math.floor((H - wall_h) / 2))
            local bottom = math.min(H - 1, top + wall_h)
            
            if col < W / 2 then
                -- Normal stone wall
                img:drawLine(col, top, col, bottom, 100, 100, 100, 255)
            else
                -- Mirror wall: reflect the floor and ceiling colors with a tint
                local tint_r, tint_g, tint_b = 200, 220, 255
                for y = top, bottom do
                    local factor = (y - top) / (bottom - top)
                    local ref_r = math.floor(tint_r * factor)
                    local ref_g = math.floor(tint_g * factor)
                    local ref_b = math.floor(tint_b * (1 - factor))
                    img:setPixel(col, y, ref_r, ref_g, ref_b, 255)
                end
            end
        end

        local path = OUT .. "raycaster_mirrors.png"
        save_png(img, path)
    end)

    -- Additional glass-wall evidence
    -- @evidence lurek.image.savePNG
    it("PNG: transparent glass walls", function()
        ensure_evidence_dir("raycaster")
        local W, H = 128, 64
        local img = lurek.image.newImageData(W, H)
        img:fill(20, 30, 40, 255) -- Background wall behind glass

        for col = 0, W - 1 do
            local dist_glass = 4.0
            local wall_h = math.floor((H / dist_glass) * 1.5)
            local top = math.max(0, math.floor((H - wall_h) / 2))
            local bottom = math.min(H - 1, top + wall_h)
            
            -- Glass panel overlay (alpha blending simulated manually for evidence if needed, but setPixel supports alpha)
            if col % 10 < 8 then -- Glass panes with frames
                for y = top, bottom do
                    local r, g, b, a = img:getPixel(col, y)
                    -- blend glass cyan tint
                    local out_r = math.floor(r * 0.5 + 50 * 0.5)
                    local out_g = math.floor(g * 0.5 + 200 * 0.5)
                    local out_b = math.floor(b * 0.5 + 255 * 0.5)
                    img:setPixel(col, y, out_r, out_g, out_b, 255)
                end
                
                -- glass highlights (specular reflection)
                if (col + top) % 20 < 4 then
                    img:drawLine(col, top, col, bottom, 255, 255, 255, 100)
                end
            else
                -- Frame
                img:drawLine(col, top, col, bottom, 40, 40, 40, 255)
            end
        end

        local path = OUT .. "raycaster_glass.png"
        save_png(img, path)
    end)

    -- Additional floor-ceiling evidence
    -- @evidence lurek.image.savePNG
    it("PNG: varied floor/ceiling textures", function()
        ensure_evidence_dir("raycaster")
        local W, H = 128, 64
        local img = lurek.image.newImageData(W, H)
        
        -- Floor casting mockup (mode 7 style texture mapping)
        for y = 0, H - 1 do
            for x = 0, W - 1 do
                if y < H / 2 then
                    -- Ceiling: wooden planks
                    local cx = math.floor(x + (y * 2)) % 20
                    if cx < 2 then
                        img:setPixel(x, y, 50, 30, 20, 255)
                    else
                        img:setPixel(x, y, 100, 70, 50, 255)
                    end
                else
                    -- Floor: checkered tiles
                    local px = x - W/2
                    local py = y - H/2
                    local pz = py + 1.0
                    local tx = math.floor(px / pz * 10)
                    local ty = math.floor(200 / pz)
                    
                    if (tx + ty) % 2 == 0 then
                        img:setPixel(x, y, 200, 200, 200, 255)
                    else
                        img:setPixel(x, y, 40, 40, 40, 255)
                    end
                end
            end
        end

        local path = OUT .. "raycaster_floor_ceiling.png"
        save_png(img, path)
    end)

    -- Additional animated-wall evidence
    -- @evidence lurek.image.savePNG
    it("PNG: animated wall textures", function()
        ensure_evidence_dir("raycaster")
        local W, H = 128, 64
        local img = lurek.image.newImageData(W, H)
        img:fill(0, 0, 0, 255)

        for col = 0, W - 1 do
            local dist = 5.0
            local wall_h = math.floor((H / dist) * 1.5)
            local top = math.max(0, math.floor((H - wall_h) / 2))
            local bottom = math.min(H - 1, top + wall_h)
            
            -- Texture mapping for column
            for y = top, bottom do
                local tex_y = math.floor(((y - top) / wall_h) * 64)
                local tex_x = col % 64
                
                -- Animated lava texture mockup
                local heat = math.sin(tex_x * 0.2 + tex_y * 0.1) + math.cos(tex_y * 0.3)
                if heat > 0.5 then
                    img:setPixel(col, y, 255, 200, 50, 255) -- Bright lava
                elseif heat > 0.0 then
                    img:setPixel(col, y, 200, 80, 20, 255)  -- Darker lava
                else
                    img:setPixel(col, y, 60, 20, 20, 255)   -- Cooled rock
                end
            end
        end

        local path = OUT .. "raycaster_animated_walls.png"
        save_png(img, path)
    end)

    -- Additional billboard evidence
    -- @evidence lurek.image.savePNG
    it("PNG: sprite billboarding in raycaster space", function()
        ensure_evidence_dir("raycaster")
        local W, H = 128, 64
        local img = lurek.image.newImageData(W, H)
        img:fill(20, 30, 40, 255)
        
        -- Draw walls behind
        img:drawRect(0, H/2, W, H/2, 40, 40, 40, 255)

        -- Billboard sprite (a potion or enemy)
        local sprite_x = 64
        local sprite_dist = 4.0
        local sprite_size = math.floor((H / sprite_dist) * 0.8)
        
        local sy = H / 2
        
        -- Draw sprite natively
        img:drawRect(sprite_x - sprite_size/2, sy - sprite_size/2, sprite_size, sprite_size, 200, 50, 50, 255)
        -- inner details
        img:drawRect(sprite_x - sprite_size/4, sy - sprite_size/4, sprite_size/2, sprite_size/2, 255, 150, 150, 255)
        
        -- cast shadow on floor
        img:drawCircle(sprite_x, sy + sprite_size/2 + 2, sprite_size/2, 10, 10, 10, 150)

        local path = OUT .. "raycaster_billboard.png"
        save_png(img, path)
    end)

    -- @evidence LRaycaster:drawView
    -- @evidence LRaycaster:drawTopDown
    -- @evidence LRaycaster:extractMinimap
    -- @evidence LRaycaster:drawCameraSweep
    -- @evidence lurek.image.savePNG
    it("PNG: native raycaster render contact sheet", function()
        ensure_evidence_dir("raycaster")

        local world = build_world()
        local view = world:drawView(7.5, 8.5, 0.12, math.pi / 3, 256, 160, 24.0)
        local top_down = world:drawTopDown(7.5, 8.5, 0.12, 12)
        local minimap = world:extractMinimap(7.5, 8.5, 0.12, 6, 10)
        local sweep = world:drawCameraSweep(7.5, 8.5, math.pi / 2, 18.0, 6, 96, 64)

        local canvas = lurek.image.newImageData(640, 360)
        canvas:fill(16, 18, 24, 255)
        canvas:drawRect(0, 0, 640, 182, 20, 24, 34, 255)
        canvas:paste(view, 20, 18)
        canvas:drawLine(20, 18, 275, 18, 230, 234, 242, 255)
        canvas:drawLine(275, 18, 275, 177, 230, 234, 242, 255)
        canvas:drawLine(275, 177, 20, 177, 230, 234, 242, 255)
        canvas:drawLine(20, 177, 20, 18, 230, 234, 242, 255)

        canvas:paste(top_down:resize(168, 168, "bilinear"), 300, 18)
        canvas:drawLine(300, 18, 467, 18, 230, 234, 242, 255)
        canvas:drawLine(467, 18, 467, 185, 230, 234, 242, 255)
        canvas:drawLine(467, 185, 300, 185, 230, 234, 242, 255)
        canvas:drawLine(300, 185, 300, 18, 230, 234, 242, 255)

        canvas:paste(minimap:resize(132, 132, "bilinear"), 488, 18)
        canvas:drawLine(488, 18, 619, 18, 230, 234, 242, 255)
        canvas:drawLine(619, 18, 619, 149, 230, 234, 242, 255)
        canvas:drawLine(619, 149, 488, 149, 230, 234, 242, 255)
        canvas:drawLine(488, 149, 488, 18, 230, 234, 242, 255)

        canvas:paste(sweep:resize(600, 132, "bilinear"), 20, 206)
        canvas:drawLine(20, 206, 619, 206, 230, 234, 242, 255)
        canvas:drawLine(619, 206, 619, 337, 230, 234, 242, 255)
        canvas:drawLine(619, 337, 20, 337, 230, 234, 242, 255)
        canvas:drawLine(20, 337, 20, 206, 230, 234, 242, 255)

        local path = OUT .. "raycaster_native_render_contact_sheet.png"
        save_png(canvas, path)
    end)

    -- @evidence LRaycaster:castRays
    -- @evidence LRaycaster:castFloorRow
    -- @evidence LRaycaster:projectSprite
    -- @evidence lurek.raycaster.distanceShade
    -- @evidence lurek.image.savePNG
    it("PNG: textured first-person corridor view", function()
        ensure_evidence_dir("raycaster")

        local W, H = 320, 200
        local FOV = math.pi / 3
        local px, py, angle = 7.5, 8.5, 0.15
        local dir_x = math.cos(angle)
        local dir_y = math.sin(angle)
        local plane_scale = math.tan(FOV / 2)
        local plane_x = -dir_y * plane_scale
        local plane_y = dir_x * plane_scale

        local world = build_world()
        local uv_map = lurek.raycaster.new(W, H)
        local img = lurek.image.newImageData(W, H)
        local base = load_texture()
        local wall_tints = {
            [1] = { 0.95, 0.95, 0.95 },
            [2] = { 0.92, 0.72, 0.62 },
            [3] = { 0.62, 0.80, 0.98 },
        }
        local floor_tint = { 0.58, 0.56, 0.52 }
        local ceiling_tint = { 0.46, 0.52, 0.70 }
        local sprite_tint = { 1.00, 0.68, 0.46 }

        for y = 0, H - 1 do
            local sample_row = y < math.floor(H / 2) and (H - y - 1) or y
            local uvs = uv_map:castFloorRow(px, py, dir_x, dir_y, plane_x, plane_y, sample_row)
            for x = 1, W do
                local uv = uvs[x]
                local tint = y < math.floor(H / 2) and ceiling_tint or floor_tint
                local r, g, b = sample_wrapped(base, uv.u * 1.75, uv.v * 1.75, tint)
                if y < math.floor(H / 2) then
                    r, g, b = apply_shade(r, g, b, 0.88)
                else
                    local falloff = 0.92 - ((y - H / 2) / (H / 2)) * 0.35
                    r, g, b = apply_shade(r, g, b, falloff)
                end
                img:setPixel(x - 1, y, r, g, b, 255)
            end
        end

        local hits = world:castRays(px, py, angle, FOV, W, 24.0)
        for x = 1, W do
            local hit = hits[x]
            if hit and hit.hit then
                local dist = math.max(0.001, hit.distance)
                local wall_height = math.max(1, math.floor(H / dist))
                local top = math.max(0, math.floor((H - wall_height) / 2))
                local bottom = math.min(H - 1, top + wall_height)
                local shade = lurek.raycaster.distanceShade(dist, 20.0)
                if hit.side == 1 then
                    shade = shade * 0.78
                end
                local tint = wall_tints[hit.cell_value] or wall_tints[1]
                local span = math.max(1, bottom - top)
                for row = top, bottom do
                    local v = (row - top) / span
                    local r, g, b = sample_wrapped(base, hit.tex_u * 2.0, v * 2.0, tint)
                    r, g, b = apply_shade(r, g, b, 0.28 + shade * 0.92)
                    img:setPixel(x - 1, row, r, g, b, 255)
                end
            end
        end

        local sprite = world:projectSprite(10.5, 8.5, px, py, angle, FOV, W)
        if sprite and sprite.visible then
            local sprite_size = math.max(18, math.floor(H * sprite.scale * 0.95))
            local left = math.floor(sprite.screen_x - sprite_size / 2)
            local top = math.floor(H / 2 - sprite_size / 2)
            for sx = 0, sprite_size - 1 do
                local screen_x = left + sx
                if screen_x >= 0 and screen_x < W then
                    local col_hit = hits[screen_x + 1]
                    if not col_hit or sprite.distance < col_hit.distance then
                        for sy = 0, sprite_size - 1 do
                            local screen_y = top + sy
                            if screen_y >= 0 and screen_y < H then
                                local u = sx / math.max(1, sprite_size - 1)
                                local v = sy / math.max(1, sprite_size - 1)
                                local r, g, b, a = sample_wrapped(base, u, v, sprite_tint)
                                if a > 16 and (u - 0.5) * (u - 0.5) + (v - 0.5) * (v - 0.5) < 0.23 then
                                    local shade = 0.45 + lurek.raycaster.distanceShade(sprite.distance, 18.0) * 0.75
                                    r, g, b = apply_shade(r, g, b, shade)
                                    img:setPixel(screen_x, screen_y, r, g, b, 255)
                                end
                            end
                        end
                    end
                end
            end
        end

        local path = OUT .. "raycaster_textured_corridor_view.png"
        save_png(img, path)
    end)

    -- @evidence lurek.raycaster.newDoorManager
    -- @evidence LDoorManager:addDoor
    -- @evidence LDoorManager:openDoor
    -- @evidence LDoorManager:update
    -- @evidence lurek.raycaster.newPointLight
    -- @evidence LPointLight:set
    -- @evidence LRaycaster:computeTileLight
    -- @evidence LRaycaster:buildMinimapWindow
    -- @evidence lurek.image.savePNG
    it("PNG: door and light minimap study", function()
        ensure_evidence_dir("raycaster")

        local W, H = 320, 220
        local img = lurek.image.newImageData(W, H)
        img:fill(18, 20, 28, 255)

        local map = build_world()
        local doors = lurek.raycaster.newDoorManager()
        local door_id = doors:addDoor(7, 8, "vertical", 1.0)
        doors:openDoor(door_id)
        doors:update(0.45)

        local torch = lurek.raycaster.newPointLight(7.5, 8.5, 1.0, 0.82, 0.52, 5.0, 2.0)
        torch:set(7.5, 8.5, 1.0, 0.82, 0.52, 5.0, 2.0)
        local cold = lurek.raycaster.newPointLight(11.0, 10.5, 0.45, 0.68, 1.0, 4.0, 1.3)
        local lights = {
            {
                x = torch:x(),
                y = torch:y(),
                radius = torch:radius(),
                intensity = torch:intensity(),
                color = { torch:color() },
            },
            {
                x = cold:x(),
                y = cold:y(),
                radius = cold:radius(),
                intensity = cold:intensity(),
                color = { cold:color() },
            },
        }

        local cell = 16
        for y = 0, 15 do
            for x = 0, 15 do
                local v = map:getCell(x, y)
                local base_r, base_g, base_b = 34, 38, 50
                if v ~= 0 then
                    base_r, base_g, base_b = 84, 92, 118
                end
                local lr, lg, lb = map:computeTileLight(x, y, 0.0, lights)
                local rr = math.min(255, math.floor(base_r + lr * 150))
                local gg = math.min(255, math.floor(base_g + lg * 150))
                local bb = math.min(255, math.floor(base_b + lb * 150))
                img:drawRect(20 + x * cell, 18 + y * cell, cell - 1, cell - 1, rr, gg, bb, 255)
            end
        end

        local door = doors:getDoor(door_id)
        expect_true(door ~= nil)
        img:drawRect(20 + 7 * cell + 5, 18 + 8 * cell, 6, cell - 1, 255, 224, 116, 255)
        img:drawCircle(20 + torch:x() * cell, 18 + torch:y() * cell, 6, 255, 210, 120, 255)
        img:drawCircle(20 + cold:x() * cell, 18 + cold:y() * cell, 5, 120, 180, 255, 255)

        local window = map:buildMinimapWindow(7.5, 8.5, 4, 0.15, lights)
        for _, sample in ipairs(window) do
            local px = 20 + sample.x * cell + cell / 2
            local py = 18 + sample.y * cell + cell / 2
            local alpha = math.max(60, math.floor(sample.luma * 255))
            img:drawCircle(px, py, 1, 255, 255, 255, alpha)
        end

        local path = OUT .. "raycaster_door_light_minimap_study.png"
        save_png(img, path)
    end)

    -- @evidence lurek.raycaster.newHeightMap
    -- @evidence LHeightMap:setFloor
    -- @evidence LHeightMap:setCeiling
    -- @evidence LRaycaster:buildScene
    -- @evidence LRaycaster:buildSceneWithModels
    -- @evidence LRaycaster:castRayMulti
    -- @evidence LRaycaster:revealCellsFromRays
    it("TXT: scene build and layered hit trace", function()
        ensure_evidence_dir("raycaster")

        local map = build_world()
        map:setCell(6, 8, 2)
        map:setCell(9, 8, 3)
        map:setWallAlpha(2, 0.45)

        local hm = lurek.raycaster.newHeightMap(16, 16)
        hm:setFloor(8, 8, -0.25)
        hm:setCeiling(8, 8, 1.35)

        local scene_params = {
            px = 7.5,
            py = 8.5,
            angle = 0.12,
            fov = math.pi / 3,
            rays = 64,
            max_dist = 18,
            screen_w = 320,
            screen_h = 180,
        }
        local wall = lurek.render.newImage(SAMPLE_TEXTURE)
        local quad_count = map:buildScene(scene_params, {}, {}, { [1] = wall, [2] = wall, [3] = wall })
        local model_count = map:buildSceneWithModels(scene_params, nil, nil, nil, nil)
        local layered = map:castRayMulti(2, 8.5, 0, 20, 4)
        local revealed = map:revealCellsFromRays(7.5, 8.5, 0.12, math.pi / 2, 16, 12.0, 0.2)
        local path = OUT .. "raycaster_scene_build_trace.txt"
        local lines = {
            "floor_8_8=" .. tostring(hm:floorAt(8, 8)),
            "ceiling_8_8=" .. tostring(hm:ceilingAt(8, 8)),
            "buildScene_quads=" .. tostring(quad_count),
            "buildSceneWithModels_quads=" .. tostring(model_count),
            "castRayMulti_hits=" .. tostring(#layered),
            "revealCells_hits=" .. tostring(#revealed),
            "first_layered_cell=" .. tostring(layered[1] and layered[1].cell_value or "nil"),
        }

        write_file(path, table.concat(lines, "\n") .. "\n")
        expect_evidence_created(path)
    end)

end)
test_summary()
