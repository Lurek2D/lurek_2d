-- Stress test: physics zones with many bodies
-- Creates 50 zones and 500 dynamic bodies, steps 60 times.
-- Verifies no crash and reasonable zone-event throughput.

-- @description Covers suite: stress: physics zones throughput.
describe("stress: physics zones throughput", function()
    -- @covers World:addZone
    -- @covers LuaZone:setGravityZero
    -- @covers World:newBody
    -- @covers World:step
    -- @covers World:getZoneEvents
    -- @description Creates 50 zones and 500 bodies and steps 60 frames
    --              without error. Verifies event table is returned.
    it("50 zones + 500 bodies steps 60 frames without error", function()
        local world = lurek.physics.newWorld(0, 0)

        -- Create 50 overlapping zones.
        for i = 1, 50 do
            local z = world:addZone(-200 + i * 4, -200 + i * 4, 400, 400)
            z:setGravityZero()
            z:setPriority(i)
        end

        -- Create 500 dynamic bodies scattered across the arena.
        for i = 1, 500 do
            local x = (i % 50) * 8 - 200
            local y = math.floor(i / 50) * 8 - 200
            world:newBody(x, y, 4, 4, "dynamic")
        end

        -- Step 60 frames.
        expect_no_error(function()
            for _ = 1, 60 do
                world:step(1/60)
            end
        end)

        -- Events must be a table; may be large.
        local events = world:getZoneEvents()
        expect_type("table", events)
    end)
end)

test_summary()
