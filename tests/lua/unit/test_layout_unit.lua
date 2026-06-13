-- Canonical unit coverage for lurek.layout.

local function make_nodes()
    return {
        { id = 1, width = 60, height = 30, label = "Root" },
        { id = 2, width = 50, height = 24, label = "Left" },
        { id = 3, width = 50, height = 24, label = "Right" },
    }
end

local function nodes_by_id(result)
    local mapped = {}
    for _, node in ipairs(result.nodes) do
        mapped[node.id] = node
    end
    return mapped
end

-- @describe lurek.layout module
describe("lurek.layout module", function()
    -- @covers lurek.layout.tree
    it("tree places the root above its children and preserves labels", function()
        local result = lurek.layout.tree(make_nodes(), { [1] = { 2, 3 } }, 1, {
            hSpacing = 70,
            vSpacing = 90,
            margin = 20,
        })
        local pos = nodes_by_id(result)
        expect_equal(3, #result.nodes)
        expect_equal("Root", pos[1].label)
        expect_near(20, pos[1].y, 0.001)
        expect_true(pos[1].y < pos[2].y)
        expect_near((pos[2].x + pos[3].x) / 2, pos[1].x, 0.001)
    end)

    -- @covers lurek.layout.dag
    it("dag assigns deeper layers lower on the y axis", function()
        local result = lurek.layout.dag(make_nodes(), {
            { from = 1, to = 2, weight = 1.0 },
            { from = 2, to = 3, weight = 1.0 },
        }, {
            hSpacing = 80,
            vSpacing = 100,
            margin = 24,
        })
        local pos = nodes_by_id(result)
        expect_equal(3, #result.nodes)
        expect_near(24, pos[1].y, 0.001)
        expect_true(pos[1].y < pos[2].y)
        expect_true(pos[2].y < pos[3].y)
        expect_true(result.height > 0)
    end)

    -- @covers lurek.layout.force
    it("force keeps nodes inside the configured simulation area", function()
        local result = lurek.layout.force(make_nodes(), {
            { from = 1, to = 2, weight = 1.0 },
            { from = 2, to = 3, weight = 1.0 },
        }, {
            iterations = 20,
            repulsion = 6000,
            attraction = 0.02,
            cooling = 0.9,
            areaWidth = 400,
            areaHeight = 300,
        })
        local pos = nodes_by_id(result)
        expect_equal(3, #result.nodes)
        expect_in_range(pos[1].x, 0, 400)
        expect_in_range(pos[1].y, 0, 300)
        expect_in_range(pos[2].x, 0, 400)
        expect_in_range(pos[2].y, 0, 300)
        expect_in_range(pos[3].x, 0, 400)
        expect_in_range(pos[3].y, 0, 300)
        expect_true(pos[1].x ~= pos[3].x or pos[1].y ~= pos[3].y)
    end)

    -- @covers lurek.layout.snapToGrid
    it("snapToGrid returns grid-aligned node coordinates", function()
        local snapped = lurek.layout.snapToGrid({
            nodes = {
                { id = 1, width = 40, height = 20, label = "Only" },
            },
        }, 16)
        expect_equal(1, #snapped.nodes)
        expect_near(0, snapped.nodes[1].x % 16, 0.001)
        expect_near(0, snapped.nodes[1].y % 16, 0.001)
        expect_equal("Only", snapped.nodes[1].label)
    end)

    -- @covers lurek.layout.centerInArea
    it("centerInArea centers a node inside the requested bounds", function()
        local centered = lurek.layout.centerInArea({
            nodes = {
                { id = 1, width = 50, height = 30, label = "Only" },
            },
        }, 400, 300)
        expect_equal(1, #centered.nodes)
        expect_near(175, centered.nodes[1].x, 0.001)
        expect_near(135, centered.nodes[1].y, 0.001)
        expect_equal(400, centered.width)
        expect_equal(300, centered.height)
    end)
end)

test_summary()
