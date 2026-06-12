-- test_network.lua
-- Canonical file. Merged from multiple sources.

require("tests/lua_reorg/init")

local function expect_invalid_host_addr(addr)
    expect_error(function()
        lurek.network.newHost({ addr = addr })
    end)
end

local function new_ephemeral_server()
    return lurek.network.newServer({ port = 0 })
end

local function build_deep_network_table(depth)
    local t = { value = 1 }
    local current = t
    for i = 1, depth do
        current.child = { value = i + 1 }
        current = current.child
    end
    return t
end

local function roundtrip_network_payload(payload)
    return lurek.network.unpack(lurek.network.pack(payload))
end

local function packed_payload_without_last_byte(payload)
    local packed = lurek.network.pack(payload)
    return string.sub(packed, 1, math.max(1, #packed - 1))
end

local function expect_invalid_server_port(port)
    expect_error(function()
        lurek.network.newServer({ port = port })
    end)
end

local function create_and_destroy_host(addr)
    local host = lurek.network.newHost({ addr = addr })
    host:destroy()
    return host
end

local function rapid_destroy_cycles(count)
    local completed = 0
    for _ = 1, count do
        local h = lurek.network.newHost({ addr = "0.0.0.0:0" })
        h:destroy()
        completed = completed + 1
    end
    return completed
end

local function shutdown_runtime_twice()
    local rt = lurek.network.newRuntime()
    rt:shutdown()
    rt:shutdown()
end

-- @describe lurek.network security
describe("lurek.network security", function()
    -- @security lurek.network.newHost
    it("should reject invalid host address strings", function()
        expect_invalid_host_addr("")
        expect_invalid_host_addr("not_an_address")
    end)

    -- @security LNetworkHost:isServer
    it("should reject server with port 0", function()
        local server = new_ephemeral_server()
        expect_equal(server:isServer(), true)
        expect_equal(server:getRole(), "server")
        server:destroy()
    end)

    -- @security lurek.network.pack
    it("should validate unsupported values and encode deep tables", function()
        expect_error(function()
            lurek.network.pack(print)
        end)
        local unpacked = roundtrip_network_payload(build_deep_network_table(20))
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
        local truncated = packed_payload_without_last_byte({ ok = true, count = 3 })
        expect_error(function()
            lurek.network.unpack(truncated)
        end)
    end)

    -- @security lurek.network.newServer
    it("should reject missing and out-of-range server ports", function()
        expect_error(function()
            lurek.network.newServer({})
        end)
        expect_invalid_server_port(-1)
        expect_invalid_server_port(70000)
    end)

    -- @security lurek.network.newClient
    it("should handle newClient without required addr", function()
        expect_error(function()
            lurek.network.newClient({})
        end)
    end)

    -- @security LNetworkHost:isDestroyed
    it("should handle destroyed host methods gracefully", function()
        local host = create_and_destroy_host("0.0.0.0:0")
        expect_equal(host:isDestroyed(), true)
        expect_error(function()
            host:service()
        end)
    end)

    -- @security LNetworkHost:destroy
    it("should not crash on rapid create/destroy cycle", function()
        local completed = rapid_destroy_cycles(10)
        expect_equal(10, completed)
    end)

    -- @security LNetworkRuntime:shutdown
    it("should handle runtime shutdown idempotently", function()
        expect_no_error(function()
            shutdown_runtime_twice()
        end)
    end)
end)
test_summary()
