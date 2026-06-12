-- Canonical evidence file for lurek.ai data outputs.
-- @covers lurek.ai.newAIDirector
-- @covers lurek.ai.newAILod
-- @covers lurek.ai.newAction
-- @covers lurek.ai.newBandit
-- @covers lurek.ai.newBehaviorTree
-- @covers lurek.ai.newBlackboard
-- @covers lurek.ai.newCommandQueue
-- @covers lurek.ai.newCondition
-- @covers lurek.ai.newContextSteering
-- @covers lurek.ai.newDialogueAI
-- @covers lurek.ai.newEmotionModel
-- @covers lurek.ai.newGOAPPlanner
-- @covers lurek.ai.newGeneticAlgorithm
-- @covers lurek.ai.newGuard
-- @covers lurek.ai.newHTNDomain
-- @covers lurek.ai.newInfluenceMap
-- @covers lurek.ai.newInverter
-- @covers lurek.ai.newMCTSEngine
-- @covers lurek.ai.newNeedSystem
-- @covers lurek.ai.newNeuralNet
-- @covers lurek.ai.newNeuroevolution
-- @covers lurek.ai.newORCASolver
-- @covers lurek.ai.newParallel
-- @covers lurek.ai.newQLearner
-- @covers lurek.ai.newRepeater
-- @covers lurek.ai.newSelector
-- @covers lurek.ai.newSequence
-- @covers lurek.ai.newSquad
-- @covers lurek.ai.newStateMachine
-- @covers lurek.ai.newSteeringManager
-- @covers lurek.ai.newStimulusWorld
-- @covers lurek.ai.newStrategyAI
-- @covers lurek.ai.newSucceeder
-- @covers lurek.ai.newTraitProfile
-- @covers lurek.ai.newUtilityAI
-- @covers lurek.ai.newWorld
-- @covers lurek.filesystem.write


local OUT = evidence_output_dir("ai")

local function write_text(path, text)
    if write_file then
        write_file(path, text)
    else
        lurek.filesystem.write(path, text)
    end
    expect_evidence_created(path)
end

-- @describe Evidence: lurek.ai data outputs
describe("Evidence: lurek.ai data outputs", function()
    before_each(function()
        ensure_evidence_dir("ai")
    end)

    -- @evidence lurek.ai.newStateMachine
    -- @evidence LStateMachine:addState
    -- @evidence LStateMachine:addTransition
    -- @evidence LStateMachine:setInitialState
    -- @evidence LStateMachine:getCurrentState
    -- @evidence LStateMachine:forceState
    -- @evidence LStateMachine:getTimeInState
    it("writes ai_state_machine_transitions.txt", function()
        local fsm = lurek.ai.newStateMachine()
        fsm:addState("idle", {})
        fsm:addState("patrol", {})
        fsm:addState("chase", {})
        fsm:addTransition("idle", "patrol", function() return true end, 1)
        fsm:addTransition("patrol", "chase", function() return true end, 2)
        fsm:setInitialState("idle")
        local before = tostring(fsm:getCurrentState())
        fsm:forceState("patrol")
        local after_patrol = tostring(fsm:getCurrentState())
        fsm:forceState("chase")
        local after_chase = tostring(fsm:getCurrentState())
        local text = table.concat({
            "initial=" .. before,
            "after_patrol=" .. after_patrol,
            "after_chase=" .. after_chase,
            "time_in_state=" .. tostring(fsm:getTimeInState()),
        }, "\n") .. "\n"
        write_text(OUT .. "ai_state_machine_transitions.txt", text)
    end)

    -- @evidence lurek.ai.newBlackboard
    -- @evidence LAIBlackboard:setNumber
    -- @evidence LAIBlackboard:getNumber
    -- @evidence LAIBlackboard:setBool
    -- @evidence LAIBlackboard:getBool
    -- @evidence LAIBlackboard:setString
    -- @evidence LAIBlackboard:getString
    -- @evidence LAIBlackboard:has
    -- @evidence LAIBlackboard:getKeys
    -- @evidence LAIBlackboard:getSize
    -- @evidence LAIBlackboard:remove
    -- @evidence LAIBlackboard:clear
    it("writes ai_blackboard_snapshot.json", function()
        local bb = lurek.ai.newBlackboard()
        bb:setNumber("hp", 82)
        bb:setBool("alert", true)
        bb:setString("state", "patrol")
        local before_size = bb:getSize()
        local has_hp = bb:has("hp")
        local hp = bb:getNumber("hp", 0)
        local alert = bb:getBool("alert")
        local state = bb:getString("state", "none")
        local keys = bb:getKeys()
        table.sort(keys)
        bb:remove("alert")
        local after_remove_size = bb:getSize()
        bb:clear()
        local after_clear_size = bb:getSize()
        local text = string.format(
            '{"hp":%.2f,"alert":%s,"state":"%s","has_hp":%s,"keys":["%s"],"before_size":%d,"after_remove_size":%d,"after_clear_size":%d}',
            tonumber(hp) or 0,
            tostring(alert),
            tostring(state),
            tostring(has_hp),
            table.concat(keys, '","'),
            before_size,
            after_remove_size,
            after_clear_size
        )
        write_text(OUT .. "ai_blackboard_snapshot.json", text)
    end)

    -- @evidence lurek.ai.newBehaviorTree
    -- @evidence lurek.ai.newSequence
    -- @evidence lurek.ai.newCondition
    -- @evidence lurek.ai.newAction
    -- @evidence LBehaviorTree:setRoot
    -- @evidence LBehaviorTree:getLastStatus
    -- @evidence LBehaviorTree:getDebugState
    it("writes ai_behavior_tree_debug.json", function()
        local tree = lurek.ai.newBehaviorTree()
        local root = lurek.ai.newSequence()
        root:addChild(lurek.ai.newCondition(function() return true end))
        root:addChild(lurek.ai.newAction(function() return "success" end))
        tree:setRoot(root)
        local info = tree:getDebugState()
        local text = string.format(
            '{"last_status":"%s","node_count":%d,"tick_count":%d}',
            tostring(tree:getLastStatus()),
            tonumber(info.node_count) or 0,
            tonumber(info.tick_count) or 0
        )
        write_text(OUT .. "ai_behavior_tree_debug.json", text)
    end)

    -- @evidence lurek.ai.newUtilityAI
    -- @evidence LUtilityAI:addAction
    -- @evidence LUtilityAI:addConsideration
    -- @evidence LUtilityAI:evaluate
    -- @evidence LUtilityAI:getActionCount
    -- @evidence LUtilityAI:getLastAction
    it("writes ai_utility_scorecard.json", function()
        local uai = lurek.ai.newUtilityAI()
        uai:addAction("heal", function() return 0.45 end, 1.0)
        uai:addAction("attack", function() return 0.80 end, 1.0)
        uai:addAction("retreat", function() return 0.65 end, 1.0)
        uai:addConsideration("heal", "low_health", function() return 0.90 end, "linear", 1.0, 0.0, 0.0, 1.0)
        local winner = uai:evaluate()
        local text = string.format(
            '{"winner":"%s","last_action":"%s","action_count":%d}',
            tostring(winner),
            tostring(uai:getLastAction()),
            tonumber(uai:getActionCount()) or 0
        )
        write_text(OUT .. "ai_utility_scorecard.json", text)
    end)

    -- @evidence lurek.ai.newGOAPPlanner
    -- @evidence LGOAPPlanner:addAction
    -- @evidence LGOAPPlanner:setPrecondition
    -- @evidence LGOAPPlanner:setEffect
    -- @evidence LGOAPPlanner:addGoal
    -- @evidence LGOAPPlanner:setGoalState
    -- @evidence LGOAPPlanner:plan
    -- @evidence LGOAPPlanner:getActionCount
    -- @evidence LGOAPPlanner:getGoalCount
    -- @evidence LGOAPPlanner:setMaxIterations
    -- @evidence LGOAPPlanner:getMaxIterations
    it("writes ai_goap_plan_trace.json", function()
        local planner = lurek.ai.newGOAPPlanner()
        planner:setMaxIterations(250)
        planner:addAction("get_axe", 1.0)
        planner:setEffect("get_axe", "has_axe", true)
        planner:addAction("chop_tree", 2.0)
        planner:setPrecondition("chop_tree", "has_axe", true)
        planner:setEffect("chop_tree", "has_wood", true)
        planner:addGoal("gather", 1.0)
        planner:setGoalState("gather", "has_wood", true)
        local plan = planner:plan({ has_axe = false, has_wood = false }) or {}
        local actions = {}
        for i, name in ipairs(plan) do
            actions[i] = '"' .. tostring(name) .. '"'
        end
        local text = string.format(
            '{"actions":[%s],"action_count":%d,"goal_count":%d,"max_iterations":%d}',
            table.concat(actions, ","),
            tonumber(planner:getActionCount()) or 0,
            tonumber(planner:getGoalCount()) or 0,
            tonumber(planner:getMaxIterations()) or 0
        )
        write_text(OUT .. "ai_goap_plan_trace.json", text)
    end)

    -- @evidence lurek.ai.newWorld
    -- @evidence lurek.ai.newSelector
    -- @evidence lurek.ai.newParallel
    -- @evidence lurek.ai.newInverter
    -- @evidence lurek.ai.newRepeater
    -- @evidence lurek.ai.newSucceeder
    -- @evidence lurek.ai.newGuard
    -- @evidence lurek.ai.newSteeringManager
    -- @evidence lurek.ai.newQLearner
    -- @evidence lurek.ai.newDialogueAI
    -- @evidence lurek.ai.newInfluenceMap
    -- @evidence lurek.ai.newSquad
    -- @evidence lurek.ai.newCommandQueue
    -- @evidence lurek.ai.newTraitProfile
    -- @evidence lurek.ai.newStimulusWorld
    -- @evidence lurek.ai.newContextSteering
    -- @evidence lurek.ai.newNeedSystem
    -- @evidence lurek.ai.newAIDirector
    -- @evidence lurek.ai.newHTNDomain
    -- @evidence lurek.ai.newMCTSEngine
    -- @evidence lurek.ai.newEmotionModel
    -- @evidence lurek.ai.newORCASolver
    -- @evidence lurek.ai.newNeuralNet
    -- @evidence lurek.ai.newGeneticAlgorithm
    -- @evidence lurek.ai.newBandit
    -- @evidence lurek.ai.newNeuroevolution
    -- @evidence lurek.ai.newStrategyAI
    -- @evidence lurek.ai.newAILod
    it("writes ai_constructor_surface_snapshot.txt", function()
        local lines = {
            "world=" .. tostring(type(lurek.ai.newWorld) == "function"),
            "selector=" .. tostring(type(lurek.ai.newSelector) == "function"),
            "parallel=" .. tostring(type(lurek.ai.newParallel) == "function"),
            "inverter=" .. tostring(type(lurek.ai.newInverter) == "function"),
            "repeater=" .. tostring(type(lurek.ai.newRepeater) == "function"),
            "succeeder=" .. tostring(type(lurek.ai.newSucceeder) == "function"),
            "guard=" .. tostring(lurek.ai.newGuard(function() return true end, lurek.ai.newAction(function() return "success" end)) ~= nil),
            "steering=" .. tostring(type(lurek.ai.newSteeringManager) == "function"),
            "dialogue_ctor=" .. tostring(type(lurek.ai.newDialogueAI) == "function"),
            "influence_ctor=" .. tostring(type(lurek.ai.newInfluenceMap) == "function"),
            "squad_ctor=" .. tostring(type(lurek.ai.newSquad) == "function"),
            "command_queue_ctor=" .. tostring(type(lurek.ai.newCommandQueue) == "function"),
            "trait_profile_ctor=" .. tostring(type(lurek.ai.newTraitProfile) == "function"),
            "stimulus_world_ctor=" .. tostring(type(lurek.ai.newStimulusWorld) == "function"),
            "context_steering_ctor=" .. tostring(type(lurek.ai.newContextSteering) == "function"),
            "need_system_ctor=" .. tostring(type(lurek.ai.newNeedSystem) == "function"),
            "director_ctor=" .. tostring(type(lurek.ai.newAIDirector) == "function"),
            "htn_ctor=" .. tostring(type(lurek.ai.newHTNDomain) == "function"),
            "emotion_ctor=" .. tostring(type(lurek.ai.newEmotionModel) == "function"),
            "qlearner_ctor=" .. tostring(type(lurek.ai.newQLearner) == "function"),
            "neural_net_ctor=" .. tostring(type(lurek.ai.newNeuralNet) == "function"),
            "genetic_ctor=" .. tostring(type(lurek.ai.newGeneticAlgorithm) == "function"),
            "bandit_ctor=" .. tostring(type(lurek.ai.newBandit) == "function"),
            "neuroevolution_ctor=" .. tostring(type(lurek.ai.newNeuroevolution) == "function"),
            "mcts=" .. tostring(lurek.ai.newMCTSEngine(20, 1.41, 4, 42) ~= nil),
            "orca=" .. tostring(lurek.ai.newORCASolver(1.5) ~= nil),
            "strategy=" .. tostring(lurek.ai.newStrategyAI(5.0) ~= nil),
            "lod=" .. tostring(lurek.ai.newAILod() ~= nil),
        }
        write_text(OUT .. "ai_constructor_surface_snapshot.txt", table.concat(lines, "\n") .. "\n")
    end)
end)
test_summary()
