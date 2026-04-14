-- Lurek2D Physics Zone API Tests
-- Tests for lurek.physics zone API: addZone, LuaZone methods, getZoneEvents.

-- @description Covers suite: lurek.physics zone factory.
describe("lurek.physics zone factory", function()
    -- @covers lurek.physics.newWorld
    -- @covers World:addZone
    -- @description Verifies addZone returns a userdata zone handle.
    it("addZone returns userdata", function()
        local world = lurek.physics.newWorld(0, 9.81)
        local zone = world:addZone(0, 0, 100, 100)
        expect_type("userdata", zone)
    end)

    -- @covers World:addZone
    -- @covers LuaZone:getId
    -- @description Verifies zone IDs are unique across consecutive addZone calls.
    it("consecutive zones have different IDs", function()
        local world = lurek.physics.newWorld(0, 9.81)
        local z1 = world:addZone(0, 0, 50, 50)
        local z2 = world:addZone(50, 0, 50, 50)
        expect_false(z1:getId() == z2:getId(), "zone IDs must be unique")
    end)
end)

-- @description Covers suite: lurek.physics zone gravity modes.
describe("lurek.physics zone gravity modes", function()
    local world, zone

    before_each(function()
        world = lurek.physics.newWorld(0, 9.81)
        zone = world:addZone(0, 0, 1000, 1000)
    end)

    -- @covers LuaZone:setGravityZero
    -- @description Verifies setGravityZero does not error.
    it("setGravityZero accepts no arguments", function()
        expect_no_error(function()
            zone:setGravityZero()
        end)
    end)

    -- @covers LuaZone:setGravityDirectional
    -- @description Verifies setGravityDirectional accepts gx, gy.
    it("setGravityDirectional accepts gx and gy", function()
        expect_no_error(function()
            zone:setGravityDirectional(0, -50)
        end)
    end)

    -- @covers LuaZone:setGravityPoint
    -- @description Verifies setGravityPoint accepts centre and strength.
    it("setGravityPoint accepts cx, cy, strength", function()
        expect_no_error(function()
            zone:setGravityPoint(500, 500, 1000)
        end)
    end)

    -- @covers LuaZone:setGravityRepulsor
    -- @description Verifies setGravityRepulsor accepts centre and strength.
    it("setGravityRepulsor accepts cx, cy, strength", function()
        expect_no_error(function()
            zone:setGravityRepulsor(500, 500, 500)
        end)
    end)
end)

-- @description Covers suite: lurek.physics zone configuration.
describe("lurek.physics zone configuration", function()
    local world, zone

    before_each(function()
        world = lurek.physics.newWorld(0, 9.81)
        zone = world:addZone(0, 0, 1000, 1000)
    end)

    -- @covers LuaZone:setEnabled
    -- @description Verifies setEnabled accepts a boolean without error.
    it("setEnabled false does not error", function()
        expect_no_error(function()
            zone:setEnabled(false)
        end)
    end)

    -- @covers LuaZone:setPriority
    -- @description Verifies setPriority accepts an integer without error.
    it("setPriority accepts an integer", function()
        expect_no_error(function()
            zone:setPriority(10)
        end)
    end)

    -- @covers LuaZone:setLayerMask
    -- @description Verifies setLayerMask accepts a bitmask without error.
    it("setLayerMask accepts a bitmask", function()
        expect_no_error(function()
            zone:setLayerMask(0xFF)
        end)
    end)

    -- @covers LuaZone:setCircle
    -- @description Verifies switching to a circular boundary does not error.
    it("setCircle replaces boundary with circle", function()
        expect_no_error(function()
            zone:setCircle(500, 500, 300)
        end)
    end)

    -- @covers LuaZone:setLinearDampingOverride
    -- @description Verifies setLinearDampingOverride accepts a number.
    it("setLinearDampingOverride accepts a value", function()
        expect_no_error(function()
            zone:setLinearDampingOverride(2.0)
        end)
    end)

    -- @covers LuaZone:setAngularDampingOverride
    -- @description Verifies setAngularDampingOverride accepts a value.
    it("setAngularDampingOverride accepts a value", function()
        expect_no_error(function()
            zone:setAngularDampingOverride(1.0)
        end)
    end)

    -- @covers LuaZone:destroy
    -- @description Verifies destroy does not error.
    it("destroy does not error", function()
        expect_no_error(function()
            zone:destroy()
        end)
    end)
end)

-- @description Covers suite: lurek.physics zone events.
describe("lurek.physics zone events", function()
    -- @covers World:addZone
    -- @covers World:getZoneEvents
    -- @description Verifies getZoneEvents returns a table (may be empty before step).
    it("getZoneEvents returns a table", function()
        local world = lurek.physics.newWorld(0, 9.81)
        world:addZone(0, 0, 1000, 1000)
        local events = world:getZoneEvents()
        expect_type("table", events)
    end)

    -- @covers World:addZone
    -- @covers World:getZoneEvents
    -- @covers World:step
    -- @description Verifies that a body created inside a zone produces an enter event after the first step.
    it("body inside zone produces enter event after step", function()
        local world = lurek.physics.newWorld(0, 0)
        world:addZone(0, 0, 1000, 1000)
        world:newBody(0, 0, 100, 100, "dynamic")
        world:step(1/60)
        local events = world:getZoneEvents()
        expect_true(#events >= 1, "expected at least one zone event")
        expect_equal("enter", events[1].kind)
    end)
end)

test_summary()
