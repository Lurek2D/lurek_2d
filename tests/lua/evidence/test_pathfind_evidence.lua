-- Evidence tests: pathfind module
-- Output-only evidence from direct lurek.pathfind API calls.
-- @covers lurek.pathfind.newFlowField
-- @covers lurek.pathfind.newNavGrid
-- @covers lurek.pathfind.newPathfinder


local function write_text(path, text)
    local f = io and io.open and io.open(path, "w") or nil
    if f then
        f:write(text)
        f:close()
    end
end

describe("evidence: pathfind", function()
    before_each(function()
        ensure_evidence_dir("pathfind")
    end)

    -- @evidence file
    it("exports astar path through obstacle gap", function()
        local dir = evidence_output_dir("pathfind")
        local path = dir .. "astar_gap.json"

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

    -- @evidence file
    it("exports weighted-terrain path", function()
        local dir = evidence_output_dir("pathfind")
        local path = dir .. "astar_weighted.json"

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

    -- @evidence file
    it("exports flow-field direction samples", function()
        local dir = evidence_output_dir("pathfind")
        local path = dir .. "flow_field.json"

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
