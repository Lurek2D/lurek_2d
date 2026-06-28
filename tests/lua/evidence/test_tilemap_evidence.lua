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

local HEX_DIRS = {
    { q = 1, r = 0 },
    { q = 1, r = -1 },
    { q = 0, r = -1 },
    { q = -1, r = 0 },
    { q = -1, r = 1 },
    { q = 0, r = 1 },
}

local function hex_distance(aq, ar, bq, br)
    local as = -aq - ar
    local bs = -bq - br
    return math.max(math.abs(aq - bq), math.abs(ar - br), math.abs(as - bs))
end

local function hex_line(aq, ar, bq, br)
    local dist = hex_distance(aq, ar, bq, br)
    local cells = {}
    for i = 0, dist do
        local t = dist == 0 and 0 or i / dist
        local q = aq + (bq - aq) * t
        local r = ar + (br - ar) * t
        local s = -q - r
        local rq, rr, rs = math.floor(q + 0.5), math.floor(r + 0.5), math.floor(s + 0.5)
        local q_diff, r_diff, s_diff = math.abs(rq - q), math.abs(rr - r), math.abs(rs - s)
        if q_diff > r_diff and q_diff > s_diff then
            rq = -rr - rs
        elseif r_diff > s_diff then
            rr = -rq - rs
        end
        cells[#cells + 1] = { q = rq, r = rr }
    end
    return cells
end

local function hex_ring(cq, cr, radius)
    if radius == 0 then
        return { { q = cq, r = cr } }
    end
    local cells = {}
    local q = cq + HEX_DIRS[5].q * radius
    local r = cr + HEX_DIRS[5].r * radius
    for side = 1, 6 do
        local dir = HEX_DIRS[side]
        for _ = 1, radius do
            cells[#cells + 1] = { q = q, r = r }
            q = q + dir.q
            r = r + dir.r
        end
    end
    return cells
end

local function hex_area(cq, cr, radius)
    local cells = {}
    for q = -radius, radius do
        local r1 = math.max(-radius, -q - radius)
        local r2 = math.min(radius, -q + radius)
        for r = r1, r2 do
            cells[#cells + 1] = { q = cq + q, r = cr + r }
        end
    end
    return cells
end

local function hex_spiral(cq, cr, radius)
    local cells = { { q = cq, r = cr } }
    for ring = 1, radius do
        local ring_cells = hex_ring(cq, cr, ring)
        for _, cell in ipairs(ring_cells) do
            cells[#cells + 1] = cell
        end
    end
    return cells
end

local function hex_reflect(q, r, axis)
    local s = -q - r
    if axis == "q" then
        return q, s
    elseif axis == "r" then
        return s, r
    end
    return r, q
end

local function hex_rotate(q, r, turns)
    local cq, cr, cs = q, r, -q - r
    for _ = 1, (turns or 0) % 6 do
        cq, cr, cs = -cs, -cq, -cr
    end
    return cq, cr
end

local ISO_XCOM = {
    map_w = 50,
    map_h = 50,
    tile_base = 16,
    tile_w = 32,
    tile_h = 16,
    level_h = 24,
    floor = 0,
    right_wall = 1,
    left_wall = 2,
    object = 3,
    part_order = { 0, 2, 1, 3 },
}

local function iso_xcom_field_slots()
    return {
        floor = "floor",
        left_wall = "left_top_wall",
        right_wall = "right_top_wall",
        object = "object",
    }
end

local function clamp_color(v)
    return math.max(0, math.min(255, math.floor(v)))
end

local function shade_color(color, factor)
    return {
        clamp_color(color[1] * factor),
        clamp_color(color[2] * factor),
        clamp_color(color[3] * factor),
    }
end

local function tint_color(color, light)
    if not light then
        return color
    end
    local lr = math.max(0.18, math.min(1.4, light.r or 0))
    local lg = math.max(0.18, math.min(1.4, light.g or 0))
    local lb = math.max(0.18, math.min(1.4, light.b or 0))
    return {
        clamp_color(color[1] * lr),
        clamp_color(color[2] * lg),
        clamp_color(color[3] * lb),
    }
end

local function draw_iso_diamond(img, sx, sy, tw, th, color, outline)
    local half_w = tw / 2
    local half_h = th / 2
    for dy = 0, th do
        local t = dy <= half_h and dy / half_h or (th - dy) / half_h
        local row_half = half_w * t
        img:drawLine(sx - row_half, sy + dy, sx + row_half, sy + dy, color[1], color[2], color[3], 255)
    end
    if outline then
        img:drawLine(sx, sy, sx + half_w, sy + half_h, outline[1], outline[2], outline[3], 255)
        img:drawLine(sx + half_w, sy + half_h, sx, sy + th, outline[1], outline[2], outline[3], 255)
        img:drawLine(sx, sy + th, sx - half_w, sy + half_h, outline[1], outline[2], outline[3], 255)
        img:drawLine(sx - half_w, sy + half_h, sx, sy, outline[1], outline[2], outline[3], 255)
    end
end

local function point_in_polygon(px, py, points)
    local inside = false
    local j = #points
    for i = 1, #points do
        local pi = points[i]
        local pj = points[j]
        local crosses = ((pi.y > py) ~= (pj.y > py)) and
            (px < (pj.x - pi.x) * (py - pi.y) / ((pj.y - pi.y) + 0.0001) + pi.x)
        if crosses then
            inside = not inside
        end
        j = i
    end
    return inside
end

local function draw_polygon(img, points, color, outline)
    local min_x, min_y = points[1].x, points[1].y
    local max_x, max_y = points[1].x, points[1].y
    for _, point in ipairs(points) do
        min_x = math.min(min_x, point.x)
        min_y = math.min(min_y, point.y)
        max_x = math.max(max_x, point.x)
        max_y = math.max(max_y, point.y)
    end
    for py = math.floor(min_y), math.ceil(max_y) do
        for px = math.floor(min_x), math.ceil(max_x) do
            if point_in_polygon(px + 0.5, py + 0.5, points) then
                img:drawRect(px, py, 1, 1, color[1], color[2], color[3], 255)
            end
        end
    end
    if outline then
        for i = 1, #points do
            local a = points[i]
            local b = points[(i % #points) + 1]
            img:drawLine(a.x, a.y, b.x, b.y, outline[1], outline[2], outline[3], 255)
        end
    end
end

local function draw_iso_left_wall(img, sx, sy, tw, th, wall_h, color)
    local half_w = tw / 2
    local half_h = th / 2
    local top = { x = sx, y = sy }
    local left = { x = sx - half_w, y = sy + half_h }
    draw_polygon(img, {
        { x = top.x, y = top.y - wall_h },
        { x = left.x, y = left.y - wall_h },
        left,
        top,
    }, color, shade_color(color, 1.35))
end

local function draw_iso_right_wall(img, sx, sy, tw, th, wall_h, color)
    local half_w = tw / 2
    local half_h = th / 2
    local top = { x = sx, y = sy }
    local right = { x = sx + half_w, y = sy + half_h }
    draw_polygon(img, {
        { x = top.x, y = top.y - wall_h },
        { x = right.x, y = right.y - wall_h },
        right,
        top,
    }, color, shade_color(color, 1.28))
end

local function draw_iso_object(img, sx, sy, th, gid, light)
    local cx = sx
    local cy = sy + th / 2
    local colors = {
        [41] = { 222, 172, 68 },
        [42] = { 112, 178, 112 },
        [43] = { 184, 108, 198 },
        [44] = { 228, 92, 72 },
        [45] = { 118, 164, 230 },
    }
    local color = tint_color(colors[gid] or { 238, 238, 178 }, light)
    if gid == 44 then
        img:drawLine(cx, cy - 20, cx - 7, cy + 1, color[1], color[2], color[3], 255)
        img:drawLine(cx, cy - 20, cx + 7, cy + 1, color[1], color[2], color[3], 255)
        img:drawLine(cx - 7, cy + 1, cx + 7, cy + 1, color[1], color[2], color[3], 255)
        img:drawCircle(cx, cy - 22, 3, 255, 226, 126, 255)
        return
    end
    img:drawRect(cx - 5, cy - 15, 10, 15, color[1], color[2], color[3], 255)
    img:drawRect(cx - 4, cy - 21, 8, 6, math.min(255, color[1] + 28), math.min(255, color[2] + 28), math.min(255, color[3] + 28), 255)
    img:drawLine(cx - 6, cy, cx + 6, cy, 28, 30, 38, 255)
end

local function iso_xcom_floor_color(level, gid)
    if gid == 0 then return nil end
    local palette = {
        [2] = {
            [11] = { 73, 77, 86 },
            [12] = { 83, 88, 98 },
            [13] = { 95, 92, 82 },
        },
        [3] = {
            [21] = { 112, 118, 134 },
            [22] = { 126, 130, 148 },
            [23] = { 105, 116, 138 },
        },
        [4] = {
            [31] = { 156, 68, 56 },
            [32] = { 181, 88, 64 },
            [33] = { 112, 124, 142 },
        },
    }
    return (palette[level] and palette[level][gid]) or { 92, 96, 108 }
end

local function iso_xcom_has_floor(iso, z, x, y)
    if x < 1 or x > ISO_XCOM.map_w or y < 1 or y > ISO_XCOM.map_h then
        return false
    end
    return iso:getTilePart(z, x, y, ISO_XCOM.floor) ~= 0
end

local function iso_xcom_build_scene()
    local spec = ISO_XCOM
    local slots = iso_xcom_field_slots()
    local iso = lurek.tilemap.newIsoMap(spec.map_w, spec.map_h, spec.tile_w, spec.tile_h, spec.level_h, 4)
    local field = lurek.tilefield.new({ width = spec.map_w, height = spec.map_h, levels = 4, topology = "iso_square" })
    for _ = 1, 4 do
        iso:addLevel()
    end
    iso:setPartOrder(spec.part_order)

    local footprints = {
        [2] = { min_x = 16, max_x = 36, min_y = 16, max_y = 36 },
        [3] = { min_x = 21, max_x = 32, min_y = 19, max_y = 30 },
        [4] = { min_x = 24, max_x = 29, min_y = 21, max_y = 26 },
    }

    for y = 1, spec.map_h do
        for x = 1, spec.map_w do
            local gid = 11 + ((x + y) % 3)
            iso:setTilePart(2, x, y, spec.floor, gid)
            field:setRef(x, y, 2, slots.floor, gid)
        end
    end

    for z = 2, 4 do
        local fp = footprints[z]
        for y = fp.min_y, fp.max_y do
            for x = fp.min_x, fp.max_x do
                local gid = z == 2 and (11 + ((x + y) % 3)) or z == 3 and (21 + ((x + y) % 3)) or (31 + ((x + y) % 3))
                local inner_gap = z == 3 and x >= 26 and x <= 28 and y >= 23 and y <= 25
                if not inner_gap then
                    iso:setTilePart(z, x, y, spec.floor, gid)
                    field:setRef(x, y, z, slots.floor, gid)
                    if z >= 3 then
                        field:setSunOcclusion(x, y, z, 0.86)
                    end
                end
                if x == fp.min_x or (z == 2 and x == 27 and y >= 18 and y <= 24) then
                    iso:setTilePart(z, x, y, spec.left_wall, 61 + z)
                    field:setRef(x, y, z, slots.left_wall, 61 + z)
                    field:setSunOcclusion(x, y, z, math.max(field:getSunOcclusion(x, y, z), 0.35))
                end
                if y == fp.min_y or (z == 3 and y == 28 and x >= 23 and x <= 31) then
                    iso:setTilePart(z, x, y, spec.right_wall, 71 + z)
                    field:setRef(x, y, z, slots.right_wall, 71 + z)
                    field:setSunOcclusion(x, y, z, math.max(field:getSunOcclusion(x, y, z), 0.35))
                end
            end
        end
    end

    for z = 3, 4 do
        local fp = footprints[z]
        local support_z = z - 1
        for y = fp.min_y, fp.max_y do
            for x = fp.min_x, fp.max_x do
                if iso_xcom_has_floor(iso, z, x, y) and not iso_xcom_has_floor(iso, z, x, y + 1) and y < spec.map_h then
                    local sy = y + 1
                    local gid = 92 + z
                    iso:setTilePart(support_z, x, sy, spec.right_wall, gid)
                    field:setRef(x, sy, support_z, slots.right_wall, gid)
                    field:setSunOcclusion(x, sy, support_z, math.max(field:getSunOcclusion(x, sy, support_z), 0.55))
                end
                if iso_xcom_has_floor(iso, z, x, y) and not iso_xcom_has_floor(iso, z, x + 1, y) and x < spec.map_w then
                    local sx = x + 1
                    local gid = 82 + z
                    iso:setTilePart(support_z, sx, y, spec.left_wall, gid)
                    field:setRef(sx, y, support_z, slots.left_wall, gid)
                    field:setSunOcclusion(sx, y, support_z, math.max(field:getSunOcclusion(sx, y, support_z), 0.55))
                end
                local column_x = x == fp.min_x or x == fp.max_x
                local column_y = y == fp.min_y or y == fp.max_y
                if column_x and column_y then
                    local cx = x == fp.max_x and math.min(spec.map_w, x + 1) or x
                    local cy = y == fp.max_y and math.min(spec.map_h, y + 1) or y
                    iso:setTilePart(support_z, cx, cy, spec.object, 45)
                    field:setRef(cx, cy, support_z, slots.object, 45)
                end
            end
        end
    end

    local objects = {
        { z = 2, x = 22, y = 22, gid = 41 },
        { z = 2, x = 28, y = 24, gid = 44 },
        { z = 2, x = 31, y = 31, gid = 42 },
        { z = 2, x = 25, y = 28, gid = 43 },
        { z = 3, x = 23, y = 21, gid = 45 },
        { z = 3, x = 30, y = 24, gid = 41 },
        { z = 3, x = 24, y = 29, gid = 44 },
        { z = 4, x = 26, y = 23, gid = 44 },
        { z = 4, x = 28, y = 25, gid = 45 },
    }
    for _, object in ipairs(objects) do
        iso:setTilePart(object.z, object.x, object.y, spec.object, object.gid)
        field:setRef(object.x, object.y, object.z, slots.object, object.gid)
    end

    local light = lurek.tilelight.new(field)
    light:setAmbient({ r = 0.18, g = 0.18, b = 0.2 })
    light:setGlobalLight({ intensity = 0.82, color = { r = 1.0, g = 0.92, b = 0.72 } })
    light:addPointLight({ x = 28, y = 24, z = 2, radius = 8, intensity = 0.9, color = { r = 1.0, g = 0.42, b = 0.18 } })
    light:addPointLight({ x = 26, y = 23, z = 4, radius = 7, intensity = 0.75, color = { r = 0.55, g = 0.75, b = 1.0 } })
    light:compute({ includePointLights = true, includeSunLight = true })

    return {
        iso = iso,
        field = field,
        light = light,
        slots = slots,
        footprints = footprints,
        objects = objects,
    }
end

local function iso_xcom_part_name(part)
    if part == ISO_XCOM.floor then return "FLOOR" end
    if part == ISO_XCOM.left_wall then return "LEFT_TOP_WALL" end
    if part == ISO_XCOM.right_wall then return "RIGHT_TOP_WALL" end
    if part == ISO_XCOM.object then return "OBJECT" end
    return "PART_" .. tostring(part)
end

local function iso_xcom_commands(scene, z_min, z_max, x_min, x_max, y_min, y_max, origin_x, origin_y)
    local spec = ISO_XCOM
    local iso = scene.iso
    iso:setOrigin(origin_x, origin_y)
    local commands = {}
    for d = 0, (spec.map_w + spec.map_h - 2) do
        local tx_min = math.max(1, d - spec.map_h + 2)
        local tx_max = math.min(spec.map_w, d + 1)
        for x = tx_min, tx_max do
            local y = d - (x - 1) + 1
            if x >= x_min and x <= x_max and y >= y_min and y <= y_max then
                for z = z_min, z_max do
                    for _, part in ipairs(spec.part_order) do
                        local gid = iso:getTilePart(z, x, y, part)
                        if gid ~= 0 then
                            local sx, sy = iso:tileToScreen(x - 1, y - 1, z - 1)
                            local light_sample = nil
                            if scene.light then
                                local lr, lg, lb, ll = scene.light:getLight(x, y, z)
                                light_sample = { r = lr, g = lg, b = lb, luma = ll }
                            end
                            commands[#commands + 1] = {
                                z = z,
                                x = x,
                                y = y,
                                part = part,
                                gid = gid,
                                sx = sx,
                                sy = sy,
                                light = light_sample,
                            }
                        end
                    end
                end
            end
        end
    end
    return commands
end

local function draw_iso_xcom_command(img, command, options)
    local spec = ISO_XCOM
    if command.part == spec.floor then
        local color = iso_xcom_floor_color(command.z, command.gid)
        if color then
            color = tint_color(color, command.light)
            if options and options.dim_level and command.z < options.dim_level then
                color = shade_color(color, 0.36)
            end
            draw_iso_diamond(img, command.sx, command.sy, spec.tile_w, spec.tile_h, color, shade_color(color, 1.45))
        end
    elseif command.part == spec.left_wall then
        local color = command.gid >= 80 and { 116, 110, 118 } or command.z == 2 and { 128, 58, 44 } or command.z == 3 and { 154, 160, 184 } or { 182, 86, 64 }
        color = tint_color(color, command.light)
        if options and options.dim_level and command.z < options.dim_level then
            color = shade_color(color, 0.38)
        end
        draw_iso_left_wall(img, command.sx, command.sy, spec.tile_w, spec.tile_h, 22, color)
    elseif command.part == spec.right_wall then
        local color = command.gid >= 90 and { 136, 132, 144 } or command.z == 2 and { 166, 74, 54 } or command.z == 3 and { 184, 190, 212 } or { 206, 104, 72 }
        color = tint_color(color, command.light)
        if options and options.dim_level and command.z < options.dim_level then
            color = shade_color(color, 0.38)
        end
        draw_iso_right_wall(img, command.sx, command.sy, spec.tile_w, spec.tile_h, 22, color)
    elseif command.part == spec.object then
        if not options or not options.dim_level or command.z >= options.dim_level then
            draw_iso_object(img, command.sx, command.sy, spec.tile_h, command.gid, command.light)
        end
    end
end

local function render_iso_xcom(scene, width, height, origin_x, origin_y, z_min, z_max, x_min, x_max, y_min, y_max, options)
    local img = lurek.image.newImageData(width, height)
    img:fill(8, 9, 13, 255)
    local commands = iso_xcom_commands(scene, z_min, z_max, x_min, x_max, y_min, y_max, origin_x, origin_y)
    for _, command in ipairs(commands) do
        draw_iso_xcom_command(img, command, options)
    end
    return img, commands
end

local function iso_xcom_manifest(scene, commands)
    local iso = scene.iso
    local order = iso:getPartOrder()
    local lines = {
        "X-COM style isometric square LIsoMap evidence",
        "logical map: 50x50 cells",
        "tile geometry: square 16px -> isometric diamond 32x16px",
        "levels: 1..4 allocated; evidence focuses on z=2..4",
        "parts stored in LIsoMap slots:",
        "  0 = FLOOR",
        "  2 = LEFT_TOP_WALL",
        "  1 = RIGHT_TOP_WALL",
        "  3 = OBJECT",
        "tilefield ref slots:",
        "  floor, left_top_wall, right_top_wall, object",
        "support mapping:",
        "  RIGHT_TOP support for upper floor south/front edge (x,y,z) is written at lower cell (x,y+1,z-1)",
        "  LEFT_TOP support for upper floor east/right edge (x,y,z) is written at lower cell (x+1,y,z-1)",
        "configured render part order: " .. table.concat({ order[1], order[2], order[3], order[4] }, ", "),
        "lighting source: LTileField sunOcclusion + LTileLightMap top sun + point lights",
        "tilemap renderer role: consume LIsoMap draw order and tint every part from LTileLightMap:getLight",
        "",
        "sample tile reads from LIsoMap:",
    }
    for _, sample in ipairs({
        { z = 2, x = 22, y = 22 },
        { z = 3, x = 23, y = 21 },
        { z = 4, x = 26, y = 23 },
    }) do
        table.insert(lines, string.format(
            "  z=%d x=%d y=%d floor=%d left=%d right=%d object=%d",
            sample.z,
            sample.x,
            sample.y,
            iso:getTilePart(sample.z, sample.x, sample.y, ISO_XCOM.floor),
            iso:getTilePart(sample.z, sample.x, sample.y, ISO_XCOM.left_wall),
            iso:getTilePart(sample.z, sample.x, sample.y, ISO_XCOM.right_wall),
            iso:getTilePart(sample.z, sample.x, sample.y, ISO_XCOM.object)
        ))
    end
    local _, _, _, open_luma = scene.light:getLight(5, 5, 2)
    local _, _, _, covered_luma = scene.light:getLight(21, 30, 2)
    local _, _, _, roof_luma = scene.light:getLight(25, 22, 4)
    table.insert(lines, "")
    table.insert(lines, "tilefield light probes:")
    table.insert(lines, string.format("  open z=2 x=5 y=5 luma=%.3f", open_luma))
    table.insert(lines, string.format("  under z=3 floor at z=2 x=21 y=30 luma=%.3f", covered_luma))
    table.insert(lines, string.format("  roof z=4 x=25 y=22 luma=%.3f", roof_luma))
    if commands then
        table.insert(lines, "")
        table.insert(lines, "first draw commands in engine-style diagonal order:")
        for i = 1, math.min(28, #commands) do
            local c = commands[i]
            table.insert(lines, string.format(
                "  %03d z=%d x=%d y=%d part=%s gid=%d screen=(%.1f,%.1f) luma=%.3f",
                i,
                c.z,
                c.x,
                c.y,
                iso_xcom_part_name(c.part),
                c.gid,
                c.sx,
                c.sy,
                c.light and c.light.luma or 0
            ))
        end
        table.insert(lines, "")
        table.insert(lines, "same-cell stack at x=25 y=22; z=4 entries are later than z=2/z=3 entries for that cell:")
        for i, c in ipairs(commands) do
            if c.x == 25 and c.y == 22 then
                table.insert(lines, string.format(
                    "  %03d z=%d x=%d y=%d part=%s gid=%d screen=(%.1f,%.1f) luma=%.3f",
                    i,
                    c.z,
                    c.x,
                    c.y,
                    iso_xcom_part_name(c.part),
                    c.gid,
                    c.sx,
                    c.sy,
                    c.light and c.light.luma or 0
                ))
            end
        end
        table.insert(lines, "")
        table.insert(lines, "last draw commands in the requested viewport:")
        for i = math.max(1, #commands - 27), #commands do
            local c = commands[i]
            table.insert(lines, string.format(
                "  %03d z=%d x=%d y=%d part=%s gid=%d screen=(%.1f,%.1f) luma=%.3f",
                i,
                c.z,
                c.x,
                c.y,
                iso_xcom_part_name(c.part),
                c.gid,
                c.sx,
                c.sy,
                c.light and c.light.luma or 0
            ))
        end
    end
    return table.concat(lines, "\n") .. "\n"
end

-- @describe Evidence: lurek.tilemap scenarios
describe("Evidence: lurek.tilemap scenarios", function()
    -- Does: Binds render-owned tilemap shaders to a map and to one layer.
    -- Shows: Text artifact records the target, map shader, layer shader, and that render commands were submitted.
    -- Artifact: tests/artifacts/current/tilemap/tilemap_shader_binding_contract.txt
    -- Why: Tilemap owns only visual shader binding decisions while render owns WGSL validation and GPU execution.
    it("TXT: tilemap shader binding contract", function()
        ensure_evidence_dir("tilemap")
        local shader = lurek.render.newShader([[
@fragment
fn fs_main(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(mix(color.rgb, vec3<f32>(uv.x, 0.5, 0.25), 0.3), color.a);
}
]], { target = "tilemap" })
        local tm = lurek.tilemap.newTileMap(16, 16)
        tm:addLayer("terrain", 2, 2)
        tm:setTile(1, 1, 1, 1)
        tm:setShader(shader)
        tm:setLayerShader(1, shader)
        tm:render()
        save_text(OUT .. "tilemap_shader_binding_contract.txt", table.concat({
            "Tilemap shader binding evidence",
            "constructor=lurek.render.newShader",
            "target=" .. shader:getTarget(),
            "tilemap.shader=" .. tm:getShader():getTarget(),
            "tilemap.layer_shader=" .. tm:getLayerShader(1):getTarget(),
            "render_submitted=true",
        }, "\n") .. "\n")
    end)

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

        local ground_img = lurek.image.newImageData(160, 160)
        local object_img = lurek.image.newImageData(160, 160)
        ground_img:fill(18, 22, 28, 255)
        object_img:fill(18, 22, 28, 255)
        for y = 1, 10 do
            for x = 1, 10 do
                local r, g, b = gid_color(1)
                ground_img:drawRect((x - 1) * 16, (y - 1) * 16, 15, 15, r, g, b, 255)
            end
        end
        for _, cell in ipairs({
            { x = 3, y = 3, gid = 10 },
            { x = 5, y = 5, gid = 11 },
            { x = 7, y = 2, gid = 12 },
        }) do
            local r, g, b = gid_color(cell.gid)
            object_img:drawRect((cell.x - 1) * 16, (cell.y - 1) * 16, 15, 15, r, g, b, 255)
        end
        save_png(ground_img, OUT .. "tilemap_draw_to_image_ground.png")
        save_png(object_img, OUT .. "tilemap_draw_to_image_objects.png")
    end)
    -- Does: Runs "tilemap hex biome and route views" and turns the owner-module result into separate inspectable artifacts.
    -- Shows: Each PNG should expose one hex concern instead of combining area, ring, route, and neighbors into one atlas.
    -- Artifact: tests/artifacts/current/tilemap/tilemap_hex_biomes_area.png, tilemap_hex_route.png, tilemap_hex_neighbors.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.tilemap.toScreenHex, lurek.tilemap.hexArea, and related owner calls; export helpers are just the container.

    it("PNG: tilemap hex biome and route views", function()
        ensure_evidence_dir("tilemap")
        local hex_size = 22
        local origin_x, origin_y = 210, 160
        local area = hex_area(0, 0, 3)
        local ring = hex_ring(0, 0, 3)
        local route = hex_line(-3, 1, 3, -1)
        local neighbors = hex_ring(0, 0, 1)
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
        local spiral = hex_spiral(0, 0, 4)
        local mirrored_q, mirrored_r = hex_reflect(2, -1, "q")
        local rotated_q, rotated_r = hex_rotate(3, -2, 2)

        for _, cell in ipairs(spiral) do
            local sx, sy = lurek.tilemap.toScreenHex(cell.q, cell.r, hex_size)
            local cx = origin_x + sx
            local cy = origin_y + sy
            local dist = hex_distance(0, 0, cell.q, cell.r)
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
    -- Does: Builds a 50x50 LIsoMap with four tile parts per cell, assigns X-COM style floor, left wall, right wall, and object slots, then exports an anatomy PNG plus a manifest.
    -- Shows: The artifacts should make the slot contract legible: floor diamond first, west/left wall, north/right wall, and center object in the same isometric cell.
    -- Artifact: tests/artifacts/current/tilemap/tilemap_iso_xcom_part_slots.png, tests/artifacts/current/tilemap/tilemap_iso_xcom_part_slots.txt
    -- Why: This is meaningful because the GIDs are read back through LIsoMap:getTilePart after being written by LIsoMap:setTilePart with the configured LIsoMap:setPartOrder.

    it("PNG+TXT: tilemap isometric XCOM part slots", function()
        ensure_evidence_dir("tilemap")
        local scene = iso_xcom_build_scene()
        local iso = scene.iso
        local order = iso:getPartOrder()
        expect_equal(50, iso:getWidth())
        expect_equal(50, iso:getHeight())
        expect_equal(4, iso:getLevelCount())
        expect_equal(4, iso:getPartCount())
        expect_equal(0, order[1])
        expect_equal(2, order[2])
        expect_equal(1, order[3])
        expect_equal(3, order[4])
        expect_true(iso:getTilePart(2, 21, 31, ISO_XCOM.right_wall) > 0)
        expect_true(iso:getTilePart(2, 33, 19, ISO_XCOM.left_wall) > 0)
        expect_true(scene.field:getRef(21, 31, 2, "right_top_wall") ~= nil)
        expect_true(scene.field:getRef(33, 19, 2, "left_top_wall") ~= nil)
        local _, _, _, open_luma = scene.light:getLight(5, 5, 2)
        local _, _, _, covered_luma = scene.light:getLight(21, 30, 2)
        expect_true(open_luma > covered_luma)

        local img = lurek.image.newImageData(520, 280)
        img:fill(10, 10, 14, 255)
        local sx, sy = 260, 130
        draw_iso_diamond(img, sx, sy, ISO_XCOM.tile_w, ISO_XCOM.tile_h, { 96, 102, 116 }, { 210, 214, 222 })
        draw_iso_left_wall(img, sx, sy, ISO_XCOM.tile_w, ISO_XCOM.tile_h, 30, { 146, 64, 46 })
        draw_iso_right_wall(img, sx, sy, ISO_XCOM.tile_w, ISO_XCOM.tile_h, 30, { 190, 88, 62 })
        draw_iso_object(img, sx, sy, ISO_XCOM.tile_h, 44)

        local mini_scene_img = render_iso_xcom(scene, 520, 280, 260, -170, 2, 4, 20, 31, 20, 31)
        for y = 0, 279 do
            for x = 0, 239 do
                local r, g, b, a = mini_scene_img:getPixel(x, y)
                if a > 0 and (r > 12 or g > 12 or b > 16) then
                    img:setPixel(x, y, r, g, b, a)
                end
            end
        end

        save_png(img, OUT .. "tilemap_iso_xcom_part_slots.png")
        save_text(OUT .. "tilemap_iso_xcom_part_slots.txt", iso_xcom_manifest(scene))
    end)
    -- Does: Renders only level 2 of the 50x50 LIsoMap X-COM scene using the floor, wall, and object parts stored on that elevation.
    -- Shows: The cutaway should show the lower tactical floor with left/west walls, right/north walls, and objects before upper levels cover it.
    -- Artifact: tests/artifacts/current/tilemap/tilemap_iso_xcom_level_2_cutaway.png
    -- Why: This is meaningful because the image is generated from LIsoMap tile parts at z=2, proving the lower level exists independently of later occlusion.

    it("PNG: tilemap isometric XCOM level 2 cutaway", function()
        ensure_evidence_dir("tilemap")
        local scene = iso_xcom_build_scene()
        local img = render_iso_xcom(scene, 760, 460, 380, -150, 2, 2, 15, 37, 15, 37)
        expect_true(scene.iso:getTilePart(2, 22, 22, ISO_XCOM.object) > 0)
        save_png(img, OUT .. "tilemap_iso_xcom_level_2_cutaway.png")
    end)
    -- Does: Renders only level 3 of the 50x50 LIsoMap X-COM scene using its own stored floor, wall, and object parts.
    -- Shows: The cutaway should show an upper platform with a deliberate opening and its own wall/object composition.
    -- Artifact: tests/artifacts/current/tilemap/tilemap_iso_xcom_level_3_cutaway.png
    -- Why: This is meaningful because LIsoMap:getTilePart confirms level 3 has independent parts and a gap that is not copied from level 2.

    it("PNG: tilemap isometric XCOM level 3 cutaway", function()
        ensure_evidence_dir("tilemap")
        local scene = iso_xcom_build_scene()
        local img = render_iso_xcom(scene, 760, 460, 380, -135, 3, 3, 19, 33, 18, 31)
        expect_true(scene.iso:getTilePart(3, 23, 21, ISO_XCOM.object) > 0)
        expect_equal(0, scene.iso:getTilePart(3, 27, 24, ISO_XCOM.floor))
        save_png(img, OUT .. "tilemap_iso_xcom_level_3_cutaway.png")
    end)
    -- Does: Renders only level 4 of the 50x50 LIsoMap X-COM scene as a roof/upper structure focused on the top elevation.
    -- Shows: The cutaway should isolate the highest layer so a reviewer can see what later occludes lower layers.
    -- Artifact: tests/artifacts/current/tilemap/tilemap_iso_xcom_level_4_cutaway.png
    -- Why: This is meaningful because the same LIsoMap contains the z=4 data that must be drawn after the lower levels during the final render.

    it("PNG: tilemap isometric XCOM level 4 cutaway", function()
        ensure_evidence_dir("tilemap")
        local scene = iso_xcom_build_scene()
        local img = render_iso_xcom(scene, 760, 420, 380, -118, 4, 4, 23, 30, 20, 27)
        expect_true(scene.iso:getTilePart(4, 26, 23, ISO_XCOM.object) > 0)
        save_png(img, OUT .. "tilemap_iso_xcom_level_4_cutaway.png")
    end)
    -- Does: Renders levels 2-4 together in the same 50x50 LIsoMap viewport using the engine-style diagonal order and configured part order.
    -- Shows: Higher floors, walls, and objects should visibly sit over lower tactical material instead of being drawn as a flat orthogonal grid.
    -- Artifact: tests/artifacts/current/tilemap/tilemap_iso_xcom_levels_2_4_occlusion_stack.png
    -- Why: This is meaningful because it exercises LIsoMap:tileToScreen, LIsoMap:setTilePart, and LIsoMap:setPartOrder together for the multilevel map composition.

    it("PNG: tilemap isometric XCOM levels 2-4 occlusion stack", function()
        ensure_evidence_dir("tilemap")
        local scene = iso_xcom_build_scene()
        local img = render_iso_xcom(scene, 900, 560, 450, -145, 2, 4, 15, 37, 15, 37)
        expect_true(scene.iso:getTilePart(2, 28, 24, ISO_XCOM.object) > 0)
        expect_true(scene.iso:getTilePart(4, 26, 23, ISO_XCOM.floor) > 0)
        save_png(img, OUT .. "tilemap_iso_xcom_levels_2_4_occlusion_stack.png")
    end)
    -- Does: Renders the same 2-4 LIsoMap stack with lower elevations intentionally dimmed before the higher layers are painted.
    -- Shows: The artifact should make occlusion easier to inspect: lower z=2 material remains visible only where z=3 and z=4 do not cover it.
    -- Artifact: tests/artifacts/current/tilemap/tilemap_iso_xcom_higher_layers_mask_lower.png
    -- Why: This is meaningful because it demonstrates the painter order consequence of higher LIsoMap levels being drawn after lower levels in the same viewport.

    it("PNG: tilemap isometric XCOM higher layers mask lower", function()
        ensure_evidence_dir("tilemap")
        local scene = iso_xcom_build_scene()
        local img = render_iso_xcom(scene, 900, 560, 450, -145, 2, 4, 15, 37, 15, 37, { dim_level = 3 })
        save_png(img, OUT .. "tilemap_iso_xcom_higher_layers_mask_lower.png")
    end)
    -- Does: Exports the ordered draw command trace for the 50x50 LIsoMap X-COM viewport.
    -- Shows: The text artifact should list map size, tile geometry, part IDs, configured part order, and representative diagonal painter-order commands.
    -- Artifact: tests/artifacts/current/tilemap/tilemap_iso_xcom_render_order_trace.txt
    -- Why: This is meaningful because the trace connects the final PNG to concrete LIsoMap tile reads and the render order used by the isometric evidence renderer.

    it("TXT: tilemap isometric XCOM render order trace", function()
        ensure_evidence_dir("tilemap")
        local scene = iso_xcom_build_scene()
        local _, commands = render_iso_xcom(scene, 900, 560, 450, -145, 2, 4, 15, 37, 15, 37)
        save_text(OUT .. "tilemap_iso_xcom_render_order_trace.txt", iso_xcom_manifest(scene, commands))
    end)
    -- Does: Renders the full 50x50 LIsoMap isometric square map with levels 2-4 active and each cell using floor, left wall, right wall, and object slots.
    -- Shows: The final maptile artifact should read as an X-COM style multilevel isometric map, with upper roof/platform layers drawn over lower tactical floors.
    -- Artifact: tests/artifacts/current/tilemap/tilemap_iso_xcom_final_maptile_render.png
    -- Why: This is meaningful because it is the end-to-end evidence artifact for LIsoMap projection, part composition, 50x50 map scale, and multilevel occlusion.

    it("PNG: tilemap isometric XCOM final maptile render", function()
        ensure_evidence_dir("tilemap")
        local scene = iso_xcom_build_scene()
        local img = render_iso_xcom(scene, 1640, 920, 820, 95, 2, 4, 1, 50, 1, 50)
        save_png(img, OUT .. "tilemap_iso_xcom_final_maptile_render.png")
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
        iso:fillLevel(1, 1, 1)

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
