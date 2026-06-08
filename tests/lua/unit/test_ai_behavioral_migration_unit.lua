-- Behavioral migration parity tests for legacy Rust AI unit cases.
-- Source set: tests/rust/unit/ai_tests/*.rs

-- @describe AI behavioral parity migrated from Rust unit tests
describe("AI behavioral parity migrated from Rust unit tests", function()
    -- @covers LAIWorld:addAgent
    -- @covers LBot:getDecisionModel
    -- @covers LBot:getName
    -- @covers LBot:getPosition
    -- @covers LBot:getVelocity
    -- @covers lurek.ai.newWorld
    it("agent_tests.rs parity: new agent defaults via public API", function()
        local w = lurek.ai.newWorld()
        local a = w:addAgent("test")
        local x, y = a:getPosition()
        local vx, vy = a:getVelocity()

        expect_equal("test", a:getName())
        expect_near(0.0, x, 0.001)
        expect_near(0.0, y, 0.001)
        expect_near(0.0, vx, 0.001)
        expect_near(0.0, vy, 0.001)
        expect_equal("fsm", a:getDecisionModel())
    end)

    -- @covers LAIWorld:addAgent
    -- @covers LBot:getDecisionModel
    -- @covers LBot:setDecisionModel
    -- @covers lurek.ai.newWorld
    it("agent_tests.rs parity: decision model roundtrip for valid values", function()
        local w = lurek.ai.newWorld()
        local a = w:addAgent("dm")
        local models = { "fsm", "bt", "steering", "fsm+steering", "bt+steering" }

        for _, model in ipairs(models) do
            a:setDecisionModel(model)
            expect_equal(model, a:getDecisionModel())
        end
    end)

    -- @covers LAIWorld:addAgent
    -- @covers LBot:setDecisionModel
    -- @covers lurek.ai.newWorld
    it("agent_tests.rs parity: unknown decision model keeps previous value", function()
        local w = lurek.ai.newWorld()
        local a = w:addAgent("dm-invalid")
        a:setDecisionModel("bogus")
        expect_equal("fsm", a:getDecisionModel())
    end)

    -- @covers LBehaviorTree:getDebugState
    -- @covers lurek.ai.newBehaviorTree
    it("behavior_tree_tests.rs parity: new behavior tree has no nodes", function()
        local bt = lurek.ai.newBehaviorTree()
        local dbg = bt:getDebugState()
        expect_equal(0, dbg.node_count)
    end)

    -- @covers LCommandQueue:getCount
    -- @covers lurek.ai.newCommandQueue
    it("command_queue_tests.rs parity: new queue is empty", function()
        local q = lurek.ai.newCommandQueue()
        expect_equal(0, q:getCount())
    end)

    -- @covers LCommandQueue:clear
    -- @covers LCommandQueue:getCount
    -- @covers LCommandQueue:enqueue
    -- @covers lurek.ai.newCommandQueue
    it("command_queue_tests.rs parity: clear empties queue", function()
        local q = lurek.ai.newCommandQueue()
        q:enqueue("move", function() end)
        q:clear()
        expect_equal(0, q:getCount())
    end)

    -- @covers LContextSteering:slotCount
    -- @covers lurek.ai.newContextSteering
    it("context_steering_tests.rs parity: slot count follows constructor", function()
        local cs = lurek.ai.newContextSteering(8)
        expect_equal(8, cs:slotCount())
    end)

    -- @covers LStateMachine:addState
    -- @covers LStateMachine:getCurrentState
    -- @covers LStateMachine:setInitialState
    -- @covers lurek.ai.newStateMachine
    it("fsm_tests.rs parity: initial state can be configured", function()
        local fsm = lurek.ai.newStateMachine()
        fsm:addState("idle", {})
        fsm:setInitialState("idle")
        expect_equal("idle", fsm:getCurrentState())
    end)

    -- @covers LGeneticAlgorithm:bestGenes
    -- @covers LGeneticAlgorithm:evolve
    -- @covers LGeneticAlgorithm:popSize
    -- @covers LGeneticAlgorithm:setFitness
    -- @covers lurek.ai.newGeneticAlgorithm
    it("genetic_tests.rs parity: evolve keeps population size and returns best genes", function()
        local ga = lurek.ai.newGeneticAlgorithm(6, 4, 3)
        for i = 0, 5 do ga:setFitness(i, i * 0.1) end
        ga:evolve()
        expect_equal(6, ga:popSize())
        expect_type("table", ga:bestGenes())
    end)

    -- @covers LGOAPPlanner:getMaxIterations
    -- @covers LGOAPPlanner:setMaxIterations
    -- @covers lurek.ai.newGOAPPlanner
    it("goap_tests.rs parity: max iterations roundtrip", function()
        local p = lurek.ai.newGOAPPlanner()
        p:setMaxIterations(500)
        expect_equal(500, p:getMaxIterations())
    end)

    -- @covers LHTNDomain:addCompound
    -- @covers LHTNDomain:addPrimitive
    -- @covers LHTNDomain:plan
    -- @covers lurek.ai.newHTNDomain
    it("htn_tests.rs parity: decomposition returns primitive plan", function()
        local d = lurek.ai.newHTNDomain()
        d:addPrimitive("eat", {}, { "fed" }, {})
        d:addCompound("survive", {
            { name = "main", preconditions = {}, sub_tasks = { "eat" } }
        })

        local plan = d:plan("survive", {})
        expect_not_nil(plan)
        expect_type("table", plan)
        local p = plan
        if p then
            expect_equal("eat", p[1])
        end
    end)

    -- @covers LMCTSEngine:search
    -- @covers lurek.ai.newMCTSEngine
    it("mcts_tests.rs parity: search executes and returns action", function()
        local e = lurek.ai.newMCTSEngine(50, 1.41, 10, 42)
        local action = e:search(
            0,
            function(state)
                if state >= 2 then return {} end
                return {1, 2}
            end,
            function(state, act)
                return state + act
            end,
            function(state)
                return state / 2.0
            end
        )
        expect_type("number", action)
    end)

    -- @covers LNeedSystem:addNeed
    -- @covers LNeedSystem:mostUrgent
    -- @covers LNeedSystem:update
    -- @covers LNeedSystem:valueOf
    -- @covers lurek.ai.newNeedSystem
    it("needs_tests.rs parity: update changes need values and urgency is queryable", function()
        local ns = lurek.ai.newNeedSystem()
        ns:addNeed("hunger", 1.0, 0.3, 2.0)
        local before = ns:valueOf("hunger")
        ns:update(0.8)
        expect_equal(ns:valueOf("hunger") < before, true)
        expect_type("string", ns:mostUrgent())
    end)

    -- @covers LNeuralNet:forward
    -- @covers LNeuralNet:layerCount
    -- @covers lurek.ai.newNeuralNet
    it("neural_net_tests.rs parity: forward returns table and layer count is stable", function()
        local net = lurek.ai.newNeuralNet()
        net:addLayer(2, 3, "relu")
        net:addLayer(3, 1, "sigmoid")
        local out = net:forward({ 0.5, 0.25 })
        expect_equal(2, net:layerCount())
        expect_type("table", out)
    end)

    -- @covers LNeuroevolution:evolve
    -- @covers LNeuroevolution:popSize
    -- @covers LNeuroevolution:setFitness
    -- @covers lurek.ai.newNeuroevolution
    it("neuroevolution_tests.rs parity: evolve preserves population size", function()
        local ne = lurek.ai.newNeuroevolution({ { inputs = 2, outputs = 1, activation = "sigmoid" } }, 6, 7)
        for i = 0, 5 do ne:setFitness(i, i * 0.2) end
        ne:evolve()
        expect_equal(6, ne:popSize())
    end)

    -- @covers LORCASolver:addAgent
    -- @covers LORCASolver:agentCount
    -- @covers lurek.ai.newORCASolver
    it("orca_tests.rs parity: addAgent updates solver count", function()
        local s = lurek.ai.newORCASolver(2.0)
        s:addAgent(0, 0, 0.5, 3.0)
        expect_equal(1, s:agentCount())
    end)

    -- @covers LStimulusWorld:addVisual
    -- @covers LStimulusWorld:count
    -- @covers lurek.ai.newStimulusWorld
    it("perception_tests.rs parity: stimulus world stores visual stimuli", function()
        local sw = lurek.ai.newStimulusWorld()
        sw:addVisual(10, 20, 0.9, 1.0, "enemy")
        expect_equal(1, sw:count())
    end)

    -- @covers LSquad:addMember
    -- @covers LSquad:getFormationPosition
    -- @covers LSquad:setFormation
    -- @covers lurek.ai.newSquad
    it("squad_tests.rs parity: line formation computes distinct X positions", function()
        local sq = lurek.ai.newSquad("alpha")
        sq:addMember("m0")
        sq:addMember("m1")
        sq:setFormation("line", 10)

        local x0, _ = sq:getFormationPosition(1, 0, 0)
        local x1, _ = sq:getFormationPosition(2, 0, 0)
        expect_equal(x0 ~= x1, true)
    end)

    -- @covers LSteeringManager:getCombineMode
    -- @covers LSteeringManager:setCombineMode
    -- @covers lurek.ai.newSteeringManager
    it("steering_tests.rs parity: combine mode roundtrip", function()
        local sm = lurek.ai.newSteeringManager()
        sm:setCombineMode("priority")
        expect_equal("priority", sm:getCombineMode())
        sm:setCombineMode("weighted")
        expect_equal("weighted", sm:getCombineMode())
    end)

    -- @covers LStrategyAI:addGoal
    -- @covers LStrategyAI:activeGoal
    -- @covers LStrategyAI:forceEvaluate
    -- @covers LStrategyAI:timeUntilNext
    -- @covers lurek.ai.newStrategyAI
    it("strategy_tests.rs parity: goals can be evaluated and interval is exposed", function()
        local s = lurek.ai.newStrategyAI(2.0)
        s:addGoal("attack")
        s:forceEvaluate(function(goal)
            if goal == "attack" then
                return 1.0
            end
            return 0.0
        end)
        expect_equal("attack", s:activeGoal())
        expect_near(2.0, s:timeUntilNext(), 0.001)
    end)

    -- @covers LTraitProfile:addModifier
    -- @covers LTraitProfile:get
    -- @covers LTraitProfile:set
    -- @covers LTraitProfile:update
    -- @covers lurek.ai.newTraitProfile
    it("traits_tests.rs parity: modifiers affect trait and can expire", function()
        local tp = lurek.ai.newTraitProfile()
        tp:set("caution", 0.3)
        tp:addModifier("caution", 0.4, nil, "buff")
        expect_near(0.7, tp:get("caution"), 0.001)

        tp:addModifier("caution", 0.1, 0.001, "temp")
        tp:update(1.0)
        local v = tp:get("caution")
        expect_type("number", v)
        expect_equal(v >= 0.7, true)
    end)

    -- @covers LUtilityAI:addAction
    -- @covers LUtilityAI:evaluate
    -- @covers LUtilityAI:getLastAction
    -- @covers lurek.ai.newUtilityAI
    it("utility_ai_tests.rs parity: utility evaluation returns best action name", function()
        local ua = lurek.ai.newUtilityAI()
        ua:addAction("idle", function() return 0.1 end, 1.0)
        ua:addAction("fight", function() return 0.9 end, 1.0)
        local action = ua:evaluate()
        expect_equal("fight", action)
        expect_equal("fight", ua:getLastAction())
    end)

    -- @covers LAIWorld:addAgent
    -- @covers LAIWorld:getAgentCount
    -- @covers LAIWorld:update
    -- @covers lurek.ai.newWorld
    it("world_tests.rs parity: world updates agent position from velocity", function()
        local w = lurek.ai.newWorld()
        local a = w:addAgent("mover")
        a:setPosition(0, 0)
        a:setVelocity(10, 20)
        w:update(0.5)

        local x, y = a:getPosition()
        expect_near(5.0, x, 0.01)
        expect_near(10.0, y, 0.01)
    end)
end)
test_summary()
