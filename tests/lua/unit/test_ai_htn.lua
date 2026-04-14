-- Lurek2D AI — HTN Planner tests

-- =========================================================================
-- 1. Factory
-- =========================================================================
-- @description Verifies the HTNDomain factory and basic API.
describe("lurek.ai.newHTNDomain factory", function()
    -- @covers lurek.ai.newHTNDomain
    it("exists as a function", function()
        expect_type("function", lurek.ai.newHTNDomain)
    end)

    -- @covers lurek.ai.newHTNDomain
    it("creates a userdata object", function()
        local d = lurek.ai.newHTNDomain()
        expect_type("userdata", d)
    end)

    -- @covers lurek.ai.newHTNDomain
    it("starts with zero tasks", function()
        local d = lurek.ai.newHTNDomain()
        expect_equal(d:taskCount(), 0)
    end)
end)

-- =========================================================================
-- 2. Primitives
-- =========================================================================
-- @description Verifies that primitive tasks can be added.
describe("HTNDomain addPrimitive", function()
    -- @covers lurek.ai.newHTNDomain
    it("addPrimitive increments task count", function()
        local d = lurek.ai.newHTNDomain()
        d:addPrimitive("MoveTo", {}, {"at_target"}, {})
        expect_equal(d:taskCount(), 1)
    end)

    -- @covers lurek.ai.newHTNDomain
    it("addPrimitive with preconditions is counted", function()
        local d = lurek.ai.newHTNDomain()
        d:addPrimitive("Attack", {"has_weapon", "enemy_visible"}, {"attacked"}, {})
        expect_equal(d:taskCount(), 1)
    end)
end)

-- =========================================================================
-- 3. Planning
-- =========================================================================
-- @description Verifies that plan() returns a sequence of primitive actions.
describe("HTNDomain plan", function()
    -- @covers lurek.ai.newHTNDomain
    it("plan returns nil for unknown root task", function()
        local d = lurek.ai.newHTNDomain()
        local result = d:plan("nonexistent", {})
        expect_equal(result, nil)
    end)

    -- @covers lurek.ai.newHTNDomain
    it("plan returns a table of primitive actions for solvable problem", function()
        local d = lurek.ai.newHTNDomain()
        -- Primitives
        d:addPrimitive("Navigate", {}, {"nav_done"}, {})
        d:addPrimitive("PickUp", {"nav_done"}, {"holding_item"}, {})
        -- Compound root task
        d:addCompound("GetItem", {
            { name = "main_method", preconditions = {}, sub_tasks = {"Navigate", "PickUp"} }
        })
        local plan = d:plan("GetItem", {})
        expect_type("table", plan)
        expect_equal(#plan, 2)
        expect_equal(plan[1], "Navigate")
        expect_equal(plan[2], "PickUp")
    end)

    -- @covers lurek.ai.newHTNDomain
    it("plan returns nil when precondition not satisfied", function()
        local d = lurek.ai.newHTNDomain()
        d:addPrimitive("Attack", {"has_weapon"}, {"attacked"}, {})
        d:addCompound("DoAttack", {
            { name = "armed", preconditions = {"has_weapon"}, sub_tasks = {"Attack"} }
        })
        -- State does not include has_weapon
        local plan = d:plan("DoAttack", {})
        expect_equal(plan, nil)
    end)
end)

-- Print summary
test_summary()
