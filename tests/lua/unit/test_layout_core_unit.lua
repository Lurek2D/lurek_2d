-- Unit tests for lurek.layout positioning and flow module.

-- @describe lurek.layout module unit tests
describe("lurek.layout", function()
    local function make_nodes(count)
        local nodes = {}
        for i = 1, count do
            nodes[i] = { id = i, width = 40, height = 20 }
        end
        return nodes
    end

    -- @covers lurek.layout.tree
    it("tree layout positions root above children", function()
        local nodes = make_nodes(3)
        local children = { [1] = { 2, 3 } }
        local result = lurek.layout.tree(nodes, children, 1)
        expect_true(result ~= nil, "result should exist")
        expect_equal(3, #result.nodes)
        -- Root should be above children (smaller y)
        local root_y, child_y
        for _, n in ipairs(result.nodes) do
            if n.id == 1 then root_y = n.y end
            if n.id == 2 then child_y = n.y end
        end
        expect_true(root_y < child_y, "root y should be less than child y")
    end)

    -- @covers lurek.layout.tree
    it("tree layout centers parent over children", function()
        local nodes = make_nodes(3)
        local children = { [1] = { 2, 3 } }
        local result = lurek.layout.tree(nodes, children, 1)
        local positions = {}
        for _, n in ipairs(result.nodes) do positions[n.id] = n end
        local center = (positions[2].x + positions[3].x) / 2
        expect_near(center, positions[1].x, 1.0)
    end)

    -- @covers lurek.layout.dag
    it("dag layout assigns layers", function()
        local nodes = make_nodes(4)
        local edges = {
            { from = 1, to = 2 },
            { from = 1, to = 3 },
            { from = 2, to = 4 },
            { from = 3, to = 4 },
        }
        local result = lurek.layout.dag(nodes, edges)
        expect_equal(4, #result.nodes)
        -- Node 1 (source) should be at top, node 4 (sink) at bottom
        local pos = {}
        for _, n in ipairs(result.nodes) do pos[n.id] = n end
        expect_true(pos[1].y < pos[4].y, "source should be above sink")
    end)

    -- @covers lurek.layout.dag
    it("dag layout handles empty graph", function()
        local result = lurek.layout.dag({}, {})
        expect_equal(0, #result.nodes)
    end)

    -- @covers lurek.layout.force
    it("force layout separates nodes", function()
        local nodes = make_nodes(3)
        local edges = { { from = 1, to = 2 }, { from = 2, to = 3 } }
        local result = lurek.layout.force(nodes, edges, { iterations = 20, areaWidth = 400, areaHeight = 300 })
        expect_equal(3, #result.nodes)
        -- Nodes should not overlap (different positions)
        local p1, p2
        for _, n in ipairs(result.nodes) do
            if n.id == 1 then p1 = n end
            if n.id == 3 then p2 = n end
        end
        local dist = math.sqrt((p1.x - p2.x)^2 + (p1.y - p2.y)^2)
        expect_true(dist > 10, "nodes should be separated")
    end)

    -- @covers lurek.layout.snapToGrid
    it("snapToGrid aligns to grid", function()
        local nodes = make_nodes(2)
        local edges = { { from = 1, to = 2 } }
        local result = lurek.layout.dag(nodes, edges)
        local snapped = lurek.layout.snapToGrid(result, 50)
        for _, n in ipairs(snapped.nodes) do
            local x_mod = n.x % 50
            local y_mod = n.y % 50
            expect_near(0, x_mod, 0.01)
            expect_near(0, y_mod, 0.01)
        end
    end)

    -- @covers lurek.layout.centerInArea
    it("centerInArea sets result bounds", function()
        local nodes = make_nodes(2)
        local edges = { { from = 1, to = 2 } }
        local result = lurek.layout.dag(nodes, edges)
        local centered = lurek.layout.centerInArea(result, 1000, 800)
        expect_equal(1000, centered.width)
        expect_equal(800, centered.height)
    end)

    -- @covers lurek.layout.tree
    it("single-node tree returns that node", function()
        local nodes = { { id = 1, width = 40, height = 20 } }
        local children = {}
        local result = lurek.layout.tree(nodes, children, 1)
        expect_equal(1, #result.nodes)
        expect_equal(1, result.nodes[1].id)
    end)

    -- @covers lurek.layout.force
    it("force with no edges still positions nodes", function()
        local nodes = make_nodes(5)
        local result = lurek.layout.force(nodes, {}, { iterations = 10, areaWidth = 200, areaHeight = 200 })
        expect_equal(5, #result.nodes)
    end)
end)

test_summary()
