--- @title Overlay Effects
--- @desc Weather, atmosphere, screen flash/shake/fade, and transitions.



--@api: lurek.overlay.new
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ov = lurek.overlay.new(800, 600)
    local w, h = ov:getDimensions()
    overlay_log("new type=" .. ov:type())
    overlay_log("new size=" .. w .. "x" .. h)
    overlay_log("new width=" .. ov:getWidth())
    overlay_log("new height=" .. ov:getHeight())
end

--@api: lurek.overlay.newTransition
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tr = lurek.overlay.newTransition("wipe", 0.75, { 0.05, 0.10, 0.15, 1.0 })
    local r, g, b, a = tr:color()
    overlay_log("newTransition type=" .. tr:type())
    overlay_log("newTransition kind=" .. tr:kind())
    overlay_log("newTransition active=" .. tostring(tr:isActive()))
    overlay_log("newTransition color=" .. string.format("%.2f,%.2f,%.2f,%.2f", r, g, b, a))
end

--@api: LOverlay:clear
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ov = lurek.overlay.new(800, 600)
    ov:triggerFlash(1, 1, 1, 0.5, 0.1)
    example_print_log("LOverlay:clear before=" .. tostring(ov:isActive()))
    ov:clear()
    example_print_log("LOverlay:clear after=" .. tostring(ov:isActive()))
end

--@api: LOverlay:drawToImage
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ov = lurek.overlay.new(200, 150)
    ov:flash(0.9, 0.95, 1.0, 0.6, 0.2)
    local img = ov:drawToImage(200, 150)
    example_print_log("LOverlay:drawToImage type=" .. type(img))
    example_print_log("LOverlay:drawToImage active=" .. tostring(ov:isActive()))
end

--@api: LOverlay:fade
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ov = lurek.overlay.new(800, 600)
    ov:fade(0.05, 0.05, 0.10, 0.85, 0.5)
    ov:update(0.1)
    overlay_log("fade isFading=" .. tostring(ov:isFading()))
    overlay_log("fade active=" .. tostring(ov:isActive()))
    overlay_log("fade flashAlpha=" .. string.format("%.2f", ov:getFlashAlpha()))
    overlay_log("fade dimensions=" .. ov:getWidth() .. "x" .. ov:getHeight())
end

--@api: LOverlay:flash
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:flash(1.0, 0.95, 0.70, 0.8, 0.2)
    example_print_log("LOverlay:flash isFlashing=" .. tostring(ov:isFlashing()))
    example_print_log("LOverlay:flash alpha=" .. f2(ov:getFlashAlpha()))
end

--@api: LOverlay:getAmbientColor
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function rgba_text(r, g, b, a)
        return string.format("(%.2f, %.2f, %.2f, %.2f)", r, g, b, a)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setAmbientColor(0.2, 0.1, 0.3, 0.5)
    local r, g, b, a = ov:getAmbientColor()
    example_print_log("LOverlay:getAmbientColor=" .. rgba_text(r, g, b, a))
end

--@api: LOverlay:getCloudCount
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setCloudCount(8)
    ov:setCloudShadows(true)
    overlay_log("getCloudCount count=" .. ov:getCloudCount())
    overlay_log("getCloudCount enabled=" .. tostring(ov:isCloudShadowsEnabled()))
    overlay_log("getCloudCount width=" .. ov:getWidth())
    overlay_log("getCloudCount height=" .. ov:getHeight())
end

--@api: LOverlay:getCloudOpacity
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setCloudOpacity(0.7)
    example_print_log("LOverlay:getCloudOpacity=" .. f2(ov:getCloudOpacity()))
end

--@api: LOverlay:getCloudScale
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setCloudScale(1.5)
    example_print_log("LOverlay:getCloudScale=" .. f2(ov:getCloudScale()))
end

--@api: LOverlay:getCloudSpeed
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setCloudSpeed(0.3)
    example_print_log("LOverlay:getCloudSpeed=" .. f2(ov:getCloudSpeed()))
end

--@api: LOverlay:getDimensions
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ov = lurek.overlay.new(800, 600)
    local w, h = ov:getDimensions()
    overlay_log("getDimensions=" .. w .. "x" .. h)
    overlay_log("getDimensions width=" .. ov:getWidth())
    overlay_log("getDimensions height=" .. ov:getHeight())
    overlay_log("getDimensions active=" .. tostring(ov:isActive()))
end

--@api: LOverlay:getRenderPlan
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setFogEnabled(true)
    ov:setWater(0.2, 1.0, 0.5)
    ov:setCloudShadows(true)
    ov:setFilmGrainEnabled(true)
    local plan = ov:getRenderPlan()
    overlay_log("rendered layers=" .. tostring(#plan.rendered))
    overlay_log("external layers=" .. tostring(#plan.externally_handled))
    overlay_log("first external=" .. tostring(plan.externally_handled[1]))
end

--@api: LOverlay:getFilmGrainIntensity
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setFilmGrainIntensity(0.4)
    example_print_log("LOverlay:getFilmGrainIntensity=" .. f2(ov:getFilmGrainIntensity()))
end

--@api: LOverlay:getFlashAlpha
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:flash(1, 1, 0, 1.0, 0.5)
    example_print_log("LOverlay:getFlashAlpha=" .. f2(ov:getFlashAlpha()))
end

--@api: LOverlay:getFogColor
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function rgba_text(r, g, b, a)
        return string.format("(%.2f, %.2f, %.2f, %.2f)", r, g, b, a)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setFogColor(0.5, 0.5, 0.5, 0.8)
    local r, g, b, a = ov:getFogColor()
    example_print_log("LOverlay:getFogColor=" .. rgba_text(r, g, b, a))
end

--@api: LOverlay:getFogDensity
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setFogDensity(0.6)
    example_print_log("LOverlay:getFogDensity=" .. f2(ov:getFogDensity()))
end

--@api: LOverlay:getHeatHazeIntensity
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setHeatHazeIntensity(0.4)
    example_print_log("LOverlay:getHeatHazeIntensity=" .. f2(ov:getHeatHazeIntensity()))
end

--@api: LOverlay:getHeight
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ov = lurek.overlay.new(800, 600)
    local w, h = ov:getDimensions()
    overlay_log("getHeight=" .. ov:getHeight())
    overlay_log("dimensions=" .. w .. "x" .. h)
    overlay_log("width getter=" .. ov:getWidth())
    overlay_log("type=" .. ov:type())
end

--@api: LOverlay:getLightningAlpha
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:triggerLightning()
    example_print_log("LOverlay:getLightningAlpha=" .. f2(ov:getLightningAlpha()))
end

--@api: LOverlay:setAccessibilityPolicy
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    overlay_log("reduced motion=" .. tostring(ov:getAccessibilityPolicy().reduced_motion))
    overlay_log("flash alpha after clamp=" .. string.format("%.2f", ov:getFlashAlpha()))
end

--@api: LOverlay:getAccessibilityPolicy
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setAccessibilityPolicy({
        max_flash_alpha = 0.3,
        disable_lightning = true,
        disable_film_grain = true,
    })
    local policy = ov:getAccessibilityPolicy()
    overlay_log("policy flash alpha=" .. string.format("%.2f", policy.max_flash_alpha))
    overlay_log("policy disable lightning=" .. tostring(policy.disable_lightning))
    overlay_log("policy disable grain=" .. tostring(policy.disable_film_grain))
end

--@api: LOverlay:getLightningColor
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function rgba_text(r, g, b, a)
        return string.format("(%.2f, %.2f, %.2f, %.2f)", r, g, b, a)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setLightningColor(0.9, 0.9, 1.0, 1.0)
    local r, g, b, a = ov:getLightningColor()
    example_print_log("LOverlay:getLightningColor=" .. rgba_text(r, g, b, a))
end

--@api: LOverlay:getShakeOffset
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function pair_text(x, y)
        return string.format("(%.2f, %.2f)", x, y)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:shake(5.0, 0.3)
    local ox, oy = ov:getShakeOffset()
    example_print_log("LOverlay:getShakeOffset=" .. pair_text(ox, oy))
end

--@api: LOverlay:getTimeOfDay
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setTimeOfDay(0.75)
    ov:setAmbientEnabled(true)
    local r, g, b, a = ov:getAmbientColor()
    overlay_log("getTimeOfDay=" .. ov:getTimeOfDay())
    overlay_log("ambient enabled=" .. tostring(ov:isAmbientEnabled()))
    overlay_log("ambient color=" .. string.format("%.2f,%.2f,%.2f,%.2f", r, g, b, a))
    overlay_log("active=" .. tostring(ov:isActive()))
end

--@api: LOverlay:getVignetteStrength
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setVignetteStrength(0.6)
    example_print_log("LOverlay:getVignetteStrength=" .. f2(ov:getVignetteStrength()))
end

--@api: LOverlay:getWater
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setWater(0.20, 1.10, 0.35)
    local w = ov:getWater()
    example_print_log("LOverlay:getWater enabled=" .. tostring(w.enabled))
    example_print_log("LOverlay:getWater wave=" .. f2(w.amplitude) .. "," .. f2(w.frequency) .. "," .. f2(w.speed))
end

--@api: LOverlay:getWeather
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setWeather("rain")
    ov:setWeatherEnabled(true)
    ov:setWeatherIntensity(0.6)
    overlay_log("getWeather=" .. ov:getWeather())
    overlay_log("weather enabled=" .. tostring(ov:isWeatherEnabled()))
    overlay_log("weather intensity=" .. string.format("%.2f", ov:getWeatherIntensity()))
    overlay_log("wind speed=" .. string.format("%.2f", ov:getWindSpeed()))
end

--@api: LOverlay:getWeatherIntensity
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setWeatherIntensity(0.7)
    example_print_log("LOverlay:getWeatherIntensity=" .. f2(ov:getWeatherIntensity()))
end

--@api: LOverlay:getWidth
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ov = lurek.overlay.new(800, 600)
    local w, h = ov:getDimensions()
    overlay_log("getWidth=" .. ov:getWidth())
    overlay_log("dimensions=" .. w .. "x" .. h)
    overlay_log("height getter=" .. ov:getHeight())
    overlay_log("type=" .. ov:type())
end

--@api: LOverlay:getWindDirection
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setWindDirection(0.79)
    example_print_log("LOverlay:getWindDirection=" .. f2(ov:getWindDirection()))
end

--@api: LOverlay:getWindSpeed
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setWindSpeed(12.0)
    example_print_log("LOverlay:getWindSpeed=" .. f2(ov:getWindSpeed()))
end

--@api: LOverlay:isActive
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ov = lurek.overlay.new(800, 600)
    ov:triggerFlash(1, 1, 1, 0.5, 0.3)
    overlay_log("isActive after flash=" .. tostring(ov:isActive()))
    overlay_log("isFlashing=" .. tostring(ov:isFlashing()))
    overlay_log("flashAlpha=" .. string.format("%.2f", ov:getFlashAlpha()))
    overlay_log("isFading=" .. tostring(ov:isFading()))
end

--@api: LOverlay:isAmbientEnabled
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setAmbientEnabled(true)
    local r, g, b, a = ov:getAmbientColor()
    overlay_log("isAmbientEnabled=" .. tostring(ov:isAmbientEnabled()))
    overlay_log("ambient color=" .. string.format("%.2f,%.2f,%.2f,%.2f", r, g, b, a))
    overlay_log("width=" .. ov:getWidth())
    overlay_log("height=" .. ov:getHeight())
end

--@api: LOverlay:isCloudShadowsEnabled
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setCloudShadows(true)
    ov:setCloudCount(6)
    overlay_log("isCloudShadowsEnabled=" .. tostring(ov:isCloudShadowsEnabled()))
    overlay_log("cloud count=" .. ov:getCloudCount())
    overlay_log("cloud scale=" .. string.format("%.2f", ov:getCloudScale()))
    overlay_log("cloud speed=" .. string.format("%.2f", ov:getCloudSpeed()))
end

--@api: LOverlay:isFading
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ov = lurek.overlay.new(800, 600)
    ov:triggerFade(0.0, 0.0, 0.0, 1.0, 0.4)
    ov:update(0.1)
    overlay_log("isFading=" .. tostring(ov:isFading()))
    overlay_log("isActive=" .. tostring(ov:isActive()))
    overlay_log("flashAlpha=" .. string.format("%.2f", ov:getFlashAlpha()))
    overlay_log("isFlashing=" .. tostring(ov:isFlashing()))
end

--@api: LOverlay:isFilmGrainEnabled
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setFilmGrainEnabled(true)
    ov:setFilmGrainIntensity(0.35)
    overlay_log("isFilmGrainEnabled=" .. tostring(ov:isFilmGrainEnabled()))
    overlay_log("grain intensity=" .. string.format("%.2f", ov:getFilmGrainIntensity()))
    overlay_log("width=" .. ov:getWidth())
    overlay_log("height=" .. ov:getHeight())
end

--@api: LOverlay:isFlashing
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ov = lurek.overlay.new(800, 600)
    ov:triggerFlash(1, 0, 0, 1.0, 0.5)
    overlay_log("isFlashing=" .. tostring(ov:isFlashing()))
    overlay_log("flash alpha=" .. string.format("%.2f", ov:getFlashAlpha()))
    overlay_log("isActive=" .. tostring(ov:isActive()))
    overlay_log("isFading=" .. tostring(ov:isFading()))
end

--@api: LOverlay:isFogEnabled
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setFogEnabled(true)
    ov:setFogDensity(0.45)
    overlay_log("isFogEnabled=" .. tostring(ov:isFogEnabled()))
    overlay_log("fog density=" .. string.format("%.2f", ov:getFogDensity()))
    overlay_log("fog active=" .. tostring(ov:isActive()))
    overlay_log("dimensions=" .. ov:getWidth() .. "x" .. ov:getHeight())
end

--@api: LOverlay:isHeatHazeEnabled
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setHeatHazeEnabled(true)
    ov:setHeatHazeIntensity(0.25)
    overlay_log("isHeatHazeEnabled=" .. tostring(ov:isHeatHazeEnabled()))
    overlay_log("heat haze intensity=" .. string.format("%.2f", ov:getHeatHazeIntensity()))
    overlay_log("width=" .. ov:getWidth())
    overlay_log("height=" .. ov:getHeight())
end

--@api: LOverlay:isShaking
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ov = lurek.overlay.new(800, 600)
    ov:triggerShake(5.0, 0.5)
    local ox, oy = ov:getShakeOffset()
    overlay_log("isShaking=" .. tostring(ov:isShaking()))
    overlay_log("shake offset=" .. string.format("%.2f,%.2f", ox, oy))
    overlay_log("isActive=" .. tostring(ov:isActive()))
    overlay_log("width=" .. ov:getWidth())
end

--@api: LOverlay:isVignetteEnabled
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setVignetteEnabled(true)
    ov:setVignetteStrength(0.55)
    overlay_log("isVignetteEnabled=" .. tostring(ov:isVignetteEnabled()))
    overlay_log("vignette strength=" .. string.format("%.2f", ov:getVignetteStrength()))
    overlay_log("width=" .. ov:getWidth())
    overlay_log("height=" .. ov:getHeight())
end

--@api: LOverlay:isWeatherEnabled
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setWeatherEnabled(true)
    ov:setWeather("snow")
    ov:setWeatherIntensity(0.5)
    overlay_log("isWeatherEnabled=" .. tostring(ov:isWeatherEnabled()))
    overlay_log("weather=" .. ov:getWeather())
    overlay_log("weather intensity=" .. string.format("%.2f", ov:getWeatherIntensity()))
    overlay_log("wind direction=" .. string.format("%.2f", ov:getWindDirection()))
end

--@api: LOverlay:pullAmbientFromLight
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function rgba_text(r, g, b, a)
        return string.format("(%.2f, %.2f, %.2f, %.2f)", r, g, b, a)
    end

    local source = lurek.overlay.new(800, 600)
    source:setAmbientColor(0.12, 0.18, 0.30, 0.65)
    source:pushAmbientToLight()

    local ov = lurek.overlay.new(800, 600)
    ov:pullAmbientFromLight()
    local r, g, b, a = ov:getAmbientColor()
    example_print_log("LOverlay:pullAmbientFromLight=" .. rgba_text(r, g, b, a))
end

--@api: LOverlay:pushAmbientToLight
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function rgba_text(r, g, b, a)
        return string.format("(%.2f, %.2f, %.2f, %.2f)", r, g, b, a)
    end

    local source = lurek.overlay.new(800, 600)
    source:setAmbientColor(0.30, 0.20, 0.50, 0.40)
    source:pushAmbientToLight()

    local probe = lurek.overlay.new(800, 600)
    probe:pullAmbientFromLight()
    local r, g, b, a = probe:getAmbientColor()
    example_print_log("LOverlay:pushAmbientToLight=" .. rgba_text(r, g, b, a))
end

--@api: LOverlay:render
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:flash(1.0, 1.0, 1.0, 0.5, 0.2)
    ov:render()
    example_print_log("LOverlay:render active=" .. tostring(ov:isActive()))
    example_print_log("LOverlay:render flashAlpha=" .. f2(ov:getFlashAlpha()))
end

--@api: LOverlay:resize
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ov = lurek.overlay.new(800, 600)
    ov:resize(1280, 720)
    local w, h = ov:getDimensions()
    overlay_log("resize=" .. ov:getWidth() .. "x" .. ov:getHeight())
    overlay_log("dimensions=" .. w .. "x" .. h)
    overlay_log("type=" .. ov:type())
    overlay_log("active=" .. tostring(ov:isActive()))
end

--@api: LOverlay:setAmbientColor
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function rgba_text(r, g, b, a)
        return string.format("(%.2f, %.2f, %.2f, %.2f)", r, g, b, a)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setAmbientColor(0.2, 0.1, 0.3, 0.5)
    local r, g, b, a = ov:getAmbientColor()
    example_print_log("LOverlay:setAmbientColor=" .. rgba_text(r, g, b, a))
end

--@api: LOverlay:setAmbientEnabled
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setAmbientEnabled(true)
    local r, g, b, a = ov:getAmbientColor()
    overlay_log("setAmbientEnabled=" .. tostring(ov:isAmbientEnabled()))
    overlay_log("ambient color=" .. string.format("%.2f,%.2f,%.2f,%.2f", r, g, b, a))
    overlay_log("width=" .. ov:getWidth())
    overlay_log("height=" .. ov:getHeight())
end

--@api: LOverlay:setCloudCount
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setCloudCount(12)
    ov:setCloudShadows(true)
    overlay_log("setCloudCount=" .. ov:getCloudCount())
    overlay_log("cloud shadows=" .. tostring(ov:isCloudShadowsEnabled()))
    overlay_log("cloud opacity=" .. string.format("%.2f", ov:getCloudOpacity()))
    overlay_log("cloud speed=" .. string.format("%.2f", ov:getCloudSpeed()))
end

--@api: LOverlay:setCloudOpacity
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setCloudOpacity(0.5)
    example_print_log("LOverlay:setCloudOpacity=" .. f2(ov:getCloudOpacity()))
end

--@api: LOverlay:setCloudScale
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setCloudScale(2.0)
    example_print_log("LOverlay:setCloudScale=" .. f2(ov:getCloudScale()))
end

--@api: LOverlay:setCloudShadows
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setCloudShadows(true)
    ov:setCloudCount(5)
    overlay_log("setCloudShadows=" .. tostring(ov:isCloudShadowsEnabled()))
    overlay_log("cloud count=" .. ov:getCloudCount())
    overlay_log("cloud scale=" .. string.format("%.2f", ov:getCloudScale()))
    overlay_log("cloud opacity=" .. string.format("%.2f", ov:getCloudOpacity()))
end

--@api: LOverlay:setCloudSpeed
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setCloudSpeed(0.5)
    example_print_log("LOverlay:setCloudSpeed=" .. f2(ov:getCloudSpeed()))
end

--@api: LOverlay:setCustomShader
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setCustomShader("scanlines")
    local img_with_shader = ov:drawToImage(96, 64)
    ov:setCustomShader(nil)
    local img_without_shader = ov:drawToImage(96, 64)
    example_print_log("LOverlay:setCustomShader types=" .. type(img_with_shader) .. "," .. type(img_without_shader))
end

--@api: LOverlay:setFilmGrainEnabled
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setFilmGrainEnabled(true)
    ov:setFilmGrainIntensity(0.25)
    overlay_log("setFilmGrainEnabled=" .. tostring(ov:isFilmGrainEnabled()))
    overlay_log("grain intensity=" .. string.format("%.2f", ov:getFilmGrainIntensity()))
    overlay_log("width=" .. ov:getWidth())
    overlay_log("height=" .. ov:getHeight())
end

--@api: LOverlay:setFilmGrainIntensity
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setFilmGrainIntensity(0.3)
    example_print_log("LOverlay:setFilmGrainIntensity=" .. f2(ov:getFilmGrainIntensity()))
end

--@api: LOverlay:setFogColor
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function rgba_text(r, g, b, a)
        return string.format("(%.2f, %.2f, %.2f, %.2f)", r, g, b, a)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setFogColor(0.7, 0.7, 0.8, 0.6)
    local r, g, b, a = ov:getFogColor()
    example_print_log("LOverlay:setFogColor=" .. rgba_text(r, g, b, a))
end

--@api: LOverlay:setFogDensity
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setFogDensity(0.5)
    example_print_log("LOverlay:setFogDensity=" .. f2(ov:getFogDensity()))
end

--@api: LOverlay:setFogEnabled
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setFogEnabled(true)
    ov:setFogDensity(0.5)
    overlay_log("setFogEnabled=" .. tostring(ov:isFogEnabled()))
    overlay_log("fog density=" .. string.format("%.2f", ov:getFogDensity()))
    overlay_log("width=" .. ov:getWidth())
    overlay_log("height=" .. ov:getHeight())
end

--@api: LOverlay:setHeatHazeEnabled
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setHeatHazeEnabled(true)
    ov:setHeatHazeIntensity(0.4)
    overlay_log("setHeatHazeEnabled=" .. tostring(ov:isHeatHazeEnabled()))
    overlay_log("heat haze intensity=" .. string.format("%.2f", ov:getHeatHazeIntensity()))
    overlay_log("width=" .. ov:getWidth())
    overlay_log("height=" .. ov:getHeight())
end

--@api: LOverlay:setHeatHazeIntensity
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setHeatHazeIntensity(0.5)
    example_print_log("LOverlay:setHeatHazeIntensity=" .. f2(ov:getHeatHazeIntensity()))
end

--@api: LOverlay:setLightningColor
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function rgba_text(r, g, b, a)
        return string.format("(%.2f, %.2f, %.2f, %.2f)", r, g, b, a)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setLightningColor(1.0, 1.0, 0.8, 1.0)
    local r, g, b, a = ov:getLightningColor()
    example_print_log("LOverlay:setLightningColor=" .. rgba_text(r, g, b, a))
end

--@api: LOverlay:setTimeOfDay
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setTimeOfDay(0.5)
    local r, g, b, a = ov:getAmbientColor()
    overlay_log("setTimeOfDay=" .. ov:getTimeOfDay())
    overlay_log("ambient color=" .. string.format("%.2f,%.2f,%.2f,%.2f", r, g, b, a))
    overlay_log("ambient enabled=" .. tostring(ov:isAmbientEnabled()))
    overlay_log("active=" .. tostring(ov:isActive()))
end

--@api: LOverlay:setVignetteEnabled
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setVignetteEnabled(true)
    ov:setVignetteStrength(0.6)
    overlay_log("setVignetteEnabled=" .. tostring(ov:isVignetteEnabled()))
    overlay_log("vignette strength=" .. string.format("%.2f", ov:getVignetteStrength()))
    overlay_log("width=" .. ov:getWidth())
    overlay_log("height=" .. ov:getHeight())
end

--@api: LOverlay:setVignetteStrength
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setVignetteStrength(0.7)
    example_print_log("LOverlay:setVignetteStrength=" .. f2(ov:getVignetteStrength()))
end

--@api: LOverlay:setWater
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setWater(0.25, 1.25, 0.60)
    local w = ov:getWater()
    example_print_log("LOverlay:setWater enabled=" .. tostring(w.enabled))
    example_print_log("LOverlay:setWater wave=" .. f2(w.amplitude) .. "," .. f2(w.frequency) .. "," .. f2(w.speed))
end

--@api: LOverlay:setWaterTint
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setWater(0.20, 1.10, 0.35)
    ov:setWaterTint(0.1, 0.3, 0.7, 0.8)
    local w = ov:getWater()
    example_print_log("LOverlay:setWaterTint tint=" .. f2(w.tint_r) .. "," .. f2(w.tint_g) .. "," .. f2(w.tint_b) .. "," .. f2(w.tint_strength))
end

--@api: LOverlay:setWeather
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setWeather("snow")
    ov:setWeatherEnabled(true)
    ov:setWeatherIntensity(0.7)
    overlay_log("setWeather=" .. ov:getWeather())
    overlay_log("weather enabled=" .. tostring(ov:isWeatherEnabled()))
    overlay_log("weather intensity=" .. string.format("%.2f", ov:getWeatherIntensity()))
    overlay_log("wind speed=" .. string.format("%.2f", ov:getWindSpeed()))
end

--@api: LOverlay:setWeatherEnabled
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setWeatherEnabled(true)
    ov:setWeather("rain")
    ov:setWeatherIntensity(0.8)
    overlay_log("setWeatherEnabled=" .. tostring(ov:isWeatherEnabled()))
    overlay_log("weather=" .. ov:getWeather())
    overlay_log("weather intensity=" .. string.format("%.2f", ov:getWeatherIntensity()))
    overlay_log("wind direction=" .. string.format("%.2f", ov:getWindDirection()))
end

--@api: LOverlay:setWeatherIntensity
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setWeatherIntensity(0.8)
    example_print_log("LOverlay:setWeatherIntensity=" .. f2(ov:getWeatherIntensity()))
end

--@api: LOverlay:setWeatherSeed
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setWeatherSeed(123456789)
    overlay_log("weather seed state=" .. tostring(ov:getWeatherRngState()))
    ov:setWeatherEnabled(true)
    overlay_log("weather enabled=" .. tostring(ov:isWeatherEnabled()))
end

--@api: LOverlay:getWeatherRngState
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setWeatherSeed(246813579)
    local state = ov:getWeatherRngState()
    overlay_log("weather rng state=" .. tostring(state))
    overlay_log("weather type=" .. tostring(ov:getWeather()))
end

--@api: LOverlay:setWeatherRngState
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setWeatherRngState(987654321)
    overlay_log("weather rng state=" .. tostring(ov:getWeatherRngState()))
    ov:setWeather("rain")
    overlay_log("overlay type=" .. tostring(ov:type()))
end

--@api: LOverlay:setWindDirection
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setWindDirection(1.57)
    example_print_log("LOverlay:setWindDirection=" .. f2(ov:getWindDirection()))
end

--@api: LOverlay:setWindSpeed
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setWindSpeed(8.0)
    example_print_log("LOverlay:setWindSpeed=" .. f2(ov:getWindSpeed()))
end

--@api: LOverlay:shake
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ov = lurek.overlay.new(800, 600)
    ov:shake(8.0, 0.4)
    local ox, oy = ov:getShakeOffset()
    overlay_log("shake isShaking=" .. tostring(ov:isShaking()))
    overlay_log("shake offset=" .. string.format("%.2f,%.2f", ox, oy))
    overlay_log("shake active=" .. tostring(ov:isActive()))
    overlay_log("shake height=" .. ov:getHeight())
end

--@api: LOverlay:syncAmbientWithLight
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function rgba_text(r, g, b, a)
        return string.format("(%.2f, %.2f, %.2f, %.2f)", r, g, b, a)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setAmbientColor(0.20, 0.10, 0.40, 0.60)
    ov:syncAmbientWithLight("overlay")

    local probe = lurek.overlay.new(800, 600)
    probe:pullAmbientFromLight()
    local r, g, b, a = probe:getAmbientColor()
    example_print_log("LOverlay:syncAmbientWithLight=" .. rgba_text(r, g, b, a))
end

--@api: LOverlay:triggerFade
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ov = lurek.overlay.new(800, 600)
    ov:triggerFade(1.0, 0, 0, 0, 0.2)
    ov:update(0.05)
    overlay_log("triggerFade isFading=" .. tostring(ov:isFading()))
    overlay_log("triggerFade active=" .. tostring(ov:isActive()))
    overlay_log("triggerFade isFlashing=" .. tostring(ov:isFlashing()))
    overlay_log("triggerFade width=" .. ov:getWidth())
end

--@api: LOverlay:triggerFlash
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ov = lurek.overlay.new(800, 600)
    ov:triggerFlash(1, 1, 0, 1.0, 0.2)
    overlay_log("triggerFlash isFlashing=" .. tostring(ov:isFlashing()))
    overlay_log("triggerFlash alpha=" .. string.format("%.2f", ov:getFlashAlpha()))
    overlay_log("triggerFlash active=" .. tostring(ov:isActive()))
    overlay_log("triggerFlash type=" .. ov:type())
end

--@api: LOverlay:triggerLightning
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function f2(value)
        return string.format("%.2f", value)
    end

    local ov = lurek.overlay.new(800, 600)
    ov:triggerLightning()
    example_print_log("LOverlay:triggerLightning alpha=" .. f2(ov:getLightningAlpha()))
end

--@api: LOverlay:triggerShake
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ov = lurek.overlay.new(800, 600)
    ov:triggerShake(6.0, 0.3)
    local ox, oy = ov:getShakeOffset()
    overlay_log("triggerShake isShaking=" .. tostring(ov:isShaking()))
    overlay_log("triggerShake offset=" .. string.format("%.2f,%.2f", ox, oy))
    overlay_log("triggerShake active=" .. tostring(ov:isActive()))
    overlay_log("triggerShake width=" .. ov:getWidth())
end

--@api: LOverlay:type
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ov = lurek.overlay.new(800, 600)
    local w, h = ov:getDimensions()
    overlay_log("type=" .. ov:type())
    overlay_log("dimensions=" .. w .. "x" .. h)
    overlay_log("active=" .. tostring(ov:isActive()))
    overlay_log("typeOf overlay=" .. tostring(ov:typeOf("LOverlay")))
end

--@api: LOverlay:typeOf
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ov = lurek.overlay.new(800, 600)
    overlay_log("typeOf LOverlay=" .. tostring(ov:typeOf("LOverlay")))
    overlay_log("overlay width=" .. tostring(ov:getWidth()))
    overlay_log("typeOf LScreenTransition=" .. tostring(ov:typeOf("LScreenTransition")))
    overlay_log("dimensions=" .. ov:getWidth() .. "x" .. ov:getHeight())
end

--@api: LOverlay:update
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ov = lurek.overlay.new(800, 600)
    ov:triggerShake(5.0, 1.0)
    ov:update(0.016)
    local ox, oy = ov:getShakeOffset()
    overlay_log("update isShaking=" .. tostring(ov:isShaking()))
    overlay_log("update offset=" .. string.format("%.2f,%.2f", ox, oy))
    overlay_log("update active=" .. tostring(ov:isActive()))
    overlay_log("update width=" .. ov:getWidth())
end

--@api: LScreenTransition:color
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function rgba_text(r, g, b, a)
        return string.format("(%.2f, %.2f, %.2f, %.2f)", r, g, b, a)
    end

    local tr = lurek.overlay.newTransition("fade", 1.0, { 0.0, 0.0, 0.0, 1.0 })
    local r, g, b, a = tr:color()
    example_print_log("LScreenTransition:color=" .. rgba_text(r, g, b, a))
end

--@api: LScreenTransition:isActive
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tr = lurek.overlay.newTransition("fade", 1.0, { 0.0, 0.0, 0.0, 1.0 })
    tr:play()
    overlay_log("transition isActive=" .. tostring(tr:isActive()))
    overlay_log("transition isDone=" .. tostring(tr:isDone()))
    overlay_log("transition kind=" .. tr:kind())
    overlay_log("transition progress=" .. string.format("%.2f", tr:progress()))
end

--@api: LScreenTransition:isDone
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tr = lurek.overlay.newTransition("fade", 0.2, { 0.0, 0.0, 0.0, 1.0 })
    tr:play()
    tr:update(1.0)
    overlay_log("transition isDone=" .. tostring(tr:isDone()))
    overlay_log("transition isActive=" .. tostring(tr:isActive()))
    overlay_log("transition progress=" .. string.format("%.2f", tr:progress()))
    overlay_log("transition type=" .. tr:type())
end

--@api: LScreenTransition:kind
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tr = lurek.overlay.newTransition("iris", 1.0, { 0.0, 0.0, 0.0, 1.0 })
    local r, g, b, a = tr:color()
    overlay_log("transition kind=" .. tr:kind())
    overlay_log("transition type=" .. tr:type())
    overlay_log("transition active=" .. tostring(tr:isActive()))
    overlay_log("transition color=" .. string.format("%.2f,%.2f,%.2f,%.2f", r, g, b, a))
end

--@api: LScreenTransition:play
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function f2(value)
        return string.format("%.2f", value)
    end

    local tr = lurek.overlay.newTransition("fade", 0.5, { 0.0, 0.0, 0.0, 1.0 })
    tr:play()
    example_print_log("LScreenTransition:play isActive=" .. tostring(tr:isActive()))
    example_print_log("LScreenTransition:play progress=" .. f2(tr:progress()))
end

--@api: LScreenTransition:progress
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function f2(value)
        return string.format("%.2f", value)
    end

    local tr = lurek.overlay.newTransition("fade", 1.0, { 0.0, 0.0, 0.0, 1.0 })
    tr:play()
    tr:update(0.5)
    example_print_log("LScreenTransition:progress=" .. f2(tr:progress()))
end

--@api: LScreenTransition:reverse
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function f2(value)
        return string.format("%.2f", value)
    end

    local tr = lurek.overlay.newTransition("fade", 1.0, { 0.0, 0.0, 0.0, 1.0 })
    tr:reverse()
    example_print_log("LScreenTransition:reverse isActive=" .. tostring(tr:isActive()))
    example_print_log("LScreenTransition:reverse progress=" .. f2(tr:progress()))
end

--@api: LScreenTransition:setColor
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function rgba_text(r, g, b, a)
        return string.format("(%.2f, %.2f, %.2f, %.2f)", r, g, b, a)
    end

    local tr = lurek.overlay.newTransition("fade", 1.0, { 0.0, 0.0, 0.0, 1.0 })
    tr:setColor({ 0.1, 0.05, 0.2, 1.0 })
    local r, g, b, a = tr:color()
    example_print_log("LScreenTransition:setColor=" .. rgba_text(r, g, b, a))
end

--@api: LScreenTransition:type
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tr = lurek.overlay.newTransition("fade", 1.0, { 0.0, 0.0, 0.0, 1.0 })
    local r, g, b, a = tr:color()
    overlay_log("transition type=" .. tr:type())
    overlay_log("transition kind=" .. tr:kind())
    overlay_log("transition active=" .. tostring(tr:isActive()))
    overlay_log("transition color=" .. string.format("%.2f,%.2f,%.2f,%.2f", r, g, b, a))
end

--@api: LScreenTransition:typeOf
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tr = lurek.overlay.newTransition("fade", 1.0, { 0.0, 0.0, 0.0, 1.0 })
    overlay_log("typeOf LScreenTransition=" .. tostring(tr:typeOf("LScreenTransition")))
    overlay_log("typeOf LObject=" .. tostring(tr:typeOf("LObject")))
    overlay_log("typeOf LOverlay=" .. tostring(tr:typeOf("LOverlay")))
    overlay_log("kind=" .. tr:kind())
end

--@api: LScreenTransition:update
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function f2(value)
        return string.format("%.2f", value)
    end

    local tr = lurek.overlay.newTransition("fade", 1.0, { 0.0, 0.0, 0.0, 1.0 })
    tr:play()
    local still_active = tr:update(0.016)
    example_print_log("LScreenTransition:update active=" .. tostring(still_active))
    example_print_log("LScreenTransition:update progress=" .. f2(tr:progress()))
end

--@api: LOverlay:getStats
do
    local function overlay_log(message)
        lurek.log.info("[overlay.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ov = lurek.overlay.new(800, 600)
    ov:setWeatherEnabled(true)
    ov:setWeather("rain")
    ov:setWeatherIntensity(0.6)
    ov:triggerFlash(1.0, 1.0, 1.0, 0.7, 0.2)
    local stats = ov:getStats()
    example_print_log("overlay stats size=" .. stats.width .. "x" .. stats.height)
    example_print_log("overlay stats effects=" .. stats.active_effects .. " weather=" .. tostring(stats.weather_enabled))
end
