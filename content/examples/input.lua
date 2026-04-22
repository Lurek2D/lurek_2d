-- content/examples/input.lua
-- love2d-style usage snippets for the lurek.input API (80 items).
-- Each --@api-stub: block is a copy-pastable snippet showing the API
-- in real context (callbacks, conditionals, real arg values).
-- Run: cargo run -- content/examples/input.lua

-- ── lurek.input.* functions ──

--@api-stub: lurek.input.isDown
-- Returns true if any of the given keys is currently held down.
-- Use as a guard inside lurek.update or event handlers.
if lurek.input.isDown({ x = 0, y = 0 }) then
  print("isDown -> true")
end

--@api-stub: lurek.input.isScancodeDown
-- Returns whether the key with the given scancode is held.
-- Use as a guard inside lurek.update or event handlers.
if lurek.input.isScancodeDown(scancode) then
  print("isScancodeDown -> true")
end

--@api-stub: lurek.input.setKeyRepeat
-- Enables or disables key-repeat events.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.input.setKeyRepeat(enabled)
print("setKeyRepeat applied")
print("ok")

--@api-stub: lurek.input.hasKeyRepeat
-- Returns whether key-repeat is currently enabled.
-- Use as a guard inside lurek.update or event handlers.
if lurek.input.hasKeyRepeat() then
  print("hasKeyRepeat -> true")
end

--@api-stub: lurek.input.setTextInput
-- Enables or disables Unicode text input mode.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.input.setTextInput(enabled)
print("setTextInput applied")
print("ok")

--@api-stub: lurek.input.hasTextInput
-- Returns whether text input mode is currently active.
-- Use as a guard inside lurek.update or event handlers.
if lurek.input.hasTextInput() then
  print("hasTextInput -> true")
end

--@api-stub: lurek.input.getScancodeFromKey
-- Returns the hardware scancode for the given key name.
-- Cheap to call; safe inside callbacks.
local value = lurek.input.getScancodeFromKey("space")
print("getScancodeFromKey:", value)
return value

--@api-stub: lurek.input.getKeyFromScancode
-- Returns the key name for the given hardware scancode.
-- Cheap to call; safe inside callbacks.
local value = lurek.input.getKeyFromScancode(scancode)
print("getKeyFromScancode:", value)
return value

--@api-stub: lurek.input.isModifierActive
-- Returns whether the named modifier key is currently held.
-- Use as a guard inside lurek.update or event handlers.
if lurek.input.isModifierActive(modifier) then
  print("isModifierActive -> true")
end

--@api-stub: lurek.input.getPosition
-- Returns the current cursor position as (x, y).
-- Cheap to call; safe inside callbacks.
local value = lurek.input.getPosition()
print("getPosition:", value)
return value

--@api-stub: lurek.input.getX
-- Returns the current mouse X position in window coordinates.
-- Cheap to call; safe inside callbacks.
local value = lurek.input.getX()
print("getX:", value)
return value

--@api-stub: lurek.input.getY
-- Returns the current mouse Y position in window coordinates.
-- Cheap to call; safe inside callbacks.
local value = lurek.input.getY()
print("getY:", value)
return value

--@api-stub: lurek.input.isDown
-- Returns whether the given mouse button is currently held down.
-- Use as a guard inside lurek.update or event handlers.
if lurek.input.isDown("left") then
  print("isDown -> true")
end

--@api-stub: lurek.input.setVisible
-- Shows or hides the operating-system mouse cursor.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.input.setVisible(visible)
print("setVisible applied")
print("ok")

--@api-stub: lurek.input.isVisible
-- Returns whether the mouse cursor is currently visible.
-- Use as a guard inside lurek.update or event handlers.
if lurek.input.isVisible() then
  print("isVisible -> true")
end

--@api-stub: lurek.input.setGrabbed
-- Locks or unlocks the mouse cursor to the window.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.input.setGrabbed(grabbed)
print("setGrabbed applied")
print("ok")

--@api-stub: lurek.input.isGrabbed
-- Returns whether the mouse cursor is locked to the window.
-- Use as a guard inside lurek.update or event handlers.
if lurek.input.isGrabbed() then
  print("isGrabbed -> true")
end

--@api-stub: lurek.input.setRelativeMode
-- Enables or disables raw relative mouse motion mode.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.input.setRelativeMode(relative)
print("setRelativeMode applied")
print("ok")

--@api-stub: lurek.input.getRelativeMode
-- Returns whether relative mouse mode is active.
-- Cheap to call; safe inside callbacks.
local value = lurek.input.getRelativeMode()
print("getRelativeMode:", value)
return value

--@api-stub: lurek.input.setPosition
-- Moves the mouse cursor to the given window-space position.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.input.setPosition(100, 100)
print("setPosition applied")
print("ok")

--@api-stub: lurek.input.setCursor
-- Sets the active mouse cursor from a Cursor handle, name string, or nil to reset.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.input.setCursor(cursor_val)
print("setCursor applied")
print("ok")

--@api-stub: lurek.input.newCursor
-- Creates a custom mouse cursor from RGBA pixel data.
-- Build once at startup; reuse across frames.
local cursor = lurek.input.newCursor()
print("created", cursor)
return cursor

--@api-stub: lurek.input.getSystemCursor
-- Returns a system cursor object for the named cursor shape.
-- Cheap to call; safe inside callbacks.
local value = lurek.input.getSystemCursor("main")
print("getSystemCursor:", value)
return value

--@api-stub: lurek.input.isCursorSupported
-- Returns whether cursor customisation is supported on this platform.
-- Use as a guard inside lurek.update or event handlers.
if lurek.input.isCursorSupported() then
  print("isCursorSupported -> true")
end

--@api-stub: lurek.input.getCursor
-- Returns the name of the currently active system cursor.
-- Cheap to call; safe inside callbacks.
local value = lurek.input.getCursor()
print("getCursor:", value)
return value

--@api-stub: lurek.input.getWheelDelta
-- Returns the mouse scroll wheel delta (dx, dy) since last frame.
-- Cheap to call; safe inside callbacks.
local value = lurek.input.getWheelDelta()
print("getWheelDelta:", value)
return value

--@api-stub: lurek.input.getCount
-- Returns the number of connected gamepads.
-- Cheap to call; safe inside callbacks.
local value = lurek.input.getCount()
print("getCount:", value)
return value

--@api-stub: lurek.input.getJoystickCount
-- Returns the number of tracked gamepad slots.
-- Cheap to call; safe inside callbacks.
local value = lurek.input.getJoystickCount()
print("getJoystickCount:", value)
return value

--@api-stub: lurek.input.getJoysticks
-- Returns a list of connected gamepad IDs.
-- Cheap to call; safe inside callbacks.
local value = lurek.input.getJoysticks()
print("getJoysticks:", value)
return value

--@api-stub: lurek.input.isConnected
-- Returns whether the gamepad with the given ID is connected.
-- Use as a guard inside lurek.update or event handlers.
if lurek.input.isConnected(1) then
  print("isConnected -> true")
end

--@api-stub: lurek.input.getName
-- Returns the human-readable name of a gamepad.
-- Cheap to call; safe inside callbacks.
local value = lurek.input.getName(1)
print("getName:", value)
return value

--@api-stub: lurek.input.isGamepad
-- Returns whether the joystick at the given slot is a recognized gamepad.
-- Place inside `function lurek.update(dt) ... end`.
function lurek.update(dt)
  lurek.input.isGamepad(1)
end

--@api-stub: lurek.input.getButtonCount
-- Returns the total number of buttons on the gamepad.
-- Cheap to call; safe inside callbacks.
local value = lurek.input.getButtonCount(1)
print("getButtonCount:", value)
return value

--@api-stub: lurek.input.getAxisCount
-- Returns the total number of analog axes on the gamepad.
-- Place inside `function lurek.update(dt) ... end`.
function lurek.update(dt)
  lurek.input.getAxisCount(1)
end

--@api-stub: lurek.input.isDown
-- Returns whether the given button on the gamepad is currently held.
-- Use as a guard inside lurek.update or event handlers.
if lurek.input.isDown(1, "left") then
  print("isDown -> true")
end

--@api-stub: lurek.input.getAxis
-- Returns the current value (-1 to 1) of a gamepad analog axis.
-- Place inside `function lurek.update(dt) ... end`.
function lurek.update(dt)
  local ax = lurek.input.getAxis("leftx")
  player.vx = ax * 200
end

--@api-stub: lurek.input.isVibrationSupported
-- Returns whether the gamepad supports haptic vibration.
-- Use as a guard inside lurek.update or event handlers.
if lurek.input.isVibrationSupported(1) then
  print("isVibrationSupported -> true")
end

--@api-stub: lurek.input.vibrate
-- Requests haptic vibration on a gamepad.
-- See the module spec for detailed semantics.
local result = lurek.input.vibrate(1, low_freq, high_freq, duration_ms)
print("vibrate:", result)
return result

--@api-stub: lurek.input.getGUID
-- Returns the hardware GUID string of the gamepad.
-- Cheap to call; safe inside callbacks.
local value = lurek.input.getGUID(1)
print("getGUID:", value)
return value

--@api-stub: lurek.input.getHat
-- Returns the direction string of a hat switch on the gamepad.
-- Cheap to call; safe inside callbacks.
local value = lurek.input.getHat(1, hat)
print("getHat:", value)
return value

--@api-stub: lurek.input.setVibration
-- Triggers haptic rumble (currently a no-op stub).
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.input.setVibration({ x = 0, y = 0 })
print("setVibration applied")
print("ok")

--@api-stub: lurek.input.setBackgroundEvents
-- Enable or disable receiving gamepad events when the window is not focused.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.input.setBackgroundEvents(enable)
print("setBackgroundEvents applied")
print("ok")

--@api-stub: lurek.input.getBackgroundEvents
-- Returns whether background gamepad events are enabled.
-- Cheap to call; safe inside callbacks.
local value = lurek.input.getBackgroundEvents()
print("getBackgroundEvents:", value)
return value

--@api-stub: lurek.input.setGamepadMapping
-- Stores or replaces the SDL2 GameControllerDB mapping string for the given GUID.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.input.setGamepadMapping(1, mapping)
print("setGamepadMapping applied")
print("ok")

--@api-stub: lurek.input.getGamepadMappingString
-- Returns the stored mapping string for the given GUID, or nil.
-- Cheap to call; safe inside callbacks.
local value = lurek.input.getGamepadMappingString(1)
print("getGamepadMappingString:", value)
return value

--@api-stub: lurek.input.loadGamepadMappings
-- Loads SDL2 GameControllerDB-format mappings from a file.
-- May block — call from a worker thread for large payloads.
local result = lurek.input.loadGamepadMappings("data/file.txt")
-- may block; consider lurek.thread for large payloads
print("loadGamepadMappings:", result)
print("ok")

--@api-stub: lurek.input.saveGamepadMappings
-- Saves all stored gamepad mappings to a plain-text file.
-- May block — call from a worker thread for large payloads.
local result = lurek.input.saveGamepadMappings("data/file.txt")
-- may block; consider lurek.thread for large payloads
print("saveGamepadMappings:", result)
print("ok")

--@api-stub: lurek.input.getTouches
-- Returns a table of active touch points with id, x, y, and pressure fields.
-- Cheap to call; safe inside callbacks.
local value = lurek.input.getTouches()
print("getTouches:", value)
return value

--@api-stub: lurek.input.getPosition
-- Returns the position (x, y) of the touch with the given ID.
-- Cheap to call; safe inside callbacks.
local value = lurek.input.getPosition(1)
print("getPosition:", value)
return value

--@api-stub: lurek.input.getPressure
-- Returns the pressure (0-1) of the touch with the given ID.
-- Cheap to call; safe inside callbacks.
local value = lurek.input.getPressure(1)
print("getPressure:", value)
return value

--@api-stub: lurek.input.getTouchCount
-- Returns the number of currently active touch points.
-- Cheap to call; safe inside callbacks.
local value = lurek.input.getTouchCount()
print("getTouchCount:", value)
return value

--@api-stub: lurek.input.bind
-- Maps an action name to one or more key/button names.
-- Side-effecting; safe to call any time after init.
lurek.input.bind(action, keys)
-- mutator; side effect applied
print("bind done")
print("ok")

--@api-stub: lurek.input.unbind
-- Removes all key bindings for the given action name.
-- Pair with the matching constructor to free resources.
-- release the resource and forget the handle
lurek.input.unbind(action)
print("unbind done")
print("ok")

--@api-stub: lurek.input.clearBindings
-- Removes all action bindings.
-- Pair with the matching constructor to free resources.
-- release the resource and forget the handle
lurek.input.clearBindings()
print("clearBindings done")
print("ok")

--@api-stub: lurek.input.getBindings
-- Returns a table mapping each action name to its bound keys.
-- Cheap to call; safe inside callbacks.
local value = lurek.input.getBindings()
print("getBindings:", value)
return value

--@api-stub: lurek.input.isActionDown
-- Returns true if any key bound to the action is currently held down.
-- Use as a guard inside lurek.update or event handlers.
if lurek.input.isActionDown(action) then
  print("isActionDown -> true")
end

--@api-stub: lurek.input.wasActionPressed
-- Returns true if any key bound to the action was pressed this frame.
-- See the module spec for detailed semantics.
local result = lurek.input.wasActionPressed(action)
print("wasActionPressed:", result)
return result

--@api-stub: lurek.input.wasActionReleased
-- Returns true if any key bound to the action was released this frame.
-- See the module spec for detailed semantics.
local result = lurek.input.wasActionReleased(action)
print("wasActionReleased:", result)
return result

--@api-stub: lurek.input.wasActionPressedWithin
-- Was action pressed within.
-- See the module spec for detailed semantics.
local result = lurek.input.wasActionPressedWithin(action, frames)
print("wasActionPressedWithin:", result)
return result

--@api-stub: lurek.input.newCombo
-- Creates a new combo detector from an ordered list of steps.
-- Build once at startup; reuse across frames.
local combo = lurek.input.newCombo(steps_val, { x = 0, y = 0 })
print("created", combo)
return combo

--@api-stub: lurek.input.startRecording
-- Starts capturing input events frame-by-frame.
-- Trigger from input, timers, or game events.
-- trigger from input or timer
lurek.input.startRecording()
print("startRecording fired")
print("ok")

--@api-stub: lurek.input.stopRecording
-- Stops recording and returns an `InputRecording` userdata, or nil if not recording.
-- Trigger from input, timers, or game events.
-- trigger from input or timer
lurek.input.stopRecording()
print("stopRecording fired")
print("ok")

--@api-stub: lurek.input.loadRecording
-- Loads a JSON-encoded recording string for playback.
-- May block — call from a worker thread for large payloads.
local result = lurek.input.loadRecording(json)
-- may block; consider lurek.thread for large payloads
print("loadRecording:", result)
print("ok")

--@api-stub: lurek.input.startPlayback
-- Starts playback from the beginning of the loaded recording.
-- Trigger from input, timers, or game events.
-- trigger from input or timer
lurek.input.startPlayback()
print("startPlayback fired")
print("ok")

--@api-stub: lurek.input.stopPlayback
-- Stops playback immediately.
-- Trigger from input, timers, or game events.
-- trigger from input or timer
lurek.input.stopPlayback()
print("stopPlayback fired")
print("ok")

--@api-stub: lurek.input.isRecording
-- Returns true if input recording is currently active.
-- Use as a guard inside lurek.update or event handlers.
if lurek.input.isRecording() then
  print("isRecording -> true")
end

--@api-stub: lurek.input.isPlayingBack
-- Returns true if input playback is currently active.
-- Use as a guard inside lurek.update or event handlers.
if lurek.input.isPlayingBack() then
  print("isPlayingBack -> true")
end

--@api-stub: lurek.input.getPlaybackFrame
-- Returns the current playback frame index (0-based).
-- Cheap to call; safe inside callbacks.
local value = lurek.input.getPlaybackFrame()
print("getPlaybackFrame:", value)
return value

--@api-stub: lurek.input.advancePlayback
-- Advances playback by one frame and returns an array of key/button events for that.
-- See the module spec for detailed semantics.
local result = lurek.input.advancePlayback()
print("advancePlayback:", result)
return result

-- ── Cursor methods ──

--@api-stub: Cursor:release
-- Releases the cursor resource (no-op on desktop).
-- See the module spec for detailed semantics.
local cursor = lurek.input.newCursor()
cursor:release()
print("Cursor:release done")

--@api-stub: Cursor:getType
-- Returns the cursor type as "system" or "custom".
-- Cheap to call; safe inside callbacks.
local cursor = lurek.input.newCursor()  -- or your existing handle
local value = cursor:getType()
print("Cursor:getType ->", value)

-- ── Combo methods ──

--@api-stub: Combo:feed
-- Feed a key-press event into the combo detector.
-- See the module spec for detailed semantics.
local combo = lurek.input.newCombo()
combo:feed("space")
print("Combo:feed done")

--@api-stub: Combo:tick
-- Advance the internal clock by `dt` seconds and check for timeouts.
-- Trigger from input, timers, or game events.
local combo = lurek.input.newCombo()
combo:tick(dt)
-- trigger from input, timer, or event
print("ok")

--@api-stub: Combo:reset
-- Reset the detector to its initial idle state, cancelling any in-progress sequence.
-- Pair with the matching constructor to free resources.
local combo = lurek.input.newCombo()
combo:reset()
-- combo is now released
print("ok")

--@api-stub: Combo:totalSteps
-- Returns the total number of steps in the combo sequence.
-- See the module spec for detailed semantics.
local combo = lurek.input.newCombo()
combo:totalSteps()
print("Combo:totalSteps done")

--@api-stub: Combo:isInProgress
-- Returns true if the detector is currently mid-sequence.
-- Use as a guard inside lurek.update or event handlers.
local combo = lurek.input.newCombo()
if combo:isInProgress() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Combo:getStep
-- Returns the step at the given 1-based index as `{key=..., gap_ms=...}`.
-- Cheap to call; safe inside callbacks.
local combo = lurek.input.newCombo()  -- or your existing handle
local value = combo:getStep(1)
print("Combo:getStep ->", value)

-- ── InputRecording methods ──

--@api-stub: InputRecording:toJson
-- Serializes this recording to a JSON string for saving to disk.
-- See the module spec for detailed semantics.
local inputRecording = lurek.input.newInputRecording()
inputRecording:toJson()
print("InputRecording:toJson done")

--@api-stub: InputRecording:totalFrames
-- Returns the total frame count when recording was stopped.
-- See the module spec for detailed semantics.
local inputRecording = lurek.input.newInputRecording()
inputRecording:totalFrames()
print("InputRecording:totalFrames done")

--@api-stub: InputRecording:frameCount
-- Returns the number of sparse event frames stored in this recording.
-- See the module spec for detailed semantics.
local inputRecording = lurek.input.newInputRecording()
inputRecording:frameCount()
print("InputRecording:frameCount done")

