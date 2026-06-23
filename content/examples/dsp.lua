--- DSP Processing Example
--- Demonstrates offline audio processing, normalization, and visualization using lurek.dsp.


--@api: lurek.dsp.newEffectParams
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local params = lurek.dsp.newEffectParams("reverb", 0.7, 0.4, 0.2)
    dsp_log("effect params type=" .. type(params))
    dsp_log("effect=" .. tostring(params.type))
    dsp_log("wet mix p1=" .. tostring(params.p1))
    dsp_log("room size p2=" .. tostring(params.p2))
    dsp_log("damping p3=" .. tostring(params.p3))
end

--@api: lurek.dsp.processOffline
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local input = "content/examples/assets/audio/sample_click.wav"
    local output = "save/_fs_tests/dsp_processed.wav"
    local effects = {
        lurek.dsp.newEffectParams("reverb", 0.7, 0.4, 0.2),
        lurek.dsp.newEffectParams("compressor", 0.8, 2.5, 0.1),
    }
    local ok = lurek.dsp.processOffline(input, output, effects)
    dsp_log("processOffline ok=" .. tostring(ok))
    dsp_log("input=" .. input)
    dsp_log("effects applied=" .. tostring(#effects))
    dsp_log("output exists=" .. tostring(lurek.filesystem.exists(output)))
end

--@api: lurek.dsp.normalize
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local input = "content/examples/assets/audio/sample_tone.wav"
    local output = "save/_fs_tests/dsp_normalized.wav"
    local ok = lurek.dsp.normalize(input, output, 0.9)
    dsp_log("normalize ok=" .. tostring(ok))
    dsp_log("target peak=0.9")
    dsp_log("input=" .. input)
    dsp_log("normalized exists=" .. tostring(lurek.filesystem.exists(output)))
end

--@api: lurek.dsp.waveformToPng
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local input = "content/examples/assets/audio/sample_loop.wav"
    local output = "save/_fs_tests/dsp_waveform.png"
    local ok = lurek.dsp.waveformToPng(input, output, 256, 64)
    dsp_log("waveformToPng ok=" .. tostring(ok))
    dsp_log("width=256")
    dsp_log("height=64")
    dsp_log("png exists=" .. tostring(lurek.filesystem.exists(output)))
end

--@api: lurek.dsp.spectrogramToPng
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local input = "content/examples/assets/audio/sample_loop.wav"
    local output = "save/_fs_tests/dsp_spectrogram.png"
    local ok = lurek.dsp.spectrogramToPng(input, output, 256, 128)
    dsp_log("spectrogramToPng ok=" .. tostring(ok))
    dsp_log("width=256")
    dsp_log("height=128")
    dsp_log("png exists=" .. tostring(lurek.filesystem.exists(output)))
end

--@api: lurek.dsp.addEffectToBus
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    lurek.audio.newBus("dsp_bus_fx")
    local id = lurek.dsp.addEffectToBus("dsp_bus_fx", "lowpass", {value=2000.0})
    local second_id = lurek.dsp.addEffectToBus("dsp_bus_fx", "highpass", {value=180.0})
    dsp_log("added lowpass id=" .. tostring(id))
    dsp_log("added highpass id=" .. tostring(second_id))
    dsp_log("effect ids are distinct=" .. tostring(id ~= second_id))
end

--@api: lurek.dsp.removeEffectFromBus
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    lurek.audio.newBus("dsp_bus_rm")
    local id = lurek.dsp.addEffectToBus("dsp_bus_rm", "lowpass", {value=2000.0})
    local ok = lurek.dsp.removeEffectFromBus("dsp_bus_rm", id)
    local replacement_id = lurek.dsp.addEffectToBus("dsp_bus_rm", "highpass", {value=220.0})
    dsp_log("removeEffectFromBus ok=" .. tostring(ok))
    dsp_log("removed id=" .. tostring(id))
    dsp_log("replacement id=" .. tostring(replacement_id))
    dsp_log("ids differ after remove=" .. tostring(id ~= replacement_id))
end

--@api: lurek.dsp.setEffectParam
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    lurek.audio.newBus("dsp_bus_param")
    local id = lurek.dsp.addEffectToBus("dsp_bus_param", "lowpass", {value=2000.0})
    local ok = lurek.dsp.setEffectParam("dsp_bus_param", id, "cutoff", 1000.0)
    local ok2 = lurek.dsp.setEffectParam("dsp_bus_param", id, "q", 0.7)
    dsp_log("setEffectParam cutoff ok=" .. tostring(ok))
    dsp_log("setEffectParam q ok=" .. tostring(ok2))
end

--@api: lurek.dsp.analyzeFft
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local sd = lurek.dsp.newSynthWave("sine", 440, 0.1, 44100, 0.8)
    local result = lurek.dsp.analyzeFft(sd, 64)
    dsp_log("analyzeFft bins=" .. tostring(#result))
    dsp_log("first bin frequency=" .. tostring(result[1] and result[1].frequency))
    dsp_log("first bin magnitude=" .. tostring(result[1] and result[1].magnitude))
end

--@api: lurek.dsp.analyzePeak
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local sd = lurek.dsp.newSynthWave("sine", 440, 0.1, 44100, 0.8)
    local peak = lurek.dsp.analyzePeak(sd)
    local rms = lurek.dsp.analyzeRms(sd)
    dsp_log("analyzePeak peak=" .. tostring(peak))
    dsp_log("matching rms=" .. tostring(rms))
    dsp_log("sampleCount=" .. tostring(sd:getSampleCount()))
end

--@api: lurek.dsp.analyzeRms
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local sd = lurek.dsp.newSynthWave("sine", 440, 0.1, 44100, 0.8)
    local rms = lurek.dsp.analyzeRms(sd)
    local peak = lurek.dsp.analyzePeak(sd)
    dsp_log("analyzeRms rms=" .. tostring(rms))
    dsp_log("reference peak=" .. tostring(peak))
    dsp_log("sampleCount=" .. tostring(sd:getSampleCount()))
end

--@api: lurek.dsp.applyBandpass
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local sd = lurek.dsp.newSynthWave("sine", 440, 0.1, 44100, 0.8)
    lurek.dsp.applyBandpass(sd, 500.0, 2000.0)
    local peak = lurek.dsp.analyzePeak(sd)
    dsp_log("applyBandpass sampleCount=" .. tostring(sd:getSampleCount()))
    dsp_log("post-filter peak=" .. tostring(peak))
    dsp_log("post-filter rms=" .. tostring(lurek.dsp.analyzeRms(sd)))
end

--@api: lurek.dsp.applyGain
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local sd = lurek.dsp.newSynthWave("sine", 440, 0.1, 44100, 0.8)
    lurek.dsp.applyGain(sd, 0.5)
    dsp_log("applyGain sampleCount=" .. tostring(sd:getSampleCount()))
    dsp_log("peak after gain=" .. tostring(lurek.dsp.analyzePeak(sd)))
    dsp_log("rms after gain=" .. tostring(lurek.dsp.analyzeRms(sd)))
end

--@api: lurek.dsp.applyHighpass
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local sd = lurek.dsp.newSynthWave("sine", 440, 0.1, 44100, 0.8)
    lurek.dsp.applyHighpass(sd, 2000.0)
    dsp_log("applyHighpass sampleCount=" .. tostring(sd:getSampleCount()))
    dsp_log("post-filter peak=" .. tostring(lurek.dsp.analyzePeak(sd)))
    dsp_log("post-filter rms=" .. tostring(lurek.dsp.analyzeRms(sd)))
end

--@api: lurek.dsp.applyLowpass
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local sd = lurek.dsp.newSynthWave("sine", 440, 0.1, 44100, 0.8)
    lurek.dsp.applyLowpass(sd, 1000.0)
    dsp_log("applyLowpass sampleCount=" .. tostring(sd:getSampleCount()))
    dsp_log("post-filter peak=" .. tostring(lurek.dsp.analyzePeak(sd)))
    dsp_log("post-filter rms=" .. tostring(lurek.dsp.analyzeRms(sd)))
end

--@api: lurek.dsp.newSineWave
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local sd = lurek.dsp.newSineWave(440, 0.01, 44100, 0.5)
    dsp_log("newSineWave type=" .. type(sd))
    dsp_log("sampleCount=" .. tostring(sd:getSampleCount()))
    dsp_log("peak=" .. tostring(lurek.dsp.analyzePeak(sd)))
    dsp_log("rms=" .. tostring(lurek.dsp.analyzeRms(sd)))
end

--@api: lurek.dsp.newSquareWave
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local sd = lurek.dsp.newSquareWave(440, 0.01, 44100, 0.5)
    dsp_log("newSquareWave type=" .. type(sd))
    dsp_log("sampleCount=" .. tostring(sd:getSampleCount()))
    dsp_log("peak=" .. tostring(lurek.dsp.analyzePeak(sd)))
    dsp_log("rms=" .. tostring(lurek.dsp.analyzeRms(sd)))
end

--@api: lurek.dsp.newSawtoothWave
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local sd = lurek.dsp.newSawtoothWave(440, 0.01, 44100, 0.5)
    dsp_log("newSawtoothWave type=" .. type(sd))
    dsp_log("sampleCount=" .. tostring(sd:getSampleCount()))
    dsp_log("peak=" .. tostring(lurek.dsp.analyzePeak(sd)))
    dsp_log("rms=" .. tostring(lurek.dsp.analyzeRms(sd)))
end

--@api: lurek.dsp.newTriangleWave
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local sd = lurek.dsp.newTriangleWave(440, 0.01, 44100, 0.5)
    dsp_log("newTriangleWave type=" .. type(sd))
    dsp_log("sampleCount=" .. tostring(sd:getSampleCount()))
    dsp_log("peak=" .. tostring(lurek.dsp.analyzePeak(sd)))
    dsp_log("rms=" .. tostring(lurek.dsp.analyzeRms(sd)))
end

--@api: lurek.dsp.newWhiteNoise
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local sd = lurek.dsp.newWhiteNoise(0.01, 44100, 0.5, 42)
    dsp_log("newWhiteNoise type=" .. type(sd))
    dsp_log("sampleCount=" .. tostring(sd:getSampleCount()))
    dsp_log("peak=" .. tostring(lurek.dsp.analyzePeak(sd)))
    dsp_log("rms=" .. tostring(lurek.dsp.analyzeRms(sd)))
end

--@api: lurek.dsp.newSynthWave
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local sd = lurek.dsp.newSynthWave("sine", 440, 0.01, 44100, 0.5, nil)
    dsp_log("newSynthWave type=" .. type(sd))
    dsp_log("sampleCount=" .. tostring(sd:getSampleCount()))
    dsp_log("peak=" .. tostring(lurek.dsp.analyzePeak(sd)))
    dsp_log("rms=" .. tostring(lurek.dsp.analyzeRms(sd)))
end

--@api: lurek.dsp.newLevelDetector
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local det = lurek.dsp.newLevelDetector({ clipThreshold = 0.99 })
    det:process_sample(0.5)
    det:process_sample(-0.5)
    dsp_log("newLevelDetector rms=" .. tostring(det:get_rms()))
    dsp_log("newLevelDetector peak=" .. tostring(det:get_peak()))
    dsp_log("reference 1.0 db=" .. tostring(det:to_db(1.0)))
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    local result = det:process(sd)
    dsp_log("process rms=" .. tostring(result.rms))
    det:reset()
    dsp_log("reset rms=" .. tostring(det:get_rms()))
end

--@api: LLevelDetector:process_sample
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local det = lurek.dsp.newLevelDetector({})
    det:process_sample(0.8)
    det:process_sample(-0.3)
    dsp_log("process_sample peak=" .. tostring(det:get_peak()))
    dsp_log("process_sample rms=" .. tostring(det:get_rms()))
end

--@api: LLevelDetector:process
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local det = lurek.dsp.newLevelDetector({})
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    local result = det:process(sd)
    dsp_log("process rms=" .. tostring(result.rms))
    dsp_log("process peak=" .. tostring(result.peak))
end

--@api: LLevelDetector:get_rms
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local det = lurek.dsp.newLevelDetector({})
    det:process_sample(0.5)
    local rms = det:get_rms()
    dsp_log("get_rms rms=" .. tostring(rms))
    dsp_log("get_rms peak=" .. tostring(det:get_peak()))
end

--@api: LLevelDetector:get_peak
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local det = lurek.dsp.newLevelDetector({})
    det:process_sample(0.9)
    local peak = det:get_peak()
    dsp_log("get_peak peak=" .. tostring(peak))
    dsp_log("get_peak rms=" .. tostring(det:get_rms()))
end

--@api: LLevelDetector:to_db
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local det = lurek.dsp.newLevelDetector({})
    local db = det:to_db(0.5)
    det:process_sample(0.5)
    dsp_log("to_db db=" .. tostring(db))
    dsp_log("peak after sample=" .. tostring(det:get_peak()))
    dsp_log("rms after sample=" .. tostring(det:get_rms()))
end

--@api: LLevelDetector:reset
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local det = lurek.dsp.newLevelDetector({})
    det:process_sample(0.7)
    det:reset()
    dsp_log("reset rms=" .. tostring(det:get_rms()))
    dsp_log("reset peak=" .. tostring(det:get_peak()))
end

--@api: lurek.dsp.newSpectrumAnalyzer
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local sa = lurek.dsp.newSpectrumAnalyzer({ size = 64 })
    sa:setSize(32)
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    local bins = sa:analyze(sd)
    dsp_log("newSpectrumAnalyzer bins=" .. tostring(#bins))
end

--@api: LSpectrumAnalyzer:setSize
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local sa = lurek.dsp.newSpectrumAnalyzer({ size = 64 })
    sa:setSize(128)
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    local bins = sa:analyze(sd)
    dsp_log("setSize bins=" .. tostring(#bins))
end

--@api: LSpectrumAnalyzer:analyze
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local sa = lurek.dsp.newSpectrumAnalyzer({ size = 32 })
    local sd = lurek.dsp.newSineWave(440, 0.01, 44100, 0.8)
    local bins = sa:analyze(sd)
    dsp_log("analyze bins=" .. tostring(#bins))
    dsp_log("analyze bin[1]=" .. tostring(bins[1]))
end

--@api: lurek.dsp.newWaveform
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local waveform_name = "sawtooth"
    local wf = lurek.dsp.newWaveform(waveform_name)
    local sd = wf:render(220, 0.01, 44100, 0.5)
    dsp_log("newWaveform requested=" .. waveform_name)
    dsp_log("waveform type=" .. tostring(wf:type()))
    dsp_log("rendered sampleCount=" .. tostring(sd:getSampleCount()))
    dsp_log("rendered peak=" .. tostring(lurek.dsp.analyzePeak(sd)))
end

--@api: LWaveform:type
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local wf = lurek.dsp.newWaveform("square")
    local waveform_type = wf:type()
    local preview = wf:render(330, 0.01, 44100, 0.4)
    dsp_log("type waveform=" .. tostring(waveform_type))
    dsp_log("preview sampleCount=" .. tostring(preview:getSampleCount()))
    dsp_log("preview rms=" .. tostring(lurek.dsp.analyzeRms(preview)))
end

--@api: LWaveform:render
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local wf = lurek.dsp.newWaveform("triangle")
    local sd = wf:render(330, 0.01, 44100, 0.6)
    dsp_log("render waveform=" .. tostring(wf:type()))
    dsp_log("render frequency=330")
    dsp_log("render sampleCount=" .. tostring(sd:getSampleCount()))
    dsp_log("render peak=" .. tostring(lurek.dsp.analyzePeak(sd)))
end

--@api: lurek.dsp.newAdsrEnvelope
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local env = lurek.dsp.newAdsrEnvelope(0.01, 0.01, 0.8, 0.05)
    env:trigger_on()
    local s = env:next_sample()
    dsp_log("newAdsrEnvelope sample=" .. tostring(s))
    dsp_log("newAdsrEnvelope idle=" .. tostring(env:is_idle()))
    env:trigger_off()
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    env:apply(sd)
    dsp_log("apply ok")
end

--@api: LAdsrEnvelope:trigger_on
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local env = lurek.dsp.newAdsrEnvelope(0.01, 0.01, 0.8, 0.05)
    env:trigger_on()
    local first_sample = env:next_sample()
    local second_sample = env:next_sample()
    dsp_log("trigger_on first sample=" .. tostring(first_sample))
    dsp_log("trigger_on second sample=" .. tostring(second_sample))
    dsp_log("trigger_on idle=" .. tostring(env:is_idle()))
end

--@api: LAdsrEnvelope:trigger_off
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local env = lurek.dsp.newAdsrEnvelope(0.01, 0.01, 0.8, 0.05)
    env:trigger_on()
    local attack_sample = env:next_sample()
    env:trigger_off()
    local release_sample = env:next_sample()
    dsp_log("trigger_off attack sample=" .. tostring(attack_sample))
    dsp_log("trigger_off release sample=" .. tostring(release_sample))
    dsp_log("trigger_off idle=" .. tostring(env:is_idle()))
end

--@api: LAdsrEnvelope:next_sample
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local env = lurek.dsp.newAdsrEnvelope(0.005, 0.01, 0.7, 0.05)
    env:trigger_on()
    local s1 = env:next_sample()
    local s2 = env:next_sample()
    dsp_log("next_sample s1=" .. tostring(s1) .. " s2=" .. tostring(s2))
end

--@api: LAdsrEnvelope:is_idle
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local env = lurek.dsp.newAdsrEnvelope(0.01, 0.01, 0.8, 0.05)
    local before = env:is_idle()
    env:trigger_on()
    local during_note = env:is_idle()
    env:trigger_off()
    local after_release = env:is_idle()
    dsp_log("is_idle before=" .. tostring(before))
    dsp_log("is_idle during note=" .. tostring(during_note))
    dsp_log("is_idle after release=" .. tostring(after_release))
end

--@api: LAdsrEnvelope:apply
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local env = lurek.dsp.newAdsrEnvelope(0.01, 0.01, 0.8, 0.05)
    env:trigger_on()
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    env:apply(sd)
    dsp_log("apply sampleCount=" .. tostring(sd:getSampleCount()))
end

--@api: lurek.dsp.newSynthesizer
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local synth = lurek.dsp.newSynthesizer()
    synth:setWaveform("triangle")
    local env = lurek.dsp.newAdsrEnvelope(0.01, 0.01, 0.8, 0.02)
    synth:setEnvelope(env)
    local sd = synth:render(440, 0.01, 44100, 0.5)
    dsp_log("newSynthesizer render type=" .. type(sd))
    local sd2 = synth:generate(440, 0.01, 44100, 0.5)
    dsp_log("generate type=" .. type(sd2))
end

--@api: LSynthesizer:setWaveform
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local synth = lurek.dsp.newSynthesizer()
    synth:setWaveform("sawtooth")
    local rendered = synth:render(440, 0.01, 44100, 0.5)
    dsp_log("setWaveform waveform=sawtooth")
    dsp_log("setWaveform sampleCount=" .. tostring(rendered:getSampleCount()))
    dsp_log("setWaveform peak=" .. tostring(lurek.dsp.analyzePeak(rendered)))
    dsp_log("setWaveform rms=" .. tostring(lurek.dsp.analyzeRms(rendered)))
end

--@api: LSynthesizer:setEnvelope
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local synth = lurek.dsp.newSynthesizer()
    local env = lurek.dsp.newAdsrEnvelope(0.01, 0.02, 0.7, 0.03)
    synth:setEnvelope(env)
    local sd = synth:render(523, 0.01, 44100, 0.5)
    dsp_log("setEnvelope sampleCount=" .. tostring(sd:getSampleCount()))
end

--@api: LSynthesizer:render
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local synth = lurek.dsp.newSynthesizer()
    synth:setWaveform("sine")
    local sd = synth:render(330, 0.01, 44100, 0.5)
    dsp_log("render type=" .. type(sd))
    dsp_log("render sampleCount=" .. tostring(sd:getSampleCount()))
end

--@api: LSynthesizer:generate
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local synth = lurek.dsp.newSynthesizer()
    local envelope = lurek.dsp.newAdsrEnvelope(0.005, 0.02, 0.6, 0.03)
    synth:setEnvelope(envelope)
    local generated = synth:generate(440, 0.02, 44100, 0.7)
    dsp_log("generate type=" .. type(generated))
    dsp_log("generate sampleCount=" .. tostring(generated:getSampleCount()))
    dsp_log("generate peak=" .. tostring(lurek.dsp.analyzePeak(generated)))
    dsp_log("generate rms=" .. tostring(lurek.dsp.analyzeRms(generated)))
end

--@api: lurek.dsp.newNode
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local node = lurek.dsp.newNode("lowpass")
    dsp_log("newNode type=" .. node:type())
    node:setParam("cutoff", 1000.0)
    local val = node:getParam("cutoff")
    dsp_log("getParam cutoff=" .. tostring(val))
end

--@api: LDspNode:type
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local node = lurek.dsp.newNode("gain")
    local node_type = node:type()
    node:setParam("gain", 0.75)
    dsp_log("type node=" .. tostring(node_type))
    dsp_log("type gain param=" .. tostring(node:getParam("gain")))
    dsp_log("type ready for graph routing")
end

--@api: LDspNode:setParam
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local node = lurek.dsp.newNode("lowpass")
    node:setParam("cutoff", 800.0)
    node:setParam("q", 0.5)
    dsp_log("setParam type=" .. tostring(node:type()))
    dsp_log("setParam cutoff=" .. tostring(node:getParam("cutoff")))
    dsp_log("setParam q=" .. tostring(node:getParam("q")))
end

--@api: LDspNode:getParam
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local node = lurek.dsp.newNode("gain")
    node:setParam("gain", 0.7)
    local gain_value = node:getParam("gain")
    dsp_log("getParam node=" .. tostring(node:type()))
    dsp_log("getParam gain=" .. tostring(gain_value))
    dsp_log("getParam matches target=" .. tostring(gain_value == 0.7))
end

--@api: lurek.dsp.newGraph
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local g = lurek.dsp.newGraph()
    local n1 = lurek.dsp.newNode("lowpass")
    local n2 = lurek.dsp.newNode("gain")
    local id1 = g:addNode(n1)
    local id2 = g:addNode(n2)
    local ok = g:connect(id1, id2)
    dsp_log("newGraph connect ok=" .. tostring(ok))
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    local out = g:process(sd)
    dsp_log("process type=" .. type(out))
    local ok2 = g:disconnect(id1, id2)
    dsp_log("disconnect ok=" .. tostring(ok2))
    g:clear()
    dsp_log("clear ok")
end

--@api: LDspGraph:addNode
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local g = lurek.dsp.newGraph()
    local lowpass_id = g:addNode(lurek.dsp.newNode("lowpass"))
    local gain_id = g:addNode(lurek.dsp.newNode("gain"))
    local connected = g:connect(lowpass_id, gain_id)
    local output = g:process(lurek.audio.newSoundData(44100, 44100, 1))
    dsp_log("addNode lowpass id=" .. tostring(lowpass_id))
    dsp_log("addNode gain id=" .. tostring(gain_id))
    dsp_log("addNode connect ok=" .. tostring(connected))
    dsp_log("addNode output type=" .. type(output))
end

--@api: LDspGraph:connect
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local g = lurek.dsp.newGraph()
    local id1 = g:addNode(lurek.dsp.newNode("lowpass"))
    local id2 = g:addNode(lurek.dsp.newNode("gain"))
    local ok = g:connect(id1, id2)
    dsp_log("connect ok=" .. tostring(ok))
end

--@api: LDspGraph:disconnect
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local g = lurek.dsp.newGraph()
    local id1 = g:addNode(lurek.dsp.newNode("lowpass"))
    local id2 = g:addNode(lurek.dsp.newNode("gain"))
    g:connect(id1, id2)
    local ok = g:disconnect(id1, id2)
    dsp_log("disconnect ok=" .. tostring(ok))
end

--@api: LDspGraph:process
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local g = lurek.dsp.newGraph()
    g:addNode(lurek.dsp.newNode("lowpass"))
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    local out = g:process(sd)
    dsp_log("process type=" .. type(out))
    dsp_log("process sampleCount=" .. tostring(out:getSampleCount()))
end

--@api: LDspGraph:clear
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    -- Build a small graph, process audio through it, then clear it.
    -- After clear() the graph can be reused with fresh nodes.
    local g = lurek.dsp.newGraph()
    local n1 = lurek.dsp.newNode("lowpass")
    local n2 = lurek.dsp.newNode("gain")
    local id1 = g:addNode(n1)
    local id2 = g:addNode(n2)
    g:connect(id1, id2)
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    g:process(sd)
    g:clear()
    dsp_log("clear graph reset, node count 0")
end
