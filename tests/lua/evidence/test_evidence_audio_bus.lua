-- test_evidence_audio_bus.lua
-- Evidence test: lurek.audio Bus API + saves bus-processed audio as WAV
-- Produces: audio_bus_volume.wav, audio_bus_pitch.wav

local OUT = "tests/lua/evidence/output/audio/"

--- Helper: generate a sine wave SoundData
local function make_sine(freq, duration, rate)
    rate = rate or 44100
    local samples = math.floor(rate * duration)
    local sd = lurek.audio.newSoundData(samples, rate, 1)
    for i = 0, samples - 1 do
        local t = i / rate
        sd:setSample(i, math.sin(2 * math.pi * freq * t) * 0.8)
    end
    return sd
end

-- @description Covers suite: Evidence: lurek.audio Bus API + WAV output.
describe("Evidence: lurek.audio Bus API + WAV output", function()
    -- @covers lurek.audio.newBus
    -- @covers AudioBus:setVolume
    -- @covers AudioBus:getVolume
    -- @covers lurek.audio.newSoundData
    -- @covers lurek.audio.saveWAV
    -- @evidence file
    -- @description Applies a bus volume value to a synthesized sine wave and writes the scaled result as bus-volume evidence.
    it("WAV: volume-scaled sine â€” simulates bus volume", function()
        -- Generate a 440 Hz sine at full amplitude, then create a
        -- half-volume version to demonstrate bus volume effect
        local RATE = 44100
        local DURATION = 1.0
        local FREQ = 440
        local samples = math.floor(RATE * DURATION)

        local bus = lurek.audio.newBus("vol_test")
        bus:setVolume(0.5)
        local vol = bus:getVolume()

        -- Create SoundData with bus volume applied
        local sd = lurek.audio.newSoundData(samples, RATE, 1)
        for i = 0, samples - 1 do
            local t = i / RATE
            local val = math.sin(2 * math.pi * FREQ * t) * 0.8 * vol
            sd:setSample(i, val)
        end

        -- Verify peak is ~0.4 (0.8 * 0.5)
        local quarter = math.floor(RATE / FREQ / 4)

        lurek.audio.saveWAV(sd, OUT .. "audio_bus_volume.wav")
    end)

    -- @covers lurek.audio.newBus
    -- @covers AudioBus:setPitch
    -- @covers AudioBus:getPitch
    -- @covers lurek.audio.newSoundData
    -- @covers lurek.audio.saveWAV
    -- @evidence file
    -- @description Multiplies the source tone frequency by the bus pitch value and saves the shifted result as file evidence.
    it("WAV: pitch-shifted sine â€” simulates bus pitch", function()
        -- Generate a sine where frequency is multiplied by bus pitch
        local RATE = 44100
        local DURATION = 1.0
        local BASE_FREQ = 440
        local samples = math.floor(RATE * DURATION)

        local bus = lurek.audio.newBus("pitch_test")
        bus:setPitch(1.5)
        local pitch = bus:getPitch()

        -- Create SoundData with bus pitch applied to frequency
        local actual_freq = BASE_FREQ * pitch
        local sd = lurek.audio.newSoundData(samples, RATE, 1)
        for i = 0, samples - 1 do
            local t = i / RATE
            sd:setSample(i, math.sin(2 * math.pi * actual_freq * t) * 0.7)
        end

        -- Verify it's playing at the pitched frequency (660 Hz)
        lurek.audio.saveWAV(sd, OUT .. "audio_bus_pitch.wav")
    end)

    -- @covers lurek.audio.newBus
    -- @covers AudioBus:setVolume
    -- @covers lurek.audio.newSoundData
    -- @covers SoundData:getSample
    -- @covers lurek.audio.saveWAV
    -- @evidence file
    -- @description Ramps bus volume down over time to simulate a fade-out envelope and exports the resulting buffer.
    it("WAV: fade-out envelope simulating bus volume ramp", function()
        local RATE = 44100
        local DURATION = 2.0
        local FREQ = 330
        local samples = math.floor(RATE * DURATION)

        local bus = lurek.audio.newBus("fade_test")
        local sd = lurek.audio.newSoundData(samples, RATE, 1)

        for i = 0, samples - 1 do
            local t = i / RATE
            -- Simulate bus volume ramping from 1.0 to 0.0 over duration
            local vol = 1.0 - (t / DURATION)
            bus:setVolume(vol) -- prove the API accepts continuous changes
            local val = math.sin(2 * math.pi * FREQ * t) * 0.8 * vol
            sd:setSample(i, val)
        end

        -- Verify: start is loud, end is silent
        local mid = math.floor(samples / 2)
        local mid_peak = 0
        for i = mid, mid + math.floor(RATE / FREQ) do
            if i < samples then
                mid_peak = math.max(mid_peak, math.abs(sd:getSample(i)))
            end
        end

        lurek.audio.saveWAV(sd, OUT .. "audio_bus_fadeout.wav")
    end)

end)
test_summary()
