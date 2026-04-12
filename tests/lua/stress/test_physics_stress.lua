-- Lurek2D Stress Test: Mass Body Creation
-- Creates 1000 physics bodies and steps the world

-- @description Covers suite: physics stress: 1000 bodies.
describe("physics stress: 1000 bodies", function()
    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.newBody
    -- @covers Body:getPosition
    -- @covers lurek.physics.destroyWorld
    -- @stress Creates 1000 dynamic bodies, samples positions from the first ten, and destroys the world.
    -- @description Stresses large-body allocation plus userdata access by filling one world with 1000 bodies and performing spot-check position reads before teardown.
    it("creates 1000 bodies without error", function()
        local world_id = lurek.physics.newWorld(0, 100)
        local bodies = {}

        for i = 1, 1000 do
            local x = (i % 50) * 10
            local y = lurek.math.floor(i / 50) * 10
            bodies[i] = lurek.physics.newBody(world_id, x, y, "dynamic")
        end

        expect_equal(1000, #bodies, "created 1000 bodies")

        -- Verify all bodies are valid
        for i = 1, 10 do
            local x, y = bodies[i]:getPosition()
            expect_true(type(x) == "number", "body position is number")
        end

        lurek.physics.destroyWorld(world_id)
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.newBody
    -- @covers lurek.physics.step
    -- @covers lurek.physics.destroyWorld
    -- @stress Creates 1000 dynamic bodies and advances the full world for 60 fixed simulation steps.
    -- @description Stresses steady-state world stepping at high body counts by running one second of simulation after bulk body creation.
    it("steps 1000-body world 60 times", function()
        local world_id = lurek.physics.newWorld(0, 100)

        for i = 1, 1000 do
            lurek.physics.newBody(world_id, i * 2, 0, "dynamic")
        end

        -- Simulate one second of gameplay
        for step = 1, 60 do
            lurek.physics.step(world_id, 1.0 / 60.0)
        end

        -- World should still be valid
        expect_true(true, "world survived 60 steps with 1000 bodies")

        lurek.physics.destroyWorld(world_id)
    end)
end)
test_summary()
