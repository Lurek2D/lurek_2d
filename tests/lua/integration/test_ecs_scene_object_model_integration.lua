-- Integration: ECS object model attached to scene-owned objects.
-- @describe ecs + scene object model integration

describe("ecs + scene object model integration", function()
    -- @integration LSceneObjectContainer:add
    -- @integration LSceneObjectContainer:update
    -- @integration LUniverse:attachObject
    -- @integration LUniverse:get
    -- @integration LUniverse:spawn
    -- @integration lurek.ecs.clearClasses
    -- @integration lurek.ecs.clearObjects
    -- @integration lurek.ecs.defineClass
    -- @integration lurek.ecs.newObject
    -- @integration lurek.scene.newObjectContainer
    it("scene container can update ECS objects attached to entities", function()
        lurek.ecs.clearObjects()
        lurek.ecs.clearClasses()
        lurek.ecs.defineClass("GameObject", {
            defaults = { x = 0, y = 0 },
            methods = {
                moveBy = function(self, dx, dy)
                    self.x = self.x + dx
                    self.y = self.y + dy
                end,
            },
        })
        lurek.ecs.defineClass("EnemyBullet", {
            extends = "GameObject",
            defaults = { speed = 120 },
        })

        local world = lurek.ecs.newUniverse()
        local entity = world:spawn()
        local bullet = lurek.ecs.newObject("EnemyBullet", { x = 10, y = 20 })
        world:attachObject(entity, bullet)

        local container = lurek.scene.newObjectContainer()
        container:add({
            object = world:get(entity, "object"),
            update = function(self, dt)
                self.object:moveBy(self.object.speed * dt, 0)
            end,
        })

        container:update(0.5)
        expect_equal(70, bullet.x)
        expect_equal("EnemyBullet", world:get(entity, "objectClass"))
    end)
end)

test_summary()
