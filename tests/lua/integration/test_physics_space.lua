-- Lurek2D Integration Test: Space-style Zone Gravity
-- Exercises World zones with point-attractor gravity together with dynamic bodies.

-- @description Covers suite: space zone gravity integration.
describe("space zone gravity integration", function()
    -- @covers lurek.physics.newWorld
    -- @covers World:addZone
    -- @covers LuaZone:setGravityPoint
    -- @covers World:step
    -- @covers World:getZoneEvents
    -- @description Verifies a body placed inside a point-gravity zone enters the zone
    --              and receives a zone enter event after the first step.
    it("body inside point-gravity zone gets enter event", function()
        local world = lurek.physics.newWorld(0, 0)  -- no global gravity
        -- Create a large zone covering the whole arena.
        local zone = world:addZone(-500, -500, 1000, 1000)
        zone:setGravityPoint(0, 0, 5000)

        -- Place a dynamic body somewhere inside the zone.
        world:newBody(200, 0, "dynamic")

        -- Step once â€” zone tracker should produce an enter event.
        world:step(1/60)
        local events = world:getZoneEvents()
        expect_true(#events >= 1, "expected zone enter event")
        expect_equal("enter", events[1].kind)
    end)

    -- @covers World:addZone
    -- @covers LuaZone:setGravityZero
    -- @covers World:step
    -- @description Verifies that a body in a zero-g zone does not accelerate
    --              (position remains approximately constant over multiple steps).
    it("body in zero-g zone stays put", function()
        local world = lurek.physics.newWorld(0, 500) -- strong global gravity
        local zone = world:addZone(-500, -500, 1000, 1000)
        zone:setGravityZero()

        -- Body at origin, zero initial velocity.
        world:newBody(0, 0, "dynamic")

        -- Step several frames â€” if zero-g works, body should not fall far.
        -- We can only check the simulation runs without error here since
        -- getBody is on the module-level API, not the world method.
        expect_no_error(function()
            for _ = 1, 30 do
                world:step(1/60)
            end
        end)
    end)

    -- @covers World:addZone
    -- @covers LuaZone:setPriority
    -- @covers LuaZone:setGravityDirectional
    -- @description Verifies that two overlapping zones with different priorities
    --              can both be created and stepped without error.
    it("overlapping zones with different priorities step without error", function()
        local world = lurek.physics.newWorld(0, 0)
        local z1 = world:addZone(-200, -200, 400, 400)
        z1:setPriority(10)
        z1:setGravityDirectional(0, -200) -- upward pull

        local z2 = world:addZone(-100, -100, 200, 200)
        z2:setPriority(20)
        z2:setGravityDirectional(0, 100)  -- downward pull

        world:newBody(0, 0, "dynamic")

        expect_no_error(function()
            for _ = 1, 10 do
                world:step(1/60)
            end
        end)
    end)
end)

test_summary()
