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

    -- @covers lurek.ai.newTraitArchetypes
    it("newTraitArchetypes creates userdata", function()
        expect_type("userdata", lurek.ai.newTraitArchetypes())
    end)

    -- @covers lurek.ai.newDecisionBiasSet
    it("newDecisionBiasSet creates userdata", function()
        expect_type("userdata", lurek.ai.newDecisionBiasSet())
    end)

    -- @covers lurek.ai.newStimulusWorld
    it("newStimulusWorld creates userdata", function()
        expect_type("userdata", lurek.ai.newStimulusWorld())
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

    -- @covers LAIWorld:setSpatialCellSize
    it("setSpatialCellSize updates the world spatial query cell size", function()
        local world = lurek.ai.newWorld()
        world:setSpatialCellSize(24.0)
        expect_near(24.0, world:getSpatialCellSize(), 0.01)
    end)

    -- @covers LAIWorld:getSpatialCellSize
    it("getSpatialCellSize returns a number", function()
        expect_type("number", lurek.ai.newWorld():getSpatialCellSize())
    end)

    -- @covers LAIWorld:getSpatialQueryStats
    it("getSpatialQueryStats reports candidate and result counters", function()
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
        expect_true(stats.activeAgents >= 2)
        expect_true(stats.candidateChecks >= 1)
    end)

    -- @covers LAIWorld:setOrderArrivalRadius
    it("setOrderArrivalRadius updates the move arrival threshold", function()
        local world = lurek.ai.newWorld()
        world:setOrderArrivalRadius(2.5)
        expect_near(2.5, world:getOrderArrivalRadius(), 0.01)
    end)

    -- @covers LAIWorld:getOrderArrivalRadius
    it("getOrderArrivalRadius returns a number", function()
        expect_type("number", lurek.ai.newWorld():getOrderArrivalRadius())
    end)

    -- @covers LAIWorld:setAutoAcquireBudget
    it("setAutoAcquireBudget updates the query budget used by world update", function()
        local world = lurek.ai.newWorld()
        world:setAutoAcquireBudget(3)
        expect_equal(3, world:getAutoAcquireBudget())
    end)

    -- @covers LAIWorld:getAutoAcquireBudget
    it("getAutoAcquireBudget returns a number", function()
        expect_type("number", lurek.ai.newWorld():getAutoAcquireBudget())
    end)

    -- @covers LAIWorld:getOrderRuntimeStats
    it("getOrderRuntimeStats reports move completions and acquisition work", function()
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
        expect_true(stats.acquireQueries >= 1)
        expect_true(stats.targetsAcquired >= 1)
        expect_true(stats.activeEngagements >= 1)
    end)

    -- @covers LAIWorld:queryAgentsInRadius
    it("queryAgentsInRadius returns nearest filtered agents", function()
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
        local found = world:queryAgentsInRadius(0.0, 0.0, 32.0, {
            exclude = "alpha",
            hostileTo = 1,
            limit = 1,
            tag = "hostile",
            notTag = "hidden",
        })
        expect_equal(1, #found)
        expect_equal("beta", found[1]:getName())
    end)

    -- @covers LAIWorld:update
    it("update integrates velocity and executes queued move orders", function()
        local world, agent = new_world_agent("mover")
        agent:setPosition(0, 0)
        agent:setVelocity(10, 20)
        world:update(0.5)
        local x, y = agent:getPosition()
        expect_near(5.0, x, 0.01)
        expect_near(10.0, y, 0.01)

        local order_world, runner = new_world_agent("runner")
        order_world:setOrderArrivalRadius(0.5)
        local queue = runner:getCommandQueue()
        queue:enqueue("move", function() end, { targetX = 10.0, targetY = 0.0 })
        order_world:update(1.0)
        local rx, ry = runner:getPosition()
        local stats = order_world:getOrderRuntimeStats()
        expect_near(10.0, rx, 0.01)
        expect_near(0.0, ry, 0.01)
        expect_nil(runner:getCurrentOrder())
        expect_true(stats.moveOrdersCompleted >= 1)
    end)

    -- @covers LAIWorld:getLastCallbackErrors
    it("getLastCallbackErrors records custom model callback failures without crashing update", function()
        local world, agent = new_world_agent("broken")
        agent:setCustomModel(function()
            error("boom")
        end)
        world:update(0.1)
        local errors = world:getLastCallbackErrors()
        expect_equal(1, #errors)
        expect_true(type(errors[1].context) == "string")
        expect_true(type(errors[1].message) == "string")
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

    -- @covers LBot:setTeam
    it("setTeam updates the bot team id", function()
        local _, agent = new_world_agent("hero")
        agent:setTeam(3)
        expect_equal(3, agent:getTeam())
    end)

    -- @covers LBot:getTeam
    it("getTeam returns a number", function()
        local _, agent = new_world_agent("hero")
        expect_type("number", agent:getTeam())
    end)

    -- @covers LBot:setStance
    it("setStance applies built-in stance values and overrides", function()
        local _, agent = new_world_agent("hero")
        agent:setStance("defensive", { chaseRadius = 48.0, interruptsMove = true })
        local stance = agent:getStance()
        expect_equal("defensive", stance.stance)
        expect_near(48.0, stance.chaseRadius, 0.01)
        expect_true(stance.interruptsMove)
    end)

    -- @covers LBot:getStance
    it("getStance returns a stance profile table", function()
        local _, agent = new_world_agent("hero")
        local stance = agent:getStance()
        expect_equal("aggressive", stance.stance)
        expect_type("number", stance.acquireRadius)
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

    -- @covers LBot:setTraitProfile
    it("setTraitProfile copies profile traits onto the bot", function()
        local _, agent = new_world_agent("hero")
        local profile = lurek.ai.newTraitProfile()
        profile:set("aggression", 0.7)
        agent:setTraitProfile(profile)
        expect_near(0.7, agent:getTrait("aggression"), 0.01)
    end)

    -- @covers LBot:getTraitProfile
    it("getTraitProfile returns a profile snapshot", function()
        local _, agent = new_world_agent("hero")
        agent:setTrait("caution", 0.6)
        local profile = agent:getTraitProfile()
        expect_type("userdata", profile)
        expect_near(0.6, profile:get("caution"), 0.01)
    end)

    -- @covers LBot:hasTraitProfile
    it("hasTraitProfile reports assigned profile state", function()
        local _, agent = new_world_agent("hero")
        expect_true(not agent:hasTraitProfile())
        agent:setTrait("caution", 0.4)
        expect_true(agent:hasTraitProfile())
    end)

    -- @covers LBot:setTrait
    it("setTrait creates or updates the bot profile", function()
        local _, agent = new_world_agent("hero")
        agent:setTrait("risk_tolerance", 0.8)
        expect_near(0.8, agent:getTrait("risk_tolerance"), 0.01)
    end)

    -- @covers LBot:getTrait
    it("getTrait returns zero for missing bot traits", function()
        local _, agent = new_world_agent("hero")
        expect_near(0.0, agent:getTrait("missing_trait"), 0.01)
    end)

    -- @covers LBot:addTraitModifier
    it("addTraitModifier changes bot trait until world update expires it", function()
        local world, agent = new_world_agent("hero")
        agent:setTrait("caution", 0.3)
        agent:addTraitModifier("caution", 0.5, 0.2, "ambush")
        expect_near(0.8, agent:getTrait("caution"), 0.01)
        world:update(0.5)
        expect_near(0.3, agent:getTrait("caution"), 0.01)
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

    -- @covers LBot:findHostilesInRange
    it("findHostilesInRange uses the world spatial index and team filtering", function()
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
        expect_equal(1, #found)
        expect_equal("enemy", found[1]:getName())
    end)

    -- @covers LBot:acquireTarget
    it("acquireTarget returns the nearest target allowed by the stance profile", function()
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
        expect_equal("near_enemy", target:getName())
    end)

    -- @covers LBot:getBlackboard
    it("getBlackboard returns a blackboard", function()
        local _, agent = new_world_agent("hero")
        expect_equal("LAIBlackboard", agent:getBlackboard():type())
    end)

    -- @covers LBot:getCommandQueue
    it("getCommandQueue returns a live queue bound to the agent", function()
        local _, agent = new_world_agent("hero")
        local queue = agent:getCommandQueue()
        local id = queue:enqueue("move", function() end, { targetX = 8, targetY = 12 })
        expect_type("userdata", queue)
        expect_true(id > 0)
        expect_equal("move", agent:getCurrentOrder().kind)
    end)

    -- @covers LBot:getCurrentOrder
    it("getCurrentOrder returns nil when the agent has no orders", function()
        local _, agent = new_world_agent("hero")
        expect_nil(agent:getCurrentOrder())
    end)

    -- @covers LBot:getOrderRuntimeState
    it("getOrderRuntimeState reports soft interruptions and later clears them", function()
        local world = lurek.ai.newWorld()
        world:setSpatialCellSize(16.0)
        local hero = world:addAgent("hero")
        local enemy = world:addAgent("enemy")
        hero:setTeam(1)
        hero:setPosition(0.0, 0.0)
        hero:setStance("aggressive", {
            acquireRadius = 64.0,
            chaseRadius = 24.0,
            abandonFormation = true,
        })
        hero:getCommandQueue():enqueue("move", function() end, {
            targetX = 100.0,
            targetY = 0.0,
            interruptible = true,
        })
        enemy:setTeam(2)
        enemy:setPosition(8.0, 0.0)
        world:update(0.1)
        local state = hero:getOrderRuntimeState()
        expect_true(state.active)
        expect_equal("enemy", state.engageTarget)
        expect_true(state.formationAbandoned)
        expect_equal(hero:getCurrentOrder().id, state.suspendedOrderId)

        enemy:setPosition(80.0, 0.0)
        world:update(0.1)
        local cleared = hero:getOrderRuntimeState()
        expect_false(cleared.active)
        expect_nil(cleared.engageTarget)
    end)

    -- @covers LBot:clearOrders
    it("clearOrders empties the agent queue and returns the cleared count", function()
        local _, agent = new_world_agent("hero")
        local queue = agent:getCommandQueue()
        queue:enqueue("move", function() end)
        queue:enqueue("guard", function() end)
        expect_equal(2, agent:clearOrders("stop"))
        expect_true(queue:isEmpty())
    end)

    -- @covers LBot:drainCommandEvents
    it("drainCommandEvents returns and clears lifecycle events", function()
        local _, agent = new_world_agent("hero")
        local queue = agent:getCommandQueue()
        queue:enqueue("move", function() end, { targetX = 5, targetY = 7 })
        queue:completeCurrent("arrived")
        local events = agent:drainCommandEvents()
        expect_equal(2, #events)
        expect_equal("enqueued", events[1].event)
        expect_equal("completed", events[2].event)
        expect_equal(0, #agent:drainCommandEvents())
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

    -- @covers LGOAPPlanner:getLastFailureReason
    it("getLastFailureReason reports budget exhaustion after a truncated search", function()
        local planner = lurek.ai.newGOAPPlanner()
        planner:setMaxIterations(1)
        planner:addAction("get_axe", 1.0)
        planner:setEffect("get_axe", "has_axe", true)
        planner:addAction("chop", 1.0)
        planner:setPrecondition("chop", "has_axe", true)
        planner:setEffect("chop", "has_wood", true)
        planner:addAction("build", 1.0)
        planner:setPrecondition("build", "has_wood", true)
        planner:setEffect("build", "has_house", true)
        planner:addGoal("house", 1.0)
        planner:setGoalState("house", "has_house", true)
        local plan = planner:plan({ has_axe = false, has_wood = false, has_house = false }, 8)
        expect_equal(0, #plan)
        expect_equal("budget_exhausted", planner:getLastFailureReason())
    end)

    -- @covers LGOAPPlanner:getLastTrace
    it("getLastTrace exposes failure reason and iteration counters", function()
        local planner = lurek.ai.newGOAPPlanner()
        local plan = planner:plan({}, 4)
        local trace = planner:getLastTrace()
        expect_equal(0, #plan)
        expect_true(type(trace.iterations) == "number")
        expect_equal("no_goal", trace.failure_reason)
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

-- @describe command queue
describe("ai command queue", function()
    -- @covers LCommandQueue:enqueue
    it("enqueue adds one command and returns a stable id", function()
        local queue = lurek.ai.newCommandQueue()
        local id = queue:enqueue("move", function() end)
        expect_true(id > 0)
        expect_equal(1, queue:getCount())
    end)

    -- @covers LCommandQueue:pushFront
    it("pushFront adds one command and returns a stable id", function()
        local queue = lurek.ai.newCommandQueue()
        local id = queue:pushFront("move", function() end)
        expect_true(id > 0)
        expect_equal(1, queue:getCount())
    end)

    -- @covers LCommandQueue:replace
    it("replace resets queue contents and returns a stable id", function()
        local queue = lurek.ai.newCommandQueue()
        queue:enqueue("move", function() end)
        local id = queue:replace("attack", function() end)
        expect_true(id > 0)
        expect_equal(1, queue:getCount())
    end)

    -- @covers LCommandQueue:cancelCurrent
    it("cancelCurrent removes the current interruptible command and emits an event", function()
        local queue = lurek.ai.newCommandQueue()
        queue:enqueue("move", function() end)
        expect_true(queue:cancelCurrent("manual"))
        expect_true(queue:isEmpty())
        local events = queue:drainEvents()
        expect_equal("cancelled", events[#events].event)
    end)

    -- @covers LCommandQueue:clear
    it("clear removes queued commands and returns the cleared count", function()
        local queue = lurek.ai.newCommandQueue()
        queue:enqueue("move", function() end)
        expect_equal(1, queue:clear("reset"))
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

    -- @covers LCommandQueue:getCurrent
    it("getCurrent returns a snapshot for the active command", function()
        local queue = lurek.ai.newCommandQueue()
        local id = queue:enqueue("move", function() end, { targetX = 4, targetY = 9, priority = 3, interruptible = false })
        local current = queue:getCurrent()
        expect_equal(id, current.id)
        expect_equal("move", current.kind)
        expect_equal(3, current.priority)
        expect_false(current.interruptible)
    end)

    -- @covers LCommandQueue:getPending
    it("getPending returns snapshots in queue order", function()
        local queue = lurek.ai.newCommandQueue()
        queue:enqueue("move", function() end)
        queue:enqueue("guard", function() end)
        local pending = queue:getPending()
        expect_equal(2, #pending)
        expect_equal("move", pending[1].kind)
        expect_equal("guard", pending[2].kind)
    end)

    -- @covers LCommandQueue:completeCurrent
    it("completeCurrent advances the queue and records a completion event", function()
        local queue = lurek.ai.newCommandQueue()
        local id = queue:enqueue("move", function() end)
        queue:enqueue("guard", function() end)
        expect_equal(id, queue:completeCurrent("arrived"))
        expect_equal("guard", queue:getCurrentType())
        local events = queue:drainEvents()
        expect_equal("completed", events[#events].event)
    end)

    -- @covers LCommandQueue:failCurrent
    it("failCurrent removes the current command and records a failure event", function()
        local queue = lurek.ai.newCommandQueue()
        queue:enqueue("move", function() end)
        expect_true(queue:failCurrent("blocked"))
        expect_true(queue:isEmpty())
        local events = queue:drainEvents()
        expect_equal("failed", events[#events].event)
        expect_equal("blocked", events[#events].detail)
    end)

    -- @covers LCommandQueue:drainEvents
    it("drainEvents returns emitted lifecycle events in order", function()
        local queue = lurek.ai.newCommandQueue()
        queue:enqueue("move", function() end)
        queue:completeCurrent("done")
        local events = queue:drainEvents()
        expect_equal(2, #events)
        expect_equal("enqueued", events[1].event)
        expect_equal("completed", events[2].event)
        expect_equal(0, #queue:drainEvents())
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

    -- @covers LUtilityAI:evaluateWithProfile
    it("evaluateWithProfile applies personality bias to action scores", function()
        local uai = lurek.ai.newUtilityAI()
        uai:addAction("attack", function() return 0.4 end)
        uai:addAction("defend", function() return 0.5 end)
        local profile = lurek.ai.newTraitProfile()
        profile:set("aggression", 0.8)
        local bias = lurek.ai.newDecisionBiasSet()
        bias:addRule("aggression", "attack", 0.3, "add")
        expect_equal("attack", uai:evaluateWithProfile(profile, bias))
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
    it("addConsideration changes the winning action when consideration scores differ", function()
        local uai = lurek.ai.newUtilityAI()
        uai:addAction("attack", function() return 0.9 end)
        uai:addAction("heal", function() return 0.8 end)
        uai:addConsideration(
            "heal",
            "low_health",
            function() return 1.0 end,
            "linear",
            1.0,
            0.0,
            0.0,
            1.0
        )
        uai:addConsideration(
            "attack",
            "safe_window",
            function() return 0.1 end,
            "linear",
            1.0,
            0.0,
            0.0,
            1.0
        )
        expect_equal("heal", uai:evaluate())
    end)

    -- @covers LUtilityAI:getLastTrace
    it("getLastTrace exposes chosen action and consideration details", function()
        local uai = lurek.ai.newUtilityAI()
        uai:addAction("gather", function() return 0.5 end)
        uai:addConsideration(
            "gather",
            "need_food",
            function() return 0.7 end,
            "linear",
            1.0,
            0.0,
            0.0,
            1.0
        )
        uai:evaluate()
        local trace = uai:getLastTrace()
        expect_equal("gather", trace.chosen_action)
        expect_true(trace.callbacks_used >= 2)
        expect_equal("gather", trace.actions[1].name)
        expect_equal("need_food", trace.actions[1].considerations[1].name)
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

    -- @covers LSquad:setMemberProfile
    it("setMemberProfile stores footprint and subgroup metadata", function()
        local squad = lurek.ai.newSquad("armor")
        squad:setMemberProfile("tank", { footprintW = 4, footprintH = 3, subgroup = "heavy" })
        local profile = squad:getMemberProfile("tank")
        expect_equal(4, profile.footprintW)
        expect_equal(3, profile.footprintH)
        expect_equal("heavy", profile.subgroup)
    end)

    -- @covers LSquad:getMemberProfile
    it("getMemberProfile returns default metadata for an unconfigured member", function()
        local squad = lurek.ai.newSquad("defaults")
        local profile = squad:getMemberProfile("scout")
        expect_equal(1, profile.footprintW)
        expect_equal(1, profile.footprintH)
        expect_nil(profile.subgroup)
    end)

    -- @covers LSquad:setFormationBehavior
    it("setFormationBehavior stores sort, fallback, and subgroup preservation settings", function()
        local squad = lurek.ai.newSquad("behavior")
        squad:setFormationBehavior("distance", "column", true)
        local behavior = squad:getFormationBehavior()
        expect_equal("distance", behavior.sortMode)
        expect_equal("column", behavior.fallbackMode)
        expect_true(behavior.preserveSubgroups)
    end)

    -- @covers LSquad:getFormationBehavior
    it("getFormationBehavior returns default squad layout behavior", function()
        local behavior = lurek.ai.newSquad("behavior_defaults"):getFormationBehavior()
        expect_equal("roster", behavior.sortMode)
        expect_equal("keep", behavior.fallbackMode)
        expect_false(behavior.preserveSubgroups)
    end)

    -- @covers LSquad:getFormationSlots
    it("getFormationSlots returns slot tables and uses lane fallback when needed", function()
        local squad = lurek.ai.newSquad("slots")
        squad:addMember("tank_1")
        squad:addMember("tank_2")
        squad:addMember("tank_3")
        squad:setFormation("line", 10.0)
        squad:setFormationBehavior("roster", "column", false)
        squad:setMemberProfile("tank_1", { footprintW = 4, footprintH = 4 })
        local slots = squad:getFormationSlots(100.0, 50.0, { laneWidth = 20.0 })
        local summary = squad:getFormationSummary(100.0, 50.0, { laneWidth = 20.0 })
        expect_equal(3, #slots)
        expect_equal("column", summary.activeFormation)
        expect_true(summary.fallbackApplied)
        expect_type("string", slots[1].member)
    end)

    -- @covers LSquad:getFormationSummary
    it("getFormationSummary reports subgroup-preserving distance assignment", function()
        local squad = lurek.ai.newSquad("summary")
        squad:addMember("beta_1")
        squad:addMember("alpha_1")
        squad:addMember("beta_2")
        squad:addMember("alpha_2")
        squad:setFormation("line", 8.0)
        squad:setFormationBehavior("distance", "keep", true)
        squad:setMemberProfile("beta_1", { subgroup = "beta" })
        squad:setMemberProfile("beta_2", { subgroup = "beta" })
        squad:setMemberProfile("alpha_1", { subgroup = "alpha" })
        squad:setMemberProfile("alpha_2", { subgroup = "alpha" })
        local slots = squad:getFormationSlots(0.0, 0.0, {
            positions = {
                beta_1 = { x = -40.0, y = 0.0 },
                beta_2 = { x = -30.0, y = 0.0 },
                alpha_1 = { x = 30.0, y = 0.0 },
                alpha_2 = { x = 40.0, y = 0.0 },
            },
        })
        local summary = squad:getFormationSummary(0.0, 0.0)
        expect_equal("line", summary.activeFormation)
        expect_equal("beta", slots[1].subgroup)
        expect_equal("beta", slots[2].subgroup)
        expect_equal("alpha", slots[3].subgroup)
        expect_equal("alpha", slots[4].subgroup)
    end)

    -- @covers LSquad:assignFormationMove
    it("assignFormationMove resolves slots and replaces member move orders in one call", function()
        local world = lurek.ai.newWorld()
        local squad = lurek.ai.newSquad("summary_apply")
        local alpha = world:addAgent("alpha")
        local beta = world:addAgent("beta")
        alpha:setPosition(0.0, 0.0)
        beta:setPosition(10.0, 0.0)
        squad:addMember("alpha")
        squad:addMember("beta")
        squad:setFormation("line", 10.0)
        local applied = squad:assignFormationMove(world, 100.0, 50.0, {
            mode = "replace",
            priority = 3,
            interruptible = false,
        })
        local alpha_order = alpha:getCurrentOrder()
        local beta_order = beta:getCurrentOrder()
        expect_equal(2, applied.assignedCount)
        expect_equal(0, #applied.missingMembers)
        expect_equal("line", applied.activeFormation)
        expect_equal("move", alpha_order.kind)
        expect_equal("move", beta_order.kind)
        expect_equal(3, alpha_order.priority)
        expect_false(alpha_order.interruptible)
        expect_true(math.abs(alpha_order.targetX - beta_order.targetX) >= 10.0)
        local err = expect_error(function()
            squad:assignFormationMove(world, 100.0, 50.0, { mode = "bad_mode" })
        end)
        expect_true(string.find(tostring(err), "invalid mode") ~= nil)
    end)

    -- @covers LSquad:submitFormationPaths
    it("submitFormationPaths batches formation slot pairs through async pathfinding", function()
        lurek.pathfind.setThreadCount(1)
        lurek.pathfind.clearAsyncPaths()
        local world = lurek.ai.newWorld()
        local grid = lurek.pathfind.newNavGrid(32, 32)
        local squad = lurek.ai.newSquad("summary_paths")
        local alpha = world:addAgent("alpha")
        local beta = world:addAgent("beta")
        alpha:setPosition(0.0, 0.0)
        beta:setPosition(10.0, 0.0)
        squad:addMember("alpha")
        squad:addMember("beta")
        squad:setFormation("line", 10.0)
        local submitted = squad:submitFormationPaths(world, grid, 100.0, 50.0, {
            cellSize = 10.0,
            priority = 2,
        })
        expect_true(submitted.requestId > 0)
        expect_true(submitted.ownerId > 0)
        expect_equal(1, submitted.version)
        expect_equal(2, submitted.submittedCount)
        expect_equal(0, #submitted.missingMembers)
        expect_equal(0, #submitted.outOfBoundsMembers)
        expect_equal(1, submitted.slots[1].startCellX)
        expect_equal(10, submitted.slots[1].targetCellX)
        expect_equal(11, submitted.slots[2].targetCellX)

        local final_event = nil
        for _ = 1, 256 do
            local events = lurek.pathfind.pollAsyncPaths()
            for i = 1, #events do
                if events[i].id == submitted.requestId and events[i].final then
                    final_event = events[i]
                    break
                end
            end
            if final_event ~= nil then
                break
            end
            lurek.timer.sleep(0.001)
        end

        expect_not_nil(final_event)
        expect_equal("complete", final_event.status)
        expect_equal(2, #final_event.paths)
        expect_equal(10, final_event.paths[1][#final_event.paths[1]].x)
        expect_equal(11, final_event.paths[2][#final_event.paths[2]].x)
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

    -- @covers LTraitProfile:names
    it("names returns profile trait names", function()
        local profile = lurek.ai.newTraitProfile()
        profile:set("aggression", 0.7)
        profile:set("caution", 0.2)
        local names = profile:names()
        expect_equal(2, #names)
    end)

    -- @covers LTraitProfile:scoreDecision
    it("scoreDecision applies a decision bias set", function()
        local profile = lurek.ai.newTraitProfile()
        profile:set("aggression", 0.8)
        local bias = lurek.ai.newDecisionBiasSet()
        bias:addRule("aggression", "attack", 0.2, "add")
        expect_near(0.66, profile:scoreDecision(bias, "attack", 0.5), 0.01)
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

-- @describe trait archetypes
describe("ai trait archetypes", function()
    -- @covers LTraitArchetypes:register
    it("register adds a custom archetype", function()
        local archetypes = lurek.ai.newTraitArchetypes()
        archetypes:register("raider", { aggression = 0.9, naval_focus = 1.0 })
        local profile = archetypes:createProfile("raider")
        expect_near(1.0, profile:get("naval_focus"), 0.01)
    end)

    -- @covers LTraitArchetypes:createProfile
    it("createProfile returns built-in commander profiles", function()
        local archetypes = lurek.ai.newTraitArchetypes()
        local profile = archetypes:createProfile("aggressive")
        expect_type("userdata", profile)
        expect_true(profile:get("aggression") > 0.5)
    end)

    -- @covers LTraitArchetypes:names
    it("names returns built-in archetype names", function()
        local names = lurek.ai.newTraitArchetypes():names()
        expect_true(#names >= 1)
    end)

    -- @covers LTraitArchetypes:count
    it("count returns registered archetype count", function()
        expect_true(lurek.ai.newTraitArchetypes():count() >= 1)
    end)

    -- @covers LTraitArchetypes:type
    it("type returns LTraitArchetypes", function()
        expect_equal("LTraitArchetypes", lurek.ai.newTraitArchetypes():type())
    end)

    -- @covers LTraitArchetypes:typeOf
    it("typeOf reports trait archetype inheritance", function()
        expect_true(lurek.ai.newTraitArchetypes():typeOf("LTraitArchetypes"))
    end)
end)

-- @describe decision bias
describe("ai decision bias", function()
    -- @covers LDecisionBiasSet:addRule
    it("addRule stores a trait-to-decision rule", function()
        local bias = lurek.ai.newDecisionBiasSet()
        bias:addRule("aggression", "attack", 0.2, "add")
        expect_equal(1, bias:ruleCount())
    end)

    -- @covers LDecisionBiasSet:score
    it("score applies matching rules to profile values", function()
        local profile = lurek.ai.newTraitProfile()
        profile:set("aggression", 0.8)
        local bias = lurek.ai.newDecisionBiasSet()
        bias:addRule("aggression", "attack", 0.2, "add")
        expect_near(0.66, bias:score(profile, "attack", 0.5), 0.01)
    end)

    -- @covers LDecisionBiasSet:ruleCount
    it("ruleCount returns the stored rule count", function()
        local bias = lurek.ai.newDecisionBiasSet()
        bias:addRule("caution", "retreat", 0.4)
        bias:addRule("aggression", "attack", 0.2)
        expect_equal(2, bias:ruleCount())
    end)

    -- @covers LDecisionBiasSet:type
    it("type returns LDecisionBiasSet", function()
        expect_equal("LDecisionBiasSet", lurek.ai.newDecisionBiasSet():type())
    end)

    -- @covers LDecisionBiasSet:typeOf
    it("typeOf reports decision bias inheritance", function()
        expect_true(lurek.ai.newDecisionBiasSet():typeOf("LDecisionBiasSet"))
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

    -- @covers LMCTSEngine:getLastTrace
    it("getLastTrace reports invalid rollout scores", function()
        local mcts = lurek.ai.newMCTSEngine(8, 1.4, 4, 42)
        mcts:search(
            1,
            function(_) return { 7 } end,
            function(state, act) return state + act end,
            function(_) return 0 / 0 end
        )
        local trace = mcts:getLastTrace()
        expect_true(trace.invalid_score_count > 0)
        expect_true(type(trace.iterations_run) == "number")
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
