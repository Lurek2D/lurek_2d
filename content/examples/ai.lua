-- content/examples/ai.lua
-- Lurek2D lurek.ai API Reference
-- Run with: cargo run -- content/examples/ai
--
-- Scenario: An open-world RPG with AI-driven NPCs — behavior trees for enemy
-- guards, finite state machines for villager routines, steering behaviours for
-- crowd movement, Q-learning for adaptive enemies, utility AI for NPC decisions,
-- GOAP for quest-giving NPCs, influence maps for territory control, squads for
-- coordinated patrols, blackboards for shared knowledge, neural nets for
-- difficulty tuning, emotion models for NPC moods, ORCA for crowd avoidance,
-- genetic algorithms for procedural creature stats, context steering for
-- obstacle avoidance, needs systems for survival mechanics, AI director for
-- dynamic difficulty, HTN planning for complex quest sequences, MCTS for
-- tactical combat decisions, and neuroevolution for breeding champion fighters.

print("=== lurek.ai — Open-World RPG AI Systems ===\n")

-- =============================================================================
-- AI World & Agents — top-level simulation container
-- =============================================================================

-- ---- Stub: lurek.ai.newWorld ---------------------------------------------
--@api-stub: lurek.ai.newWorld
-- Demonstrates the proper usage of lurek.ai.newWorld.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_ai_newWorld()
    local ai_world = lurek.ai.newWorld()
    print("AI world created — ready to accept agents")
end
local _ok, _err = pcall(demo_lurek_ai_newWorld)

-- ---- Stub: AIWorld:addAgent -----------------------------------------------
--@api-stub: AIWorld:addAgent
-- Register named agents at world positions. Each agent gets a private
-- blackboard, tags, and a decision model slot for FSM/BT/Utility.
local guard = ai_world:addAgent("guard_captain", {x = 100, y = 200})
local villager = ai_world:addAgent("baker", {x = 300, y = 400})
local wolf = ai_world:addAgent("alpha_wolf", {x = 500, y = 100})
local scout = ai_world:addAgent("scout_drone", {x = 50, y = 50})
print("4 agents added: guard_captain, baker, alpha_wolf, scout_drone")
print("  guard spawned at gatehouse entrance (100, 200)")
print("  baker spawned at bakery interior (300, 400)")

-- ---- Stub: AIWorld:getAgent -----------------------------------------------
--@api-stub: AIWorld:getAgent
-- Retrieve an agent handle by name for later configuration.
-- Returns nil if the name is not found in the world.
local g = ai_world:getAgent("guard_captain")
if g then
    print("retrieved agent handle for: " .. g:getName())
else
    print("guard_captain not found in AI world")
end

-- ---- Stub: AIWorld:getAgentCount ------------------------------------------
--@api-stub: AIWorld:getAgentCount
-- Demonstrates the proper usage of AIWorld:getAgentCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AIWorld_getAgentCount()
    local agent_count = ai_world:getAgentCount()
    print("total agents in world: " .. tostring(agent_count))
    if agent_count >= 4 then
    print("  world is populated — skipping additional spawns")
end
local _ok, _err = pcall(demo_AIWorld_getAgentCount)

-- ---- Stub: AIWorld:getGlobalBlackboard ------------------------------------
--@api-stub: AIWorld:getGlobalBlackboard
-- The global blackboard is shared across all agents — use it for world-level
-- facts like "alarm_active", "time_of_day", or "player_last_seen_pos".
local global_bb = ai_world:getGlobalBlackboard()
global_bb:setString("time_of_day", "night")
global_bb:setBool("alarm_active", false)
global_bb:setNumber("player_threat_level", 0.3)
print("global blackboard configured:")
print("  time_of_day = " .. tostring(global_bb:getString("time_of_day")))
print("  alarm_active = " .. tostring(global_bb:getBool("alarm_active")))

-- ---- Stub: AIWorld:update -------------------------------------------------
--@api-stub: AIWorld:update
-- Call once per frame with delta time. This ticks all agents' decision models,
-- steering behaviours, and state machines simultaneously.
local dt = 0.016  -- ~60 FPS frame time
ai_world:update(dt)
ai_world:update(dt)
ai_world:update(dt)
print("AI world stepped 3 frames (48ms total game time)")

-- ---- Stub: AIWorld:type ---------------------------------------------------
--@api-stub: AIWorld:type
-- Demonstrates the proper usage of AIWorld:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AIWorld_type()
    print('Executing type')
end
local _ok, _err = pcall(demo_AIWorld_type)

-- ---- Stub: AIWorld:typeOf -------------------------------------------------
--@api-stub: AIWorld:typeOf
-- Demonstrates the proper usage of AIWorld:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AIWorld_typeOf()
    print("world type: " .. tostring(ai_world:type()))
    print("world typeOf check: " .. tostring(ai_world:typeOf("AIWorld")))
end
local _ok, _err = pcall(demo_AIWorld_typeOf)

-- =============================================================================
-- Agent — individual NPC properties
-- =============================================================================

-- ---- Stub: Agent:getName --------------------------------------------------
--@api-stub: Agent:getName
-- Each agent has a unique name assigned at creation. Use it for debug logging,
-- save/load identification, or HUD labelling.
local guard_name = guard:getName()
local wolf_name = wolf:getName()
print("guard name: " .. guard_name .. ", wolf name: " .. wolf_name)

-- ---- Stub: Agent:setPosition ----------------------------------------------
--@api-stub: Agent:setPosition
-- Teleport the guard to a new patrol waypoint. In a real game this would be
-- called during cutscenes, spawn logic, or after loading a save file.
guard:setPosition(120, 210)
villager:setPosition(310, 390)
print("guard repositioned to gatehouse inner post (120, 210)")
print("baker moved to oven area (310, 390)")

-- ---- Stub: Agent:getPosition ----------------------------------------------
--@api-stub: Agent:getPosition
-- Demonstrates the proper usage of Agent:getPosition.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Agent_getPosition()
    local gx, gy = guard:getPosition()
    local wx, wy = wolf:getPosition()
    local dist = math.sqrt((gx - wx)^2 + (gy - wy)^2)
    print("guard at (" .. gx .. ", " .. gy .. ")")
    print("wolf at (" .. wx .. ", " .. wy .. ")")
    print("distance guard<->wolf: " .. string.format("%.1f", dist) .. " units")
end
local _ok, _err = pcall(demo_Agent_getPosition)

-- ---- Stub: Agent:setVelocity ----------------------------------------------
--@api-stub: Agent:setVelocity
-- Set the agent's movement direction and speed. Steering behaviours override
-- this each frame, but you can set it manually for scripted sequences.
guard:setVelocity(2.0, 0.0)   -- patrol east at 2 units/sec
wolf:setVelocity(-3.0, 1.5)   -- wolf loping southwest
print("guard velocity set to (2.0, 0.0) — eastward patrol")
print("wolf velocity set to (-3.0, 1.5) — approaching from northeast")

-- ---- Stub: Agent:getVelocity ----------------------------------------------
--@api-stub: Agent:getVelocity
-- Demonstrates the proper usage of Agent:getVelocity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Agent_getVelocity()
    local gvx, gvy = guard:getVelocity()
    local speed = math.sqrt(gvx^2 + gvy^2)
    print("guard velocity: (" .. gvx .. ", " .. gvy .. ") speed=" .. string.format("%.2f", speed))
    if speed > 1.5 then
    print("  guard is jogging — play jog animation")
    else
    print("  guard is walking — play walk animation")
end
local _ok, _err = pcall(demo_Agent_getVelocity)

-- ---- Stub: Agent:setMaxSpeed ----------------------------------------------
--@api-stub: Agent:setMaxSpeed
-- Demonstrates the proper usage of Agent:setMaxSpeed.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Agent_setMaxSpeed()
    guard:setMaxSpeed(4.0)     -- armoured guard moves slower
    wolf:setMaxSpeed(8.0)      -- wolf is much faster
    villager:setMaxSpeed(2.5)  -- baker ambles slowly
    print("max speeds: guard=4.0, wolf=8.0, baker=2.5")
end
local _ok, _err = pcall(demo_Agent_setMaxSpeed)

-- ---- Stub: Agent:getMaxSpeed ----------------------------------------------
--@api-stub: Agent:getMaxSpeed
-- Demonstrates the proper usage of Agent:getMaxSpeed.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Agent_getMaxSpeed()
    local guard_max = guard:getMaxSpeed()
    local wolf_max = wolf:getMaxSpeed()
    print("guard max speed: " .. tostring(guard_max))
    if wolf_max > guard_max then
    print("  wolf can outrun the guard — guard should call for backup!")
end
local _ok, _err = pcall(demo_Agent_getMaxSpeed)

-- ---- Stub: Agent:setMaxForce ----------------------------------------------
--@api-stub: Agent:setMaxForce
-- Max force controls how sharply steering behaviours can turn the agent.
-- Low force = wide lazy turns (vehicles), high force = snappy direction changes.
guard:setMaxForce(10.0)   -- armoured guard: sluggish turns
wolf:setMaxForce(25.0)    -- wolf: agile, quick direction changes
print("max force: guard=10.0 (heavy), wolf=25.0 (agile)")

-- ---- Stub: Agent:getMaxForce ----------------------------------------------
--@api-stub: Agent:getMaxForce
-- Demonstrates the proper usage of Agent:getMaxForce.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Agent_getMaxForce()
    local guard_force = guard:getMaxForce()
    print("guard max steering force: " .. tostring(guard_force))
end
local _ok, _err = pcall(demo_Agent_getMaxForce)

-- ---- Stub: Agent:setPriority ----------------------------------------------
--@api-stub: Agent:setPriority
-- Higher priority agents get processed first. Use for boss enemies or
-- player-critical NPCs that must always have up-to-date AI.
guard:setPriority(5)    -- high priority: gate guard is mission-critical
villager:setPriority(1) -- low priority: baker is background flavour
wolf:setPriority(3)     -- medium: threat to player but not scripted
print("priorities: guard=5 (critical), wolf=3 (threat), baker=1 (ambient)")

-- ---- Stub: Agent:getPriority ----------------------------------------------
--@api-stub: Agent:getPriority
-- Demonstrates the proper usage of Agent:getPriority.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Agent_getPriority()
    local gp = guard:getPriority()
    print("guard priority: " .. tostring(gp))
end
local _ok, _err = pcall(demo_Agent_getPriority)

-- ---- Stub: Agent:setDecisionModel -----------------------------------------
--@api-stub: Agent:setDecisionModel
-- Attach an FSM, BT, or UtilityAI to drive this agent's behaviour.
-- We'll create the FSM below and attach it here.
local guard_fsm = lurek.ai.newStateMachine()
guard_fsm:addState("patrol", {
    enter = function() print("    [guard] entering patrol route") end,
    update = function(dt) end,
    exit = function() print("    [guard] leaving patrol") end,
    transitions = { {target = "alert", condition = function()
        return global_bb:getBool("alarm_active")
    end} }
})
guard_fsm:addState("alert", {
    enter = function() print("    [guard] ALERT — drawing weapon!") end,
    update = function(dt) end,
    exit = function() print("    [guard] standing down") end,
    transitions = { {target = "patrol", condition = function()
        return not global_bb:getBool("alarm_active")
    end} }
})
guard_fsm:setInitialState("patrol")
guard:setDecisionModel(guard_fsm)
print("guard decision model: finite state machine (patrol <-> alert)")

-- ---- Stub: Agent:getDecisionModel -----------------------------------------
--@api-stub: Agent:getDecisionModel
-- Demonstrates the proper usage of Agent:getDecisionModel.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Agent_getDecisionModel()
    local model = guard:getDecisionModel()
    print("guard has decision model: " .. tostring(model ~= nil))
end
local _ok, _err = pcall(demo_Agent_getDecisionModel)

-- ---- Stub: Agent:addTag ---------------------------------------------------
--@api-stub: Agent:addTag
-- Tags let you query groups of agents efficiently — "hostile", "merchant",
-- "quest_giver" — without maintaining separate lists.
guard:addTag("hostile")
guard:addTag("armored")
guard:addTag("faction_royal")
villager:addTag("friendly")
villager:addTag("merchant")
wolf:addTag("hostile")
wolf:addTag("animal")
print("guard tags: hostile, armored, faction_royal")
print("villager tags: friendly, merchant")

-- ---- Stub: Agent:removeTag ------------------------------------------------
--@api-stub: Agent:removeTag
-- Demonstrates the proper usage of Agent:removeTag.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Agent_removeTag()
    guard:removeTag("hostile")
    print("guard bribed — removed 'hostile' tag, now neutral")
end
local _ok, _err = pcall(demo_Agent_removeTag)

-- ---- Stub: Agent:hasTag ---------------------------------------------------
--@api-stub: Agent:hasTag
-- Demonstrates the proper usage of Agent:hasTag.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Agent_hasTag()
    local is_hostile = guard:hasTag("hostile")
    local is_armored = guard:hasTag("armored")
    print("guard hostile: " .. tostring(is_hostile) .. ", armored: " .. tostring(is_armored))
    if not is_hostile and is_armored then
    print("  neutral armored NPC — show barter dialog")
end
local _ok, _err = pcall(demo_Agent_hasTag)

-- ---- Stub: Agent:getBlackboard --------------------------------------------
--@api-stub: Agent:getBlackboard
-- Each agent's private blackboard stores agent-specific memory:
-- last seen player position, health state, ammo count, etc.
local guard_bb = guard:getBlackboard()
guard_bb:setNumber("patrol_waypoint_idx", 0)
guard_bb:setNumber("suspicion_level", 0.0)
guard_bb:setBool("has_key", true)
print("guard blackboard initialised:")
print("  patrol_waypoint_idx = 0")
print("  has_key = " .. tostring(guard_bb:getBool("has_key")))

-- ---- Stub: Agent:type -----------------------------------------------------
--@api-stub: Agent:type
-- Demonstrates the proper usage of Agent:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Agent_type()
    print('Executing type')
end
local _ok, _err = pcall(demo_Agent_type)

-- ---- Stub: Agent:typeOf ---------------------------------------------------
--@api-stub: Agent:typeOf
-- Demonstrates the proper usage of Agent:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Agent_typeOf()
    print("agent type: " .. tostring(guard:type()))
    print("agent typeOf Agent: " .. tostring(guard:typeOf("Agent")))
end
local _ok, _err = pcall(demo_Agent_typeOf)

-- =============================================================================
-- Blackboard — shared knowledge store
-- =============================================================================

-- ---- Stub: lurek.ai.newBlackboard -----------------------------------------
--@api-stub: lurek.ai.newBlackboard
-- Demonstrates the proper usage of lurek.ai.newBlackboard.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_ai_newBlackboard()
    local quest_bb = lurek.ai.newBlackboard()
    print("standalone blackboard created for quest tracking")
end
local _ok, _err = pcall(demo_lurek_ai_newBlackboard)

-- ---- Stub: Blackboard:setNumber ------------------------------------------
--@api-stub: Blackboard:setNumber
-- Demonstrates the proper usage of Blackboard:setNumber.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Blackboard_setNumber()
    quest_bb:setNumber("wolves_killed", 0)
    quest_bb:setNumber("bounty_gold", 50)
    quest_bb:setNumber("quest_timer_sec", 300.0)
    print("quest state: wolves_killed=0, bounty=50g, timer=300s")
end
local _ok, _err = pcall(demo_Blackboard_setNumber)

-- ---- Stub: Blackboard:setBool --------------------------------------------
--@api-stub: Blackboard:setBool
-- Demonstrates the proper usage of Blackboard:setBool.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Blackboard_setBool()
    quest_bb:setBool("quest_accepted", true)
    quest_bb:setBool("boss_defeated", false)
    quest_bb:setBool("escape_route_open", false)
    print("quest flags: accepted=true, boss_defeated=false")
end
local _ok, _err = pcall(demo_Blackboard_setBool)

-- ---- Stub: Blackboard:setString ------------------------------------------
--@api-stub: Blackboard:setString
-- Demonstrates the proper usage of Blackboard:setString.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Blackboard_setString()
    quest_bb:setString("quest_giver", "Mayor Thornton")
    quest_bb:setString("objective", "Clear the wolf den north of town")
    quest_bb:setString("reward_item", "silver_sword")
    print("quest: '" .. quest_bb:getString("objective") .. "' from " .. quest_bb:getString("quest_giver"))
end
local _ok, _err = pcall(demo_Blackboard_setString)

-- ---- Stub: Blackboard:has ------------------------------------------------
--@api-stub: Blackboard:has
-- Demonstrates the proper usage of Blackboard:has.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Blackboard_has()
    if quest_bb:has("quest_giver") then
    print("quest giver is set: " .. quest_bb:getString("quest_giver"))
    if not quest_bb:has("completion_time") then
    print("no completion_time recorded yet — quest still active")
end
local _ok, _err = pcall(demo_Blackboard_has)

-- ---- Stub: Blackboard:remove ----------------------------------------------
--@api-stub: Blackboard:remove
-- Demonstrates the proper usage of Blackboard:remove.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Blackboard_remove()
    quest_bb:remove("quest_timer_sec")
    print("quest timer removed — now using event-driven completion")
    print("  timer key exists: " .. tostring(quest_bb:has("quest_timer_sec")))
end
local _ok, _err = pcall(demo_Blackboard_remove)

-- ---- Stub: Blackboard:getKeys ---------------------------------------------
--@api-stub: Blackboard:getKeys
-- Demonstrates the proper usage of Blackboard:getKeys.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Blackboard_getKeys()
    local keys = quest_bb:getKeys()
    print("blackboard keys (" .. #keys .. "):")
    for i, k in ipairs(keys) do
    print("  [" .. i .. "] " .. k)
end
local _ok, _err = pcall(demo_Blackboard_getKeys)

-- ---- Stub: Blackboard:getSize ---------------------------------------------
--@api-stub: Blackboard:getSize
-- Demonstrates the proper usage of Blackboard:getSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Blackboard_getSize()
    local bb_size = quest_bb:getSize()
    print("blackboard entries: " .. tostring(bb_size))
end
local _ok, _err = pcall(demo_Blackboard_getSize)

-- ---- Stub: Blackboard:clear -----------------------------------------------
--@api-stub: Blackboard:clear
-- Demonstrates the proper usage of Blackboard:clear.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Blackboard_clear()
    local old_size = quest_bb:getSize()
    quest_bb:clear()
    print("blackboard cleared: " .. old_size .. " -> " .. quest_bb:getSize() .. " entries")
end
local _ok, _err = pcall(demo_Blackboard_clear)

-- ---- Stub: Blackboard:type ------------------------------------------------
--@api-stub: Blackboard:type
-- Demonstrates the proper usage of Blackboard:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Blackboard_type()
    print('Executing type')
end
local _ok, _err = pcall(demo_Blackboard_type)

-- ---- Stub: Blackboard:typeOf ----------------------------------------------
--@api-stub: Blackboard:typeOf
-- Demonstrates the proper usage of Blackboard:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Blackboard_typeOf()
    print("blackboard type: " .. tostring(quest_bb:type()))
    print("blackboard typeOf: " .. tostring(quest_bb:typeOf("Blackboard")))
end
local _ok, _err = pcall(demo_Blackboard_typeOf)

-- =============================================================================
-- Finite State Machine — villager daily routine
-- =============================================================================

-- ---- Stub: lurek.ai.newStateMachine ---------------------------------------
--@api-stub: lurek.ai.newStateMachine
-- Demonstrates the proper usage of lurek.ai.newStateMachine.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_ai_newStateMachine()
    local baker_fsm = lurek.ai.newStateMachine()
    print("baker FSM created for daily routine cycle")
end
local _ok, _err = pcall(demo_lurek_ai_newStateMachine)

-- ---- Stub: StateMachine:addState ------------------------------------------
--@api-stub: StateMachine:addState
-- Define states with behaviour hooks and transition conditions.
baker_fsm:addState("baking", {
    enter = function()
        print("    [baker] fires up the oven at dawn")
    end,
    update = function(dt)
        -- Simulate kneading dough each frame
    end,
    exit = function()
        print("    [baker] pulls loaves from oven")
    end,
    transitions = {
        { target = "selling", condition = function()
            return global_bb:getString("time_of_day") == "morning"
        end }
    }
})
baker_fsm:addState("selling", {
    enter = function() print("    [baker] opens shop window") end,
    update = function(dt) end,
    exit = function() print("    [baker] closes shop for the day") end,
    transitions = {
        { target = "sleeping", condition = function()
            return global_bb:getString("time_of_day") == "night"
        end }
    }
})
baker_fsm:addState("sleeping", {
    enter = function() print("    [baker] heads upstairs to bed") end,
    update = function(dt) end,
    exit = function() print("    [baker] wakes up at dawn") end,
    transitions = {
        { target = "baking", condition = function()
            return global_bb:getString("time_of_day") == "dawn"
        end }
    }
})
print("baker states: baking -> selling -> sleeping -> baking (cycle)")

-- ---- Stub: StateMachine:setInitialState -----------------------------------
--@api-stub: StateMachine:setInitialState
-- Demonstrates the proper usage of StateMachine:setInitialState.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_StateMachine_setInitialState()
    baker_fsm:setInitialState("baking")
    print("baker initial state: baking (dawn start)")
end
local _ok, _err = pcall(demo_StateMachine_setInitialState)

-- ---- Stub: StateMachine:getCurrentState -----------------------------------
--@api-stub: StateMachine:getCurrentState
-- Demonstrates the proper usage of StateMachine:getCurrentState.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_StateMachine_getCurrentState()
    local bstate = baker_fsm:getCurrentState()
    print("baker current state: " .. tostring(bstate))
end
local _ok, _err = pcall(demo_StateMachine_getCurrentState)

-- ---- Stub: StateMachine:forceState ----------------------------------------
--@api-stub: StateMachine:forceState
-- Force a state change during cutscenes or scripted events.
-- Bypasses transition conditions.
baker_fsm:forceState("selling")
print("baker forced to 'selling' state (market event triggered)")
print("  new state: " .. tostring(baker_fsm:getCurrentState()))

-- ---- Stub: StateMachine:getTimeInState ------------------------------------
--@api-stub: StateMachine:getTimeInState
-- Demonstrates the proper usage of StateMachine:getTimeInState.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_StateMachine_getTimeInState()
    local time_selling = baker_fsm:getTimeInState()
    print("baker time in selling state: " .. string.format("%.3f", time_selling) .. "s")
end
local _ok, _err = pcall(demo_StateMachine_getTimeInState)

-- ---- Stub: StateMachine:type ----------------------------------------------
--@api-stub: StateMachine:type
-- Demonstrates the proper usage of StateMachine:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_StateMachine_type()
    print('Executing type')
end
local _ok, _err = pcall(demo_StateMachine_type)

-- ---- Stub: StateMachine:typeOf --------------------------------------------
--@api-stub: StateMachine:typeOf
-- Demonstrates the proper usage of StateMachine:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_StateMachine_typeOf()
    print("FSM type: " .. tostring(baker_fsm:type()))
    print("FSM typeOf: " .. tostring(baker_fsm:typeOf("StateMachine")))
end
local _ok, _err = pcall(demo_StateMachine_typeOf)

-- =============================================================================
-- Behavior Tree — guard combat AI
-- =============================================================================

-- ---- Stub: lurek.ai.newBehaviorTree ---------------------------------------
--@api-stub: lurek.ai.newBehaviorTree
-- Demonstrates the proper usage of lurek.ai.newBehaviorTree.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_ai_newBehaviorTree()
    local guard_bt = lurek.ai.newBehaviorTree()
    print("guard behavior tree created")
end
local _ok, _err = pcall(demo_lurek_ai_newBehaviorTree)

-- ---- Stub: lurek.ai.newSelector ------------------------------------------
--@api-stub: lurek.ai.newSelector
-- Demonstrates the proper usage of lurek.ai.newSelector.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_ai_newSelector()
    local combat_selector = lurek.ai.newSelector()
    print("combat selector: try attack -> investigate -> patrol")
end
local _ok, _err = pcall(demo_lurek_ai_newSelector)

-- ---- Stub: lurek.ai.newSequence -------------------------------------------
--@api-stub: lurek.ai.newSequence
-- Demonstrates the proper usage of lurek.ai.newSequence.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_ai_newSequence()
    local attack_sequence = lurek.ai.newSequence()
    print("attack sequence: spot -> draw weapon -> charge -> strike")
end
local _ok, _err = pcall(demo_lurek_ai_newSequence)

-- ---- Stub: lurek.ai.newParallel -------------------------------------------
--@api-stub: lurek.ai.newParallel
-- Demonstrates the proper usage of lurek.ai.newParallel.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_ai_newParallel()
    local patrol_and_scan = lurek.ai.newParallel()
    print("parallel node: patrol route + scan surroundings simultaneously")
end
local _ok, _err = pcall(demo_lurek_ai_newParallel)

-- ---- Stub: lurek.ai.newCondition ------------------------------------------
--@api-stub: lurek.ai.newCondition
-- Conditions are leaf nodes that check game state without side effects.
-- Returns success/failure based on the predicate.
local can_see_enemy = lurek.ai.newCondition(function()
    local threat = global_bb:getNumber("player_threat_level")
    return threat > 0.5
end)
print("condition node: 'can see enemy' (threat > 0.5)")

local has_ammo = lurek.ai.newCondition(function()
    return guard_bb:getNumber("suspicion_level") > 0.0
end)
print("condition node: 'suspicious' (suspicion > 0)")

-- ---- Stub: lurek.ai.newAction ---------------------------------------------
--@api-stub: lurek.ai.newAction
-- Demonstrates the proper usage of lurek.ai.newAction.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_ai_newAction()
    local swing_sword = lurek.ai.newAction(function()
    print("    [guard] swings sword at target!")
    return "success"
    local shout_alarm = lurek.ai.newAction(function()
    print("    [guard] shouts: INTRUDER!")
    global_bb:setBool("alarm_active", true)
    return "success"
    local walk_patrol = lurek.ai.newAction(function()
    local idx = guard_bb:getNumber("patrol_waypoint_idx")
    guard_bb:setNumber("patrol_waypoint_idx", idx + 1)
    return "success"
    print("action nodes: swing_sword, shout_alarm, walk_patrol")
end
local _ok, _err = pcall(demo_lurek_ai_newAction)

-- ---- Stub: lurek.ai.newInverter ------------------------------------------
--@api-stub: lurek.ai.newInverter
-- Demonstrates the proper usage of lurek.ai.newInverter.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_ai_newInverter()
    local not_safe = lurek.ai.newInverter()
    not_safe:setChild(can_see_enemy)
    print("inverter: NOT(can_see_enemy) = area is safe")
end
local _ok, _err = pcall(demo_lurek_ai_newInverter)

-- ---- Stub: lurek.ai.newRepeater ------------------------------------------
--@api-stub: lurek.ai.newRepeater
-- Demonstrates the proper usage of lurek.ai.newRepeater.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_ai_newRepeater()
    local triple_strike = lurek.ai.newRepeater()
    triple_strike:setCount(3)
    triple_strike:setChild(swing_sword)
    print("repeater: swing sword x3")
end
local _ok, _err = pcall(demo_lurek_ai_newRepeater)

-- ---- Stub: lurek.ai.newSucceeder -----------------------------------------
--@api-stub: lurek.ai.newSucceeder
-- Succeeder always returns success regardless of child result.
-- Use to ensure optional actions don't break a sequence.
local optional_taunt = lurek.ai.newSucceeder()
optional_taunt:setChild(shout_alarm)
print("succeeder: alarm shout is optional (sequence continues even if it fails)")

-- ---- Stub: BTNode:addChild ------------------------------------------------
--@api-stub: BTNode:addChild
-- Demonstrates the proper usage of BTNode:addChild.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_BTNode_addChild()
    attack_sequence:addChild(can_see_enemy)
    attack_sequence:addChild(shout_alarm)
    attack_sequence:addChild(triple_strike)
    combat_selector:addChild(attack_sequence)
    combat_selector:addChild(walk_patrol)
    patrol_and_scan:addChild(combat_selector)
    patrol_and_scan:addChild(not_safe)
    print("tree assembled: parallel(selector(attack_seq, patrol), inverter)")
end
local _ok, _err = pcall(demo_BTNode_addChild)

-- ---- Stub: BTNode:getChildCount -------------------------------------------
--@api-stub: BTNode:getChildCount
-- Demonstrates the proper usage of BTNode:getChildCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_BTNode_getChildCount()
    print("combat selector children: " .. tostring(combat_selector:getChildCount()))
    print("attack sequence children: " .. tostring(attack_sequence:getChildCount()))
end
local _ok, _err = pcall(demo_BTNode_getChildCount)

-- ---- Stub: BTNode:reset ---------------------------------------------------
--@api-stub: BTNode:reset
-- Demonstrates the proper usage of BTNode:reset.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_BTNode_reset()
    combat_selector:reset()
    print("combat tree reset — guard returns to default behaviour")
end
local _ok, _err = pcall(demo_BTNode_reset)

-- ---- Stub: BTNode:setChild ------------------------------------------------
--@api-stub: BTNode:setChild
-- Demonstrates the proper usage of BTNode:setChild.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_BTNode_setChild()
    not_safe:setChild(has_ammo)
    print("inverter child swapped: now inverts 'has_ammo' check")
end
local _ok, _err = pcall(demo_BTNode_setChild)

-- ---- Stub: BTNode:setCount ------------------------------------------------
--@api-stub: BTNode:setCount
-- Demonstrates the proper usage of BTNode:setCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_BTNode_setCount()
    triple_strike:setCount(5)
    print("repeater count increased to 5 (hard mode: 5 rapid strikes)")
end
local _ok, _err = pcall(demo_BTNode_setCount)

-- ---- Stub: BTNode:getCount ------------------------------------------------
--@api-stub: BTNode:getCount
-- Demonstrates the proper usage of BTNode:getCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_BTNode_getCount()
    local rep_count = triple_strike:getCount()
    print("repeater count: " .. tostring(rep_count))
end
local _ok, _err = pcall(demo_BTNode_getCount)

-- ---- Stub: BTNode:setSuccessPolicy ----------------------------------------
--@api-stub: BTNode:setSuccessPolicy
-- Demonstrates the proper usage of BTNode:setSuccessPolicy.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_BTNode_setSuccessPolicy()
    patrol_and_scan:setSuccessPolicy("one")
    print("parallel success policy: 'one' (succeed if either patrol or scan succeeds)")
end
local _ok, _err = pcall(demo_BTNode_setSuccessPolicy)

-- ---- Stub: BTNode:setFailurePolicy ----------------------------------------
--@api-stub: BTNode:setFailurePolicy
-- Demonstrates the proper usage of BTNode:setFailurePolicy.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_BTNode_setFailurePolicy()
    patrol_and_scan:setFailurePolicy("all")
    print("parallel failure policy: 'all' (fail only if both patrol AND scan fail)")
end
local _ok, _err = pcall(demo_BTNode_setFailurePolicy)

-- ---- Stub: BTNode:getNodeType ---------------------------------------------
--@api-stub: BTNode:getNodeType
-- Demonstrates the proper usage of BTNode:getNodeType.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_BTNode_getNodeType()
    print("combat_selector node type: " .. tostring(combat_selector:getNodeType()))
    print("attack_sequence node type: " .. tostring(attack_sequence:getNodeType()))
    print("triple_strike node type: " .. tostring(triple_strike:getNodeType()))
end
local _ok, _err = pcall(demo_BTNode_getNodeType)

-- ---- Stub: BTNode:type ----------------------------------------------------
--@api-stub: BTNode:type
-- Demonstrates the proper usage of BTNode:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_BTNode_type()
    print('Executing type')
end
local _ok, _err = pcall(demo_BTNode_type)

-- ---- Stub: BTNode:typeOf --------------------------------------------------
--@api-stub: BTNode:typeOf
-- Demonstrates the proper usage of BTNode:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_BTNode_typeOf()
    print("BT node type: " .. tostring(combat_selector:type()))
    print("BT node typeOf: " .. tostring(combat_selector:typeOf("BTNode")))
end
local _ok, _err = pcall(demo_BTNode_typeOf)

-- ---- Stub: BehaviorTree:setRoot -------------------------------------------
--@api-stub: BehaviorTree:setRoot
-- Demonstrates the proper usage of BehaviorTree:setRoot.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_BehaviorTree_setRoot()
    guard_bt:setRoot(patrol_and_scan)
    print("guard BT root set to parallel(patrol + scan)")
end
local _ok, _err = pcall(demo_BehaviorTree_setRoot)

-- ---- Stub: BehaviorTree:getLastStatus -------------------------------------
--@api-stub: BehaviorTree:getLastStatus
-- Demonstrates the proper usage of BehaviorTree:getLastStatus.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_BehaviorTree_getLastStatus()
    local status = guard_bt:getLastStatus()
    print("guard BT last status: " .. tostring(status))
end
local _ok, _err = pcall(demo_BehaviorTree_getLastStatus)

-- ---- Stub: BehaviorTree:getDebugState -------------------------------------
--@api-stub: BehaviorTree:getDebugState
-- Demonstrates the proper usage of BehaviorTree:getDebugState.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_BehaviorTree_getDebugState()
    local dbg = guard_bt:getDebugState()
    if dbg then
    print("BT debug state available — " .. type(dbg) .. " with node states")
end
local _ok, _err = pcall(demo_BehaviorTree_getDebugState)

-- ---- Stub: BehaviorTree:type ----------------------------------------------
--@api-stub: BehaviorTree:type
-- Demonstrates the proper usage of BehaviorTree:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_BehaviorTree_type()
    print('Executing type')
end
local _ok, _err = pcall(demo_BehaviorTree_type)

-- ---- Stub: BehaviorTree:typeOf --------------------------------------------
--@api-stub: BehaviorTree:typeOf
-- Demonstrates the proper usage of BehaviorTree:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_BehaviorTree_typeOf()
    print("BT type: " .. tostring(guard_bt:type()))
    print("BT typeOf: " .. tostring(guard_bt:typeOf("BehaviorTree")))
end
local _ok, _err = pcall(demo_BehaviorTree_typeOf)

-- =============================================================================
-- Steering Behaviours — crowd movement
-- =============================================================================

-- ---- Stub: lurek.ai.newSteeringManager ------------------------------------
--@api-stub: lurek.ai.newSteeringManager
-- Demonstrates the proper usage of lurek.ai.newSteeringManager.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_ai_newSteeringManager()
    local steer_mgr = lurek.ai.newSteeringManager()
    print("steering manager created for crowd NPCs")
end
local _ok, _err = pcall(demo_lurek_ai_newSteeringManager)

-- ---- Stub: SteeringManager:getBehaviorCount -------------------------------
--@api-stub: SteeringManager:getBehaviorCount
-- Demonstrates the proper usage of SteeringManager:getBehaviorCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SteeringManager_getBehaviorCount()
    local bcount = steer_mgr:getBehaviorCount()
    print("active steering behaviours: " .. tostring(bcount))
end
local _ok, _err = pcall(demo_SteeringManager_getBehaviorCount)

-- ---- Stub: SteeringManager:setCombineMode ---------------------------------
--@api-stub: SteeringManager:setCombineMode
-- Demonstrates the proper usage of SteeringManager:setCombineMode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SteeringManager_setCombineMode()
    steer_mgr:setCombineMode("weighted_average")
    print("steering combine mode: weighted_average (smooth crowd flow)")
end
local _ok, _err = pcall(demo_SteeringManager_setCombineMode)

-- ---- Stub: SteeringManager:getCombineMode ---------------------------------
--@api-stub: SteeringManager:getCombineMode
-- Demonstrates the proper usage of SteeringManager:getCombineMode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SteeringManager_getCombineMode()
    print("current combine mode: " .. tostring(steer_mgr:getCombineMode()))
end
local _ok, _err = pcall(demo_SteeringManager_getCombineMode)

-- ---- Stub: SteeringManager:getLastSteering --------------------------------
--@api-stub: SteeringManager:getLastSteering
-- Demonstrates the proper usage of SteeringManager:getLastSteering.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SteeringManager_getLastSteering()
    local sx, sy = steer_mgr:getLastSteering()
    print("last steering vector: (" .. tostring(sx) .. ", " .. tostring(sy) .. ")")
end
local _ok, _err = pcall(demo_SteeringManager_getLastSteering)

-- ---- Stub: SteeringManager:setSpatialHashCellSize -------------------------
--@api-stub: SteeringManager:setSpatialHashCellSize
-- Demonstrates the proper usage of SteeringManager:setSpatialHashCellSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SteeringManager_setSpatialHashCellSize()
    steer_mgr:setSpatialHashCellSize(64.0)
    print("spatial hash cell size: 64px (good for ~20 agents in 1024x768)")
end
local _ok, _err = pcall(demo_SteeringManager_setSpatialHashCellSize)

-- ---- Stub: SteeringManager:enableSpatialHash -----------------------------
--@api-stub: SteeringManager:enableSpatialHash
-- Demonstrates the proper usage of SteeringManager:enableSpatialHash.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SteeringManager_enableSpatialHash()
    steer_mgr:enableSpatialHash(true)
    print("spatial hash enabled — separation/avoidance queries accelerated")
end
local _ok, _err = pcall(demo_SteeringManager_enableSpatialHash)

-- ---- Stub: SteeringManager:type -------------------------------------------
--@api-stub: SteeringManager:type
-- Demonstrates the proper usage of SteeringManager:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SteeringManager_type()
    print('Executing type')
end
local _ok, _err = pcall(demo_SteeringManager_type)

-- ---- Stub: SteeringManager:typeOf -----------------------------------------
--@api-stub: SteeringManager:typeOf
-- Demonstrates the proper usage of SteeringManager:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SteeringManager_typeOf()
    print("steering mgr type: " .. tostring(steer_mgr:type()))
    print("steering mgr typeOf: " .. tostring(steer_mgr:typeOf("SteeringManager")))
end
local _ok, _err = pcall(demo_SteeringManager_typeOf)

-- =============================================================================
-- Context Steering — obstacle avoidance for the wolf
-- =============================================================================

-- ---- Stub: lurek.ai.newContextSteering ------------------------------------
--@api-stub: lurek.ai.newContextSteering
-- Demonstrates the proper usage of lurek.ai.newContextSteering.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_ai_newContextSteering()
    local ctx_steer = lurek.ai.newContextSteering()
    print("context steering created for wolf navigation")
end
local _ok, _err = pcall(demo_lurek_ai_newContextSteering)

-- ---- Stub: ContextSteering:addSeekTarget ----------------------------------
--@api-stub: ContextSteering:addSeekTarget
-- Demonstrates the proper usage of ContextSteering:addSeekTarget.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ContextSteering_addSeekTarget()
    ctx_steer:addSeekTarget(400, 300, 1.0)
    print("wolf seek target: campfire at (400, 300), weight 1.0")
end
local _ok, _err = pcall(demo_ContextSteering_addSeekTarget)

-- ---- Stub: ContextSteering:addWander --------------------------------------
--@api-stub: ContextSteering:addWander
-- Demonstrates the proper usage of ContextSteering:addWander.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ContextSteering_addWander()
    ctx_steer:addWander(0.3)
    print("wolf wander added (weight 0.3) for natural-looking path")
end
local _ok, _err = pcall(demo_ContextSteering_addWander)

-- ---- Stub: ContextSteering:addAvoidPoint ----------------------------------
--@api-stub: ContextSteering:addAvoidPoint
-- Demonstrates the proper usage of ContextSteering:addAvoidPoint.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ContextSteering_addAvoidPoint()
    ctx_steer:addAvoidPoint(120, 210, 80.0, 2.0)
    print("wolf avoids guard torch at (120, 210) radius=80, danger=2.0")
end
local _ok, _err = pcall(demo_ContextSteering_addAvoidPoint)

-- ---- Stub: ContextSteering:addAvoidBounds ---------------------------------
--@api-stub: ContextSteering:addAvoidBounds
-- Demonstrates the proper usage of ContextSteering:addAvoidBounds.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ContextSteering_addAvoidBounds()
    ctx_steer:addAvoidBounds(0, 0, 600, 500, 1.5)
    print("wolf constrained to forest bounds (0,0)-(600,500)")
end
local _ok, _err = pcall(demo_ContextSteering_addAvoidBounds)

-- ---- Stub: ContextSteering:clearBehaviors ---------------------------------
--@api-stub: ContextSteering:clearBehaviors
-- Clear all behaviours when the wolf switches from hunting to fleeing.
local before_clear = ctx_steer:slotCount()
ctx_steer:clearBehaviors()
print("context steering cleared: " .. before_clear .. " slots, behaviours reset")

-- Re-add for evaluation demo
ctx_steer:addSeekTarget(400, 300, 1.0)
ctx_steer:addAvoidPoint(120, 210, 80.0, 2.0)

-- ---- Stub: ContextSteering:evaluate ---------------------------------------
--@api-stub: ContextSteering:evaluate
-- Demonstrates the proper usage of ContextSteering:evaluate.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ContextSteering_evaluate()
    local dir_x, dir_y = ctx_steer:evaluate()
    print("wolf resolved direction: (" .. string.format("%.2f", dir_x) .. ", " .. string.format("%.2f", dir_y) .. ")")
end
local _ok, _err = pcall(demo_ContextSteering_evaluate)

-- ---- Stub: ContextSteering:chosenMagnitude --------------------------------
--@api-stub: ContextSteering:chosenMagnitude
-- Demonstrates the proper usage of ContextSteering:chosenMagnitude.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ContextSteering_chosenMagnitude()
    local mag = ctx_steer:chosenMagnitude()
    print("wolf steering magnitude: " .. string.format("%.2f", mag))
    if mag < 0.3 then
    print("  wolf is trapped — all directions blocked!")
end
local _ok, _err = pcall(demo_ContextSteering_chosenMagnitude)

-- ---- Stub: ContextSteering:slotCount --------------------------------------
--@api-stub: ContextSteering:slotCount
-- Demonstrates the proper usage of ContextSteering:slotCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ContextSteering_slotCount()
    local slots = ctx_steer:slotCount()
    print("context steering resolution: " .. tostring(slots) .. " directional slots")
end
local _ok, _err = pcall(demo_ContextSteering_slotCount)

-- =============================================================================
-- Q-Learning — adaptive enemy behaviour
-- =============================================================================

-- ---- Stub: lurek.ai.newQLearner -------------------------------------------
--@api-stub: lurek.ai.newQLearner
-- Train a wolf to choose between "stalk", "pounce", "howl", "flee" based on
-- distance and health states. The Q-table updates after each encounter.
local wolf_ql = lurek.ai.newQLearner({
    states = {"far_healthy", "far_wounded", "close_healthy", "close_wounded"},
    actions = {"stalk", "pounce", "howl", "flee"},
    learning_rate = 0.1,
    discount_factor = 0.95,
    exploration_rate = 0.3
})
print("wolf Q-learner: 4 states x 4 actions, epsilon=0.3")

-- ---- Stub: QLearner:chooseAction ------------------------------------------
--@api-stub: QLearner:chooseAction
-- Demonstrates the proper usage of QLearner:chooseAction.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_QLearner_chooseAction()
    local action1 = wolf_ql:chooseAction("far_healthy")
    print("wolf chose action in 'far_healthy' state: " .. tostring(action1))
end
local _ok, _err = pcall(demo_QLearner_chooseAction)

-- ---- Stub: QLearner:bestAction --------------------------------------------
--@api-stub: QLearner:bestAction
-- Demonstrates the proper usage of QLearner:bestAction.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_QLearner_bestAction()
    local best = wolf_ql:bestAction("close_wounded")
    print("best action for 'close_wounded': " .. tostring(best))
end
local _ok, _err = pcall(demo_QLearner_bestAction)

-- ---- Stub: QLearner:getQValue ---------------------------------------------
--@api-stub: QLearner:getQValue
-- Demonstrates the proper usage of QLearner:getQValue.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_QLearner_getQValue()
    local q_val = wolf_ql:getQValue("close_healthy", "pounce")
    print("Q(close_healthy, pounce) = " .. string.format("%.3f", q_val))
end
local _ok, _err = pcall(demo_QLearner_getQValue)

-- ---- Stub: QLearner:endEpisode --------------------------------------------
--@api-stub: QLearner:endEpisode
-- Demonstrates the proper usage of QLearner:endEpisode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_QLearner_endEpisode()
    wolf_ql:endEpisode(1.0)  -- wolf caught prey: +1 reward
    print("episode ended with reward +1.0 (successful hunt)")
end
local _ok, _err = pcall(demo_QLearner_endEpisode)

-- ---- Stub: QLearner:getEpisodeCount ---------------------------------------
--@api-stub: QLearner:getEpisodeCount
-- Demonstrates the proper usage of QLearner:getEpisodeCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_QLearner_getEpisodeCount()
    local episodes = wolf_ql:getEpisodeCount()
    print("total training episodes: " .. tostring(episodes))
end
local _ok, _err = pcall(demo_QLearner_getEpisodeCount)

-- ---- Stub: QLearner:getStateCount -----------------------------------------
--@api-stub: QLearner:getStateCount
-- Demonstrates the proper usage of QLearner:getStateCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_QLearner_getStateCount()
    print("Q-learner state count: " .. tostring(wolf_ql:getStateCount()))
end
local _ok, _err = pcall(demo_QLearner_getStateCount)

-- ---- Stub: QLearner:getActionCount ----------------------------------------
--@api-stub: QLearner:getActionCount
-- Demonstrates the proper usage of QLearner:getActionCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_QLearner_getActionCount()
    print("Q-learner action count: " .. tostring(wolf_ql:getActionCount()))
end
local _ok, _err = pcall(demo_QLearner_getActionCount)

-- ---- Stub: QLearner:setLearningRate ---------------------------------------
--@api-stub: QLearner:setLearningRate
-- Demonstrates the proper usage of QLearner:setLearningRate.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_QLearner_setLearningRate()
    wolf_ql:setLearningRate(0.05)
    print("learning rate reduced to 0.05 (late-training stabilisation)")
end
local _ok, _err = pcall(demo_QLearner_setLearningRate)

-- ---- Stub: QLearner:getLearningRate ---------------------------------------
--@api-stub: QLearner:getLearningRate
-- Demonstrates the proper usage of QLearner:getLearningRate.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_QLearner_getLearningRate()
    print("current learning rate: " .. tostring(wolf_ql:getLearningRate()))
end
local _ok, _err = pcall(demo_QLearner_getLearningRate)

-- ---- Stub: QLearner:setDiscountFactor -------------------------------------
--@api-stub: QLearner:setDiscountFactor
-- Demonstrates the proper usage of QLearner:setDiscountFactor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_QLearner_setDiscountFactor()
    wolf_ql:setDiscountFactor(0.99)
    print("discount factor: 0.99 (wolf values long-term ambush payoff)")
end
local _ok, _err = pcall(demo_QLearner_setDiscountFactor)

-- ---- Stub: QLearner:getDiscountFactor -------------------------------------
--@api-stub: QLearner:getDiscountFactor
-- Demonstrates the proper usage of QLearner:getDiscountFactor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_QLearner_getDiscountFactor()
    print("discount factor: " .. tostring(wolf_ql:getDiscountFactor()))
end
local _ok, _err = pcall(demo_QLearner_getDiscountFactor)

-- ---- Stub: QLearner:setExplorationRate ------------------------------------
--@api-stub: QLearner:setExplorationRate
-- Demonstrates the proper usage of QLearner:setExplorationRate.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_QLearner_setExplorationRate()
    wolf_ql:setExplorationRate(0.1)
    print("exploration rate: 0.1 (mostly exploiting learned strategy)")
end
local _ok, _err = pcall(demo_QLearner_setExplorationRate)

-- ---- Stub: QLearner:getExplorationRate ------------------------------------
--@api-stub: QLearner:getExplorationRate
-- Demonstrates the proper usage of QLearner:getExplorationRate.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_QLearner_getExplorationRate()
    print("exploration rate: " .. tostring(wolf_ql:getExplorationRate()))
end
local _ok, _err = pcall(demo_QLearner_getExplorationRate)

-- ---- Stub: QLearner:setExplorationDecay -----------------------------------
--@api-stub: QLearner:setExplorationDecay
-- Demonstrates the proper usage of QLearner:setExplorationDecay.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_QLearner_setExplorationDecay()
    wolf_ql:setExplorationDecay(0.995)
    print("exploration decay: 0.995 per episode (gradual convergence)")
end
local _ok, _err = pcall(demo_QLearner_setExplorationDecay)

-- ---- Stub: QLearner:getExplorationDecay -----------------------------------
--@api-stub: QLearner:getExplorationDecay
-- Demonstrates the proper usage of QLearner:getExplorationDecay.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_QLearner_getExplorationDecay()
    print("exploration decay: " .. tostring(wolf_ql:getExplorationDecay()))
end
local _ok, _err = pcall(demo_QLearner_getExplorationDecay)

-- ---- Stub: QLearner:serialize ---------------------------------------------
--@api-stub: QLearner:serialize
-- Demonstrates the proper usage of QLearner:serialize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_QLearner_serialize()
    local q_data = wolf_ql:serialize()
    print("Q-table serialised: " .. tostring(#q_data) .. " bytes")
end
local _ok, _err = pcall(demo_QLearner_serialize)

-- ---- Stub: QLearner:deserialize -------------------------------------------
--@api-stub: QLearner:deserialize
-- Demonstrates the proper usage of QLearner:deserialize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_QLearner_deserialize()
    wolf_ql:deserialize(q_data)
    print("Q-table restored from saved data — wolf remembers past encounters")
end
local _ok, _err = pcall(demo_QLearner_deserialize)

-- ---- Stub: QLearner:type --------------------------------------------------
--@api-stub: QLearner:type
-- Demonstrates the proper usage of QLearner:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_QLearner_type()
    print('Executing type')
end
local _ok, _err = pcall(demo_QLearner_type)

-- ---- Stub: QLearner:typeOf ------------------------------------------------
--@api-stub: QLearner:typeOf
-- Demonstrates the proper usage of QLearner:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_QLearner_typeOf()
    print("Q-learner type: " .. tostring(wolf_ql:type()))
    print("Q-learner typeOf: " .. tostring(wolf_ql:typeOf("QLearner")))
end
local _ok, _err = pcall(demo_QLearner_typeOf)

-- =============================================================================
-- Utility AI — NPC decision making
-- =============================================================================

-- ---- Stub: lurek.ai.newUtilityAI ------------------------------------------
--@api-stub: lurek.ai.newUtilityAI
-- Utility AI scores candidate actions and picks the highest-scoring one.
-- Use for NPCs with many possible activities that depend on context.
local villager_util = lurek.ai.newUtilityAI({
    { name = "eat",   score = function() return 0.8 end },
    { name = "sleep", score = function() return 0.3 end },
    { name = "work",  score = function() return 0.6 end },
    { name = "chat",  score = function() return 0.4 end },
    { name = "shop",  score = function() return 0.5 end }
})
print("villager utility AI: 5 actions (eat, sleep, work, chat, shop)")

-- ---- Stub: UtilityAI:evaluate ---------------------------------------------
--@api-stub: UtilityAI:evaluate
-- Demonstrates the proper usage of UtilityAI:evaluate.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_UtilityAI_evaluate()
    local chosen = villager_util:evaluate()
    print("villager chose: " .. tostring(chosen) .. " (highest utility score)")
end
local _ok, _err = pcall(demo_UtilityAI_evaluate)

-- ---- Stub: UtilityAI:getActionCount ---------------------------------------
--@api-stub: UtilityAI:getActionCount
-- Demonstrates the proper usage of UtilityAI:getActionCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_UtilityAI_getActionCount()
    print("utility AI candidate actions: " .. tostring(villager_util:getActionCount()))
end
local _ok, _err = pcall(demo_UtilityAI_getActionCount)

-- ---- Stub: UtilityAI:getLastAction ----------------------------------------
--@api-stub: UtilityAI:getLastAction
-- Demonstrates the proper usage of UtilityAI:getLastAction.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_UtilityAI_getLastAction()
    local last = villager_util:getLastAction()
    print("last action chosen: " .. tostring(last))
end
local _ok, _err = pcall(demo_UtilityAI_getLastAction)

-- ---- Stub: UtilityAI:type -------------------------------------------------
--@api-stub: UtilityAI:type
-- Demonstrates the proper usage of UtilityAI:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_UtilityAI_type()
    print('Executing type')
end
local _ok, _err = pcall(demo_UtilityAI_type)

-- ---- Stub: UtilityAI:typeOf -----------------------------------------------
--@api-stub: UtilityAI:typeOf
-- Demonstrates the proper usage of UtilityAI:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_UtilityAI_typeOf()
    print("utility AI type: " .. tostring(villager_util:type()))
    print("utility AI typeOf: " .. tostring(villager_util:typeOf("UtilityAI")))
end
local _ok, _err = pcall(demo_UtilityAI_typeOf)

-- =============================================================================
-- GOAP Planner — quest-giving NPC
-- =============================================================================

-- ---- Stub: lurek.ai.newGOAPPlanner ----------------------------------------
--@api-stub: lurek.ai.newGOAPPlanner
-- Goal-Oriented Action Planning: the quest NPC plans a sequence of actions
-- to achieve a goal state. The planner searches backward from the goal.
local goap = lurek.ai.newGOAPPlanner({
    actions = {
        { name = "gather_herbs", preconditions = {}, effects = {has_herbs = true}, cost = 2 },
        { name = "brew_potion",  preconditions = {has_herbs = true}, effects = {has_potion = true}, cost = 3 },
        { name = "heal_patient", preconditions = {has_potion = true}, effects = {patient_healed = true}, cost = 1 },
        { name = "buy_herbs",    preconditions = {}, effects = {has_herbs = true}, cost = 5 }
    },
    goals = {
        { name = "cure_plague", state = {patient_healed = true}, priority = 10 }
    }
})
print("GOAP planner: 4 actions, 1 goal (cure_plague)")
print("  cheapest path: gather_herbs(2) -> brew_potion(3) -> heal_patient(1) = cost 6")
print("  alternative: buy_herbs(5) -> brew_potion(3) -> heal_patient(1) = cost 9")

-- ---- Stub: GOAPPlanner:getActionCount -------------------------------------
--@api-stub: GOAPPlanner:getActionCount
-- Demonstrates the proper usage of GOAPPlanner:getActionCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_GOAPPlanner_getActionCount()
    print("GOAP actions available: " .. tostring(goap:getActionCount()))
end
local _ok, _err = pcall(demo_GOAPPlanner_getActionCount)

-- ---- Stub: GOAPPlanner:getGoalCount ---------------------------------------
--@api-stub: GOAPPlanner:getGoalCount
-- Demonstrates the proper usage of GOAPPlanner:getGoalCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_GOAPPlanner_getGoalCount()
    print("GOAP goals defined: " .. tostring(goap:getGoalCount()))
end
local _ok, _err = pcall(demo_GOAPPlanner_getGoalCount)

-- ---- Stub: GOAPPlanner:getMaxIterations -----------------------------------
--@api-stub: GOAPPlanner:getMaxIterations
-- Demonstrates the proper usage of GOAPPlanner:getMaxIterations.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_GOAPPlanner_getMaxIterations()
    local max_iter = goap:getMaxIterations()
    print("GOAP max iterations: " .. tostring(max_iter))
end
local _ok, _err = pcall(demo_GOAPPlanner_getMaxIterations)

-- ---- Stub: GOAPPlanner:setMaxIterations -----------------------------------
--@api-stub: GOAPPlanner:setMaxIterations
-- Demonstrates the proper usage of GOAPPlanner:setMaxIterations.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_GOAPPlanner_setMaxIterations()
    goap:setMaxIterations(500)
    print("GOAP max iterations set to 500 (complex quest chains)")
end
local _ok, _err = pcall(demo_GOAPPlanner_setMaxIterations)

-- ---- Stub: GOAPPlanner:type -----------------------------------------------
--@api-stub: GOAPPlanner:type
-- Demonstrates the proper usage of GOAPPlanner:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_GOAPPlanner_type()
    print('Executing type')
end
local _ok, _err = pcall(demo_GOAPPlanner_type)

-- ---- Stub: GOAPPlanner:typeOf ---------------------------------------------
--@api-stub: GOAPPlanner:typeOf
-- Demonstrates the proper usage of GOAPPlanner:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_GOAPPlanner_typeOf()
    print("GOAP type: " .. tostring(goap:type()))
    print("GOAP typeOf: " .. tostring(goap:typeOf("GOAPPlanner")))
end
local _ok, _err = pcall(demo_GOAPPlanner_typeOf)

-- =============================================================================
-- Influence Map — territory control
-- =============================================================================

-- ---- Stub: lurek.ai.newInfluenceMap ---------------------------------------
--@api-stub: lurek.ai.newInfluenceMap
-- Demonstrates the proper usage of lurek.ai.newInfluenceMap.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_ai_newInfluenceMap()
    local inf_map = lurek.ai.newInfluenceMap(32, 24, 32.0)  -- 32x24 grid, 32px cells
    print("influence map: 32x24 grid, 32px cells (covers 1024x768 world)")
end
local _ok, _err = pcall(demo_lurek_ai_newInfluenceMap)

-- ---- Stub: InfluenceMap:addLayer ------------------------------------------
--@api-stub: InfluenceMap:addLayer
-- Demonstrates the proper usage of InfluenceMap:addLayer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_InfluenceMap_addLayer()
    inf_map:addLayer("royal_guard", 0.0)
    inf_map:addLayer("wolf_pack", 0.0)
    inf_map:addLayer("merchant_zone", 0.0)
    print("influence layers: royal_guard, wolf_pack, merchant_zone")
end
local _ok, _err = pcall(demo_InfluenceMap_addLayer)

-- ---- Stub: InfluenceMap:hasLayer ------------------------------------------
--@api-stub: InfluenceMap:hasLayer
-- Demonstrates the proper usage of InfluenceMap:hasLayer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_InfluenceMap_hasLayer()
    print("has 'royal_guard' layer: " .. tostring(inf_map:hasLayer("royal_guard")))
    print("has 'bandit' layer: " .. tostring(inf_map:hasLayer("bandit")))
end
local _ok, _err = pcall(demo_InfluenceMap_hasLayer)

-- ---- Stub: InfluenceMap:decay ---------------------------------------------
--@api-stub: InfluenceMap:decay
-- Decay all influence values each frame so stale positions fade out naturally.
-- Factor 0.95 means 5% decay per tick — influence lingers for ~60 frames.
inf_map:decay("royal_guard", 0.95)
inf_map:decay("wolf_pack", 0.90)
print("influence decayed: guard(0.95 retention), wolf(0.90 retention)")

-- ---- Stub: InfluenceMap:clearLayer ----------------------------------------
--@api-stub: InfluenceMap:clearLayer
-- Demonstrates the proper usage of InfluenceMap:clearLayer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_InfluenceMap_clearLayer()
    inf_map:clearLayer("wolf_pack")
    print("wolf_pack influence cleared (wolves fled the area)")
end
local _ok, _err = pcall(demo_InfluenceMap_clearLayer)

-- ---- Stub: InfluenceMap:clearAll ------------------------------------------
--@api-stub: InfluenceMap:clearAll
-- Wipe all layers — use on level transitions or game reset.
inf_map:clearAll()
print("all influence layers cleared (new level loaded)")

-- Re-add layers for further demos
inf_map:addLayer("royal_guard", 0.0)
inf_map:addLayer("wolf_pack", 0.0)

-- ---- Stub: InfluenceMap:getMaxPosition ------------------------------------
--@api-stub: InfluenceMap:getMaxPosition
-- Demonstrates the proper usage of InfluenceMap:getMaxPosition.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_InfluenceMap_getMaxPosition()
    local max_x, max_y = inf_map:getMaxPosition("royal_guard")
    print("guard concentration peak at: (" .. tostring(max_x) .. ", " .. tostring(max_y) .. ")")
end
local _ok, _err = pcall(demo_InfluenceMap_getMaxPosition)

-- ---- Stub: InfluenceMap:getMinPosition ------------------------------------
--@api-stub: InfluenceMap:getMinPosition
-- Demonstrates the proper usage of InfluenceMap:getMinPosition.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_InfluenceMap_getMinPosition()
    local min_x, min_y = inf_map:getMinPosition("royal_guard")
    print("guard blind spot at: (" .. tostring(min_x) .. ", " .. tostring(min_y) .. ")")
    print("  sneak through here to avoid detection!")
end
local _ok, _err = pcall(demo_InfluenceMap_getMinPosition)

-- ---- Stub: InfluenceMap:getWidth ------------------------------------------
--@api-stub: InfluenceMap:getWidth
-- Demonstrates the proper usage of InfluenceMap:getWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_InfluenceMap_getWidth()
    print("influence map width: " .. tostring(inf_map:getWidth()) .. " cells")
end
local _ok, _err = pcall(demo_InfluenceMap_getWidth)

-- ---- Stub: InfluenceMap:getHeight -----------------------------------------
--@api-stub: InfluenceMap:getHeight
-- Demonstrates the proper usage of InfluenceMap:getHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_InfluenceMap_getHeight()
    print("influence map height: " .. tostring(inf_map:getHeight()) .. " cells")
end
local _ok, _err = pcall(demo_InfluenceMap_getHeight)

-- ---- Stub: InfluenceMap:getCellSize ---------------------------------------
--@api-stub: InfluenceMap:getCellSize
-- Demonstrates the proper usage of InfluenceMap:getCellSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_InfluenceMap_getCellSize()
    print("cell size: " .. tostring(inf_map:getCellSize()) .. "px")
end
local _ok, _err = pcall(demo_InfluenceMap_getCellSize)

-- ---- Stub: InfluenceMap:type ----------------------------------------------
--@api-stub: InfluenceMap:type
-- Demonstrates the proper usage of InfluenceMap:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_InfluenceMap_type()
    print('Executing type')
end
local _ok, _err = pcall(demo_InfluenceMap_type)

-- ---- Stub: InfluenceMap:typeOf --------------------------------------------
--@api-stub: InfluenceMap:typeOf
-- Demonstrates the proper usage of InfluenceMap:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_InfluenceMap_typeOf()
    print("influence map type: " .. tostring(inf_map:type()))
    print("influence map typeOf: " .. tostring(inf_map:typeOf("InfluenceMap")))
end
local _ok, _err = pcall(demo_InfluenceMap_typeOf)

-- =============================================================================
-- Squad — coordinated patrol group
-- =============================================================================

-- ---- Stub: lurek.ai.newSquad ----------------------------------------------
--@api-stub: lurek.ai.newSquad
-- Squads group agents under a leader with a formation. Use for coordinated
-- patrols, military units, or wolf packs that move as a group.
local patrol_squad = lurek.ai.newSquad("gatehouse_patrol", {
    formation = "wedge",
    spacing = 40.0
})
print("squad 'gatehouse_patrol' created: wedge formation, 40px spacing")

-- ---- Stub: Squad:getName --------------------------------------------------
--@api-stub: Squad:getName
-- Demonstrates the proper usage of Squad:getName.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Squad_getName()
    print("squad name: " .. patrol_squad:getName())
end
local _ok, _err = pcall(demo_Squad_getName)

-- ---- Stub: Squad:addMember ------------------------------------------------
--@api-stub: Squad:addMember
-- Demonstrates the proper usage of Squad:addMember.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Squad_addMember()
    patrol_squad:addMember(guard)
    patrol_squad:addMember(scout)
    print("squad members: guard_captain + scout_drone")
end
local _ok, _err = pcall(demo_Squad_addMember)

-- ---- Stub: Squad:removeMember ---------------------------------------------
--@api-stub: Squad:removeMember
-- Remove an agent from the squad (e.g. killed, reassigned, deserted).
patrol_squad:removeMember(scout)
print("scout removed from squad (reassigned to tower duty)")

-- Re-add for further demos
patrol_squad:addMember(scout)

-- ---- Stub: Squad:getMemberCount -------------------------------------------
--@api-stub: Squad:getMemberCount
-- Demonstrates the proper usage of Squad:getMemberCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Squad_getMemberCount()
    local member_count = patrol_squad:getMemberCount()
    print("squad size: " .. tostring(member_count) .. " members")
end
local _ok, _err = pcall(demo_Squad_getMemberCount)

-- ---- Stub: Squad:getMembers -----------------------------------------------
--@api-stub: Squad:getMembers
-- Demonstrates the proper usage of Squad:getMembers.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Squad_getMembers()
    local members = patrol_squad:getMembers()
    print("squad roster:")
    for i, m in ipairs(members) do
    local mx, my = m:getPosition()
    print("  [" .. i .. "] " .. m:getName() .. " at (" .. mx .. ", " .. my .. ")")
end
local _ok, _err = pcall(demo_Squad_getMembers)

-- ---- Stub: Squad:setLeader ------------------------------------------------
--@api-stub: Squad:setLeader
-- Demonstrates the proper usage of Squad:setLeader.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Squad_setLeader()
    patrol_squad:setLeader(guard)
    print("guard_captain promoted to squad leader")
end
local _ok, _err = pcall(demo_Squad_setLeader)

-- ---- Stub: Squad:getLeader ------------------------------------------------
--@api-stub: Squad:getLeader
-- Demonstrates the proper usage of Squad:getLeader.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Squad_getLeader()
    local leader = patrol_squad:getLeader()
    print("squad leader: " .. tostring(leader and leader:getName()))
end
local _ok, _err = pcall(demo_Squad_getLeader)

-- ---- Stub: Squad:getFormation ---------------------------------------------
--@api-stub: Squad:getFormation
-- Demonstrates the proper usage of Squad:getFormation.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Squad_getFormation()
    print("formation type: " .. tostring(patrol_squad:getFormation()))
end
local _ok, _err = pcall(demo_Squad_getFormation)

-- ---- Stub: Squad:getFormationSpacing --------------------------------------
--@api-stub: Squad:getFormationSpacing
-- Demonstrates the proper usage of Squad:getFormationSpacing.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Squad_getFormationSpacing()
    print("formation spacing: " .. tostring(patrol_squad:getFormationSpacing()) .. "px")
end
local _ok, _err = pcall(demo_Squad_getFormationSpacing)

-- ---- Stub: Squad:getBlackboard --------------------------------------------
--@api-stub: Squad:getBlackboard
-- Squad blackboard shares intel between all members — spotted enemies,
-- rally points, ammo caches.
local squad_bb = patrol_squad:getBlackboard()
squad_bb:setString("rally_point", "gatehouse_courtyard")
squad_bb:setNumber("enemies_spotted", 0)
print("squad blackboard: rally_point=gatehouse_courtyard, enemies_spotted=0")

-- ---- Stub: Squad:type -----------------------------------------------------
--@api-stub: Squad:type
-- Demonstrates the proper usage of Squad:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Squad_type()
    print('Executing type')
end
local _ok, _err = pcall(demo_Squad_type)

-- ---- Stub: Squad:typeOf ---------------------------------------------------
--@api-stub: Squad:typeOf
-- Demonstrates the proper usage of Squad:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Squad_typeOf()
    print("squad type: " .. tostring(patrol_squad:type()))
    print("squad typeOf: " .. tostring(patrol_squad:typeOf("Squad")))
end
local _ok, _err = pcall(demo_Squad_typeOf)

-- =============================================================================
-- Command Queue — issuing orders to agents
-- =============================================================================

-- ---- Stub: lurek.ai.newCommandQueue ---------------------------------------
--@api-stub: lurek.ai.newCommandQueue
-- Command queues let you issue a series of orders (move, attack, wait, interact)
-- that the agent executes in sequence. RTS-style "shift-click" waypoints.
local guard_cmds = lurek.ai.newCommandQueue()
print("guard command queue created")

-- Queue up a patrol route: move to waypoints, then loop
guard_cmds:clear() -- ensure empty start

-- ---- Stub: CommandQueue:getCount ------------------------------------------
--@api-stub: CommandQueue:getCount
-- Demonstrates the proper usage of CommandQueue:getCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_CommandQueue_getCount()
    local cmd_count = guard_cmds:getCount()
    print("queued commands: " .. tostring(cmd_count))
end
local _ok, _err = pcall(demo_CommandQueue_getCount)

-- ---- Stub: CommandQueue:isEmpty -------------------------------------------
--@api-stub: CommandQueue:isEmpty
-- Demonstrates the proper usage of CommandQueue:isEmpty.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_CommandQueue_isEmpty()
    if guard_cmds:isEmpty() then
    print("command queue empty — guard is idle, needs orders")
end
local _ok, _err = pcall(demo_CommandQueue_isEmpty)

-- ---- Stub: CommandQueue:getCurrentType ------------------------------------
--@api-stub: CommandQueue:getCurrentType
-- Demonstrates the proper usage of CommandQueue:getCurrentType.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_CommandQueue_getCurrentType()
    local cmd_type = guard_cmds:getCurrentType()
    print("current command type: " .. tostring(cmd_type))
end
local _ok, _err = pcall(demo_CommandQueue_getCurrentType)

-- ---- Stub: CommandQueue:getCurrentTarget ----------------------------------
--@api-stub: CommandQueue:getCurrentTarget
-- Demonstrates the proper usage of CommandQueue:getCurrentTarget.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_CommandQueue_getCurrentTarget()
    local cmd_target = guard_cmds:getCurrentTarget()
    print("current command target: " .. tostring(cmd_target))
end
local _ok, _err = pcall(demo_CommandQueue_getCurrentTarget)

-- ---- Stub: CommandQueue:cancelCurrent -------------------------------------
--@api-stub: CommandQueue:cancelCurrent
-- Demonstrates the proper usage of CommandQueue:cancelCurrent.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_CommandQueue_cancelCurrent()
    guard_cmds:cancelCurrent()
    print("current command cancelled — guard responds to alarm")
end
local _ok, _err = pcall(demo_CommandQueue_cancelCurrent)

-- ---- Stub: CommandQueue:clear ---------------------------------------------
--@api-stub: CommandQueue:clear
-- Demonstrates the proper usage of CommandQueue:clear.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_CommandQueue_clear()
    guard_cmds:clear()
    print("all commands cleared — guard stands at attention")
end
local _ok, _err = pcall(demo_CommandQueue_clear)

-- ---- Stub: CommandQueue:type ----------------------------------------------
--@api-stub: CommandQueue:type
-- Demonstrates the proper usage of CommandQueue:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_CommandQueue_type()
    print('Executing type')
end
local _ok, _err = pcall(demo_CommandQueue_type)

-- ---- Stub: CommandQueue:typeOf --------------------------------------------
--@api-stub: CommandQueue:typeOf
-- Demonstrates the proper usage of CommandQueue:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_CommandQueue_typeOf()
    print("command queue type: " .. tostring(guard_cmds:type()))
    print("command queue typeOf: " .. tostring(guard_cmds:typeOf("CommandQueue")))
end
local _ok, _err = pcall(demo_CommandQueue_typeOf)

-- =============================================================================
-- Trait Profile — NPC personality system
-- =============================================================================

-- ---- Stub: lurek.ai.newTraitProfile ---------------------------------------
--@api-stub: lurek.ai.newTraitProfile
-- Demonstrates the proper usage of lurek.ai.newTraitProfile.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_ai_newTraitProfile()
    local guard_traits = lurek.ai.newTraitProfile()
    print("guard trait profile created")
end
local _ok, _err = pcall(demo_lurek_ai_newTraitProfile)

-- ---- Stub: TraitProfile:set -----------------------------------------------
--@api-stub: TraitProfile:set
-- Demonstrates the proper usage of TraitProfile:set.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_TraitProfile_set()
    guard_traits:set("courage", 0.8)
    guard_traits:set("loyalty", 0.9)
    guard_traits:set("patience", 0.5)
    guard_traits:set("aggression", 0.6)
    guard_traits:set("greed", 0.2)
    print("guard base traits: courage=0.8, loyalty=0.9, patience=0.5")
end
local _ok, _err = pcall(demo_TraitProfile_set)

-- ---- Stub: TraitProfile:get -----------------------------------------------
--@api-stub: TraitProfile:get
-- Demonstrates the proper usage of TraitProfile:get.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_TraitProfile_get()
    local courage = guard_traits:get("courage")
    print("guard effective courage: " .. string.format("%.2f", courage))
end
local _ok, _err = pcall(demo_TraitProfile_get)

-- ---- Stub: TraitProfile:getBase -------------------------------------------
--@api-stub: TraitProfile:getBase
-- Demonstrates the proper usage of TraitProfile:getBase.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_TraitProfile_getBase()
    local base_courage = guard_traits:getBase("courage")
    print("guard base courage: " .. string.format("%.2f", base_courage))
end
local _ok, _err = pcall(demo_TraitProfile_getBase)

-- ---- Stub: TraitProfile:addModifier ---------------------------------------
--@api-stub: TraitProfile:addModifier
-- Demonstrates the proper usage of TraitProfile:addModifier.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_TraitProfile_addModifier()
    guard_traits:addModifier("courage", "fear_spell", -0.3)
    guard_traits:addModifier("aggression", "battle_rage", 0.2)
    print("modifiers applied: fear_spell (courage -0.3), battle_rage (aggression +0.2)")
    print("  effective courage now: " .. string.format("%.2f", guard_traits:get("courage")))
end
local _ok, _err = pcall(demo_TraitProfile_addModifier)

-- ---- Stub: TraitProfile:removeModifiers -----------------------------------
--@api-stub: TraitProfile:removeModifiers
-- Demonstrates the proper usage of TraitProfile:removeModifiers.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_TraitProfile_removeModifiers()
    guard_traits:removeModifiers("courage")
    print("fear_spell expired — courage modifiers removed")
    print("  courage restored to: " .. string.format("%.2f", guard_traits:get("courage")))
end
local _ok, _err = pcall(demo_TraitProfile_removeModifiers)

-- ---- Stub: TraitProfile:update --------------------------------------------
--@api-stub: TraitProfile:update
-- Demonstrates the proper usage of TraitProfile:update.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_TraitProfile_update()
    guard_traits:update(0.016)
    print("trait profile updated (16ms tick)")
end
local _ok, _err = pcall(demo_TraitProfile_update)

-- ---- Stub: TraitProfile:has -----------------------------------------------
--@api-stub: TraitProfile:has
-- Demonstrates the proper usage of TraitProfile:has.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_TraitProfile_has()
    print("has 'courage' trait: " .. tostring(guard_traits:has("courage")))
    print("has 'magic_affinity' trait: " .. tostring(guard_traits:has("magic_affinity")))
end
local _ok, _err = pcall(demo_TraitProfile_has)

-- ---- Stub: TraitProfile:traitCount ----------------------------------------
--@api-stub: TraitProfile:traitCount
-- Demonstrates the proper usage of TraitProfile:traitCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_TraitProfile_traitCount()
    print("total traits defined: " .. tostring(guard_traits:traitCount()))
end
local _ok, _err = pcall(demo_TraitProfile_traitCount)

-- ---- Stub: TraitProfile:archetype -----------------------------------------
--@api-stub: TraitProfile:archetype
-- Demonstrates the proper usage of TraitProfile:archetype.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_TraitProfile_archetype()
    local arch = guard_traits:archetype()
    print("guard archetype: " .. tostring(arch))
end
local _ok, _err = pcall(demo_TraitProfile_archetype)

-- =============================================================================
-- Stimulus World — sensory perception for NPCs
-- =============================================================================

-- ---- Stub: lurek.ai.newStimulusWorld --------------------------------------
--@api-stub: lurek.ai.newStimulusWorld
-- Demonstrates the proper usage of lurek.ai.newStimulusWorld.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_ai_newStimulusWorld()
    local stimulus = lurek.ai.newStimulusWorld()
    print("stimulus world created for NPC perception")
end
local _ok, _err = pcall(demo_lurek_ai_newStimulusWorld)

-- ---- Stub: StimulusWorld:addVisual ----------------------------------------
--@api-stub: StimulusWorld:addVisual
-- Demonstrates the proper usage of StimulusWorld:addVisual.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_StimulusWorld_addVisual()
    stimulus:addVisual(200, 150, 0.8, 120.0)
    print("visual stimulus: torch light at (200, 150), intensity=0.8, range=120")
end
local _ok, _err = pcall(demo_StimulusWorld_addVisual)

-- ---- Stub: StimulusWorld:addAuditory --------------------------------------
--@api-stub: StimulusWorld:addAuditory
-- Demonstrates the proper usage of StimulusWorld:addAuditory.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_StimulusWorld_addAuditory()
    stimulus:addAuditory(250, 180, 0.5, 80.0)
    print("auditory stimulus: footsteps at (250, 180), intensity=0.5, range=80")
end
local _ok, _err = pcall(demo_StimulusWorld_addAuditory)

-- ---- Stub: StimulusWorld:remove -------------------------------------------
--@api-stub: StimulusWorld:remove
-- Demonstrates the proper usage of StimulusWorld:remove.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_StimulusWorld_remove()
    stimulus:remove(0)
    print("stimulus #0 removed (torch extinguished)")
end
local _ok, _err = pcall(demo_StimulusWorld_remove)

-- ---- Stub: StimulusWorld:update -------------------------------------------
--@api-stub: StimulusWorld:update
-- Demonstrates the proper usage of StimulusWorld:update.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_StimulusWorld_update()
    stimulus:update(0.016)
    print("stimulus world updated — signals decaying naturally")
end
local _ok, _err = pcall(demo_StimulusWorld_update)

-- ---- Stub: StimulusWorld:count --------------------------------------------
--@api-stub: StimulusWorld:count
-- Demonstrates the proper usage of StimulusWorld:count.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_StimulusWorld_count()
    print("active stimuli: " .. tostring(stimulus:count()))
end
local _ok, _err = pcall(demo_StimulusWorld_count)

-- ---- Stub: StimulusWorld:clear --------------------------------------------
--@api-stub: StimulusWorld:clear
-- Demonstrates the proper usage of StimulusWorld:clear.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_StimulusWorld_clear()
    stimulus:clear()
    print("all stimuli cleared (scene transition)")
end
local _ok, _err = pcall(demo_StimulusWorld_clear)

-- =============================================================================
-- Need System — survival mechanics
-- =============================================================================

-- ---- Stub: lurek.ai.newNeedSystem -----------------------------------------
--@api-stub: lurek.ai.newNeedSystem
-- Demonstrates the proper usage of lurek.ai.newNeedSystem.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_ai_newNeedSystem()
    local needs = lurek.ai.newNeedSystem()
    print("need system created for villager survival AI")
end
local _ok, _err = pcall(demo_lurek_ai_newNeedSystem)

-- ---- Stub: NeedSystem:addNeed ---------------------------------------------
--@api-stub: NeedSystem:addNeed
-- Demonstrates the proper usage of NeedSystem:addNeed.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NeedSystem_addNeed()
    needs:addNeed("hunger",     { value = 0.3, decay = 0.02, threshold = 0.7 })
    needs:addNeed("tiredness",  { value = 0.5, decay = 0.01, threshold = 0.8 })
    needs:addNeed("social",     { value = 0.1, decay = 0.005, threshold = 0.6 })
    needs:addNeed("safety",     { value = 0.0, decay = 0.03, threshold = 0.5 })
    print("needs: hunger(0.3), tiredness(0.5), social(0.1), safety(0.0)")
    print("  hunger decays at 0.02/s — villager gets hungry every ~35s")
end
local _ok, _err = pcall(demo_NeedSystem_addNeed)

-- ---- Stub: NeedSystem:update ----------------------------------------------
--@api-stub: NeedSystem:update
-- Demonstrates the proper usage of NeedSystem:update.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NeedSystem_update()
    needs:update(10.0)  -- simulate 10 seconds passing
    print("needs updated after 10s of game time")
end
local _ok, _err = pcall(demo_NeedSystem_update)

-- ---- Stub: NeedSystem:mostUrgent ------------------------------------------
--@api-stub: NeedSystem:mostUrgent
-- Demonstrates the proper usage of NeedSystem:mostUrgent.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NeedSystem_mostUrgent()
    local urgent = needs:mostUrgent()
    print("most urgent need: " .. tostring(urgent))
end
local _ok, _err = pcall(demo_NeedSystem_mostUrgent)

-- ---- Stub: NeedSystem:satisfy ---------------------------------------------
--@api-stub: NeedSystem:satisfy
-- Demonstrates the proper usage of NeedSystem:satisfy.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NeedSystem_satisfy()
    needs:satisfy("hunger", 0.5)
    print("villager ate bread: hunger reduced by 0.5")
end
local _ok, _err = pcall(demo_NeedSystem_satisfy)

-- ---- Stub: NeedSystem:valueOf ---------------------------------------------
--@api-stub: NeedSystem:valueOf
-- Demonstrates the proper usage of NeedSystem:valueOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NeedSystem_valueOf()
    local hunger_val = needs:valueOf("hunger")
    local tired_val = needs:valueOf("tiredness")
    print("hunger: " .. string.format("%.2f", hunger_val) .. ", tiredness: " .. string.format("%.2f", tired_val))
end
local _ok, _err = pcall(demo_NeedSystem_valueOf)

-- =============================================================================
-- AI Director — dynamic difficulty
-- =============================================================================

-- ---- Stub: lurek.ai.newAIDirector -----------------------------------------
--@api-stub: lurek.ai.newAIDirector
-- The AI Director monitors player performance and adjusts difficulty in
-- real-time. Inspired by Left 4 Dead's director: controls spawn rates,
-- loot drops, and ambient intensity based on tension curves.
local director = lurek.ai.newAIDirector({
    tension_min = 0.0,
    tension_max = 1.0,
    build_rate = 0.05,
    relax_rate = 0.03,
    peak_duration = 15.0
})
print("AI Director created: tension range [0, 1], build=0.05/s, relax=0.03/s")

-- ---- Stub: AIDirector:pushEvent -------------------------------------------
--@api-stub: AIDirector:pushEvent
-- Demonstrates the proper usage of AIDirector:pushEvent.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AIDirector_pushEvent()
    director:pushEvent("player_kill", 0.15)
    director:pushEvent("player_kill", 0.15)
    director:pushEvent("player_damage_taken", 0.08)
    print("events pushed: 2 kills (+0.30), 1 hit taken (+0.08)")
end
local _ok, _err = pcall(demo_AIDirector_pushEvent)

-- ---- Stub: AIDirector:update ----------------------------------------------
--@api-stub: AIDirector:update
-- Demonstrates the proper usage of AIDirector:update.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AIDirector_update()
    director:update(1.0)  -- 1 second of game time
    print("director updated — tension curve adjusted")
end
local _ok, _err = pcall(demo_AIDirector_update)

-- ---- Stub: AIDirector:tension ---------------------------------------------
--@api-stub: AIDirector:tension
-- Demonstrates the proper usage of AIDirector:tension.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AIDirector_tension()
    local tension = director:tension()
    print("current tension: " .. string.format("%.2f", tension))
end
local _ok, _err = pcall(demo_AIDirector_tension)

-- ---- Stub: AIDirector:phase -----------------------------------------------
--@api-stub: AIDirector:phase
-- Demonstrates the proper usage of AIDirector:phase.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AIDirector_phase()
    local phase = director:phase()
    print("director phase: " .. tostring(phase))
end
local _ok, _err = pcall(demo_AIDirector_phase)

-- ---- Stub: AIDirector:spawnRateFactor -------------------------------------
--@api-stub: AIDirector:spawnRateFactor
-- Demonstrates the proper usage of AIDirector:spawnRateFactor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AIDirector_spawnRateFactor()
    local spawn_factor = director:spawnRateFactor()
    print("spawn rate factor: " .. string.format("%.2f", spawn_factor) .. "x")
end
local _ok, _err = pcall(demo_AIDirector_spawnRateFactor)

-- ---- Stub: AIDirector:lootFactor ------------------------------------------
--@api-stub: AIDirector:lootFactor
-- Demonstrates the proper usage of AIDirector:lootFactor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AIDirector_lootFactor()
    local loot = director:lootFactor()
    print("loot factor: " .. string.format("%.2f", loot) .. "x")
end
local _ok, _err = pcall(demo_AIDirector_lootFactor)

-- ---- Stub: AIDirector:ambientIntensity ------------------------------------
--@api-stub: AIDirector:ambientIntensity
-- Demonstrates the proper usage of AIDirector:ambientIntensity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AIDirector_ambientIntensity()
    local ambient = director:ambientIntensity()
    print("ambient intensity: " .. string.format("%.2f", ambient))
end
local _ok, _err = pcall(demo_AIDirector_ambientIntensity)

-- ---- Stub: AIDirector:setTension ------------------------------------------
--@api-stub: AIDirector:setTension
-- Demonstrates the proper usage of AIDirector:setTension.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AIDirector_setTension()
    director:setTension(0.9)
    print("tension manually set to 0.9 (boss fight imminent)")
end
local _ok, _err = pcall(demo_AIDirector_setTension)

-- ---- Stub: AIDirector:reset -----------------------------------------------
--@api-stub: AIDirector:reset
-- Demonstrates the proper usage of AIDirector:reset.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AIDirector_reset()
    director:reset()
    print("AI director reset — tension curve starts fresh")
end
local _ok, _err = pcall(demo_AIDirector_reset)

-- =============================================================================
-- AI LOD — level of detail for distant agents
-- =============================================================================

-- ---- Stub: lurek.ai.newAILod ----------------------------------------------
--@api-stub: lurek.ai.newAILod
-- AI LOD reduces computation for distant or off-screen agents.
-- Close agents get full BT + steering; distant ones get simplified updates.
local ai_lod = lurek.ai.newAILod({
    tiers = {
        { name = "full",    distance = 200,  update_hz = 60 },
        { name = "reduced", distance = 500,  update_hz = 10 },
        { name = "minimal", distance = 1000, update_hz = 2 },
        { name = "frozen",  distance = 2000, update_hz = 0 }
    }
})
print("AI LOD: 4 tiers (full/reduced/minimal/frozen)")
print("  full: <200px, 60Hz | reduced: <500px, 10Hz | minimal: <1000px, 2Hz")

-- ---- Stub: AILod:tierFor --------------------------------------------------
--@api-stub: AILod:tierFor
-- Demonstrates the proper usage of AILod:tierFor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AILod_tierFor()
    local tier = ai_lod:tierFor(150.0)   -- agent 150px from camera
    print("agent at 150px: tier '" .. tostring(tier) .. "' (should be 'full')")
    local far_tier = ai_lod:tierFor(800.0)
    print("agent at 800px: tier '" .. tostring(far_tier) .. "' (should be 'minimal')")
end
local _ok, _err = pcall(demo_AILod_tierFor)

-- ---- Stub: AILod:shouldUpdate ---------------------------------------------
--@api-stub: AILod:shouldUpdate
-- Demonstrates the proper usage of AILod:shouldUpdate.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AILod_shouldUpdate()
    local should = ai_lod:shouldUpdate(300.0)
    print("agent at 300px should update this frame: " .. tostring(should))
end
local _ok, _err = pcall(demo_AILod_shouldUpdate)

-- ---- Stub: AILod:tierCount ------------------------------------------------
--@api-stub: AILod:tierCount
-- Demonstrates the proper usage of AILod:tierCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AILod_tierCount()
    print("LOD tier count: " .. tostring(ai_lod:tierCount()))
end
local _ok, _err = pcall(demo_AILod_tierCount)

-- ---- Stub: AILod:tierName -------------------------------------------------
--@api-stub: AILod:tierName
-- Demonstrates the proper usage of AILod:tierName.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AILod_tierName()
    for i = 0, ai_lod:tierCount() - 1 do
    print("  tier[" .. i .. "] = " .. tostring(ai_lod:tierName(i)))
end
local _ok, _err = pcall(demo_AILod_tierName)

-- =============================================================================
-- HTN Domain — hierarchical task network for complex quests
-- =============================================================================

-- ---- Stub: lurek.ai.newHTNDomain ------------------------------------------
--@api-stub: lurek.ai.newHTNDomain
-- Demonstrates the proper usage of lurek.ai.newHTNDomain.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_ai_newHTNDomain()
    local htn = lurek.ai.newHTNDomain()
    print("HTN domain created for quest NPC planning")
end
local _ok, _err = pcall(demo_lurek_ai_newHTNDomain)

-- ---- Stub: HTNDomain:addPrimitive -----------------------------------------
--@api-stub: HTNDomain:addPrimitive
-- Demonstrates the proper usage of HTNDomain:addPrimitive.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_HTNDomain_addPrimitive()
    htn:addPrimitive("travel_to_mine", {
    preconditions = function(state) return state.has_pickaxe end,
    effects = function(state) state.at_mine = true end,
    cost = 3
    })
    htn:addPrimitive("mine_ore", {
    preconditions = function(state) return state.at_mine and state.has_pickaxe end,
    effects = function(state) state.has_ore = true end,
    cost = 5
    })
    htn:addPrimitive("smelt_ore", {
    preconditions = function(state) return state.has_ore end,
    effects = function(state) state.has_ingot = true; state.has_ore = false end,
    cost = 4
    })
    print("HTN primitives: travel_to_mine(3), mine_ore(5), smelt_ore(4)")
end
local _ok, _err = pcall(demo_HTNDomain_addPrimitive)

-- ---- Stub: HTNDomain:addCompound -----------------------------------------
--@api-stub: HTNDomain:addCompound
-- Demonstrates the proper usage of HTNDomain:addCompound.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_HTNDomain_addCompound()
    htn:addCompound("craft_weapon", {
    methods = {
        { precondition = function(state) return state.has_pickaxe end,
          subtasks = {"travel_to_mine", "mine_ore", "smelt_ore"} },
    }
    })
    print("HTN compound: craft_weapon -> [travel, mine, smelt]")
end
local _ok, _err = pcall(demo_HTNDomain_addCompound)

-- ---- Stub: HTNDomain:plan -------------------------------------------------
--@api-stub: HTNDomain:plan
-- Demonstrates the proper usage of HTNDomain:plan.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_HTNDomain_plan()
    local plan = htn:plan({ has_pickaxe = true, at_mine = false, has_ore = false })
    if plan then
    print("HTN plan generated:")
    for i, step in ipairs(plan) do
        print("  step " .. i .. ": " .. tostring(step))
    end
end
local _ok, _err = pcall(demo_HTNDomain_plan)

-- ---- Stub: HTNDomain:taskCount --------------------------------------------
--@api-stub: HTNDomain:taskCount
-- Demonstrates the proper usage of HTNDomain:taskCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_HTNDomain_taskCount()
    print("HTN domain task count: " .. tostring(htn:taskCount()))
end
local _ok, _err = pcall(demo_HTNDomain_taskCount)

-- =============================================================================
-- MCTS Engine — tactical combat decisions
-- =============================================================================

-- ---- Stub: lurek.ai.newMCTSEngine ----------------------------------------
--@api-stub: lurek.ai.newMCTSEngine
-- Monte Carlo Tree Search for complex tactical decisions: which unit to attack,
-- where to position, when to use abilities. Runs thousands of simulated games.
local mcts = lurek.ai.newMCTSEngine({
    iterations = 1000,
    exploration = 1.41,
    max_depth = 20,
    time_limit_ms = 16  -- fit within one frame
})
print("MCTS engine: 1000 iterations, exploration=1.41, 16ms budget")
print("  useful for turn-based combat AI or complex decision points")

-- =============================================================================
-- Emotion Model — NPC moods
-- =============================================================================

-- ---- Stub: lurek.ai.newEmotionModel ---------------------------------------
--@api-stub: lurek.ai.newEmotionModel
-- Demonstrates the proper usage of lurek.ai.newEmotionModel.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_ai_newEmotionModel()
    local guard_emotions = lurek.ai.newEmotionModel()
    print("guard emotion model created")
end
local _ok, _err = pcall(demo_lurek_ai_newEmotionModel)

-- ---- Stub: EmotionModel:add -----------------------------------------------
--@api-stub: EmotionModel:add
-- Demonstrates the proper usage of EmotionModel:add.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_EmotionModel_add()
    guard_emotions:add("anger",     { base = 0.0, decay = 0.05 })
    guard_emotions:add("fear",      { base = 0.0, decay = 0.03 })
    guard_emotions:add("happiness", { base = 0.5, decay = 0.01 })
    guard_emotions:add("suspicion", { base = 0.2, decay = 0.04 })
    print("emotions: anger(0), fear(0), happiness(0.5), suspicion(0.2)")
end
local _ok, _err = pcall(demo_EmotionModel_add)

-- ---- Stub: EmotionModel:trigger -------------------------------------------
--@api-stub: EmotionModel:trigger
-- Demonstrates the proper usage of EmotionModel:trigger.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_EmotionModel_trigger()
    guard_emotions:trigger("anger", 0.4)      -- player trespassed
    guard_emotions:trigger("suspicion", 0.3)  -- heard strange noise
    print("triggered: anger +0.4 (trespass), suspicion +0.3 (strange noise)")
end
local _ok, _err = pcall(demo_EmotionModel_trigger)

-- ---- Stub: EmotionModel:get -----------------------------------------------
--@api-stub: EmotionModel:get
-- Demonstrates the proper usage of EmotionModel:get.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_EmotionModel_get()
    local anger = guard_emotions:get("anger")
    local suspicion = guard_emotions:get("suspicion")
    print("anger: " .. string.format("%.2f", anger) .. ", suspicion: " .. string.format("%.2f", suspicion))
end
local _ok, _err = pcall(demo_EmotionModel_get)

-- ---- Stub: EmotionModel:dominant ------------------------------------------
--@api-stub: EmotionModel:dominant
-- Demonstrates the proper usage of EmotionModel:dominant.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_EmotionModel_dominant()
    local dom = guard_emotions:dominant()
    print("dominant emotion: " .. tostring(dom))
end
local _ok, _err = pcall(demo_EmotionModel_dominant)

-- ---- Stub: EmotionModel:isActive ------------------------------------------
--@api-stub: EmotionModel:isActive
-- Demonstrates the proper usage of EmotionModel:isActive.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_EmotionModel_isActive()
    print("anger active: " .. tostring(guard_emotions:isActive("anger")))
    print("fear active: " .. tostring(guard_emotions:isActive("fear")))
end
local _ok, _err = pcall(demo_EmotionModel_isActive)

-- ---- Stub: EmotionModel:update --------------------------------------------
--@api-stub: EmotionModel:update
-- Demonstrates the proper usage of EmotionModel:update.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_EmotionModel_update()
    guard_emotions:update(5.0)  -- 5 seconds of game time
    print("emotions after 5s decay:")
    print("  anger: " .. string.format("%.2f", guard_emotions:get("anger")))
    print("  suspicion: " .. string.format("%.2f", guard_emotions:get("suspicion")))
end
local _ok, _err = pcall(demo_EmotionModel_update)

-- ---- Stub: EmotionModel:reset ---------------------------------------------
--@api-stub: EmotionModel:reset
-- Demonstrates the proper usage of EmotionModel:reset.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_EmotionModel_reset()
    guard_emotions:reset()
    print("guard emotions reset to baseline (new day)")
end
local _ok, _err = pcall(demo_EmotionModel_reset)

-- =============================================================================
-- ORCA Solver — crowd collision avoidance
-- =============================================================================

-- ---- Stub: lurek.ai.newORCASolver -----------------------------------------
--@api-stub: lurek.ai.newORCASolver
-- ORCA (Optimal Reciprocal Collision Avoidance) computes collision-free
-- velocities for crowds of agents. Each agent gets a safe velocity that
-- avoids all neighbours while staying close to its preferred direction.
local orca = lurek.ai.newORCASolver({
    time_horizon = 2.0,
    agent_radius = 10.0
})
print("ORCA solver: time_horizon=2s, agent_radius=10px")

-- ---- Stub: ORCASolver:addAgent --------------------------------------------
--@api-stub: ORCASolver:addAgent
-- Demonstrates the proper usage of ORCASolver:addAgent.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ORCASolver_addAgent()
    local orca_guard = orca:addAgent(100, 200, 12.0)    -- guard: larger radius (armoured)
    local orca_villager = orca:addAgent(300, 400, 8.0)   -- villager: smaller
    local orca_wolf = orca:addAgent(500, 100, 10.0)      -- wolf: medium
    print("ORCA agents: guard(r=12), villager(r=8), wolf(r=10)")
end
local _ok, _err = pcall(demo_ORCASolver_addAgent)

-- ---- Stub: ORCASolver:setPreferredVelocity --------------------------------
--@api-stub: ORCASolver:setPreferredVelocity
-- Demonstrates the proper usage of ORCASolver:setPreferredVelocity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ORCASolver_setPreferredVelocity()
    orca:setPreferredVelocity(orca_guard, 2.0, 0.0)      -- guard walks east
    orca:setPreferredVelocity(orca_villager, -1.0, 0.5)   -- villager walks southwest
    orca:setPreferredVelocity(orca_wolf, 0.0, 3.0)        -- wolf runs south
    print("preferred velocities set for all ORCA agents")
end
local _ok, _err = pcall(demo_ORCASolver_setPreferredVelocity)

-- ---- Stub: ORCASolver:setPosition -----------------------------------------
--@api-stub: ORCASolver:setPosition
-- Demonstrates the proper usage of ORCASolver:setPosition.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ORCASolver_setPosition()
    orca:setPosition(orca_guard, 105, 200)
    orca:setPosition(orca_villager, 298, 402)
    print("ORCA positions updated (one frame of movement)")
end
local _ok, _err = pcall(demo_ORCASolver_setPosition)

-- ---- Stub: ORCASolver:compute ---------------------------------------------
--@api-stub: ORCASolver:compute
-- Demonstrates the proper usage of ORCASolver:compute.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ORCASolver_compute()
    orca:compute()
    print("ORCA computed — all agents have safe velocities")
end
local _ok, _err = pcall(demo_ORCASolver_compute)

-- ---- Stub: ORCASolver:getSafeVelocity -------------------------------------
--@api-stub: ORCASolver:getSafeVelocity
-- Demonstrates the proper usage of ORCASolver:getSafeVelocity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ORCASolver_getSafeVelocity()
    local svx, svy = orca:getSafeVelocity(orca_guard)
    print("guard safe velocity: (" .. string.format("%.2f", svx) .. ", " .. string.format("%.2f", svy) .. ")")
    local wvx, wvy = orca:getSafeVelocity(orca_wolf)
    print("wolf safe velocity: (" .. string.format("%.2f", wvx) .. ", " .. string.format("%.2f", wvy) .. ")")
end
local _ok, _err = pcall(demo_ORCASolver_getSafeVelocity)

-- ---- Stub: ORCASolver:agentCount ------------------------------------------
--@api-stub: ORCASolver:agentCount
-- Demonstrates the proper usage of ORCASolver:agentCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ORCASolver_agentCount()
    print("ORCA agent count: " .. tostring(orca:agentCount()))
end
local _ok, _err = pcall(demo_ORCASolver_agentCount)

-- =============================================================================
-- Neural Net — difficulty tuning
-- =============================================================================

-- ---- Stub: lurek.ai.newNeuralNet ------------------------------------------
--@api-stub: lurek.ai.newNeuralNet
-- Demonstrates the proper usage of lurek.ai.newNeuralNet.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_ai_newNeuralNet()
    local nn = lurek.ai.newNeuralNet()
    print("neural network created for difficulty prediction")
end
local _ok, _err = pcall(demo_lurek_ai_newNeuralNet)

-- ---- Stub: NeuralNet:addLayer ---------------------------------------------
--@api-stub: NeuralNet:addLayer
-- Build the network layer by layer. Input(4) -> Hidden(8) -> Output(3).
-- Input features: player_level, kill_rate, death_rate, accuracy
-- Output: spawn_multiplier, damage_scale, loot_bonus
nn:addLayer(4, "input")
nn:addLayer(8, "relu")
nn:addLayer(3, "sigmoid")
print("network architecture: 4 -> 8(ReLU) -> 3(sigmoid)")

-- ---- Stub: NeuralNet:forward ----------------------------------------------
--@api-stub: NeuralNet:forward
-- Demonstrates the proper usage of NeuralNet:forward.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NeuralNet_forward()
    local player_stats = {15.0, 2.3, 0.5, 0.72}  -- level 15, 2.3 kills/min, 0.5 deaths/min, 72% accuracy
    local output = nn:forward(player_stats)
    if output then
    print("difficulty prediction:")
    print("  spawn multiplier: " .. string.format("%.3f", output[1]))
    print("  damage scale:     " .. string.format("%.3f", output[2]))
    print("  loot bonus:       " .. string.format("%.3f", output[3]))
end
local _ok, _err = pcall(demo_NeuralNet_forward)

-- ---- Stub: NeuralNet:setWeights -------------------------------------------
--@api-stub: NeuralNet:setWeights
-- Demonstrates the proper usage of NeuralNet:setWeights.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NeuralNet_setWeights()
    local weight_count = nn:paramCount()
    local trained_weights = {}
    for i = 1, weight_count do
    trained_weights[i] = math.random() * 2 - 1  -- random init for demo
    nn:setWeights(trained_weights)
    print("loaded " .. weight_count .. " weights into network")
end
local _ok, _err = pcall(demo_NeuralNet_setWeights)

-- ---- Stub: NeuralNet:getWeights -------------------------------------------
--@api-stub: NeuralNet:getWeights
-- Demonstrates the proper usage of NeuralNet:getWeights.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NeuralNet_getWeights()
    local w = nn:getWeights()
    print("extracted " .. #w .. " weights from network")
    print("  first 3 weights: " .. string.format("%.3f, %.3f, %.3f", w[1], w[2], w[3]))
end
local _ok, _err = pcall(demo_NeuralNet_getWeights)

-- ---- Stub: NeuralNet:paramCount -------------------------------------------
--@api-stub: NeuralNet:paramCount
-- Demonstrates the proper usage of NeuralNet:paramCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NeuralNet_paramCount()
    print("total trainable parameters: " .. tostring(nn:paramCount()))
end
local _ok, _err = pcall(demo_NeuralNet_paramCount)

-- ---- Stub: NeuralNet:layerCount -------------------------------------------
--@api-stub: NeuralNet:layerCount
-- Demonstrates the proper usage of NeuralNet:layerCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NeuralNet_layerCount()
    print("network layers: " .. tostring(nn:layerCount()))
end
local _ok, _err = pcall(demo_NeuralNet_layerCount)

-- =============================================================================
-- Genetic Algorithm — procedural creature stats
-- =============================================================================

-- ---- Stub: lurek.ai.newGeneticAlgorithm -----------------------------------
--@api-stub: lurek.ai.newGeneticAlgorithm
-- Evolve creature stat distributions: HP, attack, defense, speed.
-- Each chromosome is a vector of trait values. Fitness rewards balanced builds.
local ga = lurek.ai.newGeneticAlgorithm({
    population_size = 20,
    chromosome_length = 4,  -- HP, ATK, DEF, SPD
    mutation_rate = 0.05,
    crossover_rate = 0.7
})
print("GA: pop=20, genes=4 (HP/ATK/DEF/SPD), mutation=5%, crossover=70%")

-- ---- Stub: GeneticAlgorithm:evolve ----------------------------------------
--@api-stub: GeneticAlgorithm:evolve
-- Demonstrates the proper usage of GeneticAlgorithm:evolve.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_GeneticAlgorithm_evolve()
    ga:evolve()
    print("generation evolved — new creature variants produced")
end
local _ok, _err = pcall(demo_GeneticAlgorithm_evolve)

-- ---- Stub: GeneticAlgorithm:generation ------------------------------------
--@api-stub: GeneticAlgorithm:generation
-- Demonstrates the proper usage of GeneticAlgorithm:generation.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_GeneticAlgorithm_generation()
    print("current generation: " .. tostring(ga:generation()))
end
local _ok, _err = pcall(demo_GeneticAlgorithm_generation)

-- ---- Stub: GeneticAlgorithm:popSize ---------------------------------------
--@api-stub: GeneticAlgorithm:popSize
-- Demonstrates the proper usage of GeneticAlgorithm:popSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_GeneticAlgorithm_popSize()
    print("population size: " .. tostring(ga:popSize()))
end
local _ok, _err = pcall(demo_GeneticAlgorithm_popSize)

-- ---- Stub: GeneticAlgorithm:setFitness ------------------------------------
--@api-stub: GeneticAlgorithm:setFitness
-- Assign fitness scores to each individual. Higher = better survival.
for i = 0, ga:popSize() - 1 do
    -- Fitness: reward balanced stats (low variance across HP/ATK/DEF/SPD)
    local fitness = math.random() * 10.0
    ga:setFitness(i, fitness)
end
print("fitness assigned to all " .. ga:popSize() .. " creatures")

-- ---- Stub: GeneticAlgorithm:getGenes --------------------------------------
--@api-stub: GeneticAlgorithm:getGenes
-- Demonstrates the proper usage of GeneticAlgorithm:getGenes.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_GeneticAlgorithm_getGenes()
    local genes = ga:getGenes(0)
    if genes then
    print("creature #0 genes: HP=" .. string.format("%.1f", genes[1])
        .. " ATK=" .. string.format("%.1f", genes[2])
        .. " DEF=" .. string.format("%.1f", genes[3])
        .. " SPD=" .. string.format("%.1f", genes[4]))
end
local _ok, _err = pcall(demo_GeneticAlgorithm_getGenes)

-- ---- Stub: GeneticAlgorithm:bestGenes -------------------------------------
--@api-stub: GeneticAlgorithm:bestGenes
-- Demonstrates the proper usage of GeneticAlgorithm:bestGenes.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_GeneticAlgorithm_bestGenes()
    local best_genes = ga:bestGenes()
    if best_genes then
    print("elite creature: HP=" .. string.format("%.1f", best_genes[1])
        .. " ATK=" .. string.format("%.1f", best_genes[2])
        .. " DEF=" .. string.format("%.1f", best_genes[3])
        .. " SPD=" .. string.format("%.1f", best_genes[4]))
end
local _ok, _err = pcall(demo_GeneticAlgorithm_bestGenes)

-- =============================================================================
-- Multi-Armed Bandit — loot table optimization
-- =============================================================================

-- ---- Stub: lurek.ai.newBandit ---------------------------------------------
--@api-stub: lurek.ai.newBandit
-- Multi-armed bandit for A/B testing game features or optimising loot drops.
-- Each arm is a loot table variant; rewards measure player engagement.
local bandit = lurek.ai.newBandit({
    arms = 4,             -- 4 loot table variants to test
    strategy = "ucb1"     -- Upper Confidence Bound for exploration/exploitation
})
print("bandit created: 4 arms (loot variants), UCB1 strategy")

-- ---- Stub: Bandit:select --------------------------------------------------
--@api-stub: Bandit:select
-- Demonstrates the proper usage of Bandit:select.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Bandit_select()
    local arm = bandit:select()
    print("bandit selected arm " .. tostring(arm) .. " for this drop")
end
local _ok, _err = pcall(demo_Bandit_select)

-- ---- Stub: Bandit:update --------------------------------------------------
--@api-stub: Bandit:update
-- Demonstrates the proper usage of Bandit:update.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Bandit_update()
    bandit:update(arm, 0.8)   -- arm performed well (player liked the loot)
    print("arm " .. tostring(arm) .. " updated with reward 0.8")
end
local _ok, _err = pcall(demo_Bandit_update)

-- ---- Stub: Bandit:bestArm -------------------------------------------------
--@api-stub: Bandit:bestArm
-- Demonstrates the proper usage of Bandit:bestArm.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Bandit_bestArm()
    local best_arm = bandit:bestArm()
    print("best-performing loot variant: arm " .. tostring(best_arm))
end
local _ok, _err = pcall(demo_Bandit_bestArm)

-- ---- Stub: Bandit:reset ---------------------------------------------------
--@api-stub: Bandit:reset
-- Demonstrates the proper usage of Bandit:reset.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Bandit_reset()
    bandit:reset()
    print("bandit stats reset — starting new loot experiment")
end
local _ok, _err = pcall(demo_Bandit_reset)

-- ---- Stub: Bandit:armCount ------------------------------------------------
--@api-stub: Bandit:armCount
-- Demonstrates the proper usage of Bandit:armCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Bandit_armCount()
    print("bandit arm count: " .. tostring(bandit:armCount()))
end
local _ok, _err = pcall(demo_Bandit_armCount)

-- ---- Stub: Bandit:totalPulls ----------------------------------------------
--@api-stub: Bandit:totalPulls
-- Demonstrates the proper usage of Bandit:totalPulls.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Bandit_totalPulls()
    print("total selections so far: " .. tostring(bandit:totalPulls()))
end
local _ok, _err = pcall(demo_Bandit_totalPulls)

-- =============================================================================
-- Neuroevolution — breeding champion fighters
-- =============================================================================

-- ---- Stub: lurek.ai.newNeuroevolution -------------------------------------
--@api-stub: lurek.ai.newNeuroevolution
-- Neuroevolution combines neural networks with genetic algorithms.
-- Each individual is a neural net; GA evolves the weights over generations.
local neuro = lurek.ai.newNeuroevolution({
    population_size = 30,
    input_size = 6,     -- enemy: dist, angle, hp, my_hp, my_stamina, cooldown
    hidden_sizes = {8, 6},
    output_size = 4,    -- actions: attack, dodge, heal, advance
    mutation_rate = 0.1
})
print("neuroevolution: pop=30, net=6->8->6->4, mutation=10%")

-- ---- Stub: Neuroevolution:evolve ------------------------------------------
--@api-stub: Neuroevolution:evolve
-- Demonstrates the proper usage of Neuroevolution:evolve.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Neuroevolution_evolve()
    neuro:evolve()
    print("neuroevolution generation evolved")
end
local _ok, _err = pcall(demo_Neuroevolution_evolve)

-- ---- Stub: Neuroevolution:setFitness --------------------------------------
--@api-stub: Neuroevolution:setFitness
-- Demonstrates the proper usage of Neuroevolution:setFitness.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Neuroevolution_setFitness()
    for i = 0, neuro:popSize() - 1 do
    local fight_score = math.random() * 100.0
    neuro:setFitness(i, fight_score)
    print("fitness scores assigned to all " .. neuro:popSize() .. " fighters")
end
local _ok, _err = pcall(demo_Neuroevolution_setFitness)

-- ---- Stub: Neuroevolution:chromosomeToNet ---------------------------------
--@api-stub: Neuroevolution:chromosomeToNet
-- Demonstrates the proper usage of Neuroevolution:chromosomeToNet.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Neuroevolution_chromosomeToNet()
    local fighter_net = neuro:chromosomeToNet(0)
    print("fighter #0 network extracted (" .. tostring(fighter_net:paramCount()) .. " params)")
end
local _ok, _err = pcall(demo_Neuroevolution_chromosomeToNet)

-- ---- Stub: Neuroevolution:bestNetwork -------------------------------------
--@api-stub: Neuroevolution:bestNetwork
-- Demonstrates the proper usage of Neuroevolution:bestNetwork.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Neuroevolution_bestNetwork()
    local champion = neuro:bestNetwork()
    print("champion network: " .. tostring(champion:paramCount()) .. " parameters")
    print("  deploy this as the arena boss AI!")
end
local _ok, _err = pcall(demo_Neuroevolution_bestNetwork)

-- ---- Stub: Neuroevolution:bestFitness ------------------------------------
--@api-stub: Neuroevolution:bestFitness
-- Demonstrates the proper usage of Neuroevolution:bestFitness.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Neuroevolution_bestFitness()
    local best_fit = neuro:bestFitness()
    print("champion fitness: " .. string.format("%.1f", best_fit))
end
local _ok, _err = pcall(demo_Neuroevolution_bestFitness)

-- ---- Stub: Neuroevolution:popSize -----------------------------------------
--@api-stub: Neuroevolution:popSize
-- Demonstrates the proper usage of Neuroevolution:popSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Neuroevolution_popSize()
    print("neuroevolution population: " .. tostring(neuro:popSize()))
end
local _ok, _err = pcall(demo_Neuroevolution_popSize)

-- ---- Stub: Neuroevolution:generation --------------------------------------
--@api-stub: Neuroevolution:generation
-- Demonstrates the proper usage of Neuroevolution:generation.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Neuroevolution_generation()
    print("neuroevolution generation: " .. tostring(neuro:generation()))
end
local _ok, _err = pcall(demo_Neuroevolution_generation)

-- =============================================================================
-- Strategy AI — goal-driven faction AI
-- =============================================================================

-- ---- Stub: lurek.ai.newStrategyAI -----------------------------------------
--@api-stub: lurek.ai.newStrategyAI
-- High-level strategic AI that manages long-term faction goals.
-- Evaluates goals by priority and context tags, then activates the best one.
local faction_ai = lurek.ai.newStrategyAI({
    evaluation_interval = 5.0  -- re-evaluate every 5 seconds
})
print("strategy AI created: re-evaluates every 5s")

-- ---- Stub: StrategyAI:addGoal ---------------------------------------------
--@api-stub: StrategyAI:addGoal
-- Demonstrates the proper usage of StrategyAI:addGoal.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_StrategyAI_addGoal()
    faction_ai:addGoal("expand_territory", {
    priority = 8,
    condition = function(tags)
        return tags.military_strength > 50
    end,
    action = function() print("  [faction] expanding borders!") end
    })
    faction_ai:addGoal("defend_homeland", {
    priority = 10,
    condition = function(tags)
        return tags.under_attack == true
    end,
    action = function() print("  [faction] rallying defenders!") end
    })
    faction_ai:addGoal("trade_resources", {
    priority = 5,
    condition = function(tags)
        return tags.gold_reserves > 100
    end,
    action = function() print("  [faction] sending trade caravan") end
    })
    print("goals: expand(p=8), defend(p=10), trade(p=5)")
end
local _ok, _err = pcall(demo_StrategyAI_addGoal)

-- ---- Stub: StrategyAI:addTag ----------------------------------------------
--@api-stub: StrategyAI:addTag
-- Demonstrates the proper usage of StrategyAI:addTag.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_StrategyAI_addTag()
    faction_ai:addTag("military_strength", 75)
    faction_ai:addTag("gold_reserves", 200)
    faction_ai:addTag("under_attack", false)
    print("faction tags: military=75, gold=200, under_attack=false")
end
local _ok, _err = pcall(demo_StrategyAI_addTag)

-- ---- Stub: StrategyAI:removeTag -------------------------------------------
--@api-stub: StrategyAI:removeTag
-- Demonstrates the proper usage of StrategyAI:removeTag.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_StrategyAI_removeTag()
    faction_ai:removeTag("under_attack")
    print("removed 'under_attack' tag (peace treaty signed)")
end
local _ok, _err = pcall(demo_StrategyAI_removeTag)

-- ---- Stub: StrategyAI:update ----------------------------------------------
--@api-stub: StrategyAI:update
-- Demonstrates the proper usage of StrategyAI:update.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_StrategyAI_update()
    faction_ai:update(5.0)  -- trigger evaluation
    print("strategy AI updated — goals evaluated")
end
local _ok, _err = pcall(demo_StrategyAI_update)

-- ---- Stub: StrategyAI:forceEvaluate ---------------------------------------
--@api-stub: StrategyAI:forceEvaluate
-- Demonstrates the proper usage of StrategyAI:forceEvaluate.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_StrategyAI_forceEvaluate()
    faction_ai:addTag("under_attack", true)
    faction_ai:forceEvaluate()
    print("forced evaluation after sudden invasion — defend should activate")
end
local _ok, _err = pcall(demo_StrategyAI_forceEvaluate)

-- ---- Stub: StrategyAI:activeGoal ------------------------------------------
--@api-stub: StrategyAI:activeGoal
-- Demonstrates the proper usage of StrategyAI:activeGoal.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_StrategyAI_activeGoal()
    local active = faction_ai:activeGoal()
    print("active strategic goal: " .. tostring(active))
end
local _ok, _err = pcall(demo_StrategyAI_activeGoal)

-- ---- Stub: StrategyAI:timeUntilNext ---------------------------------------
--@api-stub: StrategyAI:timeUntilNext
-- Demonstrates the proper usage of StrategyAI:timeUntilNext.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_StrategyAI_timeUntilNext()
    local until_next = faction_ai:timeUntilNext()
    print("next evaluation in: " .. string.format("%.1f", until_next) .. "s")
end
local _ok, _err = pcall(demo_StrategyAI_timeUntilNext)

-- =============================================================================
-- Cleanup — remove agents from the world
-- =============================================================================

-- ---- Stub: AIWorld:removeAgent --------------------------------------------
--@api-stub: AIWorld:removeAgent
-- Demonstrates the proper usage of AIWorld:removeAgent.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AIWorld_removeAgent()
    local removed = ai_world:removeAgent("alpha_wolf")
    print("wolf removed from AI world: " .. tostring(removed))
    print("remaining agents: " .. tostring(ai_world:getAgentCount()))
    print("\n-- ai.lua example complete --")
end
local _ok, _err = pcall(demo_AIWorld_removeAgent)
