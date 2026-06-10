-- Lurek2D REPL API unit tests.

local function write_repl_fixture(path, source)
    lurek.filesystem.createDirectory("save/_fs_tests")
    lurek.filesystem.write(path, source)
end

-- @describe lurek.repl module
describe("lurek.repl module", function()
    -- @covers lurek.repl.new
    it("creates a repl session with bounded history capacity", function()
        local repl = lurek.repl.new(8)
        expect_type("userdata", repl)
    end)
end)

-- @describe LReplSession
describe("LReplSession", function()
    -- @covers LReplSession:eval
    it("evaluates expressions, statements, reset, and load commands", function()
        local repl = lurek.repl.new(8)
        expect_equal("4", repl:eval("2 + 2"))
        expect_equal("(ok)", repl:eval("repl_answer = 41"))
        expect_equal("42", repl:eval("repl_answer + 1"))
        expect_contains(repl:eval(":help"), ":load")
        expect_equal("(quit)", repl:eval(":quit"))
        expect_equal("(cleared)", repl:eval(":clear"))
        repl:eval("1 + 1")
        repl:eval("2 + 2")
        expect_equal("(reset)", repl:eval(":reset"))
        expect_contains(repl:eval(":load __nonexistent_repl_test_file__.lua"), "error:")
        expect_contains(repl:eval(":load"), "error:")

        local path = "save/_fs_tests/repl_loaded_snippet.lua"
        write_repl_fixture(path, "loaded_value = 19")
        local result = repl:eval(":load " .. path)
        expect_contains(result, "loaded " .. path)
        expect_equal("19", repl:eval("loaded_value"))
    end)

    -- @covers LReplSession:history
    it("history keeps the most recent bounded results", function()
        local repl = lurek.repl.new(2)
        repl:eval("1")
        repl:eval("2")
        repl:eval("3")
        local history = repl:history()
        expect_equal(2, #history)
        expect_equal("2", history[1])
        expect_equal("3", history[2])
    end)

    -- @covers LReplSession:len
    it("len reports the current history length", function()
        local repl = lurek.repl.new(2)
        expect_equal(0, repl:len())
        repl:eval("1")
        repl:eval("2")
        repl:eval("3")
        expect_equal(2, repl:len())
    end)

    -- @covers LReplSession:clear
    it("clear removes history entries", function()
        local repl = lurek.repl.new(8)
        repl:eval("1")
        repl:eval("2")
        repl:clear()
        expect_equal(0, repl:len())
        expect_equal(0, #repl:history())
    end)

    -- @covers LReplSession:complete
    it("complete includes lurek.repl suggestions", function()
        local repl = lurek.repl.new(8)
        local completions = repl:complete("lurek.re")
        local found = false
        for _, item in ipairs(completions) do
            if item == "lurek.repl" then
                found = true
                break
            end
        end
        expect_true(found)
    end)

    -- @covers LReplSession:type
    it("type returns LReplSession", function()
        local repl = lurek.repl.new(8)
        expect_equal("LReplSession", repl:type())
    end)

    -- @covers LReplSession:typeOf
    it("typeOf recognises supported types", function()
        local repl = lurek.repl.new(8)
        expect_true(repl:typeOf("LReplSession"))
        expect_true(repl:typeOf("LObject"))
        expect_false(repl:typeOf("LOther"))
    end)
end)

test_summary()
