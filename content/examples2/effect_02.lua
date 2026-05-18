--- Effect Module Part 3: LOverlay fog, heat haze, vignette, film grain, clouds, weather, wind, lightning, render

--@api-stub: LOverlay:setFogEnabled
-- Enables or disables overlay fog rendering.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setFogEnabled(true)
    print("fog enabled = " .. tostring(ov:isFogEnabled()))
end

--@api-stub: LOverlay:isFogEnabled
-- Returns whether fog rendering is enabled.
do
    local ov = lurek.effect.newOverlay(800, 600)
    print("fog = " .. tostring(ov:isFogEnabled()))
end

--@api-stub: LOverlay:setFogColor
-- Sets the overlay fog RGBA color.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setFogColor(0.5, 0.5, 0.5, 0.8)
    local r, g, b, a = ov:getFogColor()
    print("fog color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LOverlay:getFogColor
-- Returns overlay fog RGBA color.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setFogColor(0.3, 0.3, 0.4, 1.0)
    local r, g, b, a = ov:getFogColor()
    print("fog = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LOverlay:setFogDensity
-- Sets overlay fog density.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setFogDensity(0.7)
    print("fog density = " .. ov:getFogDensity())
end

--@api-stub: LOverlay:getFogDensity
-- Returns overlay fog density.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setFogDensity(0.4)
    print("density = " .. ov:getFogDensity())
end

--@api-stub: LOverlay:setHeatHazeEnabled
-- Enables or disables heat haze rendering.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setHeatHazeEnabled(true)
    print("heat haze on = " .. tostring(ov:isHeatHazeEnabled()))
end

--@api-stub: LOverlay:isHeatHazeEnabled
-- Returns whether heat haze is enabled.
do
    local ov = lurek.effect.newOverlay(800, 600)
    print("heat haze = " .. tostring(ov:isHeatHazeEnabled()))
end

--@api-stub: LOverlay:setHeatHazeIntensity
-- Sets heat haze intensity.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setHeatHazeIntensity(0.5)
    print("heat intensity = " .. ov:getHeatHazeIntensity())
end

--@api-stub: LOverlay:getHeatHazeIntensity
-- Returns heat haze intensity.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setHeatHazeIntensity(0.3)
    print("intensity = " .. ov:getHeatHazeIntensity())
end

--@api-stub: LOverlay:setVignetteEnabled
-- Enables or disables vignette rendering.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setVignetteEnabled(true)
    print("vignette on = " .. tostring(ov:isVignetteEnabled()))
end

--@api-stub: LOverlay:isVignetteEnabled
-- Returns whether vignette is enabled.
do
    local ov = lurek.effect.newOverlay(800, 600)
    print("vignette = " .. tostring(ov:isVignetteEnabled()))
end

--@api-stub: LOverlay:setVignetteStrength
-- Sets vignette strength.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setVignetteStrength(0.6)
    print("vignette strength = " .. ov:getVignetteStrength())
end

--@api-stub: LOverlay:getVignetteStrength
-- Returns vignette strength.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setVignetteStrength(0.4)
    print("strength = " .. ov:getVignetteStrength())
end

--@api-stub: LOverlay:setFilmGrainEnabled
-- Enables or disables film grain rendering.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setFilmGrainEnabled(true)
    print("grain on = " .. tostring(ov:isFilmGrainEnabled()))
end

--@api-stub: LOverlay:isFilmGrainEnabled
-- Returns whether film grain is enabled.
do
    local ov = lurek.effect.newOverlay(800, 600)
    print("grain = " .. tostring(ov:isFilmGrainEnabled()))
end

--@api-stub: LOverlay:setFilmGrainIntensity
-- Sets film grain intensity.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setFilmGrainIntensity(0.2)
    print("grain intensity = " .. ov:getFilmGrainIntensity())
end

--@api-stub: LOverlay:getFilmGrainIntensity
-- Returns film grain intensity.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setFilmGrainIntensity(0.15)
    print("intensity = " .. ov:getFilmGrainIntensity())
end

--@api-stub: LOverlay:setCloudShadows
-- Enables or disables cloud shadow rendering.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setCloudShadows(true)
    print("clouds on = " .. tostring(ov:isCloudShadowsEnabled()))
end

--@api-stub: LOverlay:isCloudShadowsEnabled
-- Returns whether cloud shadows are enabled.
do
    local ov = lurek.effect.newOverlay(800, 600)
    print("clouds = " .. tostring(ov:isCloudShadowsEnabled()))
end

--@api-stub: LOverlay:setCloudCount
-- Sets the cloud shadow count.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setCloudCount(5)
    print("clouds = " .. ov:getCloudCount())
end

--@api-stub: LOverlay:getCloudCount
-- Returns the cloud shadow count.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setCloudCount(3)
    print("count = " .. ov:getCloudCount())
end

--@api-stub: LOverlay:setCloudSpeed
-- Sets cloud shadow movement speed.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setCloudSpeed(0.5)
    print("speed = " .. ov:getCloudSpeed())
end

--@api-stub: LOverlay:getCloudSpeed
-- Returns cloud shadow speed.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setCloudSpeed(1.0)
    print("speed = " .. ov:getCloudSpeed())
end

--@api-stub: LOverlay:setCloudScale
-- Sets cloud shadow scale.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setCloudScale(2.0)
    print("scale = " .. ov:getCloudScale())
end

--@api-stub: LOverlay:getCloudScale
-- Returns cloud shadow scale.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setCloudScale(1.5)
    print("scale = " .. ov:getCloudScale())
end

--@api-stub: LOverlay:setCloudOpacity
-- Sets cloud shadow opacity.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setCloudOpacity(0.6)
    print("opacity = " .. ov:getCloudOpacity())
end

--@api-stub: LOverlay:getCloudOpacity
-- Returns cloud shadow opacity.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setCloudOpacity(0.4)
    print("opacity = " .. ov:getCloudOpacity())
end

--@api-stub: LOverlay:setWeatherEnabled
-- Enables or disables weather rendering.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setWeatherEnabled(true)
    print("weather on = " .. tostring(ov:isWeatherEnabled()))
end

--@api-stub: LOverlay:isWeatherEnabled
-- Returns whether weather is enabled.
do
    local ov = lurek.effect.newOverlay(800, 600)
    print("weather = " .. tostring(ov:isWeatherEnabled()))
end

--@api-stub: LOverlay:setWeather
-- Sets the weather type by name.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setWeather("rain")
    print("weather = " .. ov:getWeather())
end

--@api-stub: LOverlay:getWeather
-- Returns the weather type name.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setWeather("snow")
    print("weather = " .. ov:getWeather())
end

--@api-stub: LOverlay:setWeatherIntensity
-- Sets weather intensity.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setWeatherIntensity(0.8)
    print("intensity = " .. ov:getWeatherIntensity())
end

--@api-stub: LOverlay:getWeatherIntensity
-- Returns weather intensity.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setWeatherIntensity(0.5)
    print("intensity = " .. ov:getWeatherIntensity())
end

--@api-stub: LOverlay:setWindDirection
-- Sets the weather wind direction.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setWindDirection(45)
    print("wind dir = " .. ov:getWindDirection())
end

--@api-stub: LOverlay:getWindDirection
-- Returns the wind direction.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setWindDirection(90)
    print("dir = " .. ov:getWindDirection())
end

--@api-stub: LOverlay:setWindSpeed
-- Sets the weather wind speed.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setWindSpeed(2.5)
    print("wind speed = " .. ov:getWindSpeed())
end

--@api-stub: LOverlay:getWindSpeed
-- Returns the wind speed.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setWindSpeed(1.0)
    print("speed = " .. ov:getWindSpeed())
end

--@api-stub: LOverlay:setLightningColor
-- Sets the lightning RGBA color.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setLightningColor(0.9, 0.9, 1.0, 1.0)
    local r, g, b, a = ov:getLightningColor()
    print("lightning = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LOverlay:getLightningColor
-- Returns the lightning RGBA color.
do
    local ov = lurek.effect.newOverlay(800, 600)
    local r, g, b, a = ov:getLightningColor()
    print("lightning color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LOverlay:isFlashing
-- Returns whether the flash overlay is active.
do
    local ov = lurek.effect.newOverlay(800, 600)
    print("flashing = " .. tostring(ov:isFlashing()))
end

--@api-stub: LOverlay:isShaking
-- Returns whether the screen shake is active.
do
    local ov = lurek.effect.newOverlay(800, 600)
    print("shaking = " .. tostring(ov:isShaking()))
end

--@api-stub: LOverlay:isFading
-- Returns whether the fade overlay is active.
do
    local ov = lurek.effect.newOverlay(800, 600)
    print("fading = " .. tostring(ov:isFading()))
end

--@api-stub: LOverlay:render
-- Queues renderer commands for the overlay's visual state.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:render()
    print("overlay rendered")
end

--@api-stub: LOverlay:flash
-- Starts a short flash overlay.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:flash(1, 1, 1, 0.5, 0.2)
    print("flash started")
end

--@api-stub: LOverlay:shake
-- Starts a screen shake with optional duration.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:shake(3.0, 0.4)
    print("shake started")
end

--@api-stub: LOverlay:fade
-- Starts a fade overlay.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:fade(0, 0, 0, 1.0, 1.0)
    print("fade started")
end

--@api-stub: LOverlay:type
-- Returns the type name ("LOverlay").
do
    local ov = lurek.effect.newOverlay(800, 600)
    print("type = " .. ov:type())
end

--@api-stub: LOverlay:typeOf
-- Returns whether this handle matches a type name.
do
    local ov = lurek.effect.newOverlay(800, 600)
    print("is Overlay = " .. tostring(ov:typeOf("Overlay")))
end

print("effect_02.lua")
