-- content/examples/repl.lua
-- Auto-generated from content/examples2/repl_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/repl.lua

--- REPL Module: interactive Lua evaluation session

--@api-stub: lurek.repl.new
do
    ---@type LReplSession
    local repl = lurek.repl.new(8)
    print("type = " .. repl:type())
    print("initial len = " .. repl:len())
end

--@api-stub: LReplSession:eval
do
    ---@type LReplSession
    local repl = lurek.repl.new()
    repl:eval("local total = 2 + 2")
    local result = repl:eval("return total * 3")
    print("eval result = " .. result)
    print("history len = " .. repl:len())
end

--@api-stub: LReplSession:history
do
    local repl = lurek.repl.new()
    repl:eval("return 'first'")
    repl:eval("return 'second'")
    local hist = repl:history()
    print("history entries = " .. #hist)
    print("last entry = " .. hist[#hist])
end

--@api-stub: LReplSession:complete
do
    ---@type LReplSession
    local repl = lurek.repl.new()
    local completions = repl:complete("lurek.re")
    print("completions for 'lurek.re' = " .. #completions)
    print("first match = " .. tostring(completions[1]))
end

--@api-stub: LReplSession:clear
do
    local repl = lurek.repl.new()
    repl:eval("return 1")
    repl:eval("return 2")
    repl:clear()
    print("after clear = " .. repl:len() .. " history=" .. #repl:history())
end

--@api-stub: LReplSession:len
do
    local repl = lurek.repl.new()
    repl:eval("return 'a'")
    repl:eval("return 'b'")
    print("len = " .. repl:len())
    repl:clear()
    print("after clear = " .. repl:len())
end

--@api-stub: LReplSession:type
do
    ---@type LReplSession
    local sess = lurek.repl.new()
    print("type = " .. sess:type())
end

--@api-stub: LReplSession:typeOf
do
    ---@type LReplSession
    local sess = lurek.repl.new()
    print("is session = " .. tostring(sess:typeOf("LReplSession")))
    print("is object = " .. tostring(sess:typeOf("LObject")))
end
