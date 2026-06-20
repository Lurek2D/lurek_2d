local util = require("util")
local asteroid_logic = require("asteroids")

local M = {}

M.STATUS = { TITLE = "title", PLAYING = "playing", GAME_OVER = "game_over" }

local function respawn_ship(game)
    game.ship = {
        x = game.config.screen.w / 2,
        y = game.config.screen.h / 2,
        angle = -math.pi / 2,
        vx = 0,
        vy = 0,
        thrusting = false,
    }
    game.respawn = game.config.ship.respawn_time
end

function M.new(config)
    return {
        config = config,
        status = M.STATUS.TITLE,
        score = 0,
        lives = 3,
        wave = 0,
        bullets = {},
        asteroids = {},
        fire_timer = 0,
        respawn = 0,
    }
end

function M.start(game)
    game.status = M.STATUS.PLAYING
    game.score = 0
    game.lives = 3
    game.wave = 1
    game.bullets = {}
    game.asteroids = {}
    game.fire_timer = 0
    respawn_ship(game)
    asteroid_logic.spawn_wave(game.config, game.asteroids, game.wave)
end

function M.rotate(game, dir, dt)
    game.ship.angle = game.ship.angle + dir * game.config.ship.turn_speed * dt
end

function M.thrust(game, dt, effects)
    local ship = game.ship
    ship.thrusting = true
    ship.vx = ship.vx + math.cos(ship.angle) * game.config.ship.thrust * dt
    ship.vy = ship.vy + math.sin(ship.angle) * game.config.ship.thrust * dt
    local tx = ship.x - math.cos(ship.angle) * game.config.ship.radius
    local ty = ship.y - math.sin(ship.angle) * game.config.ship.radius
    effects.ship_thrust(tx, ty)
end

function M.fire(game, audio)
    if game.fire_timer > 0 or #game.bullets >= game.config.bullets.max then return end
    local ship = game.ship
    game.fire_timer = game.config.bullets.cooldown
    game.bullets[#game.bullets + 1] = {
        x = ship.x + math.cos(ship.angle) * game.config.ship.radius,
        y = ship.y + math.sin(ship.angle) * game.config.ship.radius,
        vx = math.cos(ship.angle) * game.config.bullets.speed + ship.vx * 0.5,
        vy = math.sin(ship.angle) * game.config.bullets.speed + ship.vy * 0.5,
        life = game.config.bullets.lifetime,
    }
    audio.play("fire")
end

local function update_bullets(game, dt)
    local i = 1
    while i <= #game.bullets do
        local b = game.bullets[i]
        b.x = util.wrap(b.x + b.vx * dt, game.config.screen.w)
        b.y = util.wrap(b.y + b.vy * dt, game.config.screen.h)
        b.life = b.life - dt
        if b.life <= 0 then table.remove(game.bullets, i) else i = i + 1 end
    end
end

local function bullet_hits(game, effects, audio)
    local i = 1
    while i <= #game.bullets do
        local bullet = game.bullets[i]
        local hit = false
        for j = #game.asteroids, 1, -1 do
            local asteroid = game.asteroids[j]
            if util.circle_hit(bullet.x, bullet.y, 2, asteroid.x, asteroid.y, asteroid.radius * 0.85) then
                local value = game.config.asteroids.score[asteroid.size]
                game.score = game.score + value
                effects.score(asteroid.x, asteroid.y, value)
                effects.explode(asteroid.x, asteroid.y, ({ large = 28, medium = 18, small = 10 })[asteroid.size])
                asteroid_logic.split(game.config, game.asteroids, asteroid)
                table.remove(game.asteroids, j)
                audio.play("hit")
                hit = true
                break
            end
        end
        if hit then table.remove(game.bullets, i) else i = i + 1 end
    end
end

local function ship_hits(game, effects, audio)
    if game.respawn > 0 then return end
    for _, asteroid in ipairs(game.asteroids) do
        if util.circle_hit(game.ship.x, game.ship.y, game.config.ship.radius * 0.65, asteroid.x, asteroid.y, asteroid.radius * 0.85) then
            game.lives = game.lives - 1
            effects.explode(game.ship.x, game.ship.y, 32)
            audio.play("death")
            if game.lives <= 0 then
                game.status = M.STATUS.GAME_OVER
            else
                respawn_ship(game)
            end
            return
        end
    end
end

function M.update(game, dt, effects, audio)
    if game.status ~= M.STATUS.PLAYING then return end
    game.fire_timer = math.max(0, game.fire_timer - dt)
    game.respawn = math.max(0, game.respawn - dt)
    game.ship.thrusting = false
    game.ship.vx = game.ship.vx * game.config.ship.drag
    game.ship.vy = game.ship.vy * game.config.ship.drag
    game.ship.x = util.wrap(game.ship.x + game.ship.vx * dt, game.config.screen.w)
    game.ship.y = util.wrap(game.ship.y + game.ship.vy * dt, game.config.screen.h)
    update_bullets(game, dt)
    asteroid_logic.update(game.config, game.asteroids, dt)
    bullet_hits(game, effects, audio)
    ship_hits(game, effects, audio)
    if game.status == M.STATUS.PLAYING and #game.asteroids == 0 then
        game.wave = game.wave + 1
        asteroid_logic.spawn_wave(game.config, game.asteroids, game.wave)
    end
end

return M
