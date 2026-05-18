--- Patterns Module Part 3: observer, event bus, mediator, debounce, throttle, funnel

--@api-stub: lurek.patterns.newObserver / LObserver:set / get / subscribe / unsubscribe
-- Reactive observer with key-value watching.
do
    ---@type LObserver
    local obs = lurek.patterns.newObserver("player_stats")
    local sub_id = obs:subscribe("hp", function(key, val)
        print("  " .. key .. " changed to " .. val)
    end)
    obs:set("hp", 100)
    obs:set("hp", 75)
    print("hp = " .. obs:get("hp"))
    obs:unsubscribe(sub_id)
    obs:set("hp", 50)
    print("hp after unsub = " .. obs:get("hp"))
end

--@api-stub: LObserver:getCount / subscribe with once
-- Observer subscription count and one-shot subscriptions.
do
    ---@type LObserver
    local obs = lurek.patterns.newObserver()
    obs:subscribe("score", function(key, val)
        print("  score = " .. val)
    end, true)
    print("subs = " .. obs:getCount())
    obs:set("score", 100)
    print("after once-fire: subs = " .. obs:getCount())
end

--@api-stub: lurek.patterns.newEventBus / LEventBus:on / emit / off
-- Publish/subscribe event bus.
do
    ---@type LEventBus
    local bus = lurek.patterns.newEventBus("game_events")
    local id1 = bus:on("damage", function(amount, source)
        print("  damage: " .. amount .. " from " .. source)
    end)
    local id2 = bus:on("damage", function(amount)
        print("  log: took " .. amount .. " damage")
    end, -1)
    bus:emit("damage", 25, "fire")
    bus:off(id1)
    bus:emit("damage", 10, "ice")
end

--@api-stub: LEventBus:getListenerCount / getEvents / clear / clearAll
-- Event bus management.
do
    ---@type LEventBus
    local bus = lurek.patterns.newEventBus()
    bus:on("spawn", function() end)
    bus:on("spawn", function() end)
    bus:on("death", function() end)
    print("spawn listeners = " .. bus:getListenerCount("spawn"))
    print("events = " .. #bus:getEvents())
    bus:clear("spawn")
    print("after clear spawn: " .. bus:getListenerCount("spawn"))
    bus:clearAll()
    print("after clearAll: events = " .. #bus:getEvents())
end

--@api-stub: lurek.patterns.newMediator / LMediator:on / send / off
-- Channel-based message passing.
do
    ---@type LMediator
    local med = lurek.patterns.newMediator()
    local h1 = med:on("ui", function(msg, data)
        print("  ui handler: " .. msg .. " = " .. tostring(data))
    end)
    local h2 = med:on("game", function(event)
        print("  game handler: " .. event)
    end)
    med:send("ui", "health_update", 80)
    med:send("game", "level_complete")
    med:off("ui", h1)
    med:send("ui", "ignored", 0)
end

--@api-stub: LMediator:broadcast / channels / handlerCount / removeChannel / clear
-- Mediator broadcast and channel management.
do
    ---@type LMediator
    local med = lurek.patterns.newMediator()
    med:on("audio", function(...) end)
    med:on("video", function(...) end)
    med:on("input", function(...) end)
    med:broadcast("system_pause")
    print("channels = " .. #med:channels())
    print("audio handlers = " .. med:handlerCount("audio"))
    med:removeChannel("audio")
    print("after remove: channels = " .. #med:channels())
    med:clear()
    print("after clear: channels = " .. #med:channels())
end

--@api-stub: lurek.patterns.newDebounce / LDebounce:trigger / update / onFire
-- Debounce delays action until input stops.
do
    ---@type LDebounce
    local db = lurek.patterns.newDebounce(0.5)
    db:onFire(function()
        print("  debounce fired!")
    end)
    db:trigger()
    print("pending = " .. tostring(db:isPending()))
    db:update(0.3)
    db:trigger()
    db:update(0.3)
    db:update(0.3)
    print("fire count = " .. db:getFireCount())
end

--@api-stub: LDebounce:cancel / isPending / getFireCount
-- Debounce cancellation.
do
    ---@type LDebounce
    local db = lurek.patterns.newDebounce(1.0)
    db:onFire(function() print("  should not fire") end)
    db:trigger()
    print("pending = " .. tostring(db:isPending()))
    db:cancel()
    print("after cancel: pending = " .. tostring(db:isPending()))
    db:update(2.0)
    print("fire count = " .. db:getFireCount())
end

--@api-stub: lurek.patterns.newThrottle / LThrottle:onFire / update / getFireCount
-- Throttle limits action frequency.
do
    ---@type LThrottle
    local th = lurek.patterns.newThrottle(0.2)
    local fires = 0
    th:onFire(function()
        fires = fires + 1
    end)
    for _ = 1, 10 do
        th:update(0.1)
    end
    print("fires over 1s at 0.2 interval = " .. fires)
    print("fire count = " .. th:getFireCount())
end

--@api-stub: LThrottle:reset / setEnabled / getProgress
-- Throttle control.
do
    ---@type LThrottle
    local th = lurek.patterns.newThrottle(1.0)
    th:onFire(function() end)
    th:update(0.5)
    print("progress = " .. th:getProgress())
    th:reset()
    print("after reset progress = " .. th:getProgress())
    th:setEnabled(false)
    th:update(5.0)
    print("disabled progress = " .. th:getProgress())
end

--@api-stub: lurek.patterns.newFunnel / LFunnel:push / update / onFlush
-- Batching funnel collects events and flushes together.
do
    ---@type LFunnel
    local funnel = lurek.patterns.newFunnel(1.0, 5, "damage_log")
    funnel:onFlush(function(entries)
        print("  flushed " .. #entries .. " entries")
        for _, e in ipairs(entries) do
            print("    " .. e.tag .. " = " .. e.value)
        end
    end)
    funnel:push("fire", 10)
    funnel:push("ice", 5)
    funnel:push("fire", 8)
    print("pending = " .. funnel:pendingCount())
    funnel:update(1.1)
    print("flush count = " .. funnel:getFlushCount())
end

--@api-stub: LFunnel:flush / discard / pendingCount / getFlushCount
-- Funnel manual control.
do
    ---@type LFunnel
    local funnel = lurek.patterns.newFunnel(5.0, 0)
    funnel:onFlush(function(entries)
        print("  manual flush: " .. #entries)
    end)
    funnel:push("event_a", 1)
    funnel:push("event_b", 2)
    funnel:flush()
    print("flush count = " .. funnel:getFlushCount())
    funnel:push("event_c", 3)
    funnel:discard()
    print("after discard: pending = " .. funnel:pendingCount())
end

print("patterns_02.lua")
