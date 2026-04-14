-- Lurek2D Lua BDD tests for lurek.entity queryNot
-- Headless: no GPU, no audio, no window.

-- @description Covers suite: lurek.entity queryNot.
describe("lurek.entity", function()
    -- @description Covers suite: queryNot component exclusion.
    describe("queryNot", function()
        -- @covers lurek.entity.newUniverse
        -- @covers lurek.entity.queryNot
        -- @description Verifies that queryNot returns entities with all 'with' and none of the 'without' components.
        it("returns entities that have required and NOT excluded components", function()
            local w = lurek.entity.newUniverse()
            local e1 = w:spawn()
            local e2 = w:spawn()
            local e3 = w:spawn()
            w:set(e1, "Health", {hp = 100})
            w:set(e1, "Visible", true)
            w:set(e2, "Health", {hp = 50})
            -- e3 has no components
            -- queryNot: has Health, does NOT have Visible
            local res = w:queryNot({"Health"}, {"Visible"})
            expect_equal(1, #res)
            expect_equal(e2, res[1])
        end)

        -- @covers lurek.entity.queryNot
        -- @description Verifies that an empty without-list behaves like a normal query.
        it("empty without-list behaves like query", function()
            local w = lurek.entity.newUniverse()
            local e1 = w:spawn()
            local e2 = w:spawn()
            w:set(e1, "Speed", 5)
            w:set(e2, "Speed", 10)
            local res = w:queryNot({"Speed"}, {})
            expect_equal(2, #res)
        end)

        -- @covers lurek.entity.queryNot
        -- @description Verifies that an empty with-list returns all entities not having the excluded component.
        it("empty with-list returns all entities without excluded component", function()
            local w = lurek.entity.newUniverse()
            local e1 = w:spawn()
            local e2 = w:spawn()
            local e3 = w:spawn()
            w:set(e1, "Invisible", true)
            -- e2, e3 have no Invisible component
            local res = w:queryNot({}, {"Invisible"})
            -- e2 and e3 should appear
            expect_equal(2, #res)
        end)

        -- @covers lurek.entity.queryNot
        -- @description Verifies that entities with all excluded components are excluded even if multi-excludes.
        it("excludes entities with any of the excluded components", function()
            local w = lurek.entity.newUniverse()
            local e1 = w:spawn()
            local e2 = w:spawn()
            local e3 = w:spawn()
            w:set(e1, "Health", 10)
            w:set(e2, "Health", 10)
            w:set(e2, "Dead", true)
            w:set(e3, "Health", 10)
            w:set(e3, "Frozen", true)
            local res = w:queryNot({"Health"}, {"Dead", "Frozen"})
            expect_equal(1, #res)
            expect_equal(e1, res[1])
        end)
    end)
end)
test_summary()
