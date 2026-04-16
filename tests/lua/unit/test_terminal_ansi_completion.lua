-- tests/lua/unit/test_terminal_ansi_completion.lua
-- Tests for lurek.terminal ANSI support and tab-completion engine.
-- No GPU, audio, or window calls.

describe("terminal.stripAnsi", function()

    it("stripAnsi exists in lurek.terminal", function()
        expect_equal(type(lurek.terminal.stripAnsi), "function")
    end)

    it("strips a simple red color code", function()
        local result = lurek.terminal.stripAnsi("\27[31mHello\27[0m world")
        expect_equal(result, "Hello world")
    end)

    it("strips empty ESC sequence", function()
        local result = lurek.terminal.stripAnsi("\27[mText")
        expect_equal(result, "Text")
    end)

    it("returns plain text unchanged", function()
        local result = lurek.terminal.stripAnsi("no escape codes here")
        expect_equal(result, "no escape codes here")
    end)

    it("strips multiple sequences", function()
        local result = lurek.terminal.stripAnsi("\27[1m\27[32mBold Green\27[0m")
        expect_equal(result, "Bold Green")
    end)

end)

describe("terminal.parseAnsi", function()

    it("parseAnsi exists in lurek.terminal", function()
        expect_equal(type(lurek.terminal.parseAnsi), "function")
    end)

    it("returns a table for plain text", function()
        local spans = lurek.terminal.parseAnsi("hello")
        expect_equal(type(spans), "table")
        expect_equal(#spans, 1)
        expect_equal(spans[1].text, "hello")
    end)

    it("span has bold=false for plain text", function()
        local spans = lurek.terminal.parseAnsi("plain")
        expect_equal(spans[1].bold, false)
    end)

    it("bold flag is set for ESC[1m", function()
        local spans = lurek.terminal.parseAnsi("\27[1mBold\27[0m")
        local bold_span = nil
        for _, s in ipairs(spans) do
            if s.text == "Bold" then bold_span = s end
        end
        expect_equal(bold_span ~= nil, true)
        expect_equal(bold_span.bold, true)
    end)

    it("fg color set for ESC[31m (red)", function()
        local spans = lurek.terminal.parseAnsi("\27[31mred\27[0m")
        local red_span = nil
        for _, s in ipairs(spans) do
            if s.text == "red" then red_span = s end
        end
        expect_equal(red_span ~= nil, true)
        expect_equal(type(red_span.fg), "table")
        expect_equal(red_span.fg.r > 0, true)
    end)

    it("reset clears color", function()
        local spans = lurek.terminal.parseAnsi("\27[31mred\27[0mnormal")
        local normal = nil
        for _, s in ipairs(spans) do
            if s.text == "normal" then normal = s end
        end
        expect_equal(normal ~= nil, true)
        expect_equal(normal.fg, nil)
    end)

end)

describe("terminal.completion", function()

    it("addCompletion and getCompletions work", function()
        lurek.terminal.clearCompletions()
        lurek.terminal.addCompletion("help")
        lurek.terminal.addCompletion("hello")
        lurek.terminal.addCompletion("quit")
        local results = lurek.terminal.getCompletions("hel")
        expect_equal(type(results), "table")
        expect_equal(#results, 2)
    end)

    it("getCompletions returns empty for no match", function()
        lurek.terminal.clearCompletions()
        lurek.terminal.addCompletion("world")
        local results = lurek.terminal.getCompletions("xyz")
        expect_equal(#results, 0)
    end)

    it("nextCompletion returns a string for matching prefix", function()
        lurek.terminal.clearCompletions()
        lurek.terminal.addCompletion("help")
        local result = lurek.terminal.nextCompletion("hel")
        expect_equal(result, "help")
    end)

    it("nextCompletion returns nil for no match", function()
        lurek.terminal.clearCompletions()
        local result = lurek.terminal.nextCompletion("xyz")
        expect_equal(result, nil)
    end)

    it("nextCompletion cycles on repeated calls", function()
        lurek.terminal.clearCompletions()
        lurek.terminal.addCompletion("hello")
        lurek.terminal.addCompletion("help")
        local first  = lurek.terminal.nextCompletion("hel")
        local second = lurek.terminal.nextCompletion("hel")
        expect_equal(first ~= second, true)
    end)

    it("resetCompletion resets cycle", function()
        lurek.terminal.clearCompletions()
        lurek.terminal.addCompletion("hello")
        lurek.terminal.addCompletion("help")
        lurek.terminal.nextCompletion("hel")  -- advance cycle
        lurek.terminal.resetCompletion()
        local after_reset = lurek.terminal.nextCompletion("hel")
        -- After reset, should return first candidate again
        expect_equal(after_reset ~= nil, true)
    end)

    it("removeCompletion removes a candidate", function()
        lurek.terminal.clearCompletions()
        lurek.terminal.addCompletion("help")
        lurek.terminal.addCompletion("hello")
        lurek.terminal.removeCompletion("help")
        local results = lurek.terminal.getCompletions("hel")
        expect_equal(#results, 1)
        expect_equal(results[1], "hello")
    end)

    it("clearCompletions empties the list", function()
        lurek.terminal.addCompletion("anything")
        lurek.terminal.clearCompletions()
        local results = lurek.terminal.getCompletions("")
        expect_equal(#results, 0)
    end)

end)

test_summary()
