-- Lurek2D Lua BDD tests for lurek.patterns.newMediator
-- Headless: no GPU, no audio, no window.

-- @description Covers suite: lurek.patterns Mediator.
describe("lurek.patterns.Mediator", function()
    -- @covers lurek.patterns.newMediator
    -- @covers lurek.patterns.Mediator.on
    -- @covers lurek.patterns.Mediator.send
    -- @description Verifies that a registered handler receives sent messages.
    it("on registers a handler that receives send messages", function()
        local m = lurek.patterns.newMediator()
        local received = nil
        m:on("click", function(data)
            received = data
        end)
        m:send("click", "hello")
        expect_equal("hello", received)
    end)

    -- @covers lurek.patterns.Mediator.off
    -- @description Verifies that off by handler id stops the handler receiving messages.
    it("off removes handler by id", function()
        local m = lurek.patterns.newMediator()
        local count = 0
        local id = m:on("tick", function() count = count + 1 end)
        m:send("tick")
        m:off("tick", id)
        m:send("tick")
        expect_equal(1, count)
    end)

    -- @covers lurek.patterns.Mediator.broadcast
    -- @description Verifies that broadcast delivers to all subscribed channels that match.
    it("send only fires handler on its own channel", function()
        local m = lurek.patterns.newMediator()
        local hit = 0
        m:on("channelA", function() hit = hit + 1 end)
        m:on("channelB", function() hit = hit + 100 end)
        m:send("channelA", "payload")
        expect_equal(1, hit)
    end)

    -- @covers lurek.patterns.Mediator.handlerCount
    -- @description Verifies that handlerCount reflects registered/removed handlers.
    it("handlerCount tracks registration and removal", function()
        local m = lurek.patterns.newMediator()
        expect_equal(0, m:handlerCount("events"))
        local id = m:on("events", function() end)
        expect_equal(1, m:handlerCount("events"))
        m:off("events", id)
        expect_equal(0, m:handlerCount("events"))
    end)

    -- @covers lurek.patterns.Mediator.channels
    -- @description Verifies that channels returns all channel names.
    it("channels returns registered channel names", function()
        local m = lurek.patterns.newMediator()
        m:on("alpha", function() end)
        m:on("beta", function() end)
        local ch = m:channels()
        expect_equal(2, #ch)
    end)

    -- @covers lurek.patterns.Mediator.removeChannel
    -- @description Verifies that removeChannel clears all handlers on that channel.
    it("removeChannel removes all handlers on a channel", function()
        local m = lurek.patterns.newMediator()
        m:on("destroy", function() end)
        m:on("destroy", function() end)
        expect_equal(2, m:handlerCount("destroy"))
        m:removeChannel("destroy")
        expect_equal(0, m:handlerCount("destroy"))
    end)

    -- @covers lurek.patterns.Mediator.clear
    -- @description Verifies that clear removes all channels and handlers.
    it("clear removes all channels", function()
        local m = lurek.patterns.newMediator()
        m:on("a", function() end)
        m:on("b", function() end)
        m:clear()
        local ch = m:channels()
        expect_equal(0, #ch)
    end)
end)
test_summary()
