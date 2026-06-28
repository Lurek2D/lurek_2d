--- DSP Processing Example
--- Demonstrates offline audio processing, normalization, and visualization using lurek.dsp.


--@api: lurek.dsp.newEffectParams
do

    local params = lurek.dsp.newEffectParams("reverb", 0.7, 0.4, 0.2)
    lurek.log.info("effect params type=" .. type(params))
    lurek.log.info("effect=" .. tostring(params.type))
    lurek.log.info("wet mix p1=" .. tostring(params.p1))
    lurek.log.info("room size p2=" .. tostring(params.p2))
    lurek.log.info("damping p3=" .. tostring(params.p3))
end

--@api: lurek.dsp.processOffline
do

    local input = "content/examples/assets/audio/sample_click.wav"
    local output = "save/_fs_tests/dsp_processed.wav"
    local effects = {
        lurek.dsp.newEffectParams("reverb", 0.7, 0.4, 0.2),
        lurek.dsp.newEffectParams("compressor", 0.8, 2.5, 0.1),
    }
    local ok = lurek.dsp.processOffline(input, output, effects)
    lurek.log.info("processOffline ok=" .. tostring(ok))
    lurek.log.info("input=" .. input)
    lurek.log.info("effects applied=" .. tostring(#effects))
    lurek.log.info("output exists=" .. tostring(lurek.filesystem.exists(output)))
end

--@api: lurek.dsp.normalize
do

    local input = "content/examples/assets/audio/sample_tone.wav"
    local output = "save/_fs_tests/dsp_normalized.wav"
    local ok = lurek.dsp.normalize(input, output, 0.9)
    lurek.log.info("normalize ok=" .. tostring(ok))
    lurek.log.info("target peak=0.9")
    lurek.log.info("input=" .. input)
    lurek.log.info("normalized exists=" .. tostring(lurek.filesystem.exists(output)))
end

--@api: lurek.dsp.waveformToPng
do

    local input = "content/examples/assets/audio/sample_loop.wav"
    local output = "save/_fs_tests/dsp_waveform.png"
    local ok = lurek.dsp.waveformToPng(input, output, 256, 64)
    lurek.log.info("waveformToPng ok=" .. tostring(ok))
    lurek.log.info("width=256")
    lurek.log.info("height=64")
    lurek.log.info("png exists=" .. tostring(lurek.filesystem.exists(output)))
end

--@api: lurek.dsp.spectrogramToPng
do

    local input = "content/examples/assets/audio/sample_loop.wav"
    local output = "save/_fs_tests/dsp_spectrogram.png"
    local ok = lurek.dsp.spectrogramToPng(input, output, 256, 128)
    lurek.log.info("spectrogramToPng ok=" .. tostring(ok))
    lurek.log.info("width=256")
    lurek.log.info("height=128")
    lurek.log.info("png exists=" .. tostring(lurek.filesystem.exists(output)))
end

--@api: lurek.dsp.addEffectToBus
do

    lurek.audio.newBus("dsp_bus_fx")
    local id = lurek.dsp.addEffectToBus("dsp_bus_fx", "lowpass", {value=2000.0})
    local second_id = lurek.dsp.addEffectToBus("dsp_bus_fx", "highpass", {value=180.0})
    lurek.log.info("added lowpass id=" .. tostring(id))
    lurek.log.info("added highpass id=" .. tostring(second_id))
    lurek.log.info("effect ids are distinct=" .. tostring(id ~= second_id))
end

--@api: lurek.dsp.removeEffectFromBus
do

    lurek.audio.newBus("dsp_bus_rm")
    local id = lurek.dsp.addEffectToBus("dsp_bus_rm", "lowpass", {value=2000.0})
    local ok = lurek.dsp.removeEffectFromBus("dsp_bus_rm", id)
    local replacement_id = lurek.dsp.addEffectToBus("dsp_bus_rm", "highpass", {value=220.0})
    lurek.log.info("removeEffectFromBus ok=" .. tostring(ok))
    lurek.log.info("removed id=" .. tostring(id))
    lurek.log.info("replacement id=" .. tostring(replacement_id))
    lurek.log.info("ids differ after remove=" .. tostring(id ~= replacement_id))
end

--@api: lurek.dsp.setEffectParam
do

    lurek.audio.newBus("dsp_bus_param")
    local id = lurek.dsp.addEffectToBus("dsp_bus_param", "lowpass", {value=2000.0})
    local ok = lurek.dsp.setEffectParam("dsp_bus_param", id, "cutoff", 1000.0)
    local ok2 = lurek.dsp.setEffectParam("dsp_bus_param", id, "q", 0.7)
    lurek.log.info("setEffectParam cutoff ok=" .. tostring(ok))
    lurek.log.info("setEffectParam q ok=" .. tostring(ok2))
end

--@api: lurek.dsp.analyzeFft
do

    local sd = lurek.dsp.newSynthWave("sine", 440, 0.1, 44100, 0.8)
    local result = lurek.dsp.analyzeFft(sd, 64)
    lurek.log.info("analyzeFft bins=" .. tostring(#result))
    lurek.log.info("first bin frequency=" .. tostring(result[1] and result[1].frequency))
    lurek.log.info("first bin magnitude=" .. tostring(result[1] and result[1].magnitude))
end

--@api: lurek.dsp.analyzePeak
do

    local sd = lurek.dsp.newSynthWave("sine", 440, 0.1, 44100, 0.8)
    local peak = lurek.dsp.analyzePeak(sd)
    local rms = lurek.dsp.analyzeRms(sd)
    lurek.log.info("analyzePeak peak=" .. tostring(peak))
    lurek.log.info("matching rms=" .. tostring(rms))
    lurek.log.info("sampleCount=" .. tostring(sd:getSampleCount()))
end

--@api: lurek.dsp.analyzeRms
do

    local sd = lurek.dsp.newSynthWave("sine", 440, 0.1, 44100, 0.8)
    local rms = lurek.dsp.analyzeRms(sd)
    local peak = lurek.dsp.analyzePeak(sd)
    lurek.log.info("analyzeRms rms=" .. tostring(rms))
    lurek.log.info("reference peak=" .. tostring(peak))
    lurek.log.info("sampleCount=" .. tostring(sd:getSampleCount()))
end

--@api: lurek.dsp.applyBandpass
do

    local sd = lurek.dsp.newSynthWave("sine", 440, 0.1, 44100, 0.8)
    lurek.dsp.applyBandpass(sd, 500.0, 2000.0)
    local peak = lurek.dsp.analyzePeak(sd)
    lurek.log.info("applyBandpass sampleCount=" .. tostring(sd:getSampleCount()))
    lurek.log.info("post-filter peak=" .. tostring(peak))
    lurek.log.info("post-filter rms=" .. tostring(lurek.dsp.analyzeRms(sd)))
end

--@api: lurek.dsp.applyGain
do

    local sd = lurek.dsp.newSynthWave("sine", 440, 0.1, 44100, 0.8)
    lurek.dsp.applyGain(sd, 0.5)
    lurek.log.info("applyGain sampleCount=" .. tostring(sd:getSampleCount()))
    lurek.log.info("peak after gain=" .. tostring(lurek.dsp.analyzePeak(sd)))
    lurek.log.info("rms after gain=" .. tostring(lurek.dsp.analyzeRms(sd)))
end

--@api: lurek.dsp.applyHighpass
do

    local sd = lurek.dsp.newSynthWave("sine", 440, 0.1, 44100, 0.8)
    lurek.dsp.applyHighpass(sd, 2000.0)
    lurek.log.info("applyHighpass sampleCount=" .. tostring(sd:getSampleCount()))
    lurek.log.info("post-filter peak=" .. tostring(lurek.dsp.analyzePeak(sd)))
    lurek.log.info("post-filter rms=" .. tostring(lurek.dsp.analyzeRms(sd)))
end

--@api: lurek.dsp.applyLowpass
do

    local sd = lurek.dsp.newSynthWave("sine", 440, 0.1, 44100, 0.8)
    lurek.dsp.applyLowpass(sd, 1000.0)
    lurek.log.info("applyLowpass sampleCount=" .. tostring(sd:getSampleCount()))
    lurek.log.info("post-filter peak=" .. tostring(lurek.dsp.analyzePeak(sd)))
    lurek.log.info("post-filter rms=" .. tostring(lurek.dsp.analyzeRms(sd)))
end

--@api: lurek.dsp.newSineWave
do

    local sd = lurek.dsp.newSineWave(440, 0.01, 44100, 0.5)
    lurek.log.info("newSineWave type=" .. type(sd))
    lurek.log.info("sampleCount=" .. tostring(sd:getSampleCount()))
    lurek.log.info("peak=" .. tostring(lurek.dsp.analyzePeak(sd)))
    lurek.log.info("rms=" .. tostring(lurek.dsp.analyzeRms(sd)))
end

--@api: lurek.dsp.newSquareWave
do

    local sd = lurek.dsp.newSquareWave(440, 0.01, 44100, 0.5)
    lurek.log.info("newSquareWave type=" .. type(sd))
    lurek.log.info("sampleCount=" .. tostring(sd:getSampleCount()))
    lurek.log.info("peak=" .. tostring(lurek.dsp.analyzePeak(sd)))
    lurek.log.info("rms=" .. tostring(lurek.dsp.analyzeRms(sd)))
end

--@api: lurek.dsp.newSawtoothWave
do

    local sd = lurek.dsp.newSawtoothWave(440, 0.01, 44100, 0.5)
    lurek.log.info("newSawtoothWave type=" .. type(sd))
    lurek.log.info("sampleCount=" .. tostring(sd:getSampleCount()))
    lurek.log.info("peak=" .. tostring(lurek.dsp.analyzePeak(sd)))
    lurek.log.info("rms=" .. tostring(lurek.dsp.analyzeRms(sd)))
end

--@api: lurek.dsp.newTriangleWave
do

    local sd = lurek.dsp.newTriangleWave(440, 0.01, 44100, 0.5)
    lurek.log.info("newTriangleWave type=" .. type(sd))
    lurek.log.info("sampleCount=" .. tostring(sd:getSampleCount()))
    lurek.log.info("peak=" .. tostring(lurek.dsp.analyzePeak(sd)))
    lurek.log.info("rms=" .. tostring(lurek.dsp.analyzeRms(sd)))
end

--@api: lurek.dsp.newWhiteNoise
do

    local sd = lurek.dsp.newWhiteNoise(0.01, 44100, 0.5, 42)
    lurek.log.info("newWhiteNoise type=" .. type(sd))
    lurek.log.info("sampleCount=" .. tostring(sd:getSampleCount()))
    lurek.log.info("peak=" .. tostring(lurek.dsp.analyzePeak(sd)))
    lurek.log.info("rms=" .. tostring(lurek.dsp.analyzeRms(sd)))
end

--@api: lurek.dsp.newSynthWave
do

    local sd = lurek.dsp.newSynthWave("sine", 440, 0.01, 44100, 0.5, nil)
    lurek.log.info("newSynthWave type=" .. type(sd))
    lurek.log.info("sampleCount=" .. tostring(sd:getSampleCount()))
    lurek.log.info("peak=" .. tostring(lurek.dsp.analyzePeak(sd)))
    lurek.log.info("rms=" .. tostring(lurek.dsp.analyzeRms(sd)))
end

--@api: lurek.dsp.newLevelDetector
do

    local det = lurek.dsp.newLevelDetector({ clipThreshold = 0.99 })
    det:process_sample(0.5)
    det:process_sample(-0.5)
    lurek.log.info("newLevelDetector rms=" .. tostring(det:get_rms()))
    lurek.log.info("newLevelDetector peak=" .. tostring(det:get_peak()))
    lurek.log.info("reference 1.0 db=" .. tostring(det:to_db(1.0)))
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    local result = det:process(sd)
    lurek.log.info("process rms=" .. tostring(result.rms))
    det:reset()
    lurek.log.info("reset rms=" .. tostring(det:get_rms()))
end

--@api: LLevelDetector:process_sample
do

    local det = lurek.dsp.newLevelDetector({})
    det:process_sample(0.8)
    det:process_sample(-0.3)
    lurek.log.info("process_sample peak=" .. tostring(det:get_peak()))
    lurek.log.info("process_sample rms=" .. tostring(det:get_rms()))
end

--@api: LLevelDetector:process
do

    local det = lurek.dsp.newLevelDetector({})
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    local result = det:process(sd)
    lurek.log.info("process rms=" .. tostring(result.rms))
    lurek.log.info("process peak=" .. tostring(result.peak))
end

--@api: LLevelDetector:get_rms
do

    local det = lurek.dsp.newLevelDetector({})
    det:process_sample(0.5)
    local rms = det:get_rms()
    lurek.log.info("get_rms rms=" .. tostring(rms))
    lurek.log.info("get_rms peak=" .. tostring(det:get_peak()))
end

--@api: LLevelDetector:get_peak
do

    local det = lurek.dsp.newLevelDetector({})
    det:process_sample(0.9)
    local peak = det:get_peak()
    lurek.log.info("get_peak peak=" .. tostring(peak))
    lurek.log.info("get_peak rms=" .. tostring(det:get_rms()))
end

--@api: LLevelDetector:to_db
do

    local det = lurek.dsp.newLevelDetector({})
    local db = det:to_db(0.5)
    det:process_sample(0.5)
    lurek.log.info("to_db db=" .. tostring(db))
    lurek.log.info("peak after sample=" .. tostring(det:get_peak()))
    lurek.log.info("rms after sample=" .. tostring(det:get_rms()))
end

--@api: LLevelDetector:reset
do

    local det = lurek.dsp.newLevelDetector({})
    det:process_sample(0.7)
    det:reset()
    lurek.log.info("reset rms=" .. tostring(det:get_rms()))
    lurek.log.info("reset peak=" .. tostring(det:get_peak()))
end

--@api: lurek.dsp.newSpectrumAnalyzer
do

    local sa = lurek.dsp.newSpectrumAnalyzer({ size = 64 })
    sa:setSize(32)
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    local bins = sa:analyze(sd)
    lurek.log.info("newSpectrumAnalyzer bins=" .. tostring(#bins))
end

--@api: LSpectrumAnalyzer:setSize
do

    local sa = lurek.dsp.newSpectrumAnalyzer({ size = 64 })
    sa:setSize(128)
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    local bins = sa:analyze(sd)
    lurek.log.info("setSize bins=" .. tostring(#bins))
end

--@api: LSpectrumAnalyzer:analyze
do

    local sa = lurek.dsp.newSpectrumAnalyzer({ size = 32 })
    local sd = lurek.dsp.newSineWave(440, 0.01, 44100, 0.8)
    local bins = sa:analyze(sd)
    lurek.log.info("analyze bins=" .. tostring(#bins))
    lurek.log.info("analyze bin[1]=" .. tostring(bins[1]))
end

--@api: lurek.dsp.newWaveform
do

    local waveform_name = "sawtooth"
    local wf = lurek.dsp.newWaveform(waveform_name)
    local sd = wf:render(220, 0.01, 44100, 0.5)
    lurek.log.info("newWaveform requested=" .. waveform_name)
    lurek.log.info("waveform type=" .. tostring(wf:type()))
    lurek.log.info("rendered sampleCount=" .. tostring(sd:getSampleCount()))
    lurek.log.info("rendered peak=" .. tostring(lurek.dsp.analyzePeak(sd)))
end

--@api: LWaveform:type
do

    local wf = lurek.dsp.newWaveform("square")
    local waveform_type = wf:type()
    local preview = wf:render(330, 0.01, 44100, 0.4)
    lurek.log.info("type waveform=" .. tostring(waveform_type))
    lurek.log.info("preview sampleCount=" .. tostring(preview:getSampleCount()))
    lurek.log.info("preview rms=" .. tostring(lurek.dsp.analyzeRms(preview)))
end

--@api: LWaveform:render
do

    local wf = lurek.dsp.newWaveform("triangle")
    local sd = wf:render(330, 0.01, 44100, 0.6)
    lurek.log.info("render waveform=" .. tostring(wf:type()))
    lurek.log.info("render frequency=330")
    lurek.log.info("render sampleCount=" .. tostring(sd:getSampleCount()))
    lurek.log.info("render peak=" .. tostring(lurek.dsp.analyzePeak(sd)))
end

--@api: lurek.dsp.newAdsrEnvelope
do

    local env = lurek.dsp.newAdsrEnvelope(0.01, 0.01, 0.8, 0.05)
    env:trigger_on()
    local s = env:next_sample()
    lurek.log.info("newAdsrEnvelope sample=" .. tostring(s))
    lurek.log.info("newAdsrEnvelope idle=" .. tostring(env:is_idle()))
    env:trigger_off()
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    env:apply(sd)
    lurek.log.info("apply ok")
end

--@api: LAdsrEnvelope:trigger_on
do

    local env = lurek.dsp.newAdsrEnvelope(0.01, 0.01, 0.8, 0.05)
    env:trigger_on()
    local first_sample = env:next_sample()
    local second_sample = env:next_sample()
    lurek.log.info("trigger_on first sample=" .. tostring(first_sample))
    lurek.log.info("trigger_on second sample=" .. tostring(second_sample))
    lurek.log.info("trigger_on idle=" .. tostring(env:is_idle()))
end

--@api: LAdsrEnvelope:trigger_off
do

    local env = lurek.dsp.newAdsrEnvelope(0.01, 0.01, 0.8, 0.05)
    env:trigger_on()
    local attack_sample = env:next_sample()
    env:trigger_off()
    local release_sample = env:next_sample()
    lurek.log.info("trigger_off attack sample=" .. tostring(attack_sample))
    lurek.log.info("trigger_off release sample=" .. tostring(release_sample))
    lurek.log.info("trigger_off idle=" .. tostring(env:is_idle()))
end

--@api: LAdsrEnvelope:next_sample
do

    local env = lurek.dsp.newAdsrEnvelope(0.005, 0.01, 0.7, 0.05)
    env:trigger_on()
    local s1 = env:next_sample()
    local s2 = env:next_sample()
    lurek.log.info("next_sample s1=" .. tostring(s1) .. " s2=" .. tostring(s2))
end

--@api: LAdsrEnvelope:is_idle
do

    local env = lurek.dsp.newAdsrEnvelope(0.01, 0.01, 0.8, 0.05)
    local before = env:is_idle()
    env:trigger_on()
    local during_note = env:is_idle()
    env:trigger_off()
    local after_release = env:is_idle()
    lurek.log.info("is_idle before=" .. tostring(before))
    lurek.log.info("is_idle during note=" .. tostring(during_note))
    lurek.log.info("is_idle after release=" .. tostring(after_release))
end

--@api: LAdsrEnvelope:apply
do

    local env = lurek.dsp.newAdsrEnvelope(0.01, 0.01, 0.8, 0.05)
    env:trigger_on()
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    env:apply(sd)
    lurek.log.info("apply sampleCount=" .. tostring(sd:getSampleCount()))
end

--@api: lurek.dsp.newSynthesizer
do

    local synth = lurek.dsp.newSynthesizer()
    synth:setWaveform("triangle")
    local env = lurek.dsp.newAdsrEnvelope(0.01, 0.01, 0.8, 0.02)
    synth:setEnvelope(env)
    local sd = synth:render(440, 0.01, 44100, 0.5)
    lurek.log.info("newSynthesizer render type=" .. type(sd))
    local sd2 = synth:generate(440, 0.01, 44100, 0.5)
    lurek.log.info("generate type=" .. type(sd2))
end

--@api: LSynthesizer:setWaveform
do

    local synth = lurek.dsp.newSynthesizer()
    synth:setWaveform("sawtooth")
    local rendered = synth:render(440, 0.01, 44100, 0.5)
    lurek.log.info("setWaveform waveform=sawtooth")
    lurek.log.info("setWaveform sampleCount=" .. tostring(rendered:getSampleCount()))
    lurek.log.info("setWaveform peak=" .. tostring(lurek.dsp.analyzePeak(rendered)))
    lurek.log.info("setWaveform rms=" .. tostring(lurek.dsp.analyzeRms(rendered)))
end

--@api: LSynthesizer:setEnvelope
do

    local synth = lurek.dsp.newSynthesizer()
    local env = lurek.dsp.newAdsrEnvelope(0.01, 0.02, 0.7, 0.03)
    synth:setEnvelope(env)
    local sd = synth:render(523, 0.01, 44100, 0.5)
    lurek.log.info("setEnvelope sampleCount=" .. tostring(sd:getSampleCount()))
end

--@api: LSynthesizer:render
do

    local synth = lurek.dsp.newSynthesizer()
    synth:setWaveform("sine")
    local sd = synth:render(330, 0.01, 44100, 0.5)
    lurek.log.info("render type=" .. type(sd))
    lurek.log.info("render sampleCount=" .. tostring(sd:getSampleCount()))
end

--@api: LSynthesizer:generate
do

    local synth = lurek.dsp.newSynthesizer()
    local envelope = lurek.dsp.newAdsrEnvelope(0.005, 0.02, 0.6, 0.03)
    synth:setEnvelope(envelope)
    local generated = synth:generate(440, 0.02, 44100, 0.7)
    lurek.log.info("generate type=" .. type(generated))
    lurek.log.info("generate sampleCount=" .. tostring(generated:getSampleCount()))
    lurek.log.info("generate peak=" .. tostring(lurek.dsp.analyzePeak(generated)))
    lurek.log.info("generate rms=" .. tostring(lurek.dsp.analyzeRms(generated)))
end

--@api: lurek.dsp.newNode
do

    local node = lurek.dsp.newNode("lowpass")
    lurek.log.info("newNode type=" .. node:type())
    node:setParam("cutoff", 1000.0)
    local val = node:getParam("cutoff")
    lurek.log.info("getParam cutoff=" .. tostring(val))
end

--@api: LDspNode:type
do

    local node = lurek.dsp.newNode("gain")
    local node_type = node:type()
    node:setParam("gain", 0.75)
    lurek.log.info("type node=" .. tostring(node_type))
    lurek.log.info("type gain param=" .. tostring(node:getParam("gain")))
    lurek.log.info("type ready for graph routing")
end

--@api: LDspNode:setParam
do

    local node = lurek.dsp.newNode("lowpass")
    node:setParam("cutoff", 800.0)
    node:setParam("q", 0.5)
    lurek.log.info("setParam type=" .. tostring(node:type()))
    lurek.log.info("setParam cutoff=" .. tostring(node:getParam("cutoff")))
    lurek.log.info("setParam q=" .. tostring(node:getParam("q")))
end

--@api: LDspNode:getParam
do

    local node = lurek.dsp.newNode("gain")
    node:setParam("gain", 0.7)
    local gain_value = node:getParam("gain")
    lurek.log.info("getParam node=" .. tostring(node:type()))
    lurek.log.info("getParam gain=" .. tostring(gain_value))
    lurek.log.info("getParam matches target=" .. tostring(gain_value == 0.7))
end

--@api: lurek.dsp.newGraph
do

    local g = lurek.dsp.newGraph()
    local n1 = lurek.dsp.newNode("lowpass")
    local n2 = lurek.dsp.newNode("gain")
    local id1 = g:addNode(n1)
    local id2 = g:addNode(n2)
    local ok = g:connect(id1, id2)
    lurek.log.info("newGraph connect ok=" .. tostring(ok))
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    local out = g:process(sd)
    lurek.log.info("process type=" .. type(out))
    local ok2 = g:disconnect(id1, id2)
    lurek.log.info("disconnect ok=" .. tostring(ok2))
    g:clear()
    lurek.log.info("clear ok")
end

--@api: LDspGraph:addNode
do

    local g = lurek.dsp.newGraph()
    local lowpass_id = g:addNode(lurek.dsp.newNode("lowpass"))
    local gain_id = g:addNode(lurek.dsp.newNode("gain"))
    local connected = g:connect(lowpass_id, gain_id)
    local output = g:process(lurek.audio.newSoundData(44100, 44100, 1))
    lurek.log.info("addNode lowpass id=" .. tostring(lowpass_id))
    lurek.log.info("addNode gain id=" .. tostring(gain_id))
    lurek.log.info("addNode connect ok=" .. tostring(connected))
    lurek.log.info("addNode output type=" .. type(output))
end

--@api: LDspGraph:connect
do

    local g = lurek.dsp.newGraph()
    local id1 = g:addNode(lurek.dsp.newNode("lowpass"))
    local id2 = g:addNode(lurek.dsp.newNode("gain"))
    local ok = g:connect(id1, id2)
    lurek.log.info("connect ok=" .. tostring(ok))
end

--@api: LDspGraph:disconnect
do

    local g = lurek.dsp.newGraph()
    local id1 = g:addNode(lurek.dsp.newNode("lowpass"))
    local id2 = g:addNode(lurek.dsp.newNode("gain"))
    g:connect(id1, id2)
    local ok = g:disconnect(id1, id2)
    lurek.log.info("disconnect ok=" .. tostring(ok))
end

--@api: LDspGraph:process
do

    local g = lurek.dsp.newGraph()
    g:addNode(lurek.dsp.newNode("lowpass"))
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    local out = g:process(sd)
    lurek.log.info("process type=" .. type(out))
    lurek.log.info("process sampleCount=" .. tostring(out:getSampleCount()))
end

--@api: LDspGraph:clear
do

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
    lurek.log.info("clear graph reset, node count 0")
end
