-- Lurek2D Stress Test: Patterns Module Operations
-- Measures observer, state machine, and command queue throughput.

local function run_observer_notification_stress(subscriber_count, notification_count)
    local obs = lurek.patterns.newObserver()
    local count = 0

    for _ = 1, subscriber_count do
        obs:subscribe("*", function()
            count = count + 1
        end)
    end

    local start = os.clock()
    for _ = 1, notification_count do
        obs:set("x", true)
    end
    local elapsed = os.clock() - start

    return elapsed, count, subscriber_count * notification_count
end

local function run_command_enqueue_stress(count)
    local queue = lurek.ai.newCommandQueue()
    local start = os.clock()
    for _ = 1, count do
        queue:enqueue("action", function()
        end)
    end
    local elapsed = os.clock() - start
    return elapsed, queue:getCount()
end

local function build_pattern_state_machine()
    local sm = lurek.ai.newStateMachine()
    sm:addState("A", { onEnter = function() end, onExit = function() end })
    sm:addState("B", { onEnter = function() end, onExit = function() end })
    sm:setInitialState("A")
    return sm
end

local function measure_force_state_stress(count)
    local sm = build_pattern_state_machine()
    return measure("pattern SM transition x" .. count, count, function()
        local cur = sm:getCurrentState()
        sm:forceState(cur == "A" and "B" or "A")
    end)
end

-- @describe stress: patterns observer throughput
describe("stress: patterns observer throughput", function()
    -- @stress LObserver:set
    it("1000 observers       100 notifications: <10s", function()
        local subscriber_count = 1000
        local notification_count = 100
        local elapsed, count, expected = run_observer_notification_stress(subscriber_count, notification_count)
        print(string.format("[STRESS] %d observer notifications in %.4fs (%.0f/sec)",
            expected, elapsed, expected / elapsed))

        expect_true(elapsed < 10.0, "observer budget: " .. elapsed .. "s")
        expect_equal(expected, count, "all notifications delivered")
    end)
end)

-- @describe stress: patterns command queue throughput
describe("stress: patterns command queue throughput", function()
    -- @stress LCommandQueue:enqueue
    it("10000 commands enqueued and executed: <10s", function()
        local count = 10000
        local elapsed, queue_count = run_command_enqueue_stress(count)
        print(string.format("[STRESS] %d commands enqueued in %.4fs (%.0f/sec)",
            count, elapsed, count / elapsed))

        expect_true(elapsed < 10.0, "command queue budget: " .. elapsed .. "s")
        expect_equal(count, queue_count, "all commands enqueued")
    end)
end)

-- @describe stress: patterns state machine throughput
describe("stress: patterns state machine throughput", function()
    -- @stress LStateMachine:forceState
    it("5000 state transitions in <10s", function()
        local count = 5000
        local elapsed = measure_force_state_stress(count)
        expect_true(elapsed < 10.0, "SM transition budget: " .. elapsed .. "s")
    end)
end)
test_summary()
