<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/input.md or source docstrings instead. -->

# input

## TL;DR

- Unifies keyboard, mouse, gamepad slotting, and touch events into stable inputs.
- Supports custom action-bindings, gesture combo timing, and JSON input replays.

## General Info

- Module group: `Platform Services`
- Source path: `src/input`
- Binding: `src/lua_api/input_api.rs`
- Namespace: `lurek.input`
- Lua API surface: `89` functions, `8` types, `18` methods
- User-facing: `true`
- Plugin tier: `not_evaluated`

## Summary

- The `input` module is the engine's unified control surface for users who need keyboard, mouse, gamepad, and touch state to behave as one coherent runtime system.
- Its main job is normalization. Device-specific events become stable engine-side state so scripts can ask about buttons, axes, touches, combos, and actions through one consistent vocabulary.
- Per-frame snapshots matter because gameplay, UI, replays, and tools all need deterministic control state rather than raw transient platform events.
- Action mapping, rebinding, presets, and conflict handling are central because real projects care about intent and user-configurable schemes more than about hardwired physical keys.
- Mouse, pointer, touch, and compound input remain part of the same model, which keeps interaction semantics consistent across device families and helps accessibility layers share the same action surface.
- Recording and playback make the module useful for debugging, tests, automation, tutorials, and deterministic repro workflows as well as for live play.
- Replay payloads also carry schema and provenance metadata so tools can reason about compatibility, timing assumptions, and keyboard-layout risk before treating a recording as deterministic.
- That normalization layer protects higher-level systems from platform detail churn. Gameplay and UI code can ask for stable actions instead of reinventing per-device handling every time a new device family or interaction surface appears.
- Rebinding is especially important because modern projects often need several physical inputs to express the same logical action under explicit precedence, accessibility, or user-preference rules.
- Input capture and replay also make the module one of the cleanest sources of truth for what happened during a failing run, a scripted demonstration, or a tool-driven automation pass.
- The result is a surface that serves players, tools, and tests at the same time: it turns noisy device events into deterministic, serializable, reusable intent.
- Other systems consume the result, but `input` owns normalization, mapping, serialization, and replay semantics for device-originated intent.

This module primarily collaborates with `filesystem`, `runtime`. Its responsibility should stay inside the Platform Services group rather than absorb behavior owned by those neighbors.

## Ownership

- Canonical source: `src/input`
- Owning tier: `Platform Services`
- Plugin tier: `not_evaluated`
- Lua binding owner: `src/lua_api/input_api.rs`
- Referenced engine modules: `filesystem`, `runtime`

## Imports

- `filesystem`: Imports or references `src/filesystem/`. Cross-group dependency from `Platform Services` into `Core Runtime`.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Platform Services` into `Core Runtime`.

## Source Files

### action_def.rs

- Owns input behavior with explicit state, validation, and crate-local integration boundaries.
- Centers the implementation around InputBinding, parse, to_canonical_string, with helpers kept close to their invariants.
- Defines how action def data is validated, transformed, or stored before neighboring systems use it.
- Owns input behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on action def behavior while Lua registration stays elsewhere.

### combo.rs

- This file owns `ComboStep`, `ComboProgress`, and `ComboDetector`, the timed multi-step combo recognizer.
- It tracks the next expected key, per-step elapsed gap, whole-sequence timeout, and enabled state in one owner.
- Feed and tick helpers emit explicit advanced, completed, broken, or idle states for caller-side response logic.
- Reset and progress helpers keep repeated combo attempts deterministic after mismatches, timeouts, or completion.
- Open this file when combo semantics change; live key polling and action binding data live in sibling files.

### events.rs

- This file owns the canonical string constants for keyboard, mouse, wheel, and text input event names.
- It centralizes the Lua-facing event vocabulary so the platform loop and consumers use one stable naming surface.
- Open this file when event-name contracts change; device state and dispatch behavior live in sibling files.

### gamepad.rs

- This file owns `GamepadState`, `GamepadVibrationRequest`, and `GamepadMappings`, the runtime gamepad model.
- It stores connection flags, per-button hold and transition sets, axis values, GUIDs, names, and rumble capability.
- Frame helpers clear transient deltas, while update methods record button and axis changes from backend polling.
- Virtual D-pad conversion also lives here so input-facing helpers stay near the gamepad state model.
- The mappings store parses SDL2-style controller database lines, keeps them by GUID, and can read or write files.
- The file is the owner for device state and mapping schema, while app-side polling and rumble dispatch live higher.
- Open it when gamepad semantics change; combo logic, recording, and window-event orchestration live in siblings.

### keyboard.rs

- This file owns `KeyboardState` and key-translation helpers, the runtime keyboard model used by the engine.
- It stores held logical keys, held scancodes, pressed and released deltas, modifier bits, and text input buffers.
- Frame helpers clear transient deltas, while mutation methods record presses, releases, repeat policy, and IME text.
- Lookup helpers expose current state, any-key queries, modifier flags, and raw frame-local text input collections.
- Name translation also lives here, mapping winit logical keys and physical keycodes into stable engine strings.
- The file separates logical key identity from scancodes so layout-aware and physical-input paths can both coexist.
- Open it when keyboard semantics change; action maps, combos, and app event dispatch live in sibling modules.

### mod.rs

- This module re-exports the input subsystem for keyboard, mouse, gamepad, touch, combos, events, and recording.
- It is the navigation map for device state owners, name translation helpers, and reusable input-facing type exports.
- `keyboard.rs`, `mouse.rs`, and `gamepad.rs` own the live per-device polling state used during runtime frames.
- `touch.rs`, `combo.rs`, and `recorder.rs` cover multitouch state, sequence detection, and replay persistence flows.
- `action_def.rs` stores action-map data, while `events.rs` centralizes the canonical Lua-facing event name constants.
- Change this file when public input exports move; change sibling files when device semantics or polling behavior changes.

### mouse.rs

- Owns the mouse owner for the input subsystem and keeps its rules local to this file while keeping call sites explicit.
- Centers the implementation around CursorImageLimits, default, SystemCursor, with helpers kept close to their invariants.
- Defines how mouse data is validated, transformed, or stored before neighboring systems use it.
- Owns input behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on mouse behavior while Lua registration stays elsewhere.
- Documents where input callers should change defaults, errors, or lifecycle behavior. with focused crate-local behavior.
- Use this file when changing mouse defaults, lifecycle handling, validation, or data ownership.

### recorder.rs

- Owns input behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps input data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
- Defines how recorder data is validated, transformed, or stored before neighboring systems use it.
- Owns input behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on recorder behavior while Lua registration stays elsewhere.
- Documents where input callers should change defaults, errors, or lifecycle behavior. with focused crate-local behavior.
- Use this file when changing recorder defaults, lifecycle handling, validation, or data ownership.

### touch.rs

- This file owns `TouchPoint` and `TouchState`, the multitouch state used to track active contacts per frame.
- It stores current contacts by id plus pressed and released delta sets so touch queries stay deterministic.
- Mutation helpers cover touch start, move, and end, while `begin_frame` clears only transient transition markers.
- Open this file when touch-state semantics change; mouse, keyboard, and event-loop dispatch live in siblings.



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
- `mouse_x` (`number?`): Replayed mouse X coordinate for this frame when recorded.
- `mouse_y` (`number?`): Replayed mouse Y coordinate for this frame when recorded.
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

## Examples

- `content/examples/input.lua` (present)

## Architecture Links

- Intentionally empty.

## Notes

- Action bindings are canonicalized at the API boundary. Alias key names collapse to one stored spelling, malformed structured bindings are rejected, and reserved binding families stay unavailable to action queries until the engine supports them end to end.
- Custom cursor creation validates image dimensions, RGBA byte length, and hotspot bounds before the request becomes a runtime cursor handle.
- Gamepad mapping import and export use sandboxed `GameFS` path resolution instead of arbitrary host filesystem paths, and mapping lines must pass GUID and token validation before they are stored.
- Losing window focus clears held keyboard keys and modifier state so stale `ctrl`, `alt`, `shift`, `meta`, and `altgr` flags do not leak across blur events.
- Replay playback preserves sparse mouse coordinates, and recording JSON loading enforces byte, frame-count, event-count, and metadata-length limits before accepting untrusted payloads.
