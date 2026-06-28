local M = {}

function M.compute(model)
    local light = model.light_map
    if not light then
        light = lurek.tilelight.new(model.field)
        light:addPointLight({ x = 3, y = 3, z = 1, radius = 6, intensity = 0.9, color = { r = 1, g = 0.75, b = 0.42 } })
        light:addPointLight({ x = 9, y = 9, z = 1, radius = 5, intensity = 0.7, color = { r = 0.35, g = 0.55, b = 1 } })
        light:setGlobalLight({ intensity = 0.32, color = { r = 1, g = 0.96, b = 0.86 } })
        model.light_map = light
    end
    light:compute({
        includePointLights = true,
        includeGlobalLight = true,
        ambient = { r = 0.02, g = 0.02, b = 0.025 },
    })
    model.light = light:exportLayer(model.active_level)
end

return M
