--- Tilelight Example
--- Compact one-owner examples for tile-based lighting.

--@api: lurek.tilelight.new
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        local made = lurek.tilelight.new(field)
        return made:type()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: lurek.tilelight.compute
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        local made = lurek.tilelight.compute(field, { ambient = { r = 0.1, g = 0.1, b = 0.12 } })
        local _, _, _, luma = made:getLight(1, 1, 1)
        return luma
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileLightMap:addPointLight
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        return light:addPointLight({ x = 2, y = 2, z = 1, radius = 3, intensity = 1 })
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileLightMap:updatePointLight
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        local id = light:addPointLight({ x = 1, y = 1, z = 1, radius = 2 })
        light:updatePointLight(id, { x = 3, y = 3, radius = 3 })
        return id
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileLightMap:removePointLight
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        local id = light:addPointLight({ x = 1, y = 1, z = 1, radius = 2 })
        return light:removePointLight(id)
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileLightMap:clearPointLights
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        light:addPointLight({ x = 2, y = 2, z = 1, radius = 2 })
        light:clearPointLights()
        return light:type()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileLightMap:addLineLight
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        return light:addLineLight({ x1 = 1, y1 = 2, x2 = 6, y2 = 2, z1 = 1, z2 = 1, radius = 1.5 })
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileLightMap:updateLineLight
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        local id = light:addLineLight({ x1 = 1, y1 = 2, x2 = 6, y2 = 2, z1 = 1, z2 = 1, radius = 1.5 })
        light:updateLineLight(id, { x1 = 2, y1 = 2, x2 = 5, y2 = 2, radius = 2 })
        return id
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileLightMap:removeLineLight
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        local id = light:addLineLight({ x1 = 1, y1 = 2, x2 = 6, y2 = 2, z1 = 1, z2 = 1, radius = 1.5 })
        return light:removeLineLight(id)
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileLightMap:clearLineLights
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        light:addLineLight({ x1 = 1, y1 = 2, x2 = 6, y2 = 2, z1 = 1, z2 = 1, radius = 1.5 })
        light:clearLineLights()
        return light:type()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileLightMap:addAreaLight
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        return light:addAreaLight({ x = 2, y = 2, z = 1, width = 2, height = 2, radius = 2 })
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileLightMap:addRectLight
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        return light:addRectLight({ x = 2, y = 2, z = 1, w = 2, h = 2, radius = 2 })
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileLightMap:updateAreaLight
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        local id = light:addAreaLight({ x = 2, y = 2, z = 1, width = 2, height = 2, radius = 2 })
        light:updateAreaLight(id, { x = 3, y = 3, w = 1, h = 1 })
        return id
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileLightMap:updateRectLight
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        local id = light:addRectLight({ x = 2, y = 2, z = 1, w = 2, h = 2, radius = 2 })
        light:updateRectLight(id, { x = 3, y = 3, w = 1, h = 1 })
        return id
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileLightMap:removeAreaLight
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        local id = light:addAreaLight({ x = 2, y = 2, z = 1, width = 2, height = 2, radius = 2 })
        return light:removeAreaLight(id)
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileLightMap:removeRectLight
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        local id = light:addRectLight({ x = 2, y = 2, z = 1, w = 2, h = 2, radius = 2 })
        return light:removeRectLight(id)
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileLightMap:clearAreaLights
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        light:addAreaLight({ x = 2, y = 2, z = 1, width = 2, height = 2, radius = 2 })
        light:clearAreaLights()
        return light:type()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileLightMap:clearRectLights
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        light:addRectLight({ x = 2, y = 2, z = 1, w = 2, h = 2, radius = 2 })
        light:clearRectLights()
        return light:type()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileLightMap:setAmbient
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        light:setAmbient({ r = 0.1, g = 0.2, b = 0.3 })
        light:compute({ includeSunLight = false })
        return light:getLight(1, 1, 1)
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileLightMap:setSunLight
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        light:setSunLight({ kind = "directional", intensity = 0.8, direction = { x = 1, y = 0 } })
        light:compute({ includeSunLight = true })
        return light:getLight(1, 1, 1)
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileLightMap:setGlobalLight
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        light:setGlobalLight({ intensity = 0.4, color = { r = 1, g = 0.85, b = 0.55 } })
        light:compute({ includeGlobalLight = true })
        return light:getLight(1, 1, 1)
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileLightMap:compute
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        light:addPointLight({ x = 2, y = 2, z = 1, radius = 3, intensity = 1 })
        -- Line and area sources are independently selectable when a map has them.
        light:compute({ includePointLights = true, includeLineLights = false, includeAreaLights = false, includeSunLight = false })
        return light:getLight(2, 2, 1)
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileLightMap:getLight
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        light:setAmbient({ r = 0.1, g = 0.1, b = 0.1 })
        light:compute({ includeSunLight = false })
        return light:getLight(1, 1, 1)
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileLightMap:exportLayer
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        light:setAmbient({ r = 0.1, g = 0.1, b = 0.1 })
        light:compute({ includeSunLight = false })
        return #light:exportLayer(1)
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileLightMap:exportVolume
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        light:setAmbient({ r = 0.1, g = 0.1, b = 0.1 })
        light:compute({ includeSunLight = false })
        return #light:exportVolume()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileLightMap:getSize
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        local w, h, levels = light:getSize()
        return w + h + levels
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileLightMap:type
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        return light:type()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileLightMap:typeOf
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        return light:typeOf("LTileLightMap")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
