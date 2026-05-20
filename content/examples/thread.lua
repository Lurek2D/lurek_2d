-- content/examples/thread.lua
-- Auto-generated from content/examples2/thread_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/thread.lua

--- Thread Module: channels, threads, pools, promises, async, worker capabilities


--@api-stub: lurek.thread.newChannel
do
    local ch = lurek.thread.newChannel()
    print("type = " .. ch:type())
    print("count = " .. ch:getCount())
    print("bounded = " .. tostring(ch:isBounded()))
end

--@api-stub: lurek.thread.newBoundedChannel
do
    ---@type LChannel
    local ch = lurek.thread.newBoundedChannel(10)
    print("bounded = " .. tostring(ch:isBounded()))
    print("capacity = " .. ch:getCapacity())
    print("count = " .. ch:getCount())
end

--@api-stub: LChannel:push
do
    ---@type LChannel
    local ch = lurek.thread.newChannel()
    local id1 = ch:push("hello")
    print("pushed id: " .. id1)
    print("count = " .. ch:getCount())
end

--@api-stub: LChannel:pop
do
    ---@type LChannel
    local ch = lurek.thread.newChannel()
    ch:push("hello")
    local val1 = ch:pop()
    print("pop 1 = " .. tostring(val1))
end

--@api-stub: LChannel:peek
do
    local ch = lurek.thread.newChannel()
    ch:push("first")
    print("peek = " .. tostring(ch:peek()))
    print("count after peek = " .. ch:getCount())
end

--@api-stub: LChannel:demand
do
    local ch = lurek.thread.newChannel()
    ch:push("ready")
    print("demand got = " .. tostring(ch:demand(1.0)))
    print("demand timeout = " .. tostring(ch:demand(0.01)))
end

--@api-stub: LChannel:supply
do
    local ch = lurek.thread.newBoundedChannel(2)
    ch:tryPush("a")
    ch:tryPush("b")
    print("supply when full = " .. tostring(ch:supply("d")))
end

--@api-stub: LChannel:tryPush
do
    ---@type LChannel
    local ch = lurek.thread.newBoundedChannel(2)
    local ok1 = ch:tryPush("a")
    print("tryPush 1 = " .. tostring(ok1))
end

--@api-stub: LChannel:pushBytes
do
    ---@type LChannel
    local ch = lurek.thread.newChannel()
    local data = string.rep("\x00\xFF", 100)
    local id = ch:pushBytes(data)
    print("pushBytes id = " .. id)
end

--@api-stub: LChannel:popBytes
do
    local ch = lurek.thread.newChannel()
    ch:pushBytes(string.rep("\x00\xFF", 100))
    print("popBytes length = " .. #ch:popBytes())
end

--@api-stub: LChannel:pushTable
do
    ---@type LChannel
    local ch = lurek.thread.newChannel()
    local payload = { name = "player", hp = 100, items = { "sword", "shield" } }
    local id = ch:pushTable(payload)
    print("pushTable id = " .. id)
end

--@api-stub: LChannel:popTable
do
    local ch = lurek.thread.newChannel()
    ch:pushTable({ name = "player" })
    local result = ch:popTable()
    print("popTable name = " .. result.name)
end

--@api-stub: LChannel:clear
do
    local ch = lurek.thread.newChannel()
    ch:push("x")
    print("before clear = " .. ch:getCount())
    ch:clear()
    print("after clear = " .. ch:getCount())
end

--@api-stub: LChannel:getCount
do
    local ch = lurek.thread.newChannel()
    ch:push("x")
    print("count = " .. ch:getCount())
end

--@api-stub: lurek.thread.getChannel
do
    local ch = lurek.thread.getChannel("events")
    ch:push("player_died")
    local same = lurek.thread.getChannel("events")
    print("shared channel msg = " .. tostring(same:pop()))
    print("same instance = " .. tostring(ch == same))
end

--@api-stub: lurek.thread.newThread
do
    local results = lurek.thread.getChannel("results")
    results:clear()
    local thread = lurek.thread.newThread([[ local ch = lurek.thread.getChannel("results"); ch:push(21 * 2) ]])
    thread:start(); thread:wait()
    print("result = " .. tostring(results:pop()))
end

--@api-stub: lurek.thread.newPool

do
    local pool = lurek.thread.newPool(2, "local i=lurek.thread.getChannel('__pool_input');local o=lurek.thread.getChannel('__pool_output');local v=i:demand(0.1);if v then o:push(v*2) end")
    print("type = " .. pool:type())
    print("pool size = " .. pool:size())
end

--@api-stub: LThreadPool:submit
do
    local pool = lurek.thread.newPool(2, "local i=lurek.thread.getChannel('__pool_input');local o=lurek.thread.getChannel('__pool_output');local v=i:demand(0.1);if v then o:push(v*2) end")
    pool:submit(10)
    print("submitted one task")
end

--@api-stub: LThreadPool:collect
do
    local pool = lurek.thread.newPool(2, "local i=lurek.thread.getChannel('__pool_input');local o=lurek.thread.getChannel('__pool_output');local v=i:demand(0.1);if v then o:push(v*2) end")
    pool:submit(10)
    print("collected = " .. tostring(pool:collect()))
end

--@api-stub: LThreadPool:getInputChannel
do
    local pool = lurek.thread.newPool(2, "local i=lurek.thread.getChannel('__pool_input');local o=lurek.thread.getChannel('__pool_output');local v=i:demand(0.1);if v then o:push(v*2) end")
    local inCh = pool:getInputChannel()
    print("input channel type = " .. inCh:type())
end

--@api-stub: LThreadPool:getOutputChannel
do
    local pool = lurek.thread.newPool(2, "local i=lurek.thread.getChannel('__pool_input');local o=lurek.thread.getChannel('__pool_output');local v=i:demand(0.1);if v then o:push(v*2) end")
    local outCh = pool:getOutputChannel()
    print("output channel type = " .. outCh:type())
end

--@api-stub: LThreadPool:join
do
    local pool = lurek.thread.newPool(2, "return nil")
    print("join result = " .. tostring(pool:join(2.0)))
end

--@api-stub: lurek.thread.async
do
    local promise = lurek.thread.async("return 42")
    print("type = " .. promise:type())
    print("done immediately = " .. tostring(promise:isDone()))
end

--@api-stub: LPromise:result
do
    local promise = lurek.thread.async("return 42")
    print("result = " .. tostring(promise:result()))
end

--@api-stub: LPromise:isDone
do
    local promise = lurek.thread.async("return 42")
    promise:result()
    print("done = " .. tostring(promise:isDone()))
end

--@api-stub: LPromise:getError
do
    local promise = lurek.thread.async("return 42")
    promise:result()
    print("error = " .. tostring(promise:getError()))
end

--@api-stub: LPromise:chain
do
    local first = lurek.thread.async([[ return 10 ]])
    while not first:isDone() do end
    local second = first:chain([[ local prev = ...; return prev * 3 ]])
    while not second:isDone() do end
    print("chain result = " .. tostring(second:result()))
end

--@api-stub: lurek.thread.getWorkerCapabilities
do
    local caps = lurek.thread.getWorkerCapabilities()
    print("capabilities = " .. #caps)
end

--- Thread Module Part 1: LChannel, LThread, newBoundedChannel, newPool, newChannel, newThread


--@api-stub: LChannel:getCapacity
do
    local ch = lurek.thread.newChannel()
    print("capacity=" .. tostring(ch:getCapacity()))
end

--@api-stub: LChannel:isBounded
do
    local ch = lurek.thread.newChannel()
    print("bounded=" .. tostring(ch:isBounded()))
end

--@api-stub: LChannel:type
do
    local ch = lurek.thread.newChannel()
    print("type=" .. ch:type())
end

--@api-stub: LChannel:typeOf
do
    local ch = lurek.thread.newChannel()
    print("typeOf=" .. tostring(ch:typeOf("LChannel")))
end

--@api-stub: LThread:getError
do
    local t = lurek.thread.newThread("lurek.thread.getChannel('thread_status'):push('done')")
    t:start(); t:wait()
    print("error=" .. tostring(t:getError()))
end

--@api-stub: LThread:isRunning
do
    local t = lurek.thread.newThread("return 1")
    t:start()
    print("running=" .. tostring(t:isRunning()))
end

--@api-stub: LThread:start
do
    local t = lurek.thread.newThread("return 1")
    t:start()
    print("start ok")
end

--@api-stub: LThread:type
do
    local t = lurek.thread.newThread("return 1")
    print("type=" .. t:type())
end

--@api-stub: LThread:typeOf
do
    local t = lurek.thread.newThread("return 1")
    print("typeOf=" .. tostring(t:typeOf("LThread")))
end

--@api-stub: LPromise:type
do
    local p = lurek.thread.async("return 42")
    local t = p:type()
    print("LPromise type:", t)
end

--@api-stub: LPromise:typeOf
do
    local p = lurek.thread.async("return 42")
    local ok = p:typeOf("LPromise")
    print("LPromise typeOf:", ok)
end

--@api-stub: LThread:wait
do
    local thread = lurek.thread.newThread("return 'done'")
    thread:start()
    thread:wait()
    print("LThread:wait ok")
end

--@api-stub: LThreadPool:size
do
    local pool = lurek.thread.newPool(3, "return require 'lurek'.thread and 'ok' or 'ok'")
    local sz = pool:size()
    print("pool size:", sz)
end

--@api-stub: LThreadPool:type
do
    local pool = lurek.thread.newPool(3, "return require 'lurek'.thread and 'ok' or 'ok'")
    local t = pool:type()
    print("type:", t)
end

--@api-stub: LThreadPool:typeOf
do
    local pool = lurek.thread.newPool(3, "return require 'lurek'.thread and 'ok' or 'ok'")
    local ok = pool:typeOf("LThreadPool")
    print("typeOf:", ok)
end

print("content/examples/thread.lua")
