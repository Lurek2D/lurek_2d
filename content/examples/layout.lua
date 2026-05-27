--- @title Graph Layout Algorithms
--- @desc Tree, DAG, and force-directed layouts for node positioning.

-- Define nodes
--@api-stub: lurek.layout.tree
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
    print("tree nodes = " .. #result.nodes)
    print("tree size = " .. result.width .. "x" .. result.height)
    print("root x = " .. result.nodes[1].x)
end

--@api-stub: lurek.layout.dag
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
    print("dag nodes = " .. #result.nodes)
    print("dag size = " .. result.width .. "x" .. result.height)
    print("node 2 y = " .. result.nodes[2].y)
end

--@api-stub: lurek.layout.force
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
    print("force nodes = " .. #result.nodes)
    print("force size = " .. result.width .. "x" .. result.height)
    print("node 1 pos = " .. result.nodes[1].x .. "," .. result.nodes[1].y)
end

--@api-stub: lurek.layout.snapToGrid
do
    local result = {
        nodes = {
            { id = 1, x = 13.5, y = 27.3, width = 40, height = 20 },
            { id = 2, x = 42.1, y = 11.9, width = 40, height = 20 },
        },
    }
    local snapped = lurek.layout.snapToGrid(result, 16)
    print("snapped nodes = " .. #snapped.nodes)
    print("node 1 = " .. snapped.nodes[1].x .. "," .. snapped.nodes[1].y)
    print("node 2 = " .. snapped.nodes[2].x .. "," .. snapped.nodes[2].y)
end

--@api-stub: lurek.layout.centerInArea
do
    local result = {
        nodes = {
            { id = 1, x = 0, y = 0, width = 50, height = 30 },
            { id = 2, x = 60, y = 0, width = 40, height = 30 },
        },
    }
    local centered = lurek.layout.centerInArea(result, 400, 300)
    print("centered nodes = " .. #centered.nodes)
    print("node 1 x = " .. centered.nodes[1].x)
    print("layout height = " .. centered.height)
end
