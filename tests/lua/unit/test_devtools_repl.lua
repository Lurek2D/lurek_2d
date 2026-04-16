-- Lurek2D Lua BDD tests — lurek.devtools REPL console
-- Covers: newRepl, eval, history, clear, len.
-- Headless: no GPU, no audio, no window.

-- @description Covers suite: lurek.devtools REPL console.
describe("lurek.devtools newRepl", function()
    -- @description Covers suite: factory.
    describe("factory", function()
        -- @covers lurek.devtools.newRepl
        -- @description Verifies newRepl is exposed on the devtools namespace.
        it("exposes newRepl", function()
            expect_type("function", lurek.devtools.newRepl)
        end)

        -- @covers lurek.devtools.newRepl
        -- @description Factory returns a userdata.
        it("returns a userdata", function()
            local repl = lurek.devtools.newRepl()
            expect_type("userdata", repl)
        end)

        -- @covers lurek.devtools.newRepl
        -- @description Factory with explicit history limit does not error.
        it("accepts max_history argument", function()
            local repl = lurek.devtools.newRepl(25)
            expect_type("userdata", repl)
        end)
    end)

    -- @description Covers suite: len() and history().
    describe("len() / history()", function()
        -- @covers lurek.devtools:len
        -- @description Starts with zero entries.
        it("starts empty", function()
            local repl = lurek.devtools.newRepl()
            expect_equal(0, repl:len())
        end)

        -- @covers lurek.devtools:history
        -- @description history() returns a table.
        it("history returns a table", function()
            local repl = lurek.devtools.newRepl()
            expect_type("table", repl:history())
        end)

        -- @covers lurek.devtools:history
        -- @description Empty history has zero entries.
        it("empty history has length zero", function()
            local repl = lurek.devtools.newRepl()
            expect_equal(0, #repl:history())
        end)
    end)

    -- @description Covers suite: eval().
    describe("eval()", function()
        -- @covers lurek.devtools:eval
        -- @description eval returns a string.
        it("returns a string for a simple expression", function()
            local repl = lurek.devtools.newRepl()
            local result = repl:eval("1 + 1")
            expect_type("string", result)
        end)

        -- @covers lurek.devtools:eval
        -- @description eval of an arithmetic expression returns the correct value.
        it("evaluates arithmetic expressions", function()
            local repl = lurek.devtools.newRepl()
            local result = repl:eval("2 + 2")
            expect_equal("4", result)
        end)

        -- @covers lurek.devtools:eval
        -- @description eval of a string literal returns the string.
        it("evaluates string literals", function()
            local repl = lurek.devtools.newRepl()
            local result = repl:eval("\"hello\"")
            expect_equal("hello", result)
        end)

        -- @covers lurek.devtools:eval
        -- @description eval of a nil expression returns \"nil\".
        it("evaluates nil as string nil", function()
            local repl = lurek.devtools.newRepl()
            local result = repl:eval("nil")
            expect_equal("nil", result)
        end)

        -- @covers lurek.devtools:eval
        -- @description Calling eval increments len.
        it("increments len after eval", function()
            local repl = lurek.devtools.newRepl()
            repl:eval("1 + 1")
            expect_equal(1, repl:len())
        end)

        -- @covers lurek.devtools:eval
        -- @description Each eval call adds one entry to history.
        it("history grows with each eval", function()
            local repl = lurek.devtools.newRepl()
            repl:eval("1")
            repl:eval("2")
            expect_equal(2, #repl:history())
        end)

        -- @covers lurek.devtools:eval
        -- @description Invalid Lua returns an error string without panicking.
        it("returns error string for invalid Lua", function()
            local repl = lurek.devtools.newRepl()
            local result = repl:eval("!!!not valid lua!!!")
            expect_type("string", result)
        end)
    end)

    -- @description Covers suite: clear().
    describe("clear()", function()
        -- @covers lurek.devtools:clear
        -- @description clear resets len to zero.
        it("resets len to zero", function()
            local repl = lurek.devtools.newRepl()
            repl:eval("42")
            repl:eval("99")
            repl:clear()
            expect_equal(0, repl:len())
        end)

        -- @covers lurek.devtools:clear
        -- @description clear empties the history table.
        it("empties history", function()
            local repl = lurek.devtools.newRepl()
            repl:eval("1")
            repl:clear()
            expect_equal(0, #repl:history())
        end)
    end)
end)

test_summary()
