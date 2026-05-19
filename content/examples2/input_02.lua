--- Input Module Part 2: combo system, cursor, recording/playback, extra gamepad/touch/mouse

--@api-stub: LCombo:isInProgress
--@api-stub: LCombo:progress
--@api-stub: LCombo:totalSteps
-- Combo state queries.
do
    local combo = lurek.input.newCombo({ "a", "b", "c" })
    combo:feed("a")
    combo:tick(0.016)
    print("in_progress=" .. tostring(combo:isInProgress()))
    print("progress=" .. combo:progress())
    print("total=" .. combo:totalSteps())
    combo:reset()
end

--@api-stub: LCursor:getType
--@api-stub: LCursor:release
--@api-stub: LCursor:type
--@api-stub: LCursor:typeOf
-- Custom cursor lifecycle and type introspection.
do
    local sys_cursor = lurek.input.mouse.getSystemCursor("arrow")
    print("cursor type=" .. sys_cursor:type())
    print("cursor kind=" .. sys_cursor:getType())
    print("typeOf=" .. tostring(sys_cursor:typeOf("LCursor")))
    sys_cursor:release()
end

--@api-stub: LInputRecording:frameCount
--@api-stub: LInputRecording:totalFrames
--@api-stub: LInputRecording:type
--@api-stub: LInputRecording:typeOf
-- Input recording lifecycle and state queries.
do
    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    print("frames=" .. rec:frameCount())
    print("total=" .. rec:totalFrames())
    print("type=" .. rec:type())
    print("typeOf=" .. tostring(rec:typeOf("LInputRecording")))
end

--@api-stub: lurek.input.isPlayingBack
--@api-stub: lurek.input.stopPlayback
--@api-stub: lurek.input.stopRecording
-- Input recording/playback module functions.
do
    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    print("is_playing=" .. tostring(lurek.input.isPlayingBack()))
    lurek.input.startPlayback()
    lurek.input.stopPlayback()
    print("stopped")
end

--@api-stub: lurek.input.mouse.getY
-- Mouse Y position query.
do
    local y = lurek.input.mouse.getY()
    print("mouse_y=" .. y)
end

--@api-stub: lurek.input.gamepad.getJoysticks
--@api-stub: lurek.input.gamepad.saveGamepadMappings
--@api-stub: lurek.input.gamepad.setBackgroundEvents
--@api-stub: lurek.input.gamepad.wasDisconnected
--@api-stub: lurek.input.gamepad.wasReleased
-- Gamepad discovery, mappings, background events, and input release.
do
    local sticks = lurek.input.gamepad.getJoysticks()
    print("joystick_count=" .. #sticks)
    lurek.input.gamepad.saveGamepadMappings("save/mappings_out.txt")
    lurek.input.gamepad.setBackgroundEvents(false)
    local dc = lurek.input.gamepad.wasDisconnected(1)
    local rel = lurek.input.gamepad.wasReleased(1, 0)
    print("disconnected=" .. tostring(dc))
    print("released=" .. tostring(rel))
end

--@api-stub: lurek.input.touch.wasReleased
-- Touch release query.
do
    local rel = lurek.input.touch.wasReleased(1)
    print("touch_released=" .. tostring(rel))
end

--@api-stub: lurek.light.setMaxLights
-- Set max lights count.
do
    lurek.light.setMaxLights(64)
    local max = lurek.light.getMaxLights()
    print("max_lights=" .. max)
end

print("input_02.lua")
