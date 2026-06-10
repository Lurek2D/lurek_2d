-- tests/lua/unit/test_thread_core_unit.lua
-- Canonical unit coverage for lurek.thread and related userdata APIs.

local function await_promise(promise)
    local spins = 0
    while not promise:isDone() and spins < 10000 do
        if lurek.timer and lurek.timer.sleep then
            lurek.timer.sleep(0.001)
        end
        spins = spins + 1
    end
    expect_true(promise:isDone())
end

local function new_pool()
    return lurek.thread.newPool(2, [[
        local input = lurek.thread.getChannel("__pool_input")
        local output = lurek.thread.getChannel("__pool_output")
        local value = input:demand(0.1)
        if value ~= nil then
            output:push(value * 2)
        end
    ]])
end

-- @describe lurek.thread functions
describe("lurek.thread functions", function()
    -- @covers lurek.thread.async
    it("async returns a promise for Lua code", function()
        local promise = lurek.thread.async("lurek.thread.getChannel('__promise_result'):push(42)")
        expect_not_nil(promise)
        expect_type("function", promise.result)
    end)

    -- @covers lurek.thread.getChannel
    it("getChannel returns the same named channel across calls", function()
        local first = lurek.thread.getChannel("thread_unit_named")
        local second = lurek.thread.getChannel("thread_unit_named")
        first:clear()
        first:push("hello")
        expect_equal("hello", second:pop())
    end)

    -- @covers lurek.thread.getWorkerCapabilities
    it("getWorkerCapabilities returns a non-empty capability list", function()
        local caps = lurek.thread.getWorkerCapabilities()
        expect_type("table", caps)
        expect_true(#caps >= 1)
    end)

    -- @covers lurek.thread.newBoundedChannel
    it("newBoundedChannel creates a bounded channel with fixed capacity", function()
        local channel = lurek.thread.newBoundedChannel(2)
        expect_true(channel:isBounded())
        expect_equal(2, channel:getCapacity())
    end)

    -- @covers lurek.thread.newChannel
    it("newChannel creates an unbounded empty channel", function()
        local channel = lurek.thread.newChannel()
        expect_equal(0, channel:getCount())
        expect_false(channel:isBounded())
    end)

    -- @covers lurek.thread.newPool
    it("newPool returns a thread pool handle", function()
        local pool = new_pool()
        expect_not_nil(pool)
        expect_equal(2, pool:size())
    end)

    -- @covers lurek.thread.newThread
    it("newThread creates a thread handle without starting it", function()
        local thread = lurek.thread.newThread("return 42")
        expect_not_nil(thread)
        expect_false(thread:isRunning())
    end)
end)

-- @describe LChannel methods
describe("LChannel methods", function()
    -- @covers LChannel:clear
    it("clear removes all queued values", function()
        local channel = lurek.thread.newChannel()
        channel:push("a")
        channel:push("b")
        channel:clear()
        expect_equal(0, channel:getCount())
        expect_nil(channel:pop())
    end)

    -- @covers LChannel:demand
    it("demand returns an already queued value immediately", function()
        local channel = lurek.thread.newChannel()
        channel:push("ready")
        expect_equal("ready", channel:demand(0.0))
    end)

    -- @covers LChannel:getCapacity
    it("getCapacity returns nil for unbounded channels", function()
        local channel = lurek.thread.newChannel()
        expect_nil(channel:getCapacity())
    end)

    -- @covers LChannel:getCount
    it("getCount tracks queue length", function()
        local channel = lurek.thread.newChannel()
        channel:push("x")
        channel:push("y")
        expect_equal(2, channel:getCount())
    end)

    -- @covers LChannel:isBounded
    it("isBounded distinguishes bounded channels", function()
        local channel = lurek.thread.newBoundedChannel(1)
        expect_true(channel:isBounded())
    end)

    -- @covers LChannel:peek
    it("peek reads the next value without removing it", function()
        local channel = lurek.thread.newChannel()
        channel:push("peek_me")
        expect_equal("peek_me", channel:peek())
        expect_equal("peek_me", channel:pop())
    end)

    -- @covers LChannel:pop
    it("pop removes values in FIFO order", function()
        local channel = lurek.thread.newChannel()
        channel:push(1)
        channel:push(2)
        expect_equal(1, channel:pop())
        expect_equal(2, channel:pop())
    end)

    -- @covers LChannel:popBytes
    it("popBytes returns a pushed byte string", function()
        local channel = lurek.thread.newChannel()
        local bytes = "binary\0payload\255"
        channel:pushBytes(bytes)
        expect_equal(#bytes, #channel:popBytes())
    end)

    -- @covers LChannel:popTable
    it("popTable returns a pushed Lua table", function()
        local channel = lurek.thread.newChannel()
        channel:pushTable({ x = 10, y = 20 })
        local value = channel:popTable()
        expect_not_nil(value)
        expect_equal(10, value.x)
        expect_equal(20, value.y)
    end)

    -- @covers LChannel:push
    it("push round-trips scalar values", function()
        local channel = lurek.thread.newChannel()
        channel:push(42)
        expect_equal(42, channel:pop())
    end)

    -- @covers LChannel:pushBytes
    it("pushBytes increments the channel count", function()
        local channel = lurek.thread.newChannel()
        channel:pushBytes("hello")
        expect_equal(1, channel:getCount())
    end)

    -- @covers LChannel:pushTable
    it("pushTable preserves nested table content", function()
        local channel = lurek.thread.newChannel()
        channel:pushTable({ items = { "sword", "shield" } })
        local value = channel:popTable()
        expect_equal("sword", value.items[1])
        expect_equal("shield", value.items[2])
    end)

    -- @covers LChannel:supply
    it("supply returns false when a bounded channel is already full", function()
        local channel = lurek.thread.newBoundedChannel(2)
        expect_true(channel:tryPush("a"))
        expect_true(channel:tryPush("b"))
        expect_false(channel:supply("c"))
    end)

    -- @covers LChannel:tryPush
    it("tryPush returns false when capacity is exhausted", function()
        local channel = lurek.thread.newBoundedChannel(1)
        expect_true(channel:tryPush("a"))
        expect_false(channel:tryPush("b"))
    end)

    -- @covers LChannel:type
    it("type returns the channel userdata name", function()
        local channel = lurek.thread.newChannel()
        expect_equal("LChannel", channel:type())
    end)

    -- @covers LChannel:typeOf
    it("typeOf accepts the channel type name", function()
        local channel = lurek.thread.newChannel()
        expect_true(channel:typeOf("LChannel"))
    end)
end)

-- @describe LPromise methods
describe("LPromise methods", function()
    -- @covers LPromise:chain
    it("chain creates a follow-up promise using the previous result", function()
        local first = lurek.thread.async("lurek.thread.getChannel('__promise_result'):push(10)")
        await_promise(first)
        local second = first:chain(
            "lurek.thread.getChannel('__promise_result'):push((arg[1] or 0) + 5)"
        )
        await_promise(second)
        expect_equal(15, second:result())
    end)

    -- @covers LPromise:getError
    it("getError returns nil for a successful promise", function()
        local promise = lurek.thread.async("lurek.thread.getChannel('__promise_result'):push(42)")
        await_promise(promise)
        expect_nil(promise:getError())
    end)

    -- @covers LPromise:isDone
    it("isDone becomes true after the promise completes", function()
        local promise = lurek.thread.async("lurek.thread.getChannel('__promise_result'):push(42)")
        await_promise(promise)
        expect_true(promise:isDone())
    end)

    -- @covers LPromise:result
    it("result returns the resolved promise value", function()
        local promise = lurek.thread.async("lurek.thread.getChannel('__promise_result'):push(42)")
        await_promise(promise)
        expect_equal(42, promise:result())
    end)

    -- @covers LPromise:type
    it("type returns the promise userdata name", function()
        local promise = lurek.thread.async("lurek.thread.getChannel('__promise_result'):push(42)")
        expect_equal("LPromise", promise:type())
    end)

    -- @covers LPromise:typeOf
    it("typeOf accepts the promise type name", function()
        local promise = lurek.thread.async("lurek.thread.getChannel('__promise_result'):push(42)")
        expect_true(promise:typeOf("LPromise"))
    end)
end)

-- @describe LThreadHandle methods
describe("LThreadHandle methods", function()
    -- @covers LThreadHandle:getError
    it("getError stays nil after a successful thread run", function()
        local thread = lurek.thread.newThread("return 1")
        thread:start()
        thread:wait()
        expect_nil(thread:getError())
    end)

    -- @covers LThreadHandle:isRunning
    it("isRunning is false before start", function()
        local thread = lurek.thread.newThread("return 1")
        expect_false(thread:isRunning())
    end)

    -- @covers LThreadHandle:start
    it("start launches a trivial thread without error", function()
        local thread = lurek.thread.newThread("return 1")
        expect_no_error(function()
            thread:start()
            thread:wait()
        end)
    end)

    -- @covers LThreadHandle:wait
    it("wait blocks until a started thread completes", function()
        local results = lurek.thread.getChannel("thread_wait_results")
        results:clear()
        local thread = lurek.thread.newThread([[
            lurek.thread.getChannel("thread_wait_results"):push(21 * 2)
        ]])
        thread:start()
        thread:wait()
        expect_equal(42, results:pop())
    end)
end)

-- @describe LThreadPool methods
describe("LThreadPool methods", function()
    -- @covers LThreadPool:collect
    it("collect returns a worker result after submit and join", function()
        local pool = new_pool()
        pool:submit(10)
        pool:join(1.0)
        expect_equal(20, pool:collect())
    end)

    -- @covers LThreadPool:getInputChannel
    it("getInputChannel returns a channel handle", function()
        local pool = new_pool()
        local channel = pool:getInputChannel()
        expect_equal("LChannel", channel:type())
    end)

    -- @covers LThreadPool:getOutputChannel
    it("getOutputChannel returns a channel handle", function()
        local pool = new_pool()
        local channel = pool:getOutputChannel()
        expect_equal("LChannel", channel:type())
    end)

    -- @covers LThreadPool:join
    it("join returns a boolean status", function()
        local pool = lurek.thread.newPool(2, "return nil")
        expect_type("boolean", pool:join(1.0))
    end)

    -- @covers LThreadPool:size
    it("size returns the configured worker count", function()
        local pool = new_pool()
        expect_equal(2, pool:size())
    end)

    -- @covers LThreadPool:submit
    it("submit queues work without raising an error", function()
        local pool = new_pool()
        expect_no_error(function()
            pool:submit(10)
            pool:join(1.0)
        end)
    end)

    -- @covers LThreadPool:type
    it("type returns the pool userdata name", function()
        local pool = new_pool()
        expect_equal("LThreadPool", pool:type())
    end)

    -- @covers LThreadPool:typeOf
    it("typeOf accepts the pool type name", function()
        local pool = new_pool()
        expect_true(pool:typeOf("LThreadPool"))
    end)
end)

test_summary()
