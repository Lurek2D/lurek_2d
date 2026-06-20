local state = require("state")

local M = {}

local function line(x1, y1, x2, y2)
    lurek.render.line(x1, y1, x2, y2)
end

local function draw_ship(config, ship, alpha)
    local a = ship.angle
    local r = config.ship.radius
    local nx = ship.x + math.cos(a) * r * 1.35
    local ny = ship.y + math.sin(a) * r * 1.35
    local lx = ship.x + math.cos(a + 2.45) * r
    local ly = ship.y + math.sin(a + 2.45) * r
    local rx = ship.x + math.cos(a - 2.45) * r
    local ry = ship.y + math.sin(a - 2.45) * r
    lurek.render.setColor(config.colors.ship[1], config.colors.ship[2], config.colors.ship[3], alpha or 1)
    line(nx, ny, lx, ly); line(lx, ly, rx, ry); line(rx, ry, nx, ny)
    if ship.thrusting then
        lurek.render.setColor(0.25, 0.6, 1.0, 0.9)
        local tx = ship.x - math.cos(a) * r * 1.2
        local ty = ship.y - math.sin(a) * r * 1.2
        line(lx, ly, tx, ty); line(rx, ry, tx, ty)
    end
end

function M.draw(config, game, effects)
    for _, asteroid in ipairs(game.asteroids) do
        local color = config.colors[asteroid.size]
        lurek.render.setColor(color[1], color[2], color[3], 1)
        for i = 1, #asteroid.verts do
            local j = (i % #asteroid.verts) + 1
            line(asteroid.x + asteroid.verts[i][1], asteroid.y + asteroid.verts[i][2], asteroid.x + asteroid.verts[j][1], asteroid.y + asteroid.verts[j][2])
        end
    end

    lurek.render.setColor(config.colors.bullet[1], config.colors.bullet[2], config.colors.bullet[3], 1)
    for _, bullet in ipairs(game.bullets) do
        lurek.render.circle("fill", bullet.x, bullet.y, 2)
    end

    if game.status == state.STATUS.PLAYING and game.ship then
        local alpha = 1
        if game.respawn > 0 and math.floor(game.respawn * 8) % 2 == 1 then alpha = 0.25 end
        draw_ship(config, game.ship, alpha)
    end

    for _, pop in ipairs(effects.score_pops) do
        lurek.render.setColor(1, 1, 0.35, pop.alpha)
        lurek.render.print(tostring(pop.value), pop.x - 10, pop.y + pop.dy)
    end

    if effects.explosions and effects.explosions.render then effects.explosions:render() end
    if effects.thrust and effects.thrust.render then effects.thrust:render() end
end

return M
