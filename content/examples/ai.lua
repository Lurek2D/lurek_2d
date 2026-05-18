-- content/examples/ai.lua
-- Demonstrates every lurek.ai.* function with realistic game AI usage patterns.
-- Run: cargo run -- content/examples/ai.lua
--@api-stub: lurek.ai.newWorld
-- Creates an isolated AI world for agents, blackboards, and custom decision callbacks.
do
  -- Use one AI world per simulation scope, such as one dungeon floor or town map.
  -- Agents are looked up by stable string names, so save IDs and squad IDs can
  -- refer to the same NPC without storing the full Lua handle everywhere.
  local world = lurek.ai.newWorld()
  local guard = world:addAgent("guard_01")
  guard:setPosition(128, 96)
  guard:setVelocity(0, 0)
  guard:setDecisionModel("custom")
  guard:setCustomModel(function(agent, blackboard, dt)
    blackboard:setNumber("last_dt", dt)
    blackboard:setString("state", "watching_gate")
    agent:setPriority(10)
  end)

  local found_guard = world:getAgent("guard_01")
  if found_guard then
    local pos_x, pos_y = found_guard:getPosition()
    local global_facts = world:getGlobalBlackboard()
    global_facts:setString("region", "north_gate")
    lurek.log.info("agent at " .. tostring(pos_x) .. ", " .. tostring(pos_y), "ai")
  end

  -- Drive the world from the game update loop in a real project.
  world:update(1 / 60)
  local agent_count = world:getAgentCount()
  lurek.log.info("AI agents: " .. tostring(agent_count), "ai")
end
--@api-stub: lurek.ai.newBlackboard
-- Creates an empty AI blackboard for typed local facts.
do
  -- Blackboards keep AI facts typed at the boundary: numbers, booleans, and
  -- strings are read with defaults so missing keys do not break decision code.
  local blackboard = lurek.ai.newBlackboard()
  blackboard:setNumber("alert_level", 0.3)
  blackboard:setBool("player_seen", false)
  blackboard:setString("last_sound", "footstep")

  local alert_level = blackboard:getNumber("alert_level", 0)
  local player_seen = blackboard:getBool("player_seen", false)
  local last_sound = blackboard:getString("last_sound", "none")
  if blackboard:has("last_sound") then
    lurek.log.info(last_sound .. " alert=" .. tostring(alert_level), "ai")
  end

  local key_count = blackboard:getSize()
  local keys = blackboard:getKeys()
  lurek.log.info("blackboard keys=" .. tostring(key_count) .. ", first=" .. tostring(keys[1]), "ai")
  blackboard:remove("last_sound")
  blackboard:clear()
end
--@api-stub: lurek.ai.newStateMachine
-- Creates an empty finite state machine with Lua-backed states and transitions.
do
  -- FSMs are useful when an NPC has a small set of named phases. Register the
  -- states first, then use transitions or forceState to move between phases.
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("patrol", {
    onEnter = function() lurek.log.info("guard starts patrol", "ai") end,
    onExit = function() lurek.log.info("guard leaves patrol", "ai") end,
  })
  fsm:addState("chase", {
    onEnter = function() lurek.log.info("guard starts chase", "ai") end,
  })
  fsm:addTransition("patrol", "chase", function() return true end, 5)
  fsm:setInitialState("patrol")
  local current_state = fsm:getCurrentState() or "none"
  lurek.log.info("fsm state=" .. current_state, "ai")
  fsm:forceState("chase")
  local seconds_in_state = fsm:getTimeInState()
  lurek.log.info("fsm timer=" .. tostring(seconds_in_state), "ai")
end
--@api-stub: lurek.ai.newBehaviorTree
-- Creates an empty behavior tree that can receive a root node.
do
  -- The exposed tree object stores a root node and reports debug state. Build
  -- the node graph with LBTNode methods, then assign the root with setRoot.
  local behavior_tree = lurek.ai.newBehaviorTree()
  local root = lurek.ai.newSequence()
  root:addChild(lurek.ai.newAction(function() return "success" end))
  behavior_tree:setRoot(root)
  local debug_state = behavior_tree:getDebugState()
  lurek.log.info(
    "bt nodes=" .. tostring(debug_state.node_count) .. ", status=" .. behavior_tree:getLastStatus(),
    "ai"
  )
end
--@api-stub: lurek.ai.newSelector
-- Creates a behavior tree selector node with no children.
do
  -- A selector models fallback priority. Child handles are moved into the
  -- parent, so create fresh nodes for each composite branch.
  local selector = lurek.ai.newSelector()
  selector:addChild(lurek.ai.newCondition(function() return false end))
  selector:addChild(lurek.ai.newAction(function() return "success" end))
  local child_count = selector:getChildCount()
  local node_type = selector:getNodeType()
  selector:reset()
  lurek.log.info(node_type .. " children=" .. tostring(child_count), "ai")
end
--@api-stub: lurek.ai.newSequence
-- Creates a behavior tree sequence node with no children.
do
  -- A sequence is useful for ordered requirements: pass every condition, then
  -- run the action. Any failing child stops the sequence.
  local sequence = lurek.ai.newSequence()
  sequence:addChild(lurek.ai.newCondition(function() return true end))
  sequence:addChild(lurek.ai.newAction(function() return "success" end))
  local behavior_tree = lurek.ai.newBehaviorTree()
  behavior_tree:setRoot(sequence)
  local debug_state = behavior_tree:getDebugState()
  lurek.log.info("sequence node count=" .. tostring(debug_state.node_count), "ai")
end
--@api-stub: lurek.ai.newParallel
-- Creates a behavior tree parallel node with optional success and failure policies.
do
  -- Policy strings are camelCase in the engine: requireAll or requireOne.
  -- Unknown policy names fall back to requireOne, so spell them exactly.
  local parallel = lurek.ai.newParallel("requireAll", "requireOne")
  parallel:addChild(lurek.ai.newAction(function() return "success" end))
  parallel:addChild(lurek.ai.newAction(function() return "running" end))
  parallel:setSuccessPolicy("requireAll")
  parallel:setFailurePolicy("requireOne")
  lurek.log.info("parallel children=" .. tostring(parallel:getChildCount()), "ai")
end
--@api-stub: lurek.ai.newInverter
-- Creates a behavior tree inverter decorator with an empty sequence child.
do
  -- Inverter flips success and failure while leaving running unchanged. Use it
  -- to express "not visible" without making a second condition function.
  local inverter = lurek.ai.newInverter()
  inverter:setChild(lurek.ai.newCondition(function() return false end))
  local behavior_tree = lurek.ai.newBehaviorTree()
  behavior_tree:setRoot(inverter)
  lurek.log.info("inverter root status=" .. behavior_tree:getLastStatus(), "ai")
end
--@api-stub: lurek.ai.newRepeater
-- Creates a behavior tree repeater decorator with an optional repeat count.
do
  -- The count is stored on the node. A count of zero is the engine's indefinite
  -- repeat mode; use a positive count for bounded actions.
  local repeater = lurek.ai.newRepeater(3)
  repeater:setChild(lurek.ai.newAction(function() return "success" end))
  repeater:setCount(3)
  local repeat_count = repeater:getCount()
  local behavior_tree = lurek.ai.newBehaviorTree()
  behavior_tree:setRoot(repeater)
  lurek.log.info("repeat count=" .. tostring(repeat_count), "ai")
end
--@api-stub: lurek.ai.newSucceeder
-- Creates a behavior tree succeeder decorator with an empty sequence child.
do
  -- Succeeder is a decorator for optional work. It lets a larger sequence keep
  -- moving even when the child action reports failure.
  local succeeder = lurek.ai.newSucceeder()
  succeeder:setChild(lurek.ai.newAction(function() return "failure" end))
  local behavior_tree = lurek.ai.newBehaviorTree()
  behavior_tree:setRoot(succeeder)
  lurek.log.info("succeeder type=" .. succeeder:getNodeType(), "ai")
end
--@api-stub: lurek.ai.newAction
-- Creates a behavior tree action leaf backed by a Lua callback.
do
  -- Action callbacks return one of the behavior-tree status strings. Unknown
  -- strings are parsed by the engine as running.
  local action = lurek.ai.newAction(function()
    local reached_cover = true
    if reached_cover then
      return "success"
    end
    return "running"
  end)
  lurek.log.info("action node type=" .. action:getNodeType(), "ai")
end
--@api-stub: lurek.ai.newCondition
-- Creates a behavior tree condition leaf backed by a Lua callback.
do
  -- Conditions return a boolean. True becomes success, false becomes failure,
  -- which makes conditions a good fit for cheap gate checks.
  local hit_points = 24
  local hit_points_low = lurek.ai.newCondition(function() return hit_points < 30 end)
  local sequence = lurek.ai.newSequence()
  sequence:addChild(hit_points_low)
  sequence:addChild(lurek.ai.newAction(function() return "success" end))
  lurek.log.info("condition tree children=" .. tostring(sequence:getChildCount()), "ai")
end
--@api-stub: lurek.ai.newSteeringManager
-- Creates an empty steering manager with support for built-in and custom behaviors.
do
  -- Steering combines behaviors into a single force. Weights let a designer
  -- make goal seeking stronger than noise from wander, flee, or flocking.
  local steering = lurek.ai.newSteeringManager()
  steering:addSeek(400, 300, 1.0)
  steering:addWander(20, 40, 5, 0.3)
  steering:setCombineMode("weighted")
  local force_x, force_y = steering:calculate(120, 80, 0, 0, 140, 240, 1 / 60)
  local last_x, last_y = steering:getLastSteering()
  lurek.log.info(
    "steering=" .. tostring(force_x) .. "," .. tostring(force_y) .. " last=" .. tostring(last_x) .. "," .. tostring(last_y),
    "ai"
  )
end
--@api-stub: LSteeringManager:setPath
-- Sets the path of this steering manager.
do
  -- setPath expects an array table of waypoints with numeric x and y fields.
  -- reach_radius controls how close the agent must get before advancing.
  local path = {
    { x = 16, y = 16 },
    { x = 96, y = 32 },
    { x = 160, y = 96 },
  }
  local steering = lurek.ai.newSteeringManager()
  steering:setPath(path, 12.0, 1.0)
  if steering:hasPath() then
    local force_x, force_y = steering:calculate(0, 0, 0, 0, 120, 240, 1 / 60)
    lurek.log.info("path force: " .. tostring(force_x) .. ", " .. tostring(force_y), "ai")
  end
end
--@api-stub: LSteeringManager:getPathProgress
-- Returns the path progress of this steering manager.
do
  -- Progress is reported as one-based current waypoint index and total count.
  -- A UI can display this as a patrol checkpoint meter.
  local steering = lurek.ai.newSteeringManager()
  steering:setPath({ { x = 16, y = 16 }, { x = 48, y = 16 } }, 8, 1)
  local waypoint_index, waypoint_total = steering:getPathProgress()
  lurek.log.info("path progress " .. tostring(waypoint_index) .. "/" .. tostring(waypoint_total), "ai")
  steering:clearPath()
end
--@api-stub: lurek.ai.newQLearner
-- Creates a Q-learner with fixed state and action counts.
do
  -- State and action indexes are one-based in Lua. Store rewards after each
  -- transition, then choose future actions through the exploration policy.
  local learner = lurek.ai.newQLearner(16, 4)
  learner:setLearningRate(0.1)
  learner:setDiscountFactor(0.95)
  learner:setExplorationRate(0.2)
  learner:setExplorationDecay(0.99)
  local chosen_action = learner:chooseAction(1)
  learner:learn(1, chosen_action, 1.0, 2)
  local best_action = learner:bestAction(1)
  local q_value = learner:getQValue(1, best_action)
  learner:endEpisode()
  local saved_state = learner:serialize()
  lurek.log.info("q=" .. tostring(q_value) .. " saved=" .. tostring(#saved_state), "ai")
end
--@api-stub: lurek.ai.newUtilityAI
-- Creates an empty utility AI action scorer.
do
  -- Utility AI compares actions by score. Add considerations when one action
  -- needs multiple inputs, such as danger, hunger, distance, or ammo.
  local utility = lurek.ai.newUtilityAI()
  local danger = 0.8
  local stamina = 0.5
  utility:addAction("flee", function() return danger end, 1.0)
  utility:addAction("attack", function() return 0.4 end, 1.0)
  utility:addConsideration("attack", "stamina", function() return stamina end, "linear", 1, 0, 0, 0.5)
  local selected_action = utility:evaluate() or "none"
  lurek.log.info(
    "utility action=" .. tostring(selected_action) .. ", count=" .. tostring(utility:getActionCount()),
    "ai"
  )
end
--@api-stub: lurek.ai.newDialogueAI
-- Creates an empty dialogue selector for weighted topics and branches.
do
  -- Dialogue topics can be weighted by utility keys and gated by the current
  -- FSM state or behavior-tree status.
  local dialogue = lurek.ai.newDialogueAI()
  local dialogue_type = dialogue:type()
  local is_dialogue = dialogue:typeOf("DialogueAI")
  lurek.log.info("dialogue type: " .. tostring(dialogue_type) .. ", ok=" .. tostring(is_dialogue), "ai")
  dialogue:addTopic("smalltalk", 0.2, nil, nil, "smalltalk_score")
  dialogue:addTopic("combat", 0.2, "combat", "success", "combat_score")
  dialogue:addBranch("combat", "taunt", 0.3, "combat", nil, "taunt_score")
  dialogue:addBranch("combat", "threat", 0.2, "combat", nil, "threat_score")
  dialogue:setFSMState("combat")
  dialogue:setBTStatus("success")
  dialogue:setUtilityScore("smalltalk_score", 0.1)
  dialogue:setUtilityScore("combat_score", 0.9)
  dialogue:setUtilityScore("taunt_score", 0.6)
  dialogue:setUtilityScore("threat_score", 0.4)

  local topic = dialogue:selectTopic()
  if topic then
    local branch = dialogue:selectBranch(topic)
    lurek.log.info("dialogue: " .. tostring(topic) .. "/" .. tostring(branch), "ai")
  end
  local topic_count = dialogue:getTopicCount()
  lurek.log.info("dialogue topics: " .. tostring(topic_count), "ai")
  dialogue:clearUtilityScores()
end
--@api-stub: lurek.ai.newGOAPPlanner
-- Creates an empty GOAP planner for boolean world-state planning.
do
  -- GOAP builds a list of action names from boolean world-state facts. Define
  -- preconditions, effects, and the desired goal state before calling plan.
  local planner = lurek.ai.newGOAPPlanner()
  planner:addAction("find_food", 1.0, function() lurek.log.info("finding food", "ai") end)
  planner:setPrecondition("find_food", "has_food", false)
  planner:setEffect("find_food", "has_food", true)
  planner:addAction("eat", 1.0, function() lurek.log.info("eating", "ai") end)
  planner:setPrecondition("eat", "has_food", true)
  planner:setEffect("eat", "hungry", false)
  planner:addGoal("not_hungry", 1.0)
  planner:setGoalState("not_hungry", "hungry", false)
  planner:setMaxIterations(128)
  local plan = planner:plan({ hungry = true, has_food = false }, 8)
  lurek.log.info("goap steps=" .. tostring(#plan) .. ", actions=" .. tostring(planner:getActionCount()), "ai")
end
--@api-stub: lurek.ai.newInfluenceMap
-- Creates a grid influence map with the supplied cell dimensions and world cell size.
do
  -- Influence maps store named layers over grid cells. Use world coordinates
  -- for radial stamps and one-based cell coordinates for direct cell reads.
  local influence = lurek.ai.newInfluenceMap(64, 64, 16)
  influence:addLayer("threat")
  influence:addLayer("resources")
  influence:stampInfluence("threat", 320, 240, 80, 1.0, 1.0)
  influence:setInfluence("resources", 10, 12, 0.75)
  influence:propagate("threat", 0.4)
  influence:decay("threat", 0.95)
  local threat_value = influence:getInfluence("threat", 20, 15)
  local max_x, max_y = influence:getMaxPosition("resources")
  local samples = influence:queryRect("threat", 256, 192, 128, 128)
  lurek.log.info(
    "influence=" .. tostring(threat_value) .. " max=" .. tostring(max_x) .. "," .. tostring(max_y) .. " query=" .. tostring(samples),
    "ai"
  )
end
--@api-stub: lurek.ai.newSquad
-- Creates an empty named squad.
do
  -- Squads group named agents or game objects for formation logic. Store the
  -- leader by name, then ask each member for its formation target.
  local squad = lurek.ai.newSquad("alpha")
  squad:addMember("guard_01")
  squad:addMember("guard_02")
  squad:setLeader("guard_01")
  squad:setFormation("wedge", 32)
  local target_x, target_y = squad:getFormationPosition(2, 200, 120)
  local members = squad:getMembers()
  local squad_blackboard = squad:getBlackboard()
  squad_blackboard:setString("order", "hold_position")
  lurek.log.info(
    squad:getName() .. " leader=" .. tostring(squad:getLeader()) .. " members=" .. tostring(#members) .. " pos=" .. tostring(target_x) .. "," .. tostring(target_y),
    "ai"
  )
end
--@api-stub: lurek.ai.newCommandQueue
-- Creates an empty command queue for callback-backed AI commands.
do
  -- Queues store command kind, callback, target, priority, and interrupt flag.
  -- Game code can inspect the current target and decide which callback to run.
  local queue = lurek.ai.newCommandQueue()
  queue:enqueue("move", function() lurek.log.info("move command", "ai") end, {
    targetX = 200,
    targetY = 100,
    priority = 1,
    interruptible = true,
  })
  queue:pushFront("dodge", function() lurek.log.info("dodge command", "ai") end, {
    targetX = 160,
    targetY = 90,
    priority = 10,
    interruptible = false,
  })
  local target_x, target_y = queue:getCurrentTarget()
  lurek.log.info("commands=" .. tostring(queue:getCount()) .. " target=" .. tostring(target_x) .. "," .. tostring(target_y), "ai")
  queue:replace("recover", function() end, { priority = 2 })
  queue:clear()
  local empty = queue:isEmpty()
  lurek.log.info("queue empty=" .. tostring(empty), "ai")
end
--@api-stub: lurek.ai.newTraitProfile
-- Creates an empty trait profile with modifier support.
do
  -- Traits are named numeric personality or tuning values. Modifiers let a
  -- temporary event change an effective value without changing the base value.
  local traits = lurek.ai.newTraitProfile()
  traits:set("aggression", 0.7)
  traits:set("courage", 0.4)
  traits:addModifier("aggression", 0.2, 2.0, "combat_shout")
  traits:update(1 / 60)
  local base_aggression = traits:getBase("aggression")
  local effective_aggression = traits:get("aggression")
  local archetype = traits:archetype() or "unclassified"
  lurek.log.info(
    "traits=" .. tostring(traits:traitCount()) .. " base=" .. tostring(base_aggression) .. " effective=" .. tostring(effective_aggression) .. " archetype=" .. archetype,
    "ai"
  )
  traits:removeModifiers("combat_shout")
end
--@api-stub: lurek.ai.newStimulusWorld
-- Creates an empty stimulus world for visual and auditory stimulus records.
do
  -- Stimuli are records that sensory AI can query or mirror into blackboards.
  -- Visual stimuli persist until removed; auditory stimuli decay during update.
  local stimuli = lurek.ai.newStimulusWorld()
  local sight_id = stimuli:addVisual(320, 240, 1.0, 120, "player_seen")
  local sound_id = stimuli:addAuditory(100, 200, 0.8, 150, 0.5, "footstep")
  stimuli:update(1 / 60)
  lurek.log.info("stimuli=" .. tostring(stimuli:count()), "ai")
  stimuli:remove(sight_id)
  stimuli:remove(sound_id)
  stimuli:clear()
end
--@api-stub: lurek.ai.newContextSteering
-- Creates a context steering model with the requested directional slot count.
do
  -- Context steering evaluates directional slots and returns a chosen direction.
  -- Use more slots for smoother direction choice; zero would select the default.
  local steering = lurek.ai.newContextSteering(16)
  steering:addSeekTarget(500, 300, 1.0)
  steering:addAvoidPoint(250, 200, 64, 1.0)
  steering:addAvoidBounds(0, 0, 800, 600, 24, 0.5)
  steering:addWander(0.2, 0.15)
  local dir_x, dir_y = steering:evaluate(220, 180, 0, 0)
  lurek.log.info("context dir=" .. tostring(dir_x) .. "," .. tostring(dir_y) .. " slots=" .. tostring(steering:slotCount()), "ai")
  steering:clearBehaviors()
end
--@api-stub: lurek.ai.newNeedSystem
-- Creates an empty need system for decaying named needs.
do
  -- Needs accumulate urgency through update, then game logic can satisfy the
  -- chosen need after an action completes.
  local needs = lurek.ai.newNeedSystem()
  needs:addNeed("hunger", 0.05, 0.6, 1.5)
  needs:addNeed("rest", 0.02, 0.4, 1.0)
  needs:update(10.0)
  local urgent_need = needs:mostUrgent() or "none"
  local hunger_value = needs:valueOf("hunger")
  needs:satisfy("hunger", 0.25)
  lurek.log.info("need=" .. urgent_need .. " hunger=" .. tostring(hunger_value), "ai")
end
--@api-stub: lurek.ai.newAIDirector
-- Creates an AI director for tension, phase, and pacing factor calculations.
do
  -- The director turns tension into spawn, loot, and ambience factors that a
  -- game can sample while building encounters.
  local director = lurek.ai.newAIDirector()
  director:setTension(0.4)
  director:pushEvent(0.2)
  director:update(1 / 60)
  local phase = director:phase()
  local spawn_factor = director:spawnRateFactor()
  local loot_factor = director:lootFactor()
  local ambience = director:ambientIntensity()
  lurek.log.info("phase=" .. phase .. " spawn=" .. tostring(spawn_factor) .. " loot=" .. tostring(loot_factor) .. " amb=" .. tostring(ambience), "ai")
  director:reset()
end
--@api-stub: lurek.ai.newHTNDomain
-- Creates an empty hierarchical task network domain.
do
  -- HTN domains decompose compound tasks into primitive task names. State facts
  -- are numeric in the Lua binding, so use 1.0 for present facts.
  local domain = lurek.ai.newHTNDomain()
  domain:addPrimitive("approach", { "enemy_visible" }, { "in_range" }, {})
  domain:addPrimitive("attack", { "has_weapon", "in_range" }, { "enemy_defeated" }, {})
  domain:addCompound("defeat_enemy", {
    { name = "armed_attack", preconditions = { "has_weapon" }, sub_tasks = { "approach", "attack" } },
  })
  local plan = domain:plan("defeat_enemy", { enemy_visible = 1.0, has_weapon = 1.0 })
  local plan_count = plan and #plan or 0
  lurek.log.info("htn tasks=" .. tostring(domain:taskCount()) .. " plan=" .. tostring(plan_count), "ai")
end
--@api-stub: lurek.ai.newMCTSEngine
-- Creates a Monte Carlo tree search engine with deterministic configuration.
do
  -- MCTS asks Lua for actions, successor states, and a score. Keep callbacks
  -- deterministic when using a fixed seed so tests and replays are repeatable.
  local mcts = lurek.ai.newMCTSEngine(200, 1.41, 32, 12345)
  local get_actions = function(state) return { 1, 2, 3 } end
  local apply_action = function(state, action) return state + action end
  local evaluate_state = function(state) return state % 7 end
  local selected_action = mcts:search(0, get_actions, apply_action, evaluate_state)
  lurek.log.info("mcts action=" .. tostring(selected_action), "ai")
end
--@api-stub: lurek.ai.newEmotionModel
-- Creates an empty emotion model for named decaying emotion values.
do
  -- Emotions have a resting value, decay rate, and active threshold. Trigger
  -- events raise values; update moves them back toward rest.
  local emotions = lurek.ai.newEmotionModel()
  emotions:add("fear", 0.0, 0.1, 0.2)
  emotions:add("anger", 0.0, 0.05, 0.15)
  emotions:trigger("fear", 0.7)
  emotions:update(1 / 60)
  local dominant = emotions:dominant() or "none"
  local fear_value = emotions:get("fear")
  local fear_active = emotions:isActive("fear")
  lurek.log.info("emotion=" .. dominant .. " fear=" .. tostring(fear_value) .. " active=" .. tostring(fear_active), "ai")
  emotions:reset()
end
--@api-stub: lurek.ai.newORCASolver
-- Creates an ORCA avoidance solver with the supplied prediction horizon.
do
  -- ORCA stores its own crowd agents by zero-based index. Set preferred
  -- velocities, compute, then read safe velocities back into movement code.
  local orca = lurek.ai.newORCASolver(2.0)
  local first_agent = orca:addAgent(100, 100, 16, 80)
  local second_agent = orca:addAgent(140, 100, 16, 80)
  orca:setPreferredVelocity(first_agent, 50, 0)
  orca:setPreferredVelocity(second_agent, -50, 0)
  orca:setPosition(second_agent, 136, 100)
  orca:compute(1 / 60)
  local safe_x, safe_y = orca:getSafeVelocity(first_agent)
  lurek.log.info("orca agents=" .. tostring(orca:agentCount()) .. " safe=" .. tostring(safe_x) .. "," .. tostring(safe_y), "ai")
end
--@api-stub: lurek.ai.newNeuralNet
-- Creates an empty feed-forward neural network.
do
  -- Add layers before running a forward pass. Weights are flat arrays in engine
  -- layer order, which is useful for genetic algorithms or save data.
  local network = lurek.ai.newNeuralNet()
  network:addLayer(4, 8, "relu")
  network:addLayer(8, 2, "softmax")
  local weights = network:getWeights()
  local weights_ok = network:setWeights(weights)
  local output = network:forward({ 0.2, 0.6, 0.1, 1.0 })
  lurek.log.info(
    "net layers=" .. tostring(network:layerCount()) .. " params=" .. tostring(network:paramCount()) .. " ok=" .. tostring(weights_ok) .. " out=" .. tostring(output[1] or 0),
    "ai"
  )
end
--@api-stub: lurek.ai.newGeneticAlgorithm
-- Creates a genetic algorithm population with fixed chromosome length.
do
  -- Genetic algorithms use zero-based chromosome indexes in Lua. Set fitness
  -- values for evaluated candidates before calling evolve.
  local genetic = lurek.ai.newGeneticAlgorithm(12, 6, 42)
  genetic:setFitness(0, 0.7)
  genetic:setFitness(1, 0.4)
  local genes = genetic:getGenes(0)
  local best_before = genetic:bestGenes()
  genetic:evolve()
  lurek.log.info("ga pop=" .. tostring(genetic:popSize()) .. " gen=" .. tostring(genetic:generation()) .. " genes=" .. tostring(#genes) .. " best=" .. tostring(#best_before), "ai")
end
--@api-stub: lurek.ai.newBandit
-- Creates a multi-armed bandit with a named selection strategy.
do
  -- The bandit returns zero-based arm indexes. Use ucb1, thompson, or any
  -- other string for the epsilon-greedy fallback configured by epsilon.
  local bandit = lurek.ai.newBandit(4, "ucb1", 0.1, 99)
  local selected_arm = bandit:select()
  bandit:update(selected_arm, 1.0)
  local best_arm = bandit:bestArm()
  lurek.log.info("bandit arms=" .. tostring(bandit:armCount()) .. " best=" .. tostring(best_arm) .. " pulls=" .. tostring(bandit:totalPulls()), "ai")
end
--@api-stub: lurek.ai.newNeuroevolution
-- Creates a neuroevolution population from a layer specification table.
do
  -- Neuroevolution turns chromosomes into neural nets. Give each chromosome a
  -- fitness score from gameplay, then evolve the next population.
  local layers = { { inputs = 4, outputs = 8, activation = "relu" }, { inputs = 8, outputs = 2, activation = "softmax" } }
  local evolution = lurek.ai.newNeuroevolution(layers, 10, 1)
  evolution:setFitness(0, 0.9)
  local network = evolution:chromosomeToNet(0)
  if network then
    local output = network:forward({ 0.1, 0.2, 0.3, 0.4 })
    lurek.log.info("ne output=" .. tostring(output[1] or 0), "ai")
  end
  evolution:evolve()
  lurek.log.info("ne pop=" .. tostring(evolution:popSize()) .. " gen=" .. tostring(evolution:generation()) .. " best=" .. tostring(evolution:bestFitness()), "ai")
end
--@api-stub: lurek.ai.newStrategyAI
-- Creates a strategy AI that reevaluates goals on a fixed interval.
do
  -- Strategy AI scores named goals with a Lua callback. Use forceEvaluate for
  -- immediate decisions and update for interval-based reevaluation.
  local strategy = lurek.ai.newStrategyAI(2.0)
  strategy:addGoal("expand")
  strategy:addGoal("defend")
  strategy:addTag("early_game")
  local scorer = function(goal)
    if goal == "defend" then return 0.8 end
    return 0.5
  end
  strategy:forceEvaluate(scorer)
  strategy:update(2.0, scorer)
  local active_goal = strategy:activeGoal() or "none"
  lurek.log.info("strategy=" .. active_goal .. " next=" .. tostring(strategy:timeUntilNext()), "ai")
  strategy:removeTag("early_game")
end
--@api-stub: lurek.ai.newAILod
-- Creates a default AI level-of-detail tier selector.
do
  -- AI LOD maps distance from a reference point to a zero-based update tier.
  -- The frame counter lets distant tiers update less often.
  local lod = lurek.ai.newAILod()
  local tier = lod:tierFor(400, 260, 320, 240)
  local tier_name = lod:tierName(tier) or "unknown"
  if lod:shouldUpdate(tier, 60) then
    lurek.log.debug("lod tier " .. tostring(tier) .. " " .. tier_name .. " of " .. tostring(lod:tierCount()), "ai")
  end
end
--@api-stub: LAIWorld:getAgent
-- Returns the agent of this ai world.
do
  -- getAgent returns nil when the name is missing, so guard the result before
  -- calling LAgent methods.
  local world = lurek.ai.newWorld()
  local guard = world:addAgent("guard_01")
  guard:addTag("patrol")
  local found_guard = world:getAgent("guard_01")
  local missing_guard = world:getAgent("guard_99")
  if found_guard then
    found_guard:addTag("alive")
    lurek.log.info("found=" .. found_guard:getName() .. " missing=" .. tostring(missing_guard), "ai")
  end
end
--@api-stub: LAIWorld:removeAgent
-- Removes a agent from this ai world.
do
  -- removeAgent takes an existing LAgent handle. Other handles with the same
  -- name become harmless stale references that return default values.
  local world = lurek.ai.newWorld()
  local temporary_agent = world:addAgent("temp")
  local before_count = world:getAgentCount()
  world:removeAgent(temporary_agent)
  local after_count = world:getAgentCount()
  lurek.log.info("removed agent count " .. tostring(before_count) .. " -> " .. tostring(after_count), "ai")
end
--@api-stub: LAIWorld:getAgentCount
-- Returns the number of agent items in this ai world.
do
  -- Agent count is useful for debug overlays and spawn-budget assertions.
  local world = lurek.ai.newWorld()
  world:addAgent("patrol_a")
  world:addAgent("patrol_b")
  local agent_count = world:getAgentCount()
  lurek.log.info("agents=" .. tostring(agent_count), "ai")
end
--@api-stub: LAIWorld:getGlobalBlackboard
-- Returns a blackboard snapshot containing this AI world's shared facts.
do
  -- Use the global blackboard handle for world-level facts such as alert state,
  -- patrol shift, or last known player region.
  local world = lurek.ai.newWorld()
  local global_blackboard = world:getGlobalBlackboard()
  global_blackboard:setNumber("alarm", 0.0)
  global_blackboard:setString("region", "north_gate")
  local region = global_blackboard:getString("region", "unknown")
  lurek.log.info("global region=" .. region, "ai")
end
--@api-stub: LAIWorld:update
-- Advances this AI world by the given delta time.
do
  -- update also invokes custom model callbacks installed on agents. Use the
  -- callback to mirror decisions into the agent's blackboard.
  local world = lurek.ai.newWorld()
  local scout = world:addAgent("npc")
  scout:setCustomModel(function(agent, blackboard, dt)
    blackboard:setNumber("last_update", dt)
    agent:setVelocity(12, 0)
  end)
  world:update(1 / 60)
  local velocity_x, velocity_y = scout:getVelocity()
  lurek.log.info("world update velocity=" .. tostring(velocity_x) .. "," .. tostring(velocity_y), "ai")
end
--@api-stub: LAIWorld:type
-- Returns the Lua-visible type name string for this AI world handle.
do
  local world = lurek.ai.newWorld()
  local type_name = world:type()
  if type_name == "LAIWorld" then
    lurek.log.debug("got world handle", "ai")
  end
end
--@api-stub: LAIWorld:typeOf
-- Returns true if this AI world handle matches the given type name string.
do
  local world = lurek.ai.newWorld()
  local is_ai_world = world:typeOf("AIWorld")
  local is_object = world:typeOf("Object")
  lurek.log.debug("world typeOf AIWorld=" .. tostring(is_ai_world) .. " Object=" .. tostring(is_object), "ai")
end
--@api-stub: LAgent:getName
-- Returns the name of this agent.
do
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("scout_01")
  local name = agent:getName()
  lurek.log.debug("agent=" .. name, "ai")
end
--@api-stub: LAgent:setPosition
-- Sets the position of this agent.
do
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("scout_01")
  agent:setPosition(320, 240)
  local position_x, position_y = agent:getPosition()
  lurek.log.debug("set pos=" .. tostring(position_x) .. "," .. tostring(position_y), "ai")
end
--@api-stub: LAgent:getPosition
-- Returns the position of this agent.
do
  -- Removed agents return the origin, so getPosition is safe for stale handles
  -- during cleanup or deferred debug drawing.
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("scout_01")
  agent:setPosition(50, 75)
  local position_x, position_y = agent:getPosition()
  lurek.log.debug("pos=" .. tostring(position_x) .. "," .. tostring(position_y), "ai")
end
--@api-stub: LAgent:setVelocity
-- Sets the velocity of this agent.
do
  -- Velocity is stored in world units per second. Pair this with a steering
  -- force or movement integrator in the game update loop.
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("scout_01")
  agent:setVelocity(40, 0)
  local velocity_x = agent:getVelocity()
  lurek.log.debug("velocity x=" .. tostring(velocity_x), "ai")
end
--@api-stub: LAgent:getVelocity
-- Returns the velocity of this agent.
do
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("scout_01")
  agent:setVelocity(40, 30)
  local velocity_x, velocity_y = agent:getVelocity()
  local speed_sq = velocity_x * velocity_x + velocity_y * velocity_y
  if speed_sq > 100 then
    lurek.log.debug("moving", "ai")
  end
end
--@api-stub: LAgent:setMaxSpeed
-- Sets the max speed of this agent.
do
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("scout_01")
  agent:setMaxSpeed(150)
  lurek.log.debug("max speed set=" .. tostring(agent:getMaxSpeed()), "ai")
end
--@api-stub: LAgent:getMaxSpeed
-- Returns the max speed of this agent.
do
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("scout_01")
  local speed_cap = agent:getMaxSpeed()
  agent:setVelocity(speed_cap, 0)
  lurek.log.debug("speed cap=" .. tostring(speed_cap), "ai")
end
--@api-stub: LAgent:setMaxForce
-- Sets the max force of this agent.
do
  -- Max force limits how sharply steering can change velocity.
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("scout_01")
  agent:setMaxForce(300)
  lurek.log.debug("force cap set=" .. tostring(agent:getMaxForce()), "ai")
end
--@api-stub: LAgent:getMaxForce
-- Returns the max force of this agent.
do
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("scout_01")
  local max_force = agent:getMaxForce()
  lurek.log.debug("max force=" .. tostring(max_force), "ai")
end
--@api-stub: LAgent:setPriority
-- Sets the priority of this agent.
do
  -- Priority is a game-side scheduling hint. Higher-priority agents can be
  -- updated first or kept at higher AI LOD by script code.
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("scout_01")
  agent:setPriority(10)
  lurek.log.debug("priority set=" .. tostring(agent:getPriority()), "ai")
end
--@api-stub: LAgent:getPriority
-- Returns the priority of this agent.
do
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("scout_01")
  agent:setPriority(5)
  local priority = agent:getPriority()
  if priority > 0 then
    lurek.log.debug("priority agent=" .. tostring(priority), "ai")
  end
end
--@api-stub: LAgent:setDecisionModel
-- Sets the decision model of this agent.
do
  -- Recognized built-in model names include fsm, bt, and utility. Unknown
  -- names are ignored by the binding.
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("scout_01")
  agent:setDecisionModel("bt")
  lurek.log.debug("decision model=" .. agent:getDecisionModel(), "ai")
end
--@api-stub: LAgent:getDecisionModel
-- Returns the decision model of this agent.
do
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("scout_01")
  local default_model = agent:getDecisionModel()
  agent:setDecisionModel("utility")
  local selected_model = agent:getDecisionModel()
  lurek.log.debug("model " .. default_model .. " -> " .. selected_model, "ai")
end
--@api-stub: LAgent:addTag
-- Adds a tag to this agent.
do
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("scout_01")
  agent:addTag("alive")
  agent:addTag("scout")
  lurek.log.debug("has scout=" .. tostring(agent:hasTag("scout")), "ai")
end
--@api-stub: LAgent:removeTag
-- Removes a tag from this agent.
do
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("scout_01")
  agent:addTag("burning")
  agent:removeTag("burning")
  lurek.log.debug("burning=" .. tostring(agent:hasTag("burning")), "ai")
end
--@api-stub: LAgent:hasTag
-- Returns true if this agent has a tag.
do
  -- Tags are simple string flags for filters such as boss, civilian, flying,
  -- or quest_target.
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("scout_01")
  agent:addTag("boss")
  if agent:hasTag("boss") then
    lurek.log.info("boss alert", "ai")
  end
end
--@api-stub: LAgent:getBlackboard
-- Returns a blackboard snapshot for this agent.
do
  -- The returned handle is initialized from the agent's local blackboard values.
  -- Use it for inspection or local calculations without reaching into Rust state.
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("scout_01")
  local blackboard = agent:getBlackboard()
  blackboard:setNumber("hp", 100)
  local hit_points = blackboard:getNumber("hp", 0)
  lurek.log.debug("agent blackboard hp=" .. tostring(hit_points), "ai")
end
--@api-stub: LAgent:type
-- Returns the Lua-visible type name string for this agent handle.
do
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("scout_01")
  if agent:type() == "LAgent" then
    lurek.log.debug("agent type ok", "ai")
  end
end
--@api-stub: LAgent:typeOf
-- Returns true if this agent handle matches the given type name string.
do
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("scout_01")
  local is_agent = agent:typeOf("Agent")
  local is_object = agent:typeOf("Object")
  lurek.log.debug("agent typeOf Agent=" .. tostring(is_agent) .. " Object=" .. tostring(is_object), "ai")
end
--@api-stub: LAIBlackboard:setNumber
-- Sets the number of this blackboard.
do
  -- Numeric facts work well for health, distance, cooldowns, or threat scores.
  local blackboard = lurek.ai.newBlackboard()
  blackboard:setNumber("hp", 100)
  blackboard:setNumber("alert_level", 0.6)
  local alert_level = blackboard:getNumber("alert_level", 0)
  lurek.log.debug("alert=" .. tostring(alert_level), "ai")
end
--@api-stub: LAIBlackboard:setBool
-- Sets the bool of this blackboard.
do
  -- Boolean facts are good for gates: player_seen, door_open, or has_weapon.
  local blackboard = lurek.ai.newBlackboard()
  blackboard:setBool("player_seen", true)
  blackboard:setBool("door_open", false)
  local player_seen = blackboard:getBool("player_seen", false)
  lurek.log.debug("player_seen=" .. tostring(player_seen), "ai")
end
--@api-stub: LAIBlackboard:setString
-- Sets the string of this blackboard.
do
  -- String facts usually hold stable IDs or named state labels.
  local blackboard = lurek.ai.newBlackboard()
  blackboard:setString("target_id", "player_01")
  blackboard:setString("last_state", "patrol")
  local target_id = blackboard:getString("target_id", "none")
  lurek.log.debug("target=" .. target_id, "ai")
end
--@api-stub: LAIBlackboard:has
-- Returns true if this blackboard has an entry for the key.
do
  local blackboard = lurek.ai.newBlackboard()
  blackboard:setBool("alive", true)
  if blackboard:has("alive") then
    lurek.log.debug("entry exists", "ai")
  end
end
--@api-stub: LAIBlackboard:remove
-- Removes one key from this blackboard.
do
  local blackboard = lurek.ai.newBlackboard()
  blackboard:setNumber("temp", 1)
  blackboard:remove("temp")
  lurek.log.debug("temp exists=" .. tostring(blackboard:has("temp")), "ai")
end
--@api-stub: LAIBlackboard:clear
-- Clears all items from this blackboard.
do
  -- Clear removes all entries, useful when reusing a blackboard for a new role.
  local blackboard = lurek.ai.newBlackboard()
  blackboard:setBool("dirty", true)
  blackboard:setString("target", "player_01")
  blackboard:clear()
  lurek.log.debug("blackboard size=" .. tostring(blackboard:getSize()), "ai")
end
--@api-stub: LAIBlackboard:getKeys
-- Returns the keys of this blackboard.
do
  -- getKeys returns an array-style table of stored key names.
  local blackboard = lurek.ai.newBlackboard()
  blackboard:setNumber("hp", 100)
  blackboard:setBool("alive", true)
  for _, key in ipairs(blackboard:getKeys()) do
    lurek.log.debug("key=" .. key, "ai")
  end
end
--@api-stub: LAIBlackboard:getSize
-- Returns the size of this blackboard.
do
  local blackboard = lurek.ai.newBlackboard()
  blackboard:setNumber("hp", 100)
  blackboard:setString("target", "player_01")
  lurek.log.debug("entries=" .. tostring(blackboard:getSize()), "ai")
end
--@api-stub: LAIBlackboard:type
-- Returns the Lua-visible type name string for this blackboard handle.
do
  local blackboard = lurek.ai.newBlackboard()
  if blackboard:type() == "LAIBlackboard" then
    lurek.log.debug("got blackboard", "ai")
  end
end
--@api-stub: LAIBlackboard:typeOf
-- Returns true if this blackboard handle matches the given type name string.
do
  local blackboard = lurek.ai.newBlackboard()
  local is_blackboard = blackboard:typeOf("Blackboard")
  local is_object = blackboard:typeOf("Object")
  lurek.log.debug("blackboard typeOf Blackboard=" .. tostring(is_blackboard) .. " Object=" .. tostring(is_object), "ai")
end
--@api-stub: LStateMachine:addState
-- Adds a state to this state machine.
do
  -- State tables can carry lifecycle callbacks for systems that drive the FSM.
  -- Add all state names before assigning initial state or transitions.
  local machine = lurek.ai.newStateMachine()
  machine:addState("patrol", { onEnter = function() lurek.log.info("patrol", "ai") end })
  machine:addState("chase", { onUpdate = function(dt) lurek.log.debug("dt=" .. tostring(dt), "ai") end })
  machine:addTransition("patrol", "chase", function() return true end, 1)
end
--@api-stub: LStateMachine:setInitialState
-- Sets the initial state of this state machine.
do
  local machine = lurek.ai.newStateMachine()
  machine:addState("idle", {})
  machine:setInitialState("idle")
  lurek.log.debug("initial=" .. tostring(machine:getCurrentState()), "ai")
end
--@api-stub: LStateMachine:getCurrentState
-- Returns the current state of this state machine.
do
  -- Query the active state to drive animations, sound, or UI indicators.
  local machine = lurek.ai.newStateMachine()
  machine:addState("patrol", {})
  machine:setInitialState("patrol")
  local current_state = machine:getCurrentState()
  if current_state then
    lurek.log.debug("state=" .. current_state, "ai")
  end
end
--@api-stub: LStateMachine:forceState
-- Performs the force state operation on this state machine.
do
  -- forceState switches the stored current state and resets time-in-state.
  local machine = lurek.ai.newStateMachine()
  machine:addState("idle", {})
  machine:addState("stunned", {})
  machine:setInitialState("idle")
  machine:forceState("stunned")
  lurek.log.debug("forced=" .. tostring(machine:getCurrentState()), "ai")
end
--@api-stub: LStateMachine:getTimeInState
-- Returns the time in state of this state machine.
do
  -- Time starts at zero and resets when forceState changes state.
  local machine = lurek.ai.newStateMachine()
  machine:addState("idle", {})
  machine:setInitialState("idle")
  local elapsed = machine:getTimeInState()
  if elapsed > 5.0 then
    machine:forceState("idle")
  end
end
--@api-stub: LStateMachine:type
-- Returns the Lua-visible type name string for this state machine handle.
do
  local machine = lurek.ai.newStateMachine()
  if machine:type() == "LStateMachine" then
    lurek.log.debug("state machine type ok", "ai")
  end
end
--@api-stub: LStateMachine:typeOf
-- Returns true if this state machine handle matches the given type name string.
do
  local machine = lurek.ai.newStateMachine()
  local is_state_machine = machine:typeOf("StateMachine")
  local is_object = machine:typeOf("Object")
  lurek.log.debug("state machine typeOf StateMachine=" .. tostring(is_state_machine) .. " Object=" .. tostring(is_object), "ai")
end
--@api-stub: LBehaviorTree:setRoot
-- Sets the root of this behavior tree.
do
  -- Build the node graph bottom-up, then move the root node into the tree.
  -- The debug state confirms the tree shape after setRoot consumes the node.
  local behavior_tree = lurek.ai.newBehaviorTree()
  local root = lurek.ai.newSelector()
  root:addChild(lurek.ai.newAction(function() return "success" end))
  root:addChild(lurek.ai.newAction(function() return "running" end))
  behavior_tree:setRoot(root)
  local debug_state = behavior_tree:getDebugState()
  lurek.log.debug("bt root nodes=" .. tostring(debug_state.node_count), "ai")
end
--@api-stub: LBehaviorTree:getLastStatus
-- Returns the last status of this behavior tree.
do
  -- Last status is stored on the tree as a string: success, failure, or running.
  -- A newly created tree starts at success until engine-side evaluation changes it.
  local behavior_tree = lurek.ai.newBehaviorTree()
  local root = lurek.ai.newSequence()
  root:addChild(lurek.ai.newAction(function() return "success" end))
  behavior_tree:setRoot(root)
  local status = behavior_tree:getLastStatus()
  lurek.log.debug("bt status=" .. status, "ai")
end
--@api-stub: LBehaviorTree:getDebugState
-- Returns the debug state of this behavior tree.
do
  -- Debug state contains node_count and last_status. This is enough for simple
  -- overlays that show whether a tree was built and what status it last held.
  local behavior_tree = lurek.ai.newBehaviorTree()
  local root = lurek.ai.newSequence()
  root:addChild(lurek.ai.newAction(function() return "success" end))
  root:addChild(lurek.ai.newCondition(function() return true end))
  behavior_tree:setRoot(root)
  local debug_state = behavior_tree:getDebugState()
  lurek.log.debug("nodes=" .. tostring(debug_state.node_count) .. " status=" .. debug_state.last_status, "ai")
end
--@api-stub: LBehaviorTree:type
-- Returns the Lua-visible type name string for this behavior tree handle.
do
  local behavior_tree = lurek.ai.newBehaviorTree()
  if behavior_tree:type() == "LBehaviorTree" then
    lurek.log.debug("behavior tree type ok", "ai")
  end
end
--@api-stub: LBehaviorTree:typeOf
-- Returns true if this behavior tree handle matches the given type name string.
do
  local behavior_tree = lurek.ai.newBehaviorTree()
  local is_behavior_tree = behavior_tree:typeOf("BehaviorTree")
  local is_object = behavior_tree:typeOf("Object")
  lurek.log.debug("bt typeOf BehaviorTree=" .. tostring(is_behavior_tree) .. " Object=" .. tostring(is_object), "ai")
end
--@api-stub: LBTNode:addChild
-- Adds a child to this bt node.
do
  -- addChild is valid for selector, sequence, and parallel nodes only.
  local sequence = lurek.ai.newSequence()
  sequence:addChild(lurek.ai.newCondition(function() return true end))
  sequence:addChild(lurek.ai.newAction(function() return "success" end))
  lurek.log.debug("sequence children=" .. tostring(sequence:getChildCount()), "ai")
end
--@api-stub: LBTNode:getChildCount
-- Returns the number of child items in this bt node.
do
  local selector = lurek.ai.newSelector()
  selector:addChild(lurek.ai.newAction(function() return "failure" end))
  selector:addChild(lurek.ai.newAction(function() return "success" end))
  lurek.log.debug("selector children=" .. tostring(selector:getChildCount()), "ai")
end
--@api-stub: LBTNode:reset
-- Resets this bt node to its default state.
do
  -- Clears running state and iteration counters for this node and its subtree.
  local repeater = lurek.ai.newRepeater(3)
  repeater:setChild(lurek.ai.newAction(function() return "success" end))
  repeater:reset()
  lurek.log.debug("reset repeater count=" .. tostring(repeater:getCount()), "ai")
end
--@api-stub: LBTNode:setChild
-- Sets the child of this bt node.
do
  -- setChild is for decorators such as inverter, repeater, and succeeder.
  local inverter = lurek.ai.newInverter()
  inverter:setChild(lurek.ai.newCondition(function() return false end))
  local behavior_tree = lurek.ai.newBehaviorTree()
  behavior_tree:setRoot(inverter)
end
--@api-stub: LBTNode:setCount
-- Sets the count of this bt node.
do
  local repeater = lurek.ai.newRepeater(0)
  repeater:setCount(5)
  repeater:setChild(lurek.ai.newAction(function() return "success" end))
  lurek.log.debug("repeat target=" .. tostring(repeater:getCount()), "ai")
end
--@api-stub: LBTNode:getCount
-- Returns the total count of items held by this bt node.
do
  local repeater = lurek.ai.newRepeater(7)
  if repeater:getCount() == 7 then
    lurek.log.debug("count ok", "ai")
  end
end
--@api-stub: LBTNode:setSuccessPolicy
-- Sets the success policy of this bt node.
do
  -- Parallel policy names are requireOne and requireAll.
  local parallel = lurek.ai.newParallel("requireOne", "requireOne")
  parallel:setSuccessPolicy("requireAll")
  parallel:addChild(lurek.ai.newAction(function() return "success" end))
  parallel:addChild(lurek.ai.newAction(function() return "running" end))
end
--@api-stub: LBTNode:setFailurePolicy
-- Sets the failure policy of this bt node.
do
  -- Failure policy uses the same requireOne or requireAll strings.
  local parallel = lurek.ai.newParallel("requireOne", "requireOne")
  parallel:setFailurePolicy("requireAll")
  parallel:addChild(lurek.ai.newAction(function() return "running" end))
end
--@api-stub: LBTNode:getNodeType
-- Returns the node type of this bt node.
do
  local sequence = lurek.ai.newSequence()
  if sequence:getNodeType() == "sequence" then
    lurek.log.debug("sequence node ok", "ai")
  end
end
--@api-stub: LBTNode:type
-- Returns the Lua-visible type name string for this bt node handle.
do
  local sequence = lurek.ai.newSequence()
  if sequence:type() == "LBTNode" then
    lurek.log.debug("bt node type ok", "ai")
  end
end
--@api-stub: LBTNode:typeOf
-- Returns true if this bt node handle matches the given type name string.
do
  local selector = lurek.ai.newSelector()
  local is_node = selector:typeOf("BTNode")
  local is_object = selector:typeOf("Object")
  lurek.log.debug("node typeOf BTNode=" .. tostring(is_node) .. " Object=" .. tostring(is_object), "ai")
end
--@api-stub: LSteeringManager:getBehaviorCount
-- Returns the number of behavior items in this steering manager.
do
  local steering = lurek.ai.newSteeringManager()
  steering:addSeek(400, 300, 1.0)
  steering:addWander(20, 40, 5, 0.3)
  lurek.log.debug("behaviors=" .. tostring(steering:getBehaviorCount()), "ai")
end
--@api-stub: LSteeringManager:setCombineMode
-- Sets the combine mode of this steering manager.
do
  -- Combine modes are weighted and priority. Unknown strings fall back to weighted.
  local steering = lurek.ai.newSteeringManager()
  steering:addSeek(400, 300, 1.0)
  steering:setCombineMode("priority")
  lurek.log.debug("combine=" .. steering:getCombineMode(), "ai")
end
--@api-stub: LSteeringManager:getCombineMode
-- Returns the combine mode of this steering manager.
do
  local steering = lurek.ai.newSteeringManager()
  steering:addSeek(400, 300, 1.0)
  if steering:getCombineMode() == "weighted" then
    lurek.log.debug("weighted blend mode", "ai")
  end
end
--@api-stub: LSteeringManager:getLastSteering
-- Returns the last steering of this steering manager.
do
  -- Last steering is the force vector from the most recent calculate call.
  local steering = lurek.ai.newSteeringManager()
  steering:addSeek(400, 300, 1.0)
  steering:calculate(100, 80, 0, 0, 120, 200, 1 / 60)
  local force_x, force_y = steering:getLastSteering()
  if force_x ~= 0 or force_y ~= 0 then
    lurek.log.debug("steering active", "ai")
  end
end
--@api-stub: LSteeringManager:type
-- Returns the Lua-visible type name string for this steering manager handle.
do
  local steering = lurek.ai.newSteeringManager()
  steering:addSeek(400, 300, 1.0)
  if steering:type() == "LSteeringManager" then
    lurek.log.debug("steering type ok", "ai")
  end
end
--@api-stub: LSteeringManager:typeOf
-- Returns true if this steering manager handle matches the given type name string.
do
  local steering = lurek.ai.newSteeringManager()
  steering:addSeek(400, 300, 1.0)
  local is_steering = steering:typeOf("SteeringManager")
  local is_object = steering:typeOf("Object")
  lurek.log.debug("steering typeOf SteeringManager=" .. tostring(is_steering) .. " Object=" .. tostring(is_object), "ai")
end
--@api-stub: LSteeringManager:setSpatialHashCellSize
-- Sets the spatial hash cell size of this steering manager.
do
  -- Cell size is measured in world units and is used by neighbor queries.
  local steering = lurek.ai.newSteeringManager()
  steering:addFlock(96, 1.5, 1.0, 1.0, 0.8)
  steering:enableSpatialHash(true)
  steering:setSpatialHashCellSize(64)
end
--@api-stub: LSteeringManager:enableSpatialHash
-- Performs the enable spatial hash operation on this steering manager.
do
  -- Spatial hashing can speed neighbor-heavy behaviors such as flocking.
  local steering = lurek.ai.newSteeringManager()
  steering:addFlock(96, 1.5, 1.0, 1.0, 0.8)
  steering:enableSpatialHash(true)
  local force_x, force_y = steering:calculate(100, 80, 0, 0, 140, 240, 1 / 60)
  lurek.log.debug("hash steering=" .. tostring(force_x) .. "," .. tostring(force_y), "ai")
end
--@api-stub: LQLearner:chooseAction
-- Performs the choose action operation on this q learner.
do
  -- chooseAction uses one-based state indexes and the learner's exploration rate.
  local learner = lurek.ai.newQLearner(8, 4)
  learner:setExplorationRate(0.1)
  local action = learner:chooseAction(1)
  lurek.log.debug("chosen action=" .. tostring(action), "ai")
end
--@api-stub: LQLearner:bestAction
-- Performs the best action operation on this q learner.
do
  -- bestAction ignores exploration and returns the highest known action.
  local learner = lurek.ai.newQLearner(8, 4)
  learner:setQValue(1, 3, 2.5)
  local action = learner:bestAction(1)
  if action >= 1 then
    lurek.log.debug("greedy=" .. tostring(action), "ai")
  end
end
--@api-stub: LQLearner:getQValue
-- Returns the q value of this q learner.
do
  -- Q(state, action) estimates expected future reward for one transition choice.
  local learner = lurek.ai.newQLearner(8, 4)
  learner:learn(1, 2, 1.0, 3)
  local q_value = learner:getQValue(1, 2)
  lurek.log.debug("Q(1,2)=" .. tostring(q_value), "ai")
end
--@api-stub: LQLearner:endEpisode
-- Performs the end episode operation on this q learner.
do
  -- End an episode after a terminal state, reward reset, or training rollout.
  local learner = lurek.ai.newQLearner(8, 4)
  learner:learn(1, 1, 0.5, 2)
  learner:endEpisode()
  lurek.log.debug("episodes=" .. tostring(learner:getEpisodeCount()), "ai")
end
--@api-stub: LQLearner:getEpisodeCount
-- Returns the number of episode items in this q learner.
do
  local learner = lurek.ai.newQLearner(8, 4)
  learner:endEpisode()
  learner:endEpisode()
  lurek.log.debug("episodes=" .. tostring(learner:getEpisodeCount()), "ai")
end
--@api-stub: LQLearner:getStateCount
-- Returns the number of state items in this q learner.
do
  local learner = lurek.ai.newQLearner(8, 4)
  lurek.log.debug("states=" .. tostring(learner:getStateCount()), "ai")
end
--@api-stub: LQLearner:getActionCount
-- Returns the number of action items in this q learner.
do
  local learner = lurek.ai.newQLearner(8, 4)
  for action_index = 1, learner:getActionCount() do
    lurek.log.debug("action slot=" .. tostring(action_index), "ai")
  end
end
--@api-stub: LQLearner:setLearningRate
-- Sets the learning rate of this q learner.
do
  local learner = lurek.ai.newQLearner(8, 4)
  learner:setLearningRate(0.05)
  lurek.log.debug("alpha set=" .. tostring(learner:getLearningRate()), "ai")
end
--@api-stub: LQLearner:getLearningRate
-- Returns the learning rate of this q learner.
do
  local learner = lurek.ai.newQLearner(8, 4)
  lurek.log.debug("alpha=" .. tostring(learner:getLearningRate()), "ai")
end
--@api-stub: LQLearner:setDiscountFactor
-- Sets the discount factor of this q learner.
do
  local learner = lurek.ai.newQLearner(8, 4)
  learner:setDiscountFactor(0.95)
  lurek.log.debug("gamma set=" .. tostring(learner:getDiscountFactor()), "ai")
end
--@api-stub: LQLearner:getDiscountFactor
-- Returns the discount factor of this q learner.
do
  local learner = lurek.ai.newQLearner(8, 4)
  lurek.log.debug("gamma=" .. tostring(learner:getDiscountFactor()), "ai")
end
--@api-stub: LQLearner:setExplorationRate
-- Sets the exploration rate of this q learner.
do
  local learner = lurek.ai.newQLearner(8, 4)
  learner:setExplorationRate(0.1)
  lurek.log.debug("epsilon set=" .. tostring(learner:getExplorationRate()), "ai")
end
--@api-stub: LQLearner:getExplorationRate
-- Returns the exploration rate of this q learner.
do
  local learner = lurek.ai.newQLearner(8, 4)
  learner:setExplorationRate(0.02)
  if learner:getExplorationRate() < 0.05 then
    lurek.log.info("exploit phase", "ai")
  end
end
--@api-stub: LQLearner:setExplorationDecay
-- Sets the exploration decay of this q learner.
do
  local learner = lurek.ai.newQLearner(8, 4)
  learner:setExplorationDecay(0.995)
  lurek.log.debug("decay set=" .. tostring(learner:getExplorationDecay()), "ai")
end
--@api-stub: LQLearner:getExplorationDecay
-- Returns the exploration decay of this q learner.
do
  local learner = lurek.ai.newQLearner(8, 4)
  lurek.log.debug("decay=" .. tostring(learner:getExplorationDecay()), "ai")
end
--@api-stub: LQLearner:serialize
-- Performs the serialize operation on this q learner.
do
  local learner = lurek.ai.newQLearner(8, 4)
  learner:learn(1, 1, 1.0, 2)
  local json = learner:serialize()
  lurek.log.info("saved " .. tostring(#json) .. " bytes", "ai")
end
--@api-stub: LQLearner:deserialize
-- Performs the deserialize operation on this q learner.
do
  -- Deserialize is useful when restoring trained Q-values from save data.
  local learner = lurek.ai.newQLearner(8, 4)
  learner:learn(1, 1, 1.0, 2)
  local saved = learner:serialize()
  local restored = lurek.ai.newQLearner(8, 4)
  restored:deserialize(saved)
  lurek.log.debug("restored q=" .. tostring(restored:getQValue(1, 1)), "ai")
end
--@api-stub: LQLearner:type
-- Returns the Lua-visible type name string for this q learner handle.
do
  local learner = lurek.ai.newQLearner(8, 4)
  if learner:type() == "LQLearner" then
    lurek.log.debug("q learner type ok", "ai")
  end
end
--@api-stub: LQLearner:typeOf
-- Returns true if this q learner handle matches the given type name string.
do
  local learner = lurek.ai.newQLearner(8, 4)
  local is_learner = learner:typeOf("QLearner")
  local is_object = learner:typeOf("Object")
  lurek.log.debug("q typeOf QLearner=" .. tostring(is_learner) .. " Object=" .. tostring(is_object), "ai")
end
--@api-stub: LUtilityAI:evaluate
-- Performs the evaluate operation on this utility ai.
do
  -- Scores all registered actions and returns the highest-scoring action name.
  local utility = lurek.ai.newUtilityAI()
  utility:addAction("flee", function() return 0.8 end, 1.0)
  utility:addAction("attack", function() return 0.4 end, 1.0)
  local choice = utility:evaluate()
  if choice then
    lurek.log.info("chose " .. choice, "ai")
  end
end
--@api-stub: LUtilityAI:getActionCount
-- Returns the number of action items in this utility ai.
do
  local utility = lurek.ai.newUtilityAI()
  utility:addAction("flee", function() return 0.8 end, 1.0)
  utility:addAction("attack", function() return 0.4 end, 1.0)
  lurek.log.debug("utility actions=" .. tostring(utility:getActionCount()), "ai")
end
--@api-stub: LUtilityAI:getLastAction
-- Returns the last action of this utility ai.
do
  local utility = lurek.ai.newUtilityAI()
  utility:addAction("flee", function() return 0.8 end, 1.0)
  utility:addAction("attack", function() return 0.4 end, 1.0)
  utility:evaluate()
  local last_action = utility:getLastAction()
  if last_action then
    lurek.log.debug("last=" .. last_action, "ai")
  end
end
--@api-stub: LUtilityAI:type
-- Returns the Lua-visible type name string for this utility ai handle.
do
  local utility = lurek.ai.newUtilityAI()
  if utility:type() == "LUtilityAI" then
    lurek.log.debug("utility type ok", "ai")
  end
end
--@api-stub: LUtilityAI:typeOf
-- Returns true if this utility ai handle matches the given type name string.
do
  local utility = lurek.ai.newUtilityAI()
  local is_utility = utility:typeOf("UtilityAI")
  local is_object = utility:typeOf("Object")
  lurek.log.debug("utility typeOf UtilityAI=" .. tostring(is_utility) .. " Object=" .. tostring(is_object), "ai")
end
--@api-stub: LGOAPPlanner:getActionCount
-- Returns the number of action items in this goap planner.
do
  local planner = lurek.ai.newGOAPPlanner()
  planner:addAction("eat", 1.0, function() end)
  planner:addGoal("not_hungry", 1.0)
  lurek.log.debug("goap actions=" .. tostring(planner:getActionCount()), "ai")
end
--@api-stub: LGOAPPlanner:getGoalCount
-- Returns the number of goal items in this goap planner.
do
  local planner = lurek.ai.newGOAPPlanner()
  planner:addAction("eat", 1.0, function() end)
  planner:addGoal("not_hungry", 1.0)
  lurek.log.debug("goap goals=" .. tostring(planner:getGoalCount()), "ai")
end
--@api-stub: LGOAPPlanner:getMaxIterations
-- Returns the max iterations of this goap planner.
do
  local planner = lurek.ai.newGOAPPlanner()
  lurek.log.debug("max iters=" .. tostring(planner:getMaxIterations()), "ai")
end
--@api-stub: LGOAPPlanner:setMaxIterations
-- Sets the max iterations of this goap planner.
do
  local planner = lurek.ai.newGOAPPlanner()
  planner:setMaxIterations(500)
  lurek.log.debug("max iters set=" .. tostring(planner:getMaxIterations()), "ai")
end
--@api-stub: LGOAPPlanner:type
-- Returns the Lua-visible type name string for this goap planner handle.
do
  local planner = lurek.ai.newGOAPPlanner()
  if planner:type() == "LGOAPPlanner" then
    lurek.log.debug("goap type ok", "ai")
  end
end
--@api-stub: LGOAPPlanner:typeOf
-- Returns true if this goap planner handle matches the given type name string.
do
  local planner = lurek.ai.newGOAPPlanner()
  local is_goap = planner:typeOf("GOAPPlanner")
  local is_object = planner:typeOf("Object")
  lurek.log.debug("goap typeOf GOAPPlanner=" .. tostring(is_goap) .. " Object=" .. tostring(is_object), "ai")
end
--@api-stub: LInfluenceMap:hasLayer
-- Returns true if this influence map has a layer.
do
  local influence = lurek.ai.newInfluenceMap(32, 32, 16)
  influence:addLayer("threat")
  if influence:hasLayer("threat") then
    lurek.log.debug("layer ok", "ai")
  end
end
--@api-stub: LInfluenceMap:decay
-- Performs the decay operation on this influence map.
do
  -- Multiplies every cell by the decay factor, fading old influence over time.
  local influence = lurek.ai.newInfluenceMap(32, 32, 16)
  influence:addLayer("threat")
  influence:stampInfluence("threat", 100, 100, 64, 1.0, 1.0)
  influence:decay("threat", 0.97)
  lurek.log.debug("decayed threat=" .. tostring(influence:getInfluence("threat", 7, 7)), "ai")
end
--@api-stub: LInfluenceMap:clearLayer
-- Clears all layer items from this influence map.
do
  local influence = lurek.ai.newInfluenceMap(32, 32, 16)
  influence:addLayer("threat")
  influence:stampInfluence("threat", 100, 100, 64, 1.0, 1.0)
  influence:clearLayer("threat")
  lurek.log.debug("cleared threat=" .. tostring(influence:getInfluence("threat", 7, 7)), "ai")
end
--@api-stub: LInfluenceMap:clearAll
-- Clears all all items from this influence map.
do
  local influence = lurek.ai.newInfluenceMap(32, 32, 16)
  influence:addLayer("threat")
  influence:addLayer("resources")
  influence:setInfluence("resources", 5, 5, 1.0)
  influence:clearAll()
  lurek.log.debug("all cleared=" .. tostring(influence:getInfluence("resources", 5, 5)), "ai")
end
--@api-stub: LInfluenceMap:getMaxPosition
-- Returns the max position of this influence map.
do
  -- Returns one-based cell coordinates of the highest-value cell on a layer.
  local influence = lurek.ai.newInfluenceMap(32, 32, 16)
  influence:addLayer("threat")
  influence:setInfluence("threat", 12, 8, 1.0)
  local max_x, max_y = influence:getMaxPosition("threat")
  lurek.log.debug("hot=" .. tostring(max_x) .. "," .. tostring(max_y), "ai")
end
--@api-stub: LInfluenceMap:getMinPosition
-- Returns the min position of this influence map.
do
  local influence = lurek.ai.newInfluenceMap(32, 32, 16)
  influence:addLayer("threat")
  influence:setInfluence("threat", 4, 3, -1.0)
  local min_x, min_y = influence:getMinPosition("threat")
  lurek.log.debug("safe=" .. tostring(min_x) .. "," .. tostring(min_y), "ai")
end
--@api-stub: LInfluenceMap:getWidth
-- Returns the width of this influence map.
do
  local influence = lurek.ai.newInfluenceMap(32, 32, 16)
  influence:addLayer("threat")
  lurek.log.debug("width=" .. tostring(influence:getWidth()), "ai")
end
--@api-stub: LInfluenceMap:getHeight
-- Returns the height of this influence map.
do
  local influence = lurek.ai.newInfluenceMap(32, 32, 16)
  influence:addLayer("threat")
  lurek.log.debug("height=" .. tostring(influence:getHeight()), "ai")
end
--@api-stub: LInfluenceMap:getCellSize
-- Returns the cell size of this influence map.
do
  -- Cell size converts between world units and one-based grid cells.
  local influence = lurek.ai.newInfluenceMap(32, 32, 16)
  influence:addLayer("threat")
  lurek.log.debug("cell=" .. tostring(influence:getCellSize()), "ai")
end
--@api-stub: LInfluenceMap:type
-- Returns the Lua-visible type name string for this influence map handle.
do
  local influence = lurek.ai.newInfluenceMap(32, 32, 16)
  influence:addLayer("threat")
  if influence:type() == "LInfluenceMap" then
    lurek.log.debug("influence type ok", "ai")
  end
end
--@api-stub: LInfluenceMap:typeOf
-- Returns true if this influence map handle matches the given type name string.
do
  local influence = lurek.ai.newInfluenceMap(32, 32, 16)
  influence:addLayer("threat")
  local is_influence = influence:typeOf("InfluenceMap")
  local is_object = influence:typeOf("Object")
  lurek.log.debug("influence typeOf InfluenceMap=" .. tostring(is_influence) .. " Object=" .. tostring(is_object), "ai")
end
--@api-stub: LSquad:getName
-- Returns the name of this squad.
do
  local squad = lurek.ai.newSquad("alpha")
  squad:addMember("guard_01")
  lurek.log.debug("squad=" .. squad:getName(), "ai")
end
--@api-stub: LSquad:addMember
-- Adds a member to this squad.
do
  local squad = lurek.ai.newSquad("alpha")
  squad:addMember("guard_01")
  squad:addMember("guard_02")
  squad:addMember("scout_03")
  lurek.log.debug("members=" .. tostring(squad:getMemberCount()), "ai")
end
--@api-stub: LSquad:removeMember
-- Removes a member from this squad.
do
  local squad = lurek.ai.newSquad("alpha")
  squad:addMember("guard_01")
  squad:addMember("temporary")
  squad:removeMember("temporary")
  lurek.log.debug("remaining=" .. tostring(squad:getMemberCount()), "ai")
end
--@api-stub: LSquad:getMemberCount
-- Returns the number of member items in this squad.
do
  local squad = lurek.ai.newSquad("alpha")
  squad:addMember("guard_01")
  squad:addMember("guard_02")
  lurek.log.debug("member count=" .. tostring(squad:getMemberCount()), "ai")
end
--@api-stub: LSquad:getMembers
-- Returns the members of this squad.
do
  local squad = lurek.ai.newSquad("alpha")
  squad:addMember("guard_01")
  squad:addMember("guard_02")
  for _, member_name in ipairs(squad:getMembers()) do
    lurek.log.debug("member=" .. member_name, "ai")
  end
end
--@api-stub: LSquad:setLeader
-- Sets the leader of this squad.
do
  local squad = lurek.ai.newSquad("alpha")
  squad:addMember("guard_01")
  squad:setLeader("guard_01")
  lurek.log.debug("leader set=" .. tostring(squad:getLeader()), "ai")
end
--@api-stub: LSquad:getLeader
-- Returns the leader of this squad.
do
  local squad = lurek.ai.newSquad("alpha")
  squad:addMember("guard_01")
  squad:setLeader("guard_01")
  local leader = squad:getLeader()
  if leader then
    lurek.log.debug("leader=" .. leader, "ai")
  end
end
--@api-stub: LSquad:getFormation
-- Returns the formation of this squad.
do
  local squad = lurek.ai.newSquad("alpha")
  squad:addMember("guard_01")
  squad:setFormation("wedge", 32)
  if squad:getFormation() == "wedge" then
    lurek.log.debug("wedge formation", "ai")
  end
end
--@api-stub: LSquad:getFormationSpacing
-- Returns the formation spacing of this squad.
do
  local squad = lurek.ai.newSquad("alpha")
  squad:addMember("guard_01")
  squad:setFormation("line", 48)
  lurek.log.debug("spacing=" .. tostring(squad:getFormationSpacing()), "ai")
end
--@api-stub: LSquad:getBlackboard
-- Returns the blackboard of this squad.
do
  -- Like other AI blackboard accessors, this returns a handle initialized from
  -- the squad's current shared facts.
  local squad = lurek.ai.newSquad("alpha")
  squad:addMember("guard_01")
  local blackboard = squad:getBlackboard()
  blackboard:setString("objective", "capture_point_a")
  lurek.log.debug("objective=" .. blackboard:getString("objective", "none"), "ai")
end
--@api-stub: LSquad:type
-- Returns the Lua-visible type name string for this squad handle.
do
  local squad = lurek.ai.newSquad("alpha")
  squad:addMember("guard_01")
  if squad:type() == "LSquad" then
    lurek.log.debug("squad type ok", "ai")
  end
end
--@api-stub: LSquad:typeOf
-- Returns true if this squad handle matches the given type name string.
do
  local squad = lurek.ai.newSquad("alpha")
  squad:addMember("guard_01")
  local is_squad = squad:typeOf("Squad")
  local is_object = squad:typeOf("Object")
  lurek.log.debug("squad typeOf Squad=" .. tostring(is_squad) .. " Object=" .. tostring(is_object), "ai")
end
--@api-stub: LCommandQueue:cancelCurrent
-- Performs the cancel current operation on this command queue.
do
  local queue = lurek.ai.newCommandQueue()
  queue:enqueue("move", function() end, { targetX = 200, targetY = 100 })
  local cancelled = queue:cancelCurrent()
  lurek.log.debug("cancelled=" .. tostring(cancelled), "ai")
end
--@api-stub: LCommandQueue:clear
-- Clears all items from this command queue.
do
  local queue = lurek.ai.newCommandQueue()
  queue:enqueue("move", function() end, { targetX = 200, targetY = 100 })
  queue:enqueue("attack", function() end)
  queue:clear()
  lurek.log.debug("queue empty=" .. tostring(queue:isEmpty()), "ai")
end
--@api-stub: LCommandQueue:getCount
-- Returns the total count of items held by this command queue.
do
  local queue = lurek.ai.newCommandQueue()
  queue:enqueue("move", function() end, { targetX = 200, targetY = 100 })
  queue:enqueue("attack", function() end, { priority = 5 })
  lurek.log.debug("queue=" .. tostring(queue:getCount()), "ai")
end
--@api-stub: LCommandQueue:isEmpty
-- Returns true if this command queue contains no items.
do
  local queue = lurek.ai.newCommandQueue()
  queue:enqueue("move", function() end, { targetX = 200, targetY = 100 })
  queue:clear()
  if queue:isEmpty() then
    lurek.log.debug("command queue idle", "ai")
  end
end
--@api-stub: LCommandQueue:getCurrentType
-- Returns the current type of this command queue.
do
  local queue = lurek.ai.newCommandQueue()
  queue:enqueue("move", function() end, { targetX = 200, targetY = 100 })
  local kind = queue:getCurrentType() or "none"
  lurek.log.debug("current command=" .. kind, "ai")
end
--@api-stub: LCommandQueue:getCurrentTarget
-- Returns the current target of this command queue.
do
  local queue = lurek.ai.newCommandQueue()
  queue:enqueue("move", function() end, { targetX = 200, targetY = 100 })
  local target_x, target_y = queue:getCurrentTarget()
  lurek.log.debug("target=" .. tostring(target_x) .. "," .. tostring(target_y), "ai")
end
--@api-stub: LCommandQueue:type
-- Returns the Lua-visible type name string for this command queue handle.
do
  local queue = lurek.ai.newCommandQueue()
  queue:enqueue("move", function() end, { targetX = 200, targetY = 100 })
  if queue:type() == "LCommandQueue" then
    lurek.log.debug("command queue type ok", "ai")
  end
end
--@api-stub: LCommandQueue:typeOf
-- Returns true if this command queue handle matches the given type name string.
do
  local queue = lurek.ai.newCommandQueue()
  queue:enqueue("move", function() end, { targetX = 200, targetY = 100 })
  local is_queue = queue:typeOf("CommandQueue")
  local is_object = queue:typeOf("Object")
  lurek.log.debug("queue typeOf CommandQueue=" .. tostring(is_queue) .. " Object=" .. tostring(is_object), "ai")
end
--@api-stub: LTraitProfile:set
-- Sets the  of this trait profile.
do
  -- Trait names are free-form strings, and values are numeric tuning inputs.
  local traits = lurek.ai.newTraitProfile()
  traits:set("aggression", 0.7)
  traits:set("courage", 0.5)
  lurek.log.debug("traits=" .. tostring(traits:traitCount()), "ai")
end
--@api-stub: LTraitProfile:get
-- Returns the  of this trait profile.
do
  local traits = lurek.ai.newTraitProfile()
  traits:set("aggression", 0.7)
  traits:addModifier("aggression", 0.2, 5.0, "alert")
  local aggression = traits:get("aggression")
  if aggression > 0.6 then
    lurek.log.debug("aggressive", "ai")
  end
end
--@api-stub: LTraitProfile:getBase
-- Returns the base of this trait profile.
do
  local traits = lurek.ai.newTraitProfile()
  traits:set("aggression", 0.7)
  traits:addModifier("aggression", 0.2, 5.0, "alert")
  local base = traits:getBase("aggression")
  lurek.log.debug("base=" .. tostring(base), "ai")
end
--@api-stub: LTraitProfile:removeModifiers
-- Removes a modifiers from this trait profile.
do
  local traits = lurek.ai.newTraitProfile()
  traits:set("aggression", 0.7)
  traits:addModifier("aggression", 0.2, 10.0, "rage_potion")
  traits:removeModifiers("rage_potion")
  lurek.log.debug("aggression=" .. tostring(traits:get("aggression")), "ai")
end
--@api-stub: LTraitProfile:update
-- Advances this trait profile by the given delta time.
do
  -- update advances temporary modifier timers and expires finished modifiers.
  local traits = lurek.ai.newTraitProfile()
  traits:set("aggression", 0.7)
  traits:addModifier("aggression", 0.2, 0.5, "buff")
  traits:update(1.0)
  lurek.log.debug("after update=" .. tostring(traits:get("aggression")), "ai")
end
--@api-stub: LTraitProfile:has
-- Returns true if this trait profile has a .
do
  local traits = lurek.ai.newTraitProfile()
  traits:set("aggression", 0.7)
  if traits:has("aggression") then
    lurek.log.debug("trait set", "ai")
  end
end
--@api-stub: LTraitProfile:traitCount
-- Performs the trait count operation on this trait profile.
do
  local traits = lurek.ai.newTraitProfile()
  traits:set("aggression", 0.7)
  traits:set("courage", 0.5)
  lurek.log.debug("traits=" .. tostring(traits:traitCount()), "ai")
end
--@api-stub: LTraitProfile:archetype
-- Performs the archetype operation on this trait profile.
do
  local traits = lurek.ai.newTraitProfile()
  traits:set("aggression", 0.7)
  traits:set("courage", 0.5)
  local archetype = traits:archetype() or "none"
  lurek.log.info("archetype=" .. archetype, "ai")
end
--@api-stub: LStimulusWorld:remove
-- Removes a  from this stimulus world.
do
  local stimuli = lurek.ai.newStimulusWorld()
  local stimulus_id = stimuli:addAuditory(100, 200, 1.0, 150, 0.5, "footstep")
  if stimuli:remove(stimulus_id) then
    lurek.log.debug("removed " .. tostring(stimulus_id), "ai")
  end
end
--@api-stub: LStimulusWorld:update
-- Advances this stimulus world by the given delta time.
do
  local stimuli = lurek.ai.newStimulusWorld()
  stimuli:addAuditory(100, 200, 1.0, 150, 0.5, "footstep")
  stimuli:update(1 / 60)
  lurek.log.debug("stimuli=" .. tostring(stimuli:count()), "ai")
end
--@api-stub: LStimulusWorld:clear
-- Clears all items from this stimulus world.
do
  local stimuli = lurek.ai.newStimulusWorld()
  stimuli:addAuditory(100, 200, 1.0, 150, 0.5, "footstep")
  stimuli:addVisual(120, 210, 0.6, 80, "spark")
  stimuli:clear()
  lurek.log.debug("stimuli cleared=" .. tostring(stimuli:count()), "ai")
end
--@api-stub: LContextSteering:addWander
-- Adds a wander to this context steering.
do
  local steering = lurek.ai.newContextSteering(16)
  steering:addSeekTarget(500, 300, 1.0)
  steering:addWander(0.5, 0.3)
  local dir_x, dir_y = steering:evaluate(0, 0, 0, 0)
  lurek.log.debug("wander dir=" .. tostring(dir_x) .. "," .. tostring(dir_y), "ai")
end
--@api-stub: LContextSteering:addAvoidBounds
-- Adds a avoid bounds to this context steering.
do
  local steering = lurek.ai.newContextSteering(16)
  steering:addSeekTarget(500, 300, 1.0)
  steering:addAvoidBounds(0, 0, 1280, 720, 32, 1.0)
  steering:evaluate(16, 16, 0, 0)
end
--@api-stub: LContextSteering:clearBehaviors
-- Clears all behaviors items from this context steering.
do
  local steering = lurek.ai.newContextSteering(16)
  steering:addSeekTarget(500, 300, 1.0)
  steering:clearBehaviors()
  local dir_x, dir_y = steering:evaluate(0, 0, 0, 0)
  lurek.log.debug("cleared dir=" .. tostring(dir_x) .. "," .. tostring(dir_y), "ai")
end
--@api-stub: LContextSteering:chosenMagnitude
-- Performs the chosen magnitude operation on this context steering.
do
  local steering = lurek.ai.newContextSteering(16)
  steering:addSeekTarget(500, 300, 1.0)
  steering:evaluate(0, 0, 0, 0)
  lurek.log.debug("mag=" .. tostring(steering:chosenMagnitude()), "ai")
end
--@api-stub: LContextSteering:slotCount
-- Performs the slot count operation on this context steering.
do
  local steering = lurek.ai.newContextSteering(16)
  steering:addSeekTarget(500, 300, 1.0)
  lurek.log.debug("slots=" .. tostring(steering:slotCount()), "ai")
end
--@api-stub: LNeedSystem:addNeed
-- Adds a need to this need system.
do
  -- Need values decay over time and become urgent near their threshold.
  local needs = lurek.ai.newNeedSystem()
  needs:addNeed("hunger", 0.05, 0.6, 1.5)
  needs:addNeed("thirst", 0.08, 0.5, 2.0)
  lurek.log.debug("hunger=" .. tostring(needs:valueOf("hunger")), "ai")
end
--@api-stub: LNeedSystem:update
-- Advances this need system by the given delta time.
do
  local needs = lurek.ai.newNeedSystem()
  needs:addNeed("hunger", 0.05, 0.6, 1.5)
  needs:update(10.0)
  lurek.log.debug("hunger after update=" .. tostring(needs:valueOf("hunger")), "ai")
end
--@api-stub: LNeedSystem:mostUrgent
-- Performs the most urgent operation on this need system.
do
  local needs = lurek.ai.newNeedSystem()
  needs:addNeed("hunger", 0.05, 0.6, 1.5)
  needs:update(20.0)
  local urgent_need = needs:mostUrgent() or "none"
  lurek.log.debug("urgent=" .. urgent_need, "ai")
end
--@api-stub: LNeedSystem:satisfy
-- Performs the satisfy operation on this need system.
do
  local needs = lurek.ai.newNeedSystem()
  needs:addNeed("hunger", 0.05, 0.6, 1.5)
  needs:update(20.0)
  needs:satisfy("hunger", 0.4)
  lurek.log.debug("hunger satisfied=" .. tostring(needs:valueOf("hunger")), "ai")
end
--@api-stub: LNeedSystem:valueOf
-- Performs the value of operation on this need system.
do
  local needs = lurek.ai.newNeedSystem()
  needs:addNeed("hunger", 0.05, 0.6, 1.5)
  needs:update(20.0)
  local hunger = needs:valueOf("hunger")
  if hunger > 0.8 then
    lurek.log.warn("urgent hunger", "ai")
  end
end
--@api-stub: LAIDirector:pushEvent
-- Performs the push event operation on this ai director.
do
  local director = lurek.ai.newAIDirector()
  director:pushEvent(0.7)
  lurek.log.debug("tension after event=" .. tostring(director:tension()), "ai")
end
--@api-stub: LAIDirector:update
-- Advances this ai director by the given delta time.
do
  local director = lurek.ai.newAIDirector()
  director:pushEvent(0.5)
  director:update(1 / 60)
  lurek.log.debug("director phase=" .. director:phase(), "ai")
end
--@api-stub: LAIDirector:tension
-- Performs the tension operation on this ai director.
do
  local director = lurek.ai.newAIDirector()
  director:pushEvent(0.5)
  lurek.log.debug("tension=" .. tostring(director:tension()), "ai")
end
--@api-stub: LAIDirector:phase
-- Performs the phase operation on this ai director.
do
  local director = lurek.ai.newAIDirector()
  director:setTension(0.9)
  director:update(1 / 60)
  lurek.log.info("director phase=" .. director:phase(), "ai")
end
--@api-stub: LAIDirector:spawnRateFactor
-- Performs the spawn rate factor operation on this ai director.
do
  local director = lurek.ai.newAIDirector()
  director:setTension(0.8)
  local multiplier = director:spawnRateFactor()
  lurek.log.debug("spawn x" .. tostring(multiplier), "ai")
end
--@api-stub: LAIDirector:lootFactor
-- Performs the loot factor operation on this ai director.
do
  local director = lurek.ai.newAIDirector()
  director:setTension(0.3)
  lurek.log.debug("loot x" .. tostring(director:lootFactor()), "ai")
end
--@api-stub: LAIDirector:ambientIntensity
-- Performs the ambient intensity operation on this ai director.
do
  local director = lurek.ai.newAIDirector()
  director:setTension(0.6)
  local ambience = director:ambientIntensity()
  if ambience > 0.5 then
    lurek.log.debug("loud ambience", "ai")
  end
end
--@api-stub: LAIDirector:setTension
-- Sets the tension of this ai director.
do
  local director = lurek.ai.newAIDirector()
  director:setTension(0.9)
  lurek.log.debug("set tension=" .. tostring(director:tension()), "ai")
end
--@api-stub: LAIDirector:reset
-- Resets this ai director to its default state.
do
  local director = lurek.ai.newAIDirector()
  director:setTension(0.9)
  director:reset()
  lurek.log.debug("reset tension=" .. tostring(director:tension()), "ai")
end
--@api-stub: LHTNDomain:addPrimitive
-- Adds a primitive to this htn domain.
do
  local domain = lurek.ai.newHTNDomain()
  domain:addPrimitive("attack", { "has_weapon", "in_range" }, { "enemy_dead" }, { "in_range" })
  lurek.log.debug("htn tasks=" .. tostring(domain:taskCount()), "ai")
end
--@api-stub: LHTNDomain:taskCount
-- Performs the task count operation on this htn domain.
do
  local domain = lurek.ai.newHTNDomain()
  domain:addPrimitive("rest", {}, { "rested" }, {})
  domain:addPrimitive("eat", { "has_food" }, { "fed" }, { "hungry" })
  lurek.log.debug("tasks=" .. tostring(domain:taskCount()), "ai")
end
--@api-stub: LEmotionModel:trigger
-- Performs the trigger operation on this emotion model.
do
  local emotions = lurek.ai.newEmotionModel()
  emotions:add("fear", 0.0, 0.1, 0.2)
  emotions:trigger("fear", 0.5)
  lurek.log.debug("fear=" .. tostring(emotions:get("fear")), "ai")
end
--@api-stub: LEmotionModel:get
-- Returns the  of this emotion model.
do
  local emotions = lurek.ai.newEmotionModel()
  emotions:add("fear", 0.0, 0.1, 0.2)
  emotions:trigger("fear", 0.4)
  if emotions:get("fear") > 0.3 then
    lurek.log.debug("fear active", "ai")
  end
end
--@api-stub: LEmotionModel:dominant
-- Performs the dominant operation on this emotion model.
do
  local emotions = lurek.ai.newEmotionModel()
  emotions:add("fear", 0.0, 0.1, 0.2)
  emotions:add("anger", 0.0, 0.05, 0.2)
  emotions:trigger("fear", 0.6)
  emotions:trigger("anger", 0.3)
  local dominant = emotions:dominant()
  if dominant then
    lurek.log.info("feeling " .. dominant, "ai")
  end
end
--@api-stub: LEmotionModel:isActive
-- Returns true if this emotion model is currently active.
do
  local emotions = lurek.ai.newEmotionModel()
  emotions:add("fear", 0.0, 0.1, 0.2)
  emotions:trigger("fear", 0.5)
  if emotions:isActive("fear") then
    lurek.log.debug("show fear face", "ai")
  end
end
--@api-stub: LEmotionModel:update
-- Advances this emotion model by the given delta time.
do
  local emotions = lurek.ai.newEmotionModel()
  emotions:add("fear", 0.0, 0.1, 0.2)
  emotions:trigger("fear", 0.5)
  emotions:update(1.0)
  lurek.log.debug("fear after update=" .. tostring(emotions:get("fear")), "ai")
end
--@api-stub: LEmotionModel:reset
-- Resets this emotion model to its default state.
do
  local emotions = lurek.ai.newEmotionModel()
  emotions:add("fear", 0.0, 0.1, 0.2)
  emotions:trigger("fear", 0.5)
  emotions:reset()
  lurek.log.debug("fear reset=" .. tostring(emotions:get("fear")), "ai")
end
--@api-stub: LORCASolver:setPosition
-- Sets the position of this orca solver.
do
  local orca = lurek.ai.newORCASolver(2.0)
  local agent_index = orca:addAgent(100, 100, 16, 80)
  orca:setPosition(agent_index, 120, 100)
  orca:compute(1 / 60)
  local safe_x, safe_y = orca:getSafeVelocity(agent_index)
  lurek.log.debug("orca safe after move=" .. tostring(safe_x) .. "," .. tostring(safe_y), "ai")
end
--@api-stub: LORCASolver:compute
-- Performs the compute operation on this orca solver.
do
  local orca = lurek.ai.newORCASolver(2.0)
  local agent_index = orca:addAgent(100, 100, 16, 80)
  orca:setPreferredVelocity(agent_index, 40, 0)
  orca:compute(1 / 60)
end
--@api-stub: LORCASolver:getSafeVelocity
-- Returns the safe velocity of this orca solver.
do
  local orca = lurek.ai.newORCASolver(2.0)
  local agent_index = orca:addAgent(100, 100, 16, 80)
  orca:setPreferredVelocity(agent_index, 40, 0)
  orca:compute(0.016)
  local velocity_x, velocity_y = orca:getSafeVelocity(agent_index)
  lurek.log.debug("safe v=" .. tostring(velocity_x) .. "," .. tostring(velocity_y), "ai")
end
--@api-stub: LORCASolver:agentCount
-- Performs the agent count operation on this orca solver.
do
  local orca = lurek.ai.newORCASolver(2.0)
  orca:addAgent(100, 100, 16, 80)
  orca:addAgent(140, 100, 16, 80)
  lurek.log.debug("agents=" .. tostring(orca:agentCount()), "ai")
end
--@api-stub: LNeuralNet:forward
-- Performs the forward operation on this neural net.
do
  local network = lurek.ai.newNeuralNet()
  network:addLayer(4, 8, "relu")
  network:addLayer(8, 2, "softmax")
  local output = network:forward({ 0.1, 0.2, 0.3, 0.4 })
  lurek.log.debug("y=" .. tostring(output[1]) .. "," .. tostring(output[2]), "ai")
end
--@api-stub: LNeuralNet:setWeights
-- Sets the weights of this neural net.
do
  local network = lurek.ai.newNeuralNet()
  network:addLayer(4, 8, "relu")
  network:addLayer(8, 2, "softmax")
  local param_count = network:paramCount()
  local weights = {}
  for weight_index = 1, param_count do
    weights[weight_index] = 0.01
  end
  local ok = network:setWeights(weights)
  lurek.log.debug("weights ok=" .. tostring(ok), "ai")
end
--@api-stub: LNeuralNet:getWeights
-- Returns the weights of this neural net.
do
  local network = lurek.ai.newNeuralNet()
  network:addLayer(4, 8, "relu")
  network:addLayer(8, 2, "softmax")
  local weights = network:getWeights()
  lurek.log.debug("weights=" .. tostring(#weights), "ai")
end
--@api-stub: LNeuralNet:paramCount
-- Performs the param count operation on this neural net.
do
  local network = lurek.ai.newNeuralNet()
  network:addLayer(4, 8, "relu")
  network:addLayer(8, 2, "softmax")
  lurek.log.debug("params=" .. tostring(network:paramCount()), "ai")
end
--@api-stub: LNeuralNet:layerCount
-- Performs the layer count operation on this neural net.
do
  local network = lurek.ai.newNeuralNet()
  network:addLayer(4, 8, "relu")
  network:addLayer(8, 2, "softmax")
  lurek.log.debug("layers=" .. tostring(network:layerCount()), "ai")
end
--@api-stub: LGeneticAlgorithm:evolve
-- Performs the evolve operation on this genetic algorithm.
do
  local genetic = lurek.ai.newGeneticAlgorithm(20, 8, 42)
  for chromosome_index = 0, genetic:popSize() - 1 do
    genetic:setFitness(chromosome_index, 0.5)
  end
  genetic:evolve()
  lurek.log.debug("generation=" .. tostring(genetic:generation()), "ai")
end
--@api-stub: LGeneticAlgorithm:generation
-- Performs the generation operation on this genetic algorithm.
do
  local genetic = lurek.ai.newGeneticAlgorithm(20, 8, 42)
  lurek.log.debug("generation=" .. tostring(genetic:generation()), "ai")
end
--@api-stub: LGeneticAlgorithm:popSize
-- Performs the pop size operation on this genetic algorithm.
do
  local genetic = lurek.ai.newGeneticAlgorithm(20, 8, 42)
  lurek.log.debug("pop=" .. tostring(genetic:popSize()), "ai")
end
--@api-stub: LGeneticAlgorithm:setFitness
-- Sets the fitness of this genetic algorithm.
do
  local genetic = lurek.ai.newGeneticAlgorithm(20, 8, 42)
  for chromosome_index = 0, genetic:popSize() - 1 do
    genetic:setFitness(chromosome_index, 0.25 + chromosome_index * 0.01)
  end
end
--@api-stub: LGeneticAlgorithm:getGenes
-- Returns the genes of this genetic algorithm.
do
  local genetic = lurek.ai.newGeneticAlgorithm(20, 8, 42)
  local genes = genetic:getGenes(0)
  lurek.log.debug("first gene=" .. tostring(genes[1]), "ai")
end
--@api-stub: LGeneticAlgorithm:bestGenes
-- Performs the best genes operation on this genetic algorithm.
do
  local genetic = lurek.ai.newGeneticAlgorithm(20, 8, 42)
  genetic:setFitness(0, 1.0)
  local best = genetic:bestGenes()
  lurek.log.debug("best[1]=" .. tostring(best[1]), "ai")
end
--@api-stub: LBandit:select
-- Performs the select operation on this bandit.
do
  local bandit = lurek.ai.newBandit(4, "ucb1", 0.1, 99)
  local arm = bandit:select()
  lurek.log.debug("arm=" .. tostring(arm), "ai")
end
--@api-stub: LBandit:update
-- Advances this bandit by the given delta time.
do
  local bandit = lurek.ai.newBandit(4, "ucb1", 0.1, 99)
  local arm = bandit:select()
  bandit:update(arm, 1.0)
  lurek.log.debug("pulls=" .. tostring(bandit:totalPulls()), "ai")
end
--@api-stub: LBandit:bestArm
-- Returns the zero-based arm index with the strongest current reward estimate.
do
  local bandit = lurek.ai.newBandit(4, "ucb1", 0.1, 99)
  bandit:update(0, 0.7)
  bandit:update(1, 0.3)
  bandit:update(2, 0.9)

  local best_arm = bandit:bestArm()
  lurek.log.debug("best reward arm=" .. tostring(best_arm), "ai")
end
--@api-stub: LBandit:reset
-- Clears all recorded pulls and reward estimates for this bandit.
do
  local bandit = lurek.ai.newBandit(4, "ucb1", 0.1, 99)
  bandit:update(0, 0.4)
  bandit:update(1, 0.8)
  lurek.log.debug("before reset pulls=" .. tostring(bandit:totalPulls()), "ai")

  bandit:reset()
  lurek.log.debug("after reset pulls=" .. tostring(bandit:totalPulls()), "ai")
end
--@api-stub: LBandit:armCount
-- Returns how many zero-based choices the bandit can select from.
do
  local bandit = lurek.ai.newBandit(4, "epsilon_greedy", 0.2, 42)
  for arm = 0, bandit:armCount() - 1 do
    bandit:update(arm, arm * 0.25)
  end
  lurek.log.debug("bandit arms=" .. tostring(bandit:armCount()), "ai")
end
--@api-stub: LBandit:totalPulls
-- Reports the total number of arm selections recorded by this bandit.
do
  local bandit = lurek.ai.newBandit(3, "ucb1", 0.1, 99)
  for _ = 1, 5 do
    local arm = bandit:select()
    bandit:update(arm, arm == 2 and 1.0 or 0.25)
  end
  lurek.log.debug("recorded pulls=" .. tostring(bandit:totalPulls()), "ai")
end
--@api-stub: LNeuroevolution:evolve
-- Advances the population by one generation after fitness values are assigned.
do
  local layers = { { inputs = 2, outputs = 4, activation = "relu" }, { inputs = 4, outputs = 1, activation = "tanh" } }
  local evolution = lurek.ai.newNeuroevolution(layers, 10, 1)
  for index = 0, evolution:popSize() - 1 do
    evolution:setFitness(index, 1.0 - index * 0.05)
  end

  evolution:evolve()
  lurek.log.debug("generation=" .. tostring(evolution:generation()), "ai")
end
--@api-stub: LNeuroevolution:setFitness
-- Stores the score for one zero-based chromosome before the next evolve call.
do
  local layers = { { inputs = 2, outputs = 4, activation = "relu" }, { inputs = 4, outputs = 1, activation = "tanh" } }
  local evolution = lurek.ai.newNeuroevolution(layers, 10, 1)
  evolution:setFitness(0, 0.85)
  evolution:setFitness(1, 0.35)
  lurek.log.debug("best fitness=" .. tostring(evolution:bestFitness()), "ai")
end
--@api-stub: LNeuroevolution:chromosomeToNet
-- Converts a valid chromosome index into an LNeuralNet handle.
do
  local layers = { { inputs = 2, outputs = 4, activation = "relu" }, { inputs = 4, outputs = 1, activation = "tanh" } }
  local evolution = lurek.ai.newNeuroevolution(layers, 10, 1)
  local network = evolution:chromosomeToNet(0)
  if network then
    local output = network:forward({ 0.25, 0.75 })
    lurek.log.debug("chromosome net output=" .. tostring(output[1]), "ai")
  end
end
--@api-stub: LNeuroevolution:bestNetwork
-- Returns an LNeuralNet built from the current best chromosome, when one exists.
do
  local layers = { { inputs = 2, outputs = 4, activation = "relu" }, { inputs = 4, outputs = 1, activation = "tanh" } }
  local evolution = lurek.ai.newNeuroevolution(layers, 10, 1)
  evolution:setFitness(0, 1.0)
  evolution:setFitness(1, 0.2)
  local best = evolution:bestNetwork()
  if best then
    lurek.log.debug("best network layers=" .. tostring(best:layerCount()), "ai")
  end
end
--@api-stub: LNeuroevolution:bestFitness
-- Reads the highest chromosome fitness currently recorded in the population.
do
  local layers = { { inputs = 2, outputs = 4, activation = "relu" }, { inputs = 4, outputs = 1, activation = "tanh" } }
  local evolution = lurek.ai.newNeuroevolution(layers, 10, 1)
  evolution:setFitness(0, 0.7)
  evolution:setFitness(3, 0.95)
  lurek.log.debug("best fitness=" .. tostring(evolution:bestFitness()), "ai")
end
--@api-stub: LNeuroevolution:popSize
-- Returns the number of chromosomes maintained by this neuroevolution run.
do
  local layers = { { inputs = 2, outputs = 4, activation = "relu" }, { inputs = 4, outputs = 1, activation = "tanh" } }
  local evolution = lurek.ai.newNeuroevolution(layers, 10, 1)
  for index = 0, evolution:popSize() - 1 do
    evolution:setFitness(index, index / evolution:popSize())
  end
  lurek.log.debug("population size=" .. tostring(evolution:popSize()), "ai")
end
--@api-stub: LNeuroevolution:generation
-- Returns the current generation count, which increases after evolve.
do
  local layers = { { inputs = 2, outputs = 4, activation = "relu" }, { inputs = 4, outputs = 1, activation = "tanh" } }
  local evolution = lurek.ai.newNeuroevolution(layers, 10, 1)
  local before = evolution:generation()
  evolution:setFitness(0, 1.0)
  evolution:evolve()
  lurek.log.debug("generation " .. tostring(before) .. " -> " .. tostring(evolution:generation()), "ai")
end
--@api-stub: LStrategyAI:addGoal
-- Registers a named strategic option that scorer callbacks can rank.
do
  local strategy = lurek.ai.newStrategyAI(2.0)
  strategy:addGoal("expand")
  strategy:addGoal("defend")
  strategy:forceEvaluate(function(goal)
    return goal == "defend" and 0.9 or 0.4
  end)
  lurek.log.debug("active goal=" .. tostring(strategy:activeGoal()), "ai")
end
--@api-stub: LStrategyAI:addTag
-- Adds one context tag to the strategy model for systems that track eligibility state.
do
  local strategy = lurek.ai.newStrategyAI(2.0)
  strategy:addTag("early_game")
  strategy:addGoal("scout")
  strategy:forceEvaluate(function(goal)
    return goal == "scout" and 0.75 or 0.0
  end)
  lurek.log.debug("tagged strategy goal=" .. tostring(strategy:activeGoal()), "ai")
end
--@api-stub: LStrategyAI:removeTag
-- Removes a context tag from the strategy model when the world state changes.
do
  local strategy = lurek.ai.newStrategyAI(2.0)
  strategy:addTag("scout_phase")
  strategy:removeTag("scout_phase")
  strategy:addGoal("hold_position")
  strategy:forceEvaluate(function(goal)
    return goal == "hold_position" and 0.6 or 0.0
  end)
  lurek.log.debug("strategy after tag removal=" .. tostring(strategy:activeGoal()), "ai")
end
--@api-stub: LStrategyAI:update
-- Advances the internal timer and evaluates goals after the configured interval elapses.
do
  local strategy = lurek.ai.newStrategyAI(1.0)
  strategy:addGoal("expand")
  strategy:addGoal("fortify")
  strategy:update(0.5, function(goal)
    return goal == "expand" and 0.5 or 0.7
  end)
  strategy:update(0.6, function(goal)
    return goal == "expand" and 0.5 or 0.7
  end)
  lurek.log.debug("strategy update picked=" .. tostring(strategy:activeGoal()), "ai")
end
--@api-stub: LStrategyAI:forceEvaluate
-- Immediately evaluates all registered goals without waiting for the timer interval.
do
  local strategy = lurek.ai.newStrategyAI(2.0)
  strategy:addGoal("retreat")
  strategy:addGoal("push")
  strategy:forceEvaluate(function(goal)
    return goal == "retreat" and 1.0 or 0.0
  end)
  lurek.log.info("forced goal=" .. tostring(strategy:activeGoal()), "ai")
end
--@api-stub: LStrategyAI:activeGoal
-- Returns the currently selected strategic goal, or nil before evaluation.
do
  local strategy = lurek.ai.newStrategyAI(2.0)
  strategy:addGoal("hold")
  strategy:addGoal("advance")
  strategy:forceEvaluate(function(goal)
    return goal == "advance" and 0.8 or 0.3
  end)
  local active_goal = strategy:activeGoal()
  if active_goal then
    lurek.log.info("active strategy=" .. active_goal, "ai")
  end
end
--@api-stub: LStrategyAI:timeUntilNext
-- Returns the seconds remaining before the next interval-based evaluation.
do
  local strategy = lurek.ai.newStrategyAI(2.0)
  strategy:addGoal("economy")
  strategy:update(0.75, function(goal)
    return goal == "economy" and 1.0 or 0.0
  end)
  lurek.log.debug("next eval in " .. tostring(strategy:timeUntilNext()), "ai")
end
--@api-stub: LAILod:shouldUpdate
-- Checks whether agents in a zero-based LOD tier should run on a frame counter.
do
  local lod = lurek.ai.newAILod()
  local tier = lod:tierFor(650, 0, 0, 0)
  for frame = 60, 64 do
    if lod:shouldUpdate(tier, frame) then
      lurek.log.debug("tier " .. tostring(tier) .. " updates on frame " .. tostring(frame), "ai")
    end
  end
end
--@api-stub: LAILod:tierCount
-- Returns how many distance tiers are configured in the default AI LOD table.
do
  local lod = lurek.ai.newAILod()
  for tier = 0, lod:tierCount() - 1 do
    lurek.log.debug("lod tier index=" .. tostring(tier), "ai")
  end
  lurek.log.debug("lod tier count=" .. tostring(lod:tierCount()), "ai")
end
--@api-stub: LAILod:tierName
-- Returns the display name for a zero-based AI LOD tier when the tier exists.
do
  local lod = lurek.ai.newAILod()
  for tier = 0, lod:tierCount() - 1 do
    local name = lod:tierName(tier)
    if name then
      lurek.log.debug("lod tier " .. tostring(tier) .. " is " .. name, "ai")
    end
  end
end
--@api-stub: LAgent:setCustomModel
-- Installs a Lua decision callback that runs when the owning AI world updates.
do
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("custom_agent")
  agent:setCustomModel(function(ag, bb, dt)
    local target_dist = bb:getNumber("target_dist", 999)
    if target_dist < 50 then
      ag:setVelocity(0, 0)
    else
      ag:setVelocity(20 * dt, 0)
    end
  end)
  world:update(0.016)
  local vx, vy = agent:getVelocity()
  lurek.log.debug("custom model=" .. agent:getDecisionModel() .. " velocity=" .. tostring(vx) .. "," .. tostring(vy), "ai")
end
--@api-stub: lurek.ai.newGuard
-- Creates a guard decorator that runs a predicate before ticking its child
do
  local action = lurek.ai.newAction(function(ag, bb, dt)
    return dt >= 0 and "success" or "failure"
  end)
  local guard = lurek.ai.newGuard(
    function(ag, bb)
      return bb:getNumber("health", 1.0) > 0.0
    end,
    action
  )
  lurek.log.debug("guard type=" .. guard:getNodeType(), "ai")
  lurek.log.debug("guard children=" .. guard:getChildCount(), "ai")
end
--@api-stub: LUtilityAI:addConsideration
-- Adds an extra scorer and response curve to an existing utility action.
do
  local utility = lurek.ai.newUtilityAI()
  utility:addAction("patrol", function()
    return 0.4
  end, 1.0)
  utility:addConsideration(
    "patrol",
    "health_curve",
    function()
      return 0.8
    end,
    "linear",
    1.0,
    0.0,
    0.0,
    0.5
  )
  lurek.log.debug("utility winner=" .. tostring(utility:evaluate()), "ai")
end
--@api-stub: LSteeringManager:addCustomBehavior
-- Adds a weighted Lua callback that returns a steering force.
do
  local steering = lurek.ai.newSteeringManager()
  steering:addCustomBehavior(function(ag, dt)
    return 100 * dt, 0
  end, 1.0)
  lurek.log.debug("custom behaviors=" .. tostring(steering:getBehaviorCount()), "ai")
end
--@api-stub: LSteeringManager:applyCustomSteering
-- Runs all enabled custom steering callbacks and combines their weighted forces.
do
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("steered")
  agent:setPosition(10, 20)

  local steering = lurek.ai.newSteeringManager()
  steering:addCustomBehavior(function(ag, dt)
    local x, y = ag:getPosition()
    return (50 - x) * dt, (25 - y) * dt
  end, 1.0)
  local fx, fy = steering:applyCustomSteering(agent, 0.016)
  lurek.log.debug("custom force=" .. tostring(fx) .. "," .. tostring(fy), "ai")
end
--@api-stub: LEmotionModel:add
-- Registers an emotion with its resting value, decay rate, and active threshold.
do
  local emotions = lurek.ai.newEmotionModel()
  emotions:add("fear", 0.0, 0.08, 1.0)
  emotions:add("anger", 0.0, 0.06, 1.0)
  emotions:trigger("fear", 1.25)
  lurek.log.info("dominant emotion=" .. tostring(emotions:dominant()), "ai")
end
--@api-stub: LGOAPPlanner:addAction
-- Registers a GOAP action with an optional cost and callback for game execution.
do
  local planner = lurek.ai.newGOAPPlanner()
  planner:addAction("pickup_key", 2.0, function()
    lurek.log.info("picked up key", "ai")
  end)
  planner:setEffect("pickup_key", "has_key", true)
  planner:addAction("unlock_door", 1.0, function()
    lurek.log.info("door unlocked", "ai")
  end)
  planner:setPrecondition("unlock_door", "has_key", true)
  planner:setEffect("unlock_door", "door_open", true)
  lurek.log.debug("goap actions=" .. tostring(planner:getActionCount()), "ai")
end
--@api-stub: LUtilityAI:addAction
-- Registers a utility action scored by a Lua callback.
do
  local utility = lurek.ai.newUtilityAI()
  utility:addAction("heal", function()
    return 0.9
  end, 1.0)
  utility:addAction("attack", function()
    return 0.4
  end, 1.0)
  local best = utility:evaluate()
  lurek.log.info("best action: " .. (best or "none"), "ai")
end
--@api-stub: LORCASolver:addAgent
-- Adds an ORCA avoidance agent and returns its zero-based solver index.
do
  local orca = lurek.ai.newORCASolver(2.0)
  local first = orca:addAgent(0, 0, 12, 80)
  local second = orca:addAgent(24, 0, 12, 80)
  orca:setPreferredVelocity(first, 50, 0)
  orca:setPreferredVelocity(second, -50, 0)
  lurek.log.info("orca agents=" .. tostring(orca:agentCount()), "ai")
end
--@api-stub: LSteeringManager:addArrive
-- Adds an arrive behavior that slows down near the target point.
do
  local steering = lurek.ai.newSteeringManager()
  steering:addArrive(400, 300, 80, 1.0)
  local fx, fy = steering:calculate(200, 200, 0, 0, 100, 50, 1 / 60)
  lurek.log.info("arrive force=" .. tostring(fx) .. "," .. tostring(fy), "ai")
end
--@api-stub: LStimulusWorld:addAuditory
-- Adds a decaying sound stimulus and returns its identifier.
do
  local stimuli = lurek.ai.newStimulusWorld()
  local id = stimuli:addAuditory(200, 150, 1.2, 100, 0.8, "footstep")
  stimuli:update(0.25)
  lurek.log.info("auditory stimulus " .. tostring(id) .. " count=" .. tostring(stimuli:count()), "ai")
end
--@api-stub: LContextSteering:addAvoidPoint
-- Adds point avoidance to a slot-based context steering model.
do
  local context = lurek.ai.newContextSteering(16)
  context:addSeekTarget(500, 300, 1.0)
  context:addAvoidPoint(300, 200, 64, 1.5)
  context:addAvoidPoint(100, 350, 48, 1.0)
  local fx, fy = context:evaluate(150, 150, 0, 0)
  lurek.log.info("context steer=" .. tostring(fx) .. "," .. tostring(fy), "ai")
end
--@api-stub: LHTNDomain:addCompound
-- Adds a compound task whose methods decompose into primitive task names.
do
  local domain = lurek.ai.newHTNDomain()
  domain:addPrimitive("draw_weapon", {}, { "armed" }, {})
  domain:addPrimitive("strike", { "armed" }, { "enemy_down" }, {})
  domain:addCompound("defeat_enemy", {
    { name = "armed_attack", preconditions = {}, sub_tasks = { "draw_weapon", "strike" } }
  })
  lurek.log.info("htn tasks=" .. tostring(domain:taskCount()), "ai")
end
--@api-stub: LSteeringManager:addEvade
-- Adds an evade behavior that moves away from a named threat agent.
do
  local steering = lurek.ai.newSteeringManager()
  steering:addEvade("player", 1.0)
  local fx, fy = steering:calculate(200, 200, 0, 0, 100, 50, 1 / 60)
  lurek.log.info("evade force=" .. tostring(fx) .. "," .. tostring(fy), "ai")
end
--@api-stub: LSteeringManager:addFlee
-- Adds a flee behavior that pushes away from a threat point inside a panic radius.
do
  local steering = lurek.ai.newSteeringManager()
  steering:addFlee(400, 300, 250, 1.0)
  local fx, fy = steering:calculate(250, 240, 0, 0, 100, 50, 1 / 60)
  lurek.log.info("flee force=" .. tostring(fx) .. "," .. tostring(fy), "ai")
end
--@api-stub: LSteeringManager:addFlock
-- Adds flocking weights for separation, alignment, and cohesion.
do
  local steering = lurek.ai.newSteeringManager()
  steering:addFlock(80, 1.0, 0.8, 0.6, 1.0)
  local fx, fy = steering:calculate(200, 200, 10, 0, 100, 50, 1 / 60)
  lurek.log.info("flock force=" .. tostring(fx) .. "," .. tostring(fy), "ai")
end
--@api-stub: LGOAPPlanner:addGoal
-- Registers a named GOAP goal and its priority weight.
do
  local planner = lurek.ai.newGOAPPlanner()
  planner:addAction("rest", 1.0, function()
    lurek.log.debug("rest action", "ai")
  end)
  planner:addGoal("is_rested", 1.0)
  planner:addGoal("is_safe", 2.0)
  lurek.log.info("goap goal count=" .. tostring(planner:getGoalCount()), "ai")
end
--@api-stub: LNeuralNet:addLayer
-- Adds a feed-forward neural network layer with a named activation function.
do
  local network = lurek.ai.newNeuralNet()
  network:addLayer(2, 3, "relu")
  network:addLayer(3, 1, "sigmoid")
  local output = network:forward({ 0.25, 0.75 })
  lurek.log.info("network output=" .. tostring(output[1]), "ai")
end
--@api-stub: LTraitProfile:addModifier
-- Adds a temporary modifier to a base trait value.
do
  local traits = lurek.ai.newTraitProfile()
  traits:set("courage", 0.5)
  traits:addModifier("courage", -0.3, 5.0, "fear_potion")
  lurek.log.info("effective courage=" .. tostring(traits:get("courage")), "ai")
end
--@api-stub: LSteeringManager:addPursue
-- Adds a pursue behavior that chases a named target agent.
do
  local steering = lurek.ai.newSteeringManager()
  steering:addPursue("player", 1.0)
  local fx, fy = steering:calculate(200, 200, 0, 0, 100, 50, 1 / 60)
  lurek.log.info("pursue force=" .. tostring(fx) .. "," .. tostring(fy), "ai")
end
--@api-stub: LSteeringManager:addSeek
-- Adds a seek behavior that pulls the agent toward a target point.
do
  local steering = lurek.ai.newSteeringManager()
  steering:addSeek(500, 400, 1.0)
  local fx, fy = steering:calculate(100, 100, 0, 0, 150, 50, 1 / 60)
  lurek.log.info("seek force=" .. tostring(fx) .. "," .. tostring(fy), "ai")
end
--@api-stub: LContextSteering:addSeekTarget
-- Adds target attraction to a context steering slot model.
do
  local context = lurek.ai.newContextSteering(16)
  context:addSeekTarget(500, 300, 1.0)
  context:addSeekTarget(400, 400, 0.6)
  local fx, fy = context:evaluate(200, 200, 0, 0)
  lurek.log.info("context direction=" .. tostring(fx) .. "," .. tostring(fy), "ai")
end
--@api-stub: LStateMachine:addTransition
-- Adds a guarded transition between two named state-machine states.
do
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("patrol", { onEnter = function() lurek.log.debug("enter patrol", "ai") end })
  fsm:addState("alert", { onEnter = function() lurek.log.debug("enter alert", "ai") end })
  fsm:addTransition("patrol", "alert", function()
    return true
  end, 10)
  fsm:setInitialState("patrol")
  lurek.log.info("state: " .. (fsm:getCurrentState() or "nil"), "ai")
end
--@api-stub: LStimulusWorld:addVisual
-- Adds a visual stimulus and returns its identifier.
do
  local stimuli = lurek.ai.newStimulusWorld()
  local visual_id = stimuli:addVisual(300, 200, 1.0, 200, "player")
  stimuli:addAuditory(300, 200, 1.0, 80, 0.5, "footstep")
  lurek.log.info("visual stimulus " .. tostring(visual_id) .. " count=" .. tostring(stimuli:count()), "ai")
end
--@api-stub: LContextSteering:addWander
-- Adds wander noise to context steering before evaluating the selected slot.
do
  local context = lurek.ai.newContextSteering(16)
  context:addSeekTarget(500, 300, 0.6)
  context:addWander(8, 0.4)
  local fx, fy = context:evaluate(200, 200, 0, 0)
  lurek.log.info("context wander=" .. tostring(fx) .. "," .. tostring(fy), "ai")
end
--@api-stub: LInfluenceMap:blend
-- Blends two influence layers into a destination layer with independent weights.
do
  local map = lurek.ai.newInfluenceMap(32, 32, 16)
  map:addLayer("threat")
  map:addLayer("resource")
  map:addLayer("priority")
  map:stampInfluence("threat", 256, 256, 64, 1.0, 1.0)
  map:stampInfluence("resource", 192, 192, 64, 0.6, 1.0)
  map:blend("threat", 0.7, "resource", 0.3, "priority")
  lurek.log.info("priority influence=" .. tostring(map:getInfluence("priority", 16, 16)), "ai")
end
--@api-stub: LSteeringManager:calculate
-- Calculates the combined steering force from the configured behaviors.
do
  local steering = lurek.ai.newSteeringManager()
  steering:addSeek(400, 300, 1.0)
  steering:addArrive(400, 300, 80, 0.5)
  local fx, fy = steering:calculate(100, 100, 0, 0, 120, 50, 1 / 60)
  lurek.log.info("steering force=" .. tostring(fx) .. "," .. tostring(fy), "ai")
end
--@api-stub: LStimulusWorld:count
-- Returns the number of active visual and auditory stimuli.
do
  local stimuli = lurek.ai.newStimulusWorld()
  local sound_id = stimuli:addAuditory(200, 100, 1.0, 80, 0.8, "alert")
  stimuli:addVisual(240, 120, 0.6, 120, "movement")
  local count = stimuli:count()
  lurek.log.info("active stimuli=" .. tostring(count) .. " first=" .. tostring(sound_id), "ai")
end
--@api-stub: LCommandQueue:enqueue
-- Appends callback-backed commands with optional target and priority fields.
do
  local queue = lurek.ai.newCommandQueue()
  queue:enqueue("move", function()
    lurek.log.debug("move command", "ai")
  end, { targetX = 300, targetY = 200, priority = 1 })
  queue:enqueue("attack", function()
    lurek.log.debug("attack command", "ai")
  end, { targetX = 480, targetY = 220, priority = 2, interruptible = false })
  lurek.log.info("queue count=" .. tostring(queue:getCount()), "ai")
end
--@api-stub: LContextSteering:evaluate
-- Evaluates all context steering influences and returns the chosen direction.
do
  local context = lurek.ai.newContextSteering(16)
  context:addSeekTarget(500, 300, 1.0)
  context:addAvoidPoint(350, 250, 50, 1.0)
  local dx, dy = context:evaluate(200, 200, 0, 0)
  lurek.log.info("context direction=" .. tostring(dx) .. "," .. tostring(dy), "ai")
  lurek.log.debug("chosen magnitude=" .. tostring(context:chosenMagnitude()), "ai")
end
--@api-stub: LAIBlackboard:getBool
-- Reads a boolean fact, using the fallback when the key is missing or not boolean.
do
  local blackboard = lurek.ai.newBlackboard()
  blackboard:setBool("player_spotted", true)
  local spotted = blackboard:getBool("player_spotted", false)
  local can_attack = blackboard:getBool("can_attack", false)
  lurek.log.info("player spotted: " .. tostring(spotted), "ai")
  lurek.log.debug("can attack: " .. tostring(can_attack), "ai")
end
--@api-stub: LSquad:getFormationPosition
-- Calculates a one-based member slot position around the leader.
do
  local squad = lurek.ai.newSquad("alpha")
  squad:addMember("guard_01")
  squad:addMember("guard_02")
  squad:setFormation("wedge", 32)
  local first_x, first_y = squad:getFormationPosition(1, 400, 300)
  local second_x, second_y = squad:getFormationPosition(2, 400, 300)
  lurek.log.info("slot 1=" .. tostring(first_x) .. "," .. tostring(first_y), "ai")
  lurek.log.debug("slot 2=" .. tostring(second_x) .. "," .. tostring(second_y), "ai")
end
--@api-stub: LInfluenceMap:getInfluence
-- Reads one named-layer cell using one-based cell coordinates.
do
  local map = lurek.ai.newInfluenceMap(32, 32, 16)
  map:addLayer("threat")
  map:stampInfluence("threat", 256, 256, 64, 1.0, 0.9)
  local value = map:getInfluence("threat", 16, 16)
  lurek.log.info("threat influence=" .. tostring(value), "ai")
end
--@api-stub: LAIBlackboard:getNumber
-- Reads a numeric fact, using the fallback when the key is missing or not numeric.
do
  local blackboard = lurek.ai.newBlackboard()
  blackboard:setNumber("threat_level", 0.75)
  local threat = blackboard:getNumber("threat_level", 0.0)
  local courage = blackboard:getNumber("courage", 0.5)
  lurek.log.info("threat=" .. tostring(threat) .. " courage=" .. tostring(courage), "ai")
end
--@api-stub: LAIBlackboard:getString
-- Reads a string fact, using the fallback when the key is missing or not a string.
do
  local blackboard = lurek.ai.newBlackboard()
  blackboard:setString("last_target", "raider_03")
  local name = blackboard:getString("last_target", "none")
  local fallback = blackboard:getString("route", "patrol")
  lurek.log.info("last target=" .. name .. " route=" .. fallback, "ai")
end
--@api-stub: LQLearner:learn
-- Applies one Q-learning update using one-based state and action indices.
do
  local learner = lurek.ai.newQLearner(8, 4)
  learner:setLearningRate(0.1)
  learner:setDiscountFactor(0.9)
  learner:learn(2, 1, 1.0, 3)
  local q_value = learner:getQValue(2, 1)
  lurek.log.info("Q(2,1)=" .. tostring(q_value), "ai")
end
--@api-stub: LGOAPPlanner:plan
-- Builds a GOAP action list from a boolean world-state table.
do
  local planner = lurek.ai.newGOAPPlanner()
  planner:addAction("eat", 1.0, function()
    lurek.log.debug("eat action", "ai")
  end)
  planner:setPrecondition("eat", "has_food", true)
  planner:setEffect("eat", "not_hungry", true)
  planner:addGoal("not_hungry", 1.0)
  planner:setGoalState("not_hungry", "not_hungry", true)
  local actions = planner:plan({ hungry = true, has_food = true }, 5)
  lurek.log.info("goap plan length=" .. tostring(actions and #actions or 0), "ai")
end
--@api-stub: LHTNDomain:plan
-- Decomposes a root compound task into primitive HTN task names.
do
  local domain = lurek.ai.newHTNDomain()
  domain:addPrimitive("move", {}, { "at_waypoint" }, {})
  domain:addPrimitive("scan", { "at_waypoint" }, { "area_checked" }, {})
  domain:addCompound("patrol", {
    { name = "simple_patrol", preconditions = {}, sub_tasks = { "move", "scan" } }
  })
  local plan = domain:plan("patrol", {})
  lurek.log.info("htn plan steps=" .. tostring(plan and #plan or 0), "ai")
end
--@api-stub: LInfluenceMap:propagate
-- Spreads values across neighboring cells on a named influence layer.
do
  local map = lurek.ai.newInfluenceMap(32, 32, 16)
  map:addLayer("threat")
  map:stampInfluence("threat", 256, 256, 48, 1.0, 0.8)
  map:propagate("threat", 0.85)
  lurek.log.info("propagated threat=" .. tostring(map:getInfluence("threat", 16, 16)), "ai")
end
--@api-stub: LCommandQueue:pushFront
-- Inserts a command before the current front of the queue.
do
  local queue = lurek.ai.newCommandQueue()
  queue:enqueue("patrol", function()
    lurek.log.debug("patrol command", "ai")
  end, { targetX = 100, targetY = 120 })
  queue:pushFront("flee", function()
    lurek.log.debug("flee command", "ai")
  end, { targetX = 300, targetY = 200, priority = 10 })
  lurek.log.info("front command=" .. tostring(queue:getCurrentType()), "ai")
end
--@api-stub: LInfluenceMap:queryRect
-- Queries influence samples inside a world-space rectangle.
do
  local map = lurek.ai.newInfluenceMap(32, 32, 16)
  map:addLayer("resource")
  map:setInfluence("resource", 10, 10, 1.0)
  map:setInfluence("resource", 11, 10, 0.5)
  local samples = map:queryRect("resource", 100, 100, 300, 300)
  lurek.log.info("query samples=" .. tostring(samples), "ai")
end
--@api-stub: LCommandQueue:replace
-- Replaces every queued command with a single new command.
do
  local queue = lurek.ai.newCommandQueue()
  queue:enqueue("move", function()
    lurek.log.debug("move command", "ai")
  end, { targetX = 200, targetY = 100 })
  queue:replace("attack", function()
    lurek.log.debug("attack command", "ai")
  end, { targetX = 450, targetY = 180, priority = 5 })
  lurek.log.info("replaced command=" .. tostring(queue:getCurrentType()), "ai")
end
--@api-stub: LMCTSEngine:search
-- Runs Monte Carlo tree search with Lua callbacks for actions, transitions, and scoring.
do
  local mcts = lurek.ai.newMCTSEngine(100, 1.41, 16, 42)
  local actions = function(state)
    return state < 6 and { 1, 2, 3 } or {}
  end
  local apply = function(state, action)
    return state + action
  end
  local eval = function(state)
    return state % 5
  end
  local best = mcts:search(0, actions, apply, eval)
  lurek.log.info("best action=" .. tostring(best), "ai")
end
--@api-stub: LGOAPPlanner:setEffect
-- Stores a boolean world-state effect for an existing GOAP action.
do
  local planner = lurek.ai.newGOAPPlanner()
  planner:addAction("open_door", 1.0, function()
    lurek.log.debug("open door", "ai")
  end)
  planner:setEffect("open_door", "door_locked", false)
  planner:setEffect("open_door", "door_open", true)
  lurek.log.info("effect registered", "ai")
end
--@api-stub: LSquad:setFormation
-- Sets the squad formation type and optional member spacing.
do
  local squad = lurek.ai.newSquad("bravo")
  squad:addMember("soldier_01")
  squad:addMember("soldier_02")
  squad:setFormation("wedge", 40)
  local x, y = squad:getFormationPosition(2, 300, 200)
  lurek.log.info("formation=" .. squad:getFormation() .. " slot=" .. tostring(x) .. "," .. tostring(y), "ai")
end
--@api-stub: LGOAPPlanner:setGoalState
-- Adds a desired boolean world-state key to an existing GOAP goal.
do
  local planner = lurek.ai.newGOAPPlanner()
  planner:addGoal("target_disabled", 1.0)
  planner:setGoalState("target_disabled", "is_disabled", true)
  planner:setGoalState("target_disabled", "is_safe", true)
  lurek.log.info("goal state set", "ai")
end
--@api-stub: LInfluenceMap:setInfluence
-- Writes a value to one named-layer cell using one-based cell coordinates.
do
  local map = lurek.ai.newInfluenceMap(32, 32, 16)
  map:addLayer("hazard")
  map:setInfluence("hazard", 8, 8, 1.0)
  map:setInfluence("hazard", 9, 8, 0.5)
  lurek.log.info("hazard cell=" .. tostring(map:getInfluence("hazard", 8, 8)), "ai")
end
--@api-stub: LGOAPPlanner:setPrecondition
-- Stores a boolean requirement for an existing GOAP action.
do
  local planner = lurek.ai.newGOAPPlanner()
  planner:addAction("shoot", 1.0, function()
    lurek.log.debug("shoot action", "ai")
  end)
  planner:setPrecondition("shoot", "has_ammo", true)
  planner:setPrecondition("shoot", "has_line_of_sight", true)
  lurek.log.info("precondition set", "ai")
end
--@api-stub: LORCASolver:setPreferredVelocity
-- Sets the desired velocity for a zero-based ORCA agent before computing avoidance.
do
  local orca = lurek.ai.newORCASolver(2.0)
  local idx = orca:addAgent(100, 100, 14, 80)
  orca:setPreferredVelocity(idx, 60, 0)
  orca:compute(1 / 60)
  local vx, vy = orca:getSafeVelocity(idx)
  lurek.log.info("safe velocity=" .. tostring(vx) .. "," .. tostring(vy), "ai")
end
--@api-stub: LQLearner:setQValue
-- Stores a Q value with one-based state and action indices.
do
  local learner = lurek.ai.newQLearner(8, 4)
  learner:setQValue(1, 2, 0.85)
  learner:setQValue(2, 1, 0.25)
  local value = learner:getQValue(1, 2)
  lurek.log.info("Q(1,2)=" .. tostring(value), "ai")
end
--@api-stub: LInfluenceMap:stampInfluence
-- Applies a radial world-space influence stamp to a named layer.
do
  local map = lurek.ai.newInfluenceMap(32, 32, 16)
  map:addLayer("threat")
  map:stampInfluence("threat", 256, 256, 96, 1.0, 0.75)
  local max_x, max_y = map:getMaxPosition("threat")
  lurek.log.info("threat peak=" .. tostring(max_x) .. "," .. tostring(max_y), "ai")
end
--@api-stub: LAILod:tierFor
-- Assigns a zero-based LOD tier from agent and reference positions.
do
  local lod = lurek.ai.newAILod()
  local near_tier = lod:tierFor(350, 0, 0, 0)
  local far_tier = lod:tierFor(1200, 0, 0, 0)
  lurek.log.info("lod tiers=" .. tostring(near_tier) .. "," .. tostring(far_tier), "ai")
end
--@api-stub: LORCASolver:addAgent
-- Adds an ORCA agent and uses the returned zero-based index for later calls.
do
  local solver = lurek.ai.newORCASolver(2.0)
  local idx = solver:addAgent(200, 300, 50, 100)
  solver:setPreferredVelocity(idx, 25, 0)
  solver:compute(1 / 60)
  local vx, vy = solver:getSafeVelocity(idx)
  lurek.log.info("ORCA agent " .. tostring(idx) .. " safe=" .. tostring(vx) .. "," .. tostring(vy), "ai")
end
--@api-stub: LNeuralNet:addLayer
-- Adds layers to an empty neural net before running a forward pass.
do
  local net = lurek.ai.newNeuralNet()
  net:addLayer(2, 4, "relu")
  net:addLayer(4, 1, "linear")
  local out = net:forward({ 0.25, 0.75 })
  lurek.log.info("forward count=" .. tostring(#out), "ai")
end
--@api-stub: LAIBlackboard:setNumber
-- Stores a numeric fact under the given blackboard key
do
  local blackboard = lurek.ai.newBlackboard()
  blackboard:setNumber("health", 100)
  blackboard:setNumber("aggro_timer", 3.5)
  lurek.log.info("health=" .. tostring(blackboard:getNumber("health", 0)), "ai")
end
--@api-stub: LAIBlackboard:getNumber
-- Returns a numeric blackboard fact or the provided fallback when the key is missing or not numeric
do
  local blackboard = lurek.ai.newBlackboard()
  blackboard:setNumber("speed", 5.0)
  local speed = blackboard:getNumber("speed", 0.0)
  local missing = blackboard:getNumber("nonexistent", -1.0)
  lurek.log.info("speed=" .. tostring(speed) .. " missing=" .. tostring(missing), "ai")
end
--@api-stub: LAIBlackboard:setBool
-- Stores a boolean fact under the given blackboard key
do
  local blackboard = lurek.ai.newBlackboard()
  blackboard:setBool("is_alerted", true)
  blackboard:setBool("can_attack", false)
  lurek.log.info("alerted=" .. tostring(blackboard:getBool("is_alerted", false)), "ai")
end
--@api-stub: LAIBlackboard:getBool
-- Returns a boolean blackboard fact or the provided fallback when the key is missing or not boolean
do
  local blackboard = lurek.ai.newBlackboard()
  blackboard:setBool("player_visible", true)
  lurek.log.info("visible=" .. tostring(blackboard:getBool("player_visible", false)), "ai")
  lurek.log.info("default=" .. tostring(blackboard:getBool("unknown_key", false)), "ai")
end
--@api-stub: LAIBlackboard:setString
-- Stores a string fact under the given blackboard key
do
  local blackboard = lurek.ai.newBlackboard()
  blackboard:setString("state", "patrol")
  blackboard:setString("target_id", "player_1")
  lurek.log.info("state=" .. blackboard:getString("state", "idle"), "ai")
end
--@api-stub: LAIBlackboard:getString
-- Returns a string blackboard fact or the provided fallback when the key is missing or not a string
do
  local blackboard = lurek.ai.newBlackboard()
  blackboard:setString("last_command", "patrol_waypoint_3")
  local command = blackboard:getString("last_command", "idle")
  local fallback = blackboard:getString("missing_command", "hold")
  lurek.log.info("last_command=" .. command .. " fallback=" .. fallback, "ai")
end
--@api-stub: LAIBlackboard:has
-- Returns whether the blackboard contains any entry for the given key
do
  local blackboard = lurek.ai.newBlackboard()
  blackboard:setNumber("ammo", 12)
  blackboard:setBool("alerted", true)
  lurek.log.info("has ammo=" .. tostring(blackboard:has("ammo")), "ai")
  lurek.log.info("has route=" .. tostring(blackboard:has("route")), "ai")
end
--@api-stub: LAIBlackboard:remove
-- Removes the given key from the blackboard if it exists
do
  local blackboard = lurek.ai.newBlackboard()
  blackboard:setString("target", "raider_5")
  lurek.log.info("before remove=" .. tostring(blackboard:has("target")), "ai")
  blackboard:remove("target")
  lurek.log.info("after remove=" .. tostring(blackboard:has("target")), "ai")
end
--@api-stub: LAIBlackboard:clear
-- Removes every local entry from this blackboard
do
  local blackboard = lurek.ai.newBlackboard()
  blackboard:setNumber("hp", 80)
  blackboard:setBool("alerted", true)
  lurek.log.info("size before clear=" .. tostring(blackboard:getSize()), "ai")
  blackboard:clear()
  lurek.log.info("size after clear=" .. tostring(blackboard:getSize()), "ai")
end
--@api-stub: LAIBlackboard:getKeys
-- Returns every local blackboard key in an array-style Lua table
do
  local blackboard = lurek.ai.newBlackboard()
  blackboard:setNumber("energy", 50)
  blackboard:setBool("charging", false)
  blackboard:setString("phase", "attack")
  local keys = blackboard:getKeys()
  lurek.log.info("key count=" .. tostring(#keys), "ai")
end
--@api-stub: LAIBlackboard:getSize
-- Returns the number of entries currently stored in this blackboard
do
  local blackboard = lurek.ai.newBlackboard()
  blackboard:setNumber("x", 10)
  blackboard:setNumber("y", 20)
  blackboard:setString("label", "waypoint")
  lurek.log.info("blackboard size=" .. tostring(blackboard:getSize()), "ai")
end
--@api-stub: LAIBlackboard:type
-- Returns the Lua-visible type name for this blackboard handle
do
  local blackboard = lurek.ai.newBlackboard()
  local type_name = blackboard:type()
  lurek.log.info("LAIBlackboard:type = " .. type_name, "ai")
end
--@api-stub: LAIBlackboard:typeOf
-- Returns whether this blackboard handle matches a supported type name
do
  local blackboard = lurek.ai.newBlackboard()
  lurek.log.info("is LAIBlackboard=" .. tostring(blackboard:typeOf("LAIBlackboard")), "ai")
  lurek.log.info("is Object=" .. tostring(blackboard:typeOf("Object")), "ai")
end
--@api-stub: LAIDirector:type
-- Returns the Lua-visible type name for this AI director handle
do
  local director = lurek.ai.newAIDirector()
  director:setTension(0.6)
  local type_name = director:type()
  lurek.log.info("LAIDirector:type = " .. type_name, "ai")
end
--@api-stub: LAIDirector:typeOf
-- Returns whether this AI director handle matches a supported type name
do
  local director = lurek.ai.newAIDirector()
  lurek.log.info("is LAIDirector=" .. tostring(director:typeOf("LAIDirector")), "ai")
  lurek.log.info("is Object=" .. tostring(director:typeOf("Object")), "ai")
end
--@api-stub: LAILod:type
-- Returns the Lua-visible type name for this AI LOD handle
do
  local lod = lurek.ai.newAILod()
  local type_name = lod:type()
  lurek.log.info("LAILod:type = " .. type_name, "ai")
end
--@api-stub: LAILod:typeOf
-- Returns whether this AI LOD handle matches a supported type name
do
  local lod = lurek.ai.newAILod()
  lurek.log.info("is LAILod=" .. tostring(lod:typeOf("LAILod")), "ai")
  lurek.log.info("is Object=" .. tostring(lod:typeOf("Object")), "ai")
end
--@api-stub: LBandit:type
-- Returns the Lua-visible type name for this bandit handle
do
  local bandit = lurek.ai.newBandit(4, "ucb1", 0.1, 42)
  bandit:update(0, 0.5)
  local type_name = bandit:type()
  lurek.log.info("LBandit:type = " .. type_name, "ai")
end
--@api-stub: LBandit:typeOf
-- Returns whether this bandit handle matches a supported type name
do
  local bandit = lurek.ai.newBandit(4, "ucb1", 0.1, 42)
  lurek.log.info("is LBandit=" .. tostring(bandit:typeOf("LBandit")), "ai")
  lurek.log.info("is Object=" .. tostring(bandit:typeOf("Object")), "ai")
end
--@api-stub: LContextSteering:type
-- Returns the Lua-visible type name for this context steering handle
do
  local context = lurek.ai.newContextSteering(8)
  context:addSeekTarget(10, 0, 1.0)
  local type_name = context:type()
  lurek.log.info("LContextSteering:type = " .. type_name, "ai")
end
--@api-stub: LContextSteering:typeOf
-- Returns whether this context steering handle matches a supported type name
do
  local context = lurek.ai.newContextSteering(8)
  lurek.log.info("is LContextSteering=" .. tostring(context:typeOf("LContextSteering")), "ai")
  lurek.log.info("is Object=" .. tostring(context:typeOf("Object")), "ai")
end
--@api-stub: LEmotionModel:type
-- Returns the Lua-visible type name for this emotion model handle
do
  local emotions = lurek.ai.newEmotionModel()
  emotions:add("focus", 0.0, 0.05, 0.4)
  local type_name = emotions:type()
  lurek.log.info("LEmotionModel:type = " .. type_name, "ai")
end
--@api-stub: LEmotionModel:typeOf
-- Returns whether this emotion model handle matches a supported type name
do
  local emotions = lurek.ai.newEmotionModel()
  lurek.log.info("is LEmotionModel=" .. tostring(emotions:typeOf("LEmotionModel")), "ai")
  lurek.log.info("is Object=" .. tostring(emotions:typeOf("Object")), "ai")
end
--@api-stub: LGeneticAlgorithm:type
-- Returns the Lua-visible type name for this genetic algorithm handle
do
  local genetic = lurek.ai.newGeneticAlgorithm(20, 8, 42)
  genetic:setFitness(0, 0.75)
  local type_name = genetic:type()
  lurek.log.info("LGeneticAlgorithm:type = " .. type_name, "ai")
end
--@api-stub: LGeneticAlgorithm:typeOf
-- Returns whether this genetic algorithm handle matches a supported type name
do
  local genetic = lurek.ai.newGeneticAlgorithm(20, 8, 42)
  lurek.log.info("is LGeneticAlgorithm=" .. tostring(genetic:typeOf("LGeneticAlgorithm")), "ai")
  lurek.log.info("is Object=" .. tostring(genetic:typeOf("Object")), "ai")
end
--@api-stub: LHTNDomain:type
-- Returns the Lua-visible type name for this HTN domain handle
do
  local domain = lurek.ai.newHTNDomain()
  domain:addPrimitive("wait", {}, {}, {})
  local type_name = domain:type()
  lurek.log.info("LHTNDomain:type = " .. type_name, "ai")
end
--@api-stub: LHTNDomain:typeOf
-- Returns whether this HTN domain handle matches a supported type name
do
  local domain = lurek.ai.newHTNDomain()
  lurek.log.info("is LHTNDomain=" .. tostring(domain:typeOf("LHTNDomain")), "ai")
  lurek.log.info("is Object=" .. tostring(domain:typeOf("Object")), "ai")
end
--@api-stub: LMCTSEngine:type
-- Returns the Lua-visible type name for this MCTS engine handle
do
  local mcts = lurek.ai.newMCTSEngine(100, 1.41, 5, 42)
  local type_name = mcts:type()
  lurek.log.info("LMCTSEngine:type = " .. type_name, "ai")
end
--@api-stub: LMCTSEngine:typeOf
-- Returns whether this MCTS engine handle matches a supported type name
do
  local mcts = lurek.ai.newMCTSEngine(100, 1.41, 5, 42)
  lurek.log.info("is LMCTSEngine=" .. tostring(mcts:typeOf("LMCTSEngine")), "ai")
  lurek.log.info("is Object=" .. tostring(mcts:typeOf("Object")), "ai")
end
--@api-stub: LNeedSystem:type
-- Returns the Lua-visible type name for this need system handle
do
  local needs = lurek.ai.newNeedSystem()
  needs:addNeed("hunger", 0.05, 0.7, 1.0)
  local type_name = needs:type()
  lurek.log.info("LNeedSystem:type = " .. type_name, "ai")
end
--@api-stub: LNeedSystem:typeOf
-- Returns whether this need system handle matches a supported type name
do
  local needs = lurek.ai.newNeedSystem()
  lurek.log.info("is LNeedSystem=" .. tostring(needs:typeOf("LNeedSystem")), "ai")
  lurek.log.info("is Object=" .. tostring(needs:typeOf("Object")), "ai")
end
--@api-stub: LNeuralNet:type
-- Returns the Lua-visible type name for this neural network handle
do
  local network = lurek.ai.newNeuralNet()
  network:addLayer(2, 1, "linear")
  local type_name = network:type()
  lurek.log.info("LNeuralNet:type = " .. type_name, "ai")
end
--@api-stub: LNeuralNet:typeOf
-- Returns whether this neural network handle matches a supported type name
do
  local network = lurek.ai.newNeuralNet()
  lurek.log.info("is LNeuralNet=" .. tostring(network:typeOf("LNeuralNet")), "ai")
  lurek.log.info("is Object=" .. tostring(network:typeOf("Object")), "ai")
end
--@api-stub: LNeuroevolution:type
-- Returns the Lua-visible type name for this neuroevolution handle
do
  local layers = { { inputs = 4, outputs = 8, activation = "relu" }, { inputs = 8, outputs = 4, activation = "softmax" } }
  local evolution = lurek.ai.newNeuroevolution(layers, 20, 42)
  local type_name = evolution:type()
  lurek.log.info("LNeuroevolution:type = " .. type_name, "ai")
end
--@api-stub: LNeuroevolution:typeOf
-- Returns whether this neuroevolution handle matches a supported type name
do
  local layers = { { inputs = 4, outputs = 8, activation = "relu" }, { inputs = 8, outputs = 4, activation = "softmax" } }
  local evolution = lurek.ai.newNeuroevolution(layers, 20, 42)
  lurek.log.info("is LNeuroevolution=" .. tostring(evolution:typeOf("LNeuroevolution")), "ai")
  lurek.log.info("is Object=" .. tostring(evolution:typeOf("Object")), "ai")
end
--@api-stub: LORCASolver:type
-- Returns the Lua-visible type name for this ORCA solver handle
do
  local solver = lurek.ai.newORCASolver(0.5)
  solver:addAgent(0, 0, 10, 60)
  local type_name = solver:type()
  lurek.log.info("LORCASolver:type = " .. type_name, "ai")
end
--@api-stub: LORCASolver:typeOf
-- Returns whether this ORCA solver handle matches a supported type name
do
  local solver = lurek.ai.newORCASolver(0.5)
  lurek.log.info("is LORCASolver=" .. tostring(solver:typeOf("LORCASolver")), "ai")
  lurek.log.info("is Object=" .. tostring(solver:typeOf("Object")), "ai")
end
--@api-stub: LStimulusWorld:type
-- Returns the Lua-visible type name for this stimulus world handle
do
  local stimuli = lurek.ai.newStimulusWorld()
  stimuli:addVisual(10, 20, 1.0, 80, "movement")
  local type_name = stimuli:type()
  lurek.log.info("LStimulusWorld:type = " .. type_name, "ai")
end
--@api-stub: LStimulusWorld:typeOf
-- Returns whether this stimulus world handle matches a supported type name
do
  local stimuli = lurek.ai.newStimulusWorld()
  lurek.log.info("is LStimulusWorld=" .. tostring(stimuli:typeOf("LStimulusWorld")), "ai")
  lurek.log.info("is Object=" .. tostring(stimuli:typeOf("Object")), "ai")
end
--@api-stub: LStrategyAI:type
-- Returns the Lua-visible type name for this strategy AI handle
do
  local strategy = lurek.ai.newStrategyAI(0.25)
  strategy:addGoal("patrol")
  local type_name = strategy:type()
  lurek.log.info("LStrategyAI:type = " .. type_name, "ai")
end
--@api-stub: LStrategyAI:typeOf
-- Returns whether this strategy AI handle matches a supported type name
do
  local strategy = lurek.ai.newStrategyAI(0.25)
  lurek.log.info("is LStrategyAI=" .. tostring(strategy:typeOf("LStrategyAI")), "ai")
  lurek.log.info("is Object=" .. tostring(strategy:typeOf("Object")), "ai")
end
--@api-stub: LTraitProfile:type
-- Returns the Lua-visible type name for this trait profile handle
do
  local traits = lurek.ai.newTraitProfile()
  traits:set("courage", 0.5)
  local type_name = traits:type()
  lurek.log.info("LTraitProfile:type = " .. type_name, "ai")
end
--@api-stub: LTraitProfile:typeOf
-- Returns whether this trait profile handle matches a supported type name
do
  local traits = lurek.ai.newTraitProfile()
  lurek.log.info("is LTraitProfile=" .. tostring(traits:typeOf("LTraitProfile")), "ai")
  lurek.log.info("is Object=" .. tostring(traits:typeOf("Object")), "ai")
end
--@api-stub: LBTNode:addChild
-- Adds child nodes to a composite selector, sequence, or parallel node.
do
  local seq = lurek.ai.newSequence()
  local check_hp = lurek.ai.newCondition(function() return true end)
  local attack = lurek.ai.newAction(function() return "success" end)
  seq:addChild(check_hp)
  seq:addChild(attack)
  local bt = lurek.ai.newBehaviorTree()
  bt:setRoot(seq)
  lurek.log.debug("sequence children=" .. tostring(seq:getChildCount()), "ai")
end
--@api-stub: lurek.ai.newInverter
-- Creates an inverter decorator node and attaches a single child with setChild.
do
  local action = lurek.ai.newAction(function() return "failure" end)
  local inverter = lurek.ai.newInverter()
  inverter:setChild(action)
  local bt = lurek.ai.newBehaviorTree()
  bt:setRoot(inverter)
  lurek.log.debug("inverter node type=" .. inverter:getNodeType(), "ai")
end
--@api-stub: lurek.ai.newAction
-- Creates an action leaf callback that returns a behavior-tree status string.
do
  local leaf = lurek.ai.newAction(function()
    return "success"
  end)
  local bt = lurek.ai.newBehaviorTree()
  bt:setRoot(leaf)
  lurek.log.debug("action node type=" .. leaf:getNodeType(), "ai")
end
--@api-stub: lurek.ai.newParallel
-- Creates a parallel composite with explicit success and failure policies.
do
  local par = lurek.ai.newParallel("requireAll", "requireOne")
  local patrol = lurek.ai.newAction(function() return "running" end)
  local scan = lurek.ai.newAction(function() return "success" end)
  par:addChild(patrol)
  par:addChild(scan)
  local bt = lurek.ai.newBehaviorTree()
  bt:setRoot(par)
  lurek.log.debug("parallel children=" .. tostring(par:getChildCount()), "ai")
end
--@api-stub: lurek.ai.newRepeater
-- Creates a repeater decorator with an optional repeat count.
do
  local action = lurek.ai.newAction(function() return "success" end)
  local repeater = lurek.ai.newRepeater(3)
  repeater:setChild(action)
  local bt = lurek.ai.newBehaviorTree()
  bt:setRoot(repeater)
  lurek.log.debug("repeater count=" .. tostring(repeater:getCount()), "ai")
end
--@api-stub: lurek.ai.newSelector
-- Creates a selector composite that tries children until one succeeds.
do
  local selector = lurek.ai.newSelector()
  local preferred = lurek.ai.newAction(function() return "failure" end)
  local fallback = lurek.ai.newAction(function() return "success" end)
  selector:addChild(preferred)
  selector:addChild(fallback)
  local bt = lurek.ai.newBehaviorTree()
  bt:setRoot(selector)
  lurek.log.debug("selector children=" .. tostring(selector:getChildCount()), "ai")
end
--@api-stub: lurek.ai.newSequence
-- Creates a sequence composite that runs children in order.
do
  local seq = lurek.ai.newSequence()
  local step1 = lurek.ai.newAction(function() return "success" end)
  local step2 = lurek.ai.newAction(function() return "success" end)
  seq:addChild(step1)
  seq:addChild(step2)
  local bt = lurek.ai.newBehaviorTree()
  bt:setRoot(seq)
  lurek.log.debug("sequence children=" .. tostring(seq:getChildCount()), "ai")
end
--@api-stub: LInfluenceMap:clearAll
-- Clears every value from every influence-map layer.
do
  local map = lurek.ai.newInfluenceMap(16, 16, 32)
  map:addLayer("danger")
  map:addLayer("resource")
  map:setInfluence("danger", 4, 4, 1.0)
  map:setInfluence("resource", 5, 5, 0.8)
  map:clearAll()
  lurek.log.debug("danger after clear=" .. tostring(map:getInfluence("danger", 4, 4)), "ai")
end
--@api-stub: LBTNode:getChildCount
-- Returns the direct child count for composite behavior-tree nodes.
do
  local seq = lurek.ai.newSequence()
  seq:addChild(lurek.ai.newAction(function() return "success" end))
  seq:addChild(lurek.ai.newAction(function() return "success" end))
  lurek.log.debug("seq childCount=" .. tostring(seq:getChildCount()), "ai")
end
--@api-stub: LBTNode:reset
-- Resets one behavior-tree node's runtime state.
do
  local seq = lurek.ai.newSequence()
  local action = lurek.ai.newAction(function() return "running" end)
  seq:addChild(action)
  seq:reset()
  action:reset()
  local bt = lurek.ai.newBehaviorTree()
  bt:setRoot(seq)
  lurek.log.debug("node execution state reset", "ai")
end
--@api-stub: LBTNode:setChild
-- Replaces the single child on a decorator node such as an inverter or repeater.
do
  local first_action = lurek.ai.newAction(function() return "success" end)
  local replacement = lurek.ai.newAction(function() return "running" end)
  local inverter = lurek.ai.newInverter()
  inverter:setChild(first_action)
  inverter:setChild(replacement)
  local bt = lurek.ai.newBehaviorTree()
  bt:setRoot(inverter)
  lurek.log.debug("leaf swapped via setChild()", "ai")
end
--@api-stub: LBehaviorTree:getDebugState
-- Reads behavior-tree debug fields after the root has been assigned.
do
  local seq = lurek.ai.newSequence()
  seq:addChild(lurek.ai.newAction(function() return "success" end))
  local bt = lurek.ai.newBehaviorTree()
  bt:setRoot(seq)
  local debug_state = bt:getDebugState()
  lurek.log.debug("BT nodes=" .. tostring(debug_state.node_count) .. " status=" .. tostring(debug_state.last_status), "ai")
end
--@api-stub: LDialogueAI:addBranch
-- Adds a response branch with a label and condition to a topic in this dialogue AI.
do
  local dialogue = lurek.ai.newDialogueAI()
  dialogue:setFSMState("idle")
  dialogue:setUtilityScore("rapport", 0.8)
  dialogue:addTopic("greet", 1.0, "idle", nil, "rapport")
  local added = dialogue:addBranch("greet", "friendly", 1.0, "idle", nil, "rapport")
  lurek.log.debug("branch added=" .. tostring(added), "ai")
end
--@api-stub: LDialogueAI:addTopic
-- Adds a named dialogue topic to this dialogue AI for later selection.
do
  local dialogue = lurek.ai.newDialogueAI()
  dialogue:addTopic("greet", 1.0, nil, nil, "rapport")
  dialogue:setUtilityScore("rapport", 0.7)
  lurek.log.debug("topics=" .. tostring(dialogue:getTopicCount()), "ai")
end
--@api-stub: LDialogueAI:clearUtilityScores
-- Resets all utility scores in this dialogue AI to zero.
do
  local dialogue = lurek.ai.newDialogueAI()
  dialogue:addTopic("greet", 1.0, nil, nil, "rapport")
  dialogue:setUtilityScore("rapport", 1.0)
  dialogue:clearUtilityScores()
  lurek.log.debug("topic after clear=" .. tostring(dialogue:selectTopic()), "ai")
end
--@api-stub: LDialogueAI:getTopicCount
-- Returns the number of topics currently registered in this dialogue AI.
do
  local dialogue = lurek.ai.newDialogueAI()
  dialogue:addTopic("greet", 1.0)
  dialogue:addTopic("trade", 0.5)
  lurek.log.debug("topics=" .. tostring(dialogue:getTopicCount()), "ai")
end
--@api-stub: LDialogueAI:selectBranch
-- Selects the highest-scoring active branch for a topic and returns its label.
do
  local dialogue = lurek.ai.newDialogueAI()
  dialogue:addTopic("greet", 1.0)
  dialogue:addBranch("greet", "friendly", 1.0)
  dialogue:addBranch("greet", "brief", 0.5)
  local branch = dialogue:selectBranch("greet")
  lurek.log.debug("branch=" .. tostring(branch), "ai")
end
--@api-stub: LDialogueAI:selectTopic
-- Returns the topic with the highest utility score that passes its condition.
do
  local dialogue = lurek.ai.newDialogueAI()
  dialogue:addTopic("greet", 1.0, nil, nil, "rapport")
  dialogue:addTopic("trade", 0.5)
  dialogue:setUtilityScore("rapport", 0.9)
  local topic = dialogue:selectTopic()
  lurek.log.debug("topic=" .. tostring(topic), "ai")
end
--@api-stub: LDialogueAI:setBTStatus
-- Sets the behavior tree status used as context for dialogue condition evaluation.
do
  local dialogue = lurek.ai.newDialogueAI()
  dialogue:setBTStatus("running")
  dialogue:addTopic("while_running", 1.0, nil, "running", nil)
  lurek.log.debug("bt topic=" .. tostring(dialogue:selectTopic()), "ai")
end
--@api-stub: LDialogueAI:setFSMState
-- Sets the FSM state name used as context for dialogue condition evaluation.
do
  local dialogue = lurek.ai.newDialogueAI()
  dialogue:setFSMState("combat")
  dialogue:addTopic("combat_bark", 1.0, "combat", nil, nil)
  lurek.log.debug("fsm topic=" .. tostring(dialogue:selectTopic()), "ai")
end
--@api-stub: LDialogueAI:setUtilityScore
-- Sets the utility score for a named topic in this dialogue AI.
do
  local dialogue = lurek.ai.newDialogueAI()
  dialogue:addTopic("greet", 1.0, nil, nil, "rapport")
  dialogue:setUtilityScore("rapport", 0.8)
  lurek.log.debug("utility topic=" .. tostring(dialogue:selectTopic()), "ai")
end
--@api-stub: LDialogueAI:type
-- Returns the Lua-visible type name string for this dialogue AI handle.
do
  local dialogue = lurek.ai.newDialogueAI()
  dialogue:addTopic("greet", 1.0)
  lurek.log.info(dialogue:type(), "ai")
end
--@api-stub: LDialogueAI:typeOf
-- Returns true if this dialogue AI handle matches the given type name string.
do
  local dialogue = lurek.ai.newDialogueAI()
  lurek.log.info("is DialogueAI=" .. tostring(dialogue:typeOf("DialogueAI")), "ai")
  lurek.log.info("is Object=" .. tostring(dialogue:typeOf("Object")), "ai")
end
--@api-stub: LSteeringManager:clearPath
-- Clears the current movement path from this steering manager.
do
  local steering = lurek.ai.newSteeringManager()
  steering:setPath({ { x = 0, y = 0 }, { x = 100, y = 0 } }, 12, 1.0)
  lurek.log.debug("has path before clear=" .. tostring(steering:hasPath()), "ai")
  steering:clearPath()
  lurek.log.debug("has path after clear=" .. tostring(steering:hasPath()), "ai")
end
--@api-stub: LSteeringManager:getPathProgress
-- Returns the current one-based waypoint index and total waypoint count.
do
  local steering = lurek.ai.newSteeringManager()
  steering:setPath({ { x = 0, y = 0 }, { x = 50, y = 0 }, { x = 100, y = 0 } }, 10, 1.0)
  local current, total = steering:getPathProgress()
  lurek.log.debug("path progress=" .. tostring(current) .. "/" .. tostring(total), "ai")
end
--@api-stub: LSteeringManager:hasPath
-- Returns true if this steering manager currently has a path to follow.
do
  local steering = lurek.ai.newSteeringManager()
  lurek.log.debug("initial path=" .. tostring(steering:hasPath()), "ai")
  steering:setPath({ { x = 0, y = 0 }, { x = 32, y = 32 } }, 8, 1.0)
  lurek.log.debug("configured path=" .. tostring(steering:hasPath()), "ai")
end
--@api-stub: LSteeringManager:setPath
-- Sets the waypoint path for this steering manager to follow.
do
  local steering = lurek.ai.newSteeringManager()
  steering:setPath({ { x = 0, y = 0 }, { x = 100, y = 0 }, { x = 100, y = 100 } }, 12, 1.0)
  local fx, fy = steering:calculate(0, 0, 0, 0, 120, 40, 1 / 60)
  lurek.log.debug("path force=" .. tostring(fx) .. "," .. tostring(fy), "ai")
end
--@api-stub: LAIDirector:update
-- Advances director tension decay and phase evaluation.
do
  local director = lurek.ai.newAIDirector()
  director:setTension(0.8)
  director:update(0.5)
  lurek.log.info("tension after decay=" .. tostring(director:tension()), "ai")
  lurek.log.debug("director phase=" .. tostring(director:phase()), "ai")
end
--@api-stub: LAIDirector:reset
-- Resets director tension and phase state to defaults.
do
  local director = lurek.ai.newAIDirector()
  director:setTension(0.9)
  director:reset()
  lurek.log.info("tension after reset=" .. tostring(director:tension()), "ai")
end
--@api-stub: LAIWorld:addAgent
-- Creates a named agent in this world and returns a handle that can edit its movement and decision state.
do
  local world = lurek.ai.newWorld()
  local guard = world:addAgent("patrol_guard")
  guard:setPosition(200, 150)
  guard:setDecisionModel("fsm")
  lurek.log.info("spawned agent=" .. guard:getName() .. " count=" .. tostring(world:getAgentCount()), "ai")
end
--@api-stub: LAIWorld:update
-- Advances the world simulation and invokes custom decision callbacks for agents that use a custom model.
do
  local world = lurek.ai.newWorld()
  local sentry = world:addAgent("sentry_a")
  sentry:setCustomModel(function(agent, blackboard, dt)
    agent:setVelocity(10 * dt, 0)
  end)
  world:addAgent("sentry_b")
  world:update(0.016)
  local vx, vy = sentry:getVelocity()
  lurek.log.info("world ticked agents=" .. tostring(world:getAgentCount()) .. " sentry_v=" .. tostring(vx) .. "," .. tostring(vy), "ai")
end
--@api-stub: LAIWorld:type
-- Returns the Lua-visible type name for this AI world handle.
do
  local world = lurek.ai.newWorld()
  world:addAgent("type_probe")
  lurek.log.info("world type=" .. world:type(), "ai")
end
--@api-stub: LAIWorld:typeOf
-- Returns whether this AI world handle matches a supported type name.
do
  local world = lurek.ai.newWorld()
  lurek.log.info("is AIWorld=" .. tostring(world:typeOf("AIWorld")), "ai")
  lurek.log.info("is Object=" .. tostring(world:typeOf("Object")), "ai")
end
--@api-stub: LAgent:getName
-- Returns this agent's stable world name.
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("merchant_01")
  npc:addTag("vendor")
  lurek.log.info("agent name=" .. npc:getName(), "ai")
end
--@api-stub: LAgent:setPosition
-- Sets this agent's world position when the agent still exists in its world.
do
  local world = lurek.ai.newWorld()
  local guard = world:addAgent("gate_guard")
  guard:setPosition(400, 300)
  local x, y = guard:getPosition()
  lurek.log.info("guard at=" .. tostring(x) .. "," .. tostring(y), "ai")
end
--@api-stub: LAgent:addTag
-- Adds a tag string to this agent when the agent still exists in its world.
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("villager")
  npc:addTag("civilian")
  npc:addTag("quest_giver")
  lurek.log.info("has quest tag=" .. tostring(npc:hasTag("quest_giver")), "ai")
end
--@api-stub: LAgent:removeTag
-- Removes a tag string from this agent when the agent still exists in its world.
do
  local world = lurek.ai.newWorld()
  local enemy = world:addAgent("raider")
  enemy:addTag("hostile")
  enemy:removeTag("hostile")
  lurek.log.info("raider hostile=" .. tostring(enemy:hasTag("hostile")), "ai")
end
--@api-stub: LAgent:getBlackboard
-- Returns a blackboard snapshot for this agent or an empty blackboard when the agent has been removed.
do
  local world = lurek.ai.newWorld()
  local guard = world:addAgent("wall_guard")
  local blackboard = guard:getBlackboard()
  blackboard:setNumber("waypoint_idx", 0)
  lurek.log.info("blackboard snapshot size=" .. tostring(blackboard:getSize()), "ai")
end
--@api-stub: LAgent:type
-- Returns the Lua-visible type name for this agent handle.
do
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("test_agent")
  agent:setPriority(3)
  lurek.log.info("agent type=" .. agent:type(), "ai")
end
--@api-stub: LAgent:typeOf
-- Returns whether this agent handle matches a supported type name.
do
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("test_agent")
  lurek.log.info("is Agent=" .. tostring(agent:typeOf("Agent")), "ai")
  lurek.log.info("is Object=" .. tostring(agent:typeOf("Object")), "ai")
end
--@api-stub: LBTNode:reset
-- Resets this behavior tree node's runtime state.
do
  local seq = lurek.ai.newSequence()
  seq:addChild(lurek.ai.newAction(function() return "running" end))
  seq:reset()
  lurek.log.info("sequence node state cleared", "ai")
end
--@api-stub: LBTNode:getCount
-- Returns the repeat count for repeater nodes or zero for other node kinds.
do
  local repeater = lurek.ai.newRepeater(3)
  repeater:setCount(5)
  lurek.log.info("repeater count=" .. tostring(repeater:getCount()), "ai")
end
--@api-stub: LBTNode:type
-- Returns the Lua-visible type name for this behavior tree node handle.
do
  local action = lurek.ai.newAction(function() return "success" end)
  lurek.log.info("node type=" .. action:type(), "ai")
end
--@api-stub: LBTNode:typeOf
-- Returns whether this behavior tree node handle matches a supported type name.
do
  local selector = lurek.ai.newSelector()
  lurek.log.info("is BTNode=" .. tostring(selector:typeOf("BTNode")), "ai")
  lurek.log.info("is Object=" .. tostring(selector:typeOf("Object")), "ai")
end
--@api-stub: LBandit:update
-- Updates one arm with a received reward.
do
  local bandit = lurek.ai.newBandit(4, "ucb1", 0.1, 99)
  local arm = bandit:select()
  bandit:update(arm, 0.8)
  lurek.log.info("updated arm " .. tostring(arm) .. " pulls=" .. tostring(bandit:totalPulls()), "ai")
end
--@api-stub: LBehaviorTree:type
-- Returns the Lua-visible type name for this behavior tree handle.
do
  local bt = lurek.ai.newBehaviorTree()
  bt:setRoot(lurek.ai.newSequence())
  lurek.log.info("bt type=" .. bt:type(), "ai")
end
--@api-stub: LBehaviorTree:typeOf
-- Returns whether this behavior tree handle matches a supported type name.
do
  local bt = lurek.ai.newBehaviorTree()
  lurek.log.info("is BehaviorTree=" .. tostring(bt:typeOf("BehaviorTree")), "ai")
  lurek.log.info("is Object=" .. tostring(bt:typeOf("Object")), "ai")
end
--@api-stub: LCommandQueue:clear
-- Removes every queued command. This method is available to Lua scripts.
do
  local queue = lurek.ai.newCommandQueue()
  queue:enqueue("slam", function() end, { targetX = 0, targetY = 0 })
  queue:enqueue("roar", function() end, { targetX = 40, targetY = 0 })
  queue:clear()
  lurek.log.info("queue cleared empty=" .. tostring(queue:isEmpty()), "ai")
end
--@api-stub: LCommandQueue:type
-- Returns the Lua-visible type name for this command queue handle.
do
  local queue = lurek.ai.newCommandQueue()
  queue:enqueue("wait", function() end, { targetX = 0, targetY = 0 })
  lurek.log.info("queue type=" .. queue:type(), "ai")
end
--@api-stub: LCommandQueue:typeOf
-- Returns whether this command queue handle matches a supported type name.
do
  local queue = lurek.ai.newCommandQueue()
  lurek.log.info("is CommandQueue=" .. tostring(queue:typeOf("CommandQueue")), "ai")
  lurek.log.info("is Object=" .. tostring(queue:typeOf("Object")), "ai")
end
--@api-stub: LEmotionModel:update
-- Advances emotion decay over elapsed time.
do
  local emotions = lurek.ai.newEmotionModel()
  emotions:add("fear", 0.0, 0.1, 0.5)
  emotions:trigger("fear", 0.8)
  emotions:update(1.0)
  lurek.log.info("fear after decay=" .. tostring(emotions:get("fear")), "ai")
end
--@api-stub: LEmotionModel:reset
-- Resets all emotions toward their default state.
do
  local emotions = lurek.ai.newEmotionModel()
  emotions:add("anger", 0.0, 0.05, 0.5)
  emotions:trigger("anger", 0.9)
  emotions:reset()
  lurek.log.info("anger after reset=" .. tostring(emotions:get("anger")), "ai")
end
--@api-stub: LGOAPPlanner:addGoal
-- Adds a GOAP goal with an optional priority weight.
do
  local planner = lurek.ai.newGOAPPlanner()
  planner:addAction("eat", 1.0, function()
    lurek.log.debug("eat action", "ai")
  end)
  planner:setEffect("eat", "not_hungry", true)
  planner:addGoal("not_hungry", 2.0)
  planner:addGoal("is_rested", 1.0)
  planner:setGoalState("not_hungry", "not_hungry", true)
  lurek.log.info("goals=" .. tostring(planner:getGoalCount()), "ai")
end
--@api-stub: LGOAPPlanner:plan
-- Builds a plan from the supplied boolean world state and returns action names in execution order.
do
  local planner = lurek.ai.newGOAPPlanner()
  planner:addAction("get_weapon", 1.0, function()
    lurek.log.debug("get weapon", "ai")
  end)
  planner:setPrecondition("get_weapon", "has_weapon", false)
  planner:setEffect("get_weapon", "has_weapon", true)
  planner:addAction("attack", 2.0, function()
    lurek.log.debug("attack", "ai")
  end)
  planner:setPrecondition("attack", "has_weapon", true)
  planner:setEffect("attack", "target_disabled", true)
  planner:addGoal("target_disabled", 1.0)
  planner:setGoalState("target_disabled", "target_disabled", true)
  local plan = planner:plan({ has_weapon = false, target_disabled = false }, 6)
  lurek.log.info("plan steps=" .. tostring(plan and #plan or 0), "ai")
end
--@api-stub: LGOAPPlanner:type
-- Returns the Lua-visible type name for this GOAP planner handle.
do
  local planner = lurek.ai.newGOAPPlanner()
  planner:addGoal("probe", 1.0)
  lurek.log.info("planner type=" .. planner:type(), "ai")
end
--@api-stub: LGOAPPlanner:typeOf
-- Returns whether this GOAP planner handle matches a supported type name.
do
  local planner = lurek.ai.newGOAPPlanner()
  lurek.log.info("is GOAPPlanner=" .. tostring(planner:typeOf("GOAPPlanner")), "ai")
  lurek.log.info("is Object=" .. tostring(planner:typeOf("Object")), "ai")
end
--@api-stub: LGeneticAlgorithm:evolve
-- Advances the genetic algorithm by one generation.
do
  local ga = lurek.ai.newGeneticAlgorithm(20, 8, 42)
  for i = 0, ga:popSize() - 1 do
    ga:setFitness(i, (i + 1) / ga:popSize())
  end
  ga:evolve()
  lurek.log.info("generation after evolve=" .. tostring(ga:generation()), "ai")
end
--@api-stub: LGeneticAlgorithm:generation
-- Returns the current generation index.
do
  local ga = lurek.ai.newGeneticAlgorithm(10, 4, 7)
  ga:setFitness(0, 1.0)
  lurek.log.info("initial generation=" .. tostring(ga:generation()), "ai")
end
--@api-stub: LGeneticAlgorithm:popSize
-- Returns the population size. This method is available to Lua scripts.
do
  local ga = lurek.ai.newGeneticAlgorithm(30, 8, 42)
  for i = 0, ga:popSize() - 1 do
    ga:setFitness(i, i / ga:popSize())
  end
  lurek.log.info("population=" .. tostring(ga:popSize()), "ai")
end
--@api-stub: LGeneticAlgorithm:setFitness
-- Sets the fitness value for a chromosome by zero-based index.
do
  local ga = lurek.ai.newGeneticAlgorithm(10, 4, 42)
  ga:setFitness(0, 0.95)
  ga:setFitness(1, 0.3)
  lurek.log.info("best chromosome genes=" .. tostring(#ga:bestGenes()), "ai")
end
--@api-stub: LInfluenceMap:addLayer
-- Adds an influence layer with the given name if it does not already exist.
do
  local map = lurek.ai.newInfluenceMap(32, 32, 16)
  map:addLayer("threat")
  map:addLayer("resources")
  map:setInfluence("threat", 4, 4, 0.7)
  lurek.log.info("has threat=" .. tostring(map:hasLayer("threat")), "ai")
end
--@api-stub: LInfluenceMap:type
-- Returns the Lua-visible type name for this influence map handle.
do
  local map = lurek.ai.newInfluenceMap(16, 16, 32)
  map:addLayer("probe")
  lurek.log.info("influence map type=" .. map:type(), "ai")
end
--@api-stub: LInfluenceMap:typeOf
-- Returns whether this influence map handle matches a supported type name.
do
  local map = lurek.ai.newInfluenceMap(16, 16, 32)
  lurek.log.info("is InfluenceMap=" .. tostring(map:typeOf("InfluenceMap")), "ai")
  lurek.log.info("is Object=" .. tostring(map:typeOf("Object")), "ai")
end
--@api-stub: LNeedSystem:update
-- Advances need decay over elapsed time.
do
  local needs = lurek.ai.newNeedSystem()
  needs:addNeed("hunger", 0.1, 0.7, 1.5)
  needs:update(2.0)
  lurek.log.info("hunger after update=" .. tostring(needs:valueOf("hunger")), "ai")
end
--@api-stub: LQLearner:getActionCount
-- Returns the number of actions represented by this learner.
do
  local learner = lurek.ai.newQLearner(8, 4)
  learner:setQValue(1, 1, 0.2)
  lurek.log.info("actions=" .. tostring(learner:getActionCount()), "ai")
end
--@api-stub: LQLearner:type
-- Returns the Lua-visible type name for this Q-learner handle.
do
  local learner = lurek.ai.newQLearner(4, 2)
  learner:setLearningRate(0.2)
  lurek.log.info("learner type=" .. learner:type(), "ai")
end
--@api-stub: LQLearner:typeOf
-- Returns whether this Q-learner handle matches a supported type name.
do
  local learner = lurek.ai.newQLearner(4, 2)
  lurek.log.info("is QLearner=" .. tostring(learner:typeOf("QLearner")), "ai")
  lurek.log.info("is Object=" .. tostring(learner:typeOf("Object")), "ai")
end
--@api-stub: LSquad:type
-- Returns the Lua-visible type name for this squad handle.
do
  local squad = lurek.ai.newSquad("bravo")
  squad:addMember("guard_01")
  lurek.log.info("squad type=" .. squad:type(), "ai")
end
--@api-stub: LSquad:typeOf
-- Returns whether this squad handle matches a supported type name.
do
  local squad = lurek.ai.newSquad("bravo")
  lurek.log.info("is Squad=" .. tostring(squad:typeOf("Squad")), "ai")
  lurek.log.info("is Object=" .. tostring(squad:typeOf("Object")), "ai")
end
--@api-stub: LStateMachine:type
-- Returns the Lua-visible type name for this state machine handle.
do
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("idle", {})
  lurek.log.info("fsm type=" .. fsm:type(), "ai")
end
--@api-stub: LStateMachine:typeOf
-- Returns whether this state machine handle matches a supported type name.
do
  local fsm = lurek.ai.newStateMachine()
  lurek.log.info("is StateMachine=" .. tostring(fsm:typeOf("StateMachine")), "ai")
  lurek.log.info("is Object=" .. tostring(fsm:typeOf("Object")), "ai")
end
--@api-stub: LSteeringManager:addWander
-- Adds a wander behavior that produces jittered exploratory movement.
do
  local steering = lurek.ai.newSteeringManager()
  steering:addWander(20, 40, 5, 0.4)
  local fx, fy = steering:calculate(100, 100, 0, 0, 80, 30, 1 / 60)
  lurek.log.info("wander force=" .. tostring(fx) .. "," .. tostring(fy), "ai")
end
--@api-stub: LSteeringManager:type
-- Returns the Lua-visible type name for this steering manager handle.
do
  local steering = lurek.ai.newSteeringManager()
  steering:addSeek(10, 20, 1.0)
  lurek.log.info("steering type=" .. steering:type(), "ai")
end
--@api-stub: LSteeringManager:typeOf
-- Returns whether this steering manager handle matches a supported type name.
do
  local steering = lurek.ai.newSteeringManager()
  lurek.log.info("is SteeringManager=" .. tostring(steering:typeOf("SteeringManager")), "ai")
  lurek.log.info("is Object=" .. tostring(steering:typeOf("Object")), "ai")
end
--@api-stub: LStimulusWorld:update
-- Advances stimulus decay and lifetime state.
do
  local stimuli = lurek.ai.newStimulusWorld()
  local id = stimuli:addAuditory(100, 200, 1.0, 150, 0.5, "alert")
  stimuli:update(1.0)
  lurek.log.info("stimuli after update=" .. tostring(stimuli:count()) .. " first=" .. tostring(id), "ai")
end
--@api-stub: LTraitProfile:get
-- Returns the current value of a named trait including active modifiers.
do
  local traits = lurek.ai.newTraitProfile()
  traits:set("courage", 0.5)
  traits:addModifier("courage", 0.3, 10.0, "battle_cry")
  lurek.log.info("effective courage=" .. tostring(traits:get("courage")), "ai")
end
--@api-stub: LTraitProfile:update
-- Advances modifier timers and removes expired modifiers.
do
  local traits = lurek.ai.newTraitProfile()
  traits:set("aggression", 0.4)
  traits:addModifier("aggression", 0.5, 2.0, "rage")
  traits:update(3.0)
  lurek.log.info("aggression after update=" .. tostring(traits:get("aggression")), "ai")
end
--@api-stub: LUtilityAI:addAction
-- Adds an action scored by a Lua callback and optional momentum weight.
do
  local utility = lurek.ai.newUtilityAI()
  utility:addAction("patrol", function() return 0.3 end, 1.0)
  utility:addAction("eat", function() return 0.7 end, 1.0)
  utility:addAction("sleep", function() return 0.5 end, 1.0)
  lurek.log.info("utility actions=" .. tostring(utility:getActionCount()), "ai")
end
--@api-stub: LUtilityAI:evaluate
-- Evaluates all actions and returns the winning action name when one is available.
do
  local utility = lurek.ai.newUtilityAI()
  utility:addAction("fight", function() return 0.4 end, 1.0)
  utility:addAction("fallback", function() return 0.9 end, 1.0)
  local choice = utility:evaluate()
  lurek.log.info("utility chose=" .. (choice or "none"), "ai")
end
--@api-stub: LUtilityAI:getActionCount
-- Returns the number of actions registered in this utility AI.
do
  local utility = lurek.ai.newUtilityAI()
  utility:addAction("scan", function() return 0.1 end, 1.0)
  utility:addAction("move", function() return 0.2 end, 1.0)
  lurek.log.info("action count=" .. tostring(utility:getActionCount()), "ai")
end
--@api-stub: LUtilityAI:type
-- Returns the Lua-visible type name for this utility AI handle.
do
  local utility = lurek.ai.newUtilityAI()
  utility:addAction("idle", function() return 0.1 end, 1.0)
  lurek.log.info("utility type=" .. utility:type(), "ai")
end
--@api-stub: LUtilityAI:typeOf
-- Returns whether this utility AI handle matches a supported type name.
do
  local utility = lurek.ai.newUtilityAI()
  lurek.log.info("is UtilityAI=" .. tostring(utility:typeOf("UtilityAI")), "ai")
  lurek.log.info("is Object=" .. tostring(utility:typeOf("Object")), "ai")
end
--@api-stub: LAIBlackboard:has
-- Returns whether the blackboard contains any entry for the given key.
do
  local blackboard = lurek.ai.newBlackboard()
  blackboard:setNumber("score", 42)
  blackboard:setBool("ready", true)
  local found = blackboard:has("score")
  local missing = blackboard:has("no_such_key")
  lurek.log.debug("has score=" .. tostring(found) .. " missing=" .. tostring(missing), "ai")
end
--@api-stub: LAIBlackboard:remove
-- Removes the given key from the blackboard if it exists.
do
  local blackboard = lurek.ai.newBlackboard()
  blackboard:setNumber("hp", 100)
  blackboard:setNumber("mp", 50)
  blackboard:remove("hp")
  lurek.log.debug("has hp=" .. tostring(blackboard:has("hp")) .. " has mp=" .. tostring(blackboard:has("mp")), "ai")
end
--@api-stub: LAIBlackboard:clear
-- Removes every local entry from this blackboard.
do
  local blackboard = lurek.ai.newBlackboard()
  blackboard:setNumber("gold", 500)
  blackboard:setString("name", "hero")
  blackboard:clear()
  lurek.log.debug("after clear size=" .. tostring(blackboard:getSize()), "ai")
end
--@api-stub: LAIBlackboard:type
-- Returns the Lua-visible type name for this blackboard handle.
do
  local blackboard = lurek.ai.newBlackboard()
  blackboard:setString("role", "scout")
  lurek.log.debug("blackboard type=" .. blackboard:type(), "ai")
end
--@api-stub: LAIBlackboard:typeOf
-- Returns whether this blackboard handle matches a supported type name.
do
  local blackboard = lurek.ai.newBlackboard()
  lurek.log.debug("is LAIBlackboard=" .. tostring(blackboard:typeOf("LAIBlackboard")), "ai")
  lurek.log.debug("is Object=" .. tostring(blackboard:typeOf("Object")), "ai")
end
--@api-stub: LAIDirector:type
-- Returns the Lua-visible type name for this AI director handle.
do
  local director = lurek.ai.newAIDirector()
  director:setTension(0.4)
  lurek.log.debug("director type=" .. director:type(), "ai")
end
--@api-stub: LAIDirector:typeOf
-- Returns whether this AI director handle matches a supported type name.
do
  local director = lurek.ai.newAIDirector()
  lurek.log.debug("is LAIDirector=" .. tostring(director:typeOf("LAIDirector")), "ai")
  lurek.log.debug("is Object=" .. tostring(director:typeOf("Object")), "ai")
end
--@api-stub: LBandit:type
-- Returns the Lua-visible type name for this bandit handle.
do
  local bandit = lurek.ai.newBandit(4, "ucb1", 0.1, 99)
  bandit:update(0, 0.2)
  lurek.log.debug("bandit type=" .. bandit:type(), "ai")
end
--@api-stub: LBandit:typeOf
-- Returns whether this bandit handle matches a supported type name.
do
  local bandit = lurek.ai.newBandit(4, "ucb1", 0.1, 99)
  lurek.log.debug("is LBandit=" .. tostring(bandit:typeOf("LBandit")), "ai")
  lurek.log.debug("is Object=" .. tostring(bandit:typeOf("Object")), "ai")
end
--@api-stub: LContextSteering:type
-- Returns the Lua-visible type name for this context steering handle.
do
  local context = lurek.ai.newContextSteering(16)
  context:addSeekTarget(20, 0, 1.0)
  lurek.log.debug("context type=" .. context:type(), "ai")
end
--@api-stub: LContextSteering:typeOf
-- Returns whether this context steering handle matches a supported type name.
do
  local context = lurek.ai.newContextSteering(16)
  lurek.log.debug("is LContextSteering=" .. tostring(context:typeOf("LContextSteering")), "ai")
  lurek.log.debug("is Object=" .. tostring(context:typeOf("Object")), "ai")
end
--@api-stub: LDialogueAI:type
-- Returns the Lua-visible type name for this dialogue AI handle.
do
  local dialogue = lurek.ai.newDialogueAI()
  dialogue:addTopic("greet", 1.0)
  lurek.log.debug("dialogue type=" .. dialogue:type(), "ai")
end
--@api-stub: LDialogueAI:typeOf
-- Returns whether this dialogue AI handle matches a supported type name.
do
  local dialogue = lurek.ai.newDialogueAI()
  lurek.log.debug("is DialogueAI=" .. tostring(dialogue:typeOf("DialogueAI")), "ai")
  lurek.log.debug("is Object=" .. tostring(dialogue:typeOf("Object")), "ai")
end
--@api-stub: LEmotionModel:type
-- Returns the Lua-visible type name for this emotion model handle.
do
  local emotions = lurek.ai.newEmotionModel()
  emotions:add("focus", 0.0, 0.05, 0.3)
  lurek.log.debug("emotion type=" .. emotions:type(), "ai")
end
--@api-stub: LEmotionModel:typeOf
-- Returns whether this emotion model handle matches a supported type name.
do
  local emotions = lurek.ai.newEmotionModel()
  lurek.log.debug("is LEmotionModel=" .. tostring(emotions:typeOf("LEmotionModel")), "ai")
  lurek.log.debug("is Object=" .. tostring(emotions:typeOf("Object")), "ai")
end
--@api-stub: LGeneticAlgorithm:type
-- Returns the Lua-visible type name for this genetic algorithm handle.
do
  local genetic = lurek.ai.newGeneticAlgorithm(50, 16, 42)
  genetic:setFitness(0, 1.0)
  lurek.log.debug("genetic type=" .. genetic:type(), "ai")
end
--@api-stub: LGeneticAlgorithm:typeOf
-- Returns whether this genetic algorithm handle matches a supported type name.
do
  local genetic = lurek.ai.newGeneticAlgorithm(50, 16, 42)
  lurek.log.debug("is LGeneticAlgorithm=" .. tostring(genetic:typeOf("LGeneticAlgorithm")), "ai")
  lurek.log.debug("is Object=" .. tostring(genetic:typeOf("Object")), "ai")
end
--@api-stub: LHTNDomain:type
-- Returns the Lua-visible type name for this HTN domain handle.
do
  local domain = lurek.ai.newHTNDomain()
  domain:addPrimitive("wait", {}, {}, {})
  lurek.log.debug("htn type=" .. domain:type(), "ai")
end
--@api-stub: LHTNDomain:typeOf
-- Returns whether this HTN domain handle matches a supported type name.
do
  local domain = lurek.ai.newHTNDomain()
  lurek.log.debug("is LHTNDomain=" .. tostring(domain:typeOf("LHTNDomain")), "ai")
  lurek.log.debug("is Object=" .. tostring(domain:typeOf("Object")), "ai")
end
--@api-stub: LMCTSEngine:type
-- Returns the Lua-visible type name for this MCTS engine handle.
do
  local mcts = lurek.ai.newMCTSEngine(200, 1.41, 32, 12345)
  lurek.log.debug("mcts type=" .. mcts:type(), "ai")
end
--@api-stub: LMCTSEngine:typeOf
-- Returns whether this MCTS engine handle matches a supported type name.
do
  local mcts = lurek.ai.newMCTSEngine(200, 1.41, 32, 12345)
  lurek.log.debug("is LMCTSEngine=" .. tostring(mcts:typeOf("LMCTSEngine")), "ai")
  lurek.log.debug("is Object=" .. tostring(mcts:typeOf("Object")), "ai")
end
--@api-stub: LNeedSystem:type
-- Returns the Lua-visible type name for this need system handle.
do
  local needs = lurek.ai.newNeedSystem()
  needs:addNeed("hunger", 0.1, 0.7, 1.2)
  lurek.log.debug("need system type=" .. needs:type(), "ai")
end
--@api-stub: LNeedSystem:typeOf
-- Returns whether this need system handle matches a supported type name.
do
  local needs = lurek.ai.newNeedSystem()
  lurek.log.debug("is LNeedSystem=" .. tostring(needs:typeOf("LNeedSystem")), "ai")
  lurek.log.debug("is Object=" .. tostring(needs:typeOf("Object")), "ai")
end
--@api-stub: LNeuralNet:type
-- Returns the Lua-visible type name for this neural network handle.
do
  local network = lurek.ai.newNeuralNet()
  network:addLayer(2, 1, "linear")
  lurek.log.debug("network type=" .. network:type(), "ai")
end
--@api-stub: LNeuralNet:typeOf
-- Returns whether this neural network handle matches a supported type name.
do
  local network = lurek.ai.newNeuralNet()
  lurek.log.debug("is LNeuralNet=" .. tostring(network:typeOf("LNeuralNet")), "ai")
  lurek.log.debug("is Object=" .. tostring(network:typeOf("Object")), "ai")
end
--@api-stub: LNeuroevolution:type
-- Returns the Lua-visible type name for this neuroevolution handle.
do
  local layers = { { inputs = 2, outputs = 4, activation = "relu" }, { inputs = 4, outputs = 1, activation = "linear" } }
  local evolution = lurek.ai.newNeuroevolution(layers, 30, 1)
  lurek.log.debug("neuroevolution type=" .. evolution:type(), "ai")
end
--@api-stub: LNeuroevolution:typeOf
-- Returns whether this neuroevolution handle matches a supported type name.
do
  local layers = { { inputs = 2, outputs = 4, activation = "relu" }, { inputs = 4, outputs = 1, activation = "linear" } }
  local evolution = lurek.ai.newNeuroevolution(layers, 30, 1)
  lurek.log.debug("is LNeuroevolution=" .. tostring(evolution:typeOf("LNeuroevolution")), "ai")
  lurek.log.debug("is Object=" .. tostring(evolution:typeOf("Object")), "ai")
end
--@api-stub: LORCASolver:type
-- Returns the Lua-visible type name for this ORCA solver handle.
do
  local solver = lurek.ai.newORCASolver(2.0)
  solver:addAgent(0, 0, 8, 60)
  lurek.log.debug("orca type=" .. solver:type(), "ai")
end
--@api-stub: LORCASolver:typeOf
-- Returns whether this ORCA solver handle matches a supported type name.
do
  local solver = lurek.ai.newORCASolver(2.0)
  lurek.log.debug("is LORCASolver=" .. tostring(solver:typeOf("LORCASolver")), "ai")
  lurek.log.debug("is Object=" .. tostring(solver:typeOf("Object")), "ai")
end
--@api-stub: LStimulusWorld:type
-- Returns the Lua-visible type name for this stimulus world handle.
do
  local stimuli = lurek.ai.newStimulusWorld()
  stimuli:addVisual(12, 24, 1.0, 90, "movement")
  lurek.log.debug("stimulus type=" .. stimuli:type(), "ai")
end
--@api-stub: LStimulusWorld:typeOf
-- Returns whether this stimulus world handle matches a supported type name.
do
  local stimuli = lurek.ai.newStimulusWorld()
  stimuli:addAuditory(0, 0, 1.0, 64, 0.5, "alert")
  lurek.log.debug("is LStimulusWorld=" .. tostring(stimuli:typeOf("LStimulusWorld")), "ai")
  lurek.log.debug("is Object=" .. tostring(stimuli:typeOf("Object")), "ai")
end
--@api-stub: LStrategyAI:type
-- Returns the Lua-visible type name for this strategy AI handle.
do
  local strategy = lurek.ai.newStrategyAI(2.0)
  strategy:addGoal("patrol")
  lurek.log.debug("strategy type=" .. strategy:type(), "ai")
end
--@api-stub: LStrategyAI:typeOf
-- Returns whether this strategy AI handle matches a supported type name.
do
  local strategy = lurek.ai.newStrategyAI(2.0)
  lurek.log.debug("is LStrategyAI=" .. tostring(strategy:typeOf("LStrategyAI")), "ai")
  lurek.log.debug("is Object=" .. tostring(strategy:typeOf("Object")), "ai")
end
--@api-stub: LTraitProfile:type
-- Returns the Lua-visible type name for this trait profile handle.
do
  local traits = lurek.ai.newTraitProfile()
  traits:set("focus", 0.6)
  lurek.log.debug("trait profile type=" .. traits:type(), "ai")
end
--@api-stub: LTraitProfile:typeOf
-- Returns whether this trait profile handle matches a supported type name.
do
  local traits = lurek.ai.newTraitProfile()
  lurek.log.debug("is LTraitProfile=" .. tostring(traits:typeOf("LTraitProfile")), "ai")
  lurek.log.debug("is Object=" .. tostring(traits:typeOf("Object")), "ai")
end
