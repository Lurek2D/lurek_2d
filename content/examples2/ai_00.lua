--@api-stub: lurek.ai.newWorld
-- Creates an isolated AI world for agents, blackboards, and custom decision callbacks.
do
  -- AI world is the top-level container for agents, their blackboards, and decisions.
  -- Create one world per simulation scope (dungeon floor, town, arena).
  local world = lurek.ai.newWorld()
  local guard = world:addAgent("sentry_01")
  guard:setPosition(200, 150)
  guard:setVelocity(10, 0)
  guard:setDecisionModel("custom")
  guard:setCustomModel(function(agent, blackboard, dt)
    blackboard:setString("duty", "patrol")
    blackboard:setNumber("elapsed", dt)
  end)
  world:update(1 / 60)
  local count = world:getAgentCount()
  -- World holds all agents and ticks their decision callbacks each update.
  print("lurek.ai.newWorld: agents=" .. tostring(count))
end

--@api-stub: lurek.ai.newBlackboard
-- Creates an empty AI blackboard for typed local facts.
do
  -- Blackboards store typed facts (number, bool, string) that AI logic reads.
  -- Missing keys return the default you provide, so decision code never errors.
  local bb = lurek.ai.newBlackboard()
  bb:setNumber("alert", 0.6)
  bb:setBool("player_visible", true)
  bb:setString("zone", "courtyard")
  local alert = bb:getNumber("alert", 0)
  local visible = bb:getBool("player_visible", false)
  local zone = bb:getString("zone", "unknown")
  local keys = bb:getKeys()
  -- Typed get calls make blackboard access safe inside callbacks.
  print("lurek.ai.newBlackboard: alert=" .. tostring(alert) .. " zone=" .. zone .. " keys=" .. tostring(#keys))
end

--@api-stub: lurek.ai.newStateMachine
-- Creates an empty finite state machine with Lua-backed states and transitions.
do
  -- FSM manages named states with enter/exit callbacks and conditional transitions.
  -- Transitions have a priority integer; higher priority fires first when multiple match.
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("idle", {
    onEnter = function() end,
    onExit = function() end,
  })
  fsm:addState("alert", {
    onEnter = function() end,
  })
  fsm:addTransition("idle", "alert", function() return true end, 5)
  fsm:setInitialState("idle")
  local state = fsm:getCurrentState() or "none"
  fsm:forceState("alert")
  local timer = fsm:getTimeInState()
  -- FSM state drives NPC behavior phases: idle, patrol, chase, attack.
  print("lurek.ai.newStateMachine: state=" .. state .. " timer=" .. tostring(timer))
end

--@api-stub: lurek.ai.newBehaviorTree
-- Creates an empty behavior tree that can receive a root node.
do
  -- Behavior tree stores a root node and ticks it each update. Build nodes
  -- from composites (selector, sequence) and leaves (action, condition).
  local bt = lurek.ai.newBehaviorTree()
  local root = lurek.ai.newSequence()
  root:addChild(lurek.ai.newCondition(function() return true end))
  root:addChild(lurek.ai.newAction(function() return "success" end))
  bt:setRoot(root)
  local debug_info = bt:getDebugState()
  local status = bt:getLastStatus()
  -- Tree returns "success", "failure", or "running" after each tick.
  print("lurek.ai.newBehaviorTree: nodes=" .. tostring(debug_info.node_count) .. " status=" .. status)
end

--@api-stub: lurek.ai.newSelector
-- Creates a behavior tree selector node with no children.
do
  -- Selector tries children in order until one succeeds (OR logic).
  -- If the first child fails, it tries the second, and so on.
  local sel = lurek.ai.newSelector()
  sel:addChild(lurek.ai.newCondition(function() return false end))
  sel:addChild(lurek.ai.newAction(function() return "success" end))
  local count = sel:getChildCount()
  local node_type = sel:getNodeType()
  sel:reset()
  -- Selector is useful for fallback priorities: try attack, else flee, else idle.
  print("lurek.ai.newSelector: type=" .. node_type .. " children=" .. tostring(count))
end

--@api-stub: lurek.ai.newSequence
-- Creates a behavior tree sequence node with no children.
do
  -- Sequence requires all children to succeed (AND logic).
  -- If any child fails, the sequence stops and reports failure.
  local seq = lurek.ai.newSequence()
  seq:addChild(lurek.ai.newCondition(function() return true end))
  seq:addChild(lurek.ai.newAction(function() return "success" end))
  local bt = lurek.ai.newBehaviorTree()
  bt:setRoot(seq)
  local info = bt:getDebugState()
  -- Sequence enforces ordered prerequisites: check ammo, aim, fire.
  print("lurek.ai.newSequence: nodes=" .. tostring(info.node_count))
end

--@api-stub: lurek.ai.newParallel
-- Creates a behavior tree parallel node with optional success and failure policies.
do
  -- Parallel ticks all children simultaneously. Policies control when the
  -- parallel reports success or failure: "requireAll" or "requireOne".
  local par = lurek.ai.newParallel("requireAll", "requireOne")
  par:addChild(lurek.ai.newAction(function() return "success" end))
  par:addChild(lurek.ai.newAction(function() return "running" end))
  par:setSuccessPolicy("requireAll")
  par:setFailurePolicy("requireOne")
  local count = par:getChildCount()
  -- Parallel is useful for concurrent tasks: move AND play animation.
  print("lurek.ai.newParallel: children=" .. tostring(count))
end

--@api-stub: lurek.ai.newInverter
-- Creates a behavior tree inverter decorator with an empty sequence child.
do
  -- Inverter flips success to failure and failure to success.
  -- Running is passed through unchanged.
  local inv = lurek.ai.newInverter()
  inv:setChild(lurek.ai.newCondition(function() return false end))
  local bt = lurek.ai.newBehaviorTree()
  bt:setRoot(inv)
  local status = bt:getLastStatus()
  -- Inverter turns "is enemy visible?" into "is enemy NOT visible?" without new code.
  print("lurek.ai.newInverter: status=" .. status)
end

--@api-stub: lurek.ai.newRepeater
-- Creates a behavior tree repeater decorator with an optional repeat count.
do
  -- Repeater re-ticks its child up to N times. Count of 0 means infinite repeat.
  local rep = lurek.ai.newRepeater(5)
  rep:setChild(lurek.ai.newAction(function() return "success" end))
  rep:setCount(5)
  local count = rep:getCount()
  local bt = lurek.ai.newBehaviorTree()
  bt:setRoot(rep)
  -- Repeater is useful for patrol loops or retry-until-done patterns.
  print("lurek.ai.newRepeater: count=" .. tostring(count))
end

--@api-stub: lurek.ai.newSucceeder
-- Creates a behavior tree succeeder decorator with an empty sequence child.
do
  -- Succeeder always reports success regardless of what the child returns.
  -- Use it to make optional tasks that do not break a parent sequence.
  local suc = lurek.ai.newSucceeder()
  suc:setChild(lurek.ai.newAction(function() return "failure" end))
  local bt = lurek.ai.newBehaviorTree()
  bt:setRoot(suc)
  local node_type = suc:getNodeType()
  -- Even if the child fails, the succeeder makes the parent see success.
  print("lurek.ai.newSucceeder: type=" .. node_type)
end

--@api-stub: lurek.ai.newAction
-- Creates a behavior tree action leaf backed by a Lua callback.
do
  -- Action callbacks return "success", "failure", or "running".
  -- Unknown return values are treated as "running" by the engine.
  local reached_target = true
  local act = lurek.ai.newAction(function()
    if reached_target then return "success" end
    return "running"
  end)
  local node_type = act:getNodeType()
  -- Actions are the leaf nodes that do actual game work: move, attack, heal.
  print("lurek.ai.newAction: type=" .. node_type)
end

--@api-stub: lurek.ai.newCondition
-- Creates a behavior tree condition leaf backed by a Lua callback.
do
  -- Condition callbacks return a boolean. true = success, false = failure.
  -- Conditions are cheap gate checks before expensive actions.
  local hp = 25
  local low_hp = lurek.ai.newCondition(function() return hp < 30 end)
  local node_type = low_hp:getNodeType()
  -- Use conditions to guard sequences: "has ammo?", "in range?", "can see?"
  print("lurek.ai.newCondition: type=" .. node_type)
end

--@api-stub: lurek.ai.newGuard
-- Creates a guard decorator that runs a predicate before ticking its child.
do
  -- Guard checks a predicate each tick. If predicate returns false, the child
  -- is not ticked and guard reports failure directly.
  local alert_level = 0.8
  local child_action = lurek.ai.newAction(function() return "success" end)
  local guard = lurek.ai.newGuard(function() return alert_level > 0.5 end, child_action)
  local bt = lurek.ai.newBehaviorTree()
  bt:setRoot(guard)
  -- Guard prevents subtrees from running when preconditions are not met.
  print("lurek.ai.newGuard: node=" .. guard:getNodeType())
end

--@api-stub: lurek.ai.newSteeringManager
-- Creates an empty steering manager with support for built-in and custom behaviors.
do
  -- Steering combines multiple movement behaviors (seek, flee, wander) into one force.
  -- Weights control the influence of each behavior on the final direction.
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(400, 300, 1.0)
  steer:addWander(20, 40, 5, 0.3)
  steer:setCombineMode("weighted")
  local fx, fy = steer:calculate(100, 80, 0, 0, 120, 200, 1 / 60)
  local lx, ly = steer:getLastSteering()
  -- The resulting force vector drives NPC movement each frame.
  print("lurek.ai.newSteeringManager: force=" .. tostring(fx) .. "," .. tostring(fy))
end

--@api-stub: lurek.ai.newQLearner
-- Creates a Q-learner with fixed state and action counts.
do
  -- Q-learning stores value estimates for (state, action) pairs.
  -- The agent explores initially, then exploits learned values over time.
  local ql = lurek.ai.newQLearner(10, 4)
  ql:setLearningRate(0.1)
  ql:setDiscountFactor(0.95)
  ql:setExplorationRate(0.3)
  ql:setExplorationDecay(0.99)
  local action = ql:chooseAction(1)
  ql:learn(1, action, 1.0, 2)
  local best = ql:bestAction(1)
  local qval = ql:getQValue(1, best)
  ql:endEpisode()
  -- After many episodes, Q-values converge to optimal policy.
  print("lurek.ai.newQLearner: q=" .. tostring(qval) .. " best=" .. tostring(best))
end

--@api-stub: lurek.ai.newUtilityAI
-- Creates an empty utility AI action scorer.
do
  -- Utility AI picks the highest-scoring action. Each action has a base scorer
  -- callback and optional considerations that multiply the final score.
  local util = lurek.ai.newUtilityAI()
  local danger = 0.9
  util:addAction("flee", function() return danger end, 1.0)
  util:addAction("fight", function() return 0.4 end, 1.0)
  util:addConsideration("fight", "stamina", function() return 0.8 end, "linear", 1, 0, 0, 0.5)
  local chosen = util:evaluate() or "none"
  local count = util:getActionCount()
  -- Utility AI is flexible: add/remove actions at runtime as context changes.
  print("lurek.ai.newUtilityAI: action=" .. chosen .. " count=" .. tostring(count))
end

--@api-stub: lurek.ai.newDialogueAI
-- Creates an empty dialogue selector for weighted topics and branches.
do
  -- DialogueAI selects topics and branches based on FSM state, BT status,
  -- and utility scores. Topics gate on FSM state; branches gate on sub-conditions.
  local dlg = lurek.ai.newDialogueAI()
  dlg:addTopic("greeting", 0.3, nil, nil, "greet_score")
  dlg:addTopic("threat", 0.2, "combat", "success", "threat_score")
  dlg:addBranch("threat", "insult", 0.4, "combat", nil, "insult_score")
  dlg:setFSMState("combat")
  dlg:setBTStatus("success")
  dlg:setUtilityScore("greet_score", 0.1)
  dlg:setUtilityScore("threat_score", 0.8)
  dlg:setUtilityScore("insult_score", 0.6)
  local topic = dlg:selectTopic()
  local branch = topic and dlg:selectBranch(topic) or nil
  -- Dialogue selection changes dynamically as game state evolves.
  print("lurek.ai.newDialogueAI: topic=" .. tostring(topic) .. " branch=" .. tostring(branch))
end

--@api-stub: lurek.ai.newGOAPPlanner
-- Creates an empty GOAP planner for boolean world-state planning.
do
  -- GOAP finds a sequence of actions to reach a goal state from the current state.
  -- Each action has preconditions and effects expressed as boolean facts.
  local goap = lurek.ai.newGOAPPlanner()
  goap:addAction("get_axe", 1.0, function() end)
  goap:setPrecondition("get_axe", "has_axe", false)
  goap:setEffect("get_axe", "has_axe", true)
  goap:addAction("chop_tree", 2.0, function() end)
  goap:setPrecondition("chop_tree", "has_axe", true)
  goap:setEffect("chop_tree", "has_wood", true)
  goap:addGoal("gather_wood", 1.0)
  goap:setGoalState("gather_wood", "has_wood", true)
  goap:setMaxIterations(64)
  local plan = goap:plan({ has_axe = false, has_wood = false }, 8)
  -- Plan is an ordered list of action names: {"get_axe", "chop_tree"}.
  print("lurek.ai.newGOAPPlanner: steps=" .. tostring(#plan))
end

--@api-stub: lurek.ai.newInfluenceMap
-- Creates a grid influence map with the supplied cell dimensions and world cell size.
do
  -- Influence map stores named numeric layers over a 2D grid.
  -- Use it for threat analysis, resource tracking, or territory control.
  local imap = lurek.ai.newInfluenceMap(32, 32, 16)
  imap:addLayer("danger")
  imap:stampInfluence("danger", 200, 150, 64, 1.0, 0.8)
  imap:propagate("danger", 0.3)
  imap:decay("danger", 0.9)
  local val = imap:getInfluence("danger", 12, 9)
  local mx, my = imap:getMaxPosition("danger")
  -- Query influence to steer AI away from danger zones.
  print("lurek.ai.newInfluenceMap: danger=" .. tostring(val) .. " max=" .. tostring(mx) .. "," .. tostring(my))
end

--@api-stub: lurek.ai.newSquad
-- Creates an empty named squad. This function is exposed to Lua scripts.
do
  -- Squads group agents for formation movement and shared orders.
  -- The leader defines the reference point; members get formation offsets.
  local squad = lurek.ai.newSquad("bravo")
  squad:addMember("soldier_01")
  squad:addMember("soldier_02")
  squad:setLeader("soldier_01")
  squad:setFormation("line", 24)
  local tx, ty = squad:getFormationPosition(2, 300, 200)
  local members = squad:getMembers()
  local bb = squad:getBlackboard()
  bb:setString("order", "advance")
  -- Formation positions keep squad members spaced properly around the leader.
  print("lurek.ai.newSquad: name=" .. squad:getName() .. " members=" .. tostring(#members))
end

--@api-stub: lurek.ai.newCommandQueue
-- Creates an empty command queue for callback-backed AI commands.
do
  -- Command queue stores prioritized AI orders. Higher priority commands
  -- can be pushed to front. Non-interruptible commands block preemption.
  local cq = lurek.ai.newCommandQueue()
  cq:enqueue("patrol", function() end, { targetX = 100, targetY = 50, priority = 1, interruptible = true })
  cq:pushFront("evade", function() end, { targetX = 80, targetY = 40, priority = 10, interruptible = false })
  local tx, ty = cq:getCurrentTarget()
  local count = cq:getCount()
  local empty = cq:isEmpty()
  cq:clear()
  -- Commands execute in priority order; pushFront inserts urgent orders.
  print("lurek.ai.newCommandQueue: count=" .. tostring(count) .. " empty=" .. tostring(cq:isEmpty()))
end

--@api-stub: lurek.ai.newTraitProfile
-- Creates an empty trait profile with modifier support.
do
  -- Traits are named numeric personality values. Modifiers temporarily change
  -- the effective value without altering the base (buffs, debuffs, events).
  local traits = lurek.ai.newTraitProfile()
  traits:set("bravery", 0.6)
  traits:set("greed", 0.3)
  traits:addModifier("bravery", 0.2, 3.0, "war_cry")
  traits:update(1 / 60)
  local base = traits:getBase("bravery")
  local effective = traits:get("bravery")
  local archetype = traits:archetype() or "unknown"
  traits:removeModifiers("war_cry")
  -- Effective value = base + sum of active modifiers.
  print("lurek.ai.newTraitProfile: base=" .. tostring(base) .. " effective=" .. tostring(effective))
end

--@api-stub: lurek.ai.newStimulusWorld
-- Creates an empty stimulus world for visual and auditory stimulus records.
do
  -- Stimulus world tracks sensory events (sight, sound) with position and radius.
  -- AI agents query nearby stimuli to react to the environment.
  local sw = lurek.ai.newStimulusWorld()
  local vis_id = sw:addVisual(300, 200, 1.0, 100, "player_spotted")
  local aud_id = sw:addAuditory(150, 250, 0.7, 80, 0.5, "gunshot")
  sw:update(1 / 60)
  local total = sw:count()
  sw:remove(vis_id)
  sw:remove(aud_id)
  sw:clear()
  -- Visual stimuli persist; auditory stimuli decay over time during update.
  print("lurek.ai.newStimulusWorld: stimuli=" .. tostring(total))
end

--@api-stub: lurek.ai.newContextSteering
-- Creates a context steering model with the requested directional slot count.
do
  -- Context steering divides directions into N slots and scores each.
  -- The highest-scoring direction becomes the movement vector.
  local cs = lurek.ai.newContextSteering(8)
  cs:addSeekTarget(400, 300, 1.0)
  cs:addAvoidPoint(200, 200, 48, 1.0)
  cs:addAvoidBounds(0, 0, 800, 600, 16, 0.5)
  cs:addWander(0.1, 0.1)
  local dx, dy = cs:evaluate(180, 180, 0, 0)
  local slots = cs:slotCount()
  cs:clearBehaviors()
  -- More slots = smoother direction resolution at higher computation cost.
  print("lurek.ai.newContextSteering: dir=" .. tostring(dx) .. "," .. tostring(dy) .. " slots=" .. tostring(slots))
end

--@api-stub: lurek.ai.newNeedSystem
-- Creates an empty need system for decaying named needs.
do
  -- Needs accumulate urgency via decay rate. The most urgent need drives behavior.
  -- Satisfy a need after completing the corresponding action.
  local needs = lurek.ai.newNeedSystem()
  needs:addNeed("thirst", 0.04, 0.5, 1.2)
  needs:addNeed("sleep", 0.02, 0.3, 1.0)
  needs:update(8.0)
  local urgent = needs:mostUrgent() or "none"
  local thirst_val = needs:valueOf("thirst")
  needs:satisfy("thirst", 0.3)
  -- After satisfy, urgency drops and another need may become most urgent.
  print("lurek.ai.newNeedSystem: urgent=" .. urgent .. " thirst=" .. tostring(thirst_val))
end

--@api-stub: lurek.ai.newAIDirector
-- Creates an AI director for tension, phase, and pacing factor calculations.
do
  -- AI Director controls game pacing by converting tension into spawn/loot factors.
  -- Push events to raise tension; update decays it over time.
  local dir = lurek.ai.newAIDirector()
  dir:setTension(0.3)
  dir:pushEvent(0.4)
  dir:update(1 / 60)
  local phase = dir:phase()
  local spawn = dir:spawnRateFactor()
  local loot = dir:lootFactor()
  local amb = dir:ambientIntensity()
  dir:reset()
  -- Higher tension = more spawns, better loot, intense ambience.
  print("lurek.ai.newAIDirector: phase=" .. phase .. " spawn=" .. tostring(spawn))
end

--@api-stub: lurek.ai.newHTNDomain
-- Creates an empty hierarchical task network domain.
do
  -- HTN decomposes compound tasks into sequences of primitive tasks.
  -- Primitive tasks have preconditions, positive effects, and negative effects.
  local htn = lurek.ai.newHTNDomain()
  htn:addPrimitive("move_to_ore", { "can_move" }, { "at_ore" }, {})
  htn:addPrimitive("mine_ore", { "at_ore", "has_pick" }, { "has_ore" }, {})
  htn:addCompound("gather_ore", {
    { name = "mine_route", preconditions = { "can_move" }, sub_tasks = { "move_to_ore", "mine_ore" } },
  })
  local plan = htn:plan("gather_ore", { can_move = 1.0, has_pick = 1.0 })
  local task_count = htn:taskCount()
  -- Plan is an ordered list of primitive task names to execute.
  print("lurek.ai.newHTNDomain: tasks=" .. tostring(task_count) .. " plan=" .. tostring(plan and #plan or 0))
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
  -- Emotions decay toward a resting value over time. Trigger events raise them.
  -- An emotion is "active" when its value exceeds the threshold.
  local emo = lurek.ai.newEmotionModel()
  emo:add("joy", 0.0, 0.08, 0.2)
  emo:add("rage", 0.0, 0.05, 0.15)
  emo:trigger("joy", 0.9)
  emo:trigger("rage", 0.3)
  emo:update(1 / 60)
  local dominant = emo:dominant() or "none"
  local joy_val = emo:get("joy")
  local joy_active = emo:isActive("joy")
  emo:reset()
  -- Dominant emotion can drive animation, dialogue tone, or decision weights.
  print("lurek.ai.newEmotionModel: dominant=" .. dominant .. " joy=" .. tostring(joy_val))
end

--@api-stub: lurek.ai.newORCASolver
-- Creates an ORCA avoidance solver with the supplied prediction horizon.
do
  -- ORCA computes collision-free velocities for a crowd of agents.
  -- Each agent has position, radius, and max speed. Set preferred velocity, then compute.
  local orca = lurek.ai.newORCASolver(1.5)
  local a1 = orca:addAgent(100, 100, 12, 60)
  local a2 = orca:addAgent(130, 100, 12, 60)
  orca:setPreferredVelocity(a1, 40, 0)
  orca:setPreferredVelocity(a2, -40, 0)
  orca:compute(1 / 60)
  local sx, sy = orca:getSafeVelocity(a1)
  local count = orca:agentCount()
  -- Safe velocity avoids collisions while staying close to preferred direction.
  print("lurek.ai.newORCASolver: agents=" .. tostring(count) .. " safe=" .. tostring(sx) .. "," .. tostring(sy))
end

--@api-stub: lurek.ai.newNeuralNet
-- Creates an empty feed-forward neural network.
do
  -- Neural network with layers added sequentially. Activation: relu, sigmoid, softmax, tanh.
  -- Use forward() to compute output from input values.
  local nn = lurek.ai.newNeuralNet()
  nn:addLayer(3, 6, "relu")
  nn:addLayer(6, 2, "softmax")
  local weights = nn:getWeights()
  nn:setWeights(weights)
  local output = nn:forward({ 0.5, 0.3, 0.8 })
  local layers = nn:layerCount()
  local params = nn:paramCount()
  -- Output is a table of values from the final layer.
  print("lurek.ai.newNeuralNet: layers=" .. tostring(layers) .. " params=" .. tostring(params) .. " out=" .. tostring(output[1] or 0))
end

--@api-stub: lurek.ai.newGeneticAlgorithm
-- Creates a genetic algorithm population with fixed chromosome length.
do
  -- Genetic algorithm evolves a population of chromosomes (float arrays).
  -- Set fitness per chromosome, then evolve to produce the next generation.
  local ga = lurek.ai.newGeneticAlgorithm(8, 5, 7)
  ga:setFitness(0, 0.9)
  ga:setFitness(1, 0.3)
  local genes = ga:getGenes(0)
  local best = ga:bestGenes()
  ga:evolve()
  local gen = ga:generation()
  local pop = ga:popSize()
  -- Each evolve() produces offspring via crossover and mutation.
  print("lurek.ai.newGeneticAlgorithm: pop=" .. tostring(pop) .. " gen=" .. tostring(gen) .. " genes=" .. tostring(#genes))
end

--@api-stub: lurek.ai.newBandit
-- Creates a multi-armed bandit with a named selection strategy.
do
  -- Multi-armed bandit selects arms (options) to maximize cumulative reward.
  -- Strategies: "ucb1", "thompson", or epsilon-greedy fallback.
  local bandit = lurek.ai.newBandit(3, "ucb1", 0.15, 55)
  local arm = bandit:select()
  bandit:update(arm, 1.0)
  bandit:update(arm, 0.5)
  local best_arm = bandit:bestArm()
  local pulls = bandit:totalPulls()
  -- Use bandits for adaptive difficulty, ad placement, or reward balancing.
  print("lurek.ai.newBandit: arms=" .. tostring(bandit:armCount()) .. " best=" .. tostring(best_arm) .. " pulls=" .. tostring(pulls))
end

--@api-stub: lurek.ai.newNeuroevolution
-- Creates a neuroevolution population from a layer specification table.
do
  -- Neuroevolution combines neural networks with genetic algorithms.
  -- Each chromosome encodes network weights; fitness drives selection.
  local layers = {
    { inputs = 3, outputs = 6, activation = "relu" },
    { inputs = 6, outputs = 2, activation = "softmax" },
  }
  local ne = lurek.ai.newNeuroevolution(layers, 8, 1)
  ne:setFitness(0, 0.7)
  local net = ne:chromosomeToNet(0)
  local output = net and net:forward({ 0.2, 0.4, 0.6 }) or {}
  ne:evolve()
  local gen = ne:generation()
  local best_fit = ne:bestFitness()
  -- After evolve, new population inherits traits from top performers.
  print("lurek.ai.newNeuroevolution: gen=" .. tostring(gen) .. " best=" .. tostring(best_fit))
end

--@api-stub: lurek.ai.newStrategyAI
-- Creates a strategy AI that reevaluates goals on a fixed interval.
do
  -- Strategy AI picks the highest-scoring goal from a registered set.
  -- Reevaluation happens at a fixed interval or on-demand via forceEvaluate.
  local strat = lurek.ai.newStrategyAI(3.0)
  strat:addGoal("expand")
  strat:addGoal("fortify")
  strat:addTag("mid_game")
  local scorer = function(goal)
    if goal == "fortify" then return 0.9 end
    return 0.4
  end
  strat:forceEvaluate(scorer)
  local active = strat:activeGoal() or "none"
  local next_eval = strat:timeUntilNext()
  strat:removeTag("mid_game")
  -- Tags provide context that scorers can read for conditional logic.
  print("lurek.ai.newStrategyAI: goal=" .. active .. " next=" .. tostring(next_eval))
end

--@api-stub: lurek.ai.newAILod
-- Creates a default AI level-of-detail tier selector.
do
  -- AI LOD reduces update frequency for distant agents. Closer agents get
  -- higher tiers (more frequent updates); distant ones get lower tiers.
  local lod = lurek.ai.newAILod()
  local tier = lod:tierFor(500, 400, 320, 240)
  local name = lod:tierName(tier) or "unknown"
  local should = lod:shouldUpdate(tier, 60)
  local count = lod:tierCount()
  -- Check shouldUpdate each frame to skip expensive AI for far-away NPCs.
  print("lurek.ai.newAILod: tier=" .. tostring(tier) .. " name=" .. name .. " count=" .. tostring(count))
end

--@api-stub: LAIWorld:addAgent
-- Creates a named agent in this world and returns a handle that can edit its movement and decision state.
do
  -- addAgent returns an LAgent handle. The name must be unique within the world.
  -- Use the handle to set position, velocity, and decision model.
  local world = lurek.ai.newWorld()
  local archer = world:addAgent("archer_01")
  archer:setPosition(50, 75)
  archer:setMaxSpeed(120)
  archer:setDecisionModel("custom")
  local count = world:getAgentCount()
  -- The handle stays valid until removeAgent is called.
  print("LAIWorld:addAgent: count=" .. tostring(count))
end

--@api-stub: LAIWorld:getAgent
-- Returns the named agent handle when it exists in this world.
do
  -- getAgent returns nil if no agent has that name. Always check before using.
  local world = lurek.ai.newWorld()
  world:addAgent("scout_01")
  local found = world:getAgent("scout_01")
  local missing = world:getAgent("ghost_99")
  local name = found and found:getName() or "nil"
  -- Use getAgent to look up agents by their stable string ID.
  print("LAIWorld:getAgent: found=" .. name .. " missing=" .. tostring(missing))
end

--@api-stub: LAIWorld:removeAgent
-- Removes an agent from this world by using an existing agent handle.
do
  -- After removal, the handle becomes stale and returns defaults.
  local world = lurek.ai.newWorld()
  local temp = world:addAgent("temp_npc")
  local before = world:getAgentCount()
  world:removeAgent(temp)
  local after = world:getAgentCount()
  -- Stale handles are safe to hold but will return zero/empty values.
  print("LAIWorld:removeAgent: " .. tostring(before) .. " -> " .. tostring(after))
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
  -- Global blackboard stores world-level facts shared by all agents.
  -- Use it for alert state, time of day, or team-wide knowledge.
  local world = lurek.ai.newWorld()
  local gb = world:getGlobalBlackboard()
  gb:setNumber("alarm_level", 0.0)
  gb:setString("weather", "rain")
  gb:setBool("night", true)
  local weather = gb:getString("weather", "clear")
  -- All agents can read global facts to adjust their decisions.
  print("LAIWorld:getGlobalBlackboard: weather=" .. weather)
end

--@api-stub: LAIWorld:update
-- Advances the world simulation and invokes custom decision callbacks for agents that use a custom model.
do
  -- update(dt) ticks all agents with custom models, passing dt to their callbacks.
  -- Call this once per frame from your game loop.
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("worker")
  npc:setDecisionModel("custom")
  local ticked = false
  npc:setCustomModel(function(agent, blackboard, dt)
    ticked = true
    blackboard:setNumber("frame_dt", dt)
  end)
  world:update(1 / 60)
  -- After update, all custom model callbacks have been invoked with dt.
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
  -- setPosition(x, y) moves the agent to new world coordinates instantly.
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("mover")
  npc:setPosition(256, 128)
  local x, y = npc:getPosition()
  -- Position is used by steering, formation, and influence queries.
  print("LAgent:setPosition: x=" .. tostring(x) .. " y=" .. tostring(y))
end

--@api-stub: LAgent:getPosition
-- Returns this agent's world position or the origin when the agent has been removed.
do
  -- getPosition() returns two numbers: x, y. Removed agents return 0, 0.
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("static_guard")
  npc:setPosition(400, 300)
  local x, y = npc:getPosition()
  -- Use position for distance checks, steering targets, or rendering.
  print("LAgent:getPosition: " .. tostring(x) .. ", " .. tostring(y))
end

--@api-stub: LAgent:setVelocity
-- Sets this agent's velocity vector when the agent still exists in its world.
do
  -- setVelocity(vx, vy) sets the agent's current movement direction and speed.
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("runner")
  npc:setVelocity(60, -30)
  local vx, vy = npc:getVelocity()
  -- Velocity is typically set from steering output each frame.
  print("LAgent:setVelocity: vx=" .. tostring(vx) .. " vy=" .. tostring(vy))
end

--@api-stub: LAgent:getVelocity
-- Returns this agent's velocity vector or zero velocity when the agent has been removed.
do
  -- getVelocity() returns two numbers: vx, vy. Removed agents return 0, 0.
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("idle_npc")
  npc:setVelocity(0, 0)
  local vx, vy = npc:getVelocity()
  -- Zero velocity means the agent is stationary.
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

print("ai_00.lua")
