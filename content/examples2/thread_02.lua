--@api-stub: LPromise:type
--@api-stub: LPromise:typeOf
--@api-stub: LThread:wait
-- LPromise type checks and LThread wait.
do
    local p = lurek.thread.async("return 42")
    local t = p:type()
    local ok = p:typeOf("LPromise")
    local thread = lurek.thread.newThread("return 'done'")
    thread:start()
    thread:wait()
    print("LPromise type:", t, "typeOf:", ok, "LThread:wait ok")
end

--@api-stub: LThreadPool:size
--@api-stub: LThreadPool:type
--@api-stub: LThreadPool:typeOf
-- LThreadPool size and type checks.
do
    local pool = lurek.thread.newPool(3, "return require 'lurek'.thread and 'ok' or 'ok'")
    local sz = pool:size()
    local t = pool:type()
    local ok = pool:typeOf("LThreadPool")
    print("pool size:", sz, "type:", t, "typeOf:", ok)
end
