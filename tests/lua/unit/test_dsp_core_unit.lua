-- Lurek2D DSP API unit tests.

local WAVE = "tests/fixtures/sine_mono_44100.wav"
local OUT_DIR = evidence_output_dir("dsp")

local function make_test_tone(sample_count, amplitude)
    local sd = lurek.audio.newSoundData(sample_count, 44100, 1)
    for i = 0, sample_count - 1 do
        local phase = (2.0 * math.pi * 440.0 * i) / 44100.0
        sd:setSample(i, math.sin(phase) * amplitude)
    end
    return sd
end

-- @describe lurek.dsp existence
describe("lurek.dsp existence", function()
    -- @covers lurek.dsp
    it("lurek.dsp table exists", function()
        expect_type("table", lurek.dsp)
    end)

    -- @covers lurek.dsp.newEffectParams
    it("newEffectParams exists", function()
        expect_type("function", lurek.dsp.newEffectParams)
    end)

    -- @covers lurek.dsp.processOffline
    it("processOffline exists", function()
        expect_type("function", lurek.dsp.processOffline)
    end)

    -- @covers lurek.dsp.normalize
    it("normalize exists", function()
        expect_type("function", lurek.dsp.normalize)
    end)

    -- @covers lurek.dsp.waveformToPng
    it("waveformToPng exists", function()
        expect_type("function", lurek.dsp.waveformToPng)
    end)

    -- @covers lurek.dsp.spectrogramToPng
    it("spectrogramToPng exists", function()
        expect_type("function", lurek.dsp.spectrogramToPng)
    end)
end)

-- @describe lurek.dsp.newEffectParams
describe("lurek.dsp.newEffectParams", function()
    -- @covers lurek.dsp.newEffectParams
    it("creates params with correct fields", function()
        local params = lurek.dsp.newEffectParams("lowpass", 1000, 0.7, 0)
        expect_equal("lowpass", params.type)
        expect_equal(1000, params.p1)
        expect_near(0.7, params.p2, 0.0001)
        expect_equal(0, params.p3)
    end)

    -- @covers lurek.dsp.newEffectParams
    it("keeps effect type names unchanged", function()
        local types = {
            "lowpass", "highpass", "bandpass", "notch",
            "reverb", "delay", "chorus", "flanger",
            "distortion", "bitcrush", "compressor", "limiter",
            "tremolo", "vibrato", "phaser", "gain",
        }
        for _, effect_type in ipairs(types) do
            local params = lurek.dsp.newEffectParams(effect_type, 1, 2, 3)
            expect_equal(effect_type, params.type)
        end
    end)
end)

-- @describe lurek.dsp functions exist
describe("lurek.dsp functions exist", function()
    -- @covers lurek.dsp.applyLowpass
    it("applyLowpass exists", function()
        expect_type("function", lurek.dsp.applyLowpass)
    end)

    -- @covers lurek.dsp.applyHighpass
    it("applyHighpass exists", function()
        expect_type("function", lurek.dsp.applyHighpass)
    end)

    -- @covers lurek.dsp.applyBandpass
    it("applyBandpass exists", function()
        expect_type("function", lurek.dsp.applyBandpass)
    end)

    -- @covers lurek.dsp.applyGain
    it("applyGain exists", function()
        expect_type("function", lurek.dsp.applyGain)
    end)

    -- @covers lurek.dsp.analyzeRms
    it("analyzeRms exists", function()
        expect_type("function", lurek.dsp.analyzeRms)
    end)

    -- @covers lurek.dsp.analyzePeak
    it("analyzePeak exists", function()
        expect_type("function", lurek.dsp.analyzePeak)
    end)

    -- @covers lurek.dsp.analyzeFft
    it("analyzeFft exists", function()
        expect_type("function", lurek.dsp.analyzeFft)
    end)

    -- @covers lurek.dsp.addEffectToBus
    it("addEffectToBus exists", function()
        expect_type("function", lurek.dsp.addEffectToBus)
    end)

    -- @covers lurek.dsp.removeEffectFromBus
    it("removeEffectFromBus exists", function()
        expect_type("function", lurek.dsp.removeEffectFromBus)
    end)

    -- @covers lurek.dsp.setEffectParam
    it("setEffectParam exists", function()
        expect_type("function", lurek.dsp.setEffectParam)
    end)
end)

-- @describe lurek.dsp analysis
describe("lurek.dsp analysis", function()
    -- @covers LSoundData:setSample
    -- @covers lurek.audio.newSoundData
    -- @covers lurek.dsp.analyzeRms
    it("analyzeRms returns a number in range for a sine wave", function()
        local sound = make_test_tone(4410, 0.5)
        local rms = lurek.dsp.analyzeRms(sound)
        expect_type("number", rms)
        expect_equal(rms >= 0.0, true)
        expect_equal(rms <= 1.0, true)
    end)

    -- @covers LSoundData:setSample
    -- @covers lurek.audio.newSoundData
    -- @covers lurek.dsp.analyzePeak
    it("analyzePeak returns a number in range for a sine wave", function()
        local sound = make_test_tone(4410, 0.5)
        local peak = lurek.dsp.analyzePeak(sound)
        expect_type("number", peak)
        expect_equal(peak >= 0.0, true)
        expect_equal(peak <= 1.0, true)
    end)

    -- @covers LSoundData:setSample
    -- @covers lurek.audio.newSoundData
    -- @covers lurek.dsp.analyzePeak
    -- @covers lurek.dsp.applyGain
    it("applyGain increases peak when gain is above one", function()
        local sound = make_test_tone(4410, 0.4)
        local before = lurek.dsp.analyzePeak(sound)
        lurek.dsp.applyGain(sound, 2.0)
        local after = lurek.dsp.analyzePeak(sound)
        expect_equal(after > before, true)
    end)

    -- @covers LSoundData:setSample
    -- @covers lurek.audio.newSoundData
    -- @covers lurek.dsp.analyzeFft
    it("analyzeFft returns bins with frequency and magnitude fields", function()
        local sound = make_test_tone(4410, 0.5)
        local bins = lurek.dsp.analyzeFft(sound, 16)
        expect_type("table", bins)
        expect_equal(#bins > 0, true)
        expect_type("number", bins[1].frequency)
        expect_type("number", bins[1].magnitude)
    end)
end)

-- @describe lurek.dsp wave generators
describe("lurek.dsp wave generators", function()
    -- @covers lurek.dsp.newSquareWave
    it("newSquareWave returns SoundData userdata", function()
        local f = rawget(lurek.dsp, "newSquareWave")
        expect_type("function", f)
        local sd = f(440, 0.01, 44100, 0.5)
        expect_type("userdata", sd)
    end)

    -- @covers lurek.dsp.newSawtoothWave
    it("newSawtoothWave returns SoundData userdata", function()
        local f = rawget(lurek.dsp, "newSawtoothWave")
        expect_type("function", f)
        local sd = f(440, 0.01, 44100, 0.5)
        expect_type("userdata", sd)
    end)

    -- @covers lurek.dsp.newTriangleWave
    it("newTriangleWave returns SoundData userdata", function()
        local f = rawget(lurek.dsp, "newTriangleWave")
        expect_type("function", f)
        local sd = f(440, 0.01, 44100, 0.5)
        expect_type("userdata", sd)
    end)

    -- @covers lurek.dsp.newWhiteNoise
    it("newWhiteNoise returns SoundData userdata", function()
        local f = rawget(lurek.dsp, "newWhiteNoise")
        expect_type("function", f)
        local sd = f(0.01, 44100, 0.5, 42)
        expect_type("userdata", sd)
    end)
end)

-- @describe lurek.dsp offline file processing
describe("lurek.dsp offline file processing", function()
    -- @covers lurek.dsp.processOffline
    -- @covers lurek.filesystem.exists
    it("processOffline writes output WAV with a chained effect list", function()
        local effects = {
            { type = "highpass", p1 = 150.0 },
            { type = "reverb", p1 = 0.5, p2 = 0.3, p3 = 0.25 },
        }
        local out = OUT_DIR .. "offline_chain.wav"
        local ok = lurek.dsp.processOffline(WAVE, out, effects)
        expect_equal(true, ok)
        expect_true(lurek.filesystem.exists(out), "processed WAV output should exist")
    end)

    -- @covers lurek.dsp.normalize
    -- @covers lurek.filesystem.exists
    it("normalize writes a normalized output WAV", function()
        local out = OUT_DIR .. "normalized.wav"
        local ok = lurek.dsp.normalize(WAVE, out, 0.9)
        expect_equal(true, ok)
        expect_true(lurek.filesystem.exists(out), "normalized WAV output should exist")
    end)

    -- @covers lurek.dsp.waveformToPng
    -- @covers lurek.filesystem.exists
    it("waveformToPng writes a PNG for valid input", function()
        local out = OUT_DIR .. "waveform.png"
        local ok = lurek.dsp.waveformToPng(WAVE, out, 256, 64)
        expect_equal(true, ok)
        expect_true(lurek.filesystem.exists(out), "waveform PNG output should exist")
    end)

    -- @covers lurek.dsp.spectrogramToPng
    -- @covers lurek.filesystem.exists
    it("spectrogramToPng writes a PNG for valid input", function()
        local out = OUT_DIR .. "spectrogram.png"
        local ok = lurek.dsp.spectrogramToPng(WAVE, out, 256, 128)
        expect_equal(true, ok)
        expect_true(lurek.filesystem.exists(out), "spectrogram PNG output should exist")
    end)

    -- @covers lurek.dsp.processOffline
    it("processOffline rejects missing source file", function()
        expect_error(function()
            lurek.dsp.processOffline("no_such_file.wav", OUT_DIR .. "missing_out.wav", {})
        end, "not found")
    end)

    -- @covers lurek.dsp.normalize
    it("normalize rejects invalid target level", function()
        expect_error(function()
            lurek.dsp.normalize(WAVE, OUT_DIR .. "bad_target_low.wav", 0.0)
        end, "target level")
        expect_error(function()
            lurek.dsp.normalize(WAVE, OUT_DIR .. "bad_target_high.wav", 1.5)
        end, "target level")
    end)

    -- @covers lurek.dsp.waveformToPng
    it("waveformToPng rejects missing source file", function()
        local ok = pcall(function()
            lurek.dsp.waveformToPng("tests/fixtures/does_not_exist.wav", OUT_DIR .. "missing_waveform.png", 100, 50)
        end)
        expect_equal(false, ok)
    end)
end)

-- @describe lurek.dsp filters
describe("lurek.dsp filters", function()
    -- @covers LSoundData:setSample
    -- @covers lurek.audio.newSoundData
    -- @covers lurek.dsp.applyLowpass
    it("applyLowpass accepts LSoundData", function()
        local sound = make_test_tone(4410, 0.5)
        expect_no_error(function()
            lurek.dsp.applyLowpass(sound, 1000)
        end)
    end)

    -- @covers LSoundData:setSample
    -- @covers lurek.audio.newSoundData
    -- @covers lurek.dsp.applyHighpass
    it("applyHighpass accepts LSoundData", function()
        local sound = make_test_tone(4410, 0.5)
        expect_no_error(function()
            lurek.dsp.applyHighpass(sound, 100)
        end)
    end)

    -- @covers LSoundData:setSample
    -- @covers lurek.audio.newSoundData
    -- @covers lurek.dsp.applyBandpass
    it("applyBandpass accepts LSoundData", function()
        local sound = make_test_tone(4410, 0.5)
        expect_no_error(function()
            lurek.dsp.applyBandpass(sound, 200, 2000)
        end)
    end)
end)

-- @describe lurek.dsp bus effects
describe("lurek.dsp bus effects", function()
    -- @covers lurek.audio.create_bus
    -- @covers lurek.dsp.addEffectToBus
    it("addEffectToBus returns a number effect id", function()
        lurek.audio.create_bus("test_dsp_bus")
        local effect_id = lurek.dsp.addEffectToBus("test_dsp_bus", "lowpass")
        expect_type("number", effect_id)
    end)

    -- @covers lurek.audio.create_bus
    -- @covers lurek.dsp.addEffectToBus
    -- @covers lurek.dsp.removeEffectFromBus
    it("removeEffectFromBus returns true", function()
        lurek.audio.create_bus("test_dsp_remove_bus")
        local effect_id = lurek.dsp.addEffectToBus("test_dsp_remove_bus", "lowpass")
        local ok = lurek.dsp.removeEffectFromBus("test_dsp_remove_bus", effect_id)
        expect_equal(true, ok)
    end)

    -- @covers lurek.audio.create_bus
    -- @covers lurek.dsp.addEffectToBus
    -- @covers lurek.dsp.setEffectParam
    it("setEffectParam returns true for valid cutoff param", function()
        lurek.audio.create_bus("test_dsp_param_bus")
        local effect_id = lurek.dsp.addEffectToBus("test_dsp_param_bus", "lowpass")
        local ok = lurek.dsp.setEffectParam("test_dsp_param_bus", effect_id, "cutoff", 500.0)
        expect_equal(true, ok)
    end)

    -- @covers lurek.dsp.addEffectToBus
    it("addEffectToBus errors for unknown bus", function()
        local ok = pcall(function()
            lurek.dsp.addEffectToBus("nonexistent_bus_xyz_dsp", "lowpass")
        end)
        expect_equal(false, ok)
    end)
end)

-- @describe lurek.dsp bus effects errors
describe("lurek.dsp bus effects errors", function()
    -- @covers lurek.dsp.addEffectToBus
    it("addEffectToBus rejects unknown effect type", function()
        lurek.audio.create_bus("test_dsp_err_bus_1")
        local ok = pcall(function()
            lurek.dsp.addEffectToBus("test_dsp_err_bus_1", "totally_unknown_xyz")
        end)
        expect_equal(false, ok)
    end)

    -- @covers lurek.audio.create_bus
    -- @covers lurek.dsp.addEffectToBus
    it("addEffectToBus first effect id is 1", function()
        lurek.audio.create_bus("test_dsp_id_bus_1")
        local effect_id = lurek.dsp.addEffectToBus("test_dsp_id_bus_1", "lowpass")
        expect_equal(1, effect_id)
    end)

    -- @covers lurek.audio.create_bus
    -- @covers lurek.dsp.addEffectToBus
    -- @covers lurek.dsp.removeEffectFromBus
    it("removeEffectFromBus rejects missing effect id", function()
        lurek.audio.create_bus("test_dsp_rm_err_bus")
        local ok = pcall(function()
            lurek.dsp.removeEffectFromBus("test_dsp_rm_err_bus", 9999)
        end)
        expect_equal(false, ok)
    end)

    -- @covers lurek.audio.create_bus
    -- @covers lurek.dsp.addEffectToBus
    -- @covers lurek.dsp.setEffectParam
    it("setEffectParam rejects missing effect id", function()
        lurek.audio.create_bus("test_dsp_param_err_bus")
        local ok = pcall(function()
            lurek.dsp.setEffectParam("test_dsp_param_err_bus", 9999, "cutoff", 500.0)
        end)
        expect_equal(false, ok)
    end)
end)

-- @describe lurek.dsp.newSineWave
describe("lurek.dsp.newSineWave", function()
    -- @covers lurek.dsp.newSineWave
    it("newSineWave returns SoundData userdata", function()
        local sd = lurek.dsp.newSineWave(440, 0.01, 44100, 0.5)
        expect_type("userdata", sd)
    end)
end)

-- @describe lurek.dsp.newSynthWave
describe("lurek.dsp.newSynthWave", function()
    -- @covers lurek.dsp.newSynthWave
    it("newSynthWave returns SoundData userdata", function()
        local sd = lurek.dsp.newSynthWave("sine", 440, 0.01, 44100, 0.5, nil)
        expect_type("userdata", sd)
    end)

    -- @covers lurek.dsp.newSynthWave
    it("newSynthWave accepts adsr table", function()
        local sd = lurek.dsp.newSynthWave("square", 220, 0.05, 44100, 0.5,
            { attack = 0.01, decay = 0.01, sustain = 0.8, release = 0.02 })
        expect_type("userdata", sd)
    end)
end)

-- @describe lurek.dsp.newLevelDetector
describe("lurek.dsp.newLevelDetector", function()
    -- @covers lurek.dsp.newLevelDetector
    it("newLevelDetector returns userdata", function()
        local det = lurek.dsp.newLevelDetector()
        expect_type("userdata", det)
    end)

    -- @covers lurek.dsp.newLevelDetector
    -- @covers LLevelDetector:process_sample
    -- @covers LLevelDetector:get_rms
    -- @covers LLevelDetector:get_peak
    it("process_sample updates rms and peak", function()
        local det = lurek.dsp.newLevelDetector()
        det:process_sample(0.5)
        det:process_sample(-0.5)
        local rms = det:get_rms()
        local peak = det:get_peak()
        expect_type("number", rms)
        expect_type("number", peak)
        expect_equal(rms > 0, true)
        expect_equal(peak > 0, true)
    end)

    -- @covers lurek.dsp.newLevelDetector
    -- @covers LLevelDetector:to_db
    it("to_db converts linear amplitude to dBFS", function()
        local det = lurek.dsp.newLevelDetector()
        local db = det:to_db(1.0)
        expect_type("number", db)
        expect_near(0.0, db, 0.1)
    end)

    -- @covers lurek.dsp.newLevelDetector
    -- @covers LLevelDetector:reset
    -- @covers LLevelDetector:get_rms
    it("reset clears rms to zero", function()
        local det = lurek.dsp.newLevelDetector()
        det:process_sample(0.8)
        det:reset()
        local rms = det:get_rms()
        expect_near(0.0, rms, 0.0001)
    end)

    -- @covers lurek.dsp.newLevelDetector
    -- @covers LLevelDetector:process
    it("process accepts LSoundData and returns table with rms peak clipping", function()
        local sound = lurek.audio.newSoundData(44100, 44100, 1)
        local det = lurek.dsp.newLevelDetector()
        local result = det:process(sound)
        expect_type("table", result)
        expect_type("number", result.rms)
        expect_type("number", result.peak)
        expect_type("boolean", result.clipping)
    end)
end)

-- @describe lurek.dsp.newSpectrumAnalyzer
describe("lurek.dsp.newSpectrumAnalyzer", function()
    -- @covers lurek.dsp.newSpectrumAnalyzer
    it("newSpectrumAnalyzer returns userdata", function()
        local sa = lurek.dsp.newSpectrumAnalyzer()
        expect_type("userdata", sa)
    end)

    -- @covers lurek.dsp.newSpectrumAnalyzer
    -- @covers LSpectrumAnalyzer:setSize
    -- @covers LSpectrumAnalyzer:analyze
    it("setSize and analyze return frequency bins", function()
        local sa = lurek.dsp.newSpectrumAnalyzer()
        sa:setSize(16)
        local sound = lurek.audio.newSoundData(4410, 44100, 1)
        local bins = sa:analyze(sound)
        expect_type("table", bins)
        expect_equal(#bins > 0, true)
        expect_type("number", bins[1].frequency)
        expect_type("number", bins[1].magnitude)
    end)
end)

-- @describe lurek.dsp.newWaveform
describe("lurek.dsp.newWaveform", function()
    -- @covers lurek.dsp.newWaveform
    it("newWaveform returns userdata", function()
        local wf = lurek.dsp.newWaveform("sine")
        expect_type("userdata", wf)
    end)

    -- @covers lurek.dsp.newWaveform
    -- @covers LWaveform:type
    it("type returns the waveform kind string", function()
        local wf = lurek.dsp.newWaveform("sawtooth")
        expect_equal("sawtooth", wf:type())
    end)

    -- @covers lurek.dsp.newWaveform
    -- @covers LWaveform:render
    it("render returns LSoundData userdata", function()
        local wf = lurek.dsp.newWaveform("square")
        local sd = wf:render(440, 0.01, 44100, 0.5)
        expect_type("userdata", sd)
    end)
end)

-- @describe lurek.dsp.newAdsrEnvelope
describe("lurek.dsp.newAdsrEnvelope", function()
    -- @covers lurek.dsp.newAdsrEnvelope
    it("newAdsrEnvelope returns userdata", function()
        local env = lurek.dsp.newAdsrEnvelope(0.01, 0.01, 0.8, 0.05)
        expect_type("userdata", env)
    end)

    -- @covers lurek.dsp.newAdsrEnvelope
    -- @covers LAdsrEnvelope:trigger_on
    -- @covers LAdsrEnvelope:next_sample
    -- @covers LAdsrEnvelope:is_idle
    it("trigger_on then next_sample returns non-zero and is_idle is false", function()
        local env = lurek.dsp.newAdsrEnvelope(0.5, 0.1, 0.8, 0.1)
        env:trigger_on()
        local sample = env:next_sample()
        expect_type("number", sample)
        expect_equal(sample >= 0.0, true)
        expect_equal(false, env:is_idle())
    end)

    -- @covers lurek.dsp.newAdsrEnvelope
    -- @covers LAdsrEnvelope:trigger_off
    -- @covers LAdsrEnvelope:is_idle
    it("trigger_off makes envelope converge to idle", function()
        local env = lurek.dsp.newAdsrEnvelope(0.0, 0.0, 1.0, 0.0)
        env:trigger_on()
        env:trigger_off()
        expect_no_error(function()
            for _ = 1, 10 do env:next_sample() end
        end)
        expect_equal(true, env:is_idle())
    end)

    -- @covers lurek.dsp.newAdsrEnvelope
    -- @covers LAdsrEnvelope:apply
    it("apply accepts LSoundData without error", function()
        local sound = lurek.audio.newSoundData(4410, 44100, 1)
        local env = lurek.dsp.newAdsrEnvelope(0.01, 0.01, 0.8, 0.02)
        expect_no_error(function()
            env:apply(sound)
        end)
    end)
end)

-- @describe lurek.dsp.newSynthesizer
describe("lurek.dsp.newSynthesizer", function()
    -- @covers lurek.dsp.newSynthesizer
    it("newSynthesizer returns userdata", function()
        local synth = lurek.dsp.newSynthesizer()
        expect_type("userdata", synth)
    end)

    -- @covers lurek.dsp.newSynthesizer
    -- @covers LSynthesizer:setWaveform
    -- @covers LSynthesizer:render
    it("setWaveform with string then render returns LSoundData", function()
        local synth = lurek.dsp.newSynthesizer()
        synth:setWaveform("triangle")
        local sd = synth:render(440, 0.01, 44100, 0.5)
        expect_type("userdata", sd)
    end)

    -- @covers lurek.dsp.newSynthesizer
    -- @covers LSynthesizer:setEnvelope
    -- @covers LSynthesizer:generate
    it("setEnvelope then generate returns LSoundData", function()
        local synth = lurek.dsp.newSynthesizer()
        local env = lurek.dsp.newAdsrEnvelope(0.01, 0.01, 0.8, 0.02)
        synth:setEnvelope(env)
        local sd = synth:generate(440, 0.05, 44100, 0.5)
        expect_type("userdata", sd)
    end)
end)

-- @describe lurek.dsp.newNode
describe("lurek.dsp.newNode", function()
    -- @covers lurek.dsp.newNode
    it("newNode returns userdata", function()
        local node = lurek.dsp.newNode("lowpass")
        expect_type("userdata", node)
    end)

    -- @covers lurek.dsp.newNode
    -- @covers LDspNode:type
    it("type returns the node kind string", function()
        local node = lurek.dsp.newNode("highpass")
        expect_equal("highpass", node:type())
    end)

    -- @covers lurek.dsp.newNode
    -- @covers LDspNode:setParam
    -- @covers LDspNode:getParam
    it("setParam and getParam round-trip a parameter", function()
        local node = lurek.dsp.newNode("lowpass")
        node:setParam("cutoff", 1500.0)
        local val = node:getParam("cutoff")
        expect_type("number", val)
        expect_near(1500.0, val, 1.0)
    end)
end)

-- @describe lurek.dsp.newGraph
describe("lurek.dsp.newGraph", function()
    -- @covers lurek.dsp.newGraph
    it("newGraph returns userdata", function()
        local g = lurek.dsp.newGraph()
        expect_type("userdata", g)
    end)

    -- @covers lurek.dsp.newGraph
    -- @covers LDspGraph:addNode
    -- @covers LDspGraph:connect
    -- @covers LDspGraph:disconnect
    it("addNode, connect, disconnect without error", function()
        local g = lurek.dsp.newGraph()
        local n1 = lurek.dsp.newNode("lowpass")
        local n2 = lurek.dsp.newNode("gain")
        local id1 = g:addNode(n1)
        local id2 = g:addNode(n2)
        expect_type("number", id1)
        expect_type("number", id2)
        local ok_c = g:connect(id1, id2)
        expect_equal(true, ok_c)
        local ok_d = g:disconnect(id1, id2)
        expect_equal(true, ok_d)
    end)

    -- @covers lurek.dsp.newGraph
    -- @covers LDspGraph:process
    it("process returns LSoundData", function()
        local g = lurek.dsp.newGraph()
        local n = lurek.dsp.newNode("gain")
        g:addNode(n)
        local sound = lurek.audio.newSoundData(4410, 44100, 1)
        local out = g:process(sound)
        expect_type("userdata", out)
    end)

    -- @covers lurek.dsp.newGraph
    -- @covers LDspGraph:clear
    it("clear does not error", function()
        local g = lurek.dsp.newGraph()
        local n = lurek.dsp.newNode("lowpass")
        g:addNode(n)
        expect_no_error(function()
            g:clear()
        end)
    end)
end)

test_summary()
