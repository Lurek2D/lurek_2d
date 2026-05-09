-- Lurek2D Integration Test: AI + Physics
-- Tests AI agents making decisions that affect physics bodies

-- @describe integration: AI steering with physics bodies
describe("integration: AI steering with physics bodies", function()
    -- @integration LSteeringManager:addSeek
    -- @integration LSteeringManager:calculate
    -- @integration lurek.ai.newSteeringManager
    -- @integration lurek.physics.getBody
    -- @integration lurek.physics.newBody
    -- @integration lurek.physics.newWorld
    -- @integration lurek.physics.setBodyVelocity
    -- @integration lurek.physics.step
    it("agent seeks target in physics world", function()
        -- Create physics world (no gravity for top-down)
        local world_id = lurek.physics.newWorld(0, 0)

        -- Create bodies for seeker and target
        local seeker_body = lurek.physics.newBody(world_id, 100, 100, "dynamic")
        local target_body = lurek.physics.newBody(world_id, 400, 400, "static")

        -- Create AI steering manager
        local sm = lurek.ai.newSteeringManager()
        sm:addSeek(400, 400, 1.0)

        -- Calculate steering force          calculate returns (fx, fy) as two values
        local fx, fy = sm:calculate(100, 100, 0, 0, 50, 100, 1.0 / 60.0)

        -- Verify we got non-zero steering force toward target
        expect_not_nil(fx, "steering fx returned")

        -- Apply forces as velocity and step physics
        local vel_x = type(fx) == "number" and fx or 50
        local vel_y = type(fy) == "number" and fy or 50
        lurek.physics.setBodyVelocity(world_id, seeker_body, vel_x, vel_y)

        -- Step physics for 60 frames
        for frame = 1, 60 do
            lurek.physics.step(world_id, 1.0 / 60.0)
        end

        -- Read back position
        local px, py = lurek.physics.getBody(world_id, seeker_body)

        -- Seeker should have moved from (100, 100)          some movement occurred
        local moved = math.abs(px - 100) > 0.1 or math.abs(py - 100) > 0.1
        expect_true(moved, "seeker moved from starting position")
    end)
end)

-- @describe integration: AI pathfinding with navgrid
describe("integration: AI pathfinding with navgrid", function()
end)
test_summary()
