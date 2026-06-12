-- Lurek2D Stress Test: Thread/Channel Communication
-- Tests thread channel message throughput

local function pop_msg(ch)
    if type(ch.tryPop) == "function" then
        return ch:tryPop()
    end
    if type(ch.pop) == "function" then
        return ch:pop()
    end
    return nil
end

local function new_channel_with_messages(count, value_builder)
    local channel = lurek.thread.newChannel()
    for i = 1, count do
        channel:push(value_builder(i))
    end
    return channel
end

local function drain_channel(channel, expected_count)
    local count = 0
    for _ = 1, expected_count do
        local val = pop_msg(channel)
        if val ~= nil then
            count = count + 1
        end
    end
    return count
end

-- @describe thread stress: channel creation
describe("thread stress: channel creation", function()
    -- @stress lurek.thread.newChannel
    it("creates 100 channels", function()
        local channels = {}
        for i = 1, 100 do
            channels[i] = lurek.thread.newChannel()
        end
        expect_equal(100, #channels, "100 channels created")
    end)

    -- @stress LChannel:getCount
    it("single channel handles 10000 messages", function()
        local ch = new_channel_with_messages(10000, function(i)
            return i
        end)
        expect_equal(10000, ch:getCount(), "channel reports 10000 queued messages")
        local count = drain_channel(ch, 10000)
        expect_equal(10000, count, "10000 messages round-tripped")
    end)
end)

-- @describe thread stress: mixed message types
describe("thread stress: mixed message types", function()
    -- @stress LChannel:pop
    it("channel handles mixed types", function()
        local ch = new_channel_with_messages(1000, function(i)
            if i % 4 == 0 then
                return i
            elseif i % 4 == 1 then
                return "msg_" .. i
            elseif i % 4 == 2 then
                return true
            end
            return i * 0.5
        end)
        local count = drain_channel(ch, 1000)
        expect_equal(1000, count, "1000 mixed messages")
    end)
end)

-- @describe thread stress: multi-channel fanout
describe("thread stress: multi-channel fanout", function()
    -- @stress LChannel:push
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
            for _ = 1, 100 do
                if pop_msg(ch) ~= nil then
                    count = count + 1
                end
            end
            expect_equal(100, count, "channel " .. i .. " had 100 messages")
        end
    end)
end)
test_summary()
