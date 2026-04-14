-- Lurek2D AI — StimulusWorld perception tests

-- =========================================================================
-- 1. Factory
-- =========================================================================
-- @description Verifies the StimulusWorld factory and basic API.
describe("lurek.ai.newStimulusWorld factory", function()
    -- @covers lurek.ai.newStimulusWorld
    it("exists as a function", function()
        expect_type("function", lurek.ai.newStimulusWorld)
    end)

    -- @covers lurek.ai.newStimulusWorld
    it("creates a userdata object", function()
        local sw = lurek.ai.newStimulusWorld()
        expect_type("userdata", sw)
    end)

    -- @covers lurek.ai.newStimulusWorld
    it("starts with zero stimuli", function()
        local sw = lurek.ai.newStimulusWorld()
        expect_equal(sw:count(), 0)
    end)
end)

-- =========================================================================
-- 2. Adding stimuli
-- =========================================================================
-- @description Verifies that visual and auditory stimuli can be added and counted.
describe("StimulusWorld add stimuli", function()
    -- @covers lurek.ai.newStimulusWorld
    it("addVisual increases count", function()
        local sw = lurek.ai.newStimulusWorld()
        sw:addVisual(100, 200, 1.0, 50.0, nil)
        expect_equal(sw:count(), 1)
    end)

    -- @covers lurek.ai.newStimulusWorld
    it("addAuditory increases count", function()
        local sw = lurek.ai.newStimulusWorld()
        sw:addAuditory(50, 50, 0.8, 80.0, 0.5, "gunshot")
        expect_equal(sw:count(), 1)
    end)

    -- @covers lurek.ai.newStimulusWorld
    it("multiple stimuli counted correctly", function()
        local sw = lurek.ai.newStimulusWorld()
        sw:addVisual(0, 0, 1.0, 40.0, nil)
        sw:addVisual(10, 10, 0.5, 20.0, "guard")
        sw:addAuditory(5, 5, 0.9, 60.0, 0.3, "footstep")
        expect_equal(sw:count(), 3)
    end)
end)

-- =========================================================================
-- 3. Remove
-- =========================================================================
-- @description Verifies that stimuli can be removed by ID.
describe("StimulusWorld remove", function()
    -- @covers lurek.ai.newStimulusWorld
    it("remove decrements count", function()
        local sw = lurek.ai.newStimulusWorld()
        local id = sw:addVisual(0, 0, 1.0, 50.0, nil)
        expect_equal(sw:count(), 1)
        sw:remove(id)
        expect_equal(sw:count(), 0)
    end)

    -- @covers lurek.ai.newStimulusWorld
    it("remove returns true for valid id", function()
        local sw = lurek.ai.newStimulusWorld()
        local id = sw:addVisual(0, 0, 1.0, 50.0, nil)
        expect_equal(sw:remove(id), true)
    end)

    -- @covers lurek.ai.newStimulusWorld
    it("remove returns false for unknown id", function()
        local sw = lurek.ai.newStimulusWorld()
        expect_equal(sw:remove(99999), false)
    end)
end)

-- =========================================================================
-- 4. Update and clear
-- =========================================================================
-- @description Verifies update and clear operations.
describe("StimulusWorld update/clear", function()
    -- @covers lurek.ai.newStimulusWorld
    it("update does not crash with empty world", function()
        local sw = lurek.ai.newStimulusWorld()
        sw:update(0.016)
        expect_equal(sw:count(), 0)
    end)

    -- @covers lurek.ai.newStimulusWorld
    it("clear removes all stimuli", function()
        local sw = lurek.ai.newStimulusWorld()
        sw:addVisual(0, 0, 1.0, 50.0, nil)
        sw:addVisual(10, 10, 0.5, 30.0, nil)
        sw:clear()
        expect_equal(sw:count(), 0)
    end)
end)

-- Print summary
test_summary()
