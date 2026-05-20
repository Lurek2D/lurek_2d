-- content/examples/event.lua
-- Auto-generated from content/examples2/event_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/event.lua

--- Event Module: queue, signals, polling, deferred events


--@api-stub: lurek.event.push
do
    lurek.event.push("player_hit", 25)
    print("pushed 'player_hit' event")
end

--@api-stub: lurek.event.pushPriority
do
    lurek.event.pushPriority("critical_error", "high", "out of memory")
    print("pushed high-priority event")
end

--@api-stub: lurek.event.pushDeferred
do
    lurek.event.pushDeferred("scene_ready", "main_menu")
    print("deferred 'scene_ready'")
end

--@api-stub: lurek.event.pushDeferredPriority
do
    lurek.event.pushDeferredPriority("system_alert", "high", "low battery")
    print("deferred high-priority 'system_alert'")
end

--@api-stub: lurek.event.flushDeferred
do
    lurek.event.pushDeferred("a", 1)
    lurek.event.pushDeferred("b", 2)
    local count = lurek.event.flushDeferred()
    print("flushed " .. count .. " deferred events")
end

--@api-stub: lurek.event.poll
do
    lurek.event.push("test_event", 42)
    for name, a1 in lurek.event.poll() do
        print("polled: " .. name .. " arg=" .. tostring(a1))
    end
end

--@api-stub: lurek.event.wait
do
    lurek.event.push("wake_up", "now")
    local ok, name = lurek.event.wait(0.1)
    print(ok and ("received: " .. name) or "timed out")
end

--@api-stub: lurek.event.clear
do
    lurek.event.push("discard_me", 1)
    lurek.event.clear()
    print("queue cleared")
end

--@api-stub: lurek.event.pump
do
    lurek.event.pump()
    print("pumped")
end

--@api-stub: lurek.event.enableHistory
do
    lurek.event.enableHistory(100)
    print("history enabled, capacity = 100")
end

--@api-stub: lurek.event.getHistory
do
    lurek.event.enableHistory(50)
    lurek.event.push("score", 999)
    local history = lurek.event.getHistory()
    print("history entries = " .. #history)
end

--@api-stub: lurek.event.clearHistory
do
    lurek.event.clearHistory()
    print("history cleared")
end

--@api-stub: lurek.event.exit
do
    -- lurek.event.exit(0)
    print("exit(0) would shut down the engine")
end

--@api-stub: lurek.event.quit
do
    -- lurek.event.quit()
    print("quit() would shut down the engine")
end

--@api-stub: lurek.event.restart
do
    -- lurek.event.restart()
    print("restart() would restart the engine")
end

--@api-stub: lurek.event.newSignal
do
    local sig = lurek.event.newSignal()
    print("signal type = " .. sig:type())
end

--@api-stub: LSignal:connect
do
    local sig = lurek.event.newSignal()
    local handle = sig:connect("damage", function(amount)
        print("took " .. tostring(amount) .. " damage")
    end)
    print("connected, handle = " .. handle)
end

--@api-stub: LSignal:register
do
    local sig = lurek.event.newSignal()
    local handle = sig:register("heal", function(amount)
        print("healed " .. tostring(amount))
    end)
    print("registered, handle = " .. handle)
end

--@api-stub: LSignal:registerWithFilter
do
    local sig = lurek.event.newSignal()
    local handle = sig:registerWithFilter("hit", function(dmg) print("critical hit: " .. tostring(dmg)) end, function(dmg) return dmg > 50 end)
    print("registered with filter, handle = " .. handle)
end

--@api-stub: LSignal:once
do
    local sig = lurek.event.newSignal()
    local handle = sig:once("init", function()
        print("initialized (fires once)")
    end)
    print("once handle = " .. handle)
end

--@api-stub: LSignal:emit
do
    local sig = lurek.event.newSignal()
    sig:connect("greet", function(name)
        print("hello " .. tostring(name))
    end)
    sig:emit("greet", "world")
end

--@api-stub: LSignal:remove
do
    local sig = lurek.event.newSignal()
    local h = sig:connect("tick", function() end)
    local removed = sig:remove(h)
    print("removed = " .. tostring(removed))
end

--@api-stub: LSignal:clear
do
    local sig = lurek.event.newSignal()
    sig:connect("update", function() end)
    sig:connect("update", function() end)
    local count = sig:clear("update")
    print("cleared " .. count .. " callbacks")
end

--@api-stub: LSignal:clearAll
do
    local sig = lurek.event.newSignal()
    sig:connect("a", function() end)
    sig:connect("b", function() end)
    local count = sig:clearAll()
    print("cleared all: " .. count)
end

--@api-stub: LSignal:getCount
do
    local sig = lurek.event.newSignal()
    sig:connect("tick", function() end)
    sig:connect("tick", function() end)
    print("tick count = " .. sig:getCount("tick"))
end

--@api-stub: LSignal:getTotalCount
do
    local sig = lurek.event.newSignal()
    sig:connect("a", function() end)
    sig:connect("b", function() end)
    sig:connect("b", function() end)
    print("total = " .. sig:getTotalCount())
end

--@api-stub: LSignal:type
do
    local sig = lurek.event.newSignal()
    print("type = " .. sig:type())
end

--@api-stub: LSignal:typeOf
do
    local sig = lurek.event.newSignal()
    print("is Signal = " .. tostring(sig:typeOf("Signal")))
end

print("content/examples/event.lua")
