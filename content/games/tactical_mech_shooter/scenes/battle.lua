local M = {}

local function spawn_point(model, team_id, index)
    local team = tonumber(tostring(team_id):match("(%d+)$")) or 1
    local spawns = model.active_map and model.active_map.spawn or {}
    local source
    for _, spawn in ipairs(spawns) do if tonumber(spawn.team) == team then source = spawn; break end end
    source = source or {x = team % 2 == 1 and 18 or 107, y = team <= 2 and 18 or 107, radius = 8}
    if index == 0 then return model.world.center(model, source.x, source.y) end
    local ring = 2.5 + math.floor((index - 1) / 8) * 1.55
    local angle = ((index - 1) % 8) * math.pi * 0.25 + team * 0.31
    local x = source.x + math.cos(angle) * ring
    local y = source.y + math.sin(angle) * ring
    return model.world.center(model, x, y)
end

local function make_build(state, preset_id)
    local build, err = state.modules.Build.from_preset(state.content, preset_id)
    assert(build, tostring(err))
    return build
end

local function change_player_build(state, preset_id)
    local battle = state.battle
    local actor = battle and battle.player
    if not actor or actor.dead then return end
    local next_build = make_build(state, preset_id)
    local hp_ratio = actor.hp / math.max(1, actor.build.max_health)
    local energy_ratio = actor.energy / math.max(1, actor.build.max_energy)
    actor.build = next_build
    actor.radius = next_build.corpus.radius
    actor.hp = next_build.max_health * hp_ratio
    actor.energy = next_build.max_energy * energy_ratio
    actor.shield_current, actor.max_shield = next_build.shield, next_build.shield
    actor.base_signature, actor.signature = next_build.signature, next_build.signature
    actor.cooldowns = {0, 0}
    actor.spread_slots = {actor.max_spread_radius, actor.max_spread_radius}
    battle.preset_id = preset_id
    state.modules.Effects.burst(state, actor.x, actor.y, next_build.corpus.color, 4, 0.32)
end

function M.start(state, preset_id)
    local model = state.modules.World.create(state)
    model.active_map = state.content.active_map
    model.world = state.modules.World
    state.modules.Physics.create(state, model)
    state.modules.Camera.create(state, model)
    state.modules.Awareness.create(state, model)
    state.modules.Lighting.create(state, model)
    state.modules.Navigation.create(state, model)
    state.modules.AI.create(state, model)
    state.modules.Effects.create(state, model)
    state.modules.Combat.create(state, model)
    state.modules.Minimap.create(state, model)
    local battle = {
        model = model, preset_id = preset_id or "f1", elapsed = 0, score = 0,
        enemies_left = 0, phase = "LIVE", squad = {}, player = nil, active_index = 1,
    }
    state.battle = battle
    local player_build = make_build(state, battle.preset_id)
    local px, py = spawn_point(model, "team1", 0)
    battle.player = state.modules.Combat.spawn_actor(state, "team1", player_build, px, py, 1, true)
    battle.squad[#battle.squad + 1] = battle.player
    local spent = player_build.cost
    local ally_team = state.content.active_map.mode == "balanced_2v2" and "team2" or "team1"
    for _, ally_preset in ipairs(state.content.game.squad_presets or {"f1", "f2", "f3"}) do
        local ally_build = make_build(state, ally_preset)
        if spent + ally_build.cost <= (state.content.game.battle_budget or 200) then
            local ax, ay = spawn_point(model, ally_team, #battle.squad)
            local ally = state.modules.Combat.spawn_actor(state, ally_team, ally_build, ax, ay, #model.actors + 1, false)
            battle.squad[#battle.squad + 1] = ally
            spent = spent + ally_build.cost
        end
    end
    local count = math.min(tonumber(state.content.game.enemy_count) or 12, tonumber(state.content.game.max_enemies) or 32)
    local spawned = 0
    local enemy_teams, enemy_team_count = 0, 0
    for team_number = 2, state.modules.Teams.team_count(model) do
        if state.modules.Teams.is_enemy(model, "team1", "team" .. tostring(team_number)) then enemy_team_count = enemy_team_count + 1 end
    end
    for team_number = 2, state.modules.Teams.team_count(model) do
        local team = "team" .. tostring(team_number)
        if state.modules.Teams.is_enemy(model, "team1", team) then
            enemy_teams = enemy_teams + 1
            local team_count = math.floor(count / math.max(1, enemy_team_count)) + (enemy_teams <= count % math.max(1, enemy_team_count) and 1 or 0)
            local enemy_build = make_build(state, "f" .. tostring(team_number))
            for i = 1, team_count do
                local ex, ey = spawn_point(model, team, i)
                state.modules.Combat.spawn_actor(state, team, enemy_build, ex, ey, #model.actors + 1, false)
                spawned = spawned + 1
            end
        end
    end
    battle.enemies_left = spawned
    battle.awareness_team_index = 1
    battle.awareness_clock = 0
    state.phase = "battle"
    state.modules.Awareness.compute(state)
end

function M.switch_actor(state)
    local battle = state.battle
    if not battle or #battle.squad == 0 then return end
    local start = battle.active_index or 1
    for offset = 1, #battle.squad do
        local index = ((start + offset - 1) % #battle.squad) + 1
        local candidate = battle.squad[index]
        if candidate and not candidate.dead then
            for _, ally in ipairs(battle.squad) do ally.is_player = false end
            candidate.is_player = true
            battle.active_index = index
            battle.player = candidate
            battle.model.camera:lookAt(candidate.x, candidate.y)
            return
        end
    end
end

local function mouse_world(model)
    local sx, sy = lurek.input.mouse.getX(), lurek.input.mouse.getY()
    return model.camera:toWorld(sx, sy)
end

function M.process(state, dt)
    local battle = state.battle
    if not battle then return end
    if state.modules.Movement.pressed(state, "pause") then state.phase = "pause"; return end
    if state.modules.Movement.pressed(state, "restart") then M.start(state, battle.preset_id); return end
    for i = 1, 12 do
        local preset_id = "f" .. tostring(i)
        if state.modules.Movement.pressed(state, "preset_" .. tostring(i)) and battle.preset_id ~= preset_id then
            change_player_build(state, preset_id)
            return
        end
    end
    if state.modules.Movement.pressed(state, "switch") then M.switch_actor(state) end
    state.last_dt = dt
    battle.elapsed = battle.elapsed + dt
    local model = battle.model
    state.modules.Camera.handle_wheel(state, model)
    state.modules.Camera.update(model, battle.player, dt)
    local mouse_x, mouse_y = mouse_world(model)
    state.modules.Movement.update(state, battle.player, dt, mouse_x, mouse_y)
    state.modules.Combat.player_fire(state, battle.player, mouse_x, mouse_y)
    state.modules.AI.update(state, dt)
    state.modules.Combat.update(state, dt)
    state.modules.World.update_smoke(model, dt)
    state.modules.Effects.update(state, dt)
    state.modules.Lighting.update(state, dt)
    battle.awareness_clock = (battle.awareness_clock or 0) - dt
    if battle.awareness_clock <= 0 then
        local team_index = battle.awareness_team_index or 1
        state.modules.Awareness.compute_team(state, "team" .. tostring(team_index))
        local team_count = state.modules.Teams.team_count(model)
        battle.awareness_team_index = team_index % team_count + 1
        local per_team_hz = math.max(1, tonumber(state.content.game.awareness_hz) or 3)
        battle.awareness_clock = 1 / (per_team_hz * team_count)
    end
    state.modules.Minimap.update(state)
    local enemies = 0
    for _, actor in ipairs(model.actors) do
        if state.modules.Teams.is_enemy(model, "team1", actor.team) and not actor.dead then enemies = enemies + 1 end
    end
    battle.enemies_left = enemies
    local allies_alive = 0
    for _, ally in ipairs(battle.squad) do if not ally.dead then allies_alive = allies_alive + 1 end end
    local score_win = battle.score >= (state.content.game.score_to_win or math.huge)
    if enemies == 0 or score_win or allies_alive == 0 or battle.elapsed >= (state.content.game.match_seconds or 480) then
        battle.win = (enemies == 0 or score_win) and allies_alive > 0
        battle.phase = battle.win and "VICTORY" or "TIMEOUT"
        state.modules.Economy.finish(state.content, state.campaign, battle.win)
        state.modules.Save.save(state.campaign, state.game_root)
        state.last_battle = battle
        state.phase = "results"
    end
end

function M.process_physics(state, dt)
    if state.battle then state.modules.Physics.step(state.battle.model, dt) end
end

function M.draw(state)
    state.modules.Render.world(state)
end

function M.draw_ui(state)
    state.modules.Render.hud(state)
    state.modules.UI.update(state)
    state.modules.UI.draw(state)
end

return M
