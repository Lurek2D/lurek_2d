-- Lurek2D Stress Test: Graph Flow Simulation
-- Tests large graph creation, edge traversal, and simulation ticks


-- @description Covers suite: graph stress: large graph creation.
describe("graph stress: large graph creation", function()
    -- @covers lurek.graph.newGraph
    -- @covers Graph:addNode
    -- @covers Graph:addEdge
    -- @covers Graph:getStats
    -- @stress Creates 500 nodes and 499 connecting edges in a single chain topology.
    -- @description Stresses graph construction throughput by allocating a long linear pipeline and then querying aggregate node and edge counts.
    it("creates a 500-node chain graph", function()
        local g = lurek.graph.newGraph()

        local nodes = {}
        for i = 1, 500 do
            nodes[i] = g:addNode("processor", 100)
        end

        -- Connect in chain
        for i = 1, 499 do
            g:addEdge(nodes[i], nodes[i + 1])
        end

        local stats = g:getStats()
        expect_equal(500, stats.nodes, "500 nodes created")
        expect_equal(499, stats.edges, "499 edges created")
    end)

    -- @covers lurek.graph.newGraph
    -- @covers Graph:addNode
    -- @covers Graph:addEdge
    -- @covers Graph:getStats
    -- @stress Builds a 20x20 mesh graph with horizontal and vertical edge connections.
    -- @description Stresses dense graph construction by filling a 400-node grid and wiring every internal adjacency before validating the resulting edge count.
    it("creates a mesh-connected graph", function()
        local g = lurek.graph.newGraph()

        -- 20x20 grid = 400 nodes
        local size = 20
        local nodes = {}
        for i = 1, size * size do
            nodes[i] = g:addNode("processor", 50)
        end

        -- Connect horizontally and vertically
        local edges = 0
        for row = 0, size - 1 do
            for col = 0, size - 1 do
                local id = row * size + col + 1
                if col < size - 1 then
                    g:addEdge(nodes[id], nodes[id + 1])
                    edges = edges + 1
                end
                if row < size - 1 then
                    g:addEdge(nodes[id], nodes[id + size])
                    edges = edges + 1
                end
            end
        end

        local stats = g:getStats()
        expect_equal(400, stats.nodes, "400 nodes in grid")
        expect_equal(edges, stats.edges, "correct edge count")
    end)
end)

-- @description Covers suite: graph stress: simulation ticks.
describe("graph stress: simulation ticks", function()
    -- @covers lurek.graph.newGraph
    -- @covers Graph:createItem
    -- @covers Graph:addItem
    -- @covers Graph:update
    -- @stress Seeds 50 items into a 200-node pipeline and advances the simulation for 100 ticks.
    -- @description Stresses steady-state graph simulation by combining nontrivial topology, queued items, and a long fixed-step update loop.
    it("runs 100 ticks on a 200-node pipeline", function()
        local g = lurek.graph.newGraph()

        local nodes = {}
        for i = 1, 200 do
            nodes[i] = g:addNode("processor", 100)
        end

        -- Linear pipeline
        for i = 1, 199 do
            g:addEdge(nodes[i], nodes[i + 1])
        end

        -- Add items at the source
        for i = 1, 50 do
            local item = g:createItem("resource")
            g:addItem(item, nodes[1])
        end

        -- Run 100 simulation ticks
        for tick = 1, 100 do
            g:update(1.0)
        end

        expect_true(true, "100 ticks completed without error")
    end)
end)
