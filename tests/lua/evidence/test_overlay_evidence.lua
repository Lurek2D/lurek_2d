-- Evidence tests: overlay module
-- Artifacts are generated from lurek.overlay screen-effect, environment-state, and transition APIs.
-- This file intentionally avoids file-level @covers markers; evidence ownership is described per artifact block.

local OUT = evidence_output_dir("overlay")

local function write_text(path, text)
    if write_file then
        write_file(path, text)
    else
        lurek.filesystem.write(path, text)
    end
    expect_evidence_created(path)
end

local function save_png(img, path)
    lurek.image.savePNG(img, path)
    expect_evidence_created(path)
end

local function save_gif(frames, path, options)
    lurek.image.saveGIF(frames, path, options or { delayMs = 90, speed = 10 })
    expect_evidence_created(path)
end

local function reset_overlay_outputs()
    local names = {
        "overlay_dawn_fog_preview.png",
        "overlay_draw_to_image.json",
        "overlay_dusk_heat_preview.png",
        "overlay_environment_layers.gif",
        "overlay_fade_preview.png",
        "overlay_flash_fade_lightning_sequence.gif",
        "overlay_flash_preview.png",
        "overlay_lightning_preview.png",
        "overlay_night_snow_preview.png",
        "overlay_noon_rain_preview.png",
        "overlay_screen_effects_timeline.gif",
        "overlay_timeline.json",
        "overlay_transition_modes.gif",
        "overlay_atmosphere_compositor.png",
        "overlay_flash_shake_fade_composite.gif",
        "overlay_storm_front_wind_sweep.gif",
        "overlay_transition_mask_atlas.png",
        "overlay_weather_wind_field.png",
        "overlay_weather_cycle.gif",
        "overlay_weather_state_trace.json",
    }
    for _, name in ipairs(names) do
        pcall(function()
            lurek.filesystem.remove(OUT .. name)
        end)
        if os and os.remove then
            pcall(function()
                os.remove(OUT .. name)
            end)
        end
    end
end

local function clamp01(v)
    return math.max(0.0, math.min(1.0, tonumber(v) or 0.0))
end

local function draw_meter(img, x, y, w, h, value, r, g, b)
    img:drawRect(x, y, w, h, 26, 30, 42, 255)
    img:drawRect(x, y, math.max(1, math.floor(w * clamp01(value))), h, r, g, b, 255)
end

local function draw_outline(img, x, y, w, h, r, g, b)
    img:drawLine(x, y, x + w - 1, y, r, g, b, 255)
    img:drawLine(x + w - 1, y, x + w - 1, y + h - 1, r, g, b, 255)
    img:drawLine(x + w - 1, y + h - 1, x, y + h - 1, r, g, b, 255)
    img:drawLine(x, y + h - 1, x, y, r, g, b, 255)
end

local function draw_wind_field(img, x0, y0, w, h, direction, speed, weather)
    local rad = math.rad(direction)
    local dx = math.cos(rad) * (7 + speed * 4)
    local dy = math.sin(rad) * (7 + speed * 4)
    for y = y0 + 12, y0 + h - 12, 18 do
        for x = x0 + 12, x0 + w - 12, 22 do
            if weather == "snow" then
                img:drawCircle(x + math.floor(dx * 0.4), y + math.floor(dy * 0.4), 2, 230, 240, 255, 210)
            else
                img:drawLine(x, y, x + math.floor(dx), y + math.floor(dy), 110, 170, 255, 220)
            end
        end
    end
end

local function draw_transition_mask(img, kind, progress, x, y, w, h, r, g, b)
    img:drawRect(x, y, w, h, 22, 26, 38, 255)
    if kind == "fade" then
        img:drawRect(x, y, w, h, r, g, b, math.floor(255 * progress))
    elseif kind == "wipe" then
        img:drawRect(x, y, math.floor(w * progress), h, r, g, b, 230)
    elseif kind == "iris" then
        local radius = math.floor(math.max(w, h) * progress * 0.55)
        img:drawCircle(x + math.floor(w / 2), y + math.floor(h / 2), radius, r, g, b, 230)
    else
        local step = 9
        for yy = y, y + h - step, step do
            for xx = x, x + w - step, step do
                local hash = ((xx - x) * 13 + (yy - y) * 7) % 100
                if hash < progress * 100 then
                    img:drawRect(xx, yy, step - 1, step - 1, r, g, b, 220)
                end
            end
        end
    end
    draw_outline(img, x, y, w, h, 220, 226, 238)
end

local function draw_environment_frame(ov, frame_index, width, height)
    local img = lurek.image.newImageData(width, height)
    img:fill(12, 15, 24, 255)

    local stats = ov:getStats()
    local water = ov:getWater()
    local plan = ov:getRenderPlan()
    local active_external = 0
    for _ in pairs(plan.externally_handled) do
        active_external = active_external + 1
    end

    img:drawRect(0, 0, width, 14, 34, 42, 62, 255)
    img:drawRect(0, height - 14, width, 14, 34, 42, 62, 255)
    draw_meter(img, 12, 24, 170, 12, (stats.weather_particle_count or 0) / math.max(1, stats.weather_particle_limit or 1), 105, 170, 255)
    draw_meter(img, 12, 44, 170, 12, (stats.weather_intensity or 0) / 8.0, 135, 205, 255)
    draw_meter(img, 12, 64, 170, 12, ov:getFogDensity() / 0.8, 180, 190, 210)
    draw_meter(img, 12, 84, 170, 12, ov:getCloudOpacity(), 120, 130, 150)
    draw_meter(img, 12, 104, 170, 12, ov:getVignetteStrength(), 40, 44, 60)
    draw_meter(img, 12, 124, 170, 12, water.tint_strength or 0, 40, 130, 210)

    local weather_count = math.min(60, stats.weather_particle_count or 0)
    for i = 1, weather_count do
        local x = 210 + ((i * 37 + frame_index * 11) % 135)
        local y = 22 + ((i * 19 + frame_index * 7) % 102)
        if ov:getWeather() == "snow" then
            img:drawCircle(x, y, 2, 230, 240, 255, 210)
        else
            img:drawLine(x, y, x + 4, y + 9, 110, 170, 255, 220)
        end
    end

    local cloud_count = ov:getCloudCount()
    for i = 1, cloud_count do
        local x = 205 + ((i * 41 + frame_index * math.max(1, math.floor(ov:getCloudSpeed() * 10))) % 120)
        local y = 20 + ((i * 17) % 70)
        img:drawCircle(x, y, 12, 36, 38, 48, math.floor(180 * ov:getCloudOpacity()))
        img:drawCircle(x + 13, y + 2, 10, 36, 38, 48, math.floor(160 * ov:getCloudOpacity()))
    end

    if water.enabled then
        local wave_y = 134
        for x = 202, width - 14, 5 do
            local t = (x + frame_index * 7) / 13.0
            local y = wave_y + math.floor(math.sin(t) * (water.amplitude or 1) * 3)
            img:drawLine(x, y, x + 4, y, 40, 145, 220, 230)
        end
    end

    for i = 1, active_external do
        img:drawRect(width - 18 - i * 10, 4, 7, 7, 210, 165, 80, 255)
    end
    return img
end

local function configure_environment(ov, phase)
    ov:setAmbientEnabled(true)
    ov:setFogEnabled(true)
    ov:setWeatherEnabled(true)
    ov:setCloudShadows(true)
    ov:setVignetteEnabled(true)
    ov:setFilmGrainEnabled(true)
    ov:setWeatherSeed(4041)
    ov:setCloudCount(7)
    ov:setCloudScale(1.2)
    ov:setCloudSpeed(0.75)
    ov:setWater(0.7, 3.5, 1.2)
    ov:setWaterTint(0.10, 0.42, 0.78, 0.45)

    if phase < 0.34 then
        ov:setTimeOfDay(7.0)
        ov:setAmbientColor(0.82, 0.56, 0.30, 0.34)
        ov:setWeather("rain")
        ov:setWeatherIntensity(1.6)
        ov:setFogDensity(0.24)
        ov:setCloudOpacity(0.36)
        ov:setVignetteStrength(0.18)
        ov:setWindDirection(25.0)
        ov:setWindSpeed(1.2)
    elseif phase < 0.68 then
        ov:setTimeOfDay(18.0)
        ov:setAmbientColor(0.95, 0.48, 0.22, 0.42)
        ov:setWeather("rain")
        ov:setWeatherIntensity(3.6)
        ov:setFogDensity(0.34)
        ov:setCloudOpacity(0.58)
        ov:setVignetteStrength(0.34)
        ov:setHeatHazeEnabled(true)
        ov:setHeatHazeIntensity(0.45)
        ov:setWindDirection(55.0)
        ov:setWindSpeed(2.4)
    else
        ov:setTimeOfDay(22.0)
        ov:setAmbientColor(0.10, 0.14, 0.28, 0.48)
        ov:setWeather("snow")
        ov:setWeatherIntensity(2.2)
        ov:setFogDensity(0.42)
        ov:setCloudOpacity(0.46)
        ov:setVignetteStrength(0.46)
        ov:setHeatHazeEnabled(false)
        ov:setWindDirection(120.0)
        ov:setWindSpeed(1.0)
    end
end

reset_overlay_outputs()

-- @describe Evidence: lurek.overlay API
describe("Evidence: lurek.overlay API", function()
    before_each(function()
        ensure_evidence_dir("overlay")
    end)

    -- Does: Records one overlay as flash, shake, fade, and lightning timers advance through LOverlay:update.
    -- Shows: The GIF exposes the overlay module's screen-effect controller: flash decays, shake moves the marker, fade accumulates, and lightning spikes.
    -- Artifact: tests/artifacts/current/overlay/overlay_screen_effects_timeline.gif
    -- Why: This is overlay-owned evidence because each frame is produced by LOverlay:drawToImage from triggerFlash, triggerShake, triggerFade, triggerLightning, and update.
    it("GIF: screen effect timeline", function()
        local ov = lurek.overlay.new(260, 150)
        ov:triggerFlash(1.0, 0.24, 0.10, 0.95, 0.65)
        ov:triggerShake(16.0, 1.0)
        ov:triggerFade(0.02, 0.03, 0.08, 0.76, 1.2)

        local frames = {}
        for i = 1, 18 do
            if i == 7 or i == 13 then
                ov:triggerLightning()
            end
            ov:update(0.07)
            frames[i] = ov:drawToImage(260, 150)
        end

        save_gif(frames, OUT .. "overlay_screen_effects_timeline.gif", { delayMs = 75, speed = 10 })
    end)

    -- Does: Animates overlay environment state and renders a diagnostic map from owner getters, stats, render plan, weather RNG, and water state.
    -- Shows: The GIF makes non-rasterized overlay layers legible: weather particle count, fog, clouds, vignette, wind, external render responsibility, and water time all change.
    -- Artifact: tests/artifacts/current/overlay/overlay_environment_layers.gif
    -- Why: Lua drawToImage intentionally covers screen-effect state only; this diagnostic visual is honest evidence for overlay's environment controller APIs without pretending to be the final scene renderer.
    it("GIF: environment layer state map", function()
        local ov = lurek.overlay.new(360, 160)
        local frames = {}
        for i = 1, 18 do
            configure_environment(ov, (i - 1) / 17.0)
            ov:update(0.12)
            frames[i] = draw_environment_frame(ov, i, 360, 160)
        end
        save_gif(frames, OUT .. "overlay_environment_layers.gif", { delayMs = 90, speed = 10 })
    end)

    -- Does: Drives fade, wipe, iris, and dissolve screen transitions forward and then reverse while drawing progress meters.
    -- Shows: The GIF demonstrates that overlay transitions are timed state machines with different modes and reversible progress.
    -- Artifact: tests/artifacts/current/overlay/overlay_transition_modes.gif
    -- Why: This belongs to overlay because the progress values come from lurek.overlay.newTransition, LScreenTransition:play, update, reverse, kind, and progress.
    it("GIF: transition modes and reverse progress", function()
        local transitions = {
            lurek.overlay.newTransition("fade", 0.9, { 0.0, 0.0, 0.0, 1.0 }),
            lurek.overlay.newTransition("wipe", 0.9, { 0.1, 0.2, 0.4, 1.0 }),
            lurek.overlay.newTransition("iris", 0.9, { 0.4, 0.1, 0.2, 1.0 }),
            lurek.overlay.newTransition("dissolve", 0.9, { 0.3, 0.3, 0.3, 1.0 }),
        }
        local colors = {
            { 220, 220, 230 },
            { 90, 160, 255 },
            { 240, 100, 150 },
            { 180, 180, 190 },
        }
        for _, tr in ipairs(transitions) do
            tr:play()
        end

        local frames = {}
        for frame = 1, 16 do
            local img = lurek.image.newImageData(320, 140)
            img:fill(13, 16, 25, 255)
            if frame == 10 then
                for _, tr in ipairs(transitions) do
                    tr:reverse()
                end
            end
            for i, tr in ipairs(transitions) do
                tr:update(0.09)
                local y = 18 + (i - 1) * 28
                img:drawRect(24, y, 260, 16, 34, 38, 52, 255)
                img:drawRect(24, y, math.max(2, math.floor(260 * tr:progress())), 16, colors[i][1], colors[i][2], colors[i][3], 255)
                img:drawCircle(14, y + 8, i + 2, colors[i][1], colors[i][2], colors[i][3], 255)
            end
            frames[frame] = img
        end

        save_gif(frames, OUT .. "overlay_transition_modes.gif", { delayMs = 85, speed = 10 })
    end)

    -- Does: Exports a structured trace for the same environment controller used by the visual GIF.
    -- Shows: The trace records exact weather counts, active external layers, fog, water time, and screen-effect alpha values behind the visual artifact.
    -- Artifact: tests/artifacts/current/overlay/overlay_weather_state_trace.json
    -- Why: The JSON is secondary evidence that lets reviewers audit the overlay state values when a GIF frame is visually ambiguous.
    it("JSON: environment state trace", function()
        local ov = lurek.overlay.new(320, 160)
        local rows = {}
        for i = 1, 8 do
            configure_environment(ov, (i - 1) / 7.0)
            if i == 4 then
                ov:triggerLightning()
            end
            ov:update(0.18)
            local stats = ov:getStats()
            local plan = ov:getRenderPlan()
            local water = ov:getWater()
            rows[i] = string.format(
                '{"frame":%d,"weather":"%s","particles":%d,"external_layers":%d,"fog":%.3f,"water_time":%.3f,"lightning":%.3f}',
                i,
                ov:getWeather(),
                stats.weather_particle_count or 0,
                #plan.externally_handled,
                ov:getFogDensity(),
                water.time or 0,
                ov:getLightningAlpha()
            )
        end
        write_text(OUT .. "overlay_weather_state_trace.json", "[" .. table.concat(rows, ",") .. "]")
    end)

    -- Does: Compares rain, snow, fog-heavy, and heat-haze weather profiles as wind-vector fields with owner telemetry meters.
    -- Shows: The PNG makes overlay-specific weather and wind orchestration visible instead of showing a generic image filter.
    -- Artifact: tests/artifacts/current/overlay/overlay_weather_wind_field.png
    -- Why: This belongs to overlay because every panel is driven by LOverlay weather, wind, fog, heat haze, stats, and update state.
    it("PNG: weather wind field profiles", function()
        local profiles = {
            { weather = "rain", direction = 35, speed = 2.4, intensity = 3.2, fog = 0.16, haze = false, color = { 82, 150, 255 } },
            { weather = "snow", direction = 115, speed = 1.1, intensity = 2.0, fog = 0.34, haze = false, color = { 210, 230, 255 } },
            { weather = "rain", direction = 260, speed = 3.1, intensity = 4.0, fog = 0.52, haze = false, color = { 120, 155, 190 } },
            { weather = "rain", direction = 10, speed = 1.8, intensity = 1.4, fog = 0.10, haze = true, color = { 245, 130, 70 } },
        }
        local img = lurek.image.newImageData(520, 170)
        img:fill(10, 13, 22, 255)
        for i, p in ipairs(profiles) do
            local ov = lurek.overlay.new(120, 130)
            ov:setWeatherEnabled(true)
            ov:setWeatherSeed(8100 + i)
            ov:setWeather(p.weather)
            ov:setWeatherIntensity(p.intensity)
            ov:setWindDirection(p.direction)
            ov:setWindSpeed(p.speed)
            ov:setFogEnabled(true)
            ov:setFogDensity(p.fog)
            ov:setHeatHazeEnabled(p.haze)
            ov:setHeatHazeIntensity(p.haze and 0.65 or 0.0)
            ov:update(0.28)
            local stats = ov:getStats()
            local x = 10 + (i - 1) * 128
            img:drawRect(x, 14, 118, 140, 20, 24, 36, 255)
            draw_wind_field(img, x + 6, 22, 106, 82, p.direction, p.speed, p.weather)
            draw_meter(img, x + 10, 112, 96, 7, (stats.weather_particle_count or 0) / math.max(1, stats.weather_particle_limit or 1), p.color[1], p.color[2], p.color[3])
            draw_meter(img, x + 10, 124, 96, 7, p.fog / 0.7, 170, 180, 200)
            draw_meter(img, x + 10, 136, 96, 7, p.haze and 0.65 or 0.0, 245, 130, 70)
            draw_outline(img, x, 14, 118, 140, p.color[1], p.color[2], p.color[3])
        end
        save_png(img, OUT .. "overlay_weather_wind_field.png")
    end)

    -- Does: Advances four transition kinds to three fixed progress samples and renders their mask geometry as an atlas.
    -- Shows: The PNG distinguishes fade, wipe, iris, and dissolve as screen-wide transition controllers rather than particle or post-fx effects.
    -- Artifact: tests/artifacts/current/overlay/overlay_transition_mask_atlas.png
    -- Why: This is overlay-owned because mask shape and progress come from LScreenTransition kind/play/update/color/progress.
    it("PNG: transition mask atlas", function()
        local kinds = { "fade", "wipe", "iris", "dissolve" }
        local colors = {
            { 235, 235, 245 },
            { 90, 160, 255 },
            { 240, 94, 144 },
            { 190, 190, 200 },
        }
        local img = lurek.image.newImageData(430, 245)
        img:fill(11, 14, 23, 255)
        for row, kind in ipairs(kinds) do
            for col = 1, 3 do
                local tr = lurek.overlay.newTransition(kind, 1.0, { colors[row][1] / 255, colors[row][2] / 255, colors[row][3] / 255, 1.0 })
                tr:play()
                tr:update(col * 0.25)
                draw_transition_mask(img, tr:kind(), tr:progress(), 18 + (col - 1) * 132, 14 + (row - 1) * 56, 112, 42, colors[row][1], colors[row][2], colors[row][3])
            end
        end
        save_png(img, OUT .. "overlay_transition_mask_atlas.png")
    end)

    -- Does: Builds one overlay with ambient, fog, clouds, vignette, water, and rain enabled, then renders each layer as a compositor strip.
    -- Shows: The PNG makes overlay's layer-wide presentation ownership legible as stacked global treatments.
    -- Artifact: tests/artifacts/current/overlay/overlay_atmosphere_compositor.png
    -- Why: The layers are driven by LOverlay environment setters/getters and getRenderPlan, while the image is only a diagnostic view.
    it("PNG: atmosphere compositor layers", function()
        local ov = lurek.overlay.new(420, 190)
        ov:setAmbientEnabled(true)
        ov:setAmbientColor(0.22, 0.34, 0.62, 0.38)
        ov:setFogEnabled(true)
        ov:setFogDensity(0.42)
        ov:setCloudShadows(true)
        ov:setCloudCount(9)
        ov:setCloudOpacity(0.55)
        ov:setCloudScale(1.6)
        ov:setVignetteEnabled(true)
        ov:setVignetteStrength(0.62)
        ov:setWater(0.8, 2.8, 1.4)
        ov:setWaterTint(0.08, 0.38, 0.78, 0.55)
        ov:setWeatherEnabled(true)
        ov:setWeather("rain")
        ov:setWeatherIntensity(2.8)
        ov:update(0.32)

        local img = lurek.image.newImageData(420, 190)
        img:fill(9, 11, 19, 255)
        local layers = {
            { value = 0.38, color = { 80, 120, 210 } },
            { value = ov:getFogDensity(), color = { 170, 180, 200 } },
            { value = ov:getCloudOpacity(), color = { 74, 82, 105 } },
            { value = ov:getVignetteStrength(), color = { 38, 40, 58 } },
            { value = ov:getWater().tint_strength or 0, color = { 35, 120, 220 } },
        }
        for i, layer in ipairs(layers) do
            local y = 18 + (i - 1) * 31
            img:drawRect(24, y, 288, 21, 24, 28, 40, 255)
            img:drawRect(24, y, math.floor(288 * clamp01(layer.value)), 21, layer.color[1], layer.color[2], layer.color[3], 220)
            draw_outline(img, 24, y, 288, 21, 210, 216, 228)
        end
        local plan = ov:getRenderPlan()
        local marker = 0
        for _ in pairs(plan.externally_handled) do
            marker = marker + 1
            img:drawCircle(346 + marker * 10, 48 + marker * 15, 5, 230, 170, 80, 255)
        end
        draw_wind_field(img, 330, 95, 70, 66, ov:getWindDirection(), ov:getWindSpeed(), ov:getWeather())
        save_png(img, OUT .. "overlay_atmosphere_compositor.png")
    end)

    -- Does: Sweeps a storm front across a scene by raising rain intensity, wind, fog, clouds, and lightning over time.
    -- Shows: The GIF demonstrates stateful overlay weather orchestration evolving frame-to-frame.
    -- Artifact: tests/artifacts/current/overlay/overlay_storm_front_wind_sweep.gif
    -- Why: It is overlay evidence because the visible field is generated from LOverlay weather, wind, fog, cloud, lightning, stats, and update calls.
    it("GIF: storm front wind sweep", function()
        local ov = lurek.overlay.new(300, 150)
        ov:setWeatherEnabled(true)
        ov:setWeather("rain")
        ov:setWeatherSeed(9912)
        ov:setFogEnabled(true)
        ov:setCloudShadows(true)
        ov:setCloudCount(8)
        local frames = {}
        for i = 1, 18 do
            local t = (i - 1) / 17.0
            ov:setWeatherIntensity(0.8 + t * 4.4)
            ov:setWindDirection(20 + t * 105)
            ov:setWindSpeed(0.6 + t * 3.8)
            ov:setFogDensity(0.10 + t * 0.44)
            ov:setCloudOpacity(0.22 + t * 0.55)
            if i == 9 or i == 14 then
                ov:triggerLightning()
            end
            ov:update(0.11)
            local img = lurek.image.newImageData(300, 150)
            img:fill(10, 13, 22, 255)
            draw_wind_field(img, 12, 16, 214, 108, ov:getWindDirection(), ov:getWindSpeed(), ov:getWeather())
            draw_meter(img, 238, 24, 42, 96, t, 90, 150, 255)
            img:drawRect(0, 0, 300, 150, 170, 180, 200, math.floor(70 * ov:getFogDensity()))
            img:drawRect(0, 0, 300, 150, 230, 240, 255, math.floor(180 * ov:getLightningAlpha()))
            frames[i] = img
        end
        save_gif(frames, OUT .. "overlay_storm_front_wind_sweep.gif", { delayMs = 75, speed = 10 })
    end)

    -- Does: Combines overlay flash, shake, fade, and lightning with drawToImage output and a motion marker trail.
    -- Shows: The GIF focuses on short-lived screen effects: color wash, fade overlay, lightning spike, and shake displacement.
    -- Artifact: tests/artifacts/current/overlay/overlay_flash_shake_fade_composite.gif
    -- Why: It is overlay-specific because each frame is produced from LOverlay screen-effect triggers, update, getShakeOffset, and drawToImage.
    it("GIF: flash shake fade composite", function()
        local ov = lurek.overlay.new(260, 150)
        ov:triggerFlash(1.0, 0.12, 0.05, 0.85, 0.65)
        ov:triggerShake(18.0, 1.1)
        ov:triggerFade(0.02, 0.03, 0.08, 0.72, 1.0)
        local frames = {}
        for i = 1, 18 do
            if i == 8 then
                ov:triggerLightning()
            end
            ov:update(0.06)
            local img = ov:drawToImage(260, 150)
            local sx, sy = ov:getShakeOffset()
            img:drawCircle(130 + math.floor(sx), 75 + math.floor(sy), 7, 255, 245, 130, 230)
            img:drawLine(130, 75, 130 + math.floor(sx * 2), 75 + math.floor(sy * 2), 255, 245, 130, 220)
            frames[i] = img
        end
        save_gif(frames, OUT .. "overlay_flash_shake_fade_composite.gif", { delayMs = 65, speed = 10 })
    end)
end)

test_summary()
