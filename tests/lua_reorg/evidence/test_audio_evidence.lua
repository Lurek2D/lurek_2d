-- test_audio_evidence.lua
-- Canonical evidence file for lurek.audio and lurek.dsp artifacts.

local OUT = evidence_output_dir("audio")
local FIXTURE_WAVE = "tests/fixtures/sine_mono_44100.wav"
local SR = 44100

local function save_wav(sd, path)
    lurek.audio.saveWAV(sd, path)
    expect_evidence_created(path)
end

local function save_png(img, path)
    lurek.image.savePNG(img, path)
    expect_evidence_created(path)
end

local function draw_waveform_png(sd, path, r, g, b)
    local img = lurek.image.newImageData(900, 220)
    img:fill(12, 14, 20, 255)
    sd:drawWaveform(img, 0, 0, 900, 220, r, g, b, 255)
    save_png(img, path)
end

local function save_compare_png(before_sd, after_sd, path, before_color, after_color)
    local img = lurek.image.newImageData(900, 220)
    img:fill(10, 12, 18, 255)
    before_sd:drawWaveform(img, 0, 0, 450, 220, before_color[1], before_color[2], before_color[3], 255)
    after_sd:drawWaveform(img, 450, 0, 450, 220, after_color[1], after_color[2], after_color[3], 255)
    save_png(img, path)
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

local function make_waveform_strip(img, sd, lane, lanes_total, color)
    local lane_h = math.floor(img:getHeight() / lanes_total)
    local y = lane * lane_h
    sd:drawWaveform(img, 0, y, img:getWidth(), lane_h, color[1], color[2], color[3], 255)
end

-- @describe Evidence: lurek.audio synthesized fixtures
describe("Evidence: lurek.audio synthesized fixtures", function()
    before_each(function()
        ensure_evidence_dir("audio")
    end)

    -- @evidence lurek.audio.newSoundData
    -- @evidence LSoundData:drawWaveform
    -- @evidence lurek.audio.saveWAV
    -- @evidence lurek.image.savePNG
    it("WAV+PNG: sine tone with waveform preview", function()
        local sound = make_sine_sound(440, 1.0, 0.8, SR)
        local wav = OUT .. "audio_sine_440hz_mono.wav"
        save_wav(sound, wav)
        draw_waveform_png(sound, OUT .. "audio_waveform_sine_440hz.png", 90, 220, 140)
    end)

    -- @evidence lurek.audio.newSoundData
    -- @evidence lurek.audio.saveWAV
    -- @evidence lurek.image.savePNG
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

        local wav = OUT .. "audio_chord_c_major.wav"
        save_wav(sound, wav)
        draw_waveform_png(sound, OUT .. "audio_waveform_chord_c_major.png", 255, 180, 80)
    end)

    -- @evidence lurek.audio.newSoundData
    -- @evidence lurek.audio.saveWAV
    -- @evidence lurek.image.savePNG
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

        local wav = OUT .. "audio_frequency_sweep_200_2000.wav"
        save_wav(sound, wav)
        draw_waveform_png(sound, OUT .. "audio_waveform_frequency_sweep.png", 150, 110, 255)
    end)

    -- @evidence lurek.audio.newSoundData
    -- @evidence lurek.audio.saveWAV
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

        local wav = OUT .. "audio_stereo_ping_pong.wav"
        save_wav(sound, wav)
    end)
end)

-- @describe Evidence: lurek.audio bus shaping
describe("Evidence: lurek.audio bus shaping", function()
    before_each(function()
        ensure_evidence_dir("audio")
    end)

    -- @evidence lurek.audio.newBus
    -- @evidence lurek.audio.saveWAV
    it("WAV: bus volume attenuation fixture", function()
        local bus = lurek.audio.newBus("volume_bus")
        bus:setVolume(0.5)
        local vol = bus:getVolume()
        local sound = make_sine_sound(440, 1.0, 0.8 * vol, SR)
        local wav = OUT .. "audio_bus_volume_half_gain.wav"
        save_wav(sound, wav)
    end)

    -- @evidence lurek.audio.newBus
    -- @evidence lurek.audio.saveWAV
    it("WAV: bus pitch-shifted fixture", function()
        local bus = lurek.audio.newBus("pitch_bus")
        bus:setPitch(1.5)
        local pitch = bus:getPitch()
        local sound = make_sine_sound(440 * pitch, 1.0, 0.7, SR)
        local wav = OUT .. "audio_bus_pitch_up_150.wav"
        save_wav(sound, wav)
    end)

    -- @evidence lurek.audio.newBus
    -- @evidence lurek.audio.saveWAV
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

        local wav = OUT .. "audio_bus_volume_fadeout.wav"
        save_wav(sound, wav)
    end)
end)

-- @describe Evidence: lurek.dsp waveform and filter views
describe("Evidence: lurek.dsp waveform and filter views", function()
    before_each(function()
        ensure_evidence_dir("audio")
    end)

    -- @evidence lurek.dsp.newSineWave
    -- @evidence lurek.dsp.newSquareWave
    -- @evidence lurek.dsp.newSawtoothWave
    -- @evidence lurek.dsp.newTriangleWave
    -- @evidence lurek.dsp.newWhiteNoise
    -- @evidence lurek.image.savePNG
    it("PNG: generator waveform comparison atlas", function()
        local duration = 0.05
        local waves = {
            { lurek.dsp.newSineWave(440, duration, SR, 0.8), { 80, 180, 240 } },
            { lurek.dsp.newSquareWave(440, duration, SR, 0.8), { 220, 100, 100 } },
            { lurek.dsp.newSawtoothWave(440, duration, SR, 0.8), { 80, 220, 100 } },
            { lurek.dsp.newTriangleWave(440, duration, SR, 0.8), { 240, 200, 50 } },
            { lurek.dsp.newWhiteNoise(duration, SR, 0.8, 42), { 180, 120, 220 } },
        }

        local img = lurek.image.newImageData(900, 400)
        img:fill(12, 14, 20, 255)
        for i, entry in ipairs(waves) do
            make_waveform_strip(img, entry[1], i - 1, #waves, entry[2])
        end

        local png = OUT .. "audio_waveform_generator_atlas.png"
        save_png(img, png)
    end)

    -- @evidence lurek.dsp.applyLowpass
    -- @evidence lurek.image.savePNG
    it("PNG: low-pass before-after comparison", function()
        local before = lurek.dsp.newSineWave(4000, 0.05, 22050, 0.8)
        local after = lurek.dsp.newSineWave(4000, 0.05, 22050, 0.8)
        lurek.dsp.applyLowpass(after, 300)
        save_compare_png(before, after, OUT .. "audio_dsp_lowpass_compare.png", { 90, 180, 240 }, { 255, 160, 80 })
    end)

    -- @evidence lurek.dsp.applyHighpass
    -- @evidence lurek.image.savePNG
    it("PNG: high-pass before-after comparison", function()
        local before = lurek.dsp.newSineWave(300, 0.05, 22050, 0.8)
        local after = lurek.dsp.newSineWave(300, 0.05, 22050, 0.8)
        lurek.dsp.applyHighpass(after, 2000)
        save_compare_png(before, after, OUT .. "audio_dsp_highpass_compare.png", { 90, 180, 240 }, { 255, 160, 80 })
    end)

    -- @evidence lurek.dsp.applyBandpass
    -- @evidence lurek.audio.mixInto
    -- @evidence lurek.image.savePNG
    it("PNG: band-pass and mixing comparison", function()
        local before = lurek.dsp.newWhiteNoise(0.05, 22050, 0.8, 42)
        local band = lurek.dsp.newWhiteNoise(0.05, 22050, 0.8, 42)
        lurek.dsp.applyBandpass(band, 800, 3000)
        save_compare_png(before, band, OUT .. "audio_dsp_bandpass_compare.png", { 120, 200, 255 }, { 255, 180, 100 })

        local mixed = lurek.dsp.newSineWave(440, 0.05, 22050, 0.5)
        local overlay = lurek.dsp.newSineWave(880, 0.05, 22050, 0.5)
        local raw = lurek.dsp.newSineWave(440, 0.05, 22050, 0.5)
        lurek.audio.mixInto(mixed, overlay)
        save_compare_png(raw, mixed, OUT .. "audio_dsp_mix_compare.png", { 90, 180, 240 }, { 220, 140, 255 })
    end)
end)

-- @describe Evidence: lurek.dsp offline processors
describe("Evidence: lurek.dsp offline processors", function()
    before_each(function()
        ensure_evidence_dir("audio")
    end)

    -- @evidence lurek.dsp.processOffline
    it("WAV: offline processed low-pass fixture", function()
        local out = OUT .. "audio_offline_lowpass_1khz.wav"
        lurek.dsp.processOffline(FIXTURE_WAVE, out, {
            { type = "lowpass", cutoff = 1000.0 },
        })
        expect_evidence_created(out)
    end)

    -- @evidence lurek.dsp.normalize
    it("WAV: normalized fixture", function()
        local out = OUT .. "audio_normalized_peak_09.wav"
        lurek.dsp.normalize(FIXTURE_WAVE, out, 0.9)
        expect_evidence_created(out)
    end)

    -- @evidence lurek.dsp.waveformToPng
    -- @evidence lurek.dsp.spectrogramToPng
    it("PNG: waveform and spectrogram exports from wav fixture", function()
        local waveform = OUT .. "audio_fixture_waveform.png"
        local spectrogram = OUT .. "audio_fixture_spectrogram.png"
        lurek.dsp.waveformToPng(FIXTURE_WAVE, waveform, 1024, 256)
        lurek.dsp.spectrogramToPng(FIXTURE_WAVE, spectrogram, 512, 256)
        expect_evidence_created(waveform)
        expect_evidence_created(spectrogram)
    end)
end)

-- @describe Evidence: lurek.audio golden fixtures
describe("Evidence: lurek.audio golden fixtures", function()
    before_each(function()
        ensure_evidence_dir("audio")
    end)

    -- @evidence lurek.audio.newSoundData
    -- @evidence lurek.audio.saveWAV
    it("WAV: audio_fixture_stereo_two_tones.wav -- stereo A4/A5 fixture", function()
        local frames = SR
        local sound = lurek.audio.newSoundData(frames, SR, 2)
        for i = 0, frames - 1 do
            local t = i / SR
            sound:setSample(i * 2 + 0, math.sin(t * 440.0 * math.pi * 2) * 0.5)
            sound:setSample(i * 2 + 1, math.sin(t * 880.0 * math.pi * 2) * 0.5)
        end
        local path = OUT .. "audio_fixture_stereo_two_tones.wav"
        save_wav(sound, path)
    end)

    -- @evidence lurek.audio.saveWAV
    it("WAV: audio_fixture_frequency_sweep_100_4000.wav -- mono sweep fixture", function()
        local samples = SR * 2
        local sound = lurek.audio.newSoundData(samples, SR, 1)
        for i = 0, samples - 1 do
            local t = i / SR
            local f = 100.0 + (4000.0 - 100.0) * (t / 2.0)
            sound:setSample(i, math.sin(t * f * math.pi * 2) * 0.5)
        end
        local path = OUT .. "audio_fixture_frequency_sweep_100_4000.wav"
        save_wav(sound, path)
    end)

    -- @evidence lurek.audio.saveWAV
    it("WAV: audio_fixture_amplitude_envelope.wav -- attack sustain release sine fixture", function()
        local samples = SR * 2
        local sound = lurek.audio.newSoundData(samples, SR, 1)
        for i = 0, samples - 1 do
            local t = i / SR
            local env = 1.0
            if t < 0.2 then
                env = t / 0.2
            elseif t > 1.5 then
                env = 1.0 - (t - 1.5) / 0.5
            end
            sound:setSample(i, math.sin(t * 440.0 * math.pi * 2) * env * 0.8)
        end
        local path = OUT .. "audio_fixture_amplitude_envelope.wav"
        save_wav(sound, path)
    end)

    -- @evidence lurek.audio.saveWAV
    it("WAV: audio_fixture_square_wave_440hz.wav -- square wave fixture", function()
        local samples = SR
        local sound = lurek.audio.newSoundData(samples, SR, 1)
        for i = 0, samples - 1 do
            local t = i / SR
            local v = math.sin(t * 440.0 * math.pi * 2)
            sound:setSample(i, v > 0 and 0.4 or -0.4)
        end
        local path = OUT .. "audio_fixture_square_wave_440hz.wav"
        save_wav(sound, path)
    end)

    -- @evidence lurek.audio.saveWAV
    it("WAV: audio_fixture_sawtooth_wave_440hz.wav -- sawtooth wave fixture", function()
        local samples = SR
        local sound = lurek.audio.newSoundData(samples, SR, 1)
        for i = 0, samples - 1 do
            local t = i / SR
            local phase = (t * 440.0) % 1.0
            sound:setSample(i, (phase * 2.0 - 1.0) * 0.4)
        end
        local path = OUT .. "audio_fixture_sawtooth_wave_440hz.wav"
        save_wav(sound, path)
    end)

    -- @evidence lurek.audio.saveWAV
    it("WAV: audio_fixture_white_noise.wav -- deterministic white noise fixture", function()
        local samples = SR
        local sound = lurek.audio.newSoundData(samples, SR, 1)
        local state = 12345
        for i = 0, samples - 1 do
            state = (state * 1103515245 + 12345) % 2147483648
            local rv = (state / 2147483648.0) * 2.0 - 1.0
            sound:setSample(i, rv * 0.2)
        end
        local path = OUT .. "audio_fixture_white_noise.wav"
        save_wav(sound, path)
    end)

    -- @evidence lurek.audio.saveWAV
    it("WAV: audio_fixture_silence_half_second.wav -- silence fixture", function()
        local samples = 22050
        local sound = lurek.audio.newSoundData(samples, SR, 1)
        for i = 0, samples - 1 do
            sound:setSample(i, 0.0)
        end
        local path = OUT .. "audio_fixture_silence_half_second.wav"
        save_wav(sound, path)
    end)

    -- @evidence lurek.audio.saveWAV
    it("WAV: audio_fixture_waveform_sine_440hz.wav -- sine waveform audio fixture", function()
        local samples = SR
        local sound = lurek.audio.newSoundData(samples, SR, 1)
        for i = 0, samples - 1 do
            local t = i / SR
            sound:setSample(i, math.sin(t * 440.0 * math.pi * 2) * 0.5)
        end
        local path = OUT .. "audio_fixture_waveform_sine_440hz.wav"
        save_wav(sound, path)
    end)
end)

-- @describe Evidence: lurek.audio timing and bus traces
describe("Evidence: lurek.audio timing and bus traces", function()
    before_each(function()
        ensure_evidence_dir("audio")
    end)

    -- @evidence lurek.audio.newBeatClock
    -- @evidence LBeatClock:every
    -- @evidence LBeatClock:pattern
    -- @evidence LBeatClock:at
    -- @evidence LBeatClock:scheduleAt
    -- @evidence LBeatClock:update
    -- @evidence LBeatClock:drainFired
    -- @evidence LBeatClock:getBeat
    -- @evidence LBeatClock:getBar
    -- @evidence LBeatClock:getPhase
    -- @evidence lurek.audio.judgeBeat
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
        local path = OUT .. "audio_beat_clock_scheduler_trace.txt"
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

        write_file(path, table.concat(lines, "\n") .. "\n")
        expect_evidence_created(path)
    end)

    -- @evidence LBus:setDuckTarget
    -- @evidence LBus:clearDuck
    -- @evidence LBus:getPeak
    -- @evidence lurek.audio.newPool
    -- @evidence LSoundPool:getVoiceCount
    -- @evidence lurek.audio.newDecoder
    -- @evidence LDecoder:decode
    -- @evidence LDecoder:getDuration
    -- @evidence LDecoder:isSeekable
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

        local path = OUT .. "audio_bus_decoder_trace.txt"
        local lines = {
            "music_peak_before=" .. tostring(peak_before),
            "music_peak_after=" .. tostring(peak_after),
            "pool_voices=" .. tostring(pool:getVoiceCount()),
            "decoder_seekable=" .. tostring(decoder:isSeekable()),
            "decoder_duration=" .. tostring(decoder:getDuration()),
            "decoded_chunk_type=" .. type(chunk),
            "decoded_chunk_present=" .. tostring(chunk ~= nil),
        }

        write_file(path, table.concat(lines, "\n") .. "\n")
        expect_evidence_created(path)

        decoder:release()
        pool:release()
    end)
end)

test_summary()
