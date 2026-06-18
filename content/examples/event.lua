-- content/examples/event.lua
-- Auto-generated from content/examples2/event_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/event.lua

--- Event Module: queue, signals, polling, deferred events

local function event_log(message)
    lurek.log.info("[event] " .. message)
end

local function reset_event_state()
    lurek.event.clear()
    lurek.event.clearHistory()
    lurek.event.enableHistory(0)
end

local function collect_polled_events()
    local events = {}
    for name, a1, a2, a3 in lurek.event.poll() do
        events[#events + 1] = { name = name, args = { a1, a2, a3 } }
    end
    return events
end

--@api: lurek.event.push
do
    reset_event_state()
    lurek.event.push("player_hit", 25, "critical")
    local events = collect_polled_events()
    local first = events[1]
    local count = #events
    event_log("push count=" .. tostring(count) .. " name=" .. tostring(first and first.name) .. " damage=" .. tostring(first and first.args[1]) .. " tag=" .. tostring(first and first.args[2]))
end

--@api: lurek.event.pushPriority
do
    reset_event_state()
    lurek.event.push("normal_evt", 1)
    lurek.event.pushPriority("high_evt", "high", 2)
    local events = collect_polled_events()
    local first = events[1] and events[1].name or "none"
    local second = events[2] and events[2].name or "none"
    event_log("pushPriority first=" .. first .. " second=" .. second .. " count=" .. tostring(#events))
end

--@api: lurek.event.pushDeferred
do
    reset_event_state()
    lurek.event.pushDeferred("scene_ready", "main_menu")
    local before = collect_polled_events()
    local moved = lurek.event.flushDeferred()
    local after = collect_polled_events()
    event_log("pushDeferred before=" .. tostring(#before) .. " moved=" .. tostring(moved) .. " after=" .. tostring(#after) .. " name=" .. tostring(after[1] and after[1].name))
end

--@api: lurek.event.pushDeferredPriority
do
    reset_event_state()
    lurek.event.pushDeferred("normal_deferred", "slow")
    lurek.event.pushDeferredPriority("high_deferred", "high", "fast")
    local moved = lurek.event.flushDeferred()
    local events = collect_polled_events()
    event_log("pushDeferredPriority moved=" .. tostring(moved) .. " first=" .. tostring(events[1] and events[1].name) .. " second=" .. tostring(events[2] and events[2].name))
end

--@api: lurek.event.flushDeferred
do
    reset_event_state()
    lurek.event.pushDeferred("scene_ready", "hangar")
    lurek.event.pushDeferred("music_cue", "boss_intro")
    local moved = lurek.event.flushDeferred()
    local events = collect_polled_events()
    local last = events[#events] and events[#events].name or "none"
    event_log("flushDeferred moved=" .. tostring(moved) .. " count=" .. tostring(#events) .. " last=" .. last)
end

--@api: lurek.event.poll
do
    reset_event_state()
    lurek.event.push("ev1", 10)
    lurek.event.push("ev2", 20)
    local events = collect_polled_events()
    local first = events[1]
    local second = events[2]
    event_log("poll first=" .. tostring(first and first.name) .. ":" .. tostring(first and first.args[1]) .. " second=" .. tostring(second and second.name) .. ":" .. tostring(second and second.args[1]))
end

--@api: lurek.event.wait
do
    reset_event_state()
    local timed_out, empty_name, empty_args = lurek.event.wait(0.01)
    lurek.event.push("wake_up", "now")
    local ok, name, args = lurek.event.wait(0)
    event_log("wait timeout=" .. tostring(timed_out) .. " empty=" .. tostring(empty_name) .. "/" .. tostring(#empty_args) .. " ok=" .. tostring(ok) .. " name=" .. tostring(name) .. " arg=" .. tostring(args[1]))
end

--@api: lurek.event.clear
do
    reset_event_state()
    lurek.event.push("discard_me", 1)
    lurek.event.push("discard_me_too", 2)
    lurek.event.clear()
    local events = collect_polled_events()
    event_log("clear remaining=" .. tostring(#events) .. " queue_cleared=" .. tostring(#events == 0))
end

--@api: lurek.event.pump
do
    reset_event_state()
    lurek.event.push("hud_refresh", "health_bar")
    lurek.event.pump()
    local events = collect_polled_events()
    local first = events[1] and events[1].name or "none"
    event_log("pump remaining=" .. tostring(#events) .. " first=" .. first .. " callable=" .. tostring(type(lurek.event.pump) == "function"))
end

--@api: lurek.event.enableHistory
do
    reset_event_state()
    lurek.event.enableHistory(2)
    lurek.event.push("score", 100)
    lurek.event.push("score", 200)
    local history = lurek.event.getHistory()
    event_log("enableHistory capacity=2 entries=" .. tostring(#history) .. " latest=" .. tostring(history[#history] and history[#history].args[1]))
end

--@api: lurek.event.getHistory
do
    reset_event_state()
    lurek.event.enableHistory(4)
    lurek.event.push("score", 999, "gold")
    local history = lurek.event.getHistory()
    local first = history[1]
    local arg_count = first and #first.args or 0
    event_log("getHistory entries=" .. tostring(#history) .. " name=" .. tostring(first and first.name) .. " arg_count=" .. tostring(arg_count))
end

--@api: lurek.event.clearHistory
do
    reset_event_state()
    lurek.event.enableHistory(4)
    lurek.event.push("histA", 1)
    lurek.event.push("histB", 2)
    local before = #lurek.event.getHistory()
    lurek.event.clearHistory()
    local after = #lurek.event.getHistory()
    event_log("clearHistory before=" .. tostring(before) .. " after=" .. tostring(after))
end

--@api: lurek.event.exit
do
    reset_event_state()
    lurek.event.enableHistory(2)
    lurek.event.push("menu_action", "exit_requested")
    local callable = type(lurek.event.exit) == "function"
    local history = lurek.event.getHistory()
    event_log("exit callable=" .. tostring(callable) .. " note=not_called entries=" .. tostring(#history) .. " action=" .. tostring(history[1] and history[1].args[1]))
end

--@api: lurek.event.quit
do
    reset_event_state()
    lurek.event.enableHistory(2)
    lurek.event.push("menu_action", "quit_requested")
    local callable = type(lurek.event.quit) == "function"
    local history = lurek.event.getHistory()
    event_log("quit callable=" .. tostring(callable) .. " note=not_called entries=" .. tostring(#history) .. " action=" .. tostring(history[1] and history[1].args[1]))
end

--@api: lurek.event.restart
do
    reset_event_state()
    lurek.event.enableHistory(2)
    lurek.event.push("menu_action", "restart_requested")
    local callable = type(lurek.event.restart) == "function"
    local history = lurek.event.getHistory()
    event_log("restart callable=" .. tostring(callable) .. " note=not_called entries=" .. tostring(#history) .. " action=" .. tostring(history[1] and history[1].args[1]))
end

--@api: lurek.event.newSignal
do
    local sig = lurek.event.newSignal()
    local type_name = sig:type()
    local total = sig:getTotalCount()
    local is_signal = sig:typeOf("LSignal")
    event_log("newSignal type=" .. type_name .. " total=" .. tostring(total) .. " is_signal=" .. tostring(is_signal))
end

--@api: LSignal:connect
do
    local sig = lurek.event.newSignal()
    local seen = "none"
    local handle = sig:connect("player.*", function(kind) seen = kind end)
    sig:emit("player.jump", "jump")
    local count = sig:getCount("player.*")
    event_log("connect handle=" .. tostring(handle) .. " seen=" .. seen .. " count=" .. tostring(count))
end

--@api: LSignal:register
do
    local sig = lurek.event.newSignal()
    local total = 0
    local handle = sig:register("heal", function(amount) total = total + amount end)
    sig:emit("heal", 15)
    local count = sig:getCount("heal")
    event_log("register handle=" .. tostring(handle) .. " total=" .. tostring(total) .. " count=" .. tostring(count))
end

--@api: LSignal:registerWithFilter
do
    local sig = lurek.event.newSignal()
    local hits = 0
    local handle = sig:registerWithFilter("hit", function(dmg) hits = hits + dmg end, function(dmg) return dmg > 50 end)
    sig:emit("hit", 10)
    sig:emit("hit", 75)
    event_log("registerWithFilter handle=" .. tostring(handle) .. " hits=" .. tostring(hits) .. " total=" .. tostring(sig:getTotalCount()))
end

--@api: LSignal:once
do
    local sig = lurek.event.newSignal()
    local count = 0
    local handle = sig:once("init", function() count = count + 1 end)
    sig:emit("init")
    sig:emit("init")
    local remaining = sig:getCount("init")
    event_log("once handle=" .. tostring(handle) .. " count=" .. tostring(count) .. " remaining=" .. tostring(remaining))
end

--@api: LSignal:emit
do
    local sig = lurek.event.newSignal()
    local received_a = nil
    local received_b = nil
    sig:connect("ping", function(a, b) received_a = a; received_b = b end)
    sig:emit("ping", 4, "ok")
    event_log("emit a=" .. tostring(received_a) .. " b=" .. tostring(received_b) .. " total=" .. tostring(sig:getTotalCount()))
end

--@api: LSignal:remove
do
    local sig = lurek.event.newSignal()
    local count_a = 0
    local count_b = 0
    local handle_a = sig:connect("tick", function() count_a = count_a + 1 end)
    sig:connect("tick", function() count_b = count_b + 1 end)
    local removed = sig:remove(handle_a)
    sig:emit("tick")
    event_log("remove removed=" .. tostring(removed) .. " count_a=" .. tostring(count_a) .. " count_b=" .. tostring(count_b) .. " remaining=" .. tostring(sig:getCount("tick")))
end

--@api: LSignal:clear
do
    local sig = lurek.event.newSignal()
    sig:connect("click", function() end)
    sig:connect("click", function() end)
    sig:connect("hover", function() end)
    local removed = sig:clear("click")
    local clicks = sig:getCount("click")
    local hover = sig:getCount("hover")
    event_log("clear removed=" .. tostring(removed) .. " clicks=" .. tostring(clicks) .. " hover=" .. tostring(hover))
end

--@api: LSignal:clearAll
do
    local sig = lurek.event.newSignal()
    sig:connect("a", function() end)
    sig:connect("b", function() end)
    sig:connect("b", function() end)
    local before = sig:getTotalCount()
    local removed = sig:clearAll()
    local after = sig:getTotalCount()
    event_log("clearAll before=" .. tostring(before) .. " removed=" .. tostring(removed) .. " after=" .. tostring(after))
end

--@api: LSignal:getCount
do
    local sig = lurek.event.newSignal()
    sig:register("click", function() end)
    sig:register("click", function() end)
    sig:register("hover", function() end)
    local clicks = sig:getCount("click")
    local hover = sig:getCount("hover")
    local missing = sig:getCount("missing")
    event_log("getCount clicks=" .. tostring(clicks) .. " hover=" .. tostring(hover) .. " missing=" .. tostring(missing))
end

--@api: LSignal:getTotalCount
do
    local sig = lurek.event.newSignal()
    sig:register("a", function() end)
    sig:register("b", function() end)
    sig:register("b", function() end)
    local total = sig:getTotalCount()
    local clicks = sig:getCount("a")
    event_log("getTotalCount total=" .. tostring(total) .. " a=" .. tostring(clicks) .. " b=" .. tostring(sig:getCount("b")))
end

--@api: LSignal:type
do
    local sig = lurek.event.newSignal()
    local type_name = sig:type()
    local total = sig:getTotalCount()
    local is_signal = sig:typeOf("LSignal")
    event_log("type name=" .. type_name .. " total=" .. tostring(total) .. " is_signal=" .. tostring(is_signal))
end

--@api: LSignal:typeOf
do
    local sig = lurek.event.newSignal()
    local is_signal = sig:typeOf("LSignal")
    local is_object = sig:typeOf("LObject")
    local is_entity = sig:typeOf("LEntity")
    event_log("typeOf signal=" .. tostring(is_signal) .. " object=" .. tostring(is_object) .. " entity=" .. tostring(is_entity))
end
