-- content/examples/event.lua
-- Auto-generated from content/examples2/event_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/event.lua

--- Event Module: queue, signals, polling, deferred events




--@api: lurek.event.push
do

    lurek.event.clear()
    lurek.event.clearHistory()
    lurek.event.enableHistory(0)
    lurek.event.push("player_hit", 25, "critical")
    local events = {}
    for event_name, a1, a2, a3 in lurek.event.poll() do
        events[#events + 1] = { name = event_name, args = { a1, a2, a3 } }
    end
    local first = events[1]
    local count = #events
    lurek.log.info("push count=" .. tostring(count) .. " name=" .. tostring(first and first.name) .. " damage=" .. tostring(first and first.args[1]) .. " tag=" .. tostring(first and first.args[2]))
end

--@api: lurek.event.pushPriority
do

    lurek.event.clear()
    lurek.event.clearHistory()
    lurek.event.enableHistory(0)
    lurek.event.push("normal_evt", 1)
    lurek.event.pushPriority("high_evt", "high", 2)
    local events = {}
    for event_name, a1, a2, a3 in lurek.event.poll() do
        events[#events + 1] = { name = event_name, args = { a1, a2, a3 } }
    end
    local first = events[1] and events[1].name or "none"
    local second = events[2] and events[2].name or "none"
    lurek.log.info("pushPriority first=" .. first .. " second=" .. second .. " count=" .. tostring(#events))
end

--@api: lurek.event.pushDeferred
do

    lurek.event.clear()
    lurek.event.clearHistory()
    lurek.event.enableHistory(0)
    lurek.event.pushDeferred("scene_ready", "main_menu")
    local before = {}
    for event_name, a1, a2, a3 in lurek.event.poll() do
        before[#before + 1] = { name = event_name, args = { a1, a2, a3 } }
    end
    local moved = lurek.event.flushDeferred()
    local after = {}
    for event_name, a1, a2, a3 in lurek.event.poll() do
        after[#after + 1] = { name = event_name, args = { a1, a2, a3 } }
    end
    lurek.log.info("pushDeferred before=" .. tostring(#before) .. " moved=" .. tostring(moved) .. " after=" .. tostring(#after) .. " name=" .. tostring(after[1] and after[1].name))
end

--@api: lurek.event.pushDeferredPriority
do

    lurek.event.clear()
    lurek.event.clearHistory()
    lurek.event.enableHistory(0)
    lurek.event.pushDeferred("normal_deferred", "slow")
    lurek.event.pushDeferredPriority("high_deferred", "high", "fast")
    local moved = lurek.event.flushDeferred()
    local events = {}
    for event_name, a1, a2, a3 in lurek.event.poll() do
        events[#events + 1] = { name = event_name, args = { a1, a2, a3 } }
    end
    lurek.log.info("pushDeferredPriority moved=" .. tostring(moved) .. " first=" .. tostring(events[1] and events[1].name) .. " second=" .. tostring(events[2] and events[2].name))
end

--@api: lurek.event.flushDeferred
do

    lurek.event.clear()
    lurek.event.clearHistory()
    lurek.event.enableHistory(0)
    lurek.event.pushDeferred("scene_ready", "hangar")
    lurek.event.pushDeferred("music_cue", "boss_intro")
    local moved = lurek.event.flushDeferred()
    local events = {}
    for event_name, a1, a2, a3 in lurek.event.poll() do
        events[#events + 1] = { name = event_name, args = { a1, a2, a3 } }
    end
    local last = events[#events] and events[#events].name or "none"
    lurek.log.info("flushDeferred moved=" .. tostring(moved) .. " count=" .. tostring(#events) .. " last=" .. last)
end

--@api: lurek.event.poll
do

    lurek.event.clear()
    lurek.event.clearHistory()
    lurek.event.enableHistory(0)
    lurek.event.push("ev1", 10)
    lurek.event.push("ev2", 20)
    local events = {}
    for event_name, a1, a2, a3 in lurek.event.poll() do
        events[#events + 1] = { name = event_name, args = { a1, a2, a3 } }
    end
    local first = events[1]
    local second = events[2]
    lurek.log.info("poll first=" .. tostring(first and first.name) .. ":" .. tostring(first and first.args[1]) .. " second=" .. tostring(second and second.name) .. ":" .. tostring(second and second.args[1]))
end

--@api: lurek.event.wait
do

    lurek.event.clear()
    lurek.event.clearHistory()
    lurek.event.enableHistory(0)
    local timed_out, empty_name, empty_args = lurek.event.wait(0.01)
    lurek.event.push("wake_up", "now")
    local ok, name, args = lurek.event.wait(0)
    lurek.log.info("wait timeout=" .. tostring(timed_out) .. " empty=" .. tostring(empty_name) .. "/" .. tostring(#empty_args) .. " ok=" .. tostring(ok) .. " name=" .. tostring(name) .. " arg=" .. tostring(args[1]))
end

--@api: lurek.event.clear
do

    lurek.event.clear()
    lurek.event.clearHistory()
    lurek.event.enableHistory(0)
    lurek.event.push("discard_me", 1)
    lurek.event.push("discard_me_too", 2)
    lurek.event.clear()
    local events = {}
    for event_name, a1, a2, a3 in lurek.event.poll() do
        events[#events + 1] = { name = event_name, args = { a1, a2, a3 } }
    end
    lurek.log.info("clear remaining=" .. tostring(#events) .. " queue_cleared=" .. tostring(#events == 0))
end

--@api: lurek.event.pump
do

    lurek.event.clear()
    lurek.event.clearHistory()
    lurek.event.enableHistory(0)
    lurek.event.push("hud_refresh", "health_bar")
    lurek.event.pump()
    local events = {}
    for event_name, a1, a2, a3 in lurek.event.poll() do
        events[#events + 1] = { name = event_name, args = { a1, a2, a3 } }
    end
    local first = events[1] and events[1].name or "none"
    lurek.log.info("pump remaining=" .. tostring(#events) .. " first=" .. first .. " callable=" .. tostring(type(lurek.event.pump) == "function"))
end

--@api: lurek.event.enableHistory
do

    lurek.event.clear()
    lurek.event.clearHistory()
    lurek.event.enableHistory(0)
    lurek.event.enableHistory(2)
    lurek.event.push("score", 100)
    lurek.event.push("score", 200)
    local history = lurek.event.getHistory()
    lurek.log.info("enableHistory capacity=2 entries=" .. tostring(#history) .. " latest=" .. tostring(history[#history] and history[#history].args[1]))
end

--@api: lurek.event.getHistory
do

    lurek.event.clear()
    lurek.event.clearHistory()
    lurek.event.enableHistory(0)
    lurek.event.enableHistory(4)
    lurek.event.push("score", 999, "gold")
    local history = lurek.event.getHistory()
    local first = history[1]
    local arg_count = first and #first.args or 0
    lurek.log.info("getHistory entries=" .. tostring(#history) .. " name=" .. tostring(first and first.name) .. " arg_count=" .. tostring(arg_count))
end

--@api: lurek.event.clearHistory
do

    lurek.event.clear()
    lurek.event.clearHistory()
    lurek.event.enableHistory(0)
    lurek.event.enableHistory(4)
    lurek.event.push("histA", 1)
    lurek.event.push("histB", 2)
    local before = #lurek.event.getHistory()
    lurek.event.clearHistory()
    local after = #lurek.event.getHistory()
    lurek.log.info("clearHistory before=" .. tostring(before) .. " after=" .. tostring(after))
end

--@api: lurek.event.exit
do

    lurek.event.clear()
    lurek.event.clearHistory()
    lurek.event.enableHistory(0)
    lurek.event.enableHistory(2)
    lurek.event.push("menu_action", "exit_requested")
    local callable = type(lurek.event.exit) == "function"
    local history = lurek.event.getHistory()
    lurek.log.info("exit callable=" .. tostring(callable) .. " note=not_called entries=" .. tostring(#history) .. " action=" .. tostring(history[1] and history[1].args[1]))
end

--@api: lurek.event.quit
do

    lurek.event.clear()
    lurek.event.clearHistory()
    lurek.event.enableHistory(0)
    lurek.event.enableHistory(2)
    lurek.event.push("menu_action", "quit_requested")
    local callable = type(lurek.event.quit) == "function"
    local history = lurek.event.getHistory()
    lurek.log.info("quit callable=" .. tostring(callable) .. " note=not_called entries=" .. tostring(#history) .. " action=" .. tostring(history[1] and history[1].args[1]))
end

--@api: lurek.event.restart
do

    lurek.event.clear()
    lurek.event.clearHistory()
    lurek.event.enableHistory(0)
    lurek.event.enableHistory(2)
    lurek.event.push("menu_action", "restart_requested")
    local callable = type(lurek.event.restart) == "function"
    local history = lurek.event.getHistory()
    lurek.log.info("restart callable=" .. tostring(callable) .. " note=not_called entries=" .. tostring(#history) .. " action=" .. tostring(history[1] and history[1].args[1]))
end

--@api: lurek.event.newSignal
do

    local sig = lurek.event.newSignal()
    local type_name = sig:type()
    local total = sig:getTotalCount()
    local is_signal = sig:typeOf("LSignal")
    lurek.log.info("newSignal type=" .. type_name .. " total=" .. tostring(total) .. " is_signal=" .. tostring(is_signal))
end

--@api: LSignal:connect
do

    local sig = lurek.event.newSignal()
    local seen = "none"
    local handle = sig:connect("player.*", function(kind) seen = kind end)
    sig:emit("player.jump", "jump")
    local count = sig:getCount("player.*")
    lurek.log.info("connect handle=" .. tostring(handle) .. " seen=" .. seen .. " count=" .. tostring(count))
end

--@api: LSignal:register
do

    local sig = lurek.event.newSignal()
    local total = 0
    local handle = sig:register("heal", function(amount) total = total + amount end)
    sig:emit("heal", 15)
    local count = sig:getCount("heal")
    lurek.log.info("register handle=" .. tostring(handle) .. " total=" .. tostring(total) .. " count=" .. tostring(count))
end

--@api: LSignal:registerWithFilter
do

    local sig = lurek.event.newSignal()
    local hits = 0
    local handle = sig:registerWithFilter("hit", function(dmg) hits = hits + dmg end, function(dmg) return dmg > 50 end)
    sig:emit("hit", 10)
    sig:emit("hit", 75)
    lurek.log.info("registerWithFilter handle=" .. tostring(handle) .. " hits=" .. tostring(hits) .. " total=" .. tostring(sig:getTotalCount()))
end

--@api: LSignal:once
do

    local sig = lurek.event.newSignal()
    local count = 0
    local handle = sig:once("init", function() count = count + 1 end)
    sig:emit("init")
    sig:emit("init")
    local remaining = sig:getCount("init")
    lurek.log.info("once handle=" .. tostring(handle) .. " count=" .. tostring(count) .. " remaining=" .. tostring(remaining))
end

--@api: LSignal:emit
do

    local sig = lurek.event.newSignal()
    local received_a = nil
    local received_b = nil
    sig:connect("ping", function(a, b) received_a = a; received_b = b end)
    sig:emit("ping", 4, "ok")
    lurek.log.info("emit a=" .. tostring(received_a) .. " b=" .. tostring(received_b) .. " total=" .. tostring(sig:getTotalCount()))
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
    lurek.log.info("remove removed=" .. tostring(removed) .. " count_a=" .. tostring(count_a) .. " count_b=" .. tostring(count_b) .. " remaining=" .. tostring(sig:getCount("tick")))
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
    lurek.log.info("clear removed=" .. tostring(removed) .. " clicks=" .. tostring(clicks) .. " hover=" .. tostring(hover))
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
    lurek.log.info("clearAll before=" .. tostring(before) .. " removed=" .. tostring(removed) .. " after=" .. tostring(after))
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
    lurek.log.info("getCount clicks=" .. tostring(clicks) .. " hover=" .. tostring(hover) .. " missing=" .. tostring(missing))
end

--@api: LSignal:getTotalCount
do

    local sig = lurek.event.newSignal()
    sig:register("a", function() end)
    sig:register("b", function() end)
    sig:register("b", function() end)
    local total = sig:getTotalCount()
    local clicks = sig:getCount("a")
    lurek.log.info("getTotalCount total=" .. tostring(total) .. " a=" .. tostring(clicks) .. " b=" .. tostring(sig:getCount("b")))
end

--@api: LSignal:type
do

    local sig = lurek.event.newSignal()
    local type_name = sig:type()
    local total = sig:getTotalCount()
    local is_signal = sig:typeOf("LSignal")
    lurek.log.info("type name=" .. type_name .. " total=" .. tostring(total) .. " is_signal=" .. tostring(is_signal))
end

--@api: LSignal:typeOf
do

    local sig = lurek.event.newSignal()
    local is_signal = sig:typeOf("LSignal")
    local is_object = sig:typeOf("LObject")
    local is_entity = sig:typeOf("LEntity")
    lurek.log.info("typeOf signal=" .. tostring(is_signal) .. " object=" .. tostring(is_object) .. " entity=" .. tostring(is_entity))
end

--@api: lurek.event.newChangeSet
do
    local changes = lurek.event.newChangeSet({ schema = "actor.v1", revision = 7, maxChanges = 16 })
    local schema = changes:schema()
    local revision = changes:revision()
    local empty = changes:isEmpty()
    lurek.log.info("changeset schema=" .. schema .. " revision=" .. revision .. " empty=" .. tostring(empty))
end

--@api: lurek.event.fromChangeSetTable
do
    local source = lurek.event.newChangeSet({ schema = "save.v1", revision = 2 })
    source:append(11, "health", "set", { value = 90 })
    local restored = lurek.event.fromChangeSetTable(source:toTable())
    local row = restored:toTable().changes[1]
    lurek.log.info("restored object=" .. row.objectId .. " component=" .. row.component .. " value=" .. row.payload.value)
end

--@api: LChangeSet:append
do
local changes = lurek.event.newChangeSet({ schema = "world.v1" })
local count = changes:append(42, "position", "set", { x = 12, y = 8, level = 1 })
local table_value = changes:toTable()
lurek.log.info("appended=" .. count .. " records=" .. #table_value.changes .. " operation=" .. table_value.changes[1].operation)
    local example_ok = true
end

--@api: LChangeSet:clear
do
    local changes = lurek.event.newChangeSet()
    changes:append(1, "flag", "set", true)
    changes:append(2, "flag", "set", false)
    local removed = changes:clear()
    lurek.log.info("cleared=" .. removed .. " remaining=" .. changes:len() .. " empty=" .. tostring(changes:isEmpty()))
end

--@api: LChangeSet:hash
do
    local changes = lurek.event.newChangeSet({ schema = "hash.v1", revision = 3 })
    changes:append(7, "score", "set", 99)
    local hash = changes:hash()
    local snapshot_hash = changes:snapshot().hash
    lurek.log.info("hash=" .. tostring(hash) .. " snapshot_matches=" .. tostring(hash == snapshot_hash))
end

--@api: LChangeSet:isEmpty
do
    local changes = lurek.event.newChangeSet()
    local before = changes:isEmpty()
    changes:append(3, "alive", "set", true)
    local after = changes:isEmpty()
    lurek.log.info("empty before=" .. tostring(before) .. " after append=" .. tostring(after))
end

--@api: LChangeSet:len
do
    local changes = lurek.event.newChangeSet()
    local before = changes:len()
    changes:append(8, "ammo", "set", 12)
    local after = changes:len()
    lurek.log.info("length before=" .. before .. " after=" .. after)
end

--@api: LChangeSet:restore
do
    local changes = lurek.event.newChangeSet({ schema = "restore.v1" })
    local source = lurek.event.newChangeSet({ schema = "restore.v1" })
    source:append(5, "state", "set", { ready = true })
    changes:restore(source:snapshot())
    lurek.log.info("restored len=" .. changes:len() .. " state=" .. tostring(changes:toTable().changes[1].payload.ready))
end

--@api: LChangeSet:revision
do
local changes = lurek.event.newChangeSet({ schema = "revision.v1", revision = 18 })
local revision = changes:revision()
local snapshot_revision = changes:snapshot().revision
lurek.log.info("revision=" .. revision .. " snapshot=" .. snapshot_revision)
    local example_ok = true
end

--@api: LChangeSet:schema
do
local changes = lurek.event.newChangeSet({ schema = "content.v2" })
local schema = changes:schema()
local table_schema = changes:toTable().schema
lurek.log.info("schema=" .. schema .. " table_schema=" .. table_schema)
    local example_ok = true
end

--@api: LChangeSet:snapshot
do
local changes = lurek.event.newChangeSet({ schema = "network.v1", revision = 4 })
changes:append(10, "owner", "set", "player_one")
local snapshot = changes:snapshot()
lurek.log.info("snapshot schema=" .. snapshot.schema .. " revision=" .. snapshot.revision .. " rows=" .. #snapshot.changes)
    local example_ok = true
end

--@api: LChangeSet:toTable
do
local changes = lurek.event.newChangeSet({ schema = "table.v1" })
changes:append(4, "tag", "set", "quest")
local value = changes:toTable()
lurek.log.info("table schema=" .. value.schema .. " object=" .. value.changes[1].objectId .. " payload=" .. value.changes[1].payload)
    local example_ok = true
end

--@api: LChangeSet:type
do
local changes = lurek.event.newChangeSet()
local type_name = changes:type()
lurek.log.info("changeset type=" .. type_name .. " handle=" .. tostring(changes ~= nil))
    local example_ok = true
    local example_label = "LChangeSet:type"
end

--@api: LChangeSet:typeOf
do
local changes = lurek.event.newChangeSet()
local is_changeset = changes:typeOf("LChangeSet")
local is_object = changes:typeOf("LObject")
lurek.log.info("changeset=" .. tostring(is_changeset) .. " object=" .. tostring(is_object))
    local example_ok = true
end
