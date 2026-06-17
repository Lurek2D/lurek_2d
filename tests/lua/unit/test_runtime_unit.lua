-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_runtime_core_unit.lua
do
-- Lurek2D Runtime Unit Tests
-- Headless-safe runtime API coverage with one owner test per public symbol.

-- @describe lurek.runtime.getOS
describe("lurek.runtime.getOS", function()
    -- @covers lurek.runtime.getOS
    it("returns a recognised OS name", function()
        expect_type("function", lurek.runtime.getOS)
        local os = lurek.runtime.getOS()
        expect_type("string", os)
        local valid = {
            Windows = true,
            Linux = true,
            macOS = true,
            Android = true,
            iOS = true,
            Unknown = true,
        }
        expect_true(valid[os] == true, "OS should be recognised, got: " .. tostring(os))
    end)
end)

-- @describe lurek.runtime.getVersion
describe("lurek.runtime.getVersion", function()
    -- @covers lurek.runtime.getVersion
    it("returns a non-empty string", function()
        expect_type("function", lurek.runtime.getVersion)
        local ver = lurek.runtime.getVersion()
        expect_type("string", ver)
        expect_true(#ver > 0, "version should not be empty")
    end)
end)

-- @describe lurek.runtime.getArch
describe("lurek.runtime.getArch", function()
    -- @covers lurek.runtime.getArch
    it("returns a non-empty architecture string", function()
        expect_type("function", lurek.runtime.getArch)
        local arch = lurek.runtime.getArch()
        expect_type("string", arch)
        expect_true(#arch > 0, "arch should not be empty")
    end)
end)

-- @describe lurek.runtime.getProcessorCount
describe("lurek.runtime.getProcessorCount", function()
    -- @covers lurek.runtime.getProcessorCount
    it("returns a positive integer", function()
        expect_type("function", lurek.runtime.getProcessorCount)
        local n = lurek.runtime.getProcessorCount()
        expect_type("number", n)
        expect_true(n >= 1, "processor count should be at least 1")
        expect_true(n == math.floor(n), "should be an integer")
    end)
end)

-- @describe lurek.runtime.getMemorySize
describe("lurek.runtime.getMemorySize", function()
    -- @covers lurek.runtime.getMemorySize
    it("returns a positive memory size in MiB", function()
        expect_type("function", lurek.runtime.getMemorySize)
        local mb = lurek.runtime.getMemorySize()
        expect_type("number", mb)
        expect_true(mb > 0, "memory should be positive")
    end)
end)

-- @describe lurek.runtime.getInfo
describe("lurek.runtime.getInfo", function()
    -- @covers lurek.runtime.getInfo
    it("returns a populated engine info table", function()
        expect_type("function", lurek.runtime.getInfo)
        local info = lurek.runtime.getInfo()
        expect_type("table", info)
        expect_equal("Lurek2D", info.engine)
        expect_type("string", info.version)
        expect_true(#info.version > 0)
        expect_contains(info.lua_version, "Lua")
        expect_equal("wgpu", info.renderer)
        expect_type("string", info.os)
        expect_type("number", info.processors)
        expect_true(info.processors >= 1)
        expect_type("number", info.memory)
        expect_true(info.memory > 0)
    end)
end)

-- @describe lurek.runtime.setClipboardText
describe("lurek.runtime.setClipboardText", function()
    -- @covers lurek.runtime.setClipboardText
    it("accepts clipboard writes without error", function()
        expect_type("function", lurek.runtime.setClipboardText)
        lurek.runtime.setClipboardText("lurek2d test")
    end)
end)

-- @describe lurek.runtime.getClipboardText
describe("lurek.runtime.getClipboardText", function()
    -- @covers lurek.runtime.getClipboardText
    it("returns a string when clipboard access is available", function()
        expect_type("function", lurek.runtime.getClipboardText)
        local text = lurek.runtime.getClipboardText()
        if text ~= nil then
            expect_type("string", text)
        end
    end)
end)

-- @describe lurek.runtime.setDebugOverlay
describe("lurek.runtime.setDebugOverlay", function()
    -- @covers lurek.runtime.setDebugOverlay
    it("toggles overlay state without error", function()
        expect_type("function", lurek.runtime.setDebugOverlay)
        lurek.runtime.setDebugOverlay(true)
        expect_equal(true, lurek.runtime.getDebugOverlay())
        lurek.runtime.setDebugOverlay(false)
        expect_equal(false, lurek.runtime.getDebugOverlay())
    end)
end)

-- @describe lurek.runtime.getDebugOverlay
describe("lurek.runtime.getDebugOverlay", function()
    -- @covers lurek.runtime.getDebugOverlay
    it("returns a boolean", function()
        expect_type("function", lurek.runtime.getDebugOverlay)
        local value = lurek.runtime.getDebugOverlay()
        expect_true(value == true or value == false, "debug overlay must be boolean")
    end)
end)

-- @describe lurek.runtime.setLogLevel
describe("lurek.runtime.setLogLevel", function()
    -- @covers lurek.runtime.setLogLevel
    it("round-trips supported log levels", function()
        expect_type("function", lurek.runtime.setLogLevel)
        local levels = { "warn", "debug", "info", "error" }
        for _, level in ipairs(levels) do
            lurek.runtime.setLogLevel(level)
            expect_equal(level, lurek.runtime.getLogLevel())
        end
    end)
end)

-- @describe lurek.runtime.getLogLevel
describe("lurek.runtime.getLogLevel", function()
    -- @covers lurek.runtime.getLogLevel
    it("returns a non-empty string", function()
        expect_type("function", lurek.runtime.getLogLevel)
        local level = lurek.runtime.getLogLevel()
        expect_type("string", level)
        expect_true(#level > 0)
    end)
end)

-- @describe lurek.runtime.log
describe("lurek.runtime.log", function()
    -- @covers lurek.runtime.log
    it("accepts standard log levels without error", function()
        expect_type("function", lurek.runtime.log)
        lurek.runtime.log("info", "test log message")
        lurek.runtime.log("warn", "test warn message")
        lurek.runtime.log("error", "test error message")
    end)
end)

-- @describe lurek.runtime.getLastError
describe("lurek.runtime.getLastError", function()
    -- @covers lurek.runtime.getLastError
    it("returns nil or a table", function()
        expect_type("function", lurek.runtime.getLastError)
        local err = lurek.runtime.getLastError()
        local t = type(err)
        expect_true(t == "nil" or t == "table", "expected nil or table, got " .. t)
    end)
end)

-- @describe lurek.runtime.getEnv
describe("lurek.runtime.getEnv", function()
    -- @covers lurek.runtime.getEnv
    it("reads unset and set environment variables safely", function()
        expect_type("function", lurek.runtime.getEnv)
        expect_equal(nil, lurek.runtime.getEnv("LUREK2D_NONEXISTENT_VAR_12345"))
        local path = lurek.runtime.getEnv("PATH")
        if path ~= nil then
            expect_type("string", path)
        end
    end)
end)

-- @describe lurek.runtime.getArgs
describe("lurek.runtime.getArgs", function()
    -- @covers lurek.runtime.getArgs
    it("returns a table", function()
        expect_type("function", lurek.runtime.getArgs)
        local args = lurek.runtime.getArgs()
        expect_type("table", args)
    end)
end)

-- @describe lurek.runtime.parseArgs
describe("lurek.runtime.parseArgs", function()
    -- @covers lurek.runtime.parseArgs
    it("parses flags, options, and positional arguments", function()
        expect_type("function", lurek.runtime.parseArgs)

        local empty = lurek.runtime.parseArgs({})
        expect_type("table", empty)
        expect_type("table", empty.flags)
        expect_type("table", empty.options)
        expect_type("table", empty.positional)

        local flags = lurek.runtime.parseArgs({"--verbose", "--debug"})
        expect_equal(true, flags.flags.verbose)
        expect_equal(true, flags.flags.debug)

        local option = lurek.runtime.parseArgs({"--output=foo.txt"})
        expect_equal("foo.txt", option.options.output)

        local positional = lurek.runtime.parseArgs({"file1.lua", "file2.lua"})
        expect_equal(2, #positional.positional)
        expect_equal("file1.lua", positional.positional[1])
    end)
end)

-- @describe lurek.runtime.getMessage
describe("lurek.runtime.getMessage", function()
    -- @covers lurek.runtime.getMessage
    it("resolves known ids and falls back for unknown ids", function()
        expect_type("function", lurek.runtime.getMessage)
        expect_equal("Lurek2D Engine starting", lurek.runtime.getMessage("L001"))
        expect_equal("Game loaded", lurek.runtime.getMessage("L003"))
        expect_equal("Render error", lurek.runtime.getMessage("L010"))
        expect_equal("ZZUNKNOWN", lurek.runtime.getMessage("ZZUNKNOWN"))
    end)
end)

-- @describe lurek.runtime.hasMessage
describe("lurek.runtime.hasMessage", function()
    -- @covers lurek.runtime.hasMessage
    it("distinguishes known and unknown ids", function()
        expect_type("function", lurek.runtime.hasMessage)
        expect_equal(true, lurek.runtime.hasMessage("L001"))
        expect_equal(false, lurek.runtime.hasMessage("ZZUNKNOWN"))
    end)
end)

-- @describe lurek.runtime.getMessageCount
describe("lurek.runtime.getMessageCount", function()
    -- @covers lurek.runtime.getMessageCount
    it("returns a non-trivial catalog size", function()
        expect_type("function", lurek.runtime.getMessageCount)
        expect_true(lurek.runtime.getMessageCount() >= 30)
    end)
end)

-- @describe lurek.runtime.getPowerInfo
describe("lurek.runtime.getPowerInfo", function()
    -- @covers lurek.runtime.getPowerInfo
    it("returns a string state as the first value", function()
        expect_type("function", lurek.runtime.getPowerInfo)
        local state = lurek.runtime.getPowerInfo()
        expect_type("string", state)
    end)
end)

-- @describe lurek.runtime.getPreferredLocales
describe("lurek.runtime.getPreferredLocales", function()
    -- @covers lurek.runtime.getPreferredLocales
    it("returns a table", function()
        expect_type("function", lurek.runtime.getPreferredLocales)
        local locales = lurek.runtime.getPreferredLocales()
        expect_type("table", locales)
    end)
end)

-- @describe lurek.runtime.openURL
describe("lurek.runtime.openURL", function()
    -- @covers lurek.runtime.openURL
    it("is exposed as a function", function()
        expect_type("function", lurek.runtime.openURL)
    end)
end)

-- @describe lurek.runtime.errorSnapshot
describe("lurek.runtime.errorSnapshot", function()
    -- @covers lurek.runtime.errorSnapshot
    it("returns a JSON-like string with standard fields", function()
        expect_type("function", lurek.runtime.errorSnapshot)
        local json = lurek.runtime.errorSnapshot("test error")
        expect_equal("string", type(json))
        expect_true(#json > 0)
        expect_true(json:find('"message"') ~= nil)
        expect_true(json:find('"code"') ~= nil)
        expect_true(json:find('"category"') ~= nil)
    end)
end)

-- @describe lurek.runtime.reloadConfig
describe("lurek.runtime.reloadConfig", function()
    -- @covers lurek.runtime.reloadConfig
    it("does not error when called", function()
        expect_type("function", lurek.runtime.reloadConfig)
        lurek.runtime.reloadConfig()
    end)
end)

-- @describe lurek.runtime.getConfig
describe("lurek.runtime.getConfig", function()
    -- @covers lurek.runtime.getConfig
    it("returns a populated runtime config table", function()
        expect_type("function", lurek.runtime.getConfig)
        local cfg = lurek.runtime.getConfig()
        expect_type("table", cfg)
        expect_type("string", cfg.runtime_mode)
        expect_true(
            cfg.runtime_mode == "gui" or cfg.runtime_mode == "tui" or
            cfg.runtime_mode == "headless" or cfg.runtime_mode == "cli",
            "runtime_mode must be supported"
        )
        expect_type("number", cfg.physics_tick_rate)
        expect_true(cfg.physics_tick_rate >= 1)
        expect_true(cfg.vsync == true or cfg.vsync == false)
        expect_type("string", cfg.log_level)
        expect_true(#cfg.log_level > 0)
        expect_type("number", cfg.config_reload_revision)
        expect_true(cfg.config_reload_revision >= 0)
    end)
end)

-- @describe lurek.runtime.runBatch
describe("lurek.runtime.runBatch", function()
    -- @covers lurek.runtime.runBatch
    it("records per-task pass and fail states", function()
        local results = lurek.runtime.runBatch({
            ok = function()
                return true
            end,
            nope = function()
                error("boom")
            end,
        })

        expect_type("table", results)
        expect_equal("passed", results.ok.status)
        expect_equal("failed", results.nope.status)
        expect_type("number", results.ok.time)
        expect_type("number", results.nope.time)
        expect_type("string", results.nope.error)
    end)
end)

-- @describe lurek.runtime.getBatchResults
describe("lurek.runtime.getBatchResults", function()
    -- @covers lurek.runtime.getBatchResults
    it("summarises passed failed and skipped task counts", function()
        local results = {
            ok = { status = "passed", time = 0.01 },
            nope = { status = "failed", time = 0.02, error = "nope" },
            later = { status = "skipped", time = 0.0 },
        }

        local passed, failed, skipped = lurek.runtime.getBatchResults(results)
        expect_equal(1, passed)
        expect_equal(1, failed)
        expect_equal(1, skipped)
    end)
end)
end
-- END test_runtime_core_unit.lua

test_summary()
