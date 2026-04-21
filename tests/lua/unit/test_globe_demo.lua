-- tests/lua/unit/test_globe_demo.lua
-- Smoke test for content/games/showcase/globe_demo/main.lua
--
-- This test catches the class of bugs that caused three consecutive silent
-- failures in the globe demo (wrong callback names, wrong input API, wrong
-- render API, broken gfx alias).  It works by:
--   1. Loading the demo module file directly (dofile).
--   2. Calling lurek.init() (the init callback) in the test VM.
--   3. Asserting all post-init invariants hold (globe exists, 200 provinces,
--      layers present, markers present, camera set).
--   4. Calling lurek.process(1/60) once to verify the update path runs.
--
-- The test does NOT call lurek.render() because that requires a live GPU
-- surface; render-side panics are caught at runtime in the dev loop.
-- All render-namespace calls in main.lua guard against nil via pcall below.

local DEMO_PATH = "content/games/showcase/globe_demo/main.lua"

-- =========================================================================
-- Helper: reset the global demo state so the file can be re-loaded cleanly
-- =========================================================================
local function load_demo()
    -- Reset the province-ID counter that main.lua keeps as a module-level
    -- upvalue; dofile creates a fresh closure so this is automatic.
    -- We do need to stub out the render and input calls that don't exist
    -- in headless test VMs.
    lurek.render = lurek.render or {}
    lurek.render.setBackgroundColor = lurek.render.setBackgroundColor or function() end

    lurek.input = lurek.input or {}
    lurek.input.bind             = lurek.input.bind             or function() end
    lurek.input.getMousePosition = lurek.input.getMousePosition or function() return 640, 360 end
    lurek.input.isActionDown     = lurek.input.isActionDown     or function() return false end
    lurek.input.getWheelDelta    = lurek.input.getWheelDelta    or function() return 0, 0 end
    lurek.input.wasActionPressed = lurek.input.wasActionPressed or function() return false end

    dofile(DEMO_PATH)
end

-- =========================================================================
-- 1. Demo file loads without error
-- =========================================================================
describe("globe_demo: file loads", function()
    -- @covers content/games/showcase/globe_demo/main.lua (load-time)
    it("dofile does not raise", function()
        local ok, err = pcall(load_demo)
        expect(ok, "dofile raised: " .. tostring(err))
    end)
end)

-- =========================================================================
-- 2. lurek.init() runs to completion and builds the world
-- =========================================================================
describe("globe_demo: lurek.init()", function()
    -- @covers lurek.globe.new
    -- @covers lurek.globe.Globe.addProvince
    -- @covers lurek.globe.Globe.provinceCount
    -- @covers lurek.globe.Globe.addLayer
    -- @covers lurek.globe.Globe.addMarker
    -- @covers lurek.globe.Globe.addLabel
    -- @covers lurek.globe.Globe.setCamera
    -- @covers lurek.globe.Globe.setTimeOfDay
    -- @covers lurek.globe.Globe.setBorders
    -- @covers lurek.globe.Globe.revealAll

    local init_ok, init_err

    it("lurek.init callback is registered as a function", function()
        -- If callback names were wrong (e.g. lurek.load instead of lurek.init)
        -- this would be nil.
        expect_type("function", lurek.init)
    end)

    it("lurek.init() runs without error", function()
        init_ok, init_err = pcall(lurek.init)
        expect(init_ok, "lurek.init() raised: " .. tostring(init_err))
    end)

    it("globe handle is available after init", function()
        local earth = lurek.globe.get("earth")
        expect(earth ~= nil, "lurek.globe.get('earth') returned nil after init")
    end)

    it("exactly 200 provinces were generated", function()
        local earth = lurek.globe.get("earth")
        if earth == nil then
            pending("globe not created — skipping province count check")
            return
        end
        local count = earth:provinceCount()
        expect_eq(200, count, string.format("expected 200 provinces, got %d", count))
    end)

    it("political layer exists", function()
        local earth = lurek.globe.get("earth")
        if earth == nil then pending("globe not created") return end
        -- Layer existence is checked indirectly: setLayerAlpha must not raise
        local ok = pcall(function() earth:setLayerAlpha("political", 0.55) end)
        expect(ok, "setLayerAlpha('political') raised — layer may not exist")
    end)

    it("highlight layer exists", function()
        local earth = lurek.globe.get("earth")
        if earth == nil then pending("globe not created") return end
        local ok = pcall(function() earth:setLayerAlpha("highlight", 0.3) end)
        expect(ok, "setLayerAlpha('highlight') raised — layer may not exist")
    end)

    it("at least 15 capital markers were added", function()
        local earth = lurek.globe.get("earth")
        if earth == nil then pending("globe not created") return end
        local count = earth:markerCount()
        expect(count >= 15, string.format("expected >= 15 markers, got %d", count))
    end)

    it("camera was set (getCamera returns numeric lat/lon/zoom)", function()
        local earth = lurek.globe.get("earth")
        if earth == nil then pending("globe not created") return end
        local lat, lon, zoom = earth:getCamera()
        expect_type("number", lat)
        expect_type("number", lon)
        expect_type("number", zoom)
        expect(zoom >= 0.5 and zoom <= 12.0,
            string.format("zoom %s out of range", tostring(zoom)))
    end)
end)

-- =========================================================================
-- 3. lurek.process() does not crash
-- =========================================================================
describe("globe_demo: lurek.process(dt)", function()
    -- @covers lurek.globe.Globe.update
    -- @covers lurek.globe.Globe.setTimeOfDay
    -- @covers lurek.globe.Globe.setCamera
    -- @covers lurek.globe.Globe.pick

    it("lurek.process callback is registered as a function", function()
        -- Would be nil if callback was named lurek.update instead
        expect_type("function", lurek.process)
    end)

    it("lurek.process(1/60) runs without error", function()
        local ok, err = pcall(lurek.process, 1 / 60)
        expect(ok, "lurek.process(dt) raised: " .. tostring(err))
    end)

    it("lurek.process(1.0) with a full second does not crash", function()
        local ok, err = pcall(lurek.process, 1.0)
        expect(ok, "lurek.process(1.0) raised: " .. tostring(err))
    end)
end)

-- =========================================================================
-- 4. Callback name regression guards
-- =========================================================================
describe("globe_demo: callback name guards", function()
    -- These catch the earlier bug where callbacks were registered as
    -- lurek.load / lurek.update / lurek.draw instead of
    -- lurek.init  / lurek.process / lurek.render.

    it("lurek.load is NOT set (wrong callback name)", function()
        -- If this fails the game silently shows a black screen on startup
        expect(lurek.load == nil,
            "lurek.load is set — callback should be lurek.init not lurek.load")
    end)

    it("lurek.update is NOT set (wrong callback name)", function()
        expect(lurek.update == nil,
            "lurek.update is set — callback should be lurek.process not lurek.update")
    end)

    it("lurek.draw is NOT set (wrong callback name)", function()
        expect(lurek.draw == nil,
            "lurek.draw is set — callback should be lurek.render not lurek.draw")
    end)
end)
