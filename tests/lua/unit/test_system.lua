-- Lurek2D system / platform API tests
-- Tests lurek.platform.* namespace (registered via system_api.rs)
-- Headless-safe: no GPU, no audio, no window.
-- @covers lurek.platform.getOS
-- @covers lurek.platform.getVersion
-- @covers lurek.platform.getArch
-- @covers lurek.platform.getProcessorCount
-- @covers lurek.platform.getMemorySize
-- @covers lurek.platform.getInfo
-- @covers lurek.platform.getClipboardText
-- @covers lurek.platform.setClipboardText
-- @covers lurek.platform.setDebugOverlay
-- @covers lurek.platform.getDebugOverlay
-- @covers lurek.platform.setLogLevel
-- @covers lurek.platform.getLogLevel
-- @covers lurek.platform.log
-- @covers lurek.platform.getLastError
-- @covers lurek.platform.getEnv
-- @covers lurek.platform.getArgs
-- @covers lurek.platform.parseArgs
-- @covers lurek.platform.getPowerInfo
-- @covers lurek.platform.getPreferredLocales
-- @covers lurek.platform.openURL
-- @covers lurek.signal.quit

-- ============================================================
-- Module surface
-- ============================================================
describe("lurek.platform module", function()
    it("is a table", function()
        expect_type("table", lurek.platform)
    end)
end)

-- ============================================================
-- OS information
-- ============================================================
describe("lurek.platform.getOS", function()
    it("is a function", function()
        expect_type("function", lurek.platform.getOS)
    end)

    it("returns a string", function()
        local os = lurek.platform.getOS()
        expect_type("string", os)
    end)

    it("returns a known OS name", function()
        local os = lurek.platform.getOS()
        local valid = (os == "Windows" or os == "Linux" or os == "macOS"
                      or os == "Android" or os == "iOS" or os == "Unknown")
        expect_true(valid, "OS should be recognised, got: " .. os)
    end)
end)

describe("lurek.platform.getVersion", function()
    it("is a function", function()
        expect_type("function", lurek.platform.getVersion)
    end)

    it("returns a non-empty string", function()
        local ver = lurek.platform.getVersion()
        expect_type("string", ver)
        expect_true(#ver > 0, "version should not be empty")
    end)
end)

describe("lurek.platform.getArch", function()
    it("is a function", function()
        expect_type("function", lurek.platform.getArch)
    end)

    it("returns a string", function()
        local arch = lurek.platform.getArch()
        expect_type("string", arch)
        expect_true(#arch > 0, "arch should not be empty")
    end)
end)

describe("lurek.platform.getProcessorCount", function()
    it("is a function", function()
        expect_type("function", lurek.platform.getProcessorCount)
    end)

    it("returns a positive integer", function()
        local n = lurek.platform.getProcessorCount()
        expect_type("number", n)
        expect_true(n >= 1, "processor count should be at least 1")
        expect_true(n == math.floor(n), "should be an integer")
    end)
end)

describe("lurek.platform.getMemorySize", function()
    it("is a function", function()
        expect_type("function", lurek.platform.getMemorySize)
    end)

    it("returns a positive number (MiB)", function()
        local mb = lurek.platform.getMemorySize()
        expect_type("number", mb)
        expect_true(mb > 0, "memory should be positive")
    end)
end)

-- ============================================================
-- Engine info table
-- ============================================================
describe("lurek.platform.getInfo", function()
    it("is a function", function()
        expect_type("function", lurek.platform.getInfo)
    end)

    it("returns a table", function()
        local info = lurek.platform.getInfo()
        expect_type("table", info)
    end)

    it("has engine == 'Lurek2D'", function()
        local info = lurek.platform.getInfo()
        expect_equal("Lurek2D", info.engine)
    end)

    it("has a non-empty version string", function()
        local info = lurek.platform.getInfo()
        expect_type("string", info.version)
        expect_true(#info.version > 0)
    end)

    it("has lua_version containing 'Lua'", function()
        local info = lurek.platform.getInfo()
        expect_contains(info.lua_version, "Lua")
    end)

    it("reports the wgpu renderer", function()
        local info = lurek.platform.getInfo()
        expect_equal("wgpu", info.renderer)
    end)

    it("has os field", function()
        local info = lurek.platform.getInfo()
        expect_type("string", info.os)
    end)

    it("has processors field >= 1", function()
        local info = lurek.platform.getInfo()
        expect_type("number", info.processors)
        expect_true(info.processors >= 1)
    end)

    it("has memory field > 0", function()
        local info = lurek.platform.getInfo()
        expect_type("number", info.memory)
        expect_true(info.memory > 0)
    end)
end)

-- ============================================================
-- Clipboard
-- ============================================================
describe("lurek.platform clipboard", function()
    it("setClipboardText is a function", function()
        expect_type("function", lurek.platform.setClipboardText)
    end)

    it("getClipboardText is a function", function()
        expect_type("function", lurek.platform.getClipboardText)
    end)

    it("setClipboardText does not error", function()
        lurek.platform.setClipboardText("lurek2d test")
    end)

    it("getClipboardText returns a string", function()
        local text = lurek.platform.getClipboardText()
        expect_type("string", text)
    end)
end)

-- ============================================================
-- Debug overlay
-- ============================================================
describe("lurek.platform debug overlay", function()
    it("setDebugOverlay is a function", function()
        expect_type("function", lurek.platform.setDebugOverlay)
    end)

    it("getDebugOverlay is a function", function()
        expect_type("function", lurek.platform.getDebugOverlay)
    end)

    it("setDebugOverlay/getDebugOverlay round-trip", function()
        lurek.platform.setDebugOverlay(true)
        expect_equal(true, lurek.platform.getDebugOverlay())
        lurek.platform.setDebugOverlay(false)
        expect_equal(false, lurek.platform.getDebugOverlay())
    end)
end)

-- ============================================================
-- Log level
-- ============================================================
describe("lurek.platform log level", function()
    it("setLogLevel is a function", function()
        expect_type("function", lurek.platform.setLogLevel)
    end)

    it("getLogLevel is a function", function()
        expect_type("function", lurek.platform.getLogLevel)
    end)

    it("setLogLevel/getLogLevel round-trip for 'warn'", function()
        lurek.platform.setLogLevel("warn")
        local level = lurek.platform.getLogLevel()
        expect_equal("warn", level)
    end)

    it("setLogLevel/getLogLevel round-trip for 'debug'", function()
        lurek.platform.setLogLevel("debug")
        local level = lurek.platform.getLogLevel()
        expect_equal("debug", level)
    end)
end)

-- ============================================================
-- log()
-- ============================================================
describe("lurek.platform.log", function()
    it("is a function", function()
        expect_type("function", lurek.platform.log)
    end)

    it("does not error for info level", function()
        lurek.platform.log("info", "test log message")
    end)

    it("does not error for warn level", function()
        lurek.platform.log("warn", "test warn message")
    end)
end)

-- ============================================================
-- getLastError
-- ============================================================
describe("lurek.platform.getLastError", function()
    it("is a function", function()
        expect_type("function", lurek.platform.getLastError)
    end)

    it("returns nil or a table", function()
        local err = lurek.platform.getLastError()
        local t = type(err)
        expect_true(t == "nil" or t == "table",
            "getLastError should return nil or table, got " .. t)
    end)
end)

-- ============================================================
-- Environment and args
-- ============================================================
describe("lurek.platform.getEnv", function()
    it("is a function", function()
        expect_type("function", lurek.platform.getEnv)
    end)

    it("returns nil for an unset variable", function()
        local v = lurek.platform.getEnv("LUREK2D_NONEXISTENT_VAR_12345")
        expect_equal(nil, v)
    end)

    it("returns a string for a set variable", function()
        local v = lurek.platform.getEnv("PATH")
        if v ~= nil then
            expect_type("string", v)
        end
    end)
end)

describe("lurek.platform.getArgs", function()
    it("is a function", function()
        expect_type("function", lurek.platform.getArgs)
    end)

    it("returns a table", function()
        local args = lurek.platform.getArgs()
        expect_type("table", args)
    end)
end)

describe("lurek.platform.parseArgs", function()
    it("is a function", function()
        expect_type("function", lurek.platform.parseArgs)
    end)

    it("returns a table with flags, options, positional", function()
        local parsed = lurek.platform.parseArgs({})
        expect_type("table", parsed)
        expect_type("table", parsed.flags)
        expect_type("table", parsed.options)
        expect_type("table", parsed.positional)
    end)

    it("parses flag arguments", function()
        local parsed = lurek.platform.parseArgs({"--verbose", "--debug"})
        expect_equal(true, parsed.flags.verbose)
        expect_equal(true, parsed.flags.debug)
    end)

    it("parses key=value options", function()
        local parsed = lurek.platform.parseArgs({"--output=foo.txt"})
        expect_equal("foo.txt", parsed.options.output)
    end)

    it("parses positional arguments", function()
        local parsed = lurek.platform.parseArgs({"file1.lua", "file2.lua"})
        expect_equal(2, #parsed.positional)
        expect_equal("file1.lua", parsed.positional[1])
    end)
end)

-- ============================================================
-- Power info
-- ============================================================
describe("lurek.platform.getPowerInfo", function()
    it("is a function", function()
        expect_type("function", lurek.platform.getPowerInfo)
    end)

    it("returns state as first value (string)", function()
        local state, pct, secs = lurek.platform.getPowerInfo()
        expect_type("string", state)
    end)
end)

-- ============================================================
-- Preferred locales
-- ============================================================
describe("lurek.platform.getPreferredLocales", function()
    it("is a function", function()
        expect_type("function", lurek.platform.getPreferredLocales)
    end)

    it("returns a table", function()
        local locales = lurek.platform.getPreferredLocales()
        expect_type("table", locales)
    end)
end)

-- ============================================================
-- openURL (function-existence test — do NOT call it)
-- ============================================================
describe("lurek.platform.openURL", function()
    it("is a function", function()
        expect_type("function", lurek.platform.openURL)
    end)
end)

-- ============================================================
-- lurek.signal.quit (cross-module surface check)
-- ============================================================
describe("lurek.signal.quit", function()
    it("lurek.signal is a table", function()
        expect_type("table", lurek.signal)
    end)

    it("quit is a function", function()
        expect_type("function", lurek.signal.quit)
    end)
end)

test_summary()
