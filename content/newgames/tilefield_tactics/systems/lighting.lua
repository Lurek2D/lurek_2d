local M = {}

function M.compute(model)
    model.field:computeLight({
        includePointLights = true,
        includeGlobalLight = true,
        ambient = { r = 0.02, g = 0.02, b = 0.025 },
    })
    model.light = model.field:exportLightLayer(model.active_level)
end

return M
