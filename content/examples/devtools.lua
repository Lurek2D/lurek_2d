-- content/examples/devtools.lua
-- love2d-style usage snippets for the lurek.devtools API (48 items).
-- Each --@api-stub: block is a copy-pastable snippet showing the API
-- in real context (callbacks, conditionals, real arg values).
-- Run: cargo run -- content/examples/devtools.lua

-- ── lurek.devtools.* functions ──

--@api-stub: lurek.devtools.log
-- Logs a message at the given level.
-- See the module spec for detailed semantics.
local result = lurek.devtools.log(level, message)
print("log:", result)
return result

--@api-stub: lurek.devtools.setLogLevel
-- Sets the minimum log level.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.devtools.setLogLevel(level)
print("setLogLevel applied")
print("ok")

--@api-stub: lurek.devtools.getLogLevel
-- Returns the current minimum log level.
-- Cheap to call; safe inside callbacks.
local value = lurek.devtools.getLogLevel()
print("getLogLevel:", value)
return value

--@api-stub: lurek.devtools.setLogConsole
-- Enables or disables console log output.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.devtools.setLogConsole(enabled)
print("setLogConsole applied")
print("ok")

--@api-stub: lurek.devtools.getLogConsole
-- Returns whether console log output is enabled.
-- Cheap to call; safe inside callbacks.
local value = lurek.devtools.getLogConsole()
print("getLogConsole:", value)
return value

--@api-stub: lurek.devtools.setLogFile
-- Sets the log file path (empty string disables file output).
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.devtools.setLogFile("data/file.txt")
print("setLogFile applied")
print("ok")

--@api-stub: lurek.devtools.getLogFile
-- Returns the current log file path.
-- Cheap to call; safe inside callbacks.
local value = lurek.devtools.getLogFile()
print("getLogFile:", value)
return value

--@api-stub: lurek.devtools.getLogHistory
-- Returns recent log entries as an array of tables.
-- Cheap to call; safe inside callbacks.
local value = lurek.devtools.getLogHistory(10)
print("getLogHistory:", value)
return value

--@api-stub: lurek.devtools.clearLog
-- Discards all accumulated log entries from the in-memory devtools log buffer.
-- Pair with the matching constructor to free resources.
-- release the resource and forget the handle
lurek.devtools.clearLog()
print("clearLog done")
print("ok")

--@api-stub: lurek.devtools.setProfilingEnabled
-- Enables or disables the profiler.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.devtools.setProfilingEnabled(enabled)
print("setProfilingEnabled applied")
print("ok")

--@api-stub: lurek.devtools.isProfilingEnabled
-- Returns whether the profiler is enabled.
-- Use as a guard inside lurek.update or event handlers.
if lurek.devtools.isProfilingEnabled() then
  print("isProfilingEnabled -> true")
end

--@api-stub: lurek.devtools.profilePush
-- Opens a named profiling zone on the stack.
-- See the module spec for detailed semantics.
local result = lurek.devtools.profilePush("main")
print("profilePush:", result)
return result

--@api-stub: lurek.devtools.profilePop
-- Closes the most recent profiling zone.
-- See the module spec for detailed semantics.
local result = lurek.devtools.profilePop()
print("profilePop:", result)
return result

--@api-stub: lurek.devtools.profileFrame
-- Seals the current frame of profiling data.
-- See the module spec for detailed semantics.
local result = lurek.devtools.profileFrame()
print("profileFrame:", result)
return result

--@api-stub: lurek.devtools.getProfileFrameCount
-- Returns the number of retained profile frames.
-- Cheap to call; safe inside callbacks.
local value = lurek.devtools.getProfileFrameCount()
print("getProfileFrameCount:", value)
return value

--@api-stub: lurek.devtools.getProfileData
-- Returns zone data table for a specific frame (0 or nil = most recent).
-- Cheap to call; safe inside callbacks.
local value = lurek.devtools.getProfileData(frame)
print("getProfileData:", value)
return value

--@api-stub: lurek.devtools.resetProfile
-- Clears all profiling data and resets the zone stack.
-- Pair with the matching constructor to free resources.
-- release the resource and forget the handle
lurek.devtools.resetProfile()
print("resetProfile done")
print("ok")

--@api-stub: lurek.devtools.recordFrameTime
-- Records a frame-time sample (call each frame with delta time in seconds).
-- See the module spec for detailed semantics.
local result = lurek.devtools.recordFrameTime(dt_val)
print("recordFrameTime:", result)
return result

--@api-stub: lurek.devtools.getFrameStats
-- Returns a table of computed frame statistics.
-- Cheap to call; safe inside callbacks.
local value = lurek.devtools.getFrameStats()
print("getFrameStats:", value)
return value

--@api-stub: lurek.devtools.getFrameHistory
-- Returns the raw frame-time sample array.
-- Cheap to call; safe inside callbacks.
local value = lurek.devtools.getFrameHistory()
print("getFrameHistory:", value)
return value

--@api-stub: lurek.devtools.setFrameHistorySize
-- Sets the frame-history buffer capacity (clamped 10-10000).
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.devtools.setFrameHistorySize(10)
print("setFrameHistorySize applied")
print("ok")

--@api-stub: lurek.devtools.getFrameHistorySize
-- Returns the current frame-history buffer capacity.
-- Cheap to call; safe inside callbacks.
local value = lurek.devtools.getFrameHistorySize()
print("getFrameHistorySize:", value)
return value

--@api-stub: lurek.devtools.watch
-- Adds a file path to the watch list.
-- See the module spec for detailed semantics.
local result = lurek.devtools.watch("data/file.txt")
print("watch:", result)
return result

--@api-stub: lurek.devtools.unwatch
-- Removes a file path from the watch list.
-- See the module spec for detailed semantics.
local result = lurek.devtools.unwatch("data/file.txt")
print("unwatch:", result)
return result

--@api-stub: lurek.devtools.getWatchedPaths
-- Returns an array of all watched paths.
-- Cheap to call; safe inside callbacks.
local value = lurek.devtools.getWatchedPaths()
print("getWatchedPaths:", value)
return value

--@api-stub: lurek.devtools.scan
-- Polls all watched paths and returns paths whose mtime changed.
-- See the module spec for detailed semantics.
local result = lurek.devtools.scan()
print("scan:", result)
return result

--@api-stub: lurek.devtools.clearWatches
-- Clears all watched paths.
-- Pair with the matching constructor to free resources.
-- release the resource and forget the handle
lurek.devtools.clearWatches()
print("clearWatches done")
print("ok")

--@api-stub: lurek.devtools.getWatchInterval
-- Returns the file watch poll interval in seconds.
-- Cheap to call; safe inside callbacks.
local value = lurek.devtools.getWatchInterval()
print("getWatchInterval:", value)
return value

--@api-stub: lurek.devtools.setWatchInterval
-- Sets the file watch poll interval in seconds.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.devtools.setWatchInterval(interval)
print("setWatchInterval applied")
print("ok")

--@api-stub: lurek.devtools.getCallStack
-- Returns the Lua call stack as a table of frames.
-- Cheap to call; safe inside callbacks.
local value = lurek.devtools.getCallStack(max_depth)
print("getCallStack:", value)
return value

--@api-stub: lurek.devtools.eval
-- Evaluates a Lua string and returns (success, results...).
-- See the module spec for detailed semantics.
local result = lurek.devtools.eval(code)
print("eval:", result)
return result

--@api-stub: lurek.devtools.openConsole
-- Opens the console window (updates the console flag; returns true).
-- Build once at startup; reuse across frames.
local openconsole = lurek.devtools.openConsole()
print("created", openconsole)
return openconsole

--@api-stub: lurek.devtools.isConsoleOpen
-- Returns whether the console is considered open.
-- Use as a guard inside lurek.update or event handlers.
if lurek.devtools.isConsoleOpen() then
  print("isConsoleOpen -> true")
end

--@api-stub: lurek.devtools.exposeWatch
-- Registers a named live watch.
-- See the module spec for detailed semantics.
local result = lurek.devtools.exposeWatch("main", getter, category)
print("exposeWatch:", result)
return result

--@api-stub: lurek.devtools.removeWatch
-- Removes a watch by the id returned from exposeWatch.
-- Pair with the matching constructor to free resources.
-- release the resource and forget the handle
lurek.devtools.removeWatch(1)
print("removeWatch done")
print("ok")

--@api-stub: lurek.devtools.getWatches
-- Calls all registered watch getters and returns a table of {name, category, value} records.
-- Cheap to call; safe inside callbacks.
local value = lurek.devtools.getWatches()
print("getWatches:", value)
return value

--@api-stub: lurek.devtools.snapshot
-- Takes a structured snapshot of all watches + frame stats + last profile frame.
-- See the module spec for detailed semantics.
local result = lurek.devtools.snapshot()
print("snapshot:", result)
return result

--@api-stub: lurek.devtools.profilerReport
-- Returns a flat summary table of all recorded profiler zones across all stored.
-- See the module spec for detailed semantics.
local result = lurek.devtools.profilerReport()
print("profilerReport:", result)
return result

--@api-stub: lurek.devtools.newFileWatcher
-- Creates a standalone per-path file watcher.
-- Build once at startup; reuse across frames.
local filewatcher = lurek.devtools.newFileWatcher("data/file.txt")
print("created", filewatcher)
return filewatcher

--@api-stub: lurek.devtools.newRepl
-- Creates an interactive Lua REPL console with a bounded history buffer.
-- Build once at startup; reuse across frames.
local repl = lurek.devtools.newRepl(max_history)
print("created", repl)
return repl

-- ── FileWatcher methods ──

--@api-stub: FileWatcher:onChanged
-- Registers a callback invoked (with no arguments) when the watched path changes.
-- See the module spec for detailed semantics.
local fileWatcher = lurek.devtools.newFileWatcher()
fileWatcher:onChanged(function() print("onChanged fired") end)
print("FileWatcher:onChanged done")

--@api-stub: FileWatcher:check
-- Polls the watcher.
-- See the module spec for detailed semantics.
local fileWatcher = lurek.devtools.newFileWatcher()
fileWatcher:check()
print("FileWatcher:check done")

--@api-stub: FileWatcher:getPath
-- Returns the watched path string.
-- Cheap to call; safe inside callbacks.
local fileWatcher = lurek.devtools.newFileWatcher()  -- or your existing handle
local value = fileWatcher:getPath()
print("FileWatcher:getPath ->", value)

--@api-stub: FileWatcher:cancel
-- Removes the stored `onChanged` callback and stops future notifications.
-- Pair with the matching constructor to free resources.
local fileWatcher = lurek.devtools.newFileWatcher()
fileWatcher:cancel()
-- fileWatcher is now released
print("ok")

-- ── ReplConsole methods ──

--@api-stub: ReplConsole:eval
-- Evaluates a Lua snippet and records the input in history.
-- See the module spec for detailed semantics.
local replConsole = lurek.devtools.newReplConsole()
replConsole:eval(code)
print("ReplConsole:eval done")

--@api-stub: ReplConsole:history
-- Returns an ordered array of past inputs (oldest first).
-- See the module spec for detailed semantics.
local replConsole = lurek.devtools.newReplConsole()
replConsole:history()
print("ReplConsole:history done")

--@api-stub: ReplConsole:clear
-- Clears the REPL history buffer.
-- Pair with the matching constructor to free resources.
local replConsole = lurek.devtools.newReplConsole()
replConsole:clear()
-- replConsole is now released
print("ok")

--@api-stub: ReplConsole:len
-- Returns the number of history entries.
-- See the module spec for detailed semantics.
local replConsole = lurek.devtools.newReplConsole()
replConsole:len()
print("ReplConsole:len done")

