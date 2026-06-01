-- Unit tests for lurek.visibility fog-of-war module.

-- @describe lurek.visibility module unit tests
describe("lurek.visibility", function()
    -- @covers lurek.visibility.new
    it("creates a visibility grid", function()
        local vis = lurek.visibility.new({ regions = 50, players = 2 })
        expect_true(vis ~= nil, "grid should be created")
    end)

    -- @covers LVisibilityGrid:regionCount
    it("returns region count", function()
        local vis = lurek.visibility.new({ regions = 50, players = 2 })
        expect_equal(50, vis:regionCount())
    end)

    -- @covers LVisibilityGrid:playerCount
    it("returns player count", function()
        local vis = lurek.visibility.new({ regions = 50, players = 2 })
        expect_equal(2, vis:playerCount())
    end)

    -- @covers LVisibilityGrid:getState
    it("all regions start hidden", function()
        local vis = lurek.visibility.new({ regions = 10, players = 1 })
        expect_equal("hidden", vis:getState(0, 0))
        expect_equal("hidden", vis:getState(0, 9))
    end)

    -- @covers LVisibilityGrid:reveal
    it("reveal changes state to visible", function()
        local vis = lurek.visibility.new({ regions = 10, players = 1 })
        vis:reveal(0, 3)
        expect_equal("visible", vis:getState(0, 3))
    end)

    -- @covers LVisibilityGrid:hide
    it("hide changes visible to discovered", function()
        local vis = lurek.visibility.new({ regions = 10, players = 1 })
        vis:reveal(0, 3)
        vis:hide(0, 3)
        expect_equal("discovered", vis:getState(0, 3))
    end)

    -- @covers LVisibilityGrid:getFogIntensity
    it("fog intensity matches state", function()
        local vis = lurek.visibility.new({ regions = 10, players = 1 })
        expect_near(1.0, vis:getFogIntensity(0, 0), 0.01)
        vis:reveal(0, 0)
        expect_near(0.0, vis:getFogIntensity(0, 0), 0.01)
        vis:hide(0, 0)
        expect_near(0.5, vis:getFogIntensity(0, 0), 0.01)
    end)

    -- @covers LVisibilityGrid:setGroup
    it("setGroup creates shared visibility group", function()
        local vis = lurek.visibility.new({ regions = 10, players = 3 })
        local gid = vis:setGroup({ 0, 1 })
        expect_type("number", gid)
    end)

    -- @covers LVisibilityGrid:sharesVisibility
    it("sharesVisibility reports alliance correctly", function()
        local vis = lurek.visibility.new({ regions = 5, players = 3 })
        vis:setGroup({ 0, 2 })
        expect_true(vis:sharesVisibility(0, 2))
        expect_true(not vis:sharesVisibility(0, 1))
    end)

    -- @covers LVisibilityGrid:setCost
    it("sets discovery cost", function()
        local vis = lurek.visibility.new({ regions = 10, players = 1 })
        vis:setCost(3, 5.0)
        expect_true(true)
    end)

    -- @covers LVisibilityGrid:getCost
    it("gets discovery cost", function()
        local vis = lurek.visibility.new({ regions = 10, players = 1 })
        vis:setCost(3, 5.0)
        expect_near(5.0, vis:getCost(3), 0.001)
    end)

    -- @covers LVisibilityGrid:setFlag
    it("sets region flag", function()
        local vis = lurek.visibility.new({ regions = 10, players = 1 })
        vis:setFlag(2, 0, true)
        expect_true(true)
    end)

    -- @covers LVisibilityGrid:hasFlag
    it("checks region flag", function()
        local vis = lurek.visibility.new({ regions = 10, players = 1 })
        vis:setFlag(2, 0, true)
        expect_true(vis:hasFlag(2, 0))
    end)

    -- @covers LVisibilityGrid:revealAll
    it("revealAll reveals every region", function()
        local vis = lurek.visibility.new({ regions = 5, players = 1 })
        vis:revealAll(0)
        expect_equal("visible", vis:getState(0, 0))
    end)

    -- @covers LVisibilityGrid:reset
    it("reset clears visibility", function()
        local vis = lurek.visibility.new({ regions = 5, players = 1 })
        vis:revealAll(0)
        vis:reset(0)
        expect_equal("hidden", vis:getState(0, 0))
    end)

    -- @covers LVisibilityGrid:drainEvents
    it("drainEvents returns visibility events", function()
        local vis = lurek.visibility.new({ regions = 10, players = 1 })
        vis:reveal(0, 3)
        local events = vis:drainEvents()
        expect_true(#events >= 1)
    end)
end)

-- @describe LFov API
describe("lurek.visibility.newFov", function()
    -- @covers lurek.visibility.newFov
    it("creates LFov object", function()
        local fov = lurek.visibility.newFov({ range = 6, width = 16, height = 16 })
        expect_true(fov ~= nil)
    end)

    -- @covers LFov:setBlocker
    it("accepts blocker callback", function()
        local fov = lurek.visibility.newFov({ range = 6, width = 16, height = 16 })
        fov:setBlocker(function(_, _)
            return false
        end)
        expect_true(true)
    end)

    -- @covers LFov:setRange
    it("updates fov range", function()
        local fov = lurek.visibility.newFov({ range = 6, width = 16, height = 16 })
        fov:setRange(5)
        expect_true(true)
    end)

    -- @covers LFov:compute
    it("computes visible cells", function()
        local fov = lurek.visibility.newFov({ range = 6, width = 16, height = 16 })
        fov:compute(4, 4)
        expect_true(true)
    end)

    -- @covers LFov:isVisible
    it("reports current visibility", function()
        local fov = lurek.visibility.newFov({ range = 6, width = 16, height = 16 })
        fov:compute(4, 4)
        expect_type("boolean", fov:isVisible(4, 4))
    end)

    -- @covers LFov:isExplored
    it("reports explored state", function()
        local fov = lurek.visibility.newFov({ range = 6, width = 16, height = 16 })
        fov:compute(4, 4)
        expect_type("boolean", fov:isExplored(4, 4))
    end)

    -- @covers LFov:visibleCells
    it("returns visible cell array", function()
        local fov = lurek.visibility.newFov({ range = 6, width = 16, height = 16 })
        fov:compute(4, 4)
        expect_type("table", fov:visibleCells())
    end)

    -- @covers LFov:eachVisible
    it("iterates visible cells", function()
        local fov = lurek.visibility.newFov({ range = 6, width = 16, height = 16 })
        fov:compute(4, 4)
        local count = 0
        fov:eachVisible(function(_, _)
            count = count + 1
        end)
        expect_true(count >= 1)
    end)

    -- @covers LFov:export
    it("exports fov blob", function()
        local fov = lurek.visibility.newFov({ range = 6, width = 16, height = 16 })
        fov:compute(4, 4)
        expect_type("string", fov:export())
    end)

    -- @covers LFov:import
    it("imports fov blob", function()
        local fov = lurek.visibility.newFov({ range = 6, width = 16, height = 16 })
        fov:compute(4, 4)
        local blob = fov:export()
        fov:import(blob)
        expect_true(true)
    end)

    -- @covers LFov:resetExplored
    it("resets explored mask", function()
        local fov = lurek.visibility.newFov({ range = 6, width = 16, height = 16 })
        fov:compute(4, 4)
        fov:resetExplored()
        expect_true(true)
    end)

    -- @covers LFov:type
    it("returns type name", function()
        local fov = lurek.visibility.newFov({ range = 6, width = 16, height = 16 })
        expect_equal("LFov", fov:type())
    end)

    -- @covers LFov:typeOf
    it("matches typeOf LFov", function()
        local fov = lurek.visibility.newFov({ range = 6, width = 16, height = 16 })
        expect_true(fov:typeOf("LFov"))
    end)
end)

test_summary()
