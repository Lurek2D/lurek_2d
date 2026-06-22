-- Canonical evidence file for lurek.ai data outputs.


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
    -- Does: Runs "writes ai_state_machine_transitions.txt" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.ai.newStateMachine, LStateMachine:addState, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/ai/ai_state_machine_transitions.txt
    -- Why: This is meaningful only if the visible/text output comes from lurek.ai.newStateMachine, LStateMachine:addState, and related owner calls; export helpers are just the container.

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
    -- Does: Runs "writes ai_blackboard_snapshot.json" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.ai.newBlackboard, LAIBlackboard:setNumber, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/ai/ai_blackboard_snapshot.json
    -- Why: This is meaningful only if the visible/text output comes from lurek.ai.newBlackboard, LAIBlackboard:setNumber, and related owner calls; export helpers are just the container.

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
    -- Does: Runs "writes ai_behavior_tree_debug.json" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.ai.newBehaviorTree, lurek.ai.newSequence, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/ai/ai_behavior_tree_debug.json
    -- Why: This is meaningful only if the visible/text output comes from lurek.ai.newBehaviorTree, lurek.ai.newSequence, and related owner calls; export helpers are just the container.

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
    -- Does: Runs "writes ai_utility_scorecard.json" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.ai.newUtilityAI, LUtilityAI:addAction, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/ai/ai_utility_scorecard.json
    -- Why: This is meaningful only if the visible/text output comes from lurek.ai.newUtilityAI, LUtilityAI:addAction, and related owner calls; export helpers are just the container.

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
    -- Does: Runs "writes ai_goap_plan_trace.json" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.ai.newGOAPPlanner, LGOAPPlanner:addAction, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/ai/ai_goap_plan_trace.json
    -- Why: This is meaningful only if the visible/text output comes from lurek.ai.newGOAPPlanner, LGOAPPlanner:addAction, and related owner calls; export helpers are just the container.

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
    -- Does: Runs "writes ai_constructor_surface_snapshot.txt" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.ai.newWorld, lurek.ai.newSelector, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/ai/ai_constructor_surface_snapshot.txt
    -- Why: This is meaningful only if the visible/text output comes from lurek.ai.newWorld, lurek.ai.newSelector, and related owner calls; export helpers are just the container.

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
            "ai_qlearner_ctor=" .. tostring(type(lurek.ai.newQLearner) == "nil"),
            "ai_neural_net_ctor=" .. tostring(type(lurek.ai.newNeuralNet) == "nil"),
            "ai_genetic_ctor=" .. tostring(type(lurek.ai.newGeneticAlgorithm) == "nil"),
            "ai_bandit_ctor=" .. tostring(type(lurek.ai.newBandit) == "nil"),
            "ai_neuroevolution_ctor=" .. tostring(type(lurek.ai.newNeuroevolution) == "nil"),
            "learning_qlearner_ctor=" .. tostring(type(lurek.learning.newQLearner) == "function"),
            "learning_neural_net_ctor=" .. tostring(type(lurek.learning.newNeuralNet) == "function"),
            "learning_genetic_ctor=" .. tostring(type(lurek.learning.newGeneticAlgorithm) == "function"),
            "learning_bandit_ctor=" .. tostring(type(lurek.learning.newBandit) == "function"),
            "learning_neuroevolution_ctor=" .. tostring(type(lurek.learning.newNeuroevolution) == "function"),
            "mcts=" .. tostring(lurek.ai.newMCTSEngine(20, 1.41, 4, 42) ~= nil),
            "orca=" .. tostring(lurek.ai.newORCASolver(1.5) ~= nil),
            "strategy=" .. tostring(lurek.ai.newStrategyAI(5.0) ~= nil),
            "lod=" .. tostring(lurek.ai.newAILod() ~= nil),
        }
        write_text(OUT .. "ai_constructor_surface_snapshot.txt", table.concat(lines, "\n") .. "\n")
    end)
end)
test_summary()
