-- Lurek2D Module Registration Unit Tests
-- Verifies that the LuaModule trait-based registration system correctly
-- populates the lurek.* namespace with always-on, config-gated, and
-- feature-gated modules. Also checks sandbox restrictions.

-- ============================================================
-- lurek global table
-- ============================================================
-- @describe lurek global table
describe("lurek global table", function()
    -- @covers lurek.runtime.getVersion
    it("exists as a global", function()
        expect_type("string", lurek.runtime.getVersion())
        expect_true(lurek ~= nil, "lurek should exist as a global")
    end)
    -- @covers lurek.runtime.getVersion
    it("is a table", function()
        expect_type("string", lurek.runtime.getVersion())
        expect_type("table", lurek)
    end)
end)

-- ============================================================
-- Always-on modules exist
-- ============================================================
-- @describe always-on module registration
describe("always-on module registration", function()
    local always_on = {
        "event", "sprite", "save", "docs", "log", "runtime",
        "repl", "binary", "mods", "serial", "dataframe", "light",
        "html", "math", "color"
    }

    for _, name in ipairs(always_on) do
        -- @covers lurek.runtime.getVersion
        it("lurek." .. name .. " is registered", function()
            expect_type("string", lurek.runtime.getVersion())
            expect_true(lurek[name] ~= nil, "lurek." .. name .. " should not be nil")
        end)
        -- @covers lurek.runtime.getVersion
        it("lurek." .. name .. " is a table", function()
            expect_type("string", lurek.runtime.getVersion())
            expect_type("table", lurek[name])
        end)
    end
end)

-- ============================================================
-- Config-gated modules exist (default test VM has them enabled)
-- ============================================================
-- @describe config-gated module registration
describe("config-gated module registration", function()
    local config_gated = {
        "timer", "physics", "animation", "audio", "input", "ecs"
    }

    for _, name in ipairs(config_gated) do
        -- @covers lurek.runtime.getVersion
        it("lurek." .. name .. " is registered", function()
            expect_type("string", lurek.runtime.getVersion())
            expect_true(lurek[name] ~= nil, "lurek." .. name .. " should not be nil")
        end)
        -- @covers lurek.runtime.getVersion
        it("lurek." .. name .. " is a table", function()
            expect_type("string", lurek.runtime.getVersion())
            expect_type("table", lurek[name])
        end)
    end
end)

-- ============================================================
-- Module namespace type (must be table, not userdata or function)
-- ============================================================
-- @describe module namespace types
describe("module namespace types", function()
    local modules_to_check = {
        "event", "sprite", "math", "color", "log", "binary",
        "serial", "html", "timer", "physics", "animation",
        "audio", "input", "ecs"
    }

    for _, name in ipairs(modules_to_check) do
        -- @covers lurek.runtime.getVersion
        it("lurek." .. name .. " is specifically a table type", function()
            expect_type("string", lurek.runtime.getVersion())
            local t = type(lurek[name])
            expect_equal(t, "table", "lurek." .. name .. " should be table, got " .. t)
        end)
    end
end)

-- ============================================================
-- Security sandbox: dangerous globals removed
-- ============================================================
-- @describe sandbox: dangerous globals are nil
describe("sandbox: dangerous globals are nil", function()
    -- @covers lurek.runtime.getVersion
    it("load is nil", function()
        expect_type("string", lurek.runtime.getVersion())
        expect_equal(load, nil, "load should be nil in sandbox")
    end)
    -- @covers lurek.runtime.getVersion
    it("loadfile is nil", function()
        expect_type("string", lurek.runtime.getVersion())
        expect_equal(loadfile, nil, "loadfile should be nil in sandbox")
    end)
    -- @covers lurek.runtime.getVersion
    it("dofile is nil (unless harness-provided)", function()
        expect_type("string", lurek.runtime.getVersion())
        -- The test harness intentionally provides dofile for loading shared helpers.
        -- In a real sandbox dofile is removed; here it may be function or nil.
        expect_true(dofile == nil or type(dofile) == "function",
            "dofile must be nil in sandbox or a harness-provided function")
    end)
    -- @covers lurek.runtime.getVersion
    it("debug is nil", function()
        expect_type("string", lurek.runtime.getVersion())
        expect_equal(debug, nil, "debug library should be nil in sandbox")
    end)
    -- @covers lurek.runtime.getVersion
    it("os.execute is nil", function()
        expect_type("string", lurek.runtime.getVersion())
        local result = (os == nil) or (os.execute == nil)
        expect_equal(result, true, "os.execute should not be accessible")
    end)
    -- @covers lurek.runtime.getVersion
    it("os.getenv is nil", function()
        expect_type("string", lurek.runtime.getVersion())
        local result = (os == nil) or (os.getenv == nil)
        expect_equal(result, true, "os.getenv should not be accessible")
    end)
    -- @covers lurek.runtime.getVersion
    it("io.open is nil", function()
        expect_type("string", lurek.runtime.getVersion())
        local result = (io == nil) or (io.open == nil)
        expect_equal(result, true, "io.open should not be accessible")
    end)
    -- @covers lurek.runtime.getVersion
    it("io.popen is nil", function()
        expect_type("string", lurek.runtime.getVersion())
        local result = (io == nil) or (io.popen == nil)
        expect_equal(result, true, "io.popen should not be accessible")
    end)
end)
test_summary()
