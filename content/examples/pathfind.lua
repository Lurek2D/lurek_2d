-- content/examples/pathfind.lua
-- Auto-generated from content/examples2/pathfind_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/pathfind.lua

--- Pathfinding Module Part 1: grid pathfinding basics (LPathGrid, LNavGrid)


--@api: lurek.pathfind.newNavGridFromField
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local field = lurek.tilefield.new({ width = 6, height = 6 })
    field:applyProfile(3, 3, 1, "wall")
    local grid = lurek.pathfind.newNavGridFromField(field, { level = 1, channel = "move" })
    local blocked = grid:isBlocked(3, 3)
    local width = grid:getWidth()
    pathfind_log("field navgrid width=" .. width .. " blocked=" .. tostring(blocked))
end

--@api: lurek.pathfind.rangeMapFromField
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local field = lurek.tilefield.new({ width = 6, height = 6 })
    field:setCost(2, 1, 1, "move", 2)
    local range = lurek.pathfind.rangeMapFromField(field, { origin = { x = 1, y = 1, z = 1 }, budget = 4 })
    local count = #range.cells
    local width = range.width
    pathfind_log("field range width=" .. width .. " cells=" .. count)
end


--@api: lurek.pathfind.newPathGrid
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.pathfind.newPathGrid(20, 15, 32)
    grid:setWalkable(10, 8, false)
    local width = grid:getWidth()
    local height = grid:getHeight()
    local cell_size = grid:getCellSize()
    local chokepoint_open = grid:isWalkable(10, 7)

    pathfind_log("patrol grid = " .. width .. "x" .. height)
    pathfind_log("patrol cell size = " .. cell_size)
    pathfind_log("approach tile walkable = " .. tostring(chokepoint_open))
end

--@api: LPathGrid:setWalkable
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.pathfind.newPathGrid(20, 15, 32)
    grid:setWalkable(6, 7, false)
    grid:setWalkable(5, 5, false)
    local blocked_gate = grid:isWalkable(5, 5)
    local flank_route = grid:isWalkable(5, 6)
    local guard_post = grid:isWalkable(6, 7)

    pathfind_log("main gate open = " .. tostring(blocked_gate))
    pathfind_log("flank route open = " .. tostring(flank_route))
    pathfind_log("guard post open = " .. tostring(guard_post))
end

--@api: LPathGrid:isWalkable
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.pathfind.newPathGrid(20, 15, 32)
    grid:setWalkable(4, 4, false)
    grid:setWalkable(4, 5, true)
    local tower_cell = grid:isWalkable(4, 4)
    local stairs_cell = grid:isWalkable(4, 5)
    local courtyard_cell = grid:isWalkable(5, 5)

    pathfind_log("tower cell walkable = " .. tostring(tower_cell))
    pathfind_log("stairs cell walkable = " .. tostring(stairs_cell))
    pathfind_log("courtyard cell walkable = " .. tostring(courtyard_cell))
end

--@api: LPathGrid:setCost
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.pathfind.newPathGrid(10, 10, 16)
    grid:setCost(3, 2, 2)
    grid:setCost(3, 3, 5)
    local mud_cost = grid:getCost(3, 3)
    local road_cost = grid:getCost(3, 2)
    local plain_cost = grid:getCost(3, 4)

    pathfind_log("mud tile cost = " .. mud_cost)
    pathfind_log("road tile cost = " .. road_cost)
    pathfind_log("plain tile cost = " .. plain_cost)
end

--@api: LPathGrid:getCost
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.pathfind.newPathGrid(10, 10, 16)
    grid:setCost(6, 1, 1.5)
    grid:setCost(6, 2, 2.5)
    local bridge_cost = grid:getCost(6, 2)
    local lane_cost = grid:getCost(6, 1)
    local base_cost = grid:getCost(1, 1)

    pathfind_log("bridge tile cost = " .. bridge_cost)
    pathfind_log("lane tile cost = " .. lane_cost)
    pathfind_log("default tile cost = " .. base_cost)
end

--@api: LPathGrid:findPath
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.pathfind.newPathGrid(10, 10, 32)

    for y = 1, 10 do
        grid:setWalkable(5, y, false)
    end
    grid:setWalkable(5, 8, true)

    local path = grid:findPath(1, 1, 10, 10)
    if path then
        example_print_log("steps = " .. #path)
        example_print_log("first = " .. path[1].x .. "," .. path[1].y)
        example_print_log("last = " .. path[#path].x .. "," .. path[#path].y)
    else
        example_print_log("steps = 0")
    end
end

--@api: LPathGrid:findPathSmoothed
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.pathfind.newPathGrid(20, 20, 16)

    grid:setWalkable(10, 5, false)
    grid:setWalkable(10, 6, false)
    grid:setWalkable(10, 7, false)

    local path = grid:findPathSmoothed(1, 5, 20, 5)
    if path then
        example_print_log("points = " .. #path)
        example_print_log("first = " .. path[1].x .. "," .. path[1].y)
        example_print_log("last = " .. path[#path].x .. "," .. path[#path].y)
    else
        example_print_log("points = 0")
    end
end

--@api: LPathGrid:type
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.pathfind.newPathGrid(5, 5, 32)
    grid:setWalkable(3, 3, false)
    local type_name = grid:type()
    local width = grid:getWidth()
    local height = grid:getHeight()
    local blocked_center = grid:isWalkable(3, 3)

    pathfind_log("path grid type = " .. type_name)
    pathfind_log("training grid = " .. width .. "x" .. height)
    pathfind_log("center walkable = " .. tostring(blocked_center))
end

--@api: LPathGrid:typeOf
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.pathfind.newPathGrid(5, 5, 32)
    grid:setCost(2, 2, 3)
    local is_path_grid = grid:typeOf("LPathGrid")
    local is_object = grid:typeOf("LObject")
    local is_nav_grid = grid:typeOf("LNavGrid")

    pathfind_log("matches LPathGrid = " .. tostring(is_path_grid))
    pathfind_log("matches LObject = " .. tostring(is_object))
    pathfind_log("matches LNavGrid = " .. tostring(is_nav_grid))
end

--@api: lurek.pathfind.newNavGrid
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local nav = lurek.pathfind.newNavGrid(50, 50)
    local w, h = nav:getDimensions()
    nav:setBlocked(25, 25, true)
    local chunk = nav:getChunkSize()
    local center_blocked = nav:isBlocked(25, 25)

    pathfind_log("city nav dims = " .. w .. "x" .. h)
    pathfind_log("default chunk = " .. chunk)
    pathfind_log("market center blocked = " .. tostring(center_blocked))
end

--@api: LNavGrid:setBlocked
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local nav = lurek.pathfind.newNavGrid(30, 30)
    nav:fill(1)
    nav:setBlocked(10, 10, true)
    nav:setBlocked(10, 11, true)
    local blocked_gate = nav:isBlocked(10, 10)
    local blocked_corridor = nav:isBlocked(10, 11)
    local detour_open = nav:isWalkable(11, 10)

    pathfind_log("main gate blocked = " .. tostring(blocked_gate))
    pathfind_log("corridor blocked = " .. tostring(blocked_corridor))
    pathfind_log("detour open = " .. tostring(detour_open))
end

--@api: LNavGrid:isBlocked
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local nav = lurek.pathfind.newNavGrid(30, 30)
    nav:fill(1)
    nav:setBlocked(12, 12, true)
    nav:setBlocked(13, 12, true)
    local barricade = nav:isBlocked(12, 12)
    local second_barricade = nav:isBlocked(13, 12)
    local alley = nav:isBlocked(12, 13)

    pathfind_log("barricade = " .. tostring(barricade))
    pathfind_log("second barricade = " .. tostring(second_barricade))
    pathfind_log("alley blocked = " .. tostring(alley))
end

--@api: LNavGrid:setCost
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local nav = lurek.pathfind.newNavGrid(30, 30)
    nav:fill(1)
    nav:setCost(5, 5, 200)
    nav:setCost(5, 6, 25)
    local swamp_cost = nav:getCost(5, 5)
    local path_cost = nav:getCost(5, 6)
    local swamp_blocked = nav:isBlocked(5, 5)

    pathfind_log("swamp cost = " .. swamp_cost)
    pathfind_log("trail cost = " .. path_cost)
    pathfind_log("swamp blocked = " .. tostring(swamp_blocked))
end

--@api: LNavGrid:getCost
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local nav = lurek.pathfind.newNavGrid(30, 30)
    nav:fill(1)
    nav:setCost(7, 8, 4)
    nav:setCost(8, 8, 7)
    local shallow_water = nav:getCost(7, 8)
    local deep_water = nav:getCost(8, 8)
    local dry_ground = nav:getCost(1, 1)

    pathfind_log("shallow water cost = " .. shallow_water)
    pathfind_log("deep water cost = " .. deep_water)
    pathfind_log("dry ground cost = " .. dry_ground)
end

--@api: LNavGrid:isWalkable
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)
    nav:setBlocked(6, 6, true)

    example_print_log("walkable_1x1 = " .. tostring(nav:isWalkable(5, 5)))
    example_print_log("walkable_blocked = " .. tostring(nav:isWalkable(6, 6)))
    example_print_log("walkable_2x2 = " .. tostring(nav:isWalkable(5, 5, 2)))
end

--@api: LNavGrid:fill
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local nav = lurek.pathfind.newNavGrid(20, 20)
    nav:fill(3)
    nav:setCost(10, 10, 1)
    local border_cost = nav:getCost(1, 1)
    local far_corner_cost = nav:getCost(20, 20)
    local plaza_cost = nav:getCost(10, 10)

    pathfind_log("default patrol cost = " .. border_cost)
    pathfind_log("far corner cost = " .. far_corner_cost)
    pathfind_log("plaza override cost = " .. plaza_cost)
end

--@api: LNavGrid:fillRect
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fillRect(5, 5, 5, 5, 0)

    example_print_log("blocked_5_5 = " .. tostring(nav:isBlocked(5, 5)))
    example_print_log("blocked_10_10 = " .. tostring(nav:isBlocked(10, 10)))
    example_print_log("blocked_11_11 = " .. tostring(nav:isBlocked(11, 11)))
end

--@api: LNavGrid:setDiagonalMode
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local nav = lurek.pathfind.newNavGrid(10, 10)
    nav:setDiagonalMode("always")
    nav:setBlocked(5, 5, true)
    local mode = nav:getDiagonalMode()
    local direct_corner = nav:isWalkable(4, 4)

    pathfind_log("scout diagonal mode = " .. mode)
    pathfind_log("corner tile open = " .. tostring(direct_corner))
    pathfind_log("blocked pivot = " .. tostring(nav:isBlocked(5, 5)))
end

--@api: LNavGrid:getDiagonalMode
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local nav = lurek.pathfind.newNavGrid(10, 10)
    nav:setDiagonalMode("nocornercut")
    nav:setBlocked(4, 5, true)
    local mode = nav:getDiagonalMode()
    local blocked_neighbor = nav:isBlocked(4, 5)

    pathfind_log("formation diagonal mode = " .. mode)
    pathfind_log("blocked neighbor = " .. tostring(blocked_neighbor))
    pathfind_log("origin walkable = " .. tostring(nav:isWalkable(1, 1)))
end

--@api: LNavGrid:setChunkSize
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local nav = lurek.pathfind.newNavGrid(100, 100)
    nav:setChunkSize(16)
    nav:rebuildAbstract()
    nav:setBlocked(40, 40, true)
    local chunk_size = nav:getChunkSize()
    local blocked_hub = nav:isBlocked(40, 40)

    pathfind_log("hpa chunk size = " .. chunk_size)
    pathfind_log("blocked logistics hub = " .. tostring(blocked_hub))
    pathfind_log("nav width = " .. nav:getWidth())
end

--@api: LNavGrid:getChunkSize
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local nav = lurek.pathfind.newNavGrid(100, 100)
    nav:setChunkSize(12)
    nav:setBlocked(60, 60, true)
    local chunk_size = nav:getChunkSize()
    local dimensions = nav:getWidth() .. "x" .. nav:getHeight()

    pathfind_log("chunk size = " .. chunk_size)
    pathfind_log("sector dims = " .. dimensions)
    pathfind_log("warehouse blocked = " .. tostring(nav:isBlocked(60, 60)))
end

--@api: LNavGrid:rebuildAbstract
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local nav = lurek.pathfind.newNavGrid(64, 64)

    nav:setChunkSize(8)
    nav:rebuildAbstract()

    example_print_log("chunk = " .. nav:getChunkSize())
    example_print_log("blocked_1_1 = " .. tostring(nav:isBlocked(1, 1)))
end

--@api: LNavGrid:findHpaPath
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local nav = lurek.pathfind.newNavGrid(16, 16)
    nav:setChunkSize(4)
    nav:rebuildAbstract()
    local path = nav:findHpaPath(1, 1, 16, 16, 1)
    example_print_log("hpa path exists = " .. tostring(path ~= nil))
    example_print_log("hpa path len = " .. tostring(path and #path or 0))
end

--@api: LNavGrid:setDirty
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local nav = lurek.pathfind.newNavGrid(50, 50)

    nav:setChunkSize(10)
    nav:rebuildAbstract()
    nav:setBlocked(25, 25, true)
    nav:setDirty(20, 20, 10, 10)
    nav:rebuildAbstract()

    example_print_log("blocked_25_25 = " .. tostring(nav:isBlocked(25, 25)))
    example_print_log("chunk = " .. nav:getChunkSize())
end

--@api: LNavGrid:clearDirty
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local nav = lurek.pathfind.newNavGrid(50, 50)

    nav:setChunkSize(10)
    nav:setDirty(20, 20, 10, 10)
    nav:clearDirty()
    nav:rebuildAbstract()

    example_print_log("chunk = " .. nav:getChunkSize())
end

--@api: LNavGrid:saveToString
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local nav = lurek.pathfind.newNavGrid(10, 10)

    nav:setBlocked(5, 5, true)
    nav:setCost(3, 3, 9)

    local data = nav:saveToString()

    example_print_log("bytes = " .. #data)
    example_print_log("blocked_5_5 = " .. tostring(nav:isBlocked(5, 5)))
end

--@api: LNavGrid:loadFromString
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local nav = lurek.pathfind.newNavGrid(10, 10)

    nav:setBlocked(5, 5, true)
    nav:setCost(3, 3, 9)

    local data = nav:saveToString()
    local nav2 = lurek.pathfind.newNavGrid(10, 10)
    nav2:loadFromString(data)

    example_print_log("blocked_5_5 = " .. tostring(nav2:isBlocked(5, 5)))
    example_print_log("cost_3_3 = " .. nav2:getCost(3, 3))
end

--@api: LNavGrid:type
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local nav = lurek.pathfind.newNavGrid(5, 5)
    nav:setCost(3, 3, 9)
    local type_name = nav:type()
    local dims = nav:getWidth() .. "x" .. nav:getHeight()
    local center_cost = nav:getCost(3, 3)

    pathfind_log("nav grid type = " .. type_name)
    pathfind_log("debug dims = " .. dims)
    pathfind_log("center cost = " .. center_cost)
end

--@api: LNavGrid:typeOf
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local nav = lurek.pathfind.newNavGrid(5, 5)
    nav:setBlocked(2, 3, true)
    local is_nav_grid = nav:typeOf("LNavGrid")
    local is_object = nav:typeOf("LObject")
    local is_path_grid = nav:typeOf("LPathGrid")

    pathfind_log("matches LNavGrid = " .. tostring(is_nav_grid))
    pathfind_log("matches LObject = " .. tostring(is_object))
    pathfind_log("matches LPathGrid = " .. tostring(is_path_grid))
end

--- Pathfinding Module Part 2: navmesh, hex grid, JPS grid

--@api: lurek.pathfind.newNavMesh
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mesh = lurek.pathfind.newNavMesh()
    local id1 = mesh:addPolygon({
        { x = 0, y = 0 },
        { x = 100, y = 0 },
        { x = 50, y = 80 },
    })
    local id2 = mesh:addPolygon({
        { x = 50, y = 80 },
        { x = 100, y = 0 },
        { x = 150, y = 80 },
    })

    example_print_log("polygons = " .. mesh:getPolygonCount())
    example_print_log("ids = " .. id1 .. "," .. id2)
end

--@api: LNavMesh:addPolygon
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mesh = lurek.pathfind.newNavMesh()
    local id = mesh:addPolygon({
        { x = 0, y = 0 },
        { x = 60, y = 0 },
        { x = 30, y = 45 },
    })

    example_print_log("polygon_id = " .. id)
    example_print_log("polygon_count = " .. mesh:getPolygonCount())
end

--@api: LNavMesh:connectPolygons
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mesh = lurek.pathfind.newNavMesh()
    local a = mesh:addPolygon({
        { x = 0, y = 0 },
        { x = 50, y = 0 },
        { x = 25, y = 40 },
    })
    local b = mesh:addPolygon({
        { x = 50, y = 0 },
        { x = 100, y = 0 },
        { x = 75, y = 40 },
    })
    local c = mesh:addPolygon({
        { x = 25, y = 40 },
        { x = 75, y = 40 },
        { x = 50, y = 80 },
    })
    local ab = mesh:connectPolygons(a, b, true)
    local bc = mesh:connectPolygons(b, c, false)

    example_print_log("connected_ab = " .. tostring(ab))
    example_print_log("connected_bc = " .. tostring(bc))
    example_print_log("polygon_count = " .. mesh:getPolygonCount())
end

--@api: LNavMesh:findPath
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mesh = lurek.pathfind.newNavMesh()
    local p1 = mesh:addPolygon({
        { x = 0, y = 0 },
        { x = 100, y = 0 },
        { x = 100, y = 100 },
        { x = 0, y = 100 },
    })
    local p2 = mesh:addPolygon({
        { x = 100, y = 0 },
        { x = 200, y = 0 },
        { x = 200, y = 100 },
        { x = 100, y = 100 },
    })
    local p3 = mesh:addPolygon({
        { x = 200, y = 0 },
        { x = 300, y = 0 },
        { x = 300, y = 100 },
        { x = 200, y = 100 },
    })

    mesh:connectPolygons(p1, p2, true)
    mesh:connectPolygons(p2, p3, true)

    local path = mesh:findPath(10, 50, 290, 50)
    if path then
        example_print_log("waypoints = " .. #path)
        example_print_log("first = " .. path[1].x .. "," .. path[1].y)
        example_print_log("last = " .. path[#path].x .. "," .. path[#path].y)
    else
        example_print_log("waypoints = 0")
    end
end

--@api: LNavMesh:type
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mesh = lurek.pathfind.newNavMesh()
    mesh:addPolygon({
        { x = 0, y = 0 },
        { x = 64, y = 0 },
        { x = 32, y = 48 },
    })
    local type_name = mesh:type()
    local polygon_count = mesh:getPolygonCount()

    pathfind_log("nav mesh type = " .. type_name)
    pathfind_log("triangle count = " .. polygon_count)
    pathfind_log("mesh ready for corridor routing = " .. tostring(polygon_count > 0))
end

--@api: LNavMesh:typeOf
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mesh = lurek.pathfind.newNavMesh()
    mesh:addPolygon({
        { x = 0, y = 0 },
        { x = 32, y = 0 },
        { x = 16, y = 24 },
    })
    local is_nav_mesh = mesh:typeOf("LNavMesh")
    local is_object = mesh:typeOf("LObject")
    local is_goal_map = mesh:typeOf("LGoalMap")

    pathfind_log("matches LNavMesh = " .. tostring(is_nav_mesh))
    pathfind_log("matches LObject = " .. tostring(is_object))
    pathfind_log("matches LGoalMap = " .. tostring(is_goal_map))
end

--@api: lurek.pathfind.newHexGrid
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local hex = lurek.pathfind.newHexGrid(12, 10, "flat")

    hex:setBlocked(5, 5, true)
    hex:setBlocked(6, 5, true)

    example_print_log("blocked_5_5 = " .. tostring(hex:isBlocked(5, 5)))
    example_print_log("blocked_1_1 = " .. tostring(hex:isBlocked(1, 1)))
end

--@api: LHexGrid:setBlocked
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local hex = lurek.pathfind.newHexGrid(12, 10, "flat")

    hex:setBlocked(5, 5, true)
    hex:setBlocked(6, 5, true)

    example_print_log("blocked_5_5 = " .. tostring(hex:isBlocked(5, 5)))
    example_print_log("blocked_6_5 = " .. tostring(hex:isBlocked(6, 5)))
end

--@api: LHexGrid:isBlocked
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local hex = lurek.pathfind.newHexGrid(12, 10, "flat")
    hex:setBlocked(4, 4, true)
    hex:setBlocked(5, 4, true)
    local ridge = hex:isBlocked(4, 4)
    local ridge_neighbor = hex:isBlocked(5, 4)
    local open_hex = hex:isBlocked(4, 5)

    pathfind_log("ridge blocked = " .. tostring(ridge))
    pathfind_log("ridge neighbor blocked = " .. tostring(ridge_neighbor))
    pathfind_log("southern hex blocked = " .. tostring(open_hex))
end

--@api: LHexGrid:setCost
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local hex = lurek.pathfind.newHexGrid(8, 8)

    hex:setCost(4, 4, 4)
    hex:setCost(5, 4, 4)

    local reachable = hex:rangeOfMovement(4, 4, 4)
    example_print_log("reachable = " .. #reachable)
    if #reachable > 0 then
        example_print_log("first = " .. reachable[1].col .. "," .. reachable[1].row)
    end
end

--@api: LHexGrid:findPath
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local hex = lurek.pathfind.newHexGrid(10, 10)

    hex:setBlocked(5, 3, true)
    hex:setBlocked(5, 4, true)
    hex:setBlocked(5, 5, true)

    local path = hex:findPath(1, 5, 10, 5)
    if path then
        example_print_log("steps = " .. #path)
        example_print_log("first = " .. path[1].col .. "," .. path[1].row)
        example_print_log("last = " .. path[#path].col .. "," .. path[#path].row)
    else
        example_print_log("steps = 0")
    end
end

--@api: LHexGrid:distance
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local hex = lurek.pathfind.newHexGrid(10, 10)
    hex:setBlocked(3, 3, true)
    local flank_distance = hex:distance(1, 1, 5, 5)
    local same_cell_distance = hex:distance(1, 1, 1, 1)
    local scout_distance = hex:distance(2, 4, 7, 4)

    pathfind_log("flank distance = " .. flank_distance)
    pathfind_log("same cell distance = " .. same_cell_distance)
    pathfind_log("frontline distance = " .. scout_distance)
end

--@api: LHexGrid:fieldOfView
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local hex = lurek.pathfind.newHexGrid(15, 15)

    hex:setBlocked(8, 8, true)

    local visible = hex:fieldOfView(7, 7, 3)
    example_print_log("visible = " .. #visible)
    if #visible > 0 then
        example_print_log("first = " .. visible[1].col .. "," .. visible[1].row)
    end
end

--@api: LHexGrid:rangeOfMovement
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local hex = lurek.pathfind.newHexGrid(12, 12)

    hex:setCost(6, 6, 3)

    local reachable = hex:rangeOfMovement(6, 6, 4)
    example_print_log("reachable = " .. #reachable)
    if #reachable > 0 then
        example_print_log("first = " .. reachable[1].col .. "," .. reachable[1].row)
    end
end

--@api: LHexGrid:type
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local hex = lurek.pathfind.newHexGrid(5, 5, "pointy")
    hex:setCost(3, 3, 2)
    local type_name = hex:type()
    local reachable = hex:rangeOfMovement(3, 3, 3)

    pathfind_log("hex grid type = " .. type_name)
    pathfind_log("reachable cells = " .. #reachable)
    pathfind_log("center blocked = " .. tostring(hex:isBlocked(3, 3)))
end

--@api: LHexGrid:typeOf
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local hex = lurek.pathfind.newHexGrid(5, 5, "pointy")
    hex:setBlocked(2, 2, true)
    local is_hex_grid = hex:typeOf("LHexGrid")
    local is_object = hex:typeOf("LObject")
    local is_jps_grid = hex:typeOf("LJpsGrid")

    pathfind_log("matches LHexGrid = " .. tostring(is_hex_grid))
    pathfind_log("matches LObject = " .. tostring(is_object))
    pathfind_log("matches LJpsGrid = " .. tostring(is_jps_grid))
end

--@api: lurek.pathfind.newJpsGrid
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local jps = lurek.pathfind.newJpsGrid(30, 30)

    jps:setBlocked(15, 10, true)
    jps:setBlocked(15, 11, true)
    jps:setBlocked(15, 12, true)

    example_print_log("blocked_15_10 = " .. tostring(jps:isBlocked(15, 10)))
    example_print_log("blocked_1_1 = " .. tostring(jps:isBlocked(1, 1)))
end

--@api: LJpsGrid:setBlocked
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local jps = lurek.pathfind.newJpsGrid(30, 30)

    jps:setBlocked(15, 10, true)
    jps:setBlocked(15, 11, true)
    jps:setBlocked(15, 12, true)

    example_print_log("blocked_15_10 = " .. tostring(jps:isBlocked(15, 10)))
    example_print_log("blocked_15_12 = " .. tostring(jps:isBlocked(15, 12)))
end

--@api: LJpsGrid:isBlocked
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local jps = lurek.pathfind.newJpsGrid(30, 30)
    jps:setBlocked(9, 9, true)
    jps:setBlocked(10, 9, true)
    local wall_center = jps:isBlocked(9, 9)
    local wall_neighbor = jps:isBlocked(10, 9)
    local lane_open = jps:isBlocked(9, 10)

    pathfind_log("wall center blocked = " .. tostring(wall_center))
    pathfind_log("wall neighbor blocked = " .. tostring(wall_neighbor))
    pathfind_log("lane blocked = " .. tostring(lane_open))
end

--@api: LJpsGrid:findPath
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local jps = lurek.pathfind.newJpsGrid(50, 50)

    for y = 10, 40 do
        jps:setBlocked(25, y, true)
    end
    jps:setBlocked(25, 30, false)

    local path = jps:findPath(1, 25, 50, 25)
    if path then
        example_print_log("points = " .. #path)
        example_print_log("first = " .. path[1].x .. "," .. path[1].y)
        example_print_log("last = " .. path[#path].x .. "," .. path[#path].y)
    else
        example_print_log("points = 0")
    end
end

--@api: LJpsGrid:type
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local jps = lurek.pathfind.newJpsGrid(5, 5)
    jps:setBlocked(3, 3, true)
    local type_name = jps:type()
    local blocked_center = jps:isBlocked(3, 3)
    local path = jps:findPath(1, 1, 5, 5)

    pathfind_log("jps grid type = " .. type_name)
    pathfind_log("center blocked = " .. tostring(blocked_center))
    pathfind_log("corner route nodes = " .. tostring(path and #path or 0))
end

--@api: LJpsGrid:typeOf
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local jps = lurek.pathfind.newJpsGrid(5, 5)
    jps:setBlocked(2, 2, true)
    local is_jps_grid = jps:typeOf("LJpsGrid")
    local is_object = jps:typeOf("LObject")
    local is_hex_grid = jps:typeOf("LHexGrid")

    pathfind_log("matches LJpsGrid = " .. tostring(is_jps_grid))
    pathfind_log("matches LObject = " .. tostring(is_object))
    pathfind_log("matches LHexGrid = " .. tostring(is_hex_grid))
end

--- Pathfinding Module Part 3: flow fields, AI flow fields, unit pathfinder

--@api: lurek.pathfind.newFlowField
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)
    nav:setBlocked(10, 5, true)
    nav:setBlocked(10, 6, true)
    nav:setBlocked(10, 7, true)

    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(20, 10)

    example_print_log("calculated = " .. tostring(ff:isCalculated()))
    example_print_log("targets = " .. #ff:getTargets())
end

--@api: LFlowField:calculate
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)

    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(20, 10)

    example_print_log("calculated = " .. tostring(ff:isCalculated()))
    example_print_log("targets = " .. #ff:getTargets())
end

--@api: LFlowField:getDirection
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local nav = lurek.pathfind.newNavGrid(10, 10)

    nav:fill(1)

    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(10, 10)

    local dx, dy = ff:getDirection(1, 1)
    example_print_log("dir = " .. dx .. "," .. dy)
    example_print_log("angle = " .. ff:getDirectionAngle(1, 1))
    example_print_log("cost = " .. ff:getCostToTarget(1, 1))
end

--@api: LFlowField:getDirectionAngle
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local nav = lurek.pathfind.newNavGrid(10, 10)

    nav:fill(1)

    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(10, 10)

    example_print_log("angle = " .. ff:getDirectionAngle(1, 1))
    example_print_log("cost = " .. ff:getCostToTarget(1, 1))
end

--@api: LFlowField:getCostToTarget
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local nav = lurek.pathfind.newNavGrid(10, 10)

    nav:fill(1)

    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(10, 10)

    local dx, dy = ff:getDirection(1, 1)
    example_print_log("dir = " .. dx .. "," .. dy)
    example_print_log("cost = " .. ff:getCostToTarget(1, 1))
end

--@api: LFlowField:calculateMulti
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local nav = lurek.pathfind.newNavGrid(15, 15)

    nav:fill(1)

    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculateMulti({
        { x = 5, y = 5 },
        { x = 10, y = 10 },
    })

    local targets = ff:getTargets()
    example_print_log("targets = " .. #targets)
    example_print_log("first = " .. targets[1].x .. "," .. targets[1].y)
    example_print_log("last = " .. targets[#targets].x .. "," .. targets[#targets].y)
end

--@api: LFlowField:getTargets
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local nav = lurek.pathfind.newNavGrid(15, 15)

    nav:fill(1)

    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculateMulti({
        { x = 4, y = 4 },
        { x = 12, y = 12 },
    })

    local targets = ff:getTargets()
    example_print_log("targets = " .. #targets)
    example_print_log("first = " .. targets[1].x .. "," .. targets[1].y)
end

--@api: LFlowField:steer
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local nav = lurek.pathfind.newNavGrid(10, 10)

    nav:fill(1)

    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(10, 10)

    local vx, vy = ff:steer(50, 50, 100, 32, 32)
    example_print_log("velocity = " .. vx .. "," .. vy)
end

--@api: LFlowField:type
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local nav = lurek.pathfind.newNavGrid(5, 5)
    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(5, 5)
    local type_name = ff:type()
    local calculated = ff:isCalculated()
    local targets = ff:getTargets()

    pathfind_log("flow field type = " .. type_name)
    pathfind_log("calculated = " .. tostring(calculated))
    pathfind_log("target count = " .. #targets)
end

--@api: LFlowField:typeOf
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local nav = lurek.pathfind.newNavGrid(5, 5)
    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(4, 4)
    local is_flow_field = ff:typeOf("LFlowField")
    local is_object = ff:typeOf("LObject")
    local is_ai_flow_field = ff:typeOf("LAIFlowField")

    pathfind_log("matches LFlowField = " .. tostring(is_flow_field))
    pathfind_log("matches LObject = " .. tostring(is_object))
    pathfind_log("matches LAIFlowField = " .. tostring(is_ai_flow_field))
end

--@api: lurek.pathfind.newPathFlowField
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.pathfind.newPathGrid(15, 15, 32)
    local aiff = lurek.pathfind.newPathFlowField(grid)

    aiff:setGoal(10, 10)

    local gx, gy = aiff:getGoal()
    example_print_log("dims = " .. aiff:getWidth() .. "x" .. aiff:getHeight())
    example_print_log("has_goal = " .. tostring(aiff:hasGoal()))
    example_print_log("goal = " .. gx .. "," .. gy)
end

--@api: LAIFlowField:setGoal
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.pathfind.newPathGrid(15, 15, 32)
    local aiff = lurek.pathfind.newPathFlowField(grid)

    aiff:setGoal(10, 10)

    local gx, gy = aiff:getGoal()
    example_print_log("has_goal = " .. tostring(aiff:hasGoal()))
    example_print_log("goal = " .. gx .. "," .. gy)
end

--@api: LAIFlowField:getGoal
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.pathfind.newPathGrid(15, 15, 32)
    local aiff = lurek.pathfind.newPathFlowField(grid)

    aiff:setGoal(10, 10)

    local gx, gy = aiff:getGoal()
    example_print_log("goal = " .. gx .. "," .. gy)
    example_print_log("has_goal = " .. tostring(aiff:hasGoal()))
end

--@api: LAIFlowField:getDirection
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.pathfind.newPathGrid(10, 10, 16)
    local aiff = lurek.pathfind.newPathFlowField(grid)

    aiff:setGoal(10, 10)

    local dx, dy = aiff:getDirection(1, 1)
    example_print_log("dir = " .. dx .. "," .. dy)
    example_print_log("distance = " .. aiff:getDistance(1, 1))
end

--@api: LAIFlowField:getDistance
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.pathfind.newPathGrid(10, 10, 16)
    local aiff = lurek.pathfind.newPathFlowField(grid)

    aiff:setGoal(10, 10)

    local dx, dy = aiff:getDirection(1, 1)
    example_print_log("dir = " .. dx .. "," .. dy)
    example_print_log("distance = " .. aiff:getDistance(1, 1))
end

--@api: LAIFlowField:type
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.pathfind.newPathGrid(5, 5, 32)
    local aiff = lurek.pathfind.newPathFlowField(grid)
    aiff:setGoal(5, 5)
    local type_name = aiff:type()
    local width = aiff:getWidth()
    local height = aiff:getHeight()

    pathfind_log("ai flow field type = " .. type_name)
    pathfind_log("field dims = " .. width .. "x" .. height)
    pathfind_log("goal ready = " .. tostring(aiff:hasGoal()))
end

--@api: LAIFlowField:typeOf
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.pathfind.newPathGrid(5, 5, 32)
    local aiff = lurek.pathfind.newPathFlowField(grid)
    aiff:setGoal(4, 4)
    local is_ai_flow_field = aiff:typeOf("LAIFlowField")
    local is_object = aiff:typeOf("LObject")
    local is_flow_field = aiff:typeOf("LFlowField")

    pathfind_log("matches LAIFlowField = " .. tostring(is_ai_flow_field))
    pathfind_log("matches LObject = " .. tostring(is_object))
    pathfind_log("matches LFlowField = " .. tostring(is_flow_field))
end

--@api: lurek.pathfind.newPathfinder
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local nav = lurek.pathfind.newNavGrid(30, 30)

    nav:fill(1)
    nav:setBlocked(15, 10, true)
    nav:setBlocked(15, 11, true)
    nav:setBlocked(15, 12, true)
    nav:setBlocked(15, 13, true)

    local pf = lurek.pathfind.newPathfinder(nav)
    local path = pf:findPath(1, 12, 30, 12)
    if path then
        example_print_log("steps = " .. #path)
        example_print_log("first = " .. path[1].x .. "," .. path[1].y)
        example_print_log("last = " .. path[#path].x .. "," .. path[#path].y)
    else
        example_print_log("steps = 0")
    end
end

--@api: LUnitPathfinder:findPath
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local nav = lurek.pathfind.newNavGrid(30, 30)

    nav:fill(1)
    nav:setBlocked(15, 10, true)
    nav:setBlocked(15, 11, true)
    nav:setBlocked(15, 12, true)
    nav:setBlocked(15, 13, true)

    local pf = lurek.pathfind.newPathfinder(nav)
    local path = pf:findPath(1, 12, 30, 12)
    if path then
        example_print_log("steps = " .. #path)
        example_print_log("first = " .. path[1].x .. "," .. path[1].y)
        example_print_log("last = " .. path[#path].x .. "," .. path[#path].y)
    else
        example_print_log("steps = 0")
    end
end

--@api: LUnitPathfinder:findPathSmooth
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    local path = pf:findPathSmooth(1, 1, 20, 20)
    if path then
        example_print_log("points = " .. #path)
        example_print_log("first = " .. path[1].x .. "," .. path[1].y)
        example_print_log("last = " .. path[#path].x .. "," .. path[#path].y)
    else
        example_print_log("points = 0")
    end
end

--@api: LUnitPathfinder:findPathBidirectional
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local nav = lurek.pathfind.newNavGrid(40, 40)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    local path, complete = pf:findPathBidirectional(1, 1, 40, 40, 1, 500)
    if path then
        example_print_log("points = " .. #path)
        example_print_log("complete = " .. tostring(complete))
        example_print_log("last = " .. path[#path].x .. "," .. path[#path].y)
    else
        example_print_log("complete = " .. tostring(complete))
    end
end

--@api: LUnitPathfinder:findPartialPath
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local nav = lurek.pathfind.newNavGrid(100, 100)

    nav:fill(1)
    nav:fillRect(40, 1, 1, 100, 0)
    nav:fillRect(40, 50, 1, 1, 1)

    local pf = lurek.pathfind.newPathfinder(nav)
    local path, reached = pf:findPartialPath(1, 1, 100, 100, 50)

    example_print_log("points = " .. #path)
    example_print_log("reached = " .. tostring(reached))
    example_print_log("last = " .. path[#path].x .. "," .. path[#path].y)
end

--@api: LUnitPathfinder:isReachable
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)
    nav:fillRect(10, 1, 1, 20, 0)

    local pf = lurek.pathfind.newPathfinder(nav)

    example_print_log("reachable_left = " .. tostring(pf:isReachable(1, 1, 9, 9)))
    example_print_log("reachable_right = " .. tostring(pf:isReachable(1, 1, 20, 20)))
end

--@api: LUnitPathfinder:heuristicDistance
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local nav = lurek.pathfind.newNavGrid(20, 20)
    local pf = lurek.pathfind.newPathfinder(nav)
    nav:setBlocked(10, 10, true)
    local map_corner = pf:heuristicDistance(1, 1, 20, 20)
    local same_cell = pf:heuristicDistance(5, 5, 5, 5)
    local front_line = pf:heuristicDistance(2, 10, 18, 10)

    pathfind_log("corner estimate = " .. map_corner)
    pathfind_log("same cell estimate = " .. same_cell)
    pathfind_log("front line estimate = " .. front_line)
end

--@api: LUnitPathfinder:findNearestWalkable
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)
    nav:setBlocked(10, 10, true)
    nav:setBlocked(11, 10, true)
    nav:setBlocked(10, 11, true)
    nav:setBlocked(11, 11, true)

    local pf = lurek.pathfind.newPathfinder(nav)
    local nx, ny = pf:findNearestWalkable(10, 10, 5)

    example_print_log("nearest = " .. nx .. "," .. ny)
end

--@api: LUnitPathfinder:getPathCost
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local nav = lurek.pathfind.newNavGrid(10, 10)

    nav:fill(1)
    nav:setCost(5, 5, 4)

    local pf = lurek.pathfind.newPathfinder(nav)
    local path = pf:findPath(1, 1, 10, 10)
    if path then
        example_print_log("cost = " .. pf:getPathCost(path))
        example_print_log("length = " .. pf:getPathLength(path))
    else
        example_print_log("cost = 0")
    end
end

--@api: LUnitPathfinder:getPathLength
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local nav = lurek.pathfind.newNavGrid(10, 10)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    local path = pf:findPath(1, 1, 10, 10)
    if path then
        example_print_log("length = " .. pf:getPathLength(path))
        example_print_log("cost = " .. pf:getPathCost(path))
    else
        example_print_log("length = 0")
    end
end

--@api: LUnitPathfinder:setCacheEnabled
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    pf:setCacheEnabled(true)
    pf:setCacheMaxSize(100)
    pf:findPath(1, 1, 20, 20)
    pf:findPath(5, 5, 15, 15)

    example_print_log("enabled = " .. tostring(pf:isCacheEnabled()))
    example_print_log("cache_size = " .. pf:getCacheSize())
    pf:clearCache()
    example_print_log("cache_after_clear = " .. pf:getCacheSize())
end

--@api: LUnitPathfinder:isCacheEnabled
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    pf:setCacheEnabled(true)
    local enabled = pf:isCacheEnabled()
    pf:setCacheEnabled(false)

    example_print_log("enabled_before_disable = " .. tostring(enabled))
    example_print_log("enabled_after_disable = " .. tostring(pf:isCacheEnabled()))
end

--@api: LUnitPathfinder:setCacheMaxSize
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    pf:setCacheEnabled(true)
    pf:setCacheMaxSize(2)
    pf:findPath(1, 1, 20, 20)
    pf:findPath(2, 2, 19, 19)
    pf:findPath(3, 3, 18, 18)

    example_print_log("cache_size = " .. pf:getCacheSize())
end

--@api: LUnitPathfinder:getCacheSize
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    pf:setCacheEnabled(true)
    pf:findPath(1, 1, 20, 20)
    pf:findPath(5, 5, 15, 15)

    example_print_log("cache_size = " .. pf:getCacheSize())
end

--@api: LUnitPathfinder:clearCache
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    pf:setCacheEnabled(true)
    pf:findPath(1, 1, 20, 20)

    example_print_log("cache_before_clear = " .. pf:getCacheSize())
    pf:clearCache()
    example_print_log("cache_after_clear = " .. pf:getCacheSize())
end

--@api: LUnitPathfinder:type
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local nav = lurek.pathfind.newNavGrid(5, 5)
    local pf = lurek.pathfind.newPathfinder(nav)
    nav:fill(1)
    local type_name = pf:type()
    local path = pf:findPath(1, 1, 5, 5)
    local cache_enabled = pf:isCacheEnabled()

    pathfind_log("pathfinder type = " .. type_name)
    pathfind_log("route nodes = " .. tostring(path and #path or 0))
    pathfind_log("cache enabled = " .. tostring(cache_enabled))
end

--@api: LUnitPathfinder:typeOf
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local nav = lurek.pathfind.newNavGrid(5, 5)
    local pf = lurek.pathfind.newPathfinder(nav)
    nav:fill(1)
    local is_pathfinder = pf:typeOf("LUnitPathfinder")
    local is_object = pf:typeOf("LObject")
    local is_nav_grid = pf:typeOf("LNavGrid")

    pathfind_log("matches LUnitPathfinder = " .. tostring(is_pathfinder))
    pathfind_log("matches LObject = " .. tostring(is_object))
    pathfind_log("matches LNavGrid = " .. tostring(is_nav_grid))
end

--@api: lurek.pathfind.rangeMap
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local result = lurek.pathfind.rangeMap({
        width = 10,
        height = 10,
        origin_x = 5,
        origin_y = 5,
        budget = 4,
        diagonal = true,
    })

    example_print_log("dims = " .. result.width .. "x" .. result.height)
    example_print_log("cells = " .. #result.cells)
    if #result.cells > 0 then
        example_print_log("first = " .. result.cells[1].x .. "," .. result.cells[1].y .. "," .. result.cells[1].cost)
    end
end

--@api: lurek.pathfind.getThreadCount
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tc = lurek.pathfind.getThreadCount()
    local nav = lurek.pathfind.newNavGrid(8, 8)
    nav:setBlocked(4, 4, true)
    local pending = lurek.pathfind.getAsyncPendingCount()

    pathfind_log("thread count = " .. tc)
    pathfind_log("pending async jobs = " .. pending)
    pathfind_log("sample grid blocked = " .. tostring(nav:isBlocked(4, 4)))
end

--- Pathfind Module Part 4: AI flow field state, nav dimensions, tilemap nav grids, thread count

--@api: LAIFlowField:getHeight
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pg = lurek.pathfind.newPathGrid(32, 32, 1)
    local ff = lurek.pathfind.newPathFlowField(pg)

    ff:setGoal(16, 16)

    example_print_log("dims = " .. ff:getWidth() .. "x" .. ff:getHeight())
    example_print_log("has_goal = " .. tostring(ff:hasGoal()))
end

--@api: LAIFlowField:getWidth
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pg = lurek.pathfind.newPathGrid(32, 32, 1)
    local ff = lurek.pathfind.newPathFlowField(pg)

    ff:setGoal(16, 16)

    example_print_log("dims = " .. ff:getWidth() .. "x" .. ff:getHeight())
    example_print_log("has_goal = " .. tostring(ff:hasGoal()))
end

--@api: LAIFlowField:hasGoal
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pg = lurek.pathfind.newPathGrid(32, 32, 1)
    local ff = lurek.pathfind.newPathFlowField(pg)

    example_print_log("has_goal_before = " .. tostring(ff:hasGoal()))
    ff:setGoal(16, 16)
    example_print_log("has_goal_after = " .. tostring(ff:hasGoal()))
end

--@api: LFlowField:isCalculated
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.pathfind.newNavGrid(16, 16)
    local ff = lurek.pathfind.newFlowField(grid)

    example_print_log("calculated_before = " .. tostring(ff:isCalculated()))
    ff:calculate(8, 8, 1)
    example_print_log("calculated_after = " .. tostring(ff:isCalculated()))
end

--@api: LNavGrid:getDimensions
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ng = lurek.pathfind.newNavGrid(20, 15)
    local w, h = ng:getDimensions()
    ng:setBlocked(10, 8, true)
    local width = ng:getWidth()
    local height = ng:getHeight()

    pathfind_log("nav dims = " .. w .. "x" .. h)
    pathfind_log("width via getter = " .. width)
    pathfind_log("height via getter = " .. height)
end

--@api: LNavGrid:getHeight
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ng = lurek.pathfind.newNavGrid(20, 15)
    local w, h = ng:getDimensions()
    local height = ng:getHeight()

    example_print_log("dims = " .. w .. "x" .. h)
    example_print_log("height = " .. height)
end

--@api: LNavGrid:getWidth
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ng = lurek.pathfind.newNavGrid(20, 15)
    local w, h = ng:getDimensions()
    local width = ng:getWidth()

    example_print_log("dims = " .. w .. "x" .. h)
    example_print_log("width = " .. width)
end

--@api: LNavMesh:getPolygonCount
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mesh = lurek.pathfind.newNavMesh()
    local id = mesh:addPolygon({
        { x = 0, y = 0 },
        { x = 64, y = 0 },
        { x = 32, y = 48 },
    })

    example_print_log("polygon_count = " .. mesh:getPolygonCount())
    example_print_log("first_id = " .. id)
end

--@api: LPathGrid:getCellSize
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pg = lurek.pathfind.newPathGrid(10, 10, 32)
    pg:setWalkable(5, 5, false)
    local cell_size = pg:getCellSize()
    local dims = pg:getWidth() .. "x" .. pg:getHeight()
    local center_open = pg:isWalkable(5, 5)

    pathfind_log("cell size = " .. cell_size)
    pathfind_log("path grid dims = " .. dims)
    pathfind_log("center open = " .. tostring(center_open))
end

--@api: LPathGrid:getHeight
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pg = lurek.pathfind.newPathGrid(10, 10, 32)
    pg:setCost(6, 6, 4)
    local height = pg:getHeight()
    local width = pg:getWidth()
    local center_cost = pg:getCost(6, 6)

    pathfind_log("height = " .. height)
    pathfind_log("width = " .. width)
    pathfind_log("center cost = " .. center_cost)
end

--@api: LPathGrid:getWidth
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pg = lurek.pathfind.newPathGrid(10, 10, 32)
    pg:setCost(4, 4, 3)
    local width = pg:getWidth()
    local height = pg:getHeight()
    local cell_size = pg:getCellSize()

    pathfind_log("width = " .. width)
    pathfind_log("height = " .. height)
    pathfind_log("cell size = " .. cell_size)
end

--@api: lurek.pathfind.newNavGridFromTileMap
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tm = lurek.tilemap.newTileMap(16, 16, 8)
    local layer_index = tm:addLayer("ground", 8, 8)

    tm:setTile(layer_index, 3, 3, 2)
    tm:setTile(layer_index, 4, 3, 1)

    local ng = lurek.pathfind.newNavGridFromTileMap(tm, layer_index, { 2 })

    example_print_log("dims = " .. ng:getWidth() .. "x" .. ng:getHeight())
    example_print_log("blocked_3_3 = " .. tostring(ng:isBlocked(3, 3)))
    example_print_log("blocked_4_3 = " .. tostring(ng:isBlocked(4, 3)))
end

--@api: lurek.pathfind.setThreadCount
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local previous = lurek.pathfind.getThreadCount()
    local target = previous < 2 and 2 or previous

    lurek.pathfind.setThreadCount(target)
    local actual = lurek.pathfind.getThreadCount()
    local nav = lurek.pathfind.newNavGrid(6, 6)

    pathfind_log("thread count target = " .. target)
    pathfind_log("thread count actual = " .. actual)
    pathfind_log("worker sample dims = " .. nav:getWidth() .. "x" .. nav:getHeight())
end

--@api: lurek.pathfind.submitAsyncPath
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.pathfind.clearAsyncPaths()
    local nav = lurek.pathfind.newNavGrid(24, 24)
    local request_id = lurek.pathfind.submitAsyncPath(nav, {
        start_x = 1,
        start_y = 1,
        goal_x = 24,
        goal_y = 24,
        stream_budget = 4,
    })
    example_print_log("request_id = " .. tostring(request_id))
end

--@api: lurek.pathfind.pollAsyncPaths
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.pathfind.clearAsyncPaths()
    local nav = lurek.pathfind.newNavGrid(24, 24)
    local request_id = lurek.pathfind.submitAsyncPath(nav, {
        start_x = 1,
        start_y = 1,
        goal_x = 24,
        goal_y = 24,
        stream_budget = 4,
    })
    local seen = {}
    for _ = 1, 64 do
        local events = lurek.pathfind.pollAsyncPaths()
        for i = 1, #events do
            seen[#seen + 1] = events[i]
        end
        if #seen > 0 then
            break
        end
        lurek.timer.sleep(0.001)
    end
    example_print_log("request = " .. tostring(request_id))
    example_print_log("events = " .. tostring(#seen))
end

--@api: lurek.pathfind.cancelAsyncPath
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.pathfind.clearAsyncPaths()
    local nav = lurek.pathfind.newNavGrid(24, 24)
    local request_id = lurek.pathfind.submitAsyncPath(nav, {
        start_x = 1,
        start_y = 1,
        goal_x = 24,
        goal_y = 24,
        stream_budget = 4,
    })
    example_print_log("cancelled = " .. tostring(lurek.pathfind.cancelAsyncPath(request_id)))
end

--@api: lurek.pathfind.getAsyncPendingCount
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.pathfind.clearAsyncPaths()
    local before = lurek.pathfind.getAsyncPendingCount()
    local nav = lurek.pathfind.newNavGrid(12, 12)
    lurek.pathfind.submitAsyncPath(nav, {
        start_x = 1,
        start_y = 1,
        goal_x = 12,
        goal_y = 12,
        stream_budget = 2,
    })
    local after = lurek.pathfind.getAsyncPendingCount()
    example_print_log("pending_before = " .. tostring(before))
    example_print_log("pending_after = " .. tostring(after))
    lurek.pathfind.clearAsyncPaths()
end

--@api: lurek.pathfind.clearAsyncPaths
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.pathfind.clearAsyncPaths()
    local nav = lurek.pathfind.newNavGrid(12, 12)
    lurek.pathfind.submitAsyncPath(nav, {
        start_x = 1,
        start_y = 1,
        goal_x = 12,
        goal_y = 12,
        stream_budget = 2,
    })
    lurek.pathfind.clearAsyncPaths()
    example_print_log("pending = " .. tostring(lurek.pathfind.getAsyncPendingCount()))
end

--@api: lurek.pathfind.newGoalMap
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local gm = lurek.pathfind.newGoalMap(16, 16)
    gm:addSource(8, 8, 1)
    gm:bake()
    local ready = gm:isReady()
    local center_distance = gm:distanceAt(8, 8)

    pathfind_log("goal map type = " .. gm:type())
    pathfind_log("goal map ready = " .. tostring(ready))
    pathfind_log("center distance = " .. center_distance)
end

--@api: LGoalMap:addSource
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local gm = lurek.pathfind.newGoalMap(16, 16)
    gm:addSource(8, 8, 1)
    gm:addSource(4, 12, 2)
    gm:bake()
    local origin_distance = gm:distanceAt(8, 8)
    local flank_distance = gm:distanceAt(4, 12)
    local corner_distance = gm:distanceAt(1, 1)

    pathfind_log("origin distance = " .. origin_distance)
    pathfind_log("flank source distance = " .. flank_distance)
    pathfind_log("corner distance = " .. corner_distance)
end

--@api: LGoalMap:setSources
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local gm = lurek.pathfind.newGoalMap(16, 16)
    gm:setSources({
        { x = 4, y = 4, weight = 1 },
        { x = 13, y = 13, weight = 2 },
    })
    gm:bake()
    example_print_log("ready = " .. tostring(gm:isReady()))
end

--@api: LGoalMap:clearSources
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local gm = lurek.pathfind.newGoalMap(16, 16)
    gm:addSource(8, 8, 1)
    gm:clearSources()
    gm:bake()
    example_print_log("ready_after_clear = " .. tostring(gm:isReady()))
end

--@api: LGoalMap:setBlocker
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local gm = lurek.pathfind.newGoalMap(16, 16)
    gm:addSource(8, 8, 1)
    gm:setBlocker(function(x, y)
        return x == 9 and y >= 4 and y <= 12
    end)
    gm:bake()
    example_print_log("distance_12_8 = " .. gm:distanceAt(12, 8))
end

--@api: LGoalMap:bake
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local gm = lurek.pathfind.newGoalMap(16, 16)
    gm:addSource(8, 8, 1)
    gm:bake()
    local ready = gm:isReady()
    local distance_mid = gm:distanceAt(10, 8)
    local distance_corner = gm:distanceAt(1, 1)

    pathfind_log("ready after bake = " .. tostring(ready))
    pathfind_log("east lane distance = " .. distance_mid)
    pathfind_log("corner distance = " .. distance_corner)
end

--@api: LGoalMap:isReady
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local gm = lurek.pathfind.newGoalMap(8, 8)
    gm:addSource(4, 4, 1)
    example_print_log("ready_before = " .. tostring(gm:isReady()))
    gm:bake()
    example_print_log("ready_after = " .. tostring(gm:isReady()))
end

--@api: LGoalMap:distanceAt
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local gm = lurek.pathfind.newGoalMap(10, 10)
    gm:addSource(5, 5, 1)
    gm:bake()
    example_print_log("distance_5_5 = " .. gm:distanceAt(5, 5))
    example_print_log("distance_1_1 = " .. gm:distanceAt(1, 1))
end

--@api: LGoalMap:gradientAt
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local gm = lurek.pathfind.newGoalMap(10, 10)
    gm:addSource(10, 10, 1)
    gm:bake()
    local dx, dy = gm:gradientAt(1, 1)
    example_print_log("gradient = " .. dx .. "," .. dy)
end

--@api: LGoalMap:flee
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local gm = lurek.pathfind.newGoalMap(10, 10)
    gm:addSource(5, 5, 1)
    gm:bake()
    local dx, dy = gm:flee(5, 6, 1.0)
    example_print_log("flee = " .. dx .. "," .. dy)
end

--@api: LGoalMap:floodFill
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local gm = lurek.pathfind.newGoalMap(12, 12)
    gm:addSource(6, 6, 1)
    gm:bake()
    local cells = gm:floodFill(6, 6, 4)
    example_print_log("flood_cells = " .. #cells)
end

--@api: LGoalMap:save
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local gm = lurek.pathfind.newGoalMap(12, 12)
    gm:addSource(6, 6, 1)
    gm:bake()
    local blob = gm:save()
    example_print_log("blob_bytes = " .. #blob)
end

--@api: LGoalMap:restore
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local gm = lurek.pathfind.newGoalMap(12, 12)
    gm:addSource(6, 6, 1)
    gm:bake()
    local blob = gm:save()

    local gm2 = lurek.pathfind.newGoalMap(12, 12)
    gm2:restore(blob)
    example_print_log("distance_restored = " .. gm2:distanceAt(6, 6))
end

--@api: LGoalMap:type
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local gm = lurek.pathfind.newGoalMap(8, 8)
    gm:addSource(4, 4, 1)
    gm:bake()
    local type_name = gm:type()
    local ready = gm:isReady()

    pathfind_log("goal map type = " .. type_name)
    pathfind_log("ready = " .. tostring(ready))
    pathfind_log("center distance = " .. gm:distanceAt(4, 4))
end

--@api: LGoalMap:typeOf
do
    local function pathfind_log(message)
        lurek.log.info("[pathfind.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local gm = lurek.pathfind.newGoalMap(8, 8)
    gm:addSource(4, 4, 1)
    gm:bake()
    local is_goal_map = gm:typeOf("LGoalMap")
    local is_object = gm:typeOf("LObject")
    local is_nav_mesh = gm:typeOf("LNavMesh")

    pathfind_log("matches LGoalMap = " .. tostring(is_goal_map))
    pathfind_log("matches LObject = " .. tostring(is_object))
    pathfind_log("matches LNavMesh = " .. tostring(is_nav_mesh))
end
