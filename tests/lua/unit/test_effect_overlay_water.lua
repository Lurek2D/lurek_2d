-- test_effect_overlay_water.lua
-- Unit tests for the WaterOverlayState fields exposed through lurek.overlay / lurek.postfx.
-- Tests: setWater, setWaterTint, setCustomShader, getWater on LuaOverlay.

local describe = describe
local it       = it
local expect_equal = expect_equal
local expect_error = expect_error

-- lurek.overlay.newOverlay() -> LuaOverlay
local function make_overlay()
    local ov = lurek.overlay.newOverlay()
    assert(ov ~= nil, "newOverlay() must return non-nil")
    return ov
end

describe("LuaOverlay water overlay", function()
    it("getWater returns a table with default values", function()
        local ov = make_overlay()
        local w = ov:getWater()
        expect_equal(type(w), "table")
        expect_equal(w.enabled, false)
        expect_equal(type(w.amplitude), "number")
        expect_equal(type(w.frequency), "number")
        expect_equal(type(w.speed), "number")
    end)

    it("setWater enables the overlay and stores wave params", function()
        local ov = make_overlay()
        ov:setWater(0.05, 4.0, 2.0)
        local w = ov:getWater()
        expect_equal(w.enabled, true)
        expect_equal(w.amplitude, 0.05)
        expect_equal(w.frequency, 4.0)
        expect_equal(w.speed, 2.0)
    end)

    it("setWaterTint stores tint channels and strength", function()
        local ov = make_overlay()
        ov:setWaterTint(0.1, 0.5, 0.9, 0.7)
        local w = ov:getWater()
        expect_equal(w.tint_r, 0.1)
        expect_equal(w.tint_g, 0.5)
        expect_equal(w.tint_b, 0.9)
        expect_equal(w.tint_strength, 0.7)
    end)

    it("setCustomShader stores a shader name", function()
        local ov = make_overlay()
        ov:setCustomShader("my_wave")
        -- No public getter for custom_shader; just verify no error.
    end)

    it("setCustomShader(nil) clears the shader name", function()
        local ov = make_overlay()
        ov:setCustomShader("some_shader")
        ov:setCustomShader(nil)
        -- No error expected.
    end)

    it("setWater zero amplitude is accepted", function()
        local ov = make_overlay()
        ov:setWater(0.0, 1.0, 1.0)
        local w = ov:getWater()
        expect_equal(w.enabled, true)
        expect_equal(w.amplitude, 0.0)
    end)
end)

describe("LuaOverlay water does not affect non-water state", function()
    it("isActive() is not changed by setting water fields before enabling", function()
        local ov = make_overlay()
        -- Default water is disabled; overlay itself may or may not be active for other reasons.
        -- After setWaterTint without setWater, water.enabled stays false.
        ov:setWaterTint(1.0, 0.0, 0.0, 1.0)
        local w = ov:getWater()
        expect_equal(w.enabled, false)
    end)

    it("setWater then getWater returns consistent values on second call", function()
        local ov = make_overlay()
        ov:setWater(0.03, 2.5, 1.5)
        local w1 = ov:getWater()
        local w2 = ov:getWater()
        expect_equal(w1.amplitude, w2.amplitude)
        expect_equal(w1.frequency, w2.frequency)
        expect_equal(w1.speed, w2.speed)
    end)
end)

test_summary()
