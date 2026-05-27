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
