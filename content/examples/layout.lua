--- @title Graph Layout Algorithms
--- @desc Tree, DAG, and force-directed layouts for node positioning.

-- Define nodes
local function example_print_log(...)
    local parts = {}
    for i = 1, select("#", ...) do
        parts[i] = tostring(select(i, ...))
    end
    lurek.log.info(table.concat(parts, " "))
end

--@api: lurek.layout.tree
do
    local nodes = {
        { id = 1, width = 60, height = 30, label = "Root" },
        { id = 2, width = 50, height = 24, label = "Left" },
        { id = 3, width = 50, height = 24, label = "Right" },
    }
    local children = {
        [1] = { 2, 3 },
    }
    local result = lurek.layout.tree(nodes, children, 1, {
        hSpacing = 70,
        vSpacing = 90,
        margin = 20,
    })
    example_print_log("tree nodes = " .. #result.nodes)
    example_print_log("tree size = " .. result.width .. "x" .. result.height)
    example_print_log("root x = " .. result.nodes[1].x)
end

--@api: lurek.layout.dag
do
    local nodes = {
        { id = 1, width = 60, height = 30, label = "Start" },
        { id = 2, width = 60, height = 30, label = "Build" },
        { id = 3, width = 60, height = 30, label = "Test" },
    }
    local edges = {
        { from = 1, to = 2, weight = 1.0 },
        { from = 1, to = 3, weight = 1.0 },
    }
    local result = lurek.layout.dag(nodes, edges, {
        hSpacing = 80,
        vSpacing = 100,
        margin = 24,
    })
    example_print_log("dag nodes = " .. #result.nodes)
    example_print_log("dag size = " .. result.width .. "x" .. result.height)
    example_print_log("node 2 y = " .. result.nodes[2].y)
end

--@api: lurek.layout.force
do
    local nodes = {
        { id = 1, width = 40, height = 24, label = "A" },
        { id = 2, width = 40, height = 24, label = "B" },
        { id = 3, width = 40, height = 24, label = "C" },
    }
    local edges = {
        { from = 1, to = 2, weight = 1.0 },
        { from = 2, to = 3, weight = 1.0 },
    }
    local result = lurek.layout.force(nodes, edges, {
        iterations = 40,
        repulsion = 6000,
        attraction = 0.02,
        cooling = 0.9,
        areaWidth = 400,
        areaHeight = 300,
    })
    example_print_log("force nodes = " .. #result.nodes)
    example_print_log("force size = " .. result.width .. "x" .. result.height)
    example_print_log("node 1 pos = " .. result.nodes[1].x .. "," .. result.nodes[1].y)
end

--@api: lurek.layout.snapToGrid
do
    local result = {
        nodes = {
            { id = 1, x = 13.5, y = 27.3, width = 40, height = 20 },
            { id = 2, x = 42.1, y = 11.9, width = 40, height = 20 },
        },
    }
    local snapped = lurek.layout.snapToGrid(result, 16)
    example_print_log("snapped nodes = " .. #snapped.nodes)
    example_print_log("node 1 = " .. snapped.nodes[1].x .. "," .. snapped.nodes[1].y)
    example_print_log("node 2 = " .. snapped.nodes[2].x .. "," .. snapped.nodes[2].y)
end

--@api: lurek.layout.centerInArea
do
    local result = {
        nodes = {
            { id = 1, x = 0, y = 0, width = 50, height = 30 },
            { id = 2, x = 60, y = 0, width = 40, height = 30 },
        },
    }
    local centered = lurek.layout.centerInArea(result, 400, 300)
    example_print_log("centered nodes = " .. #centered.nodes)
    example_print_log("node 1 x = " .. centered.nodes[1].x)
    example_print_log("layout height = " .. centered.height)
end
