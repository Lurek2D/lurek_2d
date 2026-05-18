--- Math Module Part 6: random, tween, spatial, circle, color, easings

--@api-stub: lurek.math.newRandomGenerator
-- Creates a deterministic random generator.
do
    ---@type LRandomGenerator
    local rng = lurek.math.newRandomGenerator(42)
    print("seed = " .. rng:getSeed())
end

--@api-stub: LRandomGenerator:random / randomFloat / randomInt / randomNormal
-- Random value generators.
do
    ---@type LRandomGenerator
    local rng = lurek.math.newRandomGenerator(100)
    local r = rng:random()
    local rf = rng:randomFloat(1.0, 5.0)
    local ri = rng:randomInt(1, 100)
    local rn = rng:randomNormal(1.0, 0.0)
    print("random=" .. r .. " float=" .. rf .. " int=" .. ri .. " normal=" .. rn)
end

--@api-stub: LRandomGenerator:setSeed / getState / setState
-- Seed and state management.
do
    ---@type LRandomGenerator
    local rng = lurek.math.newRandomGenerator(1)
    rng:setSeed(999)
    local state = rng:getState()
    rng:random()
    rng:setState(state)
    print("state restored, seed = " .. rng:getSeed())
end

--@api-stub: lurek.math.newTween
-- Creates a tween with duration and optional easing.
do
    ---@type LTween
    local tw = lurek.math.newTween(2.0, "inOutCubic")
    print("duration = " .. tw:getDuration())
    print("easing = " .. tw:getEasingName())
end

--@api-stub: LTween:addValue / getValue / getAllValues / getValueCount
-- Tweened value channels.
do
    ---@type LTween
    local tw = lurek.math.newTween(1.0, "linear")
    local idx1 = tw:addValue(0, 100)
    local idx2 = tw:addValue(50, 200)
    print("channels = " .. tw:getValueCount())
    tw:setTime(0.5)
    print("ch1 = " .. tw:getValue(idx1) .. " ch2 = " .. tw:getValue(idx2))
    local all = tw:getAllValues()
    print("all count = " .. #all)
end

--@api-stub: LTween:update / isComplete / reset
-- Tween playback.
do
    ---@type LTween
    local tw = lurek.math.newTween(1.0, "outBounce")
    tw:addValue(0, 10)
    local done = tw:update(0.5)
    print("half done = " .. tostring(done) .. " val = " .. tw:getValue())
    tw:update(0.6)
    print("complete = " .. tostring(tw:isComplete()))
    tw:reset()
    print("after reset clock = " .. tw:getClock())
end

--@api-stub: LTween:set / setTime / getTime / getClock
-- Direct time control.
do
    ---@type LTween
    local tw = lurek.math.newTween(2.0)
    tw:addValue(0, 100)
    tw:set(0.75)
    print("set 75%% = " .. tw:getValue())
    tw:setTime(1.0)
    print("time 1.0 = " .. tw:getTime() .. " clock = " .. tw:getClock())
end

--@api-stub: lurek.math.aabbTree
-- Creates an AABB tree for broad-phase queries.
do
    ---@type LAabbTree
    local tree = lurek.math.aabbTree()
    tree:insert(1, 0, 0, 10, 10)
    tree:insert(2, 5, 5, 15, 15)
    tree:insert(3, 100, 100, 110, 110)
    print("len = " .. tree:len() .. " empty = " .. tostring(tree:isEmpty()))
end

--@api-stub: LAabbTree:query / queryPoint / contains / remove / update
-- Spatial queries and mutation.
do
    ---@type LAabbTree
    local tree = lurek.math.aabbTree()
    tree:insert(1, 0, 0, 10, 10)
    tree:insert(2, 5, 5, 15, 15)
    local hits = tree:query(4, 4, 6, 6)
    print("query hits = " .. #hits)
    local pt = tree:queryPoint(7, 7)
    print("point hits = " .. #pt)
    print("contains 1 = " .. tostring(tree:contains(1)))
    tree:update(1, 20, 20, 30, 30)
    tree:remove(2)
    print("after remove len = " .. tree:len())
end

--@api-stub: lurek.math.newSpatialHash
-- Creates a spatial hash for broad-phase queries.
do
    ---@type LSpatialHash
    local sh = lurek.math.newSpatialHash(32)
    sh:insert("a", 10, 10, 20, 20)
    sh:insert("b", 50, 50, 30, 30)
    print("cell size = " .. sh:getCellSize() .. " items = " .. sh:getItemCount())
end

--@api-stub: LSpatialHash:queryRect / queryCircle / querySegment / remove / update
-- Spatial hash queries.
do
    ---@type LSpatialHash
    local sh = lurek.math.newSpatialHash(16)
    sh:insert("a", 0, 0, 10, 10)
    sh:insert("b", 5, 5, 10, 10)
    sh:insert("c", 100, 100, 10, 10)
    local r = sh:queryRect(0, 0, 12, 12)
    local c = sh:queryCircle(5, 5, 10)
    local s = sh:querySegment(0, 0, 50, 50)
    print("rect=" .. #r .. " circle=" .. #c .. " seg=" .. #s)
    sh:update("a", 200, 200, 10, 10)
    sh:remove("c")
    print("items after = " .. sh:getItemCount())
end

--@api-stub: lurek.math.newRectPacker
-- Creates a rectangle packer.
do
    ---@type LRectPacker
    local rp = lurek.math.newRectPacker(256, 256, 1)
    local x1, y1 = rp:pack(32, 32, "icon1")
    local x2, y2 = rp:pack(64, 64, "icon2")
    if x1 and y1 then
        print("icon1 at " .. x1 .. "," .. y1)
    end
    if x2 and y2 then
        print("icon2 at " .. x2 .. "," .. y2)
    end
    print("occupancy = " .. rp:occupancy())
    local packed = rp:getPacked()
    print("packed count = " .. #packed)
    rp:clear()
end

--@api-stub: lurek.math.newCircle
-- Creates a circle primitive.
do
    ---@type LCircle
    local c = lurek.math.newCircle(50, 50, 25)
    print("circle at " .. c:x() .. "," .. c:y() .. " r=" .. c:radius())
    print("area = " .. c:area())
    print("perimeter = " .. c:perimeter())
end

--@api-stub: LCircle:contains / intersects / aabb
-- Circle spatial tests.
do
    ---@type LCircle
    local c1 = lurek.math.newCircle(0, 0, 10)
    ---@type LCircle
    local c2 = lurek.math.newCircle(15, 0, 10)
    print("contains(5,5) = " .. tostring(c1:contains(5, 5)))
    print("intersects = " .. tostring(c1:intersects(c2)))
    local minx, miny, maxx, maxy = c1:aabb()
    print("aabb = " .. minx .. "," .. miny .. " " .. maxx .. "," .. maxy)
end

--@api-stub: lurek.math.fromHex
-- Converts a hex color string to RGBA channels.
do
    local r, g, b, a = lurek.math.fromHex("#FF8800FF")
    print("fromHex = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: lurek.math.hslToRgb / rgbToHsl
-- HSL ↔ RGB conversion.
do
    local r, g, b, a = lurek.math.hslToRgb(0.0, 1.0, 0.5)
    print("hsl(0,1,0.5) = " .. r .. "," .. g .. "," .. b .. "," .. a)
    local h, s, l = lurek.math.rgbToHsl(1.0, 0.0, 0.0)
    print("red → hsl = " .. h .. "," .. s .. "," .. l)
end

--@api-stub: lurek.math.gammaToLinear / linearToGamma
-- Gamma ↔ linear color space conversion.
do
    local lin = lurek.math.gammaToLinear(0.5)
    local gam = lurek.math.linearToGamma(lin)
    print("gamma→linear→gamma = " .. gam)
end

--@api-stub: lurek.math.applyEasing
-- Applies a named easing function.
do
    local v1 = lurek.math.applyEasing("linear", 0.5)
    local v2 = lurek.math.applyEasing("inOutCubic", 0.5)
    local v3 = lurek.math.applyEasing("outBounce", 0.8)
    print("linear=" .. v1 .. " inOutCubic=" .. v2 .. " outBounce=" .. v3)
end

--@api-stub: lurek.math.inBack / outBack / inOutBack (individual easings)
-- Direct easing function calls.
do
    local a = lurek.math.inBack(0.5)
    local b = lurek.math.outBack(0.5)
    local c = lurek.math.inOutBack(0.5)
    print("inBack=" .. a .. " outBack=" .. b .. " inOutBack=" .. c)
end

--@api-stub: lurek.math.inBounce / outBounce / inOutBounce
-- Bounce easing functions.
do
    local a = lurek.math.inBounce(0.7)
    local b = lurek.math.outBounce(0.7)
    local c = lurek.math.inOutBounce(0.7)
    print("inBounce=" .. a .. " outBounce=" .. b .. " inOutBounce=" .. c)
end

print("math_05.lua")
