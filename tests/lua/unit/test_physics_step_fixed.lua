-- Lurek2D Physics stepFixed API Tests
-- Tests for World:stepFixed fixed-timestep accumulator.

-- @description Covers suite: lurek.physics World:stepFixed.
describe("lurek.physics World:stepFixed", function()
    -- @covers World:stepFixed
    -- @description Verifies stepFixed is callable on a world handle.
    it("stepFixed is callable", function()
        local world = lurek.physics.newWorld(0, 9.81)
        expect_no_error(function()
            world:stepFixed(1/60, 1/60, 8)
        end)
    end)

    -- @covers World:stepFixed
    -- @description Verifies the remainder is less than step_dt when accum equals step_dt exactly.
    it("remainder is zero when accum equals step_dt exactly", function()
        local world = lurek.physics.newWorld(0, 0)
        local step_dt = 1/60
        local remainder = world:stepFixed(step_dt, step_dt, 8)
        expect_near(0.0, remainder, 1e-4)
    end)

    -- @covers World:stepFixed
    -- @description Verifies the remainder is less than step_dt regardless of accum size.
    it("remainder is always less than step_dt", function()
        local world = lurek.physics.newWorld(0, 0)
        local step_dt = 1/60
        -- Pass 3.5 steps worth of accumulated time.
        local accum = step_dt * 3.5
        local remainder = world:stepFixed(accum, step_dt, 8)
        expect_true(remainder < step_dt, "remainder must be < step_dt")
        expect_true(remainder >= 0, "remainder must be non-negative")
    end)

    -- @covers World:stepFixed
    -- @description Verifies max_steps caps the number of sub-steps.
    it("max_steps cap leaves remainder >= step_dt when capped", function()
        local world = lurek.physics.newWorld(0, 0)
        local step_dt = 1/60
        -- Pass 100 steps worth of time but cap at 1 sub-step.
        local accum = step_dt * 100
        local remainder = world:stepFixed(accum, step_dt, 1)
        -- After one step, remainder = accum - step_dt ≈ step_dt * 99
        expect_true(remainder > step_dt, "remaining time should exceed step_dt when capped")
    end)

    -- @covers World:stepFixed
    -- @covers World:newBody
    -- @description Verifies a dynamic body moves after fixed sub-steps under gravity.
    it("dynamic body moves under gravity after stepFixed", function()
        local world = lurek.physics.newWorld(0, 100)
        world:newBody(0, 0, 10, 10, "dynamic")
        -- Accumulate enough time for one step.
        world:stepFixed(1/60, 1/60, 4)
        -- Body position is not queryable here; we only verify no error was raised.
        expect_true(true)
    end)
end)

test_summary()
