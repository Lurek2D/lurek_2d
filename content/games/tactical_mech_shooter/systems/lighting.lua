local M = {}

function M.create(state, model)
    model.visual_lights = {}
    return model
end

function M.update(state, dt)
    local model = state.battle and state.battle.model
    if not model then return end
    if model.tilelight and model.lights_dirty then
        model.lights_dirty = false
        model.tilelight:compute({includePointLights = true, includeGlobalLight = false})
        model.light_layer = model.tilelight:exportLayer(1)
    end
end

function M.flash(state, x, y, color)
    local model = state.battle and state.battle.model
    if not model then return end
    state.modules.Effects.burst(state, x, y, color or {1, 0.6, 0.2, 1}, 3, 0.12)
end

return M
