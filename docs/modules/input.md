# Input

## Purpose

Unifies keyboard, mouse, gamepad slotting, and touch events into stable inputs. - Supports custom action-bindings, gesture combo timing, and JSON input replays.

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

## API Reference

- This page is the generated API reference for this module.

## Functions

### `lurek.input.advancePlayback`

Advances playback by one frame and returns events for that frame.

```lua
lurek.input.advancePlayback()
```

**Returns**

| Type | Description |
|------|-------------|
| LInputAdvancePlaybackResult | Array of event records with `kind` and `name` fields. |

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
    local frame = lurek.input.getPlaybackFrame()
    lurek.log.info("playback events=" .. #events)
    lurek.log.info("playback advanced frame=" .. tostring(frame))
    lurek.input.stopPlayback()
end
```

---

### `lurek.input.bind`

Adds one or more keyboard/gamepad bindings to an action.

```lua
lurek.input.bind(action, keys)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `action` | string | Action name. |
| `keys` | any | Binding string or array table of binding strings. |

**Example**

```lua
do

    lurek.input.bind("jump", "space")
    lurek.input.bind("move_left", {"a", "left"})
    local bindings = lurek.input.getBindings()
    local jumpBindings = rawget(bindings, "jump") or {}
    lurek.log.info("actions bound total=" .. tostring(#jumpBindings))
    lurek.log.info("actions bound has move_left=" .. tostring(rawget(bindings, "move_left") ~= nil))
    lurek.input.reset()
end
```

---

### `lurek.input.clearBindings`

Removes all action bindings from the map.

```lua
lurek.input.clearBindings()
```

**Example**

```lua
do

    lurek.input.bind("a1", "q")
    lurek.input.bind("a2", "e")
    local before = lurek.input.getBindings()
    lurek.input.clearBindings()
    local after = lurek.input.getBindings()
    lurek.log.info("clearBindings before a1=" .. tostring(rawget(before, "a1") ~= nil))
    lurek.log.info("clearBindings after a1=" .. tostring(rawget(after, "a1") ~= nil))
end
```

---

### `lurek.input.define`

Defines an action with a full set of bindings and an optional category, replacing any prior definition.

```lua
lurek.input.define(name, bindings, category)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Action name. |
| `bindings` | any | Binding string or array of binding strings. |
| `category?` | string | Category label for grouping (default empty string). |

**Example**

```lua
do

    lurek.input.define("jump", {"space", "up"}, "movement")
    lurek.input.define("pause", {"escape", "p"}, "system")
    local movement = lurek.input.getByCategory("movement")
    local system = lurek.input.getByCategory("system")
    lurek.log.info("define movement count=" .. tostring(#movement))
    lurek.log.info("define system count=" .. tostring(#system))
    lurek.input.reset()
end
```

---

### `lurek.input.deserializeBindings`

Loads action definitions from a JSON string produced by serializeBindings, replacing all current definitions.

```lua
lurek.input.deserializeBindings(json)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `json` | string | JSON string with action definitions. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True on success. |

**Example**

```lua
do

    lurek.input.bind("test_deser", "q")
    local json = lurek.input.serializeBindings()
    lurek.input.reset()
    local ok = lurek.input.deserializeBindings(json)
    lurek.log.info(tostring("deserializeBindings=" .. tostring(ok)))
    lurek.input.reset()
end
```

---

### `lurek.input.getAxis`

Returns -1.0, 0.0, or +1.0 for a named action; first binding is positive, second is negative.

```lua
lurek.input.getAxis(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Action name. |

**Returns**

| Type | Description |
|------|-------------|
| number | Axis value: +1.0, -1.0, or 0.0. |

**Example**

```lua
do

    lurek.input.bind("move_x", {"d", "a"})
    local v = lurek.input.getAxis("move_x")
    local mapping = rawget(lurek.input.getBindings(), "move_x") or {}
    lurek.log.info("axis move_x value=" .. tostring(v))
    lurek.log.info("axis move_x bindings=" .. tostring(#mapping))
    lurek.input.reset()
end
```

---

### `lurek.input.getBindings`

Returns all registered action bindings.

```lua
lurek.input.getBindings()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Map table from action names to arrays of binding strings. |

**Example**

```lua
do

    lurek.input.bind("shoot", "x")
    local bindings = lurek.input.getBindings()
    local shoot = rawget(bindings, "shoot") or {}
    lurek.log.info(tostring("has shoot = " .. tostring(rawget(bindings, "shoot") ~= nil)))
    lurek.log.info(tostring("shoot bindings = " .. #shoot))
end
```

---

### `lurek.input.getByCategory`

Returns action names belonging to the given category.

```lua
lurek.input.getByCategory(category)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `category` | string | Category label. |

**Returns**

| Type | Description |
|------|-------------|
| string[] | Array of matching action names. |

**Example**

```lua
do

    lurek.input.define("run", "lshift", "movement")
    local cats = lurek.input.getByCategory("movement")
    lurek.input.define("jump", "space", "movement")
    local first = cats[1] or "none"
    lurek.log.info("getByCategory count=" .. #cats)
    lurek.log.info("getByCategory first=" .. tostring(first))
    lurek.input.reset()
end
```

---

### `lurek.input.getConflicts`

Returns a table mapping each binding key to the action names that share it; only keys with two or more actions are included.

```lua
lurek.input.getConflicts()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Map of binding string to array of conflicting action names. |

**Example**

```lua
do

    lurek.input.bind("act_a", "x")
    lurek.input.bind("act_b", "x")
    local c = lurek.input.getConflicts()
    lurek.log.info(tostring("getConflicts type=" .. type(c)))
    lurek.input.reset()
end
```

---

### `lurek.input.getPlaybackFrame`

Returns the current playback frame index.

```lua
lurek.input.getPlaybackFrame()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Playback frame index. |

**Example**

```lua
do

    local frame = lurek.input.getPlaybackFrame()
    local playing = lurek.input.isPlayingBack()
    local recording = lurek.input.isRecording()
    lurek.log.info("playback frame=" .. frame)
    lurek.log.info("playback active=" .. tostring(playing) .. " recording=" .. tostring(recording))
end
```

---

### `lurek.input.getVector`

Returns a 2D axis vector from two named actions.

```lua
lurek.input.getVector(hname, vname)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `hname` | string | Horizontal action name (positive = right). |
| `vname` | string | Vertical action name (positive = down). |

**Returns**

| Type | Description |
|------|-------------|
| number | Horizontal axis value. |
| number | Vertical axis value. |

**Example**

```lua
do

    lurek.input.bind("haxis", {"d", "a"})
    lurek.input.bind("vaxis", {"s", "w"})
    local h, v = lurek.input.getVector("haxis", "vaxis")
    lurek.log.info(tostring("getVector=" .. tostring(h) .. "," .. tostring(v)))
    lurek.input.reset()
end
```

---

### `lurek.input.isActionDown`

Returns whether any binding for an action is currently down.

```lua
lurek.input.isActionDown(action)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `action` | string | Action name. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when any binding is down. |

**Example**

```lua
do

    lurek.input.bind("fire", "space")
    local down = lurek.input.isActionDown("fire")
    local exists = rawget(lurek.input.getBindings(), "fire") ~= nil
    lurek.log.info("combat fire bound=" .. tostring(exists))
    lurek.log.info("combat fire down=" .. tostring(down))
    lurek.input.reset()
end
```

---

### `lurek.input.isDown`

Returns whether any bound key for this mapping is currently down.

```lua
lurek.input.isDown()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when any bound key is down. |

**Example**

```lua
do

    local hasHelper = type(lurek.input.isDown) == "function"
    local keyboardDown = lurek.input.keyboard.isDown("a")
    local mapping = lurek.input.newMapping("move_left", {"a", "left"})
    local mappingDown = mapping.isDown()
    lurek.log.info("mapping isDown helper=" .. tostring(hasHelper) .. " keyboardDown=" .. tostring(keyboardDown))
    lurek.log.info("mapping move_left down=" .. tostring(mappingDown))
end
```

---

### `lurek.input.isPlayingBack`

Returns whether the module recorder is currently playing back.

```lua
lurek.input.isPlayingBack()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when playback is active. |

**Example**

```lua
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
```

---

### `lurek.input.isRecording`

Returns whether the module recorder is currently recording.

```lua
lurek.input.isRecording()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when recording is active. |

**Example**

```lua
do

    local before = lurek.input.isRecording()
    lurek.input.startRecording()
    local during = lurek.input.isRecording()
    local rec = lurek.input.stopRecording()
    lurek.log.info("recording before=" .. tostring(before) .. " during=" .. tostring(during))
    lurek.log.info("recording object returned=" .. tostring(rec ~= nil))
end
```

---

### `lurek.input.loadRecording`

Loads recording JSON into the module recorder.

```lua
lurek.input.loadRecording(json)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `json` | string | Recording JSON. |

**Example**

```lua
do

    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    if rec then lurek.input.loadRecording(rec:toJson()) end
    local frame = lurek.input.getPlaybackFrame()
    local loaded = rec ~= nil
    lurek.log.info("recording loaded=" .. tostring(loaded))
    lurek.log.info("recording playback frame=" .. tostring(frame))
end
```

---

### `lurek.input.newCombo`

Creates a combo detector from string steps or step tables with optional timing.

```lua
lurek.input.newCombo(steps, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `steps` | table | Array table of key strings or `{key, gap}` step tables. |
| `opts?` | table | Options table with `total_gap` in milliseconds. |

**Returns**

| Type | Description |
|------|-------------|
| [LCombo](#lcombo) | New combo detector handle. |

**Example**

```lua
do

    local combo = lurek.input.newCombo({"down", "right", "z"}, {total_gap = 500})
    local step1 = combo:getStep(1)
    local progress = combo:progress()
    lurek.log.info("combo total steps=" .. combo:totalSteps() .. " first=" .. tostring(step1.key))
    lurek.log.info("combo in progress=" .. tostring(combo:isInProgress()) .. " progress=" .. progress)
end
```

---

### `lurek.input.newMapping`

Creates an action mapping table with isDown, wasPressed, and wasReleased helper functions.

```lua
lurek.input.newMapping(name, keys)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Action name. |
| `keys` | any | Binding string or array table of binding strings. |

**Returns**

| Type | Description |
|------|-------------|
| LInputNewMappingResult | Mapping table with action query closures. |

**Example**

```lua
do

    local mapping = lurek.input.newMapping("attack", {"z", "button1"})
    local held = mapping.isDown()
    local just = mapping.wasPressed()
    local done = mapping.wasReleased()
    lurek.log.info(tostring("held=" .. tostring(held) .. " just=" .. tostring(just) .. " done=" .. tostring(done)))
end
```

---

### `lurek.input.onRebind`

Registers a callback invoked whenever bindings change via bind, unbind, define, or deserializeBindings.

```lua
lurek.input.onRebind(callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `callback` | function | function(action_name, new_keys) called on any change. |

**Example**

```lua
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
```

---

### `lurek.input.reset`

Removes bindings for one action by name, or all actions when name is nil.

```lua
lurek.input.reset(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name?` | string | Action name. When nil, all actions are removed. |

**Example**

```lua
do

    lurek.input.bind("temp", "t")
    lurek.input.reset("temp")
    lurek.log.info(tostring("reset(name) ok"))
    lurek.input.reset()
    lurek.log.info(tostring("reset() ok"))
end
```

---

### `lurek.input.serializeBindings`

Serialises all action definitions to a JSON string.

```lua
lurek.input.serializeBindings()
```

**Returns**

| Type | Description |
|------|-------------|
| string | JSON representation of all action definitions. |

**Example**

```lua
do

    lurek.input.bind("test_ser", "s")
    local json = lurek.input.serializeBindings()
    local hasAction = json:find("test_ser", 1, true) ~= nil
    lurek.log.info("serializeBindings len=" .. #json)
    lurek.log.info("serializeBindings has action=" .. tostring(hasAction))
    lurek.input.reset()
end
```

---

### `lurek.input.startPlayback`

Starts playback of the loaded recording.

```lua
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
    local playing = lurek.input.isPlayingBack()
    local frame = lurek.input.getPlaybackFrame()
    lurek.log.info("playback started=" .. tostring(playing))
    lurek.log.info("playback frame=" .. tostring(frame))
    lurek.input.stopPlayback()
end
```

---

### `lurek.input.startRecording`

Starts recording input events into the module recorder.

```lua
lurek.input.startRecording()
```

**Example**

```lua
do

    lurek.input.startRecording()
    local recording = lurek.input.stopRecording()
    local frames = recording and recording:frameCount() or 0
    local typeName = recording and recording:type() or "nil"
    lurek.log.info("recording captured=" .. tostring(recording ~= nil))
    lurek.log.info("recording frames=" .. tostring(frames) .. " type=" .. tostring(typeName))
end
```

---

### `lurek.input.stopPlayback`

Stops playback of the loaded recording.

```lua
lurek.input.stopPlayback()
```

**Example**

```lua
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
```

---

### `lurek.input.stopRecording`

Stops input recording and returns the captured recording when one is active.

```lua
lurek.input.stopRecording()
```

**Returns**

| Type | Description |
|------|-------------|
| [LInputRecording](#linputrecording) | Recording handle, or nil when recording was not active. |

**Example**

```lua
do

    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    local frames = rec and rec:frameCount() or 0
    local json = rec and rec:toJson() or ""
    lurek.log.info("stopped recording=" .. tostring(rec ~= nil))
    lurek.log.info("stopped recording frames=" .. tostring(frames) .. " json_len=" .. tostring(#json))
end
```

---

### `lurek.input.unbind`

Removes all bindings for an action.

```lua
lurek.input.unbind(action)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `action` | string | Action name. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the action had bindings. |

**Example**

```lua
do

    lurek.input.bind("temp", "t")
    local had = lurek.input.unbind("temp")
    local bindings = lurek.input.getBindings()
    local stillPresent = rawget(bindings, "temp") ~= nil
    lurek.log.info("unbind had bindings=" .. tostring(had))
    lurek.log.info("unbind still present=" .. tostring(stillPresent))
    lurek.input.reset()
end
```

---

### `lurek.input.wasActionPressed`

Returns whether any binding for an action was pressed this frame and records the frame.

```lua
lurek.input.wasActionPressed(action)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `action` | string | Action name. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when any binding was pressed this frame. |

**Example**

```lua
do

    lurek.input.bind("jump", "space")
    local pressed = lurek.input.wasActionPressed("jump")
    local recent = lurek.input.wasActionPressedWithin("jump", 5)
    lurek.log.info("platform jump pressed=" .. tostring(pressed))
    lurek.log.info("platform jump recent=" .. tostring(recent))
    lurek.input.reset()
end
```

---

### `lurek.input.wasActionPressedWithin`

Returns whether an action was pressed within a recent frame window.

```lua
lurek.input.wasActionPressedWithin(action, frames)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `action` | string | Action name. |
| `frames` | number | Number of frames allowed since the last press. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the action was pressed within the window. |

**Example**

```lua
do

    lurek.input.bind("dodge", "shift")
    local recent = lurek.input.wasActionPressedWithin("dodge", 10)
    local pressed = lurek.input.wasActionPressed("dodge")
    lurek.log.info("action dodge recent=" .. tostring(recent))
    lurek.log.info("action dodge pressed_now=" .. tostring(pressed))
    lurek.input.reset()
end
```

---

### `lurek.input.wasActionReleased`

Returns whether any binding for an action was released this frame.

```lua
lurek.input.wasActionReleased(action)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `action` | string | Action name. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when any binding was released this frame. |

**Example**

```lua
do

    lurek.input.bind("run", "shift")
    local released = lurek.input.wasActionReleased("run")
    local down = lurek.input.isActionDown("run")
    lurek.log.info("action run released=" .. tostring(released))
    lurek.log.info("action run down=" .. tostring(down))
    lurek.input.reset()
end
```

---

### `lurek.input.wasPressed`

Returns whether any bound key for this mapping was pressed this frame.

```lua
lurek.input.wasPressed()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when any bound key was pressed. |

**Example**

```lua
do

    local has_was_pressed = type(lurek.input.wasPressed) == "function"
    local v = has_was_pressed and lurek.input.wasPressed() or false
    local mapping = lurek.input.newMapping("attack", {"z", "button1"})
    local mappingPressed = mapping.wasPressed()
    lurek.log.info("wasPressed available=" .. tostring(has_was_pressed))
    lurek.log.info("wasPressed result=" .. tostring(v) .. " mappingPressed=" .. tostring(mappingPressed))
end
```

---

### `lurek.input.wasReleased`

Returns whether any bound key for this mapping was released this frame.

```lua
lurek.input.wasReleased()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when any bound key was released. |

**Example**

```lua
do

    local has_was_released = type(lurek.input.wasReleased) == "function"
    local v = has_was_released and lurek.input.wasReleased() or false
    local mapping = lurek.input.newMapping("attack", {"z", "button1"})
    local mappingReleased = mapping.wasReleased()
    lurek.log.info("wasReleased available=" .. tostring(has_was_released))
    lurek.log.info("wasReleased result=" .. tostring(v) .. " mappingReleased=" .. tostring(mappingReleased))
end
```

---

## Module Fields

*No module-level fields documented.*

## Callback Parameters

- `lurek.input.onRebind` param `callback` (`function`): function(action_name, new_keys) called on any change.

## Enums

*No module-specific enums documented.*

## Types

- [LCombo](#lcombo)
- [LCursor](#lcursor)
- [LInputRecording](#linputrecording)

## LCombo

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LCombo:feed`

Feeds one key into the combo detector and returns progress status.

```lua
LCombo:feed(key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | Key name to feed into the combo sequence. |

**Returns**

| Type | Description |
|------|-------------|
| string | `completed`, `advanced`, `broken`, or `idle`. |

**Example**

```lua
do

    local combo = lurek.input.newCombo({"a", "b", "c"})
    local result = combo:feed("a")
    local progress = combo:progress()
    local inProgress = combo:isInProgress()
    lurek.log.info("combo feed a->" .. tostring(result))
    lurek.log.info("combo progress=" .. tostring(progress) .. " inProgress=" .. tostring(inProgress))
end
```

---

#### `LCombo:getStep`

Returns step data by one-based index.

```lua
LCombo:getStep(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | One-based combo step index. |

**Returns**

| Type | Description |
|------|-------------|
| LComboGetStepResult | Step table with `key` and `gap_ms`, or nil when out of range. |

**Example**

```lua
do

    local combo = lurek.input.newCombo({"a", "b"})
    local step = combo:getStep(1)
    local step2 = combo:getStep(2)
    lurek.log.info("combo step1 key=" .. tostring(step.key) .. " gap=" .. tostring(step.gap_ms))
    lurek.log.info("combo step2 key=" .. tostring(step2.key) .. " gap=" .. tostring(step2.gap_ms))
end
```

---

#### `LCombo:isInProgress`

Returns whether the combo sequence is partially matched.

```lua
LCombo:isInProgress()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the combo is in progress. |

**Example**

```lua
do

    local combo = lurek.input.newCombo({ "a", "b", "c" })
    combo:feed("a")
    combo:tick(0.016)
    local progress = combo:progress()
    local total = combo:totalSteps()
    lurek.log.info("combo in progress=" .. tostring(combo:isInProgress()))
    lurek.log.info("combo progress=" .. tostring(progress) .. " total=" .. tostring(total))
end
```

---

#### `LCombo:progress`

Returns the current combo step index reached.

```lua
LCombo:progress()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Number of completed combo steps. |

**Example**

```lua
do

    local combo = lurek.input.newCombo({ "a", "b", "c" })
    combo:feed("a")
    combo:tick(0.016)
    lurek.log.info(tostring("in_progress=" .. tostring(combo:isInProgress())))
    lurek.log.info(tostring("progress=" .. combo:progress()))
end
```

---

#### `LCombo:reset`

Resets combo progress and elapsed time.

```lua
LCombo:reset()
```

**Example**

```lua
do

    local combo = lurek.input.newCombo({"q", "w", "e"})
    combo:feed("q")
    local before = combo:progress()
    combo:reset()
    local after = combo:progress()
    lurek.log.info("combo progress before reset=" .. tostring(before))
    lurek.log.info("combo progress after reset=" .. tostring(after))
end
```

---

#### `LCombo:tick`

Advances combo timeout state and returns progress status.

```lua
LCombo:tick(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Delta time in seconds. |

**Returns**

| Type | Description |
|------|-------------|
| string | `expired`, `in_progress`, or `idle`. |

**Example**

```lua
do

    local combo = lurek.input.newCombo({"x", "y"}, {total_gap = 300})
    local result = combo:tick(0.016)
    local progress = combo:progress()
    local total = combo:totalSteps()
    lurek.log.info("combo tick->" .. tostring(result))
    lurek.log.info("combo progress=" .. tostring(progress) .. " total=" .. tostring(total))
end
```

---

#### `LCombo:totalSteps`

Returns the number of steps in this combo sequence.

```lua
LCombo:totalSteps()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Total combo step count. |

**Example**

```lua
do

    local combo = lurek.input.newCombo({ "a", "b", "c" })
    combo:feed("a")
    combo:tick(0.016)
    local progress = combo:progress()
    local inProgress = combo:isInProgress()
    lurek.log.info("combo total=" .. combo:totalSteps())
    lurek.log.info("combo progress=" .. tostring(progress) .. " inProgress=" .. tostring(inProgress))
end
```

---

#### `LCombo:type`

Returns the Lua-visible type name for this combo handle.

```lua
LCombo:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LCombo](#lcombo)`. |

**Example**

```lua
do

    local combo = lurek.input.newCombo({"a"})
    local total = combo:totalSteps()
    local progress = combo:progress()
    lurek.log.info("combo type=" .. combo:type() .. " total=" .. tostring(total))
    lurek.log.info("combo is LCombo=" .. tostring(combo:typeOf("LCombo")) .. " progress=" .. tostring(progress))
end
```

---

#### `LCombo:typeOf`

Returns whether this combo handle matches a supported type name.

```lua
LCombo:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LCombo](#lcombo)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do

    local combo = lurek.input.newCombo({"a"})
    local total = combo:totalSteps()
    local progress = combo:progress()
    lurek.log.info("combo typeOf LCombo=" .. tostring(combo:typeOf("LCombo")))
    lurek.log.info("combo type=" .. combo:type() .. " progress=" .. tostring(progress) .. " total=" .. tostring(total))
end
```

---

## LCursor

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LCursor:getType`

Returns whether this cursor is a system cursor or custom cursor.

```lua
LCursor:getType()
```

**Returns**

| Type | Description |
|------|-------------|
| string | `system` or `custom`. |

**Example**

```lua
do

    local sys_cursor = lurek.input.mouse.getSystemCursor("arrow")
    lurek.log.info(tostring("cursor type=" .. sys_cursor:type()))
    lurek.log.info(tostring("cursor kind=" .. sys_cursor:getType()))
    lurek.log.info(tostring("typeOf=" .. tostring(sys_cursor:typeOf("LCursor"))))
    sys_cursor:release()
end
```

---

#### `LCursor:release`

Releases cursor resources; currently a no-op for managed cursor handles.

```lua
LCursor:release()
```

**Example**

```lua
do

    local sys_cursor = lurek.input.mouse.getSystemCursor("arrow")
    lurek.log.info(tostring("cursor type=" .. sys_cursor:type()))
    lurek.log.info(tostring("cursor kind=" .. sys_cursor:getType()))
    lurek.log.info(tostring("typeOf=" .. tostring(sys_cursor:typeOf("LCursor"))))
    sys_cursor:release()
end
```

---

#### `LCursor:type`

Returns the Lua-visible type name for this cursor handle.

```lua
LCursor:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LCursor](#lcursor)`. |

**Example**

```lua
do

    local sys_cursor = lurek.input.mouse.getSystemCursor("arrow")
    lurek.log.info(tostring("cursor type=" .. sys_cursor:type()))
    lurek.log.info(tostring("cursor kind=" .. sys_cursor:getType()))
    lurek.log.info(tostring("typeOf=" .. tostring(sys_cursor:typeOf("LCursor"))))
    sys_cursor:release()
end
```

---

#### `LCursor:typeOf`

Returns whether this cursor handle matches a supported type name.

```lua
LCursor:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LCursor](#lcursor)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do

    local sys_cursor = lurek.input.mouse.getSystemCursor("arrow")
    lurek.log.info(tostring("cursor type=" .. sys_cursor:type()))
    lurek.log.info(tostring("cursor kind=" .. sys_cursor:getType()))
    lurek.log.info(tostring("typeOf=" .. tostring(sys_cursor:typeOf("LCursor"))))
    sys_cursor:release()
end
```

---

## LInputRecording

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LInputRecording:frameCount`

Returns the number of event frames stored in this recording.

```lua
LInputRecording:frameCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Stored event frame count. |

**Example**

```lua
do

    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    local frames = rec and rec:frameCount() or 0
    local total = rec and rec:totalFrames() or 0
    lurek.log.info("recording frameCount=" .. tostring(frames))
    lurek.log.info("recording totalFrames=" .. tostring(total))
end
```

---

#### `LInputRecording:toJson`

Serializes this input recording to JSON text.

```lua
LInputRecording:toJson()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Recording JSON. |

**Example**

```lua
do

    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    local json = rec and rec:toJson() or ""
    local frames = rec and rec:frameCount() or 0
    local total = rec and rec:totalFrames() or 0
    lurek.log.info("recording json length=" .. #json)
    lurek.log.info("recording frames=" .. tostring(frames) .. " total=" .. tostring(total))
end
```

---

#### `LInputRecording:totalFrames`

Returns total frame count stored in this recording.

```lua
LInputRecording:totalFrames()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Total recorded frames. |

**Example**

```lua
do

    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    local total = rec and rec:totalFrames() or 0
    local frames = rec and rec:frameCount() or 0
    lurek.log.info("recording totalFrames=" .. tostring(total))
    lurek.log.info("recording frameCount=" .. tostring(frames))
end
```

---

#### `LInputRecording:type`

Returns the Lua-visible type name for this input recording handle.

```lua
LInputRecording:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LInputRecording](#linputrecording)`. |

**Example**

```lua
do

    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    local typeName = rec and rec:type() or "nil"
    local frames = rec and rec:frameCount() or 0
    lurek.log.info("recording type=" .. tostring(typeName))
    lurek.log.info("recording frames=" .. tostring(frames))
end
```

---

#### `LInputRecording:typeOf`

Returns whether this input recording handle matches a supported type name.

```lua
LInputRecording:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LInputRecording](#linputrecording)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do

    lurek.input.startRecording()
    local rec = lurek.input.stopRecording()
    local isRecording = rec and rec:typeOf("LInputRecording") or false
    local typeName = rec and rec:type() or "nil"
    lurek.log.info("recording typeOf LInputRecording=" .. tostring(isRecording))
    lurek.log.info("recording type=" .. tostring(typeName))
end
```

---
