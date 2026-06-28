--- @title Overlay Effects
--- @desc Weather, atmosphere, screen flash/shake/fade, and transitions.



--@api: lurek.overlay.new
do

    local ov = lurek.overlay.new(800, 600)
    local w, h = ov:getDimensions()
    lurek.log.info("new type=" .. ov:type())
    lurek.log.info("new size=" .. w .. "x" .. h)
    lurek.log.info("new width=" .. ov:getWidth())
    lurek.log.info("new height=" .. ov:getHeight())
end

--@api: lurek.overlay.newTransition
do

    local tr = lurek.overlay.newTransition("wipe", 0.75, { 0.05, 0.10, 0.15, 1.0 })
    local r, g, b, a = tr:color()
    lurek.log.info("newTransition type=" .. tr:type())
    lurek.log.info("newTransition kind=" .. tr:kind())
    lurek.log.info("newTransition active=" .. tostring(tr:isActive()))
    lurek.log.info("newTransition color=" .. string.format("%.2f,%.2f,%.2f,%.2f", r, g, b, a))
end

--@api: LOverlay:clear
do

    local ov = lurek.overlay.new(800, 600)
    ov:triggerFlash(1, 1, 1, 0.5, 0.1)
    lurek.log.info("LOverlay:clear before=" .. tostring(ov:isActive()))
    ov:clear()
    lurek.log.info("LOverlay:clear after=" .. tostring(ov:isActive()))
end

--@api: LOverlay:drawToImage
do

    local ov = lurek.overlay.new(200, 150)
    ov:flash(0.9, 0.95, 1.0, 0.6, 0.2)
    local img = ov:drawToImage(200, 150)
    lurek.log.info("LOverlay:drawToImage type=" .. type(img))
    lurek.log.info("LOverlay:drawToImage active=" .. tostring(ov:isActive()))
end

--@api: LOverlay:fade
do

    local ov = lurek.overlay.new(800, 600)
    ov:fade(0.05, 0.05, 0.10, 0.85, 0.5)
    ov:update(0.1)
    lurek.log.info("fade isFading=" .. tostring(ov:isFading()))
    lurek.log.info("fade active=" .. tostring(ov:isActive()))
    lurek.log.info("fade flashAlpha=" .. string.format("%.2f", ov:getFlashAlpha()))
    lurek.log.info("fade dimensions=" .. ov:getWidth() .. "x" .. ov:getHeight())
end

--@api: LOverlay:flash
do


    local ov = lurek.overlay.new(800, 600)
    ov:flash(1.0, 0.95, 0.70, 0.8, 0.2)
    lurek.log.info("LOverlay:flash isFlashing=" .. tostring(ov:isFlashing()))
    lurek.log.info("LOverlay:flash alpha=" .. string.format("%.2f", ov:getFlashAlpha()))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end

--@api: LOverlay:getAmbientColor
do


    local ov = lurek.overlay.new(800, 600)
    ov:setAmbientColor(0.2, 0.1, 0.3, 0.5)
    local r, g, b, a = ov:getAmbientColor()
    lurek.log.info("LOverlay:getAmbientColor=" .. string.format("%.2f,%.2f,%.2f,%.2f", r, g, b, a))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end

--@api: LOverlay:getCloudCount
do

    local ov = lurek.overlay.new(800, 600)
    ov:setCloudCount(8)
    ov:setCloudShadows(true)
    lurek.log.info("getCloudCount count=" .. ov:getCloudCount())
    lurek.log.info("getCloudCount enabled=" .. tostring(ov:isCloudShadowsEnabled()))
    lurek.log.info("getCloudCount width=" .. ov:getWidth())
    lurek.log.info("getCloudCount height=" .. ov:getHeight())
end

--@api: LOverlay:getCloudOpacity
do


    local ov = lurek.overlay.new(800, 600)
    ov:setCloudOpacity(0.7)
    lurek.log.info("LOverlay:getCloudOpacity=" .. string.format("%.2f", ov:getCloudOpacity()))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end

--@api: LOverlay:getCloudScale
do


    local ov = lurek.overlay.new(800, 600)
    ov:setCloudScale(1.5)
    lurek.log.info("LOverlay:getCloudScale=" .. string.format("%.2f", ov:getCloudScale()))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end

--@api: LOverlay:getCloudSpeed
do


    local ov = lurek.overlay.new(800, 600)
    ov:setCloudSpeed(0.3)
    lurek.log.info("LOverlay:getCloudSpeed=" .. string.format("%.2f", ov:getCloudSpeed()))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end

--@api: LOverlay:getDimensions
do

    local ov = lurek.overlay.new(800, 600)
    local w, h = ov:getDimensions()
    lurek.log.info("getDimensions=" .. w .. "x" .. h)
    lurek.log.info("getDimensions width=" .. ov:getWidth())
    lurek.log.info("getDimensions height=" .. ov:getHeight())
    lurek.log.info("getDimensions active=" .. tostring(ov:isActive()))
end

--@api: LOverlay:getRenderPlan
do

    local ov = lurek.overlay.new(800, 600)
    ov:setFogEnabled(true)
    ov:setWater(0.2, 1.0, 0.5)
    ov:setCloudShadows(true)
    ov:setFilmGrainEnabled(true)
    local plan = ov:getRenderPlan()
    lurek.log.info("rendered layers=" .. tostring(#plan.rendered))
    lurek.log.info("external layers=" .. tostring(#plan.externally_handled))
    lurek.log.info("first external=" .. tostring(plan.externally_handled[1]))
end

--@api: LOverlay:getFilmGrainIntensity
do


    local ov = lurek.overlay.new(800, 600)
    ov:setFilmGrainIntensity(0.4)
    lurek.log.info("LOverlay:getFilmGrainIntensity=" .. string.format("%.2f", ov:getFilmGrainIntensity()))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end

--@api: LOverlay:getFlashAlpha
do


    local ov = lurek.overlay.new(800, 600)
    ov:flash(1, 1, 0, 1.0, 0.5)
    lurek.log.info("LOverlay:getFlashAlpha=" .. string.format("%.2f", ov:getFlashAlpha()))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end

--@api: LOverlay:getFogColor
do


    local ov = lurek.overlay.new(800, 600)
    ov:setFogColor(0.5, 0.5, 0.5, 0.8)
    local r, g, b, a = ov:getFogColor()
    lurek.log.info("LOverlay:getFogColor=" .. string.format("%.2f,%.2f,%.2f,%.2f", r, g, b, a))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end

--@api: LOverlay:getFogDensity
do


    local ov = lurek.overlay.new(800, 600)
    ov:setFogDensity(0.6)
    lurek.log.info("LOverlay:getFogDensity=" .. string.format("%.2f", ov:getFogDensity()))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end

--@api: LOverlay:getHeatHazeIntensity
do


    local ov = lurek.overlay.new(800, 600)
    ov:setHeatHazeIntensity(0.4)
    lurek.log.info("LOverlay:getHeatHazeIntensity=" .. string.format("%.2f", ov:getHeatHazeIntensity()))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end

--@api: LOverlay:getHeight
do

    local ov = lurek.overlay.new(800, 600)
    local w, h = ov:getDimensions()
    lurek.log.info("getHeight=" .. ov:getHeight())
    lurek.log.info("dimensions=" .. w .. "x" .. h)
    lurek.log.info("width getter=" .. ov:getWidth())
    lurek.log.info("type=" .. ov:type())
end

--@api: LOverlay:getLightningAlpha
do


    local ov = lurek.overlay.new(800, 600)
    ov:triggerLightning()
    lurek.log.info("LOverlay:getLightningAlpha=" .. string.format("%.2f", ov:getLightningAlpha()))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end

--@api: LOverlay:setAccessibilityPolicy
do

    local ov = lurek.overlay.new(800, 600)
    ov:setAccessibilityPolicy({
        reduced_motion = true,
        max_flash_alpha = 0.2,
        max_flash_duration = 0.1,
        max_shake_intensity = 1.25,
        disable_lightning = true,
        disable_film_grain = true,
    })
    ov:triggerFlash(1.0, 1.0, 1.0, 0.9, 0.5)
    lurek.log.info("reduced motion=" .. tostring(ov:getAccessibilityPolicy().reduced_motion))
    lurek.log.info("flash alpha after clamp=" .. string.format("%.2f", ov:getFlashAlpha()))
end

--@api: LOverlay:getAccessibilityPolicy
do

    local ov = lurek.overlay.new(800, 600)
    ov:setAccessibilityPolicy({
        max_flash_alpha = 0.3,
        disable_lightning = true,
        disable_film_grain = true,
    })
    local policy = ov:getAccessibilityPolicy()
    lurek.log.info("policy flash alpha=" .. string.format("%.2f", policy.max_flash_alpha))
    lurek.log.info("policy disable lightning=" .. tostring(policy.disable_lightning))
    lurek.log.info("policy disable grain=" .. tostring(policy.disable_film_grain))
end

--@api: LOverlay:getLightningColor
do


    local ov = lurek.overlay.new(800, 600)
    ov:setLightningColor(0.9, 0.9, 1.0, 1.0)
    local r, g, b, a = ov:getLightningColor()
    lurek.log.info("LOverlay:getLightningColor=" .. string.format("%.2f,%.2f,%.2f,%.2f", r, g, b, a))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end

--@api: LOverlay:getShakeOffset
do


    local ov = lurek.overlay.new(800, 600)
    ov:shake(5.0, 0.3)
    local ox, oy = ov:getShakeOffset()
    lurek.log.info("LOverlay:getShakeOffset=" .. string.format("%.2f,%.2f", ox, oy))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end

--@api: LOverlay:getTimeOfDay
do

    local ov = lurek.overlay.new(800, 600)
    ov:setTimeOfDay(0.75)
    ov:setAmbientEnabled(true)
    local r, g, b, a = ov:getAmbientColor()
    lurek.log.info("getTimeOfDay=" .. ov:getTimeOfDay())
    lurek.log.info("ambient enabled=" .. tostring(ov:isAmbientEnabled()))
    lurek.log.info("ambient color=" .. string.format("%.2f,%.2f,%.2f,%.2f", r, g, b, a))
    lurek.log.info("active=" .. tostring(ov:isActive()))
end

--@api: LOverlay:getVignetteStrength
do


    local ov = lurek.overlay.new(800, 600)
    ov:setVignetteStrength(0.6)
    lurek.log.info("LOverlay:getVignetteStrength=" .. string.format("%.2f", ov:getVignetteStrength()))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end

--@api: LOverlay:getWater
do


    local ov = lurek.overlay.new(800, 600)
    ov:setWater(0.20, 1.10, 0.35)
    local w = ov:getWater()
    lurek.log.info("LOverlay:getWater enabled=" .. tostring(w.enabled))
    lurek.log.info("LOverlay:getWater wave=" .. string.format("%.2f", w.amplitude) .. "," .. string.format("%.2f", w.frequency) .. "," .. string.format("%.2f", w.speed))
end

--@api: LOverlay:getWeather
do

    local ov = lurek.overlay.new(800, 600)
    ov:setWeather("rain")
    ov:setWeatherEnabled(true)
    ov:setWeatherIntensity(0.6)
    lurek.log.info("getWeather=" .. ov:getWeather())
    lurek.log.info("weather enabled=" .. tostring(ov:isWeatherEnabled()))
    lurek.log.info("weather intensity=" .. string.format("%.2f", ov:getWeatherIntensity()))
    lurek.log.info("wind speed=" .. string.format("%.2f", ov:getWindSpeed()))
end

--@api: LOverlay:getWeatherIntensity
do


    local ov = lurek.overlay.new(800, 600)
    ov:setWeatherIntensity(0.7)
    lurek.log.info("LOverlay:getWeatherIntensity=" .. string.format("%.2f", ov:getWeatherIntensity()))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end

--@api: LOverlay:getWidth
do

    local ov = lurek.overlay.new(800, 600)
    local w, h = ov:getDimensions()
    lurek.log.info("getWidth=" .. ov:getWidth())
    lurek.log.info("dimensions=" .. w .. "x" .. h)
    lurek.log.info("height getter=" .. ov:getHeight())
    lurek.log.info("type=" .. ov:type())
end

--@api: LOverlay:getWindDirection
do


    local ov = lurek.overlay.new(800, 600)
    ov:setWindDirection(0.79)
    lurek.log.info("LOverlay:getWindDirection=" .. string.format("%.2f", ov:getWindDirection()))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end

--@api: LOverlay:getWindSpeed
do


    local ov = lurek.overlay.new(800, 600)
    ov:setWindSpeed(12.0)
    lurek.log.info("LOverlay:getWindSpeed=" .. string.format("%.2f", ov:getWindSpeed()))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end

--@api: LOverlay:isActive
do

    local ov = lurek.overlay.new(800, 600)
    ov:triggerFlash(1, 1, 1, 0.5, 0.3)
    lurek.log.info("isActive after flash=" .. tostring(ov:isActive()))
    lurek.log.info("isFlashing=" .. tostring(ov:isFlashing()))
    lurek.log.info("flashAlpha=" .. string.format("%.2f", ov:getFlashAlpha()))
    lurek.log.info("isFading=" .. tostring(ov:isFading()))
end

--@api: LOverlay:isAmbientEnabled
do

    local ov = lurek.overlay.new(800, 600)
    ov:setAmbientEnabled(true)
    local r, g, b, a = ov:getAmbientColor()
    lurek.log.info("isAmbientEnabled=" .. tostring(ov:isAmbientEnabled()))
    lurek.log.info("ambient color=" .. string.format("%.2f,%.2f,%.2f,%.2f", r, g, b, a))
    lurek.log.info("width=" .. ov:getWidth())
    lurek.log.info("height=" .. ov:getHeight())
end

--@api: LOverlay:isCloudShadowsEnabled
do

    local ov = lurek.overlay.new(800, 600)
    ov:setCloudShadows(true)
    ov:setCloudCount(6)
    lurek.log.info("isCloudShadowsEnabled=" .. tostring(ov:isCloudShadowsEnabled()))
    lurek.log.info("cloud count=" .. ov:getCloudCount())
    lurek.log.info("cloud scale=" .. string.format("%.2f", ov:getCloudScale()))
    lurek.log.info("cloud speed=" .. string.format("%.2f", ov:getCloudSpeed()))
end

--@api: LOverlay:isFading
do

    local ov = lurek.overlay.new(800, 600)
    ov:triggerFade(0.0, 0.0, 0.0, 1.0, 0.4)
    ov:update(0.1)
    lurek.log.info("isFading=" .. tostring(ov:isFading()))
    lurek.log.info("isActive=" .. tostring(ov:isActive()))
    lurek.log.info("flashAlpha=" .. string.format("%.2f", ov:getFlashAlpha()))
    lurek.log.info("isFlashing=" .. tostring(ov:isFlashing()))
end

--@api: LOverlay:isFilmGrainEnabled
do

    local ov = lurek.overlay.new(800, 600)
    ov:setFilmGrainEnabled(true)
    ov:setFilmGrainIntensity(0.35)
    lurek.log.info("isFilmGrainEnabled=" .. tostring(ov:isFilmGrainEnabled()))
    lurek.log.info("grain intensity=" .. string.format("%.2f", ov:getFilmGrainIntensity()))
    lurek.log.info("width=" .. ov:getWidth())
    lurek.log.info("height=" .. ov:getHeight())
end

--@api: LOverlay:isFlashing
do

    local ov = lurek.overlay.new(800, 600)
    ov:triggerFlash(1, 0, 0, 1.0, 0.5)
    lurek.log.info("isFlashing=" .. tostring(ov:isFlashing()))
    lurek.log.info("flash alpha=" .. string.format("%.2f", ov:getFlashAlpha()))
    lurek.log.info("isActive=" .. tostring(ov:isActive()))
    lurek.log.info("isFading=" .. tostring(ov:isFading()))
end

--@api: LOverlay:isFogEnabled
do

    local ov = lurek.overlay.new(800, 600)
    ov:setFogEnabled(true)
    ov:setFogDensity(0.45)
    lurek.log.info("isFogEnabled=" .. tostring(ov:isFogEnabled()))
    lurek.log.info("fog density=" .. string.format("%.2f", ov:getFogDensity()))
    lurek.log.info("fog active=" .. tostring(ov:isActive()))
    lurek.log.info("dimensions=" .. ov:getWidth() .. "x" .. ov:getHeight())
end

--@api: LOverlay:isHeatHazeEnabled
do

    local ov = lurek.overlay.new(800, 600)
    ov:setHeatHazeEnabled(true)
    ov:setHeatHazeIntensity(0.25)
    lurek.log.info("isHeatHazeEnabled=" .. tostring(ov:isHeatHazeEnabled()))
    lurek.log.info("heat haze intensity=" .. string.format("%.2f", ov:getHeatHazeIntensity()))
    lurek.log.info("width=" .. ov:getWidth())
    lurek.log.info("height=" .. ov:getHeight())
end

--@api: LOverlay:isShaking
do

    local ov = lurek.overlay.new(800, 600)
    ov:triggerShake(5.0, 0.5)
    local ox, oy = ov:getShakeOffset()
    lurek.log.info("isShaking=" .. tostring(ov:isShaking()))
    lurek.log.info("shake offset=" .. string.format("%.2f,%.2f", ox, oy))
    lurek.log.info("isActive=" .. tostring(ov:isActive()))
    lurek.log.info("width=" .. ov:getWidth())
end

--@api: LOverlay:isVignetteEnabled
do

    local ov = lurek.overlay.new(800, 600)
    ov:setVignetteEnabled(true)
    ov:setVignetteStrength(0.55)
    lurek.log.info("isVignetteEnabled=" .. tostring(ov:isVignetteEnabled()))
    lurek.log.info("vignette strength=" .. string.format("%.2f", ov:getVignetteStrength()))
    lurek.log.info("width=" .. ov:getWidth())
    lurek.log.info("height=" .. ov:getHeight())
end

--@api: LOverlay:isWeatherEnabled
do

    local ov = lurek.overlay.new(800, 600)
    ov:setWeatherEnabled(true)
    ov:setWeather("snow")
    ov:setWeatherIntensity(0.5)
    lurek.log.info("isWeatherEnabled=" .. tostring(ov:isWeatherEnabled()))
    lurek.log.info("weather=" .. ov:getWeather())
    lurek.log.info("weather intensity=" .. string.format("%.2f", ov:getWeatherIntensity()))
    lurek.log.info("wind direction=" .. string.format("%.2f", ov:getWindDirection()))
end

--@api: LOverlay:pullAmbientFromLight
do


    local source = lurek.overlay.new(800, 600)
    source:setAmbientColor(0.12, 0.18, 0.30, 0.65)
    source:pushAmbientToLight()

    local ov = lurek.overlay.new(800, 600)
    ov:pullAmbientFromLight()
    local r, g, b, a = ov:getAmbientColor()
    lurek.log.info("LOverlay:pullAmbientFromLight=" .. string.format("%.2f,%.2f,%.2f,%.2f", r, g, b, a))
end

--@api: LOverlay:pushAmbientToLight
do


    local source = lurek.overlay.new(800, 600)
    source:setAmbientColor(0.30, 0.20, 0.50, 0.40)
    source:pushAmbientToLight()

    local probe = lurek.overlay.new(800, 600)
    probe:pullAmbientFromLight()
    local r, g, b, a = probe:getAmbientColor()
    lurek.log.info("LOverlay:pushAmbientToLight=" .. string.format("%.2f,%.2f,%.2f,%.2f", r, g, b, a))
end

--@api: LOverlay:render
do


    local ov = lurek.overlay.new(800, 600)
    ov:flash(1.0, 1.0, 1.0, 0.5, 0.2)
    ov:render()
    lurek.log.info("LOverlay:render active=" .. tostring(ov:isActive()))
    lurek.log.info("LOverlay:render flashAlpha=" .. string.format("%.2f", ov:getFlashAlpha()))
end

--@api: LOverlay:resize
do

    local ov = lurek.overlay.new(800, 600)
    ov:resize(1280, 720)
    local w, h = ov:getDimensions()
    lurek.log.info("resize=" .. ov:getWidth() .. "x" .. ov:getHeight())
    lurek.log.info("dimensions=" .. w .. "x" .. h)
    lurek.log.info("type=" .. ov:type())
    lurek.log.info("active=" .. tostring(ov:isActive()))
end

--@api: LOverlay:setAmbientColor
do


    local ov = lurek.overlay.new(800, 600)
    ov:setAmbientColor(0.2, 0.1, 0.3, 0.5)
    local r, g, b, a = ov:getAmbientColor()
    lurek.log.info("LOverlay:setAmbientColor=" .. string.format("%.2f,%.2f,%.2f,%.2f", r, g, b, a))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end

--@api: LOverlay:setAmbientEnabled
do

    local ov = lurek.overlay.new(800, 600)
    ov:setAmbientEnabled(true)
    local r, g, b, a = ov:getAmbientColor()
    lurek.log.info("setAmbientEnabled=" .. tostring(ov:isAmbientEnabled()))
    lurek.log.info("ambient color=" .. string.format("%.2f,%.2f,%.2f,%.2f", r, g, b, a))
    lurek.log.info("width=" .. ov:getWidth())
    lurek.log.info("height=" .. ov:getHeight())
end

--@api: LOverlay:setCloudCount
do

    local ov = lurek.overlay.new(800, 600)
    ov:setCloudCount(12)
    ov:setCloudShadows(true)
    lurek.log.info("setCloudCount=" .. ov:getCloudCount())
    lurek.log.info("cloud shadows=" .. tostring(ov:isCloudShadowsEnabled()))
    lurek.log.info("cloud opacity=" .. string.format("%.2f", ov:getCloudOpacity()))
    lurek.log.info("cloud speed=" .. string.format("%.2f", ov:getCloudSpeed()))
end

--@api: LOverlay:setCloudOpacity
do


    local ov = lurek.overlay.new(800, 600)
    ov:setCloudOpacity(0.5)
    lurek.log.info("LOverlay:setCloudOpacity=" .. string.format("%.2f", ov:getCloudOpacity()))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end

--@api: LOverlay:setCloudScale
do


    local ov = lurek.overlay.new(800, 600)
    ov:setCloudScale(2.0)
    lurek.log.info("LOverlay:setCloudScale=" .. string.format("%.2f", ov:getCloudScale()))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end

--@api: LOverlay:setCloudShadows
do

    local ov = lurek.overlay.new(800, 600)
    ov:setCloudShadows(true)
    ov:setCloudCount(5)
    lurek.log.info("setCloudShadows=" .. tostring(ov:isCloudShadowsEnabled()))
    lurek.log.info("cloud count=" .. ov:getCloudCount())
    lurek.log.info("cloud scale=" .. string.format("%.2f", ov:getCloudScale()))
    lurek.log.info("cloud opacity=" .. string.format("%.2f", ov:getCloudOpacity()))
end

--@api: LOverlay:setCloudSpeed
do


    local ov = lurek.overlay.new(800, 600)
    ov:setCloudSpeed(0.5)
    lurek.log.info("LOverlay:setCloudSpeed=" .. string.format("%.2f", ov:getCloudSpeed()))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end

--@api: LOverlay:setCustomShader
do

    local ov = lurek.overlay.new(800, 600)
    ov:setCustomShader("scanlines")
    local img_with_shader = ov:drawToImage(96, 64)
    ov:setCustomShader(nil)
    local img_without_shader = ov:drawToImage(96, 64)
    lurek.log.info("LOverlay:setCustomShader types=" .. type(img_with_shader) .. "," .. type(img_without_shader))
end

--@api: LOverlay:setFilmGrainEnabled
do

    local ov = lurek.overlay.new(800, 600)
    ov:setFilmGrainEnabled(true)
    ov:setFilmGrainIntensity(0.25)
    lurek.log.info("setFilmGrainEnabled=" .. tostring(ov:isFilmGrainEnabled()))
    lurek.log.info("grain intensity=" .. string.format("%.2f", ov:getFilmGrainIntensity()))
    lurek.log.info("width=" .. ov:getWidth())
    lurek.log.info("height=" .. ov:getHeight())
end

--@api: LOverlay:setFilmGrainIntensity
do


    local ov = lurek.overlay.new(800, 600)
    ov:setFilmGrainIntensity(0.3)
    lurek.log.info("LOverlay:setFilmGrainIntensity=" .. string.format("%.2f", ov:getFilmGrainIntensity()))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end

--@api: LOverlay:setFogColor
do


    local ov = lurek.overlay.new(800, 600)
    ov:setFogColor(0.7, 0.7, 0.8, 0.6)
    local r, g, b, a = ov:getFogColor()
    lurek.log.info("LOverlay:setFogColor=" .. string.format("%.2f,%.2f,%.2f,%.2f", r, g, b, a))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end

--@api: LOverlay:setFogDensity
do


    local ov = lurek.overlay.new(800, 600)
    ov:setFogDensity(0.5)
    lurek.log.info("LOverlay:setFogDensity=" .. string.format("%.2f", ov:getFogDensity()))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end

--@api: LOverlay:setFogEnabled
do

    local ov = lurek.overlay.new(800, 600)
    ov:setFogEnabled(true)
    ov:setFogDensity(0.5)
    lurek.log.info("setFogEnabled=" .. tostring(ov:isFogEnabled()))
    lurek.log.info("fog density=" .. string.format("%.2f", ov:getFogDensity()))
    lurek.log.info("width=" .. ov:getWidth())
    lurek.log.info("height=" .. ov:getHeight())
end

--@api: LOverlay:setHeatHazeEnabled
do

    local ov = lurek.overlay.new(800, 600)
    ov:setHeatHazeEnabled(true)
    ov:setHeatHazeIntensity(0.4)
    lurek.log.info("setHeatHazeEnabled=" .. tostring(ov:isHeatHazeEnabled()))
    lurek.log.info("heat haze intensity=" .. string.format("%.2f", ov:getHeatHazeIntensity()))
    lurek.log.info("width=" .. ov:getWidth())
    lurek.log.info("height=" .. ov:getHeight())
end

--@api: LOverlay:setHeatHazeIntensity
do


    local ov = lurek.overlay.new(800, 600)
    ov:setHeatHazeIntensity(0.5)
    lurek.log.info("LOverlay:setHeatHazeIntensity=" .. string.format("%.2f", ov:getHeatHazeIntensity()))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end

--@api: LOverlay:setLightningColor
do


    local ov = lurek.overlay.new(800, 600)
    ov:setLightningColor(1.0, 1.0, 0.8, 1.0)
    local r, g, b, a = ov:getLightningColor()
    lurek.log.info("LOverlay:setLightningColor=" .. string.format("%.2f,%.2f,%.2f,%.2f", r, g, b, a))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end

--@api: LOverlay:setTimeOfDay
do

    local ov = lurek.overlay.new(800, 600)
    ov:setTimeOfDay(0.5)
    local r, g, b, a = ov:getAmbientColor()
    lurek.log.info("setTimeOfDay=" .. ov:getTimeOfDay())
    lurek.log.info("ambient color=" .. string.format("%.2f,%.2f,%.2f,%.2f", r, g, b, a))
    lurek.log.info("ambient enabled=" .. tostring(ov:isAmbientEnabled()))
    lurek.log.info("active=" .. tostring(ov:isActive()))
end

--@api: LOverlay:setVignetteEnabled
do

    local ov = lurek.overlay.new(800, 600)
    ov:setVignetteEnabled(true)
    ov:setVignetteStrength(0.6)
    lurek.log.info("setVignetteEnabled=" .. tostring(ov:isVignetteEnabled()))
    lurek.log.info("vignette strength=" .. string.format("%.2f", ov:getVignetteStrength()))
    lurek.log.info("width=" .. ov:getWidth())
    lurek.log.info("height=" .. ov:getHeight())
end

--@api: LOverlay:setVignetteStrength
do


    local ov = lurek.overlay.new(800, 600)
    ov:setVignetteStrength(0.7)
    lurek.log.info("LOverlay:setVignetteStrength=" .. string.format("%.2f", ov:getVignetteStrength()))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end

--@api: LOverlay:setWater
do


    local ov = lurek.overlay.new(800, 600)
    ov:setWater(0.25, 1.25, 0.60)
    local w = ov:getWater()
    lurek.log.info("LOverlay:setWater enabled=" .. tostring(w.enabled))
    lurek.log.info("LOverlay:setWater wave=" .. string.format("%.2f", w.amplitude) .. "," .. string.format("%.2f", w.frequency) .. "," .. string.format("%.2f", w.speed))
end

--@api: LOverlay:setWaterTint
do


    local ov = lurek.overlay.new(800, 600)
    ov:setWater(0.20, 1.10, 0.35)
    ov:setWaterTint(0.1, 0.3, 0.7, 0.8)
    local w = ov:getWater()
    lurek.log.info("LOverlay:setWaterTint tint=" .. string.format("%.2f", w.tint_r) .. "," .. string.format("%.2f", w.tint_g) .. "," .. string.format("%.2f", w.tint_b) .. "," .. string.format("%.2f", w.tint_strength))
end

--@api: LOverlay:setWeather
do

    local ov = lurek.overlay.new(800, 600)
    ov:setWeather("snow")
    ov:setWeatherEnabled(true)
    ov:setWeatherIntensity(0.7)
    lurek.log.info("setWeather=" .. ov:getWeather())
    lurek.log.info("weather enabled=" .. tostring(ov:isWeatherEnabled()))
    lurek.log.info("weather intensity=" .. string.format("%.2f", ov:getWeatherIntensity()))
    lurek.log.info("wind speed=" .. string.format("%.2f", ov:getWindSpeed()))
end

--@api: LOverlay:setWeatherEnabled
do

    local ov = lurek.overlay.new(800, 600)
    ov:setWeatherEnabled(true)
    ov:setWeather("rain")
    ov:setWeatherIntensity(0.8)
    lurek.log.info("setWeatherEnabled=" .. tostring(ov:isWeatherEnabled()))
    lurek.log.info("weather=" .. ov:getWeather())
    lurek.log.info("weather intensity=" .. string.format("%.2f", ov:getWeatherIntensity()))
    lurek.log.info("wind direction=" .. string.format("%.2f", ov:getWindDirection()))
end

--@api: LOverlay:setWeatherIntensity
do


    local ov = lurek.overlay.new(800, 600)
    ov:setWeatherIntensity(0.8)
    lurek.log.info("LOverlay:setWeatherIntensity=" .. string.format("%.2f", ov:getWeatherIntensity()))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end

--@api: LOverlay:setWeatherSeed
do

    local ov = lurek.overlay.new(800, 600)
    ov:setWeatherSeed(123456789)
    lurek.log.info("weather seed state=" .. tostring(ov:getWeatherRngState()))
    ov:setWeatherEnabled(true)
    lurek.log.info("weather enabled=" .. tostring(ov:isWeatherEnabled()))
end

--@api: LOverlay:getWeatherRngState
do

    local ov = lurek.overlay.new(800, 600)
    ov:setWeatherSeed(246813579)
    local state = ov:getWeatherRngState()
    lurek.log.info("weather rng state=" .. tostring(state))
    lurek.log.info("weather type=" .. tostring(ov:getWeather()))
end

--@api: LOverlay:setWeatherRngState
do

    local ov = lurek.overlay.new(800, 600)
    ov:setWeatherRngState(987654321)
    lurek.log.info("weather rng state=" .. tostring(ov:getWeatherRngState()))
    ov:setWeather("rain")
    lurek.log.info("overlay type=" .. tostring(ov:type()))
end

--@api: LOverlay:setWindDirection
do


    local ov = lurek.overlay.new(800, 600)
    ov:setWindDirection(1.57)
    lurek.log.info("LOverlay:setWindDirection=" .. string.format("%.2f", ov:getWindDirection()))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end

--@api: LOverlay:setWindSpeed
do


    local ov = lurek.overlay.new(800, 600)
    ov:setWindSpeed(8.0)
    lurek.log.info("LOverlay:setWindSpeed=" .. string.format("%.2f", ov:getWindSpeed()))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end

--@api: LOverlay:shake
do

    local ov = lurek.overlay.new(800, 600)
    ov:shake(8.0, 0.4)
    local ox, oy = ov:getShakeOffset()
    lurek.log.info("shake isShaking=" .. tostring(ov:isShaking()))
    lurek.log.info("shake offset=" .. string.format("%.2f,%.2f", ox, oy))
    lurek.log.info("shake active=" .. tostring(ov:isActive()))
    lurek.log.info("shake height=" .. ov:getHeight())
end

--@api: LOverlay:syncAmbientWithLight
do


    local ov = lurek.overlay.new(800, 600)
    ov:setAmbientColor(0.20, 0.10, 0.40, 0.60)
    ov:syncAmbientWithLight("overlay")

    local probe = lurek.overlay.new(800, 600)
    probe:pullAmbientFromLight()
    local r, g, b, a = probe:getAmbientColor()
    lurek.log.info("LOverlay:syncAmbientWithLight=" .. string.format("%.2f,%.2f,%.2f,%.2f", r, g, b, a))
end

--@api: LOverlay:triggerFade
do

    local ov = lurek.overlay.new(800, 600)
    ov:triggerFade(1.0, 0, 0, 0, 0.2)
    ov:update(0.05)
    lurek.log.info("triggerFade isFading=" .. tostring(ov:isFading()))
    lurek.log.info("triggerFade active=" .. tostring(ov:isActive()))
    lurek.log.info("triggerFade isFlashing=" .. tostring(ov:isFlashing()))
    lurek.log.info("triggerFade width=" .. ov:getWidth())
end

--@api: LOverlay:triggerFlash
do

    local ov = lurek.overlay.new(800, 600)
    ov:triggerFlash(1, 1, 0, 1.0, 0.2)
    lurek.log.info("triggerFlash isFlashing=" .. tostring(ov:isFlashing()))
    lurek.log.info("triggerFlash alpha=" .. string.format("%.2f", ov:getFlashAlpha()))
    lurek.log.info("triggerFlash active=" .. tostring(ov:isActive()))
    lurek.log.info("triggerFlash type=" .. ov:type())
end

--@api: LOverlay:triggerLightning
do


    local ov = lurek.overlay.new(800, 600)
    ov:triggerLightning()
    lurek.log.info("LOverlay:triggerLightning alpha=" .. string.format("%.2f", ov:getLightningAlpha()))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end

--@api: LOverlay:triggerShake
do

    local ov = lurek.overlay.new(800, 600)
    ov:triggerShake(6.0, 0.3)
    local ox, oy = ov:getShakeOffset()
    lurek.log.info("triggerShake isShaking=" .. tostring(ov:isShaking()))
    lurek.log.info("triggerShake offset=" .. string.format("%.2f,%.2f", ox, oy))
    lurek.log.info("triggerShake active=" .. tostring(ov:isActive()))
    lurek.log.info("triggerShake width=" .. ov:getWidth())
end

--@api: LOverlay:type
do

    local ov = lurek.overlay.new(800, 600)
    local w, h = ov:getDimensions()
    lurek.log.info("type=" .. ov:type())
    lurek.log.info("dimensions=" .. w .. "x" .. h)
    lurek.log.info("active=" .. tostring(ov:isActive()))
    lurek.log.info("typeOf overlay=" .. tostring(ov:typeOf("LOverlay")))
end

--@api: LOverlay:typeOf
do

    local ov = lurek.overlay.new(800, 600)
    lurek.log.info("typeOf LOverlay=" .. tostring(ov:typeOf("LOverlay")))
    lurek.log.info("overlay width=" .. tostring(ov:getWidth()))
    lurek.log.info("typeOf LScreenTransition=" .. tostring(ov:typeOf("LScreenTransition")))
    lurek.log.info("dimensions=" .. ov:getWidth() .. "x" .. ov:getHeight())
end

--@api: LOverlay:update
do

    local ov = lurek.overlay.new(800, 600)
    ov:triggerShake(5.0, 1.0)
    ov:update(0.016)
    local ox, oy = ov:getShakeOffset()
    lurek.log.info("update isShaking=" .. tostring(ov:isShaking()))
    lurek.log.info("update offset=" .. string.format("%.2f,%.2f", ox, oy))
    lurek.log.info("update active=" .. tostring(ov:isActive()))
    lurek.log.info("update width=" .. ov:getWidth())
end

--@api: LScreenTransition:color
do


    local tr = lurek.overlay.newTransition("fade", 1.0, { 0.0, 0.0, 0.0, 1.0 })
    local r, g, b, a = tr:color()
    lurek.log.info("LScreenTransition:color=" .. string.format("%.2f,%.2f,%.2f,%.2f", r, g, b, a))
    local active = tr:isActive()
    lurek.log.info("active=" .. tostring(active))
end

--@api: LScreenTransition:isActive
do

    local tr = lurek.overlay.newTransition("fade", 1.0, { 0.0, 0.0, 0.0, 1.0 })
    tr:play()
    lurek.log.info("transition isActive=" .. tostring(tr:isActive()))
    lurek.log.info("transition isDone=" .. tostring(tr:isDone()))
    lurek.log.info("transition kind=" .. tr:kind())
    lurek.log.info("transition progress=" .. string.format("%.2f", tr:progress()))
end

--@api: LScreenTransition:isDone
do

    local tr = lurek.overlay.newTransition("fade", 0.2, { 0.0, 0.0, 0.0, 1.0 })
    tr:play()
    tr:update(1.0)
    lurek.log.info("transition isDone=" .. tostring(tr:isDone()))
    lurek.log.info("transition isActive=" .. tostring(tr:isActive()))
    lurek.log.info("transition progress=" .. string.format("%.2f", tr:progress()))
    lurek.log.info("transition type=" .. tr:type())
end

--@api: LScreenTransition:kind
do

    local tr = lurek.overlay.newTransition("iris", 1.0, { 0.0, 0.0, 0.0, 1.0 })
    local r, g, b, a = tr:color()
    lurek.log.info("transition kind=" .. tr:kind())
    lurek.log.info("transition type=" .. tr:type())
    lurek.log.info("transition active=" .. tostring(tr:isActive()))
    lurek.log.info("transition color=" .. string.format("%.2f,%.2f,%.2f,%.2f", r, g, b, a))
end

--@api: LScreenTransition:play
do


    local tr = lurek.overlay.newTransition("fade", 0.5, { 0.0, 0.0, 0.0, 1.0 })
    tr:play()
    lurek.log.info("LScreenTransition:play isActive=" .. tostring(tr:isActive()))
    lurek.log.info("LScreenTransition:play progress=" .. string.format("%.2f", tr:progress()))
    local active = tr:isActive()
    lurek.log.info("active=" .. tostring(active))
end

--@api: LScreenTransition:progress
do


    local tr = lurek.overlay.newTransition("fade", 1.0, { 0.0, 0.0, 0.0, 1.0 })
    tr:play()
    tr:update(0.5)
    lurek.log.info("LScreenTransition:progress=" .. string.format("%.2f", tr:progress()))
    local active = tr:isActive()
    lurek.log.info("active=" .. tostring(active))
end

--@api: LScreenTransition:reverse
do


    local tr = lurek.overlay.newTransition("fade", 1.0, { 0.0, 0.0, 0.0, 1.0 })
    tr:reverse()
    lurek.log.info("LScreenTransition:reverse isActive=" .. tostring(tr:isActive()))
    lurek.log.info("LScreenTransition:reverse progress=" .. string.format("%.2f", tr:progress()))
    local active = tr:isActive()
    lurek.log.info("active=" .. tostring(active))
end

--@api: LScreenTransition:setColor
do


    local tr = lurek.overlay.newTransition("fade", 1.0, { 0.0, 0.0, 0.0, 1.0 })
    tr:setColor({ 0.1, 0.05, 0.2, 1.0 })
    local r, g, b, a = tr:color()
    lurek.log.info("LScreenTransition:setColor=" .. string.format("%.2f,%.2f,%.2f,%.2f", r, g, b, a))
    local active = tr:isActive()
    lurek.log.info("active=" .. tostring(active))
end

--@api: LScreenTransition:type
do

    local tr = lurek.overlay.newTransition("fade", 1.0, { 0.0, 0.0, 0.0, 1.0 })
    local r, g, b, a = tr:color()
    lurek.log.info("transition type=" .. tr:type())
    lurek.log.info("transition kind=" .. tr:kind())
    lurek.log.info("transition active=" .. tostring(tr:isActive()))
    lurek.log.info("transition color=" .. string.format("%.2f,%.2f,%.2f,%.2f", r, g, b, a))
end

--@api: LScreenTransition:typeOf
do

    local tr = lurek.overlay.newTransition("fade", 1.0, { 0.0, 0.0, 0.0, 1.0 })
    lurek.log.info("typeOf LScreenTransition=" .. tostring(tr:typeOf("LScreenTransition")))
    lurek.log.info("typeOf LObject=" .. tostring(tr:typeOf("LObject")))
    lurek.log.info("typeOf LOverlay=" .. tostring(tr:typeOf("LOverlay")))
    lurek.log.info("kind=" .. tr:kind())
end

--@api: LScreenTransition:update
do


    local tr = lurek.overlay.newTransition("fade", 1.0, { 0.0, 0.0, 0.0, 1.0 })
    tr:play()
    local still_active = tr:update(0.016)
    lurek.log.info("LScreenTransition:update active=" .. tostring(still_active))
    lurek.log.info("LScreenTransition:update progress=" .. string.format("%.2f", tr:progress()))
end

--@api: LOverlay:getStats
do

    local ov = lurek.overlay.new(800, 600)
    ov:setWeatherEnabled(true)
    ov:setWeather("rain")
    ov:setWeatherIntensity(0.6)
    ov:triggerFlash(1.0, 1.0, 1.0, 0.7, 0.2)
    local stats = ov:getStats()
    lurek.log.info("overlay stats size=" .. stats.width .. "x" .. stats.height)
    lurek.log.info("overlay stats effects=" .. stats.active_effects .. " weather=" .. tostring(stats.weather_enabled))
end

--@api: LOverlay:setShader
do
    local ov = lurek.overlay.new(800, 600)
    local shader = lurek.render.newShader([[
@fragment
fn fs(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(color.rgb + uv.xyx * 0.0, color.a);
}
]], { target = "overlay" })
    ov:setShader(shader)
    lurek.log.info("[overlay.example] shader bound=" .. tostring(ov:getShader() ~= nil))
end

--@api: LOverlay:getShader
do
    local ov = lurek.overlay.new(800, 600)
    local shader = lurek.render.newShader("@fragment fn fs(@location(0) color: vec4<f32>) -> @location(0) vec4<f32> { return color; }", { target = "overlay" })
    ov:setShader(shader)
    local active = ov:getShader()
    local target = active and active:getTarget() or "nil"
    ov:setShader(nil)
    lurek.log.info("[overlay.example] shader target=" .. target)
end

--@api: LOverlay:setShaderLayer
do
    local ov = lurek.overlay.new(800, 600)
    local shader = lurek.render.newShader([[
@fragment
fn fs(@location(0) color: vec4<f32>) -> @location(0) vec4<f32> {
    return color;
}
]], { target = "overlay" })
    ov:setShaderLayer("heat_haze", shader)
    lurek.log.info("[overlay.example] layer shader=" .. tostring(ov:getShaderLayer("heat_haze") ~= nil))
end

--@api: LOverlay:getShaderLayer
do
    local ov = lurek.overlay.new(800, 600)
    local shader = lurek.render.newShader("@fragment fn fs(@location(0) color: vec4<f32>) -> @location(0) vec4<f32> { return color; }", { target = "overlay" })
    ov:setShaderLayer("heat_haze", shader)
    local active = ov:getShaderLayer("heat_haze")
    local target = active and active:getTarget() or "nil"
    ov:setShaderLayer("heat_haze", nil)
    lurek.log.info("[overlay.example] heat_haze target=" .. target)
end
