-- content/examples/ai.lua
-- Auto-generated from content/examples2/ai_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/ai.lua


--@api: lurek.ai.newWorld
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local scout = world:addAgent("scout_preview")
  local count = world:getAgentCount()
  lurek.log.info(tostring("lurek.ai.newWorld: agents=" .. tostring(count)))
  lurek.log.info(tostring("lurek.ai.newWorld: first_agent=" .. scout:getName()))
end

--@api: lurek.ai.newBlackboard
do
  local bb = lurek.ai.newBlackboard()
  bb:setString("context", "active")
  local bb_size = bb:getSize()
  bb:setString("state", "idle")
  lurek.log.info(tostring("lurek.ai.newBlackboard: state=" .. bb:getString("state", "none")))
end

--@api: lurek.ai.newStateMachine
do
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("idle", {})
  local fsm_type = fsm:type()
  fsm:addState("idle", {})
  fsm:setInitialState("idle")
  lurek.log.info(tostring("lurek.ai.newStateMachine: ok=" .. tostring(fsm ~= nil)))
  lurek.log.info(tostring("lurek.ai.newStateMachine: current=" .. tostring(fsm:getCurrentState())))
end

--@api: lurek.ai.newBehaviorTree
do
  local bt = lurek.ai.newBehaviorTree()
  local bt_debug = bt:getDebugState()
  local bt_status = bt:getLastStatus()
  bt:setRoot(lurek.ai.newAction(function() return "success" end))
  local info = bt:getDebugState()
  lurek.log.info(tostring("lurek.ai.newBehaviorTree: status=" .. tostring(bt:getLastStatus())))
  lurek.log.info(tostring("lurek.ai.newBehaviorTree: node_count=" .. tostring(info.node_count)))
end

--@api: lurek.ai.newSelector
do
  local sel = lurek.ai.newSelector()
  local node_type = sel:getNodeType()
  local child_count = sel:getChildCount()
  sel:addChild(lurek.ai.newAction(function() return "failure" end))
  sel:addChild(lurek.ai.newAction(function() return "success" end))
  lurek.log.info(tostring("lurek.ai.newSelector: type=" .. sel:getNodeType()))
  lurek.log.info(tostring("lurek.ai.newSelector: children=" .. tostring(sel:getChildCount())))
end

--@api: lurek.ai.newSequence
do
  local seq = lurek.ai.newSequence()
  local node_type = seq:getNodeType()
  local child_count = seq:getChildCount()
  seq:addChild(lurek.ai.newCondition(function() return true end))
  seq:addChild(lurek.ai.newAction(function() return "success" end))
  lurek.log.info(tostring("lurek.ai.newSequence: type=" .. seq:getNodeType()))
  lurek.log.info(tostring("lurek.ai.newSequence: children=" .. tostring(seq:getChildCount())))
end

--@api: lurek.ai.newParallel
do
  local par = lurek.ai.newParallel("requireAll", "requireOne")
  local node_type = par:getNodeType()
  local child_count = par:getChildCount()
  par:addChild(lurek.ai.newAction(function() return "running" end))
  par:addChild(lurek.ai.newAction(function() return "success" end))
  lurek.log.info(tostring("lurek.ai.newParallel: type=" .. par:getNodeType()))
  lurek.log.info(tostring("lurek.ai.newParallel: children=" .. tostring(par:getChildCount())))
end

--@api: lurek.ai.newInverter
do
  local inv = lurek.ai.newInverter()
  local node_type = inv:getNodeType()
  local child_count = inv:getChildCount()
  inv:setChild(lurek.ai.newCondition(function() return false end))
  lurek.log.info(tostring("lurek.ai.newInverter: type=" .. inv:getNodeType()))
  lurek.log.info(tostring("lurek.ai.newInverter: child_count=" .. tostring(inv:getChildCount())))
end

--@api: lurek.ai.newRepeater
do
  local rep = lurek.ai.newRepeater(5)
  local node_type = rep:getNodeType()
  local child_count = rep:getChildCount()
  rep:setChild(lurek.ai.newAction(function() return "success" end))
  lurek.log.info(tostring("lurek.ai.newRepeater: count=" .. tostring(rep:getCount())))
  lurek.log.info(tostring("lurek.ai.newRepeater: type=" .. rep:getNodeType()))
end

--@api: lurek.ai.newSucceeder
do
  local suc = lurek.ai.newSucceeder()
  local node_type = suc:getNodeType()
  local child_count = suc:getChildCount()
  suc:setChild(lurek.ai.newAction(function() return "failure" end))
  lurek.log.info(tostring("lurek.ai.newSucceeder: type=" .. suc:getNodeType()))
  lurek.log.info(tostring("lurek.ai.newSucceeder: child_count=" .. tostring(suc:getChildCount())))
end

--@api: lurek.ai.newAction
do
  local act = lurek.ai.newAction(function() return "success" end)
  local node_type = act:getNodeType()
  local child_count = act:getChildCount()
  act:reset()
  lurek.log.info(tostring("lurek.ai.newAction: type=" .. act:getNodeType()))
  lurek.log.info(tostring("lurek.ai.newAction: child_count=" .. tostring(act:getChildCount())))
end

--@api: lurek.ai.newCondition
do
  local cond = lurek.ai.newCondition(function() return true end)
  local node_type = cond:getNodeType()
  local child_count = cond:getChildCount()
  cond:reset()
  lurek.log.info(tostring("lurek.ai.newCondition: type=" .. cond:getNodeType()))
  lurek.log.info(tostring("lurek.ai.newCondition: child_count=" .. tostring(cond:getChildCount())))
end

--@api: lurek.ai.newGuard
do
  local child_action = lurek.ai.newAction(function() return "success" end)
  local guard = lurek.ai.newGuard(function() return true end, child_action)
  local node_type = guard:getNodeType()
  local child_count = guard:getChildCount()
  lurek.log.info(tostring("lurek.ai.newGuard: node=" .. guard:getNodeType()))
end

--@api: lurek.ai.newUtilityAI
do
  local util = lurek.ai.newUtilityAI()
  util:addAction("wait", function() return 0.2 end)
  util:addAction("attack", function() return 0.9 end)
  lurek.log.info(tostring("lurek.ai.newUtilityAI: ok=" .. tostring(util ~= nil)))
  lurek.log.info(tostring("lurek.ai.newUtilityAI: pick=" .. tostring(util:evaluate())))
end

--@api: lurek.ai.newDialogueAI
do
  local dlg = lurek.ai.newDialogueAI()
  dlg:addTopic("greeting", 0.5, nil, nil, "greet_score")
  dlg:setUtilityScore("greet_score", 0.8)
  lurek.log.info(tostring("lurek.ai.newDialogueAI: ok=" .. tostring(dlg ~= nil)))
  lurek.log.info(tostring("lurek.ai.newDialogueAI: topics=" .. tostring(dlg:getTopicCount())))
end

--@api: lurek.ai.newGOAPPlanner
do
  local goap = lurek.ai.newGOAPPlanner()
  goap:addGoal("idle", 1)
  local goal_count = goap:getGoalCount()
  goap:addGoal("stay_alive", 5)
  goap:setGoalState("stay_alive", "alive", true)
  lurek.log.info(tostring("lurek.ai.newGOAPPlanner: ok=" .. tostring(goap ~= nil)))
  lurek.log.info(tostring("lurek.ai.newGOAPPlanner: goals=" .. tostring(goap:getGoalCount())))
end

--@api: lurek.ai.newSquad
do
  local squad = lurek.ai.newSquad("bravo")
  squad:addMember("leader")
  squad:setLeader("leader")
  lurek.log.info(tostring("lurek.ai.newSquad: name=" .. squad:getName()))
  lurek.log.info(tostring("lurek.ai.newSquad: members=" .. tostring(squad:getMemberCount())))
end

--@api: lurek.ai.newCommandQueue
do
  local cq = lurek.ai.newCommandQueue()
  cq:enqueue("hold", function() end, { targetX = 0, targetY = 0 })
  local queue_count = cq:getCount()
  cq:enqueue("move", function() lurek.log.info(tostring("moving")) end, { targetX = 32, targetY = 64 })
  lurek.log.info(tostring("lurek.ai.newCommandQueue: empty=" .. tostring(cq:isEmpty())))
  lurek.log.info(tostring("lurek.ai.newCommandQueue: count=" .. tostring(cq:getCount())))
end

--@api: lurek.ai.newTraitProfile
do
  local traits = lurek.ai.newTraitProfile()
  traits:set("discipline", 0.4)
  traits:set("courage", 0.7)
  lurek.log.info(tostring("lurek.ai.newTraitProfile: ok=" .. tostring(traits ~= nil)))
  lurek.log.info(tostring("lurek.ai.newTraitProfile: courage=" .. tostring(traits:get("courage"))))
end

--@api: lurek.ai.newTraitArchetypes
do
  local archetypes = lurek.ai.newTraitArchetypes()
  local profile = archetypes:createProfile("aggressive")
  local names = archetypes:names()
  local count = archetypes:count()
  lurek.log.info(tostring("lurek.ai.newTraitArchetypes: count=" .. tostring(count)))
  lurek.log.info(tostring("lurek.ai.newTraitArchetypes: aggression=" .. tostring(profile:get("aggression"))))
  lurek.log.info(tostring("lurek.ai.newTraitArchetypes: first=" .. tostring(names[1])))
end

--@api: lurek.ai.newDecisionBiasSet
do
  local profile = lurek.ai.newTraitProfile()
  local bias = lurek.ai.newDecisionBiasSet()
  profile:set("aggression", 0.8)
  bias:addRule("aggression", "attack", 0.2, "add")
  local score = bias:score(profile, "attack", 0.5)
  lurek.log.info(tostring("lurek.ai.newDecisionBiasSet: score=" .. tostring(score)))
end

--@api: lurek.ai.newStimulusWorld
do
  local sw = lurek.ai.newStimulusWorld()
  local stimulus_id = sw:addVisual(0, 0, 0.5, 8.0, "ping")
  local stimulus_count = sw:count()
  sw:addVisual(100, 150, 1.0, 48.0, "enemy")
  lurek.log.info(tostring("lurek.ai.newStimulusWorld: stimuli=" .. tostring(sw:count())))
  lurek.log.info(tostring("lurek.ai.newStimulusWorld: type=" .. sw:type()))
end

--@api: lurek.ai.newNeedSystem
do
  local needs = lurek.ai.newNeedSystem()
  needs:addNeed("hunger", 0.1, 0.7, 2.0)
  needs:update(2.0)
  lurek.log.info(tostring("lurek.ai.newNeedSystem: ok=" .. tostring(needs ~= nil)))
  lurek.log.info(tostring("lurek.ai.newNeedSystem: urgent=" .. tostring(needs:mostUrgent())))
end

--@api: lurek.ai.newAIDirector
do
  local dir = lurek.ai.newAIDirector()
  dir:pushEvent(0.1)
  local current_phase = dir:phase()
  dir:pushEvent(0.6)
  dir:update(1.0)
  lurek.log.info(tostring("lurek.ai.newAIDirector: ok=" .. tostring(dir ~= nil)))
  lurek.log.info(tostring("lurek.ai.newAIDirector: phase=" .. dir:phase()))
end

--@api: lurek.ai.newHTNDomain
do
  local htn = lurek.ai.newHTNDomain()
  local domain_type = htn:type()
  local task_count = htn:taskCount()
  lurek.log.info(tostring("lurek.ai.newHTNDomain: ok=" .. tostring(htn ~= nil)))
  lurek.log.info(tostring("lurek.ai.newHTNDomain: tasks=" .. tostring(htn:taskCount())))
end

--@api: lurek.ai.newMCTSEngine
do
  local mcts = lurek.ai.newMCTSEngine(100, 1.41, 20, 42)
  local get_actions = function(state) return { 1, 2, 3 } end
  local apply = function(state, action) return state + action end
  local evaluate = function(state) return state % 5 end
  local search_budget = 100
  local exploration = 1.41
  local rollout_depth = 20
  local root_state = 0
  local best_action = mcts:search(0, get_actions, apply, evaluate)
  lurek.log.info(tostring("lurek.ai.newMCTSEngine: action=" .. tostring(best_action)))
end

--@api: lurek.ai.newEmotionModel
do
  local emo = lurek.ai.newEmotionModel()
  emo:add("fear", 0.1, 0.2, 0.3)
  emo:trigger("fear", 0.5)
  lurek.log.info(tostring("lurek.ai.newEmotionModel: ok=" .. tostring(emo ~= nil)))
  lurek.log.info(tostring("lurek.ai.newEmotionModel: dominant=" .. tostring(emo:dominant())))
end

--@api: lurek.ai.newStrategyAI
do
  local strat = lurek.ai.newStrategyAI(3.0)
  strat:addGoal("expand")
  strat:addTag("economy")
  lurek.log.info(tostring("lurek.ai.newStrategyAI: ok=" .. tostring(strat ~= nil)))
  lurek.log.info(tostring("lurek.ai.newStrategyAI: next_eval=" .. tostring(strat:timeUntilNext())))
end

--@api: lurek.ai.newAILod
do
  local lod = lurek.ai.newAILod()
  local tier_name = lod:tierName(0)
  local tier_index = lod:tierFor(0, 0, 0, 0)
  lurek.log.info(tostring("lurek.ai.newAILod: ok=" .. tostring(lod ~= nil)))
  lurek.log.info(tostring("lurek.ai.newAILod: tiers=" .. tostring(lod:tierCount())))
end

--@api: LAIWorld:addAgent
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local archer = world:addAgent("archer_01")
  local count = world:getAgentCount()
  lurek.log.info(tostring("LAIWorld:addAgent: name=" .. archer:getName()))
end

--@api: LAIWorld:getAgent
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  world:addAgent("scout_01")
  local found = world:getAgent("scout_01")
  lurek.log.info(tostring("LAIWorld:getAgent: found=" .. tostring(found ~= nil)))
end

--@api: LAIWorld:removeAgent
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local temp = world:addAgent("temp_npc")
  world:removeAgent(temp)
  lurek.log.info(tostring("LAIWorld:removeAgent: removed"))
end

--@api: LAIWorld:getAgentCount
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  world:addAgent("unit_a")
  world:addAgent("unit_b")
  world:addAgent("unit_c")
  local count = world:getAgentCount()
  lurek.log.info(tostring("LAIWorld:getAgentCount: " .. tostring(count)))
end

--@api: LAIWorld:getGlobalBlackboard
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local gb = world:getGlobalBlackboard()
  gb:setString("weather", "rain")
  lurek.log.info(tostring("LAIWorld:getGlobalBlackboard: ok=" .. tostring(gb ~= nil)))
  lurek.log.info(tostring("LAIWorld:getGlobalBlackboard: weather=" .. gb:getString("weather", "none")))
end

--@api: LAIWorld:setSpatialCellSize
do
  local world = lurek.ai.newWorld()
  world:setSpatialCellSize(24.0)
  local size = world:getSpatialCellSize()
  local stats = world:getSpatialQueryStats()
  lurek.log.info(tostring("LAIWorld:setSpatialCellSize: size=" .. tostring(size)))
  lurek.log.info(tostring("LAIWorld:setSpatialCellSize: queries=" .. tostring(stats.queryCount)))
end

--@api: LAIWorld:getSpatialCellSize
do
  local world = lurek.ai.newWorld()
  world:setSpatialCellSize(32.0)
  local size = world:getSpatialCellSize()
  local type_name = world:type()
  lurek.log.info(tostring("LAIWorld:getSpatialCellSize: " .. tostring(size)))
  lurek.log.info(tostring("LAIWorld:getSpatialCellSize: type=" .. tostring(type_name)))
end

--@api: LAIWorld:getSpatialQueryStats
do
  local world = lurek.ai.newWorld()
  world:setSpatialCellSize(16.0)
  local alpha = world:addAgent("alpha")
  local beta = world:addAgent("beta")
  alpha:setPosition(0.0, 0.0)
  alpha:setTeam(1)
  beta:setPosition(10.0, 0.0)
  beta:setTeam(2)
  world:queryAgentsInRadius(0.0, 0.0, 32.0, { exclude = "alpha", hostileTo = 1 })
  local stats = world:getSpatialQueryStats()
  lurek.log.info(tostring("LAIWorld:getSpatialQueryStats: candidates=" .. tostring(stats.candidateChecks)))
  lurek.log.info(tostring("LAIWorld:getSpatialQueryStats: returned=" .. tostring(stats.returnedAgents)))
end

--@api: LAIWorld:setOrderArrivalRadius
do
  local world = lurek.ai.newWorld()
  world:setOrderArrivalRadius(2.5)
  local radius = world:getOrderArrivalRadius()
  local stats = world:getOrderRuntimeStats()
  lurek.log.info(tostring("LAIWorld:setOrderArrivalRadius: radius=" .. tostring(radius)))
  lurek.log.info(tostring("LAIWorld:setOrderArrivalRadius: active=" .. tostring(stats.activeAgents)))
end

--@api: LAIWorld:getOrderArrivalRadius
do
  local world = lurek.ai.newWorld()
  world:setOrderArrivalRadius(3.0)
  local radius = world:getOrderArrivalRadius()
  local world_type = world:type()
  lurek.log.info(tostring("LAIWorld:getOrderArrivalRadius: " .. tostring(radius)))
  lurek.log.info(tostring("LAIWorld:getOrderArrivalRadius: type=" .. tostring(world_type)))
end

--@api: LAIWorld:setAutoAcquireBudget
do
  local world = lurek.ai.newWorld()
  world:setAutoAcquireBudget(3)
  local budget = world:getAutoAcquireBudget()
  local stats = world:getOrderRuntimeStats()
  lurek.log.info(tostring("LAIWorld:setAutoAcquireBudget: budget=" .. tostring(budget)))
  lurek.log.info(tostring("LAIWorld:setAutoAcquireBudget: skipped=" .. tostring(stats.budgetSkips)))
end

--@api: LAIWorld:getAutoAcquireBudget
do
  local world = lurek.ai.newWorld()
  world:setAutoAcquireBudget(5)
  local budget = world:getAutoAcquireBudget()
  local world_type = world:type()
  lurek.log.info(tostring("LAIWorld:getAutoAcquireBudget: " .. tostring(budget)))
  lurek.log.info(tostring("LAIWorld:getAutoAcquireBudget: type=" .. tostring(world_type)))
end

--@api: LAIWorld:getOrderRuntimeStats
do
  local world = lurek.ai.newWorld()
  world:setSpatialCellSize(16.0)
  world:setOrderArrivalRadius(0.5)
  local hero = world:addAgent("hero")
  local enemy = world:addAgent("enemy")
  hero:setTeam(1)
  hero:setPosition(0.0, 0.0)
  hero:setStance("aggressive", { acquireRadius = 64.0, chaseRadius = 24.0 })
  hero:getCommandQueue():enqueue("move", function() end, { targetX = 32.0, targetY = 0.0 })
  enemy:setTeam(2)
  enemy:setPosition(8.0, 0.0)
  world:update(0.1)
  local stats = world:getOrderRuntimeStats()
  lurek.log.info(tostring("LAIWorld:getOrderRuntimeStats: queries=" .. tostring(stats.acquireQueries)))
  lurek.log.info(tostring("LAIWorld:getOrderRuntimeStats: interrupts=" .. tostring(stats.softInterrupts)))
end

--@api: LAIWorld:queryAgentsInRadius
do
  local world = lurek.ai.newWorld()
  world:setSpatialCellSize(16.0)
  local alpha = world:addAgent("alpha")
  local beta = world:addAgent("beta")
  local gamma = world:addAgent("gamma")
  alpha:setPosition(0.0, 0.0)
  alpha:setTeam(1)
  beta:setPosition(8.0, 0.0)
  beta:setTeam(2)
  beta:addTag("hostile")
  gamma:setPosition(12.0, 0.0)
  gamma:setTeam(2)
  gamma:addTag("hidden")
  local found = world:queryAgentsInRadius(0.0, 0.0, 32.0, { exclude = "alpha", hostileTo = 1, limit = 1, tag = "hostile", notTag = "hidden" })
  lurek.log.info(tostring("LAIWorld:queryAgentsInRadius: count=" .. tostring(#found)))
  lurek.log.info(tostring("LAIWorld:queryAgentsInRadius: first=" .. tostring(found[1] and found[1]:getName())))
end

--@api: LAIWorld:update
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("worker")
  local runner = world:addAgent("runner")
  local ticked = false
  npc:setCustomModel(function(agent, blackboard, dt) ticked = true end)
  runner:getCommandQueue():enqueue("move", function() end, { targetX = 10.0, targetY = 0.0 })
  world:setOrderArrivalRadius(0.5)
  world:update(1.0)
  local x, y = runner:getPosition()
  lurek.log.info(tostring("LAIWorld:update: ticked=" .. tostring(ticked)))
  lurek.log.info(tostring("LAIWorld:update: runner=" .. tostring(x) .. "," .. tostring(y)))
end

--@api: LAIWorld:type
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local t = world:type()
  local ok = world:typeOf("LAIWorld")
  lurek.log.info(tostring("LAIWorld:type: " .. t))
  lurek.log.info(tostring("LAIWorld:type: matches=" .. tostring(ok)))
end

--@api: LAIWorld:typeOf
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local is_world = world:typeOf("LAIWorld")
  local is_wrong = world:typeOf("LImage")
  lurek.log.info(tostring("LAIWorld:typeOf: LAIWorld=" .. tostring(is_world) .. " LImage=" .. tostring(is_wrong)))
end

--@api: LBot:getName
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("knight_03")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  local name = npc:getName()
  lurek.log.info(tostring("LBot:getName: " .. name))
end

--@api: LBot:setPosition
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("mover")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  npc:setPosition(256, 128)
  local x, y = npc:getPosition()
  lurek.log.info(tostring("LBot:setPosition: done"))
  lurek.log.info(tostring("LBot:setPosition: pos=" .. tostring(x) .. ", " .. tostring(y)))
end

--@api: LBot:getPosition
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("static_guard")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  npc:setPosition(400, 300)
  local x, y = npc:getPosition()
  lurek.log.info(tostring("LBot:getPosition: " .. tostring(x) .. ", " .. tostring(y)))
end

--@api: LBot:setVelocity
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("runner")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  npc:setVelocity(60, -30)
  local vx, vy = npc:getVelocity()
  lurek.log.info(tostring("LBot:setVelocity: done"))
  lurek.log.info(tostring("LBot:setVelocity: vel=" .. tostring(vx) .. ", " .. tostring(vy)))
end

--@api: LBot:getVelocity
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("idle_npc")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  npc:setVelocity(0, 0)
  local vx, vy = npc:getVelocity()
  lurek.log.info(tostring("LBot:getVelocity: vx=" .. tostring(vx) .. " vy=" .. tostring(vy)))
end

--@api: LBot:setMaxSpeed
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("sprinter")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  npc:setMaxSpeed(200)
  lurek.log.info(tostring("LBot:setMaxSpeed: done"))
  lurek.log.info(tostring("LBot:setMaxSpeed: speed=" .. tostring(npc:getMaxSpeed())))
end

--@api: LBot:getMaxSpeed
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("courier")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  npc:setMaxSpeed(150)
  local speed = npc:getMaxSpeed()
  lurek.log.info(tostring("LBot:getMaxSpeed: " .. tostring(speed)))
  lurek.log.info(tostring("LBot:getMaxSpeed: name=" .. npc:getName()))
end

--@api: LBot:setMaxForce
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("tank")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  npc:setMaxForce(80)
  lurek.log.info(tostring("LBot:setMaxForce: done"))
  lurek.log.info(tostring("LBot:setMaxForce: force=" .. tostring(npc:getMaxForce())))
end

--@api: LBot:getMaxForce
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("scout")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  npc:setMaxForce(200)
  local force = npc:getMaxForce()
  lurek.log.info(tostring("LBot:getMaxForce: " .. tostring(force)))
  lurek.log.info(tostring("LBot:getMaxForce: name=" .. npc:getName()))
end

--@api: LBot:setPriority
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("captain")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  npc:setPriority(10)
  lurek.log.info(tostring("LBot:setPriority: " .. tostring(npc:getPriority())))
end

--@api: LBot:getPriority
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("grunt")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  npc:setPriority(5)
  local prio = npc:getPriority()
  lurek.log.info(tostring("LBot:getPriority: " .. tostring(prio)))
end

--@api: LBot:setTeam
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("captain")
  npc:setTeam(3)
  local team = npc:getTeam()
  local name = npc:getName()
  lurek.log.info(tostring("LBot:setTeam: team=" .. tostring(team)))
  lurek.log.info(tostring("LBot:setTeam: name=" .. tostring(name)))
end

--@api: LBot:getTeam
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("grunt")
  npc:setTeam(5)
  local team = npc:getTeam()
  local type_name = npc:type()
  lurek.log.info(tostring("LBot:getTeam: " .. tostring(team)))
  lurek.log.info(tostring("LBot:getTeam: type=" .. tostring(type_name)))
end

--@api: LBot:setStance
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("raider")
  npc:setStance("defensive", { chaseRadius = 48.0, interruptsMove = true })
  local stance = npc:getStance()
  local team = npc:getTeam()
  lurek.log.info(tostring("LBot:setStance: stance=" .. tostring(stance.stance)))
  lurek.log.info(tostring("LBot:setStance: chase=" .. tostring(stance.chaseRadius) .. " team=" .. tostring(team)))
end

--@api: LBot:getStance
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("guardian")
  local stance = npc:getStance()
  local interrupt = stance.interruptsMove
  local radius = stance.acquireRadius
  lurek.log.info(tostring("LBot:getStance: stance=" .. tostring(stance.stance)))
  lurek.log.info(tostring("LBot:getStance: radius=" .. tostring(radius) .. " interrupt=" .. tostring(interrupt)))
end

--@api: LBot:setDecisionModel
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("worker")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  npc:setDecisionModel("custom")
  local model = npc:getDecisionModel()
  lurek.log.info(tostring("LBot:setDecisionModel: " .. model))
end

--@api: LBot:getDecisionModel
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("farmer")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  npc:setDecisionModel("custom")
  local model = npc:getDecisionModel()
  lurek.log.info(tostring("LBot:getDecisionModel: " .. model))
end

--@api: LBot:setCustomModel
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("thinker")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  npc:setDecisionModel("custom")
  local called_with_dt = 0
  npc:setCustomModel(function(agent, bb, dt) called_with_dt = dt end)
  world:update(0.016)
  lurek.log.info(tostring("LBot:setCustomModel: dt=" .. tostring(called_with_dt)))
end

--@api: LBot:setTraitProfile
do
  local world = lurek.ai.newWorld()
  local bot = world:addAgent("commander")
  local profile = lurek.ai.newTraitProfile()
  profile:set("aggression", 0.7)
  bot:setTraitProfile(profile)
  local aggression = bot:getTrait("aggression")
  lurek.log.info(tostring("LBot:setTraitProfile: aggression=" .. tostring(aggression)))
end

--@api: LBot:getTraitProfile
do
  local world = lurek.ai.newWorld()
  local bot = world:addAgent("commander")
  bot:setTrait("caution", 0.6)
  local profile = bot:getTraitProfile()
  local caution = profile:get("caution")
  lurek.log.info(tostring("LBot:getTraitProfile: caution=" .. tostring(caution)))
end

--@api: LBot:hasTraitProfile
do
  local world = lurek.ai.newWorld()
  local bot = world:addAgent("commander")
  local before = bot:hasTraitProfile()
  bot:setTrait("caution", 0.6)
  local after = bot:hasTraitProfile()
  lurek.log.info(tostring("LBot:hasTraitProfile: before=" .. tostring(before) .. " after=" .. tostring(after)))
end

--@api: LBot:setTrait
do
  local world = lurek.ai.newWorld()
  local bot = world:addAgent("commander")
  bot:setTrait("risk_tolerance", 0.8)
  local risk = bot:getTrait("risk_tolerance")
  bot:setTrait("risk_tolerance", 0.6)
  lurek.log.info(tostring("LBot:setTrait: risk=" .. tostring(risk) .. " updated=" .. tostring(bot:getTrait("risk_tolerance"))))
end

--@api: LBot:getTrait
do
  local world = lurek.ai.newWorld()
  local bot = world:addAgent("commander")
  bot:setTrait("aggression", 0.75)
  local aggression = bot:getTrait("aggression")
  local missing = bot:getTrait("missing")
  lurek.log.info(tostring("LBot:getTrait: aggression=" .. tostring(aggression) .. " missing=" .. tostring(missing)))
end

--@api: LBot:addTraitModifier
do
  local world = lurek.ai.newWorld()
  local bot = world:addAgent("commander")
  bot:setTrait("caution", 0.3)
  bot:addTraitModifier("caution", 0.4, 1.0, "ambush")
  local boosted = bot:getTrait("caution")
  world:update(2.0)
  lurek.log.info(tostring("LBot:addTraitModifier: boosted=" .. tostring(boosted) .. " now=" .. tostring(bot:getTrait("caution"))))
end

--@api: LBot:addTag
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("guard")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  npc:addTag("hostile")
  local has_hostile = npc:hasTag("hostile")
  lurek.log.info(tostring("LBot:addTag: hostile=" .. tostring(has_hostile)))
end

--@api: LBot:removeTag
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("spy")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  npc:addTag("visible")
  npc:removeTag("visible")
  local still_has = npc:hasTag("visible")
  lurek.log.info(tostring("LBot:removeTag: visible=" .. tostring(still_has)))
end

--@api: LBot:hasTag
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("merchant")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  npc:addTag("friendly")
  local friendly = npc:hasTag("friendly")
  local hostile = npc:hasTag("hostile")
  lurek.log.info(tostring("LBot:hasTag: friendly=" .. tostring(friendly) .. " hostile=" .. tostring(hostile)))
end

--@api: LBot:findHostilesInRange
do
  local world = lurek.ai.newWorld()
  world:setSpatialCellSize(16.0)
  local hero = world:addAgent("hero")
  local enemy = world:addAgent("enemy")
  local ally = world:addAgent("ally")
  hero:setTeam(1)
  hero:setPosition(0.0, 0.0)
  enemy:setTeam(2)
  enemy:setPosition(20.0, 0.0)
  enemy:addTag("visible")
  ally:setTeam(1)
  ally:setPosition(10.0, 0.0)
  local found = hero:findHostilesInRange(64.0, { tag = "visible", limit = 4 })
  lurek.log.info(tostring("LBot:findHostilesInRange: count=" .. tostring(#found)))
  lurek.log.info(tostring("LBot:findHostilesInRange: first=" .. tostring(found[1] and found[1]:getName())))
end

--@api: LBot:acquireTarget
do
  local world = lurek.ai.newWorld()
  world:setSpatialCellSize(16.0)
  local hero = world:addAgent("hero")
  local near_enemy = world:addAgent("near_enemy")
  local far_enemy = world:addAgent("far_enemy")
  hero:setTeam(1)
  hero:setPosition(0.0, 0.0)
  hero:setStance("aggressive", { acquireRadius = 80.0 })
  near_enemy:setTeam(2)
  near_enemy:setPosition(24.0, 0.0)
  far_enemy:setTeam(2)
  far_enemy:setPosition(120.0, 0.0)
  local target = hero:acquireTarget()
  lurek.log.info(tostring("LBot:acquireTarget: found=" .. tostring(target ~= nil)))
  lurek.log.info(tostring("LBot:acquireTarget: target=" .. tostring(target and target:getName())))
end

--@api: LBot:getBlackboard
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("ranger")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  local bb = npc:getBlackboard()
  bb:setNumber("hp", 100)
  local hp = bb:getNumber("hp", 0)
  lurek.log.info(tostring("LBot:getBlackboard: hp=" .. tostring(hp)))
end

--@api: LBot:getCommandQueue
do
  local world = lurek.ai.newWorld()
  local bot = world:addAgent("order_owner")
  local queue = bot:getCommandQueue()
  local order_id = queue:enqueue("move", function() end, { targetX = 16, targetY = 24, priority = 2 })
  local current = bot:getCurrentOrder()
  lurek.log.info(tostring("LBot:getCommandQueue: id=" .. tostring(order_id)))
  lurek.log.info(tostring("LBot:getCommandQueue: kind=" .. tostring(current and current.kind)))
end

--@api: LBot:getCurrentOrder
do
  local world = lurek.ai.newWorld()
  local bot = world:addAgent("order_reader")
  local queue = bot:getCommandQueue()
  queue:enqueue("guard", function() end, { targetX = 32, targetY = 40 })
  local current = bot:getCurrentOrder()
  lurek.log.info(tostring("LBot:getCurrentOrder: id=" .. tostring(current and current.id)))
  lurek.log.info(tostring("LBot:getCurrentOrder: target=" .. tostring(current and current.targetX) .. "," .. tostring(current and current.targetY)))
end

--@api: LBot:getOrderRuntimeState
do
  local world = lurek.ai.newWorld()
  world:setSpatialCellSize(16.0)
  local hero = world:addAgent("hero")
  local enemy = world:addAgent("enemy")
  hero:setTeam(1)
  hero:setPosition(0.0, 0.0)
  hero:setStance("aggressive", { acquireRadius = 64.0, chaseRadius = 24.0, abandonFormation = true })
  hero:getCommandQueue():enqueue("move", function() end, { targetX = 100.0, targetY = 0.0, interruptible = true })
  enemy:setTeam(2)
  enemy:setPosition(8.0, 0.0)
  world:update(0.1)
  local state = hero:getOrderRuntimeState()
  lurek.log.info(tostring("LBot:getOrderRuntimeState: active=" .. tostring(state.active)))
  lurek.log.info(tostring("LBot:getOrderRuntimeState: target=" .. tostring(state.engageTarget)))
end

--@api: LBot:clearOrders
do
  local world = lurek.ai.newWorld()
  local bot = world:addAgent("order_clear")
  local queue = bot:getCommandQueue()
  queue:enqueue("move", function() end)
  queue:enqueue("patrol", function() end)
  local cleared = bot:clearOrders("player_stop")
  lurek.log.info(tostring("LBot:clearOrders: cleared=" .. tostring(cleared)))
  lurek.log.info(tostring("LBot:clearOrders: empty=" .. tostring(queue:isEmpty())))
end

--@api: LBot:drainCommandEvents
do
  local world = lurek.ai.newWorld()
  local bot = world:addAgent("order_events")
  local queue = bot:getCommandQueue()
  queue:enqueue("move", function() end, { targetX = 4, targetY = 8 })
  queue:completeCurrent("arrived")
  local events = bot:drainCommandEvents()
  lurek.log.info(tostring("LBot:drainCommandEvents: count=" .. tostring(#events)))
  lurek.log.info(tostring("LBot:drainCommandEvents: last=" .. tostring(events[#events] and events[#events].event)))
end

--@api: LBot:type
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("villager")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  local t = npc:type()
  lurek.log.info(tostring("LBot:type: " .. t))
  lurek.log.info(tostring("LBot:type: matches=" .. tostring(npc:typeOf("LBot"))))
end

--@api: LBot:typeOf
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("knight")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  local is_agent = npc:typeOf("LBot")
  local is_image = npc:typeOf("LImage")
  lurek.log.info(tostring("LBot:typeOf: LBot=" .. tostring(is_agent) .. " LImage=" .. tostring(is_image)))
end

--@api: LAIBlackboard:setNumber
do
  local bb = lurek.ai.newBlackboard()
  bb:setString("context", "active")
  local bb_size = bb:getSize()
  bb:setNumber("distance", 42.5)
  bb:setNumber("ammo", 30)
  local dist = bb:getNumber("distance", 0)
  lurek.log.info(tostring("LAIBlackboard:setNumber: distance=" .. tostring(dist)))
end

--@api: LAIBlackboard:getNumber
do
  local bb = lurek.ai.newBlackboard()
  bb:setString("context", "active")
  local bb_size = bb:getSize()
  bb:setNumber("score", 95.5)
  local score = bb:getNumber("score", 0)
  local missing = bb:getNumber("nonexistent", -1)
  lurek.log.info(tostring("LAIBlackboard:getNumber: score=" .. tostring(score) .. " missing=" .. tostring(missing)))
end

--@api: LAIBlackboard:setBool
do
  local bb = lurek.ai.newBlackboard()
  bb:setString("context", "active")
  local bb_size = bb:getSize()
  bb:setBool("can_attack", true)
  bb:setBool("is_hiding", false)
  local attack = bb:getBool("can_attack", false)
  lurek.log.info(tostring("LAIBlackboard:setBool: can_attack=" .. tostring(attack)))
end

--@api: LAIBlackboard:getBool
do
  local bb = lurek.ai.newBlackboard()
  bb:setString("context", "active")
  local bb_size = bb:getSize()
  bb:setBool("alert", true)
  local alert = bb:getBool("alert", false)
  local calm = bb:getBool("calm", true)
  lurek.log.info(tostring("LAIBlackboard:getBool: alert=" .. tostring(alert) .. " calm=" .. tostring(calm)))
end

--@api: LAIBlackboard:setString
do
  local bb = lurek.ai.newBlackboard()
  bb:setString("context", "active")
  local bb_size = bb:getSize()
  bb:setString("target_name", "dragon")
  bb:setString("current_zone", "forest")
  local target = bb:getString("target_name", "none")
  lurek.log.info(tostring("LAIBlackboard:setString: target=" .. target))
end

--@api: LAIBlackboard:getString
do
  local bb = lurek.ai.newBlackboard()
  bb:setString("context", "active")
  local bb_size = bb:getSize()
  bb:setString("weapon", "sword")
  local weapon = bb:getString("weapon", "fists")
  local shield = bb:getString("shield", "none")
  lurek.log.info(tostring("LAIBlackboard:getString: weapon=" .. weapon .. " shield=" .. shield))
end

--@api: LAIBlackboard:has
do
  local bb = lurek.ai.newBlackboard()
  bb:setString("context", "active")
  local bb_size = bb:getSize()
  bb:setNumber("hp", 80)
  local has_hp = bb:has("hp")
  local has_mp = bb:has("mp")
  lurek.log.info(tostring("LAIBlackboard:has: hp=" .. tostring(has_hp) .. " mp=" .. tostring(has_mp)))
end

--@api: LAIBlackboard:remove
do
  local bb = lurek.ai.newBlackboard()
  bb:setString("context", "active")
  local bb_size = bb:getSize()
  bb:setNumber("temp", 99)
  bb:remove("temp")
  local still_has = bb:has("temp")
  lurek.log.info(tostring("LAIBlackboard:remove: has_temp=" .. tostring(still_has)))
end

--@api: LAIBlackboard:clear
do
  local bb = lurek.ai.newBlackboard()
  bb:setString("context", "active")
  local bb_size = bb:getSize()
  bb:setNumber("a", 1)
  bb:setString("b", "x")
  bb:setBool("c", true)
  bb:clear()
  local size = bb:getSize()
  lurek.log.info(tostring("LAIBlackboard:clear: size=" .. tostring(size)))
end

--@api: LAIBlackboard:getKeys
do
  local bb = lurek.ai.newBlackboard()
  bb:setString("context", "active")
  local bb_size = bb:getSize()
  bb:setNumber("hp", 100)
  bb:setString("state", "idle")
  local keys = bb:getKeys()
  lurek.log.info(tostring("LAIBlackboard:getKeys: count=" .. tostring(#keys)))
end

--@api: LAIBlackboard:getSize
do
  local bb = lurek.ai.newBlackboard()
  bb:setString("context", "active")
  local bb_size = bb:getSize()
  bb:setNumber("hp", 10)
  bb:setString("name", "test")
  local size = bb:getSize()
  lurek.log.info(tostring("LAIBlackboard:getSize: " .. tostring(size)))
end

--@api: LAIBlackboard:type
do
  local bb = lurek.ai.newBlackboard()
  bb:setString("context", "active")
  local bb_size = bb:getSize()
  local t = bb:type()
  lurek.log.info(tostring("LAIBlackboard:type: " .. t))
  lurek.log.info(tostring("LAIBlackboard:type: matches=" .. tostring(bb:typeOf("LAIBlackboard"))))
end

--@api: LAIBlackboard:typeOf
do
  local bb = lurek.ai.newBlackboard()
  bb:setString("context", "active")
  local bb_size = bb:getSize()
  local is_bb = bb:typeOf("LAIBlackboard")
  local is_agent = bb:typeOf("LBot")
  lurek.log.info(tostring("LAIBlackboard:typeOf: LAIBlackboard=" .. tostring(is_bb) .. " LBot=" .. tostring(is_agent)))
end

--@api: LStateMachine:addState
do
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("idle", {})
  local fsm_type = fsm:type()
  local entered = ""
  fsm:addState("patrol", { onEnter = function() entered = "patrol" end })
  fsm:setInitialState("patrol")
  lurek.log.info(tostring("LStateMachine:addState: entered=" .. entered))
end

--@api: LStateMachine:addTransition
do
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("idle", {})
  local fsm_type = fsm:type()
  fsm:addState("idle", {})
  fsm:addState("alert", {})
  fsm:addTransition("idle", "alert", function() return true end, 1)
  lurek.log.info(tostring("LStateMachine:addTransition: configured"))
end

--@api: LStateMachine:setInitialState
do
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("idle", {})
  local fsm_type = fsm:type()
  local log = ""
  fsm:addState("sleep", { onEnter = function() log = "entered_sleep" end })
  fsm:setInitialState("sleep")
  local current = fsm:getCurrentState() or "none"
  lurek.log.info(tostring("LStateMachine:setInitialState: " .. current .. " log=" .. log))
end

--@api: LStateMachine:getCurrentState
do
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("idle", {})
  local fsm_type = fsm:type()
  fsm:addState("wander", {})
  local before = fsm:getCurrentState()
  fsm:setInitialState("wander")
  local after = fsm:getCurrentState()
  lurek.log.info(tostring("LStateMachine:getCurrentState: before=" .. tostring(before) .. " after=" .. tostring(after)))
end

--@api: LStateMachine:forceState
do
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("idle", {})
  local fsm_type = fsm:type()
  fsm:addState("alive", {})
  fsm:addState("dead", {})
  fsm:setInitialState("alive")
  fsm:forceState("dead")
  local current = fsm:getCurrentState() or "none"
  lurek.log.info(tostring("LStateMachine:forceState: " .. current))
end

--@api: LStateMachine:getTimeInState
do
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("idle", {})
  local fsm_type = fsm:type()
  fsm:addState("cooking", {})
  fsm:setInitialState("cooking")
  local time_in = fsm:getTimeInState()
  lurek.log.info(tostring("LStateMachine:getTimeInState: " .. tostring(time_in)))
end

--@api: LStateMachine:type
do
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("idle", {})
  local fsm_type = fsm:type()
  local t = fsm:type()
  lurek.log.info(tostring("LStateMachine:type: " .. t))
  lurek.log.info(tostring("LStateMachine:type: matches=" .. tostring(fsm:typeOf("LStateMachine"))))
end

--@api: LStateMachine:typeOf
do
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("idle", {})
  local fsm_type = fsm:type()
  local is_fsm = fsm:typeOf("LStateMachine")
  local is_other = fsm:typeOf("LBehaviorTree")
  lurek.log.info(tostring("LStateMachine:typeOf: LStateMachine=" .. tostring(is_fsm) .. " LBehaviorTree=" .. tostring(is_other)))
end

--@api: LBehaviorTree:getLastStatus
do
  local bt = lurek.ai.newBehaviorTree()
  local bt_debug = bt:getDebugState()
  local bt_status = bt:getLastStatus()
  bt:setRoot(lurek.ai.newAction(function() return "success" end))
  local status = bt:getLastStatus()
  lurek.log.info(tostring("LBehaviorTree:getLastStatus: " .. status))
end

--@api: LBehaviorTree:getDebugState
do
  local bt = lurek.ai.newBehaviorTree()
  local bt_debug = bt:getDebugState()
  local bt_status = bt:getLastStatus()
  bt:setRoot(lurek.ai.newAction(function() return "success" end))
  local info = bt:getDebugState()
  lurek.log.info(tostring("LBehaviorTree:getDebugState: node_count=" .. tostring(info.node_count)))
  lurek.log.info(tostring("LBehaviorTree:getDebugState: last_status=" .. tostring(info.last_status)))
end

--@api: LBehaviorTree:type
do
  local bt = lurek.ai.newBehaviorTree()
  local bt_debug = bt:getDebugState()
  local bt_status = bt:getLastStatus()
  local t = bt:type()
  lurek.log.info(tostring("LBehaviorTree:type: " .. t))
  lurek.log.info(tostring("LBehaviorTree:type: matches=" .. tostring(bt:typeOf("LBehaviorTree"))))
end

--@api: LBehaviorTree:typeOf
do
  local bt = lurek.ai.newBehaviorTree()
  local bt_debug = bt:getDebugState()
  local bt_status = bt:getLastStatus()
  local is_bt = bt:typeOf("LBehaviorTree")
  local is_other = bt:typeOf("LBot")
  lurek.log.info(tostring("LBehaviorTree:typeOf: LBehaviorTree=" .. tostring(is_bt) .. " LBot=" .. tostring(is_other)))
end

--@api: LBTNode:addChild
do
  local seq = lurek.ai.newSequence()
  local node_type = seq:getNodeType()
  local child_count = seq:getChildCount()
  seq:addChild(lurek.ai.newAction(function() return "success" end))
  local count = seq:getChildCount()
  lurek.log.info(tostring("LBTNode:addChild: children=" .. tostring(count)))
end

--@api: LBTNode:getChildCount
do
  local sel = lurek.ai.newSelector()
  local node_type = sel:getNodeType()
  local child_count = sel:getChildCount()
  sel:addChild(lurek.ai.newAction(function() return "success" end))
  local count = sel:getChildCount()
  lurek.log.info(tostring("LBTNode:getChildCount: " .. tostring(count)))
end

--@api: LBTNode:reset
do
  local seq = lurek.ai.newSequence()
  local node_type = seq:getNodeType()
  local child_count = seq:getChildCount()
  seq:addChild(lurek.ai.newAction(function() return "running" end))
  seq:reset()
  lurek.log.info(tostring("LBTNode:reset: done"))
end

--@api: LBTNode:setChild
do
  local inv = lurek.ai.newInverter()
  local node_type = inv:getNodeType()
  local child_count = inv:getChildCount()
  inv:setChild(lurek.ai.newAction(function() return "failure" end))
  lurek.log.info(tostring("LBTNode:setChild: configured"))
  lurek.log.info(tostring("LBTNode:setChild: type=" .. inv:getNodeType()))
end

--@api: LBTNode:setCount
do
  local rep = lurek.ai.newRepeater(3)
  local node_type = rep:getNodeType()
  local child_count = rep:getChildCount()
  rep:setCount(10)
  local count = rep:getCount()
  lurek.log.info(tostring("LBTNode:setCount: " .. tostring(count)))
end

--@api: LBTNode:getCount
do
  local rep = lurek.ai.newRepeater(7)
  local node_type = rep:getNodeType()
  local child_count = rep:getChildCount()
  local count = rep:getCount()
  lurek.log.info(tostring("LBTNode:getCount: " .. tostring(count)))
end

--@api: LBTNode:setSuccessPolicy
do
  local par = lurek.ai.newParallel("requireAll", "requireOne")
  local node_type = par:getNodeType()
  local child_count = par:getChildCount()
  par:setSuccessPolicy("requireOne")
  lurek.log.info(tostring("LBTNode:setSuccessPolicy: done"))
  lurek.log.info(tostring("LBTNode:setSuccessPolicy: type=" .. par:getNodeType()))
end

--@api: LBTNode:setFailurePolicy
do
  local par = lurek.ai.newParallel("requireOne", "requireAll")
  local node_type = par:getNodeType()
  local child_count = par:getChildCount()
  par:setFailurePolicy("requireOne")
  lurek.log.info(tostring("LBTNode:setFailurePolicy: done"))
  lurek.log.info(tostring("LBTNode:setFailurePolicy: type=" .. par:getNodeType()))
end

--@api: LBTNode:getNodeType
do
  local act = lurek.ai.newAction(function() return "success" end)
  local node_type = act:getNodeType()
  local child_count = act:getChildCount()
  act:reset()
  lurek.log.info(tostring("LBTNode:getNodeType: " .. act:getNodeType()))
end

--@api: LBTNode:type
do
  local node = lurek.ai.newAction(function() return "success" end)
  local node_type = node:getNodeType()
  local child_count = node:getChildCount()
  local t = node:type()
  lurek.log.info(tostring("LBTNode:type: " .. t))
  lurek.log.info(tostring("LBTNode:type: matches=" .. tostring(node:typeOf("LBTNode"))))
end

--@api: LBTNode:typeOf
do
  local node = lurek.ai.newSelector()
  local node_type = node:getNodeType()
  local child_count = node:getChildCount()
  local is_node = node:typeOf("LBTNode")
  local is_other = node:typeOf("LImage")
  lurek.log.info(tostring("LBTNode:typeOf: LBTNode=" .. tostring(is_node) .. " LImage=" .. tostring(is_other)))
end

--@api: LUtilityAI:addAction
do
    local uai = lurek.ai.newUtilityAI()
  uai:addAction("idle", function() return 0.1 end)
  local chosen_preview = uai:evaluate()
    uai:addAction("eat", function() return 0.8 end, 1.0)
    uai:addAction("sleep", function() return 0.3 end, 1.0)
    lurek.log.info(tostring("actions added = " .. uai:getActionCount()))
end

--@api: LUtilityAI:evaluate
do
    local uai = lurek.ai.newUtilityAI()
  uai:addAction("idle", function() return 0.1 end)
  local chosen_preview = uai:evaluate()
    uai:addAction("attack", function() return 0.9 end)
    uai:addAction("defend", function() return 0.4 end)
    local chosen = uai:evaluate()
    lurek.log.info(tostring("chosen action = " .. tostring(chosen)))
end

--@api: LUtilityAI:evaluateWithProfile
do
  local uai = lurek.ai.newUtilityAI()
  local profile = lurek.ai.newTraitProfile()
  local bias = lurek.ai.newDecisionBiasSet()
  uai:addAction("attack", function() return 0.4 end)
  uai:addAction("defend", function() return 0.5 end)
  profile:set("aggression", 0.8)
  bias:addRule("aggression", "attack", 0.3, "add")
  lurek.log.info(tostring("LUtilityAI:evaluateWithProfile: chosen=" .. tostring(uai:evaluateWithProfile(profile, bias))))
end

--@api: LUtilityAI:getActionCount
do
    local uai = lurek.ai.newUtilityAI()
  uai:addAction("idle", function() return 0.1 end)
  local chosen_preview = uai:evaluate()
    uai:addAction("patrol", function() return 0.5 end)
    uai:addAction("idle", function() return 0.1 end)
    uai:addAction("chase", function() return 0.7 end)
    lurek.log.info(tostring("action count = " .. uai:getActionCount()))
end

--@api: LUtilityAI:getLastAction
do
  local uai = lurek.ai.newUtilityAI()
  uai:addAction("idle", function() return 0.1 end)
  local chosen_preview = uai:evaluate()
  uai:addAction("gather", function() return 0.6 end)
    uai:addAction("build", function() return 0.2 end)
    uai:evaluate()
    local last = uai:getLastAction()
    lurek.log.info(tostring("last action = " .. tostring(last)))
end

--@api: LUtilityAI:addConsideration
do
    local uai = lurek.ai.newUtilityAI()
  uai:addAction("idle", function() return 0.1 end)
  local chosen_preview = uai:evaluate()
    uai:addAction("heal", function() return 0.5 end)
    uai:addConsideration("heal", "low_health", function() return 0.9 end, "linear", 1.0, 0.0, 0.0, 1.0)
    uai:evaluate()
    lurek.log.info(tostring("consideration added, last = " .. tostring(uai:getLastAction())))
end

--@api: LUtilityAI:type
do
    local uai = lurek.ai.newUtilityAI()
  uai:addAction("idle", function() return 0.1 end)
  local chosen_preview = uai:evaluate()
    lurek.log.info(tostring("type = " .. uai:type()))
  lurek.log.info(tostring("matches = " .. tostring(uai:typeOf("LUtilityAI"))))
end

--@api: LUtilityAI:typeOf
do
    local uai = lurek.ai.newUtilityAI()
  uai:addAction("idle", function() return 0.1 end)
  local chosen_preview = uai:evaluate()
    local type_name = uai:type()
    lurek.log.info(tostring("is LUtilityAI = " .. tostring(uai:typeOf("LUtilityAI"))))
end

--@api: LGOAPPlanner:addAction
do
    local goap = lurek.ai.newGOAPPlanner()
  goap:addGoal("idle", 1)
  local goal_count = goap:getGoalCount()
    goap:addAction("chop_wood", 2, function() lurek.log.info(tostring("  chopping wood")) end)
    goap:addAction("build_house", 5, function() lurek.log.info(tostring("  building house")) end)
    lurek.log.info(tostring("goap actions = " .. goap:getActionCount()))
end

--@api: LGOAPPlanner:setPrecondition
do
    local goap = lurek.ai.newGOAPPlanner()
  goap:addGoal("idle", 1)
  local goal_count = goap:getGoalCount()
    goap:addAction("cook", 1, function() end)
    goap:setPrecondition("cook", "has_food", true)
    lurek.log.info(tostring("precondition set for cook"))
end

--@api: LGOAPPlanner:setEffect
do
    local goap = lurek.ai.newGOAPPlanner()
  goap:addGoal("idle", 1)
  local goal_count = goap:getGoalCount()
    goap:addAction("mine_ore", 3, function() end)
    goap:setEffect("mine_ore", "has_ore", true)
    lurek.log.info(tostring("effect set for mine_ore"))
end

--@api: LGOAPPlanner:addGoal
do
    local goap = lurek.ai.newGOAPPlanner()
  goap:addGoal("idle", 1)
  local goal_count = goap:getGoalCount()
    goap:addGoal("survive", 10)
    goap:addGoal("explore", 3)
    lurek.log.info(tostring("goals = " .. goap:getGoalCount()))
end

--@api: LGOAPPlanner:setGoalState
do
    local goap = lurek.ai.newGOAPPlanner()
  goap:addGoal("idle", 1)
  local goal_count = goap:getGoalCount()
    goap:addGoal("build_shelter", 5)
    goap:setGoalState("build_shelter", "shelter_built", true)
    lurek.log.info(tostring("goal state set for build_shelter"))
end

--@api: LGOAPPlanner:plan
do
  local goap = lurek.ai.newGOAPPlanner()
  goap:addGoal("idle", 1)
  local goal_count = goap:getGoalCount()
  goap:addAction("get_wood", 1, function() end)
  goap:setEffect("get_wood", "has_wood", true)
  goap:addAction("build", 2, function() end)
  goap:setPrecondition("build", "has_wood", true)
  goap:setEffect("build", "house_done", true)
  goap:addGoal("build_house", 10)
  goap:setGoalState("build_house", "house_done", true)
  local plan = goap:plan({ has_wood = false, house_done = false }, 10)
  lurek.log.info(tostring("plan steps = " .. #plan))
end

--@api: LGOAPPlanner:getActionCount
do
    local goap = lurek.ai.newGOAPPlanner()
  goap:addGoal("idle", 1)
  local goal_count = goap:getGoalCount()
    goap:addAction("a1", 1, function() end)
    goap:addAction("a2", 2, function() end)
    lurek.log.info(tostring("action count = " .. goap:getActionCount()))
end

--@api: LGOAPPlanner:getGoalCount
do
    local goap = lurek.ai.newGOAPPlanner()
  goap:addGoal("idle", 1)
  local goal_count = goap:getGoalCount()
    goap:addGoal("g1", 1)
    goap:addGoal("g2", 5)
    goap:addGoal("g3", 3)
    lurek.log.info(tostring("goal count = " .. goap:getGoalCount()))
end

--@api: LGOAPPlanner:getMaxIterations
do
    local goap = lurek.ai.newGOAPPlanner()
  goap:addGoal("idle", 1)
  local goal_count = goap:getGoalCount()
    local max = goap:getMaxIterations()
    lurek.log.info(tostring("default max iterations = " .. max))
end

--@api: LGOAPPlanner:setMaxIterations
do
    local goap = lurek.ai.newGOAPPlanner()
  goap:addGoal("idle", 1)
  local goal_count = goap:getGoalCount()
    goap:setMaxIterations(500)
    lurek.log.info(tostring("max iterations = " .. goap:getMaxIterations()))
end

--@api: LGOAPPlanner:type
do
    local goap = lurek.ai.newGOAPPlanner()
  goap:addGoal("idle", 1)
  local goal_count = goap:getGoalCount()
    lurek.log.info(tostring("type = " .. goap:type()))
  lurek.log.info(tostring("matches = " .. tostring(goap:typeOf("LGOAPPlanner"))))
end

--@api: LGOAPPlanner:typeOf
do
    local goap = lurek.ai.newGOAPPlanner()
  goap:addGoal("idle", 1)
  local goal_count = goap:getGoalCount()
    local type_name = goap:type()
    lurek.log.info(tostring("is LGOAPPlanner = " .. tostring(goap:typeOf("LGOAPPlanner"))))
end

--@api: LSquad:getName
do
    local sq = lurek.ai.newSquad("alpha")
  sq:addMember("unit_1")
  local member_count = sq:getMemberCount()
    sq:setLeader("unit_1")
    lurek.log.info(tostring("squad name = " .. sq:getName()))
end

--@api: LSquad:addMember
do
    local sq = lurek.ai.newSquad("bravo")
  sq:addMember("unit_1")
  local member_count = sq:getMemberCount()
    sq:addMember("soldier_1")
    sq:addMember("soldier_2")
    lurek.log.info(tostring("members = " .. sq:getMemberCount()))
end

--@api: LSquad:removeMember
do
    local sq = lurek.ai.newSquad("charlie")
  sq:addMember("unit_1")
  local member_count = sq:getMemberCount()
    sq:addMember("scout")
    sq:addMember("medic")
    sq:removeMember("scout")
    lurek.log.info(tostring("after remove = " .. sq:getMemberCount()))
end

--@api: LSquad:getMemberCount
do
    local sq = lurek.ai.newSquad("delta")
  sq:addMember("unit_1")
  local member_count = sq:getMemberCount()
    sq:addMember("a")
    sq:addMember("b")
    sq:addMember("c")
    lurek.log.info(tostring("count = " .. sq:getMemberCount()))
end

--@api: LSquad:getMembers
do
    local sq = lurek.ai.newSquad("echo")
  sq:addMember("unit_1")
  local member_count = sq:getMemberCount()
    sq:addMember("sniper")
    sq:addMember("heavy")
    local members = sq:getMembers()
    lurek.log.info(tostring("members: " .. table.concat(members, ", ")))
end

--@api: LSquad:setLeader
do
    local sq = lurek.ai.newSquad("foxtrot")
  sq:addMember("unit_1")
  local member_count = sq:getMemberCount()
    sq:addMember("captain")
    sq:addMember("private")
    sq:setLeader("captain")
    lurek.log.info(tostring("leader = " .. sq:getLeader()))
end

--@api: LSquad:getLeader
do
    local sq = lurek.ai.newSquad("golf")
  sq:addMember("unit_1")
  local member_count = sq:getMemberCount()
    sq:addMember("commander")
    sq:setLeader("commander")
    local leader = sq:getLeader()
    lurek.log.info(tostring("leader = " .. tostring(leader)))
end

--@api: LSquad:setFormation
do
  local sq = lurek.ai.newSquad("hotel")
  sq:addMember("unit_1")
  local member_count = sq:getMemberCount()
  sq:addMember("point")
    sq:addMember("left")
    sq:addMember("right")
    sq:setFormation("wedge", 2.0)
    lurek.log.info(tostring("formation set to wedge, spacing 2.0"))
end

--- AI Examples Part 4: Squad (cont.), Command Queue, Trait Profile, Stimulus World, Context Steering, Need System

--@api: LSquad:getFormation
do
    local sq = lurek.ai.newSquad("recon")
  sq:addMember("unit_1")
  local member_count = sq:getMemberCount()
    sq:setFormation("line", 3.0)
    local f = sq:getFormation()
    lurek.log.info(tostring("formation = " .. f))
end

--@api: LSquad:getFormationSpacing
do
    local sq = lurek.ai.newSquad("assault")
  sq:addMember("unit_1")
  local member_count = sq:getMemberCount()
    sq:setFormation("wedge", 2.5)
    local s = sq:getFormationSpacing()
    lurek.log.info(tostring("spacing = " .. s))
end

--@api: LSquad:getFormationPosition
do
  local sq = lurek.ai.newSquad("patrol")
  sq:addMember("unit_1")
  local member_count = sq:getMemberCount()
  sq:addMember("lead")
  sq:addMember("flank_l")
  sq:addMember("flank_r")
    sq:setFormation("wedge", 2.0)
    local x, y = sq:getFormationPosition(2, 100.0, 50.0)
    lurek.log.info(tostring("member 2 pos = " .. x .. ", " .. y))
end

--@api: LSquad:setMemberProfile
do
  local sq = lurek.ai.newSquad("armor")
  sq:addMember("tank")
  sq:setMemberProfile("tank", { footprintW = 4, footprintH = 3, subgroup = "heavy" })
  local profile = sq:getMemberProfile("tank")
  lurek.log.info(tostring("LSquad:setMemberProfile: width=" .. tostring(profile.footprintW)))
  lurek.log.info(tostring("LSquad:setMemberProfile: subgroup=" .. tostring(profile.subgroup)))
end

--@api: LSquad:getMemberProfile
do
  local sq = lurek.ai.newSquad("profiles")
  sq:addMember("scout")
  local default_profile = sq:getMemberProfile("scout")
  sq:setMemberProfile("scout", { footprintW = 2, footprintH = 1 })
  local updated_profile = sq:getMemberProfile("scout")
  lurek.log.info(tostring("LSquad:getMemberProfile: default=" .. tostring(default_profile.footprintW)))
  lurek.log.info(tostring("LSquad:getMemberProfile: updated=" .. tostring(updated_profile.footprintW)))
end

--@api: LSquad:setFormationBehavior
do
  local sq = lurek.ai.newSquad("behavior")
  sq:addMember("beta_1")
  sq:addMember("alpha_1")
  sq:setFormationBehavior("distance", "column", true)
  local behavior = sq:getFormationBehavior()
  lurek.log.info(tostring("LSquad:setFormationBehavior: sort=" .. tostring(behavior.sortMode)))
  lurek.log.info(tostring("LSquad:setFormationBehavior: fallback=" .. tostring(behavior.fallbackMode)))
end

--@api: LSquad:getFormationBehavior
do
  local sq = lurek.ai.newSquad("behavior_read")
  sq:setFormationBehavior("distance", "keep", false)
  local behavior = sq:getFormationBehavior()
  local preserve = behavior.preserveSubgroups
  lurek.log.info(tostring("LSquad:getFormationBehavior: sort=" .. tostring(behavior.sortMode)))
  lurek.log.info(tostring("LSquad:getFormationBehavior: preserve=" .. tostring(preserve)))
end

--@api: LSquad:getFormationSlots
do
  local sq = lurek.ai.newSquad("slots")
  sq:addMember("tank_1")
  sq:addMember("tank_2")
  sq:addMember("tank_3")
  sq:setFormation("line", 10.0)
  sq:setFormationBehavior("roster", "column", false)
  sq:setMemberProfile("tank_1", { footprintW = 4, footprintH = 4 })
  local slots = sq:getFormationSlots(100.0, 50.0, { laneWidth = 20.0 })
  lurek.log.info(tostring("LSquad:getFormationSlots: count=" .. tostring(#slots)))
  lurek.log.info(tostring("LSquad:getFormationSlots: first=" .. tostring(slots[1] and slots[1].member)))
end

--@api: LSquad:getFormationSummary
do
  local sq = lurek.ai.newSquad("summary")
  sq:addMember("beta_1")
  sq:addMember("alpha_1")
  sq:addMember("beta_2")
  sq:addMember("alpha_2")
  sq:setFormation("line", 8.0)
  sq:setFormationBehavior("distance", "keep", true)
  sq:setMemberProfile("beta_1", { subgroup = "beta" })
  sq:setMemberProfile("beta_2", { subgroup = "beta" })
  sq:setMemberProfile("alpha_1", { subgroup = "alpha" })
  sq:setMemberProfile("alpha_2", { subgroup = "alpha" })
  local summary = sq:getFormationSummary(0.0, 0.0, {
    positions = {
      beta_1 = { x = -40.0, y = 0.0 },
      beta_2 = { x = -30.0, y = 0.0 },
      alpha_1 = { x = 30.0, y = 0.0 },
      alpha_2 = { x = 40.0, y = 0.0 },
    },
  })
  lurek.log.info(tostring("LSquad:getFormationSummary: active=" .. tostring(summary.activeFormation)))
  lurek.log.info(tostring("LSquad:getFormationSummary: slots=" .. tostring(summary.slotCount)))
end

--@api: LSquad:assignFormationMove
do
  local world = lurek.ai.newWorld()
  local sq = lurek.ai.newSquad("summary_apply")
  local alpha = world:addAgent("alpha")
  local beta = world:addAgent("beta")
  alpha:setPosition(0.0, 0.0)
  beta:setPosition(10.0, 0.0)
  sq:addMember("alpha")
  sq:addMember("beta")
  sq:setFormation("line", 10.0)
  local applied = sq:assignFormationMove(world, 100.0, 50.0, {
    mode = "replace",
    priority = 3,
    interruptible = false,
  })
  lurek.log.info(tostring("LSquad:assignFormationMove: assigned=" .. tostring(applied.assignedCount)))
  lurek.log.info(tostring("LSquad:assignFormationMove: first=" .. tostring(applied.slots[1] and applied.slots[1].commandId)))
end

--@api: LSquad:submitFormationPaths
do
  lurek.pathfind.setThreadCount(1)
  lurek.pathfind.clearAsyncPaths()
  local world = lurek.ai.newWorld()
  local nav = lurek.pathfind.newNavGrid(32, 32)
  local sq = lurek.ai.newSquad("summary_paths")
  local alpha = world:addAgent("alpha")
  local beta = world:addAgent("beta")
  alpha:setPosition(0.0, 0.0)
  beta:setPosition(10.0, 0.0)
  sq:addMember("alpha")
  sq:addMember("beta")
  sq:setFormation("line", 10.0)
  local submitted = sq:submitFormationPaths(world, nav, 100.0, 50.0, {
    cellSize = 10.0,
    priority = 2,
  })
  lurek.log.info(tostring("LSquad:submitFormationPaths: request=" .. tostring(submitted.requestId)))
  lurek.log.info(tostring("LSquad:submitFormationPaths: submitted=" .. tostring(submitted.submittedCount)))
end

--@api: LSquad:getBlackboard
do
    local sq = lurek.ai.newSquad("intel")
  sq:addMember("unit_1")
  local member_count = sq:getMemberCount()
    local bb = sq:getBlackboard()
    bb:setNumber("threat_level", 3)
    lurek.log.info(tostring("squad bb threat = " .. bb:getNumber("threat_level")))
end

--@api: LSquad:type
do
    local sq = lurek.ai.newSquad("test")
  sq:addMember("unit_1")
  local member_count = sq:getMemberCount()
    lurek.log.info(tostring("type = " .. sq:type()))
  lurek.log.info(tostring("matches = " .. tostring(sq:typeOf("LSquad"))))
end

--@api: LSquad:typeOf
do
    local sq = lurek.ai.newSquad("test2")
  sq:addMember("unit_1")
  local member_count = sq:getMemberCount()
    local type_name = sq:type()
    lurek.log.info(tostring("is LSquad = " .. tostring(sq:typeOf("LSquad"))))
end

--@api: LCommandQueue:enqueue
do
    local cq = lurek.ai.newCommandQueue()
  cq:enqueue("hold", function() end, { targetX = 0, targetY = 0 })
  local queue_count = cq:getCount()
    cq:enqueue("move", function() lurek.log.info(tostring("  moving")) end, { targetX = 10, targetY = 20 })
    cq:enqueue("attack", function() lurek.log.info(tostring("  attacking")) end)
    lurek.log.info(tostring("queue size = " .. cq:getCount()))
end

--@api: LCommandQueue:pushFront
do
    local cq = lurek.ai.newCommandQueue()
  cq:enqueue("hold", function() end, { targetX = 0, targetY = 0 })
  local queue_count = cq:getCount()
    cq:enqueue("patrol", function() end)
    cq:pushFront("dodge", function() lurek.log.info(tostring("  dodging")) end)
    lurek.log.info(tostring("next type = " .. cq:getCurrentType()))
end

--@api: LCommandQueue:replace
do
    local cq = lurek.ai.newCommandQueue()
  cq:enqueue("hold", function() end, { targetX = 0, targetY = 0 })
  local queue_count = cq:getCount()
    cq:enqueue("idle", function() end)
    cq:enqueue("gather", function() end)
    cq:replace("retreat", function() lurek.log.info(tostring("  retreating")) end)
    lurek.log.info(tostring("after replace count = " .. cq:getCount()))
end

--@api: LCommandQueue:cancelCurrent
do
    local cq = lurek.ai.newCommandQueue()
  cq:enqueue("hold", function() end, { targetX = 0, targetY = 0 })
  local queue_count = cq:getCount()
    cq:enqueue("walk", function() end)
    cq:enqueue("talk", function() end)
    cq:cancelCurrent()
    lurek.log.info(tostring("after cancel, type = " .. tostring(cq:getCurrentType())))
end

--@api: LCommandQueue:clear
do
    local cq = lurek.ai.newCommandQueue()
  cq:enqueue("hold", function() end, { targetX = 0, targetY = 0 })
  local queue_count = cq:getCount()
    cq:enqueue("a", function() end)
    cq:enqueue("b", function() end)
    cq:clear()
    lurek.log.info(tostring("after clear, empty = " .. tostring(cq:isEmpty())))
end

--@api: LCommandQueue:getCount
do
    local cq = lurek.ai.newCommandQueue()
  cq:enqueue("hold", function() end, { targetX = 0, targetY = 0 })
  local queue_count = cq:getCount()
    cq:enqueue("x", function() end)
    cq:enqueue("y", function() end)
    cq:enqueue("z", function() end)
    lurek.log.info(tostring("count = " .. cq:getCount()))
end

--@api: LCommandQueue:isEmpty
do
    local cq = lurek.ai.newCommandQueue()
  cq:enqueue("hold", function() end, { targetX = 0, targetY = 0 })
  local queue_count = cq:getCount()
    lurek.log.info(tostring("empty initially = " .. tostring(cq:isEmpty())))
    cq:enqueue("step", function() end)
    lurek.log.info(tostring("empty after enqueue = " .. tostring(cq:isEmpty())))
end

--@api: LCommandQueue:getCurrentType
do
    local cq = lurek.ai.newCommandQueue()
  cq:enqueue("hold", function() end, { targetX = 0, targetY = 0 })
  local queue_count = cq:getCount()
    cq:enqueue("harvest", function() end)
    lurek.log.info(tostring("current type = " .. tostring(cq:getCurrentType())))
end

--@api: LCommandQueue:getCurrentTarget
do
    local cq = lurek.ai.newCommandQueue()
  cq:enqueue("hold", function() end, { targetX = 0, targetY = 0 })
  local queue_count = cq:getCount()
    cq:enqueue("go", function() end, { targetX = 5, targetY = 10 })
    local tgt = cq:getCurrentTarget()
    lurek.log.info(tostring("target = " .. tostring(tgt)))
end

--@api: LCommandQueue:getCurrent
do
    local cq = lurek.ai.newCommandQueue()
    local order_id = cq:enqueue("move", function() end, { targetX = 6, targetY = 9, priority = 3, interruptible = false })
    local current = cq:getCurrent()
    local queue_count = cq:getCount()
    lurek.log.info(tostring("LCommandQueue:getCurrent: id=" .. tostring(order_id)))
    lurek.log.info(tostring("LCommandQueue:getCurrent: kind=" .. tostring(current and current.kind)))
end

--@api: LCommandQueue:getPending
do
    local cq = lurek.ai.newCommandQueue()
    cq:enqueue("move", function() end)
    cq:enqueue("guard", function() end)
    local pending = cq:getPending()
    local queue_count = cq:getCount()
    lurek.log.info(tostring("LCommandQueue:getPending: count=" .. tostring(#pending)))
    lurek.log.info(tostring("LCommandQueue:getPending: second=" .. tostring(pending[2] and pending[2].kind)))
end

--@api: LCommandQueue:completeCurrent
do
    local cq = lurek.ai.newCommandQueue()
    local first_id = cq:enqueue("move", function() end)
    cq:enqueue("guard", function() end)
    local completed = cq:completeCurrent("arrived")
    local current = cq:getCurrent()
    lurek.log.info(tostring("LCommandQueue:completeCurrent: id=" .. tostring(completed)))
    lurek.log.info(tostring("LCommandQueue:completeCurrent: next=" .. tostring(current and current.kind)))
end

--@api: LCommandQueue:failCurrent
do
    local cq = lurek.ai.newCommandQueue()
    cq:enqueue("move", function() end)
    local failed = cq:failCurrent("blocked")
    local events = cq:drainEvents()
    local queue_count = cq:getCount()
    lurek.log.info(tostring("LCommandQueue:failCurrent: failed=" .. tostring(failed)))
    lurek.log.info(tostring("LCommandQueue:failCurrent: last_event=" .. tostring(events[#events] and events[#events].event)))
end

--@api: LCommandQueue:drainEvents
do
    local cq = lurek.ai.newCommandQueue()
    cq:enqueue("move", function() end, { targetX = 1, targetY = 2 })
    cq:completeCurrent("arrived")
    local events = cq:drainEvents()
    local drained_again = cq:drainEvents()
    lurek.log.info(tostring("LCommandQueue:drainEvents: count=" .. tostring(#events)))
    lurek.log.info(tostring("LCommandQueue:drainEvents: empty_after=" .. tostring(#drained_again)))
end

--@api: LCommandQueue:type
do
    local cq = lurek.ai.newCommandQueue()
  cq:enqueue("hold", function() end, { targetX = 0, targetY = 0 })
  local queue_count = cq:getCount()
    lurek.log.info(tostring("type = " .. cq:type()))
  lurek.log.info(tostring("matches = " .. tostring(cq:typeOf("LCommandQueue"))))
end

--@api: LCommandQueue:typeOf
do
    local cq = lurek.ai.newCommandQueue()
  cq:enqueue("hold", function() end, { targetX = 0, targetY = 0 })
  local queue_count = cq:getCount()
    local type_name = cq:type()
    lurek.log.info(tostring("is LCommandQueue = " .. tostring(cq:typeOf("LCommandQueue"))))
end

--@api: LTraitProfile:set
do
    local tp = lurek.ai.newTraitProfile()
  tp:set("morale", 0.5)
  local morale = tp:get("morale")
    tp:set("courage", 0.7)
    tp:set("aggression", 0.3)
    lurek.log.info(tostring("courage = " .. tp:get("courage")))
end

--@api: LTraitProfile:get
do
    local tp = lurek.ai.newTraitProfile()
  tp:set("morale", 0.5)
  local morale = tp:get("morale")
    tp:set("speed", 1.0)
    tp:addModifier("speed", 0.5, 5.0, "buff")
    local effective = tp:get("speed")
    lurek.log.info(tostring("effective speed = " .. effective))
end

--@api: LTraitProfile:getBase
do
    local tp = lurek.ai.newTraitProfile()
  tp:set("morale", 0.5)
  local morale = tp:get("morale")
    tp:set("strength", 0.8)
    tp:addModifier("strength", 0.2, 10.0, "potion")
    lurek.log.info(tostring("base strength = " .. tp:getBase("strength")))
end

--@api: LTraitProfile:addModifier
do
    local tp = lurek.ai.newTraitProfile()
  tp:set("morale", 0.5)
  local morale = tp:get("morale")
    tp:set("defense", 0.5)
    tp:addModifier("defense", 0.3, 8.0, "shield_spell")
    lurek.log.info(tostring("defense with modifier = " .. tp:get("defense")))
end

--@api: LTraitProfile:removeModifiers
do
  local tp = lurek.ai.newTraitProfile()
  tp:set("morale", 0.5)
  local morale = tp:get("morale")
  tp:set("luck", 0.4)
    tp:addModifier("luck", 0.2, 10.0, "charm")
    tp:addModifier("luck", 0.1, 5.0, "charm")
    tp:removeModifiers("charm")
    lurek.log.info(tostring("luck after remove = " .. tp:get("luck")))
end

--@api: LTraitProfile:update
do
    local tp = lurek.ai.newTraitProfile()
  tp:set("morale", 0.5)
  local morale = tp:get("morale")
    tp:set("rage", 0.5)
    tp:addModifier("rage", 0.5, 2.0, "berserk")
    tp:update(3.0)
    lurek.log.info(tostring("rage after 3s = " .. tp:get("rage")))
end

--@api: LTraitProfile:has
do
    local tp = lurek.ai.newTraitProfile()
  tp:set("morale", 0.5)
  local morale = tp:get("morale")
    tp:set("wisdom", 0.6)
    lurek.log.info(tostring("has wisdom = " .. tostring(tp:has("wisdom"))))
    lurek.log.info(tostring("has charm = " .. tostring(tp:has("charm"))))
end

--@api: LTraitProfile:names
do
  local tp = lurek.ai.newTraitProfile()
  tp:set("aggression", 0.7)
  tp:set("caution", 0.2)
  local names = tp:names()
  local count = #names
  lurek.log.info(tostring("LTraitProfile:names: count=" .. tostring(count)))
end

--@api: LTraitProfile:scoreDecision
do
  local tp = lurek.ai.newTraitProfile()
  local bias = lurek.ai.newDecisionBiasSet()
  tp:set("aggression", 0.8)
  bias:addRule("aggression", "attack", 0.2, "add")
  local score = tp:scoreDecision(bias, "attack", 0.5)
  lurek.log.info(tostring("LTraitProfile:scoreDecision: " .. tostring(score)))
end

--@api: LTraitProfile:traitCount
do
    local tp = lurek.ai.newTraitProfile()
  tp:set("morale", 0.5)
  local morale = tp:get("morale")
    tp:set("a", 0.1)
    tp:set("b", 0.2)
    tp:set("c", 0.3)
    lurek.log.info(tostring("trait count = " .. tp:traitCount()))
end

--@api: LTraitProfile:archetype
do
  local tp = lurek.ai.newTraitProfile()
  tp:set("morale", 0.5)
  local morale = tp:get("morale")
  tp:set("aggression", 0.9)
    tp:set("caution", 0.1)
    tp:set("curiosity", 0.4)
    local arch = tp:archetype() or "unknown"
    lurek.log.info(tostring("archetype = " .. arch))
end

--@api: LTraitProfile:type
do
    local tp = lurek.ai.newTraitProfile()
  tp:set("morale", 0.5)
  local morale = tp:get("morale")
    lurek.log.info(tostring("type = " .. tp:type()))
  lurek.log.info(tostring("matches = " .. tostring(tp:typeOf("LTraitProfile"))))
end

--@api: LTraitProfile:typeOf
do
    local tp = lurek.ai.newTraitProfile()
  tp:set("morale", 0.5)
  local morale = tp:get("morale")
    local type_name = tp:type()
    lurek.log.info(tostring("is LTraitProfile = " .. tostring(tp:typeOf("LTraitProfile"))))
end

--@api: LTraitArchetypes:register
do
  local archetypes = lurek.ai.newTraitArchetypes()
  archetypes:register("naval_raider", { aggression = 0.8, naval_focus = 1.0 })
  local profile = archetypes:createProfile("naval_raider")
  local focus = profile:get("naval_focus")
  local count = archetypes:count()
  lurek.log.info(tostring("LTraitArchetypes:register: focus=" .. tostring(focus) .. " count=" .. tostring(count)))
end

--@api: LTraitArchetypes:createProfile
do
  local archetypes = lurek.ai.newTraitArchetypes()
  local profile = archetypes:createProfile("aggressive")
  local aggression = profile:get("aggression")
  local archetype_name = profile:archetype() or "none"
  lurek.log.info(tostring("LTraitArchetypes:createProfile: " .. archetype_name .. " aggression=" .. tostring(aggression)))
end

--@api: LTraitArchetypes:names
do
  local archetypes = lurek.ai.newTraitArchetypes()
  local names = archetypes:names()
  local count = #names
  local first = names[1] or "none"
  lurek.log.info(tostring("LTraitArchetypes:names: count=" .. tostring(count) .. " first=" .. tostring(first)))
end

--@api: LTraitArchetypes:count
do
  local archetypes = lurek.ai.newTraitArchetypes()
  local before = archetypes:count()
  archetypes:register("turtle", { defensiveness = 0.9, caution = 0.8 })
  local after = archetypes:count()
  lurek.log.info(tostring("LTraitArchetypes:count: before=" .. tostring(before) .. " after=" .. tostring(after)))
end

--@api: LTraitArchetypes:type
do
  local archetypes = lurek.ai.newTraitArchetypes()
  local count = archetypes:count()
  local type_name = archetypes:type()
  local is_match = archetypes:typeOf("LTraitArchetypes")
  lurek.log.info(tostring("LTraitArchetypes:type: " .. type_name .. " match=" .. tostring(is_match)))
end

--@api: LTraitArchetypes:typeOf
do
  local archetypes = lurek.ai.newTraitArchetypes()
  local count = archetypes:count()
  local is_arch = archetypes:typeOf("LTraitArchetypes")
  local is_object = archetypes:typeOf("LObject")
  lurek.log.info(tostring("LTraitArchetypes:typeOf: arch=" .. tostring(is_arch) .. " object=" .. tostring(is_object)))
end

--@api: LDecisionBiasSet:addRule
do
  local bias = lurek.ai.newDecisionBiasSet()
  bias:addRule("aggression", "attack", 0.2, "add")
  bias:addRule("caution", "retreat", 0.3, "multiply")
  local count = bias:ruleCount()
  lurek.log.info(tostring("LDecisionBiasSet:addRule: count=" .. tostring(count)))
end

--@api: LDecisionBiasSet:score
do
  local profile = lurek.ai.newTraitProfile()
  local bias = lurek.ai.newDecisionBiasSet()
  profile:set("aggression", 0.8)
  bias:addRule("aggression", "attack", 0.2, "add")
  local score = bias:score(profile, "attack", 0.5)
  lurek.log.info(tostring("LDecisionBiasSet:score: " .. tostring(score)))
end

--@api: LDecisionBiasSet:ruleCount
do
  local bias = lurek.ai.newDecisionBiasSet()
  bias:addRule("aggression", "attack", 0.2)
  bias:addRule("defensiveness", "defend", 0.3)
  local count = bias:ruleCount()
  lurek.log.info(tostring("LDecisionBiasSet:ruleCount: " .. tostring(count)))
end

--@api: LDecisionBiasSet:type
do
  local bias = lurek.ai.newDecisionBiasSet()
  bias:addRule("aggression", "attack", 0.2)
  local count = bias:ruleCount()
  local type_name = bias:type()
  lurek.log.info(tostring("LDecisionBiasSet:type: " .. type_name .. " count=" .. tostring(count)))
end

--@api: LDecisionBiasSet:typeOf
do
  local bias = lurek.ai.newDecisionBiasSet()
  bias:addRule("aggression", "attack", 0.2)
  local is_bias = bias:typeOf("LDecisionBiasSet")
  local is_object = bias:typeOf("LObject")
  lurek.log.info(tostring("LDecisionBiasSet:typeOf: bias=" .. tostring(is_bias) .. " object=" .. tostring(is_object)))
end

--@api: LStimulusWorld:addVisual
do
    local sw = lurek.ai.newStimulusWorld()
  local stimulus_id = sw:addVisual(0, 0, 0.5, 8.0, "ping")
  local stimulus_count = sw:count()
    local id = sw:addVisual(100, 200, 0.8, 50.0, "enemy_spotted")
    lurek.log.info(tostring("visual stimulus id = " .. id))
end

--@api: LStimulusWorld:addAuditory
do
    local sw = lurek.ai.newStimulusWorld()
  local stimulus_id = sw:addVisual(0, 0, 0.5, 8.0, "ping")
  local stimulus_count = sw:count()
    local id = sw:addAuditory(50, 80, 0.6, 30.0, 0.1, "footstep")
    lurek.log.info(tostring("auditory stimulus id = " .. id))
end

--@api: LStimulusWorld:remove
do
    local sw = lurek.ai.newStimulusWorld()
  local stimulus_id = sw:addVisual(0, 0, 0.5, 8.0, "ping")
  local stimulus_count = sw:count()
    local id = sw:addVisual(10, 10, 1.0, 20.0, "flash")
    sw:remove(id)
    lurek.log.info(tostring("removed stimulus, count = " .. sw:count()))
end

--@api: LStimulusWorld:update
do
    local sw = lurek.ai.newStimulusWorld()
  local stimulus_id = sw:addVisual(0, 0, 0.5, 8.0, "ping")
  local stimulus_count = sw:count()
    sw:addAuditory(0, 0, 1.0, 10.0, 0.5, "bang")
    sw:update(5.0)
    lurek.log.info(tostring("after update, count = " .. sw:count()))
end

--@api: LStimulusWorld:count
do
    local sw = lurek.ai.newStimulusWorld()
  local stimulus_id = sw:addVisual(0, 0, 0.5, 8.0, "ping")
  local stimulus_count = sw:count()
    sw:addVisual(0, 0, 1.0, 10.0, "a")
    sw:addVisual(5, 5, 0.5, 8.0, "b")
    lurek.log.info(tostring("stimulus count = " .. sw:count()))
end

--@api: LStimulusWorld:clear
do
    local sw = lurek.ai.newStimulusWorld()
  local stimulus_id = sw:addVisual(0, 0, 0.5, 8.0, "ping")
  local stimulus_count = sw:count()
    sw:addVisual(0, 0, 1.0, 10.0, "x")
    sw:addAuditory(1, 1, 0.5, 5.0, 0.2, "y")
    sw:clear()
    lurek.log.info(tostring("after clear, count = " .. sw:count()))
end

--@api: LStimulusWorld:type
do
    local sw = lurek.ai.newStimulusWorld()
  local stimulus_id = sw:addVisual(0, 0, 0.5, 8.0, "ping")
  local stimulus_count = sw:count()
    lurek.log.info(tostring("type = " .. sw:type()))
  lurek.log.info(tostring("matches = " .. tostring(sw:typeOf("LStimulusWorld"))))
end

--@api: LStimulusWorld:typeOf
do
    local sw = lurek.ai.newStimulusWorld()
  local stimulus_id = sw:addVisual(0, 0, 0.5, 8.0, "ping")
  local stimulus_count = sw:count()
    local type_name = sw:type()
    lurek.log.info(tostring("is LStimulusWorld = " .. tostring(sw:typeOf("LStimulusWorld"))))
end

--@api: LNeedSystem:addNeed
do
    local ns = lurek.ai.newNeedSystem()
  ns:addNeed("rest", 0.1, 0.5, 1.0)
  local urgent_need = ns:mostUrgent()
    ns:addNeed("hunger", 0.1, 0.7, 2.0)
    ns:addNeed("thirst", 0.15, 0.6, 1.5)
    lurek.log.info(tostring("needs registered"))
end

--@api: LNeedSystem:update
do
    local ns = lurek.ai.newNeedSystem()
  ns:addNeed("rest", 0.1, 0.5, 1.0)
  local urgent_need = ns:mostUrgent()
    ns:addNeed("fatigue", 0.05, 0.8, 1.0)
    ns:update(2.0)
    local urgent = ns:mostUrgent()
    lurek.log.info(tostring("most urgent after 2s = " .. tostring(urgent)))
end

--@api: LNeedSystem:mostUrgent
do
    local ns = lurek.ai.newNeedSystem()
  ns:addNeed("rest", 0.1, 0.5, 1.0)
  local urgent_need = ns:mostUrgent()
    ns:addNeed("hunger", 0.5, 0.3, 2.0)
    ns:update(1.0)
    local name = ns:mostUrgent()
    lurek.log.info(tostring("most urgent = " .. tostring(name)))
end

--@api: LNeedSystem:satisfy
do
    local ns = lurek.ai.newNeedSystem()
  ns:addNeed("rest", 0.1, 0.5, 1.0)
  local urgent_need = ns:mostUrgent()
    ns:addNeed("thirst", 0.2, 0.5, 1.5)
    ns:update(3.0)
    ns:satisfy("thirst", 0.8)
    lurek.log.info(tostring("thirst satisfied"))
end

--- AI Examples Part 5: Need System (cont.), AI Director, HTN, MCTS, Emotion, ORCA, Neural Net, Genetic Algorithm

--@api: LNeedSystem:valueOf
do
    local ns = lurek.ai.newNeedSystem()
  ns:addNeed("rest", 0.1, 0.5, 1.0)
  local urgent_need = ns:mostUrgent()
    ns:addNeed("hunger", 0.1, 0.7, 2.0)
    ns:update(2.0)
    local val = ns:valueOf("hunger")
    lurek.log.info(tostring("hunger value = " .. val))
end

--@api: LNeedSystem:type
do
    local ns = lurek.ai.newNeedSystem()
  ns:addNeed("rest", 0.1, 0.5, 1.0)
  local urgent_need = ns:mostUrgent()
    lurek.log.info(tostring("type = " .. ns:type()))
  lurek.log.info(tostring("matches = " .. tostring(ns:typeOf("LNeedSystem"))))
end

--@api: LNeedSystem:typeOf
do
    local ns = lurek.ai.newNeedSystem()
  ns:addNeed("rest", 0.1, 0.5, 1.0)
  local urgent_need = ns:mostUrgent()
    local type_name = ns:type()
    lurek.log.info(tostring("is LNeedSystem = " .. tostring(ns:typeOf("LNeedSystem"))))
end

--@api: LAIDirector:pushEvent
do
    local dir = lurek.ai.newAIDirector()
  dir:pushEvent(0.1)
  local current_phase = dir:phase()
    dir:pushEvent(0.5)
    dir:pushEvent(0.8)
    lurek.log.info(tostring("events pushed, tension = " .. dir:tension()))
end

--@api: LAIDirector:update
do
    local dir = lurek.ai.newAIDirector()
  dir:pushEvent(0.1)
  local current_phase = dir:phase()
    dir:pushEvent(1.0)
    dir:update(2.0)
    lurek.log.info(tostring("phase after update = " .. dir:phase()))
end

--@api: LAIDirector:tension
do
    local dir = lurek.ai.newAIDirector()
  dir:pushEvent(0.1)
  local current_phase = dir:phase()
    dir:setTension(0.6)
    lurek.log.info(tostring("tension = " .. dir:tension()))
end

--@api: LAIDirector:phase
do
    local dir = lurek.ai.newAIDirector()
  dir:pushEvent(0.1)
  local current_phase = dir:phase()
    local p = dir:phase()
    lurek.log.info(tostring("initial phase = " .. p))
end

--@api: LAIDirector:spawnRateFactor
do
    local dir = lurek.ai.newAIDirector()
  dir:pushEvent(0.1)
  local current_phase = dir:phase()
    dir:setTension(0.9)
    dir:update(0.1)
    lurek.log.info(tostring("spawn rate factor = " .. dir:spawnRateFactor()))
end

--@api: LAIDirector:lootFactor
do
    local dir = lurek.ai.newAIDirector()
  dir:pushEvent(0.1)
  local current_phase = dir:phase()
    dir:setTension(0.2)
    dir:update(0.1)
    lurek.log.info(tostring("loot factor = " .. dir:lootFactor()))
end

--@api: LAIDirector:ambientIntensity
do
    local dir = lurek.ai.newAIDirector()
  dir:pushEvent(0.1)
  local current_phase = dir:phase()
    dir:setTension(0.7)
    dir:update(0.1)
    lurek.log.info(tostring("ambient intensity = " .. dir:ambientIntensity()))
end

--@api: LAIDirector:setTension
do
    local dir = lurek.ai.newAIDirector()
  dir:pushEvent(0.1)
  local current_phase = dir:phase()
    dir:setTension(0.5)
    lurek.log.info(tostring("tension set to " .. dir:tension()))
end

--@api: LAIDirector:reset
do
    local dir = lurek.ai.newAIDirector()
  dir:pushEvent(0.1)
  local current_phase = dir:phase()
    dir:setTension(0.9)
    dir:reset()
    lurek.log.info(tostring("after reset, tension = " .. dir:tension()))
end

--@api: LAIDirector:type
do
    local dir = lurek.ai.newAIDirector()
  dir:pushEvent(0.1)
  local current_phase = dir:phase()
    lurek.log.info(tostring("type = " .. dir:type()))
  lurek.log.info(tostring("matches = " .. tostring(dir:typeOf("LAIDirector"))))
end

--@api: LAIDirector:typeOf
do
    local dir = lurek.ai.newAIDirector()
  dir:pushEvent(0.1)
  local current_phase = dir:phase()
    local type_name = dir:type()
    lurek.log.info(tostring("is LAIDirector = " .. tostring(dir:typeOf("LAIDirector"))))
end

--@api: LHTNDomain:addPrimitive
do
    local htn = lurek.ai.newHTNDomain()
  local domain_type = htn:type()
  local task_count = htn:taskCount()
    htn:addPrimitive("chop", { "has_axe" }, { "has_wood" }, {})
    htn:addPrimitive("build", { "has_wood" }, { "shelter_done" }, { "has_wood" })
    lurek.log.info(tostring("primitives = " .. htn:taskCount()))
end

--@api: LHTNDomain:addCompound
do
    local htn = lurek.ai.newHTNDomain()
  local domain_type = htn:type()
  local task_count = htn:taskCount()
    htn:addPrimitive("mine", {}, { "has_ore" }, {})
    htn:addPrimitive("smelt", { "has_ore" }, { "has_metal" }, { "has_ore" })
  htn:addCompound("get_metal", { { name = "mine_and_smelt", preconditions = {}, sub_tasks = { "mine", "smelt" } } })
  lurek.log.info(tostring("compound added, tasks = " .. htn:taskCount()))
end

--@api: LHTNDomain:plan
do
    local htn = lurek.ai.newHTNDomain()
  local domain_type = htn:type()
  local task_count = htn:taskCount()
    htn:addPrimitive("gather", {}, { "has_food" }, {})
    htn:addPrimitive("cook", { "has_food" }, { "meal_ready" }, { "has_food" })
  htn:addCompound("prepare_meal", { { name = "full_cook", preconditions = {}, sub_tasks = { "gather", "cook" } } })
  local plan = htn:plan("prepare_meal", { has_food = 0, meal_ready = 0 })
  if plan then
    lurek.log.info(tostring("plan size = " .. #plan))
    lurek.log.info(tostring("plan = " .. table.concat(plan, " -> ")))
  end
end

--@api: LHTNDomain:taskCount
do
    local htn = lurek.ai.newHTNDomain()
  local domain_type = htn:type()
  local task_count = htn:taskCount()
    htn:addPrimitive("a", {}, {}, {})
    htn:addPrimitive("b", {}, {}, {})
    lurek.log.info(tostring("task count = " .. htn:taskCount()))
end

--@api: LHTNDomain:type
do
    local htn = lurek.ai.newHTNDomain()
  local domain_type = htn:type()
  local task_count = htn:taskCount()
    lurek.log.info(tostring("type = " .. htn:type()))
  lurek.log.info(tostring("matches = " .. tostring(htn:typeOf("LHTNDomain"))))
end

--@api: LHTNDomain:typeOf
do
    local htn = lurek.ai.newHTNDomain()
  local domain_type = htn:type()
  local task_count = htn:taskCount()
    local type_name = htn:type()
    lurek.log.info(tostring("is LHTNDomain = " .. tostring(htn:typeOf("LHTNDomain"))))
end

--@api: LMCTSEngine:search
do
    local mcts = lurek.ai.newMCTSEngine(100, 1.4, 10, 42)
  local action = mcts:search(
    1,
    function(state) return { 1, 2, 3 } end,
    function(state, act) return state + act end,
    function(state) return -math.abs(state - 5) end
  )
  lurek.log.info(tostring("best action = " .. tostring(action)))
end

--@api: LMCTSEngine:type
do
    local mcts = lurek.ai.newMCTSEngine(50, 1.0, 5, 0)
    local simulations = 50
    local exploration = 1.0
    lurek.log.info(tostring("type = " .. mcts:type()))
  lurek.log.info(tostring("matches = " .. tostring(mcts:typeOf("LMCTSEngine"))))
end

--@api: LMCTSEngine:typeOf
do
    local mcts = lurek.ai.newMCTSEngine(50, 1.0, 5, 0)
    local simulations = 50
    local exploration = 1.0
    local type_name = mcts:type()
    lurek.log.info(tostring("is LMCTSEngine = " .. tostring(mcts:typeOf("LMCTSEngine"))))
end

--@api: LEmotionModel:add
do
    local em = lurek.ai.newEmotionModel()
    em:add("joy", 0.3, 0.1, 0.2)
    em:add("anger", 0.0, 0.05, 0.3)
    local joy = em:get("joy")
    local anger = em:get("anger")
    lurek.log.info(tostring("emotions registered"))
end

--@api: LEmotionModel:trigger
do
    local em = lurek.ai.newEmotionModel()
    em:add("fear", 0.0, 0.1, 0.2)
    em:trigger("fear", 0.7)
    local dominant = em:dominant()
    local active = em:isActive("fear")
    lurek.log.info(tostring("fear = " .. em:get("fear")))
end

--@api: LEmotionModel:get
do
    local em = lurek.ai.newEmotionModel()
    em:add("sadness", 0.2, 0.05, 0.1)
    em:trigger("sadness", 0.5)
    local val = em:get("sadness")
    lurek.log.info(tostring("sadness = " .. val))
end

--@api: LEmotionModel:dominant
do
  local em = lurek.ai.newEmotionModel()
  em:add("joy", 0.0, 0.1, 0.1)
    em:add("anger", 0.0, 0.1, 0.1)
    em:trigger("joy", 0.3)
    em:trigger("anger", 0.8)
    lurek.log.info(tostring("dominant = " .. tostring(em:dominant())))
end

--@api: LEmotionModel:isActive
do
  local em = lurek.ai.newEmotionModel()
  em:add("surprise", 0.0, 0.1, 0.5)
    em:trigger("surprise", 0.2)
    lurek.log.info(tostring("surprise active = " .. tostring(em:isActive("surprise"))))
    em:trigger("surprise", 0.5)
    lurek.log.info(tostring("surprise active = " .. tostring(em:isActive("surprise"))))
end

--@api: LEmotionModel:update
do
    local em = lurek.ai.newEmotionModel()
    em:add("excitement", 0.0, 0.2, 0.1)
    em:trigger("excitement", 1.0)
    em:update(3.0)
    lurek.log.info(tostring("excitement after 3s = " .. em:get("excitement")))
end

--@api: LEmotionModel:reset
do
    local em = lurek.ai.newEmotionModel()
    em:add("rage", 0.0, 0.1, 0.2)
    em:trigger("rage", 1.0)
    em:reset()
    lurek.log.info(tostring("rage after reset = " .. em:get("rage")))
end

--@api: LEmotionModel:type
do
    local em = lurek.ai.newEmotionModel()
    em:add("joy", 0.1, 0.1, 0.1)
    local dominant = em:dominant()
    lurek.log.info(tostring("type = " .. em:type()))
  lurek.log.info(tostring("matches = " .. tostring(em:typeOf("LEmotionModel"))))
end

--@api: LEmotionModel:typeOf
do
    local em = lurek.ai.newEmotionModel()
    em:add("joy", 0.1, 0.1, 0.1)
    local type_name = em:type()
    local dominant = em:dominant()
    lurek.log.info(tostring("is LEmotionModel = " .. tostring(em:typeOf("LEmotionModel"))))
end

--@api: LStrategyAI:addGoal
do
    local strat = lurek.ai.newStrategyAI(5.0)
    strat:addGoal("expand")
    strat:addGoal("defend")
    strat:addGoal("research")
    lurek.log.info(tostring("goals registered"))
end

--@api: LStrategyAI:addTag
do
    local strat = lurek.ai.newStrategyAI(3.0)
    strat:addTag("war_declared")
    strat:addTag("low_resources")
    strat:addGoal("expand")
    local next_eval = strat:timeUntilNext()
    lurek.log.info(tostring("tags added"))
end

--@api: LStrategyAI:removeTag
do
    local strat = lurek.ai.newStrategyAI(3.0)
    strat:addTag("peace")
    strat:removeTag("peace")
    strat:addGoal("defend")
    local next_eval = strat:timeUntilNext()
    lurek.log.info(tostring("tag removed"))
end

--@api: LStrategyAI:update
do
    local strat = lurek.ai.newStrategyAI(1.0)
    strat:addGoal("attack")
    strat:addGoal("retreat")
    strat:update(1.5, function(goal) if goal == "attack" then return 0.8 end return 0.2 end)
    lurek.log.info(tostring("active = " .. tostring(strat:activeGoal())))
end

--@api: LStrategyAI:forceEvaluate
do
    local strat = lurek.ai.newStrategyAI(10.0)
    strat:addGoal("build")
    strat:addGoal("scout")
    strat:forceEvaluate(function(goal) if goal == "scout" then return 5.0 end return 1.0 end)
    lurek.log.info(tostring("forced active = " .. tostring(strat:activeGoal())))
end

--@api: LStrategyAI:activeGoal
do
    local strat = lurek.ai.newStrategyAI(1.0)
    strat:addGoal("idle")
    strat:addTag("waiting")
    local until_next = strat:timeUntilNext()
    local active = strat:activeGoal()
    lurek.log.info(tostring("active goal = " .. tostring(active)))
end

--@api: LStrategyAI:timeUntilNext
do
    local strat = lurek.ai.newStrategyAI(5.0)
    strat:addGoal("wait")
    strat:update(2.0, function() return 1.0 end)
    strat:addTag("timer")
    local active = strat:activeGoal()
    lurek.log.info(tostring("time until next = " .. strat:timeUntilNext()))
end

--@api: LStrategyAI:type
do
    local strat = lurek.ai.newStrategyAI(1.0)
    strat:addGoal("idle")
    local active = strat:activeGoal()
    lurek.log.info(tostring("type = " .. strat:type()))
  lurek.log.info(tostring("matches = " .. tostring(strat:typeOf("LStrategyAI"))))
end

--@api: LStrategyAI:typeOf
do
    local strat = lurek.ai.newStrategyAI(1.0)
    strat:addGoal("idle")
    local until_next = strat:timeUntilNext()
    local type_name = strat:type()
    lurek.log.info(tostring("is LStrategyAI = " .. tostring(strat:typeOf("LStrategyAI"))))
end

--@api: LAILod:tierFor
do
    local lod = lurek.ai.newAILod()
  local tier_name = lod:tierName(0)
  local tier_index = lod:tierFor(0, 0, 0, 0)
    local tier = lod:tierFor(100, 200, 0, 0)
    lurek.log.info(tostring("tier = " .. tier))
end

--@api: LAILod:shouldUpdate
do
    local lod = lurek.ai.newAILod()
  local tier_name = lod:tierName(0)
  local tier_index = lod:tierFor(0, 0, 0, 0)
    local run = lod:shouldUpdate(0, 1)
    lurek.log.info(tostring("tier 0 should update on frame 1 = " .. tostring(run)))
end

--@api: LAILod:tierCount
do
    local lod = lurek.ai.newAILod()
  local tier_name = lod:tierName(0)
  local tier_index = lod:tierFor(0, 0, 0, 0)
    local type_name = lod:type()
    local is_lod = lod:typeOf("LAILod")
    lurek.log.info(tostring("tier count = " .. lod:tierCount()))
end

--@api: LAILod:tierName
do
    local lod = lurek.ai.newAILod()
  local tier_name = lod:tierName(0)
  local tier_index = lod:tierFor(0, 0, 0, 0)
    local name = lod:tierName(0)
    lurek.log.info(tostring("tier 0 name = " .. name))
end

--@api: LAILod:type
do
    local lod = lurek.ai.newAILod()
  local tier_name = lod:tierName(0)
  local tier_index = lod:tierFor(0, 0, 0, 0)
    lurek.log.info(tostring("type = " .. lod:type()))
  lurek.log.info(tostring("matches = " .. tostring(lod:typeOf("LAILod"))))
end

--@api: LAILod:typeOf
do
    local lod = lurek.ai.newAILod()
  local tier_name = lod:tierName(0)
  local tier_index = lod:tierFor(0, 0, 0, 0)
    local count = lod:tierCount()
    local type_name = lod:type()
    lurek.log.info(tostring("is LAILod = " .. tostring(lod:typeOf("LAILod"))))
end

--@api: LAIWorld:getLastCallbackErrors
do
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("callback_probe")
  agent:setCustomModel(function() error("probe failure") end)
  world:update(1 / 60)
  local errors = world:getLastCallbackErrors()
  lurek.log.info(tostring("LAIWorld:getLastCallbackErrors: count=" .. tostring(#errors)))
end

--@api: LUtilityAI:getLastTrace
do
  local uai = lurek.ai.newUtilityAI()
  uai:addAction("heal", function() return 0.8 end)
  uai:addConsideration("heal", "low_health", function() return 1.0 end, "linear", 1.0, 0.0, 0.0, 1.0)
  uai:evaluate()
  local trace = uai:getLastTrace()
  lurek.log.info(tostring("LUtilityAI:getLastTrace: chosen=" .. tostring(trace.chosen_action)))
end

--@api: LGOAPPlanner:getLastFailureReason
do
  local goap = lurek.ai.newGOAPPlanner()
  goap:setMaxIterations(1)
  goap:addAction("get_axe", 1.0)
  goap:setEffect("get_axe", "has_axe", true)
  goap:addAction("chop", 1.0)
  goap:setPrecondition("chop", "has_axe", true)
  goap:setEffect("chop", "has_wood", true)
  goap:addGoal("house", 1.0)
  goap:setGoalState("house", "has_house", true)
  local plan = goap:plan({ has_axe = false, has_wood = false, has_house = false }, 8)
  lurek.log.info(tostring("LGOAPPlanner:getLastFailureReason: plan_size=" .. tostring(#plan)))
  lurek.log.info(tostring("LGOAPPlanner:getLastFailureReason: failure=" .. tostring(goap:getLastFailureReason())))
end

--@api: LGOAPPlanner:getLastTrace
do
  local goap = lurek.ai.newGOAPPlanner()
  goap:plan({}, 4)
  local trace = goap:getLastTrace()
  lurek.log.info(tostring("LGOAPPlanner:getLastTrace: failure=" .. tostring(trace.failure_reason)))
  lurek.log.info(tostring("LGOAPPlanner:getLastTrace: iterations=" .. tostring(trace.iterations)))
  lurek.log.info(tostring("LGOAPPlanner:getLastTrace: selected_goal=" .. tostring(trace.selected_goal)))
end

--@api: LMCTSEngine:getLastTrace
do
  local mcts = lurek.ai.newMCTSEngine(8, 1.4, 4, 42)
  mcts:search(
    1,
    function(_) return { 7 } end,
    function(state, act) return state + act end,
    function(_) return 0 / 0 end
  )
  local trace = mcts:getLastTrace()
  lurek.log.info(tostring("LMCTSEngine:getLastTrace: invalid_scores=" .. tostring(trace.invalid_score_count)))
end
