local M = {}

local function cell_key(model, x, y)
    return (y - 1) * model.width + x
end

local function light_luma(model, x, y)
    local cell = model.light_layer and model.light_layer[(y - 1) * model.width + x]
    if type(cell) ~= "table" then return 0 end
    return tonumber(cell.luma or cell[4]) or 0
end

local function smoke_contains(model, x, y)
    local wx, wy = model.world.center(model, x, y)
    for _, smoke in ipairs(model.smoke or {}) do
        local dx, dy = wx - smoke.x, wy - smoke.y
        if dx * dx + dy * dy <= smoke.radius * smoke.radius then return true end
    end
    return false
end

local function segment_hits_smoke(smoke, ax, ay, bx, by)
    local vx, vy = bx - ax, by - ay
    local length_sq = vx * vx + vy * vy
    local t = 0
    if length_sq > 0 then t = math.max(0, math.min(1, ((smoke.x - ax) * vx + (smoke.y - ay) * vy) / length_sq)) end
    local px, py = ax + vx * t, ay + vy * t
    local dx, dy = smoke.x - px, smoke.y - py
    return dx * dx + dy * dy <= smoke.radius * smoke.radius
end

function M.create(state, model)
    local teams = state.modules.Teams.list(model)
    model.awareness = lurek.awareness.newTileAwareness(model.field, {
        players = teams,
        rememberExplored = true,
    })
    model.visible_cells, model.explored_cells = {}, {}
    return model
end

local function sources_for_team(state, model, team)
    local candidates = {}
    for _, actor in ipairs(model.actors) do
        if not actor.dead and actor.team == team then
            local cx, cy = model.world.cell(model, actor.x, actor.y)
            local source = {
                x = cx, y = cy, z = 1, range = math.max(1, math.floor(actor.build.sight)),
            }
            local arc = tonumber(actor.build.vision_arc) or 360
            if arc < 359.9 then
                source.mode, source.arc = "cone", arc
                source.facing = {
                    x = math.floor(math.cos(actor.angle or 0) * 100),
                    y = math.floor(math.sin(actor.angle or 0) * 100),
                }
            end
            candidates[#candidates + 1] = source
        end
    end
    local cap = math.max(1, tonumber(state.content.game.max_sight_sources_per_team) or 12)
    if #candidates <= cap then return candidates end
    local sources, stride = {}, #candidates / cap
    for i = 1, cap do sources[i] = candidates[math.floor((i - 1) * stride) + 1] end
    return sources
end

function M.compute_team(state, team)
    local battle = state.battle
    if not battle or not battle.model.awareness then return end
    local model = battle.model
    model.awareness:updateSightSources(team, sources_for_team(state, model, team))
    local lookup = {}
    local explored = model.explored_cells[team] or {}
    for _, cell in ipairs(model.awareness:visibleCells(team, 1)) do
        local key = cell_key(model, cell.x, cell.y)
        lookup[key], explored[key] = true, true
    end
    model.visible_cells[team] = lookup
    model.explored_cells[team] = explored
end

function M.compute(state)
    for _, team in ipairs(state.modules.Teams.list(state.battle.model)) do M.compute_team(state, team) end
end

function M.tile_state(state, team, x, y)
    local model = state.battle.model
    local key = cell_key(model, x, y)
    local visible = model.visible_cells[team] and model.visible_cells[team][key] == true
    local explored = model.explored_cells[team] and model.explored_cells[team][key] == true
    if visible and smoke_contains(model, x, y) then visible = false end
    return visible, explored, light_luma(model, x, y)
end

function M.can_see(state, observer, target)
    if not observer or not target or observer.dead or target.dead then return false end
    local model = state.battle.model
    local dx, dy = target.x - observer.x, target.y - observer.y
    local distance = math.sqrt(dx * dx + dy * dy)
    if distance > observer.build.sight * model.tile_size then return false end
    local tcx, tcy = model.world.cell(model, target.x, target.y)
    if not model.awareness:isVisible(observer.team, tcx, tcy, 1) then return false end

    -- Awareness owns geometric FOV; tilelight supplies the illumination policy.
    -- Very close silhouettes remain visible, while darkvision lowers the light threshold.
    local threshold = tonumber(state.content.game.vision_light_threshold) or 0.045
    threshold = threshold * (1 - math.min(0.9, observer.build.darkvision or 0))
    if distance > model.tile_size * 2 and light_luma(model, tcx, tcy) < threshold then return false end

    for _, smoke in ipairs(model.smoke) do
        if segment_hits_smoke(smoke, observer.x, observer.y, target.x, target.y) then
            return (observer.build.smoke_resist or 0) >= 0.9
        end
    end
    return true
end

function M.has_line_of_sight(state, observer, target)
    if not observer or not target then return false end
    local model = state.battle.model
    local ox, oy = model.world.cell(model, observer.x, observer.y)
    local tx, ty = model.world.cell(model, target.x, target.y)
    return lurek.awareness.lineOfSight(
        model.field,
        {x = ox, y = oy, z = 1},
        {x = tx, y = ty, z = 1},
        {channel = "vision"}
    )
end

function M.add_smoke(state, x, y, radius)
    state.modules.Effects.smoke(state, x, y, radius or 72, 8)
end

return M
