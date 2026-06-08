# input

## TL;DR

- Unifies keyboard, mouse, gamepad slotting, and touch events into stable inputs.
- Supports custom action-bindings, gesture combo timing, and JSON input replays.

## General Info

- Module group: `Platform Services`
- Source path: `src/input/`
- Binding: `src/lua_api/input_api.rs`
- Namespace: `lurek.input`
- Lua API surface: `89` functions, `8` types, `18` methods
- Rust test path(s): tests/rust/unit/input_tests.rs
- Lua test path(s): tests/lua/unit/test_input.lua, tests/lua/integration/test_input_camera.lua

## Summary

- This module gives users a unified input layer across keyboard, mouse, gamepad, and touch devices.
- It normalizes hardware-specific events into stable runtime-facing controls.
- Keyboard state includes held/pressed/released tracking, modifiers, and optional text input behavior.
- Mouse APIs cover position, wheel, visibility, lock/grab state, and cursor management.
- Gamepad support includes connection lifecycle, axis/button polling, mapping, and vibration requests.
- Touch APIs expose active points, pressure, and per-frame transition state.
- Action bindings map logical commands to multiple physical inputs.
- Binding definitions can be serialized and restored, enabling rebindable controls and user presets.
- Action query helpers support common checks like down, pressed, released, and timing-window variants.
- Combo detection enables timed gesture sequences for fighting-game or rhythm-style interactions.
- Input recording and playback support deterministic replay for automation and debugging.
- Frame-indexed replay helps reproduce issues without manual re-entry.
- Category and conflict helpers support tooling around control-map maintenance.
- The module is useful for gameplay, UI navigation, accessibility mapping, and test automation.
- For users, it centralizes all input concerns into one scriptable control surface.
- It reduces per-device branching code and keeps behavior consistent across platforms.
- The practical value is faster control iteration and more reliable input diagnostics.
- It also supports robust QA through record/replay and deterministic input timelines.
- Overall, users get both ergonomic control APIs and advanced tooling hooks in one module.
- This makes input behavior easier to tune, test, and ship confidently.

## Imports

- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### action_def.rs

- Defines action-binding data shapes used to map logical actions onto multiple physical inputs.
- Stores ordered binding strings and optional category grouping for tooling and menu presentation.
- Provides serializable action-map structures for loading, saving, and sharing binding presets.

### combo.rs

- Implements sequential combo recognition for multi-step input patterns with timing constraints.
- Tracks progress state across key feeds, validating per-step gaps and whole-sequence deadlines.
- Emits explicit advanced, completed, and broken states to simplify caller-side response logic.
- Resets predictably after failures or completion to support repeated combo attempts.
- Powers gameplay and scripting features that require ordered gesture-style key sequences.

### events.rs

- Declares normalized input event names and payload types emitted from the platform event loop.
- Defines keyboard, mouse, wheel, text, and gamepad event variants for unified downstream handling.
- Serves as the shared event contract consumed by runtime queues and Lua-facing dispatch paths.

### gamepad.rs

- Manages gamepad device state per slot, including buttons, axes, and connection lifecycle changes.
- Tracks per-frame deltas for press and release transitions so polling remains deterministic.
- Queues rumble requests with normalized motor strengths for runtime delivery to OS backends.
- Parses and stores mapping profiles using GUID-keyed formats compatible with common controller data.
- Bridges backend-specific button and axis identities into stable engine-facing naming.
- Synthesizes virtual directional output from analog sticks with deadzone-aware interpretation.
- Exposes hat and direction queries used by gameplay code and Lua input APIs.

### keyboard.rs

- Implements per-frame keyboard state with held keys, transition deltas, and modifier tracking.
- Separates logical key identity from physical scancode paths for layout-aware and layout-agnostic input.
- Updates modifier bitmasks on each event to keep control-state queries cheap and consistent.
- Maintains optional key-repeat and text-input buffering for UI fields and chat-like interactions.
- Performs translation from backend key enums into stable engine key naming conventions.
- Clears transient deltas at frame boundaries while preserving held-state continuity.
- Supports binding workflows that combine textual key names with physical scan-code fallback semantics.

### mod.rs

- High-level input module that groups keyboard, mouse, gamepad, touch, and recording components.
- Re-exports action and state types so caller code can consume one coherent input surface.
- Defines the composition boundary where platform events become gameplay-usable input state.

### mouse.rs

- Tracks mouse position, button transitions, and scroll deltas with frame-local reset semantics.
- Stores held, pressed, and released button sets for deterministic polling across gameplay systems.
- Supports system cursor variants and custom cursor image metadata with hotspot offsets.
- Exposes cursor visibility, grab, relative mode, and warp requests for runtime window integration.
- Preserves smooth pointer-control behavior while separating transient and persistent state.
- Serves as the central mouse state source for UI interaction and gameplay input checks.

### recorder.rs

- Records and replays input timelines as frame-indexed event sequences for automation and debugging.
- Captures sparse frame data so silent periods do not inflate stored replay size.
- Serializes recordings through versioned JSON envelopes for stable persistence and interchange.
- Tracks recorder lifecycle state for live capture, loading, seeking, and playback progression.
- Supports deterministic test scenarios by emitting recorded events on their original frame numbers.
- Unifies recording and playback behavior in one stateful component used by runtime and tools.

### touch.rs

- Tracks multi-touch contacts with active-point state and per-frame transition sets.
- Stores per-contact position and pressure values keyed by stable touch identifiers.
- Clears transient pressed and released markers at frame boundaries while preserving active points.
- Provides touch lifecycle mutation paths for start, move, and end events from the platform layer.

## Lua API Ref

### Functions

- `lurek.input.advancePlayback() -> table`: Advances playback by one frame and returns events for that frame.
- `lurek.input.bind(action, keys) -> nil`: Adds one or more keyboard/gamepad bindings to an action.
- `lurek.input.clearBindings() -> nil`: Removes all action bindings from the map.
- `lurek.input.define(name, bindings, category?) -> nil`: Defines an action with a full set of bindings and an optional category, replacing any prior definition.
- `lurek.input.deserializeBindings(json) -> boolean`: Loads action definitions from a JSON string produced by serializeBindings, replacing all current definitions.
- `lurek.input.gamepad.getAxis(id, axis) -> number`: Returns a gamepad axis value by index.
- `lurek.input.gamepad.getAxisCount(id) -> integer`: Returns the axis count for a gamepad.
- `lurek.input.gamepad.getBackgroundEvents() -> boolean`: Returns whether background gamepad event processing is enabled.
- `lurek.input.gamepad.getButtonCount(id) -> integer`: Returns the button count for a gamepad.
- `lurek.input.gamepad.getCount() -> integer`: Returns the number of gamepad slots tracked by the runtime.
- `lurek.input.gamepad.getGUID(id) -> string`: Returns the GUID string for a gamepad.
- `lurek.input.gamepad.getGamepadMappingString(guid) -> string`: Returns a stored mapping string for a gamepad GUID.
- `lurek.input.gamepad.getHat(id, hat) -> string`: Returns hat direction for a gamepad hat index.
- `lurek.input.gamepad.getJoystickCount() -> integer`: Returns the number of joystick slots tracked by the runtime.
- `lurek.input.gamepad.getJoysticks() -> integer[]`: Returns ids for currently connected gamepads.
- `lurek.input.gamepad.getName(id) -> string`: Returns a gamepad display name by its id.
- `lurek.input.gamepad.isConnected(id) -> boolean`: Returns whether a gamepad id is currently connected.
- `lurek.input.gamepad.isDown(id, button) -> boolean`: Returns whether a gamepad button is currently down.
- `lurek.input.gamepad.isGamepad(id) -> boolean`: Returns whether a connected gamepad exists at an id.
- `lurek.input.gamepad.isVibrationSupported(id) -> boolean`: Returns whether a gamepad supports vibration requests.
- `lurek.input.gamepad.loadGamepadMappings(path) -> nil`: Loads gamepad mapping strings from a file.
- `lurek.input.gamepad.saveGamepadMappings(path) -> nil`: Saves gamepad mapping strings to a file.
- `lurek.input.gamepad.setBackgroundEvents(enable) -> nil`: Enables or disables background gamepad event processing.
- `lurek.input.gamepad.setGamepadMapping(guid, mapping) -> nil`: Stores a controller mapping string for a gamepad GUID.
- `lurek.input.gamepad.setVibration(id, low_freq, high_freq, duration_ms) -> boolean`: Requests gamepad vibration with low and high frequency motor strengths.
- `lurek.input.gamepad.vibrate(id, low_freq, high_freq, duration_ms) -> boolean`: Requests gamepad vibration with low and high frequency motor strengths.
- `lurek.input.gamepad.virtualDpad(x, y, deadzone?) -> table`: Converts analog x and y values into virtual d-pad booleans and direction.
- `lurek.input.gamepad.wasConnected(id) -> boolean`: Returns whether a gamepad connected this frame.
- `lurek.input.gamepad.wasDisconnected(id) -> boolean`: Returns whether a gamepad disconnected this frame.
- `lurek.input.gamepad.wasPressed(id, button) -> boolean`: Returns whether a gamepad button was pressed this frame.
- `lurek.input.gamepad.wasReleased(id, button) -> boolean`: Returns whether a gamepad button was released this frame.
- `lurek.input.getAxis(name) -> number`: Returns -1.0, 0.0, or +1.0 for a named action; first binding is positive, second is negative.
- `lurek.input.getBindings() -> string[]`: Returns all registered action bindings.
- `lurek.input.getByCategory(category) -> string[]`: Returns action names belonging to the given category.
- `lurek.input.getConflicts() -> table`: Returns a table mapping each binding key to the action names that share it; only keys with two or more actions are included.
- `lurek.input.getPlaybackFrame() -> integer`: Returns the current playback frame index.
- `lurek.input.getVector(hname, vname) -> number`: Returns a 2D axis vector from two named actions.
- `lurek.input.isActionDown(action) -> boolean`: Returns whether any binding for an action is currently down.
- `lurek.input.isDown() -> boolean`: Returns whether any bound key for this mapping is currently down.
- `lurek.input.isPlayingBack() -> boolean`: Returns whether the module recorder is currently playing back.
- `lurek.input.isRecording() -> boolean`: Returns whether the module recorder is currently recording.
- `lurek.input.keyboard.getKeyFromScancode(scancode) -> string`: Converts a scancode name to its key name when known.
- `lurek.input.keyboard.getScancodeFromKey(key) -> string`: Converts a key name to its scancode name when known.
- `lurek.input.keyboard.hasKeyRepeat() -> boolean`: Returns whether key repeat tracking is enabled.
- `lurek.input.keyboard.hasTextInput() -> boolean`: Returns whether text input tracking is enabled.
- `lurek.input.keyboard.isDown(...) -> boolean`: Returns whether any of the supplied key names are currently held down.
- `lurek.input.keyboard.isModifierActive(modifier) -> boolean`: Returns whether a named keyboard modifier is active.
- `lurek.input.keyboard.isScancodeDown(scancode) -> boolean`: Returns whether a scancode is currently down.
- `lurek.input.keyboard.setKeyRepeat(enabled) -> nil`: Enables or disables key repeat tracking.
- `lurek.input.keyboard.setTextInput(enabled) -> nil`: Enables or disables text input tracking.
- `lurek.input.loadRecording(json) -> nil`: Loads recording JSON into the module recorder.
- `lurek.input.mouse.getCursor() -> string`: Returns the current system cursor name.
- `lurek.input.mouse.getPosition() -> number`: Returns the current mouse position.
- `lurek.input.mouse.getRelativeMode() -> boolean`: Returns whether relative mouse mode is enabled.
- `lurek.input.mouse.getSystemCursor(name) -> LCursor`: Creates a system cursor handle from a cursor name.
- `lurek.input.mouse.getWheelDelta() -> number`: Returns the current mouse wheel delta.
- `lurek.input.mouse.getX() -> number`: Returns the current mouse x coordinate.
- `lurek.input.mouse.getY() -> number`: Returns the current mouse y coordinate.
- `lurek.input.mouse.isCursorSupported() -> boolean`: Returns whether the current platform supports cursor changes.
- `lurek.input.mouse.isDown(button) -> boolean`: Returns whether a one-based mouse button index is down.
- `lurek.input.mouse.isGrabbed() -> boolean`: Returns whether the mouse is grabbed by the window.
- `lurek.input.mouse.isVisible() -> boolean`: Returns whether the mouse cursor is visible.
- `lurek.input.mouse.newCursor(pixels, width, height, hotx?, hoty?) -> LCursor`: Creates a custom cursor handle from RGBA pixels and hotspot coordinates.
- `lurek.input.mouse.setCursor(cursor) -> nil`: Sets the active cursor from a cursor handle, system cursor name, or nil for arrow.
- `lurek.input.mouse.setGrabbed(grabbed) -> nil`: Sets whether the mouse is grabbed by the window.
- `lurek.input.mouse.setPosition(x, y) -> nil`: Requests a mouse cursor position change.
- `lurek.input.mouse.setRelativeMode(relative) -> nil`: Sets the relative mouse input mode state.
- `lurek.input.mouse.setVisible(visible) -> nil`: Sets the mouse cursor visibility state.
- `lurek.input.newCombo(steps, opts?) -> LCombo`: Creates a combo detector from string steps or step tables with optional timing.
- `lurek.input.newMapping(name, keys) -> table`: Creates an action mapping table with isDown, wasPressed, and wasReleased helper functions.
- `lurek.input.onRebind(callback) -> nil`: Registers a callback invoked whenever bindings change via bind, unbind, define, or deserializeBindings.
- `lurek.input.reset(name?) -> nil`: Removes bindings for one action by name, or all actions when name is nil.
- `lurek.input.serializeBindings() -> string`: Serialises all action definitions to a JSON string.
- `lurek.input.startPlayback() -> nil`: Starts playback of the loaded recording.
- `lurek.input.startRecording() -> nil`: Starts recording input events into the module recorder.
- `lurek.input.stopPlayback() -> nil`: Stops playback of the loaded recording.
- `lurek.input.stopRecording() -> LInputRecording`: Stops input recording and returns the captured recording when one is active.
- `lurek.input.touch.getPosition(id) -> number`: Returns the position of a touch point by id.
- `lurek.input.touch.getPressure(id) -> number`: Returns pressure for a touch point by its id.
- `lurek.input.touch.getTouchCount() -> integer`: Returns the current active touch count.
- `lurek.input.touch.getTouches() -> table`: Returns active touch points with id, position, and pressure.
- `lurek.input.touch.wasPressed(id) -> boolean`: Returns whether a touch id began this frame.
- `lurek.input.touch.wasReleased(id) -> boolean`: Returns whether a touch id ended this frame.
- `lurek.input.unbind(action) -> boolean`: Removes all bindings for an action.
- `lurek.input.wasActionPressed(action) -> boolean`: Returns whether any binding for an action was pressed this frame and records the frame.
- `lurek.input.wasActionPressedWithin(action, frames) -> boolean`: Returns whether an action was pressed within a recent frame window.
- `lurek.input.wasActionReleased(action) -> boolean`: Returns whether any binding for an action was released this frame.
- `lurek.input.wasPressed() -> boolean`: Returns whether any bound key for this mapping was pressed this frame.
- `lurek.input.wasReleased() -> boolean`: Returns whether any bound key for this mapping was released this frame.

### Callbacks

- `lurek.input.onRebind` param `callback` (`function`): function(action_name, new_keys) called on any change.

### Enums

- No documented module-level enums/constants.

### Types

#### LCombo Type

- Lua-side combo detector handle tracking ordered key sequences.

##### Fields

- No documented fields.

##### Methods

- `LCombo:feed(key) -> string`: Feeds one key into the combo detector and returns progress status.
- `LCombo:getStep(index) -> table`: Returns step data by one-based index.
- `LCombo:isInProgress() -> boolean`: Returns whether the combo sequence is partially matched.
- `LCombo:progress() -> integer`: Returns the current combo step index reached.
- `LCombo:reset() -> nil`: Resets combo progress and elapsed time.
- `LCombo:tick(dt) -> string`: Advances combo timeout state and returns progress status.
- `LCombo:totalSteps() -> integer`: Returns the number of steps in this combo sequence.
- `LCombo:type() -> string`: Returns the Lua-visible type name for this combo handle.
- `LCombo:typeOf(name) -> boolean`: Returns whether this combo handle matches a supported type name.

#### LComboGetStepResult Type

- Generated result shape from @field tags.

##### Fields

- `gap_ms` (`number`): Gap in milliseconds.
- `key` (`string`): Key name.

##### Methods

- No documented methods.

#### LCursor Type

- Lua-side cursor handle for system and custom cursor requests.

##### Fields

- No documented fields.

##### Methods

- `LCursor:getType() -> string`: Returns whether this cursor is a system cursor or custom cursor.
- `LCursor:release() -> nil`: Releases cursor resources; currently a no-op for managed cursor handles.
- `LCursor:type() -> string`: Returns the Lua-visible type name for this cursor handle.
- `LCursor:typeOf(name) -> boolean`: Returns whether this cursor handle matches a supported type name.

#### LGamepadVirtualDpadResult Type

- Generated result shape from @field tags.

##### Fields

- `direction` (`string`): Direction name.
- `down` (`boolean`): Down pressed.
- `left` (`boolean`): Left pressed.
- `right` (`boolean`): Right pressed.
- `up` (`boolean`): Up pressed.

##### Methods

- No documented methods.

#### LInputAdvancePlaybackResult Type

- Generated result shape from @field tags.

##### Fields

- `kind` (`string`): Event kind (press, release, hold).
- `name` (`string`): Event name.

##### Methods

- No documented methods.

#### LInputNewMappingResult Type

- Generated result shape from @field tags.

##### Fields

- `isDown` (`function`): Returns true while the action is held.
- `wasPressed` (`function`): Returns true on the frame the action was pressed.
- `wasReleased` (`function`): Returns true on the frame the action was released.

##### Methods

- No documented methods.

#### LInputRecording Type

- Lua-side handle for serialized input recording data.

##### Fields

- No documented fields.

##### Methods

- `LInputRecording:frameCount() -> integer`: Returns the number of event frames stored in this recording.
- `LInputRecording:toJson() -> string`: Serializes this input recording to JSON text.
- `LInputRecording:totalFrames() -> integer`: Returns total frame count stored in this recording.
- `LInputRecording:type() -> string`: Returns the Lua-visible type name for this input recording handle.
- `LInputRecording:typeOf(name) -> boolean`: Returns whether this input recording handle matches a supported type name.

#### LTouchGetTouchesResult Type

- Generated result shape from @field tags.

##### Fields

- `id` (`integer`): Touch point id.
- `pressure` (`number`): Touch pressure.
- `x` (`number`): Touch x position.
- `y` (`number`): Touch y position.

##### Methods

- No documented methods.
