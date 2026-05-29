-- tests/lua/pathfind/test_goal_map_unit.lua
-- Unit tests for lurek.pathfind.newGoalMap

local t = require("test_harness")

-- ── Helpers ──────────────────────────────────────────────────────────────────

local function open_blocker(_, _) return false end

local function wall_blocker(gm, wall_x, wall_y)
    local w = gm.width or 10
    return function(x, y) return x == wall_x and y == wall_y end
end

local function make_gm(w, h, src_x, src_y)
    local gm = lurek.pathfind.newGoalMap(w, h)
    gm:addSource(src_x, src_y)
    gm:setBlocker(open_blocker)
    gm:bake()
    return gm
end

-- ── Tests ─────────────────────────────────────────────────────────────────────

t.test("newGoalMap creates object", function()
    local gm = lurek.pathfind.newGoalMap(10, 8)
    t.assert(gm ~= nil, "newGoalMap returned nil")
    t.assert(gm:type() == "LGoalMap", "type() mismatch")
end)

t.test("addSource + bake + distanceAt = 0 at source", function()
    local gm = make_gm(10, 10, 5, 5)
    t.assert_eq(gm:distanceAt(5, 5), 0, "source cell distance must be 0")
end)

t.test("distanceAt returns correct BFS distance", function()
    local gm = make_gm(10, 10, 1, 1)
    -- Manhattan distance from (1,1) to (1,3) = 2
    t.assert_eq(gm:distanceAt(1, 3), 2, "BFS distance mismatch")
    t.assert_eq(gm:distanceAt(4, 1), 3, "BFS distance mismatch (horizontal)")
end)

t.test("distanceAt returns UNREACHABLE when fully walled in", function()
    local gm = lurek.pathfind.newGoalMap(5, 5)
    gm:addSource(1, 1)
    gm:setBlocker(function(x, y)
        -- Block all cells except source
        return not (x == 1 and y == 1)
    end)
    gm:bake()
    local d = gm:distanceAt(3, 3)
    t.assert(d == math.maxinteger or d == 0xFFFFFFFF or d > 1000,
        "blocked cell should be unreachable, got " .. tostring(d))
end)

t.test("gradientAt points toward source", function()
    local gm = make_gm(10, 10, 5, 5)
    local dx, dy = gm:gradientAt(7, 5)
    t.assert(dx < 0, "gradient dx should point left toward (5,5) from (7,5)")
    local _, dy2 = gm:gradientAt(5, 7)
    t.assert(dy2 < 0, "gradient dy should point up toward (5,5) from (5,7)")
end)

t.test("flee returns inverted gradient", function()
    local gm = make_gm(10, 10, 5, 5)
    local gx, gy = gm:gradientAt(3, 5)
    local fx, fy = gm:flee(3, 5, 1.0)
    t.assert(math.abs(fx + gx) < 0.01, "flee dx should be -gradient dx")
    t.assert(math.abs(fy + gy) < 0.01, "flee dy should be -gradient dy")
end)

t.test("clearSources removes all sources", function()
    local gm = lurek.pathfind.newGoalMap(10, 10)
    gm:addSource(5, 5)
    gm:clearSources()
    gm:setBlocker(open_blocker)
    gm:bake()
    local d = gm:distanceAt(5, 5)
    t.assert(d ~= 0, "after clearSources, no cell should have distance 0")
end)

t.test("setSources replaces sources", function()
    local gm = lurek.pathfind.newGoalMap(10, 10)
    gm:addSource(1, 1)
    gm:setSources({ { x = 9, y = 9 } })
    gm:setBlocker(open_blocker)
    gm:bake()
    t.assert_eq(gm:distanceAt(9, 9), 0, "setSources: new source must be at dist 0")
    t.assert(gm:distanceAt(1, 1) > 0, "setSources: old source must not be dist 0")
end)

t.test("setBlocker is respected during bake", function()
    local gm = lurek.pathfind.newGoalMap(5, 5)
    gm:addSource(1, 1)
    gm:setBlocker(function(x, y)
        return x == 2  -- block column 2, splitting the grid
    end)
    gm:bake()
    local d = gm:distanceAt(3, 1)
    t.assert(d > 1000 or d == 0xFFFFFFFF or d == math.maxinteger,
        "cell behind wall should be unreachable, got " .. tostring(d))
end)

t.test("floodFill returns correct cells within threshold", function()
    local gm = make_gm(5, 5, 3, 3)
    local cells = gm:floodFill(3, 3, 1)
    -- Only cells at distance <= 1: (3,3), (2,3), (4,3), (3,2), (3,4)
    t.assert(#cells >= 4 and #cells <= 5, "floodFill threshold=1 should return 4-5 cells, got " .. #cells)
end)

t.test("bake is idempotent", function()
    local gm = make_gm(10, 10, 1, 1)
    local d1 = gm:distanceAt(5, 5)
    gm:bake()
    local d2 = gm:distanceAt(5, 5)
    t.assert_eq(d1, d2, "bake must be idempotent")
end)

t.test("isReady false before bake, true after", function()
    local gm = lurek.pathfind.newGoalMap(5, 5)
    gm:addSource(1, 1)
    t.assert(not gm:isReady(), "should be dirty before bake")
    gm:setBlocker(open_blocker)
    gm:bake()
    t.assert(gm:isReady(), "should be ready after bake")
end)

t.test("save and restore round-trip", function()
    local gm = make_gm(8, 8, 4, 4)
    local blob = gm:save()
    t.assert(type(blob) == "string" and #blob > 0, "save must return non-empty string")

    local gm2 = lurek.pathfind.newGoalMap(8, 8)
    gm2:restore(blob)
    for y = 1, 8 do
        for x = 1, 8 do
            t.assert_eq(gm:distanceAt(x, y), gm2:distanceAt(x, y),
                string.format("distance mismatch at (%d,%d)", x, y))
        end
    end
end)

t.test("typeOf returns true for LGoalMap and LObject", function()
    local gm = lurek.pathfind.newGoalMap(5, 5)
    t.assert(gm:typeOf("LGoalMap"), "typeOf LGoalMap")
    t.assert(gm:typeOf("LObject"), "typeOf LObject")
    t.assert(not gm:typeOf("LNavGrid"), "typeOf LNavGrid should be false")
end)

t.finish()
