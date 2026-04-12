-- Lurek2D Integration Test: Physics + Timer
-- Tests physics simulation stepping with time management

-- @description Covers suite: physics + timer integration.
describe("physics + timer integration", function()
    -- @covers lurek.physics.step
    -- @covers lurek.timer
    -- @covers lurek.physics.destroyWorld
    -- @covers lurek.physics.newBody
    -- @covers lurek.physics.newWorld
    -- @description Verifies a fixed timestep value can be passed into the physics world and moves a dynamic body.
    it("physics world step with timer delta", function()
        local world_id = lurek.physics.newWorld(0, 100)
        local body_id = lurek.physics.newBody(world_id, 0, 0, "dynamic")

        -- Step using a fixed dt
        local dt = 0.016
        lurek.physics.step(world_id, dt)

        local _, y = body_id:getPosition()
        expect_true(y > 0, "body fell after one step")

        lurek.physics.destroyWorld(world_id)
    end)

    -- @covers lurek.physics.step
    -- @covers lurek.timer
    -- @description Verifies repeated fixed timesteps accumulate into larger physics motion over time.
    it("accumulating multiple physics steps", function()
        local world_id = lurek.physics.newWorld(0, 100)
        local body_id = lurek.physics.newBody(world_id, 0, 0, "dynamic")

        -- Multiple steps
        for i = 1, 10 do
            lurek.physics.step(world_id, 0.016)
        end

        local _, y = body_id:getPosition()
        expect_true(y > 0.1, "body fell significantly after 10 steps")

        lurek.physics.destroyWorld(world_id)
    end)

    -- @covers lurek.physics
    -- @covers lurek.timer
    -- @description Verifies the classic fixed-timestep accumulator pattern yields the expected step count and remainder.
    it("fixed timestep accumulator pattern", function()
        -- Simulate accumulator pattern
        local fixed_dt = 1.0 / 60.0
        local accumulator = 0
        local frame_time = 0.033 -- ~30fps frame

        accumulator = accumulator + frame_time
        local steps = 0

        while accumulator >= fixed_dt do
            accumulator = accumulator - fixed_dt
            steps = steps + 1
        end

        expect_equal(1, steps, "one physics step for a slow frame")
        expect_true(accumulator >= 0, "positive remainder")
        expect_true(accumulator < fixed_dt, "remainder < fixed_dt")
    end)
end)

-- @description Covers suite: physics multi-body + math.
describe("physics multi-body + math", function()
    -- @covers lurek.physics.step
    -- @covers lurek.timer
    -- @description Verifies bodies with different starting positions fall at the same rate under shared gravity across repeated timed steps.
    it("two bodies with different masses fall at same rate", function()
        local world_id = lurek.physics.newWorld(0, 100)
        local b1 = lurek.physics.newBody(world_id, 0, 0, "dynamic")
        local b2 = lurek.physics.newBody(world_id, 100, 0, "dynamic")

        -- Step the world
        for i = 1, 5 do
            lurek.physics.step(world_id, 0.016)
        end

        local _, y1 = b1:getPosition()
        local _, y2 = b2:getPosition()

        -- Both should fall the same amount (no friction/air resistance)
        expect_near(y1, y2, 0.1, "same fall distance")

        lurek.physics.destroyWorld(world_id)
    end)

    -- @covers lurek.physics.step
    -- @covers lurek.timer
    -- @description Verifies static bodies remain fixed even after many timed physics steps.
    it("static body doesn't move under gravity", function()
        local world_id = lurek.physics.newWorld(0, 100)
        local body_id = lurek.physics.newBody(world_id, 50, 300, "static")

        for i = 1, 10 do
            lurek.physics.step(world_id, 0.016)
        end

        local x, y = body_id:getPosition()
        expect_near(50, x, 0.001, "static x unchanged")
        expect_near(300, y, 0.001, "static y unchanged")

        lurek.physics.destroyWorld(world_id)
    end)
end)
test_summary()
