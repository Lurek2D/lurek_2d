# Animation

- The `animation` module provides a comprehensive sprite and skeletal animation runtime for Lurek2D, managing frame sequences, blend layers, parameter-driven state machines, and synchronization groups.

At its core, the module uses `AnimClip` to hold ordered sequences of `AnimFrame` entries, each specifying a source texture rectangle, an optional per-frame duration, and event triggers. This allows for both uniform and variable-timing animations. Playback is managed by the `Animation` controller, which handles forward, reverse, and ping-pong playback modes, along with looping and playback speed scaling.

To support complex character and entity animations, the module implements a robust `AnimStateMachine`. This finite-state machine (FSM) drives transitions between named animation clips based on configurable conditions. Transitions can evaluate float, integer, and boolean parameters using standard relational operators, enabling logic like switching from a 'running' state to a 'jumping' state when a velocity parameter exceeds a threshold. Furthermore, `BlendLayerSet` provides support for multi-layer additive and override mixing, allowing multiple animations to be combined—for instance, playing a 'shooting' animation on the upper body while a 'running' animation plays on the lower body.

For coordinated character movement and advanced timing, the `AnimSyncGroup` locks multiple animation keyframes to a shared normalized timeline. The module also includes `AnimCurve` and `AnimPropertyTimeline` to support easing-driven value interpolation along keyframes. These curves evaluate properties over time using step, linear, or custom easing functions, which are heavily utilized by higher-level animation systems to drive parameters smoothly.

The module offers seamless integration with external tools and formats. An Aseprite JSON importer (`load_aseprite_json`) parses exported frame tags into named clip ranges, supporting both array and object layouts while extracting per-frame durations. Additionally, a `SpineAnimBridge` maps the module's FSM states to Spine skeleton animations, allowing 2D skeletal animations to be controlled through the same uniform interface.

Finally, the module generates textured draw commands from active frame quads via the `render` utilities, tightly integrating with the engine's graphics pipeline. Lua bindings expose `LAnimation:draw` and `LAnimStateMachine:draw` as ergonomic helpers over the same current-frame rectangle returned by `getQuad`; these helpers queue one draw command when a frame is active, return `false` without mutating playback when no frame is active, and leave broader `lurek.render.draw` polymorphism unchanged. Both `:draw` methods accept two call forms: `draw(image, x, y, opts)` for explicit atlas passing and `draw(x, y, opts)` when a spritesheet has been stored in advance with `:setImage(image)`. The API is thoroughly exposed to Lua via the `lurek.animation` namespace, providing script developers with constructors for state machines, curves, blend layers, and synchronization groups, along with methods to advance playback and poll animation events. By importing only the `math` module and avoiding cyclic dependencies, the animation runtime remains fully headless-testable and architecturally isolated within the Feature Systems group.

## Functions

### `lurek.animation.buildCharacter`

Builds a character animation bundle from grid frame and clip configuration.

```lua
-- signature
lurek.animation.buildCharacter(cfg)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cfg` | `table` | Configuration table with texture size, frame size, clips, optional states, and optional transitions. |

**Returns**

| Type | Description |
|------|-------------|
| `AnimationBuildCharacterResult` | Table containing `animation` and, when states are supplied, `stateMachine` handles. |

**Example**

```lua
do
    local char = lurek.animation.buildCharacter({
        texW = 64,
        texH = 16,
        frameW = 16,
        frameH = 16,
        clips = {
            { name = "idle", start = 0, count = 2, fps = 4, looping = true, mode = "forward" }
        },
        states = {
            { name = "idle", clip = "idle", looping = true }
        },
        initialState = "idle"
    })
    print("character built = " .. tostring(char ~= nil))
    print("has animation = " .. tostring(char.animation ~= nil))
end
```

---

### `lurek.animation.fromAseprite`

Loads an animation from an Aseprite JSON export string.

```lua
-- signature
lurek.animation.fromAseprite(json_str)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `json_str` | `string` | Raw Aseprite JSON document contents. |

**Returns**

| Type | Description |
|------|-------------|
| `LuaValue` | Animation handle when parsing succeeds; raises an error when the JSON cannot be parsed. |

**Example**

```lua
do
    local json = '{"frames":[{"filename":"f0","frame":{"x":0,"y":0,"w":16,"h":16}}],"meta":{"size":{"w":16,"h":16},"frameTags":[]}}'
    local anim = lurek.animation.fromAseprite(json)
    if anim then
        print("from aseprite, clips = " .. anim:getClipCount())
        print("from aseprite, frames = " .. anim:getFrameCount())
    end
end
```

---

### `lurek.animation.new`

Creates an empty animation with no frames or clips.

```lua
-- signature
lurek.animation.new()
```

**Returns**

| Type | Description |
|------|-------------|
| `LAnimation` | New animation handle. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    print("animation created, frames = " .. anim:getFrameCount())
    print("animation type = " .. anim:type())
end
```

---

### `lurek.animation.newBlendLayerSet`

Creates an empty blend layer set for layered animation playback.

```lua
-- signature
lurek.animation.newBlendLayerSet()
```

**Returns**

| Type | Description |
|------|-------------|
| `LBlendLayerSet` | New blend layer set handle. |

**Example**

```lua
do
    local bls = lurek.animation.newBlendLayerSet()
    print("blend layer set created = " .. tostring(bls ~= nil))
    print("blend layer count = " .. bls:len())
end
```

---

### `lurek.animation.newCurve`

Creates an empty animation curve. This function is exposed to Lua scripts.

```lua
-- signature
lurek.animation.newCurve()
```

**Returns**

| Type | Description |
|------|-------------|
| `LAnimCurve` | New animation curve handle. |

**Example**

```lua
do
    local curve = lurek.animation.newCurve()
    print("curve created = " .. tostring(curve ~= nil))
    print("curve type = " .. curve:type())
end
```

---

### `lurek.animation.newStateMachine`

Creates an animation state machine by consuming an animation handle.

```lua
-- signature
lurek.animation.newStateMachine(anim_ud, initial)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `anim_ud` | `LAnimation` | Animation handle moved into the state machine. |
| `initial` | `string` | Initial state name stored in the state machine. |

**Returns**

| Type | Description |
|------|-------------|
| `LAnimStateMachine` | New animation state machine handle. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("idle", { 0 }, 1, true)
    local sm = lurek.animation.newStateMachine(anim, "idle")
    print("state machine created = " .. tostring(sm ~= nil))
    print("state machine type = " .. sm:type())
end
```

---

### `lurek.animation.newSyncGroup`

Creates an empty animation synchronization group.

```lua
-- signature
lurek.animation.newSyncGroup()
```

**Returns**

| Type | Description |
|------|-------------|
| `LAnimSyncGroup` | New animation sync group handle. |

**Example**

```lua
do
    local sg = lurek.animation.newSyncGroup()
    print("sync group created = " .. tostring(sg ~= nil))
    print("sync group members = " .. sg:memberCount())
end
```

---

## LAnimCurve

### `LAnimCurve:addKeyframe`

Adds a keyframe to the curve. This method is available to Lua scripts.

```lua
-- signature
LAnimCurve:addKeyframe(t, v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | `number` | Keyframe time or normalized position. |
| `v` | `number` | Keyframe value. |

**Example**

```lua
do
    local curve = lurek.animation.newCurve()
    curve:addKeyframe(0.0, 0.0)
    curve:addKeyframe(0.5, 1.0)
    print("keyframes = " .. curve:keyframeCount())
    print("mid value = " .. curve:eval(0.5))
end
```

---

### `LAnimCurve:clear`

Removes all keyframes from this curve.

```lua
-- signature
LAnimCurve:clear()
```

**Example**

```lua
do
    local curve = lurek.animation.newCurve()
    curve:addKeyframe(0.0, 1.0)
    curve:addKeyframe(1.0, 2.0)
    curve:clear()
    print("after clear, keyframes = " .. curve:keyframeCount())
end
```

---

### `LAnimCurve:eval`

Evaluates the curve at a time or normalized position.

```lua
-- signature
LAnimCurve:eval(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | `number` | Time or normalized position to evaluate. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Interpolated curve value. |

**Example**

```lua
do
    local curve = lurek.animation.newCurve()
    curve:addKeyframe(0.0, 0.0)
    curve:addKeyframe(1.0, 10.0)
    local mid = curve:eval(0.5)
    print("value at 0.5 = " .. mid)
end
```

---

### `LAnimCurve:keyframeCount`

Returns the number of keyframes stored in this curve.

```lua
-- signature
LAnimCurve:keyframeCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Keyframe count. |

**Example**

```lua
do
    local curve = lurek.animation.newCurve()
    curve:addKeyframe(0.0, 0.0)
    curve:addKeyframe(0.25, 5.0)
    print("keyframe count = " .. curve:keyframeCount())
end
```

---

### `LAnimCurve:setCustomEasing`

Sets or clears a Lua callback used to evaluate custom easing.

```lua
-- signature
LAnimCurve:setCustomEasing(func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `func` | `function` | Function used as custom easing callback, or nil to clear custom easing. |

**Example**

```lua
do
    local curve = lurek.animation.newCurve()
    curve:addKeyframe(0.0, 0.0)
    curve:addKeyframe(1.0, 100.0)
    curve:setCustomEasing(function(t) return t * t end)
    print("custom eased at 0.5 = " .. curve:eval(0.5))
end
```

---

### `LAnimCurve:setEasing`

Sets the built-in easing mode used between keyframes.

```lua
-- signature
LAnimCurve:setEasing(mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | `string` | Easing mode `step`, `linear`, `ease_in`, `ease_out`, or `ease_in_out`. |

**Example**

```lua
do
    local curve = lurek.animation.newCurve()
    curve:addKeyframe(0.0, 0.0)
    curve:addKeyframe(1.0, 1.0)
    curve:setEasing("ease_in_out")
    print("eased value at 0.5 = " .. curve:eval(0.5))
end
```

---

### `LAnimCurve:type`

Returns the Lua-visible type name for this animation curve handle.

```lua
-- signature
LAnimCurve:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LAnimCurve`. |

**Example**

```lua
do
    local curve = lurek.animation.newCurve()
    print("type = " .. curve:type())
    print("matches = " .. tostring(curve:typeOf("LAnimCurve")))
end
```

---

### `LAnimCurve:typeOf`

Returns whether this animation curve handle matches a supported type name.

```lua
-- signature
LAnimCurve:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LAnimCurve` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local curve = lurek.animation.newCurve()
    print("is LAnimCurve = " .. tostring(curve:typeOf("LAnimCurve")))
end
```

---

## LAnimStateMachine

### `LAnimStateMachine:addState`

Adds a state that plays a named animation clip.

```lua
-- signature
LAnimStateMachine:addState(name, clip, looping)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | State name. |
| `clip` | `string` | Clip name to play while this state is active. |
| `looping` | `boolean` | True when the clip should loop in this state. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("idle", { 0 }, 5, true)
    local sm = lurek.animation.newStateMachine(anim, "idle")
    sm:addState("idle", "idle", true)
    print("states added")
    print("current state = " .. sm:getState())
end
```

---

### `LAnimStateMachine:addTransition`

Adds a named-condition transition between two animation states.

```lua
-- signature
LAnimStateMachine:addTransition(from_state, to_state, condition)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from_state` | `string` | Source state name. |
| `to_state` | `string` | Destination state name. |
| `condition` | `string` | Parameter condition expression understood by the state machine. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("idle", { 0 }, 5, true)
    anim:addClip("run", { 0 }, 10, true)
    local sm = lurek.animation.newStateMachine(anim, "idle")
    sm:addState("idle", "idle", true)
    sm:addState("run", "run", true)
    sm:addTransition("idle", "run", "speed > 0.1")
    print("transition added: idle -> run")
end
```

---

### `LAnimStateMachine:draw`

Draws the current state-machine animation frame without advancing playback.

```lua
-- signature
LAnimStateMachine:draw(image, x, y, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `image?` | `LImage` | Texture atlas or spritesheet; omit when an image was stored with setImage. |
| `x?` | `number` | Destination X position (default 0). |
| `y?` | `number` | Destination Y position (default 0). |
| `opts?` | `table` | Optional transform table with numeric `rotation`, `scale`, `scaleX`, `scaleY`, `originX`, and `originY` fields. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when a frame draw command was queued; false when no current frame is active. |

**Example**

```lua
do
    local atlas = lurek.render.newImage("assets/icon.png")
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 16, 16)
    anim:addClip("idle", { 0 }, 8, true)
    anim:play("idle")
    local sm = lurek.animation.newStateMachine(anim, "idle")
    sm:addState("idle", "idle", true)
    local queued = sm:draw(atlas, 48, 24, { scale = 2.0 })
    print("state machine draw queued = " .. tostring(queued))
    sm:setImage(atlas)
    local queued2 = sm:draw(48, 24, { scale = 2.0 })
    print("state machine draw (stored image) queued = " .. tostring(queued2))
end
```

---

### `LAnimStateMachine:forceState`

Forces the state machine into a named state.

```lua
-- signature
LAnimStateMachine:forceState(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | State name to activate immediately. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the state exists and was activated. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFramesFromGrid(64, 32, 32, 32, 0, 2)
    anim:addClip("a", { 0 }, 5, true)
    anim:addClip("b", { 1 }, 5, true)
    local sm = lurek.animation.newStateMachine(anim, "a")
    sm:addState("a", "a", true)
    sm:addState("b", "b", true)
    sm:forceState("b")
    print("forced to state = " .. sm:getState())
end
```

---

### `LAnimStateMachine:getQuad`

Returns the current frame rectangle from the state machine's owned animation.

```lua
-- signature
LAnimStateMachine:getQuad()
```

**Returns**

| Type | Description |
|------|-------------|
| `LuaValue` | Table with `x`, `y`, `w`, and `h`, or nil when no frame is active. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("idle", { 0 }, 5, true)
    local sm = lurek.animation.newStateMachine(anim, "idle")
    sm:addState("idle", "idle", true)
    sm:update(0.0)
    print("sm quad = " .. tostring(sm:getQuad() ~= nil))
end
```

---

### `LAnimStateMachine:getState`

Returns the current animation state name.

```lua
-- signature
LAnimStateMachine:getState()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Current state name. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("stand", { 0 }, 1, true)
    local sm = lurek.animation.newStateMachine(anim, "stand")
    sm:addState("stand", "stand", true)
    print("state = " .. sm:getState())
end
```

---

### `LAnimStateMachine:setImage`

Stores a spritesheet image on this state machine so draw can be called without an explicit image argument.

```lua
-- signature
LAnimStateMachine:setImage(image)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `image` | `LImage` | Texture atlas or spritesheet containing the animation frames. |

**Example**

```lua
do
    local atlas = lurek.render.newImage("assets/icon.png")
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 16, 16)
    anim:addClip("idle", { 0 }, 8, true)
    anim:play("idle")
    local sm = lurek.animation.newStateMachine(anim, "idle")
    sm:addState("idle", "idle", true)
    sm:setImage(atlas)
    local queued = sm:draw(48, 24)
    print("sm setImage draw queued = " .. tostring(queued))
end
```

---

### `LAnimStateMachine:setParam`

Sets a boolean, integer, or numeric state machine parameter.

```lua
-- signature
LAnimStateMachine:setParam(name, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Parameter name used by transition conditions. |
| `value` | `LuaValue` | Boolean, integer, or number value to store. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("idle", { 0 }, 5, true)
    local sm = lurek.animation.newStateMachine(anim, "idle")
    sm:addState("idle", "idle", true)
    sm:setParam("speed", 2.5)
    print("params set")
    print("state after param = " .. sm:getState())
end
```

---

### `LAnimStateMachine:type`

Returns the Lua-visible type name for this animation state machine handle.

```lua
-- signature
LAnimStateMachine:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LAnimStateMachine`. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("idle", { 0 }, 5, true)
    local sm = lurek.animation.newStateMachine(anim, "idle")
    print("type = " .. sm:type())
    print("matches = " .. tostring(sm:typeOf("LAnimStateMachine")))
end
```

---

### `LAnimStateMachine:typeOf`

Returns whether this animation state machine handle matches a supported type name.

```lua
-- signature
LAnimStateMachine:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LAnimStateMachine` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("idle", { 0 }, 5, true)
    local sm = lurek.animation.newStateMachine(anim, "idle")
    print("is LAnimStateMachine = " .. tostring(sm:typeOf("LAnimStateMachine")))
end
```

---

### `LAnimStateMachine:update`

Advances the animation state machine and its owned animation playback.

```lua
-- signature
LAnimStateMachine:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | `number` | Elapsed time in seconds. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("idle", { 0 }, 5, true)
    local sm = lurek.animation.newStateMachine(anim, "idle")
    sm:addState("idle", "idle", true)
    sm:update(0.016)
    print("sm updated, state = " .. sm:getState())
end
```

---

## LAnimSyncGroup

### `LAnimSyncGroup:add`

Adds an animation-like handle to the sync group.

```lua
-- signature
LAnimSyncGroup:add(handle)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `handle` | `number` | Animation handle accepted by future sync group implementations. |

**Example**

```lua
do
    local sg = lurek.animation.newSyncGroup()
    sg:add(1)
    print("sync group members = " .. sg:memberCount())
    print("sync group type = " .. sg:type())
end
```

---

### `LAnimSyncGroup:clear`

Removes all members from the sync group.

```lua
-- signature
LAnimSyncGroup:clear()
```

**Example**

```lua
do
    local sg = lurek.animation.newSyncGroup()
    sg:add(1)
    sg:clear()
    print("after clear, members = " .. sg:memberCount())
end
```

---

### `LAnimSyncGroup:memberCount`

Returns the number of handles tracked by the sync group.

```lua
-- signature
LAnimSyncGroup:memberCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Sync group member count. |

**Example**

```lua
do
    local sg = lurek.animation.newSyncGroup()
    sg:add(1)
    print("member count = " .. sg:memberCount())
end
```

---

### `LAnimSyncGroup:remove`

Removes an animation-like handle from the sync group.

```lua
-- signature
LAnimSyncGroup:remove(handle)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `handle` | `number` | Animation handle accepted by future sync group implementations. |

**Example**

```lua
do
    local sg = lurek.animation.newSyncGroup()
    sg:add(1)
    sg:remove(1)
    print("after remove, members = " .. sg:memberCount())
end
```

---

### `LAnimSyncGroup:type`

Returns the Lua-visible type name for this animation sync group handle.

```lua
-- signature
LAnimSyncGroup:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LAnimSyncGroup`. |

**Example**

```lua
do
    local sg = lurek.animation.newSyncGroup()
    print("type = " .. sg:type())
    print("matches = " .. tostring(sg:typeOf("LAnimSyncGroup")))
end
```

---

### `LAnimSyncGroup:typeOf`

Returns whether this animation sync group handle matches a supported type name.

```lua
-- signature
LAnimSyncGroup:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LAnimSyncGroup` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local sg = lurek.animation.newSyncGroup()
    print("is LAnimSyncGroup = " .. tostring(sg:typeOf("LAnimSyncGroup")))
end
```

---

## LAnimation

### `LAnimation:addClip`

Adds a named clip using existing frame indices.

```lua
-- signature
LAnimation:addClip(name, indices_tbl, fps, looping, mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Clip name used by playback and state machines. |
| `indices_tbl` | `table` | Array of frame indices that make up the clip. |
| `fps` | `number` | Playback speed in frames per second. |
| `looping` | `boolean` | True when playback should wrap at the end. |
| `mode?` | `string` | Playback mode `forward`, `reverse`, or `pingpong`; defaults to `forward`. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFramesFromGrid(128, 32, 32, 32, 0, 4)
    anim:addClip("walk", { 0, 1, 2, 3 }, 10, true, "forward")
    print("clips = " .. anim:getClipCount())
    print("walk mode = " .. tostring(anim:getClipMode("walk")))
end
```

---

### `LAnimation:addClipFromGrid`

Adds frames from a texture grid and creates a clip that references the new frames.

```lua
-- signature
LAnimation:addClipFromGrid(name, tw, th, fw, fh, start, count, fps, looping)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Clip name to create. |
| `tw` | `number` | Texture width in pixels. |
| `th` | `number` | Texture height in pixels. |
| `fw` | `number` | Frame width in pixels. |
| `fh` | `number` | Frame height in pixels. |
| `start` | `number` | Zero-based grid cell index where import begins. |
| `count` | `number` | Number of frames to add. |
| `fps` | `number` | Playback speed in frames per second. |
| `looping` | `boolean` | True when playback should wrap at the end. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addClipFromGrid("sprint", 256, 64, 32, 32, 0, 8, 15, true)
    print("clip from grid, frames = " .. anim:getFrameCount())
    print("clip count = " .. anim:getClipCount())
end
```

---

### `LAnimation:addFrame`

Adds one frame rectangle to this animation.

```lua
-- signature
LAnimation:addFrame(x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | Frame X coordinate in texture pixels. |
| `y` | `number` | Frame Y coordinate in texture pixels. |
| `w` | `number` | Frame width in texture pixels. |
| `h` | `number` | Frame height in texture pixels. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Index of the inserted frame. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    print("frames = " .. anim:getFrameCount())
    print("current frame = " .. anim:getCurrentFrame())
end
```

---

### `LAnimation:addFramesFromGrid`

Adds frames by slicing a texture grid.

```lua
-- signature
LAnimation:addFramesFromGrid(tw, th, fw, fh, start, count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tw` | `number` | Texture width in pixels. |
| `th` | `number` | Texture height in pixels. |
| `fw` | `number` | Frame width in pixels. |
| `fh` | `number` | Frame height in pixels. |
| `start` | `number` | Zero-based grid cell index where import begins. |
| `count` | `number` | Number of frames to add. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Number of frames inserted. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    local count = anim:addFramesFromGrid(256, 256, 32, 32, 0, 8)
    print("added " .. count .. " frames from grid")
    print("frame count = " .. anim:getFrameCount())
end
```

---

### `LAnimation:addFramesFromRects`

Adds frames from an array of rectangle tables.

```lua
-- signature
LAnimation:addFramesFromRects(rects)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `rects` | `table` | Array of tables with numeric `x`, `y`, `w`, and `h` fields. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Number of frames inserted. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFramesFromRects({ { x = 0, y = 0, w = 16, h = 16 }, { x = 16, y = 0, w = 16, h = 16 } })
    print("frames from rects = " .. anim:getFrameCount())
    print("animation type = " .. anim:type())
end
```

---

### `LAnimation:crossfade`

Starts a crossfade from the current clip to another clip.

```lua
-- signature
LAnimation:crossfade(clip_name, duration)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `clip_name` | `string` | Destination clip name. |
| `duration` | `number` | Crossfade duration in seconds. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the destination clip exists and crossfade started. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFramesFromGrid(128, 32, 32, 32, 0, 4)
    anim:addClip("idle", { 0, 1 }, 4, true)
    anim:addClip("run", { 2, 3 }, 8, true)
    anim:play("idle")
    anim:crossfade("run", 0.3)
    print("crossfading to run")
    print("blend state exists = " .. tostring(anim:getBlendState() ~= nil))
end
```

---

### `LAnimation:draw`

Draws the current animation frame without advancing playback.

```lua
-- signature
LAnimation:draw(image, x, y, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `image?` | `LImage` | Texture atlas or spritesheet; omit when an image was stored with setImage. |
| `x?` | `number` | Destination X position (default 0). |
| `y?` | `number` | Destination Y position (default 0). |
| `opts?` | `table` | Optional transform table with numeric `rotation`, `scale`, `scaleX`, `scaleY`, `originX`, and `originY` fields. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when a frame draw command was queued; false when no current frame is active. |

**Example**

```lua
do
    local atlas = lurek.render.newImage("assets/icon.png")
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 16, 16)
    anim:addClip("idle", { 0 }, 1, true)
    anim:play("idle")
    local queued = anim:draw(atlas, 20, 24, { scale = 2.0 })
    print("animation draw queued = " .. tostring(queued))
    anim:setImage(atlas)
    local queued2 = anim:draw(20, 24, { scale = 2.0 })
    print("animation draw (stored image) queued = " .. tostring(queued2))
end
```

---

### `LAnimation:drawPreviewGrid`

Rasterizes all animation frames into a preview grid image.

```lua
-- signature
LAnimation:drawPreviewGrid(columns, cell_size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `columns` | `number` | Number of columns in the preview grid. |
| `cell_size` | `number` | Size of each preview cell in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| `LImageData` | Image data containing the preview grid. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFramesFromGrid(128, 32, 32, 32, 0, 4)
    anim:drawPreviewGrid(4, 36)
    print("preview grid drawn")
end
```

---

### `LAnimation:drawToImage`

Rasterizes the current animation frame into an image userdata.

```lua
-- signature
LAnimation:drawToImage(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | `number` | Output image width in pixels. |
| `h` | `number` | Output image height in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| `LImageData` | Image data containing the rendered frame. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("snap", { 0 }, 1, false)
    anim:play("snap")
    local img = anim:drawToImage(64, 64)
    print("drawn to image = " .. tostring(img ~= nil))
end
```

---

### `LAnimation:getBlendState`

Returns current crossfade rectangles and blend factor when a crossfade is active.

```lua
-- signature
LAnimation:getBlendState()
```

**Returns**

| Type | Description |
|------|-------------|
| `LuaValue` | Table with `from`, `to`, and `blend`, or nil when no blend is active. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("a", { 0 }, 5, true)
    anim:play("a")
    local bs = anim:getBlendState()
    print("blend state = " .. tostring(bs ~= nil))
end
```

---

### `LAnimation:getClip`

Returns the current clip name when a clip is active.

```lua
-- signature
LAnimation:getClip()
```

**Returns**

| Type | Description |
|------|-------------|
| `LuaValue` | Current clip name, or nil when no clip is active. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 16, 16)
    anim:addClip("walk", { 0 }, 8, true)
    anim:play("walk")
    print("clip = " .. anim:getClip())
end
```

---

### `LAnimation:getClipCount`

Returns the number of named clips stored in this animation.

```lua
-- signature
LAnimation:getClipCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Clip count. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 16, 16)
    anim:addClip("a", { 0 }, 5, false)
    anim:addClip("b", { 0 }, 5, true)
    print("clip count = " .. anim:getClipCount())
end
```

---

### `LAnimation:getClipMode`

Returns the playback mode name for a clip when it exists.

```lua
-- signature
LAnimation:getClipMode(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Clip name to query. |

**Returns**

| Type | Description |
|------|-------------|
| `LuaValue` | Playback mode string, or nil when the clip does not exist. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("run", { 0 }, 12, true, "pingpong")
    local mode = anim:getClipMode("run")
    print("run mode = " .. mode)
end
```

---

### `LAnimation:getCurrentFrame`

Returns the current frame index. This method is available to Lua scripts.

```lua
-- signature
LAnimation:getCurrentFrame()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Current frame index. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFramesFromGrid(64, 32, 32, 32, 0, 2)
    anim:addClip("pair", { 0, 1 }, 4, true)
    anim:play("pair")
    print("current frame = " .. anim:getCurrentFrame())
end
```

---

### `LAnimation:getFrameCount`

Returns the number of frame rectangles stored in this animation.

```lua
-- signature
LAnimation:getFrameCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Frame count. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addFrame(32, 0, 32, 32)
    print("frame count = " .. anim:getFrameCount())
end
```

---

### `LAnimation:getQuad`

Returns the current frame rectangle as a table.

```lua
-- signature
LAnimation:getQuad()
```

**Returns**

| Type | Description |
|------|-------------|
| `LuaValue` | Table with `x`, `y`, `w`, and `h`, or nil when no frame is active. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("single", { 0 }, 1, false)
    anim:play("single")
    local q = anim:getQuad()
    print("quad = " .. tostring(q ~= nil))
    print("frame = " .. anim:getCurrentFrame())
end
```

---

### `LAnimation:getSpeed`

Returns the animation playback speed multiplier.

```lua
-- signature
LAnimation:getSpeed()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Current playback speed multiplier. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    print("default speed = " .. anim:getSpeed())
    print("type = " .. anim:type())
end
```

---

### `LAnimation:isLooping`

Returns whether the current clip loops.

```lua
-- signature
LAnimation:isLooping()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the active clip is looping. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 16, 16)
    anim:addClip("loop_clip", { 0 }, 5, true)
    anim:play("loop_clip")
    print("looping = " .. tostring(anim:isLooping()))
end
```

---

### `LAnimation:isPlaying`

Returns whether this animation is currently playing.

```lua
-- signature
LAnimation:isPlaying()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when playback is active. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 16, 16)
    anim:addClip("x", { 0 }, 1, false)
    anim:play("x")
    print("after play = " .. tostring(anim:isPlaying()))
end
```

---

### `LAnimation:pause`

Pauses animation playback without changing the current clip.

```lua
-- signature
LAnimation:pause()
```

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("b", { 0 }, 5, true)
    anim:play("b")
    anim:pause()
    print("playing after pause = " .. tostring(anim:isPlaying()))
    print("clip after pause = " .. tostring(anim:getClip()))
end
```

---

### `LAnimation:play`

Starts playback of a named clip. This method is available to Lua scripts.

```lua
-- signature
LAnimation:play(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Clip name to play. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the clip exists and playback started. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFramesFromGrid(128, 32, 32, 32, 0, 4)
    anim:addClip("idle", { 0, 1, 2, 3 }, 8, true)
    anim:play("idle")
    print("playing = " .. tostring(anim:isPlaying()))
end
```

---

### `LAnimation:pollEvents`

Drains animation events produced since the previous poll.

```lua
-- signature
LAnimation:pollEvents()
```

**Returns**

| Type | Description |
|------|-------------|
| `LAnimationPollEventsResult` | Array of event tables with `type` and optional `frame` fields. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("once", { 0 }, 10, false)
    anim:play("once")
    anim:update(1.0)
    local events = anim:pollEvents()
    print("events count = " .. #events)
end
```

---

### `LAnimation:resume`

Resumes playback of a paused animation.

```lua
-- signature
LAnimation:resume()
```

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("c", { 0 }, 5, true)
    anim:play("c")
    anim:pause()
    anim:resume()
    print("playing after resume = " .. tostring(anim:isPlaying()))
    print("clip after resume = " .. tostring(anim:getClip()))
end
```

---

### `LAnimation:setClipMode`

Changes the playback mode for an existing clip.

```lua
-- signature
LAnimation:setClipMode(name, mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Clip name to update. |
| `mode` | `string` | Playback mode `forward`, `reverse`, or `pingpong`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the clip exists and the mode was changed. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("test", { 0 }, 5, true, "forward")
    anim:setClipMode("test", "reverse")
    print("clip mode set to reverse")
    print("clip mode now = " .. tostring(anim:getClipMode("test")))
end
```

---

### `LAnimation:setFrame`

Sets the current frame index directly.

```lua
-- signature
LAnimation:setFrame(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | `number` | Frame index to make current. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFramesFromGrid(128, 32, 32, 32, 0, 4)
    anim:addClip("seq", { 0, 1, 2, 3 }, 8, true)
    anim:play("seq")
    anim:setFrame(2)
    print("frame after setFrame = " .. anim:getCurrentFrame())
end
```

---

### `LAnimation:setImage`

Stores a spritesheet image on this animation so draw can be called without an explicit image argument.

```lua
-- signature
LAnimation:setImage(image)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `image` | `LImage` | Texture atlas or spritesheet containing the animation frames. |

**Example**

```lua
do
    local atlas = lurek.render.newImage("assets/icon.png")
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 16, 16)
    anim:addClip("idle", { 0 }, 1, true)
    anim:play("idle")
    anim:setImage(atlas)
    local queued = anim:draw(20, 24)
    print("setImage draw queued = " .. tostring(queued))
end
```

---

### `LAnimation:setSpeed`

Sets the animation playback speed multiplier.

```lua
-- signature
LAnimation:setSpeed(speed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `speed` | `number` | Playback speed multiplier used by future updates. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:setSpeed(2.0)
    print("speed = " .. anim:getSpeed())
end
```

---

### `LAnimation:stop`

Stops playback and resets animation playback state.

```lua
-- signature
LAnimation:stop()
```

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("a", { 0 }, 5, true)
    anim:play("a")
    anim:stop()
    print("playing after stop = " .. tostring(anim:isPlaying()))
    print("current frame after stop = " .. anim:getCurrentFrame())
end
```

---

### `LAnimation:type`

Returns the Lua-visible type name for this animation handle.

```lua
-- signature
LAnimation:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LAnimation`. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    print("type = " .. anim:type())
    print("matches = " .. tostring(anim:typeOf("LAnimation")))
end
```

---

### `LAnimation:typeOf`

Returns whether this animation handle matches a supported type name.

```lua
-- signature
LAnimation:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LAnimation` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    print("is LAnimation = " .. tostring(anim:typeOf("LAnimation")))
end
```

---

### `LAnimation:update`

Advances animation playback and records any frame or clip events.

```lua
-- signature
LAnimation:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | `number` | Elapsed time in seconds. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFramesFromGrid(64, 32, 32, 32, 0, 2)
    anim:addClip("tick", { 0, 1 }, 2, true)
    anim:play("tick")
    anim:update(0.6)
    print("current frame after update = " .. anim:getCurrentFrame())
end
```

---

## LBlendLayerSet

### `LBlendLayerSet:addLayer`

Adds a weighted animation blend layer with an optional bone mask.

```lua
-- signature
LBlendLayerSet:addLayer(name, clip_name, weight, bones)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Unique layer name. |
| `clip_name` | `string` | Animation clip name used by the layer. |
| `weight` | `number` | Blend weight for this layer. |
| `bones?` | `table` | Optional array or map table of bone names included in the mask. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the layer was added. |

**Example**

```lua
do
    local bls = lurek.animation.newBlendLayerSet()
    bls:addLayer("base", "idle", 1.0)
    print("layers added")
    print("layer count = " .. bls:len())
end
```

---

### `LBlendLayerSet:getWeight`

Returns the weight for a blend layer when it exists.

```lua
-- signature
LBlendLayerSet:getWeight(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Layer name to query. |

**Returns**

| Type | Description |
|------|-------------|
| `LuaValue` | Layer weight, or nil when the layer does not exist. |

**Example**

```lua
do
    local bls = lurek.animation.newBlendLayerSet()
    bls:addLayer("run", "run_clip", 0.7)
    local w = bls:getWeight("run")
    print("run weight = " .. w)
end
```

---

### `LBlendLayerSet:len`

Returns the number of blend layers.

```lua
-- signature
LBlendLayerSet:len()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Blend layer count. |

**Example**

```lua
do
    local bls = lurek.animation.newBlendLayerSet()
    bls:addLayer("a", "clip_a", 1.0)
    print("layer count = " .. bls:len())
    print("type = " .. bls:type())
end
```

---

### `LBlendLayerSet:listLayers`

Returns all blend layers with names, clip names, weights, and bone masks.

```lua
-- signature
LBlendLayerSet:listLayers()
```

**Returns**

| Type | Description |
|------|-------------|
| `LBlendLayerSetListLayersResult` | Array of layer tables with `name`, `clip_name`, `weight`, and `bones` fields. |

**Example**

```lua
do
    local bls = lurek.animation.newBlendLayerSet()
    bls:addLayer("base", "idle", 1.0)
    local names = bls:listLayers()
    print("layers = " .. #names)
    print("first layer = " .. tostring(names[1]))
end
```

---

### `LBlendLayerSet:removeLayer`

Removes a blend layer by name. This method is available to Lua scripts.

```lua
-- signature
LBlendLayerSet:removeLayer(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Layer name to remove. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the layer was removed. |

**Example**

```lua
do
    local bls = lurek.animation.newBlendLayerSet()
    bls:addLayer("temp", "idle", 1.0)
    bls:removeLayer("temp")
    print("layer removed")
    print("layer count = " .. bls:len())
end
```

---

### `LBlendLayerSet:setMask`

Replaces a layer bone mask from a table of bone names.

```lua
-- signature
LBlendLayerSet:setMask(name, bones)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Layer name to update. |
| `bones` | `table` | Array or map table of bone names included in the mask. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the layer exists and the mask was changed. |

**Example**

```lua
do
    local bls = lurek.animation.newBlendLayerSet()
    bls:addLayer("arms", "swing", 1.0)
    bls:setMask("arms", { "shoulder_l", "arm_l", "hand_l" })
    print("mask set for arms layer")
    print("layer count = " .. bls:len())
end
```

---

### `LBlendLayerSet:setWeight`

Sets the blend weight for an existing layer.

```lua
-- signature
LBlendLayerSet:setWeight(name, weight)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Layer name to update. |
| `weight` | `number` | New layer weight. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the layer exists and the weight was changed. |

**Example**

```lua
do
    local bls = lurek.animation.newBlendLayerSet()
    bls:addLayer("walk", "walk_clip", 0.5)
    bls:setWeight("walk", 0.8)
    print("weight = " .. bls:getWeight("walk"))
    print("layer count = " .. bls:len())
end
```

---

### `LBlendLayerSet:type`

Returns the Lua-visible type name for this blend layer set handle.

```lua
-- signature
LBlendLayerSet:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LBlendLayerSet`. |

**Example**

```lua
do
    local bls = lurek.animation.newBlendLayerSet()
    print("type = " .. bls:type())
    print("matches = " .. tostring(bls:typeOf("LBlendLayerSet")))
end
```

---

### `LBlendLayerSet:typeOf`

Returns whether this blend layer set handle matches a supported type name.

```lua
-- signature
LBlendLayerSet:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LBlendLayerSet` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local bls = lurek.animation.newBlendLayerSet()
    print("is LBlendLayerSet = " .. tostring(bls:typeOf("LBlendLayerSet")))
end
```

---
