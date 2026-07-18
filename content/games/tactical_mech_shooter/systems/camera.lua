local M = {}

function M.create(state, model)
    local width, height = lurek.window.getWidth(), lurek.window.getHeight()
    model.camera = lurek.camera.new(width, height)
    -- The renderer uses the game's logical coordinate space.  Re-assert the
    -- full logical viewport here because the first resize event can arrive
    -- with the physical surface size on DPI-scaled displays.
    model.camera:setViewport(0, 0, width, height)
    model.camera:setBounds(0, 0, model.width * model.tile_size, model.height * model.tile_size)
    local config = state.content.game
    model.camera:setZoomConstraints(
        tonumber(config.camera_zoom_min) or 0.75,
        tonumber(config.camera_zoom_max) or 1.75
    )
    model.camera:setZoom(1.0)
    model.camera:lookAt(0, 0)
    return model
end

function M.zoom_by(state, model, wheel_y)
    if wheel_y == 0 then return false end
    local step = tonumber(state.content.game.camera_zoom_step) or 0.12
    local factor = math.exp(wheel_y * step)
    model.camera:setZoom(model.camera:getZoom() * factor)
    return true
end

function M.handle_wheel(state, model)
    local _, wheel_y = lurek.input.mouse.getWheelDelta()
    return M.zoom_by(state, model, wheel_y)
end

function M.update(model, actor, dt)
    if actor and not actor.dead then model.camera:setTarget(actor.x, actor.y) end
    model.camera:update(dt)
end

function M.to_world(model, x, y)
    return model.camera:toWorld(x, y)
end

function M.apply(model)
    local x, y = model.camera:getPosition()
    local zoom = model.camera:getZoom()
    lurek.render.push()
    lurek.render.translate(lurek.window.getWidth() * 0.5, lurek.window.getHeight() * 0.5)
    lurek.render.scale(zoom, zoom)
    lurek.render.translate(-x, -y)
end

function M.reset(model)
    lurek.render.pop()
end

return M
