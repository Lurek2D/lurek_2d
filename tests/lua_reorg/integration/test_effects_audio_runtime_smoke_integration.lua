-- Integration: cross-module smoke for light, particle, effect, and audio runtime APIs

-- @describe effects/audio runtime smoke via lurek API
describe("effects/audio runtime smoke via lurek API", function()
    -- @integration lurek.light.newLight
    -- @integration lurek.light.clear
    it("light module creates a light", function()
        lurek.light.clear()
        local light = lurek.light.newLight(64, 64, 32)
        expect_not_nil(light)
        expect_type("userdata", light)
    end)

    -- @integration lurek.particle.newSystem
    -- @integration LParticleSystem:isActive
    it("particle module creates a system and exposes active state", function()
        local ps = lurek.particle.newSystem({ emissionRate = 10, maxParticles = 32 })
        expect_not_nil(ps)
        expect_type("boolean", ps:isActive())
    end)

    -- @integration lurek.effect.newStack
    -- @integration lurek.effect.newEffect
    -- @integration LPostFxStack:add
    it("effect module creates a stack and accepts a built-in effect", function()
        local stack = lurek.effect.newStack(320, 240)
        local fx = lurek.effect.newEffect("bloom")
        expect_not_nil(stack)
        expect_not_nil(fx)
        expect_no_error(function()
            stack:add(fx)
        end)
    end)

    -- @integration lurek.audio.setMasterVolume
    -- @integration lurek.audio.getMasterVolume
    it("audio master volume roundtrips through the public API", function()
        local original = lurek.audio.getMasterVolume()
        lurek.audio.setMasterVolume(0.25)

        local vol = lurek.audio.getMasterVolume()
        expect_type("number", vol)
        expect_true(vol >= 0.0 and vol <= 1.0)
        expect_near(0.25, vol, 0.05)

        lurek.audio.setMasterVolume(original)
    end)
end)

test_summary()
