--- @title Cinematic Timeline
--- @desc Multi-track timeline system for orchestrating game sequences.



--@api: lurek.cinematic.newTimeline
do
    local function cinematic_log(message)
        lurek.log.info("[cinematic] " .. message)
    end
    local function make_timeline_with_signal_clip()
        local timeline = lurek.cinematic.newTimeline()
        timeline:addTrack("signals")
        timeline:addClip("signals", 0.0, 2.0, { type = "signal", name = "intro_ready", data = "scene_a" })
        return timeline
    end

    local timeline = lurek.cinematic.newTimeline()
    timeline:addTrack("camera")
    local state = timeline:getState()
    local type_name = timeline:type()
    cinematic_log("new timeline type=" .. type_name .. " state=" .. state)
end

--@api: LCinematicTimeline:addTrack
do
    local function cinematic_log(message)
        lurek.log.info("[cinematic] " .. message)
    end
    local function make_timeline_with_signal_clip()
        local timeline = lurek.cinematic.newTimeline()
        timeline:addTrack("signals")
        timeline:addClip("signals", 0.0, 2.0, { type = "signal", name = "intro_ready", data = "scene_a" })
        return timeline
    end

    local timeline = lurek.cinematic.newTimeline()
    timeline:addTrack("camera")
    timeline:addTrack("audio")
    local state = timeline:getState()
    cinematic_log("registered tracks for cutscene setup state=" .. state)
end

--@api: LCinematicTimeline:addClip
do
    local function cinematic_log(message)
        lurek.log.info("[cinematic] " .. message)
    end
    local function make_timeline_with_signal_clip()
        local timeline = lurek.cinematic.newTimeline()
        timeline:addTrack("signals")
        timeline:addClip("signals", 0.0, 2.0, { type = "signal", name = "intro_ready", data = "scene_a" })
        return timeline
    end

    local timeline = lurek.cinematic.newTimeline()
    timeline:addTrack("camera")
    timeline:addTrack("signals")
    timeline:addClip("camera", 0.0, 3.0, { type = "camera", x = 100.0, y = 50.0, zoom = 2.0, easing = "ease_out_quad" })
    timeline:addClip("signals", 2.0, 0.1, { type = "signal", name = "boss_gate_open", data = "phase_1" })
    cinematic_log("timeline duration after camera and signal clips=" .. timeline:getDuration())
end

--@api: LCinematicTimeline:play
do
    local function cinematic_log(message)
        lurek.log.info("[cinematic] " .. message)
    end
    local function make_timeline_with_signal_clip()
        local timeline = lurek.cinematic.newTimeline()
        timeline:addTrack("signals")
        timeline:addClip("signals", 0.0, 2.0, { type = "signal", name = "intro_ready", data = "scene_a" })
        return timeline
    end

    local timeline = make_timeline_with_signal_clip()
    timeline:play()
    local state = timeline:getState()
    local playing = timeline:isPlaying()
    cinematic_log("play moved timeline to state=" .. state .. " playing=" .. tostring(playing))
end

--@api: LCinematicTimeline:pause
do
    local function cinematic_log(message)
        lurek.log.info("[cinematic] " .. message)
    end
    local function make_timeline_with_signal_clip()
        local timeline = lurek.cinematic.newTimeline()
        timeline:addTrack("signals")
        timeline:addClip("signals", 0.0, 2.0, { type = "signal", name = "intro_ready", data = "scene_a" })
        return timeline
    end

    local timeline = make_timeline_with_signal_clip()
    timeline:play()
    timeline:update(1.25)
    timeline:pause()
    cinematic_log("pause kept playhead at " .. timeline:getTime() .. " with state=" .. timeline:getState())
end

--@api: LCinematicTimeline:stop
do
    local function cinematic_log(message)
        lurek.log.info("[cinematic] " .. message)
    end
    local function make_timeline_with_signal_clip()
        local timeline = lurek.cinematic.newTimeline()
        timeline:addTrack("signals")
        timeline:addClip("signals", 0.0, 2.0, { type = "signal", name = "intro_ready", data = "scene_a" })
        return timeline
    end

    local timeline = make_timeline_with_signal_clip()
    timeline:play()
    timeline:update(1.5)
    timeline:stop()
    cinematic_log("stop reset time=" .. timeline:getTime() .. " state=" .. timeline:getState())
end

--@api: LCinematicTimeline:seek
do
    local function cinematic_log(message)
        lurek.log.info("[cinematic] " .. message)
    end
    local function make_timeline_with_signal_clip()
        local timeline = lurek.cinematic.newTimeline()
        timeline:addTrack("signals")
        timeline:addClip("signals", 0.0, 2.0, { type = "signal", name = "intro_ready", data = "scene_a" })
        return timeline
    end

    local timeline = make_timeline_with_signal_clip()
    timeline:addClip("signals", 3.0, 1.0, { type = "signal", name = "camera_pan", data = "phase_2" })
    timeline:seek(1.75)
    local time = timeline:getTime()
    cinematic_log("seek positioned playhead at " .. time .. " seconds")
end

--@api: LCinematicTimeline:update
do
    local function cinematic_log(message)
        lurek.log.info("[cinematic] " .. message)
    end
    local function make_timeline_with_signal_clip()
        local timeline = lurek.cinematic.newTimeline()
        timeline:addTrack("signals")
        timeline:addClip("signals", 0.0, 2.0, { type = "signal", name = "intro_ready", data = "scene_a" })
        return timeline
    end

    local timeline = make_timeline_with_signal_clip()
    timeline:play()
    timeline:update(0.75)
    local time = timeline:getTime()
    local state = timeline:getState()
    cinematic_log("update advanced cutscene to " .. time .. " with state=" .. state)
end

--@api: LCinematicTimeline:skipToEnd
do
    local function cinematic_log(message)
        lurek.log.info("[cinematic] " .. message)
    end
    local function make_timeline_with_signal_clip()
        local timeline = lurek.cinematic.newTimeline()
        timeline:addTrack("signals")
        timeline:addClip("signals", 0.0, 2.0, { type = "signal", name = "intro_ready", data = "scene_a" })
        return timeline
    end

    local timeline = make_timeline_with_signal_clip()
    local duration = timeline:getDuration()
    timeline:skipToEnd()
    local time = timeline:getTime()
    cinematic_log("skipToEnd jumped from 0 to " .. time .. " of " .. duration)
end

--@api: LCinematicTimeline:getTime
do
    local function cinematic_log(message)
        lurek.log.info("[cinematic] " .. message)
    end
    local function make_timeline_with_signal_clip()
        local timeline = lurek.cinematic.newTimeline()
        timeline:addTrack("signals")
        timeline:addClip("signals", 0.0, 2.0, { type = "signal", name = "intro_ready", data = "scene_a" })
        return timeline
    end

    local timeline = make_timeline_with_signal_clip()
    timeline:seek(0.6)
    local time = timeline:getTime()
    local duration = timeline:getDuration()
    cinematic_log("current cinematic time=" .. time .. " within duration=" .. duration)
end

--@api: LCinematicTimeline:getDuration
do
    local function cinematic_log(message)
        lurek.log.info("[cinematic] " .. message)
    end
    local function make_timeline_with_signal_clip()
        local timeline = lurek.cinematic.newTimeline()
        timeline:addTrack("signals")
        timeline:addClip("signals", 0.0, 2.0, { type = "signal", name = "intro_ready", data = "scene_a" })
        return timeline
    end

    local timeline = lurek.cinematic.newTimeline()
    timeline:addTrack("signals")
    timeline:addClip("signals", 0.0, 5.0, { type = "signal", name = "intro" })
    timeline:addClip("signals", 2.0, 8.0, { type = "signal", name = "boss_reveal" })
    cinematic_log("timeline duration follows latest clip end=" .. timeline:getDuration())
end

--@api: LCinematicTimeline:getState
do
    local function cinematic_log(message)
        lurek.log.info("[cinematic] " .. message)
    end
    local function make_timeline_with_signal_clip()
        local timeline = lurek.cinematic.newTimeline()
        timeline:addTrack("signals")
        timeline:addClip("signals", 0.0, 2.0, { type = "signal", name = "intro_ready", data = "scene_a" })
        return timeline
    end

    local timeline = make_timeline_with_signal_clip()
    local before = timeline:getState()
    timeline:play()
    local after = timeline:getState()
    cinematic_log("state changed from " .. before .. " to " .. after)
end

--@api: LCinematicTimeline:isPlaying
do
    local function cinematic_log(message)
        lurek.log.info("[cinematic] " .. message)
    end
    local function make_timeline_with_signal_clip()
        local timeline = lurek.cinematic.newTimeline()
        timeline:addTrack("signals")
        timeline:addClip("signals", 0.0, 2.0, { type = "signal", name = "intro_ready", data = "scene_a" })
        return timeline
    end

    local timeline = make_timeline_with_signal_clip()
    local before = timeline:isPlaying()
    timeline:play()
    local after = timeline:isPlaying()
    cinematic_log("isPlaying before=" .. tostring(before) .. " after=" .. tostring(after))
end

--@api: LCinematicTimeline:isComplete
do
    local function cinematic_log(message)
        lurek.log.info("[cinematic] " .. message)
    end
    local function make_timeline_with_signal_clip()
        local timeline = lurek.cinematic.newTimeline()
        timeline:addTrack("signals")
        timeline:addClip("signals", 0.0, 2.0, { type = "signal", name = "intro_ready", data = "scene_a" })
        return timeline
    end

    local timeline = make_timeline_with_signal_clip()
    local before = timeline:isComplete()
    timeline:skipToEnd()
    local after = timeline:isComplete()
    cinematic_log("isComplete before=" .. tostring(before) .. " after=" .. tostring(after))
end

--@api: LCinematicTimeline:addLabel
do
    local function cinematic_log(message)
        lurek.log.info("[cinematic] " .. message)
    end
    local function make_timeline_with_signal_clip()
        local timeline = lurek.cinematic.newTimeline()
        timeline:addTrack("signals")
        timeline:addClip("signals", 0.0, 2.0, { type = "signal", name = "intro_ready", data = "scene_a" })
        return timeline
    end

    local timeline = make_timeline_with_signal_clip()
    timeline:addLabel("intro", 0.0)
    timeline:addLabel("reveal", 1.0)
    timeline:addLabel("exit", 2.0)
    cinematic_log("labels added for intro, reveal, and exit on duration=" .. timeline:getDuration())
end

--@api: LCinematicTimeline:branch
do
    local function cinematic_log(message)
        lurek.log.info("[cinematic] " .. message)
    end
    local function make_timeline_with_signal_clip()
        local timeline = lurek.cinematic.newTimeline()
        timeline:addTrack("signals")
        timeline:addClip("signals", 0.0, 2.0, { type = "signal", name = "intro_ready", data = "scene_a" })
        return timeline
    end

    local timeline = make_timeline_with_signal_clip()
    timeline:addLabel("checkpoint", 1.5)
    timeline:seek(0.25)
    local ok = timeline:branch("checkpoint")
    cinematic_log("branch jumped=" .. tostring(ok) .. " playhead=" .. timeline:getTime())
end

--@api: LCinematicTimeline:type
do
    local function cinematic_log(message)
        lurek.log.info("[cinematic] " .. message)
    end
    local function make_timeline_with_signal_clip()
        local timeline = lurek.cinematic.newTimeline()
        timeline:addTrack("signals")
        timeline:addClip("signals", 0.0, 2.0, { type = "signal", name = "intro_ready", data = "scene_a" })
        return timeline
    end

    local timeline = make_timeline_with_signal_clip()
    timeline:seek(0.5)
    local type_name = timeline:type()
    local state = timeline:getState()
    cinematic_log("timeline userdata type=" .. type_name .. " state=" .. state)
end

--@api: LCinematicTimeline:typeOf
do
    local function cinematic_log(message)
        lurek.log.info("[cinematic] " .. message)
    end
    local function make_timeline_with_signal_clip()
        local timeline = lurek.cinematic.newTimeline()
        timeline:addTrack("signals")
        timeline:addClip("signals", 0.0, 2.0, { type = "signal", name = "intro_ready", data = "scene_a" })
        return timeline
    end

    local timeline = make_timeline_with_signal_clip()
    timeline:play()
    local is_timeline = timeline:typeOf("LCinematicTimeline")
    local is_object = timeline:typeOf("Object")
    cinematic_log("typeOf timeline=" .. tostring(is_timeline) .. " object=" .. tostring(is_object))
end

--@api: lurek.cinematic.new
do
    local function cinematic_log(message)
        lurek.log.info("[cinematic] " .. message)
    end
    local function make_timeline_with_signal_clip()
        local timeline = lurek.cinematic.newTimeline()
        timeline:addTrack("signals")
        timeline:addClip("signals", 0.0, 2.0, { type = "signal", name = "intro_ready", data = "scene_a" })
        return timeline
    end

    local cinematic = lurek.cinematic.new()
    cinematic:addCut(0.0, "fade_from_black")
    local type_name = cinematic:type()
    local cuts = cinematic:cutCount()
    cinematic_log("legacy cinematic type=" .. type_name .. " cuts=" .. cuts)
end

--@api: LCinematic:addCut
do
    local function cinematic_log(message)
        lurek.log.info("[cinematic] " .. message)
    end
    local function make_timeline_with_signal_clip()
        local timeline = lurek.cinematic.newTimeline()
        timeline:addTrack("signals")
        timeline:addClip("signals", 0.0, 2.0, { type = "signal", name = "intro_ready", data = "scene_a" })
        return timeline
    end

    local cinematic = lurek.cinematic.new()
    cinematic:addCut(0.0, "intro_pan")
    cinematic:addCut(1.5, "player_reveal")
    local cuts = cinematic:cutCount()
    cinematic_log("legacy cut list size after addCut=" .. tostring(cuts))
end

--@api: LCinematic:cutCount
do
    local function cinematic_log(message)
        lurek.log.info("[cinematic] " .. message)
    end
    local function make_timeline_with_signal_clip()
        local timeline = lurek.cinematic.newTimeline()
        timeline:addTrack("signals")
        timeline:addClip("signals", 0.0, 2.0, { type = "signal", name = "intro_ready", data = "scene_a" })
        return timeline
    end

    local cinematic = lurek.cinematic.new()
    cinematic:addCut(0.0, "drone_establish")
    cinematic:addCut(2.0, "control_room_zoom")
    local cuts = cinematic:cutCount()
    cinematic_log("cutCount reports " .. tostring(cuts) .. " queued legacy cuts")
end

--@api: LCinematic:play
do
    local function cinematic_log(message)
        lurek.log.info("[cinematic] " .. message)
    end
    local function make_timeline_with_signal_clip()
        local timeline = lurek.cinematic.newTimeline()
        timeline:addTrack("signals")
        timeline:addClip("signals", 0.0, 2.0, { type = "signal", name = "intro_ready", data = "scene_a" })
        return timeline
    end

    local cinematic = lurek.cinematic.new()
    cinematic:addCut(0.0, "alarm_start")
    cinematic:addCut(0.5, "lights_flash")
    cinematic:play()
    cinematic_log("legacy cut list played with " .. tostring(cinematic:cutCount()) .. " cuts")
end

--@api: LCinematic:clear
do
    local function cinematic_log(message)
        lurek.log.info("[cinematic] " .. message)
    end
    local function make_timeline_with_signal_clip()
        local timeline = lurek.cinematic.newTimeline()
        timeline:addTrack("signals")
        timeline:addClip("signals", 0.0, 2.0, { type = "signal", name = "intro_ready", data = "scene_a" })
        return timeline
    end

    local cinematic = lurek.cinematic.new()
    cinematic:addCut(0.0, "temp_intro")
    cinematic:addCut(0.5, "temp_pan")
    cinematic:clear()
    cinematic_log("clear removed all cuts count=" .. tostring(cinematic:cutCount()))
end

--@api: LCinematic:type
do
    local function cinematic_log(message)
        lurek.log.info("[cinematic] " .. message)
    end
    local function make_timeline_with_signal_clip()
        local timeline = lurek.cinematic.newTimeline()
        timeline:addTrack("signals")
        timeline:addClip("signals", 0.0, 2.0, { type = "signal", name = "intro_ready", data = "scene_a" })
        return timeline
    end

    local cinematic = lurek.cinematic.new()
    cinematic:addCut(0.0, "intro")
    local type_name = cinematic:type()
    local cuts = cinematic:cutCount()
    cinematic_log("legacy cinematic type=" .. type_name .. " cuts=" .. tostring(cuts))
end

--@api: LCinematic:typeOf
do
    local function cinematic_log(message)
        lurek.log.info("[cinematic] " .. message)
    end
    local function make_timeline_with_signal_clip()
        local timeline = lurek.cinematic.newTimeline()
        timeline:addTrack("signals")
        timeline:addClip("signals", 0.0, 2.0, { type = "signal", name = "intro_ready", data = "scene_a" })
        return timeline
    end

    local cinematic = lurek.cinematic.new()
    cinematic:addCut(0.0, "intro")
    local is_cinematic = cinematic:typeOf("LCinematic")
    local is_object = cinematic:typeOf("Object")
    cinematic_log("typeOf cinematic=" .. tostring(is_cinematic) .. " object=" .. tostring(is_object))
end
