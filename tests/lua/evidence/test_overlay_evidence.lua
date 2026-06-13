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
end)
test_summary()
