-- content/examples/audio.lua
-- Auto-generated from content/examples2/audio_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/audio.lua

--- Audio Examples Part 1: Source creation, playback control, volume, pitch, pan, master, bus, filters, spatial


--@api: lurek.audio.newSource
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    local source_type = lurek.audio.getSourceType(src)
    lurek.log.info(tostring("source created = " .. tostring(src ~= nil)))
    lurek.log.info(tostring("path = " .. path))
    lurek.log.info(tostring("source type = " .. tostring(source_type)))
end

--@api: lurek.audio.play
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.play(src)
    lurek.log.info(tostring("play requested for = " .. path))
    lurek.log.info(tostring("playing = " .. tostring(lurek.audio.isPlaying(src))))
end

--@api: lurek.audio.stop
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.play(src)
    lurek.log.info(tostring("before stop playing = " .. tostring(lurek.audio.isPlaying(src))))
    lurek.audio.stop(src)
    lurek.log.info(tostring("stopped = " .. tostring(lurek.audio.isStopped(src))))
end

--@api: lurek.audio.setVolume
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.log.info(tostring("volume before = " .. tostring(lurek.audio.getVolume(src))))
    lurek.audio.setVolume(src, 0.5)
    lurek.log.info(tostring("volume after = " .. tostring(lurek.audio.getVolume(src))))
end

--@api: lurek.audio.getVolume
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setVolume(src, 0.8)
    local vol = lurek.audio.getVolume(src)
    lurek.log.info(tostring("configured volume = 0.8"))
    lurek.log.info(tostring("volume = " .. tostring(vol)))
end

--@api: lurek.audio.pause
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.play(src)
    lurek.log.info(tostring("playing before pause = " .. tostring(lurek.audio.isPlaying(src))))
    lurek.audio.pause(src)
    lurek.log.info(tostring("paused = " .. tostring(lurek.audio.isPaused(src))))
end

--@api: lurek.audio.resume
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.play(src)
    lurek.audio.pause(src)
    lurek.log.info(tostring("paused before resume = " .. tostring(lurek.audio.isPaused(src))))
    lurek.audio.resume(src)
    lurek.log.info(tostring("playing after resume = " .. tostring(lurek.audio.isPlaying(src))))
end

--@api: lurek.audio.setPitch
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.log.info(tostring("pitch before = " .. tostring(lurek.audio.getPitch(src))))
    lurek.audio.setPitch(src, 1.5)
    lurek.log.info(tostring("pitch after = " .. tostring(lurek.audio.getPitch(src))))
end

--@api: lurek.audio.getPitch
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setPitch(src, 0.8)
    local p = lurek.audio.getPitch(src)
    lurek.log.info(tostring("configured pitch = 0.8"))
    lurek.log.info(tostring("pitch = " .. tostring(p)))
end

--@api: lurek.audio.isPlaying
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.log.info(tostring("before play = " .. tostring(lurek.audio.isPlaying(src))))
    lurek.audio.play(src)
    lurek.log.info(tostring("after play = " .. tostring(lurek.audio.isPlaying(src))))
end

--@api: lurek.audio.isPaused
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.play(src)
    lurek.audio.pause(src)
    lurek.log.info(tostring("playing now = " .. tostring(lurek.audio.isPlaying(src))))
    lurek.log.info(tostring("isPaused = " .. tostring(lurek.audio.isPaused(src))))
end

--@api: lurek.audio.isStopped
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    local stoppedBefore = lurek.audio.isStopped(src)
    lurek.audio.play(src)
    local playingDuring = lurek.audio.isPlaying(src)
    lurek.audio.stop(src)
    local stoppedAfter = lurek.audio.isStopped(src)
    lurek.log.info("ui click stopped before=" .. tostring(stoppedBefore) .. " playing during=" .. tostring(playingDuring))
    lurek.log.info("ui click stopped after=" .. tostring(stoppedAfter))
end

--@api: lurek.audio.setLooping
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    lurek.log.info(tostring("looping before = " .. tostring(lurek.audio.isLooping(src))))
    lurek.audio.setLooping(src, true)
    lurek.log.info(tostring("looping after = " .. tostring(lurek.audio.isLooping(src))))
end

--@api: lurek.audio.isLooping
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.setLooping(src, true)
    lurek.log.info(tostring("source type = " .. tostring(lurek.audio.getSourceType(src))))
    lurek.log.info(tostring("isLooping = " .. tostring(lurek.audio.isLooping(src))))
end

--@api: lurek.audio.playLooping
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.playLooping(src)
    lurek.log.info(tostring("playing = " .. tostring(lurek.audio.isPlaying(src))))
    lurek.log.info(tostring("playing+looping = " .. tostring(lurek.audio.isPlaying(src) and lurek.audio.isLooping(src))))
end

--@api: lurek.audio.setPan
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.log.info(tostring("pan before = " .. tostring(lurek.audio.getPan(src))))
    lurek.audio.setPan(src, -0.5)
    lurek.log.info(tostring("pan after = " .. tostring(lurek.audio.getPan(src))))
end

--@api: lurek.audio.getPan
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setPan(src, 0.7)
    local pan = lurek.audio.getPan(src)
    lurek.log.info(tostring("configured pan = 0.7"))
    lurek.log.info(tostring("pan = " .. tostring(pan)))
end

--@api: lurek.audio.setMasterVolume
do
    local before = lurek.audio.getMasterVolume()
    lurek.audio.setMasterVolume(0.75)
    local quieter = lurek.audio.getMasterVolume()
    lurek.audio.setMasterVolume(1.0)
    local restored = lurek.audio.getMasterVolume()
    lurek.log.info("master volume before=" .. tostring(before) .. " quieter=" .. tostring(quieter))
    lurek.log.info("master volume restored=" .. tostring(restored))
end

--@api: lurek.audio.getMasterVolume
do
    lurek.audio.setMasterVolume(1.0)
    local mv = lurek.audio.getMasterVolume()
    lurek.audio.setMasterVolume(0.6)
    local ducked = lurek.audio.getMasterVolume()
    lurek.audio.setMasterVolume(1.0)
    lurek.log.info("master volume default=" .. tostring(mv))
    lurek.log.info("master volume ducked=" .. tostring(ducked))
end

--@api: lurek.audio.getActiveSourceCount
do
    local count = lurek.audio.getActiveSourceCount()
    local total = lurek.audio.getSourceCount()
    local idle = total - count
    lurek.log.info("active sources=" .. tostring(count))
    lurek.log.info("registered sources=" .. tostring(total) .. " idle=" .. tostring(idle))
end

--@api: lurek.audio.getSourceCount
do
    local total = lurek.audio.getSourceCount()
    local active = lurek.audio.getActiveSourceCount()
    local idle = total - active
    lurek.log.info("source registry count=" .. tostring(total))
    lurek.log.info("active sources=" .. tostring(active) .. " idle=" .. tostring(idle))
end

--@api: lurek.audio.getSourceType
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    local stype = lurek.audio.getSourceType(src)
    lurek.log.info(tostring("path = " .. path))
    lurek.log.info(tostring("source type = " .. tostring(stype)))
end

--@api: lurek.audio.clone
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setVolume(src, 0.6)
    local copy = lurek.audio.clone(src)
    lurek.log.info(tostring("original volume = " .. tostring(lurek.audio.getVolume(src))))
    lurek.log.info(tostring("clone volume = " .. tostring(lurek.audio.getVolume(copy))))
end

--@api: lurek.audio.pauseAll
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.play(src)
    lurek.audio.pauseAll()
    lurek.log.info(tostring("all paused"))
    lurek.log.info(tostring("sample source paused = " .. tostring(lurek.audio.isPaused(src))))
end

--@api: lurek.audio.stopAll
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.play(src)
    lurek.audio.stopAll()
    lurek.log.info(tostring("all stopped"))
    lurek.log.info(tostring("sample source stopped = " .. tostring(lurek.audio.isStopped(src))))
end

--@api: lurek.audio.resumeAll
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.play(src)
    lurek.audio.pauseAll()
    lurek.audio.resumeAll()
    lurek.log.info(tostring("all resumed"))
    lurek.log.info(tostring("sample source playing = " .. tostring(lurek.audio.isPlaying(src))))
end

--@api: lurek.audio.manager.pauseAll
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.play(src)
    lurek.audio.manager.pauseAll()
    lurek.log.info(tostring("manager.pauseAll called"))
    lurek.log.info(tostring("sample source paused = " .. tostring(lurek.audio.isPaused(src))))
end

--@api: lurek.audio.manager.resumeAll
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.play(src)
    lurek.audio.manager.pauseAll()
    lurek.audio.manager.resumeAll()
    lurek.log.info(tostring("manager.resumeAll called"))
    lurek.log.info(tostring("sample source playing = " .. tostring(lurek.audio.isPlaying(src))))
end

--@api: lurek.audio.release
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    local before = lurek.audio.getSourceCount()
    lurek.audio.release(src)
    lurek.log.info(tostring("source released"))
    lurek.log.info(tostring("source count before release = " .. tostring(before)))
end

--@api: lurek.audio.newBus
do
    local bus = lurek.audio.newBus("sfx")
    bus:setVolume(0.8)
    bus:setPitch(1.05)
    local peak = bus:getPeak()
    lurek.log.info("bus created name=" .. bus:getName())
    lurek.log.info("bus volume=" .. tostring(bus:getVolume()) .. " pitch=" .. tostring(bus:getPitch()) .. " peak=" .. tostring(peak))
end

--@api: lurek.audio.setSourceBus
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    local bus = lurek.audio.newBus("effects")
    lurek.audio.setSourceBus(src, bus)
    local assigned = lurek.audio.getSourceBus(src)
    lurek.log.info(tostring("bus assigned = " .. tostring(assigned ~= nil)))
    lurek.log.info(tostring("bus = " .. assigned:getName()))
end

--@api: lurek.audio.getSourceBus
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    local bus = lurek.audio.newBus("ui")
    lurek.audio.setSourceBus(src, bus)
    local assigned = lurek.audio.getSourceBus(src)
    lurek.log.info(tostring("source bus exists = " .. tostring(assigned ~= nil)))
    lurek.log.info(tostring("source bus = " .. assigned:getName()))
end

--@api: lurek.audio.getMaxSources
do
    local max = lurek.audio.getMaxSources()
    local total = lurek.audio.getSourceCount()
    local active = lurek.audio.getActiveSourceCount()
    local free = max - active
    lurek.log.info("audio max sources=" .. tostring(max))
    lurek.log.info("audio total=" .. tostring(total) .. " active=" .. tostring(active) .. " free_estimate=" .. tostring(free))
end

--@api: lurek.audio.getDuration
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    local dur = lurek.audio.getDuration(src) or 0
    lurek.log.info(tostring("path = " .. path))
    lurek.log.info(tostring("duration = " .. tostring(dur) .. "s"))
end

--@api: lurek.audio.tell
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.play(src)
    local pos = lurek.audio.tell(src)
    lurek.log.info(tostring("playing = " .. tostring(lurek.audio.isPlaying(src))))
    lurek.log.info(tostring("position = " .. tostring(pos)))
end

--@api: lurek.audio.seek
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.play(src)
    lurek.audio.seek(src, 5.0)
    lurek.log.info(tostring("seek target = 5.0"))
    lurek.log.info(tostring("position after seek = " .. tostring(lurek.audio.tell(src))))
end

--@api: lurek.audio.setLowpass
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.setLowpass(src, 800)
    lurek.log.info(tostring("lowpass set to 800 Hz"))
    lurek.log.info(tostring("lowpass = " .. tostring(lurek.audio.getLowpass(src)) .. " Hz"))
end

--@api: lurek.audio.setHighpass
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setHighpass(src, 2000)
    lurek.log.info(tostring("highpass set to 2000 Hz"))
    lurek.log.info(tostring("highpass = " .. tostring(lurek.audio.getHighpass(src)) .. " Hz"))
end

--@api: lurek.audio.getLowpass
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setLowpass(src, 500)
    local lp = lurek.audio.getLowpass(src)
    lurek.log.info(tostring("configured lowpass = 500"))
    lurek.log.info(tostring("lowpass = " .. tostring(lp)))
end

--@api: lurek.audio.getHighpass
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setHighpass(src, 3000)
    local hp = lurek.audio.getHighpass(src)
    lurek.log.info(tostring("configured highpass = 3000"))
    lurek.log.info(tostring("highpass = " .. tostring(hp)))
end

--@api: lurek.audio.newBeatClock
do
    local clock = lurek.audio.newBeatClock(120.0, { subdivision = 8, swing = 0.2, latency_ms = 5 })
    clock:start()
    clock:update(0.25)
    lurek.log.info(tostring("beat clock beat = " .. tostring(clock:getBeat())))
    lurek.log.info(tostring("beat clock bar = " .. tostring(clock:getBar())))
end

--@api: lurek.audio.beatClockFromSource
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.play(src)
    local clock = lurek.audio.beatClockFromSource(src, 128.0, { subdivision = 4 })
    lurek.log.info(tostring("synced clock beat = " .. tostring(clock:getBeat())))
    lurek.log.info(tostring("synced clock running = " .. tostring(clock:isRunning())))
end

--@api: lurek.audio.judgeBeat
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    local verdict, err = lurek.audio.judgeBeat(clock, 4, 0.0)
    local earlyVerdict, earlyErr = lurek.audio.judgeBeat(clock, 4, -0.04)
    lurek.log.info("judgeBeat center verdict=" .. tostring(verdict) .. " error=" .. tostring(err))
    lurek.log.info("judgeBeat early verdict=" .. tostring(earlyVerdict) .. " error=" .. tostring(earlyErr))
end

--@api: LBeatClock:every
do
    local clock = lurek.audio.newBeatClock(60.0, { subdivision = 4 })
    local hits = 0
    local every_h = clock:every(4, function() hits = hits + 1 end)
    clock:start()
    clock:update(1.1)
    lurek.log.info("metronome every handle=" .. tostring(every_h ~= nil))
    lurek.log.info("metronome quarter hits=" .. tostring(hits))
end

--@api: LBeatClock:at
do
    local clock = lurek.audio.newBeatClock(60.0, { subdivision = 4 })
    local chorusCue = 0
    local at_h = clock:at(1.0, function(beat) chorusCue = beat end)
    clock:start()
    clock:update(1.1)
    lurek.log.info("cue at handle=" .. tostring(at_h ~= nil))
    lurek.log.info("cue triggered beat=" .. tostring(chorusCue))
end

--@api: LBeatClock:pattern
do
    local clock = lurek.audio.newBeatClock(60.0, { subdivision = 4 })
    local steps = {}
    local pattern_h = clock:pattern("x.x.", function(step) steps[#steps + 1] = step end)
    clock:start()
    clock:update(2.1)
    lurek.log.info("snare pattern handle=" .. tostring(pattern_h ~= nil))
    lurek.log.info("snare pattern fired=" .. tostring(#steps))
end

--@api: LBeatClock:cancel
do
    local clock = lurek.audio.newBeatClock(60.0, { subdivision = 4 })
    local handle = clock:every(4, function() end)
    local cancelled = clock:cancel(handle)
    clock:start()
    local events = clock:update(1.1)
    lurek.log.info("cancel returned=" .. tostring(cancelled))
    lurek.log.info("cancel update events=" .. tostring(#events))
end

--@api: LBeatClock:cancelAll
do
    local clock = lurek.audio.newBeatClock(60.0, { subdivision = 4 })
    clock:every(4, function() end)
    clock:pattern("x.x.", function() end)
    clock:cancelAll()
    clock:start()
    local events = clock:update(1.1)
    lurek.log.info("cancelAll ok")
    lurek.log.info("cancelAll update events=" .. tostring(#events))
end

--@api: LBeatClock:beatTimeRemaining
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    clock:start()
    clock:tick(0.125)
    local eighth = clock:beatTimeRemaining(8)
    local quarter = clock:beatTimeRemaining(4)
    lurek.log.info("beat time remaining eighth=" .. tostring(eighth))
    lurek.log.info("beat time remaining quarter=" .. tostring(quarter))
end

--@api: LBeatClock:beatsPerBar
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    clock:setBeatsPerBar(3)
    local barLen = clock:beatsPerBar()
    clock:start()
    clock:tick(1.1)
    lurek.log.info("waltz beatsPerBar=" .. tostring(barLen))
    lurek.log.info("waltz bar position=" .. tostring(clock:getBar()))
end

--@api: LBeatClock:bpm
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    clock:setBpm(140.0)
    local bpm = clock:bpm()
    local spb = clock:secondsPerBeat()
    lurek.log.info("boss section bpm=" .. tostring(bpm))
    lurek.log.info("boss section secondsPerBeat=" .. tostring(spb))
end

--@api: LBeatClock:drainFired
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    clock:scheduleAt(1.0)
    clock:tick(0.6)
    clock:tick(0.6)
    local fired = clock:drainFired()
    lurek.log.info(tostring("drainFired count = " .. tostring(#fired)))
end

--@api: LBeatClock:dump
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    clock:start()
    local snap = clock:dump()
    local beat = snap.beat or snap.current_beat or 0
    local running = snap.running or false
    lurek.log.info("clock dump type=" .. type(snap))
    lurek.log.info("clock dump beat=" .. tostring(beat) .. " running=" .. tostring(running))
end

--@api: LBeatClock:getBar
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    clock:start()
    clock:tick(1.1)
    local bar = clock:getBar()
    local beat = clock:getBeat()
    lurek.log.info("bar position=" .. tostring(bar))
    lurek.log.info("bar companion beat=" .. tostring(beat))
end

--@api: LBeatClock:getBeat
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    clock:start()
    clock:tick(0.75)
    local beat = clock:getBeat()
    local phase = clock:getPhase(4)
    lurek.log.info("beat position=" .. tostring(beat))
    lurek.log.info("beat phase quarter=" .. tostring(phase))
end

--@api: LBeatClock:getBpm
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    clock:setBpm(128.0)
    local bpm = clock:getBpm()
    local spb = clock:secondsPerBeat()
    lurek.log.info("getBpm=" .. tostring(bpm))
    lurek.log.info("getBpm secondsPerBeat=" .. tostring(spb))
end

--@api: LBeatClock:getPhase
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    clock:start()
    clock:tick(0.125)
    local eighth = clock:getPhase(8)
    local quarter = clock:getPhase(4)
    lurek.log.info("phase eighth=" .. tostring(eighth))
    lurek.log.info("phase quarter=" .. tostring(quarter))
end

--@api: LBeatClock:isOnBeat
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    clock:start()
    clock:tick(0.5)
    local onBeat = clock:isOnBeat()
    local tight = clock:isOnBeat(4, 0.02)
    lurek.log.info("isOnBeat default=" .. tostring(onBeat))
    lurek.log.info("isOnBeat tight=" .. tostring(tight))
end

--@api: LBeatClock:isRunning
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    clock:start()
    local running = clock:isRunning()
    clock:stop()
    local stopped = clock:isRunning()
    lurek.log.info("clock running after start=" .. tostring(running))
    lurek.log.info("clock running after stop=" .. tostring(stopped))
end

--@api: LBeatClock:nearestBeat
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    clock:start()
    clock:tick(0.2)
    local beat, err = clock:nearestBeat(4)
    lurek.log.info(tostring("nearestBeat = " .. tostring(beat) .. " err = " .. tostring(err)))
end

--@api: LBeatClock:position
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    clock:start()
    clock:tick(0.5)
    local pos = clock:position()
    lurek.log.info(tostring("position beat = " .. tostring(pos.beat) .. " bar = " .. tostring(pos.bar)))
end

--@api: LBeatClock:quantise
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    local q = clock:quantise(1.3, 0.25)
    local q2 = clock:quantise(2.62, 0.5)
    lurek.log.info("quantise(1.3, 0.25)=" .. tostring(q))
    lurek.log.info("quantise(2.62, 0.5)=" .. tostring(q2))
end

--@api: LBeatClock:rampBpm
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    clock:rampBpm(150.0, 0.5)
    clock:update(0.5)
    local afterRamp = clock:getBpm()
    local spb = clock:secondsPerBeat()
    lurek.log.info("bpm after ramp=" .. tostring(afterRamp))
    lurek.log.info("secondsPerBeat after ramp=" .. tostring(spb))
end

--@api: LBeatClock:reset
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    clock:start()
    clock:tick(1.0)
    clock:reset()
    lurek.log.info(tostring("beat after reset = " .. tostring(clock:getBeat())))
end

--@api: LBeatClock:scheduleAt
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    local ok = clock:scheduleAt(2.0)
    clock:start()
    clock:tick(1.1)
    local fired = clock:drainFired()
    lurek.log.info("scheduleAt ok=" .. tostring(ok))
    lurek.log.info("scheduleAt fired count=" .. tostring(#fired))
end

--@api: LBeatClock:secondsPerBeat
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    local spb = clock:secondsPerBeat()
    local twoBeats = spb * 2
    lurek.log.info("secondsPerBeat=" .. tostring(spb))
    lurek.log.info("seconds for two beats=" .. tostring(twoBeats))
end

--@api: LBeatClock:secondsToNextBeat
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    clock:start()
    clock:tick(0.125)
    local nextBeat = clock:secondsToNextBeat()
    local remain = clock:beatTimeRemaining(4)
    lurek.log.info("secondsToNextBeat=" .. tostring(nextBeat))
    lurek.log.info("quarter remaining=" .. tostring(remain))
end

--@api: LBeatClock:setBeatsPerBar
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    clock:setBeatsPerBar(3)
    local beats = clock:beatsPerBar()
    clock:start()
    clock:tick(1.6)
    lurek.log.info("setBeatsPerBar now=" .. tostring(beats))
    lurek.log.info("setBeatsPerBar bar=" .. tostring(clock:getBar()))
end

--@api: LBeatClock:setBpm
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    clock:setBpm(90.0)
    local bpm = clock:getBpm()
    local spb = clock:secondsPerBeat()
    lurek.log.info("setBpm new bpm=" .. tostring(bpm))
    lurek.log.info("setBpm secondsPerBeat=" .. tostring(spb))
end

--@api: LBeatClock:setSwing
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    clock:setSwing(0.2)
    clock:start()
    clock:update(0.25)
    lurek.log.info(tostring("phase after swing = " .. tostring(clock:getPhase(8))))
end

--@api: LBeatClock:start
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    clock:start()
    local running = clock:isRunning()
    clock:tick(0.5)
    lurek.log.info("start running=" .. tostring(running))
    lurek.log.info("start beat after tick=" .. tostring(clock:getBeat()))
end

--@api: LBeatClock:stop
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    clock:start()
    clock:stop()
    local running = clock:isRunning()
    local beat = clock:getBeat()
    lurek.log.info("stop running=" .. tostring(running))
    lurek.log.info("stop preserved beat=" .. tostring(beat))
end

--@api: LBeatClock:syncToSource
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.play(src)
    local clock = lurek.audio.newBeatClock(120.0, 4)
    clock:syncToSource(src)
    lurek.log.info(tostring("synced beat = " .. tostring(clock:getBeat())))
end

--@api: LBeatClock:tap
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    local first = clock:tap(0.0)
    local second = clock:tap(0.5)
    local third = clock:tap(1.0)
    lurek.log.info("tap bpm first=" .. tostring(first) .. " second=" .. tostring(second))
    lurek.log.info("tap bpm third=" .. tostring(third))
end

--@api: LBeatClock:tick
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    clock:start()
    local crossings = clock:tick(0.5)
    local beat = clock:getBeat()
    lurek.log.info("tick crossings=" .. tostring(#crossings))
    lurek.log.info("tick beat=" .. tostring(beat))
end

--@api: LBeatClock:type
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    local bpm = clock:getBpm()
    local beat = clock:getBeat()
    lurek.log.info("clock type=" .. tostring(clock:type()))
    lurek.log.info("clock is object=" .. tostring(clock:typeOf("LBeatClock")) .. " bpm=" .. tostring(bpm) .. " beat=" .. tostring(beat))
end

--@api: LBeatClock:typeOf
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    local running = clock:isRunning()
    local bpm = clock:getBpm()
    lurek.log.info("typeOf LBeatClock=" .. tostring(clock:typeOf("LBeatClock")))
    lurek.log.info("type=" .. tostring(clock:type()) .. " running=" .. tostring(running) .. " bpm=" .. tostring(bpm))
end

--@api: LBeatClock:update
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    clock:start()
    local events = clock:update(0.5)
    local beat = clock:getBeat()
    lurek.log.info("update events=" .. tostring(#events))
    lurek.log.info("update beat=" .. tostring(beat))
end

--@api: lurek.audio.getJudgementWindows
do
    local windows = lurek.audio.getJudgementWindows()
    local perfect = windows.perfect or windows[1]
    local good = windows.good or windows[2]
    lurek.log.info("judgement windows present=" .. tostring(windows ~= nil))
    lurek.log.info("judgement windows perfect=" .. tostring(perfect) .. " good=" .. tostring(good))
end

--@api: lurek.audio.setJudgementWindows
do
    lurek.audio.setJudgementWindows({ perfect = 0.03, good = 0.08, ok = 0.12 })
    local windows = lurek.audio.getJudgementWindows()
    local perfect = windows.perfect or windows[1]
    local ok = windows.ok or windows[3]
    lurek.log.info("setJudgementWindows perfect=" .. tostring(perfect))
    lurek.log.info("setJudgementWindows ok=" .. tostring(ok))
end

--@api: lurek.audio.clearFilter
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setLowpass(src, 1000)
    lurek.log.info(tostring("lowpass before clear = " .. tostring(lurek.audio.getLowpass(src))))
    lurek.audio.clearFilter(src)
    lurek.log.info(tostring("filters cleared"))
end

--@api: lurek.audio.fadeIn
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.fadeIn(src, 2.0)
    lurek.log.info(tostring("fade in requested = 2.0s"))
    lurek.log.info(tostring("fade in = " .. tostring(lurek.audio.getFadeIn(src)) .. "s"))
end

--@api: lurek.audio.getFadeIn
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.fadeIn(src, 1.5)
    local fi = lurek.audio.getFadeIn(src)
    lurek.log.info(tostring("configured fade in = 1.5"))
    lurek.log.info(tostring("fade in duration = " .. tostring(fi)))
end

--@api: lurek.audio.setListener2D
do
    lurek.audio.setListener2D(400, 300)
    local x, y = lurek.audio.getListener2D()
    lurek.audio.setListener2D(512, 256)
    local x2, y2 = lurek.audio.getListener2D()
    lurek.log.info("listener2D town square=" .. x .. "," .. y)
    lurek.log.info("listener2D boss arena=" .. x2 .. "," .. y2)
end

--@api: lurek.audio.getListener2D
do
    lurek.audio.setListener2D(100, 200)
    local x, y = lurek.audio.getListener2D()
    lurek.audio.setListener2D(0, 0)
    local ox, oy = lurek.audio.getListener2D()
    lurek.log.info("listener2D queried=" .. x .. "," .. y)
    lurek.log.info("listener2D origin=" .. ox .. "," .. oy)
end

--@api: lurek.audio.setListener
do
    lurek.audio.setListener(0, 0, 0)
    local x, y, z = lurek.audio.getListener()
    lurek.audio.setListener(10, 5, 2)
    local x2, y2, z2 = lurek.audio.getListener()
    lurek.log.info("listener3D origin=" .. x .. "," .. y .. "," .. z)
    lurek.log.info("listener3D balcony=" .. x2 .. "," .. y2 .. "," .. z2)
end

--@api: lurek.audio.getListener
do
    lurek.audio.setListener(10, 5, 0)
    local x, y, z = lurek.audio.getListener()
    lurek.audio.setListener(0, 0, 0)
    local ox, oy, oz = lurek.audio.getListener()
    lurek.log.info("listener3D queried=" .. x .. "," .. y .. "," .. z)
    lurek.log.info("listener3D reset=" .. ox .. "," .. oy .. "," .. oz)
end

--@api: lurek.audio.setPosition
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setPosition(src, 50, 20, 0)
    local x, y, z = lurek.audio.getPosition(src)
    lurek.log.info(tostring("source positioned for spatial playback"))
    lurek.log.info(tostring("source pos = " .. x .. ", " .. y .. ", " .. z))
end

--@api: lurek.audio.getPosition
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setPosition(src, 100, 0, 30)
    local x, y, z = lurek.audio.getPosition(src)
    lurek.log.info(tostring("source position queried"))
    lurek.log.info(tostring("pos = " .. x .. ", " .. y .. ", " .. z))
end

--@api: lurek.audio.setVelocity
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setVelocity(src, 10, 0, 0)
    local vx, vy, vz = lurek.audio.getVelocity(src)
    lurek.log.info(tostring("source velocity set for doppler"))
    lurek.log.info(tostring("velocity = " .. vx .. ", " .. vy .. ", " .. vz))
end

--@api: lurek.audio.getVelocity
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setVelocity(src, 5, 3, 0)
    local vx, vy, vz = lurek.audio.getVelocity(src)
    lurek.log.info(tostring("source velocity queried"))
    lurek.log.info(tostring("vel = " .. vx .. ", " .. vy .. ", " .. vz))
end

--@api: lurek.audio.setOrientation
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setOrientation(src, 0, 0, -1, 0, 1, 0)
    local fx, fy, fz, ux, uy, uz = lurek.audio.getOrientation(src)
    lurek.log.info(tostring("orientation applied"))
    lurek.log.info(tostring("forward = " .. fx .. ", " .. fy .. ", " .. fz))
    lurek.log.info(tostring("up = " .. ux .. ", " .. uy .. ", " .. uz))
end

--- Audio Examples Part 2: Orientation, distance models, synthesis, DSP, bus effects, pool, offline

--@api: lurek.audio.getOrientation
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setOrientation(src, 0, 0, -1, 0, 1, 0)
    local fx, fy, fz, ux, uy, uz = lurek.audio.getOrientation(src)
    lurek.log.info(tostring("source type = " .. tostring(lurek.audio.getSourceType(src))))
    lurek.log.info(tostring("forward = " .. fx .. ", " .. fy .. ", " .. fz))
    lurek.log.info(tostring("up = " .. ux .. ", " .. uy .. ", " .. uz))
end

--@api: lurek.audio.setDopplerScale
do
    local before = lurek.audio.getDopplerScale()
    lurek.audio.setDopplerScale(1.5)
    local after = lurek.audio.getDopplerScale()
    lurek.log.info(tostring("doppler scale before = " .. tostring(before)))
    lurek.log.info(tostring("doppler scale after = " .. tostring(after)))
end

--@api: lurek.audio.getDopplerScale
do
    lurek.audio.setDopplerScale(2.0)
    local ds = lurek.audio.getDopplerScale()
    lurek.audio.setDopplerScale(1.0)
    local reset = lurek.audio.getDopplerScale()
    lurek.log.info("configured doppler scale=2.0 actual=" .. tostring(ds))
    lurek.log.info("doppler scale reset=" .. tostring(reset))
end

--@api: lurek.audio.setDistanceModel
do
    local before = lurek.audio.getDistanceModel()
    lurek.audio.setDistanceModel("inverse")
    local inverse = lurek.audio.getDistanceModel()
    lurek.audio.setDistanceModel("inverse_clamped")
    local clamped = lurek.audio.getDistanceModel()
    lurek.log.info("distance model before=" .. tostring(before) .. " inverse=" .. tostring(inverse))
    lurek.log.info("distance model clamped=" .. tostring(clamped))
end

--@api: lurek.audio.getDistanceModel
do
    lurek.audio.setDistanceModel("linear")
    local model = lurek.audio.getDistanceModel()
    lurek.audio.setDistanceModel("inverse_clamped")
    local fallback = lurek.audio.getDistanceModel()
    lurek.log.info("configured distance model linear actual=" .. tostring(model))
    lurek.log.info("configured distance model fallback=" .. tostring(fallback))
end

--@api: lurek.audio.setMeter
do
    local before = lurek.audio.getMeter()
    lurek.audio.setMeter(0.8)
    local after = lurek.audio.getMeter()
    lurek.audio.setMeter(0.25)
    local quieter = lurek.audio.getMeter()
    lurek.log.info("meter before=" .. tostring(before) .. " after=" .. tostring(after))
    lurek.log.info("meter quieter mix=" .. tostring(quieter))
end

--@api: lurek.audio.getMeter
do
    lurek.audio.setMeter(0.6)
    local lvl = lurek.audio.getMeter()
    lurek.audio.setMeter(0.1)
    local idle = lurek.audio.getMeter()
    lurek.log.info("configured meter 0.6 actual=" .. tostring(lvl))
    lurek.log.info("configured meter idle=" .. tostring(idle))
end


--@api: lurek.audio.newSoundData
do
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    local channels = sd:getChannelCount()
    local duration = sd:getDuration()
    lurek.log.info("sound data created=" .. tostring(sd ~= nil))
    lurek.log.info("sample count=" .. tostring(sd:getSampleCount()) .. " sample rate=" .. tostring(sd:getSampleRate()))
    lurek.log.info("channels=" .. tostring(channels) .. " duration=" .. tostring(duration))
end




--@api: lurek.audio.newDecoder
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local dec = lurek.audio.newDecoder(path, 4096)
    lurek.log.info(tostring("decoder created = " .. tostring(dec ~= nil)))
    lurek.log.info(tostring("sample rate = " .. tostring(dec:getSampleRate())))
    lurek.log.info(tostring("channels = " .. tostring(dec:getChannelCount())))
end

--@api: lurek.audio.newQueueableSource
do
    local qid = lurek.audio.newQueueableSource(44100, 16, 1, 4)
    local free = lurek.audio.getFreeBufferCount(qid)
    local sd = lurek.audio.newSoundData(1024, 44100, 1)
    lurek.audio.queueSource(qid, sd)
    local afterQueue = lurek.audio.getFreeBufferCount(qid)
    lurek.log.info("queueable id=" .. tostring(qid) .. " free buffers=" .. tostring(free))
    lurek.log.info("queueable free after one chunk=" .. tostring(afterQueue) .. " queued=" .. tostring(afterQueue < free))
end

--@api: lurek.audio.queueSource
do
    local qid = lurek.audio.newQueueableSource(44100, 16, 1, 4)
    local sd = lurek.audio.newSoundData(1024, 44100, 1)
    local before = lurek.audio.getFreeBufferCount(qid)
    lurek.audio.queueSource(qid, sd)
    local after = lurek.audio.getFreeBufferCount(qid)
    lurek.log.info(tostring("free buffers before queue = " .. tostring(before)))
    lurek.log.info(tostring("free buffers after queue = " .. tostring(after)))
end

--@api: lurek.audio.getFreeBufferCount
do
    local qid = lurek.audio.newQueueableSource(44100, 16, 1, 4)
    local free = lurek.audio.getFreeBufferCount(qid)
    local sd = lurek.audio.newSoundData(1024, 44100, 1)
    lurek.audio.queueSource(qid, sd)
    local afterQueue = lurek.audio.getFreeBufferCount(qid)
    lurek.log.info("queueable free buffers before=" .. tostring(free))
    lurek.log.info("queueable free buffers after queue=" .. tostring(afterQueue) .. " delta=" .. tostring(free - afterQueue))
end

--@api: lurek.audio.playQueueable
do
    local qid = lurek.audio.newQueueableSource(44100, 16, 1, 4)
    local sd = lurek.audio.newSoundData(1024, 44100, 1)
    lurek.audio.queueSource(qid, sd)
    lurek.audio.playQueueable(qid)
    lurek.log.info(tostring("queueable source started"))
    lurek.log.info(tostring("free buffers after play = " .. tostring(lurek.audio.getFreeBufferCount(qid))))
end

--@api: lurek.audio.stopQueueable
do
    local qid = lurek.audio.newQueueableSource(44100, 16, 1, 4)
    local sd = lurek.audio.newSoundData(1024, 44100, 1)
    lurek.audio.queueSource(qid, sd)
    lurek.audio.playQueueable(qid)
    lurek.audio.stopQueueable(qid)
    local free = lurek.audio.getFreeBufferCount(qid)
    lurek.log.info("queueable source stopped")
    lurek.log.info("queueable free buffers after stop=" .. tostring(free) .. " restored=" .. tostring(free == 4))
end

--@api: lurek.audio.getPlaybackDevices
do
    local devices = lurek.audio.getPlaybackDevices()
    local active = lurek.audio.getPlaybackDevice()
    local first = devices[1] or "none"
    lurek.log.info("playback device count=" .. tostring(#devices))
    lurek.log.info("playback first=" .. tostring(first) .. " active=" .. tostring(active) .. " listed_active=" .. tostring(active == first or #devices > 0))
end

--@api: lurek.audio.getPlaybackDevice
do
    local dev = lurek.audio.getPlaybackDevice()
    local devices = lurek.audio.getPlaybackDevices()
    local listed = #devices
    lurek.log.info("current playback device=" .. tostring(dev))
    lurek.log.info("available playback devices=" .. tostring(listed) .. " first=" .. tostring(devices[1] or "none"))
end

--@api: lurek.audio.setPlaybackDevice
do
    local devices = lurek.audio.getPlaybackDevices()
    local name = devices[1] or lurek.audio.getPlaybackDevice()
    lurek.audio.setPlaybackDevice(name)
    lurek.log.info(tostring("requested device = " .. tostring(name)))
    lurek.log.info(tostring("active device = " .. tostring(lurek.audio.getPlaybackDevice())))
end

--@api: lurek.audio.create_bus
do
    lurek.audio.create_bus("master_sfx", nil)
    lurek.audio.set_bus_volume("master_sfx", 0.65)
    local peak = lurek.audio.getBusPeak("master_sfx")
    local rms = lurek.audio.getBusRms("master_sfx")
    lurek.log.info("named bus created master_sfx")
    lurek.log.info("named bus peak=" .. tostring(peak) .. " rms=" .. tostring(rms) .. " volume_set=0.65")
end

--@api: lurek.audio.set_bus_volume
do
    lurek.audio.create_bus("music_bus", nil)
    lurek.audio.set_bus_volume("music_bus", 0.7)
    local peak = lurek.audio.getBusPeak("music_bus")
    local rms = lurek.audio.getBusRms("music_bus")
    lurek.log.info("configured music_bus volume=0.7")
    lurek.log.info("music_bus peak=" .. tostring(peak) .. " rms=" .. tostring(rms) .. " has_bus=" .. tostring(true))
end

--@api: lurek.audio.add_effect
do
    lurek.audio.create_bus("fx_bus", nil)
    local ok, eid = pcall(function() return lurek.audio.add_effect("fx_bus", "reverb", { value = 0.5 }) end)
    local peak = lurek.audio.getBusPeak("fx_bus")
    local rms = lurek.audio.getBusRms("fx_bus")
    lurek.log.info("effect id=" .. (ok and tostring(eid) or "unavailable"))
    lurek.log.info("effect added to fx_bus peak=" .. tostring(peak) .. " rms=" .. tostring(rms) .. " ok=" .. tostring(ok))
end

--@api: lurek.audio.remove_effect
do
    lurek.audio.create_bus("temp_bus", nil)
    local ok_add, eid = pcall(function()
        return lurek.audio.add_effect("temp_bus", "lowpass", { value = 800 })
    end)
    local ok_remove = ok_add and type(lurek.audio.remove_effect) == "function"
        and lurek.audio.remove_effect("temp_bus", eid) or false
    lurek.log.info(tostring("effect id = " .. tostring(ok_add and eid or "unavailable")))
    lurek.log.info(tostring("removed = " .. tostring(ok_remove)))
end

--@api: lurek.audio.set_effect_param
do
    lurek.audio.create_bus("eq_bus", nil)
    local ok_add, eid = pcall(function()
        return lurek.audio.add_effect("eq_bus", "highpass", { cutoff = 200 })
    end)
    local ok = ok_add and type(lurek.audio.set_effect_param) == "function"
        and lurek.audio.set_effect_param("eq_bus", eid, "cutoff", 500) or false
    lurek.log.info(tostring("effect id = " .. tostring(ok_add and eid or "unavailable")))
    lurek.log.info(tostring("param set = " .. tostring(ok)))
end

--@api: lurek.audio.newSineWave
do
    local has_fn = type(lurek.audio.newSineWave) == "function"
    local sd = has_fn and lurek.audio.newSineWave(440, 1.0, 44100, 0.8) or nil
    local duration = sd and sd:getDuration() or 0
    local samples = sd and sd:getSampleCount() or 0
    lurek.log.info("sine wave available=" .. tostring(has_fn))
    lurek.log.info("sine wave created=" .. tostring(sd ~= nil) .. " duration=" .. tostring(duration) .. " samples=" .. tostring(samples) .. " rate=" .. tostring(sd and sd:getSampleRate() or 0))
end

--@api: lurek.audio.newSquareWave
do
    local has_fn = type(lurek.audio.newSquareWave) == "function"
    local sd = has_fn and lurek.audio.newSquareWave(220, 0.5, 44100, 0.6) or nil
    local duration = sd and sd:getDuration() or 0
    local samples = sd and sd:getSampleCount() or 0
    lurek.log.info("square wave available=" .. tostring(has_fn))
    lurek.log.info("square wave created=" .. tostring(sd ~= nil) .. " duration=" .. tostring(duration) .. " samples=" .. tostring(samples) .. " rate=" .. tostring(sd and sd:getSampleRate() or 0))
end

--@api: lurek.audio.newSawtoothWave
do
    local has_fn = type(lurek.audio.newSawtoothWave) == "function"
    local sd = has_fn and lurek.audio.newSawtoothWave(330, 0.5, 44100, 0.7) or nil
    local duration = sd and sd:getDuration() or 0
    local samples = sd and sd:getSampleCount() or 0
    lurek.log.info("sawtooth wave available=" .. tostring(has_fn))
    lurek.log.info("sawtooth wave created=" .. tostring(sd ~= nil) .. " duration=" .. tostring(duration) .. " samples=" .. tostring(samples) .. " rate=" .. tostring(sd and sd:getSampleRate() or 0))
end

--@api: lurek.audio.newTriangleWave
do
    local has_fn = type(lurek.audio.newTriangleWave) == "function"
    local sd = has_fn and lurek.audio.newTriangleWave(550, 0.5, 44100, 0.5) or nil
    local duration = sd and sd:getDuration() or 0
    local samples = sd and sd:getSampleCount() or 0
    lurek.log.info("triangle wave available=" .. tostring(has_fn))
    lurek.log.info("triangle wave created=" .. tostring(sd ~= nil) .. " duration=" .. tostring(duration) .. " samples=" .. tostring(samples) .. " rate=" .. tostring(sd and sd:getSampleRate() or 0))
end

--@api: lurek.audio.newWhiteNoise
do
    local has_fn = type(lurek.audio.newWhiteNoise) == "function"
    local sd = has_fn and lurek.audio.newWhiteNoise(1.0, 44100, 0.4, 12345) or nil
    local duration = sd and sd:getDuration() or 0
    local samples = sd and sd:getSampleCount() or 0
    lurek.log.info("white noise available=" .. tostring(has_fn))
    lurek.log.info("white noise created=" .. tostring(sd ~= nil) .. " duration=" .. tostring(duration) .. " samples=" .. tostring(samples) .. " rate=" .. tostring(sd and sd:getSampleRate() or 0))
end

--@api: lurek.audio.applyLowpass
do
    local has_wave = type(lurek.audio.newSineWave) == "function"
    local has_fn = type(lurek.audio.applyLowpass) == "function"
    local sd = has_wave and lurek.audio.newSineWave(1000, 0.5, 44100, 0.8) or nil
    if has_fn and sd then
        lurek.audio.applyLowpass(sd, 500)
    end
    lurek.log.info(tostring("lowpass available = " .. tostring(has_fn)))
    lurek.log.info(tostring("lowpass applied at 500 Hz"))

end
--@api: lurek.audio.applyHighpass
do
    local has_noise = type(lurek.audio.newWhiteNoise) == "function"
    local has_fn = type(lurek.audio.applyHighpass) == "function"
    local sd = has_noise and lurek.audio.newWhiteNoise(0.5, 44100, 0.6, 99) or nil
    if has_fn and sd then
        lurek.audio.applyHighpass(sd, 2000)
    end
    lurek.log.info(tostring("highpass available = " .. tostring(has_fn)))
    lurek.log.info(tostring("highpass applied at 2000 Hz"))

end
--@api: lurek.audio.applyBandpass
do
    local has_noise = type(lurek.audio.newWhiteNoise) == "function"
    local has_fn = type(lurek.audio.applyBandpass) == "function"
    local sd = has_noise and lurek.audio.newWhiteNoise(0.5, 44100, 0.5, 42) or nil
    if has_fn and sd then
        lurek.audio.applyBandpass(sd, 300, 3000)
    end
    lurek.log.info(tostring("bandpass available = " .. tostring(has_fn)))
    lurek.log.info(tostring("bandpass 300-3000 Hz applied"))

end
--@api: lurek.audio.applyGain
do
    local has_wave = type(lurek.audio.newSineWave) == "function"
    local has_fn = type(lurek.audio.applyGain) == "function"
    local sd = has_wave and lurek.audio.newSineWave(440, 0.5, 44100, 0.3) or nil
    if has_fn and sd then
        lurek.audio.applyGain(sd, 2.0)
    end
    lurek.log.info(tostring("gain available = " .. tostring(has_fn)))
    lurek.log.info(tostring("gain x2 applied"))

end
--@api: lurek.audio.mixInto
do
    local has_wave = type(lurek.audio.newSineWave) == "function"
    local has_fn = type(lurek.audio.mixInto) == "function"
    local dest = has_wave and lurek.audio.newSineWave(440, 1.0, 44100, 0.5) or nil
    local src = has_wave and lurek.audio.newSineWave(880, 1.0, 44100, 0.3) or nil
    if has_fn and dest and src then
        lurek.audio.mixInto(dest, src)
    end
    lurek.log.info(tostring("mixInto available = " .. tostring(has_fn)))
    lurek.log.info(tostring("mixed 880 Hz into 440 Hz"))

end
--@api: lurek.audio.saveWAV
do
    local has_wave = type(lurek.audio.newSineWave) == "function"
    local has_fn = type(lurek.audio.saveWAV) == "function"
    local sd = has_wave and lurek.audio.newSineWave(440, 1.0, 44100, 0.8) or nil
    if has_fn and sd then
        lurek.audio.saveWAV(sd, "save/test_tone.wav")
    end
    lurek.log.info(tostring("saveWAV available = " .. tostring(has_fn)))
    lurek.log.info(tostring("saved WAV file"))

end
--@api: lurek.audio.setStereoWidth
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.setStereoWidth(src, 0.5)
    lurek.log.info(tostring("configured stereo width = 0.5"))
    lurek.log.info(tostring("stereo width = " .. tostring(lurek.audio.getStereoWidth(src))))
end

--@api: lurek.audio.getStereoWidth
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.setStereoWidth(src, 0.8)
    local w = lurek.audio.getStereoWidth(src)
    lurek.log.info(tostring("configured stereo width = 0.8"))
    lurek.log.info(tostring("width = " .. tostring(w)))
end

--@api: lurek.audio.setRandomPitch
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setRandomPitch(src, 0.9, 1.1)
    lurek.log.info(tostring("random pitch range = 0.9 to 1.1"))
    lurek.log.info(tostring("source ready for varied playback"))
end

--@api: lurek.audio.clearRandomPitch
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setRandomPitch(src, 0.8, 1.2)
    lurek.audio.clearRandomPitch(src)
    lurek.log.info(tostring("random pitch cleared"))
    lurek.log.info(tostring("source pitch now follows explicit setPitch calls"))
end

--@api: lurek.audio.crossfade
do
    local p1 = "content/examples/assets/audio/sample_loop.wav"
    local p2 = "content/examples/assets/audio/sample_tone.wav"
    local from = lurek.audio.newSource(p1, "stream")
    local to = lurek.audio.newSource(p2, "stream")
    lurek.audio.play(from)
    lurek.audio.crossfade(from, to, 3.0)
    lurek.log.info(tostring("from path = " .. p1))
    lurek.log.info(tostring("to path = " .. p2))
    lurek.log.info(tostring("crossfading over 3s"))
end

--@api: lurek.audio.getBusPeak
do
    lurek.audio.create_bus("vu_bus", nil)
    local peak = lurek.audio.getBusPeak("vu_bus")
    local rms = lurek.audio.getBusRms("vu_bus")
    lurek.log.info("vu bus peak=" .. tostring(peak))
    lurek.log.info("vu bus rms=" .. tostring(rms) .. " has_peak=" .. tostring(peak ~= nil))
end

--@api: lurek.audio.getBusRms
do
    lurek.audio.create_bus("rms_bus", nil)
    local rms = lurek.audio.getBusRms("rms_bus")
    local peak = lurek.audio.getBusPeak("rms_bus")
    lurek.log.info("rms bus value=" .. tostring(rms))
    lurek.log.info("rms bus peak=" .. tostring(peak) .. " has_rms=" .. tostring(rms ~= nil))
end

--@api: lurek.audio.newPool
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local pool = lurek.audio.newPool(path, 8)
    local voices = pool:getVoiceCount()
    local bus = lurek.audio.newBus("pool_bus")
    pool:setVolume(0.8)
    lurek.log.info("sound pool voices=" .. tostring(voices))
    lurek.log.info("sound pool bus ready=" .. tostring(bus:getName()) .. " volume=" .. tostring(0.8) .. " pool_type=" .. tostring(pool:type()))
end

--@api: lurek.audio.processOffline
do
    local effects = {{ type = "lowpass", p1 = 1000 }, { type = "compressor", p1 = 0.8, p2 = 2.5, p3 = 0.1 }}
    local path_in = "content/examples/assets/audio/sample_tone.wav"
    local path_out = "save/processed.wav"
    local has_fn = type(lurek.audio.processOffline) == "function"
    if has_fn then
        lurek.audio.processOffline(path_in, path_out, effects)
    end
    lurek.log.info(tostring("processOffline available = " .. tostring(has_fn)))
    lurek.log.info(tostring("input file = " .. path_in))
    lurek.log.info(tostring("output file = " .. path_out))
    lurek.log.info(tostring("offline processing done"))

end
--@api: lurek.audio.normalizeFile
do
    local path_in = "content/examples/assets/audio/sample_tone.wav"
    local path_out = "save/normalized.wav"
    local has_fn = type(lurek.audio.normalizeFile) == "function"
    if has_fn then
        lurek.audio.normalizeFile(path_in, path_out, 0.9)
    end
    lurek.log.info(tostring("normalizeFile available = " .. tostring(has_fn)))
    lurek.log.info(tostring("input file = " .. path_in))
    lurek.log.info(tostring("output file = " .. path_out))
    lurek.log.info(tostring("normalized to 0.9 peak"))

end
--@api: lurek.audio.waveformToPng
do
    local path_in = "content/examples/assets/audio/sample_tone.wav"
    local path_out = "save/waveform.png"
    local has_fn = type(lurek.audio.waveformToPng) == "function"
    if has_fn then
        lurek.audio.waveformToPng(path_in, path_out, 800, 200)
    end
    lurek.log.info(tostring("waveformToPng available = " .. tostring(has_fn)))
    lurek.log.info(tostring("input file = " .. path_in))
    lurek.log.info(tostring("output file = " .. path_out))
    lurek.log.info(tostring("waveform image saved"))

end
--@api: lurek.audio.spectrogramToPng
do
    local path_in = "content/examples/assets/audio/sample_tone.wav"
    local path_out = "save/spectrogram.png"
    local has_fn = type(lurek.audio.spectrogramToPng) == "function"
    if has_fn then
        lurek.audio.spectrogramToPng(path_in, path_out, 800, 400)
    end
    lurek.log.info(tostring("spectrogramToPng available = " .. tostring(has_fn)))
    lurek.log.info(tostring("input file = " .. path_in))
    lurek.log.info(tostring("output file = " .. path_out))
    lurek.log.info(tostring("spectrogram image saved"))

end
--@api: LSource:play
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    src:play()
    local playing = src:isPlaying()
    local stopped = src:isStopped()
    lurek.log.info("source play via method=" .. tostring(playing))
    lurek.log.info("source stopped after play=" .. tostring(stopped))
end

--- Audio Examples Part 3: LSource methods and LBus methods

--@api: LSource:stop
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    src:play()
    src:stop()
    lurek.log.info(tostring("stopped = " .. tostring(src:isStopped())))
end

--@api: LSource:pause
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    src:play()
    src:pause()
    lurek.log.info(tostring("paused = " .. tostring(src:isPaused())))
end

--@api: LSource:resume
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    src:play()
    src:pause()
    src:resume()
    lurek.log.info(tostring("resumed = " .. tostring(src:isPlaying())))
end

--@api: LSource:setVolume
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    src:setVolume(0.4)
    local volume = src:getVolume()
    src:setVolume(0.8)
    lurek.log.info("source volume low=" .. tostring(volume))
    lurek.log.info("source volume high=" .. tostring(src:getVolume()))
end

--@api: LSource:getVolume
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    src:setVolume(0.9)
    local v = src:getVolume()
    lurek.log.info(tostring("volume = " .. v))
end

--@api: LSource:setPitch
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    src:setPitch(1.5)
    local pitch = src:getPitch()
    src:setPitch(0.75)
    lurek.log.info("source pitch fast=" .. tostring(pitch))
    lurek.log.info("source pitch slow=" .. tostring(src:getPitch()))
end

--@api: LSource:getPitch
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    src:setPitch(0.7)
    local p = src:getPitch()
    lurek.log.info(tostring("pitch = " .. p))
end

--@api: LSource:setLooping
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    src:setLooping(true)
    local looping = src:isLooping()
    src:setLooping(false)
    lurek.log.info("source looping enabled=" .. tostring(looping))
    lurek.log.info("source looping disabled=" .. tostring(src:isLooping()))
end

--@api: LSource:isLooping
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    src:setLooping(true)
    local looping = src:isLooping()
    local sourceType = src:getType()
    lurek.log.info("source isLooping=" .. tostring(looping))
    lurek.log.info("source type=" .. tostring(sourceType))
end

--@api: LSource:isPlaying
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    src:play()
    local playing = src:isPlaying()
    local stopped = src:isStopped()
    lurek.log.info("source isPlaying=" .. tostring(playing))
    lurek.log.info("source isStopped while playing=" .. tostring(stopped))
end

--@api: LSource:isPaused
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    src:play()
    src:pause()
    lurek.log.info(tostring("paused = " .. tostring(src:isPaused())))
end

--@api: LSource:isStopped
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    local stoppedBefore = src:isStopped()
    src:play()
    src:stop()
    local stoppedAfter = src:isStopped()
    lurek.log.info("source stopped before play=" .. tostring(stoppedBefore))
    lurek.log.info("source stopped after stop=" .. tostring(stoppedAfter))
end

--@api: LSource:setPan
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    src:setPan(-0.8)
    local left = src:getPan()
    src:setPan(0.8)
    lurek.log.info("source pan left=" .. tostring(left))
    lurek.log.info("source pan right=" .. tostring(src:getPan()))
end

--@api: LSource:getPan
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    src:setPan(0.5)
    local pan = src:getPan()
    lurek.log.info(tostring("pan = " .. pan))
end

--@api: LSource:clone
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    src:setVolume(0.3)
    local copy = src:clone()
    lurek.log.info(tostring("clone volume = " .. copy:getVolume()))
end

--@api: LSource:getType
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    local sourceKind = src:getType()
    local typeName = src:type()
    lurek.log.info("source getType=" .. tostring(sourceKind))
    lurek.log.info("source userdata type=" .. tostring(typeName))
end

--@api: LSource:getDuration
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    local dur = src:getDuration()
    local sourceKind = src:getType()
    lurek.log.info("source duration=" .. tostring(dur) .. "s")
    lurek.log.info("source kind=" .. tostring(sourceKind))
end

--@api: LSource:tell
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    src:play()
    local pos = src:tell()
    lurek.log.info(tostring("position = " .. pos))
end

--@api: LSource:seek
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    src:play()
    src:seek(10.0)
    lurek.log.info(tostring("seeked to " .. src:tell()))
end

--@api: LSource:setLowpass
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    src:setLowpass(600)
    local low = src:getLowpass()
    src:setLowpass(1200)
    lurek.log.info("source lowpass narrow=" .. tostring(low))
    lurek.log.info("source lowpass wide=" .. tostring(src:getLowpass()))
end

--@api: LSource:setHighpass
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    src:setHighpass(1500)
    local high = src:getHighpass()
    src:setHighpass(3000)
    lurek.log.info("source highpass light=" .. tostring(high))
    lurek.log.info("source highpass heavy=" .. tostring(src:getHighpass()))
end

--@api: LSource:getLowpass
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    src:setLowpass(400)
    local lp = src:getLowpass()
    lurek.log.info(tostring("lowpass = " .. lp))
end

--@api: LSource:getHighpass
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    src:setHighpass(4000)
    local hp = src:getHighpass()
    lurek.log.info(tostring("highpass = " .. hp))
end

--@api: LSource:clearFilter
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    src:setLowpass(800)
    src:clearFilter()
    lurek.log.info(tostring("filters cleared"))
end

--@api: LSource:fadeIn
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    src:fadeIn(2.5)
    local fade = src:getFadeIn()
    src:play()
    lurek.log.info("source fade in=" .. tostring(fade) .. "s")
    lurek.log.info("source playing after fade request=" .. tostring(src:isPlaying()))
end

--@api: LSource:getFadeIn
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    src:fadeIn(1.0)
    local fi = src:getFadeIn()
    lurek.log.info(tostring("fade in = " .. fi))
end

--@api: LSource:type
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    local typeName = src:type()
    local sourceKind = src:getType()
    lurek.log.info("source type=" .. tostring(typeName))
    lurek.log.info("source kind=" .. tostring(sourceKind))
end

--@api: LSource:typeOf
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    local isSource = src:typeOf("LSource")
    local typeName = src:type()
    lurek.log.info("source typeOf LSource=" .. tostring(isSource))
    lurek.log.info("source type=" .. tostring(typeName))
end

--@api: LBus:getName
do
    local bus = lurek.audio.newBus("gameplay")
    local name = bus:getName()
    local typeName = bus:type()
    lurek.log.info("bus name=" .. tostring(name))
    lurek.log.info("bus type=" .. tostring(typeName))
end

--@api: LBus:setVolume
do
    local bus = lurek.audio.newBus("sfx")
    bus:setVolume(0.6)
    local low = bus:getVolume()
    bus:setVolume(0.9)
    lurek.log.info("bus volume low=" .. tostring(low))
    lurek.log.info("bus volume high=" .. tostring(bus:getVolume()))
end

--@api: LBus:getVolume
do
    local bus = lurek.audio.newBus("music")
    bus:setVolume(0.8)
    local chapterVolume = bus:getVolume()
    bus:setVolume(0.55)
    local duckedVolume = bus:getVolume()
    lurek.log.info("music bus chapter volume=" .. tostring(chapterVolume))
    lurek.log.info("music bus ducked volume=" .. tostring(duckedVolume))
end

--@api: LBus:setPitch
do
    local bus = lurek.audio.newBus("fx")
    bus:setPitch(1.2)
    local high = bus:getPitch()
    bus:setPitch(0.8)
    lurek.log.info("bus pitch high=" .. tostring(high))
    lurek.log.info("bus pitch low=" .. tostring(bus:getPitch()))
end

--@api: LBus:getPitch
do
    local bus = lurek.audio.newBus("ambient")
    bus:setPitch(0.9)
    local rainyPitch = bus:getPitch()
    bus:setPitch(1.05)
    local clearPitch = bus:getPitch()
    lurek.log.info("ambient bus rainy pitch=" .. tostring(rainyPitch))
    lurek.log.info("ambient bus clear pitch=" .. tostring(clearPitch))
end

--@api: LBus:pause
do
    local bus = lurek.audio.newBus("dialog")
    bus:pause()
    local paused = bus:isPaused()
    bus:resume()
    lurek.log.info("bus paused=" .. tostring(paused))
    lurek.log.info("bus resumed=" .. tostring(not bus:isPaused()))
end

--@api: LBus:resume
do
    local bus = lurek.audio.newBus("world")
    bus:pause()
    bus:resume()
    local resumed = not bus:isPaused()
    local peak = bus:getPeak()
    lurek.log.info("bus resumed=" .. tostring(resumed))
    lurek.log.info("bus peak after resume=" .. tostring(peak))
end

--@api: LBus:isPaused
do
    local bus = lurek.audio.newBus("ui")
    bus:pause()
    local paused = bus:isPaused()
    bus:resume()
    lurek.log.info("bus paused flag=" .. tostring(paused))
    lurek.log.info("bus paused after resume=" .. tostring(bus:isPaused()))
end

--@api: LBus:type
do
    local bus = lurek.audio.newBus("test")
    local typeName = bus:type()
    local isBus = bus:typeOf("LBus")
    lurek.log.info("bus type=" .. tostring(typeName))
    lurek.log.info("bus typeOf LBus=" .. tostring(isBus))
end

--@api: LBus:typeOf
do
    local bus = lurek.audio.newBus("check")
    local isBus = bus:typeOf("LBus")
    local typeName = bus:type()
    lurek.log.info("bus typeOf LBus=" .. tostring(isBus))
    lurek.log.info("bus type=" .. tostring(typeName))
end

--@api: LBus:setDuckTarget
do
    local music = lurek.audio.newBus("bg_music")
    local voice = lurek.audio.newBus("voice_over")
    music:setVolume(0.8)
    voice:setDuckTarget("bg_music", 0.3)
    local voiceType = voice:type()
    local musicVolume = music:getVolume()
    lurek.log.info("voice bus type=" .. tostring(voiceType))
    lurek.log.info("bg_music keeps base volume=" .. tostring(musicVolume))
end

--@api: LBus:clearDuck
do
    local bus = lurek.audio.newBus("narrator")
    bus:setDuckTarget("bg_music", 0.2)
    local wasBus = bus:typeOf("LBus")
    bus:clearDuck()
    local narratorName = bus:getName()
    lurek.log.info("duck cleared for=" .. tostring(narratorName))
    lurek.log.info("narrator is bus=" .. tostring(wasBus))
end

--@api: LBus:getPeak
do
    local bus = lurek.audio.newBus("meter_bus")
    bus:setVolume(0.75)
    local peak = bus:getPeak()
    local name = bus:getName()
    lurek.log.info("meter bus=" .. tostring(name))
    lurek.log.info("peak=" .. tostring(peak) .. " volume=" .. tostring(bus:getVolume()))
end










--- Audio Examples Part 4: LSoundPool and LDecoder methods










































--@api: LSoundPool:play
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local pool = lurek.audio.newPool(path, 4)
    pool:setVolume(0.7)
    local firstVoice = pool:play()
    local secondVoice = pool:play()
    lurek.log.info("ui click pool first voice=" .. tostring(firstVoice))
    lurek.log.info("ui click pool second voice=" .. tostring(secondVoice))
end

--@api: LSoundPool:stopAll
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local pool = lurek.audio.newPool(path, 4)
    pool:play()
    pool:stopAll()
    lurek.log.info(tostring("all voices stopped"))
end

--@api: LSoundPool:setVolume
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local pool = lurek.audio.newPool(path, 4)
    pool:setVolume(0.5)
    local quietVoice = pool:play()
    pool:setVolume(0.9)
    local loudVoice = pool:play()
    lurek.log.info("quiet click voice=" .. tostring(quietVoice))
    lurek.log.info("loud click voice=" .. tostring(loudVoice))
end

--@api: LSoundPool:setBus
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local pool = lurek.audio.newPool(path, 4)
    lurek.audio.newBus("pool_bus")
    pool:setBus("pool_bus")
    lurek.log.info(tostring("pool routed to pool_bus"))
end

--@api: LSoundPool:release
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local pool = lurek.audio.newPool(path, 4)
    local firstVoice = pool:play()
    local voiceCount = pool:getVoiceCount()
    pool:release()
    local typeName = pool:type()
    lurek.log.info("released pool after voice=" .. tostring(firstVoice))
    lurek.log.info("pool voices=" .. tostring(voiceCount) .. " type=" .. tostring(typeName))
end

--@api: LSoundPool:getVoiceCount
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local pool = lurek.audio.newPool(path, 8)
    local reservedVoices = pool:getVoiceCount()
    local firstVoice = pool:play()
    local secondVoice = pool:play()
    lurek.log.info("pool reserved voices=" .. tostring(reservedVoices))
    lurek.log.info("first two voice ids=" .. tostring(firstVoice) .. "," .. tostring(secondVoice))
end

--@api: LSoundPool:type
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local pool = lurek.audio.newPool(path, 2)
    local typeName = pool:type()
    local voiceCount = pool:getVoiceCount()
    local isPool = pool:typeOf("LSoundPool")
    lurek.log.info("sound pool type=" .. tostring(typeName))
    lurek.log.info("voice count=" .. tostring(voiceCount) .. " is pool=" .. tostring(isPool))
end

--@api: LSoundPool:typeOf
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local pool = lurek.audio.newPool(path, 2)
    local isPool = pool:typeOf("LSoundPool")
    local isObject = pool:typeOf("LObject")
    local typeName = pool:type()
    lurek.log.info("is LSoundPool=" .. tostring(isPool))
    lurek.log.info("is LObject=" .. tostring(isObject) .. " type=" .. tostring(typeName))
end

--@api: LDecoder:decode
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local dec = lurek.audio.newDecoder(path, 4096)
    local chunk = dec:decode()
    local sampleCount = chunk and chunk:getSampleCount() or 0
    local sampleRate = dec:getSampleRate()
    local seekable = dec:isSeekable()
    lurek.log.info("decoded chunk present=" .. tostring(chunk ~= nil))
    lurek.log.info("chunk samples=" .. tostring(sampleCount) .. " rate=" .. tostring(sampleRate) .. " seekable=" .. tostring(seekable))
end

--- Audio Examples Part 5: LDecoder methods, LSoundData methods

--@api: LDecoder:getChannelCount
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local dec = lurek.audio.newDecoder(path)
    local channels = dec:getChannelCount()
    local bitDepth = dec:getBitDepth()
    local sampleRate = dec:getSampleRate()
    lurek.log.info("decoder channels=" .. tostring(channels))
    lurek.log.info("decoder bitDepth=" .. tostring(bitDepth) .. " sampleRate=" .. tostring(sampleRate))
end

--@api: LDecoder:getBitDepth
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local dec = lurek.audio.newDecoder(path)
    local bitDepth = dec:getBitDepth()
    local channels = dec:getChannelCount()
    local duration = dec:getDuration()
    lurek.log.info("loop bit depth=" .. tostring(bitDepth))
    lurek.log.info("loop channels=" .. tostring(channels) .. " duration=" .. tostring(duration))
end

--@api: LDecoder:getSampleRate
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local dec = lurek.audio.newDecoder(path)
    local sampleRate = dec:getSampleRate()
    local duration = dec:getDuration()
    local channels = dec:getChannelCount()
    lurek.log.info("decoded sample rate=" .. tostring(sampleRate))
    lurek.log.info("decoded duration=" .. tostring(duration) .. " channels=" .. tostring(channels))
end

--@api: LDecoder:getDuration
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local dec = lurek.audio.newDecoder(path)
    local duration = dec:getDuration()
    local sampleRate = dec:getSampleRate()
    local bitDepth = dec:getBitDepth()
    lurek.log.info("loop duration=" .. tostring(duration))
    lurek.log.info("loop sample rate=" .. tostring(sampleRate) .. " bitDepth=" .. tostring(bitDepth))
end

--@api: LDecoder:seek
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local dec = lurek.audio.newDecoder(path)
    local canSeek = dec:isSeekable()
    dec:seek(2.5)
    local position = dec:tell()
    local duration = dec:getDuration()
    lurek.log.info("decoder seekable=" .. tostring(canSeek))
    lurek.log.info("preview cursor=" .. tostring(position) .. " duration=" .. tostring(duration))
end

--@api: LDecoder:rewind
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local dec = lurek.audio.newDecoder(path)
    dec:seek(5.0)
    dec:rewind()
    lurek.log.info(tostring("rewound to " .. dec:tell()))
end

--@api: LDecoder:tell
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local dec = lurek.audio.newDecoder(path)
    dec:seek(3.0)
    local pos = dec:tell()
    lurek.log.info(tostring("position = " .. pos))
end

--@api: LDecoder:isSeekable
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local dec = lurek.audio.newDecoder(path)
    local seekable = dec:isSeekable()
    dec:seek(1.0)
    local position = dec:tell()
    lurek.log.info("decoder seekable=" .. tostring(seekable))
    lurek.log.info("position after editor seek=" .. tostring(position))
end

--@api: LDecoder:release
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local dec = lurek.audio.newDecoder(path)
    local duration = dec:getDuration()
    local seekable = dec:isSeekable()
    dec:release()
    local typeName = dec:type()
    lurek.log.info("released decoder duration=" .. tostring(duration))
    lurek.log.info("decoder seekable=" .. tostring(seekable) .. " type=" .. tostring(typeName))
end

--@api: LDecoder:type
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local dec = lurek.audio.newDecoder(path)
    local typeName = dec:type()
    local isDecoder = dec:typeOf("LDecoder")
    local sampleRate = dec:getSampleRate()
    lurek.log.info("decoder type=" .. tostring(typeName))
    lurek.log.info("is decoder=" .. tostring(isDecoder) .. " sampleRate=" .. tostring(sampleRate))
end

--@api: LDecoder:typeOf
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local dec = lurek.audio.newDecoder(path)
    local isDecoder = dec:typeOf("LDecoder")
    local isObject = dec:typeOf("LObject")
    local typeName = dec:type()
    lurek.log.info("is LDecoder=" .. tostring(isDecoder))
    lurek.log.info("is LObject=" .. tostring(isObject) .. " type=" .. tostring(typeName))
end

--@api: LSoundData:getSampleCount
do
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    local sampleCount = sd:getSampleCount()
    local duration = sd:getDuration()
    local sampleRate = sd:getSampleRate()
    lurek.log.info("procedural buffer samples=" .. tostring(sampleCount))
    lurek.log.info("procedural buffer duration=" .. tostring(duration) .. " rate=" .. tostring(sampleRate))
end

--@api: LSoundData:getSampleRate
do
    local sd = lurek.audio.newSoundData(22050, 22050, 1)
    local sampleRate = sd:getSampleRate()
    local duration = sd:getDuration()
    local sampleCount = sd:getSampleCount()
    lurek.log.info("voice line sample rate=" .. tostring(sampleRate))
    lurek.log.info("voice line duration=" .. tostring(duration) .. " samples=" .. tostring(sampleCount))
end

--@api: LSoundData:getChannelCount
do
    local sd = lurek.audio.newSoundData(44100, 44100, 2)
    local channels = sd:getChannelCount()
    local sampleRate = sd:getSampleRate()
    local duration = sd:getDuration()
    lurek.log.info("stereo buffer channels=" .. tostring(channels))
    lurek.log.info("stereo buffer rate=" .. tostring(sampleRate) .. " duration=" .. tostring(duration))
end

--@api: LSoundData:getDuration
do
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    local duration = sd:getDuration()
    local sampleCount = sd:getSampleCount()
    local sampleRate = sd:getSampleRate()
    lurek.log.info("tone buffer duration=" .. tostring(duration))
    lurek.log.info("tone buffer samples=" .. tostring(sampleCount) .. " rate=" .. tostring(sampleRate))
end

--@api: LSoundData:getBitDepth
do
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    local bitDepth = sd:getBitDepth()
    local channels = sd:getChannelCount()
    local sampleRate = sd:getSampleRate()
    lurek.log.info("buffer bit depth=" .. tostring(bitDepth))
    lurek.log.info("buffer channels=" .. tostring(channels) .. " rate=" .. tostring(sampleRate))
end

--@api: LSoundData:getSample
do
    local sd = lurek.audio.newSoundData(32, 44100, 1)
    sd:setSample(0, 1.0)
    sd:setSample(1, -0.5)
    local firstSample = sd:getSample(0)
    local secondSample = sd:getSample(1)
    lurek.log.info("attack sample=" .. tostring(firstSample))
    lurek.log.info("release sample=" .. tostring(secondSample))
end

--@api: LSoundData:drawWaveform
do
    local sd = lurek.audio.newSoundData(128, 44100, 1)
    for i = 0, 127 do
        local sample = (i % 16) / 15.0
        sd:setSample(i, sample * 2.0 - 1.0)
    end
    local img = lurek.image.newImageData(400, 100)
    sd:drawWaveform(img, 0, 0, 400, 100, 0, 255, 0, 255)
    lurek.log.info(tostring("waveform drawn to image"))

end
--@api: LSoundData:setSample
do
    local sd = lurek.audio.newSoundData(100, 44100, 1)
    sd:setSample(0, 0.5)
    sd:setSample(50, -0.3)
    local startSample = sd:getSample(0)
    local midSample = sd:getSample(50)
    lurek.log.info("start sample=" .. tostring(startSample))
    lurek.log.info("mid sample=" .. tostring(midSample))
end

--@api: LSoundData:type
do
    local sd = lurek.audio.newSoundData(100, 44100, 1)
    local typeName = sd:type()
    local isSoundData = sd:typeOf("LSoundData")
    local isObject = sd:typeOf("LObject")
    lurek.log.info("sound data type=" .. tostring(typeName))
    lurek.log.info("is sound data=" .. tostring(isSoundData) .. " is object=" .. tostring(isObject))
end

--@api: LSoundData:typeOf
do
    local sd = lurek.audio.newSoundData(100, 44100, 1)
    local isSoundData = sd:typeOf("LSoundData")
    local isDecoder = sd:typeOf("LDecoder")
    local typeName = sd:type()
    lurek.log.info("is LSoundData=" .. tostring(isSoundData))
    lurek.log.info("is LDecoder=" .. tostring(isDecoder) .. " type=" .. tostring(typeName))
end

--@api: lurek.audio.newSynthWave
do
    local has_fn = type(lurek.audio.newSynthWave) == "function"
    local soundData = has_fn and lurek.audio.newSynthWave("sine", 440, 0.5, 44100, 0.8) or nil
    local sampleCount = soundData and soundData:getSampleCount() or 0
    local duration = soundData and soundData:getDuration() or 0
    lurek.log.info("newSynthWave available=" .. tostring(has_fn))
    lurek.log.info("generated synth samples=" .. tostring(sampleCount) .. " duration=" .. tostring(duration))
end

--@api: lurek.audio.setMuted
do
    local wasMuted = lurek.audio.isMuted()
    lurek.audio.setMuted(true)
    local pauseMenuMuted = lurek.audio.isMuted()
    lurek.audio.setMuted(false)
    local restored = not lurek.audio.isMuted()
    lurek.log.info("audio muted before pause menu=" .. tostring(wasMuted))
    lurek.log.info("audio muted in pause menu=" .. tostring(pauseMenuMuted) .. " restored=" .. tostring(restored))
end

--@api: lurek.audio.isMuted
do
    local muted = lurek.audio.isMuted()
    lurek.log.info(tostring("audio is muted = " .. tostring(muted)))
    if not muted then
        lurek.audio.setMuted(true)
        lurek.log.info(tostring("now muted = " .. tostring(lurek.audio.isMuted())))
    end

end
--@api: lurek.audio.stopMusic
do
    local src = lurek.audio.newSource("content/examples/assets/audio/sample_loop.wav", "stream")
    lurek.audio.play(src)
    lurek.log.info(tostring("music playing = " .. tostring(lurek.audio.isPlaying(src))))
    lurek.audio.stopMusic(0.5)
    lurek.log.info(tostring("music stopped with fade"))
end

--@api: lurek.audio.playSfx
do
    local opts = { volume = 0.8, loop = false }
    local sfx = lurek.audio.playSfx("content/examples/assets/audio/sample_click.wav", opts)
    lurek.log.info(tostring("sfx played = " .. tostring(sfx ~= nil)))
    lurek.log.info(tostring("sfx type = " .. sfx:type()))
    lurek.log.info(tostring("volume = " .. tostring(sfx:getVolume())))
end
