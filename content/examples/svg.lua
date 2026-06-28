-- content/examples/svg.lua
-- Run: cargo run -- content/examples/svg.lua





--- SVG Vector Graphics Module Examples: loading, hierarchy inspection, province transforms, and GPU caching.

--@api: lurek.svg.load
do

    local svg = lurek.svg.load("content/examples/assets/test.svg")
    local width, height = svg:getDimensions()
    local count = svg:getElementCount()
    local ids = svg:getElementIds()
    lurek.log.info("loaded map svg type=" .. svg:type() .. " size=" .. width .. "x" .. height .. " elements=" .. count .. " first=" .. tostring(ids[1]))
end

--@api: LSvgImage:getWidth
do

    local svg = lurek.svg.load("content/examples/assets/test.svg")
    local width = svg:getWidth()
    local height = svg:getHeight()
    local aspect = width / height
    lurek.log.info("svg width=" .. width .. " height=" .. height .. " aspect=" .. aspect)
end

--@api: LSvgImage:getHeight
do

    local svg = lurek.svg.load("content/examples/assets/test.svg")
    local height = svg:getHeight()
    local width = svg:getWidth()
    local aspect = width / height
    lurek.log.info("svg height=" .. height .. " width=" .. width .. " aspect=" .. aspect)
end

--@api: LSvgImage:getDimensions
do

    local svg = lurek.svg.load("content/examples/assets/test.svg")
    local width, height = svg:getDimensions()
    local count = svg:getElementCount()
    local ids = svg:getElementIds()
    lurek.log.info("svg dimensions=" .. width .. "x" .. height .. " ids=" .. #ids .. " elements=" .. count)
end

--@api: LSvgImage:draw
do

    local svg = lurek.svg.load("content/examples/assets/test.svg")
    svg:setElementVisible("prov_2", false)
    svg:setElementColor("prov_1", 1.0, 0.3, 0.3, 1.0)
    svg:draw(24, 32, 0.0, 1.0, 1.0, 0, 0)
    lurek.log.info("draw issued for highlighted prov_1 with prov_2 hidden")
end

--@api: LSvgImage:getElementIds
do

    local svg = lurek.svg.load("content/examples/assets/test.svg")
    local ids = svg:getElementIds()
    table.sort(ids)
    local joined = table.concat(ids, ", ")
    lurek.log.info("element ids=" .. joined)
end

--@api: LSvgImage:getElementCount
do

    local svg = lurek.svg.load("content/examples/assets/test.svg")
    local count = svg:getElementCount()
    local ids = svg:getElementIds()
    local width, height = svg:getDimensions()
    lurek.log.info("element count=" .. count .. " ids_listed=" .. #ids .. " size=" .. width .. "x" .. height)
end

--@api: LSvgImage:setElementVisible
do

    local svg = lurek.svg.load("content/examples/assets/test.svg")
    svg:setElementVisible("prov_1", false)
    local hidden = svg:getElementVisible("prov_1")
    svg:setElementVisible("prov_1", true)
    lurek.log.info("setElementVisible hidden=" .. tostring(hidden) .. " restored=" .. tostring(svg:getElementVisible("prov_1")))
end

--@api: LSvgImage:getElementVisible
do

    local svg = lurek.svg.load("content/examples/assets/test.svg")
    local before = svg:getElementVisible("prov_1")
    svg:setElementVisible("prov_1", false)
    local after = svg:getElementVisible("prov_1")
    lurek.log.info("getElementVisible before=" .. tostring(before) .. " after_hide=" .. tostring(after))
end

--@api: LSvgImage:setElementColor
do

    local svg = lurek.svg.load("content/examples/assets/test.svg")
    svg:setElementColor("prov_1", 1.0, 0.0, 0.0, 1.0)
    local color = svg:getElementColor("prov_1")
    local visible = svg:getElementVisible("prov_1")
    lurek.log.info("setElementColor prov_1=" .. ((color) and table.concat({ tostring((color)[1]), tostring((color)[2]), tostring((color)[3]), tostring((color)[4]) }, ",") or "nil") .. " visible=" .. tostring(visible))
end

--@api: LSvgImage:getElementColor
do

    local svg = lurek.svg.load("content/examples/assets/test.svg")
    local before = svg:getElementColor("prov_1")
    svg:setElementColor("prov_1", 0.5, 0.25, 0.0, 1.0)
    local after = svg:getElementColor("prov_1")
    lurek.log.info("getElementColor before=" .. ((before) and table.concat({ tostring((before)[1]), tostring((before)[2]), tostring((before)[3]), tostring((before)[4]) }, ",") or "nil") .. " after=" .. ((after) and table.concat({ tostring((after)[1]), tostring((after)[2]), tostring((after)[3]), tostring((after)[4]) }, ",") or "nil"))
end

--@api: LSvgImage:resetElementColor
do

    local svg = lurek.svg.load("content/examples/assets/test.svg")
    svg:setElementColor("prov_1", 1.0, 0.1, 0.1, 1.0)
    local before = svg:getElementColor("prov_1")
    svg:resetElementColor("prov_1")
    lurek.log.info("resetElementColor before=" .. ((before) and table.concat({ tostring((before)[1]), tostring((before)[2]), tostring((before)[3]), tostring((before)[4]) }, ",") or "nil") .. " after=" .. ((svg:getElementColor("prov_1")) and table.concat({ tostring((svg:getElementColor("prov_1"))[1]), tostring((svg:getElementColor("prov_1"))[2]), tostring((svg:getElementColor("prov_1"))[3]), tostring((svg:getElementColor("prov_1"))[4]) }, ",") or "nil"))
end

--@api: LSvgImage:setElementTransform
do

    local svg = lurek.svg.load("content/examples/assets/test.svg")
    svg:setElementTransform("prov_1", 5, 10, 0.2, 1.5, 1.5)
    local transform = svg:getElementTransform("prov_1")
    local bounds = svg:getElementBounds("prov_1")
    lurek.log.info("setElementTransform prov_1=" .. ((transform) and table.concat({ tostring((transform)[1]), tostring((transform)[2]), tostring((transform)[3]), tostring((transform)[4]), tostring((transform)[5]) }, ",") or "nil") .. " bounds_min=" .. bounds.min_x .. "," .. bounds.min_y)
end

--@api: LSvgImage:getElementTransform
do

    local svg = lurek.svg.load("content/examples/assets/test.svg")
    local initial = svg:getElementTransform("prov_1")
    svg:setElementTransform("prov_1", 10, 20, 0.5, 2.0, 3.0)
    local updated = svg:getElementTransform("prov_1")
    lurek.log.info("getElementTransform initial=" .. ((initial) and table.concat({ tostring((initial)[1]), tostring((initial)[2]), tostring((initial)[3]), tostring((initial)[4]), tostring((initial)[5]) }, ",") or "nil") .. " updated=" .. ((updated) and table.concat({ tostring((updated)[1]), tostring((updated)[2]), tostring((updated)[3]), tostring((updated)[4]), tostring((updated)[5]) }, ",") or "nil"))
end

--@api: LSvgImage:resetElementTransform
do

    local svg = lurek.svg.load("content/examples/assets/test.svg")
    svg:setElementTransform("prov_1", 100, 200, 1.0, 3.0, 3.0)
    local before = svg:getElementTransform("prov_1")
    svg:resetElementTransform("prov_1")
    lurek.log.info("resetElementTransform before=" .. ((before) and table.concat({ tostring((before)[1]), tostring((before)[2]), tostring((before)[3]), tostring((before)[4]), tostring((before)[5]) }, ",") or "nil") .. " after=" .. ((svg:getElementTransform("prov_1")) and table.concat({ tostring((svg:getElementTransform("prov_1"))[1]), tostring((svg:getElementTransform("prov_1"))[2]), tostring((svg:getElementTransform("prov_1"))[3]), tostring((svg:getElementTransform("prov_1"))[4]), tostring((svg:getElementTransform("prov_1"))[5]) }, ",") or "nil"))
end

--@api: LSvgImage:getElementBounds
do

    local svg = lurek.svg.load("content/examples/assets/test.svg")
    local bounds = svg:getElementBounds("prov_1")
    local width = bounds.max_x - bounds.min_x
    local height = bounds.max_y - bounds.min_y
    lurek.log.info("prov_1 bounds min=" .. bounds.min_x .. "," .. bounds.min_y .. " size=" .. width .. "x" .. height)
end

--@api: LSvgImage:getElementParent
do

    local svg = lurek.svg.load("content/examples/assets/test.svg")
    local parent = svg:getElementParent("prov_1")
    local siblings = parent and svg:getElementChildren(parent) or {}
    local count = siblings and #siblings or 0
    lurek.log.info("prov_1 parent=" .. tostring(parent) .. " sibling_count=" .. count)
end

--@api: LSvgImage:getElementChildren
do

    local svg = lurek.svg.load("content/examples/assets/test.svg")
    local children = svg:getElementChildren("group1")
    local first = children[1] or "none"
    local count = #children
    lurek.log.info("group1 children=" .. count .. " first=" .. tostring(first))
end

--@api: LSvgImage:getElementPoints
do

    local svg = lurek.svg.load("content/examples/assets/test.svg")
    local points = svg:getElementPoints("prov_1", 10.0)
    local first = points[1]
    local last = points[#points]
    lurek.log.info("prov_1 points=" .. #points .. " first=" .. first.x .. "," .. first.y .. " last=" .. last.x .. "," .. last.y)
end

--@api: LSvgImage:getAdjacencies
do

    local svg = lurek.svg.load("content/examples/assets/test.svg")
    local adjacency = svg:getAdjacencies("prov_", 5.0)
    local p1 = adjacency["prov_1"] or {}
    local p2 = adjacency["prov_2"] or {}
    lurek.log.info("adjacency prov_1=" .. table.concat(p1, ",") .. " prov_2=" .. table.concat(p2, ","))
end

--@api: LSvgImage:cacheToCanvas
do

    local svg = lurek.svg.load("content/examples/assets/test.svg")
    svg:cacheToCanvas("group1", 100, 100)
    local key = svg:getCanvasKey("group1")
    local canvas = svg:getCanvas("group1")
    lurek.log.info("cacheToCanvas key_ready=" .. tostring(key ~= nil) .. " canvas_ready=" .. tostring(canvas ~= nil))
end

--@api: LSvgImage:getCanvasKey
do

    local svg = lurek.svg.load("content/examples/assets/test.svg")
    svg:cacheToCanvas("group1", 100, 100)
    local key = svg:getCanvasKey("group1")
    local alias = svg:getCanvas("group1")
    lurek.log.info("getCanvasKey has_key=" .. tostring(key ~= nil) .. " alias_ready=" .. tostring(alias ~= nil))
end

--@api: LSvgImage:getCanvas
do

    local svg = lurek.svg.load("content/examples/assets/test.svg")
    svg:cacheToCanvas("group1", 100, 100)
    local canvas = svg:getCanvas("group1")
    local key = svg:getCanvasKey("group1")
    lurek.log.info("getCanvas canvas_ready=" .. tostring(canvas ~= nil) .. " key_ready=" .. tostring(key ~= nil))
end

--@api: LSvgImage:type
do

    local svg = lurek.svg.load("content/examples/assets/test.svg")
    local kind = svg:type()
    local width, height = svg:getDimensions()
    local count = svg:getElementCount()
    lurek.log.info("type kind=" .. kind .. " size=" .. width .. "x" .. height .. " elements=" .. count)
end

--@api: LSvgImage:typeOf
do

    local svg = lurek.svg.load("content/examples/assets/test.svg")
    local is_svg = svg:typeOf("LSvgImage")
    local is_object = svg:typeOf("LObject")
    local ids = svg:getElementIds()
    lurek.log.info("typeOf svg=" .. tostring(is_svg) .. " object=" .. tostring(is_object) .. " ids=" .. #ids)
end
