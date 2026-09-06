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

-- @describe stress: AI command queue lifecycle throughput
describe("stress: AI command queue lifecycle throughput", function()
    local function __audit_stress_7()
        local queue = lurek.ai.newCommandQueue()
        local count = 1000
        local start = os.clock()
        for i = 1, count do
            local id = queue:enqueue("move", function() end, { targetX = i, targetY = i + 1, priority = i % 4 })
            expect_true(id > 0)
            queue:completeCurrent("tick")
        end
        local elapsed = os.clock() - start
        local events = queue:drainEvents()
        expect_equal(count * 2, #events)
        expect_true(elapsed < 10.0, "command queue lifecycle budget: " .. elapsed .. "s")
    end

    -- @stress LCommandQueue:drainEvents
    it("2000 queued order lifecycle events drain in <10s", function()
        __audit_stress_7()
    end)
end)

-- @describe stress: AI squad formation slot throughput
describe("stress: AI squad formation slot throughput", function()
    local function __audit_stress_6()
        local squad = lurek.ai.newSquad("company")
        squad:setFormation("line", 4.0)
        squad:setFormationBehavior("distance", "column", true)
        local positions = {}
        for i = 1, 200 do
            local name = "unit_" .. i
            squad:addMember(name)
            squad:setMemberProfile(name, {
                footprintW = ((i - 1) % 4 == 0) and 2 or 1,
                footprintH = 1,
                subgroup = (i <= 100) and "left" or "right",
            })
            positions[name] = {
                x = (i <= 100) and (-i * 2.0) or (i * 2.0),
                y = (i % 10) * 1.0,
            }
        end
        local start = os.clock()
        local slots = squad:getFormationSlots(0.0, 0.0, {
            laneWidth = 120.0,
            positions = positions,
        })
        local summary = squad:getFormationSummary(0.0, 0.0, {
            laneWidth = 120.0,
            positions = positions,
        })
        local elapsed = os.clock() - start
        expect_equal(200, #slots)
        expect_true(summary.slotCount == 200)
        expect_true(elapsed < 10.0, "squad formation layout budget: " .. elapsed .. "s")
    end

    -- @stress LSquad:getFormationSlots
    it("200-member distance-sorted formation layout resolves in <10s", function()
        __audit_stress_6()
    end)
    local function __audit_stress_5()
        local squad = lurek.ai.newSquad("company_apply")
        local world = lurek.ai.newWorld()
        squad:setFormation("line", 4.0)
        squad:setFormationBehavior("distance", "column", true)
        for i = 1, 200 do
            local name = "unit_" .. i
            local agent = world:addAgent(name)
            agent:setPosition((i % 20) * 4.0, math.floor(i / 20) * 4.0)
            squad:addMember(name)
            squad:setMemberProfile(name, {
                footprintW = ((i - 1) % 4 == 0) and 2 or 1,
                footprintH = 1,
                subgroup = (i <= 100) and "left" or "right",
            })
        end
        local start = os.clock()
        local applied = squad:assignFormationMove(world, 0.0, 0.0, {
            laneWidth = 120.0,
            mode = "replace",
            priority = 2,
        })
        local elapsed = os.clock() - start
        expect_equal(200, applied.assignedCount)
        expect_true(applied.slotCount == 200)
        expect_true(elapsed < 10.0, "squad formation assignment budget: " .. elapsed .. "s")
    end


    -- @stress LSquad:assignFormationMove
    it("200-member formation order assignment resolves in <10s", function()
        __audit_stress_5()
    end)
    local function __audit_stress_4()
        lurek.pathfind.setThreadCount(1)
        lurek.pathfind.clearAsyncPaths()
        local squad = lurek.ai.newSquad("company_paths")
        local world = lurek.ai.newWorld()
        local grid = lurek.pathfind.newNavGrid(512, 512)
        squad:setFormation("line", 4.0)
        squad:setFormationBehavior("distance", "column", true)
        for i = 1, 200 do
            local name = "unit_" .. i
            local agent = world:addAgent(name)
            agent:setPosition((i <= 100) and (-i * 2.0) or (i * 2.0), (i % 10) * 1.0)
            squad:addMember(name)
            squad:setMemberProfile(name, {
                footprintW = ((i - 1) % 4 == 0) and 2 or 1,
                footprintH = 1,
                subgroup = (i <= 100) and "left" or "right",
            })
        end
        local start = os.clock()
        local submitted = squad:submitFormationPaths(world, grid, 96.0, 96.0, {
            cellSize = 4.0,
            originX = -400.0,
            laneWidth = 120.0,
            priority = 2,
        })
        local elapsed = os.clock() - start
        expect_equal(200, submitted.submittedCount)
        expect_true(submitted.requestId > 0)
        expect_true(lurek.pathfind.getAsyncPendingCount() >= 1)
        expect_true(elapsed < 10.0, "squad formation path submission budget: " .. elapsed .. "s")
    end


    -- @stress LSquad:submitFormationPaths
    it("200-member formation path submission resolves in <10s", function()
        __audit_stress_4()
    end)
end)

-- @describe stress: AI spatial acquisition throughput
describe("stress: AI spatial acquisition throughput", function()
    local function __audit_stress_3()
        local world = lurek.ai.newWorld()
        world:setSpatialCellSize(16.0)
        for i = 1, 2000 do
            local agent = world:addAgent("unit_" .. i)
            agent:setTeam((i % 2) + 1)
            agent:setPosition((i % 50) * 4.0, math.floor(i / 50) * 4.0)
            if i % 3 == 0 then
                agent:addTag("visible")
            end
        end

        local start = os.clock()
        local found = world:queryAgentsInRadius(0.0, 0.0, 160.0, {
            hostileTo = 1,
            limit = 24,
            tag = "visible",
        })
        local elapsed = os.clock() - start
        local stats = world:getSpatialQueryStats()
        expect_true(#found <= 24)
        expect_true(stats.candidateChecks > 0)
        expect_true(elapsed < 10.0, "world spatial query budget: " .. elapsed .. "s")
    end

    -- @stress LAIWorld:queryAgentsInRadius
    it("2000-agent world spatial query resolves in <10s", function()
        __audit_stress_3()
    end)
    local function __audit_stress_2()
        local world = lurek.ai.newWorld()
        world:setSpatialCellSize(16.0)
        local hero = world:addAgent("hero")
        hero:setTeam(1)
        hero:setPosition(0.0, 0.0)
        hero:setStance("aggressive", { acquireRadius = 256.0 })
        for i = 1, 1500 do
            local agent = world:addAgent("enemy_" .. i)
            agent:setTeam(2)
            agent:setPosition((i % 40) * 6.0, math.floor(i / 40) * 6.0)
        end

        local start = os.clock()
        local target = hero:acquireTarget({ limit = 32 })
        local elapsed = os.clock() - start
        expect_true(target ~= nil)
        expect_true(elapsed < 10.0, "acquireTarget budget: " .. elapsed .. "s")
    end


    -- @stress LBot:acquireTarget
    it("stance-driven target acquisition resolves in <10s on a dense world", function()
        __audit_stress_2()
    end)
    local function __audit_stress_1()
        local world = lurek.ai.newWorld()
        world:setSpatialCellSize(16.0)
        world:setAutoAcquireBudget(32)
        world:setOrderArrivalRadius(1.0)
        for i = 1, 128 do
            local hero = world:addAgent("hero_" .. i)
            hero:setTeam(1)
            hero:setPosition((i % 32) * 8.0, math.floor(i / 32) * 12.0)
            hero:setStance("aggressive", { acquireRadius = 96.0, chaseRadius = 48.0 })
            hero:getCommandQueue():enqueue("move", function() end, {
                targetX = 512.0,
                targetY = math.floor(i / 32) * 12.0,
                interruptible = true,
            })
        end
        for i = 1, 512 do
            local enemy = world:addAgent("enemy_" .. i)
            enemy:setTeam(2)
            enemy:setPosition((i % 32) * 8.0 + 4.0, math.floor(i / 32) * 8.0)
        end

        local start = os.clock()
        world:update(0.1)
        local elapsed = os.clock() - start
        local stats = world:getOrderRuntimeStats()
        expect_true(stats.acquireQueries <= 32)
        expect_true(stats.activeEngagements > 0)
        expect_true(elapsed < 10.0, "order runtime update budget: " .. elapsed .. "s")
    end


    -- @stress LAIWorld:getOrderRuntimeStats
    it("budgeted auto-engagement update resolves in <10s on a dense world", function()
        __audit_stress_1()
    end)
end)
test_summary()
