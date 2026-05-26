-- Lurek2D Library Tween Chain Tests
-- @testCategory library

local TweenChain = require("library.tween_chain")

-- @describe tween_chain library     new
describe("tween_chain library     new", function()
    -- @library lurek.library_tween_chain
    it("creates chain", function()
        local chain = TweenChain.new()
        expect_not_nil(chain, "new() must return non-nil chain")
        expect_true(chain:isComplete() == false, "fresh chain must not be complete")
        expect_true(chain:isPlaying() == false, "fresh chain must not be playing")
    end)
end)

-- @describe tween_chain library     to
describe("tween_chain library     to", function()
    -- @library lurek.library_tween_chain
    it("adds tween step and object properties change after full update", function()
        local obj = { x = 0, y = 0 }
        local chain = TweenChain.new()
        chain:to(obj, { x = 100, y = 50 }, 1.0, "linear")
        chain:start()
        chain:update(1.0)
        expect_equal(obj.x, 100, "x must reach 100 after full duration")
        expect_equal(obj.y, 50, "y must reach 50 after full duration")
    end)
end)

-- @describe tween_chain library     wait
describe("tween_chain library     wait", function()
    -- @library lurek.library_tween_chain
    it("adds delay step", function()
        local obj = { x = 0 }
        local chain = TweenChain.new()
        chain:wait(0.5):to(obj, { x = 10 }, 0.5, "linear")
        chain:start()
        -- After 0.3s we should still be in the wait step
        chain:update(0.3)
        expect_equal(obj.x, 0, "x must still be 0 during wait")
        -- After 0.5s total the wait completes, tween begins
        chain:update(0.2)
        expect_equal(obj.x, 0, "x must still be 0 at exact wait boundary")
        -- Now the tween step should advance
        chain:update(0.5)
        expect_equal(obj.x, 10, "x must reach 10 after tween completes")
    end)
end)

-- @describe tween_chain library     call
describe("tween_chain library     call", function()
    -- @library lurek.library_tween_chain
    it("fires callback when step is reached", function()
        local called = false
        local chain = TweenChain.new()
        chain:call(function() called = true end)
        chain:start()
        chain:update(0)
        expect_true(called, "call step must fire its callback")
    end)
end)

-- @describe tween_chain library     start stop reset lifecycle
describe("tween_chain library     start stop reset lifecycle", function()
    -- @library lurek.library_tween_chain
    it("start sets playing state", function()
        local obj = { x = 0 }
        local chain = TweenChain.new()
        chain:to(obj, { x = 10 }, 1.0)
        chain:start()
        expect_true(chain:isPlaying(), "chain must be playing after start")
    end)

    -- @library lurek.library_tween_chain
    it("stop marks chain as complete", function()
        local obj = { x = 0 }
        local chain = TweenChain.new()
        chain:to(obj, { x = 10 }, 1.0)
        chain:start()
        chain:stop()
        expect_true(chain:isPlaying() == false, "chain must not be playing after stop")
        expect_true(chain:isComplete(), "chain must be complete after stop")
    end)

    -- @library lurek.library_tween_chain
    it("reset returns to initial state", function()
        local obj = { x = 0 }
        local chain = TweenChain.new()
        chain:to(obj, { x = 10 }, 1.0)
        chain:start()
        chain:update(0.5)
        chain:reset()
        expect_true(chain:isPlaying() == false, "chain must not be playing after reset")
        expect_true(chain:isComplete() == false, "chain must not be complete after reset")
    end)
end)

-- @describe tween_chain library     isPlaying isComplete state
describe("tween_chain library     isPlaying isComplete state", function()
    -- @library lurek.library_tween_chain
    it("isComplete is true after full playthrough", function()
        local obj = { x = 0 }
        local chain = TweenChain.new()
        chain:to(obj, { x = 10 }, 0.5)
        chain:start()
        chain:update(0.5)
        chain:update(0)
        expect_true(chain:isComplete(), "chain must be complete after all steps done")
        expect_true(chain:isPlaying() == false, "chain must not be playing when complete")
    end)
end)

-- @describe tween_chain library     getProgress
describe("tween_chain library     getProgress", function()
    -- @library lurek.library_tween_chain
    it("returns 0 before start", function()
        local chain = TweenChain.new()
        chain:to({ x = 0 }, { x = 10 }, 1.0)
        expect_equal(chain:getProgress(), 0, "progress must be 0 before start")
    end)

    -- @library lurek.library_tween_chain
    it("returns 1.0 when complete", function()
        local obj = { x = 0 }
        local chain = TweenChain.new()
        chain:to(obj, { x = 10 }, 0.5)
        chain:start()
        chain:update(0.5)
        chain:update(0)
        expect_equal(chain:getProgress(), 1.0, "progress must be 1.0 when complete")
    end)
end)

-- @describe tween_chain library     parallel group
describe("tween_chain library     parallel group", function()
    -- @library lurek.library_tween_chain
    it("completes when longest tween finishes", function()
        local a = { x = 0 }
        local b = { x = 0 }
        local group = TweenChain.parallel()
        group:to(a, { x = 10 }, 0.5, "linear")
        group:to(b, { x = 20 }, 1.0, "linear")

        local chain = TweenChain.new()
        chain:add(group)
        chain:start()
        -- After 0.5s, short tween done, long still running
        chain:update(0.5)
        expect_equal(a.x, 10, "short tween must complete at 0.5s")
        expect_true(chain:isComplete() == false, "chain must not be complete before longest tween")
        -- After another 0.5s, long tween also done
        chain:update(0.5)
        chain:update(0)
        expect_equal(b.x, 20, "long tween must complete at 1.0s")
        expect_true(chain:isComplete(), "chain must be complete after parallel group finishes")
    end)
end)

-- @describe tween_chain library     loop
describe("tween_chain library     loop", function()
    -- @library lurek.library_tween_chain
    it("repeats correct number of times", function()
        local obj = { x = 0 }
        local count = 0
        local chain = TweenChain.new()
        chain:to(obj, { x = 10 }, 0.5, "linear")
             :call(function() count = count + 1 end)
        chain:loop(3)
        chain:start()
        -- Run through 3 iterations
        for _ = 1, 3 do
            chain:update(0.5)
            chain:update(0)
        end
        expect_equal(count, 3, "call must fire 3 times for loop(3)")
        expect_true(chain:isComplete(), "chain must be complete after all loops")
    end)
end)

-- @describe tween_chain library     onComplete callback
describe("tween_chain library     onComplete callback", function()
    -- @library lurek.library_tween_chain
    it("fires when chain fully completes", function()
        local fired = false
        local obj = { x = 0 }
        local chain = TweenChain.new()
        chain:to(obj, { x = 10 }, 0.5)
        chain:onComplete(function() fired = true end)
        chain:start()
        chain:update(0.5)
        chain:update(0)
        expect_true(fired, "onComplete must fire when chain completes")
    end)
end)

test_summary()
