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

local function draw_objectives(state, model, viewer)
    for _, objective in ipairs(model.objectives or {}) do
        local cx, cy = model.world.cell(model, objective.x, objective.y)
        local visible, explored = state.modules.Awareness.tile_state(state, viewer.team, cx, cy)
        if visible or explored then
            local color_value = objective.kind == "flag" and {0.92, 0.96, 1.00, 1} or {1.00, 0.72, 0.18, 1}
            color(color_value, visible and 0.95 or 0.38)
            lurek.render.setLineWidth(3)
            circle_segments(objective.x, objective.y, 26, 32, true)
            lurek.render.setLineWidth(1)
            lurek.render.rectangle("fill", objective.x - 3, objective.y - 18, 6, 36)
            lurek.render.polygon("fill",
                objective.x, objective.y - 18,
                objective.x + 22, objective.y - 10,
                objective.x, objective.y - 2
            )
        end
    end
end

local function draw_weapon(state, weapon, side)
    local scale = 0.30 + (tonumber(weapon.size) or 2) * 0.055
    local center_x = -4 + 48 * scale
    state.modules.Assets.draw_centered(weapon.sprite_image, center_x, side * 22, 0, scale, scale)
end

local function draw_mech(state, model, actor)
    local radius = actor.radius
    local jump = actor.z_offset or 0
    local draw_y = actor.y - jump

    lurek.render.push()
    lurek.render.translate(actor.x, draw_y)
    lurek.render.rotate(actor.angle)

    if actor.build.backpack_id ~= "none" then
        local pack_scale = 0.45 + (tonumber(actor.build.backpack.size) or 3) * 0.035
        state.modules.Assets.draw_centered(actor.build.backpack.sprite_image, -radius - 10, 0, 0, pack_scale, pack_scale)
    end

    draw_weapon(state, actor.build.left, -1)
    draw_weapon(state, actor.build.right, 1)
    state.modules.Assets.draw_centered(actor.build.corpus.sprite_image, 0, 0, 0, radius / 48, radius / 48)
    lurek.render.pop()

    if state.modules.Teams.is_enemy(model, "team1", actor.team) then
        lurek.render.setColor(0.08, 0.02, 0.02, 0.8)
        lurek.render.rectangle("fill", actor.x - radius, draw_y - radius - 9, radius * 2, 4)
        lurek.render.setColor(0.95, 0.14, 0.10, 1)
        lurek.render.rectangle("fill", actor.x - radius, draw_y - radius - 9, radius * 2 * math.max(0, actor.hp / actor.build.max_health), 4)
    end
end

local function draw_projectiles(state, model)
    for _, projectile in ipairs(model.projectiles) do
        local vx, vy = projectile.vx or 0, projectile.vy or 0
        local length = math.sqrt((vx or 0) ^ 2 + (vy or 0) ^ 2)
        local nx, ny = 0, 0
        if length > 0 then nx, ny = vx / length, vy / length end
        local angle = math.atan2(ny, nx)
        local scale = math.max(0.35, (projectile.radius or 4) / 5)
        state.modules.Assets.draw_centered(projectile.sprite_image, projectile.x, projectile.y, angle, scale, scale, projectile.color)
    end
end

local function draw_effects(state, model)
    for _, smoke in ipairs(model.smoke) do
        local scale = (smoke.radius or 48) / 48
        state.modules.Assets.draw_centered(smoke.sprite_image, smoke.x, smoke.y, 0, scale, scale, nil, 0.72)
    end
    for _, hazard in ipairs(model.hazards or {}) do
        local scale = (hazard.radius or 48) / 48
        state.modules.Assets.draw_centered(hazard.sprite_image, hazard.x, hazard.y, 0, scale, scale, hazard.color, 0.82)
    end
    for _, field in ipairs(model.fields or {}) do
        local scale = (field.radius or 48) / 48
        state.modules.Assets.draw_centered(field.sprite_image, field.x, field.y, 0, scale, scale, field.color, 0.78)
    end
    for _, effect in ipairs(model.effects) do
        local fade = math.min(1, math.max(0, effect.left * 4))
        if effect.kind == "beam" then
            local dx, dy = effect.x2 - effect.x, effect.y2 - effect.y
            local length = math.max(1, math.sqrt(dx * dx + dy * dy))
            state.modules.Assets.draw_centered(effect.sprite_image, (effect.x + effect.x2) * 0.5, (effect.y + effect.y2) * 0.5,
                math.atan2(dy, dx), length / 128, math.max(0.25, (effect.width or 3) / 6), effect.color, fade)
        else
            local scale = math.max(0.18, (effect.radius or 6) / 12)
            local angle = effect.angle or math.atan2(effect.vy or 0, effect.vx or 1)
            state.modules.Assets.draw_centered(effect.sprite_image, effect.x, effect.y, angle, scale, scale, effect.color, fade)
        end
    end
    for _, explosion in ipairs(model.explosions) do
        local life = math.max(0, explosion.left / (explosion.duration or 0.36))
        local radius = explosion.radius * (1.05 - life * 0.75)
        state.modules.Assets.draw_centered(explosion.sprite_image, explosion.x, explosion.y, 0, radius / 64, radius / 64, explosion.color, 0.20 + life * 0.65)
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
    draw_objectives(state, model, player)
    draw_terrain(state, model, player, min_x, max_x, min_y, max_y)
    draw_effects(state, model)

    for _, actor in ipairs(model.actors) do
        if not actor.dead and (state.modules.Teams.is_ally(model, player.team, actor.team) or state.modules.Awareness.can_see(state, player, actor)) then
            draw_mech(state, model, actor)
        end
    end
    draw_projectiles(state, model)

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
    local active_map = battle.model.active_map or {}
    lurek.render.print(string.format("%s // %s", tostring(active_map.name or "MAP"), tostring(active_map.mode or "elimination"):upper()), w - 430, 24)
    lurek.render.print(string.format("WYNIK %03d   WROGOWIE %03d   CZAS %03d", battle.score or 0, battle.enemies_left or 0, battle.elapsed or 0), w - 355, 42)
    local objective = active_map.objective or {}
    local objective_text = objective.kind == "destroy_base" and ("CEL: ZNISZCZ BAZE T" .. tostring(objective.target_team or 2))
        or objective.kind == "capture_flag" and ("CEL: PRZEJMIJ FLAGE " .. tostring(objective.capture_limit or 3) .. "x")
        or "CEL: ELIMINACJA"
    lurek.render.setColor(0.98, 0.78, 0.25, 1)
    lurek.render.print(objective_text, w - 355, 60)
    local team_counts = {}
    local team_count = state.modules.Teams.team_count(battle.model)
    for i = 1, team_count do team_counts["team" .. tostring(i)] = 0 end
    for _, actor in ipairs(battle.model.actors) do
        if not actor.dead and team_counts[actor.team] then team_counts[actor.team] = team_counts[actor.team] + 1 end
    end
    for i = 1, team_count do
        local team = "team" .. tostring(i)
        local x = 330 + (i - 1) * math.min(105, (w - 350) / math.max(1, team_count))
        color(battle.model.team_colors[team])
        lurek.render.rectangle("fill", x, 82, 10, 10)
        lurek.render.setColor(0.82, 0.84, 0.86, 1)
        lurek.render.print(string.format("T%d %02d", i, team_counts[team]), x + 16, 82)
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
