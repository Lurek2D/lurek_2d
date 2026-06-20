local M = {}

function M.init(config)
    M.config = config
    M.food = lurek.particle.newSystem({
        maxParticles = 120,
        emissionRate = 0,
        lifetimeMin = 0.2,
        lifetimeMax = 0.55,
        speedMin = 80,
        speedMax = 200,
        direction = 0,
        spread = math.pi * 2,
        gravityY = 60,
        sizes = { 4, 3, 1.5, 0 },
        colors = {
            { 1.0, 0.4, 0.2, 1 },
            { 1.0, 0.8, 0.1, 0.8 },
            { 0.2, 1.0, 0.2, 0 },
        },
    })
end

function M.eat(cx, cy)
    if not M.food then return end
    local cell = M.config.grid.cell
    M.food:moveTo(cx * cell + cell / 2, M.config.grid.hud_h + cy * cell + cell / 2)
    M.food:emit(18)
end

function M.update(dt)
    if M.food then M.food:update(dt) end
end

return M
