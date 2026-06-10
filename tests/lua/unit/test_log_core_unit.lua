-- Lurek2D logging API unit tests
-- One owner test per public lurek.log symbol.

local function reset_log()
    lurek.log.clearSinks()
    lurek.log.setLevel("debug")
end

local function read_entries(id, drain)
    local entries = lurek.log.readMemory(id, drain)
    expect_type("table", entries)
    return entries
end

local function find_entry(entries, needle)
    for _, entry in ipairs(entries) do
        if type(entry.message) == "string" and string.find(entry.message, needle, 1, true) then
            return entry
        end
    end
    return nil
end

local function expect_entry(entries, needle)
    local entry = find_entry(entries, needle)
    expect_not_nil(entry, "expected log entry containing " .. needle)
    return entry
end

local function expect_level(entry, expected)
    expect_type("string", entry.level)
    expect_equal(expected, string.lower(entry.level))
end

local function new_memory_sink(extra)
    local cfg = { type = "memory", level = "debug", capacity = 32 }
    if extra ~= nil then
        for k, v in pairs(extra) do
            cfg[k] = v
        end
    end
    return lurek.log.addSink(cfg)
end

local function new_file_sink(path, extra)
    local cfg = { type = "file", path = path, level = "debug" }
    if extra ~= nil then
        for k, v in pairs(extra) do
            cfg[k] = v
        end
    end
    return lurek.log.addSink(cfg)
end

-- @describe lurek.log.getLevel
describe("lurek.log.getLevel", function()
    before_each(reset_log)
    after_each(reset_log)

    -- @covers lurek.log.getLevel
    it("returns a non-empty string", function()
        local level = lurek.log.getLevel()
        expect_type("string", level)
        expect_true(#level > 0, "level should not be empty")
    end)
end)

-- @describe lurek.log.setLevel
describe("lurek.log.setLevel", function()
    before_each(reset_log)
    after_each(reset_log)

    -- @covers lurek.log.setLevel
    it("round-trips supported levels", function()
        local levels = { "error", "warn", "info", "debug", "off" }
        for _, level in ipairs(levels) do
            lurek.log.setLevel(level)
            expect_equal(level, lurek.log.getLevel())
        end
    end)
end)

-- @describe lurek.log.addSink
describe("lurek.log.addSink", function()
    before_each(reset_log)
    after_each(reset_log)

    -- @covers lurek.log.addSink
    it("registers a memory sink and returns a positive id", function()
        local id = new_memory_sink()
        expect_type("number", id)
        expect_true(id > 0, "sink id should be positive")
    end)
end)

-- @describe lurek.log.removeSink
describe("lurek.log.removeSink", function()
    before_each(reset_log)
    after_each(reset_log)

    -- @covers lurek.log.removeSink
    it("returns true once and false after the sink is gone", function()
        local id = new_memory_sink()
        expect_true(lurek.log.removeSink(id))
        expect_false(lurek.log.removeSink(id))
    end)
end)

-- @describe lurek.log.clearSinks
describe("lurek.log.clearSinks", function()
    before_each(reset_log)
    after_each(reset_log)

    -- @covers lurek.log.clearSinks
    it("removes all registered sinks", function()
        new_memory_sink()
        new_memory_sink()
        lurek.log.clearSinks()
        expect_equal(0, #lurek.log.listSinks())
    end)
end)

-- @describe lurek.log.listSinks
describe("lurek.log.listSinks", function()
    before_each(reset_log)
    after_each(reset_log)

    -- @covers lurek.log.listSinks
    it("returns sink metadata for registered sinks", function()
        local id = new_memory_sink({ capacity = 8 })
        local sinks = lurek.log.listSinks()
        expect_type("table", sinks)
        local found = false
        for _, sink in ipairs(sinks) do
            if sink.id == id then
                found = true
                expect_equal("memory", sink.type)
            end
        end
        expect_true(found, "expected created sink in metadata list")
    end)
end)

-- @describe lurek.log.readMemory
describe("lurek.log.readMemory", function()
    before_each(reset_log)
    after_each(reset_log)

    -- @covers lurek.log.readMemory
    it("returns entries and supports draining the buffer", function()
        local id = new_memory_sink()
        lurek.log.info("memory-drain-check")
        local first = read_entries(id, true)
        local second = read_entries(id, false)
        expect_true(#first >= 1, "first read should contain entries")
        expect_equal(0, #second)
    end)
end)

-- @describe lurek.log.flushFile
describe("lurek.log.flushFile", function()
    before_each(reset_log)
    after_each(reset_log)

    -- @covers lurek.log.flushFile
    it("flushes file-backed sinks to disk", function()
        local path = "save/_log_flush_file_unit.log"
        local id = new_file_sink(path)
        lurek.log.info("flush-file-check")
        expect_no_error(function()
            lurek.log.flushFile(id)
        end)
        local content = lurek.filesystem.read(path)
        expect_not_nil(content)
        expect_contains(content, "flush-file-check")
    end)
end)

-- @describe lurek.log.info
describe("lurek.log.info", function()
    before_each(reset_log)
    after_each(reset_log)

    -- @covers lurek.log.info
    it("writes an info entry to a memory sink", function()
        local id = new_memory_sink()
        lurek.log.info("info-message", "InfoTag")
        local entry = expect_entry(read_entries(id, false), "info-message")
        expect_level(entry, "info")
        expect_equal("InfoTag", entry.tag)
    end)
end)

-- @describe lurek.log.warn
describe("lurek.log.warn", function()
    before_each(reset_log)
    after_each(reset_log)

    -- @covers lurek.log.warn
    it("writes a warn entry to a memory sink", function()
        local id = new_memory_sink()
        lurek.log.warn("warn-message", "WarnTag")
        local entry = expect_entry(read_entries(id, false), "warn-message")
        expect_level(entry, "warn")
        expect_equal("WarnTag", entry.tag)
    end)
end)

-- @describe lurek.log.error
describe("lurek.log.error", function()
    before_each(reset_log)
    after_each(reset_log)

    -- @covers lurek.log.error
    it("writes an error entry to a memory sink", function()
        local id = new_memory_sink()
        lurek.log.error("error-message", "ErrorTag")
        local entry = expect_entry(read_entries(id, false), "error-message")
        expect_level(entry, "error")
        expect_equal("ErrorTag", entry.tag)
    end)
end)

-- @describe lurek.log.debug
describe("lurek.log.debug", function()
    before_each(reset_log)
    after_each(reset_log)

    -- @covers lurek.log.debug
    it("writes a debug entry when the level allows it", function()
        local id = new_memory_sink()
        lurek.log.debug("debug-message", "DebugTag")
        local entry = expect_entry(read_entries(id, false), "debug-message")
        expect_level(entry, "debug")
        expect_equal("DebugTag", entry.tag)
    end)
end)

-- @describe lurek.log.print
describe("lurek.log.print", function()
    before_each(reset_log)
    after_each(reset_log)

    -- @covers lurek.log.print
    it("logs using a runtime-selected level", function()
        local id = new_memory_sink()
        lurek.log.print("warn", "print-message", "PrintTag")
        local entry = expect_entry(read_entries(id, false), "print-message")
        expect_level(entry, "warn")
        expect_equal("PrintTag", entry.tag)
    end)
end)

-- @describe lurek.log.struct
describe("lurek.log.struct", function()
    before_each(reset_log)
    after_each(reset_log)

    -- @covers lurek.log.struct
    it("stores structured fields in memory entries", function()
        local id = new_memory_sink()
        lurek.log.struct("info", "struct-message", { player = "Alice", score = "100" })
        local entry = expect_entry(read_entries(id, false), "struct-message")
        expect_type("table", entry.fields)
        expect_equal("Alice", entry.fields.player)
        expect_equal("100", entry.fields.score)
    end)
end)

-- @describe lurek.log.debug_fields
describe("lurek.log.debug_fields", function()
    before_each(reset_log)
    after_each(reset_log)

    -- @covers lurek.log.debug_fields
    it("writes debug structured fields", function()
        local id = new_memory_sink()
        lurek.log.debug_fields("debug-fields-message", { module = "anim", dt = "0.016" })
        local entry = expect_entry(read_entries(id, false), "debug-fields-message")
        expect_level(entry, "debug")
        expect_equal("anim", entry.fields.module)
    end)
end)

-- @describe lurek.log.info_fields
describe("lurek.log.info_fields", function()
    before_each(reset_log)
    after_each(reset_log)

    -- @covers lurek.log.info_fields
    it("writes info structured fields", function()
        local id = new_memory_sink()
        lurek.log.info_fields("info-fields-message", { zone = "forest" })
        local entry = expect_entry(read_entries(id, false), "info-fields-message")
        expect_level(entry, "info")
        expect_equal("forest", entry.fields.zone)
    end)
end)

-- @describe lurek.log.warn_fields
describe("lurek.log.warn_fields", function()
    before_each(reset_log)
    after_each(reset_log)

    -- @covers lurek.log.warn_fields
    it("writes warn structured fields", function()
        local id = new_memory_sink()
        lurek.log.warn_fields("warn-fields-message", { bucket = "cache" })
        local entry = expect_entry(read_entries(id, false), "warn-fields-message")
        expect_level(entry, "warn")
        expect_equal("cache", entry.fields.bucket)
    end)
end)

-- @describe lurek.log.error_fields
describe("lurek.log.error_fields", function()
    before_each(reset_log)
    after_each(reset_log)

    -- @covers lurek.log.error_fields
    it("writes error structured fields", function()
        local id = new_memory_sink()
        lurek.log.error_fields("error-fields-message", { reason = "disk" })
        local entry = expect_entry(read_entries(id, false), "error-fields-message")
        expect_level(entry, "error")
        expect_equal("disk", entry.fields.reason)
    end)
end)

reset_log()
test_summary()
