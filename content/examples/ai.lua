-- content/examples/ai.lua
-- Auto-generated from content/examples2/ai_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/ai.lua

--@api: lurek.ai.newWorld
do
  local world = lurek.ai.newWorld()
  local scout = world:addAgent("scout_preview")
  local count = world:getAgentCount()
  print("lurek.ai.newWorld: agents=" .. tostring(count))
  print("lurek.ai.newWorld: first_agent=" .. scout:getName())
end

--@api: lurek.ai.newBlackboard
do
  local bb = lurek.ai.newBlackboard()
  bb:setString("state", "idle")
  print("lurek.ai.newBlackboard: state=" .. bb:getString("state", "none"))
end

--@api: lurek.ai.newStateMachine
do
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("idle", {})
  fsm:setInitialState("idle")
  print("lurek.ai.newStateMachine: ok=" .. tostring(fsm ~= nil))
  print("lurek.ai.newStateMachine: current=" .. tostring(fsm:getCurrentState()))
end

--@api: lurek.ai.newBehaviorTree
do
  local bt = lurek.ai.newBehaviorTree()
  bt:setRoot(lurek.ai.newAction(function() return "success" end))
  local info = bt:getDebugState()
  print("lurek.ai.newBehaviorTree: status=" .. tostring(bt:getLastStatus()))
  print("lurek.ai.newBehaviorTree: node_count=" .. tostring(info.node_count))
end

--@api: lurek.ai.newSelector
do
  local sel = lurek.ai.newSelector()
  sel:addChild(lurek.ai.newAction(function() return "failure" end))
  sel:addChild(lurek.ai.newAction(function() return "success" end))
  print("lurek.ai.newSelector: type=" .. sel:getNodeType())
  print("lurek.ai.newSelector: children=" .. tostring(sel:getChildCount()))
end

--@api: lurek.ai.newSequence
do
  local seq = lurek.ai.newSequence()
  seq:addChild(lurek.ai.newCondition(function() return true end))
  seq:addChild(lurek.ai.newAction(function() return "success" end))
  print("lurek.ai.newSequence: type=" .. seq:getNodeType())
  print("lurek.ai.newSequence: children=" .. tostring(seq:getChildCount()))
end

--@api: lurek.ai.newParallel
do
  local par = lurek.ai.newParallel("requireAll", "requireOne")
  par:addChild(lurek.ai.newAction(function() return "running" end))
  par:addChild(lurek.ai.newAction(function() return "success" end))
  print("lurek.ai.newParallel: type=" .. par:getNodeType())
  print("lurek.ai.newParallel: children=" .. tostring(par:getChildCount()))
end

--@api: lurek.ai.newInverter
do
  local inv = lurek.ai.newInverter()
  inv:setChild(lurek.ai.newCondition(function() return false end))
  print("lurek.ai.newInverter: type=" .. inv:getNodeType())
  print("lurek.ai.newInverter: child_count=" .. tostring(inv:getChildCount()))
end

--@api: lurek.ai.newRepeater
do
  local rep = lurek.ai.newRepeater(5)
  rep:setChild(lurek.ai.newAction(function() return "success" end))
  print("lurek.ai.newRepeater: count=" .. tostring(rep:getCount()))
  print("lurek.ai.newRepeater: type=" .. rep:getNodeType())
end

--@api: lurek.ai.newSucceeder
do
  local suc = lurek.ai.newSucceeder()
  suc:setChild(lurek.ai.newAction(function() return "failure" end))
  print("lurek.ai.newSucceeder: type=" .. suc:getNodeType())
  print("lurek.ai.newSucceeder: child_count=" .. tostring(suc:getChildCount()))
end

--@api: lurek.ai.newAction
do
  local act = lurek.ai.newAction(function() return "success" end)
  act:reset()
  print("lurek.ai.newAction: type=" .. act:getNodeType())
  print("lurek.ai.newAction: child_count=" .. tostring(act:getChildCount()))
end

--@api: lurek.ai.newCondition
do
  local cond = lurek.ai.newCondition(function() return true end)
  cond:reset()
  print("lurek.ai.newCondition: type=" .. cond:getNodeType())
  print("lurek.ai.newCondition: child_count=" .. tostring(cond:getChildCount()))
end

--@api: lurek.ai.newGuard
do
  local child_action = lurek.ai.newAction(function() return "success" end)
  local guard = lurek.ai.newGuard(function() return true end, child_action)
  print("lurek.ai.newGuard: node=" .. guard:getNodeType())
end

--@api: lurek.ai.newSteeringManager
do
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(320, 180, 1.0)
  print("lurek.ai.newSteeringManager: ok=" .. tostring(steer ~= nil))
  print("lurek.ai.newSteeringManager: behaviors=" .. tostring(steer:getBehaviorCount()))
end

--@api: lurek.ai.newQLearner
do
  local ql = lurek.ai.newQLearner(10, 4)
  ql:setQValue(1, 2, 0.75)
  print("lurek.ai.newQLearner: ok=" .. tostring(ql ~= nil))
  print("lurek.ai.newQLearner: best_action=" .. tostring(ql:bestAction(1)))
end

--@api: lurek.ai.newUtilityAI
do
  local util = lurek.ai.newUtilityAI()
  util:addAction("wait", function() return 0.2 end)
  util:addAction("attack", function() return 0.9 end)
  print("lurek.ai.newUtilityAI: ok=" .. tostring(util ~= nil))
  print("lurek.ai.newUtilityAI: pick=" .. tostring(util:evaluate()))
end

--@api: lurek.ai.newDialogueAI
do
  local dlg = lurek.ai.newDialogueAI()
  dlg:addTopic("greeting", 0.5, nil, nil, "greet_score")
  dlg:setUtilityScore("greet_score", 0.8)
  print("lurek.ai.newDialogueAI: ok=" .. tostring(dlg ~= nil))
  print("lurek.ai.newDialogueAI: topics=" .. tostring(dlg:getTopicCount()))
end

--@api: lurek.ai.newGOAPPlanner
do
  local goap = lurek.ai.newGOAPPlanner()
  goap:addGoal("stay_alive", 5)
  goap:setGoalState("stay_alive", "alive", true)
  print("lurek.ai.newGOAPPlanner: ok=" .. tostring(goap ~= nil))
  print("lurek.ai.newGOAPPlanner: goals=" .. tostring(goap:getGoalCount()))
end

--@api: lurek.ai.newInfluenceMap
do
  local imap = lurek.ai.newInfluenceMap(32, 32, 16)
  imap:addLayer("danger")
  imap:setInfluence("danger", 4, 5, 0.9)
  print("lurek.ai.newInfluenceMap: ok=" .. tostring(imap ~= nil))
  print("lurek.ai.newInfluenceMap: width=" .. tostring(imap:getWidth()))
end

--@api: lurek.ai.newSquad
do
  local squad = lurek.ai.newSquad("bravo")
  squad:addMember("leader")
  squad:setLeader("leader")
  print("lurek.ai.newSquad: name=" .. squad:getName())
  print("lurek.ai.newSquad: members=" .. tostring(squad:getMemberCount()))
end

--@api: lurek.ai.newCommandQueue
do
  local cq = lurek.ai.newCommandQueue()
  cq:enqueue("move", function() print("moving") end, { targetX = 32, targetY = 64 })
  print("lurek.ai.newCommandQueue: empty=" .. tostring(cq:isEmpty()))
  print("lurek.ai.newCommandQueue: count=" .. tostring(cq:getCount()))
end

--@api: lurek.ai.newTraitProfile
do
  local traits = lurek.ai.newTraitProfile()
  traits:set("courage", 0.7)
  print("lurek.ai.newTraitProfile: ok=" .. tostring(traits ~= nil))
  print("lurek.ai.newTraitProfile: courage=" .. tostring(traits:get("courage")))
end

--@api: lurek.ai.newStimulusWorld
do
  local sw = lurek.ai.newStimulusWorld()
  sw:addVisual(100, 150, 1.0, 48.0, "enemy")
  print("lurek.ai.newStimulusWorld: stimuli=" .. tostring(sw:count()))
  print("lurek.ai.newStimulusWorld: type=" .. sw:type())
end

--@api: lurek.ai.newContextSteering
do
  local cs = lurek.ai.newContextSteering(8)
  cs:addSeekTarget(256, 128, 1.0)
  local dx, dy = cs:evaluate(0, 0, 1, 0)
  print("lurek.ai.newContextSteering: ok=" .. tostring(cs ~= nil))
  print("lurek.ai.newContextSteering: dir=" .. tostring(dx) .. "," .. tostring(dy))
end

--@api: lurek.ai.newNeedSystem
do
  local needs = lurek.ai.newNeedSystem()
  needs:addNeed("hunger", 0.1, 0.7, 2.0)
  needs:update(2.0)
  print("lurek.ai.newNeedSystem: ok=" .. tostring(needs ~= nil))
  print("lurek.ai.newNeedSystem: urgent=" .. tostring(needs:mostUrgent()))
end

--@api: lurek.ai.newAIDirector
do
  local dir = lurek.ai.newAIDirector()
  dir:pushEvent(0.6)
  dir:update(1.0)
  print("lurek.ai.newAIDirector: ok=" .. tostring(dir ~= nil))
  print("lurek.ai.newAIDirector: phase=" .. dir:phase())
end

--@api: lurek.ai.newHTNDomain
do
  local htn = lurek.ai.newHTNDomain()
  print("lurek.ai.newHTNDomain: ok=" .. tostring(htn ~= nil))
  print("lurek.ai.newHTNDomain: tasks=" .. tostring(htn:taskCount()))
end

--@api: lurek.ai.newMCTSEngine
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

--@api: lurek.ai.newEmotionModel
do
  local emo = lurek.ai.newEmotionModel()
  emo:add("fear", 0.1, 0.2, 0.3)
  emo:trigger("fear", 0.5)
  print("lurek.ai.newEmotionModel: ok=" .. tostring(emo ~= nil))
  print("lurek.ai.newEmotionModel: dominant=" .. tostring(emo:dominant()))
end

--@api: lurek.ai.newORCASolver
do
  local orca = lurek.ai.newORCASolver(1.5)
  orca:addAgent(0, 0, 0.5, 3.0)
  print("lurek.ai.newORCASolver: ok=" .. tostring(orca ~= nil))
  print("lurek.ai.newORCASolver: agents=" .. tostring(orca:agentCount()))
end

--@api: lurek.ai.newNeuralNet
do
  local nn = lurek.ai.newNeuralNet()
  nn:addLayer(2, 3, "relu")
  nn:addLayer(3, 1, "linear")
  print("lurek.ai.newNeuralNet: ok=" .. tostring(nn ~= nil))
  print("lurek.ai.newNeuralNet: layers=" .. tostring(nn:layerCount()))
end

--@api: lurek.ai.newGeneticAlgorithm
do
  local ga = lurek.ai.newGeneticAlgorithm(8, 5, 7)
  print("lurek.ai.newGeneticAlgorithm: ok=" .. tostring(ga ~= nil))
  print("lurek.ai.newGeneticAlgorithm: pop=" .. tostring(ga:popSize()))
end

--@api: lurek.ai.newBandit
do
  local bandit = lurek.ai.newBandit(3, "ucb1", 0.15, 55)
  local arm = bandit:select()
  bandit:update(arm, 0.8)
  print("lurek.ai.newBandit: ok=" .. tostring(bandit ~= nil))
  print("lurek.ai.newBandit: arms=" .. tostring(bandit:armCount()))
end

--@api: lurek.ai.newNeuroevolution
do
  local layers = {
    { inputs = 3, outputs = 6, activation = "relu" },
    { inputs = 6, outputs = 2, activation = "softmax" },
  }
  local ne = lurek.ai.newNeuroevolution(layers, 8, 1)
  print("lurek.ai.newNeuroevolution: ok=" .. tostring(ne ~= nil))
  print("lurek.ai.newNeuroevolution: pop=" .. tostring(ne:popSize()))
end

--@api: lurek.ai.newStrategyAI
do
  local strat = lurek.ai.newStrategyAI(3.0)
  strat:addGoal("expand")
  strat:addTag("economy")
  print("lurek.ai.newStrategyAI: ok=" .. tostring(strat ~= nil))
  print("lurek.ai.newStrategyAI: next_eval=" .. tostring(strat:timeUntilNext()))
end

--@api: lurek.ai.newAILod
do
  local lod = lurek.ai.newAILod()
  print("lurek.ai.newAILod: ok=" .. tostring(lod ~= nil))
  print("lurek.ai.newAILod: tiers=" .. tostring(lod:tierCount()))
end

--@api: LAIWorld:addAgent
do
  local world = lurek.ai.newWorld()
  local archer = world:addAgent("archer_01")
  print("LAIWorld:addAgent: name=" .. archer:getName())
end

--@api: LAIWorld:getAgent
do
  local world = lurek.ai.newWorld()
  world:addAgent("scout_01")
  local found = world:getAgent("scout_01")
  print("LAIWorld:getAgent: found=" .. tostring(found ~= nil))
end

--@api: LAIWorld:removeAgent
do
  local world = lurek.ai.newWorld()
  local temp = world:addAgent("temp_npc")
  world:removeAgent(temp)
  print("LAIWorld:removeAgent: removed")
end

--@api: LAIWorld:getAgentCount
do
  local world = lurek.ai.newWorld()
  world:addAgent("unit_a")
  world:addAgent("unit_b")
  world:addAgent("unit_c")
  local count = world:getAgentCount()
  print("LAIWorld:getAgentCount: " .. tostring(count))
end

--@api: LAIWorld:getGlobalBlackboard
do
  local world = lurek.ai.newWorld()
  local gb = world:getGlobalBlackboard()
  gb:setString("weather", "rain")
  print("LAIWorld:getGlobalBlackboard: ok=" .. tostring(gb ~= nil))
  print("LAIWorld:getGlobalBlackboard: weather=" .. gb:getString("weather", "none"))
end

--@api: LAIWorld:update
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("worker")
  npc:setDecisionModel("custom")
  local ticked = false
  npc:setCustomModel(function(agent, blackboard, dt) ticked = true end)
  world:update(1 / 60)
  print("LAIWorld:update: ticked=" .. tostring(ticked))
end

--@api: LAIWorld:type
do
  local world = lurek.ai.newWorld()
  local t = world:type()
  local ok = world:typeOf("LAIWorld")
  print("LAIWorld:type: " .. t)
  print("LAIWorld:type: matches=" .. tostring(ok))
end

--@api: LAIWorld:typeOf
do
  local world = lurek.ai.newWorld()
  local is_world = world:typeOf("LAIWorld")
  local is_wrong = world:typeOf("LImage")
  print("LAIWorld:typeOf: LAIWorld=" .. tostring(is_world) .. " LImage=" .. tostring(is_wrong))
end

--@api: LBot:getName
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("knight_03")
  local name = npc:getName()
  print("LBot:getName: " .. name)
end

--@api: LBot:setPosition
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("mover")
  npc:setPosition(256, 128)
  local x, y = npc:getPosition()
  print("LBot:setPosition: done")
  print("LBot:setPosition: pos=" .. tostring(x) .. ", " .. tostring(y))
end

--@api: LBot:getPosition
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("static_guard")
  npc:setPosition(400, 300)
  local x, y = npc:getPosition()
  print("LBot:getPosition: " .. tostring(x) .. ", " .. tostring(y))
end

--@api: LBot:setVelocity
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("runner")
  npc:setVelocity(60, -30)
  local vx, vy = npc:getVelocity()
  print("LBot:setVelocity: done")
  print("LBot:setVelocity: vel=" .. tostring(vx) .. ", " .. tostring(vy))
end

--@api: LBot:getVelocity
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("idle_npc")
  npc:setVelocity(0, 0)
  local vx, vy = npc:getVelocity()
  print("LBot:getVelocity: vx=" .. tostring(vx) .. " vy=" .. tostring(vy))
end

--@api: LBot:setMaxSpeed
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("sprinter")
  npc:setMaxSpeed(200)
  print("LBot:setMaxSpeed: done")
  print("LBot:setMaxSpeed: speed=" .. tostring(npc:getMaxSpeed()))
end

--@api: LBot:getMaxSpeed
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("courier")
  npc:setMaxSpeed(150)
  local speed = npc:getMaxSpeed()
  print("LBot:getMaxSpeed: " .. tostring(speed))
  print("LBot:getMaxSpeed: name=" .. npc:getName())
end

--@api: LBot:setMaxForce
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("tank")
  npc:setMaxForce(80)
  print("LBot:setMaxForce: done")
  print("LBot:setMaxForce: force=" .. tostring(npc:getMaxForce()))
end

--@api: LBot:getMaxForce
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("scout")
  npc:setMaxForce(200)
  local force = npc:getMaxForce()
  print("LBot:getMaxForce: " .. tostring(force))
  print("LBot:getMaxForce: name=" .. npc:getName())
end

--@api: LBot:setPriority
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("captain")
  npc:setPriority(10)
  print("LBot:setPriority: " .. tostring(npc:getPriority()))
end

--@api: LBot:getPriority
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("grunt")
  npc:setPriority(5)
  local prio = npc:getPriority()
  print("LBot:getPriority: " .. tostring(prio))
end

--@api: LBot:setDecisionModel
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("worker")
  npc:setDecisionModel("custom")
  local model = npc:getDecisionModel()
  print("LBot:setDecisionModel: " .. model)
end

--@api: LBot:getDecisionModel
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("farmer")
  npc:setDecisionModel("custom")
  local model = npc:getDecisionModel()
  print("LBot:getDecisionModel: " .. model)
end

--@api: LBot:setCustomModel
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("thinker")
  npc:setDecisionModel("custom")
  local called_with_dt = 0
  npc:setCustomModel(function(agent, bb, dt) called_with_dt = dt end)
  world:update(0.016)
  print("LBot:setCustomModel: dt=" .. tostring(called_with_dt))
end

--@api: LBot:addTag
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("guard")
  npc:addTag("hostile")
  local has_hostile = npc:hasTag("hostile")
  print("LBot:addTag: hostile=" .. tostring(has_hostile))
end

--@api: LBot:removeTag
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("spy")
  npc:addTag("visible")
  npc:removeTag("visible")
  local still_has = npc:hasTag("visible")
  print("LBot:removeTag: visible=" .. tostring(still_has))
end

--@api: LBot:hasTag
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("merchant")
  npc:addTag("friendly")
  local friendly = npc:hasTag("friendly")
  local hostile = npc:hasTag("hostile")
  print("LBot:hasTag: friendly=" .. tostring(friendly) .. " hostile=" .. tostring(hostile))
end

--@api: LBot:getBlackboard
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("ranger")
  local bb = npc:getBlackboard()
  bb:setNumber("hp", 100)
  local hp = bb:getNumber("hp", 0)
  print("LBot:getBlackboard: hp=" .. tostring(hp))
end

--@api: LBot:type
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("villager")
  local t = npc:type()
  print("LBot:type: " .. t)
  print("LBot:type: matches=" .. tostring(npc:typeOf("LBot")))
end

--@api: LBot:typeOf
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("knight")
  local is_agent = npc:typeOf("LBot")
  local is_image = npc:typeOf("LImage")
  print("LBot:typeOf: LBot=" .. tostring(is_agent) .. " LImage=" .. tostring(is_image))
end

--@api: LAIBlackboard:setNumber
do
  local bb = lurek.ai.newBlackboard()
  bb:setNumber("distance", 42.5)
  bb:setNumber("ammo", 30)
  local dist = bb:getNumber("distance", 0)
  print("LAIBlackboard:setNumber: distance=" .. tostring(dist))
end

--@api: LAIBlackboard:getNumber
do
  local bb = lurek.ai.newBlackboard()
  bb:setNumber("score", 95.5)
  local score = bb:getNumber("score", 0)
  local missing = bb:getNumber("nonexistent", -1)
  print("LAIBlackboard:getNumber: score=" .. tostring(score) .. " missing=" .. tostring(missing))
end

--@api: LAIBlackboard:setBool
do
  local bb = lurek.ai.newBlackboard()
  bb:setBool("can_attack", true)
  bb:setBool("is_hiding", false)
  local attack = bb:getBool("can_attack", false)
  print("LAIBlackboard:setBool: can_attack=" .. tostring(attack))
end

--@api: LAIBlackboard:getBool
do
  local bb = lurek.ai.newBlackboard()
  bb:setBool("alert", true)
  local alert = bb:getBool("alert", false)
  local calm = bb:getBool("calm", true)
  print("LAIBlackboard:getBool: alert=" .. tostring(alert) .. " calm=" .. tostring(calm))
end

--@api: LAIBlackboard:setString
do
  local bb = lurek.ai.newBlackboard()
  bb:setString("target_name", "dragon")
  bb:setString("current_zone", "forest")
  local target = bb:getString("target_name", "none")
  print("LAIBlackboard:setString: target=" .. target)
end

--@api: LAIBlackboard:getString
do
  local bb = lurek.ai.newBlackboard()
  bb:setString("weapon", "sword")
  local weapon = bb:getString("weapon", "fists")
  local shield = bb:getString("shield", "none")
  print("LAIBlackboard:getString: weapon=" .. weapon .. " shield=" .. shield)
end

--@api: LAIBlackboard:has
do
  local bb = lurek.ai.newBlackboard()
  bb:setNumber("hp", 80)
  local has_hp = bb:has("hp")
  local has_mp = bb:has("mp")
  print("LAIBlackboard:has: hp=" .. tostring(has_hp) .. " mp=" .. tostring(has_mp))
end

--@api: LAIBlackboard:remove
do
  local bb = lurek.ai.newBlackboard()
  bb:setNumber("temp", 99)
  bb:remove("temp")
  local still_has = bb:has("temp")
  print("LAIBlackboard:remove: has_temp=" .. tostring(still_has))
end

--@api: LAIBlackboard:clear
do
  local bb = lurek.ai.newBlackboard()
  bb:setNumber("a", 1)
  bb:setString("b", "x")
  bb:setBool("c", true)
  bb:clear()
  local size = bb:getSize()
  print("LAIBlackboard:clear: size=" .. tostring(size))
end

--@api: LAIBlackboard:getKeys
do
  local bb = lurek.ai.newBlackboard()
  bb:setNumber("hp", 100)
  bb:setString("state", "idle")
  local keys = bb:getKeys()
  print("LAIBlackboard:getKeys: count=" .. tostring(#keys))
end

--@api: LAIBlackboard:getSize
do
  local bb = lurek.ai.newBlackboard()
  bb:setNumber("hp", 10)
  bb:setString("name", "test")
  local size = bb:getSize()
  print("LAIBlackboard:getSize: " .. tostring(size))
end

--@api: LAIBlackboard:type
do
  local bb = lurek.ai.newBlackboard()
  local t = bb:type()
  print("LAIBlackboard:type: " .. t)
  print("LAIBlackboard:type: matches=" .. tostring(bb:typeOf("LAIBlackboard")))
end

--@api: LAIBlackboard:typeOf
do
  local bb = lurek.ai.newBlackboard()
  local is_bb = bb:typeOf("LAIBlackboard")
  local is_agent = bb:typeOf("LBot")
  print("LAIBlackboard:typeOf: LAIBlackboard=" .. tostring(is_bb) .. " LBot=" .. tostring(is_agent))
end

--@api: LStateMachine:addState
do
  local fsm = lurek.ai.newStateMachine()
  local entered = ""
  fsm:addState("patrol", { onEnter = function() entered = "patrol" end })
  fsm:setInitialState("patrol")
  print("LStateMachine:addState: entered=" .. entered)
end

--@api: LStateMachine:addTransition
do
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("idle", {})
  fsm:addState("alert", {})
  fsm:addTransition("idle", "alert", function() return true end, 1)
  print("LStateMachine:addTransition: configured")
end

--@api: LStateMachine:setInitialState
do
  local fsm = lurek.ai.newStateMachine()
  local log = ""
  fsm:addState("sleep", { onEnter = function() log = "entered_sleep" end })
  fsm:setInitialState("sleep")
  local current = fsm:getCurrentState() or "none"
  print("LStateMachine:setInitialState: " .. current .. " log=" .. log)
end

--@api: LStateMachine:getCurrentState
do
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("wander", {})
  local before = fsm:getCurrentState()
  fsm:setInitialState("wander")
  local after = fsm:getCurrentState()
  print("LStateMachine:getCurrentState: before=" .. tostring(before) .. " after=" .. tostring(after))
end

--@api: LStateMachine:forceState
do
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("alive", {})
  fsm:addState("dead", {})
  fsm:setInitialState("alive")
  fsm:forceState("dead")
  local current = fsm:getCurrentState() or "none"
  print("LStateMachine:forceState: " .. current)
end

--@api: LStateMachine:getTimeInState
do
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("cooking", {})
  fsm:setInitialState("cooking")
  local time_in = fsm:getTimeInState()
  print("LStateMachine:getTimeInState: " .. tostring(time_in))
end

--@api: LStateMachine:type
do
  local fsm = lurek.ai.newStateMachine()
  local t = fsm:type()
  print("LStateMachine:type: " .. t)
  print("LStateMachine:type: matches=" .. tostring(fsm:typeOf("LStateMachine")))
end

--@api: LStateMachine:typeOf
do
  local fsm = lurek.ai.newStateMachine()
  local is_fsm = fsm:typeOf("LStateMachine")
  local is_other = fsm:typeOf("LBehaviorTree")
  print("LStateMachine:typeOf: LStateMachine=" .. tostring(is_fsm) .. " LBehaviorTree=" .. tostring(is_other))
end

--@api: LBehaviorTree:getLastStatus
do
  local bt = lurek.ai.newBehaviorTree()
  bt:setRoot(lurek.ai.newAction(function() return "success" end))
  local status = bt:getLastStatus()
  print("LBehaviorTree:getLastStatus: " .. status)
end

--@api: LBehaviorTree:getDebugState
do
  local bt = lurek.ai.newBehaviorTree()
  bt:setRoot(lurek.ai.newAction(function() return "success" end))
  local info = bt:getDebugState()
  print("LBehaviorTree:getDebugState: node_count=" .. tostring(info.node_count))
  print("LBehaviorTree:getDebugState: last_status=" .. tostring(info.last_status))
end

--@api: LBehaviorTree:type
do
  local bt = lurek.ai.newBehaviorTree()
  local t = bt:type()
  print("LBehaviorTree:type: " .. t)
  print("LBehaviorTree:type: matches=" .. tostring(bt:typeOf("LBehaviorTree")))
end

--@api: LBehaviorTree:typeOf
do
  local bt = lurek.ai.newBehaviorTree()
  local is_bt = bt:typeOf("LBehaviorTree")
  local is_other = bt:typeOf("LBot")
  print("LBehaviorTree:typeOf: LBehaviorTree=" .. tostring(is_bt) .. " LBot=" .. tostring(is_other))
end

--@api: LBTNode:addChild
do
  local seq = lurek.ai.newSequence()
  seq:addChild(lurek.ai.newAction(function() return "success" end))
  local count = seq:getChildCount()
  print("LBTNode:addChild: children=" .. tostring(count))
end

--@api: LBTNode:getChildCount
do
  local sel = lurek.ai.newSelector()
  sel:addChild(lurek.ai.newAction(function() return "success" end))
  local count = sel:getChildCount()
  print("LBTNode:getChildCount: " .. tostring(count))
end

--@api: LBTNode:reset
do
  local seq = lurek.ai.newSequence()
  seq:addChild(lurek.ai.newAction(function() return "running" end))
  seq:reset()
  print("LBTNode:reset: done")
end

--@api: LBTNode:setChild
do
  local inv = lurek.ai.newInverter()
  inv:setChild(lurek.ai.newAction(function() return "failure" end))
  print("LBTNode:setChild: configured")
  print("LBTNode:setChild: type=" .. inv:getNodeType())
end

--@api: LBTNode:setCount
do
  local rep = lurek.ai.newRepeater(3)
  rep:setCount(10)
  local count = rep:getCount()
  print("LBTNode:setCount: " .. tostring(count))
end

--@api: LBTNode:getCount
do
  local rep = lurek.ai.newRepeater(7)
  local count = rep:getCount()
  print("LBTNode:getCount: " .. tostring(count))
end

--@api: LBTNode:setSuccessPolicy
do
  local par = lurek.ai.newParallel("requireAll", "requireOne")
  par:setSuccessPolicy("requireOne")
  print("LBTNode:setSuccessPolicy: done")
  print("LBTNode:setSuccessPolicy: type=" .. par:getNodeType())
end

--@api: LBTNode:setFailurePolicy
do
  local par = lurek.ai.newParallel("requireOne", "requireAll")
  par:setFailurePolicy("requireOne")
  print("LBTNode:setFailurePolicy: done")
  print("LBTNode:setFailurePolicy: type=" .. par:getNodeType())
end

--@api: LBTNode:getNodeType
do
  local act = lurek.ai.newAction(function() return "success" end)
  print("LBTNode:getNodeType: " .. act:getNodeType())
end

--@api: LBTNode:type
do
  local node = lurek.ai.newAction(function() return "success" end)
  local t = node:type()
  print("LBTNode:type: " .. t)
  print("LBTNode:type: matches=" .. tostring(node:typeOf("LBTNode")))
end

--@api: LBTNode:typeOf
do
  local node = lurek.ai.newSelector()
  local is_node = node:typeOf("LBTNode")
  local is_other = node:typeOf("LImage")
  print("LBTNode:typeOf: LBTNode=" .. tostring(is_node) .. " LImage=" .. tostring(is_other))
end

--@api: LSteeringManager:addSeek
do
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(400, 300, 1.0)
  local fx, fy = steer:calculate(50, 50, 0, 0, 100, 200, 1 / 60)
  print("LSteeringManager:addSeek: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end

--@api: LSteeringManager:addFlee
do
  local steer = lurek.ai.newSteeringManager()
  steer:addFlee(200, 200, 1.0)
  local fx, fy = steer:calculate(210, 195, 0, 0, 100, 200, 1 / 60)
  print("LSteeringManager:addFlee: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end

--@api: LSteeringManager:addArrive
do
  local steer = lurek.ai.newSteeringManager()
  steer:addArrive(300, 300, 50, 1.0)
  local fx, fy = steer:calculate(280, 290, 30, 10, 100, 200, 1 / 60)
  print("LSteeringManager:addArrive: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end

--@api: LSteeringManager:addWander
do
  local steer = lurek.ai.newSteeringManager()
  steer:addWander(25, 50, 8, 0.5)
  local fx, fy = steer:calculate(100, 100, 10, 0, 80, 150, 1 / 60)
  print("LSteeringManager:addWander: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end

--@api: LSteeringManager:addPursue
do
  local steer = lurek.ai.newSteeringManager()
  steer:setEntity("target_agent", 220, 120, 20, 0)
  steer:addPursue("target_agent", 1.0)
  local fx, fy = steer:calculate(100, 120, 0, 0, 120, 250, 1 / 60)
  print("LSteeringManager:addPursue: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end

--@api: LSteeringManager:addEvade
do
  local steer = lurek.ai.newSteeringManager()
  steer:setEntity("enemy_agent", 140, 120, -10, 0)
  steer:addEvade("enemy_agent", 1.0)
  local fx, fy = steer:calculate(100, 120, 0, 0, 120, 250, 1 / 60)
  print("LSteeringManager:addEvade: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end

--@api: LSteeringManager:addFlock
do
  local steer = lurek.ai.newSteeringManager()
  steer:setEntity("ally_1", 110, 100, 20, 0)
  steer:setEntity("ally_2", 95, 140, 10, 5)
  steer:addFlock(80, 1.5, 1.0, 1.0, 1.0)
  local fx, fy = steer:calculate(100, 120, 0, 0, 120, 250, 1 / 60)
  print("LSteeringManager:addFlock: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end

--@api: LSteeringManager:setEntity
do
  local steer = lurek.ai.newSteeringManager()
  steer:setEntity("scout", 100, 80, 12, 0)
  print("LSteeringManager:setEntity: count=" .. tostring(steer:entityCount()))
end

--@api: LSteeringManager:removeEntity
do
  local steer = lurek.ai.newSteeringManager()
  steer:setEntity("scout", 100, 80, 12, 0)
  local removed = steer:removeEntity("scout")
  print("LSteeringManager:removeEntity: removed=" .. tostring(removed))
end

--@api: LSteeringManager:clearEntities
do
  local steer = lurek.ai.newSteeringManager()
  steer:setEntity("a", 0, 0)
  steer:setEntity("b", 16, 0)
  steer:clearEntities()
  print("LSteeringManager:clearEntities: count=" .. tostring(steer:entityCount()))
end

--@api: LSteeringManager:entityCount
do
  local steer = lurek.ai.newSteeringManager()
  steer:setEntity("a", 0, 0)
  print("LSteeringManager:entityCount: " .. tostring(steer:entityCount()))
end

--@api: LSteeringManager:getBehaviorCount
do
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(100, 100, 1.0)
  steer:addWander(10, 20, 3, 0.5)
  local count = steer:getBehaviorCount()
  print("LSteeringManager:getBehaviorCount: " .. tostring(count))
end

--@api: LSteeringManager:setCombineMode
do
  local steer = lurek.ai.newSteeringManager()
  steer:setCombineMode("priority")
  local mode = steer:getCombineMode()
  print("LSteeringManager:setCombineMode: " .. mode)
end

--@api: LSteeringManager:getCombineMode
do
  local steer = lurek.ai.newSteeringManager()
  steer:setCombineMode("truncated")
  local mode = steer:getCombineMode()
  print("LSteeringManager:getCombineMode: " .. mode)
  print("LSteeringManager:getCombineMode: type=" .. steer:type())
end

--@api: LSteeringManager:getLastSteering
do
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(200, 200, 1.0)
  steer:calculate(50, 50, 0, 0, 100, 200, 1 / 60)
  local lx, ly = steer:getLastSteering()
  print("LSteeringManager:getLastSteering: " .. tostring(lx) .. "," .. tostring(ly))
end

--@api: LSteeringManager:calculate
do
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(500, 300, 1.0)
  steer:addWander(15, 30, 4, 0.3)
  local fx, fy = steer:calculate(100, 100, 20, 5, 150, 250, 1 / 60)
  print("LSteeringManager:calculate: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end

--@api: LSteeringManager:setPath
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

--@api: LSteeringManager:clearPath
do
  local steer = lurek.ai.newSteeringManager()
  steer:setPath({ { x = 10, y = 10 }, { x = 100, y = 100 } }, 8.0, 1.0)
  steer:clearPath()
  local has = steer:hasPath()
  print("LSteeringManager:clearPath: hasPath=" .. tostring(has))
end

--@api: LSteeringManager:hasPath
do
  local steer = lurek.ai.newSteeringManager()
  local before = steer:hasPath()
  steer:setPath({ { x = 0, y = 0 }, { x = 50, y = 50 } }, 5.0, 1.0)
  local after = steer:hasPath()
  print("LSteeringManager:hasPath: before=" .. tostring(before) .. " after=" .. tostring(after))
end

--@api: LSteeringManager:getPathProgress
do
  local steer = lurek.ai.newSteeringManager()
  steer:setPath({ { x = 0, y = 0 }, { x = 100, y = 50 }, { x = 200, y = 100 } }, 10.0, 1.0)
  local idx, total = steer:getPathProgress()
  print("LSteeringManager:getPathProgress: " .. tostring(idx) .. "/" .. tostring(total))
end

--@api: LSteeringManager:type
do
  local steer = lurek.ai.newSteeringManager()
  local t = steer:type()
  print("LSteeringManager:type: " .. t)
  print("LSteeringManager:type: matches=" .. tostring(steer:typeOf("LSteeringManager")))
end

--@api: LSteeringManager:typeOf
do
  local steer = lurek.ai.newSteeringManager()
  local is_steer = steer:typeOf("LSteeringManager")
  local is_other = steer:typeOf("LBot")
  print("LSteeringManager:typeOf: LSteeringManager=" .. tostring(is_steer) .. " LBot=" .. tostring(is_other))
end

--@api: LSteeringManager:setSpatialHashCellSize
do
  local steer = lurek.ai.newSteeringManager()
  steer:setSpatialHashCellSize(32)
  print("LSteeringManager:setSpatialHashCellSize: done")
end

--@api: LSteeringManager:enableSpatialHash
do
  local steer = lurek.ai.newSteeringManager()
  steer:enableSpatialHash(true)
  steer:setSpatialHashCellSize(48)
  print("LSteeringManager:enableSpatialHash: done")
end

--@api: LSteeringManager:addCustomBehavior
do
  local steer = lurek.ai.newSteeringManager()
  steer:addCustomBehavior(function(agent, dt) return 50, 0 end, 0.8)
  local count = steer:getBehaviorCount()
  print("LSteeringManager:addCustomBehavior: behaviors=" .. tostring(count))
end

--@api: LSteeringManager:applyCustomSteering
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("pusher")
  npc:setPosition(100, 100)
  local steer = lurek.ai.newSteeringManager()
  steer:addCustomBehavior(function(agent, dt) return 25, -10 end, 1.0)
  local fx, fy = steer:applyCustomSteering(npc, 1 / 60)
  print("LSteeringManager:applyCustomSteering: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end

--@api: LUtilityAI:addAction
do
    local uai = lurek.ai.newUtilityAI()
    uai:addAction("eat", function() return 0.8 end, 1.0)
    uai:addAction("sleep", function() return 0.3 end, 1.0)
    print("actions added = " .. uai:getActionCount())
end

--@api: LUtilityAI:evaluate
do
    local uai = lurek.ai.newUtilityAI()
    uai:addAction("attack", function() return 0.9 end)
    uai:addAction("defend", function() return 0.4 end)
    local chosen = uai:evaluate()
    print("chosen action = " .. tostring(chosen))
end

--@api: LUtilityAI:getActionCount
do
    local uai = lurek.ai.newUtilityAI()
    uai:addAction("patrol", function() return 0.5 end)
    uai:addAction("idle", function() return 0.1 end)
    uai:addAction("chase", function() return 0.7 end)
    print("action count = " .. uai:getActionCount())
end

--@api: LUtilityAI:getLastAction
do
  local uai = lurek.ai.newUtilityAI()
  uai:addAction("gather", function() return 0.6 end)
    uai:addAction("build", function() return 0.2 end)
    uai:evaluate()
    local last = uai:getLastAction()
    print("last action = " .. tostring(last))
end

--@api: LUtilityAI:addConsideration
do
    local uai = lurek.ai.newUtilityAI()
    uai:addAction("heal", function() return 0.5 end)
    uai:addConsideration("heal", "low_health", function() return 0.9 end, "linear", 1.0, 0.0, 0.0, 1.0)
    uai:evaluate()
    print("consideration added, last = " .. tostring(uai:getLastAction()))
end

--@api: LUtilityAI:type
do
    local uai = lurek.ai.newUtilityAI()
    print("type = " .. uai:type())
  print("matches = " .. tostring(uai:typeOf("LUtilityAI")))
end

--@api: LUtilityAI:typeOf
do
    local uai = lurek.ai.newUtilityAI()
    print("is LUtilityAI = " .. tostring(uai:typeOf("LUtilityAI")))
end

--@api: LGOAPPlanner:addAction
do
    local goap = lurek.ai.newGOAPPlanner()
    goap:addAction("chop_wood", 2, function() print("  chopping wood") end)
    goap:addAction("build_house", 5, function() print("  building house") end)
    print("goap actions = " .. goap:getActionCount())
end

--@api: LGOAPPlanner:setPrecondition
do
    local goap = lurek.ai.newGOAPPlanner()
    goap:addAction("cook", 1, function() end)
    goap:setPrecondition("cook", "has_food", true)
    print("precondition set for cook")
end

--@api: LGOAPPlanner:setEffect
do
    local goap = lurek.ai.newGOAPPlanner()
    goap:addAction("mine_ore", 3, function() end)
    goap:setEffect("mine_ore", "has_ore", true)
    print("effect set for mine_ore")
end

--@api: LGOAPPlanner:addGoal
do
    local goap = lurek.ai.newGOAPPlanner()
    goap:addGoal("survive", 10)
    goap:addGoal("explore", 3)
    print("goals = " .. goap:getGoalCount())
end

--@api: LGOAPPlanner:setGoalState
do
    local goap = lurek.ai.newGOAPPlanner()
    goap:addGoal("build_shelter", 5)
    goap:setGoalState("build_shelter", "shelter_built", true)
    print("goal state set for build_shelter")
end

--@api: LGOAPPlanner:plan
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

--@api: LGOAPPlanner:getActionCount
do
    local goap = lurek.ai.newGOAPPlanner()
    goap:addAction("a1", 1, function() end)
    goap:addAction("a2", 2, function() end)
    print("action count = " .. goap:getActionCount())
end

--@api: LGOAPPlanner:getGoalCount
do
    local goap = lurek.ai.newGOAPPlanner()
    goap:addGoal("g1", 1)
    goap:addGoal("g2", 5)
    goap:addGoal("g3", 3)
    print("goal count = " .. goap:getGoalCount())
end

--@api: LGOAPPlanner:getMaxIterations
do
    local goap = lurek.ai.newGOAPPlanner()
    local max = goap:getMaxIterations()
    print("default max iterations = " .. max)
end

--@api: LGOAPPlanner:setMaxIterations
do
    local goap = lurek.ai.newGOAPPlanner()
    goap:setMaxIterations(500)
    print("max iterations = " .. goap:getMaxIterations())
end

--@api: LGOAPPlanner:type
do
    local goap = lurek.ai.newGOAPPlanner()
    print("type = " .. goap:type())
  print("matches = " .. tostring(goap:typeOf("LGOAPPlanner")))
end

--@api: LGOAPPlanner:typeOf
do
    local goap = lurek.ai.newGOAPPlanner()
    print("is LGOAPPlanner = " .. tostring(goap:typeOf("LGOAPPlanner")))
end

--@api: LInfluenceMap:addLayer
do
    local im = lurek.ai.newInfluenceMap(16, 16, 1.0)
    im:addLayer("threat")
    im:addLayer("resources")
    print("layers added: threat, resources")
end

--@api: LInfluenceMap:hasLayer
do
    local im = lurek.ai.newInfluenceMap(8, 8, 2.0)
    im:addLayer("heat")
    print("has heat = " .. tostring(im:hasLayer("heat")))
    print("has cold = " .. tostring(im:hasLayer("cold")))
end

--@api: LInfluenceMap:setInfluence
do
    local im = lurek.ai.newInfluenceMap(10, 10, 1.0)
    im:addLayer("danger")
    im:setInfluence("danger", 5, 5, 1.0)
    im:setInfluence("danger", 3, 7, 0.5)
    print("set influence at (5,5) and (3,7)")
end

--@api: LInfluenceMap:getInfluence
do
    local im = lurek.ai.newInfluenceMap(10, 10, 1.0)
    im:addLayer("food")
    im:setInfluence("food", 4, 4, 0.75)
    local val = im:getInfluence("food", 4, 4)
    print("food at (4,4) = " .. val)
end

--@api: LInfluenceMap:stampInfluence
do
    local im = lurek.ai.newInfluenceMap(20, 20, 1.0)
    im:addLayer("noise")
    im:stampInfluence("noise", 10.0, 10.0, 3.0, 1.0, 0.5)
    local center = im:getInfluence("noise", 10, 10)
    print("noise center = " .. center)
end

--@api: LInfluenceMap:propagate
do
  local im = lurek.ai.newInfluenceMap(10, 10, 1.0)
  im:addLayer("scent")
    im:setInfluence("scent", 5, 5, 1.0)
    im:propagate("scent", 0.8)
    local neighbor = im:getInfluence("scent", 4, 5)
    print("scent propagated to (4,5) = " .. neighbor)
end

--@api: LInfluenceMap:decay
do
  local im = lurek.ai.newInfluenceMap(8, 8, 1.0)
  im:addLayer("heat")
    im:setInfluence("heat", 4, 4, 1.0)
    im:decay("heat", 0.5)
    local val = im:getInfluence("heat", 4, 4)
    print("heat after decay = " .. val)
end

--@api: LInfluenceMap:clearLayer
do
  local im = lurek.ai.newInfluenceMap(8, 8, 1.0)
  im:addLayer("marks")
    im:setInfluence("marks", 2, 2, 1.0)
    im:clearLayer("marks")
    local val = im:getInfluence("marks", 2, 2)
    print("after clear = " .. val)
end

--@api: LInfluenceMap:clearAll
do
  local im = lurek.ai.newInfluenceMap(8, 8, 1.0)
  im:addLayer("a")
  im:addLayer("b")
  im:setInfluence("a", 1, 1, 1.0)
    im:setInfluence("b", 2, 2, 0.5)
    im:clearAll()
    print("all cleared, a(1,1) = " .. im:getInfluence("a", 1, 1))
end

--@api: LInfluenceMap:getMaxPosition
do
  local im = lurek.ai.newInfluenceMap(10, 10, 1.0)
  im:addLayer("gold")
    im:setInfluence("gold", 7, 3, 0.9)
    im:setInfluence("gold", 2, 8, 0.4)
    local mx, my = im:getMaxPosition("gold")
    print("max gold at (" .. mx .. ", " .. my .. ")")
end

--@api: LInfluenceMap:getMinPosition
do
  local im = lurek.ai.newInfluenceMap(10, 10, 1.0)
  im:addLayer("cold")
    im:setInfluence("cold", 1, 1, -0.5)
    im:setInfluence("cold", 5, 5, 0.3)
    local mx, my = im:getMinPosition("cold")
    print("min cold at (" .. mx .. ", " .. my .. ")")
end

--@api: LInfluenceMap:queryRect
do
  local im = lurek.ai.newInfluenceMap(10, 10, 1.0)
  im:addLayer("energy")
    im:setInfluence("energy", 2, 2, 0.5)
    im:setInfluence("energy", 3, 3, 0.5)
    local total = im:queryRect("energy", 1, 1, 4, 4)
    print("energy in rect = " .. total)
end

--@api: LInfluenceMap:blend
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

--@api: LInfluenceMap:getWidth
do
    local im = lurek.ai.newInfluenceMap(16, 12, 2.0)
    print("width = " .. im:getWidth())
end

--@api: LInfluenceMap:getHeight
do
    local im = lurek.ai.newInfluenceMap(16, 12, 2.0)
    print("height = " .. im:getHeight())
end

--@api: LInfluenceMap:getCellSize
do
    local im = lurek.ai.newInfluenceMap(8, 8, 2.5)
    print("cell size = " .. im:getCellSize())
end

--@api: LInfluenceMap:type
do
    local im = lurek.ai.newInfluenceMap(4, 4, 1.0)
    print("type = " .. im:type())
  print("matches = " .. tostring(im:typeOf("LInfluenceMap")))
end

--@api: LInfluenceMap:typeOf
do
    local im = lurek.ai.newInfluenceMap(4, 4, 1.0)
    print("is LInfluenceMap = " .. tostring(im:typeOf("LInfluenceMap")))
end

--@api: LSquad:getName
do
    local sq = lurek.ai.newSquad("alpha")
    print("squad name = " .. sq:getName())
end

--@api: LSquad:addMember
do
    local sq = lurek.ai.newSquad("bravo")
    sq:addMember("soldier_1")
    sq:addMember("soldier_2")
    print("members = " .. sq:getMemberCount())
end

--@api: LSquad:removeMember
do
    local sq = lurek.ai.newSquad("charlie")
    sq:addMember("scout")
    sq:addMember("medic")
    sq:removeMember("scout")
    print("after remove = " .. sq:getMemberCount())
end

--@api: LSquad:getMemberCount
do
    local sq = lurek.ai.newSquad("delta")
    sq:addMember("a")
    sq:addMember("b")
    sq:addMember("c")
    print("count = " .. sq:getMemberCount())
end

--@api: LSquad:getMembers
do
    local sq = lurek.ai.newSquad("echo")
    sq:addMember("sniper")
    sq:addMember("heavy")
    local members = sq:getMembers()
    print("members: " .. table.concat(members, ", "))
end

--@api: LSquad:setLeader
do
    local sq = lurek.ai.newSquad("foxtrot")
    sq:addMember("captain")
    sq:addMember("private")
    sq:setLeader("captain")
    print("leader = " .. sq:getLeader())
end

--@api: LSquad:getLeader
do
    local sq = lurek.ai.newSquad("golf")
    sq:addMember("commander")
    sq:setLeader("commander")
    local leader = sq:getLeader()
    print("leader = " .. tostring(leader))
end

--@api: LSquad:setFormation
do
  local sq = lurek.ai.newSquad("hotel")
  sq:addMember("point")
    sq:addMember("left")
    sq:addMember("right")
    sq:setFormation("wedge", 2.0)
    print("formation set to wedge, spacing 2.0")
end

--- AI Examples Part 4: Squad (cont.), Command Queue, Trait Profile, Stimulus World, Context Steering, Need System

--@api: LSquad:getFormation
do
    local sq = lurek.ai.newSquad("recon")
    sq:setFormation("line", 3.0)
    local f = sq:getFormation()
    print("formation = " .. f)
end

--@api: LSquad:getFormationSpacing
do
    local sq = lurek.ai.newSquad("assault")
    sq:setFormation("wedge", 2.5)
    local s = sq:getFormationSpacing()
    print("spacing = " .. s)
end

--@api: LSquad:getFormationPosition
do
  local sq = lurek.ai.newSquad("patrol")
  sq:addMember("lead")
  sq:addMember("flank_l")
  sq:addMember("flank_r")
    sq:setFormation("wedge", 2.0)
    local x, y = sq:getFormationPosition(2, 100.0, 50.0)
    print("member 2 pos = " .. x .. ", " .. y)
end

--@api: LSquad:getBlackboard
do
    local sq = lurek.ai.newSquad("intel")
    local bb = sq:getBlackboard()
    bb:setNumber("threat_level", 3)
    print("squad bb threat = " .. bb:getNumber("threat_level"))
end

--@api: LSquad:type
do
    local sq = lurek.ai.newSquad("test")
    print("type = " .. sq:type())
  print("matches = " .. tostring(sq:typeOf("LSquad")))
end

--@api: LSquad:typeOf
do
    local sq = lurek.ai.newSquad("test2")
    print("is LSquad = " .. tostring(sq:typeOf("LSquad")))
end

--@api: LCommandQueue:enqueue
do
    local cq = lurek.ai.newCommandQueue()
    cq:enqueue("move", function() print("  moving") end, { targetX = 10, targetY = 20 })
    cq:enqueue("attack", function() print("  attacking") end)
    print("queue size = " .. cq:getCount())
end

--@api: LCommandQueue:pushFront
do
    local cq = lurek.ai.newCommandQueue()
    cq:enqueue("patrol", function() end)
    cq:pushFront("dodge", function() print("  dodging") end)
    print("next type = " .. cq:getCurrentType())
end

--@api: LCommandQueue:replace
do
    local cq = lurek.ai.newCommandQueue()
    cq:enqueue("idle", function() end)
    cq:enqueue("gather", function() end)
    cq:replace("retreat", function() print("  retreating") end)
    print("after replace count = " .. cq:getCount())
end

--@api: LCommandQueue:cancelCurrent
do
    local cq = lurek.ai.newCommandQueue()
    cq:enqueue("walk", function() end)
    cq:enqueue("talk", function() end)
    cq:cancelCurrent()
    print("after cancel, type = " .. tostring(cq:getCurrentType()))
end

--@api: LCommandQueue:clear
do
    local cq = lurek.ai.newCommandQueue()
    cq:enqueue("a", function() end)
    cq:enqueue("b", function() end)
    cq:clear()
    print("after clear, empty = " .. tostring(cq:isEmpty()))
end

--@api: LCommandQueue:getCount
do
    local cq = lurek.ai.newCommandQueue()
    cq:enqueue("x", function() end)
    cq:enqueue("y", function() end)
    cq:enqueue("z", function() end)
    print("count = " .. cq:getCount())
end

--@api: LCommandQueue:isEmpty
do
    local cq = lurek.ai.newCommandQueue()
    print("empty initially = " .. tostring(cq:isEmpty()))
    cq:enqueue("step", function() end)
    print("empty after enqueue = " .. tostring(cq:isEmpty()))
end

--@api: LCommandQueue:getCurrentType
do
    local cq = lurek.ai.newCommandQueue()
    cq:enqueue("harvest", function() end)
    print("current type = " .. tostring(cq:getCurrentType()))
end

--@api: LCommandQueue:getCurrentTarget
do
    local cq = lurek.ai.newCommandQueue()
    cq:enqueue("go", function() end, { targetX = 5, targetY = 10 })
    local tgt = cq:getCurrentTarget()
    print("target = " .. tostring(tgt))
end

--@api: LCommandQueue:type
do
    local cq = lurek.ai.newCommandQueue()
    print("type = " .. cq:type())
  print("matches = " .. tostring(cq:typeOf("LCommandQueue")))
end

--@api: LCommandQueue:typeOf
do
    local cq = lurek.ai.newCommandQueue()
    print("is LCommandQueue = " .. tostring(cq:typeOf("LCommandQueue")))
end

--@api: LTraitProfile:set
do
    local tp = lurek.ai.newTraitProfile()
    tp:set("courage", 0.7)
    tp:set("aggression", 0.3)
    print("courage = " .. tp:get("courage"))
end

--@api: LTraitProfile:get
do
    local tp = lurek.ai.newTraitProfile()
    tp:set("speed", 1.0)
    tp:addModifier("speed", 0.5, 5.0, "buff")
    local effective = tp:get("speed")
    print("effective speed = " .. effective)
end

--@api: LTraitProfile:getBase
do
    local tp = lurek.ai.newTraitProfile()
    tp:set("strength", 0.8)
    tp:addModifier("strength", 0.2, 10.0, "potion")
    print("base strength = " .. tp:getBase("strength"))
end

--@api: LTraitProfile:addModifier
do
    local tp = lurek.ai.newTraitProfile()
    tp:set("defense", 0.5)
    tp:addModifier("defense", 0.3, 8.0, "shield_spell")
    print("defense with modifier = " .. tp:get("defense"))
end

--@api: LTraitProfile:removeModifiers
do
  local tp = lurek.ai.newTraitProfile()
  tp:set("luck", 0.4)
    tp:addModifier("luck", 0.2, 10.0, "charm")
    tp:addModifier("luck", 0.1, 5.0, "charm")
    tp:removeModifiers("charm")
    print("luck after remove = " .. tp:get("luck"))
end

--@api: LTraitProfile:update
do
    local tp = lurek.ai.newTraitProfile()
    tp:set("rage", 0.5)
    tp:addModifier("rage", 0.5, 2.0, "berserk")
    tp:update(3.0)
    print("rage after 3s = " .. tp:get("rage"))
end

--@api: LTraitProfile:has
do
    local tp = lurek.ai.newTraitProfile()
    tp:set("wisdom", 0.6)
    print("has wisdom = " .. tostring(tp:has("wisdom")))
    print("has charm = " .. tostring(tp:has("charm")))
end

--@api: LTraitProfile:traitCount
do
    local tp = lurek.ai.newTraitProfile()
    tp:set("a", 0.1)
    tp:set("b", 0.2)
    tp:set("c", 0.3)
    print("trait count = " .. tp:traitCount())
end

--@api: LTraitProfile:archetype
do
  local tp = lurek.ai.newTraitProfile()
  tp:set("aggression", 0.9)
    tp:set("caution", 0.1)
    tp:set("curiosity", 0.4)
    local arch = tp:archetype() or "unknown"
    print("archetype = " .. arch)
end

--@api: LTraitProfile:type
do
    local tp = lurek.ai.newTraitProfile()
    print("type = " .. tp:type())
  print("matches = " .. tostring(tp:typeOf("LTraitProfile")))
end

--@api: LTraitProfile:typeOf
do
    local tp = lurek.ai.newTraitProfile()
    print("is LTraitProfile = " .. tostring(tp:typeOf("LTraitProfile")))
end

--@api: LStimulusWorld:addVisual
do
    local sw = lurek.ai.newStimulusWorld()
    local id = sw:addVisual(100, 200, 0.8, 50.0, "enemy_spotted")
    print("visual stimulus id = " .. id)
end

--@api: LStimulusWorld:addAuditory
do
    local sw = lurek.ai.newStimulusWorld()
    local id = sw:addAuditory(50, 80, 0.6, 30.0, 0.1, "footstep")
    print("auditory stimulus id = " .. id)
end

--@api: LStimulusWorld:remove
do
    local sw = lurek.ai.newStimulusWorld()
    local id = sw:addVisual(10, 10, 1.0, 20.0, "flash")
    sw:remove(id)
    print("removed stimulus, count = " .. sw:count())
end

--@api: LStimulusWorld:update
do
    local sw = lurek.ai.newStimulusWorld()
    sw:addAuditory(0, 0, 1.0, 10.0, 0.5, "bang")
    sw:update(5.0)
    print("after update, count = " .. sw:count())
end

--@api: LStimulusWorld:count
do
    local sw = lurek.ai.newStimulusWorld()
    sw:addVisual(0, 0, 1.0, 10.0, "a")
    sw:addVisual(5, 5, 0.5, 8.0, "b")
    print("stimulus count = " .. sw:count())
end

--@api: LStimulusWorld:clear
do
    local sw = lurek.ai.newStimulusWorld()
    sw:addVisual(0, 0, 1.0, 10.0, "x")
    sw:addAuditory(1, 1, 0.5, 5.0, 0.2, "y")
    sw:clear()
    print("after clear, count = " .. sw:count())
end

--@api: LStimulusWorld:type
do
    local sw = lurek.ai.newStimulusWorld()
    print("type = " .. sw:type())
  print("matches = " .. tostring(sw:typeOf("LStimulusWorld")))
end

--@api: LStimulusWorld:typeOf
do
    local sw = lurek.ai.newStimulusWorld()
    print("is LStimulusWorld = " .. tostring(sw:typeOf("LStimulusWorld")))
end

--@api: LContextSteering:addSeekTarget
do
    local cs = lurek.ai.newContextSteering(8)
    cs:addSeekTarget(200, 150, 1.0)
    print("seek target added at (200, 150)")
end

--@api: LContextSteering:addWander
do
    local cs = lurek.ai.newContextSteering(8)
    cs:addWander(0.3, 0.5)
    print("wander behavior added")
end

--@api: LContextSteering:addAvoidPoint
do
    local cs = lurek.ai.newContextSteering(8)
    cs:addAvoidPoint(50, 50, 20.0, 1.5)
    print("avoid point at (50, 50) radius 20")
end

--@api: LContextSteering:addAvoidBounds
do
    local cs = lurek.ai.newContextSteering(8)
    cs:addAvoidBounds(0, 0, 800, 600, 30.0, 1.0)
    print("avoid bounds set for 800x600 area")
end

--@api: LContextSteering:clearBehaviors
do
    local cs = lurek.ai.newContextSteering(8)
    cs:addSeekTarget(100, 100, 1.0)
    cs:addAvoidPoint(50, 50, 10.0, 1.0)
    cs:clearBehaviors()
    print("behaviors cleared")
end

--@api: LContextSteering:evaluate
do
    local cs = lurek.ai.newContextSteering(8)
    cs:addSeekTarget(300, 200, 1.0)
    cs:addAvoidPoint(150, 150, 30.0, 2.0)
    local dx, dy = cs:evaluate(100, 100, 1.0, 0.0)
    print("direction = " .. dx .. ", " .. dy)
end

--@api: LContextSteering:chosenMagnitude
do
    local cs = lurek.ai.newContextSteering(8)
    cs:addSeekTarget(200, 200, 1.0)
    cs:evaluate(0, 0, 0, 0)
    local mag = cs:chosenMagnitude()
    print("magnitude = " .. mag)
end

--@api: LContextSteering:slotCount
do
    local cs = lurek.ai.newContextSteering(16)
    print("slots = " .. cs:slotCount())
end

--@api: LContextSteering:type
do
    local cs = lurek.ai.newContextSteering(8)
    print("type = " .. cs:type())
  print("matches = " .. tostring(cs:typeOf("LContextSteering")))
end

--@api: LContextSteering:typeOf
do
    local cs = lurek.ai.newContextSteering(8)
    print("is LContextSteering = " .. tostring(cs:typeOf("LContextSteering")))
end

--@api: LNeedSystem:addNeed
do
    local ns = lurek.ai.newNeedSystem()
    ns:addNeed("hunger", 0.1, 0.7, 2.0)
    ns:addNeed("thirst", 0.15, 0.6, 1.5)
    print("needs registered")
end

--@api: LNeedSystem:update
do
    local ns = lurek.ai.newNeedSystem()
    ns:addNeed("fatigue", 0.05, 0.8, 1.0)
    ns:update(2.0)
    local urgent = ns:mostUrgent()
    print("most urgent after 2s = " .. tostring(urgent))
end

--@api: LNeedSystem:mostUrgent
do
    local ns = lurek.ai.newNeedSystem()
    ns:addNeed("hunger", 0.5, 0.3, 2.0)
    ns:update(1.0)
    local name = ns:mostUrgent()
    print("most urgent = " .. tostring(name))
end

--@api: LNeedSystem:satisfy
do
    local ns = lurek.ai.newNeedSystem()
    ns:addNeed("thirst", 0.2, 0.5, 1.5)
    ns:update(3.0)
    ns:satisfy("thirst", 0.8)
    print("thirst satisfied")
end

--- AI Examples Part 5: Need System (cont.), AI Director, HTN, MCTS, Emotion, ORCA, Neural Net, Genetic Algorithm

--@api: LNeedSystem:valueOf
do
    local ns = lurek.ai.newNeedSystem()
    ns:addNeed("hunger", 0.1, 0.7, 2.0)
    ns:update(2.0)
    local val = ns:valueOf("hunger")
    print("hunger value = " .. val)
end

--@api: LNeedSystem:type
do
    local ns = lurek.ai.newNeedSystem()
    print("type = " .. ns:type())
  print("matches = " .. tostring(ns:typeOf("LNeedSystem")))
end

--@api: LNeedSystem:typeOf
do
    local ns = lurek.ai.newNeedSystem()
    print("is LNeedSystem = " .. tostring(ns:typeOf("LNeedSystem")))
end

--@api: LAIDirector:pushEvent
do
    local dir = lurek.ai.newAIDirector()
    dir:pushEvent(0.5)
    dir:pushEvent(0.8)
    print("events pushed, tension = " .. dir:tension())
end

--@api: LAIDirector:update
do
    local dir = lurek.ai.newAIDirector()
    dir:pushEvent(1.0)
    dir:update(2.0)
    print("phase after update = " .. dir:phase())
end

--@api: LAIDirector:tension
do
    local dir = lurek.ai.newAIDirector()
    dir:setTension(0.6)
    print("tension = " .. dir:tension())
end

--@api: LAIDirector:phase
do
    local dir = lurek.ai.newAIDirector()
    local p = dir:phase()
    print("initial phase = " .. p)
end

--@api: LAIDirector:spawnRateFactor
do
    local dir = lurek.ai.newAIDirector()
    dir:setTension(0.9)
    dir:update(0.1)
    print("spawn rate factor = " .. dir:spawnRateFactor())
end

--@api: LAIDirector:lootFactor
do
    local dir = lurek.ai.newAIDirector()
    dir:setTension(0.2)
    dir:update(0.1)
    print("loot factor = " .. dir:lootFactor())
end

--@api: LAIDirector:ambientIntensity
do
    local dir = lurek.ai.newAIDirector()
    dir:setTension(0.7)
    dir:update(0.1)
    print("ambient intensity = " .. dir:ambientIntensity())
end

--@api: LAIDirector:setTension
do
    local dir = lurek.ai.newAIDirector()
    dir:setTension(0.5)
    print("tension set to " .. dir:tension())
end

--@api: LAIDirector:reset
do
    local dir = lurek.ai.newAIDirector()
    dir:setTension(0.9)
    dir:reset()
    print("after reset, tension = " .. dir:tension())
end

--@api: LAIDirector:type
do
    local dir = lurek.ai.newAIDirector()
    print("type = " .. dir:type())
  print("matches = " .. tostring(dir:typeOf("LAIDirector")))
end

--@api: LAIDirector:typeOf
do
    local dir = lurek.ai.newAIDirector()
    print("is LAIDirector = " .. tostring(dir:typeOf("LAIDirector")))
end

--@api: LHTNDomain:addPrimitive
do
    local htn = lurek.ai.newHTNDomain()
    htn:addPrimitive("chop", { "has_axe" }, { "has_wood" }, {})
    htn:addPrimitive("build", { "has_wood" }, { "shelter_done" }, { "has_wood" })
    print("primitives = " .. htn:taskCount())
end

--@api: LHTNDomain:addCompound
do
    local htn = lurek.ai.newHTNDomain()
    htn:addPrimitive("mine", {}, { "has_ore" }, {})
    htn:addPrimitive("smelt", { "has_ore" }, { "has_metal" }, { "has_ore" })
  htn:addCompound("get_metal", { { name = "mine_and_smelt", preconditions = {}, sub_tasks = { "mine", "smelt" } } })
  print("compound added, tasks = " .. htn:taskCount())
end

--@api: LHTNDomain:plan
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

--@api: LHTNDomain:taskCount
do
    local htn = lurek.ai.newHTNDomain()
    htn:addPrimitive("a", {}, {}, {})
    htn:addPrimitive("b", {}, {}, {})
    print("task count = " .. htn:taskCount())
end

--@api: LHTNDomain:type
do
    local htn = lurek.ai.newHTNDomain()
    print("type = " .. htn:type())
  print("matches = " .. tostring(htn:typeOf("LHTNDomain")))
end

--@api: LHTNDomain:typeOf
do
    local htn = lurek.ai.newHTNDomain()
    print("is LHTNDomain = " .. tostring(htn:typeOf("LHTNDomain")))
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
  print("best action = " .. tostring(action))
end

--@api: LMCTSEngine:type
do
    local mcts = lurek.ai.newMCTSEngine(50, 1.0, 5, 0)
    print("type = " .. mcts:type())
  print("matches = " .. tostring(mcts:typeOf("LMCTSEngine")))
end

--@api: LMCTSEngine:typeOf
do
    local mcts = lurek.ai.newMCTSEngine(50, 1.0, 5, 0)
    print("is LMCTSEngine = " .. tostring(mcts:typeOf("LMCTSEngine")))
end

--@api: LEmotionModel:add
do
    local em = lurek.ai.newEmotionModel()
    em:add("joy", 0.3, 0.1, 0.2)
    em:add("anger", 0.0, 0.05, 0.3)
    print("emotions registered")
end

--@api: LEmotionModel:trigger
do
    local em = lurek.ai.newEmotionModel()
    em:add("fear", 0.0, 0.1, 0.2)
    em:trigger("fear", 0.7)
    print("fear = " .. em:get("fear"))
end

--@api: LEmotionModel:get
do
    local em = lurek.ai.newEmotionModel()
    em:add("sadness", 0.2, 0.05, 0.1)
    em:trigger("sadness", 0.5)
    local val = em:get("sadness")
    print("sadness = " .. val)
end

--@api: LEmotionModel:dominant
do
  local em = lurek.ai.newEmotionModel()
  em:add("joy", 0.0, 0.1, 0.1)
    em:add("anger", 0.0, 0.1, 0.1)
    em:trigger("joy", 0.3)
    em:trigger("anger", 0.8)
    print("dominant = " .. tostring(em:dominant()))
end

--@api: LEmotionModel:isActive
do
  local em = lurek.ai.newEmotionModel()
  em:add("surprise", 0.0, 0.1, 0.5)
    em:trigger("surprise", 0.2)
    print("surprise active = " .. tostring(em:isActive("surprise")))
    em:trigger("surprise", 0.5)
    print("surprise active = " .. tostring(em:isActive("surprise")))
end

--@api: LEmotionModel:update
do
    local em = lurek.ai.newEmotionModel()
    em:add("excitement", 0.0, 0.2, 0.1)
    em:trigger("excitement", 1.0)
    em:update(3.0)
    print("excitement after 3s = " .. em:get("excitement"))
end

--@api: LEmotionModel:reset
do
    local em = lurek.ai.newEmotionModel()
    em:add("rage", 0.0, 0.1, 0.2)
    em:trigger("rage", 1.0)
    em:reset()
    print("rage after reset = " .. em:get("rage"))
end

--@api: LEmotionModel:type
do
    local em = lurek.ai.newEmotionModel()
    print("type = " .. em:type())
  print("matches = " .. tostring(em:typeOf("LEmotionModel")))
end

--@api: LEmotionModel:typeOf
do
    local em = lurek.ai.newEmotionModel()
    print("is LEmotionModel = " .. tostring(em:typeOf("LEmotionModel")))
end

--@api: LORCASolver:addAgent
do
    local orca = lurek.ai.newORCASolver(2.0)
    local idx = orca:addAgent(10.0, 20.0, 0.5, 3.0)
    print("agent index = " .. idx)
end

--@api: LORCASolver:setPreferredVelocity
do
    local orca = lurek.ai.newORCASolver(2.0)
    orca:addAgent(0, 0, 0.5, 5.0)
    orca:setPreferredVelocity(0, 2.0, 1.0)
    print("preferred velocity set for agent 0")
end

--@api: LORCASolver:setPosition
do
    local orca = lurek.ai.newORCASolver(2.0)
    orca:addAgent(0, 0, 0.5, 5.0)
    orca:setPosition(0, 5.0, 3.0)
    print("position updated for agent 0")
end

--@api: LORCASolver:compute
do
  local orca = lurek.ai.newORCASolver(1.5)
  orca:addAgent(0, 0, 0.5, 3.0)
  orca:addAgent(5, 0, 0.5, 3.0)
  orca:setPreferredVelocity(0, 1.0, 0.0)
    orca:setPreferredVelocity(1, -1.0, 0.0)
    orca:compute(0.016)
    print("collision avoidance computed")
end

--@api: LORCASolver:getSafeVelocity
do
  local orca = lurek.ai.newORCASolver(1.5)
  orca:addAgent(0, 0, 0.5, 3.0)
    orca:setPreferredVelocity(0, 2.0, 0.0)
    orca:compute(0.016)
    local vx, vy = orca:getSafeVelocity(0)
    print("safe velocity = " .. vx .. ", " .. vy)
end

--@api: LORCASolver:agentCount
do
    local orca = lurek.ai.newORCASolver(2.0)
    orca:addAgent(0, 0, 1.0, 2.0)
    orca:addAgent(5, 5, 1.0, 2.0)
    print("agent count = " .. orca:agentCount())
end

--@api: LORCASolver:type
do
    local orca = lurek.ai.newORCASolver(1.0)
    print("type = " .. orca:type())
  print("matches = " .. tostring(orca:typeOf("LORCASolver")))
end

--@api: LORCASolver:typeOf
do
    local orca = lurek.ai.newORCASolver(1.0)
    print("is LORCASolver = " .. tostring(orca:typeOf("LORCASolver")))
end

--@api: LStrategyAI:addGoal
do
    local strat = lurek.ai.newStrategyAI(5.0)
    strat:addGoal("expand")
    strat:addGoal("defend")
    strat:addGoal("research")
    print("goals registered")
end

--@api: LStrategyAI:addTag
do
    local strat = lurek.ai.newStrategyAI(3.0)
    strat:addTag("war_declared")
    strat:addTag("low_resources")
    print("tags added")
end

--@api: LStrategyAI:removeTag
do
    local strat = lurek.ai.newStrategyAI(3.0)
    strat:addTag("peace")
    strat:removeTag("peace")
    print("tag removed")
end

--@api: LStrategyAI:update
do
    local strat = lurek.ai.newStrategyAI(1.0)
    strat:addGoal("attack")
    strat:addGoal("retreat")
    strat:update(1.5, function(goal) if goal == "attack" then return 0.8 end return 0.2 end)
    print("active = " .. tostring(strat:activeGoal()))
end

--@api: LStrategyAI:forceEvaluate
do
    local strat = lurek.ai.newStrategyAI(10.0)
    strat:addGoal("build")
    strat:addGoal("scout")
    strat:forceEvaluate(function(goal) if goal == "scout" then return 5.0 end return 1.0 end)
    print("forced active = " .. tostring(strat:activeGoal()))
end

--@api: LStrategyAI:activeGoal
do
    local strat = lurek.ai.newStrategyAI(1.0)
    strat:addGoal("idle")
    local active = strat:activeGoal()
    print("active goal = " .. tostring(active))
end

--@api: LStrategyAI:timeUntilNext
do
    local strat = lurek.ai.newStrategyAI(5.0)
    strat:addGoal("wait")
    strat:update(2.0, function() return 1.0 end)
    print("time until next = " .. strat:timeUntilNext())
end

--@api: LStrategyAI:type
do
    local strat = lurek.ai.newStrategyAI(1.0)
    print("type = " .. strat:type())
  print("matches = " .. tostring(strat:typeOf("LStrategyAI")))
end

--@api: LStrategyAI:typeOf
do
    local strat = lurek.ai.newStrategyAI(1.0)
    print("is LStrategyAI = " .. tostring(strat:typeOf("LStrategyAI")))
end

--@api: LAILod:tierFor
do
    local lod = lurek.ai.newAILod()
    local tier = lod:tierFor(100, 200, 0, 0)
    print("tier = " .. tier)
end

--@api: LAILod:shouldUpdate
do
    local lod = lurek.ai.newAILod()
    local run = lod:shouldUpdate(0, 1)
    print("tier 0 should update on frame 1 = " .. tostring(run))
end

--@api: LAILod:tierCount
do
    local lod = lurek.ai.newAILod()
    print("tier count = " .. lod:tierCount())
end

--@api: LAILod:tierName
do
    local lod = lurek.ai.newAILod()
    local name = lod:tierName(0)
    print("tier 0 name = " .. name)
end

--@api: LAILod:type
do
    local lod = lurek.ai.newAILod()
    print("type = " .. lod:type())
  print("matches = " .. tostring(lod:typeOf("LAILod")))
end

--@api: LAILod:typeOf
do
    local lod = lurek.ai.newAILod()
    print("is LAILod = " .. tostring(lod:typeOf("LAILod")))
end

