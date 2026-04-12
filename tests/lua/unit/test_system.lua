-- Lurek2D system / platform API tests
-- Tests lurek.platform.* namespace (registered via system_api.rs)
-- Headless-safe: no GPU, no audio, no window.

-- ============================================================
-- Module surface
-- ============================================================
-- @description Covers suite: lurek.platform module.
describe("lurek.platform module", function()
    -- @covers lurek.platform
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
    -- @covers lurek.platform.getMessage
    -- @covers lurek.platform.hasMessage
    -- @covers lurek.platform.getMessageCount
    -- @covers lurek.signal.quit
    -- @description Verifies the platform namespace is available as a Lua table.
    it("is a table", function()
        expect_type("table", lurek.platform)
    end)
end)

-- ============================================================
-- OS information
-- ============================================================
-- @description Covers suite: lurek.platform.getOS.
describe("lurek.platform.getOS", function()
    -- @covers lurek.platform.getOS
    -- @description Verifies getOS is exposed.
    it("is a function", function()
        expect_type("function", lurek.platform.getOS)
    end)

    -- @covers lurek.platform.getOS
    -- @description Verifies getOS returns a string payload.
    it("returns a string", function()
        local os = lurek.platform.getOS()
        expect_type("string", os)
    end)

    -- @covers lurek.platform.getOS
    -- @description Verifies getOS maps to one of the known platform labels.
    it("returns a known OS name", function()
        local os = lurek.platform.getOS()
        local valid = (os == "Windows" or os == "Linux" or os == "macOS"
                      or os == "Android" or os == "iOS" or os == "Unknown")
        expect_true(valid, "OS should be recognised, got: " .. os)
    end)
end)

-- @description Covers suite: lurek.platform.getVersion.
describe("lurek.platform.getVersion", function()
    -- @covers lurek.platform.getVersion
    -- @description Verifies getVersion is exposed.
    it("is a function", function()
        expect_type("function", lurek.platform.getVersion)
    end)

    -- @covers lurek.platform.getVersion
    -- @description Verifies getVersion returns non-empty version text.
    it("returns a non-empty string", function()
        local ver = lurek.platform.getVersion()
        expect_type("string", ver)
        expect_true(#ver > 0, "version should not be empty")
    end)
end)

-- @description Covers suite: lurek.platform.getArch.
describe("lurek.platform.getArch", function()
    -- @covers lurek.platform.getArch
    -- @description Verifies getArch is exposed.
    it("is a function", function()
        expect_type("function", lurek.platform.getArch)
    end)

    -- @covers lurek.platform.getArch
    -- @description Verifies getArch returns non-empty architecture text.
    it("returns a string", function()
        local arch = lurek.platform.getArch()
        expect_type("string", arch)
        expect_true(#arch > 0, "arch should not be empty")
    end)
end)

-- @description Covers suite: lurek.platform.getProcessorCount.
describe("lurek.platform.getProcessorCount", function()
    -- @covers lurek.platform.getProcessorCount
    -- @description Verifies getProcessorCount is exposed.
    it("is a function", function()
        expect_type("function", lurek.platform.getProcessorCount)
    end)

    -- @covers lurek.platform.getProcessorCount
    -- @description Verifies getProcessorCount returns a positive integer.
    it("returns a positive integer", function()
        local n = lurek.platform.getProcessorCount()
        expect_type("number", n)
        expect_true(n >= 1, "processor count should be at least 1")
        expect_true(n == math.floor(n), "should be an integer")
    end)
end)

-- @description Covers suite: lurek.platform.getMemorySize.
describe("lurek.platform.getMemorySize", function()
    -- @covers lurek.platform.getMemorySize
    -- @description Verifies getMemorySize is exposed.
    it("is a function", function()
        expect_type("function", lurek.platform.getMemorySize)
    end)

    -- @covers lurek.platform.getMemorySize
    -- @description Verifies getMemorySize reports a positive memory value in MiB.
    it("returns a positive number (MiB)", function()
        local mb = lurek.platform.getMemorySize()
        expect_type("number", mb)
        expect_true(mb > 0, "memory should be positive")
    end)
end)

-- ============================================================
-- Engine info table
-- ============================================================
-- @description Covers suite: lurek.platform.getInfo.
describe("lurek.platform.getInfo", function()
    -- @covers lurek.platform.getInfo
    -- @description Verifies getInfo is exposed.
    it("is a function", function()
        expect_type("function", lurek.platform.getInfo)
    end)

    -- @covers lurek.platform.getInfo
    -- @description Verifies getInfo returns a table payload.
    it("returns a table", function()
        local info = lurek.platform.getInfo()
        expect_type("table", info)
    end)

    -- @covers lurek.platform.getInfo
    -- @description Verifies getInfo identifies the engine as Lurek2D.
    it("has engine == 'Lurek2D'", function()
        local info = lurek.platform.getInfo()
        expect_equal("Lurek2D", info.engine)
    end)

    -- @covers lurek.platform.getInfo
    -- @description Verifies getInfo includes a non-empty engine version string.
    it("has a non-empty version string", function()
        local info = lurek.platform.getInfo()
        expect_type("string", info.version)
        expect_true(#info.version > 0)
    end)

    -- @covers lurek.platform.getInfo
    -- @description Verifies getInfo exposes the Lua runtime version string.
    it("has lua_version containing 'Lua'", function()
        local info = lurek.platform.getInfo()
        expect_contains(info.lua_version, "Lua")
    end)

    -- @covers lurek.platform.getInfo
    -- @description Verifies getInfo reports wgpu as the active renderer backend.
    it("reports the wgpu renderer", function()
        local info = lurek.platform.getInfo()
        expect_equal("wgpu", info.renderer)
    end)

    -- @covers lurek.platform.getInfo
    -- @description Verifies getInfo includes the host OS string.
    it("has os field", function()
        local info = lurek.platform.getInfo()
        expect_type("string", info.os)
    end)

    -- @covers lurek.platform.getInfo
    -- @description Verifies getInfo includes a processor count of at least one.
    it("has processors field >= 1", function()
        local info = lurek.platform.getInfo()
        expect_type("number", info.processors)
        expect_true(info.processors >= 1)
    end)

    -- @covers lurek.platform.getInfo
    -- @description Verifies getInfo includes a positive memory value.
    it("has memory field > 0", function()
        local info = lurek.platform.getInfo()
        expect_type("number", info.memory)
        expect_true(info.memory > 0)
    end)
end)

-- ============================================================
-- Clipboard
-- ============================================================
-- @description Covers suite: lurek.platform clipboard.
describe("lurek.platform clipboard", function()
    -- @covers lurek.platform.setClipboardText
    -- @description Verifies the clipboard setter is exposed.
    it("setClipboardText is a function", function()
        expect_type("function", lurek.platform.setClipboardText)
    end)

    -- @covers lurek.platform.getClipboardText
    -- @description Verifies the clipboard getter is exposed.
    it("getClipboardText is a function", function()
        expect_type("function", lurek.platform.getClipboardText)
    end)

    -- @covers lurek.platform.setClipboardText
    -- @description Verifies setClipboardText accepts a string without error.
    it("setClipboardText does not error", function()
        lurek.platform.setClipboardText("lurek2d test")
    end)

    -- @covers lurek.platform.getClipboardText
    -- @description Verifies getClipboardText returns a string payload.
    it("getClipboardText returns a string", function()
        local text = lurek.platform.getClipboardText()
        expect_type("string", text)
    end)
end)

-- ============================================================
-- Debug overlay
-- ============================================================
-- @description Covers suite: lurek.platform debug overlay.
describe("lurek.platform debug overlay", function()
    -- @covers lurek.platform.setDebugOverlay
    -- @description Verifies the debug-overlay setter is exposed.
    it("setDebugOverlay is a function", function()
        expect_type("function", lurek.platform.setDebugOverlay)
    end)

    -- @covers lurek.platform.getDebugOverlay
    -- @description Verifies the debug-overlay getter is exposed.
    it("getDebugOverlay is a function", function()
        expect_type("function", lurek.platform.getDebugOverlay)
    end)

    -- @covers lurek.platform.setDebugOverlay
    -- @covers lurek.platform.getDebugOverlay
    -- @description Verifies debug-overlay state round-trips through the setter and getter.
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
-- @description Covers suite: lurek.platform log level.
describe("lurek.platform log level", function()
    -- @covers lurek.platform.setLogLevel
    -- @description Verifies the log-level setter is exposed.
    it("setLogLevel is a function", function()
        expect_type("function", lurek.platform.setLogLevel)
    end)

    -- @covers lurek.platform.getLogLevel
    -- @description Verifies the log-level getter is exposed.
    it("getLogLevel is a function", function()
        expect_type("function", lurek.platform.getLogLevel)
    end)

    -- @covers lurek.platform.setLogLevel
    -- @covers lurek.platform.getLogLevel
    -- @description Verifies warn log level round-trips through the API.
    it("setLogLevel/getLogLevel round-trip for 'warn'", function()
        lurek.platform.setLogLevel("warn")
        local level = lurek.platform.getLogLevel()
        expect_equal("warn", level)
    end)

    -- @covers lurek.platform.setLogLevel
    -- @covers lurek.platform.getLogLevel
    -- @description Verifies debug log level round-trips through the API.
    it("setLogLevel/getLogLevel round-trip for 'debug'", function()
        lurek.platform.setLogLevel("debug")
        local level = lurek.platform.getLogLevel()
        expect_equal("debug", level)
    end)
end)

-- ============================================================
-- log()
-- ============================================================
-- @description Covers suite: lurek.platform.log.
describe("lurek.platform.log", function()
    -- @covers lurek.platform.log
    -- @description Verifies the generic log bridge is exposed.
    it("is a function", function()
        expect_type("function", lurek.platform.log)
    end)

    -- @covers lurek.platform.log
    -- @description Verifies log accepts the info level without error.
    it("does not error for info level", function()
        lurek.platform.log("info", "test log message")
    end)

    -- @covers lurek.platform.log
    -- @description Verifies log accepts the warn level without error.
    it("does not error for warn level", function()
        lurek.platform.log("warn", "test warn message")
    end)
end)

-- ============================================================
-- getLastError
-- ============================================================
-- @description Covers suite: lurek.platform.getLastError.
describe("lurek.platform.getLastError", function()
    -- @covers lurek.platform.getLastError
    -- @description Verifies getLastError is exposed.
    it("is a function", function()
        expect_type("function", lurek.platform.getLastError)
    end)

    -- @covers lurek.platform.getLastError
    -- @description Verifies getLastError returns either nil or a structured table.
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
-- @description Covers suite: lurek.platform.getEnv.
describe("lurek.platform.getEnv", function()
    -- @covers lurek.platform.getEnv
    -- @description Verifies getEnv is exposed.
    it("is a function", function()
        expect_type("function", lurek.platform.getEnv)
    end)

    -- @covers lurek.platform.getEnv
    -- @description Verifies getEnv returns nil for missing environment variables.
    it("returns nil for an unset variable", function()
        local v = lurek.platform.getEnv("LUREK2D_NONEXISTENT_VAR_12345")
        expect_equal(nil, v)
    end)

    -- @covers lurek.platform.getEnv
    -- @description Verifies getEnv returns string data for a present variable when available.
    it("returns a string for a set variable", function()
        local v = lurek.platform.getEnv("PATH")
        if v ~= nil then
            expect_type("string", v)
        end
    end)
end)

-- @description Covers suite: lurek.platform.getArgs.
describe("lurek.platform.getArgs", function()
    -- @covers lurek.platform.getArgs
    -- @description Verifies getArgs is exposed.
    it("is a function", function()
        expect_type("function", lurek.platform.getArgs)
    end)

    -- @covers lurek.platform.getArgs
    -- @description Verifies getArgs returns a table of process arguments.
    it("returns a table", function()
        local args = lurek.platform.getArgs()
        expect_type("table", args)
    end)
end)

-- @description Covers suite: lurek.platform.parseArgs.
describe("lurek.platform.parseArgs", function()
    -- @covers lurek.platform.parseArgs
    -- @description Verifies parseArgs is exposed.
    it("is a function", function()
        expect_type("function", lurek.platform.parseArgs)
    end)

    -- @covers lurek.platform.parseArgs
    -- @description Verifies parseArgs returns flags, options, and positional arrays.
    it("returns a table with flags, options, positional", function()
        local parsed = lurek.platform.parseArgs({})
        expect_type("table", parsed)
        expect_type("table", parsed.flags)
        expect_type("table", parsed.options)
        expect_type("table", parsed.positional)
    end)

    -- @covers lurek.platform.parseArgs
    -- @description Verifies parseArgs treats double-dash flags as boolean entries.
    it("parses flag arguments", function()
        local parsed = lurek.platform.parseArgs({"--verbose", "--debug"})
        expect_equal(true, parsed.flags.verbose)
        expect_equal(true, parsed.flags.debug)
    end)

    -- @covers lurek.platform.parseArgs
    -- @description Verifies parseArgs splits key=value options into the options table.
    it("parses key=value options", function()
        local parsed = lurek.platform.parseArgs({"--output=foo.txt"})
        expect_equal("foo.txt", parsed.options.output)
    end)

    -- @covers lurek.platform.parseArgs
    -- @description Verifies parseArgs preserves bare arguments in positional order.
    it("parses positional arguments", function()
        local parsed = lurek.platform.parseArgs({"file1.lua", "file2.lua"})
        expect_equal(2, #parsed.positional)
        expect_equal("file1.lua", parsed.positional[1])
    end)
end)

-- ============================================================
-- Message catalog
-- ============================================================
-- @description Covers suite: lurek.platform runtime message catalog lookup.
describe("lurek.platform message catalog", function()
    -- @covers lurek.platform.getMessage
    -- @description Verifies the stable message lookup helper is exposed.
    it("getMessage is a function", function()
        expect_type("function", lurek.platform.getMessage)
    end)

    -- @covers lurek.platform.hasMessage
    -- @description Verifies the catalog membership helper is exposed.
    it("hasMessage is a function", function()
        expect_type("function", lurek.platform.hasMessage)
    end)

    -- @covers lurek.platform.getMessageCount
    -- @description Verifies the catalog size helper is exposed.
    it("getMessageCount is a function", function()
        expect_type("function", lurek.platform.getMessageCount)
    end)

    -- @covers lurek.platform.getMessageCount
    -- @description Verifies the embedded runtime message catalog loads at least the baseline message set.
    it("getMessageCount returns at least 30 entries", function()
        expect_true(lurek.platform.getMessageCount() >= 30)
    end)

    -- @covers lurek.platform.getMessage
    -- @description Verifies L001 resolves to the expected startup text from the embedded message catalog.
    it("L001 resolves to startup text", function()
        expect_equal("Lurek2D Engine starting", lurek.platform.getMessage("L001"))
    end)

    -- @covers lurek.platform.getMessage
    -- @description Verifies L003 resolves to the expected game-loaded text from the embedded message catalog.
    it("L003 resolves to game loaded", function()
        expect_equal("Game loaded", lurek.platform.getMessage("L003"))
    end)

    -- @covers lurek.platform.getMessage
    -- @description Verifies L010 resolves to the expected render-error text from the embedded message catalog.
    it("L010 resolves to render error", function()
        expect_equal("Render error", lurek.platform.getMessage("L010"))
    end)

    -- @covers lurek.platform.getMessage
    -- @description Verifies unknown message IDs fall back to the raw ID string instead of crashing or returning nil.
    it("unknown IDs fall back to the raw id", function()
        expect_equal("ZZUNKNOWN", lurek.platform.getMessage("ZZUNKNOWN"))
    end)

    -- @covers lurek.platform.hasMessage
    -- @description Verifies known and unknown message IDs are reported correctly by the catalog membership helper.
    it("hasMessage distinguishes known and unknown ids", function()
        expect_equal(true, lurek.platform.hasMessage("L001"))
        expect_equal(false, lurek.platform.hasMessage("ZZUNKNOWN"))
    end)
end)

-- ============================================================
-- Power info
-- ============================================================
-- @description Covers suite: lurek.platform.getPowerInfo.
describe("lurek.platform.getPowerInfo", function()
    -- @covers lurek.platform.getPowerInfo
    -- @description Verifies getPowerInfo is exposed.
    it("is a function", function()
        expect_type("function", lurek.platform.getPowerInfo)
    end)

    -- @covers lurek.platform.getPowerInfo
    -- @description Verifies getPowerInfo returns a string state as its first value.
    it("returns state as first value (string)", function()
        local state, pct, secs = lurek.platform.getPowerInfo()
        expect_type("string", state)
    end)
end)

-- ============================================================
-- Preferred locales
-- ============================================================
-- @description Covers suite: lurek.platform.getPreferredLocales.
describe("lurek.platform.getPreferredLocales", function()
    -- @covers lurek.platform.getPreferredLocales
    -- @description Verifies getPreferredLocales is exposed.
    it("is a function", function()
        expect_type("function", lurek.platform.getPreferredLocales)
    end)

    -- @covers lurek.platform.getPreferredLocales
    -- @description Verifies getPreferredLocales returns a table payload.
    it("returns a table", function()
        local locales = lurek.platform.getPreferredLocales()
        expect_type("table", locales)
    end)
end)

-- ============================================================
-- openURL (function-existence test â€” do NOT call it)
-- ============================================================
-- @description Covers suite: lurek.platform.openURL.
describe("lurek.platform.openURL", function()
    -- @covers lurek.platform.openURL
    -- @description Verifies the openURL hook is exposed without invoking side effects.
    it("is a function", function()
        expect_type("function", lurek.platform.openURL)
    end)
end)

-- ============================================================
-- lurek.signal.quit (cross-module surface check)
-- ============================================================
-- @description Covers suite: lurek.signal.quit.
describe("lurek.signal.quit", function()
    -- @covers lurek.signal.quit
    -- @description Verifies the signal namespace exists for the quit helper.
    it("lurek.signal is a table", function()
        expect_type("table", lurek.signal)
    end)

    -- @covers lurek.signal.quit
    -- @description Verifies the quit signal helper is exposed.
    it("quit is a function", function()
        expect_type("function", lurek.signal.quit)
    end)
end)
test_summary()
