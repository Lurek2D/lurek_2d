-- Lurek2D Integration Test: Light + Graphics
-- Tests that light state set via the API is readable back and correct.

-- @describe integration: light placement alongside scene geometry
describe("integration: light placement alongside scene geometry", function()
    -- @covers LLight:getColor
    -- @covers LLight:setColor
    -- @covers lurek.light.newLight
    it("setColor persists and getColor returns the set value", function()
        local light = lurek.light.newLight(200, 200, 150)
        light:setColor(1.0, 0.9, 0.7, 1.0)

        local r, g, b, a = light:getColor()
        expect_near(1.0, r, 0.001, "red component")
        expect_near(0.9, g, 0.001, "green component")
        expect_near(0.7, b, 0.001, "blue component")
        expect_near(1.0, a, 0.001, "alpha component")
    end)

    -- @covers LLight:getIntensity
    -- @covers LLight:setIntensity
    -- @covers lurek.light.newLight
    it("setIntensity persists and getIntensity returns the set value", function()
        local light = lurek.light.newLight(100, 100, 50)

        light:setIntensity(0.8)
        expect_near(0.8, light:getIntensity(), 0.001, "intensity 0.8 round-trips")

        light:setIntensity(0.0)
        expect_near(0.0, light:getIntensity(), 0.001, "intensity 0.0 round-trips")

        light:setIntensity(1.0)
        expect_near(1.0, light:getIntensity(), 0.001, "intensity 1.0 round-trips")
    end)

    -- @covers LLight:getIntensity
    -- @covers LLight:setIntensity
    -- @covers lurek.light.newLight
    it("multiple lights track independent intensity values", function()
        local lights = {}
        for i = 1, 3 do
            local l = lurek.light.newLight(i * 100, i * 100, i * 30)
            local intensity = i * 0.25
            l:setIntensity(intensity)
            lights[i] = { light = l, expected = intensity }
        end

        for i, entry in ipairs(lights) do
            expect_near(entry.expected, entry.light:getIntensity(), 0.001,
                "light " .. i .. " intensity = " .. entry.expected)
        end
    end)

    -- @covers LLight:getColor
    -- @covers LLight:setColor
    -- @covers lurek.light.newLight
    it("overwriting color returns only the latest value", function()
        local light = lurek.light.newLight(100, 100, 50)

        light:setColor(0.0, 0.0, 0.0, 1.0)
        light:setColor(1.0, 1.0, 1.0, 1.0)
        light:setColor(1.0, 0.0, 0.0, 0.5)

        local r, g, b, a = light:getColor()
        expect_near(1.0, r, 0.001, "r = 1.0 after last setColor")
        expect_near(0.0, g, 0.001, "g = 0.0 after last setColor")
        expect_near(0.0, b, 0.001, "b = 0.0 after last setColor")
        expect_near(0.5, a, 0.001, "a = 0.5 after last setColor")
    end)
end)
test_summary()
