-- content/examples/thread.lua
-- Auto-generated from content/examples2/thread_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/thread.lua

--- Thread Module: channels, threads, pools, promises, async, worker capabilities

--@api: lurek.thread.newChannel
do
    local ch = lurek.thread.newChannel()
    print("type = " .. ch:type())
    print("count = " .. ch:getCount())
    print("bounded = " .. tostring(ch:isBounded()))
end

--@api: lurek.thread.newBoundedChannel
do
    ---@type LChannel
    local ch = lurek.thread.newBoundedChannel(10)
    print("bounded = " .. tostring(ch:isBounded()))
    print("capacity = " .. ch:getCapacity())
    print("count = " .. ch:getCount())
end

--@api: LChannel:push
do
    ---@type LChannel
    local ch = lurek.thread.newChannel()
    local id1 = ch:push("hello")
    print("pushed id: " .. id1)
    print("count = " .. ch:getCount())
end

--@api: LChannel:pop
do
    ---@type LChannel
    local ch = lurek.thread.newChannel()
    ch:push("hello")
    local val1 = ch:pop()
    print("pop 1 = " .. tostring(val1))
end

--@api: LChannel:peek
do
    local ch = lurek.thread.newChannel()
    ch:push("first")
    print("peek = " .. tostring(ch:peek()))
    print("count after peek = " .. ch:getCount())
end

--@api: LChannel:demand
do
    local ch = lurek.thread.newChannel()
    ch:push("ready")
    print("demand got = " .. tostring(ch:demand(1.0)))
    print("demand timeout = " .. tostring(ch:demand(0.01)))
end

--@api: LChannel:supply
do
    local ch = lurek.thread.newBoundedChannel(2)
    ch:tryPush("a")
    ch:tryPush("b")
    print("supply when full = " .. tostring(ch:supply("d")))
end

--@api: LChannel:tryPush
do
    ---@type LChannel
    local ch = lurek.thread.newBoundedChannel(2)
    local ok1 = ch:tryPush("a")
    print("tryPush 1 = " .. tostring(ok1))
end

--@api: LChannel:pushBytes
do
    ---@type LChannel
    local ch = lurek.thread.newChannel()
    local data = string.rep("\x00\xFF", 100)
    local id = ch:pushBytes(data)
    print("pushBytes id = " .. id)
end

--@api: LChannel:popBytes
do
    local ch = lurek.thread.newChannel()
    ch:pushBytes(string.rep("\x00\xFF", 100))
    print("popBytes length = " .. #ch:popBytes())
end

--@api: LChannel:pushTable
do
    ---@type LChannel
    local ch = lurek.thread.newChannel()
    local payload = { name = "player", hp = 100, items = { "sword", "shield" } }
    local id = ch:pushTable(payload)
    print("pushTable id = " .. id)
end

--@api: LChannel:popTable
do
    local ch = lurek.thread.newChannel()
    ch:pushTable({ name = "player" })
    local result = ch:popTable()
    print("popTable name = " .. result.name)
end

--@api: LChannel:clear
do
    local ch = lurek.thread.newChannel()
    ch:push("x")
    print("before clear = " .. ch:getCount())
    ch:clear()
    print("after clear = " .. ch:getCount())
end

--@api: LChannel:getCount
do
    local ch = lurek.thread.newChannel()
    ch:push("x")
    print("count = " .. ch:getCount())
end

--@api: lurek.thread.getChannel
do
    local ch = lurek.thread.getChannel("events")
    ch:push("player_died")
    local same = lurek.thread.getChannel("events")
    print("shared channel msg = " .. tostring(same:pop()))
    print("same instance = " .. tostring(ch == same))
end

--@api: lurek.thread.newThread
do
    local results = lurek.thread.getChannel("results")
    results:clear()
    local thread = lurek.thread.newThread([[
        local ch = lurek.thread.getChannel("results")
        ch:push(21 * 2)
    ]])
    thread:start()
    thread:wait()
    print("result = " .. tostring(results:pop()))
end

--@api: lurek.thread.newPool

do
    local pool = lurek.thread.newPool(2, [[
        local input = lurek.thread.getChannel("__pool_input")
        local output = lurek.thread.getChannel("__pool_output")
        local value = input:demand(0.1)
        if value then
            output:push(value * 2)
        end
    ]])
    print("type = " .. pool:type())
    print("pool size = " .. pool:size())
end

--@api: LThreadPool:submit
do
    local pool = lurek.thread.newPool(2, [[
        local input = lurek.thread.getChannel("__pool_input")
        local output = lurek.thread.getChannel("__pool_output")
        local value = input:demand(0.1)
        if value then
            output:push(value * 2)
        end
    ]])
    pool:submit(10)
    print("submitted one task")
    print("input count = " .. pool:getInputChannel():getCount())
end

--@api: LThreadPool:collect
do
    local pool = lurek.thread.newPool(2, [[
        local input = lurek.thread.getChannel("__pool_input")
        local output = lurek.thread.getChannel("__pool_output")
        local value = input:demand(0.1)
        if value then
            output:push(value * 2)
        end
    ]])
    pool:submit(10)
    pool:join(1.0)
    print("collected = " .. tostring(pool:collect()))
end

--@api: LThreadPool:getInputChannel
do
    local pool = lurek.thread.newPool(2, [[
        local input = lurek.thread.getChannel("__pool_input")
        local output = lurek.thread.getChannel("__pool_output")
        local value = input:demand(0.1)
        if value then
            output:push(value * 2)
        end
    ]])
    local inCh = pool:getInputChannel()
    print("input channel type = " .. inCh:type())
    print("input bounded = " .. tostring(inCh:isBounded()))
end

--@api: LThreadPool:getOutputChannel
do
    local pool = lurek.thread.newPool(2, [[
        local input = lurek.thread.getChannel("__pool_input")
        local output = lurek.thread.getChannel("__pool_output")
        local value = input:demand(0.1)
        if value then
            output:push(value * 2)
        end
    ]])
    local outCh = pool:getOutputChannel()
    print("output channel type = " .. outCh:type())
    print("output count = " .. outCh:getCount())
end

--@api: LThreadPool:join
do
    local pool = lurek.thread.newPool(2, "return nil")
    print("join result = " .. tostring(pool:join(2.0)))
end

--@api: lurek.thread.async
do
    local promise = lurek.thread.async("return 42")
    print("type = " .. promise:type())
    print("done immediately = " .. tostring(promise:isDone()))
end

--@api: LPromise:result
do
    local promise = lurek.thread.async("return 42")
    print("result = " .. tostring(promise:result()))
end

--@api: LPromise:isDone
do
    local promise = lurek.thread.async("return 42")
    promise:result()
    print("done = " .. tostring(promise:isDone()))
end

--@api: LPromise:getError
do
    local promise = lurek.thread.async("return 42")
    promise:result()
    print("error = " .. tostring(promise:getError()))
end

--@api: LPromise:chain
do
    local first = lurek.thread.async([[
        local result = lurek.thread.getChannel("__promise_result")
        result:push(10)
    ]])
    local guard = 0
    while not first:isDone() and guard < 10000 do
        guard = guard + 1
    end
    local second = first:chain([[
        local prev = ...
        local result = lurek.thread.getChannel("__promise_result")
        result:push(prev * 3)
    ]])
    guard = 0
    while not second:isDone() and guard < 10000 do
        guard = guard + 1
    end
    print("chain result = " .. tostring(second:result()))
end

--@api: lurek.thread.getWorkerCapabilities
do
    local caps = lurek.thread.getWorkerCapabilities()
    print("capabilities = " .. #caps)
end

--- Thread Module Part 1: LChannel, LThread, newBoundedChannel, newPool, newChannel, newThread

--@api: LChannel:getCapacity
do
    local ch = lurek.thread.newChannel()
    print("capacity=" .. tostring(ch:getCapacity()))
end

--@api: LChannel:isBounded
do
    local ch = lurek.thread.newChannel()
    print("bounded=" .. tostring(ch:isBounded()))
end

--@api: LChannel:type
do
    local ch = lurek.thread.newChannel()
    print("type=" .. ch:type())
end

--@api: LChannel:typeOf
do
    local ch = lurek.thread.newChannel()
    print("typeOf=" .. tostring(ch:typeOf("LChannel")))
end

--@api: LThread:getError
do
    local t = lurek.thread.newThread([[
        lurek.thread.getChannel("thread_status"):push("done")
    ]])
    t:start()
    t:wait()
    print("error=" .. tostring(t:getError()))
end

--@api: LThread:isRunning
do
    local t = lurek.thread.newThread("return 1")
    t:start()
    print("running=" .. tostring(t:isRunning()))
end

--@api: LThread:start
do
    local t = lurek.thread.newThread("return 1")
    t:start()
    print("start ok")
end

--@api: LThread:type
do
    local t = lurek.thread.newThread("return 1")
    print("type=" .. t:type())
end

--@api: LThread:typeOf
do
    local t = lurek.thread.newThread("return 1")
    print("typeOf=" .. tostring(t:typeOf("LThread")))
end

--@api: LPromise:type
do
    local p = lurek.thread.async("return 42")
    local t = p:type()
    print("LPromise type:", t)
end

--@api: LPromise:typeOf
do
    local p = lurek.thread.async("return 42")
    local ok = p:typeOf("LPromise")
    print("LPromise typeOf:", ok)
end

--@api: LThread:wait
do
    local thread = lurek.thread.newThread("return 'done'")
    thread:start()
    thread:wait()
    print("LThread:wait ok")
end

--@api: LThreadPool:size
do
    local pool = lurek.thread.newPool(3, [[
        local input = lurek.thread.getChannel("__pool_input")
        local output = lurek.thread.getChannel("__pool_output")
        local value = input:demand(0.05)
        if value then
            output:push(value)
        end
    ]])
    local sz = pool:size()
    print("pool size = " .. sz)
end

--@api: LThreadPool:type
do
    local pool = lurek.thread.newPool(3, [[
        local input = lurek.thread.getChannel("__pool_input")
        local output = lurek.thread.getChannel("__pool_output")
        local value = input:demand(0.05)
        if value then
            output:push(value)
        end
    ]])
    local t = pool:type()
    print("type = " .. t)
end

--@api: LThreadPool:typeOf
do
    local pool = lurek.thread.newPool(3, [[
        local input = lurek.thread.getChannel("__pool_input")
        local output = lurek.thread.getChannel("__pool_output")
        local value = input:demand(0.05)
        if value then
            output:push(value)
        end
    ]])
    local ok = pool:typeOf("LThreadPool")
    print("typeOf = " .. tostring(ok))
end

--@api: LThreadHandle:start
do
    local t = lurek.thread.newThread("return 1")
    t:start()
    print("LThreadHandle:start ok")
end

--@api: LThreadHandle:wait
do
    local t = lurek.thread.newThread("return 1")
    t:start()
    t:wait()
    print("LThreadHandle:wait ok")
end

--@api: LThreadHandle:isRunning
do
    local t = lurek.thread.newThread("return 1")
    t:start()
    print("LThreadHandle:isRunning = " .. tostring(t:isRunning()))
end

--@api: LThreadHandle:getError
do
    local t = lurek.thread.newThread("return 1")
    t:start()
    t:wait()
    print("LThreadHandle:getError = " .. tostring(t:getError()))
end

--@api: LThreadHandle:type
do
    local t = lurek.thread.newThread("return 1")
    print("LThreadHandle:type = " .. t:type())
end

--@api: LThreadHandle:typeOf
do
    local t = lurek.thread.newThread("return 1")
    print("LThreadHandle:typeOf = " .. tostring(t:typeOf("LThread")))
end
