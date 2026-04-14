-- Lurek2D Physics Extension API Tests
-- Tests for breakable joints, one-way platforms, body sleeping,
-- solver iterations, CCD, contact callbacks, and batch body creation.

-- ── Solver iterations ──────────────────────────────────────────────────────

-- @description Covers suite: lurek.physics solver iterations API.
describe("lurek.physics solver iterations", function()
    local world

    before_each(function()
        world = lurek.physics.newWorld(0, 9.81)
    end)

    -- @covers lurek.physics.World:getSolverIterations
    -- @description Verifies default solver iteration count is 4.
    it("default solver iteration count is 4", function()
        expect_equal(4, world:getSolverIterations())
    end)

    -- @covers lurek.physics.World:setSolverIterations
    -- @covers lurek.physics.World:getSolverIterations
    -- @description Verifies setSolverIterations persists the new value.
    it("setSolverIterations persists the value", function()
        world:setSolverIterations(8)
        expect_equal(8, world:getSolverIterations())
    end)

    -- @covers lurek.physics.World:setSolverIterations
    -- @description Verifies values below 1 are clamped to 1.
    it("setSolverIterations clamps zero to 1", function()
        world:setSolverIterations(0)
        expect_equal(1, world:getSolverIterations())
    end)
end)

-- ── Body sleeping ──────────────────────────────────────────────────────────

-- @description Covers suite: lurek.physics body sleep API.
describe("lurek.physics body sleeping", function()
    local world
    local body_id

    before_each(function()
        world = lurek.physics.newWorld(0, 9.81)
        body_id = lurek.physics.newBody(world, 100, 100, "dynamic")
    end)

    -- @covers lurek.physics.World:isBodySleeping
    -- @description Verifies isBodySleeping returns a boolean without error.
    it("isBodySleeping returns boolean", function()
        local sleeping = world:isBodySleeping(body_id)
        expect_type("boolean", sleeping)
    end)

    -- @covers lurek.physics.World:sleepBody
    -- @covers lurek.physics.World:isBodySleeping
    -- @description Verifies sleepBody puts a body to sleep.
    it("sleepBody puts a body to sleep", function()
        world:sleepBody(body_id)
        expect_equal(true, world:isBodySleeping(body_id))
    end)

    -- @covers lurek.physics.World:wakeUpBody
    -- @covers lurek.physics.World:sleepBody
    -- @covers lurek.physics.World:isBodySleeping
    -- @description Verifies wakeUpBody wakes a sleeping body.
    it("wakeUpBody wakes a sleeping body", function()
        world:sleepBody(body_id)
        world:wakeUpBody(body_id)
        expect_equal(false, world:isBodySleeping(body_id))
    end)

    -- @covers lurek.physics.Body:isSleeping
    -- @description Verifies Body:isSleeping returns a boolean.
    it("Body:isSleeping returns boolean", function()
        local body = lurek.physics.newBody(world, 200, 200, "dynamic")
        expect_type("boolean", body:isSleeping())
    end)

    -- @covers lurek.physics.Body:sleep
    -- @covers lurek.physics.Body:isSleeping
    -- @description Verifies Body:sleep and Body:isSleeping.
    it("Body:sleep puts the body to sleep", function()
        local body = lurek.physics.newBody(world, 300, 300, "dynamic")
        body:sleep()
        expect_equal(true, body:isSleeping())
    end)

    -- @covers lurek.physics.Body:wakeUp
    -- @covers lurek.physics.Body:sleep
    -- @covers lurek.physics.Body:isSleeping
    -- @description Verifies Body:wakeUp wakes the body after sleeping.
    it("Body:wakeUp wakes the body", function()
        local body = lurek.physics.newBody(world, 400, 400, "dynamic")
        body:sleep()
        body:wakeUp()
        expect_equal(false, body:isSleeping())
    end)
end)

-- ── One-way platform ───────────────────────────────────────────────────────

-- @description Covers suite: lurek.physics one-way platform API.
describe("lurek.physics one-way platform", function()
    local world
    local body_id

    before_each(function()
        world = lurek.physics.newWorld(0, 9.81)
        body_id = lurek.physics.newBody(world, 0, 0, "static")
    end)

    -- @covers lurek.physics.World:setBodyOneWay
    -- @covers lurek.physics.World:getBodyOneWay
    -- @description Verifies setBodyOneWay stores the normal vector.
    it("setBodyOneWay stores the normal", function()
        world:setBodyOneWay(body_id, 0, -1)
        local nx, ny = world:getBodyOneWay(body_id)
        expect_near(0,  nx, 1e-5)
        expect_near(-1, ny, 1e-5)
    end)

    -- @covers lurek.physics.World:clearBodyOneWay
    -- @covers lurek.physics.World:getBodyOneWay
    -- @description Verifies clearBodyOneWay removes the one-way normal.
    it("clearBodyOneWay removes the one-way flag", function()
        world:setBodyOneWay(body_id, 0, -1)
        world:clearBodyOneWay(body_id)
        local nx, ny = world:getBodyOneWay(body_id)
        expect_equal(nil, nx)
        expect_equal(nil, ny)
    end)

    -- @covers lurek.physics.World:getBodyOneWay
    -- @description Verifies getBodyOneWay returns nil for a normal body.
    it("getBodyOneWay returns nil for a normal body", function()
        local nx, ny = world:getBodyOneWay(body_id)
        expect_equal(nil, nx)
        expect_equal(nil, ny)
    end)
end)

-- ── CCD ────────────────────────────────────────────────────────────────────

-- @description Covers suite: lurek.physics CCD API.
describe("lurek.physics CCD", function()
    local world
    local body_id

    before_each(function()
        world = lurek.physics.newWorld(0, 9.81)
        body_id = lurek.physics.newBody(world, 100, 100, "dynamic")
    end)

    -- @covers lurek.physics.World:setBodyCCD
    -- @covers lurek.physics.World:getBodyCCD
    -- @description Verifies setBodyCCD enables CCD on a body.
    it("setBodyCCD enables CCD", function()
        world:setBodyCCD(body_id, true)
        expect_equal(true, world:getBodyCCD(body_id))
    end)

    -- @covers lurek.physics.World:setBodyCCD
    -- @covers lurek.physics.World:getBodyCCD
    -- @description Verifies setBodyCCD can disable CCD after enabling.
    it("setBodyCCD can disable CCD", function()
        world:setBodyCCD(body_id, true)
        world:setBodyCCD(body_id, false)
        expect_equal(false, world:getBodyCCD(body_id))
    end)
end)

-- ── Breakable joints ───────────────────────────────────────────────────────

-- @description Covers suite: lurek.physics breakable joint API.
describe("lurek.physics breakable joints", function()
    local world

    before_each(function()
        world = lurek.physics.newWorld(0, 0)
    end)

    -- @covers lurek.physics.World:setJointBreakForce
    -- @covers lurek.physics.World:getJointBreakForce
    -- @description Verifies setJointBreakForce stores the threshold.
    it("setJointBreakForce stores the threshold", function()
        local b1 = lurek.physics.newBody(world, 0, 0, "dynamic")
        local b2 = lurek.physics.newBody(world, 50, 0, "dynamic")
        local jid = lurek.physics.newJoint(world, b1, b2, "distance")
        world:setJointBreakForce(jid, 100.0)
        expect_near(100.0, world:getJointBreakForce(jid), 1e-4)
    end)

    -- @covers lurek.physics.World:getJointBreakForce
    -- @description Verifies getJointBreakForce returns nil for an unset joint.
    it("getJointBreakForce returns nil when not set", function()
        local b1 = lurek.physics.newBody(world, 0, 0, "dynamic")
        local b2 = lurek.physics.newBody(world, 50, 0, "dynamic")
        local jid = lurek.physics.newJoint(world, b1, b2, "distance")
        expect_equal(nil, world:getJointBreakForce(jid))
    end)
end)

-- ── Contact callbacks ──────────────────────────────────────────────────────

-- @description Covers suite: lurek.physics contact callbacks.
describe("lurek.physics contact callbacks", function()
    local world

    before_each(function()
        world = lurek.physics.newWorld(0, 0)
    end)

    -- @covers lurek.physics.World:setBeginContact
    -- @description Verifies setBeginContact accepts a function without error.
    it("setBeginContact accepts a function", function()
        expect_no_error(function()
            world:setBeginContact(function(a, b) end)
        end)
    end)

    -- @covers lurek.physics.World:clearBeginContact
    -- @description Verifies clearBeginContact does not error.
    it("clearBeginContact does not error", function()
        world:setBeginContact(function(a, b) end)
        expect_no_error(function()
            world:clearBeginContact()
        end)
    end)

    -- @covers lurek.physics.World:setEndContact
    -- @description Verifies setEndContact accepts a function without error.
    it("setEndContact accepts a function", function()
        expect_no_error(function()
            world:setEndContact(function(a, b) end)
        end)
    end)

    -- @covers lurek.physics.World:clearEndContact
    -- @description Verifies clearEndContact does not error.
    it("clearEndContact does not error", function()
        world:setEndContact(function(a, b) end)
        expect_no_error(function()
            world:clearEndContact()
        end)
    end)
end)

-- ── Batch body creation ────────────────────────────────────────────────────

-- @description Covers suite: lurek.physics batch body creation.
describe("lurek.physics newBodies", function()
    local world

    before_each(function()
        world = lurek.physics.newWorld(0, 9.81)
    end)

    -- @covers lurek.physics.World:newBodies
    -- @description Verifies newBodies returns the correct number of IDs.
    it("newBodies returns correct number of IDs", function()
        local ids = world:newBodies({
            {0, 0, "dynamic"},
            {100, 0, "static"},
            {200, 0, "kinematic"},
        })
        expect_equal(3, #ids)
    end)

    -- @covers lurek.physics.World:newBodies
    -- @description Verifies all IDs returned by newBodies are integers.
    it("newBodies IDs are integers", function()
        local ids = world:newBodies({
            {10, 20, "dynamic"},
            {30, 40, "dynamic"},
        })
        for _, id in ipairs(ids) do
            expect_type("number", id)
        end
    end)

    -- @covers lurek.physics.World:newBodies
    -- @description Verifies newBodies with an empty table returns an empty result.
    it("newBodies with empty table returns empty table", function()
        local ids = world:newBodies({})
        expect_equal(0, #ids)
    end)
end)

test_summary()
