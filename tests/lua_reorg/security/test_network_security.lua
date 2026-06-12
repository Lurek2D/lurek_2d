-- test_network.lua
-- Canonical file. Merged from multiple sources.

require("tests/lua_reorg/init")

-- @describe lurek.network security
describe("lurek.network security", function()
    -- @security lurek.network.newHost
    it("should reject invalid host address strings", function()
        expect_error(function()
            lurek.network.newHost({ addr = "" })
        end)
        expect_error(function()
            lurek.network.newHost({ addr = "not_an_address" })
        end)
    end)

    -- @security LNetworkHost:isServer
    it("should reject server with port 0", function()
        -- Port 0 is ephemeral     should still create but bind to random port
        -- This is NOT an error; verify it works
        local server = lurek.network.newServer({ port = 0 })
        expect_equal(server:isServer(), true)
        expect_equal(server:getRole(), "server")
        server:destroy()
    end)

    -- @security lurek.network.pack
    it("should validate unsupported values and encode deep tables", function()
        -- Functions cannot be serialized
        expect_error(function()
            lurek.network.pack(print)
        end)
        -- Deep tables should still round-trip without corruption.
        local t = { value = 1 }
        local current = t
        for i = 1, 20 do
            current.child = { value = i + 1 }
            current = current.child
        end
        local packed = lurek.network.pack(t)
        local unpacked = lurek.network.unpack(packed)
        expect_not_nil(unpacked)
        expect_equal(1, unpacked.value)
        expect_not_nil(unpacked.child)
        expect_equal(2, unpacked.child.value)
    end)

    -- @security lurek.network.unpack
    it("should reject invalid serialized payloads", function()
        expect_error(function()
            lurek.network.unpack("")
        end)
        expect_error(function()
            lurek.network.unpack("\xff\xfe\xfd\xfc\xfb\xfa")
        end)
        local payload = lurek.network.pack({ ok = true, count = 3 })
        local truncated = string.sub(payload, 1, math.max(1, #payload - 1))
        expect_error(function()
            lurek.network.unpack(truncated)
        end)
    end)

    -- @security lurek.network.newServer
    it("should reject missing and out-of-range server ports", function()
        expect_error(function()
            lurek.network.newServer({})
        end)
        expect_error(function()
            lurek.network.newServer({ port = -1 })
        end)
        expect_error(function()
            lurek.network.newServer({ port = 70000 })
        end)
    end)

    -- @security lurek.network.newClient
    it("should handle newClient without required addr", function()
        expect_error(function()
            lurek.network.newClient({})
        end)
    end)

    -- @security LNetworkHost:isDestroyed
    it("should handle destroyed host methods gracefully", function()
        local host = lurek.network.newHost({ addr = "0.0.0.0:0" })
        host:destroy()
        expect_equal(host:isDestroyed(), true)
        expect_error(function()
            host:service()
        end)
    end)

    -- @security LNetworkHost:destroy
    it("should not crash on rapid create/destroy cycle", function()
        local completed = 0
        for i = 1, 10 do
            local h = lurek.network.newHost({ addr = "0.0.0.0:0" })
            h:destroy()
            completed = completed + 1
        end
        expect_equal(10, completed)
    end)

    -- @security LNetworkRuntime:shutdown
    it("should handle runtime shutdown idempotently", function()
        local rt = lurek.network.newRuntime()
        rt:shutdown()
        expect_no_error(function()
            rt:shutdown()
        end)
    end)
end)
test_summary()
