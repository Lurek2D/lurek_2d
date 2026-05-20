-- content/examples/log.lua
-- Auto-generated from content/examples2/log_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/log.lua

--- Log Module: structured logging, sinks, and memory drain


--@api-stub: lurek.log.debug
do
    lurek.log.debug("tick completed")
    print("debug logged")
end

--@api-stub: lurek.log.info
do
    lurek.log.info("game started")
    lurek.log.info("asset loaded", "assets")
    print("info logged")
end

--@api-stub: lurek.log.warn
do
    lurek.log.warn("low memory")
    lurek.log.warn("texture missing", "render")
    print("warn logged")
end

--@api-stub: lurek.log.error
do
    lurek.log.error("failed to save")
    lurek.log.error("shader compile failed", "gpu")
    print("error logged")
end

--@api-stub: lurek.log.print
do
    lurek.log.print("info", "general purpose log")
    lurek.log.print("warn", "something suspicious", "system")
    print("print logged")
end

--@api-stub: lurek.log.debug_fields
do
    lurek.log.debug_fields("frame stats", {fps = 60, dt = 0.016})
    print("debug_fields logged")
end

--@api-stub: lurek.log.info_fields
do
    lurek.log.info_fields("player join", {name = "Alice", id = 42})
    print("info_fields logged")
end

--@api-stub: lurek.log.warn_fields
do
    lurek.log.warn_fields("memory usage", {used_mb = 512, limit_mb = 1024})
    print("warn_fields logged")
end

--@api-stub: lurek.log.error_fields
do
    lurek.log.error_fields("save failed", {path = "slot1.sav", reason = "disk full"})
    print("error_fields logged")
end

--@api-stub: lurek.log.struct
do
    lurek.log.struct("info", "combat hit", {attacker = "goblin", target = "player", damage = 15})
    print("struct logged")
end

--@api-stub: lurek.log.getLevel
do
    local prev = lurek.log.getLevel()
    lurek.log.setLevel("warn")
    print("level was " .. prev .. " now " .. lurek.log.getLevel())
    lurek.log.setLevel(prev)
end

--@api-stub: lurek.log.addSink
do
    local id = lurek.log.addSink({type = "memory", level = "debug", capacity = 10})
    print("memory sink id = " .. id)
end

--@api-stub: lurek.log.removeSink
do
    local id = lurek.log.addSink({type = "memory", level = "debug", capacity = 10})
    local ok = lurek.log.removeSink(id)
    print("removed = " .. tostring(ok))
end

--@api-stub: lurek.log.listSinks
do
    local sinks = lurek.log.listSinks()
    print("sink count = " .. #sinks)
end

--@api-stub: lurek.log.clearSinks
do
    lurek.log.clearSinks()
    local sinks = lurek.log.listSinks()
    print("sinks after clear = " .. #sinks)
end

--@api-stub: lurek.log.readMemory
do
    local id = lurek.log.addSink({type = "memory", level = "debug", capacity = 50})
    lurek.log.info("test message")
    local entries = lurek.log.readMemory(id, false)
    print("memory entries = " .. #entries)
end

--@api-stub: lurek.log.flushFile
do
    local id = lurek.log.addSink({type = "file", level = "info", path = "logs/flush_test.log"})
    lurek.log.info("flush me")
    lurek.log.flushFile(id)
    print("file flushed")
end

--@api-stub: lurek.log.setLevel
do
    lurek.log.setLevel("debug")
    print("level set to debug")
end

print("content/examples/log.lua")
