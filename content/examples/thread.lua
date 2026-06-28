-- content/examples/thread.lua
-- Auto-generated from content/examples2/thread_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/thread.lua




--- Thread Module: channels, threads, pools, promises, async, worker capabilities

--@api: lurek.thread.newChannel
do
    local channel = lurek.thread.newChannel()
    channel:push("spawn_enemy")
    local type_name = channel:type()
    local count = channel:getCount()
    lurek.log.info("[thread] new channel type=" .. type_name .. " count=" .. count .. " bounded=" .. tostring(channel:isBounded()))
end

--@api: lurek.thread.newBoundedChannel
do
    local channel = lurek.thread.newBoundedChannel(10)
    channel:push("frame_1")
    local bounded = channel:isBounded()
    local capacity = channel:getCapacity()
    lurek.log.info("[thread] bounded channel bounded=" .. tostring(bounded) .. " capacity=" .. capacity .. " count=" .. channel:getCount())
end

--@api: LChannel:push
do
    local channel = lurek.thread.newChannel()
    local id = channel:push("quest_started")
    local queued = channel:getCount()
    local preview = channel:peek()
    lurek.log.info("[thread] push queued id=" .. id .. " count=" .. queued .. " preview=" .. tostring(preview))
end

--@api: LChannel:pop
do
    local channel = lurek.thread.newChannel()
    channel:push("hello")
    channel:push("world")
    local first = channel:pop()
    local remaining = channel:getCount()
    lurek.log.info("[thread] pop first=" .. tostring(first) .. " remaining=" .. remaining)
end

--@api: LChannel:peek
do
    local channel = lurek.thread.newChannel()
    channel:push("first")
    channel:push("second")
    local preview = channel:peek()
    local count = channel:getCount()
    lurek.log.info("[thread] peek saw=" .. tostring(preview) .. " while count stayed=" .. count)
end

--@api: LChannel:demand
do
    local channel = lurek.thread.newChannel()
    channel:push("ready")
    local immediate = channel:demand(1.0)
    local timeout = channel:demand(0.01)
    lurek.log.info("[thread] demand immediate=" .. tostring(immediate) .. " timeout=" .. tostring(timeout))
end

--@api: LChannel:supply
do
    local channel = lurek.thread.newBoundedChannel(2)
    channel:tryPush("a")
    channel:tryPush("b")
    local ok = channel:supply("c")
    local count = channel:getCount()
    lurek.log.info("[thread] supply when full=" .. tostring(ok) .. " queued=" .. count)
end

--@api: LChannel:tryPush
do
    local channel = lurek.thread.newBoundedChannel(2)
    local first = channel:tryPush("a")
    local second = channel:tryPush("b")
    local third = channel:tryPush("c")
    lurek.log.info("[thread] tryPush results=" .. tostring(first) .. "," .. tostring(second) .. "," .. tostring(third))
end

--@api: LChannel:pushBytes
do
    local channel = lurek.thread.newChannel()
    local payload = string.rep("\x00\xFF", 100)
    local id = channel:pushBytes(payload)
    local count = channel:getCount()
    lurek.log.info("[thread] pushBytes id=" .. id .. " bytes=" .. #payload .. " count=" .. count)
end

--@api: LChannel:popBytes
do
    local channel = lurek.thread.newChannel()
    channel:pushBytes(string.rep("\x00\xFF", 100))
    local payload = channel:popBytes()
    local size = #payload
    lurek.log.info("[thread] popBytes length=" .. size .. " remaining=" .. channel:getCount())
end

--@api: LChannel:pushTable
do
    local channel = lurek.thread.newChannel()
    local payload = { name = "player", hp = 100, items = { "sword", "shield" } }
    local id = channel:pushTable(payload)
    local preview = channel:peek()
    lurek.log.info("[thread] pushTable id=" .. id .. " preview_name=" .. tostring(preview.name))
end

--@api: LChannel:popTable
do
    local channel = lurek.thread.newChannel()
    channel:pushTable({ name = "player", hp = 100 })
    local result = channel:popTable()
    local hp = result.hp
    lurek.log.info("[thread] popTable name=" .. result.name .. " hp=" .. hp)
end

--@api: LChannel:clear
do
    local channel = lurek.thread.newChannel()
    channel:push("x")
    channel:push("y")
    local before = channel:getCount()
    channel:clear()
    lurek.log.info("[thread] clear removed queue from " .. before .. " to " .. channel:getCount())
end

--@api: LChannel:getCount
do
    local channel = lurek.thread.newChannel()
    channel:push("x")
    channel:push("y")
    local count = channel:getCount()
    local preview = channel:peek()
    lurek.log.info("[thread] getCount reports " .. count .. " next=" .. tostring(preview))
end

--@api: lurek.thread.getChannel
do
    local events = lurek.thread.getChannel("events")
    events:clear()
    events:push("player_died")
    local same = lurek.thread.getChannel("events")
    local message = same:pop()
    lurek.log.info("[thread] shared channel message=" .. tostring(message) .. " same_instance=" .. tostring(events == same))
end

--@api: lurek.thread.newThread
do
    local results = lurek.thread.getChannel("thread_results")
    results:clear()
    local thread = lurek.thread.newThread([[
        local ch = lurek.thread.getChannel("thread_results")
        ch:push(21 * 2)
    ]])
    thread:start()
    thread:wait()
    lurek.log.info("[thread] newThread result=" .. tostring(results:pop()))
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
    local type_name = pool:type()
    local size = pool:size()
    local matches = pool:typeOf("LThreadPool")
    lurek.log.info("[thread] new pool type=" .. type_name .. " workers=" .. size .. " matches=" .. tostring(matches))
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
    local queued = pool:getInputChannel():getCount()
    local workers = pool:size()
    lurek.log.info("[thread] submit queued=" .. queued .. " workers=" .. workers)
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
    local result = pool:collect()
    lurek.log.info("[thread] collect returned=" .. tostring(result))
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
    local input = pool:getInputChannel()
    pool:submit(7)
    local count = input:getCount()
    lurek.log.info("[thread] input channel type=" .. input:type() .. " count=" .. count)
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
    local output = pool:getOutputChannel()
    pool:submit(5)
    pool:join(1.0)
    local preview = output:peek()
    lurek.log.info("[thread] output channel type=" .. output:type() .. " preview=" .. tostring(preview))
end

--@api: LThreadPool:join
do
    local pool = lurek.thread.newPool(2, [[
        local input = lurek.thread.getChannel("__pool_input")
        local output = lurek.thread.getChannel("__pool_output")
        local value = input:demand(0.1)
        if value then
            output:push(value * 2)
        end
    ]])
    pool:submit(8)
    local joined = pool:join(2.0)
    local collected = pool:collect()
    lurek.log.info("[thread] join result=" .. tostring(joined) .. " collected=" .. tostring(collected))
end

--@api: lurek.thread.async
do
    local promise = lurek.thread.async("lurek.thread.getChannel('__promise_result'):push(42)")
    local type_name = promise:type()
    local done = promise:isDone()
    local result = promise:result()
    lurek.log.info("[thread] async promise type=" .. type_name .. " done=" .. tostring(done) .. " result=" .. tostring(result))
end

--@api: LPromise:result
do
    local promise = lurek.thread.async("lurek.thread.getChannel('__promise_result'):push(42)")
    local type_name = promise:type()
    local result = promise:result()
    local done = promise:isDone()
    lurek.log.info("[thread] promise type=" .. type_name .. " result=" .. tostring(result) .. " done=" .. tostring(done))
end

--@api: LPromise:isDone
do
    local promise = lurek.thread.async("lurek.thread.getChannel('__promise_result'):push(42)")
    local before = promise:isDone()
    local result = promise:result()
    local after = promise:isDone()
    lurek.log.info("[thread] promise isDone before=" .. tostring(before) .. " after=" .. tostring(after) .. " result=" .. tostring(result))
end

--@api: LPromise:getError
do
    local promise = lurek.thread.async("lurek.thread.getChannel('__promise_result'):push(42)")
    local done = promise:isDone()
    local result = promise:result()
    local error_message = promise:getError()
    lurek.log.info("[thread] promise done_before=" .. tostring(done) .. " result=" .. tostring(result) .. " error=" .. tostring(error_message))
end

--@api: LPromise:chain
do
    local first = lurek.thread.async("lurek.thread.getChannel('__promise_result'):push(10)")
    while not first:isDone() do
    end
    local second = first:chain("lurek.thread.getChannel('__promise_result'):push((arg[1] or 0) * 3)")
    while not second:isDone() do
    end
    local result = second:result()
    local done = second:isDone()
    lurek.log.info("[thread] promise chain result=" .. tostring(result) .. " done=" .. tostring(done))
end

--@api: lurek.thread.getWorkerCapabilities
do
    local caps = lurek.thread.getWorkerCapabilities()
    local first = caps[1] or "none"
    local count = #caps
    local has_thread = count > 0
    lurek.log.info("[thread] worker capabilities count=" .. count .. " first=" .. first .. " available=" .. tostring(has_thread))
end

--- Thread Module Part 1: LChannel, LThread, newBoundedChannel, newPool, newChannel, newThread

--@api: LChannel:getCapacity
do
    local channel = lurek.thread.newBoundedChannel(3)
    channel:push("job")
    local capacity = channel:getCapacity()
    local bounded = channel:isBounded()
    lurek.log.info("[thread] bounded channel capacity=" .. tostring(capacity) .. " count=" .. channel:getCount() .. " bounded=" .. tostring(bounded))
end

--@api: LChannel:isBounded
do
    local channel = lurek.thread.newBoundedChannel(1)
    channel:push("job")
    local bounded = channel:isBounded()
    local count = channel:getCount()
    lurek.log.info("[thread] channel bounded=" .. tostring(bounded) .. " capacity=" .. tostring(channel:getCapacity()) .. " count=" .. count)
end

--@api: LChannel:type
do
    local channel = lurek.thread.newChannel()
    channel:push("job")
    local type_name = channel:type()
    local bounded = channel:isBounded()
    lurek.log.info("[thread] channel type=" .. type_name .. " count=" .. channel:getCount() .. " bounded=" .. tostring(bounded))
end

--@api: LChannel:typeOf
do
    local channel = lurek.thread.newChannel()
    channel:push("job")
    local matches = channel:typeOf("LChannel")
    local type_name = channel:type()
    lurek.log.info("[thread] channel typeOf LChannel=" .. tostring(matches) .. " type=" .. type_name)
end

--@api: LThread:getError
do
    local status = lurek.thread.getChannel("thread_status")
    status:clear()
    local thread = lurek.thread.newThread([[lurek.thread.getChannel("thread_status"):push("done")]])
    thread:start()
    thread:wait()
    lurek.log.info("[thread] thread error=" .. tostring(thread:getError()) .. " status=" .. tostring(status:pop()))
end

--@api: LThread:isRunning
do
    local thread = lurek.thread.newThread("return 1")
    local before = thread:isRunning()
    thread:start()
    thread:wait()
    local after = thread:isRunning()
    lurek.log.info("[thread] thread running before=" .. tostring(before) .. " after=" .. tostring(after))
end

--@api: LThread:start
do
    local results = lurek.thread.getChannel("thread_start_results")
    results:clear()
    local thread = lurek.thread.newThread([[lurek.thread.getChannel("thread_start_results"):push("started")]])
    thread:start()
    thread:wait()
    lurek.log.info("[thread] thread start pushed=" .. tostring(results:pop()))
end

--@api: LThread:type
do
    local thread = lurek.thread.newThread("return 1")
    local type_name = thread:type()
    local matches = thread:typeOf("LThread")
    local running = thread:isRunning()
    lurek.log.info("[thread] thread type=" .. type_name .. " matches=" .. tostring(matches) .. " running=" .. tostring(running))
end

--@api: LThread:typeOf
do
    local thread = lurek.thread.newThread("return 1")
    local is_thread = thread:typeOf("LThread")
    local is_handle = thread:typeOf("LThreadHandle")
    local type_name = thread:type()
    lurek.log.info("[thread] thread typeOf LThread=" .. tostring(is_thread) .. " handle=" .. tostring(is_handle) .. " type=" .. type_name)
end

--@api: LPromise:type
do
    local promise = lurek.thread.async("lurek.thread.getChannel('__promise_result'):push(42)")
    local type_name = promise:type()
    local result = promise:result()
    local done = promise:isDone()
    lurek.log.info("[thread] promise type=" .. type_name .. " result=" .. tostring(result) .. " done=" .. tostring(done))
end

--@api: LPromise:typeOf
do
    local promise = lurek.thread.async("lurek.thread.getChannel('__promise_result'):push(42)")
    local is_promise = promise:typeOf("LPromise")
    local result = promise:result()
    local type_name = promise:type()
    lurek.log.info("[thread] promise typeOf=" .. tostring(is_promise) .. " result=" .. tostring(result) .. " type=" .. type_name)
end

--@api: LThread:wait
do
    local results = lurek.thread.getChannel("thread_wait_results")
    results:clear()
    local thread = lurek.thread.newThread([[lurek.thread.getChannel("thread_wait_results"):push(42)]])
    thread:start()
    thread:wait()
    lurek.log.info("[thread] thread wait result=" .. tostring(results:pop()))
end

--@api: LThreadPool:size
do
    local pool = lurek.thread.newPool(2, [[
        local input = lurek.thread.getChannel("__pool_input")
        local output = lurek.thread.getChannel("__pool_output")
        local value = input:demand(0.1)
        if value then
            output:push(value * 2)
        end
    ]])
    pool:submit(3)
    local size = pool:size()
    local input_count = pool:getInputChannel():getCount()
    lurek.log.info("[thread] thread pool size=" .. size .. " queued=" .. input_count)
end

--@api: LThreadPool:type
do
    local pool = lurek.thread.newPool(2, [[
        local input = lurek.thread.getChannel("__pool_input")
        local output = lurek.thread.getChannel("__pool_output")
        local value = input:demand(0.1)
        if value then
            output:push(value * 2)
        end
    ]])
    pool:submit(3)
    local type_name = pool:type()
    local matches = pool:typeOf("LThreadPool")
    lurek.log.info("[thread] thread pool type=" .. type_name .. " size=" .. pool:size() .. " matches=" .. tostring(matches))
end

--@api: LThreadPool:typeOf
do
    local pool = lurek.thread.newPool(2, [[
        local input = lurek.thread.getChannel("__pool_input")
        local output = lurek.thread.getChannel("__pool_output")
        local value = input:demand(0.1)
        if value then
            output:push(value * 2)
        end
    ]])
    local matches = pool:typeOf("LThreadPool")
    pool:submit(4)
    local size = pool:size()
    lurek.log.info("[thread] thread pool typeOf LThreadPool=" .. tostring(matches) .. " size=" .. size)
end

--@api: LThreadHandle:start
do
    local results = lurek.thread.getChannel("thread_handle_start")
    results:clear()
    local thread = lurek.thread.newThread([[lurek.thread.getChannel("thread_handle_start"):push("ok")]])
    thread:start()
    thread:wait()
    lurek.log.info("[thread] thread handle start pushed=" .. tostring(results:pop()))
end

--@api: LThreadHandle:wait
do
    local results = lurek.thread.getChannel("thread_handle_wait")
    results:clear()
    local thread = lurek.thread.newThread([[lurek.thread.getChannel("thread_handle_wait"):push(99)]])
    thread:start()
    thread:wait()
    lurek.log.info("[thread] thread handle wait result=" .. tostring(results:pop()))
end

--@api: LThreadHandle:isRunning
do
    local thread = lurek.thread.newThread("return 1")
    local before = thread:isRunning()
    thread:start()
    thread:wait()
    local after = thread:isRunning()
    lurek.log.info("[thread] thread handle running before=" .. tostring(before) .. " after=" .. tostring(after))
end

--@api: LThreadHandle:getError
do
    local thread = lurek.thread.newThread("return 1")
    thread:start()
    thread:wait()
    local error_message = thread:getError()
    lurek.log.info("[thread] thread handle error=" .. tostring(error_message))
end

--@api: LThreadHandle:type
do
    local thread = lurek.thread.newThread("return 1")
    local type_name = thread:type()
    local matches = thread:typeOf("LThread")
    local running = thread:isRunning()
    lurek.log.info("[thread] thread handle type=" .. type_name .. " matches=" .. tostring(matches) .. " running=" .. tostring(running))
end

--@api: LThreadHandle:typeOf
do
    local thread = lurek.thread.newThread("return 1")
    local is_thread = thread:typeOf("LThread")
    local is_handle = thread:typeOf("LThreadHandle")
    local type_name = thread:type()
    lurek.log.info("[thread] thread handle typeOf LThread=" .. tostring(is_thread) .. " handle=" .. tostring(is_handle) .. " type=" .. type_name)
end
