-- content/examples/audio.lua
-- Auto-generated from content/examples2/audio_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/audio.lua

--- Audio Examples Part 1: Source creation, playback control, volume, pitch, pan, master, bus, filters, spatial


--@api-stub: lurek.audio.newSource
-- Creates a new audio source from a file path with a source type.
do
    local path = "sounds/click.wav"
    local src = lurek.audio.newSource(path, "static")
    print("source created = " .. tostring(src ~= nil))
end

--@api-stub: lurek.audio.play
-- Begins playback of an audio source.
do
    local path = "sounds/bgm.ogg"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.play(src)
    print("playing = " .. tostring(lurek.audio.isPlaying(src)))
end

--@api-stub: lurek.audio.stop
-- Stops playback and resets position to the beginning.
do
    local path = "sounds/shot.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.play(src)
    lurek.audio.stop(src)
    print("stopped = " .. tostring(lurek.audio.isStopped(src)))
end

--@api-stub: lurek.audio.setVolume
-- Sets the volume of a source (0.0 = silent, 1.0 = full).
do
    local path = "sounds/alert.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setVolume(src, 0.5)
    print("volume = " .. lurek.audio.getVolume(src))
end

--@api-stub: lurek.audio.getVolume
-- Returns the current volume of a source.
do
    local path = "sounds/step.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setVolume(src, 0.8)
    local vol = lurek.audio.getVolume(src)
    print("volume = " .. vol)
end

--@api-stub: lurek.audio.pause
-- Pauses playback at the current position.
do
    local path = "sounds/music.ogg"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.play(src)
    lurek.audio.pause(src)
    print("paused = " .. tostring(lurek.audio.isPaused(src)))
end

--@api-stub: lurek.audio.resume
-- Resumes playback from the paused position.
do
    local path = "sounds/music.ogg"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.play(src)
    lurek.audio.pause(src)
    lurek.audio.resume(src)
    print("playing after resume = " .. tostring(lurek.audio.isPlaying(src)))
end

--@api-stub: lurek.audio.setPitch
-- Sets the pitch multiplier (1.0 = normal, 2.0 = octave up).
do
    local path = "sounds/ding.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setPitch(src, 1.5)
    print("pitch = " .. lurek.audio.getPitch(src))
end

--@api-stub: lurek.audio.getPitch
-- Returns the current pitch multiplier of a source.
do
    local path = "sounds/tone.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setPitch(src, 0.8)
    local p = lurek.audio.getPitch(src)
    print("pitch = " .. p)
end

--@api-stub: lurek.audio.isPlaying
-- Returns true if the source is currently playing.
do
    local path = "sounds/beep.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.play(src)
    print("after play = " .. tostring(lurek.audio.isPlaying(src)))
end

--@api-stub: lurek.audio.isPaused
-- Returns true if the source is paused.
do
    local path = "sounds/tick.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.play(src)
    lurek.audio.pause(src)
    print("isPaused = " .. tostring(lurek.audio.isPaused(src)))
end

--@api-stub: lurek.audio.isStopped
-- Returns true if the source is stopped (not playing, not paused).
do
    local path = "sounds/pop.wav"
    local src = lurek.audio.newSource(path, "static")
    print("initially stopped = " .. tostring(lurek.audio.isStopped(src)))
end

--@api-stub: lurek.audio.setLooping
-- Sets whether a source should loop when it reaches the end.
do
    local path = "sounds/ambient.ogg"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.setLooping(src, true)
    print("looping = " .. tostring(lurek.audio.isLooping(src)))
end

--@api-stub: lurek.audio.isLooping
-- Returns true if a source is set to loop.
do
    local path = "sounds/bgm.ogg"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.setLooping(src, true)
    print("isLooping = " .. tostring(lurek.audio.isLooping(src)))
end

--@api-stub: lurek.audio.playLooping
-- Starts playback with looping enabled in one call.
do
    local path = "sounds/wind.ogg"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.playLooping(src)
    print("playing+looping = " .. tostring(lurek.audio.isPlaying(src) and lurek.audio.isLooping(src)))
end

--@api-stub: lurek.audio.setPan
-- Sets stereo panning (-1 = left, 0 = center, 1 = right).
do
    local path = "sounds/ping.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setPan(src, -0.5)
    print("pan = " .. lurek.audio.getPan(src))
end

--@api-stub: lurek.audio.getPan
-- Returns the current stereo pan value.
do
    local path = "sounds/ring.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setPan(src, 0.7)
    local pan = lurek.audio.getPan(src)
    print("pan = " .. pan)
end

--@api-stub: lurek.audio.setMasterVolume
-- Sets the global master volume affecting all sources.
do
    lurek.audio.setMasterVolume(0.75)
    print("master volume = " .. lurek.audio.getMasterVolume())
end

--@api-stub: lurek.audio.getMasterVolume
-- Returns the current global master volume.
do
    lurek.audio.setMasterVolume(1.0)
    local mv = lurek.audio.getMasterVolume()
    print("master volume = " .. mv)
end

--@api-stub: lurek.audio.getActiveSourceCount
-- Returns the number of sources currently playing.
do
    local count = lurek.audio.getActiveSourceCount()
    print("active sources = " .. count)
end

--@api-stub: lurek.audio.getSourceCount
-- Returns the total number of allocated sources.
do
    local total = lurek.audio.getSourceCount()
    print("total sources = " .. total)
end

--@api-stub: lurek.audio.getSourceType
-- Returns the type of a source ("static" or "stream").
do
    local path = "sounds/fx.wav"
    local src = lurek.audio.newSource(path, "static")
    local stype = lurek.audio.getSourceType(src)
    print("source type = " .. stype)
end

--@api-stub: lurek.audio.clone
-- Creates an independent copy of an existing source.
do
    local path = "sounds/hit.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setVolume(src, 0.6)
    local copy = lurek.audio.clone(src)
    print("clone volume = " .. lurek.audio.getVolume(copy))
end

--@api-stub: lurek.audio.pauseAll
-- Pauses all currently playing sources.
do
    lurek.audio.pauseAll()
    print("all paused")
end

--@api-stub: lurek.audio.stopAll
-- Stops all sources and resets their positions.
do
    lurek.audio.stopAll()
    print("all stopped")
end

--@api-stub: lurek.audio.resumeAll
-- Resumes all paused sources.
do
    lurek.audio.resumeAll()
    print("all resumed")
end

--@api-stub: lurek.audio.release
-- Releases an audio source, freeing its resources.
do
    local path = "sounds/temp.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.release(src)
    print("source released")
end

--@api-stub: lurek.audio.newBus
-- Creates a named audio bus for grouping and routing sources.
do
    lurek.audio.newBus("sfx")
    print("bus created: sfx")
end

--@api-stub: lurek.audio.setSourceBus
-- Assigns a source to an audio bus for grouped mixing.
do
    local path = "sounds/sword.wav"
    local src = lurek.audio.newSource(path, "static")
    local bus = lurek.audio.newBus("effects")
    lurek.audio.setSourceBus(src, bus)
    local b = lurek.audio.getSourceBus(src)
    print("bus = " .. b:getName())
end

--@api-stub: lurek.audio.getSourceBus
-- Returns the bus object assigned to a source.
do
    local path = "sounds/coin.wav"
    local src = lurek.audio.newSource(path, "static")
    local bus = lurek.audio.newBus("ui")
    lurek.audio.setSourceBus(src, bus)
    local b = lurek.audio.getSourceBus(src)
    print("source bus = " .. b:getName())
end

--@api-stub: lurek.audio.getMaxSources
-- Returns the maximum number of simultaneous sources supported.
do
    local max = lurek.audio.getMaxSources()
    print("max sources = " .. max)
end

--@api-stub: lurek.audio.getDuration
-- Returns the total duration of a source in seconds.
do
    local path = "sounds/song.ogg"
    local src = lurek.audio.newSource(path, "stream")
    local dur = lurek.audio.getDuration(src) or 0
    print("duration = " .. dur .. "s")
end

--@api-stub: lurek.audio.tell
-- Returns the current playback position in seconds.
do
    local path = "sounds/track.ogg"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.play(src)
    local pos = lurek.audio.tell(src)
    print("position = " .. pos)
end

--@api-stub: lurek.audio.seek
-- Sets the playback position to a specific time in seconds.
do
    local path = "sounds/long.ogg"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.play(src)
    lurek.audio.seek(src, 5.0)
    print("seeked to 5s, pos = " .. lurek.audio.tell(src))
end

--@api-stub: lurek.audio.setLowpass
-- Applies a lowpass filter to a source at the given cutoff frequency.
do
    local path = "sounds/engine.ogg"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.setLowpass(src, 800)
    print("lowpass = " .. lurek.audio.getLowpass(src) .. " Hz")
end

--@api-stub: lurek.audio.setHighpass
-- Applies a highpass filter to a source at the given cutoff frequency.
do
    local path = "sounds/radio.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setHighpass(src, 2000)
    print("highpass = " .. lurek.audio.getHighpass(src) .. " Hz")
end

--@api-stub: lurek.audio.getLowpass
-- Returns the current lowpass cutoff frequency of a source.
do
    local path = "sounds/bass.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setLowpass(src, 500)
    local lp = lurek.audio.getLowpass(src)
    print("lowpass = " .. lp)
end

--@api-stub: lurek.audio.getHighpass
-- Returns the current highpass cutoff frequency of a source.
do
    local path = "sounds/treble.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setHighpass(src, 3000)
    local hp = lurek.audio.getHighpass(src)
    print("highpass = " .. hp)
end

--@api-stub: lurek.audio.clearFilter
-- Removes all filters from a source.
do
    local path = "sounds/voice.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setLowpass(src, 1000)
    lurek.audio.clearFilter(src)
    print("filters cleared")
end

--@api-stub: lurek.audio.fadeIn
-- Sets a fade-in duration for the source's next play.
do
    local path = "sounds/intro.ogg"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.fadeIn(src, 2.0)
    print("fade in = " .. lurek.audio.getFadeIn(src) .. "s")
end

--@api-stub: lurek.audio.getFadeIn
-- Returns the fade-in duration set for a source.
do
    local path = "sounds/start.ogg"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.fadeIn(src, 1.5)
    local fi = lurek.audio.getFadeIn(src)
    print("fade in duration = " .. fi)
end

--@api-stub: lurek.audio.setListener2D
-- Sets the 2D listener position for spatial audio.
do
    lurek.audio.setListener2D(400, 300)
    local x, y = lurek.audio.getListener2D()
    print("listener 2D = " .. x .. ", " .. y)
end

--@api-stub: lurek.audio.getListener2D
-- Returns the current 2D listener position.
do
    lurek.audio.setListener2D(100, 200)
    local x, y = lurek.audio.getListener2D()
    print("listener at " .. x .. ", " .. y)
end

--@api-stub: lurek.audio.setListener
-- Sets the 3D listener position for spatial audio.
do
    lurek.audio.setListener(0, 0, 0)
    local x, y, z = lurek.audio.getListener()
    print("listener 3D = " .. x .. ", " .. y .. ", " .. z)
end

--@api-stub: lurek.audio.getListener
-- Returns the current 3D listener position.
do
    lurek.audio.setListener(10, 5, 0)
    local x, y, z = lurek.audio.getListener()
    print("listener = " .. x .. ", " .. y .. ", " .. z)
end

--@api-stub: lurek.audio.setPosition
-- Sets the 3D position of a source for spatial audio.
do
    local path = "sounds/bird.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setPosition(src, 50, 20, 0)
    local x, y, z = lurek.audio.getPosition(src)
    print("source pos = " .. x .. ", " .. y .. ", " .. z)
end

--@api-stub: lurek.audio.getPosition
-- Returns the 3D position of a source.
do
    local path = "sounds/car.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setPosition(src, 100, 0, 30)
    local x, y, z = lurek.audio.getPosition(src)
    print("pos = " .. x .. ", " .. y .. ", " .. z)
end

--@api-stub: lurek.audio.setVelocity
-- Sets the velocity of a source for Doppler effect calculations.
do
    local path = "sounds/siren.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setVelocity(src, 10, 0, 0)
    local vx, vy, vz = lurek.audio.getVelocity(src)
    print("velocity = " .. vx .. ", " .. vy .. ", " .. vz)
end

--@api-stub: lurek.audio.getVelocity
-- Returns the velocity of a source.
do
    local path = "sounds/plane.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setVelocity(src, 5, 3, 0)
    local vx, vy, vz = lurek.audio.getVelocity(src)
    print("vel = " .. vx .. ", " .. vy .. ", " .. vz)
end

--@api-stub: lurek.audio.setOrientation
-- Sets the orientation of a source using forward and up vectors.
do
    local path = "sounds/speaker.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setOrientation(src, 0, 0, -1, 0, 1, 0)
    print("orientation set: forward(0,0,-1) up(0,1,0)")
end

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
    local ok = pcall(function()
        lurek.audio.setMidiSoundFont(path)
    end)
    print("soundfont set = " .. tostring(ok and lurek.audio.hasMidiSoundFont()))
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
    local path = "tests/fixtures/sine_mono_44100.wav"
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
    print("bus created: master_sfx")
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
    local path_in = "tests/fixtures/sine_mono_44100.wav"
    local path_out = "output/waveform.png"
    lurek.audio.waveformToPng(path_in, path_out, 800, 200)
    print("waveform image saved")
end

--@api-stub: lurek.audio.spectrogramToPng
-- Renders a spectrogram visualization as a PNG image.
do
    local path_in = "tests/fixtures/sine_mono_44100.wav"
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

--- Audio Examples Part 3: LSource methods, LBus methods, LMidiPlayer methods


--@api-stub: LSource:stop
-- Stops playback using the method syntax.
do
    local path = "sounds/shot.wav"
    local src = lurek.audio.newSource(path, "static")
    src:play()
    src:stop()
    print("stopped = " .. tostring(src:isStopped()))
end

--@api-stub: LSource:pause
-- Pauses playback at the current position.
do
    local path = "sounds/music.ogg"
    local src = lurek.audio.newSource(path, "stream")
    src:play()
    src:pause()
    print("paused = " .. tostring(src:isPaused()))
end

--@api-stub: LSource:resume
-- Resumes playback from where it was paused.
do
    local path = "sounds/music.ogg"
    local src = lurek.audio.newSource(path, "stream")
    src:play()
    src:pause()
    src:resume()
    print("resumed = " .. tostring(src:isPlaying()))
end

--@api-stub: LSource:setVolume
-- Sets the volume of a source via method.
do
    local path = "sounds/ping.wav"
    local src = lurek.audio.newSource(path, "static")
    src:setVolume(0.4)
    print("volume = " .. src:getVolume())
end

--@api-stub: LSource:getVolume
-- Returns the current volume of a source.
do
    local path = "sounds/ding.wav"
    local src = lurek.audio.newSource(path, "static")
    src:setVolume(0.9)
    local v = src:getVolume()
    print("volume = " .. v)
end

--@api-stub: LSource:setPitch
-- Sets the pitch multiplier via method.
do
    local path = "sounds/tone.wav"
    local src = lurek.audio.newSource(path, "static")
    src:setPitch(1.5)
    print("pitch = " .. src:getPitch())
end

--@api-stub: LSource:getPitch
-- Returns the current pitch multiplier.
do
    local path = "sounds/beep.wav"
    local src = lurek.audio.newSource(path, "static")
    src:setPitch(0.7)
    local p = src:getPitch()
    print("pitch = " .. p)
end

--@api-stub: LSource:setLooping
-- Enables or disables looping on a source.
do
    local path = "sounds/ambient.ogg"
    local src = lurek.audio.newSource(path, "stream")
    src:setLooping(true)
    print("looping = " .. tostring(src:isLooping()))
end

--@api-stub: LSource:isLooping
-- Returns true if the source is set to loop.
do
    local path = "sounds/bgm.ogg"
    local src = lurek.audio.newSource(path, "stream")
    src:setLooping(true)
    print("isLooping = " .. tostring(src:isLooping()))
end

--@api-stub: LSource:isPlaying
-- Returns true if the source is currently playing.
do
    local path = "sounds/click.wav"
    local src = lurek.audio.newSource(path, "static")
    src:play()
    print("playing = " .. tostring(src:isPlaying()))
end

--@api-stub: LSource:isPaused
-- Returns true if the source is paused.
do
    local path = "sounds/step.wav"
    local src = lurek.audio.newSource(path, "static")
    src:play()
    src:pause()
    print("paused = " .. tostring(src:isPaused()))
end

--@api-stub: LSource:isStopped
-- Returns true if the source is stopped.
do
    local path = "sounds/pop.wav"
    local src = lurek.audio.newSource(path, "static")
    print("stopped = " .. tostring(src:isStopped()))
end

--@api-stub: LSource:setPan
-- Sets stereo panning on a source.
do
    local path = "sounds/ring.wav"
    local src = lurek.audio.newSource(path, "static")
    src:setPan(-0.8)
    print("pan = " .. src:getPan())
end

--@api-stub: LSource:getPan
-- Returns the current stereo pan value.
do
    local path = "sounds/ping.wav"
    local src = lurek.audio.newSource(path, "static")
    src:setPan(0.5)
    local pan = src:getPan()
    print("pan = " .. pan)
end

--@api-stub: LSource:clone
-- Creates an independent copy of the source.
do
    local path = "sounds/hit.wav"
    local src = lurek.audio.newSource(path, "static")
    src:setVolume(0.3)
    local copy = src:clone()
    print("clone volume = " .. copy:getVolume())
end

--@api-stub: LSource:getType
-- Returns the source type ("static" or "stream").
do
    local path = "sounds/song.ogg"
    local src = lurek.audio.newSource(path, "stream")
    print("type = " .. src:getType())
end

--@api-stub: LSource:getDuration
-- Returns the total duration of the source in seconds.
do
    local path = "sounds/track.ogg"
    local src = lurek.audio.newSource(path, "stream")
    local dur = src:getDuration()
    print("duration = " .. dur .. "s")
end

--@api-stub: LSource:tell
-- Returns the current playback position in seconds.
do
    local path = "sounds/long.ogg"
    local src = lurek.audio.newSource(path, "stream")
    src:play()
    local pos = src:tell()
    print("position = " .. pos)
end

--@api-stub: LSource:seek
-- Seeks to a specific position in seconds.
do
    local path = "sounds/long.ogg"
    local src = lurek.audio.newSource(path, "stream")
    src:play()
    src:seek(10.0)
    print("seeked to " .. src:tell())
end

--@api-stub: LSource:setLowpass
-- Applies a lowpass filter at a given cutoff frequency.
do
    local path = "sounds/engine.ogg"
    local src = lurek.audio.newSource(path, "stream")
    src:setLowpass(600)
    print("lowpass = " .. src:getLowpass())
end

--@api-stub: LSource:setHighpass
-- Applies a highpass filter at a given cutoff frequency.
do
    local path = "sounds/radio.wav"
    local src = lurek.audio.newSource(path, "static")
    src:setHighpass(1500)
    print("highpass = " .. src:getHighpass())
end

--@api-stub: LSource:getLowpass
-- Returns the current lowpass cutoff frequency.
do
    local path = "sounds/bass.wav"
    local src = lurek.audio.newSource(path, "static")
    src:setLowpass(400)
    local lp = src:getLowpass()
    print("lowpass = " .. lp)
end

--@api-stub: LSource:getHighpass
-- Returns the current highpass cutoff frequency.
do
    local path = "sounds/treble.wav"
    local src = lurek.audio.newSource(path, "static")
    src:setHighpass(4000)
    local hp = src:getHighpass()
    print("highpass = " .. hp)
end

--@api-stub: LSource:clearFilter
-- Removes all filters from the source.
do
    local path = "sounds/voice.wav"
    local src = lurek.audio.newSource(path, "static")
    src:setLowpass(800)
    src:clearFilter()
    print("filters cleared")
end

--@api-stub: LSource:fadeIn
-- Sets a fade-in duration for the next play.
do
    local path = "sounds/intro.ogg"
    local src = lurek.audio.newSource(path, "stream")
    src:fadeIn(2.5)
    print("fade in = " .. src:getFadeIn() .. "s")
end

--@api-stub: LSource:getFadeIn
-- Returns the configured fade-in duration.
do
    local path = "sounds/start.ogg"
    local src = lurek.audio.newSource(path, "stream")
    src:fadeIn(1.0)
    local fi = src:getFadeIn()
    print("fade in = " .. fi)
end

--@api-stub: LSource:type
-- Returns the type name of this object ("LSource").
do
    local path = "sounds/click.wav"
    local src = lurek.audio.newSource(path, "static")
    print("type = " .. src:type())
end

--@api-stub: LSource:typeOf
-- Checks whether this object matches a given type name.
do
    local path = "sounds/click.wav"
    local src = lurek.audio.newSource(path, "static")
    print("is LSource = " .. tostring(src:typeOf("LSource")))
end

--@api-stub: LBus:getName
-- Returns the name of an audio bus.
do
    local bus = lurek.audio.newBus("gameplay")
    print("bus name = " .. bus:getName())
end

--@api-stub: LBus:setVolume
-- Sets the volume multiplier for all sources on a bus.
do
    local bus = lurek.audio.newBus("sfx")
    bus:setVolume(0.6)
    print("bus volume = " .. bus:getVolume())
end

--@api-stub: LBus:getVolume
-- Returns the current volume multiplier of a bus.
do
    local bus = lurek.audio.newBus("music")
    bus:setVolume(0.8)
    local v = bus:getVolume()
    print("volume = " .. v)
end

--@api-stub: LBus:setPitch
-- Sets the pitch multiplier for all sources on a bus.
do
    local bus = lurek.audio.newBus("fx")
    bus:setPitch(1.2)
    print("bus pitch = " .. bus:getPitch())
end

--@api-stub: LBus:getPitch
-- Returns the current pitch multiplier of a bus.
do
    local bus = lurek.audio.newBus("ambient")
    bus:setPitch(0.9)
    local p = bus:getPitch()
    print("pitch = " .. p)
end

--@api-stub: LBus:pause
-- Pauses all sources routed through this bus.
do
    local bus = lurek.audio.newBus("dialog")
    bus:pause()
    print("bus paused = " .. tostring(bus:isPaused()))
end

--@api-stub: LBus:resume
-- Resumes all paused sources on this bus.
do
    local bus = lurek.audio.newBus("world")
    bus:pause()
    bus:resume()
    print("bus resumed = " .. tostring(not bus:isPaused()))
end

--@api-stub: LBus:isPaused
-- Returns true if the bus is paused.
do
    local bus = lurek.audio.newBus("ui")
    bus:pause()
    print("paused = " .. tostring(bus:isPaused()))
end

--@api-stub: LBus:type
-- Returns the type name of this object ("LBus").
do
    local bus = lurek.audio.newBus("test")
    print("type = " .. bus:type())
end

--@api-stub: LBus:typeOf
-- Checks whether this object matches a given type name.
do
    local bus = lurek.audio.newBus("check")
    print("is LBus = " .. tostring(bus:typeOf("LBus")))
end

--@api-stub: LBus:setDuckTarget
-- Configures ducking so this bus lowers another bus's volume when active.
do
    local music = lurek.audio.newBus("bg_music")
    local voice = lurek.audio.newBus("voice_over")
    voice:setDuckTarget("bg_music", 0.3)
    print("ducking bg_music to 0.3 when voice active")
end

--@api-stub: LBus:clearDuck
-- Removes the ducking configuration from a bus.
do
    local bus = lurek.audio.newBus("narrator")
    bus:setDuckTarget("bg_music", 0.2)
    bus:clearDuck()
    print("duck cleared")
end

--@api-stub: LBus:getPeak
-- Returns the peak amplitude level of this bus.
do
    local bus = lurek.audio.newBus("meter_bus")
    local peak = bus:getPeak()
    print("peak = " .. peak)
end

--@api-stub: LMidiPlayer:load
-- Loads a MIDI file from a path.
do
    local player = lurek.audio.newMidiPlayer()
    local path = "music/theme.mid"
    local ok = player:load(path)
    print("loaded = " .. tostring(ok))
end

--@api-stub: LMidiPlayer:loadData
-- Loads MIDI data from a raw byte string.
do
    local player = lurek.audio.newMidiPlayer()
    local data = "MThd..." -- raw MIDI bytes
    local ok = player:loadData(data)
    print("loaded data = " .. tostring(ok))
end

--@api-stub: LMidiPlayer:isLoaded
-- Returns true if a MIDI file is loaded.
do
    local player = lurek.audio.newMidiPlayer()
    print("loaded = " .. tostring(player:isLoaded()))
end

--@api-stub: LMidiPlayer:getFilePath
-- Returns the path of the loaded MIDI file.
do
    local path = "music/theme.mid"
    local player = lurek.audio.newMidiPlayer(path)
    print("file = " .. player:getFilePath())
end

--@api-stub: LMidiPlayer:setSoundFont
-- Sets the SoundFont file for this player.
do
    local player = lurek.audio.newMidiPlayer()
    local sf_path = "audio/gm.sf2"
    local ok = pcall(function()
        player:setSoundFont(sf_path)
    end)
    print("sf = " .. tostring(ok and player:getSoundFontPath()))
end

--@api-stub: LMidiPlayer:getSoundFontPath
-- Returns the path of the SoundFont in use.
do
    local player = lurek.audio.newMidiPlayer()
    local sf_path = "audio/gm.sf2"
    local ok = pcall(function()
        player:setSoundFont(sf_path)
    end)
    local p = ok and player:getSoundFontPath() or nil
    print("soundfont = " .. tostring(p))
end

--@api-stub: LMidiPlayer:useDefaultSoundFont
-- Reverts to the global default SoundFont.
do
    local player = lurek.audio.newMidiPlayer()
    player:useDefaultSoundFont()
    print("using default soundfont")
end

--@api-stub: LMidiPlayer:play
-- Starts MIDI playback.
do
    local path = "music/theme.mid"
    local player = lurek.audio.newMidiPlayer(path)
    player:play()
    print("midi playing = " .. tostring(player:isPlaying()))
end

--@api-stub: LMidiPlayer:pause
-- Pauses MIDI playback.
do
    local path = "music/theme.mid"
    local player = lurek.audio.newMidiPlayer(path)
    player:play()
    player:pause()
    print("midi paused = " .. tostring(player:isPaused()))
end

--- Audio Examples Part 4: LMidiPlayer (cont.), LSoundPool, LDecoder methods


--@api-stub: LMidiPlayer:stop
-- Stops MIDI playback.
do
    local path = "music/theme.mid"
    local player = lurek.audio.newMidiPlayer(path)
    player:play()
    player:stop()
    print("midi stopped")
end

--@api-stub: LMidiPlayer:isPlaying
-- Returns true if the MIDI player is currently playing.
do
    local path = "music/theme.mid"
    local player = lurek.audio.newMidiPlayer(path)
    player:play()
    print("playing = " .. tostring(player:isPlaying()))
end

--@api-stub: LMidiPlayer:isPaused
-- Returns true if the MIDI player is paused.
do
    local path = "music/theme.mid"
    local player = lurek.audio.newMidiPlayer(path)
    player:play()
    player:pause()
    print("paused = " .. tostring(player:isPaused()))
end

--@api-stub: LMidiPlayer:seek
-- Seeks to a position in seconds.
do
    local path = "music/theme.mid"
    local player = lurek.audio.newMidiPlayer(path)
    player:play()
    player:seek(5.0)
    print("seeked to " .. player:tell())
end

--@api-stub: LMidiPlayer:tell
-- Returns the current playback position in seconds.
do
    local path = "music/theme.mid"
    local player = lurek.audio.newMidiPlayer(path)
    player:play()
    local pos = player:tell()
    print("position = " .. pos)
end

--@api-stub: LMidiPlayer:getDuration
-- Returns the total duration of the loaded MIDI file.
do
    local path = "music/theme.mid"
    local player = lurek.audio.newMidiPlayer(path)
    local dur = player:getDuration()
    print("duration = " .. dur .. "s")
end

--@api-stub: LMidiPlayer:setLooping
-- Enables or disables looping on the MIDI player.
do
    local path = "music/theme.mid"
    local player = lurek.audio.newMidiPlayer(path)
    player:setLooping(true)
    print("looping = " .. tostring(player:isLooping()))
end

--@api-stub: LMidiPlayer:isLooping
-- Returns true if the MIDI player is set to loop.
do
    local path = "music/theme.mid"
    local player = lurek.audio.newMidiPlayer(path)
    player:setLooping(true)
    print("isLooping = " .. tostring(player:isLooping()))
end

--@api-stub: LMidiPlayer:setVolume
-- Sets the playback volume.
do
    local player = lurek.audio.newMidiPlayer()
    player:setVolume(0.7)
    print("volume = " .. player:getVolume())
end

--@api-stub: LMidiPlayer:getVolume
-- Returns the current playback volume.
do
    local player = lurek.audio.newMidiPlayer()
    player:setVolume(0.5)
    local v = player:getVolume()
    print("volume = " .. v)
end

--@api-stub: LMidiPlayer:setBus
-- Routes the MIDI player through an audio bus.
do
    local player = lurek.audio.newMidiPlayer()
    local bus = lurek.audio.newBus("midi_bus")
    player:setBus(bus)
    print("bus set")
end

--@api-stub: LMidiPlayer:getBus
-- Returns the bus this player is routed through.
do
    local player = lurek.audio.newMidiPlayer()
    local bus = lurek.audio.newBus("midi_out")
    player:setBus(bus)
    local b = player:getBus()
    print("bus = " .. b:getName())
end

--@api-stub: LMidiPlayer:setTempo
-- Sets the playback tempo in BPM.
do
    local player = lurek.audio.newMidiPlayer()
    player:setTempo(140)
    print("tempo = " .. player:getTempo())
end

--@api-stub: LMidiPlayer:getTempo
-- Returns the current playback tempo in BPM.
do
    local player = lurek.audio.newMidiPlayer()
    player:setTempo(120)
    local t = player:getTempo()
    print("tempo = " .. t)
end

--@api-stub: LMidiPlayer:getOriginalTempo
-- Returns the original tempo from the MIDI file.
do
    local path = "music/theme.mid"
    local player = lurek.audio.newMidiPlayer(path)
    local orig = player:getOriginalTempo()
    print("original tempo = " .. orig)
end

--@api-stub: LMidiPlayer:setTempoScale
-- Sets a tempo scale multiplier (1.0 = normal, 2.0 = double speed).
do
    local player = lurek.audio.newMidiPlayer()
    player:setTempoScale(1.5)
    print("tempo scale = " .. player:getTempoScale())
end

--@api-stub: LMidiPlayer:getTempoScale
-- Returns the current tempo scale multiplier.
do
    local player = lurek.audio.newMidiPlayer()
    player:setTempoScale(0.8)
    local s = player:getTempoScale()
    print("scale = " .. s)
end

--@api-stub: LMidiPlayer:getTicksPerBeat
-- Returns the MIDI file's ticks-per-beat (PPQN) value.
do
    local path = "music/theme.mid"
    local player = lurek.audio.newMidiPlayer(path)
    local tpb = player:getTicksPerBeat()
    print("ticks/beat = " .. tpb)
end

--@api-stub: LMidiPlayer:setChannelVolume
-- Sets the volume of a specific MIDI channel.
do
    local player = lurek.audio.newMidiPlayer()
    player:setChannelVolume(1, 0.8)
    print("ch1 volume = " .. player:getChannelVolume(1))
end

--@api-stub: LMidiPlayer:getChannelVolume
-- Returns the volume of a MIDI channel.
do
    local player = lurek.audio.newMidiPlayer()
    player:setChannelVolume(2, 0.6)
    local v = player:getChannelVolume(2)
    print("ch2 volume = " .. v)
end

--@api-stub: LMidiPlayer:setChannelMuted
-- Mutes or unmutes a MIDI channel.
do
    local player = lurek.audio.newMidiPlayer()
    player:setChannelMuted(10, true)
    print("ch10 muted = " .. tostring(player:isChannelMuted(10)))
end

--@api-stub: LMidiPlayer:isChannelMuted
-- Returns true if a channel is muted.
do
    local player = lurek.audio.newMidiPlayer()
    player:setChannelMuted(3, true)
    print("ch3 muted = " .. tostring(player:isChannelMuted(3)))
end

--@api-stub: LMidiPlayer:setChannelInstrument
-- Sets the instrument program for a MIDI channel.
do
    local player = lurek.audio.newMidiPlayer()
    player:setChannelInstrument(1, 25)
    print("ch1 instrument = " .. player:getChannelInstrument(1))
end

--@api-stub: LMidiPlayer:getChannelInstrument
-- Returns the instrument program of a MIDI channel.
do
    local player = lurek.audio.newMidiPlayer()
    player:setChannelInstrument(2, 48)
    local inst = player:getChannelInstrument(2)
    print("ch2 instrument = " .. inst)
end

--@api-stub: LMidiPlayer:getChannelCount
-- Returns the number of active MIDI channels.
do
    local path = "music/theme.mid"
    local player = lurek.audio.newMidiPlayer(path)
    local count = player:getChannelCount()
    print("channels = " .. count)
end

--@api-stub: LMidiPlayer:soloChannel
-- Solos a specific channel, muting all others.
do
    local player = lurek.audio.newMidiPlayer()
    player:soloChannel(1)
    print("ch1 soloed")
end

--@api-stub: LMidiPlayer:unsoloAll
-- Removes solo from all channels.
do
    local player = lurek.audio.newMidiPlayer()
    player:soloChannel(1)
    player:unsoloAll()
    print("unsolo all done")
end

--@api-stub: LMidiPlayer:getTrackCount
-- Returns the number of tracks in the MIDI file.
do
    local path = "music/theme.mid"
    local player = lurek.audio.newMidiPlayer(path)
    local count = player:getTrackCount()
    print("tracks = " .. count)
end

--@api-stub: LMidiPlayer:getTrackName
-- Returns the name of a track by index.
do
    local path = "music/theme.mid"
    local player = lurek.audio.newMidiPlayer(path)
    local name = player:getTrackName(1)
    print("track 1 = " .. name)
end

--@api-stub: LMidiPlayer:setTrackMuted
-- Mutes or unmutes a track by index.
do
    local path = "music/theme.mid"
    local player = lurek.audio.newMidiPlayer(path)
    player:setTrackMuted(1, true)
    print("track 1 muted = " .. tostring(player:isTrackMuted(1)))
end

--@api-stub: LMidiPlayer:isTrackMuted
-- Returns true if a track is muted.
do
    local path = "music/theme.mid"
    local player = lurek.audio.newMidiPlayer(path)
    player:setTrackMuted(2, true)
    print("track 2 muted = " .. tostring(player:isTrackMuted(2)))
end

--@api-stub: LMidiPlayer:getNoteCount
-- Returns the total number of note events in the loaded file.
do
    local path = "music/theme.mid"
    local player = lurek.audio.newMidiPlayer(path)
    local notes = player:getNoteCount()
    print("notes = " .. notes)
end

--@api-stub: LMidiPlayer:setOnNoteOn
-- Sets a callback for note-on events during playback.
do
    local player = lurek.audio.newMidiPlayer()
    player:setOnNoteOn(function(ch, note, vel)
        print("note on: ch=" .. ch .. " note=" .. note .. " vel=" .. vel)
    end)
    print("onNoteOn callback set")
end

--@api-stub: LMidiPlayer:setOnNoteOff
-- Sets a callback for note-off events during playback.
do
    local player = lurek.audio.newMidiPlayer()
    player:setOnNoteOff(function(ch, note)
        print("note off: ch=" .. ch .. " note=" .. note)
    end)
    print("onNoteOff callback set")
end

--@api-stub: LMidiPlayer:setOnEnd
-- Sets a callback invoked when playback finishes.
do
    local player = lurek.audio.newMidiPlayer()
    player:setOnEnd(function()
        print("midi playback ended")
    end)
    print("onEnd callback set")
end

--@api-stub: LMidiPlayer:getSampleRate
-- Returns the sample rate used for MIDI synthesis.
do
    local player = lurek.audio.newMidiPlayer()
    local rate = player:getSampleRate()
    print("sample rate = " .. rate)
end

--@api-stub: LMidiPlayer:setSampleRate
-- Sets the sample rate for MIDI synthesis.
do
    local player = lurek.audio.newMidiPlayer()
    player:setSampleRate(48000)
    print("sample rate = " .. player:getSampleRate())
end

--@api-stub: LMidiPlayer:getChannels
-- Returns the audio channel count for output (1=mono, 2=stereo).
do
    local player = lurek.audio.newMidiPlayer()
    local ch = player:getChannels()
    print("output channels = " .. ch)
end

--@api-stub: LMidiPlayer:setChannels
-- Sets the audio channel count for output.
do
    local player = lurek.audio.newMidiPlayer()
    player:setChannels(2)
    print("set stereo output")
end

--@api-stub: LMidiPlayer:type
-- Returns the type name of this object ("LMidiPlayer").
do
    local player = lurek.audio.newMidiPlayer()
    print("type = " .. player:type())
end

--@api-stub: LMidiPlayer:typeOf
-- Checks whether this object matches a given type name.
do
    local player = lurek.audio.newMidiPlayer()
    print("is LMidiPlayer = " .. tostring(player:typeOf("LMidiPlayer")))
end

--@api-stub: LSoundPool:play
-- Plays the next available voice from the pool.
do
    local path = "sounds/shot.wav"
    local pool = lurek.audio.newPool(path, 4)
    local id = pool:play()
    print("playing voice id = " .. id)
end

--@api-stub: LSoundPool:stopAll
-- Stops all voices in the pool.
do
    local path = "sounds/step.wav"
    local pool = lurek.audio.newPool(path, 4)
    pool:play()
    pool:stopAll()
    print("all voices stopped")
end

--@api-stub: LSoundPool:setVolume
-- Sets the volume for all voices in the pool.
do
    local path = "sounds/click.wav"
    local pool = lurek.audio.newPool(path, 4)
    pool:setVolume(0.5)
    print("pool volume = 0.5")
end

--@api-stub: LSoundPool:setBus
-- Routes all pool voices through a named bus.
do
    local path = "sounds/coin.wav"
    local pool = lurek.audio.newPool(path, 4)
    lurek.audio.newBus("pool_bus")
    pool:setBus("pool_bus")
    print("pool routed to pool_bus")
end

--@api-stub: LSoundPool:release
-- Releases all voices and frees resources.
do
    local path = "sounds/pop.wav"
    local pool = lurek.audio.newPool(path, 4)
    pool:release()
    print("pool released")
end

--@api-stub: LSoundPool:getVoiceCount
-- Returns the number of pre-allocated voices.
do
    local path = "sounds/beep.wav"
    local pool = lurek.audio.newPool(path, 8)
    print("voices = " .. pool:getVoiceCount())
end

--@api-stub: LSoundPool:type
-- Returns the type name of this object ("LSoundPool").
do
    local path = "sounds/ding.wav"
    local pool = lurek.audio.newPool(path, 2)
    print("type = " .. pool:type())
end

--@api-stub: LSoundPool:typeOf
-- Checks whether this object matches a given type name.
do
    local path = "sounds/ring.wav"
    local pool = lurek.audio.newPool(path, 2)
    print("is LSoundPool = " .. tostring(pool:typeOf("LSoundPool")))
end

--@api-stub: LDecoder:decode
-- Decodes the next chunk of audio data.
do
    local path = "sounds/song.ogg"
    local dec = lurek.audio.newDecoder(path, 4096)
    local chunk = dec:decode()
    print("decoded chunk = " .. tostring(chunk ~= nil))
end

--- Audio Examples Part 5: LDecoder methods, LSoundData methods


--@api-stub: LDecoder:getChannelCount
-- Returns the number of audio channels in the source file.
do
    local path = "tests/fixtures/sine_mono_44100.wav"
    local dec = lurek.audio.newDecoder(path)
    local ch = dec:getChannelCount()
    print("channels = " .. ch)
end

--@api-stub: LDecoder:getBitDepth
-- Returns the bit depth of the source audio file.
do
    local path = "tests/fixtures/sine_mono_44100.wav"
    local dec = lurek.audio.newDecoder(path)
    local bits = dec:getBitDepth()
    print("bit depth = " .. bits)
end

--@api-stub: LDecoder:getSampleRate
-- Returns the sample rate of the source file.
do
    local path = "tests/fixtures/sine_mono_44100.wav"
    local dec = lurek.audio.newDecoder(path)
    local rate = dec:getSampleRate()
    print("sample rate = " .. rate)
end

--@api-stub: LDecoder:getDuration
-- Returns the total duration of the source file.
do
    local path = "tests/fixtures/sine_mono_44100.wav"
    local dec = lurek.audio.newDecoder(path)
    local dur = dec:getDuration()
    print("duration = " .. dur .. "s")
end

--@api-stub: LDecoder:seek
-- Seeks to a specific position in the audio stream.
do
    local path = "tests/fixtures/sine_mono_44100.wav"
    local dec = lurek.audio.newDecoder(path)
    dec:seek(2.5)
    print("seeked to " .. dec:tell())
end

--@api-stub: LDecoder:rewind
-- Rewinds the decoder back to the beginning.
do
    local path = "tests/fixtures/sine_mono_44100.wav"
    local dec = lurek.audio.newDecoder(path)
    dec:seek(5.0)
    dec:rewind()
    print("rewound to " .. dec:tell())
end

--@api-stub: LDecoder:tell
-- Returns the current read position in seconds.
do
    local path = "tests/fixtures/sine_mono_44100.wav"
    local dec = lurek.audio.newDecoder(path)
    dec:seek(3.0)
    local pos = dec:tell()
    print("position = " .. pos)
end

--@api-stub: LDecoder:isSeekable
-- Returns whether this decoder supports seeking.
do
    local path = "tests/fixtures/sine_mono_44100.wav"
    local dec = lurek.audio.newDecoder(path)
    print("seekable = " .. tostring(dec:isSeekable()))
end

--@api-stub: LDecoder:release
-- Releases decoder resources.
do
    local path = "tests/fixtures/sine_mono_44100.wav"
    local dec = lurek.audio.newDecoder(path)
    dec:release()
    print("decoder released")
end

--@api-stub: LDecoder:type
-- Returns the type name ("LDecoder").
do
    local path = "tests/fixtures/sine_mono_44100.wav"
    local dec = lurek.audio.newDecoder(path)
    print("type = " .. dec:type())
end

--@api-stub: LDecoder:typeOf
-- Checks whether this object matches a given type name.
do
    local path = "tests/fixtures/sine_mono_44100.wav"
    local dec = lurek.audio.newDecoder(path)
    print("is LDecoder = " .. tostring(dec:typeOf("LDecoder")))
end

--@api-stub: LSoundData:getSampleCount
-- Returns the total number of samples in the buffer.
do
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    local count = sd:getSampleCount()
    print("samples = " .. count)
end

--@api-stub: LSoundData:getSampleRate
-- Returns the sample rate of the sound data.
do
    local sd = lurek.audio.newSoundData(22050, 22050, 1)
    local rate = sd:getSampleRate()
    print("sample rate = " .. rate)
end

--@api-stub: LSoundData:getChannelCount
-- Returns the number of audio channels.
do
    local sd = lurek.audio.newSoundData(44100, 44100, 2)
    local ch = sd:getChannelCount()
    print("channels = " .. ch)
end

--@api-stub: LSoundData:getDuration
-- Returns the approximate playback duration.
do
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    local dur = sd:getDuration()
    print("duration = " .. dur .. "s")
end

--@api-stub: LSoundData:getBitDepth
-- Returns the bit depth per sample.
do
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    local bits = sd:getBitDepth()
    print("bit depth = " .. bits)
end

--@api-stub: LSoundData:getSample
-- Returns the sample value at a zero-based index.
do
    local sd = lurek.audio.newSineWave(440, 0.1, 44100, 1.0)
    local val = sd:getSample(0)
    print("sample[0] = " .. val)
end

--@api-stub: LSoundData:drawWaveform
-- Draws the waveform into an image buffer.
do
    local sd = lurek.audio.newSineWave(440, 1.0, 44100, 0.8)
    local img = lurek.image.newImageData(400, 100)
    sd:drawWaveform(img, 0, 0, 400, 100, 0, 255, 0, 255)
    print("waveform drawn to image")
end

--@api-stub: LSoundData:setSample
-- Overwrites a sample value at a zero-based index.
do
    local sd = lurek.audio.newSoundData(100, 44100, 1)
    sd:setSample(0, 0.5)
    sd:setSample(50, -0.3)
    print("sample[0] = " .. sd:getSample(0) .. " sample[50] = " .. sd:getSample(50))
end

--@api-stub: LSoundData:type
-- Returns the type name ("LSoundData").
do
    local sd = lurek.audio.newSoundData(100, 44100, 1)
    print("type = " .. sd:type())
end

--@api-stub: LSoundData:typeOf
-- Checks whether this object matches a given type name.
do
    local sd = lurek.audio.newSoundData(100, 44100, 1)
    print("is LSoundData = " .. tostring(sd:typeOf("LSoundData")))
end

print("content/examples/audio.lua")
