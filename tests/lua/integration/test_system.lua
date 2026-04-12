-- @covers lurek.platform.clipboard
-- @covers lurek.platform.getClipboardText
-- @covers lurek.platform.getInfo
-- @covers lurek.platform.getOS
-- @covers lurek.platform.getVersion
-- @covers lurek.platform.setClipboardText
-- @covers lurek.signal.quit

ď»ż-- Lurek2D System API Tests

-- @description Covers suite: lurek.platform module exists.
describe("lurek.platform module exists", function()
    -- @covers lurek.platform
    -- @covers lurek.platform.getOS
    -- @description Verifies the platform namespace exists; this file is stored under integration but this test is effectively single-module platform coverage.
    it("lurek.platform is a table", function()
        expect_type("table", lurek.platform)
    end)
end)

-- @description Covers suite: lurek.platform.getOS.
describe("lurek.platform.getOS", function()
    -- @covers lurek.platform.getOS
    -- @covers lurek.platform
    -- @description Verifies the platform OS getter is exposed as a function; this is single-module platform coverage.
    it("is a function", function()
        expect_type("function", lurek.platform.getOS)
    end)

    -- @covers lurek.platform.getOS
    -- @covers lurek.platform
    -- @description Verifies the platform OS getter returns a string value.
    it("returns a string", function()
        local os = lurek.platform.getOS()
        expect_type("string", os)
    end)

    -- @covers lurek.platform.getOS
    -- @covers lurek.platform
    -- @description Verifies the platform OS getter returns one of the expected engine OS labels.
    it("returns a known OS name", function()
        local os = lurek.platform.getOS()
        local valid = (os == "Windows" or os == "Linux" or os == "macOS"
                      or os == "Android" or os == "iOS" or os == "Unknown")
        expect_true(valid, "OS should be a known name, got: " .. os)
    end)
end)

-- @description Covers suite: lurek.platform.getVersion.
describe("lurek.platform.getVersion", function()
    -- @covers lurek.platform.getVersion
    -- @covers lurek.platform
    -- @description Verifies the platform version getter is exposed as a function.
    it("is a function", function()
        expect_type("function", lurek.platform.getVersion)
    end)

    -- @covers lurek.platform.getVersion
    -- @covers lurek.platform
    -- @description Verifies the platform version getter returns a string.
    it("returns a string", function()
        local ver = lurek.platform.getVersion()
        expect_type("string", ver)
    end)

    -- @covers lurek.platform.getVersion
    -- @covers lurek.platform
    -- @description Verifies the reported platform version string is not empty.
    it("returns non-empty version", function()
        local ver = lurek.platform.getVersion()
        expect_true(#ver > 0, "version should not be empty")
    end)
end)

-- @description Covers suite: lurek.platform.getInfo.
describe("lurek.platform.getInfo", function()
    -- @covers lurek.platform.getInfo
    -- @covers lurek.platform
    -- @description Verifies the platform info getter is exposed as a function.
    it("is a function", function()
        expect_type("function", lurek.platform.getInfo)
    end)

    -- @covers lurek.platform.getInfo
    -- @covers lurek.platform
    -- @description Verifies platform info returns a structured table.
    it("returns a table", function()
        local info = lurek.platform.getInfo()
        expect_type("table", info)
    end)

    -- @covers lurek.platform.getInfo
    -- @covers lurek.platform
    -- @description Verifies platform info reports the expected engine name.
    it("has engine name", function()
        local info = lurek.platform.getInfo()
        expect_equal("Lurek2D", info.engine)
    end)

    -- @covers lurek.platform.getInfo
    -- @covers lurek.platform.getVersion
    -- @description Verifies platform info includes a version string field.
    it("has version", function()
        local info = lurek.platform.getInfo()
        expect_type("string", info.version)
    end)

    -- @covers lurek.platform.getInfo
    -- @covers lurek.platform
    -- @description Verifies platform info includes a Lua runtime version string.
    it("has lua_version", function()
        local info = lurek.platform.getInfo()
        expect_contains(info.lua_version, "Lua")
    end)

    -- @covers lurek.platform.getInfo
    -- @covers lurek.platform
    -- @description Verifies platform info identifies wgpu as the renderer backend.
    it("reports the wgpu renderer", function()
        local info = lurek.platform.getInfo()
        expect_equal("wgpu", info.renderer)
    end)
end)

-- @description Covers suite: lurek.signal module exists.
describe("lurek.signal module exists", function()
    -- @covers lurek.signal
    -- @covers lurek.signal.quit
    -- @description Verifies the signal namespace exists; this is a single-module signal smoke test kept in the integration folder.
    it("lurek.signal is a table", function()
        expect_type("table", lurek.signal)
    end)
end)

-- @description Covers suite: lurek.signal.quit.
describe("lurek.signal.quit", function()
    -- @covers lurek.signal.quit
    -- @covers lurek.signal
    -- @description Verifies the quit signal hook is exposed as a function.
    it("is a function", function()
        expect_type("function", lurek.signal.quit)
    end)
end)

-- @description Covers suite: lurek.platform.clipboard stubs.
describe("lurek.platform.clipboard stubs", function()
    -- @covers lurek.platform.setClipboardText
    -- @covers lurek.platform
    -- @description Verifies the platform clipboard setter is exposed as a function.
    it("setClipboardText is a function", function()
        expect_type("function", lurek.platform.setClipboardText)
    end)

    -- @covers lurek.platform.getClipboardText
    -- @covers lurek.platform
    -- @description Verifies the platform clipboard getter is exposed as a function.
    it("getClipboardText is a function", function()
        expect_type("function", lurek.platform.getClipboardText)
    end)

    -- @covers lurek.platform.getClipboardText
    -- @covers lurek.platform
    -- @description Verifies the clipboard getter returns a string even in stubbed or headless environments.
    it("getClipboardText returns a string", function()
        local text = lurek.platform.getClipboardText()
        expect_type("string", text)
    end)
end)

test_summary()
