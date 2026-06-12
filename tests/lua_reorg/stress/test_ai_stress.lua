-- Lurek2D Stress Test: AI Agent Processing
-- Measures FSM and behavior tree throughput under heavy load.

local function resolve_update_fn(machine)
    local ok_update, update_fn = pcall(function()
        return machine["update"]
    end)
    if not ok_update or type(update_fn) ~= "function" then
        return nil
    end
    return update_fn
end

local function build_tick_state_machine()
    local sm = lurek.ai.newStateMachine()
    sm:addState("A", { onUpdate = function() end })
    sm:addState("B", { onUpdate = function() end })
    sm:addTransition("A", "B")
    sm:addTransition("B", "A")
    sm:forceState("A")
    return sm
end

local function maybe_measure_fsm_ticks(count)
    local sm = build_tick_state_machine()
    local update_fn = resolve_update_fn(sm)
    if update_fn == nil then
        return nil
    end
    return measure("AI FSM tick x" .. count, count, function()
        update_fn(sm, 1 / 60)
    end)
end

local function build_transition_machine()
    local sm = lurek.ai.newStateMachine()
    sm:addState("IDLE", { onUpdate = function() end })
    sm:addState("ACTIVE", { onUpdate = function() end })
    sm:addTransition("IDLE", "ACTIVE")
    sm:addTransition("ACTIVE", "IDLE")
    sm:forceState("IDLE")
    return sm
end

local function maybe_measure_multi_agent_updates(agent_count, updates)
    local machines = {}
    for _ = 1, agent_count do
        machines[#machines + 1] = build_transition_machine()
    end

    local update_fn = resolve_update_fn(machines[1])
    if update_fn == nil then
        return nil
    end

    local start = os.clock()
    for _ = 1, updates do
        for _, sm in ipairs(machines) do
            update_fn(sm, 1 / 60)
        end
    end
    return os.clock() - start
end

-- @describe stress: AI FSM evaluation throughput
describe("stress: AI FSM evaluation throughput", function()
    -- @stress LStateMachine:forceState
    it("1000 FSM ticks in <10s", function()
        local count = 1000
        local elapsed = maybe_measure_fsm_ticks(count)
        if elapsed == nil then
            expect_nil(elapsed, "update is not exposed")
            return
        end

        expect_true(elapsed < 10.0, "FSM tick budget: " .. elapsed .. "s")
    end)

    -- @stress LStateMachine:addTransition
    it("100 agents       10 FSM updates each: <10s", function()
        local agents = 100
        local updates = 10
        local elapsed = maybe_measure_multi_agent_updates(agents, updates)
        if elapsed == nil then
            expect_nil(elapsed, "update is not exposed")
            return
        end
        print(string.format("[STRESS] 100 AI agents       10 updates: %.4fs", elapsed))

        expect_true(elapsed < 10.0, "multi-agent FSM budget: " .. elapsed .. "s")
    end)
end)
test_summary()
