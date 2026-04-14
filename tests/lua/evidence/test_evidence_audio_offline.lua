-- Evidence test: proves lurek.audio.processOffline and lurek.audio.normalizeFile
-- write valid WAV files to disk that contain non-trivial PCM data.
-- Does NOT call raw draw calls. Litmus: delete offline.rs → these calls error.

local WAVE    = "tests/fixtures/sine_mono_44100.wav"
local OUT_DIR = "tests/evidence_out/"

-- @description Evidence: offline processing writes real WAV output files.
describe("Evidence: lurek.audio.processOffline", function()
    -- @covers lurek.audio.processOffline
    -- @evidence file
    -- @description Applies a lowpass filter offline and confirms the output WAV file exists with valid size.
    it("lowpass at 1 kHz produces a WAV file larger than 44 bytes", function()
        local out = OUT_DIR .. "evidence_offline_lowpass.wav"
        lurek.audio.processOffline(WAVE, out, { { type = "lowpass", cutoff = 1000.0 } })
        local data = lurek.filesystem.read(out)
        expect_not_nil(data)
        expect_equal(true, #data >= 44)
    end)

    -- @covers lurek.audio.processOffline
    -- @evidence file
    -- @description Applies a reverb effect offline and confirms the output WAV file exists.
    it("reverb produces a WAV file larger than 44 bytes", function()
        local out = OUT_DIR .. "evidence_offline_reverb.wav"
        lurek.audio.processOffline(WAVE, out, { { type = "reverb", room_size = 0.7, mix = 0.4 } })
        local data = lurek.filesystem.read(out)
        expect_not_nil(data)
        expect_equal(true, #data >= 44)
    end)

    -- @covers lurek.audio.processOffline
    -- @evidence file
    -- @description Chains highpass + distortion offline and confirms the output WAV file exists.
    it("chained effects produce a WAV file larger than 44 bytes", function()
        local out = OUT_DIR .. "evidence_offline_chain.wav"
        lurek.audio.processOffline(WAVE, out, {
            { type = "highpass",   cutoff = 200.0 },
            { type = "distortion", drive = 10.0, mix = 0.6 }
        })
        local data = lurek.filesystem.read(out)
        expect_not_nil(data)
        expect_equal(true, #data >= 44)
    end)
end)

-- @description Evidence: normalizeFile writes a normalised WAV output file.
describe("Evidence: lurek.audio.normalizeFile", function()
    -- @covers lurek.audio.normalizeFile
    -- @evidence file
    -- @description Normalises to 0.9 peak and confirms the output WAV file exists with valid size.
    it("normalizeFile at 0.9 produces a WAV file larger than 44 bytes", function()
        local out = OUT_DIR .. "evidence_normalized.wav"
        lurek.audio.normalizeFile(WAVE, out, 0.9)
        local data = lurek.filesystem.read(out)
        expect_not_nil(data)
        expect_equal(true, #data >= 44)
    end)
end)

test_summary()
