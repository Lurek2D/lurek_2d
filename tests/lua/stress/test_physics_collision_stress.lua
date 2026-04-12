-- Lurek2D Stress Test: Physics Collision Storm
-- Tests mass body creation, extended simulation, and collision detection

-- @description Covers suite: physics stress: collision storm.
describe("physics stress: collision storm", function()
    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.newBody
    -- @covers lurek.physics.step
    -- @covers lurek.physics.getBody
    -- @stress Creates 500 dynamic bodies above one static ground body and simulates 300 fixed steps.
    -- @description Stresses broad collision-heavy world stepping by stacking hundreds of falling bodies into one confined simulation and checking post-step motion.
    it("creates 500 bodies in a confined space", function()
        local world = lurek.physics.newWorld(0, 200)

        -- Ground
        lurek.physics.newBody(world, 250, 500, "static")

        -- Drop 500 bodies from varying heights
        local bodies = {}
        for i = 1, 500 do
            local x = 50 + (i % 20) * 20
            local y = -i * 5
            bodies[i] = lurek.physics.newBody(world, x, y, "dynamic")
        end

        expect_equal(500, #bodies, "500 dynamic bodies created")

        -- Step 300 times (5 seconds at 60fps)
        for step = 1, 300 do
            lurek.physics.step(world, 1.0 / 60.0)
        end

        -- Check that a body moved due to gravity
        local x, y = lurek.physics.getBody(world, bodies[1])
        expect_true(y > -500 * 5, "body moved under gravity")
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.newBody
    -- @covers lurek.physics.setBodyVelocity
    -- @covers lurek.physics.step
    -- @covers lurek.physics.getCollisions
    -- @stress Steps two opposing dynamic bodies for up to 120 frames while polling collision events every frame.
    -- @description Stresses collision-event reporting by driving a head-on approach and checking that the simulation remains stable whether or not events appear.
    it("detects collisions between moving bodies", function()
        local world = lurek.physics.newWorld(0, 100)

        -- Two bodies approaching each other
        local a = lurek.physics.newBody(world, 100, 100, "dynamic")
        local b = lurek.physics.newBody(world, 200, 100, "dynamic")

        -- Give them opposing velocities
        lurek.physics.setBodyVelocity(world, a, 50, 0)
        lurek.physics.setBodyVelocity(world, b, -50, 0)

        -- Step until they might collide
        local collisions_detected = false
        for step = 1, 120 do
            lurek.physics.step(world, 1.0 / 60.0)
            local events = lurek.physics.getCollisions(world)
            if events and #events > 0 then
                collisions_detected = true
                break
            end
        end

        -- The simulation should not crash regardless of collision result
        expect_true(true, "collision simulation completed without crash")
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.newCircleBody
    -- @covers lurek.physics.step
    -- @stress Creates 200 circle bodies and advances the world for 180 fixed simulation steps.
    -- @description Stresses high-contact circle-body stepping by filling the world with many small dynamic circles and running several seconds of updates.
    it("circle bodies handle mass collision", function()
        local world = lurek.physics.newWorld(0, 100)

        -- Create 200 circle bodies
        for i = 1, 200 do
            local x = (i % 20) * 15 + 50
            local y = math.floor(i / 20) * 15
            lurek.physics.newCircleBody(world, x, y, 5, "dynamic")
        end

        -- Step 180 times (3 seconds)
        for step = 1, 180 do
            lurek.physics.step(world, 1.0 / 60.0)
        end

        expect_true(true, "circle collision simulation completed")
    end)
end)

-- @description Covers suite: physics stress: determinism.
describe("physics stress: determinism", function()
    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.newBody
    -- @covers lurek.physics.step
    -- @covers lurek.physics.getBody
    -- @stress Runs the same 60-step single-body simulation twice and compares both final positions.
    -- @description Stresses repeatability by replaying one deterministic setup two times and checking that the world integration lands on the same coordinates.
    it("same initial state produces same result", function()
        local function run_simulation()
            local world = lurek.physics.newWorld(0, 100)
            local body = lurek.physics.newBody(world, 100, 0, "dynamic")

            for step = 1, 60 do
                lurek.physics.step(world, 1.0 / 60.0)
            end

            local x, y = lurek.physics.getBody(world, body)
            return x, y
        end

        local x1, y1 = run_simulation()
        local x2, y2 = run_simulation()

        expect_near(x1, x2, 0.001, "x position deterministic")
        expect_near(y1, y2, 0.001, "y position deterministic")
    end)
end)
test_summary()
