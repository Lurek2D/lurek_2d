--- Thread Module Part 1: LChannel, LThread, newBoundedChannel, newPool, newChannel, newThread

--@api-stub: LChannel:getCapacity
--@api-stub: LChannel:isBounded
--@api-stub: LChannel:type
--@api-stub: LChannel:typeOf
-- Channel full API coverage: push/pop variants, supply, demand, capacity, count, type.
do
    local ch = lurek.thread.newChannel()
    print("bounded=" .. tostring(ch:isBounded()))
    print("capacity=" .. tostring(ch:getCapacity()))
    print("count=" .. ch:getCount())

    ch:push("hello")
    local peeked = ch:peek()
    print("peeked=" .. tostring(peeked))
    local popped = ch:pop()
    print("popped=" .. tostring(popped))

    ch:pushTable({ a = 1, b = 2 })
    local t = ch:popTable()
    print("table=" .. tostring(t ~= nil))

    ch:pushBytes("raw_data")
    local raw = ch:popBytes()
    print("bytes=" .. tostring(raw ~= nil))

    ch:supply("supplied_value")
    local demanded = ch:demand(100)
    print("demanded=" .. tostring(demanded))

    local ok = ch:tryPush("try_value")
    print("try_push=" .. tostring(ok))

    ch:clear()
    print("count_after_clear=" .. ch:getCount())

    print("type=" .. ch:type())
    print("typeOf=" .. tostring(ch:typeOf("LChannel")))
end

--@api-stub: LThread:getError
--@api-stub: LThread:isRunning
--@api-stub: LThread:start
--@api-stub: LThread:type
--@api-stub: LThread:typeOf
-- Thread lifecycle, start, error, and type introspection.
do
    local code = [[
        local ch = lurek.thread.newChannel()
        local msg = ch:pop()
    ]]
    local t = lurek.thread.newThread(code)
    t:start()
    local running = t:isRunning()
    print("running=" .. tostring(running))
    local err = t:getError()
    print("error=" .. tostring(err))
    print("type=" .. t:type())
    print("typeOf=" .. tostring(t:typeOf("LThread")))
end

print("thread_01.lua")
