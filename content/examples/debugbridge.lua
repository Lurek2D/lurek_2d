-- content/examples/debugbridge.lua
-- love2d-style usage snippets for the lurek.debugbridge API (14 items).
-- Each --@api-stub: block is a copy-pastable snippet showing the API
-- in real context (callbacks, conditionals, real arg values).
-- Run: cargo run -- content/examples/debugbridge.lua

-- ── lurek.debugbridge.* functions ──

--@api-stub: lurek.debugbridge.start
-- Start the TCP debug server on 127.0.0.1:port.
-- Trigger from input, timers, or game events.
-- trigger from input or timer
lurek.debugbridge.start(port)
print("start fired")
print("ok")

--@api-stub: lurek.debugbridge.stop
-- Stop the TCP debug server and close all connections.
-- Trigger from input, timers, or game events.
-- trigger from input or timer
lurek.debugbridge.stop()
print("stop fired")
print("ok")

--@api-stub: lurek.debugbridge.isRunning
-- Returns whether the server is currently running.
-- Use as a guard inside lurek.update or event handlers.
if lurek.debugbridge.isRunning() then
  print("isRunning -> true")
end

--@api-stub: lurek.debugbridge.getPort
-- Returns the server port (0 if not running).
-- Cheap to call; safe inside callbacks.
local value = lurek.debugbridge.getPort()
print("getPort:", value)
return value

--@api-stub: lurek.debugbridge.getClientCount
-- Returns the number of connected TCP clients.
-- Cheap to call; safe inside callbacks.
local value = lurek.debugbridge.getClientCount()
print("getClientCount:", value)
return value

--@api-stub: lurek.debugbridge.poll
-- Poll for pending Lua-dependent requests from TCP clients.
-- See the module spec for detailed semantics.
local result = lurek.debugbridge.poll()
print("poll:", result)
return result

--@api-stub: lurek.debugbridge.capturePrint
-- Captures a print message and broadcasts it to connected clients.
-- See the module spec for detailed semantics.
local result = lurek.debugbridge.capturePrint("hello", source, line)
print("capturePrint:", result)
return result

--@api-stub: lurek.debugbridge.getPrintHistory
-- Returns the print history.
-- Cheap to call; safe inside callbacks.
local value = lurek.debugbridge.getPrintHistory(10)
print("getPrintHistory:", value)
return value

--@api-stub: lurek.debugbridge.clearPrintHistory
-- Clears the print history.
-- Pair with the matching constructor to free resources.
-- release the resource and forget the handle
lurek.debugbridge.clearPrintHistory()
print("clearPrintHistory done")
print("ok")

--@api-stub: lurek.debugbridge.setMaxPrintHistory
-- Sets the maximum print history size.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.debugbridge.setMaxPrintHistory(100)
print("setMaxPrintHistory applied")
print("ok")

--@api-stub: lurek.debugbridge.getPerformance
-- Returns performance statistics.
-- Cheap to call; safe inside callbacks.
local value = lurek.debugbridge.getPerformance()
print("getPerformance:", value)
return value

--@api-stub: lurek.debugbridge.requestScreenshot
-- Flags a screenshot request for the next frame.
-- See the module spec for detailed semantics.
local result = lurek.debugbridge.requestScreenshot(1.0)
print("requestScreenshot:", result)
return result

--@api-stub: lurek.debugbridge.isScreenshotRequested
-- Returns whether a screenshot is currently requested.
-- Use as a guard inside lurek.update or event handlers.
if lurek.debugbridge.isScreenshotRequested() then
  print("isScreenshotRequested -> true")
end

--@api-stub: lurek.debugbridge.broadcast
-- Broadcasts a JSON event to all connected clients.
-- See the module spec for detailed semantics.
local result = lurek.debugbridge.broadcast(event, { x = 0, y = 0 })
print("broadcast:", result)
return result

