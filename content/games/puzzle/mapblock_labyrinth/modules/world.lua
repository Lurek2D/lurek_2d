local M = {}

local MACRO_SEGMENT = 1
local DETAIL_SEGMENT = 5

local MACRO_COLORS = {
    coast = { 72, 138, 204 },
    citadel = { 196, 144, 82 },
    academy = { 156, 114, 204 },
    arcade = { 88, 178, 132 },
    market = { 224, 172, 78 },
    outpost = { 214, 108, 126 },
    hall = { 126, 164, 196 },
    plaza = { 198, 198, 210 },
}

local TILES = {
    water = 1,
    sand = 2,
    grass = 3,
    stone = 4,
    wall = 5,
    brick = 6,
    garden = 7,
    timber = 8,
    road = 9,
    violet = 10,
    awning = 11,
    roof = 12,
    trim = 13,
    gate = 14,
    banner = 15,
    shadow = 16,
}

local TILE_COLORS = {
    [0] = { 18, 20, 28 },
    [TILES.water] = { 44, 88, 162 },
    [TILES.sand] = { 216, 198, 132 },
    [TILES.grass] = { 84, 136, 84 },
    [TILES.stone] = { 142, 138, 136 },
    [TILES.wall] = { 92, 96, 112 },
    [TILES.brick] = { 184, 92, 82 },
    [TILES.garden] = { 112, 170, 106 },
    [TILES.timber] = { 168, 132, 88 },
    [TILES.road] = { 220, 196, 92 },
    [TILES.violet] = { 122, 118, 168 },
    [TILES.awning] = { 204, 126, 54 },
    [TILES.roof] = { 170, 88, 54 },
    [TILES.trim] = { 210, 214, 226 },
    [TILES.gate] = { 208, 188, 120 },
    [TILES.banner] = { 194, 98, 196 },
    [TILES.shadow] = { 56, 60, 72 },
}

local function clamp_color(value)
    return math.max(0, math.min(255, math.floor(value + 0.5)))
end

local function cell_key(x, y)
    return x .. ":" .. y
end

local function copy_cells(cells)
    local out = {}
    for i = 1, #cells do
        out[#out + 1] = { cells[i][1], cells[i][2] }
    end
    return out
end

local function rect_cells(width, height)
    local cells = {}
    for y = 0, height - 1 do
        for x = 0, width - 1 do
            cells[#cells + 1] = { x, y }
        end
    end
    return cells
end

local function add_rect(cells, x0, y0, width, height)
    for y = y0, y0 + height - 1 do
        for x = x0, x0 + width - 1 do
            cells[#cells + 1] = { x, y }
        end
    end
end

local function province_cells()
    local cells = {}
    add_rect(cells, 0, 0, 8, 6)
    cells[#cells + 1] = { -1, 2 }
    cells[#cells + 1] = { -1, 3 }
    cells[#cells + 1] = { 8, 1 }
    cells[#cells + 1] = { 8, 2 }
    cells[#cells + 1] = { 8, 3 }
    cells[#cells + 1] = { 3, 6 }
    cells[#cells + 1] = { 4, 6 }
    return cells
end

local function bounds_from_cells(cells)
    local min_x, min_y = math.huge, math.huge
    local max_x, max_y = -math.huge, -math.huge
    for i = 1, #cells do
        local x = cells[i][1]
        local y = cells[i][2]
        min_x = math.min(min_x, x)
        min_y = math.min(min_y, y)
        max_x = math.max(max_x, x)
        max_y = math.max(max_y, y)
    end
    return min_x, min_y, max_x, max_y
end

local function new_config(segment_size)
    local config = lurek.mapblock.newConfig()
    config:setDefaultSegmentSize(segment_size)
    config:setMaxLayers(2)
    return config
end

local function add_shape_positions(grid, cells)
    for i = 1, #cells do
        grid:addPosition(cells[i][1], cells[i][2])
    end
end

local function add_open_sockets(block, cells, edge_type)
    local occupied = {}
    local dirs = {
        { edge = "north", dx = 0, dy = -1 },
        { edge = "east", dx = 1, dy = 0 },
        { edge = "south", dx = 0, dy = 1 },
        { edge = "west", dx = -1, dy = 0 },
    }

    for i = 1, #cells do
        occupied[cell_key(cells[i][1], cells[i][2])] = true
    end

    for i = 1, #cells do
        local x = cells[i][1]
        local y = cells[i][2]
        for j = 1, #dirs do
            local dir = dirs[j]
            if not occupied[cell_key(x + dir.dx, y + dir.dy)] then
                block:setSocket(x, y, dir.edge, edge_type)
            end
        end
    end
end

local function set_all_occupied_tiles(block, layer, gid, segment_tiles)
    local width = block:getWidth()
    local height = block:getHeight()
    for y = 0, height - 1 do
        for x = 0, width - 1 do
            local cell_x = math.floor(x / segment_tiles)
            local cell_y = math.floor(y / segment_tiles)
            if block:isFootprintCell(cell_x, cell_y) then
                block:setTile(layer, x, y, 0, 1, gid)
            end
        end
    end
end

local function make_macro_block(config, spec)
    local bounds_w, bounds_h = 1, 1
    for i = 1, #spec.cells do
        bounds_w = math.max(bounds_w, spec.cells[i][1] + 1)
        bounds_h = math.max(bounds_h, spec.cells[i][2] + 1)
    end
    local block = lurek.mapblock.newBlock(bounds_w, bounds_h, 1, config)
    block:setName(spec.name)
    block:setWeight(spec.weight or 1)
    block:setFootprint(spec.cells)
    add_open_sockets(block, spec.cells, 1)
    set_all_occupied_tiles(block, 0, spec.gid, MACRO_SEGMENT)
    return block
end

local function fill_rect(block, layer, x0, y0, width, height, gid)
    for y = y0, y0 + height - 1 do
        for x = x0, x0 + width - 1 do
            if x >= 0 and y >= 0 and x < block:getWidth() and y < block:getHeight() then
                block:setTile(layer, x, y, 0, 1, gid)
            end
        end
    end
end

local function fill_border(block, layer, gid)
    local width = block:getWidth()
    local height = block:getHeight()
    fill_rect(block, layer, 0, 0, width, 1, gid)
    fill_rect(block, layer, 0, height - 1, width, 1, gid)
    fill_rect(block, layer, 0, 0, 1, height, gid)
    fill_rect(block, layer, width - 1, 0, 1, height, gid)
end

local function fill_checker(block, layer, x0, y0, width, height, gid_a, gid_b)
    for y = 0, height - 1 do
        for x = 0, width - 1 do
            local gid = ((x + y) % 2 == 0) and gid_a or gid_b
            block:setTile(layer, x0 + x, y0 + y, 0, 1, gid)
        end
    end
end

local function fill_cell(block, layer, cell_x, cell_y, gid)
    fill_rect(
        block,
        layer,
        cell_x * DETAIL_SEGMENT,
        cell_y * DETAIL_SEGMENT,
        DETAIL_SEGMENT,
        DETAIL_SEGMENT,
        gid
    )
end

local function for_each_footprint_cell(block, fn)
    local cells_w = math.floor(block:getWidth() / DETAIL_SEGMENT)
    local cells_h = math.floor(block:getHeight() / DETAIL_SEGMENT)
    for cy = 0, cells_h - 1 do
        for cx = 0, cells_w - 1 do
            if block:isFootprintCell(cx, cy) then
                fn(cx, cy)
            end
        end
    end
end

local function fill_footprint_cells(block, layer, gid)
    for_each_footprint_cell(block, function(cx, cy)
        fill_cell(block, layer, cx, cy, gid)
    end)
end

local function fill_footprint_checker(block, layer, gid_a, gid_b)
    for_each_footprint_cell(block, function(cx, cy)
        fill_cell(block, layer, cx, cy, ((cx + cy) % 2 == 0) and gid_a or gid_b)
    end)
end

local function add_road_stripe(block, layer, horizontal, gid)
    local width_tiles = block:getWidth()
    local height_tiles = block:getHeight()
    if horizontal then
        fill_rect(block, layer, 0, math.floor(height_tiles / 2) - 1, width_tiles, 2, gid)
    else
        fill_rect(block, layer, math.floor(width_tiles / 2) - 1, 0, 2, height_tiles, gid)
    end
end

local function paint_cell_borders(block, layer, gid)
    local cells = rect_cells(block:getWidth() / DETAIL_SEGMENT, block:getHeight() / DETAIL_SEGMENT)
    for i = 1, #cells do
        local cx = cells[i][1]
        local cy = cells[i][2]
        if block:isFootprintCell(cx, cy) then
            local tile_x = cx * DETAIL_SEGMENT
            local tile_y = cy * DETAIL_SEGMENT
            fill_rect(block, layer, tile_x, tile_y, DETAIL_SEGMENT, 1, gid)
            fill_rect(block, layer, tile_x, tile_y + DETAIL_SEGMENT - 1, DETAIL_SEGMENT, 1, gid)
            fill_rect(block, layer, tile_x, tile_y, 1, DETAIL_SEGMENT, gid)
            fill_rect(block, layer, tile_x + DETAIL_SEGMENT - 1, tile_y, 1, DETAIL_SEGMENT, gid)
        end
    end
end

local function make_detail_block(config, spec, upper)
    local bounds_w, bounds_h = 1, 1
    for i = 1, #spec.cells do
        bounds_w = math.max(bounds_w, spec.cells[i][1] + 1)
        bounds_h = math.max(bounds_h, spec.cells[i][2] + 1)
    end

    local width_tiles = bounds_w * DETAIL_SEGMENT
    local height_tiles = bounds_h * DETAIL_SEGMENT
    local block = lurek.mapblock.newBlock(width_tiles, height_tiles, 2, config)
    block:setName(upper and (spec.name .. "_upper") or spec.name)
    block:setFootprint(spec.cells)
    add_open_sockets(block, spec.cells, 1)

    if upper then
        if spec.name == "citadel" then
            fill_footprint_cells(block, 0, TILES.brick)
            fill_border(block, 1, TILES.trim)
            add_road_stripe(block, 1, false, TILES.gate)
        elseif spec.name == "academy" then
            fill_footprint_cells(block, 0, TILES.violet)
            paint_cell_borders(block, 1, TILES.trim)
            fill_rect(block, 1, 2, 2, 2, 2, TILES.banner)
        elseif spec.name == "market" then
            fill_footprint_checker(block, 0, TILES.awning, TILES.brick)
            paint_cell_borders(block, 1, TILES.trim)
        elseif spec.name == "outpost" then
            fill_footprint_cells(block, 0, TILES.violet)
            fill_border(block, 1, TILES.trim)
            fill_rect(block, 1, width_tiles - 3, 1, 2, 2, TILES.banner)
        end
    else
        if spec.name == "coast" then
            fill_footprint_cells(block, 0, TILES.water)
            fill_rect(block, 1, 0, height_tiles - 2, width_tiles, 2, TILES.sand)
            fill_rect(block, 1, 1, height_tiles - 3, width_tiles - 2, 1, TILES.road)
        elseif spec.name == "citadel" then
            fill_footprint_cells(block, 0, TILES.grass)
            fill_rect(block, 0, 2, 2, width_tiles - 4, height_tiles - 4, TILES.stone)
            fill_border(block, 1, TILES.wall)
            fill_rect(block, 1, math.floor(width_tiles / 2) - 1, height_tiles - 2, 3, 2, TILES.gate)
        elseif spec.name == "academy" then
            fill_footprint_cells(block, 0, TILES.garden)
            fill_rect(block, 0, 1, 1, width_tiles - 2, math.max(3, height_tiles - 5), TILES.stone)
            fill_rect(block, 1, width_tiles - 4, 1, 3, height_tiles - 4, TILES.roof)
            paint_cell_borders(block, 1, TILES.wall)
        elseif spec.name == "arcade" then
            fill_footprint_cells(block, 0, TILES.timber)
            fill_rect(block, 0, 0, 2, width_tiles, height_tiles - 4, TILES.stone)
            fill_rect(block, 1, 0, 0, width_tiles, 2, TILES.roof)
            fill_rect(block, 1, 0, height_tiles - 2, width_tiles, 2, TILES.roof)
            for x = 2, width_tiles - 3, 4 do
                fill_rect(block, 1, x, math.floor(height_tiles / 2) - 1, 2, 2, TILES.road)
            end
        elseif spec.name == "market" then
            fill_footprint_cells(block, 0, TILES.stone)
            fill_rect(block, 1, 1, 1, width_tiles - 2, 2, TILES.awning)
            fill_rect(block, 1, 1, height_tiles - 3, width_tiles - 2, 2, TILES.awning)
            fill_rect(block, 1, 2, 3, width_tiles - 4, height_tiles - 6, TILES.road)
        elseif spec.name == "outpost" then
            fill_footprint_cells(block, 0, TILES.grass)
            fill_rect(block, 1, 1, 1, width_tiles - 2, 1, TILES.wall)
            fill_rect(block, 1, 1, height_tiles - 2, width_tiles - 2, 1, TILES.wall)
            fill_rect(block, 1, 1, 1, 1, height_tiles - 2, TILES.wall)
            fill_rect(block, 1, width_tiles - 2, 1, 1, height_tiles - 2, TILES.wall)
            fill_rect(block, 1, width_tiles - 3, 1, 2, 2, TILES.banner)
        elseif spec.name == "hall" then
            fill_footprint_cells(block, 0, TILES.stone)
            add_road_stripe(block, 1, block:getWidth() >= block:getHeight(), TILES.road)
            fill_border(block, 1, TILES.wall)
        elseif spec.name == "plaza" then
            fill_footprint_checker(block, 0, TILES.gate, TILES.road)
            fill_border(block, 1, TILES.wall)
        end
    end

    return block
end

local MACRO_SCRIPT_PLAN = {
    { type = "fill_edges", opts = { group = "coast", count = 128 } },
    { type = "place_block", opts = { group = "anchors", block_name = "citadel", x = 1, y = 1 } },
    { type = "place_block", opts = { group = "anchors", block_name = "academy", x = 4, y = 1 } },
    { type = "place_block", opts = { group = "anchors", block_name = "arcade", x = 2, y = 3 } },
    { type = "place_block", opts = { group = "anchors", block_name = "market", x = 5, y = 2 } },
    { type = "place_block", opts = { group = "anchors", block_name = "outpost", x = 0, y = 2, rotation = 3 } },
    { type = "solve_shape", opts = { group = "solver", random_rotation = true, random_mirror = true } },
}

local function build_macro_world(seed)
    local shape = province_cells()
    local bounds = { bounds_from_cells(shape) }
    local config = new_config(MACRO_SEGMENT)
    local gen = lurek.mapblock.newGenerator(config)
    local rules = lurek.mapblock.newRules()
    local grid = lurek.mapblock.newEmptyGrid()
    local coast_group = lurek.mapblock.newGroup("coast")
    local anchor_group = lurek.mapblock.newGroup("anchors")
    local solver_group = lurek.mapblock.newGroup("solver")
    local script = lurek.mapblock.newScript("macro_layout")

    add_shape_positions(grid, shape)
    rules:addCompatible(1, 1)

    coast_group:addBlock(make_macro_block(config, {
        name = "coast",
        cells = { { 0, 0 } },
        weight = 1,
        gid = 1,
    }))

    local anchor_specs = {
        { name = "citadel", cells = rect_cells(3, 2), weight = 1, gid = 4 },
        { name = "academy", cells = { { 0, 0 }, { 1, 0 }, { 0, 1 } }, weight = 1, gid = 10 },
        { name = "arcade", cells = rect_cells(4, 2), weight = 1, gid = 8 },
        { name = "market", cells = rect_cells(2, 2), weight = 1, gid = 11 },
        { name = "outpost", cells = { { 0, 0 }, { 1, 0 }, { 0, 1 } }, weight = 1, gid = 15 },
    }
    local anchor_index = {}
    for i = 1, #anchor_specs do
        anchor_group:addBlock(make_macro_block(config, anchor_specs[i]))
        anchor_index[anchor_specs[i].name] = i - 1
    end

    local solver_specs = {
        { name = "hall", cells = rect_cells(2, 1), weight = 3, gid = 9 },
        { name = "plaza", cells = { { 0, 0 } }, weight = 1, gid = 14 },
    }
    for i = 1, #solver_specs do
        solver_group:addBlock(make_macro_block(config, solver_specs[i]))
    end

    gen:setGrid(grid)
    gen:setRules(rules)
    gen:setSeed(seed)
    gen:addGroup(coast_group)
    gen:addGroup(anchor_group)
    gen:addGroup(solver_group)

    for i = 1, #MACRO_SCRIPT_PLAN do
        local step = MACRO_SCRIPT_PLAN[i]
        local opts = {}
        for key, value in pairs(step.opts) do
            opts[key] = value
        end
        if step.type == "place_block" then
            opts.block_index = anchor_index[opts.block_name]
            opts.block_name = nil
        end
        script:addStep(step.type, opts)
    end

    local result = gen:generate(script)
    local placements = result:getPlacements()
    local macro = {
        bounds = bounds,
        placements = placements,
        cells = {},
        cells_list = copy_cells(shape),
        counts = {},
        transformed_count = 0,
        cell_count = #shape,
        result = result,
    }

    for i = 1, #placements do
        local placement = placements[i]
        macro.counts[placement.block_name] = (macro.counts[placement.block_name] or 0) + 1
        if placement.rotation ~= 0 or placement.mirrored then
            macro.transformed_count = macro.transformed_count + 1
        end
        for j = 1, #placement.cells do
            local cell = placement.cells[j]
            macro.cells[cell_key(cell.x, cell.y)] = {
                x = cell.x,
                y = cell.y,
                block_name = placement.block_name,
                group_name = placement.group_name,
                rotation = placement.rotation,
                mirrored = placement.mirrored,
                color = MACRO_COLORS[placement.block_name] or { 180, 180, 180 },
            }
        end
    end

    return macro
end

local function build_detail_world(seed, macro)
    local config = new_config(DETAIL_SEGMENT)
    local ground_gen = lurek.mapblock.newGenerator(config)
    local upper_gen = lurek.mapblock.newGenerator(config)
    local ground_grid = lurek.mapblock.newEmptyGrid()
    local upper_grid = lurek.mapblock.newEmptyGrid()
    local ground_group = lurek.mapblock.newGroup("ground")
    local upper_group = lurek.mapblock.newGroup("upper")
    local ground_script = lurek.mapblock.newScript("detail_ground")
    local upper_script = lurek.mapblock.newScript("detail_upper")

    add_shape_positions(ground_grid, macro.cells_list)
    add_shape_positions(upper_grid, macro.cells_list)

    local detail_specs = {
        { name = "coast", cells = { { 0, 0 } }, size = "5x5" },
        { name = "citadel", cells = rect_cells(3, 2), size = "15x10" },
        { name = "academy", cells = { { 0, 0 }, { 1, 0 }, { 0, 1 } }, size = "10x10" },
        { name = "arcade", cells = rect_cells(4, 2), size = "20x10" },
        { name = "market", cells = rect_cells(2, 2), size = "10x10" },
        { name = "outpost", cells = { { 0, 0 }, { 1, 0 }, { 0, 1 } }, size = "10x10" },
        { name = "hall", cells = rect_cells(2, 1), size = "10x5" },
        { name = "plaza", cells = { { 0, 0 } }, size = "5x5" },
    }

    local ground_index = {}
    local upper_index = {}
    local block_sizes = {}
    for i = 1, #detail_specs do
        local spec = detail_specs[i]
        ground_group:addBlock(make_detail_block(config, spec, false))
        ground_index[spec.name] = i - 1
        block_sizes[spec.name] = spec.size
        if spec.name == "citadel" or spec.name == "academy" or spec.name == "market" or spec.name == "outpost" then
            upper_group:addBlock(make_detail_block(config, spec, true))
            upper_index[spec.name] = upper_group:getBlockCount() - 1
        end
    end

    ground_gen:setGrid(ground_grid)
    ground_gen:setSeed(seed + 1000)
    ground_gen:addGroup(ground_group)

    upper_gen:setGrid(upper_grid)
    upper_gen:setSeed(seed + 2000)
    upper_gen:addGroup(upper_group)

    for i = 1, #macro.placements do
        local placement = macro.placements[i]
        ground_script:addStep("place_block", {
            group = "ground",
            block_index = ground_index[placement.block_name],
            x = placement.grid_x,
            y = placement.grid_y,
            rotation = placement.rotation,
            mirror = placement.mirrored,
        })
        if upper_index[placement.block_name] ~= nil then
            upper_script:addStep("place_block", {
                group = "upper",
                block_index = upper_index[placement.block_name],
                x = placement.grid_x,
                y = placement.grid_y,
                rotation = placement.rotation,
                mirror = placement.mirrored,
            })
        end
    end

    local ground_result = ground_gen:generate(ground_script)
    local upper_result = upper_gen:generate(upper_script)
    local ground_placements = ground_result:getPlacements()
    local upper_placements = upper_result:getPlacements()
    local placements = {}
    local size_set = {}
    local level_counts = { [0] = #ground_placements, [1] = #upper_placements }
    local upper_count = #upper_placements

    for name, size in pairs(block_sizes) do
        if name ~= "coast" then
            size_set[size] = true
        end
    end

    for i = 1, #ground_placements do
        placements[#placements + 1] = ground_placements[i]
    end
    for i = 1, #upper_placements do
        upper_placements[i].level = 1
        placements[#placements + 1] = upper_placements[i]
    end

    local size_labels = {}
    for size in pairs(size_set) do
        size_labels[#size_labels + 1] = size
    end
    table.sort(size_labels)

    return {
        results = {
            [0] = ground_result,
            [1] = upper_result,
        },
        placements = placements,
        tile_width = ground_result:getWidth(),
        tile_height = ground_result:getHeight(),
        level_count = 2,
        layer_count = math.max(ground_result:getLayerCount(), upper_result:getLayerCount()),
        segment_tiles = DETAIL_SEGMENT,
        block_sizes = block_sizes,
        size_labels = size_labels,
        level_counts = level_counts,
        upper_count = upper_count,
    }
end

local function bfs(world, start_key)
    local queue = { start_key }
    local head = 1
    local dist = { [start_key] = 0 }
    local farthest_key = start_key

    while head <= #queue do
        local key = queue[head]
        head = head + 1
        local cell = world.macro.cells[key]
        local base = dist[key]
        local neighbors = {
            { cell.x + 1, cell.y },
            { cell.x - 1, cell.y },
            { cell.x, cell.y + 1 },
            { cell.x, cell.y - 1 },
        }

        for i = 1, #neighbors do
            local nx = neighbors[i][1]
            local ny = neighbors[i][2]
            local nkey = cell_key(nx, ny)
            if world.macro.cells[nkey] and dist[nkey] == nil and world.macro.cells[nkey].block_name ~= "coast" then
                dist[nkey] = base + 1
                queue[#queue + 1] = nkey
                if dist[nkey] > dist[farthest_key] then
                    farthest_key = nkey
                end
            end
        end
    end

    return dist, farthest_key
end

function M.build(seed)
    local resolved_seed = seed or 41
    local macro = build_macro_world(resolved_seed)
    local detail = build_detail_world(resolved_seed, macro)

    local start_key
    for i = 1, #macro.cells_list do
        local cell = macro.cells[cell_key(macro.cells_list[i][1], macro.cells_list[i][2])]
        if cell and cell.block_name ~= "coast" then
            start_key = cell_key(cell.x, cell.y)
            break
        end
    end

    local _, farthest = bfs({ macro = macro }, start_key)
    local distances = bfs({ macro = macro }, farthest)

    return {
        seed = resolved_seed,
        macro = macro,
        detail = detail,
        bounds = macro.bounds,
        cells = macro.cells,
        cells_list = macro.cells_list,
        counts = macro.counts,
        transformed_count = macro.transformed_count,
        cell_count = macro.cell_count,
        start = macro.cells[start_key],
        goal = macro.cells[farthest],
        optimal_steps = distances[start_key] or 0,
    }
end

function M.can_move(world, x, y)
    local cell = world.macro.cells[cell_key(x, y)]
    return cell ~= nil and cell.block_name ~= "coast"
end

function M.block_summary(world)
    local names = {}
    for name in pairs(world.macro.counts) do
        names[#names + 1] = name
    end
    table.sort(names)

    local lines = {}
    for i = 1, #names do
        lines[#lines + 1] = string.format("%s x%d", names[i], world.macro.counts[names[i]])
    end
    return lines
end

local function result_for_level(world, level)
    return world.detail.results[level]
end

function M.resolve_level_gid(world, level, x, y)
    local result = result_for_level(world, level)
    if not result then
        return 0
    end
    for layer = result:getLayerCount() - 1, 0, -1 do
        local gid = result:getGid(0, layer, x, y, 0)
        if gid ~= 0 then
            return gid
        end
    end
    return 0
end

function M.tile_color(level, gid)
    local base = TILE_COLORS[gid] or { 220, 92, 220 }
    local tint = (level == 1) and 1.06 or 1.0
    return {
        clamp_color(base[1] * tint),
        clamp_color(base[2] * tint),
        clamp_color(base[3] * tint),
    }
end

function M.render_level_image(world, level, tile_scale)
    local width = world.detail.tile_width * tile_scale
    local height = world.detail.tile_height * tile_scale
    local img = lurek.image.newImageData(width, height)
    img:fill(14, 16, 22, 255)

    for y = 0, world.detail.tile_height - 1 do
        for x = 0, world.detail.tile_width - 1 do
            local gid = M.resolve_level_gid(world, level, x, y)
            local color = M.tile_color(level, gid)
            local px = x * tile_scale
            local py = y * tile_scale
            img:drawRect(px, py, tile_scale, tile_scale, color[1], color[2], color[3], 255)
            if tile_scale >= 4 and gid ~= 0 then
                img:drawRect(px + 1, py + 1, tile_scale - 2, tile_scale - 2, clamp_color(color[1] * 0.9), clamp_color(color[2] * 0.9), clamp_color(color[3] * 0.9), 255)
            end
        end
    end

    local min_x = world.macro.bounds[1]
    local min_y = world.macro.bounds[2]
    for i = 1, #world.macro.cells_list do
        local cx = world.macro.cells_list[i][1]
        local cy = world.macro.cells_list[i][2]
        local px = (cx - min_x) * world.detail.segment_tiles * tile_scale
        local py = (cy - min_y) * world.detail.segment_tiles * tile_scale
        img:drawRect(px, py, world.detail.segment_tiles * tile_scale, 1, 235, 238, 244, 255)
        img:drawRect(px, py + world.detail.segment_tiles * tile_scale - 1, world.detail.segment_tiles * tile_scale, 1, 235, 238, 244, 255)
        img:drawRect(px, py, 1, world.detail.segment_tiles * tile_scale, 235, 238, 244, 255)
        img:drawRect(px + world.detail.segment_tiles * tile_scale - 1, py, 1, world.detail.segment_tiles * tile_scale, 235, 238, 244, 255)
    end

    return img
end

function M.render_pipeline_image(world, macro_scale, tile_scale)
    local level0 = M.render_level_image(world, 0, tile_scale)
    local level1 = M.render_level_image(world, 1, tile_scale)
    local macro_w = (world.macro.bounds[3] - world.macro.bounds[1] + 1) * macro_scale
    local macro_h = (world.macro.bounds[4] - world.macro.bounds[2] + 1) * macro_scale
    local width = macro_w + level0:getWidth() + level1:getWidth() + 48
    local height = math.max(macro_h, level0:getHeight(), level1:getHeight()) + 24
    local img = lurek.image.newImageData(width, height)
    img:fill(12, 14, 20, 255)

    local macro_x = 12
    local macro_y = 12
    local level0_x = macro_x + macro_w + 12
    local level1_x = level0_x + level0:getWidth() + 12

    for i = 1, #world.macro.cells_list do
        local cx = world.macro.cells_list[i][1]
        local cy = world.macro.cells_list[i][2]
        local cell = world.macro.cells[cell_key(cx, cy)]
        local color = (cell and cell.color) or { 48, 52, 64 }
        local px = macro_x + (cx - world.macro.bounds[1]) * macro_scale
        local py = macro_y + (cy - world.macro.bounds[2]) * macro_scale
        img:drawRect(px, py, macro_scale - 1, macro_scale - 1, color[1], color[2], color[3], 255)
    end

    img:blit(level0, level0_x, 12)
    img:blit(level1, level1_x, 12)
    return img
end

return M
