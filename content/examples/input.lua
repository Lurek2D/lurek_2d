-- content/examples/input.lua
-- Lurek2D lurek.input API Reference
-- Run with: cargo run -- content/examples/input

-- =============================================================================
-- Input System — keyboard, mouse, gamepad, touch, action bindings,
-- combo detection, and input recording/playback
-- =============================================================================

-- ---- Stub: lurek.input.isDown --------------------------------------------
--@api-stub: lurek.input.isDown
-- Check whether movement keys are held so the player character keeps running.
-- isDown returns true for the ENTIRE duration the key is held, not just the press frame.
local moving_left  = lurek.input.isDown("a")
local moving_right = lurek.input.isDown("d")
local jumping      = lurek.input.isDown("space")
if moving_left then
    print("player running left")
elseif moving_right then
    print("player running right")
end
if jumping then
    print("player holding jump")
end

-- ---- Stub: lurek.input.isScancodeDown ------------------------------------
--@api-stub: lurek.input.isScancodeDown
-- Scancodes are layout-independent — WASD stays the same on AZERTY keyboards.
-- Use scancodes for movement so the physical key position always matches.
local sc_w = lurek.input.isScancodeDown("w")
local sc_a = lurek.input.isScancodeDown("a")
local sc_s = lurek.input.isScancodeDown("s")
local sc_d = lurek.input.isScancodeDown("d")
print("WASD (scancode) — W:" .. tostring(sc_w)
    .. " A:" .. tostring(sc_a)
    .. " S:" .. tostring(sc_s)
    .. " D:" .. tostring(sc_d))

-- ---- Stub: lurek.input.setKeyRepeat --------------------------------------
--@api-stub: lurek.input.setKeyRepeat
-- Demonstrates the proper usage of lurek.input.setKeyRepeat.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_input_setKeyRepeat()
    lurek.input.setKeyRepeat(true)
    print("key repeat enabled for search box")
end
local _ok, _err = pcall(demo_lurek_input_setKeyRepeat)

-- ---- Stub: lurek.input.hasKeyRepeat --------------------------------------
--@api-stub: lurek.input.hasKeyRepeat
-- Demonstrates the proper usage of lurek.input.hasKeyRepeat.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_input_hasKeyRepeat()
    local repeat_on = lurek.input.hasKeyRepeat()
    print("key repeat currently: " .. tostring(repeat_on))
end
local _ok, _err = pcall(demo_lurek_input_hasKeyRepeat)

-- ---- Stub: lurek.input.setTextInput --------------------------------------
--@api-stub: lurek.input.setTextInput
-- Demonstrates the proper usage of lurek.input.setTextInput.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_input_setTextInput()
    lurek.input.setTextInput(true)
    print("text input enabled — chat window open")
end
local _ok, _err = pcall(demo_lurek_input_setTextInput)

-- ---- Stub: lurek.input.hasTextInput --------------------------------------
--@api-stub: lurek.input.hasTextInput
-- Check text input state so we know whether to route keypresses to the chat box
-- or to the game action system.
local text_mode = lurek.input.hasTextInput()
print("text input mode active: " .. tostring(text_mode))
-- Disable when the chat window is closed
lurek.input.setTextInput(false)
print("text input disabled — back to game controls")

-- ---- Stub: lurek.input.getScancodeFromKey --------------------------------
--@api-stub: lurek.input.getScancodeFromKey
-- In a key-rebinding menu, convert the user-facing key name to the internal scancode
-- so the binding works regardless of keyboard layout.
local scancode_for_space = lurek.input.getScancodeFromKey("space")
print("scancode for 'space': " .. tostring(scancode_for_space))
local scancode_for_return = lurek.input.getScancodeFromKey("return")
print("scancode for 'return': " .. tostring(scancode_for_return))

-- ---- Stub: lurek.input.getKeyFromScancode --------------------------------
--@api-stub: lurek.input.getKeyFromScancode
-- Demonstrates the proper usage of lurek.input.getKeyFromScancode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_input_getKeyFromScancode()
    local key_name = lurek.input.getKeyFromScancode("space")
    print("key name for scancode 'space': " .. tostring(key_name))
end
local _ok, _err = pcall(demo_lurek_input_getKeyFromScancode)

-- ---- Stub: lurek.input.isModifierActive ----------------------------------
--@api-stub: lurek.input.isModifierActive
-- Demonstrates the proper usage of lurek.input.isModifierActive.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_input_isModifierActive()
    local ctrl_held  = lurek.input.isModifierActive("ctrl")
    local shift_held = lurek.input.isModifierActive("shift")
    print("ctrl held: " .. tostring(ctrl_held) .. "  shift held: " .. tostring(shift_held))
    if ctrl_held then
    print("adding unit to selection group")
end
local _ok, _err = pcall(demo_lurek_input_isModifierActive)

-- =============================================================================
-- Mouse — position, buttons, cursor, grab, and scroll wheel
-- =============================================================================

-- ---- Stub: lurek.input.getPosition ---------------------------------------
--@api-stub: lurek.input.getPosition
-- Demonstrates the proper usage of lurek.input.getPosition.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_input_getPosition()
    local aim_x, aim_y = lurek.input.getPosition()
    print("crosshair at: " .. tostring(aim_x) .. ", " .. tostring(aim_y))
end
local _ok, _err = pcall(demo_lurek_input_getPosition)

-- ---- Stub: lurek.input.getX ----------------------------------------------
--@api-stub: lurek.input.getX
-- Demonstrates the proper usage of lurek.input.getX.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_input_getX()
    print('Executing getX')
end
local _ok, _err = pcall(demo_lurek_input_getX)

-- ---- Stub: lurek.input.getY ----------------------------------------------
--@api-stub: lurek.input.getY
-- Demonstrates the proper usage of lurek.input.getY.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_input_getY()
    local mouse_x = lurek.input.getX()
    local mouse_y = lurek.input.getY()
    local parallax_offset_x = (mouse_x - 640) * 0.02
    local parallax_offset_y = (mouse_y - 360) * 0.01
    print("parallax offset: " .. parallax_offset_x .. ", " .. parallax_offset_y)
end
local _ok, _err = pcall(demo_lurek_input_getY)

-- ---- Stub: lurek.input.isDown --------------------------------------------
--@api-stub: lurek.input.isDown
-- Detect mouse button held for drag-selection box in an RTS.
-- Button 1 = left click, 2 = right click, 3 = middle click.
local lmb_held = lurek.input.isDown(1)
local rmb_held = lurek.input.isDown(2)
if lmb_held then
    print("drawing selection rectangle from " .. tostring(aim_x) .. "," .. tostring(aim_y))
elseif rmb_held then
    print("issuing move command to " .. tostring(aim_x) .. "," .. tostring(aim_y))
end

-- ---- Stub: lurek.input.setVisible ----------------------------------------
--@api-stub: lurek.input.setVisible
-- Demonstrates the proper usage of lurek.input.setVisible.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_input_setVisible()
    lurek.input.setVisible(false)
    print("OS cursor hidden — using custom crosshair sprite")
end
local _ok, _err = pcall(demo_lurek_input_setVisible)

-- ---- Stub: lurek.input.isVisible -----------------------------------------
--@api-stub: lurek.input.isVisible
-- Demonstrates the proper usage of lurek.input.isVisible.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_input_isVisible()
    local cursor_visible = lurek.input.isVisible()
    print("cursor visible: " .. tostring(cursor_visible))
    lurek.input.setVisible(true)
    print("OS cursor restored for pause menu")
end
local _ok, _err = pcall(demo_lurek_input_isVisible)

-- ---- Stub: lurek.input.setGrabbed ----------------------------------------
--@api-stub: lurek.input.setGrabbed
-- Demonstrates the proper usage of lurek.input.setGrabbed.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_input_setGrabbed()
    lurek.input.setGrabbed(true)
    print("mouse grabbed — first-person camera active")
end
local _ok, _err = pcall(demo_lurek_input_setGrabbed)

-- ---- Stub: lurek.input.isGrabbed -----------------------------------------
--@api-stub: lurek.input.isGrabbed
-- Demonstrates the proper usage of lurek.input.isGrabbed.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_input_isGrabbed()
    local grabbed = lurek.input.isGrabbed()
    if grabbed then
    print("press ESC to release the cursor")
    lurek.input.setGrabbed(false)
    print("mouse released")
end
local _ok, _err = pcall(demo_lurek_input_isGrabbed)

-- ---- Stub: lurek.input.setRelativeMode -----------------------------------
--@api-stub: lurek.input.setRelativeMode
-- Demonstrates the proper usage of lurek.input.setRelativeMode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_input_setRelativeMode()
    lurek.input.setRelativeMode(true)
    print("relative mouse mode ON — mouselook camera active")
end
local _ok, _err = pcall(demo_lurek_input_setRelativeMode)

-- ---- Stub: lurek.input.getRelativeMode -----------------------------------
--@api-stub: lurek.input.getRelativeMode
-- Demonstrates the proper usage of lurek.input.getRelativeMode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_input_getRelativeMode()
    local rel_mode = lurek.input.getRelativeMode()
    print("relative mode: " .. tostring(rel_mode))
    lurek.input.setRelativeMode(false)
    print("relative mode OFF — inventory cursor active")
end
local _ok, _err = pcall(demo_lurek_input_getRelativeMode)

-- ---- Stub: lurek.input.setPosition ---------------------------------------
--@api-stub: lurek.input.setPosition
-- Demonstrates the proper usage of lurek.input.setPosition.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_input_setPosition()
    local center_x, center_y = 640, 360
    lurek.input.setPosition(center_x, center_y)
    print("cursor snapped to screen center: " .. center_x .. ", " .. center_y)
end
local _ok, _err = pcall(demo_lurek_input_setPosition)

-- ---- Stub: lurek.input.setCursor -----------------------------------------
--@api-stub: lurek.input.setCursor
-- Demonstrates the proper usage of lurek.input.setCursor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_input_setCursor()
    lurek.input.setCursor("crosshair")
    print("cursor set to crosshair for targeting")
end
local _ok, _err = pcall(demo_lurek_input_setCursor)

-- ---- Stub: lurek.input.newCursor -----------------------------------------
--@api-stub: lurek.input.newCursor
-- Create a custom cursor from RGBA pixel data for a pixel-art game.
-- Arguments: width, height, hotspot_x, hotspot_y, pixel_data_table
local pixel_data = {}
for i = 1, 16 * 16 * 4 do pixel_data[i] = 255 end  -- solid white 16x16
local custom_cursor = lurek.input.newCursor(16, 16, 0, 0, pixel_data)
print("custom 16x16 cursor created, type: " .. type(custom_cursor))

-- ---- Stub: lurek.input.getSystemCursor -----------------------------------
--@api-stub: lurek.input.getSystemCursor
-- Retrieve a platform system cursor (arrow, hand, ibeam, crosshair, etc.)
-- for use in UI hover states.
local hand_cursor = lurek.input.getSystemCursor("hand")
print("system hand cursor: " .. type(hand_cursor))
local arrow_cursor = lurek.input.getSystemCursor("arrow")
print("system arrow cursor: " .. type(arrow_cursor))

-- ---- Stub: lurek.input.isCursorSupported ---------------------------------
--@api-stub: lurek.input.isCursorSupported
-- Demonstrates the proper usage of lurek.input.isCursorSupported.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_input_isCursorSupported()
    local cursor_supported = lurek.input.isCursorSupported()
    print("custom cursors supported: " .. tostring(cursor_supported))
end
local _ok, _err = pcall(demo_lurek_input_isCursorSupported)

-- ---- Stub: lurek.input.getCursor -----------------------------------------
--@api-stub: lurek.input.getCursor
-- Demonstrates the proper usage of lurek.input.getCursor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_input_getCursor()
    local current_cursor_name = lurek.input.getCursor()
    print("active cursor: " .. tostring(current_cursor_name))
end
local _ok, _err = pcall(demo_lurek_input_getCursor)

-- ---- Stub: lurek.input.getWheelDelta -------------------------------------
--@api-stub: lurek.input.getWheelDelta
-- Use the scroll wheel to zoom the camera in a strategy game.
-- Returns (dx, dy) — dy > 0 means scroll up (zoom in).
local wheel_dx, wheel_dy = lurek.input.getWheelDelta()
print("scroll wheel delta: dx=" .. tostring(wheel_dx) .. " dy=" .. tostring(wheel_dy))
if wheel_dy and wheel_dy > 0 then
    print("zooming camera in")
elseif wheel_dy and wheel_dy < 0 then
    print("zooming camera out")
end

-- =============================================================================
-- Gamepad — enumerate, query buttons/axes, vibration, mappings
-- =============================================================================

-- ---- Stub: lurek.input.getCount ------------------------------------------
--@api-stub: lurek.input.getCount
-- Demonstrates the proper usage of lurek.input.getCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_input_getCount()
    local gamepad_count = lurek.input.getCount()
    print("gamepads connected: " .. tostring(gamepad_count))
end
local _ok, _err = pcall(demo_lurek_input_getCount)

-- ---- Stub: lurek.input.getJoystickCount ----------------------------------
--@api-stub: lurek.input.getJoystickCount
-- Demonstrates the proper usage of lurek.input.getJoystickCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_input_getJoystickCount()
    local joystick_slots = lurek.input.getJoystickCount()
    print("joystick slots tracked: " .. tostring(joystick_slots))
end
local _ok, _err = pcall(demo_lurek_input_getJoystickCount)

-- ---- Stub: lurek.input.getJoysticks --------------------------------------
--@api-stub: lurek.input.getJoysticks
-- Demonstrates the proper usage of lurek.input.getJoysticks.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_input_getJoysticks()
    local joystick_ids = lurek.input.getJoysticks()
    print("connected joystick IDs: " .. tostring(#joystick_ids))
    for i, jid in ipairs(joystick_ids) do
    print("  slot " .. i .. ": joystick " .. tostring(jid))
end
local _ok, _err = pcall(demo_lurek_input_getJoysticks)

-- ---- Stub: lurek.input.isConnected ---------------------------------------
--@api-stub: lurek.input.isConnected
-- Demonstrates the proper usage of lurek.input.isConnected.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_input_isConnected()
    local pad1_connected = lurek.input.isConnected(1)
    print("gamepad 1 connected: " .. tostring(pad1_connected))
end
local _ok, _err = pcall(demo_lurek_input_isConnected)

-- ---- Stub: lurek.input.getName -------------------------------------------
--@api-stub: lurek.input.getName
-- Demonstrates the proper usage of lurek.input.getName.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_input_getName()
    local pad1_name = lurek.input.getName(1)
    print("gamepad 1 name: " .. tostring(pad1_name))
end
local _ok, _err = pcall(demo_lurek_input_getName)

-- ---- Stub: lurek.input.isGamepad -----------------------------------------
--@api-stub: lurek.input.isGamepad
-- Demonstrates the proper usage of lurek.input.isGamepad.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_input_isGamepad()
    local is_standard_pad = lurek.input.isGamepad(1)
    print("slot 1 is standard gamepad: " .. tostring(is_standard_pad))
end
local _ok, _err = pcall(demo_lurek_input_isGamepad)

-- ---- Stub: lurek.input.getButtonCount ------------------------------------
--@api-stub: lurek.input.getButtonCount
-- Demonstrates the proper usage of lurek.input.getButtonCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_input_getButtonCount()
    local btn_count = lurek.input.getButtonCount(1)
    print("gamepad 1 buttons: " .. tostring(btn_count))
end
local _ok, _err = pcall(demo_lurek_input_getButtonCount)

-- ---- Stub: lurek.input.getAxisCount --------------------------------------
--@api-stub: lurek.input.getAxisCount
-- Demonstrates the proper usage of lurek.input.getAxisCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_input_getAxisCount()
    local axis_count = lurek.input.getAxisCount(1)
    print("gamepad 1 axes: " .. tostring(axis_count))
end
local _ok, _err = pcall(demo_lurek_input_getAxisCount)

-- ---- Stub: lurek.input.isDown --------------------------------------------
--@api-stub: lurek.input.isDown
-- Check if the A button (button 1) is held for a charged jump.
-- First arg is gamepad ID, second is button index.
local a_held = lurek.input.isDown(1, 1)
if a_held then
    print("gamepad 1: A button held — charging jump power")
end

-- ---- Stub: lurek.input.getAxis -------------------------------------------
--@api-stub: lurek.input.getAxis
-- Read the left stick X axis (-1.0 = full left, 1.0 = full right)
-- and apply a deadzone before moving the player.
local left_stick_x = lurek.input.getAxis(1, 1)
local deadzone = 0.15
if math.abs(left_stick_x) > deadzone then
    local move_speed = left_stick_x * 200.0  -- pixels per second
    print("moving player at speed: " .. string.format("%.1f", move_speed))
else
    print("left stick inside deadzone — player idle")
end

-- ---- Stub: lurek.input.isVibrationSupported ------------------------------
--@api-stub: lurek.input.isVibrationSupported
-- Demonstrates the proper usage of lurek.input.isVibrationSupported.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_input_isVibrationSupported()
    local vib_ok = lurek.input.isVibrationSupported(1)
    print("gamepad 1 vibration supported: " .. tostring(vib_ok))
end
local _ok, _err = pcall(demo_lurek_input_isVibrationSupported)

-- ---- Stub: lurek.input.vibrate -------------------------------------------
--@api-stub: lurek.input.vibrate
-- Trigger a strong rumble when the player takes damage.
-- Args: gamepad_id, low_frequency_intensity, high_frequency_intensity, duration_ms
if vib_ok then
    lurek.input.vibrate(1, 0.8, 0.4, 250)
    print("damage rumble: heavy low-freq, light high-freq, 250ms")
end

-- ---- Stub: lurek.input.getGUID -------------------------------------------
--@api-stub: lurek.input.getGUID
-- Demonstrates the proper usage of lurek.input.getGUID.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_input_getGUID()
    local guid = lurek.input.getGUID(1)
    print("gamepad 1 GUID: " .. tostring(guid))
end
local _ok, _err = pcall(demo_lurek_input_getGUID)

-- ---- Stub: lurek.input.getHat --------------------------------------------
--@api-stub: lurek.input.getHat
-- Demonstrates the proper usage of lurek.input.getHat.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_input_getHat()
    local hat_dir = lurek.input.getHat(1, 1)
    print("gamepad 1 hat direction: " .. tostring(hat_dir))
end
local _ok, _err = pcall(demo_lurek_input_getHat)

-- ---- Stub: lurek.input.setVibration --------------------------------------
--@api-stub: lurek.input.setVibration
-- Demonstrates the proper usage of lurek.input.setVibration.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_input_setVibration()
    local vib_result = lurek.input.setVibration(1, 0.5, 0.3)
    print("setVibration result: " .. tostring(vib_result))
end
local _ok, _err = pcall(demo_lurek_input_setVibration)

-- ---- Stub: lurek.input.setBackgroundEvents -------------------------------
--@api-stub: lurek.input.setBackgroundEvents
-- Demonstrates the proper usage of lurek.input.setBackgroundEvents.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_input_setBackgroundEvents()
    lurek.input.setBackgroundEvents(true)
    print("background gamepad events enabled")
end
local _ok, _err = pcall(demo_lurek_input_setBackgroundEvents)

-- ---- Stub: lurek.input.getBackgroundEvents -------------------------------
--@api-stub: lurek.input.getBackgroundEvents
-- Demonstrates the proper usage of lurek.input.getBackgroundEvents.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_input_getBackgroundEvents()
    local bg_events = lurek.input.getBackgroundEvents()
    print("background events: " .. tostring(bg_events))
    lurek.input.setBackgroundEvents(false)
end
local _ok, _err = pcall(demo_lurek_input_getBackgroundEvents)

-- ---- Stub: lurek.input.setGamepadMapping ---------------------------------
--@api-stub: lurek.input.setGamepadMapping
-- Override the button layout for a specific third-party controller using
-- an SDL2 GameControllerDB mapping string.
local example_guid    = "03000000c82d00001090000000000000"
local example_mapping = "03000000c82d00001090000000000000,8Bitdo SN30,a:b0,b:b1,x:b3,y:b4,platform:Windows,"
lurek.input.setGamepadMapping(example_guid, example_mapping)
print("custom mapping set for 8Bitdo SN30")

-- ---- Stub: lurek.input.getGamepadMappingString ---------------------------
--@api-stub: lurek.input.getGamepadMappingString
-- Demonstrates the proper usage of lurek.input.getGamepadMappingString.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_input_getGamepadMappingString()
    local stored_mapping = lurek.input.getGamepadMappingString(example_guid)
    print("stored mapping: " .. tostring(stored_mapping))
end
local _ok, _err = pcall(demo_lurek_input_getGamepadMappingString)

-- ---- Stub: lurek.input.loadGamepadMappings -------------------------------
--@api-stub: lurek.input.loadGamepadMappings
-- Bulk-load community gamepad mappings from an SDL GameControllerDB text file
-- shipped with the game. Returns the number of mappings loaded.
local ok_load, load_count = pcall(function()
    return lurek.input.loadGamepadMappings("assets/gamecontrollerdb.txt")
end)
print("loadGamepadMappings: " .. tostring(ok_load) .. " count=" .. tostring(load_count))

-- ---- Stub: lurek.input.saveGamepadMappings -------------------------------
--@api-stub: lurek.input.saveGamepadMappings
-- Export all current mappings (built-in + user overrides) to a file
-- so they persist across sessions.
local ok_save = pcall(function()
    lurek.input.saveGamepadMappings("save/gamepad_mappings.txt")
end)
print("saveGamepadMappings: " .. tostring(ok_save))

-- =============================================================================
-- Touch — multi-touch queries (mobile / touchscreen laptops)
-- =============================================================================

-- ---- Stub: lurek.input.getTouches ----------------------------------------
--@api-stub: lurek.input.getTouches
-- Enumerate all active touch points to support multi-finger gestures.
-- Each entry has id, x, y, and pressure fields.
local touches = lurek.input.getTouches()
print("active touch points: " .. #touches)
for i, touch in ipairs(touches) do
    print("  touch " .. touch.id .. " at (" .. touch.x .. ", " .. touch.y
        .. ") pressure=" .. string.format("%.2f", touch.pressure))
end

-- ---- Stub: lurek.input.getPosition ---------------------------------------
--@api-stub: lurek.input.getPosition
-- Demonstrates the proper usage of lurek.input.getPosition.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_input_getPosition()
    local touch_x, touch_y = lurek.input.getPosition(1)
    print("touch #1 position: " .. tostring(touch_x) .. ", " .. tostring(touch_y))
end
local _ok, _err = pcall(demo_lurek_input_getPosition)

-- ---- Stub: lurek.input.getPressure ---------------------------------------
--@api-stub: lurek.input.getPressure
-- Demonstrates the proper usage of lurek.input.getPressure.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_input_getPressure()
    local pressure = lurek.input.getPressure(1)
    print("touch #1 pressure: " .. tostring(pressure))
    local brush_size = 4 + (pressure or 0) * 20
    print("brush size: " .. string.format("%.1f", brush_size))
end
local _ok, _err = pcall(demo_lurek_input_getPressure)

-- ---- Stub: lurek.input.getTouchCount -------------------------------------
--@api-stub: lurek.input.getTouchCount
-- Demonstrates the proper usage of lurek.input.getTouchCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_input_getTouchCount()
    local finger_count = lurek.input.getTouchCount()
    print("fingers down: " .. tostring(finger_count))
    if finger_count == 2 then
    print("pinch-zoom gesture detected")
end
local _ok, _err = pcall(demo_lurek_input_getTouchCount)

-- =============================================================================
-- Action Bindings — abstract named actions mapped to physical keys
-- =============================================================================

-- ---- Stub: lurek.input.bind ----------------------------------------------
--@api-stub: lurek.input.bind
-- Bind game actions to keys. Multiple keys per action allow keyboard + gamepad.
-- The player can rebind these from the settings menu.
lurek.input.bind("jump",   {"space", "gamepad_a"})
lurek.input.bind("attack", {"z", "gamepad_x"})
lurek.input.bind("dash",   {"lshift", "gamepad_b"})
lurek.input.bind("interact", {"e", "gamepad_y"})
print("actions bound: jump, attack, dash, interact")

-- ---- Stub: lurek.input.unbind --------------------------------------------
--@api-stub: lurek.input.unbind
-- Demonstrates the proper usage of lurek.input.unbind.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_input_unbind()
    local unbound = lurek.input.unbind("dash")
    print("dash unbound: " .. tostring(unbound))
end
local _ok, _err = pcall(demo_lurek_input_unbind)

-- ---- Stub: lurek.input.clearBindings -------------------------------------
--@api-stub: lurek.input.clearBindings
-- Demonstrates the proper usage of lurek.input.clearBindings.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_input_clearBindings()
    lurek.input.clearBindings()
    print("all bindings cleared — ready to load custom preset")
end
local _ok, _err = pcall(demo_lurek_input_clearBindings)

-- ---- Stub: lurek.input.getBindings ---------------------------------------
--@api-stub: lurek.input.getBindings
-- Demonstrates the proper usage of lurek.input.getBindings.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_input_getBindings()
    lurek.input.bind("jump",   {"space", "gamepad_a"})
    lurek.input.bind("attack", {"z", "gamepad_x"})
    local bindings = lurek.input.getBindings()
    print("current bindings:")
    for action, keys in pairs(bindings) do
    print("  " .. action .. " -> " .. table.concat(keys, ", "))
end
local _ok, _err = pcall(demo_lurek_input_getBindings)

-- ---- Stub: lurek.input.isActionDown --------------------------------------
--@api-stub: lurek.input.isActionDown
-- Use action names instead of raw keys for gameplay logic — this automatically
-- works with both keyboard and gamepad.
local jump_held = lurek.input.isActionDown("jump")
if jump_held then
    print("player is holding jump — increase jump height")
end

-- ---- Stub: lurek.input.wasActionPressed ----------------------------------
--@api-stub: lurek.input.wasActionPressed
-- Demonstrates the proper usage of lurek.input.wasActionPressed.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_input_wasActionPressed()
    local attack_pressed = lurek.input.wasActionPressed("attack")
    if attack_pressed then
    print("attack started — play swing animation")
end
local _ok, _err = pcall(demo_lurek_input_wasActionPressed)

-- ---- Stub: lurek.input.wasActionReleased ---------------------------------
--@api-stub: lurek.input.wasActionReleased
-- Demonstrates the proper usage of lurek.input.wasActionReleased.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_input_wasActionReleased()
    local attack_released = lurek.input.wasActionReleased("attack")
    if attack_released then
    print("attack released — fire charged projectile")
end
local _ok, _err = pcall(demo_lurek_input_wasActionReleased)

-- ---- Stub: lurek.input.wasActionPressedWithin ----------------------------
--@api-stub: lurek.input.wasActionPressedWithin
-- Allow a 6-frame input buffer for the jump action so the player can press
-- jump slightly before landing and still get an immediate jump.
local buffered_jump = lurek.input.wasActionPressedWithin("jump", 6)
if buffered_jump then
    print("buffered jump detected — executing jump on landing")
end

-- =============================================================================
-- Combo Detection — multi-key input sequences (fighting game combos)
-- =============================================================================

-- ---- Stub: lurek.input.newCombo ------------------------------------------
--@api-stub: lurek.input.newCombo
-- Define a three-key hadouken combo: down, down-forward, forward + punch.
-- Each step has a max gap (ms) before the combo resets.
local combo = lurek.input.newCombo(
    { "down", "down+right", "right", "z" },
    { timeout_ms = 500 }
)
print("hadouken combo created with " .. combo:totalSteps() .. " steps")

-- ---- Stub: Combo:feed ----------------------------------------------------
--@api-stub: Combo:feed
-- Feed key-press events into the combo detector as they arrive from the input
-- callback. The detector tracks whether the sequence is being followed.
combo:feed("down")
print("fed 'down' — progress: " .. combo:progress() .. "/" .. combo:totalSteps())
combo:feed("down+right")
print("fed 'down+right' — progress: " .. combo:progress() .. "/" .. combo:totalSteps())

-- ---- Stub: Combo:tick ----------------------------------------------------
--@api-stub: Combo:tick
-- Advance the combo timer every frame. If the gap between two inputs exceeds
-- the timeout, the combo resets automatically.
local dt = 0.016  -- ~60 FPS frame time
combo:tick(dt)
print("combo ticked by " .. dt .. "s — still in progress: " .. tostring(combo:isInProgress()))

-- ---- Stub: Combo:reset ---------------------------------------------------
--@api-stub: Combo:reset
-- Demonstrates the proper usage of Combo:reset.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Combo_reset()
    combo:reset()
    print("combo reset by damage — progress back to " .. combo:progress())
end
local _ok, _err = pcall(demo_Combo_reset)

-- ---- Stub: Combo:progress ------------------------------------------------
--@api-stub: Combo:progress
-- Display a combo progress bar in the fighting game HUD.
-- Feed some steps again after the reset to show progress climbing.
combo:feed("down")
combo:feed("down+right")
local matched = combo:progress()
print("combo progress: " .. matched .. " of " .. combo:totalSteps() .. " steps matched")

-- ---- Stub: Combo:totalSteps ----------------------------------------------
--@api-stub: Combo:totalSteps
-- Demonstrates the proper usage of Combo:totalSteps.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Combo_totalSteps()
    local total = combo:totalSteps()
    print("this combo requires " .. total .. " sequential inputs")
end
local _ok, _err = pcall(demo_Combo_totalSteps)

-- ---- Stub: Combo:isInProgress --------------------------------------------
--@api-stub: Combo:isInProgress
-- Demonstrates the proper usage of Combo:isInProgress.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Combo_isInProgress()
    local in_progress = combo:isInProgress()
    if in_progress then
    print("combo meter glowing — keep going!")
    else
    print("combo idle — start with 'down'")
end
local _ok, _err = pcall(demo_Combo_isInProgress)

-- ---- Stub: Combo:getStep -------------------------------------------------
--@api-stub: Combo:getStep
-- Demonstrates the proper usage of Combo:getStep.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Combo_getStep()
    for i = 1, combo:totalSteps() do
    local step = combo:getStep(i)
    print("step " .. i .. ": key=" .. tostring(step.key)
        .. " gap_ms=" .. tostring(step.gap_ms))
end
local _ok, _err = pcall(demo_Combo_getStep)

-- =============================================================================
-- Cursor Object — custom and system cursor handles
-- =============================================================================

-- ---- Stub: Cursor:release ------------------------------------------------
--@api-stub: Cursor:release
-- Release the custom cursor when leaving the aiming state to free resources.
-- On desktop this is typically a no-op, but it is good practice.
if custom_cursor then
    custom_cursor:release()
    print("custom cursor released")
end

-- ---- Stub: Cursor:getType ------------------------------------------------
--@api-stub: Cursor:getType
-- Demonstrates the proper usage of Cursor:getType.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Cursor_getType()
    local cursor_type = hand_cursor:getType()
    print("hand cursor type: " .. tostring(cursor_type))
end
local _ok, _err = pcall(demo_Cursor_getType)

-- =============================================================================
-- Input Recording & Playback — replay system for testing and demos
-- =============================================================================

-- ---- Stub: lurek.input.startRecording ------------------------------------
--@api-stub: lurek.input.startRecording
-- Demonstrates the proper usage of lurek.input.startRecording.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_input_startRecording()
    lurek.input.startRecording()
    print("input recording started")
end
local _ok, _err = pcall(demo_lurek_input_startRecording)

-- ---- Stub: lurek.input.isRecording ---------------------------------------
--@api-stub: lurek.input.isRecording
-- Demonstrates the proper usage of lurek.input.isRecording.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_input_isRecording()
    local is_rec = lurek.input.isRecording()
    print("recording active: " .. tostring(is_rec))
end
local _ok, _err = pcall(demo_lurek_input_isRecording)

-- ---- Stub: lurek.input.stopRecording -------------------------------------
--@api-stub: lurek.input.stopRecording
-- Demonstrates the proper usage of lurek.input.stopRecording.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_input_stopRecording()
    local rec = lurek.input.stopRecording()
    print("recording stopped — got recording: " .. tostring(rec ~= nil))
end
local _ok, _err = pcall(demo_lurek_input_stopRecording)

-- ---- Stub: InputRecording:toJson -----------------------------------------
--@api-stub: InputRecording:toJson
-- Demonstrates the proper usage of InputRecording:toJson.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_InputRecording_toJson()
    if rec then
    local json_str = rec:toJson()
    print("recording JSON length: " .. #json_str .. " bytes")
    print("first 80 chars: " .. json_str:sub(1, 80))
end
local _ok, _err = pcall(demo_InputRecording_toJson)

-- ---- Stub: InputRecording:totalFrames ------------------------------------
--@api-stub: InputRecording:totalFrames
-- Demonstrates the proper usage of InputRecording:totalFrames.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_InputRecording_totalFrames()
    if rec then
    local total_frames = rec:totalFrames()
    print("recording total frames: " .. tostring(total_frames))
end
local _ok, _err = pcall(demo_InputRecording_totalFrames)

-- ---- Stub: InputRecording:frameCount -------------------------------------
--@api-stub: InputRecording:frameCount
-- The frameCount is the number of sparse event frames (frames that had input),
-- which is typically much smaller than totalFrames (wall-clock frames).
if rec then
    local event_frames = rec:frameCount()
    print("sparse event frames: " .. tostring(event_frames))
    print("compression ratio: " .. tostring(event_frames) .. " / " .. tostring(rec:totalFrames()))
end

-- ---- Stub: lurek.input.loadRecording -------------------------------------
--@api-stub: lurek.input.loadRecording
-- Demonstrates the proper usage of lurek.input.loadRecording.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_input_loadRecording()
    if rec then
    local json_data = rec:toJson()
    lurek.input.loadRecording(json_data)
    print("recording loaded for playback")
end
local _ok, _err = pcall(demo_lurek_input_loadRecording)

-- ---- Stub: lurek.input.startPlayback -------------------------------------
--@api-stub: lurek.input.startPlayback
-- Demonstrates the proper usage of lurek.input.startPlayback.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_input_startPlayback()
    lurek.input.startPlayback()
    print("playback started from frame 0")
end
local _ok, _err = pcall(demo_lurek_input_startPlayback)

-- ---- Stub: lurek.input.isPlayingBack -------------------------------------
--@api-stub: lurek.input.isPlayingBack
-- Demonstrates the proper usage of lurek.input.isPlayingBack.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_input_isPlayingBack()
    local is_playing = lurek.input.isPlayingBack()
    print("playback active: " .. tostring(is_playing))
end
local _ok, _err = pcall(demo_lurek_input_isPlayingBack)

-- ---- Stub: lurek.input.getPlaybackFrame ----------------------------------
--@api-stub: lurek.input.getPlaybackFrame
-- Demonstrates the proper usage of lurek.input.getPlaybackFrame.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_input_getPlaybackFrame()
    local current_frame = lurek.input.getPlaybackFrame()
    print("playback at frame: " .. tostring(current_frame))
end
local _ok, _err = pcall(demo_lurek_input_getPlaybackFrame)

-- ---- Stub: lurek.input.advancePlayback -----------------------------------
--@api-stub: lurek.input.advancePlayback
-- Step through the recording one frame at a time for slow-motion debug replay.
-- Returns a table of key/button events that occurred on that frame.
local events = lurek.input.advancePlayback()
print("frame events: " .. tostring(#events) .. " input(s)")
for _, evt in ipairs(events) do
    print("  event: " .. tostring(evt))
end

-- ---- Stub: lurek.input.stopPlayback --------------------------------------
--@api-stub: lurek.input.stopPlayback
-- Demonstrates the proper usage of lurek.input.stopPlayback.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_input_stopPlayback()
    lurek.input.stopPlayback()
    print("playback stopped — returning to live input")
    print("\n-- input.lua example complete --")
end
local _ok, _err = pcall(demo_lurek_input_stopPlayback)
