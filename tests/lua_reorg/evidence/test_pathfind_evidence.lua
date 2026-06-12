-- Evidence tests: pathfind module
-- Output-only evidence from direct lurek.pathfind API calls.

local OUT = evidence_output_dir("pathfind")

local function write_text(path, text)
    if write_file then
        write_file(path, text)
        return
    end
    lurek.filesystem.write(path, text)
end

local function paint_cell(img, x, y, cell, r, g, b)
    local ox = (x - 1) * cell
    local oy = (y - 1) * cell
    for py = oy, oy + cell - 1 do
        for px = ox, ox + cell - 1 do
            img:setPixel(px, py, r, g, b, 255)
        end
    end
    img:drawRect(ox, oy, cell, cell, 28, 30, 36, 255)
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
        local path = OUT .. "astar_basic.png"
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- @evidence lurek.pathfind.newNavGrid
    -- @evidence LNavGrid:setCost
    -- @evidence lurek.pathfind.newPathfinder
    -- @evidence LUnitPathfinder:findPath
    -- @evidence lurek.image.savePNG
    it("PNG: weighted terrain route across a cost field", function()
        local cell = 18
        local grid = lurek.pathfind.newNavGrid(12, 12)
        local costs = {}
        for y = 1, 12 do
            costs[y] = {}
            for x = 1, 12 do
                local cost = 1
                if x == 6 or x == 7 then
                    cost = 9
                elseif y >= 9 and x >= 9 then
                    cost = 5
                end
                grid:setCost(x, y, cost)
                costs[y][x] = cost
            end
        end

        local pf = lurek.pathfind.newPathfinder(grid)
        local nodes = pf:findPath(1, 6, 12, 6) or {}
        local img = lurek.image.newImageData(12 * cell, 12 * cell)
        img:fill(14, 14, 18, 255)

        for y = 1, 12 do
            for x = 1, 12 do
                local cost = costs[y][x]
                local shade = math.floor(50 + math.min(180, cost * 18))
                paint_cell(img, x, y, cell, shade, 48, 180 - math.min(120, cost * 10))
            end
        end

        draw_path_overlay(img, nodes, cell, 80, 230, 255)
        local path = OUT .. "weighted_route.png"
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
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
                    draw_arrow(
                        img,
                        math.floor((x - 0.5) * cell),
                        math.floor((y - 0.5) * cell),
                        tonumber(dx) or 0,
                        tonumber(dy) or 0,
                        cell * 0.35,
                        110,
                        220,
                        130
                    )
                end
            end
        end

        img:drawCircle(math.floor((16 - 0.5) * cell), math.floor((16 - 0.5) * cell), math.max(3, math.floor(cell / 4)), 255, 210, 70, 255)
        local path = OUT .. "pathfind_api_surface.png"
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- @evidence lurek.pathfind.newNavGrid
    -- @evidence LNavGrid:setBlocked
    -- @evidence lurek.pathfind.newPathfinder
    -- @evidence LUnitPathfinder:findPath
    it("exports astar path through obstacle gap", function()
        local path = OUT .. "pathfind_astar_gap_trace.json"

        local grid = lurek.pathfind.newNavGrid(20, 15)
        for y = 1, 15 do
            if y ~= 8 then grid:setBlocked(10, y, true) end
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
        local head = nodes[1] or {x = -1, y = -1}
        local tail = nodes[#nodes] or {x = -1, y = -1}

        local json = string.format(
            '{"count":%d,"start":{"x":%d,"y":%d},"end":{"x":%d,"y":%d}}',
            #nodes,
            head.x or -1,
            head.y or -1,
            tail.x or -1,
            tail.y or -1
        )
        write_text(path, json)
    end)

    -- @evidence lurek.pathfind.newFlowField
    -- @evidence LFlowField:calculate
    -- @evidence LFlowField:getDirection
    it("exports flow-field direction samples", function()
        local path = OUT .. "pathfind_flow_field_samples.json"

        local grid = lurek.pathfind.newNavGrid(16, 16)
        for y = 3, 12 do grid:setBlocked(8, y, true) end
        for x = 8, 16 do grid:setBlocked(x, 8, true) end

        local ff = lurek.pathfind.newFlowField(grid)
        ff:calculate(16, 16)

        local probes = {{2,2},{5,5},{10,4},{14,14},{7,10}}
        local out = {}
        for i, p in ipairs(probes) do
            local dx, dy = ff:getDirection(p[1], p[2])
            out[i] = string.format('{"x":%d,"y":%d,"dx":%.4f,"dy":%.4f}', p[1], p[2], tonumber(dx) or 0, tonumber(dy) or 0)
        end
        write_text(path, "[" .. table.concat(out, ",") .. "]")
    end)
end)
test_summary()
