local M = {}

local function distance(a, b)
    local dx, dy = a.x - b.x, a.y - b.y
    return math.sqrt(dx * dx + dy * dy)
end

local function nearest_visible(state, actor)
    local best, best_distance
    for _, other in ipairs(state.battle.model.actors) do
        if other ~= actor and not other.dead and state.modules.Teams.is_enemy(state.battle.model, actor.team, other.team) then
            local d = distance(actor, other)
            if (not best_distance or d < best_distance) and state.modules.Awareness.can_see(state, actor, other) then
                best, best_distance = other, d
            end
        end
    end
    return best, best_distance
end

function M.create(state, model)
    assert(lurek.ai and lurek.ai.newWorld, "required API missing: lurek.ai.newWorld")
    assert(lurek.ai.newStimulusWorld, "required API missing: lurek.ai.newStimulusWorld")
    model.ai_world = assert(lurek.ai.newWorld(), "failed to create AI world")
    model.stimuli = assert(lurek.ai.newStimulusWorld(), "failed to create stimulus world")
    return model
end

function M.register(state, actor)
    local model = state.battle.model
    if not model.ai_world then return end
    local ok, agent = pcall(model.ai_world.addAgent, model.ai_world, "agent_" .. tostring(actor.id))
    if ok and agent then
        actor.ai_agent = agent
        pcall(agent.setPosition, agent, actor.x, actor.y)
        pcall(agent.setTeam, agent, actor.team)
    end
end

local function move_towards(state, actor, target, dt)
    local model = state.battle.model
    local target_x, target_y = state.modules.Navigation.next_waypoint(model, actor, target.x, target.y)
    local dx, dy = target_x - actor.x, target_y - actor.y
    local length = math.sqrt(dx * dx + dy * dy)
    if length < 0.001 then return end
    local speed = actor.build.move_speed * 0.55
    actor.pref_vx, actor.pref_vy = dx / length * speed, dy / length * speed
    local move_vx = actor.safe_vx or actor.pref_vx
    local move_vy = actor.safe_vy or actor.pref_vy
    local nx = actor.x + move_vx * dt
    local ny = actor.y + move_vy * dt
    if not state.modules.World.is_blocked(model, nx, actor.y) then actor.x = nx end
    if not state.modules.World.is_blocked(model, actor.x, ny) then actor.y = ny end
    state.modules.Physics.set_position(actor, actor.x, actor.y)
end

function M.update(state, dt)
    local battle = state.battle
    if not battle then return end
    local model = battle.model
    model.ai_frame = (model.ai_frame or 0) + 1
    for _, actor in ipairs(model.actors) do
        if not actor.is_player and not actor.dead and (actor.status_stun or 0) <= 0 and (actor.status_emp or 0) <= 0 then
            local player_distance = distance(actor, battle.player)
            local lod_stride = player_distance > 1200 and 4 or 1
            if (model.ai_frame + actor.id) % lod_stride ~= 0 then
                if actor.ai_agent and model.ai_frame % 15 == actor.id % 15 then pcall(actor.ai_agent.setPosition, actor.ai_agent, actor.x, actor.y) end
            else
            local step_dt = dt * lod_stride
            actor.ai_clock = (actor.ai_clock or 0) - dt
            actor.sense_clock = (actor.sense_clock or ((actor.id % 10) * 0.025)) - step_dt
            local target = actor.ai_target
            if target and (target.dead or state.modules.Teams.is_ally(model, target.team, actor.team)) then target = nil end
            local target_distance = target and distance(actor, target) or nil
            if actor.sense_clock <= 0 then
                target, target_distance = nearest_visible(state, actor)
                actor.ai_target = target
                actor.sense_clock = (state.content.ai.think_interval or 0.25) + (actor.id % 5) * 0.018
            end
            if target then
                actor.ai_state = target_distance < 320 and "engage" or "advance"
                actor.ai_target = target
                actor.angle = math.atan2(target.y - actor.y, target.x - actor.x)
                if target_distance > 250 then move_towards(state, actor, target, step_dt) end
                if actor.ai_clock <= 0 and target_distance < actor.build.sight * model.tile_size then
                    state.modules.Combat.fire(state, actor, target.x, target.y, 1)
                    actor.ai_clock = (state.content.ai.think_interval or 0.25) + ((actor.id * 17) % 7) / 10
                end
            else
                actor.ai_state = "patrol"
                actor.patrol_clock = (actor.patrol_clock or 0) - step_dt
                if actor.patrol_clock <= 0 then
                    actor.patrol_clock = 3
                    actor.patrol_x = actor.home_x + ((actor.id * 113) % 900) - 450
                    actor.patrol_y = actor.home_y + ((actor.id * 71) % 900) - 450
                end
                move_towards(state, actor, {x = actor.patrol_x, y = actor.patrol_y}, step_dt)
            end
            if actor.ai_agent then
                pcall(actor.ai_agent.setPosition, actor.ai_agent, actor.x, actor.y)
                pcall(actor.ai_agent.setStance, actor.ai_agent, actor.ai_state or "patrol")
            end
            end
        end
    end
    state.modules.Navigation.update_avoidance(model, model.actors, dt)
end

function M.emit(state, kind, x, y, strength)
    local stimuli = state.battle and state.battle.model.stimuli
    if not stimuli then return end
    pcall(stimuli.add, stimuli, kind, x, y, strength or 1, 2.0)
end

return M
