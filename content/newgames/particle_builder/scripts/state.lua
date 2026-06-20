local M = {}
function M.new(config)
    local ps = lurek.particle.newSystem({ maxParticles = 900 })
    ps:setEmissionRate(90)
    ps:setParticleLifetime(0.4, 1.6)
    ps:setColors({1, 0.8, 0.2, 1}, {0.2, 0.7, 1, 0})
    return { particles = ps, rate = 90, life_min = 0.4, life_max = 1.6, spread = 6.28, mode = "Spark Fountain", x = 480, y = 285 }
end
function M.apply(app)
    app.particles:setEmissionRate(app.rate)
    app.particles:setParticleLifetime(app.life_min, app.life_max)
end
function M.update(app, dt)
    app.particles:moveTo(app.x, app.y)
    app.particles:update(dt)
end
return M
