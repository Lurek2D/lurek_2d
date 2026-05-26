-- Evidence tests: particle module
-- Artifacts are generated via lurek.particle APIs (toImage/drawToImage).


local OUT = "tests/output/particle/"

-- @describe Evidence: lurek.particle API
describe("Evidence: lurek.particle API", function()
    before_each(function()
        ensure_evidence_dir("particle")
    end)

    -- @evidence file
    it("PNG: emitter cluster snapshot", function()
        local ps = lurek.particle.newSystem({
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
        local path = OUT .. "particle_positions.png"
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)

        lurek.particle.release(ps)
    end)

    -- @evidence file
    it("PNG: burst emission", function()
        local ps = lurek.particle.newSystem({
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
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)

        lurek.particle.release(ps)
    end)

    -- @evidence file
    it("PNG: attractor contraction", function()
        local ps = lurek.particle.newSystem({
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
        local path = OUT .. "particle_attractor.png"
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)

        lurek.particle.release(ps)
    end)

    -- @evidence file
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
        local path = OUT .. "particle_trail.png"
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)
end)

test_summary()
