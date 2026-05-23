-- Evidence tests: graph module
-- Output-only evidence from direct lurek.graph API calls.
-- @covers lurek.graph.newGraph


local function write_text(path, text)
    local f = io and io.open and io.open(path, "w") or nil
    if f then
        f:write(text)
        f:close()
    end
end

describe("evidence: graph", function()
    before_each(function()
        ensure_evidence_dir("graph")
    end)

    -- @evidence file
    it("exports ring topology shortest-path evidence", function()
        local dir = evidence_output_dir("graph")
        local path = dir .. "ring_path.json"

        local g = lurek.graph.newGraph()
        local nodes = {}
        for i = 1, 8 do nodes[i] = g:addNode() end
        for i = 1, 8 do g:addEdge(nodes[i], nodes[(i % 8) + 1]) end

        local p = g:findPath(nodes[1], nodes[5]) or {}
        local out = {}
        for i, n in ipairs(p) do
            out[i] = '"' .. tostring(n) .. '"'
        end
        write_text(path, '{"node_count":8,"edge_count":8,"path_len":' .. tostring(#p) .. ',"path":[' .. table.concat(out, ",") .. "]}")
    end)

    -- @evidence file
    it("exports hub-and-spoke path evidence", function()
        local dir = evidence_output_dir("graph")
        local path = dir .. "hub_spoke.json"

        local g = lurek.graph.newGraph()
        local nodes = {}
        for i = 1, 7 do nodes[i] = g:addNode() end
        for i = 2, 7 do g:addEdge(nodes[1], nodes[i]) end
        g:addEdge(nodes[2], nodes[3])
        g:addEdge(nodes[3], nodes[4])

        local p = g:findPath(nodes[2], nodes[6]) or {}
        write_text(path, '{"node_count":7,"path_len":' .. tostring(#p) .. '}')
    end)

    -- @evidence file
    it("exports graph adjacency metrics", function()
        local dir = evidence_output_dir("graph")
        local path = dir .. "adjacency_metrics.json"

        local g = lurek.graph.newGraph()
        local a = g:addNode()
        local b = g:addNode()
        local c = g:addNode()
        local d = g:addNode()
        g:addEdge(a, b)
        g:addEdge(b, c)
        g:addEdge(c, d)
        g:addEdge(a, d)

        local p1 = g:findPath(a, c) or {}
        local p2 = g:findPath(b, d) or {}
        local json = string.format('{"nodes":4,"edges":4,"ac":%d,"bd":%d}', #p1, #p2)
        write_text(path, json)
    end)
end)

test_summary()
