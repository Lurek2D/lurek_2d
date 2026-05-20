-- content/examples/repl.lua
-- Auto-generated from content/examples2/repl_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/repl.lua

--- REPL Module: interactive Lua evaluation session


--@api-stub: lurek.repl.new
do
    ---@type LReplSession
    local repl = lurek.repl.new()
    print("type = " .. repl:type())
    print("initial len = " .. repl:len())
end

--@api-stub: LReplSession:eval
do
    ---@type LReplSession
    local repl = lurek.repl.new()
    local r1 = repl:eval("return 2 + 2")
    print("2+2 = " .. r1)
end

--@api-stub: LReplSession:history
do
    local repl = lurek.repl.new()
    repl:eval("return 1")
    local hist = repl:history()
    print("history entries = " .. #hist)
end

--@api-stub: LReplSession:complete
do
    ---@type LReplSession
    local repl = lurek.repl.new()
    repl:eval("myVariable = 42")
    local completions = repl:complete("my")
    print("completions for 'my' = " .. #completions)
end

--@api-stub: LReplSession:clear
do
    local repl = lurek.repl.new()
    repl:eval("return 1")
    repl:clear()
    print("after clear = " .. repl:len() .. " history=" .. #repl:history())
end

--@api-stub: LReplSession:len
do
    local repl = lurek.repl.new()
    repl:eval("return 'a'")
    print("len = " .. repl:len())
    repl:clear()
    print("after clear = " .. repl:len())
end

--@api-stub: LReplSession:type
do
    ---@type LReplSession
    local sess = lurek.repl.new()
    print(sess:type())
end

--@api-stub: LReplSession:typeOf
do
    ---@type LReplSession
    local sess = lurek.repl.new()
    print(sess:typeOf("LReplSession"))
end

print("content/examples/repl.lua")
