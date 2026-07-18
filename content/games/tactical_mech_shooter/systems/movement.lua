local M = {}

local function action(name)
    return lurek.input.isActionDown(name)
end

local function clamp(value, low, high)
    if value < low then return low end
    if value > high then return high end
    return value
end

local function wrap_angle(value)
    while value > math.pi do value = value - math.pi * 2 end
    while value < -math.pi do value = value + math.pi * 2 end
    return value
end

local function spread_radius(weapon, distance)
    local accuracy = math.rad(tonumber(weapon and weapon.accuracy) or 0)
    return math.tan(accuracy) * distance
end

function M.bind()
    lurek.input.bind("move_left", {"a", "left"})
    lurek.input.bind("move_right", {"d", "right"})
    lurek.input.bind("move_up", {"w", "up"})
    lurek.input.bind("move_down", {"s", "down"})
    lurek.input.bind("run", {"shift"})
    lurek.input.bind("sneak", {"ctrl"})
    lurek.input.bind("aim", {"alt"})
    lurek.input.bind("jump", {"space"})
    -- `return` is the engine's canonical Enter key; keep space/click as
    -- discoverable fallbacks so the title screen is usable on every layout.
    lurek.input.bind("confirm", {"return", "enter", "space", "mouse1"})
    -- Escape is reserved by the engine as a global quit key; P is the
    -- in-game pause/return action.
    lurek.input.bind("pause", {"p"})
    lurek.input.bind("restart", {"r"})
    lurek.input.bind("switch", {"tab"})
    for i = 1, 12 do lurek.input.bind("preset_" .. tostring(i), {"f" .. tostring(i)}) end
end

-- Some window backends deliver a key transition between two frame ticks. Keep
-- a local edge detector in addition to the transient engine helper so menu
-- actions remain reliable when the key is held for only one rendered frame.
function M.pressed(state, name)
    state.input_edges = state.input_edges or {}
    local held = action(name)
    local was_held = state.input_edges[name] == true
    state.input_edges[name] = held
    local api_pressed = lurek.input.wasActionPressed(name)
    return api_pressed or (held and not was_held)
end

function M.update(state, actor, dt, mouse_x, mouse_y)
    if actor.dead then return end
    local model = state.battle.model
    local tuning = state.content.movement or {}
    local stunned = (actor.status_stun or 0) > 0 or (actor.status_emp or 0) > 0
    actor.spread_slots = actor.spread_slots or {actor.max_spread_radius or 180, actor.max_spread_radius or 180}
    local was_jumping = (actor.jump_timer or 0) > 0
    local old_x, old_y = actor.x, actor.y
    actor.jump_cooldown = math.max(0, (actor.jump_cooldown or 0) - dt)
    actor.jump_timer = math.max(0, (actor.jump_timer or 0) - dt)
    if not stunned and M.pressed(state, "jump") and actor.jump_timer <= 0 and actor.jump_cooldown <= 0 and actor.energy >= (tuning.jump_energy or 25) then
        actor.energy = actor.energy - (tuning.jump_energy or 25)
        actor.energy_regen_delay = tuning.energy_regen_delay or 1.0
        actor.jump_timer = tuning.jump_duration or 0.8
        actor.jump_cooldown = tuning.jump_cooldown or 1.0
        actor.jump_started = tuning.jump_duration or 0.8
        pcall(actor.body.setAltitudeMode, actor.body, "ballistic")
        pcall(actor.body.setVerticalVelocity, actor.body, actor.build.jump_power * 0.1)
        pcall(actor.body.setVerticalGravity, actor.body, actor.build.jump_gravity * 0.1)
    end
    local jumping = actor.jump_timer > 0
    if was_jumping and not jumping then
        pcall(actor.body.setAltitudeMode, actor.body, "ground")
        pcall(actor.body.setAltitude, actor.body, 0)
    end
    actor.z_offset = 0
    if jumping then
        local duration = math.max(0.01, actor.jump_started or tuning.jump_duration or 0.8)
        local progress = 1 - actor.jump_timer / duration
        actor.z_offset = math.sin(clamp(progress, 0, 1) * math.pi) * (actor.build.jump_power * duration * 0.08)
    end
    local x = stunned and 0 or ((action("move_right") and 1 or 0) - (action("move_left") and 1 or 0))
    local y = stunned and 0 or ((action("move_down") and 1 or 0) - (action("move_up") and 1 or 0))
    local length = math.sqrt(x * x + y * y)
    if length > 0 then x, y = x / length, y / length end
    local stance = jumping and "jump" or "walk"
    if not jumping and action("run") and actor.energy > 0 then stance = "run" elseif not jumping and action("sneak") then stance = "sneak" elseif not jumping and action("aim") then stance = "aim" end
    local speed = actor.build.move_speed
    speed = speed * model.world.move_multiplier(model, actor.x, actor.y)
    if stance == "run" then speed = speed * (tuning.run_multiplier or 1.5); actor.energy = math.max(0, actor.energy - dt * (tuning.run_energy_per_second or 15)); actor.energy_regen_delay = tuning.energy_regen_delay or 1.0
    elseif stance == "sneak" then speed = speed * (tuning.sneak_multiplier or 0.5); actor.signature = actor.base_signature * 0.55
    elseif stance == "aim" then speed = 0 end
    if stance == "jump" then speed = speed * (tuning.jump_multiplier or 1.2) end
    if stance ~= "sneak" then actor.signature = actor.base_signature end
    local nx, ny = actor.x + x * speed * dt, actor.y + y * speed * dt
    if jumping or not model.world.is_blocked(model, nx, actor.y) then actor.x = nx end
    if jumping or not model.world.is_blocked(model, actor.x, ny) then actor.y = ny end
    state.modules.Physics.set_position(actor, actor.x, actor.y)
    local moved = math.sqrt((actor.x - old_x) ^ 2 + (actor.y - old_y) ^ 2)
    actor.energy_regen_delay = math.max(0, (actor.energy_regen_delay or 0) - dt)
    if actor.energy_regen_delay <= 0 then
        local regen = math.max(0, actor.build.energy_regen - (actor.build.energy_regen_penalty or 0))
        actor.energy = math.min(actor.build.max_energy, actor.energy + regen * dt)
    end
    actor.status_stun = math.max(0, (actor.status_stun or 0) - dt)
    actor.status_emp = math.max(0, (actor.status_emp or 0) - dt)
    actor.hp = math.min(actor.build.max_health, actor.hp + actor.build.health_regen * dt)
    if mouse_x and mouse_y then
        local target_angle = math.atan2(mouse_y - actor.y, mouse_x - actor.x)
        local delta = wrap_angle(target_angle - actor.angle)
        -- Player weapons and chassis track the cursor exactly. Spread models
        -- accuracy; rotation lag must not redirect shots away from the cursor.
        actor.angle = target_angle
        actor.target_angle = target_angle
        actor.aim_error = math.abs(delta)
        if actor.last_target_angle and math.abs(wrap_angle(target_angle - actor.last_target_angle)) > 0.035 then actor.aim_progress = 0 end
        actor.last_target_angle = target_angle
        local max_spread = actor.max_spread_radius or 180
        if moved > 0.05 then
            local move_penalty = jumping and 100 or 30
            actor.spread_slots[1] = math.min(max_spread, actor.spread_slots[1] + move_penalty * dt)
            actor.spread_slots[2] = math.min(max_spread, actor.spread_slots[2] + move_penalty * dt)
        end
        if actor.last_mouse_world_x then
            local cursor_motion = math.sqrt((mouse_x - actor.last_mouse_world_x) ^ 2 + (mouse_y - actor.last_mouse_world_y) ^ 2)
            if cursor_motion > 0 then
                local mouse_penalty = math.min(48, cursor_motion * 0.08)
                actor.spread_slots[1] = math.min(max_spread, actor.spread_slots[1] + mouse_penalty)
                actor.spread_slots[2] = math.min(max_spread, actor.spread_slots[2] + mouse_penalty)
            end
        end
        actor.last_mouse_world_x, actor.last_mouse_world_y = mouse_x, mouse_y
        local dist = math.max(10, math.sqrt((mouse_x - actor.x) ^ 2 + (mouse_y - actor.y) ^ 2))
        local aim_mult = actor.build.aim_multiplier or 1
        local left_min = spread_radius(actor.build.left, dist)
        local right_min = spread_radius(actor.build.right, dist)
        local left_shrink = (max_spread / math.max(0.05, actor.build.left.aim_time or 0.2)) * aim_mult * (stance == "aim" and 1 or 0.55)
        local right_shrink = (max_spread / math.max(0.05, actor.build.right.aim_time or 0.2)) * aim_mult * (stance == "aim" and 1 or 0.55)
        actor.spread_slots[1] = clamp(actor.spread_slots[1] - left_shrink * dt, left_min, max_spread)
        actor.spread_slots[2] = clamp(actor.spread_slots[2] - right_shrink * dt, right_min, max_spread)
    end
    local aim_time = math.min(actor.build.left.aim_time or 0.2, actor.build.right.aim_time or 0.2)
    if stance == "aim" then actor.aim_progress = clamp((actor.aim_progress or 0) + dt / math.max(0.05, aim_time), 0, 1) else actor.aim_progress = clamp((actor.aim_progress or 0) - dt * 0.6, 0, 1) end
    actor.spread = ((actor.spread_slots[1] or 0) + (actor.spread_slots[2] or 0)) * 0.5
    actor.stance = stance
end

return M
