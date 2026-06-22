local Fixture = {}

local function new_config()
    local config = lurek.mapblock.newConfig()
    config:setDefaultSegmentSize(1)
    return config
end

local function fill_rect_pixels(img, x, y, w, h, r, g, b, a)
    for yy = y, y + h - 1 do
        for xx = x, x + w - 1 do
            img:setPixel(xx, yy, r, g, b, a or 255)
        end
    end
end

local function draw_rect_outline(img, x, y, w, h, r, g, b, a)
    img:drawLine(x, y, x + w - 1, y, r, g, b, a or 255)
    img:drawLine(x + w - 1, y, x + w - 1, y + h - 1, r, g, b, a or 255)
    img:drawLine(x + w - 1, y + h - 1, x, y + h - 1, r, g, b, a or 255)
    img:drawLine(x, y + h - 1, x, y, r, g, b, a or 255)
end

local function copy_cells(cells)
    local out = {}
    for i = 1, #cells do
        out[i] = { x = cells[i].x, y = cells[i].y }
    end
    return out
end

local function copy_placements(placements)
    local out = {}
    for i = 1, #placements do
        local placement = placements[i]
        out[i] = {
            block_name = placement.block_name,
            group_name = placement.group_name,
            grid_x = placement.grid_x,
            grid_y = placement.grid_y,
            level = placement.level,
            rotation = placement.rotation,
            mirrored = placement.mirrored,
            cells = copy_cells(placement.cells or {}),
        }
    end
    return out
end

local function level_histogram(result, level)
    local histogram = {}
    for y = 0, result:getHeight() - 1 do
        for x = 0, result:getWidth() - 1 do
            local gid = result:getGid(level, 0, x, y, 0)
            if gid ~= 0 then
                local key = tostring(gid)
                histogram[key] = (histogram[key] or 0) + 1
            end
        end
    end
    return histogram
end

local function make_block(config, spec)
    local block = lurek.mapblock.newBlock(spec.width, spec.height, 1, config)
    block:setName(spec.name)
    if spec.weight then
        block:setWeight(spec.weight)
    end
    if spec.footprint then
        block:setFootprint(spec.footprint)
    end
    if spec.level_span then
        block:setLevelSpan(spec.level_span)
    end
    if spec.edge_only ~= nil then
        block:setEdgeOnly(spec.edge_only)
    end
    if spec.interior_only ~= nil then
        block:setInteriorOnly(spec.interior_only)
    end
    for _, socket in ipairs(spec.sockets or {}) do
        block:setSocket(socket.x, socket.y, socket.edge, socket.kind)
    end
    for _, tile in ipairs(spec.tiles or {}) do
        block:setTile(0, tile.x, tile.y, 0, 1, tile.gid)
    end
    return block
end

local SHAPE = {
    { 1, 0 }, { 5, 0 },
    { 0, 1 }, { 1, 1 }, { 2, 1 }, { 3, 1 }, { 4, 1 }, { 5, 1 },
    { 0, 2 }, { 2, 2 }, { 3, 2 }, { 4, 2 }, { 5, 2 },
    { 1, 3 }, { 2, 3 }, { 3, 3 }, { 4, 3 }, { 5, 3 },
    { 2, 4 }, { 3, 4 }, { 4, 4 },
}

local PLACEMENT_COLORS = {
    water = { 18, 54, 96 },
    tower = { 220, 194, 124 },
    keep = { 136, 101, 72 },
    granary = { 103, 149, 86 },
    barracks = { 120, 126, 157 },
    gate = { 188, 92, 70 },
    garden = { 78, 170, 118 },
    banner = { 214, 72, 142 },
    lantern = { 242, 212, 96 },
    elbow = { 104, 176, 118 },
    bar = { 94, 126, 190 },
    pin = { 232, 202, 108 },
    source = { 220, 96, 86 },
    link = { 218, 180, 86 },
    sink = { 82, 176, 138 },
    stair = { 128, 108, 210 },
    bridge = { 96, 164, 192 },
    room = { 148, 102, 76 },
    pillar = { 232, 204, 122 },
    outer_wall = { 186, 112, 88 },
    inner_core = { 118, 176, 128 },
    plaza = { 94, 132, 186 },
}

local BLOCK_SPECS = {
    { name = "tower", width = 1, height = 1, tiles = { { x = 0, y = 0, gid = 21 } } },
    {
        name = "keep",
        width = 2,
        height = 2,
        tiles = {
            { x = 0, y = 0, gid = 31 },
            { x = 1, y = 0, gid = 32 },
            { x = 0, y = 1, gid = 33 },
            { x = 1, y = 1, gid = 34 },
        },
    },
    {
        name = "granary",
        width = 2,
        height = 2,
        footprint = {
            { 0, 0 },
            { 1, 0 },
            { 0, 1 },
        },
        tiles = {
            { x = 0, y = 0, gid = 41 },
            { x = 1, y = 0, gid = 42 },
            { x = 0, y = 1, gid = 43 },
        },
    },
    {
        name = "barracks",
        width = 2,
        height = 1,
        tiles = {
            { x = 0, y = 0, gid = 51 },
            { x = 1, y = 0, gid = 52 },
        },
    },
    {
        name = "gate",
        width = 2,
        height = 1,
        tiles = {
            { x = 0, y = 0, gid = 61 },
            { x = 1, y = 0, gid = 62 },
        },
    },
    {
        name = "garden",
        width = 2,
        height = 2,
        tiles = {
            { x = 0, y = 0, gid = 71 },
            { x = 1, y = 0, gid = 72 },
            { x = 0, y = 1, gid = 73 },
            { x = 1, y = 1, gid = 74 },
        },
    },
    { name = "banner", width = 1, height = 1, tiles = { { x = 0, y = 0, gid = 81 } } },
    { name = "lantern", width = 1, height = 1, tiles = { { x = 0, y = 0, gid = 82 } } },
}

function Fixture.build(seed)
    local config = new_config()
    local generator = lurek.mapblock.newGenerator(config)
    generator:setShape(SHAPE)
    generator:setTileSize(1, 1)
    generator:setMaxLevels(2)
    generator:setSeed(seed)

    local group = lurek.mapblock.newGroup("fortress")
    for _, spec in ipairs(BLOCK_SPECS) do
        group:addBlock(make_block(config, spec))
    end
    generator:addGroup(group)

    local script = lurek.mapblock.newScript("fortress_fixture")
    script:addStep("place_block", { group = "fortress", block_index = 2, x = 0, y = 1, rotation = 0, mirror = false, level = 0 })
    script:addStep("place_block", { group = "fortress", block_index = 0, x = 1, y = 0, level = 0 })
    script:addStep("place_block", { group = "fortress", block_index = 1, x = 2, y = 1, level = 0 })
    script:addStep("place_block", { group = "fortress", block_index = 3, x = 4, y = 1, level = 0 })
    script:addStep("place_block", { group = "fortress", block_index = 4, x = 1, y = 3, level = 0 })
    script:addStep("place_block", { group = "fortress", block_index = 5, x = 3, y = 3, level = 0 })
    script:addStep("place_block", { group = "fortress", block_index = 0, x = 5, y = 2, level = 0 })
    script:addStep("place_block", { group = "fortress", block_index = 6, x = 5, y = 0, level = 1 })
    script:addStep("place_block", { group = "fortress", block_index = 7, x = 4, y = 2, level = 1 })
    script:addStep("place_block", { group = "fortress", block_index = 6, x = 5, y = 3, level = 1 })
    script:addStep("place_block", { group = "fortress", block_index = 7, x = 2, y = 4, level = 1 })

    local result, report = generator:generateWithReport(script)
    return {
        seed = seed,
        shape = SHAPE,
        result = result,
        report = report:toTable(),
        placements = copy_placements(result:getPlacements()),
    }
end

function Fixture.build_solver(seed)
    local config = new_config()
    local generator = lurek.mapblock.newGenerator(config)
    generator:setShape({
        { 0, 0 }, { 1, 0 }, { 2, 0 }, { 3, 0 },
        { 0, 1 }, { 1, 1 }, { 2, 1 },
        { 1, 2 }, { 2, 2 }, { 3, 2 },
        { 2, 3 }, { 3, 3 },
    })
    generator:setTileSize(1, 1)
    generator:setSeed(seed)
    generator:setSolverBudget({ max_nodes = 512, max_depth = 32, max_ms = 1000, max_candidates_per_cell = 16 })

    local group = lurek.mapblock.newGroup("solver")
    group:addBlock(make_block(config, {
        name = "elbow",
        width = 2,
        height = 2,
        footprint = { { 0, 0 }, { 1, 0 }, { 0, 1 } },
        weight = 2.0,
        tiles = {
            { x = 0, y = 0, gid = 91 },
            { x = 1, y = 0, gid = 92 },
            { x = 0, y = 1, gid = 93 },
        },
    }))
    group:addBlock(make_block(config, {
        name = "bar",
        width = 2,
        height = 1,
        weight = 1.4,
        tiles = {
            { x = 0, y = 0, gid = 94 },
            { x = 1, y = 0, gid = 95 },
        },
    }))
    group:addBlock(make_block(config, {
        name = "pin",
        width = 1,
        height = 1,
        weight = 0.5,
        tiles = { { x = 0, y = 0, gid = 96 } },
    }))
    generator:addGroup(group)

    local script = lurek.mapblock.newScript("solver_footprint")
    script:addStep("solve_shape", { group = "solver", random_rotation = true, random_mirror = true })

    local result, report = generator:generateWithReport(script)
    return {
        seed = seed,
        shape = {
            { 0, 0 }, { 1, 0 }, { 2, 0 }, { 3, 0 },
            { 0, 1 }, { 1, 1 }, { 2, 1 },
            { 1, 2 }, { 2, 2 }, { 3, 2 },
            { 2, 3 }, { 3, 3 },
        },
        result = result,
        report = report:toTable(),
        placements = copy_placements(result:getPlacements()),
    }
end

function Fixture.build_socket_corridor(seed)
    local config = new_config()
    local generator = lurek.mapblock.newGenerator(config)
    generator:setRectShape(5, 1)
    generator:setTileSize(1, 1)
    generator:setSeed(seed)

    local rules = lurek.mapblock.newRules()
    rules:addCompatible(10, 20)
    generator:setRules(rules)

    local group = lurek.mapblock.newGroup("sockets")
    group:addBlock(make_block(config, {
        name = "source",
        width = 1,
        height = 1,
        sockets = { { x = 0, y = 0, edge = "east", kind = 10 } },
        tiles = { { x = 0, y = 0, gid = 101 } },
    }))
    group:addBlock(make_block(config, {
        name = "link",
        width = 1,
        height = 1,
        sockets = {
            { x = 0, y = 0, edge = "west", kind = 20 },
            { x = 0, y = 0, edge = "east", kind = 10 },
        },
        tiles = { { x = 0, y = 0, gid = 102 } },
    }))
    group:addBlock(make_block(config, {
        name = "sink",
        width = 1,
        height = 1,
        sockets = { { x = 0, y = 0, edge = "west", kind = 20 } },
        tiles = { { x = 0, y = 0, gid = 103 } },
    }))
    generator:addGroup(group)

    local script = lurek.mapblock.newScript("socket_corridor")
    script:addStep("place_block", { group = "sockets", block_index = 0, x = 0, y = 0, match_sides = true })
    script:addStep("place_block", { group = "sockets", block_index = 1, x = 1, y = 0, match_sides = true })
    script:addStep("place_block", { group = "sockets", block_index = 1, x = 2, y = 0, match_sides = true })
    script:addStep("place_block", { group = "sockets", block_index = 1, x = 3, y = 0, match_sides = true })
    script:addStep("place_block", { group = "sockets", block_index = 2, x = 4, y = 0, match_sides = true })

    local result, report = generator:generateWithReport(script)
    return {
        seed = seed,
        result = result,
        report = report:toTable(),
        placements = copy_placements(result:getPlacements()),
    }
end

function Fixture.build_transform(seed)
    local config = new_config()
    local generator = lurek.mapblock.newGenerator(config)
    generator:setRectShape(5, 3)
    generator:setTileSize(1, 1)
    generator:setSeed(seed)
    generator:setOrientation("isometric")

    local group = lurek.mapblock.newGroup("transforms")
    group:addBlock(make_block(config, {
        name = "stair",
        width = 2,
        height = 2,
        footprint = { { 0, 0 }, { 1, 0 }, { 1, 1 } },
        tiles = {
            { x = 0, y = 0, gid = 111 },
            { x = 1, y = 0, gid = 112 },
            { x = 1, y = 1, gid = 113 },
        },
    }))
    group:addBlock(make_block(config, {
        name = "bridge",
        width = 3,
        height = 1,
        tiles = {
            { x = 0, y = 0, gid = 114 },
            { x = 1, y = 0, gid = 115 },
            { x = 2, y = 0, gid = 116 },
        },
    }))
    generator:addGroup(group)

    local script = lurek.mapblock.newScript("rotated_export")
    script:addStep("place_block", { group = "transforms", block_index = 0, x = 0, y = 0, rotation = 1, mirror = false, match_sides = false })
    script:addStep("place_block", { group = "transforms", block_index = 0, x = 3, y = 0, rotation = 2, mirror = true, match_sides = false })
    script:addStep("place_block", { group = "transforms", block_index = 1, x = 1, y = 2, rotation = 0, mirror = true, match_sides = false })

    local result, report = generator:generateWithReport(script)
    return {
        seed = seed,
        result = result,
        report = report:toTable(),
        placements = copy_placements(result:getPlacements()),
    }
end

function Fixture.build_paint(seed)
    local config = new_config()
    local generator = lurek.mapblock.newGenerator(config)
    generator:setRectShape(6, 4)
    generator:setTileSize(1, 1)
    generator:setSeed(seed)

    local group = lurek.mapblock.newGroup("paint")
    group:addBlock(make_block(config, {
        name = "room",
        width = 2,
        height = 2,
        tiles = {
            { x = 0, y = 0, gid = 121 },
            { x = 1, y = 0, gid = 122 },
            { x = 0, y = 1, gid = 123 },
            { x = 1, y = 1, gid = 124 },
        },
    }))
    group:addBlock(make_block(config, {
        name = "pillar",
        width = 1,
        height = 1,
        tiles = { { x = 0, y = 0, gid = 125 } },
    }))
    generator:addGroup(group)

    local script = lurek.mapblock.newScript("paint_diagnostics")
    script:addStep("place_block", { group = "paint", block_index = 0, x = 1, y = 1, match_sides = false })
    script:addStep("place_block", { group = "paint", block_index = 1, x = 4, y = 2, match_sides = false })
    script:addStep("fill_rect", { x = 0, y = 0, width = 6, height = 1, tile_id = 131, layer = 0, level = 0, slot = 0 })
    script:addStep("fill_rect", { x = 5, y = 0, width = 3, height = 4, tile_id = 132, layer = 0, level = 0, slot = 0 })
    script:addStep("fill_rect", { x = 0, y = 3, width = 6, height = 1, tile_id = 133, layer = 0, level = 0, slot = 0 })

    local result, report = generator:generateWithReport(script)
    return {
        seed = seed,
        result = result,
        report = report:toTable(),
        placements = copy_placements(result:getPlacements()),
    }
end

function Fixture.render_macro(world, cell, pad)
    local width = 6
    local height = 5
    local img = lurek.image.newImageData(width * cell + pad * 2, height * cell + pad * 2)
    img:fill(12, 16, 24, 255)

    for gx = 0, width do
        local xx = pad + gx * cell
        img:drawLine(xx, pad, xx, pad + height * cell, 26, 34, 48, 255)
    end
    for gy = 0, height do
        local yy = pad + gy * cell
        img:drawLine(pad, yy, pad + width * cell, yy, 26, 34, 48, 255)
    end

    fill_rect_pixels(img, pad, pad, width * cell, height * cell, 10, 18, 28, 255)

    for _, placement in ipairs(world.placements) do
        local color = PLACEMENT_COLORS[placement.block_name] or { 190, 190, 190 }
        for _, cell_ref in ipairs(placement.cells or {}) do
            local x = pad + cell_ref.x * cell
            local y = pad + cell_ref.y * cell
            fill_rect_pixels(img, x + 2, y + 2, cell - 3, cell - 3, color[1], color[2], color[3], 255)
            draw_rect_outline(img, x + 1, y + 1, cell - 1, cell - 1, 235, 240, 246, 255)
            if placement.level == 1 then
                img:drawCircle(x + math.floor(cell / 2), y + math.floor(cell / 2), math.max(2, math.floor(cell / 5)), 255, 222, 110, 255)
            end
        end
    end

    local route = {
        { 1, 0 },
        { 2, 1 },
        { 3, 1 },
        { 4, 1 },
        { 5, 3 },
    }
    for i = 1, #route - 1 do
        local a = route[i]
        local b = route[i + 1]
        img:drawLine(
            pad + a[1] * cell + math.floor(cell / 2),
            pad + a[2] * cell + math.floor(cell / 2),
            pad + b[1] * cell + math.floor(cell / 2),
            pad + b[2] * cell + math.floor(cell / 2),
            255,
            204,
            84,
            255
        )
    end

    return img
end

function Fixture.render_level(result, level, scale)
    local width = result:getWidth()
    local height = result:getHeight()
    local img = lurek.image.newImageData(width * scale, height * scale)
    img:fill(10, 14, 20, 255)

    local palette = {
        [0] = { 16, 18, 24 },
        [11] = { 24, 62, 104 },
        [21] = { 214, 186, 118 },
        [31] = { 158, 112, 82 },
        [32] = { 142, 101, 72 },
        [33] = { 126, 89, 66 },
        [34] = { 110, 78, 58 },
        [41] = { 110, 160, 90 },
        [42] = { 94, 142, 74 },
        [43] = { 82, 126, 64 },
        [51] = { 112, 120, 154 },
        [52] = { 94, 104, 138 },
        [61] = { 198, 102, 84 },
        [62] = { 170, 86, 70 },
        [71] = { 76, 176, 118 },
        [72] = { 64, 154, 102 },
        [73] = { 48, 132, 84 },
        [74] = { 36, 116, 72 },
        [81] = { 214, 72, 142 },
        [82] = { 248, 216, 110 },
    }

    for y = 0, height - 1 do
        for x = 0, width - 1 do
            local gid = result:getGid(level, 0, x, y, 0)
            local color = palette[gid] or { 220, 220, 220 }
            fill_rect_pixels(img, x * scale, y * scale, scale, scale, color[1], color[2], color[3], 255)
            if gid ~= 0 then
                draw_rect_outline(img, x * scale, y * scale, scale, scale, 18, 22, 28, 160)
            end
        end
    end

    return img
end

local MODULE_PALETTE = {
    [0] = { 16, 18, 24 },
    [11] = { 24, 62, 104 },
    [21] = { 214, 186, 118 },
    [31] = { 158, 112, 82 },
    [32] = { 142, 101, 72 },
    [33] = { 126, 89, 66 },
    [34] = { 110, 78, 58 },
    [41] = { 110, 160, 90 },
    [42] = { 94, 142, 74 },
    [43] = { 82, 126, 64 },
    [51] = { 112, 120, 154 },
    [52] = { 94, 104, 138 },
    [61] = { 198, 102, 84 },
    [62] = { 170, 86, 70 },
    [71] = { 76, 176, 118 },
    [72] = { 64, 154, 102 },
    [73] = { 48, 132, 84 },
    [74] = { 36, 116, 72 },
    [81] = { 214, 72, 142 },
    [82] = { 248, 216, 110 },
    [91] = { 104, 176, 118 },
    [92] = { 82, 150, 104 },
    [93] = { 64, 126, 92 },
    [94] = { 94, 126, 190 },
    [95] = { 72, 104, 166 },
    [96] = { 232, 202, 108 },
    [101] = { 220, 96, 86 },
    [102] = { 218, 180, 86 },
    [103] = { 82, 176, 138 },
    [111] = { 128, 108, 210 },
    [112] = { 110, 94, 190 },
    [113] = { 92, 78, 166 },
    [114] = { 96, 164, 192 },
    [115] = { 74, 142, 170 },
    [116] = { 58, 118, 146 },
    [121] = { 148, 102, 76 },
    [122] = { 132, 90, 68 },
    [123] = { 116, 78, 60 },
    [124] = { 100, 68, 52 },
    [125] = { 232, 204, 122 },
    [131] = { 90, 142, 210 },
    [132] = { 218, 116, 92 },
    [133] = { 92, 180, 124 },
    [141] = { 186, 112, 88 },
    [142] = { 118, 176, 128 },
    [143] = { 94, 132, 186 },
}

local function draw_result_grid(result, level, scale, ox, oy, img)
    for y = 0, result:getHeight() - 1 do
        for x = 0, result:getWidth() - 1 do
            local gid = result:getGid(level, 0, x, y, 0)
            local color = MODULE_PALETTE[gid] or { 220, 220, 220 }
            fill_rect_pixels(img, ox + x * scale, oy + y * scale, scale, scale, color[1], color[2], color[3], 255)
            if gid ~= 0 then
                draw_rect_outline(img, ox + x * scale, oy + y * scale, scale, scale, 14, 18, 24, 180)
            end
        end
    end
end

function Fixture.render_solver(world)
    local cell = 42
    local pad = 20
    local img = lurek.image.newImageData(4 * cell + pad * 2, 4 * cell + pad * 2)
    img:fill(11, 15, 22, 255)

    local available = {}
    for _, p in ipairs(world.shape) do
        available[p[1] .. "," .. p[2]] = true
    end
    for y = 0, 3 do
        for x = 0, 3 do
            local key = x .. "," .. y
            local color = available[key] and { 26, 40, 58 } or { 9, 12, 18 }
            fill_rect_pixels(img, pad + x * cell, pad + y * cell, cell - 2, cell - 2, color[1], color[2], color[3], 255)
        end
    end

    for _, placement in ipairs(world.placements) do
        for _, cell_ref in ipairs(placement.cells or {}) do
            local color = {
                92 + ((cell_ref.x * 47 + cell_ref.y * 29) % 130),
                116 + ((cell_ref.x * 31 + cell_ref.y * 53) % 110),
                138 + ((cell_ref.x * 59 + cell_ref.y * 37) % 90),
            }
            local x = pad + cell_ref.x * cell
            local y = pad + cell_ref.y * cell
            fill_rect_pixels(img, x + 5, y + 5, cell - 11, cell - 11, color[1], color[2], color[3], 255)
            draw_rect_outline(img, x + 4, y + 4, cell - 9, cell - 9, 238, 244, 252, 255)
        end
    end
    return img
end

function Fixture.render_socket_corridor(world)
    local cell = 54
    local pad = 24
    local img = lurek.image.newImageData(5 * cell + pad * 2, cell + pad * 2)
    img:fill(10, 14, 20, 255)

    for x = 0, 4 do
        local gid = world.result:getGid(0, 0, x, 0, 0)
        local color = MODULE_PALETTE[gid] or { 70, 80, 96 }
        fill_rect_pixels(img, pad + x * cell, pad, cell - 2, cell - 2, color[1], color[2], color[3], 255)
        draw_rect_outline(img, pad + x * cell, pad, cell - 2, cell - 2, 232, 238, 246, 255)
        if x < 4 then
            local cx = pad + x * cell + cell - 1
            img:drawLine(cx - 12, pad + math.floor(cell / 2), cx + 12, pad + math.floor(cell / 2), 255, 218, 92, 255)
            img:drawCircle(cx - 14, pad + math.floor(cell / 2), 4, 255, 96, 86, 255)
            img:drawCircle(cx + 14, pad + math.floor(cell / 2), 4, 82, 176, 138, 255)
        end
    end
    return img
end

function Fixture.render_transform_export(world)
    local scale = 34
    local img = lurek.image.newImageData(world.result:getWidth() * scale, world.result:getHeight() * scale)
    img:fill(10, 14, 20, 255)
    draw_result_grid(world.result, 0, scale, 0, 0, img)

    for _, placement in ipairs(world.placements) do
        local cx = placement.grid_x * scale + math.floor(scale / 2)
        local cy = placement.grid_y * scale + math.floor(scale / 2)
        local r = placement.rotation % 4
        local dx = ({ [0] = 0, [1] = 11, [2] = 0, [3] = -11 })[r]
        local dy = ({ [0] = -11, [1] = 0, [2] = 11, [3] = 0 })[r]
        img:drawLine(cx, cy, cx + dx, cy + dy, 255, 232, 120, 255)
        if placement.mirrored then
            img:drawCircle(cx, cy, 5, 255, 100, 150, 255)
        end
    end
    return img
end

function Fixture.render_multilevel(world)
    local scale = 20
    local gap = 18
    local width = world.result:getWidth() * scale * 2 + gap
    local height = world.result:getHeight() * scale
    local img = lurek.image.newImageData(width, height)
    img:fill(10, 14, 20, 255)
    draw_result_grid(world.result, 0, scale, 0, 0, img)
    draw_result_grid(world.result, 1, scale, world.result:getWidth() * scale + gap, 0, img)

    for y = 0, height - 1, 8 do
        img:drawLine(world.result:getWidth() * scale + math.floor(gap / 2), y, world.result:getWidth() * scale + math.floor(gap / 2), math.min(height - 1, y + 4), 255, 222, 110, 255)
    end
    return img
end

function Fixture.render_paint_diagnostics(world)
    local scale = 28
    local img = lurek.image.newImageData(world.result:getWidth() * scale, world.result:getHeight() * scale + 28)
    img:fill(10, 14, 20, 255)
    draw_result_grid(world.result, 0, scale, 0, 0, img)

    local diag = world.report.diagnostics or {}
    local bars = {
        { diag.clipped_paint_ops or 0, 82, 176, 138 },
        { diag.rejected_paint_ops or 0, 218, 116, 92 },
        { world.result:getBlocksPlaced(), 232, 204, 122 },
    }
    local base_y = world.result:getHeight() * scale + 6
    local x = 8
    for _, bar in ipairs(bars) do
        local w = 18 + bar[1] * 22
        fill_rect_pixels(img, x, base_y, w, 14, bar[2], bar[3], bar[4], 255)
        draw_rect_outline(img, x, base_y, w, 14, 232, 238, 246, 255)
        x = x + w + 8
    end
    return img
end

function Fixture.render_timeline_frames(world)
    local frames = {}
    for i = 1, math.min(#world.placements, 8) do
        local frame_world = {
            placements = {},
        }
        for n = 1, i do
            frame_world.placements[n] = world.placements[n]
        end
        frames[#frames + 1] = Fixture.render_macro(frame_world, 34, 18)
    end
    return frames
end

function Fixture.build_edge_interior(seed)
    local config = new_config()
    local generator = lurek.mapblock.newGenerator(config)
    generator:setRectShape(5, 5)
    generator:setTileSize(1, 1)
    generator:setSeed(seed)

    local group = lurek.mapblock.newGroup("edge_interior")
    group:addBlock(make_block(config, {
        name = "outer_wall",
        width = 1,
        height = 1,
        edge_only = true,
        tiles = { { x = 0, y = 0, gid = 141 } },
    }))
    group:addBlock(make_block(config, {
        name = "inner_core",
        width = 1,
        height = 1,
        interior_only = true,
        tiles = { { x = 0, y = 0, gid = 142 } },
    }))
    group:addBlock(make_block(config, {
        name = "plaza",
        width = 1,
        height = 1,
        tiles = { { x = 0, y = 0, gid = 143 } },
    }))
    generator:addGroup(group)

    local script = lurek.mapblock.newScript("edge_interior_policy")
    script:addStep("place_block", { group = "edge_interior", block_index = 0, x = 0, y = 0, match_sides = false })
    script:addStep("place_block", { group = "edge_interior", block_index = 0, x = 4, y = 0, match_sides = false })
    script:addStep("place_block", { group = "edge_interior", block_index = 0, x = 0, y = 4, match_sides = false })
    script:addStep("place_block", { group = "edge_interior", block_index = 0, x = 4, y = 4, match_sides = false })
    script:addStep("place_block", { group = "edge_interior", block_index = 1, x = 2, y = 2, match_sides = false })
    script:addStep("place_block", { group = "edge_interior", block_index = 2, x = 1, y = 2, match_sides = false })
    script:addStep("place_block", { group = "edge_interior", block_index = 2, x = 3, y = 2, match_sides = false })

    local result, report = generator:generateWithReport(script)
    return {
        seed = seed,
        result = result,
        report = report:toTable(),
        placements = copy_placements(result:getPlacements()),
    }
end

function Fixture.render_strategic_tactical_split(world)
    local img = lurek.image.newImageData(700, 310)
    img:fill(10, 14, 20, 255)
    img:drawRect(18, 18, 286, 244, 18, 24, 34, 255)
    img:drawRect(338, 18, 344, 244, 18, 24, 34, 255)
    draw_rect_outline(img, 18, 18, 286, 244, 92, 112, 142, 255)
    draw_rect_outline(img, 338, 18, 344, 244, 92, 112, 142, 255)

    local macro_cell = 38
    local macro_x = 48
    local macro_y = 44
    local available = {}
    for _, p in ipairs(world.shape) do
        available[p[1] .. "," .. p[2]] = true
    end
    for y = 0, 4 do
        for x = 0, 5 do
            local key = x .. "," .. y
            local color = available[key] and { 28, 42, 58 } or { 8, 10, 15 }
            fill_rect_pixels(img, macro_x + x * macro_cell, macro_y + y * macro_cell, macro_cell - 3, macro_cell - 3, color[1], color[2], color[3], 255)
        end
    end
    for _, placement in ipairs(world.placements) do
        local color = PLACEMENT_COLORS[placement.block_name] or { 180, 180, 190 }
        for _, cell_ref in ipairs(placement.cells or {}) do
            local x = macro_x + cell_ref.x * macro_cell
            local y = macro_y + cell_ref.y * macro_cell
            fill_rect_pixels(img, x + 5, y + 5, macro_cell - 12, macro_cell - 12, color[1], color[2], color[3], 255)
            if placement.level == 1 then
                img:drawCircle(x + math.floor(macro_cell / 2), y + math.floor(macro_cell / 2), 6, 248, 216, 110, 255)
            end
        end
    end

    local tactical_scale = 36
    local tactical_x = 398
    local tactical_y = 42
    draw_result_grid(world.result, 0, tactical_scale, tactical_x, tactical_y, img)
    for _, placement in ipairs(world.placements) do
        if placement.block_name == "keep" then
            for _, cell_ref in ipairs(placement.cells or {}) do
                local sx = macro_x + cell_ref.x * macro_cell + math.floor(macro_cell / 2)
                local sy = macro_y + cell_ref.y * macro_cell + math.floor(macro_cell / 2)
                local tx = tactical_x + cell_ref.x * tactical_scale + math.floor(tactical_scale / 2)
                local ty = tactical_y + cell_ref.y * tactical_scale + math.floor(tactical_scale / 2)
                img:drawLine(sx, sy, tx, ty, 255, 222, 110, 190)
                draw_rect_outline(img, tactical_x + cell_ref.x * tactical_scale, tactical_y + cell_ref.y * tactical_scale, tactical_scale, tactical_scale, 255, 222, 110, 255)
            end
            break
        end
    end

    local lx = 42
    for _, entry in ipairs({ "keep", "tower", "granary", "barracks", "gate", "garden", "banner", "lantern" }) do
        local c = PLACEMENT_COLORS[entry]
        fill_rect_pixels(img, lx, 278, 18, 12, c[1], c[2], c[3], 255)
        lx = lx + 28
    end
    return img
end

function Fixture.render_two_level_cutaway(world)
    local scale = 34
    local img = lurek.image.newImageData(470, 340)
    img:fill(9, 13, 19, 255)
    local base_x = 74
    local base_y = 156
    local upper_x = 156
    local upper_y = 54

    img:drawRect(base_x - 16, base_y - 16, world.result:getWidth() * scale + 32, world.result:getHeight() * scale + 32, 18, 24, 34, 255)
    img:drawRect(upper_x - 16, upper_y - 16, world.result:getWidth() * scale + 32, world.result:getHeight() * scale + 32, 22, 27, 38, 255)
    draw_result_grid(world.result, 0, scale, base_x, base_y, img)
    draw_result_grid(world.result, 1, scale, upper_x, upper_y, img)

    for _, placement in ipairs(world.placements) do
        if placement.level == 1 then
            for _, cell_ref in ipairs(placement.cells or {}) do
                local ux = upper_x + cell_ref.x * scale + math.floor(scale / 2)
                local uy = upper_y + cell_ref.y * scale + math.floor(scale / 2)
                local bx = base_x + cell_ref.x * scale + math.floor(scale / 2)
                local by = base_y + cell_ref.y * scale + math.floor(scale / 2)
                img:drawLine(ux, uy, bx, by, 255, 222, 110, 210)
                img:drawCircle(ux, uy, 5, 255, 222, 110, 255)
                img:drawCircle(bx, by, 4, 255, 222, 110, 180)
            end
        end
    end

    draw_rect_outline(img, base_x - 16, base_y - 16, world.result:getWidth() * scale + 32, world.result:getHeight() * scale + 32, 92, 112, 142, 255)
    draw_rect_outline(img, upper_x - 16, upper_y - 16, world.result:getWidth() * scale + 32, world.result:getHeight() * scale + 32, 248, 216, 110, 255)
    return img
end

function Fixture.render_script_pipeline_storyboard(world)
    local panel_w = 138
    local panel_h = 164
    local img = lurek.image.newImageData(panel_w * 5 + 36, panel_h + 48)
    img:fill(10, 14, 20, 255)

    local stage_limits = { 0, 2, 5, 8, #world.placements }
    for stage = 1, #stage_limits do
        local ox = 18 + (stage - 1) * panel_w
        local oy = 24
        img:drawRect(ox, oy, panel_w - 12, panel_h, 18, 24, 34, 255)
        draw_rect_outline(img, ox, oy, panel_w - 12, panel_h, 92, 112, 142, 255)
        local cell = 18
        local gx0 = ox + 10
        local gy0 = oy + 18
        for y = 0, 4 do
            for x = 0, 5 do
                fill_rect_pixels(img, gx0 + x * cell, gy0 + y * cell, cell - 2, cell - 2, 24, 62, 104, 255)
            end
        end
        for i = 1, stage_limits[stage] do
            local placement = world.placements[i]
            local color = PLACEMENT_COLORS[placement.block_name] or { 180, 180, 190 }
            for _, cell_ref in ipairs(placement.cells or {}) do
                fill_rect_pixels(img, gx0 + cell_ref.x * cell + 3, gy0 + cell_ref.y * cell + 3, cell - 7, cell - 7, color[1], color[2], color[3], 255)
                if placement.level == 1 then
                    img:drawCircle(gx0 + cell_ref.x * cell + 9, gy0 + cell_ref.y * cell + 9, 3, 255, 222, 110, 255)
                end
            end
        end
        local progress = math.max(2, math.floor((panel_w - 36) * (stage_limits[stage] / math.max(1, #world.placements))))
        img:drawRect(ox + 18, oy + panel_h - 24, panel_w - 48, 10, 36, 44, 58, 255)
        img:drawRect(ox + 18, oy + panel_h - 24, progress, 10, 255, 204, 84, 255)
    end
    return img
end

function Fixture.render_result_contract(world)
    local img = lurek.image.newImageData(610, 300)
    img:fill(10, 14, 20, 255)
    img:drawRect(18, 18, 252, 184, 18, 24, 34, 255)
    img:drawRect(286, 18, 252, 184, 18, 24, 34, 255)
    img:drawRect(18, 224, 520, 48, 18, 24, 34, 255)
    draw_rect_outline(img, 18, 18, 252, 184, 92, 112, 142, 255)
    draw_rect_outline(img, 286, 18, 252, 184, 248, 216, 110, 255)
    draw_rect_outline(img, 18, 224, 520, 48, 92, 112, 142, 255)
    draw_result_grid(world.result, 0, 28, 58, 40, img)
    draw_result_grid(world.result, 1, 28, 326, 40, img)

    local histograms = {
        level_histogram(world.result, 0),
        level_histogram(world.result, 1),
    }
    local bar_x = 30
    for level = 1, 2 do
        local keys = {}
        for gid, _ in pairs(histograms[level]) do
            keys[#keys + 1] = tonumber(gid)
        end
        table.sort(keys)
        for _, gid in ipairs(keys) do
            local count = histograms[level][tostring(gid)] or 0
            local c = MODULE_PALETTE[gid] or { 220, 220, 220 }
            local h = math.min(38, 4 + count * 2)
            img:drawRect(bar_x, 268 - h, 10, h, c[1], c[2], c[3], 255)
            bar_x = bar_x + 13
        end
        bar_x = bar_x + 34
    end
    return img
end

function Fixture.render_edge_interior_constraints(world)
    local scale = 46
    local pad = 30
    local img = lurek.image.newImageData(5 * scale + pad * 2, 5 * scale + pad * 2)
    img:fill(9, 13, 19, 255)
    for y = 0, 4 do
        for x = 0, 4 do
            local edge = x == 0 or y == 0 or x == 4 or y == 4
            local color = edge and { 38, 48, 64 } or { 22, 32, 44 }
            fill_rect_pixels(img, pad + x * scale, pad + y * scale, scale - 2, scale - 2, color[1], color[2], color[3], 255)
        end
    end
    draw_result_grid(world.result, 0, scale, pad, pad, img)
    for _, placement in ipairs(world.placements) do
        local color = PLACEMENT_COLORS[placement.block_name] or { 220, 220, 220 }
        for _, cell_ref in ipairs(placement.cells or {}) do
            local cx = pad + cell_ref.x * scale + math.floor(scale / 2)
            local cy = pad + cell_ref.y * scale + math.floor(scale / 2)
            img:drawCircle(cx, cy, 7, color[1], color[2], color[3], 255)
            if placement.block_name == "outer_wall" then
                draw_rect_outline(img, pad + cell_ref.x * scale + 4, pad + cell_ref.y * scale + 4, scale - 10, scale - 10, 255, 222, 110, 255)
            else
                img:drawLine(cx - 11, cy, cx + 11, cy, 232, 238, 246, 255)
                img:drawLine(cx, cy - 11, cx, cy + 11, 232, 238, 246, 255)
            end
        end
    end
    return img
end

function Fixture.manifest(world)
    return {
        seed = world.seed,
        shape_cell_count = #world.shape,
        width = world.result:getWidth(),
        height = world.result:getHeight(),
        level_count = world.result:getLevelCount(),
        layer_count = world.result:getLayerCount(),
        blocks_placed = world.result:getBlocksPlaced(),
        placements = world.placements,
        diagnostics = world.report.diagnostics,
        solve_failure_reason = world.report.solve_failure_reason,
        gid_histograms = {
            level0 = level_histogram(world.result, 0),
            level1 = level_histogram(world.result, 1),
        },
    }
end

return Fixture
