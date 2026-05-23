-- content/examples/input.lua
-- Auto-generated from content/examples2/input_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/input.lua

--- Input Module Part 1: keyboard, mouse, gamepad, touch functions


--@api-stub: lurek.input.keyboard.isDown
do
    local down = lurek.input.keyboard.isDown("space", "w", "up")
    print("any key down = " .. tostring(down))
end

--@api-stub: lurek.input.keyboard.isScancodeDown
do
    local down = lurek.input.keyboard.isScancodeDown("a")
    print("scancode a down = " .. tostring(down))
end

--@api-stub: lurek.input.keyboard.isModifierActive
do
    local shift = lurek.input.keyboard.isModifierActive("shift")
    local ctrl = lurek.input.keyboard.isModifierActive("ctrl")
    print("shift=" .. tostring(shift) .. " ctrl=" .. tostring(ctrl))
end

--@api-stub: lurek.input.keyboard.getKeyFromScancode
do
    local key = lurek.input.keyboard.getKeyFromScancode("a")
    print("scancode 'a' → key '" .. key .. "'")
end

--@api-stub: lurek.input.keyboard.getScancodeFromKey
do
    local sc = lurek.input.keyboard.getScancodeFromKey("space")
    print("key 'space' → scancode '" .. sc .. "'")
end

--@api-stub: lurek.input.keyboard.hasKeyRepeat
do
    print("key repeat = " .. tostring(lurek.input.keyboard.hasKeyRepeat()))
end

--@api-stub: lurek.input.keyboard.setKeyRepeat
do
    lurek.input.keyboard.setKeyRepeat(true)
    print("key repeat enabled")
end

--@api-stub: lurek.input.keyboard.hasTextInput
do
    print("text input = " .. tostring(lurek.input.keyboard.hasTextInput()))
end

--@api-stub: lurek.input.keyboard.setTextInput
do
    lurek.input.keyboard.setTextInput(true)
    print("text input enabled")
end

--@api-stub: lurek.input.mouse.getPosition
do
    local x, y = lurek.input.mouse.getPosition()
    print("mouse at " .. x .. "," .. y)
end

--@api-stub: lurek.input.mouse.getX
do
    local x = lurek.input.mouse.getX()
    print("mouse x=" .. x)
end

--@api-stub: lurek.input.mouse.getY
do
    local y = lurek.input.mouse.getY()
    print("mouse y=" .. y)
end

--@api-stub: lurek.input.mouse.isDown
do
    local left = lurek.input.mouse.isDown(1)
    local right = lurek.input.mouse.isDown(2)
    print("left=" .. tostring(left) .. " right=" .. tostring(right))
end

--@api-stub: lurek.input.mouse.getWheelDelta
do
    local delta = lurek.input.mouse.getWheelDelta()
    print("wheel delta = " .. delta)
end

--@api-stub: lurek.input.mouse.setPosition
do
    lurek.input.mouse.setPosition(400, 300)
    print("mouse warped to 400,300")
end

--@api-stub: lurek.input.mouse.isVisible
do
    print("cursor visible = " .. tostring(lurek.input.mouse.isVisible()))
end

--@api-stub: lurek.input.mouse.setVisible
do
    lurek.input.mouse.setVisible(true)
    print("cursor shown")
end

--@api-stub: lurek.input.mouse.isGrabbed
do
    print("grabbed = " .. tostring(lurek.input.mouse.isGrabbed()))
end

--@api-stub: lurek.input.mouse.setGrabbed
do
    lurek.input.mouse.setGrabbed(false)
    print("mouse released")
end

--@api-stub: lurek.input.mouse.getRelativeMode
do
    print("relative mode = " .. tostring(lurek.input.mouse.getRelativeMode()))
end

--@api-stub: lurek.input.mouse.setRelativeMode
do
    lurek.input.mouse.setRelativeMode(false)
    print("relative mode off")
end

--@api-stub: lurek.input.mouse.isCursorSupported
do
    print("cursor supported = " .. tostring(lurek.input.mouse.isCursorSupported()))
end

--@api-stub: lurek.input.mouse.getCursor
do
    local name = lurek.input.mouse.getCursor()
    print("cursor name = " .. name)
end

--@api-stub: lurek.input.mouse.getSystemCursor
do
    local cursor = lurek.input.mouse.getSystemCursor("arrow")
    print("got system cursor = " .. tostring(cursor ~= nil))
end

--@api-stub: lurek.input.mouse.setCursor
do
    local cursor = lurek.input.mouse.getSystemCursor("arrow")
    lurek.input.mouse.setCursor(cursor)
    print("cursor set to arrow")
end

--@api-stub: lurek.input.mouse.newCursor
do
    local pixels = {}
    for i = 1, 16 * 16 * 4 do pixels[i] = 255 end
    local cursor = lurek.input.mouse.newCursor(pixels, 16, 16, 0, 0)
    print("custom cursor type = " .. cursor:getType())
end

--@api-stub: lurek.input.gamepad.getCount
do
    local count = lurek.input.gamepad.getCount()
    print("gamepad slots = " .. count)
end

--@api-stub: lurek.input.gamepad.isConnected
do
    local connected = lurek.input.gamepad.isConnected(1)
    print("gamepad 1 connected = " .. tostring(connected))
end

--@api-stub: lurek.input.gamepad.isGamepad
do
    local is_gp = lurek.input.gamepad.isGamepad(1)
    print("is gamepad = " .. tostring(is_gp))
end

--@api-stub: lurek.input.gamepad.getName
do
    local name = lurek.input.gamepad.getName(1)
    print("gamepad name = " .. name)
end

--@api-stub: lurek.input.gamepad.getGUID
do
    local guid = lurek.input.gamepad.getGUID(1)
    print("guid = " .. guid)
end

--@api-stub: lurek.input.gamepad.getAxis
do
    local val = lurek.input.gamepad.getAxis(1, 1)
    print("axis 1 = " .. val)
end

--@api-stub: lurek.input.gamepad.getAxisCount
do
    local count = lurek.input.gamepad.getAxisCount(1)
    print("axes = " .. count)
end

--@api-stub: lurek.input.gamepad.getButtonCount
do
    local count = lurek.input.gamepad.getButtonCount(1)
    print("buttons = " .. count)
end

--@api-stub: lurek.input.gamepad.isDown
do
    local pressed = lurek.input.gamepad.isDown(1, 1)
    print("button 1 = " .. tostring(pressed))
end

--@api-stub: lurek.input.gamepad.wasPressed
do
    local pressed = lurek.input.gamepad.wasPressed(1, 1)
    print("pressed=" .. tostring(pressed))
end

--@api-stub: lurek.input.gamepad.wasReleased
do
    local released = lurek.input.gamepad.wasReleased(1, 1)
    print("released=" .. tostring(released))
end

--@api-stub: lurek.input.gamepad.getHat
do
    local hat = lurek.input.gamepad.getHat(1, 1)
    print("hat 1 = " .. hat)
end

--@api-stub: lurek.input.gamepad.vibrate
do
    local ok = lurek.input.gamepad.vibrate(1, 0.5, 0.5, 200)
    print("vibrate ok = " .. tostring(ok))
end

--@api-stub: lurek.input.gamepad.isVibrationSupported
do
    local sup = lurek.input.gamepad.isVibrationSupported(1)
    print("vibration supported = " .. tostring(sup))
end

--@api-stub: lurek.input.gamepad.virtualDpad
do
    local dpad = lurek.input.gamepad.virtualDpad(0.8, 0.0, 0.3)
    print("direction = " .. dpad.direction)
    print("right = " .. tostring(dpad.right))
end

--@api-stub: lurek.input.gamepad.wasConnected
do
    local c = lurek.input.gamepad.wasConnected(1)
    print("connected=" .. tostring(c))
end

--@api-stub: lurek.input.gamepad.wasDisconnected
do
    local d = lurek.input.gamepad.wasDisconnected(1)
    print("disconnected=" .. tostring(d))
end

--@api-stub: lurek.input.gamepad.loadGamepadMappings
do
    local mappingPath = "save/gamecontrollerdb.txt"
    lurek.filesystem.write(mappingPath, "030000005e0400008e02000014010000,XInput,a:b0\n")
    lurek.input.gamepad.loadGamepadMappings(mappingPath)
    lurek.input.gamepad.saveGamepadMappings("save/mappings_out.txt")
    print("mappings loaded and saved")
end

--@api-stub: lurek.input.gamepad.saveGamepadMappings
do
    local mappingPath = "save/gamecontrollerdb.txt"
    lurek.filesystem.write(mappingPath, "030000005e0400008e02000014010000,XInput,a:b0\n")
    lurek.input.gamepad.loadGamepadMappings(mappingPath)
    lurek.input.gamepad.saveGamepadMappings("save/mappings_out.txt")
    print("mappings loaded and saved")
end

--@api-stub: lurek.input.gamepad.getBackgroundEvents
do
    local was = lurek.input.gamepad.getBackgroundEvents()
    lurek.input.gamepad.setBackgroundEvents(true)
    print("bg events was=" .. tostring(was) .. " now=true")
end

--@api-stub: lurek.input.gamepad.setBackgroundEvents
do
    local was = lurek.input.gamepad.getBackgroundEvents()
    lurek.input.gamepad.setBackgroundEvents(true)
    print("bg events was=" .. tostring(was) .. " now=true")
end

--@api-stub: lurek.input.gamepad.getJoystickCount
do
    local count = lurek.input.gamepad.getJoystickCount()
    local sticks = lurek.input.gamepad.getJoysticks()
    print("joystick count = " .. count .. ", list = " .. #sticks)
end

--@api-stub: lurek.input.gamepad.getJoysticks
do
    local count = lurek.input.gamepad.getJoystickCount()
    local sticks = lurek.input.gamepad.getJoysticks()
    print("joystick count = " .. count .. ", list = " .. #sticks)
end

--@api-stub: lurek.input.touch.getTouchCount
do
    local count = lurek.input.touch.getTouchCount()
    print("touches = " .. count)
end

--@api-stub: lurek.input.touch.getTouches
do
    local touches = lurek.input.touch.getTouches()
    print("touch ids = " .. #touches)
end

--@api-stub: lurek.input.touch.getPosition
do
    local x, y = lurek.input.touch.getPosition(1)
    print("touch 1 at " .. x .. "," .. y)
end

--@api-stub: lurek.input.touch.getPressure
do
    local p = lurek.input.touch.getPressure(1)
    print("pressure = " .. p)
end

--@api-stub: lurek.input.touch.wasPressed
do
    local pressed = lurek.input.touch.wasPressed(1)
    local released = lurek.input.touch.wasReleased(1)
    print("t1 pressed=" .. tostring(pressed) .. " released=" .. tostring(released))
end

--@api-stub: lurek.input.touch.wasReleased
do
    local pressed = lurek.input.touch.wasPressed(1)
    local released = lurek.input.touch.wasReleased(1)
    print("t1 pressed=" .. tostring(pressed) .. " released=" .. tostring(released))
end

--- Input Module Part 2: action bindings, combos, recording/playback


--@api-stub: lurek.input.bind
do
    lurek.input.bind("jump", "space")
    lurek.input.bind("move_left", {"a", "left"})
    print("actions bound")
end

--@api-stub: lurek.input.unbind
do
    lurek.input.bind("temp", "t")
    local had = lurek.input.unbind("temp")
    print("unbind had bindings = " .. tostring(had))
end

--@api-stub: lurek.input.clearBindings
do
    lurek.input.bind("a1", "q")
    lurek.input.bind("a2", "e")
    lurek.input.clearBindings()
    print("all bindings cleared")
end

--@api-stub: lurek.input.getBindings
do
    lurek.input.bind("shoot", "x")
    local bindings = lurek.input.getBindings()
    print("bindings count = " .. #bindings)
end

--@api-stub: lurek.input.isActionDown
do
    lurek.input.bind("fire", "space")
    local down = lurek.input.isActionDown("fire")
    print("fire down = " .. tostring(down))
end

--@api-stub: lurek.input.wasActionPressed
do
    lurek.input.bind("jump", "space")
    local pressed = lurek.input.wasActionPressed("jump")
    print("jump pressed = " .. tostring(pressed))
end

--@api-stub: lurek.input.wasActionPressedWithin
do
    lurek.input.bind("dodge", "shift")
    local recent = lurek.input.wasActionPressedWithin("dodge", 10)
    print("dodge recent = " .. tostring(recent))
end

--@api-stub: lurek.input.wasActionReleased
do
    lurek.input.bind("run", "shift")
    local released = lurek.input.wasActionReleased("run")
    print("run released = " .. tostring(released))
end

--@api-stub: lurek.input.isDown
do
    print("isDown available = " .. tostring(type(lurek.input.isDown) == "function"))
end

--@api-stub: lurek.input.wasPressed
do
    print("wasPressed available = " .. tostring(type(lurek.input.wasPressed) == "function"))
end

--@api-stub: lurek.input.wasReleased
do
    print("wasReleased available = " .. tostring(type(lurek.input.wasReleased) == "function"))
end

--@api-stub: lurek.input.newMapping
do
    local mapping = lurek.input.newMapping("attack", {"z", "button1"})
    local held = mapping.isDown()
    local just = mapping.wasPressed()
    local done = mapping.wasReleased()
    print("held=" .. tostring(held) .. " just=" .. tostring(just) .. " done=" .. tostring(done))
end

--@api-stub: lurek.input.newCombo
do
    local combo = lurek.input.newCombo({"down", "right", "z"}, {total_gap = 500})
    print("combo steps = " .. combo:totalSteps())
    print("in progress = " .. tostring(combo:isInProgress()))
    print("progress = " .. combo:progress())
end

--@api-stub: LCombo:feed
do
    local combo = lurek.input.newCombo({"a", "b", "c"})
    local result = combo:feed("a")
    print("feed a → " .. result)
end

--@api-stub: LCombo:tick
do
    local combo = lurek.input.newCombo({"x", "y"}, {total_gap = 300})
    local result = combo:tick(0.016)
    print("tick → " .. result)
end

--@api-stub: LCombo:getStep
do
    local combo = lurek.input.newCombo({"a", "b"})
    local step = combo:getStep(1)
    print("step 1 key = " .. step.key .. " gap = " .. step.gap_ms)
end

--@api-stub: LCombo:reset
do
    local combo = lurek.input.newCombo({"q", "w", "e"})
    combo:feed("q")
    combo:reset()
    print("progress after reset = " .. combo:progress())
end

--@api-stub: LCombo:type
do
    local combo = lurek.input.newCombo({"a"})
    print("type = " .. combo:type())
    print("is Combo = " .. tostring(combo:typeOf("LCombo")))
end

--@api-stub: LCombo:typeOf
do
    local combo = lurek.input.newCombo({"a"})
    print("type = " .. combo:type())
    print("is Combo = " .. tostring(combo:typeOf("LCombo")))
end

--@api-stub: lurek.input.startRecording
do
    lurek.input.startRecording()
    local recording = lurek.input.stopRecording()
    print("captured = " .. tostring(recording ~= nil))
end

--@api-stub: LInputRecording:toJson
do
    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    local json = rec and rec:toJson() or ""
    print("json length = " .. #json)
end

--@api-stub: lurek.input.loadRecording
do
    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    if rec then lurek.input.loadRecording(rec:toJson()) end
    print("recording loaded = " .. tostring(rec ~= nil))
end

--@api-stub: lurek.input.startPlayback
do
    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    if rec then lurek.input.loadRecording(rec:toJson()); lurek.input.startPlayback() end
    print("playing = " .. tostring(lurek.input.isPlayingBack()))
    lurek.input.stopPlayback()
end

--@api-stub: lurek.input.advancePlayback
do
    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    if rec then lurek.input.loadRecording(rec:toJson()); lurek.input.startPlayback() end
    local events = lurek.input.advancePlayback()
    print("events = " .. #events)
    lurek.input.stopPlayback()
end

--@api-stub: lurek.input.getPlaybackFrame
do
    local frame = lurek.input.getPlaybackFrame()
    print("playback frame = " .. frame)
end

--@api-stub: lurek.input.isRecording
do
    print("recording = " .. tostring(lurek.input.isRecording()))
    print("playing = " .. tostring(lurek.input.isPlayingBack()))
end

--@api-stub: lurek.input.gamepad.getGamepadMappingString
do
    local guid = "030000005e0400008e02000014010000"
    lurek.input.gamepad.setGamepadMapping(guid, guid .. ",XInput,a:b0")
    local mapping = lurek.input.gamepad.getGamepadMappingString(guid)
    print("mapping = " .. tostring(mapping))
end

--@api-stub: lurek.input.gamepad.setGamepadMapping
do
    local guid = lurek.input.gamepad.getGUID(1)
    lurek.input.gamepad.setGamepadMapping(guid, "custom_mapping_string")
    print("custom mapping set")
end

--@api-stub: lurek.input.gamepad.setVibration
do
    lurek.input.gamepad.setVibration(1, 0.3, 0.7, 100)
    print("vibration set")
end

--- Input Module Part 2: combo system, cursor, recording/playback, extra gamepad/touch/mouse


--@api-stub: LCombo:isInProgress
do
    local combo = lurek.input.newCombo({ "a", "b", "c" })
    combo:feed("a")
    combo:tick(0.016)
    print("in_progress=" .. tostring(combo:isInProgress()))
end

--@api-stub: LCombo:progress
do
    local combo = lurek.input.newCombo({ "a", "b", "c" })
    combo:feed("a")
    combo:tick(0.016)
    print("in_progress=" .. tostring(combo:isInProgress()))
    print("progress=" .. combo:progress())
end

--@api-stub: LCombo:totalSteps
do
    local combo = lurek.input.newCombo({ "a", "b", "c" })
    combo:feed("a")
    combo:tick(0.016)
    print("total=" .. combo:totalSteps())
end

--@api-stub: LCursor:getType
do
    local sys_cursor = lurek.input.mouse.getSystemCursor("arrow")
    print("cursor type=" .. sys_cursor:type())
    print("cursor kind=" .. sys_cursor:getType())
    print("typeOf=" .. tostring(sys_cursor:typeOf("LCursor")))
    sys_cursor:release()
end

--@api-stub: LCursor:release
do
    local sys_cursor = lurek.input.mouse.getSystemCursor("arrow")
    print("cursor type=" .. sys_cursor:type())
    print("cursor kind=" .. sys_cursor:getType())
    print("typeOf=" .. tostring(sys_cursor:typeOf("LCursor")))
    sys_cursor:release()
end

--@api-stub: LCursor:type
do
    local sys_cursor = lurek.input.mouse.getSystemCursor("arrow")
    print("cursor type=" .. sys_cursor:type())
    print("cursor kind=" .. sys_cursor:getType())
    print("typeOf=" .. tostring(sys_cursor:typeOf("LCursor")))
    sys_cursor:release()
end

--@api-stub: LCursor:typeOf
do
    local sys_cursor = lurek.input.mouse.getSystemCursor("arrow")
    print("cursor type=" .. sys_cursor:type())
    print("cursor kind=" .. sys_cursor:getType())
    print("typeOf=" .. tostring(sys_cursor:typeOf("LCursor")))
    sys_cursor:release()
end

--@api-stub: LInputRecording:frameCount
do
    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    print("frames=" .. tostring(rec and rec:frameCount() or 0))
end

--@api-stub: LInputRecording:totalFrames
do
    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    print("total=" .. tostring(rec and rec:totalFrames() or 0))
end

--@api-stub: LInputRecording:type
do
    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    print("type=" .. tostring(rec and rec:type() or nil))
end

--@api-stub: LInputRecording:typeOf
do
    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    print("typeOf=" .. tostring(rec and rec:typeOf("LInputRecording") or false))
end

--@api-stub: lurek.input.isPlayingBack
do
    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    if rec then lurek.input.loadRecording(rec:toJson()); lurek.input.startPlayback() end
    print("is_playing=" .. tostring(lurek.input.isPlayingBack()))
    lurek.input.stopPlayback()
end

--@api-stub: lurek.input.stopPlayback
do
    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    if rec then lurek.input.loadRecording(rec:toJson()); lurek.input.startPlayback() end
    lurek.input.stopPlayback()
    print("is_playing=" .. tostring(lurek.input.isPlayingBack()))
end

--@api-stub: lurek.input.stopRecording
do
    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    print("frames=" .. tostring(rec and rec:frameCount() or 0))
end

print("content/examples/input.lua")
