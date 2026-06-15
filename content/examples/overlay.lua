--- @title Overlay Effects
--- @desc Weather, atmosphere, screen flash/shake/fade, and transitions.

--@api: lurek.overlay.new
do
    local ov = lurek.overlay.new(800, 600)
    local w, h = ov:getDimensions()
    print("lurek.overlay.new type=" .. ov:type())
    print("lurek.overlay.new size=" .. w .. "x" .. h)
end

--@api: lurek.overlay.newTransition
do
    local tr = lurek.overlay.newTransition("wipe", 0.75, { 0.05, 0.10, 0.15, 1.0 })
    print("lurek.overlay.newTransition type=" .. tr:type())
    print("lurek.overlay.newTransition kind=" .. tr:kind())
end

--@api: LOverlay:clear
do
    local ov = lurek.overlay.new(800, 600)
    ov:triggerFlash(1, 1, 1, 0.5, 0.1)
    print("LOverlay:clear before=" .. tostring(ov:isActive()))
    ov:clear()
    print("LOverlay:clear after=" .. tostring(ov:isActive()))
end

--@api: LOverlay:drawToImage
do
    local ov = lurek.overlay.new(200, 150)
    ov:flash(0.9, 0.95, 1.0, 0.6, 0.2)
    local img = ov:drawToImage(200, 150)
    print("LOverlay:drawToImage type=" .. type(img))
    print("LOverlay:drawToImage active=" .. tostring(ov:isActive()))
end

--@api: LOverlay:fade
do
    local ov = lurek.overlay.new(800, 600)
    ov:fade(0.05, 0.05, 0.10, 0.85, 0.5)
    print("LOverlay:fade isFading=" .. tostring(ov:isFading()))
    print("LOverlay:fade active=" .. tostring(ov:isActive()))
end

--@api: LOverlay:flash
do
    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:flash(1.0, 0.95, 0.70, 0.8, 0.2)
    print("LOverlay:flash isFlashing=" .. tostring(ov:isFlashing()))
    print("LOverlay:flash alpha=" .. f2(ov:getFlashAlpha()))
end

--@api: LOverlay:getAmbientColor
do
    local function rgba_text(r, g, b, a)
        return string.format("(%.2f, %.2f, %.2f, %.2f)", r, g, b, a)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setAmbientColor(0.2, 0.1, 0.3, 0.5)
    local r, g, b, a = ov:getAmbientColor()
    print("LOverlay:getAmbientColor=" .. rgba_text(r, g, b, a))
end

--@api: LOverlay:getCloudCount
do
    local ov = lurek.overlay.new(800, 600)
    ov:setCloudCount(8)
    print("LOverlay:getCloudCount=" .. ov:getCloudCount())
end

--@api: LOverlay:getCloudOpacity
do
    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setCloudOpacity(0.7)
    print("LOverlay:getCloudOpacity=" .. f2(ov:getCloudOpacity()))
end

--@api: LOverlay:getCloudScale
do
    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setCloudScale(1.5)
    print("LOverlay:getCloudScale=" .. f2(ov:getCloudScale()))
end

--@api: LOverlay:getCloudSpeed
do
    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setCloudSpeed(0.3)
    print("LOverlay:getCloudSpeed=" .. f2(ov:getCloudSpeed()))
end

--@api: LOverlay:getDimensions
do
    local ov = lurek.overlay.new(800, 600)
    local w, h = ov:getDimensions()
    print("LOverlay:getDimensions=" .. w .. "x" .. h)
end

--@api: LOverlay:getFilmGrainIntensity
do
    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setFilmGrainIntensity(0.4)
    print("LOverlay:getFilmGrainIntensity=" .. f2(ov:getFilmGrainIntensity()))
end

--@api: LOverlay:getFlashAlpha
do
    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:flash(1, 1, 0, 1.0, 0.5)
    print("LOverlay:getFlashAlpha=" .. f2(ov:getFlashAlpha()))
end

--@api: LOverlay:getFogColor
do
    local function rgba_text(r, g, b, a)
        return string.format("(%.2f, %.2f, %.2f, %.2f)", r, g, b, a)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setFogColor(0.5, 0.5, 0.5, 0.8)
    local r, g, b, a = ov:getFogColor()
    print("LOverlay:getFogColor=" .. rgba_text(r, g, b, a))
end

--@api: LOverlay:getFogDensity
do
    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setFogDensity(0.6)
    print("LOverlay:getFogDensity=" .. f2(ov:getFogDensity()))
end

--@api: LOverlay:getHeatHazeIntensity
do
    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setHeatHazeIntensity(0.4)
    print("LOverlay:getHeatHazeIntensity=" .. f2(ov:getHeatHazeIntensity()))
end

--@api: LOverlay:getHeight
do
    local ov = lurek.overlay.new(800, 600)
    print("LOverlay:getHeight=" .. ov:getHeight())
end

--@api: LOverlay:getLightningAlpha
do
    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:triggerLightning()
    print("LOverlay:getLightningAlpha=" .. f2(ov:getLightningAlpha()))
end

--@api: LOverlay:getLightningColor
do
    local function rgba_text(r, g, b, a)
        return string.format("(%.2f, %.2f, %.2f, %.2f)", r, g, b, a)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setLightningColor(0.9, 0.9, 1.0, 1.0)
    local r, g, b, a = ov:getLightningColor()
    print("LOverlay:getLightningColor=" .. rgba_text(r, g, b, a))
end

--@api: LOverlay:getShakeOffset
do
    local function pair_text(x, y)
        return string.format("(%.2f, %.2f)", x, y)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:shake(5.0, 0.3)
    local ox, oy = ov:getShakeOffset()
    print("LOverlay:getShakeOffset=" .. pair_text(ox, oy))
end

--@api: LOverlay:getTimeOfDay
do
    local ov = lurek.overlay.new(800, 600)
    ov:setTimeOfDay(0.75)
    print("LOverlay:getTimeOfDay=" .. ov:getTimeOfDay())
end

--@api: LOverlay:getVignetteStrength
do
    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setVignetteStrength(0.6)
    print("LOverlay:getVignetteStrength=" .. f2(ov:getVignetteStrength()))
end

--@api: LOverlay:getWater
do
    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setWater(0.20, 1.10, 0.35)
    local w = ov:getWater()
    print("LOverlay:getWater enabled=" .. tostring(w.enabled))
    print("LOverlay:getWater wave=" .. f2(w.amplitude) .. "," .. f2(w.frequency) .. "," .. f2(w.speed))
end

--@api: LOverlay:getWeather
do
    local ov = lurek.overlay.new(800, 600)
    ov:setWeather("rain")
    print("LOverlay:getWeather=" .. ov:getWeather())
end

--@api: LOverlay:getWeatherIntensity
do
    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setWeatherIntensity(0.7)
    print("LOverlay:getWeatherIntensity=" .. f2(ov:getWeatherIntensity()))
end

--@api: LOverlay:getWidth
do
    local ov = lurek.overlay.new(800, 600)
    print("LOverlay:getWidth=" .. ov:getWidth())
end

--@api: LOverlay:getWindDirection
do
    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setWindDirection(0.79)
    print("LOverlay:getWindDirection=" .. f2(ov:getWindDirection()))
end

--@api: LOverlay:getWindSpeed
do
    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setWindSpeed(12.0)
    print("LOverlay:getWindSpeed=" .. f2(ov:getWindSpeed()))
end

--@api: LOverlay:isActive
do
    local ov = lurek.overlay.new(800, 600)
    ov:triggerFlash(1, 1, 1, 0.5, 0.3)
    print("LOverlay:isActive=" .. tostring(ov:isActive()))
end

--@api: LOverlay:isAmbientEnabled
do
    local ov = lurek.overlay.new(800, 600)
    ov:setAmbientEnabled(true)
    print("LOverlay:isAmbientEnabled=" .. tostring(ov:isAmbientEnabled()))
end

--@api: LOverlay:isCloudShadowsEnabled
do
    local ov = lurek.overlay.new(800, 600)
    ov:setCloudShadows(true)
    print("LOverlay:isCloudShadowsEnabled=" .. tostring(ov:isCloudShadowsEnabled()))
    print("LOverlay:isCloudShadowsEnabled count=" .. ov:getCloudCount())
end

--@api: LOverlay:isFading
do
    local ov = lurek.overlay.new(800, 600)
    ov:triggerFade(0.0, 0.0, 0.0, 1.0, 0.4)
    print("LOverlay:isFading=" .. tostring(ov:isFading()))
end

--@api: LOverlay:isFilmGrainEnabled
do
    local ov = lurek.overlay.new(800, 600)
    ov:setFilmGrainEnabled(true)
    print("LOverlay:isFilmGrainEnabled=" .. tostring(ov:isFilmGrainEnabled()))
end

--@api: LOverlay:isFlashing
do
    local ov = lurek.overlay.new(800, 600)
    ov:triggerFlash(1, 0, 0, 1.0, 0.5)
    print("LOverlay:isFlashing=" .. tostring(ov:isFlashing()))
end

--@api: LOverlay:isFogEnabled
do
    local ov = lurek.overlay.new(800, 600)
    ov:setFogEnabled(true)
    print("LOverlay:isFogEnabled=" .. tostring(ov:isFogEnabled()))
end

--@api: LOverlay:isHeatHazeEnabled
do
    local ov = lurek.overlay.new(800, 600)
    ov:setHeatHazeEnabled(true)
    print("LOverlay:isHeatHazeEnabled=" .. tostring(ov:isHeatHazeEnabled()))
end

--@api: LOverlay:isShaking
do
    local ov = lurek.overlay.new(800, 600)
    ov:triggerShake(5.0, 0.5)
    print("LOverlay:isShaking=" .. tostring(ov:isShaking()))
end

--@api: LOverlay:isVignetteEnabled
do
    local ov = lurek.overlay.new(800, 600)
    ov:setVignetteEnabled(true)
    print("LOverlay:isVignetteEnabled=" .. tostring(ov:isVignetteEnabled()))
end

--@api: LOverlay:isWeatherEnabled
do
    local ov = lurek.overlay.new(800, 600)
    ov:setWeatherEnabled(true)
    print("LOverlay:isWeatherEnabled=" .. tostring(ov:isWeatherEnabled()))
end

--@api: LOverlay:pullAmbientFromLight
do
    local function rgba_text(r, g, b, a)
        return string.format("(%.2f, %.2f, %.2f, %.2f)", r, g, b, a)
    end

    local source = lurek.overlay.new(800, 600)
    source:setAmbientColor(0.12, 0.18, 0.30, 0.65)
    source:pushAmbientToLight()

    local ov = lurek.overlay.new(800, 600)
    ov:pullAmbientFromLight()
    local r, g, b, a = ov:getAmbientColor()
    print("LOverlay:pullAmbientFromLight=" .. rgba_text(r, g, b, a))
end

--@api: LOverlay:pushAmbientToLight
do
    local function rgba_text(r, g, b, a)
        return string.format("(%.2f, %.2f, %.2f, %.2f)", r, g, b, a)
    end

    local source = lurek.overlay.new(800, 600)
    source:setAmbientColor(0.30, 0.20, 0.50, 0.40)
    source:pushAmbientToLight()

    local probe = lurek.overlay.new(800, 600)
    probe:pullAmbientFromLight()
    local r, g, b, a = probe:getAmbientColor()
    print("LOverlay:pushAmbientToLight=" .. rgba_text(r, g, b, a))
end

--@api: LOverlay:render
do
    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:flash(1.0, 1.0, 1.0, 0.5, 0.2)
    ov:render()
    print("LOverlay:render active=" .. tostring(ov:isActive()))
    print("LOverlay:render flashAlpha=" .. f2(ov:getFlashAlpha()))
end

--@api: LOverlay:resize
do
    local ov = lurek.overlay.new(800, 600)
    ov:resize(1280, 720)
    print("LOverlay:resize=" .. ov:getWidth() .. "x" .. ov:getHeight())
end

--@api: LOverlay:setAmbientColor
do
    local function rgba_text(r, g, b, a)
        return string.format("(%.2f, %.2f, %.2f, %.2f)", r, g, b, a)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setAmbientColor(0.2, 0.1, 0.3, 0.5)
    local r, g, b, a = ov:getAmbientColor()
    print("LOverlay:setAmbientColor=" .. rgba_text(r, g, b, a))
end

--@api: LOverlay:setAmbientEnabled
do
    local ov = lurek.overlay.new(800, 600)
    ov:setAmbientEnabled(true)
    print("LOverlay:setAmbientEnabled=" .. tostring(ov:isAmbientEnabled()))
end

--@api: LOverlay:setCloudCount
do
    local ov = lurek.overlay.new(800, 600)
    ov:setCloudCount(12)
    print("LOverlay:setCloudCount=" .. ov:getCloudCount())
end

--@api: LOverlay:setCloudOpacity
do
    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setCloudOpacity(0.5)
    print("LOverlay:setCloudOpacity=" .. f2(ov:getCloudOpacity()))
end

--@api: LOverlay:setCloudScale
do
    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setCloudScale(2.0)
    print("LOverlay:setCloudScale=" .. f2(ov:getCloudScale()))
end

--@api: LOverlay:setCloudShadows
do
    local ov = lurek.overlay.new(800, 600)
    ov:setCloudShadows(true)
    print("LOverlay:setCloudShadows=" .. tostring(ov:isCloudShadowsEnabled()))
end

--@api: LOverlay:setCloudSpeed
do
    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setCloudSpeed(0.5)
    print("LOverlay:setCloudSpeed=" .. f2(ov:getCloudSpeed()))
end

--@api: LOverlay:setCustomShader
do
    local ov = lurek.overlay.new(800, 600)
    ov:setCustomShader("scanlines")
    local img_with_shader = ov:drawToImage(96, 64)
    ov:setCustomShader(nil)
    local img_without_shader = ov:drawToImage(96, 64)
    print("LOverlay:setCustomShader types=" .. type(img_with_shader) .. "," .. type(img_without_shader))
end

--@api: LOverlay:setFilmGrainEnabled
do
    local ov = lurek.overlay.new(800, 600)
    ov:setFilmGrainEnabled(true)
    print("LOverlay:setFilmGrainEnabled=" .. tostring(ov:isFilmGrainEnabled()))
end

--@api: LOverlay:setFilmGrainIntensity
do
    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setFilmGrainIntensity(0.3)
    print("LOverlay:setFilmGrainIntensity=" .. f2(ov:getFilmGrainIntensity()))
end

--@api: LOverlay:setFogColor
do
    local function rgba_text(r, g, b, a)
        return string.format("(%.2f, %.2f, %.2f, %.2f)", r, g, b, a)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setFogColor(0.7, 0.7, 0.8, 0.6)
    local r, g, b, a = ov:getFogColor()
    print("LOverlay:setFogColor=" .. rgba_text(r, g, b, a))
end

--@api: LOverlay:setFogDensity
do
    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setFogDensity(0.5)
    print("LOverlay:setFogDensity=" .. f2(ov:getFogDensity()))
end

--@api: LOverlay:setFogEnabled
do
    local ov = lurek.overlay.new(800, 600)
    ov:setFogEnabled(true)
    print("LOverlay:setFogEnabled=" .. tostring(ov:isFogEnabled()))
end

--@api: LOverlay:setHeatHazeEnabled
do
    local ov = lurek.overlay.new(800, 600)
    ov:setHeatHazeEnabled(true)
    print("LOverlay:setHeatHazeEnabled=" .. tostring(ov:isHeatHazeEnabled()))
end

--@api: LOverlay:setHeatHazeIntensity
do
    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setHeatHazeIntensity(0.5)
    print("LOverlay:setHeatHazeIntensity=" .. f2(ov:getHeatHazeIntensity()))
end

--@api: LOverlay:setLightningColor
do
    local function rgba_text(r, g, b, a)
        return string.format("(%.2f, %.2f, %.2f, %.2f)", r, g, b, a)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setLightningColor(1.0, 1.0, 0.8, 1.0)
    local r, g, b, a = ov:getLightningColor()
    print("LOverlay:setLightningColor=" .. rgba_text(r, g, b, a))
end

--@api: LOverlay:setTimeOfDay
do
    local ov = lurek.overlay.new(800, 600)
    ov:setTimeOfDay(0.5)
    print("LOverlay:setTimeOfDay=" .. ov:getTimeOfDay())
end

--@api: LOverlay:setVignetteEnabled
do
    local ov = lurek.overlay.new(800, 600)
    ov:setVignetteEnabled(true)
    print("LOverlay:setVignetteEnabled=" .. tostring(ov:isVignetteEnabled()))
end

--@api: LOverlay:setVignetteStrength
do
    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setVignetteStrength(0.7)
    print("LOverlay:setVignetteStrength=" .. f2(ov:getVignetteStrength()))
end

--@api: LOverlay:setWater
do
    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setWater(0.25, 1.25, 0.60)
    local w = ov:getWater()
    print("LOverlay:setWater enabled=" .. tostring(w.enabled))
    print("LOverlay:setWater wave=" .. f2(w.amplitude) .. "," .. f2(w.frequency) .. "," .. f2(w.speed))
end

--@api: LOverlay:setWaterTint
do
    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setWater(0.20, 1.10, 0.35)
    ov:setWaterTint(0.1, 0.3, 0.7, 0.8)
    local w = ov:getWater()
    print("LOverlay:setWaterTint tint=" .. f2(w.tint_r) .. "," .. f2(w.tint_g) .. "," .. f2(w.tint_b) .. "," .. f2(w.tint_strength))
end

--@api: LOverlay:setWeather
do
    local ov = lurek.overlay.new(800, 600)
    ov:setWeather("snow")
    print("LOverlay:setWeather=" .. ov:getWeather())
end

--@api: LOverlay:setWeatherEnabled
do
    local ov = lurek.overlay.new(800, 600)
    ov:setWeatherEnabled(true)
    print("LOverlay:setWeatherEnabled=" .. tostring(ov:isWeatherEnabled()))
end

--@api: LOverlay:setWeatherIntensity
do
    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setWeatherIntensity(0.8)
    print("LOverlay:setWeatherIntensity=" .. f2(ov:getWeatherIntensity()))
end

--@api: LOverlay:setWindDirection
do
    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setWindDirection(1.57)
    print("LOverlay:setWindDirection=" .. f2(ov:getWindDirection()))
end

--@api: LOverlay:setWindSpeed
do
    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setWindSpeed(8.0)
    print("LOverlay:setWindSpeed=" .. f2(ov:getWindSpeed()))
end

--@api: LOverlay:shake
do
    local ov = lurek.overlay.new(800, 600)
    ov:shake(8.0, 0.4)
    print("LOverlay:shake isShaking=" .. tostring(ov:isShaking()))
end

--@api: LOverlay:syncAmbientWithLight
do
    local function rgba_text(r, g, b, a)
        return string.format("(%.2f, %.2f, %.2f, %.2f)", r, g, b, a)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setAmbientColor(0.20, 0.10, 0.40, 0.60)
    ov:syncAmbientWithLight("overlay")

    local probe = lurek.overlay.new(800, 600)
    probe:pullAmbientFromLight()
    local r, g, b, a = probe:getAmbientColor()
    print("LOverlay:syncAmbientWithLight=" .. rgba_text(r, g, b, a))
end

--@api: LOverlay:triggerFade
do
    local ov = lurek.overlay.new(800, 600)
    ov:triggerFade(1.0, 0, 0, 0, 0.2)
    print("LOverlay:triggerFade isFading=" .. tostring(ov:isFading()))
end

--@api: LOverlay:triggerFlash
do
    local ov = lurek.overlay.new(800, 600)
    ov:triggerFlash(1, 1, 0, 1.0, 0.2)
    print("LOverlay:triggerFlash isFlashing=" .. tostring(ov:isFlashing()))
end

--@api: LOverlay:triggerLightning
do
    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:triggerLightning()
    print("LOverlay:triggerLightning alpha=" .. f2(ov:getLightningAlpha()))
end

--@api: LOverlay:triggerShake
do
    local ov = lurek.overlay.new(800, 600)
    ov:triggerShake(6.0, 0.3)
    print("LOverlay:triggerShake isShaking=" .. tostring(ov:isShaking()))
end

--@api: LOverlay:type
do
    local ov = lurek.overlay.new(800, 600)
    print("LOverlay:type=" .. ov:type())
end

--@api: LOverlay:typeOf
do
    local ov = lurek.overlay.new(800, 600)
    print("LOverlay:typeOf LOverlay=" .. tostring(ov:typeOf("LOverlay")))
end

--@api: LOverlay:update
do
    local ov = lurek.overlay.new(800, 600)
    ov:triggerShake(5.0, 1.0)
    ov:update(0.016)
    print("LOverlay:update isShaking=" .. tostring(ov:isShaking()))
end

--@api: LScreenTransition:color
do
    local function rgba_text(r, g, b, a)
        return string.format("(%.2f, %.2f, %.2f, %.2f)", r, g, b, a)
    end

    local tr = lurek.overlay.newTransition("fade", 1.0, { 0.0, 0.0, 0.0, 1.0 })
    local r, g, b, a = tr:color()
    print("LScreenTransition:color=" .. rgba_text(r, g, b, a))
end

--@api: LScreenTransition:isActive
do
    local tr = lurek.overlay.newTransition("fade", 1.0, { 0.0, 0.0, 0.0, 1.0 })
    tr:play()
    print("LScreenTransition:isActive=" .. tostring(tr:isActive()))
end

--@api: LScreenTransition:isDone
do
    local tr = lurek.overlay.newTransition("fade", 0.2, { 0.0, 0.0, 0.0, 1.0 })
    tr:play()
    tr:update(1.0)
    print("LScreenTransition:isDone=" .. tostring(tr:isDone()))
end

--@api: LScreenTransition:kind
do
    local tr = lurek.overlay.newTransition("iris", 1.0, { 0.0, 0.0, 0.0, 1.0 })
    print("LScreenTransition:kind=" .. tr:kind())
end

--@api: LScreenTransition:play
do
    local function f2(value)
        return string.format("%.2f", value)
    end

    local tr = lurek.overlay.newTransition("fade", 0.5, { 0.0, 0.0, 0.0, 1.0 })
    tr:play()
    print("LScreenTransition:play isActive=" .. tostring(tr:isActive()))
    print("LScreenTransition:play progress=" .. f2(tr:progress()))
end

--@api: LScreenTransition:progress
do
    local function f2(value)
        return string.format("%.2f", value)
    end

    local tr = lurek.overlay.newTransition("fade", 1.0, { 0.0, 0.0, 0.0, 1.0 })
    tr:play()
    tr:update(0.5)
    print("LScreenTransition:progress=" .. f2(tr:progress()))
end

--@api: LScreenTransition:reverse
do
    local function f2(value)
        return string.format("%.2f", value)
    end

    local tr = lurek.overlay.newTransition("fade", 1.0, { 0.0, 0.0, 0.0, 1.0 })
    tr:reverse()
    print("LScreenTransition:reverse isActive=" .. tostring(tr:isActive()))
    print("LScreenTransition:reverse progress=" .. f2(tr:progress()))
end

--@api: LScreenTransition:setColor
do
    local function rgba_text(r, g, b, a)
        return string.format("(%.2f, %.2f, %.2f, %.2f)", r, g, b, a)
    end

    local tr = lurek.overlay.newTransition("fade", 1.0, { 0.0, 0.0, 0.0, 1.0 })
    tr:setColor({ 0.1, 0.05, 0.2, 1.0 })
    local r, g, b, a = tr:color()
    print("LScreenTransition:setColor=" .. rgba_text(r, g, b, a))
end

--@api: LScreenTransition:type
do
    local tr = lurek.overlay.newTransition("fade", 1.0, { 0.0, 0.0, 0.0, 1.0 })
    print("LScreenTransition:type=" .. tr:type())
end

--@api: LScreenTransition:typeOf
do
    local tr = lurek.overlay.newTransition("fade", 1.0, { 0.0, 0.0, 0.0, 1.0 })
    print("LScreenTransition:typeOf LScreenTransition=" .. tostring(tr:typeOf("LScreenTransition")))
end

--@api: LScreenTransition:update
do
    local function f2(value)
        return string.format("%.2f", value)
    end

    local tr = lurek.overlay.newTransition("fade", 1.0, { 0.0, 0.0, 0.0, 1.0 })
    tr:play()
    local still_active = tr:update(0.016)
    print("LScreenTransition:update active=" .. tostring(still_active))
    print("LScreenTransition:update progress=" .. f2(tr:progress()))
end

--@api: LOverlay:getStats
do
    local ov = lurek.overlay.new(800, 600)
    ov:setWeatherEnabled(true)
    ov:setWeather("rain")
    ov:setWeatherIntensity(0.6)
    ov:triggerFlash(1.0, 1.0, 1.0, 0.7, 0.2)
    local stats = ov:getStats()
    print("overlay stats size=" .. stats.width .. "x" .. stats.height)
    print("overlay stats effects=" .. stats.active_effects .. " weather=" .. tostring(stats.weather_enabled))
end

