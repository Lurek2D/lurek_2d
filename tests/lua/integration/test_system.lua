-- Luna2D System API Tests

describe("luna.platform module exists", function()
    it("luna.platform is a table", function()
        expect_type("table", luna.platform)
    end)
end)

describe("luna.platform.getOS", function()
    it("is a function", function()
        expect_type("function", luna.platform.getOS)
    end)

    it("returns a string", function()
        local os = luna.platform.getOS()
        expect_type("string", os)
    end)

    it("returns a known OS name", function()
        local os = luna.platform.getOS()
        local valid = (os == "Windows" or os == "Linux" or os == "macOS"
                      or os == "Android" or os == "iOS" or os == "Unknown")
        expect_true(valid, "OS should be a known name, got: " .. os)
    end)
end)

describe("luna.platform.getVersion", function()
    it("is a function", function()
        expect_type("function", luna.platform.getVersion)
    end)

    it("returns a string", function()
        local ver = luna.platform.getVersion()
        expect_type("string", ver)
    end)

    it("returns non-empty version", function()
        local ver = luna.platform.getVersion()
        expect_true(#ver > 0, "version should not be empty")
    end)
end)

describe("luna.platform.getInfo", function()
    it("is a function", function()
        expect_type("function", luna.platform.getInfo)
    end)

    it("returns a table", function()
        local info = luna.platform.getInfo()
        expect_type("table", info)
    end)

    it("has engine name", function()
        local info = luna.platform.getInfo()
        expect_equal("Luna2D", info.engine)
    end)

    it("has version", function()
        local info = luna.platform.getInfo()
        expect_type("string", info.version)
    end)

    it("has lua_version", function()
        local info = luna.platform.getInfo()
        expect_contains(info.lua_version, "Lua")
    end)

    it("reports the wgpu renderer", function()
        local info = luna.platform.getInfo()
        expect_equal("wgpu", info.renderer)
    end)
end)

describe("luna.signal module exists", function()
    it("luna.signal is a table", function()
        expect_type("table", luna.signal)
    end)
end)

describe("luna.signal.quit", function()
    it("is a function", function()
        expect_type("function", luna.signal.quit)
    end)
end)

describe("luna.platform.clipboard stubs", function()
    it("setClipboardText is a function", function()
        expect_type("function", luna.platform.setClipboardText)
    end)

    it("getClipboardText is a function", function()
        expect_type("function", luna.platform.getClipboardText)
    end)

    it("getClipboardText returns a string", function()
        local text = luna.platform.getClipboardText()
        expect_type("string", text)
    end)
end)

test_summary()
