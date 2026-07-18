local M = {}

local function color(c, alpha)
    c = c or {1, 1, 1, 1}
    lurek.render.setColor(c[1] or 1, c[2] or 1, c[3] or 1, alpha or c[4] or 1)
end

local function circle_segments(cx, cy, radius, segments, dashed)
    local step = math.pi * 2 / segments
    for i = 0, segments - 1 do
        if not dashed or i % 2 == 0 then
            local a0, a1 = i * step, (i + 0.72) * step
            lurek.render.line(
                cx + math.cos(a0) * radius, cy + math.sin(a0) * radius,
                cx + math.cos(a1) * radius, cy + math.sin(a1) * radius
            )
        end
    end
end

local function spread_radius(actor, slot)
    return math.max(2, (actor.spread_slots and actor.spread_slots[slot]) or 2)
end

local function visible_bounds(model)
    local vx, vy, vw, vh = model.camera:getVisibleArea()
    return
        math.max(1, math.floor(vx / model.tile_size) - 2),
        math.min(model.width, math.ceil((vx + vw) / model.tile_size) + 2),
        math.max(1, math.floor(vy / model.tile_size) - 2),
        math.min(model.height, math.ceil((vy + vh) / model.tile_size) + 2)
end

local function draw_floor(state, model, viewer, min_x, max_x, min_y, max_y)
    for y = min_y, max_y do
        for x = min_x, max_x do
            local kind = model.world.tile(model, x, y)
            local px, py = (x - 1) * model.tile_size, (y - 1) * model.tile_size
            local visible, explored, luma = state.modules.Awareness.tile_state(state, viewer.team, x, y)
            if explored and kind ~= "wall" and kind ~= "door_closed" then
                local def = model.tile_defs[kind] or model.tile_defs.floor or {}
                local base = def.color or {0.22, 0.28, 0.36, 1}
                local factor = visible and (0.52 + math.min(0.48, luma * 0.65)) or 0.12
                lurek.render.setColor(
                    (base[1] or 0.2) * factor,
                    (base[2] or 0.2) * factor,
                    (base[3] or 0.2) * factor,
                    1
                )
                lurek.render.rectangle("fill", px, py, model.tile_size + 1, model.tile_size + 1)
            end
        end
    end
    local world_w, world_h = model.width * model.tile_size, model.height * model.tile_size
    lurek.render.setLineWidth(3)
    lurek.render.setColor(0.55, 0.12, 0.10, 0.9)
    lurek.render.rectangle("line", 1, 1, world_w - 2, world_h - 2)
    lurek.render.setLineWidth(1)
end

local function draw_terrain(state, model, viewer, min_x, max_x, min_y, max_y)
    for y = min_y, max_y do
        for x = min_x, max_x do
            local kind = model.world.tile(model, x, y)
            local _, explored = state.modules.Awareness.tile_state(state, viewer.team, x, y)
            if explored and (kind == "wall" or kind == "door_closed") and x > 1 and y > 1 and x < model.width and y < model.height then
                local cx, cy = (x - 0.5) * model.tile_size, (y - 0.5) * model.tile_size
                local r = model.tile_size * 0.47
                lurek.render.setColor(0.08, 0.08, 0.085, 0.55)
                lurek.render.ellipse("fill", cx + 5, cy + 7, r, r * 0.66)
                if kind == "door_closed" then
                    lurek.render.setColor(0.46, 0.27, 0.10, 1)
                    lurek.render.rectangle("fill", cx - r, cy - r * 0.55, r * 2, r * 1.1)
                    lurek.render.setColor(0.92, 0.62, 0.18, 0.75)
                    lurek.render.line(cx - r * 0.7, cy, cx + r * 0.7, cy)
                else
                    lurek.render.setColor(0.25, 0.25, 0.26, 1)
                    lurek.render.circle("fill", cx, cy, r)
                    lurek.render.setColor(0.36, 0.36, 0.37, 0.85)
                    lurek.render.circle("line", cx, cy, r)
                    lurek.render.circle("fill", cx - r * 0.28, cy - r * 0.24, r * 0.18)
                end
            end
        end
    end
end

local function draw_bases(state, model, viewer)
    for _, base in ipairs(model.bases or {}) do
        local cx, cy = model.world.cell(model, base.x, base.y)
        local _, explored = state.modules.Awareness.tile_state(state, viewer.team, cx, cy)
        if explored or base.team == viewer.team then
            color(base.color, 0.72)
            lurek.render.setLineWidth(3)
            circle_segments(base.x, base.y, base.radius, 48, true)
            lurek.render.circle("line", base.x, base.y, 48)
            lurek.render.setLineWidth(1)
            lurek.render.rectangle("fill", base.x - 30, base.y - 30, 60, 60)
            lurek.render.setColor(0.04, 0.05, 0.06, 1)
            lurek.render.rectangle("fill", base.x - 18, base.y - 18, 36, 36)
        end
    end
end

local function draw_weapon(weapon, side)
    local size = tonumber(weapon.size) or 2
    local length, thickness = 14 + size * 4.2, 6 + size * 1.25
    color(weapon.color or {0.65, 0.65, 0.65, 1})
    lurek.render.rectangle("fill", -4, side * 22 - thickness * 0.5, length, thickness)
    lurek.render.setColor(0.92, 0.92, 0.92, 0.35)
    lurek.render.line(1, side * 22 - thickness * 0.28, length - 2, side * 22 - thickness * 0.28)
end

local function draw_mech(actor)
    local radius = actor.radius
    local jump = actor.z_offset or 0
    local draw_y = actor.y - jump
    local body_color = actor.team_color or actor.build.corpus.color or {0.30, 0.42, 0.28, 1}

    lurek.render.setColor(0.01, 0.01, 0.01, jump > 0 and 0.5 or 0.3)
    lurek.render.ellipse("fill", actor.x + 7, actor.y + radius * 0.72, radius * 1.15, radius * 0.60)

    lurek.render.push()
    lurek.render.translate(actor.x, draw_y)
    lurek.render.rotate(actor.angle)

    if actor.build.backpack_id ~= "none" then
        color(actor.build.backpack.color or {0.25, 0.25, 0.28, 1})
        local pack_size = 12 + (tonumber(actor.build.backpack.size) or 3)
        lurek.render.rectangle("fill", -radius - 10, -pack_size, 17, pack_size * 2)
        lurek.render.setColor(0.02, 0.02, 0.025, 0.75)
        lurek.render.rectangle("line", -radius - 10, -pack_size, 17, pack_size * 2)
    end

    draw_weapon(actor.build.left, -1)
    draw_weapon(actor.build.right, 1)

    color(body_color)
    lurek.render.circle("fill", 0, 0, radius)
    lurek.render.setLineWidth(actor.is_player and 3 or 2)
    local is_hit = (actor.hit_flash or 0) > 0
    lurek.render.setColor(is_hit and 1 or 0.92, is_hit and 0.85 or 0.92, is_hit and 0.40 or 0.92, 1)
    lurek.render.circle("line", 0, 0, radius)
    lurek.render.setLineWidth(1)
    lurek.render.setColor(0.98, 0.98, 0.98, 1)
    lurek.render.rectangle("fill", radius - 7, -4, 9, 8)
    lurek.render.pop()

    if actor.team ~= "team1" then
        lurek.render.setColor(0.08, 0.02, 0.02, 0.8)
        lurek.render.rectangle("fill", actor.x - radius, draw_y - radius - 9, radius * 2, 4)
        lurek.render.setColor(0.95, 0.14, 0.10, 1)
        lurek.render.rectangle("fill", actor.x - radius, draw_y - radius - 9, radius * 2 * math.max(0, actor.hp / actor.build.max_health), 4)
    end
end

local function draw_projectiles(model)
    for _, projectile in ipairs(model.projectiles) do
        local vx, vy = projectile.vx or 0, projectile.vy or 0
        local length = math.sqrt((vx or 0) ^ 2 + (vy or 0) ^ 2)
        local nx, ny = 0, 0
        if length > 0 then nx, ny = vx / length, vy / length end
        color(projectile.color or {1, 0.75, 0.25, 1})
        lurek.render.setLineWidth(math.max(1, (projectile.radius or 2) * 0.7))
        lurek.render.line(projectile.x - nx * 18, projectile.y - ny * 18, projectile.x, projectile.y)
        lurek.render.circle("fill", projectile.x, projectile.y, math.max(2, projectile.radius or 2))
        lurek.render.setLineWidth(1)
    end
end

local function draw_effects(model)
    for _, smoke in ipairs(model.smoke) do
        lurek.render.setColor(0.28, 0.29, 0.30, 0.30)
        lurek.render.circle("fill", smoke.x, smoke.y, smoke.radius)
    end
    for _, hazard in ipairs(model.hazards or {}) do
        color(hazard.color or {1, 0.25, 0.05, 1}, 0.24)
        lurek.render.circle("fill", hazard.x, hazard.y, hazard.radius)
    end
    for _, field in ipairs(model.fields or {}) do
        color(field.color or {0.45, 0.15, 0.80, 1}, 0.20)
        lurek.render.circle("fill", field.x, field.y, field.radius)
        color(field.color, 0.8)
        circle_segments(field.x, field.y, field.radius, 30, true)
    end
    for _, effect in ipairs(model.effects) do
        local fade = math.min(1, math.max(0, effect.left * 4))
        color(effect.color, fade)
        if effect.kind == "beam" then
            lurek.render.setLineWidth(effect.width or 3)
            lurek.render.line(effect.x, effect.y, effect.x2, effect.y2)
            lurek.render.setLineWidth(1)
        else
            local radius = effect.radius or 3
            if effect.kind == "flame" then
                local age = 1 - effect.left / math.max(0.001, effect.duration or effect.left)
                radius = radius * (1 + age * 1.8)
            end
            lurek.render.circle("fill", effect.x, effect.y, radius)
        end
    end
    for _, explosion in ipairs(model.explosions) do
        local life = math.max(0, explosion.left / (explosion.duration or 0.36))
        local radius = explosion.radius * (1.05 - life * 0.75)
        color(explosion.color or {1, 0.32, 0.05, 1}, 0.16 + life * 0.42)
        lurek.render.circle("fill", explosion.x, explosion.y, radius * 0.64)
        lurek.render.setLineWidth(3)
        color({1, 0.72, 0.18, 1}, life)
        lurek.render.circle("line", explosion.x, explosion.y, radius)
        lurek.render.setLineWidth(1)
    end
end

function M.world(state)
    local battle = state.battle
    if not battle then return end
    local model, player = battle.model, battle.player
    state.modules.Camera.apply(model)
    local min_x, max_x, min_y, max_y = visible_bounds(model)

    draw_floor(state, model, player, min_x, max_x, min_y, max_y)
    draw_bases(state, model, player)
    draw_terrain(state, model, player, min_x, max_x, min_y, max_y)
    draw_effects(model)

    for _, actor in ipairs(model.actors) do
        if not actor.dead and (actor.team == player.team or state.modules.Awareness.can_see(state, player, actor)) then
            draw_mech(actor)
        end
    end
    draw_projectiles(model)

    if player and not player.dead then
        local sx, sy = lurek.input.mouse.getX(), lurek.input.mouse.getY()
        local mx, my = state.modules.Camera.to_world(model, sx, sy)
        lurek.render.setColor(1, 1, 1, 0.10)
        circle_segments(player.x, player.y - (player.z_offset or 0), player.build.left.range, 72, false)
        circle_segments(player.x, player.y - (player.z_offset or 0), player.build.right.range, 72, true)
        color(player.build.left.color or {1, 1, 1, 1}, 0.85)
        circle_segments(mx, my, spread_radius(player, 1), 40, false)
        color(player.build.right.color or {1, 1, 1, 1}, 0.85)
        circle_segments(mx, my, spread_radius(player, 2), 40, true)
        lurek.render.setColor(1, 1, 1, 1)
        lurek.render.line(mx - 8, my, mx + 8, my)
        lurek.render.line(mx, my - 8, mx, my + 8)
        lurek.render.circle("fill", mx, my, 2)
    end
    state.modules.Camera.reset(model)
end

local function bar(x, y, w, value, fill)
    lurek.render.setColor(0.12, 0.12, 0.13, 1)
    lurek.render.rectangle("fill", x, y, w, 12)
    color(fill)
    lurek.render.rectangle("fill", x, y, w * math.max(0, math.min(1, value)), 12)
end

function M.hud(state)
    local battle = state.battle
    if not battle then return end
    local player = battle.player
    local w, h = lurek.window.getWidth(), lurek.window.getHeight()

    -- Canvas-style vignette and compact DOM-like information panel.
    lurek.render.setColor(0, 0, 0, 0.38)
    lurek.render.rectangle("fill", 0, 0, w, 16)
    lurek.render.rectangle("fill", 0, h - 22, w, 22)
    lurek.render.rectangle("fill", 0, 0, 18, h)
    lurek.render.rectangle("fill", w - 18, 0, 18, h)
    lurek.render.setColor(0.02, 0.02, 0.025, 0.84)
    lurek.render.rectangle("fill", 16, 16, 292, 180)
    lurek.render.setColor(0.32, 0.32, 0.34, 1)
    lurek.render.rectangle("line", 16, 16, 292, 180)

    if player then
        lurek.render.setColor(0.30, 0.90, 0.48, 1)
        lurek.render.print("KLASA: " .. tostring((player.build.name or "MECH"):upper()), 31, 28)
        bar(31, 52, 220, player.hp / player.build.max_health, {0.94, 0.18, 0.16, 1})
        bar(31, 70, 220, player.energy / player.build.max_energy, {0.18, 0.48, 0.94, 1})
        lurek.render.setColor(0.82, 0.82, 0.84, 1)
        lurek.render.print(string.format("HP %03d/%03d   EN %03d/%03d", player.hp, player.build.max_health, player.energy, player.build.max_energy), 31, 90)
        lurek.render.print("STAN: " .. tostring((player.stance or "walk"):upper()), 31, 108)
        lurek.render.print("L: " .. tostring(player.build.left.name) .. "  [LMB]", 31, 126)
        lurek.render.print("R: " .. tostring(player.build.right.name) .. "  [RMB]", 31, 144)
        lurek.render.print(string.format("ROZRZUT L %03d  R %03d", spread_radius(player, 1), spread_radius(player, 2)), 31, 162)
    end
    lurek.render.setColor(0.88, 0.88, 0.90, 1)
    lurek.render.print(string.format("WYNIK %03d   WROGOWIE %03d   CZAS %03d", battle.score or 0, battle.enemies_left or 0, battle.elapsed or 0), w - 355, 24)
    local team_counts = {team1 = 0, team2 = 0, team3 = 0, team4 = 0}
    for _, actor in ipairs(battle.model.actors) do
        if not actor.dead and team_counts[actor.team] then team_counts[actor.team] = team_counts[actor.team] + 1 end
    end
    for i = 1, 4 do
        local team = "team" .. tostring(i)
        local x = 330 + (i - 1) * 105
        color(battle.model.team_colors[team])
        lurek.render.rectangle("fill", x, 22, 10, 10)
        lurek.render.setColor(0.82, 0.84, 0.86, 1)
        lurek.render.print(string.format("T%d %02d", i, team_counts[team]), x + 16, 22)
    end
    lurek.render.setColor(0.58, 0.58, 0.60, 1)
    lurek.render.print("WASD RUCH  SHIFT BIEG  CTRL SKRADANIE  ALT CELOWANIE  SPACE SKOK  F1-F12 MECH", 28, h - 18)
    lurek.render.setColor(1, 1, 1, 1)
    state.modules.Minimap.draw(state)
end

function M.center_text(text, y, _size)
    lurek.render.setFont(lurek.render.getDefaultFont(10))
    lurek.render.setColor(0.88, 0.94, 1, 1)
    lurek.render.printf(text, 0, y, lurek.window.getWidth(), "center")
    lurek.render.setColor(1, 1, 1, 1)
end

return M
