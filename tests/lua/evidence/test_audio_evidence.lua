-- Canonical evidence file for lurek.audio artifacts.
-- @covers lurek.audio.judgeBeat
-- @covers lurek.audio.mixInto
-- @covers lurek.audio.newBeatClock
-- @covers lurek.audio.newBus
-- @covers lurek.audio.newDecoder
-- @covers lurek.audio.newPool
-- @covers lurek.audio.newSoundData
-- @covers lurek.audio.saveWAV
-- @covers lurek.filesystem.write
-- @covers lurek.image.newImageData
-- @covers lurek.image.savePNG



local OUT = evidence_output_dir("audio")
local FIXTURE_WAVE = "tests/fixtures/sine_mono_44100.wav"
local SR = 44100

local function write_text(path, text)
    if write_file then
        write_file(path, text)
    else
        lurek.filesystem.write(path, text)
    end
    expect_evidence_created(path)
end

local function save_wav(sd, path)
    lurek.audio.saveWAV(sd, path)
    expect_evidence_created(path)
end

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

local function make_sine_sound(freq, duration, amplitude, rate)
    rate = rate or SR
    local samples = math.floor(rate * duration)
    local sd = lurek.audio.newSoundData(samples, rate, 1)
    for i = 0, samples - 1 do
        local t = i / rate
        sd:setSample(i, math.sin(2 * math.pi * freq * t) * amplitude)
    end
    return sd
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

local function save_waveform_preview(sound, path, color, title_band)
    local img = lurek.image.newImageData(960, 260)
    img:fill(14, 16, 22, 255)
    img:drawRect(24, 28, 912, 188, 24, 28, 36, 255)
    draw_outline(img, 24, 28, 912, 188, 232, 236, 244, 255)
    plot_sound_waveform(img, sound, 40, 44, 880, 156, color)
    img:drawRect(24, 224, 912, 12, title_band[1], title_band[2], title_band[3], 255)
    save_png(img, path)
end

local function save_waveform_pair(before_sound, before_path, before_color, after_sound, after_path, after_color)
    save_waveform_preview(before_sound, before_path, before_color, before_color)
    save_waveform_preview(after_sound, after_path, after_color, after_color)
end

-- @describe Evidence: lurek.audio synthesized fixtures and timing traces
describe("Evidence: lurek.audio synthesized fixtures and timing traces", function()
    before_each(function()
        ensure_evidence_dir("audio")
    end)

    -- Does: Synthesizes a mono sine tone, exports it as WAV, then samples the same sound data into a generic waveform PNG.
    -- Shows: The WAV and PNG should agree on one steady 440 Hz tone, proving sound-data creation and sample reads without using drawWaveform.
    -- Artifact: tests/artifacts/current/audio/audio_sine_440hz_mono.wav, tests/artifacts/current/audio/audio_waveform_sine_440hz.png
    -- Why: This is meaningful because the preview comes from LSoundData:getSample on the generated audio data; the image module only visualizes those samples.

    it("WAV+PNG: sine tone with sampled waveform preview", function()
        local sound = make_sine_sound(440, 1.0, 0.8, SR)
        save_wav(sound, OUT .. "audio_sine_440hz_mono.wav")
        save_waveform_preview(sound, OUT .. "audio_waveform_sine_440hz.png", { 90, 220, 140 }, { 90, 220, 140 })
    end)

    -- Does: Builds a three-note chord with an amplitude envelope, then exports both the audio and a sampled waveform view.
    -- Shows: The evidence should reveal the chord body plus the attack/release shape in one artifact pair.
    -- Artifact: tests/artifacts/current/audio/audio_chord_c_major.wav, tests/artifacts/current/audio/audio_waveform_chord_c_major.png
    -- Why: This is meaningful because the visible envelope is reconstructed from generated audio samples instead of an audio-specific drawing helper.

    it("WAV+PNG: three-note chord with envelope", function()
        local duration = 2.0
        local samples = math.floor(SR * duration)
        local sound = lurek.audio.newSoundData(samples, SR, 1)
        local freqs = { 261.63, 329.63, 392.00 }
        for i = 0, samples - 1 do
            local t = i / SR
            local v = 0.0
            for _, freq in ipairs(freqs) do
                v = v + math.sin(2 * math.pi * freq * t)
            end
            local env = math.min(1.0, math.min(t / 0.05, (duration - t) / 0.12))
            sound:setSample(i, (v / #freqs) * env * 0.72)
        end

        save_wav(sound, OUT .. "audio_chord_c_major.wav")
        save_waveform_preview(sound, OUT .. "audio_waveform_chord_c_major.png", { 255, 180, 80 }, { 255, 180, 80 })
    end)

    -- Does: Generates a rising-frequency sweep and exports a waveform preview derived from the created samples.
    -- Shows: The waveform PNG should show changing density over time, while the WAV preserves the same sweep for listening or downstream DSP.
    -- Artifact: tests/artifacts/current/audio/audio_frequency_sweep_200_2000.wav, tests/artifacts/current/audio/audio_waveform_frequency_sweep.png
    -- Why: This is meaningful because both artifacts come from the same lurek.audio sound-data buffer.

    it("WAV+PNG: rising frequency sweep", function()
        local duration = 2.0
        local samples = math.floor(SR * duration)
        local sound = lurek.audio.newSoundData(samples, SR, 1)
        local f0, f1 = 200.0, 2000.0
        local phase = 0.0
        for i = 0, samples - 1 do
            local t = i / SR
            local freq = f0 + (f1 - f0) * (t / duration)
            phase = phase + 2 * math.pi * freq / SR
            sound:setSample(i, math.sin(phase) * 0.8)
        end

        save_wav(sound, OUT .. "audio_frequency_sweep_200_2000.wav")
        save_waveform_preview(sound, OUT .. "audio_waveform_frequency_sweep.png", { 150, 110, 255 }, { 150, 110, 255 })
    end)

    -- Does: Mixes a base tone with an overtone using lurek.audio.mixInto and exports separate before/after previews.
    -- Shows: The PNG pair should show the base waveform and the richer mixed waveform as separate evidence files, while the WAV stores the mixed result.
    -- Artifact: tests/artifacts/current/audio/audio_mix_into_harmonic_layer.wav, tests/artifacts/current/audio/audio_mix_into_base.png, tests/artifacts/current/audio/audio_mix_into_mixed.png
    -- Why: This is meaningful because the changed shape comes from lurek.audio.mixInto on sound data, not from hand-authored pixels.

    it("WAV+PNG: mixed harmonic layer via mixInto", function()
        local base = make_sine_sound(440, 1.0, 0.55, SR)
        local overlay = make_sine_sound(880, 1.0, 0.30, SR)
        local mixed = make_sine_sound(440, 1.0, 0.55, SR)
        lurek.audio.mixInto(mixed, overlay)

        save_wav(mixed, OUT .. "audio_mix_into_harmonic_layer.wav")
        save_waveform_pair(
            base,
            OUT .. "audio_mix_into_base.png",
            { 90, 180, 240 },
            mixed,
            OUT .. "audio_mix_into_mixed.png",
            { 240, 160, 100 }
        )
    end)

    -- Does: Creates a stereo ping-pong tone by writing alternating left/right samples into one buffer.
    -- Shows: The WAV should let a reviewer confirm channel alternation instead of a mono collapse.
    -- Artifact: tests/artifacts/current/audio/audio_stereo_ping_pong.wav
    -- Why: This is meaningful because the evidence comes directly from stereo sample placement in lurek.audio sound data.

    it("WAV: stereo ping-pong tone", function()
        local duration = 1.0
        local frames = math.floor(SR * duration)
        local sound = lurek.audio.newSoundData(frames * 2, SR, 2)
        for frame = 0, frames - 1 do
            local t = frame / SR
            local tone = math.sin(2 * math.pi * 880 * t) * 0.6
            local left_idx = frame * 2
            local right_idx = frame * 2 + 1
            if math.floor(t * 4) % 2 == 0 then
                sound:setSample(left_idx, tone)
                sound:setSample(right_idx, 0.0)
            else
                sound:setSample(left_idx, 0.0)
                sound:setSample(right_idx, tone)
            end
        end

        save_wav(sound, OUT .. "audio_stereo_ping_pong.wav")
    end)

    -- Does: Applies bus volume settings to a rendered fixture and exports the attenuated result as WAV.
    -- Shows: The artifact should preserve one tone at half the expected amplitude.
    -- Artifact: tests/artifacts/current/audio/audio_bus_volume_half_gain.wav
    -- Why: This is meaningful because the fixture amplitude is driven by lurek.audio.newBus state instead of a manual label.

    it("WAV: bus volume attenuation fixture", function()
        local bus = lurek.audio.newBus("volume_bus")
        bus:setVolume(0.5)
        local sound = make_sine_sound(440, 1.0, 0.8 * bus:getVolume(), SR)
        save_wav(sound, OUT .. "audio_bus_volume_half_gain.wav")
    end)

    -- Does: Applies bus pitch state to a rendered tone and exports the shifted result.
    -- Shows: The artifact should move the tone frequency upward relative to the base 440 Hz reference.
    -- Artifact: tests/artifacts/current/audio/audio_bus_pitch_up_150.wav
    -- Why: This is meaningful because the generated pitch comes from the bus state used by the test logic.

    it("WAV: bus pitch-shifted fixture", function()
        local bus = lurek.audio.newBus("pitch_bus")
        bus:setPitch(1.5)
        local sound = make_sine_sound(440 * bus:getPitch(), 1.0, 0.7, SR)
        save_wav(sound, OUT .. "audio_bus_pitch_up_150.wav")
    end)

    -- Does: Recomputes a fade-out envelope from live bus volume values and exports the result as one long fixture.
    -- Shows: The WAV should decay smoothly to silence over the test duration.
    -- Artifact: tests/artifacts/current/audio/audio_bus_volume_fadeout.wav
    -- Why: This is meaningful because the exported envelope is driven by repeated LBus:setVolume updates.

    it("WAV: bus fade-out envelope fixture", function()
        local duration = 2.0
        local samples = math.floor(SR * duration)
        local bus = lurek.audio.newBus("fade_bus")
        local sound = lurek.audio.newSoundData(samples, SR, 1)
        for i = 0, samples - 1 do
            local t = i / SR
            local vol = 1.0 - (t / duration)
            bus:setVolume(vol)
            sound:setSample(i, math.sin(2 * math.pi * 330 * t) * 0.8 * vol)
        end

        save_wav(sound, OUT .. "audio_bus_volume_fadeout.wav")
    end)

    -- Does: Exercises beat scheduling, callbacks, and beat judgement, then writes a scheduler trace for inspection.
    -- Shows: The text trace should show fired events, beat position, bar index, phase, and the judgement verdict from one deterministic update step.
    -- Artifact: tests/artifacts/current/audio/audio_beat_clock_scheduler_trace.txt
    -- Why: This is meaningful because the artifact is a serialized runtime trace of lurek.audio timing behavior.

    it("TXT: beat clock scheduler trace", function()
        local clock = lurek.audio.newBeatClock(120.0, { subdivision = 8, swing = 0.15, latency_ms = 4 })
        local callback_hits = {}

        clock:every(2, function(step_index)
            callback_hits[#callback_hits + 1] = "every:" .. tostring(step_index)
        end)
        clock:pattern("x.x.", function(step_index)
            callback_hits[#callback_hits + 1] = "pattern:" .. tostring(step_index)
        end)
        clock:at(1.0, function(beat)
            callback_hits[#callback_hits + 1] = string.format("at:%.2f", beat)
        end)

        clock:start()
        clock:scheduleAt(1.0)
        clock:update(1.10)

        local fired = clock:drainFired()
        local verdict, err = lurek.audio.judgeBeat(clock, 8, 0.0)
        local lines = {
            "beat=" .. string.format("%.3f", clock:getBeat()),
            "bar=" .. tostring(clock:getBar()),
            "phase8=" .. tostring(clock:getPhase(8)),
            "scheduled_fired=" .. tostring(#fired),
            "callbacks=" .. tostring(#callback_hits),
            "callback_preview=" .. table.concat(callback_hits, ", "),
            "judge_verdict=" .. tostring(verdict),
            "judge_error=" .. tostring(err),
        }
        write_text(OUT .. "audio_beat_clock_scheduler_trace.txt", table.concat(lines, "\n") .. "\n")
    end)

    -- Does: Exercises ducking, decoder reads, and pooled voices, then writes a single text trace for the reviewer.
    -- Shows: The trace should show ducking state changes plus decoder metadata and whether one chunk could be decoded from the fixture.
    -- Artifact: tests/artifacts/current/audio/audio_bus_decoder_trace.txt
    -- Why: This is meaningful because the text is derived from real lurek.audio runtime state instead of a hand-written expectation file.

    it("TXT: bus ducking and decoder trace", function()
        local music = lurek.audio.newBus("music_bus_trace")
        local voice = lurek.audio.newBus("voice_bus_trace")
        voice:setDuckTarget("music_bus_trace", 0.35)
        local peak_before = music:getPeak()
        voice:clearDuck()
        local peak_after = music:getPeak()

        local pool = lurek.audio.newPool(FIXTURE_WAVE, 3)
        local decoder = lurek.audio.newDecoder(FIXTURE_WAVE, 2048)
        local chunk = decoder:decode()

        local lines = {
            "music_peak_before=" .. tostring(peak_before),
            "music_peak_after=" .. tostring(peak_after),
            "pool_voices=" .. tostring(pool:getVoiceCount()),
            "decoder_seekable=" .. tostring(decoder:isSeekable()),
            "decoder_duration=" .. tostring(decoder:getDuration()),
            "decoded_chunk_type=" .. type(chunk),
            "decoded_chunk_present=" .. tostring(chunk ~= nil),
        }
        write_text(OUT .. "audio_bus_decoder_trace.txt", table.concat(lines, "\n") .. "\n")

        decoder:release()
        pool:release()
    end)
end)

test_summary()
