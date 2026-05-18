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
    player:setSoundFont(sf_path)
    print("sf = " .. player:getSoundFontPath())
end

--@api-stub: LMidiPlayer:getSoundFontPath
-- Returns the path of the SoundFont in use.
do
    local player = lurek.audio.newMidiPlayer()
    local sf_path = "audio/gm.sf2"
    player:setSoundFont(sf_path)
    local p = player:getSoundFontPath()
    print("soundfont = " .. p)
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

print("audio_02.lua")
