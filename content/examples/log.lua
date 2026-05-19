-- content/examples/log.lua
-- Auto-generated from content/examples2/log_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/log.lua

--- Log Module: structured logging, sinks, and memory drain


--@api-stub: lurek.log.debug
-- Emits a debug-level message.
do
    lurek.log.debug("tick completed")
    lurek.log.debug("player moved", "movement")
    print("debug logged")

    -- Reads and drains entries from memory sink. Focus: debug.
    local id = lurek.log.addSink({type = "memory", level = "debug", capacity = 50})
    lurek.log.debug("ephemeral")
    local entries = lurek.log.readMemory(id, true)
    print("drained " .. #entries .. " entries")
    local after = lurek.log.readMemory(id, false)
    print("after drain = " .. #after)
end

--@api-stub: lurek.log.info
-- Emits an info-level message.
do
    lurek.log.info("game started")
    lurek.log.info("asset loaded", "assets")
    print("info logged")
end

--@api-stub: lurek.log.warn
-- Emits a warning-level message.
do
    lurek.log.warn("low memory")
    lurek.log.warn("texture missing", "render")
    print("warn logged")
end

--@api-stub: lurek.log.error
-- Emits an error-level message.
do
    lurek.log.error("failed to save")
    lurek.log.error("shader compile failed", "gpu")
    print("error logged")
end

--@api-stub: lurek.log.print
-- Emits a message at a given level string.
do
    lurek.log.print("info", "general purpose log")
    lurek.log.print("warn", "something suspicious", "system")
    print("print logged")
end

--@api-stub: lurek.log.debug_fields
-- Emits a debug message with structured fields.
do
    lurek.log.debug_fields("frame stats", {fps = 60, dt = 0.016})
    print("debug_fields logged")
end

--@api-stub: lurek.log.info_fields
-- Emits an info message with structured fields.
do
    lurek.log.info_fields("player join", {name = "Alice", id = 42})
    print("info_fields logged")
end

--@api-stub: lurek.log.warn_fields
-- Emits a warning message with structured fields.
do
    lurek.log.warn_fields("memory usage", {used_mb = 512, limit_mb = 1024})
    print("warn_fields logged")
end

--@api-stub: lurek.log.error_fields
-- Emits an error message with structured fields.
do
    lurek.log.error_fields("save failed", {path = "slot1.sav", reason = "disk full"})
    print("error_fields logged")
end

--@api-stub: lurek.log.struct
-- Emits a structured log at an explicit level.
do
    lurek.log.struct("info", "combat hit", {
        attacker = "goblin",
        target = "player",
        damage = 15,
    })
    print("struct logged")
end

--@api-stub: lurek.log.getLevel
-- Gets and sets the minimum log level filter.
do
    local prev = lurek.log.getLevel()
    lurek.log.setLevel("warn")
    print("level was " .. prev .. " now " .. lurek.log.getLevel())
    lurek.log.setLevel(prev)
end

--@api-stub: lurek.log.addSink
-- Adds a console sink.
do
    local id = lurek.log.addSink({
        type = "memory",
        level = "debug",
        capacity = 10,
    })
    print("memory sink id = " .. id)

    -- Adds a file sink with path.
    local id = lurek.log.addSink({
        type = "file",
        level = "info",
        format = "json",
        path = "logs/game.log",
    })
    print("file sink id = " .. id)

    -- Adds a memory ring buffer sink.
    local id = lurek.log.addSink({
        type = "memory",
        level = "debug",
        capacity = 100,
    })
    print("memory sink id = " .. id)

    -- Adds a callback-based sink.
    local id = lurek.log.addSink({
        type = "callback",
        level = "warn",
        callback = function(entry)
            print("callback got: " .. entry.message)
        end,
    })
    print("callback sink id = " .. id)

    -- Reads and drains entries from memory sink. Focus: addSink.
    local id = lurek.log.addSink({type = "memory", level = "debug", capacity = 50})
    lurek.log.debug("ephemeral")
    local entries = lurek.log.readMemory(id, true)
    print("drained " .. #entries .. " entries")
    local after = lurek.log.readMemory(id, false)
    print("after drain = " .. #after)
end

--@api-stub: lurek.log.removeSink
-- Removes a sink by id.
do
    local id = lurek.log.addSink({type = "memory", level = "debug", capacity = 10})
    local ok = lurek.log.removeSink(id)
    print("removed = " .. tostring(ok))
end

--@api-stub: lurek.log.listSinks
-- Lists all active sinks.
do
    local sinks = lurek.log.listSinks()
    for _, s in ipairs(sinks) do
        print("sink " .. s.id .. " type=" .. s.type .. " level=" .. s.level)
    end
end

--@api-stub: lurek.log.clearSinks
-- Removes all sinks.
do
    lurek.log.clearSinks()
    local sinks = lurek.log.listSinks()
    print("sinks after clear = " .. #sinks)
end

--@api-stub: lurek.log.readMemory
-- Reads entries from a memory sink.
do
    local id = lurek.log.addSink({type = "memory", level = "debug", capacity = 50})
    lurek.log.info("test message")
    local entries = lurek.log.readMemory(id, false)
    print("memory entries = " .. #entries)
    for _, e in ipairs(entries) do
        print("  [" .. e.level .. "] " .. e.message)
    end

    -- Reads and drains entries from memory sink. Focus: readMemory.
    local id = lurek.log.addSink({type = "memory", level = "debug", capacity = 50})
    lurek.log.debug("ephemeral")
    local entries = lurek.log.readMemory(id, true)
    print("drained " .. #entries .. " entries")
    local after = lurek.log.readMemory(id, false)
    print("after drain = " .. #after)
end

--@api-stub: lurek.log.flushFile
-- Flushes a file sink to disk.
do
    local id = lurek.log.addSink({type = "file", level = "info", path = "logs/flush_test.log"})
    lurek.log.info("flush me")
    lurek.log.flushFile(id)
    print("file flushed")
end

--@api-stub: lurek.log.setLevel
-- Log sinks and dynamic level changes.
do
    lurek.log.setLevel("debug")
    lurek.log.addSink({ type = "callback", level = "debug", callback = function(msg) print(msg.message) end })
    lurek.log.setLevel("info")
    lurek.log.setLevel("warn")
    lurek.log.setLevel("error")
end

print("content/examples/log.lua")
