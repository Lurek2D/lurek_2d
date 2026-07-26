-- Security coverage for hostile status lifecycle inputs.

local NAN = 0 / 0

-- @describe security: status tracker mutation validation
describe("security: status tracker mutation validation", function()
    -- @security LStatusTracker:setRemaining
    it("rejects invalid remaining times without changing the instance", function()
        local tracker = lurek.progression.newStatusTracker()
        tracker:define({ id = "finite", duration = 4, tags = { "safe" } })
        local instance_id = tracker:apply(1, "finite")
        expect_error(function() tracker:setRemaining(instance_id, -1) end)
        expect_error(function() tracker:setRemaining(instance_id, NAN) end)
        expect_equal(4, tracker:get(instance_id).remaining)
    end)

    -- @security LStatusTracker:restore
    it("rejects malformed snapshot tags before replacing tracker state", function()
        local tracker = lurek.progression.newStatusTracker()
        tracker:define({ id = "kept", tags = { "safe" } })
        tracker:apply(1, "kept")
        local snapshot = tracker:snapshot()
        snapshot.instances[1].tags = { "" }
        expect_error(function() tracker:restore(snapshot) end)
        expect_true(tracker:has(1, "kept"))
    end)
end)

test_summary()
