# Cinematic

## Purpose

Multi-track timeline system for orchestrating game sequences.

## When To Use

- Use this module when a script needs the `cinematic` runtime capability through `lurek.*`.

## Minimal Example

From the `lurek.cinematic.newTimeline` example block:

```lua
do
    local timeline = lurek.cinematic.newTimeline()
    timeline:addTrack("camera")
    local state = timeline:getState()
    local type_name = timeline:type()
    cinematic_log("new timeline type=" .. type_name .. " state=" .. state)
end
```

## Common Patterns

- Start with `lurek.cinematic.new` when exploring this module.
- Start with `lurek.cinematic.newTimeline` when exploring this module.

## API Reference

- Full generated API reference: [docs/api/lurek.md](../api/lurek.md)
- Runnable example owner: `content/examples/cinematic.lua`

## Summary

The `cinematic` module is the timeline authoring surface for cutscenes, scripted reveals, and other multi-system sequences. It lets motion, camera, audio, tween, and signal tracks advance against one playhead so designers can choreograph timing instead of hand-synchronizing callbacks. Playback controls such as play, pause, seek, loop, labels, and branching keep the same timeline useful for both fixed sequences and reactive presentation logic. It gives multi-system presentation one explicit sequencing surface inside the engine.

This module is mostly self-contained inside the `Edge/Integration` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Functions

### `lurek.cinematic.new`

Creates a new empty cinematic timeline handle (legacy cut-based API).

```lua
lurek.cinematic.new()
```

**Returns**

| Type | Description |
|------|-------------|
| [LCinematic](#lcinematic) | New cinematic handle. |

**Example**

```lua
do
    local cinematic = lurek.cinematic.new()
    cinematic:addCut(0.0, "fade_from_black")
    local type_name = cinematic:type()
    local cuts = cinematic:cutCount()
    cinematic_log("legacy cinematic type=" .. type_name .. " cuts=" .. cuts)
end
```

---

### `lurek.cinematic.newTimeline`

Creates a new multi-track timeline for modern cinematic support.

```lua
lurek.cinematic.newTimeline()
```

**Returns**

| Type | Description |
|------|-------------|
| [LCinematicTimeline](#lcinematictimeline) | New timeline handle. |

**Example**

```lua
do
    local timeline = lurek.cinematic.newTimeline()
    timeline:addTrack("camera")
    local state = timeline:getState()
    local type_name = timeline:type()
    cinematic_log("new timeline type=" .. type_name .. " state=" .. state)
end
```

---

## Module Fields

*No module-level fields documented.*

## Callbacks

*No callback parameters documented in this module.*

## Enums

*No module-specific enums documented.*

## Types

- [LCinematic](#lcinematic)
- [LCinematicTimeline](#lcinematictimeline)

## LCinematic

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LCinematic:addCut`

Appends a timed cut to the cinematic timeline.

```lua
LCinematic:addCut(time, description)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `time` | number | Time in seconds when the cut fires. |
| `description` | string | Human-readable cut label. |

**Example**

```lua
do
    local cinematic = lurek.cinematic.new()
    cinematic:addCut(0.0, "intro_pan")
    cinematic:addCut(1.5, "player_reveal")
    local cuts = cinematic:cutCount()
    cinematic_log("legacy cut list size after addCut=" .. tostring(cuts))
end
```

---

#### `LCinematic:clear`

Removes all cuts from the timeline.

```lua
LCinematic:clear()
```

**Example**

```lua
do
    local cinematic = lurek.cinematic.new()
    cinematic:addCut(0.0, "temp_intro")
    cinematic:addCut(0.5, "temp_pan")
    cinematic:clear()
    cinematic_log("clear removed all cuts count=" .. tostring(cinematic:cutCount()))
end
```

---

#### `LCinematic:cutCount`

Returns the number of cuts in the timeline.

```lua
LCinematic:cutCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Cut count. |

**Example**

```lua
do
    local cinematic = lurek.cinematic.new()
    cinematic:addCut(0.0, "drone_establish")
    cinematic:addCut(2.0, "control_room_zoom")
    local cuts = cinematic:cutCount()
    cinematic_log("cutCount reports " .. tostring(cuts) .. " queued legacy cuts")
end
```

---

#### `LCinematic:play`

Plays back the timeline by firing all cuts in order.

```lua
LCinematic:play()
```

**Example**

```lua
do
    local cinematic = lurek.cinematic.new()
    cinematic:addCut(0.0, "alarm_start")
    cinematic:addCut(0.5, "lights_flash")
    cinematic:play()
    cinematic_log("legacy cut list played with " .. tostring(cinematic:cutCount()) .. " cuts")
end
```

---

#### `LCinematic:type`

Returns the Lua-visible type name.

```lua
LCinematic:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always `"[LCinematic](#lcinematic)"`. |

**Example**

```lua
do
    local cinematic = lurek.cinematic.new()
    cinematic:addCut(0.0, "intro")
    local type_name = cinematic:type()
    local cuts = cinematic:cutCount()
    cinematic_log("legacy cinematic type=" .. type_name .. " cuts=" .. tostring(cuts))
end
```

---

#### `LCinematic:typeOf`

Checks whether this object matches the given type name.

```lua
LCinematic:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check (e.g. `"[LCinematic](#lcinematic)"`, `"Object"`). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the name matches. |

**Example**

```lua
do
    local cinematic = lurek.cinematic.new()
    cinematic:addCut(0.0, "intro")
    local is_cinematic = cinematic:typeOf("LCinematic")
    local is_object = cinematic:typeOf("Object")
    cinematic_log("typeOf cinematic=" .. tostring(is_cinematic) .. " object=" .. tostring(is_object))
end
```

---

## LCinematicTimeline

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LCinematicTimeline:addClip`

Adds a clip to a named track (creates track if missing).

```lua
LCinematicTimeline:addClip(track_name, at, duration, clip_table)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `track_name` | string | Target track name. |
| `at` | number | Start time in seconds. |
| `duration` | number | Clip duration in seconds. |
| `clip_table` | table | Clip definition with type-specific data. |

**Example**

```lua
do
    local timeline = lurek.cinematic.newTimeline()
    timeline:addTrack("camera")
    timeline:addTrack("signals")
    timeline:addClip("camera", 0.0, 3.0, { type = "camera", x = 100.0, y = 50.0, zoom = 2.0, easing = "ease_out_quad" })
    timeline:addClip("signals", 2.0, 0.1, { type = "signal", name = "boss_gate_open", data = "phase_1" })
    cinematic_log("timeline duration after camera and signal clips=" .. timeline:getDuration())
end
```

---

#### `LCinematicTimeline:addLabel`

Registers a named time position for branching.

```lua
LCinematicTimeline:addLabel(name, time)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Label name. |
| `time` | number | Time in seconds. |

**Example**

```lua
do
    local timeline = make_timeline_with_signal_clip()
    timeline:addLabel("intro", 0.0)
    timeline:addLabel("reveal", 1.0)
    timeline:addLabel("exit", 2.0)
    cinematic_log("labels added for intro, reveal, and exit on duration=" .. timeline:getDuration())
end
```

---

#### `LCinematicTimeline:addTrack`

Adds a named track to this cinematic timeline.

```lua
LCinematicTimeline:addTrack(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Track name for identification. |

**Returns**

| Type | Description |
|------|-------------|
| nil | No value is returned. |

**Example**

```lua
do
    local timeline = lurek.cinematic.newTimeline()
    timeline:addTrack("camera")
    timeline:addTrack("audio")
    local state = timeline:getState()
    cinematic_log("registered tracks for cutscene setup state=" .. state)
end
```

---

#### `LCinematicTimeline:branch`

Jumps playback to a named label position.

```lua
LCinematicTimeline:branch(label)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | string | Label name to jump to. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if label was found and jumped to. |

**Example**

```lua
do
    local timeline = make_timeline_with_signal_clip()
    timeline:addLabel("checkpoint", 1.5)
    timeline:seek(0.25)
    local ok = timeline:branch("checkpoint")
    cinematic_log("branch jumped=" .. tostring(ok) .. " playhead=" .. timeline:getTime())
end
```

---

#### `LCinematicTimeline:getDuration`

Returns the total duration of the timeline.

```lua
LCinematicTimeline:getDuration()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Duration in seconds. |

**Example**

```lua
do
    local timeline = lurek.cinematic.newTimeline()
    timeline:addTrack("signals")
    timeline:addClip("signals", 0.0, 5.0, { type = "signal", name = "intro" })
    timeline:addClip("signals", 2.0, 8.0, { type = "signal", name = "boss_reveal" })
    cinematic_log("timeline duration follows latest clip end=" .. timeline:getDuration())
end
```

---

#### `LCinematicTimeline:getState`

Returns the playback state as a string.

```lua
LCinematicTimeline:getState()
```

**Returns**

| Type | Description |
|------|-------------|
| string | One of "stopped", "playing", "paused". |

**Example**

```lua
do
    local timeline = make_timeline_with_signal_clip()
    local before = timeline:getState()
    timeline:play()
    local after = timeline:getState()
    cinematic_log("state changed from " .. before .. " to " .. after)
end
```

---

#### `LCinematicTimeline:getTime`

Returns the current playback time.

```lua
LCinematicTimeline:getTime()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current time in seconds. |

**Example**

```lua
do
    local timeline = make_timeline_with_signal_clip()
    timeline:seek(0.6)
    local time = timeline:getTime()
    local duration = timeline:getDuration()
    cinematic_log("current cinematic time=" .. time .. " within duration=" .. duration)
end
```

---

#### `LCinematicTimeline:isComplete`

Checks if playback has reached the end.

```lua
LCinematicTimeline:isComplete()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if complete. |

**Example**

```lua
do
    local timeline = make_timeline_with_signal_clip()
    local before = timeline:isComplete()
    timeline:skipToEnd()
    local after = timeline:isComplete()
    cinematic_log("isComplete before=" .. tostring(before) .. " after=" .. tostring(after))
end
```

---

#### `LCinematicTimeline:isPlaying`

Checks if the timeline is currently playing.

```lua
LCinematicTimeline:isPlaying()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if playing. |

**Example**

```lua
do
    local timeline = make_timeline_with_signal_clip()
    local before = timeline:isPlaying()
    timeline:play()
    local after = timeline:isPlaying()
    cinematic_log("isPlaying before=" .. tostring(before) .. " after=" .. tostring(after))
end
```

---

#### `LCinematicTimeline:pause`

Pauses playback without resetting time.

```lua
LCinematicTimeline:pause()
```

**Example**

```lua
do
    local timeline = make_timeline_with_signal_clip()
    timeline:play()
    timeline:update(1.25)
    timeline:pause()
    cinematic_log("pause kept playhead at " .. timeline:getTime() .. " with state=" .. timeline:getState())
end
```

---

#### `LCinematicTimeline:play`

Starts playback from the current time.

```lua
LCinematicTimeline:play()
```

**Example**

```lua
do
    local timeline = make_timeline_with_signal_clip()
    timeline:play()
    local state = timeline:getState()
    local playing = timeline:isPlaying()
    cinematic_log("play moved timeline to state=" .. state .. " playing=" .. tostring(playing))
end
```

---

#### `LCinematicTimeline:seek`

Jumps playback to a specific timeline time.

```lua
LCinematicTimeline:seek(time)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `time` | number | Time in seconds. |

**Example**

```lua
do
    local timeline = make_timeline_with_signal_clip()
    timeline:addClip("signals", 3.0, 1.0, { type = "signal", name = "camera_pan", data = "phase_2" })
    timeline:seek(1.75)
    local time = timeline:getTime()
    cinematic_log("seek positioned playhead at " .. time .. " seconds")
end
```

---

#### `LCinematicTimeline:skipToEnd`

Instantly jumps to the end of the timeline.

```lua
LCinematicTimeline:skipToEnd()
```

**Example**

```lua
do
    local timeline = make_timeline_with_signal_clip()
    local duration = timeline:getDuration()
    timeline:skipToEnd()
    local time = timeline:getTime()
    cinematic_log("skipToEnd jumped from 0 to " .. time .. " of " .. duration)
end
```

---

#### `LCinematicTimeline:stop`

Stops playback and resets to time 0.

```lua
LCinematicTimeline:stop()
```

**Example**

```lua
do
    local timeline = make_timeline_with_signal_clip()
    timeline:play()
    timeline:update(1.5)
    timeline:stop()
    cinematic_log("stop reset time=" .. timeline:getTime() .. " state=" .. timeline:getState())
end
```

---

#### `LCinematicTimeline:type`

Returns the Lua-visible type name.

```lua
LCinematicTimeline:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always `"[LCinematicTimeline](#lcinematictimeline)"`. |

**Example**

```lua
do
    local timeline = make_timeline_with_signal_clip()
    timeline:seek(0.5)
    local type_name = timeline:type()
    local state = timeline:getState()
    cinematic_log("timeline userdata type=" .. type_name .. " state=" .. state)
end
```

---

#### `LCinematicTimeline:typeOf`

Checks whether this object matches the given type name.

```lua
LCinematicTimeline:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the name matches. |

**Example**

```lua
do
    local timeline = make_timeline_with_signal_clip()
    timeline:play()
    local is_timeline = timeline:typeOf("LCinematicTimeline")
    local is_object = timeline:typeOf("Object")
    cinematic_log("typeOf timeline=" .. tostring(is_timeline) .. " object=" .. tostring(is_object))
end
```

---

#### `LCinematicTimeline:update`

Advances time by dt (only if playing).

```lua
LCinematicTimeline:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Delta time in seconds. |

**Example**

```lua
do
    local timeline = make_timeline_with_signal_clip()
    timeline:play()
    timeline:update(0.75)
    local time = timeline:getTime()
    local state = timeline:getState()
    cinematic_log("update advanced cutscene to " .. time .. " with state=" .. state)
end
```

---
