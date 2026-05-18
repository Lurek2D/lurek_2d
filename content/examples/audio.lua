-- content/examples/audio.lua
-- lurek.audio API examples.
-- Run: cargo run -- content/examples/audio.lua
--@api-stub: lurek.audio.newSource
-- Creates a new audio source from a file path, either fully loaded or streaming
do
  -- "static" is for short effects that are played often.
  -- "stream" is the default and is better for long music tracks.
  local ok_jump, jump_source = pcall(lurek.audio.newSource, "sfx/jump.ogg", "static")
  local ok_music, music_source = pcall(lurek.audio.newSource, "music/level.mp3", "stream")

  if ok_jump and ok_music then
    jump_source:setVolume(0.8)
    music_source:setLooping(true)
    music_source:setVolume(0.5)
    lurek.log.info("loaded jump as " .. jump_source:getType() .. " and music as " .. music_source:getType(), "audio")
  end
end
--@api-stub: LSoundPool:play
-- Plays the next available voice from a sound pool.
do
  -- Pools pre-allocate voices so rapid effects can overlap without reloading data.
  local ok_pool, hit_pool = pcall(lurek.audio.newPool, "sfx/hit.ogg", 4)
  if ok_pool then
    hit_pool:setVolume(0.75)
    local voice_id = hit_pool:play()
    lurek.log.info("played pooled hit voice id=" .. voice_id, "audio")
  end
end
--@api-stub: LMidiPlayer:stop
-- Stops MIDI playback and resets its position.
do
  -- A MIDI player can be created empty, then loaded later with load() or loadData().
  local midi_player = lurek.audio.newMidiPlayer()
  midi_player:setLooping(false)
  midi_player:stop()
  lurek.log.info("midi stopped, playing=" .. tostring(midi_player:isPlaying()), "audio")
end
--@api-stub: LSoundPool:setVolume
-- Sets the volume for every voice in a sound pool.
do
  local ok_pool, footstep_pool = pcall(lurek.audio.newPool, "sfx/footstep.ogg", 6)
  if ok_pool then
    -- Volume is a multiplier: 0.0 is silent, 1.0 is normal output.
    footstep_pool:setVolume(0.45)
    lurek.log.info("footstep voices=" .. footstep_pool:getVoiceCount(), "audio")
  end
end
--@api-stub: LMidiPlayer:getVolume
-- Returns the current MIDI master volume.
do
  local midi_player = lurek.audio.newMidiPlayer()
  midi_player:setVolume(0.65)

  -- Useful for menu sliders or for restoring saved MIDI settings.
  local volume = midi_player:getVolume()
  lurek.log.info("midi volume=" .. volume, "audio")
end
--@api-stub: LMidiPlayer:pause
-- Pauses MIDI playback at the current position.
do
  local midi_player = lurek.audio.newMidiPlayer()
  midi_player:play()
  midi_player:pause()
  lurek.log.info("midi paused=" .. tostring(midi_player:isPaused()), "audio")
end
--@api-stub: LBus:resume
-- Resumes every source routed through this bus.
do
  local music_bus = lurek.audio.newBus("music")
  music_bus:pause()
  music_bus:resume()
  lurek.log.info("music bus paused=" .. tostring(music_bus:isPaused()), "audio")
end
--@api-stub: LBus:setPitch
-- Sets a pitch multiplier for every source routed through a bus.
do
  local ambience_bus = lurek.audio.newBus("ambience")
  ambience_bus:setPitch(0.8)
  lurek.log.info("ambience pitch=" .. ambience_bus:getPitch(), "audio")
end
--@api-stub: LBus:getPitch
-- Returns the current pitch multiplier of this bus.
do
  local music_bus = lurek.audio.newBus("music")
  music_bus:setPitch(1.05)
  lurek.log.info("music pitch=" .. music_bus:getPitch(), "audio")
end
--@api-stub: LMidiPlayer:isPlaying
-- Returns whether this MIDI player is currently playing.
do
  local midi_player = lurek.audio.newMidiPlayer()
  lurek.log.info("midi playing=" .. tostring(midi_player:isPlaying()), "audio")
end
--@api-stub: LMidiPlayer:isPaused
-- Returns whether this MIDI player is paused.
do
  local midi_player = lurek.audio.newMidiPlayer()
  midi_player:pause()
  lurek.log.info("midi paused=" .. tostring(midi_player:isPaused()), "audio")
end
--@api-stub: LSource:isStopped
-- Returns whether this source is stopped.
do
  local ok_sting, sting_source = pcall(lurek.audio.newSource, "sfx/sting.ogg", "static")
  if ok_sting then
    sting_source:play()
    sting_source:stop()
    lurek.log.info("source stopped=" .. tostring(sting_source:isStopped()), "audio")
  end
end
--@api-stub: LMidiPlayer:setLooping
-- Enables or disables MIDI looping.
do
  local midi_player = lurek.audio.newMidiPlayer()
  midi_player:setLooping(true)
  lurek.log.info("midi looping enabled=" .. tostring(midi_player:isLooping()), "audio")
end
--@api-stub: LMidiPlayer:isLooping
-- Returns whether MIDI looping is enabled.
do
  local midi_player = lurek.audio.newMidiPlayer()
  midi_player:setLooping(false)
  lurek.log.info("midi looping=" .. tostring(midi_player:isLooping()), "audio")
end
--@api-stub: lurek.audio.playLooping
-- Starts a source and marks it as looping.
do
  local ok_rain, rain_source = pcall(lurek.audio.newSource, "music/rain_loop.ogg", "stream")
  if ok_rain then
    lurek.audio.playLooping(rain_source)
    lurek.log.info("rain looping=" .. tostring(rain_source:isLooping()), "audio")
  end
end
--@api-stub: LSource:setPan
-- Sets stereo pan for this source.
do
  local ok_swoosh, swoosh_source = pcall(lurek.audio.newSource, "sfx/swoosh.ogg", "static")
  if ok_swoosh then
    swoosh_source:setPan(-0.5)
    lurek.log.info("swoosh pan=" .. swoosh_source:getPan(), "audio")
  end
end
--@api-stub: LSource:getPan
-- Returns stereo pan for this source.
do
  local ok_swoosh, swoosh_source = pcall(lurek.audio.newSource, "sfx/swoosh.ogg", "static")
  if ok_swoosh then
    swoosh_source:setPan(0.25)
    lurek.log.info("swoosh pan=" .. swoosh_source:getPan(), "audio")
  end
end
--@api-stub: lurek.audio.setMasterVolume
-- Sets the global master volume affecting all audio output.
do
  local user_volume = 0.7
  lurek.audio.setMasterVolume(user_volume)
  lurek.log.info("master volume set to " .. lurek.audio.getMasterVolume(), "audio")
end
--@api-stub: lurek.audio.getMasterVolume
-- Returns the current global master volume multiplier.
do
  lurek.audio.setMasterVolume(0.7)
  local master_volume = lurek.audio.getMasterVolume()
  lurek.log.info("master=" .. master_volume, "audio")
end
--@api-stub: lurek.audio.getActiveSourceCount
-- Returns the number of sources currently playing audio.
do
  lurek.log.info("active sources=" .. lurek.audio.getActiveSourceCount(), "audio")
end
--@api-stub: lurek.audio.getSourceCount
-- Returns the total number of loaded audio sources.
do
  local source_count = lurek.audio.getSourceCount()
  lurek.log.info("loaded source count=" .. source_count, "audio")
end
--@api-stub: lurek.audio.getSourceType
-- Returns whether a source is static or streaming.
do
  local ok_music, music_source = pcall(lurek.audio.newSource, "music/level.mp3", "stream")
  if ok_music then
    local source_type = lurek.audio.getSourceType(music_source)
    lurek.log.info("music source type=" .. source_type, "audio")
  end
end
--@api-stub: LSource:clone
-- Creates an independent copy of a source sharing the same audio data.
do
  local ok_hit, hit_source = pcall(lurek.audio.newSource, "sfx/hit.ogg", "static")
  if ok_hit then
    local copy = hit_source:clone()
    copy:setVolume(0.6)
    lurek.log.info("cloned source type=" .. copy:getType(), "audio")
  end
end
--@api-stub: lurek.audio.pauseAll
-- Pauses all currently playing audio sources.
do
  local ok_music, music_source = pcall(lurek.audio.newSource, "music/level.mp3", "stream")
  if ok_music then
    music_source:play()
    lurek.audio.pauseAll()
    lurek.log.info("paused all sources", "audio")
  end
end
--@api-stub: LSoundPool:stopAll
-- Stops every active voice in this sound pool.
do
  local ok_pool, laser_pool = pcall(lurek.audio.newPool, "sfx/laser.ogg", 3)
  if ok_pool then
    laser_pool:play()
    laser_pool:stopAll()
  end
end
--@api-stub: lurek.audio.resumeAll
-- Resumes all paused audio sources.
do
  local ok_music, music_source = pcall(lurek.audio.newSource, "music/level.mp3", "stream")
  if ok_music then
    music_source:play()
    lurek.audio.pauseAll()
    lurek.audio.resumeAll()
  end
end
--@api-stub: LDecoder:release
-- Releases decoder resources.
do
  local ok_decoder, decoder = pcall(lurek.audio.newDecoder, "music/long_track.ogg", 4096)
  if ok_decoder then
    decoder:release()
  else
    lurek.log.warn("decoder asset missing; release example skipped", "audio")
  end
end
--@api-stub: lurek.audio.newBus
-- Creates a new audio mixing bus for grouped control.
do
  local sfx_bus = lurek.audio.newBus("sfx")
  sfx_bus:setVolume(0.7)
  lurek.log.info("bus=" .. sfx_bus:getName() .. " volume=" .. sfx_bus:getVolume(), "audio")
end
--@api-stub: lurek.audio.setSourceBus
-- Routes a source through a specific audio bus.
do
  local voice_bus = lurek.audio.newBus("voice")
  local ok_line, line_source = pcall(lurek.audio.newSource, "voice/line01.ogg", "static")
  if ok_line then
    voice_bus:setVolume(0.85)
    lurek.audio.setSourceBus(line_source, voice_bus)
  end
end
--@api-stub: lurek.audio.getSourceBus
-- Returns the bus a source is routed through.
do
  local sfx_bus = lurek.audio.newBus("sfx")
  local ok_hit, hit_source = pcall(lurek.audio.newSource, "sfx/hit.ogg", "static")
  if ok_hit then
    lurek.audio.setSourceBus(hit_source, sfx_bus)
    local routed_bus = lurek.audio.getSourceBus(hit_source)
    if routed_bus then
      lurek.log.info("routed through: " .. routed_bus:getName(), "audio")
    end
  end
end
--@api-stub: lurek.audio.getMaxSources
-- Returns the maximum number of simultaneous audio sources supported
do
  -- Engine hard limit. Plan your sound budget and stop or reuse low-priority voices.
  local max_sources = lurek.audio.getMaxSources()
  lurek.log.info("max simultaneous voices=" .. max_sources, "audio")
end
--@api-stub: LSoundData:getDuration
-- Returns the approximate duration of a sound buffer in seconds.
do
  -- One second of mono audio at 44.1 kHz has 44,100 samples.
  local buffer = lurek.audio.newSoundData(44100, 44100, 1)
  local duration = buffer:getDuration()
  lurek.log.info("sound data duration=" .. string.format("%.2f", duration) .. "s", "audio")
end
--@api-stub: LDecoder:tell
-- Returns the current decoder read position in seconds.
do
  local ok_decoder, decoder = pcall(lurek.audio.newDecoder, "music/long_track.ogg", 4096)
  if ok_decoder then
    -- tell() reports the current decode cursor, not a mixer playback cursor.
    local position = decoder:tell()
    lurek.log.info("decoder at=" .. position .. "s", "audio")
  end
end
--@api-stub: LDecoder:seek
-- Seeks a decoder to a specific read position in seconds.
do
  local ok_decoder, decoder = pcall(lurek.audio.newDecoder, "music/long_track.ogg", 4096)
  if ok_decoder then
    -- Jump to 30 seconds before the next decode() call.
    decoder:seek(30.0)
    lurek.log.info("decoder seeked to=" .. decoder:tell() .. "s", "audio")
  end
end
--@api-stub: LSource:setLowpass
-- Applies a lowpass filter to a source, attenuating high frequencies
do
  local ok_music, music_source = pcall(lurek.audio.newSource, "music/level.mp3", "stream")
  if ok_music then
    -- Lowpass at 800 Hz makes audio sound muffled, like being behind a wall.
    music_source:setLowpass(800)
    music_source:play()
  end
end
--@api-stub: LSource:setHighpass
-- Applies a highpass filter to a source, attenuating low frequencies
do
  local ok_radio, radio_source = pcall(lurek.audio.newSource, "music/radio_loop.ogg", "stream")
  if ok_radio then
    -- Highpass at 200 Hz removes bass rumble and can simulate a small speaker.
    radio_source:setHighpass(200)
    radio_source:play()
  end
end
--@api-stub: LSource:getLowpass
-- Returns the current lowpass filter cutoff of a source
do
  local ok_music, music_source = pcall(lurek.audio.newSource, "music/level.mp3", "stream")
  if ok_music then
    music_source:setLowpass(800)
    lurek.log.info("lowpass cutoff=" .. music_source:getLowpass() .. " Hz", "audio")
  end
end
--@api-stub: LSource:getHighpass
-- Returns the current highpass filter cutoff of a source
do
  local ok_radio, radio_source = pcall(lurek.audio.newSource, "music/radio_loop.ogg", "stream")
  if ok_radio then
    radio_source:setHighpass(200)
    lurek.log.info("highpass cutoff=" .. radio_source:getHighpass() .. " Hz", "audio")
  end
end
--@api-stub: LSource:clearFilter
-- Removes all frequency filters from a source
do
  local ok_music, music_source = pcall(lurek.audio.newSource, "music/level.mp3", "stream")
  if ok_music then
    music_source:setLowpass(800)
    music_source:setHighpass(120)

    -- clearFilter() removes both lowpass and highpass and restores full-band playback.
    music_source:clearFilter()
    lurek.log.info("filters cleared: lp=" .. tostring(music_source:getLowpass()) .. " hp=" .. tostring(music_source:getHighpass()), "audio")
  end
end
--@api-stub: LSource:fadeIn
-- Sets the fade-in duration for a source so it ramps from silence on play
do
  local ok_music, music_source = pcall(lurek.audio.newSource, "music/level.mp3", "stream")
  if ok_music then
    -- Set fade-in before play() so the source ramps from silence to its volume.
    music_source:fadeIn(2.5)
    music_source:play()
  end
end
--@api-stub: LSource:getFadeIn
-- Returns the configured fade-in duration of a source
do
  local ok_music, music_source = pcall(lurek.audio.newSource, "music/level.mp3", "stream")
  if ok_music then
    music_source:fadeIn(2.5)
    lurek.log.info("fade-in duration=" .. music_source:getFadeIn() .. "s", "audio")
  end
end
--@api-stub: lurek.audio.setListener2D
-- Sets the 2D listener position for spatial audio calculations
do
  -- The listener is usually the camera or player position in world units.
  local camera_x, camera_y = 320.0, 240.0
  lurek.audio.setListener2D(camera_x, camera_y)
end
--@api-stub: lurek.audio.getListener2D
-- Returns the current 2D listener position
do
  lurek.audio.setListener2D(320.0, 240.0)
  local listener_x, listener_y = lurek.audio.getListener2D()
  lurek.log.info("listener at " .. listener_x .. ", " .. listener_y, "audio")
end
--@api-stub: lurek.audio.setListener
-- Sets the 3D listener position for spatial audio (Z defaults to 0 for 2D games)
do
  -- For 2D games, pass Z as 0.0 or omit it and let the binding default to zero.
  lurek.audio.setListener(320.0, 240.0, 0.0)
end
--@api-stub: lurek.audio.getListener
-- Returns the current 3D listener position
do
  lurek.audio.setListener(320.0, 240.0, 0.0)
  local listener_x, listener_y, listener_z = lurek.audio.getListener()
  lurek.log.info("listener 3D=" .. listener_x .. "," .. listener_y .. "," .. listener_z, "audio")
end
--@api-stub: lurek.audio.setPosition
-- Sets the 3D position of a source for spatial audio panning and attenuation
do
  local ok_footstep, footstep_source = pcall(lurek.audio.newSource, "sfx/footstep.ogg", "static")
  if ok_footstep then
    -- Place the emitter at a world position relative to the listener.
    lurek.audio.setPosition(footstep_source, 480.0, 240.0, 0.0)
    footstep_source:play()
  end
end
--@api-stub: lurek.audio.getPosition
-- Returns the 3D position of a source
do
  local ok_footstep, footstep_source = pcall(lurek.audio.newSource, "sfx/footstep.ogg", "static")
  if ok_footstep then
    lurek.audio.setPosition(footstep_source, 480.0, 240.0, 0.0)
    local source_x, source_y, source_z = lurek.audio.getPosition(footstep_source)
    lurek.log.info("emitter at " .. source_x .. "," .. source_y .. "," .. source_z, "audio")
  end
end
--@api-stub: lurek.audio.setVelocity
-- Sets the velocity of a source for Doppler effect calculations
do
  local ok_engine, engine_source = pcall(lurek.audio.newSource, "sfx/engine.ogg", "static")
  if ok_engine then
    -- Velocity is in world units per second and feeds Doppler calculations.
    lurek.audio.setVelocity(engine_source, 60.0, 0.0, 0.0)
    engine_source:play()
  end
end
--@api-stub: lurek.audio.getVelocity
-- Returns the velocity vector of a source
do
  local ok_engine, engine_source = pcall(lurek.audio.newSource, "sfx/engine.ogg", "static")
  if ok_engine then
    lurek.audio.setVelocity(engine_source, 60.0, 0.0, 0.0)
    local velocity_x, velocity_y, velocity_z = lurek.audio.getVelocity(engine_source)
    lurek.log.info("velocity=" .. velocity_x .. "," .. velocity_y .. "," .. velocity_z, "audio")
  end
end
--@api-stub: lurek.audio.setOrientation
-- Sets the orientation of a source using forward and up vectors
do
  local ok_horn, horn_source = pcall(lurek.audio.newSource, "sfx/horn.ogg", "static")
  if ok_horn then
    -- Six floats: forward vector first, then up vector.
    lurek.audio.setOrientation(horn_source, 0.0, 0.0, -1.0, 0.0, 1.0, 0.0)
    horn_source:play()
  end
end
--@api-stub: lurek.audio.getOrientation
-- Returns the orientation vectors of a source
do
  local ok_horn, horn_source = pcall(lurek.audio.newSource, "sfx/horn.ogg", "static")
  if ok_horn then
    lurek.audio.setOrientation(horn_source, 0.0, 0.0, -1.0, 0.0, 1.0, 0.0)
    local forward_x, forward_y, forward_z, up_x, up_y, up_z = lurek.audio.getOrientation(horn_source)
    lurek.log.info("forward=" .. forward_x .. "," .. forward_y .. "," .. forward_z, "audio")
    lurek.log.info("up=" .. up_x .. "," .. up_y .. "," .. up_z, "audio")
  end
end
--@api-stub: lurek.audio.setDopplerScale
-- Sets the global Doppler effect intensity multiplier
do
  -- 1.0 is realistic Doppler, 0.0 disables it, higher values exaggerate it.
  lurek.audio.setDopplerScale(1.0)
end
--@api-stub: lurek.audio.getDopplerScale
-- Returns the current global Doppler effect scale
do
  lurek.audio.setDopplerScale(1.5)
  lurek.log.info("doppler scale=" .. lurek.audio.getDopplerScale(), "audio")
end
--@api-stub: lurek.audio.setDistanceModel
-- Sets the distance attenuation model for spatial audio
do
  -- Supported model names include "none", "linear", "inverse", and "exponent".
  lurek.audio.setDistanceModel("linear")
end
--@api-stub: lurek.audio.getDistanceModel
-- Returns the current distance attenuation model name
do
  lurek.audio.setDistanceModel("linear")
  lurek.log.info("distance model=" .. lurek.audio.getDistanceModel(), "audio")
end
--@api-stub: lurek.audio.setMeter
-- Sets the master peak level for metering purposes
do
  -- Useful for testing a VU meter UI without requiring live audio output.
  lurek.audio.setMeter(0.7)
end
--@api-stub: lurek.audio.getMeter
-- Returns the current master peak level for VU-meter displays
do
  lurek.audio.setMeter(0.7)

  -- Read this each frame to drive a VU meter bar in the HUD.
  lurek.log.info("meter peak=" .. lurek.audio.getMeter(), "audio")
end
--@api-stub: lurek.audio.newMidiPlayer
-- Creates a new MIDI player instance, optionally loading a file immediately
do
  -- Pass a path to load immediately, or create empty and call :load() later.
  local midi_player = lurek.audio.newMidiPlayer()
  midi_player:setLooping(true)
  midi_player:setVolume(0.8)
  lurek.log.info("new MIDI player loaded=" .. tostring(midi_player:isLoaded()), "audio")
end
--@api-stub: lurek.audio.newSoundData
-- Creates a new SoundData object from a file path or blank buffer for procedural audio
do
  -- Args: sample_count, sample_rate, channels.
  -- Creates a blank buffer you can fill with setSample() for procedural generation.
  local sound_data = lurek.audio.newSoundData(44100, 44100, 1)
  sound_data:setSample(0, 0.25)
  lurek.log.info("blank buffer samples=" .. sound_data:getSampleCount(), "audio")
end
--@api-stub: lurek.audio.setMidiSoundFont
-- Sets the midi sound font for Lua scripts in this module
do
  -- Must be called before MIDI playback. Points to a General MIDI compatible .sf2 file.
  local ok_soundfont, err = pcall(lurek.audio.setMidiSoundFont, "music/gm.sf2")
  if ok_soundfont then
    lurek.log.info("MIDI SoundFont loaded", "audio")
  else
    lurek.log.warn("SoundFont unavailable: " .. tostring(err), "audio")
  end
end
--@api-stub: lurek.audio.hasMidiSoundFont
-- Returns true if midi sound font for Lua scripts in this module
do
  -- Check before MIDI playback so UI can warn when notes will be silent.
  if not lurek.audio.hasMidiSoundFont() then
    lurek.log.warn("no soundfont loaded; MIDI will be silent", "audio")
  end
end
--@api-stub: lurek.audio.clearMidiSoundFont
-- Clears midi sound font for Lua scripts in this module
do
  -- Unload the SoundFont to free memory when MIDI is no longer needed.
  lurek.audio.clearMidiSoundFont()
  lurek.log.info("soundfont loaded=" .. tostring(lurek.audio.hasMidiSoundFont()), "audio")
end
--@api-stub: lurek.audio.newDecoder
-- Creates a streaming audio decoder for the given file
do
  -- Args: file_path, buffer_size in samples per decode chunk.
  local ok_decoder, decoder = pcall(lurek.audio.newDecoder, "music/long_track.ogg", 4096)
  if ok_decoder then
    lurek.log.info("decoder rate=" .. decoder:getSampleRate() .. " Hz", "audio")
  else
    lurek.log.warn("decoder asset missing; streaming example skipped", "audio")
  end
end
--@api-stub: lurek.audio.newQueueableSource
-- Creates a new queueable audio source for streaming PCM data buffer by buffer
do
  -- Args: sample_rate, bit_depth, channels, buffer_count.
  -- Queueable sources let you feed generated or streamed PCM buffers in order.
  local queueable_id = lurek.audio.newQueueableSource(44100, 16, 1, 4)
  lurek.log.info("queueable source id=" .. queueable_id, "audio")
end
--@api-stub: lurek.audio.queueSource
-- Queues a decoded audio chunk for playback on a queueable source
do
  local queueable_id = lurek.audio.newQueueableSource(44100, 16, 1, 4)

  -- Generate a short tone and push it into the queue.
  -- Buffers are consumed in first-in, first-out order.
  local chunk = lurek.audio.newSineWave(440.0, 0.1, 44100, 0.5)
  lurek.audio.queueSource(queueable_id, chunk)
end
--@api-stub: lurek.audio.getFreeBufferCount
-- Returns the number of free (available) buffer slots on a queueable source
do
  local queueable_id = lurek.audio.newQueueableSource(44100, 16, 1, 4)

  -- Check free slots before queuing. If zero, wait until playback consumes a buffer.
  local free_buffers = lurek.audio.getFreeBufferCount(queueable_id)
  lurek.log.info("free buffer slots=" .. free_buffers, "audio")
end
--@api-stub: lurek.audio.playQueueable
-- Play queueable for Lua scripts in this module
do
  local queueable_id = lurek.audio.newQueueableSource(44100, 16, 1, 4)
  local chunk = lurek.audio.newSineWave(440.0, 0.5, 44100, 0.5)
  lurek.audio.queueSource(queueable_id, chunk)

  -- Start playback of queued buffers. Keep queuing to avoid underruns.
  lurek.audio.playQueueable(queueable_id)
end
--@api-stub: lurek.audio.stopQueueable
-- Stop queueable for Lua scripts in this module
do
  local queueable_id = lurek.audio.newQueueableSource(44100, 16, 1, 4)
  lurek.audio.playQueueable(queueable_id)

  -- Stops playback for this queueable source.
  lurek.audio.stopQueueable(queueable_id)
end
--@api-stub: lurek.audio.getPlaybackDevices
-- Returns the playback devices for Lua scripts in this module
do
  -- Returns available output device names for an options menu.
  local devices = lurek.audio.getPlaybackDevices()
  for index, device_name in ipairs(devices) do
    lurek.log.info(index .. ": " .. device_name, "audio")
  end
end
--@api-stub: lurek.audio.getPlaybackDevice
-- Returns the playback device for Lua scripts in this module
do
  local current_device = lurek.audio.getPlaybackDevice()
  lurek.log.info("current output device=" .. current_device, "audio")
end
--@api-stub: lurek.audio.setPlaybackDevice
-- Sets the playback device for Lua scripts in this module
do
  -- Use a name returned by getPlaybackDevices(); setting the current device is a safe no-op.
  local current_device = lurek.audio.getPlaybackDevice()
  if current_device ~= "" then
    local ok_device, err = pcall(lurek.audio.setPlaybackDevice, current_device)
    if not ok_device then
      lurek.log.warn("playback device unchanged: " .. tostring(err), "audio")
    end
  end
end
--@api-stub: lurek.audio.create_bus
-- Create_bus for Lua scripts in this module
do
  -- create_bus creates a named bus. The second arg accepts an optional parent bus name.
  lurek.audio.create_bus("music")
  lurek.audio.create_bus("ambient_music", "music")
end
--@api-stub: lurek.audio.set_bus_volume
-- Sets the volume of a named audio bus
do
  lurek.audio.create_bus("music")

  -- All sources routed to the named bus are scaled by this volume.
  lurek.audio.set_bus_volume("music", 0.7)
end
--@api-stub: lurek.audio.add_effect
-- Adds an effect to a named audio bus and returns its effect ID
do
  lurek.audio.create_bus("sfx")

  -- Add a lowpass effect to the entire SFX bus. The returned ID addresses this effect.
  local effect_id = lurek.audio.add_effect("sfx", "lowpass", {value = 1500.0})
  lurek.log.info("effect id=" .. tostring(effect_id), "audio")
end
--@api-stub: lurek.audio.remove_effect
-- Remove_effect for Lua scripts in this module
do
  lurek.audio.create_bus("sfx")
  local effect_id = lurek.audio.add_effect("sfx", "lowpass", {value = 1500.0})

  -- Remove the effect by bus name and effect ID when the muffled section ends.
  if effect_id then
    lurek.audio.remove_effect("sfx", effect_id)
  end
end
--@api-stub: lurek.audio.set_effect_param
-- Set_effect_param for Lua scripts in this module
do
  lurek.audio.create_bus("sfx")
  local effect_id = lurek.audio.add_effect("sfx", "lowpass", {value = 1500.0})

  -- Lowpass effects accept "cutoff" or "frequency" for their primary frequency.
  if effect_id then
    lurek.audio.set_effect_param("sfx", effect_id, "cutoff", 800.0)
  end
end
--@api-stub: lurek.audio.newSineWave
-- Generates a sine wave as a `SoundData` buffer
do
  -- Args: frequency_hz, duration_sec, sample_rate, amplitude from 0.0 to 1.0.
  local beep = lurek.audio.newSineWave(440.0, 0.25, 44100, 0.5)
  lurek.log.info("sine wave samples=" .. beep:getSampleCount(), "audio")
end
--@api-stub: lurek.audio.newSquareWave
-- Generates a square wave as a `SoundData` buffer
do
  -- Square waves have a sharp tone, useful for retro UI or synth effects.
  local square = lurek.audio.newSquareWave(220.0, 0.5, 44100, 0.5)
  lurek.log.info("square wave samples=" .. square:getSampleCount(), "audio")
end
--@api-stub: lurek.audio.newSawtoothWave
-- Generates a sawtooth wave as a `SoundData` buffer
do
  -- Sawtooth waves are bright and rich in harmonics for synth-style sounds.
  local sawtooth = lurek.audio.newSawtoothWave(110.0, 1.0, 44100, 0.5)
  lurek.log.info("sawtooth duration=" .. sawtooth:getDuration() .. "s", "audio")
end
--@api-stub: lurek.audio.newTriangleWave
-- Generates a triangle wave as a `SoundData` buffer
do
  -- Triangle waves are softer than square waves and work well for gentle tones.
  local triangle = lurek.audio.newTriangleWave(330.0, 0.5, 44100, 0.5)
  lurek.log.info("triangle samples=" .. triangle:getSampleCount(), "audio")
end
--@api-stub: lurek.audio.newWhiteNoise
-- Generates white noise as a `SoundData` buffer using a deterministic seed
do
  -- Args: duration_sec, sample_rate, amplitude, seed.
  -- The same seed produces identical noise, which is useful for reproducible SFX.
  local noise = lurek.audio.newWhiteNoise(0.5, 44100, 0.3, 12345)
  lurek.log.info("noise samples=" .. noise:getSampleCount(), "audio")
end
--@api-stub: lurek.audio.applyLowpass
-- Applies a lowpass filter in-place to the sound data
do
  local sawtooth = lurek.audio.newSawtoothWave(110.0, 1.0, 44100, 0.5)

  -- Permanently modifies the buffer by reducing frequencies above 800 Hz.
  lurek.audio.applyLowpass(sawtooth, 800.0)
end
--@api-stub: lurek.audio.applyHighpass
-- Applies a highpass filter in-place to the sound data
do
  local sawtooth = lurek.audio.newSawtoothWave(110.0, 1.0, 44100, 0.5)

  -- Reduces frequencies below 80 Hz to remove low-end rumble.
  lurek.audio.applyHighpass(sawtooth, 80.0)
end
--@api-stub: lurek.audio.applyBandpass
-- Applies a bandpass filter in-place to the sound data
do
  local sound_data = lurek.audio.newWhiteNoise(0.5, 44100, 0.3, 1)

  -- Keeps only frequencies between low_hz and high_hz.
  lurek.audio.applyBandpass(sound_data, 300.0, 3400.0)
end
--@api-stub: lurek.audio.applyGain
-- Applies a gain multiplier in-place to the sound data
do
  local sound_data = lurek.audio.newSineWave(440.0, 0.25, 44100, 0.3)

  -- Values above 1.0 amplify; values below 1.0 attenuate.
  lurek.audio.applyGain(sound_data, 1.5)
end
--@api-stub: lurek.audio.mixInto
-- Mixes the samples of `src` into `dest` in-place (both must have the same format)
do
  local tone_a = lurek.audio.newSineWave(440.0, 0.5, 44100, 0.3)
  local tone_b = lurek.audio.newSineWave(660.0, 0.5, 44100, 0.3)

  -- Both buffers should use the same sample rate, channel count, and length.
  lurek.audio.mixInto(tone_a, tone_b)
end
--@api-stub: lurek.audio.saveWAV
-- Encodes the sound data as a WAV file and saves it to the given path (relative to game dir)
do
  local tone = lurek.audio.newSineWave(440.0, 1.0, 44100, 0.5)

  -- Export procedurally generated audio as a standard WAV file.
  local ok_save, err = pcall(lurek.audio.saveWAV, tone, "save/audio_example_tone.wav")
  if not ok_save then
    lurek.log.warn("saveWAV failed: " .. tostring(err), "audio")
  end
end
--@api-stub: lurek.audio.setStereoWidth
-- Sets the stereo width of an audio source (0
do
  local ok_music, music_source = pcall(lurek.audio.newSource, "music/level.mp3", "stream")
  if ok_music then
    -- 0.0 is mono, 1.0 is normal stereo, and values above 1.0 widen stereo.
    lurek.audio.setStereoWidth(music_source, 0.5)
    music_source:play()
  end
end
--@api-stub: lurek.audio.getStereoWidth
-- Returns the current stereo width factor of an audio source
do
  local ok_music, music_source = pcall(lurek.audio.newSource, "music/level.mp3", "stream")
  if ok_music then
    lurek.audio.setStereoWidth(music_source, 0.5)
    lurek.log.info("stereo width=" .. lurek.audio.getStereoWidth(music_source), "audio")
  end
end
--@api-stub: lurek.audio.setRandomPitch
-- Sets a random pitch range for a source; each play picks a random pitch between min and max
do
  local ok_footstep, footstep_source = pcall(lurek.audio.newSource, "sfx/footstep.ogg", "static")
  if ok_footstep then
    -- Each play picks a pitch between 0.95 and 1.05.
    lurek.audio.setRandomPitch(footstep_source, 0.95, 1.05)
    footstep_source:play()
  end
end
--@api-stub: lurek.audio.clearRandomPitch
-- Clears any random pitch range previously set on the source
do
  local ok_footstep, footstep_source = pcall(lurek.audio.newSource, "sfx/footstep.ogg", "static")
  if ok_footstep then
    lurek.audio.setRandomPitch(footstep_source, 0.95, 1.05)

    -- Restore fixed pitch behavior for scripted or rhythm-critical sounds.
    lurek.audio.clearRandomPitch(footstep_source)
  end
end
--@api-stub: lurek.audio.crossfade
-- Crossfades from one audio source to another over the given duration
do
  local ok_intro, intro_source = pcall(lurek.audio.newSource, "music/level1.mp3", "stream")
  local ok_loop, loop_source = pcall(lurek.audio.newSource, "music/level2.mp3", "stream")
  if ok_intro and ok_loop then
    intro_source:play()

    -- Smoothly transitions from intro_source to loop_source over 3 seconds.
    lurek.audio.crossfade(intro_source, loop_source, 3.0)
  end
end
--@api-stub: lurek.audio.getBusPeak
-- Returns the peak amplitude of the named audio bus over the last processing frame
do
  lurek.audio.create_bus("music")

  -- Peak is the loudest sample in the last audio frame. Use it for fast meters.
  local peak = lurek.audio.getBusPeak("music")
  lurek.log.info("music bus peak=" .. peak, "audio")
end
--@api-stub: lurek.audio.getBusRms
-- Returns the RMS (root mean square) amplitude of the named audio bus over the last processing frame
do
  lurek.audio.create_bus("music")

  -- RMS is smoother than peak and works well for reactive UI or beat thresholds.
  local rms = lurek.audio.getBusRms("music")
  lurek.log.info("music bus rms=" .. rms, "audio")
end
--@api-stub: lurek.audio.newPool
-- Creates a polyphonic sound pool that allows the same audio file to play on multiple simultaneous voices
do
  -- A pool pre-allocates several copies of the same sound for overlapping playback.
  local ok_pool, footstep_pool = pcall(lurek.audio.newPool, "sfx/footstep.ogg", 8)
  if ok_pool then
    footstep_pool:setVolume(0.7)
    footstep_pool:play()
  end
end
--@api-stub: lurek.audio.processOffline
-- Processes an audio file offline through a chain of effects and writes the result to an output file
do
  -- Each effect is a table: {type = "...", p1 = ..., p2 = ..., p3 = ...}.
  local effects = {{type = "lowpass", p1 = 800.0, p2 = 1.0, p3 = 0.5}}
  local ok_process, err = pcall(lurek.audio.processOffline, "music/in.wav", "save/out.wav", effects)
  if not ok_process then
    lurek.log.warn("offline processing skipped: " .. tostring(err), "audio")
  end
end
--@api-stub: lurek.audio.normalizeFile
-- Normalize file for Lua scripts in this module
do
  -- Scales the file so the peak reaches the target amplitude.
  local ok_normalize, err = pcall(lurek.audio.normalizeFile, "music/raw.wav", "save/normalized.wav", 0.95)
  if not ok_normalize then
    lurek.log.warn("normalize skipped: " .. tostring(err), "audio")
  end
end
--@api-stub: lurek.audio.waveformToPng
-- Waveform to png for Lua scripts in this module
do
  -- Renders an amplitude-over-time preview image for debugging or tools.
  local ok_waveform, err = pcall(lurek.audio.waveformToPng, "music/level.wav", "save/level_wave.png", 800, 200)
  if not ok_waveform then
    lurek.log.warn("waveform render skipped: " .. tostring(err), "audio")
  end
end
--@api-stub: lurek.audio.spectrogramToPng
-- Spectrogram to png for Lua scripts in this module
do
  -- Renders a frequency-over-time image that shows which frequencies are present.
  local ok_spectrogram, err = pcall(lurek.audio.spectrogramToPng, "music/level.wav", "save/level_spec.png", 800, 400)
  if not ok_spectrogram then
    lurek.log.warn("spectrogram render skipped: " .. tostring(err), "audio")
  end
end
--@api-stub: LSoundPool:play
-- Plays the next available voice from a sound pool.
do
  local ok_pool, ui_pool = pcall(lurek.audio.newPool, "sfx/ui_click.ogg", 4)
  if ok_pool then
    local voice_id = ui_pool:play()
    lurek.log.info("UI click voice=" .. voice_id, "audio")
  end
end
--@api-stub: LMidiPlayer:stop
-- Stops MIDI playback and rewinds to the beginning.
do
  local midi_player = lurek.audio.newMidiPlayer()
  midi_player:play()
  midi_player:stop()
  lurek.log.info("midi stopped=" .. tostring(not midi_player:isPlaying()), "audio")
end
--@api-stub: LMidiPlayer:pause
-- Pauses MIDI playback at the current position.
do
  local midi_player = lurek.audio.newMidiPlayer()
  midi_player:play()
  midi_player:pause()
  lurek.log.info("midi paused=" .. tostring(midi_player:isPaused()), "audio")
end
--@api-stub: LBus:resume
-- Resumes all paused sources routed through this bus.
do
  local music_bus = lurek.audio.newBus("menu_music")
  music_bus:pause()
  music_bus:resume()
  lurek.log.info("bus paused=" .. tostring(music_bus:isPaused()), "audio")
end
--@api-stub: LSoundPool:setVolume
-- Sets the volume of every voice in the sound pool.
do
  local ok_pool, alert_pool = pcall(lurek.audio.newPool, "sfx/alert.ogg", 3)
  if ok_pool then
    alert_pool:setVolume(0.6)
    lurek.log.info("alert pool voices=" .. alert_pool:getVoiceCount(), "audio")
  end
end
--@api-stub: LMidiPlayer:getVolume
-- Returns the MIDI player master volume.
do
  local midi_player = lurek.audio.newMidiPlayer()
  midi_player:setVolume(0.5)
  lurek.log.info("midi volume=" .. midi_player:getVolume(), "audio")
end
--@api-stub: LBus:setPitch
-- Sets the pitch multiplier for the entire bus.
do
  local slow_motion_bus = lurek.audio.newBus("slow_motion")
  slow_motion_bus:setPitch(0.75)
  lurek.log.info("slow-motion pitch=" .. slow_motion_bus:getPitch(), "audio")
end
--@api-stub: LBus:getPitch
-- Returns the pitch multiplier for this bus.
do
  local music_bus = lurek.audio.newBus("credits_music")
  music_bus:setPitch(1.05)
  lurek.log.info("credits pitch=" .. music_bus:getPitch(), "audio")
end
--@api-stub: LMidiPlayer:setLooping
-- Enables or disables MIDI looping.
do
  local midi_player = lurek.audio.newMidiPlayer()
  midi_player:setLooping(true)
  lurek.log.info("midi looping=" .. tostring(midi_player:isLooping()), "audio")
end
--@api-stub: LMidiPlayer:isLooping
-- Returns whether MIDI looping is enabled.
do
  local midi_player = lurek.audio.newMidiPlayer()
  midi_player:setLooping(false)
  if not midi_player:isLooping() then
    lurek.log.info("midi will stop at the end", "audio")
  end
end
--@api-stub: LMidiPlayer:isPlaying
-- Returns whether a MIDI player is currently playing.
do
  local midi_player = lurek.audio.newMidiPlayer()
  midi_player:play()
  lurek.log.info("midi playing=" .. tostring(midi_player:isPlaying()), "audio")
end
--@api-stub: LMidiPlayer:isPaused
-- Returns whether a MIDI player is paused.
do
  local midi_player = lurek.audio.newMidiPlayer()
  midi_player:pause()
  if midi_player:isPaused() then
    midi_player:play()
  end
end
--@api-stub: LSource:isStopped
-- Returns whether a source is stopped.
do
  local ok_jump, jump_source = pcall(lurek.audio.newSource, "sfx/jump.ogg", "static")
  if ok_jump then
    jump_source:play()
    jump_source:stop()
    if jump_source:isStopped() then
      lurek.log.info("source idle", "audio")
    end
  end
end
--@api-stub: LSource:setPan
-- Sets stereo pan for this source.
do
  local ok_swoosh, swoosh_source = pcall(lurek.audio.newSource, "sfx/swoosh.ogg", "static")
  if ok_swoosh then
    -- -1.0 is hard left, 0.0 is center, and 1.0 is hard right.
    swoosh_source:setPan(-0.5)
    swoosh_source:play()
  end
end
--@api-stub: LSource:getPan
-- Returns stereo pan for this source.
do
  local ok_swoosh, swoosh_source = pcall(lurek.audio.newSource, "sfx/swoosh.ogg", "static")
  if ok_swoosh then
    swoosh_source:setPan(-0.5)
    lurek.log.info("pan=" .. swoosh_source:getPan(), "audio")
  end
end
--@api-stub: LSource:clone
-- Creates an independent source that shares the same audio data.
do
  local ok_hit, hit_source = pcall(lurek.audio.newSource, "sfx/hit.ogg", "static")
  if ok_hit then
    local copy_source = hit_source:clone()
    copy_source:setPitch(1.1)
    hit_source:play()
    copy_source:play()
  end
end
--@api-stub: LSource:getType
-- Returns the type of this source.
do
  local ok_music, music_source = pcall(lurek.audio.newSource, "music/level.mp3", "stream")
  if ok_music then
    -- Returns "static" or "stream".
    if music_source:getType() == "stream" then
      lurek.log.info("streaming from disk", "audio")
    end
  end
end
--@api-stub: LSource:getDuration
-- Returns the total duration of this source in seconds.
do
  local ok_music, music_source = pcall(lurek.audio.newSource, "music/level.mp3", "stream")
  if ok_music then
    lurek.log.info("track length=" .. tostring(music_source:getDuration()) .. "s", "audio")
  end
end
--@api-stub: LSource:tell
-- Returns this source playback position in seconds.
do
  local ok_music, music_source = pcall(lurek.audio.newSource, "music/level.mp3", "stream")
  if ok_music then
    music_source:play()
    lurek.log.info("position=" .. tostring(music_source:tell()) .. "s", "audio")
  end
end
--@api-stub: LSource:seek
-- Seeks this source to a playback position in seconds.
do
  local ok_music, music_source = pcall(lurek.audio.newSource, "music/level.mp3", "stream")
  if ok_music then
    music_source:play()
    music_source:seek(15.0)
  end
end
--@api-stub: LSource:setLowpass
-- Sets the lowpass of this source.
do
  local ok_music, music_source = pcall(lurek.audio.newSource, "music/level.mp3", "stream")
  if ok_music then
    -- Lowpass reduces high frequencies for muffled playback.
    music_source:setLowpass(800)
    music_source:play()
  end
end
--@api-stub: LSource:setHighpass
-- Sets the highpass of this source.
do
  local ok_music, music_source = pcall(lurek.audio.newSource, "music/level.mp3", "stream")
  if ok_music then
    -- Highpass reduces low frequencies for thin radio-style playback.
    music_source:setHighpass(200)
    music_source:play()
  end
end
--@api-stub: LSource:getLowpass
-- Returns the lowpass of this source.
do
  local ok_music, music_source = pcall(lurek.audio.newSource, "music/level.mp3", "stream")
  if ok_music then
    music_source:setLowpass(800)
    lurek.log.info("lowpass=" .. music_source:getLowpass() .. " Hz", "audio")
  end
end
--@api-stub: LSource:getHighpass
-- Returns the highpass of this source.
do
  local ok_music, music_source = pcall(lurek.audio.newSource, "music/level.mp3", "stream")
  if ok_music then
    music_source:setHighpass(200)
    lurek.log.info("highpass=" .. music_source:getHighpass() .. " Hz", "audio")
  end
end
--@api-stub: LSource:clearFilter
-- Clears all filter items from this source.
do
  local ok_music, music_source = pcall(lurek.audio.newSource, "music/level.mp3", "stream")
  if ok_music then
    music_source:setLowpass(800)
    music_source:setHighpass(160)

    -- Restore full frequency range by clearing both filter slots.
    music_source:clearFilter()
  end
end
--@api-stub: LSource:fadeIn
-- Performs the fade in operation on this source.
do
  local ok_music, music_source = pcall(lurek.audio.newSource, "music/level.mp3", "stream")
  if ok_music then
    -- Set before play: source ramps from silence over 2.5 seconds.
    music_source:fadeIn(2.5)
    music_source:play()
  end
end
--@api-stub: LSource:getFadeIn
-- Returns the fade in of this source.
do
  local ok_music, music_source = pcall(lurek.audio.newSource, "music/level.mp3", "stream")
  if ok_music then
    music_source:fadeIn(2.5)
    lurek.log.info("fade-in=" .. music_source:getFadeIn() .. "s", "audio")
  end
end
--@api-stub: LBus:getName
-- Returns the name of this bus.
do
  local music_bus = lurek.audio.newBus("music")
  lurek.log.info("bus name=" .. music_bus:getName(), "audio")
end
--@api-stub: LBus:setVolume
-- Sets the volume of this bus.
do
  local music_bus = lurek.audio.newBus("music")

  -- All sources routed to this bus are scaled by this volume.
  music_bus:setVolume(0.7)
end
--@api-stub: LBus:getVolume
-- Returns the volume of this bus.
do
  local music_bus = lurek.audio.newBus("music")
  music_bus:setVolume(0.7)
  lurek.log.info("bus vol=" .. music_bus:getVolume(), "audio")
end
--@api-stub: LBus:setPitch
-- Sets the pitch of this bus.
do
  local music_bus = lurek.audio.newBus("music")

  -- Pitch-shift all sources on this bus. Useful for slow-motion effects.
  music_bus:setPitch(0.85)
end
--@api-stub: LBus:getPitch
-- Returns the pitch of this bus.
do
  local music_bus = lurek.audio.newBus("music")
  music_bus:setPitch(0.85)
  lurek.log.info("bus pitch=" .. music_bus:getPitch(), "audio")
end
--@api-stub: LBus:pause
-- Pauses the current operation or playback on this bus.
do
  local music_bus = lurek.audio.newBus("music")

  -- Pauses all sources routed through this bus.
  music_bus:pause()
end
--@api-stub: LBus:resume
-- Resumes a previously paused operation or playback on this bus.
do
  local music_bus = lurek.audio.newBus("music")
  music_bus:pause()

  -- Resumes all sources that were paused by this bus.
  music_bus:resume()
end
--@api-stub: LBus:isPaused
-- Returns true if this bus paused.
do
  local music_bus = lurek.audio.newBus("music")
  music_bus:pause()
  if music_bus:isPaused() then
    lurek.log.info("music bus paused", "audio")
  end
end
--@api-stub: LBus:type
-- Returns the Lua-visible type name string for this bus handle.
do
  local music_bus = lurek.audio.newBus("music")
  lurek.log.info("type=" .. music_bus:type(), "audio")
end
--@api-stub: LBus:typeOf
-- Returns true if this bus handle matches the given type name string.
do
  local music_bus = lurek.audio.newBus("music")

  -- Accepts "LBus", "Bus", or "Object".
  if music_bus:typeOf("Bus") then
    lurek.log.info("confirmed bus type", "audio")
  end
end
--@api-stub: LBus:clearDuck
-- Clears all duck items from this bus.
do
  local voice_bus = lurek.audio.newBus("voice")

  -- Remove any ducking configuration previously set with setDuckTarget().
  voice_bus:clearDuck()
end
--@api-stub: LBus:getPeak
-- Returns the peak of this bus.
do
  local music_bus = lurek.audio.newBus("music")

  -- Peak amplitude from 0.0 to 1.0 over the last processing frame.
  lurek.log.info("peak=" .. music_bus:getPeak(), "audio")
end
--@api-stub: LMidiPlayer:load
-- Loads into this midi player.
do
  local midi_player = lurek.audio.newMidiPlayer()

  -- load() returns false when the relative file is missing or not a valid MIDI file.
  if midi_player:load("music/song.mid") then
    lurek.log.info("midi loaded successfully", "audio")
  else
    lurek.log.warn("midi file unavailable", "audio")
  end
end
--@api-stub: LMidiPlayer:loadData
-- Loads data into this midi player.
do
  local midi_player = lurek.audio.newMidiPlayer()

  -- Load MIDI from raw binary data, such as data read from a custom archive.
  local loaded = midi_player:loadData("")
  lurek.log.info("raw midi parsed=" .. tostring(loaded), "audio")
end
--@api-stub: LMidiPlayer:isLoaded
-- Returns true if this midi player loaded.
do
  local midi_player = lurek.audio.newMidiPlayer("music/song.mid")

  -- Always check before playback because the file might not exist.
  if midi_player:isLoaded() then
    midi_player:play()
  end
end
--@api-stub: LMidiPlayer:getFilePath
-- Returns the file path of this midi player.
do
  local midi_player = lurek.audio.newMidiPlayer("music/song.mid")
  local path = midi_player:getFilePath()
  if path then
    lurek.log.info("loaded midi=" .. path, "audio")
  end
end
--@api-stub: LMidiPlayer:setSoundFont
-- Sets the sound font of this midi player.
do
  local midi_player = lurek.audio.newMidiPlayer("music/song.mid")

  -- Per-player SoundFont selection is currently a stub; global setMidiSoundFont controls synthesis.
  midi_player:setSoundFont("music/orchestra.sf2")
end
--@api-stub: LMidiPlayer:getSoundFontPath
-- Returns the sound font path of this midi player.
do
  local midi_player = lurek.audio.newMidiPlayer("music/song.mid")
  local soundfont_path = midi_player:getSoundFontPath()
  lurek.log.info("player soundfont=" .. tostring(soundfont_path), "audio")
end
--@api-stub: LMidiPlayer:useDefaultSoundFont
-- Performs the use default sound font operation on this midi player.
do
  local midi_player = lurek.audio.newMidiPlayer("music/song.mid")

  -- Per-player default SoundFont selection is a no-op stub in the current binding.
  midi_player:useDefaultSoundFont()
end
--@api-stub: LMidiPlayer:play
-- Starts MIDI playback from the current position.
do
  local midi_player = lurek.audio.newMidiPlayer("music/song.mid")
  midi_player:setLooping(true)
  midi_player:play()
end
--@api-stub: LMidiPlayer:pause
-- Pauses the current operation or playback on this midi player.
do
  local midi_player = lurek.audio.newMidiPlayer("music/song.mid")
  midi_player:play()

  -- Pauses at current position. All active notes are silenced.
  midi_player:pause()
end
--@api-stub: LMidiPlayer:stop
-- Stops the current operation or playback on this midi player.
do
  local midi_player = lurek.audio.newMidiPlayer("music/song.mid")
  midi_player:play()

  -- Stops and rewinds to the beginning.
  midi_player:stop()
end
--@api-stub: LMidiPlayer:isPlaying
-- Returns true if this midi player playing.
do
  local midi_player = lurek.audio.newMidiPlayer("music/song.mid")
  midi_player:play()
  lurek.log.info("midi is active=" .. tostring(midi_player:isPlaying()), "audio")
end
--@api-stub: LMidiPlayer:isPaused
-- Returns true if this midi player paused.
do
  local midi_player = lurek.audio.newMidiPlayer("music/song.mid")
  midi_player:play()
  midi_player:pause()
  if midi_player:isPaused() then
    midi_player:play()
  end
end
--@api-stub: LMidiPlayer:seek
-- Seeks to a position in the MIDI file.
do
  local midi_player = lurek.audio.newMidiPlayer("music/song.mid")
  midi_player:play()

  -- Jump to 30 seconds into the MIDI file.
  midi_player:seek(30.0)
end
--@api-stub: LMidiPlayer:tell
-- Returns the current MIDI playback position in seconds.
do
  local midi_player = lurek.audio.newMidiPlayer("music/song.mid")
  midi_player:play()
  lurek.log.info("midi position=" .. tostring(midi_player:tell()) .. "s", "audio")
end
--@api-stub: LMidiPlayer:getDuration
-- Returns the duration of the loaded MIDI file in seconds.
do
  local midi_player = lurek.audio.newMidiPlayer("music/song.mid")
  lurek.log.info("midi duration=" .. tostring(midi_player:getDuration()) .. "s", "audio")
end
--@api-stub: LMidiPlayer:setLooping
-- Sets the looping of this midi player.
do
  local midi_player = lurek.audio.newMidiPlayer("music/song.mid")

  -- Loop playback so the track restarts when it ends.
  midi_player:setLooping(true)
end
--@api-stub: LMidiPlayer:isLooping
-- Returns true if this midi player looping.
do
  local midi_player = lurek.audio.newMidiPlayer("music/song.mid")
  midi_player:setLooping(true)
  if midi_player:isLooping() then
    lurek.log.info("midi will loop", "audio")
  end
end
--@api-stub: LMidiPlayer:setVolume
-- Sets the volume of this midi player.
do
  local midi_player = lurek.audio.newMidiPlayer("music/song.mid")

  -- Master volume for all MIDI synthesis output.
  midi_player:setVolume(0.7)
end
--@api-stub: LMidiPlayer:getVolume
-- Returns the volume of this midi player.
do
  local midi_player = lurek.audio.newMidiPlayer("music/song.mid")
  midi_player:setVolume(0.7)
  lurek.log.info("midi volume=" .. midi_player:getVolume(), "audio")
end
--@api-stub: LMidiPlayer:setBus
-- Sets the bus of this midi player.
do
  local music_bus = lurek.audio.newBus("music")
  local midi_player = lurek.audio.newMidiPlayer("music/song.mid")

  -- Route MIDI output through the music bus for grouped volume control.
  midi_player:setBus(music_bus)
end
--@api-stub: LMidiPlayer:getBus
-- Returns the bus of this midi player.
do
  local music_bus = lurek.audio.newBus("music")
  local midi_player = lurek.audio.newMidiPlayer("music/song.mid")
  midi_player:setBus(music_bus)

  local current_bus = midi_player:getBus()
  if current_bus then
    lurek.log.info("midi bus=" .. current_bus:getName(), "audio")
  end
end
--@api-stub: LMidiPlayer:setTempo
-- Sets the tempo of this midi player.
do
  local midi_player = lurek.audio.newMidiPlayer("music/song.mid")

  -- Override the MIDI file tempo. Value is in BPM.
  midi_player:setTempo(140)
end
--@api-stub: LMidiPlayer:getTempo
-- Returns the tempo of this midi player.
do
  local midi_player = lurek.audio.newMidiPlayer("music/song.mid")
  midi_player:setTempo(140)
  lurek.log.info("bpm=" .. midi_player:getTempo(), "audio")
end
--@api-stub: LMidiPlayer:getOriginalTempo
-- Returns the original tempo of this midi player.
do
  local midi_player = lurek.audio.newMidiPlayer("music/song.mid")

  -- Tempo as authored in the MIDI file before setTempo or setTempoScale.
  lurek.log.info("original bpm=" .. midi_player:getOriginalTempo(), "audio")
end
--@api-stub: LMidiPlayer:setTempoScale
-- Sets the tempo scale of this midi player.
do
  local midi_player = lurek.audio.newMidiPlayer("music/song.mid")

  -- Scale relative to original: 1.0 normal, 0.5 half speed, 2.0 double speed.
  midi_player:setTempoScale(0.85)
end
--@api-stub: LMidiPlayer:getTempoScale
-- Returns the tempo scale of this midi player.
do
  local midi_player = lurek.audio.newMidiPlayer("music/song.mid")
  midi_player:setTempoScale(0.85)
  lurek.log.info("tempo scale=" .. midi_player:getTempoScale(), "audio")
end
--@api-stub: LMidiPlayer:getTicksPerBeat
-- Returns the ticks per beat of this midi player.
do
  local midi_player = lurek.audio.newMidiPlayer("music/song.mid")

  -- PPQN is the MIDI file timing resolution.
  lurek.log.info("ppq=" .. midi_player:getTicksPerBeat(), "audio")
end
--@api-stub: LMidiPlayer:setChannelVolume
-- Sets the channel volume of this midi player.
do
  local midi_player = lurek.audio.newMidiPlayer("music/song.mid")

  -- Channel 10 is usually drums in General MIDI. Lower its volume.
  midi_player:setChannelVolume(10, 0.4)
end
--@api-stub: LMidiPlayer:getChannelVolume
-- Returns the channel volume of this midi player.
do
  local midi_player = lurek.audio.newMidiPlayer("music/song.mid")
  midi_player:setChannelVolume(10, 0.4)
  lurek.log.info("drums vol=" .. midi_player:getChannelVolume(10), "audio")
end
--@api-stub: LMidiPlayer:setChannelMuted
-- Sets the channel muted of this midi player.
do
  local midi_player = lurek.audio.newMidiPlayer("music/song.mid")

  -- Mute the drum channel for a quieter arrangement.
  midi_player:setChannelMuted(10, true)
end
--@api-stub: LMidiPlayer:isChannelMuted
-- Returns true if this midi player channel muted.
do
  local midi_player = lurek.audio.newMidiPlayer("music/song.mid")
  midi_player:setChannelMuted(10, true)
  if midi_player:isChannelMuted(10) then
    lurek.log.info("drums muted", "audio")
  end
end
--@api-stub: LMidiPlayer:getChannelInstrument
-- Returns the channel instrument of this midi player.
do
  local midi_player = lurek.audio.newMidiPlayer("music/song.mid")

  -- Returns the General MIDI program number from 0 to 127 for channel 1.
  local instrument = midi_player:getChannelInstrument(1)
  lurek.log.info("ch1 instrument=" .. instrument, "audio")
end
--@api-stub: LMidiPlayer:getChannelCount
-- Returns the number of channel items in this midi player.
do
  local midi_player = lurek.audio.newMidiPlayer("music/song.mid")

  -- How many of the 16 MIDI channels have note data.
  lurek.log.info("active channels=" .. midi_player:getChannelCount(), "audio")
end
--@api-stub: LMidiPlayer:soloChannel
-- Performs the solo channel operation on this midi player.
do
  local midi_player = lurek.audio.newMidiPlayer("music/song.mid")

  -- Solo channel 1 to isolate an instrument during development.
  midi_player:soloChannel(1)
end
--@api-stub: LMidiPlayer:unsoloAll
-- Performs the unsolo all operation on this midi player.
do
  local midi_player = lurek.audio.newMidiPlayer("music/song.mid")
  midi_player:soloChannel(1)

  -- Restore normal playback so all channels are audible again.
  midi_player:unsoloAll()
end
--@api-stub: LMidiPlayer:getTrackCount
-- Returns the number of track items in this midi player.
do
  local midi_player = lurek.audio.newMidiPlayer("music/song.mid")
  lurek.log.info("midi tracks=" .. midi_player:getTrackCount(), "audio")
end
--@api-stub: LMidiPlayer:getTrackName
-- Returns the track name of this midi player.
do
  local midi_player = lurek.audio.newMidiPlayer("music/song.mid")

  -- Track names are metadata embedded in the MIDI file.
  local track_name = midi_player:getTrackName(1)
  if track_name then
    lurek.log.info("track 1=" .. track_name, "audio")
  end
end
--@api-stub: LMidiPlayer:setTrackMuted
-- Sets the track muted of this midi player.
do
  local midi_player = lurek.audio.newMidiPlayer("music/song.mid")

  -- Mute track 2 using a 1-based track index.
  midi_player:setTrackMuted(2, true)
end
--@api-stub: LMidiPlayer:isTrackMuted
-- Returns true if this midi player track muted.
do
  local midi_player = lurek.audio.newMidiPlayer("music/song.mid")
  midi_player:setTrackMuted(2, true)
  if midi_player:isTrackMuted(2) then
    lurek.log.info("track 2 muted", "audio")
  end
end
--@api-stub: LMidiPlayer:getNoteCount
-- Returns the number of note items in this midi player.
do
  local midi_player = lurek.audio.newMidiPlayer("music/song.mid")

  -- Total note-on events in the file, useful for progress displays.
  lurek.log.info("total notes=" .. midi_player:getNoteCount(), "audio")
end
--@api-stub: LMidiPlayer:setOnNoteOn
-- Sets the on note on of this midi player.
do
  local midi_player = lurek.audio.newMidiPlayer("music/song.mid")

  -- Callback registration is currently a stub but keeps the intended call shape visible.
  midi_player:setOnNoteOn(function(channel, note)
    lurek.log.info("note on ch=" .. channel .. " note=" .. note, "audio")
  end)
end
--@api-stub: LMidiPlayer:setOnNoteOff
-- Sets the on note off of this midi player.
do
  local midi_player = lurek.audio.newMidiPlayer("music/song.mid")

  -- Callback registration is currently a stub but mirrors note-off event shape.
  midi_player:setOnNoteOff(function(channel, note)
    lurek.log.info("note off ch=" .. channel .. " note=" .. note, "audio")
  end)
end
--@api-stub: LMidiPlayer:setOnEnd
-- Sets the on end of this midi player.
do
  local midi_player = lurek.audio.newMidiPlayer("music/song.mid")

  -- Callback registration is currently a stub but keeps the end-event shape visible.
  midi_player:setOnEnd(function()
    lurek.log.info("midi playback finished", "audio")
  end)
end
--@api-stub: LMidiPlayer:getSampleRate
-- Returns the sample rate of this midi player.
do
  local midi_player = lurek.audio.newMidiPlayer("music/song.mid")

  -- The synthesis output rate, commonly 44100 Hz or 48000 Hz.
  lurek.log.info("midi output rate=" .. midi_player:getSampleRate() .. " Hz", "audio")
end
--@api-stub: LMidiPlayer:setSampleRate
-- Sets the sample rate of this midi player.
do
  local midi_player = lurek.audio.newMidiPlayer("music/song.mid")

  -- Change synthesis rate. Higher values can cost more CPU.
  midi_player:setSampleRate(48000)
end
--@api-stub: LMidiPlayer:getChannels
-- Returns the channels of this midi player.
do
  local midi_player = lurek.audio.newMidiPlayer("music/song.mid")

  -- Output audio channels: 1 is mono, 2 is stereo.
  lurek.log.info("output channels=" .. midi_player:getChannels(), "audio")
end
--@api-stub: LMidiPlayer:setChannels
-- Sets the channels of this midi player.
do
  local midi_player = lurek.audio.newMidiPlayer("music/song.mid")

  -- Force stereo output.
  midi_player:setChannels(2)
end
--@api-stub: LMidiPlayer:type
-- Returns the Lua-visible type name string for this midi player handle.
do
  local midi_player = lurek.audio.newMidiPlayer("music/song.mid")
  lurek.log.info("type=" .. midi_player:type(), "audio")
end
--@api-stub: LMidiPlayer:typeOf
-- Returns true if this midi player handle matches the given type name string.
do
  local midi_player = lurek.audio.newMidiPlayer("music/song.mid")
  if midi_player:typeOf("MidiPlayer") then
    lurek.log.info("confirmed MidiPlayer", "audio")
  end
end
--@api-stub: LSoundPool:play
-- Starts playback of on this sound pool.
do
  local ok_pool, footstep_pool = pcall(lurek.audio.newPool, "sfx/footstep.ogg", 8)
  if ok_pool then
    -- play() fires the next available voice in round-robin order.
    local voice_id = footstep_pool:play()
    lurek.log.info("voice id=" .. voice_id, "audio")
  end
end
--@api-stub: LSoundPool:stopAll
-- Stops the current operation or playback on this sound pool.
do
  local ok_pool, footstep_pool = pcall(lurek.audio.newPool, "sfx/footstep.ogg", 8)
  if ok_pool then
    footstep_pool:play()

    -- Silences all active voices in the pool at once.
    footstep_pool:stopAll()
  end
end
--@api-stub: LSoundPool:setVolume
-- Sets the volume of this sound pool.
do
  local ok_pool, footstep_pool = pcall(lurek.audio.newPool, "sfx/footstep.ogg", 8)
  if ok_pool then
    -- Sets volume for all voices in the pool.
    footstep_pool:setVolume(0.7)
  end
end
--@api-stub: LSoundPool:setBus
-- Sets the bus of this sound pool.
do
  lurek.audio.create_bus("sfx")
  local ok_pool, footstep_pool = pcall(lurek.audio.newPool, "sfx/footstep.ogg", 8)
  if ok_pool then
    -- Route all pool voices through the named bus.
    footstep_pool:setBus("sfx")
  end
end
--@api-stub: LSoundPool:release
-- Releases all voices and audio resources held by this sound pool.
do
  local ok_pool, footstep_pool = pcall(lurek.audio.newPool, "sfx/footstep.ogg", 8)
  if ok_pool then
    footstep_pool:release()
  end
end
--@api-stub: LSoundPool:getVoiceCount
-- Returns the number of voice items in this sound pool.
do
  local ok_pool, footstep_pool = pcall(lurek.audio.newPool, "sfx/footstep.ogg", 8)
  if ok_pool then
    -- Returns the total number of pre-allocated voices, not just active ones.
    lurek.log.info("pool voices=" .. footstep_pool:getVoiceCount(), "audio")
  end
end
--@api-stub: LSoundPool:type
-- Returns the Lua-visible type name string for this sound pool handle.
do
  local ok_pool, footstep_pool = pcall(lurek.audio.newPool, "sfx/footstep.ogg", 8)
  if ok_pool then
    lurek.log.info("type=" .. footstep_pool:type(), "audio")
  end
end
--@api-stub: LSoundPool:typeOf
-- Returns true if this sound pool handle matches the given type name string.
do
  local ok_pool, footstep_pool = pcall(lurek.audio.newPool, "sfx/footstep.ogg", 8)
  if ok_pool and footstep_pool:typeOf("SoundPool") then
    lurek.log.info("confirmed pool type", "audio")
  end
end
--@api-stub: LDecoder:decode
-- Performs the decode operation on this decoder.
do
  local ok_decoder, decoder = pcall(lurek.audio.newDecoder, "music/long_track.ogg", 4096)
  if ok_decoder then
    -- Decodes the next chunk of PCM data. Returns LSoundData or nil at end of stream.
    local chunk = decoder:decode()
    if chunk then
      lurek.log.info("decoded " .. chunk:getSampleCount() .. " samples", "audio")
    end
  end
end
--@api-stub: LDecoder:getChannelCount
-- Returns the number of channel items in this decoder.
do
  local ok_decoder, decoder = pcall(lurek.audio.newDecoder, "music/long_track.ogg", 4096)
  if ok_decoder then
    -- 1 is mono, 2 is stereo. Matches the source file channel layout.
    lurek.log.info("decoder channels=" .. decoder:getChannelCount(), "audio")
  end
end
--@api-stub: LDecoder:getBitDepth
-- Returns the bit depth of this decoder.
do
  local ok_decoder, decoder = pcall(lurek.audio.newDecoder, "music/long_track.ogg", 4096)
  if ok_decoder then
    -- Typically 16 or 24 bits per sample.
    lurek.log.info("bit depth=" .. decoder:getBitDepth(), "audio")
  end
end
--@api-stub: LDecoder:getSampleRate
-- Returns the sample rate of this decoder.
do
  local ok_decoder, decoder = pcall(lurek.audio.newDecoder, "music/long_track.ogg", 4096)
  if ok_decoder then
    lurek.log.info("sample rate=" .. decoder:getSampleRate() .. " Hz", "audio")
  end
end
--@api-stub: LDecoder:getDuration
-- Returns the duration of this decoder.
do
  local ok_decoder, decoder = pcall(lurek.audio.newDecoder, "music/long_track.ogg", 4096)
  if ok_decoder then
    lurek.log.info("file duration=" .. decoder:getDuration() .. "s", "audio")
  end
end
--@api-stub: LDecoder:seek
-- Performs the seek operation on this decoder.
do
  local ok_decoder, decoder = pcall(lurek.audio.newDecoder, "music/long_track.ogg", 4096)
  if ok_decoder then
    -- Jump to 15 seconds. Next decode() returns data from this position.
    decoder:seek(15.0)
  end
end
--@api-stub: LDecoder:rewind
-- Performs the rewind operation on this decoder.
do
  local ok_decoder, decoder = pcall(lurek.audio.newDecoder, "music/long_track.ogg", 4096)
  if ok_decoder then
    decoder:seek(15.0)

    -- Reset to the beginning without recreating the decoder.
    decoder:rewind()
  end
end
--@api-stub: LDecoder:tell
-- Performs the tell operation on this decoder.
do
  local ok_decoder, decoder = pcall(lurek.audio.newDecoder, "music/long_track.ogg", 4096)
  if ok_decoder then
    -- Returns current read position in seconds.
    lurek.log.info("decoder at=" .. decoder:tell() .. "s", "audio")
  end
end
--@api-stub: LDecoder:isSeekable
-- Returns true if this decoder seekable.
do
  local ok_decoder, decoder = pcall(lurek.audio.newDecoder, "music/long_track.ogg", 4096)
  if ok_decoder and decoder:isSeekable() then
    decoder:seek(15.0)
  end
end
--@api-stub: LDecoder:release
-- Performs the release operation on this decoder.
do
  local ok_decoder, decoder = pcall(lurek.audio.newDecoder, "music/long_track.ogg", 4096)
  if ok_decoder then
    -- release() is a no-op today, kept for API symmetry.
    decoder:release()
  end
end
--@api-stub: LSoundData:getSampleCount
-- Returns the number of sample values in this sound buffer.
do
  local sound_data = lurek.audio.newSineWave(440.0, 1.0, 44100, 0.5)

  -- For 1 second at 44100 Hz mono, this is 44100 samples.
  lurek.log.info("samples=" .. sound_data:getSampleCount(), "audio")
end
--@api-stub: LSoundData:getSampleRate
-- Returns the sample rate of this sound buffer.
do
  local sound_data = lurek.audio.newSineWave(440.0, 1.0, 44100, 0.5)
  lurek.log.info("rate=" .. sound_data:getSampleRate() .. " Hz", "audio")
end
--@api-stub: LSoundData:getChannelCount
-- Returns the number of channels in this sound buffer.
do
  local sound_data = lurek.audio.newSineWave(440.0, 1.0, 44100, 0.5)
  lurek.log.info("channels=" .. sound_data:getChannelCount(), "audio")
end
--@api-stub: LSoundData:getDuration
-- Returns the duration of this sound buffer.
do
  local sound_data = lurek.audio.newSineWave(440.0, 1.0, 44100, 0.5)
  lurek.log.info("duration=" .. sound_data:getDuration() .. "s", "audio")
end
--@api-stub: LSoundData:getBitDepth
-- Returns the bit depth of this sound buffer.
do
  local sound_data = lurek.audio.newSineWave(440.0, 1.0, 44100, 0.5)
  lurek.log.info("bit depth=" .. sound_data:getBitDepth(), "audio")
end
--@api-stub: LSoundData:getSample
-- Returns the normalized sample value at a zero-based index.
do
  local sound_data = lurek.audio.newSineWave(440.0, 1.0, 44100, 0.5)

  -- Values are normalized floats in the range -1.0 to 1.0.
  local sample_value = sound_data:getSample(0)
  lurek.log.info("sample[0]=" .. tostring(sample_value), "audio")
end
--@api-stub: LSoundData:setSample
-- Writes a normalized sample value at a zero-based index.
do
  local sound_data = lurek.audio.newSineWave(440.0, 1.0, 44100, 0.5)

  -- Direct sample editing is useful for procedural tones or custom effects.
  sound_data:setSample(0, 0.0)
  lurek.log.info("sample[0] after write=" .. tostring(sound_data:getSample(0)), "audio")
end
--@api-stub: LSoundData:drawWaveform
-- Draws this sound buffer into an image buffer.
do
  local sound_data = lurek.audio.newSoundData(44100, 44100, 1)
  local image_data = lurek.image.newImageData(512, 64)

  -- Args: target image, x, y, width, height, r, g, b, a.
  sound_data:drawWaveform(image_data, 0, 0, 512, 64, 255, 255, 255, 255)
  lurek.log.info("waveform rendered to " .. image_data:getWidth() .. "px", "audio")
end
--@api-stub: LMidiPlayer:setChannelInstrument
-- Sets the channel instrument of this midi player.
do
  local midi_player = lurek.audio.newMidiPlayer()

  -- Channels are 1-based. Program 41 is violin in General MIDI tables.
  midi_player:setChannelInstrument(1, 41)
  lurek.log.info("ch1 instrument=" .. midi_player:getChannelInstrument(1), "audio")
end
--@api-stub: LBus:setDuckTarget
-- Sets the duck target of this bus.
do
  lurek.audio.newBus("music")
  local voice_bus = lurek.audio.newBus("voice")

  -- Duck music to 30% while voice bus output is active.
  voice_bus:setDuckTarget("music", 0.3)
  lurek.log.info("voice bus ducks music", "audio")
end
--@api-stub: LSoundData:drawWaveform
-- Draws this sound buffer into an image buffer.
do
  local sound_data = lurek.audio.newSineWave(440, 0.5, 44100, 0.5)
  local image_data = lurek.image.newImageData(256, 64)

  -- Render a white waveform into the image buffer for visualization.
  sound_data:drawWaveform(image_data, 0, 0, 256, 64, 255, 255, 255, 255)
  lurek.log.info("waveform drawn to image", "audio")
end
--@api-stub: LDecoder:type
-- Returns the decoder type name for runtime checks.
do
  local ok_decoder, decoder = pcall(lurek.audio.newDecoder, "assets/sound.ogg", 4096)
  if ok_decoder then
    lurek.log.info("LDecoder:type = " .. decoder:type(), "audio")
  end
end
--@api-stub: LDecoder:typeOf
-- Checks whether this decoder matches the given type name.
do
  local ok_decoder, decoder = pcall(lurek.audio.newDecoder, "assets/sound.ogg", 4096)
  if ok_decoder then
    lurek.log.info("is LDecoder: " .. tostring(decoder:typeOf("LDecoder")), "audio")
    lurek.log.info("is wrong: " .. tostring(decoder:typeOf("Unknown")), "audio")
  end
end
--@api-stub: LSoundData:getSampleCount
-- Returns the total number of samples stored in this sound buffer
do
  local sd = lurek.audio.newSineWave(440, 1.0, 44100, 0.5)
  lurek.log.info("sample_count=" .. sd:getSampleCount(), "audio")
end
--@api-stub: LSoundData:getSampleRate
-- Returns the playback sample rate of this sound buffer
do
  local sd = lurek.audio.newSineWave(440, 0.5, 44100, 0.5)
  lurek.log.info("sample_rate=" .. sd:getSampleRate(), "audio")
end
--@api-stub: LSoundData:getChannelCount
-- Returns the number of audio channels stored in this sound buffer
do
  local sd = lurek.audio.newSineWave(440, 0.5, 44100, 0.5)
  lurek.log.info("channels=" .. sd:getChannelCount(), "audio")
end
--@api-stub: LSoundData:getDuration
-- Returns the approximate playback duration of this sound buffer
do
  local sd = lurek.audio.newSineWave(440, 2.0, 44100, 0.5)
  lurek.log.info("duration=" .. sd:getDuration() .. "s", "audio")
end
--@api-stub: LSoundData:getBitDepth
-- Returns the sample bit depth of this sound buffer
do
  local sd = lurek.audio.newSineWave(440, 0.5, 44100, 0.5)
  lurek.log.info("bit_depth=" .. sd:getBitDepth(), "audio")
end
--@api-stub: LSoundData:getSample
-- Returns the sample value at the given zero-based sample index
do
  local sd = lurek.audio.newSineWave(440, 1.0, 44100, 0.5)

  -- Zero-based index. Returns normalized float value (-1.0 to 1.0).
  local s = sd:getSample(1)
  lurek.log.info("sample[1]=" .. tostring(s), "audio")
end
--@api-stub: LSoundData:drawWaveform
-- Draws this sound buffer as a waveform into an image buffer
do
  local sd = lurek.audio.newSineWave(440, 0.5, 44100, 0.5)
  local idata = lurek.image.newImageData(256, 64)

  -- Render a green waveform at position (0,0) with size 256x64 pixels.
  -- Useful for audio editors, level meters, or debug visualization.
  sd:drawWaveform(idata, 0, 0, 256, 64, 0, 255, 0, 255)
  lurek.log.info("waveform drawn to image 256x64", "audio")
end
--@api-stub: LSoundData:setSample
-- Overwrites the sample value at the given zero-based sample index
do
  local sd = lurek.audio.newSineWave(440, 0.5, 44100, 0.5)

  -- Zero out the first sample; direct buffer manipulation for procedural audio.
  sd:setSample(0, 0.0)
  lurek.log.info("sample[0] after zero=" .. sd:getSample(0), "audio")
end
--@api-stub: LSource:type
-- Returns the type name of this source object.
do
  local ok_source, source = pcall(lurek.audio.newSource, "sfx/jump.ogg", "static")
  if ok_source then
    lurek.log.info("LSource:type = " .. source:type(), "audio")
  end
end
--@api-stub: LSource:typeOf
-- Checks whether this source matches a type name.
do
  local ok_source, source = pcall(lurek.audio.newSource, "sfx/jump.ogg", "static")
  if ok_source then
    lurek.log.info("is LSource: " .. tostring(source:typeOf("LSource")), "audio")
    lurek.log.info("is wrong: " .. tostring(source:typeOf("Unknown")), "audio")
  end
end
--@api-stub: LBus:setVolume
-- Sets the volume multiplier for all sources routed through this bus.
do
  -- Control group volume for options menu sliders (music/sfx/voice).
  local bus = lurek.audio.newBus("sfx")
  bus:setVolume(0.6)
  lurek.log.info("sfx bus volume set to 0.6", "audio")
end
--@api-stub: LBus:getVolume
-- Returns the current volume multiplier of this bus.
do
  -- Read bus volume to display the current setting in a HUD slider.
  local bus = lurek.audio.newBus("music")
  bus:setVolume(0.8)
  local vol = bus:getVolume()
  lurek.log.info("music bus volume=" .. vol, "audio")
end
--@api-stub: LBus:pause
-- Pauses all sources routed through this bus.
do
  -- Pause all music when opening the inventory screen.
  local bus = lurek.audio.newBus("music")
  bus:pause()
  lurek.log.info("music bus paused", "audio")
end
--@api-stub: LBus:isPaused
-- Returns whether this bus is currently paused.
do
  -- Toggle bus pause state with a single key.
  local bus = lurek.audio.newBus("music")
  bus:pause()
  if bus:isPaused() then
    lurek.log.info("music is paused, press P to resume", "audio")
  end
end
--@api-stub: LBus:type
-- Returns the type name of this object for runtime type-checking.
do
  -- Confirm the handle type before calling bus-specific methods.
  local bus = lurek.audio.newBus("sfx")
  lurek.log.info("handle type: " .. bus:type(), "audio")
end
--@api-stub: LBus:typeOf
-- Checks whether this object matches the given type name.
do
  -- Runtime type-guard in generic audio management functions.
  local bus = lurek.audio.newBus("sfx")
  if bus:typeOf("LBus") then
    lurek.log.info("confirmed LBus handle", "audio")
  end
end
--@api-stub: LDecoder:getChannelCount
-- Returns the number of audio channels in the source file.
do
  -- Check channel count to detect mono vs stereo for spatial audio decisions.
  local ok_dec, dec = pcall(lurek.audio.newDecoder, "music/theme.ogg", 4096)
  if ok_dec then
    local ch = dec:getChannelCount()
    lurek.log.info("channels=" .. ch, "audio")
  end
end
--@api-stub: LDecoder:getBitDepth
-- Returns the bit depth of the source audio file.
do
  -- Verify bit depth for quality reporting or format validation.
  local ok_dec, dec = pcall(lurek.audio.newDecoder, "sfx/explosion.ogg", 4096)
  if ok_dec then
    local bits = dec:getBitDepth()
    lurek.log.info("bit depth=" .. bits, "audio")
  end
end
--@api-stub: LDecoder:getSampleRate
-- Returns the sample rate of the source audio file.
do
  -- Confirm sample rate matches your output device for clean playback.
  local ok_dec, dec = pcall(lurek.audio.newDecoder, "music/theme.ogg", 4096)
  if ok_dec then
    local rate = dec:getSampleRate()
    lurek.log.info("sample rate=" .. rate .. " Hz", "audio")
  end
end
--@api-stub: LDecoder:getDuration
-- Returns the total duration of the source audio file in seconds.
do
  -- Use duration to display track length in a music player UI.
  local ok_dec, dec = pcall(lurek.audio.newDecoder, "music/theme.ogg", 4096)
  if ok_dec then
    local dur = dec:getDuration()
    lurek.log.info("track duration=" .. dur .. "s", "audio")
  end
end
--@api-stub: LMidiPlayer:play
-- Starts MIDI playback from the current position using the audio output stream.
do
  -- Start MIDI playback for background music in a retro-style RPG.
  local ok_mp, mp = pcall(lurek.audio.newMidiPlayer, "music/battle.mid")
  if ok_mp then
    mp:play()
    lurek.log.info("MIDI playback started", "audio")
  end
end
--@api-stub: LMidiPlayer:seek
-- Seeks to a specific position in the MIDI file.
do
  -- Jump to the chorus section of a MIDI track for a boss encounter intro.
  local midi_player = lurek.audio.newMidiPlayer("music/boss.mid")
  midi_player:play()
  midi_player:seek(12.5)
  lurek.log.info("seeked to 12.5s", "audio")
end
--@api-stub: LMidiPlayer:tell
-- Returns the current playback position of the MIDI player in seconds.
do
  -- Display current MIDI position for a music visualizer or progress bar.
  local mp = lurek.audio.newMidiPlayer("music/town.mid")
  mp:play()
  local pos = mp:tell()
  lurek.log.info("MIDI position=" .. pos .. "s", "audio")
end
--@api-stub: LMidiPlayer:getDuration
-- Returns the total duration of the loaded MIDI file in seconds.
do
  -- Show total track length in the jukebox UI.
  local mp = lurek.audio.newMidiPlayer("music/credits.mid")
  local dur = mp:getDuration()
  lurek.log.info("MIDI duration=" .. dur .. "s", "audio")
end
--@api-stub: LMidiPlayer:setVolume
-- Sets the master volume for MIDI playback.
do
  -- Lower MIDI volume when voice dialog is playing.
  local mp = lurek.audio.newMidiPlayer("music/town.mid")
  mp:setVolume(0.4)
  mp:play()
  lurek.log.info("MIDI volume set to 0.4", "audio")
end
--@api-stub: LMidiPlayer:setBus
-- Routes this MIDI player's output through the specified audio bus.
do
  -- Route MIDI through the music bus so the options slider controls it.
  local music_bus = lurek.audio.newBus("music")
  local mp = lurek.audio.newMidiPlayer("music/town.mid")
  mp:setBus(music_bus)
  mp:play()
  lurek.log.info("MIDI routed through music bus", "audio")
end
--@api-stub: LMidiPlayer:getChannelCount
-- Returns the number of active MIDI channels in the loaded file.
do
  -- Check channel count for complexity analysis or debug display.
  local mp = lurek.audio.newMidiPlayer("music/orchestra.mid")
  local ch = mp:getChannelCount()
  lurek.log.info("MIDI channels=" .. ch, "audio")
end
--@api-stub: LMidiPlayer:getSampleRate
-- Returns the output sample rate used for MIDI synthesis.
do
  -- Verify synthesis rate matches the audio device for clean output.
  local mp = lurek.audio.newMidiPlayer("music/town.mid")
  local rate = mp:getSampleRate()
  lurek.log.info("MIDI synthesis rate=" .. rate .. " Hz", "audio")
end
--@api-stub: LMidiPlayer:type
-- Returns the type name of this object for runtime type-checking.
do
  -- Confirm handle type before calling MIDI-specific methods.
  local mp = lurek.audio.newMidiPlayer("music/town.mid")
  lurek.log.info("handle type: " .. mp:type(), "audio")
end
--@api-stub: LMidiPlayer:typeOf
-- Checks whether this object matches the given type name.
do
  -- Type-guard for generic audio handle processing.
  local mp = lurek.audio.newMidiPlayer("music/town.mid")
  if mp:typeOf("LMidiPlayer") then
    lurek.log.info("confirmed LMidiPlayer handle", "audio")
  end
end
--@api-stub: LSoundPool:release
-- Releases all voices and frees audio resources held by this pool.
do
  -- Free pool memory when leaving a scene that used rapid-fire SFX.
  local pool = lurek.audio.newPool("sfx/gunshot.ogg", 8)
  pool:release()
  lurek.log.info("sound pool released", "audio")
end
--@api-stub: LSoundPool:type
-- Returns the type name of this object for runtime type-checking.
do
  -- Check handle type for generic audio resource management.
  local pool = lurek.audio.newPool("sfx/footstep.ogg", 4)
  lurek.log.info("pool type: " .. pool:type(), "audio")
end
--@api-stub: LSoundPool:typeOf
-- Checks whether this object matches the given type name.
do
  -- Type-guard before calling pool-specific methods.
  local pool = lurek.audio.newPool("sfx/footstep.ogg", 4)
  if pool:typeOf("LSoundPool") then
    lurek.log.info("confirmed LSoundPool handle", "audio")
  end
end
--@api-stub: LSource:play
-- Starts playback of this audio source from the current position.
do
  -- Fire a one-shot SFX when the player jumps.
  local ok, s = pcall(lurek.audio.newSource, "sfx/jump.ogg", "static")
  if ok then s:play() end
end
--@api-stub: LSource:stop
-- Stops playback and resets the source position to the beginning.
do
  -- Cut off an alarm when the player reaches safety.
  local ok, s = pcall(lurek.audio.newSource, "sfx/alarm.ogg", "static")
  if ok then
    s:play()
    s:stop()
  end
end
--@api-stub: LSource:pause
-- Pauses playback at the current position, allowing later resumption.
do
  -- Freeze music when opening the pause menu.
  local ok, s = pcall(lurek.audio.newSource, "music/level.mp3")
  if ok then
    s:play()
    s:pause()
  end
end
--@api-stub: LSource:resume
-- Resumes playback from the position where the source was paused.
do
  -- Continue music when closing the pause menu.
  local ok, s = pcall(lurek.audio.newSource, "music/level.mp3")
  if ok then
    s:play()
    s:pause()
    s:resume()
  end
end
--@api-stub: LSource:setVolume
-- Sets the volume level of this source where 0.0 is silent and 1.0 is full volume.
do
  -- Set ambient rain to 40% volume so it doesn't overpower dialog.
  local ok, s = pcall(lurek.audio.newSource, "sfx/rain_loop.ogg", "static")
  if ok then
    s:setVolume(0.4)
    s:play()
  end
end
--@api-stub: LSource:getVolume
-- Returns the current volume level of this audio source.
do
  -- Read current volume to implement a fade-out step.
  local ok, s = pcall(lurek.audio.newSource, "music/level.mp3")
  if ok then
    s:setVolume(0.8)
    lurek.log.info("source vol=" .. s:getVolume(), "audio")
  end
end
--@api-stub: LSource:setPitch
-- Sets the playback speed multiplier, affecting both pitch and duration.
do
  -- Raise pitch for a speed-up power-up effect.
  local ok, s = pcall(lurek.audio.newSource, "sfx/engine.ogg", "static")
  if ok then
    s:setPitch(1.5)
    s:play()
  end
end
--@api-stub: LSource:getPitch
-- Returns the current pitch multiplier of this audio source.
do
  -- Display current pitch in a debug overlay.
  local ok, s = pcall(lurek.audio.newSource, "sfx/engine.ogg", "static")
  if ok then
    s:setPitch(1.3)
    lurek.log.info("pitch=" .. s:getPitch(), "audio")
  end
end
--@api-stub: LSource:setLooping
-- Enables or disables looping so the source restarts automatically after finishing.
do
  -- Loop ambient wind for an outdoor scene.
  local ok, s = pcall(lurek.audio.newSource, "sfx/wind.ogg", "static")
  if ok then
    s:setLooping(true)
    s:play()
  end
end
--@api-stub: LSource:isLooping
-- Returns whether this source is set to loop continuously.
do
  -- Verify loop state before deciding to restart manually.
  local ok, s = pcall(lurek.audio.newSource, "music/level.mp3")
  if ok then
    s:setLooping(true)
    if s:isLooping() then lurek.log.info("source loops", "audio") end
  end
end
--@api-stub: LSource:isPlaying
-- Returns whether this source is currently playing audio.
do
  -- Only trigger a new SFX if the previous one finished.
  local ok, s = pcall(lurek.audio.newSource, "sfx/sting.ogg", "static")
  if ok then
    s:play()
    if s:isPlaying() then lurek.log.info("sting active", "audio") end
  end
end
--@api-stub: LSource:isPaused
-- Returns whether this source is currently paused.
do
  -- Toggle pause/resume with a single call.
  local ok, s = pcall(lurek.audio.newSource, "music/level.mp3")
  if ok then
    s:play()
    s:pause()
    if s:isPaused() then s:resume() end
  end
end
--@api-stub: LSource:getDuration
-- Returns the total duration of this audio source in seconds.
do
  -- Show track length in the music player UI.
  local ok, s = pcall(lurek.audio.newSource, "music/level.mp3")
  if ok then
    lurek.log.info("duration=" .. (s:getDuration() or 0) .. "s", "audio")
  end
end
--@api-stub: LSource:tell
-- Returns the current playback position of this source in seconds.
do
  -- Sync game events to music position.
  local ok, s = pcall(lurek.audio.newSource, "music/level.mp3")
  if ok then
    s:play()
    lurek.log.info("position=" .. s:tell() .. "s", "audio")
  end
end
--@api-stub: LSource:seek
-- Seeks to a specific position in seconds within this audio source.
do
  -- Skip the intro and jump to 10 seconds in.
  local ok, s = pcall(lurek.audio.newSource, "music/level.mp3")
  if ok then
    s:play()
    s:seek(10.0)
  end
end
--@api-stub: lurek.audio.setVolume
-- Sets the volume of a source by handle.
do
  local ok_music, music_source = pcall(lurek.audio.newSource, "assets/audio/music.ogg", "static")
  if ok_music then
    lurek.audio.setVolume(music_source, 0.6)
    lurek.log.debug("volume set to 60%", "audio")
    lurek.audio.release(music_source)
  end
end
--@api-stub: lurek.audio.getVolume
-- Returns the current volume of a source.
do
  local ok_source, source = pcall(lurek.audio.newSource, "assets/audio/music.ogg", "static")
  if ok_source then
    lurek.audio.setVolume(source, 0.7)
    local volume = lurek.audio.getVolume(source)
    lurek.log.debug("volume: " .. tostring(volume), "audio")
    lurek.audio.release(source)
  end
end
--@api-stub: lurek.audio.setPitch
-- Sets the pitch multiplier of a source, affecting playback speed and tone.
do
  local ok_sfx, sfx_source = pcall(lurek.audio.newSource, "assets/audio/music.ogg", "static")
  if ok_sfx then
    -- Speed up the sound; higher pitch is faster.
    lurek.audio.setPitch(sfx_source, 1.25)
    lurek.log.debug("pitch set to 1.25", "audio")
    lurek.audio.release(sfx_source)
  end
end
--@api-stub: lurek.audio.getPitch
-- Returns the current pitch multiplier of a source.
do
  local ok_source, source = pcall(lurek.audio.newSource, "assets/audio/music.ogg", "static")
  if ok_source then
    lurek.audio.setPitch(source, 1.5)
    local pitch = lurek.audio.getPitch(source)
    lurek.log.debug("pitch: " .. tostring(pitch), "audio")
    lurek.audio.release(source)
  end
end
--@api-stub: lurek.audio.isPlaying
-- Returns whether a source is currently playing.
do
  local ok_source, source = pcall(lurek.audio.newSource, "assets/audio/music.ogg", "static")
  if ok_source then
    lurek.audio.play(source)
    local playing = lurek.audio.isPlaying(source)
    lurek.log.debug("isPlaying: " .. tostring(playing), "audio")
    lurek.audio.stop(source)
    lurek.audio.release(source)
  end
end
--@api-stub: lurek.audio.isPaused
-- Returns whether a source is currently paused.
do
  local ok_source, source = pcall(lurek.audio.newSource, "assets/audio/music.ogg", "static")
  if ok_source then
    lurek.audio.play(source)
    lurek.audio.pause(source)
    local paused = lurek.audio.isPaused(source)
    lurek.log.debug("isPaused: " .. tostring(paused), "audio")
    lurek.audio.stop(source)
    lurek.audio.release(source)
  end
end
--@api-stub: lurek.audio.isStopped
-- Returns whether a source is currently stopped.
do
  local ok_source, source = pcall(lurek.audio.newSource, "assets/audio/music.ogg", "static")
  if ok_source then
    local stopped = lurek.audio.isStopped(source)
    lurek.log.debug("isStopped before play: " .. tostring(stopped), "audio")
    lurek.audio.release(source)
  end
end
--@api-stub: lurek.audio.setLooping
-- Enables or disables looping for a source.
do
  local ok_music, music_source = pcall(lurek.audio.newSource, "assets/audio/music.ogg", "static")
  if ok_music then
    lurek.audio.setLooping(music_source, true)
    lurek.log.debug("music will loop", "audio")
    lurek.audio.release(music_source)
  end
end
--@api-stub: lurek.audio.isLooping
-- Returns whether a source has looping enabled.
do
  local ok_source, source = pcall(lurek.audio.newSource, "assets/audio/music.ogg", "static")
  if ok_source then
    lurek.audio.setLooping(source, true)
    local looping = lurek.audio.isLooping(source)
    lurek.log.debug("looping: " .. tostring(looping), "audio")
    lurek.audio.release(source)
  end
end
--@api-stub: lurek.audio.setPan
-- Sets the stereo panning of a source.
do
  local ok_sfx, sfx_source = pcall(lurek.audio.newSource, "assets/audio/music.ogg", "static")
  if ok_sfx then
    lurek.audio.setPan(sfx_source, 1.0)
    lurek.log.debug("panned right", "audio")
    lurek.audio.release(sfx_source)
  end
end
--@api-stub: lurek.audio.getPan
-- Returns the current stereo pan position of a source.
do
  local ok_source, source = pcall(lurek.audio.newSource, "assets/audio/music.ogg", "static")
  if ok_source then
    lurek.audio.setPan(source, 0.5)
    local pan = lurek.audio.getPan(source)
    lurek.log.debug("pan: " .. tostring(pan), "audio")
    lurek.audio.release(source)
  end
end
--@api-stub: lurek.audio.clone
-- Creates an independent copy of a source sharing the same audio data.
do
  local ok_source, source = pcall(lurek.audio.newSource, "assets/audio/music.ogg", "static")
  if ok_source then
    local copy = lurek.audio.clone(source)
    lurek.log.debug("source cloned", "audio")
    lurek.audio.release(source)
    lurek.audio.release(copy)
  end
end
--@api-stub: lurek.audio.stopAll
-- Stops all audio sources and resets their positions.
do
  -- Stop every active audio source at once (e.g., game over or menu open).
  lurek.audio.stopAll()
  lurek.log.info("all audio stopped", "audio")
end
--@api-stub: lurek.audio.release
-- Releases an audio source, freeing its memory and stopping playback.
do
  local ok_source, source = pcall(lurek.audio.newSource, "assets/audio/music.ogg", "static")
  if ok_source then
    lurek.audio.release(source)
    lurek.log.debug("source released", "audio")
  end
end
--@api-stub: lurek.audio.getDuration
-- Returns the total duration of a source in seconds.
do
  local ok_source, source = pcall(lurek.audio.newSource, "assets/audio/music.ogg", "static")
  if ok_source then
    local duration = lurek.audio.getDuration(source)
    lurek.log.info("duration: " .. tostring(duration) .. " s", "audio")
    lurek.audio.release(source)
  end
end
--@api-stub: lurek.audio.tell
-- Returns the current playback position of a source in seconds.
do
  local ok_source, source = pcall(lurek.audio.newSource, "assets/audio/music.ogg", "static")
  if ok_source then
    lurek.audio.seek(source, 1.0)
    local position = lurek.audio.tell(source)
    lurek.log.debug("tell: " .. tostring(position) .. " s", "audio")
    lurek.audio.release(source)
  end
end
--@api-stub: lurek.audio.seek
-- Seeks a source to a specific position in seconds.
do
  local ok_source, source = pcall(lurek.audio.newSource, "assets/audio/music.ogg", "static")
  if ok_source then
    lurek.audio.seek(source, 0.5)
    local position = lurek.audio.tell(source)
    lurek.log.debug("position after seek: " .. tostring(position) .. " s", "audio")
    lurek.audio.release(source)
  end
end
--@api-stub: lurek.audio.setLowpass
-- Applies a lowpass filter to a source, attenuating high frequencies.
do
  local ok_source, source = pcall(lurek.audio.newSource, "assets/audio/music.ogg", "static")
  if ok_source then
    lurek.audio.setLowpass(source, 3000)
    lurek.log.debug("lowpass filter set to 3000 Hz", "audio")
    lurek.audio.release(source)
  end
end
--@api-stub: lurek.audio.setHighpass
-- Applies a highpass filter to a source, attenuating low frequencies.
do
  local ok_source, source = pcall(lurek.audio.newSource, "assets/audio/music.ogg", "static")
  if ok_source then
    lurek.audio.setHighpass(source, 800)
    lurek.log.debug("highpass filter set to 800 Hz", "audio")
    lurek.audio.release(source)
  end
end
--@api-stub: lurek.audio.getLowpass
-- Returns the current lowpass filter cutoff of a source.
do
  local ok_source, source = pcall(lurek.audio.newSource, "assets/audio/music.ogg", "static")
  if ok_source then
    lurek.audio.setLowpass(source, 3000)
    local frequency = lurek.audio.getLowpass(source)
    lurek.log.debug("lowpass: " .. tostring(frequency) .. " Hz", "audio")
    lurek.audio.release(source)
  end
end
--@api-stub: lurek.audio.getHighpass
-- Returns the current highpass filter cutoff of a source.
do
  local ok_source, source = pcall(lurek.audio.newSource, "assets/audio/music.ogg", "static")
  if ok_source then
    lurek.audio.setHighpass(source, 800)
    local frequency = lurek.audio.getHighpass(source)
    lurek.log.debug("highpass: " .. tostring(frequency) .. " Hz", "audio")
    lurek.audio.release(source)
  end
end
--@api-stub: lurek.audio.clearFilter
-- Removes all frequency filters from a source.
do
  local ok_source, source = pcall(lurek.audio.newSource, "assets/audio/music.ogg", "static")
  if ok_source then
    lurek.audio.setLowpass(source, 1000)
    lurek.audio.clearFilter(source)
    lurek.log.debug("filter cleared", "audio")
    lurek.audio.release(source)
  end
end
--@api-stub: lurek.audio.fadeIn
-- Sets the fade-in duration for a source so it ramps from silence on play.
do
  local ok_music, music_source = pcall(lurek.audio.newSource, "assets/audio/music.ogg", "static")
  if ok_music then
    lurek.audio.fadeIn(music_source, 2.0)
    lurek.log.info("music fading in over 2 s", "audio")
    lurek.audio.release(music_source)
  end
end
--@api-stub: lurek.audio.getFadeIn
-- Returns the configured fade-in duration of a source.
do
  local ok_source, source = pcall(lurek.audio.newSource, "assets/audio/music.ogg", "static")
  if ok_source then
    lurek.audio.fadeIn(source, 1.0)
    local fade = lurek.audio.getFadeIn(source)
    lurek.log.debug("fade-in duration: " .. tostring(fade), "audio")
    lurek.audio.release(source)
  end
end
--@api-stub: LDecoder:type
-- Returns the type name of this object for runtime type-checking.
do
  local ok_decoder, decoder = pcall(lurek.audio.newDecoder, "assets/audio/music.ogg")
  if ok_decoder then
    lurek.log.debug("type: " .. decoder:type(), "audio")
  end
end
--@api-stub: LDecoder:typeOf
-- Checks whether this object matches the given type name.
do
  local ok_decoder, decoder = pcall(lurek.audio.newDecoder, "assets/audio/music.ogg")
  if ok_decoder then
    lurek.log.debug("typeOf LDecoder: " .. tostring(decoder:typeOf("LDecoder")), "audio")
  end
end
--@api-stub: LSource:type
-- Returns the type name of this object for runtime type-checking.
do
  local ok_source, source = pcall(lurek.audio.newSource, "assets/audio/music.ogg", "static")
  if ok_source then
    lurek.log.debug("type: " .. source:type(), "audio")
  end
end
--@api-stub: LSource:typeOf
-- Checks whether this object is of the given type name or a parent type.
do
  local ok_source, source = pcall(lurek.audio.newSource, "assets/audio/music.ogg", "static")
  if ok_source then
    lurek.log.debug("typeOf LSource: " .. tostring(source:typeOf("LSource")), "audio")
  end
end
--@api-stub: lurek.audio.play
-- Plays a source through the audio mixer, with optional per-play bus override.
do
  local ok_sfx, sfx_source = pcall(lurek.audio.newSource, "assets/audio/hit.wav", "static")
  if ok_sfx then
    lurek.audio.play(sfx_source)
  end
end
--@api-stub: lurek.audio.stop
-- Stops playback and rewinds a source to the beginning.
do
  local ok_source, source = pcall(lurek.audio.newSource, "assets/audio/music.ogg", "stream")
  if ok_source then
    lurek.audio.play(source)
    lurek.audio.stop(source)
  end
end
--@api-stub: lurek.audio.pause
-- Pauses playback of a source, preserving its position.
do
  local ok_source, source = pcall(lurek.audio.newSource, "assets/audio/music.ogg", "stream")
  if ok_source then
    lurek.audio.play(source)
    lurek.audio.pause(source)
  end
end
--@api-stub: lurek.audio.resume
-- Resumes a paused source from where it was paused.
do
  local ok_source, source = pcall(lurek.audio.newSource, "assets/audio/music.ogg", "stream")
  if ok_source then
    lurek.audio.play(source)
    lurek.audio.pause(source)
    lurek.audio.resume(source)
  end
end
