local M = {}

local function clamp(v, lo, hi)
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

local function distance(ax, ay, bx, by)
    if lurek.math and lurek.math.distance then
        return lurek.math.distance(ax, ay, bx, by)
    end
    local dx = bx - ax
    local dy = by - ay
    return math.sqrt(dx * dx + dy * dy)
end

local function make_particles()
    if not lurek.particle or not lurek.particle.newSystem then
        return nil
    end
    local ok, ps = pcall(lurek.particle.newSystem, { maxParticles = 420 })
    if not ok then
        ok, ps = pcall(lurek.particle.newSystem)
    end
    if not ok then
        return nil
    end
    if ps.setBufferSize then ps:setBufferSize(420) end
    if ps.setParticleLifetime then ps:setParticleLifetime(0.18, 0.72) end
    if ps.setSpeed then ps:setSpeed(40, 180) end
    if ps.setSpread then ps:setSpread(math.pi * 2) end
    if ps.setSizes then ps:setSizes(4, 2, 1) end
    return ps
end

local function emit(game, x, y, count)
    local ps = game.particles
    if not ps then
        return
    end
    if ps.moveTo then ps:moveTo(x, y) end
    if ps.emit then ps:emit(count or 12) end
end

local function reset(game)
    local a = game.cfg.ARENA
    game.mode = "title"
    game.time = game.cfg.GAME_SECONDS
    game.score = 0
    game.fuel = 0
    game.message = "Recover fuel cells and reach extraction."
    game.player = {
        x = a.x + 80,
        y = a.y + a.h * 0.5,
        vx = 0,
        vy = 0,
        shield = game.cfg.PLAYER.shield,
        invulnerable = 0,
    }
    game.cells = {
        { x = a.x + 250, y = a.y + 96, taken = false },
        { x = a.x + 460, y = a.y + 310, taken = false },
        { x = a.x + 680, y = a.y + 156, taken = false },
    }
    game.sentries = {
        { x = a.x + 330, y = a.y + 92, base_y = a.y + 92, phase = 0.2, radius = 18 },
        { x = a.x + 560, y = a.y + 300, base_y = a.y + 300, phase = 1.7, radius = 18 },
        { x = a.x + 710, y = a.y + 230, base_y = a.y + 230, phase = 2.8, radius = 20 },
    }
    game.obstacles = {
        { x = a.x + 190, y = a.y + 170, w = 74, h = 34 },
        { x = a.x + 390, y = a.y + 82, w = 42, h = 118 },
        { x = a.x + 590, y = a.y + 230, w = 120, h = 34 },
    }
    game.extract = { x = a.x + a.w - 76, y = a.y + a.h * 0.5, radius = 28, open = false }
end

local function start(game)
    game.mode = "playing"
    game.message = "Move now. Patrols are active."
end

local function rect_hit(px, py, r, rect)
    local cx = clamp(px, rect.x, rect.x + rect.w)
    local cy = clamp(py, rect.y, rect.y + rect.h)
    return distance(px, py, cx, cy) < r
end

local function move_player(game, intent, dt)
    local p = game.player
    local cfg = game.cfg.PLAYER
    local a = game.cfg.ARENA
    local nx = p.x + intent.x * cfg.speed * dt
    local ny = p.y + intent.y * cfg.speed * dt
    nx = clamp(nx, a.x + cfg.radius, a.x + a.w - cfg.radius)
    ny = clamp(ny, a.y + cfg.radius, a.y + a.h - cfg.radius)

    local blocked = false
    for _, rect in ipairs(game.obstacles) do
        if rect_hit(nx, ny, cfg.radius, rect) then
            blocked = true
            break
        end
    end
    if not blocked then
        p.x = nx
        p.y = ny
    end
end

local function damage(game, amount)
    local p = game.player
    if p.invulnerable > 0 then
        return
    end
    p.shield = math.max(0, p.shield - amount)
    p.invulnerable = 0.8
    game.message = "Shield hit. Keep moving."
    game.audio.play(game.audio, "hit")
    emit(game, p.x, p.y, 20)
    if p.shield <= 0 then
        game.mode = "lost"
        game.message = "Ship disabled. Press Space to retry."
    end
end

local function update_sentries(game, dt)
    local t = game.elapsed
    for _, s in ipairs(game.sentries) do
        s.x = s.x + math.sin(t * 1.8 + s.phase) * 16 * dt
        s.y = s.base_y + math.sin(t * 2.2 + s.phase) * 86
        if game.mode == "playing" and distance(game.player.x, game.player.y, s.x, s.y) < s.radius + game.cfg.PLAYER.radius then
            damage(game, 18)
        end
    end
end

local function update_cells(game)
    for _, cell in ipairs(game.cells) do
        if not cell.taken and distance(game.player.x, game.player.y, cell.x, cell.y) < 28 then
            cell.taken = true
            game.fuel = game.fuel + 1
            game.score = game.score + 500
            game.message = "Fuel cell secured."
            game.audio.play(game.audio, "pickup")
            emit(game, cell.x, cell.y, 24)
        end
    end
    game.extract.open = game.fuel >= game.cfg.FUEL_REQUIRED
end

local function update_extract(game)
    if game.extract.open and distance(game.player.x, game.player.y, game.extract.x, game.extract.y) < game.extract.radius then
        game.mode = "won"
        game.score = game.score + math.floor(game.time * 25) + game.player.shield * 10
        game.message = "Extraction complete. Press Space to run again."
        game.audio.play(game.audio, "win")
        emit(game, game.extract.x, game.extract.y, 48)
    end
end

function M.new(cfg, audio)
    local game = {
        cfg = cfg,
        audio = audio,
        particles = make_particles(),
        elapsed = 0,
    }
    reset(game)
    return game
end

function M.start(game)
    start(game)
end

function M.update(game, intent, dt)
    if intent.restart then
        reset(game)
        start(game)
        return
    end

    if game.mode == "title" then
        if intent.confirm then start(game) end
    elseif game.mode == "won" or game.mode == "lost" then
        if intent.confirm then
            reset(game)
            start(game)
        end
    elseif game.mode == "playing" then
        game.elapsed = game.elapsed + dt
        game.time = math.max(0, game.time - dt)
        game.player.invulnerable = math.max(0, game.player.invulnerable - dt)
        move_player(game, intent, dt)
        update_sentries(game, dt)
        update_cells(game)
        update_extract(game)
        if game.time <= 0 and game.mode == "playing" then
            game.mode = "lost"
            game.message = "Time expired. Press Space to retry."
        end
    end

    if game.particles and game.particles.update then
        game.particles:update(dt)
    end
end

function M.debug_snapshot(game)
    return {
        mode = game.mode,
        score = game.score,
        fuel = game.fuel,
        shield = game.player.shield,
        time = game.time,
        extract_open = game.extract.open,
    }
end

return M
