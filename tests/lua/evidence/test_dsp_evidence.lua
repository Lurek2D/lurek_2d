-- Canonical evidence file for lurek.dsp artifacts.
-- @covers lurek.audio.saveWAV
-- @covers lurek.dsp.applyBandpass
-- @covers lurek.dsp.applyGain
-- @covers lurek.dsp.applyHighpass
-- @covers lurek.dsp.applyLowpass
-- @covers lurek.dsp.newSawtoothWave
-- @covers lurek.dsp.newSineWave
-- @covers lurek.dsp.newSquareWave
-- @covers lurek.dsp.newTriangleWave
-- @covers lurek.dsp.newWhiteNoise
-- @covers lurek.dsp.normalize
-- @covers lurek.dsp.processOffline
-- @covers lurek.dsp.spectrogramToPng
-- @covers lurek.dsp.waveformToPng
-- @covers lurek.image.newImageData
-- @covers lurek.image.savePNG



local OUT = evidence_output_dir("dsp")
local FIXTURE_WAVE = "tests/fixtures/sine_mono_44100.wav"
local SPECTROGRAM_OPTIONS = {
    inputWindowSize = 512,
    fftPoints = 2048,
    dynamicRangeDb = 78,
    frequencyScale = "log",
}

local function save_png(img, path)
    lurek.image.savePNG(img, path)
    expect_evidence_created(path)
end

local function save_wav(sound, path)
    lurek.audio.saveWAV(sound, path)
    expect_evidence_created(path)
end

local function save_waveform_from_wav(wav_path, waveform_path)
    lurek.dsp.waveformToPng(wav_path, waveform_path, 1024, 256)
    expect_evidence_created(waveform_path)
end

local function save_spectrogram_from_wav(wav_path, spectrogram_path)
    lurek.dsp.spectrogramToPng(wav_path, spectrogram_path, 640, 320, SPECTROGRAM_OPTIONS)
    expect_evidence_created(spectrogram_path)
end

local function save_spectrogram_from_sound(sound, wav_path, spectrogram_path)
    save_wav(sound, wav_path)
    save_spectrogram_from_wav(wav_path, spectrogram_path)
end

local function draw_outline(img, x, y, w, h, r, g, b, a)
    img:drawLine(x, y, x + w - 1, y, r, g, b, a or 255)
    img:drawLine(x + w - 1, y, x + w - 1, y + h - 1, r, g, b, a or 255)
    img:drawLine(x + w - 1, y + h - 1, x, y + h - 1, r, g, b, a or 255)
    img:drawLine(x, y + h - 1, x, y, r, g, b, a or 255)
end

local function plot_sound_waveform(img, sound, x, y, w, h, color)
    local channels = math.max(1, sound:getChannelCount())
    local frame_count = math.max(1, math.floor(sound:getSampleCount() / channels))
    local mid_y = y + math.floor(h * 0.5)
    local amplitude = math.max(1, math.floor((h - 12) * 0.5))

    img:drawLine(x, mid_y, x + w - 1, mid_y, 52, 60, 78, 255)

    local prev_x = x
    local prev_y = mid_y
    for px = 0, w - 1 do
        local t = px / math.max(1, w - 1)
        local frame = math.min(frame_count - 1, math.floor(t * (frame_count - 1)))
        local sample = tonumber(sound:getSample(frame * channels)) or 0.0
        sample = math.max(-1.0, math.min(1.0, sample))
        local py = mid_y - math.floor(sample * amplitude + 0.5)
        local cx = x + px
        if px > 0 then
            img:drawLine(prev_x, prev_y, cx, py, color[1], color[2], color[3], 255)
        end
        prev_x = cx
        prev_y = py
    end
end

local function save_waveform_preview(sound, path, color)
    local img = lurek.image.newImageData(960, 260)
    img:fill(14, 16, 22, 255)
    img:drawRect(24, 28, 912, 188, 24, 28, 36, 255)
    draw_outline(img, 24, 28, 912, 188, 232, 236, 244, 255)
    plot_sound_waveform(img, sound, 40, 44, 880, 156, color)
    img:drawRect(24, 224, 912, 12, color[1], color[2], color[3], 255)
    save_png(img, path)
end

local function save_waveform_pair(before_sound, before_path, before_color, after_sound, after_path, after_color)
    save_waveform_preview(before_sound, before_path, before_color)
    save_waveform_preview(after_sound, after_path, after_color)
end

-- @describe Evidence: lurek.dsp waveform, filter, and export flows
describe("Evidence: lurek.dsp waveform, filter, and export flows", function()
    before_each(function()
        ensure_evidence_dir("dsp")
    end)

    -- Does: Generates several synthetic waveforms and plots each returned sound buffer into its own PNG.
    -- Shows: Each PNG should expose one generator output instead of folding multiple evidences into one atlas.
    -- Artifact: tests/artifacts/current/dsp/dsp_waveform_sine.png, tests/artifacts/current/dsp/dsp_waveform_square.png, tests/artifacts/current/dsp/dsp_waveform_sawtooth.png, tests/artifacts/current/dsp/dsp_waveform_triangle.png, tests/artifacts/current/dsp/dsp_waveform_white_noise.png
    -- Why: This is meaningful because each image is derived from samples produced by one lurek.dsp generator, not from a bespoke waveform renderer in the API.

    it("PNG: generator waveform previews", function()
        local waves = {
            { "sine", lurek.dsp.newSineWave(440, 0.05, 22050, 0.8), { 80, 180, 240 } },
            { "square", lurek.dsp.newSquareWave(440, 0.05, 22050, 0.8), { 220, 100, 100 } },
            { "sawtooth", lurek.dsp.newSawtoothWave(440, 0.05, 22050, 0.8), { 80, 220, 100 } },
            { "triangle", lurek.dsp.newTriangleWave(440, 0.05, 22050, 0.8), { 240, 200, 50 } },
            { "white_noise", lurek.dsp.newWhiteNoise(0.05, 22050, 0.8, 42), { 180, 120, 220 } },
        }

        for i, entry in ipairs(waves) do
            local name = entry[1]
            local sound = entry[2]
            local color = entry[3]
            save_waveform_preview(sound, OUT .. "dsp_waveform_" .. name .. ".png", color)
        end
    end)

    -- Does: Applies a low-pass filter to one generated tone and writes separate source/filtered sample previews.
    -- Shows: The PNG pair should reveal the smoothing effect of the low-pass operation without collapsing both evidences into one file.
    -- Artifact: tests/artifacts/current/dsp/dsp_lowpass_source.png, tests/artifacts/current/dsp/dsp_lowpass_filtered.png, tests/artifacts/current/dsp/dsp_lowpass_filtered.wav, tests/artifacts/current/dsp/dsp_lowpass_filtered_spectrogram.png
    -- Why: This is meaningful because both files come from actual DSP output buffers and not from hand-made art.

    it("PNG: low-pass before-after comparison", function()
        local before = lurek.dsp.newSineWave(4000, 0.05, 22050, 0.8)
        local after = lurek.dsp.newSineWave(4000, 0.05, 22050, 0.8)
        lurek.dsp.applyLowpass(after, 300)
        save_waveform_pair(
            before,
            OUT .. "dsp_lowpass_source.png",
            { 90, 180, 240 },
            after,
            OUT .. "dsp_lowpass_filtered.png",
            { 255, 160, 80 }
        )
        save_spectrogram_from_sound(
            after,
            OUT .. "dsp_lowpass_filtered.wav",
            OUT .. "dsp_lowpass_filtered_spectrogram.png"
        )
    end)

    -- Does: Applies a high-pass filter to one low-frequency tone and writes separate source/filtered previews.
    -- Shows: The filtered PNG should collapse much of the original low-frequency energy without sharing a board with the source.
    -- Artifact: tests/artifacts/current/dsp/dsp_highpass_source.png, tests/artifacts/current/dsp/dsp_highpass_filtered.png, tests/artifacts/current/dsp/dsp_highpass_filtered.wav, tests/artifacts/current/dsp/dsp_highpass_filtered_spectrogram.png
    -- Why: This is meaningful because the effect is produced by lurek.dsp.applyHighpass on the sampled sound buffer.

    it("PNG: high-pass before-after comparison", function()
        local before = lurek.dsp.newSineWave(300, 0.05, 22050, 0.8)
        local after = lurek.dsp.newSineWave(300, 0.05, 22050, 0.8)
        lurek.dsp.applyHighpass(after, 2000)
        save_waveform_pair(
            before,
            OUT .. "dsp_highpass_source.png",
            { 90, 180, 240 },
            after,
            OUT .. "dsp_highpass_filtered.png",
            { 255, 160, 80 }
        )
        save_spectrogram_from_sound(
            after,
            OUT .. "dsp_highpass_filtered.wav",
            OUT .. "dsp_highpass_filtered_spectrogram.png"
        )
    end)

    -- Does: Applies a band-pass filter to deterministic noise and writes separate source/filtered previews.
    -- Shows: The filtered PNG should show a visibly narrower waveform texture without sharing a composite compare board.
    -- Artifact: tests/artifacts/current/dsp/dsp_bandpass_source.png, tests/artifacts/current/dsp/dsp_bandpass_filtered.png, tests/artifacts/current/dsp/dsp_bandpass_filtered.wav, tests/artifacts/current/dsp/dsp_bandpass_filtered_spectrogram.png
    -- Why: This is meaningful because the output is created by lurek.dsp.applyBandpass on one real noise buffer.

    it("PNG: band-pass filtered noise comparison", function()
        local before = lurek.dsp.newWhiteNoise(0.05, 22050, 0.8, 42)
        local after = lurek.dsp.newWhiteNoise(0.05, 22050, 0.8, 42)
        lurek.dsp.applyBandpass(after, 800, 3000)
        save_waveform_pair(
            before,
            OUT .. "dsp_bandpass_source.png",
            { 120, 200, 255 },
            after,
            OUT .. "dsp_bandpass_filtered.png",
            { 255, 180, 100 }
        )
        save_spectrogram_from_sound(
            after,
            OUT .. "dsp_bandpass_filtered.wav",
            OUT .. "dsp_bandpass_filtered_spectrogram.png"
        )
    end)

    -- Does: Applies a gain transform to one generated tone and writes both waveform and spectrogram previews.
    -- Shows: The waveform should retain the tone shape with larger amplitude, while the spectrogram should keep the same frequency band with brighter energy.
    -- Artifact: tests/artifacts/current/dsp/dsp_gain_boost.wav, tests/artifacts/current/dsp/dsp_gain_boost_waveform.png, tests/artifacts/current/dsp/dsp_gain_boost_spectrogram.png
    -- Why: This is meaningful because the preview pair comes from a buffer transformed by lurek.dsp.applyGain.

    it("PNG: gain transform waveform and spectrogram", function()
        local sound = lurek.dsp.newSineWave(880, 0.08, 22050, 0.35)
        lurek.dsp.applyGain(sound, 2.0)
        local wav = OUT .. "dsp_gain_boost.wav"
        save_wav(sound, wav)
        save_waveform_from_wav(wav, OUT .. "dsp_gain_boost_waveform.png")
        save_spectrogram_from_wav(wav, OUT .. "dsp_gain_boost_spectrogram.png")
    end)

    -- Does: Processes a fixture WAV offline with one low-pass step and exports the resulting audio plus waveform and spectrogram previews.
    -- Shows: The output fixture should be ready for listening or later golden comparison, and the PNGs should show the filtered time and frequency shape.
    -- Artifact: tests/artifacts/current/dsp/dsp_offline_lowpass_1khz.wav, tests/artifacts/current/dsp/dsp_offline_lowpass_1khz_waveform.png, tests/artifacts/current/dsp/dsp_offline_lowpass_1khz_spectrogram.png
    -- Why: This is meaningful because every artifact is emitted from lurek.dsp.processOffline output using stable public visualization helpers.

    it("WAV: offline processed low-pass fixture", function()
        local out = OUT .. "dsp_offline_lowpass_1khz.wav"
        lurek.dsp.processOffline(FIXTURE_WAVE, out, {
            { type = "lowpass", cutoff = 1000.0 },
        })
        expect_evidence_created(out)
        save_waveform_from_wav(out, OUT .. "dsp_offline_lowpass_1khz_waveform.png")
        save_spectrogram_from_wav(out, OUT .. "dsp_offline_lowpass_1khz_spectrogram.png")
    end)

    -- Does: Normalizes one fixture WAV to a target peak and exports the result plus waveform and spectrogram previews.
    -- Shows: The output should preserve the source shape while lifting or lowering the peak to the requested value across the audio and PNG artifacts.
    -- Artifact: tests/artifacts/current/dsp/dsp_normalized_peak_09.wav, tests/artifacts/current/dsp/dsp_normalized_peak_09_waveform.png, tests/artifacts/current/dsp/dsp_normalized_peak_09_spectrogram.png
    -- Why: This is meaningful because lurek.dsp.normalize writes the transformed audio and the visualizations inspect that exact output.

    it("WAV: normalized fixture", function()
        local out = OUT .. "dsp_normalized_peak_09.wav"
        lurek.dsp.normalize(FIXTURE_WAVE, out, 0.9)
        expect_evidence_created(out)
        save_waveform_from_wav(out, OUT .. "dsp_normalized_peak_09_waveform.png")
        save_spectrogram_from_wav(out, OUT .. "dsp_normalized_peak_09_spectrogram.png")
    end)

    -- Does: Exports both waveform and spectrogram PNGs from the same fixture WAV using explicit spectrogram window and FFT sizes.
    -- Shows: The pair should give time-domain and frequency-domain views of the same source audio, with the spectrogram using a larger FFT than input window for sharper frequency detail.
    -- Artifact: tests/artifacts/current/dsp/dsp_fixture_waveform.png, tests/artifacts/current/dsp/dsp_fixture_spectrogram.png
    -- Why: This is meaningful because the exported images are the direct output of DSP analysis APIs on a real WAV fixture.

    it("PNG: waveform and spectrogram exports from wav fixture", function()
        local waveform = OUT .. "dsp_fixture_waveform.png"
        local spectrogram = OUT .. "dsp_fixture_spectrogram.png"
        lurek.dsp.waveformToPng(FIXTURE_WAVE, waveform, 1024, 256)
        lurek.dsp.spectrogramToPng(FIXTURE_WAVE, spectrogram, 640, 320, SPECTROGRAM_OPTIONS)
        expect_evidence_created(waveform)
        expect_evidence_created(spectrogram)
    end)
end)

test_summary()
