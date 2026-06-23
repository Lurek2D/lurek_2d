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

local function overlaps(a, b, padding)
    padding = padding or 0
    return a.x < b.x + b.width + padding
        and a.x + a.width + padding > b.x
        and a.y < b.y + b.height + padding
        and a.y + a.height + padding > b.y
end

local function expect_no_overlap(nodes, padding)
    for i = 1, #nodes do
        for j = i + 1, #nodes do
            expect_true(not overlaps(nodes[i], nodes[j], padding or 0), "layout nodes should not overlap")
        end
    end
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
        local child_center = ((pos[2].x + pos[2].width * 0.5) + (pos[3].x + pos[3].width * 0.5)) * 0.5
        expect_near(child_center, pos[1].x + pos[1].width * 0.5, 0.001)
        expect_no_overlap(result.nodes, 0)
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
        expect_no_overlap(result.nodes, 0)
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
        expect_no_overlap(result.nodes, 0)
    end)

    -- @covers lurek.layout.circular
    it("circular places every node on a non-overlapping overview ring", function()
        local result = lurek.layout.circular(make_nodes(), {
            hSpacing = 60,
            vSpacing = 80,
            margin = 10,
        })
        local pos = nodes_by_id(result)
        expect_equal(3, #result.nodes)
        expect_true(pos[1].x ~= pos[2].x or pos[1].y ~= pos[2].y)
        expect_no_overlap(result.nodes, 0)
        expect_true(result.width > 0)
        expect_true(result.height > 0)
    end)

    -- @covers lurek.layout.radial
    it("radial places the root inside the inner ring and children farther out", function()
        local result = lurek.layout.radial(make_nodes(), {
            { from = 1, to = 2 },
            { from = 1, to = 3 },
        }, 1, {
            hSpacing = 60,
            vSpacing = 90,
            margin = 12,
        })
        local pos = nodes_by_id(result)
        local child_dx = math.abs(pos[2].x - pos[1].x) + math.abs(pos[2].y - pos[1].y)
        expect_equal(3, #result.nodes)
        expect_true(child_dx > 10)
        expect_no_overlap(result.nodes, 0)
        expect_true(result.width > 0)
    end)

    -- @covers lurek.layout.grid
    it("grid packs nodes into deterministic rows and columns", function()
        local result = lurek.layout.grid(make_nodes(), {
            hSpacing = 20,
            vSpacing = 30,
            margin = 8,
        })
        local pos = nodes_by_id(result)
        expect_equal(3, #result.nodes)
        expect_near(8, pos[1].x, 0.001)
        expect_true(pos[2].x > pos[1].x or pos[2].y > pos[1].y)
        expect_no_overlap(result.nodes, 0)
    end)

    -- @covers lurek.layout.spiral
    it("spiral gives unordered graphs distinct deterministic positions", function()
        local result = lurek.layout.spiral(make_nodes(), {
            hSpacing = 40,
            vSpacing = 40,
            margin = 10,
        })
        local pos = nodes_by_id(result)
        expect_equal(3, #result.nodes)
        expect_true(pos[1].x ~= pos[3].x or pos[1].y ~= pos[3].y)
        expect_no_overlap(result.nodes, 0)
        expect_true(result.width > 0)
    end)

    -- @covers lurek.layout.stress
    it("stress preserves graph-distance layout while staying deterministic", function()
        local result = lurek.layout.stress(make_nodes(), {
            { from = 1, to = 2 },
            { from = 2, to = 3 },
        }, {
            iterations = 8,
            edgeLength = 50,
            step = 0.05,
        })
        local pos = nodes_by_id(result)
        expect_equal(3, #result.nodes)
        expect_true(pos[1].x ~= pos[2].x or pos[1].y ~= pos[2].y)
        expect_no_overlap(result.nodes, 0)
        expect_true(result.width > 0)
    end)

    -- @covers lurek.layout.snapToGrid
    it("snapToGrid aligns nodes even when they start off-grid", function()
        local snapped = lurek.layout.snapToGrid({
            nodes = {
                { id = 1, width = 40, height = 20, label = "Only" },
            },
        }, 16)
        expect_equal(1, #snapped.nodes)
        expect_near(0, snapped.nodes[1].x % 16, 0.001)
        expect_near(0, snapped.nodes[1].y % 16, 0.001)
        expect_equal("Only", snapped.nodes[1].label)
        local snapped = lurek.layout.snapToGrid({
            nodes = {
                { id = 1, x = 18, y = 34, width = 40, height = 20, label = "Only" },
            },
        }, 16)
        expect_equal(16, snapped.nodes[1].x)
        expect_equal(32, snapped.nodes[1].y)
    end)

    -- @covers lurek.layout.centerInArea
    it("centerInArea centers a node inside the requested bounds regardless of prior coordinates", function()
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
        local centered = lurek.layout.centerInArea({
            nodes = {
                { id = 1, x = 20, y = 30, width = 50, height = 30, label = "Only" },
            },
        }, 400, 300)
        expect_near(175, centered.nodes[1].x, 0.001)
        expect_near(135, centered.nodes[1].y, 0.001)
    end)
end)

test_summary()
