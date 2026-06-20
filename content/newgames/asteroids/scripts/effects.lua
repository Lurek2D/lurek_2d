local M = { score_pops = {} }

function M.init(config)
    M.config = config
    M.explosions = lurek.particle.newSystem({
        maxParticles = 450,
        emissionRate = 0,
        lifetimeMin = 0.25,
        lifetimeMax = 0.9,
        speedMin = 50,
        speedMax = 210,
        direction = 0,
        spread = math.pi,
        sizes = { 4, 2, 1, 0 },
        colors = {
            { 1.0, 0.9, 0.55, 1 },
            { 1.0, 0.45, 0.12, 0.7 },
            { 0.6, 0.2, 0.0, 0 },
        },
    })
    M.thrust = lurek.particle.newSystem({
        maxParticles = 160,
        emissionRate = 0,
        lifetimeMin = 0.1,
        lifetimeMax = 0.35,
        speedMin = 40,
        speedMax = 150,
        direction = 0,
        spread = 0.6,
        sizes = { 3, 2, 0 },
        colors = {
            { 0.3, 0.65, 1.0, 1 },
            { 0.1, 0.25, 0.8, 0.5 },
            { 0.05, 0.1, 0.25, 0 },
        },
    })
end

function M.explode(x, y, count)
    if not M.explosions then return end
    M.explosions:moveTo(x, y)
    M.explosions:emit(count or 18)
end

function M.ship_thrust(x, y)
    if not M.thrust then return end
    M.thrust:moveTo(x, y)
    M.thrust:emit(2)
end

function M.score(x, y, value)
    local pop = { x = x, y = y, value = value, alpha = 1, dy = 0 }
    M.score_pops[#M.score_pops + 1] = pop
    if lurek.tween then lurek.tween.to(pop, { alpha = 0, dy = -38 }, 0.75, "outQuad") end
end

function M.update(dt)
    if lurek.tween then lurek.tween.update(dt) end
    if M.explosions then M.explosions:update(dt) end
    if M.thrust then M.thrust:update(dt) end
    local i = 1
    while i <= #M.score_pops do
        if M.score_pops[i].alpha <= 0.02 then table.remove(M.score_pops, i) else i = i + 1 end
    end
end

return M
