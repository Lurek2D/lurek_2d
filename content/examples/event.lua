-- content/examples/event.lua
-- lurek.event API examples.
-- Run: cargo run -- content/examples/event.lua

--@api-stub: lurek.event.exit -- Requests engine shutdown with an optional process exit code
do -- lurek.event.exit
  local fatal = false
  if fatal then
    lurek.event.exit(1)
  else
    lurek.event.exit(0)
  end
end

--@api-stub: lurek.event.poll -- Creates a polling function that returns the next queued event each time it is called
do -- lurek.event.poll
  function lurek.process(dt)
    for name, a, b in lurek.event.poll() do
      if name == "keypressed" and a == "escape" then
        lurek.event.quit()
      end
    end
  end
end

--@api-stub: lurek.event.clear -- Clears all pending events from the shared event queue
do -- lurek.event.clear
  local function load_level(name)
    lurek.event.clear()
    lurek.log.info("loaded " .. name .. "; input queue flushed", "scene")
  end
  load_level("forest_01")
end

--@api-stub: lurek.event.newSignal -- Creates an isolated signal dispatcher for Lua callbacks
do -- lurek.event.newSignal
  local combat = lurek.event.newSignal()
  combat:register("damage", function(target, amount)
    lurek.log.info(target .. " took " .. amount .. " hp", "combat")
  end)
  combat:emit("damage", "goblin", 12)
end

--@api-stub: lurek.event.pump -- Pumps the shared event queue without removing events for Lua
do -- lurek.event.pump
  function lurek.process(dt)
    lurek.event.pump()
    for name in lurek.event.poll() do
      lurek.log.debug("event: " .. name, "input")
    end
  end
end

--@api-stub: lurek.event.wait -- Waits for the next queued event and returns success, name, and argument table
do -- lurek.event.wait
  local ok, name, args = lurek.event.wait(0.5)
  if ok then
    lurek.log.info("got event '" .. name .. "' within timeout", "tool")
  else
    lurek.log.info("wait timed out, continuing idle", "tool")
  end
end

--@api-stub: lurek.event.restart -- Requests an engine restart
do -- lurek.event.restart
  local function apply_graphics_preset(preset)
    lurek.log.info("applied preset '" .. preset .. "', restarting", "boot")
    lurek.event.restart()
  end
  apply_graphics_preset("high")
end

--@api-stub: lurek.event.quit -- Requests engine shutdown with exit code zero
do -- lurek.event.quit
  local function on_quit_button()
    lurek.log.info("user requested quit", "ui")
    lurek.event.quit()
  end
  on_quit_button()
end

--@api-stub: lurek.event.pushDeferred -- Adds a normal-priority event to the deferred buffer instead of the live queue
do -- lurek.event.pushDeferred
  for i = 1, 3 do
    lurek.event.pushDeferred("spawn", "enemy", i * 64, 0)
  end
  lurek.event.flushDeferred()
end

--@api-stub: lurek.event.pushDeferredPriority -- Adds an event with explicit priority to the deferred buffer
do -- lurek.event.pushDeferredPriority
  lurek.event.pushDeferredPriority("ui.toast", "normal", "hello")
  lurek.event.pushDeferredPriority("shutdown", "high")
  lurek.event.flushDeferred()
end

--@api-stub: lurek.event.flushDeferred -- Moves all deferred events into the shared event queue and clears the deferred buffer
do -- lurek.event.flushDeferred
  lurek.event.pushDeferred("save", "slot1")
  lurek.event.pushDeferred("save", "slot2")
  local moved = lurek.event.flushDeferred()
  lurek.log.info("flushed " .. moved .. " deferred events", "event")
end

--@api-stub: lurek.event.enableHistory -- Enables event push history with a maximum retained capacity
do -- lurek.event.enableHistory
  lurek.event.enableHistory(64)
  lurek.event.push("checkpoint", "boss_arena")
  lurek.event.push("achievement", "first_blood")
end

--@api-stub: lurek.event.getHistory -- Returns retained pushed event history entries
do -- lurek.event.getHistory
  lurek.event.enableHistory(32)
  lurek.event.push("damage", "player", 5)
  for _, entry in ipairs(lurek.event.getHistory()) do
    lurek.log.debug("hist: " .. entry.name .. " #args=" .. #entry.args, "event")
  end
end

--@api-stub: lurek.event.clearHistory -- Clears retained pushed event history
do -- lurek.event.clearHistory
  lurek.event.enableHistory(16)
  lurek.event.push("temp_event")
  lurek.event.clearHistory()
  lurek.log.info("history cleared, entries=" .. #lurek.event.getHistory(), "event")
end

--@api-stub: lurek.event.push -- Pushes a normal-priority event into the shared event queue and optional history
do -- lurek.event.push
  lurek.event.push("damage", "player", 12)
  for name, target, amount in lurek.event.poll() do
    if name == "damage" then
      lurek.log.info(target .. " took " .. tostring(amount), "combat")
    end
  end
end

--@api-stub: lurek.event.pushPriority -- Pushes an event with explicit priority into the shared event queue and optional history
do -- lurek.event.pushPriority
  lurek.event.push("normal_notice", "late")
  lurek.event.pushPriority("urgent_notice", "high", {source="system"})
  for name, payload in lurek.event.poll() do
    lurek.log.info("event " .. name, "event")
  end
end

-- -- Signal methods --

--@api-stub: Signal:emit
do -- Signal:emit
  local sig = lurek.event.newSignal()
  sig:register("level_up", function(actor, new_level)
    lurek.log.info(actor .. " reached level " .. new_level, "rpg")
  end)
  sig:emit("level_up", "hero", 7)
end

--@api-stub: Signal:remove
do -- Signal:remove
  local sig = lurek.event.newSignal()
  local handle = sig:register("tick", function() end)
  local removed = sig:remove(handle)
  lurek.log.info("unsubscribed handle=" .. handle .. " ok=" .. tostring(removed), "event")
end

--@api-stub: Signal:clear
do -- Signal:clear
  local sig = lurek.event.newSignal()
  sig:register("damage", function() end)
  sig:register("damage", function() end)
  local n = sig:clear("damage")
  lurek.log.info("dropped " .. n .. " damage listeners", "event")
end

--@api-stub: Signal:clearAll
do -- Signal:clearAll
  local sig = lurek.event.newSignal()
  sig:register("a", function() end)
  sig:register("b", function() end)
  local total = sig:clearAll()
  lurek.log.info("dispatcher reset, removed=" .. total, "event")
end

--@api-stub: Signal:getCount
do -- Signal:getCount
  local sig = lurek.event.newSignal()
  sig:register("frame", function() end)
  if sig:getCount("frame") > 0 then
    sig:emit("frame", 0.016)
  end
end

--@api-stub: Signal:getTotalCount
do -- Signal:getTotalCount
  local sig = lurek.event.newSignal()
  sig:register("a", function() end)
  sig:register("b", function() end)
  lurek.log.debug("signal listener count=" .. sig:getTotalCount(), "diag")
end

--@api-stub: Signal:type
do -- Signal:type
  local sig = lurek.event.newSignal()
  local kind = sig:type()
  lurek.log.info("created object of type=" .. kind, "diag")
end

--@api-stub: Signal:typeOf
do -- Signal:typeOf
  local sig = lurek.event.newSignal()
  if sig:typeOf("Signal") and sig:typeOf("Object") then
    lurek.log.info("dispatcher passes Signal+Object guard", "diag")
  end
end

--@api-stub: Signal:connect
do -- Signal:connect
  local sig = lurek.event.newSignal()
  local id = sig:connect("*", function(data)
    lurek.log.info("received: " .. tostring(data), "event")
  end)
  sig:emit("hello")
  lurek.log.info("listener id: " .. id, "event")
end

--@api-stub: Signal:once
do -- Signal:once
  local sig = lurek.event.newSignal()
  sig:once("*", function(val)
    lurek.log.info("once fired: " .. tostring(val), "event")
  end)
  sig:emit("*", 42)
  sig:emit("*", 99)
  lurek.log.info("count after once: " .. sig:getCount("*"), "event")
end

--@api-stub: Signal:register
do -- Signal:register
  local sig = lurek.event.newSignal()
  local id = sig:register("*", function(payload)
    lurek.log.info("payload: " .. tostring(payload), "event")
  end)
  sig:emit("damage")
  lurek.log.info("registered id: " .. id, "event")
end

--@api-stub: Signal:registerWithFilter
do -- Signal:registerWithFilter
  local sig = lurek.event.newSignal()
  sig:registerWithFilter(
    "combat.event",
    function(evt) lurek.log.info("damage event", "event") end,
    function(evt) return evt.type == "damage" end
  )
  sig:emit("combat.event", {type="damage", amount=10})
  sig:emit("combat.event", {type="heal", amount=5})
  lurek.log.info("filtered listener ok", "event")
end

