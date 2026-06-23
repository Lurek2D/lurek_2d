-- content/examples/svg.lua
-- Run: cargo run -- content/examples/svg.lua





--- SVG Vector Graphics Module Examples: loading, hierarchy inspection, province transforms, and GPU caching.

--@api: lurek.svg.load
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    local width, height = svg:getDimensions()
    local count = svg:getElementCount()
    local ids = svg:getElementIds()
    svg_log("loaded map svg type=" .. svg:type() .. " size=" .. width .. "x" .. height .. " elements=" .. count .. " first=" .. tostring(ids[1]))
end

--@api: LSvgImage:getWidth
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    local width = svg:getWidth()
    local height = svg:getHeight()
    local aspect = width / height
    svg_log("svg width=" .. width .. " height=" .. height .. " aspect=" .. aspect)
end

--@api: LSvgImage:getHeight
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    local height = svg:getHeight()
    local width = svg:getWidth()
    local aspect = width / height
    svg_log("svg height=" .. height .. " width=" .. width .. " aspect=" .. aspect)
end

--@api: LSvgImage:getDimensions
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    local width, height = svg:getDimensions()
    local count = svg:getElementCount()
    local ids = svg:getElementIds()
    svg_log("svg dimensions=" .. width .. "x" .. height .. " ids=" .. #ids .. " elements=" .. count)
end

--@api: LSvgImage:draw
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    svg:setElementVisible("prov_2", false)
    svg:setElementColor("prov_1", 1.0, 0.3, 0.3, 1.0)
    svg:draw(24, 32, 0.0, 1.0, 1.0, 0, 0)
    svg_log("draw issued for highlighted prov_1 with prov_2 hidden")
end

--@api: LSvgImage:getElementIds
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    local ids = svg:getElementIds()
    table.sort(ids)
    local joined = table.concat(ids, ", ")
    svg_log("element ids=" .. joined)
end

--@api: LSvgImage:getElementCount
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    local count = svg:getElementCount()
    local ids = svg:getElementIds()
    local width, height = svg:getDimensions()
    svg_log("element count=" .. count .. " ids_listed=" .. #ids .. " size=" .. width .. "x" .. height)
end

--@api: LSvgImage:setElementVisible
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    svg:setElementVisible("prov_1", false)
    local hidden = svg:getElementVisible("prov_1")
    svg:setElementVisible("prov_1", true)
    svg_log("setElementVisible hidden=" .. tostring(hidden) .. " restored=" .. tostring(svg:getElementVisible("prov_1")))
end

--@api: LSvgImage:getElementVisible
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    local before = svg:getElementVisible("prov_1")
    svg:setElementVisible("prov_1", false)
    local after = svg:getElementVisible("prov_1")
    svg_log("getElementVisible before=" .. tostring(before) .. " after_hide=" .. tostring(after))
end

--@api: LSvgImage:setElementColor
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    svg:setElementColor("prov_1", 1.0, 0.0, 0.0, 1.0)
    local color = svg:getElementColor("prov_1")
    local visible = svg:getElementVisible("prov_1")
    svg_log("setElementColor prov_1=" .. color_text(color) .. " visible=" .. tostring(visible))
end

--@api: LSvgImage:getElementColor
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    local before = svg:getElementColor("prov_1")
    svg:setElementColor("prov_1", 0.5, 0.25, 0.0, 1.0)
    local after = svg:getElementColor("prov_1")
    svg_log("getElementColor before=" .. color_text(before) .. " after=" .. color_text(after))
end

--@api: LSvgImage:resetElementColor
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    svg:setElementColor("prov_1", 1.0, 0.1, 0.1, 1.0)
    local before = svg:getElementColor("prov_1")
    svg:resetElementColor("prov_1")
    svg_log("resetElementColor before=" .. color_text(before) .. " after=" .. color_text(svg:getElementColor("prov_1")))
end

--@api: LSvgImage:setElementTransform
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    svg:setElementTransform("prov_1", 5, 10, 0.2, 1.5, 1.5)
    local transform = svg:getElementTransform("prov_1")
    local bounds = svg:getElementBounds("prov_1")
    svg_log("setElementTransform prov_1=" .. transform_text(transform) .. " bounds_min=" .. bounds.min_x .. "," .. bounds.min_y)
end

--@api: LSvgImage:getElementTransform
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    local initial = svg:getElementTransform("prov_1")
    svg:setElementTransform("prov_1", 10, 20, 0.5, 2.0, 3.0)
    local updated = svg:getElementTransform("prov_1")
    svg_log("getElementTransform initial=" .. transform_text(initial) .. " updated=" .. transform_text(updated))
end

--@api: LSvgImage:resetElementTransform
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    svg:setElementTransform("prov_1", 100, 200, 1.0, 3.0, 3.0)
    local before = svg:getElementTransform("prov_1")
    svg:resetElementTransform("prov_1")
    svg_log("resetElementTransform before=" .. transform_text(before) .. " after=" .. transform_text(svg:getElementTransform("prov_1")))
end

--@api: LSvgImage:getElementBounds
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    local bounds = svg:getElementBounds("prov_1")
    local width = bounds.max_x - bounds.min_x
    local height = bounds.max_y - bounds.min_y
    svg_log("prov_1 bounds min=" .. bounds.min_x .. "," .. bounds.min_y .. " size=" .. width .. "x" .. height)
end

--@api: LSvgImage:getElementParent
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    local parent = svg:getElementParent("prov_1")
    local siblings = parent and svg:getElementChildren(parent) or {}
    local count = siblings and #siblings or 0
    svg_log("prov_1 parent=" .. tostring(parent) .. " sibling_count=" .. count)
end

--@api: LSvgImage:getElementChildren
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    local children = svg:getElementChildren("group1")
    local first = children[1] or "none"
    local count = #children
    svg_log("group1 children=" .. count .. " first=" .. tostring(first))
end

--@api: LSvgImage:getElementPoints
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    local points = svg:getElementPoints("prov_1", 10.0)
    local first = points[1]
    local last = points[#points]
    svg_log("prov_1 points=" .. #points .. " first=" .. first.x .. "," .. first.y .. " last=" .. last.x .. "," .. last.y)
end

--@api: LSvgImage:getAdjacencies
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    local adjacency = svg:getAdjacencies("prov_", 5.0)
    local p1 = adjacency["prov_1"] or {}
    local p2 = adjacency["prov_2"] or {}
    svg_log("adjacency prov_1=" .. table.concat(p1, ",") .. " prov_2=" .. table.concat(p2, ","))
end

--@api: LSvgImage:cacheToCanvas
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    svg:cacheToCanvas("group1", 100, 100)
    local key = svg:getCanvasKey("group1")
    local canvas = svg:getCanvas("group1")
    svg_log("cacheToCanvas key_ready=" .. tostring(key ~= nil) .. " canvas_ready=" .. tostring(canvas ~= nil))
end

--@api: LSvgImage:getCanvasKey
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    svg:cacheToCanvas("group1", 100, 100)
    local key = svg:getCanvasKey("group1")
    local alias = svg:getCanvas("group1")
    svg_log("getCanvasKey has_key=" .. tostring(key ~= nil) .. " alias_ready=" .. tostring(alias ~= nil))
end

--@api: LSvgImage:getCanvas
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    svg:cacheToCanvas("group1", 100, 100)
    local canvas = svg:getCanvas("group1")
    local key = svg:getCanvasKey("group1")
    svg_log("getCanvas canvas_ready=" .. tostring(canvas ~= nil) .. " key_ready=" .. tostring(key ~= nil))
end

--@api: LSvgImage:type
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    local kind = svg:type()
    local width, height = svg:getDimensions()
    local count = svg:getElementCount()
    svg_log("type kind=" .. kind .. " size=" .. width .. "x" .. height .. " elements=" .. count)
end

--@api: LSvgImage:typeOf
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    local is_svg = svg:typeOf("LSvgImage")
    local is_object = svg:typeOf("LObject")
    local ids = svg:getElementIds()
    svg_log("typeOf svg=" .. tostring(is_svg) .. " object=" .. tostring(is_object) .. " ids=" .. #ids)
end
