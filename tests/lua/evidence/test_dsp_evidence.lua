-- Canonical evidence file for lurek.dsp artifacts.


local OUT = evidence_output_dir("dsp")
local FIXTURE_WAVE = "tests/fixtures/sine_mono_44100.wav"

local function save_png(img, path)
    lurek.image.savePNG(img, path)
    expect_evidence_created(path)
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

local function save_waveform_compare(before_sound, after_sound, path, before_color, after_color)
    local img = lurek.image.newImageData(960, 280)
    img:fill(12, 14, 20, 255)
    img:drawRect(24, 24, 432, 216, 24, 28, 36, 255)
    img:drawRect(504, 24, 432, 216, 24, 28, 36, 255)
    draw_outline(img, 24, 24, 432, 216, 232, 236, 244, 255)
    draw_outline(img, 504, 24, 432, 216, 232, 236, 244, 255)
    plot_sound_waveform(img, before_sound, 40, 40, 400, 184, before_color)
    plot_sound_waveform(img, after_sound, 520, 40, 400, 184, after_color)
    save_png(img, path)
end

-- @describe Evidence: lurek.dsp waveform, filter, and export flows
describe("Evidence: lurek.dsp waveform, filter, and export flows", function()
    before_each(function()
        ensure_evidence_dir("dsp")
    end)

    -- Does: Generates several synthetic waveforms and plots them by sampling the returned sound buffers into one atlas image.
    -- Shows: The atlas should make the differences between sine, square, saw, triangle, and deterministic noise visually obvious.
    -- Artifact: tests/artifacts/current/dsp/dsp_waveform_generator_atlas.png
    -- Why: This is meaningful because the image is derived from samples produced by lurek.dsp generators, not from a bespoke waveform renderer in the API.

    it("PNG: generator waveform comparison atlas", function()
        local waves = {
            { lurek.dsp.newSineWave(440, 0.05, 22050, 0.8), { 80, 180, 240 } },
            { lurek.dsp.newSquareWave(440, 0.05, 22050, 0.8), { 220, 100, 100 } },
            { lurek.dsp.newSawtoothWave(440, 0.05, 22050, 0.8), { 80, 220, 100 } },
            { lurek.dsp.newTriangleWave(440, 0.05, 22050, 0.8), { 240, 200, 50 } },
            { lurek.dsp.newWhiteNoise(0.05, 22050, 0.8, 42), { 180, 120, 220 } },
        }

        local img = lurek.image.newImageData(960, 420)
        img:fill(12, 14, 20, 255)
        for i, entry in ipairs(waves) do
            local lane_y = 24 + (i - 1) * 76
            img:drawRect(24, lane_y, 912, 60, 24, 28, 36, 255)
            draw_outline(img, 24, lane_y, 912, 60, 232, 236, 244, 255)
            plot_sound_waveform(img, entry[1], 40, lane_y + 8, 880, 44, entry[2])
        end

        save_png(img, OUT .. "dsp_waveform_generator_atlas.png")
    end)

    -- Does: Applies a low-pass filter to one generated tone and plots before/after sample views side by side.
    -- Shows: The comparison should reveal the smoothing effect of the low-pass operation on the same source tone.
    -- Artifact: tests/artifacts/current/dsp/dsp_lowpass_compare.png
    -- Why: This is meaningful because both panels come from actual DSP output buffers and not from hand-made art.

    it("PNG: low-pass before-after comparison", function()
        local before = lurek.dsp.newSineWave(4000, 0.05, 22050, 0.8)
        local after = lurek.dsp.newSineWave(4000, 0.05, 22050, 0.8)
        lurek.dsp.applyLowpass(after, 300)
        save_waveform_compare(before, after, OUT .. "dsp_lowpass_compare.png", { 90, 180, 240 }, { 255, 160, 80 })
    end)

    -- Does: Applies a high-pass filter to one low-frequency tone and plots the result against the source.
    -- Shows: The after panel should collapse much of the original low-frequency energy.
    -- Artifact: tests/artifacts/current/dsp/dsp_highpass_compare.png
    -- Why: This is meaningful because the effect is produced by lurek.dsp.applyHighpass on the sampled sound buffer.

    it("PNG: high-pass before-after comparison", function()
        local before = lurek.dsp.newSineWave(300, 0.05, 22050, 0.8)
        local after = lurek.dsp.newSineWave(300, 0.05, 22050, 0.8)
        lurek.dsp.applyHighpass(after, 2000)
        save_waveform_compare(before, after, OUT .. "dsp_highpass_compare.png", { 90, 180, 240 }, { 255, 160, 80 })
    end)

    -- Does: Applies a band-pass filter to deterministic noise and plots the filtered result against the source.
    -- Shows: The evidence should show a visibly narrower waveform texture after band-pass filtering.
    -- Artifact: tests/artifacts/current/dsp/dsp_bandpass_compare.png
    -- Why: This is meaningful because the output is created by lurek.dsp.applyBandpass on one real noise buffer.

    it("PNG: band-pass filtered noise comparison", function()
        local before = lurek.dsp.newWhiteNoise(0.05, 22050, 0.8, 42)
        local after = lurek.dsp.newWhiteNoise(0.05, 22050, 0.8, 42)
        lurek.dsp.applyBandpass(after, 800, 3000)
        save_waveform_compare(before, after, OUT .. "dsp_bandpass_compare.png", { 120, 200, 255 }, { 255, 180, 100 })
    end)

    -- Does: Processes a fixture WAV offline with one low-pass step and exports the resulting audio.
    -- Shows: The output fixture should be ready for listening or later golden comparison as a filtered reference.
    -- Artifact: tests/artifacts/current/dsp/dsp_offline_lowpass_1khz.wav
    -- Why: This is meaningful because the file is emitted by lurek.dsp.processOffline from a stable source fixture.

    it("WAV: offline processed low-pass fixture", function()
        local out = OUT .. "dsp_offline_lowpass_1khz.wav"
        lurek.dsp.processOffline(FIXTURE_WAVE, out, {
            { type = "lowpass", cutoff = 1000.0 },
        })
        expect_evidence_created(out)
    end)

    -- Does: Normalizes one fixture WAV to a target peak and exports the result for later inspection.
    -- Shows: The output should preserve the source shape while lifting or lowering the peak to the requested value.
    -- Artifact: tests/artifacts/current/dsp/dsp_normalized_peak_09.wav
    -- Why: This is meaningful because lurek.dsp.normalize writes a concrete transformed audio artifact instead of a manual report.

    it("WAV: normalized fixture", function()
        local out = OUT .. "dsp_normalized_peak_09.wav"
        lurek.dsp.normalize(FIXTURE_WAVE, out, 0.9)
        expect_evidence_created(out)
    end)

    -- Does: Exports both waveform and spectrogram PNGs from the same fixture WAV using the public DSP export helpers.
    -- Shows: The pair should give time-domain and frequency-domain views of the same source audio.
    -- Artifact: tests/artifacts/current/dsp/dsp_fixture_waveform.png, tests/artifacts/current/dsp/dsp_fixture_spectrogram.png
    -- Why: This is meaningful because the exported images are the direct output of DSP analysis APIs on a real WAV fixture.

    it("PNG: waveform and spectrogram exports from wav fixture", function()
        local waveform = OUT .. "dsp_fixture_waveform.png"
        local spectrogram = OUT .. "dsp_fixture_spectrogram.png"
        lurek.dsp.waveformToPng(FIXTURE_WAVE, waveform, 1024, 256)
        lurek.dsp.spectrogramToPng(FIXTURE_WAVE, spectrogram, 512, 256)
        expect_evidence_created(waveform)
        expect_evidence_created(spectrogram)
    end)
end)

test_summary()
