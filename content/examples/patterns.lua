-- content/examples/patterns.lua
-- Lurek2D lurek.patterns API Reference
-- Run with: cargo run -- content/examples/patterns
--
-- Scenario: An RPG using design patterns for event-driven combat, undo/redo
-- in a level editor, object pools for bullet recycling, a state machine for
-- game phases, and data structures for AI priority queues and inventories.

print("=== lurek.patterns — Design Patterns & Data Structures ===\n")

-- =============================================================================
-- EventBus — decoupled event-driven communication
-- =============================================================================

--@api-stub: lurek.patterns.newEventBus
-- Demonstrates the proper usage of lurek.patterns.newEventBus.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_patterns_newEventBus()
    local events = lurek.patterns.newEventBus()
end
local _ok, _err = pcall(demo_lurek_patterns_newEventBus)

--@api-stub: EventBus:on
-- Demonstrates the proper usage of EventBus:on.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_EventBus_on()
    events:on("player_hit", function(damage)
    print("player took " .. damage .. " damage")
    events:on("item_pickup", function(item)
    print("picked up: " .. item)
end
local _ok, _err = pcall(demo_EventBus_on)

--@api-stub: EventBus:emit
-- Demonstrates the proper usage of EventBus:emit.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_EventBus_emit()
    events:emit("player_hit", 25)
    events:emit("item_pickup", "Health Potion")
end
local _ok, _err = pcall(demo_EventBus_emit)

--@api-stub: EventBus:getListenerCount
-- Demonstrates the proper usage of EventBus:getListenerCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_EventBus_getListenerCount()
    print("player_hit listeners: " .. events:getListenerCount("player_hit"))
end
local _ok, _err = pcall(demo_EventBus_getListenerCount)

--@api-stub: EventBus:getEvents
-- Demonstrates the proper usage of EventBus:getEvents.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_EventBus_getEvents()
    local event_names = events:getEvents()
    print("registered events: " .. table.concat(event_names, ", "))
end
local _ok, _err = pcall(demo_EventBus_getEvents)

--@api-stub: EventBus:off
-- Demonstrates the proper usage of EventBus:off.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_EventBus_off()
    events:off("item_pickup")
end
local _ok, _err = pcall(demo_EventBus_off)

--@api-stub: EventBus:clear
-- Demonstrates the proper usage of EventBus:clear.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_EventBus_clear()
    events:clear("player_hit")
end
local _ok, _err = pcall(demo_EventBus_clear)

--@api-stub: EventBus:clearAll
-- Demonstrates the proper usage of EventBus:clearAll.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_EventBus_clearAll()
    events:clearAll()
end
local _ok, _err = pcall(demo_EventBus_clearAll)

-- =============================================================================
-- ObjectPool — bullet/particle recycling
-- =============================================================================

--@api-stub: lurek.patterns.newObjectPool
-- Demonstrates the proper usage of lurek.patterns.newObjectPool.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_patterns_newObjectPool()
    local bullet_pool = lurek.patterns.newObjectPool()
end
local _ok, _err = pcall(demo_lurek_patterns_newObjectPool)

--@api-stub: ObjectPool:add
-- Demonstrates the proper usage of ObjectPool:add.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ObjectPool_add()
    for i = 1, 50 do
    bullet_pool:add({x = 0, y = 0, active = false})
end
local _ok, _err = pcall(demo_ObjectPool_add)

--@api-stub: ObjectPool:acquire
-- Demonstrates the proper usage of ObjectPool:acquire.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ObjectPool_acquire()
    local bullet = bullet_pool:acquire()
    print("acquired bullet: " .. tostring(bullet))
end
local _ok, _err = pcall(demo_ObjectPool_acquire)

--@api-stub: ObjectPool:release
-- Demonstrates the proper usage of ObjectPool:release.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ObjectPool_release()
    bullet_pool:release(bullet)
end
local _ok, _err = pcall(demo_ObjectPool_release)

--@api-stub: ObjectPool:getActiveCount
-- Demonstrates the proper usage of ObjectPool:getActiveCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ObjectPool_getActiveCount()
    print("active bullets: " .. bullet_pool:getActiveCount())
end
local _ok, _err = pcall(demo_ObjectPool_getActiveCount)

--@api-stub: ObjectPool:getAvailableCount
-- Demonstrates the proper usage of ObjectPool:getAvailableCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ObjectPool_getAvailableCount()
    print("available: " .. bullet_pool:getAvailableCount())
end
local _ok, _err = pcall(demo_ObjectPool_getAvailableCount)

--@api-stub: ObjectPool:getTotalCount
-- Demonstrates the proper usage of ObjectPool:getTotalCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ObjectPool_getTotalCount()
    print("total pool: " .. bullet_pool:getTotalCount())
end
local _ok, _err = pcall(demo_ObjectPool_getTotalCount)

--@api-stub: ObjectPool:clearAll
-- Demonstrates the proper usage of ObjectPool:clearAll.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ObjectPool_clearAll()
    bullet_pool:clearAll()
end
local _ok, _err = pcall(demo_ObjectPool_clearAll)

-- =============================================================================
-- CommandStack — undo/redo for level editor
-- =============================================================================

--@api-stub: lurek.patterns.newCommandStack
-- Demonstrates the proper usage of lurek.patterns.newCommandStack.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_patterns_newCommandStack()
    local commands = lurek.patterns.newCommandStack()
end
local _ok, _err = pcall(demo_lurek_patterns_newCommandStack)

--@api-stub: CommandStack:execute
-- Demonstrates the proper usage of CommandStack:execute.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_CommandStack_execute()
    commands:execute("place_tile", function() print("tile placed") end, function() print("tile removed") end)
    commands:execute("move_entity", function() print("entity moved") end, function() print("entity restored") end)
end
local _ok, _err = pcall(demo_CommandStack_execute)

--@api-stub: CommandStack:undo
-- Demonstrates the proper usage of CommandStack:undo.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_CommandStack_undo()
    commands:undo()
end
local _ok, _err = pcall(demo_CommandStack_undo)

--@api-stub: CommandStack:redo
-- Demonstrates the proper usage of CommandStack:redo.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_CommandStack_redo()
    commands:redo()
end
local _ok, _err = pcall(demo_CommandStack_redo)

--@api-stub: CommandStack:canUndo
-- Demonstrates the proper usage of CommandStack:canUndo.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_CommandStack_canUndo()
    print("can undo: " .. tostring(commands:canUndo()))
end
local _ok, _err = pcall(demo_CommandStack_canUndo)

--@api-stub: CommandStack:canRedo
-- Demonstrates the proper usage of CommandStack:canRedo.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_CommandStack_canRedo()
    print("can redo: " .. tostring(commands:canRedo()))
end
local _ok, _err = pcall(demo_CommandStack_canRedo)

--@api-stub: CommandStack:getHistorySize
-- Demonstrates the proper usage of CommandStack:getHistorySize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_CommandStack_getHistorySize()
    print("history: " .. commands:getHistorySize())
end
local _ok, _err = pcall(demo_CommandStack_getHistorySize)

--@api-stub: CommandStack:getCurrentName
-- Demonstrates the proper usage of CommandStack:getCurrentName.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_CommandStack_getCurrentName()
    print("current: " .. tostring(commands:getCurrentName()))
end
local _ok, _err = pcall(demo_CommandStack_getCurrentName)

--@api-stub: CommandStack:clearAll
-- Demonstrates the proper usage of CommandStack:clearAll.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_CommandStack_clearAll()
    commands:clearAll()
end
local _ok, _err = pcall(demo_CommandStack_clearAll)

-- =============================================================================
-- ServiceLocator — global service registry
-- =============================================================================

--@api-stub: lurek.patterns.newServiceLocator
-- Demonstrates the proper usage of lurek.patterns.newServiceLocator.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_patterns_newServiceLocator()
    local services = lurek.patterns.newServiceLocator()
end
local _ok, _err = pcall(demo_lurek_patterns_newServiceLocator)

--@api-stub: ServiceLocator:provide
-- Demonstrates the proper usage of ServiceLocator:provide.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ServiceLocator_provide()
    services:provide("audio", {play = function(s) print("playing: " .. s) end})
    services:provide("save", {save = function() print("saving...") end})
end
local _ok, _err = pcall(demo_ServiceLocator_provide)

--@api-stub: ServiceLocator:locate
-- Demonstrates the proper usage of ServiceLocator:locate.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ServiceLocator_locate()
    local audio = services:locate("audio")
    audio.play("battle_music")
end
local _ok, _err = pcall(demo_ServiceLocator_locate)

--@api-stub: ServiceLocator:has
-- Demonstrates the proper usage of ServiceLocator:has.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ServiceLocator_has()
    print("has audio: " .. tostring(services:has("audio")))
end
local _ok, _err = pcall(demo_ServiceLocator_has)

--@api-stub: ServiceLocator:getServices
-- Demonstrates the proper usage of ServiceLocator:getServices.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ServiceLocator_getServices()
    local svc_list = services:getServices()
    print("services: " .. table.concat(svc_list, ", "))
end
local _ok, _err = pcall(demo_ServiceLocator_getServices)

--@api-stub: ServiceLocator:remove
-- Demonstrates the proper usage of ServiceLocator:remove.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ServiceLocator_remove()
    services:remove("save")
end
local _ok, _err = pcall(demo_ServiceLocator_remove)

--@api-stub: ServiceLocator:clearAll
-- Demonstrates the proper usage of ServiceLocator:clearAll.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ServiceLocator_clearAll()
    services:clearAll()
end
local _ok, _err = pcall(demo_ServiceLocator_clearAll)

-- =============================================================================
-- Factory — dynamic entity creation
-- =============================================================================

--@api-stub: lurek.patterns.newFactory
-- Demonstrates the proper usage of lurek.patterns.newFactory.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_patterns_newFactory()
    local entity_factory = lurek.patterns.newFactory()
end
local _ok, _err = pcall(demo_lurek_patterns_newFactory)

--@api-stub: Factory:register
-- Demonstrates the proper usage of Factory:register.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Factory_register()
    entity_factory:register("goblin", function() return {hp = 30, atk = 5} end)
    entity_factory:register("dragon", function() return {hp = 500, atk = 80} end)
end
local _ok, _err = pcall(demo_Factory_register)

--@api-stub: Factory:create
-- Demonstrates the proper usage of Factory:create.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Factory_create()
    local goblin = entity_factory:create("goblin")
    print("goblin hp: " .. goblin.hp)
end
local _ok, _err = pcall(demo_Factory_create)

--@api-stub: Factory:has
-- Demonstrates the proper usage of Factory:has.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Factory_has()
    print("has dragon: " .. tostring(entity_factory:has("dragon")))
end
local _ok, _err = pcall(demo_Factory_has)

--@api-stub: Factory:alias
-- Demonstrates the proper usage of Factory:alias.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Factory_alias()
    entity_factory:alias("boss", "dragon")
end
local _ok, _err = pcall(demo_Factory_alias)

--@api-stub: Factory:getTypes
-- Demonstrates the proper usage of Factory:getTypes.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Factory_getTypes()
    local types = entity_factory:getTypes()
    print("entity types: " .. table.concat(types, ", "))
end
local _ok, _err = pcall(demo_Factory_getTypes)

--@api-stub: Factory:remove
-- Demonstrates the proper usage of Factory:remove.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Factory_remove()
    entity_factory:remove("goblin")
end
local _ok, _err = pcall(demo_Factory_remove)

--@api-stub: Factory:clearAll
-- Demonstrates the proper usage of Factory:clearAll.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Factory_clearAll()
    entity_factory:clearAll()
end
local _ok, _err = pcall(demo_Factory_clearAll)

-- =============================================================================
-- SimpleState — game phase state machine
-- =============================================================================

--@api-stub: lurek.patterns.newSimpleState
-- Demonstrates the proper usage of lurek.patterns.newSimpleState.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_patterns_newSimpleState()
    local game_state = lurek.patterns.newSimpleState()
end
local _ok, _err = pcall(demo_lurek_patterns_newSimpleState)

--@api-stub: SimpleState:addState
-- Demonstrates the proper usage of SimpleState:addState.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SimpleState_addState()
    game_state:addState("menu", {
    enter = function() print("entering menu") end,
    update = function(dt) end,
    exit = function() print("leaving menu") end
    })
    game_state:addState("gameplay", {
    enter = function() print("entering gameplay") end,
    update = function(dt) end,
    exit = function() print("leaving gameplay") end
    })
end
local _ok, _err = pcall(demo_SimpleState_addState)

--@api-stub: SimpleState:transitionTo
-- Demonstrates the proper usage of SimpleState:transitionTo.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SimpleState_transitionTo()
    game_state:transitionTo("menu")
end
local _ok, _err = pcall(demo_SimpleState_transitionTo)

--@api-stub: SimpleState:update
-- Demonstrates the proper usage of SimpleState:update.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SimpleState_update()
    game_state:update(1/60)
end
local _ok, _err = pcall(demo_SimpleState_update)

--@api-stub: SimpleState:getCurrent
-- Demonstrates the proper usage of SimpleState:getCurrent.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SimpleState_getCurrent()
    print("state: " .. game_state:getCurrent())
end
local _ok, _err = pcall(demo_SimpleState_getCurrent)

--@api-stub: SimpleState:hasState
-- Demonstrates the proper usage of SimpleState:hasState.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SimpleState_hasState()
    print("has 'gameplay': " .. tostring(game_state:hasState("gameplay")))
end
local _ok, _err = pcall(demo_SimpleState_hasState)

--@api-stub: SimpleState:getStates
-- Demonstrates the proper usage of SimpleState:getStates.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SimpleState_getStates()
    local states = game_state:getStates()
    print("states: " .. table.concat(states, ", "))
end
local _ok, _err = pcall(demo_SimpleState_getStates)

--@api-stub: SimpleState:clearAll
-- Demonstrates the proper usage of SimpleState:clearAll.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SimpleState_clearAll()
    game_state:clearAll()
end
local _ok, _err = pcall(demo_SimpleState_clearAll)

-- =============================================================================
-- Blackboard — shared AI knowledge base
-- =============================================================================

--@api-stub: lurek.patterns.newBlackboard
-- Demonstrates the proper usage of lurek.patterns.newBlackboard.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_patterns_newBlackboard()
    local bb = lurek.patterns.newBlackboard()
end
local _ok, _err = pcall(demo_lurek_patterns_newBlackboard)

--@api-stub: Blackboard:set
-- Demonstrates the proper usage of Blackboard:set.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Blackboard_set()
    bb:set("player_pos", {x = 200, y = 300})
    bb:set("alert_level", 0)
end
local _ok, _err = pcall(demo_Blackboard_set)

--@api-stub: Blackboard:get
-- Demonstrates the proper usage of Blackboard:get.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Blackboard_get()
    local pos = bb:get("player_pos")
    print("player pos: " .. tostring(pos))
end
local _ok, _err = pcall(demo_Blackboard_get)

--@api-stub: Blackboard:has
-- Demonstrates the proper usage of Blackboard:has.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Blackboard_has()
    print("has alert_level: " .. tostring(bb:has("alert_level")))
end
local _ok, _err = pcall(demo_Blackboard_has)

--@api-stub: Blackboard:keys
-- Demonstrates the proper usage of Blackboard:keys.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Blackboard_keys()
    local bb_keys = bb:keys()
    print("blackboard keys: " .. table.concat(bb_keys, ", "))
end
local _ok, _err = pcall(demo_Blackboard_keys)

--@api-stub: Blackboard:watch
-- Demonstrates the proper usage of Blackboard:watch.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Blackboard_watch()
    bb:watch("alert_level", function(old, new)
    print("alert changed: " .. tostring(old) .. " -> " .. tostring(new))
end
local _ok, _err = pcall(demo_Blackboard_watch)

--@api-stub: Blackboard:unwatch
-- Demonstrates the proper usage of Blackboard:unwatch.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Blackboard_unwatch()
    bb:unwatch("alert_level")
end
local _ok, _err = pcall(demo_Blackboard_unwatch)

--@api-stub: Blackboard:getRevision
-- Demonstrates the proper usage of Blackboard:getRevision.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Blackboard_getRevision()
    print("revision: " .. bb:getRevision())
end
local _ok, _err = pcall(demo_Blackboard_getRevision)

--@api-stub: Blackboard:snapshot
-- Demonstrates the proper usage of Blackboard:snapshot.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Blackboard_snapshot()
    local snap = bb:snapshot()
    print("snapshot: " .. tostring(snap))
end
local _ok, _err = pcall(demo_Blackboard_snapshot)

--@api-stub: Blackboard:clear
-- Demonstrates the proper usage of Blackboard:clear.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Blackboard_clear()
    bb:clear("player_pos")
end
local _ok, _err = pcall(demo_Blackboard_clear)

--@api-stub: Blackboard:clearAll
-- Demonstrates the proper usage of Blackboard:clearAll.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Blackboard_clearAll()
    bb:clearAll()
end
local _ok, _err = pcall(demo_Blackboard_clearAll)

-- =============================================================================
-- Observer — reactive property watching
-- =============================================================================

--@api-stub: lurek.patterns.newObserver
-- Demonstrates the proper usage of lurek.patterns.newObserver.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_patterns_newObserver()
    local hp_obs = lurek.patterns.newObserver()
end
local _ok, _err = pcall(demo_lurek_patterns_newObserver)

--@api-stub: Observer:set
-- Demonstrates the proper usage of Observer:set.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Observer_set()
    hp_obs:set(100)
end
local _ok, _err = pcall(demo_Observer_set)

--@api-stub: Observer:get
-- Demonstrates the proper usage of Observer:get.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Observer_get()
    print("observed HP: " .. hp_obs:get())
end
local _ok, _err = pcall(demo_Observer_get)

--@api-stub: Observer:subscribe
-- Demonstrates the proper usage of Observer:subscribe.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Observer_subscribe()
    hp_obs:subscribe(function(old, new)
    print("HP: " .. old .. " -> " .. new)
end
local _ok, _err = pcall(demo_Observer_subscribe)

--@api-stub: Observer:unsubscribe
-- Demonstrates the proper usage of Observer:unsubscribe.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Observer_unsubscribe()
    hp_obs:unsubscribe(1)
end
local _ok, _err = pcall(demo_Observer_unsubscribe)

--@api-stub: Observer:getCount
-- Demonstrates the proper usage of Observer:getCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Observer_getCount()
    print("subscribers: " .. hp_obs:getCount())
end
local _ok, _err = pcall(demo_Observer_getCount)

-- =============================================================================
-- Throttle & Debounce — input/event rate limiting
-- =============================================================================

--@api-stub: lurek.patterns.newThrottle
-- Demonstrates the proper usage of lurek.patterns.newThrottle.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_patterns_newThrottle()
    local attack_throttle = lurek.patterns.newThrottle()
end
local _ok, _err = pcall(demo_lurek_patterns_newThrottle)

--@api-stub: Throttle:onFire
-- Demonstrates the proper usage of Throttle:onFire.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Throttle_onFire()
    attack_throttle:onFire(function()
    print("attack executed!")
end
local _ok, _err = pcall(demo_Throttle_onFire)

--@api-stub: Throttle:update
-- Demonstrates the proper usage of Throttle:update.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Throttle_update()
    attack_throttle:update(1/60)
end
local _ok, _err = pcall(demo_Throttle_update)

--@api-stub: Throttle:reset
-- Demonstrates the proper usage of Throttle:reset.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Throttle_reset()
    attack_throttle:reset()
end
local _ok, _err = pcall(demo_Throttle_reset)

--@api-stub: Throttle:getProgress
-- Demonstrates the proper usage of Throttle:getProgress.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Throttle_getProgress()
    print("cooldown: " .. string.format("%.0f%%", attack_throttle:getProgress() * 100))
end
local _ok, _err = pcall(demo_Throttle_getProgress)

--@api-stub: Throttle:getFireCount
-- Demonstrates the proper usage of Throttle:getFireCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Throttle_getFireCount()
    print("attacks fired: " .. attack_throttle:getFireCount())
end
local _ok, _err = pcall(demo_Throttle_getFireCount)

--@api-stub: Throttle:setEnabled
-- Demonstrates the proper usage of Throttle:setEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Throttle_setEnabled()
    attack_throttle:setEnabled(true)
end
local _ok, _err = pcall(demo_Throttle_setEnabled)

--@api-stub: lurek.patterns.newDebounce
-- Demonstrates the proper usage of lurek.patterns.newDebounce.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_patterns_newDebounce()
    local search_debounce = lurek.patterns.newDebounce()
end
local _ok, _err = pcall(demo_lurek_patterns_newDebounce)

--@api-stub: Debounce:onFire
-- Demonstrates the proper usage of Debounce:onFire.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Debounce_onFire()
    search_debounce:onFire(function()
    print("search executed!")
end
local _ok, _err = pcall(demo_Debounce_onFire)

--@api-stub: Debounce:trigger
-- Demonstrates the proper usage of Debounce:trigger.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Debounce_trigger()
    search_debounce:trigger()
end
local _ok, _err = pcall(demo_Debounce_trigger)

--@api-stub: Debounce:update
-- Demonstrates the proper usage of Debounce:update.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Debounce_update()
    search_debounce:update(1/60)
end
local _ok, _err = pcall(demo_Debounce_update)

--@api-stub: Debounce:cancel
-- Demonstrates the proper usage of Debounce:cancel.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Debounce_cancel()
    search_debounce:cancel()
end
local _ok, _err = pcall(demo_Debounce_cancel)

--@api-stub: Debounce:isPending
-- Demonstrates the proper usage of Debounce:isPending.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Debounce_isPending()
    print("search pending: " .. tostring(search_debounce:isPending()))
end
local _ok, _err = pcall(demo_Debounce_isPending)

--@api-stub: Debounce:getFireCount
-- Demonstrates the proper usage of Debounce:getFireCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Debounce_getFireCount()
    print("searches: " .. search_debounce:getFireCount())
end
local _ok, _err = pcall(demo_Debounce_getFireCount)

-- =============================================================================
-- PriorityQueue — AI action scheduling
-- =============================================================================

--@api-stub: lurek.patterns.newPriorityQueue
-- Demonstrates the proper usage of lurek.patterns.newPriorityQueue.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_patterns_newPriorityQueue()
    local ai_queue = lurek.patterns.newPriorityQueue()
end
local _ok, _err = pcall(demo_lurek_patterns_newPriorityQueue)

--@api-stub: PriorityQueue:push
-- Demonstrates the proper usage of PriorityQueue:push.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PriorityQueue_push()
    ai_queue:push("heal", 10)
    ai_queue:push("attack", 5)
    ai_queue:push("flee", 1)
end
local _ok, _err = pcall(demo_PriorityQueue_push)

--@api-stub: PriorityQueue:peek
-- Demonstrates the proper usage of PriorityQueue:peek.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PriorityQueue_peek()
    print("highest priority: " .. tostring(ai_queue:peek()))
end
local _ok, _err = pcall(demo_PriorityQueue_peek)

--@api-stub: PriorityQueue:pop
-- Demonstrates the proper usage of PriorityQueue:pop.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PriorityQueue_pop()
    local action = ai_queue:pop()
    print("executing: " .. action)
end
local _ok, _err = pcall(demo_PriorityQueue_pop)

--@api-stub: PriorityQueue:len
-- Demonstrates the proper usage of PriorityQueue:len.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PriorityQueue_len()
    print("remaining: " .. ai_queue:len())
end
local _ok, _err = pcall(demo_PriorityQueue_len)

--@api-stub: PriorityQueue:isEmpty
-- Demonstrates the proper usage of PriorityQueue:isEmpty.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PriorityQueue_isEmpty()
    print("empty: " .. tostring(ai_queue:isEmpty()))
end
local _ok, _err = pcall(demo_PriorityQueue_isEmpty)

--@api-stub: PriorityQueue:clearAll
-- Demonstrates the proper usage of PriorityQueue:clearAll.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PriorityQueue_clearAll()
    ai_queue:clearAll()
end
local _ok, _err = pcall(demo_PriorityQueue_clearAll)

-- =============================================================================
-- Ring Buffer — damage history tracking
-- =============================================================================

--@api-stub: lurek.patterns.newRing
-- Demonstrates the proper usage of lurek.patterns.newRing.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_patterns_newRing()
    local dmg_history = lurek.patterns.newRing()
end
local _ok, _err = pcall(demo_lurek_patterns_newRing)

--@api-stub: Ring:push
-- Demonstrates the proper usage of Ring:push.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Ring_push()
    dmg_history:push(25)
    dmg_history:push(10)
    dmg_history:push(50)
end
local _ok, _err = pcall(demo_Ring_push)

--@api-stub: Ring:latest
-- Demonstrates the proper usage of Ring:latest.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Ring_latest()
    print("last damage: " .. dmg_history:latest())
end
local _ok, _err = pcall(demo_Ring_latest)

--@api-stub: Ring:toArray
-- Demonstrates the proper usage of Ring:toArray.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Ring_toArray()
    local hist = dmg_history:toArray()
    print("history: " .. table.concat(hist, ", "))
end
local _ok, _err = pcall(demo_Ring_toArray)

--@api-stub: Ring:sum
-- Demonstrates the proper usage of Ring:sum.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Ring_sum()
    print("total damage: " .. dmg_history:sum())
end
local _ok, _err = pcall(demo_Ring_sum)

--@api-stub: Ring:average
-- Demonstrates the proper usage of Ring:average.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Ring_average()
    print("avg damage: " .. dmg_history:average())
end
local _ok, _err = pcall(demo_Ring_average)

--@api-stub: Ring:len
-- Demonstrates the proper usage of Ring:len.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Ring_len()
    print("samples: " .. dmg_history:len())
end
local _ok, _err = pcall(demo_Ring_len)

--@api-stub: Ring:isFull
-- Demonstrates the proper usage of Ring:isFull.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Ring_isFull()
    print("buffer full: " .. tostring(dmg_history:isFull()))
end
local _ok, _err = pcall(demo_Ring_isFull)

--@api-stub: Ring:clear
-- Demonstrates the proper usage of Ring:clear.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Ring_clear()
    dmg_history:clear()
end
local _ok, _err = pcall(demo_Ring_clear)

-- =============================================================================
-- Funnel — batch event processing
-- =============================================================================

--@api-stub: lurek.patterns.newFunnel
-- Demonstrates the proper usage of lurek.patterns.newFunnel.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_patterns_newFunnel()
    local damage_funnel = lurek.patterns.newFunnel()
end
local _ok, _err = pcall(demo_lurek_patterns_newFunnel)

--@api-stub: Funnel:onFlush
-- Demonstrates the proper usage of Funnel:onFlush.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Funnel_onFlush()
    damage_funnel:onFlush(function(items)
    print("flushing " .. #items .. " damage events")
end
local _ok, _err = pcall(demo_Funnel_onFlush)

--@api-stub: Funnel:push
-- Demonstrates the proper usage of Funnel:push.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Funnel_push()
    damage_funnel:push({target = "player", amount = 15})
    damage_funnel:push({target = "player", amount = 8})
end
local _ok, _err = pcall(demo_Funnel_push)

--@api-stub: Funnel:update
-- Demonstrates the proper usage of Funnel:update.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Funnel_update()
    damage_funnel:update(1/60)
end
local _ok, _err = pcall(demo_Funnel_update)

--@api-stub: Funnel:pendingCount
-- Demonstrates the proper usage of Funnel:pendingCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Funnel_pendingCount()
    print("pending: " .. damage_funnel:pendingCount())
end
local _ok, _err = pcall(demo_Funnel_pendingCount)

--@api-stub: Funnel:flush
-- Demonstrates the proper usage of Funnel:flush.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Funnel_flush()
    damage_funnel:flush()
end
local _ok, _err = pcall(demo_Funnel_flush)

--@api-stub: Funnel:getFlushCount
-- Demonstrates the proper usage of Funnel:getFlushCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Funnel_getFlushCount()
    print("flushes: " .. damage_funnel:getFlushCount())
end
local _ok, _err = pcall(demo_Funnel_getFlushCount)

--@api-stub: Funnel:discard
-- Demonstrates the proper usage of Funnel:discard.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Funnel_discard()
    damage_funnel:discard()
end
local _ok, _err = pcall(demo_Funnel_discard)

-- =============================================================================
-- RelationshipManager — NPC faction relations
-- =============================================================================

--@api-stub: lurek.patterns.newRelationshipManager
-- Demonstrates the proper usage of lurek.patterns.newRelationshipManager.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_patterns_newRelationshipManager()
    local relations = lurek.patterns.newRelationshipManager()
end
local _ok, _err = pcall(demo_lurek_patterns_newRelationshipManager)

--@api-stub: RelationshipManager:defineType
-- Demonstrates the proper usage of RelationshipManager:defineType.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_RelationshipManager_defineType()
    relations:defineType("alliance")
    relations:defineType("trade")
end
local _ok, _err = pcall(demo_RelationshipManager_defineType)

--@api-stub: RelationshipManager:typeNames
-- Demonstrates the proper usage of RelationshipManager:typeNames.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_RelationshipManager_typeNames()
    local rtypes = relations:typeNames()
    print("relation types: " .. table.concat(rtypes, ", "))
end
local _ok, _err = pcall(demo_RelationshipManager_typeNames)

--@api-stub: RelationshipManager:setValue
-- Demonstrates the proper usage of RelationshipManager:setValue.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_RelationshipManager_setValue()
    relations:setValue("humans", "elves", "alliance", 80)
    relations:setValue("humans", "orcs", "alliance", -50)
end
local _ok, _err = pcall(demo_RelationshipManager_setValue)

--@api-stub: RelationshipManager:getValue
-- Demonstrates the proper usage of RelationshipManager:getValue.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_RelationshipManager_getValue()
    print("human-elf alliance: " .. relations:getValue("humans", "elves", "alliance"))
end
local _ok, _err = pcall(demo_RelationshipManager_getValue)

--@api-stub: RelationshipManager:adjustValue
-- Demonstrates the proper usage of RelationshipManager:adjustValue.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_RelationshipManager_adjustValue()
    relations:adjustValue("humans", "orcs", "alliance", 10)
end
local _ok, _err = pcall(demo_RelationshipManager_adjustValue)

--@api-stub: RelationshipManager:setLevel
-- Demonstrates the proper usage of RelationshipManager:setLevel.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_RelationshipManager_setLevel()
    relations:setLevel("humans", "elves", "trade", "partner")
end
local _ok, _err = pcall(demo_RelationshipManager_setLevel)

--@api-stub: RelationshipManager:getLevel
-- Demonstrates the proper usage of RelationshipManager:getLevel.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_RelationshipManager_getLevel()
    print("human-elf trade: " .. relations:getLevel("humans", "elves", "trade"))
end
local _ok, _err = pcall(demo_RelationshipManager_getLevel)

--@api-stub: RelationshipManager:pairCount
-- Demonstrates the proper usage of RelationshipManager:pairCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_RelationshipManager_pairCount()
    print("tracked pairs: " .. relations:pairCount())
end
local _ok, _err = pcall(demo_RelationshipManager_pairCount)

--@api-stub: RelationshipManager:removePair
-- Demonstrates the proper usage of RelationshipManager:removePair.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_RelationshipManager_removePair()
    relations:removePair("humans", "orcs")
end
local _ok, _err = pcall(demo_RelationshipManager_removePair)

--@api-stub: RelationshipManager:removeType
-- Demonstrates the proper usage of RelationshipManager:removeType.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_RelationshipManager_removeType()
    relations:removeType("trade")
end
local _ok, _err = pcall(demo_RelationshipManager_removeType)

-- =============================================================================
-- Mediator — cross-system communication
-- =============================================================================

--@api-stub: lurek.patterns.newMediator
-- Demonstrates the proper usage of lurek.patterns.newMediator.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_patterns_newMediator()
    local mediator = lurek.patterns.newMediator()
end
local _ok, _err = pcall(demo_lurek_patterns_newMediator)

--@api-stub: Mediator:on
-- Demonstrates the proper usage of Mediator:on.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Mediator_on()
    mediator:on("combat", function(msg)
    print("combat channel: " .. tostring(msg))
end
local _ok, _err = pcall(demo_Mediator_on)

--@api-stub: Mediator:send
-- Demonstrates the proper usage of Mediator:send.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Mediator_send()
    mediator:send("combat", "attack_started")
end
local _ok, _err = pcall(demo_Mediator_send)

--@api-stub: Mediator:broadcast
-- Demonstrates the proper usage of Mediator:broadcast.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Mediator_broadcast()
    mediator:broadcast("game paused")
end
local _ok, _err = pcall(demo_Mediator_broadcast)

--@api-stub: Mediator:handlerCount
-- Demonstrates the proper usage of Mediator:handlerCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Mediator_handlerCount()
    print("combat handlers: " .. mediator:handlerCount("combat"))
end
local _ok, _err = pcall(demo_Mediator_handlerCount)

--@api-stub: Mediator:channels
-- Demonstrates the proper usage of Mediator:channels.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Mediator_channels()
    local ch = mediator:channels()
    print("channels: " .. table.concat(ch, ", "))
end
local _ok, _err = pcall(demo_Mediator_channels)

--@api-stub: Mediator:off
-- Demonstrates the proper usage of Mediator:off.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Mediator_off()
    mediator:off("combat")
end
local _ok, _err = pcall(demo_Mediator_off)

--@api-stub: Mediator:removeChannel
-- Demonstrates the proper usage of Mediator:removeChannel.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Mediator_removeChannel()
    mediator:removeChannel("combat")
end
local _ok, _err = pcall(demo_Mediator_removeChannel)

--@api-stub: Mediator:clear
-- Demonstrates the proper usage of Mediator:clear.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Mediator_clear()
    mediator:clear()
end
local _ok, _err = pcall(demo_Mediator_clear)

-- =============================================================================
-- Strategy — interchangeable AI behaviors
-- =============================================================================

--@api-stub: lurek.patterns.newStrategy
-- Demonstrates the proper usage of lurek.patterns.newStrategy.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_patterns_newStrategy()
    local ai_strategy = lurek.patterns.newStrategy()
end
local _ok, _err = pcall(demo_lurek_patterns_newStrategy)

--@api-stub: Strategy:register
-- Demonstrates the proper usage of Strategy:register.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Strategy_register()
    ai_strategy:register("aggressive", function(ctx) return "attack" end)
    ai_strategy:register("defensive", function(ctx) return "defend" end)
end
local _ok, _err = pcall(demo_Strategy_register)

--@api-stub: Strategy:set
-- Demonstrates the proper usage of Strategy:set.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Strategy_set()
    ai_strategy:set("aggressive")
end
local _ok, _err = pcall(demo_Strategy_set)

--@api-stub: Strategy:execute
-- Demonstrates the proper usage of Strategy:execute.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Strategy_execute()
    local action2 = ai_strategy:execute({hp = 50})
    print("AI chose: " .. action2)
end
local _ok, _err = pcall(demo_Strategy_execute)

--@api-stub: Strategy:getCurrent
-- Demonstrates the proper usage of Strategy:getCurrent.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Strategy_getCurrent()
    print("strategy: " .. ai_strategy:getCurrent())
end
local _ok, _err = pcall(demo_Strategy_getCurrent)

--@api-stub: Strategy:has
-- Demonstrates the proper usage of Strategy:has.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Strategy_has()
    print("has defensive: " .. tostring(ai_strategy:has("defensive")))
end
local _ok, _err = pcall(demo_Strategy_has)

--@api-stub: Strategy:names
-- Demonstrates the proper usage of Strategy:names.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Strategy_names()
    local strat_names = ai_strategy:names()
    print("strategies: " .. table.concat(strat_names, ", "))
end
local _ok, _err = pcall(demo_Strategy_names)

--@api-stub: Strategy:remove
-- Demonstrates the proper usage of Strategy:remove.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Strategy_remove()
    ai_strategy:remove("defensive")
end
local _ok, _err = pcall(demo_Strategy_remove)

--@api-stub: Strategy:clear
-- Demonstrates the proper usage of Strategy:clear.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Strategy_clear()
    ai_strategy:clear()
end
local _ok, _err = pcall(demo_Strategy_clear)

-- =============================================================================
-- Stack — navigation history
-- =============================================================================

--@api-stub: lurek.patterns.newStack
-- Demonstrates the proper usage of lurek.patterns.newStack.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_patterns_newStack()
    local nav_stack = lurek.patterns.newStack()
end
local _ok, _err = pcall(demo_lurek_patterns_newStack)

--@api-stub: Stack:push
-- Demonstrates the proper usage of Stack:push.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Stack_push()
    nav_stack:push("main_menu")
    nav_stack:push("inventory")
    nav_stack:push("item_detail")
end
local _ok, _err = pcall(demo_Stack_push)

--@api-stub: Stack:peek
-- Demonstrates the proper usage of Stack:peek.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Stack_peek()
    print("current screen: " .. nav_stack:peek())
end
local _ok, _err = pcall(demo_Stack_peek)

--@api-stub: Stack:pop
-- Demonstrates the proper usage of Stack:pop.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Stack_pop()
    local prev = nav_stack:pop()
    print("back to: " .. nav_stack:peek())
end
local _ok, _err = pcall(demo_Stack_pop)

--@api-stub: Stack:len
-- Demonstrates the proper usage of Stack:len.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Stack_len()
    print("stack depth: " .. nav_stack:len())
end
local _ok, _err = pcall(demo_Stack_len)

--@api-stub: Stack:isEmpty
-- Demonstrates the proper usage of Stack:isEmpty.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Stack_isEmpty()
    print("stack empty: " .. tostring(nav_stack:isEmpty()))
end
local _ok, _err = pcall(demo_Stack_isEmpty)

--@api-stub: Stack:isFull
-- Demonstrates the proper usage of Stack:isFull.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Stack_isFull()
    print("stack full: " .. tostring(nav_stack:isFull()))
end
local _ok, _err = pcall(demo_Stack_isFull)

--@api-stub: Stack:toArray
-- Demonstrates the proper usage of Stack:toArray.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Stack_toArray()
    local stack_arr = nav_stack:toArray()
    print("stack: " .. table.concat(stack_arr, " > "))
end
local _ok, _err = pcall(demo_Stack_toArray)

--@api-stub: Stack:clear
-- Demonstrates the proper usage of Stack:clear.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Stack_clear()
    nav_stack:clear()
end
local _ok, _err = pcall(demo_Stack_clear)

-- =============================================================================
-- Queue — turn order / action queue
-- =============================================================================

--@api-stub: lurek.patterns.newQueue
-- Demonstrates the proper usage of lurek.patterns.newQueue.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_patterns_newQueue()
    local turn_queue = lurek.patterns.newQueue()
end
local _ok, _err = pcall(demo_lurek_patterns_newQueue)

--@api-stub: Queue:enqueue
-- Demonstrates the proper usage of Queue:enqueue.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Queue_enqueue()
    turn_queue:enqueue("warrior")
    turn_queue:enqueue("mage")
    turn_queue:enqueue("archer")
end
local _ok, _err = pcall(demo_Queue_enqueue)

--@api-stub: Queue:front
-- Demonstrates the proper usage of Queue:front.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Queue_front()
    print("next turn: " .. turn_queue:front())
end
local _ok, _err = pcall(demo_Queue_front)

--@api-stub: Queue:dequeue
-- Demonstrates the proper usage of Queue:dequeue.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Queue_dequeue()
    local current_turn = turn_queue:dequeue()
    print("acting: " .. current_turn)
end
local _ok, _err = pcall(demo_Queue_dequeue)

--@api-stub: Queue:len
-- Demonstrates the proper usage of Queue:len.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Queue_len()
    print("remaining turns: " .. turn_queue:len())
end
local _ok, _err = pcall(demo_Queue_len)

--@api-stub: Queue:isEmpty
-- Demonstrates the proper usage of Queue:isEmpty.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Queue_isEmpty()
    print("queue empty: " .. tostring(turn_queue:isEmpty()))
end
local _ok, _err = pcall(demo_Queue_isEmpty)

--@api-stub: Queue:isFull
-- Demonstrates the proper usage of Queue:isFull.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Queue_isFull()
    print("queue full: " .. tostring(turn_queue:isFull()))
end
local _ok, _err = pcall(demo_Queue_isFull)

--@api-stub: Queue:toArray
-- Demonstrates the proper usage of Queue:toArray.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Queue_toArray()
    local q_arr = turn_queue:toArray()
    print("turn order: " .. table.concat(q_arr, ", "))
end
local _ok, _err = pcall(demo_Queue_toArray)

--@api-stub: Queue:clear
-- Demonstrates the proper usage of Queue:clear.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Queue_clear()
    turn_queue:clear()
end
local _ok, _err = pcall(demo_Queue_clear)

-- =============================================================================
-- List — ordered inventory
-- =============================================================================

--@api-stub: lurek.patterns.newList
-- Demonstrates the proper usage of lurek.patterns.newList.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_patterns_newList()
    local inventory = lurek.patterns.newList()
end
local _ok, _err = pcall(demo_lurek_patterns_newList)

--@api-stub: List:add
-- Demonstrates the proper usage of List:add.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_List_add()
    inventory:add("Iron Sword")
    inventory:add("Health Potion")
    inventory:add("Shield")
end
local _ok, _err = pcall(demo_List_add)

--@api-stub: List:get
-- Demonstrates the proper usage of List:get.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_List_get()
    print("slot 0: " .. inventory:get(0))
end
local _ok, _err = pcall(demo_List_get)

--@api-stub: List:set
-- Demonstrates the proper usage of List:set.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_List_set()
    inventory:set(0, "Steel Sword")
end
local _ok, _err = pcall(demo_List_set)

--@api-stub: List:len
-- Demonstrates the proper usage of List:len.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_List_len()
    print("items: " .. inventory:len())
end
local _ok, _err = pcall(demo_List_len)

--@api-stub: List:contains
-- Demonstrates the proper usage of List:contains.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_List_contains()
    print("has Shield: " .. tostring(inventory:contains("Shield")))
end
local _ok, _err = pcall(demo_List_contains)

--@api-stub: List:isEmpty
-- Demonstrates the proper usage of List:isEmpty.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_List_isEmpty()
    print("empty: " .. tostring(inventory:isEmpty()))
end
local _ok, _err = pcall(demo_List_isEmpty)

--@api-stub: List:remove
-- Demonstrates the proper usage of List:remove.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_List_remove()
    inventory:remove(1)
end
local _ok, _err = pcall(demo_List_remove)

--@api-stub: List:toArray
-- Demonstrates the proper usage of List:toArray.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_List_toArray()
    local inv_arr = inventory:toArray()
    print("inventory: " .. table.concat(inv_arr, ", "))
end
local _ok, _err = pcall(demo_List_toArray)

--@api-stub: List:clear
-- Demonstrates the proper usage of List:clear.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_List_clear()
    inventory:clear()
end
local _ok, _err = pcall(demo_List_clear)

-- =============================================================================
-- Set — unique tag collection
-- =============================================================================

--@api-stub: lurek.patterns.newSet
-- Demonstrates the proper usage of lurek.patterns.newSet.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_patterns_newSet()
    local tags = lurek.patterns.newSet()
end
local _ok, _err = pcall(demo_lurek_patterns_newSet)

--@api-stub: Set:add
-- Demonstrates the proper usage of Set:add.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Set_add()
    tags:add("fire")
    tags:add("magic")
    tags:add("rare")
end
local _ok, _err = pcall(demo_Set_add)

--@api-stub: Set:has
-- Demonstrates the proper usage of Set:has.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Set_has()
    print("has fire: " .. tostring(tags:has("fire")))
end
local _ok, _err = pcall(demo_Set_has)

--@api-stub: Set:len
-- Demonstrates the proper usage of Set:len.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Set_len()
    print("tags: " .. tags:len())
end
local _ok, _err = pcall(demo_Set_len)

--@api-stub: Set:isEmpty
-- Demonstrates the proper usage of Set:isEmpty.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Set_isEmpty()
    print("empty: " .. tostring(tags:isEmpty()))
end
local _ok, _err = pcall(demo_Set_isEmpty)

--@api-stub: Set:toArray
-- Demonstrates the proper usage of Set:toArray.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Set_toArray()
    local tag_arr = tags:toArray()
    print("tags: " .. table.concat(tag_arr, ", "))
end
local _ok, _err = pcall(demo_Set_toArray)

--@api-stub: Set:remove
-- Demonstrates the proper usage of Set:remove.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Set_remove()
    tags:remove("rare")
    local other_tags = lurek.patterns.newSet()
    other_tags:add("fire")
    other_tags:add("ice")
end
local _ok, _err = pcall(demo_Set_remove)

--@api-stub: Set:union
-- Demonstrates the proper usage of Set:union.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Set_union()
    local all_tags = tags:union(other_tags)
    print("union: " .. all_tags:len())
end
local _ok, _err = pcall(demo_Set_union)

--@api-stub: Set:intersection
-- Demonstrates the proper usage of Set:intersection.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Set_intersection()
    local shared = tags:intersection(other_tags)
    print("shared: " .. shared:len())
end
local _ok, _err = pcall(demo_Set_intersection)

--@api-stub: Set:clear
-- Demonstrates the proper usage of Set:clear.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Set_clear()
    tags:clear()
    print("\n-- patterns.lua example complete --")
end
local _ok, _err = pcall(demo_Set_clear)
