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

--@api-stub: lurek.input.mouse.getX / getY
-- Returns individual mouse coordinates.
do
    local x = lurek.input.mouse.getX()
    local y = lurek.input.mouse.getY()
    print("mouse x=" .. x .. " y=" .. y)
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

--@api-stub: lurek.input.mouse.setCursor
-- Sets an active cursor handle.
do
    local cursor = lurek.input.mouse.getSystemCursor("arrow")
    lurek.input.mouse.setCursor(cursor)
    print("cursor set to arrow")
end

--@api-stub: lurek.input.mouse.getSystemCursor
-- Returns a system cursor by name.
do
    local arrow = lurek.input.mouse.getSystemCursor("arrow")
    print("got system cursor")
    _ = arrow
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

--@api-stub: lurek.input.gamepad.wasPressed / wasReleased
-- Checks if button was pressed or released this frame.
do
    local pressed = lurek.input.gamepad.wasPressed(1, 1)
    local released = lurek.input.gamepad.wasReleased(1, 1)
    print("pressed=" .. tostring(pressed) .. " released=" .. tostring(released))
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

--@api-stub: lurek.input.gamepad.wasConnected / wasDisconnected
-- Detects connection changes this frame.
do
    local c = lurek.input.gamepad.wasConnected(1)
    local d = lurek.input.gamepad.wasDisconnected(1)
    print("connected=" .. tostring(c) .. " disconnected=" .. tostring(d))
end

--@api-stub: lurek.input.gamepad.loadGamepadMappings / saveGamepadMappings
-- Loads and saves SDL gamepad mappings.
do
    lurek.input.gamepad.loadGamepadMappings("assets/gamecontrollerdb.txt")
    lurek.input.gamepad.saveGamepadMappings("save/mappings_out.txt")
    print("mappings loaded and saved")
end

--@api-stub: lurek.input.gamepad.getBackgroundEvents / setBackgroundEvents
-- Controls background event processing.
do
    local was = lurek.input.gamepad.getBackgroundEvents()
    lurek.input.gamepad.setBackgroundEvents(true)
    print("bg events was=" .. tostring(was) .. " now=true")
end

--@api-stub: lurek.input.gamepad.getJoystickCount / getJoysticks
-- Enumerates joysticks.
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

--@api-stub: lurek.input.touch.wasPressed / wasReleased
-- Detects touch begin/end this frame.
do
    local pressed = lurek.input.touch.wasPressed(1)
    local released = lurek.input.touch.wasReleased(1)
    print("t1 pressed=" .. tostring(pressed) .. " released=" .. tostring(released))
end

print("input_00.lua")
