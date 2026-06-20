local util = require("util")

local M = {}

local function make_verts(radius)
    local verts = {}
    local count = math.random(7, 10)
    for i = 1, count do
        local a = (i - 1) / count * util.PI2
        local r = radius * (0.72 + math.random() * 0.44)
        verts[#verts + 1] = { math.cos(a) * r, math.sin(a) * r }
    end
    return verts
end

function M.spawn(config, list, x, y, size)
    local angle = math.random() * util.PI2
    local speed = config.asteroids.speed[size]
    list[#list + 1] = {
        x = x,
        y = y,
        vx = math.cos(angle) * speed,
        vy = math.sin(angle) * speed,
        size = size,
        radius = config.asteroids.radius[size],
        verts = make_verts(config.asteroids.radius[size]),
    }
end

function M.spawn_wave(config, list, wave)
    local count = config.asteroids.start_count + wave - 1
    for _ = 1, count do
        local edge = math.random(4)
        local x, y
        if edge == 1 then x, y = math.random() * config.screen.w, 0
        elseif edge == 2 then x, y = config.screen.w, math.random() * config.screen.h
        elseif edge == 3 then x, y = math.random() * config.screen.w, config.screen.h
        else x, y = 0, math.random() * config.screen.h end
        M.spawn(config, list, x, y, "large")
    end
end

function M.update(config, list, dt)
    for _, asteroid in ipairs(list) do
        asteroid.x = util.wrap(asteroid.x + asteroid.vx * dt, config.screen.w)
        asteroid.y = util.wrap(asteroid.y + asteroid.vy * dt, config.screen.h)
    end
end

function M.split(config, list, asteroid)
    if asteroid.size == "large" then
        M.spawn(config, list, asteroid.x, asteroid.y, "medium")
        M.spawn(config, list, asteroid.x, asteroid.y, "medium")
    elseif asteroid.size == "medium" then
        M.spawn(config, list, asteroid.x, asteroid.y, "small")
        M.spawn(config, list, asteroid.x, asteroid.y, "small")
    end
end

return M
