# input

## TL;DR

- The `input` module is a core Platform Services tier component that aggregates and processes hardware inputs across keyboard, mouse, gamepad, and multi-touch devices.

## General Info

- Module group: `Platform Services`
- Source path: `src/input/`
- Lua API path(s): `src/lua_api/input_api.rs`
- Primary Lua namespace: `lurek.input`
- Rust test path(s): tests/rust/unit/input_tests.rs
- Lua test path(s): tests/lua/unit/test_input.lua, tests/lua/integration/test_input_camera.lua

## Summary

Functioning as a translation layer between the winit OS event loop and the game logic, it provides frame-perfect state tracking and querying. The `KeyboardState` system accurately monitors key-down, key-up, just-pressed, and just-released events on a per-frame basis. It maintains a strict separation between physical scan-codes (ideal for layout-agnostic WASD movement) and logical key mappings, while also supporting OS key-repeat events, text-input buffering for typing, and modifier bitmasks.

The `MouseState` system offers comprehensive tracking of cursor coordinates, scroll-wheel deltas, and multi-button states. It allows developers to customize the cursor by selecting from system icons, providing raw RGBA pixel data, or toggling visibility and window-grab confinement (relative mode) for first-person control schemes. Gamepad support is exceptionally robust via the `GamepadState` struct, which tracks up to four connected controllers simultaneously. It manages analog sticks, triggers, button presses, connection lifecycles, and OS force-feedback vibration requests, synthesizing virtual D-pads and providing SDL2 GameControllerDB GUID mapping for maximum compatibility. `TouchState` similarly handles multi-point contact tracking for mobile or touchscreen interfaces, capturing press, move, and release lifecycles.

To support complex game mechanics, the module includes a highly capable `ComboDetector` designed to recognize fighting-game-style multi-step input sequences, complete with configurable per-step and total-sequence timeout windows. Furthermore, the module implements an `InputRecorder` that can capture sparse frame-by-frame event streams into versioned JSON envelopes. These recordings can be loaded and played back deterministically, facilitating automated testing, replay systems, and automated demo loops. All of these features are seamlessly exposed to the scripting engine via the `lurek.input.*` Lua namespace.

## Files

### action_def.rs

- Action definition types for the extended action-binding system.
- Defines ActionDef with bindings and a grouping category string.
- Provides ActionMap type alias for the full action map.
- Derives Serialize/Deserialize for JSON round-trip via serializeBindings and deserializeBindings.

### combo.rs

- Multi-step key-press combo detection with per-step and total-sequence timeouts.
- Stateful detector that advances, breaks, or completes on each key feed or timer tick.
- Used by the `lurek.input` combo API to recognize fighting-game-style input sequences.

### events.rs

- Input event types emitted by the winit event loop and queued for Lua consumption.
- `InputEvent` enum covers keyboard, mouse button, mouse move, scroll, and gamepad.
- Events are buffered in a ring during the platform event loop and drained each tick.
- `KeyEvent` carries the logical `KeyCode`, physical scan code, and press/release state.
- Gamepad events include axis deltas and button states for up to 4 connected pads.

### gamepad.rs

- Per-slot gamepad state tracking: buttons, axes, connection lifecycle, and per-frame delta sets.
- Vibration request queuing for delivery to the OS force-feedback driver.
- SDL2-style GUID-based mapping store with file and string parsing.
- Gilrs button/axis to SDL2 string conversion helpers.
- Virtual D-pad synthesis from analog stick values with configurable deadzone.
- Hat (D-pad) direction queries returning 8-way compass strings.

### keyboard.rs

- Per-frame keyboard state machine tracking logical keys, physical scan-codes, and frame deltas.
- Modifier bitmask flags (Shift, Ctrl, Alt, Meta) updated each event.
- OS key-repeat and text-input (IME) buffer toggling.
- Bidirectional mapping between logical key names and physical scan-code names.
- Winit-to-Lurek translation for both logical `Key` and physical `KeyCode` enums.
- Frame lifecycle: `begin_frame` clears deltas, events accumulate, queries read snapshot.
- Scan-code layer allows layout-independent bindings for WASD-style controls.
- Text-input buffer collects composed characters for chat and text fields.

### mod.rs

- Keyboard, mouse, gamepad, and touch input state aggregation.
- Event constants for Lua callbacks (keypressed, mousemoved, etc.).
- Combo gesture detection and input recording for replays.
- Extended action definitions with category metadata for the binding system.

### mouse.rs

- Per-frame mouse state tracking: position, button held/pressed/released deltas, and scroll accumulators.
- System cursor shape selection from a fixed set of OS-provided variants.
- Custom image-based cursor support via raw RGBA pixel buffers with hotspot offsets.
- Cursor visibility, grab (confinement), and relative (delta) mode toggles.
- Warp-to-position requests consumed by the runtime window loop.
- Frame-boundary reset for button deltas and scroll values.

### recorder.rs

- Record and replay input sessions as sparse frame sequences.
- Capture key/mouse events per frame; skip silent frames to save space.
- Serialise recordings to versioned JSON envelopes for deterministic replay.
- Provide stateful recorder with start/stop/load/playback cursor lifecycle.
- Support both live recording and loaded-file playback in one struct.

### touch.rs

- Multi-touch contact tracking with per-frame pressed/released deltas.
- Position and pressure state for each active touch id.
- Frame-boundary lifecycle: begin_frame clears deltas, start/move/end mutate state.

## Lua API Ref

- Binding: `src/lua_api/input_api.rs`
- Namespace: `lurek.input`

### Functions

- `lurek.input.advancePlayback`: Advances playback by one frame and returns events for that frame.
- `lurek.input.bind`: Adds one or more keyboard/gamepad bindings to an action.
- `lurek.input.clearBindings`: Removes all action bindings from the map.
- `lurek.input.define`: Defines an action with a full set of bindings and an optional category, replacing any prior definition.
- `lurek.input.deserializeBindings`: Loads action definitions from a JSON string produced by serializeBindings, replacing all current definitions.
- `lurek.input.gamepad.getAxis`: Returns a gamepad axis value by index.
- `lurek.input.gamepad.getAxisCount`: Returns the axis count for a gamepad.
- `lurek.input.gamepad.getBackgroundEvents`: Returns whether background gamepad event processing is enabled.
- `lurek.input.gamepad.getButtonCount`: Returns the button count for a gamepad.
- `lurek.input.gamepad.getCount`: Returns the number of gamepad slots tracked by the runtime.
- `lurek.input.gamepad.getGUID`: Returns the GUID string for a gamepad.
- `lurek.input.gamepad.getGamepadMappingString`: Returns a stored mapping string for a gamepad GUID.
- `lurek.input.gamepad.getHat`: Returns hat direction for a gamepad hat index.
- `lurek.input.gamepad.getJoystickCount`: Returns the number of joystick slots tracked by the runtime.
- `lurek.input.gamepad.getJoysticks`: Returns ids for currently connected gamepads.
- `lurek.input.gamepad.getName`: Returns a gamepad display name by its id.
- `lurek.input.gamepad.isConnected`: Returns whether a gamepad id is currently connected.
- `lurek.input.gamepad.isDown`: Returns whether a gamepad button is currently down.
- `lurek.input.gamepad.isGamepad`: Returns whether a connected gamepad exists at an id.
- `lurek.input.gamepad.isVibrationSupported`: Returns whether a gamepad supports vibration requests.
- `lurek.input.gamepad.loadGamepadMappings`: Loads gamepad mapping strings from a file.
- `lurek.input.gamepad.saveGamepadMappings`: Saves gamepad mapping strings to a file.
- `lurek.input.gamepad.setBackgroundEvents`: Enables or disables background gamepad event processing.
- `lurek.input.gamepad.setGamepadMapping`: Stores a controller mapping string for a gamepad GUID.
- `lurek.input.gamepad.setVibration`: Requests gamepad vibration with low and high frequency motor strengths.
- `lurek.input.gamepad.vibrate`: Requests gamepad vibration with low and high frequency motor strengths.
- `lurek.input.gamepad.virtualDpad`: Converts analog x and y values into virtual d-pad booleans and direction.
- `lurek.input.gamepad.wasConnected`: Returns whether a gamepad connected this frame.
- `lurek.input.gamepad.wasDisconnected`: Returns whether a gamepad disconnected this frame.
- `lurek.input.gamepad.wasPressed`: Returns whether a gamepad button was pressed this frame.
- `lurek.input.gamepad.wasReleased`: Returns whether a gamepad button was released this frame.
- `lurek.input.getAxis`: Returns -1.0, 0.0, or +1.0 for a named action; first binding is positive, second is negative.
- `lurek.input.getBindings`: Returns all registered action bindings.
- `lurek.input.getByCategory`: Returns action names belonging to the given category.
- `lurek.input.getConflicts`: Returns a table mapping each binding key to the action names that share it; only keys with two or more actions are included.
- `lurek.input.getPlaybackFrame`: Returns the current playback frame index.
- `lurek.input.getVector`: Returns a 2D axis vector from two named actions.
- `lurek.input.isActionDown`: Returns whether any binding for an action is currently down.
- `lurek.input.isDown`: Returns whether any bound key for this mapping is currently down.
- `lurek.input.isPlayingBack`: Returns whether the module recorder is currently playing back.
- `lurek.input.isRecording`: Returns whether the module recorder is currently recording.
- `lurek.input.keyboard.getKeyFromScancode`: Converts a scancode name to its key name when known.
- `lurek.input.keyboard.getScancodeFromKey`: Converts a key name to its scancode name when known.
- `lurek.input.keyboard.hasKeyRepeat`: Returns whether key repeat tracking is enabled.
- `lurek.input.keyboard.hasTextInput`: Returns whether text input tracking is enabled.
- `lurek.input.keyboard.isDown`: Returns whether any of the supplied key names are currently held down.
- `lurek.input.keyboard.isModifierActive`: Returns whether a named keyboard modifier is active.
- `lurek.input.keyboard.isScancodeDown`: Returns whether a scancode is currently down.
- `lurek.input.keyboard.setKeyRepeat`: Enables or disables key repeat tracking.
- `lurek.input.keyboard.setTextInput`: Enables or disables text input tracking.
- `lurek.input.loadRecording`: Loads recording JSON into the module recorder.
- `lurek.input.mouse.getCursor`: Returns the current system cursor name.
- `lurek.input.mouse.getPosition`: Returns the current mouse position.
- `lurek.input.mouse.getRelativeMode`: Returns whether relative mouse mode is enabled.
- `lurek.input.mouse.getSystemCursor`: Creates a system cursor handle from a cursor name.
- `lurek.input.mouse.getWheelDelta`: Returns the current mouse wheel delta.
- `lurek.input.mouse.getX`: Returns the current mouse x coordinate.
- `lurek.input.mouse.getY`: Returns the current mouse y coordinate.
- `lurek.input.mouse.isCursorSupported`: Returns whether the current platform supports cursor changes.
- `lurek.input.mouse.isDown`: Returns whether a one-based mouse button index is down.
- `lurek.input.mouse.isGrabbed`: Returns whether the mouse is grabbed by the window.
- `lurek.input.mouse.isVisible`: Returns whether the mouse cursor is visible.
- `lurek.input.mouse.newCursor`: Creates a custom cursor handle from RGBA pixels and hotspot coordinates.
- `lurek.input.mouse.setCursor`: Sets the active cursor from a cursor handle, system cursor name, or nil for arrow.
- `lurek.input.mouse.setGrabbed`: Sets whether the mouse is grabbed by the window.
- `lurek.input.mouse.setPosition`: Requests a mouse cursor position change.
- `lurek.input.mouse.setRelativeMode`: Sets the relative mouse input mode state.
- `lurek.input.mouse.setVisible`: Sets the mouse cursor visibility state.
- `lurek.input.newCombo`: Creates a combo detector from string steps or step tables with optional timing.
- `lurek.input.newMapping`: Creates an action mapping table with isDown, wasPressed, and wasReleased helper functions.
- `lurek.input.onRebind`: Registers a callback invoked whenever bindings change via bind, unbind, define, or deserializeBindings.
- `lurek.input.reset`: Removes bindings for one action by name, or all actions when name is nil.
- `lurek.input.serializeBindings`: Serialises all action definitions to a JSON string.
- `lurek.input.startPlayback`: Starts playback of the loaded recording.
- `lurek.input.startRecording`: Starts recording input events into the module recorder.
- `lurek.input.stopPlayback`: Stops playback of the loaded recording.
- `lurek.input.stopRecording`: Stops input recording and returns the captured recording when one is active.
- `lurek.input.touch.getPosition`: Returns the position of a touch point by id.
- `lurek.input.touch.getPressure`: Returns pressure for a touch point by its id.
- `lurek.input.touch.getTouchCount`: Returns the current active touch count.
- `lurek.input.touch.getTouches`: Returns active touch points with id, position, and pressure.
- `lurek.input.touch.wasPressed`: Returns whether a touch id began this frame.
- `lurek.input.touch.wasReleased`: Returns whether a touch id ended this frame.
- `lurek.input.unbind`: Removes all bindings for an action.
- `lurek.input.wasActionPressed`: Returns whether any binding for an action was pressed this frame and records the frame.
- `lurek.input.wasActionPressedWithin`: Returns whether an action was pressed within a recent frame window.
- `lurek.input.wasActionReleased`: Returns whether any binding for an action was released this frame.
- `lurek.input.wasPressed`: Returns whether any bound key for this mapping was pressed this frame.
- `lurek.input.wasReleased`: Returns whether any bound key for this mapping was released this frame.

### Enums

- No documented module-level enums/constants.

### Types


#### LCombo Type


##### Fields

- No documented fields.

##### Methods

- `LCombo:feed`: Feeds one key into the combo detector and returns progress status.
- `LCombo:getStep`: Returns step data by one-based index.
- `LCombo:isInProgress`: Returns whether the combo sequence is partially matched.
- `LCombo:progress`: Returns the current combo step index reached.
- `LCombo:reset`: Resets combo progress and elapsed time.
- `LCombo:tick`: Advances combo timeout state and returns progress status.
- `LCombo:totalSteps`: Returns the number of steps in this combo sequence.
- `LCombo:type`: Returns the Lua-visible type name for this combo handle.
- `LCombo:typeOf`: Returns whether this combo handle matches a supported type name.


#### LCursor Type


##### Fields

- No documented fields.

##### Methods

- `LCursor:getType`: Returns whether this cursor is a system cursor or custom cursor.
- `LCursor:release`: Releases cursor resources; currently a no-op for managed cursor handles.
- `LCursor:type`: Returns the Lua-visible type name for this cursor handle.
- `LCursor:typeOf`: Returns whether this cursor handle matches a supported type name.


#### LInputRecording Type


##### Fields

- No documented fields.

##### Methods

- `LInputRecording:frameCount`: Returns the number of event frames stored in this recording.
- `LInputRecording:toJson`: Serializes this input recording to JSON text.
- `LInputRecording:totalFrames`: Returns total frame count stored in this recording.
- `LInputRecording:type`: Returns the Lua-visible type name for this input recording handle.
- `LInputRecording:typeOf`: Returns whether this input recording handle matches a supported type name.

## References

- `runtime`: Imports or references `runtime` from `src/runtime/`.
