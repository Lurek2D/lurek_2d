-- Evidence tests: overlay module
-- Output-only evidence from direct lurek.overlay APIs.

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

local function chart_to_image(chart, width, height)
    local img = lurek.image.newImageData(width, height)
    img:fill(18, 20, 28, 255)
    chart:drawToImage(img)
    return img
end

local function draw_outline(img, x, y, w, h, r, g, b, a)
    img:drawLine(x, y, x + w - 1, y, r, g, b, a or 255)
    img:drawLine(x + w - 1, y, x + w - 1, y + h - 1, r, g, b, a or 255)
    img:drawLine(x + w - 1, y + h - 1, x, y + h - 1, r, g, b, a or 255)
    img:drawLine(x, y + h - 1, x, y, r, g, b, a or 255)
end

-- @describe evidence: overlay
describe("evidence: overlay", function()
    before_each(function()
        ensure_evidence_dir("overlay")
    end)
    -- Does: Runs "exports overlay flash/fade/lightning state timeline" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.overlay.new without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/overlay/overlay_timeline.json
    -- Why: This is meaningful only if the visible/text output comes from lurek.overlay.new; export helpers are just the container.

    it("exports overlay flash/fade/lightning state timeline", function()
        local path = OUT .. "overlay_timeline.json"

        local ov = lurek.overlay.new(256, 128)
        ov:triggerFlash(1.0, 0.2, 0.0, 0.9, 0.5)
        ov:triggerFade(0.0, 0.0, 0.0, 0.7, 0.8)
        ov:triggerLightning()

        local dt = 1 / 30
        local out = {}
        for i = 1, 24 do
            local fa = ov:getFlashAlpha()
            local la = ov:getLightningAlpha()
            ov:update(dt)
            out[i] = string.format('{"frame":%d,"flash":%.5f,"lightning":%.5f}', i, tonumber(fa) or 0, tonumber(la) or 0)
        end
        write_text(path, "[" .. table.concat(out, ",") .. "]")
    end)
    -- Does: Runs "exports overlay drawToImage metadata" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.overlay.new and LOverlay:drawToImage without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/overlay/overlay_draw_to_image.json
    -- Why: This is meaningful only if the visible/text output comes from lurek.overlay.new and LOverlay:drawToImage; export helpers are just the container.

    it("exports overlay drawToImage metadata", function()
        local path = OUT .. "overlay_draw_to_image.json"

        local ov = lurek.overlay.new(256, 128)
        ov:triggerFlash(0.3, 0.7, 1.0, 0.8, 0.6)
        ov:update(0.1)
        local img = ov:drawToImage(256, 128)
        local json = string.format('{"lua_type":"%s","engine_type":"%s"}', type(img), tostring(img and img:type() or "nil"))
        write_text(path, json)
    end)
    -- Does: Runs "exports overlay state preview panels" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by LOverlay:triggerFlash, LOverlay:triggerFade, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/overlay/overlay_state_panels.png, tests/artifacts/current/overlay/overlay_weather_daynight_panels.png
    -- Why: This is meaningful only if the visible/text output comes from LOverlay:triggerFlash, LOverlay:triggerFade, and related owner calls; export helpers are just the container.

    it("exports overlay state preview panels", function()
        local path = OUT .. "overlay_state_panels.png"
        local canvas = lurek.image.newImageData(540, 160)
        canvas:fill(12, 14, 20, 255)

        local configs = {
            function(ov)
                ov:triggerFlash(1.0, 0.35, 0.10, 0.9, 0.5)
                ov:update(0.05)
            end,
            function(ov)
                ov:triggerFade(0.05, 0.08, 0.12, 0.85, 0.9)
                ov:update(0.45)
            end,
            function(ov)
                ov:triggerLightning()
                ov:update(0.02)
            end,
        }

        for i, configure in ipairs(configs) do
            local ov = lurek.overlay.new(160, 96)
            configure(ov)
            local frame = ov:drawToImage(160, 96)
            local x = 16 + (i - 1) * 172
            canvas:drawRect(x - 4, 18, 168, 104, 24, 28, 36, 255)
            canvas:paste(frame, x, 22)
            draw_outline(canvas, x, 22, 160, 96, 232, 236, 244, 255)
        end

        save_png(canvas, path)
    end)
    -- Does: Runs "exports weather and day-night overlay panels" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by LOverlay:setAmbientColor, LOverlay:setTimeOfDay, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/overlay/overlay_weather_daynight_panels.png
    -- Why: This is meaningful only if the visible/text output comes from LOverlay:setAmbientColor, LOverlay:setTimeOfDay, and related owner calls; export helpers are just the container.

    it("exports weather and day-night overlay panels", function()
        local path = OUT .. "overlay_weather_daynight_panels.png"
        local canvas = lurek.image.newImageData(696, 196)
        canvas:fill(12, 14, 20, 255)

        local configs = {
            function(ov)
                ov:setAmbientColor(0.90, 0.62, 0.38, 0.35)
                ov:setTimeOfDay(6.5)
                ov:setFogEnabled(true)
                ov:setFogDensity(0.18)
                ov:setVignetteEnabled(true)
                ov:setVignetteStrength(0.22)
            end,
            function(ov)
                ov:setAmbientColor(0.28, 0.38, 0.55, 0.25)
                ov:setTimeOfDay(12.0)
                ov:setCloudShadows(true)
                ov:setCloudCount(6)
                ov:setCloudSpeed(0.75)
                ov:setCloudScale(1.3)
                ov:setCloudOpacity(0.42)
                ov:setWeatherEnabled(true)
                ov:setWeather("rain")
                ov:setWeatherIntensity(0.55)
                ov:setWindDirection(35.0)
                ov:setWindSpeed(1.4)
            end,
            function(ov)
                ov:setAmbientColor(0.98, 0.74, 0.42, 0.30)
                ov:setTimeOfDay(17.75)
                ov:setHeatHazeEnabled(true)
                ov:setHeatHazeIntensity(0.48)
                ov:setFilmGrainEnabled(true)
                ov:setFilmGrainIntensity(0.18)
                ov:setVignetteEnabled(true)
                ov:setVignetteStrength(0.32)
            end,
            function(ov)
                ov:setAmbientColor(0.14, 0.18, 0.32, 0.42)
                ov:setTimeOfDay(22.0)
                ov:setFogEnabled(true)
                ov:setFogDensity(0.28)
                ov:setWeatherEnabled(true)
                ov:setWeather("snow")
                ov:setWeatherIntensity(0.42)
                ov:setLightningColor(0.70, 0.86, 1.0, 0.90)
                ov:triggerLightning()
                ov:update(0.03)
            end,
        }

        for i, configure in ipairs(configs) do
            local ov = lurek.overlay.new(160, 96)
            configure(ov)
            local frame = ov:drawToImage(160, 96)
            local x = 16 + (i - 1) * 168
            canvas:drawRect(x - 4, 26, 168, 104, 24, 28, 36, 255)
            canvas:paste(frame, x, 30)
            draw_outline(canvas, x, 30, 160, 96, 232, 236, 244, 255)
        end

        save_png(canvas, path)
    end)
    -- Does: Runs "exports overlay telemetry dashboard" and turns the owner-module result into inspectable dashboard charts.
    -- Shows: The artifact should expose the behavior produced by LOverlay:getStats, lurek.dataframe.fromRows, and lurek.charts chart renderers.
    -- Artifact: tests/artifacts/current/overlay/overlay_runtime_dashboard.png
    -- Why: This is meaningful only if the visible output comes from runtime overlay telemetry sampled over time.

    it("exports overlay telemetry dashboard", function()
        local ov = lurek.overlay.new(320, 180)
        ov:setAmbientEnabled(true)
        ov:setFogEnabled(true)
        ov:setFogDensity(0.18)
        ov:setVignetteEnabled(true)
        ov:setVignetteStrength(0.24)
        ov:setWeatherEnabled(true)
        ov:setWeather("rain")
        ov:setWeatherIntensity(0.25)

        local rows = {}
        local peak = { flash = 0.0, lightning = 0.0, weather = 0.0, load = 0.0 }
        local sum = { flash = 0.0, lightning = 0.0, weather = 0.0, load = 0.0 }
        local phase_sums = {
            { 0.0, 0.0, 0.0, 0.0 },
            { 0.0, 0.0, 0.0, 0.0 },
            { 0.0, 0.0, 0.0, 0.0 },
        }
        local phase_counts = { 0, 0, 0 }

        for frame = 1, 48 do
            if frame == 4 or frame == 22 then
                ov:triggerFlash(0.95, 0.55, 0.20, 0.85, 0.45)
            end
            if frame == 12 or frame == 34 then
                ov:triggerLightning()
            end
            if frame == 18 then
                ov:setWeatherIntensity(0.55)
            end
            if frame == 30 then
                ov:setWeatherIntensity(0.85)
                ov:setFogDensity(0.26)
            end

            ov:update(1 / 30)

            local stats = ov:getStats()
            local weather_fill = 0.0
            if stats.weather_particle_limit > 0 then
                weather_fill = stats.weather_particle_count / stats.weather_particle_limit
            end
            local effect_load = math.min(1.0, stats.active_effects / 8.0)
            rows[#rows + 1] = {
                frame,
                stats.flash_alpha,
                stats.lightning_alpha,
                weather_fill,
                effect_load,
            }

            peak.flash = math.max(peak.flash, stats.flash_alpha)
            peak.lightning = math.max(peak.lightning, stats.lightning_alpha)
            peak.weather = math.max(peak.weather, weather_fill)
            peak.load = math.max(peak.load, effect_load)
            sum.flash = sum.flash + stats.flash_alpha
            sum.lightning = sum.lightning + stats.lightning_alpha
            sum.weather = sum.weather + weather_fill
            sum.load = sum.load + effect_load

            local phase = frame <= 16 and 1 or (frame <= 32 and 2 or 3)
            phase_counts[phase] = phase_counts[phase] + 1
            phase_sums[phase][1] = phase_sums[phase][1] + stats.flash_alpha * 100.0
            phase_sums[phase][2] = phase_sums[phase][2] + stats.lightning_alpha * 100.0
            phase_sums[phase][3] = phase_sums[phase][3] + weather_fill * 100.0
            phase_sums[phase][4] = phase_sums[phase][4] + effect_load * 100.0
        end

        local df = lurek.dataframe.fromRows(
            { "frame", "flash_alpha", "lightning_alpha", "weather_fill", "effect_load" },
            rows
        )

        local signal = lurek.charts.newLine({ width = 360, height = 180, title = "overlay-signal" })
        signal:addSeriesFromDataFrame("flash", df, "frame", "flash_alpha")
        signal:addSeriesFromDataFrame("lightning", df, "frame", "lightning_alpha")
        signal:addSeriesFromDataFrame("weather", df, "frame", "weather_fill")
        signal:addSeriesFromDataFrame("load", df, "frame", "effect_load")

        local summary = lurek.charts.newBar({ width = 180, height = 180, title = "overlay-load" })
        summary:addSeries("peak", {})
        summary:addSeries("mean", {})
        summary:addCategory("flash", { peak.flash * 100.0, (sum.flash / #rows) * 100.0 })
        summary:addCategory("light", { peak.lightning * 100.0, (sum.lightning / #rows) * 100.0 })
        summary:addCategory("weather", { peak.weather * 100.0, (sum.weather / #rows) * 100.0 })
        summary:addCategory("load", { peak.load * 100.0, (sum.load / #rows) * 100.0 })

        local matrix = {}
        for i = 1, 3 do
            local n = math.max(1, phase_counts[i])
            matrix[i] = {
                phase_sums[i][1] / n,
                phase_sums[i][2] / n,
                phase_sums[i][3] / n,
                phase_sums[i][4] / n,
            }
        end
        local phases = lurek.charts.newHeatmap({ width = 180, height = 180, showLegend = true, title = "phase-density" })
        phases:setMatrix(matrix, { "early", "mid", "late" }, { "flash", "light", "weather", "load" })
        phases:setValueRange(0, 100)
        phases:setShowValues(true)

        local canvas = lurek.image.newImageData(784, 220)
        canvas:fill(12, 14, 20, 255)
        local cards = {
            { chart_to_image(signal, 360, 180), 16, 20, 360, 180 },
            { chart_to_image(summary, 180, 180), 392, 20, 180, 180 },
            { chart_to_image(phases, 180, 180), 588, 20, 180, 180 },
        }
        for _, card in ipairs(cards) do
            canvas:drawRect(card[2] - 4, card[3] - 4, card[4] + 8, card[5] + 8, 24, 28, 36, 255)
            canvas:paste(card[1], card[2], card[3])
            draw_outline(canvas, card[2], card[3], card[4], card[5], 232, 236, 244, 255)
        end

        save_png(canvas, OUT .. "overlay_runtime_dashboard.png")
    end)
end)
test_summary()
