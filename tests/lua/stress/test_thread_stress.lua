-- Lurek2D Stress Test: Thread/Channel Communication
-- Tests thread channel message throughput

-- @description Covers suite: thread stress: channel creation.
describe("thread stress: channel creation", function()
    -- @covers lurek.thread.newChannel
    -- @stress Allocates 100 standalone channels in one loop.
    -- @description Stresses channel-object construction throughput by creating a moderate batch of channel instances without message traffic.
    it("creates 100 channels", function()
        local channels = {}
        for i = 1, 100 do
            channels[i] = lurek.thread.newChannel()
        end
        expect_equal(100, #channels, "100 channels created")
    end)

    -- @covers lurek.thread.newChannel
    -- @covers Channel:push
    -- @covers Channel:tryPop
    -- @stress Pushes and drains 10000 messages through one channel.
    -- @description Stresses single-channel queue throughput by filling one channel with a large message count and then popping everything back out.
    it("single channel handles 10000 messages", function()
        local ch = lurek.thread.newChannel()

        -- Push 10000 messages
        for i = 1, 10000 do
            ch:push(i)
        end

        -- Pop all
        local count = 0
        while true do
            local val = ch:tryPop()
            if val == nil then break end
            count = count + 1
        end

        expect_equal(10000, count, "10000 messages round-tripped")
    end)
end)

-- @description Covers suite: thread stress: mixed message types.
describe("thread stress: mixed message types", function()
    -- @covers lurek.thread.newChannel
    -- @covers Channel:push
    -- @covers Channel:tryPop
    -- @stress Pushes 1000 mixed-type messages through one channel and drains them all.
    -- @description Stresses channel serialization and queue handling across numbers, strings, booleans, and floats in one mixed workload.
    it("channel handles mixed types", function()
        local ch = lurek.thread.newChannel()

        -- Push different types
        for i = 1, 1000 do
            if i % 4 == 0 then
                ch:push(i)              -- number
            elseif i % 4 == 1 then
                ch:push("msg_" .. i)    -- string
            elseif i % 4 == 2 then
                ch:push(true)           -- boolean
            else
                ch:push(i * 0.5)        -- float
            end
        end

        local count = 0
        while true do
            local val = ch:tryPop()
            if val == nil then break end
            count = count + 1
        end

        expect_equal(1000, count, "1000 mixed messages")
    end)
end)

-- @description Covers suite: thread stress: multi-channel fanout.
describe("thread stress: multi-channel fanout", function()
    -- @covers lurek.thread.newChannel
    -- @covers Channel:push
    -- @covers Channel:tryPop
    -- @stress Broadcasts 100 messages into each of 10 channels, then drains every queue.
    -- @description Stresses fanout-style message throughput by distributing the same message stream across many channels and verifying per-channel counts.
    it("broadcast to 10 channels", function()
        local channels = {}
        for i = 1, 10 do
            channels[i] = lurek.thread.newChannel()
        end

        -- Broadcast 100 messages to all channels
        for msg = 1, 100 do
            for _, ch in ipairs(channels) do
                ch:push(msg)
            end
        end

        -- Each channel should have 100 messages
        for i, ch in ipairs(channels) do
            local count = 0
            while ch:tryPop() ~= nil do
                count = count + 1
            end
            expect_equal(100, count, "channel " .. i .. " had 100 messages")
        end
    end)
end)
test_summary()
