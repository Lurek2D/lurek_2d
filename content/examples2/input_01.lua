--- Input Module Part 2: action bindings, combos, recording/playback

--@api-stub: lurek.input.bind
-- Binds keys to an action name.
do
    lurek.input.bind("jump", "space")
    lurek.input.bind("move_left", {"a", "left"})
    print("actions bound")
end

--@api-stub: lurek.input.unbind
-- Removes all bindings for an action.
do
    lurek.input.bind("temp", "t")
    local had = lurek.input.unbind("temp")
    print("unbind had bindings = " .. tostring(had))
end

--@api-stub: lurek.input.clearBindings
-- Clears all action bindings.
do
    lurek.input.bind("a1", "q")
    lurek.input.bind("a2", "e")
    lurek.input.clearBindings()
    print("all bindings cleared")
end

--@api-stub: lurek.input.getBindings
-- Returns the current binding map.
do
    lurek.input.bind("shoot", "x")
    local bindings = lurek.input.getBindings()
    print("bindings count = " .. #bindings)
end

--@api-stub: lurek.input.isActionDown
-- Checks if an action is currently held.
do
    lurek.input.bind("fire", "space")
    local down = lurek.input.isActionDown("fire")
    print("fire down = " .. tostring(down))
end

--@api-stub: lurek.input.wasActionPressed
-- Checks if an action was pressed this frame.
do
    lurek.input.bind("jump", "space")
    local pressed = lurek.input.wasActionPressed("jump")
    print("jump pressed = " .. tostring(pressed))
end

--@api-stub: lurek.input.wasActionPressedWithin
-- Checks if an action was pressed within recent frames.
do
    lurek.input.bind("dodge", "shift")
    local recent = lurek.input.wasActionPressedWithin("dodge", 10)
    print("dodge recent = " .. tostring(recent))
end

--@api-stub: lurek.input.wasActionReleased
-- Checks if an action was released this frame.
do
    lurek.input.bind("run", "shift")
    local released = lurek.input.wasActionReleased("run")
    print("run released = " .. tostring(released))
end

--@api-stub: lurek.input.isDown
-- Checks if any bound key in current mapping is down.
do
    local down = lurek.input.isDown()
    print("any mapping down = " .. tostring(down))
end

--@api-stub: lurek.input.wasPressed
-- Checks if any bound key was pressed this frame.
do
    local pressed = lurek.input.wasPressed()
    print("any mapping pressed = " .. tostring(pressed))
end

--@api-stub: lurek.input.wasReleased
-- Checks if any bound key was released this frame.
do
    local released = lurek.input.wasReleased()
    print("any mapping released = " .. tostring(released))
end

--@api-stub: lurek.input.newMapping
-- Creates an action mapping with query closures.
do
    local mapping = lurek.input.newMapping("attack", {"z", "button1"})
    local held = mapping.isDown()
    local just = mapping.wasPressed()
    local done = mapping.wasReleased()
    print("held=" .. tostring(held) .. " just=" .. tostring(just) .. " done=" .. tostring(done))
end

--@api-stub: lurek.input.newCombo
-- Creates a combo detector.
do
    local combo = lurek.input.newCombo({"down", "right", "z"}, {total_gap = 500})
    print("combo steps = " .. combo:totalSteps())
    print("in progress = " .. tostring(combo:isInProgress()))
    print("progress = " .. combo:progress())
end

--@api-stub: LCombo:feed
-- Feeds a key press to the combo.
do
    local combo = lurek.input.newCombo({"a", "b", "c"})
    local result = combo:feed("a")
    print("feed a → " .. result)
end

--@api-stub: LCombo:tick
-- Advances combo timer by delta time.
do
    local combo = lurek.input.newCombo({"x", "y"}, {total_gap = 300})
    local result = combo:tick(0.016)
    print("tick → " .. result)
end

--@api-stub: LCombo:getStep
-- Returns step info at an index.
do
    local combo = lurek.input.newCombo({"a", "b"})
    local step = combo:getStep(1)
    print("step 1 key = " .. step.key .. " gap = " .. step.gap_ms)
end

--@api-stub: LCombo:reset
-- Resets combo progress.
do
    local combo = lurek.input.newCombo({"q", "w", "e"})
    combo:feed("q")
    combo:reset()
    print("progress after reset = " .. combo:progress())
end

--@api-stub: LCombo:type / typeOf
-- Type identity.
do
    local combo = lurek.input.newCombo({"a"})
    print("type = " .. combo:type())
    print("is Combo = " .. tostring(combo:typeOf("Combo")))
end

--@api-stub: lurek.input.startRecording / stopRecording
-- Records input and returns a recording handle.
do
    lurek.input.startRecording()
    local recording = lurek.input.stopRecording()
    if recording then
        print("frames = " .. recording:frameCount())
        print("total = " .. recording:totalFrames())
    end
end

--@api-stub: LInputRecording:toJson
-- Serializes recording to JSON.
do
    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    if rec then
        local json = rec:toJson()
        print("json length = " .. #json)
    end
end

--@api-stub: lurek.input.loadRecording
-- Loads a recording from JSON.
do
    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    if rec then
        local json = rec:toJson()
        lurek.input.loadRecording(json)
        print("recording loaded")
    end
end

--@api-stub: lurek.input.startPlayback / stopPlayback
-- Starts and stops playback of a loaded recording.
do
    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    if rec then
        lurek.input.loadRecording(rec:toJson())
        lurek.input.startPlayback()
        print("playing = " .. tostring(lurek.input.isPlayingBack()))
        lurek.input.stopPlayback()
        print("stopped = " .. tostring(not lurek.input.isPlayingBack()))
    end
end

--@api-stub: lurek.input.advancePlayback
-- Advances playback by one frame.
do
    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    if rec then
        lurek.input.loadRecording(rec:toJson())
        lurek.input.startPlayback()
        local events = lurek.input.advancePlayback()
        print("events = " .. #events)
        lurek.input.stopPlayback()
    end
end

--@api-stub: lurek.input.getPlaybackFrame
-- Returns current playback frame index.
do
    local frame = lurek.input.getPlaybackFrame()
    print("playback frame = " .. frame)
end

--@api-stub: lurek.input.isRecording / isPlayingBack
-- State queries for recording/playback.
do
    print("recording = " .. tostring(lurek.input.isRecording()))
    print("playing = " .. tostring(lurek.input.isPlayingBack()))
end

--@api-stub: lurek.input.gamepad.getGamepadMappingString
-- Returns the mapping string for a GUID.
do
    local guid = lurek.input.gamepad.getGUID(1)
    local mapping = lurek.input.gamepad.getGamepadMappingString(guid)
    print("mapping = " .. mapping)
end

--@api-stub: lurek.input.gamepad.setGamepadMapping
-- Sets a custom gamepad mapping.
do
    local guid = lurek.input.gamepad.getGUID(1)
    lurek.input.gamepad.setGamepadMapping(guid, "custom_mapping_string")
    print("custom mapping set")
end

--@api-stub: lurek.input.gamepad.setVibration
-- Alternative vibration function.
do
    lurek.input.gamepad.setVibration(1, 0.3, 0.7, 100)
    print("vibration set")
end

print("input_01.lua")
