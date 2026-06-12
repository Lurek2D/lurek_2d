-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_ai_core_unit.lua
do
-- Canonical unit coverage for lurek.ai.

local function new_world_agent(name)
    local world = lurek.ai.newWorld()
    local agent = world:addAgent(name or "agent")
    return world, agent
end

local function new_blackboard()
    return lurek.ai.newBlackboard()
end

local function new_influence_map()
    return lurek.ai.newInfluenceMap(4, 3, 2)
end

-- @describe factories
describe("ai factories", function()
    -- @covers lurek.ai.newWorld
    it("newWorld creates userdata", function()
        expect_type("userdata", lurek.ai.newWorld())
    end)

    -- @covers lurek.ai.newBlackboard
    it("newBlackboard creates userdata", function()
        expect_type("userdata", lurek.ai.newBlackboard())
    end)

    -- @covers lurek.ai.newStateMachine
    it("newStateMachine creates userdata", function()
        expect_type("userdata", lurek.ai.newStateMachine())
    end)

    -- @covers lurek.ai.newBehaviorTree
    it("newBehaviorTree creates userdata", function()
        expect_type("userdata", lurek.ai.newBehaviorTree())
    end)

    -- @covers lurek.ai.newSelector
    it("newSelector creates userdata", function()
        expect_type("userdata", lurek.ai.newSelector())
    end)

    -- @covers lurek.ai.newSequence
    it("newSequence creates userdata", function()
        expect_type("userdata", lurek.ai.newSequence())
    end)

    -- @covers lurek.ai.newParallel
    it("newParallel creates userdata", function()
        expect_type("userdata", lurek.ai.newParallel())
    end)

    -- @covers lurek.ai.newInverter
    it("newInverter creates userdata", function()
        expect_type("userdata", lurek.ai.newInverter())
    end)

    -- @covers lurek.ai.newRepeater
    it("newRepeater creates userdata", function()
        expect_type("userdata", lurek.ai.newRepeater())
    end)

    -- @covers lurek.ai.newSucceeder
    it("newSucceeder creates userdata", function()
        expect_type("userdata", lurek.ai.newSucceeder())
    end)

    -- @covers lurek.ai.newAction
    it("newAction creates userdata", function()
        expect_type("userdata", lurek.ai.newAction(function() return "success" end))
    end)

    -- @covers lurek.ai.newCondition
    it("newCondition creates userdata", function()
        expect_type("userdata", lurek.ai.newCondition(function() return true end))
    end)

    -- @covers lurek.ai.newGuard
    it("newGuard is exposed", function()
        expect_type("function", lurek.ai.newGuard)
    end)

    -- @covers lurek.ai.newSteeringManager
    it("newSteeringManager creates userdata", function()
        expect_type("userdata", lurek.ai.newSteeringManager())
    end)

    -- @covers lurek.ai.newQLearner
    it("newQLearner is exposed", function()
        expect_type("function", lurek.ai.newQLearner)
    end)

    -- @covers lurek.ai.newUtilityAI
    it("newUtilityAI creates userdata", function()
        expect_type("userdata", lurek.ai.newUtilityAI())
    end)

    -- @covers lurek.ai.newDialogueAI
    it("newDialogueAI is exposed", function()
        expect_type("function", lurek.ai.newDialogueAI)
    end)

    -- @covers lurek.ai.newGOAPPlanner
    it("newGOAPPlanner creates userdata", function()
        expect_type("userdata", lurek.ai.newGOAPPlanner())
    end)

    -- @covers lurek.ai.newInfluenceMap
    it("newInfluenceMap creates userdata", function()
        expect_type("userdata", new_influence_map())
    end)

    -- @covers lurek.ai.newSquad
    it("newSquad creates userdata", function()
        expect_type("userdata", lurek.ai.newSquad("alpha"))
    end)

    -- @covers lurek.ai.newCommandQueue
    it("newCommandQueue creates userdata", function()
        expect_type("userdata", lurek.ai.newCommandQueue())
    end)

    -- @covers lurek.ai.newTraitProfile
    it("newTraitProfile creates userdata", function()
        expect_type("userdata", lurek.ai.newTraitProfile())
    end)

    -- @covers lurek.ai.newStimulusWorld
    it("newStimulusWorld creates userdata", function()
        expect_type("userdata", lurek.ai.newStimulusWorld())
    end)

    -- @covers lurek.ai.newContextSteering
    it("newContextSteering creates userdata", function()
        expect_type("userdata", lurek.ai.newContextSteering(8))
    end)

    -- @covers lurek.ai.newNeedSystem
    it("newNeedSystem creates userdata", function()
        expect_type("userdata", lurek.ai.newNeedSystem())
    end)

    -- @covers lurek.ai.newAIDirector
    it("newAIDirector creates userdata", function()
        expect_type("userdata", lurek.ai.newAIDirector())
    end)

    -- @covers lurek.ai.newHTNDomain
    it("newHTNDomain creates userdata", function()
        expect_type("userdata", lurek.ai.newHTNDomain())
    end)

    -- @covers lurek.ai.newMCTSEngine
    it("newMCTSEngine creates userdata", function()
        expect_type("userdata", lurek.ai.newMCTSEngine(20, 1.41, 4, 42))
    end)

    -- @covers lurek.ai.newEmotionModel
    it("newEmotionModel creates userdata", function()
        expect_type("userdata", lurek.ai.newEmotionModel())
    end)

    -- @covers lurek.ai.newORCASolver
    it("newORCASolver creates userdata", function()
        expect_type("userdata", lurek.ai.newORCASolver(1.5))
    end)

    -- @covers lurek.ai.newNeuralNet
    it("newNeuralNet is exposed", function()
        expect_type("function", lurek.ai.newNeuralNet)
    end)

    -- @covers lurek.ai.newGeneticAlgorithm
    it("newGeneticAlgorithm is exposed", function()
        expect_type("function", lurek.ai.newGeneticAlgorithm)
    end)

    -- @covers lurek.ai.newBandit
    it("newBandit is exposed", function()
        expect_type("function", lurek.ai.newBandit)
    end)

    -- @covers lurek.ai.newNeuroevolution
    it("newNeuroevolution is exposed", function()
        expect_type("function", lurek.ai.newNeuroevolution)
    end)

    -- @covers lurek.ai.newStrategyAI
    it("newStrategyAI creates userdata", function()
        expect_type("userdata", lurek.ai.newStrategyAI(5.0))
    end)

    -- @covers lurek.ai.newAILod
    it("newAILod creates userdata", function()
        expect_type("userdata", lurek.ai.newAILod())
    end)
end)

-- @describe world
describe("ai world", function()
    -- @covers LAIWorld:addAgent
    it("addAgent returns a bot handle", function()
        local _, agent = new_world_agent("hero")
        expect_type("userdata", agent)
    end)

    -- @covers LAIWorld:getAgent
    it("getAgent returns a named agent", function()
        local world = lurek.ai.newWorld()
        world:addAgent("hero")
        expect_equal("hero", world:getAgent("hero"):getName())
    end)

    -- @covers LAIWorld:removeAgent
    it("removeAgent removes an inserted agent", function()
        local world, agent = new_world_agent("hero")
        world:removeAgent(agent)
        expect_equal(0, world:getAgentCount())
    end)

    -- @covers LAIWorld:getAgentCount
    it("getAgentCount tracks agents", function()
        local world = lurek.ai.newWorld()
        world:addAgent("a")
        world:addAgent("b")
        expect_equal(2, world:getAgentCount())
    end)

    -- @covers LAIWorld:getGlobalBlackboard
    it("getGlobalBlackboard returns a blackboard", function()
        expect_equal("LAIBlackboard", lurek.ai.newWorld():getGlobalBlackboard():type())
    end)

    -- @covers LAIWorld:update
    it("update moves agents by velocity", function()
        local world, agent = new_world_agent("mover")
        agent:setPosition(0, 0)
        agent:setVelocity(10, 20)
        world:update(0.5)
        local x, y = agent:getPosition()
        expect_near(5.0, x, 0.01)
        expect_near(10.0, y, 0.01)
    end)

    -- @covers LAIWorld:type
    it("type returns LAIWorld", function()
        expect_equal("LAIWorld", lurek.ai.newWorld():type())
    end)

    -- @covers LAIWorld:typeOf
    it("typeOf reports world inheritance", function()
        expect_true(lurek.ai.newWorld():typeOf("LAIWorld"))
    end)
end)

-- @describe bot
describe("ai bot", function()
    -- @covers LBot:getName
    it("getName returns the bot name", function()
        local _, agent = new_world_agent("warrior")
        expect_equal("warrior", agent:getName())
    end)

    -- @covers LBot:setPosition
    it("setPosition updates bot coordinates", function()
        local _, agent = new_world_agent("hero")
        agent:setPosition(100, 200)
        local x, y = agent:getPosition()
        expect_near(100, x, 0.01)
        expect_near(200, y, 0.01)
    end)

    -- @covers LBot:getPosition
    it("getPosition returns two numbers", function()
        local _, agent = new_world_agent("hero")
        local x, y = agent:getPosition()
        expect_type("number", x)
        expect_type("number", y)
    end)

    -- @covers LBot:setVelocity
    it("setVelocity updates bot velocity", function()
        local _, agent = new_world_agent("hero")
        agent:setVelocity(3, 4)
        local vx, vy = agent:getVelocity()
        expect_near(3, vx, 0.01)
        expect_near(4, vy, 0.01)
    end)

    -- @covers LBot:getVelocity
    it("getVelocity returns two numbers", function()
        local _, agent = new_world_agent("hero")
        local vx, vy = agent:getVelocity()
        expect_type("number", vx)
        expect_type("number", vy)
    end)

    -- @covers LBot:setMaxSpeed
    it("setMaxSpeed updates bot max speed", function()
        local _, agent = new_world_agent("hero")
        agent:setMaxSpeed(12.5)
        expect_near(12.5, agent:getMaxSpeed(), 0.01)
    end)

    -- @covers LBot:getMaxSpeed
    it("getMaxSpeed returns a number", function()
        local _, agent = new_world_agent("hero")
        expect_type("number", agent:getMaxSpeed())
    end)

    -- @covers LBot:setMaxForce
    it("setMaxForce updates bot max force", function()
        local _, agent = new_world_agent("hero")
        agent:setMaxForce(8.0)
        expect_near(8.0, agent:getMaxForce(), 0.01)
    end)

    -- @covers LBot:getMaxForce
    it("getMaxForce returns a number", function()
        local _, agent = new_world_agent("hero")
        expect_type("number", agent:getMaxForce())
    end)

    -- @covers LBot:setPriority
    it("setPriority updates bot priority", function()
        local _, agent = new_world_agent("hero")
        agent:setPriority(7)
        expect_equal(7, agent:getPriority())
    end)

    -- @covers LBot:getPriority
    it("getPriority returns a number", function()
        local _, agent = new_world_agent("hero")
        expect_type("number", agent:getPriority())
    end)

    -- @covers LBot:setDecisionModel
    it("setDecisionModel updates valid decision models", function()
        local _, agent = new_world_agent("hero")
        agent:setDecisionModel("bt")
        expect_equal("bt", agent:getDecisionModel())
    end)

    -- @covers LBot:getDecisionModel
    it("getDecisionModel returns default fsm", function()
        local _, agent = new_world_agent("hero")
        expect_equal("fsm", agent:getDecisionModel())
    end)

    -- @covers LBot:setCustomModel
    it("setCustomModel installs a callback used during world updates", function()
        local world, agent = new_world_agent("hero")
        local called_dt = nil
        agent:setCustomModel(function(_, _, dt)
            called_dt = dt
        end)
        world:update(0.25)
        expect_near(0.25, called_dt, 0.001)
    end)

    -- @covers LBot:addTag
    it("addTag stores a tag", function()
        local _, agent = new_world_agent("hero")
        agent:addTag("scout")
        expect_true(agent:hasTag("scout"))
    end)

    -- @covers LBot:removeTag
    it("removeTag deletes a stored tag", function()
        local _, agent = new_world_agent("hero")
        agent:addTag("scout")
        agent:removeTag("scout")
        expect_false(agent:hasTag("scout"))
    end)

    -- @covers LBot:hasTag
    it("hasTag reports missing tags", function()
        local _, agent = new_world_agent("hero")
        expect_false(agent:hasTag("unknown"))
    end)

    -- @covers LBot:getBlackboard
    it("getBlackboard returns a blackboard", function()
        local _, agent = new_world_agent("hero")
        expect_equal("LAIBlackboard", agent:getBlackboard():type())
    end)

    -- @covers LBot:type
    it("type returns LBot", function()
        local _, agent = new_world_agent("hero")
        expect_equal("LBot", agent:type())
    end)

    -- @covers LBot:typeOf
    it("typeOf reports bot inheritance", function()
        local _, agent = new_world_agent("hero")
        expect_true(agent:typeOf("LBot"))
    end)
end)

-- @describe blackboard
describe("ai blackboard", function()
    -- @covers LAIBlackboard:setNumber
    it("setNumber stores numeric values", function()
        local bb = new_blackboard()
        bb:setNumber("hp", 10)
        expect_near(10, bb:getNumber("hp"), 0.01)
    end)

    -- @covers LAIBlackboard:getNumber
    it("getNumber returns default for missing key", function()
        expect_near(5, new_blackboard():getNumber("missing", 5), 0.01)
    end)

    -- @covers LAIBlackboard:setBool
    it("setBool stores boolean values", function()
        local bb = new_blackboard()
        bb:setBool("ready", true)
        expect_true(bb:getBool("ready"))
    end)

    -- @covers LAIBlackboard:getBool
    it("getBool returns false for missing key", function()
        expect_false(new_blackboard():getBool("missing"))
    end)

    -- @covers LAIBlackboard:setString
    it("setString stores string values", function()
        local bb = new_blackboard()
        bb:setString("name", "hero")
        expect_equal("hero", bb:getString("name"))
    end)

    -- @covers LAIBlackboard:getString
    it("getString returns default for missing key", function()
        expect_equal("none", new_blackboard():getString("missing", "none"))
    end)

    -- @covers LAIBlackboard:has
    it("has reports whether a key exists", function()
        local bb = new_blackboard()
        bb:setNumber("hp", 10)
        expect_true(bb:has("hp"))
    end)

    -- @covers LAIBlackboard:remove
    it("remove deletes one key", function()
        local bb = new_blackboard()
        bb:setNumber("hp", 10)
        bb:remove("hp")
        expect_false(bb:has("hp"))
    end)

    -- @covers LAIBlackboard:clear
    it("clear removes all keys", function()
        local bb = new_blackboard()
        bb:setNumber("a", 1)
        bb:setBool("b", true)
        bb:clear()
        expect_equal(0, bb:getSize())
    end)

    -- @covers LAIBlackboard:getKeys
    it("getKeys returns stored key names", function()
        local bb = new_blackboard()
        bb:setNumber("hp", 10)
        bb:setString("name", "hero")
        expect_equal(2, #bb:getKeys())
    end)

    -- @covers LAIBlackboard:getSize
    it("getSize returns key count", function()
        local bb = new_blackboard()
        bb:setNumber("hp", 10)
        bb:setBool("alive", true)
        expect_equal(2, bb:getSize())
    end)

    -- @covers LAIBlackboard:type
    it("type returns LAIBlackboard", function()
        expect_equal("LAIBlackboard", new_blackboard():type())
    end)

    -- @covers LAIBlackboard:typeOf
    it("typeOf reports blackboard inheritance", function()
        expect_true(new_blackboard():typeOf("LAIBlackboard"))
    end)
end)

-- @describe state machine
describe("ai state machine", function()
    -- @covers LStateMachine:addState
    it("addState accepts a state table", function()
        local fsm = lurek.ai.newStateMachine()
        expect_no_error(function()
            fsm:addState("idle", {})
        end)
    end)

    -- @covers LStateMachine:addTransition
    it("addTransition accepts a guard function", function()
        local fsm = lurek.ai.newStateMachine()
        fsm:addState("idle", {})
        fsm:addState("run", {})
        expect_no_error(function()
            fsm:addTransition("idle", "run", function() return true end, 1)
        end)
    end)

    -- @covers LStateMachine:setInitialState
    it("setInitialState chooses the current state", function()
        local fsm = lurek.ai.newStateMachine()
        fsm:addState("idle", {})
        fsm:setInitialState("idle")
        expect_equal("idle", fsm:getCurrentState())
    end)

    -- @covers LStateMachine:getCurrentState
    it("getCurrentState returns nil before initialization", function()
        expect_nil(lurek.ai.newStateMachine():getCurrentState())
    end)

    -- @covers LStateMachine:forceState
    it("forceState overrides the current state", function()
        local fsm = lurek.ai.newStateMachine()
        fsm:addState("idle", {})
        fsm:addState("run", {})
        fsm:setInitialState("idle")
        fsm:forceState("run")
        expect_equal("run", fsm:getCurrentState())
    end)

    -- @covers LStateMachine:getTimeInState
    it("getTimeInState returns a number", function()
        local fsm = lurek.ai.newStateMachine()
        fsm:addState("idle", {})
        fsm:setInitialState("idle")
        expect_type("number", fsm:getTimeInState())
    end)

    -- @covers LStateMachine:type
    it("type returns LStateMachine", function()
        expect_equal("LStateMachine", lurek.ai.newStateMachine():type())
    end)

    -- @covers LStateMachine:typeOf
    it("typeOf reports state machine inheritance", function()
        expect_true(lurek.ai.newStateMachine():typeOf("LStateMachine"))
    end)
end)

-- @describe behavior tree
describe("ai behavior tree", function()
    -- @covers LBehaviorTree:setRoot
    it("setRoot accepts a bt node", function()
        local tree = lurek.ai.newBehaviorTree()
        expect_no_error(function()
            tree:setRoot(lurek.ai.newSequence())
        end)
    end)

    -- @covers LBehaviorTree:getLastStatus
    it("getLastStatus returns success initially", function()
        expect_equal("success", lurek.ai.newBehaviorTree():getLastStatus())
    end)

    -- @covers LBehaviorTree:getDebugState
    it("getDebugState returns a table", function()
        expect_type("table", lurek.ai.newBehaviorTree():getDebugState())
    end)

    -- @covers LBehaviorTree:type
    it("type returns LBehaviorTree", function()
        expect_equal("LBehaviorTree", lurek.ai.newBehaviorTree():type())
    end)

    -- @covers LBehaviorTree:typeOf
    it("typeOf reports behavior tree inheritance", function()
        expect_true(lurek.ai.newBehaviorTree():typeOf("LBehaviorTree"))
    end)
end)

-- @describe bt nodes
describe("ai bt nodes", function()
    -- @covers LBTNode:addChild
    it("addChild appends child nodes", function()
        local parent = lurek.ai.newSelector()
        parent:addChild(lurek.ai.newAction(function() return "success" end))
        expect_equal(1, parent:getChildCount())
    end)

    -- @covers LBTNode:getChildCount
    it("getChildCount is zero for a new leaf node", function()
        expect_equal(0, lurek.ai.newAction(function() return "success" end):getChildCount())
    end)

    -- @covers LBTNode:reset
    it("reset is callable", function()
        expect_no_error(function()
            lurek.ai.newSelector():reset()
        end)
    end)

    -- @covers LBTNode:setChild
    it("setChild replaces a child slot", function()
        local parent = lurek.ai.newInverter()
        expect_no_error(function()
            parent:setChild(lurek.ai.newCondition(function() return true end))
        end)
    end)

    -- @covers LBTNode:setCount
    it("setCount updates node count metadata", function()
        local node = lurek.ai.newRepeater()
        node:setCount(3)
        expect_equal(3, node:getCount())
    end)

    -- @covers LBTNode:getCount
    it("getCount returns a number", function()
        expect_type("number", lurek.ai.newRepeater():getCount())
    end)

    -- @covers LBTNode:setSuccessPolicy
    it("setSuccessPolicy accepts a policy name", function()
        expect_no_error(function()
            lurek.ai.newParallel():setSuccessPolicy("all")
        end)
    end)

    -- @covers LBTNode:setFailurePolicy
    it("setFailurePolicy accepts a policy name", function()
        expect_no_error(function()
            lurek.ai.newParallel():setFailurePolicy("any")
        end)
    end)

    -- @covers LBTNode:getNodeType
    it("getNodeType returns selector for selector nodes", function()
        expect_equal("selector", lurek.ai.newSelector():getNodeType())
    end)

    -- @covers LBTNode:type
    it("type returns LBTNode", function()
        expect_equal("LBTNode", lurek.ai.newSequence():type())
    end)

    -- @covers LBTNode:typeOf
    it("typeOf reports bt node inheritance", function()
        expect_true(lurek.ai.newSequence():typeOf("LBTNode"))
    end)
end)

-- @describe steering manager
describe("ai steering manager", function()
    -- @covers LSteeringManager:addSeek
    it("addSeek increases behavior count", function()
        local sm = lurek.ai.newSteeringManager()
        sm:addSeek(100, 200)
        expect_equal(1, sm:getBehaviorCount())
    end)

    -- @covers LSteeringManager:addFlee
    it("addFlee increases behavior count", function()
        local sm = lurek.ai.newSteeringManager()
        sm:addFlee(0, 0)
        expect_equal(1, sm:getBehaviorCount())
    end)

    -- @covers LSteeringManager:addArrive
    it("addArrive increases behavior count", function()
        local sm = lurek.ai.newSteeringManager()
        sm:addArrive(50, 50)
        expect_equal(1, sm:getBehaviorCount())
    end)

    -- @covers LSteeringManager:addWander
    it("addWander increases behavior count", function()
        local sm = lurek.ai.newSteeringManager()
        sm:addWander()
        expect_equal(1, sm:getBehaviorCount())
    end)

    -- @covers LSteeringManager:addPursue
    it("addPursue steers toward a stored target entity", function()
        local sm = lurek.ai.newSteeringManager()
        sm:setEntity("target", 10, 0, 2, 0)
        sm:addPursue("target")
        local fx, fy = sm:calculate(0, 0, 0, 0, 100, 200, 1 / 60)
        expect_equal(1, sm:getBehaviorCount())
        expect_true(fx > 0, "pursue should steer toward target")
        expect_near(0, fy, 0.01)
    end)

    -- @covers LSteeringManager:addEvade
    it("addEvade steers away from a stored threat entity", function()
        local sm = lurek.ai.newSteeringManager()
        sm:setEntity("threat", 10, 0, 0, 0)
        sm:addEvade("threat")
        local fx, fy = sm:calculate(0, 0, 0, 0, 100, 200, 1 / 60)
        expect_equal(1, sm:getBehaviorCount())
        expect_true(fx < 0, "evade should steer away from threat")
        expect_near(0, fy, 0.01)
    end)

    -- @covers LSteeringManager:addFlock
    it("addFlock uses stored neighbors", function()
        local sm = lurek.ai.newSteeringManager()
        sm:setEntity("a", 3, 0, 1, 0)
        sm:setEntity("b", 0, 4, 0, 1)
        sm:addFlock()
        local fx, fy = sm:calculate(0, 0, 0, 0, 100, 200, 1 / 60)
        expect_equal(1, sm:getBehaviorCount())
        expect_true(math.abs(fx) > 0.001 or math.abs(fy) > 0.001, "flock should produce steering")
    end)

    -- @covers LSteeringManager:setEntity
    it("setEntity stores named steering context", function()
        local sm = lurek.ai.newSteeringManager()
        sm:setEntity("target", 8, 0)
        expect_equal(1, sm:entityCount())
    end)

    -- @covers LSteeringManager:removeEntity
    it("removeEntity returns whether an entity existed", function()
        local sm = lurek.ai.newSteeringManager()
        sm:setEntity("target", 8, 0, 0, 0)
        expect_true(sm:removeEntity("target"))
        expect_false(sm:removeEntity("target"))
    end)

    -- @covers LSteeringManager:clearEntities
    it("clearEntities removes all steering context", function()
        local sm = lurek.ai.newSteeringManager()
        sm:setEntity("a", 1, 0)
        sm:setEntity("b", 2, 0)
        sm:clearEntities()
        expect_equal(0, sm:entityCount())
    end)

    -- @covers LSteeringManager:entityCount
    it("entityCount reports stored steering entities", function()
        local sm = lurek.ai.newSteeringManager()
        expect_equal(0, sm:entityCount())
        sm:setEntity("a", 1, 0)
        expect_equal(1, sm:entityCount())
    end)

    -- @covers LSteeringManager:getBehaviorCount
    it("getBehaviorCount returns zero for a new manager", function()
        expect_equal(0, lurek.ai.newSteeringManager():getBehaviorCount())
    end)

    -- @covers LSteeringManager:setCombineMode
    it("setCombineMode updates the combine mode", function()
        local sm = lurek.ai.newSteeringManager()
        sm:setCombineMode("priority")
        expect_equal("priority", sm:getCombineMode())
    end)

    -- @covers LSteeringManager:getCombineMode
    it("getCombineMode returns a string", function()
        expect_type("string", lurek.ai.newSteeringManager():getCombineMode())
    end)

    -- @covers LSteeringManager:calculate
    it("calculate returns steering values", function()
        local sm = lurek.ai.newSteeringManager()
        sm:addSeek(100, 100)
        local fx, fy = sm:calculate(0, 0, 0, 0, 100, 200, 1 / 60)
        expect_type("number", fx)
        expect_type("number", fy)
    end)

    -- @covers LSteeringManager:getLastSteering
    it("getLastSteering returns the last steering pair", function()
        local sm = lurek.ai.newSteeringManager()
        sm:addSeek(100, 100)
        sm:calculate(0, 0, 0, 0, 100, 200, 1 / 60)
        local fx, fy = sm:getLastSteering()
        expect_type("number", fx)
        expect_type("number", fy)
    end)

    -- @covers LSteeringManager:setPath
    it("setPath accepts waypoint tables", function()
        local sm = lurek.ai.newSteeringManager()
        sm:setPath({ { x = 8, y = 8 }, { x = 16, y = 8 } })
        expect_true(sm:hasPath())
    end)

    -- @covers LSteeringManager:clearPath
    it("clearPath removes an active path", function()
        local sm = lurek.ai.newSteeringManager()
        sm:setPath({ { x = 8, y = 8 }, { x = 16, y = 8 } })
        sm:clearPath()
        expect_false(sm:hasPath())
    end)

    -- @covers LSteeringManager:hasPath
    it("hasPath is false by default", function()
        expect_false(lurek.ai.newSteeringManager():hasPath())
    end)

    -- @covers LSteeringManager:getPathProgress
    it("getPathProgress reports index and total", function()
        local sm = lurek.ai.newSteeringManager()
        sm:setPath({ { x = 8, y = 8 }, { x = 16, y = 8 } })
        local idx, total = sm:getPathProgress()
        expect_equal(1, idx)
        expect_equal(2, total)
    end)

    -- @covers LSteeringManager:type
    it("type returns LSteeringManager", function()
        expect_equal("LSteeringManager", lurek.ai.newSteeringManager():type())
    end)

    -- @covers LSteeringManager:typeOf
    it("typeOf reports steering manager inheritance", function()
        expect_true(lurek.ai.newSteeringManager():typeOf("LSteeringManager"))
    end)

    -- @covers LSteeringManager:setSpatialHashCellSize
    it("setSpatialHashCellSize accepts a custom cell size", function()
        local sm = lurek.ai.newSteeringManager()
        expect_no_error(function()
            sm:setSpatialHashCellSize(24.0)
        end)
    end)

    -- @covers LSteeringManager:enableSpatialHash
    it("enableSpatialHash toggles spatial hash acceleration", function()
        local sm = lurek.ai.newSteeringManager()
        expect_no_error(function()
            sm:enableSpatialHash(true)
            sm:enableSpatialHash(false)
        end)
    end)

    -- @covers LSteeringManager:addCustomBehavior
    it("addCustomBehavior accepts a Lua steering callback", function()
        local sm = lurek.ai.newSteeringManager()
        expect_no_error(function()
            sm:addCustomBehavior(function(_, _)
                return 1.0, -0.5
            end, 0.75)
        end)
    end)

    -- @covers LSteeringManager:applyCustomSteering
    it("applyCustomSteering combines custom behavior forces", function()
        local _, agent = new_world_agent("pusher")
        local sm = lurek.ai.newSteeringManager()
        sm:addCustomBehavior(function(_, _)
            return 25, -10
        end, 1.0)
        local fx, fy = sm:applyCustomSteering(agent, 1 / 60)
        expect_near(25, fx, 0.01)
        expect_near(-10, fy, 0.01)
    end)
end)

-- @describe goap planner
describe("ai goap planner", function()
    -- @covers LGOAPPlanner:addAction
    it("addAction increases action count", function()
        local planner = lurek.ai.newGOAPPlanner()
        planner:addAction("gather_wood", 1.0)
        expect_equal(1, planner:getActionCount())
    end)

    -- @covers LGOAPPlanner:setPrecondition
    it("setPrecondition is callable for an action", function()
        local planner = lurek.ai.newGOAPPlanner()
        planner:addAction("chop", 1.0)
        expect_no_error(function()
            planner:setPrecondition("chop", "has_axe", true)
        end)
    end)

    -- @covers LGOAPPlanner:setEffect
    it("setEffect is callable for an action", function()
        local planner = lurek.ai.newGOAPPlanner()
        planner:addAction("chop", 1.0)
        expect_no_error(function()
            planner:setEffect("chop", "has_wood", true)
        end)
    end)

    -- @covers LGOAPPlanner:addGoal
    it("addGoal increases goal count", function()
        local planner = lurek.ai.newGOAPPlanner()
        planner:addGoal("build_house", 1.0)
        expect_equal(1, planner:getGoalCount())
    end)

    -- @covers LGOAPPlanner:setGoalState
    it("setGoalState is callable for a goal", function()
        local planner = lurek.ai.newGOAPPlanner()
        planner:addGoal("build_house", 1.0)
        expect_no_error(function()
            planner:setGoalState("build_house", "has_house", true)
        end)
    end)

    -- @covers LGOAPPlanner:plan
    it("plan returns a non-empty action table for reachable goals", function()
        local planner = lurek.ai.newGOAPPlanner()
        planner:addAction("get_axe", 1.0)
        planner:setEffect("get_axe", "has_axe", true)
        planner:addAction("chop_tree", 2.0)
        planner:setPrecondition("chop_tree", "has_axe", true)
        planner:setEffect("chop_tree", "has_wood", true)
        planner:addGoal("gather", 1.0)
        planner:setGoalState("gather", "has_wood", true)
        local plan = planner:plan({ has_axe = false, has_wood = false })
        expect_true(type(plan) == "table" and #plan > 0)
    end)

    -- @covers LGOAPPlanner:getActionCount
    it("getActionCount is zero for a new planner", function()
        expect_equal(0, lurek.ai.newGOAPPlanner():getActionCount())
    end)

    -- @covers LGOAPPlanner:getGoalCount
    it("getGoalCount is zero for a new planner", function()
        expect_equal(0, lurek.ai.newGOAPPlanner():getGoalCount())
    end)

    -- @covers LGOAPPlanner:getMaxIterations
    it("getMaxIterations returns a number", function()
        expect_type("number", lurek.ai.newGOAPPlanner():getMaxIterations())
    end)

    -- @covers LGOAPPlanner:setMaxIterations
    it("setMaxIterations updates the planner cap", function()
        local planner = lurek.ai.newGOAPPlanner()
        planner:setMaxIterations(500)
        expect_equal(500, planner:getMaxIterations())
    end)

    -- @covers LGOAPPlanner:type
    it("type returns LGOAPPlanner", function()
        expect_equal("LGOAPPlanner", lurek.ai.newGOAPPlanner():type())
    end)

    -- @covers LGOAPPlanner:typeOf
    it("typeOf reports planner inheritance", function()
        expect_true(lurek.ai.newGOAPPlanner():typeOf("LGOAPPlanner"))
    end)
end)

-- @describe influence map
describe("ai influence map", function()
    -- @covers LInfluenceMap:addLayer
    it("addLayer registers a named layer", function()
        local map = new_influence_map()
        map:addLayer("danger")
        expect_true(map:hasLayer("danger"))
    end)

    -- @covers LInfluenceMap:hasLayer
    it("hasLayer returns false before a layer is added", function()
        expect_false(new_influence_map():hasLayer("danger"))
    end)

    -- @covers LInfluenceMap:setInfluence
    it("setInfluence writes one cell value", function()
        local map = new_influence_map()
        map:addLayer("danger")
        map:setInfluence("danger", 2, 2, 0.75)
        expect_near(0.75, map:getInfluence("danger", 2, 2), 0.01)
    end)

    -- @covers LInfluenceMap:getInfluence
    it("getInfluence returns a number", function()
        local map = new_influence_map()
        map:addLayer("danger")
        expect_type("number", map:getInfluence("danger", 1, 1))
    end)

    -- @covers LInfluenceMap:clearLayer
    it("clearLayer resets values on one layer", function()
        local map = new_influence_map()
        map:addLayer("danger")
        map:setInfluence("danger", 2, 2, 0.75)
        map:clearLayer("danger")
        expect_near(0.0, map:getInfluence("danger", 2, 2), 0.01)
    end)

    -- @covers LInfluenceMap:clearAll
    it("clearAll removes every layer", function()
        local map = new_influence_map()
        map:addLayer("danger")
        map:setInfluence("danger", 2, 2, 0.75)
        map:clearAll()
        expect_near(0.0, map:getInfluence("danger", 2, 2), 0.01)
    end)

    -- @covers LInfluenceMap:getWidth
    it("getWidth returns configured width", function()
        expect_equal(4, new_influence_map():getWidth())
    end)

    -- @covers LInfluenceMap:getHeight
    it("getHeight returns configured height", function()
        expect_equal(3, new_influence_map():getHeight())
    end)

    -- @covers LInfluenceMap:getCellSize
    it("getCellSize returns configured cell size", function()
        expect_near(2, new_influence_map():getCellSize(), 0.01)
    end)

    -- @covers LInfluenceMap:type
    it("type returns LInfluenceMap", function()
        expect_equal("LInfluenceMap", new_influence_map():type())
    end)

    -- @covers LInfluenceMap:typeOf
    it("typeOf reports influence map inheritance", function()
        expect_true(new_influence_map():typeOf("LInfluenceMap"))
    end)
end)

-- @describe command queue
describe("ai command queue", function()
    -- @covers LCommandQueue:enqueue
    it("enqueue adds one command", function()
        local queue = lurek.ai.newCommandQueue()
        queue:enqueue("move", function() end)
        expect_equal(1, queue:getCount())
    end)

    -- @covers LCommandQueue:pushFront
    it("pushFront adds one command", function()
        local queue = lurek.ai.newCommandQueue()
        queue:pushFront("move", function() end)
        expect_equal(1, queue:getCount())
    end)

    -- @covers LCommandQueue:replace
    it("replace resets queue contents", function()
        local queue = lurek.ai.newCommandQueue()
        queue:enqueue("move", function() end)
        queue:replace("attack", function() end)
        expect_equal(1, queue:getCount())
    end)

    -- @covers LCommandQueue:cancelCurrent
    it("cancelCurrent is callable", function()
        local queue = lurek.ai.newCommandQueue()
        queue:enqueue("move", function() end)
        expect_no_error(function()
            queue:cancelCurrent()
        end)
    end)

    -- @covers LCommandQueue:clear
    it("clear removes queued commands", function()
        local queue = lurek.ai.newCommandQueue()
        queue:enqueue("move", function() end)
        queue:clear()
        expect_true(queue:isEmpty())
    end)

    -- @covers LCommandQueue:getCount
    it("getCount returns zero for a new queue", function()
        expect_equal(0, lurek.ai.newCommandQueue():getCount())
    end)

    -- @covers LCommandQueue:isEmpty
    it("isEmpty returns true for a new queue", function()
        expect_true(lurek.ai.newCommandQueue():isEmpty())
    end)

    -- @covers LCommandQueue:getCurrentType
    it("getCurrentType returns nil for a new queue", function()
        expect_nil(lurek.ai.newCommandQueue():getCurrentType())
    end)

    -- @covers LCommandQueue:getCurrentTarget
    it("getCurrentTarget returns nil for a new queue", function()
        local x, y = lurek.ai.newCommandQueue():getCurrentTarget()
        expect_type("number", x)
        expect_type("number", y)
    end)

    -- @covers LCommandQueue:type
    it("type returns LCommandQueue", function()
        expect_equal("LCommandQueue", lurek.ai.newCommandQueue():type())
    end)

    -- @covers LCommandQueue:typeOf
    it("typeOf reports command queue inheritance", function()
        expect_true(lurek.ai.newCommandQueue():typeOf("LCommandQueue"))
    end)
end)

-- @describe utility ai
describe("ai utility ai", function()
    -- @covers LUtilityAI:addAction
    it("addAction registers an action scorer", function()
        local uai = lurek.ai.newUtilityAI()
        uai:addAction("eat", function() return 0.8 end, 1.0)
        expect_equal(1, uai:getActionCount())
    end)

    -- @covers LUtilityAI:evaluate
    it("evaluate returns the best scoring action name", function()
        local uai = lurek.ai.newUtilityAI()
        uai:addAction("attack", function() return 0.9 end)
        uai:addAction("defend", function() return 0.4 end)
        expect_equal("attack", uai:evaluate())
    end)

    -- @covers LUtilityAI:getActionCount
    it("getActionCount returns the number of registered actions", function()
        local uai = lurek.ai.newUtilityAI()
        uai:addAction("patrol", function() return 0.5 end)
        uai:addAction("idle", function() return 0.1 end)
        uai:addAction("chase", function() return 0.7 end)
        expect_equal(3, uai:getActionCount())
    end)

    -- @covers LUtilityAI:getLastAction
    it("getLastAction returns the last evaluated winner", function()
        local uai = lurek.ai.newUtilityAI()
        uai:addAction("gather", function() return 0.6 end)
        uai:addAction("build", function() return 0.2 end)
        uai:evaluate()
        expect_equal("gather", uai:getLastAction())
    end)

    -- @covers LUtilityAI:addConsideration
    it("addConsideration augments an existing action", function()
        local uai = lurek.ai.newUtilityAI()
        uai:addAction("heal", function() return 0.5 end)
        uai:addConsideration(
            "heal",
            "low_health",
            function() return 0.9 end,
            "linear",
            1.0,
            0.0,
            0.0,
            1.0
        )
        expect_equal("heal", uai:evaluate())
    end)

    -- @covers LUtilityAI:type
    it("type returns LUtilityAI", function()
        expect_equal("LUtilityAI", lurek.ai.newUtilityAI():type())
    end)

    -- @covers LUtilityAI:typeOf
    it("typeOf reports utility ai inheritance", function()
        expect_true(lurek.ai.newUtilityAI():typeOf("LUtilityAI"))
    end)
end)

-- @describe influence map advanced
describe("ai influence map advanced", function()
    -- @covers LInfluenceMap:stampInfluence
    it("stampInfluence writes radial influence into nearby cells", function()
        local map = lurek.ai.newInfluenceMap(20, 20, 1.0)
        map:addLayer("noise")
        map:stampInfluence("noise", 10.0, 10.0, 3.0, 1.0, 0.5)
        expect_true(map:getInfluence("noise", 10, 10) > 0.0)
    end)

    -- @covers LInfluenceMap:propagate
    it("propagate spreads influence to neighboring cells", function()
        local map = lurek.ai.newInfluenceMap(10, 10, 1.0)
        map:addLayer("scent")
        map:setInfluence("scent", 5, 5, 1.0)
        map:propagate("scent", 0.8)
        expect_true(map:getInfluence("scent", 4, 5) > 0.0)
    end)

    -- @covers LInfluenceMap:decay
    it("decay reduces stored influence values", function()
        local map = lurek.ai.newInfluenceMap(8, 8, 1.0)
        map:addLayer("heat")
        map:setInfluence("heat", 4, 4, 1.0)
        map:decay("heat", 0.5)
        expect_true(map:getInfluence("heat", 4, 4) < 1.0)
    end)

    -- @covers LInfluenceMap:getMaxPosition
    it("getMaxPosition returns the strongest cell coordinates", function()
        local map = lurek.ai.newInfluenceMap(10, 10, 1.0)
        map:addLayer("gold")
        map:setInfluence("gold", 7, 3, 0.9)
        map:setInfluence("gold", 2, 8, 0.4)
        local x, y = map:getMaxPosition("gold")
        expect_near(6.5, x, 0.01)
        expect_near(2.5, y, 0.01)
    end)

    -- @covers LInfluenceMap:getMinPosition
    it("getMinPosition returns the weakest cell coordinates", function()
        local map = lurek.ai.newInfluenceMap(10, 10, 1.0)
        map:addLayer("cold")
        map:setInfluence("cold", 1, 1, -0.5)
        map:setInfluence("cold", 5, 5, 0.3)
        local x, y = map:getMinPosition("cold")
        expect_near(0.5, x, 0.01)
        expect_near(0.5, y, 0.01)
    end)

    -- @covers LInfluenceMap:queryRect
    it("queryRect sums influence inside a rectangle", function()
        local map = lurek.ai.newInfluenceMap(10, 10, 1.0)
        map:addLayer("energy")
        map:setInfluence("energy", 2, 2, 0.5)
        map:setInfluence("energy", 3, 3, 0.5)
        expect_near(1.0, map:queryRect("energy", 1, 1, 4, 4), 0.01)
    end)

    -- @covers LInfluenceMap:blend
    it("blend writes a weighted combined layer", function()
        local map = lurek.ai.newInfluenceMap(8, 8, 1.0)
        map:addLayer("threat")
        map:addLayer("reward")
        map:addLayer("combined")
        map:setInfluence("threat", 4, 4, 1.0)
        map:setInfluence("reward", 4, 4, 0.8)
        map:blend("threat", 0.5, "reward", 0.5, "combined")
        expect_near(0.9, map:getInfluence("combined", 4, 4), 0.01)
    end)
end)

-- @describe squad
describe("ai squad", function()
    -- @covers LSquad:getName
    it("getName returns the squad name", function()
        expect_equal("alpha", lurek.ai.newSquad("alpha"):getName())
    end)

    -- @covers LSquad:addMember
    it("addMember appends a member to the squad", function()
        local squad = lurek.ai.newSquad("bravo")
        squad:addMember("soldier_1")
        expect_equal(1, squad:getMemberCount())
    end)

    -- @covers LSquad:removeMember
    it("removeMember deletes matching members", function()
        local squad = lurek.ai.newSquad("charlie")
        squad:addMember("scout")
        squad:addMember("medic")
        squad:removeMember("scout")
        expect_equal(1, squad:getMemberCount())
    end)

    -- @covers LSquad:getMemberCount
    it("getMemberCount returns the squad size", function()
        local squad = lurek.ai.newSquad("delta")
        squad:addMember("a")
        squad:addMember("b")
        squad:addMember("c")
        expect_equal(3, squad:getMemberCount())
    end)

    -- @covers LSquad:getMembers
    it("getMembers returns member names in order", function()
        local squad = lurek.ai.newSquad("echo")
        squad:addMember("sniper")
        squad:addMember("heavy")
        local members = squad:getMembers()
        expect_equal(2, #members)
        expect_equal("sniper", members[1])
        expect_equal("heavy", members[2])
    end)

    -- @covers LSquad:setLeader
    it("setLeader stores the squad leader name", function()
        local squad = lurek.ai.newSquad("foxtrot")
        squad:setLeader("captain")
        expect_equal("captain", squad:getLeader())
    end)

    -- @covers LSquad:getLeader
    it("getLeader returns the current leader name", function()
        local squad = lurek.ai.newSquad("golf")
        squad:setLeader("commander")
        expect_equal("commander", squad:getLeader())
    end)

    -- @covers LSquad:setFormation
    it("setFormation accepts a formation type and spacing", function()
        local squad = lurek.ai.newSquad("hotel")
        squad:setFormation("wedge", 2.0)
        expect_equal("wedge", squad:getFormation())
    end)

    -- @covers LSquad:getFormation
    it("getFormation returns the stored formation name", function()
        local squad = lurek.ai.newSquad("recon")
        squad:setFormation("line", 3.0)
        expect_equal("line", squad:getFormation())
    end)

    -- @covers LSquad:getFormationSpacing
    it("getFormationSpacing returns the stored spacing", function()
        local squad = lurek.ai.newSquad("assault")
        squad:setFormation("wedge", 2.5)
        expect_near(2.5, squad:getFormationSpacing(), 0.01)
    end)

    -- @covers LSquad:getFormationPosition
    it("getFormationPosition returns numeric slot coordinates", function()
        local squad = lurek.ai.newSquad("patrol")
        squad:addMember("lead")
        squad:addMember("flank_l")
        squad:addMember("flank_r")
        squad:setFormation("wedge", 2.0)
        local x, y = squad:getFormationPosition(2, 100.0, 50.0)
        expect_type("number", x)
        expect_type("number", y)
    end)

    -- @covers LSquad:getBlackboard
    it("getBlackboard returns a writable squad blackboard snapshot", function()
        local squad = lurek.ai.newSquad("intel")
        local bb = squad:getBlackboard()
        bb:setNumber("threat_level", 3)
        expect_near(3, bb:getNumber("threat_level"), 0.01)
    end)

    -- @covers LSquad:type
    it("type returns LSquad", function()
        expect_equal("LSquad", lurek.ai.newSquad("test"):type())
    end)

    -- @covers LSquad:typeOf
    it("typeOf reports squad inheritance", function()
        expect_true(lurek.ai.newSquad("test2"):typeOf("LSquad"))
    end)
end)

-- @describe trait profile
describe("ai trait profile", function()
    -- @covers LTraitProfile:set
    it("set stores a base trait value", function()
        local profile = lurek.ai.newTraitProfile()
        profile:set("courage", 0.7)
        expect_near(0.7, profile:get("courage"), 0.01)
    end)

    -- @covers LTraitProfile:get
    it("get returns the effective value including modifiers", function()
        local profile = lurek.ai.newTraitProfile()
        profile:set("speed", 0.3)
        profile:addModifier("speed", 0.5, 5.0, "buff")
        expect_near(0.8, profile:get("speed"), 0.01)
    end)

    -- @covers LTraitProfile:getBase
    it("getBase ignores temporary modifiers", function()
        local profile = lurek.ai.newTraitProfile()
        profile:set("strength", 0.8)
        profile:addModifier("strength", 0.2, 10.0, "potion")
        expect_near(0.8, profile:getBase("strength"), 0.01)
    end)

    -- @covers LTraitProfile:addModifier
    it("addModifier changes the effective trait value", function()
        local profile = lurek.ai.newTraitProfile()
        profile:set("defense", 0.5)
        profile:addModifier("defense", 0.3, 8.0, "shield_spell")
        expect_near(0.8, profile:get("defense"), 0.01)
    end)

    -- @covers LTraitProfile:removeModifiers
    it("removeModifiers removes modifiers by source label", function()
        local profile = lurek.ai.newTraitProfile()
        profile:set("luck", 0.4)
        profile:addModifier("luck", 0.2, 10.0, "charm")
        profile:addModifier("luck", 0.1, 5.0, "charm")
        profile:removeModifiers("charm")
        expect_near(0.4, profile:get("luck"), 0.01)
    end)

    -- @covers LTraitProfile:update
    it("update expires elapsed modifiers", function()
        local profile = lurek.ai.newTraitProfile()
        profile:set("rage", 0.5)
        profile:addModifier("rage", 0.5, 2.0, "berserk")
        profile:update(3.0)
        expect_near(0.5, profile:get("rage"), 0.01)
    end)

    -- @covers LTraitProfile:has
    it("has reports whether a trait exists", function()
        local profile = lurek.ai.newTraitProfile()
        profile:set("wisdom", 0.6)
        expect_true(profile:has("wisdom"))
    end)

    -- @covers LTraitProfile:traitCount
    it("traitCount returns the number of stored traits", function()
        local profile = lurek.ai.newTraitProfile()
        profile:set("a", 0.1)
        profile:set("b", 0.2)
        profile:set("c", 0.3)
        expect_equal(3, profile:traitCount())
    end)

    -- @covers LTraitProfile:archetype
    it("archetype returns nil for a fresh profile without archetype metadata", function()
        expect_nil(lurek.ai.newTraitProfile():archetype())
    end)

    -- @covers LTraitProfile:type
    it("type returns LTraitProfile", function()
        expect_equal("LTraitProfile", lurek.ai.newTraitProfile():type())
    end)

    -- @covers LTraitProfile:typeOf
    it("typeOf reports trait profile inheritance", function()
        expect_true(lurek.ai.newTraitProfile():typeOf("LTraitProfile"))
    end)
end)

-- @describe stimulus world
describe("ai stimulus world", function()
    -- @covers LStimulusWorld:addVisual
    it("addVisual returns a stimulus id and increases count", function()
        local world = lurek.ai.newStimulusWorld()
        local id = world:addVisual(100, 200, 0.8, 50.0, "enemy_spotted")
        expect_equal(0, id)
        expect_equal(1, world:count())
    end)

    -- @covers LStimulusWorld:addAuditory
    it("addAuditory returns a stimulus id and increases count", function()
        local world = lurek.ai.newStimulusWorld()
        local id = world:addAuditory(50, 80, 0.6, 30.0, 0.1, "footstep")
        expect_equal(0, id)
        expect_equal(1, world:count())
    end)

    -- @covers LStimulusWorld:remove
    it("remove deletes a stimulus by id", function()
        local world = lurek.ai.newStimulusWorld()
        local id = world:addVisual(10, 10, 1.0, 20.0, "flash")
        expect_true(world:remove(id))
    end)

    -- @covers LStimulusWorld:update
    it("update decays auditory stimuli until they expire", function()
        local world = lurek.ai.newStimulusWorld()
        world:addAuditory(0, 0, 1.0, 10.0, 0.5, "bang")
        world:update(5.0)
        expect_equal(0, world:count())
    end)

    -- @covers LStimulusWorld:count
    it("count returns the number of active stimuli", function()
        local world = lurek.ai.newStimulusWorld()
        world:addVisual(0, 0, 1.0, 10.0, "a")
        world:addVisual(5, 5, 0.5, 8.0, "b")
        expect_equal(2, world:count())
    end)

    -- @covers LStimulusWorld:clear
    it("clear removes every active stimulus", function()
        local world = lurek.ai.newStimulusWorld()
        world:addVisual(0, 0, 1.0, 10.0, "x")
        world:addAuditory(1, 1, 0.5, 5.0, 0.2, "y")
        world:clear()
        expect_equal(0, world:count())
    end)

    -- @covers LStimulusWorld:type
    it("type returns LStimulusWorld", function()
        expect_equal("LStimulusWorld", lurek.ai.newStimulusWorld():type())
    end)

    -- @covers LStimulusWorld:typeOf
    it("typeOf reports stimulus world inheritance", function()
        expect_true(lurek.ai.newStimulusWorld():typeOf("LStimulusWorld"))
    end)
end)

-- @describe context steering
describe("ai context steering", function()
    -- @covers LContextSteering:addSeekTarget
    it("addSeekTarget accepts a target attraction behavior", function()
        local cs = lurek.ai.newContextSteering(8)
        expect_no_error(function()
            cs:addSeekTarget(200, 150, 1.0)
        end)
    end)

    -- @covers LContextSteering:addWander
    it("addWander accepts a wander behavior", function()
        local cs = lurek.ai.newContextSteering(8)
        expect_no_error(function()
            cs:addWander(0.3, 0.5)
        end)
    end)

    -- @covers LContextSteering:addAvoidPoint
    it("addAvoidPoint accepts a point avoidance behavior", function()
        local cs = lurek.ai.newContextSteering(8)
        expect_no_error(function()
            cs:addAvoidPoint(50, 50, 20.0, 1.5)
        end)
    end)

    -- @covers LContextSteering:addAvoidBounds
    it("addAvoidBounds accepts rectangular avoidance bounds", function()
        local cs = lurek.ai.newContextSteering(8)
        expect_no_error(function()
            cs:addAvoidBounds(0, 0, 800, 600, 30.0, 1.0)
        end)
    end)

    -- @covers LContextSteering:clearBehaviors
    it("clearBehaviors removes configured steering behaviors", function()
        local cs = lurek.ai.newContextSteering(8)
        cs:addSeekTarget(100, 100, 1.0)
        cs:addAvoidPoint(50, 50, 10.0, 1.0)
        expect_no_error(function()
            cs:clearBehaviors()
        end)
    end)

    -- @covers LContextSteering:evaluate
    it("evaluate returns a chosen steering direction", function()
        local cs = lurek.ai.newContextSteering(8)
        cs:addSeekTarget(300, 200, 1.0)
        cs:addAvoidPoint(150, 150, 30.0, 2.0)
        local dx, dy = cs:evaluate(100, 100, 1.0, 0.0)
        expect_true(math.abs(dx) > 0 or math.abs(dy) > 0)
    end)

    -- @covers LContextSteering:chosenMagnitude
    it("chosenMagnitude reports the last selected slot strength", function()
        local cs = lurek.ai.newContextSteering(8)
        cs:addSeekTarget(200, 200, 1.0)
        cs:evaluate(0, 0, 0, 0)
        expect_true(cs:chosenMagnitude() > 0.0)
    end)

    -- @covers LContextSteering:slotCount
    it("slotCount returns the configured number of slots", function()
        expect_equal(16, lurek.ai.newContextSteering(16):slotCount())
    end)

    -- @covers LContextSteering:type
    it("type returns LContextSteering", function()
        expect_equal("LContextSteering", lurek.ai.newContextSteering(8):type())
    end)

    -- @covers LContextSteering:typeOf
    it("typeOf reports context steering inheritance", function()
        expect_true(lurek.ai.newContextSteering(8):typeOf("LContextSteering"))
    end)
end)

-- @describe need system
describe("ai need system", function()
    -- @covers LNeedSystem:addNeed
    it("addNeed registers a named need", function()
        local needs = lurek.ai.newNeedSystem()
        needs:addNeed("hunger", 0.1, 0.7, 2.0)
        expect_near(1.0, needs:valueOf("hunger"), 0.01)
    end)

    -- @covers LNeedSystem:update
    it("update decays need values over time", function()
        local needs = lurek.ai.newNeedSystem()
        needs:addNeed("fatigue", 0.05, 0.8, 1.0)
        needs:update(2.0)
        expect_near(0.9, needs:valueOf("fatigue"), 0.01)
    end)

    -- @covers LNeedSystem:mostUrgent
    it("mostUrgent returns the highest urgency need name", function()
        local needs = lurek.ai.newNeedSystem()
        needs:addNeed("hunger", 0.5, 0.3, 2.0)
        needs:addNeed("thirst", 0.15, 0.6, 1.5)
        needs:update(1.0)
        expect_equal("hunger", needs:mostUrgent())
    end)

    -- @covers LNeedSystem:satisfy
    it("satisfy restores a decayed need value", function()
        local needs = lurek.ai.newNeedSystem()
        needs:addNeed("food", 0.1, 0.7, 1.0)
        needs:update(2.0)
        needs:satisfy("food", 0.1)
        expect_near(0.9, needs:valueOf("food"), 0.01)
    end)

    -- @covers LNeedSystem:valueOf
    it("valueOf returns the current need value", function()
        local needs = lurek.ai.newNeedSystem()
        needs:addNeed("thirst", 0.15, 0.6, 1.5)
        needs:update(1.0)
        expect_near(0.85, needs:valueOf("thirst"), 0.01)
    end)

    -- @covers LNeedSystem:type
    it("type returns LNeedSystem", function()
        expect_equal("LNeedSystem", lurek.ai.newNeedSystem():type())
    end)

    -- @covers LNeedSystem:typeOf
    it("typeOf reports need system inheritance", function()
        expect_true(lurek.ai.newNeedSystem():typeOf("LNeedSystem"))
    end)
end)

-- @describe ai director
describe("ai director", function()
    -- @covers LAIDirector:pushEvent
    it("pushEvent increases tension using clamped event intensity", function()
        local director = lurek.ai.newAIDirector()
        director:pushEvent(0.5)
        director:pushEvent(0.8)
        expect_near(0.5, director:tension(), 0.01)
    end)

    -- @covers LAIDirector:update
    it("update advances phase evaluation and tension decay", function()
        local director = lurek.ai.newAIDirector()
        director:setTension(0.6)
        director:update(2.0)
        expect_equal("build_up", director:phase())
    end)

    -- @covers LAIDirector:tension
    it("tension returns the current tension value", function()
        local director = lurek.ai.newAIDirector()
        director:setTension(0.6)
        expect_near(0.6, director:tension(), 0.01)
    end)

    -- @covers LAIDirector:phase
    it("phase returns the default pacing phase", function()
        expect_equal("relief", lurek.ai.newAIDirector():phase())
    end)

    -- @covers LAIDirector:spawnRateFactor
    it("spawnRateFactor reflects peak pacing pressure", function()
        local director = lurek.ai.newAIDirector()
        director:setTension(0.9)
        director:update(0.1)
        expect_near(2.0, director:spawnRateFactor(), 0.01)
    end)

    -- @covers LAIDirector:lootFactor
    it("lootFactor is high during relief", function()
        expect_near(2.5, lurek.ai.newAIDirector():lootFactor(), 0.01)
    end)

    -- @covers LAIDirector:ambientIntensity
    it("ambientIntensity follows current tension and phase", function()
        local director = lurek.ai.newAIDirector()
        director:setTension(0.7)
        director:update(0.1)
        expect_true(director:ambientIntensity() > 0.6)
    end)

    -- @covers LAIDirector:setTension
    it("setTension stores a clamped tension value", function()
        local director = lurek.ai.newAIDirector()
        director:setTension(0.5)
        expect_near(0.5, director:tension(), 0.01)
    end)

    -- @covers LAIDirector:reset
    it("reset restores the default tension and phase", function()
        local director = lurek.ai.newAIDirector()
        director:setTension(0.9)
        director:reset()
        expect_near(0.0, director:tension(), 0.01)
    end)

    -- @covers LAIDirector:type
    it("type returns LAIDirector", function()
        expect_equal("LAIDirector", lurek.ai.newAIDirector():type())
    end)

    -- @covers LAIDirector:typeOf
    it("typeOf reports ai director inheritance", function()
        expect_true(lurek.ai.newAIDirector():typeOf("LAIDirector"))
    end)
end)

-- @describe htn domain
describe("ai htn domain", function()
    -- @covers LHTNDomain:addPrimitive
    it("addPrimitive increases the defined task count", function()
        local htn = lurek.ai.newHTNDomain()
        htn:addPrimitive("chop", { "has_axe" }, { "has_wood" }, {})
        expect_equal(1, htn:taskCount())
    end)

    -- @covers LHTNDomain:addCompound
    it("addCompound registers a compound task definition", function()
        local htn = lurek.ai.newHTNDomain()
        htn:addPrimitive("mine", {}, { "has_ore" }, {})
        htn:addPrimitive("smelt", { "has_ore" }, { "has_metal" }, { "has_ore" })
        htn:addCompound("get_metal", {
            { name = "mine_and_smelt", preconditions = {}, sub_tasks = { "mine", "smelt" } },
        })
        expect_equal(3, htn:taskCount())
    end)

    -- @covers LHTNDomain:plan
    it("plan returns primitive tasks in execution order", function()
        local htn = lurek.ai.newHTNDomain()
        htn:addPrimitive("gather", {}, { "has_food" }, {})
        htn:addPrimitive("cook", { "has_food" }, { "meal_ready" }, { "has_food" })
        htn:addCompound("prepare_meal", {
            { name = "full_cook", preconditions = {}, sub_tasks = { "gather", "cook" } },
        })
        local plan = htn:plan("prepare_meal", { has_food = 0, meal_ready = 0 })
        expect_equal(2, #plan)
        expect_equal("gather", plan[1])
        expect_equal("cook", plan[2])
    end)

    -- @covers LHTNDomain:taskCount
    it("taskCount returns the number of domain tasks", function()
        local htn = lurek.ai.newHTNDomain()
        htn:addPrimitive("a", {}, {}, {})
        htn:addPrimitive("b", {}, {}, {})
        expect_equal(2, htn:taskCount())
    end)

    -- @covers LHTNDomain:type
    it("type returns LHTNDomain", function()
        expect_equal("LHTNDomain", lurek.ai.newHTNDomain():type())
    end)

    -- @covers LHTNDomain:typeOf
    it("typeOf reports htn domain inheritance", function()
        expect_true(lurek.ai.newHTNDomain():typeOf("LHTNDomain"))
    end)
end)

-- @describe mcts engine
describe("ai mcts engine", function()
    -- @covers LMCTSEngine:search
    it("search returns the only available action when search is deterministic", function()
        local mcts = lurek.ai.newMCTSEngine(20, 1.4, 4, 42)
        local action = mcts:search(
            1,
            function(_) return { 7 } end,
            function(state, act) return state + act end,
            function(_) return 1.0 end
        )
        expect_equal(7, action)
    end)

    -- @covers LMCTSEngine:type
    it("type returns LMCTSEngine", function()
        expect_equal("LMCTSEngine", lurek.ai.newMCTSEngine(50, 1.0, 5, 0):type())
    end)

    -- @covers LMCTSEngine:typeOf
    it("typeOf reports mcts inheritance", function()
        expect_true(lurek.ai.newMCTSEngine(50, 1.0, 5, 0):typeOf("LMCTSEngine"))
    end)
end)

-- @describe emotion model
describe("ai emotion model", function()
    -- @covers LEmotionModel:add
    it("add registers an emotion with its rest value", function()
        local model = lurek.ai.newEmotionModel()
        model:add("joy", 0.3, 0.1, 0.2)
        expect_near(0.3, model:get("joy"), 0.01)
    end)

    -- @covers LEmotionModel:trigger
    it("trigger raises the current emotion value", function()
        local model = lurek.ai.newEmotionModel()
        model:add("fear", 0.0, 0.1, 0.2)
        model:trigger("fear", 0.7)
        expect_near(0.7, model:get("fear"), 0.01)
    end)

    -- @covers LEmotionModel:get
    it("get returns the current emotion value", function()
        local model = lurek.ai.newEmotionModel()
        model:add("sadness", 0.2, 0.05, 0.1)
        model:trigger("sadness", 0.5)
        expect_near(0.7, model:get("sadness"), 0.01)
    end)

    -- @covers LEmotionModel:dominant
    it("dominant returns the strongest active emotion name", function()
        local model = lurek.ai.newEmotionModel()
        model:add("joy", 0.0, 0.1, 0.1)
        model:add("anger", 0.0, 0.1, 0.1)
        model:trigger("joy", 0.3)
        model:trigger("anger", 0.8)
        expect_equal("anger", model:dominant())
    end)

    -- @covers LEmotionModel:isActive
    it("isActive checks whether an emotion exceeds its threshold", function()
        local model = lurek.ai.newEmotionModel()
        model:add("surprise", 0.0, 0.1, 0.5)
        model:trigger("surprise", 0.7)
        expect_true(model:isActive("surprise"))
    end)

    -- @covers LEmotionModel:update
    it("update decays emotion values over time", function()
        local model = lurek.ai.newEmotionModel()
        model:add("excitement", 0.0, 0.2, 0.1)
        model:trigger("excitement", 1.0)
        model:update(3.0)
        expect_near(0.4, model:get("excitement"), 0.01)
    end)

    -- @covers LEmotionModel:reset
    it("reset returns emotions to their default state", function()
        local model = lurek.ai.newEmotionModel()
        model:add("rage", 0.0, 0.1, 0.2)
        model:trigger("rage", 1.0)
        model:reset()
        expect_near(0.0, model:get("rage"), 0.01)
    end)

    -- @covers LEmotionModel:type
    it("type returns LEmotionModel", function()
        expect_equal("LEmotionModel", lurek.ai.newEmotionModel():type())
    end)

    -- @covers LEmotionModel:typeOf
    it("typeOf reports emotion model inheritance", function()
        expect_true(lurek.ai.newEmotionModel():typeOf("LEmotionModel"))
    end)
end)

-- @describe orca solver
describe("ai orca solver", function()
    -- @covers LORCASolver:addAgent
    it("addAgent returns a zero-based solver index", function()
        local orca = lurek.ai.newORCASolver(2.0)
        expect_equal(0, orca:addAgent(10.0, 20.0, 0.5, 3.0))
    end)

    -- @covers LORCASolver:setPreferredVelocity
    it("setPreferredVelocity influences the computed safe velocity", function()
        local orca = lurek.ai.newORCASolver(2.0)
        orca:addAgent(0, 0, 0.5, 5.0)
        orca:setPreferredVelocity(0, 2.0, 1.0)
        orca:compute(0.016)
        local vx, vy = orca:getSafeVelocity(0)
        expect_near(2.0, vx, 0.01)
        expect_near(1.0, vy, 0.01)
    end)

    -- @covers LORCASolver:setPosition
    it("setPosition accepts a new agent position", function()
        local orca = lurek.ai.newORCASolver(2.0)
        orca:addAgent(0, 0, 0.5, 5.0)
        expect_no_error(function()
            orca:setPosition(0, 5.0, 3.0)
        end)
    end)

    -- @covers LORCASolver:compute
    it("compute updates safe velocities for the current agent set", function()
        local orca = lurek.ai.newORCASolver(1.5)
        orca:addAgent(0, 0, 0.5, 3.0)
        orca:addAgent(5, 0, 0.5, 3.0)
        orca:setPreferredVelocity(0, 1.0, 0.0)
        orca:setPreferredVelocity(1, -1.0, 0.0)
        expect_no_error(function()
            orca:compute(0.016)
        end)
    end)

    -- @covers LORCASolver:getSafeVelocity
    it("getSafeVelocity returns two numbers", function()
        local orca = lurek.ai.newORCASolver(1.5)
        orca:addAgent(0, 0, 0.5, 3.0)
        orca:setPreferredVelocity(0, 2.0, 0.0)
        orca:compute(0.016)
        local vx, vy = orca:getSafeVelocity(0)
        expect_type("number", vx)
        expect_type("number", vy)
    end)

    -- @covers LORCASolver:agentCount
    it("agentCount returns the number of registered agents", function()
        local orca = lurek.ai.newORCASolver(2.0)
        orca:addAgent(0, 0, 1.0, 2.0)
        orca:addAgent(5, 5, 1.0, 2.0)
        expect_equal(2, orca:agentCount())
    end)

    -- @covers LORCASolver:type
    it("type returns LORCASolver", function()
        expect_equal("LORCASolver", lurek.ai.newORCASolver(1.0):type())
    end)

    -- @covers LORCASolver:typeOf
    it("typeOf reports orca solver inheritance", function()
        expect_true(lurek.ai.newORCASolver(1.0):typeOf("LORCASolver"))
    end)
end)

-- @describe strategy ai
describe("ai strategy ai", function()
    -- @covers LStrategyAI:addGoal
    it("addGoal accepts named strategic goals", function()
        local strat = lurek.ai.newStrategyAI(5.0)
        expect_no_error(function()
            strat:addGoal("expand")
            strat:addGoal("defend")
            strat:addGoal("research")
        end)
    end)

    -- @covers LStrategyAI:addTag
    it("addTag accepts context tags", function()
        local strat = lurek.ai.newStrategyAI(3.0)
        expect_no_error(function()
            strat:addTag("war_declared")
            strat:addTag("low_resources")
        end)
    end)

    -- @covers LStrategyAI:removeTag
    it("removeTag removes an existing context tag", function()
        local strat = lurek.ai.newStrategyAI(3.0)
        strat:addTag("peace")
        expect_no_error(function()
            strat:removeTag("peace")
        end)
    end)

    -- @covers LStrategyAI:update
    it("update selects the best goal after its interval elapses", function()
        local strat = lurek.ai.newStrategyAI(1.0)
        strat:addGoal("attack")
        strat:addGoal("retreat")
        strat:update(1.5, function(goal)
            if goal == "attack" then
                return 0.8
            end
            return 0.2
        end)
        expect_equal("attack", strat:activeGoal())
    end)

    -- @covers LStrategyAI:forceEvaluate
    it("forceEvaluate immediately chooses the best scoring goal", function()
        local strat = lurek.ai.newStrategyAI(10.0)
        strat:addGoal("build")
        strat:addGoal("scout")
        strat:forceEvaluate(function(goal)
            if goal == "scout" then
                return 5.0
            end
            return 1.0
        end)
        expect_equal("scout", strat:activeGoal())
    end)

    -- @covers LStrategyAI:activeGoal
    it("activeGoal returns nil before any evaluation has run", function()
        local strat = lurek.ai.newStrategyAI(1.0)
        strat:addGoal("idle")
        expect_nil(strat:activeGoal())
    end)

    -- @covers LStrategyAI:timeUntilNext
    it("timeUntilNext reports remaining time until the next evaluation", function()
        local strat = lurek.ai.newStrategyAI(5.0)
        strat:addGoal("wait")
        strat:update(2.0, function() return 1.0 end)
        expect_near(3.0, strat:timeUntilNext(), 0.01)
    end)

    -- @covers LStrategyAI:type
    it("type returns LStrategyAI", function()
        expect_equal("LStrategyAI", lurek.ai.newStrategyAI(1.0):type())
    end)

    -- @covers LStrategyAI:typeOf
    it("typeOf reports strategy ai inheritance", function()
        expect_true(lurek.ai.newStrategyAI(1.0):typeOf("LStrategyAI"))
    end)
end)

-- @describe ai lod
describe("ai lod", function()
    -- @covers LAILod:tierFor
    it("tierFor returns a numeric lod tier index", function()
        expect_type("number", lurek.ai.newAILod():tierFor(100, 200, 0, 0))
    end)

    -- @covers LAILod:shouldUpdate
    it("shouldUpdate returns a boolean for the given tier and frame", function()
        expect_type("boolean", lurek.ai.newAILod():shouldUpdate(0, 1))
    end)

    -- @covers LAILod:tierCount
    it("tierCount returns the number of configured tiers", function()
        expect_true(lurek.ai.newAILod():tierCount() > 0)
    end)

    -- @covers LAILod:tierName
    it("tierName returns a name for a valid tier", function()
        expect_type("string", lurek.ai.newAILod():tierName(0))
    end)

    -- @covers LAILod:type
    it("type returns LAILod", function()
        expect_equal("LAILod", lurek.ai.newAILod():type())
    end)

    -- @covers LAILod:typeOf
    it("typeOf reports ai lod inheritance", function()
        expect_true(lurek.ai.newAILod():typeOf("LAILod"))
    end)
end)
end
-- END test_ai_core_unit.lua

test_summary()
