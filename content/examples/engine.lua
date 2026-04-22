-- content/examples/engine.lua
-- love2d-style usage snippets for the lurek.engine API (10 items).
-- Each --@api-stub: block is a copy-pastable snippet showing the API
-- in real context (callbacks, conditionals, real arg values).
-- Run: cargo run -- content/examples/engine.lua

-- ── lurek.engine.* functions ──

--@api-stub: lurek.engine.getVersion
-- Returns the engine version string (from `Cargo.toml`).
-- Cheap to call; safe inside callbacks.
local value = lurek.engine.getVersion()
print("getVersion:", value)
return value

--@api-stub: lurek.engine.getFrameBudget
-- Returns the target frame budget in milliseconds (default: 1000 / 60 â‰ 16.667 ms).
-- Cheap to call; safe inside callbacks.
local value = lurek.engine.getFrameBudget()
print("getFrameBudget:", value)
return value

--@api-stub: lurek.engine.memoryUsage
-- Returns a table with `lua_bytes` (Lua GC heap usage in bytes) and.
-- See the module spec for detailed semantics.
local result = lurek.engine.memoryUsage()
print("memoryUsage:", result)
return result

--@api-stub: lurek.engine.platform
-- Returns a string identifying the host operating system:.
-- See the module spec for detailed semantics.
local result = lurek.engine.platform()
print("platform:", result)
return result

--@api-stub: lurek.engine.uptime
-- Returns the total engine uptime in seconds (sum of all processed deltas).
-- See the module spec for detailed semantics.
local result = lurek.engine.uptime()
print("uptime:", result)
return result

--@api-stub: lurek.engine.fps
-- Returns the current measured frames-per-second.
-- See the module spec for detailed semantics.
local result = lurek.engine.fps()
print("fps:", result)
return result

--@api-stub: lurek.engine.frameCount
-- Returns the total number of frames processed since engine start.
-- See the module spec for detailed semantics.
local result = lurek.engine.frameCount()
print("frameCount:", result)
return result

--@api-stub: lurek.engine.isDebug
-- Returns `true` if the engine was compiled in debug mode.
-- Use as a guard inside lurek.update or event handlers.
if lurek.engine.isDebug() then
  print("isDebug -> true")
end

--@api-stub: lurek.engine.setResourceBudget
-- Sets the maximum resident texture memory budget in bytes.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.engine.setResourceBudget(budget_bytes)
print("setResourceBudget applied")
print("ok")

--@api-stub: lurek.engine.getResourceStats
-- Returns a table with resident resource memory statistics.
-- Cheap to call; safe inside callbacks.
local value = lurek.engine.getResourceStats()
print("getResourceStats:", value)
return value

