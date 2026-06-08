-- API-level behavioral smoke migrated from tests/rust/ext/effects_audio_runtime_smoke_tests.rs

-- @describe effects/audio runtime smoke via lurek API
describe("effects/audio runtime smoke via lurek API", function()
    -- @covers lurek.light
    -- @covers lurek.particle
    -- @covers lurek.effect
    -- @covers lurek.audio
    it("module tables exist", function()
        expect_type("table", lurek.light)
        expect_type("table", lurek.particle)
        expect_type("table", lurek.effect)
        expect_type("table", lurek.audio)
    end)

    -- @covers lurek.light.clear
    -- @covers lurek.light.newLight
    it("light module creates a light", function()
        lurek.light.clear()
        local light = lurek.light.newLight(64, 64, 32)
        expect_not_nil(light)
        expect_type("userdata", light)
    end)

    -- @covers lurek.particle.isActive
    -- @covers lurek.particle.newSystem
    it("particle module creates system and reports active flag type", function()
        local ps = lurek.particle.newSystem({ emissionRate = 10, maxParticles = 32 })
        expect_not_nil(ps)
        expect_type("boolean", lurek.particle.isActive(ps))
    end)

    -- @covers LEffectStack:add
    -- @covers lurek.effect.newEffect
    -- @covers lurek.effect.newStack
    it("effect module creates stack and adds effect", function()
        local stack = lurek.effect.newStack(320, 240)
        local fx = lurek.effect.newEffect("bloom")
        expect_not_nil(stack)
        expect_not_nil(fx)
        expect_no_error(function() stack:add(fx) end)
    end)

    -- @covers lurek.audio.getMasterVolume
    -- @covers lurek.audio.setMasterVolume
    it("audio module master volume roundtrip is numeric and clamped domain", function()
        lurek.audio.setMasterVolume(0.25)
        local vol = lurek.audio.getMasterVolume()
        expect_type("number", vol)
        expect_equal(vol >= 0.0 and vol <= 1.0, true)
    end)
end)
test_summary()
