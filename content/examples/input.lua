-- content/examples/input.lua
-- Auto-generated from content/examples2/input_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/input.lua

--- Input Module Part 1: keyboard, mouse, gamepad, touch functions

--@api: lurek.input.keyboard.isDown
do
    local down = lurek.input.keyboard.isDown("space", "w", "up")
    print("any key down = " .. tostring(down))
    print("lua type = " .. type(down))
end

--@api: lurek.input.keyboard.isScancodeDown
do
    local down = lurek.input.keyboard.isScancodeDown("a")
    print("scancode a down = " .. tostring(down))
    print("lua type = " .. type(down))
end

--@api: lurek.input.keyboard.isModifierActive
do
    local shift = lurek.input.keyboard.isModifierActive("shift")
    local ctrl = lurek.input.keyboard.isModifierActive("ctrl")
    print("shift=" .. tostring(shift) .. " ctrl=" .. tostring(ctrl))
end

--@api: lurek.input.keyboard.getKeyFromScancode
do
    local key = lurek.input.keyboard.getKeyFromScancode("a")
    print("scancode 'a' → key '" .. key .. "'")
    print("lua type = " .. type(key))
end

--@api: lurek.input.keyboard.getScancodeFromKey
do
    local sc = lurek.input.keyboard.getScancodeFromKey("space")
    print("key 'space' → scancode '" .. sc .. "'")
    print("lua type = " .. type(sc))
end

--@api: lurek.input.keyboard.hasKeyRepeat
do
    local v = lurek.input.keyboard.hasKeyRepeat()
    print("key repeat = " .. tostring(v))
    print("lua type = " .. type(v))
end

--@api: lurek.input.keyboard.setKeyRepeat
do
    lurek.input.keyboard.setKeyRepeat(true)
    print("key repeat enabled")
    print("key repeat = " .. tostring(lurek.input.keyboard.hasKeyRepeat()))
end

--@api: lurek.input.keyboard.hasTextInput
do
    local v = lurek.input.keyboard.hasTextInput()
    print("text input = " .. tostring(v))
    print("lua type = " .. type(v))
end

--@api: lurek.input.keyboard.setTextInput
do
    lurek.input.keyboard.setTextInput(true)
    print("text input enabled")
    print("text input = " .. tostring(lurek.input.keyboard.hasTextInput()))
end

--@api: lurek.input.mouse.getPosition
do
    local x, y = lurek.input.mouse.getPosition()
    print("mouse at " .. x .. "," .. y)
    print("value types = " .. type(x) .. "," .. type(y))
end

--@api: lurek.input.mouse.getX
do
    local x = lurek.input.mouse.getX()
    print("mouse x=" .. x)
    print("lua type = " .. type(x))
end

--@api: lurek.input.mouse.getY
do
    local y = lurek.input.mouse.getY()
    print("mouse y=" .. y)
    print("lua type = " .. type(y))
end

--@api: lurek.input.mouse.isDown
do
    local left = lurek.input.mouse.isDown(1)
    local right = lurek.input.mouse.isDown(2)
    print("left=" .. tostring(left) .. " right=" .. tostring(right))
end

--@api: lurek.input.mouse.getWheelDelta
do
    local dx, dy = lurek.input.mouse.getWheelDelta()
    print("wheel dx = " .. dx)
    print("wheel dy = " .. dy)
end

--@api: lurek.input.mouse.setPosition
do
    lurek.input.mouse.setPosition(400, 300)
    print("mouse warped to 400,300")
    print("mouse x after set = " .. tostring(lurek.input.mouse.getX()))
end

--@api: lurek.input.mouse.isVisible
do
    local v = lurek.input.mouse.isVisible()
    print("cursor visible = " .. tostring(v))
    print("lua type = " .. type(v))
end

--@api: lurek.input.mouse.setVisible
do
    lurek.input.mouse.setVisible(true)
    print("cursor shown")
    print("mouse visible = " .. tostring(lurek.input.mouse.isVisible()))
end

--@api: lurek.input.mouse.isGrabbed
do
    local v = lurek.input.mouse.isGrabbed()
    print("grabbed = " .. tostring(v))
    print("lua type = " .. type(v))
end

--@api: lurek.input.mouse.setGrabbed
do
    lurek.input.mouse.setGrabbed(false)
    print("mouse released")
    print("mouse grabbed = " .. tostring(lurek.input.mouse.isGrabbed()))
end

--@api: lurek.input.mouse.getRelativeMode
do
    local v = lurek.input.mouse.getRelativeMode()
    print("relative mode = " .. tostring(v))
    print("lua type = " .. type(v))
end

--@api: lurek.input.mouse.setRelativeMode
do
    lurek.input.mouse.setRelativeMode(false)
    print("relative mode off")
    print("relative mode = " .. tostring(lurek.input.mouse.getRelativeMode()))
end

--@api: lurek.input.mouse.isCursorSupported
do
    local v = lurek.input.mouse.isCursorSupported()
    print("cursor supported = " .. tostring(v))
    print("lua type = " .. type(v))
end

--@api: lurek.input.mouse.getCursor
do
    local name = lurek.input.mouse.getCursor()
    print("cursor name = " .. name)
    print("lua type = " .. type(name))
end

--@api: lurek.input.mouse.getSystemCursor
do
    local cursor = lurek.input.mouse.getSystemCursor("arrow")
    print("got system cursor = " .. tostring(cursor ~= nil))
    print("lua type = " .. type(cursor))
end

--@api: lurek.input.mouse.setCursor
do
    local cursor = lurek.input.mouse.getSystemCursor("arrow")
    lurek.input.mouse.setCursor(cursor)
    print("cursor set to arrow")
end

--@api: lurek.input.mouse.newCursor
do
    local pixels = {}
    for i = 1, 16 * 16 * 4 do
        pixels[i] = 255
    end
    local cursor = lurek.input.mouse.newCursor(pixels, 16, 16, 0, 0)
    print("custom cursor type = " .. cursor:getType())
end

--@api: lurek.input.gamepad.getCount
do
    local count = lurek.input.gamepad.getCount()
    print("gamepad slots = " .. count)
    print("lua type = " .. type(count))
end

--@api: lurek.input.gamepad.isConnected
do
    local connected = lurek.input.gamepad.isConnected(0)
    print("gamepad 0 connected = " .. tostring(connected))
    print("lua type = " .. type(connected))
end

--@api: lurek.input.gamepad.isGamepad
do
    local is_gp = lurek.input.gamepad.isGamepad(0)
    print("is gamepad = " .. tostring(is_gp))
    print("lua type = " .. type(is_gp))
end

--@api: lurek.input.gamepad.getName
do
    local name = lurek.input.gamepad.getName(0)
    print("gamepad name = " .. name)
    print("lua type = " .. type(name))
end

--@api: lurek.input.gamepad.getGUID
do
    local guid = lurek.input.gamepad.getGUID(0)
    print("guid = " .. guid)
    print("lua type = " .. type(guid))
end

--@api: lurek.input.gamepad.getAxis
do
    local val = lurek.input.gamepad.getAxis(0, 0)
    print("axis 0 = " .. val)
    print("lua type = " .. type(val))
end

--@api: lurek.input.gamepad.getAxisCount
do
    local count = lurek.input.gamepad.getAxisCount(0)
    print("axes = " .. count)
    print("lua type = " .. type(count))
end

--@api: lurek.input.gamepad.getButtonCount
do
    local count = lurek.input.gamepad.getButtonCount(0)
    print("buttons = " .. count)
    print("lua type = " .. type(count))
end

--@api: lurek.input.gamepad.isDown
do
    local pressed = lurek.input.gamepad.isDown(0, 0)
    print("button 0 = " .. tostring(pressed))
    print("lua type = " .. type(pressed))
end

--@api: lurek.input.gamepad.wasPressed
do
    local pressed = lurek.input.gamepad.wasPressed(0, 0)
    print("pressed=" .. tostring(pressed))
    print("lua type = " .. type(pressed))
end

--@api: lurek.input.gamepad.wasReleased
do
    local released = lurek.input.gamepad.wasReleased(0, 0)
    print("released=" .. tostring(released))
    print("lua type = " .. type(released))
end

--@api: lurek.input.gamepad.getHat
do
    local hat = lurek.input.gamepad.getHat(0, 0)
    print("hat 0 = " .. hat)
    print("lua type = " .. type(hat))
end

--@api: lurek.input.gamepad.vibrate
do
    local ok = lurek.input.gamepad.vibrate(0, 0.5, 0.5, 200)
    print("vibrate ok = " .. tostring(ok))
    print("vibration needs a connected gamepad id, for example 0")
end

--@api: lurek.input.gamepad.isVibrationSupported
do
    local sup = lurek.input.gamepad.isVibrationSupported(0)
    print("vibration supported = " .. tostring(sup))
    print("lua type = " .. type(sup))
end

--@api: lurek.input.gamepad.virtualDpad
do
    local dpad = lurek.input.gamepad.virtualDpad(0.8, 0.0, 0.3)
    print("direction = " .. dpad.direction)
    print("right = " .. tostring(dpad.right))
end

--@api: lurek.input.gamepad.wasConnected
do
    local c = lurek.input.gamepad.wasConnected(0)
    print("connected=" .. tostring(c))
    print("lua type = " .. type(c))
end

--@api: lurek.input.gamepad.wasDisconnected
do
    local d = lurek.input.gamepad.wasDisconnected(0)
    print("disconnected=" .. tostring(d))
    print("lua type = " .. type(d))
end

--@api: lurek.input.gamepad.loadGamepadMappings
do
    local mappingPath = "save/gamecontrollerdb.txt"
    lurek.filesystem.write(mappingPath, "030000005e0400008e02000014010000,XInput,a:b0\n")
    lurek.input.gamepad.loadGamepadMappings(mappingPath)
    lurek.input.gamepad.saveGamepadMappings("save/mappings_out.txt")
    print("mappings loaded and saved")
end

--@api: lurek.input.gamepad.saveGamepadMappings
do
    local mappingPath = "save/gamecontrollerdb.txt"
    lurek.filesystem.write(mappingPath, "030000005e0400008e02000014010000,XInput,a:b0\n")
    lurek.input.gamepad.loadGamepadMappings(mappingPath)
    lurek.input.gamepad.saveGamepadMappings("save/mappings_out.txt")
    print("mappings loaded and saved")
end

--@api: lurek.input.gamepad.getBackgroundEvents
do
    local was = lurek.input.gamepad.getBackgroundEvents()
    lurek.input.gamepad.setBackgroundEvents(true)
    print("bg events was=" .. tostring(was) .. " now=true")
end

--@api: lurek.input.gamepad.setBackgroundEvents
do
    local was = lurek.input.gamepad.getBackgroundEvents()
    lurek.input.gamepad.setBackgroundEvents(true)
    print("bg events was=" .. tostring(was) .. " now=true")
end

--@api: lurek.input.gamepad.getJoystickCount
do
    local count = lurek.input.gamepad.getJoystickCount()
    local sticks = lurek.input.gamepad.getJoysticks()
    print("joystick count = " .. count .. ", list = " .. #sticks)
end

--@api: lurek.input.gamepad.getJoysticks
do
    local count = lurek.input.gamepad.getJoystickCount()
    local sticks = lurek.input.gamepad.getJoysticks()
    print("joystick count = " .. count .. ", list = " .. #sticks)
end

--@api: lurek.input.touch.getTouchCount
do
    local count = lurek.input.touch.getTouchCount()
    print("touches = " .. count)
    print("lua type = " .. type(count))
end

--@api: lurek.input.touch.getTouches
do
    local touches = lurek.input.touch.getTouches()
    print("touch ids = " .. #touches)
    print("lua type = " .. type(touches))
end

--@api: lurek.input.touch.getPosition
do
    local touches = lurek.input.touch.getTouches()
    local id = touches[1] and touches[1].id or 1
    local x, y = lurek.input.touch.getPosition(id)
    print("touch id = " .. tostring(id))
    print("touch at " .. x .. "," .. y)
end

--@api: lurek.input.touch.getPressure
do
    local touches = lurek.input.touch.getTouches()
    local id = touches[1] and touches[1].id or 1
    local p = lurek.input.touch.getPressure(id)
    print("touch id = " .. tostring(id))
    print("pressure = " .. p)
end

--@api: lurek.input.touch.wasPressed
do
    local touches = lurek.input.touch.getTouches()
    local id = touches[1] and touches[1].id or 1
    local pressed = lurek.input.touch.wasPressed(id)
    local released = lurek.input.touch.wasReleased(id)
    print("touch id = " .. tostring(id))
    print("pressed=" .. tostring(pressed) .. " released=" .. tostring(released))
end

--@api: lurek.input.touch.wasReleased
do
    local touches = lurek.input.touch.getTouches()
    local id = touches[1] and touches[1].id or 1
    local pressed = lurek.input.touch.wasPressed(id)
    local released = lurek.input.touch.wasReleased(id)
    print("touch id = " .. tostring(id))
    print("pressed=" .. tostring(pressed) .. " released=" .. tostring(released))
end

--- Input Module Part 2: action bindings, combos, recording/playback

--@api: lurek.input.bind
do
    lurek.input.bind("jump", "space")
    lurek.input.bind("move_left", {"a", "left"})
    print("actions bound")
end

--@api: lurek.input.unbind
do
    lurek.input.bind("temp", "t")
    local had = lurek.input.unbind("temp")
    print("unbind had bindings = " .. tostring(had))
end

--@api: lurek.input.clearBindings
do
    lurek.input.bind("a1", "q")
    lurek.input.bind("a2", "e")
    lurek.input.clearBindings()
    print("all bindings cleared")
end

--@api: lurek.input.getBindings
do
    lurek.input.bind("shoot", "x")
    local bindings = lurek.input.getBindings()
    local shoot = rawget(bindings, "shoot") or {}
    print("has shoot = " .. tostring(rawget(bindings, "shoot") ~= nil))
    print("shoot bindings = " .. #shoot)
end

--@api: lurek.input.isActionDown
do
    lurek.input.bind("fire", "space")
    local down = lurek.input.isActionDown("fire")
    print("fire down = " .. tostring(down))
end

--@api: lurek.input.wasActionPressed
do
    lurek.input.bind("jump", "space")
    local pressed = lurek.input.wasActionPressed("jump")
    print("jump pressed = " .. tostring(pressed))
end

--@api: lurek.input.wasActionPressedWithin
do
    lurek.input.bind("dodge", "shift")
    local recent = lurek.input.wasActionPressedWithin("dodge", 10)
    print("dodge recent = " .. tostring(recent))
end

--@api: lurek.input.wasActionReleased
do
    lurek.input.bind("run", "shift")
    local released = lurek.input.wasActionReleased("run")
    print("run released = " .. tostring(released))
end

--@api: lurek.input.isDown
do
    -- isDown() returns true while any key is held; check inside an input event callback
    local v = lurek.input.keyboard.isDown("a")
    print("isDown available = " .. tostring(type(lurek.input.keyboard.isDown) == "function"))
    print("result type = " .. type(v))
end

--@api: lurek.input.wasPressed
do
    local has_was_pressed = type(lurek.input.wasPressed) == "function"
    local v = has_was_pressed and lurek.input.wasPressed() or false
    print("wasPressed available = " .. tostring(has_was_pressed))
    print("result type = " .. type(v))
end

--@api: lurek.input.wasReleased
do
    local has_was_released = type(lurek.input.wasReleased) == "function"
    local v = has_was_released and lurek.input.wasReleased() or false
    print("wasReleased available = " .. tostring(has_was_released))
    print("space released = " .. tostring(v))
end

--@api: lurek.input.newMapping
do
    local mapping = lurek.input.newMapping("attack", {"z", "button1"})
    local held = mapping.isDown()
    local just = mapping.wasPressed()
    local done = mapping.wasReleased()
    print("held=" .. tostring(held) .. " just=" .. tostring(just) .. " done=" .. tostring(done))
end

--@api: lurek.input.newCombo
do
    local combo = lurek.input.newCombo({"down", "right", "z"}, {total_gap = 500})
    print("combo steps = " .. combo:totalSteps())
    print("in progress = " .. tostring(combo:isInProgress()))
    print("progress = " .. combo:progress())
end

--@api: LCombo:feed
do
    local combo = lurek.input.newCombo({"a", "b", "c"})
    local result = combo:feed("a")
    print("feed a → " .. result)
end

--@api: LCombo:tick
do
    local combo = lurek.input.newCombo({"x", "y"}, {total_gap = 300})
    local result = combo:tick(0.016)
    print("tick → " .. result)
end

--@api: LCombo:getStep
do
    local combo = lurek.input.newCombo({"a", "b"})
    local step = combo:getStep(1)
    print("step 1 key = " .. step.key .. " gap = " .. step.gap_ms)
end

--@api: LCombo:reset
do
    local combo = lurek.input.newCombo({"q", "w", "e"})
    combo:feed("q")
    combo:reset()
    print("progress after reset = " .. combo:progress())
end

--@api: LCombo:type
do
    local combo = lurek.input.newCombo({"a"})
    print("type = " .. combo:type())
    print("is Combo = " .. tostring(combo:typeOf("LCombo")))
end

--@api: LCombo:typeOf
do
    local combo = lurek.input.newCombo({"a"})
    print("type = " .. combo:type())
    print("is Combo = " .. tostring(combo:typeOf("LCombo")))
end

--@api: lurek.input.startRecording
do
    lurek.input.startRecording()
    local recording = lurek.input.stopRecording()
    print("captured = " .. tostring(recording ~= nil))
end

--@api: LInputRecording:toJson
do
    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    local json = rec and rec:toJson() or ""
    print("json length = " .. #json)
end

--@api: lurek.input.loadRecording
do
    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    if rec then lurek.input.loadRecording(rec:toJson()) end
    print("recording loaded = " .. tostring(rec ~= nil))
end

--@api: lurek.input.startPlayback
do
    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    if rec then
        lurek.input.loadRecording(rec:toJson())
        lurek.input.startPlayback()
    end
    print("playing = " .. tostring(lurek.input.isPlayingBack()))
    lurek.input.stopPlayback()
end

--@api: lurek.input.advancePlayback
do
    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    if rec then
        lurek.input.loadRecording(rec:toJson())
        lurek.input.startPlayback()
    end
    local events = lurek.input.advancePlayback()
    print("events = " .. #events)
    lurek.input.stopPlayback()
end

--@api: lurek.input.getPlaybackFrame
do
    local frame = lurek.input.getPlaybackFrame()
    print("playback frame = " .. frame)
    print("lua type = " .. type(frame))
end

--@api: lurek.input.isRecording
do
    print("recording = " .. tostring(lurek.input.isRecording()))
    print("playing = " .. tostring(lurek.input.isPlayingBack()))
    print("lua type = " .. type(tostring(lurek.input.isPlayingBack())))
end

--@api: lurek.input.gamepad.getGamepadMappingString
do
    local guid = "030000005e0400008e02000014010000"
    lurek.input.gamepad.setGamepadMapping(guid, guid .. ",XInput,a:b0")
    local mapping = lurek.input.gamepad.getGamepadMappingString(guid)
    print("mapping = " .. tostring(mapping))
end

--@api: lurek.input.gamepad.setGamepadMapping
do
    local guid = lurek.input.gamepad.getGUID(1)
    lurek.input.gamepad.setGamepadMapping(guid, "custom_mapping_string")
    print("custom mapping set")
end

--@api: lurek.input.gamepad.setVibration
do
    lurek.input.gamepad.setVibration(1, 0.3, 0.7, 100)
    print("vibration set")
    print("setVibration needs a connected gamepad id, for example 0")
end

--- Input Module Part 2: combo system, cursor, recording/playback, extra gamepad/touch/mouse

--@api: LCombo:isInProgress
do
    local combo = lurek.input.newCombo({ "a", "b", "c" })
    combo:feed("a")
    combo:tick(0.016)
    print("in_progress=" .. tostring(combo:isInProgress()))
end

--@api: LCombo:progress
do
    local combo = lurek.input.newCombo({ "a", "b", "c" })
    combo:feed("a")
    combo:tick(0.016)
    print("in_progress=" .. tostring(combo:isInProgress()))
    print("progress=" .. combo:progress())
end

--@api: LCombo:totalSteps
do
    local combo = lurek.input.newCombo({ "a", "b", "c" })
    combo:feed("a")
    combo:tick(0.016)
    print("total=" .. combo:totalSteps())
end

--@api: LCursor:getType
do
    local sys_cursor = lurek.input.mouse.getSystemCursor("arrow")
    print("cursor type=" .. sys_cursor:type())
    print("cursor kind=" .. sys_cursor:getType())
    print("typeOf=" .. tostring(sys_cursor:typeOf("LCursor")))
    sys_cursor:release()
end

--@api: LCursor:release
do
    local sys_cursor = lurek.input.mouse.getSystemCursor("arrow")
    print("cursor type=" .. sys_cursor:type())
    print("cursor kind=" .. sys_cursor:getType())
    print("typeOf=" .. tostring(sys_cursor:typeOf("LCursor")))
    sys_cursor:release()
end

--@api: LCursor:type
do
    local sys_cursor = lurek.input.mouse.getSystemCursor("arrow")
    print("cursor type=" .. sys_cursor:type())
    print("cursor kind=" .. sys_cursor:getType())
    print("typeOf=" .. tostring(sys_cursor:typeOf("LCursor")))
    sys_cursor:release()
end

--@api: LCursor:typeOf
do
    local sys_cursor = lurek.input.mouse.getSystemCursor("arrow")
    print("cursor type=" .. sys_cursor:type())
    print("cursor kind=" .. sys_cursor:getType())
    print("typeOf=" .. tostring(sys_cursor:typeOf("LCursor")))
    sys_cursor:release()
end

--@api: LInputRecording:frameCount
do
    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    print("frames=" .. tostring(rec and rec:frameCount() or 0))
end

--@api: LInputRecording:totalFrames
do
    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    print("total=" .. tostring(rec and rec:totalFrames() or 0))
end

--@api: LInputRecording:type
do
    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    print("type=" .. tostring(rec and rec:type() or nil))
end

--@api: LInputRecording:typeOf
do
    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    print("typeOf=" .. tostring(rec and rec:typeOf("LInputRecording") or false))
end

--@api: lurek.input.isPlayingBack
do
    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    if rec then
        lurek.input.loadRecording(rec:toJson())
        lurek.input.startPlayback()
    end
    print("is_playing=" .. tostring(lurek.input.isPlayingBack()))
    lurek.input.stopPlayback()
end

--@api: lurek.input.stopPlayback
do
    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    if rec then lurek.input.loadRecording(rec:toJson()); lurek.input.startPlayback() end
    lurek.input.stopPlayback()
    print("is_playing=" .. tostring(lurek.input.isPlayingBack()))
end

--@api: lurek.input.stopRecording
do
    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    print("stopped recording=" .. tostring(rec ~= nil))
end

--@api: lurek.input.getTouchCount
do
    -- getTouchCount returns active touch points; 0 on desktop without a touchscreen
    local n = lurek.input.touch.getTouchCount()
    print("lurek.input.getTouchCount=" .. n)
    print("touch type = " .. type(n))
end

--- Input Module Part 3: extended action binding (NM-04)

--@api: lurek.input.define
do
    lurek.input.define("jump", {"space", "up"}, "movement")
    print("define ok")
    lurek.input.reset()
end

--@api: lurek.input.getAxis
do
    lurek.input.bind("move_x", {"d", "a"})
    local v = lurek.input.getAxis("move_x")
    print("getAxis=" .. tostring(v))
    lurek.input.reset()
end

--@api: lurek.input.getVector
do
    lurek.input.bind("haxis", {"d", "a"})
    lurek.input.bind("vaxis", {"s", "w"})
    local h, v = lurek.input.getVector("haxis", "vaxis")
    print("getVector=" .. tostring(h) .. "," .. tostring(v))
    lurek.input.reset()
end

--@api: lurek.input.reset
do
    lurek.input.bind("temp", "t")
    lurek.input.reset("temp")
    print("reset(name) ok")
    lurek.input.reset()
    print("reset() ok")
end

--@api: lurek.input.getConflicts
do
    lurek.input.bind("act_a", "x")
    lurek.input.bind("act_b", "x")
    local c = lurek.input.getConflicts()
    print("getConflicts type=" .. type(c))
    lurek.input.reset()
end

--@api: lurek.input.serializeBindings
do
    lurek.input.bind("test_ser", "s")
    local json = lurek.input.serializeBindings()
    print("serializeBindings len=" .. #json)
    lurek.input.reset()
end

--@api: lurek.input.deserializeBindings
do
    lurek.input.bind("test_deser", "q")
    local json = lurek.input.serializeBindings()
    lurek.input.reset()
    local ok = lurek.input.deserializeBindings(json)
    print("deserializeBindings=" .. tostring(ok))
    lurek.input.reset()
end

--@api: lurek.input.getByCategory
do
    lurek.input.define("run", "lshift", "movement")
    local cats = lurek.input.getByCategory("movement")
    print("getByCategory count=" .. #cats)
    lurek.input.reset()
end

--@api: lurek.input.onRebind
do
    lurek.input.onRebind(function(action, keys)
        print("rebind: " .. action .. " keys=" .. #keys)
    end)
    print("onRebind registered")
end
