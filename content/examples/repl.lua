-- content/examples/repl.lua
-- Auto-generated from content/examples2/repl_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/repl.lua

--- REPL Module: interactive Lua evaluation session


--@api-stub: lurek.repl.new
-- Creating a REPL session with default history size.
do
    ---@type LReplSession
    local repl = lurek.repl.new()
    print("type = " .. repl:type())
    print("initial len = " .. repl:len())
end

--@api-stub: LReplSession:eval
-- Evaluating Lua expressions.
do
    ---@type LReplSession
    local repl = lurek.repl.new()
    local r1 = repl:eval("return 2 + 2")
    print("2+2 = " .. r1)
end

--@api-stub: LReplSession:history
-- Retrieving evaluation history.
do
    ---@type LReplSession
    local repl = lurek.repl.new()
    repl:eval("return 1")
    repl:eval("return 2")
    repl:eval("return 3")
    local hist = repl:history()
    print("history entries = " .. #hist)
end

--@api-stub: LReplSession:complete
-- Tab-completion of Lua symbols.
do
    ---@type LReplSession
    local repl = lurek.repl.new()
    repl:eval("myVariable = 42")
    local completions = repl:complete("my")
    print("completions for 'my' = " .. #completions)
end

--@api-stub: LReplSession:clear
-- Clearing session history.
do
    ---@type LReplSession
    local repl = lurek.repl.new()
    repl:eval("return 1")
    repl:eval("return 2")
    repl:eval("return 3")
    print("before clear = " .. repl:len())
    repl:clear()
    print("after clear = " .. repl:len())
    local hist = repl:history()
    print("history after clear = " .. #hist)
end

--@api-stub: LReplSession:len
-- Tracking history length.
do
    ---@type LReplSession
    local repl = lurek.repl.new()
    print("empty = " .. repl:len())
    repl:eval("return 'a'")
    print("after 1 eval = " .. repl:len())
    repl:eval("return 'b'")
    repl:eval("return 'c'")
    print("after 3 evals = " .. repl:len())
    repl:clear()
    print("after clear = " .. repl:len())
end

--@api-stub: LReplSession:type
-- Type introspection on LReplSession. Focus: type.
do
    ---@type LReplSession
    local sess = lurek.repl.new()
    print(sess:type())
end

--@api-stub: LReplSession:typeOf
-- Type introspection on LReplSession. Focus: typeOf.
do
    ---@type LReplSession
    local sess = lurek.repl.new()
    print(sess:typeOf("LReplSession"))
end

print("content/examples/repl.lua")
