require("tests/lua/init")

describe("lurek.network.newRuntime", function()
    it("should have newRuntime function", function()
        expect_equal(type(lurek.network.newRuntime), "function")
    end)

    it("should create a runtime object", function()
        local rt = lurek.network.newRuntime()
        expect_equal(type(rt) == "userdata" or type(rt) == "table", true)
        rt:shutdown()
    end)

    it("should poll with empty results", function()
        local rt = lurek.network.newRuntime()
        local results = rt:poll()
        expect_equal(type(results), "table")
        -- No pending requests, so results should be empty
        expect_equal(#results, 0)
        rt:shutdown()
    end)

    it("should survive multiple polls", function()
        local rt = lurek.network.newRuntime()
        for i = 1, 5 do
            local results = rt:poll()
            expect_equal(type(results), "table")
        end
        rt:shutdown()
    end)

    it("should have httpGet method", function()
        local rt = lurek.network.newRuntime()
        expect_equal(type(rt.httpGet), "function")
        rt:shutdown()
    end)

    it("should have httpPost method", function()
        local rt = lurek.network.newRuntime()
        expect_equal(type(rt.httpPost), "function")
        rt:shutdown()
    end)

    it("should have httpRequest method", function()
        local rt = lurek.network.newRuntime()
        expect_equal(type(rt.httpRequest), "function")
        rt:shutdown()
    end)

    it("should have TCP methods", function()
        local rt = lurek.network.newRuntime()
        expect_equal(type(rt.tcpConnect), "function")
        expect_equal(type(rt.tcpSend), "function")
        expect_equal(type(rt.tcpClose), "function")
        rt:shutdown()
    end)

    it("should have WebSocket methods", function()
        local rt = lurek.network.newRuntime()
        expect_equal(type(rt.wsConnect), "function")
        expect_equal(type(rt.wsSend), "function")
        expect_equal(type(rt.wsClose), "function")
        rt:shutdown()
    end)
end)

test_summary()
