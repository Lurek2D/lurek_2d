-- Lurek2D Stress Test: AI Agent Processing
-- Measures FSM and behavior tree throughput under heavy load.

-- @description Covers suite: stress: AI FSM evaluation throughput.
describe("stress: AI FSM evaluation throughput", function()
    -- @covers lurek.ai.newStateMachine
    -- @covers StateMachine:update
    -- @stress Times 1000 update calls on one two-state FSM after one-time setup.
    -- @description Stresses per-tick FSM evaluation throughput by reusing a single machine with no-op callbacks so the hot path is update dispatch rather than allocation.
    it("1000 FSM ticks in <10s", function()
        local COUNT = 1000
        local sm    = lurek.ai.newStateMachine()
        sm:addState("A", { onUpdate = function() end })
        sm:addState("B", { onUpdate = function() end })
        sm:addTransition("A", "B")
        sm:addTransition("B", "A")
        sm:forceState("A")

        local elapsed = measure("AI FSM tick x" .. COUNT, COUNT, function()
            sm:update(1 / 60)
        end)

        expect_true(elapsed < 10.0, "FSM tick budget: " .. elapsed .. "s")
    end)

    -- @covers lurek.ai.newStateMachine
    -- @covers StateMachine:update
    -- @stress Allocates 100 FSMs, then performs 10 full update passes across the whole pool.
    -- @description Pushes multi-agent update throughput by building a small FSM per agent and running nested loops over 100 machines to stress repeated state-machine stepping.
    it("100 agents Ă— 10 FSM updates each: <10s", function()
        local AGENTS    = 100
        local UPDATES   = 10
        local machines  = {}

        for _ = 1, AGENTS do
            local sm = lurek.ai.newStateMachine()
            sm:addState("IDLE",   { onUpdate = function() end })
            sm:addState("ACTIVE", { onUpdate = function() end })
            sm:addTransition("IDLE", "ACTIVE")
            sm:addTransition("ACTIVE", "IDLE")
            sm:forceState("IDLE")
            machines[#machines + 1] = sm
        end

        local start = os.clock()
        for _ = 1, UPDATES do
            for _, sm in ipairs(machines) do
                sm:update(1 / 60)
            end
        end
        local elapsed = os.clock() - start
        print(string.format("[STRESS] 100 AI agents Ă— 10 updates: %.4fs", elapsed))

        expect_true(elapsed < 10.0, "multi-agent FSM budget: " .. elapsed .. "s")
    end)
end)

test_summary()
