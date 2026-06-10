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
    it("addPursue increases behavior count", function()
        local sm = lurek.ai.newSteeringManager()
        sm:addPursue("target")
        expect_equal(1, sm:getBehaviorCount())
    end)

    -- @covers LSteeringManager:addEvade
    it("addEvade increases behavior count", function()
        local sm = lurek.ai.newSteeringManager()
        sm:addEvade("threat")
        expect_equal(1, sm:getBehaviorCount())
    end)

    -- @covers LSteeringManager:addFlock
    it("addFlock increases behavior count", function()
        local sm = lurek.ai.newSteeringManager()
        sm:addFlock()
        expect_equal(1, sm:getBehaviorCount())
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

test_summary()
