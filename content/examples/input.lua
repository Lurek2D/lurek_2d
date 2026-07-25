-- content/examples/input.lua
-- Auto-generated from content/examples2/input_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/input.lua

--- Input Module Part 1: keyboard, mouse, gamepad, touch functions


--@api: lurek.input.keyboard.isDown
do

    local jumpHeld = lurek.input.keyboard.isDown("space")
    local climbHeld = lurek.input.keyboard.isDown("w", "up")
    local moveHeld = lurek.input.keyboard.isDown("a", "d", "left", "right")
    local hasInput = jumpHeld or climbHeld or moveHeld
    lurek.log.info("platformer input jump=" .. tostring(jumpHeld) .. " climb=" .. tostring(climbHeld))
    lurek.log.info("platformer movement held=" .. tostring(moveHeld) .. " active=" .. tostring(hasInput))
end

--@api: lurek.input.keyboard.isScancodeDown
do

    local leftPhysical = lurek.input.keyboard.isScancodeDown("a")
    local rightPhysical = lurek.input.keyboard.isScancodeDown("d")
    local jumpPhysical = lurek.input.keyboard.isScancodeDown("space")
    local moving = leftPhysical or rightPhysical
    lurek.log.info("physical layout left=" .. tostring(leftPhysical) .. " right=" .. tostring(rightPhysical))
    lurek.log.info("physical layout jump=" .. tostring(jumpPhysical) .. " moving=" .. tostring(moving))
end

--@api: lurek.input.keyboard.isModifierActive
do

    local shift = lurek.input.keyboard.isModifierActive("shift")
    local ctrl = lurek.input.keyboard.isModifierActive("ctrl")
    local alt = lurek.input.keyboard.isModifierActive("alt")
    local modifierCombo = shift or ctrl or alt
    lurek.log.info("editor modifiers shift=" .. tostring(shift) .. " ctrl=" .. tostring(ctrl) .. " alt=" .. tostring(alt))
    lurek.log.info("editor modifier combo active=" .. tostring(modifierCombo))
end

--@api: lurek.input.keyboard.getKeyFromScancode
do

    local key = lurek.input.keyboard.getKeyFromScancode("a")
    local jumpKey = lurek.input.keyboard.getKeyFromScancode("space")
    local confirmKey = lurek.input.keyboard.getKeyFromScancode("return")
    local mapped = { key, jumpKey, confirmKey }
    lurek.log.info("tutorial scancode a->" .. tostring(key) .. " space->" .. tostring(jumpKey))
    lurek.log.info("tutorial key count=" .. tostring(#mapped) .. " confirm=" .. tostring(confirmKey))
end

--@api: lurek.input.keyboard.getScancodeFromKey
do

    local sc = lurek.input.keyboard.getScancodeFromKey("space")
    local pauseSc = lurek.input.keyboard.getScancodeFromKey("escape")
    local confirmSc = lurek.input.keyboard.getScancodeFromKey("return")
    local scancodes = { sc, pauseSc, confirmSc }
    lurek.log.info("menu key space->" .. tostring(sc) .. " escape->" .. tostring(pauseSc))
    lurek.log.info("menu scancode count=" .. tostring(#scancodes) .. " confirm=" .. tostring(confirmSc))
end

--@api: lurek.input.keyboard.hasKeyRepeat
do

    local before = lurek.input.keyboard.hasKeyRepeat()
    lurek.input.keyboard.setKeyRepeat(true)
    local enabled = lurek.input.keyboard.hasKeyRepeat()
    lurek.input.keyboard.setKeyRepeat(before)
    lurek.log.info("chat repeat before=" .. tostring(before) .. " enabled=" .. tostring(enabled))
    lurek.log.info("chat repeat restored=" .. tostring(lurek.input.keyboard.hasKeyRepeat()))
end

--@api: lurek.input.keyboard.setKeyRepeat
do

    local before = lurek.input.keyboard.hasKeyRepeat()
    lurek.input.keyboard.setKeyRepeat(true)
    local enabled = lurek.input.keyboard.hasKeyRepeat()
    lurek.input.keyboard.setKeyRepeat(false)
    local disabled = lurek.input.keyboard.hasKeyRepeat()
    lurek.input.keyboard.setKeyRepeat(before)
    lurek.log.info("rename field repeat enabled=" .. tostring(enabled) .. " disabled=" .. tostring(disabled))
end

--@api: lurek.input.keyboard.hasTextInput
do

    local before = lurek.input.keyboard.hasTextInput()
    lurek.input.keyboard.setTextInput(true)
    local enabled = lurek.input.keyboard.hasTextInput()
    lurek.input.keyboard.setTextInput(before)
    lurek.log.info("chat text input before=" .. tostring(before) .. " enabled=" .. tostring(enabled))
    lurek.log.info("chat text input restored=" .. tostring(lurek.input.keyboard.hasTextInput()))
end

--@api: lurek.input.keyboard.setTextInput
do

    local before = lurek.input.keyboard.hasTextInput()
    lurek.input.keyboard.setTextInput(true)
    local enabled = lurek.input.keyboard.hasTextInput()
    lurek.input.keyboard.setTextInput(false)
    local disabled = lurek.input.keyboard.hasTextInput()
    lurek.input.keyboard.setTextInput(before)
    lurek.log.info("rename dialog text input enabled=" .. tostring(enabled) .. " disabled=" .. tostring(disabled))
end

--@api: lurek.input.mouse.getPosition
do

    local x, y = lurek.input.mouse.getPosition()
    local tileX = math.floor(x / 32)
    local tileY = math.floor(y / 32)
    local hoveredCell = tileX .. "," .. tileY
    lurek.log.info("map editor mouse=" .. x .. "," .. y)
    lurek.log.info("map editor tile=" .. hoveredCell)
end

--@api: lurek.input.mouse.getX
do

    local x = lurek.input.mouse.getX()
    local y = lurek.input.mouse.getY()
    local snappedX = math.floor(x / 16) * 16
    lurek.log.info("inventory cursor x=" .. x .. " y=" .. y)
    lurek.log.info("inventory snapped x=" .. snappedX)
end

--@api: lurek.input.mouse.getY
do

    local y = lurek.input.mouse.getY()
    local x = lurek.input.mouse.getX()
    local snappedY = math.floor(y / 16) * 16
    lurek.log.info("inventory cursor y=" .. y .. " x=" .. x)
    lurek.log.info("inventory snapped y=" .. snappedY)
end

--@api: lurek.input.mouse.isDown
do

    local left = lurek.input.mouse.isDown(1)
    local right = lurek.input.mouse.isDown(2)
    local middle = lurek.input.mouse.isDown(3)
    local painting = left and not right
    lurek.log.info("tile painter left=" .. tostring(left) .. " right=" .. tostring(right) .. " middle=" .. tostring(middle))
    lurek.log.info("tile painter drawing=" .. tostring(painting))
end

--@api: lurek.input.mouse.getWheelDelta
do

    local dx, dy = lurek.input.mouse.getWheelDelta()
    local zoomDelta = dy
    local cycleDelta = dx
    lurek.log.info("tool wheel dx=" .. dx .. " dy=" .. dy)
    lurek.log.info("tool zoom delta=" .. zoomDelta .. " cycle delta=" .. cycleDelta)
end

--@api: lurek.input.mouse.setPosition
do

    lurek.input.mouse.setPosition(400, 300)
    local x, y = lurek.input.mouse.getPosition()
    local centered = x == 400 and y == 300
    local tile = math.floor(x / 32) .. "," .. math.floor(y / 32)
    lurek.log.info("strategy cursor warped to=" .. x .. "," .. y)
    lurek.log.info("strategy cursor centered=" .. tostring(centered) .. " tile=" .. tile)
end

--@api: lurek.input.mouse.isVisible
do

    local before = lurek.input.mouse.isVisible()
    lurek.input.mouse.setVisible(false)
    local hidden = lurek.input.mouse.isVisible()
    lurek.input.mouse.setVisible(true)
    local shown = lurek.input.mouse.isVisible()
    lurek.input.mouse.setVisible(before)
    lurek.log.info("photo cursor before=" .. tostring(before) .. " hidden=" .. tostring(hidden) .. " shown=" .. tostring(shown))
end

--@api: lurek.input.mouse.setVisible
do

    local before = lurek.input.mouse.isVisible()
    lurek.input.mouse.setVisible(false)
    local hidden = lurek.input.mouse.isVisible()
    lurek.input.mouse.setVisible(true)
    local shown = lurek.input.mouse.isVisible()
    lurek.input.mouse.setVisible(before)
    lurek.log.info("dialog cursor hidden=" .. tostring(hidden) .. " shown=" .. tostring(shown))
end

--@api: lurek.input.mouse.isGrabbed
do

    local before = lurek.input.mouse.isGrabbed()
    lurek.input.mouse.setGrabbed(false)
    local released = lurek.input.mouse.isGrabbed()
    lurek.input.mouse.setGrabbed(before)
    lurek.log.info("fps grab before=" .. tostring(before))
    lurek.log.info("fps grab released state=" .. tostring(released))
end

--@api: lurek.input.mouse.setGrabbed
do

    local before = lurek.input.mouse.isGrabbed()
    lurek.input.mouse.setGrabbed(false)
    local released = lurek.input.mouse.isGrabbed()
    lurek.input.mouse.setGrabbed(before)
    local restored = lurek.input.mouse.isGrabbed()
    lurek.log.info("editor grab released=" .. tostring(released))
    lurek.log.info("editor grab restored=" .. tostring(restored))
end

--@api: lurek.input.mouse.getRelativeMode
do

    local before = lurek.input.mouse.getRelativeMode()
    lurek.input.mouse.setRelativeMode(false)
    local disabled = lurek.input.mouse.getRelativeMode()
    lurek.input.mouse.setRelativeMode(before)
    lurek.log.info("aim mode relative before=" .. tostring(before))
    lurek.log.info("aim mode relative disabled=" .. tostring(disabled))
end

--@api: lurek.input.mouse.setRelativeMode
do

    local before = lurek.input.mouse.getRelativeMode()
    lurek.input.mouse.setRelativeMode(false)
    local disabled = lurek.input.mouse.getRelativeMode()
    lurek.input.mouse.setRelativeMode(before)
    local restored = lurek.input.mouse.getRelativeMode()
    lurek.log.info("shooter relative disabled=" .. tostring(disabled))
    lurek.log.info("shooter relative restored=" .. tostring(restored))
end

--@api: lurek.input.mouse.isCursorSupported
do

    local supported = lurek.input.mouse.isCursorSupported()
    local current = lurek.input.mouse.getCursor()
    local arrow = lurek.input.mouse.getSystemCursor("arrow")
    lurek.log.info("cursor support=" .. tostring(supported) .. " current=" .. tostring(current))
    lurek.log.info("cursor arrow userdata=" .. tostring(arrow ~= nil))
    arrow:release()
end

--@api: lurek.input.mouse.getCursor
do

    local name = lurek.input.mouse.getCursor()
    local supported = lurek.input.mouse.isCursorSupported()
    local isArrowLike = name == "arrow" or name == "default"
    lurek.log.info("ui cursor name=" .. tostring(name))
    lurek.log.info("ui cursor supported=" .. tostring(supported) .. " arrow_like=" .. tostring(isArrowLike))
end

--@api: lurek.input.mouse.getSystemCursor
do

    local cursor = lurek.input.mouse.getSystemCursor("arrow")
    local kind = cursor:getType()
    local typeName = cursor:type()
    local isCursor = cursor:typeOf("LCursor")
    lurek.log.info("system cursor ready=" .. tostring(cursor ~= nil) .. " kind=" .. tostring(kind))
    lurek.log.info("system cursor type=" .. tostring(typeName) .. " is_cursor=" .. tostring(isCursor))
    cursor:release()
end

--@api: lurek.input.mouse.setCursor
do

    local cursor = lurek.input.mouse.getSystemCursor("arrow")
    lurek.input.mouse.setCursor(cursor)
    local afterArrow = lurek.input.mouse.getCursor()
    lurek.input.mouse.setCursor("crosshair")
    local afterCrosshair = lurek.input.mouse.getCursor()
    lurek.input.mouse.setCursor("arrow")
    lurek.log.info("cursor after arrow=" .. tostring(afterArrow) .. " after crosshair=" .. tostring(afterCrosshair))
    cursor:release()
end

--@api: lurek.input.mouse.newCursor
do

    local pixels = {}
    for i = 1, 16 * 16 * 4 do
        pixels[i] = 255
    end
    local cursor = lurek.input.mouse.newCursor(pixels, 16, 16, 0, 0)
    lurek.log.info(tostring("custom cursor type = " .. cursor:getType()))
end

--@api: lurek.input.gamepad.getCount
do

    local count = lurek.input.gamepad.getCount()
    local joystickCount = lurek.input.gamepad.getJoystickCount()
    local ids = lurek.input.gamepad.getJoysticks()
    lurek.log.info("gamepad slots=" .. count .. " joystick slots=" .. joystickCount)
    lurek.log.info("gamepad listed ids=" .. tostring(#ids))
end

--@api: lurek.input.gamepad.isConnected
do

    local connected = lurek.input.gamepad.isConnected(0)
    local name = lurek.input.gamepad.getName(0)
    local count = lurek.input.gamepad.getCount()
    lurek.log.info("pad0 connected=" .. tostring(connected) .. " name=" .. tostring(name))
    lurek.log.info("tracked pads=" .. tostring(count))
end

--@api: lurek.input.gamepad.isGamepad
do

    local is_gp = lurek.input.gamepad.isGamepad(0)
    local connected = lurek.input.gamepad.isConnected(0)
    local guid = lurek.input.gamepad.getGUID(0)
    lurek.log.info("slot0 is gamepad=" .. tostring(is_gp) .. " connected=" .. tostring(connected))
    lurek.log.info("slot0 guid=" .. tostring(guid))
end

--@api: lurek.input.gamepad.getName
do

    local name = lurek.input.gamepad.getName(0)
    local connected = lurek.input.gamepad.isConnected(0)
    local buttons = lurek.input.gamepad.getButtonCount(0)
    lurek.log.info("gamepad name=" .. tostring(name))
    lurek.log.info("gamepad connected=" .. tostring(connected) .. " buttons=" .. tostring(buttons))
end

--@api: lurek.input.gamepad.getGUID
do

    local guid = lurek.input.gamepad.getGUID(0)
    local name = lurek.input.gamepad.getName(0)
    local mapping = lurek.input.gamepad.getGamepadMappingString(guid)
    lurek.log.info("gamepad guid=" .. tostring(guid))
    lurek.log.info("gamepad name=" .. tostring(name) .. " has_mapping=" .. tostring(mapping ~= nil))
end

--@api: lurek.input.gamepad.getAxis
do

    local val = lurek.input.gamepad.getAxis(0, 0)
    local trigger = lurek.input.gamepad.getAxis(0, 5)
    local dpad = lurek.input.gamepad.virtualDpad(val, 0.0, 0.3)
    lurek.log.info("racing steer axis=" .. tostring(val) .. " trigger=" .. tostring(trigger))
    lurek.log.info("racing steer direction=" .. tostring(dpad.direction))
end

--@api: lurek.input.gamepad.getAxisCount
do

    local count = lurek.input.gamepad.getAxisCount(0)
    local buttons = lurek.input.gamepad.getButtonCount(0)
    local connected = lurek.input.gamepad.isConnected(0)
    lurek.log.info("pad axes=" .. count .. " buttons=" .. buttons)
    lurek.log.info("pad connected=" .. tostring(connected))
end

--@api: lurek.input.gamepad.getButtonCount
do

    local count = lurek.input.gamepad.getButtonCount(0)
    local axes = lurek.input.gamepad.getAxisCount(0)
    local connected = lurek.input.gamepad.isConnected(0)
    lurek.log.info("pad buttons=" .. count .. " axes=" .. axes)
    lurek.log.info("pad connected=" .. tostring(connected))
end

--@api: lurek.input.gamepad.isDown
do

    local pressed = lurek.input.gamepad.isDown(0, 0)
    local confirmPressed = lurek.input.gamepad.isDown(0, 1)
    local anyFace = pressed or confirmPressed
    lurek.log.info("pad attack=" .. tostring(pressed) .. " confirm=" .. tostring(confirmPressed))
    lurek.log.info("pad any face button=" .. tostring(anyFace))
end

--@api: lurek.input.gamepad.wasPressed
do

    local pressed = lurek.input.gamepad.wasPressed(0, 0)
    local confirm = lurek.input.gamepad.wasPressed(0, 1)
    local justPressed = pressed or confirm
    lurek.log.info("pad pressed attack=" .. tostring(pressed) .. " confirm=" .. tostring(confirm))
    lurek.log.info("pad any just pressed=" .. tostring(justPressed))
end

--@api: lurek.input.gamepad.wasReleased
do

    local released = lurek.input.gamepad.wasReleased(0, 0)
    local confirm = lurek.input.gamepad.wasReleased(0, 1)
    local anyReleased = released or confirm
    lurek.log.info("pad released attack=" .. tostring(released) .. " confirm=" .. tostring(confirm))
    lurek.log.info("pad any released=" .. tostring(anyReleased))
end

--@api: lurek.input.gamepad.getHat
do

    local hat = lurek.input.gamepad.getHat(0, 0)
    local connected = lurek.input.gamepad.isConnected(0)
    local isCenter = hat == "c"
    lurek.log.info("pad hat0=" .. tostring(hat))
    lurek.log.info("pad connected=" .. tostring(connected) .. " centered=" .. tostring(isCenter))
end

--@api: lurek.input.gamepad.vibrate
do

    local ok = lurek.input.gamepad.vibrate(0, 0.5, 0.5, 200)
    local supported = lurek.input.gamepad.isVibrationSupported(0)
    local fallback = lurek.input.gamepad.setVibration(0, 0.2, 0.4, 100)
    lurek.log.info("boss hit rumble vibrate=" .. tostring(ok) .. " supported=" .. tostring(supported))
    lurek.log.info("boss hit rumble fallback setVibration=" .. tostring(fallback))
end

--@api: lurek.input.gamepad.isVibrationSupported
do

    local sup = lurek.input.gamepad.isVibrationSupported(0)
    local name = lurek.input.gamepad.getName(0)
    local guid = lurek.input.gamepad.getGUID(0)
    lurek.log.info("rumble supported=" .. tostring(sup))
    lurek.log.info("rumble device=" .. tostring(name) .. " guid=" .. tostring(guid))
end

--@api: lurek.input.gamepad.virtualDpad
do

    local dpad = lurek.input.gamepad.virtualDpad(0.8, 0.0, 0.3)
    local diag = lurek.input.gamepad.virtualDpad(0.9, -0.9, 0.2)
    local centered = lurek.input.gamepad.virtualDpad(0.0, 0.0, 0.2)
    lurek.log.info("analog move direction=" .. tostring(dpad.direction) .. " right=" .. tostring(dpad.right))
    lurek.log.info("analog diag=" .. tostring(diag.direction) .. " centered=" .. tostring(centered.direction))
end

--@api: lurek.input.gamepad.wasConnected
do

    local c = lurek.input.gamepad.wasConnected(0)
    local connected = lurek.input.gamepad.isConnected(0)
    local count = lurek.input.gamepad.getCount()
    lurek.log.info("pad connected this frame=" .. tostring(c))
    lurek.log.info("pad connected now=" .. tostring(connected) .. " count=" .. tostring(count))
end

--@api: lurek.input.gamepad.wasDisconnected
do

    local d = lurek.input.gamepad.wasDisconnected(0)
    local connected = lurek.input.gamepad.isConnected(0)
    local count = lurek.input.gamepad.getCount()
    lurek.log.info("pad disconnected this frame=" .. tostring(d))
    lurek.log.info("pad connected now=" .. tostring(connected) .. " count=" .. tostring(count))
end

--@api: lurek.input.gamepad.loadGamepadMappings
do

    local mappingPath = "save/gamecontrollerdb.txt"
    lurek.filesystem.write(mappingPath, "030000005e0400008e02000014010000,XInput,a:b0\n")
    lurek.input.gamepad.loadGamepadMappings(mappingPath)
    lurek.input.gamepad.saveGamepadMappings("save/mappings_out.txt")
    lurek.log.info(tostring("mappings loaded and saved"))
end

--@api: lurek.input.gamepad.saveGamepadMappings
do

    local mappingPath = "save/gamecontrollerdb.txt"
    lurek.filesystem.write(mappingPath, "030000005e0400008e02000014010000,XInput,a:b0\n")
    lurek.input.gamepad.loadGamepadMappings(mappingPath)
    lurek.input.gamepad.saveGamepadMappings("save/mappings_out.txt")
    lurek.log.info(tostring("mappings loaded and saved"))
end

--@api: lurek.input.gamepad.getBackgroundEvents
do

    local was = lurek.input.gamepad.getBackgroundEvents()
    lurek.input.gamepad.setBackgroundEvents(true)
    local enabled = lurek.input.gamepad.getBackgroundEvents()
    lurek.input.gamepad.setBackgroundEvents(was)
    lurek.log.info("background pad events was=" .. tostring(was) .. " enabled=" .. tostring(enabled))
    lurek.log.info("background pad events restored=" .. tostring(lurek.input.gamepad.getBackgroundEvents()))
end

--@api: lurek.input.gamepad.setBackgroundEvents
do

    local was = lurek.input.gamepad.getBackgroundEvents()
    lurek.input.gamepad.setBackgroundEvents(true)
    local enabled = lurek.input.gamepad.getBackgroundEvents()
    lurek.input.gamepad.setBackgroundEvents(false)
    local disabled = lurek.input.gamepad.getBackgroundEvents()
    lurek.input.gamepad.setBackgroundEvents(was)
    lurek.log.info("background focus enabled=" .. tostring(enabled) .. " disabled=" .. tostring(disabled))
end

--@api: lurek.input.gamepad.getJoystickCount
do

    local count = lurek.input.gamepad.getJoystickCount()
    local sticks = lurek.input.gamepad.getJoysticks()
    local gamepads = lurek.input.gamepad.getCount()
    lurek.log.info("joystick count=" .. count .. " listed=" .. #sticks)
    lurek.log.info("tracked gamepad slots=" .. gamepads)
end

--@api: lurek.input.gamepad.getJoysticks
do

    local count = lurek.input.gamepad.getJoystickCount()
    local sticks = lurek.input.gamepad.getJoysticks()
    local first = sticks[1] or -1
    lurek.log.info("joystick list count=" .. #sticks .. " expected=" .. count)
    lurek.log.info("joystick first id=" .. tostring(first))
end

--@api: lurek.input.touch.getTouchCount
do

    local count = lurek.input.touch.getTouchCount()
    local touches = lurek.input.touch.getTouches()
    local first = touches[1] and touches[1].id or "none"
    lurek.log.info("mobile touches=" .. count)
    lurek.log.info("mobile first touch id=" .. tostring(first))
end

--@api: lurek.input.touch.getTouches
do

    local touches = lurek.input.touch.getTouches()
    local first = touches[1]
    local firstId = first and first.id or "none"
    local firstPressure = first and first.pressure or 0
    lurek.log.info("touch list count=" .. #touches)
    lurek.log.info("touch first id=" .. tostring(firstId) .. " pressure=" .. tostring(firstPressure))
end

--@api: lurek.input.touch.getPosition
do

    local touches = lurek.input.touch.getTouches()
    local id = touches[1] and touches[1].id or 1
    local x, y = lurek.input.touch.getPosition(id)
    local tx = math.floor(x / 32)
    local ty = math.floor(y / 32)
    lurek.log.info("touch drag id=" .. tostring(id))
    lurek.log.info("touch drag pos=" .. x .. "," .. y .. " tile=" .. tx .. "," .. ty)
end

--@api: lurek.input.touch.getPressure
do

    local touches = lurek.input.touch.getTouches()
    local id = touches[1] and touches[1].id or 1
    local p = lurek.input.touch.getPressure(id)
    local pressureClass = p > 0.5 and "firm" or "light"
    lurek.log.info("touch pressure id=" .. tostring(id))
    lurek.log.info("touch pressure value=" .. p .. " class=" .. pressureClass)
end

--@api: lurek.input.touch.wasPressed
do

    local touches = lurek.input.touch.getTouches()
    local id = touches[1] and touches[1].id or 1
    local pressed = lurek.input.touch.wasPressed(id)
    local released = lurek.input.touch.wasReleased(id)
    local active = lurek.input.touch.getTouchCount()
    lurek.log.info("touch pressed id=" .. tostring(id) .. " pressed=" .. tostring(pressed))
    lurek.log.info("touch released same frame=" .. tostring(released) .. " active_count=" .. tostring(active))
end

--@api: lurek.input.touch.wasReleased
do

    local touches = lurek.input.touch.getTouches()
    local id = touches[1] and touches[1].id or 1
    local pressed = lurek.input.touch.wasPressed(id)
    local released = lurek.input.touch.wasReleased(id)
    local active = lurek.input.touch.getTouchCount()
    lurek.log.info("touch released id=" .. tostring(id) .. " released=" .. tostring(released))
    lurek.log.info("touch pressed same frame=" .. tostring(pressed) .. " active_count=" .. tostring(active))
end

--- Input Module Part 2: action bindings, combos, recording/playback

--@api: lurek.input.bind
do

    lurek.input.bind("jump", "space")
    lurek.input.bind("move_left", {"a", "left"})
    local bindings = lurek.input.getBindings()
    local jumpBindings = rawget(bindings, "jump") or {}
    lurek.log.info("actions bound total=" .. tostring(#jumpBindings))
    lurek.log.info("actions bound has move_left=" .. tostring(rawget(bindings, "move_left") ~= nil))
    lurek.input.reset()
end

--@api: lurek.input.unbind
do

    lurek.input.bind("temp", "t")
    local had = lurek.input.unbind("temp")
    local bindings = lurek.input.getBindings()
    local stillPresent = rawget(bindings, "temp") ~= nil
    lurek.log.info("unbind had bindings=" .. tostring(had))
    lurek.log.info("unbind still present=" .. tostring(stillPresent))
    lurek.input.reset()
end

--@api: lurek.input.clearBindings
do

    lurek.input.bind("a1", "q")
    lurek.input.bind("a2", "e")
    local before = lurek.input.getBindings()
    lurek.input.clearBindings()
    local after = lurek.input.getBindings()
    lurek.log.info("clearBindings before a1=" .. tostring(rawget(before, "a1") ~= nil))
    lurek.log.info("clearBindings after a1=" .. tostring(rawget(after, "a1") ~= nil))
end

--@api: lurek.input.getBindings
do

    lurek.input.bind("shoot", "x")
    local bindings = lurek.input.getBindings()
    local shoot = rawget(bindings, "shoot") or {}
    lurek.log.info(tostring("has shoot = " .. tostring(rawget(bindings, "shoot") ~= nil)))
    lurek.log.info(tostring("shoot bindings = " .. #shoot))
end

--@api: lurek.input.isActionDown
do

    lurek.input.bind("fire", "space")
    local down = lurek.input.isActionDown("fire")
    local exists = rawget(lurek.input.getBindings(), "fire") ~= nil
    lurek.log.info("combat fire bound=" .. tostring(exists))
    lurek.log.info("combat fire down=" .. tostring(down))
    lurek.input.reset()
end

--@api: lurek.input.wasActionPressed
do

    lurek.input.bind("jump", "space")
    local pressed = lurek.input.wasActionPressed("jump")
    local recent = lurek.input.wasActionPressedWithin("jump", 5)
    lurek.log.info("platform jump pressed=" .. tostring(pressed))
    lurek.log.info("platform jump recent=" .. tostring(recent))
    lurek.input.reset()
end

--@api: lurek.input.wasActionPressedWithin
do

    lurek.input.bind("dodge", "shift")
    local recent = lurek.input.wasActionPressedWithin("dodge", 10)
    local pressed = lurek.input.wasActionPressed("dodge")
    lurek.log.info("action dodge recent=" .. tostring(recent))
    lurek.log.info("action dodge pressed_now=" .. tostring(pressed))
    lurek.input.reset()
end

--@api: lurek.input.wasActionReleased
do

    lurek.input.bind("run", "shift")
    local released = lurek.input.wasActionReleased("run")
    local down = lurek.input.isActionDown("run")
    lurek.log.info("action run released=" .. tostring(released))
    lurek.log.info("action run down=" .. tostring(down))
    lurek.input.reset()
end

--@api: lurek.input.isDown
do

    local hasHelper = type(lurek.input.isDown) == "function"
    local keyboardDown = lurek.input.keyboard.isDown("a")
    local mapping = lurek.input.newMapping("move_left", {"a", "left"})
    local mappingDown = mapping.isDown()
    lurek.log.info("mapping isDown helper=" .. tostring(hasHelper) .. " keyboardDown=" .. tostring(keyboardDown))
    lurek.log.info("mapping move_left down=" .. tostring(mappingDown))
end

--@api: lurek.input.wasPressed
do

    local has_was_pressed = type(lurek.input.wasPressed) == "function"
    local v = has_was_pressed and lurek.input.wasPressed() or false
    local mapping = lurek.input.newMapping("attack", {"z", "button1"})
    local mappingPressed = mapping.wasPressed()
    lurek.log.info("wasPressed available=" .. tostring(has_was_pressed))
    lurek.log.info("wasPressed result=" .. tostring(v) .. " mappingPressed=" .. tostring(mappingPressed))
end

--@api: lurek.input.wasReleased
do

    local has_was_released = type(lurek.input.wasReleased) == "function"
    local v = has_was_released and lurek.input.wasReleased() or false
    local mapping = lurek.input.newMapping("attack", {"z", "button1"})
    local mappingReleased = mapping.wasReleased()
    lurek.log.info("wasReleased available=" .. tostring(has_was_released))
    lurek.log.info("wasReleased result=" .. tostring(v) .. " mappingReleased=" .. tostring(mappingReleased))
end

--@api: lurek.input.newMapping
do

    local mapping = lurek.input.newMapping("attack", {"z", "button1"})
    local held = mapping.isDown()
    local just = mapping.wasPressed()
    local done = mapping.wasReleased()
    lurek.log.info(tostring("held=" .. tostring(held) .. " just=" .. tostring(just) .. " done=" .. tostring(done)))
end

--@api: lurek.input.newCombo
do

    local combo = lurek.input.newCombo({"down", "right", "z"}, {total_gap = 500})
    local step1 = combo:getStep(1)
    local progress = combo:progress()
    lurek.log.info("combo total steps=" .. combo:totalSteps() .. " first=" .. tostring(step1.key))
    lurek.log.info("combo in progress=" .. tostring(combo:isInProgress()) .. " progress=" .. progress)
end

--@api: LCombo:feed
do

    local combo = lurek.input.newCombo({"a", "b", "c"})
    local result = combo:feed("a")
    local progress = combo:progress()
    local inProgress = combo:isInProgress()
    lurek.log.info("combo feed a->" .. tostring(result))
    lurek.log.info("combo progress=" .. tostring(progress) .. " inProgress=" .. tostring(inProgress))
end

--@api: LCombo:tick
do

    local combo = lurek.input.newCombo({"x", "y"}, {total_gap = 300})
    local result = combo:tick(0.016)
    local progress = combo:progress()
    local total = combo:totalSteps()
    lurek.log.info("combo tick->" .. tostring(result))
    lurek.log.info("combo progress=" .. tostring(progress) .. " total=" .. tostring(total))
end

--@api: LCombo:getStep
do

    local combo = lurek.input.newCombo({"a", "b"})
    local step = combo:getStep(1)
    local step2 = combo:getStep(2)
    lurek.log.info("combo step1 key=" .. tostring(step.key) .. " gap=" .. tostring(step.gap_ms))
    lurek.log.info("combo step2 key=" .. tostring(step2.key) .. " gap=" .. tostring(step2.gap_ms))
end

--@api: LCombo:reset
do

    local combo = lurek.input.newCombo({"q", "w", "e"})
    combo:feed("q")
    local before = combo:progress()
    combo:reset()
    local after = combo:progress()
    lurek.log.info("combo progress before reset=" .. tostring(before))
    lurek.log.info("combo progress after reset=" .. tostring(after))
end

--@api: LCombo:type
do

    local combo = lurek.input.newCombo({"a"})
    local total = combo:totalSteps()
    local progress = combo:progress()
    lurek.log.info("combo type=" .. combo:type() .. " total=" .. tostring(total))
    lurek.log.info("combo is LCombo=" .. tostring(combo:typeOf("LCombo")) .. " progress=" .. tostring(progress))
end

--@api: LCombo:typeOf
do

    local combo = lurek.input.newCombo({"a"})
    local total = combo:totalSteps()
    local progress = combo:progress()
    lurek.log.info("combo typeOf LCombo=" .. tostring(combo:typeOf("LCombo")))
    lurek.log.info("combo type=" .. combo:type() .. " progress=" .. tostring(progress) .. " total=" .. tostring(total))
end

--@api: lurek.input.startRecording
do

    lurek.input.startRecording()
    local recording = lurek.input.stopRecording()
    local frames = recording and recording:frameCount() or 0
    local typeName = recording and recording:type() or "nil"
    lurek.log.info("recording captured=" .. tostring(recording ~= nil))
    lurek.log.info("recording frames=" .. tostring(frames) .. " type=" .. tostring(typeName))
end

--@api: LInputRecording:toJson
do

    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    local json = rec and rec:toJson() or ""
    local frames = rec and rec:frameCount() or 0
    local total = rec and rec:totalFrames() or 0
    lurek.log.info("recording json length=" .. #json)
    lurek.log.info("recording frames=" .. tostring(frames) .. " total=" .. tostring(total))
end

--@api: lurek.input.loadRecording
do

    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    if rec then lurek.input.loadRecording(rec:toJson()) end
    local frame = lurek.input.getPlaybackFrame()
    local loaded = rec ~= nil
    lurek.log.info("recording loaded=" .. tostring(loaded))
    lurek.log.info("recording playback frame=" .. tostring(frame))
end

--@api: lurek.input.startPlayback
do

    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    if rec then
        lurek.input.loadRecording(rec:toJson())
        lurek.input.startPlayback({ mode = "fixed", fixed_step_ms = 16 })
    end
    local playing = lurek.input.isPlayingBack()
    local frame = lurek.input.getPlaybackFrame()
    lurek.log.info("playback started=" .. tostring(playing))
    lurek.log.info("playback frame=" .. tostring(frame))
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
    local frame = lurek.input.getPlaybackFrame()
    lurek.log.info("playback events=" .. #events)
    lurek.log.info("playback advanced frame=" .. tostring(frame))
    lurek.input.stopPlayback()
end

--@api: lurek.input.getPlaybackFrame
do

    local frame = lurek.input.getPlaybackFrame()
    local playing = lurek.input.isPlayingBack()
    local recording = lurek.input.isRecording()
    lurek.log.info("playback frame=" .. frame)
    lurek.log.info("playback active=" .. tostring(playing) .. " recording=" .. tostring(recording))
end

--@api: lurek.input.isRecording
do

    local before = lurek.input.isRecording()
    lurek.input.startRecording()
    local during = lurek.input.isRecording()
    local rec = lurek.input.stopRecording()
    lurek.log.info("recording before=" .. tostring(before) .. " during=" .. tostring(during))
    lurek.log.info("recording object returned=" .. tostring(rec ~= nil))
end

--@api: lurek.input.gamepad.getGamepadMappingString
do

    local guid = "030000005e0400008e02000014010000"
    lurek.input.gamepad.setGamepadMapping(guid, guid .. ",XInput,a:b0")
    local mapping = lurek.input.gamepad.getGamepadMappingString(guid)
    local hasAButton = mapping and mapping:find("a:b0", 1, true) ~= nil
    lurek.log.info("mapping present=" .. tostring(mapping ~= nil))
    lurek.log.info("mapping has a:b0=" .. tostring(hasAButton))
end

--@api: lurek.input.gamepad.setGamepadMapping
do

    local guid = "030000005e0400008e02000014010000"
    local mapping = guid .. ",TestPad,a:b0,b:b1"
    lurek.input.gamepad.setGamepadMapping(guid, mapping)
    local stored = lurek.input.gamepad.getGamepadMappingString(guid)
    lurek.log.info("custom mapping set for guid=" .. guid)
    lurek.log.info("custom mapping stored=" .. tostring(stored == mapping))
end

--@api: lurek.input.gamepad.setVibration
do

    local ok = lurek.input.gamepad.setVibration(0, 0.3, 0.7, 100)
    local supported = lurek.input.gamepad.isVibrationSupported(0)
    local alias = lurek.input.gamepad.vibrate(0, 0.1, 0.1, 50)
    lurek.log.info("setVibration ok=" .. tostring(ok) .. " supported=" .. tostring(supported))
    lurek.log.info("setVibration alias vibrate=" .. tostring(alias))
end

--- Input Module Part 2: combo system, cursor, recording/playback, extra gamepad/touch/mouse

--@api: LCombo:isInProgress
do

    local combo = lurek.input.newCombo({ "a", "b", "c" })
    combo:feed("a")
    combo:tick(0.016)
    local progress = combo:progress()
    local total = combo:totalSteps()
    lurek.log.info("combo in progress=" .. tostring(combo:isInProgress()))
    lurek.log.info("combo progress=" .. tostring(progress) .. " total=" .. tostring(total))
end

--@api: LCombo:progress
do

    local combo = lurek.input.newCombo({ "a", "b", "c" })
    combo:feed("a")
    combo:tick(0.016)
    lurek.log.info(tostring("in_progress=" .. tostring(combo:isInProgress())))
    lurek.log.info(tostring("progress=" .. combo:progress()))
end

--@api: LCombo:totalSteps
do

    local combo = lurek.input.newCombo({ "a", "b", "c" })
    combo:feed("a")
    combo:tick(0.016)
    local progress = combo:progress()
    local inProgress = combo:isInProgress()
    lurek.log.info("combo total=" .. combo:totalSteps())
    lurek.log.info("combo progress=" .. tostring(progress) .. " inProgress=" .. tostring(inProgress))
end

--@api: LCursor:getType
do

    local sys_cursor = lurek.input.mouse.getSystemCursor("arrow")
    lurek.log.info(tostring("cursor type=" .. sys_cursor:type()))
    lurek.log.info(tostring("cursor kind=" .. sys_cursor:getType()))
    lurek.log.info(tostring("typeOf=" .. tostring(sys_cursor:typeOf("LCursor"))))
    sys_cursor:release()
end

--@api: LCursor:release
do

    local sys_cursor = lurek.input.mouse.getSystemCursor("arrow")
    lurek.log.info(tostring("cursor type=" .. sys_cursor:type()))
    lurek.log.info(tostring("cursor kind=" .. sys_cursor:getType()))
    lurek.log.info(tostring("typeOf=" .. tostring(sys_cursor:typeOf("LCursor"))))
    sys_cursor:release()
end

--@api: LCursor:type
do

    local sys_cursor = lurek.input.mouse.getSystemCursor("arrow")
    lurek.log.info(tostring("cursor type=" .. sys_cursor:type()))
    lurek.log.info(tostring("cursor kind=" .. sys_cursor:getType()))
    lurek.log.info(tostring("typeOf=" .. tostring(sys_cursor:typeOf("LCursor"))))
    sys_cursor:release()
end

--@api: LCursor:typeOf
do

    local sys_cursor = lurek.input.mouse.getSystemCursor("arrow")
    lurek.log.info(tostring("cursor type=" .. sys_cursor:type()))
    lurek.log.info(tostring("cursor kind=" .. sys_cursor:getType()))
    lurek.log.info(tostring("typeOf=" .. tostring(sys_cursor:typeOf("LCursor"))))
    sys_cursor:release()
end

--@api: LInputRecording:frameCount
do

    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    local frames = rec and rec:frameCount() or 0
    local total = rec and rec:totalFrames() or 0
    lurek.log.info("recording frameCount=" .. tostring(frames))
    lurek.log.info("recording totalFrames=" .. tostring(total))
end

--@api: LInputRecording:totalFrames
do

    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    local total = rec and rec:totalFrames() or 0
    local frames = rec and rec:frameCount() or 0
    lurek.log.info("recording totalFrames=" .. tostring(total))
    lurek.log.info("recording frameCount=" .. tostring(frames))
end

--@api: LInputRecording:type
do

    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    local typeName = rec and rec:type() or "nil"
    local frames = rec and rec:frameCount() or 0
    lurek.log.info("recording type=" .. tostring(typeName))
    lurek.log.info("recording frames=" .. tostring(frames))
end

--@api: LInputRecording:typeOf
do

    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    local isRecording = rec and rec:typeOf("LInputRecording") or false
    local typeName = rec and rec:type() or "nil"
    lurek.log.info("recording typeOf LInputRecording=" .. tostring(isRecording))
    lurek.log.info("recording type=" .. tostring(typeName))
end

--@api: lurek.input.isPlayingBack
do

    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    if rec then
        lurek.input.loadRecording(rec:toJson())
        lurek.input.startPlayback()
    end
    local playing = lurek.input.isPlayingBack()
    local frame = lurek.input.getPlaybackFrame()
    lurek.log.info("isPlayingBack=" .. tostring(playing))
    lurek.log.info("playback frame=" .. tostring(frame))
    lurek.input.stopPlayback()
end

--@api: lurek.input.stopPlayback
do

    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    if rec then lurek.input.loadRecording(rec:toJson()); lurek.input.startPlayback() end
    local before = lurek.input.isPlayingBack()
    lurek.input.stopPlayback()
    local after = lurek.input.isPlayingBack()
    lurek.log.info("stopPlayback before=" .. tostring(before))
    lurek.log.info("stopPlayback after=" .. tostring(after))
end

--@api: lurek.input.stopRecording
do

    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    local frames = rec and rec:frameCount() or 0
    local json = rec and rec:toJson() or ""
    lurek.log.info("stopped recording=" .. tostring(rec ~= nil))
    lurek.log.info("stopped recording frames=" .. tostring(frames) .. " json_len=" .. tostring(#json))
end

--@api: lurek.input.getTouchCount
do

    local n = lurek.input.touch.getTouchCount()
    local touches = lurek.input.touch.getTouches()
    local first = touches[1] and touches[1].id or "none"
    lurek.log.info("module getTouchCount=" .. n)
    lurek.log.info("module first touch id=" .. tostring(first))
end

--- Input Module Part 3: extended action binding (NM-04)

--@api: lurek.input.define
do

    lurek.input.define("jump", {"space", "up"}, "movement")
    lurek.input.define("pause", {"escape", "p"}, "system")
    local movement = lurek.input.getByCategory("movement")
    local system = lurek.input.getByCategory("system")
    lurek.log.info("define movement count=" .. tostring(#movement))
    lurek.log.info("define system count=" .. tostring(#system))
    lurek.input.reset()
end

--@api: lurek.input.getAxis
do

    lurek.input.bind("move_x", {"d", "a"})
    local v = lurek.input.getAxis("move_x")
    local mapping = rawget(lurek.input.getBindings(), "move_x") or {}
    lurek.log.info("axis move_x value=" .. tostring(v))
    lurek.log.info("axis move_x bindings=" .. tostring(#mapping))
    lurek.input.reset()
end

--@api: lurek.input.getVector
do

    lurek.input.bind("haxis", {"d", "a"})
    lurek.input.bind("vaxis", {"s", "w"})
    local h, v = lurek.input.getVector("haxis", "vaxis")
    lurek.log.info(tostring("getVector=" .. tostring(h) .. "," .. tostring(v)))
    lurek.input.reset()
end

--@api: lurek.input.reset
do

    lurek.input.bind("temp", "t")
    lurek.input.reset("temp")
    lurek.log.info(tostring("reset(name) ok"))
    lurek.input.reset()
    lurek.log.info(tostring("reset() ok"))
end

--@api: lurek.input.getConflicts
do

    lurek.input.bind("act_a", "x")
    lurek.input.bind("act_b", "x")
    local c = lurek.input.getConflicts()
    lurek.log.info(tostring("getConflicts type=" .. type(c)))
    lurek.input.reset()
end

--@api: lurek.input.serializeBindings
do

    lurek.input.bind("test_ser", "s")
    local json = lurek.input.serializeBindings()
    local hasAction = json:find("test_ser", 1, true) ~= nil
    lurek.log.info("serializeBindings len=" .. #json)
    lurek.log.info("serializeBindings has action=" .. tostring(hasAction))
    lurek.input.reset()
end

--@api: lurek.input.deserializeBindings
do

    lurek.input.bind("test_deser", "q")
    local json = lurek.input.serializeBindings()
    lurek.input.reset()
    local ok = lurek.input.deserializeBindings(json)
    lurek.log.info(tostring("deserializeBindings=" .. tostring(ok)))
    lurek.input.reset()
end

--@api: lurek.input.getByCategory
do

    lurek.input.define("run", "lshift", "movement")
    local cats = lurek.input.getByCategory("movement")
    lurek.input.define("jump", "space", "movement")
    local first = cats[1] or "none"
    lurek.log.info("getByCategory count=" .. #cats)
    lurek.log.info("getByCategory first=" .. tostring(first))
    lurek.input.reset()
end

--@api: lurek.input.onRebind
do

    local firedAction = "none"
    local firedCount = 0
    lurek.input.onRebind(function(action, keys)
        firedAction = action
        firedCount = #keys
    end)
    lurek.input.define("menu_confirm", {"return", "space"}, "ui")
    lurek.log.info("onRebind action=" .. tostring(firedAction))
    lurek.log.info("onRebind key_count=" .. tostring(firedCount))
    lurek.input.reset()
end

--@api: lurek.input.defineActions
do
    local count = lurek.input.defineActions({
        fire = { "space", "mouse1" },
        thrust = { bindings = { "w", "up" }, category = "flight" },
        brake = { bindings = { "s" } },
    }, "combat")
    lurek.log.info("defineActions count=" .. tostring(count))
    lurek.log.info("combat actions=" .. tostring(#lurek.input.getByCategory("combat")))
    lurek.input.reset()
end

--- Fighting-game and multi-device input patterns.

--@api: lurek.input.setContextEnabled
--@api: lurek.input.isContextEnabled
--@api: lurek.input.mouse.wasPressed
--@api: lurek.input.mouse.getDelta
--@api: lurek.input.keyboard.wasPressed
--@api: lurek.input.gamepad.assignPlayer
--@api: lurek.input.gamepad.setDeadzone
--@api: lurek.input.gamepad.getStandardAxis
do
    lurek.input.define("debug_palette", {
        { all = { "lctrl", "k" }, within_ms = 60 },
        "gamepad:any:start",
    }, "system", "system")
    lurek.input.setContextEnabled("gameplay", true)
    local ctrl_k = lurek.input.isActionDown("debug_palette")
    local extra_mouse = lurek.input.mouse.wasPressed(6)
    local dx, dy = lurek.input.mouse.getDelta()
    local q_pressed = lurek.input.keyboard.wasPressed("q")
    lurek.input.assignPlayer(1, 0)
    lurek.input.gamepad.setDeadzone(0, "leftstick", 0.18)
    local stick_x = lurek.input.gamepad.getStandardAxis(0, "leftx")
    lurek.log.info("input chord=" .. tostring(ctrl_k) .. " extra_mouse=" .. tostring(extra_mouse))
    lurek.log.info("input delta=" .. tostring(dx) .. "," .. tostring(dy) .. " q=" .. tostring(q_pressed) .. " stick=" .. tostring(stick_x))
    lurek.input.reset()
end

--@api: lurek.input.newCombo
--@api: LCombo:wasCompleted
--@api: LCombo:completedWithin
--@api: LCombo:consume
do
    local fireball = lurek.input.newCombo({
        { direction = "down" },
        { direction = "down_right", leniency_ms = 70 },
        { direction = "right" },
        { press = "punch" },
    }, { source = "player1", total_ms = 550, input_buffer_ms = 100 })
    local charge = lurek.input.newCombo({
        { hold = "left", min_hold_ms = 600 },
        { press = "punch" },
    })
    local chord = lurek.input.newCombo({ { chord = { "punch_light", "kick_light" }, within_ms = 50 } })
    fireball:update()
    charge:update()
    chord:update()
    if fireball:wasCompleted() and fireball:completedWithin(100) then
        fireball:consume()
    end
end

--@api: LCombo:update
do

    local combo = lurek.input.newCombo({ { press = "punch" } }, { total_ms = 250 })
    local completed = combo:update()
    local pending = combo:wasCompleted()
    local still_fresh = combo:completedWithin(100)
    lurek.log.info("combo update=" .. tostring(completed))
    lurek.log.info("combo pending=" .. tostring(pending) .. " fresh=" .. tostring(still_fresh))
end

--@api: lurek.input.assignPlayer
do

    local player = 1
    local gamepad_id = 0
    lurek.input.assignPlayer(player, gamepad_id)
    local assigned_player = lurek.input.gamepad.getAssignedPlayer(gamepad_id)
    local assigned_gamepad = lurek.input.getPlayerGamepad(player)
    lurek.log.info("assigned player=" .. tostring(assigned_player))
    lurek.log.info("assigned gamepad=" .. tostring(assigned_gamepad))
end

--@api: lurek.input.gamepad.getAssignedPlayer
do

    local player = 2
    local gamepad_id = 0
    lurek.input.assignPlayer(player, gamepad_id)
    local assigned = lurek.input.gamepad.getAssignedPlayer(gamepad_id)
    local selected = lurek.input.getPlayerGamepad(player)
    lurek.log.info("gamepad player=" .. tostring(assigned))
    lurek.log.info("player gamepad=" .. tostring(selected))
end

--@api: lurek.input.gamepad.getDeadzone
do

    local gamepad_id = 0
    local stick = "leftstick"
    lurek.input.gamepad.setDeadzone(gamepad_id, stick, 0.18)
    local deadzone = lurek.input.gamepad.getDeadzone(gamepad_id, stick)
    local axis = lurek.input.gamepad.getStandardAxis(gamepad_id, "leftx")
    lurek.log.info("deadzone=" .. tostring(deadzone))
    lurek.log.info("left stick=" .. tostring(axis))
end

--@api: lurek.input.gamepad.getStandardButton
do

    local gamepad_id = 0
    local confirm_down = lurek.input.gamepad.getStandardButton(gamepad_id, "a")
    local menu_down = lurek.input.gamepad.getStandardButton(gamepad_id, "start")
    local confirm_released = lurek.input.gamepad.wasReleased(gamepad_id, 0)
    lurek.log.info("confirm down=" .. tostring(confirm_down))
    lurek.log.info("menu down=" .. tostring(menu_down) .. " released=" .. tostring(confirm_released))
end

--@api: lurek.input.getPlayerGamepad
do

    local player = 3
    local gamepad_id = 0
    lurek.input.assignPlayer(player, gamepad_id)
    local assigned = lurek.input.getPlayerGamepad(player)
    local owner = lurek.input.gamepad.getAssignedPlayer(gamepad_id)
    lurek.log.info("player gamepad=" .. tostring(assigned))
    lurek.log.info("gamepad owner=" .. tostring(owner))
end

--@api: lurek.input.keyboard.getTextInput
do

    local text_segments = lurek.input.keyboard.getTextInput()
    local count = #text_segments
    local first = text_segments[1] or ""
    local pressed = lurek.input.keyboard.wasPressed("return")
    lurek.log.info("committed text segments=" .. tostring(count))
    lurek.log.info("first text=" .. first .. " return=" .. tostring(pressed))
end

--@api: lurek.input.keyboard.wasReleased
do

    local key = "space"
    local released = lurek.input.keyboard.wasReleased(key)
    local down = lurek.input.keyboard.isDown(key)
    local pressed = lurek.input.keyboard.wasPressed(key)
    lurek.log.info("key released=" .. tostring(released))
    lurek.log.info("key down=" .. tostring(down) .. " pressed=" .. tostring(pressed))
end

--@api: lurek.input.keyboard.wasScancodePressed
do

    local scancode = "KeyW"
    local pressed = lurek.input.keyboard.wasScancodePressed(scancode)
    local released = lurek.input.keyboard.wasScancodeReleased(scancode)
    local down = lurek.input.keyboard.isScancodeDown(scancode)
    lurek.log.info("scancode pressed=" .. tostring(pressed))
    lurek.log.info("scancode released=" .. tostring(released) .. " down=" .. tostring(down))
end

--@api: lurek.input.keyboard.wasScancodeReleased
do

    local scancode = "Space"
    local released = lurek.input.keyboard.wasScancodeReleased(scancode)
    local pressed = lurek.input.keyboard.wasScancodePressed(scancode)
    local down = lurek.input.keyboard.isScancodeDown(scancode)
    lurek.log.info("scancode released=" .. tostring(released))
    lurek.log.info("scancode pressed=" .. tostring(pressed) .. " down=" .. tostring(down))
end

--@api: lurek.input.mouse.wasReleased
do

    local button = 1
    local released = lurek.input.mouse.wasReleased(button)
    local pressed = lurek.input.mouse.wasPressed(button)
    local down = lurek.input.mouse.isDown(button)
    lurek.log.info("mouse released=" .. tostring(released))
    lurek.log.info("mouse pressed=" .. tostring(pressed) .. " down=" .. tostring(down))
end
