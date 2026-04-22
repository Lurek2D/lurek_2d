-- content/examples/system.lua
-- love2d-style usage snippets for the lurek.system API (26 items).
-- Each --@api-stub: block is a copy-pastable snippet showing the API
-- in real context (callbacks, conditionals, real arg values).
-- Run: cargo run -- content/examples/system.lua

-- ── lurek.system.* functions ──

--@api-stub: lurek.system.getOS
-- Returns the host operating system name ('Windows', 'Linux', 'macOS').
-- Cheap to call; safe inside callbacks.
local os = lurek.system.getOS()
if os == "Windows" then print("hi windows") end
print("running on:", os)

--@api-stub: lurek.system.getVersion
-- Returns the Lurek2D engine version string.
-- Cheap to call; safe inside callbacks.
local value = lurek.system.getVersion()
print("getVersion:", value)
return value

--@api-stub: lurek.system.getProcessorCount
-- Returns the number of logical CPU cores available.
-- Cheap to call; safe inside callbacks.
local value = lurek.system.getProcessorCount()
print("getProcessorCount:", value)
return value

--@api-stub: lurek.system.getMemorySize
-- Returns the total amount of installed system RAM in megabytes.
-- Cheap to call; safe inside callbacks.
local value = lurek.system.getMemorySize()
print("getMemorySize:", value)
return value

--@api-stub: lurek.system.openURL
-- Opens a URL in the system's default browser.
-- Build once at startup; reuse across frames.
lurek.system.openURL("https://github.com")
lurek.system.openURL("https://lurek2d.dev/docs")
-- opens in default browser
print("ok")

--@api-stub: lurek.system.getPreferredLocales
-- Returns an ordered list of the user's preferred locale strings (e.g.
-- Cheap to call; safe inside callbacks.
local value = lurek.system.getPreferredLocales()
print("getPreferredLocales:", value)
return value

--@api-stub: lurek.system.getPowerInfo
-- Returns battery state, percentage charged, and estimated time remaining.
-- Cheap to call; safe inside callbacks.
local value = lurek.system.getPowerInfo()
print("getPowerInfo:", value)
return value

--@api-stub: lurek.system.getInfo
-- Returns a table of system information including OS name, CPU model, and installed RAM.
-- Cheap to call; safe inside callbacks.
local value = lurek.system.getInfo()
print("getInfo:", value)
return value

--@api-stub: lurek.system.getMessage
-- Resolves a stable runtime message ID such as 'L001' to its human-readable text.
-- Cheap to call; safe inside callbacks.
local value = lurek.system.getMessage(1)
print("getMessage:", value)
return value

--@api-stub: lurek.system.hasMessage
-- Returns true when the runtime message catalog contains the given stable message ID.
-- Use as a guard inside lurek.update or event handlers.
if lurek.system.hasMessage(1) then
  print("hasMessage -> true")
end

--@api-stub: lurek.system.getMessageCount
-- Returns the total number of message entries loaded into the runtime message catalog.
-- Cheap to call; safe inside callbacks.
local value = lurek.system.getMessageCount()
print("getMessageCount:", value)
return value

--@api-stub: lurek.system.setClipboardText
-- Replaces the system clipboard contents with the given string.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.system.setClipboardText("hello")
print("setClipboardText applied")
print("ok")

--@api-stub: lurek.system.getClipboardText
-- Returns the current contents of the system clipboard.
-- Cheap to call; safe inside callbacks.
local value = lurek.system.getClipboardText()
print("getClipboardText:", value)
return value

--@api-stub: lurek.system.setDebugOverlay
-- Shows or hides the FPS/draw-call debug overlay.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.system.setDebugOverlay(enabled)
print("setDebugOverlay applied")
print("ok")

--@api-stub: lurek.system.getDebugOverlay
-- Returns whether the debug overlay is currently visible.
-- Cheap to call; safe inside callbacks.
local value = lurek.system.getDebugOverlay()
print("getDebugOverlay:", value)
return value

--@api-stub: lurek.system.setLogLevel
-- Sets the minimum severity level for runtime log messages.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.system.setLogLevel(level)
print("setLogLevel applied")
print("ok")

--@api-stub: lurek.system.getLogLevel
-- Returns the name of the current minimum log level for runtime messages.
-- Cheap to call; safe inside callbacks.
local value = lurek.system.getLogLevel()
print("getLogLevel:", value)
return value

--@api-stub: lurek.system.log
-- Emit a log message from Lua at the specified level.
-- See the module spec for detailed semantics.
local result = lurek.system.log(level, message)
print("log:", result)
return result

--@api-stub: lurek.system.getLastError
-- Returns the last unhandled error message, or nil.
-- Cheap to call; safe inside callbacks.
local value = lurek.system.getLastError()
print("getLastError:", value)
return value

--@api-stub: lurek.system.errorSnapshot
-- Serialises an engine error message to a compact JSON string.
-- See the module spec for detailed semantics.
local result = lurek.system.errorSnapshot("hello")
print("errorSnapshot:", result)
return result

--@api-stub: lurek.system.getArch
-- Returns the CPU architecture string for the current machine.
-- Cheap to call; safe inside callbacks.
local value = lurek.system.getArch()
print("getArch:", value)
return value

--@api-stub: lurek.system.getEnv
-- Returns the value of an environment variable, or nil if not set.
-- Cheap to call; safe inside callbacks.
local value = lurek.system.getEnv("main")
print("getEnv:", value)
return value

--@api-stub: lurek.system.getArgs
-- Returns the command-line arguments as a table.
-- Cheap to call; safe inside callbacks.
local value = lurek.system.getArgs()
print("getArgs:", value)
return value

--@api-stub: lurek.system.parseArgs
-- Parses a command-line argument string and returns a structured key/value table.
-- See the module spec for detailed semantics.
local result = lurek.system.parseArgs({ x = 0, y = 0 })
print("parseArgs:", result)
return result

--@api-stub: lurek.system.runBatch
-- Runs a list of shell commands in parallel and returns immediately without blocking.
-- Trigger from input, timers, or game events.
-- trigger from input or timer
lurek.system.runBatch(tasks, { x = 0, y = 0 })
print("runBatch fired")
print("ok")

--@api-stub: lurek.system.getBatchResults
-- Returns the output table from the most recently completed runBatch call.
-- Cheap to call; safe inside callbacks.
local value = lurek.system.getBatchResults(results)
print("getBatchResults:", value)
return value

