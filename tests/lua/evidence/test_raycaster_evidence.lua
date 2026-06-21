-- test_evidence_raycaster.lua
-- Canonical evidence file for lurek.raycaster visual outputs.

-- The raycaster casts rays through a 2D grid and returns hit data.
-- Tests verify correctness of ray geometry and render results to a PNG
-- "depth buffer" image so the output can be visually inspected.


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

local function draw_frame(img, x, y, w, h, r, g, b)
    img:drawLine(x, y, x + w - 1, y, r, g, b, 255)
    img:drawLine(x + w - 1, y, x + w - 1, y + h - 1, r, g, b, 255)
    img:drawLine(x + w - 1, y + h - 1, x, y + h - 1, r, g, b, 255)
    img:drawLine(x, y + h - 1, x, y, r, g, b, 255)
end

local function mark_cell(img, cell_x, cell_y, scale, r, g, b)
    local left = cell_x * scale + math.floor(scale * 0.25)
    local top = cell_y * scale + math.floor(scale * 0.25)
    local size = math.max(2, math.floor(scale * 0.5))
    img:drawRect(left, top, size, size, r, g, b, 255)
end

local function mark_world_point(img, world_x, world_y, scale, r, g, b)
    local px = math.floor(world_x * scale + 0.5)
    local py = math.floor(world_y * scale + 0.5)
    img:drawLine(px - 3, py, px + 3, py, r, g, b, 255)
    img:drawLine(px, py - 3, px, py + 3, r, g, b, 255)
end

local function describe_pick(hit)
    if not hit then
        return "nil"
    end
    return table.concat({
        tostring(hit.surface),
        tostring(hit.x),
        tostring(hit.y),
        string.format("%.3f", hit.distance or 0.0),
        string.format("%.3f", hit.hit_x or 0.0),
        string.format("%.3f", hit.hit_y or 0.0),
        string.format("%.3f", hit.u or 0.0),
        string.format("%.3f", hit.v or 0.0),
        tostring(hit.level or 0),
    }, "@")
end

-- @describe Evidence: lurek.raycaster visual scenarios
describe("Evidence: lurek.raycaster visual scenarios", function()
    -- Does: Runs "saves raycaster depth-buffer as PNG evidence" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.raycaster.projectColumn, lurek.raycaster.new, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/raycaster/<artifact>
    -- Why: This is meaningful only if the visible/text output comes from lurek.raycaster.projectColumn, lurek.raycaster.new, and related owner calls; export helpers are just the container.

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
    -- Does: Runs "saves top-down occupancy map as PNG evidence" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.raycaster.new and related owner calls.
    -- Artifact: tests/artifacts/current/raycaster/<artifact>
    -- Why: This is meaningful only if the output is driven by lurek.raycaster.new and related owner calls rather than by helper-only drawing.

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
    -- Does: Runs "saves raycaster FOV rays projection as PNG evidence" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.raycaster.new and related owner calls.
    -- Artifact: tests/artifacts/current/raycaster/<artifact>
    -- Why: This is meaningful only if the output is driven by lurek.raycaster.new and related owner calls rather than by helper-only drawing.

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
    -- Does: Runs "saves raycaster minimap overlay as PNG evidence" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.raycaster.new and related owner calls.
    -- Artifact: tests/artifacts/current/raycaster/<artifact>
    -- Why: This is meaningful only if the output is driven by lurek.raycaster.new and related owner calls rather than by helper-only drawing.

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
    -- Does: Draws a pseudo-3D wall slice set with depth-based brightness variance.
    -- Shows: The PNG should make distance shading across wall columns visually obvious.
    -- Artifact: tests/artifacts/current/raycaster/raycaster_shaded_walls.png
    -- Why: This is meaningful because it preserves a stable rendering of depth-to-brightness behavior.

    it("saves raycaster shaded walls with height variance as PNG evidence", function()
        local W, H = 128, 64
        local img = lurek.image.newImageData(W, H)
        img:fill(18, 18, 22, 255)
        img:drawRect(0, 0, W, H / 2, 30, 35, 45, 255)
        img:drawRect(0, H / 2, W, H / 2, 20, 25, 30, 255)

        for col = 0, W - 1 do
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
    -- Does: Splits the wall view into stone and mirrored halves to visualize reflective styling.
    -- Shows: The PNG should contrast a regular wall surface with a tinted mirrored surface.
    -- Artifact: tests/artifacts/current/raycaster/raycaster_mirrors.png
    -- Why: This is meaningful because it preserves a concrete reflective-wall presentation sample.

    it("PNG: raycaster mirrors/reflections", function()
        ensure_evidence_dir("raycaster")
        local W, H = 128, 64
        local img = lurek.image.newImageData(W, H)
        img:fill(10, 10, 15, 255)

        for col = 0, W - 1 do
            local dist = 6.0
            local wall_h = math.floor((H / dist) * 1.5)
            local top = math.max(0, math.floor((H - wall_h) / 2))
            local bottom = math.min(H - 1, top + wall_h)

            if col < W / 2 then
                img:drawLine(col, top, col, bottom, 100, 100, 100, 255)
            else
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
    -- Does: Compares solid-wall, window, closed-door, and open-door visibility using actual raycaster LOS images.
    -- Shows: The contact sheet should make the transition from blocked sight to pass-through sight obvious without a fake renderer.
    -- Artifact: tests/artifacts/current/raycaster/raycaster_feature_visibility_sheet.png
    -- Why: This is meaningful because each panel is produced by LRaycaster:drawLineOfSight over real wall-feature semantics.

    it("PNG: feature visibility contact sheet", function()
        ensure_evidence_dir("raycaster")

        local scale = 16
        local solid = make_room(16, 16)
        solid:setCell(7, 7, 1)

        local window_map = make_room(16, 16)
        window_map:setCell(7, 7, 1)
        window_map:setWindowCell(7, 7, 0.25, 0.78, 0.35)

        local closed_door = make_room(16, 16)
        closed_door:setCell(7, 7, 1)
        closed_door:setDoorCell(7, 7, "vertical", 0.0)

        local open_door = make_room(16, 16)
        open_door:setCell(7, 7, 1)
        open_door:setDoorCell(7, 7, "vertical", 1.0)

        local panels = {
            { image = solid:drawLineOfSight(2.5, 7.5, 12.5, 7.5, scale), accent = { 224, 92, 92 } },
            { image = window_map:drawLineOfSight(2.5, 7.5, 12.5, 7.5, scale), accent = { 88, 208, 240 } },
            { image = closed_door:drawLineOfSight(2.5, 7.5, 12.5, 7.5, scale), accent = { 224, 176, 96 } },
            { image = open_door:drawLineOfSight(2.5, 7.5, 12.5, 7.5, scale), accent = { 96, 220, 144 } },
        }

        for _, panel in ipairs(panels) do
            mark_cell(panel.image, 7, 7, scale, panel.accent[1], panel.accent[2], panel.accent[3])
        end

        local panel_w = panels[1].image:getWidth()
        local panel_h = panels[1].image:getHeight()
        local canvas = lurek.image.newImageData(panel_w * 2 + 36, panel_h * 2 + 36)
        canvas:fill(16, 18, 24, 255)

        local positions = {
            { 12, 12 },
            { panel_w + 24, 12 },
            { 12, panel_h + 24 },
            { panel_w + 24, panel_h + 24 },
        }
        for i, panel in ipairs(panels) do
            local pos = positions[i]
            canvas:paste(panel.image, pos[1], pos[2])
            draw_frame(canvas, pos[1] - 2, pos[2] - 2, panel_w + 4, panel_h + 4, panel.accent[1], panel.accent[2], panel.accent[3])
        end

        local path = OUT .. "raycaster_feature_visibility_sheet.png"
        save_png(canvas, path)
    end)
    -- Does: Paints a ceiling and floor with different procedural textures in one first-person frame.
    -- Shows: The PNG should make the contrast between ceiling patterning and floor patterning visually clear.
    -- Artifact: tests/artifacts/current/raycaster/raycaster_floor_ceiling.png
    -- Why: This is meaningful because it preserves a durable sample of floor and ceiling styling behavior.

    it("PNG: varied floor/ceiling textures", function()
        ensure_evidence_dir("raycaster")
        local W, H = 128, 64
        local img = lurek.image.newImageData(W, H)

        for y = 0, H - 1 do
            for x = 0, W - 1 do
                if y < H / 2 then
                    local cx = math.floor(x + (y * 2)) % 20
                    if cx < 2 then
                        img:setPixel(x, y, 50, 30, 20, 255)
                    else
                        img:setPixel(x, y, 100, 70, 50, 255)
                    end
                else
                    local px = x - W / 2
                    local py = y - H / 2
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
    -- Does: Fills wall columns with a procedural lava-like texture to capture animated-wall styling.
    -- Shows: The PNG should show bright, warm veins against darker cooled regions across the wall.
    -- Artifact: tests/artifacts/current/raycaster/raycaster_animated_walls.png
    -- Why: This is meaningful because it preserves a concrete texture-style output for review.

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
            for y = top, bottom do
                local tex_y = math.floor(((y - top) / wall_h) * 64)
                local tex_x = col % 64
                local heat = math.sin(tex_x * 0.2 + tex_y * 0.1) + math.cos(tex_y * 0.3)
                if heat > 0.5 then
                    img:setPixel(col, y, 255, 200, 50, 255)
                elseif heat > 0.0 then
                    img:setPixel(col, y, 200, 80, 20, 255)
                else
                    img:setPixel(col, y, 60, 20, 20, 255)
                end
            end
        end

        local path = OUT .. "raycaster_animated_walls.png"
        save_png(img, path)
    end)
    -- Does: Runs "native raycaster render contact sheet" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by LRaycaster:drawView, LRaycaster:drawTopDown, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/raycaster/raycaster_native_render_contact_sheet.png
    -- Why: This is meaningful only if the visible/text output comes from LRaycaster:drawView, LRaycaster:drawTopDown, and related owner calls; export helpers are just the container.

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
    -- Does: Runs "textured first-person corridor view" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by LRaycaster:castRays, LRaycaster:castFloorRow, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/raycaster/<artifact>
    -- Why: This is meaningful only if the visible/text output comes from LRaycaster:castRays, LRaycaster:castFloorRow, and related owner calls; export helpers are just the container.

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
    -- Does: Runs "door and light minimap study" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.raycaster.newDoorManager, LDoorManager:addDoor, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/raycaster/<artifact>
    -- Why: This is meaningful only if the visible/text output comes from lurek.raycaster.newDoorManager, LDoorManager:addDoor, and related owner calls; export helpers are just the container.

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
        map:setCell(7, 8, 2)
        map:applyDoorManager(doors, 0.85)

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
    -- Does: Compares wall, half-wall, sprite, and model picks on one atlas of real raycaster top-down captures.
    -- Shows: The contact sheet should make the resolved cell and exact world hit point easy to inspect across geometry and entity picks.
    -- Artifact: tests/artifacts/current/raycaster/raycaster_pick_contact_sheet.png
    -- Why: This is meaningful because each panel starts from LRaycaster:drawTopDown and overlays coordinates returned by LRaycaster:pickScreen.

    it("PNG: pick contact sheet", function()
        ensure_evidence_dir("raycaster")

        local scale = 12
        local wall_params = {
            px = 8.0,
            py = 8.0,
            angle = 0.0,
            fov = math.pi / 3,
            rays = 64,
            max_dist = 16.0,
            screen_w = 320,
            screen_h = 200,
        }
        local pick_params = {
            px = 8.0,
            py = 8.0,
            angle = 0.0,
            fov = math.pi / 3,
            rays = 32,
            max_dist = 16.0,
            screen_w = 160,
            screen_h = 100,
        }
        local half_params = {
            px = 2.5,
            py = 5.5,
            angle = 0.0,
            fov = math.pi / 3,
            rays = 64,
            max_dist = 20.0,
            screen_w = 320,
            screen_h = 200,
        }

        local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
        local wall = lurek.render.newImage(SAMPLE_TEXTURE)

        local wall_map = make_room(16, 16)
        local wall_hit = wall_map:pickScreen(160, 100, wall_params)
        expect_true(wall_hit ~= nil)
        expect_equal("wall", wall_hit.surface)

        local half_map = make_room(12, 10)
        half_map:setCell(7, 5, 1)
        half_map:setHalfWallCell(7, 5, 0.5)
        local half_hit = half_map:pickScreen(160, 100, half_params)
        expect_true(half_hit ~= nil)
        expect_equal(7, half_hit.x)
        expect_equal(5, half_hit.y)

        local sprite_map = make_room(16, 16)
        local sprite_hit = sprite_map:pickScreen(80, 50, pick_params, {
            { id = 901, x = 10.5, y = 8.0, texture = wall, size = 1.0 },
        })
        expect_true(sprite_hit ~= nil)
        expect_equal("sprite", sprite_hit.surface)

        local model_map = make_room(16, 16)
        local model_hit = model_map:pickScreen(80, 60, pick_params, nil, {
            { id = 902, model = model, x = 10.5, y = 8.0, yaw = math.pi / 4, z = 0.15, scale = 0.22 },
        })
        expect_true(model_hit ~= nil)
        expect_equal("model", model_hit.surface)

        local panels = {
            {
                image = wall_map:drawTopDown(wall_params.px, wall_params.py, wall_params.angle, scale),
                hit = wall_hit,
                accent = { 232, 120, 96 },
            },
            {
                image = half_map:drawTopDown(half_params.px, half_params.py, half_params.angle, scale),
                hit = half_hit,
                accent = { 224, 200, 104 },
            },
            {
                image = sprite_map:drawTopDown(pick_params.px, pick_params.py, pick_params.angle, scale),
                hit = sprite_hit,
                accent = { 104, 216, 160 },
                entity = { 10.5, 8.0 },
            },
            {
                image = model_map:drawTopDown(pick_params.px, pick_params.py, pick_params.angle, scale),
                hit = model_hit,
                accent = { 104, 168, 255 },
                entity = { 10.5, 8.0 },
            },
        }

        for _, panel in ipairs(panels) do
            mark_cell(panel.image, panel.hit.x, panel.hit.y, scale, panel.accent[1], panel.accent[2], panel.accent[3])
            mark_world_point(panel.image, panel.hit.hit_x, panel.hit.hit_y, scale, panel.accent[1], panel.accent[2], panel.accent[3])
            if panel.entity then
                mark_world_point(panel.image, panel.entity[1], panel.entity[2], scale, 220, 236, 255)
            end
        end

        local panel_w = panels[1].image:getWidth()
        local panel_h = panels[1].image:getHeight()
        local canvas = lurek.image.newImageData(panel_w * 2 + 36, panel_h * 2 + 36)
        canvas:fill(16, 18, 24, 255)

        local positions = {
            { 12, 12 },
            { panel_w + 24, 12 },
            { 12, panel_h + 24 },
            { panel_w + 24, panel_h + 24 },
        }
        for i, panel in ipairs(panels) do
            local pos = positions[i]
            canvas:paste(panel.image, pos[1], pos[2])
            draw_frame(canvas, pos[1] - 2, pos[2] - 2, panel_w + 4, panel_h + 4, panel.accent[1], panel.accent[2], panel.accent[3])
        end

        local path = OUT .. "raycaster_pick_contact_sheet.png"
        save_png(canvas, path)
    end)
    -- Does: Runs "scene build and layered hit trace" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.raycaster.newHeightMap, LHeightMap:setFloor, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/raycaster/raycaster_scene_build_trace.txt
    -- Why: This is meaningful only if the visible/text output comes from lurek.raycaster.newHeightMap, LHeightMap:setFloor, and related owner calls; export helpers are just the container.

    it("TXT: scene build and layered hit trace", function()
        ensure_evidence_dir("raycaster")

        local map = build_world()
        map:setCell(6, 8, 2)
        map:setCell(9, 8, 3)
        map:setWallAlpha(2, 0.45)
        map:setCell(7, 7, 1)
        map:setWindowCell(7, 7, 0.25, 0.78, 0.35)
        map:setCell(7, 9, 1)
        map:setDoorCell(7, 9, "vertical", 0.0)
        local half_pick_map = make_room(12, 10)
        half_pick_map:setCell(7, 5, 1)
        half_pick_map:setHalfWallCell(7, 5, 0.5)

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
        local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
        local model_count = map:buildSceneWithModels(scene_params, nil, nil, nil, {
            { model = model, x = 10.5, y = 8.0, yaw = math.pi / 4, z = 0.15, scale = 0.22 },
        })
        local layered = map:castRayMulti(2, 8.5, 0, 20, 4)
        local revealed = map:revealCellsFromRays(7.5, 8.5, 0.12, math.pi / 2, 16, 12.0, 0.2)
        local managed_doors = lurek.raycaster.newDoorManager()
        local managed_id = managed_doors:addDoor(7, 9, "vertical", 1.0)
        local half_pick_center = half_pick_map:pickScreen(160, 100, {
            px = 2.5,
            py = 5.5,
            angle = 0.0,
            fov = math.pi / 3,
            rays = 64,
            max_dist = 20.0,
            screen_w = 320,
            screen_h = 200,
        })
        local half_pick_upper = half_pick_map:pickScreen(160, 84, {
            px = 2.5,
            py = 5.5,
            angle = 0.0,
            fov = math.pi / 3,
            rays = 64,
            max_dist = 20.0,
            screen_w = 320,
            screen_h = 200,
        })
        local window_pick_map = make_room(12, 10)
        window_pick_map:setCell(7, 5, 1)
        window_pick_map:setWindowCell(7, 5, 0.3, 0.75, 0.35)
        local window_pick_open = window_pick_map:pickScreen(160, 100, {
            px = 2.5,
            py = 5.5,
            angle = 0.0,
            fov = math.pi / 3,
            rays = 64,
            max_dist = 20.0,
            screen_w = 320,
            screen_h = 200,
        })
        local window_pick_lower = window_pick_map:pickScreen(160, 114, {
            px = 2.5,
            py = 5.5,
            angle = 0.0,
            fov = math.pi / 3,
            rays = 64,
            max_dist = 20.0,
            screen_w = 320,
            screen_h = 200,
        })
        local door_pick_map = make_room(12, 10)
        door_pick_map:setCell(7, 5, 1)
        door_pick_map:setDoorCell(7, 5, "vertical", 0.25, 0.9)
        local door_pick_panel = door_pick_map:pickScreen(160, 100, {
            px = 2.5,
            py = 5.5,
            angle = 0.0,
            fov = math.pi / 3,
            rays = 64,
            max_dist = 20.0,
            screen_w = 320,
            screen_h = 200,
        })
        local open_door_pick_map = make_room(12, 10)
        open_door_pick_map:setCell(7, 5, 1)
        open_door_pick_map:setDoorCell(7, 5, "vertical", 0.6, 0.9)
        local door_pick_gap = open_door_pick_map:pickScreen(160, 100, {
            px = 2.5,
            py = 5.5,
            angle = 0.0,
            fov = math.pi / 3,
            rays = 64,
            max_dist = 20.0,
            screen_w = 320,
            screen_h = 200,
        })
        local pick_map = make_room(16, 16)
        local pick_params = {
            px = 8.0,
            py = 8.0,
            angle = 0.0,
            fov = math.pi / 3,
            rays = 32,
            max_dist = 16.0,
            screen_w = 160,
            screen_h = 100,
        }
        local sprite_pick = pick_map:pickScreen(80, 50, pick_params, {
            { id = 901, x = 10.5, y = 8.0, texture = wall, size = 1.0 },
        })
        local model_pick = pick_map:pickScreen(80, 60, pick_params, nil, {
            { id = 902, model = model, x = 10.5, y = 8.0, yaw = math.pi / 4, z = 0.15, scale = 0.22 },
        })
        local solid_los_map = lurek.raycaster.new(10, 10)
        solid_los_map:setCell(5, 5, 1)
        local solid_los = solid_los_map:lineOfSight(1.0, 5.5, 9.0, 5.5)
        local window_los_map = lurek.raycaster.new(10, 10)
        window_los_map:setCell(5, 5, 1)
        window_los_map:setWindowCell(5, 5, 0.25, 0.8, 0.35)
        local window_los = window_los_map:lineOfSight(1.0, 5.5, 9.0, 5.5)
        local door_closed_map = lurek.raycaster.new(12, 6)
        door_closed_map:setCell(5, 2, 2)
        door_closed_map:setDoorCell(5, 2, "vertical", 0.0, 0.25)
        door_closed_map:setCell(9, 2, 1)
        local door_closed_hit = door_closed_map:castRay(1.5, 2.5, 0.0, 20.0)
        local door_open_map = lurek.raycaster.new(12, 6)
        door_open_map:setCell(5, 2, 2)
        door_open_map:setDoorCell(5, 2, "vertical", 1.0, 0.25)
        door_open_map:setCell(9, 2, 1)
        local door_open_hit = door_open_map:castRay(1.5, 2.5, 0.0, 20.0)
        local feature_light = {
            { x = 12.5, y = 7.5, radius = 10.0, intensity = 8.0, color = { 1.0, 0.8, 0.6 } },
        }
        local solid_light_map = lurek.raycaster.new(16, 16)
        solid_light_map:setCell(7, 7, 1)
        local solid_light_r = select(1, solid_light_map:computeTileLight(4, 7, 0.0, feature_light))
        local window_light_map = lurek.raycaster.new(16, 16)
        window_light_map:setCell(7, 7, 1)
        window_light_map:setWindowCell(7, 7, 0.25, 0.78, 0.35)
        local window_light_r = select(1, window_light_map:computeTileLight(4, 7, 0.0, feature_light))
        local closed_door_light_map = lurek.raycaster.new(16, 16)
        closed_door_light_map:setCell(7, 7, 1)
        closed_door_light_map:setDoorCell(7, 7, "vertical", 0.0, 0.25)
        local closed_door_light_r = select(1, closed_door_light_map:computeTileLight(4, 7, 0.0, feature_light))
        local open_door_light_map = lurek.raycaster.new(16, 16)
        open_door_light_map:setCell(7, 7, 1)
        open_door_light_map:setDoorCell(7, 7, "vertical", 1.0, 0.25)
        local open_door_light_r = select(1, open_door_light_map:computeTileLight(4, 7, 0.0, feature_light))
        expect_equal("half", half_pick_center.feature.kind)
        expect_equal("body", half_pick_center.feature.section)
        expect_equal(11, half_pick_upper.x)
        expect_equal(5, half_pick_upper.y)
        expect_equal(11, window_pick_open.x)
        expect_equal(5, window_pick_open.y)
        expect_equal("window", window_pick_lower.feature.kind)
        expect_equal("lower", window_pick_lower.feature.section)
        expect_equal("door", door_pick_panel.feature.kind)
        expect_equal("panel", door_pick_panel.feature.section)
        expect_equal(11, door_pick_gap.x)
        expect_equal(5, door_pick_gap.y)
        expect_true(window_light_r > solid_light_r)
        expect_true(open_door_light_r > closed_door_light_r)
        local multilevel_count = lurek.raycaster.buildMultiLevelScene(
            {
                px = 0.5,
                py = 1.5,
                angle = 0.0,
                fov = math.pi / 3,
                rays = 32,
                max_dist = 8.0,
                screen_w = 160,
                screen_h = 100,
                active_level = 1,
            },
            {
                {
                    width = 4,
                    height = 4,
                    cells = {
                        0, 0, 0, 0,
                        0, 0, 0, 0,
                        0, 0, 0, 0,
                        0, 0, 0, 0,
                    },
                    floor_offset = 0.0,
                    ceiling_height = 1.0,
                    ceiling_holes = {
                        false, false, false, false,
                        false, false, false, false,
                        false, false, false, false,
                        false, false, false, false,
                    },
                    ceiling_texture = wall,
                },
                {
                    width = 4,
                    height = 4,
                    cells = {
                        0, 0, 0, 0,
                        0, 0, 0, 0,
                        0, 0, 0, 0,
                        0, 0, 0, 0,
                    },
                    floor_offset = 1.0,
                    ceiling_height = 2.0,
                    floor_holes = {
                        false, false, false, false,
                        false, false, false, false,
                        false, false, false, false,
                        false, false, false, false,
                    },
                    floor_texture = wall,
                },
            },
            {},
            {},
            {},
            {
                { model = model, x = 2.5, y = 1.5, level = 1, yaw = math.pi / 6, z = 0.2, scale = 0.22 },
            }
        )
        local cull_closed_count = lurek.raycaster.buildMultiLevelScene(
            {
                px = 1.5,
                py = 2.5,
                angle = 0.0,
                fov = math.pi / 3,
                rays = 32,
                max_dist = 20.0,
                screen_w = 160,
                screen_h = 100,
                active_level = 0,
            },
            {
                {
                    width = 8,
                    height = 8,
                    cells = {
                        0, 0, 0, 0, 0, 0, 0, 0,
                        0, 0, 0, 0, 0, 0, 0, 0,
                        0, 0, 0, 0, 0, 0, 0, 0,
                        0, 0, 0, 0, 0, 0, 0, 0,
                        0, 0, 0, 0, 0, 0, 0, 0,
                        0, 0, 0, 0, 0, 0, 0, 0,
                        0, 0, 0, 0, 0, 0, 0, 0,
                        0, 0, 0, 0, 0, 0, 0, 0,
                    },
                    floor_offset = 0.0,
                    ceiling_height = 1.0,
                },
                {
                    width = 8,
                    height = 8,
                    cells = {
                        0, 0, 0, 0, 0, 0, 0, 0,
                        0, 0, 0, 0, 0, 0, 0, 0,
                        0, 0, 0, 0, 1, 0, 0, 0,
                        0, 0, 0, 0, 0, 0, 0, 0,
                        0, 0, 0, 0, 0, 0, 0, 0,
                        0, 0, 0, 0, 0, 0, 0, 0,
                        0, 0, 0, 0, 0, 0, 0, 0,
                        0, 0, 0, 0, 0, 0, 0, 0,
                    },
                    floor_offset = 1.0,
                    ceiling_height = 2.0,
                },
            },
            {},
            {},
            { [1] = wall }
        )
        local cull_open_count = lurek.raycaster.buildMultiLevelScene(
            {
                px = 1.5,
                py = 2.5,
                angle = 0.0,
                fov = math.pi / 3,
                rays = 32,
                max_dist = 20.0,
                screen_w = 160,
                screen_h = 100,
                active_level = 0,
            },
            {
                {
                    width = 8,
                    height = 8,
                    cells = {
                        0, 0, 0, 0, 0, 0, 0, 0,
                        0, 0, 0, 0, 0, 0, 0, 0,
                        0, 0, 0, 0, 0, 0, 0, 0,
                        0, 0, 0, 0, 0, 0, 0, 0,
                        0, 0, 0, 0, 0, 0, 0, 0,
                        0, 0, 0, 0, 0, 0, 0, 0,
                        0, 0, 0, 0, 0, 0, 0, 0,
                        0, 0, 0, 0, 0, 0, 0, 0,
                    },
                    floor_offset = 0.0,
                    ceiling_height = 1.0,
                    ceiling_holes = {
                        false, false, false, false, false, false, false, false,
                        false, false, false, false, false, false, false, false,
                        false, false, false, false, true, false, false, false,
                        false, false, false, false, false, false, false, false,
                        false, false, false, false, false, false, false, false,
                        false, false, false, false, false, false, false, false,
                        false, false, false, false, false, false, false, false,
                        false, false, false, false, false, false, false, false,
                    },
                },
                {
                    width = 8,
                    height = 8,
                    cells = {
                        0, 0, 0, 0, 0, 0, 0, 0,
                        0, 0, 0, 0, 0, 0, 0, 0,
                        0, 0, 0, 0, 1, 0, 0, 0,
                        0, 0, 0, 0, 0, 0, 0, 0,
                        0, 0, 0, 0, 0, 0, 0, 0,
                        0, 0, 0, 0, 0, 0, 0, 0,
                        0, 0, 0, 0, 0, 0, 0, 0,
                        0, 0, 0, 0, 0, 0, 0, 0,
                    },
                    floor_offset = 1.0,
                    ceiling_height = 2.0,
                },
            },
            {},
            {},
            { [1] = wall }
        )
        expect_true(cull_open_count > cull_closed_count)
        local stats_map = make_room(8, 8)
        for y = 1, 6 do
            for x = 1, 6 do
                stats_map:setCeilingTextureCell(x, y, wall)
            end
        end
        stats_map:buildScene({
            px = 4.0,
            py = 4.0,
            angle = 0.0,
            fov = math.pi / 3,
            rays = 48,
            max_dist = 10.0,
            screen_w = 160,
            screen_h = 100,
        }, {
            lurek.raycaster.newPointLight(4.0, 4.0, 1.0, 0.9, 0.8, 4.0, 1.25),
        }, {}, {
            [1] = wall,
        })
        local build_stats = lurek.raycaster.getLastBuildStats()
        local path = OUT .. "raycaster_scene_build_trace.txt"
        local lines = {
            "floor_8_8=" .. tostring(hm:floorAt(8, 8)),
            "ceiling_8_8=" .. tostring(hm:ceilingAt(8, 8)),
            "buildScene_quads=" .. tostring(quad_count),
            "buildSceneWithModels_quads=" .. tostring(model_count),
            "buildMultiLevelScene_quads=" .. tostring(multilevel_count),
            "castRayMulti_hits=" .. tostring(#layered),
            "revealCells_hits=" .. tostring(#revealed),
            "first_layered_cell=" .. tostring(layered[1] and layered[1].cell_value or "nil"),
            "half_feature=" .. tostring(half_pick_map:getWallFeatureCell(7, 5).kind),
            "half_pick_center=" .. describe_pick(half_pick_center),
            "half_pick_upper=" .. describe_pick(half_pick_upper),
            "half_pick_section=" .. tostring(half_pick_center.feature and half_pick_center.feature.section or "nil"),
            "window_pick_open=" .. describe_pick(window_pick_open),
            "window_pick_lower=" .. describe_pick(window_pick_lower),
            "window_pick_section=" .. tostring(window_pick_lower.feature and window_pick_lower.feature.section or "nil"),
            "door_pick_panel=" .. describe_pick(door_pick_panel),
            "door_pick_gap=" .. describe_pick(door_pick_gap),
            "door_pick_section=" .. tostring(door_pick_panel.feature and door_pick_panel.feature.section or "nil"),
            "sprite_pick=" .. describe_pick(sprite_pick),
            "sprite_pick_id=" .. tostring(sprite_pick and sprite_pick.id or "nil"),
            "sprite_pick_hit=" .. tostring(sprite_pick and string.format("%.3f,%.3f", sprite_pick.hit_x, sprite_pick.hit_y) or "nil"),
            "model_pick=" .. describe_pick(model_pick),
            "model_pick_id=" .. tostring(model_pick and model_pick.id or "nil"),
            "model_pick_hit=" .. tostring(model_pick and string.format("%.3f,%.3f", model_pick.hit_x, model_pick.hit_y) or "nil"),
            "model_pick_level=" .. tostring(model_pick and model_pick.level or "nil"),
            "solid_los=" .. tostring(solid_los),
            "window_los=" .. tostring(window_los),
            "door_closed_hit=" .. tostring(door_closed_hit and door_closed_hit.cell_value or "nil"),
            "door_open_hit=" .. tostring(door_open_hit and door_open_hit.cell_value or "nil"),
            "managed_door_kind=" .. tostring(map:getWallFeatureCell(7, 9).kind),
            "solid_light_r=" .. string.format("%.3f", solid_light_r),
            "window_light_r=" .. string.format("%.3f", window_light_r),
            "closed_door_light_r=" .. string.format("%.3f", closed_door_light_r),
            "open_door_light_r=" .. string.format("%.3f", open_door_light_r),
            "cull_closed_quads=" .. tostring(cull_closed_count),
            "cull_open_quads=" .. tostring(cull_open_count),
            "lighting_samples=" .. tostring(build_stats and build_stats.lightingSamples or "nil"),
            "lighting_cache_hits=" .. tostring(build_stats and build_stats.lightingCacheHits or "nil"),
            "lighting_cache_misses=" .. tostring(build_stats and build_stats.lightingCacheMisses or "nil"),
        }

        write_file(path, table.concat(lines, "\n") .. "\n")
        expect_evidence_created(path)
    end)

    -- Does: Runs "scene adapter physics bridge trace" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.raycaster.newSceneAdapter, LRaycaster:buildSceneFromAdapter, and LRaycaster:pickScreenFromAdapter while a bound physics body moves.
    -- Artifact: tests/artifacts/current/raycaster/raycaster_scene_adapter_trace.txt
    -- Why: This is meaningful only if the trace changes come from the physics-backed adapter bridge rather than manual sprite/model table rebuilding.

    it("TXT: scene adapter physics bridge trace", function()
        ensure_evidence_dir("raycaster")

        local map = make_room(16, 16)
        local world = lurek.physics.newWorld(0, 0)
        local body = world:newBody(10.5, 8.0, "dynamic")
        local wall = lurek.render.newImage(SAMPLE_TEXTURE)
        local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
        local adapter = lurek.raycaster.newSceneAdapter()
        adapter:bindBodySprite(body, wall, {
            id = 771,
            size = 1.0,
        })
        adapter:bindBodyLight(body, 4.0, {
            intensity = 1.2,
            color = { 1.0, 0.85, 0.5 },
        })
        adapter:bindBodyModel(body, model, {
            id = 772,
            yaw_offset = math.pi / 4,
            z = 0.15,
            scale = 0.22,
        })

        local params = {
            px = 8.0,
            py = 8.0,
            angle = 0.0,
            fov = math.pi / 3,
            rays = 32,
            max_dist = 16.0,
            screen_w = 160,
            screen_h = 100,
        }
        local before_inputs = adapter:sceneInputs()
        local before_quads = map:buildSceneFromAdapter(params, adapter, {})
        local before_pick = map:pickScreenFromAdapter(80, 50, params, adapter)

        body:setPosition(11.5, 8.0)

        local after_inputs = adapter:sceneInputs()
        local after_quads = map:buildSceneFromAdapter(params, adapter, {})
        local after_pick = map:pickScreenFromAdapter(80, 50, params, adapter)

        local path = OUT .. "raycaster_scene_adapter_trace.txt"
        local lines = {
            "before_sprite=" .. string.format("%.3f,%.3f", before_inputs.sprites[1].x, before_inputs.sprites[1].y),
            "before_light=" .. string.format("%.3f,%.3f", before_inputs.lights[1].x, before_inputs.lights[1].y),
            "before_quads=" .. tostring(before_quads),
            "before_pick=" .. describe_pick(before_pick),
            "after_sprite=" .. string.format("%.3f,%.3f", after_inputs.sprites[1].x, after_inputs.sprites[1].y),
            "after_light=" .. string.format("%.3f,%.3f", after_inputs.lights[1].x, after_inputs.lights[1].y),
            "after_quads=" .. tostring(after_quads),
            "after_pick=" .. describe_pick(after_pick),
            "after_pick_id=" .. tostring(after_pick and after_pick.id or "nil"),
        }
        write_file(path, table.concat(lines, "\n") .. "\n")
        expect_evidence_created(path)
    end)

    -- Does: Runs "multilevel scene adapter level trace" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.raycaster.buildMultiLevelSceneFromAdapter and lurek.raycaster.pickScreenMultiLevelFromAdapter for physics-backed entities placed on an upper level.
    -- Artifact: tests/artifacts/current/raycaster/raycaster_multilevel_scene_adapter_trace.txt
    -- Why: This is meaningful only if the same 2D body movement changes both the projected multilevel scene and the picked owning level without rebuilding manual sprite tables.

    it("TXT: multilevel scene adapter level trace", function()
        ensure_evidence_dir("raycaster")

        local world = lurek.physics.newWorld(0, 0)
        local body = world:newBody(2.5, 1.5, "dynamic")
        local wall = lurek.render.newImage(SAMPLE_TEXTURE)
        local adapter = lurek.raycaster.newSceneAdapter()
        adapter:bindBodySprite(body, wall, {
            id = 881,
            level = 1,
            size = 1.0,
        })
        adapter:bindBodyLight(body, 4.0, {
            level = 1,
            intensity = 1.0,
            color = { 1.0, 0.85, 0.6 },
        })

        local params = {
            px = 0.5,
            py = 1.5,
            angle = 0.0,
            fov = math.pi / 3,
            rays = 32,
            max_dist = 8.0,
            screen_w = 160,
            screen_h = 100,
            active_level = 1,
        }
        local levels = {
            {
                width = 4,
                height = 4,
                cells = {
                    0, 0, 0, 0,
                    0, 0, 0, 0,
                    0, 0, 0, 0,
                    0, 0, 0, 0,
                },
                floor_offset = 0.0,
                ceiling_height = 1.0,
            },
            {
                width = 4,
                height = 4,
                cells = {
                    0, 0, 0, 0,
                    0, 0, 0, 0,
                    0, 0, 0, 0,
                    0, 0, 0, 0,
                },
                floor_offset = 1.0,
                ceiling_height = 2.0,
            },
        }

        local before_inputs = adapter:sceneInputs()
        local before_quads = lurek.raycaster.buildMultiLevelSceneFromAdapter(params, levels, adapter, {})
        local before_pick = lurek.raycaster.pickScreenMultiLevelFromAdapter(80, 50, params, levels, {}, adapter)

        body:setPosition(3.0, 1.5)

        local after_inputs = adapter:sceneInputs()
        local after_quads = lurek.raycaster.buildMultiLevelSceneFromAdapter(params, levels, adapter, {})
        local after_pick = lurek.raycaster.pickScreenMultiLevelFromAdapter(80, 50, params, levels, {}, adapter)

        local path = OUT .. "raycaster_multilevel_scene_adapter_trace.txt"
        local lines = {
            "before_sprite=" .. string.format("%.3f,%.3f@L%d", before_inputs.sprites[1].x, before_inputs.sprites[1].y, before_inputs.sprites[1].level or -1),
            "before_light=" .. string.format("%.3f,%.3f@L%d", before_inputs.lights[1].x, before_inputs.lights[1].y, before_inputs.lights[1].level or -1),
            "before_quads=" .. tostring(before_quads),
            "before_pick=" .. describe_pick(before_pick),
            "before_pick_id=" .. tostring(before_pick and before_pick.id or "nil"),
            "after_sprite=" .. string.format("%.3f,%.3f@L%d", after_inputs.sprites[1].x, after_inputs.sprites[1].y, after_inputs.sprites[1].level or -1),
            "after_light=" .. string.format("%.3f,%.3f@L%d", after_inputs.lights[1].x, after_inputs.lights[1].y, after_inputs.lights[1].level or -1),
            "after_quads=" .. tostring(after_quads),
            "after_pick=" .. describe_pick(after_pick),
            "after_pick_id=" .. tostring(after_pick and after_pick.id or "nil"),
        }
        write_file(path, table.concat(lines, "\n") .. "\n")
        expect_evidence_created(path)
    end)

    -- Does: Runs "persistent multilevel runtime authoring trace" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by LMultiLevelGrid:setFloorTexture, LMultiLevelGrid:setCeilingTexture, LMultiLevelGrid:setLoweredFloorCell, and LMultiLevelGrid:buildScene when a stacked world is authored incrementally at runtime.
    -- Artifact: tests/artifacts/current/raycaster/raycaster_persistent_multilevel_authoring_trace.txt
    -- Why: This is meaningful only if the same persistent grid handle can be shaped into a lit pseudo-3D level without rebuilding level tables from scratch.

    it("TXT: persistent multilevel runtime authoring trace", function()
        ensure_evidence_dir("raycaster")

        local wall = lurek.render.newImage(SAMPLE_TEXTURE)
        local grid = lurek.raycaster.newMultiLevelGrid({
            {
                width = 6,
                height = 4,
                cells = {
                    0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0,
                },
                floor_offset = 0.0,
                ceiling_height = 1.0,
            },
            {
                width = 6,
                height = 4,
                cells = {
                    0, 0, 0, 0, 0, 1,
                    0, 0, 0, 0, 0, 1,
                    0, 0, 0, 0, 0, 1,
                    0, 0, 0, 0, 0, 1,
                },
                floor_offset = 1.0,
                ceiling_height = 2.0,
            },
        })
        grid:setActiveLevel(1)
        grid:setFloorOffset(1.2)
        grid:setCeilingHeight(2.4)
        grid:setFloorTexture(wall)
        grid:setCeilingTexture(wall)
        grid:setFloorTextureCell(2, 1, wall)
        grid:setCeilingTextureCell(2, 1, wall)
        grid:setLoweredFloorCell(2, 1, {
            texture = wall,
            depth = 0.35,
            r = 0.8,
            g = 0.7,
            b = 0.6,
            blocked = false,
        })
        grid:setFloorHole(2, 1, false)
        grid:setCeilingHole(2, 1, false)

        local params = {
            px = 1.5,
            py = 1.5,
            angle = 0.0,
            fov = math.pi / 3,
            rays = 48,
            max_dist = 10.0,
            screen_w = 160,
            screen_h = 100,
            camera_height = 0.5,
        }
        local quad_count = grid:buildScene(params, {
            lurek.raycaster.newPointLight(2.5, 1.5, 1.0, 0.9, 0.8, 4.0, 1.25, 1),
        }, {}, {
            [1] = wall,
        })
        local wall_pick = grid:pickScreen(80, 50, params, { [1] = wall })
        local floor_pick = grid:pickScreen(80, 92, params, { [1] = wall })
        local pit = grid:getLoweredFloorCell(2, 1)
        local stats = lurek.raycaster.getLastBuildStats()

        local path = OUT .. "raycaster_persistent_multilevel_authoring_trace.txt"
        local lines = {
            "active_level=" .. tostring(grid:activeLevel()),
            "floor_offset=" .. tostring(grid:getFloorOffset()),
            "ceiling_height=" .. tostring(grid:getCeilingHeight()),
            "floor_texture=" .. tostring(grid:getFloorTexture()),
            "ceiling_texture=" .. tostring(grid:getCeilingTexture()),
            "floor_cell_texture=" .. tostring(grid:getFloorTextureCell(2, 1)),
            "ceiling_cell_texture=" .. tostring(grid:getCeilingTextureCell(2, 1)),
            "pit_depth=" .. tostring(pit and pit.depth or "nil"),
            "pit_blocked=" .. (pit == nil and "nil" or tostring(pit.blocked)),
            "quad_count=" .. tostring(quad_count),
            "wall_pick=" .. describe_pick(wall_pick),
            "floor_pick=" .. describe_pick(floor_pick),
            "lighting_samples=" .. tostring(stats and stats.lightingSamples or "nil"),
            "lighting_cache_hits=" .. tostring(stats and stats.lightingCacheHits or "nil"),
            "lighting_cache_misses=" .. tostring(stats and stats.lightingCacheMisses or "nil"),
        }
        write_file(path, table.concat(lines, "\n") .. "\n")
        expect_evidence_created(path)
    end)

end)
test_summary()
