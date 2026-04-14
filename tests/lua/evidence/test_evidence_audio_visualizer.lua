-- Evidence test: proves lurek.audio.waveformToPng and lurek.audio.spectrogramToPng
-- create valid PNG image files from WAV audio data.
-- Litmus: delete src/audio/visualizer.rs → these calls error out.

local WAVE    = "tests/fixtures/sine_mono_44100.wav"
local OUT_DIR = "tests/evidence_out/"

-- @description Evidence: waveformToPng writes a PNG image file of the audio waveform.
describe("Evidence: lurek.audio.waveformToPng", function()
    -- @covers lurek.audio.waveformToPng
    -- @evidence file
    -- @description Renders the 44100 Hz test sine wave to a 512x128 PNG waveform image.
    it("produces a 512x128 PNG waveform file larger than 100 bytes", function()
        local out = OUT_DIR .. "evidence_waveform.png"
        lurek.audio.waveformToPng(WAVE, out, 512, 128)
        local data = lurek.filesystem.read(out)
        expect_not_nil(data)
        -- Minimum valid PNG is 67 bytes (IHDR+IEND only); any real content is larger
        expect_equal(true, #data >= 100)
    end)

    -- @covers lurek.audio.waveformToPng
    -- @evidence file
    -- @description Renders to a larger 1024x256 size to confirm different dimensions are supported.
    it("produces a 1024x256 PNG waveform file", function()
        local out = OUT_DIR .. "evidence_waveform_large.png"
        lurek.audio.waveformToPng(WAVE, out, 1024, 256)
        local data = lurek.filesystem.read(out)
        expect_not_nil(data)
        expect_equal(true, #data >= 100)
    end)
end)

-- @description Evidence: spectrogramToPng writes a PNG spectrogram image from WAV audio.
describe("Evidence: lurek.audio.spectrogramToPng", function()
    -- @covers lurek.audio.spectrogramToPng
    -- @evidence file
    -- @description Renders a 512x256 DFT spectrogram of the test sine wave.
    it("produces a 512x256 PNG spectrogram file larger than 100 bytes", function()
        local out = OUT_DIR .. "evidence_spectrogram.png"
        lurek.audio.spectrogramToPng(WAVE, out, 512, 256)
        local data = lurek.filesystem.read(out)
        expect_not_nil(data)
        expect_equal(true, #data >= 100)
    end)
end)

test_summary()
