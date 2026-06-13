-- Evidence tests: particle module
-- Artifacts are generated via lurek.particle APIs (toImage/drawToImage).

local OUT = evidence_output_dir("particle")

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

local function reset_particle_outputs()
    local names = {
        "particle_attractor.png",
        "particle_attractor_contraction.png",
        "particle_burst_evolution.gif",
        "particle_emitter_burst.png",
        "particle_emitter_cluster_snapshot.png",
        "particle_lifecycle_chart.png",
        "particle_positions.png",
        "particle_trail.png",
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
        local ps = lurek.particle.newSystem({
            seed = 1001,
            maxParticles = 180,
            emissionRate = 120,
            shape = "circle",
            lifetimeMin = 1.0,
            lifetimeMax = 2.0,
            sizeMin = 2,
            sizeMax = 6,
            speedMin = 20,
            speedMax = 80,
        })
        ps:setPosition(100, 100)
        ps:start()
        ps:emit(80)
        ps:update(0.35)

        local raw = ps:toImage(200, 200)
        local img = lurek.image.newImageData(240, 240)
        img:fill(14, 16, 22, 255)
        for x = 0, 239, 20 do
            img:drawLine(x, 0, x, 239, 24, 28, 36, 255)
        end
        for y = 0, 239, 20 do
            img:drawLine(0, y, 239, y, 24, 28, 36, 255)
        end
        img:paste(raw, 20, 20)
        draw_outline(img, 20, 20, 200, 200, 232, 236, 244, 255)
        img:drawCircle(120, 120, 5, 255, 208, 118, 255)
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
        local ps = lurek.particle.newSystem({
            seed = 1003,
            maxParticles = 220,
            emissionRate = 0,
            shape = "shrapnel",
            lifetimeMin = 0.6,
            lifetimeMax = 1.3,
            sizeMin = 2,
            sizeMax = 5,
            speedMin = 70,
            speedMax = 140,
            spread = 360,
        })
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
        local ps = lurek.particle.newSystem({
            seed = 1004,
            maxParticles = 240,
            emissionRate = 220,
            shape = "puff",
            lifetimeMin = 2.0,
            lifetimeMax = 2.0,
            speedMin = 40,
            speedMax = 90,
            sizeMin = 3,
            sizeMax = 7,
        })
        ps:setPosition(128, 128)
        ps:addAttractor(128, 128, 500, 260)
        ps:start()
        ps:warmUp(0.5)
        ps:update(0.3)

        local img = ps:toImage(256, 256)
        local path = OUT .. "particle_attractor_contraction.png"
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)

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

        for i = 1, 60 do
            local t = i / 60
            local x = 24 + t * 208
            local y = 128 + math.sin(t * math.pi * 3) * 48
            trail:pushPoint(x, y)
        end

        local img = trail:drawToImage(256, 256)
        local path = OUT .. "particle_trail_wave_ribbon.png"
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
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

        local img = lurek.image.newImageData(320, 180)
        img:fill(14, 16, 22, 255)
        img:drawRect(18, 24, 284, 132, 24, 28, 36, 255)
        img:paste(chart, 32, 42)
        draw_outline(img, 32, 42, 256, 96, 232, 236, 244, 255)
        img:drawLine(32, 152, 288, 152, 96, 110, 132, 255)

        local path = OUT .. "particle_lifecycle_chart.png"
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)
    -- Does: Runs "particle contact sheet" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by LParticleSystem:drawToImage and lurek.particle.drawLifecycleToImage without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/particle/particle_emitter_cluster_snapshot.png, tests/artifacts/current/particle/particle_emitter_burst.png, tests/artifacts/current/particle/particle_trail_wave_ribbon.png, tests/artifacts/current/particle/particle_lifecycle_chart.png
    -- Why: This is meaningful only if the visible/text output comes from LParticleSystem:drawToImage and lurek.particle.drawLifecycleToImage; export helpers are just the container.

    it("PNG: particle contact sheet", function()
        local cluster = lurek.image.newImageData(OUT .. "particle_emitter_cluster_snapshot.png")
        local burst = lurek.image.newImageData(OUT .. "particle_emitter_burst.png")
        local trail = lurek.image.newImageData(OUT .. "particle_trail_wave_ribbon.png")
        local lifecycle = lurek.image.newImageData(OUT .. "particle_lifecycle_chart.png")

        local canvas = lurek.image.newImageData(540, 360)
        canvas:fill(12, 14, 20, 255)
        local cards = {
            { cluster:resize(220, 220, "bilinear"), 24, 24, 220, 220 },
            { burst:resize(220, 220, "bilinear"), 296, 24, 220, 220 },
            { trail:resize(220, 88, "bilinear"), 24, 252, 220, 88 },
            { lifecycle:resize(272, 88, "bilinear"), 244, 252, 272, 88 },
        }
        for _, card in ipairs(cards) do
            canvas:paste(card[1], card[2], card[3])
            draw_outline(canvas, card[2], card[3], card[4], card[5], 232, 236, 244, 255)
        end

        local path = OUT .. "particle_contact_sheet.png"
        save_png(canvas, path)
    end)
    -- Does: Runs "specialized renderer strip" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by LParticleSystem:drawExplosionToImage, LParticleSystem:drawRainToImage, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/particle/<artifact>
    -- Why: This is meaningful only if the visible/text output comes from LParticleSystem:drawExplosionToImage, LParticleSystem:drawRainToImage, and related owner calls; export helpers are just the container.

    it("PNG: specialized renderer strip", function()
        local explosion = lurek.particle.newSystem({ seed = 1201, maxParticles = 32 })
        explosion:setPosition(60, 60)
        local img_explosion = explosion:drawExplosionToImage(120, 120)

        local rain = lurek.particle.newSystem({ seed = 1202, maxParticles = 64 })
        rain:setPosition(60, 60)
        local img_rain = rain:drawRainToImage(120, 120)

        local spark = lurek.particle.newSystem({ seed = 1203, maxParticles = 48 })
        spark:setPosition(60, 60)
        local img_spark = spark:drawSparkTrailToImage(120, 120)

        local over = lurek.particle.newSystem({ seed = 1204, maxParticles = 24 })
        over:setPosition(60, 60)
        local composite = lurek.image.newImageData(120, 120)
        composite:fill(20, 24, 30, 255)
        over:drawOverImage(composite)
        over:paintOnto(composite)

        local canvas = lurek.image.newImageData(268, 268)
        canvas:fill(12, 14, 20, 255)
        local cards = {
            { img_explosion, 16, 16 },
            { img_rain, 132, 16 },
            { img_spark, 16, 132 },
            { composite, 132, 132 },
        }
        for _, card in ipairs(cards) do
            canvas:paste(card[1], card[2], card[3])
            draw_outline(canvas, card[2], card[3], 120, 120, 232, 236, 244, 255)
        end

        save_png(canvas, OUT .. "particle_specialized_renderer_strip.png")
        lurek.particle.release(explosion)
        lurek.particle.release(rain)
        lurek.particle.release(spark)
        lurek.particle.release(over)
    end)
end)
test_summary()
