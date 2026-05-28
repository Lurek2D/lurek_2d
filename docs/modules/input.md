# Input

- The `input` module is a core Platform Services tier component that aggregates and processes hardware inputs across keyboard, mouse, gamepad, and multi-touch devices.

Functioning as a translation layer between the winit OS event loop and the game logic, it provides frame-perfect state tracking and querying. The `KeyboardState` system accurately monitors key-down, key-up, just-pressed, and just-released events on a per-frame basis. It maintains a strict separation between physical scan-codes (ideal for layout-agnostic WASD movement) and logical key mappings, while also supporting OS key-repeat events, text-input buffering for typing, and modifier bitmasks.

The `MouseState` system offers comprehensive tracking of cursor coordinates, scroll-wheel deltas, and multi-button states. It allows developers to customize the cursor by selecting from system icons, providing raw RGBA pixel data, or toggling visibility and window-grab confinement (relative mode) for first-person control schemes. Gamepad support is exceptionally robust via the `GamepadState` struct, which tracks up to four connected controllers simultaneously. It manages analog sticks, triggers, button presses, connection lifecycles, and OS force-feedback vibration requests, synthesizing virtual D-pads and providing SDL2 GameControllerDB GUID mapping for maximum compatibility. `TouchState` similarly handles multi-point contact tracking for mobile or touchscreen interfaces, capturing press, move, and release lifecycles.

To support complex game mechanics, the module includes a highly capable `ComboDetector` designed to recognize fighting-game-style multi-step input sequences, complete with configurable per-step and total-sequence timeout windows. Furthermore, the module implements an `InputRecorder` that can capture sparse frame-by-frame event streams into versioned JSON envelopes. These recordings can be loaded and played back deterministically, facilitating automated testing, replay systems, and automated demo loops. All of these features are seamlessly exposed to the scripting engine via the `lurek.input.*` Lua namespace.

## Functions

### `lurek.input.advancePlayback`

Advances playback by one frame and returns events for that frame.

```lua
-- signature
lurek.input.advancePlayback()
```

**Returns**

| Type | Description |
|------|-------------|
| `InputAdvancePlaybackResult` | Array of event records with `kind` and `name` fields. |

**Example**

```lua
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
```

---

### `lurek.input.bind`

Adds one or more keyboard/gamepad bindings to an action.

```lua
-- signature
lurek.input.bind(action, keys)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `action` | `string` | Action name. |
| `keys` | `any` | Binding string or array table of binding strings. |

**Example**

```lua
do
    lurek.input.bind("jump", "space")
    lurek.input.bind("move_left", {"a", "left"})
    print("actions bound")
end
```

---

### `lurek.input.clearBindings`

Removes all action bindings from the map.

```lua
-- signature
lurek.input.clearBindings()
```

**Example**

```lua
do
    lurek.input.bind("a1", "q")
    lurek.input.bind("a2", "e")
    lurek.input.clearBindings()
    print("all bindings cleared")
end
```

---

### `lurek.input.define`

Defines an action with a full set of bindings and an optional category, replacing any prior definition.

```lua
-- signature
lurek.input.define(name, bindings, category)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Action name. |
| `bindings` | `any` | Binding string or array of binding strings. |
| `category?` | `string` | Category label for grouping (default empty string). |

**Example**

```lua
do
    lurek.input.define("jump", {"space", "up"}, "movement")
    print("define ok")
    lurek.input.reset()
end
```

---

### `lurek.input.deserializeBindings`

Loads action definitions from a JSON string produced by serializeBindings, replacing all current definitions.

```lua
-- signature
lurek.input.deserializeBindings(json)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `json` | `string` | JSON string with action definitions. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True on success. |

**Example**

```lua
do
    lurek.input.bind("test_deser", "q")
    local json = lurek.input.serializeBindings()
    lurek.input.reset()
    local ok = lurek.input.deserializeBindings(json)
    print("deserializeBindings=" .. tostring(ok))
    lurek.input.reset()
end
```

---

### `lurek.input.getAxis`

Returns -1.0, 0.0, or +1.0 for a named action; first binding is positive, second is negative.

```lua
-- signature
lurek.input.getAxis(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Action name. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Axis value: +1.0, -1.0, or 0.0. |

**Example**

```lua
do
    lurek.input.bind("move_x", {"d", "a"})
    local v = lurek.input.getAxis("move_x")
    print("getAxis=" .. tostring(v))
    lurek.input.reset()
end
```

---

### `lurek.input.getBindings`

Returns all registered action bindings.

```lua
-- signature
lurek.input.getBindings()
```

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Map table from action names to arrays of binding strings. |

**Example**

```lua
do
    lurek.input.bind("shoot", "x")
    local bindings = lurek.input.getBindings()
    local shoot = rawget(bindings, "shoot") or {}
    print("has shoot = " .. tostring(rawget(bindings, "shoot") ~= nil))
    print("shoot bindings = " .. #shoot)
end
```

---

### `lurek.input.getByCategory`

Returns action names belonging to the given category.

```lua
-- signature
lurek.input.getByCategory(category)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `category` | `string` | Category label. |

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Array of matching action names. |

**Example**

```lua
do
    lurek.input.define("run", "lshift", "movement")
    local cats = lurek.input.getByCategory("movement")
    print("getByCategory count=" .. #cats)
    lurek.input.reset()
end
```

---

### `lurek.input.getConflicts`

Returns a table mapping each binding key to the action names that share it; only keys with two or more actions are included.

```lua
-- signature
lurek.input.getConflicts()
```

**Returns**

| Type | Description |
|------|-------------|
| `table` | Map of binding string to array of conflicting action names. |

**Example**

```lua
do
    lurek.input.bind("act_a", "x")
    lurek.input.bind("act_b", "x")
    local c = lurek.input.getConflicts()
    print("getConflicts type=" .. type(c))
    lurek.input.reset()
end
```

---

### `lurek.input.getPlaybackFrame`

Returns the current playback frame index.

```lua
-- signature
lurek.input.getPlaybackFrame()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Playback frame index. |

**Example**

```lua
do
    local frame = lurek.input.getPlaybackFrame()
    print("playback frame = " .. frame)
end
```

---

### `lurek.input.getVector`

Returns a 2D axis vector from two named actions.

```lua
-- signature
lurek.input.getVector(hname, vname)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `hname` | `string` | Horizontal action name (positive = right). |
| `vname` | `string` | Vertical action name (positive = down). |

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Horizontal axis value. |
| `number` | b Vertical axis value. |

**Example**

```lua
do
    lurek.input.bind("haxis", {"d", "a"})
    lurek.input.bind("vaxis", {"s", "w"})
    local h, v = lurek.input.getVector("haxis", "vaxis")
    print("getVector=" .. tostring(h) .. "," .. tostring(v))
    lurek.input.reset()
end
```

---

### `lurek.input.isActionDown`

Returns whether any binding for an action is currently down.

```lua
-- signature
lurek.input.isActionDown(action)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `action` | `string` | Action name. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when any binding is down. |

**Example**

```lua
do
    lurek.input.bind("fire", "space")
    local down = lurek.input.isActionDown("fire")
    print("fire down = " .. tostring(down))
end
```

---

### `lurek.input.isDown`

Returns whether any bound key for this mapping is currently down.

```lua
-- signature
lurek.input.isDown()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when any bound key is down. |

**Example**

```lua
do
    -- isDown() returns true while any key is held; check inside an input event callback
    local v = lurek.input.keyboard.isDown("a")
    print("isDown available = " .. tostring(type(lurek.input.keyboard.isDown) == "function"))
    print("result type = " .. type(v))
end
```

---

### `lurek.input.isPlayingBack`

Returns whether the module recorder is currently playing back.

```lua
-- signature
lurek.input.isPlayingBack()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when playback is active. |

**Example**

```lua
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
```

---

### `lurek.input.isRecording`

Returns whether the module recorder is currently recording.

```lua
-- signature
lurek.input.isRecording()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when recording is active. |

**Example**

```lua
do
    print("recording = " .. tostring(lurek.input.isRecording()))
    print("playing = " .. tostring(lurek.input.isPlayingBack()))
end
```

---

### `lurek.input.loadRecording`

Loads recording JSON into the module recorder.

```lua
-- signature
lurek.input.loadRecording(json)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `json` | `string` | Recording JSON. |

**Example**

```lua
do
    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    if rec then lurek.input.loadRecording(rec:toJson()) end
    print("recording loaded = " .. tostring(rec ~= nil))
end
```

---

### `lurek.input.newCombo`

Creates a combo detector from string steps or step tables with optional timing.

```lua
-- signature
lurek.input.newCombo(steps, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `steps` | `table` | Array table of key strings or `{key, gap}` step tables. |
| `opts?` | `table` | Options table with `total_gap` in milliseconds. |

**Returns**

| Type | Description |
|------|-------------|
| `LCombo` | New combo detector handle. |

**Example**

```lua
do
    local combo = lurek.input.newCombo({"down", "right", "z"}, {total_gap = 500})
    print("combo steps = " .. combo:totalSteps())
    print("in progress = " .. tostring(combo:isInProgress()))
    print("progress = " .. combo:progress())
end
```

---

### `lurek.input.newMapping`

Creates an action mapping table with isDown, wasPressed, and wasReleased helper functions.

```lua
-- signature
lurek.input.newMapping(name, keys)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Action name. |
| `keys` | `any` | Binding string or array table of binding strings. |

**Returns**

| Type | Description |
|------|-------------|
| `InputNewMappingResult` | Mapping table with action query closures. |

**Example**

```lua
do
    local mapping = lurek.input.newMapping("attack", {"z", "button1"})
    local held = mapping.isDown()
    local just = mapping.wasPressed()
    local done = mapping.wasReleased()
    print("held=" .. tostring(held) .. " just=" .. tostring(just) .. " done=" .. tostring(done))
end
```

---

### `lurek.input.onRebind`

Registers a callback invoked whenever bindings change via bind, unbind, define, or deserializeBindings.

```lua
-- signature
lurek.input.onRebind(callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `callback` | `function` | function(action_name, new_keys) called on any change. |

**Example**

```lua
do
    lurek.input.onRebind(function(action, keys)
        print("rebind: " .. action .. " keys=" .. #keys)
    end)
    print("onRebind registered")
end
```

---

### `lurek.input.reset`

Removes bindings for one action by name, or all actions when name is nil.

```lua
-- signature
lurek.input.reset(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name?` | `string` | Action name. When nil, all actions are removed. |

**Example**

```lua
do
    lurek.input.bind("temp", "t")
    lurek.input.reset("temp")
    print("reset(name) ok")
    lurek.input.reset()
    print("reset() ok")
end
```

---

### `lurek.input.serializeBindings`

Serialises all action definitions to a JSON string.

```lua
-- signature
lurek.input.serializeBindings()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | JSON representation of all action definitions. |

**Example**

```lua
do
    lurek.input.bind("test_ser", "s")
    local json = lurek.input.serializeBindings()
    print("serializeBindings len=" .. #json)
    lurek.input.reset()
end
```

---

### `lurek.input.startPlayback`

Starts playback of the loaded recording.

```lua
-- signature
lurek.input.startPlayback()
```

**Example**

```lua
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
```

---

### `lurek.input.startRecording`

Starts recording input events into the module recorder.

```lua
-- signature
lurek.input.startRecording()
```

**Example**

```lua
do
    lurek.input.startRecording()
    local recording = lurek.input.stopRecording()
    print("captured = " .. tostring(recording ~= nil))
end
```

---

### `lurek.input.stopPlayback`

Stops playback of the loaded recording.

```lua
-- signature
lurek.input.stopPlayback()
```

**Example**

```lua
do
    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    if rec then lurek.input.loadRecording(rec:toJson()); lurek.input.startPlayback() end
    lurek.input.stopPlayback()
    print("is_playing=" .. tostring(lurek.input.isPlayingBack()))
end
```

---

### `lurek.input.stopRecording`

Stops input recording and returns the captured recording when one is active.

```lua
-- signature
lurek.input.stopRecording()
```

**Returns**

| Type | Description |
|------|-------------|
| `LInputRecording` | Recording handle, or nil when recording was not active. |

**Example**

```lua
do
    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    print("stopped recording=" .. tostring(rec ~= nil))
end
```

---

### `lurek.input.unbind`

Removes all bindings for an action.

```lua
-- signature
lurek.input.unbind(action)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `action` | `string` | Action name. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the action had bindings. |

**Example**

```lua
do
    lurek.input.bind("temp", "t")
    local had = lurek.input.unbind("temp")
    print("unbind had bindings = " .. tostring(had))
end
```

---

### `lurek.input.wasActionPressed`

Returns whether any binding for an action was pressed this frame and records the frame.

```lua
-- signature
lurek.input.wasActionPressed(action)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `action` | `string` | Action name. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when any binding was pressed this frame. |

**Example**

```lua
do
    lurek.input.bind("jump", "space")
    local pressed = lurek.input.wasActionPressed("jump")
    print("jump pressed = " .. tostring(pressed))
end
```

---

### `lurek.input.wasActionPressedWithin`

Returns whether an action was pressed within a recent frame window.

```lua
-- signature
lurek.input.wasActionPressedWithin(action, frames)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `action` | `string` | Action name. |
| `frames` | `number` | Number of frames allowed since the last press. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the action was pressed within the window. |

**Example**

```lua
do
    lurek.input.bind("dodge", "shift")
    local recent = lurek.input.wasActionPressedWithin("dodge", 10)
    print("dodge recent = " .. tostring(recent))
end
```

---

### `lurek.input.wasActionReleased`

Returns whether any binding for an action was released this frame.

```lua
-- signature
lurek.input.wasActionReleased(action)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `action` | `string` | Action name. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when any binding was released this frame. |

**Example**

```lua
do
    lurek.input.bind("run", "shift")
    local released = lurek.input.wasActionReleased("run")
    print("run released = " .. tostring(released))
end
```

---

### `lurek.input.wasPressed`

Returns whether any bound key for this mapping was pressed this frame.

```lua
-- signature
lurek.input.wasPressed()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when any bound key was pressed. |

**Example**

```lua
do
    -- wasPressed() is true on the first frame the key goes down; call inside event callback
    local v = lurek.input.wasPressed()
    print("wasPressed available = " .. tostring(type(lurek.input.wasPressed) == "function"))
    print("result type = " .. type(v))
end
```

---

### `lurek.input.wasReleased`

Returns whether any bound key for this mapping was released this frame.

```lua
-- signature
lurek.input.wasReleased()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when any bound key was released. |

**Example**

```lua
do
    -- wasReleased(key) is true on the first frame the key goes up
    local v = lurek.input.wasReleased("space")
    print("wasReleased available = " .. tostring(type(lurek.input.wasReleased) == "function"))
    print("space released = " .. tostring(v))
end
```

---

## LCombo

### `LCombo:feed`

Feeds one key into the combo detector and returns progress status.

```lua
-- signature
LCombo:feed(key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | `string` | Key name to feed into the combo sequence. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | `completed`, `advanced`, `broken`, or `idle`. |

**Example**

```lua
do
    local combo = lurek.input.newCombo({"a", "b", "c"})
    local result = combo:feed("a")
    print("feed a → " .. result)
end
```

---

### `LCombo:getStep`

Returns step data by one-based index.

```lua
-- signature
LCombo:getStep(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | `number` | One-based combo step index. |

**Returns**

| Type | Description |
|------|-------------|
| `LComboGetStepResult` | Step table with `key` and `gap_ms`, or nil when out of range. |

**Example**

```lua
do
    local combo = lurek.input.newCombo({"a", "b"})
    local step = combo:getStep(1)
    print("step 1 key = " .. step.key .. " gap = " .. step.gap_ms)
end
```

---

### `LCombo:isInProgress`

Returns whether the combo sequence is partially matched.

```lua
-- signature
LCombo:isInProgress()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the combo is in progress. |

**Example**

```lua
do
    local combo = lurek.input.newCombo({ "a", "b", "c" })
    combo:feed("a")
    combo:tick(0.016)
    print("in_progress=" .. tostring(combo:isInProgress()))
end
```

---

### `LCombo:progress`

Returns the current combo step index reached.

```lua
-- signature
LCombo:progress()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Number of completed combo steps. |

**Example**

```lua
do
    local combo = lurek.input.newCombo({ "a", "b", "c" })
    combo:feed("a")
    combo:tick(0.016)
    print("in_progress=" .. tostring(combo:isInProgress()))
    print("progress=" .. combo:progress())
end
```

---

### `LCombo:reset`

Resets combo progress and elapsed time.

```lua
-- signature
LCombo:reset()
```

**Example**

```lua
do
    local combo = lurek.input.newCombo({"q", "w", "e"})
    combo:feed("q")
    combo:reset()
    print("progress after reset = " .. combo:progress())
end
```

---

### `LCombo:tick`

Advances combo timeout state and returns progress status.

```lua
-- signature
LCombo:tick(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | `number` | Delta time in seconds. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | `expired`, `in_progress`, or `idle`. |

**Example**

```lua
do
    local combo = lurek.input.newCombo({"x", "y"}, {total_gap = 300})
    local result = combo:tick(0.016)
    print("tick → " .. result)
end
```

---

### `LCombo:totalSteps`

Returns the number of steps in this combo sequence.

```lua
-- signature
LCombo:totalSteps()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Total combo step count. |

**Example**

```lua
do
    local combo = lurek.input.newCombo({ "a", "b", "c" })
    combo:feed("a")
    combo:tick(0.016)
    print("total=" .. combo:totalSteps())
end
```

---

### `LCombo:type`

Returns the Lua-visible type name for this combo handle.

```lua
-- signature
LCombo:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LCombo`. |

**Example**

```lua
do
    local combo = lurek.input.newCombo({"a"})
    print("type = " .. combo:type())
    print("is Combo = " .. tostring(combo:typeOf("LCombo")))
end
```

---

### `LCombo:typeOf`

Returns whether this combo handle matches a supported type name.

```lua
-- signature
LCombo:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LCombo` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local combo = lurek.input.newCombo({"a"})
    print("type = " .. combo:type())
    print("is Combo = " .. tostring(combo:typeOf("LCombo")))
end
```

---

## LCursor

### `LCursor:getType`

Returns whether this cursor is a system cursor or custom cursor.

```lua
-- signature
LCursor:getType()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | `system` or `custom`. |

**Example**

```lua
do
    local sys_cursor = lurek.input.mouse.getSystemCursor("arrow")
    print("cursor type=" .. sys_cursor:type())
    print("cursor kind=" .. sys_cursor:getType())
    print("typeOf=" .. tostring(sys_cursor:typeOf("LCursor")))
    sys_cursor:release()
end
```

---

### `LCursor:release`

Releases cursor resources; currently a no-op for managed cursor handles.

```lua
-- signature
LCursor:release()
```

**Example**

```lua
do
    local sys_cursor = lurek.input.mouse.getSystemCursor("arrow")
    print("cursor type=" .. sys_cursor:type())
    print("cursor kind=" .. sys_cursor:getType())
    print("typeOf=" .. tostring(sys_cursor:typeOf("LCursor")))
    sys_cursor:release()
end
```

---

### `LCursor:type`

Returns the Lua-visible type name for this cursor handle.

```lua
-- signature
LCursor:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LCursor`. |

**Example**

```lua
do
    local sys_cursor = lurek.input.mouse.getSystemCursor("arrow")
    print("cursor type=" .. sys_cursor:type())
    print("cursor kind=" .. sys_cursor:getType())
    print("typeOf=" .. tostring(sys_cursor:typeOf("LCursor")))
    sys_cursor:release()
end
```

---

### `LCursor:typeOf`

Returns whether this cursor handle matches a supported type name.

```lua
-- signature
LCursor:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LCursor` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local sys_cursor = lurek.input.mouse.getSystemCursor("arrow")
    print("cursor type=" .. sys_cursor:type())
    print("cursor kind=" .. sys_cursor:getType())
    print("typeOf=" .. tostring(sys_cursor:typeOf("LCursor")))
    sys_cursor:release()
end
```

---

## LInputRecording

### `LInputRecording:frameCount`

Returns the number of event frames stored in this recording.

```lua
-- signature
LInputRecording:frameCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Stored event frame count. |

**Example**

```lua
do
    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    print("frames=" .. tostring(rec and rec:frameCount() or 0))
end
```

---

### `LInputRecording:toJson`

Serializes this input recording to JSON text.

```lua
-- signature
LInputRecording:toJson()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Recording JSON. |

**Example**

```lua
do
    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    local json = rec and rec:toJson() or ""
    print("json length = " .. #json)
end
```

---

### `LInputRecording:totalFrames`

Returns total frame count stored in this recording.

```lua
-- signature
LInputRecording:totalFrames()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Total recorded frames. |

**Example**

```lua
do
    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    print("total=" .. tostring(rec and rec:totalFrames() or 0))
end
```

---

### `LInputRecording:type`

Returns the Lua-visible type name for this input recording handle.

```lua
-- signature
LInputRecording:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LInputRecording`. |

**Example**

```lua
do
    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    print("type=" .. tostring(rec and rec:type() or nil))
end
```

---

### `LInputRecording:typeOf`

Returns whether this input recording handle matches a supported type name.

```lua
-- signature
LInputRecording:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LInputRecording` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    print("typeOf=" .. tostring(rec and rec:typeOf("LInputRecording") or false))
end
```

---
