-- content/examples/log.lua
-- Auto-generated from content/examples2/log_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/log.lua

--- Log Module: structured logging, sinks, and memory drain

--@api: lurek.log.debug
do
    lurek.log.clearSinks()
    lurek.log.setLevel("debug")
    local id = lurek.log.addSink({type = "memory", level = "debug", capacity = 8})
    lurek.log.debug("tick completed", "Gameplay")
    local entry = lurek.log.readMemory(id, true)[1]
    lurek.log.removeSink(id)
    lurek.log.info("captured debug entry: " .. entry.level .. " " .. entry.tag)
end

--@api: lurek.log.info
do
    lurek.log.clearSinks()
    local id = lurek.log.addSink({type = "memory", level = "info", capacity = 8})
    lurek.log.info("game started")
    lurek.log.info("asset loaded", "assets")
    local entries = lurek.log.readMemory(id, true)
    lurek.log.removeSink(id)
    lurek.log.info("info entries captured = " .. #entries)
end

--@api: lurek.log.warn
do
    lurek.log.clearSinks()
    local id = lurek.log.addSink({type = "memory", level = "warn", capacity = 8})
    lurek.log.warn("low memory")
    lurek.log.warn("texture missing", "render")
    local entry = lurek.log.readMemory(id, true)[2]
    lurek.log.removeSink(id)
    lurek.log.info("warn tag captured = " .. tostring(entry.tag))
end

--@api: lurek.log.error
do
    lurek.log.clearSinks()
    local id = lurek.log.addSink({type = "memory", level = "error", capacity = 8})
    lurek.log.error("failed to save")
    lurek.log.error("shader compile failed", "gpu")
    local entry = lurek.log.readMemory(id, true)[2]
    lurek.log.removeSink(id)
    lurek.log.info("error sink captured message = " .. entry.message)
end

--@api: lurek.log.print
do
    lurek.log.clearSinks()
    local id = lurek.log.addSink({type = "memory", level = "debug", capacity = 8})
    lurek.log.print("info", "general purpose log")
    lurek.log.print("warn", "something suspicious", "system")
    local entry = lurek.log.readMemory(id, true)[2]
    lurek.log.removeSink(id)
    lurek.log.info("runtime-selected level = " .. entry.level .. " tag=" .. tostring(entry.tag))
end

--@api: lurek.log.debug_fields
do
    lurek.log.clearSinks()
    lurek.log.setLevel("debug")
    local id = lurek.log.addSink({type = "memory", level = "debug", capacity = 8})
    lurek.log.debug_fields("frame stats", {fps = "60", dt = "0.016"})
    local entry = lurek.log.readMemory(id, true)[1]
    lurek.log.removeSink(id)
    lurek.log.info("debug fields fps=" .. tostring(entry.fields.fps) .. " dt=" .. tostring(entry.fields.dt))
end

--@api: lurek.log.info_fields
do
    lurek.log.clearSinks()
    local id = lurek.log.addSink({type = "memory", level = "info", capacity = 8})
    lurek.log.info_fields("player join", {name = "Alice", id = "42"})
    local entry = lurek.log.readMemory(id, true)[1]
    lurek.log.removeSink(id)
    lurek.log.info("joined player " .. tostring(entry.fields.name) .. " id=" .. tostring(entry.fields.id))
end

--@api: lurek.log.warn_fields
do
    lurek.log.clearSinks()
    local id = lurek.log.addSink({type = "memory", level = "warn", capacity = 8})
    lurek.log.warn_fields("memory usage", {used_mb = "512", limit_mb = "1024"})
    local entry = lurek.log.readMemory(id, true)[1]
    lurek.log.removeSink(id)
    lurek.log.info("warn fields usage=" .. tostring(entry.fields.used_mb) .. "/" .. tostring(entry.fields.limit_mb) .. " MB")
end

--@api: lurek.log.error_fields
do
    lurek.log.clearSinks()
    local id = lurek.log.addSink({type = "memory", level = "error", capacity = 8})
    lurek.log.error_fields("save failed", {path = "slot1.sav", reason = "disk full"})
    local entry = lurek.log.readMemory(id, true)[1]
    lurek.log.removeSink(id)
    lurek.log.info("save error path=" .. tostring(entry.fields.path) .. " reason=" .. tostring(entry.fields.reason))
end

--@api: lurek.log.struct
do
    lurek.log.clearSinks()
    local id = lurek.log.addSink({type = "memory", level = "debug", capacity = 8})
    lurek.log.struct("info", "combat hit", {attacker = "enemy", target = "player", damage = "15"})
    local entry = lurek.log.readMemory(id, true)[1]
    lurek.log.removeSink(id)
    lurek.log.info("struct fields attacker=" .. tostring(entry.fields.attacker) .. " damage=" .. tostring(entry.fields.damage))
end

--@api: lurek.log.getLevel
do
    local prev = lurek.log.getLevel()
    lurek.log.setLevel("warn")
    local current = lurek.log.getLevel()
    lurek.log.setLevel(prev)
    local restored = lurek.log.getLevel()
    lurek.log.info("level switched " .. prev .. " -> " .. current)
    lurek.log.info("level restored = " .. restored)
end

--@api: lurek.log.addSink
do
    lurek.log.clearSinks()
    local before = #lurek.log.listSinks()
    local id = lurek.log.addSink({type = "memory", level = "debug", capacity = 10})
    local after = #lurek.log.listSinks()
    lurek.log.info("memory sink id = " .. id)
    lurek.log.info("sink count " .. before .. " -> " .. after)
end

--@api: lurek.log.removeSink
do
    lurek.log.clearSinks()
    local id = lurek.log.addSink({type = "memory", level = "debug", capacity = 10})
    local before = #lurek.log.listSinks()
    local ok = lurek.log.removeSink(id)
    local after = #lurek.log.listSinks()
    lurek.log.info("removed = " .. tostring(ok))
    lurek.log.info("sink count " .. before .. " -> " .. after)
end

--@api: lurek.log.listSinks
do
    lurek.log.clearSinks()
    lurek.log.addSink({type = "memory", level = "info", capacity = 8})
    lurek.log.addSink({type = "memory", level = "warn", capacity = 8})
    local sinks = lurek.log.listSinks()
    lurek.log.info("sink count = " .. #sinks)
    lurek.log.info("first sink type = " .. sinks[1].type)
end

--@api: lurek.log.clearSinks
do
    lurek.log.addSink({type = "memory", level = "info", capacity = 8})
    lurek.log.addSink({type = "memory", level = "warn", capacity = 8})
    local before = #lurek.log.listSinks()
    lurek.log.clearSinks()
    local sinks = lurek.log.listSinks()
    lurek.log.info("sinks before clear = " .. before)
    lurek.log.info("sinks after clear = " .. #sinks)
end

--@api: lurek.log.readMemory
do
    lurek.log.clearSinks()
    local id = lurek.log.addSink({type = "memory", level = "debug", capacity = 50})
    lurek.log.info("test message")
    local entries = lurek.log.readMemory(id, false)
    local entry = entries[1]
    lurek.log.removeSink(id)
    lurek.log.info("memory entries = " .. #entries)
    lurek.log.info("first entry message = " .. entry.message)
end

--@api: lurek.log.flushFile
do
    lurek.log.clearSinks()
    lurek.filesystem.mkdir("save")
    local path = "save/_log_flush_example.log"
    local id = lurek.log.addSink({type = "file", level = "info", path = path})
    lurek.log.info("flush me")
    lurek.log.flushFile(id)
    lurek.log.removeSink(id)
    lurek.log.info("file sink id = " .. id)
    lurek.log.info("flush requested for " .. path)
end

--@api: lurek.log.setLevel
do
    local previous = lurek.log.getLevel()
    lurek.log.setLevel("debug")
    local current = lurek.log.getLevel()
    lurek.log.setLevel(previous)
    lurek.log.info("level set to " .. current)
    lurek.log.info("restored level = " .. lurek.log.getLevel())
end
