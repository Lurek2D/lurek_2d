--- Tilelight Example
--- Demonstrates tile-based lighting over a shared LTileField.

local function tilelight_log(message)
    lurek.log.info("[tilelight.example] " .. tostring(message))
end

--@api: lurek.tilelight.new
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 1 })
    local light = lurek.tilelight.new(field)
    tilelight_log("tilelight type=" .. light:type())
end

--@api: LTileLightMap:addPointLight
--@api: LTileLightMap:compute
--@api: LTileLightMap:getLight
do
    local field = lurek.tilefield.new({ width = 6, height = 3 })
    field:setBlock(4, 2, 1, "light", true)
    local light = lurek.tilelight.new(field)
    light:addPointLight({ x = 2, y = 2, z = 1, radius = 5, intensity = 1, color = { r = 1, g = 0.6, b = 0.2 } })
    light:compute({ includePointLights = true, includeGlobalLight = false })
    local _, _, _, near = light:getLight(3, 2, 1)
    local _, _, _, blocked = light:getLight(6, 2, 1)
    tilelight_log("point light near=" .. near .. " blocked=" .. blocked)
end

--@api: LTileLightMap:setGlobalLight
--@api: LTileLightMap:exportLayer
--@api: LTileLightMap:exportVolume
do
    local field = lurek.tilefield.new({ width = 3, height = 3, levels = 2 })
    field:setSunOcclusion(2, 2, 2, 0.5)
    local light = lurek.tilelight.new(field)
    light:setGlobalLight({ intensity = 0.4, color = { r = 1, g = 0.85, b = 0.55 } })
    light:compute({ includePointLights = false, includeGlobalLight = true })
    local layer = light:exportLayer(1)
    local volume = light:exportVolume()
    tilelight_log("layer cells=" .. #layer .. " levels=" .. #volume)
end

--@api: lurek.tilelight.compute
do
    local field = lurek.tilefield.new({ width = 2, height = 2 })
    local light = lurek.tilelight.compute(field, { ambient = { r = 0.1, g = 0.1, b = 0.12 } })
    local _, _, _, luma = light:getLight(1, 1, 1)
    tilelight_log("ambient luma=" .. luma)
end
