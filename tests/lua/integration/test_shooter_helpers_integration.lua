-- Integration: input, camera, physics, and particle shooter helper pipeline.
-- @describe integration: input + camera + physics + particle shooter helpers
describe("integration: input + camera + physics + particle shooter helpers", function()
    -- @integration LCamera:presetHorizontalFollow
    -- @integration LParticleSystem:emitAt
    -- @integration LWorld:castProjectile
    -- @integration LWorld:configureCollisionGroups
    -- @integration LWorld:newCircleBody
    -- @integration LWorld:newProjectileBody
    -- @integration LWorld:step
    -- @integration lurek.input.defineActions
    -- @integration lurek.input.reset
    -- @integration lurek.particle.newPreset
    -- @integration lurek.camera.new
    -- @integration lurek.physics.newWorld
    it("casts a fired projectile and emits an impact effect", function()
        lurek.input.reset()
        lurek.input.defineActions({
            move = { "d", "a" },
            fire = { bindings = { "space", "mouse1" }, category = "combat" },
        }, "ship")

        local camera = lurek.camera.new(320, 180)
        camera:presetHorizontalFollow({ deadZoneW = 160, deadZoneH = 60, lookAhead = 0.4 })

        local world = lurek.physics.newWorld(0, 0)
        local groups = world:configureCollisionGroups({
            projectile = { group = 0, collidesWith = { "enemy" } },
            enemy = { group = 1, collidesWith = { "projectile" } },
        })
        local enemy = world:newCircleBody(40, 0, 6, "static", {
            layer = groups.enemy.layer,
            mask = groups.enemy.mask,
        })
        local projectile = world:newProjectileBody({
            x = 0, y = 0, radius = 2, vx = 80, vy = 0,
            layer = groups.projectile.layer,
            mask = groups.projectile.mask,
        })
        world:step(1 / 60)

        local hit = world:castProjectile({
            x = 0, y = 0, radius = 2, vx = 80, vy = 0, dt = 1,
            excludeBody = projectile:getId(),
            layer = groups.projectile.layer,
            mask = groups.projectile.mask,
        })

        local explosion = lurek.particle.newPreset("explosion")
        if hit.hit then
            explosion:emitAt(hit.x, hit.y, 6)
        end

        expect_equal(enemy:getId(), hit.hitBody)
        expect_true(explosion:getCount() >= 6)
        lurek.input.reset()
    end)
end)

test_summary()
