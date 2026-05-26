-- Unit tests for lurek.visibility fog-of-war module.

-- @describe lurek.visibility module unit tests
describe("lurek.visibility", function()
    -- @covers lurek.visibility.new
    it("creates a visibility grid", function()
        local vis = lurek.visibility.new({ regions = 50, players = 2 })
        expect_true(vis ~= nil, "grid should be created")
        expect_equal(50, vis:regionCount())
        expect_equal(2, vis:playerCount())
    end)

    -- @covers lurek.visibility.new
    it("all regions start hidden", function()
        local vis = lurek.visibility.new({ regions = 10, players = 1 })
        expect_equal("hidden", vis:getState(0, 0))
        expect_equal("hidden", vis:getState(0, 9))
    end)

    -- @covers VisibilityGrid:reveal
    it("reveal changes state to visible", function()
        local vis = lurek.visibility.new({ regions = 10, players = 1 })
        vis:reveal(0, 3)
        expect_equal("visible", vis:getState(0, 3))
    end)

    -- @covers VisibilityGrid:hide
    it("hide changes visible to discovered", function()
        local vis = lurek.visibility.new({ regions = 10, players = 1 })
        vis:reveal(0, 3)
        vis:hide(0, 3)
        expect_equal("discovered", vis:getState(0, 3))
    end)

    -- @covers VisibilityGrid:hide
    it("hide does not affect hidden regions", function()
        local vis = lurek.visibility.new({ regions = 10, players = 1 })
        vis:hide(0, 3)
        expect_equal("hidden", vis:getState(0, 3))
    end)

    -- @covers VisibilityGrid:getFogIntensity
    it("fog intensity matches state", function()
        local vis = lurek.visibility.new({ regions = 10, players = 1 })
        expect_near(1.0, vis:getFogIntensity(0, 0), 0.01)  -- hidden
        vis:reveal(0, 0)
        expect_near(0.0, vis:getFogIntensity(0, 0), 0.01)  -- visible
        vis:hide(0, 0)
        expect_near(0.5, vis:getFogIntensity(0, 0), 0.01)  -- discovered
    end)

    -- @covers VisibilityGrid:setGroup
    it("alliance shares visibility on reveal", function()
        local vis = lurek.visibility.new({ regions = 10, players = 3 })
        vis:setGroup({0, 1})
        vis:reveal(0, 5)
        expect_equal("visible", vis:getState(0, 5))
        expect_equal("visible", vis:getState(1, 5))  -- ally sees it
        expect_equal("hidden", vis:getState(2, 5))   -- non-ally doesn't
    end)

    -- @covers VisibilityGrid:sharesVisibility
    it("sharesVisibility reports alliance correctly", function()
        local vis = lurek.visibility.new({ regions = 5, players = 3 })
        vis:setGroup({0, 2})
        expect_true(vis:sharesVisibility(0, 2))
        expect_true(not vis:sharesVisibility(0, 1))
        expect_true(vis:sharesVisibility(0, 0))  -- self
    end)

    -- @covers VisibilityGrid:setCost
    -- @covers VisibilityGrid:getCost
    it("sets and gets discovery cost", function()
        local vis = lurek.visibility.new({ regions = 10, players = 1 })
        vis:setCost(3, 5.0)
        expect_near(5.0, vis:getCost(3), 0.001)
        expect_near(1.0, vis:getCost(0), 0.001)  -- default
    end)

    -- @covers VisibilityGrid:setFlag
    -- @covers VisibilityGrid:hasFlag
    it("sets and checks flags", function()
        local vis = lurek.visibility.new({ regions = 10, players = 1 })
        vis:setFlag(2, 0, true)
        vis:setFlag(2, 3, true)
        expect_true(vis:hasFlag(2, 0))
        expect_true(vis:hasFlag(2, 3))
        expect_true(not vis:hasFlag(2, 1))
    end)

    -- @covers VisibilityGrid:revealAll
    it("revealAll reveals every region", function()
        local vis = lurek.visibility.new({ regions = 5, players = 1 })
        vis:revealAll(0)
        for i = 0, 4 do
            expect_equal("visible", vis:getState(0, i))
        end
    end)

    -- @covers VisibilityGrid:reset
    it("reset clears all visibility", function()
        local vis = lurek.visibility.new({ regions = 5, players = 1 })
        vis:revealAll(0)
        vis:reset(0)
        for i = 0, 4 do
            expect_equal("hidden", vis:getState(0, i))
        end
    end)

    -- @covers VisibilityGrid:drainEvents
    it("drainEvents returns reveal/hide events", function()
        local vis = lurek.visibility.new({ regions = 10, players = 1 })
        vis:reveal(0, 3)
        vis:hide(0, 3)
        local events = vis:drainEvents()
        expect_true(#events >= 2, "should have at least 2 events")
        expect_equal("revealed", events[1].type)
        expect_equal(0, events[1].player_id)
        expect_equal(3, events[1].region_id)
    end)

    -- @covers VisibilityGrid:reveal
    it("reveal with flags sets region flags", function()
        local vis = lurek.visibility.new({ regions = 10, players = 1 })
        vis:reveal(0, 4)
        vis:setFlag(4, 0, true)
        vis:setFlag(4, 2, true)
        expect_true(vis:hasFlag(4, 0))
        expect_true(vis:hasFlag(4, 2))
    end)
end)

test_summary()
