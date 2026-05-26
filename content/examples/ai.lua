-- content/examples/ai.lua
-- Auto-generated from content/examples2/ai_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/ai.lua

--@api-stub: lurek.ai.newWorld
do
  local world = lurek.ai.newWorld()
  local scout = world:addAgent("scout_preview")
  local count = world:getAgentCount()
  print("lurek.ai.newWorld: agents=" .. tostring(count))
  print("lurek.ai.newWorld: first_agent=" .. scout:getName())
end

--@api-stub: lurek.ai.newBlackboard
do
  local bb = lurek.ai.newBlackboard()
  bb:setString("state", "idle")
  print("lurek.ai.newBlackboard: state=" .. bb:getString("state", "none"))
end

--@api-stub: lurek.ai.newStateMachine
do
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("idle", {})
  fsm:setInitialState("idle")
  print("lurek.ai.newStateMachine: ok=" .. tostring(fsm ~= nil))
  print("lurek.ai.newStateMachine: current=" .. tostring(fsm:getCurrentState()))
end

--@api-stub: lurek.ai.newBehaviorTree
do
  local bt = lurek.ai.newBehaviorTree()
  bt:setRoot(lurek.ai.newAction(function() return "success" end))
  local info = bt:getDebugState()
  print("lurek.ai.newBehaviorTree: status=" .. tostring(bt:getLastStatus()))
  print("lurek.ai.newBehaviorTree: node_count=" .. tostring(info.node_count))
end

--@api-stub: lurek.ai.newSelector
do
  local sel = lurek.ai.newSelector()
  sel:addChild(lurek.ai.newAction(function() return "failure" end))
  sel:addChild(lurek.ai.newAction(function() return "success" end))
  print("lurek.ai.newSelector: type=" .. sel:getNodeType())
  print("lurek.ai.newSelector: children=" .. tostring(sel:getChildCount()))
end

--@api-stub: lurek.ai.newSequence
do
  local seq = lurek.ai.newSequence()
  seq:addChild(lurek.ai.newCondition(function() return true end))
  seq:addChild(lurek.ai.newAction(function() return "success" end))
  print("lurek.ai.newSequence: type=" .. seq:getNodeType())
  print("lurek.ai.newSequence: children=" .. tostring(seq:getChildCount()))
end

--@api-stub: lurek.ai.newParallel
do
  local par = lurek.ai.newParallel("requireAll", "requireOne")
  par:addChild(lurek.ai.newAction(function() return "running" end))
  par:addChild(lurek.ai.newAction(function() return "success" end))
  print("lurek.ai.newParallel: type=" .. par:getNodeType())
  print("lurek.ai.newParallel: children=" .. tostring(par:getChildCount()))
end

--@api-stub: lurek.ai.newInverter
do
  local inv = lurek.ai.newInverter()
  inv:setChild(lurek.ai.newCondition(function() return false end))
  print("lurek.ai.newInverter: type=" .. inv:getNodeType())
  print("lurek.ai.newInverter: child_count=" .. tostring(inv:getChildCount()))
end

--@api-stub: lurek.ai.newRepeater
do
  local rep = lurek.ai.newRepeater(5)
  rep:setChild(lurek.ai.newAction(function() return "success" end))
  print("lurek.ai.newRepeater: count=" .. tostring(rep:getCount()))
  print("lurek.ai.newRepeater: type=" .. rep:getNodeType())
end

--@api-stub: lurek.ai.newSucceeder
do
  local suc = lurek.ai.newSucceeder()
  suc:setChild(lurek.ai.newAction(function() return "failure" end))
  print("lurek.ai.newSucceeder: type=" .. suc:getNodeType())
  print("lurek.ai.newSucceeder: child_count=" .. tostring(suc:getChildCount()))
end

--@api-stub: lurek.ai.newAction
do
  local act = lurek.ai.newAction(function() return "success" end)
  act:reset()
  print("lurek.ai.newAction: type=" .. act:getNodeType())
  print("lurek.ai.newAction: child_count=" .. tostring(act:getChildCount()))
end

--@api-stub: lurek.ai.newCondition
do
  local cond = lurek.ai.newCondition(function() return true end)
  cond:reset()
  print("lurek.ai.newCondition: type=" .. cond:getNodeType())
  print("lurek.ai.newCondition: child_count=" .. tostring(cond:getChildCount()))
end

--@api-stub: lurek.ai.newGuard
do
  local child_action = lurek.ai.newAction(function() return "success" end)
  local guard = lurek.ai.newGuard(function() return true end, child_action)
  print("lurek.ai.newGuard: node=" .. guard:getNodeType())
end

--@api-stub: lurek.ai.newSteeringManager
do
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(320, 180, 1.0)
  print("lurek.ai.newSteeringManager: ok=" .. tostring(steer ~= nil))
  print("lurek.ai.newSteeringManager: behaviors=" .. tostring(steer:getBehaviorCount()))
end

--@api-stub: lurek.ai.newQLearner
do
  local ql = lurek.ai.newQLearner(10, 4)
  ql:setQValue(1, 2, 0.75)
  print("lurek.ai.newQLearner: ok=" .. tostring(ql ~= nil))
  print("lurek.ai.newQLearner: best_action=" .. tostring(ql:bestAction(1)))
end

--@api-stub: lurek.ai.newUtilityAI
do
  local util = lurek.ai.newUtilityAI()
  util:addAction("wait", function() return 0.2 end)
  util:addAction("attack", function() return 0.9 end)
  print("lurek.ai.newUtilityAI: ok=" .. tostring(util ~= nil))
  print("lurek.ai.newUtilityAI: pick=" .. tostring(util:evaluate()))
end

--@api-stub: lurek.ai.newDialogueAI
do
  local dlg = lurek.ai.newDialogueAI()
  dlg:addTopic("greeting", 0.5, nil, nil, "greet_score")
  dlg:setUtilityScore("greet_score", 0.8)
  print("lurek.ai.newDialogueAI: ok=" .. tostring(dlg ~= nil))
  print("lurek.ai.newDialogueAI: topics=" .. tostring(dlg:getTopicCount()))
end

--@api-stub: lurek.ai.newGOAPPlanner
do
  local goap = lurek.ai.newGOAPPlanner()
  goap:addGoal("stay_alive", 5)
  goap:setGoalState("stay_alive", "alive", true)
  print("lurek.ai.newGOAPPlanner: ok=" .. tostring(goap ~= nil))
  print("lurek.ai.newGOAPPlanner: goals=" .. tostring(goap:getGoalCount()))
end

--@api-stub: lurek.ai.newInfluenceMap
do
  local imap = lurek.ai.newInfluenceMap(32, 32, 16)
  imap:addLayer("danger")
  imap:setInfluence("danger", 4, 5, 0.9)
  print("lurek.ai.newInfluenceMap: ok=" .. tostring(imap ~= nil))
  print("lurek.ai.newInfluenceMap: width=" .. tostring(imap:getWidth()))
end

--@api-stub: lurek.ai.newSquad
do
  local squad = lurek.ai.newSquad("bravo")
  squad:addMember("leader")
  squad:setLeader("leader")
  print("lurek.ai.newSquad: name=" .. squad:getName())
  print("lurek.ai.newSquad: members=" .. tostring(squad:getMemberCount()))
end

--@api-stub: lurek.ai.newCommandQueue
do
  local cq = lurek.ai.newCommandQueue()
  cq:enqueue("move", function() print("moving") end, { targetX = 32, targetY = 64 })
  print("lurek.ai.newCommandQueue: empty=" .. tostring(cq:isEmpty()))
  print("lurek.ai.newCommandQueue: count=" .. tostring(cq:getCount()))
end

--@api-stub: lurek.ai.newTraitProfile
do
  local traits = lurek.ai.newTraitProfile()
  traits:set("courage", 0.7)
  print("lurek.ai.newTraitProfile: ok=" .. tostring(traits ~= nil))
  print("lurek.ai.newTraitProfile: courage=" .. tostring(traits:get("courage")))
end

--@api-stub: lurek.ai.newStimulusWorld
do
  local sw = lurek.ai.newStimulusWorld()
  sw:addVisual(100, 150, 1.0, 48.0, "enemy")
  print("lurek.ai.newStimulusWorld: stimuli=" .. tostring(sw:count()))
  print("lurek.ai.newStimulusWorld: type=" .. sw:type())
end

--@api-stub: lurek.ai.newContextSteering
do
  local cs = lurek.ai.newContextSteering(8)
  cs:addSeekTarget(256, 128, 1.0)
  local dx, dy = cs:evaluate(0, 0, 1, 0)
  print("lurek.ai.newContextSteering: ok=" .. tostring(cs ~= nil))
  print("lurek.ai.newContextSteering: dir=" .. tostring(dx) .. "," .. tostring(dy))
end

--@api-stub: lurek.ai.newNeedSystem
do
  local needs = lurek.ai.newNeedSystem()
  needs:addNeed("hunger", 0.1, 0.7, 2.0)
  needs:update(2.0)
  print("lurek.ai.newNeedSystem: ok=" .. tostring(needs ~= nil))
  print("lurek.ai.newNeedSystem: urgent=" .. tostring(needs:mostUrgent()))
end

--@api-stub: lurek.ai.newAIDirector
do
  local dir = lurek.ai.newAIDirector()
  dir:pushEvent(0.6)
  dir:update(1.0)
  print("lurek.ai.newAIDirector: ok=" .. tostring(dir ~= nil))
  print("lurek.ai.newAIDirector: phase=" .. dir:phase())
end

--@api-stub: lurek.ai.newHTNDomain
do
  local htn = lurek.ai.newHTNDomain()
  print("lurek.ai.newHTNDomain: ok=" .. tostring(htn ~= nil))
  print("lurek.ai.newHTNDomain: tasks=" .. tostring(htn:taskCount()))
end

--@api-stub: lurek.ai.newMCTSEngine
do
  local mcts = lurek.ai.newMCTSEngine(100, 1.41, 20, 42)
  local get_actions = function(state)
    return { 1, 2, 3 }
  end
  local apply = function(state, action) return state + action end
  local evaluate = function(state) return state % 5 end
  local best_action = mcts:search(0, get_actions, apply, evaluate)
  print("lurek.ai.newMCTSEngine: action=" .. tostring(best_action))
end

--@api-stub: lurek.ai.newEmotionModel
do
  local emo = lurek.ai.newEmotionModel()
  emo:add("fear", 0.1, 0.2, 0.3)
  emo:trigger("fear", 0.5)
  print("lurek.ai.newEmotionModel: ok=" .. tostring(emo ~= nil))
  print("lurek.ai.newEmotionModel: dominant=" .. tostring(emo:dominant()))
end

--@api-stub: lurek.ai.newORCASolver
do
  local orca = lurek.ai.newORCASolver(1.5)
  orca:addAgent(0, 0, 0.5, 3.0)
  print("lurek.ai.newORCASolver: ok=" .. tostring(orca ~= nil))
  print("lurek.ai.newORCASolver: agents=" .. tostring(orca:agentCount()))
end

--@api-stub: lurek.ai.newNeuralNet
do
  local nn = lurek.ai.newNeuralNet()
  nn:addLayer(2, 3, "relu")
  nn:addLayer(3, 1, "linear")
  print("lurek.ai.newNeuralNet: ok=" .. tostring(nn ~= nil))
  print("lurek.ai.newNeuralNet: layers=" .. tostring(nn:layerCount()))
end

--@api-stub: lurek.ai.newGeneticAlgorithm
do
  local ga = lurek.ai.newGeneticAlgorithm(8, 5, 7)
  print("lurek.ai.newGeneticAlgorithm: ok=" .. tostring(ga ~= nil))
  print("lurek.ai.newGeneticAlgorithm: pop=" .. tostring(ga:popSize()))
end

--@api-stub: lurek.ai.newBandit
do
  local bandit = lurek.ai.newBandit(3, "ucb1", 0.15, 55)
  local arm = bandit:select()
  bandit:update(arm, 0.8)
  print("lurek.ai.newBandit: ok=" .. tostring(bandit ~= nil))
  print("lurek.ai.newBandit: arms=" .. tostring(bandit:armCount()))
end

--@api-stub: lurek.ai.newNeuroevolution
do
  local layers = {
    { inputs = 3, outputs = 6, activation = "relu" },
    { inputs = 6, outputs = 2, activation = "softmax" },
  }
  local ne = lurek.ai.newNeuroevolution(layers, 8, 1)
  print("lurek.ai.newNeuroevolution: ok=" .. tostring(ne ~= nil))
  print("lurek.ai.newNeuroevolution: pop=" .. tostring(ne:popSize()))
end

--@api-stub: lurek.ai.newStrategyAI
do
  local strat = lurek.ai.newStrategyAI(3.0)
  strat:addGoal("expand")
  strat:addTag("economy")
  print("lurek.ai.newStrategyAI: ok=" .. tostring(strat ~= nil))
  print("lurek.ai.newStrategyAI: next_eval=" .. tostring(strat:timeUntilNext()))
end

--@api-stub: lurek.ai.newAILod
do
  local lod = lurek.ai.newAILod()
  print("lurek.ai.newAILod: ok=" .. tostring(lod ~= nil))
  print("lurek.ai.newAILod: tiers=" .. tostring(lod:tierCount()))
end

--@api-stub: LAIWorld:addAgent
do
  local world = lurek.ai.newWorld()
  local archer = world:addAgent("archer_01")
  print("LAIWorld:addAgent: name=" .. archer:getName())
end

--@api-stub: LAIWorld:getAgent
do
  local world = lurek.ai.newWorld()
  world:addAgent("scout_01")
  local found = world:getAgent("scout_01")
  print("LAIWorld:getAgent: found=" .. tostring(found ~= nil))
end

--@api-stub: LAIWorld:removeAgent
do
  local world = lurek.ai.newWorld()
  local temp = world:addAgent("temp_npc")
  world:removeAgent(temp)
  print("LAIWorld:removeAgent: removed")
end

--@api-stub: LAIWorld:getAgentCount
do
  local world = lurek.ai.newWorld()
  world:addAgent("unit_a")
  world:addAgent("unit_b")
  world:addAgent("unit_c")
  local count = world:getAgentCount()
  print("LAIWorld:getAgentCount: " .. tostring(count))
end

--@api-stub: LAIWorld:getGlobalBlackboard
do
  local world = lurek.ai.newWorld()
  local gb = world:getGlobalBlackboard()
  gb:setString("weather", "rain")
  print("LAIWorld:getGlobalBlackboard: ok=" .. tostring(gb ~= nil))
  print("LAIWorld:getGlobalBlackboard: weather=" .. gb:getString("weather", "none"))
end

--@api-stub: LAIWorld:update
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("worker")
  npc:setDecisionModel("custom")
  local ticked = false
  npc:setCustomModel(function(agent, blackboard, dt) ticked = true end)
  world:update(1 / 60)
  print("LAIWorld:update: ticked=" .. tostring(ticked))
end

--@api-stub: LAIWorld:type
do
  local world = lurek.ai.newWorld()
  local t = world:type()
  local ok = world:typeOf("LAIWorld")
  print("LAIWorld:type: " .. t)
  print("LAIWorld:type: matches=" .. tostring(ok))
end

--@api-stub: LAIWorld:typeOf
do
  local world = lurek.ai.newWorld()
  local is_world = world:typeOf("LAIWorld")
  local is_wrong = world:typeOf("LImage")
  print("LAIWorld:typeOf: LAIWorld=" .. tostring(is_world) .. " LImage=" .. tostring(is_wrong))
end

--@api-stub: LAgent:getName
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("knight_03")
  local name = npc:getName()
  print("LAgent:getName: " .. name)
end

--@api-stub: LAgent:setPosition
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("mover")
  npc:setPosition(256, 128)
  local x, y = npc:getPosition()
  print("LAgent:setPosition: done")
  print("LAgent:setPosition: pos=" .. tostring(x) .. ", " .. tostring(y))
end

--@api-stub: LAgent:getPosition
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("static_guard")
  npc:setPosition(400, 300)
  local x, y = npc:getPosition()
  print("LAgent:getPosition: " .. tostring(x) .. ", " .. tostring(y))
end

--@api-stub: LAgent:setVelocity
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("runner")
  npc:setVelocity(60, -30)
  local vx, vy = npc:getVelocity()
  print("LAgent:setVelocity: done")
  print("LAgent:setVelocity: vel=" .. tostring(vx) .. ", " .. tostring(vy))
end

--@api-stub: LAgent:getVelocity
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("idle_npc")
  npc:setVelocity(0, 0)
  local vx, vy = npc:getVelocity()
  print("LAgent:getVelocity: vx=" .. tostring(vx) .. " vy=" .. tostring(vy))
end

--@api-stub: LAgent:setMaxSpeed
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("sprinter")
  npc:setMaxSpeed(200)
  print("LAgent:setMaxSpeed: done")
  print("LAgent:setMaxSpeed: speed=" .. tostring(npc:getMaxSpeed()))
end

--@api-stub: LAgent:getMaxSpeed
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("courier")
  npc:setMaxSpeed(150)
  local speed = npc:getMaxSpeed()
  print("LAgent:getMaxSpeed: " .. tostring(speed))
  print("LAgent:getMaxSpeed: name=" .. npc:getName())
end

--@api-stub: LAgent:setMaxForce
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("tank")
  npc:setMaxForce(80)
  print("LAgent:setMaxForce: done")
  print("LAgent:setMaxForce: force=" .. tostring(npc:getMaxForce()))
end

--@api-stub: LAgent:getMaxForce
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("scout")
  npc:setMaxForce(200)
  local force = npc:getMaxForce()
  print("LAgent:getMaxForce: " .. tostring(force))
  print("LAgent:getMaxForce: name=" .. npc:getName())
end

--@api-stub: LAgent:setPriority
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("captain")
  npc:setPriority(10)
  print("LAgent:setPriority: " .. tostring(npc:getPriority()))
end

--@api-stub: LAgent:getPriority
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("grunt")
  npc:setPriority(5)
  local prio = npc:getPriority()
  print("LAgent:getPriority: " .. tostring(prio))
end

--@api-stub: LAgent:setDecisionModel
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("worker")
  npc:setDecisionModel("custom")
  local model = npc:getDecisionModel()
  print("LAgent:setDecisionModel: " .. model)
end

--@api-stub: LAgent:getDecisionModel
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("farmer")
  npc:setDecisionModel("custom")
  local model = npc:getDecisionModel()
  print("LAgent:getDecisionModel: " .. model)
end

--@api-stub: LAgent:setCustomModel
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("thinker")
  npc:setDecisionModel("custom")
  local called_with_dt = 0
  npc:setCustomModel(function(agent, bb, dt) called_with_dt = dt end)
  world:update(0.016)
  print("LAgent:setCustomModel: dt=" .. tostring(called_with_dt))
end

--@api-stub: LAgent:addTag
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("guard")
  npc:addTag("hostile")
  local has_hostile = npc:hasTag("hostile")
  print("LAgent:addTag: hostile=" .. tostring(has_hostile))
end

--@api-stub: LAgent:removeTag
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("spy")
  npc:addTag("visible")
  npc:removeTag("visible")
  local still_has = npc:hasTag("visible")
  print("LAgent:removeTag: visible=" .. tostring(still_has))
end

--@api-stub: LAgent:hasTag
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("merchant")
  npc:addTag("friendly")
  local friendly = npc:hasTag("friendly")
  local hostile = npc:hasTag("hostile")
  print("LAgent:hasTag: friendly=" .. tostring(friendly) .. " hostile=" .. tostring(hostile))
end

--@api-stub: LAgent:getBlackboard
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("ranger")
  local bb = npc:getBlackboard()
  bb:setNumber("hp", 100)
  local hp = bb:getNumber("hp", 0)
  print("LAgent:getBlackboard: hp=" .. tostring(hp))
end

--@api-stub: LAgent:type
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("villager")
  local t = npc:type()
  print("LAgent:type: " .. t)
  print("LAgent:type: matches=" .. tostring(npc:typeOf("LAgent")))
end

--@api-stub: LAgent:typeOf
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("knight")
  local is_agent = npc:typeOf("LAgent")
  local is_image = npc:typeOf("LImage")
  print("LAgent:typeOf: LAgent=" .. tostring(is_agent) .. " LImage=" .. tostring(is_image))
end

--@api-stub: LAIBlackboard:setNumber
do
  local bb = lurek.ai.newBlackboard()
  bb:setNumber("distance", 42.5)
  bb:setNumber("ammo", 30)
  local dist = bb:getNumber("distance", 0)
  print("LAIBlackboard:setNumber: distance=" .. tostring(dist))
end

--@api-stub: LAIBlackboard:getNumber
do
  local bb = lurek.ai.newBlackboard()
  bb:setNumber("score", 95.5)
  local score = bb:getNumber("score", 0)
  local missing = bb:getNumber("nonexistent", -1)
  print("LAIBlackboard:getNumber: score=" .. tostring(score) .. " missing=" .. tostring(missing))
end

--@api-stub: LAIBlackboard:setBool
do
  local bb = lurek.ai.newBlackboard()
  bb:setBool("can_attack", true)
  bb:setBool("is_hiding", false)
  local attack = bb:getBool("can_attack", false)
  print("LAIBlackboard:setBool: can_attack=" .. tostring(attack))
end

--@api-stub: LAIBlackboard:getBool
do
  local bb = lurek.ai.newBlackboard()
  bb:setBool("alert", true)
  local alert = bb:getBool("alert", false)
  local calm = bb:getBool("calm", true)
  print("LAIBlackboard:getBool: alert=" .. tostring(alert) .. " calm=" .. tostring(calm))
end

--@api-stub: LAIBlackboard:setString
do
  local bb = lurek.ai.newBlackboard()
  bb:setString("target_name", "dragon")
  bb:setString("current_zone", "forest")
  local target = bb:getString("target_name", "none")
  print("LAIBlackboard:setString: target=" .. target)
end

--@api-stub: LAIBlackboard:getString
do
  local bb = lurek.ai.newBlackboard()
  bb:setString("weapon", "sword")
  local weapon = bb:getString("weapon", "fists")
  local shield = bb:getString("shield", "none")
  print("LAIBlackboard:getString: weapon=" .. weapon .. " shield=" .. shield)
end

--@api-stub: LAIBlackboard:has
do
  local bb = lurek.ai.newBlackboard()
  bb:setNumber("hp", 80)
  local has_hp = bb:has("hp")
  local has_mp = bb:has("mp")
  print("LAIBlackboard:has: hp=" .. tostring(has_hp) .. " mp=" .. tostring(has_mp))
end

--@api-stub: LAIBlackboard:remove
do
  local bb = lurek.ai.newBlackboard()
  bb:setNumber("temp", 99)
  bb:remove("temp")
  local still_has = bb:has("temp")
  print("LAIBlackboard:remove: has_temp=" .. tostring(still_has))
end

--@api-stub: LAIBlackboard:clear
do
  local bb = lurek.ai.newBlackboard()
  bb:setNumber("a", 1)
  bb:setString("b", "x")
  bb:setBool("c", true)
  bb:clear()
  local size = bb:getSize()
  print("LAIBlackboard:clear: size=" .. tostring(size))
end

--@api-stub: LAIBlackboard:getKeys
do
  local bb = lurek.ai.newBlackboard()
  bb:setNumber("hp", 100)
  bb:setString("state", "idle")
  local keys = bb:getKeys()
  print("LAIBlackboard:getKeys: count=" .. tostring(#keys))
end

--@api-stub: LAIBlackboard:getSize
do
  local bb = lurek.ai.newBlackboard()
  bb:setNumber("hp", 10)
  bb:setString("name", "test")
  local size = bb:getSize()
  print("LAIBlackboard:getSize: " .. tostring(size))
end

--@api-stub: LAIBlackboard:type
do
  local bb = lurek.ai.newBlackboard()
  local t = bb:type()
  print("LAIBlackboard:type: " .. t)
  print("LAIBlackboard:type: matches=" .. tostring(bb:typeOf("LAIBlackboard")))
end

--@api-stub: LAIBlackboard:typeOf
do
  local bb = lurek.ai.newBlackboard()
  local is_bb = bb:typeOf("LAIBlackboard")
  local is_agent = bb:typeOf("LAgent")
  print("LAIBlackboard:typeOf: LAIBlackboard=" .. tostring(is_bb) .. " LAgent=" .. tostring(is_agent))
end

--@api-stub: LStateMachine:addState
do
  local fsm = lurek.ai.newStateMachine()
  local entered = ""
  fsm:addState("patrol", { onEnter = function() entered = "patrol" end })
  fsm:setInitialState("patrol")
  print("LStateMachine:addState: entered=" .. entered)
end

--@api-stub: LStateMachine:addTransition
do
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("idle", {})
  fsm:addState("alert", {})
  fsm:addTransition("idle", "alert", function() return true end, 1)
  print("LStateMachine:addTransition: configured")
end

--@api-stub: LStateMachine:setInitialState
do
  local fsm = lurek.ai.newStateMachine()
  local log = ""
  fsm:addState("sleep", { onEnter = function() log = "entered_sleep" end })
  fsm:setInitialState("sleep")
  local current = fsm:getCurrentState() or "none"
  print("LStateMachine:setInitialState: " .. current .. " log=" .. log)
end

--@api-stub: LStateMachine:getCurrentState
do
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("wander", {})
  local before = fsm:getCurrentState()
  fsm:setInitialState("wander")
  local after = fsm:getCurrentState()
  print("LStateMachine:getCurrentState: before=" .. tostring(before) .. " after=" .. tostring(after))
end

--@api-stub: LStateMachine:forceState
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
do
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("cooking", {})
  fsm:setInitialState("cooking")
  local time_in = fsm:getTimeInState()
  print("LStateMachine:getTimeInState: " .. tostring(time_in))
end

--@api-stub: LStateMachine:type
do
  local fsm = lurek.ai.newStateMachine()
  local t = fsm:type()
  print("LStateMachine:type: " .. t)
  print("LStateMachine:type: matches=" .. tostring(fsm:typeOf("LStateMachine")))
end

--@api-stub: LStateMachine:typeOf
do
  local fsm = lurek.ai.newStateMachine()
  local is_fsm = fsm:typeOf("LStateMachine")
  local is_other = fsm:typeOf("LBehaviorTree")
  print("LStateMachine:typeOf: LStateMachine=" .. tostring(is_fsm) .. " LBehaviorTree=" .. tostring(is_other))
end

--@api-stub: LBehaviorTree:getLastStatus
do
  local bt = lurek.ai.newBehaviorTree()
  bt:setRoot(lurek.ai.newAction(function() return "success" end))
  local status = bt:getLastStatus()
  print("LBehaviorTree:getLastStatus: " .. status)
end

--@api-stub: LBehaviorTree:getDebugState
do
  local bt = lurek.ai.newBehaviorTree()
  bt:setRoot(lurek.ai.newAction(function() return "success" end))
  local info = bt:getDebugState()
  print("LBehaviorTree:getDebugState: node_count=" .. tostring(info.node_count))
  print("LBehaviorTree:getDebugState: last_status=" .. tostring(info.last_status))
end

--@api-stub: LBehaviorTree:type
do
  local bt = lurek.ai.newBehaviorTree()
  local t = bt:type()
  print("LBehaviorTree:type: " .. t)
  print("LBehaviorTree:type: matches=" .. tostring(bt:typeOf("LBehaviorTree")))
end

--@api-stub: LBehaviorTree:typeOf
do
  local bt = lurek.ai.newBehaviorTree()
  local is_bt = bt:typeOf("LBehaviorTree")
  local is_other = bt:typeOf("LAgent")
  print("LBehaviorTree:typeOf: LBehaviorTree=" .. tostring(is_bt) .. " LAgent=" .. tostring(is_other))
end

--@api-stub: LBTNode:addChild
do
  local seq = lurek.ai.newSequence()
  seq:addChild(lurek.ai.newAction(function() return "success" end))
  local count = seq:getChildCount()
  print("LBTNode:addChild: children=" .. tostring(count))
end

--@api-stub: LBTNode:getChildCount
do
  local sel = lurek.ai.newSelector()
  sel:addChild(lurek.ai.newAction(function() return "success" end))
  local count = sel:getChildCount()
  print("LBTNode:getChildCount: " .. tostring(count))
end

--@api-stub: LBTNode:reset
do
  local seq = lurek.ai.newSequence()
  seq:addChild(lurek.ai.newAction(function() return "running" end))
  seq:reset()
  print("LBTNode:reset: done")
end

--@api-stub: LBTNode:setChild
do
  local inv = lurek.ai.newInverter()
  inv:setChild(lurek.ai.newAction(function() return "failure" end))
  print("LBTNode:setChild: configured")
  print("LBTNode:setChild: type=" .. inv:getNodeType())
end

--@api-stub: LBTNode:setCount
do
  local rep = lurek.ai.newRepeater(3)
  rep:setCount(10)
  local count = rep:getCount()
  print("LBTNode:setCount: " .. tostring(count))
end

--@api-stub: LBTNode:getCount
do
  local rep = lurek.ai.newRepeater(7)
  local count = rep:getCount()
  print("LBTNode:getCount: " .. tostring(count))
end

--@api-stub: LBTNode:setSuccessPolicy
do
  local par = lurek.ai.newParallel("requireAll", "requireOne")
  par:setSuccessPolicy("requireOne")
  print("LBTNode:setSuccessPolicy: done")
  print("LBTNode:setSuccessPolicy: type=" .. par:getNodeType())
end

--@api-stub: LBTNode:setFailurePolicy
do
  local par = lurek.ai.newParallel("requireOne", "requireAll")
  par:setFailurePolicy("requireOne")
  print("LBTNode:setFailurePolicy: done")
  print("LBTNode:setFailurePolicy: type=" .. par:getNodeType())
end

--@api-stub: LBTNode:getNodeType
do
  local act = lurek.ai.newAction(function() return "success" end)
  print("LBTNode:getNodeType: " .. act:getNodeType())
end

--@api-stub: LBTNode:type
do
  local node = lurek.ai.newAction(function() return "success" end)
  local t = node:type()
  print("LBTNode:type: " .. t)
  print("LBTNode:type: matches=" .. tostring(node:typeOf("LBTNode")))
end

--@api-stub: LBTNode:typeOf
do
  local node = lurek.ai.newSelector()
  local is_node = node:typeOf("LBTNode")
  local is_other = node:typeOf("LImage")
  print("LBTNode:typeOf: LBTNode=" .. tostring(is_node) .. " LImage=" .. tostring(is_other))
end

--@api-stub: LSteeringManager:addSeek
do
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(400, 300, 1.0)
  local fx, fy = steer:calculate(50, 50, 0, 0, 100, 200, 1 / 60)
  print("LSteeringManager:addSeek: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end

--@api-stub: LSteeringManager:addFlee
do
  local steer = lurek.ai.newSteeringManager()
  steer:addFlee(200, 200, 1.0)
  local fx, fy = steer:calculate(210, 195, 0, 0, 100, 200, 1 / 60)
  print("LSteeringManager:addFlee: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end

--@api-stub: LSteeringManager:addArrive
do
  local steer = lurek.ai.newSteeringManager()
  steer:addArrive(300, 300, 50, 1.0)
  local fx, fy = steer:calculate(280, 290, 30, 10, 100, 200, 1 / 60)
  print("LSteeringManager:addArrive: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end

--@api-stub: LSteeringManager:addWander
do
  local steer = lurek.ai.newSteeringManager()
  steer:addWander(25, 50, 8, 0.5)
  local fx, fy = steer:calculate(100, 100, 10, 0, 80, 150, 1 / 60)
  print("LSteeringManager:addWander: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end

--@api-stub: LSteeringManager:addPursue
do
  local steer = lurek.ai.newSteeringManager()
  steer:addPursue("target_agent", 1.0)
  local count = steer:getBehaviorCount()
  print("LSteeringManager:addPursue: behaviors=" .. tostring(count))
end

--@api-stub: LSteeringManager:addEvade
do
  local steer = lurek.ai.newSteeringManager()
  steer:addEvade("enemy_agent", 1.0)
  local count = steer:getBehaviorCount()
  print("LSteeringManager:addEvade: behaviors=" .. tostring(count))
end

--@api-stub: LSteeringManager:addFlock
do
  local steer = lurek.ai.newSteeringManager()
  steer:addFlock(80, 1.5, 1.0, 1.0, 1.0)
  local count = steer:getBehaviorCount()
  print("LSteeringManager:addFlock: behaviors=" .. tostring(count))
end

--@api-stub: LSteeringManager:getBehaviorCount
do
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(100, 100, 1.0)
  steer:addWander(10, 20, 3, 0.5)
  local count = steer:getBehaviorCount()
  print("LSteeringManager:getBehaviorCount: " .. tostring(count))
end

--@api-stub: LSteeringManager:setCombineMode
do
  local steer = lurek.ai.newSteeringManager()
  steer:setCombineMode("priority")
  local mode = steer:getCombineMode()
  print("LSteeringManager:setCombineMode: " .. mode)
end

--@api-stub: LSteeringManager:getCombineMode
do
  local steer = lurek.ai.newSteeringManager()
  steer:setCombineMode("truncated")
  local mode = steer:getCombineMode()
  print("LSteeringManager:getCombineMode: " .. mode)
  print("LSteeringManager:getCombineMode: type=" .. steer:type())
end

--@api-stub: LSteeringManager:getLastSteering
do
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(200, 200, 1.0)
  steer:calculate(50, 50, 0, 0, 100, 200, 1 / 60)
  local lx, ly = steer:getLastSteering()
  print("LSteeringManager:getLastSteering: " .. tostring(lx) .. "," .. tostring(ly))
end

--@api-stub: LSteeringManager:calculate
do
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(500, 300, 1.0)
  steer:addWander(15, 30, 4, 0.3)
  local fx, fy = steer:calculate(100, 100, 20, 5, 150, 250, 1 / 60)
  print("LSteeringManager:calculate: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end

--@api-stub: LSteeringManager:setPath
do
  local steer = lurek.ai.newSteeringManager()
  local waypoints = {
    { x = 50, y = 50 },
    { x = 200, y = 80 },
    { x = 350, y = 200 },
    { x = 400, y = 400 },
  }
  steer:setPath(waypoints, 16.0, 1.0)
  local has = steer:hasPath()
  print("LSteeringManager:setPath: hasPath=" .. tostring(has))
end

--@api-stub: LSteeringManager:clearPath
do
  local steer = lurek.ai.newSteeringManager()
  steer:setPath({ { x = 10, y = 10 }, { x = 100, y = 100 } }, 8.0, 1.0)
  steer:clearPath()
  local has = steer:hasPath()
  print("LSteeringManager:clearPath: hasPath=" .. tostring(has))
end

--@api-stub: LSteeringManager:hasPath
do
  local steer = lurek.ai.newSteeringManager()
  local before = steer:hasPath()
  steer:setPath({ { x = 0, y = 0 }, { x = 50, y = 50 } }, 5.0, 1.0)
  local after = steer:hasPath()
  print("LSteeringManager:hasPath: before=" .. tostring(before) .. " after=" .. tostring(after))
end

--@api-stub: LSteeringManager:getPathProgress
do
  local steer = lurek.ai.newSteeringManager()
  steer:setPath({ { x = 0, y = 0 }, { x = 100, y = 50 }, { x = 200, y = 100 } }, 10.0, 1.0)
  local idx, total = steer:getPathProgress()
  print("LSteeringManager:getPathProgress: " .. tostring(idx) .. "/" .. tostring(total))
end

--@api-stub: LSteeringManager:type
do
  local steer = lurek.ai.newSteeringManager()
  local t = steer:type()
  print("LSteeringManager:type: " .. t)
  print("LSteeringManager:type: matches=" .. tostring(steer:typeOf("LSteeringManager")))
end

--@api-stub: LSteeringManager:typeOf
do
  local steer = lurek.ai.newSteeringManager()
  local is_steer = steer:typeOf("LSteeringManager")
  local is_other = steer:typeOf("LAgent")
  print("LSteeringManager:typeOf: LSteeringManager=" .. tostring(is_steer) .. " LAgent=" .. tostring(is_other))
end

--@api-stub: LSteeringManager:setSpatialHashCellSize
do
  local steer = lurek.ai.newSteeringManager()
  steer:setSpatialHashCellSize(32)
  print("LSteeringManager:setSpatialHashCellSize: done")
end

--@api-stub: LSteeringManager:enableSpatialHash
do
  local steer = lurek.ai.newSteeringManager()
  steer:enableSpatialHash(true)
  steer:setSpatialHashCellSize(48)
  print("LSteeringManager:enableSpatialHash: done")
end

--@api-stub: LSteeringManager:addCustomBehavior
do
  local steer = lurek.ai.newSteeringManager()
  steer:addCustomBehavior(function(agent, dt) return 50, 0 end, 0.8)
  local count = steer:getBehaviorCount()
  print("LSteeringManager:addCustomBehavior: behaviors=" .. tostring(count))
end

--@api-stub: LSteeringManager:applyCustomSteering
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("pusher")
  npc:setPosition(100, 100)
  local steer = lurek.ai.newSteeringManager()
  steer:addCustomBehavior(function(agent, dt) return 25, -10 end, 1.0)
  local fx, fy = steer:applyCustomSteering(npc, 1 / 60)
  print("LSteeringManager:applyCustomSteering: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end

--@api-stub: LDialogueAI:setFSMState
do
  local dlg = lurek.ai.newDialogueAI()
  dlg:addTopic("battle_cry", 0.5, "combat", nil, "cry_score")
  dlg:setFSMState("combat")
  dlg:setUtilityScore("cry_score", 0.8)
  local topic = dlg:selectTopic()
  print("LDialogueAI:setFSMState: topic=" .. tostring(topic))
end

--@api-stub: LDialogueAI:setBTStatus
do
  local dlg = lurek.ai.newDialogueAI()
  dlg:addTopic("victory", 0.6, nil, "success", "vic_score")
  dlg:setBTStatus("success")
  dlg:setUtilityScore("vic_score", 0.9)
  local topic = dlg:selectTopic()
  print("LDialogueAI:setBTStatus: topic=" .. tostring(topic))
end

--@api-stub: LDialogueAI:setUtilityScore
do
  local dlg = lurek.ai.newDialogueAI()
  dlg:addTopic("greeting", 0.3, nil, nil, "greet_val")
  dlg:addTopic("farewell", 0.3, nil, nil, "bye_val")
  dlg:setUtilityScore("greet_val", 0.2)
  dlg:setUtilityScore("bye_val", 0.9)
  local topic = dlg:selectTopic()
  print("LDialogueAI:setUtilityScore: topic=" .. tostring(topic))
end

--@api-stub: LDialogueAI:clearUtilityScores
do
  local dlg = lurek.ai.newDialogueAI()
  dlg:setUtilityScore("a", 1.0)
  dlg:setUtilityScore("b", 0.5)
  dlg:clearUtilityScores()
  print("LDialogueAI:clearUtilityScores: done")
end

--@api-stub: LDialogueAI:addTopic
do
  local dlg = lurek.ai.newDialogueAI()
  dlg:addTopic("weather_chat", 0.4, nil, nil, "chat_score")
  dlg:addTopic("combat_taunt", 0.3, "combat", "running", "taunt_score")
  local count = dlg:getTopicCount()
  print("LDialogueAI:addTopic: count=" .. tostring(count))
end

--@api-stub: LDialogueAI:addBranch
do
  local dlg = lurek.ai.newDialogueAI()
  dlg:addTopic("threat", 0.5, nil, nil, "threat_score")
  dlg:addBranch("threat", "mock", 0.4, nil, nil, "mock_score")
  dlg:addBranch("threat", "demand", 0.6, nil, nil, "demand_score")
  dlg:setUtilityScore("threat_score", 0.8)
  dlg:setUtilityScore("mock_score", 0.3)
  dlg:setUtilityScore("demand_score", 0.7)
  local topic = dlg:selectTopic()
  local branch = topic and dlg:selectBranch(topic) or nil
  print("LDialogueAI:addBranch: branch=" .. tostring(branch))
end

--@api-stub: LDialogueAI:selectTopic
do
  local dlg = lurek.ai.newDialogueAI()
  dlg:addTopic("joke", 0.2, nil, nil, "joke_v")
  dlg:addTopic("quest_hint", 0.8, nil, nil, "hint_v")
  dlg:setUtilityScore("joke_v", 0.5)
  dlg:setUtilityScore("hint_v", 0.9)
  local topic = dlg:selectTopic() or "none"
  print("LDialogueAI:selectTopic: " .. topic)
end

--@api-stub: LDialogueAI:selectBranch
do
  local dlg = lurek.ai.newDialogueAI()
  dlg:addTopic("trade", 0.5, nil, nil, "trade_v")
  dlg:addBranch("trade", "buy", 0.5, nil, nil, "buy_v")
  dlg:addBranch("trade", "sell", 0.5, nil, nil, "sell_v")
  dlg:setUtilityScore("trade_v", 1.0)
  dlg:setUtilityScore("buy_v", 0.3)
  dlg:setUtilityScore("sell_v", 0.7)
  local branch = dlg:selectBranch("trade") or "none"
  print("LDialogueAI:selectBranch: " .. branch)
end

--@api-stub: LDialogueAI:getTopicCount
do
  local dlg = lurek.ai.newDialogueAI()
  dlg:addTopic("a", 0.5, nil, nil, "a_v")
  dlg:addTopic("b", 0.3, nil, nil, "b_v")
  dlg:addTopic("c", 0.2, nil, nil, "c_v")
  local count = dlg:getTopicCount()
  print("LDialogueAI:getTopicCount: " .. tostring(count))
end

--@api-stub: LDialogueAI:type
do
  local dlg = lurek.ai.newDialogueAI()
  local t = dlg:type()
  print("LDialogueAI:type: " .. t)
  print("LDialogueAI:type: matches=" .. tostring(dlg:typeOf("LDialogueAI")))
end

--@api-stub: LDialogueAI:typeOf
do
  local dlg = lurek.ai.newDialogueAI()
  local is_dlg = dlg:typeOf("LDialogueAI")
  local is_other = dlg:typeOf("LQLearner")
  print("LDialogueAI:typeOf: LDialogueAI=" .. tostring(is_dlg) .. " LQLearner=" .. tostring(is_other))
end

--@api-stub: LQLearner:chooseAction
do
  local ql = lurek.ai.newQLearner(5, 3)
  ql:setExplorationRate(0.0)
  ql:setQValue(0, 1, 0.9)
  local action = ql:chooseAction(0)
  print("LQLearner:chooseAction: action=" .. tostring(action))
end

--@api-stub: LQLearner:bestAction
do
  local ql = lurek.ai.newQLearner(4, 3)
  ql:setQValue(2, 0, 0.3)
  ql:setQValue(2, 1, 0.8)
  ql:setQValue(2, 2, 0.5)
  local best = ql:bestAction(2)
  print("LQLearner:bestAction: " .. tostring(best))
end

--@api-stub: LQLearner:learn
do
  local ql = lurek.ai.newQLearner(3, 2)
  ql:setLearningRate(0.5)
  ql:setDiscountFactor(0.9)
  ql:learn(0, 0, 1.0, 1)
  local qval = ql:getQValue(0, 0)
  print("LQLearner:learn: Q(0,0)=" .. tostring(qval))
end

--@api-stub: LQLearner:getQValue
do
  local ql = lurek.ai.newQLearner(3, 2)
  ql:setQValue(1, 0, 0.75)
  local val = ql:getQValue(1, 0)
  local zero = ql:getQValue(1, 1)
  print("LQLearner:getQValue: (1,0)=" .. tostring(val) .. " (1,1)=" .. tostring(zero))
end

--@api-stub: LQLearner:setQValue
do
  local ql = lurek.ai.newQLearner(4, 2)
  ql:setQValue(0, 0, 0.5)
  ql:setQValue(0, 1, 0.9)
  local best = ql:bestAction(0)
  print("LQLearner:setQValue: best=" .. tostring(best))
end

--@api-stub: LQLearner:endEpisode
do
  local ql = lurek.ai.newQLearner(3, 2)
  ql:setExplorationRate(1.0)
  ql:setExplorationDecay(0.95)
  ql:endEpisode()
  local rate = ql:getExplorationRate()
  print("LQLearner:endEpisode: rate=" .. tostring(rate))
end

--@api-stub: LQLearner:getEpisodeCount
do
  local ql = lurek.ai.newQLearner(3, 2)
  ql:endEpisode()
  ql:endEpisode()
  ql:endEpisode()
  local episodes = ql:getEpisodeCount()
  print("LQLearner:getEpisodeCount: " .. tostring(episodes))
end

--@api-stub: LQLearner:getStateCount
do
  local ql = lurek.ai.newQLearner(8, 4)
  local states = ql:getStateCount()
  print("LQLearner:getStateCount: " .. tostring(states))
  print("LQLearner:getStateCount: actions=" .. tostring(ql:getActionCount()))
end

--@api-stub: LQLearner:getActionCount
do
  local ql = lurek.ai.newQLearner(8, 4)
  local actions = ql:getActionCount()
  print("LQLearner:getActionCount: " .. tostring(actions))
  print("LQLearner:getActionCount: states=" .. tostring(ql:getStateCount()))
end

--@api-stub: LQLearner:setLearningRate
do
  local ql = lurek.ai.newQLearner(3, 2)
  ql:setLearningRate(0.2)
  local rate = ql:getLearningRate()
  print("LQLearner:setLearningRate: " .. tostring(rate))
end

--@api-stub: LQLearner:getLearningRate
do
  local ql = lurek.ai.newQLearner(3, 2)
  ql:setLearningRate(0.15)
  local rate = ql:getLearningRate()
  print("LQLearner:getLearningRate: " .. tostring(rate))
end

--@api-stub: LQLearner:setDiscountFactor
do
  local ql = lurek.ai.newQLearner(3, 2)
  ql:setDiscountFactor(0.99)
  local gamma = ql:getDiscountFactor()
  print("LQLearner:setDiscountFactor: " .. tostring(gamma))
end

--@api-stub: LQLearner:getDiscountFactor
do
  local ql = lurek.ai.newQLearner(3, 2)
  ql:setDiscountFactor(0.9)
  local gamma = ql:getDiscountFactor()
  print("LQLearner:getDiscountFactor: " .. tostring(gamma))
end

--@api-stub: LQLearner:setExplorationRate
do
  local ql = lurek.ai.newQLearner(3, 2)
  ql:setExplorationRate(0.5)
  local rate = ql:getExplorationRate()
  print("LQLearner:setExplorationRate: " .. tostring(rate))
end

--@api-stub: LQLearner:getExplorationRate
do
  local ql = lurek.ai.newQLearner(3, 2)
  ql:setExplorationRate(0.3)
  local rate = ql:getExplorationRate()
  print("LQLearner:getExplorationRate: " .. tostring(rate))
end

--@api-stub: LQLearner:setExplorationDecay
do
  local ql = lurek.ai.newQLearner(3, 2)
  ql:setExplorationRate(1.0)
  ql:setExplorationDecay(0.9)
  ql:endEpisode()
  local rate = ql:getExplorationRate()
  print("LQLearner:setExplorationDecay: rate=" .. tostring(rate))
end

--- AI Examples Part 3: Q-Learning (cont.), Utility AI, GOAP, Influence Maps, Squads

--@api-stub: LQLearner:getExplorationDecay
do
    local ql = lurek.ai.newQLearner(4, 3)
    ql:setExplorationDecay(0.99)
    local decay = ql:getExplorationDecay()
    print("exploration decay = " .. decay)
end

--@api-stub: LQLearner:serialize
do
    local ql = lurek.ai.newQLearner(3, 2)
    ql:learn(1, 1, 1.0, 2)
    ql:learn(2, 2, 5.0, 1)
    local json = ql:serialize()
    print("serialized length = " .. #json)
end

--@api-stub: LQLearner:serialize.2
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
do
    local ql = lurek.ai.newQLearner(2, 2)
    local t = ql:type()
    print("type = " .. t)
  print("matches = " .. tostring(ql:typeOf("LQLearner")))
end

--@api-stub: LQLearner:typeOf
do
    local ql = lurek.ai.newQLearner(2, 2)
    local yes = ql:typeOf("LQLearner")
    local no = ql:typeOf("LAgent")
    print("is LQLearner = " .. tostring(yes) .. ", is LAgent = " .. tostring(no))
end

--@api-stub: LUtilityAI:addAction
do
    local uai = lurek.ai.newUtilityAI()
    uai:addAction("eat", function() return 0.8 end, 1.0)
    uai:addAction("sleep", function() return 0.3 end, 1.0)
    print("actions added = " .. uai:getActionCount())
end

--@api-stub: LUtilityAI:evaluate
do
    local uai = lurek.ai.newUtilityAI()
    uai:addAction("attack", function() return 0.9 end)
    uai:addAction("defend", function() return 0.4 end)
    local chosen = uai:evaluate()
    print("chosen action = " .. tostring(chosen))
end

--@api-stub: LUtilityAI:getActionCount
do
    local uai = lurek.ai.newUtilityAI()
    uai:addAction("patrol", function() return 0.5 end)
    uai:addAction("idle", function() return 0.1 end)
    uai:addAction("chase", function() return 0.7 end)
    print("action count = " .. uai:getActionCount())
end

--@api-stub: LUtilityAI:getLastAction
do
  local uai = lurek.ai.newUtilityAI()
  uai:addAction("gather", function() return 0.6 end)
    uai:addAction("build", function() return 0.2 end)
    uai:evaluate()
    local last = uai:getLastAction()
    print("last action = " .. tostring(last))
end

--@api-stub: LUtilityAI:addConsideration
do
    local uai = lurek.ai.newUtilityAI()
    uai:addAction("heal", function() return 0.5 end)
    uai:addConsideration("heal", "low_health", function() return 0.9 end, "linear", 1.0, 0.0, 0.0, 1.0)
    uai:evaluate()
    print("consideration added, last = " .. tostring(uai:getLastAction()))
end

--@api-stub: LUtilityAI:type
do
    local uai = lurek.ai.newUtilityAI()
    print("type = " .. uai:type())
  print("matches = " .. tostring(uai:typeOf("LUtilityAI")))
end

--@api-stub: LUtilityAI:typeOf
do
    local uai = lurek.ai.newUtilityAI()
    print("is LUtilityAI = " .. tostring(uai:typeOf("LUtilityAI")))
end

--@api-stub: LGOAPPlanner:addAction
do
    local goap = lurek.ai.newGOAPPlanner()
    goap:addAction("chop_wood", 2, function() print("  chopping wood") end)
    goap:addAction("build_house", 5, function() print("  building house") end)
    print("goap actions = " .. goap:getActionCount())
end

--@api-stub: LGOAPPlanner:setPrecondition
do
    local goap = lurek.ai.newGOAPPlanner()
    goap:addAction("cook", 1, function() end)
    goap:setPrecondition("cook", "has_food", true)
    print("precondition set for cook")
end

--@api-stub: LGOAPPlanner:setEffect
do
    local goap = lurek.ai.newGOAPPlanner()
    goap:addAction("mine_ore", 3, function() end)
    goap:setEffect("mine_ore", "has_ore", true)
    print("effect set for mine_ore")
end

--@api-stub: LGOAPPlanner:addGoal
do
    local goap = lurek.ai.newGOAPPlanner()
    goap:addGoal("survive", 10)
    goap:addGoal("explore", 3)
    print("goals = " .. goap:getGoalCount())
end

--@api-stub: LGOAPPlanner:setGoalState
do
    local goap = lurek.ai.newGOAPPlanner()
    goap:addGoal("build_shelter", 5)
    goap:setGoalState("build_shelter", "shelter_built", true)
    print("goal state set for build_shelter")
end

--@api-stub: LGOAPPlanner:plan
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
do
    local goap = lurek.ai.newGOAPPlanner()
    goap:addAction("a1", 1, function() end)
    goap:addAction("a2", 2, function() end)
    print("action count = " .. goap:getActionCount())
end

--@api-stub: LGOAPPlanner:getGoalCount
do
    local goap = lurek.ai.newGOAPPlanner()
    goap:addGoal("g1", 1)
    goap:addGoal("g2", 5)
    goap:addGoal("g3", 3)
    print("goal count = " .. goap:getGoalCount())
end

--@api-stub: LGOAPPlanner:getMaxIterations
do
    local goap = lurek.ai.newGOAPPlanner()
    local max = goap:getMaxIterations()
    print("default max iterations = " .. max)
end

--@api-stub: LGOAPPlanner:setMaxIterations
do
    local goap = lurek.ai.newGOAPPlanner()
    goap:setMaxIterations(500)
    print("max iterations = " .. goap:getMaxIterations())
end

--@api-stub: LGOAPPlanner:type
do
    local goap = lurek.ai.newGOAPPlanner()
    print("type = " .. goap:type())
  print("matches = " .. tostring(goap:typeOf("LGOAPPlanner")))
end

--@api-stub: LGOAPPlanner:typeOf
do
    local goap = lurek.ai.newGOAPPlanner()
    print("is LGOAPPlanner = " .. tostring(goap:typeOf("LGOAPPlanner")))
end

--@api-stub: LInfluenceMap:addLayer
do
    local im = lurek.ai.newInfluenceMap(16, 16, 1.0)
    im:addLayer("threat")
    im:addLayer("resources")
    print("layers added: threat, resources")
end

--@api-stub: LInfluenceMap:hasLayer
do
    local im = lurek.ai.newInfluenceMap(8, 8, 2.0)
    im:addLayer("heat")
    print("has heat = " .. tostring(im:hasLayer("heat")))
    print("has cold = " .. tostring(im:hasLayer("cold")))
end

--@api-stub: LInfluenceMap:setInfluence
do
    local im = lurek.ai.newInfluenceMap(10, 10, 1.0)
    im:addLayer("danger")
    im:setInfluence("danger", 5, 5, 1.0)
    im:setInfluence("danger", 3, 7, 0.5)
    print("set influence at (5,5) and (3,7)")
end

--@api-stub: LInfluenceMap:getInfluence
do
    local im = lurek.ai.newInfluenceMap(10, 10, 1.0)
    im:addLayer("food")
    im:setInfluence("food", 4, 4, 0.75)
    local val = im:getInfluence("food", 4, 4)
    print("food at (4,4) = " .. val)
end

--@api-stub: LInfluenceMap:stampInfluence
do
    local im = lurek.ai.newInfluenceMap(20, 20, 1.0)
    im:addLayer("noise")
    im:stampInfluence("noise", 10.0, 10.0, 3.0, 1.0, 0.5)
    local center = im:getInfluence("noise", 10, 10)
    print("noise center = " .. center)
end

--@api-stub: LInfluenceMap:propagate
do
  local im = lurek.ai.newInfluenceMap(10, 10, 1.0)
  im:addLayer("scent")
    im:setInfluence("scent", 5, 5, 1.0)
    im:propagate("scent", 0.8)
    local neighbor = im:getInfluence("scent", 4, 5)
    print("scent propagated to (4,5) = " .. neighbor)
end

--@api-stub: LInfluenceMap:decay
do
  local im = lurek.ai.newInfluenceMap(8, 8, 1.0)
  im:addLayer("heat")
    im:setInfluence("heat", 4, 4, 1.0)
    im:decay("heat", 0.5)
    local val = im:getInfluence("heat", 4, 4)
    print("heat after decay = " .. val)
end

--@api-stub: LInfluenceMap:clearLayer
do
  local im = lurek.ai.newInfluenceMap(8, 8, 1.0)
  im:addLayer("marks")
    im:setInfluence("marks", 2, 2, 1.0)
    im:clearLayer("marks")
    local val = im:getInfluence("marks", 2, 2)
    print("after clear = " .. val)
end

--@api-stub: LInfluenceMap:clearAll
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
do
  local im = lurek.ai.newInfluenceMap(10, 10, 1.0)
  im:addLayer("gold")
    im:setInfluence("gold", 7, 3, 0.9)
    im:setInfluence("gold", 2, 8, 0.4)
    local mx, my = im:getMaxPosition("gold")
    print("max gold at (" .. mx .. ", " .. my .. ")")
end

--@api-stub: LInfluenceMap:getMinPosition
do
  local im = lurek.ai.newInfluenceMap(10, 10, 1.0)
  im:addLayer("cold")
    im:setInfluence("cold", 1, 1, -0.5)
    im:setInfluence("cold", 5, 5, 0.3)
    local mx, my = im:getMinPosition("cold")
    print("min cold at (" .. mx .. ", " .. my .. ")")
end

--@api-stub: LInfluenceMap:queryRect
do
  local im = lurek.ai.newInfluenceMap(10, 10, 1.0)
  im:addLayer("energy")
    im:setInfluence("energy", 2, 2, 0.5)
    im:setInfluence("energy", 3, 3, 0.5)
    local total = im:queryRect("energy", 1, 1, 4, 4)
    print("energy in rect = " .. total)
end

--@api-stub: LInfluenceMap:blend
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
do
    local im = lurek.ai.newInfluenceMap(16, 12, 2.0)
    print("width = " .. im:getWidth())
end

--@api-stub: LInfluenceMap:getHeight
do
    local im = lurek.ai.newInfluenceMap(16, 12, 2.0)
    print("height = " .. im:getHeight())
end

--@api-stub: LInfluenceMap:getCellSize
do
    local im = lurek.ai.newInfluenceMap(8, 8, 2.5)
    print("cell size = " .. im:getCellSize())
end

--@api-stub: LInfluenceMap:type
do
    local im = lurek.ai.newInfluenceMap(4, 4, 1.0)
    print("type = " .. im:type())
  print("matches = " .. tostring(im:typeOf("LInfluenceMap")))
end

--@api-stub: LInfluenceMap:typeOf
do
    local im = lurek.ai.newInfluenceMap(4, 4, 1.0)
    print("is LInfluenceMap = " .. tostring(im:typeOf("LInfluenceMap")))
end

--@api-stub: LSquad:getName
do
    local sq = lurek.ai.newSquad("alpha")
    print("squad name = " .. sq:getName())
end

--@api-stub: LSquad:addMember
do
    local sq = lurek.ai.newSquad("bravo")
    sq:addMember("soldier_1")
    sq:addMember("soldier_2")
    print("members = " .. sq:getMemberCount())
end

--@api-stub: LSquad:removeMember
do
    local sq = lurek.ai.newSquad("charlie")
    sq:addMember("scout")
    sq:addMember("medic")
    sq:removeMember("scout")
    print("after remove = " .. sq:getMemberCount())
end

--@api-stub: LSquad:getMemberCount
do
    local sq = lurek.ai.newSquad("delta")
    sq:addMember("a")
    sq:addMember("b")
    sq:addMember("c")
    print("count = " .. sq:getMemberCount())
end

--@api-stub: LSquad:getMembers
do
    local sq = lurek.ai.newSquad("echo")
    sq:addMember("sniper")
    sq:addMember("heavy")
    local members = sq:getMembers()
    print("members: " .. table.concat(members, ", "))
end

--@api-stub: LSquad:setLeader
do
    local sq = lurek.ai.newSquad("foxtrot")
    sq:addMember("captain")
    sq:addMember("private")
    sq:setLeader("captain")
    print("leader = " .. sq:getLeader())
end

--@api-stub: LSquad:getLeader
do
    local sq = lurek.ai.newSquad("golf")
    sq:addMember("commander")
    sq:setLeader("commander")
    local leader = sq:getLeader()
    print("leader = " .. tostring(leader))
end

--@api-stub: LSquad:setFormation
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
do
    local sq = lurek.ai.newSquad("recon")
    sq:setFormation("line", 3.0)
    local f = sq:getFormation()
    print("formation = " .. f)
end

--@api-stub: LSquad:getFormationSpacing
do
    local sq = lurek.ai.newSquad("assault")
    sq:setFormation("wedge", 2.5)
    local s = sq:getFormationSpacing()
    print("spacing = " .. s)
end

--@api-stub: LSquad:getFormationPosition
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
do
    local sq = lurek.ai.newSquad("intel")
    local bb = sq:getBlackboard()
    bb:setNumber("threat_level", 3)
    print("squad bb threat = " .. bb:getNumber("threat_level"))
end

--@api-stub: LSquad:type
do
    local sq = lurek.ai.newSquad("test")
    print("type = " .. sq:type())
  print("matches = " .. tostring(sq:typeOf("LSquad")))
end

--@api-stub: LSquad:typeOf
do
    local sq = lurek.ai.newSquad("test2")
    print("is LSquad = " .. tostring(sq:typeOf("LSquad")))
end

--@api-stub: LCommandQueue:enqueue
do
    local cq = lurek.ai.newCommandQueue()
    cq:enqueue("move", function() print("  moving") end, { targetX = 10, targetY = 20 })
    cq:enqueue("attack", function() print("  attacking") end)
    print("queue size = " .. cq:getCount())
end

--@api-stub: LCommandQueue:pushFront
do
    local cq = lurek.ai.newCommandQueue()
    cq:enqueue("patrol", function() end)
    cq:pushFront("dodge", function() print("  dodging") end)
    print("next type = " .. cq:getCurrentType())
end

--@api-stub: LCommandQueue:replace
do
    local cq = lurek.ai.newCommandQueue()
    cq:enqueue("idle", function() end)
    cq:enqueue("gather", function() end)
    cq:replace("retreat", function() print("  retreating") end)
    print("after replace count = " .. cq:getCount())
end

--@api-stub: LCommandQueue:cancelCurrent
do
    local cq = lurek.ai.newCommandQueue()
    cq:enqueue("walk", function() end)
    cq:enqueue("talk", function() end)
    cq:cancelCurrent()
    print("after cancel, type = " .. tostring(cq:getCurrentType()))
end

--@api-stub: LCommandQueue:clear
do
    local cq = lurek.ai.newCommandQueue()
    cq:enqueue("a", function() end)
    cq:enqueue("b", function() end)
    cq:clear()
    print("after clear, empty = " .. tostring(cq:isEmpty()))
end

--@api-stub: LCommandQueue:getCount
do
    local cq = lurek.ai.newCommandQueue()
    cq:enqueue("x", function() end)
    cq:enqueue("y", function() end)
    cq:enqueue("z", function() end)
    print("count = " .. cq:getCount())
end

--@api-stub: LCommandQueue:isEmpty
do
    local cq = lurek.ai.newCommandQueue()
    print("empty initially = " .. tostring(cq:isEmpty()))
    cq:enqueue("step", function() end)
    print("empty after enqueue = " .. tostring(cq:isEmpty()))
end

--@api-stub: LCommandQueue:getCurrentType
do
    local cq = lurek.ai.newCommandQueue()
    cq:enqueue("harvest", function() end)
    print("current type = " .. tostring(cq:getCurrentType()))
end

--@api-stub: LCommandQueue:getCurrentTarget
do
    local cq = lurek.ai.newCommandQueue()
    cq:enqueue("go", function() end, { targetX = 5, targetY = 10 })
    local tgt = cq:getCurrentTarget()
    print("target = " .. tostring(tgt))
end

--@api-stub: LCommandQueue:type
do
    local cq = lurek.ai.newCommandQueue()
    print("type = " .. cq:type())
  print("matches = " .. tostring(cq:typeOf("LCommandQueue")))
end

--@api-stub: LCommandQueue:typeOf
do
    local cq = lurek.ai.newCommandQueue()
    print("is LCommandQueue = " .. tostring(cq:typeOf("LCommandQueue")))
end

--@api-stub: LTraitProfile:set
do
    local tp = lurek.ai.newTraitProfile()
    tp:set("courage", 0.7)
    tp:set("aggression", 0.3)
    print("courage = " .. tp:get("courage"))
end

--@api-stub: LTraitProfile:get
do
    local tp = lurek.ai.newTraitProfile()
    tp:set("speed", 1.0)
    tp:addModifier("speed", 0.5, 5.0, "buff")
    local effective = tp:get("speed")
    print("effective speed = " .. effective)
end

--@api-stub: LTraitProfile:getBase
do
    local tp = lurek.ai.newTraitProfile()
    tp:set("strength", 0.8)
    tp:addModifier("strength", 0.2, 10.0, "potion")
    print("base strength = " .. tp:getBase("strength"))
end

--@api-stub: LTraitProfile:addModifier
do
    local tp = lurek.ai.newTraitProfile()
    tp:set("defense", 0.5)
    tp:addModifier("defense", 0.3, 8.0, "shield_spell")
    print("defense with modifier = " .. tp:get("defense"))
end

--@api-stub: LTraitProfile:removeModifiers
do
  local tp = lurek.ai.newTraitProfile()
  tp:set("luck", 0.4)
    tp:addModifier("luck", 0.2, 10.0, "charm")
    tp:addModifier("luck", 0.1, 5.0, "charm")
    tp:removeModifiers("charm")
    print("luck after remove = " .. tp:get("luck"))
end

--@api-stub: LTraitProfile:update
do
    local tp = lurek.ai.newTraitProfile()
    tp:set("rage", 0.5)
    tp:addModifier("rage", 0.5, 2.0, "berserk")
    tp:update(3.0)
    print("rage after 3s = " .. tp:get("rage"))
end

--@api-stub: LTraitProfile:has
do
    local tp = lurek.ai.newTraitProfile()
    tp:set("wisdom", 0.6)
    print("has wisdom = " .. tostring(tp:has("wisdom")))
    print("has charm = " .. tostring(tp:has("charm")))
end

--@api-stub: LTraitProfile:traitCount
do
    local tp = lurek.ai.newTraitProfile()
    tp:set("a", 0.1)
    tp:set("b", 0.2)
    tp:set("c", 0.3)
    print("trait count = " .. tp:traitCount())
end

--@api-stub: LTraitProfile:archetype
do
  local tp = lurek.ai.newTraitProfile()
  tp:set("aggression", 0.9)
    tp:set("caution", 0.1)
    tp:set("curiosity", 0.4)
    local arch = tp:archetype() or "unknown"
    print("archetype = " .. arch)
end

--@api-stub: LTraitProfile:type
do
    local tp = lurek.ai.newTraitProfile()
    print("type = " .. tp:type())
  print("matches = " .. tostring(tp:typeOf("LTraitProfile")))
end

--@api-stub: LTraitProfile:typeOf
do
    local tp = lurek.ai.newTraitProfile()
    print("is LTraitProfile = " .. tostring(tp:typeOf("LTraitProfile")))
end

--@api-stub: LStimulusWorld:addVisual
do
    local sw = lurek.ai.newStimulusWorld()
    local id = sw:addVisual(100, 200, 0.8, 50.0, "enemy_spotted")
    print("visual stimulus id = " .. id)
end

--@api-stub: LStimulusWorld:addAuditory
do
    local sw = lurek.ai.newStimulusWorld()
    local id = sw:addAuditory(50, 80, 0.6, 30.0, 0.1, "footstep")
    print("auditory stimulus id = " .. id)
end

--@api-stub: LStimulusWorld:remove
do
    local sw = lurek.ai.newStimulusWorld()
    local id = sw:addVisual(10, 10, 1.0, 20.0, "flash")
    sw:remove(id)
    print("removed stimulus, count = " .. sw:count())
end

--@api-stub: LStimulusWorld:update
do
    local sw = lurek.ai.newStimulusWorld()
    sw:addAuditory(0, 0, 1.0, 10.0, 0.5, "bang")
    sw:update(5.0)
    print("after update, count = " .. sw:count())
end

--@api-stub: LStimulusWorld:count
do
    local sw = lurek.ai.newStimulusWorld()
    sw:addVisual(0, 0, 1.0, 10.0, "a")
    sw:addVisual(5, 5, 0.5, 8.0, "b")
    print("stimulus count = " .. sw:count())
end

--@api-stub: LStimulusWorld:clear
do
    local sw = lurek.ai.newStimulusWorld()
    sw:addVisual(0, 0, 1.0, 10.0, "x")
    sw:addAuditory(1, 1, 0.5, 5.0, 0.2, "y")
    sw:clear()
    print("after clear, count = " .. sw:count())
end

--@api-stub: LStimulusWorld:type
do
    local sw = lurek.ai.newStimulusWorld()
    print("type = " .. sw:type())
  print("matches = " .. tostring(sw:typeOf("LStimulusWorld")))
end

--@api-stub: LStimulusWorld:typeOf
do
    local sw = lurek.ai.newStimulusWorld()
    print("is LStimulusWorld = " .. tostring(sw:typeOf("LStimulusWorld")))
end

--@api-stub: LContextSteering:addSeekTarget
do
    local cs = lurek.ai.newContextSteering(8)
    cs:addSeekTarget(200, 150, 1.0)
    print("seek target added at (200, 150)")
end

--@api-stub: LContextSteering:addWander
do
    local cs = lurek.ai.newContextSteering(8)
    cs:addWander(0.3, 0.5)
    print("wander behavior added")
end

--@api-stub: LContextSteering:addAvoidPoint
do
    local cs = lurek.ai.newContextSteering(8)
    cs:addAvoidPoint(50, 50, 20.0, 1.5)
    print("avoid point at (50, 50) radius 20")
end

--@api-stub: LContextSteering:addAvoidBounds
do
    local cs = lurek.ai.newContextSteering(8)
    cs:addAvoidBounds(0, 0, 800, 600, 30.0, 1.0)
    print("avoid bounds set for 800x600 area")
end

--@api-stub: LContextSteering:clearBehaviors
do
    local cs = lurek.ai.newContextSteering(8)
    cs:addSeekTarget(100, 100, 1.0)
    cs:addAvoidPoint(50, 50, 10.0, 1.0)
    cs:clearBehaviors()
    print("behaviors cleared")
end

--@api-stub: LContextSteering:evaluate
do
    local cs = lurek.ai.newContextSteering(8)
    cs:addSeekTarget(300, 200, 1.0)
    cs:addAvoidPoint(150, 150, 30.0, 2.0)
    local dx, dy = cs:evaluate(100, 100, 1.0, 0.0)
    print("direction = " .. dx .. ", " .. dy)
end

--@api-stub: LContextSteering:chosenMagnitude
do
    local cs = lurek.ai.newContextSteering(8)
    cs:addSeekTarget(200, 200, 1.0)
    cs:evaluate(0, 0, 0, 0)
    local mag = cs:chosenMagnitude()
    print("magnitude = " .. mag)
end

--@api-stub: LContextSteering:slotCount
do
    local cs = lurek.ai.newContextSteering(16)
    print("slots = " .. cs:slotCount())
end

--@api-stub: LContextSteering:type
do
    local cs = lurek.ai.newContextSteering(8)
    print("type = " .. cs:type())
  print("matches = " .. tostring(cs:typeOf("LContextSteering")))
end

--@api-stub: LContextSteering:typeOf
do
    local cs = lurek.ai.newContextSteering(8)
    print("is LContextSteering = " .. tostring(cs:typeOf("LContextSteering")))
end

--@api-stub: LNeedSystem:addNeed
do
    local ns = lurek.ai.newNeedSystem()
    ns:addNeed("hunger", 0.1, 0.7, 2.0)
    ns:addNeed("thirst", 0.15, 0.6, 1.5)
    print("needs registered")
end

--@api-stub: LNeedSystem:update
do
    local ns = lurek.ai.newNeedSystem()
    ns:addNeed("fatigue", 0.05, 0.8, 1.0)
    ns:update(2.0)
    local urgent = ns:mostUrgent()
    print("most urgent after 2s = " .. tostring(urgent))
end

--@api-stub: LNeedSystem:mostUrgent
do
    local ns = lurek.ai.newNeedSystem()
    ns:addNeed("hunger", 0.5, 0.3, 2.0)
    ns:update(1.0)
    local name = ns:mostUrgent()
    print("most urgent = " .. tostring(name))
end

--@api-stub: LNeedSystem:satisfy
do
    local ns = lurek.ai.newNeedSystem()
    ns:addNeed("thirst", 0.2, 0.5, 1.5)
    ns:update(3.0)
    ns:satisfy("thirst", 0.8)
    print("thirst satisfied")
end

--- AI Examples Part 5: Need System (cont.), AI Director, HTN, MCTS, Emotion, ORCA, Neural Net, Genetic Algorithm

--@api-stub: LNeedSystem:valueOf
do
    local ns = lurek.ai.newNeedSystem()
    ns:addNeed("hunger", 0.1, 0.7, 2.0)
    ns:update(2.0)
    local val = ns:valueOf("hunger")
    print("hunger value = " .. val)
end

--@api-stub: LNeedSystem:type
do
    local ns = lurek.ai.newNeedSystem()
    print("type = " .. ns:type())
  print("matches = " .. tostring(ns:typeOf("LNeedSystem")))
end

--@api-stub: LNeedSystem:typeOf
do
    local ns = lurek.ai.newNeedSystem()
    print("is LNeedSystem = " .. tostring(ns:typeOf("LNeedSystem")))
end

--@api-stub: LAIDirector:pushEvent
do
    local dir = lurek.ai.newAIDirector()
    dir:pushEvent(0.5)
    dir:pushEvent(0.8)
    print("events pushed, tension = " .. dir:tension())
end

--@api-stub: LAIDirector:update
do
    local dir = lurek.ai.newAIDirector()
    dir:pushEvent(1.0)
    dir:update(2.0)
    print("phase after update = " .. dir:phase())
end

--@api-stub: LAIDirector:tension
do
    local dir = lurek.ai.newAIDirector()
    dir:setTension(0.6)
    print("tension = " .. dir:tension())
end

--@api-stub: LAIDirector:phase
do
    local dir = lurek.ai.newAIDirector()
    local p = dir:phase()
    print("initial phase = " .. p)
end

--@api-stub: LAIDirector:spawnRateFactor
do
    local dir = lurek.ai.newAIDirector()
    dir:setTension(0.9)
    dir:update(0.1)
    print("spawn rate factor = " .. dir:spawnRateFactor())
end

--@api-stub: LAIDirector:lootFactor
do
    local dir = lurek.ai.newAIDirector()
    dir:setTension(0.2)
    dir:update(0.1)
    print("loot factor = " .. dir:lootFactor())
end

--@api-stub: LAIDirector:ambientIntensity
do
    local dir = lurek.ai.newAIDirector()
    dir:setTension(0.7)
    dir:update(0.1)
    print("ambient intensity = " .. dir:ambientIntensity())
end

--@api-stub: LAIDirector:setTension
do
    local dir = lurek.ai.newAIDirector()
    dir:setTension(0.5)
    print("tension set to " .. dir:tension())
end

--@api-stub: LAIDirector:reset
do
    local dir = lurek.ai.newAIDirector()
    dir:setTension(0.9)
    dir:reset()
    print("after reset, tension = " .. dir:tension())
end

--@api-stub: LAIDirector:type
do
    local dir = lurek.ai.newAIDirector()
    print("type = " .. dir:type())
  print("matches = " .. tostring(dir:typeOf("LAIDirector")))
end

--@api-stub: LAIDirector:typeOf
do
    local dir = lurek.ai.newAIDirector()
    print("is LAIDirector = " .. tostring(dir:typeOf("LAIDirector")))
end

--@api-stub: LHTNDomain:addPrimitive
do
    local htn = lurek.ai.newHTNDomain()
    htn:addPrimitive("chop", { "has_axe" }, { "has_wood" }, {})
    htn:addPrimitive("build", { "has_wood" }, { "shelter_done" }, { "has_wood" })
    print("primitives = " .. htn:taskCount())
end

--@api-stub: LHTNDomain:addCompound
do
    local htn = lurek.ai.newHTNDomain()
    htn:addPrimitive("mine", {}, { "has_ore" }, {})
    htn:addPrimitive("smelt", { "has_ore" }, { "has_metal" }, { "has_ore" })
  htn:addCompound("get_metal", { { name = "mine_and_smelt", preconditions = {}, sub_tasks = { "mine", "smelt" } } })
  print("compound added, tasks = " .. htn:taskCount())
end

--@api-stub: LHTNDomain:plan
do
    local htn = lurek.ai.newHTNDomain()
    htn:addPrimitive("gather", {}, { "has_food" }, {})
    htn:addPrimitive("cook", { "has_food" }, { "meal_ready" }, { "has_food" })
  htn:addCompound("prepare_meal", { { name = "full_cook", preconditions = {}, sub_tasks = { "gather", "cook" } } })
  local plan = htn:plan("prepare_meal", { has_food = 0, meal_ready = 0 })
  if plan then
    print("plan size = " .. #plan)
    print("plan = " .. table.concat(plan, " -> "))
  end
end

--@api-stub: LHTNDomain:taskCount
do
    local htn = lurek.ai.newHTNDomain()
    htn:addPrimitive("a", {}, {}, {})
    htn:addPrimitive("b", {}, {}, {})
    print("task count = " .. htn:taskCount())
end

--@api-stub: LHTNDomain:type
do
    local htn = lurek.ai.newHTNDomain()
    print("type = " .. htn:type())
  print("matches = " .. tostring(htn:typeOf("LHTNDomain")))
end

--@api-stub: LHTNDomain:typeOf
do
    local htn = lurek.ai.newHTNDomain()
    print("is LHTNDomain = " .. tostring(htn:typeOf("LHTNDomain")))
end

--@api-stub: LMCTSEngine:search
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
do
    local mcts = lurek.ai.newMCTSEngine(50, 1.0, 5, 0)
    print("type = " .. mcts:type())
  print("matches = " .. tostring(mcts:typeOf("LMCTSEngine")))
end

--@api-stub: LMCTSEngine:typeOf
do
    local mcts = lurek.ai.newMCTSEngine(50, 1.0, 5, 0)
    print("is LMCTSEngine = " .. tostring(mcts:typeOf("LMCTSEngine")))
end

--@api-stub: LEmotionModel:add
do
    local em = lurek.ai.newEmotionModel()
    em:add("joy", 0.3, 0.1, 0.2)
    em:add("anger", 0.0, 0.05, 0.3)
    print("emotions registered")
end

--@api-stub: LEmotionModel:trigger
do
    local em = lurek.ai.newEmotionModel()
    em:add("fear", 0.0, 0.1, 0.2)
    em:trigger("fear", 0.7)
    print("fear = " .. em:get("fear"))
end

--@api-stub: LEmotionModel:get
do
    local em = lurek.ai.newEmotionModel()
    em:add("sadness", 0.2, 0.05, 0.1)
    em:trigger("sadness", 0.5)
    local val = em:get("sadness")
    print("sadness = " .. val)
end

--@api-stub: LEmotionModel:dominant
do
  local em = lurek.ai.newEmotionModel()
  em:add("joy", 0.0, 0.1, 0.1)
    em:add("anger", 0.0, 0.1, 0.1)
    em:trigger("joy", 0.3)
    em:trigger("anger", 0.8)
    print("dominant = " .. tostring(em:dominant()))
end

--@api-stub: LEmotionModel:isActive
do
  local em = lurek.ai.newEmotionModel()
  em:add("surprise", 0.0, 0.1, 0.5)
    em:trigger("surprise", 0.2)
    print("surprise active = " .. tostring(em:isActive("surprise")))
    em:trigger("surprise", 0.5)
    print("surprise active = " .. tostring(em:isActive("surprise")))
end

--@api-stub: LEmotionModel:update
do
    local em = lurek.ai.newEmotionModel()
    em:add("excitement", 0.0, 0.2, 0.1)
    em:trigger("excitement", 1.0)
    em:update(3.0)
    print("excitement after 3s = " .. em:get("excitement"))
end

--@api-stub: LEmotionModel:reset
do
    local em = lurek.ai.newEmotionModel()
    em:add("rage", 0.0, 0.1, 0.2)
    em:trigger("rage", 1.0)
    em:reset()
    print("rage after reset = " .. em:get("rage"))
end

--@api-stub: LEmotionModel:type
do
    local em = lurek.ai.newEmotionModel()
    print("type = " .. em:type())
  print("matches = " .. tostring(em:typeOf("LEmotionModel")))
end

--@api-stub: LEmotionModel:typeOf
do
    local em = lurek.ai.newEmotionModel()
    print("is LEmotionModel = " .. tostring(em:typeOf("LEmotionModel")))
end

--@api-stub: LORCASolver:addAgent
do
    local orca = lurek.ai.newORCASolver(2.0)
    local idx = orca:addAgent(10.0, 20.0, 0.5, 3.0)
    print("agent index = " .. idx)
end

--@api-stub: LORCASolver:setPreferredVelocity
do
    local orca = lurek.ai.newORCASolver(2.0)
    orca:addAgent(0, 0, 0.5, 5.0)
    orca:setPreferredVelocity(0, 2.0, 1.0)
    print("preferred velocity set for agent 0")
end

--@api-stub: LORCASolver:setPosition
do
    local orca = lurek.ai.newORCASolver(2.0)
    orca:addAgent(0, 0, 0.5, 5.0)
    orca:setPosition(0, 5.0, 3.0)
    print("position updated for agent 0")
end

--@api-stub: LORCASolver:compute
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
do
  local orca = lurek.ai.newORCASolver(1.5)
  orca:addAgent(0, 0, 0.5, 3.0)
    orca:setPreferredVelocity(0, 2.0, 0.0)
    orca:compute(0.016)
    local vx, vy = orca:getSafeVelocity(0)
    print("safe velocity = " .. vx .. ", " .. vy)
end

--@api-stub: LORCASolver:agentCount
do
    local orca = lurek.ai.newORCASolver(2.0)
    orca:addAgent(0, 0, 1.0, 2.0)
    orca:addAgent(5, 5, 1.0, 2.0)
    print("agent count = " .. orca:agentCount())
end

--@api-stub: LORCASolver:type
do
    local orca = lurek.ai.newORCASolver(1.0)
    print("type = " .. orca:type())
  print("matches = " .. tostring(orca:typeOf("LORCASolver")))
end

--@api-stub: LORCASolver:typeOf
do
    local orca = lurek.ai.newORCASolver(1.0)
    print("is LORCASolver = " .. tostring(orca:typeOf("LORCASolver")))
end

--@api-stub: LNeuralNet:addLayer
do
    local nn = lurek.ai.newNeuralNet()
    nn:addLayer(4, 8, "relu")
    nn:addLayer(8, 2, "sigmoid")
    print("layers = " .. nn:layerCount())
end

--@api-stub: LNeuralNet:forward
do
    local nn = lurek.ai.newNeuralNet()
    nn:addLayer(2, 3, "relu")
    nn:addLayer(3, 1, "sigmoid")
    local out = nn:forward({ 0.5, 0.8 })
    print("output[1] = " .. out[1])
end

--@api-stub: LNeuralNet:setWeights
do
  local nn = lurek.ai.newNeuralNet()
  nn:addLayer(2, 2, "relu")
  local count = nn:paramCount()
  local weights = {}
  for i = 1, count do
    weights[i] = 0.1 * i
  end
    nn:setWeights(weights)
    print("weights set, count = " .. count)
end

--@api-stub: LNeuralNet:getWeights
do
    local nn = lurek.ai.newNeuralNet()
    nn:addLayer(2, 2, "relu")
    local w = nn:getWeights()
    print("weight count = " .. #w)
end

--@api-stub: LNeuralNet:addLayer.5
do
    local nn = lurek.ai.newNeuralNet()
    nn:addLayer(3, 4, "relu")
    nn:addLayer(4, 1, "sigmoid")
    print("param count = " .. nn:paramCount())
end

--@api-stub: LNeuralNet:addLayer.6
do
    local nn = lurek.ai.newNeuralNet()
    nn:addLayer(5, 10, "relu")
    nn:addLayer(10, 5, "relu")
    nn:addLayer(5, 2, "sigmoid")
    print("layer count = " .. nn:layerCount())
end

--@api-stub: LNeuralNet:type
do
    local nn = lurek.ai.newNeuralNet()
    print("type = " .. nn:type())
  print("matches = " .. tostring(nn:typeOf("LNeuralNet")))
end

--@api-stub: LNeuralNet:typeOf
do
    local nn = lurek.ai.newNeuralNet()
    print("is LNeuralNet = " .. tostring(nn:typeOf("LNeuralNet")))
end

--@api-stub: LGeneticAlgorithm:setFitness
do
    local ga = lurek.ai.newGeneticAlgorithm(10, 5, 42)
  for i = 0, 9 do
    ga:setFitness(i, math.random())
  end
    ga:evolve()
    print("evolved to generation " .. ga:generation())
end

--@api-stub: LGeneticAlgorithm:generation
do
    local ga = lurek.ai.newGeneticAlgorithm(8, 4, 0)
    print("initial generation = " .. ga:generation())
  for i = 0, 7 do
    ga:setFitness(i, 1.0)
  end
    ga:evolve()
    print("after evolve = " .. ga:generation())
end

--- AI Examples Part 6: Genetic Algorithm (cont.), Bandit, Neuroevolution, Strategy AI, AI LOD

--@api-stub: LGeneticAlgorithm:popSize
do
    local ga = lurek.ai.newGeneticAlgorithm(20, 6, 99)
    print("pop size = " .. ga:popSize())
end

--@api-stub: LGeneticAlgorithm:setFitness.2
do
    local ga = lurek.ai.newGeneticAlgorithm(5, 3, 0)
    ga:setFitness(0, 10.0)
    ga:setFitness(1, 5.0)
    ga:setFitness(2, 8.0)
    print("fitness set for 3 chromosomes")
end

--@api-stub: LGeneticAlgorithm:getGenes
do
    local ga = lurek.ai.newGeneticAlgorithm(4, 3, 42)
    local genes = ga:getGenes(0)
    print("genes[0] length = " .. #genes)
end

--@api-stub: LGeneticAlgorithm:bestGenes
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
do
    local ga = lurek.ai.newGeneticAlgorithm(4, 2, 0)
    print("type = " .. ga:type())
  print("matches = " .. tostring(ga:typeOf("LGeneticAlgorithm")))
end

--@api-stub: LGeneticAlgorithm:typeOf
do
    local ga = lurek.ai.newGeneticAlgorithm(4, 2, 0)
    print("is LGeneticAlgorithm = " .. tostring(ga:typeOf("LGeneticAlgorithm")))
end

--@api-stub: LBandit:select
do
    local b = lurek.ai.newBandit(4, "epsilon_greedy", 0.1, 42)
    local arm = b:select()
    print("selected arm = " .. arm)
end

--@api-stub: LBandit:update.2
do
    local b = lurek.ai.newBandit(3, "ucb1", 0.0, 0)
    local arm = b:select()
    b:update(arm, 1.0)
    print("updated arm " .. arm .. " with reward 1.0")
end

--@api-stub: LBandit:update
do
    local b = lurek.ai.newBandit(3, "epsilon_greedy", 0.0, 10)
    b:update(0, 0.5)
    b:update(1, 0.9)
    b:update(2, 0.3)
    print("best arm = " .. b:bestArm())
end

--@api-stub: LBandit:reset
do
    local b = lurek.ai.newBandit(3, "epsilon_greedy", 0.1, 0)
    b:update(0, 1.0)
    b:update(1, 0.5)
    b:reset()
    print("total pulls after reset = " .. b:totalPulls())
end

--@api-stub: LBandit:armCount
do
    local b = lurek.ai.newBandit(5, "ucb1", 0.0, 0)
    print("arm count = " .. b:armCount())
end

--@api-stub: LBandit:select.3
do
    local b = lurek.ai.newBandit(3, "epsilon_greedy", 0.1, 0)
    b:select()
    b:select()
    b:select()
    print("total pulls = " .. b:totalPulls())
end

--@api-stub: LBandit:type
do
    local b = lurek.ai.newBandit(2, "ucb1", 0.0, 0)
    print("type = " .. b:type())
  print("matches = " .. tostring(b:typeOf("LBandit")))
end

--@api-stub: LBandit:typeOf
do
    local b = lurek.ai.newBandit(2, "ucb1", 0.0, 0)
    print("is LBandit = " .. tostring(b:typeOf("LBandit")))
end

--@api-stub: LNeuroevolution:setFitness
do
  local ne = lurek.ai.newNeuroevolution(
    {
      { inputs = 2, outputs = 3, activation = "relu" },
      { inputs = 3, outputs = 1, activation = "sigmoid" },
    },
    10,
    42
  )
  for i = 0, 9 do
    ne:setFitness(i, math.random())
  end
    ne:evolve()
    print("evolved to gen " .. ne:generation())
end

--@api-stub: LNeuroevolution:setFitness.2
do
  local ne = lurek.ai.newNeuroevolution({ { inputs = 2, outputs = 2 } }, 5, 0)
  ne:setFitness(0, 10.0)
    ne:setFitness(4, 5.0)
    print("fitness assigned to chromosomes 0 and 4")
end

--@api-stub: LNeuroevolution:chromosomeToNet
do
  local ne = lurek.ai.newNeuroevolution({ { inputs = 3, outputs = 2, activation = "relu" } }, 4, 7)
  local net = ne:chromosomeToNet(0)
  if net then
    print("network created from chromosome 0")
    print("network type = " .. net:type())
  end
end

--@api-stub: LNeuroevolution:bestNetwork
do
  local ne = lurek.ai.newNeuroevolution({ { inputs = 2, outputs = 1 } }, 6, 0)
  for i = 0, 5 do
    ne:setFitness(i, i * 1.5)
  end
    ne:evolve()
    local best = ne:bestNetwork()
    print("best network obtained = " .. tostring(best ~= nil))
end

--@api-stub: LNeuroevolution:setFitness.4
do
  local ne = lurek.ai.newNeuroevolution({ { inputs = 2, outputs = 1 } }, 4, 0)
  ne:setFitness(0, 3.0)
    ne:setFitness(1, 7.0)
    ne:setFitness(2, 5.0)
    ne:setFitness(3, 1.0)
    print("best fitness = " .. ne:bestFitness())
end

--@api-stub: LNeuroevolution:popSize
do
    local ne = lurek.ai.newNeuroevolution(
        { { inputs = 1, outputs = 1 } }, 12, 0
    )
    print("pop size = " .. ne:popSize())
end

--@api-stub: LNeuroevolution:generation
do
    local ne = lurek.ai.newNeuroevolution(
        { { inputs = 1, outputs = 1 } }, 4, 0
    )
    print("initial generation = " .. ne:generation())
end

--@api-stub: LNeuroevolution:type
do
    local ne = lurek.ai.newNeuroevolution(
        { { inputs = 1, outputs = 1 } }, 4, 0
    )
    print("type = " .. ne:type())
  print("matches = " .. tostring(ne:typeOf("LNeuroevolution")))
end

--@api-stub: LNeuroevolution:typeOf
do
    local ne = lurek.ai.newNeuroevolution(
        { { inputs = 1, outputs = 1 } }, 4, 0
    )
    print("is LNeuroevolution = " .. tostring(ne:typeOf("LNeuroevolution")))
end

--@api-stub: LStrategyAI:addGoal
do
    local strat = lurek.ai.newStrategyAI(5.0)
    strat:addGoal("expand")
    strat:addGoal("defend")
    strat:addGoal("research")
    print("goals registered")
end

--@api-stub: LStrategyAI:addTag
do
    local strat = lurek.ai.newStrategyAI(3.0)
    strat:addTag("war_declared")
    strat:addTag("low_resources")
    print("tags added")
end

--@api-stub: LStrategyAI:removeTag
do
    local strat = lurek.ai.newStrategyAI(3.0)
    strat:addTag("peace")
    strat:removeTag("peace")
    print("tag removed")
end

--@api-stub: LStrategyAI:update
do
    local strat = lurek.ai.newStrategyAI(1.0)
    strat:addGoal("attack")
    strat:addGoal("retreat")
    strat:update(1.5, function(goal) if goal == "attack" then return 0.8 end return 0.2 end)
    print("active = " .. tostring(strat:activeGoal()))
end

--@api-stub: LStrategyAI:forceEvaluate
do
    local strat = lurek.ai.newStrategyAI(10.0)
    strat:addGoal("build")
    strat:addGoal("scout")
    strat:forceEvaluate(function(goal) if goal == "scout" then return 5.0 end return 1.0 end)
    print("forced active = " .. tostring(strat:activeGoal()))
end

--@api-stub: LStrategyAI:activeGoal
do
    local strat = lurek.ai.newStrategyAI(1.0)
    strat:addGoal("idle")
    local active = strat:activeGoal()
    print("active goal = " .. tostring(active))
end

--@api-stub: LStrategyAI:timeUntilNext
do
    local strat = lurek.ai.newStrategyAI(5.0)
    strat:addGoal("wait")
    strat:update(2.0, function() return 1.0 end)
    print("time until next = " .. strat:timeUntilNext())
end

--@api-stub: LStrategyAI:type
do
    local strat = lurek.ai.newStrategyAI(1.0)
    print("type = " .. strat:type())
  print("matches = " .. tostring(strat:typeOf("LStrategyAI")))
end

--@api-stub: LStrategyAI:typeOf
do
    local strat = lurek.ai.newStrategyAI(1.0)
    print("is LStrategyAI = " .. tostring(strat:typeOf("LStrategyAI")))
end

--@api-stub: LAILod:tierFor
do
    local lod = lurek.ai.newAILod()
    local tier = lod:tierFor(100, 200, 0, 0)
    print("tier = " .. tier)
end

--@api-stub: LAILod:shouldUpdate
do
    local lod = lurek.ai.newAILod()
    local run = lod:shouldUpdate(0, 1)
    print("tier 0 should update on frame 1 = " .. tostring(run))
end

--@api-stub: LAILod:tierCount
do
    local lod = lurek.ai.newAILod()
    print("tier count = " .. lod:tierCount())
end

--@api-stub: LAILod:tierName
do
    local lod = lurek.ai.newAILod()
    local name = lod:tierName(0)
    print("tier 0 name = " .. name)
end

--@api-stub: LAILod:type
do
    local lod = lurek.ai.newAILod()
    print("type = " .. lod:type())
  print("matches = " .. tostring(lod:typeOf("LAILod")))
end

--@api-stub: LAILod:typeOf
do
    local lod = lurek.ai.newAILod()
    print("is LAILod = " .. tostring(lod:typeOf("LAILod")))
end
