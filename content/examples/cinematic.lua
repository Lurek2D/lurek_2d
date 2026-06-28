--- @title Cinematic Timeline
--- @desc Multi-track timeline system for orchestrating game sequences.



--@api: lurek.cinematic.newTimeline
do
    local timeline = lurek.cinematic.newTimeline()
    timeline:addTrack("camera")
    local state = timeline:getState()
    local type_name = timeline:type()
    lurek.log.info("new timeline type=" .. type_name .. " state=" .. state)
end

--@api: LCinematicTimeline:addTrack
do
    local timeline = lurek.cinematic.newTimeline()
    timeline:addTrack("camera")
    timeline:addTrack("audio")
    local state = timeline:getState()
    lurek.log.info("registered tracks for cutscene setup state=" .. state)
end

--@api: LCinematicTimeline:addClip
do
    local timeline = lurek.cinematic.newTimeline()
    timeline:addTrack("camera")
    timeline:addTrack("signals")
    timeline:addClip("camera", 0.0, 3.0, { type = "camera", x = 100.0, y = 50.0, zoom = 2.0, easing = "ease_out_quad" })
    timeline:addClip("signals", 2.0, 0.1, { type = "signal", name = "boss_gate_open", data = "phase_1" })
    lurek.log.info("timeline duration after camera and signal clips=" .. timeline:getDuration())
end

--@api: LCinematicTimeline:play
do
    local timeline = lurek.cinematic.newTimeline()
    timeline:addTrack("signals")
    timeline:addClip("signals", 0.0, 2.0, { type = "signal", name = "intro_ready", data = "scene_a" })
    timeline:play()
    local state = timeline:getState()
    local playing = timeline:isPlaying()
    lurek.log.info("play moved timeline to state=" .. state .. " playing=" .. tostring(playing))
end

--@api: LCinematicTimeline:pause
do
    local timeline = lurek.cinematic.newTimeline()
    timeline:addTrack("signals")
    timeline:addClip("signals", 0.0, 2.0, { type = "signal", name = "intro_ready", data = "scene_a" })
    timeline:play()
    timeline:update(1.25)
    timeline:pause()
    lurek.log.info("pause kept playhead at " .. timeline:getTime() .. " with state=" .. timeline:getState())
end

--@api: LCinematicTimeline:stop
do
    local timeline = lurek.cinematic.newTimeline()
    timeline:addTrack("signals")
    timeline:addClip("signals", 0.0, 2.0, { type = "signal", name = "intro_ready", data = "scene_a" })
    timeline:play()
    timeline:update(1.5)
    timeline:stop()
    lurek.log.info("stop reset time=" .. timeline:getTime() .. " state=" .. timeline:getState())
end

--@api: LCinematicTimeline:seek
do
    local timeline = lurek.cinematic.newTimeline()
    timeline:addTrack("signals")
    timeline:addClip("signals", 0.0, 2.0, { type = "signal", name = "intro_ready", data = "scene_a" })
    timeline:addClip("signals", 3.0, 1.0, { type = "signal", name = "camera_pan", data = "phase_2" })
    timeline:seek(1.75)
    local time = timeline:getTime()
    lurek.log.info("seek positioned playhead at " .. time .. " seconds")
end

--@api: LCinematicTimeline:update
do
    local timeline = lurek.cinematic.newTimeline()
    timeline:addTrack("signals")
    timeline:addClip("signals", 0.0, 2.0, { type = "signal", name = "intro_ready", data = "scene_a" })
    timeline:play()
    timeline:update(0.75)
    local time = timeline:getTime()
    local state = timeline:getState()
    lurek.log.info("update advanced cutscene to " .. time .. " with state=" .. state)
end

--@api: LCinematicTimeline:skipToEnd
do
    local timeline = lurek.cinematic.newTimeline()
    timeline:addTrack("signals")
    timeline:addClip("signals", 0.0, 2.0, { type = "signal", name = "intro_ready", data = "scene_a" })
    local duration = timeline:getDuration()
    timeline:skipToEnd()
    local time = timeline:getTime()
    lurek.log.info("skipToEnd jumped from 0 to " .. time .. " of " .. duration)
end

--@api: LCinematicTimeline:getTime
do
    local timeline = lurek.cinematic.newTimeline()
    timeline:addTrack("signals")
    timeline:addClip("signals", 0.0, 2.0, { type = "signal", name = "intro_ready", data = "scene_a" })
    timeline:seek(0.6)
    local time = timeline:getTime()
    local duration = timeline:getDuration()
    lurek.log.info("current cinematic time=" .. time .. " within duration=" .. duration)
end

--@api: LCinematicTimeline:getDuration
do
    local timeline = lurek.cinematic.newTimeline()
    timeline:addTrack("signals")
    timeline:addClip("signals", 0.0, 5.0, { type = "signal", name = "intro" })
    timeline:addClip("signals", 2.0, 8.0, { type = "signal", name = "boss_reveal" })
    lurek.log.info("timeline duration follows latest clip end=" .. timeline:getDuration())
end

--@api: LCinematicTimeline:getState
do
    local timeline = lurek.cinematic.newTimeline()
    timeline:addTrack("signals")
    timeline:addClip("signals", 0.0, 2.0, { type = "signal", name = "intro_ready", data = "scene_a" })
    local before = timeline:getState()
    timeline:play()
    local after = timeline:getState()
    lurek.log.info("state changed from " .. before .. " to " .. after)
end

--@api: LCinematicTimeline:isPlaying
do
    local timeline = lurek.cinematic.newTimeline()
    timeline:addTrack("signals")
    timeline:addClip("signals", 0.0, 2.0, { type = "signal", name = "intro_ready", data = "scene_a" })
    local before = timeline:isPlaying()
    timeline:play()
    local after = timeline:isPlaying()
    lurek.log.info("isPlaying before=" .. tostring(before) .. " after=" .. tostring(after))
end

--@api: LCinematicTimeline:isComplete
do
    local timeline = lurek.cinematic.newTimeline()
    timeline:addTrack("signals")
    timeline:addClip("signals", 0.0, 2.0, { type = "signal", name = "intro_ready", data = "scene_a" })
    local before = timeline:isComplete()
    timeline:skipToEnd()
    local after = timeline:isComplete()
    lurek.log.info("isComplete before=" .. tostring(before) .. " after=" .. tostring(after))
end

--@api: LCinematicTimeline:addLabel
do
    local timeline = lurek.cinematic.newTimeline()
    timeline:addTrack("signals")
    timeline:addClip("signals", 0.0, 2.0, { type = "signal", name = "intro_ready", data = "scene_a" })
    timeline:addLabel("intro", 0.0)
    timeline:addLabel("reveal", 1.0)
    timeline:addLabel("exit", 2.0)
    lurek.log.info("labels added for intro, reveal, and exit on duration=" .. timeline:getDuration())
end

--@api: LCinematicTimeline:branch
do
    local timeline = lurek.cinematic.newTimeline()
    timeline:addTrack("signals")
    timeline:addClip("signals", 0.0, 2.0, { type = "signal", name = "intro_ready", data = "scene_a" })
    timeline:addLabel("checkpoint", 1.5)
    timeline:seek(0.25)
    local ok = timeline:branch("checkpoint")
    lurek.log.info("branch jumped=" .. tostring(ok) .. " playhead=" .. timeline:getTime())
end

--@api: LCinematicTimeline:type
do
    local timeline = lurek.cinematic.newTimeline()
    timeline:addTrack("signals")
    timeline:addClip("signals", 0.0, 2.0, { type = "signal", name = "intro_ready", data = "scene_a" })
    timeline:seek(0.5)
    local type_name = timeline:type()
    local state = timeline:getState()
    lurek.log.info("timeline userdata type=" .. type_name .. " state=" .. state)
end

--@api: LCinematicTimeline:typeOf
do
    local timeline = lurek.cinematic.newTimeline()
    timeline:addTrack("signals")
    timeline:addClip("signals", 0.0, 2.0, { type = "signal", name = "intro_ready", data = "scene_a" })
    timeline:play()
    local is_timeline = timeline:typeOf("LCinematicTimeline")
    local is_object = timeline:typeOf("Object")
    lurek.log.info("typeOf timeline=" .. tostring(is_timeline) .. " object=" .. tostring(is_object))
end

--@api: lurek.cinematic.new
do
    local cinematic = lurek.cinematic.new()
    cinematic:addCut(0.0, "fade_from_black")
    local type_name = cinematic:type()
    local cuts = cinematic:cutCount()
    lurek.log.info("legacy cinematic type=" .. type_name .. " cuts=" .. cuts)
end

--@api: LCinematic:addCut
do
    local cinematic = lurek.cinematic.new()
    cinematic:addCut(0.0, "intro_pan")
    cinematic:addCut(1.5, "player_reveal")
    local cuts = cinematic:cutCount()
    lurek.log.info("legacy cut list size after addCut=" .. tostring(cuts))
end

--@api: LCinematic:cutCount
do
    local cinematic = lurek.cinematic.new()
    cinematic:addCut(0.0, "drone_establish")
    cinematic:addCut(2.0, "control_room_zoom")
    local cuts = cinematic:cutCount()
    lurek.log.info("cutCount reports " .. tostring(cuts) .. " queued legacy cuts")
end

--@api: LCinematic:play
do
    local cinematic = lurek.cinematic.new()
    cinematic:addCut(0.0, "alarm_start")
    cinematic:addCut(0.5, "lights_flash")
    cinematic:play()
    lurek.log.info("legacy cut list played with " .. tostring(cinematic:cutCount()) .. " cuts")
end

--@api: LCinematic:clear
do
    local cinematic = lurek.cinematic.new()
    cinematic:addCut(0.0, "temp_intro")
    cinematic:addCut(0.5, "temp_pan")
    cinematic:clear()
    lurek.log.info("clear removed all cuts count=" .. tostring(cinematic:cutCount()))
end

--@api: LCinematic:type
do
    local cinematic = lurek.cinematic.new()
    cinematic:addCut(0.0, "intro")
    local type_name = cinematic:type()
    local cuts = cinematic:cutCount()
    lurek.log.info("legacy cinematic type=" .. type_name .. " cuts=" .. tostring(cuts))
end

--@api: LCinematic:typeOf
do
    local cinematic = lurek.cinematic.new()
    cinematic:addCut(0.0, "intro")
    local is_cinematic = cinematic:typeOf("LCinematic")
    local is_object = cinematic:typeOf("Object")
    lurek.log.info("typeOf cinematic=" .. tostring(is_cinematic) .. " object=" .. tostring(is_object))
end
