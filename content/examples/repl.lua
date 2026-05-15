-- content/examples/repl.lua
-- Hand-written coverage of the lurek.repl API.

--@api-stub: lurek.repl.new
do -- lurek.repl.new
  local repl = lurek.repl.new(32)
  repl:eval("example_repl_value = 10")
end

--@api-stub: LReplSession:eval
do -- LReplSession:eval
  local repl = lurek.repl.new(8)
  local value = repl:eval("6 * 7")
  lurek.log.info("repl value " .. value, "repl")
end

--@api-stub: LReplSession:history
do -- LReplSession:history
  local repl = lurek.repl.new(8)
  repl:eval("1 + 1")
  local history = repl:history()
  lurek.log.info("repl history entries " .. tostring(#history), "repl")
end

--@api-stub: LReplSession:clear
do -- LReplSession:clear
  local repl = lurek.repl.new(8)
  repl:eval("2 + 2")
  repl:clear()
end

--@api-stub: LReplSession:len
do -- LReplSession:len
  local repl = lurek.repl.new(8)
  repl:eval("3 + 3")
  lurek.log.info("repl length " .. tostring(repl:len()), "repl")
end

--@api-stub: LReplSession:complete
do -- LReplSession:complete
  local repl = lurek.repl.new(8)
  local matches = repl:complete("lurek.re")
  lurek.log.info("repl completions " .. tostring(#matches), "repl")
end

--@api-stub: LReplSession:type
do -- LReplSession:type
  local repl = lurek.repl.new(8)
  lurek.log.info("repl type " .. repl:type(), "repl")
end

--@api-stub: LReplSession:typeOf
do -- LReplSession:typeOf
  local repl = lurek.repl.new(8)
  if repl:typeOf("LReplSession") then
    lurek.log.info("repl session ready", "repl")
  end
end
