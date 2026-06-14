-- Canonical unit coverage for lurek.overlay.

local function new_overlay(width, height)
    return lurek.overlay.new(width, height)
end

local function new_transition(kind, duration, color)
    return lurek.overlay.newTransition(kind, duration, color)
end

local function expect_rgba(r, g, b, a, er, eg, eb, ea)
    expect_near(er, r, 0.0001)
    expect_near(eg, g, 0.0001)
    expect_near(eb, b, 0.0001)
    expect_near(ea, a, 0.0001)
end

-- @describe lurek.overlay module
describe("lurek.overlay module", function()
    -- @covers lurek.overlay.new
    it("new creates an overlay with default dimensions", function()
        local overlay = lurek.overlay.new()
        local w, h = overlay:getDimensions()
        expect_equal("userdata", type(overlay))
        expect_equal(800, w)
        expect_equal(600, h)
    end)

    -- @covers lurek.overlay.newTransition
    it("newTransition creates a transition with the requested kind", function()
        local transition = new_transition("fade", 0.5, { 0.1, 0.2, 0.3, 0.4 })
        expect_equal("userdata", type(transition))
        expect_equal("fade", transition:kind())
    end)
end)

-- @describe overlay methods
describe("overlay methods", function()
    -- @covers LOverlay:triggerFlash
    it("triggerFlash activates a flash effect", function()
        local overlay = new_overlay(320, 240)
        overlay:triggerFlash(1.0, 0.5, 0.25, 0.75, 0.5)
        expect_true(overlay:isActive())
    end)

    -- @covers LOverlay:triggerShake
    it("triggerShake activates a shake effect", function()
        local overlay = new_overlay(320, 240)
        overlay:triggerShake(4.0, 0.5)
        expect_true(overlay:isActive())
    end)

    -- @covers LOverlay:triggerFade
    it("triggerFade activates a fade effect", function()
        local overlay = new_overlay(320, 240)
        overlay:triggerFade(0.1, 0.2, 0.3, 0.9, 0.5)
        expect_true(overlay:isActive())
    end)

    -- @covers LOverlay:triggerLightning
    it("triggerLightning raises lightning alpha", function()
        local overlay = new_overlay(320, 240)
        overlay:triggerLightning()
        expect_true(overlay:getLightningAlpha() > 0.0)
    end)

    -- @covers LOverlay:getShakeOffset
    it("getShakeOffset returns numeric offsets", function()
        local overlay = new_overlay(320, 240)
        overlay:triggerShake(4.0, 0.5)
        overlay:update(0.05)
        local x, y = overlay:getShakeOffset()
        expect_type("number", x)
        expect_type("number", y)
    end)

    -- @covers LOverlay:isActive
    it("isActive is false by default and true after an effect starts", function()
        local overlay = new_overlay(320, 240)
        expect_false(overlay:isActive())
        overlay:flash(1.0, 1.0, 1.0, 0.5, 0.2)
        expect_true(overlay:isActive())
    end)

    -- @covers LOverlay:getStats
    it("getStats returns clamped telemetry for active overlay state", function()
        local overlay = new_overlay(320, 240)
        overlay:setWeatherEnabled(true)
        overlay:setWeather("rain")
        overlay:setWeatherIntensity(0.75)
        overlay:setFogEnabled(true)
        overlay:triggerFlash(1.0, 1.0, 1.0, 0.6, 0.5)
        overlay:update(0.1)
        local stats = overlay:getStats()
        expect_type("table", stats)
        expect_equal(320, stats.width)
        expect_equal(240, stats.height)
        expect_true(stats.flash_alpha > 0.0)
        expect_true(stats.weather_enabled)
        expect_true(stats.fog_enabled)
        expect_true(stats.active_effects >= 3)
        expect_true(stats.weather_particle_limit >= stats.weather_particle_count)
    end)

    -- @covers LOverlay:getWidth
    it("getWidth returns the overlay width", function()
        expect_equal(640, new_overlay(640, 360):getWidth())
    end)

    -- @covers LOverlay:getHeight
    it("getHeight returns the overlay height", function()
        expect_equal(360, new_overlay(640, 360):getHeight())
    end)

    -- @covers LOverlay:getDimensions
    it("getDimensions returns overlay width and height", function()
        local w, h = new_overlay(512, 288):getDimensions()
        expect_equal(512, w)
        expect_equal(288, h)
    end)

    -- @covers LOverlay:getFlashAlpha
    it("getFlashAlpha reflects an active flash", function()
        local overlay = new_overlay(320, 240)
        overlay:triggerFlash(1.0, 1.0, 1.0, 0.8, 0.5)
        expect_true(overlay:getFlashAlpha() > 0.0)
    end)

    -- @covers LOverlay:getLightningAlpha
    it("getLightningAlpha starts at zero and rises after lightning", function()
        local overlay = new_overlay(320, 240)
        expect_near(0.0, overlay:getLightningAlpha(), 0.0001)
        overlay:triggerLightning()
        expect_true(overlay:getLightningAlpha() > 0.0)
    end)

    -- @covers LOverlay:isAmbientEnabled
    it("isAmbientEnabled reflects the ambient enabled flag", function()
        local overlay = new_overlay(320, 240)
        overlay:setAmbientEnabled(true)
        expect_true(overlay:isAmbientEnabled())
    end)

    -- @covers LOverlay:setAmbientColor
    it("setAmbientColor updates overlay ambient rgba state", function()
        local overlay = new_overlay(320, 240)
        overlay:setAmbientColor(0.1, 0.2, 0.3, 0.4)
        local r, g, b, a = overlay:getAmbientColor()
        expect_rgba(r, g, b, a, 0.1, 0.2, 0.3, 0.4)
    end)

    -- @covers LOverlay:getAmbientColor
    it("getAmbientColor returns the stored ambient color", function()
        local overlay = new_overlay(320, 240)
        overlay:setAmbientColor(0.25, 0.35, 0.45, 0.55)
        local r, g, b, a = overlay:getAmbientColor()
        expect_rgba(r, g, b, a, 0.25, 0.35, 0.45, 0.55)
    end)

    -- @covers LOverlay:pullAmbientFromLight
    it("pullAmbientFromLight copies ambient color from the light world", function()
        local overlay = new_overlay(320, 240)
        lurek.light.setAmbient(0.2, 0.3, 0.4, 0.9)
        overlay:pullAmbientFromLight()
        local r, g, b, a = overlay:getAmbientColor()
        expect_rgba(r, g, b, a, 0.2, 0.3, 0.4, 0.9)
    end)

    -- @covers LOverlay:pushAmbientToLight
    it("pushAmbientToLight copies overlay ambient color to the light world", function()
        local overlay = new_overlay(320, 240)
        overlay:setAmbientColor(0.6, 0.5, 0.4, 0.8)
        overlay:pushAmbientToLight()
        local r, g, b, a = lurek.light.getAmbient()
        expect_rgba(r, g, b, a, 0.6, 0.5, 0.4, 0.8)
    end)

    -- @covers LOverlay:syncAmbientWithLight
    it("syncAmbientWithLight with overlay mode propagates overlay ambient to light", function()
        local overlay = new_overlay(320, 240)
        lurek.light.setAmbient(0.1, 0.1, 0.1, 1.0)
        overlay:setAmbientColor(0.7, 0.6, 0.5, 0.4)
        overlay:syncAmbientWithLight("overlay")
        local r, g, b, a = lurek.light.getAmbient()
        expect_rgba(r, g, b, a, 0.7, 0.6, 0.5, 0.4)
    end)

    -- @covers LOverlay:setTimeOfDay
    it("setTimeOfDay updates the stored time-of-day value", function()
        local overlay = new_overlay(320, 240)
        overlay:setTimeOfDay(18.5)
        expect_near(18.5, overlay:getTimeOfDay(), 0.0001)
    end)

    -- @covers LOverlay:getTimeOfDay
    it("getTimeOfDay returns the current time-of-day value", function()
        local overlay = new_overlay(320, 240)
        overlay:setTimeOfDay(7.25)
        expect_near(7.25, overlay:getTimeOfDay(), 0.0001)
    end)

    -- @covers LOverlay:setFogEnabled
    it("setFogEnabled toggles fog rendering", function()
        local overlay = new_overlay(320, 240)
        overlay:setFogEnabled(true)
        expect_true(overlay:isFogEnabled())
    end)

    -- @covers LOverlay:isFogEnabled
    it("isFogEnabled reflects the fog enabled flag", function()
        local overlay = new_overlay(320, 240)
        overlay:setFogEnabled(true)
        expect_true(overlay:isFogEnabled())
    end)

    -- @covers LOverlay:setFogDensity
    it("setFogDensity updates the fog density", function()
        local overlay = new_overlay(320, 240)
        overlay:setFogDensity(0.45)
        expect_near(0.45, overlay:getFogDensity(), 0.0001)
    end)

    -- @covers LOverlay:getFogDensity
    it("getFogDensity returns the stored fog density", function()
        local overlay = new_overlay(320, 240)
        overlay:setFogDensity(0.3)
        expect_near(0.3, overlay:getFogDensity(), 0.0001)
    end)

    -- @covers LOverlay:getFogColor
    it("getFogColor returns the stored fog color", function()
        local overlay = new_overlay(320, 240)
        overlay:setFogColor(0.4, 0.5, 0.6, 0.7)
        local r, g, b, a = overlay:getFogColor()
        expect_rgba(r, g, b, a, 0.4, 0.5, 0.6, 0.7)
    end)

    -- @covers LOverlay:setHeatHazeEnabled
    it("setHeatHazeEnabled toggles heat haze rendering", function()
        local overlay = new_overlay(320, 240)
        overlay:setHeatHazeEnabled(true)
        expect_true(overlay:isHeatHazeEnabled())
    end)

    -- @covers LOverlay:isHeatHazeEnabled
    it("isHeatHazeEnabled reflects the heat haze flag", function()
        local overlay = new_overlay(320, 240)
        overlay:setHeatHazeEnabled(true)
        expect_true(overlay:isHeatHazeEnabled())
    end)

    -- @covers LOverlay:setHeatHazeIntensity
    it("setHeatHazeIntensity updates the heat haze intensity", function()
        local overlay = new_overlay(320, 240)
        overlay:setHeatHazeIntensity(0.35)
        expect_near(0.35, overlay:getHeatHazeIntensity(), 0.0001)
    end)

    -- @covers LOverlay:getHeatHazeIntensity
    it("getHeatHazeIntensity returns the stored intensity", function()
        local overlay = new_overlay(320, 240)
        overlay:setHeatHazeIntensity(0.2)
        expect_near(0.2, overlay:getHeatHazeIntensity(), 0.0001)
    end)

    -- @covers LOverlay:setVignetteEnabled
    it("setVignetteEnabled toggles vignette rendering", function()
        local overlay = new_overlay(320, 240)
        overlay:setVignetteEnabled(true)
        expect_true(overlay:isVignetteEnabled())
    end)

    -- @covers LOverlay:isVignetteEnabled
    it("isVignetteEnabled reflects the vignette flag", function()
        local overlay = new_overlay(320, 240)
        overlay:setVignetteEnabled(true)
        expect_true(overlay:isVignetteEnabled())
    end)

    -- @covers LOverlay:setVignetteStrength
    it("setVignetteStrength updates the vignette strength", function()
        local overlay = new_overlay(320, 240)
        overlay:setVignetteStrength(0.65)
        expect_near(0.65, overlay:getVignetteStrength(), 0.0001)
    end)

    -- @covers LOverlay:getVignetteStrength
    it("getVignetteStrength returns the stored strength", function()
        local overlay = new_overlay(320, 240)
        overlay:setVignetteStrength(0.4)
        expect_near(0.4, overlay:getVignetteStrength(), 0.0001)
    end)

    -- @covers LOverlay:setFilmGrainEnabled
    it("setFilmGrainEnabled toggles film grain rendering", function()
        local overlay = new_overlay(320, 240)
        overlay:setFilmGrainEnabled(true)
        expect_true(overlay:isFilmGrainEnabled())
    end)

    -- @covers LOverlay:isFilmGrainEnabled
    it("isFilmGrainEnabled reflects the film grain flag", function()
        local overlay = new_overlay(320, 240)
        overlay:setFilmGrainEnabled(true)
        expect_true(overlay:isFilmGrainEnabled())
    end)

    -- @covers LOverlay:setFilmGrainIntensity
    it("setFilmGrainIntensity updates the film grain intensity", function()
        local overlay = new_overlay(320, 240)
        overlay:setFilmGrainIntensity(0.22)
        expect_near(0.22, overlay:getFilmGrainIntensity(), 0.0001)
    end)

    -- @covers LOverlay:getFilmGrainIntensity
    it("getFilmGrainIntensity returns the stored grain intensity", function()
        local overlay = new_overlay(320, 240)
        overlay:setFilmGrainIntensity(0.18)
        expect_near(0.18, overlay:getFilmGrainIntensity(), 0.0001)
    end)

    -- @covers LOverlay:setCloudShadows
    it("setCloudShadows toggles cloud shadow rendering", function()
        local overlay = new_overlay(320, 240)
        overlay:setCloudShadows(true)
        expect_true(overlay:isCloudShadowsEnabled())
    end)

    -- @covers LOverlay:isCloudShadowsEnabled
    it("isCloudShadowsEnabled reflects the cloud shadow flag", function()
        local overlay = new_overlay(320, 240)
        overlay:setCloudShadows(true)
        expect_true(overlay:isCloudShadowsEnabled())
    end)

    -- @covers LOverlay:setCloudCount
    it("setCloudCount updates the cloud count", function()
        local overlay = new_overlay(320, 240)
        overlay:setCloudCount(6)
        expect_equal(6, overlay:getCloudCount())
    end)

    -- @covers LOverlay:getCloudCount
    it("getCloudCount returns the stored cloud count", function()
        local overlay = new_overlay(320, 240)
        overlay:setCloudCount(4)
        expect_equal(4, overlay:getCloudCount())
    end)

    -- @covers LOverlay:setCloudSpeed
    it("setCloudSpeed updates the cloud speed", function()
        local overlay = new_overlay(320, 240)
        overlay:setCloudSpeed(1.5)
        expect_near(1.5, overlay:getCloudSpeed(), 0.0001)
    end)

    -- @covers LOverlay:getCloudSpeed
    it("getCloudSpeed returns the stored cloud speed", function()
        local overlay = new_overlay(320, 240)
        overlay:setCloudSpeed(0.75)
        expect_near(0.75, overlay:getCloudSpeed(), 0.0001)
    end)

    -- @covers LOverlay:setCloudScale
    it("setCloudScale updates the cloud scale", function()
        local overlay = new_overlay(320, 240)
        overlay:setCloudScale(2.0)
        expect_near(2.0, overlay:getCloudScale(), 0.0001)
    end)

    -- @covers LOverlay:getCloudScale
    it("getCloudScale returns the stored cloud scale", function()
        local overlay = new_overlay(320, 240)
        overlay:setCloudScale(1.25)
        expect_near(1.25, overlay:getCloudScale(), 0.0001)
    end)

    -- @covers LOverlay:setCloudOpacity
    it("setCloudOpacity updates the cloud opacity", function()
        local overlay = new_overlay(320, 240)
        overlay:setCloudOpacity(0.55)
        expect_near(0.55, overlay:getCloudOpacity(), 0.0001)
    end)

    -- @covers LOverlay:getCloudOpacity
    it("getCloudOpacity returns the stored cloud opacity", function()
        local overlay = new_overlay(320, 240)
        overlay:setCloudOpacity(0.35)
        expect_near(0.35, overlay:getCloudOpacity(), 0.0001)
    end)

    -- @covers LOverlay:setWeatherEnabled
    it("setWeatherEnabled toggles weather rendering", function()
        local overlay = new_overlay(320, 240)
        overlay:setWeatherEnabled(true)
        expect_true(overlay:isWeatherEnabled())
    end)

    -- @covers LOverlay:isWeatherEnabled
    it("isWeatherEnabled reflects the weather flag", function()
        local overlay = new_overlay(320, 240)
        overlay:setWeatherEnabled(true)
        expect_true(overlay:isWeatherEnabled())
    end)

    -- @covers LOverlay:setWeather
    it("setWeather accepts known names and rejects unknown ones", function()
        local overlay = new_overlay(320, 240)
        overlay:setWeather("snow")
        expect_equal("snow", overlay:getWeather())
        expect_error(function()
            overlay:setWeather("stormfront")
        end)
    end)

    -- @covers LOverlay:getWeather
    it("getWeather returns the stored weather name", function()
        local overlay = new_overlay(320, 240)
        overlay:setWeather("rain")
        expect_equal("rain", overlay:getWeather())
    end)

    -- @covers LOverlay:setWeatherIntensity
    it("setWeatherIntensity updates the weather intensity", function()
        local overlay = new_overlay(320, 240)
        overlay:setWeatherIntensity(0.8)
        expect_near(0.8, overlay:getWeatherIntensity(), 0.0001)
    end)

    -- @covers LOverlay:getWeatherIntensity
    it("getWeatherIntensity returns the stored intensity", function()
        local overlay = new_overlay(320, 240)
        overlay:setWeatherIntensity(0.45)
        expect_near(0.45, overlay:getWeatherIntensity(), 0.0001)
    end)

    -- @covers LOverlay:setWindDirection
    it("setWindDirection updates the wind direction", function()
        local overlay = new_overlay(320, 240)
        overlay:setWindDirection(135.0)
        expect_near(135.0, overlay:getWindDirection(), 0.0001)
    end)

    -- @covers LOverlay:getWindDirection
    it("getWindDirection returns the stored wind direction", function()
        local overlay = new_overlay(320, 240)
        overlay:setWindDirection(45.0)
        expect_near(45.0, overlay:getWindDirection(), 0.0001)
    end)

    -- @covers LOverlay:setWindSpeed
    it("setWindSpeed updates the wind speed", function()
        local overlay = new_overlay(320, 240)
        overlay:setWindSpeed(2.25)
        expect_near(2.25, overlay:getWindSpeed(), 0.0001)
    end)

    -- @covers LOverlay:getWindSpeed
    it("getWindSpeed returns the stored wind speed", function()
        local overlay = new_overlay(320, 240)
        overlay:setWindSpeed(1.1)
        expect_near(1.1, overlay:getWindSpeed(), 0.0001)
    end)

    -- @covers LOverlay:setLightningColor
    it("setLightningColor updates the lightning rgba state", function()
        local overlay = new_overlay(320, 240)
        overlay:setLightningColor(0.9, 0.8, 0.7, 0.6)
        local r, g, b, a = overlay:getLightningColor()
        expect_rgba(r, g, b, a, 0.9, 0.8, 0.7, 0.6)
    end)

    -- @covers LOverlay:getLightningColor
    it("getLightningColor returns the stored lightning color", function()
        local overlay = new_overlay(320, 240)
        overlay:setLightningColor(0.3, 0.4, 0.5, 0.6)
        local r, g, b, a = overlay:getLightningColor()
        expect_rgba(r, g, b, a, 0.3, 0.4, 0.5, 0.6)
    end)

    -- @covers LOverlay:flash
    it("flash starts the shorthand flash effect", function()
        local overlay = new_overlay(320, 240)
        overlay:flash(1.0, 0.8, 0.6, 0.5, 0.2)
        expect_true(overlay:isFlashing())
    end)

    -- @covers LOverlay:isFlashing
    it("isFlashing reflects the shorthand flash state", function()
        local overlay = new_overlay(320, 240)
        overlay:flash(1.0, 1.0, 1.0, 0.5, 0.2)
        expect_true(overlay:isFlashing())
    end)

    -- @covers LOverlay:shake
    it("shake starts the shorthand shake effect", function()
        local overlay = new_overlay(320, 240)
        overlay:shake(3.0, 0.4)
        expect_true(overlay:isShaking())
    end)

    -- @covers LOverlay:isShaking
    it("isShaking reflects the shorthand shake state", function()
        local overlay = new_overlay(320, 240)
        overlay:shake(2.0, 0.4)
        expect_true(overlay:isShaking())
    end)

    -- @covers LOverlay:fade
    it("fade starts the shorthand fade effect", function()
        local overlay = new_overlay(320, 240)
        overlay:fade(0.1, 0.2, 0.3, 0.9, 0.5)
        expect_true(overlay:isFading())
    end)

    -- @covers LOverlay:isFading
    it("isFading reflects the shorthand fade state", function()
        local overlay = new_overlay(320, 240)
        overlay:fade(0.0, 0.0, 0.0, 0.5, 0.5)
        expect_true(overlay:isFading())
    end)
end)

-- @describe screen transition methods
describe("screen transition methods", function()
    -- @covers LScreenTransition:progress
    it("progress advances according to elapsed time", function()
        local transition = new_transition("fade", 1.0, { 0.0, 0.0, 0.0, 1.0 })
        transition:play()
        transition:update(0.25)
        expect_near(0.25, transition:progress(), 0.0001)
    end)

    -- @covers LScreenTransition:isActive
    it("isActive becomes true after playback starts", function()
        local transition = new_transition("fade", 1.0, { 0.0, 0.0, 0.0, 1.0 })
        transition:play()
        expect_true(transition:isActive())
    end)

    -- @covers LScreenTransition:isDone
    it("isDone becomes true after the transition finishes", function()
        local transition = new_transition("fade", 0.25, { 0.0, 0.0, 0.0, 1.0 })
        transition:play()
        transition:update(0.3)
        expect_true(transition:isDone())
    end)

    -- @covers LScreenTransition:color
    it("color returns the transition rgba state", function()
        local transition = new_transition("fade", 1.0, { 0.2, 0.3, 0.4, 0.5 })
        local r, g, b, a = transition:color()
        expect_rgba(r, g, b, a, 0.2, 0.3, 0.4, 0.5)
    end)

    -- @covers LScreenTransition:typeOf
    it("typeOf recognizes LScreenTransition and LObject", function()
        local transition = new_transition("fade", 1.0, { 0.0, 0.0, 0.0, 1.0 })
        expect_true(transition:typeOf("LScreenTransition"))
        expect_true(transition:typeOf("LObject"))
    end)
end)

test_summary()
