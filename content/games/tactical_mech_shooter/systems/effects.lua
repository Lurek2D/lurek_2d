local M = {}

function M.create(state, model)
    model.effects = {}
    model.timers = {}
    model.max_effect_particles = math.max(32, tonumber(state.content.game.max_effect_particles) or 420)
    model.burst_particles = math.max(1, tonumber(state.content.game.burst_particles) or 8)
    return model
end

local function add_effect(model, effect)
    if #model.effects >= model.max_effect_particles then return false end
    model.effects[#model.effects + 1] = effect
    return true
end

local function effect_image(state, id)
    local effects = state.content.effects or state.content.content.effects or {}
    local effect = effects[id]
    return effect and effect.sprite_image
end

function M.after(state, delay, callback)
    local effects = state.battle and state.battle.model
    if not effects then return end
    effects.timers = effects.timers or {}
    effects.timers[#effects.timers + 1] = {left = math.max(0, delay or 0), callback = callback}
end

function M.update(state, dt)
    local battle = state.battle
    local model = battle and battle.model
    if not model then return end
    for i = #model.timers, 1, -1 do
        local timer = model.timers[i]
        timer.left = timer.left - dt
        if timer.left <= 0 then
            table.remove(model.timers, i)
            if type(timer.callback) == "function" then pcall(timer.callback) end
        end
    end
    for i = #model.effects, 1, -1 do
        local effect = model.effects[i]
        effect.left = effect.left - dt
        effect.x = effect.x + (effect.vx or 0) * dt
        effect.y = effect.y + (effect.vy or 0) * dt
        if effect.left <= 0 then table.remove(model.effects, i) end
    end
end

function M.burst(state, x, y, color, radius, duration)
    local model = state.battle and state.battle.model
    if not model then return end
    local rng = model.rng
    local count = model.burst_particles or 8
    for i = 1, count do
        local angle = (i / count) * math.pi * 2
        local speed = 35 + ((rng and rng:randomFloat(0, 1)) or 0.5) * 110
        add_effect(model, {
            x = x, y = y, vx = math.cos(angle) * speed, vy = math.sin(angle) * speed,
            radius = radius or 4, color = color or {1, 0.55, 0.12, 1}, left = duration or 0.35,
            sprite_image = effect_image(state, "spark"),
        })
    end
end


function M.flame(state, x, y, angle, weapon)
    local model = state.battle and state.battle.model
    if not model then return end
    local count = math.max(1, tonumber(weapon.pellets) or 1)
    local spread = math.rad(tonumber(weapon.arc or weapon.accuracy) or 20)
    local speed = tonumber(weapon.velocity) or 200
    local lifetime = tonumber(weapon.range) / math.max(1, speed)
    for i = 1, count do
        local t = count == 1 and 0 or (i - 1) / (count - 1) - 0.5
        local offset = t * spread * 1.4
        add_effect(model, {
            kind = "flame", x = x, y = y,
            vx = math.cos(angle + offset) * speed,
            vy = math.sin(angle + offset) * speed,
            radius = math.max(3, tonumber(weapon.size) or 3),
            color = weapon.color, left = lifetime, duration = lifetime, angle = angle + offset,
            sprite_image = weapon.flame_image or effect_image(state, "flame"),
        })
    end
end

function M.explosion(state, x, y, radius, color, sprite_image)
    M.burst(state, x, y, color or {1, 0.25, 0.08, 1}, radius or 8, 0.5)
    local model = state.battle and state.battle.model
    if model then
        model.explosions[#model.explosions + 1] = {
            x = x, y = y, radius = radius or 48, left = 0.36, duration = 0.36,
            color = color or {1, 0.25, 0.08, 1}, sprite_image = sprite_image or effect_image(state, "explosion"),
        }
    end
end

function M.beam(state, x1, y1, x2, y2, color, width)
    local model = state.battle and state.battle.model
    if not model then return end
    add_effect(model, {
        kind = "beam", x = x1, y = y1, x2 = x2, y2 = y2,
        vx = 0, vy = 0, color = color or {0.2, 1, 0.4, 1},
        width = width or 3, left = 0.09, sprite_image = effect_image(state, "beam"),
    })
end

function M.smoke(state, x, y, radius, duration)
    local model = state.battle and state.battle.model
    if not model then return end
    model.smoke[#model.smoke + 1] = {
        x = x, y = y, radius = radius or 56, left = duration or 8,
        sprite_image = effect_image(state, "smoke"),
    }
    M.burst(state, x, y, {0.35, 0.38, 0.42, 0.65}, radius or 18, 0.6)
end

return M
