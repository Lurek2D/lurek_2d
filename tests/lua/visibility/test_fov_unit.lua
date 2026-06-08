-- tests/lua/visibility/test_fov_unit.lua
-- Unit tests for lurek.visibility.newFov (tile-grid shadowcasting)
-- @covers lurek.visibility.newFov


local t = require("test_harness")

-- ── Helpers ──────────────────────────────────────────────────────────────────

local W, H = 20, 20

local function open_blocker(_, _) return false end

local function make_fov(range, light_walls)
    return lurek.visibility.newFov({
        width  = W,
        height = H,
        range  = range or 8,
        light_walls = (light_walls == nil) and true or light_walls,
    })
end

-- ── Tests ─────────────────────────────────────────────────────────────────────

t.test("newFov creates object", function()
    local fov = make_fov(6)
    t.assert(fov ~= nil, "newFov returned nil")
    t.assert(fov:type() == "LFov", "type() mismatch")
end)

t.test("compute makes observer cell visible", function()
    local fov = make_fov(6)
    fov:setBlocker(open_blocker)
    fov:compute(5, 5)
    t.assert(fov:isVisible(5, 5), "observer cell must be visible")
end)

t.test("isVisible false for cells behind solid wall", function()
    local fov = make_fov(8)
    -- Solid wall at column 3 blocks everything to the right of column 1 when observer is at 1,1
    fov:setBlocker(function(x, _) return x == 3 end)
    fov:compute(1, 1)
    -- Column 5 should be hidden behind wall at column 3
    local visible = fov:isVisible(5, 1)
    t.assert(not visible, "cell behind wall should not be visible")
end)

t.test("isVisible true for open cells within range", function()
    local fov = make_fov(10)
    fov:setBlocker(open_blocker)
    fov:compute(10, 10)
    t.assert(fov:isVisible(10, 12), "open cell within range should be visible")
    t.assert(fov:isVisible(7,  10), "open cell left within range should be visible")
end)

t.test("isVisible false beyond range", function()
    local fov = make_fov(3)
    fov:setBlocker(open_blocker)
    fov:compute(10, 10)
    -- (10,10) + range 3 → (10,14) should be outside range
    t.assert(not fov:isVisible(10, 14), "cell beyond range=3 should not be visible from (10,10)")
end)

t.test("isExplored persists across compute calls", function()
    local fov = make_fov(8)
    fov:setBlocker(open_blocker)
    fov:compute(5, 5)
    t.assert(fov:isExplored(5, 5), "cell visible at (5,5) must be explored")
    fov:compute(15, 15)  -- move observer to far corner
    -- (5,5) may not be visible now, but must still be explored
    t.assert(fov:isExplored(5, 5), "previously seen cell must remain explored after second compute")
end)

t.test("resetExplored clears all explored flags", function()
    local fov = make_fov(8)
    fov:setBlocker(open_blocker)
    fov:compute(5, 5)
    fov:resetExplored()
    t.assert(not fov:isExplored(5, 5), "explored must be false after resetExplored")
end)

t.test("eachVisible iterates correct number of cells", function()
    local fov = make_fov(4)
    fov:setBlocker(open_blocker)
    fov:compute(10, 10)
    local count = 0
    fov:eachVisible(function(_, _) count = count + 1 end)
    t.assert(count > 0, "eachVisible must yield at least one cell")
end)

t.test("visibleCells matches eachVisible count", function()
    local fov = make_fov(5)
    fov:setBlocker(open_blocker)
    fov:compute(10, 10)
    local cells = fov:visibleCells()
    local count = 0
    fov:eachVisible(function(_, _) count = count + 1 end)
    t.assert_eq(#cells, count, "visibleCells count must match eachVisible count")
end)

t.test("light_walls=false does not mark wall as visible", function()
    local fov = make_fov(8, false)
    fov:setBlocker(function(x, _) return x == 5 end)
    fov:compute(3, 10)
    t.assert(not fov:isVisible(5, 10), "wall cell should NOT be visible when light_walls=false")
end)

t.test("light_walls=true marks wall cell as visible", function()
    local fov = make_fov(8, true)
    fov:setBlocker(function(x, _) return x == 5 end)
    fov:compute(3, 10)
    t.assert(fov:isVisible(5, 10), "wall cell SHOULD be visible when light_walls=true")
end)

t.test("export and import round-trip", function()
    local fov = make_fov(6)
    fov:setBlocker(open_blocker)
    fov:compute(10, 10)
    local blob = fov:export()
    t.assert(type(blob) == "string" and #blob > 0, "export must return non-empty string")

    local fov2 = make_fov(6)
    fov2:import(blob)
    for y = 1, H do
        for x = 1, W do
            t.assert_eq(fov:isVisible(x, y),  fov2:isVisible(x, y),
                string.format("visible mismatch at (%d,%d)", x, y))
            t.assert_eq(fov:isExplored(x, y), fov2:isExplored(x, y),
                string.format("explored mismatch at (%d,%d)", x, y))
        end
    end
end)

t.test("setRange changes radius before compute", function()
    local fov = make_fov(2)
    fov:setBlocker(open_blocker)
    fov:compute(10, 10)
    t.assert(not fov:isVisible(10, 13), "range=2: (10,13) should not be visible")
    fov:setRange(5)
    fov:compute(10, 10)
    t.assert(fov:isVisible(10, 13), "range=5: (10,13) should now be visible")
end)

t.test("typeOf returns correct values", function()
    local fov = make_fov(4)
    t.assert(fov:typeOf("LFov"), "typeOf LFov must be true")
    t.assert(fov:typeOf("LObject"), "typeOf LObject must be true")
    t.assert(not fov:typeOf("LNavGrid"), "typeOf LNavGrid must be false")
end)

t.finish()
test_summary()
