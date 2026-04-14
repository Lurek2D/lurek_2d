-- Tests for stereo management API:
--   lurek.audio.setStereoWidth, lurek.audio.setRandomPitch, lurek.audio.crossfade
-- No audio hardware required.

local WAVE = "tests/fixtures/sine_mono_44100.wav"

-- @description Covers suite: lurek.audio.setStereoWidth.
describe("lurek.audio.setStereoWidth", function()
    -- @covers lurek.audio.setStereoWidth
    it("sets stereo width on a valid source without error", function()
        local src = lurek.audio.newSource(WAVE, "static")
        lurek.audio.setStereoWidth(src, 1.5)  -- 1.5 = slight widening
    end)

    -- @covers lurek.audio.setStereoWidth
    it("clamps stereo width to [0.0, 2.0] silently", function()
        local src = lurek.audio.newSource(WAVE, "static")
        lurek.audio.setStereoWidth(src, -1.0)  -- should clamp, not error
        lurek.audio.setStereoWidth(src, 5.0)   -- should clamp, not error
    end)

    -- @covers lurek.audio.getStereoWidth
    it("getStereoWidth returns the last set value (clamped)", function()
        local src = lurek.audio.newSource(WAVE, "static")
        lurek.audio.setStereoWidth(src, 0.5)
        local w = lurek.audio.getStereoWidth(src)
        expect_near(0.5, w, 0.001)
    end)

    -- @covers lurek.audio.setStereoWidth
    it("errors on invalid source handle", function()
        expect_error(function()
            lurek.audio.setStereoWidth(99999999, 1.0)
        end, "invalid")
    end)
end)

-- @description Covers suite: lurek.audio.setRandomPitch.
describe("lurek.audio.setRandomPitch", function()
    -- @covers lurek.audio.setRandomPitch
    it("sets a random pitch range on a source", function()
        local src = lurek.audio.newSource(WAVE, "static")
        lurek.audio.setRandomPitch(src, 0.9, 1.1)
    end)

    -- @covers lurek.audio.setRandomPitch
    it("errors if min > max", function()
        local src = lurek.audio.newSource(WAVE, "static")
        expect_error(function()
            lurek.audio.setRandomPitch(src, 1.5, 0.5)
        end, "min must be")
    end)

    -- @covers lurek.audio.setRandomPitch
    it("errors on invalid source", function()
        expect_error(function()
            lurek.audio.setRandomPitch(12345678, 0.9, 1.1)
        end, "invalid")
    end)

    -- @covers lurek.audio.clearRandomPitch
    it("clearRandomPitch removes the random pitch range", function()
        local src = lurek.audio.newSource(WAVE, "static")
        lurek.audio.setRandomPitch(src, 0.9, 1.1)
        lurek.audio.clearRandomPitch(src)  -- should not error
    end)
end)

-- @description Covers suite: lurek.audio.crossfade.
describe("lurek.audio.crossfade", function()
    -- @covers lurek.audio.crossfade
    it("crossfade between two sources does not error", function()
        local src_a = lurek.audio.newSource(WAVE, "static")
        local src_b = lurek.audio.newSource(WAVE, "static")
        lurek.audio.crossfade(src_a, src_b, 0.5)
    end)

    -- @covers lurek.audio.crossfade
    it("errors if duration is negative", function()
        local src_a = lurek.audio.newSource(WAVE, "static")
        local src_b = lurek.audio.newSource(WAVE, "static")
        expect_error(function()
            lurek.audio.crossfade(src_a, src_b, -1.0)
        end, "duration")
    end)

    -- @covers lurek.audio.crossfade
    it("errors if first source is invalid", function()
        local src_b = lurek.audio.newSource(WAVE, "static")
        expect_error(function()
            lurek.audio.crossfade(99999999, src_b, 0.5)
        end, "invalid")
    end)
end)

-- @description Covers suite: lurek.audio.getBusPeak.
describe("lurek.audio.getBusPeak", function()
    -- @covers lurek.audio.getBusPeak
    it("returns a number for a known bus", function()
        lurek.audio.create_bus("peak_test_bus")
        local peak = lurek.audio.getBusPeak("peak_test_bus")
        expect_type("number", peak)
    end)

    -- @covers lurek.audio.getBusPeak
    it("returns 0.0 when bus is idle", function()
        lurek.audio.create_bus("peak_idle_bus")
        local peak = lurek.audio.getBusPeak("peak_idle_bus")
        expect_near(0.0, peak, 0.001)
    end)

    -- @covers lurek.audio.getBusPeak
    it("errors for unknown bus", function()
        expect_error(function()
            lurek.audio.getBusPeak("nope_bus")
        end, "bus not found")
    end)
end)

-- @description Covers suite: lurek.audio.getBusRms.
describe("lurek.audio.getBusRms", function()
    -- @covers lurek.audio.getBusRms
    it("returns a number for a known bus", function()
        lurek.audio.create_bus("rms_test_bus")
        local rms = lurek.audio.getBusRms("rms_test_bus")
        expect_type("number", rms)
    end)

    -- @covers lurek.audio.getBusRms
    it("returns 0.0 when bus is idle", function()
        lurek.audio.create_bus("rms_idle_bus")
        local rms = lurek.audio.getBusRms("rms_idle_bus")
        expect_near(0.0, rms, 0.001)
    end)
end)

test_summary()
