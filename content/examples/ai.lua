-- content/examples/ai.lua
-- Auto-generated from content/examples2/ai_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/ai.lua

--@api-stub: lurek.ai.newWorld
-- Creates an isolated AI world for agents, blackboards, and custom decision callbacks.
do
  local world = lurek.ai.newWorld()
  print("lurek.ai.newWorld: agents=" .. tostring(world:getAgentCount()))
end

--@api-stub: lurek.ai.newBlackboard
-- Creates an empty AI blackboard for typed local facts.
do
  local bb = lurek.ai.newBlackboard()
  bb:setString("state", "idle")
  print("lurek.ai.newBlackboard: state=" .. bb:getString("state", "none"))
end

--@api-stub: lurek.ai.newStateMachine
-- Creates an empty finite state machine with Lua-backed states and transitions.
do
  local fsm = lurek.ai.newStateMachine()
  print("lurek.ai.newStateMachine: ok=" .. tostring(fsm ~= nil))
end

--@api-stub: lurek.ai.newBehaviorTree
-- Creates an empty behavior tree that can receive a root node.
do
  local bt = lurek.ai.newBehaviorTree()
  print("lurek.ai.newBehaviorTree: status=" .. tostring(bt:getLastStatus()))
end

--@api-stub: lurek.ai.newSelector
-- Creates a behavior tree selector node with no children.
do
  local sel = lurek.ai.newSelector()
  print("lurek.ai.newSelector: type=" .. sel:getNodeType())
end

--@api-stub: lurek.ai.newSequence
-- Creates a behavior tree sequence node with no children.
do
  local seq = lurek.ai.newSequence()
  print("lurek.ai.newSequence: type=" .. seq:getNodeType())
end

--@api-stub: lurek.ai.newParallel
-- Creates a behavior tree parallel node with optional success and failure policies.
do
  local par = lurek.ai.newParallel("requireAll", "requireOne")
  print("lurek.ai.newParallel: children=" .. tostring(par:getChildCount()))
end

--@api-stub: lurek.ai.newInverter
-- Creates a behavior tree inverter decorator with an empty sequence child.
do
  local inv = lurek.ai.newInverter()
  print("lurek.ai.newInverter: type=" .. inv:getNodeType())
end

--@api-stub: lurek.ai.newRepeater
-- Creates a behavior tree repeater decorator with an optional repeat count.
do
  local rep = lurek.ai.newRepeater(5)
  print("lurek.ai.newRepeater: count=" .. tostring(rep:getCount()))
end

--@api-stub: lurek.ai.newSucceeder
-- Creates a behavior tree succeeder decorator with an empty sequence child.
do
  local suc = lurek.ai.newSucceeder()
  print("lurek.ai.newSucceeder: type=" .. suc:getNodeType())
end

--@api-stub: lurek.ai.newAction
-- Creates a behavior tree action leaf backed by a Lua callback.
do
  local act = lurek.ai.newAction(function() return "success" end)
  print("lurek.ai.newAction: type=" .. act:getNodeType())
end

--@api-stub: lurek.ai.newCondition
-- Creates a behavior tree condition leaf backed by a Lua callback.
do
  local cond = lurek.ai.newCondition(function() return true end)
  print("lurek.ai.newCondition: type=" .. cond:getNodeType())
end

--@api-stub: lurek.ai.newGuard
-- Creates a guard decorator that runs a predicate before ticking its child.
do
  local child_action = lurek.ai.newAction(function() return "success" end)
  local guard = lurek.ai.newGuard(function() return true end, child_action)
  print("lurek.ai.newGuard: node=" .. guard:getNodeType())
end

--@api-stub: lurek.ai.newSteeringManager
-- Creates an empty steering manager with support for built-in and custom behaviors.
do
  local steer = lurek.ai.newSteeringManager()
  print("lurek.ai.newSteeringManager: ok=" .. tostring(steer ~= nil))
end

--@api-stub: lurek.ai.newQLearner
-- Creates a Q-learner with fixed state and action counts.
do
  local ql = lurek.ai.newQLearner(10, 4)
  print("lurek.ai.newQLearner: ok=" .. tostring(ql ~= nil))
end

--@api-stub: lurek.ai.newUtilityAI
-- Creates an empty utility AI action scorer.
do
  local util = lurek.ai.newUtilityAI()
  print("lurek.ai.newUtilityAI: ok=" .. tostring(util ~= nil))
end

--@api-stub: lurek.ai.newDialogueAI
-- Creates an empty dialogue selector for weighted topics and branches.
do
  local dlg = lurek.ai.newDialogueAI()
  print("lurek.ai.newDialogueAI: ok=" .. tostring(dlg ~= nil))
end

--@api-stub: lurek.ai.newGOAPPlanner
-- Creates an empty GOAP planner for boolean world-state planning.
do
  local goap = lurek.ai.newGOAPPlanner()
  print("lurek.ai.newGOAPPlanner: ok=" .. tostring(goap ~= nil))
end

--@api-stub: lurek.ai.newInfluenceMap
-- Creates a grid influence map with the supplied cell dimensions and world cell size.
do
  local imap = lurek.ai.newInfluenceMap(32, 32, 16)
  print("lurek.ai.newInfluenceMap: ok=" .. tostring(imap ~= nil))
end

--@api-stub: lurek.ai.newSquad
-- Creates an empty named squad. This function is exposed to Lua scripts.
do
  local squad = lurek.ai.newSquad("bravo")
  print("lurek.ai.newSquad: name=" .. squad:getName())
end

--@api-stub: lurek.ai.newCommandQueue
-- Creates an empty command queue for callback-backed AI commands.
do
  local cq = lurek.ai.newCommandQueue()
  print("lurek.ai.newCommandQueue: empty=" .. tostring(cq:isEmpty()))
end

--@api-stub: lurek.ai.newTraitProfile
-- Creates an empty trait profile with modifier support.
do
  local traits = lurek.ai.newTraitProfile()
  print("lurek.ai.newTraitProfile: ok=" .. tostring(traits ~= nil))
end

--@api-stub: lurek.ai.newStimulusWorld
-- Creates an empty stimulus world for visual and auditory stimulus records.
do
  local sw = lurek.ai.newStimulusWorld()
  print("lurek.ai.newStimulusWorld: stimuli=" .. tostring(sw:count()))
end

--@api-stub: lurek.ai.newContextSteering
-- Creates a context steering model with the requested directional slot count.
do
  local cs = lurek.ai.newContextSteering(8)
  print("lurek.ai.newContextSteering: ok=" .. tostring(cs ~= nil))
end

--@api-stub: lurek.ai.newNeedSystem
-- Creates an empty need system for decaying named needs.
do
  local needs = lurek.ai.newNeedSystem()
  print("lurek.ai.newNeedSystem: ok=" .. tostring(needs ~= nil))
end

--@api-stub: lurek.ai.newAIDirector
-- Creates an AI director for tension, phase, and pacing factor calculations.
do
  local dir = lurek.ai.newAIDirector()
  print("lurek.ai.newAIDirector: ok=" .. tostring(dir ~= nil))
end

--@api-stub: lurek.ai.newHTNDomain
-- Creates an empty hierarchical task network domain.
do
  local htn = lurek.ai.newHTNDomain()
  print("lurek.ai.newHTNDomain: ok=" .. tostring(htn ~= nil))
end

--@api-stub: lurek.ai.newMCTSEngine
-- Creates a Monte Carlo tree search engine with deterministic configuration.
do
  -- MCTS explores game states via random simulations to find the best action.
  -- Parameters: iterations, exploration constant, max depth, random seed.
  local mcts = lurek.ai.newMCTSEngine(100, 1.41, 20, 42)
  local get_actions = function(state) return { 1, 2, 3 } end
  local apply = function(state, action) return state + action end
  local evaluate = function(state) return state % 5 end
  local best_action = mcts:search(0, get_actions, apply, evaluate)
  -- Deterministic seed makes results repeatable for testing and replays.
  print("lurek.ai.newMCTSEngine: action=" .. tostring(best_action))
end

--@api-stub: lurek.ai.newEmotionModel
-- Creates an empty emotion model for named decaying emotion values.
do
  local emo = lurek.ai.newEmotionModel()
  print("lurek.ai.newEmotionModel: ok=" .. tostring(emo ~= nil))
end

--@api-stub: lurek.ai.newORCASolver
-- Creates an ORCA avoidance solver with the supplied prediction horizon.
do
  local orca = lurek.ai.newORCASolver(1.5)
  print("lurek.ai.newORCASolver: ok=" .. tostring(orca ~= nil))
end

--@api-stub: lurek.ai.newNeuralNet
-- Creates an empty feed-forward neural network.
do
  local nn = lurek.ai.newNeuralNet()
  print("lurek.ai.newNeuralNet: ok=" .. tostring(nn ~= nil))
end

--@api-stub: lurek.ai.newGeneticAlgorithm
-- Creates a genetic algorithm population with fixed chromosome length.
do
  local ga = lurek.ai.newGeneticAlgorithm(8, 5, 7)
  print("lurek.ai.newGeneticAlgorithm: ok=" .. tostring(ga ~= nil))
end

--@api-stub: lurek.ai.newBandit
-- Creates a multi-armed bandit with a named selection strategy.
do
  local bandit = lurek.ai.newBandit(3, "ucb1", 0.15, 55)
  print("lurek.ai.newBandit: ok=" .. tostring(bandit ~= nil))
end

--@api-stub: lurek.ai.newNeuroevolution
-- Creates a neuroevolution population from a layer specification table.
do
  local layers = {
    { inputs = 3, outputs = 6, activation = "relu" },
    { inputs = 6, outputs = 2, activation = "softmax" },
  }
  local ne = lurek.ai.newNeuroevolution(layers, 8, 1)
  print("lurek.ai.newNeuroevolution: ok=" .. tostring(ne ~= nil))
end

--@api-stub: lurek.ai.newStrategyAI
-- Creates a strategy AI that reevaluates goals on a fixed interval.
do
  local strat = lurek.ai.newStrategyAI(3.0)
  print("lurek.ai.newStrategyAI: ok=" .. tostring(strat ~= nil))
end

--@api-stub: lurek.ai.newAILod
-- Creates a default AI level-of-detail tier selector.
do
  local lod = lurek.ai.newAILod()
  print("lurek.ai.newAILod: ok=" .. tostring(lod ~= nil))
end

--@api-stub: LAIWorld:addAgent
-- Creates a named agent in this world and returns a handle that can edit its movement and decision state.
do
  local world = lurek.ai.newWorld()
  local archer = world:addAgent("archer_01")
  print("LAIWorld:addAgent: name=" .. archer:getName())
end

--@api-stub: LAIWorld:getAgent
-- Returns the named agent handle when it exists in this world.
do
  local world = lurek.ai.newWorld()
  world:addAgent("scout_01")
  local found = world:getAgent("scout_01")
  print("LAIWorld:getAgent: found=" .. tostring(found ~= nil))
end

--@api-stub: LAIWorld:removeAgent
-- Removes an agent from this world by using an existing agent handle.
do
  local world = lurek.ai.newWorld()
  local temp = world:addAgent("temp_npc")
  world:removeAgent(temp)
  print("LAIWorld:removeAgent: removed")
end

--@api-stub: LAIWorld:getAgentCount
-- Returns the number of agents currently stored in this world.
do
  -- Use agent count for debug overlays or spawn budget checks.
  local world = lurek.ai.newWorld()
  world:addAgent("unit_a")
  world:addAgent("unit_b")
  world:addAgent("unit_c")
  local count = world:getAgentCount()
  -- Count reflects active agents only; removed agents are not counted.
  print("LAIWorld:getAgentCount: " .. tostring(count))
end

--@api-stub: LAIWorld:getGlobalBlackboard
-- Returns a blackboard snapshot containing the world's shared AI facts.
do
  local world = lurek.ai.newWorld()
  local gb = world:getGlobalBlackboard()
  print("LAIWorld:getGlobalBlackboard: ok=" .. tostring(gb ~= nil))
end

--@api-stub: LAIWorld:update
-- Advances the world simulation and invokes custom decision callbacks for agents that use a custom model.
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("worker")
  npc:setDecisionModel("custom")
  local ticked = false
  npc:setCustomModel(function(agent, blackboard, dt)
    ticked = true
  end)
  world:update(1 / 60)
  print("LAIWorld:update: ticked=" .. tostring(ticked))
end

--@api-stub: LAIWorld:type
-- Returns the Lua-visible type name for this AI world handle.
do
  -- type() returns the string "LAIWorld" for AI world handles.
  local world = lurek.ai.newWorld()
  local t = world:type()
  -- Use type() for runtime type identification in polymorphic code.
  print("LAIWorld:type: " .. t)
end

--@api-stub: LAIWorld:typeOf
-- Returns whether this AI world handle matches a supported type name.
do
  -- typeOf() checks if the handle is of a given type. Accepts "LAIWorld" and "Object".
  local world = lurek.ai.newWorld()
  local is_world = world:typeOf("LAIWorld")
  local is_wrong = world:typeOf("LImage")
  -- typeOf is useful for generic code that handles multiple object types.
  print("LAIWorld:typeOf: LAIWorld=" .. tostring(is_world) .. " LImage=" .. tostring(is_wrong))
end

--@api-stub: LAgent:getName
-- Returns this agent's stable world name.
do
  -- getName() returns the string passed to addAgent. It never changes.
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("knight_03")
  local name = npc:getName()
  -- Use the name as a stable ID for save data, squad membership, or lookups.
  print("LAgent:getName: " .. name)
end

--@api-stub: LAgent:setPosition
-- Sets this agent's world position when the agent still exists in its world.
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("mover")
  npc:setPosition(256, 128)
  print("LAgent:setPosition: done")
end

--@api-stub: LAgent:getPosition
-- Returns this agent's world position or the origin when the agent has been removed.
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("static_guard")
  npc:setPosition(400, 300)
  local x, y = npc:getPosition()
  print("LAgent:getPosition: " .. tostring(x) .. ", " .. tostring(y))
end

--@api-stub: LAgent:setVelocity
-- Sets this agent's velocity vector when the agent still exists in its world.
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("runner")
  npc:setVelocity(60, -30)
  print("LAgent:setVelocity: done")
end

--@api-stub: LAgent:getVelocity
-- Returns this agent's velocity vector or zero velocity when the agent has been removed.
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("idle_npc")
  npc:setVelocity(0, 0)
  local vx, vy = npc:getVelocity()
  print("LAgent:getVelocity: vx=" .. tostring(vx) .. " vy=" .. tostring(vy))
end

--@api-stub: LAgent:setMaxSpeed
-- Sets this agent's maximum movement speed when the agent still exists in its world.
do
  -- setMaxSpeed(speed) limits how fast the agent can move regardless of steering force.
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("sprinter")
  npc:setMaxSpeed(200)
  -- Max speed clamps velocity magnitude during movement integration.
  print("LAgent:setMaxSpeed: done")
end

--@api-stub: LAgent:getMaxSpeed
-- Returns this agent's maximum movement speed.
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("courier")
  npc:setMaxSpeed(150)
  local speed = npc:getMaxSpeed()
  print("LAgent:getMaxSpeed: " .. tostring(speed))
end

--@api-stub: LAgent:setMaxForce
-- Sets this agent's maximum steering force when the agent still exists in its world.
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("tank")
  npc:setMaxForce(80)
  print("LAgent:setMaxForce: done")
end

--@api-stub: LAgent:getMaxForce
-- Returns this agent's maximum steering force.
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("scout")
  npc:setMaxForce(200)
  local force = npc:getMaxForce()
  print("LAgent:getMaxForce: " .. tostring(force))
end

--@api-stub: LAgent:setPriority
-- Sets this agent's update priority when the agent still exists in its world.
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("captain")
  npc:setPriority(10)
  print("LAgent:setPriority: " .. tostring(npc:getPriority()))
end

--@api-stub: LAgent:getPriority
-- Returns this agent's update priority.
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("grunt")
  npc:setPriority(5)
  local prio = npc:getPriority()
  print("LAgent:getPriority: " .. tostring(prio))
end

--@api-stub: LAgent:setDecisionModel
-- Sets the agent's decision model type when the agent still exists.
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("worker")
  npc:setDecisionModel("custom")
  local model = npc:getDecisionModel()
  print("LAgent:setDecisionModel: " .. model)
end

--@api-stub: LAgent:getDecisionModel
-- Returns the agent's decision model type string.
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("farmer")
  npc:setDecisionModel("custom")
  local model = npc:getDecisionModel()
  print("LAgent:getDecisionModel: " .. model)
end

--@api-stub: LAgent:setCustomModel
-- Sets the Lua callback that runs every world:update() for this agent.
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("thinker")
  npc:setDecisionModel("custom")
  local called_with_dt = 0
  npc:setCustomModel(function(agent, bb, dt)
    called_with_dt = dt
  end)
  world:update(0.016)
  print("LAgent:setCustomModel: dt=" .. tostring(called_with_dt))
end

--@api-stub: LAgent:addTag
-- Adds a string tag to this agent when the agent still exists.
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("guard")
  npc:addTag("hostile")
  local has_hostile = npc:hasTag("hostile")
  print("LAgent:addTag: hostile=" .. tostring(has_hostile))
end

--@api-stub: LAgent:removeTag
-- Removes a string tag from this agent when the agent still exists.
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("spy")
  npc:addTag("visible")
  npc:removeTag("visible")
  local still_has = npc:hasTag("visible")
  print("LAgent:removeTag: visible=" .. tostring(still_has))
end

--@api-stub: LAgent:hasTag
-- Returns whether this agent currently has a specific tag.
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("merchant")
  npc:addTag("friendly")
  local friendly = npc:hasTag("friendly")
  local hostile = npc:hasTag("hostile")
  print("LAgent:hasTag: friendly=" .. tostring(friendly) .. " hostile=" .. tostring(hostile))
end

--@api-stub: LAgent:getBlackboard
-- Returns this agent's local blackboard for reading and writing facts.
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("ranger")
  local bb = npc:getBlackboard()
  bb:setNumber("hp", 100)
  local hp = bb:getNumber("hp", 0)
  print("LAgent:getBlackboard: hp=" .. tostring(hp))
end

--@api-stub: LAgent:type
-- Returns the Lua-visible type name for this agent handle.
do
  -- type() returns the string "LAgent" for agent handles.
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("villager")
  local t = npc:type()
  -- Use type() for runtime type checks in generic code.
  print("LAgent:type: " .. t)
end

--@api-stub: LAgent:typeOf
-- Returns whether this agent handle matches a supported type name.
do
  -- typeOf accepts "LAgent" and "Object". Other strings return false.
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("knight")
  local is_agent = npc:typeOf("LAgent")
  local is_image = npc:typeOf("LImage")
  -- typeOf is useful for polymorphic code that handles mixed userdata.
  print("LAgent:typeOf: LAgent=" .. tostring(is_agent) .. " LImage=" .. tostring(is_image))
end

--@api-stub: LAIBlackboard:setNumber
-- Stores a numeric value under a string key in this blackboard.
do
  -- setNumber overwrites any existing value at the same key.
  local bb = lurek.ai.newBlackboard()
  bb:setNumber("distance", 42.5)
  bb:setNumber("ammo", 30)
  local dist = bb:getNumber("distance", 0)
  -- Numbers are stored as f64 internally; integers and floats both work.
  print("LAIBlackboard:setNumber: distance=" .. tostring(dist))
end

--@api-stub: LAIBlackboard:getNumber
-- Returns a numeric value from this blackboard or the default if not found.
do
  -- The second argument is the default value returned when the key is absent.
  local bb = lurek.ai.newBlackboard()
  bb:setNumber("score", 95.5)
  local score = bb:getNumber("score", 0)
  local missing = bb:getNumber("nonexistent", -1)
  -- Default values prevent nil errors in decision code.
  print("LAIBlackboard:getNumber: score=" .. tostring(score) .. " missing=" .. tostring(missing))
end

--@api-stub: LAIBlackboard:setBool
-- Stores a boolean value under a string key in this blackboard.
do
  -- setBool overwrites any existing value at the same key.
  local bb = lurek.ai.newBlackboard()
  bb:setBool("can_attack", true)
  bb:setBool("is_hiding", false)
  local attack = bb:getBool("can_attack", false)
  -- Boolean facts are common for condition checks in behavior trees.
  print("LAIBlackboard:setBool: can_attack=" .. tostring(attack))
end

--@api-stub: LAIBlackboard:getBool
-- Returns a boolean value from this blackboard or the default if not found.
do
  -- The second argument is the default value returned when the key is absent.
  local bb = lurek.ai.newBlackboard()
  bb:setBool("alert", true)
  local alert = bb:getBool("alert", false)
  local calm = bb:getBool("calm", true)
  -- Use getBool in condition nodes and guard predicates.
  print("LAIBlackboard:getBool: alert=" .. tostring(alert) .. " calm=" .. tostring(calm))
end

--@api-stub: LAIBlackboard:setString
-- Stores a string value under a string key in this blackboard.
do
  -- setString overwrites any existing value at the same key.
  local bb = lurek.ai.newBlackboard()
  bb:setString("target_name", "dragon")
  bb:setString("current_zone", "forest")
  local target = bb:getString("target_name", "none")
  -- String facts hold entity references, zone names, or state labels.
  print("LAIBlackboard:setString: target=" .. target)
end

--@api-stub: LAIBlackboard:getString
-- Returns a string value from this blackboard or the default if not found.
do
  -- The second argument is the default string returned when the key is absent.
  local bb = lurek.ai.newBlackboard()
  bb:setString("weapon", "sword")
  local weapon = bb:getString("weapon", "fists")
  local shield = bb:getString("shield", "none")
  -- Default strings avoid nil concatenation errors.
  print("LAIBlackboard:getString: weapon=" .. weapon .. " shield=" .. shield)
end

--@api-stub: LAIBlackboard:has
-- Returns whether this blackboard contains a value for the given key.
do
  -- has() checks existence regardless of value type (number, bool, string).
  local bb = lurek.ai.newBlackboard()
  bb:setNumber("hp", 80)
  local has_hp = bb:has("hp")
  local has_mp = bb:has("mp")
  -- Use has() before remove() to avoid unnecessary work.
  print("LAIBlackboard:has: hp=" .. tostring(has_hp) .. " mp=" .. tostring(has_mp))
end

--@api-stub: LAIBlackboard:remove
-- Removes a single key-value pair from this blackboard.
do
  local bb = lurek.ai.newBlackboard()
  bb:setNumber("temp", 99)
  bb:remove("temp")
  local still_has = bb:has("temp")
  print("LAIBlackboard:remove: has_temp=" .. tostring(still_has))
end

--@api-stub: LAIBlackboard:clear
-- Removes all key-value pairs from this blackboard.
do
  -- clear() is useful on scene transitions or agent respawn.
  local bb = lurek.ai.newBlackboard()
  bb:setNumber("a", 1)
  bb:setString("b", "x")
  bb:setBool("c", true)
  bb:clear()
  local size = bb:getSize()
  -- After clear, getSize returns 0 and all get calls return their defaults.
  print("LAIBlackboard:clear: size=" .. tostring(size))
end

--@api-stub: LAIBlackboard:getKeys
-- Returns a table of all keys currently stored in this blackboard.
do
  local bb = lurek.ai.newBlackboard()
  bb:setNumber("hp", 100)
  bb:setString("state", "idle")
  local keys = bb:getKeys()
  print("LAIBlackboard:getKeys: count=" .. tostring(#keys))
end

--@api-stub: LAIBlackboard:getSize
-- Returns the number of key-value pairs currently stored in this blackboard.
do
  local bb = lurek.ai.newBlackboard()
  bb:setNumber("hp", 10)
  bb:setString("name", "test")
  local size = bb:getSize()
  print("LAIBlackboard:getSize: " .. tostring(size))
end

--@api-stub: LAIBlackboard:type
-- Returns the Lua-visible type name for this blackboard handle.
do
  -- type() returns "LAIBlackboard" for blackboard handles.
  local bb = lurek.ai.newBlackboard()
  local t = bb:type()
  -- Use type() for runtime identification in generic code.
  print("LAIBlackboard:type: " .. t)
end

--@api-stub: LAIBlackboard:typeOf
-- Returns whether this blackboard handle matches a supported type name.
do
  -- typeOf accepts "LAIBlackboard" and "Object". Other strings return false.
  local bb = lurek.ai.newBlackboard()
  local is_bb = bb:typeOf("LAIBlackboard")
  local is_agent = bb:typeOf("LAgent")
  -- typeOf helps distinguish objects in polymorphic containers.
  print("LAIBlackboard:typeOf: LAIBlackboard=" .. tostring(is_bb) .. " LAgent=" .. tostring(is_agent))
end

--@api-stub: LStateMachine:addState
-- Adds a named state with optional enter and exit callbacks.
do
  local fsm = lurek.ai.newStateMachine()
  local entered = ""
  fsm:addState("patrol", {
    onEnter = function() entered = "patrol" end,
  })
  fsm:setInitialState("patrol")
  print("LStateMachine:addState: entered=" .. entered)
end

--@api-stub: LStateMachine:addTransition
-- Adds a conditional transition between two named states.
do
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("idle", {})
  fsm:addState("alert", {})
  fsm:addTransition("idle", "alert", function() return true end, 1)
  print("LStateMachine:addTransition: configured")
end

--@api-stub: LStateMachine:setInitialState
-- Sets the FSM's starting state and calls its onEnter callback.
do
  local fsm = lurek.ai.newStateMachine()
  local log = ""
  fsm:addState("sleep", { onEnter = function() log = "entered_sleep" end })
  fsm:setInitialState("sleep")
  local current = fsm:getCurrentState() or "none"
  print("LStateMachine:setInitialState: " .. current .. " log=" .. log)
end

--@api-stub: LStateMachine:getCurrentState
-- Returns the name of the currently active state or nil if none set.
do
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("wander", {})
  local before = fsm:getCurrentState()
  fsm:setInitialState("wander")
  local after = fsm:getCurrentState()
  print("LStateMachine:getCurrentState: before=" .. tostring(before) .. " after=" .. tostring(after))
end

--@api-stub: LStateMachine:forceState
-- Forces an immediate state transition bypassing normal transition logic.
do
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("alive", {})
  fsm:addState("dead", {})
  fsm:setInitialState("alive")
  fsm:forceState("dead")
  local current = fsm:getCurrentState() or "none"
  print("LStateMachine:forceState: " .. current)
end

--@api-stub: LStateMachine:getTimeInState
-- Returns the elapsed time in the current state since the last transition.
do
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("cooking", {})
  fsm:setInitialState("cooking")
  local time_in = fsm:getTimeInState()
  print("LStateMachine:getTimeInState: " .. tostring(time_in))
end

--@api-stub: LStateMachine:type
-- Returns the Lua-visible type name for this state machine handle.
do
  -- type() returns "LStateMachine" for FSM handles.
  local fsm = lurek.ai.newStateMachine()
  local t = fsm:type()
  print("LStateMachine:type: " .. t)
end

--@api-stub: LStateMachine:typeOf
-- Returns whether this FSM handle matches a supported type name.
do
  -- typeOf accepts "LStateMachine" and "Object".
  local fsm = lurek.ai.newStateMachine()
  local is_fsm = fsm:typeOf("LStateMachine")
  local is_other = fsm:typeOf("LBehaviorTree")
  print("LStateMachine:typeOf: LStateMachine=" .. tostring(is_fsm) .. " LBehaviorTree=" .. tostring(is_other))
end

--@api-stub: LBehaviorTree:getLastStatus
-- Returns the result of the most recent tree tick.
do
  local bt = lurek.ai.newBehaviorTree()
  bt:setRoot(lurek.ai.newAction(function() return "success" end))
  local status = bt:getLastStatus()
  print("LBehaviorTree:getLastStatus: " .. status)
end

--@api-stub: LBehaviorTree:getDebugState
-- Returns a table with internal debug state about this behavior tree.
do
  local bt = lurek.ai.newBehaviorTree()
  bt:setRoot(lurek.ai.newAction(function() return "success" end))
  local info = bt:getDebugState()
  print("LBehaviorTree:getDebugState: node_count=" .. tostring(info.node_count))
end

--@api-stub: LBehaviorTree:type
-- Returns the Lua-visible type name for this behavior tree handle.
do
  local bt = lurek.ai.newBehaviorTree()
  local t = bt:type()
  print("LBehaviorTree:type: " .. t)
end

--@api-stub: LBehaviorTree:typeOf
-- Returns whether this BT handle matches a supported type name.
do
  local bt = lurek.ai.newBehaviorTree()
  local is_bt = bt:typeOf("LBehaviorTree")
  local is_other = bt:typeOf("LAgent")
  print("LBehaviorTree:typeOf: LBehaviorTree=" .. tostring(is_bt) .. " LAgent=" .. tostring(is_other))
end

--@api-stub: LBTNode:addChild
-- Appends a child node to this composite (selector, sequence, or parallel).
do
  local seq = lurek.ai.newSequence()
  seq:addChild(lurek.ai.newAction(function() return "success" end))
  local count = seq:getChildCount()
  print("LBTNode:addChild: children=" .. tostring(count))
end

--@api-stub: LBTNode:getChildCount
-- Returns the number of children currently in this composite node.
do
  local sel = lurek.ai.newSelector()
  sel:addChild(lurek.ai.newAction(function() return "success" end))
  local count = sel:getChildCount()
  print("LBTNode:getChildCount: " .. tostring(count))
end

--@api-stub: LBTNode:reset
-- Resets this node and all descendants to their initial state.
do
  local seq = lurek.ai.newSequence()
  seq:addChild(lurek.ai.newAction(function() return "running" end))
  seq:reset()
  print("LBTNode:reset: done")
end

--@api-stub: LBTNode:setChild
-- Sets the single child of a decorator node (inverter, repeater, succeeder, guard).
do
  local inv = lurek.ai.newInverter()
  inv:setChild(lurek.ai.newAction(function() return "failure" end))
  print("LBTNode:setChild: configured")
end

--@api-stub: LBTNode:setCount
-- Sets the repeat count on a repeater decorator node.
do
  local rep = lurek.ai.newRepeater(3)
  rep:setCount(10)
  local count = rep:getCount()
  print("LBTNode:setCount: " .. tostring(count))
end

--@api-stub: LBTNode:getCount
-- Returns the repeat count from a repeater decorator node.
do
  local rep = lurek.ai.newRepeater(7)
  local count = rep:getCount()
  print("LBTNode:getCount: " .. tostring(count))
end

--@api-stub: LBTNode:setSuccessPolicy
-- Sets the success policy on a parallel composite node.
do
  local par = lurek.ai.newParallel("requireAll", "requireOne")
  par:setSuccessPolicy("requireOne")
  print("LBTNode:setSuccessPolicy: done")
end

--@api-stub: LBTNode:setFailurePolicy
-- Sets the failure policy on a parallel composite node.
do
  local par = lurek.ai.newParallel("requireOne", "requireAll")
  par:setFailurePolicy("requireOne")
  print("LBTNode:setFailurePolicy: done")
end

--@api-stub: LBTNode:getNodeType
-- Returns a string identifying what kind of BT node this is.
do
  local act = lurek.ai.newAction(function() return "success" end)
  print("LBTNode:getNodeType: " .. act:getNodeType())
end

--@api-stub: LBTNode:type
-- Returns the Lua-visible type name for this BT node handle.
do
  -- type() returns "LBTNode" for all behavior tree node handles.
  local node = lurek.ai.newAction(function() return "success" end)
  local t = node:type()
  -- All node kinds (action, selector, inverter, etc.) share the same type string.
  print("LBTNode:type: " .. t)
end

--@api-stub: LBTNode:typeOf
-- Returns whether this BT node handle matches a supported type name.
do
  -- typeOf accepts "LBTNode" and "Object". Other strings return false.
  local node = lurek.ai.newSelector()
  local is_node = node:typeOf("LBTNode")
  local is_other = node:typeOf("LImage")
  -- All BT node kinds (action, selector, etc.) respond true to "LBTNode".
  print("LBTNode:typeOf: LBTNode=" .. tostring(is_node) .. " LImage=" .. tostring(is_other))
end

--@api-stub: LSteeringManager:addSeek
-- Adds a seek behavior that steers toward a target position.
do
  -- Seek produces a force pointing directly at (tx, ty) with the given weight.
  -- Weight controls how much this behavior contributes to the combined output.
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(400, 300, 1.0)
  local fx, fy = steer:calculate(50, 50, 0, 0, 100, 200, 1 / 60)
  -- Seek never slows down near the target; use arrive for deceleration.
  print("LSteeringManager:addSeek: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end

--@api-stub: LSteeringManager:addFlee
-- Adds a flee behavior that steers away from a threat position.
do
  -- Flee produces a force pointing directly away from (tx, ty).
  local steer = lurek.ai.newSteeringManager()
  steer:addFlee(200, 200, 1.0)
  local fx, fy = steer:calculate(210, 195, 0, 0, 100, 200, 1 / 60)
  -- Flee is the opposite of seek; useful for panic or danger avoidance.
  print("LSteeringManager:addFlee: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end

--@api-stub: LSteeringManager:addArrive
-- Adds an arrive behavior that decelerates smoothly near a target position.
do
  -- Arrive works like seek but slows down within the deceleration radius.
  -- The 3rd argument is the deceleration distance; 4th is weight.
  local steer = lurek.ai.newSteeringManager()
  steer:addArrive(300, 300, 50, 1.0)
  local fx, fy = steer:calculate(280, 290, 30, 10, 100, 200, 1 / 60)
  -- Use arrive for movement that stops gracefully at a destination.
  print("LSteeringManager:addArrive: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end

--@api-stub: LSteeringManager:addWander
-- Adds a wander behavior for random undirected exploration movement.
do
  -- Wander projects a circle ahead and picks a random point on it each tick.
  -- Args: circle_radius, circle_distance, jitter_amount, weight.
  local steer = lurek.ai.newSteeringManager()
  steer:addWander(25, 50, 8, 0.5)
  local fx, fy = steer:calculate(100, 100, 10, 0, 80, 150, 1 / 60)
  -- Wander produces natural-looking exploration without explicit waypoints.
  print("LSteeringManager:addWander: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end

--@api-stub: LSteeringManager:addPursue
-- Adds a pursue behavior that chases another named agent.
do
  -- Pursue steers toward a named agent registered in the AI world.
  -- Pass the agent name string and an optional weight.
  local steer = lurek.ai.newSteeringManager()
  steer:addPursue("target_agent", 1.0)
  local count = steer:getBehaviorCount()
  -- Pursue is better than seek for chasing moving enemies.
  print("LSteeringManager:addPursue: behaviors=" .. tostring(count))
end

--@api-stub: LSteeringManager:addEvade
-- Adds an evade behavior that moves away from another named agent.
do
  -- Evade steers away from a named agent registered in the AI world.
  -- Pass the agent name string and an optional weight.
  local steer = lurek.ai.newSteeringManager()
  steer:addEvade("enemy_agent", 1.0)
  local count = steer:getBehaviorCount()
  -- Evade is better than flee for escaping moving pursuers.
  print("LSteeringManager:addEvade: behaviors=" .. tostring(count))
end

--@api-stub: LSteeringManager:addFlock
-- Adds a flocking behavior with separation, alignment, and cohesion weights.
do
  -- Flock uses a neighbor radius to find nearby agents and combines three forces.
  -- Args: neighbor_radius, separation_weight, alignment_weight, cohesion_weight, behavior_weight.
  local steer = lurek.ai.newSteeringManager()
  steer:addFlock(80, 1.5, 1.0, 1.0, 1.0)
  local count = steer:getBehaviorCount()
  -- Flocking creates emergent group patterns like bird murmurations.
  print("LSteeringManager:addFlock: behaviors=" .. tostring(count))
end

--@api-stub: LSteeringManager:getBehaviorCount
-- Returns the number of behaviors currently registered in this manager.
do
  -- Each add call increments the count. clearPath does not affect behavior count.
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(100, 100, 1.0)
  steer:addWander(10, 20, 3, 0.5)
  local count = steer:getBehaviorCount()
  -- Use behavior count for debug or to limit how many behaviors stack.
  print("LSteeringManager:getBehaviorCount: " .. tostring(count))
end

--@api-stub: LSteeringManager:setCombineMode
-- Sets how multiple behaviors are combined into the final force.
do
  -- Modes: "weighted" (sum all * weight), "priority" (first non-zero wins),
  -- "truncated" (sum until max force reached).
  local steer = lurek.ai.newSteeringManager()
  steer:setCombineMode("priority")
  local mode = steer:getCombineMode()
  -- "weighted" is the default and works for most cases.
  print("LSteeringManager:setCombineMode: " .. mode)
end

--@api-stub: LSteeringManager:getCombineMode
-- Returns the current combine mode string.
do
  local steer = lurek.ai.newSteeringManager()
  steer:setCombineMode("truncated")
  local mode = steer:getCombineMode()
  -- Use getCombineMode for serialization or debug display.
  print("LSteeringManager:getCombineMode: " .. mode)
end

--@api-stub: LSteeringManager:getLastSteering
-- Returns the x,y force from the most recent calculate() call.
do
  -- getLastSteering returns 0,0 before the first calculate call.
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(200, 200, 1.0)
  steer:calculate(50, 50, 0, 0, 100, 200, 1 / 60)
  local lx, ly = steer:getLastSteering()
  -- Use getLastSteering for debug visualization without recalculating.
  print("LSteeringManager:getLastSteering: " .. tostring(lx) .. "," .. tostring(ly))
end

--@api-stub: LSteeringManager:calculate
-- Computes the combined steering force for the agent's current state.
do
  -- Args: pos_x, pos_y, vel_x, vel_y, max_speed, max_force, dt.
  -- Returns two numbers: force_x, force_y.
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(500, 300, 1.0)
  steer:addWander(15, 30, 4, 0.3)
  local fx, fy = steer:calculate(100, 100, 20, 5, 150, 250, 1 / 60)
  -- Apply the force to velocity: vel = vel + force * dt, clamped to max_speed.
  print("LSteeringManager:calculate: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end

--@api-stub: LSteeringManager:setPath
-- Sets a waypoint path for path-following behavior.
do
  -- Path is an array of {x=n, y=n} tables. The agent follows waypoints in order.
  -- reach_radius controls how close the agent must be to advance to the next point.
  local steer = lurek.ai.newSteeringManager()
  local waypoints = {
    { x = 50, y = 50 },
    { x = 200, y = 80 },
    { x = 350, y = 200 },
    { x = 400, y = 400 },
  }
  steer:setPath(waypoints, 16.0, 1.0)
  local has = steer:hasPath()
  -- Path following uses the internal pathfinding force during calculate.
  print("LSteeringManager:setPath: hasPath=" .. tostring(has))
end

--@api-stub: LSteeringManager:clearPath
-- Removes the current path from this steering manager.
do
  -- clearPath stops path-following without removing other behaviors.
  local steer = lurek.ai.newSteeringManager()
  steer:setPath({ { x = 10, y = 10 }, { x = 100, y = 100 } }, 8.0, 1.0)
  steer:clearPath()
  local has = steer:hasPath()
  -- After clear, calculate no longer includes path-following force.
  print("LSteeringManager:clearPath: hasPath=" .. tostring(has))
end

--@api-stub: LSteeringManager:hasPath
-- Returns whether this steering manager has an active path.
do
  -- hasPath returns false before setPath or after clearPath.
  local steer = lurek.ai.newSteeringManager()
  local before = steer:hasPath()
  steer:setPath({ { x = 0, y = 0 }, { x = 50, y = 50 } }, 5.0, 1.0)
  local after = steer:hasPath()
  -- Check hasPath before calling getPathProgress.
  print("LSteeringManager:hasPath: before=" .. tostring(before) .. " after=" .. tostring(after))
end

--@api-stub: LSteeringManager:getPathProgress
-- Returns the current waypoint index and total waypoint count.
do
  -- Returns two integers: current_index (1-based), total_count.
  local steer = lurek.ai.newSteeringManager()
  steer:setPath({
    { x = 0, y = 0 },
    { x = 100, y = 50 },
    { x = 200, y = 100 },
  }, 10.0, 1.0)
  local idx, total = steer:getPathProgress()
  -- Use progress for UI (e.g. "Waypoint 2/5") or completion checks.
  print("LSteeringManager:getPathProgress: " .. tostring(idx) .. "/" .. tostring(total))
end

--@api-stub: LSteeringManager:type
-- Returns the Lua-visible type name for this steering manager handle.
do
  local steer = lurek.ai.newSteeringManager()
  local t = steer:type()
  print("LSteeringManager:type: " .. t)
end

--@api-stub: LSteeringManager:typeOf
-- Returns whether this steering handle matches a supported type name.
do
  local steer = lurek.ai.newSteeringManager()
  local is_steer = steer:typeOf("LSteeringManager")
  local is_other = steer:typeOf("LAgent")
  print("LSteeringManager:typeOf: LSteeringManager=" .. tostring(is_steer) .. " LAgent=" .. tostring(is_other))
end

--@api-stub: LSteeringManager:setSpatialHashCellSize
-- Sets the cell size for the internal spatial hash used by flocking.
do
  -- Spatial hash accelerates neighbor lookups for flocking.
  -- Smaller cells = more precise but more memory; bigger cells = faster but less accurate.
  local steer = lurek.ai.newSteeringManager()
  steer:setSpatialHashCellSize(32)
  -- Set cell size before adding flock behaviors for best performance.
  print("LSteeringManager:setSpatialHashCellSize: done")
end

--@api-stub: LSteeringManager:enableSpatialHash
-- Enables or disables the spatial hash for neighbor queries.
do
  -- When disabled, flocking uses brute-force neighbor checks.
  -- Enable it when you have many agents (> 20) sharing a manager.
  local steer = lurek.ai.newSteeringManager()
  steer:enableSpatialHash(true)
  steer:setSpatialHashCellSize(48)
  -- Spatial hash only helps with flock-type behaviors.
  print("LSteeringManager:enableSpatialHash: done")
end

--@api-stub: LSteeringManager:addCustomBehavior
-- Registers a custom steering behavior backed by a Lua callback.
do
  -- Custom behaviors let you implement game-specific steering logic.
  -- The callback receives (agent, dt) and must return fx, fy force values.
  local steer = lurek.ai.newSteeringManager()
  steer:addCustomBehavior(function(agent, dt)
    -- Simple constant push to the right
    return 50, 0
  end, 0.8)
  local count = steer:getBehaviorCount()
  -- Custom behaviors integrate with all other behaviors via combine mode.
  print("LSteeringManager:addCustomBehavior: behaviors=" .. tostring(count))
end

--@api-stub: LSteeringManager:applyCustomSteering
-- Runs enabled custom steering callbacks for an agent and returns the combined force.
do
  -- applyCustomSteering(agent, dt) invokes all custom callbacks registered
  -- with addCustomBehavior and returns the weighted combined force.
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("pusher")
  npc:setPosition(100, 100)
  local steer = lurek.ai.newSteeringManager()
  steer:addCustomBehavior(function(agent, dt)
    return 25, -10
  end, 1.0)
  local fx, fy = steer:applyCustomSteering(npc, 1 / 60)
  -- Use for scripted nudges: knockback, wind gusts, or magnetic fields.
  print("LSteeringManager:applyCustomSteering: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end

--@api-stub: LDialogueAI:setFSMState
-- Sets the current FSM state string used for topic/branch gating.
do
  -- Topics and branches can require a specific FSM state to be eligible.
  local dlg = lurek.ai.newDialogueAI()
  dlg:addTopic("battle_cry", 0.5, "combat", nil, "cry_score")
  dlg:setFSMState("combat")
  dlg:setUtilityScore("cry_score", 0.8)
  local topic = dlg:selectTopic()
  -- Without matching FSM state, gated topics are skipped.
  print("LDialogueAI:setFSMState: topic=" .. tostring(topic))
end

--@api-stub: LDialogueAI:setBTStatus
-- Sets the current behavior tree status string used for topic/branch gating.
do
  -- Topics can gate on BT status: "success", "failure", "running".
  local dlg = lurek.ai.newDialogueAI()
  dlg:addTopic("victory", 0.6, nil, "success", "vic_score")
  dlg:setBTStatus("success")
  dlg:setUtilityScore("vic_score", 0.9)
  local topic = dlg:selectTopic()
  -- BT status reflects the outcome of the agent's last behavior tick.
  print("LDialogueAI:setBTStatus: topic=" .. tostring(topic))
end

--@api-stub: LDialogueAI:setUtilityScore
-- Sets a named utility score used to weight topics and branches.
do
  -- Each topic/branch references a score key. Higher score = more likely selected.
  local dlg = lurek.ai.newDialogueAI()
  dlg:addTopic("greeting", 0.3, nil, nil, "greet_val")
  dlg:addTopic("farewell", 0.3, nil, nil, "bye_val")
  dlg:setUtilityScore("greet_val", 0.2)
  dlg:setUtilityScore("bye_val", 0.9)
  local topic = dlg:selectTopic()
  -- Update scores each frame from game state for dynamic dialogue.
  print("LDialogueAI:setUtilityScore: topic=" .. tostring(topic))
end

--@api-stub: LDialogueAI:clearUtilityScores
-- Removes all utility scores, resetting topic selection to base weights only.
do
  local dlg = lurek.ai.newDialogueAI()
  dlg:setUtilityScore("a", 1.0)
  dlg:setUtilityScore("b", 0.5)
  dlg:clearUtilityScores()
  -- After clear, topics fall back to their base weight for selection.
  print("LDialogueAI:clearUtilityScores: done")
end

--@api-stub: LDialogueAI:addTopic
-- Registers a named topic with base weight, optional FSM/BT gates, and a score key.
do
  -- Args: name, base_weight, required_fsm_state (nil=any), required_bt_status (nil=any), score_key.
  local dlg = lurek.ai.newDialogueAI()
  dlg:addTopic("weather_chat", 0.4, nil, nil, "chat_score")
  dlg:addTopic("combat_taunt", 0.3, "combat", "running", "taunt_score")
  local count = dlg:getTopicCount()
  -- Topics form the first level of dialogue selection.
  print("LDialogueAI:addTopic: count=" .. tostring(count))
end

--@api-stub: LDialogueAI:addBranch
-- Adds a named branch under a topic with its own gating and scoring.
do
  -- Branches subdivide a topic into specific lines or responses.
  -- Args: topic_name, branch_name, base_weight, fsm_gate, bt_gate, score_key.
  local dlg = lurek.ai.newDialogueAI()
  dlg:addTopic("threat", 0.5, nil, nil, "threat_score")
  dlg:addBranch("threat", "mock", 0.4, nil, nil, "mock_score")
  dlg:addBranch("threat", "demand", 0.6, nil, nil, "demand_score")
  dlg:setUtilityScore("threat_score", 0.8)
  dlg:setUtilityScore("mock_score", 0.3)
  dlg:setUtilityScore("demand_score", 0.7)
  local topic = dlg:selectTopic()
  local branch = topic and dlg:selectBranch(topic) or nil
  -- Branch selection narrows the topic to a specific dialogue line.
  print("LDialogueAI:addBranch: branch=" .. tostring(branch))
end

--@api-stub: LDialogueAI:selectTopic
-- Returns the name of the highest-scoring eligible topic or nil.
do
  -- Selection considers base_weight * utility_score, filtered by FSM/BT gates.
  local dlg = lurek.ai.newDialogueAI()
  dlg:addTopic("joke", 0.2, nil, nil, "joke_v")
  dlg:addTopic("quest_hint", 0.8, nil, nil, "hint_v")
  dlg:setUtilityScore("joke_v", 0.5)
  dlg:setUtilityScore("hint_v", 0.9)
  local topic = dlg:selectTopic() or "none"
  -- Nil result means no topic passes all gates.
  print("LDialogueAI:selectTopic: " .. topic)
end

--@api-stub: LDialogueAI:selectBranch
-- Returns the name of the highest-scoring eligible branch for a given topic.
do
  -- selectBranch(topic_name) returns nil if the topic has no branches.
  local dlg = lurek.ai.newDialogueAI()
  dlg:addTopic("trade", 0.5, nil, nil, "trade_v")
  dlg:addBranch("trade", "buy", 0.5, nil, nil, "buy_v")
  dlg:addBranch("trade", "sell", 0.5, nil, nil, "sell_v")
  dlg:setUtilityScore("trade_v", 1.0)
  dlg:setUtilityScore("buy_v", 0.3)
  dlg:setUtilityScore("sell_v", 0.7)
  local branch = dlg:selectBranch("trade") or "none"
  -- Use the selected branch to pick dialogue text from a table.
  print("LDialogueAI:selectBranch: " .. branch)
end

--@api-stub: LDialogueAI:getTopicCount
-- Returns the number of topics registered in this dialogue AI.
do
  local dlg = lurek.ai.newDialogueAI()
  dlg:addTopic("a", 0.5, nil, nil, "a_v")
  dlg:addTopic("b", 0.3, nil, nil, "b_v")
  dlg:addTopic("c", 0.2, nil, nil, "c_v")
  local count = dlg:getTopicCount()
  -- Topic count helps validate setup completeness.
  print("LDialogueAI:getTopicCount: " .. tostring(count))
end

--@api-stub: LDialogueAI:type
-- Returns the Lua-visible type name for this dialogue AI handle.
do
  local dlg = lurek.ai.newDialogueAI()
  local t = dlg:type()
  print("LDialogueAI:type: " .. t)
end

--@api-stub: LDialogueAI:typeOf
-- Returns whether this dialogue handle matches a supported type name.
do
  local dlg = lurek.ai.newDialogueAI()
  local is_dlg = dlg:typeOf("LDialogueAI")
  local is_other = dlg:typeOf("LQLearner")
  print("LDialogueAI:typeOf: LDialogueAI=" .. tostring(is_dlg) .. " LQLearner=" .. tostring(is_other))
end

--@api-stub: LQLearner:chooseAction
-- Selects an action for a given state using the current exploration policy.
do
  -- chooseAction(state) returns an action index. With high exploration rate,
  -- the action may be random; with low rate, it picks the highest Q-value.
  local ql = lurek.ai.newQLearner(5, 3)
  ql:setExplorationRate(0.0)
  ql:setQValue(0, 1, 0.9)
  local action = ql:chooseAction(0)
  -- With 0 exploration, chooseAction always returns the best known action.
  print("LQLearner:chooseAction: action=" .. tostring(action))
end

--@api-stub: LQLearner:bestAction
-- Returns the action with the highest Q-value for a given state.
do
  -- bestAction ignores exploration; it always returns the greedy choice.
  local ql = lurek.ai.newQLearner(4, 3)
  ql:setQValue(2, 0, 0.3)
  ql:setQValue(2, 1, 0.8)
  ql:setQValue(2, 2, 0.5)
  local best = ql:bestAction(2)
  -- Use bestAction for evaluation; use chooseAction for training.
  print("LQLearner:bestAction: " .. tostring(best))
end

--@api-stub: LQLearner:learn
-- Updates the Q-value for a (state, action) pair after observing a reward.
do
  -- learn(state, action, reward, next_state) applies the Q-learning update rule.
  local ql = lurek.ai.newQLearner(3, 2)
  ql:setLearningRate(0.5)
  ql:setDiscountFactor(0.9)
  ql:learn(0, 0, 1.0, 1)
  local qval = ql:getQValue(0, 0)
  -- Q-value increases toward rewards over repeated learn calls.
  print("LQLearner:learn: Q(0,0)=" .. tostring(qval))
end

--@api-stub: LQLearner:getQValue
-- Returns the current Q-value for a specific (state, action) pair.
do
  -- Q-values start at 0 and change through learn() or setQValue().
  local ql = lurek.ai.newQLearner(3, 2)
  ql:setQValue(1, 0, 0.75)
  local val = ql:getQValue(1, 0)
  local zero = ql:getQValue(1, 1)
  -- Read Q-values for debug visualization or policy export.
  print("LQLearner:getQValue: (1,0)=" .. tostring(val) .. " (1,1)=" .. tostring(zero))
end

--@api-stub: LQLearner:setQValue
-- Directly sets the Q-value for a specific (state, action) pair.
do
  -- setQValue is useful for loading pre-trained policies from save files.
  local ql = lurek.ai.newQLearner(4, 2)
  ql:setQValue(0, 0, 0.5)
  ql:setQValue(0, 1, 0.9)
  local best = ql:bestAction(0)
  -- After setting, bestAction and chooseAction see the new values.
  print("LQLearner:setQValue: best=" .. tostring(best))
end

--@api-stub: LQLearner:endEpisode
-- Signals the end of a training episode and applies exploration decay.
do
  -- endEpisode multiplies exploration rate by the decay factor.
  -- Call it after a game round ends (win, lose, or timeout).
  local ql = lurek.ai.newQLearner(3, 2)
  ql:setExplorationRate(1.0)
  ql:setExplorationDecay(0.95)
  ql:endEpisode()
  local rate = ql:getExplorationRate()
  -- Over many episodes, exploration decreases toward zero.
  print("LQLearner:endEpisode: rate=" .. tostring(rate))
end

--@api-stub: LQLearner:getEpisodeCount
-- Returns the number of completed episodes since creation.
do
  local ql = lurek.ai.newQLearner(3, 2)
  ql:endEpisode()
  ql:endEpisode()
  ql:endEpisode()
  local episodes = ql:getEpisodeCount()
  -- Use episode count for logging or stopping training after N episodes.
  print("LQLearner:getEpisodeCount: " .. tostring(episodes))
end

--@api-stub: LQLearner:getStateCount
-- Returns the number of states this Q-learner was initialized with.
do
  local ql = lurek.ai.newQLearner(8, 4)
  local states = ql:getStateCount()
  -- State count is fixed at creation; you cannot add states later.
  print("LQLearner:getStateCount: " .. tostring(states))
end

--@api-stub: LQLearner:getActionCount
-- Returns the number of actions this Q-learner was initialized with.
do
  local ql = lurek.ai.newQLearner(8, 4)
  local actions = ql:getActionCount()
  -- Action count is fixed at creation; you cannot add actions later.
  print("LQLearner:getActionCount: " .. tostring(actions))
end

--@api-stub: LQLearner:setLearningRate
-- Sets how quickly new rewards override old Q-values.
do
  -- Learning rate (alpha) between 0 and 1. Higher = faster learning, less stable.
  local ql = lurek.ai.newQLearner(3, 2)
  ql:setLearningRate(0.2)
  local rate = ql:getLearningRate()
  -- Typical values: 0.1 for stability, 0.5 for fast adaptation.
  print("LQLearner:setLearningRate: " .. tostring(rate))
end

--@api-stub: LQLearner:getLearningRate
-- Returns the current learning rate.
do
  local ql = lurek.ai.newQLearner(3, 2)
  ql:setLearningRate(0.15)
  local rate = ql:getLearningRate()
  print("LQLearner:getLearningRate: " .. tostring(rate))
end

--@api-stub: LQLearner:setDiscountFactor
-- Sets how much future rewards are valued relative to immediate rewards.
do
  -- Discount factor (gamma) between 0 and 1. Higher = more forward-looking.
  local ql = lurek.ai.newQLearner(3, 2)
  ql:setDiscountFactor(0.99)
  local gamma = ql:getDiscountFactor()
  -- 0.99 plans far ahead; 0.5 focuses on immediate rewards.
  print("LQLearner:setDiscountFactor: " .. tostring(gamma))
end

--@api-stub: LQLearner:getDiscountFactor
-- Returns the current discount factor.
do
  local ql = lurek.ai.newQLearner(3, 2)
  ql:setDiscountFactor(0.9)
  local gamma = ql:getDiscountFactor()
  print("LQLearner:getDiscountFactor: " .. tostring(gamma))
end

--@api-stub: LQLearner:setExplorationRate
-- Sets the probability of choosing a random action instead of the best one.
do
  -- Exploration rate (epsilon) between 0 and 1. 1.0 = pure random, 0.0 = pure greedy.
  local ql = lurek.ai.newQLearner(3, 2)
  ql:setExplorationRate(0.5)
  local rate = ql:getExplorationRate()
  -- Start high and decay over episodes for explore-then-exploit.
  print("LQLearner:setExplorationRate: " .. tostring(rate))
end

--@api-stub: LQLearner:getExplorationRate
-- Returns the current exploration rate.
do
  local ql = lurek.ai.newQLearner(3, 2)
  ql:setExplorationRate(0.3)
  local rate = ql:getExplorationRate()
  print("LQLearner:getExplorationRate: " .. tostring(rate))
end

--@api-stub: LQLearner:setExplorationDecay
-- Sets the multiplicative decay applied to exploration rate each episode.
do
  -- Decay factor between 0 and 1. Each endEpisode: rate = rate * decay.
  local ql = lurek.ai.newQLearner(3, 2)
  ql:setExplorationRate(1.0)
  ql:setExplorationDecay(0.9)
  ql:endEpisode()
  local rate = ql:getExplorationRate()
  -- After 1 episode with 0.9 decay: rate = 1.0 * 0.9 = 0.9.
  print("LQLearner:setExplorationDecay: rate=" .. tostring(rate))
end

--- AI Examples Part 3: Q-Learning (cont.), Utility AI, GOAP, Influence Maps, Squads


--@api-stub: LQLearner:getExplorationDecay
-- Returns the per-episode multiplicative decay applied to exploration rate.
do
    local ql = lurek.ai.newQLearner(4, 3)
    ql:setExplorationDecay(0.99)
    local decay = ql:getExplorationDecay()
    print("exploration decay = " .. decay)
end

--@api-stub: LQLearner:serialize
-- Serializes the entire Q-table and parameters to a JSON string.
do
    local ql = lurek.ai.newQLearner(3, 2)
    ql:learn(1, 1, 1.0, 2)
    ql:learn(2, 2, 5.0, 1)
    local json = ql:serialize()
    print("serialized length = " .. #json)
end

--@api-stub: LQLearner:deserialize
-- Restores Q-table and parameters from a previously serialized JSON string.
do
    local ql = lurek.ai.newQLearner(3, 2)
    ql:learn(1, 2, 10.0, 3)
    local saved = ql:serialize()
    local ql2 = lurek.ai.newQLearner(3, 2)
    ql2:deserialize(saved)
    local q = ql2:getQValue(1, 2)
    print("restored Q(1,2) = " .. q)
end

--@api-stub: LQLearner:type
-- Returns the type name string "LQLearner".
do
    local ql = lurek.ai.newQLearner(2, 2)
    local t = ql:type()
    print("type = " .. t)
end

--@api-stub: LQLearner:typeOf
-- Checks whether this object is of the given type name.
do
    local ql = lurek.ai.newQLearner(2, 2)
    local yes = ql:typeOf("LQLearner")
    local no = ql:typeOf("LAgent")
    print("is LQLearner = " .. tostring(yes) .. ", is LAgent = " .. tostring(no))
end

--@api-stub: LUtilityAI:addAction
-- Registers a named action with a scorer function and optional weight.
do
    local uai = lurek.ai.newUtilityAI()
    uai:addAction("eat", function() return 0.8 end, 1.0)
    uai:addAction("sleep", function() return 0.3 end, 1.0)
    print("actions added = " .. uai:getActionCount())
end

--@api-stub: LUtilityAI:evaluate
-- Evaluates all actions and returns the name of the highest-scoring one.
do
    local uai = lurek.ai.newUtilityAI()
    uai:addAction("attack", function() return 0.9 end)
    uai:addAction("defend", function() return 0.4 end)
    local chosen = uai:evaluate()
    print("chosen action = " .. tostring(chosen))
end

--@api-stub: LUtilityAI:getActionCount
-- Returns the number of registered actions.
do
    local uai = lurek.ai.newUtilityAI()
    uai:addAction("patrol", function() return 0.5 end)
    uai:addAction("idle", function() return 0.1 end)
    uai:addAction("chase", function() return 0.7 end)
    print("action count = " .. uai:getActionCount())
end

--@api-stub: LUtilityAI:getLastAction
-- Returns the name of the action chosen in the most recent evaluate() call.
do
    local uai = lurek.ai.newUtilityAI()
    uai:addAction("gather", function() return 0.6 end)
    uai:addAction("build", function() return 0.2 end)
    uai:evaluate()
    local last = uai:getLastAction()
    print("last action = " .. tostring(last))
end

--@api-stub: LUtilityAI:addConsideration
-- Attaches a consideration to a named action with a response curve.
do
    local uai = lurek.ai.newUtilityAI()
    uai:addAction("heal", function() return 0.5 end)
    uai:addConsideration("heal", "low_health", function() return 0.9 end, "linear", 1.0, 0.0, 0.0, 1.0)
    uai:evaluate()
    print("consideration added, last = " .. tostring(uai:getLastAction()))
end

--@api-stub: LUtilityAI:type
-- Returns the type name string "LUtilityAI".
do
    local uai = lurek.ai.newUtilityAI()
    print("type = " .. uai:type())
end

--@api-stub: LUtilityAI:typeOf
-- Checks whether this object is of the given type name.
do
    local uai = lurek.ai.newUtilityAI()
    print("is LUtilityAI = " .. tostring(uai:typeOf("LUtilityAI")))
end

--@api-stub: LGOAPPlanner:addAction
-- Registers an action with a name, cost, and callback function.
do
    local goap = lurek.ai.newGOAPPlanner()
    goap:addAction("chop_wood", 2, function() print("  chopping wood") end)
    goap:addAction("build_house", 5, function() print("  building house") end)
    print("goap actions = " .. goap:getActionCount())
end

--@api-stub: LGOAPPlanner:setPrecondition
-- Sets a precondition fact that must be true for an action to be usable.
do
    local goap = lurek.ai.newGOAPPlanner()
    goap:addAction("cook", 1, function() end)
    goap:setPrecondition("cook", "has_food", true)
    print("precondition set for cook")
end

--@api-stub: LGOAPPlanner:setEffect
-- Sets a world-state effect that an action produces when executed.
do
    local goap = lurek.ai.newGOAPPlanner()
    goap:addAction("mine_ore", 3, function() end)
    goap:setEffect("mine_ore", "has_ore", true)
    print("effect set for mine_ore")
end

--@api-stub: LGOAPPlanner:addGoal
-- Registers a named goal with a priority value.
do
    local goap = lurek.ai.newGOAPPlanner()
    goap:addGoal("survive", 10)
    goap:addGoal("explore", 3)
    print("goals = " .. goap:getGoalCount())
end

--@api-stub: LGOAPPlanner:setGoalState
-- Defines a required world-state fact for a goal to be satisfied.
do
    local goap = lurek.ai.newGOAPPlanner()
    goap:addGoal("build_shelter", 5)
    goap:setGoalState("build_shelter", "shelter_built", true)
    print("goal state set for build_shelter")
end

--@api-stub: LGOAPPlanner:plan
-- Searches for a sequence of actions that transforms the world state to satisfy the highest-priority goal.
do
    local goap = lurek.ai.newGOAPPlanner()
    goap:addAction("get_wood", 1, function() end)
    goap:setEffect("get_wood", "has_wood", true)
    goap:addAction("build", 2, function() end)
    goap:setPrecondition("build", "has_wood", true)
    goap:setEffect("build", "house_done", true)
    goap:addGoal("build_house", 10)
    goap:setGoalState("build_house", "house_done", true)
    local plan = goap:plan({ has_wood = false, house_done = false }, 10)
    print("plan steps = " .. #plan)
end

--@api-stub: LGOAPPlanner:getActionCount
-- Returns the number of registered actions.
do
    local goap = lurek.ai.newGOAPPlanner()
    goap:addAction("a1", 1, function() end)
    goap:addAction("a2", 2, function() end)
    print("action count = " .. goap:getActionCount())
end

--@api-stub: LGOAPPlanner:getGoalCount
-- Returns the number of registered goals.
do
    local goap = lurek.ai.newGOAPPlanner()
    goap:addGoal("g1", 1)
    goap:addGoal("g2", 5)
    goap:addGoal("g3", 3)
    print("goal count = " .. goap:getGoalCount())
end

--@api-stub: LGOAPPlanner:getMaxIterations
-- Returns the current maximum iteration limit for the planner search.
do
    local goap = lurek.ai.newGOAPPlanner()
    local max = goap:getMaxIterations()
    print("default max iterations = " .. max)
end

--@api-stub: LGOAPPlanner:setMaxIterations
-- Sets the maximum iteration limit for the planner search.
do
    local goap = lurek.ai.newGOAPPlanner()
    goap:setMaxIterations(500)
    print("max iterations = " .. goap:getMaxIterations())
end

--@api-stub: LGOAPPlanner:type
-- Returns the type name string "LGOAPPlanner".
do
    local goap = lurek.ai.newGOAPPlanner()
    print("type = " .. goap:type())
end

--@api-stub: LGOAPPlanner:typeOf
-- Checks whether this object is of the given type name.
do
    local goap = lurek.ai.newGOAPPlanner()
    print("is LGOAPPlanner = " .. tostring(goap:typeOf("LGOAPPlanner")))
end

--@api-stub: LInfluenceMap:addLayer
-- Adds a named layer to the influence map grid.
do
    local im = lurek.ai.newInfluenceMap(16, 16, 1.0)
    im:addLayer("threat")
    im:addLayer("resources")
    print("layers added: threat, resources")
end

--@api-stub: LInfluenceMap:hasLayer
-- Returns true if a layer with the given name exists.
do
    local im = lurek.ai.newInfluenceMap(8, 8, 2.0)
    im:addLayer("heat")
    print("has heat = " .. tostring(im:hasLayer("heat")))
    print("has cold = " .. tostring(im:hasLayer("cold")))
end

--@api-stub: LInfluenceMap:setInfluence
-- Sets the influence value at a specific cell coordinate on a layer.
do
    local im = lurek.ai.newInfluenceMap(10, 10, 1.0)
    im:addLayer("danger")
    im:setInfluence("danger", 5, 5, 1.0)
    im:setInfluence("danger", 3, 7, 0.5)
    print("set influence at (5,5) and (3,7)")
end

--@api-stub: LInfluenceMap:getInfluence
-- Returns the influence value at a specific cell coordinate on a layer.
do
    local im = lurek.ai.newInfluenceMap(10, 10, 1.0)
    im:addLayer("food")
    im:setInfluence("food", 4, 4, 0.75)
    local val = im:getInfluence("food", 4, 4)
    print("food at (4,4) = " .. val)
end

--@api-stub: LInfluenceMap:stampInfluence
-- Stamps a circular area of influence on a layer around a world position.
do
    local im = lurek.ai.newInfluenceMap(20, 20, 1.0)
    im:addLayer("noise")
    im:stampInfluence("noise", 10.0, 10.0, 3.0, 1.0, 0.5)
    local center = im:getInfluence("noise", 10, 10)
    print("noise center = " .. center)
end

--@api-stub: LInfluenceMap:propagate
-- Spreads influence values across neighboring cells using a momentum factor.
do
    local im = lurek.ai.newInfluenceMap(10, 10, 1.0)
    im:addLayer("scent")
    im:setInfluence("scent", 5, 5, 1.0)
    im:propagate("scent", 0.8)
    local neighbor = im:getInfluence("scent", 4, 5)
    print("scent propagated to (4,5) = " .. neighbor)
end

--@api-stub: LInfluenceMap:decay
-- Multiplies all influence values on a layer by a decay factor (0..1 shrinks).
do
    local im = lurek.ai.newInfluenceMap(8, 8, 1.0)
    im:addLayer("heat")
    im:setInfluence("heat", 4, 4, 1.0)
    im:decay("heat", 0.5)
    local val = im:getInfluence("heat", 4, 4)
    print("heat after decay = " .. val)
end

--@api-stub: LInfluenceMap:clearLayer
-- Resets all cell values on a specific layer to zero.
do
    local im = lurek.ai.newInfluenceMap(8, 8, 1.0)
    im:addLayer("marks")
    im:setInfluence("marks", 2, 2, 1.0)
    im:clearLayer("marks")
    local val = im:getInfluence("marks", 2, 2)
    print("after clear = " .. val)
end

--@api-stub: LInfluenceMap:clearAll
-- Resets all cell values on all layers to zero.
do
    local im = lurek.ai.newInfluenceMap(8, 8, 1.0)
    im:addLayer("a")
    im:addLayer("b")
    im:setInfluence("a", 1, 1, 1.0)
    im:setInfluence("b", 2, 2, 0.5)
    im:clearAll()
    print("all cleared, a(1,1) = " .. im:getInfluence("a", 1, 1))
end

--@api-stub: LInfluenceMap:getMaxPosition
-- Returns the cell coordinates with the highest influence on a layer.
do
    local im = lurek.ai.newInfluenceMap(10, 10, 1.0)
    im:addLayer("gold")
    im:setInfluence("gold", 7, 3, 0.9)
    im:setInfluence("gold", 2, 8, 0.4)
    local mx, my = im:getMaxPosition("gold")
    print("max gold at (" .. mx .. ", " .. my .. ")")
end

--@api-stub: LInfluenceMap:getMinPosition
-- Returns the cell coordinates with the lowest influence on a layer.
do
    local im = lurek.ai.newInfluenceMap(10, 10, 1.0)
    im:addLayer("cold")
    im:setInfluence("cold", 1, 1, -0.5)
    im:setInfluence("cold", 5, 5, 0.3)
    local mx, my = im:getMinPosition("cold")
    print("min cold at (" .. mx .. ", " .. my .. ")")
end

--@api-stub: LInfluenceMap:queryRect
-- Sums all influence values within a rectangular region on a layer.
do
    local im = lurek.ai.newInfluenceMap(10, 10, 1.0)
    im:addLayer("energy")
    im:setInfluence("energy", 2, 2, 0.5)
    im:setInfluence("energy", 3, 3, 0.5)
    local total = im:queryRect("energy", 1, 1, 4, 4)
    print("energy in rect = " .. total)
end

--@api-stub: LInfluenceMap:blend
-- Blends two source layers with independent weights into a destination layer.
do
    local im = lurek.ai.newInfluenceMap(8, 8, 1.0)
    im:addLayer("threat")
    im:addLayer("reward")
    im:addLayer("combined")
    im:setInfluence("threat", 4, 4, 1.0)
    im:setInfluence("reward", 4, 4, 0.8)
    im:blend("threat", 0.5, "reward", 0.5, "combined")
    local val = im:getInfluence("combined", 4, 4)
    print("blended (4,4) = " .. val)
end

--@api-stub: LInfluenceMap:getWidth
-- Returns the grid width in cells.
do
    local im = lurek.ai.newInfluenceMap(16, 12, 2.0)
    print("width = " .. im:getWidth())
end

--@api-stub: LInfluenceMap:getHeight
-- Returns the grid height in cells.
do
    local im = lurek.ai.newInfluenceMap(16, 12, 2.0)
    print("height = " .. im:getHeight())
end

--@api-stub: LInfluenceMap:getCellSize
-- Returns the world-space size of each cell.
do
    local im = lurek.ai.newInfluenceMap(8, 8, 2.5)
    print("cell size = " .. im:getCellSize())
end

--@api-stub: LInfluenceMap:type
-- Returns the type name string "LInfluenceMap".
do
    local im = lurek.ai.newInfluenceMap(4, 4, 1.0)
    print("type = " .. im:type())
end

--@api-stub: LInfluenceMap:typeOf
-- Checks whether this object is of the given type name.
do
    local im = lurek.ai.newInfluenceMap(4, 4, 1.0)
    print("is LInfluenceMap = " .. tostring(im:typeOf("LInfluenceMap")))
end

--@api-stub: LSquad:getName
-- Returns the squad's name.
do
    local sq = lurek.ai.newSquad("alpha")
    print("squad name = " .. sq:getName())
end

--@api-stub: LSquad:addMember
-- Adds a named agent to the squad.
do
    local sq = lurek.ai.newSquad("bravo")
    sq:addMember("soldier_1")
    sq:addMember("soldier_2")
    print("members = " .. sq:getMemberCount())
end

--@api-stub: LSquad:removeMember
-- Removes a named agent from the squad.
do
    local sq = lurek.ai.newSquad("charlie")
    sq:addMember("scout")
    sq:addMember("medic")
    sq:removeMember("scout")
    print("after remove = " .. sq:getMemberCount())
end

--@api-stub: LSquad:getMemberCount
-- Returns the number of current squad members.
do
    local sq = lurek.ai.newSquad("delta")
    sq:addMember("a")
    sq:addMember("b")
    sq:addMember("c")
    print("count = " .. sq:getMemberCount())
end

--@api-stub: LSquad:getMembers
-- Returns a table of all member names currently in the squad.
do
    local sq = lurek.ai.newSquad("echo")
    sq:addMember("sniper")
    sq:addMember("heavy")
    local members = sq:getMembers()
    print("members: " .. table.concat(members, ", "))
end

--@api-stub: LSquad:setLeader
-- Designates a named member as the squad leader.
do
    local sq = lurek.ai.newSquad("foxtrot")
    sq:addMember("captain")
    sq:addMember("private")
    sq:setLeader("captain")
    print("leader = " .. sq:getLeader())
end

--@api-stub: LSquad:getLeader
-- Returns the name of the current squad leader, or nil if none set.
do
    local sq = lurek.ai.newSquad("golf")
    sq:addMember("commander")
    sq:setLeader("commander")
    local leader = sq:getLeader()
    print("leader = " .. tostring(leader))
end

--@api-stub: LSquad:setFormation
-- Sets the formation type and spacing used for position calculations.
do
    local sq = lurek.ai.newSquad("hotel")
    sq:addMember("point")
    sq:addMember("left")
    sq:addMember("right")
    sq:setFormation("wedge", 2.0)
    print("formation set to wedge, spacing 2.0")
end

--- AI Examples Part 4: Squad (cont.), Command Queue, Trait Profile, Stimulus World, Context Steering, Need System


--@api-stub: LSquad:getFormation
-- Returns the current formation type name.
do
    local sq = lurek.ai.newSquad("recon")
    sq:setFormation("line", 3.0)
    local f = sq:getFormation()
    print("formation = " .. f)
end

--@api-stub: LSquad:getFormationSpacing
-- Returns the spacing value used between formation positions.
do
    local sq = lurek.ai.newSquad("assault")
    sq:setFormation("wedge", 2.5)
    local s = sq:getFormationSpacing()
    print("spacing = " .. s)
end

--@api-stub: LSquad:getFormationPosition
-- Computes the world position for a member given the leader position and formation.
do
    local sq = lurek.ai.newSquad("patrol")
    sq:addMember("lead")
    sq:addMember("flank_l")
    sq:addMember("flank_r")
    sq:setFormation("wedge", 2.0)
    local x, y = sq:getFormationPosition(2, 100.0, 50.0)
    print("member 2 pos = " .. x .. ", " .. y)
end

--@api-stub: LSquad:getBlackboard
-- Returns the squad-level shared blackboard for coordination data.
do
    local sq = lurek.ai.newSquad("intel")
    local bb = sq:getBlackboard()
    bb:setNumber("threat_level", 3)
    print("squad bb threat = " .. bb:getNumber("threat_level"))
end

--@api-stub: LSquad:type
-- Returns the type name string "LSquad".
do
    local sq = lurek.ai.newSquad("test")
    print("type = " .. sq:type())
end

--@api-stub: LSquad:typeOf
-- Checks whether this object is of the given type name.
do
    local sq = lurek.ai.newSquad("test2")
    print("is LSquad = " .. tostring(sq:typeOf("LSquad")))
end

--@api-stub: LCommandQueue:enqueue
-- Adds a command to the back of the queue with a type label and callback.
do
    local cq = lurek.ai.newCommandQueue()
    cq:enqueue("move", function() print("  moving") end, { targetX = 10, targetY = 20 })
    cq:enqueue("attack", function() print("  attacking") end)
    print("queue size = " .. cq:getCount())
end

--@api-stub: LCommandQueue:pushFront
-- Inserts a command at the front of the queue (executes next).
do
    local cq = lurek.ai.newCommandQueue()
    cq:enqueue("patrol", function() end)
    cq:pushFront("dodge", function() print("  dodging") end)
    print("next type = " .. cq:getCurrentType())
end

--@api-stub: LCommandQueue:replace
-- Replaces all queued commands with a single new one.
do
    local cq = lurek.ai.newCommandQueue()
    cq:enqueue("idle", function() end)
    cq:enqueue("gather", function() end)
    cq:replace("retreat", function() print("  retreating") end)
    print("after replace count = " .. cq:getCount())
end

--@api-stub: LCommandQueue:cancelCurrent
-- Removes the currently executing (front) command from the queue.
do
    local cq = lurek.ai.newCommandQueue()
    cq:enqueue("walk", function() end)
    cq:enqueue("talk", function() end)
    cq:cancelCurrent()
    print("after cancel, type = " .. tostring(cq:getCurrentType()))
end

--@api-stub: LCommandQueue:clear
-- Removes all commands from the queue.
do
    local cq = lurek.ai.newCommandQueue()
    cq:enqueue("a", function() end)
    cq:enqueue("b", function() end)
    cq:clear()
    print("after clear, empty = " .. tostring(cq:isEmpty()))
end

--@api-stub: LCommandQueue:getCount
-- Returns the number of commands currently queued.
do
    local cq = lurek.ai.newCommandQueue()
    cq:enqueue("x", function() end)
    cq:enqueue("y", function() end)
    cq:enqueue("z", function() end)
    print("count = " .. cq:getCount())
end

--@api-stub: LCommandQueue:isEmpty
-- Returns true if the queue has no commands.
do
    local cq = lurek.ai.newCommandQueue()
    print("empty initially = " .. tostring(cq:isEmpty()))
    cq:enqueue("step", function() end)
    print("empty after enqueue = " .. tostring(cq:isEmpty()))
end

--@api-stub: LCommandQueue:getCurrentType
-- Returns the type label of the front command, or nil if empty.
do
    local cq = lurek.ai.newCommandQueue()
    cq:enqueue("harvest", function() end)
    print("current type = " .. tostring(cq:getCurrentType()))
end

--@api-stub: LCommandQueue:getCurrentTarget
-- Returns the target table of the front command, if set via opts.
do
    local cq = lurek.ai.newCommandQueue()
    cq:enqueue("go", function() end, { targetX = 5, targetY = 10 })
    local tgt = cq:getCurrentTarget()
    print("target = " .. tostring(tgt))
end

--@api-stub: LCommandQueue:type
-- Returns the type name string "LCommandQueue".
do
    local cq = lurek.ai.newCommandQueue()
    print("type = " .. cq:type())
end

--@api-stub: LCommandQueue:typeOf
-- Checks whether this object is of the given type name.
do
    local cq = lurek.ai.newCommandQueue()
    print("is LCommandQueue = " .. tostring(cq:typeOf("LCommandQueue")))
end

--@api-stub: LTraitProfile:set
-- Sets the base value of a named trait.
do
    local tp = lurek.ai.newTraitProfile()
    tp:set("courage", 0.7)
    tp:set("aggression", 0.3)
    print("courage = " .. tp:get("courage"))
end

--@api-stub: LTraitProfile:get
-- Returns the effective value of a trait (base + active modifiers).
do
    local tp = lurek.ai.newTraitProfile()
    tp:set("speed", 1.0)
    tp:addModifier("speed", 0.5, 5.0, "buff")
    local effective = tp:get("speed")
    print("effective speed = " .. effective)
end

--@api-stub: LTraitProfile:getBase
-- Returns the base value of a trait, ignoring modifiers.
do
    local tp = lurek.ai.newTraitProfile()
    tp:set("strength", 0.8)
    tp:addModifier("strength", 0.2, 10.0, "potion")
    print("base strength = " .. tp:getBase("strength"))
end

--@api-stub: LTraitProfile:addModifier
-- Adds a temporary modifier to a trait that expires after a duration.
do
    local tp = lurek.ai.newTraitProfile()
    tp:set("defense", 0.5)
    tp:addModifier("defense", 0.3, 8.0, "shield_spell")
    print("defense with modifier = " .. tp:get("defense"))
end

--@api-stub: LTraitProfile:removeModifiers
-- Removes all modifiers from a given source.
do
    local tp = lurek.ai.newTraitProfile()
    tp:set("luck", 0.4)
    tp:addModifier("luck", 0.2, 10.0, "charm")
    tp:addModifier("luck", 0.1, 5.0, "charm")
    tp:removeModifiers("charm")
    print("luck after remove = " .. tp:get("luck"))
end

--@api-stub: LTraitProfile:update
-- Advances time, expiring modifiers whose duration has elapsed.
do
    local tp = lurek.ai.newTraitProfile()
    tp:set("rage", 0.5)
    tp:addModifier("rage", 0.5, 2.0, "berserk")
    tp:update(3.0)
    print("rage after 3s = " .. tp:get("rage"))
end

--@api-stub: LTraitProfile:has
-- Returns true if a trait with the given name exists.
do
    local tp = lurek.ai.newTraitProfile()
    tp:set("wisdom", 0.6)
    print("has wisdom = " .. tostring(tp:has("wisdom")))
    print("has charm = " .. tostring(tp:has("charm")))
end

--@api-stub: LTraitProfile:traitCount
-- Returns the number of defined traits.
do
    local tp = lurek.ai.newTraitProfile()
    tp:set("a", 0.1)
    tp:set("b", 0.2)
    tp:set("c", 0.3)
    print("trait count = " .. tp:traitCount())
end

--@api-stub: LTraitProfile:archetype
-- Returns a string label describing the dominant trait pattern.
do
    local tp = lurek.ai.newTraitProfile()
    tp:set("aggression", 0.9)
    tp:set("caution", 0.1)
    tp:set("curiosity", 0.4)
    local arch = tp:archetype() or "unknown"
    print("archetype = " .. arch)
end

--@api-stub: LTraitProfile:type
-- Returns the type name string "LTraitProfile".
do
    local tp = lurek.ai.newTraitProfile()
    print("type = " .. tp:type())
end

--@api-stub: LTraitProfile:typeOf
-- Checks whether this object is of the given type name.
do
    local tp = lurek.ai.newTraitProfile()
    print("is LTraitProfile = " .. tostring(tp:typeOf("LTraitProfile")))
end

--@api-stub: LStimulusWorld:addVisual
-- Adds a visual stimulus at a position with intensity, radius, and tag.
do
    local sw = lurek.ai.newStimulusWorld()
    local id = sw:addVisual(100, 200, 0.8, 50.0, "enemy_spotted")
    print("visual stimulus id = " .. id)
end

--@api-stub: LStimulusWorld:addAuditory
-- Adds an auditory stimulus at a position with intensity, radius, decay, and tag.
do
    local sw = lurek.ai.newStimulusWorld()
    local id = sw:addAuditory(50, 80, 0.6, 30.0, 0.1, "footstep")
    print("auditory stimulus id = " .. id)
end

--@api-stub: LStimulusWorld:remove
-- Removes a stimulus by its ID.
do
    local sw = lurek.ai.newStimulusWorld()
    local id = sw:addVisual(10, 10, 1.0, 20.0, "flash")
    sw:remove(id)
    print("removed stimulus, count = " .. sw:count())
end

--@api-stub: LStimulusWorld:update
-- Advances time, decaying auditory stimuli and removing expired ones.
do
    local sw = lurek.ai.newStimulusWorld()
    sw:addAuditory(0, 0, 1.0, 10.0, 0.5, "bang")
    sw:update(5.0)
    print("after update, count = " .. sw:count())
end

--@api-stub: LStimulusWorld:count
-- Returns the number of active stimuli.
do
    local sw = lurek.ai.newStimulusWorld()
    sw:addVisual(0, 0, 1.0, 10.0, "a")
    sw:addVisual(5, 5, 0.5, 8.0, "b")
    print("stimulus count = " .. sw:count())
end

--@api-stub: LStimulusWorld:clear
-- Removes all stimuli.
do
    local sw = lurek.ai.newStimulusWorld()
    sw:addVisual(0, 0, 1.0, 10.0, "x")
    sw:addAuditory(1, 1, 0.5, 5.0, 0.2, "y")
    sw:clear()
    print("after clear, count = " .. sw:count())
end

--@api-stub: LStimulusWorld:type
-- Returns the type name string "LStimulusWorld".
do
    local sw = lurek.ai.newStimulusWorld()
    print("type = " .. sw:type())
end

--@api-stub: LStimulusWorld:typeOf
-- Checks whether this object is of the given type name.
do
    local sw = lurek.ai.newStimulusWorld()
    print("is LStimulusWorld = " .. tostring(sw:typeOf("LStimulusWorld")))
end

--@api-stub: LContextSteering:addSeekTarget
-- Adds a seek interest toward a world position with a weight.
do
    local cs = lurek.ai.newContextSteering(8)
    cs:addSeekTarget(200, 150, 1.0)
    print("seek target added at (200, 150)")
end

--@api-stub: LContextSteering:addWander
-- Adds a random wander interest with jitter and weight.
do
    local cs = lurek.ai.newContextSteering(8)
    cs:addWander(0.3, 0.5)
    print("wander behavior added")
end

--@api-stub: LContextSteering:addAvoidPoint
-- Adds a danger signal around a point with radius and weight.
do
    local cs = lurek.ai.newContextSteering(8)
    cs:addAvoidPoint(50, 50, 20.0, 1.5)
    print("avoid point at (50, 50) radius 20")
end

--@api-stub: LContextSteering:addAvoidBounds
-- Adds a rectangular boundary avoidance with a margin.
do
    local cs = lurek.ai.newContextSteering(8)
    cs:addAvoidBounds(0, 0, 800, 600, 30.0, 1.0)
    print("avoid bounds set for 800x600 area")
end

--@api-stub: LContextSteering:clearBehaviors
-- Removes all registered interest and danger behaviors.
do
    local cs = lurek.ai.newContextSteering(8)
    cs:addSeekTarget(100, 100, 1.0)
    cs:addAvoidPoint(50, 50, 10.0, 1.0)
    cs:clearBehaviors()
    print("behaviors cleared")
end

--@api-stub: LContextSteering:evaluate
-- Evaluates all behaviors and returns the chosen steering direction.
do
    local cs = lurek.ai.newContextSteering(8)
    cs:addSeekTarget(300, 200, 1.0)
    cs:addAvoidPoint(150, 150, 30.0, 2.0)
    local dx, dy = cs:evaluate(100, 100, 1.0, 0.0)
    print("direction = " .. dx .. ", " .. dy)
end

--@api-stub: LContextSteering:chosenMagnitude
-- Returns the magnitude of the last evaluated steering direction.
do
    local cs = lurek.ai.newContextSteering(8)
    cs:addSeekTarget(200, 200, 1.0)
    cs:evaluate(0, 0, 0, 0)
    local mag = cs:chosenMagnitude()
    print("magnitude = " .. mag)
end

--@api-stub: LContextSteering:slotCount
-- Returns the number of directional slots in this context map.
do
    local cs = lurek.ai.newContextSteering(16)
    print("slots = " .. cs:slotCount())
end

--@api-stub: LContextSteering:type
-- Returns the type name string "LContextSteering".
do
    local cs = lurek.ai.newContextSteering(8)
    print("type = " .. cs:type())
end

--@api-stub: LContextSteering:typeOf
-- Checks whether this object is of the given type name.
do
    local cs = lurek.ai.newContextSteering(8)
    print("is LContextSteering = " .. tostring(cs:typeOf("LContextSteering")))
end

--@api-stub: LNeedSystem:addNeed
-- Registers a need with a decay rate, urgency threshold, and urgency factor.
do
    local ns = lurek.ai.newNeedSystem()
    ns:addNeed("hunger", 0.1, 0.7, 2.0)
    ns:addNeed("thirst", 0.15, 0.6, 1.5)
    print("needs registered")
end

--@api-stub: LNeedSystem:update
-- Advances time, applying decay to all needs.
do
    local ns = lurek.ai.newNeedSystem()
    ns:addNeed("fatigue", 0.05, 0.8, 1.0)
    ns:update(2.0)
    local urgent = ns:mostUrgent()
    print("most urgent after 2s = " .. tostring(urgent))
end

--@api-stub: LNeedSystem:mostUrgent
-- Returns the name of the most urgent need, or nil if none are urgent.
do
    local ns = lurek.ai.newNeedSystem()
    ns:addNeed("hunger", 0.5, 0.3, 2.0)
    ns:update(1.0)
    local name = ns:mostUrgent()
    print("most urgent = " .. tostring(name))
end

--@api-stub: LNeedSystem:satisfy
-- Satisfies a need by the given amount, reducing its value.
do
    local ns = lurek.ai.newNeedSystem()
    ns:addNeed("thirst", 0.2, 0.5, 1.5)
    ns:update(3.0)
    ns:satisfy("thirst", 0.8)
    print("thirst satisfied")
end

--- AI Examples Part 5: Need System (cont.), AI Director, HTN, MCTS, Emotion, ORCA, Neural Net, Genetic Algorithm


--@api-stub: LNeedSystem:valueOf
-- Returns the current value of a named need.
do
    local ns = lurek.ai.newNeedSystem()
    ns:addNeed("hunger", 0.1, 0.7, 2.0)
    ns:update(2.0)
    local val = ns:valueOf("hunger")
    print("hunger value = " .. val)
end

--@api-stub: LNeedSystem:type
-- Returns the type name string "LNeedSystem".
do
    local ns = lurek.ai.newNeedSystem()
    print("type = " .. ns:type())
end

--@api-stub: LNeedSystem:typeOf
-- Checks whether this object is of the given type name.
do
    local ns = lurek.ai.newNeedSystem()
    print("is LNeedSystem = " .. tostring(ns:typeOf("LNeedSystem")))
end

--@api-stub: LAIDirector:pushEvent
-- Reports a gameplay event intensity to the director for tension tracking.
do
    local dir = lurek.ai.newAIDirector()
    dir:pushEvent(0.5)
    dir:pushEvent(0.8)
    print("events pushed, tension = " .. dir:tension())
end

--@api-stub: LAIDirector:update
-- Advances the director state by dt seconds, updating phase transitions.
do
    local dir = lurek.ai.newAIDirector()
    dir:pushEvent(1.0)
    dir:update(2.0)
    print("phase after update = " .. dir:phase())
end

--@api-stub: LAIDirector:tension
-- Returns the current tension value (0..1 range).
do
    local dir = lurek.ai.newAIDirector()
    dir:setTension(0.6)
    print("tension = " .. dir:tension())
end

--@api-stub: LAIDirector:phase
-- Returns the current phase name (e.g. "build", "sustain", "peak", "relax").
do
    local dir = lurek.ai.newAIDirector()
    local p = dir:phase()
    print("initial phase = " .. p)
end

--@api-stub: LAIDirector:spawnRateFactor
-- Returns a multiplier for enemy spawn rate based on current tension.
do
    local dir = lurek.ai.newAIDirector()
    dir:setTension(0.9)
    dir:update(0.1)
    print("spawn rate factor = " .. dir:spawnRateFactor())
end

--@api-stub: LAIDirector:lootFactor
-- Returns a multiplier for loot drops based on current tension.
do
    local dir = lurek.ai.newAIDirector()
    dir:setTension(0.2)
    dir:update(0.1)
    print("loot factor = " .. dir:lootFactor())
end

--@api-stub: LAIDirector:ambientIntensity
-- Returns the suggested ambient intensity (audio, effects) based on tension.
do
    local dir = lurek.ai.newAIDirector()
    dir:setTension(0.7)
    dir:update(0.1)
    print("ambient intensity = " .. dir:ambientIntensity())
end

--@api-stub: LAIDirector:setTension
-- Directly sets the tension value, overriding natural buildup.
do
    local dir = lurek.ai.newAIDirector()
    dir:setTension(0.5)
    print("tension set to " .. dir:tension())
end

--@api-stub: LAIDirector:reset
-- Resets the director to initial state (zero tension, starting phase).
do
    local dir = lurek.ai.newAIDirector()
    dir:setTension(0.9)
    dir:reset()
    print("after reset, tension = " .. dir:tension())
end

--@api-stub: LAIDirector:type
-- Returns the type name string "LAIDirector".
do
    local dir = lurek.ai.newAIDirector()
    print("type = " .. dir:type())
end

--@api-stub: LAIDirector:typeOf
-- Checks whether this object is of the given type name.
do
    local dir = lurek.ai.newAIDirector()
    print("is LAIDirector = " .. tostring(dir:typeOf("LAIDirector")))
end

--@api-stub: LHTNDomain:addPrimitive
-- Adds a primitive task with preconditions, effects, and facts it clears.
do
    local htn = lurek.ai.newHTNDomain()
    htn:addPrimitive("chop", { "has_axe" }, { "has_wood" }, {})
    htn:addPrimitive("build", { "has_wood" }, { "shelter_done" }, { "has_wood" })
    print("primitives = " .. htn:taskCount())
end

--@api-stub: LHTNDomain:addCompound
-- Adds a compound task with ordered methods containing preconditions and subtasks.
do
    local htn = lurek.ai.newHTNDomain()
    htn:addPrimitive("mine", {}, { "has_ore" }, {})
    htn:addPrimitive("smelt", { "has_ore" }, { "has_metal" }, { "has_ore" })
    htn:addCompound("get_metal", {
        { name = "mine_and_smelt", preconditions = {}, sub_tasks = { "mine", "smelt" } },
    })
    print("compound added, tasks = " .. htn:taskCount())
end

--@api-stub: LHTNDomain:plan
-- Decomposes a root task given world state facts and returns primitive task names.
do
    local htn = lurek.ai.newHTNDomain()
    htn:addPrimitive("gather", {}, { "has_food" }, {})
    htn:addPrimitive("cook", { "has_food" }, { "meal_ready" }, { "has_food" })
    htn:addCompound("prepare_meal", {
        { name = "full_cook", preconditions = {}, sub_tasks = { "gather", "cook" } },
    })
    local plan = htn:plan("prepare_meal", { has_food = 0, meal_ready = 0 })
    if plan then
        print("plan = " .. table.concat(plan --[[@as table]], " -> "))
    end
end

--@api-stub: LHTNDomain:taskCount
-- Returns the total number of registered tasks (primitive + compound).
do
    local htn = lurek.ai.newHTNDomain()
    htn:addPrimitive("a", {}, {}, {})
    htn:addPrimitive("b", {}, {}, {})
    print("task count = " .. htn:taskCount())
end

--@api-stub: LHTNDomain:type
-- Returns the type name string "LHTNDomain".
do
    local htn = lurek.ai.newHTNDomain()
    print("type = " .. htn:type())
end

--@api-stub: LHTNDomain:typeOf
-- Checks whether this object is of the given type name.
do
    local htn = lurek.ai.newHTNDomain()
    print("is LHTNDomain = " .. tostring(htn:typeOf("LHTNDomain")))
end

--@api-stub: LMCTSEngine:search
-- Runs Monte Carlo tree search from a root state and returns the best action.
do
    local mcts = lurek.ai.newMCTSEngine(100, 1.4, 10, 42)
    local action = mcts:search(
        1,
        function(state) return { 1, 2, 3 } end,
        function(state, act) return state + act end,
        function(state) return -math.abs(state - 5) end
    )
    print("best action = " .. tostring(action))
end

--@api-stub: LMCTSEngine:type
-- Returns the type name string "LMCTSEngine".
do
    local mcts = lurek.ai.newMCTSEngine(50, 1.0, 5, 0)
    print("type = " .. mcts:type())
end

--@api-stub: LMCTSEngine:typeOf
-- Checks whether this object is of the given type name.
do
    local mcts = lurek.ai.newMCTSEngine(50, 1.0, 5, 0)
    print("is LMCTSEngine = " .. tostring(mcts:typeOf("LMCTSEngine")))
end

--@api-stub: LEmotionModel:add
-- Registers an emotion with rest value, decay rate, and minimum visibility threshold.
do
    local em = lurek.ai.newEmotionModel()
    em:add("joy", 0.3, 0.1, 0.2)
    em:add("anger", 0.0, 0.05, 0.3)
    print("emotions registered")
end

--@api-stub: LEmotionModel:trigger
-- Increases an emotion's value by the given amount.
do
    local em = lurek.ai.newEmotionModel()
    em:add("fear", 0.0, 0.1, 0.2)
    em:trigger("fear", 0.7)
    print("fear = " .. em:get("fear"))
end

--@api-stub: LEmotionModel:get
-- Returns the current value of a named emotion.
do
    local em = lurek.ai.newEmotionModel()
    em:add("sadness", 0.2, 0.05, 0.1)
    em:trigger("sadness", 0.5)
    local val = em:get("sadness")
    print("sadness = " .. val)
end

--@api-stub: LEmotionModel:dominant
-- Returns the name of the emotion with the highest current value.
do
    local em = lurek.ai.newEmotionModel()
    em:add("joy", 0.0, 0.1, 0.1)
    em:add("anger", 0.0, 0.1, 0.1)
    em:trigger("joy", 0.3)
    em:trigger("anger", 0.8)
    print("dominant = " .. tostring(em:dominant()))
end

--@api-stub: LEmotionModel:isActive
-- Returns true if the emotion is above its minimum visibility threshold.
do
    local em = lurek.ai.newEmotionModel()
    em:add("surprise", 0.0, 0.1, 0.5)
    em:trigger("surprise", 0.2)
    print("surprise active = " .. tostring(em:isActive("surprise")))
    em:trigger("surprise", 0.5)
    print("surprise active = " .. tostring(em:isActive("surprise")))
end

--@api-stub: LEmotionModel:update
-- Advances time, decaying emotions toward their rest values.
do
    local em = lurek.ai.newEmotionModel()
    em:add("excitement", 0.0, 0.2, 0.1)
    em:trigger("excitement", 1.0)
    em:update(3.0)
    print("excitement after 3s = " .. em:get("excitement"))
end

--@api-stub: LEmotionModel:reset
-- Resets all emotions to their rest values.
do
    local em = lurek.ai.newEmotionModel()
    em:add("rage", 0.0, 0.1, 0.2)
    em:trigger("rage", 1.0)
    em:reset()
    print("rage after reset = " .. em:get("rage"))
end

--@api-stub: LEmotionModel:type
-- Returns the type name string "LEmotionModel".
do
    local em = lurek.ai.newEmotionModel()
    print("type = " .. em:type())
end

--@api-stub: LEmotionModel:typeOf
-- Checks whether this object is of the given type name.
do
    local em = lurek.ai.newEmotionModel()
    print("is LEmotionModel = " .. tostring(em:typeOf("LEmotionModel")))
end

--@api-stub: LORCASolver:addAgent
-- Adds an agent with position, radius, and max speed. Returns zero-based index.
do
    local orca = lurek.ai.newORCASolver(2.0)
    local idx = orca:addAgent(10.0, 20.0, 0.5, 3.0)
    print("agent index = " .. idx)
end

--@api-stub: LORCASolver:setPreferredVelocity
-- Sets the preferred velocity for an agent by index.
do
    local orca = lurek.ai.newORCASolver(2.0)
    orca:addAgent(0, 0, 0.5, 5.0)
    orca:setPreferredVelocity(0, 2.0, 1.0)
    print("preferred velocity set for agent 0")
end

--@api-stub: LORCASolver:setPosition
-- Updates the position of an agent by index.
do
    local orca = lurek.ai.newORCASolver(2.0)
    orca:addAgent(0, 0, 0.5, 5.0)
    orca:setPosition(0, 5.0, 3.0)
    print("position updated for agent 0")
end

--@api-stub: LORCASolver:compute
-- Computes collision-free velocities for all agents over dt.
do
    local orca = lurek.ai.newORCASolver(1.5)
    orca:addAgent(0, 0, 0.5, 3.0)
    orca:addAgent(5, 0, 0.5, 3.0)
    orca:setPreferredVelocity(0, 1.0, 0.0)
    orca:setPreferredVelocity(1, -1.0, 0.0)
    orca:compute(0.016)
    print("collision avoidance computed")
end

--@api-stub: LORCASolver:getSafeVelocity
-- Returns the safe velocity for an agent after compute().
do
    local orca = lurek.ai.newORCASolver(1.5)
    orca:addAgent(0, 0, 0.5, 3.0)
    orca:setPreferredVelocity(0, 2.0, 0.0)
    orca:compute(0.016)
    local vx, vy = orca:getSafeVelocity(0)
    print("safe velocity = " .. vx .. ", " .. vy)
end

--@api-stub: LORCASolver:agentCount
-- Returns the number of agents in the solver.
do
    local orca = lurek.ai.newORCASolver(2.0)
    orca:addAgent(0, 0, 1.0, 2.0)
    orca:addAgent(5, 5, 1.0, 2.0)
    print("agent count = " .. orca:agentCount())
end

--@api-stub: LORCASolver:type
-- Returns the type name string "LORCASolver".
do
    local orca = lurek.ai.newORCASolver(1.0)
    print("type = " .. orca:type())
end

--@api-stub: LORCASolver:typeOf
-- Checks whether this object is of the given type name.
do
    local orca = lurek.ai.newORCASolver(1.0)
    print("is LORCASolver = " .. tostring(orca:typeOf("LORCASolver")))
end

--@api-stub: LNeuralNet:addLayer
-- Adds a layer with input count, output count, and activation function name.
do
    local nn = lurek.ai.newNeuralNet()
    nn:addLayer(4, 8, "relu")
    nn:addLayer(8, 2, "sigmoid")
    print("layers = " .. nn:layerCount())
end

--@api-stub: LNeuralNet:forward
-- Feeds an input array through the network and returns the output array.
do
    local nn = lurek.ai.newNeuralNet()
    nn:addLayer(2, 3, "relu")
    nn:addLayer(3, 1, "sigmoid")
    local out = nn:forward({ 0.5, 0.8 })
    print("output[1] = " .. out[1])
end

--@api-stub: LNeuralNet:setWeights
-- Sets all network weights from a flat number array.
do
    local nn = lurek.ai.newNeuralNet()
    nn:addLayer(2, 2, "relu")
    local count = nn:paramCount()
    local weights = {}
    for i = 1, count do weights[i] = 0.1 * i end
    nn:setWeights(weights)
    print("weights set, count = " .. count)
end

--@api-stub: LNeuralNet:getWeights
-- Returns all network weights as a flat number array.
do
    local nn = lurek.ai.newNeuralNet()
    nn:addLayer(2, 2, "relu")
    local w = nn:getWeights()
    print("weight count = " .. #w)
end

--@api-stub: LNeuralNet:paramCount
-- Returns the total number of trainable parameters (weights + biases).
do
    local nn = lurek.ai.newNeuralNet()
    nn:addLayer(3, 4, "relu")
    nn:addLayer(4, 1, "sigmoid")
    print("param count = " .. nn:paramCount())
end

--@api-stub: LNeuralNet:layerCount
-- Returns the number of layers in the network.
do
    local nn = lurek.ai.newNeuralNet()
    nn:addLayer(5, 10, "relu")
    nn:addLayer(10, 5, "relu")
    nn:addLayer(5, 2, "sigmoid")
    print("layer count = " .. nn:layerCount())
end

--@api-stub: LNeuralNet:type
-- Returns the type name string "LNeuralNet".
do
    local nn = lurek.ai.newNeuralNet()
    print("type = " .. nn:type())
end

--@api-stub: LNeuralNet:typeOf
-- Checks whether this object is of the given type name.
do
    local nn = lurek.ai.newNeuralNet()
    print("is LNeuralNet = " .. tostring(nn:typeOf("LNeuralNet")))
end

--@api-stub: LGeneticAlgorithm:evolve
-- Runs one generation of selection, crossover, and mutation.
do
    local ga = lurek.ai.newGeneticAlgorithm(10, 5, 42)
    for i = 0, 9 do
        ga:setFitness(i, math.random())
    end
    ga:evolve()
    print("evolved to generation " .. ga:generation())
end

--@api-stub: LGeneticAlgorithm:generation
-- Returns the current generation number.
do
    local ga = lurek.ai.newGeneticAlgorithm(8, 4, 0)
    print("initial generation = " .. ga:generation())
    for i = 0, 7 do ga:setFitness(i, 1.0) end
    ga:evolve()
    print("after evolve = " .. ga:generation())
end

--- AI Examples Part 6: Genetic Algorithm (cont.), Bandit, Neuroevolution, Strategy AI, AI LOD


--@api-stub: LGeneticAlgorithm:popSize
-- Returns the population size.
do
    local ga = lurek.ai.newGeneticAlgorithm(20, 6, 99)
    print("pop size = " .. ga:popSize())
end

--@api-stub: LGeneticAlgorithm:setFitness
-- Sets the fitness value for a chromosome by zero-based index.
do
    local ga = lurek.ai.newGeneticAlgorithm(5, 3, 0)
    ga:setFitness(0, 10.0)
    ga:setFitness(1, 5.0)
    ga:setFitness(2, 8.0)
    print("fitness set for 3 chromosomes")
end

--@api-stub: LGeneticAlgorithm:getGenes
-- Returns the gene array for a chromosome by zero-based index.
do
    local ga = lurek.ai.newGeneticAlgorithm(4, 3, 42)
    local genes = ga:getGenes(0)
    print("genes[0] length = " .. #genes)
end

--@api-stub: LGeneticAlgorithm:bestGenes
-- Returns the gene array of the chromosome with the highest fitness.
do
    local ga = lurek.ai.newGeneticAlgorithm(5, 4, 7)
    for i = 0, 4 do
        ga:setFitness(i, i * 2.0)
    end
    ga:evolve()
    local best = ga:bestGenes()
    print("best genes length = " .. #best)
end

--@api-stub: LGeneticAlgorithm:type
-- Returns the type name string "LGeneticAlgorithm".
do
    local ga = lurek.ai.newGeneticAlgorithm(4, 2, 0)
    print("type = " .. ga:type())
end

--@api-stub: LGeneticAlgorithm:typeOf
-- Checks whether this object is of the given type name.
do
    local ga = lurek.ai.newGeneticAlgorithm(4, 2, 0)
    print("is LGeneticAlgorithm = " .. tostring(ga:typeOf("LGeneticAlgorithm")))
end

--@api-stub: LBandit:select
-- Selects an arm index using the configured strategy (e.g. epsilon-greedy, UCB1).
do
    local b = lurek.ai.newBandit(4, "epsilon_greedy", 0.1, 42)
    local arm = b:select()
    print("selected arm = " .. arm)
end

--@api-stub: LBandit:update
-- Updates the reward estimate for an arm after observing a result.
do
    local b = lurek.ai.newBandit(3, "ucb1", 0.0, 0)
    local arm = b:select()
    b:update(arm, 1.0)
    print("updated arm " .. arm .. " with reward 1.0")
end

--@api-stub: LBandit:bestArm
-- Returns the arm index with the highest estimated reward.
do
    local b = lurek.ai.newBandit(3, "epsilon_greedy", 0.0, 10)
    b:update(0, 0.5)
    b:update(1, 0.9)
    b:update(2, 0.3)
    print("best arm = " .. b:bestArm())
end

--@api-stub: LBandit:reset
-- Resets all arm statistics to initial state.
do
    local b = lurek.ai.newBandit(3, "epsilon_greedy", 0.1, 0)
    b:update(0, 1.0)
    b:update(1, 0.5)
    b:reset()
    print("total pulls after reset = " .. b:totalPulls())
end

--@api-stub: LBandit:armCount
-- Returns the number of arms in the bandit.
do
    local b = lurek.ai.newBandit(5, "ucb1", 0.0, 0)
    print("arm count = " .. b:armCount())
end

--@api-stub: LBandit:totalPulls
-- Returns the total number of arm selections made so far.
do
    local b = lurek.ai.newBandit(3, "epsilon_greedy", 0.1, 0)
    b:select()
    b:select()
    b:select()
    print("total pulls = " .. b:totalPulls())
end

--@api-stub: LBandit:type
-- Returns the type name string "LBandit".
do
    local b = lurek.ai.newBandit(2, "ucb1", 0.0, 0)
    print("type = " .. b:type())
end

--@api-stub: LBandit:typeOf
-- Checks whether this object is of the given type name.
do
    local b = lurek.ai.newBandit(2, "ucb1", 0.0, 0)
    print("is LBandit = " .. tostring(b:typeOf("LBandit")))
end

--@api-stub: LNeuroevolution:evolve
-- Runs one generation of selection, crossover, and mutation on the population.
do
    local ne = lurek.ai.newNeuroevolution(
        { { inputs = 2, outputs = 3, activation = "relu" }, { inputs = 3, outputs = 1, activation = "sigmoid" } },
        10, 42
    )
    for i = 0, 9 do
        ne:setFitness(i, math.random())
    end
    ne:evolve()
    print("evolved to gen " .. ne:generation())
end

--@api-stub: LNeuroevolution:setFitness
-- Sets the fitness value for a chromosome by zero-based index.
do
    local ne = lurek.ai.newNeuroevolution(
        { { inputs = 2, outputs = 2 } }, 5, 0
    )
    ne:setFitness(0, 10.0)
    ne:setFitness(4, 5.0)
    print("fitness assigned to chromosomes 0 and 4")
end

--@api-stub: LNeuroevolution:chromosomeToNet
-- Converts a chromosome into a usable neural network handle.
do
    local ne = lurek.ai.newNeuroevolution(
        { { inputs = 3, outputs = 2, activation = "relu" } }, 4, 7
    )
    local net = ne:chromosomeToNet(0)
    if net then
        print("network created from chromosome 0")
    end
end

--@api-stub: LNeuroevolution:bestNetwork
-- Returns the neural network of the best-performing chromosome.
do
    local ne = lurek.ai.newNeuroevolution(
        { { inputs = 2, outputs = 1 } }, 6, 0
    )
    for i = 0, 5 do ne:setFitness(i, i * 1.5) end
    ne:evolve()
    local best = ne:bestNetwork()
    print("best network obtained = " .. tostring(best ~= nil))
end

--@api-stub: LNeuroevolution:bestFitness
-- Returns the highest fitness value in the current population.
do
    local ne = lurek.ai.newNeuroevolution(
        { { inputs = 2, outputs = 1 } }, 4, 0
    )
    ne:setFitness(0, 3.0)
    ne:setFitness(1, 7.0)
    ne:setFitness(2, 5.0)
    ne:setFitness(3, 1.0)
    print("best fitness = " .. ne:bestFitness())
end

--@api-stub: LNeuroevolution:popSize
-- Returns the population size.
do
    local ne = lurek.ai.newNeuroevolution(
        { { inputs = 1, outputs = 1 } }, 12, 0
    )
    print("pop size = " .. ne:popSize())
end

--@api-stub: LNeuroevolution:generation
-- Returns the current generation number.
do
    local ne = lurek.ai.newNeuroevolution(
        { { inputs = 1, outputs = 1 } }, 4, 0
    )
    print("initial generation = " .. ne:generation())
end

--@api-stub: LNeuroevolution:type
-- Returns the type name string "LNeuroevolution".
do
    local ne = lurek.ai.newNeuroevolution(
        { { inputs = 1, outputs = 1 } }, 4, 0
    )
    print("type = " .. ne:type())
end

--@api-stub: LNeuroevolution:typeOf
-- Checks whether this object is of the given type name.
do
    local ne = lurek.ai.newNeuroevolution(
        { { inputs = 1, outputs = 1 } }, 4, 0
    )
    print("is LNeuroevolution = " .. tostring(ne:typeOf("LNeuroevolution")))
end

--@api-stub: LStrategyAI:addGoal
-- Registers a named strategic goal for evaluation.
do
    local strat = lurek.ai.newStrategyAI(5.0)
    strat:addGoal("expand")
    strat:addGoal("defend")
    strat:addGoal("research")
    print("goals registered")
end

--@api-stub: LStrategyAI:addTag
-- Adds a tag that can influence goal scoring logic.
do
    local strat = lurek.ai.newStrategyAI(3.0)
    strat:addTag("war_declared")
    strat:addTag("low_resources")
    print("tags added")
end

--@api-stub: LStrategyAI:removeTag
-- Removes a previously added tag.
do
    local strat = lurek.ai.newStrategyAI(3.0)
    strat:addTag("peace")
    strat:removeTag("peace")
    print("tag removed")
end

--@api-stub: LStrategyAI:update
-- Advances time; when the update interval elapses, scores all goals and picks the best.
do
    local strat = lurek.ai.newStrategyAI(1.0)
    strat:addGoal("attack")
    strat:addGoal("retreat")
    strat:update(1.5, function(goal)
        if goal == "attack" then return 0.8 end
        return 0.2
    end)
    print("active = " .. tostring(strat:activeGoal()))
end

--@api-stub: LStrategyAI:forceEvaluate
-- Forces immediate goal evaluation regardless of the update interval.
do
    local strat = lurek.ai.newStrategyAI(10.0)
    strat:addGoal("build")
    strat:addGoal("scout")
    strat:forceEvaluate(function(goal)
        if goal == "scout" then return 5.0 end
        return 1.0
    end)
    print("forced active = " .. tostring(strat:activeGoal()))
end

--@api-stub: LStrategyAI:activeGoal
-- Returns the name of the currently active goal, or nil if none.
do
    local strat = lurek.ai.newStrategyAI(1.0)
    strat:addGoal("idle")
    local active = strat:activeGoal()
    print("active goal = " .. tostring(active))
end

--@api-stub: LStrategyAI:timeUntilNext
-- Returns seconds remaining until the next scheduled evaluation.
do
    local strat = lurek.ai.newStrategyAI(5.0)
    strat:addGoal("wait")
    strat:update(2.0, function() return 1.0 end)
    print("time until next = " .. strat:timeUntilNext())
end

--@api-stub: LStrategyAI:type
-- Returns the type name string "LStrategyAI".
do
    local strat = lurek.ai.newStrategyAI(1.0)
    print("type = " .. strat:type())
end

--@api-stub: LStrategyAI:typeOf
-- Checks whether this object is of the given type name.
do
    local strat = lurek.ai.newStrategyAI(1.0)
    print("is LStrategyAI = " .. tostring(strat:typeOf("LStrategyAI")))
end

--@api-stub: LAILod:tierFor
-- Returns the LOD tier for an agent at a given distance from the reference position.
do
    local lod = lurek.ai.newAILod()
    local tier = lod:tierFor(100, 200, 0, 0)
    print("tier = " .. tier)
end

--@api-stub: LAILod:shouldUpdate
-- Returns true if a tier should run AI logic on the given frame.
do
    local lod = lurek.ai.newAILod()
    local run = lod:shouldUpdate(0, 1)
    print("tier 0 should update on frame 1 = " .. tostring(run))
end

--@api-stub: LAILod:tierCount
-- Returns the number of defined LOD tiers.
do
    local lod = lurek.ai.newAILod()
    print("tier count = " .. lod:tierCount())
end

--@api-stub: LAILod:tierName
-- Returns the name of a tier by zero-based index.
do
    local lod = lurek.ai.newAILod()
    local name = lod:tierName(0)
    print("tier 0 name = " .. name)
end

--@api-stub: LAILod:type
-- Returns the type name string "LAILod".
do
    local lod = lurek.ai.newAILod()
    print("type = " .. lod:type())
end

--@api-stub: LAILod:typeOf
-- Checks whether this object is of the given type name.
do
    local lod = lurek.ai.newAILod()
    print("is LAILod = " .. tostring(lod:typeOf("LAILod")))
end

print("content/examples/ai.lua")
