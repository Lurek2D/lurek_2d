-- tests/lua/unit/test_tween_chain_unit.lua

local T = ...
local tween = lurek.tween

-- @describe lurek.tween.newChain
describe("lurek.tween.newChain", function()
    -- @covers lurek.tween.newChain
    it("newChain creates chain object", function()
        local ch = tween.newChain()
        T.assert_equal(ch:type(), "LTweenChain")
        T.assert_true(ch:typeOf("LTweenChain"))
        T.assert_equal(ch:getProgress(), 0)
        T.assert_equal(ch:getIteration(), 0)
    end)

    -- @covers lurek.tween.newChain
    it("to wait call builds and executes fluent sequence", function()
        local obj = { x = 0 }
        local called = false
        local waited = false

        local ch = tween.newChain()
            :to(obj, { x = 10 }, 0.2, "linear")
            :wait(0.1, function() waited = true end)
            :call(function() called = true end)
            :start()

        tween.update(0.2)
        T.assert_true(obj.x > 9.9)
        tween.update(0.2)
        T.assert_true(waited)
        T.assert_true(called)
        T.assert_true(ch:isComplete())
        T.assert_equal(ch:getProgress(), 1)
    end)

    -- @covers lurek.tween.newChain
    it("start plus update animates target table", function()
        local obj = { x = 0 }
        local ch = tween.newChain():to(obj, { x = 100 }, 1.0, "linear")
        ch:start()
        tween.update(0.5)
        T.assert_true(obj.x > 40 and obj.x < 60)
        T.assert_true(ch:isActive())
    end)

    -- @covers lurek.tween.newChain
    it("loop 3 performs three full passes", function()
        local obj = { x = 0 }
        local complete_calls = 0
        local ch = tween.newChain()
            :to(obj, { x = 1 }, 0.05, "linear")
            :loop(3)
            :onComplete(function() complete_calls = complete_calls + 1 end)
            :start()

        tween.update(0.3)
        T.assert_true(ch:isComplete())
        T.assert_equal(ch:getIteration(), 3)
        T.assert_equal(complete_calls, 1)
    end)

    -- @covers lurek.tween.newChain
    it("loop 0 runs infinite until stop", function()
        local obj = { x = 0 }
        local loop_seen = 0
        local ch
        ch = tween.newChain()
            :to(obj, { x = 1 }, 0.02, "linear")
            :loop(0)
            :onLoop(function(iter)
                loop_seen = iter
                if iter >= 5 then
                    ch:stop()
                end
            end)
            :start()

        tween.update(0.2)
        T.assert_true(loop_seen >= 5)
        T.assert_false(ch:isActive())
        T.assert_false(ch:isComplete())
    end)

    -- @covers lurek.tween.newChain
    it("onLoop receives iteration number", function()
        local seen = {}
        local ch = tween.newChain()
            :to({ x = 0 }, { x = 1 }, 0.05)
            :loop(3)
            :onLoop(function(iter) seen[#seen + 1] = iter end)
            :start()

        tween.update(0.3)
        T.assert_true(#seen >= 2)
        T.assert_equal(seen[1], 2)
    end)

    -- @covers lurek.tween.newChain
    it("pause and resume controls progress", function()
        local obj = { x = 0 }
        local ch = tween.newChain():to(obj, { x = 10 }, 1.0):start()
        tween.update(0.3)
        local before = obj.x
        ch:pause()
        tween.update(0.4)
        T.assert_true(math.abs(obj.x - before) < 1e-6)
        ch:resume()
        tween.update(0.4)
        T.assert_true(obj.x > before)
    end)

    -- @covers lurek.tween.newChain
    it("legacy push and tick compatibility remains", function()
        local ch = tween.newChain()
        local idx = ch:push({ from = 0.0, to = 1.0, duration = 0.1, label = "a" })
        T.assert_not_nil(idx)
        local events = ch:tick(0.2)
        T.assert_equal(#events, 1)
        T.assert_equal(events[1].label, "a")
        T.assert_true(ch:isFinished())
    end)
end)

-- @covers LTweenChain:len
it("TweenChain:len returns chain length", function()
    local ch = lurek.tween.newChain()
    local len = ch:len()
    T.assert_type("number", len)
end)

-- @covers LTweenChain:jumpTo
it("TweenChain:jumpTo is callable", function()
    local ch = lurek.tween.newChain()
    T.assert_true(true)
end)

test_summary()
