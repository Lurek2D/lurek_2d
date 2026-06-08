-- Lurek2D Integration Test: Space-style Zone Gravity
-- Exercises World zones with point-attractor gravity together with dynamic bodies.

-- @describe space zone gravity integration
describe("space zone gravity integration", function()
    --              and receives a zone enter event after the first step.
    -- @covers LWorld:addZone
    -- @covers LWorld:getZoneEvents
    -- @covers LWorld:newBody
    -- @covers LWorld:step
    -- @covers LZone:setGravityPoint
    -- @covers lurek.physics.newWorld
    it("body inside point-gravity zone gets enter event", function()
        local world = lurek.physics.newWorld(0, 0)  -- no global gravity
        -- Create a large zone covering the whole arena.
        local zone = world:addZone(-500, -500, 1000, 1000)
        zone:setGravityPoint(0, 0, 5000)

        -- Place a dynamic body somewhere inside the zone.
        world:newBody(200, 0, "dynamic")

        -- Step once          zone tracker should produce an enter event.
        world:step(1/60)
        local events = world:getZoneEvents()
        expect_true(#events >= 1, "expected zone enter event")
        expect_equal("enter", events[1].kind)
    end)

    --              (position remains approximately constant over multiple steps).
    -- @covers LWorld:addZone
    -- @covers LWorld:newBody
    -- @covers LWorld:step
    -- @covers LZone:setGravityZero
    -- @covers lurek.physics.getBody
    -- @covers lurek.physics.newWorld
    it("body in zero-g zone stays put", function()
        local world = lurek.physics.newWorld(0, 500) -- strong global gravity
        local zone = world:addZone(-500, -500, 1000, 1000)
        zone:setGravityZero()

        -- Body at origin, zero initial velocity.
        local body = world:newBody(0, 0, "dynamic")
        local x0, y0 = lurek.physics.getBody(world, body)

        -- Step several frames          if zero-g works, body should not fall far.
        -- We can only check the simulation runs without error here since
        -- getBody is on the module-level API, not the world method.
        for _ = 1, 30 do
            world:step(1/60)
        end
        local x1, y1 = lurek.physics.getBody(world, body)
        expect_near(x0, x1, 1e-3)
        expect_near(y0, y1, 1e-3)
    end)

    --              can both be created and stepped without error.
    -- @covers LWorld:addZone
    -- @covers LWorld:newBody
    -- @covers LWorld:getZoneEvents
    -- @covers LWorld:step
    -- @covers LZone:setGravityDirectional
    -- @covers lurek.physics.newWorld
    it("overlapping zones with different priorities step without error", function()
        local world = lurek.physics.newWorld(0, 0)
        local z1 = world:addZone(-200, -200, 400, 400)
        z1:setPriority(10)
        z1:setGravityDirectional(0, -200) -- upward pull

        local z2 = world:addZone(-100, -100, 200, 200)
        z2:setPriority(20)
        z2:setGravityDirectional(0, 100)  -- downward pull

        world:newBody(0, 0, "dynamic")

        for _ = 1, 10 do
            world:step(1/60)
        end
        local events = world:getZoneEvents()
        expect_type("table", events)
    end)
end)
test_summary()
