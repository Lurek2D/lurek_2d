-- Evidence tests: particle module
-- Artifacts are generated via lurek.particle APIs (toImage/drawToImage).



local OUT = evidence_output_dir("particle")

local function save_png(img, path)
    lurek.image.savePNG(img, path)
    expect_evidence_created(path)
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

    -- @evidence lurek.image.savePNG
    -- @evidence lurek.particle.newSystem
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

        local img = ps:toImage(200, 200)
        local path = OUT .. "particle_emitter_cluster_snapshot.png"
        save_png(img, path)

        lurek.particle.release(ps)
    end)

    -- @evidence lurek.particle.newSystem
    -- @evidence LParticleSystem:update
    -- @evidence LParticleSystem:drawToImage
    -- @evidence lurek.image.saveGIF
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

    -- @evidence lurek.image.savePNG
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

    -- @evidence lurek.image.savePNG
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

    -- @evidence lurek.image.savePNG
    -- @evidence lurek.particle.newTrail
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

    -- @evidence lurek.particle.drawLifecycleToImage
    -- @evidence lurek.image.savePNG
    it("PNG: lifecycle chart snapshot", function()
        local img = lurek.particle.drawLifecycleToImage({
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
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)
end)
test_summary()
