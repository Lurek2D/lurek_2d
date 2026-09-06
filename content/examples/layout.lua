--- @title Graph Layout Algorithms
--- @desc Size-aware tree, DAG, force, ring, grid, spiral, and stress layouts for readable node positioning.

-- Define nodes

--@api: lurek.layout.tree
do

local nodes = {
{ id = 1, width = 110, height = 34, label = "Root" },
{ id = 2, width = 70, height = 28, label = "HUD" },
{ id = 3, width = 130, height = 30, label = "Simulation" },
{ id = 4, width = 84, height = 28, label = "Tools" },
}
local children = {
[1] = { 2, 3, 4 },
}
local result = lurek.layout.tree(nodes, children, 1, {
hSpacing = 28,
vSpacing = 48,
margin = 20,
})
lurek.log.info(tostring("tree nodes = " .. #result.nodes))
lurek.log.info(tostring("tree size = " .. result.width .. "x" .. result.height))
end

--@api: lurek.layout.dag
do

local nodes = {
{ id = 1, width = 86, height = 34, label = "Source" },
{ id = 2, width = 96, height = 48, label = "Build" },
{ id = 3, width = 76, height = 30, label = "Lint" },
{ id = 4, width = 94, height = 36, label = "Package" },
{ id = 5, width = 82, height = 30, label = "Ship" },
}
local edges = {
{ from = 1, to = 2, weight = 1.0 },
{ from = 1, to = 3, weight = 1.0 },
{ from = 2, to = 4, weight = 1.0 },
{ from = 3, to = 4, weight = 1.0 },
{ from = 4, to = 5, weight = 1.0 },
}
end

--@api: lurek.layout.force
do

local nodes = {
{ id = 1, width = 62, height = 28, label = "Core" },
{ id = 2, width = 78, height = 30, label = "AI" },
{ id = 3, width = 68, height = 28, label = "Save" },
{ id = 4, width = 74, height = 30, label = "UI" },
{ id = 5, width = 66, height = 28, label = "Map" },
{ id = 6, width = 84, height = 32, label = "Path" },
}
local edges = {
{ from = 1, to = 2, weight = 1.0 },
{ from = 2, to = 3, weight = 1.0 },
{ from = 1, to = 4, weight = 0.8 },
{ from = 4, to = 5, weight = 0.8 },
{ from = 5, to = 6, weight = 1.2 },
{ from = 2, to = 6, weight = 0.7 },
}
end

--@api: lurek.layout.circular
do

    local nodes = {
        { id = 1, width = 64, height = 28, label = "Auth" },
        { id = 2, width = 72, height = 28, label = "API" },
        { id = 3, width = 62, height = 28, label = "UI" },
        { id = 4, width = 76, height = 28, label = "Cache" },
        { id = 5, width = 74, height = 28, label = "Queue" },
        { id = 6, width = 68, height = 28, label = "Mail" },
        { id = 7, width = 70, height = 28, label = "Billing" },
        { id = 8, width = 60, height = 28, label = "DB" },
    }
    local result = lurek.layout.circular(nodes, { hSpacing = 28, vSpacing = 28, margin = 12 })
    lurek.log.info(tostring("circular nodes = " .. #result.nodes))
    lurek.log.info(tostring("circular size = " .. result.width .. "x" .. result.height))
    lurek.log.info(tostring("first node = " .. result.nodes[1].x .. "," .. result.nodes[1].y))
end

--@api: lurek.layout.radial
do

local nodes = {
{ id = 1, width = 70, height = 30, label = "Gateway" },
{ id = 2, width = 64, height = 28, label = "Auth" },
{ id = 3, width = 64, height = 28, label = "API" },
{ id = 4, width = 64, height = 28, label = "CDN" },
{ id = 5, width = 72, height = 28, label = "Users" },
{ id = 6, width = 76, height = 28, label = "Orders" },
{ id = 7, width = 70, height = 28, label = "Media" },
}
end

--@api: lurek.layout.grid
do

    local nodes = {
        { id = 1, width = 58, height = 24, label = "HP" },
        { id = 2, width = 90, height = 30, label = "Inventory" },
        { id = 3, width = 64, height = 26, label = "Map" },
        { id = 4, width = 82, height = 28, label = "Journal" },
        { id = 5, width = 70, height = 24, label = "Skills" },
        { id = 6, width = 96, height = 32, label = "Equipment" },
        { id = 7, width = 62, height = 24, label = "Quest" },
    }
    local result = lurek.layout.grid(nodes, { hSpacing = 14, vSpacing = 18, margin = 10 })
    lurek.log.info(tostring("grid nodes = " .. #result.nodes))
    lurek.log.info(tostring("grid first x = " .. result.nodes[1].x))
    lurek.log.info(tostring("grid size = " .. result.width .. "x" .. result.height))
end

--@api: lurek.layout.spiral
do

    local nodes = {
        { id = 1, width = 58, height = 26, label = "S1" },
        { id = 2, width = 78, height = 28, label = "S2" },
        { id = 3, width = 64, height = 26, label = "S3" },
        { id = 4, width = 92, height = 30, label = "S4" },
        { id = 5, width = 70, height = 26, label = "S5" },
        { id = 6, width = 80, height = 28, label = "S6" },
        { id = 7, width = 60, height = 26, label = "S7" },
        { id = 8, width = 88, height = 30, label = "S8" },
        { id = 9, width = 72, height = 28, label = "S9" },
        { id = 10, width = 66, height = 26, label = "S10" },
    }
    local result = lurek.layout.spiral(nodes, { hSpacing = 12, vSpacing = 12, margin = 10 })
    lurek.log.info(tostring("spiral nodes = " .. #result.nodes))
    lurek.log.info(tostring("spiral last id = " .. result.nodes[#result.nodes].id))
    lurek.log.info(tostring("spiral size = " .. result.width .. "x" .. result.height))
end

--@api: lurek.layout.stress
do

local nodes = {
{ id = 1, width = 58, height = 26, label = "A1" },
{ id = 2, width = 58, height = 26, label = "A2" },
{ id = 3, width = 58, height = 26, label = "A3" },
{ id = 4, width = 58, height = 26, label = "A4" },
{ id = 5, width = 64, height = 28, label = "B1" },
{ id = 6, width = 64, height = 28, label = "B2" },
{ id = 7, width = 64, height = 28, label = "B3" },
{ id = 8, width = 64, height = 28, label = "B4" },
}
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
    lurek.log.info(tostring("snapped nodes = " .. #snapped.nodes))
    lurek.log.info(tostring("node 1 = " .. snapped.nodes[1].x .. "," .. snapped.nodes[1].y))
    lurek.log.info(tostring("node 2 = " .. snapped.nodes[2].x .. "," .. snapped.nodes[2].y))
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
    lurek.log.info(tostring("centered nodes = " .. #centered.nodes))
    lurek.log.info(tostring("node 1 x = " .. centered.nodes[1].x))
    lurek.log.info(tostring("layout height = " .. centered.height))
end
