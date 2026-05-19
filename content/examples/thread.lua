-- content/examples/thread.lua
-- Auto-generated from content/examples2/thread_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/thread.lua

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
-- Pushing and popping values. Focus: push.
do
    ---@type LChannel
    local ch = lurek.thread.newChannel()
    local id1 = ch:push("hello")
    print("pushed id: " .. id1)
    print("count = " .. ch:getCount())
end

--@api-stub: LChannel:pop
-- Pushing and popping values. Focus: pop.
do
    ---@type LChannel
    local ch = lurek.thread.newChannel()
    ch:push("hello")
    local val1 = ch:pop()
    print("pop 1 = " .. tostring(val1))
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
-- Conditional push operations. Focus: supply.
do
    ---@type LChannel
    local ch = lurek.thread.newBoundedChannel(2)
    ch:tryPush("a")
    ch:tryPush("b")
    local supplied = ch:supply("d")
    print("supply when full = " .. tostring(supplied))
end

--@api-stub: LChannel:tryPush
-- Conditional push operations. Focus: tryPush.
do
    ---@type LChannel
    local ch = lurek.thread.newBoundedChannel(2)
    local ok1 = ch:tryPush("a")
    print("tryPush 1 = " .. tostring(ok1))
end

--@api-stub: LChannel:pushBytes
-- Binary data transfer via channel. Focus: pushBytes.
do
    ---@type LChannel
    local ch = lurek.thread.newChannel()
    local data = string.rep("\x00\xFF", 100)
    local id = ch:pushBytes(data)
    print("pushBytes id = " .. id)
end

--@api-stub: LChannel:popBytes
-- Binary data transfer via channel. Focus: popBytes.
do
    ---@type LChannel
    local ch = lurek.thread.newChannel()
    local data = string.rep("\x00\xFF", 100)
    ch:pushBytes(data)
    local retrieved = ch:popBytes()
    print("popBytes length = " .. #retrieved)
end

--@api-stub: LChannel:pushTable
-- Structured table transfer. Focus: pushTable.
do
    ---@type LChannel
    local ch = lurek.thread.newChannel()
    local payload = { name = "player", hp = 100, items = { "sword", "shield" } }
    local id = ch:pushTable(payload)
    print("pushTable id = " .. id)
end

--@api-stub: LChannel:popTable
-- Structured table transfer. Focus: popTable.
do
    ---@type LChannel
    local ch = lurek.thread.newChannel()
    local payload = { name = "player", hp = 100, items = { "sword", "shield" } }
    ch:pushTable(payload)
    local result = ch:popTable()
    print("popTable name = " .. result.name)
end

--@api-stub: LChannel:clear
-- Clearing the channel. Focus: clear.
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

--@api-stub: LChannel:getCount
-- Clearing the channel. Focus: getCount.
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
    ---@type LChannel
    local same = lurek.thread.getChannel("events")
    local msg = same:pop()
    print("shared channel msg = " .. tostring(msg))
    print("same instance = " .. tostring(ch == same))
end

--@api-stub: lurek.thread.newThread
-- Creating and starting a worker thread.
do
    ---@type LChannel
    local results = lurek.thread.getChannel("results")
    results:clear()
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
    print("result = " .. tostring(results:pop()))
    print("error = " .. tostring(t:getError()))

    -- Passing initial data to a thread. Focus: newThread.
    ---@type LChannel
    local out = lurek.thread.getChannel("output")
    out:clear()
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
        local input = lurek.thread.getChannel("__pool_input")
        local output = lurek.thread.getChannel("__pool_output")
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
-- Submitting work and collecting results. Focus: submit.
do
    ---@type LThreadPool
    local pool = lurek.thread.newPool(2, [[
        local input = lurek.thread.getChannel("__pool_input")
        local output = lurek.thread.getChannel("__pool_output")
        while true do
            local val = input:demand(0.5)
            if not val then break end
            output:push(val * 2)
        end
    ]])
    pool:submit(10)
    pool:submit(20)
    pool:submit(30)
    print("submitted 3 tasks")
    local results = nil
    for _ = 1, 1000 do
        results = pool:collect()
        if results ~= nil then
            break
        end
    end
    print("collected = " .. tostring(results))
end

--@api-stub: LThreadPool:collect
-- Submitting work and collecting results. Focus: collect.
do
    ---@type LThreadPool
    local pool = lurek.thread.newPool(2, [[
        local input = lurek.thread.getChannel("__pool_input")
        local output = lurek.thread.getChannel("__pool_output")
        while true do
            local val = input:demand(0.5)
            if not val then break end
            output:push(val * 2)
        end
    ]])
    pool:submit(10)
    pool:submit(20)
    pool:submit(30)
    print("submitted 3 tasks")
    local results = nil
    for _ = 1, 1000 do
        results = pool:collect()
        if results ~= nil then
            break
        end
    end
    print("collected = " .. tostring(results))
end

--@api-stub: LThreadPool:getInputChannel
-- Accessing pool channels directly. Focus: getInputChannel.
do
    ---@type LThreadPool
    local pool = lurek.thread.newPool(2, [[
        local inp = lurek.thread.getChannel("__pool_input")
        local out = lurek.thread.getChannel("__pool_output")
        local val = inp:demand(0.5)
        if val then out:push(val .. "_done") end
    ]])
    ---@type LChannel
    local inCh = pool:getInputChannel()
    ---@type LChannel
    local outCh = pool:getOutputChannel()
    print("input channel type = " .. inCh:type())
    print("output channel type = " .. outCh:type())
    inCh:push("job")
    print("output message = " .. tostring(outCh:demand(1.0)))
end

--@api-stub: LThreadPool:getOutputChannel
-- Accessing pool channels directly. Focus: getOutputChannel.
do
    ---@type LThreadPool
    local pool = lurek.thread.newPool(2, [[
        local inp = lurek.thread.getChannel("__pool_input")
        local out = lurek.thread.getChannel("__pool_output")
        local val = inp:demand(0.5)
        if val then out:push(val .. "_done") end
    ]])
    ---@type LChannel
    local inCh = pool:getInputChannel()
    ---@type LChannel
    local outCh = pool:getOutputChannel()
    print("output channel type = " .. outCh:type())
    inCh:push("job")
    print("output message = " .. tostring(outCh:demand(1.0)))
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
-- Waiting for async result. Focus: result.
do
    ---@type LPromise
    local promise = lurek.thread.async([[
        return 42
    ]])
    local done = false
    for _ = 1, 1000 do
        if promise:isDone() then
            done = true
            break
        end
    end
    local val = promise:result()
    print("result = " .. tostring(val))
end

--@api-stub: LPromise:isDone
-- Waiting for async result. Focus: isDone.
do
    ---@type LPromise
    local promise = lurek.thread.async([[
        return 42
    ]])
    local done = false
    for _ = 1, 1000 do
        if promise:isDone() then
            done = true
            break
        end
    end
    print("done = " .. tostring(done))
end

--@api-stub: LPromise:getError
-- Waiting for async result. Focus: getError.
do
    ---@type LPromise
    local promise = lurek.thread.async([[
        return 42
    ]])
    local done = false
    for _ = 1, 1000 do
        if promise:isDone() then
            done = true
            break
        end
    end
    print("error = " .. tostring(promise:getError()))
end

--@api-stub: LPromise:chain
-- Chaining sequential async operations.
do
    ---@type LPromise
    local p1 = lurek.thread.async([[
        return 10
    ]])
    local p2 = nil
    for _ = 1, 1000 do
        if p1:isDone() then
            p2 = p1:chain([[
                local prev = ...
                return prev * 3
            ]])
            break
        end
    end

    local p3 = nil
    if p2 then
        for _ = 1, 1000 do
            if p2:isDone() then
                p3 = p2:chain([[
                    local prev = ...
                    return prev + 5
                ]])
                break
            end
        end
    end

    print("p1 done = " .. tostring(p1:isDone()))
    print("p2 created = " .. tostring(p2 ~= nil))
    print("p3 created = " .. tostring(p3 ~= nil))
    if p3 then
        print("chain created, p3 type = " .. p3:type())
    end
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

--- Thread Module Part 1: LChannel, LThread, newBoundedChannel, newPool, newChannel, newThread


--@api-stub: LChannel:getCapacity
-- Channel full API coverage: push/pop variants, supply, demand, capacity, count, type. Focus: getCapacity.
do
    local ch = lurek.thread.newChannel()
    print("capacity=" .. tostring(ch:getCapacity()))
end

--@api-stub: LChannel:isBounded
-- Channel full API coverage: push/pop variants, supply, demand, capacity, count, type. Focus: isBounded.
do
    local ch = lurek.thread.newChannel()
    print("bounded=" .. tostring(ch:isBounded()))
end

--@api-stub: LChannel:type
-- Channel full API coverage: push/pop variants, supply, demand, capacity, count, type. Focus: type.
do
    local ch = lurek.thread.newChannel()
    print("type=" .. ch:type())
end

--@api-stub: LChannel:typeOf
-- Channel full API coverage: push/pop variants, supply, demand, capacity, count, type. Focus: typeOf.
do
    local ch = lurek.thread.newChannel()
    print("typeOf=" .. tostring(ch:typeOf("LChannel")))
end

--@api-stub: LThread:getError
-- Thread lifecycle, start, error, and type introspection. Focus: getError.
do
    local status = lurek.thread.getChannel("thread_status")
    status:clear()
    local code = [[
        local ch = lurek.thread.getChannel("thread_status")
        ch:push("done")
    ]]
    local t = lurek.thread.newThread(code)
    t:start()
    t:wait()
    local err = t:getError()
    print("error=" .. tostring(err))
end

--@api-stub: LThread:isRunning
-- Thread lifecycle, start, error, and type introspection. Focus: isRunning.
do
    local status = lurek.thread.getChannel("thread_status")
    status:clear()
    local code = [[
        local ch = lurek.thread.getChannel("thread_status")
        ch:push("done")
    ]]
    local t = lurek.thread.newThread(code)
    t:start()
    local running = t:isRunning()
    print("running=" .. tostring(running))
end

--@api-stub: LThread:start
-- Thread lifecycle, start, error, and type introspection. Focus: start.
do
    local status = lurek.thread.getChannel("thread_status")
    status:clear()
    local code = [[
        local ch = lurek.thread.getChannel("thread_status")
        ch:push("done")
    ]]
    local t = lurek.thread.newThread(code)
    t:start()
    print("start ok")
end

--@api-stub: LThread:type
-- Thread lifecycle, start, error, and type introspection. Focus: type.
do
    local status = lurek.thread.getChannel("thread_status")
    status:clear()
    local code = [[
        local ch = lurek.thread.getChannel("thread_status")
        ch:push("done")
    ]]
    local t = lurek.thread.newThread(code)
    print("type=" .. t:type())
end

--@api-stub: LThread:typeOf
-- Thread lifecycle, start, error, and type introspection. Focus: typeOf.
do
    local status = lurek.thread.getChannel("thread_status")
    status:clear()
    local code = [[
        local ch = lurek.thread.getChannel("thread_status")
        ch:push("done")
    ]]
    local t = lurek.thread.newThread(code)
    print("typeOf=" .. tostring(t:typeOf("LThread")))
end

--@api-stub: LPromise:type
-- LPromise type checks and LThread wait. Focus: type.
do
    local p = lurek.thread.async("return 42")
    local t = p:type()
    print("LPromise type:", t)
end

--@api-stub: LPromise:typeOf
-- LPromise type checks and LThread wait. Focus: typeOf.
do
    local p = lurek.thread.async("return 42")
    local ok = p:typeOf("LPromise")
    print("LPromise typeOf:", ok)
end

--@api-stub: LThread:wait
-- LPromise type checks and LThread wait. Focus: wait.
do
    local thread = lurek.thread.newThread("return 'done'")
    thread:start()
    thread:wait()
    print("LThread:wait ok")
end

--@api-stub: LThreadPool:size
-- LThreadPool size and type checks. Focus: size.
do
    local pool = lurek.thread.newPool(3, "return require 'lurek'.thread and 'ok' or 'ok'")
    local sz = pool:size()
    print("pool size:", sz)
end

--@api-stub: LThreadPool:type
-- LThreadPool size and type checks. Focus: type.
do
    local pool = lurek.thread.newPool(3, "return require 'lurek'.thread and 'ok' or 'ok'")
    local t = pool:type()
    print("type:", t)
end

--@api-stub: LThreadPool:typeOf
-- LThreadPool size and type checks. Focus: typeOf.
do
    local pool = lurek.thread.newPool(3, "return require 'lurek'.thread and 'ok' or 'ok'")
    local ok = pool:typeOf("LThreadPool")
    print("typeOf:", ok)
end

print("content/examples/thread.lua")
