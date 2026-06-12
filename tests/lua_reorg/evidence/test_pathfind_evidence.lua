-- Evidence tests: pathfind module
-- Output-only evidence from direct lurek.pathfind API calls.

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

-- @describe evidence: pathfind
describe("evidence: pathfind", function()
    before_each(function()
        ensure_evidence_dir("pathfind")
    end)

    -- @evidence lurek.pathfind.newNavGrid
    -- @evidence LNavGrid:setBlocked
    -- @evidence lurek.pathfind.newPathfinder
    -- @evidence LUnitPathfinder:findPath
    -- @evidence lurek.image.savePNG
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

    -- @evidence lurek.pathfind.newNavGrid
    -- @evidence LNavGrid:setCost
    -- @evidence lurek.pathfind.newPathfinder
    -- @evidence LUnitPathfinder:findPath
    -- @evidence lurek.image.savePNG
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

    -- @evidence lurek.pathfind.newFlowField
    -- @evidence LFlowField:calculate
    -- @evidence LFlowField:getDirection
    -- @evidence lurek.image.savePNG
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

    -- @evidence lurek.pathfind.newNavGrid
    -- @evidence LNavGrid:setBlocked
    -- @evidence lurek.pathfind.newPathfinder
    -- @evidence LUnitPathfinder:findPath
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

    -- @evidence lurek.pathfind.newNavGrid
    -- @evidence LNavGrid:setCost
    -- @evidence lurek.pathfind.newPathfinder
    -- @evidence LUnitPathfinder:findPath
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

    -- @evidence lurek.pathfind.newFlowField
    -- @evidence LFlowField:calculate
    -- @evidence LFlowField:getDirection
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

    -- @evidence LUnitPathfinder:findPath
    -- @evidence LFlowField:getDirection
    -- @evidence lurek.image.savePNG
    it("PNG: pathfind contact sheet", function()
        local files = {
            "astar_basic.png",
            "weighted_route.png",
            "pathfind_api_surface.png",
        }
        local canvas = lurek.image.newImageData(732, 256)
        canvas:fill(12, 14, 20, 255)
        for i, name in ipairs(files) do
            local src = lurek.image.newImageData(OUT .. name)
            local thumb = src:resize(220, 220, "bilinear")
            local x = 16 + (i - 1) * 236
            canvas:paste(thumb, x, 18)
            draw_outline(canvas, x, 18, 220, 220, 232, 236, 244, 255)
        end
        save_png(canvas, OUT .. "pathfind_contact_sheet.png")
    end)

    -- @evidence lurek.pathfind.newPathGrid
    -- @evidence lurek.pathfind.newPathFlowField
    -- @evidence lurek.pathfind.setThreadCount
    -- @evidence lurek.pathfind.getThreadCount
    -- @evidence lurek.pathfind.newHexGrid
    -- @evidence lurek.pathfind.newJpsGrid
    -- @evidence lurek.pathfind.newNavMesh
    -- @evidence lurek.pathfind.rangeMap
    -- @evidence lurek.pathfind.newGoalMap
    -- @evidence LNavGrid:getWidth
    -- @evidence LNavGrid:getHeight
    -- @evidence LNavGrid:getDimensions
    -- @evidence LNavGrid:getCost
    -- @evidence LNavGrid:isBlocked
    -- @evidence LNavGrid:isWalkable
    -- @evidence LNavGrid:fill
    -- @evidence LNavGrid:fillRect
    -- @evidence LNavGrid:loadFromString
    -- @evidence LNavGrid:saveToString
    -- @evidence LNavGrid:setChunkSize
    -- @evidence LNavGrid:getChunkSize
    -- @evidence LNavGrid:rebuildAbstract
    -- @evidence LNavGrid:findHpaPath
    -- @evidence LNavGrid:setDirty
    -- @evidence LNavGrid:clearDirty
    -- @evidence LNavGrid:setDiagonalMode
    -- @evidence LNavGrid:getDiagonalMode
    -- @evidence LUnitPathfinder:findPathSmooth
    -- @evidence LUnitPathfinder:findPathBidirectional
    -- @evidence LUnitPathfinder:getPathLength
    -- @evidence LUnitPathfinder:getPathCost
    -- @evidence LUnitPathfinder:findPartialPath
    -- @evidence LUnitPathfinder:findNearestWalkable
    -- @evidence LUnitPathfinder:isReachable
    -- @evidence LUnitPathfinder:heuristicDistance
    -- @evidence LUnitPathfinder:lineOfSight
    -- @evidence LUnitPathfinder:setCacheEnabled
    -- @evidence LUnitPathfinder:isCacheEnabled
    -- @evidence LUnitPathfinder:clearCache
    -- @evidence LUnitPathfinder:getCacheSize
    -- @evidence LUnitPathfinder:setCacheMaxSize
    -- @evidence LFlowField:calculateMulti
    -- @evidence LFlowField:getDirectionAngle
    -- @evidence LFlowField:getCostToTarget
    -- @evidence LFlowField:isCalculated
    -- @evidence LFlowField:getTargets
    -- @evidence LFlowField:steer
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
            "line_of_sight=" .. tostring(pf:lineOfSight(1, 1, 3, 3)),
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
end)
test_summary()
