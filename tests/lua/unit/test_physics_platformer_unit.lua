-- Lurek2D Physics + one-way-platform integration test
-- Tests lurek.physics interacting with a one-way floor setup:
-- a dynamic body falls toward a one-way static platform.
-- Requires both lurek.physics and the extension methods.

-- @describe one-way platform integration
describe("one-way platform integration", function()
    local world, floor, player

    before_each(function()
        -- Gravity pointing down (+Y).
        world  = lurek.physics.newWorld(0, 200)
        -- A wide static floor at y=500.
        floor  = lurek.physics.newBody(world, 400, 500, "static")
        -- Mark the floor as one-way: normal points upward (0, -1)
        -- so bodies approaching from above are blocked.
        world:setBodyOneWay(floor:getId(), 0, -1)
        -- A dynamic player above the floor.
        player = lurek.physics.newBody(world, 400, 100, "dynamic")
    end)

    -- @covers LWorld:getBodyOneWay
    it("floor has correct one-way normal", function()
        local nx, ny = world:getBodyOneWay(floor:getId())
        expect_near(0,  nx, 1e-5)
        expect_near(-1, ny, 1e-5)
    end)

    -- @covers LWorld:step
    -- @covers lurek.physics.getBody
    it("world stepping advances dynamic body under gravity", function()
        local _, y0 = lurek.physics.getBody(world, player)
        for _ = 1, 10 do
            world:step(1/60)
        end
        local _, y1 = lurek.physics.getBody(world, player)
        expect_true(y1 > y0, "player should move down after world steps")
    end)
end)

-- @describe contact callbacks and sleeping integration
describe("contact callbacks and sleeping integration", function()
    local world
    local began, ended

    before_each(function()
        world = lurek.physics.newWorld(0, 0)
        began = 0
        ended = 0
        world:setBeginContact(function(a, b)
            began = began + 1
        end)
        world:setEndContact(function(a, b)
            ended = ended + 1
        end)
    end)

    -- @covers LWorld:setBeginContact
    -- @covers LWorld:step
    -- @covers lurek.physics.newBody
    it("registered callbacks can observe contact activity", function()
        local b1 = lurek.physics.newBody(world, 0, 0, "dynamic")
        local b2 = lurek.physics.newBody(world, 0, 0, "static")
        for _ = 1, 5 do
            world:step(1/60)
        end
        expect_true(began >= 1, "begin-contact callback should fire at least once")
    end)

    -- @covers LWorld:clearBeginContact
    -- @covers LWorld:clearEndContact
    -- @covers LWorld:step
    it("stepping after clearing callbacks does not error", function()
        world:clearBeginContact()
        world:clearEndContact()
        world:step(1/60)
        expect_equal(0, began)
        expect_equal(0, ended)
    end)

    -- @covers LBody:getId
    -- @covers LWorld:step
    -- @covers LWorld:sleepBody
    -- @covers LWorld:wakeUpBody
    -- @covers lurek.physics.getBody
    -- @covers lurek.physics.newBody
    -- @covers lurek.physics.newWorld
    it("sleep prevents motion until wake re-enables simulation", function()
        local gravity_world = lurek.physics.newWorld(0, 100)
        local b = lurek.physics.newBody(gravity_world, 0, 0, "dynamic")
        local _, y0 = lurek.physics.getBody(gravity_world, b)
        gravity_world:sleepBody(b:getId())
        gravity_world:step(1/60)
        local _, y_sleep = lurek.physics.getBody(gravity_world, b)
        expect_near(y0, y_sleep, 1e-5, "sleeping body should not move")

        gravity_world:wakeUpBody(b:getId())
        gravity_world:step(1/60)
        local _, y_awake = lurek.physics.getBody(gravity_world, b)
        expect_true(y_awake > y_sleep, "woken body should move under gravity")
    end)
end)

-- @describe batch body creation integration
describe("batch body creation integration", function()
    local world

    before_each(function()
        world = lurek.physics.newWorld(0, 9.81)
    end)

    -- @covers LWorld:newBodies
    it("batch-created bodies can be stepped", function()
        local ids = world:newBodies({
            {0,   0, "dynamic"},
            {100, 0, "static"},
            {200, 0, "kinematic"},
        })
        expect_equal(3, #ids)
        expect_no_error(function()
            for _ = 1, 5 do
                world:step(1/60)
            end
        end)
    end)

    -- @covers LWorld:getSolverIterations
    -- @covers LWorld:newBodies
    -- @covers LWorld:setSolverIterations
    it("batch creation works with custom solver iterations", function()
        world:setSolverIterations(6)
        local ids = world:newBodies({{0, 0, "dynamic"}, {50, 0, "dynamic"}})
        expect_equal(2, #ids)
        expect_equal(6, world:getSolverIterations())
    end)
end)
test_summary()
