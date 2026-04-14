-- Lurek2D Lua BDD tests for lurek.entity system priority ordering
-- Headless: no GPU, no audio, no window.

-- @description Covers suite: lurek.entity system priority dispatch ordering.
describe("lurek.entity", function()
    -- @description Covers suite: addSystem with priority.
    describe("system priority", function()
        -- @covers lurek.entity.newUniverse
        -- @covers lurek.entity.addSystem
        -- @covers lurek.entity.update
        -- @description Verifies that systems are called in ascending priority order.
        it("systems dispatch in ascending priority order", function()
            local w = lurek.entity.newUniverse()
            local order = {}
            local sys_a = {
                update = function(self, world, dt)
                    table.insert(order, "A")
                end
            }
            local sys_b = {
                update = function(self, world, dt)
                    table.insert(order, "B")
                end
            }
            local sys_c = {
                update = function(self, world, dt)
                    table.insert(order, "C")
                end
            }
            -- Add in reverse order; lower priority = runs first
            w:addSystem(sys_c, {priority = 30})
            w:addSystem(sys_a, {priority = 10})
            w:addSystem(sys_b, {priority = 20})
            w:update(0.016)
            expect_equal("A", order[1])
            expect_equal("B", order[2])
            expect_equal("C", order[3])
        end)

        -- @covers lurek.entity.addSystem
        -- @description Verifies that systems without explicit priority default to 0.
        it("systems default to priority 0 when not specified", function()
            local w = lurek.entity.newUniverse()
            local order = {}
            local sys_default = { update = function() table.insert(order, "default") end }
            local sys_negative = { update = function() table.insert(order, "early") end }
            w:addSystem(sys_default)            -- priority 0
            w:addSystem(sys_negative, {priority = -1})  -- runs before
            w:update(0)
            expect_equal("early", order[1])
            expect_equal("default", order[2])
        end)

        -- @covers lurek.entity.getSystemCount
        -- @description Verifies that addSystem with priority correctly increments system count.
        it("getSystemCount increments correctly with priority", function()
            local w = lurek.entity.newUniverse()
            expect_equal(0, w:getSystemCount())
            local s1 = { update = function() end }
            local s2 = { update = function() end }
            w:addSystem(s1, {priority = 5})
            w:addSystem(s2, {priority = 1})
            expect_equal(2, w:getSystemCount())
        end)
    end)
end)
test_summary()
