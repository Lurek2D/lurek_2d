-- content/examples/audio.lua
-- Auto-generated from content/examples2/audio_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/audio.lua

--- Audio Examples Part 1: Source creation, playback control, volume, pitch, pan, master, bus, filters, spatial

--@api-stub: lurek.audio.newSource
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    local source_type = lurek.audio.getSourceType(src)
    print("source created = " .. tostring(src ~= nil))
    print("path = " .. path)
    print("source type = " .. tostring(source_type))
end

--@api-stub: lurek.audio.play
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.play(src)
    print("play requested for = " .. path)
    print("playing = " .. tostring(lurek.audio.isPlaying(src)))
end

--@api-stub: lurek.audio.stop
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.play(src)
    print("before stop playing = " .. tostring(lurek.audio.isPlaying(src)))
    lurek.audio.stop(src)
    print("stopped = " .. tostring(lurek.audio.isStopped(src)))
end

--@api-stub: lurek.audio.setVolume
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    print("volume before = " .. tostring(lurek.audio.getVolume(src)))
    lurek.audio.setVolume(src, 0.5)
    print("volume after = " .. tostring(lurek.audio.getVolume(src)))
end

--@api-stub: lurek.audio.getVolume
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setVolume(src, 0.8)
    local vol = lurek.audio.getVolume(src)
    print("configured volume = 0.8")
    print("volume = " .. tostring(vol))
end

--@api-stub: lurek.audio.pause
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.play(src)
    print("playing before pause = " .. tostring(lurek.audio.isPlaying(src)))
    lurek.audio.pause(src)
    print("paused = " .. tostring(lurek.audio.isPaused(src)))
end

--@api-stub: lurek.audio.resume
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.play(src)
    lurek.audio.pause(src)
    print("paused before resume = " .. tostring(lurek.audio.isPaused(src)))
    lurek.audio.resume(src)
    print("playing after resume = " .. tostring(lurek.audio.isPlaying(src)))
end

--@api-stub: lurek.audio.setPitch
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    print("pitch before = " .. tostring(lurek.audio.getPitch(src)))
    lurek.audio.setPitch(src, 1.5)
    print("pitch after = " .. tostring(lurek.audio.getPitch(src)))
end

--@api-stub: lurek.audio.getPitch
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setPitch(src, 0.8)
    local p = lurek.audio.getPitch(src)
    print("configured pitch = 0.8")
    print("pitch = " .. tostring(p))
end

--@api-stub: lurek.audio.isPlaying
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    print("before play = " .. tostring(lurek.audio.isPlaying(src)))
    lurek.audio.play(src)
    print("after play = " .. tostring(lurek.audio.isPlaying(src)))
end

--@api-stub: lurek.audio.isPaused
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.play(src)
    lurek.audio.pause(src)
    print("playing now = " .. tostring(lurek.audio.isPlaying(src)))
    print("isPaused = " .. tostring(lurek.audio.isPaused(src)))
end

--@api-stub: lurek.audio.isStopped
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    print("initially stopped = " .. tostring(lurek.audio.isStopped(src)))
    print("initially playing = " .. tostring(lurek.audio.isPlaying(src)))
end

--@api-stub: lurek.audio.setLooping
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    print("looping before = " .. tostring(lurek.audio.isLooping(src)))
    lurek.audio.setLooping(src, true)
    print("looping after = " .. tostring(lurek.audio.isLooping(src)))
end

--@api-stub: lurek.audio.isLooping
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.setLooping(src, true)
    print("source type = " .. tostring(lurek.audio.getSourceType(src)))
    print("isLooping = " .. tostring(lurek.audio.isLooping(src)))
end

--@api-stub: lurek.audio.playLooping
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.playLooping(src)
    print("playing = " .. tostring(lurek.audio.isPlaying(src)))
    print("playing+looping = " .. tostring(lurek.audio.isPlaying(src) and lurek.audio.isLooping(src)))
end

--@api-stub: lurek.audio.setPan
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    print("pan before = " .. tostring(lurek.audio.getPan(src)))
    lurek.audio.setPan(src, -0.5)
    print("pan after = " .. tostring(lurek.audio.getPan(src)))
end

--@api-stub: lurek.audio.getPan
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setPan(src, 0.7)
    local pan = lurek.audio.getPan(src)
    print("configured pan = 0.7")
    print("pan = " .. tostring(pan))
end

--@api-stub: lurek.audio.setMasterVolume
do
    local before = lurek.audio.getMasterVolume()
    lurek.audio.setMasterVolume(0.75)
    print("master volume before = " .. tostring(before))
    print("master volume after = " .. tostring(lurek.audio.getMasterVolume()))
end

--@api-stub: lurek.audio.getMasterVolume
do
    lurek.audio.setMasterVolume(1.0)
    local mv = lurek.audio.getMasterVolume()
    print("configured master volume = 1.0")
    print("master volume = " .. tostring(mv))
end

--@api-stub: lurek.audio.getActiveSourceCount
do
    local count = lurek.audio.getActiveSourceCount()
    print("active sources = " .. tostring(count))
    print("active source count queried")
end

--@api-stub: lurek.audio.getSourceCount
do
    local total = lurek.audio.getSourceCount()
    print("total sources = " .. tostring(total))
    print("source registry count queried")
end

--@api-stub: lurek.audio.getSourceType
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    local stype = lurek.audio.getSourceType(src)
    print("path = " .. path)
    print("source type = " .. tostring(stype))
end

--@api-stub: lurek.audio.clone
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setVolume(src, 0.6)
    local copy = lurek.audio.clone(src)
    print("original volume = " .. tostring(lurek.audio.getVolume(src)))
    print("clone volume = " .. tostring(lurek.audio.getVolume(copy)))
end

--@api-stub: lurek.audio.pauseAll
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.play(src)
    lurek.audio.pauseAll()
    print("all paused")
    print("sample source paused = " .. tostring(lurek.audio.isPaused(src)))
end

--@api-stub: lurek.audio.stopAll
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.play(src)
    lurek.audio.stopAll()
    print("all stopped")
    print("sample source stopped = " .. tostring(lurek.audio.isStopped(src)))
end

--@api-stub: lurek.audio.resumeAll
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.play(src)
    lurek.audio.pauseAll()
    lurek.audio.resumeAll()
    print("all resumed")
    print("sample source playing = " .. tostring(lurek.audio.isPlaying(src)))
end

--@api-stub: lurek.audio.release
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    local before = lurek.audio.getSourceCount()
    lurek.audio.release(src)
    print("source released")
    print("source count before release = " .. tostring(before))
end

--@api-stub: lurek.audio.newBus
do
    local bus = lurek.audio.newBus("sfx")
    print("bus created: sfx")
    print("bus name = " .. bus:getName())
end

--@api-stub: lurek.audio.setSourceBus
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    local bus = lurek.audio.newBus("effects")
    lurek.audio.setSourceBus(src, bus)
    local assigned = lurek.audio.getSourceBus(src)
    print("bus assigned = " .. tostring(assigned ~= nil))
    print("bus = " .. assigned:getName())
end

--@api-stub: lurek.audio.getSourceBus
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    local bus = lurek.audio.newBus("ui")
    lurek.audio.setSourceBus(src, bus)
    local assigned = lurek.audio.getSourceBus(src)
    print("source bus exists = " .. tostring(assigned ~= nil))
    print("source bus = " .. assigned:getName())
end

--@api-stub: lurek.audio.getMaxSources
do
    local max = lurek.audio.getMaxSources()
    print("max sources = " .. tostring(max))
    print("audio capacity queried")
end

--@api-stub: lurek.audio.getDuration
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    local dur = lurek.audio.getDuration(src) or 0
    print("path = " .. path)
    print("duration = " .. tostring(dur) .. "s")
end

--@api-stub: lurek.audio.tell
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.play(src)
    local pos = lurek.audio.tell(src)
    print("playing = " .. tostring(lurek.audio.isPlaying(src)))
    print("position = " .. tostring(pos))
end

--@api-stub: lurek.audio.seek
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.play(src)
    lurek.audio.seek(src, 5.0)
    print("seek target = 5.0")
    print("position after seek = " .. tostring(lurek.audio.tell(src)))
end

--@api-stub: lurek.audio.setLowpass
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.setLowpass(src, 800)
    print("lowpass set to 800 Hz")
    print("lowpass = " .. tostring(lurek.audio.getLowpass(src)) .. " Hz")
end

--@api-stub: lurek.audio.setHighpass
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setHighpass(src, 2000)
    print("highpass set to 2000 Hz")
    print("highpass = " .. tostring(lurek.audio.getHighpass(src)) .. " Hz")
end

--@api-stub: lurek.audio.getLowpass
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setLowpass(src, 500)
    local lp = lurek.audio.getLowpass(src)
    print("configured lowpass = 500")
    print("lowpass = " .. tostring(lp))
end

--@api-stub: lurek.audio.getHighpass
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setHighpass(src, 3000)
    local hp = lurek.audio.getHighpass(src)
    print("configured highpass = 3000")
    print("highpass = " .. tostring(hp))
end

--@api-stub: lurek.audio.clearFilter
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setLowpass(src, 1000)
    print("lowpass before clear = " .. tostring(lurek.audio.getLowpass(src)))
    lurek.audio.clearFilter(src)
    print("filters cleared")
end

--@api-stub: lurek.audio.fadeIn
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.fadeIn(src, 2.0)
    print("fade in requested = 2.0s")
    print("fade in = " .. tostring(lurek.audio.getFadeIn(src)) .. "s")
end

--@api-stub: lurek.audio.getFadeIn
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.fadeIn(src, 1.5)
    local fi = lurek.audio.getFadeIn(src)
    print("configured fade in = 1.5")
    print("fade in duration = " .. tostring(fi))
end

--@api-stub: lurek.audio.setListener2D
do
    lurek.audio.setListener2D(400, 300)
    local x, y = lurek.audio.getListener2D()
    print("listener 2D set to 400, 300")
    print("listener 2D = " .. x .. ", " .. y)
end

--@api-stub: lurek.audio.getListener2D
do
    lurek.audio.setListener2D(100, 200)
    local x, y = lurek.audio.getListener2D()
    print("listener 2D queried")
    print("listener at " .. x .. ", " .. y)
end

--@api-stub: lurek.audio.setListener
do
    lurek.audio.setListener(0, 0, 0)
    local x, y, z = lurek.audio.getListener()
    print("listener 3D reset to origin")
    print("listener 3D = " .. x .. ", " .. y .. ", " .. z)
end

--@api-stub: lurek.audio.getListener
do
    lurek.audio.setListener(10, 5, 0)
    local x, y, z = lurek.audio.getListener()
    print("listener 3D queried")
    print("listener = " .. x .. ", " .. y .. ", " .. z)
end

--@api-stub: lurek.audio.setPosition
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setPosition(src, 50, 20, 0)
    local x, y, z = lurek.audio.getPosition(src)
    print("source positioned for spatial playback")
    print("source pos = " .. x .. ", " .. y .. ", " .. z)
end

--@api-stub: lurek.audio.getPosition
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setPosition(src, 100, 0, 30)
    local x, y, z = lurek.audio.getPosition(src)
    print("source position queried")
    print("pos = " .. x .. ", " .. y .. ", " .. z)
end

--@api-stub: lurek.audio.setVelocity
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setVelocity(src, 10, 0, 0)
    local vx, vy, vz = lurek.audio.getVelocity(src)
    print("source velocity set for doppler")
    print("velocity = " .. vx .. ", " .. vy .. ", " .. vz)
end

--@api-stub: lurek.audio.getVelocity
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setVelocity(src, 5, 3, 0)
    local vx, vy, vz = lurek.audio.getVelocity(src)
    print("source velocity queried")
    print("vel = " .. vx .. ", " .. vy .. ", " .. vz)
end

--@api-stub: lurek.audio.setOrientation
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setOrientation(src, 0, 0, -1, 0, 1, 0)
    local fx, fy, fz, ux, uy, uz = lurek.audio.getOrientation(src)
    print("orientation applied")
    print("forward = " .. fx .. ", " .. fy .. ", " .. fz)
    print("up = " .. ux .. ", " .. uy .. ", " .. uz)
end

--- Audio Examples Part 2: Orientation, distance models, MIDI, synthesis, DSP, bus effects, pool, offline

--@api-stub: lurek.audio.getOrientation
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setOrientation(src, 0, 0, -1, 0, 1, 0)
    local fx, fy, fz, ux, uy, uz = lurek.audio.getOrientation(src)
    print("source type = " .. tostring(lurek.audio.getSourceType(src)))
    print("forward = " .. fx .. ", " .. fy .. ", " .. fz)
    print("up = " .. ux .. ", " .. uy .. ", " .. uz)
end

--@api-stub: lurek.audio.setDopplerScale
do
    local before = lurek.audio.getDopplerScale()
    lurek.audio.setDopplerScale(1.5)
    local after = lurek.audio.getDopplerScale()
    print("doppler scale before = " .. tostring(before))
    print("doppler scale after = " .. tostring(after))
end

--@api-stub: lurek.audio.getDopplerScale
do
    lurek.audio.setDopplerScale(2.0)
    local ds = lurek.audio.getDopplerScale()
    print("configured doppler scale = 2.0")
    print("doppler scale = " .. tostring(ds))
end

--@api-stub: lurek.audio.setDistanceModel
do
    local before = lurek.audio.getDistanceModel()
    lurek.audio.setDistanceModel("inverse")
    print("distance model before = " .. tostring(before))
    print("distance model after = " .. tostring(lurek.audio.getDistanceModel()))
end

--@api-stub: lurek.audio.getDistanceModel
do
    lurek.audio.setDistanceModel("linear")
    local model = lurek.audio.getDistanceModel()
    print("configured distance model = linear")
    print("distance model = " .. tostring(model))
end

--@api-stub: lurek.audio.setMeter
do
    local before = lurek.audio.getMeter()
    lurek.audio.setMeter(0.8)
    print("meter before = " .. tostring(before))
    print("meter after = " .. tostring(lurek.audio.getMeter()))
end

--@api-stub: lurek.audio.getMeter
do
    lurek.audio.setMeter(0.6)
    local lvl = lurek.audio.getMeter()
    print("configured meter = 0.6")
    print("meter = " .. tostring(lvl))
end

--@api-stub: lurek.audio.newMidiPlayer
do
    local player = lurek.audio.newMidiPlayer()
    print("midi player created = " .. tostring(player ~= nil))
    print("player type = " .. player:type())
end

--@api-stub: lurek.audio.newSoundData
do
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    print("sound data created = " .. tostring(sd ~= nil))
    print("sample count = " .. tostring(sd:getSampleCount()))
    print("sample rate = " .. tostring(sd:getSampleRate()))
end

--@api-stub: lurek.audio.setMidiSoundFont
do
    local path = "content/examples/assets/audio/sample_soundfont.sf2"
    local ok = pcall(function()
        lurek.audio.setMidiSoundFont(path)
    end)
    print("soundfont set = " .. tostring(ok and lurek.audio.hasMidiSoundFont()))
end

--@api-stub: lurek.audio.hasMidiSoundFont
do
    local has = lurek.audio.hasMidiSoundFont()
    print("has soundfont = " .. tostring(has))
    print("soundfont ready check completed")
end

--@api-stub: lurek.audio.clearMidiSoundFont
do
    lurek.audio.clearMidiSoundFont()
    print("soundfont cleared = " .. tostring(not lurek.audio.hasMidiSoundFont()))
end

--@api-stub: lurek.audio.newDecoder
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local dec = lurek.audio.newDecoder(path, 4096)
    print("decoder created = " .. tostring(dec ~= nil))
    print("sample rate = " .. tostring(dec:getSampleRate()))
    print("channels = " .. tostring(dec:getChannelCount()))
end

--@api-stub: lurek.audio.newQueueableSource
do
    local qid = lurek.audio.newQueueableSource(44100, 16, 1, 4)
    local free = lurek.audio.getFreeBufferCount(qid)
    print("queueable id = " .. tostring(qid))
    print("free buffers = " .. tostring(free))
end

--@api-stub: lurek.audio.queueSource
do
    local qid = lurek.audio.newQueueableSource(44100, 16, 1, 4)
    local sd = lurek.audio.newSoundData(1024, 44100, 1)
    local before = lurek.audio.getFreeBufferCount(qid)
    lurek.audio.queueSource(qid, sd)
    local after = lurek.audio.getFreeBufferCount(qid)
    print("free buffers before queue = " .. tostring(before))
    print("free buffers after queue = " .. tostring(after))
end

--@api-stub: lurek.audio.getFreeBufferCount
do
    local qid = lurek.audio.newQueueableSource(44100, 16, 1, 4)
    local free = lurek.audio.getFreeBufferCount(qid)
    print("queueable id = " .. tostring(qid))
    print("free buffers = " .. tostring(free))
end

--@api-stub: lurek.audio.playQueueable
do
    local qid = lurek.audio.newQueueableSource(44100, 16, 1, 4)
    local sd = lurek.audio.newSoundData(1024, 44100, 1)
    lurek.audio.queueSource(qid, sd)
    lurek.audio.playQueueable(qid)
    print("queueable source started")
    print("free buffers after play = " .. tostring(lurek.audio.getFreeBufferCount(qid)))
end

--@api-stub: lurek.audio.stopQueueable
do
    local qid = lurek.audio.newQueueableSource(44100, 16, 1, 4)
    lurek.audio.stopQueueable(qid)
    print("queueable source stopped")
    print("free buffers = " .. tostring(lurek.audio.getFreeBufferCount(qid)))
end

--@api-stub: lurek.audio.getPlaybackDevices
do
    local devices = lurek.audio.getPlaybackDevices()
    print("device count = " .. tostring(#devices))
    print("first device = " .. tostring(devices[1] or "none"))
end

--@api-stub: lurek.audio.getPlaybackDevice
do
    local dev = lurek.audio.getPlaybackDevice()
    print("current device = " .. tostring(dev))
    print("device query completed")
end

--@api-stub: lurek.audio.setPlaybackDevice
do
    local devices = lurek.audio.getPlaybackDevices()
    local name = devices[1] or lurek.audio.getPlaybackDevice()
    lurek.audio.setPlaybackDevice(name)
    print("requested device = " .. tostring(name))
    print("active device = " .. tostring(lurek.audio.getPlaybackDevice()))
end

--@api-stub: lurek.audio.create_bus
do
    lurek.audio.create_bus("master_sfx", nil)
    print("bus created: master_sfx")
    print("bus peak = " .. tostring(lurek.audio.getBusPeak("master_sfx")))
end

--@api-stub: lurek.audio.set_bus_volume
do
    lurek.audio.create_bus("music_bus", nil)
    lurek.audio.set_bus_volume("music_bus", 0.7)
    print("configured music_bus volume = 0.7")
    print("music_bus peak = " .. tostring(lurek.audio.getBusPeak("music_bus")))
end

--@api-stub: lurek.audio.add_effect
do
    lurek.audio.create_bus("fx_bus", nil)
    local eid = lurek.audio.add_effect("fx_bus", "reverb", { value = 0.5 })
    print("effect id = " .. tostring(eid))
    print("effect added to fx_bus")
end

--@api-stub: lurek.audio.remove_effect
do
    lurek.audio.create_bus("temp_bus", nil)
    local eid = lurek.audio.add_effect("temp_bus", "lowpass", { value = 800 })
    local ok = lurek.audio.remove_effect("temp_bus", eid)
    print("effect id = " .. tostring(eid))
    print("removed = " .. tostring(ok))
end

--@api-stub: lurek.audio.set_effect_param
do
    lurek.audio.create_bus("eq_bus", nil)
    local eid = lurek.audio.add_effect("eq_bus", "highpass", { cutoff = 200 })
    local ok = lurek.audio.set_effect_param("eq_bus", eid, "cutoff", 500)
    print("effect id = " .. tostring(eid))
    print("param set = " .. tostring(ok))
end

--@api-stub: lurek.audio.newSineWave
do
    local sd = lurek.audio.newSineWave(440, 1.0, 44100, 0.8)
    print("sine wave = " .. tostring(sd ~= nil))
end

--@api-stub: lurek.audio.newSquareWave
do
    local sd = lurek.audio.newSquareWave(220, 0.5, 44100, 0.6)
    print("square wave = " .. tostring(sd ~= nil))
end

--@api-stub: lurek.audio.newSawtoothWave
do
    local sd = lurek.audio.newSawtoothWave(330, 0.5, 44100, 0.7)
    print("sawtooth wave = " .. tostring(sd ~= nil))
end

--@api-stub: lurek.audio.newTriangleWave
do
    local sd = lurek.audio.newTriangleWave(550, 0.5, 44100, 0.5)
    print("triangle wave = " .. tostring(sd ~= nil))
end

--@api-stub: lurek.audio.newWhiteNoise
do
    local sd = lurek.audio.newWhiteNoise(1.0, 44100, 0.4, 12345)
    print("white noise = " .. tostring(sd ~= nil))
end

--@api-stub: lurek.audio.applyLowpass
do
    local sd = lurek.audio.newSineWave(1000, 0.5, 44100, 0.8)
    lurek.audio.applyLowpass(sd, 500)
    print("lowpass applied at 500 Hz")
end

--@api-stub: lurek.audio.applyHighpass
do
    local sd = lurek.audio.newWhiteNoise(0.5, 44100, 0.6, 99)
    lurek.audio.applyHighpass(sd, 2000)
    print("highpass applied at 2000 Hz")
end

--@api-stub: lurek.audio.applyBandpass
do
    local sd = lurek.audio.newWhiteNoise(0.5, 44100, 0.5, 42)
    lurek.audio.applyBandpass(sd, 300, 3000)
    print("bandpass 300-3000 Hz applied")
end

--@api-stub: lurek.audio.applyGain
do
    local sd = lurek.audio.newSineWave(440, 0.5, 44100, 0.3)
    lurek.audio.applyGain(sd, 2.0)
    print("gain x2 applied")
end

--@api-stub: lurek.audio.mixInto
do
    local dest = lurek.audio.newSineWave(440, 1.0, 44100, 0.5)
    local src = lurek.audio.newSineWave(880, 1.0, 44100, 0.3)
    lurek.audio.mixInto(dest, src)
    print("mixed 880 Hz into 440 Hz")
end

--@api-stub: lurek.audio.saveWAV
do
    local sd = lurek.audio.newSineWave(440, 1.0, 44100, 0.8)
    lurek.audio.saveWAV(sd, "work/output/test_tone.wav")
    print("saved WAV file")
end

--@api-stub: lurek.audio.setStereoWidth
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.setStereoWidth(src, 0.5)
    print("configured stereo width = 0.5")
    print("stereo width = " .. tostring(lurek.audio.getStereoWidth(src)))
end

--@api-stub: lurek.audio.getStereoWidth
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.setStereoWidth(src, 0.8)
    local w = lurek.audio.getStereoWidth(src)
    print("configured stereo width = 0.8")
    print("width = " .. tostring(w))
end

--@api-stub: lurek.audio.setRandomPitch
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setRandomPitch(src, 0.9, 1.1)
    print("random pitch range = 0.9 to 1.1")
    print("source ready for varied playback")
end

--@api-stub: lurek.audio.clearRandomPitch
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setRandomPitch(src, 0.8, 1.2)
    lurek.audio.clearRandomPitch(src)
    print("random pitch cleared")
    print("source pitch now follows explicit setPitch calls")
end

--@api-stub: lurek.audio.crossfade
do
    local p1 = "content/examples/assets/audio/sample_loop.wav"
    local p2 = "content/examples/assets/audio/sample_tone.wav"
    local from = lurek.audio.newSource(p1, "stream")
    local to = lurek.audio.newSource(p2, "stream")
    lurek.audio.play(from)
    lurek.audio.crossfade(from, to, 3.0)
    print("from path = " .. p1)
    print("to path = " .. p2)
    print("crossfading over 3s")
end

--@api-stub: lurek.audio.getBusPeak
do
    lurek.audio.create_bus("vu_bus", nil)
    local peak = lurek.audio.getBusPeak("vu_bus")
    print("bus peak = " .. peak)
end

--@api-stub: lurek.audio.getBusRms
do
    lurek.audio.create_bus("rms_bus", nil)
    local rms = lurek.audio.getBusRms("rms_bus")
    print("bus rms = " .. rms)
end

--@api-stub: lurek.audio.newPool
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local pool = lurek.audio.newPool(path, 8)
    print("pool voices = " .. pool:getVoiceCount())
end

--@api-stub: lurek.audio.processOffline
do
    local effects = {{ type = "lowpass", p1 = 1000 }, { type = "compressor", p1 = 0.8, p2 = 2.5, p3 = 0.1 }}
    local path_in = "content/examples/assets/audio/sample_tone.wav"
    local path_out = "work/output/processed.wav"
    lurek.audio.processOffline(path_in, path_out, effects)
    print("input file = " .. path_in)
    print("output file = " .. path_out)
    print("offline processing done")
end

--@api-stub: lurek.audio.normalizeFile
do
    local path_in = "content/examples/assets/audio/sample_tone.wav"
    local path_out = "work/output/normalized.wav"
    lurek.audio.normalizeFile(path_in, path_out, 0.9)
    print("input file = " .. path_in)
    print("output file = " .. path_out)
    print("normalized to 0.9 peak")
end

--@api-stub: lurek.audio.waveformToPng
do
    local path_in = "content/examples/assets/audio/sample_tone.wav"
    local path_out = "work/output/waveform.png"
    lurek.audio.waveformToPng(path_in, path_out, 800, 200)
    print("input file = " .. path_in)
    print("output file = " .. path_out)
    print("waveform image saved")
end

--@api-stub: lurek.audio.spectrogramToPng
do
    local path_in = "content/examples/assets/audio/sample_tone.wav"
    local path_out = "work/output/spectrogram.png"
    lurek.audio.spectrogramToPng(path_in, path_out, 800, 400)
    print("input file = " .. path_in)
    print("output file = " .. path_out)
    print("spectrogram image saved")
end

--@api-stub: LSource:play
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    src:play()
    print("playing via method = " .. tostring(src:isPlaying()))
end

--- Audio Examples Part 3: LSource methods, LBus methods, LMidiPlayer methods

--@api-stub: LSource:stop
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    src:play()
    src:stop()
    print("stopped = " .. tostring(src:isStopped()))
end

--@api-stub: LSource:pause
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    src:play()
    src:pause()
    print("paused = " .. tostring(src:isPaused()))
end

--@api-stub: LSource:resume
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    src:play()
    src:pause()
    src:resume()
    print("resumed = " .. tostring(src:isPlaying()))
end

--@api-stub: LSource:setVolume
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    src:setVolume(0.4)
    print("volume = " .. src:getVolume())
end

--@api-stub: LSource:getVolume
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    src:setVolume(0.9)
    local v = src:getVolume()
    print("volume = " .. v)
end

--@api-stub: LSource:setPitch
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    src:setPitch(1.5)
    print("pitch = " .. src:getPitch())
end

--@api-stub: LSource:getPitch
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    src:setPitch(0.7)
    local p = src:getPitch()
    print("pitch = " .. p)
end

--@api-stub: LSource:setLooping
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    src:setLooping(true)
    print("looping = " .. tostring(src:isLooping()))
end

--@api-stub: LSource:isLooping
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    src:setLooping(true)
    print("isLooping = " .. tostring(src:isLooping()))
end

--@api-stub: LSource:isPlaying
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    src:play()
    print("playing = " .. tostring(src:isPlaying()))
end

--@api-stub: LSource:isPaused
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    src:play()
    src:pause()
    print("paused = " .. tostring(src:isPaused()))
end

--@api-stub: LSource:isStopped
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    print("stopped = " .. tostring(src:isStopped()))
end

--@api-stub: LSource:setPan
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    src:setPan(-0.8)
    print("pan = " .. src:getPan())
end

--@api-stub: LSource:getPan
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    src:setPan(0.5)
    local pan = src:getPan()
    print("pan = " .. pan)
end

--@api-stub: LSource:clone
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    src:setVolume(0.3)
    local copy = src:clone()
    print("clone volume = " .. copy:getVolume())
end

--@api-stub: LSource:getType
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    print("type = " .. src:getType())
end

--@api-stub: LSource:getDuration
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    local dur = src:getDuration()
    print("duration = " .. tostring(dur) .. "s")
end

--@api-stub: LSource:tell
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    src:play()
    local pos = src:tell()
    print("position = " .. pos)
end

--@api-stub: LSource:seek
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    src:play()
    src:seek(10.0)
    print("seeked to " .. src:tell())
end

--@api-stub: LSource:setLowpass
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    src:setLowpass(600)
    print("lowpass = " .. src:getLowpass())
end

--@api-stub: LSource:setHighpass
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    src:setHighpass(1500)
    print("highpass = " .. src:getHighpass())
end

--@api-stub: LSource:getLowpass
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    src:setLowpass(400)
    local lp = src:getLowpass()
    print("lowpass = " .. lp)
end

--@api-stub: LSource:getHighpass
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    src:setHighpass(4000)
    local hp = src:getHighpass()
    print("highpass = " .. hp)
end

--@api-stub: LSource:clearFilter
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    src:setLowpass(800)
    src:clearFilter()
    print("filters cleared")
end

--@api-stub: LSource:fadeIn
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    src:fadeIn(2.5)
    print("fade in = " .. src:getFadeIn() .. "s")
end

--@api-stub: LSource:getFadeIn
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    src:fadeIn(1.0)
    local fi = src:getFadeIn()
    print("fade in = " .. fi)
end

--@api-stub: LSource:type
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    print("type = " .. src:type())
end

--@api-stub: LSource:typeOf
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    print("is LSource = " .. tostring(src:typeOf("LSource")))
end

--@api-stub: LBus:getName
do
    local bus = lurek.audio.newBus("gameplay")
    print("bus name = " .. bus:getName())
end

--@api-stub: LBus:setVolume
do
    local bus = lurek.audio.newBus("sfx")
    bus:setVolume(0.6)
    print("bus volume = " .. bus:getVolume())
end

--@api-stub: LBus:getVolume
do
    local bus = lurek.audio.newBus("music")
    bus:setVolume(0.8)
    local v = bus:getVolume()
    print("volume = " .. v)
end

--@api-stub: LBus:setPitch
do
    local bus = lurek.audio.newBus("fx")
    bus:setPitch(1.2)
    print("bus pitch = " .. bus:getPitch())
end

--@api-stub: LBus:getPitch
do
    local bus = lurek.audio.newBus("ambient")
    bus:setPitch(0.9)
    local p = bus:getPitch()
    print("pitch = " .. p)
end

--@api-stub: LBus:pause
do
    local bus = lurek.audio.newBus("dialog")
    bus:pause()
    print("bus paused = " .. tostring(bus:isPaused()))
end

--@api-stub: LBus:resume
do
    local bus = lurek.audio.newBus("world")
    bus:pause()
    bus:resume()
    print("bus resumed = " .. tostring(not bus:isPaused()))
end

--@api-stub: LBus:isPaused
do
    local bus = lurek.audio.newBus("ui")
    bus:pause()
    print("paused = " .. tostring(bus:isPaused()))
end

--@api-stub: LBus:type
do
    local bus = lurek.audio.newBus("test")
    print("type = " .. bus:type())
end

--@api-stub: LBus:typeOf
do
    local bus = lurek.audio.newBus("check")
    print("is LBus = " .. tostring(bus:typeOf("LBus")))
end

--@api-stub: LBus:setDuckTarget
do
    local music = lurek.audio.newBus("bg_music")
    local voice = lurek.audio.newBus("voice_over")
    voice:setDuckTarget("bg_music", 0.3)
    print("ducking bg_music to 0.3 when voice active")
end

--@api-stub: LBus:clearDuck
do
    local bus = lurek.audio.newBus("narrator")
    bus:setDuckTarget("bg_music", 0.2)
    bus:clearDuck()
    print("duck cleared")
end

--@api-stub: LBus:getPeak
do
    local bus = lurek.audio.newBus("meter_bus")
    local peak = bus:getPeak()
    print("peak = " .. peak)
end

--@api-stub: LMidiPlayer:load
do
    local player = lurek.audio.newMidiPlayer()
    local path = "content/examples/assets/audio/sample_midi.mid"
    local ok = player:load(path)
    print("loaded = " .. tostring(ok))
end

--@api-stub: LMidiPlayer:loadData
do
    local player = lurek.audio.newMidiPlayer()
    local data = string.char(77,84,104,100,0,0,0,6,0,0,0,1,0,96,77,84,114,107,0,0,0,4,0,255,47,0)
    local ok = player:loadData(data)
    print("loaded data = " .. tostring(ok))
end

--@api-stub: LMidiPlayer:isLoaded
do
    local player = lurek.audio.newMidiPlayer()
    print("loaded = " .. tostring(player:isLoaded()))
end

--@api-stub: LMidiPlayer:getFilePath
do
    local path = "content/examples/assets/audio/sample_midi.mid"
    local player = lurek.audio.newMidiPlayer(path)
    print("file = " .. tostring(player:getFilePath()))
end

--@api-stub: LMidiPlayer:setSoundFont
do
    local player = lurek.audio.newMidiPlayer()
    local sf_path = "content/examples/assets/audio/sample_soundfont.sf2"
    local ok = pcall(function() player:setSoundFont(sf_path) end)
    print("sf = " .. tostring(ok and player:getSoundFontPath()))
end

--@api-stub: LMidiPlayer:getSoundFontPath
do
    local player = lurek.audio.newMidiPlayer()
    local sf_path = "content/examples/assets/audio/sample_soundfont.sf2"
    local ok = pcall(function() player:setSoundFont(sf_path) end)
    local p = ok and player:getSoundFontPath() or nil
    print("soundfont = " .. tostring(p))
end

--@api-stub: LMidiPlayer:useDefaultSoundFont
do
    local player = lurek.audio.newMidiPlayer()
    player:useDefaultSoundFont()
    print("using default soundfont")
end

--@api-stub: LMidiPlayer:play
do
    local path = "content/examples/assets/audio/sample_midi.mid"
    local player = lurek.audio.newMidiPlayer(path)
    player:play()
    print("midi playing = " .. tostring(player:isPlaying()))
end

--@api-stub: LMidiPlayer:pause
do
    local path = "content/examples/assets/audio/sample_midi.mid"
    local player = lurek.audio.newMidiPlayer(path)
    player:play()
    player:pause()
    print("midi paused = " .. tostring(player:isPaused()))
end

--- Audio Examples Part 4: LMidiPlayer (cont.), LSoundPool, LDecoder methods

--@api-stub: LMidiPlayer:stop
do
    local path = "content/examples/assets/audio/sample_midi.mid"
    local player = lurek.audio.newMidiPlayer(path)
    player:play()
    player:stop()
    print("midi stopped")
end

--@api-stub: LMidiPlayer:isPlaying
do
    local path = "content/examples/assets/audio/sample_midi.mid"
    local player = lurek.audio.newMidiPlayer(path)
    player:play()
    print("playing = " .. tostring(player:isPlaying()))
end

--@api-stub: LMidiPlayer:isPaused
do
    local path = "content/examples/assets/audio/sample_midi.mid"
    local player = lurek.audio.newMidiPlayer(path)
    player:play()
    player:pause()
    print("paused = " .. tostring(player:isPaused()))
end

--@api-stub: LMidiPlayer:seek
do
    local path = "content/examples/assets/audio/sample_midi.mid"
    local player = lurek.audio.newMidiPlayer(path)
    player:play()
    player:seek(5.0)
    print("seeked to " .. player:tell())
end

--@api-stub: LMidiPlayer:tell
do
    local path = "content/examples/assets/audio/sample_midi.mid"
    local player = lurek.audio.newMidiPlayer(path)
    player:play()
    local pos = player:tell()
    print("position = " .. pos)
end

--@api-stub: LMidiPlayer:getDuration
do
    local path = "content/examples/assets/audio/sample_midi.mid"
    local player = lurek.audio.newMidiPlayer(path)
    local dur = player:getDuration()
    print("duration = " .. dur .. "s")
end

--@api-stub: LMidiPlayer:setLooping
do
    local path = "content/examples/assets/audio/sample_midi.mid"
    local player = lurek.audio.newMidiPlayer(path)
    player:setLooping(true)
    print("looping = " .. tostring(player:isLooping()))
end

--@api-stub: LMidiPlayer:isLooping
do
    local path = "content/examples/assets/audio/sample_midi.mid"
    local player = lurek.audio.newMidiPlayer(path)
    player:setLooping(true)
    print("isLooping = " .. tostring(player:isLooping()))
end

--@api-stub: LMidiPlayer:setVolume
do
    local player = lurek.audio.newMidiPlayer()
    player:setVolume(0.7)
    print("volume = " .. player:getVolume())
end

--@api-stub: LMidiPlayer:getVolume
do
    local player = lurek.audio.newMidiPlayer()
    player:setVolume(0.5)
    local v = player:getVolume()
    print("volume = " .. v)
end

--@api-stub: LMidiPlayer:setBus
do
    local player = lurek.audio.newMidiPlayer()
    local bus = lurek.audio.newBus("midi_bus")
    player:setBus(bus)
    print("bus set")
end

--@api-stub: LMidiPlayer:getBus
do
    local player = lurek.audio.newMidiPlayer()
    local bus = lurek.audio.newBus("midi_out")
    player:setBus(bus)
    local b = player:getBus()
    print("bus = " .. b:getName())
end

--@api-stub: LMidiPlayer:setTempo
do
    local player = lurek.audio.newMidiPlayer()
    player:setTempo(140)
    print("tempo = " .. player:getTempo())
end

--@api-stub: LMidiPlayer:getTempo
do
    local player = lurek.audio.newMidiPlayer()
    player:setTempo(120)
    local t = player:getTempo()
    print("tempo = " .. t)
end

--@api-stub: LMidiPlayer:getOriginalTempo
do
    local path = "content/examples/assets/audio/sample_midi.mid"
    local player = lurek.audio.newMidiPlayer(path)
    local orig = player:getOriginalTempo()
    print("original tempo = " .. orig)
end

--@api-stub: LMidiPlayer:setTempoScale
do
    local player = lurek.audio.newMidiPlayer()
    player:setTempoScale(1.5)
    print("tempo scale = " .. player:getTempoScale())
end

--@api-stub: LMidiPlayer:getTempoScale
do
    local player = lurek.audio.newMidiPlayer()
    player:setTempoScale(0.8)
    local s = player:getTempoScale()
    print("scale = " .. s)
end

--@api-stub: LMidiPlayer:getTicksPerBeat
do
    local path = "content/examples/assets/audio/sample_midi.mid"
    local player = lurek.audio.newMidiPlayer(path)
    local tpb = player:getTicksPerBeat()
    print("ticks/beat = " .. tpb)
end

--@api-stub: LMidiPlayer:setChannelVolume
do
    local player = lurek.audio.newMidiPlayer()
    player:setChannelVolume(1, 0.8)
    print("ch1 volume = " .. player:getChannelVolume(1))
end

--@api-stub: LMidiPlayer:getChannelVolume
do
    local player = lurek.audio.newMidiPlayer()
    player:setChannelVolume(2, 0.6)
    local v = player:getChannelVolume(2)
    print("ch2 volume = " .. v)
end

--@api-stub: LMidiPlayer:setChannelMuted
do
    local player = lurek.audio.newMidiPlayer()
    player:setChannelMuted(10, true)
    print("ch10 muted = " .. tostring(player:isChannelMuted(10)))
end

--@api-stub: LMidiPlayer:isChannelMuted
do
    local player = lurek.audio.newMidiPlayer()
    player:setChannelMuted(3, true)
    print("ch3 muted = " .. tostring(player:isChannelMuted(3)))
end

--@api-stub: LMidiPlayer:setChannelInstrument
do
    local player = lurek.audio.newMidiPlayer()
    player:setChannelInstrument(1, 25)
    print("ch1 instrument = " .. player:getChannelInstrument(1))
end

--@api-stub: LMidiPlayer:getChannelInstrument
do
    local player = lurek.audio.newMidiPlayer()
    player:setChannelInstrument(2, 48)
    local inst = player:getChannelInstrument(2)
    print("ch2 instrument = " .. inst)
end

--@api-stub: LMidiPlayer:getChannelCount
do
    local path = "content/examples/assets/audio/sample_midi.mid"
    local player = lurek.audio.newMidiPlayer(path)
    local count = player:getChannelCount()
    print("channels = " .. count)
end

--@api-stub: LMidiPlayer:soloChannel
do
    local player = lurek.audio.newMidiPlayer()
    player:soloChannel(1)
    print("ch1 soloed")
end

--@api-stub: LMidiPlayer:unsoloAll
do
    local player = lurek.audio.newMidiPlayer()
    player:soloChannel(1)
    player:unsoloAll()
    print("unsolo all done")
end

--@api-stub: LMidiPlayer:getTrackCount
do
    local path = "content/examples/assets/audio/sample_midi.mid"
    local player = lurek.audio.newMidiPlayer(path)
    local count = player:getTrackCount()
    print("tracks = " .. count)
end

--@api-stub: LMidiPlayer:getTrackName
do
    local path = "content/examples/assets/audio/sample_midi.mid"
    local player = lurek.audio.newMidiPlayer(path)
    local name = player:getTrackName(1)
    print("track 1 = " .. tostring(name))
end

--@api-stub: LMidiPlayer:setTrackMuted
do
    local path = "content/examples/assets/audio/sample_midi.mid"
    local player = lurek.audio.newMidiPlayer(path)
    player:setTrackMuted(1, true)
    print("track 1 muted = " .. tostring(player:isTrackMuted(1)))
end

--@api-stub: LMidiPlayer:isTrackMuted
do
    local path = "content/examples/assets/audio/sample_midi.mid"
    local player = lurek.audio.newMidiPlayer(path)
    player:setTrackMuted(2, true)
    print("track 2 muted = " .. tostring(player:isTrackMuted(2)))
end

--@api-stub: LMidiPlayer:getNoteCount
do
    local path = "content/examples/assets/audio/sample_midi.mid"
    local player = lurek.audio.newMidiPlayer(path)
    local notes = player:getNoteCount()
    print("notes = " .. notes)
end

--@api-stub: LMidiPlayer:setOnNoteOn
do
    local player = lurek.audio.newMidiPlayer()
    player:setOnNoteOn(function(ch, note, vel)
        print("note on: ch=" .. ch .. " note=" .. note .. " vel=" .. vel)
    end)
    print("onNoteOn callback set")
end

--@api-stub: LMidiPlayer:setOnNoteOff
do
    local player = lurek.audio.newMidiPlayer()
    player:setOnNoteOff(function(ch, note)
        print("note off: ch=" .. ch .. " note=" .. note)
    end)
    print("onNoteOff callback set")
end

--@api-stub: LMidiPlayer:setOnEnd
do
    local player = lurek.audio.newMidiPlayer()
    player:setOnEnd(function()
        print("midi playback ended")
    end)
    print("onEnd callback set")
end

--@api-stub: LMidiPlayer:getSampleRate
do
    local player = lurek.audio.newMidiPlayer()
    local rate = player:getSampleRate()
    print("sample rate = " .. rate)
end

--@api-stub: LMidiPlayer:setSampleRate
do
    local player = lurek.audio.newMidiPlayer()
    player:setSampleRate(48000)
    print("sample rate = " .. player:getSampleRate())
end

--@api-stub: LMidiPlayer:getChannels
do
    local player = lurek.audio.newMidiPlayer()
    local ch = player:getChannels()
    print("output channels = " .. ch)
end

--@api-stub: LMidiPlayer:setChannels
do
    local player = lurek.audio.newMidiPlayer()
    player:setChannels(2)
    print("set stereo output")
end

--@api-stub: LMidiPlayer:type
do
    local player = lurek.audio.newMidiPlayer()
    print("type = " .. player:type())
end

--@api-stub: LMidiPlayer:typeOf
do
    local player = lurek.audio.newMidiPlayer()
    print("is LMidiPlayer = " .. tostring(player:typeOf("LMidiPlayer")))
end

--@api-stub: LSoundPool:play
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local pool = lurek.audio.newPool(path, 4)
    local id = pool:play()
    print("playing voice id = " .. id)
end

--@api-stub: LSoundPool:stopAll
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local pool = lurek.audio.newPool(path, 4)
    pool:play()
    pool:stopAll()
    print("all voices stopped")
end

--@api-stub: LSoundPool:setVolume
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local pool = lurek.audio.newPool(path, 4)
    pool:setVolume(0.5)
    print("pool volume = 0.5")
end

--@api-stub: LSoundPool:setBus
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local pool = lurek.audio.newPool(path, 4)
    lurek.audio.newBus("pool_bus")
    pool:setBus("pool_bus")
    print("pool routed to pool_bus")
end

--@api-stub: LSoundPool:release
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local pool = lurek.audio.newPool(path, 4)
    pool:release()
    print("pool released")
end

--@api-stub: LSoundPool:getVoiceCount
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local pool = lurek.audio.newPool(path, 8)
    print("voices = " .. pool:getVoiceCount())
end

--@api-stub: LSoundPool:type
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local pool = lurek.audio.newPool(path, 2)
    print("type = " .. pool:type())
end

--@api-stub: LSoundPool:typeOf
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local pool = lurek.audio.newPool(path, 2)
    print("is LSoundPool = " .. tostring(pool:typeOf("LSoundPool")))
end

--@api-stub: LDecoder:decode
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local dec = lurek.audio.newDecoder(path, 4096)
    local chunk = dec:decode()
    print("decoded chunk = " .. tostring(chunk ~= nil))
end

--- Audio Examples Part 5: LDecoder methods, LSoundData methods

--@api-stub: LDecoder:getChannelCount
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local dec = lurek.audio.newDecoder(path)
    local ch = dec:getChannelCount()
    print("channels = " .. ch)
end

--@api-stub: LDecoder:getBitDepth
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local dec = lurek.audio.newDecoder(path)
    local bits = dec:getBitDepth()
    print("bit depth = " .. bits)
end

--@api-stub: LDecoder:getSampleRate
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local dec = lurek.audio.newDecoder(path)
    local rate = dec:getSampleRate()
    print("sample rate = " .. rate)
end

--@api-stub: LDecoder:getDuration
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local dec = lurek.audio.newDecoder(path)
    local dur = dec:getDuration()
    print("duration = " .. dur .. "s")
end

--@api-stub: LDecoder:seek
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local dec = lurek.audio.newDecoder(path)
    dec:seek(2.5)
    print("seeked to " .. dec:tell())
end

--@api-stub: LDecoder:rewind
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local dec = lurek.audio.newDecoder(path)
    dec:seek(5.0)
    dec:rewind()
    print("rewound to " .. dec:tell())
end

--@api-stub: LDecoder:tell
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local dec = lurek.audio.newDecoder(path)
    dec:seek(3.0)
    local pos = dec:tell()
    print("position = " .. pos)
end

--@api-stub: LDecoder:isSeekable
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local dec = lurek.audio.newDecoder(path)
    print("seekable = " .. tostring(dec:isSeekable()))
end

--@api-stub: LDecoder:release
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local dec = lurek.audio.newDecoder(path)
    dec:release()
    print("decoder released")
end

--@api-stub: LDecoder:type
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local dec = lurek.audio.newDecoder(path)
    print("type = " .. dec:type())
end

--@api-stub: LDecoder:typeOf
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local dec = lurek.audio.newDecoder(path)
    print("is LDecoder = " .. tostring(dec:typeOf("LDecoder")))
end

--@api-stub: LSoundData:getSampleCount
do
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    local count = sd:getSampleCount()
    print("samples = " .. count)
end

--@api-stub: LSoundData:getSampleRate
do
    local sd = lurek.audio.newSoundData(22050, 22050, 1)
    local rate = sd:getSampleRate()
    print("sample rate = " .. rate)
end

--@api-stub: LSoundData:getChannelCount
do
    local sd = lurek.audio.newSoundData(44100, 44100, 2)
    local ch = sd:getChannelCount()
    print("channels = " .. ch)
end

--@api-stub: LSoundData:getDuration
do
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    local dur = sd:getDuration()
    print("duration = " .. dur .. "s")
end

--@api-stub: LSoundData:getBitDepth
do
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    local bits = sd:getBitDepth()
    print("bit depth = " .. bits)
end

--@api-stub: LSoundData:getSample
do
    local sd = lurek.audio.newSineWave(440, 0.1, 44100, 1.0)
    local val = sd:getSample(0)
    print("sample[0] = " .. val)
end

--@api-stub: LSoundData:drawWaveform
do
    local sd = lurek.audio.newSineWave(440, 1.0, 44100, 0.8)
    local img = lurek.image.newImageData(400, 100)
    sd:drawWaveform(img, 0, 0, 400, 100, 0, 255, 0, 255)
    print("waveform drawn to image")
end

--@api-stub: LSoundData:setSample
do
    local sd = lurek.audio.newSoundData(100, 44100, 1)
    sd:setSample(0, 0.5)
    sd:setSample(50, -0.3)
    print("sample[0] = " .. sd:getSample(0) .. " sample[50] = " .. sd:getSample(50))
end

--@api-stub: LSoundData:type
do
    local sd = lurek.audio.newSoundData(100, 44100, 1)
    print("type = " .. sd:type())
end

--@api-stub: LSoundData:typeOf
do
    local sd = lurek.audio.newSoundData(100, 44100, 1)
    print("is LSoundData = " .. tostring(sd:typeOf("LSoundData")))
end

--@api-stub: lurek.audio.newSynthWave
do
    local sd = lurek.audio.newSynthWave("sine", 440, 0.5, 44100, 0.8)
    print("newSynthWave sampleCount = " .. sd:getSampleCount())
end
