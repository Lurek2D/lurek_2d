--- Particle Module Part 3: physics collision, trail type

--@api-stub: LParticleSystem:clearCollidesWithPhysics
--@api-stub: LParticleSystem:hasCollidesWithPhysics
--@api-stub: LParticleSystem:setCollidesWithPhysics
-- Particle physics collision integration.
do
    local ps = lurek.particle.newSystem({ max = 200 })
    local world = lurek.physics.newWorld(0, 0)
    ps:setCollidesWithPhysics(world, 4.0, 0.3)
    print("has_collides=" .. tostring(ps:hasCollidesWithPhysics()))
    ps:clearCollidesWithPhysics()
    print("cleared=" .. tostring(ps:hasCollidesWithPhysics()))
end

--@api-stub: LTrail:type
-- Type introspection on LTrail.
do
    local trail = lurek.particle.newTrail(1.5, 8.0)
    print(trail:type())
end

print("particle_03.lua")
