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

print("audio_03.lua")
