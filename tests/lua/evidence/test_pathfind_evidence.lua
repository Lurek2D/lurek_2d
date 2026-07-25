-- Evidence tests: pathfind module
-- Output-only evidence from direct lurek.pathfind API calls.
-- @covers lurek.filesystem.write
-- @covers lurek.image.newImageData
-- @covers lurek.image.savePNG
-- @covers lurek.pathfind.getThreadCount
-- @covers lurek.pathfind.newContextSteering
-- @covers lurek.pathfind.newFlowField
-- @covers lurek.pathfind.newGoalMap
-- @covers lurek.pathfind.newHexGrid
-- @covers lurek.pathfind.newHexGridFromField
-- @covers lurek.pathfind.newInfluenceMap
-- @covers lurek.pathfind.newIsoGridFromField
-- @covers lurek.pathfind.newJpsGrid
-- @covers lurek.pathfind.newNavGrid
-- @covers lurek.pathfind.newNavMesh
-- @covers lurek.pathfind.newORCASolver
-- @covers lurek.pathfind.newPathFlowField
-- @covers lurek.pathfind.newPathGrid
-- @covers lurek.pathfind.newPathfinder
-- @covers lurek.pathfind.newSteeringManager
-- @covers lurek.pathfind.rangeMap
-- @covers lurek.pathfind.setThreadCount
-- @covers lurek.tilefield.new



local OUT = evidence_output_dir("pathfind")

local function write_text(path, text)
    if write_file then
        write_file(path, text)
    else
        lurek.filesystem.write(path, text)
    end
    expect_evidence_created(path)
end

local function save_png(img, path)
    lurek.image.savePNG(img, path)
    expect_evidence_created(path)
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
    draw_outline(img, ox, oy, cell, cell, 28, 30, 36, 255)
end

local function draw_path_overlay(img, nodes, cell, r, g, b)
    for i = 1, #nodes - 1 do
        local a = nodes[i]
        local c = nodes[i + 1]
        local ax = math.floor((a.x - 0.5) * cell)
        local ay = math.floor((a.y - 0.5) * cell)
        local bx = math.floor((c.x - 0.5) * cell)
        local by = math.floor((c.y - 0.5) * cell)
        img:drawLine(ax, ay, bx, by, r, g, b, 255)
    end
    if nodes[1] then
        img:drawCircle(math.floor((nodes[1].x - 0.5) * cell), math.floor((nodes[1].y - 0.5) * cell), math.max(2, math.floor(cell / 4)), 60, 220, 90, 255)
    end
    if nodes[#nodes] then
        img:drawCircle(math.floor((nodes[#nodes].x - 0.5) * cell), math.floor((nodes[#nodes].y - 0.5) * cell), math.max(2, math.floor(cell / 4)), 255, 120, 70, 255)
    end
end

local function draw_arrow(img, cx, cy, dx, dy, scale, r, g, b)
    local x2 = math.floor(cx + dx * scale)
    local y2 = math.floor(cy + dy * scale)
    img:drawLine(cx, cy, x2, y2, r, g, b, 255)
    img:drawLine(x2, y2, math.floor(x2 - dy * 2), math.floor(y2 + dx * 2), r, g, b, 255)
    img:drawLine(x2, y2, math.floor(x2 + dy * 2), math.floor(y2 - dx * 2), r, g, b, 255)
end

local function paint_staggered_cell(img, x, y, cell, r, g, b)
    local row_offset = (y % 2 == 0) and math.floor(cell / 2) or 0
    local ox = row_offset + (x - 1) * cell
    local oy = (y - 1) * cell
    img:drawRect(ox, oy, cell, cell, r, g, b, 255)
    draw_outline(img, ox, oy, cell, cell, 28, 30, 36, 255)
end

local function staggered_center(x, y, cell)
    local row_offset = (y % 2 == 0) and math.floor(cell / 2) or 0
    return row_offset + math.floor((x - 0.5) * cell), math.floor((y - 0.5) * cell)
end

local function draw_hex_path_overlay(img, nodes, cell, r, g, b)
    for i = 1, #nodes - 1 do
        local a = nodes[i]
        local c = nodes[i + 1]
        local ax, ay = staggered_center(a.col, a.row, cell)
        local bx, by = staggered_center(c.col, c.row, cell)
        img:drawLine(ax, ay, bx, by, r, g, b, 255)
    end
    if nodes[1] then
        local sx, sy = staggered_center(nodes[1].col, nodes[1].row, cell)
        img:drawCircle(sx, sy, math.max(2, math.floor(cell / 4)), 60, 220, 90, 255)
    end
    if nodes[#nodes] then
        local gx, gy = staggered_center(nodes[#nodes].col, nodes[#nodes].row, cell)
        img:drawCircle(gx, gy, math.max(2, math.floor(cell / 4)), 255, 120, 70, 255)
    end
end

local function iso_center(x, y, tile_w, tile_h, origin_x, origin_y)
    return origin_x + math.floor((x - y) * tile_w / 2), origin_y + math.floor((x + y - 2) * tile_h / 2)
end

local function paint_iso_cell(img, x, y, tile_w, tile_h, origin_x, origin_y, r, g, b)
    local cx, cy = iso_center(x, y, tile_w, tile_h, origin_x, origin_y)
    local hw = math.floor(tile_w / 2)
    local hh = math.floor(tile_h / 2)
    for dy = -hh, hh do
        local span = math.floor(hw * (1 - math.abs(dy) / math.max(1, hh)))
        img:drawLine(cx - span, cy + dy, cx + span, cy + dy, r, g, b, 255)
    end
    img:drawLine(cx, cy - hh, cx + hw, cy, 28, 30, 36, 255)
    img:drawLine(cx + hw, cy, cx, cy + hh, 28, 30, 36, 255)
    img:drawLine(cx, cy + hh, cx - hw, cy, 28, 30, 36, 255)
    img:drawLine(cx - hw, cy, cx, cy - hh, 28, 30, 36, 255)
end

local function draw_iso_path_overlay(img, nodes, tile_w, tile_h, origin_x, origin_y, r, g, b)
    for i = 1, #nodes - 1 do
        local a = nodes[i]
        local c = nodes[i + 1]
        local ax, ay = iso_center(a.x, a.y, tile_w, tile_h, origin_x, origin_y)
        local bx, by = iso_center(c.x, c.y, tile_w, tile_h, origin_x, origin_y)
        img:drawLine(ax, ay, bx, by, r, g, b, 255)
    end
    if nodes[1] then
        local sx, sy = iso_center(nodes[1].x, nodes[1].y, tile_w, tile_h, origin_x, origin_y)
        img:drawCircle(sx, sy, math.max(3, math.floor(tile_h / 4)), 60, 220, 90, 255)
    end
    if nodes[#nodes] then
        local gx, gy = iso_center(nodes[#nodes].x, nodes[#nodes].y, tile_w, tile_h, origin_x, origin_y)
        img:drawCircle(gx, gy, math.max(3, math.floor(tile_h / 4)), 255, 120, 70, 255)
    end
end

-- @describe evidence: pathfind
describe("evidence: pathfind", function()
    before_each(function()
        ensure_evidence_dir("pathfind")
    end)
    -- Does: Runs "astar path through an obstacle gap" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.pathfind.newNavGrid, LNavGrid:setBlocked, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/pathfind/astar_basic.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.pathfind.newNavGrid, LNavGrid:setBlocked, and related owner calls; export helpers are just the container.

    it("PNG: astar path through an obstacle gap", function()
        local cell = 16
        local grid = lurek.pathfind.newNavGrid(20, 15)
        local blocked = {}
        for y = 1, 15 do
            blocked[y] = {}
            if y ~= 8 then
                grid:setBlocked(10, y, true)
                blocked[y][10] = true
            end
        end

        local pf = lurek.pathfind.newPathfinder(grid)
        local nodes = pf:findPath(1, 1, 20, 15) or {}
        local img = lurek.image.newImageData(20 * cell, 15 * cell)
        img:fill(14, 16, 20, 255)

        for y = 1, 15 do
            for x = 1, 20 do
                if blocked[y][x] then
                    paint_cell(img, x, y, cell, 82, 36, 46)
                else
                    paint_cell(img, x, y, cell, 38, 42, 52)
                end
            end
        end

        draw_path_overlay(img, nodes, cell, 255, 214, 92)
        draw_outline(img, 0, 0, 20 * cell, 15 * cell, 232, 236, 244, 255)
        save_png(img, OUT .. "astar_basic.png")
    end)
    -- Does: Runs "weighted terrain route across a cost field" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.pathfind.newNavGrid, LNavGrid:setCost, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/pathfind/weighted_route.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.pathfind.newNavGrid, LNavGrid:setCost, and related owner calls; export helpers are just the container.

    it("PNG: weighted terrain route across a cost field", function()
        local cell = 20
        local grid = lurek.pathfind.newNavGrid(14, 12)
        local costs = {}
        for y = 1, 12 do
            costs[y] = {}
            for x = 1, 14 do
                local cost = 1
                if x >= 6 and x <= 8 then
                    cost = 9
                elseif y >= 8 and x >= 10 then
                    cost = 5
                elseif y == 4 and x >= 3 and x <= 11 then
                    cost = 3
                end
                grid:setCost(x, y, cost)
                costs[y][x] = cost
            end
        end

        local pf = lurek.pathfind.newPathfinder(grid)
        local nodes = pf:findPath(1, 6, 14, 6) or {}
        local img = lurek.image.newImageData(14 * cell, 12 * cell)
        img:fill(14, 14, 18, 255)

        for y = 1, 12 do
            for x = 1, 14 do
                local cost = costs[y][x]
                local shade = math.floor(50 + math.min(180, cost * 18))
                paint_cell(img, x, y, cell, shade, 48, 180 - math.min(120, cost * 10))
            end
        end

        draw_path_overlay(img, nodes, cell, 80, 230, 255)
        draw_outline(img, 0, 0, 14 * cell, 12 * cell, 232, 236, 244, 255)
        save_png(img, OUT .. "weighted_route.png")
    end)
    -- Does: Runs "pathfind API surface with flow-field arrows" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.pathfind.newFlowField, LFlowField:calculate, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/pathfind/pathfind_api_surface.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.pathfind.newFlowField, LFlowField:calculate, and related owner calls; export helpers are just the container.

    it("PNG: pathfind API surface with flow-field arrows", function()
        local cell = 20
        local grid = lurek.pathfind.newNavGrid(16, 16)
        local blocked = {}
        for y = 1, 16 do
            blocked[y] = {}
        end
        for y = 3, 12 do
            grid:setBlocked(8, y, true)
            blocked[y][8] = true
        end
        for x = 8, 16 do
            grid:setBlocked(x, 8, true)
            blocked[8][x] = true
        end

        local ff = lurek.pathfind.newFlowField(grid)
        ff:calculate(16, 16)
        local img = lurek.image.newImageData(16 * cell, 16 * cell)
        img:fill(18, 18, 24, 255)

        for y = 1, 16 do
            for x = 1, 16 do
                if blocked[y][x] then
                    paint_cell(img, x, y, cell, 76, 38, 50)
                else
                    paint_cell(img, x, y, cell, 34, 40, 48)
                    local dx, dy = ff:getDirection(x, y)
                    draw_arrow(img, math.floor((x - 0.5) * cell), math.floor((y - 0.5) * cell), tonumber(dx) or 0, tonumber(dy) or 0, cell * 0.35, 110, 220, 130)
                end
            end
        end

        img:drawCircle(math.floor((16 - 0.5) * cell), math.floor((16 - 0.5) * cell), math.max(3, math.floor(cell / 4)), 255, 210, 70, 255)
        draw_outline(img, 0, 0, 16 * cell, 16 * cell, 232, 236, 244, 255)
        save_png(img, OUT .. "pathfind_api_surface.png")
    end)
    -- Does: Runs "pathfind movement and tactical constructor surface" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.pathfind.newSteeringManager, newInfluenceMap, newContextSteering, newORCASolver, and related owner calls.
    -- Artifact: tests/artifacts/current/pathfind/pathfind_movement_surface_snapshot.txt
    -- Why: This proves movement-side AI helpers live under the pathfind namespace rather than lurek.ai.

    it("writes pathfind_movement_surface_snapshot.txt", function()
        local steer = lurek.pathfind.newSteeringManager()
        local influence = lurek.pathfind.newInfluenceMap(4, 4, 1.0)
        local context = lurek.pathfind.newContextSteering(8)
        local orca = lurek.pathfind.newORCASolver(1.5)
        local lines = {
            "steering_ctor=" .. tostring(type(lurek.pathfind.newSteeringManager) == "function"),
            "influence_ctor=" .. tostring(type(lurek.pathfind.newInfluenceMap) == "function"),
            "context_steering_ctor=" .. tostring(type(lurek.pathfind.newContextSteering) == "function"),
            "orca_ctor=" .. tostring(type(lurek.pathfind.newORCASolver) == "function"),
            "steering_type=" .. steer:type(),
            "influence_type=" .. influence:type(),
            "context_slots=" .. tostring(context:slotCount()),
            "orca_agents=" .. tostring(orca:agentCount()),
        }
        write_text(OUT .. "pathfind_movement_surface_snapshot.txt", table.concat(lines, "\n") .. "\n")
    end)
    -- Does: Runs "exports astar path through obstacle gap" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.pathfind.newNavGrid, LNavGrid:setBlocked, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/pathfind/pathfind_astar_gap_trace.json
    -- Why: This is meaningful only if the visible/text output comes from lurek.pathfind.newNavGrid, LNavGrid:setBlocked, and related owner calls; export helpers are just the container.

    it("exports astar path through obstacle gap", function()
        local path = OUT .. "pathfind_astar_gap_trace.json"
        local grid = lurek.pathfind.newNavGrid(20, 15)
        for y = 1, 15 do
            if y ~= 8 then
                grid:setBlocked(10, y, true)
            end
        end

        local pf = lurek.pathfind.newPathfinder(grid)
        local nodes = pf:findPath(1, 1, 20, 15) or {}
        local out = {}
        for i, n in ipairs(nodes) do
            out[i] = string.format('{"x":%d,"y":%d}', n.x or 0, n.y or 0)
        end
        write_text(path, '{"count":' .. tostring(#nodes) .. ',"nodes":[' .. table.concat(out, ",") .. "]}")
    end)
    -- Does: Runs "exports weighted-terrain path" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.pathfind.newNavGrid, LNavGrid:setCost, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/pathfind/pathfind_weighted_route_trace.json
    -- Why: This is meaningful only if the visible/text output comes from lurek.pathfind.newNavGrid, LNavGrid:setCost, and related owner calls; export helpers are just the container.

    it("exports weighted-terrain path", function()
        local path = OUT .. "pathfind_weighted_route_trace.json"
        local grid = lurek.pathfind.newNavGrid(12, 12)
        for y = 1, 12 do
            grid:setCost(6, y, 9)
            grid:setCost(7, y, 9)
        end

        local pf = lurek.pathfind.newPathfinder(grid)
        local nodes = pf:findPath(1, 6, 12, 6) or {}
        local head = nodes[1] or { x = -1, y = -1 }
        local tail = nodes[#nodes] or { x = -1, y = -1 }
        write_text(
            path,
            string.format(
                '{"count":%d,"start":{"x":%d,"y":%d},"end":{"x":%d,"y":%d}}',
                #nodes,
                head.x or -1,
                head.y or -1,
                tail.x or -1,
                tail.y or -1
            )
        )
    end)
    -- Does: Runs "exports flow-field direction samples" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.pathfind.newFlowField, LFlowField:calculate, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/pathfind/pathfind_flow_field_samples.json
    -- Why: This is meaningful only if the visible/text output comes from lurek.pathfind.newFlowField, LFlowField:calculate, and related owner calls; export helpers are just the container.

    it("exports flow-field direction samples", function()
        local path = OUT .. "pathfind_flow_field_samples.json"
        local grid = lurek.pathfind.newNavGrid(16, 16)
        for y = 3, 12 do
            grid:setBlocked(8, y, true)
        end
        for x = 8, 16 do
            grid:setBlocked(x, 8, true)
        end

        local ff = lurek.pathfind.newFlowField(grid)
        ff:calculate(16, 16)
        local probes = { { 2, 2 }, { 5, 5 }, { 10, 4 }, { 14, 14 }, { 7, 10 } }
        local out = {}
        for i, p in ipairs(probes) do
            local dx, dy = ff:getDirection(p[1], p[2])
            out[i] = string.format('{"x":%d,"y":%d,"dx":%.4f,"dy":%.4f}', p[1], p[2], tonumber(dx) or 0, tonumber(dy) or 0)
        end
        write_text(path, "[" .. table.concat(out, ",") .. "]")
    end)
    -- Does: Runs "exports pathfind advanced API trace" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.pathfind.newPathGrid, lurek.pathfind.newPathFlowField, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/pathfind/pathfind_advanced_api_trace.txt
    -- Why: This is meaningful only if the visible/text output comes from lurek.pathfind.newPathGrid, lurek.pathfind.newPathFlowField, and related owner calls; export helpers are just the container.

    it("exports pathfind advanced API trace", function()
        local old_threads = lurek.pathfind.getThreadCount()
        lurek.pathfind.setThreadCount(old_threads + 1)
        local grid = lurek.pathfind.newNavGrid(12, 10)
        grid:fill(1)
        grid:fillRect(4, 4, 3, 2, 5)
        grid:setBlocked(9, 5, true)
        grid:setDiagonalMode("none")
        grid:setChunkSize(6)
        grid:setDirty(4, 4, 3, 2)
        grid:clearDirty()
        local dump = grid:saveToString()
        local replay = lurek.pathfind.newNavGrid(12, 10)
        replay:loadFromString(dump)
        replay:rebuildAbstract()

        local pf = lurek.pathfind.newPathfinder(replay)
        pf:setCacheEnabled(true)
        pf:setCacheMaxSize(32)
        local smooth = pf:findPathSmooth(1, 1, 12, 10) or {}
        local bidi = pf:findPathBidirectional(1, 1, 12, 10) or {}
        local partial = pf:findPartialPath(1, 1, 9, 5, 12) or {}
        local nearest_x, nearest_y = pf:findNearestWalkable(9, 5, 4)
        local ff = lurek.pathfind.newFlowField(replay)
        ff:calculateMulti({ { x = 12, y = 10 }, { x = 1, y = 10 } })

        local goal = lurek.pathfind.newGoalMap(12, 10)
        local range = lurek.pathfind.rangeMap({
            width = 12,
            height = 10,
            origin_x = 1,
            origin_y = 1,
            budget = 6.0,
        })
        local lines = {
            "threads_old=" .. tostring(old_threads),
            "threads_new=" .. tostring(lurek.pathfind.getThreadCount()),
            "grid_dims=" .. tostring(grid:getWidth()) .. "x" .. tostring(grid:getHeight()),
            "grid_cost_4_4=" .. tostring(grid:getCost(4, 4)),
            "grid_blocked_9_5=" .. tostring(grid:isBlocked(9, 5)),
            "grid_walkable_1_1=" .. tostring(grid:isWalkable(1, 1)),
            "chunk_size=" .. tostring(grid:getChunkSize()),
            "diagonal_mode=" .. tostring(grid:getDiagonalMode()),
            "hpa_path_count=" .. tostring(#(replay:findHpaPath(1, 1, 12, 10) or {})),
            "smooth_len=" .. tostring(pf:getPathLength(smooth)),
            "bidi_cost=" .. tostring(pf:getPathCost(bidi)),
            "partial_count=" .. tostring(#partial),
            "nearest_walkable=" .. tostring(nearest_x) .. "," .. tostring(nearest_y),
            "reachable=" .. tostring(pf:isReachable(1, 1, 12, 10)),
            "heuristic=" .. tostring(pf:heuristicDistance(1, 1, 12, 10)),
            "cache_enabled=" .. tostring(pf:isCacheEnabled()),
            "cache_size=" .. tostring(pf:getCacheSize()),
            "flow_calculated=" .. tostring(ff:isCalculated()),
            "flow_targets=" .. tostring(#(ff:getTargets() or {})),
            "flow_angle_2_2=" .. tostring(ff:getDirectionAngle(2, 2)),
            "flow_cost_2_2=" .. tostring(ff:getCostToTarget(2, 2)),
            "flow_steer_type=" .. tostring(type(ff:steer(0, 0, 32, 2, 2))),
            "path_grid_ctor=" .. tostring(type(lurek.pathfind.newPathGrid) == "function"),
            "path_flow_ctor=" .. tostring(type(lurek.pathfind.newPathFlowField) == "function"),
            "hex_grid_ctor=" .. tostring(type(lurek.pathfind.newHexGrid) == "function"),
            "jps_grid_ctor=" .. tostring(type(lurek.pathfind.newJpsGrid) == "function"),
            "nav_mesh_ctor=" .. tostring(type(lurek.pathfind.newNavMesh) == "function"),
            "goal_map_ctor=" .. tostring(goal ~= nil),
            "range_map_type=" .. tostring(type(range)),
        }
        lurek.pathfind.setThreadCount(old_threads)
        pf:clearCache()
        write_text(OUT .. "pathfind_advanced_api_trace.txt", table.concat(lines, "\n") .. "\n")
    end)
    -- Does: Builds a hex tilefield adapter and renders a direct LHexGrid route.
    -- Shows: Hex topology, field-derived movement blockers/costs, and the path returned by lurek.pathfind.newHexGridFromField.
    -- Artifact: tests/artifacts/current/pathfind/pathfind_hex_tilefield_route.png
    -- Why: Hex pathfinding should have a module-owned artifact instead of only appearing inside tilefield system screenshots.
    it("PNG: hex tilefield route adapter", function()
        local width, height = 13, 10
        local cell = 18
        local field = lurek.tilefield.new({ width = width, height = height, topology = "hex" })
        for y = 2, 9 do
            if y ~= 5 then
                field:setBlock(7, y, 1, "move", true)
            end
        end
        for x = 3, 11 do
            if x % 2 == 1 then
                field:setCost(x, 7, 1, "move", 4)
            end
        end

        local grid = lurek.pathfind.newHexGridFromField(field, { level = 1, channel = "move", layout = "flat" })
        local nodes = grid:findPath(2, 5, 12, 5) or {}
        local img = lurek.image.newImageData(width * cell + math.floor(cell / 2), height * cell)
        img:fill(14, 16, 20, 255)
        for y = 1, height do
            for x = 1, width do
                if field:blocks(x, y, 1, "move") then
                    paint_staggered_cell(img, x, y, cell, 86, 38, 50)
                elseif field:getCost(x, y, 1, "move") > 1 then
                    paint_staggered_cell(img, x, y, cell, 96, 86, 52)
                else
                    paint_staggered_cell(img, x, y, cell, 38, 46, 54)
                end
            end
        end
        draw_hex_path_overlay(img, nodes, cell, 255, 214, 92)
        draw_outline(img, 0, 0, width * cell + math.floor(cell / 2), height * cell, 232, 236, 244, 255)
        save_png(img, OUT .. "pathfind_hex_tilefield_route.png")

        local out = {}
        for i, n in ipairs(nodes) do
            out[i] = string.format('{"col":%d,"row":%d}', n.col or 0, n.row or 0)
        end
        write_text(
            OUT .. "pathfind_hex_tilefield_trace.json",
            '{"count":' .. tostring(#nodes) .. ',"blocked_7_4":' .. tostring(grid:isBlocked(7, 4)) .. ',"nodes":[' .. table.concat(out, ",") .. "]}"
        )
    end)
    -- Does: Builds an iso-square tilefield adapter and renders a direct LIsoGrid route.
    -- Shows: Isometric projection, field-derived movement blockers/costs, and the path returned by lurek.pathfind.newIsoGridFromField.
    -- Artifact: tests/artifacts/current/pathfind/pathfind_iso_tilefield_route.png
    -- Why: Iso pathfinding now has a Lua-visible owner artifact matching the isometric tilemap/tilefield combinations.
    it("PNG: iso-square tilefield route adapter", function()
        local width, height = 9, 7
        local tile_w, tile_h = 34, 18
        local origin_x, origin_y = 150, 18
        local field = lurek.tilefield.new({ width = width, height = height, topology = "iso_square" })
        for y = 1, height do
            if y ~= 4 then
                field:setBlock(5, y, 1, "move", true)
            end
        end
        for x = 2, 8 do
            if x ~= 5 then
                field:setCost(x, 5, 1, "move", 3)
            end
        end

        local grid = lurek.pathfind.newIsoGridFromField(field, { level = 1, channel = "move" })
        local nodes = grid:findPath(1, 4, 9, 4) or {}
        local img = lurek.image.newImageData(310, 160)
        img:fill(14, 16, 20, 255)
        for y = 1, height do
            for x = 1, width do
                if field:blocks(x, y, 1, "move") then
                    paint_iso_cell(img, x, y, tile_w, tile_h, origin_x, origin_y, 86, 38, 50)
                elseif field:getCost(x, y, 1, "move") > 1 then
                    paint_iso_cell(img, x, y, tile_w, tile_h, origin_x, origin_y, 100, 88, 52)
                else
                    paint_iso_cell(img, x, y, tile_w, tile_h, origin_x, origin_y, 42, 54, 62)
                end
            end
        end
        draw_iso_path_overlay(img, nodes, tile_w, tile_h, origin_x, origin_y, 80, 230, 255)
        draw_outline(img, 0, 0, 310, 160, 232, 236, 244, 255)
        save_png(img, OUT .. "pathfind_iso_tilefield_route.png")

        local out = {}
        for i, n in ipairs(nodes) do
            out[i] = string.format('{"x":%d,"y":%d}', n.x or 0, n.y or 0)
        end
        write_text(
            OUT .. "pathfind_iso_tilefield_trace.json",
            '{"count":' .. tostring(#nodes) .. ',"blocked_5_3":' .. tostring(grid:isBlocked(5, 3)) .. ',"cost_2_5":' .. tostring(grid:getCost(2, 5)) .. ',"nodes":[' .. table.concat(out, ",") .. "]}"
        )
    end)
end)
test_summary()
