local M = {}

local function distance(a, b)
    local dx, dy = a.x - b.x, a.y - b.y
    return math.sqrt(dx * dx + dy * dy)
end

local function weapon_for(actor, slot)
    return slot == 2 and actor.build.right or actor.build.left
end

local function random_spread(model, radians)
    return model.rng and model.rng:randomFloat(-radians, radians) or 0
end

local function angle_distance(a, b)
    local delta = (a - b + math.pi) % (math.pi * 2) - math.pi
    return math.abs(delta)
end

local function slot_spread(actor, slot)
    actor.spread_slots = actor.spread_slots or {0, 0}
    return actor.spread_slots[slot] or 0
end

local function set_slot_spread(actor, slot, value)
    actor.spread_slots = actor.spread_slots or {0, 0}
    actor.spread_slots[slot] = value
end

function M.create(state, model)
    model.projectiles = model.projectiles or {}
    model.explosions = model.explosions or {}
    model.deployed = {}
    model.fields = {}
    model.portals = {}
    model.hazards = {}
    return model
end

function M.spawn_actor(state, team, build, x, y, id, is_player)
    local model = state.battle.model
    local actor = state.modules.Physics.spawn_actor(model, x, y, state.modules.Teams.is_player_side(model, team) and 15 or 13)
    actor.id, actor.team, actor.build, actor.is_player = id, team, build, is_player
    actor.hp, actor.energy = build.max_health, build.max_energy
    actor.shield_current, actor.max_shield = build.shield, build.shield
    actor.energy_regen_delay = 0
    actor.base_signature, actor.signature = build.signature, build.signature
    actor.cooldowns = {0, 0}
    actor.angle, actor.spread = 0, 0
    actor.hit_flash = 0
    actor.team_color = model.team_colors and model.team_colors[team] or {1, 1, 1, 1}
    actor.home_x, actor.home_y = x, y
    actor.max_spread_radius = tonumber(state.content.game.max_spread_radius) or 180
    actor.spread_slots = {actor.max_spread_radius * 0.65, actor.max_spread_radius * 0.65}
    actor.dead, actor.score_value = false, state.content.economy.kill_score or 5
    model.actors[#model.actors + 1] = actor
    model.body_to_actor[actor.body:getId()] = actor
    if not is_player then state.modules.AI.register(state, actor) end
    return actor
end

local function damage(state, source, target, amount)
    if target.dead then return end
    local mitigation = math.max(0.1, 1 - (target.armor_reduction or 0))
    local shield_damage = math.min(target.shield_current or 0, amount * 0.25)
    target.shield_current = math.max(0, (target.shield_current or 0) - shield_damage)
    target.hp = target.hp - math.max(0, amount * mitigation - shield_damage)
    target.hit_flash = 0.08
    if target.hp <= 0 then
        target.dead = true
        state.modules.Physics.destroy(state.battle.model, target)
        if source and state.modules.Teams.is_player_side(state.battle.model, source.team) then state.battle.score = state.battle.score + (target.score_value or 5) end
        state.modules.Effects.explosion(state, target.x, target.y, 54, target.team_color)
    end
end

function M.explode(state, source, x, y, radius, amount, weapon)
    local model = state.battle.model
    if weapon and weapon.smoke then
        state.modules.Effects.smoke(state, x, y, weapon.smoke_radius or radius, weapon.duration or 10)
        return
    end
    for _, target in ipairs(model.actors) do
        if not target.dead and state.modules.Teams.is_enemy(model, source.team, target.team) and distance(target, {x = x, y = y}) <= radius then
            damage(state, source, target, amount)
            if weapon and weapon.emp_duration then target.status_emp = math.max(target.status_emp or 0, weapon.emp_duration) end
            if weapon and weapon.armor_reduction then target.armor_reduction = math.max(target.armor_reduction or 0, weapon.armor_reduction) end
        end
    end
    if weapon and weapon.submunitions then
        for i = 1, weapon.submunitions do
            local angle = (i / weapon.submunitions) * math.pi * 2
            local sx, sy = x + math.cos(angle) * radius * 0.35, y + math.sin(angle) * radius * 0.35
            for _, target in ipairs(model.actors) do
                if not target.dead and state.modules.Teams.is_enemy(model, source.team, target.team) and distance(target, {x = sx, y = sy}) <= radius * 0.35 then damage(state, source, target, amount * 0.35) end
            end
        end
    end
    if weapon and weapon.hazard_duration then
        model.hazards[#model.hazards + 1] = {
            x = x, y = y, radius = radius * 0.7, left = weapon.hazard_duration,
            damage = amount * 0.18, team = source.team, owner = source, color = weapon.color,
            sprite_image = state.content.effects.hazard.sprite_image,
        }
    end
    state.modules.Effects.explosion(state, x, y, radius)
end

local function hit_beam(state, actor, weapon, x, y, target_x, target_y)
    local dx, dy = target_x - x, target_y - y
    local length = math.sqrt(dx * dx + dy * dy)
    if length < 0.01 then return end
    dx, dy = dx / length, dy / length
    local trace = state.modules.Physics.beam(state.battle.model, x, y, dx, dy, weapon.range)
    local best, best_d = nil, weapon.range
    for _, target in ipairs(state.battle.model.actors) do
        if not target.dead and state.modules.Teams.is_enemy(state.battle.model, actor.team, target.team) then
            local tx, ty = target.x - x, target.y - y
            local along = tx * dx + ty * dy
            local side = math.abs(tx * dy - ty * dx)
            if along > 0 and along < best_d and side < target.radius + 10 and state.modules.Awareness.can_see(state, actor, target) then
                best, best_d = target, along
            end
        end
    end
    if trace and trace.distance then best_d = math.min(best_d, trace.distance) end
    if best then
        damage(state, actor, best, weapon.damage)
        if weapon.stun then best.status_stun = math.max(best.status_stun or 0, weapon.stun) end
        if weapon.emp_duration then best.status_emp = math.max(best.status_emp or 0, weapon.emp_duration) end
    end
    state.modules.Effects.beam(state, x, y, x + dx * best_d, y + dy * best_d, weapon.color, math.max(2, weapon.size or 2))
    state.modules.Lighting.flash(state, x, y, weapon.color)
    state.modules.Effects.burst(state, x + dx * math.min(best_d, 120), y + dy * math.min(best_d, 120), weapon.color, 3, 0.18)
end

function M.fire(state, actor, target_x, target_y, slot)
    if actor.dead or (actor.status_stun or 0) > 0 or (actor.status_emp or 0) > 0 then return false end
    local model = state.battle.model
    local weapon = weapon_for(actor, slot or 1)
    local index = slot or 1
    if actor.cooldowns[index] > 0 or actor.energy < weapon.energy then return false end
    actor.energy = actor.energy - weapon.energy
    actor.energy_regen_delay = state.content.game.energy_regen_delay or 1.0
    actor.cooldowns[index] = weapon.reload
    local dist_to_target = math.max(10, math.sqrt((target_x - actor.x) ^ 2 + (target_y - actor.y) ^ 2))
    local spread_radius = slot_spread(actor, index)
    local spread_angle = math.atan2(spread_radius, dist_to_target)
    local aim_angle = math.atan2(target_y - actor.y, target_x - actor.x)
    local angle = aim_angle + random_spread(model, spread_angle)
    local side_sign = index == 1 and -1 or 1
    local muzzle_x = actor.x + math.cos(aim_angle) * (actor.radius + 8) + math.cos(aim_angle + math.pi * 0.5) * (15 * side_sign)
    local muzzle_y = actor.y + math.sin(aim_angle) * (actor.radius + 8) + math.sin(aim_angle + math.pi * 0.5) * (15 * side_sign)
    set_slot_spread(actor, index, math.min(actor.max_spread_radius or 180, spread_radius + (tonumber(weapon.recoil) or 40)))
    actor.spread = (slot_spread(actor, 1) + slot_spread(actor, 2)) * 0.5
    state.modules.AI.emit(state, "gunfire", muzzle_x, muzzle_y, 1)
    if weapon.kind == "beam" then
        hit_beam(state, actor, weapon, muzzle_x, muzzle_y, target_x, target_y)
    elseif weapon.kind == "cone" then
        for _, target in ipairs(model.actors) do
            if not target.dead and state.modules.Teams.is_enemy(model, actor.team, target.team) then
                local dx, dy = target.x - actor.x, target.y - actor.y
                local d = math.sqrt(dx * dx + dy * dy)
                local delta = angle_distance(math.atan2(dy, dx), aim_angle)
                local clear = state.modules.Awareness.has_line_of_sight(state, actor, target)
                if d < weapon.range and delta < (weapon.arc or weapon.accuracy or 20) * math.pi / 180 and clear then
                    if weapon.armor_reduction then target.armor_reduction = math.max(target.armor_reduction or 0, weapon.armor_reduction) end
                    damage(state, actor, target, weapon.damage)
                end
            end
        end
        state.modules.Effects.flame(state, muzzle_x, muzzle_y, aim_angle, weapon)
    elseif weapon.kind == "support" then
        local target = actor
        local best_distance = weapon.range
        for _, candidate in ipairs(model.actors) do
            if not candidate.dead and state.modules.Teams.is_ally(model, candidate.team, actor.team) then
                local d = distance(candidate, {x = target_x, y = target_y})
                if d < best_distance then target, best_distance = candidate, d end
            end
        end
        if weapon.support == "repair" then target.hp = math.min(target.build.max_health, target.hp + (weapon.repair or weapon.damage or 0)) end
        if weapon.support == "shield" then target.shield_current = math.min(target.max_shield + (weapon.shield or 0), (target.shield_current or 0) + (weapon.shield or 0)) end
        if weapon.support == "energy" then target.energy = math.min(target.build.max_energy, target.energy + (weapon.transfer or 0)) end
        if weapon.support == "repair_drone" or weapon.support == "assault_drone" or weapon.support == "shield_drone" then
            local active = 0
            for _, device in ipairs(model.deployed) do if device.kind == weapon.support and device.owner == actor then active = active + 1 end end
            if active >= (weapon.max_deployables or 3) then
                for i = 1, #model.deployed do
                    if model.deployed[i].kind == weapon.support and model.deployed[i].owner == actor then table.remove(model.deployed, i); break end
                end
            end
            model.deployed[#model.deployed + 1] = {kind = weapon.support, x = target.x, y = target.y, team = actor.team, owner = actor, left = weapon.duration or 30, damage = weapon.damage, radius = 28, cooldown = 0}
        end
        state.modules.Effects.burst(state, target.x, target.y, weapon.color, 8, 0.3)
    elseif weapon.kind == "field" then
        model.fields[#model.fields + 1] = {
            field = weapon.field, x = target_x, y = target_y, team = actor.team, owner = actor,
            left = weapon.duration or 2, radius = weapon.explode_radius or weapon.range * 0.35,
            damage = weapon.damage, color = weapon.color, sprite_image = state.content.effects.field.sprite_image,
        }
        state.modules.Effects.explosion(state, target_x, target_y, weapon.explode_radius or 50, weapon.color, weapon.impact_image)
    elseif weapon.kind == "deployable" then
        local count = 0
        for i = #model.deployed, 1, -1 do
            if model.deployed[i].owner == actor and model.deployed[i].deployable == weapon.deployable then count = count + 1 end
        end
        if count >= (weapon.max_deployables or 3) then
            for i = 1, #model.deployed do
                if model.deployed[i].owner == actor and model.deployed[i].deployable == weapon.deployable then table.remove(model.deployed, i); break end
            end
        end
        if weapon.deployable == "smoke" then
            state.modules.Effects.smoke(state, target_x, target_y, weapon.explode_radius or 100, weapon.duration or 12)
        else
            model.deployed[#model.deployed + 1] = {deployable = weapon.deployable, x = target_x, y = target_y, team = actor.team, owner = actor, left = weapon.duration or 300, damage = weapon.damage, radius = weapon.explode_radius or 90, cooldown = 0, color = weapon.color}
            state.modules.Effects.explosion(state, target_x, target_y, 20, weapon.color, weapon.impact_image)
        end
    elseif weapon.kind == "portal" then
        model.portals = model.portals or {}
        if #model.portals >= (weapon.max_deployables or 2) then table.remove(model.portals, 1) end
        model.portals[#model.portals + 1] = {x = target_x, y = target_y, team = actor.team, owner = actor, left = weapon.duration or 600, radius = 24, color = weapon.color}
    else
        local pellets = math.max(1, weapon.pellets or 1)
        for i = 1, pellets do
            local explosive = weapon.explosive or weapon.kind == "ballistic"
            local shot_angle = explosive and aim_angle or aim_angle + random_spread(model, spread_angle)
            local projectile = state.modules.Physics.spawn_projectile(model, muzzle_x, muzzle_y, math.cos(shot_angle) * weapon.velocity, math.sin(shot_angle) * weapon.velocity, weapon.kind == "ballistic" and 7 or 4)
            projectile.owner, projectile.damage, projectile.velocity, projectile.weapon = actor, weapon.damage, weapon.velocity, weapon
            projectile.sprite_image = weapon.projectile_image
            projectile.vx, projectile.vy = math.cos(shot_angle) * weapon.velocity, math.sin(shot_angle) * weapon.velocity
            projectile.left, projectile.max_range = weapon.range / math.max(1, weapon.velocity) + 0.25, weapon.range
            projectile.travel, projectile.explosive = 0, explosive
            projectile.explode_radius, projectile.color = weapon.explode_radius or 80, weapon.color
            if explosive then
                local dx, dy = target_x - muzzle_x, target_y - muzzle_y
                local target_distance = math.sqrt(dx * dx + dy * dy)
                if target_distance > weapon.range then
                    local scale = weapon.range / math.max(0.001, target_distance)
                    dx, dy, target_distance = dx * scale, dy * scale, weapon.range
                end
                projectile.target_x, projectile.target_y = muzzle_x + dx, muzzle_y + dy
                projectile.target_distance = target_distance
            end
            model.projectiles[#model.projectiles + 1] = projectile
        end
        state.modules.Lighting.flash(state, muzzle_x, muzzle_y, weapon.color)
        state.modules.Effects.burst(state, muzzle_x, muzzle_y, weapon.color, 3, 0.16)
    end
    return true
end

function M.update(state, dt)
    local battle = state.battle
    if not battle then return end
    local model = battle.model
    for _, actor in ipairs(model.actors) do
        actor.cooldowns[1] = math.max(0, actor.cooldowns[1] - dt)
        actor.cooldowns[2] = math.max(0, actor.cooldowns[2] - dt)
        actor.hit_flash = math.max(0, (actor.hit_flash or 0) - dt)
    end
    for i = #model.projectiles, 1, -1 do
        local projectile = model.projectiles[i]
        projectile.left = projectile.left - dt
        projectile.travel = projectile.travel + (projectile.velocity or 0) * dt
        if projectile.body then projectile.x, projectile.y = projectile.body:getPosition() end
        local impact
        if not projectile.explosive and model.world.is_blocked(model, projectile.x, projectile.y) then
            state.modules.Physics.destroy(model, projectile)
            table.remove(model.projectiles, i)
            impact = true
        end
        for _, target in ipairs(model.actors) do
            if not projectile.explosive and not impact and not target.dead and target ~= projectile.owner and state.modules.Teams.is_enemy(model, projectile.owner.team, target.team) and distance(target, projectile) < target.radius + projectile.radius then impact = target; break end
        end
        if impact and impact ~= true then
            if projectile.explosive then M.explode(state, projectile.owner, projectile.x, projectile.y, projectile.explode_radius, projectile.damage, projectile.weapon) else damage(state, projectile.owner, impact, projectile.damage) end
            state.modules.Physics.destroy(model, projectile)
            table.remove(model.projectiles, i)
        elseif projectile.explosive and projectile.travel >= (projectile.target_distance or projectile.max_range) then
            local x, y = projectile.target_x or projectile.x, projectile.target_y or projectile.y
            M.explode(state, projectile.owner, x, y, projectile.explode_radius, projectile.damage, projectile.weapon)
            state.modules.Physics.destroy(model, projectile)
            table.remove(model.projectiles, i)
        elseif projectile.left <= 0 or projectile.travel > projectile.max_range then
            state.modules.Physics.destroy(model, projectile)
            table.remove(model.projectiles, i)
        end
    end
    model.fields = model.fields or {}
    model.hazards = model.hazards or {}
    for i = #model.hazards, 1, -1 do
        local hazard = model.hazards[i]
        hazard.left = hazard.left - dt
        for _, target in ipairs(model.actors) do
            if not target.dead and state.modules.Teams.is_enemy(model, hazard.team, target.team) and distance(target, hazard) < hazard.radius then damage(state, hazard.owner or {team = hazard.team}, target, hazard.damage * dt) end
        end
        if hazard.left <= 0 then table.remove(model.hazards, i) end
    end
    for i = #model.fields, 1, -1 do
        local field = model.fields[i]
        field.left = field.left - dt
        for _, target in ipairs(model.actors) do
            if not target.dead and state.modules.Teams.is_enemy(model, field.team, target.team) and distance(target, field) < field.radius then
                local dx, dy = field.x - target.x, field.y - target.y
                local length = math.max(1, math.sqrt(dx * dx + dy * dy))
                local force = field.field == "push" and -1 or 1
                if field.field == "stasis" then target.status_stun = math.max(target.status_stun or 0, dt * 1.5) else state.modules.Physics.velocity(target, dx / length * 80 * force, dy / length * 80 * force); damage(state, field.owner, target, (field.damage or 0) * dt) end
            end
        end
        if field.left <= 0 then table.remove(model.fields, i) end
    end
    for _, actor in ipairs(model.actors) do actor.portal_cooldown = math.max(0, (actor.portal_cooldown or 0) - dt) end
    for i = #model.portals, 1, -1 do
        local portal = model.portals[i]
        portal.left = portal.left - dt
        if portal.left <= 0 then table.remove(model.portals, i) end
    end
    for i = #model.deployed, 1, -1 do
        local device = model.deployed[i]
        device.left = device.left - dt
        device.cooldown = math.max(0, (device.cooldown or 0) - dt)
        for _, target in ipairs(model.actors) do
            if not target.dead and distance(target, device) < device.radius then
                if device.kind == "repair_drone" and state.modules.Teams.is_ally(model, target.team, device.team) and device.cooldown <= 0 then
                    target.hp = math.min(target.build.max_health, target.hp + (device.damage or 12))
                    device.cooldown = 0.8
                elseif device.kind == "shield_drone" and state.modules.Teams.is_ally(model, target.team, device.team) and device.cooldown <= 0 then
                    target.shield_current = math.min(target.max_shield + 40, (target.shield_current or 0) + 8)
                    device.cooldown = 0.8
                elseif device.kind == "assault_drone" and state.modules.Teams.is_enemy(model, device.team, target.team) and device.cooldown <= 0 then
                    damage(state, device.owner, target, device.damage or 10)
                    device.cooldown = 0.6
                elseif state.modules.Teams.is_enemy(model, device.team, target.team) and (device.deployable == "mine" or device.deployable == "emp_mine" or device.deployable == "fire_mine") then
                    M.explode(state, device.owner, device.x, device.y, device.radius, device.damage)
                    if device.deployable == "emp_mine" then target.status_emp = 3 end
                    device.left = 0
                elseif state.modules.Teams.is_enemy(model, device.team, target.team) and (device.deployable == "sentry" or device.deployable == "missile_turret" or device.deployable == "beam_turret") then
                    if device.cooldown <= 0 then damage(state, device.owner, target, device.damage); device.cooldown = 0.6 end
                end
            end
        end
        if device.left <= 0 then table.remove(model.deployed, i) end
    end
    for _, portal in ipairs(model.portals) do
        for _, actor in ipairs(model.actors) do
            if not actor.dead and actor.portal_cooldown <= 0 and state.modules.Teams.is_ally(model, actor.team, portal.team) and distance(actor, portal) < portal.radius and #model.portals >= 2 then
                local destination = model.portals[1] == portal and model.portals[2] or model.portals[1]
                state.modules.Physics.set_position(actor, destination.x, destination.y)
                actor.portal_cooldown = 0.6
            end
        end
    end
    for i = #model.explosions, 1, -1 do
        model.explosions[i].left = model.explosions[i].left - dt
        if model.explosions[i].left <= 0 then table.remove(model.explosions, i) end
    end
end

function M.player_fire(state, actor, mouse_x, mouse_y)
    if lurek.input.mouse.isDown(1) then M.fire(state, actor, mouse_x, mouse_y, 1) end
    if lurek.input.mouse.isDown(2) then M.fire(state, actor, mouse_x, mouse_y, 2) end
end

return M
