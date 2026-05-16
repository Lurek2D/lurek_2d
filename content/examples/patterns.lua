-- content/examples/patterns.lua
-- lurek.patterns API examples.
-- Run: cargo run -- content/examples/patterns.lua

--@api-stub: lurek.patterns.newEventBus -- Create a new publish/subscribe event bus for decoupled communication between game systems
do -- lurek.patterns.newEventBus
  local bus = lurek.patterns.newEventBus("ui_bus")
  local id = bus:on("hp_changed", function(hp) print("hp now", hp) end)
  bus:emit("hp_changed", 42)
  bus:off(id)
end

--@api-stub: lurek.patterns.newObjectPool -- Create a new object pool for reusing pre-allocated game objects to reduce allocation overhead
do -- lurek.patterns.newObjectPool
  local pool = lurek.patterns.newObjectPool()
  pool:add({ x = 0, y = 0, vx = 0, vy = 0 })
  pool:add({ x = 0, y = 0, vx = 0, vy = 0 })
  local bullet = pool:acquire()
  if bullet then bullet.x, bullet.y = 100, 200 end
end

--@api-stub: lurek.patterns.newCommandStack -- Create a new undo/redo command stack for recording and reversing player or editor actions
do -- lurek.patterns.newCommandStack
  local stack = lurek.patterns.newCommandStack(64)
  local x = 0
  stack:execute("move", function() x = x + 10 end, function() x = x - 10 end)
  print("after exec x=" .. x)
  stack:undo()
  print("after undo x=" .. x)
end

--@api-stub: lurek.patterns.newServiceLocator -- Create a new service locator for registering and retrieving shared services by name at runtime
do -- lurek.patterns.newServiceLocator
  local services = lurek.patterns.newServiceLocator()
  services:provide("logger", { info = function(m) print("[info] " .. m) end })
  local log = services:locate("logger")
  if log then log.info("services online") end
end

--@api-stub: lurek.patterns.newFactory -- Create a new factory for producing typed game objects from registered constructor functions
do -- lurek.patterns.newFactory
  local enemies = lurek.patterns.newFactory()
  enemies:register("goblin", function(x, y) return { kind = "goblin", x = x, y = y, hp = 20 } end)
  local g = enemies:create("goblin", 64, 32)
  if g then
    print("spawned " .. g.kind .. " at " .. g.x .. "," .. g.y)
  end
end

--@api-stub: lurek.patterns.newSimpleState -- Create a new finite state machine with enter/exit/update callbacks per state
do -- lurek.patterns.newSimpleState
  local sm = lurek.patterns.newSimpleState()
  sm:addState("idle", { enter = function() print("idle") end })
  sm:addState("walk", { update = function(dt) print("walking dt=" .. dt) end })
  sm:transitionTo("walk")
  sm:update(0.016)
end

--@api-stub: lurek.patterns.newBlackboard -- Create a new shared key-value blackboard supporting reactive watchers for game logic variables
do -- lurek.patterns.newBlackboard
  local bb = lurek.patterns.newBlackboard("ai_world")
  bb:set("player_hp", 100)
  bb:set("alarm_on", false)
  if not bb:get("alarm_on") and bb:get("player_hp") < 25 then bb:set("alarm_on", true) end
  print("alarm=" .. tostring(bb:get("alarm_on")))
end

--@api-stub: lurek.patterns.newObserver -- Create a new reactive observer that stores values and notifies subscribers when they change
do -- lurek.patterns.newObserver
  local obs = lurek.patterns.newObserver("hud")
  obs:subscribe("score", function(_, v) print("hud score=" .. v) end)
  obs:set("score", 0)
  obs:set("score", 100)
end

--@api-stub: lurek.patterns.newThrottle -- Create a new throttle that limits how often an action can fire, enforcing a minimum interval
do -- lurek.patterns.newThrottle
  local fire = lurek.patterns.newThrottle(0.25)
  fire:onFire(function() print("BANG") end)
  fire:update(0.016)
end

--@api-stub: lurek.patterns.newDebounce -- Create a new debounce that delays firing until input stops for a specified wait period
do -- lurek.patterns.newDebounce
  local save = lurek.patterns.newDebounce(0.5)
  save:onFire(function() print("autosave") end)
  function lurek.process(dt) save:update(dt) end
  save:trigger()
end

--@api-stub: lurek.patterns.newPriorityQueue -- Create a new priority queue that orders elements by numeric priority (highest first)
do -- lurek.patterns.newPriorityQueue
  local jobs = lurek.patterns.newPriorityQueue("ai_jobs")
  jobs:push(10, { kind = "patrol" })
  jobs:push(50, { kind = "attack", target = "player" })
  local top = jobs:pop()
  if top then print("running job: " .. top.kind) end
end

--@api-stub: lurek.patterns.newRing -- Create a new fixed-size ring buffer for numeric or string values
do -- lurek.patterns.newRing
  local fps_log = lurek.patterns.newRing(60, "fps")
  for i = 1, 65 do fps_log:push(58 + (i % 4), "frame") end
  print("avg fps=" .. fps_log:average() .. " entries=" .. fps_log:len())
end

--@api-stub: lurek.patterns.newFunnel -- Create a new batching funnel that collects events over a time window and flushes them together
do -- lurek.patterns.newFunnel
  local analytics = lurek.patterns.newFunnel(2.0, 32, "events")
  analytics:onFlush(function(batch) print("flushing " .. #batch .. " events") end)
  analytics:push("level_start", 1)
  analytics:push("kill", 5)
  function lurek.process(dt) analytics:update(dt) end
end

--@api-stub: lurek.patterns.newRelationshipManager -- Create a new relationship manager for tracking numeric values and named levels between entity pairs
do -- lurek.patterns.newRelationshipManager
  local rel = lurek.patterns.newRelationshipManager()
  rel:defineType("diplomacy", { "hostile", "neutral", "friendly", "ally" }, "neutral")
  rel:setValue(101, 202, -50)
  rel:setLevel(101, 202, "diplomacy", "hostile")
  print("level=" .. rel:getLevel(101, 202, "diplomacy"))
end

--@api-stub: lurek.patterns.newMediator -- Create a new mediator for channel-based message passing between decoupled game systems
do -- lurek.patterns.newMediator
  local hub = lurek.patterns.newMediator()
  hub:on("chat", function(user, msg) print(user .. ": " .. msg) end)
  hub:send("chat", "alice", "gg")
end

--@api-stub: lurek.patterns.newStrategy -- Create a new strategy pattern container for hot-swappable algorithm implementations
do -- lurek.patterns.newStrategy
  local damage = lurek.patterns.newStrategy()
  damage:register("normal", function(atk, def) return math.max(1, atk - def) end)
  damage:register("crit", function(atk, def) return math.max(1, atk * 2 - def) end)
  damage:set("crit")
  print("dmg=" .. damage:execute(20, 5))
end

--@api-stub: lurek.patterns.newStack -- Create a new LIFO stack with optional capacity limit
do -- lurek.patterns.newStack
  local nav = lurek.patterns.newStack(8)
  nav:push("main_menu")
  nav:push("options")
  print("top=" .. nav:peek() .. " depth=" .. nav:len())
  nav:pop()
end

--@api-stub: lurek.patterns.newQueue -- Create a new FIFO queue with optional capacity limit
do -- lurek.patterns.newQueue
  local mail = lurek.patterns.newQueue(0)
  mail:enqueue("hello")
  mail:enqueue("ready?")
  print("front=" .. mail:front() .. " size=" .. mail:len())
end

--@api-stub: lurek.patterns.newList -- Create a new dynamic array list with indexed access, insertion, removal, and search
do -- lurek.patterns.newList
  local quests = lurek.patterns.newList()
  quests:add("Find the key")
  quests:add("Open the chest")
  quests:set(1, "Find the brass key")
  print("quest[1]=" .. quests:get(1))
end

--@api-stub: lurek.patterns.newSet -- Create a new string set with add/remove/has operations and set algebra (union, intersection)
do -- lurek.patterns.newSet
  local unlocked = lurek.patterns.newSet()
  unlocked:add("level_1")
  unlocked:add("level_2")
  if unlocked:has("level_2") then print("portal open") end
end

--@api-stub: EventBus:on
do -- EventBus:on
  local bus = lurek.patterns.newEventBus("game")
  local id = bus:on("level_clear", function(lvl) print("cleared " .. lvl) end, 100)
  bus:emit("level_clear", "forest_01")
  bus:off(id)
end

--@api-stub: EventBus:off
do -- EventBus:off
  local bus = lurek.patterns.newEventBus()
  local id = bus:on("ping", function() print("pong") end)
  bus:off(id)
  bus:emit("ping")  -- no listener now
  print("listeners=" .. bus:getListenerCount("ping"))
end

--@api-stub: EventBus:emit
do -- EventBus:emit
  local bus = lurek.patterns.newEventBus()
  bus:on("damage", function(amount, src) print(src .. " dealt " .. amount) end)
  bus:emit("damage", 12, "goblin")
  bus:emit("damage", 30, "boss")
end

--@api-stub: EventBus:clear
do -- EventBus:clear
  local bus = lurek.patterns.newEventBus()
  bus:on("minigame_score", function(s) print("score " .. s) end)
  bus:on("minigame_score", function(s) print("hud " .. s) end)
  bus:clear("minigame_score")
  print("after clear: " .. bus:getListenerCount("minigame_score"))
end

--@api-stub: EventBus:clearAll
do -- EventBus:clearAll
  local bus = lurek.patterns.newEventBus()
  bus:on("a", function() end)
  bus:on("b", function() end)
  bus:clearAll()
  print("events left=" .. #bus:getEvents())
end

--@api-stub: EventBus:getListenerCount
do -- EventBus:getListenerCount
  local bus = lurek.patterns.newEventBus()
  bus:on("hit", function() end)
  bus:on("hit", function() end)
  local n = bus:getListenerCount("hit")
  if n > 1 then print("warning: " .. n .. " hit listeners") end
end

--@api-stub: EventBus:getEvents
do -- EventBus:getEvents
  local bus = lurek.patterns.newEventBus()
  bus:on("save", function() end)
  bus:on("quit", function() end)
  for _, name in ipairs(bus:getEvents()) do print("ch:" .. name) end
end

--@api-stub: ObjectPool:add
do -- ObjectPool:add
  local bullets = lurek.patterns.newObjectPool()
  for i = 1, 32 do bullets:add({ x = 0, y = 0, alive = false }) end
  print("pre-warmed bullets=" .. bullets:getAvailableCount())
end

--@api-stub: ObjectPool:acquire
do -- ObjectPool:acquire
  local pool = lurek.patterns.newObjectPool()
  pool:add({ x = 0, y = 0, vx = 0, vy = 0 })
  local b = pool:acquire()
  if b then b.x, b.y, b.vx = 50, 50, 200 end
  print("active=" .. pool:getActiveCount())
end

--@api-stub: ObjectPool:release
do -- ObjectPool:release
  local pool = lurek.patterns.newObjectPool()
  pool:add({ alive = false })
  local p = pool:acquire()
  p.alive = false
  pool:release(p)
  print("idle=" .. pool:getAvailableCount())
end

--@api-stub: ObjectPool:getActiveCount
do -- ObjectPool:getActiveCount
  local pool = lurek.patterns.newObjectPool()
  pool:add({}); pool:add({})
  pool:acquire(); pool:acquire()
  local n = pool:getActiveCount()
  if n > 100 then print("WARN pool leak: " .. n) end
end

--@api-stub: ObjectPool:getAvailableCount
do -- ObjectPool:getAvailableCount
  local pool = lurek.patterns.newObjectPool()
  for i = 1, 4 do pool:add({}) end
  pool:acquire()
  if pool:getAvailableCount() < 2 then pool:add({}) end
  print("idle now=" .. pool:getAvailableCount())
end

--@api-stub: ObjectPool:getTotalCount
do -- ObjectPool:getTotalCount
  local pool = lurek.patterns.newObjectPool()
  for i = 1, 16 do pool:add({}) end
  pool:acquire()
  print("total=" .. pool:getTotalCount() .. " active=" .. pool:getActiveCount())
end

--@api-stub: ObjectPool:clearAll
do -- ObjectPool:clearAll
  local pool = lurek.patterns.newObjectPool()
  pool:add({}); pool:add({})
  pool:clearAll()
  print("after clear total=" .. pool:getTotalCount())
end

--@api-stub: CommandStack:execute
do -- CommandStack:execute
  local stack = lurek.patterns.newCommandStack(0)
  local doc = { text = "hello" }
  local function run(s) local prev = doc.text; doc.text = doc.text .. s; return prev end
  local prev = doc.text
  stack:execute("append", function() doc.text = doc.text .. "!" end, function() doc.text = prev end)
  print("doc=" .. doc.text)
end

--@api-stub: CommandStack:undo
do -- CommandStack:undo
  local stack = lurek.patterns.newCommandStack(0)
  local x = 5
  stack:execute("inc", function() x = x + 1 end, function() x = x - 1 end)
  local ok = stack:undo()
  print("undone=" .. tostring(ok) .. " x=" .. x)
end

--@api-stub: CommandStack:redo
do -- CommandStack:redo
  local stack = lurek.patterns.newCommandStack(0)
  local n = 0
  stack:execute("step", function() n = n + 1 end, function() n = n - 1 end)
  stack:undo()
  stack:redo()
  print("after redo n=" .. n)
end

--@api-stub: CommandStack:canUndo
do -- CommandStack:canUndo
  local stack = lurek.patterns.newCommandStack(0)
  stack:execute("noop", function() end, function() end)
  if stack:canUndo() then print("undo enabled") else print("undo disabled") end
end

--@api-stub: CommandStack:canRedo
do -- CommandStack:canRedo
  local stack = lurek.patterns.newCommandStack(0)
  stack:execute("noop", function() end, function() end)
  stack:undo()
  if stack:canRedo() then print("redo enabled") end
end

--@api-stub: CommandStack:getHistorySize
do -- CommandStack:getHistorySize
  local stack = lurek.patterns.newCommandStack(0)
  for i = 1, 5 do stack:execute("op_" .. i, function() end, function() end) end
  print("history=" .. stack:getHistorySize())
end

--@api-stub: CommandStack:getCurrentName
do -- CommandStack:getCurrentName
  local stack = lurek.patterns.newCommandStack(0)
  stack:execute("paint", function() end, function() end)
  local name = stack:getCurrentName()
  if name then print("undo will revert: " .. name) end
end

--@api-stub: CommandStack:clearAll
do -- CommandStack:clearAll
  local stack = lurek.patterns.newCommandStack(0)
  stack:execute("a", function() end, function() end)
  stack:clearAll()
  print("history after clear=" .. stack:getHistorySize())
end

--@api-stub: ServiceLocator:provide
do -- ServiceLocator:provide
  local sl = lurek.patterns.newServiceLocator()
  sl:provide("clock", { now = function() return 42.0 end })
  sl:provide("save", { path = "save/slot1.dat" })
  print("services=" .. #sl:getServices())
end

--@api-stub: ServiceLocator:locate
do -- ServiceLocator:locate
  local sl = lurek.patterns.newServiceLocator()
  sl:provide("audio", { volume = 0.8 })
  local audio = sl:locate("audio")
  if audio then print("vol=" .. audio.volume) end
end

--@api-stub: ServiceLocator:has
do -- ServiceLocator:has
  local sl = lurek.patterns.newServiceLocator()
  sl:provide("analytics", {})
  if sl:has("analytics") then print("telemetry on") end
end

--@api-stub: ServiceLocator:remove
do -- ServiceLocator:remove
  local sl = lurek.patterns.newServiceLocator()
  sl:provide("net", { online = true })
  sl:remove("net")
  print("net registered=" .. tostring(sl:has("net")))
end

--@api-stub: ServiceLocator:getServices
do -- ServiceLocator:getServices
  local sl = lurek.patterns.newServiceLocator()
  sl:provide("a", 1); sl:provide("b", 2)
  for _, name in ipairs(sl:getServices()) do print("svc: " .. name) end
end

--@api-stub: ServiceLocator:clearAll
do -- ServiceLocator:clearAll
  local sl = lurek.patterns.newServiceLocator()
  sl:provide("x", 1); sl:provide("y", 2)
  sl:clearAll()
  print("count=" .. #sl:getServices())
end

--@api-stub: Factory:register
do -- Factory:register
  local f = lurek.patterns.newFactory()
  f:register("orc", function(x, y) return { kind = "orc", hp = 30, x = x, y = y } end)
  f:register("troll", function(x, y) return { kind = "troll", hp = 80, x = x, y = y } end)
  print("registered=" .. #f:getTypes())
end

--@api-stub: Factory:create
do -- Factory:create
  local f = lurek.patterns.newFactory()
  f:register("coin", function(v) return { kind = "coin", value = v } end)
  local c = f:create("coin", 50)
  if c then
    print("dropped " .. c.value .. " gold")
  end
end

--@api-stub: Factory:has
do -- Factory:has
  local f = lurek.patterns.newFactory()
  f:register("npc", function() return { kind = "npc" } end)
  if f:has("npc") then print("npc factory ready") end
end

--@api-stub: Factory:alias
do -- Factory:alias
  local f = lurek.patterns.newFactory()
  f:register("goblin", function() return { kind = "goblin" } end)
  f:alias("monster_v1", "goblin")
  local m = f:create("monster_v1")
  if m then
    print("created via alias: " .. m.kind)
  end
end

--@api-stub: Factory:getTypes
do -- Factory:getTypes
  local f = lurek.patterns.newFactory()
  f:register("a", function() end); f:register("b", function() end)
  for _, name in ipairs(f:getTypes()) do print("type:" .. name) end
end

--@api-stub: Factory:remove
do -- Factory:remove
  local f = lurek.patterns.newFactory()
  f:register("temp", function() return {} end)
  f:remove("temp")
  print("temp still registered=" .. tostring(f:has("temp")))
end

--@api-stub: Factory:clearAll
do -- Factory:clearAll
  local f = lurek.patterns.newFactory()
  f:register("x", function() end)
  f:clearAll()
  print("types after clear=" .. #f:getTypes())
end

--@api-stub: SimpleState:addState
do -- SimpleState:addState
  local sm = lurek.patterns.newSimpleState()
  sm:addState("idle", { enter = function() print("> idle") end, exit = function() print("< idle") end })
  sm:addState("attack", { update = function(dt) print("attacking " .. dt) end })
  print("states=" .. #sm:getStates())
end

--@api-stub: SimpleState:transitionTo
do -- SimpleState:transitionTo
  local sm = lurek.patterns.newSimpleState()
  sm:addState("menu", {})
  sm:addState("game", { enter = function() print("game start") end })
  sm:transitionTo("menu")
  sm:transitionTo("game")
end

--@api-stub: SimpleState:update
do -- SimpleState:update
  local sm = lurek.patterns.newSimpleState()
  sm:addState("run", { update = function(dt) print("tick " .. dt) end })
  sm:transitionTo("run")
  function lurek.process(dt) sm:update(dt) end
end

--@api-stub: SimpleState:getCurrent
do -- SimpleState:getCurrent
  local sm = lurek.patterns.newSimpleState()
  sm:addState("paused", {})
  sm:transitionTo("paused")
  if sm:getCurrent() == "paused" then print("game is paused") end
end

--@api-stub: SimpleState:hasState
do -- SimpleState:hasState
  local sm = lurek.patterns.newSimpleState()
  sm:addState("boss", {})
  if sm:hasState("boss") then sm:transitionTo("boss") end
end

--@api-stub: SimpleState:getStates
do -- SimpleState:getStates
  local sm = lurek.patterns.newSimpleState()
  sm:addState("a", {}); sm:addState("b", {}); sm:addState("c", {})
  for _, name in ipairs(sm:getStates()) do print("state:" .. name) end
end

--@api-stub: SimpleState:clearAll
do -- SimpleState:clearAll
  local sm = lurek.patterns.newSimpleState()
  sm:addState("x", {})
  sm:clearAll()
  print("states left=" .. #sm:getStates())
end

--@api-stub: Blackboard:set
do -- Blackboard:set
  local bb = lurek.patterns.newBlackboard()
  bb:set("hp", 100)
  bb:set("name", "Aria")
  bb:set("alarm", true)
  print("name=" .. bb:get("name"))
end

--@api-stub: Blackboard:get
do -- Blackboard:get
  local bb = lurek.patterns.newBlackboard()
  bb:set("ammo", 12)
  local ammo = bb:get("ammo") or 0
  if ammo <= 0 then print("reload!") else print("ammo=" .. ammo) end
end

--@api-stub: Blackboard:has
do -- Blackboard:has
  local bb = lurek.patterns.newBlackboard()
  bb:set("seen_player", true)
  if bb:has("seen_player") then print("AI is alerted") end
end

--@api-stub: Blackboard:clear
do -- Blackboard:clear
  local bb = lurek.patterns.newBlackboard()
  bb:set("target", "player")
  bb:clear("target")
  print("target set=" .. tostring(bb:has("target")))
end

--@api-stub: Blackboard:keys
do -- Blackboard:keys
  local bb = lurek.patterns.newBlackboard()
  bb:set("hp", 50); bb:set("mode", "patrol")
  for _, k in ipairs(bb:keys()) do print(k .. "=" .. tostring(bb:get(k))) end
end

--@api-stub: Blackboard:watch
do -- Blackboard:watch
  local bb = lurek.patterns.newBlackboard()
  local id = bb:watch("hp", function(k, v) print(k .. " changed to " .. v) end)
  bb:set("hp", 75)
  bb:unwatch(id)
end

--@api-stub: Blackboard:unwatch
do -- Blackboard:unwatch
  local bb = lurek.patterns.newBlackboard()
  local id = bb:watch("*", function(k) print("write to " .. k) end)
  bb:set("debug", "on")
  bb:unwatch(id)
end

--@api-stub: Blackboard:getRevision
do -- Blackboard:getRevision
  local bb = lurek.patterns.newBlackboard()
  local last_rev = bb:getRevision()
  bb:set("k", 1)
  if bb:getRevision() ~= last_rev then print("dirty") end
end

--@api-stub: Blackboard:snapshot
do -- Blackboard:snapshot
  local bb = lurek.patterns.newBlackboard()
  bb:set("hp", 80); bb:set("mode", "alert")
  local snap = bb:snapshot()
  for k, v in pairs(snap) do print(k .. "=" .. tostring(v)) end
end

--@api-stub: Blackboard:clearAll
do -- Blackboard:clearAll
  local bb = lurek.patterns.newBlackboard()
  bb:set("hp", 100)
  bb:clearAll()
  print("keys after clear=" .. #bb:keys())
end

--@api-stub: Observer:set
do -- Observer:set
  local o = lurek.patterns.newObserver("player")
  o:subscribe("hp", function(_, v) print("hud hp=" .. v) end)
  o:set("hp", 100)
  o:set("hp", 75)
end

--@api-stub: Observer:get
do -- Observer:get
  local o = lurek.patterns.newObserver()
  o:set("score", 1500)
  local s = o:get("score") or 0
  print("score now " .. s)
end

--@api-stub: Observer:subscribe
do -- Observer:subscribe
  local o = lurek.patterns.newObserver()
  local id = o:subscribe("*", function(k, v) print("write " .. k .. "=" .. tostring(v)) end)
  o:set("a", 1); o:set("b", "two")
  o:unsubscribe(id)
end

--@api-stub: Observer:unsubscribe
do -- Observer:unsubscribe
  local o = lurek.patterns.newObserver()
  local id = o:subscribe("k", function() end)
  o:unsubscribe(id)
  print("subs left=" .. o:getCount())
end

--@api-stub: Observer:getCount
do -- Observer:getCount
  local o = lurek.patterns.newObserver()
  o:subscribe("a", function() end)
  o:subscribe("b", function() end)
  print("active subs=" .. o:getCount())
end

--@api-stub: Throttle:onFire
do -- Throttle:onFire
  local t = lurek.patterns.newThrottle(0.5)
  t:onFire(function() print("tick at " .. os.time()) end)
  function lurek.process(dt) t:update(dt) end
end

--@api-stub: Throttle:update
do -- Throttle:update
  local t = lurek.patterns.newThrottle(0.25)
  t:onFire(function() print("autosave check") end)
  function lurek.process(dt) if t:update(dt) then print("just fired") end end
end

--@api-stub: Throttle:reset
do -- Throttle:reset
  local t = lurek.patterns.newThrottle(1.0)
  t:onFire(function() end)
  t:update(0.7)
  t:reset()
  print("progress after reset=" .. t:getProgress())
end

--@api-stub: Throttle:getProgress
do -- Throttle:getProgress
  local t = lurek.patterns.newThrottle(2.0)
  t:onFire(function() end)
  t:update(0.5)
  local pct = math.floor(t:getProgress() * 100)
  print("cooldown filled " .. pct .. "%")
end

--@api-stub: Throttle:getFireCount
do -- Throttle:getFireCount
  local t = lurek.patterns.newThrottle(0.1)
  t:onFire(function() end)
  for i = 1, 5 do t:update(0.1) end
  print("fires=" .. t:getFireCount())
end

--@api-stub: Throttle:setEnabled
do -- Throttle:setEnabled
  local t = lurek.patterns.newThrottle(0.5)
  t:onFire(function() print("fire") end)
  t:setEnabled(false)
  t:update(1.0)  -- no fire because disabled
  print("fires=" .. t:getFireCount())
end

--@api-stub: Debounce:onFire
do -- Debounce:onFire
  local d = lurek.patterns.newDebounce(0.3)
  d:onFire(function() print("settled") end)
  d:trigger()
  function lurek.process(dt) d:update(dt) end
end

--@api-stub: Debounce:trigger
do -- Debounce:trigger
  local d = lurek.patterns.newDebounce(0.5)
  d:onFire(function() print("autosave!") end)
  d:trigger()
  d:trigger()
  print("pending=" .. tostring(d:isPending()))
end

--@api-stub: Debounce:update
do -- Debounce:update
  local d = lurek.patterns.newDebounce(0.4)
  d:onFire(function() print("done typing") end)
  d:trigger()
  function lurek.process(dt) if d:update(dt) then print("fired") end end
end

--@api-stub: Debounce:cancel
do -- Debounce:cancel
  local d = lurek.patterns.newDebounce(1.0)
  d:onFire(function() print("commit") end)
  d:trigger()
  d:cancel()
  print("pending after cancel=" .. tostring(d:isPending()))
end

--@api-stub: Debounce:isPending
do -- Debounce:isPending
  local d = lurek.patterns.newDebounce(0.6)
  d:onFire(function() end)
  d:trigger()
  if d:isPending() then print("waiting for idle") end
end

--@api-stub: Debounce:getFireCount
do -- Debounce:getFireCount
  local d = lurek.patterns.newDebounce(0.1)
  d:onFire(function() end)
  d:trigger()
  d:update(0.2)
  print("fires=" .. d:getFireCount())
end

--@api-stub: PriorityQueue:push
do -- PriorityQueue:push
  local pq = lurek.patterns.newPriorityQueue("ai")
  pq:push(10, { kind = "patrol" }, "low")
  pq:push(50, { kind = "attack" }, "urgent")
  pq:push(20, { kind = "talk" }, "med")
  print("queued=" .. pq:len())
end

--@api-stub: PriorityQueue:pop
do -- PriorityQueue:pop
  local pq = lurek.patterns.newPriorityQueue()
  pq:push(1, "low"); pq:push(99, "high")
  local job = pq:pop()
  if job then print("running " .. job) end
end

--@api-stub: PriorityQueue:peek
do -- PriorityQueue:peek
  local pq = lurek.patterns.newPriorityQueue()
  pq:push(5, "build"); pq:push(20, "render")
  local next_job = pq:peek()
  if next_job then print("next: " .. next_job) end
end

--@api-stub: PriorityQueue:len
do -- PriorityQueue:len
  local pq = lurek.patterns.newPriorityQueue()
  pq:push(1, "a"); pq:push(2, "b"); pq:push(3, "c")
  if pq:len() > 100 then print("queue saturated") end
  print("size=" .. pq:len())
end

--@api-stub: PriorityQueue:isEmpty
do -- PriorityQueue:isEmpty
  local pq = lurek.patterns.newPriorityQueue()
  pq:push(1, "task")
  while not pq:isEmpty() do print("processing " .. pq:pop()) end
end

--@api-stub: PriorityQueue:clearAll
do -- PriorityQueue:clearAll
  local pq = lurek.patterns.newPriorityQueue()
  pq:push(1, "x"); pq:push(2, "y")
  pq:clearAll()
  print("after clear len=" .. pq:len())
end

--@api-stub: Ring:push
do -- Ring:push
  local r = lurek.patterns.newRing(8)
  for i = 1, 10 do r:push(i * 1.5, "sample") end
  print("len=" .. r:len() .. " full=" .. tostring(r:isFull()))
end

--@api-stub: Ring:latest
do -- Ring:latest
  local r = lurek.patterns.newRing(4)
  r:push("hello", "msg")
  r:push("world", "msg")
  local last = r:latest()
  if last then print("last text=" .. last.text) end
end

--@api-stub: Ring:toArray
do -- Ring:toArray
  local r = lurek.patterns.newRing(4)
  r:push(60, "fps"); r:push(58, "fps"); r:push(61, "fps")
  for _, e in ipairs(r:toArray()) do print(e.tag .. "=" .. e.value) end
end

--@api-stub: Ring:sum
do -- Ring:sum
  local r = lurek.patterns.newRing(16)
  for i = 1, 10 do r:push(i * 0.1, "lat") end
  print("total latency=" .. r:sum() .. "s")
end

--@api-stub: Ring:average
do -- Ring:average
  local r = lurek.patterns.newRing(60)
  for i = 1, 60 do r:push(58 + (i % 4), "fps") end
  print("avg fps=" .. string.format("%.1f", r:average()))
end

--@api-stub: Ring:len
do -- Ring:len
  local r = lurek.patterns.newRing(10)
  r:push(1, "x"); r:push(2, "x"); r:push(3, "x")
  if r:len() >= 3 then print("got enough samples") end
end

--@api-stub: Ring:isFull
do -- Ring:isFull
  local r = lurek.patterns.newRing(4)
  for i = 1, 4 do r:push(i, "v") end
  if r:isFull() then print("warm: avg=" .. r:average()) end
end

--@api-stub: Ring:clear
do -- Ring:clear
  local r = lurek.patterns.newRing(8)
  r:push(10, "x"); r:push(20, "x")
  r:clear()
  print("len after clear=" .. r:len())
end

--@api-stub: Funnel:onFlush
do -- Funnel:onFlush
  local f = lurek.patterns.newFunnel(1.0, 0)
  f:onFlush(function(batch) print("flushed " .. #batch .. " events") end)
  function lurek.process(dt) f:update(dt) end
end

--@api-stub: Funnel:push
do -- Funnel:push
  local f = lurek.patterns.newFunnel(0, 4)
  f:onFlush(function(b) print("batch=" .. #b) end)
  f:push("kill", 1); f:push("kill", 1); f:push("kill", 1); f:push("kill", 1)
  print("pending=" .. f:pendingCount())
end

--@api-stub: Funnel:update
do -- Funnel:update
  local f = lurek.patterns.newFunnel(0.5, 0)
  f:onFlush(function(b) print("auto flush " .. #b) end)
  f:push("hit", 5)
  function lurek.process(dt) if f:update(dt) then print("fired") end end
end

--@api-stub: Funnel:flush
do -- Funnel:flush
  local f = lurek.patterns.newFunnel(60.0, 0)
  f:onFlush(function(b) print("manual flush " .. #b) end)
  f:push("crash", 1)
  f:flush()
end

--@api-stub: Funnel:discard
do -- Funnel:discard
  local f = lurek.patterns.newFunnel(2.0, 0)
  f:onFlush(function() end)
  f:push("a", 1); f:push("b", 2)
  f:discard()
  print("pending after discard=" .. f:pendingCount())
end

--@api-stub: Funnel:pendingCount
do -- Funnel:pendingCount
  local f = lurek.patterns.newFunnel(5.0, 0)
  f:onFlush(function() end)
  f:push("x", 1); f:push("y", 2); f:push("z", 3)
  print("buffered=" .. f:pendingCount())
end

--@api-stub: Funnel:getFlushCount
do -- Funnel:getFlushCount
  local f = lurek.patterns.newFunnel(0, 1)
  f:onFlush(function() end)
  for i = 1, 3 do f:push("e", i) end
  print("flushes=" .. f:getFlushCount())
end

--@api-stub: RelationshipManager:defineType
do -- RelationshipManager:defineType
  local rm = lurek.patterns.newRelationshipManager()
  rm:defineType("faction", { "hostile", "neutral", "ally" }, "neutral")
  rm:defineType("trust", { "low", "med", "high" }, "low")
  print("types=" .. #rm:typeNames())
end

--@api-stub: RelationshipManager:removeType
do -- RelationshipManager:removeType
  local rm = lurek.patterns.newRelationshipManager()
  rm:defineType("temp", { "a", "b" }, "a")
  rm:removeType("temp")
  print("types left=" .. #rm:typeNames())
end

--@api-stub: RelationshipManager:typeNames
do -- RelationshipManager:typeNames
  local rm = lurek.patterns.newRelationshipManager()
  rm:defineType("diplomacy", { "war", "peace" }, "peace")
  rm:defineType("trade", { "off", "on" }, "off")
  for _, t in ipairs(rm:typeNames()) do print("type:" .. t) end
end

--@api-stub: RelationshipManager:setValue
do -- RelationshipManager:setValue
  local rm = lurek.patterns.newRelationshipManager()
  rm:setValue(101, 202, 35)
  print("v=" .. rm:getValue(101, 202))
  print("pairs=" .. rm:pairCount())
end

--@api-stub: RelationshipManager:getValue
do -- RelationshipManager:getValue
  local rm = lurek.patterns.newRelationshipManager()
  rm:setValue(1, 2, 50)
  local price_mult = 1.0 - rm:getValue(1, 2) * 0.005
  print("multiplier=" .. price_mult)
end

--@api-stub: RelationshipManager:adjustValue
do -- RelationshipManager:adjustValue
  local rm = lurek.patterns.newRelationshipManager()
  rm:setValue(1, 2, 0)
  rm:adjustValue(1, 2, 25)  -- gift accepted
  rm:adjustValue(1, 2, -10) -- minor offence
  print("net=" .. rm:getValue(1, 2))
end

--@api-stub: RelationshipManager:setLevel
do -- RelationshipManager:setLevel
  local rm = lurek.patterns.newRelationshipManager()
  rm:defineType("faction", { "hostile", "neutral", "ally" }, "neutral")
  local ok = rm:setLevel(1, 2, "faction", "ally")
  print("set ok=" .. tostring(ok))
end

--@api-stub: RelationshipManager:getLevel
do -- RelationshipManager:getLevel
  local rm = lurek.patterns.newRelationshipManager()
  rm:defineType("faction", { "hostile", "ally" }, "hostile")
  rm:setLevel(1, 2, "faction", "ally")
  local lvl = rm:getLevel(1, 2, "faction")
  if lvl == "ally" then print("hold fire") end
end

--@api-stub: RelationshipManager:removePair
do -- RelationshipManager:removePair
  local rm = lurek.patterns.newRelationshipManager()
  rm:setValue(1, 2, 50)
  rm:removePair(1, 2)
  print("pairs=" .. rm:pairCount())
end

--@api-stub: RelationshipManager:pairCount
do -- RelationshipManager:pairCount
  local rm = lurek.patterns.newRelationshipManager()
  rm:setValue(1, 2, 10); rm:setValue(2, 3, -10)
  if rm:pairCount() > 10000 then print("WARN large relationship graph") end
  print("pairs=" .. rm:pairCount())
end

--@api-stub: Mediator:on
do -- Mediator:on
  local m = lurek.patterns.newMediator()
  local id = m:on("net", function(msg) print("net msg: " .. msg) end)
  m:send("net", "hello")
  m:off("net", id)
end

--@api-stub: Mediator:off
do -- Mediator:off
  local m = lurek.patterns.newMediator()
  local id = m:on("ui", function() print("ui tick") end)
  m:off("ui", id)
  print("handlers=" .. m:handlerCount("ui"))
end

--@api-stub: Mediator:send
do -- Mediator:send
  local m = lurek.patterns.newMediator()
  m:on("damage", function(amount, src) print(src .. " hit for " .. amount) end)
  m:send("damage", 12, "spike_trap")
end

--@api-stub: Mediator:broadcast
do -- Mediator:broadcast
  local m = lurek.patterns.newMediator()
  m:on("audio", function(s) print("audio got " .. s) end)
  m:on("video", function(s) print("video got " .. s) end)
  m:broadcast("pause")
end

--@api-stub: Mediator:handlerCount
do -- Mediator:handlerCount
  local m = lurek.patterns.newMediator()
  m:on("save", function() end)
  m:on("save", function() end)
  print("save handlers=" .. m:handlerCount("save"))
end

--@api-stub: Mediator:channels
do -- Mediator:channels
  local m = lurek.patterns.newMediator()
  m:on("a", function() end); m:on("b", function() end)
  for _, c in ipairs(m:channels()) do print("ch:" .. c) end
end

--@api-stub: Mediator:removeChannel
do -- Mediator:removeChannel
  local m = lurek.patterns.newMediator()
  m:on("temp", function() end)
  m:removeChannel("temp")
  print("temp handlers=" .. m:handlerCount("temp"))
end

--@api-stub: Mediator:clear
do -- Mediator:clear
  local m = lurek.patterns.newMediator()
  m:on("x", function() end); m:on("y", function() end)
  m:clear()
  print("channels left=" .. #m:channels())
end

--@api-stub: Strategy:register
do -- Strategy:register
  local s = lurek.patterns.newStrategy()
  s:register("euclid", function(ax, ay, bx, by) return math.sqrt((ax-bx)^2 + (ay-by)^2) end)
  s:register("manhattan", function(ax, ay, bx, by) return math.abs(ax-bx) + math.abs(ay-by) end)
  print("strategies=" .. #s:names())
end

--@api-stub: Strategy:set
do -- Strategy:set
  local s = lurek.patterns.newStrategy()
  s:register("simple", function(x) return x * 2 end)
  local ok = s:set("simple")
  if not ok then print("strategy missing!") end
end

--@api-stub: Strategy:execute
do -- Strategy:execute
  local s = lurek.patterns.newStrategy()
  s:register("crit", function(atk, def) return atk * 2 - def end)
  s:set("crit")
  local dmg = s:execute(20, 5)
  print("dmg=" .. dmg)
end

--@api-stub: Strategy:getCurrent
do -- Strategy:getCurrent
  local s = lurek.patterns.newStrategy()
  s:register("normal", function(x) return x end)
  s:set("normal")
  local name = s:getCurrent()
  if name then print("active strategy: " .. name) end
end

--@api-stub: Strategy:has
do -- Strategy:has
  local s = lurek.patterns.newStrategy()
  s:register("legacy", function() end)
  if s:has("legacy") then s:set("legacy") end
end

--@api-stub: Strategy:remove
do -- Strategy:remove
  local s = lurek.patterns.newStrategy()
  s:register("old", function() end)
  local removed = s:remove("old")
  print("removed=" .. tostring(removed))
end

--@api-stub: Strategy:names
do -- Strategy:names
  local s = lurek.patterns.newStrategy()
  s:register("a", function() end); s:register("b", function() end)
  for _, n in ipairs(s:names()) do print("strat:" .. n) end
end

--@api-stub: Strategy:clear
do -- Strategy:clear
  local s = lurek.patterns.newStrategy()
  s:register("x", function() end)
  s:clear()
  print("strategies=" .. #s:names())
end

--@api-stub: Stack:push
do -- Stack:push
  local s = lurek.patterns.newStack(4)
  s:push("scene_main")
  s:push("scene_options")
  local ok = s:push("scene_extra")
  print("ok=" .. tostring(ok) .. " depth=" .. s:len())
end

--@api-stub: Stack:pop
do -- Stack:pop
  local s = lurek.patterns.newStack(0)
  s:push("menu"); s:push("game")
  local top = s:pop()
  print("popped " .. top .. ", new top=" .. (s:peek() or "<empty>"))
end

--@api-stub: Stack:peek
do -- Stack:peek
  local s = lurek.patterns.newStack(0)
  s:push("hud"); s:push("dialog")
  local top = s:peek()
  if top == "dialog" then print("dialog is showing") end
end

--@api-stub: Stack:len
do -- Stack:len
  local s = lurek.patterns.newStack(0)
  s:push("a"); s:push("b"); s:push("c")
  print("depth=" .. s:len())
end

--@api-stub: Stack:isEmpty
do -- Stack:isEmpty
  local s = lurek.patterns.newStack(0)
  s:push("only")
  s:pop()
  if s:isEmpty() then print("at root â€” quit to menu") end
end

--@api-stub: Stack:isFull
do -- Stack:isFull
  local s = lurek.patterns.newStack(2)
  s:push("a"); s:push("b")
  if s:isFull() then print("dialog stack saturated") end
end

--@api-stub: Stack:clear
do -- Stack:clear
  local s = lurek.patterns.newStack(0)
  s:push("a"); s:push("b")
  s:clear()
  print("len after clear=" .. s:len())
end

--@api-stub: Stack:toArray
do -- Stack:toArray
  local s = lurek.patterns.newStack(0)
  s:push("Main"); s:push("Options"); s:push("Audio")
  for i, v in ipairs(s:toArray()) do print(i .. ": " .. v) end
end

--@api-stub: Queue:enqueue
do -- Queue:enqueue
  local q = lurek.patterns.newQueue(0)
  q:enqueue("packet_a"); q:enqueue("packet_b")
  local ok = q:enqueue("packet_c")
  print("ok=" .. tostring(ok) .. " size=" .. q:len())
end

--@api-stub: Queue:dequeue
do -- Queue:dequeue
  local q = lurek.patterns.newQueue(0)
  q:enqueue("msg1"); q:enqueue("msg2")
  local m = q:dequeue()
  if m then print("processed " .. m) end
end

--@api-stub: Queue:front
do -- Queue:front
  local q = lurek.patterns.newQueue(0)
  q:enqueue("first"); q:enqueue("second")
  local f = q:front()
  if f then print("next is " .. f) end
end

--@api-stub: Queue:len
do -- Queue:len
  local q = lurek.patterns.newQueue(0)
  for i = 1, 4 do q:enqueue("e" .. i) end
  print("queue size=" .. q:len())
end

--@api-stub: Queue:isEmpty
do -- Queue:isEmpty
  local q = lurek.patterns.newQueue(0)
  q:enqueue("only")
  while not q:isEmpty() do print("got " .. q:dequeue()) end
end

--@api-stub: Queue:isFull
do -- Queue:isFull
  local q = lurek.patterns.newQueue(2)
  q:enqueue("a"); q:enqueue("b")
  if q:isFull() then print("dropping new inputs") end
end

--@api-stub: Queue:clear
do -- Queue:clear
  local q = lurek.patterns.newQueue(0)
  q:enqueue("x"); q:enqueue("y")
  q:clear()
  print("size after clear=" .. q:len())
end

--@api-stub: Queue:toArray
do -- Queue:toArray
  local q = lurek.patterns.newQueue(0)
  q:enqueue("a"); q:enqueue("b"); q:enqueue("c")
  for i, v in ipairs(q:toArray()) do print(i .. ": " .. v) end
end

--@api-stub: List:add
do -- List:add
  local l = lurek.patterns.newList()
  l:add("sword"); l:add("shield"); l:add("potion")
  print("inventory size=" .. l:len())
end

--@api-stub: List:get
do -- List:get
  local l = lurek.patterns.newList()
  l:add("apple"); l:add("bread")
  local item = l:get(1)
  if item then print("first: " .. item) end
end

--@api-stub: List:set
do -- List:set
  local l = lurek.patterns.newList()
  l:add("placeholder")
  l:set(1, "real_value")
  print("now: " .. l:get(1))
end

--@api-stub: List:remove
do -- List:remove
  local l = lurek.patterns.newList()
  l:add("a"); l:add("b"); l:add("c")
  local removed = l:remove(2)
  print("removed " .. removed .. ", remaining=" .. l:len())
end

--@api-stub: List:len
do -- List:len
  local l = lurek.patterns.newList()
  for i = 1, 5 do l:add("item_" .. i) end
  print("count=" .. l:len())
end

--@api-stub: List:isEmpty
do -- List:isEmpty
  local l = lurek.patterns.newList()
  if l:isEmpty() then print("inventory empty") end
  l:add("ring")
  print("after add empty=" .. tostring(l:isEmpty()))
end

--@api-stub: List:contains
do -- List:contains
  local l = lurek.patterns.newList()
  l:add("key"); l:add("map"); l:add("torch")
  if l:contains("key") then print("door can be opened") end
end

--@api-stub: List:clear
do -- List:clear
  local l = lurek.patterns.newList()
  l:add("x"); l:add("y")
  l:clear()
  print("len after clear=" .. l:len())
end

--@api-stub: List:toArray
do -- List:toArray
  local l = lurek.patterns.newList()
  l:add("a"); l:add("b"); l:add("c")
  for i, v in ipairs(l:toArray()) do print(i .. "=" .. v) end
end

--@api-stub: Set:add
do -- Set:add
  local s = lurek.patterns.newSet()
  local was_new = s:add("collected_gem")
  if was_new then print("first gem!") end
  s:add("collected_gem")  -- returns false on second add
end

--@api-stub: Set:remove
do -- Set:remove
  local s = lurek.patterns.newSet()
  s:add("buff_speed")
  local existed = s:remove("buff_speed")
  print("removed=" .. tostring(existed) .. " size=" .. s:len())
end

--@api-stub: Set:has
do -- Set:has
  local s = lurek.patterns.newSet()
  s:add("flying")
  if s:has("flying") then print("ignore gravity") end
end

--@api-stub: Set:len
do -- Set:len
  local s = lurek.patterns.newSet()
  s:add("orc"); s:add("goblin"); s:add("orc")
  print("unique enemies killed=" .. s:len())
end

--@api-stub: Set:isEmpty
do -- Set:isEmpty
  local s = lurek.patterns.newSet()
  if s:isEmpty() then print("no keys yet") end
  s:add("brass_key")
  print("empty=" .. tostring(s:isEmpty()))
end

--@api-stub: Set:toArray
do -- Set:toArray
  local s = lurek.patterns.newSet()
  s:add("red"); s:add("green"); s:add("blue")
  for _, k in ipairs(s:toArray()) do print("color:" .. k) end
end

--@api-stub: Set:clear
do -- Set:clear
  local s = lurek.patterns.newSet()
  s:add("seen_intro"); s:add("opened_chest")
  s:clear()
  print("size=" .. s:len())
end

--@api-stub: Set:union
do -- Set:union
  local a = lurek.patterns.newSet(); a:add("sword"); a:add("shield")
  local b = lurek.patterns.newSet(); b:add("shield"); b:add("bow")
  local both = a:union(b)
  print("union size=" .. both:len())
end

--@api-stub: Set:intersection
do -- Set:intersection
  local have = lurek.patterns.newSet(); have:add("key"); have:add("map")
  local need = lurek.patterns.newSet(); need:add("map"); need:add("torch")
  local got = have:intersection(need)
  print("matched needs=" .. got:len())
end

-- =============================================================================
-- COVERAGE: 150 uncovered lurek.patterns API item(s)
-- Generated by tools/audit/example_add_missing.py
-- REQUIRED: replace every --@api-stub: block below with a real scenario.
-- Run .github/prompts/flesh-out-example.prompt.md for instructions.
-- The final committed file must contain ZERO --@api-stub: lines.
-- =============================================================================


-- -----------------------------------------------------------------------------
-- LList methods
-- -----------------------------------------------------------------------------

--@api-stub: LList:add -- Append a value to the end of the list
do -- LList:add
  local lst = lurek.patterns.newList()
  lst:add("sword")
  lst:add("shield")
  lst:add("potion")
  lurek.log.info("list size=" .. lst:len(), "patterns")
end
--@api-stub: LList:get -- Get the value at a 1-based index
do -- LList:get
  local lst = lurek.patterns.newList()
  lst:add("apple")
  lst:add("banana")
  local item = lst:get(2)   -- 1-based index
  lurek.log.info("item[2]=" .. tostring(item), "patterns")
end
--@api-stub: LList:set -- Replace the value at a 1-based index
do -- LList:set
  local lst = lurek.patterns.newList()
  lst:add("iron_sword")
  lst:add("leather_boots")
  lst:set(1, "mythril_sword")
  lurek.log.info("slot 1=" .. tostring(lst:get(1)), "patterns")
end
--@api-stub: LList:remove -- Remove and return the value at a 1-based index
do -- LList:remove
  local lst = lurek.patterns.newList()
  lst:add("quest_a")
  lst:add("quest_b")
  lst:add("quest_c")
  local removed = lst:remove(2)
  lurek.log.info("removed=" .. tostring(removed) .. " remaining=" .. lst:len(), "patterns")
end
--@api-stub: LList:len -- Return the number of items in the list
do -- LList:len
  local lst = lurek.patterns.newList()
  for i = 1, 5 do lst:add(i * 10) end
  lurek.log.info("list length=" .. lst:len(), "patterns")
end
--@api-stub: LList:isEmpty -- Check whether the list is empty
do -- LList:isEmpty
  local lst = lurek.patterns.newList()
  lurek.log.info("before add: " .. tostring(lst:isEmpty()), "patterns")
  lst:add("item")
  lurek.log.info("after add: " .. tostring(lst:isEmpty()), "patterns")
end
--@api-stub: LList:contains -- Check whether the list contains a specific value
do -- LList:contains
  local lst = lurek.patterns.newList()
  lst:add("fire")
  lst:add("ice")
  lst:add("thunder")
  lurek.log.info("has fire: " .. tostring(lst:contains("fire")), "patterns")
  lurek.log.info("has wind: " .. tostring(lst:contains("wind")), "patterns")
end
--@api-stub: LList:clear -- Remove all items from the list
do -- LList:clear
  local lst = lurek.patterns.newList()
  lst:add("a")
  lst:add("b")
  lst:clear()
  lurek.log.info("length after clear=" .. lst:len(), "patterns")
end
--@api-stub: LList:toArray -- Return all items as an array table
do -- LList:toArray
  local lst = lurek.patterns.newList()
  lst:add(10)
  lst:add(20)
  lst:add(30)
  local arr = lst:toArray()
  lurek.log.info("arr[2]=" .. tostring(arr[2]), "patterns")
end

--@api-stub: new
do -- new factories
  local wr = lurek.patterns.newWeightedRandom()
  local bt = lurek.patterns.newBehaviorTree()
  local g = lurek.patterns.newGraph()
  if wr and bt and g then
    lurek.log.debug("new patterns factories ready", "patterns")
  end
end

--@api-stub: LWeightedRandom
do -- LWeightedRandom methods
  local wr = lurek.patterns.newWeightedRandom()
  local id_a = wr:add(1.0, "a", "low")
  local id_b = wr:add(9.0, "b", "high")
  wr:setWeight(id_a, 2.0)
  local one = wr:pick(0.3)
  local many = wr:pickN(2, { 0.1, 0.9 })
  local tw = wr:totalWeight()
  local n = wr:len()
  local empty = wr:isEmpty()
  local rev = wr:getRevision()
  wr:remove(id_b)
  wr:clearAll()
  lurek.log.debug(
    "wr sample=" .. tostring(one) .. " n=" .. tostring(n) .. " empty=" .. tostring(empty) .. " rev=" .. tostring(rev) .. " tw=" .. tostring(tw) .. " picks=" .. tostring(#many),
    "patterns"
  )
end

--@api-stub: LBehaviorTree
do -- LBehaviorTree methods
  local bt = lurek.patterns.newBehaviorTree()
  local seq = bt:addSequence("root-seq")
  local sel = bt:addSelector("fallback")
  local par = bt:addParallel(1, "parallel")
  local inv = bt:addInverter("invert")
  local rep = bt:addRepeat(2, "repeat")
  local leaf_ok = bt:addLeaf("ok", "ok-leaf")
  local leaf_fail = bt:addLeaf("fail", "fail-leaf")

  bt:addChild(seq, sel)
  bt:addChild(sel, par)
  bt:addChild(par, inv)
  bt:addChild(inv, rep)
  bt:addChild(rep, leaf_ok)
  bt:addChild(sel, leaf_fail)

  bt:setLeaf("ok", function() return "success" end)
  bt:setLeaf("fail", function() return "failure" end)
  bt:setRoot(seq)

  local status = bt:tick()
  local count = bt:nodeCount()
  bt:resetState()
  bt:clearAll()
  lurek.log.debug("bt status=" .. tostring(status) .. " nodes=" .. tostring(count), "patterns")
end

--@api-stub: LGraph
do -- LGraph methods
  local g = lurek.patterns.newGraph(true)
  local a = g:addNode("A", { hp = 10 })
  local b = g:addNode("B", { hp = 20 })
  local c = g:addNode("C", { hp = 30 })
  local eid = g:addEdge(a, b, 1.5, "road")
  g:addEdge(b, c, 2.0, "path")

  local val = g:getNodeValue(a)
  local nbs = g:neighbors(a)
  local bfs = g:bfs(a)
  local dfs = g:dfs(a)
  local conn = g:isConnected(a, c)
  local has = g:hasNode(c)
  local nc = g:nodeCount()
  local ec = g:edgeCount()

  g:removeEdge(eid)
  g:removeNode(c)
  g:clearAll()
  lurek.log.debug(
    "graph hp=" .. tostring(val and val.hp) .. " nbs=" .. tostring(#nbs) .. " bfs=" .. tostring(#bfs) .. " dfs=" .. tostring(#dfs) .. " conn=" .. tostring(conn) .. " has=" .. tostring(has) .. " nc=" .. tostring(nc) .. " ec=" .. tostring(ec),
    "patterns"
  )
end

--@api-stub: lurek.patterns.newMap -- Create a new string-keyed dictionary (map) with keys/values/entries access and merge support
do -- lurek.patterns.newMap
  local m = lurek.patterns.newMap()
  m:set("k", 1)
  print("map has k=" .. tostring(m:has("k")))
end

--@api-stub: LStack
do -- LStack extra methods
  local s = lurek.patterns.newStack(10)
  s:push("b")
  s:pushBottom("a")
  s:insertAt(3, "c")
  local bottom = s:peekBottom()
  local at2 = s:peekAt(2)
  s:moveWithin(3, 2)
  local removed = s:removeAt(2)
  local popped = s:popMany(1)
  local from_bottom = s:popBottom()
  lurek.log.debug(
    "stack extra bottom=" .. tostring(bottom) ..
    " at2=" .. tostring(at2) ..
    " removed=" .. tostring(removed) ..
    " popMany=" .. tostring(#popped) ..
    " popBottom=" .. tostring(from_bottom),
    "patterns"
  )
end

--@api-stub: LQueue
do -- LQueue extra methods
  local q = lurek.patterns.newQueue(10)
  q:enqueue("b")
  q:enqueueFront("a")
  q:enqueue("d")
  q:insertAt(3, "c")
  local b = q:back()
  local p = q:peekAt(2)
  local r = q:removeAt(3)
  local db = q:dequeueBack()
  lurek.log.debug(
    "queue extra back=" .. tostring(b) ..
    " peekAt=" .. tostring(p) ..
    " removeAt=" .. tostring(r) ..
    " dequeueBack=" .. tostring(db),
    "patterns"
  )
end

--@api-stub: LList
do -- LList extra methods
  local l = lurek.patterns.newList()
  l:push("b")
  l:unshift("a")
  l:insert(3, "c")
  local idx = l:indexOf("b")
  l:reverse()
  local p = l:pop()
  local s = l:shift()
  lurek.log.debug(
    "list extra idx=" .. tostring(idx) ..
    " pop=" .. tostring(p) ..
    " shift=" .. tostring(s),
    "patterns"
  )
end

--@api-stub: LMap
do -- LMap methods
  local a = lurek.patterns.newMap()
  a:set("hp", 10)
  a:set("name", "hero")
  local hp = a:get("hp")
  local has_hp = a:has("hp")
  local ln = a:len()
  local empty = a:isEmpty()
  local keys = a:keys()
  local values = a:values()
  local entries = a:entries()
  local b = lurek.patterns.newMap()
  b:set("hp", 20)
  b:set("mp", 7)
  a:merge(b)
  local removed = a:remove("name")
  a:clear()
  lurek.log.debug(
    "map hp=" .. tostring(hp) ..
    " has=" .. tostring(has_hp) ..
    " len=" .. tostring(ln) ..
    " empty=" .. tostring(empty) ..
    " keys=" .. tostring(#keys) ..
    " vals=" .. tostring(#values) ..
    " entries=" .. tostring(#entries) ..
    " removed=" .. tostring(removed),
    "patterns"
  )
end
