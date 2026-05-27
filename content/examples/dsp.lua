--- DSP Processing Example
--- Demonstrates offline audio processing, normalization, and visualization using lurek.dsp.

--@api-stub: lurek.dsp.newEffectParams
do
    local params = lurek.dsp.newEffectParams("reverb", 0.7, 0.4, 0.2)
    print("lurek.dsp.newEffectParams type=" .. type(params))
    print("effect=" .. tostring(params.type))
end

--@api-stub: lurek.dsp.processOffline
do
    local input = "content/examples/assets/audio/sample_click.wav"
    local output = "save/_fs_tests/dsp_processed.wav"
    local effects = {
        lurek.dsp.newEffectParams("reverb", 0.7, 0.4, 0.2),
        lurek.dsp.newEffectParams("compressor", 0.8, 2.5, 0.1),
    }
    local ok = lurek.dsp.processOffline(input, output, effects)
    print("lurek.dsp.processOffline ok=" .. tostring(ok))
    print("output exists=" .. tostring(lurek.filesystem.exists(output)))
end

--@api-stub: lurek.dsp.normalize
do
    local input = "content/examples/assets/audio/sample_tone.wav"
    local output = "save/_fs_tests/dsp_normalized.wav"
    local ok = lurek.dsp.normalize(input, output, 0.9)
    print("lurek.dsp.normalize ok=" .. tostring(ok))
    print("normalized exists=" .. tostring(lurek.filesystem.exists(output)))
end

--@api-stub: lurek.dsp.waveformToPng
do
    local input = "content/examples/assets/audio/sample_loop.wav"
    local output = "save/_fs_tests/dsp_waveform.png"
    local ok = lurek.dsp.waveformToPng(input, output, 256, 64)
    print("lurek.dsp.waveformToPng ok=" .. tostring(ok))
    print("png exists=" .. tostring(lurek.filesystem.exists(output)))
end

--@api-stub: lurek.dsp.spectrogramToPng
do
    local input = "content/examples/assets/audio/sample_loop.wav"
    local output = "save/_fs_tests/dsp_spectrogram.png"
    local ok = lurek.dsp.spectrogramToPng(input, output, 256, 128)
    print("lurek.dsp.spectrogramToPng ok=" .. tostring(ok))
    print("png exists=" .. tostring(lurek.filesystem.exists(output)))
end

--@api-stub: lurek.dsp.addEffectToBus
do
    lurek.audio.newBus("dsp_bus_fx")
    local id = lurek.dsp.addEffectToBus("dsp_bus_fx", "lowpass", {value=2000.0})
    print("lurek.dsp.addEffectToBus id=" .. tostring(id))
end

--@api-stub: lurek.dsp.removeEffectFromBus
do
    lurek.audio.newBus("dsp_bus_rm")
    local id = lurek.dsp.addEffectToBus("dsp_bus_rm", "lowpass", {value=2000.0})
    local ok = lurek.dsp.removeEffectFromBus("dsp_bus_rm", id)
    print("lurek.dsp.removeEffectFromBus ok=" .. tostring(ok))
end

--@api-stub: lurek.dsp.setEffectParam
do
    lurek.audio.newBus("dsp_bus_param")
    local id = lurek.dsp.addEffectToBus("dsp_bus_param", "lowpass", {value=2000.0})
    lurek.dsp.setEffectParam("dsp_bus_param", id, "cutoff", 1000.0)
    print("lurek.dsp.setEffectParam ok")
end

--@api-stub: lurek.dsp.analyzeFft
do
    local sd = lurek.audio.newSynthWave("sine", 440, 0.1, 44100, 0.8)
    local result = lurek.dsp.analyzeFft(sd, 64)
    print("lurek.dsp.analyzeFft bins=" .. tostring(#result))
end

--@api-stub: lurek.dsp.analyzePeak
do
    local sd = lurek.audio.newSynthWave("sine", 440, 0.1, 44100, 0.8)
    local peak = lurek.dsp.analyzePeak(sd)
    print("lurek.dsp.analyzePeak peak=" .. tostring(peak))
end

--@api-stub: lurek.dsp.analyzeRms
do
    local sd = lurek.audio.newSynthWave("sine", 440, 0.1, 44100, 0.8)
    local rms = lurek.dsp.analyzeRms(sd)
    print("lurek.dsp.analyzeRms rms=" .. tostring(rms))
end

--@api-stub: lurek.dsp.applyBandpass
do
    local sd = lurek.audio.newSynthWave("sine", 440, 0.1, 44100, 0.8)
    lurek.dsp.applyBandpass(sd, 500.0, 2000.0)
    print("lurek.dsp.applyBandpass sampleCount=" .. tostring(sd:getSampleCount()))
end

--@api-stub: lurek.dsp.applyGain
do
    local sd = lurek.audio.newSynthWave("sine", 440, 0.1, 44100, 0.8)
    lurek.dsp.applyGain(sd, 0.5)
    print("lurek.dsp.applyGain sampleCount=" .. tostring(sd:getSampleCount()))
end

--@api-stub: lurek.dsp.applyHighpass
do
    local sd = lurek.audio.newSynthWave("sine", 440, 0.1, 44100, 0.8)
    lurek.dsp.applyHighpass(sd, 2000.0)
    print("lurek.dsp.applyHighpass sampleCount=" .. tostring(sd:getSampleCount()))
end

--@api-stub: lurek.dsp.applyLowpass
do
    local sd = lurek.audio.newSynthWave("sine", 440, 0.1, 44100, 0.8)
    lurek.dsp.applyLowpass(sd, 1000.0)
    print("lurek.dsp.applyLowpass sampleCount=" .. tostring(sd:getSampleCount()))
end

--@api-stub: lurek.dsp.newSineWave
do
    local sd = lurek.dsp.newSineWave(440, 0.01, 44100, 0.5)
    print("lurek.dsp.newSineWave type=" .. type(sd))
end

--@api-stub: lurek.dsp.newSquareWave
do
    local sd = lurek.dsp.newSquareWave(440, 0.01, 44100, 0.5)
    print("lurek.dsp.newSquareWave type=" .. type(sd))
end

--@api-stub: lurek.dsp.newSawtoothWave
do
    local sd = lurek.dsp.newSawtoothWave(440, 0.01, 44100, 0.5)
    print("lurek.dsp.newSawtoothWave type=" .. type(sd))
end

--@api-stub: lurek.dsp.newTriangleWave
do
    local sd = lurek.dsp.newTriangleWave(440, 0.01, 44100, 0.5)
    print("lurek.dsp.newTriangleWave type=" .. type(sd))
end

--@api-stub: lurek.dsp.newWhiteNoise
do
    local sd = lurek.dsp.newWhiteNoise(0.01, 44100, 0.5, 42)
    print("lurek.dsp.newWhiteNoise type=" .. type(sd))
end

--@api-stub: lurek.dsp.newSynthWave
do
    local sd = lurek.dsp.newSynthWave("sine", 440, 0.01, 44100, 0.5, nil)
    print("lurek.dsp.newSynthWave type=" .. type(sd))
end

--@api-stub: lurek.dsp.newLevelDetector
do
    local det = lurek.dsp.newLevelDetector({ clipThreshold = 0.99 })
    det:process_sample(0.5)
    det:process_sample(-0.5)
    print("lurek.dsp.newLevelDetector rms=" .. tostring(det:get_rms()))
    print("LLevelDetector:get_peak peak=" .. tostring(det:get_peak()))
    print("LLevelDetector:to_db db=" .. tostring(det:to_db(1.0)))
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    local result = det:process(sd)
    print("LLevelDetector:process rms=" .. tostring(result.rms))
    det:reset()
    print("LLevelDetector:reset rms=" .. tostring(det:get_rms()))
end

--@api-stub: LLevelDetector:process_sample
--@api-stub: LLevelDetector:process
--@api-stub: LLevelDetector:get_rms
--@api-stub: LLevelDetector:get_peak
--@api-stub: LLevelDetector:to_db
--@api-stub: LLevelDetector:reset

--@api-stub: lurek.dsp.newSpectrumAnalyzer
do
    local sa = lurek.dsp.newSpectrumAnalyzer({ size = 64 })
    sa:setSize(32)
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    local bins = sa:analyze(sd)
    print("lurek.dsp.newSpectrumAnalyzer bins=" .. tostring(#bins))
end

--@api-stub: LSpectrumAnalyzer:setSize
--@api-stub: LSpectrumAnalyzer:analyze

--@api-stub: lurek.dsp.newWaveform
do
    local wf = lurek.dsp.newWaveform("sawtooth")
    print("lurek.dsp.newWaveform type=" .. wf:type())
    local sd = wf:render(220, 0.01, 44100, 0.5)
    print("LWaveform:render type=" .. type(sd))
end

--@api-stub: LWaveform:type
--@api-stub: LWaveform:render

--@api-stub: lurek.dsp.newAdsrEnvelope
do
    local env = lurek.dsp.newAdsrEnvelope(0.01, 0.01, 0.8, 0.05)
    env:trigger_on()
    local s = env:next_sample()
    print("lurek.dsp.newAdsrEnvelope sample=" .. tostring(s))
    print("LAdsrEnvelope:is_idle idle=" .. tostring(env:is_idle()))
    env:trigger_off()
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    env:apply(sd)
    print("LAdsrEnvelope:apply ok")
end

--@api-stub: LAdsrEnvelope:trigger_on
--@api-stub: LAdsrEnvelope:trigger_off
--@api-stub: LAdsrEnvelope:next_sample
--@api-stub: LAdsrEnvelope:is_idle
--@api-stub: LAdsrEnvelope:apply

--@api-stub: lurek.dsp.newSynthesizer
do
    local synth = lurek.dsp.newSynthesizer()
    synth:setWaveform("triangle")
    local env = lurek.dsp.newAdsrEnvelope(0.01, 0.01, 0.8, 0.02)
    synth:setEnvelope(env)
    local sd = synth:render(440, 0.01, 44100, 0.5)
    print("lurek.dsp.newSynthesizer render type=" .. type(sd))
    local sd2 = synth:generate(440, 0.01, 44100, 0.5)
    print("LSynthesizer:generate type=" .. type(sd2))
end

--@api-stub: LSynthesizer:setWaveform
--@api-stub: LSynthesizer:setEnvelope
--@api-stub: LSynthesizer:render
--@api-stub: LSynthesizer:generate

--@api-stub: lurek.dsp.newNode
do
    local node = lurek.dsp.newNode("lowpass")
    print("lurek.dsp.newNode type=" .. node:type())
    node:setParam("cutoff", 1000.0)
    local val = node:getParam("cutoff")
    print("LDspNode:getParam cutoff=" .. tostring(val))
end

--@api-stub: LDspNode:type
--@api-stub: LDspNode:setParam
--@api-stub: LDspNode:getParam

--@api-stub: lurek.dsp.newGraph
do
    local g = lurek.dsp.newGraph()
    local n1 = lurek.dsp.newNode("lowpass")
    local n2 = lurek.dsp.newNode("gain")
    local id1 = g:addNode(n1)
    local id2 = g:addNode(n2)
    local ok = g:connect(id1, id2)
    print("lurek.dsp.newGraph connect ok=" .. tostring(ok))
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    local out = g:process(sd)
    print("LDspGraph:process type=" .. type(out))
    local ok2 = g:disconnect(id1, id2)
    print("LDspGraph:disconnect ok=" .. tostring(ok2))
    g:clear()
    print("LDspGraph:clear ok")
end

--@api-stub: LDspGraph:addNode
--@api-stub: LDspGraph:connect
--@api-stub: LDspGraph:disconnect
--@api-stub: LDspGraph:process
--@api-stub: LDspGraph:clear
