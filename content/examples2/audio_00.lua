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
    print("before play = " .. tostring(lurek.audio.isPlaying(src)))
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
    lurek.audio.newBus("music")
    print("buses created: sfx, music")
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
    local dur = lurek.audio.getDuration(src)
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

print("audio_00.lua")
