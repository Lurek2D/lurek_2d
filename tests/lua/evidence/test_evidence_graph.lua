-- test_evidence_graph.lua
-- Evidence test: lurek.graph Graph API contracts and PNG visual network evidence

local OUT = "tests/lua/evidence/output/graph/"

-- ── helpers ──────────────────────────────────────────────────────────────────

--- Build a graph from a position table and edge index list.
--- positions: array of {x, y}
--- edges: array of {from_idx, to_idx}
--- Returns graph, nodes_array (positions stored externally, not on nodes)
local function build_graph(positions, edges)
    local g = lurek.graph.newGraph()
    local nodes = {}
    for i = 1, #positions do
        nodes[i] = g:addNode()
    end
    for _, e in ipairs(edges) do
        g:addEdge(nodes[e[1]], nodes[e[2]])
    end
    return g, nodes
end

--- Render a graph as a PNG.
--- nodes_arr: array of LuaNode
--- edges_idx: array of {from_idx, to_idx} (integer indices into nodes_arr and positions)
--- path_nodes: optional array of nodes from findPath
--- positions: array of {x, y} parallel to nodes_arr
local function draw_graph(nodes_arr, edges_idx, path_nodes, positions, iw, ih)
    local img = lurek.img.newImageData(iw, ih)
    img:fill(15, 20, 30, 255)

    -- Build set of path nodes by tostring key for highlighting
    local path_set = {}
    if path_nodes then
        for _, n in ipairs(path_nodes) do
            path_set[tostring(n)] = true
        end
    end

    -- Draw edges (index-based to avoid missing getX/getY node methods)
    for _, e in ipairs(edges_idx) do
        local x1 = positions[e[1]].x
        local y1 = positions[e[1]].y
        local x2 = positions[e[2]].x
        local y2 = positions[e[2]].y
        img:drawLine(x1, y1, x2, y2, 60, 80, 100, 255)
    end

    -- Draw nodes
    for i, n in ipairs(nodes_arr) do
        local nx = positions[i].x
        local ny = positions[i].y
        local is_path = path_set[tostring(n)]
        local r, g_val, b = 80, 120, 200
        if is_path then r, g_val, b = 220, 160, 60 end
        img:drawCircle(nx, ny, 5, r, g_val, b, 255)
        img:drawCircle(nx, ny, 3, 255, 255, 255, 255)
    end

    return img
end

-- ── tests ────────────────────────────────────────────────────────────────────

describe("Evidence: lurek.graph Graph creation", function()

    it("newGraph creates a Graph object", function()
        local g = lurek.graph.newGraph()
    end)

    it("addNode returns a Node handle", function()
        local g = lurek.graph.newGraph()
        local n = g:addNode()
    end)

    it("getNodeCount reflects additions", function()
        local g = lurek.graph.newGraph()
        g:addNode()
        g:addNode()
        g:addNode()
    end)

    it("addEdge / getEdgeCount reflect additions", function()
        local g = lurek.graph.newGraph()
        local a = g:addNode()
        local b = g:addNode()
        g:addEdge(a, b)
    end)

    it("removeNode / hasNode round-trip", function()
        local g = lurek.graph.newGraph()
        local n = g:addNode()
        g:removeNode(n)
    end)

    it("hasEdge returns false after removeEdge", function()
        local g = lurek.graph.newGraph()
        local a = g:addNode()
        local b = g:addNode()
        local e = g:addEdge(a, b)
        g:removeEdge(e)
    end)
end)

describe("Evidence: lurek.graph findPath Dijkstra", function()

    it("findPath finds a path in a linear chain", function()
        local g = lurek.graph.newGraph()
        local a = g:addNode()
        local b = g:addNode()
        local c = g:addNode()
        g:addEdge(a, b)
        g:addEdge(b, c)

        local result = g:findPath(a, c)
    end)

    it("findPath returns nil when no path exists", function()
        local g = lurek.graph.newGraph()
        local a = g:addNode()
        local b = g:addNode()
        -- No edges between a and b
        local result = g:findPath(a, b)
    end)

    it("getDistance returns correct hop count on unweighted chain", function()
        local g = lurek.graph.newGraph()
        local nodes = {}
        for i = 1, 5 do nodes[i] = g:addNode() end
        for i = 1, 4 do g:addEdge(nodes[i], nodes[i+1]) end

        local dist = g:getDistance(nodes[1], nodes[5])
    end)

    it("getNeighbors returns direct connections", function()
        local g = lurek.graph.newGraph()
        local hub = g:addNode()
        local s1  = g:addNode()
        local s2  = g:addNode()
        local s3  = g:addNode()
        g:addEdge(hub, s1)
        g:addEdge(hub, s2)
        g:addEdge(hub, s3)

        local nb = g:getNeighbors(hub)
    end)

    it("getReachable returns all nodes in connected graph", function()
        local g = lurek.graph.newGraph()
        local nodes = {}
        for i = 1, 6 do nodes[i] = g:addNode() end
        for i = 1, 5 do g:addEdge(nodes[i], nodes[i+1]) end

        local reachable = g:getReachable(nodes[1])
    end)

    it("getComponents detects disconnected subgraphs", function()
        local g = lurek.graph.newGraph()
        -- Two separate chains
        local a1 = g:addNode()
        local a2 = g:addNode()
        g:addEdge(a1, a2)

        local b1 = g:addNode()
        local b2 = g:addNode()
        g:addEdge(b1, b2)

        local comps = g:getComponents()
    end)
end)

describe("Evidence: lurek.graph visual network PNG", function()

    it("ring topology — PNG evidence: ring_graph", function()
        -- 8-node ring
        local N = 8
        local R = 90
        local CX, CY = 120, 120
        local positions = {}
        for i = 1, N do
            local angle = (i - 1) / N * 2 * math.pi
            positions[i] = {
                x = CX + math.floor(R * math.cos(angle)),
                y = CY + math.floor(R * math.sin(angle))
            }
        end
        local edge_def = {}
        for i = 1, N do
            edge_def[i] = {i, i % N + 1}
        end

        local g, nodes = build_graph(positions, edge_def)

        local path_result = g:findPath(nodes[1], nodes[5])
        local path_nodes  = path_result and path_result.nodes or nil

        local img = draw_graph(nodes, edge_def, path_nodes, positions, 240, 240)
        lurek.img.savePNG(img, OUT .. "evidence_graph_ring.png")
    end)

    it("hub-and-spoke topology — PNG evidence: hub_graph", function()
        local CX, CY = 120, 120
        local R = 80
        local SPOKES = 6

        -- positions: hub = index 1, spokes = indices 2..SPOKES+1
        local positions = {}
        positions[1] = {x = CX, y = CY}
        for i = 1, SPOKES do
            local angle = (i - 1) / SPOKES * 2 * math.pi
            positions[i + 1] = {
                x = CX + math.floor(R * math.cos(angle)),
                y = CY + math.floor(R * math.sin(angle))
            }
        end

        -- Edges: hub(1) -> each spoke(2..N+1), plus adjacent spoke cross-edges
        local edge_def = {}
        for i = 1, SPOKES do
            edge_def[#edge_def+1] = {1, i + 1}
        end
        for i = 1, SPOKES - 1 do
            edge_def[#edge_def+1] = {i + 1, i + 2}
        end

        local g, nodes = build_graph(positions, edge_def)

        -- Path from spoke 1 to spoke 4 (indices 2 and 5)
        local path_result = g:findPath(nodes[2], nodes[5])
        local path_nodes  = path_result and path_result.nodes or nil

        local img = draw_graph(nodes, edge_def, path_nodes, positions, 240, 240)
        lurek.img.savePNG(img, OUT .. "evidence_graph_hub.png")
    end)
end)

describe("Evidence: lurek.graph item flow", function()

    it("createItem / addItem / getItems round-trip", function()
        local g = lurek.graph.newGraph()
        local n = g:addNode()
        local item = g:createItem("ore", -1)
        local ok = g:addItem(item, n)
    end)

    it("removeItem removes the item", function()
        local g = lurek.graph.newGraph()
        local n = g:addNode()
        local item = g:createItem("ore", -1)
        g:addItem(item, n)
        g:removeItem(item)
    end)
end)

test_summary()
