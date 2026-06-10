-- test_collision_core_unit.lua
--
-- lurek.collision is NOT a standalone module.
-- Collision detection is provided by lurek.physics (see test_physics_core_unit.lua).
-- These tests document that fact and verify the physics-side collision surface exists.

-- @describe collision surface available via lurek.physics
describe("collision surface available via lurek.physics", function()
    -- @covers LWorld:getCollisionEvents
    it("getCollisionEvents returns a table on a fresh world", function()
        local world = lurek.physics.newWorld(0, 9.81)
        expect_type("userdata", world)
        local events = world:getCollisionEvents()
        expect_type("table", events)
    end)
    -- @covers LBody:setMask
    it("setMask stores the collision mask", function()
        local world = lurek.physics.newWorld(0, 9.81)
        local body = world:newCircleBody(0, 0, 5.0, "dynamic")
        body:setMask(7)
        expect_equal(7, body:getMask())
    end)

    -- @covers LBody:getMask
    it("getMask returns the configured collision mask", function()
        local world = lurek.physics.newWorld(0, 9.81)
        local body = world:newCircleBody(0, 0, 5.0, "dynamic")
        body:setMask(11)
        expect_equal(11, body:getMask())
    end)
end)
test_summary()
