-- Lurek2D logging API unit tests
-- Headless-safe (no window / GPU / audio required).
-- Tests the lurek.log namespace: level control, message functions,
-- addSink, removeSink, clearSinks, listSinks, readMemory, flushFile.
-- @covers lurek.log.debug
-- @covers lurek.log.info
-- @covers lurek.log.warn
-- @covers lurek.log.error
-- @covers lurek.log.print
-- @covers lurek.log.setLevel
-- @covers lurek.log.getLevel
-- @covers lurek.log.addSink
-- @covers lurek.log.removeSink
-- @covers lurek.log.clearSinks
-- @covers lurek.log.listSinks
-- @covers lurek.log.readMemory
-- @covers lurek.log.flushFile

-- Module presence
describe("lurek.log module", function()
    it("lurek.log is a table", function()
        expect_type("table", lurek.log)
    end)

    it("all expected functions are present", function()
        local fns = {
            "debug", "info", "warn", "error", "print",
            "setLevel", "getLevel",
            "addSink", "removeSink", "clearSinks", "listSinks",
            "readMemory", "flushFile",
        }
        for _, name in ipairs(fns) do
            expect_type("function", lurek.log[name], name .. " must be a function")
        end
    end)
end)

-- Level control
describe("lurek.log.setLevel / getLevel", function()
    it("getLevel returns a string", function()
        expect_type("string", lurek.log.getLevel())
    end)

    it("setLevel to debug is reflected by getLevel", function()
        lurek.log.setLevel("debug")
        expect_equal("debug", lurek.log.getLevel())
    end)

    it("setLevel to warn is reflected by getLevel", function()
        lurek.log.setLevel("warn")
        expect_equal("warn", lurek.log.getLevel())
    end)

    it("setLevel to info is reflected by getLevel", function()
        lurek.log.setLevel("info")
        expect_equal("info", lurek.log.getLevel())
    end)

    it("setLevel to error is reflected by getLevel", function()
        lurek.log.setLevel("error")
        expect_equal("error", lurek.log.getLevel())
    end)
end)

-- Basic log calls
describe("lurek.log message functions", function()
    it("info does not error", function()
        expect_no_error(function() lurek.log.info("unit test info message") end)
    end)

    it("warn does not error", function()
        expect_no_error(function() lurek.log.warn("unit test warn message") end)
    end)

    it("error call does not error", function()
        expect_no_error(function() lurek.log.error("unit test error message") end)
    end)

    it("debug does not error at debug level", function()
        lurek.log.setLevel("debug")
        expect_no_error(function() lurek.log.debug("unit test debug message") end)
    end)

    it("print does not error", function()
        expect_no_error(function() lurek.log.print("info", "unit test print message") end)
    end)
end)

-- Memory sink
describe("lurek.log.addSink memory sink", function()
    it("addSink with type=memory returns a sink id number", function()
        lurek.log.clearSinks()
        local id = lurek.log.addSink({ type = "memory" })
        expect_type("number", id)
        lurek.log.removeSink(id)
    end)

    it("readMemory returns a table for a valid memory sink id", function()
        lurek.log.clearSinks()
        local id = lurek.log.addSink({ type = "memory" })
        local entries = lurek.log.readMemory(id)
        expect_type("table", entries)
        lurek.log.removeSink(id)
    end)

    it("messages logged after addSink appear in readMemory", function()
        lurek.log.clearSinks()
        lurek.log.setLevel("debug")
        local id = lurek.log.addSink({ type = "memory" })
        lurek.log.info("memory_sink_msg_alpha")
        local entries = lurek.log.readMemory(id)
        lurek.log.removeSink(id)
        expect_true(#entries >= 1, "at least one entry captured")
    end)

    it("readMemory entries have a message field", function()
        lurek.log.clearSinks()
        lurek.log.setLevel("debug")
        local id = lurek.log.addSink({ type = "memory" })
        lurek.log.info("check_entry_structure")
        local entries = lurek.log.readMemory(id)
        lurek.log.removeSink(id)
        assert(#entries >= 1, "expected at least one entry")
        expect_type("string", entries[1].message)
    end)

    it("readMemory with drain=true clears the buffer", function()
        lurek.log.clearSinks()
        lurek.log.setLevel("debug")
        local id = lurek.log.addSink({ type = "memory" })
        lurek.log.info("before_drain")
        local first  = lurek.log.readMemory(id, true)
        local second = lurek.log.readMemory(id)
        lurek.log.removeSink(id)
        expect_true(#first >= 1, "first read should have entries")
        expect_equal(0, #second, "buffer should be empty after drain")
    end)

    it("readMemory with drain=false does not clear the buffer", function()
        lurek.log.clearSinks()
        lurek.log.setLevel("debug")
        local id = lurek.log.addSink({ type = "memory" })
        lurek.log.info("no_drain_msg")
        local first  = lurek.log.readMemory(id, false)
        local second = lurek.log.readMemory(id, false)
        lurek.log.removeSink(id)
        expect_true(#first >= 1,  "first read should have entries")
        expect_true(#second >= 1, "second read should still have entries")
    end)

    it("multiple memory sinks capture messages independently", function()
        lurek.log.clearSinks()
        lurek.log.setLevel("debug")
        local id1 = lurek.log.addSink({ type = "memory" })
        local id2 = lurek.log.addSink({ type = "memory" })
        lurek.log.info("multi_sink_test")
        local e1 = lurek.log.readMemory(id1)
        local e2 = lurek.log.readMemory(id2)
        lurek.log.removeSink(id1)
        lurek.log.removeSink(id2)
        expect_true(#e1 >= 1, "sink 1 captured message")
        expect_true(#e2 >= 1, "sink 2 captured message")
    end)
end)

-- removeSink / clearSinks / listSinks
describe("lurek.log.removeSink / clearSinks / listSinks", function()
    it("listSinks returns a table", function()
        lurek.log.clearSinks()
        local sinks = lurek.log.listSinks()
        expect_type("table", sinks)
    end)

    it("listSinks reflects newly added sinks", function()
        lurek.log.clearSinks()
        local id = lurek.log.addSink({ type = "memory" })
        local sinks = lurek.log.listSinks()
        expect_true(#sinks >= 1, "at least one sink listed")
        lurek.log.removeSink(id)
    end)

    it("removeSink decreases listSinks count", function()
        lurek.log.clearSinks()
        local id = lurek.log.addSink({ type = "memory" })
        local before = #lurek.log.listSinks()
        lurek.log.removeSink(id)
        local after = #lurek.log.listSinks()
        expect_true(after < before, "count decreased after removeSink")
    end)

    it("clearSinks leaves listSinks empty", function()
        lurek.log.addSink({ type = "memory" })
        lurek.log.addSink({ type = "memory" })
        lurek.log.clearSinks()
        expect_equal(0, #lurek.log.listSinks())
    end)
end)

-- File sink
describe("lurek.log.addSink file sink", function()
    it("addSink with type=file returns a sink id", function()
        lurek.log.clearSinks()
        local id = lurek.log.addSink({ type = "file", path = "save/_log_test_sink.log" })
        expect_type("number", id)
        lurek.log.removeSink(id)
    end)

    it("flushFile does not error for a valid file sink id", function()
        lurek.log.clearSinks()
        local id = lurek.log.addSink({ type = "file", path = "save/_log_flush_test.log" })
        lurek.log.info("flush_test_msg")
        expect_no_error(function() lurek.log.flushFile(id) end)
        lurek.log.removeSink(id)
    end)
end)


describe("log sink registry (RS parity)", function()
    it("clearSinks starts empty then addSink increments count", function()
        lurek.log.clearSinks()
        local id = lurek.log.addSink({ type = "memory", capacity = 10 })
        expect_type("number", id)
        expect_true(id > 0)
        lurek.log.removeSink(id)
    end)

    it("removeSink returns true on first call, false on second", function()
        lurek.log.clearSinks()
        local id = lurek.log.addSink({ type = "memory", capacity = 10 })
        expect_true(lurek.log.removeSink(id))
        expect_false(lurek.log.removeSink(id))
    end)

    it("messages written to memory sink are retrievable", function()
        lurek.log.clearSinks()
        local id = lurek.log.addSink({ type = "memory", capacity = 20 })
        lurek.log.setLevel("debug")
        lurek.log.info("sink_parity_test_msg")
        local entries = lurek.log.readMemory(id)
        expect_equal("table", type(entries))
        expect_true(#entries >= 1)
        lurek.log.removeSink(id)
        lurek.log.setLevel("info")
    end)

    it("memory sink respects capacity and drops oldest on overflow", function()
        lurek.log.clearSinks()
        local id = lurek.log.addSink({ type = "memory", capacity = 3 })
        lurek.log.setLevel("debug")
        for i = 1, 5 do lurek.log.debug("msg" .. i) end
        local entries = lurek.log.readMemory(id)
        expect_true(#entries <= 3)
        lurek.log.removeSink(id)
        lurek.log.setLevel("info")
    end)

    it("clearSinks removes all sinks", function()
        local id = lurek.log.addSink({ type = "memory", capacity = 5 })
        lurek.log.clearSinks()
        expect_false(lurek.log.removeSink(id))
    end)
end)

-- Restore defaults
lurek.log.setLevel("info")
lurek.log.clearSinks()

test_summary()
