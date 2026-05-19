--- Thread Module: channels, threads, pools, promises, async, worker capabilities

--@api-stub: lurek.thread.newChannel
-- Creating an unbounded channel.
do
    ---@type LChannel
    local ch = lurek.thread.newChannel()
    print("type = " .. ch:type())
    print("is LChannel = " .. tostring(ch:typeOf("LChannel")))
    print("count = " .. ch:getCount())
    print("bounded = " .. tostring(ch:isBounded()))
end

--@api-stub: lurek.thread.newBoundedChannel
-- Creating a capacity-limited channel.
do
    ---@type LChannel
    local ch = lurek.thread.newBoundedChannel(10)
    print("bounded = " .. tostring(ch:isBounded()))
    print("capacity = " .. ch:getCapacity())
    print("count = " .. ch:getCount())
end

--@api-stub: LChannel:push
--@api-stub: LChannel:pop
-- Pushing and popping values.
do
    ---@type LChannel
    local ch = lurek.thread.newChannel()
    local id1 = ch:push("hello")
    local id2 = ch:push(42)
    local id3 = ch:push({ x = 10, y = 20 })
    print("pushed ids: " .. id1 .. ", " .. id2 .. ", " .. id3)
    print("count = " .. ch:getCount())
    local val1 = ch:pop()
    print("pop 1 = " .. tostring(val1))
    local val2 = ch:pop()
    print("pop 2 = " .. tostring(val2))
    print("remaining = " .. ch:getCount())
end

--@api-stub: LChannel:peek
-- Peeking without removing.
do
    ---@type LChannel
    local ch = lurek.thread.newChannel()
    ch:push("first")
    ch:push("second")
    local peeked = ch:peek()
    print("peek = " .. tostring(peeked))
    print("count after peek = " .. ch:getCount())
    ch:pop()
    peeked = ch:peek()
    print("peek after pop = " .. tostring(peeked))
end

--@api-stub: LChannel:demand
-- Blocking pop with timeout.
do
    ---@type LChannel
    local ch = lurek.thread.newChannel()
    ch:push("ready")
    local val = ch:demand(1.0)
    print("demand got = " .. tostring(val))
    local empty = ch:demand(0.01)
    print("demand timeout = " .. tostring(empty))
end

--@api-stub: LChannel:supply
--@api-stub: LChannel:tryPush
-- Conditional push operations.
do
    ---@type LChannel
    local ch = lurek.thread.newBoundedChannel(2)
    local ok1 = ch:tryPush("a")
    print("tryPush 1 = " .. tostring(ok1))
    local ok2 = ch:tryPush("b")
    print("tryPush 2 = " .. tostring(ok2))
    local ok3 = ch:tryPush("c")
    print("tryPush 3 (full) = " .. tostring(ok3))
    print("count = " .. ch:getCount())
    local supplied = ch:supply("d")
    print("supply when full = " .. tostring(supplied))
end

--@api-stub: LChannel:pushBytes
--@api-stub: LChannel:popBytes
-- Binary data transfer via channel.
do
    ---@type LChannel
    local ch = lurek.thread.newChannel()
    local data = string.rep("\x00\xFF", 100)
    local id = ch:pushBytes(data)
    print("pushBytes id = " .. id)
    local retrieved = ch:popBytes()
    print("popBytes length = " .. #retrieved)
    print("data matches = " .. tostring(retrieved == data))
end

--@api-stub: LChannel:pushTable
--@api-stub: LChannel:popTable
-- Structured table transfer.
do
    ---@type LChannel
    local ch = lurek.thread.newChannel()
    local payload = { name = "player", hp = 100, items = { "sword", "shield" } }
    local id = ch:pushTable(payload)
    print("pushTable id = " .. id)
    local result = ch:popTable()
    print("popTable name = " .. result.name)
    print("popTable hp = " .. result.hp)
    print("popTable items = " .. #result.items)
end

--@api-stub: LChannel:clear
--@api-stub: LChannel:getCount
-- Clearing the channel.
do
    ---@type LChannel
    local ch = lurek.thread.newChannel()
    ch:push("x")
    ch:push("y")
    ch:push("z")
    print("before clear = " .. ch:getCount())
    ch:clear()
    print("after clear = " .. ch:getCount())
end

--@api-stub: lurek.thread.getChannel
-- Named shared channels.
do
    ---@type LChannel
    local ch = lurek.thread.getChannel("events")
    ch:push("player_died")
    ch:push("level_complete")
    ---@type LChannel
    local same = lurek.thread.getChannel("events")
    local msg = same:pop()
    print("shared channel msg = " .. tostring(msg))
    print("same instance = " .. tostring(ch == same))
end

--@api-stub: lurek.thread.newThread
-- Creating and starting a worker thread.
do
    ---@type LThread
    local t = lurek.thread.newThread([[
        local ch = lurek.thread.getChannel("results")
        local sum = 0
        for i = 1, 1000 do
            sum = sum + i
        end
        ch:push(sum)
    ]])
    print("type = " .. t:type())
    print("is LThread = " .. tostring(t:typeOf("LThread")))
    t:start()
    print("running = " .. tostring(t:isRunning()))
    t:wait()
    print("after wait running = " .. tostring(t:isRunning()))
    print("error = " .. tostring(t:getError()))
end

--@api-stub: LThread:start with arguments
-- Passing initial data to a thread.
do
    ---@type LThread
    local t = lurek.thread.newThread([[
        local count, prefix = ...
        local ch = lurek.thread.getChannel("output")
        for i = 1, count do
            ch:push(prefix .. "_" .. i)
        end
    ]])
    t:start(5, "item")
    t:wait()
    ---@type LChannel
    local out = lurek.thread.getChannel("output")
    for i = 1, 5 do
        local val = out:pop()
        print("received: " .. tostring(val))
    end
end

--@api-stub: lurek.thread.newPool
-- Creating a thread pool for parallel work.
do
    ---@type LThreadPool
    local pool = lurek.thread.newPool(4, [[
        local input = lurek.thread.getChannel("pool_in")
        local output = lurek.thread.getChannel("pool_out")
        while true do
            local task = input:demand(0.1)
            if not task then break end
            output:push(task * task)
        end
    ]])
    print("type = " .. pool:type())
    print("is LThreadPool = " .. tostring(pool:typeOf("LThreadPool")))
    print("pool size = " .. pool:size())
end

--@api-stub: LThreadPool:submit
--@api-stub: LThreadPool:collect
-- Submitting work and collecting results.
do
    ---@type LThreadPool
    local pool = lurek.thread.newPool(2, [[
        local input = lurek.thread.getChannel("work_in")
        local output = lurek.thread.getChannel("work_out")
        while true do
            local val = input:demand(0.1)
            if not val then break end
            output:push(val * 2)
        end
    ]])
    pool:submit(10)
    pool:submit(20)
    pool:submit(30)
    print("submitted 3 tasks")
    local results = pool:collect()
    print("collected = " .. tostring(results))
end

--@api-stub: LThreadPool:getInputChannel
--@api-stub: LThreadPool:getOutputChannel
-- Accessing pool channels directly.
do
    ---@type LThreadPool
    local pool = lurek.thread.newPool(2, [[
        local inp = lurek.thread.getChannel("direct_in")
        local out = lurek.thread.getChannel("direct_out")
        local val = inp:demand(0.5)
        if val then out:push(val .. "_done") end
    ]])
    ---@type LChannel
    local inCh = pool:getInputChannel()
    ---@type LChannel
    local outCh = pool:getOutputChannel()
    print("input channel type = " .. inCh:type())
    print("output channel type = " .. outCh:type())
end

--@api-stub: LThreadPool:join
-- Waiting for all pool workers to finish.
do
    ---@type LThreadPool
    local pool = lurek.thread.newPool(2, [[
        -- quick exit worker
    ]])
    local finished = pool:join(2.0)
    print("join result = " .. tostring(finished))
end

--@api-stub: lurek.thread.async
-- Fire-and-forget async execution.
do
    ---@type LPromise
    local promise = lurek.thread.async([[
        local sum = 0
        for i = 1, 10000 do sum = sum + i end
        return sum
    ]])
    print("type = " .. promise:type())
    print("is LPromise = " .. tostring(promise:typeOf("LPromise")))
    print("done immediately = " .. tostring(promise:isDone()))
end

--@api-stub: LPromise:result
--@api-stub: LPromise:isDone
--@api-stub: LPromise:getError
-- Waiting for async result.
do
    ---@type LPromise
    local promise = lurek.thread.async([[
        return 42
    ]])
    while not promise:isDone() do
        -- busy wait (in real code, check each frame)
    end
    local val = promise:result()
    print("result = " .. tostring(val))
    print("error = " .. tostring(promise:getError()))
end

--@api-stub: LPromise:chain
-- Chaining sequential async operations.
do
    ---@type LPromise
    local p1 = lurek.thread.async([[
        return 10
    ]])
    ---@type LPromise
    local p2 = p1:chain([[
        local prev = ...
        return prev * 3
    ]])
    ---@type LPromise
    local p3 = p2:chain([[
        local prev = ...
        return prev + 5
    ]])
    print("chain created, p3 type = " .. p3:type())
end

--@api-stub: lurek.thread.getWorkerCapabilities
-- Querying available worker features.
do
    local caps = lurek.thread.getWorkerCapabilities()
    print("capabilities = " .. #caps)
    for _, cap in ipairs(caps) do
        print("  " .. cap)
    end
end

print("thread_00.lua")
