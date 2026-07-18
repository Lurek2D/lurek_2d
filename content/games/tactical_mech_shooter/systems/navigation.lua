local M = {}

local function safe_call(object, method, ...)
    if not object or type(object[method]) ~= "function" then
        return false, "missing method: " .. tostring(method)
    end
    return pcall(object[method], object, ...)
end

M.safe_call = safe_call

function M.create(state, model)
    local nav = nil
    assert(lurek.pathfind and lurek.pathfind.newNavGridFromField, "required API missing: lurek.pathfind.newNavGridFromField")
    do
        local ok, value = pcall(lurek.pathfind.newNavGridFromField, model.field, {
            level = 1,
            channel = "move",
            costChannel = "move",
        })
        assert(ok and value, "failed to create navigation grid: " .. tostring(value))
        nav = value
    end
    model.nav = nav
    assert(lurek.pathfind.newPathfinder, "required API missing: lurek.pathfind.newPathfinder")
    model.pathfinder = assert(lurek.pathfind.newPathfinder(nav), "failed to create pathfinder")
    assert(lurek.pathfind.newORCASolver, "required API missing: lurek.pathfind.newORCASolver")
    model.orca = assert(lurek.pathfind.newORCASolver(1.0), "failed to create ORCA solver")
    return model
end

function M.next_waypoint(model, actor, tx, ty)
    actor.nav_clock = (actor.nav_clock or 0) - 1
    if not actor.nav_path or actor.nav_clock <= 0 then
        actor.nav_path = M.find_path(model, actor, tx, ty)
        actor.nav_index = 1
        actor.nav_clock = 15
    end
    local point = actor.nav_path and actor.nav_path[actor.nav_index or 1]
    if not point then return tx, ty end
    local px = (tonumber(point.x or point[1]) - 0.5) * model.tile_size
    local py = (tonumber(point.y or point[2]) - 0.5) * model.tile_size
    if (actor.x - px) ^ 2 + (actor.y - py) ^ 2 < (model.tile_size * 0.6) ^ 2 then
        actor.nav_index = (actor.nav_index or 1) + 1
        point = actor.nav_path[actor.nav_index]
        if not point then return tx, ty end
        px = (tonumber(point.x or point[1]) - 0.5) * model.tile_size
        py = (tonumber(point.y or point[2]) - 0.5) * model.tile_size
    end
    return px, py
end

function M.find_path(model, actor, tx, ty)
    local pathfinder = model.pathfinder
    if not pathfinder then return nil end
    local sx, sy = model.world.cell(model, actor.x, actor.y)
    local gx, gy = model.world.cell(model, tx, ty)
    local ok, path = safe_call(pathfinder, "findPathSmooth", sx, sy, gx, gy, {
        diagonal = true,
        simplify = true,
        smooth = true,
    })
    if ok and type(path) == "table" then return path end
    ok, path = safe_call(pathfinder, "findPath", sx, sy, gx, gy)
    if ok and type(path) == "table" then return path end
    return nil
end

function M.update_avoidance(model, actors, dt)
    if not model.orca then return end
    for _, actor in ipairs(actors) do
        if not actor.dead then
            safe_call(model.orca, "setAgent", actor.id, actor.x, actor.y, actor.radius or 14, actor.build.move_speed, actor.pref_vx or 0, actor.pref_vy or 0)
        end
    end
    safe_call(model.orca, "compute", dt)
    for _, actor in ipairs(actors) do
        if not actor.dead then
            local ok, vx, vy = safe_call(model.orca, "getSafeVelocity", actor.id)
            if ok and vx and vy then actor.safe_vx, actor.safe_vy = vx, vy end
        end
    end
end

return M
