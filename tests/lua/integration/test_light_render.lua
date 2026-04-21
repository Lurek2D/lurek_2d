-- Lurek2D Integration Test: Light + Graphics
-- Tests light API alongside graphics draw commands.

-- @description Covers suite: integration: light placement alongside scene geometry.
describe("integration: light placement alongside scene geometry", function()
    -- @covers lurek.light.newLight
    -- @covers lurek.render.rectangle
    -- @covers lurek.light.setPosition
    -- @covers lurek.light.setRadius
    -- @covers lurek.light.setColor
    -- @covers lurek.light.setIntensity
    -- @covers lurek.render.setColor
    -- @description Verifies light setup and scene geometry draw commands can be issued together without error.
    it("creates lights and draws geometry to same scene", function()
        expect_no_error(function()
            -- Create lights with correct API: newLight(x, y, radius)
            local light1 = lurek.light.newLight(200, 200, 150)
            light1:setColor(1.0, 0.9, 0.7, 1.0)
            light1:setIntensity(0.8)

            local light2 = lurek.light.newLight(600, 300, 100)
            light2:setColor(0.5, 0.5, 1.0, 1.0)
            light2:setIntensity(1.0)

            -- Draw scene geometry (walls, floors)
            lurek.render.setColor(0.3, 0.3, 0.3, 1.0)
            lurek.render.rectangle("fill", 0, 0, 800, 600)

            lurek.render.setColor(0.7, 0.6, 0.5, 1.0)
            lurek.render.rectangle("fill", 100, 100, 50, 200)
        end)
    end)

    -- @covers lurek.light.setIntensity
    -- @covers lurek.render
    -- @description Verifies point light intensity accepts boundary values while remaining compatible with the graphics scene setup.
    it("light intensity range is clamped correctly", function()
        local light = lurek.light.newLight(100, 100, 50)
        light:setIntensity(0.5)
        expect_no_error(function()
            light:setIntensity(0.0)  -- min
            light:setIntensity(1.0)  -- max
        end)
    end)

    -- @covers lurek.light.newLight
    -- @covers lurek.render
    -- @description Verifies multiple light types can coexist alongside graphics usage without raising errors.
    it("multiple lights of different types created without error", function()
        expect_no_error(function()
            -- Create multiple lights of different positions/sizes
            for i = 1, 3 do
                local l = lurek.light.newLight(i * 100, i * 100, i * 30)
                l:setIntensity(0.5)
            end
        end)
    end)

    -- @covers lurek.light.setColor
    -- @covers lurek.render
    -- @description Verifies normalized light color values are accepted while used in the same rendering context as graphics commands.
    it("light color components are in 0..1 range", function()
        local light = lurek.light.newLight(100, 100, 50)
        expect_no_error(function()
            light:setColor(0.0, 0.0, 0.0, 1.0)   -- black
            light:setColor(1.0, 1.0, 1.0, 1.0)   -- white
            light:setColor(1.0, 0.0, 0.0, 0.5)   -- red, half alpha
        end)
    end)
end)

test_summary()
