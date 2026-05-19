-- content/examples/input.lua
-- Auto-generated from content/examples2/input_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/input.lua

--- Input Module Part 1: keyboard, mouse, gamepad, touch functions


--@api-stub: lurek.input.keyboard.isDown
-- Checks if any of the given keys are held.
do
    local down = lurek.input.keyboard.isDown("space", "w", "up")
    print("any key down = " .. tostring(down))
end

--@api-stub: lurek.input.keyboard.isScancodeDown
-- Checks if a scancode is held.
do
    local down = lurek.input.keyboard.isScancodeDown("a")
    print("scancode a down = " .. tostring(down))
end

--@api-stub: lurek.input.keyboard.isModifierActive
-- Checks if a modifier key is active.
do
    local shift = lurek.input.keyboard.isModifierActive("shift")
    local ctrl = lurek.input.keyboard.isModifierActive("ctrl")
    print("shift=" .. tostring(shift) .. " ctrl=" .. tostring(ctrl))
end

--@api-stub: lurek.input.keyboard.getKeyFromScancode
-- Converts a scancode to a key name.
do
    local key = lurek.input.keyboard.getKeyFromScancode("a")
    print("scancode 'a' → key '" .. key .. "'")
end

--@api-stub: lurek.input.keyboard.getScancodeFromKey
-- Converts a key name to a scancode.
do
    local sc = lurek.input.keyboard.getScancodeFromKey("space")
    print("key 'space' → scancode '" .. sc .. "'")
end

--@api-stub: lurek.input.keyboard.hasKeyRepeat
-- Returns whether key repeat is enabled.
do
    print("key repeat = " .. tostring(lurek.input.keyboard.hasKeyRepeat()))
end

--@api-stub: lurek.input.keyboard.setKeyRepeat
-- Enables or disables key repeat.
do
    lurek.input.keyboard.setKeyRepeat(true)
    print("key repeat enabled")
end

--@api-stub: lurek.input.keyboard.hasTextInput
-- Returns whether text input mode is active.
do
    print("text input = " .. tostring(lurek.input.keyboard.hasTextInput()))
end

--@api-stub: lurek.input.keyboard.setTextInput
-- Enables or disables text input mode.
do
    lurek.input.keyboard.setTextInput(true)
    print("text input enabled")
end

--@api-stub: lurek.input.mouse.getPosition
-- Returns mouse x,y position.
do
    local x, y = lurek.input.mouse.getPosition()
    print("mouse at " .. x .. "," .. y)
end

--@api-stub: lurek.input.mouse.getX
-- Returns individual mouse coordinates. Focus: getX.
do
    local x = lurek.input.mouse.getX()
    print("mouse x=" .. x)
end

--@api-stub: lurek.input.mouse.getY
-- Returns individual mouse coordinates. Focus: getY.
do
    local y = lurek.input.mouse.getY()
    print("mouse y=" .. y)
end

--@api-stub: lurek.input.mouse.isDown
-- Checks if a mouse button is held.
do
    local left = lurek.input.mouse.isDown(1)
    local right = lurek.input.mouse.isDown(2)
    print("left=" .. tostring(left) .. " right=" .. tostring(right))
end

--@api-stub: lurek.input.mouse.getWheelDelta
-- Returns wheel scroll delta.
do
    local delta = lurek.input.mouse.getWheelDelta()
    print("wheel delta = " .. delta)
end

--@api-stub: lurek.input.mouse.setPosition
-- Warps the mouse to a position.
do
    lurek.input.mouse.setPosition(400, 300)
    print("mouse warped to 400,300")
end

--@api-stub: lurek.input.mouse.isVisible
-- Returns whether cursor is visible.
do
    print("cursor visible = " .. tostring(lurek.input.mouse.isVisible()))
end

--@api-stub: lurek.input.mouse.setVisible
-- Shows or hides the mouse cursor.
do
    lurek.input.mouse.setVisible(true)
    print("cursor shown")
end

--@api-stub: lurek.input.mouse.isGrabbed
-- Returns whether mouse is grabbed.
do
    print("grabbed = " .. tostring(lurek.input.mouse.isGrabbed()))
end

--@api-stub: lurek.input.mouse.setGrabbed
-- Grabs or releases the mouse.
do
    lurek.input.mouse.setGrabbed(false)
    print("mouse released")
end

--@api-stub: lurek.input.mouse.getRelativeMode
-- Returns whether relative mouse mode is active.
do
    print("relative mode = " .. tostring(lurek.input.mouse.getRelativeMode()))
end

--@api-stub: lurek.input.mouse.setRelativeMode
-- Enables or disables relative mouse mode.
do
    lurek.input.mouse.setRelativeMode(false)
    print("relative mode off")
end

--@api-stub: lurek.input.mouse.isCursorSupported
-- Returns whether custom cursors are supported.
do
    print("cursor supported = " .. tostring(lurek.input.mouse.isCursorSupported()))
end

--@api-stub: lurek.input.mouse.getCursor
-- Returns the current system cursor name.
do
    local name = lurek.input.mouse.getCursor()
    print("cursor name = " .. name)
end

--@api-stub: lurek.input.mouse.getSystemCursor
-- Sets an active cursor handle. Focus: getSystemCursor.
do
    local cursor = lurek.input.mouse.getSystemCursor("arrow")
    print("got system cursor = " .. tostring(cursor ~= nil))
end

--@api-stub: lurek.input.mouse.setCursor
-- Sets an active cursor handle. Focus: setCursor.
do
    local cursor = lurek.input.mouse.getSystemCursor("arrow")
    lurek.input.mouse.setCursor(cursor)
    print("cursor set to arrow")
end

--@api-stub: lurek.input.mouse.newCursor
-- Creates a custom cursor from RGBA pixel table.
do
    local pixels = {}
    for i = 1, 16 * 16 * 4 do pixels[i] = 255 end
    local cursor = lurek.input.mouse.newCursor(pixels, 16, 16, 0, 0)
    print("custom cursor type = " .. cursor:getType())
end

--@api-stub: lurek.input.gamepad.getCount
-- Returns number of gamepad slots.
do
    local count = lurek.input.gamepad.getCount()
    print("gamepad slots = " .. count)
end

--@api-stub: lurek.input.gamepad.isConnected
-- Returns whether a gamepad is connected.
do
    local connected = lurek.input.gamepad.isConnected(1)
    print("gamepad 1 connected = " .. tostring(connected))
end

--@api-stub: lurek.input.gamepad.isGamepad
-- Returns whether an ID is a gamepad.
do
    local is_gp = lurek.input.gamepad.isGamepad(1)
    print("is gamepad = " .. tostring(is_gp))
end

--@api-stub: lurek.input.gamepad.getName
-- Returns the gamepad name.
do
    local name = lurek.input.gamepad.getName(1)
    print("gamepad name = " .. name)
end

--@api-stub: lurek.input.gamepad.getGUID
-- Returns the gamepad GUID.
do
    local guid = lurek.input.gamepad.getGUID(1)
    print("guid = " .. guid)
end

--@api-stub: lurek.input.gamepad.getAxis
-- Returns a gamepad axis value.
do
    local val = lurek.input.gamepad.getAxis(1, 1)
    print("axis 1 = " .. val)
end

--@api-stub: lurek.input.gamepad.getAxisCount
-- Returns number of axes on a gamepad.
do
    local count = lurek.input.gamepad.getAxisCount(1)
    print("axes = " .. count)
end

--@api-stub: lurek.input.gamepad.getButtonCount
-- Returns number of buttons on a gamepad.
do
    local count = lurek.input.gamepad.getButtonCount(1)
    print("buttons = " .. count)
end

--@api-stub: lurek.input.gamepad.isDown
-- Checks if a gamepad button is held.
do
    local pressed = lurek.input.gamepad.isDown(1, 1)
    print("button 1 = " .. tostring(pressed))
end

--@api-stub: lurek.input.gamepad.wasPressed
-- Checks if button was pressed or released this frame. Focus: wasPressed.
do
    local pressed = lurek.input.gamepad.wasPressed(1, 1)
    print("pressed=" .. tostring(pressed))
end

--@api-stub: lurek.input.gamepad.wasReleased
-- Checks if button was pressed or released this frame. Focus: wasReleased.
do
    local released = lurek.input.gamepad.wasReleased(1, 1)
    print("released=" .. tostring(released))
end

--@api-stub: lurek.input.gamepad.getHat
-- Returns a hat direction value.
do
    local hat = lurek.input.gamepad.getHat(1, 1)
    print("hat 1 = " .. hat)
end

--@api-stub: lurek.input.gamepad.vibrate
-- Triggers gamepad vibration.
do
    local ok = lurek.input.gamepad.vibrate(1, 0.5, 0.5, 200)
    print("vibrate ok = " .. tostring(ok))
end

--@api-stub: lurek.input.gamepad.isVibrationSupported
-- Checks if vibration is supported.
do
    local sup = lurek.input.gamepad.isVibrationSupported(1)
    print("vibration supported = " .. tostring(sup))
end

--@api-stub: lurek.input.gamepad.virtualDpad
-- Converts analog to dpad.
do
    local dpad = lurek.input.gamepad.virtualDpad(0.8, 0.0, 0.3)
    print("direction = " .. dpad.direction)
    print("right = " .. tostring(dpad.right))
end

--@api-stub: lurek.input.gamepad.wasConnected
-- Detects connection changes this frame. Focus: wasConnected.
do
    local c = lurek.input.gamepad.wasConnected(1)
    print("connected=" .. tostring(c))
end

--@api-stub: lurek.input.gamepad.wasDisconnected
-- Detects connection changes this frame. Focus: wasDisconnected.
do
    local d = lurek.input.gamepad.wasDisconnected(1)
    print("disconnected=" .. tostring(d))
end

--@api-stub: lurek.input.gamepad.loadGamepadMappings
-- Loads and saves SDL gamepad mappings. Focus: loadGamepadMappings.
do
    local mappingPath = "save/gamecontrollerdb.txt"
    lurek.filesystem.write(mappingPath, "030000005e0400008e02000014010000,XInput,a:b0\n")
    lurek.input.gamepad.loadGamepadMappings(mappingPath)
    lurek.input.gamepad.saveGamepadMappings("save/mappings_out.txt")
    print("mappings loaded and saved")
end

--@api-stub: lurek.input.gamepad.saveGamepadMappings
-- Loads and saves SDL gamepad mappings. Focus: saveGamepadMappings.
do
    local mappingPath = "save/gamecontrollerdb.txt"
    lurek.filesystem.write(mappingPath, "030000005e0400008e02000014010000,XInput,a:b0\n")
    lurek.input.gamepad.loadGamepadMappings(mappingPath)
    lurek.input.gamepad.saveGamepadMappings("save/mappings_out.txt")
    print("mappings loaded and saved")
end

--@api-stub: lurek.input.gamepad.getBackgroundEvents
-- Controls background event processing. Focus: getBackgroundEvents.
do
    local was = lurek.input.gamepad.getBackgroundEvents()
    lurek.input.gamepad.setBackgroundEvents(true)
    print("bg events was=" .. tostring(was) .. " now=true")
end

--@api-stub: lurek.input.gamepad.setBackgroundEvents
-- Controls background event processing. Focus: setBackgroundEvents.
do
    local was = lurek.input.gamepad.getBackgroundEvents()
    lurek.input.gamepad.setBackgroundEvents(true)
    print("bg events was=" .. tostring(was) .. " now=true")
end

--@api-stub: lurek.input.gamepad.getJoystickCount
-- Enumerates joysticks. Focus: getJoystickCount.
do
    local count = lurek.input.gamepad.getJoystickCount()
    local sticks = lurek.input.gamepad.getJoysticks()
    print("joystick count = " .. count .. ", list = " .. #sticks)
end

--@api-stub: lurek.input.gamepad.getJoysticks
-- Enumerates joysticks. Focus: getJoysticks.
do
    local count = lurek.input.gamepad.getJoystickCount()
    local sticks = lurek.input.gamepad.getJoysticks()
    print("joystick count = " .. count .. ", list = " .. #sticks)
end

--@api-stub: lurek.input.touch.getTouchCount
-- Returns active touch count.
do
    local count = lurek.input.touch.getTouchCount()
    print("touches = " .. count)
end

--@api-stub: lurek.input.touch.getTouches
-- Returns all active touch ids.
do
    local touches = lurek.input.touch.getTouches()
    print("touch ids = " .. #touches)
end

--@api-stub: lurek.input.touch.getPosition
-- Returns touch position by id.
do
    local x, y = lurek.input.touch.getPosition(1)
    print("touch 1 at " .. x .. "," .. y)
end

--@api-stub: lurek.input.touch.getPressure
-- Returns touch pressure.
do
    local p = lurek.input.touch.getPressure(1)
    print("pressure = " .. p)
end

--@api-stub: lurek.input.touch.wasPressed
-- Detects touch begin/end this frame. Focus: wasPressed.
do
    local pressed = lurek.input.touch.wasPressed(1)
    local released = lurek.input.touch.wasReleased(1)
    print("t1 pressed=" .. tostring(pressed) .. " released=" .. tostring(released))
end

--@api-stub: lurek.input.touch.wasReleased
-- Detects touch begin/end this frame. Focus: wasReleased.
do
    local pressed = lurek.input.touch.wasPressed(1)
    local released = lurek.input.touch.wasReleased(1)
    print("t1 pressed=" .. tostring(pressed) .. " released=" .. tostring(released))
end

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
    print("isDown available = " .. tostring(type(lurek.input.isDown) == "function"))
end

--@api-stub: lurek.input.wasPressed
-- Checks if any bound key was pressed this frame.
do
    print("wasPressed available = " .. tostring(type(lurek.input.wasPressed) == "function"))
end

--@api-stub: lurek.input.wasReleased
-- Checks if any bound key was released this frame.
do
    print("wasReleased available = " .. tostring(type(lurek.input.wasReleased) == "function"))
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

--@api-stub: LCombo:type
-- Type identity. Focus: type.
do
    local combo = lurek.input.newCombo({"a"})
    print("type = " .. combo:type())
    print("is Combo = " .. tostring(combo:typeOf("Combo")))
end

--@api-stub: LCombo:typeOf
-- Type identity. Focus: typeOf.
do
    local combo = lurek.input.newCombo({"a"})
    print("type = " .. combo:type())
    print("is Combo = " .. tostring(combo:typeOf("Combo")))
end

--@api-stub: lurek.input.startRecording
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

--@api-stub: lurek.input.startPlayback
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

--@api-stub: lurek.input.isRecording
-- State queries for recording/playback.
do
    print("recording = " .. tostring(lurek.input.isRecording()))
    print("playing = " .. tostring(lurek.input.isPlayingBack()))
end

--@api-stub: lurek.input.gamepad.getGamepadMappingString
-- Returns the mapping string for a GUID.
do
    local guid = "030000005e0400008e02000014010000"
    lurek.input.gamepad.setGamepadMapping(guid, guid .. ",XInput,a:b0")
    local mapping = lurek.input.gamepad.getGamepadMappingString(guid)
    print("mapping = " .. tostring(mapping))
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

--- Input Module Part 2: combo system, cursor, recording/playback, extra gamepad/touch/mouse


--@api-stub: LCombo:isInProgress
-- Combo state queries. Focus: isInProgress.
do
    local combo = lurek.input.newCombo({ "a", "b", "c" })
    combo:feed("a")
    combo:tick(0.016)
    print("in_progress=" .. tostring(combo:isInProgress()))
    print("progress=" .. combo:progress())
    print("total=" .. combo:totalSteps())
    combo:reset()
end

--@api-stub: LCombo:progress
-- Combo state queries. Focus: progress.
do
    local combo = lurek.input.newCombo({ "a", "b", "c" })
    combo:feed("a")
    combo:tick(0.016)
    print("in_progress=" .. tostring(combo:isInProgress()))
    print("progress=" .. combo:progress())
    print("total=" .. combo:totalSteps())
    combo:reset()
end

--@api-stub: LCombo:totalSteps
-- Combo state queries. Focus: totalSteps.
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
-- Custom cursor lifecycle and type introspection. Focus: getType.
do
    local sys_cursor = lurek.input.mouse.getSystemCursor("arrow")
    print("cursor type=" .. sys_cursor:type())
    print("cursor kind=" .. sys_cursor:getType())
    print("typeOf=" .. tostring(sys_cursor:typeOf("LCursor")))
    sys_cursor:release()
end

--@api-stub: LCursor:release
-- Custom cursor lifecycle and type introspection. Focus: release.
do
    local sys_cursor = lurek.input.mouse.getSystemCursor("arrow")
    print("cursor type=" .. sys_cursor:type())
    print("cursor kind=" .. sys_cursor:getType())
    print("typeOf=" .. tostring(sys_cursor:typeOf("LCursor")))
    sys_cursor:release()
end

--@api-stub: LCursor:type
-- Custom cursor lifecycle and type introspection. Focus: type.
do
    local sys_cursor = lurek.input.mouse.getSystemCursor("arrow")
    print("cursor type=" .. sys_cursor:type())
    print("cursor kind=" .. sys_cursor:getType())
    print("typeOf=" .. tostring(sys_cursor:typeOf("LCursor")))
    sys_cursor:release()
end

--@api-stub: LCursor:typeOf
-- Custom cursor lifecycle and type introspection. Focus: typeOf.
do
    local sys_cursor = lurek.input.mouse.getSystemCursor("arrow")
    print("cursor type=" .. sys_cursor:type())
    print("cursor kind=" .. sys_cursor:getType())
    print("typeOf=" .. tostring(sys_cursor:typeOf("LCursor")))
    sys_cursor:release()
end

--@api-stub: LInputRecording:frameCount
-- Input recording lifecycle and state queries. Focus: frameCount.
do
    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    print("frames=" .. rec:frameCount())
    print("total=" .. rec:totalFrames())
    print("type=" .. rec:type())
    print("typeOf=" .. tostring(rec:typeOf("LInputRecording")))
end

--@api-stub: LInputRecording:totalFrames
-- Input recording lifecycle and state queries. Focus: totalFrames.
do
    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    print("frames=" .. rec:frameCount())
    print("total=" .. rec:totalFrames())
    print("type=" .. rec:type())
    print("typeOf=" .. tostring(rec:typeOf("LInputRecording")))
end

--@api-stub: LInputRecording:type
-- Input recording lifecycle and state queries. Focus: type.
do
    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    print("frames=" .. rec:frameCount())
    print("total=" .. rec:totalFrames())
    print("type=" .. rec:type())
    print("typeOf=" .. tostring(rec:typeOf("LInputRecording")))
end

--@api-stub: LInputRecording:typeOf
-- Input recording lifecycle and state queries. Focus: typeOf.
do
    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    print("frames=" .. rec:frameCount())
    print("total=" .. rec:totalFrames())
    print("type=" .. rec:type())
    print("typeOf=" .. tostring(rec:typeOf("LInputRecording")))
end

--@api-stub: lurek.input.isPlayingBack
-- Input recording/playback module functions. Focus: isPlayingBack.
do
    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    print("is_playing=" .. tostring(lurek.input.isPlayingBack()))
    lurek.input.startPlayback()
    lurek.input.stopPlayback()
    print("stopped")
end

--@api-stub: lurek.input.stopPlayback
-- Input recording/playback module functions. Focus: stopPlayback.
do
    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    print("is_playing=" .. tostring(lurek.input.isPlayingBack()))
    lurek.input.startPlayback()
    lurek.input.stopPlayback()
    print("stopped")
end

--@api-stub: lurek.input.stopRecording
-- Input recording/playback module functions. Focus: stopRecording.
do
    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    print("is_playing=" .. tostring(lurek.input.isPlayingBack()))
    lurek.input.startPlayback()
    lurek.input.stopPlayback()
    print("stopped")
end

print("content/examples/input.lua")
