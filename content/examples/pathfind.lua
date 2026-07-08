-- content/examples/pathfind.lua
-- Auto-generated from content/examples2/pathfind_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/pathfind.lua

--- Pathfinding Module Part 1: grid pathfinding basics (LPathGrid, LNavGrid)

--@api: lurek.pathfind.graphRoute
do

    local edges = {
        { from = 1, to = 2 },
        { from = 2, to = 3 },
        { from = 1, to = 4 },
        { from = 4, to = 3 },
    }
    local route = lurek.pathfind.graphRoute(edges, 1, 3, {
        algorithm = "dijkstra",
        cost = function(from, to)
            if (from == 1 and to == 2) or (from == 2 and to == 3) then
                return 12
            end
            return 1
        end,
    })
    lurek.log.info("graph route hops=" .. tostring(route and #route or 0) .. " via=" .. tostring(route and route[2]))
end

--@api: lurek.pathfind.graphRoutes
do

    local edges = {
        { 1, 2 },
        { 2, 3 },
        { 4, 5 },
    }
    local routes = lurek.pathfind.graphRoutes(edges, {
        { from = 1, to = 3 },
        { from = 1, to = 5 },
        { from = 4, to = 5 },
    })
    local first_len = routes[1] and #routes[1] or 0
    local third_len = routes[3] and #routes[3] or 0
    lurek.log.info("graph route batch first=" .. tostring(first_len) .. " third=" .. tostring(third_len) .. " second_nil=" .. tostring(routes[2] == nil))
end

--@api: lurek.pathfind.graphConnectedComponents
do

    local edges = {
        { from = 7, to = 8 },
        { from = 8, to = 9 },
        { from = 20, to = 21 },
    }
    local components = lurek.pathfind.graphConnectedComponents(edges, { 7, 8, 9, 10, 20, 21 })
    local isolated = components[2] and components[2][1] or nil
    local largest = components[1] and #components[1] or 0
    lurek.log.info("graph components=" .. tostring(#components) .. " largest=" .. tostring(largest) .. " isolated=" .. tostring(isolated))
end

--@api: lurek.pathfind.graphConnected
do

    local edges = {
        { from = 1, to = 2 },
        { from = 2, to = 3 },
    }
    local forward = lurek.pathfind.graphConnected(edges, 1, 3, { directed = true })
    local backward_directed = lurek.pathfind.graphConnected(edges, 3, 1, { directed = true })
    local backward_undirected = lurek.pathfind.graphConnected(edges, 3, 1)
    lurek.log.info("graph connected forward=" .. tostring(forward) .. " directed_back=" .. tostring(backward_directed) .. " undirected_back=" .. tostring(backward_undirected))
end


--@api: lurek.pathfind.newNavGridFromField
do

    local field = lurek.tilefield.new({ width = 6, height = 6 })
    field:applyProfile(3, 3, 1, "wall")
    local grid = lurek.pathfind.newNavGridFromField(field, { level = 1, channel = "move" })
    local blocked = grid:isBlocked(3, 3)
    local width = grid:getWidth()
    lurek.log.info("field navgrid width=" .. width .. " blocked=" .. tostring(blocked))
end

--@api: lurek.pathfind.newHexGridFromField
do

    local field = lurek.tilefield.new({ width = 6, height = 6, topology = "hex" })
    field:setBlock(3, 3, 1, "move", true)
    field:setCost(4, 3, 1, "move", 3)
    local grid = lurek.pathfind.newHexGridFromField(field, { level = 1, channel = "move", layout = "flat" })
    local route = grid:findPath(1, 3, 6, 3) or {}
    local blocked = grid:isBlocked(3, 3)
    lurek.log.info("field hex route nodes=" .. tostring(#route) .. " blocked=" .. tostring(blocked))
end

--@api: lurek.pathfind.newIsoGrid
do

    local grid = lurek.pathfind.newIsoGrid(6, 5)
    grid:setBlocked(3, 3, true)
    local route = grid:findPath(1, 3, 6, 3) or {}
    local blocked = grid:isBlocked(3, 3)
    lurek.log.info("iso route nodes=" .. tostring(#route) .. " blocked=" .. tostring(blocked))
end

--@api: lurek.pathfind.newIsoGridFromField
do

    local field = lurek.tilefield.new({ width = 6, height = 5, topology = "iso_square" })
    field:setBlock(3, 3, 1, "move", true)
    field:setCost(4, 3, 1, "move", 3)
    local grid = lurek.pathfind.newIsoGridFromField(field, { level = 1, channel = "move" })
    local route = grid:findPath(1, 3, 6, 3) or {}
    lurek.log.info("field iso route nodes=" .. tostring(#route) .. " cost=" .. tostring(grid:getCost(4, 3)))
end

--@api: LIsoGrid:setBlocked
do

    local grid = lurek.pathfind.newIsoGrid(5, 5)
    grid:setBlocked(2, 3, true)
    grid:setBlocked(2, 4, true)
    local first = grid:isBlocked(2, 3)
    local second = grid:isBlocked(2, 4)
    lurek.log.info("iso blockers first=" .. tostring(first) .. " second=" .. tostring(second))
end

--@api: LIsoGrid:setCost
do

    local grid = lurek.pathfind.newIsoGrid(5, 5)
    grid:setCost(3, 2, 2.5)
    grid:setCost(3, 3, 4.0)
    local road = grid:getCost(3, 2)
    local mud = grid:getCost(3, 3)
    lurek.log.info("iso costs road=" .. tostring(road) .. " mud=" .. tostring(mud))
end

--@api: LIsoGrid:isBlocked
do

    local grid = lurek.pathfind.newIsoGrid(5, 5)
    grid:setBlocked(4, 2, true)
    local wall = grid:isBlocked(4, 2)
    local floor = grid:isBlocked(4, 3)
    local route = grid:findPath(1, 2, 5, 2) or {}
    lurek.log.info("iso blocked wall=" .. tostring(wall) .. " floor=" .. tostring(floor) .. " route=" .. tostring(#route))
end

--@api: LIsoGrid:getCost
do

    local grid = lurek.pathfind.newIsoGrid(5, 5)
    grid:setCost(2, 2, 3.5)
    grid:setCost(2, 3, 1.5)
    local bridge = grid:getCost(2, 2)
    local lane = grid:getCost(2, 3)
    local plain = grid:getCost(1, 1)
    lurek.log.info("iso costs bridge=" .. tostring(bridge) .. " lane=" .. tostring(lane) .. " plain=" .. tostring(plain))
end

--@api: LIsoGrid:findPath
do

    local grid = lurek.pathfind.newIsoGrid(7, 5)
    grid:setBlocked(4, 1, true)
    grid:setBlocked(4, 2, true)
    grid:setBlocked(4, 3, true)
    local route = grid:findPath(1, 2, 7, 2) or {}
    local last = route[#route] or { x = 0, y = 0 }
    lurek.log.info("iso path nodes=" .. tostring(#route) .. " last=" .. tostring(last.x) .. "," .. tostring(last.y))
end

--@api: LIsoGrid:type
do

    local grid = lurek.pathfind.newIsoGrid(4, 4)
    grid:setCost(2, 2, 2)
    local type_name = grid:type()
    local cost = grid:getCost(2, 2)
    local route = grid:findPath(1, 1, 4, 4) or {}
    lurek.log.info("iso type=" .. type_name .. " cost=" .. tostring(cost) .. " route=" .. tostring(#route))
end

--@api: LIsoGrid:typeOf
do

    local grid = lurek.pathfind.newIsoGrid(4, 4)
    grid:setBlocked(2, 2, true)
    local is_iso = grid:typeOf("LIsoGrid")
    local is_object = grid:typeOf("LObject")
    local is_hex = grid:typeOf("LHexGrid")
    lurek.log.info("iso typeOf iso=" .. tostring(is_iso) .. " object=" .. tostring(is_object) .. " hex=" .. tostring(is_hex))
end

--@api: lurek.pathfind.rangeMapFromField
do

    local field = lurek.tilefield.new({ width = 6, height = 6 })
    field:setCost(2, 1, 1, "move", 2)
    local range = lurek.pathfind.rangeMapFromField(field, { origin = { x = 1, y = 1, z = 1 }, budget = 4 })
    local count = #range.cells
    local width = range.width
    lurek.log.info("field range width=" .. width .. " cells=" .. count)
end


--@api: lurek.pathfind.newPathGrid
do

    local grid = lurek.pathfind.newPathGrid(20, 15, 32)
    grid:setWalkable(10, 8, false)
    local width = grid:getWidth()
    local height = grid:getHeight()
    local cell_size = grid:getCellSize()
    local chokepoint_open = grid:isWalkable(10, 7)

    lurek.log.info("patrol grid = " .. width .. "x" .. height)
    lurek.log.info("patrol cell size = " .. cell_size)
    lurek.log.info("approach tile walkable = " .. tostring(chokepoint_open))
end

--@api: LPathGrid:setWalkable
do

    local grid = lurek.pathfind.newPathGrid(20, 15, 32)
    grid:setWalkable(6, 7, false)
    grid:setWalkable(5, 5, false)
    local blocked_gate = grid:isWalkable(5, 5)
    local flank_route = grid:isWalkable(5, 6)
    local guard_post = grid:isWalkable(6, 7)

    lurek.log.info("main gate open = " .. tostring(blocked_gate))
    lurek.log.info("flank route open = " .. tostring(flank_route))
    lurek.log.info("guard post open = " .. tostring(guard_post))
end

--@api: LPathGrid:isWalkable
do

    local grid = lurek.pathfind.newPathGrid(20, 15, 32)
    grid:setWalkable(4, 4, false)
    grid:setWalkable(4, 5, true)
    local tower_cell = grid:isWalkable(4, 4)
    local stairs_cell = grid:isWalkable(4, 5)
    local courtyard_cell = grid:isWalkable(5, 5)

    lurek.log.info("tower cell walkable = " .. tostring(tower_cell))
    lurek.log.info("stairs cell walkable = " .. tostring(stairs_cell))
    lurek.log.info("courtyard cell walkable = " .. tostring(courtyard_cell))
end

--@api: LPathGrid:setCost
do

    local grid = lurek.pathfind.newPathGrid(10, 10, 16)
    grid:setCost(3, 2, 2)
    grid:setCost(3, 3, 5)
    local mud_cost = grid:getCost(3, 3)
    local road_cost = grid:getCost(3, 2)
    local plain_cost = grid:getCost(3, 4)

    lurek.log.info("mud tile cost = " .. mud_cost)
    lurek.log.info("road tile cost = " .. road_cost)
    lurek.log.info("plain tile cost = " .. plain_cost)
end

--@api: LPathGrid:getCost
do

    local grid = lurek.pathfind.newPathGrid(10, 10, 16)
    grid:setCost(6, 1, 1.5)
    grid:setCost(6, 2, 2.5)
    local bridge_cost = grid:getCost(6, 2)
    local lane_cost = grid:getCost(6, 1)
    local base_cost = grid:getCost(1, 1)

    lurek.log.info("bridge tile cost = " .. bridge_cost)
    lurek.log.info("lane tile cost = " .. lane_cost)
    lurek.log.info("default tile cost = " .. base_cost)
end

--@api: LPathGrid:findPath
do

    local grid = lurek.pathfind.newPathGrid(10, 10, 32)

    for y = 1, 10 do
        grid:setWalkable(5, y, false)
    end
    grid:setWalkable(5, 8, true)

    local path = grid:findPath(1, 1, 10, 10)
    if path then
        lurek.log.info("steps = " .. #path)
        lurek.log.info("first = " .. path[1].x .. "," .. path[1].y)
        lurek.log.info("last = " .. path[#path].x .. "," .. path[#path].y)
    else
        lurek.log.info("steps = 0")
    end
end

--@api: LPathGrid:findPathSmoothed
do

    local grid = lurek.pathfind.newPathGrid(20, 20, 16)

    grid:setWalkable(10, 5, false)
    grid:setWalkable(10, 6, false)
    grid:setWalkable(10, 7, false)

    local path = grid:findPathSmoothed(1, 5, 20, 5)
    if path then
        lurek.log.info("points = " .. #path)
        lurek.log.info("first = " .. path[1].x .. "," .. path[1].y)
        lurek.log.info("last = " .. path[#path].x .. "," .. path[#path].y)
    else
        lurek.log.info("points = 0")
    end
end

--@api: LPathGrid:type
do

    local grid = lurek.pathfind.newPathGrid(5, 5, 32)
    grid:setWalkable(3, 3, false)
    local type_name = grid:type()
    local width = grid:getWidth()
    local height = grid:getHeight()
    local blocked_center = grid:isWalkable(3, 3)

    lurek.log.info("path grid type = " .. type_name)
    lurek.log.info("training grid = " .. width .. "x" .. height)
    lurek.log.info("center walkable = " .. tostring(blocked_center))
end

--@api: LPathGrid:typeOf
do

    local grid = lurek.pathfind.newPathGrid(5, 5, 32)
    grid:setCost(2, 2, 3)
    local is_path_grid = grid:typeOf("LPathGrid")
    local is_object = grid:typeOf("LObject")
    local is_nav_grid = grid:typeOf("LNavGrid")

    lurek.log.info("matches LPathGrid = " .. tostring(is_path_grid))
    lurek.log.info("matches LObject = " .. tostring(is_object))
    lurek.log.info("matches LNavGrid = " .. tostring(is_nav_grid))
end

--@api: lurek.pathfind.newNavGrid
do

    local nav = lurek.pathfind.newNavGrid(50, 50)
    local w, h = nav:getDimensions()
    nav:setBlocked(25, 25, true)
    local chunk = nav:getChunkSize()
    local center_blocked = nav:isBlocked(25, 25)

    lurek.log.info("city nav dims = " .. w .. "x" .. h)
    lurek.log.info("default chunk = " .. chunk)
    lurek.log.info("market center blocked = " .. tostring(center_blocked))
end

--@api: LNavGrid:setBlocked
do

    local nav = lurek.pathfind.newNavGrid(30, 30)
    nav:fill(1)
    nav:setBlocked(10, 10, true)
    nav:setBlocked(10, 11, true)
    local blocked_gate = nav:isBlocked(10, 10)
    local blocked_corridor = nav:isBlocked(10, 11)
    local detour_open = nav:isWalkable(11, 10)

    lurek.log.info("main gate blocked = " .. tostring(blocked_gate))
    lurek.log.info("corridor blocked = " .. tostring(blocked_corridor))
    lurek.log.info("detour open = " .. tostring(detour_open))
end

--@api: LNavGrid:isBlocked
do

    local nav = lurek.pathfind.newNavGrid(30, 30)
    nav:fill(1)
    nav:setBlocked(12, 12, true)
    nav:setBlocked(13, 12, true)
    local barricade = nav:isBlocked(12, 12)
    local second_barricade = nav:isBlocked(13, 12)
    local alley = nav:isBlocked(12, 13)

    lurek.log.info("barricade = " .. tostring(barricade))
    lurek.log.info("second barricade = " .. tostring(second_barricade))
    lurek.log.info("alley blocked = " .. tostring(alley))
end

--@api: LNavGrid:setCost
do

    local nav = lurek.pathfind.newNavGrid(30, 30)
    nav:fill(1)
    nav:setCost(5, 5, 200)
    nav:setCost(5, 6, 25)
    local swamp_cost = nav:getCost(5, 5)
    local path_cost = nav:getCost(5, 6)
    local swamp_blocked = nav:isBlocked(5, 5)

    lurek.log.info("swamp cost = " .. swamp_cost)
    lurek.log.info("trail cost = " .. path_cost)
    lurek.log.info("swamp blocked = " .. tostring(swamp_blocked))
end

--@api: LNavGrid:getCost
do

    local nav = lurek.pathfind.newNavGrid(30, 30)
    nav:fill(1)
    nav:setCost(7, 8, 4)
    nav:setCost(8, 8, 7)
    local shallow_water = nav:getCost(7, 8)
    local deep_water = nav:getCost(8, 8)
    local dry_ground = nav:getCost(1, 1)

    lurek.log.info("shallow water cost = " .. shallow_water)
    lurek.log.info("deep water cost = " .. deep_water)
    lurek.log.info("dry ground cost = " .. dry_ground)
end

--@api: LNavGrid:isWalkable
do

    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)
    nav:setBlocked(6, 6, true)

    lurek.log.info("walkable_1x1 = " .. tostring(nav:isWalkable(5, 5)))
    lurek.log.info("walkable_blocked = " .. tostring(nav:isWalkable(6, 6)))
    lurek.log.info("walkable_2x2 = " .. tostring(nav:isWalkable(5, 5, 2)))
end

--@api: LNavGrid:defineFootprint
do

    local nav = lurek.pathfind.newNavGrid(20, 20)
    nav:defineFootprint("tank", { w = 2, h = 2 })
    local spec = nav:getFootprint("tank")
    nav:setBlocked(10, 10, true)

    lurek.log.info("tank footprint = " .. spec.w .. "x" .. spec.h)
    lurek.log.info("blocked pivot = " .. tostring(nav:isBlocked(10, 10)))
end

--@api: LNavGrid:getFootprint
do

    local nav = lurek.pathfind.newNavGrid(20, 20)
    nav:defineFootprint("super_heavy", { w = 4, h = 4 })
    local spec = nav:getFootprint("super_heavy")
    local missing = nav:getFootprint("missing")

    lurek.log.info("super heavy width = " .. spec.w)
    lurek.log.info("missing footprint = " .. tostring(missing == nil))
end

--@api: LNavGrid:rebuildClearance
do

    local nav = lurek.pathfind.newNavGrid(20, 20)
    nav:defineFootprint("infantry", { w = 1, h = 1 })
    nav:defineFootprint("tank", { w = 2, h = 2 })
    local rebuilt = nav:rebuildClearance()

    lurek.log.info("rebuilt footprints = " .. rebuilt)
    lurek.log.info("tank walkable = " .. tostring(nav:isWalkableFor("tank", 1, 1)))
end

--@api: LNavGrid:isWalkableFor
do

    local nav = lurek.pathfind.newNavGrid(20, 20)
    nav:defineFootprint("tank", { w = 2, h = 2 })
    nav:rebuildClearance()
    nav:setBlocked(2, 2, true)

    lurek.log.info("tank at 1,1 = " .. tostring(nav:isWalkableFor("tank", 1, 1)))
    lurek.log.info("tank at 3,3 = " .. tostring(nav:isWalkableFor("tank", 3, 3)))
end

--@api: LNavGrid:fill
do

    local nav = lurek.pathfind.newNavGrid(20, 20)
    nav:fill(3)
    nav:setCost(10, 10, 1)
    local border_cost = nav:getCost(1, 1)
    local far_corner_cost = nav:getCost(20, 20)
    local plaza_cost = nav:getCost(10, 10)

    lurek.log.info("default patrol cost = " .. border_cost)
    lurek.log.info("far corner cost = " .. far_corner_cost)
    lurek.log.info("plaza override cost = " .. plaza_cost)
end

--@api: LNavGrid:fillRect
do

    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fillRect(5, 5, 5, 5, 0)

    lurek.log.info("blocked_5_5 = " .. tostring(nav:isBlocked(5, 5)))
    lurek.log.info("blocked_10_10 = " .. tostring(nav:isBlocked(10, 10)))
    lurek.log.info("blocked_11_11 = " .. tostring(nav:isBlocked(11, 11)))
end

--@api: LNavGrid:beginUpdate
do

    local nav = lurek.pathfind.newNavGrid(20, 20)
    nav:beginUpdate()
    nav:setBlockedRect(4, 4, 2, 2, true)
    local before = nav:getGeneration()
    local committed = nav:commitUpdate()

    lurek.log.info("generation before commit = " .. before)
    lurek.log.info("committed rects = " .. committed)
end

--@api: LNavGrid:setBlockedRect
do

    local nav = lurek.pathfind.newNavGrid(20, 20)
    nav:setBlockedRect(5, 5, 3, 3, true)
    local center = nav:isBlocked(6, 6)
    local edge = nav:isBlocked(5, 5)

    lurek.log.info("blocked center = " .. tostring(center))
    lurek.log.info("blocked edge = " .. tostring(edge))
end

--@api: LNavGrid:setCostRect
do

    local nav = lurek.pathfind.newNavGrid(20, 20)
    nav:setCostRect(5, 5, 3, 3, 7)
    local center = nav:getCost(6, 6)
    local edge = nav:getCost(5, 5)

    lurek.log.info("cost center = " .. center)
    lurek.log.info("cost edge = " .. edge)
end

--@api: LNavGrid:commitUpdate
do

    local nav = lurek.pathfind.newNavGrid(20, 20)
    nav:beginUpdate()
    nav:setBlockedRect(4, 4, 2, 2, true)
    nav:setCostRect(10, 10, 2, 2, 9)
    local committed = nav:commitUpdate({ rebuild = "dirty_chunks" })

    lurek.log.info("commit dirty rect count = " .. committed)
    lurek.log.info("generation = " .. nav:getGeneration())
end

--@api: LNavGrid:getDirtyRects
do

    local nav = lurek.pathfind.newNavGrid(20, 20)
    nav:setBlockedRect(5, 5, 3, 3, true)
    local rects = nav:getDirtyRects()
    local first = rects[1]

    lurek.log.info("dirty rect count = " .. #rects)
    lurek.log.info("first dirty rect = " .. first.x .. "," .. first.y .. " " .. first.w .. "x" .. first.h)
end

--@api: LNavGrid:setDiagonalMode
do

    local nav = lurek.pathfind.newNavGrid(10, 10)
    nav:setDiagonalMode("always")
    nav:setBlocked(5, 5, true)
    local mode = nav:getDiagonalMode()
    local direct_corner = nav:isWalkable(4, 4)

    lurek.log.info("scout diagonal mode = " .. mode)
    lurek.log.info("corner tile open = " .. tostring(direct_corner))
    lurek.log.info("blocked pivot = " .. tostring(nav:isBlocked(5, 5)))
end

--@api: LNavGrid:getDiagonalMode
do

    local nav = lurek.pathfind.newNavGrid(10, 10)
    nav:setDiagonalMode("nocornercut")
    nav:setBlocked(4, 5, true)
    local mode = nav:getDiagonalMode()
    local blocked_neighbor = nav:isBlocked(4, 5)

    lurek.log.info("formation diagonal mode = " .. mode)
    lurek.log.info("blocked neighbor = " .. tostring(blocked_neighbor))
    lurek.log.info("origin walkable = " .. tostring(nav:isWalkable(1, 1)))
end

--@api: LNavGrid:setChunkSize
do

    local nav = lurek.pathfind.newNavGrid(100, 100)
    nav:setChunkSize(16)
    nav:rebuildAbstract()
    nav:setBlocked(40, 40, true)
    local chunk_size = nav:getChunkSize()
    local blocked_hub = nav:isBlocked(40, 40)

    lurek.log.info("hpa chunk size = " .. chunk_size)
    lurek.log.info("blocked logistics hub = " .. tostring(blocked_hub))
    lurek.log.info("nav width = " .. nav:getWidth())
end

--@api: LNavGrid:getChunkSize
do

    local nav = lurek.pathfind.newNavGrid(100, 100)
    nav:setChunkSize(12)
    nav:setBlocked(60, 60, true)
    local chunk_size = nav:getChunkSize()
    local dimensions = nav:getWidth() .. "x" .. nav:getHeight()

    lurek.log.info("chunk size = " .. chunk_size)
    lurek.log.info("sector dims = " .. dimensions)
    lurek.log.info("warehouse blocked = " .. tostring(nav:isBlocked(60, 60)))
end

--@api: LNavGrid:rebuildAbstract
do

    local nav = lurek.pathfind.newNavGrid(64, 64)

    nav:setChunkSize(8)
    nav:rebuildAbstract()

    lurek.log.info("chunk = " .. nav:getChunkSize())
    lurek.log.info("blocked_1_1 = " .. tostring(nav:isBlocked(1, 1)))
end

--@api: LNavGrid:findHpaPath
do

    local nav = lurek.pathfind.newNavGrid(16, 16)
    nav:setChunkSize(4)
    nav:rebuildAbstract()
    local path = nav:findHpaPath(1, 1, 16, 16, 1)
    lurek.log.info("hpa path exists = " .. tostring(path ~= nil))
    lurek.log.info("hpa path len = " .. tostring(path and #path or 0))
end

--@api: LNavGrid:findHpaPathsToGoal
do

    local nav = lurek.pathfind.newNavGrid(32, 32)
    nav:setChunkSize(8)
    nav:rebuildAbstract()

    local paths = nav:findHpaPathsToGoal({
        { x = 1, y = 1 },
        { x = 2, y = 8 },
        { x = 10, y = 3 },
    }, 30, 30, 1)

    lurek.log.info("shared hpa count = " .. tostring(#paths))
    lurek.log.info("first len = " .. tostring(paths[1] and #paths[1] or 0))
end

--@api: LNavGrid:setDirty
do

    local nav = lurek.pathfind.newNavGrid(50, 50)

    nav:setChunkSize(10)
    nav:rebuildAbstract()
    nav:setBlocked(25, 25, true)
    nav:setDirty(20, 20, 10, 10)
    nav:rebuildAbstract()

    lurek.log.info("blocked_25_25 = " .. tostring(nav:isBlocked(25, 25)))
    lurek.log.info("chunk = " .. nav:getChunkSize())
end

--@api: LNavGrid:clearDirty
do

    local nav = lurek.pathfind.newNavGrid(50, 50)

    nav:setChunkSize(10)
    nav:setDirty(20, 20, 10, 10)
    nav:clearDirty()
    nav:rebuildAbstract()

    lurek.log.info("chunk = " .. nav:getChunkSize())
end

--@api: LNavGrid:saveToString
do

    local nav = lurek.pathfind.newNavGrid(10, 10)

    nav:setBlocked(5, 5, true)
    nav:setCost(3, 3, 9)

    local data = nav:saveToString()

    lurek.log.info("bytes = " .. #data)
    lurek.log.info("blocked_5_5 = " .. tostring(nav:isBlocked(5, 5)))
end

--@api: LNavGrid:loadFromString
do

    local nav = lurek.pathfind.newNavGrid(10, 10)

    nav:setBlocked(5, 5, true)
    nav:setCost(3, 3, 9)

    local data = nav:saveToString()
    local nav2 = lurek.pathfind.newNavGrid(10, 10)
    nav2:loadFromString(data)

    lurek.log.info("blocked_5_5 = " .. tostring(nav2:isBlocked(5, 5)))
    lurek.log.info("cost_3_3 = " .. nav2:getCost(3, 3))
end

--@api: LNavGrid:type
do

    local nav = lurek.pathfind.newNavGrid(5, 5)
    nav:setCost(3, 3, 9)
    local type_name = nav:type()
    local dims = nav:getWidth() .. "x" .. nav:getHeight()
    local center_cost = nav:getCost(3, 3)

    lurek.log.info("nav grid type = " .. type_name)
    lurek.log.info("debug dims = " .. dims)
    lurek.log.info("center cost = " .. center_cost)
end

--@api: LNavGrid:typeOf
do

    local nav = lurek.pathfind.newNavGrid(5, 5)
    nav:setBlocked(2, 3, true)
    local is_nav_grid = nav:typeOf("LNavGrid")
    local is_object = nav:typeOf("LObject")
    local is_path_grid = nav:typeOf("LPathGrid")

    lurek.log.info("matches LNavGrid = " .. tostring(is_nav_grid))
    lurek.log.info("matches LObject = " .. tostring(is_object))
    lurek.log.info("matches LPathGrid = " .. tostring(is_path_grid))
end

--- Pathfinding Module Part 2: navmesh, hex grid, JPS grid

--@api: lurek.pathfind.newNavMesh
do

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

    lurek.log.info("polygons = " .. mesh:getPolygonCount())
    lurek.log.info("ids = " .. id1 .. "," .. id2)
end

--@api: LNavMesh:addPolygon
do

    local mesh = lurek.pathfind.newNavMesh()
    local id = mesh:addPolygon({
        { x = 0, y = 0 },
        { x = 60, y = 0 },
        { x = 30, y = 45 },
    })

    lurek.log.info("polygon_id = " .. id)
    lurek.log.info("polygon_count = " .. mesh:getPolygonCount())
end

--@api: LNavMesh:connectPolygons
do

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

    lurek.log.info("connected_ab = " .. tostring(ab))
    lurek.log.info("connected_bc = " .. tostring(bc))
    lurek.log.info("polygon_count = " .. mesh:getPolygonCount())
end

--@api: LNavMesh:findPath
do

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
        lurek.log.info("waypoints = " .. #path)
        lurek.log.info("first = " .. path[1].x .. "," .. path[1].y)
        lurek.log.info("last = " .. path[#path].x .. "," .. path[#path].y)
    else
        lurek.log.info("waypoints = 0")
    end
end

--@api: LNavMesh:type
do

    local mesh = lurek.pathfind.newNavMesh()
    mesh:addPolygon({
        { x = 0, y = 0 },
        { x = 64, y = 0 },
        { x = 32, y = 48 },
    })
    local type_name = mesh:type()
    local polygon_count = mesh:getPolygonCount()

    lurek.log.info("nav mesh type = " .. type_name)
    lurek.log.info("triangle count = " .. polygon_count)
    lurek.log.info("mesh ready for corridor routing = " .. tostring(polygon_count > 0))
end

--@api: LNavMesh:typeOf
do

    local mesh = lurek.pathfind.newNavMesh()
    mesh:addPolygon({
        { x = 0, y = 0 },
        { x = 32, y = 0 },
        { x = 16, y = 24 },
    })
    local is_nav_mesh = mesh:typeOf("LNavMesh")
    local is_object = mesh:typeOf("LObject")
    local is_goal_map = mesh:typeOf("LGoalMap")

    lurek.log.info("matches LNavMesh = " .. tostring(is_nav_mesh))
    lurek.log.info("matches LObject = " .. tostring(is_object))
    lurek.log.info("matches LGoalMap = " .. tostring(is_goal_map))
end

--@api: lurek.pathfind.newHexGrid
do

    local hex = lurek.pathfind.newHexGrid(12, 10, "flat")

    hex:setBlocked(5, 5, true)
    hex:setBlocked(6, 5, true)

    lurek.log.info("blocked_5_5 = " .. tostring(hex:isBlocked(5, 5)))
    lurek.log.info("blocked_1_1 = " .. tostring(hex:isBlocked(1, 1)))
end

--@api: LHexGrid:setBlocked
do

    local hex = lurek.pathfind.newHexGrid(12, 10, "flat")

    hex:setBlocked(5, 5, true)
    hex:setBlocked(6, 5, true)

    lurek.log.info("blocked_5_5 = " .. tostring(hex:isBlocked(5, 5)))
    lurek.log.info("blocked_6_5 = " .. tostring(hex:isBlocked(6, 5)))
end

--@api: LHexGrid:isBlocked
do

    local hex = lurek.pathfind.newHexGrid(12, 10, "flat")
    hex:setBlocked(4, 4, true)
    hex:setBlocked(5, 4, true)
    local ridge = hex:isBlocked(4, 4)
    local ridge_neighbor = hex:isBlocked(5, 4)
    local open_hex = hex:isBlocked(4, 5)

    lurek.log.info("ridge blocked = " .. tostring(ridge))
    lurek.log.info("ridge neighbor blocked = " .. tostring(ridge_neighbor))
    lurek.log.info("southern hex blocked = " .. tostring(open_hex))
end

--@api: LHexGrid:setCost
do

    local hex = lurek.pathfind.newHexGrid(8, 8)

    hex:setCost(4, 4, 4)
    hex:setCost(5, 4, 4)

    local reachable = hex:rangeOfMovement(4, 4, 4)
    lurek.log.info("reachable = " .. #reachable)
    if #reachable > 0 then
        lurek.log.info("first = " .. reachable[1].col .. "," .. reachable[1].row)
    end
end

--@api: LHexGrid:findPath
do

    local hex = lurek.pathfind.newHexGrid(10, 10)

    hex:setBlocked(5, 3, true)
    hex:setBlocked(5, 4, true)
    hex:setBlocked(5, 5, true)

    local path = hex:findPath(1, 5, 10, 5)
    if path then
        lurek.log.info("steps = " .. #path)
        lurek.log.info("first = " .. path[1].col .. "," .. path[1].row)
        lurek.log.info("last = " .. path[#path].col .. "," .. path[#path].row)
    else
        lurek.log.info("steps = 0")
    end
end

--@api: LHexGrid:distance
do

    local hex = lurek.pathfind.newHexGrid(10, 10)
    hex:setBlocked(3, 3, true)
    local flank_distance = hex:distance(1, 1, 5, 5)
    local same_cell_distance = hex:distance(1, 1, 1, 1)
    local scout_distance = hex:distance(2, 4, 7, 4)

    lurek.log.info("flank distance = " .. flank_distance)
    lurek.log.info("same cell distance = " .. same_cell_distance)
    lurek.log.info("frontline distance = " .. scout_distance)
end

--@api: LHexGrid:fieldOfView
do

    local hex = lurek.pathfind.newHexGrid(15, 15)

    hex:setBlocked(8, 8, true)

    local visible = hex:fieldOfView(7, 7, 3)
    lurek.log.info("visible = " .. #visible)
    if #visible > 0 then
        lurek.log.info("first = " .. visible[1].col .. "," .. visible[1].row)
    end
end

--@api: LHexGrid:rangeOfMovement
do

    local hex = lurek.pathfind.newHexGrid(12, 12)

    hex:setCost(6, 6, 3)

    local reachable = hex:rangeOfMovement(6, 6, 4)
    lurek.log.info("reachable = " .. #reachable)
    if #reachable > 0 then
        lurek.log.info("first = " .. reachable[1].col .. "," .. reachable[1].row)
    end
end

--@api: LHexGrid:type
do

    local hex = lurek.pathfind.newHexGrid(5, 5, "pointy")
    hex:setCost(3, 3, 2)
    local type_name = hex:type()
    local reachable = hex:rangeOfMovement(3, 3, 3)

    lurek.log.info("hex grid type = " .. type_name)
    lurek.log.info("reachable cells = " .. #reachable)
    lurek.log.info("center blocked = " .. tostring(hex:isBlocked(3, 3)))
end

--@api: LHexGrid:typeOf
do

    local hex = lurek.pathfind.newHexGrid(5, 5, "pointy")
    hex:setBlocked(2, 2, true)
    local is_hex_grid = hex:typeOf("LHexGrid")
    local is_object = hex:typeOf("LObject")
    local is_jps_grid = hex:typeOf("LJpsGrid")

    lurek.log.info("matches LHexGrid = " .. tostring(is_hex_grid))
    lurek.log.info("matches LObject = " .. tostring(is_object))
    lurek.log.info("matches LJpsGrid = " .. tostring(is_jps_grid))
end

--@api: lurek.pathfind.newJpsGrid
do

    local jps = lurek.pathfind.newJpsGrid(30, 30)

    jps:setBlocked(15, 10, true)
    jps:setBlocked(15, 11, true)
    jps:setBlocked(15, 12, true)

    lurek.log.info("blocked_15_10 = " .. tostring(jps:isBlocked(15, 10)))
    lurek.log.info("blocked_1_1 = " .. tostring(jps:isBlocked(1, 1)))
end

--@api: LJpsGrid:setBlocked
do

    local jps = lurek.pathfind.newJpsGrid(30, 30)

    jps:setBlocked(15, 10, true)
    jps:setBlocked(15, 11, true)
    jps:setBlocked(15, 12, true)

    lurek.log.info("blocked_15_10 = " .. tostring(jps:isBlocked(15, 10)))
    lurek.log.info("blocked_15_12 = " .. tostring(jps:isBlocked(15, 12)))
end

--@api: LJpsGrid:isBlocked
do

    local jps = lurek.pathfind.newJpsGrid(30, 30)
    jps:setBlocked(9, 9, true)
    jps:setBlocked(10, 9, true)
    local wall_center = jps:isBlocked(9, 9)
    local wall_neighbor = jps:isBlocked(10, 9)
    local lane_open = jps:isBlocked(9, 10)

    lurek.log.info("wall center blocked = " .. tostring(wall_center))
    lurek.log.info("wall neighbor blocked = " .. tostring(wall_neighbor))
    lurek.log.info("lane blocked = " .. tostring(lane_open))
end

--@api: LJpsGrid:findPath
do

    local jps = lurek.pathfind.newJpsGrid(50, 50)

    for y = 10, 40 do
        jps:setBlocked(25, y, true)
    end
    jps:setBlocked(25, 30, false)

    local path = jps:findPath(1, 25, 50, 25)
    if path then
        lurek.log.info("points = " .. #path)
        lurek.log.info("first = " .. path[1].x .. "," .. path[1].y)
        lurek.log.info("last = " .. path[#path].x .. "," .. path[#path].y)
    else
        lurek.log.info("points = 0")
    end
end

--@api: LJpsGrid:type
do

    local jps = lurek.pathfind.newJpsGrid(5, 5)
    jps:setBlocked(3, 3, true)
    local type_name = jps:type()
    local blocked_center = jps:isBlocked(3, 3)
    local path = jps:findPath(1, 1, 5, 5)

    lurek.log.info("jps grid type = " .. type_name)
    lurek.log.info("center blocked = " .. tostring(blocked_center))
    lurek.log.info("corner route nodes = " .. tostring(path and #path or 0))
end

--@api: LJpsGrid:typeOf
do

    local jps = lurek.pathfind.newJpsGrid(5, 5)
    jps:setBlocked(2, 2, true)
    local is_jps_grid = jps:typeOf("LJpsGrid")
    local is_object = jps:typeOf("LObject")
    local is_hex_grid = jps:typeOf("LHexGrid")

    lurek.log.info("matches LJpsGrid = " .. tostring(is_jps_grid))
    lurek.log.info("matches LObject = " .. tostring(is_object))
    lurek.log.info("matches LHexGrid = " .. tostring(is_hex_grid))
end

--- Pathfinding Module Part 3: flow fields, AI flow fields, unit pathfinder

--@api: lurek.pathfind.newFlowField
do

    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)
    nav:setBlocked(10, 5, true)
    nav:setBlocked(10, 6, true)
    nav:setBlocked(10, 7, true)

    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(20, 10)

    lurek.log.info("calculated = " .. tostring(ff:isCalculated()))
    lurek.log.info("targets = " .. #ff:getTargets())
end

--@api: LFlowField:calculate
do

    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)

    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(20, 10)

    lurek.log.info("calculated = " .. tostring(ff:isCalculated()))
    lurek.log.info("targets = " .. #ff:getTargets())
end

--@api: LFlowField:getDirection
do

    local nav = lurek.pathfind.newNavGrid(10, 10)

    nav:fill(1)

    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(10, 10)

    local dx, dy = ff:getDirection(1, 1)
    lurek.log.info("dir = " .. dx .. "," .. dy)
    lurek.log.info("angle = " .. ff:getDirectionAngle(1, 1))
    lurek.log.info("cost = " .. ff:getCostToTarget(1, 1))
end

--@api: LFlowField:getDirectionAngle
do

    local nav = lurek.pathfind.newNavGrid(10, 10)

    nav:fill(1)

    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(10, 10)

    lurek.log.info("angle = " .. ff:getDirectionAngle(1, 1))
    lurek.log.info("cost = " .. ff:getCostToTarget(1, 1))
end

--@api: LFlowField:getCostToTarget
do

    local nav = lurek.pathfind.newNavGrid(10, 10)

    nav:fill(1)

    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(10, 10)

    local dx, dy = ff:getDirection(1, 1)
    lurek.log.info("dir = " .. dx .. "," .. dy)
    lurek.log.info("cost = " .. ff:getCostToTarget(1, 1))
end

--@api: LFlowField:calculateMulti
do

    local nav = lurek.pathfind.newNavGrid(15, 15)

    nav:fill(1)

    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculateMulti({
        { x = 5, y = 5 },
        { x = 10, y = 10 },
    })

    local targets = ff:getTargets()
    lurek.log.info("targets = " .. #targets)
    lurek.log.info("first = " .. targets[1].x .. "," .. targets[1].y)
    lurek.log.info("last = " .. targets[#targets].x .. "," .. targets[#targets].y)
end

--@api: LFlowField:calculateFor
do

    local nav = lurek.pathfind.newNavGrid(15, 15)

    nav:fill(1)
    nav:defineFootprint("tank", { w = 2, h = 2 })
    nav:setBlocked(2, 2, true)

    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculateFor("tank", 10, 10)

    lurek.log.info("builds = " .. ff:getBuildCount())
    lurek.log.info("start cost = " .. tostring(ff:getCostToTarget(1, 1)))
end

--@api: LFlowField:calculateMultiFor
do

    local nav = lurek.pathfind.newNavGrid(15, 15)

    nav:fill(1)
    nav:defineFootprint("tank", { w = 2, h = 2 })

    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculateMultiFor("tank", {
        { x = 5, y = 5 },
        { x = 10, y = 10 },
    })

    local targets = ff:getTargets()
    lurek.log.info("targets = " .. #targets)
    lurek.log.info("generation = " .. tostring(ff:getGeneration()))
end

--@api: LFlowField:getGeneration
do

    local nav = lurek.pathfind.newNavGrid(12, 12)

    nav:fill(1)

    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(8, 8)
    local before = ff:getGeneration()
    nav:setBlocked(2, 2, true)
    ff:calculate(8, 8)
    local after = ff:getGeneration()

    lurek.log.info("flow generation before = " .. tostring(before))
    lurek.log.info("flow generation after = " .. tostring(after))
end

--@api: LFlowField:getBuildCount
do

    local nav = lurek.pathfind.newNavGrid(12, 12)

    nav:fill(1)

    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(8, 8)
    ff:calculate(8, 8)
    nav:setBlocked(3, 3, true)
    ff:calculate(8, 8)

    lurek.log.info("rebuild count = " .. tostring(ff:getBuildCount()))
    lurek.log.info("targets = " .. #ff:getTargets())
end

--@api: LFlowField:getTargets
do

    local nav = lurek.pathfind.newNavGrid(15, 15)

    nav:fill(1)

    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculateMulti({
        { x = 4, y = 4 },
        { x = 12, y = 12 },
    })

    local targets = ff:getTargets()
    lurek.log.info("targets = " .. #targets)
    lurek.log.info("first = " .. targets[1].x .. "," .. targets[1].y)
end

--@api: LFlowField:pathFrom
do

    local nav = lurek.pathfind.newNavGrid(12, 12)

    nav:fill(1)

    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(10, 10)

    local path = ff:pathFrom(1, 1)
    lurek.log.info("path nodes = " .. tostring(path and #path or 0))
    lurek.log.info("last = " .. path[#path].x .. "," .. path[#path].y)
end

--@api: LFlowField:pathsFrom
do

    local nav = lurek.pathfind.newNavGrid(12, 12)

    nav:fill(1)

    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(10, 10)

    local routes = ff:pathsFrom({
        { x = 1, y = 1 },
        { x = 3, y = 3 },
        { x = 10, y = 10 },
    })

    lurek.log.info("route1 nodes = " .. tostring(routes[1] and #routes[1] or 0))
    lurek.log.info("route3 last = " .. routes[3][#routes[3]].x .. "," .. routes[3][#routes[3]].y)
end

--@api: LFlowField:steer
do

    local nav = lurek.pathfind.newNavGrid(10, 10)

    nav:fill(1)

    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(10, 10)

    local vx, vy = ff:steer(50, 50, 100, 32, 32)
    lurek.log.info("velocity = " .. vx .. "," .. vy)
end

--@api: LFlowField:type
do

    local nav = lurek.pathfind.newNavGrid(5, 5)
    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(5, 5)
    local type_name = ff:type()
    local calculated = ff:isCalculated()
    local targets = ff:getTargets()

    lurek.log.info("flow field type = " .. type_name)
    lurek.log.info("calculated = " .. tostring(calculated))
    lurek.log.info("target count = " .. #targets)
end

--@api: LFlowField:typeOf
do

    local nav = lurek.pathfind.newNavGrid(5, 5)
    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(4, 4)
    local is_flow_field = ff:typeOf("LFlowField")
    local is_object = ff:typeOf("LObject")
    local is_ai_flow_field = ff:typeOf("LAIFlowField")

    lurek.log.info("matches LFlowField = " .. tostring(is_flow_field))
    lurek.log.info("matches LObject = " .. tostring(is_object))
    lurek.log.info("matches LAIFlowField = " .. tostring(is_ai_flow_field))
end

--@api: lurek.pathfind.newPathFlowField
do

    local grid = lurek.pathfind.newPathGrid(15, 15, 32)
    local aiff = lurek.pathfind.newPathFlowField(grid)

    aiff:setGoal(10, 10)

    local gx, gy = aiff:getGoal()
    lurek.log.info("dims = " .. aiff:getWidth() .. "x" .. aiff:getHeight())
    lurek.log.info("has_goal = " .. tostring(aiff:hasGoal()))
    lurek.log.info("goal = " .. gx .. "," .. gy)
end

--@api: LAIFlowField:setGoal
do

    local grid = lurek.pathfind.newPathGrid(15, 15, 32)
    local aiff = lurek.pathfind.newPathFlowField(grid)

    aiff:setGoal(10, 10)

    local gx, gy = aiff:getGoal()
    lurek.log.info("has_goal = " .. tostring(aiff:hasGoal()))
    lurek.log.info("goal = " .. gx .. "," .. gy)
end

--@api: LAIFlowField:getGoal
do

    local grid = lurek.pathfind.newPathGrid(15, 15, 32)
    local aiff = lurek.pathfind.newPathFlowField(grid)

    aiff:setGoal(10, 10)

    local gx, gy = aiff:getGoal()
    lurek.log.info("goal = " .. gx .. "," .. gy)
    lurek.log.info("has_goal = " .. tostring(aiff:hasGoal()))
end

--@api: LAIFlowField:getDirection
do

    local grid = lurek.pathfind.newPathGrid(10, 10, 16)
    local aiff = lurek.pathfind.newPathFlowField(grid)

    aiff:setGoal(10, 10)

    local dx, dy = aiff:getDirection(1, 1)
    lurek.log.info("dir = " .. dx .. "," .. dy)
    lurek.log.info("distance = " .. aiff:getDistance(1, 1))
end

--@api: LAIFlowField:getDistance
do

    local grid = lurek.pathfind.newPathGrid(10, 10, 16)
    local aiff = lurek.pathfind.newPathFlowField(grid)

    aiff:setGoal(10, 10)

    local dx, dy = aiff:getDirection(1, 1)
    lurek.log.info("dir = " .. dx .. "," .. dy)
    lurek.log.info("distance = " .. aiff:getDistance(1, 1))
end

--@api: LAIFlowField:type
do

    local grid = lurek.pathfind.newPathGrid(5, 5, 32)
    local aiff = lurek.pathfind.newPathFlowField(grid)
    aiff:setGoal(5, 5)
    local type_name = aiff:type()
    local width = aiff:getWidth()
    local height = aiff:getHeight()

    lurek.log.info("ai flow field type = " .. type_name)
    lurek.log.info("field dims = " .. width .. "x" .. height)
    lurek.log.info("goal ready = " .. tostring(aiff:hasGoal()))
end

--@api: LAIFlowField:typeOf
do

    local grid = lurek.pathfind.newPathGrid(5, 5, 32)
    local aiff = lurek.pathfind.newPathFlowField(grid)
    aiff:setGoal(4, 4)
    local is_ai_flow_field = aiff:typeOf("LAIFlowField")
    local is_object = aiff:typeOf("LObject")
    local is_flow_field = aiff:typeOf("LFlowField")

    lurek.log.info("matches LAIFlowField = " .. tostring(is_ai_flow_field))
    lurek.log.info("matches LObject = " .. tostring(is_object))
    lurek.log.info("matches LFlowField = " .. tostring(is_flow_field))
end

--@api: lurek.pathfind.newPathfinder
do

    local nav = lurek.pathfind.newNavGrid(30, 30)

    nav:fill(1)
    nav:setBlocked(15, 10, true)
    nav:setBlocked(15, 11, true)
    nav:setBlocked(15, 12, true)
    nav:setBlocked(15, 13, true)

    local pf = lurek.pathfind.newPathfinder(nav)
    local path = pf:findPath(1, 12, 30, 12)
    if path then
        lurek.log.info("steps = " .. #path)
        lurek.log.info("first = " .. path[1].x .. "," .. path[1].y)
        lurek.log.info("last = " .. path[#path].x .. "," .. path[#path].y)
    else
        lurek.log.info("steps = 0")
    end
end

--@api: LUnitPathfinder:findPath
do

    local nav = lurek.pathfind.newNavGrid(30, 30)

    nav:fill(1)
    nav:setBlocked(15, 10, true)
    nav:setBlocked(15, 11, true)
    nav:setBlocked(15, 12, true)
    nav:setBlocked(15, 13, true)

    local pf = lurek.pathfind.newPathfinder(nav)
    local path = pf:findPath(1, 12, 30, 12)
    if path then
        lurek.log.info("steps = " .. #path)
        lurek.log.info("first = " .. path[1].x .. "," .. path[1].y)
        lurek.log.info("last = " .. path[#path].x .. "," .. path[#path].y)
    else
        lurek.log.info("steps = 0")
    end
end

--@api: LUnitPathfinder:findPathSmooth
do

    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    local path = pf:findPathSmooth(1, 1, 20, 20)
    if path then
        lurek.log.info("points = " .. #path)
        lurek.log.info("first = " .. path[1].x .. "," .. path[1].y)
        lurek.log.info("last = " .. path[#path].x .. "," .. path[#path].y)
    else
        lurek.log.info("points = 0")
    end
end

--@api: LUnitPathfinder:findPathBidirectional
do

    local nav = lurek.pathfind.newNavGrid(40, 40)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    local path, complete = pf:findPathBidirectional(1, 1, 40, 40, 1, 500)
    if path then
        lurek.log.info("points = " .. #path)
        lurek.log.info("complete = " .. tostring(complete))
        lurek.log.info("last = " .. path[#path].x .. "," .. path[#path].y)
    else
        lurek.log.info("complete = " .. tostring(complete))
    end
end

--@api: LUnitPathfinder:findPartialPath
do

    local nav = lurek.pathfind.newNavGrid(100, 100)

    nav:fill(1)
    nav:fillRect(40, 1, 1, 100, 0)
    nav:fillRect(40, 50, 1, 1, 1)

    local pf = lurek.pathfind.newPathfinder(nav)
    local path, reached = pf:findPartialPath(1, 1, 100, 100, 50)

    lurek.log.info("points = " .. #path)
    lurek.log.info("reached = " .. tostring(reached))
    lurek.log.info("last = " .. path[#path].x .. "," .. path[#path].y)
end

--@api: LUnitPathfinder:isReachable
do

    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)
    nav:fillRect(10, 1, 1, 20, 0)

    local pf = lurek.pathfind.newPathfinder(nav)

    lurek.log.info("reachable_left = " .. tostring(pf:isReachable(1, 1, 9, 9)))
    lurek.log.info("reachable_right = " .. tostring(pf:isReachable(1, 1, 20, 20)))
end

--@api: LUnitPathfinder:heuristicDistance
do

    local nav = lurek.pathfind.newNavGrid(20, 20)
    local pf = lurek.pathfind.newPathfinder(nav)
    nav:setBlocked(10, 10, true)
    local map_corner = pf:heuristicDistance(1, 1, 20, 20)
    local same_cell = pf:heuristicDistance(5, 5, 5, 5)
    local front_line = pf:heuristicDistance(2, 10, 18, 10)

    lurek.log.info("corner estimate = " .. map_corner)
    lurek.log.info("same cell estimate = " .. same_cell)
    lurek.log.info("front line estimate = " .. front_line)
end

--@api: LUnitPathfinder:findNearestWalkable
do

    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)
    nav:setBlocked(10, 10, true)
    nav:setBlocked(11, 10, true)
    nav:setBlocked(10, 11, true)
    nav:setBlocked(11, 11, true)

    local pf = lurek.pathfind.newPathfinder(nav)
    local nx, ny = pf:findNearestWalkable(10, 10, 5)

    lurek.log.info("nearest = " .. nx .. "," .. ny)
end

--@api: LUnitPathfinder:getPathCost
do

    local nav = lurek.pathfind.newNavGrid(10, 10)

    nav:fill(1)
    nav:setCost(5, 5, 4)

    local pf = lurek.pathfind.newPathfinder(nav)
    local path = pf:findPath(1, 1, 10, 10)
    if path then
        lurek.log.info("cost = " .. pf:getPathCost(path))
        lurek.log.info("length = " .. pf:getPathLength(path))
    else
        lurek.log.info("cost = 0")
    end
end

--@api: LUnitPathfinder:getPathLength
do

    local nav = lurek.pathfind.newNavGrid(10, 10)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    local path = pf:findPath(1, 1, 10, 10)
    if path then
        lurek.log.info("length = " .. pf:getPathLength(path))
        lurek.log.info("cost = " .. pf:getPathCost(path))
    else
        lurek.log.info("length = 0")
    end
end

--@api: LUnitPathfinder:setCacheEnabled
do

    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    pf:setCacheEnabled(true)
    pf:setCacheMaxSize(100)
    pf:findPath(1, 1, 20, 20)
    pf:findPath(5, 5, 15, 15)

    lurek.log.info("enabled = " .. tostring(pf:isCacheEnabled()))
    lurek.log.info("cache_size = " .. pf:getCacheSize())
    pf:clearCache()
    lurek.log.info("cache_after_clear = " .. pf:getCacheSize())
end

--@api: LUnitPathfinder:isCacheEnabled
do

    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    pf:setCacheEnabled(true)
    local enabled = pf:isCacheEnabled()
    pf:setCacheEnabled(false)

    lurek.log.info("enabled_before_disable = " .. tostring(enabled))
    lurek.log.info("enabled_after_disable = " .. tostring(pf:isCacheEnabled()))
end

--@api: LUnitPathfinder:setCacheMaxSize
do

    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    pf:setCacheEnabled(true)
    pf:setCacheMaxSize(2)
    pf:findPath(1, 1, 20, 20)
    pf:findPath(2, 2, 19, 19)
    pf:findPath(3, 3, 18, 18)

    lurek.log.info("cache_size = " .. pf:getCacheSize())
end

--@api: LUnitPathfinder:getCacheSize
do

    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    pf:setCacheEnabled(true)
    pf:findPath(1, 1, 20, 20)
    pf:findPath(5, 5, 15, 15)

    lurek.log.info("cache_size = " .. pf:getCacheSize())
end

--@api: LUnitPathfinder:findPathsToGoal
do

    local nav = lurek.pathfind.newNavGrid(30, 30)

    nav:fill(1)
    nav:setBlocked(15, 10, true)
    nav:setBlocked(15, 11, true)
    nav:setBlocked(15, 12, true)

    local pf = lurek.pathfind.newPathfinder(nav)
    local routes = pf:findPathsToGoal({
        { x = 1, y = 12 },
        { x = 2, y = 14 },
        { x = 5, y = 20 },
    }, 30, 12)

    lurek.log.info("shared routes = " .. tostring(#routes))
    lurek.log.info("first nodes = " .. tostring(routes[1] and #routes[1] or 0))
end

--@api: LUnitPathfinder:findPathsToGoalFor
do

    local nav = lurek.pathfind.newNavGrid(30, 30)

    nav:fill(1)
    nav:defineFootprint("tank", { w = 2, h = 2 })
    nav:setBlocked(2, 2, true)

    local pf = lurek.pathfind.newPathfinder(nav)
    local routes = pf:findPathsToGoalFor("tank", {
        { x = 1, y = 1 },
        { x = 5, y = 5 },
        { x = 8, y = 8 },
    }, 25, 25)

    lurek.log.info("blocked start nil = " .. tostring(routes[1] == nil))
    lurek.log.info("second nodes = " .. tostring(routes[2] and #routes[2] or 0))
end

--@api: LUnitPathfinder:clearSharedGoalCache
do

    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    pf:findPathsToGoal({ { x = 1, y = 1 } }, 20, 20)
    local before = pf:getSharedGoalCacheSize()
    pf:clearSharedGoalCache()

    lurek.log.info("shared cache before = " .. tostring(before))
    lurek.log.info("shared cache after = " .. tostring(pf:getSharedGoalCacheSize()))
end

--@api: LUnitPathfinder:getSharedGoalCacheSize
do

    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    pf:findPathsToGoal({ { x = 1, y = 1 }, { x = 3, y = 3 } }, 20, 20)

    lurek.log.info("shared cache size = " .. tostring(pf:getSharedGoalCacheSize()))
    lurek.log.info("path cache size = " .. tostring(pf:getCacheSize()))
end

--@api: LUnitPathfinder:getSharedFlowField
do

    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    local flow = pf:getSharedFlowField(20, 20)
    local path = flow:pathFrom(1, 1)

    lurek.log.info("shared flow targets = " .. tostring(#flow:getTargets()))
    lurek.log.info("path last = " .. path[#path].x .. "," .. path[#path].y)
end

--@api: LUnitPathfinder:getSharedFlowFieldFor
do

    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)
    nav:defineFootprint("tank", { w = 2, h = 2 })
    nav:setBlocked(2, 2, true)

    local pf = lurek.pathfind.newPathfinder(nav)
    local flow = pf:getSharedFlowFieldFor("tank", 18, 18)

    lurek.log.info("tank start cost = " .. tostring(flow:getCostToTarget(1, 1)))
    lurek.log.info("open lane cost = " .. tostring(flow:getCostToTarget(5, 5)))
end

--@api: LUnitPathfinder:getSharedFlowFieldMulti
do

    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    local flow = pf:getSharedFlowFieldMulti({
        { x = 18, y = 18 },
        { x = 20, y = 20 },
    })

    lurek.log.info("shared multi targets = " .. tostring(#flow:getTargets()))
    lurek.log.info("cache size = " .. tostring(pf:getSharedGoalCacheSize()))
end

--@api: LUnitPathfinder:getSharedFlowFieldMultiFor
do

    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)
    nav:defineFootprint("tank", { w = 2, h = 2 })

    local pf = lurek.pathfind.newPathfinder(nav)
    local flow = pf:getSharedFlowFieldMultiFor("tank", {
        { x = 16, y = 16 },
        { x = 18, y = 18 },
    })

    lurek.log.info("footprint targets = " .. tostring(#flow:getTargets()))
    lurek.log.info("builds = " .. tostring(flow:getBuildCount()))
end

--@api: LUnitPathfinder:getSharedGoalCacheStats
do

    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    pf:getSharedFlowField(20, 20)
    pf:getSharedFlowField(20, 20)
    local stats = pf:getSharedGoalCacheStats()

    lurek.log.info("shared hits = " .. tostring(stats.hits))
    lurek.log.info("shared misses = " .. tostring(stats.misses))
end

--@api: LUnitPathfinder:clearCache
do

    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    pf:setCacheEnabled(true)
    pf:findPath(1, 1, 20, 20)

    lurek.log.info("cache_before_clear = " .. pf:getCacheSize())
    pf:clearCache()
    lurek.log.info("cache_after_clear = " .. pf:getCacheSize())
end

--@api: LUnitPathfinder:type
do

    local nav = lurek.pathfind.newNavGrid(5, 5)
    local pf = lurek.pathfind.newPathfinder(nav)
    nav:fill(1)
    local type_name = pf:type()
    local path = pf:findPath(1, 1, 5, 5)
    local cache_enabled = pf:isCacheEnabled()

    lurek.log.info("pathfinder type = " .. type_name)
    lurek.log.info("route nodes = " .. tostring(path and #path or 0))
    lurek.log.info("cache enabled = " .. tostring(cache_enabled))
end

--@api: LUnitPathfinder:typeOf
do

    local nav = lurek.pathfind.newNavGrid(5, 5)
    local pf = lurek.pathfind.newPathfinder(nav)
    nav:fill(1)
    local is_pathfinder = pf:typeOf("LUnitPathfinder")
    local is_object = pf:typeOf("LObject")
    local is_nav_grid = pf:typeOf("LNavGrid")

    lurek.log.info("matches LUnitPathfinder = " .. tostring(is_pathfinder))
    lurek.log.info("matches LObject = " .. tostring(is_object))
    lurek.log.info("matches LNavGrid = " .. tostring(is_nav_grid))
end

--@api: lurek.pathfind.rangeMap
do

    local result = lurek.pathfind.rangeMap({
        width = 10,
        height = 10,
        origin_x = 5,
        origin_y = 5,
        budget = 4,
        diagonal = true,
    })

    lurek.log.info("dims = " .. result.width .. "x" .. result.height)
    lurek.log.info("cells = " .. #result.cells)
    if #result.cells > 0 then
        lurek.log.info("first = " .. result.cells[1].x .. "," .. result.cells[1].y .. "," .. result.cells[1].cost)
    end
end

--@api: lurek.pathfind.getThreadCount
do

    local tc = lurek.pathfind.getThreadCount()
    local nav = lurek.pathfind.newNavGrid(8, 8)
    nav:setBlocked(4, 4, true)
    local pending = lurek.pathfind.getAsyncPendingCount()

    lurek.log.info("thread count = " .. tc)
    lurek.log.info("pending async jobs = " .. pending)
    lurek.log.info("sample grid blocked = " .. tostring(nav:isBlocked(4, 4)))
end

--- Pathfind Module Part 4: AI flow field state, nav dimensions, tilemap nav grids, thread count

--@api: LAIFlowField:getHeight
do

    local pg = lurek.pathfind.newPathGrid(32, 32, 1)
    local ff = lurek.pathfind.newPathFlowField(pg)

    ff:setGoal(16, 16)

    lurek.log.info("dims = " .. ff:getWidth() .. "x" .. ff:getHeight())
    lurek.log.info("has_goal = " .. tostring(ff:hasGoal()))
end

--@api: LAIFlowField:getWidth
do

    local pg = lurek.pathfind.newPathGrid(32, 32, 1)
    local ff = lurek.pathfind.newPathFlowField(pg)

    ff:setGoal(16, 16)

    lurek.log.info("dims = " .. ff:getWidth() .. "x" .. ff:getHeight())
    lurek.log.info("has_goal = " .. tostring(ff:hasGoal()))
end

--@api: LAIFlowField:hasGoal
do

    local pg = lurek.pathfind.newPathGrid(32, 32, 1)
    local ff = lurek.pathfind.newPathFlowField(pg)

    lurek.log.info("has_goal_before = " .. tostring(ff:hasGoal()))
    ff:setGoal(16, 16)
    lurek.log.info("has_goal_after = " .. tostring(ff:hasGoal()))
end

--@api: LFlowField:isCalculated
do

    local grid = lurek.pathfind.newNavGrid(16, 16)
    local ff = lurek.pathfind.newFlowField(grid)

    lurek.log.info("calculated_before = " .. tostring(ff:isCalculated()))
    ff:calculate(8, 8, 1)
    lurek.log.info("calculated_after = " .. tostring(ff:isCalculated()))
end

--@api: LNavGrid:getDimensions
do

    local ng = lurek.pathfind.newNavGrid(20, 15)
    local w, h = ng:getDimensions()
    ng:setBlocked(10, 8, true)
    local width = ng:getWidth()
    local height = ng:getHeight()

    lurek.log.info("nav dims = " .. w .. "x" .. h)
    lurek.log.info("width via getter = " .. width)
    lurek.log.info("height via getter = " .. height)
end

--@api: LNavGrid:getGeneration
do

    local ng = lurek.pathfind.newNavGrid(20, 15)
    local before = ng:getGeneration()
    ng:setBlocked(10, 8, true)
    local after = ng:getGeneration()

    lurek.log.info("generation before = " .. before)
    lurek.log.info("generation after = " .. after)
end

--@api: LNavGrid:getHeight
do

    local ng = lurek.pathfind.newNavGrid(20, 15)
    local w, h = ng:getDimensions()
    local height = ng:getHeight()

    lurek.log.info("dims = " .. w .. "x" .. h)
    lurek.log.info("height = " .. height)
end

--@api: LNavGrid:getWidth
do

    local ng = lurek.pathfind.newNavGrid(20, 15)
    local w, h = ng:getDimensions()
    local width = ng:getWidth()

    lurek.log.info("dims = " .. w .. "x" .. h)
    lurek.log.info("width = " .. width)
end

--@api: LNavMesh:getPolygonCount
do

    local mesh = lurek.pathfind.newNavMesh()
    local id = mesh:addPolygon({
        { x = 0, y = 0 },
        { x = 64, y = 0 },
        { x = 32, y = 48 },
    })

    lurek.log.info("polygon_count = " .. mesh:getPolygonCount())
    lurek.log.info("first_id = " .. id)
end

--@api: LPathGrid:getCellSize
do

    local pg = lurek.pathfind.newPathGrid(10, 10, 32)
    pg:setWalkable(5, 5, false)
    local cell_size = pg:getCellSize()
    local dims = pg:getWidth() .. "x" .. pg:getHeight()
    local center_open = pg:isWalkable(5, 5)

    lurek.log.info("cell size = " .. cell_size)
    lurek.log.info("path grid dims = " .. dims)
    lurek.log.info("center open = " .. tostring(center_open))
end

--@api: LPathGrid:getHeight
do

    local pg = lurek.pathfind.newPathGrid(10, 10, 32)
    pg:setCost(6, 6, 4)
    local height = pg:getHeight()
    local width = pg:getWidth()
    local center_cost = pg:getCost(6, 6)

    lurek.log.info("height = " .. height)
    lurek.log.info("width = " .. width)
    lurek.log.info("center cost = " .. center_cost)
end

--@api: LPathGrid:getWidth
do

    local pg = lurek.pathfind.newPathGrid(10, 10, 32)
    pg:setCost(4, 4, 3)
    local width = pg:getWidth()
    local height = pg:getHeight()
    local cell_size = pg:getCellSize()

    lurek.log.info("width = " .. width)
    lurek.log.info("height = " .. height)
    lurek.log.info("cell size = " .. cell_size)
end

--@api: lurek.pathfind.newNavGridFromTileMap
do

    local tm = lurek.tilemap.newTileMap(16, 16, 8)
    local layer_index = tm:addLayer("ground", 8, 8)

    tm:setTile(layer_index, 3, 3, 2)
    tm:setTile(layer_index, 4, 3, 1)

    local ng = lurek.pathfind.newNavGridFromTileMap(tm, layer_index, { 2 })

    lurek.log.info("dims = " .. ng:getWidth() .. "x" .. ng:getHeight())
    lurek.log.info("blocked_3_3 = " .. tostring(ng:isBlocked(3, 3)))
    lurek.log.info("blocked_4_3 = " .. tostring(ng:isBlocked(4, 3)))
end

--@api: lurek.pathfind.setThreadCount
do

    local previous = lurek.pathfind.getThreadCount()
    local target = previous < 2 and 2 or previous

    lurek.pathfind.setThreadCount(target)
    local actual = lurek.pathfind.getThreadCount()
    local nav = lurek.pathfind.newNavGrid(6, 6)

    lurek.log.info("thread count target = " .. target)
    lurek.log.info("thread count actual = " .. actual)
    lurek.log.info("worker sample dims = " .. nav:getWidth() .. "x" .. nav:getHeight())
end

--@api: lurek.pathfind.submitAsyncPath
do

    lurek.pathfind.clearAsyncPaths()
    local nav = lurek.pathfind.newNavGrid(24, 24)
    local request_id = lurek.pathfind.submitAsyncPath(nav, {
        start_x = 1,
        start_y = 1,
        goal_x = 24,
        goal_y = 24,
        stream_budget = 4,
    })
    lurek.log.info("request_id = " .. tostring(request_id))
end

--@api: lurek.pathfind.submitAsyncPathsToGoal
do

    lurek.pathfind.clearAsyncPaths()
    local nav = lurek.pathfind.newNavGrid(32, 32)
    local request_id = lurek.pathfind.submitAsyncPathsToGoal(nav, {
        starts = {
            { x = 1, y = 1 },
            { x = 2, y = 2 },
            { x = 6, y = 6 },
        },
        goal_x = 32,
        goal_y = 32,
    })
    lurek.log.info("grouped_request_id = " .. tostring(request_id))
end

--@api: lurek.pathfind.submitAsyncPathPairs
do

    lurek.pathfind.clearAsyncPaths()
    local nav = lurek.pathfind.newNavGrid(32, 32)
    local request_id = lurek.pathfind.submitAsyncPathPairs(nav, {
        pairs = {
            { start = { x = 1, y = 1 }, goal = { x = 32, y = 32 } },
            { start = { x = 2, y = 2 }, goal = { x = 32, y = 32 } },
            { start = { x = 6, y = 6 }, goal = { x = 20, y = 20 } },
        },
    })
    lurek.log.info("paired_request_id = " .. tostring(request_id))
end

--@api: lurek.pathfind.pollAsyncPaths
do

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
    lurek.log.info("request = " .. tostring(request_id))
    lurek.log.info("events = " .. tostring(#seen))
end

--@api: lurek.pathfind.cancelAsyncPath
do

    lurek.pathfind.clearAsyncPaths()
    local nav = lurek.pathfind.newNavGrid(24, 24)
    local request_id = lurek.pathfind.submitAsyncPath(nav, {
        start_x = 1,
        start_y = 1,
        goal_x = 24,
        goal_y = 24,
        stream_budget = 4,
    })
    lurek.log.info("cancelled = " .. tostring(lurek.pathfind.cancelAsyncPath(request_id)))
end

--@api: lurek.pathfind.getAsyncPendingCount
do

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
    lurek.log.info("pending_before = " .. tostring(before))
    lurek.log.info("pending_after = " .. tostring(after))
    lurek.pathfind.clearAsyncPaths()
end

--@api: lurek.pathfind.clearAsyncPaths
do

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
    lurek.log.info("pending = " .. tostring(lurek.pathfind.getAsyncPendingCount()))
end

--@api: lurek.pathfind.newGoalMap
do

    local gm = lurek.pathfind.newGoalMap(16, 16)
    gm:addSource(8, 8, 1)
    gm:bake()
    local ready = gm:isReady()
    local center_distance = gm:distanceAt(8, 8)

    lurek.log.info("goal map type = " .. gm:type())
    lurek.log.info("goal map ready = " .. tostring(ready))
    lurek.log.info("center distance = " .. center_distance)
end

--@api: LGoalMap:addSource
do

    local gm = lurek.pathfind.newGoalMap(16, 16)
    gm:addSource(8, 8, 1)
    gm:addSource(4, 12, 2)
    gm:bake()
    local origin_distance = gm:distanceAt(8, 8)
    local flank_distance = gm:distanceAt(4, 12)
    local corner_distance = gm:distanceAt(1, 1)

    lurek.log.info("origin distance = " .. origin_distance)
    lurek.log.info("flank source distance = " .. flank_distance)
    lurek.log.info("corner distance = " .. corner_distance)
end

--@api: LGoalMap:setSources
do

    local gm = lurek.pathfind.newGoalMap(16, 16)
    gm:setSources({
        { x = 4, y = 4, weight = 1 },
        { x = 13, y = 13, weight = 2 },
    })
    gm:bake()
    lurek.log.info("ready = " .. tostring(gm:isReady()))
end

--@api: LGoalMap:clearSources
do

    local gm = lurek.pathfind.newGoalMap(16, 16)
    gm:addSource(8, 8, 1)
    gm:clearSources()
    gm:bake()
    lurek.log.info("ready_after_clear = " .. tostring(gm:isReady()))
end

--@api: LGoalMap:setBlocker
do

    local gm = lurek.pathfind.newGoalMap(16, 16)
    gm:addSource(8, 8, 1)
    gm:setBlocker(function(x, y)
        return x == 9 and y >= 4 and y <= 12
    end)
    gm:bake()
    lurek.log.info("distance_12_8 = " .. gm:distanceAt(12, 8))
end

--@api: LGoalMap:bake
do

    local gm = lurek.pathfind.newGoalMap(16, 16)
    gm:addSource(8, 8, 1)
    gm:bake()
    local ready = gm:isReady()
    local distance_mid = gm:distanceAt(10, 8)
    local distance_corner = gm:distanceAt(1, 1)

    lurek.log.info("ready after bake = " .. tostring(ready))
    lurek.log.info("east lane distance = " .. distance_mid)
    lurek.log.info("corner distance = " .. distance_corner)
end

--@api: LGoalMap:isReady
do

    local gm = lurek.pathfind.newGoalMap(8, 8)
    gm:addSource(4, 4, 1)
    lurek.log.info("ready_before = " .. tostring(gm:isReady()))
    gm:bake()
    lurek.log.info("ready_after = " .. tostring(gm:isReady()))
end

--@api: LGoalMap:distanceAt
do

    local gm = lurek.pathfind.newGoalMap(10, 10)
    gm:addSource(5, 5, 1)
    gm:bake()
    lurek.log.info("distance_5_5 = " .. gm:distanceAt(5, 5))
    lurek.log.info("distance_1_1 = " .. gm:distanceAt(1, 1))
end

--@api: LGoalMap:gradientAt
do

    local gm = lurek.pathfind.newGoalMap(10, 10)
    gm:addSource(10, 10, 1)
    gm:bake()
    local dx, dy = gm:gradientAt(1, 1)
    lurek.log.info("gradient = " .. dx .. "," .. dy)
end

--@api: LGoalMap:flee
do

    local gm = lurek.pathfind.newGoalMap(10, 10)
    gm:addSource(5, 5, 1)
    gm:bake()
    local dx, dy = gm:flee(5, 6, 1.0)
    lurek.log.info("flee = " .. dx .. "," .. dy)
end

--@api: LGoalMap:floodFill
do

    local gm = lurek.pathfind.newGoalMap(12, 12)
    gm:addSource(6, 6, 1)
    gm:bake()
    local cells = gm:floodFill(6, 6, 4)
    lurek.log.info("flood_cells = " .. #cells)
end

--@api: LGoalMap:save
do

    local gm = lurek.pathfind.newGoalMap(12, 12)
    gm:addSource(6, 6, 1)
    gm:bake()
    local blob = gm:save()
    lurek.log.info("blob_bytes = " .. #blob)
end

--@api: LGoalMap:restore
do

    local gm = lurek.pathfind.newGoalMap(12, 12)
    gm:addSource(6, 6, 1)
    gm:bake()
    local blob = gm:save()

    local gm2 = lurek.pathfind.newGoalMap(12, 12)
    gm2:restore(blob)
    lurek.log.info("distance_restored = " .. gm2:distanceAt(6, 6))
end

--@api: LGoalMap:type
do

    local gm = lurek.pathfind.newGoalMap(8, 8)
    gm:addSource(4, 4, 1)
    gm:bake()
    local type_name = gm:type()
    local ready = gm:isReady()

    lurek.log.info("goal map type = " .. type_name)
    lurek.log.info("ready = " .. tostring(ready))
    lurek.log.info("center distance = " .. gm:distanceAt(4, 4))
end

--@api: LGoalMap:typeOf
do

    local gm = lurek.pathfind.newGoalMap(8, 8)
    gm:addSource(4, 4, 1)
    gm:bake()
    local is_goal_map = gm:typeOf("LGoalMap")
    local is_object = gm:typeOf("LObject")
    local is_nav_mesh = gm:typeOf("LNavMesh")

    lurek.log.info("matches LGoalMap = " .. tostring(is_goal_map))
    lurek.log.info("matches LObject = " .. tostring(is_object))
    lurek.log.info("matches LNavMesh = " .. tostring(is_nav_mesh))
end

--@api: lurek.pathfind.newSteeringManager
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:addSeek(320, 180, 1.0)
  lurek.log.info("lurek.pathfind.newSteeringManager: ok=" .. tostring(steer ~= nil))
  lurek.log.info("lurek.pathfind.newSteeringManager: behaviors=" .. tostring(steer:getBehaviorCount()))
end

--@api: lurek.pathfind.newInfluenceMap
do

  local imap = lurek.pathfind.newInfluenceMap(32, 32, 16)
  imap:addLayer("debug")
  local map_width = imap:getWidth()
  imap:addLayer("danger")
  imap:setInfluence("danger", 4, 5, 0.9)
  lurek.log.info("lurek.pathfind.newInfluenceMap: ok=" .. tostring(imap ~= nil))
  lurek.log.info("lurek.pathfind.newInfluenceMap: width=" .. tostring(imap:getWidth()))
end

--@api: lurek.pathfind.newContextSteering
do

  local cs = lurek.pathfind.newContextSteering(8)
  cs:addSeekTarget(0, 0, 1.0)
  local slot_count = cs:slotCount()
  cs:addSeekTarget(256, 128, 1.0)
  local dx, dy = cs:evaluate(0, 0, 1, 0)
  lurek.log.info("lurek.pathfind.newContextSteering: ok=" .. tostring(cs ~= nil))
  lurek.log.info("lurek.pathfind.newContextSteering: dir=" .. tostring(dx) .. "," .. tostring(dy))
end

--@api: lurek.pathfind.newORCASolver
do

  local orca = lurek.pathfind.newORCASolver(1.5)
  orca:addAgent(0, 0, 0.5, 3.0)
  local preview_count = orca:agentCount()
  lurek.log.info("lurek.pathfind.newORCASolver: ok=" .. tostring(orca ~= nil))
  lurek.log.info("lurek.pathfind.newORCASolver: agents=" .. tostring(orca:agentCount()))
end

--@api: LSteeringManager:addSeek
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:addSeek(400, 300, 1.0)
  local fx, fy = steer:calculate(50, 50, 0, 0, 100, 200, 1 / 60)
  lurek.log.info("LSteeringManager:addSeek: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end

--@api: LSteeringManager:addFlee
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:addFlee(200, 200, 1.0)
  local fx, fy = steer:calculate(210, 195, 0, 0, 100, 200, 1 / 60)
  lurek.log.info("LSteeringManager:addFlee: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end

--@api: LSteeringManager:addArrive
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:addArrive(300, 300, 50, 1.0)
  local fx, fy = steer:calculate(280, 290, 30, 10, 100, 200, 1 / 60)
  lurek.log.info("LSteeringManager:addArrive: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end

--@api: LSteeringManager:addWander
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:addWander(25, 50, 8, 0.5)
  local fx, fy = steer:calculate(100, 100, 10, 0, 80, 150, 1 / 60)
  lurek.log.info("LSteeringManager:addWander: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end

--@api: LSteeringManager:addPursue
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:setEntity("target_agent", 220, 120, 20, 0)
  steer:addPursue("target_agent", 1.0)
  local fx, fy = steer:calculate(100, 120, 0, 0, 120, 250, 1 / 60)
  lurek.log.info("LSteeringManager:addPursue: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end

--@api: LSteeringManager:addEvade
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:setEntity("enemy_agent", 140, 120, -10, 0)
  steer:addEvade("enemy_agent", 1.0)
  local fx, fy = steer:calculate(100, 120, 0, 0, 120, 250, 1 / 60)
  lurek.log.info("LSteeringManager:addEvade: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end

--@api: LSteeringManager:addFlock
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:setEntity("ally_1", 110, 100, 20, 0)
  steer:setEntity("ally_2", 95, 140, 10, 5)
  steer:addFlock(80, 1.5, 1.0, 1.0, 1.0)
  local fx, fy = steer:calculate(100, 120, 0, 0, 120, 250, 1 / 60)
  lurek.log.info("LSteeringManager:addFlock: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end

--@api: LSteeringManager:setEntity
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:setEntity("scout", 100, 80, 12, 0)
  lurek.log.info("LSteeringManager:setEntity: count=" .. tostring(steer:entityCount()))
end

--@api: LSteeringManager:removeEntity
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:setEntity("scout", 100, 80, 12, 0)
  local removed = steer:removeEntity("scout")
  lurek.log.info("LSteeringManager:removeEntity: removed=" .. tostring(removed))
end

--@api: LSteeringManager:clearEntities
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:setEntity("a", 0, 0)
  steer:setEntity("b", 16, 0)
  steer:clearEntities()
  lurek.log.info("LSteeringManager:clearEntities: count=" .. tostring(steer:entityCount()))
end

--@api: LSteeringManager:entityCount
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:setEntity("a", 0, 0)
  lurek.log.info("LSteeringManager:entityCount: " .. tostring(steer:entityCount()))
end

--@api: LSteeringManager:getBehaviorCount
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:addSeek(100, 100, 1.0)
  steer:addWander(10, 20, 3, 0.5)
  local count = steer:getBehaviorCount()
  lurek.log.info("LSteeringManager:getBehaviorCount: " .. tostring(count))
end

--@api: LSteeringManager:setCombineMode
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:setCombineMode("priority")
  local mode = steer:getCombineMode()
  lurek.log.info("LSteeringManager:setCombineMode: " .. mode)
end

--@api: LSteeringManager:getCombineMode
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:setCombineMode("truncated")
  local mode = steer:getCombineMode()
  lurek.log.info("LSteeringManager:getCombineMode: " .. mode)
  lurek.log.info("LSteeringManager:getCombineMode: type=" .. steer:type())
end

--@api: LSteeringManager:getLastSteering
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:addSeek(200, 200, 1.0)
  steer:calculate(50, 50, 0, 0, 100, 200, 1 / 60)
  local lx, ly = steer:getLastSteering()
  lurek.log.info("LSteeringManager:getLastSteering: " .. tostring(lx) .. "," .. tostring(ly))
end

--@api: LSteeringManager:calculate
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:addSeek(500, 300, 1.0)
  steer:addWander(15, 30, 4, 0.3)
  local fx, fy = steer:calculate(100, 100, 20, 5, 150, 250, 1 / 60)
  lurek.log.info("LSteeringManager:calculate: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end

--@api: LSteeringManager:setPath
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  local waypoints = {
    { x = 50, y = 50 },
    { x = 200, y = 80 },
    { x = 350, y = 200 },
    { x = 400, y = 400 },
  }
  steer:setPath(waypoints, 16.0, 1.0)
  local has = steer:hasPath()
  lurek.log.info("LSteeringManager:setPath: hasPath=" .. tostring(has))
end

--@api: LSteeringManager:clearPath
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:setPath({ { x = 10, y = 10 }, { x = 100, y = 100 } }, 8.0, 1.0)
  steer:clearPath()
  local has = steer:hasPath()
  lurek.log.info("LSteeringManager:clearPath: hasPath=" .. tostring(has))
end

--@api: LSteeringManager:hasPath
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  local before = steer:hasPath()
  steer:setPath({ { x = 0, y = 0 }, { x = 50, y = 50 } }, 5.0, 1.0)
  local after = steer:hasPath()
  lurek.log.info("LSteeringManager:hasPath: before=" .. tostring(before) .. " after=" .. tostring(after))
end

--@api: LSteeringManager:getPathProgress
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:setPath({ { x = 0, y = 0 }, { x = 100, y = 50 }, { x = 200, y = 100 } }, 10.0, 1.0)
  local idx, total = steer:getPathProgress()
  lurek.log.info("LSteeringManager:getPathProgress: " .. tostring(idx) .. "/" .. tostring(total))
end

--@api: LSteeringManager:type
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  local t = steer:type()
  lurek.log.info("LSteeringManager:type: " .. t)
  lurek.log.info("LSteeringManager:type: matches=" .. tostring(steer:typeOf("LSteeringManager")))
end

--@api: LSteeringManager:typeOf
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  local is_steer = steer:typeOf("LSteeringManager")
  local is_other = steer:typeOf("LBot")
  lurek.log.info("LSteeringManager:typeOf: LSteeringManager=" .. tostring(is_steer) .. " LBot=" .. tostring(is_other))
end

--@api: LSteeringManager:setSpatialHashCellSize
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:setSpatialHashCellSize(32)
  lurek.log.info("LSteeringManager:setSpatialHashCellSize: done")
end

--@api: LSteeringManager:enableSpatialHash
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:enableSpatialHash(true)
  steer:setSpatialHashCellSize(48)
  lurek.log.info("LSteeringManager:enableSpatialHash: done")
end

--@api: LSteeringManager:addCustomBehavior
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:addCustomBehavior(function(agent, dt) return 50, 0 end, 0.8)
  local count = steer:getBehaviorCount()
  lurek.log.info("LSteeringManager:addCustomBehavior: behaviors=" .. tostring(count))
end

--@api: LSteeringManager:applyCustomSteering
do

  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("pusher")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  npc:setPosition(100, 100)
  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:addCustomBehavior(function(agent, dt) return 25, -10 end, 1.0)
  local fx, fy = steer:applyCustomSteering(npc, 1 / 60)
  lurek.log.info("LSteeringManager:applyCustomSteering: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end

--@api: LInfluenceMap:addLayer
do

    local im = lurek.pathfind.newInfluenceMap(16, 16, 1.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
    im:addLayer("threat")
    im:addLayer("resources")
    lurek.log.info("layers added: threat, resources")
end

--@api: LInfluenceMap:hasLayer
do

    local im = lurek.pathfind.newInfluenceMap(8, 8, 2.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
    im:addLayer("heat")
    lurek.log.info("has heat = " .. tostring(im:hasLayer("heat")))
    lurek.log.info("has cold = " .. tostring(im:hasLayer("cold")))
end

--@api: LInfluenceMap:setInfluence
do

    local im = lurek.pathfind.newInfluenceMap(10, 10, 1.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
    im:addLayer("danger")
    im:setInfluence("danger", 5, 5, 1.0)
    im:setInfluence("danger", 3, 7, 0.5)
    lurek.log.info("set influence at (5,5) and (3,7)")
end

--@api: LInfluenceMap:getInfluence
do

    local im = lurek.pathfind.newInfluenceMap(10, 10, 1.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
    im:addLayer("food")
    im:setInfluence("food", 4, 4, 0.75)
    local val = im:getInfluence("food", 4, 4)
    lurek.log.info("food at (4,4) = " .. val)
end

--@api: LInfluenceMap:stampInfluence
do

    local im = lurek.pathfind.newInfluenceMap(20, 20, 1.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
    im:addLayer("noise")
    im:stampInfluence("noise", 10.0, 10.0, 3.0, 1.0, 0.5)
    local center = im:getInfluence("noise", 10, 10)
    lurek.log.info("noise center = " .. center)
end

--@api: LInfluenceMap:propagate
do

  local im = lurek.pathfind.newInfluenceMap(10, 10, 1.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
  im:addLayer("scent")
    im:setInfluence("scent", 5, 5, 1.0)
    im:propagate("scent", 0.8)
    local neighbor = im:getInfluence("scent", 4, 5)
    lurek.log.info("scent propagated to (4,5) = " .. neighbor)
end

--@api: LInfluenceMap:decay
do

  local im = lurek.pathfind.newInfluenceMap(8, 8, 1.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
  im:addLayer("heat")
    im:setInfluence("heat", 4, 4, 1.0)
    im:decay("heat", 0.5)
    local val = im:getInfluence("heat", 4, 4)
    lurek.log.info("heat after decay = " .. val)
end

--@api: LInfluenceMap:clearLayer
do

  local im = lurek.pathfind.newInfluenceMap(8, 8, 1.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
  im:addLayer("marks")
    im:setInfluence("marks", 2, 2, 1.0)
    im:clearLayer("marks")
    local val = im:getInfluence("marks", 2, 2)
    lurek.log.info("after clear = " .. val)
end

--@api: LInfluenceMap:clearAll
do

  local im = lurek.pathfind.newInfluenceMap(8, 8, 1.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
  im:addLayer("a")
  im:addLayer("b")
  im:setInfluence("a", 1, 1, 1.0)
    im:setInfluence("b", 2, 2, 0.5)
    im:clearAll()
    lurek.log.info("all cleared, a(1,1) = " .. im:getInfluence("a", 1, 1))
end

--@api: LInfluenceMap:getMaxPosition
do

  local im = lurek.pathfind.newInfluenceMap(10, 10, 1.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
  im:addLayer("gold")
    im:setInfluence("gold", 7, 3, 0.9)
    im:setInfluence("gold", 2, 8, 0.4)
    local mx, my = im:getMaxPosition("gold")
    lurek.log.info("max gold at (" .. mx .. ", " .. my .. ")")
end

--@api: LInfluenceMap:getMinPosition
do

  local im = lurek.pathfind.newInfluenceMap(10, 10, 1.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
  im:addLayer("cold")
    im:setInfluence("cold", 1, 1, -0.5)
    im:setInfluence("cold", 5, 5, 0.3)
    local mx, my = im:getMinPosition("cold")
    lurek.log.info("min cold at (" .. mx .. ", " .. my .. ")")
end

--@api: LInfluenceMap:queryRect
do

  local im = lurek.pathfind.newInfluenceMap(10, 10, 1.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
  im:addLayer("energy")
    im:setInfluence("energy", 2, 2, 0.5)
    im:setInfluence("energy", 3, 3, 0.5)
    local total = im:queryRect("energy", 1, 1, 4, 4)
    lurek.log.info("energy in rect = " .. total)
end

--@api: LInfluenceMap:blend
do

  local im = lurek.pathfind.newInfluenceMap(8, 8, 1.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
  im:addLayer("threat")
  im:addLayer("reward")
  im:addLayer("combined")
  im:setInfluence("threat", 4, 4, 1.0)
  im:setInfluence("reward", 4, 4, 0.8)
  im:blend("threat", 0.5, "reward", 0.5, "combined")
  local val = im:getInfluence("combined", 4, 4)
    lurek.log.info("blended (4,4) = " .. val)
end

--@api: LInfluenceMap:getWidth
do

    local im = lurek.pathfind.newInfluenceMap(16, 12, 2.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
    local map_height = im:getHeight()
    lurek.log.info("width = " .. im:getWidth())
end

--@api: LInfluenceMap:getHeight
do

    local im = lurek.pathfind.newInfluenceMap(16, 12, 2.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
    local cell_size = im:getCellSize()
    lurek.log.info("height = " .. im:getHeight())
end

--@api: LInfluenceMap:getCellSize
do

    local im = lurek.pathfind.newInfluenceMap(8, 8, 2.5)
  im:addLayer("debug")
  local map_width = im:getWidth()
    local map_height = im:getHeight()
    lurek.log.info("cell size = " .. im:getCellSize())
end

--@api: LInfluenceMap:type
do

    local im = lurek.pathfind.newInfluenceMap(4, 4, 1.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
    lurek.log.info("type = " .. im:type())
  lurek.log.info("matches = " .. tostring(im:typeOf("LInfluenceMap")))
end

--@api: LInfluenceMap:typeOf
do

    local im = lurek.pathfind.newInfluenceMap(4, 4, 1.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
    local type_name = im:type()
    lurek.log.info("is LInfluenceMap = " .. tostring(im:typeOf("LInfluenceMap")))
end

--@api: LContextSteering:addSeekTarget
do

    local cs = lurek.pathfind.newContextSteering(8)
  cs:addSeekTarget(0, 0, 1.0)
  local slot_count = cs:slotCount()
    cs:addSeekTarget(200, 150, 1.0)
    lurek.log.info("seek target added at (200, 150)")
end

--@api: LContextSteering:addWander
do

    local cs = lurek.pathfind.newContextSteering(8)
  cs:addSeekTarget(0, 0, 1.0)
  local slot_count = cs:slotCount()
    cs:addWander(0.3, 0.5)
    lurek.log.info("wander behavior added")
end

--@api: LContextSteering:addAvoidPoint
do

    local cs = lurek.pathfind.newContextSteering(8)
  cs:addSeekTarget(0, 0, 1.0)
  local slot_count = cs:slotCount()
    cs:addAvoidPoint(50, 50, 20.0, 1.5)
    lurek.log.info("avoid point at (50, 50) radius 20")
end

--@api: LContextSteering:addAvoidBounds
do

    local cs = lurek.pathfind.newContextSteering(8)
  cs:addSeekTarget(0, 0, 1.0)
  local slot_count = cs:slotCount()
    cs:addAvoidBounds(0, 0, 800, 600, 30.0, 1.0)
    lurek.log.info("avoid bounds set for 800x600 area")
end

--@api: LContextSteering:clearBehaviors
do

    local cs = lurek.pathfind.newContextSteering(8)
  cs:addSeekTarget(0, 0, 1.0)
  local slot_count = cs:slotCount()
    cs:addSeekTarget(100, 100, 1.0)
    cs:addAvoidPoint(50, 50, 10.0, 1.0)
    cs:clearBehaviors()
    lurek.log.info("behaviors cleared")
end

--@api: LContextSteering:evaluate
do

    local cs = lurek.pathfind.newContextSteering(8)
  cs:addSeekTarget(0, 0, 1.0)
  local slot_count = cs:slotCount()
    cs:addSeekTarget(300, 200, 1.0)
    cs:addAvoidPoint(150, 150, 30.0, 2.0)
    local dx, dy = cs:evaluate(100, 100, 1.0, 0.0)
    lurek.log.info("direction = " .. dx .. ", " .. dy)
end

--@api: LContextSteering:chosenMagnitude
do

    local cs = lurek.pathfind.newContextSteering(8)
  cs:addSeekTarget(0, 0, 1.0)
  local slot_count = cs:slotCount()
    cs:addSeekTarget(200, 200, 1.0)
    cs:evaluate(0, 0, 0, 0)
    local mag = cs:chosenMagnitude()
    lurek.log.info("magnitude = " .. mag)
end

--@api: LContextSteering:slotCount
do

    local cs = lurek.pathfind.newContextSteering(16)
  cs:addSeekTarget(0, 0, 1.0)
  local slot_count = cs:slotCount()
    local type_name = cs:type()
    lurek.log.info("slots = " .. cs:slotCount())
end

--@api: LContextSteering:type
do

    local cs = lurek.pathfind.newContextSteering(8)
  cs:addSeekTarget(0, 0, 1.0)
  local slot_count = cs:slotCount()
    lurek.log.info("type = " .. cs:type())
  lurek.log.info("matches = " .. tostring(cs:typeOf("LContextSteering")))
end

--@api: LContextSteering:typeOf
do

    local cs = lurek.pathfind.newContextSteering(8)
  cs:addSeekTarget(0, 0, 1.0)
  local slot_count = cs:slotCount()
    local type_name = cs:type()
    lurek.log.info("is LContextSteering = " .. tostring(cs:typeOf("LContextSteering")))
end

--@api: LORCASolver:addAgent
do

    local orca = lurek.pathfind.newORCASolver(2.0)
    local idx = orca:addAgent(10.0, 20.0, 0.5, 3.0)
    local count = orca:agentCount()
    local type_name = orca:type()
    lurek.log.info("agent index = " .. idx)
end

--@api: LORCASolver:setAgent
do

    local orca = lurek.pathfind.newORCASolver(2.0)
    orca:setAgent(101, {
        x = 10.0,
        y = 20.0,
        radius = 0.5,
        max_speed = 3.0,
        vx = 0.25,
        vy = 0.0,
        preferred_vx = 1.0,
        preferred_vy = 0.0,
    })
    orca:compute({ dt = 0.016 })
    local vx, vy = orca:getSafeVelocity(101)
    lurek.log.info("stable agent velocity = " .. vx .. ", " .. vy)
end

--@api: LORCASolver:setPreferredVelocity
do

    local orca = lurek.pathfind.newORCASolver(2.0)
    orca:addAgent(0, 0, 0.5, 5.0)
    orca:setPreferredVelocity(0, 2.0, 1.0)
    local count = orca:agentCount()
    local type_name = orca:type()
    lurek.log.info("preferred velocity set for agent 0")
end

--@api: LORCASolver:setVelocity
do

    local orca = lurek.pathfind.newORCASolver(2.0)
    orca:setAgent(77, { x = 0.0, y = 0.0, radius = 0.5, max_speed = 5.0 })
    orca:setVelocity(77, 1.5, -0.5)
    orca:compute(0.016)
    local vx, vy = orca:getSafeVelocity(77)
    lurek.log.info("current velocity updated = " .. vx .. ", " .. vy)
end

--@api: LORCASolver:setPosition
do

    local orca = lurek.pathfind.newORCASolver(2.0)
    orca:addAgent(0, 0, 0.5, 5.0)
    orca:setPosition(0, 5.0, 3.0)
    local count = orca:agentCount()
    local type_name = orca:type()
    lurek.log.info("position updated for agent 0")
end

--@api: LORCASolver:removeAgent
do

    local orca = lurek.pathfind.newORCASolver(2.0)
    orca:setAgent(200, { x = 0.0, y = 0.0, radius = 0.5, max_speed = 2.0 })
    local before = orca:agentCount()
    local removed = orca:removeAgent(200)
    local after = orca:agentCount()
    lurek.log.info("agent count before = " .. tostring(before))
    lurek.log.info("removed agent = " .. tostring(removed))
    lurek.log.info("agent count after = " .. tostring(after))
end

--@api: LORCASolver:setMaxNeighbors
do

    local orca = lurek.pathfind.newORCASolver(1.5)
    orca:setMaxNeighbors(1)
    orca:setCellSize(4.0)
    orca:setNeighborRadius(12.0)
    for i = 1, 4 do
        orca:setAgent(i, { x = i * 2.0, y = 0.0, radius = 0.5, max_speed = 3.0, preferred_vx = 1.0, preferred_vy = 0.0 })
    end
    orca:compute(0.016)
    local stats = orca:getStats()
    lurek.log.info("max neighbors used = " .. tostring(stats.maxNeighborsUsed))
end

--@api: LORCASolver:setNeighborRadius
do

    local orca = lurek.pathfind.newORCASolver(1.5)
    orca:setCellSize(4.0)
    orca:setNeighborRadius(3.0)
    orca:setAgent(1, { x = 0.0, y = 0.0, radius = 0.5, max_speed = 3.0 })
    orca:setAgent(2, { x = 20.0, y = 0.0, radius = 0.5, max_speed = 3.0 })
    orca:compute(0.016)
    local stats = orca:getStats()
    lurek.log.info("neighbors used = " .. tostring(stats.neighborsUsed))
end

--@api: LORCASolver:setCellSize
do

    local orca = lurek.pathfind.newORCASolver(1.5)
    orca:setCellSize(6.0)
    orca:setAgent(11, { x = 0.0, y = 0.0, radius = 0.5, max_speed = 3.0 })
    orca:setAgent(12, { x = 8.0, y = 0.0, radius = 0.5, max_speed = 3.0 })
    orca:compute(0.016)
    local stats = orca:getStats()
    lurek.log.info("spatial cells = " .. tostring(stats.spatialCells))
end

--@api: LORCASolver:compute
do

  local orca = lurek.pathfind.newORCASolver(1.5)
  orca:addAgent(0, 0, 0.5, 3.0)
  orca:addAgent(5, 0, 0.5, 3.0)
  orca:setPreferredVelocity(0, 1.0, 0.0)
    orca:setPreferredVelocity(1, -1.0, 0.0)
    orca:compute({ dt = 0.016, max_ms = 1.0 })
    lurek.log.info("collision avoidance computed")
end

--@api: LORCASolver:getSafeVelocity
do

  local orca = lurek.pathfind.newORCASolver(1.5)
  orca:addAgent(0, 0, 0.5, 3.0)
    orca:setPreferredVelocity(0, 2.0, 0.0)
    orca:compute(0.016)
    local vx, vy = orca:getSafeVelocity(0)
    lurek.log.info("safe velocity = " .. vx .. ", " .. vy)
end

--@api: LORCASolver:getStats
do

    local orca = lurek.pathfind.newORCASolver(1.5)
    for i = 1, 16 do
        orca:setAgent(i, {
            x = (i - 1) * 1.0,
            y = 0.0,
            radius = 0.5,
            max_speed = 3.0,
            preferred_vx = 1.0,
            preferred_vy = 0.0,
        })
    end
    orca:compute({ dt = 0.016, max_ms = 0.0 })
    local stats = orca:getStats()
    lurek.log.info("budget exhausted = " .. tostring(stats.budgetExhausted))
end

--@api: LORCASolver:agentCount
do

    local orca = lurek.pathfind.newORCASolver(2.0)
    orca:addAgent(0, 0, 1.0, 2.0)
    orca:addAgent(5, 5, 1.0, 2.0)
    local type_name = orca:type()
    local is_solver = orca:typeOf("LORCASolver")
    lurek.log.info("agent count = " .. orca:agentCount())
end

--@api: LORCASolver:type
do

    local orca = lurek.pathfind.newORCASolver(1.0)
    orca:addAgent(0, 0, 0.5, 2.0)
    local count = orca:agentCount()
    lurek.log.info("type = " .. orca:type())
  lurek.log.info("matches = " .. tostring(orca:typeOf("LORCASolver")))
end

--@api: LORCASolver:typeOf
do

    local orca = lurek.pathfind.newORCASolver(1.0)
    orca:addAgent(0, 0, 0.5, 2.0)
    local count = orca:agentCount()
    local type_name = orca:type()
    lurek.log.info("is LORCASolver = " .. tostring(orca:typeOf("LORCASolver")))
end

--@api: LSteeringManager:getLastDiagnostic
do

  local steer = lurek.pathfind.newSteeringManager()
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("steer_probe")
  steer:addCustomBehavior(function() error("custom steering failure") end, 1.0)
  steer:applyCustomSteering(agent, 1 / 60)
  lurek.log.info("LSteeringManager:getLastDiagnostic: " .. tostring(steer:getLastDiagnostic()))
end

--- Added coverage examples for newer API owners.

--@api: lurek.pathfind.newNavGridFromProvider
do
    local provider = { width = 3, height = 2, blocked = { false, true, false, false, false, false }, costs = { 1, 4, 1, 1, 1, 1 } }
    local ok, value = pcall(function()
        local nav = lurek.pathfind.newNavGridFromProvider(provider)
        return nav:getCost(2, 1)
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: lurek.pathfind.newPathGridFromProvider
do
    local provider = { width = 3, height = 2, cellSize = 16, walkable = { true, false, true, true, true, true } }
    local ok, value = pcall(function()
        local grid = lurek.pathfind.newPathGridFromProvider(provider)
        return grid:getCellSize()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
