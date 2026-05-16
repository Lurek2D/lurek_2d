-- content/examples/ai.lua
-- lurek.ai API examples.
-- Run: cargo run -- content/examples/ai.lua

--@api-stub: lurek.ai.newWorld -- Creates an isolated AI world for agents, blackboards, and custom decision callbacks
do -- lurek.ai.newWorld
  local world = lurek.ai.newWorld()
  world:addAgent("guard_01")
  function lurek.process(dt) world:update(dt) end
end

--@api-stub: lurek.ai.newBlackboard -- Creates an empty AI blackboard for typed local facts
do -- lurek.ai.newBlackboard
  local bb = lurek.ai.newBlackboard()
  bb:setNumber("alert_level", 0.3)
  bb:setBool("player_seen", false)
end

--@api-stub: lurek.ai.newStateMachine -- Creates an empty finite state machine with Lua-backed states and transitions
do -- lurek.ai.newStateMachine
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("patrol", { onEnter = function() lurek.log.info("patrolling", "ai") end })
  fsm:addState("chase", {})
  fsm:setInitialState("patrol")
end

--@api-stub: lurek.ai.newBehaviorTree -- Creates an empty behavior tree that can receive a root node
do -- lurek.ai.newBehaviorTree
  local bt = lurek.ai.newBehaviorTree()
  local root = lurek.ai.newSequence()
  root:addChild(lurek.ai.newAction(function() return "success" end))
  bt:setRoot(root)
end

--@api-stub: lurek.ai.newSelector -- Creates a behavior tree selector node with no children
do -- lurek.ai.newSelector
  local sel = lurek.ai.newSelector()
  sel:addChild(lurek.ai.newCondition(function() return false end))
  sel:addChild(lurek.ai.newAction(function() return "success" end))
end

--@api-stub: lurek.ai.newSequence -- Creates a behavior tree sequence node with no children
do -- lurek.ai.newSequence
  local seq = lurek.ai.newSequence()
  seq:addChild(lurek.ai.newCondition(function() return true end))
  seq:addChild(lurek.ai.newAction(function() return "success" end))
end

--@api-stub: lurek.ai.newParallel -- Creates a behavior tree parallel node with optional success and failure policies
do -- lurek.ai.newParallel
  local par = lurek.ai.newParallel("require_all", "require_one")
  par:addChild(lurek.ai.newAction(function() return "success" end))
  par:addChild(lurek.ai.newAction(function() return "running" end))
end

--@api-stub: lurek.ai.newInverter -- Creates a behavior tree inverter decorator with an empty sequence child
do -- lurek.ai.newInverter
  local inv = lurek.ai.newInverter()
  inv:setChild(lurek.ai.newCondition(function() return false end))
  local bt = lurek.ai.newBehaviorTree(); bt:setRoot(inv)
end

--@api-stub: lurek.ai.newRepeater -- Creates a behavior tree repeater decorator with an optional repeat count
do -- lurek.ai.newRepeater
  local rep = lurek.ai.newRepeater(3)
  rep:setChild(lurek.ai.newAction(function() return "success" end))
  local bt = lurek.ai.newBehaviorTree(); bt:setRoot(rep)
end

--@api-stub: lurek.ai.newSucceeder -- Creates a behavior tree succeeder decorator with an empty sequence child
do -- lurek.ai.newSucceeder
  local suc = lurek.ai.newSucceeder()
  suc:setChild(lurek.ai.newAction(function() return "failure" end))
  local bt = lurek.ai.newBehaviorTree(); bt:setRoot(suc)
end

--@api-stub: lurek.ai.newAction -- Creates a behavior tree action leaf backed by a Lua callback
do -- lurek.ai.newAction
  local act = lurek.ai.newAction(function(dt)
      return "success"
  end)
end

--@api-stub: lurek.ai.newCondition -- Creates a behavior tree condition leaf backed by a Lua callback
do -- lurek.ai.newCondition
  local hp_low = lurek.ai.newCondition(function() return true end)
  local seq = lurek.ai.newSequence()
  seq:addChild(hp_low)
end

--@api-stub: lurek.ai.newSteeringManager -- Creates an empty steering manager with support for built-in and custom behaviors
do -- lurek.ai.newSteeringManager
  local sm = lurek.ai.newSteeringManager()
  sm:addSeek(400, 300, 1.0)
  sm:addWander(20, 40, 5, 0.3)
end

--@api-stub: LSteeringManager.setPath
do -- LSteeringManager.setPath
  local grid = lurek.pathfind.newPathGrid(10, 10, 32)
  local path = grid:findPath(1, 1, 10, 10)
  local sm = lurek.ai.newSteeringManager()
  if path then
    sm:setPath(path, 12.0, 1.0)
    if sm:hasPath() then
      local fx, fy = sm:calculate(0, 0, 0, 0, 120, 240, 1 / 60)
      lurek.log.info("path force: " .. tostring(fx) .. ", " .. tostring(fy), "ai")
    end
  end
end

--@api-stub: LSteeringManager.getPathProgress
do -- LSteeringManager.getPathProgress
  local sm = lurek.ai.newSteeringManager()
  sm:setPath({ { x = 16, y = 16 }, { x = 48, y = 16 } })
  local idx, total = sm:getPathProgress()
  lurek.log.info("path progress " .. tostring(idx) .. "/" .. tostring(total), "ai")
  sm:clearPath()
end

--@api-stub: lurek.ai.newQLearner -- Creates a Q-learner with fixed state and action counts
do -- lurek.ai.newQLearner
  local ql = lurek.ai.newQLearner(16, 4)
  ql:setLearningRate(0.1)
  ql:setExplorationRate(0.2)
end

--@api-stub: lurek.ai.newUtilityAI -- Creates an empty utility AI action scorer
do -- lurek.ai.newUtilityAI
  local uai = lurek.ai.newUtilityAI()
  uai:addAction("flee", function() return 0.8 end, 1.0)
  uai:addAction("attack", function() return 0.4 end, 1.0)
end

--@api-stub: lurek.ai.newDialogueAI -- Creates an empty dialogue selector for weighted topics and branches
do -- lurek.ai.newDialogueAI
  local d = lurek.ai.newDialogueAI()
  local t = d:type()
  local _is_dialogue = d:typeOf("DialogueAI")
  lurek.log.info("dialogue type: " .. tostring(t), "ai")
  d:addTopic("smalltalk", 0.2, nil, nil, "smalltalk_score")
  d:addTopic("combat", 0.2, "combat", "success", "combat_score")
  d:addBranch("combat", "taunt", 0.3, "combat", nil, "taunt_score")
  d:addBranch("combat", "threat", 0.2, "combat", nil, "threat_score")
  d:setFSMState("combat")
  d:setBTStatus("success")
  d:setUtilityScore("smalltalk_score", 0.1)
  d:setUtilityScore("combat_score", 0.9)
  d:setUtilityScore("taunt_score", 0.6)
  d:setUtilityScore("threat_score", 0.4)

  local topic = d:selectTopic()
  if topic then
    local branch = d:selectBranch(topic)
    lurek.log.info("dialogue: " .. tostring(topic) .. "/" .. tostring(branch), "ai")
  end
  local topic_count = d:getTopicCount()
  lurek.log.info("dialogue topics: " .. tostring(topic_count), "ai")
  d:clearUtilityScores()
end

--@api-stub: lurek.ai.newGOAPPlanner -- Creates an empty GOAP planner for boolean world-state planning
do -- lurek.ai.newGOAPPlanner
  local planner = lurek.ai.newGOAPPlanner()
  planner:addAction("eat", 1.0, function() lurek.log.info("eating", "ai") end)
  planner:addGoal("not_hungry", 1.0)
end

--@api-stub: lurek.ai.newInfluenceMap -- Creates a grid influence map with the supplied cell dimensions and world cell size
do -- lurek.ai.newInfluenceMap
  local infl = lurek.ai.newInfluenceMap(64, 64, 16)
  infl:addLayer("threat")
  infl:stampInfluence("threat", 320, 240, 80, 1.0, 1.0)
end

--@api-stub: lurek.ai.newSquad -- Creates an empty named squad
do -- lurek.ai.newSquad
  local squad = lurek.ai.newSquad("alpha")
  squad:addMember("guard_01")
  squad:setFormation("wedge", 32)
end

--@api-stub: lurek.ai.newCommandQueue -- Creates an empty command queue for callback-backed AI commands
do -- lurek.ai.newCommandQueue
  local q = lurek.ai.newCommandQueue()
  q:enqueue("move", function() end, { targetX = 200, targetY = 100 })
  q:enqueue("attack", function() end, { priority = 5 })
end

--@api-stub: lurek.ai.newTraitProfile -- Creates an empty trait profile with modifier support
do -- lurek.ai.newTraitProfile
  local traits = lurek.ai.newTraitProfile()
  traits:set("aggression", 0.7)
  traits:set("courage", 0.4)
end

--@api-stub: lurek.ai.newStimulusWorld -- Creates an empty stimulus world for visual and auditory stimulus records
do -- lurek.ai.newStimulusWorld
  local sw = lurek.ai.newStimulusWorld()
  sw:addAuditory(100, 200, 1.0, 150, 0.5, "footstep")
  function lurek.process(dt) sw:update(dt) end
end

--@api-stub: lurek.ai.newContextSteering -- Creates a context steering model with the requested directional slot count
do -- lurek.ai.newContextSteering
  local cs = lurek.ai.newContextSteering(16)
  cs:addSeekTarget(500, 300, 1.0)
  cs:addAvoidPoint(250, 200, 64, 1.0)
end

--@api-stub: lurek.ai.newNeedSystem -- Creates an empty need system for decaying named needs
do -- lurek.ai.newNeedSystem
  local needs = lurek.ai.newNeedSystem()
  needs:addNeed("hunger", 0.05, 0.6, 1.5)
  function lurek.process(dt) needs:update(dt) end
end

--@api-stub: lurek.ai.newAIDirector -- Creates an AI director for tension, phase, and pacing factor calculations
do -- lurek.ai.newAIDirector
  local dir = lurek.ai.newAIDirector()
  dir:setTension(0.4)
  function lurek.process(dt) dir:update(dt) end
end

--@api-stub: lurek.ai.newHTNDomain -- Creates an empty hierarchical task network domain
do -- lurek.ai.newHTNDomain
  local d = lurek.ai.newHTNDomain()
  d:addPrimitive("attack", { "has_weapon" }, { "enemy_dead" }, {})
end

--@api-stub: lurek.ai.newMCTSEngine -- Creates a Monte Carlo tree search engine with deterministic configuration
do -- lurek.ai.newMCTSEngine
  local mcts = lurek.ai.newMCTSEngine(200, 1.41, 32, 12345)
  local actions = function(s) return { 1, 2, 3 } end
  local apply = function(s, a) return s + a end
  local eval = function(s) return s % 7 end
end

--@api-stub: lurek.ai.newEmotionModel -- Creates an empty emotion model for named decaying emotion values
do -- lurek.ai.newEmotionModel
  local em = lurek.ai.newEmotionModel()
  em:add("fear", 0.0, 0.1, 0.2)
  em:add("anger", 0.0, 0.05, 0.15)
end

--@api-stub: lurek.ai.newORCASolver -- Creates an ORCA avoidance solver with the supplied prediction horizon
do -- lurek.ai.newORCASolver
  local orca = lurek.ai.newORCASolver(2.0)
  local idx = orca:addAgent(100, 100, 16, 80)
  orca:setPreferredVelocity(idx, 50, 0)
end

--@api-stub: lurek.ai.newNeuralNet -- Creates an empty feed-forward neural network
do -- lurek.ai.newNeuralNet
  local nn = lurek.ai.newNeuralNet()
  nn:addLayer(4, 8, "relu")
  nn:addLayer(8, 2, "softmax")
end

--@api-stub: lurek.ai.newGeneticAlgorithm -- Creates a genetic algorithm population with fixed chromosome length
do -- lurek.ai.newGeneticAlgorithm
  local ga = lurek.ai.newGeneticAlgorithm(50, 16, 42)
  ga:setFitness(1, 0.7)
  function lurek.process(dt) ga:evolve() end
end

--@api-stub: lurek.ai.newBandit -- Creates a multi-armed bandit with a named selection strategy
do -- lurek.ai.newBandit
  local b = lurek.ai.newBandit(4, "ucb1", 0.1, 99)
  local arm = b:select()
  b:update(arm, 1.0)
end

--@api-stub: lurek.ai.newNeuroevolution -- Creates a neuroevolution population from a layer specification table
do -- lurek.ai.newNeuroevolution
  local layers = { { inputs = 4, outputs = 8, activation = "relu" }, { inputs = 8, outputs = 2, activation = "softmax" } }
  local ne = lurek.ai.newNeuroevolution(layers, 30, 1)
  function lurek.process(dt) ne:evolve() end
end

--@api-stub: lurek.ai.newStrategyAI -- Creates a strategy AI that reevaluates goals on a fixed interval
do -- lurek.ai.newStrategyAI
  local s = lurek.ai.newStrategyAI(2.0)
  s:addGoal("expand")
  s:addGoal("defend")
end

--@api-stub: lurek.ai.newAILod -- Creates a default AI level-of-detail tier selector
do -- lurek.ai.newAILod
  local lod = lurek.ai.newAILod()
  if lod:shouldUpdate(1, 60) then lurek.log.debug("tier 1 update", "ai") end
end
-- do  -- AIWorld:addAgent
--   local world = lurek.ai.newWorld()
--   local guard = world:addAgent("guard_01")
--   guard:setPosition(100, 100)
-- end

--@api-stub: AIWorld:getAgent
do -- AIWorld:getAgent
  local world = lurek.ai.newWorld()
  world:addAgent("guard_01")
  local a = world:getAgent("guard_01")
  if a then a:addTag("alive") end
end

--@api-stub: AIWorld:removeAgent
do -- AIWorld:removeAgent
  local world = lurek.ai.newWorld()
  local tmp = world:addAgent("temp")
  world:removeAgent(tmp)
end

--@api-stub: AIWorld:getAgentCount
do -- AIWorld:getAgentCount
  local world = lurek.ai.newWorld()
  world:addAgent("a"); world:addAgent("b")
  lurek.log.info("agents=" .. world:getAgentCount(), "ai")
end

--@api-stub: AIWorld:getGlobalBlackboard
do -- AIWorld:getGlobalBlackboard
  local world = lurek.ai.newWorld()
  local bb = world:getGlobalBlackboard()
  bb:setNumber("alarm", 0.0)
end

--@api-stub: AIWorld:update
do -- AIWorld:update
  local world = lurek.ai.newWorld()
  world:addAgent("npc")
  function lurek.process(dt) world:update(dt) end
end

--@api-stub: AIWorld:type
do -- AIWorld:type
  local world = lurek.ai.newWorld()
  if world:type() == "AIWorld" then lurek.log.debug("got world", "ai") end
end

--@api-stub: AIWorld:typeOf
do -- AIWorld:typeOf
  local world = lurek.ai.newWorld()
  if world:typeOf("Object") then lurek.log.debug("inherits Object", "ai") end
end

--@api-stub: Agent:getName
do -- Agent:getName
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("scout_01")
  local name = agent:getName()
  lurek.log.debug("agent=" .. name, "ai")
end

--@api-stub: Agent:setPosition
do -- Agent:setPosition
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("scout_01")
  agent:setPosition(320, 240)
end

--@api-stub: Agent:getPosition
do -- Agent:getPosition
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("scout_01")
  agent:setPosition(50, 75)
  local x, y = agent:getPosition()
  lurek.log.debug("pos=" .. x .. "," .. y, "ai")
end

--@api-stub: Agent:setVelocity
do -- Agent:setVelocity
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("scout_01")
  agent:setVelocity(40, 0)
end

--@api-stub: Agent:getVelocity
do -- Agent:getVelocity
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("scout_01")
  agent:setVelocity(40, 30)
  local vx, vy = agent:getVelocity()
  if vx*vx + vy*vy > 100 then lurek.log.debug("moving", "ai") end
end

--@api-stub: Agent:setMaxSpeed
do -- Agent:setMaxSpeed
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("scout_01")
  agent:setMaxSpeed(150)
end

--@api-stub: Agent:getMaxSpeed
do -- Agent:getMaxSpeed
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("scout_01")
  local cap = agent:getMaxSpeed()
  agent:setVelocity(cap, 0)
end

--@api-stub: Agent:setMaxForce
do -- Agent:setMaxForce
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("scout_01")
  agent:setMaxForce(300)
end

--@api-stub: Agent:getMaxForce
do -- Agent:getMaxForce
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("scout_01")
  local f = agent:getMaxForce()
  lurek.log.debug("max force=" .. f, "ai")
end

--@api-stub: Agent:setPriority
do -- Agent:setPriority
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("scout_01")
  agent:setPriority(10)
end

--@api-stub: Agent:getPriority
do -- Agent:getPriority
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("scout_01")
  agent:setPriority(5)
  if agent:getPriority() > 0 then lurek.log.debug("prio agent", "ai") end
end

--@api-stub: Agent:setDecisionModel
do -- Agent:setDecisionModel
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("scout_01")
  agent:setDecisionModel("bt")
end

--@api-stub: Agent:getDecisionModel
do -- Agent:getDecisionModel
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("scout_01")
  if agent:getDecisionModel() == "fsm" then lurek.log.debug("uses fsm", "ai") end
end

--@api-stub: Agent:addTag
do -- Agent:addTag
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("scout_01")
  agent:addTag("alive")
  agent:addTag("scout")
end

--@api-stub: Agent:removeTag
do -- Agent:removeTag
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("scout_01")
  agent:addTag("burning")
  agent:removeTag("burning")
end

--@api-stub: Agent:hasTag
do -- Agent:hasTag
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("scout_01")
  agent:addTag("boss")
  if agent:hasTag("boss") then lurek.log.info("boss alert", "ai") end
end

--@api-stub: Agent:getBlackboard
do -- Agent:getBlackboard
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("scout_01")
  local bb = agent:getBlackboard()
  bb:setNumber("hp", 100)
end

--@api-stub: Agent:type
do -- Agent:type
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("scout_01")
  if agent:type() == "Agent" then lurek.log.debug("ok", "ai") end
end

--@api-stub: Agent:typeOf
do -- Agent:typeOf
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("scout_01")
  if agent:typeOf("Object") then lurek.log.debug("inherits Object", "ai") end
end

--@api-stub: Blackboard:setNumber
do -- Blackboard:setNumber
  local bb = lurek.ai.newBlackboard()
  bb:setNumber("hp", 100)
  bb:setNumber("alert_level", 0.6)
end

--@api-stub: Blackboard:setBool
do -- Blackboard:setBool
  local bb = lurek.ai.newBlackboard()
  bb:setBool("player_seen", true)
  bb:setBool("door_open", false)
end

--@api-stub: Blackboard:setString
do -- Blackboard:setString
  local bb = lurek.ai.newBlackboard()
  bb:setString("target_id", "player_01")
  bb:setString("last_state", "patrol")
end

--@api-stub: Blackboard:has
do -- Blackboard:has
  local bb = lurek.ai.newBlackboard()
  bb:setBool("alive", true)
  if bb:has("alive") then lurek.log.debug("entry exists", "ai") end
end

--@api-stub: Blackboard:remove
do -- Blackboard:remove
  local bb = lurek.ai.newBlackboard()
  bb:setNumber("temp", 1)
  bb:remove("temp")
end

--@api-stub: Blackboard:clear
do -- Blackboard:clear
  local bb = lurek.ai.newBlackboard()
  bb:setBool("dirty", true)
  bb:clear()
end

--@api-stub: Blackboard:getKeys
do -- Blackboard:getKeys
  local bb = lurek.ai.newBlackboard()
  bb:setNumber("hp", 100); bb:setBool("alive", true)
  for _, k in ipairs(bb:getKeys()) do lurek.log.debug("key=" .. k, "ai") end
end

--@api-stub: Blackboard:getSize
do -- Blackboard:getSize
  local bb = lurek.ai.newBlackboard()
  bb:setNumber("hp", 100)
  lurek.log.debug("entries=" .. bb:getSize(), "ai")
end

--@api-stub: Blackboard:type
do -- Blackboard:type
  local bb = lurek.ai.newBlackboard()
  if bb:type() == "Blackboard" then lurek.log.debug("got bb", "ai") end
end

--@api-stub: Blackboard:typeOf
do -- Blackboard:typeOf
  local bb = lurek.ai.newBlackboard()
  if bb:typeOf("Object") then lurek.log.debug("ok", "ai") end
end

--@api-stub: StateMachine:addState
do -- StateMachine:addState
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("patrol", { onEnter = function() lurek.log.info("patrol", "ai") end })
  fsm:addState("chase", { onUpdate = function(dt) end })
end

--@api-stub: StateMachine:setInitialState
do -- StateMachine:setInitialState
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("idle", {})
  fsm:setInitialState("idle")
end

--@api-stub: StateMachine:getCurrentState
do -- StateMachine:getCurrentState
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("patrol", {}); fsm:setInitialState("patrol")
  local s = fsm:getCurrentState()
  if s then lurek.log.debug("state=" .. s, "ai") end
end

--@api-stub: StateMachine:forceState
do -- StateMachine:forceState
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("stunned", {}); fsm:setInitialState("stunned")
  fsm:forceState("stunned")
end

--@api-stub: StateMachine:getTimeInState
do -- StateMachine:getTimeInState
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("idle", {}); fsm:setInitialState("idle")
  if fsm:getTimeInState() > 5.0 then fsm:forceState("idle") end
end

--@api-stub: StateMachine:type
do -- StateMachine:type
  local fsm = lurek.ai.newStateMachine()
  if fsm:type() == "StateMachine" then lurek.log.debug("ok", "ai") end
end

--@api-stub: StateMachine:typeOf
do -- StateMachine:typeOf
  local fsm = lurek.ai.newStateMachine()
  if fsm:typeOf("Object") then lurek.log.debug("ok", "ai") end
end

--@api-stub: BehaviorTree:setRoot
do -- BehaviorTree:setRoot
  local bt = lurek.ai.newBehaviorTree()
  local root = lurek.ai.newSelector()
  root:addChild(lurek.ai.newAction(function() return "success" end))
  bt:setRoot(root)
end

--@api-stub: BehaviorTree:getLastStatus
do -- BehaviorTree:getLastStatus
  local bt = lurek.ai.newBehaviorTree()
  local root = lurek.ai.newSequence()
  root:addChild(lurek.ai.newAction(function() return "success" end))
  bt:setRoot(root)
  local s = bt:getLastStatus()
  lurek.log.debug("bt status=" .. s, "ai")
end

--@api-stub: BehaviorTree:getDebugState
do -- BehaviorTree:getDebugState
  local bt = lurek.ai.newBehaviorTree()
  local root = lurek.ai.newSequence()
  root:addChild(lurek.ai.newAction(function() return "success" end))
  bt:setRoot(root)
  local dbg = bt:getDebugState()
  lurek.log.debug("nodes=" .. dbg.node_count .. " status=" .. dbg.last_status, "ai")
end

--@api-stub: BehaviorTree:type
do -- BehaviorTree:type
  local bt = lurek.ai.newBehaviorTree()
  if bt:type() == "BehaviorTree" then lurek.log.debug("ok", "ai") end
end

--@api-stub: BehaviorTree:typeOf
do -- BehaviorTree:typeOf
  local bt = lurek.ai.newBehaviorTree()
  if bt:typeOf("Object") then lurek.log.debug("ok", "ai") end
end

--@api-stub: BTNode:addChild
do -- BTNode:addChild
  local seq = lurek.ai.newSequence()
  seq:addChild(lurek.ai.newCondition(function() return true end))
  seq:addChild(lurek.ai.newAction(function() return "success" end))
end

--@api-stub: BTNode:getChildCount
do -- BTNode:getChildCount
  local seq = lurek.ai.newSequence()
  seq:addChild(lurek.ai.newAction(function() return "success" end))
  lurek.log.debug("children=" .. seq:getChildCount(), "ai")
end

--@api-stub: BTNode:reset
do -- BTNode:reset
  local rep = lurek.ai.newRepeater(3)
  rep:setChild(lurek.ai.newAction(function() return "success" end))
  rep:reset()
end

--@api-stub: BTNode:setChild
do -- BTNode:setChild
  local inv = lurek.ai.newInverter()
  inv:setChild(lurek.ai.newCondition(function() return false end))
  local bt = lurek.ai.newBehaviorTree(); bt:setRoot(inv)
end

--@api-stub: BTNode:setCount
do -- BTNode:setCount
  local rep = lurek.ai.newRepeater(0)
  rep:setCount(5)
  rep:setChild(lurek.ai.newAction(function() return "success" end))
end

--@api-stub: BTNode:getCount
do -- BTNode:getCount
  local rep = lurek.ai.newRepeater(7)
  if rep:getCount() == 7 then lurek.log.debug("count ok", "ai") end
end

--@api-stub: BTNode:setSuccessPolicy
do -- BTNode:setSuccessPolicy
  local par = lurek.ai.newParallel("require_one", "require_one")
  par:setSuccessPolicy("require_all")
  par:addChild(lurek.ai.newAction(function() return "success" end))
end

--@api-stub: BTNode:setFailurePolicy
do -- BTNode:setFailurePolicy
  local par = lurek.ai.newParallel("require_one", "require_one")
  par:setFailurePolicy("require_all")
  par:addChild(lurek.ai.newAction(function() return "running" end))
end

--@api-stub: BTNode:getNodeType
do -- BTNode:getNodeType
  local seq = lurek.ai.newSequence()
  if seq:getNodeType() == "sequence" then lurek.log.debug("seq ok", "ai") end
end

--@api-stub: BTNode:type
do -- BTNode:type
  local seq = lurek.ai.newSequence()
  if seq:type() == "BTNode" then lurek.log.debug("ok", "ai") end
end

--@api-stub: BTNode:typeOf
do -- BTNode:typeOf
  local sel = lurek.ai.newSelector()
  if sel:typeOf("Object") then lurek.log.debug("ok", "ai") end
end

--@api-stub: SteeringManager:getBehaviorCount
do -- SteeringManager:getBehaviorCount
  local sm = lurek.ai.newSteeringManager()
  sm:addSeek(400, 300, 1.0)
  sm:addWander(20, 40, 5, 0.3)
  lurek.log.debug("behaviours=" .. sm:getBehaviorCount(), "ai")
end

--@api-stub: SteeringManager:setCombineMode
do -- SteeringManager:setCombineMode
  local sm = lurek.ai.newSteeringManager()
  sm:addSeek(400, 300, 1.0)
  sm:setCombineMode("priority")
end

--@api-stub: SteeringManager:getCombineMode
do -- SteeringManager:getCombineMode
  local sm = lurek.ai.newSteeringManager()
  sm:addSeek(400, 300, 1.0)
  if sm:getCombineMode() == "weighted_sum" then lurek.log.debug("blend mode", "ai") end
end

--@api-stub: SteeringManager:getLastSteering
do -- SteeringManager:getLastSteering
  local sm = lurek.ai.newSteeringManager()
  sm:addSeek(400, 300, 1.0)
  local fx, fy = sm:getLastSteering()
  if fx ~= 0 or fy ~= 0 then lurek.log.debug("steering active", "ai") end
end

--@api-stub: SteeringManager:type
do -- SteeringManager:type
  local sm = lurek.ai.newSteeringManager()
  sm:addSeek(400, 300, 1.0)
  if sm:type() == "SteeringManager" then lurek.log.debug("ok", "ai") end
end

--@api-stub: SteeringManager:typeOf
do -- SteeringManager:typeOf
  local sm = lurek.ai.newSteeringManager()
  sm:addSeek(400, 300, 1.0)
  if sm:typeOf("Object") then lurek.log.debug("ok", "ai") end
end

--@api-stub: SteeringManager:setSpatialHashCellSize
do -- SteeringManager:setSpatialHashCellSize
  local sm = lurek.ai.newSteeringManager()
  sm:addSeek(400, 300, 1.0)
  sm:enableSpatialHash(true)
  sm:setSpatialHashCellSize(64)
end

--@api-stub: SteeringManager:enableSpatialHash
do -- SteeringManager:enableSpatialHash
  local sm = lurek.ai.newSteeringManager()
  sm:addSeek(400, 300, 1.0)
  sm:enableSpatialHash(true)
end

--@api-stub: QLearner:chooseAction
do -- QLearner:chooseAction
  local ql = lurek.ai.newQLearner(8, 4)
  local action = ql:chooseAction(1)
  lurek.log.debug("action=" .. action, "ai")
end

--@api-stub: QLearner:bestAction
do -- QLearner:bestAction
  local ql = lurek.ai.newQLearner(8, 4)
  local action = ql:bestAction(1)
  if action >= 1 then lurek.log.debug("greedy=" .. action, "ai") end
end

--@api-stub: QLearner:getQValue
do -- QLearner:getQValue
  local ql = lurek.ai.newQLearner(8, 4)
  ql:learn(1, 2, 1.0, 3)
  local q = ql:getQValue(1, 2)
  lurek.log.debug("Q(1,2)=" .. q, "ai")
end

--@api-stub: QLearner:endEpisode
do -- QLearner:endEpisode
  local ql = lurek.ai.newQLearner(8, 4)
  ql:learn(1, 1, 0.5, 2)
  ql:endEpisode()
end

--@api-stub: QLearner:getEpisodeCount
do -- QLearner:getEpisodeCount
  local ql = lurek.ai.newQLearner(8, 4)
  ql:endEpisode()
  lurek.log.debug("episodes=" .. ql:getEpisodeCount(), "ai")
end

--@api-stub: QLearner:getStateCount
do -- QLearner:getStateCount
  local ql = lurek.ai.newQLearner(8, 4)
  lurek.log.debug("states=" .. ql:getStateCount(), "ai")
end

--@api-stub: QLearner:getActionCount
do -- QLearner:getActionCount
  local ql = lurek.ai.newQLearner(8, 4)
  for a = 1, ql:getActionCount() do lurek.log.debug("a=" .. a, "ai") end
end

--@api-stub: QLearner:setLearningRate
do -- QLearner:setLearningRate
  local ql = lurek.ai.newQLearner(8, 4)
  ql:setLearningRate(0.05)
end

--@api-stub: QLearner:getLearningRate
do -- QLearner:getLearningRate
  local ql = lurek.ai.newQLearner(8, 4)
  lurek.log.debug("alpha=" .. ql:getLearningRate(), "ai")
end

--@api-stub: QLearner:setDiscountFactor
do -- QLearner:setDiscountFactor
  local ql = lurek.ai.newQLearner(8, 4)
  ql:setDiscountFactor(0.95)
end

--@api-stub: QLearner:getDiscountFactor
do -- QLearner:getDiscountFactor
  local ql = lurek.ai.newQLearner(8, 4)
  lurek.log.debug("gamma=" .. ql:getDiscountFactor(), "ai")
end

--@api-stub: QLearner:setExplorationRate
do -- QLearner:setExplorationRate
  local ql = lurek.ai.newQLearner(8, 4)
  ql:setExplorationRate(0.1)
end

--@api-stub: QLearner:getExplorationRate
do -- QLearner:getExplorationRate
  local ql = lurek.ai.newQLearner(8, 4)
  if ql:getExplorationRate() < 0.05 then lurek.log.info("exploit phase", "ai") end
end

--@api-stub: QLearner:setExplorationDecay
do -- QLearner:setExplorationDecay
  local ql = lurek.ai.newQLearner(8, 4)
  ql:setExplorationDecay(0.995)
end

--@api-stub: QLearner:getExplorationDecay
do -- QLearner:getExplorationDecay
  local ql = lurek.ai.newQLearner(8, 4)
  lurek.log.debug("decay=" .. ql:getExplorationDecay(), "ai")
end

--@api-stub: QLearner:serialize
do -- QLearner:serialize
  local ql = lurek.ai.newQLearner(8, 4)
  ql:learn(1, 1, 1.0, 2)
  local json = ql:serialize()
  lurek.log.info("saved " .. #json .. " bytes", "ai")
end

--@api-stub: QLearner:deserialize
do -- QLearner:deserialize
  local ql = lurek.ai.newQLearner(8, 4)
  local saved = ql:serialize()
  ql:deserialize(saved)
end

--@api-stub: QLearner:type
do -- QLearner:type
  local ql = lurek.ai.newQLearner(8, 4)
  if ql:type() == "QLearner" then lurek.log.debug("ok", "ai") end
end

--@api-stub: QLearner:typeOf
do -- QLearner:typeOf
  local ql = lurek.ai.newQLearner(8, 4)
  if ql:typeOf("Object") then lurek.log.debug("ok", "ai") end
end

--@api-stub: UtilityAI:evaluate
do -- UtilityAI:evaluate
  local uai = lurek.ai.newUtilityAI()
  uai:addAction("flee", function() return 0.8 end)
  uai:addAction("attack", function() return 0.4 end)
  local choice = uai:evaluate()
  if choice then lurek.log.info("chose " .. choice, "ai") end
end

--@api-stub: UtilityAI:getActionCount
do -- UtilityAI:getActionCount
  local uai = lurek.ai.newUtilityAI()
  uai:addAction("flee", function() return 0.8 end)
  uai:addAction("attack", function() return 0.4 end)
  lurek.log.debug("actions=" .. uai:getActionCount(), "ai")
end

--@api-stub: UtilityAI:getLastAction
do -- UtilityAI:getLastAction
  local uai = lurek.ai.newUtilityAI()
  uai:addAction("flee", function() return 0.8 end)
  uai:addAction("attack", function() return 0.4 end)
  uai:evaluate()
  local last = uai:getLastAction()
  if last then lurek.log.debug("last=" .. last, "ai") end
end

--@api-stub: UtilityAI:type
do -- UtilityAI:type
  local uai = lurek.ai.newUtilityAI()
  uai:addAction("flee", function() return 0.8 end)
  uai:addAction("attack", function() return 0.4 end)
  if uai:type() == "UtilityAI" then lurek.log.debug("ok", "ai") end
end

--@api-stub: UtilityAI:typeOf
do -- UtilityAI:typeOf
  local uai = lurek.ai.newUtilityAI()
  uai:addAction("flee", function() return 0.8 end)
  uai:addAction("attack", function() return 0.4 end)
  if uai:typeOf("Object") then lurek.log.debug("ok", "ai") end
end

--@api-stub: GOAPPlanner:getActionCount
do -- GOAPPlanner:getActionCount
  local p = lurek.ai.newGOAPPlanner()
  p:addAction("eat", 1.0, function() end)
  p:addGoal("not_hungry", 1.0)
  lurek.log.debug("actions=" .. p:getActionCount(), "ai")
end

--@api-stub: GOAPPlanner:getGoalCount
do -- GOAPPlanner:getGoalCount
  local p = lurek.ai.newGOAPPlanner()
  p:addAction("eat", 1.0, function() end)
  p:addGoal("not_hungry", 1.0)
  if p:getGoalCount() == 0 then lurek.log.warn("no goals", "ai") end
end

--@api-stub: GOAPPlanner:getMaxIterations
do -- GOAPPlanner:getMaxIterations
  local p = lurek.ai.newGOAPPlanner()
  p:addAction("eat", 1.0, function() end)
  p:addGoal("not_hungry", 1.0)
  lurek.log.debug("max iters=" .. p:getMaxIterations(), "ai")
end

--@api-stub: GOAPPlanner:setMaxIterations
do -- GOAPPlanner:setMaxIterations
  local p = lurek.ai.newGOAPPlanner()
  p:addAction("eat", 1.0, function() end)
  p:addGoal("not_hungry", 1.0)
  p:setMaxIterations(500)
end

--@api-stub: GOAPPlanner:type
do -- GOAPPlanner:type
  local p = lurek.ai.newGOAPPlanner()
  p:addAction("eat", 1.0, function() end)
  p:addGoal("not_hungry", 1.0)
  if p:type() == "GOAPPlanner" then lurek.log.debug("ok", "ai") end
end

--@api-stub: GOAPPlanner:typeOf
do -- GOAPPlanner:typeOf
  local p = lurek.ai.newGOAPPlanner()
  p:addAction("eat", 1.0, function() end)
  p:addGoal("not_hungry", 1.0)
  if p:typeOf("Object") then lurek.log.debug("ok", "ai") end
end
-- do  -- InfluenceMap:addLayer
--   local im = lurek.ai.newInfluenceMap(32, 32, 16)
--   im:addLayer("threat")
--   im:addLayer("loot")
-- end

--@api-stub: InfluenceMap:hasLayer
do -- InfluenceMap:hasLayer
  local im = lurek.ai.newInfluenceMap(32, 32, 16)
  im:addLayer("threat")
  if im:hasLayer("threat") then lurek.log.debug("layer ok", "ai") end
end

--@api-stub: InfluenceMap:decay
do -- InfluenceMap:decay
  local im = lurek.ai.newInfluenceMap(32, 32, 16)
  im:addLayer("threat")
  im:stampInfluence("threat", 100, 100, 64, 1.0, 1.0)
  function lurek.process(dt) im:decay("threat", 0.97) end
end

--@api-stub: InfluenceMap:clearLayer
do -- InfluenceMap:clearLayer
  local im = lurek.ai.newInfluenceMap(32, 32, 16)
  im:addLayer("threat")
  im:stampInfluence("threat", 100, 100, 64, 1.0, 1.0)
  im:clearLayer("threat")
end

--@api-stub: InfluenceMap:clearAll
do -- InfluenceMap:clearAll
  local im = lurek.ai.newInfluenceMap(32, 32, 16)
  im:addLayer("threat")
  im:clearAll()
end

--@api-stub: InfluenceMap:getMaxPosition
do -- InfluenceMap:getMaxPosition
  local im = lurek.ai.newInfluenceMap(32, 32, 16)
  im:addLayer("threat")
  im:stampInfluence("threat", 200, 100, 32, 1.0, 1.0)
  local mx, my = im:getMaxPosition("threat")
  lurek.log.debug("hot=" .. mx .. "," .. my, "ai")
end

--@api-stub: InfluenceMap:getMinPosition
do -- InfluenceMap:getMinPosition
  local im = lurek.ai.newInfluenceMap(32, 32, 16)
  im:addLayer("threat")
  im:stampInfluence("threat", 200, 100, 32, 1.0, 1.0)
  local sx, sy = im:getMinPosition("threat")
  lurek.log.debug("safe=" .. sx .. "," .. sy, "ai")
end

--@api-stub: InfluenceMap:getWidth
do -- InfluenceMap:getWidth
  local im = lurek.ai.newInfluenceMap(32, 32, 16)
  im:addLayer("threat")
  lurek.log.debug("w=" .. im:getWidth(), "ai")
end

--@api-stub: InfluenceMap:getHeight
do -- InfluenceMap:getHeight
  local im = lurek.ai.newInfluenceMap(32, 32, 16)
  im:addLayer("threat")
  lurek.log.debug("h=" .. im:getHeight(), "ai")
end

--@api-stub: InfluenceMap:getCellSize
do -- InfluenceMap:getCellSize
  local im = lurek.ai.newInfluenceMap(32, 32, 16)
  im:addLayer("threat")
  lurek.log.debug("cell=" .. im:getCellSize(), "ai")
end

--@api-stub: InfluenceMap:type
do -- InfluenceMap:type
  local im = lurek.ai.newInfluenceMap(32, 32, 16)
  im:addLayer("threat")
  if im:type() == "InfluenceMap" then lurek.log.debug("ok", "ai") end
end

--@api-stub: InfluenceMap:typeOf
do -- InfluenceMap:typeOf
  local im = lurek.ai.newInfluenceMap(32, 32, 16)
  im:addLayer("threat")
  if im:typeOf("Object") then lurek.log.debug("ok", "ai") end
end

--@api-stub: Squad:getName
do -- Squad:getName
  local sq = lurek.ai.newSquad("alpha")
  sq:addMember("guard_01")
  lurek.log.debug("squad=" .. sq:getName(), "ai")
end

--@api-stub: Squad:addMember
do -- Squad:addMember
  local sq = lurek.ai.newSquad("alpha")
  sq:addMember("guard_01")
  sq:addMember("guard_02")
  sq:addMember("scout_03")
end

--@api-stub: Squad:removeMember
do -- Squad:removeMember
  local sq = lurek.ai.newSquad("alpha")
  sq:addMember("guard_01")
  sq:addMember("doomed")
  sq:removeMember("doomed")
end

--@api-stub: Squad:getMemberCount
do -- Squad:getMemberCount
  local sq = lurek.ai.newSquad("alpha")
  sq:addMember("guard_01")
  if sq:getMemberCount() == 0 then lurek.log.warn("squad wiped", "ai") end
end

--@api-stub: Squad:getMembers
do -- Squad:getMembers
  local sq = lurek.ai.newSquad("alpha")
  sq:addMember("guard_01")
  sq:addMember("guard_02")
  for _, m in ipairs(sq:getMembers()) do lurek.log.debug("m=" .. m, "ai") end
end

--@api-stub: Squad:setLeader
do -- Squad:setLeader
  local sq = lurek.ai.newSquad("alpha")
  sq:addMember("guard_01")
  sq:setLeader("guard_01")
end

--@api-stub: Squad:getLeader
do -- Squad:getLeader
  local sq = lurek.ai.newSquad("alpha")
  sq:addMember("guard_01")
  sq:setLeader("guard_01")
  local l = sq:getLeader()
  if l then lurek.log.debug("leader=" .. l, "ai") end
end

--@api-stub: Squad:getFormation
do -- Squad:getFormation
  local sq = lurek.ai.newSquad("alpha")
  sq:addMember("guard_01")
  sq:setFormation("wedge", 32)
  if sq:getFormation() == "wedge" then lurek.log.debug("v formation", "ai") end
end

--@api-stub: Squad:getFormationSpacing
do -- Squad:getFormationSpacing
  local sq = lurek.ai.newSquad("alpha")
  sq:addMember("guard_01")
  sq:setFormation("line", 48)
  lurek.log.debug("spacing=" .. sq:getFormationSpacing(), "ai")
end

--@api-stub: Squad:getBlackboard
do -- Squad:getBlackboard
  local sq = lurek.ai.newSquad("alpha")
  sq:addMember("guard_01")
  local bb = sq:getBlackboard()
  bb:setString("objective", "capture_point_a")
end

--@api-stub: Squad:type
do -- Squad:type
  local sq = lurek.ai.newSquad("alpha")
  sq:addMember("guard_01")
  if sq:type() == "Squad" then lurek.log.debug("ok", "ai") end
end

--@api-stub: Squad:typeOf
do -- Squad:typeOf
  local sq = lurek.ai.newSquad("alpha")
  sq:addMember("guard_01")
  if sq:typeOf("Object") then lurek.log.debug("ok", "ai") end
end

--@api-stub: CommandQueue:cancelCurrent
do -- CommandQueue:cancelCurrent
  local cq = lurek.ai.newCommandQueue()
  cq:enqueue("move", function() end, { targetX = 200, targetY = 100 })
  if cq:cancelCurrent() then lurek.log.debug("cancelled", "ai") end
end

--@api-stub: CommandQueue:clear
do -- CommandQueue:clear
  local cq = lurek.ai.newCommandQueue()
  cq:enqueue("move", function() end, { targetX = 200, targetY = 100 })
  cq:enqueue("attack", function() end)
  cq:clear()
end

--@api-stub: CommandQueue:getCount
do -- CommandQueue:getCount
  local cq = lurek.ai.newCommandQueue()
  cq:enqueue("move", function() end, { targetX = 200, targetY = 100 })
  lurek.log.debug("queue=" .. cq:getCount(), "ai")
end

--@api-stub: CommandQueue:isEmpty
do -- CommandQueue:isEmpty
  local cq = lurek.ai.newCommandQueue()
  cq:enqueue("move", function() end, { targetX = 200, targetY = 100 })
  cq:clear()
  if cq:isEmpty() then lurek.log.debug("idle", "ai") end
end

--@api-stub: CommandQueue:getCurrentType
do -- CommandQueue:getCurrentType
  local cq = lurek.ai.newCommandQueue()
  cq:enqueue("move", function() end, { targetX = 200, targetY = 100 })
  local kind = cq:getCurrentType()
  if kind then lurek.log.debug("doing " .. kind, "ai") end
end

--@api-stub: CommandQueue:getCurrentTarget
do -- CommandQueue:getCurrentTarget
  local cq = lurek.ai.newCommandQueue()
  cq:enqueue("move", function() end, { targetX = 200, targetY = 100 })
  local tx, ty = cq:getCurrentTarget()
  lurek.log.debug("target=" .. tx .. "," .. ty, "ai")
end

--@api-stub: CommandQueue:type
do -- CommandQueue:type
  local cq = lurek.ai.newCommandQueue()
  cq:enqueue("move", function() end, { targetX = 200, targetY = 100 })
  if cq:type() == "CommandQueue" then lurek.log.debug("ok", "ai") end
end

--@api-stub: CommandQueue:typeOf
do -- CommandQueue:typeOf
  local cq = lurek.ai.newCommandQueue()
  cq:enqueue("move", function() end, { targetX = 200, targetY = 100 })
  if cq:typeOf("Object") then lurek.log.debug("ok", "ai") end
end

--@api-stub: TraitProfile:set
do -- TraitProfile:set
  local tp = lurek.ai.newTraitProfile()
  tp:set("aggression", 0.7)
  tp:set("courage", 0.5)
end

--@api-stub: TraitProfile:get
do -- TraitProfile:get
  local tp = lurek.ai.newTraitProfile()
  tp:set("aggression", 0.7)
  local v = tp:get("aggression")
  if v > 0.6 then lurek.log.debug("aggressive", "ai") end
end

--@api-stub: TraitProfile:getBase
do -- TraitProfile:getBase
  local tp = lurek.ai.newTraitProfile()
  tp:set("aggression", 0.7)
  local base = tp:getBase("aggression")
  lurek.log.debug("base=" .. base, "ai")
end

--@api-stub: TraitProfile:removeModifiers
do -- TraitProfile:removeModifiers
  local tp = lurek.ai.newTraitProfile()
  tp:set("aggression", 0.7)
  tp:addModifier("aggression", 0.2, 10.0, "rage_potion")
  tp:removeModifiers("rage_potion")
end

--@api-stub: TraitProfile:update
do -- TraitProfile:update
  local tp = lurek.ai.newTraitProfile()
  tp:set("aggression", 0.7)
  tp:addModifier("aggression", 0.2, 5.0, "buff")
  function lurek.process(dt) tp:update(dt) end
end

--@api-stub: TraitProfile:has
do -- TraitProfile:has
  local tp = lurek.ai.newTraitProfile()
  tp:set("aggression", 0.7)
  if tp:has("aggression") then lurek.log.debug("trait set", "ai") end
end

--@api-stub: TraitProfile:traitCount
do -- TraitProfile:traitCount
  local tp = lurek.ai.newTraitProfile()
  tp:set("aggression", 0.7)
  lurek.log.debug("traits=" .. tp:traitCount(), "ai")
end

--@api-stub: TraitProfile:archetype
do -- TraitProfile:archetype
  local tp = lurek.ai.newTraitProfile()
  tp:set("aggression", 0.7)
  local arch = tp:archetype()
  if arch then lurek.log.info("archetype=" .. arch, "ai") end
end

--@api-stub: StimulusWorld:remove
do -- StimulusWorld:remove
  local sw = lurek.ai.newStimulusWorld()
  local id = sw:addAuditory(100, 200, 1.0, 150, 0.5, "footstep")
  if sw:remove(id) then lurek.log.debug("removed " .. id, "ai") end
end

--@api-stub: StimulusWorld:update
do -- StimulusWorld:update
  local sw = lurek.ai.newStimulusWorld()
  local id = sw:addAuditory(100, 200, 1.0, 150, 0.5, "footstep")
  function lurek.process(dt) sw:update(dt) end
end

--@api-stub: StimulusWorld:clear
do -- StimulusWorld:clear
  local sw = lurek.ai.newStimulusWorld()
  local id = sw:addAuditory(100, 200, 1.0, 150, 0.5, "footstep")
  sw:clear()
end

--@api-stub: ContextSteering:addWander
do -- ContextSteering:addWander
  local cs = lurek.ai.newContextSteering(16)
  cs:addSeekTarget(500, 300, 1.0)
  cs:addWander(0.5, 0.3)
end

--@api-stub: ContextSteering:addAvoidBounds
do -- ContextSteering:addAvoidBounds
  local cs = lurek.ai.newContextSteering(16)
  cs:addSeekTarget(500, 300, 1.0)
  cs:addAvoidBounds(0, 0, 1280, 720, 32, 1.0)
end

--@api-stub: ContextSteering:clearBehaviors
do -- ContextSteering:clearBehaviors
  local cs = lurek.ai.newContextSteering(16)
  cs:addSeekTarget(500, 300, 1.0)
  cs:clearBehaviors()
end

--@api-stub: ContextSteering:chosenMagnitude
do -- ContextSteering:chosenMagnitude
  local cs = lurek.ai.newContextSteering(16)
  cs:addSeekTarget(500, 300, 1.0)
  cs:evaluate(0, 0, 0, 0)
  lurek.log.debug("mag=" .. cs:chosenMagnitude(), "ai")
end

--@api-stub: ContextSteering:slotCount
do -- ContextSteering:slotCount
  local cs = lurek.ai.newContextSteering(16)
  cs:addSeekTarget(500, 300, 1.0)
  lurek.log.debug("slots=" .. cs:slotCount(), "ai")
end

--@api-stub: NeedSystem:addNeed
do -- NeedSystem:addNeed
  local ns = lurek.ai.newNeedSystem()
  ns:addNeed("hunger", 0.05, 0.6, 1.5)
  ns:addNeed("thirst", 0.08, 0.5, 2.0)
end

--@api-stub: NeedSystem:update
do -- NeedSystem:update
  local ns = lurek.ai.newNeedSystem()
  ns:addNeed("hunger", 0.05, 0.6, 1.5)
  function lurek.process(dt) ns:update(dt) end
end

--@api-stub: NeedSystem:mostUrgent
do -- NeedSystem:mostUrgent
  local ns = lurek.ai.newNeedSystem()
  ns:addNeed("hunger", 0.05, 0.6, 1.5)
  local n = ns:mostUrgent()
  if n then lurek.log.debug("urgent: " .. n, "ai") end
end

--@api-stub: NeedSystem:satisfy
do -- NeedSystem:satisfy
  local ns = lurek.ai.newNeedSystem()
  ns:addNeed("hunger", 0.05, 0.6, 1.5)
  ns:satisfy("hunger", 0.4)
end

--@api-stub: NeedSystem:valueOf
do -- NeedSystem:valueOf
  local ns = lurek.ai.newNeedSystem()
  ns:addNeed("hunger", 0.05, 0.6, 1.5)
  if ns:valueOf("hunger") > 0.8 then lurek.log.warn("starving", "ai") end
end

--@api-stub: AIDirector:pushEvent
do -- AIDirector:pushEvent
  local dir = lurek.ai.newAIDirector()
  dir:pushEvent(0.7)
end

--@api-stub: AIDirector:update
do -- AIDirector:update
  local dir = lurek.ai.newAIDirector()
  function lurek.process(dt) dir:update(dt) end
end

--@api-stub: AIDirector:tension
do -- AIDirector:tension
  local dir = lurek.ai.newAIDirector()
  dir:pushEvent(0.5)
  lurek.log.debug("tension=" .. dir:tension(), "ai")
end

--@api-stub: AIDirector:phase
do -- AIDirector:phase
  local dir = lurek.ai.newAIDirector()
  if dir:phase() == "peak" then lurek.log.info("intense moment", "ai") end
end

--@api-stub: AIDirector:spawnRateFactor
do -- AIDirector:spawnRateFactor
  local dir = lurek.ai.newAIDirector()
  local mult = dir:spawnRateFactor()
  lurek.log.debug("spawn x" .. mult, "ai")
end

--@api-stub: AIDirector:lootFactor
do -- AIDirector:lootFactor
  local dir = lurek.ai.newAIDirector()
  lurek.log.debug("loot x" .. dir:lootFactor(), "ai")
end

--@api-stub: AIDirector:ambientIntensity
do -- AIDirector:ambientIntensity
  local dir = lurek.ai.newAIDirector()
  local amb = dir:ambientIntensity()
  if amb > 0.5 then lurek.log.debug("loud ambience", "ai") end
end

--@api-stub: AIDirector:setTension
do -- AIDirector:setTension
  local dir = lurek.ai.newAIDirector()
  dir:setTension(0.9)
end

--@api-stub: AIDirector:reset
do -- AIDirector:reset
  local dir = lurek.ai.newAIDirector()
  dir:reset()
end

--@api-stub: HTNDomain:addPrimitive
do -- HTNDomain:addPrimitive
  local d = lurek.ai.newHTNDomain()
  d:addPrimitive("attack", { "has_weapon", "in_range" }, { "enemy_dead" }, { "in_range" })
end

--@api-stub: HTNDomain:taskCount
do -- HTNDomain:taskCount
  local d = lurek.ai.newHTNDomain()
  d:addPrimitive("rest", {}, { "rested" }, {})
  lurek.log.debug("tasks=" .. d:taskCount(), "ai")
end

--@api-stub: EmotionModel:trigger
do -- EmotionModel:trigger
  local em = lurek.ai.newEmotionModel()
  em:add("fear", 0.0, 0.1, 0.2)
  em:trigger("fear", 0.5)
end

--@api-stub: EmotionModel:get
do -- EmotionModel:get
  local em = lurek.ai.newEmotionModel()
  em:add("fear", 0.0, 0.1, 0.2)
  em:trigger("fear", 0.4)
  if em:get("fear") > 0.3 then lurek.log.debug("scared", "ai") end
end

--@api-stub: EmotionModel:dominant
do -- EmotionModel:dominant
  local em = lurek.ai.newEmotionModel()
  em:add("fear", 0.0, 0.1, 0.2)
  em:trigger("fear", 0.6)
  local d = em:dominant()
  if d then lurek.log.info("feeling " .. d, "ai") end
end

--@api-stub: EmotionModel:isActive
do -- EmotionModel:isActive
  local em = lurek.ai.newEmotionModel()
  em:add("fear", 0.0, 0.1, 0.2)
  em:trigger("fear", 0.5)
  if em:isActive("fear") then lurek.log.debug("show fear face", "ai") end
end

--@api-stub: EmotionModel:update
do -- EmotionModel:update
  local em = lurek.ai.newEmotionModel()
  em:add("fear", 0.0, 0.1, 0.2)
  function lurek.process(dt) em:update(dt) end
end

--@api-stub: EmotionModel:reset
do -- EmotionModel:reset
  local em = lurek.ai.newEmotionModel()
  em:add("fear", 0.0, 0.1, 0.2)
  em:reset()
end

--@api-stub: ORCASolver:setPosition
do -- ORCASolver:setPosition
  local orca = lurek.ai.newORCASolver(2.0)
  local idx = orca:addAgent(100, 100, 16, 80)
  orca:setPosition(idx, 120, 100)
end

--@api-stub: ORCASolver:compute
do -- ORCASolver:compute
  local orca = lurek.ai.newORCASolver(2.0)
  local idx = orca:addAgent(100, 100, 16, 80)
  function lurek.process(dt) orca:compute(dt) end
end

--@api-stub: ORCASolver:getSafeVelocity
do -- ORCASolver:getSafeVelocity
  local orca = lurek.ai.newORCASolver(2.0)
  local idx = orca:addAgent(100, 100, 16, 80)
  orca:compute(0.016)
  local vx, vy = orca:getSafeVelocity(idx)
  lurek.log.debug("safe v=" .. vx .. "," .. vy, "ai")
end

--@api-stub: ORCASolver:agentCount
do -- ORCASolver:agentCount
  local orca = lurek.ai.newORCASolver(2.0)
  local idx = orca:addAgent(100, 100, 16, 80)
  lurek.log.debug("agents=" .. orca:agentCount(), "ai")
end

--@api-stub: NeuralNet:forward
do -- NeuralNet:forward
  local nn = lurek.ai.newNeuralNet()
  nn:addLayer(4, 8, "relu")
  nn:addLayer(8, 2, "softmax")
  local out = nn:forward({ 0.1, 0.2, 0.3, 0.4 })
  lurek.log.debug("y=" .. out[1] .. "," .. out[2], "ai")
end

--@api-stub: NeuralNet:setWeights
do -- NeuralNet:setWeights
  local nn = lurek.ai.newNeuralNet()
  nn:addLayer(4, 8, "relu")
  nn:addLayer(8, 2, "softmax")
  local count = nn:paramCount()
  local zeros = {}; for i = 1, count do zeros[i] = 0.01 end
  nn:setWeights(zeros)
end

--@api-stub: NeuralNet:getWeights
do -- NeuralNet:getWeights
  local nn = lurek.ai.newNeuralNet()
  nn:addLayer(4, 8, "relu")
  nn:addLayer(8, 2, "softmax")
  local w = nn:getWeights()
  lurek.log.debug("weights=" .. #w, "ai")
end

--@api-stub: NeuralNet:paramCount
do -- NeuralNet:paramCount
  local nn = lurek.ai.newNeuralNet()
  nn:addLayer(4, 8, "relu")
  nn:addLayer(8, 2, "softmax")
  lurek.log.debug("params=" .. nn:paramCount(), "ai")
end

--@api-stub: NeuralNet:layerCount
do -- NeuralNet:layerCount
  local nn = lurek.ai.newNeuralNet()
  nn:addLayer(4, 8, "relu")
  nn:addLayer(8, 2, "softmax")
  lurek.log.debug("layers=" .. nn:layerCount(), "ai")
end

--@api-stub: GeneticAlgorithm:evolve
do -- GeneticAlgorithm:evolve
  local ga = lurek.ai.newGeneticAlgorithm(20, 8, 42)
  for i = 1, ga:popSize() do ga:setFitness(i - 1, 0.5) end
  ga:evolve()
end

--@api-stub: GeneticAlgorithm:generation
do -- GeneticAlgorithm:generation
  local ga = lurek.ai.newGeneticAlgorithm(20, 8, 42)
  if ga:generation() >= 100 then lurek.log.info("done", "ai") end
end

--@api-stub: GeneticAlgorithm:popSize
do -- GeneticAlgorithm:popSize
  local ga = lurek.ai.newGeneticAlgorithm(20, 8, 42)
  lurek.log.debug("pop=" .. ga:popSize(), "ai")
end

--@api-stub: GeneticAlgorithm:setFitness
do -- GeneticAlgorithm:setFitness
  local ga = lurek.ai.newGeneticAlgorithm(20, 8, 42)
  for i = 0, ga:popSize() - 1 do ga:setFitness(i, math.random()) end
end

--@api-stub: GeneticAlgorithm:getGenes
do -- GeneticAlgorithm:getGenes
  local ga = lurek.ai.newGeneticAlgorithm(20, 8, 42)
  local genes = ga:getGenes(0)
  lurek.log.debug("g0=" .. genes[1], "ai")
end

--@api-stub: GeneticAlgorithm:bestGenes
do -- GeneticAlgorithm:bestGenes
  local ga = lurek.ai.newGeneticAlgorithm(20, 8, 42)
  ga:setFitness(0, 1.0)
  local best = ga:bestGenes()
  lurek.log.debug("best[1]=" .. best[1], "ai")
end

--@api-stub: Bandit:select
do -- Bandit:select
  local b = lurek.ai.newBandit(4, "ucb1", 0.1, 99)
  local arm = b:select()
  lurek.log.debug("arm=" .. arm, "ai")
end

--@api-stub: Bandit:update
do -- Bandit:update
  local b = lurek.ai.newBandit(4, "ucb1", 0.1, 99)
  local arm = b:select()
  b:update(arm, 1.0)
end

--@api-stub: Bandit:bestArm
do -- Bandit:bestArm
  local b = lurek.ai.newBandit(4, "ucb1", 0.1, 99)
  b:update(0, 0.7); b:update(1, 0.3)
  lurek.log.debug("best arm=" .. b:bestArm(), "ai")
end

--@api-stub: Bandit:reset
do -- Bandit:reset
  local b = lurek.ai.newBandit(4, "ucb1", 0.1, 99)
  b:reset()
end

--@api-stub: Bandit:armCount
do -- Bandit:armCount
  local b = lurek.ai.newBandit(4, "ucb1", 0.1, 99)
  lurek.log.debug("arms=" .. b:armCount(), "ai")
end

--@api-stub: Bandit:totalPulls
do -- Bandit:totalPulls
  local b = lurek.ai.newBandit(4, "ucb1", 0.1, 99)
  b:select(); b:select()
  lurek.log.debug("pulls=" .. b:totalPulls(), "ai")
end

--@api-stub: Neuroevolution:evolve
do -- Neuroevolution:evolve
  local layers = { { inputs = 2, outputs = 4, activation = "relu" }, { inputs = 4, outputs = 1, activation = "tanh" } }
  local ne = lurek.ai.newNeuroevolution(layers, 10, 1)
  for i = 0, ne:popSize() - 1 do ne:setFitness(i, 0.5) end
  ne:evolve()
end

--@api-stub: Neuroevolution:setFitness
do -- Neuroevolution:setFitness
  local layers = { { inputs = 2, outputs = 4, activation = "relu" }, { inputs = 4, outputs = 1, activation = "tanh" } }
  local ne = lurek.ai.newNeuroevolution(layers, 10, 1)
  ne:setFitness(0, 0.85)
end

--@api-stub: Neuroevolution:chromosomeToNet
do -- Neuroevolution:chromosomeToNet
  local layers = { { inputs = 2, outputs = 4, activation = "relu" }, { inputs = 4, outputs = 1, activation = "tanh" } }
  local ne = lurek.ai.newNeuroevolution(layers, 10, 1)
  local net = ne:chromosomeToNet(0)
  if net then lurek.log.debug("net layers=" .. net:layerCount(), "ai") end
end

--@api-stub: Neuroevolution:bestNetwork
do -- Neuroevolution:bestNetwork
  local layers = { { inputs = 2, outputs = 4, activation = "relu" }, { inputs = 4, outputs = 1, activation = "tanh" } }
  local ne = lurek.ai.newNeuroevolution(layers, 10, 1)
  ne:setFitness(0, 1.0)
  local best = ne:bestNetwork()
  if best then lurek.log.debug("ok", "ai") end
end

--@api-stub: Neuroevolution:bestFitness
do -- Neuroevolution:bestFitness
  local layers = { { inputs = 2, outputs = 4, activation = "relu" }, { inputs = 4, outputs = 1, activation = "tanh" } }
  local ne = lurek.ai.newNeuroevolution(layers, 10, 1)
  ne:setFitness(0, 0.7)
  lurek.log.debug("best=" .. ne:bestFitness(), "ai")
end

--@api-stub: Neuroevolution:popSize
do -- Neuroevolution:popSize
  local layers = { { inputs = 2, outputs = 4, activation = "relu" }, { inputs = 4, outputs = 1, activation = "tanh" } }
  local ne = lurek.ai.newNeuroevolution(layers, 10, 1)
  lurek.log.debug("pop=" .. ne:popSize(), "ai")
end

--@api-stub: Neuroevolution:generation
do -- Neuroevolution:generation
  local layers = { { inputs = 2, outputs = 4, activation = "relu" }, { inputs = 4, outputs = 1, activation = "tanh" } }
  local ne = lurek.ai.newNeuroevolution(layers, 10, 1)
  if ne:generation() >= 50 then lurek.log.info("converged", "ai") end
end

--@api-stub: StrategyAI:addGoal
do -- StrategyAI:addGoal
  local s = lurek.ai.newStrategyAI(2.0)
  s:addGoal("expand")
  s:addGoal("defend")
end

--@api-stub: StrategyAI:addTag
do -- StrategyAI:addTag
  local s = lurek.ai.newStrategyAI(2.0)
  s:addTag("early_game")
end

--@api-stub: StrategyAI:removeTag
do -- StrategyAI:removeTag
  local s = lurek.ai.newStrategyAI(2.0)
  s:addTag("scout_phase")
  s:removeTag("scout_phase")
end

--@api-stub: StrategyAI:update
do -- StrategyAI:update
  local s = lurek.ai.newStrategyAI(2.0)
  s:addGoal("expand")
  function lurek.process(dt) s:update(dt, function(goal) return 0.5 end) end
end

--@api-stub: StrategyAI:forceEvaluate
do -- StrategyAI:forceEvaluate
  local s = lurek.ai.newStrategyAI(2.0)
  s:addGoal("retreat")
  s:forceEvaluate(function(goal) return goal == "retreat" and 1.0 or 0.0 end)
end

--@api-stub: StrategyAI:activeGoal
do -- StrategyAI:activeGoal
  local s = lurek.ai.newStrategyAI(2.0)
  s:addGoal("hold"); s:forceEvaluate(function(g) return 1.0 end)
  local g = s:activeGoal()
  if g then lurek.log.info("strategy=" .. g, "ai") end
end

--@api-stub: StrategyAI:timeUntilNext
do -- StrategyAI:timeUntilNext
  local s = lurek.ai.newStrategyAI(2.0)
  lurek.log.debug("next eval in " .. s:timeUntilNext(), "ai")
end

--@api-stub: AILod:shouldUpdate
do -- AILod:shouldUpdate
  local lod = lurek.ai.newAILod()
  if lod:shouldUpdate(1, 60) then lurek.log.debug("tier 1 tick", "ai") end
end

--@api-stub: AILod:tierCount
do -- AILod:tierCount
  local lod = lurek.ai.newAILod()
  lurek.log.debug("tiers=" .. lod:tierCount(), "ai")
end

--@api-stub: AILod:tierName
do -- AILod:tierName
  local lod = lurek.ai.newAILod()
  local n = lod:tierName(0)
  if n then lurek.log.debug("tier 0=" .. n, "ai") end
end


-- =============================================================================
-- Lua Extensibility Hooks (Phase 01)
-- =============================================================================

--@api-stub: Agent:setCustomModel
do -- Agent:setCustomModel
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("custom_agent")
  agent:setCustomModel(function(ag, bb, dt)
    -- Read from blackboard and steer accordingly
    local dist = bb:getNumber("target_dist", 999)
    if dist < 50 then
      ag:setVelocity(0, 0)
    end
  end)
  world:update(0.016)
  lurek.log.debug("custom model: " .. agent:getDecisionModel(), "ai")
end

--@api-stub: lurek.ai.newGuard -- Creates a guard decorator that runs a predicate before ticking its child
do -- lurek.ai.newGuard
  local action = lurek.ai.newAction(function(ag, bb, dt) return "success" end)
  local guard = lurek.ai.newGuard(
    function(ag, bb) return bb:getNumber("health", 1.0) > 0.0 end,
    action
  )
  lurek.log.debug("guard type=" .. guard:getNodeType(), "ai")
  lurek.log.debug("guard children=" .. guard:getChildCount(), "ai")
end

--@api-stub: UtilityAI:addConsideration
do -- UtilityAI:addConsideration (custom curve)
  local ua = lurek.ai.newUtilityAI()
  ua:addAction("patrol", function() return 0.4 end, 1.0)
  ua:addConsideration(
    "patrol",
    "health_curve",
    function() return 0.8 end,
    "quadratic"
  )
  lurek.log.debug("considerations registered without error", "ai")
end

--@api-stub: SteeringManager:addCustomBehavior
do -- SteeringManager:addCustomBehavior
  local sm = lurek.ai.newSteeringManager()
  sm:addCustomBehavior(function(ag, dt)
    return 100, 0   -- constant rightward force
  end, 1.0)
  lurek.log.debug("custom behaviors=" .. sm:getBehaviorCount(), "ai")
end

--@api-stub: SteeringManager:applyCustomSteering
do -- SteeringManager:applyCustomSteering
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("steered")
  local sm = lurek.ai.newSteeringManager()
  sm:addCustomBehavior(function(ag, dt)
    return 50, 25
  end, 1.0)
  -- applyCustomSteering passes the agent userdata to each callback
  local fx, fy = sm:applyCustomSteering(agent, 0.016)
  lurek.log.debug("custom force=" .. fx .. "," .. fy, "ai")
end

--@api-stub: EmotionModel:add
do -- EmotionModel:add
  local em = lurek.ai.newEmotionModel()
  em:add("fear", 0.0, 0.08, 1.0)
  em:add("anger", 0.0, 0.06, 1.0)
  lurek.log.info("emotions registered", "ai")
end

--@api-stub: GOAPPlanner:addAction
do -- GOAPPlanner:addAction
  local planner = lurek.ai.newGOAPPlanner()
  planner:addAction("pickupKey", 2.0, function() lurek.log.info("pickup key", "ai") end)
  planner:addAction("unlockDoor", 1.0, function() lurek.log.info("unlock door", "ai") end)
  planner:addGoal("door_open", 1.0)
end

--@api-stub: UtilityAI:addAction
do -- UtilityAI:addAction
  local uai = lurek.ai.newUtilityAI()
  uai:addAction("heal", function() return 0.9 end)
  uai:addAction("attack", function() return 0.4 end)
  local best = uai:evaluate()
  lurek.log.info("best action: " .. (best or "none"), "ai")
end

--@api-stub: AIWorld:addAgent
do -- AIWorld:addAgent
  local world = lurek.ai.newWorld()
  world:addAgent("guard_01")
  world:addAgent("guard_02")
  lurek.log.info("agents: " .. world:getAgentCount(), "ai")
end

--@api-stub: SteeringManager:addArrive
do -- SteeringManager:addArrive
  local sm = lurek.ai.newSteeringManager()
  sm:addArrive(400, 300, 1.0)
  local fx, fy = sm:calculate(200, 200, 0, 0, 100, 50, 1 / 60)
  lurek.log.info("arrive: " .. fx .. "," .. fy, "ai")
end

--@api-stub: StimulusWorld:addAuditory
do -- StimulusWorld:addAuditory
  local sw = lurek.ai.newStimulusWorld()
  sw:addAuditory(200, 150, 1.2, 100, 0.8, "footstep")
  lurek.log.info("stimuli: " .. sw:count(), "ai")
end

--@api-stub: ContextSteering:addAvoidPoint
do -- ContextSteering:addAvoidPoint
  local cs = lurek.ai.newContextSteering(16)
  cs:addAvoidPoint(300, 200, 64, 1.5)
  cs:addAvoidPoint(100, 350, 48, 1.0)
  local fx, fy = cs:evaluate(150, 150, 0, 0)
  lurek.log.info("context steer: " .. fx .. "," .. fy, "ai")
end

--@api-stub: HTNDomain:addCompound
do -- HTNDomain:addCompound
  local d = lurek.ai.newHTNDomain()
  d:addPrimitive("attack", {"has_weapon"}, {"enemy_dead"}, {})
  d:addCompound("defeat_enemy", {{"has_weapon"}, {"use_weapon"}})
  lurek.log.info("htn tasks: " .. d:taskCount(), "ai")
end

--@api-stub: SteeringManager:addEvade
do -- SteeringManager:addEvade
  local sm = lurek.ai.newSteeringManager()
  sm:addEvade("player", 1.0)
  local fx, fy = sm:calculate(200, 200, 0, 0, 100, 50, 1 / 60)
  lurek.log.info("evade: " .. fx .. "," .. fy, "ai")
end

--@api-stub: SteeringManager:addFlee
do -- SteeringManager:addFlee
  local sm = lurek.ai.newSteeringManager()
  sm:addFlee(400, 300, 1.0)
  local fx, fy = sm:calculate(200, 200, 0, 0, 100, 50, 1 / 60)
  lurek.log.info("flee: " .. fx .. "," .. fy, "ai")
end

--@api-stub: SteeringManager:addFlock
do -- SteeringManager:addFlock
  local sm = lurek.ai.newSteeringManager()
  sm:addFlock(80, 1.0, 0.8, 0.6)
  local fx, fy = sm:calculate(200, 200, 10, 0, 100, 50, 1 / 60)
  lurek.log.info("flock: " .. fx .. "," .. fy, "ai")
end

--@api-stub: GOAPPlanner:addGoal
do -- GOAPPlanner:addGoal
  local planner = lurek.ai.newGOAPPlanner()
  planner:addAction("rest", 1.0, function() end)
  planner:addGoal("is_rested", 1.0)
  planner:addGoal("is_safe", 2.0)
  lurek.log.info("goal count: " .. planner:getGoalCount(), "ai")
end

--@api-stub: InfluenceMap:addLayer
do -- InfluenceMap:addLayer
  local im = lurek.ai.newInfluenceMap(32, 32, 16)
  im:addLayer("threat")
  im:addLayer("resource")
  lurek.log.info("has threat layer: " .. tostring(im:hasLayer("threat")), "ai")
end

--@api-stub: TraitProfile:addModifier
do -- TraitProfile:addModifier
  local traits = lurek.ai.newTraitProfile()
  traits:set("courage", 0.5)
  traits:addModifier("courage", -0.3, 5.0, "fear_potion")
  lurek.log.info("effective courage: " .. traits:get("courage"), "ai")
end

--@api-stub: SteeringManager:addPursue
do -- SteeringManager:addPursue
  local sm = lurek.ai.newSteeringManager()
  sm:addPursue("player", 1.0)
  local fx, fy = sm:calculate(200, 200, 0, 0, 100, 50, 1 / 60)
  lurek.log.info("pursue: " .. fx .. "," .. fy, "ai")
end

--@api-stub: SteeringManager:addSeek
do -- SteeringManager:addSeek
  local sm = lurek.ai.newSteeringManager()
  sm:addSeek(500, 400, 1.0)
  local fx, fy = sm:calculate(100, 100, 0, 0, 150, 50, 1 / 60)
  lurek.log.info("seek force: " .. fx .. "," .. fy, "ai")
end

--@api-stub: ContextSteering:addSeekTarget
do -- ContextSteering:addSeekTarget
  local cs = lurek.ai.newContextSteering(16)
  cs:addSeekTarget(500, 300, 1.0)
  cs:addSeekTarget(400, 400, 0.6)
  local fx, fy = cs:evaluate(200, 200, 0, 0)
  lurek.log.info("context direction: " .. fx .. "," .. fy, "ai")
end

--@api-stub: StateMachine:addTransition
do -- StateMachine:addTransition
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("patrol", {})
  fsm:addState("alert", {})
  fsm:addTransition("patrol", "alert", function() return true end)
  fsm:setInitialState("patrol")
  lurek.log.info("state: " .. (fsm:getCurrentState() or "nil"), "ai")
end

--@api-stub: StimulusWorld:addVisual
do -- StimulusWorld:addVisual
  local sw = lurek.ai.newStimulusWorld()
  sw:addVisual(300, 200, 1.0, 200, "player")
  sw:addAuditory(300, 200, 1.0, 80, 0.5, "footstep")
  lurek.log.info("stimuli count: " .. sw:count(), "ai")
end

--@api-stub: SteeringManager:addWander
do -- SteeringManager:addWander
  local sm = lurek.ai.newSteeringManager()
  sm:addWander(25, 50, 8, 0.4)
  local fx, fy = sm:calculate(200, 200, 0, 0, 100, 50, 1 / 60)
  lurek.log.info("wander: " .. fx .. "," .. fy, "ai")
end

--@api-stub: InfluenceMap:blend
do -- InfluenceMap:blend
  local im = lurek.ai.newInfluenceMap(32, 32, 16)
  im:addLayer("threat")
  im:addLayer("resource")
  im:stampInfluence("threat", 256, 256, 64, 1.0, 1.0)
  im:blend("threat", 0.5, "resource", 0.5, "resource")
  lurek.log.info("blend complete", "ai")
end

--@api-stub: SteeringManager:calculate
do -- SteeringManager:calculate
  local sm = lurek.ai.newSteeringManager()
  sm:addSeek(400, 300, 1.0)
  local fx, fy = sm:calculate(100, 100, 0, 0, 120, 50, 1 / 60)
  lurek.log.info("steering force: " .. fx .. "," .. fy, "ai")
end

--@api-stub: StimulusWorld:count
do -- StimulusWorld:count
  local sw = lurek.ai.newStimulusWorld()
  sw:addAuditory(200, 100, 1.0, 80, 0.8, "gunshot")
  local n = sw:count()
  lurek.log.info("active stimuli: " .. n, "ai")
end

--@api-stub: CommandQueue:enqueue
do -- CommandQueue:enqueue
  local q = lurek.ai.newCommandQueue()
  q:enqueue("move", function() end, {x=300, y=200})
  q:enqueue("attack", function() end, {targetId="enemy_01"})
  lurek.log.info("queue count: " .. q:getCount(), "ai")
end

--@api-stub: ContextSteering:evaluate
do -- ContextSteering:evaluate
  local cs = lurek.ai.newContextSteering(16)
  cs:addSeekTarget(500, 300, 1.0)
  cs:addAvoidPoint(350, 250, 50, 1.0)
  local fx, fy = cs:evaluate(200, 200, 0, 0)
  lurek.log.info("evaluated: " .. fx .. "," .. fy, "ai")
end

--@api-stub: Blackboard:getBool
do -- Blackboard:getBool
  local bb = lurek.ai.newBlackboard()
  bb:setBool("player_spotted", true)
  local spotted = bb:getBool("player_spotted")
  lurek.log.info("player spotted: " .. tostring(spotted), "ai")
end

--@api-stub: Squad:getFormationPosition
do -- Squad:getFormationPosition
  local squad = lurek.ai.newSquad("alpha")
  squad:addMember("guard_01")
  squad:setFormation("wedge", 32)
  local px, py = squad:getFormationPosition(1, 400, 300)
  lurek.log.info("slot: " .. px .. "," .. py, "ai")
end

--@api-stub: InfluenceMap:getInfluence
do -- InfluenceMap:getInfluence
  local im = lurek.ai.newInfluenceMap(32, 32, 16)
  im:addLayer("threat")
  im:stampInfluence("threat", 256, 256, 64, 1.0, 0.9)
  local v = im:getInfluence("threat", 16, 16)
  lurek.log.info("influence at centre: " .. v, "ai")
end

--@api-stub: Blackboard:getNumber
do -- Blackboard:getNumber
  local bb = lurek.ai.newBlackboard()
  bb:setNumber("threat_level", 0.75)
  local t = bb:getNumber("threat_level")
  lurek.log.info("threat: " .. t, "ai")
end

--@api-stub: Blackboard:getString
do -- Blackboard:getString
  local bb = lurek.ai.newBlackboard()
  bb:setString("last_enemy", "goblin_03")
  local name = bb:getString("last_enemy")
  lurek.log.info("last enemy: " .. name, "ai")
end

--@api-stub: QLearner:learn
do -- QLearner:learn
  local ql = lurek.ai.newQLearner(8, 4)
  ql:setLearningRate(0.1)
  ql:learn(2, 1, 1.0, 3)
  local qv = ql:getQValue(2, 1)
  lurek.log.info("Q(2,1)=" .. qv, "ai")
end

--@api-stub: GOAPPlanner:plan
do -- GOAPPlanner:plan
  local planner = lurek.ai.newGOAPPlanner()
  planner:addAction("eat", 1.0, function() end)
  planner:addGoal("not_hungry", 1.0)
  local actions = planner:plan({hungry=true})
  lurek.log.info("plan length: " .. (actions and #actions or 0), "ai")
end

--@api-stub: HTNDomain:plan
do -- HTNDomain:plan
  local d = lurek.ai.newHTNDomain()
  d:addPrimitive("move", {}, {}, {})
  d:addCompound("patrol", {{"move"}})
  local plan = d:plan("patrol", {})
  lurek.log.info("htn plan steps: " .. (plan and #plan or 0), "ai")
end

--@api-stub: InfluenceMap:propagate
do -- InfluenceMap:propagate
  local im = lurek.ai.newInfluenceMap(32, 32, 16)
  im:addLayer("threat")
  im:stampInfluence("threat", 256, 256, 48, 1.0, 0.8)
  im:propagate("threat", 0.85)
  lurek.log.info("propagation done", "ai")
end

--@api-stub: CommandQueue:pushFront
do -- CommandQueue:pushFront
  local q = lurek.ai.newCommandQueue()
  q:enqueue("patrol", function() end, {})
  q:pushFront("flee", function() end, {threatX=300, threatY=200})
  lurek.log.info("front command: " .. q:getCurrentType(), "ai")
end

--@api-stub: InfluenceMap:queryRect
do -- InfluenceMap:queryRect
  local im = lurek.ai.newInfluenceMap(32, 32, 16)
  im:addLayer("resource")
  im:setInfluence("resource", 10, 10, 1.0)
  local total = im:queryRect("resource", 100, 100, 300, 300)
  lurek.log.info("influence sum: " .. total, "ai")
end

--@api-stub: CommandQueue:replace
do -- CommandQueue:replace
  local q = lurek.ai.newCommandQueue()
  q:enqueue("move", function() end, {x=200, y=100})
  q:replace("attack", function() end, {targetId="bandit_01"})
  lurek.log.info("replaced: " .. q:getCurrentType(), "ai")
end

--@api-stub: MCTSEngine:search
do -- MCTSEngine:search
  local mcts = lurek.ai.newMCTSEngine(100, 1.41, 16, 42)
  local actions = function(s) return {1, 2, 3} end
  local apply   = function(s, a) return s + a end
  local eval    = function(s) return s % 5 end
  local best = mcts:search(0, actions, apply, eval)
  lurek.log.info("best action: " .. best, "ai")
end

--@api-stub: GOAPPlanner:setEffect
do -- GOAPPlanner:setEffect
  local planner = lurek.ai.newGOAPPlanner()
  planner:addAction("openDoor", 1.0, function() end)
  planner:setEffect("openDoor", "door_locked", false)
  lurek.log.info("effect registered", "ai")
end

--@api-stub: Squad:setFormation
do -- Squad:setFormation
  local squad = lurek.ai.newSquad("bravo")
  squad:addMember("soldier_01")
  squad:addMember("soldier_02")
  squad:setFormation("wedge", 40)
  lurek.log.info("formation: " .. squad:getFormation(), "ai")
end

--@api-stub: GOAPPlanner:setGoalState
do -- GOAPPlanner:setGoalState
  local planner = lurek.ai.newGOAPPlanner()
  planner:addGoal("enemy_dead", 1.0)
  planner:setGoalState("enemy_dead", "is_dead", true)
  lurek.log.info("goal state set", "ai")
end

--@api-stub: InfluenceMap:setInfluence
do -- InfluenceMap:setInfluence
  local im = lurek.ai.newInfluenceMap(32, 32, 16)
  im:addLayer("hazard")
  im:setInfluence("hazard", 8, 8, 1.0)
  lurek.log.info("cell 8,8 hazard: " .. im:getInfluence("hazard", 8, 8), "ai")
end

--@api-stub: GOAPPlanner:setPrecondition
do -- GOAPPlanner:setPrecondition
  local planner = lurek.ai.newGOAPPlanner()
  planner:addAction("shoot", 1.0, function() end)
  planner:setPrecondition("shoot", "has_ammo", true)
  lurek.log.info("precondition set", "ai")
end

--@api-stub: ORCASolver:setPreferredVelocity
do -- ORCASolver:setPreferredVelocity
  local orca = lurek.ai.newORCASolver(2.0)
  local idx = orca:addAgent(100, 100, 14, 80)
  orca:setPreferredVelocity(idx, 60, 0)
  orca:compute(1 / 60)
  local vx, vy = orca:getSafeVelocity(idx)
  lurek.log.info("safe vel: " .. vx .. "," .. vy, "ai")
end

--@api-stub: QLearner:setQValue
do -- QLearner:setQValue
  local ql = lurek.ai.newQLearner(8, 4)
  ql:setQValue(0, 2, 0.85)
  local v = ql:getQValue(0, 2)
  lurek.log.info("Q(0,2)=" .. v, "ai")
end

--@api-stub: InfluenceMap:stampInfluence
do -- InfluenceMap:stampInfluence
  local im = lurek.ai.newInfluenceMap(32, 32, 16)
  im:addLayer("threat")
  im:stampInfluence("threat", 256, 256, 96, 1.0, 0.75)
  lurek.log.info("stamped threat blob", "ai")
end

--@api-stub: AILod:tierFor
do -- AILod:tierFor
  local lod = lurek.ai.newAILod()
  local tier = lod:tierFor(350, 0, 0, 0)
  lurek.log.info("lod tier at 350: " .. tier, "ai")
end

--@api-stub: ORCASolver:addAgent
do -- ORCASolver:addAgent
  local solver = lurek.ai.newORCASolver(2.0)
  solver:addAgent(200, 300, 50, 100)
  solver:compute(1 / 60)
  lurek.log.info("ORCA agent added", "ai")
end

--@api-stub: NeuralNet:addLayer
do -- NeuralNet:addLayer
  local net = lurek.ai.newNeuralNet()
  net:addLayer(2, 4, "relu")
  net:addLayer(4, 1, "relu")
  local out = net:forward({0.25, 0.75})
  lurek.log.info("forward count: " .. #out, "ai")
end

-- =============================================================================
-- COVERAGE: 287 uncovered lurek.ai API item(s)
-- Generated by tools/audit/example_add_missing.py
-- Run .github/prompts/flesh-out-example.prompt.md for instructions.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- LAIBlackboard methods
-- -----------------------------------------------------------------------------

--@api-stub: LAIBlackboard:setNumber -- Stores a numeric fact under the given blackboard key
do -- LAIBlackboard:setNumber
  local bb = lurek.ai.newBlackboard()
  bb:setNumber("health", 100)
  bb:setNumber("aggro_timer", 3.5)
  lurek.log.info("health=" .. bb:getNumber("health", 0), "ai")
end
--@api-stub: LAIBlackboard:getNumber -- Returns a numeric blackboard fact or the provided fallback when the key is missing or not numeric
do -- LAIBlackboard:getNumber
  local bb = lurek.ai.newBlackboard()
  bb:setNumber("speed", 5.0)
  local v = bb:getNumber("speed", 0.0)
  local missing = bb:getNumber("nonexistent", -1.0)
  lurek.log.info("speed=" .. v .. " missing=" .. missing, "ai")
end
--@api-stub: LAIBlackboard:setBool -- Stores a boolean fact under the given blackboard key
do -- LAIBlackboard:setBool
  local bb = lurek.ai.newBlackboard()
  bb:setBool("is_alerted", true)
  bb:setBool("can_attack", false)
  lurek.log.info("alerted=" .. tostring(bb:getBool("is_alerted", false)), "ai")
end
--@api-stub: LAIBlackboard:getBool -- Returns a boolean blackboard fact or the provided fallback when the key is missing or not boolean
do -- LAIBlackboard:getBool
  local bb = lurek.ai.newBlackboard()
  bb:setBool("player_visible", true)
  lurek.log.info("visible=" .. tostring(bb:getBool("player_visible", false)), "ai")
  lurek.log.info("default=" .. tostring(bb:getBool("unknown_key", false)), "ai")
end
--@api-stub: LAIBlackboard:setString -- Stores a string fact under the given blackboard key
do -- LAIBlackboard:setString
  local bb = lurek.ai.newBlackboard()
  bb:setString("state", "patrol")
  bb:setString("target_id", "player_1")
  lurek.log.info("state=" .. bb:getString("state", "idle"), "ai")
end
--@api-stub: LAIBlackboard:getString -- Returns a string blackboard fact or the provided fallback when the key is missing or not a string
do -- LAIBlackboard:getString
  local bb = lurek.ai.newBlackboard()
  bb:setString("last_command", "patrol_waypoint_3")
  local cmd = bb:getString("last_command", "idle")
  lurek.log.info("last_command=" .. cmd, "ai")
end
--@api-stub: LAIBlackboard:has -- Returns whether the blackboard contains any entry for the given key
do -- LAIBlackboard:has
  local bb = lurek.ai.newBlackboard()
  bb:setNumber("ammo", 12)
  lurek.log.info("has ammo: " .. tostring(bb:has("ammo")), "ai")
  lurek.log.info("has mana: " .. tostring(bb:has("mana")), "ai")
end
--@api-stub: LAIBlackboard:remove -- Removes the given key from the blackboard if it exists
do -- LAIBlackboard:remove
  local bb = lurek.ai.newBlackboard()
  bb:setString("target", "goblin_5")
  lurek.log.info("before remove: " .. tostring(bb:has("target")), "ai")
  bb:remove("target")
  lurek.log.info("after remove: " .. tostring(bb:has("target")), "ai")
end
--@api-stub: LAIBlackboard:clear -- Removes every local entry from this blackboard
do -- LAIBlackboard:clear
  local bb = lurek.ai.newBlackboard()
  bb:setNumber("hp", 80)
  bb:setBool("alerted", true)
  lurek.log.info("size before clear=" .. bb:getSize(), "ai")
  bb:clear()
  lurek.log.info("size after clear=" .. bb:getSize(), "ai")
end
--@api-stub: LAIBlackboard:getKeys -- Returns every local blackboard key in an array-style Lua table
do -- LAIBlackboard:getKeys
  local bb = lurek.ai.newBlackboard()
  bb:setNumber("energy", 50)
  bb:setBool("charging", false)
  bb:setString("phase", "attack")
  local keys = bb:getKeys()
  lurek.log.info("key count=" .. #keys, "ai")
end
--@api-stub: LAIBlackboard:getSize -- Returns the number of entries currently stored in this blackboard
do -- LAIBlackboard:getSize
  local bb = lurek.ai.newBlackboard()
  bb:setNumber("x", 10)
  bb:setNumber("y", 20)
  lurek.log.info("size=" .. bb:getSize(), "ai")
end
--@api-stub: LAIBlackboard:type -- Returns the Lua-visible type name for this blackboard handle
do -- LAIBlackboard:type
  local a_i_blackboard_obj = lurek.ai.newBlackboard()
  local t = a_i_blackboard_obj:type()
  lurek.log.info("LAIBlackboard:type = " .. t, "ai")
end
--@api-stub: LAIBlackboard:typeOf -- Returns whether this blackboard handle matches a supported type name
do -- LAIBlackboard:typeOf
  local a_i_blackboard_obj = lurek.ai.newBlackboard()
  lurek.log.info("is LAIBlackboard: " .. tostring(a_i_blackboard_obj:typeOf("LAIBlackboard")), "ai")
  lurek.log.info("is wrong: " .. tostring(a_i_blackboard_obj:typeOf("Unknown")), "ai")
end
--@api-stub: LAIDirector:type -- Returns the Lua-visible type name for this AI director handle
do -- LAIDirector:type
  local a_i_director_obj = lurek.ai.newAIDirector()
  local t = a_i_director_obj:type()
  lurek.log.info("LAIDirector:type = " .. t, "ai")
end
--@api-stub: LAIDirector:typeOf -- Returns whether this AI director handle matches a supported type name
do -- LAIDirector:typeOf
  local a_i_director_obj = lurek.ai.newAIDirector()
  lurek.log.info("is LAIDirector: " .. tostring(a_i_director_obj:typeOf("LAIDirector")), "ai")
  lurek.log.info("is wrong: " .. tostring(a_i_director_obj:typeOf("Unknown")), "ai")
end
--@api-stub: LAILod:type -- Returns the Lua-visible type name for this AI LOD handle
do -- LAILod:type
  local a_i_lod_obj = lurek.ai.newAILod()
  local t = a_i_lod_obj:type()
  lurek.log.info("LAILod:type = " .. t, "ai")
end
--@api-stub: LAILod:typeOf -- Returns whether this AI LOD handle matches a supported type name
do -- LAILod:typeOf
  local a_i_lod_obj = lurek.ai.newAILod()
  lurek.log.info("is LAILod: " .. tostring(a_i_lod_obj:typeOf("LAILod")), "ai")
  lurek.log.info("is wrong: " .. tostring(a_i_lod_obj:typeOf("Unknown")), "ai")
end
--@api-stub: LBandit:type -- Returns the Lua-visible type name for this bandit handle
do -- LBandit:type
  local bandit_obj = lurek.ai.newBandit(4, "epsilon-greedy", 0.1, 42)
  local t = bandit_obj:type()
  lurek.log.info("LBandit:type = " .. t, "ai")
end
--@api-stub: LBandit:typeOf -- Returns whether this bandit handle matches a supported type name
do -- LBandit:typeOf
  local bandit_obj = lurek.ai.newBandit(4, "epsilon-greedy", 0.1, 42)
  lurek.log.info("is LBandit: " .. tostring(bandit_obj:typeOf("LBandit")), "ai")
  lurek.log.info("is wrong: " .. tostring(bandit_obj:typeOf("Unknown")), "ai")
end
--@api-stub: LContextSteering:type -- Returns the Lua-visible type name for this context steering handle
do -- LContextSteering:type
  local context_steering_obj = lurek.ai.newContextSteering(8)
  local t = context_steering_obj:type()
  lurek.log.info("LContextSteering:type = " .. t, "ai")
end
--@api-stub: LContextSteering:typeOf -- Returns whether this context steering handle matches a supported type name
do -- LContextSteering:typeOf
  local context_steering_obj = lurek.ai.newContextSteering(8)
  lurek.log.info("is LContextSteering: " .. tostring(context_steering_obj:typeOf("LContextSteering")), "ai")
  lurek.log.info("is wrong: " .. tostring(context_steering_obj:typeOf("Unknown")), "ai")
end
--@api-stub: LEmotionModel:type -- Returns the Lua-visible type name for this emotion model handle
do -- LEmotionModel:type
  local emotion_model_obj = lurek.ai.newEmotionModel()
  local t = emotion_model_obj:type()
  lurek.log.info("LEmotionModel:type = " .. t, "ai")
end
--@api-stub: LEmotionModel:typeOf -- Returns whether this emotion model handle matches a supported type name
do -- LEmotionModel:typeOf
  local emotion_model_obj = lurek.ai.newEmotionModel()
  lurek.log.info("is LEmotionModel: " .. tostring(emotion_model_obj:typeOf("LEmotionModel")), "ai")
  lurek.log.info("is wrong: " .. tostring(emotion_model_obj:typeOf("Unknown")), "ai")
end
--@api-stub: LGeneticAlgorithm:type -- Returns the Lua-visible type name for this genetic algorithm handle
do -- LGeneticAlgorithm:type
  local genetic_algorithm_obj = lurek.ai.newGeneticAlgorithm(20, 8, 42)
  local t = genetic_algorithm_obj:type()
  lurek.log.info("LGeneticAlgorithm:type = " .. t, "ai")
end
--@api-stub: LGeneticAlgorithm:typeOf -- Returns whether this genetic algorithm handle matches a supported type name
do -- LGeneticAlgorithm:typeOf
  local genetic_algorithm_obj = lurek.ai.newGeneticAlgorithm(20, 8, 42)
  lurek.log.info("is LGeneticAlgorithm: " .. tostring(genetic_algorithm_obj:typeOf("LGeneticAlgorithm")), "ai")
  lurek.log.info("is wrong: " .. tostring(genetic_algorithm_obj:typeOf("Unknown")), "ai")
end
--@api-stub: LHTNDomain:type -- Returns the Lua-visible type name for this HTN domain handle
do -- LHTNDomain:type
  local h_t_n_domain_obj = lurek.ai.newHTNDomain()
  local t = h_t_n_domain_obj:type()
  lurek.log.info("LHTNDomain:type = " .. t, "ai")
end
--@api-stub: LHTNDomain:typeOf -- Returns whether this HTN domain handle matches a supported type name
do -- LHTNDomain:typeOf
  local h_t_n_domain_obj = lurek.ai.newHTNDomain()
  lurek.log.info("is LHTNDomain: " .. tostring(h_t_n_domain_obj:typeOf("LHTNDomain")), "ai")
  lurek.log.info("is wrong: " .. tostring(h_t_n_domain_obj:typeOf("Unknown")), "ai")
end
--@api-stub: LMCTSEngine:type -- Returns the Lua-visible type name for this MCTS engine handle
do -- LMCTSEngine:type
  local m_c_t_s_engine_obj = lurek.ai.newMCTSEngine(100, 1.41, 5, 42)
  local t = m_c_t_s_engine_obj:type()
  lurek.log.info("LMCTSEngine:type = " .. t, "ai")
end
--@api-stub: LMCTSEngine:typeOf -- Returns whether this MCTS engine handle matches a supported type name
do -- LMCTSEngine:typeOf
  local m_c_t_s_engine_obj = lurek.ai.newMCTSEngine(100, 1.41, 5, 42)
  lurek.log.info("is LMCTSEngine: " .. tostring(m_c_t_s_engine_obj:typeOf("LMCTSEngine")), "ai")
  lurek.log.info("is wrong: " .. tostring(m_c_t_s_engine_obj:typeOf("Unknown")), "ai")
end
--@api-stub: LNeedSystem:type -- Returns the Lua-visible type name for this need system handle
do -- LNeedSystem:type
  local need_system_obj = lurek.ai.newNeedSystem()
  local t = need_system_obj:type()
  lurek.log.info("LNeedSystem:type = " .. t, "ai")
end
--@api-stub: LNeedSystem:typeOf -- Returns whether this need system handle matches a supported type name
do -- LNeedSystem:typeOf
  local need_system_obj = lurek.ai.newNeedSystem()
  lurek.log.info("is LNeedSystem: " .. tostring(need_system_obj:typeOf("LNeedSystem")), "ai")
  lurek.log.info("is wrong: " .. tostring(need_system_obj:typeOf("Unknown")), "ai")
end
--@api-stub: LNeuralNet:type -- Returns the Lua-visible type name for this neural network handle
do -- LNeuralNet:type
  local neural_net_obj = lurek.ai.newNeuralNet()
  local t = neural_net_obj:type()
  lurek.log.info("LNeuralNet:type = " .. t, "ai")
end
--@api-stub: LNeuralNet:typeOf -- Returns whether this neural network handle matches a supported type name
do -- LNeuralNet:typeOf
  local neural_net_obj = lurek.ai.newNeuralNet()
  lurek.log.info("is LNeuralNet: " .. tostring(neural_net_obj:typeOf("LNeuralNet")), "ai")
  lurek.log.info("is wrong: " .. tostring(neural_net_obj:typeOf("Unknown")), "ai")
end
--@api-stub: LNeuroevolution:type -- Returns the Lua-visible type name for this neuroevolution handle
do -- LNeuroevolution:type
  local ne_layers = { {inputs=4, outputs=8, activation="relu"}, {inputs=8, outputs=4, activation="softmax"} }
  local ok_ne, neuroevolution_obj = pcall(lurek.ai.newNeuroevolution, ne_layers, 20, 42)
  if not ok_ne then neuroevolution_obj = nil end
  local t = neuroevolution_obj and neuroevolution_obj:type() or "LNeuroevolution"
  lurek.log.info("LNeuroevolution:type = " .. t, "ai")
end
--@api-stub: LNeuroevolution:typeOf -- Returns whether this neuroevolution handle matches a supported type name
do -- LNeuroevolution:typeOf
  local ne_layers = { {inputs=4, outputs=8, activation="relu"}, {inputs=8, outputs=4, activation="softmax"} }
  local ok_ne, neuroevolution_obj = pcall(lurek.ai.newNeuroevolution, ne_layers, 20, 42)
  if not ok_ne then neuroevolution_obj = nil end
  lurek.log.info("is LNeuroevolution: " .. tostring(neuroevolution_obj and neuroevolution_obj:typeOf("LNeuroevolution") or false), "ai")
  lurek.log.info("is wrong: " .. tostring(neuroevolution_obj and neuroevolution_obj:typeOf("Unknown") or false), "ai")
end
--@api-stub: LORCASolver:type -- Returns the Lua-visible type name for this ORCA solver handle
do -- LORCASolver:type
  local o_r_c_a_solver_obj = lurek.ai.newORCASolver(0.5)
  local t = o_r_c_a_solver_obj:type()
  lurek.log.info("LORCASolver:type = " .. t, "ai")
end
--@api-stub: LORCASolver:typeOf -- Returns whether this ORCA solver handle matches a supported type name
do -- LORCASolver:typeOf
  local o_r_c_a_solver_obj = lurek.ai.newORCASolver(0.5)
  lurek.log.info("is LORCASolver: " .. tostring(o_r_c_a_solver_obj:typeOf("LORCASolver")), "ai")
  lurek.log.info("is wrong: " .. tostring(o_r_c_a_solver_obj:typeOf("Unknown")), "ai")
end
--@api-stub: LStimulusWorld:type -- Returns the Lua-visible type name for this stimulus world handle
do -- LStimulusWorld:type
  local stimulus_world_obj = lurek.ai.newStimulusWorld()
  local t = stimulus_world_obj:type()
  lurek.log.info("LStimulusWorld:type = " .. t, "ai")
end
--@api-stub: LStimulusWorld:typeOf -- Returns whether this stimulus world handle matches a supported type name
do -- LStimulusWorld:typeOf
  local stimulus_world_obj = lurek.ai.newStimulusWorld()
  lurek.log.info("is LStimulusWorld: " .. tostring(stimulus_world_obj:typeOf("LStimulusWorld")), "ai")
  lurek.log.info("is wrong: " .. tostring(stimulus_world_obj:typeOf("Unknown")), "ai")
end
--@api-stub: LStrategyAI:type -- Returns the Lua-visible type name for this strategy AI handle
do -- LStrategyAI:type
  local strategy_a_i_obj = lurek.ai.newStrategyAI(0.25)
  local t = strategy_a_i_obj:type()
  lurek.log.info("LStrategyAI:type = " .. t, "ai")
end
--@api-stub: LStrategyAI:typeOf -- Returns whether this strategy AI handle matches a supported type name
do -- LStrategyAI:typeOf
  local strategy_a_i_obj = lurek.ai.newStrategyAI(0.25)
  lurek.log.info("is LStrategyAI: " .. tostring(strategy_a_i_obj:typeOf("LStrategyAI")), "ai")
  lurek.log.info("is wrong: " .. tostring(strategy_a_i_obj:typeOf("Unknown")), "ai")
end
--@api-stub: LTraitProfile:type -- Returns the Lua-visible type name for this trait profile handle
do -- LTraitProfile:type
  local trait_profile_obj = lurek.ai.newTraitProfile()
  local t = trait_profile_obj:type()
  lurek.log.info("LTraitProfile:type = " .. t, "ai")
end
--@api-stub: LTraitProfile:typeOf -- Returns whether this trait profile handle matches a supported type name
do -- LTraitProfile:typeOf
  local trait_profile_obj = lurek.ai.newTraitProfile()
  lurek.log.info("is LTraitProfile: " .. tostring(trait_profile_obj:typeOf("LTraitProfile")), "ai")
  lurek.log.info("is wrong: " .. tostring(trait_profile_obj:typeOf("Unknown")), "ai")
end
