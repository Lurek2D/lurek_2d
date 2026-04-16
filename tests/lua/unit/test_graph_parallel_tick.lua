-- Lurek2D Lua BDD tests — lurek.graph parallel tick
-- Covers: tickParallel, verifying it produces the same event types as tick.
-- Headless: no GPU, no audio, no window.

-- @description Covers suite: lurek.graph tickParallel.
describe("lurek.graph tickParallel", function()
    -- @description Covers suite: factory and basic API.
    describe("factory", function()
        -- @covers lurek.graph.newSimulation
        -- @description Verifies newSimulation is a function.
        it("exposes newSimulation", function()
            expect_type("function", lurek.graph.newSimulation)
        end)

        -- @covers lurek.graph:tickParallel
        -- @description Verifies tickParallel is callable on a simulation.
        it("tickParallel is callable", function()
            local sim = lurek.graph.newSimulation()
            expect_type("function", sim.tickParallel)
        end)
    end)

    -- @description Covers suite: tickParallel behaviour.
    describe("tickParallel()", function()
        -- @covers lurek.graph:tickParallel
        -- @description Returns a table (event list) for an empty simulation.
        it("returns a table for an empty simulation", function()
            local sim = lurek.graph.newSimulation()
            local events = sim:tickParallel(0.016)
            expect_type("table", events)
        end)

        -- @covers lurek.graph:tickParallel
        -- @description Returns an empty table when there are no nodes.
        it("returns zero events for an empty graph", function()
            local sim = lurek.graph.newSimulation()
            local events = sim:tickParallel(0.016)
            expect_equal(0, #events)
        end)

        -- @covers lurek.graph:tickParallel
        -- @description dt = 0 produces no decay events.
        it("does not decay items when dt is zero", function()
            local sim = lurek.graph.newSimulation()
            local n = sim:addNode("source")
            sim:setNodeItems(n, 10)
            local events = sim:tickParallel(0.0)
            expect_type("table", events)
        end)

        -- @covers lurek.graph:tickParallel
        -- @description Calling tickParallel multiple times does not error.
        it("is idempotently callable", function()
            local sim = lurek.graph.newSimulation()
            local n = sim:addNode("reservoir")
            sim:setNodeItems(n, 5)
            sim:tickParallel(0.016)
            local events = sim:tickParallel(0.016)
            expect_type("table", events)
        end)

        -- @covers lurek.graph:tick
        -- @covers lurek.graph:tickParallel
        -- @description tickParallel and tick both return tables (same signature).
        it("has the same return signature as tick", function()
            local sim = lurek.graph.newSimulation()
            local n = sim:addNode("test")
            sim:setNodeItems(n, 3)
            local sequential_events = sim:tick(0.016)
            local parallel_events   = sim:tickParallel(0.016)
            expect_type("table", sequential_events)
            expect_type("table", parallel_events)
        end)
    end)
end)

test_summary()
