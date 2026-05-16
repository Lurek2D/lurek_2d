-- content/examples/patterns.lua
-- lurek.patterns API examples: data structures, design patterns, and game architecture utilities.
-- Run: cargo run -- content/examples/patterns.lua

--@api-stub: lurek.patterns.newEventBus
-- Create a new publish/subscribe event bus for decoupled communication between game systems
do
  -- EventBus decouples producers from consumers. Systems publish events without
  -- knowing who listens. Ideal for game-wide signals: damage dealt, level cleared,
  -- item picked up. Priority controls execution order of multiple subscribers.
  local bus = lurek.patterns.newEventBus("combat_bus")

  -- Subscribe to "hp_changed" so the HUD updates whenever any system modifies HP.
  -- Priority 100 means this runs before lower-priority listeners on the same event.
  local hud_id = bus:on("hp_changed", function(hp, max_hp)
    print("HUD: health bar " .. hp .. "/" .. max_hp)
  end, 100)

  -- A second listener with lower priority logs to analytics after HUD updates.
  bus:on("hp_changed", function(hp)
    if hp <= 0 then print("Analytics: player died") end
  end, 0)

  -- Any system can emit without knowing about listeners.
  bus:emit("hp_changed", 42, 100)

  -- Unsubscribe the HUD listener when leaving the game screen.
  bus:off(hud_id)
end

--@api-stub: lurek.patterns.newObjectPool
-- Create a new object pool for reusing pre-allocated game objects to reduce allocation overhead
do
  -- Object pools eliminate per-frame allocations for frequently spawned entities
  -- like bullets, particles, or hit effects. Pre-warm the pool at load time,
  -- then acquire/release during gameplay for zero-allocation spawning.
  local pool = lurek.patterns.newObjectPool()

  -- Pre-warm: add 32 bullet templates at scene load (not during gameplay).
  for i = 1, 32 do
    pool:add({ x = 0, y = 0, vx = 0, vy = 0, alive = false })
  end

  -- During gameplay: acquire reuses an existing bullet instead of allocating.
  local bullet = pool:acquire()
  if bullet then
    bullet.x, bullet.y = 100, 200
    bullet.vx, bullet.vy = 300, 0
    bullet.alive = true
  end

  print("active=" .. pool:getActiveCount() .. " idle=" .. pool:getAvailableCount())
end

--@api-stub: lurek.patterns.newCommandStack
-- Create a new undo/redo command stack for recording and reversing player or editor actions
do
  -- CommandStack records forward and backward operations for undo/redo support.
  -- Essential for level editors, turn-based games, or any user action that should
  -- be reversible. maxSize=64 limits memory to the last 64 actions.
  local stack = lurek.patterns.newCommandStack(64)

  -- Simulate a tile painter in a level editor.
  local tile_x, tile_y, tile_type = 5, 3, "wall"
  local prev_type = "floor"

  -- execute() runs the forward action immediately and stores the undo.
  stack:execute("paint_tile",
    function() tile_type = "wall" end,   -- forward: paint the tile
    function() tile_type = prev_type end -- backward: restore original
  )
  print("after paint: " .. tile_type)

  -- Player hits Ctrl+Z.
  stack:undo()
  print("after undo: " .. tile_type)

  -- Player hits Ctrl+Y.
  stack:redo()
  print("after redo: " .. tile_type)
end

--@api-stub: lurek.patterns.newServiceLocator
-- Create a new service locator for registering and retrieving shared services by name at runtime
do
  -- ServiceLocator provides runtime dependency injection without globals.
  -- Register services once at startup, then any system can locate them by name.
  -- Useful for swapping implementations (e.g. real audio vs silent audio in tests).
  local services = lurek.patterns.newServiceLocator()

  -- Register core services at game boot.
  services:provide("logger", {
    info = function(msg) print("[INFO] " .. msg) end,
    warn = function(msg) print("[WARN] " .. msg) end,
  })
  services:provide("save_system", { slot = "slot1", path = "save/" })

  -- Any game system can locate what it needs without hard coupling.
  local log = services:locate("logger")
  if log then log.info("all services online") end

  -- Check before use to handle optional services gracefully.
  if services:has("analytics") then
    services:locate("analytics").track("session_start")
  end
end

--@api-stub: lurek.patterns.newFactory
-- Create a new factory for producing typed game objects from registered constructor functions
do
  -- Factory pattern centralizes object creation. Register constructors once,
  -- then spawn by type name from data files, spawn tables, or level scripts.
  -- Keeps spawning logic in one place and easy to extend.
  local enemies = lurek.patterns.newFactory()

  -- Register enemy constructors with position and optional stats.
  enemies:register("goblin", function(x, y)
    return { kind = "goblin", x = x, y = y, hp = 20, speed = 80 }
  end)
  enemies:register("skeleton", function(x, y)
    return { kind = "skeleton", x = x, y = y, hp = 40, speed = 50 }
  end)

  -- Spawn enemies from level data without switch/if chains.
  local spawn_list = { {"goblin", 64, 32}, {"skeleton", 128, 64} }
  for _, info in ipairs(spawn_list) do
    local e = enemies:create(info[1], info[2], info[3])
    if e then print("spawned " .. e.kind .. " at " .. e.x .. "," .. e.y) end
  end
end

--@api-stub: lurek.patterns.newSimpleState
-- Create a new finite state machine with enter/exit/update callbacks per state
do
  -- Finite state machines organize game entity behavior into discrete states.
  -- Each state can have enter (setup), exit (cleanup), and update (per-frame) callbacks.
  -- Transitions automatically call exit on the old state and enter on the new one.
  local sm = lurek.patterns.newSimpleState()

  sm:addState("idle", {
    enter = function() print("  > idle: playing idle animation") end,
    exit  = function() print("  < idle: stopping idle animation") end,
  })
  sm:addState("patrol", {
    enter  = function() print("  > patrol: picking waypoint") end,
    update = function(dt) print("  . patrol: walking dt=" .. string.format("%.3f", dt)) end,
    exit   = function() print("  < patrol: reached waypoint") end,
  })
  sm:addState("chase", {
    enter  = function() print("  > chase: spotted player!") end,
    update = function(dt) print("  . chase: closing in") end,
  })

  -- Start in idle, then transition based on game events.
  sm:transitionTo("idle")
  sm:transitionTo("patrol")
  sm:update(0.016)
end

--@api-stub: lurek.patterns.newBlackboard
-- Create a new shared key-value blackboard supporting reactive watchers for game logic variables
do
  -- Blackboard is a shared data store for AI and game systems. Multiple systems
  -- can read/write values, and watchers react to changes automatically.
  -- Common use: AI reads "player_visible" set by the perception system.
  local bb = lurek.patterns.newBlackboard("ai_world")

  -- Perception system writes what it detects.
  bb:set("player_hp", 100)
  bb:set("player_visible", true)
  bb:set("alarm_active", false)

  -- AI reads the blackboard to make decisions.
  if bb:get("player_visible") and bb:get("player_hp") < 25 then
    bb:set("alarm_active", true)
  end
  print("alarm=" .. tostring(bb:get("alarm_active")))
end

--@api-stub: lurek.patterns.newObserver
-- Create a new reactive observer that stores values and notifies subscribers when they change
do
  -- Observer stores key-value pairs and fires callbacks when values change.
  -- Perfect for binding game state to UI: when score changes, the HUD auto-updates
  -- without polling. Lighter than EventBus when you just need value-change reactivity.
  local obs = lurek.patterns.newObserver("hud_bindings")

  -- The HUD subscribes to score changes and auto-refreshes its display.
  obs:subscribe("score", function(key, new_value)
    print("HUD: " .. key .. " is now " .. new_value)
  end)

  -- Game logic sets values; HUD reacts without being called directly.
  obs:set("score", 0)
  obs:set("score", 100)  -- triggers subscriber
  obs:set("score", 250)  -- triggers subscriber again
end

--@api-stub: lurek.patterns.newThrottle
-- Create a new throttle that limits how often an action can fire, enforcing a minimum interval
do
  -- Throttle enforces a cooldown between executions. Use for weapon fire rates,
  -- autosave intervals, network packet sending, or any action that should not
  -- happen more than once per N seconds regardless of how often it's triggered.
  local weapon_fire = lurek.patterns.newThrottle(0.25)  -- 4 shots per second max

  weapon_fire:onFire(function()
    print("BANG! bullet spawned")
  end)

  -- Even if the player holds the fire button every frame, shots are rate-limited.
  -- In a real game, call this in lurek.process(dt).
  weapon_fire:update(0.016)  -- not enough time passed, no fire
  weapon_fire:update(0.25)   -- interval elapsed, fires!
  print("shots fired=" .. weapon_fire:getFireCount())
end

--@api-stub: lurek.patterns.newDebounce
-- Create a new debounce that delays firing until input stops for a specified wait period
do
  -- Debounce waits for a pause in activity before firing. Unlike throttle (which fires
  -- at intervals), debounce fires ONCE after the user stops triggering for `wait` seconds.
  -- Ideal for: autosave after edits stop, search-as-you-type, resize handling.
  local autosave = lurek.patterns.newDebounce(0.5)  -- save 0.5s after last edit

  autosave:onFire(function()
    print("autosave: writing to disk")
  end)

  -- Each trigger resets the timer. Only fires when edits pause for 0.5s.
  autosave:trigger()  -- user typed
  autosave:trigger()  -- user typed again, timer resets
  -- After 0.5s of no triggers, the callback fires.
  print("pending=" .. tostring(autosave:isPending()))
end

--@api-stub: lurek.patterns.newPriorityQueue
-- Create a new priority queue that orders elements by numeric priority (highest first)
do
  -- PriorityQueue always dequeues the highest-priority item first. Use for AI task
  -- scheduling, event processing order, job systems, or any situation where items
  -- have different urgency levels.
  local ai_tasks = lurek.patterns.newPriorityQueue("ai_scheduler")

  -- Higher priority number = processed first.
  ai_tasks:push(10, { kind = "patrol", waypoint = 3 }, "low")
  ai_tasks:push(50, { kind = "attack", target = "player" }, "urgent")
  ai_tasks:push(30, { kind = "investigate", pos_x = 100 }, "medium")

  -- The AI processes the most important task first.
  local task = ai_tasks:pop()
  if task then print("executing: " .. task.kind) end  -- "attack"
end

--@api-stub: lurek.patterns.newRing
-- Create a new fixed-size ring buffer for numeric or string values
do
  -- Ring buffer stores the last N values, overwriting the oldest when full.
  -- Perfect for FPS counters, rolling averages, recent chat messages, or any
  -- sliding-window metric. Fixed memory regardless of how long the game runs.
  local fps_log = lurek.patterns.newRing(60, "fps_tracker")

  -- Simulate 65 frames of FPS data. Only the last 60 are kept.
  for i = 1, 65 do
    fps_log:push(58 + (i % 4), "frame")
  end

  -- average() gives the rolling average over the buffer window.
  print("avg fps=" .. string.format("%.1f", fps_log:average())
    .. " samples=" .. fps_log:len())
end

--@api-stub: lurek.patterns.newFunnel
-- Create a new batching funnel that collects events over a time window and flushes them together
do
  -- Funnel batches many small events into periodic bulk flushes. Use for analytics,
  -- network batching, or any case where you want to aggregate events over a time
  -- window instead of processing them one by one.
  local analytics = lurek.patterns.newFunnel(2.0, 32, "game_events")

  analytics:onFlush(function(batch)
    -- In production, this would send the batch to a server.
    print("flushing " .. #batch .. " analytics events")
  end)

  -- Individual events accumulate silently.
  analytics:push("level_start", 1)
  analytics:push("enemy_killed", 5)
  analytics:push("item_collected", 1)
  -- After 2 seconds or 32 events, onFlush fires with the full batch.
  print("buffered=" .. analytics:pendingCount())
end

--@api-stub: lurek.patterns.newRelationshipManager
-- Create a new relationship manager for tracking numeric values and named levels between entity pairs
do
  -- RelationshipManager tracks pairwise relationships between entities. Stores both
  -- a numeric value (reputation score) and named levels (hostile/neutral/ally).
  -- Ideal for faction systems, NPC disposition, diplomacy in strategy games.
  local rel = lurek.patterns.newRelationshipManager()

  -- Define relationship types with ordered levels.
  rel:defineType("diplomacy", { "hostile", "neutral", "friendly", "ally" }, "neutral")

  -- Set numeric affinity between two faction IDs.
  local player_id, merchant_id = 101, 202
  rel:setValue(player_id, merchant_id, 50)

  -- Set the named level based on game events.
  rel:setLevel(player_id, merchant_id, "diplomacy", "friendly")

  -- Query relationships for gameplay decisions.
  local level = rel:getLevel(player_id, merchant_id, "diplomacy")
  local value = rel:getValue(player_id, merchant_id)
  print("merchant is " .. level .. " (score=" .. value .. ")")
end

--@api-stub: lurek.patterns.newMediator
-- Create a new mediator for channel-based message passing between decoupled game systems
do
  -- Mediator provides named channels for message passing. Unlike EventBus (which uses
  -- event names), Mediator is designed for system-to-system communication where you
  -- want explicit channel control. Supports broadcast to all channels at once.
  local hub = lurek.patterns.newMediator()

  -- Systems register on their channels.
  hub:on("chat", function(user, msg)
    print("[chat] " .. user .. ": " .. msg)
  end)
  hub:on("combat_log", function(attacker, target, dmg)
    print("[combat] " .. attacker .. " hit " .. target .. " for " .. dmg)
  end)

  -- Any system sends messages to the appropriate channel.
  hub:send("chat", "alice", "gg")
  hub:send("combat_log", "warrior", "dragon", 150)
end

--@api-stub: lurek.patterns.newStrategy
-- Create a new strategy pattern container for hot-swappable algorithm implementations
do
  -- Strategy pattern lets you swap algorithms at runtime without conditionals.
  -- Register multiple implementations, then switch between them based on game state.
  -- Example: different damage formulas for normal vs critical vs magical attacks.
  local damage_calc = lurek.patterns.newStrategy()

  damage_calc:register("normal", function(atk, def)
    return math.max(1, atk - def)
  end)
  damage_calc:register("critical", function(atk, def)
    return math.max(1, atk * 2 - def)
  end)
  damage_calc:register("magical", function(atk, def)
    -- Magic ignores half of defense.
    return math.max(1, atk - math.floor(def / 2))
  end)

  -- Switch strategy based on combat conditions.
  damage_calc:set("critical")
  local dmg = damage_calc:execute(20, 5)
  print("critical hit dmg=" .. dmg)
end

--@api-stub: lurek.patterns.newStack
-- Create a new LIFO stack with optional capacity limit
do
  -- Stack is last-in first-out. Use for navigation history (back button), undo stacks,
  -- scene layering (push dialog on top of game), or bracket matching.
  -- Capacity 8 prevents unbounded growth from bugs.
  local scene_stack = lurek.patterns.newStack(8)

  -- Push scenes as the player navigates deeper.
  scene_stack:push("main_menu")
  scene_stack:push("world_map")
  scene_stack:push("inventory")

  -- Peek shows current scene without modifying the stack.
  print("current=" .. scene_stack:peek() .. " depth=" .. scene_stack:len())

  -- Pop returns to the previous scene (like pressing Back).
  scene_stack:pop()
  print("back to=" .. scene_stack:peek())
end

--@api-stub: lurek.patterns.newQueue
-- Create a new FIFO queue with optional capacity limit
do
  -- Queue is first-in first-out. Use for message queues, turn order, AI command
  -- queues, or any pipeline where items are processed in arrival order.
  -- Capacity 0 means unlimited.
  local mail = lurek.patterns.newQueue(0)

  -- Messages arrive from different systems.
  mail:enqueue("quest_accepted")
  mail:enqueue("item_received")
  mail:enqueue("achievement_unlocked")

  -- Process in order: first message sent is first message handled.
  print("next=" .. mail:front() .. " total=" .. mail:len())
end

--@api-stub: lurek.patterns.newList
-- Create a new dynamic array list with indexed access, insertion, removal, and search
do
  -- List is a dynamic array with 1-based indexing. Use for inventory slots, quest logs,
  -- ordered collections where you need random access by index. Grows as needed.
  local quest_log = lurek.patterns.newList()

  quest_log:add("Find the lost sword")
  quest_log:add("Defeat the dragon")
  quest_log:add("Return to the village")

  -- Update a quest description.
  quest_log:set(1, "Find the enchanted sword")
  print("active quest: " .. quest_log:get(1))
  print("total quests: " .. quest_log:len())
end

--@api-stub: lurek.patterns.newSet
-- Create a new string set with add/remove/has operations and set algebra (union, intersection)
do
  -- Set stores unique strings with O(1) lookup. Use for tracking collected items,
  -- visited rooms, unlocked achievements, or active status effects.
  -- Supports union/intersection for comparing player inventories or requirements.
  local unlocked = lurek.patterns.newSet()

  unlocked:add("level_1")
  unlocked:add("level_2")
  unlocked:add("boss_key")

  -- Fast membership check for game logic.
  if unlocked:has("boss_key") then
    print("boss door: access granted")
  end
  print("unlocked " .. unlocked:len() .. " items")
end

--@api-stub: EventBus:on
-- Subscribe a callback to a named event with optional priority ordering
do
  local bus = lurek.patterns.newEventBus("game")

  -- Priority 100 ensures this listener fires before default-priority (0) listeners.
  -- Returns a numeric ID for later unsubscription.
  local id = bus:on("level_clear", function(level_name)
    print("  level cleared: " .. level_name)
  end, 100)

  bus:emit("level_clear", "forest_01")
  bus:off(id)
end

--@api-stub: EventBus:off
-- Unsubscribe a listener by its subscription ID
do
  local bus = lurek.patterns.newEventBus()
  local id = bus:on("ping", function() print("pong") end)

  -- Unsubscribe when the listener's owner is destroyed or no longer relevant.
  bus:off(id)
  bus:emit("ping")  -- no output: listener was removed
  print("listeners=" .. bus:getListenerCount("ping"))
end

--@api-stub: EventBus:emit
-- Emit an event, invoking all listeners in priority order with payload arguments
do
  local bus = lurek.patterns.newEventBus()

  -- Listeners receive all arguments passed after the event name.
  bus:on("damage", function(amount, source)
    print("  " .. source .. " dealt " .. amount .. " damage")
  end)

  -- Multiple emits, each with different payloads.
  bus:emit("damage", 12, "goblin")
  bus:emit("damage", 30, "boss")
end

--@api-stub: EventBus:clear
-- Remove all listeners for a specific event name
do
  local bus = lurek.patterns.newEventBus()
  bus:on("minigame_end", function(score) print("  score: " .. score) end)
  bus:on("minigame_end", function(score) print("  hud update: " .. score) end)

  -- When the minigame scene unloads, clear all its listeners at once.
  bus:clear("minigame_end")
  print("after clear: " .. bus:getListenerCount("minigame_end") .. " listeners")
end

--@api-stub: EventBus:clearAll
-- Remove all listeners from every event on this bus
do
  local bus = lurek.patterns.newEventBus()
  bus:on("save", function() end)
  bus:on("load", function() end)

  -- Full reset when transitioning between major game states.
  bus:clearAll()
  print("events remaining=" .. #bus:getEvents())
end

--@api-stub: EventBus:getListenerCount
-- Return the number of active listeners for a given event
do
  local bus = lurek.patterns.newEventBus()
  bus:on("hit", function() end)
  bus:on("hit", function() end)

  -- Use to detect listener leaks during development.
  local n = bus:getListenerCount("hit")
  if n > 10 then print("WARNING: " .. n .. " hit listeners, possible leak") end
  print("hit listeners=" .. n)
end

--@api-stub: EventBus:getEvents
-- Return an array of all event names that have at least one listener
do
  local bus = lurek.patterns.newEventBus()
  bus:on("save", function() end)
  bus:on("quit", function() end)

  -- Useful for debug overlays showing active event channels.
  for _, name in ipairs(bus:getEvents()) do
    print("  active channel: " .. name)
  end
end

--@api-stub: ObjectPool:add
-- Add an object to the pool's idle set for future acquisition
do
  local bullets = lurek.patterns.newObjectPool()

  -- Pre-warm at load time: create all objects up front to avoid runtime allocation.
  for i = 1, 32 do
    bullets:add({ x = 0, y = 0, alive = false, sprite_id = i })
  end
  print("pool pre-warmed: " .. bullets:getAvailableCount() .. " bullets ready")
end

--@api-stub: ObjectPool:acquire
-- Take an idle object from the pool and mark it active
do
  local pool = lurek.patterns.newObjectPool()
  pool:add({ x = 0, y = 0, vx = 0, vy = 0 })

  -- acquire() returns nil if the pool is exhausted, so always check.
  local b = pool:acquire()
  if b then
    -- Reset the object for its new life. The pool reuses memory.
    b.x, b.y = 50, 50
    b.vx = 200
  end
  print("active=" .. pool:getActiveCount())
end

--@api-stub: ObjectPool:release
-- Return an active object back to the pool's idle set for reuse
do
  local pool = lurek.patterns.newObjectPool()
  pool:add({ alive = false })

  local obj = pool:acquire()
  obj.alive = true

  -- When the bullet leaves the screen or hits something, release it back.
  obj.alive = false
  pool:release(obj)
  print("returned to pool, idle=" .. pool:getAvailableCount())
end

--@api-stub: ObjectPool:getActiveCount
-- Return how many objects are currently checked out from the pool
do
  local pool = lurek.patterns.newObjectPool()
  pool:add({}); pool:add({})
  pool:acquire(); pool:acquire()

  -- Monitor for pool leaks: if active count grows unbounded, something is not releasing.
  local n = pool:getActiveCount()
  if n > 100 then print("WARN: pool leak detected, active=" .. n) end
  print("active=" .. n)
end

--@api-stub: ObjectPool:getAvailableCount
-- Return how many idle objects are ready for acquisition
do
  local pool = lurek.patterns.newObjectPool()
  for i = 1, 4 do pool:add({}) end
  pool:acquire()

  -- Dynamically grow the pool if it's running low.
  if pool:getAvailableCount() < 2 then
    pool:add({})  -- add more capacity under pressure
  end
  print("idle=" .. pool:getAvailableCount())
end

--@api-stub: ObjectPool:getTotalCount
-- Return the total number of objects managed (active + idle)
do
  local pool = lurek.patterns.newObjectPool()
  for i = 1, 16 do pool:add({}) end
  pool:acquire()

  -- Total = active + available. Useful for memory budget monitoring.
  print("total=" .. pool:getTotalCount() .. " active=" .. pool:getActiveCount())
end

--@api-stub: ObjectPool:clearAll
-- Destroy all objects (active and idle) and reset the pool to empty
do
  local pool = lurek.patterns.newObjectPool()
  pool:add({}); pool:add({})

  -- Use when changing levels or scenes to free all pooled resources.
  pool:clearAll()
  print("after clearAll: total=" .. pool:getTotalCount())
end

--@api-stub: CommandStack:execute
-- Execute a named command, recording it in history for undo/redo
do
  local stack = lurek.patterns.newCommandStack(0)
  local doc = { text = "hello" }

  -- Store state before the edit so undo can restore it.
  local prev_text = doc.text
  stack:execute("append_excl",
    function() doc.text = doc.text .. "!" end,  -- forward
    function() doc.text = prev_text end         -- undo restores previous
  )
  print("doc=" .. doc.text)
end

--@api-stub: CommandStack:undo
-- Undo the most recent command by calling its undo function
do
  local stack = lurek.patterns.newCommandStack(0)
  local x = 5

  stack:execute("increment", function() x = x + 1 end, function() x = x - 1 end)
  local ok = stack:undo()
  print("undone=" .. tostring(ok) .. " x=" .. x)  -- x is back to 5
end

--@api-stub: CommandStack:redo
-- Redo a previously undone command by re-calling its execute function
do
  local stack = lurek.patterns.newCommandStack(0)
  local n = 0

  stack:execute("step", function() n = n + 1 end, function() n = n - 1 end)
  stack:undo()   -- n=0
  stack:redo()   -- n=1 again
  print("after redo n=" .. n)
end

--@api-stub: CommandStack:canUndo
-- Check whether an undo operation is possible
do
  local stack = lurek.patterns.newCommandStack(0)
  stack:execute("action", function() end, function() end)

  -- Use to enable/disable the undo button in UI.
  if stack:canUndo() then print("undo button: enabled") end
end

--@api-stub: CommandStack:canRedo
-- Check whether a redo operation is possible
do
  local stack = lurek.patterns.newCommandStack(0)
  stack:execute("action", function() end, function() end)
  stack:undo()

  -- Use to enable/disable the redo button in UI.
  if stack:canRedo() then print("redo button: enabled") end
end

--@api-stub: CommandStack:getHistorySize
-- Return the total number of commands in history
do
  local stack = lurek.patterns.newCommandStack(0)
  for i = 1, 5 do
    stack:execute("op_" .. i, function() end, function() end)
  end
  print("history depth=" .. stack:getHistorySize())
end

--@api-stub: CommandStack:getCurrentName
-- Return the name of the most recently executed command
do
  local stack = lurek.patterns.newCommandStack(0)
  stack:execute("paint_red", function() end, function() end)

  -- Show in UI: "Undo: paint_red"
  local name = stack:getCurrentName()
  if name then print("undo will revert: " .. name) end
end

--@api-stub: CommandStack:clearAll
-- Discard all command history and free callbacks
do
  local stack = lurek.patterns.newCommandStack(0)
  stack:execute("a", function() end, function() end)

  -- Clear when starting a new document or level.
  stack:clearAll()
  print("history after clear=" .. stack:getHistorySize())
end

--@api-stub: ServiceLocator:provide
-- Register a service instance under a given name
do
  local sl = lurek.patterns.newServiceLocator()

  -- Register services at startup. Each has a unique name.
  sl:provide("clock", { now = function() return 42.0 end })
  sl:provide("save_manager", { path = "save/slot1.dat" })
  print("registered services=" .. #sl:getServices())
end

--@api-stub: ServiceLocator:locate
-- Retrieve a registered service by name (returns nil if not found)
do
  local sl = lurek.patterns.newServiceLocator()
  sl:provide("audio", { volume = 0.8, muted = false })

  -- locate() returns the exact table/value that was provided.
  local audio = sl:locate("audio")
  if audio then print("volume=" .. audio.volume) end
end

--@api-stub: ServiceLocator:has
-- Check whether a service with the given name is registered
do
  local sl = lurek.patterns.newServiceLocator()
  sl:provide("analytics", { enabled = true })

  -- Guard optional services before use.
  if sl:has("analytics") then print("telemetry active") end
end

--@api-stub: ServiceLocator:remove
-- Unregister and discard a service by name
do
  local sl = lurek.patterns.newServiceLocator()
  sl:provide("network", { online = true })

  -- Remove when going offline or shutting down a subsystem.
  sl:remove("network")
  print("network registered=" .. tostring(sl:has("network")))
end

--@api-stub: ServiceLocator:getServices
-- Return an array of all registered service names
do
  local sl = lurek.patterns.newServiceLocator()
  sl:provide("renderer", {}); sl:provide("physics", {})

  -- Debug overlay: list all active services.
  for _, name in ipairs(sl:getServices()) do print("  service: " .. name) end
end

--@api-stub: ServiceLocator:clearAll
-- Remove all registered services and reset the locator
do
  local sl = lurek.patterns.newServiceLocator()
  sl:provide("x", 1); sl:provide("y", 2)

  -- Full reset between game sessions.
  sl:clearAll()
  print("services after clear=" .. #sl:getServices())
end

--@api-stub: Factory:register
-- Register a constructor function for a given type name
do
  local f = lurek.patterns.newFactory()

  -- Each type gets a constructor that returns a fresh instance.
  f:register("orc", function(x, y) return { kind = "orc", hp = 30, x = x, y = y } end)
  f:register("troll", function(x, y) return { kind = "troll", hp = 80, x = x, y = y } end)
  print("registered types=" .. #f:getTypes())
end

--@api-stub: Factory:create
-- Create a new object by type name, forwarding arguments to the constructor
do
  local f = lurek.patterns.newFactory()
  f:register("coin", function(value) return { kind = "coin", value = value } end)

  -- Arguments after type name are forwarded to the constructor.
  local c = f:create("coin", 50)
  if c then print("dropped " .. c.value .. " gold") end
end

--@api-stub: Factory:has
-- Check whether a constructor is registered for the given type
do
  local f = lurek.patterns.newFactory()
  f:register("npc", function() return { kind = "npc" } end)

  -- Guard before create() to avoid silent nil returns.
  if f:has("npc") then print("npc factory ready") end
end

--@api-stub: Factory:alias
-- Create an alias that maps to an existing type name
do
  local f = lurek.patterns.newFactory()
  f:register("goblin", function() return { kind = "goblin" } end)

  -- Alias lets old level data reference new type names without migration.
  f:alias("monster_v1", "goblin")
  local m = f:create("monster_v1")
  if m then print("created via alias: " .. m.kind) end
end

--@api-stub: Factory:getTypes
-- Return an array of all registered type names
do
  local f = lurek.patterns.newFactory()
  f:register("warrior", function() end); f:register("mage", function() end)

  -- Useful for editor dropdowns or spawn-menu population.
  for _, name in ipairs(f:getTypes()) do print("  type: " .. name) end
end

--@api-stub: Factory:remove
-- Unregister a type and discard its constructor
do
  local f = lurek.patterns.newFactory()
  f:register("temp_enemy", function() return {} end)

  -- Remove deprecated types to prevent accidental spawning.
  f:remove("temp_enemy")
  print("temp still registered=" .. tostring(f:has("temp_enemy")))
end

--@api-stub: Factory:clearAll
-- Remove all registered types and reset the factory
do
  local f = lurek.patterns.newFactory()
  f:register("x", function() end)

  -- Full reset when loading a new mod or level pack.
  f:clearAll()
  print("types after clear=" .. #f:getTypes())
end

--@api-stub: SimpleState:addState
-- Register a named state with optional enter, exit, and update callbacks
do
  local sm = lurek.patterns.newSimpleState()

  -- Each state can have any combination of enter/exit/update.
  sm:addState("idle", {
    enter = function() print("  > entering idle") end,
    exit  = function() print("  < leaving idle") end,
  })
  sm:addState("attack", {
    update = function(dt) print("  . attacking, dt=" .. dt) end,
  })
  print("registered states=" .. #sm:getStates())
end

--@api-stub: SimpleState:transitionTo
-- Transition to a new state, calling exit on current and enter on target
do
  local sm = lurek.patterns.newSimpleState()
  sm:addState("menu", { enter = function() print("  > menu shown") end })
  sm:addState("game", { enter = function() print("  > game started") end })

  -- Transition calls menu:exit (if defined) then game:enter.
  sm:transitionTo("menu")
  sm:transitionTo("game")
end

--@api-stub: SimpleState:update
-- Call the current state's update callback with frame delta time
do
  local sm = lurek.patterns.newSimpleState()
  sm:addState("run", {
    update = function(dt) print("  . running at dt=" .. dt) end,
  })
  sm:transitionTo("run")

  -- Call each frame with the real delta time.
  sm:update(0.016)
end

--@api-stub: SimpleState:getCurrent
-- Return the name of the currently active state
do
  local sm = lurek.patterns.newSimpleState()
  sm:addState("paused", {})
  sm:transitionTo("paused")

  -- Use for conditional logic outside the FSM.
  if sm:getCurrent() == "paused" then print("game is paused") end
end

--@api-stub: SimpleState:hasState
-- Check whether a state with the given name is registered
do
  local sm = lurek.patterns.newSimpleState()
  sm:addState("boss_fight", {})

  -- Guard transitions to prevent errors on missing states.
  if sm:hasState("boss_fight") then sm:transitionTo("boss_fight") end
end

--@api-stub: SimpleState:getStates
-- Return an array of all registered state names
do
  local sm = lurek.patterns.newSimpleState()
  sm:addState("idle", {}); sm:addState("walk", {}); sm:addState("jump", {})

  -- Debug: list all possible states.
  for _, name in ipairs(sm:getStates()) do print("  state: " .. name) end
end

--@api-stub: SimpleState:clearAll
-- Remove all states and their callbacks, resetting the state machine
do
  local sm = lurek.patterns.newSimpleState()
  sm:addState("temp", {})

  -- Reset when loading a completely new entity configuration.
  sm:clearAll()
  print("states left=" .. #sm:getStates())
end

--@api-stub: Blackboard:set
-- Store a value (bool, number, string, or nil to clear) under a key
do
  local bb = lurek.patterns.newBlackboard()

  -- Supports multiple value types. nil clears the key.
  bb:set("hp", 100)
  bb:set("name", "Aria")
  bb:set("is_hostile", true)
  print("name=" .. bb:get("name"))
end

--@api-stub: Blackboard:get
-- Retrieve a value by key (returns nil if not set)
do
  local bb = lurek.patterns.newBlackboard()
  bb:set("ammo", 12)

  -- Always handle nil for keys that might not exist yet.
  local ammo = bb:get("ammo") or 0
  if ammo <= 0 then print("reload needed!") else print("ammo=" .. ammo) end
end

--@api-stub: Blackboard:keys
-- Return an array of all keys currently stored on the blackboard
do
  local bb = lurek.patterns.newBlackboard()
  bb:set("hp", 50); bb:set("mode", "patrol")

  -- Iterate all stored data for serialization or debug display.
  for _, k in ipairs(bb:keys()) do
    print("  " .. k .. "=" .. tostring(bb:get(k)))
  end
end

--@api-stub: Blackboard:watch
-- Register a watcher callback that fires when a key changes (use "*" for all keys)
do
  local bb = lurek.patterns.newBlackboard()

  -- Watch a specific key. Callback receives (key, newValue).
  local id = bb:watch("hp", function(key, value)
    print("  " .. key .. " changed to " .. tostring(value))
  end)

  bb:set("hp", 75)  -- triggers watcher
  bb:unwatch(id)    -- stop watching
end

--@api-stub: Blackboard:unwatch
-- Remove a previously registered watcher by its ID
do
  local bb = lurek.patterns.newBlackboard()

  -- "*" watches ALL key changes on this blackboard.
  local id = bb:watch("*", function(k) print("  write to " .. k) end)
  bb:set("debug", "on")  -- triggers

  -- Remove watcher when the observing system is destroyed.
  bb:unwatch(id)
  bb:set("debug", "off")  -- no trigger
end

--@api-stub: Blackboard:getRevision
-- Return the revision counter (increments on every value change)
do
  local bb = lurek.patterns.newBlackboard()
  local last_rev = bb:getRevision()

  bb:set("k", 1)
  -- Use revision to detect if anything changed since last check (dirty flag pattern).
  if bb:getRevision() ~= last_rev then print("blackboard is dirty") end
end

--@api-stub: Blackboard:snapshot
-- Return a table copy of all key-value pairs (useful for serialization or debug)
do
  local bb = lurek.patterns.newBlackboard()
  bb:set("hp", 80); bb:set("mode", "alert")

  -- snapshot() returns a plain Lua table you can serialize or inspect.
  local snap = bb:snapshot()
  for k, v in pairs(snap) do print("  " .. k .. "=" .. tostring(v)) end
end

--@api-stub: Blackboard:clearAll
-- Remove all keys and values from the blackboard
do
  local bb = lurek.patterns.newBlackboard()
  bb:set("hp", 100)

  -- Reset between encounters or when loading a new AI context.
  bb:clearAll()
  print("keys after clear=" .. #bb:keys())
end

--@api-stub: Observer:set
-- Set a value by key and notify all subscribers watching that key
do
  local o = lurek.patterns.newObserver("player_data")

  -- Subscriber fires every time the value changes.
  o:subscribe("hp", function(key, value)
    print("  HUD: " .. key .. "=" .. value)
  end)

  o:set("hp", 100)  -- triggers subscriber
  o:set("hp", 75)   -- triggers again with new value
end

--@api-stub: Observer:get
-- Retrieve the current value for a key (returns nil if not set)
do
  local o = lurek.patterns.newObserver()
  o:set("score", 1500)

  -- Read current value without triggering any notifications.
  local s = o:get("score") or 0
  print("current score=" .. s)
end

--@api-stub: Observer:subscribe
-- Subscribe to changes on a key; callback receives (key, newValue) on each change
do
  local o = lurek.patterns.newObserver()

  -- Subscribe returns an ID for later unsubscription.
  local id = o:subscribe("lives", function(k, v)
    print("  " .. k .. " is now " .. tostring(v))
  end)

  o:set("lives", 3)
  o:set("lives", 2)
  o:unsubscribe(id)
end

--@api-stub: Observer:unsubscribe
-- Remove a subscription by its ID
do
  local o = lurek.patterns.newObserver()
  local id = o:subscribe("key", function() end)

  -- Always unsubscribe when the subscriber is destroyed to prevent leaks.
  o:unsubscribe(id)
  print("subscriptions remaining=" .. o:getCount())
end

--@api-stub: Observer:getCount
-- Return the total number of active subscriptions across all keys
do
  local o = lurek.patterns.newObserver()
  o:subscribe("a", function() end)
  o:subscribe("b", function() end)

  -- Monitor subscription count to detect leaks.
  print("active subscriptions=" .. o:getCount())
end

--@api-stub: Throttle:onFire
-- Set the callback function to invoke each time the throttle fires
do
  local t = lurek.patterns.newThrottle(0.5)

  -- onFire sets the action that executes when the interval elapses.
  t:onFire(function()
    print("  periodic tick")
  end)
  -- In a real game: function lurek.process(dt) t:update(dt) end
end

--@api-stub: Throttle:update
-- Advance the throttle timer; returns true if it fired this frame
do
  local t = lurek.patterns.newThrottle(0.25)
  t:onFire(function() print("  autosave check") end)

  -- update() returns true on the frame the throttle fires.
  -- Use the return value to trigger additional logic.
  local fired = t:update(0.30)
  if fired then print("  additional post-fire logic") end
end

--@api-stub: Throttle:reset
-- Reset the throttle timer back to zero without firing
do
  local t = lurek.patterns.newThrottle(1.0)
  t:onFire(function() end)
  t:update(0.7)  -- 70% through interval

  -- Reset when the player changes weapon or cancels an action.
  t:reset()
  print("progress after reset=" .. t:getProgress())  -- 0.0
end

--@api-stub: Throttle:getProgress
-- Return how far through the current interval (0.0 to 1.0)
do
  local t = lurek.patterns.newThrottle(2.0)
  t:onFire(function() end)
  t:update(0.5)

  -- Use progress for cooldown bar UI visualization.
  local pct = math.floor(t:getProgress() * 100)
  print("cooldown: " .. pct .. "% filled")
end

--@api-stub: Throttle:getFireCount
-- Return the total number of times this throttle has fired since creation
do
  local t = lurek.patterns.newThrottle(0.1)
  t:onFire(function() end)

  -- Simulate several intervals passing.
  for i = 1, 5 do t:update(0.1) end
  print("total fires=" .. t:getFireCount())
end

--@api-stub: Throttle:setEnabled
-- Enable or disable the throttle (disabled throttle does not accumulate time)
do
  local t = lurek.patterns.newThrottle(0.5)
  t:onFire(function() print("  fire") end)

  -- Disable during pause menu or cutscenes.
  t:setEnabled(false)
  t:update(1.0)  -- no fire because disabled
  print("fires while disabled=" .. t:getFireCount())
end

--@api-stub: Debounce:onFire
-- Set the callback to invoke when the debounce fires after the wait period
do
  local d = lurek.patterns.newDebounce(0.3)

  -- The callback fires once after 0.3s of no new triggers.
  d:onFire(function()
    print("  input settled, executing action")
  end)
  d:trigger()
  -- In a real game: function lurek.process(dt) d:update(dt) end
end

--@api-stub: Debounce:trigger
-- Signal input activity, resetting the wait timer
do
  local d = lurek.patterns.newDebounce(0.5)
  d:onFire(function() print("  autosave triggered") end)

  -- Each trigger() resets the countdown. Only fires after 0.5s of silence.
  d:trigger()  -- timer starts
  d:trigger()  -- timer resets back to 0
  print("pending=" .. tostring(d:isPending()))
end

--@api-stub: Debounce:update
-- Advance the debounce timer; returns true if it fired this frame
do
  local d = lurek.patterns.newDebounce(0.4)
  d:onFire(function() print("  typing paused, run search") end)
  d:trigger()

  -- Returns true on the frame the debounce fires.
  local fired = d:update(0.5)  -- 0.5 > 0.4 wait, so it fires
  print("fired=" .. tostring(fired))
end

--@api-stub: Debounce:cancel
-- Cancel any pending debounce without firing
do
  local d = lurek.patterns.newDebounce(1.0)
  d:onFire(function() print("  commit changes") end)
  d:trigger()

  -- Cancel if the user explicitly discards their edits.
  d:cancel()
  print("pending after cancel=" .. tostring(d:isPending()))
end

--@api-stub: Debounce:isPending
-- Check whether the debounce is waiting to fire
do
  local d = lurek.patterns.newDebounce(0.6)
  d:onFire(function() end)
  d:trigger()

  -- Use to show a "saving..." indicator in the UI.
  if d:isPending() then print("waiting for idle before save...") end
end

--@api-stub: Debounce:getFireCount
-- Return the total number of times this debounce has fired since creation
do
  local d = lurek.patterns.newDebounce(0.1)
  d:onFire(function() end)
  d:trigger()
  d:update(0.2)  -- fires

  print("total fires=" .. d:getFireCount())
end

--@api-stub: PriorityQueue:push
-- Add an item with a numeric priority (higher = dequeued sooner)
do
  local pq = lurek.patterns.newPriorityQueue("ai")

  -- Third argument is an optional label for debugging.
  pq:push(10, { kind = "patrol" }, "low_priority")
  pq:push(50, { kind = "attack" }, "urgent")
  pq:push(20, { kind = "investigate" }, "medium")
  print("queued=" .. pq:len())
end

--@api-stub: PriorityQueue:pop
-- Remove and return the highest-priority item
do
  local pq = lurek.patterns.newPriorityQueue()
  pq:push(1, "low_task"); pq:push(99, "critical_task")

  -- Always returns the highest priority item first.
  local job = pq:pop()
  if job then print("executing: " .. job) end  -- "critical_task"
end

--@api-stub: PriorityQueue:peek
-- Return the highest-priority item without removing it
do
  local pq = lurek.patterns.newPriorityQueue()
  pq:push(5, "build_wall"); pq:push(20, "render_frame")

  -- Peek to check what's next without consuming it.
  local next_job = pq:peek()
  if next_job then print("next up: " .. next_job) end
end

--@api-stub: PriorityQueue:len
-- Return the current number of items in the queue
do
  local pq = lurek.patterns.newPriorityQueue()
  pq:push(1, "a"); pq:push(2, "b"); pq:push(3, "c")

  -- Use len() to check load and shed low-priority work if overwhelmed.
  if pq:len() > 100 then print("queue saturated, shedding tasks") end
  print("queue size=" .. pq:len())
end

--@api-stub: PriorityQueue:isEmpty
-- Check whether the queue contains no items
do
  local pq = lurek.patterns.newPriorityQueue()
  pq:push(1, "process_input")

  -- Drain loop: process all tasks in priority order.
  while not pq:isEmpty() do
    print("  processing: " .. pq:pop())
  end
end

--@api-stub: PriorityQueue:clearAll
-- Remove all items from the priority queue
do
  local pq = lurek.patterns.newPriorityQueue()
  pq:push(1, "x"); pq:push(2, "y")

  -- Clear when switching AI contexts or resetting the scheduler.
  pq:clearAll()
  print("after clear: len=" .. pq:len())
end

--@api-stub: Ring:push
-- Push a value into the ring (overwrites oldest when full)
do
  local r = lurek.patterns.newRing(8)

  -- Push more than capacity: oldest values are silently dropped.
  for i = 1, 10 do r:push(i * 1.5, "latency") end
  print("len=" .. r:len() .. " full=" .. tostring(r:isFull()))
end

--@api-stub: Ring:latest
-- Return the most recently pushed entry as a table
do
  local r = lurek.patterns.newRing(4)
  r:push("player joined", "event")
  r:push("enemy spawned", "event")

  -- latest() returns {id, tag, value, text} of the newest entry.
  local last = r:latest()
  if last then print("last event: " .. last.text) end
end

--@api-stub: Ring:toArray
-- Return all entries as an ordered array (oldest to newest)
do
  local r = lurek.patterns.newRing(4)
  r:push(60, "fps"); r:push(58, "fps"); r:push(61, "fps")

  -- Iterate for debug display or graph rendering.
  for _, entry in ipairs(r:toArray()) do
    print("  " .. entry.tag .. "=" .. entry.value)
  end
end

--@api-stub: Ring:sum
-- Return the sum of all numeric values in the ring
do
  local r = lurek.patterns.newRing(16)
  for i = 1, 10 do r:push(i * 0.1, "latency") end

  -- sum() for total accumulated latency over the window.
  print("total latency=" .. string.format("%.2f", r:sum()) .. "s")
end

--@api-stub: Ring:average
-- Return the arithmetic mean of all numeric values in the ring
do
  local r = lurek.patterns.newRing(60)
  for i = 1, 60 do r:push(58 + (i % 4), "fps") end

  -- Rolling average for smooth FPS display.
  print("avg fps=" .. string.format("%.1f", r:average()))
end

--@api-stub: Ring:len
-- Return the number of entries currently in the ring
do
  local r = lurek.patterns.newRing(10)
  r:push(1, "x"); r:push(2, "x"); r:push(3, "x")

  -- Check if we have enough samples for a meaningful average.
  if r:len() >= 3 then print("enough samples for analysis") end
end

--@api-stub: Ring:isFull
-- Check whether the ring has reached its maximum capacity
do
  local r = lurek.patterns.newRing(4)
  for i = 1, 4 do r:push(i, "warmup") end

  -- Only report average once the ring is fully warmed up.
  if r:isFull() then print("warm: avg=" .. string.format("%.1f", r:average())) end
end

--@api-stub: Ring:clear
-- Remove all entries from the ring
do
  local r = lurek.patterns.newRing(8)
  r:push(10, "x"); r:push(20, "x")

  -- Clear when switching measurement contexts.
  r:clear()
  print("len after clear=" .. r:len())
end

--@api-stub: Funnel:onFlush
-- Set the callback invoked when the funnel flushes its batch
do
  local f = lurek.patterns.newFunnel(1.0, 0)

  -- Callback receives an array of {tag, value} entries.
  f:onFlush(function(batch)
    print("  flushed " .. #batch .. " events to server")
  end)
  -- In a real game: function lurek.process(dt) f:update(dt) end
end

--@api-stub: Funnel:push
-- Push a tagged event into the funnel (may trigger immediate flush if at max entries)
do
  local f = lurek.patterns.newFunnel(60.0, 4)  -- max 4 entries before forced flush
  f:onFlush(function(b) print("  batch size=" .. #b) end)

  -- When maxEntries is reached, flush fires immediately.
  f:push("kill", 1); f:push("kill", 1); f:push("kill", 1); f:push("kill", 1)
  print("pending after max-flush=" .. f:pendingCount())
end

--@api-stub: Funnel:update
-- Advance the funnel's time window; returns true if it flushed this frame
do
  local f = lurek.patterns.newFunnel(0.5, 0)
  f:onFlush(function(b) print("  auto flush " .. #b .. " events") end)
  f:push("hit", 5)

  -- Returns true when the time window elapses and batch is flushed.
  local flushed = f:update(0.6)
  print("flushed=" .. tostring(flushed))
end

--@api-stub: Funnel:flush
-- Force an immediate flush of all pending entries
do
  local f = lurek.patterns.newFunnel(60.0, 0)
  f:onFlush(function(b) print("  emergency flush: " .. #b .. " events") end)
  f:push("crash_report", 1)

  -- Force flush on critical events that cannot wait for the time window.
  f:flush()
end

--@api-stub: Funnel:discard
-- Discard all pending entries without flushing or calling the callback
do
  local f = lurek.patterns.newFunnel(2.0, 0)
  f:onFlush(function() end)
  f:push("stale_event", 1); f:push("stale_event", 2)

  -- Discard when the batch is no longer relevant (e.g. player disconnected).
  f:discard()
  print("pending after discard=" .. f:pendingCount())
end

--@api-stub: Funnel:pendingCount
-- Return the number of entries waiting to be flushed
do
  local f = lurek.patterns.newFunnel(5.0, 0)
  f:onFlush(function() end)
  f:push("x", 1); f:push("y", 2); f:push("z", 3)

  -- Monitor buffer fill level.
  print("buffered events=" .. f:pendingCount())
end

--@api-stub: Funnel:getFlushCount
-- Return the total number of times this funnel has flushed since creation
do
  local f = lurek.patterns.newFunnel(0, 1)  -- flush every 1 entry
  f:onFlush(function() end)
  for i = 1, 3 do f:push("evt", i) end

  -- Track how many batches were sent for monitoring.
  print("total flushes=" .. f:getFlushCount())
end

--@api-stub: RelationshipManager:defineType
-- Define a relationship type with named levels in order
do
  local rm = lurek.patterns.newRelationshipManager()

  -- Levels are ordered: index determines thresholds.
  rm:defineType("faction", { "hostile", "neutral", "ally" }, "neutral")
  rm:defineType("trust", { "low", "medium", "high" }, "low")
  print("defined types=" .. #rm:typeNames())
end

--@api-stub: RelationshipManager:removeType
-- Remove a relationship type definition
do
  local rm = lurek.patterns.newRelationshipManager()
  rm:defineType("temp_rel", { "a", "b" }, "a")

  -- Remove types that are no longer used by the current game mode.
  rm:removeType("temp_rel")
  print("types remaining=" .. #rm:typeNames())
end

--@api-stub: RelationshipManager:typeNames
-- Return all defined relationship type names
do
  local rm = lurek.patterns.newRelationshipManager()
  rm:defineType("diplomacy", { "war", "peace" }, "peace")
  rm:defineType("trade", { "embargo", "open" }, "open")

  for _, t in ipairs(rm:typeNames()) do print("  type: " .. t) end
end

--@api-stub: RelationshipManager:setValue
-- Set the numeric relationship value between two entity IDs
do
  local rm = lurek.patterns.newRelationshipManager()

  -- Numeric values track continuous affinity (reputation, friendship score).
  rm:setValue(101, 202, 35)
  print("value=" .. rm:getValue(101, 202) .. " pairs=" .. rm:pairCount())
end

--@api-stub: RelationshipManager:getValue
-- Get the numeric relationship value between two entity IDs (0 if not set)
do
  local rm = lurek.patterns.newRelationshipManager()
  rm:setValue(1, 2, 50)

  -- Use value for shop price modifiers: higher affinity = better prices.
  local affinity = rm:getValue(1, 2)
  local discount = affinity * 0.005
  print("shop discount=" .. (discount * 100) .. "%")
end

--@api-stub: RelationshipManager:adjustValue
-- Add a delta to the relationship value between two entities
do
  local rm = lurek.patterns.newRelationshipManager()
  rm:setValue(1, 2, 0)

  -- Incremental changes from game events.
  rm:adjustValue(1, 2, 25)   -- gift accepted: +25
  rm:adjustValue(1, 2, -10)  -- minor offence: -10
  print("net affinity=" .. rm:getValue(1, 2))  -- 15
end

--@api-stub: RelationshipManager:setLevel
-- Set the named level for a relationship type between two entities
do
  local rm = lurek.patterns.newRelationshipManager()
  rm:defineType("faction", { "hostile", "neutral", "ally" }, "neutral")

  -- Discrete level assignment (e.g. after a quest changes faction standing).
  local ok = rm:setLevel(1, 2, "faction", "ally")
  print("set ally=" .. tostring(ok))
end

--@api-stub: RelationshipManager:getLevel
-- Get the named level for a relationship type between two entities
do
  local rm = lurek.patterns.newRelationshipManager()
  rm:defineType("faction", { "hostile", "ally" }, "hostile")
  rm:setLevel(1, 2, "faction", "ally")

  -- Use level for game logic decisions.
  local lvl = rm:getLevel(1, 2, "faction")
  if lvl == "ally" then print("hold fire - they are allies") end
end

--@api-stub: RelationshipManager:removePair
-- Remove all relationship data between two entities
do
  local rm = lurek.patterns.newRelationshipManager()
  rm:setValue(1, 2, 50)

  -- Remove when an entity is destroyed or relationship is forgotten.
  rm:removePair(1, 2)
  print("pairs after removal=" .. rm:pairCount())
end

--@api-stub: RelationshipManager:pairCount
-- Return the total number of tracked entity pairs
do
  local rm = lurek.patterns.newRelationshipManager()
  rm:setValue(1, 2, 10); rm:setValue(2, 3, -10)

  -- Monitor relationship graph size for performance budgeting.
  if rm:pairCount() > 10000 then print("WARN: large relationship graph") end
  print("tracked pairs=" .. rm:pairCount())
end

--@api-stub: Mediator:on
-- Register a handler callback on a named channel
do
  local m = lurek.patterns.newMediator()

  -- Returns a handler ID for later removal.
  local id = m:on("network", function(msg)
    print("  net received: " .. msg)
  end)
  m:send("network", "player_joined")
  m:off("network", id)
end

--@api-stub: Mediator:off
-- Unregister a handler from a channel by its ID
do
  local m = lurek.patterns.newMediator()
  local id = m:on("ui_events", function() print("  ui tick") end)

  -- Remove handler when the UI screen is closed.
  m:off("ui_events", id)
  print("handlers on ui_events=" .. m:handlerCount("ui_events"))
end

--@api-stub: Mediator:send
-- Send a message to all handlers on a specific channel
do
  local m = lurek.patterns.newMediator()
  m:on("damage_log", function(amount, source)
    print("  " .. source .. " dealt " .. amount .. " damage")
  end)

  -- All handlers on "damage_log" receive the same arguments.
  m:send("damage_log", 12, "spike_trap")
end

--@api-stub: Mediator:broadcast
-- Send a message to all handlers on ALL channels
do
  local m = lurek.patterns.newMediator()
  m:on("audio", function(cmd) print("  audio: " .. cmd) end)
  m:on("video", function(cmd) print("  video: " .. cmd) end)

  -- Broadcast reaches every handler on every channel.
  -- Use for global commands like "pause" or "shutdown".
  m:broadcast("pause")
end

--@api-stub: Mediator:handlerCount
-- Return the number of handlers on a specific channel
do
  local m = lurek.patterns.newMediator()
  m:on("save", function() end)
  m:on("save", function() end)

  -- Debug: verify expected handler count.
  print("save handlers=" .. m:handlerCount("save"))
end

--@api-stub: Mediator:channels
-- Return an array of all channel names with at least one handler
do
  local m = lurek.patterns.newMediator()
  m:on("input", function() end); m:on("physics", function() end)

  -- List active channels for debug overlay.
  for _, ch in ipairs(m:channels()) do print("  channel: " .. ch) end
end

--@api-stub: Mediator:removeChannel
-- Remove an entire channel and all its handlers
do
  local m = lurek.patterns.newMediator()
  m:on("minigame", function() end)

  -- Remove the whole channel when that system shuts down.
  m:removeChannel("minigame")
  print("minigame handlers=" .. m:handlerCount("minigame"))
end

--@api-stub: Mediator:clear
-- Remove all channels and handlers, resetting the mediator
do
  local m = lurek.patterns.newMediator()
  m:on("x", function() end); m:on("y", function() end)

  -- Full reset between game sessions.
  m:clear()
  print("channels after clear=" .. #m:channels())
end

--@api-stub: Strategy:register
-- Register a named strategy implementation function
do
  local s = lurek.patterns.newStrategy()

  -- Register multiple algorithms for the same task.
  s:register("euclidean", function(ax, ay, bx, by)
    return math.sqrt((ax-bx)^2 + (ay-by)^2)
  end)
  s:register("manhattan", function(ax, ay, bx, by)
    return math.abs(ax-bx) + math.abs(ay-by)
  end)
  print("registered strategies=" .. #s:names())
end

--@api-stub: Strategy:set
-- Switch to a named strategy for future execute() calls
do
  local s = lurek.patterns.newStrategy()
  s:register("fast", function(x) return x * 2 end)

  -- set() returns false if the strategy name does not exist.
  local ok = s:set("fast")
  if not ok then print("ERROR: strategy not found") end
end

--@api-stub: Strategy:execute
-- Execute the currently active strategy, forwarding arguments
do
  local s = lurek.patterns.newStrategy()
  s:register("crit", function(atk, def) return atk * 2 - def end)
  s:set("crit")

  -- Arguments and return values pass through to the active implementation.
  local dmg = s:execute(20, 5)
  print("critical damage=" .. dmg)
end

--@api-stub: Strategy:getCurrent
-- Return the name of the currently active strategy (nil if none)
do
  local s = lurek.patterns.newStrategy()
  s:register("normal", function(x) return x end)
  s:set("normal")

  -- Use to display current mode in UI.
  local name = s:getCurrent()
  if name then print("active strategy: " .. name) end
end

--@api-stub: Strategy:has
-- Check whether a strategy with the given name is registered
do
  local s = lurek.patterns.newStrategy()
  s:register("legacy", function() return 0 end)

  -- Guard before set() to handle missing strategies gracefully.
  if s:has("legacy") then s:set("legacy") end
end

--@api-stub: Strategy:remove
-- Remove a named strategy (clears selection if it was active)
do
  local s = lurek.patterns.newStrategy()
  s:register("deprecated", function() end)

  local removed = s:remove("deprecated")
  print("removed=" .. tostring(removed))
end

--@api-stub: Strategy:names
-- Return an array of all registered strategy names
do
  local s = lurek.patterns.newStrategy()
  s:register("alpha", function() end); s:register("beta", function() end)

  for _, n in ipairs(s:names()) do print("  strategy: " .. n) end
end

--@api-stub: Strategy:clear
-- Remove all strategies and reset the selection
do
  local s = lurek.patterns.newStrategy()
  s:register("x", function() end)

  -- Reset when loading new configuration.
  s:clear()
  print("strategies after clear=" .. #s:names())
end

--@api-stub: Stack:push
-- Push a value onto the top of the stack (returns false if at capacity)
do
  local s = lurek.patterns.newStack(4)

  s:push("scene_main")
  s:push("scene_options")
  local ok = s:push("scene_keybinds")
  -- ok is false if capacity is reached.
  print("pushed=" .. tostring(ok) .. " depth=" .. s:len())
end

--@api-stub: Stack:pop
-- Remove and return the top value (nil if empty)
do
  local s = lurek.patterns.newStack(0)
  s:push("menu"); s:push("gameplay")

  -- Pop returns to the previous "screen" in the navigation stack.
  local top = s:pop()
  print("popped=" .. top .. " now at=" .. (s:peek() or "<empty>"))
end

--@api-stub: Stack:peek
-- Return the top value without removing it
do
  local s = lurek.patterns.newStack(0)
  s:push("hud_layer"); s:push("dialog_layer")

  -- Peek to check current state without modifying.
  local top = s:peek()
  if top == "dialog_layer" then print("dialog is showing") end
end

--@api-stub: Stack:len
-- Return the current number of items in the stack
do
  local s = lurek.patterns.newStack(0)
  s:push("a"); s:push("b"); s:push("c")
  print("stack depth=" .. s:len())
end

--@api-stub: Stack:isEmpty
-- Check whether the stack contains no items
do
  local s = lurek.patterns.newStack(0)
  s:push("only_item")
  s:pop()

  -- Empty stack = user navigated all the way back.
  if s:isEmpty() then print("at root, quit to main menu") end
end

--@api-stub: Stack:isFull
-- Check whether the stack has reached its capacity limit
do
  local s = lurek.patterns.newStack(2)
  s:push("a"); s:push("b")

  -- Prevent pushing more dialogs when at max depth.
  if s:isFull() then print("dialog stack full, close one first") end
end

--@api-stub: Stack:clear
-- Remove all items from the stack
do
  local s = lurek.patterns.newStack(0)
  s:push("a"); s:push("b")

  -- Clear on major state transition (e.g. returning to title screen).
  s:clear()
  print("len after clear=" .. s:len())
end

--@api-stub: Stack:toArray
-- Return all items as an array table (bottom to top)
do
  local s = lurek.patterns.newStack(0)
  s:push("Main"); s:push("Settings"); s:push("Audio")

  -- Useful for breadcrumb display: Main > Settings > Audio
  for i, v in ipairs(s:toArray()) do print("  " .. i .. ": " .. v) end
end

--@api-stub: Queue:enqueue
-- Add a value to the back of the queue (returns false if at capacity)
do
  local q = lurek.patterns.newQueue(0)

  q:enqueue("packet_a"); q:enqueue("packet_b")
  local ok = q:enqueue("packet_c")
  print("enqueued=" .. tostring(ok) .. " size=" .. q:len())
end

--@api-stub: Queue:dequeue
-- Remove and return the front value (nil if empty)
do
  local q = lurek.patterns.newQueue(0)
  q:enqueue("first_msg"); q:enqueue("second_msg")

  -- FIFO: dequeue returns the oldest message first.
  local msg = q:dequeue()
  if msg then print("processing: " .. msg) end
end

--@api-stub: Queue:front
-- Return the front value without removing it
do
  local q = lurek.patterns.newQueue(0)
  q:enqueue("urgent"); q:enqueue("normal")

  -- Peek at what's next without consuming it.
  local f = q:front()
  if f then print("next in queue: " .. f) end
end

--@api-stub: Queue:len
-- Return the current number of items in the queue
do
  local q = lurek.patterns.newQueue(0)
  for i = 1, 4 do q:enqueue("event_" .. i) end
  print("queue size=" .. q:len())
end

--@api-stub: Queue:isEmpty
-- Check whether the queue contains no items
do
  local q = lurek.patterns.newQueue(0)
  q:enqueue("task")

  -- Drain loop pattern.
  while not q:isEmpty() do
    print("  handled: " .. q:dequeue())
  end
end

--@api-stub: Queue:isFull
-- Check whether the queue has reached its capacity limit
do
  local q = lurek.patterns.newQueue(2)
  q:enqueue("a"); q:enqueue("b")

  -- Drop new inputs when the queue is saturated.
  if q:isFull() then print("queue full, dropping input") end
end

--@api-stub: Queue:clear
-- Remove all items from the queue
do
  local q = lurek.patterns.newQueue(0)
  q:enqueue("x"); q:enqueue("y")

  -- Clear pending commands when aborting an action sequence.
  q:clear()
  print("size after clear=" .. q:len())
end

--@api-stub: Queue:toArray
-- Return all items as an array table (front to back)
do
  local q = lurek.patterns.newQueue(0)
  q:enqueue("alpha"); q:enqueue("beta"); q:enqueue("gamma")

  for i, v in ipairs(q:toArray()) do print("  " .. i .. ": " .. v) end
end

--@api-stub: List:add
-- Append a value to the end of the list
do
  local l = lurek.patterns.newList()

  -- Build an inventory by adding items as they are collected.
  l:add("sword"); l:add("shield"); l:add("potion")
  print("inventory size=" .. l:len())
end

--@api-stub: List:get
-- Get the value at a 1-based index (nil if out of range)
do
  local l = lurek.patterns.newList()
  l:add("apple"); l:add("bread")

  -- 1-based indexing matches Lua convention.
  local item = l:get(1)
  if item then print("first item: " .. item) end
end

--@api-stub: List:set
-- Replace the value at a 1-based index
do
  local l = lurek.patterns.newList()
  l:add("placeholder")

  -- Overwrite at a specific slot (e.g. equipment slot swap).
  l:set(1, "enchanted_sword")
  print("slot 1: " .. l:get(1))
end

--@api-stub: List:remove
-- Remove and return the value at a 1-based index
do
  local l = lurek.patterns.newList()
  l:add("quest_a"); l:add("quest_b"); l:add("quest_c")

  -- Remove shifts subsequent items left (like removing from an array).
  local removed = l:remove(2)
  print("removed=" .. removed .. " remaining=" .. l:len())
end

--@api-stub: List:len
-- Return the number of items in the list
do
  local l = lurek.patterns.newList()
  for i = 1, 5 do l:add("item_" .. i) end
  print("count=" .. l:len())
end

--@api-stub: List:isEmpty
-- Check whether the list is empty
do
  local l = lurek.patterns.newList()
  if l:isEmpty() then print("inventory is empty") end
  l:add("ring")
  print("after add: empty=" .. tostring(l:isEmpty()))
end

--@api-stub: List:contains
-- Check whether the list contains a specific value
do
  local l = lurek.patterns.newList()
  l:add("key"); l:add("map"); l:add("torch")

  -- Fast membership check for quest prerequisites.
  if l:contains("key") then print("door can be opened") end
end

--@api-stub: List:clear
-- Remove all items from the list
do
  local l = lurek.patterns.newList()
  l:add("x"); l:add("y")

  -- Clear when the player drops all items.
  l:clear()
  print("len after clear=" .. l:len())
end

--@api-stub: List:toArray
-- Return all items as a plain Lua array table
do
  local l = lurek.patterns.newList()
  l:add("fire"); l:add("ice"); l:add("lightning")

  -- Convert to plain table for iteration or serialization.
  for i, v in ipairs(l:toArray()) do print("  " .. i .. "=" .. v) end
end

--@api-stub: Set:add
-- Add a string to the set (returns true if newly added)
do
  local s = lurek.patterns.newSet()

  -- Returns true only on the first add (detects duplicates).
  local was_new = s:add("collected_gem")
  if was_new then print("first gem collected!") end
  s:add("collected_gem")  -- returns false, already present
end

--@api-stub: Set:remove
-- Remove a string from the set (returns true if it was present)
do
  local s = lurek.patterns.newSet()
  s:add("buff_speed")

  -- Remove when an effect expires.
  local existed = s:remove("buff_speed")
  print("removed=" .. tostring(existed) .. " size=" .. s:len())
end

--@api-stub: Set:has
-- Check whether a string is in the set
do
  local s = lurek.patterns.newSet()
  s:add("flying")

  -- O(1) membership check for status effects.
  if s:has("flying") then print("ignore gravity") end
end

--@api-stub: Set:len
-- Return the number of items in the set
do
  local s = lurek.patterns.newSet()
  s:add("orc"); s:add("goblin"); s:add("orc")  -- duplicate ignored

  -- Unique count only.
  print("unique enemies killed=" .. s:len())
end

--@api-stub: Set:isEmpty
-- Check whether the set is empty
do
  local s = lurek.patterns.newSet()
  if s:isEmpty() then print("no keys collected yet") end
  s:add("brass_key")
  print("empty=" .. tostring(s:isEmpty()))
end

--@api-stub: Set:toArray
-- Return all items as an array table
do
  local s = lurek.patterns.newSet()
  s:add("red"); s:add("green"); s:add("blue")

  -- Convert for serialization or display.
  for _, k in ipairs(s:toArray()) do print("  color: " .. k) end
end

--@api-stub: Set:clear
-- Remove all items from the set
do
  local s = lurek.patterns.newSet()
  s:add("seen_intro"); s:add("opened_chest")

  -- Clear when starting a new game.
  s:clear()
  print("size after clear=" .. s:len())
end

--@api-stub: Set:union
-- Return a new set containing all items from both sets
do
  local a = lurek.patterns.newSet(); a:add("sword"); a:add("shield")
  local b = lurek.patterns.newSet(); b:add("shield"); b:add("bow")

  -- Union combines both inventories (duplicates are collapsed).
  local combined = a:union(b)
  print("union size=" .. combined:len())  -- 3: sword, shield, bow
end

--@api-stub: Set:intersection
-- Return a new set containing only items present in both sets
do
  local player_has = lurek.patterns.newSet(); player_has:add("key"); player_has:add("map")
  local door_needs = lurek.patterns.newSet(); door_needs:add("map"); door_needs:add("torch")

  -- Intersection shows which requirements the player already meets.
  local matched = player_has:intersection(door_needs)
  print("requirements met=" .. matched:len())  -- 1: map
end

-- -----------------------------------------------------------------------------
-- Extended LList methods (push, unshift, insert, indexOf, reverse, pop, shift)
-- -----------------------------------------------------------------------------

--@api-stub: LList:add
-- Append a value to the end of the list
do
  local lst = lurek.patterns.newList()
  -- add() is the primary way to grow the list.
  lst:add("sword")
  lst:add("shield")
  lst:add("potion")
  print("list size=" .. lst:len())
end

--@api-stub: LList:get
-- Get the value at a 1-based index
do
  local lst = lurek.patterns.newList()
  lst:add("apple")
  lst:add("banana")
  -- 1-based: index 2 is the second element.
  local item = lst:get(2)
  print("item[2]=" .. tostring(item))
end

--@api-stub: LList:set
-- Replace the value at a 1-based index
do
  local lst = lurek.patterns.newList()
  lst:add("iron_sword")
  lst:add("leather_boots")
  -- Overwrite slot 1 with an upgraded item.
  lst:set(1, "mythril_sword")
  print("slot 1=" .. tostring(lst:get(1)))
end

--@api-stub: LList:remove
-- Remove and return the value at a 1-based index
do
  local lst = lurek.patterns.newList()
  lst:add("quest_a")
  lst:add("quest_b")
  lst:add("quest_c")
  -- Removes quest_b, shifts quest_c down to index 2.
  local removed = lst:remove(2)
  print("removed=" .. tostring(removed) .. " remaining=" .. lst:len())
end

--@api-stub: LList:len
-- Return the number of items in the list
do
  local lst = lurek.patterns.newList()
  for i = 1, 5 do lst:add(i * 10) end
  print("list length=" .. lst:len())
end

--@api-stub: LList:isEmpty
-- Check whether the list is empty
do
  local lst = lurek.patterns.newList()
  print("before add: empty=" .. tostring(lst:isEmpty()))
  lst:add("item")
  print("after add: empty=" .. tostring(lst:isEmpty()))
end

--@api-stub: LList:contains
-- Check whether the list contains a specific value
do
  local lst = lurek.patterns.newList()
  lst:add("fire")
  lst:add("ice")
  lst:add("thunder")
  -- Linear search for the value.
  print("has fire: " .. tostring(lst:contains("fire")))
  print("has wind: " .. tostring(lst:contains("wind")))
end

--@api-stub: LList:clear
-- Remove all items from the list
do
  local lst = lurek.patterns.newList()
  lst:add("a")
  lst:add("b")
  lst:clear()
  print("length after clear=" .. lst:len())
end

--@api-stub: LList:toArray
-- Return all items as an array table
do
  local lst = lurek.patterns.newList()
  lst:add(10)
  lst:add(20)
  lst:add(30)
  -- toArray() returns a plain Lua table for iteration.
  local arr = lst:toArray()
  print("arr[2]=" .. tostring(arr[2]))
end

--@api-stub: new
-- Create new pattern instances (WeightedRandom, BehaviorTree, Graph)
do
  -- All newXxx() constructors return ready-to-use pattern objects.
  local wr = lurek.patterns.newWeightedRandom()
  local bt = lurek.patterns.newBehaviorTree()
  local g = lurek.patterns.newGraph()
  if wr and bt and g then
    print("all pattern factories operational")
  end
end

--@api-stub: LWeightedRandom
-- Weighted random selection pool for loot tables, spawn variety, and procedural generation
do
  local wr = lurek.patterns.newWeightedRandom()

  -- Weight determines relative probability. 9.0 "common" vs 1.0 "rare"
  -- means ~90% chance of common, ~10% rare.
  local id_common = wr:add(9.0, "common_drop", "common")
  local id_rare = wr:add(1.0, "rare_drop", "rare")

  -- Adjust weights dynamically (e.g. pity system increasing rare chance).
  wr:setWeight(id_rare, 2.0)

  -- pick() takes a random sample in [0, 1). Use math.random() in production.
  local result = wr:pick(0.85)
  print("picked: " .. tostring(result))

  -- pickN() selects multiple unique items.
  local batch = wr:pickN(2, { 0.1, 0.9 })
  print("batch size=" .. #batch .. " total_weight=" .. wr:totalWeight())

  -- Track changes with revision counter.
  local rev = wr:getRevision()
  wr:remove(id_common)
  print("revision changed: " .. tostring(wr:getRevision() ~= rev))
  wr:clearAll()
end

--@api-stub: LBehaviorTree
-- Behavior tree for AI decision-making with sequences, selectors, parallels, and leaf actions
do
  local bt = lurek.patterns.newBehaviorTree()

  -- Build tree structure: root sequence runs children in order.
  local root_seq = bt:addSequence("root")
  -- Selector tries children until one succeeds (fallback logic).
  local fallback = bt:addSelector("try_actions")
  -- Parallel runs children simultaneously, succeeds if minSuccess children pass.
  local parallel = bt:addParallel(1, "concurrent")
  -- Inverter flips child result: success becomes failure and vice versa.
  local inverter = bt:addInverter("negate")
  -- Repeater runs its child N times.
  local repeater = bt:addRepeat(2, "do_twice")
  -- Leaves are the actual actions that return "success", "failure", or "running".
  local leaf_patrol = bt:addLeaf("patrol", "patrol_action")
  local leaf_attack = bt:addLeaf("attack", "attack_action")

  -- Wire up the tree hierarchy.
  bt:addChild(root_seq, fallback)
  bt:addChild(fallback, parallel)
  bt:addChild(parallel, inverter)
  bt:addChild(inverter, repeater)
  bt:addChild(repeater, leaf_patrol)
  bt:addChild(fallback, leaf_attack)

  -- Register leaf implementations. These run the actual game logic.
  bt:setLeaf("patrol", function() return "success" end)
  bt:setLeaf("attack", function() return "failure" end)

  -- Set root and tick once per AI update.
  bt:setRoot(root_seq)
  local status = bt:tick()
  print("AI decision: " .. status .. " (nodes=" .. bt:nodeCount() .. ")")

  -- Reset running state between encounters.
  bt:resetState()
  bt:clearAll()
end

--@api-stub: LGraph
-- Graph data structure with directed/undirected edges, BFS, DFS, and connectivity queries
do
  -- Create undirected graph (edges go both ways).
  local g = lurek.patterns.newGraph(true)

  -- Add nodes with optional labels and payload data.
  local town_a = g:addNode("Riverdale", { population = 500 })
  local town_b = g:addNode("Hillcrest", { population = 300 })
  local town_c = g:addNode("Lakewood", { population = 800 })

  -- Connect nodes with weighted edges (distance between towns).
  local road1 = g:addEdge(town_a, town_b, 15.0, "dirt_road")
  g:addEdge(town_b, town_c, 22.0, "paved_road")

  -- Query node data.
  local data = g:getNodeValue(town_a)
  print("Riverdale pop=" .. (data and data.population or 0))

  -- Pathfinding queries.
  local neighbors = g:neighbors(town_a)
  local bfs_order = g:bfs(town_a)
  local dfs_order = g:dfs(town_a)
  local connected = g:isConnected(town_a, town_c)

  print("neighbors=" .. #neighbors
    .. " bfs=" .. #bfs_order
    .. " dfs=" .. #dfs_order
    .. " a-c connected=" .. tostring(connected))

  -- Modify graph: remove a road and a town.
  g:removeEdge(road1)
  g:removeNode(town_c)
  print("nodes=" .. g:nodeCount() .. " edges=" .. g:edgeCount())
  g:clearAll()
end

--@api-stub: lurek.patterns.newMap
-- Create a new string-keyed dictionary (map) with keys/values/entries access and merge support
do
  -- Map provides a proper dictionary with iteration support, merge operations,
  -- and entries/keys/values accessors. Use when you need more than a plain table.
  local config = lurek.patterns.newMap()
  config:set("volume", 0.8)
  config:set("fullscreen", true)
  print("map has volume=" .. tostring(config:has("volume")))
end

--@api-stub: LStack
-- Extended Stack operations: pushBottom, peekBottom, insertAt, moveWithin, removeAt, popMany, popBottom
do
  local s = lurek.patterns.newStack(10)

  -- pushBottom inserts at the base of the stack.
  s:push("middle")
  s:pushBottom("bottom")

  -- insertAt places at a specific 1-based index.
  s:insertAt(3, "top")

  -- Peek at different positions without modifying.
  local bottom = s:peekBottom()
  local at2 = s:peekAt(2)

  -- moveWithin reorders items without remove+push.
  s:moveWithin(3, 2)

  -- removeAt extracts from a specific position.
  local removed = s:removeAt(2)

  -- popMany gets multiple items at once.
  local batch = s:popMany(1)

  -- popBottom removes from the base.
  local from_bottom = s:popBottom()

  print("bottom=" .. tostring(bottom)
    .. " at2=" .. tostring(at2)
    .. " removed=" .. tostring(removed)
    .. " batch=" .. #batch
    .. " popBottom=" .. tostring(from_bottom))
end

--@api-stub: LQueue
-- Extended Queue operations: enqueueFront, dequeueBack, insertAt, peekAt, removeAt, back
do
  local q = lurek.patterns.newQueue(10)

  -- enqueueFront inserts at the front (priority insertion).
  q:enqueue("normal")
  q:enqueueFront("urgent")
  q:enqueue("low")

  -- insertAt places at a specific position.
  q:insertAt(3, "medium")

  -- Peek at back and specific positions.
  local back = q:back()
  local at2 = q:peekAt(2)

  -- removeAt extracts from a specific position.
  local removed = q:removeAt(3)

  -- dequeueBack removes from the back (opposite of dequeue).
  local from_back = q:dequeueBack()

  print("back=" .. tostring(back)
    .. " peekAt2=" .. tostring(at2)
    .. " removeAt3=" .. tostring(removed)
    .. " dequeueBack=" .. tostring(from_back))
end

--@api-stub: LList
-- Extended List operations: push, unshift, insert, indexOf, reverse, pop, shift
do
  local l = lurek.patterns.newList()

  -- push is an alias for add (append to end).
  l:push("beta")
  -- unshift prepends to the beginning.
  l:unshift("alpha")
  -- insert at a specific 1-based index.
  l:insert(3, "gamma")

  -- indexOf returns the 1-based position of a value.
  local idx = l:indexOf("beta")

  -- reverse the entire list in-place.
  l:reverse()

  -- pop removes from the end, shift removes from the beginning.
  local popped = l:pop()
  local shifted = l:shift()

  print("indexOf(beta)=" .. tostring(idx)
    .. " pop=" .. tostring(popped)
    .. " shift=" .. tostring(shifted))
end

--@api-stub: LMap
-- Map operations: set, get, has, len, isEmpty, keys, values, entries, merge, remove, clear
do
  local stats = lurek.patterns.newMap()

  -- Set key-value pairs.
  stats:set("hp", 100)
  stats:set("name", "hero")
  stats:set("level", 5)

  -- Query operations.
  local hp = stats:get("hp")
  local has_hp = stats:has("hp")
  local count = stats:len()
  local empty = stats:isEmpty()

  -- Iteration helpers.
  local keys = stats:keys()
  local values = stats:values()
  local entries = stats:entries()

  -- Merge another map (overwrites matching keys).
  local buffs = lurek.patterns.newMap()
  buffs:set("hp", 120)  -- buff overwrites base hp
  buffs:set("mp", 50)
  stats:merge(buffs)

  -- Remove a key.
  local removed = stats:remove("name")

  -- Clear all entries.
  stats:clear()

  print("hp=" .. tostring(hp)
    .. " has_hp=" .. tostring(has_hp)
    .. " count=" .. tostring(count)
    .. " empty=" .. tostring(empty)
    .. " keys=" .. #keys
    .. " vals=" .. #values
    .. " entries=" .. #entries
    .. " removed=" .. tostring(removed))
end

print("content/examples/patterns.lua")
