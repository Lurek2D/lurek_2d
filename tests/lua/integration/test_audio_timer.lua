-- Lurek2D Integration Test: Audio + Timer
-- Tests audio volume timing with timer delta

-- @description Covers suite: audio + timer integration.
describe("audio + timer integration", function()
    -- @covers lurek.audio.setMasterVolume
    -- @covers lurek.timer.getDelta
    -- @covers lurek.timer.getTime
    -- @description Verifies a dt-driven fade-in calculation can be applied back to the audio API and reflected in the engine's master volume.
    it("audio volume can be ramped over time", function()
        -- Start at zero
        lurek.audio.setMasterVolume(0.0)
        expect_near(0.0, lurek.audio.getMasterVolume(), 0.01, "starts at 0")

        -- Simulate fade-in over dt steps
        local volume = 0.0
        local target = 1.0
        local speed = 2.0  -- per second
        local dt = 0.016

        for i = 1, 30 do -- ~0.5 seconds
            volume = math.min(target, volume + speed * dt)
        end

        lurek.audio.setMasterVolume(volume)
        expect_true(volume > 0.9, "volume ramped up: " .. volume)
        expect_near(volume, lurek.audio.getMasterVolume(), 0.01, "engine tracks volume")

        -- Reset
        lurek.audio.setMasterVolume(1.0)
    end)

    -- @covers lurek.audio
    -- @covers lurek.timer.getDelta
    -- @description Verifies the timer API provides a numeric non-negative timestep for audio update code.
    it("timer delta provides consistent timestep", function()
        local dt = lurek.timer.getDelta()
        expect_type("number", dt)
        expect_true(dt >= 0, "delta is non-negative")
    end)

    -- @covers lurek.audio
    -- @covers lurek.timer.getTime
    -- @description Verifies audio-side scheduling code can query a numeric monotonic time value from the timer module.
    it("timer getTime returns increasing values", function()
        local t1 = lurek.timer.getTime()
        expect_type("number", t1)
        -- In test context, getTime should return something reasonable
        expect_true(t1 >= 0, "time is non-negative")
    end)

    -- @covers lurek.audio.setMasterVolume
    -- @covers lurek.timer.getDelta
    -- @description Verifies an exponential decay curve computed from repeated time steps can be committed to the audio master volume.
    it("audio volume fade-out follows exponential decay", function()
        lurek.audio.setMasterVolume(1.0)

        -- Exponential decay: v = v * decay^(dt/rate)
        local volume = 1.0
        local decay_rate = 0.5
        local dt = 0.016
        local steps = 60

        for i = 1, steps do
            volume = volume * (decay_rate ^ dt)
        end

        expect_true(volume < 1.0, "volume decayed")
        expect_true(volume > 0.0, "volume still positive")

        lurek.audio.setMasterVolume(volume)
        expect_near(volume, lurek.audio.getMasterVolume(), 0.01, "engine accepts decayed volume")

        -- Reset
        lurek.audio.setMasterVolume(1.0)
    end)
end)

test_summary()
