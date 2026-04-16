-- Lurek2D Lua BDD tests — lurek.light syncAmbient and getGodRayHints
-- Covers: syncAmbient, getGodRayHints, and the ambient bridge between
--         the light module and post-processing shaders.
-- Headless: no GPU, no audio, no window.

-- @description Covers suite: lurek.light ambient bridge and god-ray hints.
describe("lurek.light ambient bridge", function()
    -- @description Covers suite: API exposure.
    describe("API exposure", function()
        -- @covers lurek.light.syncAmbient
        -- @description syncAmbient is exposed as a function.
        it("exposes syncAmbient", function()
            expect_type("function", lurek.light.syncAmbient)
        end)

        -- @covers lurek.light.getGodRayHints
        -- @description getGodRayHints is exposed as a function.
        it("exposes getGodRayHints", function()
            expect_type("function", lurek.light.getGodRayHints)
        end)
    end)

    -- @description Covers suite: syncAmbient().
    describe("syncAmbient()", function()
        -- @covers lurek.light.syncAmbient
        -- @description Returns four numbers.
        it("returns four numeric values", function()
            local r, g, b, a = lurek.light.syncAmbient()
            expect_type("number", r)
            expect_type("number", g)
            expect_type("number", b)
            expect_type("number", a)
        end)

        -- @covers lurek.light.syncAmbient
        -- @description Alpha is in [0, 1].
        it("alpha component is in [0, 1]", function()
            local _, _, _, a = lurek.light.syncAmbient()
            assert(a >= 0.0 and a <= 1.0,
                "alpha out of [0,1]: " .. tostring(a))
        end)

        -- @covers lurek.light.setAmbient
        -- @covers lurek.light.syncAmbient
        -- @description After setAmbient, syncAmbient reflects the new colour.
        it("reflects setAmbient changes", function()
            lurek.light.setAmbient(0.2, 0.4, 0.6, 0.8)
            local r, g, b, a = lurek.light.syncAmbient()
            expect_near(0.2, r, 0.001)
            expect_near(0.4, g, 0.001)
            expect_near(0.6, b, 0.001)
            expect_near(0.8, a, 0.001)
        end)

        -- @covers lurek.light.setAmbient
        -- @covers lurek.light.syncAmbient
        -- @description syncAmbient matches getAmbient.
        it("matches getAmbient values", function()
            lurek.light.setAmbient(0.1, 0.3, 0.5, 1.0)
            local r1, g1, b1, a1 = lurek.light.getAmbient()
            local r2, g2, b2, a2 = lurek.light.syncAmbient()
            expect_near(r1, r2, 0.001)
            expect_near(g1, g2, 0.001)
            expect_near(b1, b2, 0.001)
            expect_near(a1, a2, 0.001)
        end)
    end)

    -- @description Covers suite: getGodRayHints().
    describe("getGodRayHints()", function()
        -- @covers lurek.light.getGodRayHints
        -- @description Returns a table.
        it("returns a table", function()
            local hints = lurek.light.getGodRayHints()
            expect_type("table", hints)
        end)

        -- @covers lurek.light.getGodRayHints
        -- @description Returns empty table when no directional lights exist.
        it("returns empty table with no directional lights", function()
            lurek.light.clearAll()
            local hints = lurek.light.getGodRayHints()
            expect_equal(0, #hints)
        end)

        -- @covers lurek.light.newLight
        -- @covers lurek.light.getGodRayHints
        -- @description Each hint entry has x, y, and angle fields.
        it("each hint has x, y, angle fields", function()
            lurek.light.clearAll()
            local light = lurek.light.newLight("directional", 100, 200)
            light:setDirection(1.57)  -- ~pi/2
            light:setEnabled(true)
            local hints = lurek.light.getGodRayHints()
            if #hints > 0 then
                local h = hints[1]
                expect_type("number", h.x)
                expect_type("number", h.y)
                expect_type("number", h.angle)
            end
        end)

        -- @covers lurek.light.getGodRayHints
        -- @description Disabled directional lights are not included.
        it("disabled lights are excluded", function()
            lurek.light.clearAll()
            local light = lurek.light.newLight("directional", 0, 0)
            light:setEnabled(false)
            local hints = lurek.light.getGodRayHints()
            expect_equal(0, #hints)
        end)
    end)
end)

test_summary()
