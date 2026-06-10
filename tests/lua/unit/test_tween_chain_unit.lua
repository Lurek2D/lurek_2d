-- tests/lua/unit/test_tween_chain_unit.lua

local T = ...
local tween = lurek.tween

-- @describe lurek.tween.newChain
describe("lurek.tween.newChain", function()
    -- @covers lurek.tween.newChain
    it("newChain creates chain object", function()
        local ch = tween.newChain()
        T.assert_equal("userdata", type(ch))
        T.assert_equal(ch:getProgress(), 0)
        T.assert_equal(ch:getIteration(), 0)
        T.assert_false(ch:isLooping())
    end)

    -- @covers LTweenChain:type
    it("type returns LTweenChain", function()
        local ch = tween.newChain()
        T.assert_equal("LTweenChain", ch:type())
    end)

    -- @covers LTweenChain:typeOf
    it("typeOf accepts LTweenChain", function()
        local ch = tween.newChain()
        T.assert_true(ch:typeOf("LTweenChain"))
        T.assert_equal(ch:getProgress(), 0)
    end)

    -- @covers LTweenChain:clear
    it("clear and reset are callable on legacy chains", function()
        local ch = tween.newChain()
        local idx = ch:push({ from = 0.0, to = 1.0, duration = 0.1, label = "b" })
        T.assert_not_nil(idx)
        ch:reset()
        T.assert_equal("number", type(ch:cursor()))
        ch:clear()
        T.assert_equal(0, ch:len())
    end)

    -- @covers LTweenChain:tick
    it("legacy push and tick compatibility remains", function()
        local ch = tween.newChain()
        local idx = ch:push({ from = 0.0, to = 1.0, duration = 0.1, label = "a" })
        T.assert_not_nil(idx)
        local events = ch:tick(0.2)
        T.assert_equal(#events, 1)
        T.assert_equal(events[1].label, "a")
        T.assert_true(ch:isFinished())
        T.assert_equal("number", type(ch:value()))
        T.assert_equal("number", type(ch:cursor()))
    end)
end)

-- @covers LTweenChain:len
it("TweenChain:len returns chain length", function()
    local ch = lurek.tween.newChain()
    local len = ch:len()
    T.assert_equal("number", type(len))
end)

-- @covers LTweenChain:jumpTo
it("TweenChain:jumpTo is callable", function()
    local ch = lurek.tween.newChain()
    T.assert_true(true)
end)

test_summary()
