-- content/examples/log.lua
-- love2d-style usage snippets for the lurek.log API (18 items).
-- Each --@api-stub: block is a copy-pastable snippet showing the API
-- in real context (callbacks, conditionals, real arg values).
-- Run: cargo run -- content/examples/log.lua

-- ── lurek.log.* functions ──

--@api-stub: lurek.log.debug
-- Emits a debug-severity log message.
-- See the module spec for detailed semantics.
local frameCount, dt = 1, 0.016
lurek.log.debug("frame", frameCount, "dt", dt)
-- silent unless RUST_LOG=debug
print("ok")

--@api-stub: lurek.log.info
-- Emits an info-severity log message.
-- See the module spec for detailed semantics.
local level = { name = "forest" }
lurek.log.info("level loaded:", level.name)
lurek.log.info("entities:", 42)

--@api-stub: lurek.log.warn
-- Emits a warn-severity log message.
-- See the module spec for detailed semantics.
local hp = 5
if hp < 10 then
  lurek.log.warn("low hp:", hp)
end

--@api-stub: lurek.log.error
-- Emits an error-severity log message.
-- See the module spec for detailed semantics.
local ok, err = pcall(function() error("level load failed") end)
if not ok then
  lurek.log.error("fatal:", err)
end

--@api-stub: lurek.log.print
-- Emits a log message at the specified level.
-- See the module spec for detailed semantics.
lurek.log.print("ready")
lurek.log.print("loading assets...")
lurek.log.print("done")

--@api-stub: lurek.log.setLevel
-- Sets the minimum severity level for the default log channel.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.log.setLevel(level)
print("setLevel applied")
print("ok")

--@api-stub: lurek.log.getLevel
-- Returns the name of the currently active minimum log level.
-- Cheap to call; safe inside callbacks.
local value = lurek.log.getLevel()
print("getLevel:", value)
return value

--@api-stub: lurek.log.addSink
-- Registers a new output sink.
-- Side-effecting; safe to call any time after init.
lurek.log.addSink({ x = 0, y = 0 })
-- mutator; side effect applied
print("addSink done")
print("ok")

--@api-stub: lurek.log.removeSink
-- Removes a sink by id.
-- Pair with the matching constructor to free resources.
-- release the resource and forget the handle
lurek.log.removeSink(1)
print("removeSink done")
print("ok")

--@api-stub: lurek.log.clearSinks
-- Removes all registered sinks (the default stderr channel is unaffected).
-- Pair with the matching constructor to free resources.
-- release the resource and forget the handle
lurek.log.clearSinks()
print("clearSinks done")
print("ok")

--@api-stub: lurek.log.listSinks
-- Returns a table describing all registered sinks.
-- See the module spec for detailed semantics.
local result = lurek.log.listSinks()
print("listSinks:", result)
return result

--@api-stub: lurek.log.readMemory
-- Reads entries from a memory sink.
-- Cheap to call; safe inside callbacks.
local value = lurek.log.readMemory(1, drain)
print("readMemory:", value)
return value

--@api-stub: lurek.log.flushFile
-- Flushes the OS write buffer for a file sink.
-- See the module spec for detailed semantics.
local result = lurek.log.flushFile(1)
print("flushFile:", result)
return result

--@api-stub: lurek.log.struct
-- Emits a structured log message with key-value fields.
-- See the module spec for detailed semantics.
local result = lurek.log.struct("hello", message, { x = 0, y = 0 })
print("struct:", result)
return result

--@api-stub: lurek.log.debug_fields
-- Emits a debug structured log message.
-- See the module spec for detailed semantics.
local result = lurek.log.debug_fields(message, { x = 0, y = 0 })
print("debug_fields:", result)
return result

--@api-stub: lurek.log.info_fields
-- Emits an info structured log message.
-- See the module spec for detailed semantics.
local result = lurek.log.info_fields(message, { x = 0, y = 0 })
print("info_fields:", result)
return result

--@api-stub: lurek.log.warn_fields
-- Emits a warn structured log message.
-- See the module spec for detailed semantics.
local result = lurek.log.warn_fields(message, { x = 0, y = 0 })
print("warn_fields:", result)
return result

--@api-stub: lurek.log.error_fields
-- Emits an error structured log message.
-- See the module spec for detailed semantics.
local result = lurek.log.error_fields(message, { x = 0, y = 0 })
print("error_fields:", result)
return result

