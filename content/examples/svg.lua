-- content/examples/svg.lua
-- Run: cargo run -- content/examples/svg.lua

--- SVG Vector Graphics Module Examples: loading, transformation, hit-testing, and GPU caching.

--@api-stub: lurek.svg.load
do
    -- Load an SVG image
    local svg = lurek.svg.load("tests/lua/unit/test.svg")
    print("Loaded SVG with type: " .. svg:type())
end

--@api-stub: LSvgImage:getWidth
do
    local svg = lurek.svg.load("tests/lua/unit/test.svg")
    print("SVG width = " .. svg:getWidth())
end

--@api-stub: LSvgImage:getHeight
do
    local svg = lurek.svg.load("tests/lua/unit/test.svg")
    print("SVG height = " .. svg:getHeight())
end

--@api-stub: LSvgImage:getDimensions
do
    local svg = lurek.svg.load("tests/lua/unit/test.svg")
    local w, h = svg:getDimensions()
    print("SVG dimensions = " .. w .. "x" .. h)
end

--@api-stub: LSvgImage:draw
do
    local svg = lurek.svg.load("tests/lua/unit/test.svg")
    -- Draw SVG at (10, 20) with rotation=0, scale=1, offset=0
    svg:draw(10, 20, 0, 1.0, 1.0, 0, 0)
    print("SVG draw command issued")
end

--@api-stub: LSvgImage:getElementIds
do
    local svg = lurek.svg.load("tests/lua/unit/test.svg")
    local ids = svg:getElementIds()
    print("Parsed element IDs: " .. table.concat(ids, ", "))
end

--@api-stub: LSvgImage:getElementCount
do
    local svg = lurek.svg.load("tests/lua/unit/test.svg")
    print("Element count = " .. svg:getElementCount())
end

--@api-stub: LSvgImage:setElementVisible
do
    local svg = lurek.svg.load("tests/lua/unit/test.svg")
    svg:setElementVisible("prov_1", false)
    print("Element visibility set")
end

--@api-stub: LSvgImage:getElementVisible
do
    local svg = lurek.svg.load("tests/lua/unit/test.svg")
    local vis = svg:getElementVisible("prov_1")
    print("prov_1 visible = " .. tostring(vis))
end

--@api-stub: LSvgImage:setElementColor
do
    local svg = lurek.svg.load("tests/lua/unit/test.svg")
    svg:setElementColor("prov_1", 1.0, 0.0, 0.0, 1.0)
    print("Element color override set")
end

--@api-stub: LSvgImage:getElementColor
do
    local svg = lurek.svg.load("tests/lua/unit/test.svg")
    svg:setElementColor("prov_1", 0.5, 0.25, 0.0, 1.0)
    local col = svg:getElementColor("prov_1")
    print("Color read back: r=" .. col[1] .. " g=" .. col[2])
end

--@api-stub: LSvgImage:resetElementColor
do
    local svg = lurek.svg.load("tests/lua/unit/test.svg")
    svg:setElementColor("prov_1", 1, 0, 0, 1)
    svg:resetElementColor("prov_1")
    print("Color reset: override cleared = " .. tostring(svg:getElementColor("prov_1") == nil))
end

--@api-stub: LSvgImage:setElementTransform
do
    local svg = lurek.svg.load("tests/lua/unit/test.svg")
    svg:setElementTransform("prov_1", 5, 10, 0.2, 1.5, 1.5)
    print("Element local transformation set")
end

--@api-stub: LSvgImage:getElementTransform
do
    local svg = lurek.svg.load("tests/lua/unit/test.svg")
    svg:setElementTransform("prov_1", 5, 10, 0.2, 1.5, 1.5)
    local trs = svg:getElementTransform("prov_1")
    print("Transform read: tx=" .. trs[1] .. " ty=" .. trs[2])
end

--@api-stub: LSvgImage:resetElementTransform
do
    local svg = lurek.svg.load("tests/lua/unit/test.svg")
    svg:setElementTransform("prov_1", 100, 200, 1.0, 3, 3)
    svg:resetElementTransform("prov_1")
    local trs = svg:getElementTransform("prov_1")
    print("After reset tx=" .. trs[1] .. " sx=" .. trs[4])
end

--@api-stub: LSvgImage:getElementBounds
do
    local svg = lurek.svg.load("tests/lua/unit/test.svg")
    local bounds = svg:getElementBounds("prov_1")
    if bounds then
        print("Bounds: min_x=" .. bounds.min_x .. " min_y=" .. bounds.min_y ..
              " max_x=" .. bounds.max_x .. " max_y=" .. bounds.max_y)
    end
end

--@api-stub: LSvgImage:getElementParent
do
    local svg = lurek.svg.load("tests/lua/unit/test.svg")
    local parent = svg:getElementParent("prov_1")
    print("Parent of prov_1 = " .. tostring(parent))
end

--@api-stub: LSvgImage:getElementChildren
do
    local svg = lurek.svg.load("tests/lua/unit/test.svg")
    local children = svg:getElementChildren("group1")
    print("Children of group1 count = " .. #children)
end

--@api-stub: LSvgImage:getElementPoints
do
    local svg = lurek.svg.load("tests/lua/unit/test.svg")
    local pts = svg:getElementPoints("prov_1", 10.0)
    print("Tesselated points count = " .. #pts)
end

--@api-stub: LSvgImage:getAdjacencies
do
    local svg = lurek.svg.load("tests/lua/unit/test.svg")
    local adj = svg:getAdjacencies("prov_", 5.0)
    print("Adjacency calculated successfully")
end

--@api-stub: LSvgImage:cacheToCanvas
do
    local svg = lurek.svg.load("tests/lua/unit/test.svg")
    svg:cacheToCanvas("group1", 100, 100)
    print("Cached group1 to canvas")
end

--@api-stub: LSvgImage:getCanvasKey
do
    local svg = lurek.svg.load("tests/lua/unit/test.svg")
    svg:cacheToCanvas("group1", 100, 100)
    local canvas = svg:getCanvasKey("group1")
    print("Canvas key retrieved: " .. tostring(canvas ~= nil))
end

--@api-stub: LSvgImage:getCanvas
do
    local svg = lurek.svg.load("tests/lua/unit/test.svg")
    svg:cacheToCanvas("group1", 100, 100)
    local canvas = svg:getCanvas("group1")
    print("Canvas alias retrieved: " .. tostring(canvas ~= nil))
end

--@api-stub: LSvgImage:type
do
    local svg = lurek.svg.load("tests/lua/unit/test.svg")
    print("Type is: " .. svg:type())
end

--@api-stub: LSvgImage:typeOf
do
    local svg = lurek.svg.load("tests/lua/unit/test.svg")
    print("Is type of LSvgImage: " .. tostring(svg:typeOf("LSvgImage")))
end
