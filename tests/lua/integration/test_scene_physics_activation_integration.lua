-- Integration: scene object groups suspend scene-owned physics stepping.
-- @describe scene + physics activation integration

describe("scene + physics activation integration", function()
    -- @integration LSceneObjectContainer:defineGroup
    -- @integration LSceneObjectContainer:add
    -- @integration LSceneObjectContainer:processPhysics
    -- @integration LSceneObjectContainer:setGroupEnabled
    -- @integration LWorld:newBody
    -- @integration LWorld:step
    -- @integration LBody:getPosition
    -- @integration lurek.physics.newWorld
    -- @integration lurek.scene.newObjectContainer
    it("physics pass can be suspended by scene object group", function()
        local world = lurek.physics.newWorld(0, 9.8)
        local body = world:newBody(0, 0, "dynamic")
        expect_not_nil(body)

        local container = lurek.scene.newObjectContainer()
        container:defineGroup("physics")
        container:add({
            group = "physics",
            process_physics = function(self, dt)
                world:step(dt)
            end,
        })

        local _, start_y = body:getPosition()
        container:setGroupEnabled("physics", "physics", false)
        container:processPhysics(1 / 60)
        local _, paused_y = body:getPosition()

        container:setGroupEnabled("physics", "physics", true)
        for _ = 1, 10 do
            container:processPhysics(1 / 60)
        end
        local _, active_y = body:getPosition()

        expect_equal(start_y, paused_y)
        expect_true(active_y > paused_y)
    end)
end)

test_summary()
