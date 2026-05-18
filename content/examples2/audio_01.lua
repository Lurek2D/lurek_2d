--- Audio Examples Part 2: Orientation, distance models, MIDI, synthesis, DSP, bus effects, pool, offline

--@api-stub: lurek.audio.getOrientation
-- Returns the orientation vectors (forward + up) of a source.
do
    local path = "sounds/speaker.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setOrientation(src, 0, 0, -1, 0, 1, 0)
    local fx, fy, fz, ux, uy, uz = lurek.audio.getOrientation(src)
    print("forward = " .. fx .. "," .. fy .. "," .. fz .. " up = " .. ux .. "," .. uy .. "," .. uz)
end

--@api-stub: lurek.audio.setDopplerScale
-- Sets the global Doppler effect intensity multiplier.
do
    lurek.audio.setDopplerScale(1.5)
    print("doppler scale = " .. lurek.audio.getDopplerScale())
end

--@api-stub: lurek.audio.getDopplerScale
-- Returns the current global Doppler scale factor.
do
    lurek.audio.setDopplerScale(2.0)
    local ds = lurek.audio.getDopplerScale()
    print("doppler = " .. ds)
end

--@api-stub: lurek.audio.setDistanceModel
-- Sets the distance attenuation model for spatial audio.
do
    lurek.audio.setDistanceModel("inverse")
    print("distance model = " .. lurek.audio.getDistanceModel())
end

--@api-stub: lurek.audio.getDistanceModel
-- Returns the current distance attenuation model name.
do
    lurek.audio.setDistanceModel("linear")
    local model = lurek.audio.getDistanceModel()
    print("model = " .. model)
end

--@api-stub: lurek.audio.setMeter
-- Sets the master peak level for metering purposes.
do
    lurek.audio.setMeter(0.8)
    print("meter set to 0.8")
end

--@api-stub: lurek.audio.getMeter
-- Returns the current master peak level.
do
    lurek.audio.setMeter(0.6)
    local lvl = lurek.audio.getMeter()
    print("meter = " .. lvl)
end

--@api-stub: lurek.audio.newMidiPlayer
-- Creates a new MIDI player instance.
do
    local player = lurek.audio.newMidiPlayer()
    print("midi player = " .. tostring(player ~= nil))
end

--@api-stub: lurek.audio.newSoundData
-- Creates a SoundData object for procedural audio or file decode.
do
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    print("sound data created = " .. tostring(sd ~= nil))
end

--@api-stub: lurek.audio.setMidiSoundFont
-- Sets the SoundFont file used for MIDI synthesis.
do
    local path = "audio/gm.sf2"
    lurek.audio.setMidiSoundFont(path)
    print("soundfont set = " .. tostring(lurek.audio.hasMidiSoundFont()))
end

--@api-stub: lurek.audio.hasMidiSoundFont
-- Returns true if a SoundFont is currently loaded.
do
    local has = lurek.audio.hasMidiSoundFont()
    print("has soundfont = " .. tostring(has))
end

--@api-stub: lurek.audio.clearMidiSoundFont
-- Clears the loaded SoundFont and reverts to default synthesis.
do
    lurek.audio.clearMidiSoundFont()
    print("soundfont cleared = " .. tostring(not lurek.audio.hasMidiSoundFont()))
end

--@api-stub: lurek.audio.newDecoder
-- Creates a streaming audio decoder for a file.
do
    local path = "sounds/song.ogg"
    local dec = lurek.audio.newDecoder(path, 4096)
    print("decoder = " .. tostring(dec ~= nil))
end

--@api-stub: lurek.audio.newQueueableSource
-- Creates a queueable source for streaming PCM data buffer by buffer.
do
    local qid = lurek.audio.newQueueableSource(44100, 16, 1, 4)
    print("queueable id = " .. qid)
end

--@api-stub: lurek.audio.queueSource
-- Queues decoded audio data for playback on a queueable source.
do
    local qid = lurek.audio.newQueueableSource(44100, 16, 1, 4)
    local sd = lurek.audio.newSoundData(1024, 44100, 1)
    lurek.audio.queueSource(qid, sd)
    print("queued chunk")
end

--@api-stub: lurek.audio.getFreeBufferCount
-- Returns the number of free buffers in a queueable source.
do
    local qid = lurek.audio.newQueueableSource(44100, 16, 1, 4)
    local free = lurek.audio.getFreeBufferCount(qid)
    print("free buffers = " .. free)
end

--@api-stub: lurek.audio.playQueueable
-- Starts playback of a queueable audio source.
do
    local qid = lurek.audio.newQueueableSource(44100, 16, 1, 4)
    local sd = lurek.audio.newSoundData(1024, 44100, 1)
    lurek.audio.queueSource(qid, sd)
    lurek.audio.playQueueable(qid)
    print("queueable playing")
end

--@api-stub: lurek.audio.stopQueueable
-- Stops playback of a queueable audio source.
do
    local qid = lurek.audio.newQueueableSource(44100, 16, 1, 4)
    lurek.audio.stopQueueable(qid)
    print("queueable stopped")
end

--@api-stub: lurek.audio.getPlaybackDevices
-- Returns a list of available audio playback device names.
do
    local devices = lurek.audio.getPlaybackDevices()
    print("devices = " .. #devices)
end

--@api-stub: lurek.audio.getPlaybackDevice
-- Returns the name of the current playback device.
do
    local dev = lurek.audio.getPlaybackDevice()
    print("current device = " .. dev)
end

--@api-stub: lurek.audio.setPlaybackDevice
-- Sets the active audio playback device by name.
do
    local devices = lurek.audio.getPlaybackDevices()
    if #devices > 0 then
        lurek.audio.setPlaybackDevice(devices[1])
        print("set device = " .. devices[1])
    end
end

--@api-stub: lurek.audio.create_bus
-- Creates a named audio bus with optional parent.
do
    lurek.audio.create_bus("master_sfx", nil)
    lurek.audio.create_bus("footsteps", "master_sfx")
    print("bus hierarchy created")
end

--@api-stub: lurek.audio.set_bus_volume
-- Sets the volume of a named bus.
do
    lurek.audio.create_bus("music_bus", nil)
    lurek.audio.set_bus_volume("music_bus", 0.7)
    print("music_bus volume = 0.7")
end

--@api-stub: lurek.audio.add_effect
-- Adds an effect to a named bus and returns an effect ID.
do
    lurek.audio.create_bus("fx_bus", nil)
    local eid = lurek.audio.add_effect("fx_bus", "reverb", { value = 0.5 })
    print("effect id = " .. eid)
end

--@api-stub: lurek.audio.remove_effect
-- Removes an effect from a bus by effect ID.
do
    lurek.audio.create_bus("temp_bus", nil)
    local eid = lurek.audio.add_effect("temp_bus", "lowpass", { value = 800 })
    local ok = lurek.audio.remove_effect("temp_bus", eid)
    print("removed = " .. tostring(ok))
end

--@api-stub: lurek.audio.set_effect_param
-- Sets a parameter on an existing bus effect.
do
    lurek.audio.create_bus("eq_bus", nil)
    local eid = lurek.audio.add_effect("eq_bus", "highpass", { value = 200 })
    local ok = lurek.audio.set_effect_param("eq_bus", eid, "value", 500)
    print("param set = " .. tostring(ok))
end

--@api-stub: lurek.audio.newSineWave
-- Generates a sine wave as a SoundData buffer.
do
    local sd = lurek.audio.newSineWave(440, 1.0, 44100, 0.8)
    print("sine wave = " .. tostring(sd ~= nil))
end

--@api-stub: lurek.audio.newSquareWave
-- Generates a square wave as a SoundData buffer.
do
    local sd = lurek.audio.newSquareWave(220, 0.5, 44100, 0.6)
    print("square wave = " .. tostring(sd ~= nil))
end

--@api-stub: lurek.audio.newSawtoothWave
-- Generates a sawtooth wave as a SoundData buffer.
do
    local sd = lurek.audio.newSawtoothWave(330, 0.5, 44100, 0.7)
    print("sawtooth wave = " .. tostring(sd ~= nil))
end

--@api-stub: lurek.audio.newTriangleWave
-- Generates a triangle wave as a SoundData buffer.
do
    local sd = lurek.audio.newTriangleWave(550, 0.5, 44100, 0.5)
    print("triangle wave = " .. tostring(sd ~= nil))
end

--@api-stub: lurek.audio.newWhiteNoise
-- Generates white noise as a SoundData buffer using a seed.
do
    local sd = lurek.audio.newWhiteNoise(1.0, 44100, 0.4, 12345)
    print("white noise = " .. tostring(sd ~= nil))
end

--@api-stub: lurek.audio.applyLowpass
-- Applies a lowpass filter in-place to sound data.
do
    local sd = lurek.audio.newSineWave(1000, 0.5, 44100, 0.8)
    lurek.audio.applyLowpass(sd, 500)
    print("lowpass applied at 500 Hz")
end

--@api-stub: lurek.audio.applyHighpass
-- Applies a highpass filter in-place to sound data.
do
    local sd = lurek.audio.newWhiteNoise(0.5, 44100, 0.6, 99)
    lurek.audio.applyHighpass(sd, 2000)
    print("highpass applied at 2000 Hz")
end

--@api-stub: lurek.audio.applyBandpass
-- Applies a bandpass filter in-place to sound data.
do
    local sd = lurek.audio.newWhiteNoise(0.5, 44100, 0.5, 42)
    lurek.audio.applyBandpass(sd, 300, 3000)
    print("bandpass 300-3000 Hz applied")
end

--@api-stub: lurek.audio.applyGain
-- Applies a gain multiplier in-place to sound data.
do
    local sd = lurek.audio.newSineWave(440, 0.5, 44100, 0.3)
    lurek.audio.applyGain(sd, 2.0)
    print("gain x2 applied")
end

--@api-stub: lurek.audio.mixInto
-- Mixes source sound data into destination in-place.
do
    local dest = lurek.audio.newSineWave(440, 1.0, 44100, 0.5)
    local src = lurek.audio.newSineWave(880, 1.0, 44100, 0.3)
    lurek.audio.mixInto(dest, src)
    print("mixed 880 Hz into 440 Hz")
end

--@api-stub: lurek.audio.saveWAV
-- Encodes sound data as a WAV file and saves it.
do
    local sd = lurek.audio.newSineWave(440, 1.0, 44100, 0.8)
    lurek.audio.saveWAV(sd, "output/test_tone.wav")
    print("saved WAV file")
end

--@api-stub: lurek.audio.setStereoWidth
-- Sets the stereo width of a source (0 = mono, 1 = full stereo).
do
    local path = "sounds/music.ogg"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.setStereoWidth(src, 0.5)
    print("stereo width = " .. lurek.audio.getStereoWidth(src))
end

--@api-stub: lurek.audio.getStereoWidth
-- Returns the current stereo width of a source.
do
    local path = "sounds/ambient.ogg"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.setStereoWidth(src, 0.8)
    local w = lurek.audio.getStereoWidth(src)
    print("width = " .. w)
end

--@api-stub: lurek.audio.setRandomPitch
-- Sets a random pitch range for natural variation on each play.
do
    local path = "sounds/step.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setRandomPitch(src, 0.9, 1.1)
    print("random pitch range = 0.9 to 1.1")
end

--@api-stub: lurek.audio.clearRandomPitch
-- Clears any random pitch range on a source.
do
    local path = "sounds/click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setRandomPitch(src, 0.8, 1.2)
    lurek.audio.clearRandomPitch(src)
    print("random pitch cleared")
end

--@api-stub: lurek.audio.crossfade
-- Crossfades from one source to another over a duration.
do
    local p1 = "sounds/track_a.ogg"
    local p2 = "sounds/track_b.ogg"
    local from = lurek.audio.newSource(p1, "stream")
    local to = lurek.audio.newSource(p2, "stream")
    lurek.audio.play(from)
    lurek.audio.crossfade(from, to, 3.0)
    print("crossfading over 3s")
end

--@api-stub: lurek.audio.getBusPeak
-- Returns the peak amplitude level of a bus for VU displays.
do
    lurek.audio.create_bus("vu_bus", nil)
    local peak = lurek.audio.getBusPeak("vu_bus")
    print("bus peak = " .. peak)
end

--@api-stub: lurek.audio.getBusRms
-- Returns the RMS amplitude of a bus for level metering.
do
    lurek.audio.create_bus("rms_bus", nil)
    local rms = lurek.audio.getBusRms("rms_bus")
    print("bus rms = " .. rms)
end

--@api-stub: lurek.audio.newPool
-- Creates a polyphonic sound pool for concurrent playback of the same file.
do
    local path = "sounds/shot.wav"
    local pool = lurek.audio.newPool(path, 8)
    print("pool voices = " .. pool:getVoiceCount())
end

--@api-stub: lurek.audio.processOffline
-- Processes an audio file through an effects chain and writes the result.
do
    local effects = {
        { type = "lowpass", p1 = 1000 },
        { type = "gain", p1 = 0.8 },
    }
    local path_in = "sounds/raw.wav"
    local path_out = "output/processed.wav"
    lurek.audio.processOffline(path_in, path_out, effects)
    print("offline processing done")
end

--@api-stub: lurek.audio.normalizeFile
-- Normalizes an audio file to a target peak amplitude.
do
    local path_in = "sounds/quiet.wav"
    local path_out = "output/normalized.wav"
    lurek.audio.normalizeFile(path_in, path_out, 0.9)
    print("normalized to 0.9 peak")
end

--@api-stub: lurek.audio.waveformToPng
-- Renders a waveform visualization as a PNG image.
do
    local path_in = "sounds/song.ogg"
    local path_out = "output/waveform.png"
    lurek.audio.waveformToPng(path_in, path_out, 800, 200)
    print("waveform image saved")
end

--@api-stub: lurek.audio.spectrogramToPng
-- Renders a spectrogram visualization as a PNG image.
do
    local path_in = "sounds/song.ogg"
    local path_out = "output/spectrogram.png"
    lurek.audio.spectrogramToPng(path_in, path_out, 800, 400)
    print("spectrogram image saved")
end

--@api-stub: LSource:play
-- Plays an audio source using the method syntax.
do
    local path = "sounds/coin.wav"
    local src = lurek.audio.newSource(path, "static")
    src:play()
    print("playing via method = " .. tostring(src:isPlaying()))
end

print("audio_01.lua")
