-- Evidence tests: particle module
-- Artifacts are generated via lurek.particle APIs (toImage/drawToImage).
-- This file intentionally avoids file-level @covers markers; evidence ownership is described per artifact block.

local Fixture = lurek.filesystem.load("tests/fixtures/particle_evidence_fixture.lua")()
local OUT = evidence_output_dir("particle")

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

local function sample_runtime_charts()
    local ps = lurek.particle.newSystem({
        seed = 1301,
        maxParticles = 220,
        emissionRate = 140,
        shape = "circle",
        lifetimeMin = 0.7,
        lifetimeMax = 1.6,
        sizeMin = 2,
        sizeMax = 5,
        speedMin = 28,
        speedMax = 95,
    })
    ps:setPosition(96, 96)
    ps:addAttractor(96, 96, 180, 84)
    ps:start()
    ps:warmUp(0.25)

    local rows = {}
    local live_samples = {}
    local occupancy = {
        { 0, 0, 0 },
        { 0, 0, 0 },
        { 0, 0, 0 },
    }
    local peak = { live = 0, total = 0, rate = 0, age = 0 }
    local sum = { live = 0, total = 0, rate = 0, age = 0 }

    for frame = 1, 54 do
        if frame == 20 then
            ps:setEmissionRate(80)
        end
        if frame == 38 then
            ps:stop()
        end

        ps:update(1 / 30)
        local stats = ps:getStats()
        rows[#rows + 1] = {
            frame,
            stats.live_particles,
            stats.total_live_particles,
            stats.emission_rate,
            stats.emitter_age,
        }
        live_samples[#live_samples + 1] = stats.live_particles

        peak.live = math.max(peak.live, stats.live_particles)
        peak.total = math.max(peak.total, stats.total_live_particles)
        peak.rate = math.max(peak.rate, stats.emission_rate)
        peak.age = math.max(peak.age, stats.emitter_age)
        sum.live = sum.live + stats.live_particles
        sum.total = sum.total + stats.total_live_particles
        sum.rate = sum.rate + stats.emission_rate
        sum.age = sum.age + stats.emitter_age

        local phase = frame <= 18 and 1 or (frame <= 36 and 2 or 3)
        local band = stats.live_particles < 60 and 1 or (stats.live_particles < 120 and 2 or 3)
        occupancy[phase][band] = occupancy[phase][band] + 1
    end

    local df = lurek.dataframe.fromRows(
        { "frame", "live_particles", "total_live_particles", "emission_rate", "emitter_age" },
        rows
    )

    local line = lurek.charts.newLine({ width = 340, height = 180, title = "particle-population" })
    line:addSeriesFromDataFrame("live", df, "frame", "live_particles")
    line:addSeriesFromDataFrame("total", df, "frame", "total_live_particles")

    local histogram = lurek.charts.newHistogram({ width = 180, height = 180, showLegend = true, title = "population-dist" })
    histogram:setBinCount(8)
    histogram:addSeries("live", live_samples)

    local phases = lurek.charts.newHeatmap({ width = 180, height = 180, showLegend = true, title = "phase-occupancy" })
    phases:setMatrix(occupancy, { "warmup", "burst", "decay" }, { "low", "mid", "high" })
    phases:setValueRange(0, 18)
    phases:setShowValues(true)

    local summary = lurek.charts.newBar({ width = 180, height = 180, title = "particle-summary" })
    summary:addSeries("peak", {})
    summary:addSeries("mean", {})
    summary:addCategory("live", { peak.live, sum.live / #rows })
    summary:addCategory("total", { peak.total, sum.total / #rows })
    summary:addCategory("rate", { peak.rate, sum.rate / #rows })
    summary:addCategory("age", { peak.age, sum.age / #rows })

    lurek.particle.release(ps)
    return {
        line = chart_to_image(line, 340, 180),
        summary = chart_to_image(summary, 180, 180),
        histogram = chart_to_image(histogram, 180, 180),
        phases = chart_to_image(phases, 180, 180),
    }
end

local function reset_particle_outputs()
    local names = {
        "particle_attractor_contraction.png",
        "particle_burst_evolution.gif",
        "particle_emitter_burst.png",
        "particle_emitter_cluster_snapshot.png",
        "particle_explosion_renderer.png",
        "particle_heatmap_runtime_phase.png",
        "particle_histogram_live_population.png",
        "particle_lifecycle_chart.png",
        "particle_over_paint_renderer.png",
        "particle_rain_renderer.png",
        "particle_runtime_population_lines.png",
        "particle_runtime_summary_bars.png",
        "particle_spark_trail_renderer.png",
        "particle_trail_wave_ribbon.png",
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

reset_particle_outputs()

-- @describe Evidence: lurek.particle API
describe("Evidence: lurek.particle API", function()
    before_each(function()
        ensure_evidence_dir("particle")
    end)
    -- Does: Runs "emitter cluster snapshot" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.particle.newSystem without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/particle/<artifact>
    -- Why: This is meaningful only if the visible/text output comes from lurek.particle.newSystem; export helpers are just the container.

    it("PNG: emitter cluster snapshot", function()
        local ps = lurek.particle.newSystem(Fixture.scenes.cluster)
        ps:setPosition(100, 100)
        ps:start()
        ps:emit(80)
        ps:update(0.35)

        local img = ps:toImage(200, 200)
        local path = OUT .. "particle_emitter_cluster_snapshot.png"
        save_png(img, path)

        lurek.particle.release(ps)
    end)
    -- Does: Runs "burst plume evolution over one second" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.particle.newSystem, LParticleSystem:update, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/particle/<artifact>
    -- Why: This is meaningful only if the visible/text output comes from lurek.particle.newSystem, LParticleSystem:update, and related owner calls; export helpers are just the container.

    it("GIF: burst plume evolution over one second", function()
        local ps = lurek.particle.newSystem({
            seed = 1002,
            maxParticles = 240,
            emissionRate = 90,
            shape = "circle",
            lifetimeMin = 0.8,
            lifetimeMax = 1.4,
            sizeMin = 2,
            sizeMax = 5,
            speedMin = 30,
            speedMax = 110,
            spread = 180,
        })
        ps:setPosition(96, 128)
        ps:start()
        ps:emit(80)

        local frames = {}
        for i = 1, 10 do
            ps:update(0.1)
            frames[i] = ps:drawToImage(192, 192)
        end

        local path = OUT .. "particle_burst_evolution.gif"
        lurek.image.saveGIF(frames, path, { delayMs = 100, speed = 10 })
        expect_evidence_created(path)

        lurek.particle.release(ps)
    end)
    -- Does: Runs "PNG: burst emission" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.particle.newSystem and related owner calls.
    -- Artifact: tests/artifacts/current/particle/particle_emitter_burst.png
    -- Why: This is meaningful only if the output is driven by lurek.particle.newSystem and related owner calls rather than by helper-only drawing.

    it("PNG: burst emission", function()
        local ps = lurek.particle.newSystem(Fixture.scenes.burst)
        ps:setPosition(96, 96)
        ps:start()
        ps:emit(120)
        ps:update(0.25)

        local img = ps:drawToImage(192, 192)
        local path = OUT .. "particle_emitter_burst.png"
        save_png(img, path)

        lurek.particle.release(ps)
    end)
    -- Does: Runs "PNG: attractor contraction" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.particle.newSystem and related owner calls.
    -- Artifact: tests/artifacts/current/particle/particle_attractor_contraction.png
    -- Why: This is meaningful only if the output is driven by lurek.particle.newSystem and related owner calls rather than by helper-only drawing.

    it("PNG: attractor contraction", function()
        local ps = lurek.particle.newSystem(Fixture.scenes.attractor)
        ps:setPosition(128, 128)
        ps:addAttractor(128, 128, 500, 260)
        ps:start()
        ps:warmUp(0.5)
        ps:update(0.3)

        local img = ps:toImage(256, 256)
        local path = OUT .. "particle_attractor_contraction.png"
        save_png(img, path)

        lurek.particle.release(ps)
    end)
    -- Does: Runs "trail drawToImage" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.particle.newTrail without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/particle/<artifact>
    -- Why: This is meaningful only if the visible/text output comes from lurek.particle.newTrail; export helpers are just the container.

    it("PNG: trail drawToImage", function()
        local trail = lurek.particle.newTrail(0.9, 10.0)
        trail:setWidth(10)
        trail:setHeadColor(0.95, 0.90, 0.35, 1.0)
        trail:setTailColor(0.30, 0.60, 1.0, 0.0)

        for _, point in ipairs(Fixture.trail_points(60, 256, 256)) do
            trail:pushPoint(point.x, point.y)
        end

        local img = trail:drawToImage(256, 256)
        local path = OUT .. "particle_trail_wave_ribbon.png"
        save_png(img, path)
    end)
    -- Does: Runs "lifecycle chart snapshot" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.particle.drawLifecycleToImage without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/particle/particle_lifecycle_chart.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.particle.drawLifecycleToImage; export helpers are just the container.

    it("PNG: lifecycle chart snapshot", function()
        local chart = lurek.particle.drawLifecycleToImage({
            { 0, 0 },
            { 1, 6 },
            { 2, 12 },
            { 3, 19 },
            { 4, 23 },
            { 5, 21 },
            { 6, 16 },
            { 7, 10 },
            { 8, 4 },
            { 9, 0 },
        }, 24, 256, 96)

        local path = OUT .. "particle_lifecycle_chart.png"
        lurek.image.savePNG(chart, path)
        expect_evidence_created(path)
    end)
    -- Does: Runs "specialized explosion renderer" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by LParticleSystem:drawExplosionToImage directly, without bundling multiple renderers into one sheet.
    -- Artifact: tests/artifacts/current/particle/particle_explosion_renderer.png
    -- Why: This is meaningful only if the visible output comes from the specialized explosion renderer itself.
    it("PNG: specialized explosion renderer", function()
        local explosion = lurek.particle.newSystem({ seed = 1201, maxParticles = 32 })
        explosion:setPosition(60, 60)
        local img_explosion = explosion:drawExplosionToImage(120, 120)
        save_png(img_explosion, OUT .. "particle_explosion_renderer.png")
        lurek.particle.release(explosion)
    end)

    -- Does: Runs "specialized rain renderer" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by LParticleSystem:drawRainToImage directly, without bundling multiple renderers into one sheet.
    -- Artifact: tests/artifacts/current/particle/particle_rain_renderer.png
    -- Why: This is meaningful only if the visible output comes from the specialized rain renderer itself.
    it("PNG: specialized rain renderer", function()
        local rain = lurek.particle.newSystem({ seed = 1202, maxParticles = 64 })
        rain:setPosition(60, 60)
        local img_rain = rain:drawRainToImage(120, 120)
        save_png(img_rain, OUT .. "particle_rain_renderer.png")
        lurek.particle.release(rain)
    end)

    -- Does: Runs "specialized spark trail renderer" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by LParticleSystem:drawSparkTrailToImage directly, without bundling multiple renderers into one sheet.
    -- Artifact: tests/artifacts/current/particle/particle_spark_trail_renderer.png
    -- Why: This is meaningful only if the visible output comes from the specialized spark-trail renderer itself.
    it("PNG: specialized spark trail renderer", function()
        local spark = lurek.particle.newSystem({ seed = 1203, maxParticles = 48 })
        spark:setPosition(60, 60)
        local img_spark = spark:drawSparkTrailToImage(120, 120)
        save_png(img_spark, OUT .. "particle_spark_trail_renderer.png")
        lurek.particle.release(spark)
    end)

    -- Does: Runs "over-image painter renderer" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by LParticleSystem:drawOverImage and LParticleSystem:paintOnto on one target image.
    -- Artifact: tests/artifacts/current/particle/particle_over_paint_renderer.png
    -- Why: This is meaningful only if the visible output comes from the over-image painter path itself.
    it("PNG: over-image painter renderer", function()
        local over = lurek.particle.newSystem({ seed = 1204, maxParticles = 24 })
        over:setPosition(60, 60)
        local composite = lurek.image.newImageData(120, 120)
        composite:fill(20, 24, 30, 255)
        over:drawOverImage(composite)
        over:paintOnto(composite)
        save_png(composite, OUT .. "particle_over_paint_renderer.png")
        lurek.particle.release(over)
    end)
    -- Does: Samples runtime telemetry and renders a line chart for live vs total particle counts.
    -- Shows: The artifact should expose the behavior produced by LParticleSystem:getStats, lurek.dataframe.fromRows, and lurek.charts line rendering.
    -- Artifact: tests/artifacts/current/particle/particle_runtime_population_lines.png
    -- Why: This is meaningful only if the visible output comes from sampled particle-system telemetry rather than a hand-authored image.
    it("PNG: runtime population lines", function()
        local charts = sample_runtime_charts()
        save_png(charts.line, OUT .. "particle_runtime_population_lines.png")
    end)

    -- Does: Samples runtime telemetry and renders summary bars for peak vs mean particle metrics.
    -- Shows: The artifact should expose the behavior produced by LParticleSystem:getStats and lurek.charts bar rendering without bundling several charts into one image.
    -- Artifact: tests/artifacts/current/particle/particle_runtime_summary_bars.png
    -- Why: This is meaningful only if the visible output comes from the summary bar chart itself.
    it("PNG: runtime summary bars", function()
        local charts = sample_runtime_charts()
        save_png(charts.summary, OUT .. "particle_runtime_summary_bars.png")
    end)

    -- Does: Samples runtime telemetry and renders a histogram of live particle counts.
    -- Shows: The artifact should expose the behavior produced by LParticleSystem:getStats sampling and lurek.charts histogram rendering without bundling several charts into one image.
    -- Artifact: tests/artifacts/current/particle/particle_histogram_live_population.png
    -- Why: This is meaningful only if the visible output comes from the histogram itself.
    it("PNG: runtime live histogram", function()
        local charts = sample_runtime_charts()
        save_png(charts.histogram, OUT .. "particle_histogram_live_population.png")
    end)

    -- Does: Samples runtime telemetry and renders a heatmap of occupancy by phase and population band.
    -- Shows: The artifact should expose the behavior produced by LParticleSystem:getStats sampling and lurek.charts heatmap rendering without bundling several charts into one image.
    -- Artifact: tests/artifacts/current/particle/particle_heatmap_runtime_phase.png
    -- Why: This is meaningful only if the visible output comes from the heatmap itself.
    it("PNG: runtime phase heatmap", function()
        local charts = sample_runtime_charts()
        save_png(charts.phases, OUT .. "particle_heatmap_runtime_phase.png")
    end)
end)
test_summary()
