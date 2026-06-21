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
    script:addStep("fill_rect", { x = 0, y = 0, width = 6, height = 5, tile_id = 11, slot = 0, layer = 0, level = 0 })
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
