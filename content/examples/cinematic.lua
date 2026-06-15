--- @title Cinematic Timeline
--- @desc Multi-track timeline system for orchestrating game sequences.

--@api: lurek.cinematic.newTimeline
do
    local tl = lurek.cinematic.newTimeline()
    print("lurek.cinematic.newTimeline type=" .. tl:type())
    print("state=" .. tl:getState())
end

--@api: LCinematicTimeline:addTrack
do
    local tl = lurek.cinematic.newTimeline()
    tl:addTrack("camera")
    tl:addTrack("audio")
    print("LCinematicTimeline:addTrack ok")
end

--@api: LCinematicTimeline:addClip
do
    local tl = lurek.cinematic.newTimeline()
    local camera_clip = {
        type = "camera",
        x = 100.0,
        y = 50.0,
        zoom = 2.0,
        easing = "ease_out_quad"
    }
    tl:addClip("camera", 0.0, 3.0, camera_clip)
    print("LCinematicTimeline:addClip camera clip ok")

    -- add signal clip
    local signal_clip = {
        type = "signal",
        name = "combat_start",
        data = "goblin_wave_1"
    }
    tl:addClip("signals", 2.0, 0.1, signal_clip)
    print("LCinematicTimeline:addClip signal clip ok")

    -- add audio clip
    local audio_clip = {
        type = "audio",
        path = "music/boss_theme.wav"
    }
    tl:addClip("music", 5.0, 30.0, audio_clip)
    print("LCinematicTimeline:addClip audio clip ok")

    -- add tween clip
    local tween_clip = {
        type = "tween",
        target = "player_sprite",
        properties = { x = 500.0, y = 300.0, alpha = 1.0 },
        easing = "ease_in_out_cubic"
    }
    tl:addClip("tweens", 1.0, 2.0, tween_clip)
    print("LCinematicTimeline:addClip tween clip ok")
end

--@api: LCinematicTimeline:play
do
    local tl = lurek.cinematic.newTimeline()
    tl:addClip("test", 0.0, 5.0, { type = "signal", name = "test" })
    tl:play()
    print("LCinematicTimeline:play state=" .. tl:getState())
end

--@api: LCinematicTimeline:pause
do
    local tl = lurek.cinematic.newTimeline()
    tl:addClip("test", 0.0, 10.0, { type = "signal", name = "test" })
    tl:play()
    tl:update(3.0)
    tl:pause()
    print("LCinematicTimeline:pause state=" .. tl:getState())
    print("time=" .. tl:getTime())
end

--@api: LCinematicTimeline:stop
do
    local tl = lurek.cinematic.newTimeline()
    tl:addClip("test", 0.0, 10.0, { type = "signal", name = "test" })
    tl:play()
    tl:update(5.0)
    tl:stop()
    print("LCinematicTimeline:stop state=" .. tl:getState())
    print("time reset=" .. tl:getTime())
end

--@api: LCinematicTimeline:seek
do
    local tl = lurek.cinematic.newTimeline()
    tl:addClip("test", 0.0, 20.0, { type = "signal", name = "test" })
    tl:seek(10.5)
    print("LCinematicTimeline:seek time=" .. tl:getTime())
end

--@api: LCinematicTimeline:update
do
    local tl = lurek.cinematic.newTimeline()
    tl:addClip("test", 0.0, 10.0, { type = "signal", name = "test" })
    tl:play()
    tl:update(2.5)
    print("LCinematicTimeline:update time=" .. tl:getTime())
end

--@api: LCinematicTimeline:skipToEnd
do
    local tl = lurek.cinematic.newTimeline()
    tl:addClip("test", 0.0, 15.0, { type = "signal", name = "test" })
    tl:skipToEnd()
    print("LCinematicTimeline:skipToEnd time=" .. tl:getTime())
end

--@api: LCinematicTimeline:getTime
do
    local tl = lurek.cinematic.newTimeline()
    tl:addClip("test", 0.0, 10.0, { type = "signal", name = "test" })
    tl:seek(4.2)
    print("LCinematicTimeline:getTime=" .. tl:getTime())
end

--@api: LCinematicTimeline:getDuration
do
    local tl = lurek.cinematic.newTimeline()
    tl:addClip("track1", 0.0, 5.0, { type = "signal", name = "a" })
    tl:addClip("track2", 2.0, 8.0, { type = "signal", name = "b" })
    print("LCinematicTimeline:getDuration=" .. tl:getDuration())
end

--@api: LCinematicTimeline:getState
do
    local tl = lurek.cinematic.newTimeline()
    tl:addClip("test", 0.0, 5.0, { type = "signal", name = "test" })
    print("initial state=" .. tl:getState())
    tl:play()
    print("after play=" .. tl:getState())
end

--@api: LCinematicTimeline:isPlaying
do
    local tl = lurek.cinematic.newTimeline()
    tl:addClip("test", 0.0, 5.0, { type = "signal", name = "test" })
    print("before play=" .. tostring(tl:isPlaying()))
    tl:play()
    print("after play=" .. tostring(tl:isPlaying()))
end

--@api: LCinematicTimeline:isComplete
do
    local tl = lurek.cinematic.newTimeline()
    tl:addClip("test", 0.0, 5.0, { type = "signal", name = "test" })
    print("at start=" .. tostring(tl:isComplete()))
    tl:seek(6.0)
    print("past end=" .. tostring(tl:isComplete()))
end

--@api: LCinematicTimeline:addLabel
do
    local tl = lurek.cinematic.newTimeline()
    tl:addClip("test", 0.0, 20.0, { type = "signal", name = "test" })
    tl:addLabel("intro", 0.0)
    tl:addLabel("midpoint", 10.0)
    tl:addLabel("ending", 20.0)
    print("LCinematicTimeline:addLabel ok")
end

--@api: LCinematicTimeline:branch
do
    local tl = lurek.cinematic.newTimeline()
    tl:addClip("test", 0.0, 20.0, { type = "signal", name = "test" })
    tl:addLabel("checkpoint", 7.5)
    local ok = tl:branch("checkpoint")
    print("LCinematicTimeline:branch ok=" .. tostring(ok))
    print("jumped to=" .. tl:getTime())
end

--@api: LCinematicTimeline:type
do
    local tl = lurek.cinematic.newTimeline()
    print("LCinematicTimeline:type=" .. tl:type())
end

--@api: LCinematicTimeline:typeOf
do
    local tl = lurek.cinematic.newTimeline()
    print("typeOf LCinematicTimeline=" .. tostring(tl:typeOf("LCinematicTimeline")))
    print("typeOf Object=" .. tostring(tl:typeOf("Object")))
end

--@api: lurek.cinematic.new
do
    local cinematic = lurek.cinematic.new()
    print("lurek.cinematic.new type=" .. cinematic:type())
end

--@api: LCinematic:addCut
do
    local cinematic = lurek.cinematic.new()
    cinematic:addCut(0.0, "Intro pan")
    cinematic:addCut(1.5, "Player reveal")
    print("cuts after add = " .. tostring(cinematic:cutCount()))
end

--@api: LCinematic:cutCount
do
    local cinematic = lurek.cinematic.new()
    cinematic:addCut(0.0, "single cut")
    print("cut count = " .. tostring(cinematic:cutCount()))
end

--@api: LCinematic:play
do
    local cinematic = lurek.cinematic.new()
    cinematic:addCut(0.0, "start")
    cinematic:play()
    print("cinematic play invoked")
end

--@api: LCinematic:clear
do
    local cinematic = lurek.cinematic.new()
    cinematic:addCut(0.0, "to clear")
    cinematic:clear()
    print("cut count after clear = " .. tostring(cinematic:cutCount()))
end

--@api: LCinematic:type
do
    local cinematic = lurek.cinematic.new()
    print("LCinematic:type = " .. cinematic:type())
end

--@api: LCinematic:typeOf
do
    local cinematic = lurek.cinematic.new()
    print("is LCinematic = " .. tostring(cinematic:typeOf("LCinematic")))
    print("is Object = " .. tostring(cinematic:typeOf("Object")))
end
