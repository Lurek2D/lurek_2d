local M = {
    flash = 0,
    shake_x = 0,
    shake_y = 0,
    flash_state = { value = 0 },
    shake_state = { x = 0, y = 0 },
}

function M.init(config)
    M.config = config
    M.sparks = lurek.particle.newSystem({
        maxParticles = 300,
        emissionRate = 0,
        lifetimeMin = 0.25,
        lifetimeMax = 0.75,
        speedMin = 80,
        speedMax = 220,
        direction = 0,
        spread = math.pi,
        gravityY = 220,
        sizes = { 4, 3, 1, 0 },
        colors = {
            { 1.0, 1.0, 0.75, 1 },
            { 1.0, 0.8, 0.25, 0.8 },
            { 0.8, 0.35, 0.05, 0 },
        },
    })
end

function M.line_clear(rows)
    local cfg = M.config
    if M.sparks then
        for _, row in ipairs(rows) do
            local y = cfg.board.y + (row - 1) * cfg.board.cell + cfg.board.cell / 2
            for x = 0, cfg.board.cols - 1 do
                M.sparks:moveTo(cfg.board.x + x * cfg.board.cell + cfg.board.cell / 2, y)
                M.sparks:emit(4)
            end
        end
    end
    M.flash_state.value = 0.55
    M.shake_state.x = 4
    M.shake_state.y = 2
    if lurek.tween then
        lurek.tween.to(M.flash_state, { value = 0 }, 0.28, "outQuad")
        lurek.tween.to(M.shake_state, { x = 0, y = 0 }, 0.24, "outQuad")
    end
end

function M.update(dt)
    if lurek.tween then lurek.tween.update(dt) end
    if M.sparks then M.sparks:update(dt) end
    M.flash = M.flash_state.value or 0
    M.shake_x = M.shake_state.x or 0
    M.shake_y = M.shake_state.y or 0
end

function M.offset()
    local t = lurek.timer and lurek.timer.getTime and lurek.timer.getTime() or 0
    return math.floor(M.shake_x * math.sin(t * 60)), math.floor(M.shake_y * math.cos(t * 47))
end

return M
