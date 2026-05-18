--- Event Module: queue, signals, polling, deferred events

--@api-stub: lurek.event.push
-- Pushes an event into the shared event queue.
do
    lurek.event.push("player_hit", 25)
    print("pushed 'player_hit' event")
end

--@api-stub: lurek.event.pushPriority
-- Pushes an event with explicit priority.
do
    lurek.event.pushPriority("critical_error", "high", "out of memory")
    print("pushed high-priority event")
end

--@api-stub: lurek.event.pushDeferred
-- Adds an event to the deferred buffer for later flushing.
do
    lurek.event.pushDeferred("scene_ready", "main_menu")
    print("deferred 'scene_ready'")
end

--@api-stub: lurek.event.pushDeferredPriority
-- Adds a priority event to the deferred buffer.
do
    lurek.event.pushDeferredPriority("system_alert", "high", "low battery")
    print("deferred high-priority 'system_alert'")
end

--@api-stub: lurek.event.flushDeferred
-- Flushes deferred events into the live queue.
do
    lurek.event.pushDeferred("a", 1)
    lurek.event.pushDeferred("b", 2)
    local count = lurek.event.flushDeferred()
    print("flushed " .. count .. " deferred events")
end

--@api-stub: lurek.event.poll
-- Creates a polling iterator for the event queue.
do
    lurek.event.push("test_event", 42)
    for name, a1 in lurek.event.poll() do
        print("polled: " .. name .. " arg=" .. tostring(a1))
    end
end

--@api-stub: lurek.event.wait
-- Waits for the next event with optional timeout.
do
    lurek.event.push("wake_up", "now")
    local ok, name, args = lurek.event.wait(0.1)
    if ok then
        print("received: " .. name)
    else
        print("timed out")
    end
end

--@api-stub: lurek.event.clear
-- Clears all pending events from the queue.
do
    lurek.event.push("discard_me", 1)
    lurek.event.clear()
    print("queue cleared")
end

--@api-stub: lurek.event.pump
-- Pumps the shared event queue without removing events.
do
    lurek.event.pump()
    print("pumped")
end

--@api-stub: lurek.event.enableHistory
-- Enables push history with a max retained capacity.
do
    lurek.event.enableHistory(100)
    print("history enabled, capacity = 100")
end

--@api-stub: lurek.event.getHistory
-- Returns retained event history entries.
do
    lurek.event.enableHistory(50)
    lurek.event.push("score", 999)
    local history = lurek.event.getHistory()
    for _, entry in ipairs(history) do
        print("history: " .. entry.name)
    end
end

--@api-stub: lurek.event.clearHistory
-- Clears retained pushed event history.
do
    lurek.event.clearHistory()
    print("history cleared")
end

--@api-stub: lurek.event.exit
-- Requests engine shutdown with an optional exit code.
do
    -- lurek.event.exit(0)
    print("exit(0) would shut down the engine")
end

--@api-stub: lurek.event.quit
-- Requests engine shutdown with exit code zero.
do
    -- lurek.event.quit()
    print("quit() would shut down the engine")
end

--@api-stub: lurek.event.restart
-- Requests a full engine restart cycle.
do
    -- lurek.event.restart()
    print("restart() would restart the engine")
end

--@api-stub: lurek.event.newSignal
-- Creates an isolated signal dispatcher.
do
    local sig = lurek.event.newSignal()
    print("signal type = " .. sig:type())
end

--@api-stub: LSignal:connect
-- Registers a callback for a signal pattern.
do
    local sig = lurek.event.newSignal()
    local handle = sig:connect("damage", function(amount)
        print("took " .. tostring(amount) .. " damage")
    end)
    print("connected, handle = " .. handle)
end

--@api-stub: LSignal:register
-- Registers a callback for an exact signal name.
do
    local sig = lurek.event.newSignal()
    local handle = sig:register("heal", function(amount)
        print("healed " .. tostring(amount))
    end)
    print("registered, handle = " .. handle)
end

--@api-stub: LSignal:registerWithFilter
-- Registers a callback with a filter predicate.
do
    local sig = lurek.event.newSignal()
    local handle = sig:registerWithFilter("hit", function(dmg)
        print("critical hit: " .. tostring(dmg))
    end, function(dmg)
        return dmg > 50
    end)
    print("registered with filter, handle = " .. handle)
end

--@api-stub: LSignal:once
-- Registers a one-shot callback removed after first emission.
do
    local sig = lurek.event.newSignal()
    local handle = sig:once("init", function()
        print("initialized (fires once)")
    end)
    print("once handle = " .. handle)
end

--@api-stub: LSignal:emit
-- Emits a signal event, invoking matching callbacks.
do
    local sig = lurek.event.newSignal()
    sig:connect("greet", function(name)
        print("hello " .. tostring(name))
    end)
    sig:emit("greet", "world")
end

--@api-stub: LSignal:remove
-- Removes a callback by subscription handle.
do
    local sig = lurek.event.newSignal()
    local h = sig:connect("tick", function() end)
    local removed = sig:remove(h)
    print("removed = " .. tostring(removed))
end

--@api-stub: LSignal:clear
-- Removes all callbacks for one signal name.
do
    local sig = lurek.event.newSignal()
    sig:connect("update", function() end)
    sig:connect("update", function() end)
    local count = sig:clear("update")
    print("cleared " .. count .. " callbacks")
end

--@api-stub: LSignal:clearAll
-- Removes every callback from this signal.
do
    local sig = lurek.event.newSignal()
    sig:connect("a", function() end)
    sig:connect("b", function() end)
    local count = sig:clearAll()
    print("cleared all: " .. count)
end

--@api-stub: LSignal:getCount
-- Returns the callback count for one signal name.
do
    local sig = lurek.event.newSignal()
    sig:connect("tick", function() end)
    sig:connect("tick", function() end)
    print("tick count = " .. sig:getCount("tick"))
end

--@api-stub: LSignal:getTotalCount
-- Returns the total callback count across all names.
do
    local sig = lurek.event.newSignal()
    sig:connect("a", function() end)
    sig:connect("b", function() end)
    sig:connect("b", function() end)
    print("total = " .. sig:getTotalCount())
end

--@api-stub: LSignal:type
-- Returns the type name "LSignal".
do
    local sig = lurek.event.newSignal()
    print("type = " .. sig:type())
end

--@api-stub: LSignal:typeOf
-- Returns whether this signal matches a type name.
do
    local sig = lurek.event.newSignal()
    print("is Signal = " .. tostring(sig:typeOf("Signal")))
end

print("event_00.lua")
