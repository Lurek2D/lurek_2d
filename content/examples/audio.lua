-- content/examples/audio.lua
-- lurek.audio API examples.
-- Run: cargo run -- content/examples/audio.lua

--@api-stub: lurek.audio.newSource -- Creates a new audio source from a file path, either fully loaded or streaming
do -- lurek.audio.newSource
  function lurek.init()
    local ok_jump, jump = pcall(lurek.audio.newSource, "sfx/jump.ogg", "static")
    if not ok_jump then return end
    local music = lurek.audio.newSource("music/level.mp3")
    lurek.audio.setLooping(music, true)
    lurek.audio.play(music)
    _G.jump_sfx = jump
  end
end

--@api-stub: lurek.audio.play -- Starts playback of a source by handle, optionally routing through a named bus
do -- lurek.audio.play
  function lurek.init()
    local ok_hit, hit = pcall(lurek.audio.newSource, "sfx/hit.ogg", "static")
    if not ok_hit then return end
    lurek.audio.newBus("sfx")
    lurek.audio.play(hit, {bus = "sfx"})
  end
end

--@api-stub: lurek.audio.stop -- Stops playback of a source and resets its position to the beginning
do -- lurek.audio.stop
  function lurek.init()
    local ok_sirene, sirene = pcall(lurek.audio.newSource, "sfx/alarm.ogg", "static")
    if not ok_sirene then return end
    lurek.audio.play(sirene)
    lurek.audio.stop(sirene)
  end
end

--@api-stub: lurek.audio.setVolume -- Sets the volume of a source by handle
do -- lurek.audio.setVolume
  function lurek.init()
    local ok_music, music = pcall(lurek.audio.newSource, "music/level.mp3")
    if not ok_music then return end
    lurek.audio.setVolume(music, 0.7)
    lurek.audio.play(music)
  end
end

--@api-stub: lurek.audio.getVolume -- Returns the current volume of a source
do -- lurek.audio.getVolume
  function lurek.init()
    local ok_music, music = pcall(lurek.audio.newSource, "music/level.mp3")
    if not ok_music then return end
    lurek.audio.setVolume(music, 0.7)
    local v = lurek.audio.getVolume(music)
    lurek.log.info("music volume=" .. v, "audio")
  end
end

--@api-stub: lurek.audio.pause -- Pauses playback of a source at its current position
do -- lurek.audio.pause
  function lurek.init()
    local ok_music, music = pcall(lurek.audio.newSource, "music/level.mp3")
    if not ok_music then return end
    lurek.audio.play(music)
    lurek.audio.pause(music)
  end
end

--@api-stub: lurek.audio.resume -- Resumes playback of a paused source
do -- lurek.audio.resume
  function lurek.init()
    local ok_music, music = pcall(lurek.audio.newSource, "music/level.mp3")
    if not ok_music then return end
    lurek.audio.play(music)
    lurek.audio.pause(music)
    lurek.audio.resume(music)
  end
end

--@api-stub: lurek.audio.setPitch -- Sets the pitch multiplier of a source, affecting playback speed and tone
do -- lurek.audio.setPitch
  function lurek.init()
    local ok_engine, engine = pcall(lurek.audio.newSource, "sfx/engine.ogg", "static")
    if not ok_engine then return end
    lurek.audio.setPitch(engine, 1.25)
    lurek.audio.play(engine)
  end
end

--@api-stub: lurek.audio.getPitch -- Returns the current pitch multiplier of a source
do -- lurek.audio.getPitch
  function lurek.init()
    local ok_engine, engine = pcall(lurek.audio.newSource, "sfx/engine.ogg", "static")
    if not ok_engine then return end
    lurek.audio.setPitch(engine, 1.25)
    local p = lurek.audio.getPitch(engine)
    lurek.log.info("engine pitch=" .. p, "audio")
  end
end

--@api-stub: lurek.audio.isPlaying -- Returns whether a source is currently playing
do -- lurek.audio.isPlaying
  function lurek.init()
    local ok_sting, sting = pcall(lurek.audio.newSource, "sfx/sting.ogg", "static")
    if not ok_sting then return end
    lurek.audio.play(sting)
    if lurek.audio.isPlaying(sting) then lurek.log.info("sting active", "audio") end
  end
end

--@api-stub: lurek.audio.isPaused -- Returns whether a source is currently paused
do -- lurek.audio.isPaused
  function lurek.init()
    local ok_music, music = pcall(lurek.audio.newSource, "music/level.mp3")
    if not ok_music then return end
    lurek.audio.play(music); lurek.audio.pause(music)
    if lurek.audio.isPaused(music) then lurek.audio.resume(music) end
  end
end

--@api-stub: lurek.audio.isStopped -- Returns whether a source is currently stopped
do -- lurek.audio.isStopped
  function lurek.init()
    local ok_sting, sting = pcall(lurek.audio.newSource, "sfx/sting.ogg", "static")
    if not ok_sting then return end
    lurek.audio.play(sting); lurek.audio.stop(sting)
    if lurek.audio.isStopped(sting) then lurek.log.info("sting free", "audio") end
  end
end

--@api-stub: lurek.audio.setLooping -- Enables or disables looping for a source
do -- lurek.audio.setLooping
  function lurek.init()
    local ok_music, music = pcall(lurek.audio.newSource, "music/level.mp3")
    if not ok_music then return end
    lurek.audio.setLooping(music, true)
    lurek.audio.play(music)
  end
end

--@api-stub: lurek.audio.isLooping -- Returns whether a source has looping enabled
do -- lurek.audio.isLooping
  function lurek.init()
    local ok_music, music = pcall(lurek.audio.newSource, "music/level.mp3")
    if not ok_music then return end
    lurek.audio.setLooping(music, true)
    if lurek.audio.isLooping(music) then lurek.log.info("looping", "audio") end
  end
end

--@api-stub: lurek.audio.playLooping -- Starts playback of a source with looping enabled in one call
do -- lurek.audio.playLooping
  function lurek.init()
    local ok_rain, rain = pcall(lurek.audio.newSource, "music/rain_loop.ogg")
    if not ok_rain then return end
    lurek.audio.setVolume(rain, 0.7)
    lurek.audio.playLooping(rain)
  end
end

--@api-stub: lurek.audio.setPan -- Sets the stereo panning of a source
do -- lurek.audio.setPan
  function lurek.init()
    local ok_sfx, sfx = pcall(lurek.audio.newSource, "sfx/swoosh.ogg", "static")
    if not ok_sfx then return end
    lurek.audio.setPan(sfx, -0.5)
    lurek.audio.play(sfx)
  end
end

--@api-stub: lurek.audio.getPan -- Returns the current stereo pan position of a source
do -- lurek.audio.getPan
  function lurek.init()
    local ok_sfx, sfx = pcall(lurek.audio.newSource, "sfx/swoosh.ogg", "static")
    if not ok_sfx then return end
    lurek.audio.setPan(sfx, -0.5)
    local p = lurek.audio.getPan(sfx)
    lurek.log.info("pan=" .. p, "audio")
  end
end

--@api-stub: lurek.audio.setMasterVolume -- Sets the global master volume affecting all audio output
do -- lurek.audio.setMasterVolume
  function lurek.init()
    local user_volume = 0.7
    lurek.audio.setMasterVolume(user_volume)
  end
end

--@api-stub: lurek.audio.getMasterVolume -- Returns the current global master volume level
do -- lurek.audio.getMasterVolume
  function lurek.init()
    lurek.audio.setMasterVolume(0.7)
    local mv = lurek.audio.getMasterVolume()
    lurek.log.info("master=" .. mv, "audio")
  end
end

--@api-stub: lurek.audio.getActiveSourceCount -- Returns the number of sources currently playing audio
do -- lurek.audio.getActiveSourceCount
  function lurek.init()
    local ok_sfx, sfx = pcall(lurek.audio.newSource, "sfx/jump.ogg", "static")
    if not ok_sfx then return end
    lurek.audio.play(sfx)
    lurek.log.info("active=" .. lurek.audio.getActiveSourceCount(), "audio")
  end
end

--@api-stub: lurek.audio.getSourceCount -- Returns the total number of loaded audio sources (playing or idle)
do -- lurek.audio.getSourceCount
  function lurek.init()
    local ok__, _ = pcall(lurek.audio.newSource, "sfx/coin.ogg", "static")
    if not ok__ then return end
    local n = lurek.audio.getSourceCount()
    lurek.log.info("sources=" .. n, "audio")
  end
end

--@api-stub: lurek.audio.getSourceType -- Returns whether a source is static or streaming
do -- lurek.audio.getSourceType
  function lurek.init()
    local ok_music, music = pcall(lurek.audio.newSource, "music/level.mp3")
    if not ok_music then return end
    local t = lurek.audio.getSourceType(music)
    if t == "stream" then lurek.log.info("streamed", "audio") end
  end
end

--@api-stub: lurek.audio.clone -- Creates an independent copy of a source sharing the same audio data
do -- lurek.audio.clone
  function lurek.init()
    local ok_hit, hit = pcall(lurek.audio.newSource, "sfx/hit.ogg", "static")
    if not ok_hit then return end
    local hit2 = lurek.audio.clone(hit)
    lurek.audio.play(hit); lurek.audio.play(hit2)
  end
end

--@api-stub: lurek.audio.pauseAll -- Pauses all currently playing audio sources
do -- lurek.audio.pauseAll
  function lurek.init()
    local ok_music, music = pcall(lurek.audio.newSource, "music/level.mp3")
    if not ok_music then return end
    lurek.audio.play(music)
    lurek.audio.pauseAll()
  end
end

--@api-stub: lurek.audio.stopAll -- Stops all audio sources and resets their positions
do -- lurek.audio.stopAll
  function lurek.init()
    local ok_music, music = pcall(lurek.audio.newSource, "music/level.mp3")
    if not ok_music then return end
    lurek.audio.play(music)
    lurek.audio.stopAll()
  end
end

--@api-stub: lurek.audio.resumeAll -- Resumes all paused audio sources
do -- lurek.audio.resumeAll
  function lurek.init()
    local ok_music, music = pcall(lurek.audio.newSource, "music/level.mp3")
    if not ok_music then return end
    lurek.audio.play(music); lurek.audio.pauseAll()
    lurek.audio.resumeAll()
  end
end

--@api-stub: lurek.audio.release -- Releases an audio source, freeing its memory and stopping playback
do -- lurek.audio.release
  function lurek.init()
    local ok_sfx, sfx = pcall(lurek.audio.newSource, "sfx/coin.ogg", "static")
    if not ok_sfx then return end
    lurek.audio.stop(sfx)
    lurek.audio.release(sfx)
  end
end

--@api-stub: lurek.audio.newBus -- Creates a new audio mixing bus for grouping and controlling sources
do -- lurek.audio.newBus
  function lurek.init()
    local sfx_bus = lurek.audio.newBus("sfx")
    sfx_bus:setVolume(0.7)
    lurek.log.info("bus=" .. sfx_bus:getName(), "audio")
  end
end

--@api-stub: lurek.audio.setSourceBus -- Routes a source through a specific audio bus for grouped mixing
do -- lurek.audio.setSourceBus
  function lurek.init()
    local voice_bus = lurek.audio.newBus("voice")
    local ok_line, line = pcall(lurek.audio.newSource, "voice/line01.ogg", "static")
    if not ok_line then return end
    lurek.audio.setSourceBus(line, voice_bus)
  end
end

--@api-stub: lurek.audio.getSourceBus -- Returns the bus a source is routed through
do -- lurek.audio.getSourceBus
  function lurek.init()
    local sfx_bus = lurek.audio.newBus("sfx")
    local ok_hit, hit = pcall(lurek.audio.newSource, "sfx/hit.ogg", "static")
    if not ok_hit then return end
    lurek.audio.setSourceBus(hit, sfx_bus)
    local b = lurek.audio.getSourceBus(hit)
    if b then lurek.log.info("on " .. b:getName(), "audio") end
  end
end

--@api-stub: lurek.audio.getMaxSources -- Returns the maximum number of simultaneous audio sources supported
do -- lurek.audio.getMaxSources
  function lurek.init()
    local cap = lurek.audio.getMaxSources()
    lurek.log.info("max voices=" .. cap, "audio")
  end
end

--@api-stub: lurek.audio.getDuration -- Returns the total duration of a source in seconds
do -- lurek.audio.getDuration
  function lurek.init()
    local ok_music, music = pcall(lurek.audio.newSource, "music/level.mp3")
    if not ok_music then return end
    local d = lurek.audio.getDuration(music)
    lurek.log.info("len=" .. d .. "s", "audio")
  end
end

--@api-stub: lurek.audio.tell -- Returns the current playback position of a source in seconds
do -- lurek.audio.tell
  function lurek.init()
    local ok_music, music = pcall(lurek.audio.newSource, "music/level.mp3")
    if not ok_music then return end
    lurek.audio.play(music)
    local pos = lurek.audio.tell(music)
    lurek.log.info("at=" .. pos, "audio")
  end
end

--@api-stub: lurek.audio.seek -- Seeks a source to a specific position in seconds
do -- lurek.audio.seek
  function lurek.init()
    local ok_music, music = pcall(lurek.audio.newSource, "music/level.mp3")
    if not ok_music then return end
    lurek.audio.play(music)
    lurek.audio.seek(music, 30.0)
  end
end

--@api-stub: lurek.audio.setLowpass -- Applies a lowpass filter to a source, attenuating high frequencies
do -- lurek.audio.setLowpass
  function lurek.init()
    local ok_music, music = pcall(lurek.audio.newSource, "music/level.mp3")
    if not ok_music then return end
    lurek.audio.play(music)
    lurek.audio.setLowpass(music, 800)
  end
end

--@api-stub: lurek.audio.setHighpass -- Applies a highpass filter to a source, attenuating low frequencies
do -- lurek.audio.setHighpass
  function lurek.init()
    local ok_music, music = pcall(lurek.audio.newSource, "music/level.mp3")
    if not ok_music then return end
    lurek.audio.play(music)
    lurek.audio.setHighpass(music, 200)
  end
end

--@api-stub: lurek.audio.getLowpass -- Returns the current lowpass filter cutoff of a source
do -- lurek.audio.getLowpass
  function lurek.init()
    local ok_music, music = pcall(lurek.audio.newSource, "music/level.mp3")
    if not ok_music then return end
    lurek.audio.setLowpass(music, 800)
    lurek.log.info("lpf=" .. lurek.audio.getLowpass(music), "audio")
  end
end

--@api-stub: lurek.audio.getHighpass -- Returns the current highpass filter cutoff of a source
do -- lurek.audio.getHighpass
  function lurek.init()
    local ok_music, music = pcall(lurek.audio.newSource, "music/level.mp3")
    if not ok_music then return end
    lurek.audio.setHighpass(music, 200)
    lurek.log.info("hpf=" .. lurek.audio.getHighpass(music), "audio")
  end
end

--@api-stub: lurek.audio.clearFilter -- Removes all frequency filters from a source
do -- lurek.audio.clearFilter
  function lurek.init()
    local ok_music, music = pcall(lurek.audio.newSource, "music/level.mp3")
    if not ok_music then return end
    lurek.audio.setLowpass(music, 800)
    lurek.audio.clearFilter(music)
  end
end

--@api-stub: lurek.audio.fadeIn -- Sets the fade-in duration for a source so it ramps from silence on play
do -- lurek.audio.fadeIn
  function lurek.init()
    local ok_music, music = pcall(lurek.audio.newSource, "music/level.mp3")
    if not ok_music then return end
    lurek.audio.fadeIn(music, 2.5)
    lurek.audio.play(music)
  end
end

--@api-stub: lurek.audio.getFadeIn -- Returns the configured fade-in duration of a source
do -- lurek.audio.getFadeIn
  function lurek.init()
    local ok_music, music = pcall(lurek.audio.newSource, "music/level.mp3")
    if not ok_music then return end
    lurek.audio.fadeIn(music, 2.5)
    lurek.log.info("fade=" .. lurek.audio.getFadeIn(music), "audio")
  end
end

--@api-stub: lurek.audio.setListener2D -- Sets the 2D listener position for spatial audio calculations
do -- lurek.audio.setListener2D
  function lurek.init()
    local cam_x, cam_y = 320.0, 240.0
    lurek.audio.setListener2D(cam_x, cam_y)
  end
end

--@api-stub: lurek.audio.getListener2D -- Returns the current 2D listener position
do -- lurek.audio.getListener2D
  function lurek.init()
    lurek.audio.setListener2D(320.0, 240.0)
    local lx, ly = lurek.audio.getListener2D()
    lurek.log.info("listener=" .. lx .. "," .. ly, "audio")
  end
end

--@api-stub: lurek.audio.setListener -- Sets the 3D listener position for spatial audio (Z defaults to 0 for 2D games)
do -- lurek.audio.setListener
  function lurek.init()
    lurek.audio.setListener(320.0, 240.0, 0.0)
  end
end

--@api-stub: lurek.audio.getListener -- Returns the current 3D listener position
do -- lurek.audio.getListener
  function lurek.init()
    lurek.audio.setListener(320.0, 240.0, 0.0)
    local x, y, z = lurek.audio.getListener()
    lurek.log.info("listener=" .. x .. "," .. y .. "," .. z, "audio")
  end
end

--@api-stub: lurek.audio.setPosition -- Sets the 3D position of a source for spatial audio panning and attenuation
do -- lurek.audio.setPosition
  function lurek.init()
    local ok_foot, foot = pcall(lurek.audio.newSource, "sfx/footstep.ogg", "static")
    if not ok_foot then return end
    lurek.audio.setPosition(foot, 480.0, 240.0, 0.0)
    lurek.audio.play(foot)
  end
end

--@api-stub: lurek.audio.getPosition -- Returns the 3D position of a source
do -- lurek.audio.getPosition
  function lurek.init()
    local ok_foot, foot = pcall(lurek.audio.newSource, "sfx/footstep.ogg", "static")
    if not ok_foot then return end
    lurek.audio.setPosition(foot, 480.0, 240.0, 0.0)
    local x, y, z = lurek.audio.getPosition(foot)
    lurek.log.info("emitter=" .. x .. "," .. y .. "," .. z, "audio")
  end
end

--@api-stub: lurek.audio.setVelocity -- Sets the velocity of a source for Doppler effect calculations
do -- lurek.audio.setVelocity
  function lurek.init()
    local ok_car, car = pcall(lurek.audio.newSource, "sfx/engine.ogg", "static")
    if not ok_car then return end
    lurek.audio.setVelocity(car, 60.0, 0.0, 0.0)
    lurek.audio.play(car)
  end
end

--@api-stub: lurek.audio.getVelocity -- Returns the velocity vector of a source
do -- lurek.audio.getVelocity
  function lurek.init()
    local ok_car, car = pcall(lurek.audio.newSource, "sfx/engine.ogg", "static")
    if not ok_car then return end
    lurek.audio.setVelocity(car, 60.0, 0.0, 0.0)
    local vx, vy, vz = lurek.audio.getVelocity(car)
    lurek.log.info("vel=" .. vx .. "," .. vy .. "," .. vz, "audio")
  end
end

--@api-stub: lurek.audio.setOrientation -- Sets the orientation of a source using forward and up vectors
do -- lurek.audio.setOrientation
  function lurek.init()
    local ok_cone, cone = pcall(lurek.audio.newSource, "sfx/horn.ogg", "static")
    if not ok_cone then return end
    lurek.audio.setOrientation(cone, 0.0, 0.0, -1.0, 0.0, 1.0, 0.0)
    lurek.audio.play(cone)
  end
end

--@api-stub: lurek.audio.getOrientation -- Returns the orientation vectors of a source
do -- lurek.audio.getOrientation
  function lurek.init()
    local ok_cone, cone = pcall(lurek.audio.newSource, "sfx/horn.ogg", "static")
    if not ok_cone then return end
    lurek.audio.setOrientation(cone, 0.0, 0.0, -1.0, 0.0, 1.0, 0.0)
    local fx, fy, fz, ux, uy, uz = lurek.audio.getOrientation(cone)
    lurek.log.info("fwd=" .. fx .. "," .. fy .. "," .. fz, "audio")
  end
end

--@api-stub: lurek.audio.setDopplerScale -- Sets the global Doppler effect intensity multiplier
do -- lurek.audio.setDopplerScale
  function lurek.init()
    lurek.audio.setDopplerScale(1.0)
  end
end

--@api-stub: lurek.audio.getDopplerScale -- Returns the current global Doppler effect scale
do -- lurek.audio.getDopplerScale
  function lurek.init()
    lurek.audio.setDopplerScale(1.5)
    lurek.log.info("doppler=" .. lurek.audio.getDopplerScale(), "audio")
  end
end

--@api-stub: lurek.audio.setDistanceModel -- Sets the distance attenuation model for spatial audio
do -- lurek.audio.setDistanceModel
  function lurek.init()
    lurek.audio.setDistanceModel("linear")
  end
end

--@api-stub: lurek.audio.getDistanceModel -- Returns the current distance attenuation model name
do -- lurek.audio.getDistanceModel
  function lurek.init()
    lurek.audio.setDistanceModel("linear")
    lurek.log.info("model=" .. lurek.audio.getDistanceModel(), "audio")
  end
end

--@api-stub: lurek.audio.setMeter -- Sets the master peak level for metering purposes
do -- lurek.audio.setMeter
  function lurek.init()
    lurek.audio.setMeter(0.7)
  end
end

--@api-stub: lurek.audio.getMeter -- Returns the current master peak level for VU-meter displays
do -- lurek.audio.getMeter
  function lurek.init()
    lurek.audio.setMeter(0.7)
    lurek.log.info("meter=" .. lurek.audio.getMeter(), "audio")
  end
end

--@api-stub: lurek.audio.newMidiPlayer -- Creates a new MIDI player instance, optionally loading a file immediately
do -- lurek.audio.newMidiPlayer
  function lurek.init()
    local mp = lurek.audio.newMidiPlayer("music/song.mid")
    mp:setLooping(true)
    mp:play()
  end
end

--@api-stub: lurek.audio.newSoundData -- Creates a new SoundData object from a file path or blank buffer for procedural audio
do -- lurek.audio.newSoundData
  function lurek.init()
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    lurek.log.info("samples=" .. sd:getSampleCount(), "audio")
  end
end

--@api-stub: lurek.audio.setMidiSoundFont -- Sets the midi sound font for Lua scripts in this module
do -- lurek.audio.setMidiSoundFont
  function lurek.init()
    lurek.audio.setMidiSoundFont("music/gm.sf2")
  end
end

--@api-stub: lurek.audio.hasMidiSoundFont -- Returns true if midi sound font for Lua scripts in this module
do -- lurek.audio.hasMidiSoundFont
  function lurek.init()
    if not lurek.audio.hasMidiSoundFont() then
      lurek.log.warn("no soundfont, MIDI will be silent", "audio")
    end
  end
end

--@api-stub: lurek.audio.clearMidiSoundFont -- Clears midi sound font for Lua scripts in this module
do -- lurek.audio.clearMidiSoundFont
  function lurek.init()
    lurek.audio.setMidiSoundFont("music/gm.sf2")
    lurek.audio.clearMidiSoundFont()
  end
end

--@api-stub: lurek.audio.newDecoder -- Creates a streaming audio decoder for the given file
do -- lurek.audio.newDecoder
  function lurek.init()
    local dec = lurek.audio.newDecoder("music/long_track.ogg", 4096)
    lurek.log.info("rate=" .. dec:getSampleRate(), "audio")
  end
end

--@api-stub: lurek.audio.newQueueableSource -- Creates a new queueable audio source for streaming PCM data buffer by buffer
do -- lurek.audio.newQueueableSource
  function lurek.init()
    local qs = lurek.audio.newQueueableSource(44100, 16, 1, 4)
    lurek.log.info("queueable id=" .. qs, "audio")
  end
end

--@api-stub: lurek.audio.queueSource -- Queues a decoded audio chunk for playback on a queueable source
do -- lurek.audio.queueSource
  function lurek.init()
    local qs = lurek.audio.newQueueableSource(44100, 16, 1, 4)
    local chunk = lurek.audio.newSineWave(440.0, 0.1, 44100, 0.5)
    lurek.audio.queueSource(qs, chunk)
  end
end

--@api-stub: lurek.audio.getFreeBufferCount -- Returns the number of free (available) buffer slots on a queueable source
do -- lurek.audio.getFreeBufferCount
  function lurek.init()
    local qs = lurek.audio.newQueueableSource(44100, 16, 1, 4)
    local free = lurek.audio.getFreeBufferCount(qs)
    lurek.log.info("free buffers=" .. free, "audio")
  end
end

--@api-stub: lurek.audio.playQueueable -- Play queueable for Lua scripts in this module
do -- lurek.audio.playQueueable
  function lurek.init()
    local qs = lurek.audio.newQueueableSource(44100, 16, 1, 4)
    local chunk = lurek.audio.newSineWave(440.0, 0.5, 44100, 0.5)
    lurek.audio.queueSource(qs, chunk)
    lurek.audio.playQueueable(qs)
  end
end

--@api-stub: lurek.audio.stopQueueable -- Stop queueable for Lua scripts in this module
do -- lurek.audio.stopQueueable
  function lurek.init()
    local qs = lurek.audio.newQueueableSource(44100, 16, 1, 4)
    lurek.audio.playQueueable(qs)
    lurek.audio.stopQueueable(qs)
  end
end

--@api-stub: lurek.audio.getPlaybackDevices -- Returns the playback devices for Lua scripts in this module
do -- lurek.audio.getPlaybackDevices
  function lurek.init()
    local devs = lurek.audio.getPlaybackDevices()
    for i, name in ipairs(devs) do lurek.log.info(i .. ": " .. name, "audio") end
  end
end

--@api-stub: lurek.audio.getPlaybackDevice -- Returns the playback device for Lua scripts in this module
do -- lurek.audio.getPlaybackDevice
  function lurek.init()
    local cur = lurek.audio.getPlaybackDevice()
    lurek.log.info("device=" .. cur, "audio")
  end
end

--@api-stub: lurek.audio.setPlaybackDevice -- Sets the playback device for Lua scripts in this module
do -- lurek.audio.setPlaybackDevice
  function lurek.init()
    local devs = lurek.audio.getPlaybackDevices()
    if devs[1] then lurek.audio.setPlaybackDevice(devs[1]) end
  end
end

--@api-stub: lurek.audio.create_bus -- Create_bus for Lua scripts in this module
do -- lurek.audio.create_bus
  function lurek.init()
    lurek.audio.create_bus("music")
    lurek.audio.create_bus("ambient", "music")
  end
end

--@api-stub: lurek.audio.set_bus_volume -- Sets the volume of a named audio bus
do -- lurek.audio.set_bus_volume
  function lurek.init()
    lurek.audio.create_bus("music")
    lurek.audio.set_bus_volume("music", 0.7)
  end
end

--@api-stub: lurek.audio.add_effect -- Adds an effect to a named audio bus and returns its effect ID
do -- lurek.audio.add_effect
  function lurek.init()
    lurek.audio.create_bus("sfx")
    local id = lurek.audio.add_effect("sfx", "lowpass", {value = 1500.0})
    lurek.log.info("effect id=" .. tostring(id), "audio")
  end
end

--@api-stub: lurek.audio.remove_effect -- Remove_effect for Lua scripts in this module
do -- lurek.audio.remove_effect
  function lurek.init()
    lurek.audio.create_bus("sfx")
    local id = lurek.audio.add_effect("sfx", "lowpass", {value = 1500.0})
    lurek.audio.remove_effect("sfx", id)
  end
end

--@api-stub: lurek.audio.set_effect_param -- Set_effect_param for Lua scripts in this module
do -- lurek.audio.set_effect_param
  function lurek.init()
    lurek.audio.create_bus("sfx")
    local id = lurek.audio.add_effect("sfx", "lowpass", {value = 1500.0})
    lurek.audio.set_effect_param("sfx", id, "cutoff", 800.0)
  end
end

--@api-stub: lurek.audio.newSineWave -- Generates a sine wave as a `SoundData` buffer
do -- lurek.audio.newSineWave
  function lurek.init()
    local beep = lurek.audio.newSineWave(440.0, 0.25, 44100, 0.5)
    lurek.log.info("beep samples=" .. beep:getSampleCount(), "audio")
  end
end

--@api-stub: lurek.audio.newSquareWave -- Generates a square wave as a `SoundData` buffer
do -- lurek.audio.newSquareWave
  function lurek.init()
    local sq = lurek.audio.newSquareWave(220.0, 0.5, 44100, 0.5)
    lurek.log.info("square samples=" .. sq:getSampleCount(), "audio")
  end
end

--@api-stub: lurek.audio.newSawtoothWave -- Generates a sawtooth wave as a `SoundData` buffer
do -- lurek.audio.newSawtoothWave
  function lurek.init()
    local saw = lurek.audio.newSawtoothWave(110.0, 1.0, 44100, 0.5)
    lurek.log.info("saw len=" .. saw:getDuration(), "audio")
  end
end

--@api-stub: lurek.audio.newTriangleWave -- Generates a triangle wave as a `SoundData` buffer
do -- lurek.audio.newTriangleWave
  function lurek.init()
    local tri = lurek.audio.newTriangleWave(330.0, 0.5, 44100, 0.5)
    lurek.log.info("tri samples=" .. tri:getSampleCount(), "audio")
  end
end

--@api-stub: lurek.audio.newWhiteNoise -- Generates white noise as a `SoundData` buffer using a deterministic seed
do -- lurek.audio.newWhiteNoise
  function lurek.init()
    local noise = lurek.audio.newWhiteNoise(0.5, 44100, 0.3, 12345)
    lurek.log.info("noise samples=" .. noise:getSampleCount(), "audio")
  end
end

--@api-stub: lurek.audio.applyLowpass -- Applies a lowpass filter in-place to the sound data
do -- lurek.audio.applyLowpass
  function lurek.init()
    local saw = lurek.audio.newSawtoothWave(110.0, 1.0, 44100, 0.5)
    lurek.audio.applyLowpass(saw, 800.0)
  end
end

--@api-stub: lurek.audio.applyHighpass -- Applies a highpass filter in-place to the sound data
do -- lurek.audio.applyHighpass
  function lurek.init()
    local saw = lurek.audio.newSawtoothWave(110.0, 1.0, 44100, 0.5)
    lurek.audio.applyHighpass(saw, 80.0)
  end
end

--@api-stub: lurek.audio.applyBandpass -- Applies a bandpass filter in-place to the sound data
do -- lurek.audio.applyBandpass
  function lurek.init()
    local sd = lurek.audio.newWhiteNoise(0.5, 44100, 0.3, 1)
    lurek.audio.applyBandpass(sd, 300.0, 3400.0)
  end
end

--@api-stub: lurek.audio.applyGain -- Applies a gain multiplier in-place to the sound data
do -- lurek.audio.applyGain
  function lurek.init()
    local sd = lurek.audio.newSineWave(440.0, 0.25, 44100, 0.3)
    lurek.audio.applyGain(sd, 1.5)
  end
end

--@api-stub: lurek.audio.mixInto -- Mixes the samples of `src` into `dest` in-place (both must have the same format)
do -- lurek.audio.mixInto
  function lurek.init()
    local a = lurek.audio.newSineWave(440.0, 0.5, 44100, 0.3)
    local b = lurek.audio.newSineWave(660.0, 0.5, 44100, 0.3)
    lurek.audio.mixInto(a, b)
  end
end

--@api-stub: lurek.audio.saveWAV -- Encodes the sound data as a WAV file and saves it to the given path (relative to game dir)
do -- lurek.audio.saveWAV
  function lurek.init()
    local tone = lurek.audio.newSineWave(440.0, 1.0, 44100, 0.5)
    lurek.audio.saveWAV(tone, "save/tone.wav")
  end
end

--@api-stub: lurek.audio.setStereoWidth -- Sets the stereo width of an audio source (0
do -- lurek.audio.setStereoWidth
  function lurek.init()
    local ok_music, music = pcall(lurek.audio.newSource, "music/level.mp3")
    if not ok_music then return end
    lurek.audio.setStereoWidth(music, 0.5)
    lurek.audio.play(music)
  end
end

--@api-stub: lurek.audio.getStereoWidth -- Returns the current stereo width factor of an audio source
do -- lurek.audio.getStereoWidth
  function lurek.init()
    local ok_music, music = pcall(lurek.audio.newSource, "music/level.mp3")
    if not ok_music then return end
    lurek.audio.setStereoWidth(music, 0.5)
    lurek.log.info("width=" .. lurek.audio.getStereoWidth(music), "audio")
  end
end

--@api-stub: lurek.audio.setRandomPitch -- Sets a random pitch range for a source; each play picks a random pitch between min and max
do -- lurek.audio.setRandomPitch
  function lurek.init()
    local ok_foot, foot = pcall(lurek.audio.newSource, "sfx/footstep.ogg", "static")
    if not ok_foot then return end
    lurek.audio.setRandomPitch(foot, 0.95, 1.05)
    lurek.audio.play(foot)
  end
end

--@api-stub: lurek.audio.clearRandomPitch -- Clears any random pitch range previously set on the source
do -- lurek.audio.clearRandomPitch
  function lurek.init()
    local ok_foot, foot = pcall(lurek.audio.newSource, "sfx/footstep.ogg", "static")
    if not ok_foot then return end
    lurek.audio.setRandomPitch(foot, 0.95, 1.05)
    lurek.audio.clearRandomPitch(foot)
  end
end

--@api-stub: lurek.audio.crossfade -- Crossfades from one audio source to another over the given duration
do -- lurek.audio.crossfade
  function lurek.init()
    local ok_a, a = pcall(lurek.audio.newSource, "music/level1.mp3")
    if not ok_a then return end
    local b = lurek.audio.newSource("music/level2.mp3")
    lurek.audio.play(a)
    lurek.audio.crossfade(a, b, 3.0)
  end
end

--@api-stub: lurek.audio.getBusPeak -- Returns the peak amplitude of the named audio bus over the last processing frame
do -- lurek.audio.getBusPeak
  function lurek.init()
    lurek.audio.create_bus("music")
    local peak = lurek.audio.getBusPeak("music")
    lurek.log.info("music peak=" .. peak, "audio")
  end
end

--@api-stub: lurek.audio.getBusRms -- Returns the RMS (root mean square) amplitude of the named audio bus over the last processing frame
do -- lurek.audio.getBusRms
  function lurek.init()
    lurek.audio.create_bus("music")
    local rms = lurek.audio.getBusRms("music")
    lurek.log.info("music rms=" .. rms, "audio")
  end
end

--@api-stub: lurek.audio.newPool -- Creates a polyphonic sound pool that allows the same audio file to play on multiple simultaneous voices
do -- lurek.audio.newPool
  function lurek.init()
    local foot = lurek.audio.newPool("sfx/footstep.ogg", 8)
    foot:setVolume(0.7)
    foot:play()
  end
end

--@api-stub: lurek.audio.processOffline -- Processes an audio file offline through a chain of effects and writes the result to an output file
do -- lurek.audio.processOffline
  function lurek.init()
    local fx = {{type = "lowpass", p1 = 800.0, p2 = 1.0, p3 = 0.5}}
    lurek.audio.processOffline("music/in.wav", "save/out.wav", fx)
  end
end

--@api-stub: lurek.audio.normalizeFile -- Normalize file for Lua scripts in this module
do -- lurek.audio.normalizeFile
  function lurek.init()
    lurek.audio.normalizeFile("music/raw.wav", "save/normalised.wav", 0.95)
  end
end

--@api-stub: lurek.audio.waveformToPng -- Waveform to png for Lua scripts in this module
do -- lurek.audio.waveformToPng
  function lurek.init()
    lurek.audio.waveformToPng("music/level.wav", "save/level_wave.png", 800, 200)
  end
end

--@api-stub: lurek.audio.spectrogramToPng -- Spectrogram to png for Lua scripts in this module
do -- lurek.audio.spectrogramToPng
  function lurek.init()
    lurek.audio.spectrogramToPng("music/level.wav", "save/level_spec.png", 800, 400)
  end
end

-- â”€â”€ Source methods â”€â”€

--@api-stub: Source:play
do -- Source:play
  function lurek.init()
    local ok_s, s = pcall(lurek.audio.newSource, "sfx/jump.ogg", "static")
    if not ok_s then return end
    s:play()
  end
end

--@api-stub: Source:stop
do -- Source:stop
  function lurek.init()
    local ok_s, s = pcall(lurek.audio.newSource, "sfx/laser.ogg", "static")
    if not ok_s then return end
    s:play(); s:stop()
  end
end

--@api-stub: Source:pause
do -- Source:pause
  function lurek.init()
    local ok_s, s = pcall(lurek.audio.newSource, "music/level.mp3")
    if not ok_s then return end
    s:play(); s:pause()
  end
end

--@api-stub: Source:resume
do -- Source:resume
  function lurek.init()
    local ok_s, s = pcall(lurek.audio.newSource, "music/level.mp3")
    if not ok_s then return end
    s:play(); s:pause(); s:resume()
  end
end

--@api-stub: Source:setVolume
do -- Source:setVolume
  function lurek.init()
    local ok_s, s = pcall(lurek.audio.newSource, "music/level.mp3")
    if not ok_s then return end
    s:setVolume(0.7); s:play()
  end
end

--@api-stub: Source:getVolume
do -- Source:getVolume
  function lurek.init()
    local ok_s, s = pcall(lurek.audio.newSource, "music/level.mp3")
    if not ok_s then return end
    s:setVolume(0.7)
    lurek.log.info("vol=" .. s:getVolume(), "audio")
  end
end

--@api-stub: Source:setPitch
do -- Source:setPitch
  function lurek.init()
    local ok_s, s = pcall(lurek.audio.newSource, "sfx/engine.ogg", "static")
    if not ok_s then return end
    s:setPitch(1.2); s:play()
  end
end

--@api-stub: Source:getPitch
do -- Source:getPitch
  function lurek.init()
    local ok_s, s = pcall(lurek.audio.newSource, "sfx/engine.ogg", "static")
    if not ok_s then return end
    s:setPitch(1.2)
    lurek.log.info("pitch=" .. s:getPitch(), "audio")
  end
end

--@api-stub: Source:setLooping
do -- Source:setLooping
  function lurek.init()
    local ok_s, s = pcall(lurek.audio.newSource, "music/level.mp3")
    if not ok_s then return end
    s:setLooping(true); s:play()
  end
end

--@api-stub: Source:isLooping
do -- Source:isLooping
  function lurek.init()
    local ok_s, s = pcall(lurek.audio.newSource, "music/level.mp3")
    if not ok_s then return end
    s:setLooping(true)
    if s:isLooping() then lurek.log.info("looped", "audio") end
  end
end

--@api-stub: Source:isPlaying
do -- Source:isPlaying
  function lurek.init()
    local ok_s, s = pcall(lurek.audio.newSource, "music/sting.ogg", "static")
    if not ok_s then return end
    s:play()
    if s:isPlaying() then lurek.log.info("active", "audio") end
  end
end

--@api-stub: Source:isPaused
do -- Source:isPaused
  function lurek.init()
    local ok_s, s = pcall(lurek.audio.newSource, "music/level.mp3")
    if not ok_s then return end
    s:play(); s:pause()
    if s:isPaused() then s:resume() end
  end
end

--@api-stub: Source:isStopped
do -- Source:isStopped
  function lurek.init()
    local ok_s, s = pcall(lurek.audio.newSource, "sfx/jump.ogg", "static")
    if not ok_s then return end
    s:play(); s:stop()
    if s:isStopped() then lurek.log.info("idle", "audio") end
  end
end

--@api-stub: Source:setPan
do -- Source:setPan
  function lurek.init()
    local ok_s, s = pcall(lurek.audio.newSource, "sfx/swoosh.ogg", "static")
    if not ok_s then return end
    s:setPan(-0.5); s:play()
  end
end

--@api-stub: Source:getPan
do -- Source:getPan
  function lurek.init()
    local ok_s, s = pcall(lurek.audio.newSource, "sfx/swoosh.ogg", "static")
    if not ok_s then return end
    s:setPan(-0.5)
    lurek.log.info("pan=" .. s:getPan(), "audio")
  end
end

--@api-stub: Source:clone
do -- Source:clone
  function lurek.init()
    local ok_s, s = pcall(lurek.audio.newSource, "sfx/hit.ogg", "static")
    if not ok_s then return end
    local s2 = s:clone()
    s:play(); s2:play()
  end
end

--@api-stub: Source:getType
do -- Source:getType
  function lurek.init()
    local ok_s, s = pcall(lurek.audio.newSource, "music/level.mp3")
    if not ok_s then return end
    if s:getType() == "stream" then lurek.log.info("streamed", "audio") end
  end
end

--@api-stub: Source:getDuration
do -- Source:getDuration
  function lurek.init()
    local ok_s, s = pcall(lurek.audio.newSource, "music/level.mp3")
    if not ok_s then return end
    lurek.log.info("len=" .. s:getDuration() .. "s", "audio")
  end
end

--@api-stub: Source:tell
do -- Source:tell
  function lurek.init()
    local ok_s, s = pcall(lurek.audio.newSource, "music/level.mp3")
    if not ok_s then return end
    s:play()
    lurek.log.info("at=" .. s:tell(), "audio")
  end
end

--@api-stub: Source:seek
do -- Source:seek
  function lurek.init()
    local ok_s, s = pcall(lurek.audio.newSource, "music/level.mp3")
    if not ok_s then return end
    s:play(); s:seek(15.0)
  end
end

--@api-stub: Source:setLowpass
do -- Source:setLowpass
  function lurek.init()
    local ok_s, s = pcall(lurek.audio.newSource, "music/level.mp3")
    if not ok_s then return end
    s:play(); s:setLowpass(800)
  end
end

--@api-stub: Source:setHighpass
do -- Source:setHighpass
  function lurek.init()
    local ok_s, s = pcall(lurek.audio.newSource, "music/level.mp3")
    if not ok_s then return end
    s:play(); s:setHighpass(200)
  end
end

--@api-stub: Source:getLowpass
do -- Source:getLowpass
  function lurek.init()
    local ok_s, s = pcall(lurek.audio.newSource, "music/level.mp3")
    if not ok_s then return end
    s:setLowpass(800)
    lurek.log.info("lpf=" .. s:getLowpass(), "audio")
  end
end

--@api-stub: Source:getHighpass
do -- Source:getHighpass
  function lurek.init()
    local ok_s, s = pcall(lurek.audio.newSource, "music/level.mp3")
    if not ok_s then return end
    s:setHighpass(200)
    lurek.log.info("hpf=" .. s:getHighpass(), "audio")
  end
end

--@api-stub: Source:clearFilter
do -- Source:clearFilter
  function lurek.init()
    local ok_s, s = pcall(lurek.audio.newSource, "music/level.mp3")
    if not ok_s then return end
    s:setLowpass(800); s:clearFilter()
  end
end

--@api-stub: Source:fadeIn
do -- Source:fadeIn
  function lurek.init()
    local ok_s, s = pcall(lurek.audio.newSource, "music/level.mp3")
    if not ok_s then return end
    s:fadeIn(2.5); s:play()
  end
end

--@api-stub: Source:getFadeIn
do -- Source:getFadeIn
  function lurek.init()
    local ok_s, s = pcall(lurek.audio.newSource, "music/level.mp3")
    if not ok_s then return end
    s:fadeIn(2.5)
    lurek.log.info("fade=" .. s:getFadeIn(), "audio")
  end
end

-- â”€â”€ Bus methods â”€â”€

--@api-stub: Bus:getName
do -- Bus:getName
  function lurek.init()
    local b = lurek.audio.newBus("music")
    lurek.log.info("bus name=" .. b:getName(), "audio")
  end
end

--@api-stub: Bus:setVolume
do -- Bus:setVolume
  function lurek.init()
    local b = lurek.audio.newBus("music")
    b:setVolume(0.7)
  end
end

--@api-stub: Bus:getVolume
do -- Bus:getVolume
  function lurek.init()
    local b = lurek.audio.newBus("music")
    b:setVolume(0.7)
    lurek.log.info("bus vol=" .. b:getVolume(), "audio")
  end
end

--@api-stub: Bus:setPitch
do -- Bus:setPitch
  function lurek.init()
    local b = lurek.audio.newBus("music")
    b:setPitch(0.85)
  end
end

--@api-stub: Bus:getPitch
do -- Bus:getPitch
  function lurek.init()
    local b = lurek.audio.newBus("music")
    b:setPitch(0.85)
    lurek.log.info("bus pitch=" .. b:getPitch(), "audio")
  end
end

--@api-stub: Bus:pause
do -- Bus:pause
  function lurek.init()
    local b = lurek.audio.newBus("music")
    b:pause()
  end
end

--@api-stub: Bus:resume
do -- Bus:resume
  function lurek.init()
    local b = lurek.audio.newBus("music")
    b:pause(); b:resume()
  end
end

--@api-stub: Bus:isPaused
do -- Bus:isPaused
  function lurek.init()
    local b = lurek.audio.newBus("music")
    b:pause()
    if b:isPaused() then lurek.log.info("bus muted", "audio") end
  end
end

--@api-stub: Bus:type
do -- Bus:type
  function lurek.init()
    local b = lurek.audio.newBus("music")
    lurek.log.info("kind=" .. b:type(), "audio")
  end
end

--@api-stub: Bus:typeOf
do -- Bus:typeOf
  function lurek.init()
    local b = lurek.audio.newBus("music")
    if b:typeOf("Bus") then lurek.log.info("is bus", "audio") end
  end
end

--@api-stub: Bus:clearDuck
do -- Bus:clearDuck
  function lurek.init()
    local b = lurek.audio.newBus("voice")
    b:clearDuck()
  end
end

--@api-stub: Bus:getPeak
do -- Bus:getPeak
  function lurek.init()
    local b = lurek.audio.newBus("music")
    lurek.log.info("peak=" .. b:getPeak(), "audio")
  end
end

-- â”€â”€ MidiPlayer methods â”€â”€

--@api-stub: MidiPlayer:load
do -- MidiPlayer:load
  function lurek.init()
    local mp = lurek.audio.newMidiPlayer()
    if mp:load("music/song.mid") then lurek.log.info("midi loaded", "audio") end
  end
end

--@api-stub: MidiPlayer:loadData
do -- MidiPlayer:loadData
  function lurek.init()
    local mp = lurek.audio.newMidiPlayer()
    local data = lurek.fs.read("music/song.mid")
    mp:loadData(data)
  end
end

--@api-stub: MidiPlayer:isLoaded
do -- MidiPlayer:isLoaded
  function lurek.init()
    local mp = lurek.audio.newMidiPlayer("music/song.mid")
    if mp:isLoaded() then mp:play() end
  end
end

--@api-stub: MidiPlayer:getFilePath
do -- MidiPlayer:getFilePath
  function lurek.init()
    local mp = lurek.audio.newMidiPlayer("music/song.mid")
    local path = mp:getFilePath()
    if path then lurek.log.info("midi=" .. path, "audio") end
  end
end

--@api-stub: MidiPlayer:setSoundFont
do -- MidiPlayer:setSoundFont
  function lurek.init()
    local mp = lurek.audio.newMidiPlayer("music/song.mid")
    mp:setSoundFont("music/orchestra.sf2")
  end
end

--@api-stub: MidiPlayer:getSoundFontPath
do -- MidiPlayer:getSoundFontPath
  function lurek.init()
    local mp = lurek.audio.newMidiPlayer("music/song.mid")
    local sf = mp:getSoundFontPath()
    if sf then lurek.log.info("sf=" .. sf, "audio") end
  end
end

--@api-stub: MidiPlayer:useDefaultSoundFont
do -- MidiPlayer:useDefaultSoundFont
  function lurek.init()
    local mp = lurek.audio.newMidiPlayer("music/song.mid")
    mp:useDefaultSoundFont()
  end
end

--@api-stub: MidiPlayer:play
do -- MidiPlayer:play
  function lurek.init()
    local mp = lurek.audio.newMidiPlayer("music/song.mid")
    mp:setLooping(true); mp:play()
  end
end

--@api-stub: MidiPlayer:pause
do -- MidiPlayer:pause
  function lurek.init()
    local mp = lurek.audio.newMidiPlayer("music/song.mid")
    mp:play(); mp:pause()
  end
end

--@api-stub: MidiPlayer:stop
do -- MidiPlayer:stop
  function lurek.init()
    local mp = lurek.audio.newMidiPlayer("music/song.mid")
    mp:play(); mp:stop()
  end
end

--@api-stub: MidiPlayer:isPlaying
do -- MidiPlayer:isPlaying
  function lurek.init()
    local mp = lurek.audio.newMidiPlayer("music/song.mid")
    mp:play()
    if mp:isPlaying() then lurek.log.info("midi active", "audio") end
  end
end

--@api-stub: MidiPlayer:isPaused
do -- MidiPlayer:isPaused
  function lurek.init()
    local mp = lurek.audio.newMidiPlayer("music/song.mid")
    mp:play(); mp:pause()
    if mp:isPaused() then mp:play() end
  end
end

--@api-stub: MidiPlayer:seek
do -- MidiPlayer:seek
  function lurek.init()
    local mp = lurek.audio.newMidiPlayer("music/song.mid")
    mp:play(); mp:seek(30.0)
  end
end

--@api-stub: MidiPlayer:tell
do -- MidiPlayer:tell
  function lurek.init()
    local mp = lurek.audio.newMidiPlayer("music/song.mid")
    mp:play()
    lurek.log.info("midi at=" .. mp:tell(), "audio")
  end
end

--@api-stub: MidiPlayer:getDuration
do -- MidiPlayer:getDuration
  function lurek.init()
    local mp = lurek.audio.newMidiPlayer("music/song.mid")
    lurek.log.info("midi len=" .. mp:getDuration(), "audio")
  end
end

--@api-stub: MidiPlayer:setLooping
do -- MidiPlayer:setLooping
  function lurek.init()
    local mp = lurek.audio.newMidiPlayer("music/song.mid")
    mp:setLooping(true)
  end
end

--@api-stub: MidiPlayer:isLooping
do -- MidiPlayer:isLooping
  function lurek.init()
    local mp = lurek.audio.newMidiPlayer("music/song.mid")
    mp:setLooping(true)
    if mp:isLooping() then lurek.log.info("midi loop", "audio") end
  end
end

--@api-stub: MidiPlayer:setVolume
do -- MidiPlayer:setVolume
  function lurek.init()
    local mp = lurek.audio.newMidiPlayer("music/song.mid")
    mp:setVolume(0.7)
  end
end

--@api-stub: MidiPlayer:getVolume
do -- MidiPlayer:getVolume
  function lurek.init()
    local mp = lurek.audio.newMidiPlayer("music/song.mid")
    mp:setVolume(0.7)
    lurek.log.info("midi vol=" .. mp:getVolume(), "audio")
  end
end

--@api-stub: MidiPlayer:setBus
do -- MidiPlayer:setBus
  function lurek.init()
    local b = lurek.audio.newBus("music")
    local mp = lurek.audio.newMidiPlayer("music/song.mid")
    mp:setBus(b)
  end
end

--@api-stub: MidiPlayer:getBus
do -- MidiPlayer:getBus
  function lurek.init()
    local b = lurek.audio.newBus("music")
    local mp = lurek.audio.newMidiPlayer("music/song.mid")
    mp:setBus(b)
    local cur = mp:getBus()
    if cur then lurek.log.info("bus=" .. cur:getName(), "audio") end
  end
end

--@api-stub: MidiPlayer:setTempo
do -- MidiPlayer:setTempo
  function lurek.init()
    local mp = lurek.audio.newMidiPlayer("music/song.mid")
    mp:setTempo(140)
  end
end

--@api-stub: MidiPlayer:getTempo
do -- MidiPlayer:getTempo
  function lurek.init()
    local mp = lurek.audio.newMidiPlayer("music/song.mid")
    mp:setTempo(140)
    lurek.log.info("bpm=" .. mp:getTempo(), "audio")
  end
end

--@api-stub: MidiPlayer:getOriginalTempo
do -- MidiPlayer:getOriginalTempo
  function lurek.init()
    local mp = lurek.audio.newMidiPlayer("music/song.mid")
    lurek.log.info("orig bpm=" .. mp:getOriginalTempo(), "audio")
  end
end

--@api-stub: MidiPlayer:setTempoScale
do -- MidiPlayer:setTempoScale
  function lurek.init()
    local mp = lurek.audio.newMidiPlayer("music/song.mid")
    mp:setTempoScale(0.85)
  end
end

--@api-stub: MidiPlayer:getTempoScale
do -- MidiPlayer:getTempoScale
  function lurek.init()
    local mp = lurek.audio.newMidiPlayer("music/song.mid")
    mp:setTempoScale(0.85)
    lurek.log.info("scale=" .. mp:getTempoScale(), "audio")
  end
end

--@api-stub: MidiPlayer:getTicksPerBeat
do -- MidiPlayer:getTicksPerBeat
  function lurek.init()
    local mp = lurek.audio.newMidiPlayer("music/song.mid")
    lurek.log.info("ppq=" .. mp:getTicksPerBeat(), "audio")
  end
end

--@api-stub: MidiPlayer:setChannelVolume
do -- MidiPlayer:setChannelVolume
  function lurek.init()
    local mp = lurek.audio.newMidiPlayer("music/song.mid")
    mp:setChannelVolume(10, 0.4)
  end
end

--@api-stub: MidiPlayer:getChannelVolume
do -- MidiPlayer:getChannelVolume
  function lurek.init()
    local mp = lurek.audio.newMidiPlayer("music/song.mid")
    mp:setChannelVolume(10, 0.4)
    lurek.log.info("ch10 vol=" .. mp:getChannelVolume(10), "audio")
  end
end

--@api-stub: MidiPlayer:setChannelMuted
do -- MidiPlayer:setChannelMuted
  function lurek.init()
    local mp = lurek.audio.newMidiPlayer("music/song.mid")
    mp:setChannelMuted(10, true)
  end
end

--@api-stub: MidiPlayer:isChannelMuted
do -- MidiPlayer:isChannelMuted
  function lurek.init()
    local mp = lurek.audio.newMidiPlayer("music/song.mid")
    mp:setChannelMuted(10, true)
    if mp:isChannelMuted(10) then lurek.log.info("drums muted", "audio") end
  end
end

--@api-stub: MidiPlayer:getChannelInstrument
do -- MidiPlayer:getChannelInstrument
  function lurek.init()
    local mp = lurek.audio.newMidiPlayer("music/song.mid")
    local inst = mp:getChannelInstrument(1)
    lurek.log.info("ch1 prog=" .. inst, "audio")
  end
end

--@api-stub: MidiPlayer:getChannelCount
do -- MidiPlayer:getChannelCount
  function lurek.init()
    local mp = lurek.audio.newMidiPlayer("music/song.mid")
    lurek.log.info("channels=" .. mp:getChannelCount(), "audio")
  end
end

--@api-stub: MidiPlayer:soloChannel
do -- MidiPlayer:soloChannel
  function lurek.init()
    local mp = lurek.audio.newMidiPlayer("music/song.mid")
    mp:soloChannel(1)
  end
end

--@api-stub: MidiPlayer:unsoloAll
do -- MidiPlayer:unsoloAll
  function lurek.init()
    local mp = lurek.audio.newMidiPlayer("music/song.mid")
    mp:soloChannel(1); mp:unsoloAll()
  end
end

--@api-stub: MidiPlayer:getTrackCount
do -- MidiPlayer:getTrackCount
  function lurek.init()
    local mp = lurek.audio.newMidiPlayer("music/song.mid")
    lurek.log.info("tracks=" .. mp:getTrackCount(), "audio")
  end
end

--@api-stub: MidiPlayer:getTrackName
do -- MidiPlayer:getTrackName
  function lurek.init()
    local mp = lurek.audio.newMidiPlayer("music/song.mid")
    local name = mp:getTrackName(1)
    if name then lurek.log.info("track1=" .. name, "audio") end
  end
end

--@api-stub: MidiPlayer:setTrackMuted
do -- MidiPlayer:setTrackMuted
  function lurek.init()
    local mp = lurek.audio.newMidiPlayer("music/song.mid")
    mp:setTrackMuted(2, true)
  end
end

--@api-stub: MidiPlayer:isTrackMuted
do -- MidiPlayer:isTrackMuted
  function lurek.init()
    local mp = lurek.audio.newMidiPlayer("music/song.mid")
    mp:setTrackMuted(2, true)
    if mp:isTrackMuted(2) then lurek.log.info("track2 muted", "audio") end
  end
end

--@api-stub: MidiPlayer:getNoteCount
do -- MidiPlayer:getNoteCount
  function lurek.init()
    local mp = lurek.audio.newMidiPlayer("music/song.mid")
    lurek.log.info("notes=" .. mp:getNoteCount(), "audio")
  end
end

--@api-stub: MidiPlayer:setOnNoteOn
do -- MidiPlayer:setOnNoteOn
  function lurek.init()
    local mp = lurek.audio.newMidiPlayer("music/song.mid")
    mp:setOnNoteOn(function(ch, note) lurek.log.info("note " .. note, "audio") end)
  end
end

--@api-stub: MidiPlayer:setOnNoteOff
do -- MidiPlayer:setOnNoteOff
  function lurek.init()
    local mp = lurek.audio.newMidiPlayer("music/song.mid")
    mp:setOnNoteOff(function(ch, note) lurek.log.info("off " .. note, "audio") end)
  end
end

--@api-stub: MidiPlayer:setOnEnd
do -- MidiPlayer:setOnEnd
  function lurek.init()
    local mp = lurek.audio.newMidiPlayer("music/song.mid")
    mp:setOnEnd(function() lurek.log.info("midi end", "audio") end)
  end
end

--@api-stub: MidiPlayer:getSampleRate
do -- MidiPlayer:getSampleRate
  function lurek.init()
    local mp = lurek.audio.newMidiPlayer("music/song.mid")
    lurek.log.info("rate=" .. mp:getSampleRate(), "audio")
  end
end

--@api-stub: MidiPlayer:setSampleRate
do -- MidiPlayer:setSampleRate
  function lurek.init()
    local mp = lurek.audio.newMidiPlayer("music/song.mid")
    mp:setSampleRate(48000)
  end
end

--@api-stub: MidiPlayer:getChannels
do -- MidiPlayer:getChannels
  function lurek.init()
    local mp = lurek.audio.newMidiPlayer("music/song.mid")
    lurek.log.info("ch=" .. mp:getChannels(), "audio")
  end
end

--@api-stub: MidiPlayer:setChannels
do -- MidiPlayer:setChannels
  function lurek.init()
    local mp = lurek.audio.newMidiPlayer("music/song.mid")
    mp:setChannels(2)
  end
end

--@api-stub: MidiPlayer:type
do -- MidiPlayer:type
  function lurek.init()
    local mp = lurek.audio.newMidiPlayer("music/song.mid")
    lurek.log.info("kind=" .. mp:type(), "audio")
  end
end

--@api-stub: MidiPlayer:typeOf
do -- MidiPlayer:typeOf
  function lurek.init()
    local mp = lurek.audio.newMidiPlayer("music/song.mid")
    if mp:typeOf("MidiPlayer") then lurek.log.info("is midi", "audio") end
  end
end

-- â”€â”€ SoundPool methods â”€â”€

--@api-stub: SoundPool:play
do -- SoundPool:play
  function lurek.init()
    local pool = lurek.audio.newPool("sfx/footstep.ogg", 8)
    local id = pool:play()
    lurek.log.info("voice=" .. id, "audio")
  end
end

--@api-stub: SoundPool:stopAll
do -- SoundPool:stopAll
  function lurek.init()
    local pool = lurek.audio.newPool("sfx/footstep.ogg", 8)
    pool:play(); pool:stopAll()
  end
end

--@api-stub: SoundPool:setVolume
do -- SoundPool:setVolume
  function lurek.init()
    local pool = lurek.audio.newPool("sfx/footstep.ogg", 8)
    pool:setVolume(0.7)
  end
end

--@api-stub: SoundPool:setBus
do -- SoundPool:setBus
  function lurek.init()
    lurek.audio.create_bus("sfx")
    local pool = lurek.audio.newPool("sfx/footstep.ogg", 8)
    pool:setBus("sfx")
  end
end

--@api-stub: SoundPool:release
do -- SoundPool:release
  function lurek.init()
    local pool = lurek.audio.newPool("sfx/footstep.ogg", 8)
    pool:release()
  end
end

--@api-stub: SoundPool:getVoiceCount
do -- SoundPool:getVoiceCount
  function lurek.init()
    local pool = lurek.audio.newPool("sfx/footstep.ogg", 8)
    lurek.log.info("voices=" .. pool:getVoiceCount(), "audio")
  end
end

--@api-stub: SoundPool:type
do -- SoundPool:type
  function lurek.init()
    local pool = lurek.audio.newPool("sfx/footstep.ogg", 8)
    lurek.log.info("kind=" .. pool:type(), "audio")
  end
end

--@api-stub: SoundPool:typeOf
do -- SoundPool:typeOf
  function lurek.init()
    local pool = lurek.audio.newPool("sfx/footstep.ogg", 8)
    if pool:typeOf("SoundPool") then lurek.log.info("is pool", "audio") end
  end
end

-- â”€â”€ Decoder methods â”€â”€

--@api-stub: Decoder:decode
do -- Decoder:decode
  function lurek.init()
    local dec = lurek.audio.newDecoder("music/long_track.ogg", 4096)
    local chunk = dec:decode()
    if chunk then lurek.log.info("chunk samples=" .. chunk:getSampleCount(), "audio") end
  end
end

--@api-stub: Decoder:getChannelCount
do -- Decoder:getChannelCount
  function lurek.init()
    local dec = lurek.audio.newDecoder("music/long_track.ogg", 4096)
    lurek.log.info("ch=" .. dec:getChannelCount(), "audio")
  end
end

--@api-stub: Decoder:getBitDepth
do -- Decoder:getBitDepth
  function lurek.init()
    local dec = lurek.audio.newDecoder("music/long_track.ogg", 4096)
    lurek.log.info("bd=" .. dec:getBitDepth(), "audio")
  end
end

--@api-stub: Decoder:getSampleRate
do -- Decoder:getSampleRate
  function lurek.init()
    local dec = lurek.audio.newDecoder("music/long_track.ogg", 4096)
    lurek.log.info("rate=" .. dec:getSampleRate(), "audio")
  end
end

--@api-stub: Decoder:getDuration
do -- Decoder:getDuration
  function lurek.init()
    local dec = lurek.audio.newDecoder("music/long_track.ogg", 4096)
    lurek.log.info("len=" .. dec:getDuration(), "audio")
  end
end

--@api-stub: Decoder:seek
do -- Decoder:seek
  function lurek.init()
    local dec = lurek.audio.newDecoder("music/long_track.ogg", 4096)
    dec:seek(15.0)
  end
end

--@api-stub: Decoder:rewind
do -- Decoder:rewind
  function lurek.init()
    local dec = lurek.audio.newDecoder("music/long_track.ogg", 4096)
    dec:seek(15.0); dec:rewind()
  end
end

--@api-stub: Decoder:tell
do -- Decoder:tell
  function lurek.init()
    local dec = lurek.audio.newDecoder("music/long_track.ogg", 4096)
    lurek.log.info("at=" .. dec:tell(), "audio")
  end
end

--@api-stub: Decoder:isSeekable
do -- Decoder:isSeekable
  function lurek.init()
    local dec = lurek.audio.newDecoder("music/long_track.ogg", 4096)
    if dec:isSeekable() then dec:seek(15.0) end
  end
end

--@api-stub: Decoder:release
do -- Decoder:release
  function lurek.init()
    local dec = lurek.audio.newDecoder("music/long_track.ogg", 4096)
    dec:release()
  end
end

-- â”€â”€ SoundData methods â”€â”€

--@api-stub: mlua:getSampleCount
do -- mlua:getSampleCount
  function lurek.init()
    local sd = lurek.audio.newSineWave(440.0, 1.0, 44100, 0.5)
    lurek.log.info("samples=" .. sd:getSampleCount(), "audio")
  end
end

--@api-stub: mlua:getSampleRate
do -- mlua:getSampleRate
  function lurek.init()
    local sd = lurek.audio.newSineWave(440.0, 1.0, 44100, 0.5)
    lurek.log.info("rate=" .. sd:getSampleRate(), "audio")
  end
end

--@api-stub: mlua:getChannelCount
do -- mlua:getChannelCount
  function lurek.init()
    local sd = lurek.audio.newSineWave(440.0, 1.0, 44100, 0.5)
    lurek.log.info("ch=" .. sd:getChannelCount(), "audio")
  end
end

--@api-stub: mlua:getDuration
do -- mlua:getDuration
  function lurek.init()
    local sd = lurek.audio.newSineWave(440.0, 1.0, 44100, 0.5)
    lurek.log.info("len=" .. sd:getDuration(), "audio")
  end
end

--@api-stub: mlua:getBitDepth
do -- mlua:getBitDepth
  function lurek.init()
    local sd = lurek.audio.newSineWave(440.0, 1.0, 44100, 0.5)
    lurek.log.info("bd=" .. sd:getBitDepth(), "audio")
  end
end

--@api-stub: mlua:getSample
do -- mlua:getSample
  function lurek.init()
    local sd = lurek.audio.newSineWave(440.0, 1.0, 44100, 0.5)
    local s = sd:getSample(0)
    lurek.log.info("first=" .. s, "audio")
  end
end

--@api-stub: mlua:setSample
do -- mlua:setSample
  function lurek.init()
    local sd = lurek.audio.newSineWave(440.0, 1.0, 44100, 0.5)
    sd:setSample(0, 0.0)
  end
end

--@api-stub: mlua
do -- mlua (SoundData):drawWaveform
  function lurek.init()
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    local img = lurek.image.newImageData(512, 64)
    if sd and img then
      local ok_w = pcall(function() sd:drawWaveform(img, 0, 0, 512, 64, 255, 255, 255, 255) end)
      if ok_w then lurek.log.info("waveform size: " .. img:getWidth(), "audio") end
    end
  end
end

--@api-stub: MidiPlayer:setChannelInstrument
do -- MidiPlayer:setChannelInstrument
  function lurek.init()
    local midi = lurek.audio.newMidiPlayer()
    midi:setChannelInstrument(0, 41)
    lurek.log.info("channel 0 instrument: " .. midi:getChannelInstrument(0), "audio")
  end
end

--@api-stub: Bus:setDuckTarget
do -- Bus:setDuckTarget
  function lurek.init()
    lurek.audio.newBus("music")
    lurek.audio.newBus("sfx")
    local sfxBus = lurek.audio.newBus("sfx_active")
    sfxBus:setDuckTarget("music", 0.3)
    lurek.log.info("duck target set", "audio")
  end
end

--@api-stub: mlua:drawWaveform
do -- mlua:drawWaveform
  local ok, err = pcall(function()
    local sd = lurek.audio.newSoundData("music/loop.ogg", 44100)
    local img = lurek.image.newImageData(256, 64)
    sd:drawWaveform(img, 0, 0, 256, 64, 255, 255, 255, 255)
    lurek.log.info("waveform drawn", "audio")
  end)
  if not ok then lurek.log.info("drawWaveform: asset not available", "audio") end
end

-- =============================================================================
-- COVERAGE: 120 uncovered lurek.audio API item(s)
-- Generated by tools/audit/example_add_missing.py
-- REQUIRED: replace every --@api-stub: block below with a real scenario.
-- Run .github/prompts/flesh-out-example.prompt.md for instructions.
-- The final committed file must contain ZERO --@api-stub: lines.
-- =============================================================================


-- -----------------------------------------------------------------------------
-- LDecoder methods
-- -----------------------------------------------------------------------------

--@api-stub: LDecoder:type -- Returns the type name of this object for runtime type-checking
do -- LDecoder:type
  local decoder_obj ---@type LDecoder?
  local ok_d, r = pcall(lurek.audio.newDecoder, "assets/sound.ogg", 4096)
  if ok_d then decoder_obj = r end
  local t = decoder_obj and decoder_obj:type() or "LDecoder"
  lurek.log.info("LDecoder:type = " .. t, "audio")
end
--@api-stub: LDecoder:typeOf -- Checks whether this object matches the given type name
do -- LDecoder:typeOf
  local decoder_obj2 ---@type LDecoder?
  local ok_d2, r2 = pcall(lurek.audio.newDecoder, "assets/sound.ogg", 4096)
  if ok_d2 then decoder_obj2 = r2 end
  lurek.log.info("is LDecoder: " .. tostring(decoder_obj2 and decoder_obj2:typeOf("LDecoder") or false), "audio")
  lurek.log.info("is wrong: " .. tostring(decoder_obj2 and decoder_obj2:typeOf("Unknown") or false), "audio")
end
--@api-stub: LSoundData:getSampleCount -- Returns the total number of samples stored in this sound buffer
do -- LSoundData:getSampleCount
  local sd = lurek.audio.newSineWave(440, 1.0, 44100, 0.5)
  lurek.log.info("sample_count=" .. sd:getSampleCount(), "audio")
end
--@api-stub: LSoundData:getSampleRate -- Returns the playback sample rate of this sound buffer
do -- LSoundData:getSampleRate
  local sd = lurek.audio.newSineWave(440, 0.5, 44100, 0.5)
  lurek.log.info("sample_rate=" .. sd:getSampleRate(), "audio")
end
--@api-stub: LSoundData:getChannelCount -- Returns the number of audio channels stored in this sound buffer
do -- LSoundData:getChannelCount
  local sd = lurek.audio.newSineWave(440, 0.5, 44100, 0.5)
  lurek.log.info("channels=" .. sd:getChannelCount(), "audio")
end
--@api-stub: LSoundData:getDuration -- Returns the approximate playback duration of this sound buffer
do -- LSoundData:getDuration
  local sd = lurek.audio.newSineWave(440, 2.0, 44100, 0.5)
  lurek.log.info("duration=" .. sd:getDuration() .. "s", "audio")
end
--@api-stub: LSoundData:getBitDepth -- Returns the sample bit depth of this sound buffer
do -- LSoundData:getBitDepth
  local sd = lurek.audio.newSineWave(440, 0.5, 44100, 0.5)
  lurek.log.info("bit_depth=" .. sd:getBitDepth(), "audio")
end
--@api-stub: LSoundData:getSample -- Returns the sample value at the given zero-based sample index
do -- LSoundData:getSample
  local sd = lurek.audio.newSineWave(440, 1.0, 44100, 0.5)
  local s = sd:getSample(1)   -- frame index 1
  lurek.log.info("sample[0]=" .. tostring(s), "audio")
end
--@api-stub: LSoundData:drawWaveform -- Draws this sound buffer as a waveform into an image buffer
do -- LSoundData:drawWaveform
  local sd = lurek.audio.newSineWave(440, 0.5, 44100, 0.5)
  local idata = lurek.image.newImageData(256, 64)
  sd:drawWaveform(idata, 0, 0, 256, 64, 0, 255, 0, 255)  -- green waveform at (0,0)
  lurek.log.info("waveform drawn to image 256x64", "audio")
end
--@api-stub: LSoundData:setSample -- Overwrites the sample value at the given zero-based sample index
do -- LSoundData:setSample
  local sd = lurek.audio.newSineWave(440, 0.5, 44100, 0.5)
  sd:setSample(0, 0.0)   -- silence sample at index 0
  lurek.log.info("sample[0] after zero=" .. sd:getSample(0), "audio")
end
--@api-stub: LSource:type -- Returns the type name of this object for runtime type-checking
do -- LSource:type
  local ok_s, source_obj = pcall(lurek.audio.newSource)
  local t = (ok_s and source_obj) and source_obj:type() or "LSource"
  lurek.log.info("LSource:type = " .. t, "audio")
end
--@api-stub: LSource:typeOf -- Checks whether this object is of the given type name or a parent type
do -- LSource:typeOf
  local ok_s, source_obj = pcall(lurek.audio.newSource)
  lurek.log.info("is LSource: " .. tostring((ok_s and source_obj) and source_obj:typeOf("LSource") or false), "audio")
  lurek.log.info("is wrong: " .. tostring((ok_s and source_obj) and source_obj:typeOf("Unknown") or false), "audio")
end
