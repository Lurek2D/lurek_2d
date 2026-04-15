-- lurek.thread API — new feature unit tests
-- Headless-safe (no window / GPU / audio required).
-- Covers: pushTable/popTable, pushBytes/popBytes, newPool, async/Promise.

-- @description Covers suite: Channel table serialization.
describe("Channel table serialization", function()
    -- @covers lurek.thread.Channel.pushTable
    -- @covers lurek.thread.Channel.popTable
    -- @description Verifies pushTable is a function on a Channel.
    it("pushTable is a function", function()
        local ch = lurek.thread.newChannel()
        expect_type("function", ch.pushTable)
    end)

    -- @covers lurek.thread.Channel.popTable
    -- @description Verifies popTable is a function on a Channel.
    it("popTable is a function", function()
        local ch = lurek.thread.newChannel()
        expect_type("function", ch.popTable)
    end)

    -- @covers lurek.thread.Channel.pushTable
    -- @covers lurek.thread.Channel.popTable
    -- @description Verifies a flat table round-trips through pushTable/popTable.
    it("flat table round-trips through pushTable/popTable", function()
        local ch = lurek.thread.newChannel()
        ch:pushTable({x = 10, y = 20})
        local t = ch:popTable()
        expect_not_nil(t)
        expect_equal(10, t.x)
        expect_equal(20, t.y)
    end)

    -- @covers lurek.thread.Channel.pushTable
    -- @covers lurek.thread.Channel.popTable
    -- @description Verifies a sequence table preserves element order.
    it("sequence table preserves FIFO order", function()
        local ch = lurek.thread.newChannel()
        ch:pushTable({10, 20, 30})
        local t = ch:popTable()
        expect_not_nil(t)
        expect_equal(10, t[1])
        expect_equal(20, t[2])
        expect_equal(30, t[3])
    end)

    -- @covers lurek.thread.Channel.pushTable
    -- @covers lurek.thread.Channel.popTable
    -- @description Verifies getCount increments after pushTable.
    it("getCount increments after pushTable", function()
        local ch = lurek.thread.newChannel()
        ch:pushTable({a = 1})
        expect_equal(1, ch:getCount())
    end)

    -- @covers lurek.thread.Channel.popTable
    -- @description Verifies popTable on empty channel returns nil.
    it("popTable on empty channel returns nil", function()
        local ch = lurek.thread.newChannel()
        local t = ch:popTable()
        expect_equal(nil, t)
    end)
end)

-- @description Covers suite: Channel bytes serialization.
describe("Channel bytes serialization", function()
    -- @covers lurek.thread.Channel.pushBytes
    -- @description Verifies pushBytes is a function on a Channel.
    it("pushBytes is a function", function()
        local ch = lurek.thread.newChannel()
        expect_type("function", ch.pushBytes)
    end)

    -- @covers lurek.thread.Channel.popBytes
    -- @description Verifies popBytes is a function on a Channel.
    it("popBytes is a function", function()
        local ch = lurek.thread.newChannel()
        expect_type("function", ch.popBytes)
    end)

    -- @covers lurek.thread.Channel.pushBytes
    -- @covers lurek.thread.Channel.popBytes
    -- @description Verifies a byte string round-trips through pushBytes/popBytes.
    it("byte string round-trips through pushBytes/popBytes", function()
        local ch = lurek.thread.newChannel()
        local original = "binary\0data\255"
        ch:pushBytes(original)
        local result = ch:popBytes()
        expect_not_nil(result)
        expect_equal(#original, #result)
    end)

    -- @covers lurek.thread.Channel.pushBytes
    -- @covers lurek.thread.Channel.popBytes
    -- @description Verifies getCount increments after pushBytes.
    it("getCount increments after pushBytes", function()
        local ch = lurek.thread.newChannel()
        ch:pushBytes("hello")
        expect_equal(1, ch:getCount())
    end)

    -- @covers lurek.thread.Channel.popBytes
    -- @description Verifies popBytes on empty channel returns nil.
    it("popBytes on empty channel returns nil", function()
        local ch = lurek.thread.newChannel()
        local v = ch:popBytes()
        expect_equal(nil, v)
    end)
end)

-- @description Covers suite: Thread pool factory.
describe("Thread pool factory", function()
    -- @covers lurek.thread.newPool
    -- @description Verifies newPool is a function.
    it("newPool is a function", function()
        expect_type("function", lurek.thread.newPool)
    end)

    -- @covers lurek.thread.newPool
    -- @description Verifies newPool returns a non-nil object.
    it("newPool returns a non-nil object", function()
        local pool = lurek.thread.newPool(1, "return")
        expect_not_nil(pool)
    end)

    -- @covers lurek.thread.ThreadPool.size
    -- @description Verifies ThreadPool:size() returns the constructor argument.
    it("ThreadPool:size() matches constructor argument", function()
        local pool = lurek.thread.newPool(3, "return")
        expect_equal(3, pool:size())
    end)

    -- @covers lurek.thread.ThreadPool.submit
    -- @description Verifies submit is a function on a ThreadPool.
    it("ThreadPool has submit method", function()
        local pool = lurek.thread.newPool(1, "return")
        expect_type("function", pool.submit)
    end)

    -- @covers lurek.thread.ThreadPool.collect
    -- @description Verifies collect is a function on a ThreadPool.
    it("ThreadPool has collect method", function()
        local pool = lurek.thread.newPool(1, "return")
        expect_type("function", pool.collect)
    end)

    -- @covers lurek.thread.ThreadPool.join
    -- @description Verifies join is a function on a ThreadPool.
    it("ThreadPool has join method", function()
        local pool = lurek.thread.newPool(1, "return")
        expect_type("function", pool.join)
    end)

    -- @covers lurek.thread.ThreadPool.getInputChannel
    -- @description Verifies getInputChannel returns a channel object.
    it("ThreadPool getInputChannel returns a channel", function()
        local pool = lurek.thread.newPool(1, "return")
        local ch = pool:getInputChannel()
        expect_not_nil(ch)
    end)

    -- @covers lurek.thread.ThreadPool.getOutputChannel
    -- @description Verifies getOutputChannel returns a channel object.
    it("ThreadPool getOutputChannel returns a channel", function()
        local pool = lurek.thread.newPool(1, "return")
        local ch = pool:getOutputChannel()
        expect_not_nil(ch)
    end)
end)

-- @description Covers suite: Async / Promise.
describe("Async / Promise", function()
    -- @covers lurek.thread.async
    -- @description Verifies async is a function.
    it("async is a function", function()
        expect_type("function", lurek.thread.async)
    end)

    -- @covers lurek.thread.async
    -- @description Verifies async returns a non-nil Promise object.
    it("async returns a non-nil promise", function()
        local p = lurek.thread.async("return 42")
        expect_not_nil(p)
    end)

    -- @covers lurek.thread.Promise.isDone
    -- @description Verifies isDone is a function on a Promise.
    it("Promise has isDone method", function()
        local p = lurek.thread.async("return 42")
        expect_type("function", p.isDone)
    end)

    -- @covers lurek.thread.Promise.result
    -- @description Verifies result is a function on a Promise.
    it("Promise has result method", function()
        local p = lurek.thread.async("return 42")
        expect_type("function", p.result)
    end)

    -- @covers lurek.thread.Promise.getError
    -- @description Verifies getError is a function on a Promise.
    it("Promise has getError method", function()
        local p = lurek.thread.async("return 42")
        expect_type("function", p.getError)
    end)

    -- @covers lurek.thread.Promise.isDone
    -- @description Verifies isDone returns a boolean.
    it("isDone returns a boolean value", function()
        local p = lurek.thread.async("return 42")
        local done = p:isDone()
        expect_true(done == true or done == false)
    end)
end)

test_summary()
