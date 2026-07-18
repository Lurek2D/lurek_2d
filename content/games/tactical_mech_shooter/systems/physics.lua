local M = {}

function M.create(state, model)
    model.physics = lurek.physics.newWorld(0, 0)
    model.body_to_actor = {}
    for _, wall in ipairs(model.walls or {}) do
        local body = model.physics:newBody(wall.x, wall.y, "static")
        local shape = lurek.physics.newRectangleShape(wall.w, wall.h)
        lurek.physics.attachShape(body, shape)
    end
    return model
end

function M.spawn_actor(model, x, y, radius)
    local body = model.physics:newCircleBody(x, y, radius or 14, "dynamic", {linearDamping = 10, bullet = false})
    body:setFixedRotation(true)
    pcall(body.setAltitudeMode, body, "ground")
    local actor = {body = body, x = x, y = y, radius = radius or 14}
    model.body_to_actor[body:getId()] = actor
    return actor
end

function M.spawn_projectile(model, x, y, vx, vy, radius)
    local body = model.physics:newCircleBody(x, y, radius or 4, "dynamic", {bullet = true, linearDamping = 0})
    body:setFixedRotation(true)
    body:setVelocity(vx, vy)
    local projectile = {body = body, x = x, y = y, radius = radius or 4}
    model.body_to_actor[body:getId()] = projectile
    return projectile
end

function M.set_position(actor, x, y)
    actor.x, actor.y = x, y
    if actor.body and actor.body.setPosition then actor.body:setPosition(x, y) end
end

function M.velocity(actor, vx, vy)
    if actor.body and actor.body.setVelocity then actor.body:setVelocity(vx, vy) end
end

function M.step(model, dt)
    if model.physics then model.physics:step(dt) end
    for _, actor in ipairs(model.actors) do
        if actor.body and not actor.dead then
            actor.x, actor.y = actor.body:getPosition()
            local ok, altitude = pcall(actor.body.getAltitude, actor.body)
            if ok then actor.altitude = altitude end
        end
    end
    for _, projectile in ipairs(model.projectiles) do
        if projectile.body then projectile.x, projectile.y = projectile.body:getPosition() end
    end
end

function M.beam(model, x, y, dx, dy, distance)
    if not model.physics then return nil end
    local ok, trace = pcall(model.physics.castBeam, model.physics, x, y, dx, dy, distance, {reflect = false, maxBounces = 0})
    return ok and trace or nil
end

function M.destroy(model, object)
    if object and object.body then
        local id = object.body:getId()
        model.body_to_actor[id] = nil
        pcall(object.body.destroy, object.body)
    end
end

return M
