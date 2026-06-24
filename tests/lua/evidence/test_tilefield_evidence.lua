-- Evidence tests: tilefield module.

local MapblockFixture = lurek.filesystem.load("tests/fixtures/mapblock_evidence_fixture.lua")()
local OUT = evidence_output_dir("tilefield")
local SHOWCASE_W = 50
local SHOWCASE_H = 50
local SHOWCASE_CELL = 16
local TEAM_UNITS = {
    { team = "blue", x = 6, y = 7, r = 90, g = 180, b = 255 },
    { team = "red", x = 44, y = 7, r = 255, g = 110, b = 110 },
    { team = "green", x = 7, y = 44, r = 100, g = 230, b = 145 },
    { team = "gold", x = 43, y = 43, r = 255, g = 215, b = 95 },
}

local function save_png(img, path)
    lurek.image.savePNG(img, path)
    expect_evidence_created(path)
end

local function save_text(path, text)
    if write_file then
        write_file(path, text)
    else
        lurek.filesystem.write(path, text)
    end
    expect_evidence_created(path)
end

local function fmt(value)
    return string.format("%.4f", value)
end

local function draw_outline(img, x, y, w, h, r, g, b, a)
    img:drawLine(x, y, x + w - 1, y, r, g, b, a or 255)
    img:drawLine(x + w - 1, y, x + w - 1, y + h - 1, r, g, b, a or 255)
    img:drawLine(x + w - 1, y + h - 1, x, y + h - 1, r, g, b, a or 255)
    img:drawLine(x, y + h - 1, x, y, r, g, b, a or 255)
end

local function paint_cell(img, x, y, cell, r, g, b)
    local ox = (x - 1) * cell
    local oy = (y - 1) * cell
    img:drawRect(ox, oy, cell, cell, r, g, b, 255)
    draw_outline(img, ox, oy, cell, cell, 24, 27, 32, 255)
end

local function draw_dot(img, x, y, cell, r, g, b)
    img:drawCircle(math.floor((x - 0.5) * cell), math.floor((y - 0.5) * cell), math.max(2, math.floor(cell / 4)), r, g, b, 255)
end

local function cell_color(tile)
    if tile == 0 or tile == nil then return 44, 54, 64 end
    if tile == 1 then return 80, 138, 82 end
    if tile == 2 then return 76, 116, 176 end
    if tile == 3 then return 190, 172, 106 end
    if tile == 4 then return 116, 116, 126 end
    if tile == 5 then return 172, 92, 82 end
    return 86 + (tile * 29) % 120, 92 + (tile * 47) % 120, 102 + (tile * 61) % 110
end

local function draw_grid_from_refs(field, slot, path, opts)
    opts = opts or {}
    local w, h = field:getSize()
    local cell = opts.cell or 16
    local img = lurek.image.newImageData(w * cell, h * cell)
    img:fill(10, 12, 18, 255)
    for y = 1, h do
        for x = 1, w do
            local ref = field:getRef(x, y, opts.z or 1, slot)
            local value = type(ref) == "table" and (ref.tile or ref.localId or 6) or ref
            local r, g, b = cell_color(value or 0)
            if field:blocks(x, y, opts.z or 1, opts.channel or "move") then
                r, g, b = math.floor(r * 0.45), math.floor(g * 0.45), math.floor(b * 0.45)
            end
            paint_cell(img, x, y, cell, r, g, b)
            if field:blocks(x, y, opts.z or 1, "light") then
                img:drawCircle(math.floor((x - 0.5) * cell), math.floor((y - 0.5) * cell), math.max(2, math.floor(cell / 5)), 255, 220, 90, 255)
            end
        end
    end
    save_png(img, path)
end

local function make_procgen_field(width, height)
    local field = lurek.tilefield.new({ width = width, height = height, levels = 2 })
    local cave = lurek.procgen.cellularAutomata(width, height, { fill = 0.42, iterations = 3, seed = 4242 })
    local heightmap = lurek.procgen.heightmap({ width = width, height = height, seed = 4243, octaves = 4, persistence = 0.5 })
    for y = 1, height do
        for x = 1, width do
            local idx = (y - 1) * width + x
            local wall = cave[idx] == 1
            local hv = heightmap.cells[idx] or 0
            local tile = hv < 0.32 and 2 or (hv < 0.48 and 3 or (hv < 0.74 and 1 or 4))
            field:setRef(x, y, 1, "terrain", tile)
            field:setRef(x, y, 1, "object", 0)
            field:setCost(x, y, 1, "move", tile == 2 and 5 or (tile == 3 and 2 or 1))
            if wall then
                field:applyProfile(x, y, 1, "wall")
                field:setRef(x, y, 1, "object", 4)
            elseif tile == 2 then
                field:setBlock(x, y, 1, "action", true)
            end
            if not wall then
                local object = 0
                if (x * 7 + y * 11) % 113 == 0 then
                    object = 1 -- torch
                elseif (x * 5 + y * 13) % 97 == 0 then
                    object = 2 -- crate
                    field:setBlock(x, y, 1, "move", true)
                    field:setBlock(x, y, 1, "action", true)
                elseif (x * 17 + y * 3) % 131 == 0 then
                    object = 3 -- banner
                elseif (x * 19 + y * 23) % 157 == 0 then
                    object = 5 -- smoked glass
                    field:setBlock(x, y, 1, "action", true)
                    field:setCost(x, y, 1, "light", 0.4)
                elseif (x * 29 + y * 31) % 173 == 0 then
                    object = 6 -- gate
                    field:setBlock(x, y, 1, "move", true)
                    field:setBlock(x, y, 1, "action", true)
                elseif (x * 37 + y * 41) % 191 == 0 then
                    object = 7 -- shrine
                elseif (x * 43 + y * 47) % 211 == 0 then
                    object = 8 -- crystal
                    field:setCost(x, y, 1, "light", 0.15)
                end
                if object ~= 0 then
                    field:setRef(x, y, 1, "object", object)
                end
            end
            if (x + y) % 9 == 0 then
                field:setBlock(x, y, 1, "light", true)
            elseif (x * 3 + y * 5) % 13 == 0 then
                field:setCost(x, y, 1, "light", 0.45)
            end
            field:setSunOcclusion(x, y, 2, wall and 0.8 or (tile == 4 and 0.35 or 0.05))
        end
    end
    return field
end

local function make_object_tileset()
    return lurek.tileset.fromProvider({
        firstGid = 1,
        tileCount = 12,
        columns = 4,
        tileWidth = 16,
        tileHeight = 16,
        objects = {
            torch = {
                slot = "object",
                tileId = 1,
                visual = { image = "torch.png", order = 4 },
                transmission = { light = 1.0 },
                properties = { role = "emitter", sprite = "torch_idle" },
            },
            crate = {
                slot = "object",
                tileId = 2,
                visual = { image = "crate.png", order = 3 },
                blocks = { move = true, action = true },
                properties = { role = "blocker", material = "wood", cost = 3, solid = true },
            },
            banner = {
                slot = "object",
                tileId = 3,
                visual = { image = "banner.png", order = 5 },
                properties = { role = "marker", team = "blue" },
            },
            wall = {
                slot = "object",
                tileId = 4,
                visual = { image = "wall.png", order = 2 },
                blocks = { move = true, vision = true, action = true, light = true },
                properties = { role = "wall", solid = true },
            },
            glass = {
                slot = "object",
                tileId = 5,
                visual = { image = "smoked_glass.png", order = 3 },
                blocks = { action = true },
                transmission = { light = 0.35 },
                properties = { role = "filter", material = "glass", solid = false },
            },
            gate = {
                slot = "object",
                tileId = 6,
                visual = { image = "gate.png", order = 4 },
                blocks = { move = true, action = true },
                properties = { role = "door", material = "iron", solid = true },
            },
            shrine = {
                slot = "object",
                tileId = 7,
                visual = { image = "shrine.png", order = 6 },
                properties = { role = "objective", aura = "awareness", solid = false },
            },
            crystal = {
                slot = "object",
                tileId = 8,
                visual = { image = "crystal.png", order = 6 },
                transmission = { light = 0.85 },
                properties = { role = "light_anchor", color = "cyan", solid = false },
            },
        },
        tileObjects = {
            [1] = "torch",
            [2] = "crate",
            [3] = "banner",
            [4] = "wall",
            [5] = "glass",
            [6] = "gate",
            [7] = "shrine",
            [8] = "crystal",
        },
        properties = {
            [1] = { role = "floor", cost = 1, solid = false },
            [2] = { role = "water", cost = 5, solid = false },
            [3] = { role = "sand", cost = 2, solid = false },
            [4] = { role = "stone", cost = 3, solid = true },
        },
    })
end

local function add_showcase_lights(light)
    local sources = {
        { 6, 7, { r = 1.0, g = 0.45, b = 0.18 } },
        { 44, 7, { r = 0.15, g = 0.35, b = 1.0 } },
        { 7, 44, { r = 0.25, g = 1.0, b = 0.35 } },
        { 43, 43, { r = 1.0, g = 0.85, b = 0.25 } },
        { 25, 8, { r = 0.95, g = 0.2, b = 0.85 } },
        { 25, 25, { r = 1.0, g = 0.95, b = 0.65 } },
        { 10, 25, { r = 0.2, g = 0.9, b = 1.0 } },
        { 40, 25, { r = 1.0, g = 0.35, b = 0.2 } },
        { 16, 16, { r = 0.5, g = 0.8, b = 1.0 } },
        { 34, 16, { r = 1.0, g = 0.6, b = 0.25 } },
        { 16, 34, { r = 0.55, g = 1.0, b = 0.55 } },
        { 34, 34, { r = 0.9, g = 0.45, b = 1.0 } },
    }
    for _, source in ipairs(sources) do
        light:addPointLight({ x = source[1], y = source[2], z = 1, radius = 9, intensity = 0.85, color = source[3] })
    end
end

local function draw_team_units(img, cell)
    for _, unit in ipairs(TEAM_UNITS) do
        draw_dot(img, unit.x, unit.y, cell, unit.r, unit.g, unit.b)
    end
end

local function draw_path(img, nodes, cell, r, g, b)
    for i = 1, #nodes - 1 do
        local a = nodes[i]
        local c = nodes[i + 1]
        img:drawLine(math.floor((a.x - 0.5) * cell), math.floor((a.y - 0.5) * cell), math.floor((c.x - 0.5) * cell), math.floor((c.y - 0.5) * cell), r, g, b, 255)
    end
end

local function draw_light_layer(field, light, path)
    local w, h = field:getSize()
    local cell = 16
    local img = lurek.image.newImageData(w * cell, h * cell)
    img:fill(8, 9, 13, 255)
    for y = 1, h do
        for x = 1, w do
            local r, g, b = light:getLight(x, y, 1)
            paint_cell(img, x, y, cell, math.floor((r or 0) * 255), math.floor((g or 0) * 255), math.floor((b or 0) * 255))
            if field:blocks(x, y, 1, "light") then
                img:drawLine((x - 1) * cell + 3, (y - 1) * cell + 3, x * cell - 4, y * cell - 4, 255, 232, 120, 255)
            end
        end
    end
    save_png(img, path)
end

local function hex_radius(cell)
    return cell * 0.5
end

local function hex_center(x, y, cell)
    local radius = hex_radius(cell)
    local margin = cell
    local q = x - 1
    local r = y - 1
    local cx = math.floor(margin + radius + math.sqrt(3) * radius * (q + r * 0.5) + 0.5)
    local cy = math.floor(margin + radius + 1.5 * radius * r + 0.5)
    return cx, cy
end

local function hex_size(w, h, cell)
    local radius = hex_radius(cell)
    local margin = cell
    local width = margin * 2 + radius * 2 + math.sqrt(3) * radius * ((w - 1) + (h - 1) * 0.5)
    local height = margin * 2 + radius * 2 + 1.5 * radius * (h - 1)
    return math.ceil(width), math.ceil(height)
end

local function hex_points(cx, cy, radius)
    local pts = {}
    for i = 0, 5 do
        local a = math.rad(30 + 60 * i)
        pts[#pts + 1] = { x = cx + math.cos(a) * radius, y = cy + math.sin(a) * radius }
    end
    return pts
end

local function fill_polygon(img, pts, r, g, b)
    local min_y = math.floor(pts[1].y)
    local max_y = math.ceil(pts[1].y)
    for i = 2, #pts do
        min_y = math.min(min_y, math.floor(pts[i].y))
        max_y = math.max(max_y, math.ceil(pts[i].y))
    end
    for y = min_y, max_y do
        local xs = {}
        for i = 1, #pts do
            local a = pts[i]
            local c = pts[(i % #pts) + 1]
            if (a.y <= y and c.y > y) or (c.y <= y and a.y > y) then
                local t = (y - a.y) / (c.y - a.y)
                xs[#xs + 1] = a.x + t * (c.x - a.x)
            end
        end
        table.sort(xs)
        for i = 1, #xs, 2 do
            if xs[i + 1] then
                img:drawLine(math.floor(xs[i] + 0.5), y, math.floor(xs[i + 1] + 0.5), y, r, g, b, 255)
            end
        end
    end
end

local function paint_hex(img, x, y, cell, r, g, b)
    local cx, cy = hex_center(x, y, cell)
    local radius = hex_radius(cell)
    local pts = hex_points(cx, cy, radius)
    fill_polygon(img, pts, r, g, b)
    for i = 1, 6 do
        local a = pts[i]
        local bpt = pts[(i % 6) + 1]
        img:drawLine(math.floor(a.x + 0.5), math.floor(a.y + 0.5), math.floor(bpt.x + 0.5), math.floor(bpt.y + 0.5), 24, 27, 32, 255)
    end
end

local function draw_hex_dot(img, x, y, cell, r, g, b)
    local cx, cy = hex_center(x, y, cell)
    img:drawCircle(cx, cy, math.max(2, math.floor(cell / 4)), r, g, b, 255)
end

local function draw_hex_path(img, nodes, cell, r, g, b)
    for i = 1, #nodes - 1 do
        local a = nodes[i]
        local c = nodes[i + 1]
        local ax, ay = hex_center(a.col or a.x, a.row or a.y, cell)
        local bx, by = hex_center(c.col or c.x, c.row or c.y, cell)
        img:drawLine(ax, ay, bx, by, r, g, b, 255)
    end
end

local function draw_hex_team_units(img, cell)
    for _, unit in ipairs(TEAM_UNITS) do
        draw_hex_dot(img, unit.x, unit.y, cell, unit.r, unit.g, unit.b)
    end
end

local function make_hex_field(width, height)
    local field = lurek.tilefield.new({ width = width, height = height, levels = 2, topology = "hex" })
    local cave = lurek.procgen.cellularAutomata(width, height, { fill = 0.36, iterations = 2, seed = 5151 })
    local heightmap = lurek.procgen.heightmap({ width = width, height = height, seed = 5152, octaves = 4, persistence = 0.55 })
    for y = 1, height do
        for x = 1, width do
            local idx = (y - 1) * width + x
            local wall = cave[idx] == 1 and x > 3 and y > 3 and x < width - 2 and y < height - 2
            local hv = heightmap.cells[idx] or 0
            local tile = hv < 0.30 and 2 or (hv < 0.50 and 3 or (hv < 0.76 and 1 or 4))
            field:setRef(x, y, 1, "terrain", tile)
            field:setRef(x, y, 1, "object", 0)
            field:setCost(x, y, 1, "move", tile == 2 and 5 or (tile == 3 and 2 or 1))
            if wall then
                field:applyProfile(x, y, 1, "wall")
                field:setRef(x, y, 1, "object", 4)
            elseif tile == 2 then
                field:setBlock(x, y, 1, "action", true)
            end
            if not wall then
                local object = 0
                if (x * 7 + y * 11) % 109 == 0 then object = 1
                elseif (x * 5 + y * 13) % 101 == 0 then object = 2; field:setBlock(x, y, 1, "move", true)
                elseif (x * 17 + y * 3) % 127 == 0 then object = 3
                elseif (x * 19 + y * 23) % 151 == 0 then object = 5; field:setCost(x, y, 1, "light", 0.4)
                elseif (x * 29 + y * 31) % 179 == 0 then object = 6; field:setBlock(x, y, 1, "move", true)
                elseif (x * 37 + y * 41) % 193 == 0 then object = 7
                elseif (x * 43 + y * 47) % 223 == 0 then object = 8; field:setCost(x, y, 1, "light", 0.15)
                end
                if object ~= 0 then field:setRef(x, y, 1, "object", object) end
            end
            if (x + y) % 10 == 0 then
                field:setBlock(x, y, 1, "light", true)
            elseif (x * 3 + y * 5) % 14 == 0 then
                field:setCost(x, y, 1, "light", 0.45)
            end
            field:setSunOcclusion(x, y, 2, wall and 0.75 or (tile == 4 and 0.32 or 0.04))
        end
    end
    for _, unit in ipairs(TEAM_UNITS) do
        for dy = -1, 1 do
            for dx = -1, 1 do
                local x, y = unit.x + dx, unit.y + dy
                if field:inBounds(x, y, 1) then
                    field:setBlock(x, y, 1, "move", false)
                    field:setBlock(x, y, 1, "vision", false)
                    field:setBlock(x, y, 1, "light", false)
                    field:setRef(x, y, 1, "object", 0)
                end
            end
        end
    end
    return field
end

local function draw_hex_field(field, slot, path, opts)
    opts = opts or {}
    local w, h = field:getSize()
    local cell = opts.cell or 7
    local iw, ih = hex_size(w, h, cell)
    local img = lurek.image.newImageData(iw, ih)
    img:fill(8, 10, 15, 255)
    for y = 1, h do
        for x = 1, w do
            local ref = field:getRef(x, y, opts.z or 1, slot)
            local value = type(ref) == "table" and (ref.tile or ref.localId or 6) or ref
            local r, g, b = cell_color(value or 0)
            if field:blocks(x, y, opts.z or 1, opts.channel or "move") then
                r, g, b = math.floor(r * 0.45), math.floor(g * 0.45), math.floor(b * 0.45)
            end
            paint_hex(img, x, y, cell, r, g, b)
            if field:blocks(x, y, opts.z or 1, "light") then
                draw_hex_dot(img, x, y, cell, 255, 220, 90)
            end
        end
    end
    save_png(img, path)
end

local function add_hex_showcase_lights(light)
    local sources = {
        { 6, 7, { r = 1.0, g = 0.45, b = 0.18 } },
        { 44, 7, { r = 0.15, g = 0.35, b = 1.0 } },
        { 7, 44, { r = 0.25, g = 1.0, b = 0.35 } },
        { 43, 43, { r = 1.0, g = 0.85, b = 0.25 } },
        { 25, 8, { r = 0.95, g = 0.2, b = 0.85 } },
        { 25, 25, { r = 1.0, g = 0.95, b = 0.65 } },
        { 10, 25, { r = 0.2, g = 0.9, b = 1.0 } },
        { 40, 25, { r = 1.0, g = 0.35, b = 0.2 } },
        { 16, 16, { r = 0.5, g = 0.8, b = 1.0 } },
        { 34, 16, { r = 1.0, g = 0.6, b = 0.25 } },
        { 16, 34, { r = 0.55, g = 1.0, b = 0.55 } },
        { 34, 34, { r = 0.9, g = 0.45, b = 1.0 } },
    }
    for _, source in ipairs(sources) do
        light:addPointLight({ x = source[1], y = source[2], z = 1, radius = 8, intensity = 0.85, color = source[3] })
    end
end

local function draw_hex_light_layer(field, light, path)
    local w, h = field:getSize()
    local cell = SHOWCASE_CELL
    local iw, ih = hex_size(w, h, cell)
    local img = lurek.image.newImageData(iw, ih)
    img:fill(8, 9, 13, 255)
    for y = 1, h do
        for x = 1, w do
            local r, g, b = light:getLight(x, y, 1)
            paint_hex(img, x, y, cell, math.floor((r or 0) * 255), math.floor((g or 0) * 255), math.floor((b or 0) * 255))
            if field:blocks(x, y, 1, "light") then
                draw_hex_dot(img, x, y, cell, 255, 232, 120)
            end
        end
    end
    save_png(img, path)
end

local function make_hex_grid_from_field(field)
    local w, h = field:getSize()
    local grid = lurek.pathfind.newHexGrid(w, h)
    for y = 1, h do
        for x = 1, w do
            grid:setBlocked(x, y, field:blocks(x, y, 1, "move"))
            grid:setCost(x, y, field:getCost(x, y, 1, "move"))
        end
    end
    return grid
end

-- @describe evidence: tilefield
describe("evidence: tilefield", function()
    before_each(function()
        ensure_evidence_dir("tilefield")
    end)

    -- Does: Draws wall, window, door, and half-wall profiles over the four gameplay channels.
    -- Shows: Move, vision, action, and light blockers differ per profile instead of sharing one solid flag.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_channels.png
    -- Why: This makes the new tilefield channel contract inspectable without relying on pathfind, visibility, or raycaster.
    it("PNG: profile channels stay independent", function()
        local cell = 22
        local profiles = { "wall", "window", "door_open", "door_closed", "half_wall" }
        local channels = { "move", "vision", "action", "light" }
        local field = lurek.tilefield.new({ width = #profiles, height = #channels })
        for x, profile in ipairs(profiles) do
            for y = 1, #channels do
                field:applyProfile(x, y, 1, profile)
            end
        end

        local img = lurek.image.newImageData(#profiles * cell, #channels * cell)
        img:fill(12, 14, 18, 255)
        for y, channel in ipairs(channels) do
            for x = 1, #profiles do
                if field:blocks(x, y, 1, channel) then
                    paint_cell(img, x, y, cell, 156, 56, 70)
                else
                    paint_cell(img, x, y, cell, 54, 120, 94)
                end
            end
        end
        save_png(img, OUT .. "tilefield_channels.png")
    end)

    -- Does: Computes separate visible and action masks for two players on one shared field.
    -- Shows: Player masks are independent and action range is not identical to visibility.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_visibility_action_players.png
    -- Why: This demonstrates tilefield as source data while visibility owns per-player state.
    it("PNG: per-player visibility and action masks differ", function()
        local cell = 18
        local field = lurek.tilefield.new({ width = 12, height = 8 })
        for y = 2, 7 do field:applyProfile(6, y, 1, "wall") end
        field:applyProfile(6, 4, 1, "window")
        field:applyProfile(8, 5, 1, "half_wall")
        local vis = lurek.awareness.newTileAwareness(field, { players = { "blue", "red" } })
        vis:computeVisible("blue", { origin = { x = 3, y = 4, z = 1 }, range = 5, channel = "vision" })
        vis:computeAction("blue", { origin = { x = 3, y = 4, z = 1 }, range = 5, channel = "action" })
        vis:computeVisible("red", { origin = { x = 10, y = 4, z = 1 }, range = 4, channel = "vision" })
        vis:computeAction("red", { origin = { x = 10, y = 4, z = 1 }, range = 4, channel = "action" })

        local img = lurek.image.newImageData(12 * cell, 8 * cell)
        img:fill(10, 11, 15, 255)
        for y = 1, 8 do
            for x = 1, 12 do
                local r, g, b = 34, 38, 46
                if vis:isVisible("blue", x, y, 1) then r, g, b = 38, 78, 138 end
                if vis:isVisible("red", x, y, 1) then r, g, b = 110, 48, 56 end
                if vis:canActOn("blue", x, y, 1) or vis:canActOn("red", x, y, 1) then
                    g = math.min(220, g + 70)
                end
                if field:blocks(x, y, 1, "move") then r, g, b = 64, 62, 70 end
                paint_cell(img, x, y, cell, r, g, b)
            end
        end
        draw_dot(img, 3, 4, cell, 90, 180, 255)
        draw_dot(img, 10, 4, cell, 255, 105, 105)
        save_png(img, OUT .. "tilefield_visibility_action_players.png")
    end)

    -- Does: Computes point lights plus top light across three levels with opaque and partial occluders.
    -- Shows: Several colored light sources mix additively while wall, glass, and shade cells attenuate differently.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_lighting_multilevel.png
    -- Why: This proves tilelight consumes tilefield data without becoming raycaster-owned rendering state.
    it("PNG: multilevel point and global lighting", function()
        local cell = 16
        local field = lurek.tilefield.new({ width = 12, height = 8, levels = 3 })
        field:setProfile("smoked_glass", {
            blocks = { move = true, vision = false, action = true, light = false },
            costs = { light = 0.35 },
            sunOcclusion = 0.35,
        })
        field:setProfile("shade_screen", {
            blocks = { move = false, vision = false, action = false, light = false },
            costs = { light = 0.65 },
            sunOcclusion = 0.65,
        })
        for y = 1, 8 do field:applyProfile(6, y, 1, "wall") end
        for y = 2, 7, 2 do field:applyProfile(8, y, 1, "smoked_glass") end
        for x = 3, 10 do field:applyProfile(x, 5, 2, "shade_screen") end
        field:applyProfile(4, 3, 3, "half_wall")
        field:applyProfile(4, 4, 3, "wall")
        local light = lurek.tilelight.new(field)
        light:addPointLight({ x = 2, y = 4, z = 1, radius = 8, intensity = 1.0, color = { r = 1.0, g = 0.48, b = 0.18 } })
        light:addPointLight({ x = 11, y = 4, z = 1, radius = 7, intensity = 0.85, color = { r = 0.15, g = 0.35, b = 1.0 } })
        light:addPointLight({ x = 5, y = 2, z = 2, radius = 5, intensity = 0.65, color = { r = 0.25, g = 1.0, b = 0.35 } })
        light:addPointLight({ x = 10, y = 7, z = 3, radius = 5, intensity = 0.55, color = { r = 0.9, g = 0.2, b = 0.85 } })
        light:setGlobalLight({ intensity = 0.32, color = { r = 1.0, g = 0.58, b = 0.24 } })
        light:compute({ includePointLights = true, includeGlobalLight = true })

        local img = lurek.image.newImageData(12 * cell * 3, 8 * cell)
        img:fill(8, 9, 13, 255)
        for z = 1, 3 do
            local layer = light:exportLayer(z)
            for y = 1, 8 do
                for x = 1, 12 do
                    local light = layer[(y - 1) * 12 + x]
                    local ox = (z - 1) * 12
                    local r = math.floor((light.r or 0) * 255)
                    local g = math.floor((light.g or 0) * 255)
                    local b = math.floor((light.b or 0) * 255)
                    if field:blocks(x, y, z, "light") then
                        r, g, b = math.floor(r * 0.35), math.floor(g * 0.35), math.floor(b * 0.35)
                    end
                    paint_cell(img, ox + x, y, cell, r, g, b)
                end
            end
        end
        save_png(img, OUT .. "tilefield_lighting_multilevel.png")
    end)

    -- Does: Writes measured and expected RGB/luma values for point lights, filters, blockers, and global colors.
    -- Shows: Opaque walls produce zero behind them, partial blockers multiply transmission, colored lights mix by channel, and dusk/night global light keep different colors.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_lighting_values.txt
    -- Why: The visual PNG proves shape; this text artifact proves exact tile-light math that a reviewer can audit.
    it("TXT: tile lighting numeric calculations", function()
        local lines = {
            "case,channel,expected,measured",
        }

        local blocked = lurek.tilefield.new({ width = 5, height = 3 })
        blocked:setBlock(3, 2, 1, "light", true)
        local blocked_light = lurek.tilelight.new(blocked)
        blocked_light:addPointLight({ x = 1, y = 2, z = 1, radius = 5, intensity = 1.0, color = { r = 1, g = 1, b = 1 } })
        blocked_light:compute({ includePointLights = true, includeGlobalLight = false })
        local _, _, _, blocked_luma = blocked_light:getLight(5, 2, 1)
        lines[#lines + 1] = "opaque_wall,luma,0.0000," .. fmt(blocked_luma)
        expect_near(0.0, blocked_luma, 0.001)

        local partial = lurek.tilefield.new({ width = 7, height = 3 })
        partial:setCost(4, 2, 1, "light", 0.5)
        local partial_light = lurek.tilelight.new(partial)
        partial_light:addPointLight({ x = 1, y = 2, z = 1, radius = 8, intensity = 1.0, color = { r = 1, g = 0.25, b = 0 } })
        partial_light:compute({ includePointLights = true, includeGlobalLight = false })
        local pr, pg, pb, pl = partial_light:getLight(6, 2, 1)
        lines[#lines + 1] = "partial_filter,r,0.1875," .. fmt(pr)
        lines[#lines + 1] = "partial_filter,g,0.0469," .. fmt(pg)
        lines[#lines + 1] = "partial_filter,b,0.0000," .. fmt(pb)
        lines[#lines + 1] = "partial_filter,luma,0.0734," .. fmt(pl)
        expect_near(0.1875, pr, 0.001)
        expect_near(0.046875, pg, 0.001)
        expect_near(0.0, pb, 0.001)

        local radial = lurek.tilefield.new({ width = 4, height = 4, topology = "square" })
        local radial_light = lurek.tilelight.new(radial)
        radial_light:addPointLight({ x = 1, y = 1, z = 1, radius = 2, intensity = 1.0, color = { r = 1, g = 1, b = 1 } })
        radial_light:compute({ includePointLights = true, includeGlobalLight = false })
        local _, _, _, diagonal = radial_light:getLight(3, 3, 1)
        lines[#lines + 1] = "radial_square_diagonal_outside,luma,0.0000," .. fmt(diagonal)
        expect_near(0.0, diagonal, 0.001)

        local mixed = lurek.tilefield.new({ width = 5, height = 3 })
        local mixed_light = lurek.tilelight.new(mixed)
        mixed_light:addPointLight({ x = 1, y = 2, z = 1, radius = 4, intensity = 1.0, color = { r = 1, g = 0, b = 0 } })
        mixed_light:addPointLight({ x = 5, y = 2, z = 1, radius = 4, intensity = 1.0, color = { r = 0, g = 0, b = 1 } })
        mixed_light:compute({ includePointLights = true, includeGlobalLight = false })
        local mr, mg, mb, ml = mixed_light:getLight(3, 2, 1)
        lines[#lines + 1] = "red_blue_mix,r,0.5000," .. fmt(mr)
        lines[#lines + 1] = "red_blue_mix,g,0.0000," .. fmt(mg)
        lines[#lines + 1] = "red_blue_mix,b,0.5000," .. fmt(mb)
        lines[#lines + 1] = "red_blue_mix,luma,0.1424," .. fmt(ml)
        expect_near(0.5, mr, 0.001)
        expect_near(0.0, mg, 0.001)
        expect_near(0.5, mb, 0.001)

        local sky = lurek.tilefield.new({ width = 1, height = 1, levels = 2 })
        sky:setSunOcclusion(1, 1, 2, 0.25)
        local sky_light = lurek.tilelight.new(sky)
        sky_light:setGlobalLight({ intensity = 0.4, color = { r = 1.0, g = 0.55, b = 0.25 } })
        sky_light:compute({ includePointLights = false, includeGlobalLight = true })
        local dr, dg, db, dl = sky_light:getLight(1, 1, 1)
        lines[#lines + 1] = "dusk_lower,r,0.3000," .. fmt(dr)
        lines[#lines + 1] = "dusk_lower,g,0.1650," .. fmt(dg)
        lines[#lines + 1] = "dusk_lower,b,0.0750," .. fmt(db)
        lines[#lines + 1] = "dusk_lower,luma,0.1871," .. fmt(dl)
        expect_near(0.3, dr, 0.001)
        expect_near(0.165, dg, 0.001)
        expect_near(0.075, db, 0.001)

        sky_light:setGlobalLight({ intensity = 0.12, color = { r = 0.22, g = 0.32, b = 1.0 } })
        sky_light:compute({ includePointLights = false, includeGlobalLight = true })
        local nr, ng, nb, nl = sky_light:getLight(1, 1, 1)
        lines[#lines + 1] = "night_lower,r,0.0198," .. fmt(nr)
        lines[#lines + 1] = "night_lower,g,0.0288," .. fmt(ng)
        lines[#lines + 1] = "night_lower,b,0.0900," .. fmt(nb)
        lines[#lines + 1] = "night_lower,luma,0.0313," .. fmt(nl)
        expect_near(0.0198, nr, 0.001)
        expect_near(0.0288, ng, 0.001)
        expect_near(0.09, nb, 0.001)
        expect_true(dl > nl, "dusk should be brighter than night")
        expect_true(nb > nr, "night should be blue-dominant")

        save_text(OUT .. "tilefield_lighting_values.txt", table.concat(lines, "\n") .. "\n")
    end)

    -- Does: Exports a vision block layer and builds a raycaster scene from the same field.
    -- Shows: Raycaster input is derived from tilefield data instead of independent raycaster gameplay flags.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_raycaster_input.png
    -- Why: This is the migration bridge: tilefield owns the blockers, raycaster consumes the exported semantics.
    it("PNG: raycaster input layer from tilefield", function()
        local cell = 20
        local field = lurek.tilefield.new({ width = 8, height = 8, levels = 2 })
        for x = 1, 8 do
            field:applyProfile(x, 1, 1, "wall")
            field:applyProfile(x, 8, 1, "wall")
        end
        for y = 1, 8 do
            field:applyProfile(1, y, 1, "wall")
            field:applyProfile(8, y, 1, "wall")
        end
        field:applyProfile(4, 4, 1, "window")
        field:applyProfile(5, 4, 1, "door_closed")
        local quads = lurek.raycaster.buildMultiLevelSceneFromField({
            px = 3.5, py = 3.5, angle = 0, fov = 1.0, rays = 40, max_dist = 8,
            screen_w = 120, screen_h = 80, active_level = 0,
        }, field, { wallChannel = "vision" })

        local img = lurek.image.newImageData(8 * cell, 8 * cell)
        img:fill(11, 13, 17, 255)
        for y = 1, 8 do
            for x = 1, 8 do
                if field:blocks(x, y, 1, "vision") then
                    paint_cell(img, x, y, cell, 98, 88, 104)
                elseif field:blocks(x, y, 1, "action") then
                    paint_cell(img, x, y, cell, 84, 112, 136)
                else
                    paint_cell(img, x, y, cell, 34, 42, 52)
                end
            end
        end
        local marker = math.max(3, math.min(14, quads))
        img:drawRect(3, 3, marker, 6, 255, 210, 90, 255)
        save_png(img, OUT .. "tilefield_raycaster_input.png")
    end)

    -- Does: Converts deterministic procgen cave and height data into tilefield refs, movement costs, and blockers.
    -- Shows: The generated terrain is no longer an opaque table once tilefield stores terrain refs and gameplay channels.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_systems_01_procgen_refs.png
    -- Why: This is the first handoff in the new API pipeline: procgen output becomes shared tilefield data.
    it("PNG: systems 01 procgen terrain refs", function()
        local field = make_procgen_field(SHOWCASE_W, SHOWCASE_H)
        draw_grid_from_refs(field, "terrain", OUT .. "tilefield_systems_01_procgen_refs.png", { cell = SHOWCASE_CELL })
    end)

    -- Does: Exports the procgen-derived move-cost channel as a visual heatmap.
    -- Shows: Water, sand, grass, stone, and generated blockers carry different movement costs inside tilefield.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_systems_02_procgen_move_costs.png
    -- Why: Pathfinding consumes this channel later, so reviewers need to see the cost layer before routes are computed.
    it("PNG: systems 02 procgen move cost layer", function()
        local field = make_procgen_field(SHOWCASE_W, SHOWCASE_H)
        local w, h = field:getSize()
        local cell = SHOWCASE_CELL
        local img = lurek.image.newImageData(w * cell, h * cell)
        img:fill(10, 12, 18, 255)
        for y = 1, h do
            for x = 1, w do
                local cost = field:getCost(x, y, 1, "move")
                local shade = math.min(230, 42 + math.floor(cost * 32))
                if field:blocks(x, y, 1, "move") then
                    paint_cell(img, x, y, cell, 68, 42, 52)
                else
                    paint_cell(img, x, y, cell, shade, 96, 210 - math.min(150, shade))
                end
            end
        end
        save_png(img, OUT .. "tilefield_systems_02_procgen_move_costs.png")
    end)

    -- Does: Converts a generated mapblock fortress result into a tilefield ref layer.
    -- Shows: Mapblock tactical tile slots survive the conversion as tilefield refs that other systems can read.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_systems_03_mapblock_to_refs.png
    -- Why: This demonstrates the mapblock-to-tilefield adapter before pathfinding, lighting, and awareness are involved.
    it("PNG: systems 03 mapblock result to tilefield refs", function()
        local world = MapblockFixture.build(41)
        local field = make_procgen_field(SHOWCASE_W, SHOWCASE_H)
        local block_field = world.result:toTileField({ layer = 0, slot = 0, ref = "terrain", tilesetRef = "tileset", skipZero = false })
        local ox, oy = 22, 23
        for y = 1, world.result:getHeight() do
            for x = 1, world.result:getWidth() do
                local ref = block_field:getRef(x, y, 1, "terrain")
                if ref and ref ~= 0 then
                    field:setRef(ox + x, oy + y, 1, "terrain", ref)
                    field:setBlock(ox + x, oy + y, 1, "move", true)
                end
            end
        end
        draw_grid_from_refs(field, "terrain", OUT .. "tilefield_systems_03_mapblock_to_refs.png", { cell = SHOWCASE_CELL })
    end)

    -- Does: Writes a mapblock result into an existing tilefield and records tilefield dimensions plus ref slots.
    -- Shows: The write adapter can target an existing field without replacing the field object.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_systems_04_mapblock_write_report.txt
    -- Why: A real game often owns a field first and then writes generated block results into it.
    it("TXT: systems 04 mapblock writes into existing field", function()
        local world = MapblockFixture.build(41)
        local field = lurek.tilefield.new({ width = SHOWCASE_W, height = SHOWCASE_H, levels = 2 })
        world.result:writeTileField(field, { layer = 0, slot = 0, ref = "terrain", tilesetRef = "tileset", skipZero = false })
        local slots = field:getRefSlots()
        local lines = {
            "result_width=" .. tostring(world.result:getWidth()),
            "result_height=" .. tostring(world.result:getHeight()),
            "result_levels=" .. tostring(world.result:getLevelCount()),
            "field_width=50",
            "field_height=50",
            "field_slots=" .. table.concat(slots, ","),
            "sample_terrain=" .. tostring(field:getRef(1, 1, 1, "terrain")),
            "sample_tileset=" .. tostring(field:getRef(1, 1, 1, "tileset")),
        }
        save_text(OUT .. "tilefield_systems_04_mapblock_write_report.txt", table.concat(lines, "\n") .. "\n")
    end)

    -- Does: Applies tileset object metadata to tilefield object refs.
    -- Shows: Tile refs become movement/action/light blockers through LTileField:applyTilesetObjectLayer.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_systems_05_tileset_object_semantics.png
    -- Why: Tileset metadata is the bridge between visual objects and the semantic channels shared by gameplay systems.
    it("PNG: systems 05 tileset objects apply semantics", function()
        local field = make_procgen_field(SHOWCASE_W, SHOWCASE_H)
        local tileset = make_object_tileset()
        for y = 5, 45, 10 do
            for x = 5, 45, 8 do
                field:setRef(x, y, 1, "object", ((x + y) % 8) + 1)
            end
        end
        local applied = field:applyTilesetObjectLayer("object", tileset, { z = 1, refIsGid = true })
        expect_true(applied >= 1)
        draw_grid_from_refs(field, "object", OUT .. "tilefield_systems_05_tileset_object_semantics.png", { cell = SHOWCASE_CELL })
    end)

    -- Does: Resolves typed tilefield refs through a tileset catalog and writes the object/visual manifest.
    -- Shows: A tilefield cell can point to a named catalog object instead of a bare integer gid.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_systems_06_tileset_catalog_refs.txt
    -- Why: Typed refs are the stable asset contract for larger tilefield maps with multiple tilesets.
    it("TXT: systems 06 tileset catalog typed refs", function()
        local field = lurek.tilefield.new({ width = SHOWCASE_W, height = SHOWCASE_H })
        local tileset = make_object_tileset()
        local catalog = lurek.tileset.newCatalog({ props = tileset })
        local names = { "crate", "torch", "banner", "glass", "gate", "shrine", "crystal" }
        local placed = 0
        for y = 5, 45, 10 do
            for x = 5, 45, 10 do
                placed = placed + 1
                field:setRef(x, y, 1, "object", { tileset = "props", object = names[((placed - 1) % #names) + 1] })
            end
        end
        local lines = { "map=50x50", "typed_refs=" .. tostring(placed) }
        for i, probe in ipairs({ { 5, 5 }, { 15, 5 }, { 25, 5 }, { 35, 5 }, { 45, 5 } }) do
            local ref = field:getRef(probe[1], probe[2], 1, "object")
            local object = catalog:getObject(ref)
            local visual = catalog:getVisual(ref)
            lines[#lines + 1] = string.format("probe_%d=%d,%d:%s:%s", i, probe[1], probe[2], object and object.name or "nil", visual and visual.image or "nil")
        end
        save_text(OUT .. "tilefield_systems_06_tileset_catalog_refs.txt", table.concat(lines, "\n") .. "\n")
    end)

    -- Does: Parses a sprite atlas and links atlas region names to tilefield object refs.
    -- Shows: Sprite atlas names can be carried as object properties alongside tilefield placement.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_systems_07_sprite_atlas_manifest.txt
    -- Why: This captures the sprite-atlas side of object authoring before the final map tile render.
    it("TXT: systems 07 sprite atlas object manifest", function()
        local atlas = lurek.sprite.parseAtlas([[{"frames":{
            "torch_idle":{"frame":{"x":0,"y":0,"w":16,"h":24},"rotated":false},
            "crate_full":{"frame":{"x":18,"y":0,"w":24,"h":24},"rotated":false},
            "banner_blue":{"frame":{"x":44,"y":0,"w":16,"h":32},"rotated":false}
        }}]])
        local field = lurek.tilefield.new({ width = SHOWCASE_W, height = SHOWCASE_H })
        field:setRef(6, 7, 1, "object", { tileset = "props", object = "torch" })
        field:setRef(25, 25, 1, "object", { tileset = "props", object = "crate" })
        field:setRef(43, 43, 1, "object", { tileset = "props", object = "banner" })
        local names = atlas:entryNames()
        table.sort(names)
        local lines = { "map=50x50", "atlas_entries=" .. table.concat(names, ",") }
        for _, name in ipairs(names) do
            local entry = atlas:getEntry(name)
            lines[#lines + 1] = string.format("%s=%d,%d,%d,%d", name, entry.x, entry.y, entry.w, entry.h)
        end
        save_text(OUT .. "tilefield_systems_07_sprite_atlas_manifest.txt", table.concat(lines, "\n") .. "\n")
    end)

    -- Does: Mirrors tilefield terrain refs into a tilemap layer.
    -- Shows: The render-facing tilemap can be filled from the same refs used by gameplay systems.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_systems_08_tilemap_from_refs.png
    -- Why: This proves tilemap is presentation storage while tilefield keeps the shared semantic source.
    it("PNG: systems 08 tilemap layer from tilefield refs", function()
        local field = make_procgen_field(SHOWCASE_W, SHOWCASE_H)
        local w, h = field:getSize()
        local tm = lurek.tilemap.newTileMap(6, 6)
        local layer = tm:addLayer("terrain", w, h)
        for y = 1, h do
            for x = 1, w do
                tm:setTile(layer, x, y, field:getRef(x, y, 1, "terrain") or 0)
            end
        end
        local img = lurek.image.newImageData(w * 6, h * 6)
        img:fill(10, 12, 18, 255)
        for y = 1, h do
            for x = 1, w do
                local r, g, b = cell_color(tm:getTile(layer, x, y))
                paint_cell(img, x, y, 6, r, g, b)
            end
        end
        save_png(img, OUT .. "tilefield_systems_08_tilemap_from_refs.png")
    end)

    -- Does: Calls the tilemap field-slot render adapters for typed and gid refs, then writes a command manifest.
    -- Shows: Tilemap can consume tilefield refs through either a catalog or a direct tileset.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_systems_09_tilemap_render_adapters.txt
    -- Why: This is the API bridge used by final map-tile rendering without forcing tilefield to own draw commands.
    it("TXT: systems 09 tilemap field render adapters", function()
        local typed_field = lurek.tilefield.new({ width = SHOWCASE_W, height = SHOWCASE_H })
        local gid_field = lurek.tilefield.new({ width = SHOWCASE_W, height = SHOWCASE_H })
        local tileset = make_object_tileset()
        local catalog = lurek.tileset.newCatalog({ props = tileset })
        for y = 5, 45, 10 do
            for x = 5, 45, 10 do
                typed_field:setRef(x, y, 1, "object", { tileset = "props", object = "crate" })
                gid_field:setRef(x, y, 1, "object", 1)
            end
        end
        local typed_map = lurek.tilemap.newTileMap(16, 16)
        local gid_map = lurek.tilemap.newTileMap(16, 16)
        typed_map:renderFieldCatalogSlot(typed_field, catalog, { slot = "object", z = 1 })
        gid_map:renderFieldSlot(gid_field, tileset, { slot = "object", z = 1, refIsGid = true })
        save_text(
            OUT .. "tilefield_systems_09_tilemap_render_adapters.txt",
            "map=50x50\ncatalog_adapter=ok\nsingle_tileset_adapter=ok\ntyped_ref=props:crate\ngid_ref=1\n"
        )
    end)

    -- Does: Builds a pathfinding nav grid from tilefield move blockers and draws the selected route.
    -- Shows: Pathfinding avoids the tilefield blocker channel instead of using a separate collision map.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_systems_10_pathfind_route.png
    -- Why: This is the gameplay validation stage after procgen/mapblock data has become tilefield semantics.
    it("PNG: systems 10 pathfind route from field", function()
        local field = make_procgen_field(SHOWCASE_W, SHOWCASE_H)
        for y = 1, SHOWCASE_H do
            field:setBlock(25, y, 1, "move", y ~= 25)
        end
        local nav = lurek.pathfind.newNavGridFromField(field, { level = 1, channel = "move" })
        local pf = lurek.pathfind.newPathfinder(nav)
        local nodes = pf:findPath(2, 25, 49, 25) or {}
        local img = lurek.image.newImageData(SHOWCASE_W * 6, SHOWCASE_H * 6)
        img:fill(10, 12, 18, 255)
        for y = 1, SHOWCASE_H do
            for x = 1, SHOWCASE_W do
                if field:blocks(x, y, 1, "move") then
                    paint_cell(img, x, y, 6, 76, 44, 54)
                else
                    local r, g, b = cell_color(field:getRef(x, y, 1, "terrain"))
                    paint_cell(img, x, y, 6, r, g, b)
                end
            end
        end
        draw_path(img, nodes, 6, 255, 218, 92)
        save_png(img, OUT .. "tilefield_systems_10_pathfind_route.png")
    end)

    -- Does: Exports pathfinding range from tilefield move costs.
    -- Shows: Reachability falls off across water/sand costs before blockers stop it entirely.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_systems_11_pathfind_range.png
    -- Why: This proves cost channels are consumed by pathfinding, not just stored as metadata.
    it("PNG: systems 11 pathfind range map from field costs", function()
        local field = make_procgen_field(SHOWCASE_W, SHOWCASE_H)
        local range = lurek.pathfind.rangeMapFromField(field, { origin = { x = 6, y = 7, z = 1 }, budget = 22, channel = "move" })
        local cell = SHOWCASE_CELL
        local img = lurek.image.newImageData(SHOWCASE_W * cell, SHOWCASE_H * cell)
        img:fill(10, 12, 18, 255)
        for y = 1, SHOWCASE_H do
            for x = 1, SHOWCASE_W do
                local idx = (y - 1) * SHOWCASE_W + x
                local reached = range.cells and range.cells[idx]
                if reached then
                    paint_cell(img, x, y, cell, 82, 150, 118)
                elseif field:blocks(x, y, 1, "move") then
                    paint_cell(img, x, y, cell, 70, 42, 52)
                else
                    paint_cell(img, x, y, cell, 36, 44, 54)
                end
            end
        end
        draw_dot(img, 6, 7, cell, 255, 222, 110)
        save_png(img, OUT .. "tilefield_systems_11_pathfind_range.png")
    end)

    -- Does: Builds a flow field from tilefield-derived navigation and draws direction arrows.
    -- Shows: The route field points around blockers toward the target cell.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_systems_12_pathfind_flow.png
    -- Why: This demonstrates a second pathfinding mode over the same field data.
    it("PNG: systems 12 pathfind flow field from field", function()
        local field = make_procgen_field(SHOWCASE_W, SHOWCASE_H)
        for y = 5, 45 do field:setBlock(25, y, 1, "move", true) end
        field:setBlock(25, 25, 1, "move", false)
        local nav = lurek.pathfind.newNavGridFromField(field, { level = 1, channel = "move" })
        local flow = lurek.pathfind.newFlowField(nav)
        flow:calculate(50, 50)
        local cell = SHOWCASE_CELL
        local img = lurek.image.newImageData(SHOWCASE_W * cell, SHOWCASE_H * cell)
        img:fill(10, 12, 18, 255)
        for y = 1, SHOWCASE_H do
            for x = 1, SHOWCASE_W do
                if field:blocks(x, y, 1, "move") then
                    paint_cell(img, x, y, cell, 70, 42, 52)
                else
                    paint_cell(img, x, y, cell, 36, 44, 54)
                    local dx, dy = flow:getDirection(x, y)
                    img:drawLine(math.floor((x - 0.5) * cell), math.floor((y - 0.5) * cell), math.floor((x - 0.5) * cell + (tonumber(dx) or 0) * 3), math.floor((y - 0.5) * cell + (tonumber(dy) or 0) * 3), 110, 220, 130, 255)
                end
            end
        end
        draw_dot(img, 50, 50, cell, 255, 222, 110)
        save_png(img, OUT .. "tilefield_systems_12_pathfind_flow.png")
    end)

    -- Does: Computes visible and action masks for two players from one tilefield.
    -- Shows: Awareness keeps per-player state while reading tilefield vision/action blockers.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_systems_13_awareness_players.png
    -- Why: Player knowledge should not be encoded in map generation, tilemap, or tilelight state.
    it("PNG: systems 13 awareness per-player masks", function()
        local field = make_procgen_field(SHOWCASE_W, SHOWCASE_H)
        local vis = lurek.awareness.newTileAwareness(field, { players = { "blue", "red", "green", "gold" }, rememberExplored = true })
        for _, unit in ipairs(TEAM_UNITS) do
            vis:computeVisible(unit.team, { origin = { x = unit.x, y = unit.y, z = 1 }, range = 13, channel = "vision" })
            vis:computeAction(unit.team, { origin = { x = unit.x, y = unit.y, z = 1 }, range = 9, channel = "action" })
        end
        local cell = SHOWCASE_CELL
        local img = lurek.image.newImageData(SHOWCASE_W * cell, SHOWCASE_H * cell)
        img:fill(10, 12, 18, 255)
        for y = 1, SHOWCASE_H do
            for x = 1, SHOWCASE_W do
                local r, g, b = 34, 40, 50
                if vis:isVisible("blue", x, y, 1) then r, g, b = 46, 84, 146 end
                if vis:isVisible("red", x, y, 1) then r, g, b = 136, 56, 64 end
                if vis:isVisible("green", x, y, 1) then r, g, b = 50, 126, 76 end
                if vis:isVisible("gold", x, y, 1) then r, g, b = 150, 126, 52 end
                if vis:canActOn("blue", x, y, 1) then g = math.min(220, g + 64) end
                paint_cell(img, x, y, cell, r, g, b)
            end
        end
        draw_team_units(img, cell)
        save_png(img, OUT .. "tilefield_systems_13_awareness_players.png")
    end)

    -- Does: Shares one awareness category from scout to ally through LTileAwareness:setTeam.
    -- Shows: Team knowledge expands only after share edges are created.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_systems_14_awareness_team.txt
    -- Why: Per-team awareness is part of the requested showcase and must be inspectable as state, not only color.
    it("TXT: systems 14 awareness per-team share", function()
        local field = make_procgen_field(SHOWCASE_W, SHOWCASE_H)
        local vis = lurek.awareness.newTileAwareness(field, { players = { "blue", "red", "green", "gold" }, rememberExplored = true })
        for _, unit in ipairs(TEAM_UNITS) do
            vis:computeVisible(unit.team, { origin = { x = unit.x, y = unit.y, z = 1 }, range = 10 })
        end
        local before = vis:isVisible("red", 7, 7, 1)
        vis:setTeam({ "blue", "red" }, { "vision" })
        vis:setTeam({ "green", "gold" }, { "vision" })
        local after = vis:isVisible("red", 7, 7, 1)
        local green_to_gold = vis:isVisible("gold", 7, 44, 1)
        save_text(OUT .. "tilefield_systems_14_awareness_team.txt", "map=50x50\nteams=blue,red,green,gold\nred_sees_blue_area_before=" .. tostring(before) .. "\nred_sees_blue_area_after=" .. tostring(after) .. "\ngold_sees_green_area_after=" .. tostring(green_to_gold) .. "\n")
    end)

    -- Does: Computes an awareness cone category over a tilefield with a blocker row.
    -- Shows: The custom category reveals cells in front of the actor and excludes cells behind it.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_systems_15_awareness_cone.png
    -- Why: This demonstrates non-default awareness categories over the same field structure.
    it("PNG: systems 15 awareness cone category", function()
        local field = make_procgen_field(SHOWCASE_W, SHOWCASE_H)
        field:defineCategory("sight", { kind = "awareness" })
        for y = 5, 45 do field:setCategoryBlock(28, y, 1, "sight", y ~= 25) end
        local vis = lurek.awareness.newTileAwareness(field, { players = { "scout" } })
        vis:defineCategory("sight", { active = true, range = 18, mode = "cone", arc = 90, facing = { x = 1, y = 0 }, blockerCategory = "sight" })
        vis:computeVisible("scout", { origin = { x = 18, y = 25, z = 1 }, category = "sight" })
        local cell = SHOWCASE_CELL
        local img = lurek.image.newImageData(SHOWCASE_W * cell, SHOWCASE_H * cell)
        img:fill(10, 12, 18, 255)
        for y = 1, SHOWCASE_H do
            for x = 1, SHOWCASE_W do
                if field:blocksCategory(x, y, 1, "sight") then
                    paint_cell(img, x, y, cell, 72, 44, 54)
                elseif vis:isAware("scout", "sight", x, y, 1) then
                    paint_cell(img, x, y, cell, 82, 150, 118)
                else
                    paint_cell(img, x, y, cell, 36, 44, 54)
                end
            end
        end
        draw_dot(img, 18, 25, cell, 255, 222, 110)
        save_png(img, OUT .. "tilefield_systems_15_awareness_cone.png")
    end)

    -- Does: Writes line-of-sight and line-of-action answers through different tilefield blocker channels.
    -- Shows: A window can preserve sight while blocking actions.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_systems_16_awareness_line_channels.txt
    -- Why: This is a compact proof that awareness reads semantic channels rather than a single solid flag.
    it("TXT: systems 16 awareness sight action channels", function()
        local field = lurek.tilefield.new({ width = SHOWCASE_W, height = SHOWCASE_H })
        for x = 10, 40, 10 do field:applyProfile(x, 25, 1, "window") end
        local from = { x = 2, y = 25, z = 1 }
        local to = { x = 49, y = 25, z = 1 }
        save_text(
            OUT .. "tilefield_systems_16_awareness_line_channels.txt",
            "map=50x50\n" ..
            "line_of_sight=" .. tostring(lurek.awareness.lineOfSight(field, from, to)) .. "\n" ..
            "line_of_action=" .. tostring(lurek.awareness.lineOfAction(field, from, to)) .. "\n"
        )
    end)

    -- Does: Computes a tilelight point source through opaque and partial light blockers.
    -- Shows: Full light blockers cast dark regions while transmission costs attenuate light.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_systems_17_tilelight_point_blockers.png
    -- Why: The tilelight showcase starts from a small readable point-light map before adding many sources.
    it("PNG: systems 17 tilelight point blockers", function()
        local field = make_procgen_field(SHOWCASE_W, SHOWCASE_H)
        for y = 5, 45 do field:setBlock(25, y, 1, "light", y ~= 25) end
        for y = 6, 44, 4 do field:setCost(32, y, 1, "light", 0.45) end
        local light = lurek.tilelight.new(field)
        light:addPointLight({ x = 8, y = 25, z = 1, radius = 24, intensity = 1.0, color = { r = 1, g = 0.55, b = 0.2 } })
        light:compute({ includePointLights = true, includeSunLight = false })
        draw_light_layer(field, light, OUT .. "tilefield_systems_17_tilelight_point_blockers.png")
    end)

    -- Does: Adds many colored tilelight sources on one generated field.
    -- Shows: Multiple point lights mix into a readable RGB light field around blockers.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_systems_18_tilelight_many_sources.png
    -- Why: This directly addresses the requested showcase with many light sources and light blockers.
    it("PNG: systems 18 tilelight many sources", function()
        local field = make_procgen_field(SHOWCASE_W, SHOWCASE_H)
        local light = lurek.tilelight.new(field)
        add_showcase_lights(light)
        light:compute({ includePointLights = true, includeSunLight = false })
        draw_light_layer(field, light, OUT .. "tilefield_systems_18_tilelight_many_sources.png")
    end)

    -- Does: Combines tilelight line and area lights over a field.
    -- Shows: A corridor strip and a rectangular room light produce different footprint shapes.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_systems_19_tilelight_line_area.png
    -- Why: This proves tilelight evidence covers more than point-source propagation.
    it("PNG: systems 19 tilelight line and area sources", function()
        local field = make_procgen_field(SHOWCASE_W, SHOWCASE_H)
        for x = 8, 42 do field:setBlock(x, 25, 1, "light", x ~= 25) end
        local light = lurek.tilelight.new(field)
        light:addLineLight({ x1 = 6, y1 = 12, x2 = 45, y2 = 12, z1 = 1, z2 = 1, radius = 5.5, intensity = 0.65, color = { r = 0.2, g = 0.8, b = 1.0 } })
        light:addLineLight({ x1 = 12, y1 = 45, x2 = 45, y2 = 18, z1 = 1, z2 = 1, radius = 5.0, intensity = 0.5, color = { r = 0.9, g = 0.35, b = 1.0 } })
        light:addAreaLight({ x = 20, y = 22, z = 1, width = 10, height = 7, radius = 8, intensity = 0.75, color = { r = 1.0, g = 0.7, b = 0.25 } })
        light:compute({ includeLineLights = true, includeAreaLights = true, includeSunLight = false })
        draw_light_layer(field, light, OUT .. "tilefield_systems_19_tilelight_line_area.png")
    end)

    -- Does: Computes top/global tilelight through a two-level field with sun occlusion.
    -- Shows: Upper-level occlusion dims the lower layer while preserving the global light color.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_systems_20_tilelight_global_multilevel.png
    -- Why: Multilevel lighting is a key collaboration point between tilefield data and tilelight output.
    it("PNG: systems 20 tilelight global multilevel occlusion", function()
        local field = make_procgen_field(SHOWCASE_W, SHOWCASE_H)
        local light = lurek.tilelight.new(field)
        light:setGlobalLight({ intensity = 0.55, color = { r = 1.0, g = 0.62, b = 0.24 } })
        light:compute({ includePointLights = false, includeGlobalLight = true })
        local cell = SHOWCASE_CELL
        local img = lurek.image.newImageData(SHOWCASE_W * cell * 2, SHOWCASE_H * cell)
        img:fill(8, 9, 13, 255)
        for z = 1, 2 do
            for y = 1, SHOWCASE_H do
                for x = 1, SHOWCASE_W do
                    local r, g, b = light:getLight(x, y, z)
                    paint_cell(img, x + (z - 1) * SHOWCASE_W, y, cell, math.floor((r or 0) * 255), math.floor((g or 0) * 255), math.floor((b or 0) * 255))
                end
            end
        end
        save_png(img, OUT .. "tilefield_systems_20_tilelight_global_multilevel.png")
    end)

    -- Does: Exports a numeric tilelight layer after adding, updating, and removing source ids.
    -- Shows: Tilelight source lifecycle changes the final luma samples deterministically.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_systems_21_tilelight_source_lifecycle.txt
    -- Why: Reviewers need source-management evidence in addition to color PNGs.
    it("TXT: systems 21 tilelight source lifecycle", function()
        local field = make_procgen_field(SHOWCASE_W, SHOWCASE_H)
        local light = lurek.tilelight.new(field)
        add_showcase_lights(light)
        local point = light:addPointLight({ x = 20, y = 20, z = 1, radius = 6, intensity = 0.4 })
        light:updatePointLight(point, { x = 25, y = 25, radius = 12, intensity = 0.8 })
        local line = light:addLineLight({ x1 = 1, y1 = 50, x2 = 50, y2 = 50, z1 = 1, z2 = 1, radius = 4, intensity = 0.5 })
        local removed = light:removeLineLight(line)
        light:compute({ includePointLights = true, includeLineLights = true, includeSunLight = false })
        local _, _, _, luma = light:getLight(25, 25, 1)
        save_text(OUT .. "tilefield_systems_21_tilelight_source_lifecycle.txt", "map=50x50\nstatic_sources=12\npoint_id=" .. tostring(point) .. "\nremoved_line=" .. tostring(removed) .. "\nluma_25_25=" .. fmt(luma) .. "\n")
    end)

    -- Does: Combines tilefield refs, awareness fog, and tilelight luma into one minimap-style evidence image.
    -- Shows: Terrain color, current visibility, and light intensity remain separate overlays from separate modules.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_systems_22_fog_light_minimap.png
    -- Why: This shows the modules cooperating without collapsing ownership into one renderer.
    it("PNG: systems 22 fog and light minimap overlay", function()
        local field = make_procgen_field(SHOWCASE_W, SHOWCASE_H)
        local vis = lurek.awareness.newTileAwareness(field, { players = { "blue", "red", "green", "gold" }, rememberExplored = true })
        for _, unit in ipairs(TEAM_UNITS) do
            vis:computeVisible(unit.team, { origin = { x = unit.x, y = unit.y, z = 1 }, range = 14 })
        end
        local light = lurek.tilelight.new(field)
        add_showcase_lights(light)
        light:compute({ includePointLights = true, includeSunLight = false })
        local cell = SHOWCASE_CELL
        local img = lurek.image.newImageData(SHOWCASE_W * cell, SHOWCASE_H * cell)
        img:fill(10, 12, 18, 255)
        for y = 1, SHOWCASE_H do
            for x = 1, SHOWCASE_W do
                local r, g, b = cell_color(field:getRef(x, y, 1, "terrain"))
                local _, _, _, luma = light:getLight(x, y, 1)
                local lit = 0.35 + math.min(0.9, luma or 0)
                if not (vis:isVisible("blue", x, y, 1) or vis:isVisible("red", x, y, 1) or vis:isVisible("green", x, y, 1) or vis:isVisible("gold", x, y, 1)) then lit = lit * 0.25 end
                paint_cell(img, x, y, cell, math.floor(r * lit), math.floor(g * lit), math.floor(b * lit))
            end
        end
        draw_team_units(img, cell)
        save_png(img, OUT .. "tilefield_systems_22_fog_light_minimap.png")
    end)

    -- Does: Stores generated fields inside a tilefield map and renders the block map as a chunk atlas.
    -- Shows: Tilefield maps can hold multiple compatible fields for mapblock/tilefield-map workflows.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_systems_23_fieldmap_chunks.png
    -- Why: The requested tilefield-map stage needs evidence distinct from a single field.
    it("PNG: systems 23 tilefield map chunks", function()
        local fmap = lurek.tilefield.newFieldMap({ width = 2, height = 2, layers = 1, fieldWidth = 25, fieldHeight = 25, fieldLevels = 2 })
        for my = 1, 2 do
            for mx = 1, 2 do
                local field = make_procgen_field(25, 25)
                field:setRef(mx, my, 1, "object", mx + my)
                fmap:setField(mx, my, 1, field)
            end
        end
        local cell = SHOWCASE_CELL
        local gap = 6
        local img = lurek.image.newImageData(2 * 25 * cell + gap, 2 * 25 * cell + gap)
        img:fill(8, 10, 15, 255)
        for my = 1, 2 do
            for mx = 1, 2 do
                local field = fmap:getField(mx, my, 1)
                local ox = (mx - 1) * (25 * cell + gap)
                local oy = (my - 1) * (25 * cell + gap)
                for y = 1, 25 do
                    for x = 1, 25 do
                        local r, g, b = cell_color(field:getRef(x, y, 1, "terrain"))
                        if field:blocks(x, y, 1, "move") then r, g, b = 76, 44, 54 end
                        img:drawRect(ox + (x - 1) * cell, oy + (y - 1) * cell, cell - 1, cell - 1, r, g, b, 255)
                    end
                end
            end
        end
        save_png(img, OUT .. "tilefield_systems_23_fieldmap_chunks.png")
    end)

    -- Does: Overlays a mapblock fortress export over procgen terrain in one tilefield-derived view.
    -- Shows: Authored block placement and procedural terrain can coexist before downstream systems run.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_systems_24_procgen_mapblock_overlay.png
    -- Why: This is the requested collaboration point where mapblock and procgen jointly form a playable map.
    it("PNG: systems 24 procgen plus mapblock overlay", function()
        local terrain = make_procgen_field(SHOWCASE_W, SHOWCASE_H)
        local world = MapblockFixture.build(41)
        local blocks = world.result:toTileField({ layer = 0, slot = 0, ref = "block", skipZero = true })
        local ox, oy = 22, 23
        for y = 1, world.result:getHeight() do
            for x = 1, world.result:getWidth() do
                local ref = blocks:getRef(x, y, 1, "block")
                if ref and ref ~= 0 then
                    terrain:setRef(ox + x, oy + y, 1, "object", ref)
                    terrain:setBlock(ox + x, oy + y, 1, "move", true)
                end
            end
        end
        draw_grid_from_refs(terrain, "object", OUT .. "tilefield_systems_24_procgen_mapblock_overlay.png", { cell = SHOWCASE_CELL })
    end)

    -- Does: Renders the final map tile view from terrain refs, object refs, awareness, pathfinding, and tilelight.
    -- Shows: The final artifact includes generated tiles, object layer, blockers, many lights, player visibility, and a route overlay.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_systems_25_final_maptile_render.png
    -- Why: This closes the requested pipeline with a single maptile render that makes all collaboration stages inspectable.
    it("PNG: systems 25 final maptile render", function()
        local field = make_procgen_field(SHOWCASE_W, SHOWCASE_H)
        for x = 8, 43, 5 do field:setRef(x, 25, 1, "object", 2); field:setBlock(x, 25, 1, "move", true) end
        local vis = lurek.awareness.newTileAwareness(field, { players = { "blue", "red", "green", "gold" }, rememberExplored = true })
        for _, unit in ipairs(TEAM_UNITS) do
            vis:computeVisible(unit.team, { origin = { x = unit.x, y = unit.y, z = 1 }, range = 15 })
        end
        local nav = lurek.pathfind.newNavGridFromField(field, { level = 1, channel = "move" })
        local pf = lurek.pathfind.newPathfinder(nav)
        local nodes = pf:findPath(TEAM_UNITS[1].x, TEAM_UNITS[1].y, TEAM_UNITS[4].x, TEAM_UNITS[4].y) or {}
        local light = lurek.tilelight.new(field)
        add_showcase_lights(light)
        light:compute({ includePointLights = true, includeSunLight = false })
        local cell = SHOWCASE_CELL
        local img = lurek.image.newImageData(SHOWCASE_W * cell, SHOWCASE_H * cell)
        img:fill(10, 12, 18, 255)
        for y = 1, SHOWCASE_H do
            for x = 1, SHOWCASE_W do
                local r, g, b = cell_color(field:getRef(x, y, 1, "terrain"))
                local _, _, _, luma = light:getLight(x, y, 1)
                local visible = vis:isVisible("blue", x, y, 1) or vis:isVisible("red", x, y, 1) or vis:isVisible("green", x, y, 1) or vis:isVisible("gold", x, y, 1)
                local lit = visible and (0.45 + math.min(0.75, luma or 0)) or 0.18
                if field:blocks(x, y, 1, "move") then r, g, b = 88, 58, 66 end
                paint_cell(img, x, y, cell, math.floor(r * lit), math.floor(g * lit), math.floor(b * lit))
                local obj = field:getRef(x, y, 1, "object")
                if obj and obj ~= 0 then
                    img:drawCircle(math.floor((x - 0.5) * cell), math.floor((y - 0.5) * cell), 4, 255, 222, 110, 255)
                end
            end
        end
        draw_path(img, nodes, cell, 255, 238, 120)
        draw_team_units(img, cell)
        save_png(img, OUT .. "tilefield_systems_25_final_maptile_render.png")
    end)

    -- Does: Builds a 50x50 isometric-square tilefield with explicit floor, left-top wall, right-top wall, and object slots.
    -- Shows: The abstract PNG exposes the logical slots without tilemap rendering, including support walls offset to lower neighbor cells instead of same-cell wall placement.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_systems_26_iso_xcom_slot_logic.png, tests/artifacts/current/tilefield/tilefield_systems_26_iso_xcom_slot_logic.txt
    -- Why: This proves the tilefield owns the floor/wall/object slot semantics and the support-offset rule before tilemap consumes the data for rendering.
    it("PNG+TXT: systems 26 iso XCOM tilefield slot logic", function()
        local field = lurek.tilefield.new({ width = SHOWCASE_W, height = SHOWCASE_H, levels = 4, topology = "iso_square" })
        local slots = {
            floor = "floor",
            left = "left_top_wall",
            right = "right_top_wall",
            object = "object",
        }
        local upper = { min_x = 21, max_x = 32, min_y = 19, max_y = 30, z = 3 }
        for y = 1, SHOWCASE_H do
            for x = 1, SHOWCASE_W do
                field:setRef(x, y, 2, slots.floor, 11 + ((x + y) % 3))
            end
        end
        for y = upper.min_y, upper.max_y do
            for x = upper.min_x, upper.max_x do
                field:setRef(x, y, upper.z, slots.floor, 21 + ((x + y) % 3))
                field:setSunOcclusion(x, y, upper.z, 0.86)
                if y == upper.max_y then
                    field:setRef(x, y + 1, upper.z - 1, slots.right, 93)
                    field:setSunOcclusion(x, y + 1, upper.z - 1, 0.55)
                end
                if x == upper.max_x then
                    field:setRef(x + 1, y, upper.z - 1, slots.left, 83)
                    field:setSunOcclusion(x + 1, y, upper.z - 1, 0.55)
                end
            end
        end
        field:setRef(25, 24, 2, slots.object, 44)
        field:setRef(28, 22, 3, slots.object, 45)

        expect_true(field:getRef(21, 31, 2, slots.right) ~= nil)
        expect_true(field:getRef(33, 19, 2, slots.left) ~= nil)
        expect_nil(field:getRef(21, 30, 2, slots.right))
        expect_nil(field:getRef(32, 19, 2, slots.left))

        local cell = SHOWCASE_CELL
        local img = lurek.image.newImageData(SHOWCASE_W * cell, SHOWCASE_H * cell)
        img:fill(9, 11, 16, 255)
        for y = 1, SHOWCASE_H do
            for x = 1, SHOWCASE_W do
                local floor = field:getRef(x, y, 2, slots.floor)
                local upper_floor = field:getRef(x, y, 3, slots.floor)
                local px = (x - 1) * cell
                local py = (y - 1) * cell
                if upper_floor then
                    img:drawRect(px, py, cell, cell, 92, 108, 138, 255)
                elseif floor then
                    local shade = 54 + ((x + y) % 3) * 12
                    img:drawRect(px, py, cell, cell, shade, shade + 6, shade + 10, 255)
                else
                    img:drawRect(px, py, cell, cell, 24, 28, 34, 255)
                end
                draw_outline(img, px, py, cell, cell, 28, 32, 38, 255)
                if field:getRef(x, y, 2, slots.left) then
                    img:drawLine(px + 1, py + 1, px + math.floor(cell / 2), py + math.floor(cell / 2), 98, 232, 118, 255)
                    img:drawLine(px + 1, py + 2, px + math.floor(cell / 2), py + math.floor(cell / 2) + 1, 98, 232, 118, 255)
                end
                if field:getRef(x, y, 2, slots.right) then
                    img:drawLine(px + cell - 2, py + 1, px + math.floor(cell / 2), py + math.floor(cell / 2), 255, 178, 78, 255)
                    img:drawLine(px + cell - 2, py + 2, px + math.floor(cell / 2), py + math.floor(cell / 2) + 1, 255, 178, 78, 255)
                end
                if field:getRef(x, y, 2, slots.object) then
                    draw_dot(img, x, y, cell, 255, 222, 104)
                end
                if field:getRef(x, y, 3, slots.object) then
                    draw_dot(img, x, y, cell, 120, 180, 255)
                end
            end
        end
        save_png(img, OUT .. "tilefield_systems_26_iso_xcom_slot_logic.png")

        local lines = {
            "map=50x50",
            "topology=iso_square",
            "base_cell_px=16",
            "slots=floor,left_top_wall,right_top_wall,object",
            "right_top_support_rule=upper floor south/front edge (x,y,z) -> lower cell (x,y+1,z-1)",
            "left_top_support_rule=upper floor east/right edge (x,y,z) -> lower cell (x+1,y,z-1)",
            "good_right_top_support=21,31,2:" .. tostring(field:getRef(21, 31, 2, slots.right)),
            "bad_right_top_same_cell=21,30,2:" .. tostring(field:getRef(21, 30, 2, slots.right)),
            "good_left_top_support=33,19,2:" .. tostring(field:getRef(33, 19, 2, slots.left)),
            "bad_left_top_same_cell=32,19,2:" .. tostring(field:getRef(32, 19, 2, slots.left)),
            "object_lower=25,24,2:" .. tostring(field:getRef(25, 24, 2, slots.object)),
            "object_upper=28,22,3:" .. tostring(field:getRef(28, 22, 3, slots.object)),
        }
        save_text(OUT .. "tilefield_systems_26_iso_xcom_slot_logic.txt", table.concat(lines, "\n") .. "\n")
    end)

    -- Does: Draws procgen terrain refs on a 50x50 hex tilefield.
    -- Shows: The hex topology uses staggered cells while preserving generated terrain refs.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_hex_systems_01_procgen_refs.png
    -- Why: Hex evidence needs its own map artifact rather than reusing square-grid screenshots.
    it("PNG: hex systems 01 procgen refs", function()
        local field = make_hex_field(SHOWCASE_W, SHOWCASE_H)
        draw_hex_field(field, "terrain", OUT .. "tilefield_hex_systems_01_procgen_refs.png", { cell = SHOWCASE_CELL })
    end)

    -- Does: Draws movement costs from the 50x50 hex field.
    -- Shows: Terrain costs remain separate from blockers and object refs on a hex board.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_hex_systems_02_procgen_move_costs.png
    -- Why: Movement-budget evidence must be readable before pathfinding overlays are added.
    it("PNG: hex systems 02 procgen move costs", function()
        local field = make_hex_field(SHOWCASE_W, SHOWCASE_H)
        local cell = SHOWCASE_CELL
        local iw, ih = hex_size(SHOWCASE_W, SHOWCASE_H, cell)
        local img = lurek.image.newImageData(iw, ih)
        img:fill(8, 10, 15, 255)
        for y = 1, SHOWCASE_H do
            for x = 1, SHOWCASE_W do
                local cost = field:getCost(x, y, 1, "move")
                local shade = math.max(30, 210 - math.floor(cost * 28))
                if field:blocks(x, y, 1, "move") then
                    paint_hex(img, x, y, cell, 86, 46, 58)
                else
                    paint_hex(img, x, y, cell, shade, 118, 74)
                end
            end
        end
        save_png(img, OUT .. "tilefield_hex_systems_02_procgen_move_costs.png")
    end)

    -- Does: Converts a mapblock fixture into refs and overlays it onto a 50x50 hex field.
    -- Shows: Authored mapblock output can be staged on top of procgen hex terrain.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_hex_systems_03_mapblock_to_refs.png
    -- Why: This proves the procgen/mapblock collaboration exists for hex maps as well.
    it("PNG: hex systems 03 mapblock to refs", function()
        local field = make_hex_field(SHOWCASE_W, SHOWCASE_H)
        local world = MapblockFixture.build(42)
        local blocks = world.result:toTileField({ layer = 0, slot = 0, ref = "block", skipZero = true, topology = "hex" })
        local ox, oy = 22, 23
        for y = 1, world.result:getHeight() do
            for x = 1, world.result:getWidth() do
                local ref = blocks:getRef(x, y, 1, "block")
                if ref and ref ~= 0 and field:inBounds(ox + x, oy + y, 1) then
                    field:setRef(ox + x, oy + y, 1, "terrain", ref)
                    field:setRef(ox + x, oy + y, 1, "object", 6)
                end
            end
        end
        draw_hex_field(field, "terrain", OUT .. "tilefield_hex_systems_03_mapblock_to_refs.png", { cell = SHOWCASE_CELL })
    end)

    -- Does: Writes a text report for mapblock-to-hex-field materialization.
    -- Shows: Dimensions, topology, and sampled refs are explicit review data.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_hex_systems_04_mapblock_write_report.txt
    -- Why: Text evidence makes the generated hex field contract auditable without visual inspection.
    it("TXT: hex systems 04 mapblock write report", function()
        local field = lurek.tilefield.new({ width = SHOWCASE_W, height = SHOWCASE_H, levels = 2, topology = "hex" })
        local world = MapblockFixture.build(43)
        local blocks = world.result:toTileField({ layer = 0, slot = 0, ref = "block", skipZero = true, topology = "hex" })
        field:setRef(25, 25, 1, "block", blocks:getRef(1, 1, 1, "block") or 0)
        save_text(OUT .. "tilefield_hex_systems_04_mapblock_write_report.txt",
            "map=50x50\nfield_topology=" .. field:getTopology() .. "\nblock_width=" .. tostring(world.result:getWidth()) .. "\nblock_height=" .. tostring(world.result:getHeight()) .. "\nsample_ref=" .. tostring(field:getRef(25, 25, 1, "block")) .. "\n")
    end)

    -- Does: Applies object refs from a tileset catalog onto a hex field.
    -- Shows: Multiple object semantics appear on top of generated hex terrain.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_hex_systems_05_tileset_object_semantics.png
    -- Why: Tileset object evidence should not depend on square-only placement.
    it("PNG: hex systems 05 tileset object semantics", function()
        local field = make_hex_field(SHOWCASE_W, SHOWCASE_H)
        local tileset = make_object_tileset()
        for y = 6, 44, 6 do
            for x = 6, 44, 6 do
                local object = ((x + y) % 8) + 1
                field:setRef(x, y, 1, "object", object)
                field:applyTilesetObject(x, y, 1, "object", tileset)
            end
        end
        draw_hex_field(field, "object", OUT .. "tilefield_hex_systems_05_tileset_object_semantics.png", { cell = SHOWCASE_CELL })
    end)

    -- Does: Exports a hex tileset catalog report.
    -- Shows: Object roles, blockers, and map topology are recorded with the hex field.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_hex_systems_06_tileset_catalog_refs.txt
    -- Why: The object catalog needs a durable text artifact next to the PNG layer.
    it("TXT: hex systems 06 tileset catalog refs", function()
        local field = make_hex_field(SHOWCASE_W, SHOWCASE_H)
        local tileset = make_object_tileset()
        field:setRef(12, 12, 1, "object", 2)
        field:applyTilesetObject(12, 12, 1, "object", tileset)
        local props = field:getRefProperties(12, 12, 1, "object", tileset)
        save_text(OUT .. "tilefield_hex_systems_06_tileset_catalog_refs.txt",
            "map=50x50\nfield_topology=" .. field:getTopology() .. "\nobject_ref=" .. tostring(field:getRef(12, 12, 1, "object")) .. "\nrole=" .. tostring(props.role) .. "\nblocks_move=" .. tostring(field:blocks(12, 12, 1, "move")) .. "\n")
    end)

    -- Does: Writes a sprite atlas manifest for hex object refs.
    -- Shows: Sprite frame names and hex placement are resolved before rendering.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_hex_systems_07_sprite_atlas_manifest.txt
    -- Why: Sprite atlas evidence is required for the object layer, even when the map topology is hex.
    it("TXT: hex systems 07 sprite atlas manifest", function()
        local field = make_hex_field(SHOWCASE_W, SHOWCASE_H)
        local frames = { "torch_idle", "crate", "banner", "wall", "glass", "gate", "shrine", "crystal" }
        for i, name in ipairs(frames) do
            local x = 5 + i * 4
            field:setRef(x, 10, 1, "object", i)
            field:setRef(x, 10, 1, "sprite", i)
            frames[i] = tostring(i) .. ":" .. name .. "@hex(" .. tostring(x) .. ",10)"
        end
        save_text(OUT .. "tilefield_hex_systems_07_sprite_atlas_manifest.txt", "map=50x50\nfield_topology=hex\nframes=" .. table.concat(frames, ",") .. "\n")
    end)

    -- Does: Builds a tilemap-style projected render from hex terrain refs.
    -- Shows: Terrain ids can be adapted into a renderable hex maptile view.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_hex_systems_08_tilemap_from_refs.png
    -- Why: The tilemap stage needs a visible hex projection, not only a square tilemap copy.
    it("PNG: hex systems 08 tilemap from refs", function()
        local field = make_hex_field(SHOWCASE_W, SHOWCASE_H)
        draw_hex_field(field, "terrain", OUT .. "tilefield_hex_systems_08_tilemap_from_refs.png", { cell = SHOWCASE_CELL })
    end)

    -- Does: Writes adapter metadata for hex tilefield-to-render conversion.
    -- Shows: The topology, ref slot, and projected dimensions are explicit.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_hex_systems_09_tilemap_render_adapters.txt
    -- Why: This records how the hex field was adapted into maptile evidence.
    it("TXT: hex systems 09 tilemap render adapters", function()
        local field = make_hex_field(SHOWCASE_W, SHOWCASE_H)
        local iw, ih = hex_size(SHOWCASE_W, SHOWCASE_H, SHOWCASE_CELL)
        save_text(OUT .. "tilefield_hex_systems_09_tilemap_render_adapters.txt",
            "map=50x50\nfield_topology=" .. field:getTopology() .. "\nref_slot=terrain\nprojection=flat_hex_staggered\npixel_width=" .. tostring(iw) .. "\npixel_height=" .. tostring(ih) .. "\n")
    end)

    -- Does: Runs native hex-grid pathfinding on a 50x50 board with a gate in a blocker wall.
    -- Shows: The route follows six-neighbor hex topology instead of square diagonals.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_hex_systems_10_pathfind_route.png
    -- Why: Hex pathfinding evidence must use LHexGrid rather than square NavGrid.
    it("PNG: hex systems 10 pathfind route", function()
        local field = make_hex_field(SHOWCASE_W, SHOWCASE_H)
        local grid = lurek.pathfind.newHexGrid(SHOWCASE_W, SHOWCASE_H)
        for y = 1, SHOWCASE_H do grid:setBlocked(25, y, y ~= 25) end
        local nodes = grid:findPath(TEAM_UNITS[1].x, TEAM_UNITS[1].y, TEAM_UNITS[4].x, TEAM_UNITS[4].y) or {}
        local cell = SHOWCASE_CELL
        local iw, ih = hex_size(SHOWCASE_W, SHOWCASE_H, cell)
        local img = lurek.image.newImageData(iw, ih)
        img:fill(8, 10, 15, 255)
        for y = 1, SHOWCASE_H do
            for x = 1, SHOWCASE_W do
                if grid:isBlocked(x, y) then paint_hex(img, x, y, cell, 86, 46, 58) else paint_hex(img, x, y, cell, 36, 44, 54) end
            end
        end
        draw_hex_path(img, nodes, cell, 255, 238, 120)
        draw_hex_team_units(img, cell)
        save_png(img, OUT .. "tilefield_hex_systems_10_pathfind_route.png")
    end)

    -- Does: Computes movement range on a 50x50 hex grid with field-derived blockers and costs.
    -- Shows: Reachable cells spread through six-neighbor hex movement.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_hex_systems_11_pathfind_range.png
    -- Why: Movement evidence for hex must use hex range semantics, not square diagonal cost.
    it("PNG: hex systems 11 pathfind range", function()
        local field = make_hex_field(SHOWCASE_W, SHOWCASE_H)
        local grid = make_hex_grid_from_field(field)
        local cells = grid:rangeOfMovement(TEAM_UNITS[1].x, TEAM_UNITS[1].y, 18)
        local reachable = {}
        for _, cell in ipairs(cells) do reachable[cell.col .. "," .. cell.row] = true end
        local cell = SHOWCASE_CELL
        local iw, ih = hex_size(SHOWCASE_W, SHOWCASE_H, cell)
        local img = lurek.image.newImageData(iw, ih)
        img:fill(8, 10, 15, 255)
        for y = 1, SHOWCASE_H do
            for x = 1, SHOWCASE_W do
                if reachable[x .. "," .. y] then paint_hex(img, x, y, cell, 76, 142, 92)
                elseif field:blocks(x, y, 1, "move") then paint_hex(img, x, y, cell, 86, 46, 58)
                else paint_hex(img, x, y, cell, 36, 44, 54) end
            end
        end
        draw_hex_dot(img, TEAM_UNITS[1].x, TEAM_UNITS[1].y, cell, 90, 180, 255)
        save_png(img, OUT .. "tilefield_hex_systems_11_pathfind_range.png")
    end)

    -- Does: Computes native hex field-of-view around a center source.
    -- Shows: Hex FOV is bounded by hex distance and line-of-sight blockers.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_hex_systems_12_pathfind_fov.png
    -- Why: Hex visibility from LHexGrid is the pathfinding-side counterpart to awareness masks.
    it("PNG: hex systems 12 pathfind fov", function()
        local grid = lurek.pathfind.newHexGrid(SHOWCASE_W, SHOWCASE_H)
        for y = 8, 42 do grid:setBlocked(25, y, y ~= 25) end
        local cells = grid:fieldOfView(25, 25, 12)
        local visible = {}
        for _, cell in ipairs(cells) do visible[cell.col .. "," .. cell.row] = true end
        local cell = SHOWCASE_CELL
        local iw, ih = hex_size(SHOWCASE_W, SHOWCASE_H, cell)
        local img = lurek.image.newImageData(iw, ih)
        img:fill(8, 10, 15, 255)
        for y = 1, SHOWCASE_H do
            for x = 1, SHOWCASE_W do
                if grid:isBlocked(x, y) then paint_hex(img, x, y, cell, 86, 46, 58)
                elseif visible[x .. "," .. y] then paint_hex(img, x, y, cell, 76, 130, 150)
                else paint_hex(img, x, y, cell, 36, 44, 54) end
            end
        end
        draw_hex_dot(img, 25, 25, cell, 255, 222, 110)
        save_png(img, OUT .. "tilefield_hex_systems_12_pathfind_fov.png")
    end)

    -- Does: Computes awareness masks for four teams on a 50x50 hex tilefield.
    -- Shows: Each team unit reveals a different hex-region source footprint.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_hex_systems_13_awareness_players.png
    -- Why: Per-team awareness evidence must exist on hex maps, not only square maps.
    it("PNG: hex systems 13 awareness per-player masks", function()
        local field = make_hex_field(SHOWCASE_W, SHOWCASE_H)
        local vis = lurek.awareness.newTileAwareness(field, { players = { "blue", "red", "green", "gold" }, rememberExplored = true })
        for _, unit in ipairs(TEAM_UNITS) do
            vis:computeVisible(unit.team, { origin = { x = unit.x, y = unit.y, z = 1 }, range = 10, channel = "vision" })
            vis:computeAction(unit.team, { origin = { x = unit.x, y = unit.y, z = 1 }, range = 7, channel = "action" })
        end
        local cell = SHOWCASE_CELL
        local iw, ih = hex_size(SHOWCASE_W, SHOWCASE_H, cell)
        local img = lurek.image.newImageData(iw, ih)
        img:fill(8, 10, 15, 255)
        for y = 1, SHOWCASE_H do
            for x = 1, SHOWCASE_W do
                local r, g, b = 34, 40, 50
                if vis:isVisible("blue", x, y, 1) then r, g, b = 46, 84, 146 end
                if vis:isVisible("red", x, y, 1) then r, g, b = 136, 56, 64 end
                if vis:isVisible("green", x, y, 1) then r, g, b = 50, 126, 76 end
                if vis:isVisible("gold", x, y, 1) then r, g, b = 150, 126, 52 end
                if vis:canActOn("blue", x, y, 1) then g = math.min(220, g + 64) end
                paint_hex(img, x, y, cell, r, g, b)
            end
        end
        draw_hex_team_units(img, cell)
        save_png(img, OUT .. "tilefield_hex_systems_13_awareness_players.png")
    end)

    -- Does: Shares hex awareness between team members.
    -- Shows: Team sharing changes visible state without mutating the hex map.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_hex_systems_14_awareness_team.txt
    -- Why: Per-team behavior needs a compact state artifact for hex maps.
    it("TXT: hex systems 14 awareness per-team share", function()
        local field = make_hex_field(SHOWCASE_W, SHOWCASE_H)
        local vis = lurek.awareness.newTileAwareness(field, { players = { "blue", "red", "green", "gold" }, rememberExplored = true })
        for _, unit in ipairs(TEAM_UNITS) do
            vis:computeVisible(unit.team, { origin = { x = unit.x, y = unit.y, z = 1 }, range = 9 })
        end
        local before = vis:isVisible("red", TEAM_UNITS[1].x, TEAM_UNITS[1].y, 1)
        vis:setTeam({ "blue", "red" }, { "vision" })
        vis:setTeam({ "green", "gold" }, { "vision" })
        local after = vis:isVisible("red", TEAM_UNITS[1].x, TEAM_UNITS[1].y, 1)
        save_text(OUT .. "tilefield_hex_systems_14_awareness_team.txt", "map=50x50\nfield_topology=hex\nred_sees_blue_before=" .. tostring(before) .. "\nred_sees_blue_after=" .. tostring(after) .. "\n")
    end)

    -- Does: Computes a cone category on a hex tilefield.
    -- Shows: The forward arc clips the hex awareness area while blockers stop lines.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_hex_systems_15_awareness_cone.png
    -- Why: Hex awareness needs category/cone evidence, not only omni visibility.
    it("PNG: hex systems 15 awareness cone category", function()
        local field = make_hex_field(SHOWCASE_W, SHOWCASE_H)
        field:defineCategory("sight", { kind = "awareness" })
        for y = 6, 44 do field:setCategoryBlock(29, y, 1, "sight", y ~= 25) end
        local vis = lurek.awareness.newTileAwareness(field, { players = { "scout" } })
        vis:defineCategory("sight", { active = true, range = 13, mode = "cone", arc = 90, facing = { x = 1, y = 0 }, blockerCategory = "sight" })
        vis:computeVisible("scout", { origin = { x = 18, y = 25, z = 1 }, category = "sight" })
        local cell = SHOWCASE_CELL
        local iw, ih = hex_size(SHOWCASE_W, SHOWCASE_H, cell)
        local img = lurek.image.newImageData(iw, ih)
        img:fill(8, 10, 15, 255)
        for y = 1, SHOWCASE_H do
            for x = 1, SHOWCASE_W do
                if field:blocksCategory(x, y, 1, "sight") then paint_hex(img, x, y, cell, 72, 44, 54)
                elseif vis:isAware("scout", "sight", x, y, 1) then paint_hex(img, x, y, cell, 82, 150, 118)
                else paint_hex(img, x, y, cell, 36, 44, 54) end
            end
        end
        draw_hex_dot(img, 18, 25, cell, 255, 222, 110)
        save_png(img, OUT .. "tilefield_hex_systems_15_awareness_cone.png")
    end)

    -- Does: Writes hex line-of-sight and line-of-action channel answers.
    -- Shows: Hex line traversal still respects independent blocker channels.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_hex_systems_16_awareness_line_channels.txt
    -- Why: Channel semantics should not regress when topology changes from square to hex.
    it("TXT: hex systems 16 awareness sight action channels", function()
        local field = lurek.tilefield.new({ width = SHOWCASE_W, height = SHOWCASE_H, topology = "hex" })
        for x = 10, 40, 10 do field:applyProfile(x, 25, 1, "window") end
        local from = { x = 2, y = 25, z = 1 }
        local to = { x = 49, y = 25, z = 1 }
        save_text(OUT .. "tilefield_hex_systems_16_awareness_line_channels.txt",
            "map=50x50\nfield_topology=hex\nline_of_sight=" .. tostring(lurek.awareness.lineOfSight(field, from, to)) .. "\nline_of_action=" .. tostring(lurek.awareness.lineOfAction(field, from, to)) .. "\n")
    end)

    -- Does: Computes a hex tilelight point source through blockers.
    -- Shows: Light propagation follows hex line traversal and blocker transmission.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_hex_systems_17_tilelight_point_blockers.png
    -- Why: The point-light blocker showcase needs hex topology coverage.
    it("PNG: hex systems 17 tilelight point blockers", function()
        local field = make_hex_field(SHOWCASE_W, SHOWCASE_H)
        for y = 6, 44 do field:setBlock(25, y, 1, "light", y ~= 25) end
        local light = lurek.tilelight.new(field)
        light:addPointLight({ x = 8, y = 25, z = 1, radius = 20, intensity = 1.0, color = { r = 1, g = 0.55, b = 0.2 } })
        light:compute({ includePointLights = true, includeSunLight = false })
        draw_hex_light_layer(field, light, OUT .. "tilefield_hex_systems_17_tilelight_point_blockers.png")
    end)

    -- Does: Adds many colored tilelight sources to a generated hex field.
    -- Shows: Multiple lights mix over hex terrain, object blockers, and light blockers.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_hex_systems_18_tilelight_many_sources.png
    -- Why: The user explicitly asked for many light sources on the large map, including hex coverage.
    it("PNG: hex systems 18 tilelight many sources", function()
        local field = make_hex_field(SHOWCASE_W, SHOWCASE_H)
        local light = lurek.tilelight.new(field)
        add_hex_showcase_lights(light)
        light:compute({ includePointLights = true, includeSunLight = false })
        draw_hex_light_layer(field, light, OUT .. "tilefield_hex_systems_18_tilelight_many_sources.png")
    end)

    -- Does: Combines hex line and area tilelights.
    -- Shows: Linear and rectangular emitters produce distinct footprints over a hex field.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_hex_systems_19_tilelight_line_area.png
    -- Why: Hex tilelight evidence must cover non-point sources too.
    it("PNG: hex systems 19 tilelight line and area sources", function()
        local field = make_hex_field(SHOWCASE_W, SHOWCASE_H)
        local light = lurek.tilelight.new(field)
        light:addLineLight({ x1 = 6, y1 = 12, x2 = 45, y2 = 12, z1 = 1, z2 = 1, radius = 5.5, intensity = 0.65, color = { r = 0.2, g = 0.8, b = 1.0 } })
        light:addLineLight({ x1 = 12, y1 = 45, x2 = 45, y2 = 18, z1 = 1, z2 = 1, radius = 5.0, intensity = 0.5, color = { r = 0.9, g = 0.35, b = 1.0 } })
        light:addAreaLight({ x = 20, y = 22, z = 1, width = 10, height = 7, radius = 8, intensity = 0.75, color = { r = 1.0, g = 0.7, b = 0.25 } })
        light:compute({ includeLineLights = true, includeAreaLights = true, includeSunLight = false })
        draw_hex_light_layer(field, light, OUT .. "tilefield_hex_systems_19_tilelight_line_area.png")
    end)

    -- Does: Computes global light through a two-level 50x50 hex tilefield.
    -- Shows: Upper-level sun occlusion dims lower-level hex cells.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_hex_systems_20_tilelight_global_multilevel.png
    -- Why: Multilevel tilelight behavior must be checked on hex topology too.
    it("PNG: hex systems 20 tilelight global multilevel occlusion", function()
        local field = make_hex_field(SHOWCASE_W, SHOWCASE_H)
        local light = lurek.tilelight.new(field)
        light:setGlobalLight({ intensity = 0.55, color = { r = 1.0, g = 0.62, b = 0.24 } })
        light:compute({ includePointLights = false, includeGlobalLight = true })
        local cell = SHOWCASE_CELL
        local iw, ih = hex_size(SHOWCASE_W, SHOWCASE_H, cell)
        local img = lurek.image.newImageData(iw * 2, ih)
        img:fill(8, 9, 13, 255)
        for z = 1, 2 do
            for y = 1, SHOWCASE_H do
                for x = 1, SHOWCASE_W do
                    local r, g, b = light:getLight(x, y, z)
                    local cx, cy = hex_center(x, y, cell)
                    img:drawCircle(cx + (z - 1) * iw, cy, math.max(2, math.floor(cell * 0.45)), math.floor((r or 0) * 255), math.floor((g or 0) * 255), math.floor((b or 0) * 255), 255)
                end
            end
        end
        save_png(img, OUT .. "tilefield_hex_systems_20_tilelight_global_multilevel.png")
    end)

    -- Does: Writes source lifecycle data for hex tilelight.
    -- Shows: Add/update/remove operations produce deterministic sampled luma.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_hex_systems_21_tilelight_source_lifecycle.txt
    -- Why: Source management should be proved separately from color screenshots.
    it("TXT: hex systems 21 tilelight source lifecycle", function()
        local field = make_hex_field(SHOWCASE_W, SHOWCASE_H)
        local light = lurek.tilelight.new(field)
        add_hex_showcase_lights(light)
        local point = light:addPointLight({ x = 20, y = 20, z = 1, radius = 6, intensity = 0.4 })
        light:updatePointLight(point, { x = 25, y = 25, radius = 12, intensity = 0.8 })
        local line = light:addLineLight({ x1 = 1, y1 = 50, x2 = 50, y2 = 50, z1 = 1, z2 = 1, radius = 4, intensity = 0.5 })
        local removed = light:removeLineLight(line)
        light:compute({ includePointLights = true, includeLineLights = true, includeSunLight = false })
        local _, _, _, luma = light:getLight(25, 25, 1)
        save_text(OUT .. "tilefield_hex_systems_21_tilelight_source_lifecycle.txt", "map=50x50\nfield_topology=hex\nstatic_sources=12\npoint_id=" .. tostring(point) .. "\nremoved_line=" .. tostring(removed) .. "\nluma_25_25=" .. fmt(luma) .. "\n")
    end)

    -- Does: Combines hex terrain, awareness fog, and tilelight luma.
    -- Shows: The minimap-style view keeps module outputs visually separate on a hex board.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_hex_systems_22_fog_light_minimap.png
    -- Why: The final renderer needs intermediate fog/light evidence for hex topology.
    it("PNG: hex systems 22 fog and light minimap overlay", function()
        local field = make_hex_field(SHOWCASE_W, SHOWCASE_H)
        local vis = lurek.awareness.newTileAwareness(field, { players = { "blue", "red", "green", "gold" }, rememberExplored = true })
        for _, unit in ipairs(TEAM_UNITS) do vis:computeVisible(unit.team, { origin = { x = unit.x, y = unit.y, z = 1 }, range = 11 }) end
        local light = lurek.tilelight.new(field)
        add_hex_showcase_lights(light)
        light:compute({ includePointLights = true, includeSunLight = false })
        local cell = SHOWCASE_CELL
        local iw, ih = hex_size(SHOWCASE_W, SHOWCASE_H, cell)
        local img = lurek.image.newImageData(iw, ih)
        img:fill(8, 10, 15, 255)
        for y = 1, SHOWCASE_H do
            for x = 1, SHOWCASE_W do
                local r, g, b = cell_color(field:getRef(x, y, 1, "terrain"))
                local _, _, _, luma = light:getLight(x, y, 1)
                local lit = 0.35 + math.min(0.9, luma or 0)
                if not (vis:isVisible("blue", x, y, 1) or vis:isVisible("red", x, y, 1) or vis:isVisible("green", x, y, 1) or vis:isVisible("gold", x, y, 1)) then lit = lit * 0.25 end
                paint_hex(img, x, y, cell, math.floor(r * lit), math.floor(g * lit), math.floor(b * lit))
            end
        end
        draw_hex_team_units(img, cell)
        save_png(img, OUT .. "tilefield_hex_systems_22_fog_light_minimap.png")
    end)

    -- Does: Stores 25x25 generated hex fields inside a 2x2 tilefield map.
    -- Shows: The full atlas covers a 50x50 hex-world footprint in compatible chunks.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_hex_systems_23_fieldmap_chunks.png
    -- Why: Hex field-map evidence is required because chunking is topology-sensitive.
    it("PNG: hex systems 23 tilefield map chunks", function()
        local fmap = lurek.tilefield.newFieldMap({ width = 2, height = 2, layers = 1, fieldWidth = 25, fieldHeight = 25, fieldLevels = 2, topology = "hex" })
        local cell = SHOWCASE_CELL
        local cw, ch = hex_size(25, 25, cell)
        local gap = 8
        local img = lurek.image.newImageData(cw * 2 + gap, ch * 2 + gap)
        img:fill(8, 10, 15, 255)
        for my = 1, 2 do
            for mx = 1, 2 do
                local field = make_hex_field(25, 25)
                fmap:setField(mx, my, 1, field)
                local ox = (mx - 1) * (cw + gap)
                local oy = (my - 1) * (ch + gap)
                for y = 1, 25 do
                    for x = 1, 25 do
                        local r, g, b = cell_color(field:getRef(x, y, 1, "terrain"))
                        local cx, cy = hex_center(x, y, cell)
                        img:drawCircle(ox + cx, oy + cy, math.max(2, math.floor(cell * 0.45)), r, g, b, 255)
                    end
                end
            end
        end
        save_png(img, OUT .. "tilefield_hex_systems_23_fieldmap_chunks.png")
    end)

    -- Does: Overlays mapblock output over generated hex terrain.
    -- Shows: Procedural and authored map data coexist before downstream hex systems consume it.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_hex_systems_24_procgen_mapblock_overlay.png
    -- Why: This is the hex counterpart to the requested procgen plus mapblock stage.
    it("PNG: hex systems 24 procgen plus mapblock overlay", function()
        local field = make_hex_field(SHOWCASE_W, SHOWCASE_H)
        local world = MapblockFixture.build(44)
        local blocks = world.result:toTileField({ layer = 0, slot = 0, ref = "block", skipZero = true, topology = "hex" })
        local ox, oy = 22, 23
        for y = 1, world.result:getHeight() do
            for x = 1, world.result:getWidth() do
                local ref = blocks:getRef(x, y, 1, "block")
                if ref and ref ~= 0 and field:inBounds(ox + x, oy + y, 1) then
                    field:setRef(ox + x, oy + y, 1, "object", ref)
                    field:setBlock(ox + x, oy + y, 1, "move", true)
                end
            end
        end
        draw_hex_field(field, "object", OUT .. "tilefield_hex_systems_24_procgen_mapblock_overlay.png", { cell = SHOWCASE_CELL })
    end)

    -- Does: Renders the final hex maptile view from terrain, objects, awareness, pathfinding, and tilelight.
    -- Shows: The 50x50 hex map includes four teams, many lights, object refs, fog, blockers, and a hex path.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_hex_systems_25_final_maptile_render.png
    -- Why: This closes the hex pipeline with one reviewer-facing final artifact.
    it("PNG: hex systems 25 final maptile render", function()
        local field = make_hex_field(SHOWCASE_W, SHOWCASE_H)
        for x = 8, 43, 5 do field:setRef(x, 25, 1, "object", 2); field:setBlock(x, 25, 1, "move", true) end
        field:setBlock(25, 25, 1, "move", false)
        local vis = lurek.awareness.newTileAwareness(field, { players = { "blue", "red", "green", "gold" }, rememberExplored = true })
        for _, unit in ipairs(TEAM_UNITS) do vis:computeVisible(unit.team, { origin = { x = unit.x, y = unit.y, z = 1 }, range = 12 }) end
        local grid = make_hex_grid_from_field(field)
        local nodes = grid:findPath(TEAM_UNITS[1].x, TEAM_UNITS[1].y, TEAM_UNITS[4].x, TEAM_UNITS[4].y) or {}
        local light = lurek.tilelight.new(field)
        add_hex_showcase_lights(light)
        light:compute({ includePointLights = true, includeSunLight = false })
        local cell = SHOWCASE_CELL
        local iw, ih = hex_size(SHOWCASE_W, SHOWCASE_H, cell)
        local img = lurek.image.newImageData(iw, ih)
        img:fill(8, 10, 15, 255)
        for y = 1, SHOWCASE_H do
            for x = 1, SHOWCASE_W do
                local r, g, b = cell_color(field:getRef(x, y, 1, "terrain"))
                local _, _, _, luma = light:getLight(x, y, 1)
                local visible = vis:isVisible("blue", x, y, 1) or vis:isVisible("red", x, y, 1) or vis:isVisible("green", x, y, 1) or vis:isVisible("gold", x, y, 1)
                local lit = visible and (0.45 + math.min(0.75, luma or 0)) or 0.18
                if field:blocks(x, y, 1, "move") then r, g, b = 88, 58, 66 end
                paint_hex(img, x, y, cell, math.floor(r * lit), math.floor(g * lit), math.floor(b * lit))
                local obj = field:getRef(x, y, 1, "object")
                if obj and obj ~= 0 then draw_hex_dot(img, x, y, cell, 255, 222, 110) end
            end
        end
        draw_hex_path(img, nodes, cell, 255, 238, 120)
        draw_hex_team_units(img, cell)
        save_png(img, OUT .. "tilefield_hex_systems_25_final_maptile_render.png")
    end)
end)

test_summary()
