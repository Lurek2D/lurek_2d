-- Lurek2D Lua BDD tests for lurek.scene transition type enumeration
-- Headless: no GPU, no audio, no window.

-- @description Covers suite: lurek.scene extended transition types.
describe("lurek.scene", function()
    -- @description Covers suite: getTransitionTypes.
    describe("getTransitionTypes", function()
        -- @covers lurek.scene.getTransitionTypes
        -- @description Verifies that getTransitionTypes returns exactly 10 entries.
        it("returns exactly 10 transition type strings", function()
            local types = lurek.scene.getTransitionTypes()
            expect_equal(10, #types)
        end)

        -- @covers lurek.scene.getTransitionTypes
        -- @description Verifies that all expected basic types are present.
        it("contains none, fade, left, right, up, down", function()
            local types = lurek.scene.getTransitionTypes()
            local lookup = {}
            for _, v in ipairs(types) do lookup[v] = true end
            expect_equal(true, lookup["none"])
            expect_equal(true, lookup["fade"])
            expect_equal(true, lookup["left"])
            expect_equal(true, lookup["right"])
            expect_equal(true, lookup["up"])
            expect_equal(true, lookup["down"])
        end)

        -- @covers lurek.scene.getTransitionTypes
        -- @description Verifies that extended types wipe, iris, zoom, crossfade are present.
        it("contains extended types wipe, iris, zoom, crossfade", function()
            local types = lurek.scene.getTransitionTypes()
            local lookup = {}
            for _, v in ipairs(types) do lookup[v] = true end
            expect_equal(true, lookup["wipe"])
            expect_equal(true, lookup["iris"])
            expect_equal(true, lookup["zoom"])
            expect_equal(true, lookup["crossfade"])
        end)

        -- @covers lurek.scene.getTransitionTypes
        -- @description Verifies that all entries are strings.
        it("all entries are strings", function()
            local types = lurek.scene.getTransitionTypes()
            for _, v in ipairs(types) do
                expect_equal("string", type(v))
            end
        end)
    end)
end)
test_summary()
