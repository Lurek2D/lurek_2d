-- content/examples/event.lua
-- love2d-style usage snippets for the lurek.event API (22 items).
-- Each --@api-stub: block is a copy-pastable snippet showing the API
-- in real context (callbacks, conditionals, real arg values).
-- Run: cargo run -- content/examples/event.lua

-- ── lurek.event.* functions ──

--@api-stub: lurek.event.exit
-- Pushes an exit event, requesting the engine to stop.
-- See the module spec for detailed semantics.
local result = lurek.event.exit(code)
print("exit:", result)
return result

--@api-stub: lurek.event.poll
-- Returns an iterator function that pops events from the queue.
-- See the module spec for detailed semantics.
local result = lurek.event.poll()
print("poll:", result)
return result

--@api-stub: lurek.event.clear
-- Discards all pending events in the queue.
-- Pair with the matching constructor to free resources.
-- release the resource and forget the handle
lurek.event.clear()
print("clear done")
print("ok")

--@api-stub: lurek.event.newSignal
-- Creates a new pub-sub Signal dispatcher.
-- Build once at startup; reuse across frames.
local signal = lurek.event.newSignal()
print("created", signal)
return signal

--@api-stub: lurek.event.pump
-- Syncs OS-level events into the queue (no-op in Lurek2D push model).
-- See the module spec for detailed semantics.
local result = lurek.event.pump()
print("pump:", result)
return result

--@api-stub: lurek.event.wait
-- Blocks until the next event arrives or the optional timeout elapses.
-- See the module spec for detailed semantics.
local result = lurek.event.wait(timeout)
print("wait:", result)
return result

--@api-stub: lurek.event.restart
-- Requests that the engine restart at the beginning of the next frame.
-- See the module spec for detailed semantics.
local result = lurek.event.restart()
print("restart:", result)
return result

--@api-stub: lurek.event.quit
-- Alias for `exit()` â€” requests the engine to stop at the end of the current frame.
-- See the module spec for detailed semantics.
function lurek.update(dt)
  if lurek.input.isKeyPressed("escape") then
    lurek.event.quit()
  end
end

--@api-stub: lurek.event.pushDeferred
-- Pushes a named event to the deferred buffer; it will not reach the main queue.
-- Side-effecting; safe to call any time after init.
lurek.event.pushDeferred({ x = 0, y = 0 })
-- mutator; side effect applied
print("pushDeferred done")
print("ok")

--@api-stub: lurek.event.flushDeferred
-- Moves all buffered deferred events into the main event queue and clears the buffer.
-- See the module spec for detailed semantics.
local result = lurek.event.flushDeferred()
print("flushDeferred:", result)
return result

--@api-stub: lurek.event.enableHistory
-- Enables event history recording, keeping the last `capacity` pushed events.
-- See the module spec for detailed semantics.
local result = lurek.event.enableHistory(capacity)
print("enableHistory:", result)
return result

--@api-stub: lurek.event.getHistory
-- Returns an array of recent events as `{name, args}` tables.
-- Cheap to call; safe inside callbacks.
local value = lurek.event.getHistory()
print("getHistory:", value)
return value

--@api-stub: lurek.event.clearHistory
-- Clears all recorded event history.
-- Pair with the matching constructor to free resources.
-- release the resource and forget the handle
lurek.event.clearHistory()
print("clearHistory done")
print("ok")

--@api-stub: lurek.event.push
-- Adds an event item to the end of the event queue for processing.
-- Side-effecting; safe to call any time after init.
lurek.event.push("custom_event", { score = 100 })
lurek.event.push("level_up", { from = 1, to = 2 })
-- receivers see it on the next frame
print("ok")

-- ── Signal methods ──

--@api-stub: Signal:emit
-- Emits the named event, calling all registered callbacks with extra arguments.
-- Side-effecting; safe to call any time after init.
local signal = lurek.event.newSignal()
signal:emit({ x = 0, y = 0 })
print("Signal:emit done")

--@api-stub: Signal:remove
-- Removes a subscription by handle ID.
-- Pair with the matching constructor to free resources.
local signal = lurek.event.newSignal()
signal:remove(handle)
-- signal is now released
print("ok")

--@api-stub: Signal:clear
-- Removes all callbacks for the named event.
-- Pair with the matching constructor to free resources.
local signal = lurek.event.newSignal()
signal:clear("main")
-- signal is now released
print("ok")

--@api-stub: Signal:clearAll
-- Removes all callbacks across all events.
-- Pair with the matching constructor to free resources.
local signal = lurek.event.newSignal()
signal:clearAll()
-- signal is now released
print("ok")

--@api-stub: Signal:getCount
-- Returns the callback count for the named event.
-- Cheap to call; safe inside callbacks.
local signal = lurek.event.newSignal()  -- or your existing handle
local value = signal:getCount("main")
print("Signal:getCount ->", value)

--@api-stub: Signal:getTotalCount
-- Returns the total callback count across all events.
-- Cheap to call; safe inside callbacks.
local signal = lurek.event.newSignal()  -- or your existing handle
local value = signal:getTotalCount()
print("Signal:getTotalCount ->", value)

--@api-stub: Signal:type
-- Returns the type name of this object.
-- See the module spec for detailed semantics.
local signal = lurek.event.newSignal()
signal:type()
print("Signal:type done")

--@api-stub: Signal:typeOf
-- Returns true if the given type name matches this object's type or any parent type.
-- See the module spec for detailed semantics.
local signal = lurek.event.newSignal()
signal:typeOf("main")
print("Signal:typeOf done")

