-- content/examples/ai.lua
-- Auto-generated from content/examples2/ai_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/ai.lua

local function example_print_log(...)
    local parts = {}
    for i = 1, select("#", ...) do
        parts[i] = tostring(select(i, ...))
    end
    lurek.log.info(table.concat(parts, " "))
end

--@api: lurek.ai.newWorld
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local scout = world:addAgent("scout_preview")
  local count = world:getAgentCount()
  example_print_log("lurek.ai.newWorld: agents=" .. tostring(count))
  example_print_log("lurek.ai.newWorld: first_agent=" .. scout:getName())
end

--@api: lurek.ai.newBlackboard
do
  local bb = lurek.ai.newBlackboard()
  bb:setString("context", "active")
  local bb_size = bb:getSize()
  bb:setString("state", "idle")
  example_print_log("lurek.ai.newBlackboard: state=" .. bb:getString("state", "none"))
end

--@api: lurek.ai.newStateMachine
do
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("idle", {})
  local fsm_type = fsm:type()
  fsm:addState("idle", {})
  fsm:setInitialState("idle")
  example_print_log("lurek.ai.newStateMachine: ok=" .. tostring(fsm ~= nil))
  example_print_log("lurek.ai.newStateMachine: current=" .. tostring(fsm:getCurrentState()))
end

--@api: lurek.ai.newBehaviorTree
do
  local bt = lurek.ai.newBehaviorTree()
  local bt_debug = bt:getDebugState()
  local bt_status = bt:getLastStatus()
  bt:setRoot(lurek.ai.newAction(function() return "success" end))
  local info = bt:getDebugState()
  example_print_log("lurek.ai.newBehaviorTree: status=" .. tostring(bt:getLastStatus()))
  example_print_log("lurek.ai.newBehaviorTree: node_count=" .. tostring(info.node_count))
end

--@api: lurek.ai.newSelector
do
  local sel = lurek.ai.newSelector()
  local node_type = sel:getNodeType()
  local child_count = sel:getChildCount()
  sel:addChild(lurek.ai.newAction(function() return "failure" end))
  sel:addChild(lurek.ai.newAction(function() return "success" end))
  example_print_log("lurek.ai.newSelector: type=" .. sel:getNodeType())
  example_print_log("lurek.ai.newSelector: children=" .. tostring(sel:getChildCount()))
end

--@api: lurek.ai.newSequence
do
  local seq = lurek.ai.newSequence()
  local node_type = seq:getNodeType()
  local child_count = seq:getChildCount()
  seq:addChild(lurek.ai.newCondition(function() return true end))
  seq:addChild(lurek.ai.newAction(function() return "success" end))
  example_print_log("lurek.ai.newSequence: type=" .. seq:getNodeType())
  example_print_log("lurek.ai.newSequence: children=" .. tostring(seq:getChildCount()))
end

--@api: lurek.ai.newParallel
do
  local par = lurek.ai.newParallel("requireAll", "requireOne")
  local node_type = par:getNodeType()
  local child_count = par:getChildCount()
  par:addChild(lurek.ai.newAction(function() return "running" end))
  par:addChild(lurek.ai.newAction(function() return "success" end))
  example_print_log("lurek.ai.newParallel: type=" .. par:getNodeType())
  example_print_log("lurek.ai.newParallel: children=" .. tostring(par:getChildCount()))
end

--@api: lurek.ai.newInverter
do
  local inv = lurek.ai.newInverter()
  local node_type = inv:getNodeType()
  local child_count = inv:getChildCount()
  inv:setChild(lurek.ai.newCondition(function() return false end))
  example_print_log("lurek.ai.newInverter: type=" .. inv:getNodeType())
  example_print_log("lurek.ai.newInverter: child_count=" .. tostring(inv:getChildCount()))
end

--@api: lurek.ai.newRepeater
do
  local rep = lurek.ai.newRepeater(5)
  local node_type = rep:getNodeType()
  local child_count = rep:getChildCount()
  rep:setChild(lurek.ai.newAction(function() return "success" end))
  example_print_log("lurek.ai.newRepeater: count=" .. tostring(rep:getCount()))
  example_print_log("lurek.ai.newRepeater: type=" .. rep:getNodeType())
end

--@api: lurek.ai.newSucceeder
do
  local suc = lurek.ai.newSucceeder()
  local node_type = suc:getNodeType()
  local child_count = suc:getChildCount()
  suc:setChild(lurek.ai.newAction(function() return "failure" end))
  example_print_log("lurek.ai.newSucceeder: type=" .. suc:getNodeType())
  example_print_log("lurek.ai.newSucceeder: child_count=" .. tostring(suc:getChildCount()))
end

--@api: lurek.ai.newAction
do
  local act = lurek.ai.newAction(function() return "success" end)
  local node_type = act:getNodeType()
  local child_count = act:getChildCount()
  act:reset()
  example_print_log("lurek.ai.newAction: type=" .. act:getNodeType())
  example_print_log("lurek.ai.newAction: child_count=" .. tostring(act:getChildCount()))
end

--@api: lurek.ai.newCondition
do
  local cond = lurek.ai.newCondition(function() return true end)
  local node_type = cond:getNodeType()
  local child_count = cond:getChildCount()
  cond:reset()
  example_print_log("lurek.ai.newCondition: type=" .. cond:getNodeType())
  example_print_log("lurek.ai.newCondition: child_count=" .. tostring(cond:getChildCount()))
end

--@api: lurek.ai.newGuard
do
  local child_action = lurek.ai.newAction(function() return "success" end)
  local guard = lurek.ai.newGuard(function() return true end, child_action)
  local node_type = guard:getNodeType()
  local child_count = guard:getChildCount()
  example_print_log("lurek.ai.newGuard: node=" .. guard:getNodeType())
end

--@api: lurek.ai.newSteeringManager
do
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:addSeek(320, 180, 1.0)
  example_print_log("lurek.ai.newSteeringManager: ok=" .. tostring(steer ~= nil))
  example_print_log("lurek.ai.newSteeringManager: behaviors=" .. tostring(steer:getBehaviorCount()))
end

--@api: lurek.ai.newUtilityAI
do
  local util = lurek.ai.newUtilityAI()
  util:addAction("wait", function() return 0.2 end)
  util:addAction("attack", function() return 0.9 end)
  example_print_log("lurek.ai.newUtilityAI: ok=" .. tostring(util ~= nil))
  example_print_log("lurek.ai.newUtilityAI: pick=" .. tostring(util:evaluate()))
end

--@api: lurek.ai.newDialogueAI
do
  local dlg = lurek.ai.newDialogueAI()
  dlg:addTopic("greeting", 0.5, nil, nil, "greet_score")
  dlg:setUtilityScore("greet_score", 0.8)
  example_print_log("lurek.ai.newDialogueAI: ok=" .. tostring(dlg ~= nil))
  example_print_log("lurek.ai.newDialogueAI: topics=" .. tostring(dlg:getTopicCount()))
end

--@api: lurek.ai.newGOAPPlanner
do
  local goap = lurek.ai.newGOAPPlanner()
  goap:addGoal("idle", 1)
  local goal_count = goap:getGoalCount()
  goap:addGoal("stay_alive", 5)
  goap:setGoalState("stay_alive", "alive", true)
  example_print_log("lurek.ai.newGOAPPlanner: ok=" .. tostring(goap ~= nil))
  example_print_log("lurek.ai.newGOAPPlanner: goals=" .. tostring(goap:getGoalCount()))
end

--@api: lurek.ai.newInfluenceMap
do
  local imap = lurek.ai.newInfluenceMap(32, 32, 16)
  imap:addLayer("debug")
  local map_width = imap:getWidth()
  imap:addLayer("danger")
  imap:setInfluence("danger", 4, 5, 0.9)
  example_print_log("lurek.ai.newInfluenceMap: ok=" .. tostring(imap ~= nil))
  example_print_log("lurek.ai.newInfluenceMap: width=" .. tostring(imap:getWidth()))
end

--@api: lurek.ai.newSquad
do
  local squad = lurek.ai.newSquad("bravo")
  squad:addMember("leader")
  squad:setLeader("leader")
  example_print_log("lurek.ai.newSquad: name=" .. squad:getName())
  example_print_log("lurek.ai.newSquad: members=" .. tostring(squad:getMemberCount()))
end

--@api: lurek.ai.newCommandQueue
do
  local cq = lurek.ai.newCommandQueue()
  cq:enqueue("hold", function() end, { targetX = 0, targetY = 0 })
  local queue_count = cq:getCount()
  cq:enqueue("move", function() example_print_log("moving") end, { targetX = 32, targetY = 64 })
  example_print_log("lurek.ai.newCommandQueue: empty=" .. tostring(cq:isEmpty()))
  example_print_log("lurek.ai.newCommandQueue: count=" .. tostring(cq:getCount()))
end

--@api: lurek.ai.newTraitProfile
do
  local traits = lurek.ai.newTraitProfile()
  traits:set("discipline", 0.4)
  traits:set("courage", 0.7)
  example_print_log("lurek.ai.newTraitProfile: ok=" .. tostring(traits ~= nil))
  example_print_log("lurek.ai.newTraitProfile: courage=" .. tostring(traits:get("courage")))
end

--@api: lurek.ai.newStimulusWorld
do
  local sw = lurek.ai.newStimulusWorld()
  local stimulus_id = sw:addVisual(0, 0, 0.5, 8.0, "ping")
  local stimulus_count = sw:count()
  sw:addVisual(100, 150, 1.0, 48.0, "enemy")
  example_print_log("lurek.ai.newStimulusWorld: stimuli=" .. tostring(sw:count()))
  example_print_log("lurek.ai.newStimulusWorld: type=" .. sw:type())
end

--@api: lurek.ai.newContextSteering
do
  local cs = lurek.ai.newContextSteering(8)
  cs:addSeekTarget(0, 0, 1.0)
  local slot_count = cs:slotCount()
  cs:addSeekTarget(256, 128, 1.0)
  local dx, dy = cs:evaluate(0, 0, 1, 0)
  example_print_log("lurek.ai.newContextSteering: ok=" .. tostring(cs ~= nil))
  example_print_log("lurek.ai.newContextSteering: dir=" .. tostring(dx) .. "," .. tostring(dy))
end

--@api: lurek.ai.newNeedSystem
do
  local needs = lurek.ai.newNeedSystem()
  needs:addNeed("hunger", 0.1, 0.7, 2.0)
  needs:update(2.0)
  example_print_log("lurek.ai.newNeedSystem: ok=" .. tostring(needs ~= nil))
  example_print_log("lurek.ai.newNeedSystem: urgent=" .. tostring(needs:mostUrgent()))
end

--@api: lurek.ai.newAIDirector
do
  local dir = lurek.ai.newAIDirector()
  dir:pushEvent(0.1)
  local current_phase = dir:phase()
  dir:pushEvent(0.6)
  dir:update(1.0)
  example_print_log("lurek.ai.newAIDirector: ok=" .. tostring(dir ~= nil))
  example_print_log("lurek.ai.newAIDirector: phase=" .. dir:phase())
end

--@api: lurek.ai.newHTNDomain
do
  local htn = lurek.ai.newHTNDomain()
  local domain_type = htn:type()
  local task_count = htn:taskCount()
  example_print_log("lurek.ai.newHTNDomain: ok=" .. tostring(htn ~= nil))
  example_print_log("lurek.ai.newHTNDomain: tasks=" .. tostring(htn:taskCount()))
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
  example_print_log("lurek.ai.newMCTSEngine: action=" .. tostring(best_action))
end

--@api: lurek.ai.newEmotionModel
do
  local emo = lurek.ai.newEmotionModel()
  emo:add("fear", 0.1, 0.2, 0.3)
  emo:trigger("fear", 0.5)
  example_print_log("lurek.ai.newEmotionModel: ok=" .. tostring(emo ~= nil))
  example_print_log("lurek.ai.newEmotionModel: dominant=" .. tostring(emo:dominant()))
end

--@api: lurek.ai.newORCASolver
do
  local orca = lurek.ai.newORCASolver(1.5)
  orca:addAgent(0, 0, 0.5, 3.0)
  local preview_count = orca:agentCount()
  example_print_log("lurek.ai.newORCASolver: ok=" .. tostring(orca ~= nil))
  example_print_log("lurek.ai.newORCASolver: agents=" .. tostring(orca:agentCount()))
end

--@api: lurek.ai.newStrategyAI
do
  local strat = lurek.ai.newStrategyAI(3.0)
  strat:addGoal("expand")
  strat:addTag("economy")
  example_print_log("lurek.ai.newStrategyAI: ok=" .. tostring(strat ~= nil))
  example_print_log("lurek.ai.newStrategyAI: next_eval=" .. tostring(strat:timeUntilNext()))
end

--@api: lurek.ai.newAILod
do
  local lod = lurek.ai.newAILod()
  local tier_name = lod:tierName(0)
  local tier_index = lod:tierFor(0, 0, 0, 0)
  example_print_log("lurek.ai.newAILod: ok=" .. tostring(lod ~= nil))
  example_print_log("lurek.ai.newAILod: tiers=" .. tostring(lod:tierCount()))
end

--@api: LAIWorld:addAgent
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local archer = world:addAgent("archer_01")
  local count = world:getAgentCount()
  example_print_log("LAIWorld:addAgent: name=" .. archer:getName())
end

--@api: LAIWorld:getAgent
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  world:addAgent("scout_01")
  local found = world:getAgent("scout_01")
  example_print_log("LAIWorld:getAgent: found=" .. tostring(found ~= nil))
end

--@api: LAIWorld:removeAgent
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local temp = world:addAgent("temp_npc")
  world:removeAgent(temp)
  example_print_log("LAIWorld:removeAgent: removed")
end

--@api: LAIWorld:getAgentCount
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  world:addAgent("unit_a")
  world:addAgent("unit_b")
  world:addAgent("unit_c")
  local count = world:getAgentCount()
  example_print_log("LAIWorld:getAgentCount: " .. tostring(count))
end

--@api: LAIWorld:getGlobalBlackboard
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local gb = world:getGlobalBlackboard()
  gb:setString("weather", "rain")
  example_print_log("LAIWorld:getGlobalBlackboard: ok=" .. tostring(gb ~= nil))
  example_print_log("LAIWorld:getGlobalBlackboard: weather=" .. gb:getString("weather", "none"))
end

--@api: LAIWorld:update
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("worker")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  npc:setDecisionModel("custom")
  local ticked = false
  npc:setCustomModel(function(agent, blackboard, dt) ticked = true end)
  world:update(1 / 60)
  example_print_log("LAIWorld:update: ticked=" .. tostring(ticked))
end

--@api: LAIWorld:type
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local t = world:type()
  local ok = world:typeOf("LAIWorld")
  example_print_log("LAIWorld:type: " .. t)
  example_print_log("LAIWorld:type: matches=" .. tostring(ok))
end

--@api: LAIWorld:typeOf
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local is_world = world:typeOf("LAIWorld")
  local is_wrong = world:typeOf("LImage")
  example_print_log("LAIWorld:typeOf: LAIWorld=" .. tostring(is_world) .. " LImage=" .. tostring(is_wrong))
end

--@api: LBot:getName
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("knight_03")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  local name = npc:getName()
  example_print_log("LBot:getName: " .. name)
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
  example_print_log("LBot:setPosition: done")
  example_print_log("LBot:setPosition: pos=" .. tostring(x) .. ", " .. tostring(y))
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
  example_print_log("LBot:getPosition: " .. tostring(x) .. ", " .. tostring(y))
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
  example_print_log("LBot:setVelocity: done")
  example_print_log("LBot:setVelocity: vel=" .. tostring(vx) .. ", " .. tostring(vy))
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
  example_print_log("LBot:getVelocity: vx=" .. tostring(vx) .. " vy=" .. tostring(vy))
end

--@api: LBot:setMaxSpeed
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("sprinter")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  npc:setMaxSpeed(200)
  example_print_log("LBot:setMaxSpeed: done")
  example_print_log("LBot:setMaxSpeed: speed=" .. tostring(npc:getMaxSpeed()))
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
  example_print_log("LBot:getMaxSpeed: " .. tostring(speed))
  example_print_log("LBot:getMaxSpeed: name=" .. npc:getName())
end

--@api: LBot:setMaxForce
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("tank")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  npc:setMaxForce(80)
  example_print_log("LBot:setMaxForce: done")
  example_print_log("LBot:setMaxForce: force=" .. tostring(npc:getMaxForce()))
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
  example_print_log("LBot:getMaxForce: " .. tostring(force))
  example_print_log("LBot:getMaxForce: name=" .. npc:getName())
end

--@api: LBot:setPriority
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("captain")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  npc:setPriority(10)
  example_print_log("LBot:setPriority: " .. tostring(npc:getPriority()))
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
  example_print_log("LBot:getPriority: " .. tostring(prio))
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
  example_print_log("LBot:setDecisionModel: " .. model)
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
  example_print_log("LBot:getDecisionModel: " .. model)
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
  example_print_log("LBot:setCustomModel: dt=" .. tostring(called_with_dt))
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
  example_print_log("LBot:addTag: hostile=" .. tostring(has_hostile))
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
  example_print_log("LBot:removeTag: visible=" .. tostring(still_has))
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
  example_print_log("LBot:hasTag: friendly=" .. tostring(friendly) .. " hostile=" .. tostring(hostile))
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
  example_print_log("LBot:getBlackboard: hp=" .. tostring(hp))
end

--@api: LBot:type
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("villager")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  local t = npc:type()
  example_print_log("LBot:type: " .. t)
  example_print_log("LBot:type: matches=" .. tostring(npc:typeOf("LBot")))
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
  example_print_log("LBot:typeOf: LBot=" .. tostring(is_agent) .. " LImage=" .. tostring(is_image))
end

--@api: LAIBlackboard:setNumber
do
  local bb = lurek.ai.newBlackboard()
  bb:setString("context", "active")
  local bb_size = bb:getSize()
  bb:setNumber("distance", 42.5)
  bb:setNumber("ammo", 30)
  local dist = bb:getNumber("distance", 0)
  example_print_log("LAIBlackboard:setNumber: distance=" .. tostring(dist))
end

--@api: LAIBlackboard:getNumber
do
  local bb = lurek.ai.newBlackboard()
  bb:setString("context", "active")
  local bb_size = bb:getSize()
  bb:setNumber("score", 95.5)
  local score = bb:getNumber("score", 0)
  local missing = bb:getNumber("nonexistent", -1)
  example_print_log("LAIBlackboard:getNumber: score=" .. tostring(score) .. " missing=" .. tostring(missing))
end

--@api: LAIBlackboard:setBool
do
  local bb = lurek.ai.newBlackboard()
  bb:setString("context", "active")
  local bb_size = bb:getSize()
  bb:setBool("can_attack", true)
  bb:setBool("is_hiding", false)
  local attack = bb:getBool("can_attack", false)
  example_print_log("LAIBlackboard:setBool: can_attack=" .. tostring(attack))
end

--@api: LAIBlackboard:getBool
do
  local bb = lurek.ai.newBlackboard()
  bb:setString("context", "active")
  local bb_size = bb:getSize()
  bb:setBool("alert", true)
  local alert = bb:getBool("alert", false)
  local calm = bb:getBool("calm", true)
  example_print_log("LAIBlackboard:getBool: alert=" .. tostring(alert) .. " calm=" .. tostring(calm))
end

--@api: LAIBlackboard:setString
do
  local bb = lurek.ai.newBlackboard()
  bb:setString("context", "active")
  local bb_size = bb:getSize()
  bb:setString("target_name", "dragon")
  bb:setString("current_zone", "forest")
  local target = bb:getString("target_name", "none")
  example_print_log("LAIBlackboard:setString: target=" .. target)
end

--@api: LAIBlackboard:getString
do
  local bb = lurek.ai.newBlackboard()
  bb:setString("context", "active")
  local bb_size = bb:getSize()
  bb:setString("weapon", "sword")
  local weapon = bb:getString("weapon", "fists")
  local shield = bb:getString("shield", "none")
  example_print_log("LAIBlackboard:getString: weapon=" .. weapon .. " shield=" .. shield)
end

--@api: LAIBlackboard:has
do
  local bb = lurek.ai.newBlackboard()
  bb:setString("context", "active")
  local bb_size = bb:getSize()
  bb:setNumber("hp", 80)
  local has_hp = bb:has("hp")
  local has_mp = bb:has("mp")
  example_print_log("LAIBlackboard:has: hp=" .. tostring(has_hp) .. " mp=" .. tostring(has_mp))
end

--@api: LAIBlackboard:remove
do
  local bb = lurek.ai.newBlackboard()
  bb:setString("context", "active")
  local bb_size = bb:getSize()
  bb:setNumber("temp", 99)
  bb:remove("temp")
  local still_has = bb:has("temp")
  example_print_log("LAIBlackboard:remove: has_temp=" .. tostring(still_has))
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
  example_print_log("LAIBlackboard:clear: size=" .. tostring(size))
end

--@api: LAIBlackboard:getKeys
do
  local bb = lurek.ai.newBlackboard()
  bb:setString("context", "active")
  local bb_size = bb:getSize()
  bb:setNumber("hp", 100)
  bb:setString("state", "idle")
  local keys = bb:getKeys()
  example_print_log("LAIBlackboard:getKeys: count=" .. tostring(#keys))
end

--@api: LAIBlackboard:getSize
do
  local bb = lurek.ai.newBlackboard()
  bb:setString("context", "active")
  local bb_size = bb:getSize()
  bb:setNumber("hp", 10)
  bb:setString("name", "test")
  local size = bb:getSize()
  example_print_log("LAIBlackboard:getSize: " .. tostring(size))
end

--@api: LAIBlackboard:type
do
  local bb = lurek.ai.newBlackboard()
  bb:setString("context", "active")
  local bb_size = bb:getSize()
  local t = bb:type()
  example_print_log("LAIBlackboard:type: " .. t)
  example_print_log("LAIBlackboard:type: matches=" .. tostring(bb:typeOf("LAIBlackboard")))
end

--@api: LAIBlackboard:typeOf
do
  local bb = lurek.ai.newBlackboard()
  bb:setString("context", "active")
  local bb_size = bb:getSize()
  local is_bb = bb:typeOf("LAIBlackboard")
  local is_agent = bb:typeOf("LBot")
  example_print_log("LAIBlackboard:typeOf: LAIBlackboard=" .. tostring(is_bb) .. " LBot=" .. tostring(is_agent))
end

--@api: LStateMachine:addState
do
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("idle", {})
  local fsm_type = fsm:type()
  local entered = ""
  fsm:addState("patrol", { onEnter = function() entered = "patrol" end })
  fsm:setInitialState("patrol")
  example_print_log("LStateMachine:addState: entered=" .. entered)
end

--@api: LStateMachine:addTransition
do
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("idle", {})
  local fsm_type = fsm:type()
  fsm:addState("idle", {})
  fsm:addState("alert", {})
  fsm:addTransition("idle", "alert", function() return true end, 1)
  example_print_log("LStateMachine:addTransition: configured")
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
  example_print_log("LStateMachine:setInitialState: " .. current .. " log=" .. log)
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
  example_print_log("LStateMachine:getCurrentState: before=" .. tostring(before) .. " after=" .. tostring(after))
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
  example_print_log("LStateMachine:forceState: " .. current)
end

--@api: LStateMachine:getTimeInState
do
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("idle", {})
  local fsm_type = fsm:type()
  fsm:addState("cooking", {})
  fsm:setInitialState("cooking")
  local time_in = fsm:getTimeInState()
  example_print_log("LStateMachine:getTimeInState: " .. tostring(time_in))
end

--@api: LStateMachine:type
do
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("idle", {})
  local fsm_type = fsm:type()
  local t = fsm:type()
  example_print_log("LStateMachine:type: " .. t)
  example_print_log("LStateMachine:type: matches=" .. tostring(fsm:typeOf("LStateMachine")))
end

--@api: LStateMachine:typeOf
do
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("idle", {})
  local fsm_type = fsm:type()
  local is_fsm = fsm:typeOf("LStateMachine")
  local is_other = fsm:typeOf("LBehaviorTree")
  example_print_log("LStateMachine:typeOf: LStateMachine=" .. tostring(is_fsm) .. " LBehaviorTree=" .. tostring(is_other))
end

--@api: LBehaviorTree:getLastStatus
do
  local bt = lurek.ai.newBehaviorTree()
  local bt_debug = bt:getDebugState()
  local bt_status = bt:getLastStatus()
  bt:setRoot(lurek.ai.newAction(function() return "success" end))
  local status = bt:getLastStatus()
  example_print_log("LBehaviorTree:getLastStatus: " .. status)
end

--@api: LBehaviorTree:getDebugState
do
  local bt = lurek.ai.newBehaviorTree()
  local bt_debug = bt:getDebugState()
  local bt_status = bt:getLastStatus()
  bt:setRoot(lurek.ai.newAction(function() return "success" end))
  local info = bt:getDebugState()
  example_print_log("LBehaviorTree:getDebugState: node_count=" .. tostring(info.node_count))
  example_print_log("LBehaviorTree:getDebugState: last_status=" .. tostring(info.last_status))
end

--@api: LBehaviorTree:type
do
  local bt = lurek.ai.newBehaviorTree()
  local bt_debug = bt:getDebugState()
  local bt_status = bt:getLastStatus()
  local t = bt:type()
  example_print_log("LBehaviorTree:type: " .. t)
  example_print_log("LBehaviorTree:type: matches=" .. tostring(bt:typeOf("LBehaviorTree")))
end

--@api: LBehaviorTree:typeOf
do
  local bt = lurek.ai.newBehaviorTree()
  local bt_debug = bt:getDebugState()
  local bt_status = bt:getLastStatus()
  local is_bt = bt:typeOf("LBehaviorTree")
  local is_other = bt:typeOf("LBot")
  example_print_log("LBehaviorTree:typeOf: LBehaviorTree=" .. tostring(is_bt) .. " LBot=" .. tostring(is_other))
end

--@api: LBTNode:addChild
do
  local seq = lurek.ai.newSequence()
  local node_type = seq:getNodeType()
  local child_count = seq:getChildCount()
  seq:addChild(lurek.ai.newAction(function() return "success" end))
  local count = seq:getChildCount()
  example_print_log("LBTNode:addChild: children=" .. tostring(count))
end

--@api: LBTNode:getChildCount
do
  local sel = lurek.ai.newSelector()
  local node_type = sel:getNodeType()
  local child_count = sel:getChildCount()
  sel:addChild(lurek.ai.newAction(function() return "success" end))
  local count = sel:getChildCount()
  example_print_log("LBTNode:getChildCount: " .. tostring(count))
end

--@api: LBTNode:reset
do
  local seq = lurek.ai.newSequence()
  local node_type = seq:getNodeType()
  local child_count = seq:getChildCount()
  seq:addChild(lurek.ai.newAction(function() return "running" end))
  seq:reset()
  example_print_log("LBTNode:reset: done")
end

--@api: LBTNode:setChild
do
  local inv = lurek.ai.newInverter()
  local node_type = inv:getNodeType()
  local child_count = inv:getChildCount()
  inv:setChild(lurek.ai.newAction(function() return "failure" end))
  example_print_log("LBTNode:setChild: configured")
  example_print_log("LBTNode:setChild: type=" .. inv:getNodeType())
end

--@api: LBTNode:setCount
do
  local rep = lurek.ai.newRepeater(3)
  local node_type = rep:getNodeType()
  local child_count = rep:getChildCount()
  rep:setCount(10)
  local count = rep:getCount()
  example_print_log("LBTNode:setCount: " .. tostring(count))
end

--@api: LBTNode:getCount
do
  local rep = lurek.ai.newRepeater(7)
  local node_type = rep:getNodeType()
  local child_count = rep:getChildCount()
  local count = rep:getCount()
  example_print_log("LBTNode:getCount: " .. tostring(count))
end

--@api: LBTNode:setSuccessPolicy
do
  local par = lurek.ai.newParallel("requireAll", "requireOne")
  local node_type = par:getNodeType()
  local child_count = par:getChildCount()
  par:setSuccessPolicy("requireOne")
  example_print_log("LBTNode:setSuccessPolicy: done")
  example_print_log("LBTNode:setSuccessPolicy: type=" .. par:getNodeType())
end

--@api: LBTNode:setFailurePolicy
do
  local par = lurek.ai.newParallel("requireOne", "requireAll")
  local node_type = par:getNodeType()
  local child_count = par:getChildCount()
  par:setFailurePolicy("requireOne")
  example_print_log("LBTNode:setFailurePolicy: done")
  example_print_log("LBTNode:setFailurePolicy: type=" .. par:getNodeType())
end

--@api: LBTNode:getNodeType
do
  local act = lurek.ai.newAction(function() return "success" end)
  local node_type = act:getNodeType()
  local child_count = act:getChildCount()
  act:reset()
  example_print_log("LBTNode:getNodeType: " .. act:getNodeType())
end

--@api: LBTNode:type
do
  local node = lurek.ai.newAction(function() return "success" end)
  local node_type = node:getNodeType()
  local child_count = node:getChildCount()
  local t = node:type()
  example_print_log("LBTNode:type: " .. t)
  example_print_log("LBTNode:type: matches=" .. tostring(node:typeOf("LBTNode")))
end

--@api: LBTNode:typeOf
do
  local node = lurek.ai.newSelector()
  local node_type = node:getNodeType()
  local child_count = node:getChildCount()
  local is_node = node:typeOf("LBTNode")
  local is_other = node:typeOf("LImage")
  example_print_log("LBTNode:typeOf: LBTNode=" .. tostring(is_node) .. " LImage=" .. tostring(is_other))
end

--@api: LSteeringManager:addSeek
do
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:addSeek(400, 300, 1.0)
  local fx, fy = steer:calculate(50, 50, 0, 0, 100, 200, 1 / 60)
  example_print_log("LSteeringManager:addSeek: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end

--@api: LSteeringManager:addFlee
do
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:addFlee(200, 200, 1.0)
  local fx, fy = steer:calculate(210, 195, 0, 0, 100, 200, 1 / 60)
  example_print_log("LSteeringManager:addFlee: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end

--@api: LSteeringManager:addArrive
do
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:addArrive(300, 300, 50, 1.0)
  local fx, fy = steer:calculate(280, 290, 30, 10, 100, 200, 1 / 60)
  example_print_log("LSteeringManager:addArrive: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end

--@api: LSteeringManager:addWander
do
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:addWander(25, 50, 8, 0.5)
  local fx, fy = steer:calculate(100, 100, 10, 0, 80, 150, 1 / 60)
  example_print_log("LSteeringManager:addWander: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end

--@api: LSteeringManager:addPursue
do
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:setEntity("target_agent", 220, 120, 20, 0)
  steer:addPursue("target_agent", 1.0)
  local fx, fy = steer:calculate(100, 120, 0, 0, 120, 250, 1 / 60)
  example_print_log("LSteeringManager:addPursue: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end

--@api: LSteeringManager:addEvade
do
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:setEntity("enemy_agent", 140, 120, -10, 0)
  steer:addEvade("enemy_agent", 1.0)
  local fx, fy = steer:calculate(100, 120, 0, 0, 120, 250, 1 / 60)
  example_print_log("LSteeringManager:addEvade: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end

--@api: LSteeringManager:addFlock
do
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:setEntity("ally_1", 110, 100, 20, 0)
  steer:setEntity("ally_2", 95, 140, 10, 5)
  steer:addFlock(80, 1.5, 1.0, 1.0, 1.0)
  local fx, fy = steer:calculate(100, 120, 0, 0, 120, 250, 1 / 60)
  example_print_log("LSteeringManager:addFlock: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end

--@api: LSteeringManager:setEntity
do
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:setEntity("scout", 100, 80, 12, 0)
  example_print_log("LSteeringManager:setEntity: count=" .. tostring(steer:entityCount()))
end

--@api: LSteeringManager:removeEntity
do
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:setEntity("scout", 100, 80, 12, 0)
  local removed = steer:removeEntity("scout")
  example_print_log("LSteeringManager:removeEntity: removed=" .. tostring(removed))
end

--@api: LSteeringManager:clearEntities
do
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:setEntity("a", 0, 0)
  steer:setEntity("b", 16, 0)
  steer:clearEntities()
  example_print_log("LSteeringManager:clearEntities: count=" .. tostring(steer:entityCount()))
end

--@api: LSteeringManager:entityCount
do
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:setEntity("a", 0, 0)
  example_print_log("LSteeringManager:entityCount: " .. tostring(steer:entityCount()))
end

--@api: LSteeringManager:getBehaviorCount
do
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:addSeek(100, 100, 1.0)
  steer:addWander(10, 20, 3, 0.5)
  local count = steer:getBehaviorCount()
  example_print_log("LSteeringManager:getBehaviorCount: " .. tostring(count))
end

--@api: LSteeringManager:setCombineMode
do
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:setCombineMode("priority")
  local mode = steer:getCombineMode()
  example_print_log("LSteeringManager:setCombineMode: " .. mode)
end

--@api: LSteeringManager:getCombineMode
do
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:setCombineMode("truncated")
  local mode = steer:getCombineMode()
  example_print_log("LSteeringManager:getCombineMode: " .. mode)
  example_print_log("LSteeringManager:getCombineMode: type=" .. steer:type())
end

--@api: LSteeringManager:getLastSteering
do
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:addSeek(200, 200, 1.0)
  steer:calculate(50, 50, 0, 0, 100, 200, 1 / 60)
  local lx, ly = steer:getLastSteering()
  example_print_log("LSteeringManager:getLastSteering: " .. tostring(lx) .. "," .. tostring(ly))
end

--@api: LSteeringManager:calculate
do
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:addSeek(500, 300, 1.0)
  steer:addWander(15, 30, 4, 0.3)
  local fx, fy = steer:calculate(100, 100, 20, 5, 150, 250, 1 / 60)
  example_print_log("LSteeringManager:calculate: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end

--@api: LSteeringManager:setPath
do
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  local waypoints = {
    { x = 50, y = 50 },
    { x = 200, y = 80 },
    { x = 350, y = 200 },
    { x = 400, y = 400 },
  }
  steer:setPath(waypoints, 16.0, 1.0)
  local has = steer:hasPath()
  example_print_log("LSteeringManager:setPath: hasPath=" .. tostring(has))
end

--@api: LSteeringManager:clearPath
do
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:setPath({ { x = 10, y = 10 }, { x = 100, y = 100 } }, 8.0, 1.0)
  steer:clearPath()
  local has = steer:hasPath()
  example_print_log("LSteeringManager:clearPath: hasPath=" .. tostring(has))
end

--@api: LSteeringManager:hasPath
do
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  local before = steer:hasPath()
  steer:setPath({ { x = 0, y = 0 }, { x = 50, y = 50 } }, 5.0, 1.0)
  local after = steer:hasPath()
  example_print_log("LSteeringManager:hasPath: before=" .. tostring(before) .. " after=" .. tostring(after))
end

--@api: LSteeringManager:getPathProgress
do
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:setPath({ { x = 0, y = 0 }, { x = 100, y = 50 }, { x = 200, y = 100 } }, 10.0, 1.0)
  local idx, total = steer:getPathProgress()
  example_print_log("LSteeringManager:getPathProgress: " .. tostring(idx) .. "/" .. tostring(total))
end

--@api: LSteeringManager:type
do
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  local t = steer:type()
  example_print_log("LSteeringManager:type: " .. t)
  example_print_log("LSteeringManager:type: matches=" .. tostring(steer:typeOf("LSteeringManager")))
end

--@api: LSteeringManager:typeOf
do
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  local is_steer = steer:typeOf("LSteeringManager")
  local is_other = steer:typeOf("LBot")
  example_print_log("LSteeringManager:typeOf: LSteeringManager=" .. tostring(is_steer) .. " LBot=" .. tostring(is_other))
end

--@api: LSteeringManager:setSpatialHashCellSize
do
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:setSpatialHashCellSize(32)
  example_print_log("LSteeringManager:setSpatialHashCellSize: done")
end

--@api: LSteeringManager:enableSpatialHash
do
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:enableSpatialHash(true)
  steer:setSpatialHashCellSize(48)
  example_print_log("LSteeringManager:enableSpatialHash: done")
end

--@api: LSteeringManager:addCustomBehavior
do
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:addCustomBehavior(function(agent, dt) return 50, 0 end, 0.8)
  local count = steer:getBehaviorCount()
  example_print_log("LSteeringManager:addCustomBehavior: behaviors=" .. tostring(count))
end

--@api: LSteeringManager:applyCustomSteering
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("pusher")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  npc:setPosition(100, 100)
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:addCustomBehavior(function(agent, dt) return 25, -10 end, 1.0)
  local fx, fy = steer:applyCustomSteering(npc, 1 / 60)
  example_print_log("LSteeringManager:applyCustomSteering: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end

--@api: LUtilityAI:addAction
do
    local uai = lurek.ai.newUtilityAI()
  uai:addAction("idle", function() return 0.1 end)
  local chosen_preview = uai:evaluate()
    uai:addAction("eat", function() return 0.8 end, 1.0)
    uai:addAction("sleep", function() return 0.3 end, 1.0)
    example_print_log("actions added = " .. uai:getActionCount())
end

--@api: LUtilityAI:evaluate
do
    local uai = lurek.ai.newUtilityAI()
  uai:addAction("idle", function() return 0.1 end)
  local chosen_preview = uai:evaluate()
    uai:addAction("attack", function() return 0.9 end)
    uai:addAction("defend", function() return 0.4 end)
    local chosen = uai:evaluate()
    example_print_log("chosen action = " .. tostring(chosen))
end

--@api: LUtilityAI:getActionCount
do
    local uai = lurek.ai.newUtilityAI()
  uai:addAction("idle", function() return 0.1 end)
  local chosen_preview = uai:evaluate()
    uai:addAction("patrol", function() return 0.5 end)
    uai:addAction("idle", function() return 0.1 end)
    uai:addAction("chase", function() return 0.7 end)
    example_print_log("action count = " .. uai:getActionCount())
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
    example_print_log("last action = " .. tostring(last))
end

--@api: LUtilityAI:addConsideration
do
    local uai = lurek.ai.newUtilityAI()
  uai:addAction("idle", function() return 0.1 end)
  local chosen_preview = uai:evaluate()
    uai:addAction("heal", function() return 0.5 end)
    uai:addConsideration("heal", "low_health", function() return 0.9 end, "linear", 1.0, 0.0, 0.0, 1.0)
    uai:evaluate()
    example_print_log("consideration added, last = " .. tostring(uai:getLastAction()))
end

--@api: LUtilityAI:type
do
    local uai = lurek.ai.newUtilityAI()
  uai:addAction("idle", function() return 0.1 end)
  local chosen_preview = uai:evaluate()
    example_print_log("type = " .. uai:type())
  example_print_log("matches = " .. tostring(uai:typeOf("LUtilityAI")))
end

--@api: LUtilityAI:typeOf
do
    local uai = lurek.ai.newUtilityAI()
  uai:addAction("idle", function() return 0.1 end)
  local chosen_preview = uai:evaluate()
    local type_name = uai:type()
    example_print_log("is LUtilityAI = " .. tostring(uai:typeOf("LUtilityAI")))
end

--@api: LGOAPPlanner:addAction
do
    local goap = lurek.ai.newGOAPPlanner()
  goap:addGoal("idle", 1)
  local goal_count = goap:getGoalCount()
    goap:addAction("chop_wood", 2, function() example_print_log("  chopping wood") end)
    goap:addAction("build_house", 5, function() example_print_log("  building house") end)
    example_print_log("goap actions = " .. goap:getActionCount())
end

--@api: LGOAPPlanner:setPrecondition
do
    local goap = lurek.ai.newGOAPPlanner()
  goap:addGoal("idle", 1)
  local goal_count = goap:getGoalCount()
    goap:addAction("cook", 1, function() end)
    goap:setPrecondition("cook", "has_food", true)
    example_print_log("precondition set for cook")
end

--@api: LGOAPPlanner:setEffect
do
    local goap = lurek.ai.newGOAPPlanner()
  goap:addGoal("idle", 1)
  local goal_count = goap:getGoalCount()
    goap:addAction("mine_ore", 3, function() end)
    goap:setEffect("mine_ore", "has_ore", true)
    example_print_log("effect set for mine_ore")
end

--@api: LGOAPPlanner:addGoal
do
    local goap = lurek.ai.newGOAPPlanner()
  goap:addGoal("idle", 1)
  local goal_count = goap:getGoalCount()
    goap:addGoal("survive", 10)
    goap:addGoal("explore", 3)
    example_print_log("goals = " .. goap:getGoalCount())
end

--@api: LGOAPPlanner:setGoalState
do
    local goap = lurek.ai.newGOAPPlanner()
  goap:addGoal("idle", 1)
  local goal_count = goap:getGoalCount()
    goap:addGoal("build_shelter", 5)
    goap:setGoalState("build_shelter", "shelter_built", true)
    example_print_log("goal state set for build_shelter")
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
  example_print_log("plan steps = " .. #plan)
end

--@api: LGOAPPlanner:getActionCount
do
    local goap = lurek.ai.newGOAPPlanner()
  goap:addGoal("idle", 1)
  local goal_count = goap:getGoalCount()
    goap:addAction("a1", 1, function() end)
    goap:addAction("a2", 2, function() end)
    example_print_log("action count = " .. goap:getActionCount())
end

--@api: LGOAPPlanner:getGoalCount
do
    local goap = lurek.ai.newGOAPPlanner()
  goap:addGoal("idle", 1)
  local goal_count = goap:getGoalCount()
    goap:addGoal("g1", 1)
    goap:addGoal("g2", 5)
    goap:addGoal("g3", 3)
    example_print_log("goal count = " .. goap:getGoalCount())
end

--@api: LGOAPPlanner:getMaxIterations
do
    local goap = lurek.ai.newGOAPPlanner()
  goap:addGoal("idle", 1)
  local goal_count = goap:getGoalCount()
    local max = goap:getMaxIterations()
    example_print_log("default max iterations = " .. max)
end

--@api: LGOAPPlanner:setMaxIterations
do
    local goap = lurek.ai.newGOAPPlanner()
  goap:addGoal("idle", 1)
  local goal_count = goap:getGoalCount()
    goap:setMaxIterations(500)
    example_print_log("max iterations = " .. goap:getMaxIterations())
end

--@api: LGOAPPlanner:type
do
    local goap = lurek.ai.newGOAPPlanner()
  goap:addGoal("idle", 1)
  local goal_count = goap:getGoalCount()
    example_print_log("type = " .. goap:type())
  example_print_log("matches = " .. tostring(goap:typeOf("LGOAPPlanner")))
end

--@api: LGOAPPlanner:typeOf
do
    local goap = lurek.ai.newGOAPPlanner()
  goap:addGoal("idle", 1)
  local goal_count = goap:getGoalCount()
    local type_name = goap:type()
    example_print_log("is LGOAPPlanner = " .. tostring(goap:typeOf("LGOAPPlanner")))
end

--@api: LInfluenceMap:addLayer
do
    local im = lurek.ai.newInfluenceMap(16, 16, 1.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
    im:addLayer("threat")
    im:addLayer("resources")
    example_print_log("layers added: threat, resources")
end

--@api: LInfluenceMap:hasLayer
do
    local im = lurek.ai.newInfluenceMap(8, 8, 2.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
    im:addLayer("heat")
    example_print_log("has heat = " .. tostring(im:hasLayer("heat")))
    example_print_log("has cold = " .. tostring(im:hasLayer("cold")))
end

--@api: LInfluenceMap:setInfluence
do
    local im = lurek.ai.newInfluenceMap(10, 10, 1.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
    im:addLayer("danger")
    im:setInfluence("danger", 5, 5, 1.0)
    im:setInfluence("danger", 3, 7, 0.5)
    example_print_log("set influence at (5,5) and (3,7)")
end

--@api: LInfluenceMap:getInfluence
do
    local im = lurek.ai.newInfluenceMap(10, 10, 1.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
    im:addLayer("food")
    im:setInfluence("food", 4, 4, 0.75)
    local val = im:getInfluence("food", 4, 4)
    example_print_log("food at (4,4) = " .. val)
end

--@api: LInfluenceMap:stampInfluence
do
    local im = lurek.ai.newInfluenceMap(20, 20, 1.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
    im:addLayer("noise")
    im:stampInfluence("noise", 10.0, 10.0, 3.0, 1.0, 0.5)
    local center = im:getInfluence("noise", 10, 10)
    example_print_log("noise center = " .. center)
end

--@api: LInfluenceMap:propagate
do
  local im = lurek.ai.newInfluenceMap(10, 10, 1.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
  im:addLayer("scent")
    im:setInfluence("scent", 5, 5, 1.0)
    im:propagate("scent", 0.8)
    local neighbor = im:getInfluence("scent", 4, 5)
    example_print_log("scent propagated to (4,5) = " .. neighbor)
end

--@api: LInfluenceMap:decay
do
  local im = lurek.ai.newInfluenceMap(8, 8, 1.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
  im:addLayer("heat")
    im:setInfluence("heat", 4, 4, 1.0)
    im:decay("heat", 0.5)
    local val = im:getInfluence("heat", 4, 4)
    example_print_log("heat after decay = " .. val)
end

--@api: LInfluenceMap:clearLayer
do
  local im = lurek.ai.newInfluenceMap(8, 8, 1.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
  im:addLayer("marks")
    im:setInfluence("marks", 2, 2, 1.0)
    im:clearLayer("marks")
    local val = im:getInfluence("marks", 2, 2)
    example_print_log("after clear = " .. val)
end

--@api: LInfluenceMap:clearAll
do
  local im = lurek.ai.newInfluenceMap(8, 8, 1.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
  im:addLayer("a")
  im:addLayer("b")
  im:setInfluence("a", 1, 1, 1.0)
    im:setInfluence("b", 2, 2, 0.5)
    im:clearAll()
    example_print_log("all cleared, a(1,1) = " .. im:getInfluence("a", 1, 1))
end

--@api: LInfluenceMap:getMaxPosition
do
  local im = lurek.ai.newInfluenceMap(10, 10, 1.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
  im:addLayer("gold")
    im:setInfluence("gold", 7, 3, 0.9)
    im:setInfluence("gold", 2, 8, 0.4)
    local mx, my = im:getMaxPosition("gold")
    example_print_log("max gold at (" .. mx .. ", " .. my .. ")")
end

--@api: LInfluenceMap:getMinPosition
do
  local im = lurek.ai.newInfluenceMap(10, 10, 1.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
  im:addLayer("cold")
    im:setInfluence("cold", 1, 1, -0.5)
    im:setInfluence("cold", 5, 5, 0.3)
    local mx, my = im:getMinPosition("cold")
    example_print_log("min cold at (" .. mx .. ", " .. my .. ")")
end

--@api: LInfluenceMap:queryRect
do
  local im = lurek.ai.newInfluenceMap(10, 10, 1.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
  im:addLayer("energy")
    im:setInfluence("energy", 2, 2, 0.5)
    im:setInfluence("energy", 3, 3, 0.5)
    local total = im:queryRect("energy", 1, 1, 4, 4)
    example_print_log("energy in rect = " .. total)
end

--@api: LInfluenceMap:blend
do
  local im = lurek.ai.newInfluenceMap(8, 8, 1.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
  im:addLayer("threat")
  im:addLayer("reward")
  im:addLayer("combined")
  im:setInfluence("threat", 4, 4, 1.0)
  im:setInfluence("reward", 4, 4, 0.8)
  im:blend("threat", 0.5, "reward", 0.5, "combined")
  local val = im:getInfluence("combined", 4, 4)
    example_print_log("blended (4,4) = " .. val)
end

--@api: LInfluenceMap:getWidth
do
    local im = lurek.ai.newInfluenceMap(16, 12, 2.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
    local map_height = im:getHeight()
    example_print_log("width = " .. im:getWidth())
end

--@api: LInfluenceMap:getHeight
do
    local im = lurek.ai.newInfluenceMap(16, 12, 2.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
    local cell_size = im:getCellSize()
    example_print_log("height = " .. im:getHeight())
end

--@api: LInfluenceMap:getCellSize
do
    local im = lurek.ai.newInfluenceMap(8, 8, 2.5)
  im:addLayer("debug")
  local map_width = im:getWidth()
    local map_height = im:getHeight()
    example_print_log("cell size = " .. im:getCellSize())
end

--@api: LInfluenceMap:type
do
    local im = lurek.ai.newInfluenceMap(4, 4, 1.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
    example_print_log("type = " .. im:type())
  example_print_log("matches = " .. tostring(im:typeOf("LInfluenceMap")))
end

--@api: LInfluenceMap:typeOf
do
    local im = lurek.ai.newInfluenceMap(4, 4, 1.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
    local type_name = im:type()
    example_print_log("is LInfluenceMap = " .. tostring(im:typeOf("LInfluenceMap")))
end

--@api: LSquad:getName
do
    local sq = lurek.ai.newSquad("alpha")
  sq:addMember("unit_1")
  local member_count = sq:getMemberCount()
    sq:setLeader("unit_1")
    example_print_log("squad name = " .. sq:getName())
end

--@api: LSquad:addMember
do
    local sq = lurek.ai.newSquad("bravo")
  sq:addMember("unit_1")
  local member_count = sq:getMemberCount()
    sq:addMember("soldier_1")
    sq:addMember("soldier_2")
    example_print_log("members = " .. sq:getMemberCount())
end

--@api: LSquad:removeMember
do
    local sq = lurek.ai.newSquad("charlie")
  sq:addMember("unit_1")
  local member_count = sq:getMemberCount()
    sq:addMember("scout")
    sq:addMember("medic")
    sq:removeMember("scout")
    example_print_log("after remove = " .. sq:getMemberCount())
end

--@api: LSquad:getMemberCount
do
    local sq = lurek.ai.newSquad("delta")
  sq:addMember("unit_1")
  local member_count = sq:getMemberCount()
    sq:addMember("a")
    sq:addMember("b")
    sq:addMember("c")
    example_print_log("count = " .. sq:getMemberCount())
end

--@api: LSquad:getMembers
do
    local sq = lurek.ai.newSquad("echo")
  sq:addMember("unit_1")
  local member_count = sq:getMemberCount()
    sq:addMember("sniper")
    sq:addMember("heavy")
    local members = sq:getMembers()
    example_print_log("members: " .. table.concat(members, ", "))
end

--@api: LSquad:setLeader
do
    local sq = lurek.ai.newSquad("foxtrot")
  sq:addMember("unit_1")
  local member_count = sq:getMemberCount()
    sq:addMember("captain")
    sq:addMember("private")
    sq:setLeader("captain")
    example_print_log("leader = " .. sq:getLeader())
end

--@api: LSquad:getLeader
do
    local sq = lurek.ai.newSquad("golf")
  sq:addMember("unit_1")
  local member_count = sq:getMemberCount()
    sq:addMember("commander")
    sq:setLeader("commander")
    local leader = sq:getLeader()
    example_print_log("leader = " .. tostring(leader))
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
    example_print_log("formation set to wedge, spacing 2.0")
end

--- AI Examples Part 4: Squad (cont.), Command Queue, Trait Profile, Stimulus World, Context Steering, Need System

--@api: LSquad:getFormation
do
    local sq = lurek.ai.newSquad("recon")
  sq:addMember("unit_1")
  local member_count = sq:getMemberCount()
    sq:setFormation("line", 3.0)
    local f = sq:getFormation()
    example_print_log("formation = " .. f)
end

--@api: LSquad:getFormationSpacing
do
    local sq = lurek.ai.newSquad("assault")
  sq:addMember("unit_1")
  local member_count = sq:getMemberCount()
    sq:setFormation("wedge", 2.5)
    local s = sq:getFormationSpacing()
    example_print_log("spacing = " .. s)
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
    example_print_log("member 2 pos = " .. x .. ", " .. y)
end

--@api: LSquad:getBlackboard
do
    local sq = lurek.ai.newSquad("intel")
  sq:addMember("unit_1")
  local member_count = sq:getMemberCount()
    local bb = sq:getBlackboard()
    bb:setNumber("threat_level", 3)
    example_print_log("squad bb threat = " .. bb:getNumber("threat_level"))
end

--@api: LSquad:type
do
    local sq = lurek.ai.newSquad("test")
  sq:addMember("unit_1")
  local member_count = sq:getMemberCount()
    example_print_log("type = " .. sq:type())
  example_print_log("matches = " .. tostring(sq:typeOf("LSquad")))
end

--@api: LSquad:typeOf
do
    local sq = lurek.ai.newSquad("test2")
  sq:addMember("unit_1")
  local member_count = sq:getMemberCount()
    local type_name = sq:type()
    example_print_log("is LSquad = " .. tostring(sq:typeOf("LSquad")))
end

--@api: LCommandQueue:enqueue
do
    local cq = lurek.ai.newCommandQueue()
  cq:enqueue("hold", function() end, { targetX = 0, targetY = 0 })
  local queue_count = cq:getCount()
    cq:enqueue("move", function() example_print_log("  moving") end, { targetX = 10, targetY = 20 })
    cq:enqueue("attack", function() example_print_log("  attacking") end)
    example_print_log("queue size = " .. cq:getCount())
end

--@api: LCommandQueue:pushFront
do
    local cq = lurek.ai.newCommandQueue()
  cq:enqueue("hold", function() end, { targetX = 0, targetY = 0 })
  local queue_count = cq:getCount()
    cq:enqueue("patrol", function() end)
    cq:pushFront("dodge", function() example_print_log("  dodging") end)
    example_print_log("next type = " .. cq:getCurrentType())
end

--@api: LCommandQueue:replace
do
    local cq = lurek.ai.newCommandQueue()
  cq:enqueue("hold", function() end, { targetX = 0, targetY = 0 })
  local queue_count = cq:getCount()
    cq:enqueue("idle", function() end)
    cq:enqueue("gather", function() end)
    cq:replace("retreat", function() example_print_log("  retreating") end)
    example_print_log("after replace count = " .. cq:getCount())
end

--@api: LCommandQueue:cancelCurrent
do
    local cq = lurek.ai.newCommandQueue()
  cq:enqueue("hold", function() end, { targetX = 0, targetY = 0 })
  local queue_count = cq:getCount()
    cq:enqueue("walk", function() end)
    cq:enqueue("talk", function() end)
    cq:cancelCurrent()
    example_print_log("after cancel, type = " .. tostring(cq:getCurrentType()))
end

--@api: LCommandQueue:clear
do
    local cq = lurek.ai.newCommandQueue()
  cq:enqueue("hold", function() end, { targetX = 0, targetY = 0 })
  local queue_count = cq:getCount()
    cq:enqueue("a", function() end)
    cq:enqueue("b", function() end)
    cq:clear()
    example_print_log("after clear, empty = " .. tostring(cq:isEmpty()))
end

--@api: LCommandQueue:getCount
do
    local cq = lurek.ai.newCommandQueue()
  cq:enqueue("hold", function() end, { targetX = 0, targetY = 0 })
  local queue_count = cq:getCount()
    cq:enqueue("x", function() end)
    cq:enqueue("y", function() end)
    cq:enqueue("z", function() end)
    example_print_log("count = " .. cq:getCount())
end

--@api: LCommandQueue:isEmpty
do
    local cq = lurek.ai.newCommandQueue()
  cq:enqueue("hold", function() end, { targetX = 0, targetY = 0 })
  local queue_count = cq:getCount()
    example_print_log("empty initially = " .. tostring(cq:isEmpty()))
    cq:enqueue("step", function() end)
    example_print_log("empty after enqueue = " .. tostring(cq:isEmpty()))
end

--@api: LCommandQueue:getCurrentType
do
    local cq = lurek.ai.newCommandQueue()
  cq:enqueue("hold", function() end, { targetX = 0, targetY = 0 })
  local queue_count = cq:getCount()
    cq:enqueue("harvest", function() end)
    example_print_log("current type = " .. tostring(cq:getCurrentType()))
end

--@api: LCommandQueue:getCurrentTarget
do
    local cq = lurek.ai.newCommandQueue()
  cq:enqueue("hold", function() end, { targetX = 0, targetY = 0 })
  local queue_count = cq:getCount()
    cq:enqueue("go", function() end, { targetX = 5, targetY = 10 })
    local tgt = cq:getCurrentTarget()
    example_print_log("target = " .. tostring(tgt))
end

--@api: LCommandQueue:type
do
    local cq = lurek.ai.newCommandQueue()
  cq:enqueue("hold", function() end, { targetX = 0, targetY = 0 })
  local queue_count = cq:getCount()
    example_print_log("type = " .. cq:type())
  example_print_log("matches = " .. tostring(cq:typeOf("LCommandQueue")))
end

--@api: LCommandQueue:typeOf
do
    local cq = lurek.ai.newCommandQueue()
  cq:enqueue("hold", function() end, { targetX = 0, targetY = 0 })
  local queue_count = cq:getCount()
    local type_name = cq:type()
    example_print_log("is LCommandQueue = " .. tostring(cq:typeOf("LCommandQueue")))
end

--@api: LTraitProfile:set
do
    local tp = lurek.ai.newTraitProfile()
  tp:set("morale", 0.5)
  local morale = tp:get("morale")
    tp:set("courage", 0.7)
    tp:set("aggression", 0.3)
    example_print_log("courage = " .. tp:get("courage"))
end

--@api: LTraitProfile:get
do
    local tp = lurek.ai.newTraitProfile()
  tp:set("morale", 0.5)
  local morale = tp:get("morale")
    tp:set("speed", 1.0)
    tp:addModifier("speed", 0.5, 5.0, "buff")
    local effective = tp:get("speed")
    example_print_log("effective speed = " .. effective)
end

--@api: LTraitProfile:getBase
do
    local tp = lurek.ai.newTraitProfile()
  tp:set("morale", 0.5)
  local morale = tp:get("morale")
    tp:set("strength", 0.8)
    tp:addModifier("strength", 0.2, 10.0, "potion")
    example_print_log("base strength = " .. tp:getBase("strength"))
end

--@api: LTraitProfile:addModifier
do
    local tp = lurek.ai.newTraitProfile()
  tp:set("morale", 0.5)
  local morale = tp:get("morale")
    tp:set("defense", 0.5)
    tp:addModifier("defense", 0.3, 8.0, "shield_spell")
    example_print_log("defense with modifier = " .. tp:get("defense"))
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
    example_print_log("luck after remove = " .. tp:get("luck"))
end

--@api: LTraitProfile:update
do
    local tp = lurek.ai.newTraitProfile()
  tp:set("morale", 0.5)
  local morale = tp:get("morale")
    tp:set("rage", 0.5)
    tp:addModifier("rage", 0.5, 2.0, "berserk")
    tp:update(3.0)
    example_print_log("rage after 3s = " .. tp:get("rage"))
end

--@api: LTraitProfile:has
do
    local tp = lurek.ai.newTraitProfile()
  tp:set("morale", 0.5)
  local morale = tp:get("morale")
    tp:set("wisdom", 0.6)
    example_print_log("has wisdom = " .. tostring(tp:has("wisdom")))
    example_print_log("has charm = " .. tostring(tp:has("charm")))
end

--@api: LTraitProfile:traitCount
do
    local tp = lurek.ai.newTraitProfile()
  tp:set("morale", 0.5)
  local morale = tp:get("morale")
    tp:set("a", 0.1)
    tp:set("b", 0.2)
    tp:set("c", 0.3)
    example_print_log("trait count = " .. tp:traitCount())
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
    example_print_log("archetype = " .. arch)
end

--@api: LTraitProfile:type
do
    local tp = lurek.ai.newTraitProfile()
  tp:set("morale", 0.5)
  local morale = tp:get("morale")
    example_print_log("type = " .. tp:type())
  example_print_log("matches = " .. tostring(tp:typeOf("LTraitProfile")))
end

--@api: LTraitProfile:typeOf
do
    local tp = lurek.ai.newTraitProfile()
  tp:set("morale", 0.5)
  local morale = tp:get("morale")
    local type_name = tp:type()
    example_print_log("is LTraitProfile = " .. tostring(tp:typeOf("LTraitProfile")))
end

--@api: LStimulusWorld:addVisual
do
    local sw = lurek.ai.newStimulusWorld()
  local stimulus_id = sw:addVisual(0, 0, 0.5, 8.0, "ping")
  local stimulus_count = sw:count()
    local id = sw:addVisual(100, 200, 0.8, 50.0, "enemy_spotted")
    example_print_log("visual stimulus id = " .. id)
end

--@api: LStimulusWorld:addAuditory
do
    local sw = lurek.ai.newStimulusWorld()
  local stimulus_id = sw:addVisual(0, 0, 0.5, 8.0, "ping")
  local stimulus_count = sw:count()
    local id = sw:addAuditory(50, 80, 0.6, 30.0, 0.1, "footstep")
    example_print_log("auditory stimulus id = " .. id)
end

--@api: LStimulusWorld:remove
do
    local sw = lurek.ai.newStimulusWorld()
  local stimulus_id = sw:addVisual(0, 0, 0.5, 8.0, "ping")
  local stimulus_count = sw:count()
    local id = sw:addVisual(10, 10, 1.0, 20.0, "flash")
    sw:remove(id)
    example_print_log("removed stimulus, count = " .. sw:count())
end

--@api: LStimulusWorld:update
do
    local sw = lurek.ai.newStimulusWorld()
  local stimulus_id = sw:addVisual(0, 0, 0.5, 8.0, "ping")
  local stimulus_count = sw:count()
    sw:addAuditory(0, 0, 1.0, 10.0, 0.5, "bang")
    sw:update(5.0)
    example_print_log("after update, count = " .. sw:count())
end

--@api: LStimulusWorld:count
do
    local sw = lurek.ai.newStimulusWorld()
  local stimulus_id = sw:addVisual(0, 0, 0.5, 8.0, "ping")
  local stimulus_count = sw:count()
    sw:addVisual(0, 0, 1.0, 10.0, "a")
    sw:addVisual(5, 5, 0.5, 8.0, "b")
    example_print_log("stimulus count = " .. sw:count())
end

--@api: LStimulusWorld:clear
do
    local sw = lurek.ai.newStimulusWorld()
  local stimulus_id = sw:addVisual(0, 0, 0.5, 8.0, "ping")
  local stimulus_count = sw:count()
    sw:addVisual(0, 0, 1.0, 10.0, "x")
    sw:addAuditory(1, 1, 0.5, 5.0, 0.2, "y")
    sw:clear()
    example_print_log("after clear, count = " .. sw:count())
end

--@api: LStimulusWorld:type
do
    local sw = lurek.ai.newStimulusWorld()
  local stimulus_id = sw:addVisual(0, 0, 0.5, 8.0, "ping")
  local stimulus_count = sw:count()
    example_print_log("type = " .. sw:type())
  example_print_log("matches = " .. tostring(sw:typeOf("LStimulusWorld")))
end

--@api: LStimulusWorld:typeOf
do
    local sw = lurek.ai.newStimulusWorld()
  local stimulus_id = sw:addVisual(0, 0, 0.5, 8.0, "ping")
  local stimulus_count = sw:count()
    local type_name = sw:type()
    example_print_log("is LStimulusWorld = " .. tostring(sw:typeOf("LStimulusWorld")))
end

--@api: LContextSteering:addSeekTarget
do
    local cs = lurek.ai.newContextSteering(8)
  cs:addSeekTarget(0, 0, 1.0)
  local slot_count = cs:slotCount()
    cs:addSeekTarget(200, 150, 1.0)
    example_print_log("seek target added at (200, 150)")
end

--@api: LContextSteering:addWander
do
    local cs = lurek.ai.newContextSteering(8)
  cs:addSeekTarget(0, 0, 1.0)
  local slot_count = cs:slotCount()
    cs:addWander(0.3, 0.5)
    example_print_log("wander behavior added")
end

--@api: LContextSteering:addAvoidPoint
do
    local cs = lurek.ai.newContextSteering(8)
  cs:addSeekTarget(0, 0, 1.0)
  local slot_count = cs:slotCount()
    cs:addAvoidPoint(50, 50, 20.0, 1.5)
    example_print_log("avoid point at (50, 50) radius 20")
end

--@api: LContextSteering:addAvoidBounds
do
    local cs = lurek.ai.newContextSteering(8)
  cs:addSeekTarget(0, 0, 1.0)
  local slot_count = cs:slotCount()
    cs:addAvoidBounds(0, 0, 800, 600, 30.0, 1.0)
    example_print_log("avoid bounds set for 800x600 area")
end

--@api: LContextSteering:clearBehaviors
do
    local cs = lurek.ai.newContextSteering(8)
  cs:addSeekTarget(0, 0, 1.0)
  local slot_count = cs:slotCount()
    cs:addSeekTarget(100, 100, 1.0)
    cs:addAvoidPoint(50, 50, 10.0, 1.0)
    cs:clearBehaviors()
    example_print_log("behaviors cleared")
end

--@api: LContextSteering:evaluate
do
    local cs = lurek.ai.newContextSteering(8)
  cs:addSeekTarget(0, 0, 1.0)
  local slot_count = cs:slotCount()
    cs:addSeekTarget(300, 200, 1.0)
    cs:addAvoidPoint(150, 150, 30.0, 2.0)
    local dx, dy = cs:evaluate(100, 100, 1.0, 0.0)
    example_print_log("direction = " .. dx .. ", " .. dy)
end

--@api: LContextSteering:chosenMagnitude
do
    local cs = lurek.ai.newContextSteering(8)
  cs:addSeekTarget(0, 0, 1.0)
  local slot_count = cs:slotCount()
    cs:addSeekTarget(200, 200, 1.0)
    cs:evaluate(0, 0, 0, 0)
    local mag = cs:chosenMagnitude()
    example_print_log("magnitude = " .. mag)
end

--@api: LContextSteering:slotCount
do
    local cs = lurek.ai.newContextSteering(16)
  cs:addSeekTarget(0, 0, 1.0)
  local slot_count = cs:slotCount()
    local type_name = cs:type()
    example_print_log("slots = " .. cs:slotCount())
end

--@api: LContextSteering:type
do
    local cs = lurek.ai.newContextSteering(8)
  cs:addSeekTarget(0, 0, 1.0)
  local slot_count = cs:slotCount()
    example_print_log("type = " .. cs:type())
  example_print_log("matches = " .. tostring(cs:typeOf("LContextSteering")))
end

--@api: LContextSteering:typeOf
do
    local cs = lurek.ai.newContextSteering(8)
  cs:addSeekTarget(0, 0, 1.0)
  local slot_count = cs:slotCount()
    local type_name = cs:type()
    example_print_log("is LContextSteering = " .. tostring(cs:typeOf("LContextSteering")))
end

--@api: LNeedSystem:addNeed
do
    local ns = lurek.ai.newNeedSystem()
  ns:addNeed("rest", 0.1, 0.5, 1.0)
  local urgent_need = ns:mostUrgent()
    ns:addNeed("hunger", 0.1, 0.7, 2.0)
    ns:addNeed("thirst", 0.15, 0.6, 1.5)
    example_print_log("needs registered")
end

--@api: LNeedSystem:update
do
    local ns = lurek.ai.newNeedSystem()
  ns:addNeed("rest", 0.1, 0.5, 1.0)
  local urgent_need = ns:mostUrgent()
    ns:addNeed("fatigue", 0.05, 0.8, 1.0)
    ns:update(2.0)
    local urgent = ns:mostUrgent()
    example_print_log("most urgent after 2s = " .. tostring(urgent))
end

--@api: LNeedSystem:mostUrgent
do
    local ns = lurek.ai.newNeedSystem()
  ns:addNeed("rest", 0.1, 0.5, 1.0)
  local urgent_need = ns:mostUrgent()
    ns:addNeed("hunger", 0.5, 0.3, 2.0)
    ns:update(1.0)
    local name = ns:mostUrgent()
    example_print_log("most urgent = " .. tostring(name))
end

--@api: LNeedSystem:satisfy
do
    local ns = lurek.ai.newNeedSystem()
  ns:addNeed("rest", 0.1, 0.5, 1.0)
  local urgent_need = ns:mostUrgent()
    ns:addNeed("thirst", 0.2, 0.5, 1.5)
    ns:update(3.0)
    ns:satisfy("thirst", 0.8)
    example_print_log("thirst satisfied")
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
    example_print_log("hunger value = " .. val)
end

--@api: LNeedSystem:type
do
    local ns = lurek.ai.newNeedSystem()
  ns:addNeed("rest", 0.1, 0.5, 1.0)
  local urgent_need = ns:mostUrgent()
    example_print_log("type = " .. ns:type())
  example_print_log("matches = " .. tostring(ns:typeOf("LNeedSystem")))
end

--@api: LNeedSystem:typeOf
do
    local ns = lurek.ai.newNeedSystem()
  ns:addNeed("rest", 0.1, 0.5, 1.0)
  local urgent_need = ns:mostUrgent()
    local type_name = ns:type()
    example_print_log("is LNeedSystem = " .. tostring(ns:typeOf("LNeedSystem")))
end

--@api: LAIDirector:pushEvent
do
    local dir = lurek.ai.newAIDirector()
  dir:pushEvent(0.1)
  local current_phase = dir:phase()
    dir:pushEvent(0.5)
    dir:pushEvent(0.8)
    example_print_log("events pushed, tension = " .. dir:tension())
end

--@api: LAIDirector:update
do
    local dir = lurek.ai.newAIDirector()
  dir:pushEvent(0.1)
  local current_phase = dir:phase()
    dir:pushEvent(1.0)
    dir:update(2.0)
    example_print_log("phase after update = " .. dir:phase())
end

--@api: LAIDirector:tension
do
    local dir = lurek.ai.newAIDirector()
  dir:pushEvent(0.1)
  local current_phase = dir:phase()
    dir:setTension(0.6)
    example_print_log("tension = " .. dir:tension())
end

--@api: LAIDirector:phase
do
    local dir = lurek.ai.newAIDirector()
  dir:pushEvent(0.1)
  local current_phase = dir:phase()
    local p = dir:phase()
    example_print_log("initial phase = " .. p)
end

--@api: LAIDirector:spawnRateFactor
do
    local dir = lurek.ai.newAIDirector()
  dir:pushEvent(0.1)
  local current_phase = dir:phase()
    dir:setTension(0.9)
    dir:update(0.1)
    example_print_log("spawn rate factor = " .. dir:spawnRateFactor())
end

--@api: LAIDirector:lootFactor
do
    local dir = lurek.ai.newAIDirector()
  dir:pushEvent(0.1)
  local current_phase = dir:phase()
    dir:setTension(0.2)
    dir:update(0.1)
    example_print_log("loot factor = " .. dir:lootFactor())
end

--@api: LAIDirector:ambientIntensity
do
    local dir = lurek.ai.newAIDirector()
  dir:pushEvent(0.1)
  local current_phase = dir:phase()
    dir:setTension(0.7)
    dir:update(0.1)
    example_print_log("ambient intensity = " .. dir:ambientIntensity())
end

--@api: LAIDirector:setTension
do
    local dir = lurek.ai.newAIDirector()
  dir:pushEvent(0.1)
  local current_phase = dir:phase()
    dir:setTension(0.5)
    example_print_log("tension set to " .. dir:tension())
end

--@api: LAIDirector:reset
do
    local dir = lurek.ai.newAIDirector()
  dir:pushEvent(0.1)
  local current_phase = dir:phase()
    dir:setTension(0.9)
    dir:reset()
    example_print_log("after reset, tension = " .. dir:tension())
end

--@api: LAIDirector:type
do
    local dir = lurek.ai.newAIDirector()
  dir:pushEvent(0.1)
  local current_phase = dir:phase()
    example_print_log("type = " .. dir:type())
  example_print_log("matches = " .. tostring(dir:typeOf("LAIDirector")))
end

--@api: LAIDirector:typeOf
do
    local dir = lurek.ai.newAIDirector()
  dir:pushEvent(0.1)
  local current_phase = dir:phase()
    local type_name = dir:type()
    example_print_log("is LAIDirector = " .. tostring(dir:typeOf("LAIDirector")))
end

--@api: LHTNDomain:addPrimitive
do
    local htn = lurek.ai.newHTNDomain()
  local domain_type = htn:type()
  local task_count = htn:taskCount()
    htn:addPrimitive("chop", { "has_axe" }, { "has_wood" }, {})
    htn:addPrimitive("build", { "has_wood" }, { "shelter_done" }, { "has_wood" })
    example_print_log("primitives = " .. htn:taskCount())
end

--@api: LHTNDomain:addCompound
do
    local htn = lurek.ai.newHTNDomain()
  local domain_type = htn:type()
  local task_count = htn:taskCount()
    htn:addPrimitive("mine", {}, { "has_ore" }, {})
    htn:addPrimitive("smelt", { "has_ore" }, { "has_metal" }, { "has_ore" })
  htn:addCompound("get_metal", { { name = "mine_and_smelt", preconditions = {}, sub_tasks = { "mine", "smelt" } } })
  example_print_log("compound added, tasks = " .. htn:taskCount())
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
    example_print_log("plan size = " .. #plan)
    example_print_log("plan = " .. table.concat(plan, " -> "))
  end
end

--@api: LHTNDomain:taskCount
do
    local htn = lurek.ai.newHTNDomain()
  local domain_type = htn:type()
  local task_count = htn:taskCount()
    htn:addPrimitive("a", {}, {}, {})
    htn:addPrimitive("b", {}, {}, {})
    example_print_log("task count = " .. htn:taskCount())
end

--@api: LHTNDomain:type
do
    local htn = lurek.ai.newHTNDomain()
  local domain_type = htn:type()
  local task_count = htn:taskCount()
    example_print_log("type = " .. htn:type())
  example_print_log("matches = " .. tostring(htn:typeOf("LHTNDomain")))
end

--@api: LHTNDomain:typeOf
do
    local htn = lurek.ai.newHTNDomain()
  local domain_type = htn:type()
  local task_count = htn:taskCount()
    local type_name = htn:type()
    example_print_log("is LHTNDomain = " .. tostring(htn:typeOf("LHTNDomain")))
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
  example_print_log("best action = " .. tostring(action))
end

--@api: LMCTSEngine:type
do
    local mcts = lurek.ai.newMCTSEngine(50, 1.0, 5, 0)
    local simulations = 50
    local exploration = 1.0
    example_print_log("type = " .. mcts:type())
  example_print_log("matches = " .. tostring(mcts:typeOf("LMCTSEngine")))
end

--@api: LMCTSEngine:typeOf
do
    local mcts = lurek.ai.newMCTSEngine(50, 1.0, 5, 0)
    local simulations = 50
    local exploration = 1.0
    local type_name = mcts:type()
    example_print_log("is LMCTSEngine = " .. tostring(mcts:typeOf("LMCTSEngine")))
end

--@api: LEmotionModel:add
do
    local em = lurek.ai.newEmotionModel()
    em:add("joy", 0.3, 0.1, 0.2)
    em:add("anger", 0.0, 0.05, 0.3)
    local joy = em:get("joy")
    local anger = em:get("anger")
    example_print_log("emotions registered")
end

--@api: LEmotionModel:trigger
do
    local em = lurek.ai.newEmotionModel()
    em:add("fear", 0.0, 0.1, 0.2)
    em:trigger("fear", 0.7)
    local dominant = em:dominant()
    local active = em:isActive("fear")
    example_print_log("fear = " .. em:get("fear"))
end

--@api: LEmotionModel:get
do
    local em = lurek.ai.newEmotionModel()
    em:add("sadness", 0.2, 0.05, 0.1)
    em:trigger("sadness", 0.5)
    local val = em:get("sadness")
    example_print_log("sadness = " .. val)
end

--@api: LEmotionModel:dominant
do
  local em = lurek.ai.newEmotionModel()
  em:add("joy", 0.0, 0.1, 0.1)
    em:add("anger", 0.0, 0.1, 0.1)
    em:trigger("joy", 0.3)
    em:trigger("anger", 0.8)
    example_print_log("dominant = " .. tostring(em:dominant()))
end

--@api: LEmotionModel:isActive
do
  local em = lurek.ai.newEmotionModel()
  em:add("surprise", 0.0, 0.1, 0.5)
    em:trigger("surprise", 0.2)
    example_print_log("surprise active = " .. tostring(em:isActive("surprise")))
    em:trigger("surprise", 0.5)
    example_print_log("surprise active = " .. tostring(em:isActive("surprise")))
end

--@api: LEmotionModel:update
do
    local em = lurek.ai.newEmotionModel()
    em:add("excitement", 0.0, 0.2, 0.1)
    em:trigger("excitement", 1.0)
    em:update(3.0)
    example_print_log("excitement after 3s = " .. em:get("excitement"))
end

--@api: LEmotionModel:reset
do
    local em = lurek.ai.newEmotionModel()
    em:add("rage", 0.0, 0.1, 0.2)
    em:trigger("rage", 1.0)
    em:reset()
    example_print_log("rage after reset = " .. em:get("rage"))
end

--@api: LEmotionModel:type
do
    local em = lurek.ai.newEmotionModel()
    em:add("joy", 0.1, 0.1, 0.1)
    local dominant = em:dominant()
    example_print_log("type = " .. em:type())
  example_print_log("matches = " .. tostring(em:typeOf("LEmotionModel")))
end

--@api: LEmotionModel:typeOf
do
    local em = lurek.ai.newEmotionModel()
    em:add("joy", 0.1, 0.1, 0.1)
    local type_name = em:type()
    local dominant = em:dominant()
    example_print_log("is LEmotionModel = " .. tostring(em:typeOf("LEmotionModel")))
end

--@api: LORCASolver:addAgent
do
    local orca = lurek.ai.newORCASolver(2.0)
    local idx = orca:addAgent(10.0, 20.0, 0.5, 3.0)
    local count = orca:agentCount()
    local type_name = orca:type()
    example_print_log("agent index = " .. idx)
end

--@api: LORCASolver:setPreferredVelocity
do
    local orca = lurek.ai.newORCASolver(2.0)
    orca:addAgent(0, 0, 0.5, 5.0)
    orca:setPreferredVelocity(0, 2.0, 1.0)
    local count = orca:agentCount()
    local type_name = orca:type()
    example_print_log("preferred velocity set for agent 0")
end

--@api: LORCASolver:setPosition
do
    local orca = lurek.ai.newORCASolver(2.0)
    orca:addAgent(0, 0, 0.5, 5.0)
    orca:setPosition(0, 5.0, 3.0)
    local count = orca:agentCount()
    local type_name = orca:type()
    example_print_log("position updated for agent 0")
end

--@api: LORCASolver:compute
do
  local orca = lurek.ai.newORCASolver(1.5)
  orca:addAgent(0, 0, 0.5, 3.0)
  orca:addAgent(5, 0, 0.5, 3.0)
  orca:setPreferredVelocity(0, 1.0, 0.0)
    orca:setPreferredVelocity(1, -1.0, 0.0)
    orca:compute(0.016)
    example_print_log("collision avoidance computed")
end

--@api: LORCASolver:getSafeVelocity
do
  local orca = lurek.ai.newORCASolver(1.5)
  orca:addAgent(0, 0, 0.5, 3.0)
    orca:setPreferredVelocity(0, 2.0, 0.0)
    orca:compute(0.016)
    local vx, vy = orca:getSafeVelocity(0)
    example_print_log("safe velocity = " .. vx .. ", " .. vy)
end

--@api: LORCASolver:agentCount
do
    local orca = lurek.ai.newORCASolver(2.0)
    orca:addAgent(0, 0, 1.0, 2.0)
    orca:addAgent(5, 5, 1.0, 2.0)
    local type_name = orca:type()
    local is_solver = orca:typeOf("LORCASolver")
    example_print_log("agent count = " .. orca:agentCount())
end

--@api: LORCASolver:type
do
    local orca = lurek.ai.newORCASolver(1.0)
    orca:addAgent(0, 0, 0.5, 2.0)
    local count = orca:agentCount()
    example_print_log("type = " .. orca:type())
  example_print_log("matches = " .. tostring(orca:typeOf("LORCASolver")))
end

--@api: LORCASolver:typeOf
do
    local orca = lurek.ai.newORCASolver(1.0)
    orca:addAgent(0, 0, 0.5, 2.0)
    local count = orca:agentCount()
    local type_name = orca:type()
    example_print_log("is LORCASolver = " .. tostring(orca:typeOf("LORCASolver")))
end

--@api: LStrategyAI:addGoal
do
    local strat = lurek.ai.newStrategyAI(5.0)
    strat:addGoal("expand")
    strat:addGoal("defend")
    strat:addGoal("research")
    example_print_log("goals registered")
end

--@api: LStrategyAI:addTag
do
    local strat = lurek.ai.newStrategyAI(3.0)
    strat:addTag("war_declared")
    strat:addTag("low_resources")
    strat:addGoal("expand")
    local next_eval = strat:timeUntilNext()
    example_print_log("tags added")
end

--@api: LStrategyAI:removeTag
do
    local strat = lurek.ai.newStrategyAI(3.0)
    strat:addTag("peace")
    strat:removeTag("peace")
    strat:addGoal("defend")
    local next_eval = strat:timeUntilNext()
    example_print_log("tag removed")
end

--@api: LStrategyAI:update
do
    local strat = lurek.ai.newStrategyAI(1.0)
    strat:addGoal("attack")
    strat:addGoal("retreat")
    strat:update(1.5, function(goal) if goal == "attack" then return 0.8 end return 0.2 end)
    example_print_log("active = " .. tostring(strat:activeGoal()))
end

--@api: LStrategyAI:forceEvaluate
do
    local strat = lurek.ai.newStrategyAI(10.0)
    strat:addGoal("build")
    strat:addGoal("scout")
    strat:forceEvaluate(function(goal) if goal == "scout" then return 5.0 end return 1.0 end)
    example_print_log("forced active = " .. tostring(strat:activeGoal()))
end

--@api: LStrategyAI:activeGoal
do
    local strat = lurek.ai.newStrategyAI(1.0)
    strat:addGoal("idle")
    strat:addTag("waiting")
    local until_next = strat:timeUntilNext()
    local active = strat:activeGoal()
    example_print_log("active goal = " .. tostring(active))
end

--@api: LStrategyAI:timeUntilNext
do
    local strat = lurek.ai.newStrategyAI(5.0)
    strat:addGoal("wait")
    strat:update(2.0, function() return 1.0 end)
    strat:addTag("timer")
    local active = strat:activeGoal()
    example_print_log("time until next = " .. strat:timeUntilNext())
end

--@api: LStrategyAI:type
do
    local strat = lurek.ai.newStrategyAI(1.0)
    strat:addGoal("idle")
    local active = strat:activeGoal()
    example_print_log("type = " .. strat:type())
  example_print_log("matches = " .. tostring(strat:typeOf("LStrategyAI")))
end

--@api: LStrategyAI:typeOf
do
    local strat = lurek.ai.newStrategyAI(1.0)
    strat:addGoal("idle")
    local until_next = strat:timeUntilNext()
    local type_name = strat:type()
    example_print_log("is LStrategyAI = " .. tostring(strat:typeOf("LStrategyAI")))
end

--@api: LAILod:tierFor
do
    local lod = lurek.ai.newAILod()
  local tier_name = lod:tierName(0)
  local tier_index = lod:tierFor(0, 0, 0, 0)
    local tier = lod:tierFor(100, 200, 0, 0)
    example_print_log("tier = " .. tier)
end

--@api: LAILod:shouldUpdate
do
    local lod = lurek.ai.newAILod()
  local tier_name = lod:tierName(0)
  local tier_index = lod:tierFor(0, 0, 0, 0)
    local run = lod:shouldUpdate(0, 1)
    example_print_log("tier 0 should update on frame 1 = " .. tostring(run))
end

--@api: LAILod:tierCount
do
    local lod = lurek.ai.newAILod()
  local tier_name = lod:tierName(0)
  local tier_index = lod:tierFor(0, 0, 0, 0)
    local type_name = lod:type()
    local is_lod = lod:typeOf("LAILod")
    example_print_log("tier count = " .. lod:tierCount())
end

--@api: LAILod:tierName
do
    local lod = lurek.ai.newAILod()
  local tier_name = lod:tierName(0)
  local tier_index = lod:tierFor(0, 0, 0, 0)
    local name = lod:tierName(0)
    example_print_log("tier 0 name = " .. name)
end

--@api: LAILod:type
do
    local lod = lurek.ai.newAILod()
  local tier_name = lod:tierName(0)
  local tier_index = lod:tierFor(0, 0, 0, 0)
    example_print_log("type = " .. lod:type())
  example_print_log("matches = " .. tostring(lod:typeOf("LAILod")))
end

--@api: LAILod:typeOf
do
    local lod = lurek.ai.newAILod()
  local tier_name = lod:tierName(0)
  local tier_index = lod:tierFor(0, 0, 0, 0)
    local count = lod:tierCount()
    local type_name = lod:type()
    example_print_log("is LAILod = " .. tostring(lod:typeOf("LAILod")))
end

--@api: LAIWorld:getLastCallbackErrors
do
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("callback_probe")
  agent:setCustomModel(function() error("probe failure") end)
  world:update(1 / 60)
  local errors = world:getLastCallbackErrors()
  example_print_log("LAIWorld:getLastCallbackErrors: count=" .. tostring(#errors))
end

--@api: LSteeringManager:getLastDiagnostic
do
  local steer = lurek.ai.newSteeringManager()
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("steer_probe")
  steer:addCustomBehavior(function() error("custom steering failure") end, 1.0)
  steer:applyCustomSteering(agent, 1 / 60)
  example_print_log("LSteeringManager:getLastDiagnostic: " .. tostring(steer:getLastDiagnostic()))
end

--@api: LUtilityAI:getLastTrace
do
  local uai = lurek.ai.newUtilityAI()
  uai:addAction("heal", function() return 0.8 end)
  uai:addConsideration("heal", "low_health", function() return 1.0 end, "linear", 1.0, 0.0, 0.0, 1.0)
  uai:evaluate()
  local trace = uai:getLastTrace()
  example_print_log("LUtilityAI:getLastTrace: chosen=" .. tostring(trace.chosen_action))
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
  example_print_log("LGOAPPlanner:getLastFailureReason: plan_size=" .. tostring(#plan))
  example_print_log("LGOAPPlanner:getLastFailureReason: failure=" .. tostring(goap:getLastFailureReason()))
end

--@api: LGOAPPlanner:getLastTrace
do
  local goap = lurek.ai.newGOAPPlanner()
  goap:plan({}, 4)
  local trace = goap:getLastTrace()
  example_print_log("LGOAPPlanner:getLastTrace: failure=" .. tostring(trace.failure_reason))
  example_print_log("LGOAPPlanner:getLastTrace: iterations=" .. tostring(trace.iterations))
  example_print_log("LGOAPPlanner:getLastTrace: selected_goal=" .. tostring(trace.selected_goal))
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
  example_print_log("LMCTSEngine:getLastTrace: invalid_scores=" .. tostring(trace.invalid_score_count))
end
