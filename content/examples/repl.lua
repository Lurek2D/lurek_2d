-- content/examples/repl.lua
-- Auto-generated from content/examples2/repl_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/repl.lua

--- REPL Module: interactive Lua evaluation session


--@api: lurek.repl.new
do

    ---@type LReplSession
    local repl = lurek.repl.new(8)
    local initial_len = repl:len()
    local is_session = repl:typeOf("LReplSession")
    lurek.log.info("repl type = " .. repl:type())
    lurek.log.info("initial len = " .. initial_len)
    assert(is_session and initial_len == 0, "new REPL session starts empty")
end

--@api: LReplSession:eval
do

    ---@type LReplSession
    local repl = lurek.repl.new()
    repl:eval("local total = 2 + 2")
    local result = repl:eval("return total * 3")
    lurek.log.info(tostring("eval result = " .. result))
    lurek.log.info(tostring("history len = " .. repl:len()))
end

--@api: LReplSession:history
do

    local repl = lurek.repl.new()
    repl:eval("return 'first'")
    repl:eval("return 'second'")
    local hist = repl:history()
    lurek.log.info(tostring("history entries = " .. #hist))
    lurek.log.info(tostring("last entry = " .. hist[#hist]))
end

--@api: LReplSession:complete
do

    ---@type LReplSession
    local repl = lurek.repl.new()
    local completions = repl:complete("lurek.re")
    local first = tostring(completions[1] or "")
    local count = #completions
    lurek.log.info("completions for lurek.re = " .. count)
    lurek.log.info("first match = " .. first)
end

--@api: LReplSession:clear
do

    local repl = lurek.repl.new()
    repl:eval("return 1")
    repl:eval("return 2")
    repl:clear()
    lurek.log.info(tostring("after clear = " .. repl:len() .. " history=" .. #repl:history()))
end

--@api: LReplSession:len
do

    local repl = lurek.repl.new()
    repl:eval("return 'a'")
    repl:eval("return 'b'")
    lurek.log.info(tostring("len = " .. repl:len()))
    repl:clear()
    lurek.log.info(tostring("after clear = " .. repl:len()))
end

--@api: LReplSession:type
do

    ---@type LReplSession
    local sess = lurek.repl.new()
    local type_name = sess:type()
    local matches = sess:typeOf(type_name)
    lurek.log.info("repl session type = " .. type_name)
    lurek.log.info("type check = " .. tostring(matches))
    assert(matches, "session reports its own type")
end

--@api: LReplSession:typeOf
do

    ---@type LReplSession
    local sess = lurek.repl.new()
    local is_session = sess:typeOf("LReplSession")
    local is_object = sess:typeOf("LObject")
    lurek.log.info("is session = " .. tostring(is_session))
    lurek.log.info("history entries = " .. tostring(sess:len()))
    assert(is_session and is_object, "REPL session exposes expected type hierarchy")
end
