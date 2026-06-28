# Animation

## Purpose

Orchestrates sprite animation playback and processes Aseprite JSON imports. - Manages parameter state networks with crossfading and Spine skeletons. - Controls layered weighted blending, keyframe curves, and phase sync.

## Summary

- The `animation` module is the engine's time-based motion system for users who need sprites, poses, and related visual states to advance through structured runtime playback.
- Clips, frames, controllers, state machines, sync groups, events, blending, and curve handling live together here so simple loops and richer motion behavior share one model.
- Animation is not only frame stepping; it also needs transitions, timing hooks, authored state changes, and gameplay-aware playback control.
- Runtime events make the module useful beyond visuals, since footsteps, attack windows, cutscene timing, and other logic often need to fire from the animation timeline.
- Blend and sync-group support matter because animated systems often need continuity across states or coordinated playback across several visual parts instead of abrupt clip swaps.
- Aseprite import and Spine bridging keep the feature aligned with common art pipelines, while the shared timeline model gives teams one place to reason about authored motion timing for gameplay, tools, and preview behavior.
- State-machine support matters because animation behavior usually depends on more than a current clip. Characters, UI elements, effects, and tools often need explicit transitions, guard conditions, and coordinated playback states that remain inspectable instead of being hidden in scattered script logic.
- Timeline events also help gameplay and motion stay synchronized.
- This makes `animation` useful for straightforward sprite loops and richer authored motion systems where timing, transitions, and events need to stay deterministic enough for debugging, preview, and gameplay integration.
- `render` shows the result and `spine` specializes skeletal rigs, but `animation` owns clip selection, transitions, and timeline advancement.

This module primarily collaborates with `image`, `math`, `render`, `runtime`, `spine`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## API Reference

- This page is the generated API reference for this module.

## Functions

### `lurek.animation.buildCharacter`

Builds a character animation bundle from grid frame and clip configuration.

```lua
lurek.animation.buildCharacter(cfg)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cfg` | table | Configuration table with texture size, frame size, clips, optional states, and optional transitions. |

**Returns**

| Type | Description |
|------|-------------|
| LAnimationBuildCharacterResult | Table containing `animation` and, when states are supplied, `stateMachine` handles. |

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
    lurek.log.info(tostring("character built = " .. tostring(char ~= nil)))
    lurek.log.info(tostring("has animation = " .. tostring(char.animation ~= nil)))
end
```

---

### `lurek.animation.fromAnimatedImage`

Creates an animation from decoded frames returned by `lurek.image.loadAnimated`.

```lua
lurek.animation.fromAnimatedImage(animated, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `animated` | [LAnimatedImage](#lanimatedimage) | Decoded animated image. |
| `opts?` | table | `{name, fps, loop, mode, play}` clip options. |

**Returns**

| Type | Description |
|------|-------------|
| [LAnimation](#lanimation) | New animation handle. |

**Example**

```lua
do
    local a = lurek.image.newImageData(2, 2)
    local b = lurek.image.newImageData(2, 2)
    a:fill(255, 0, 0, 255)
    b:fill(0, 255, 0, 255)
    lurek.image.saveGIF({ a, b }, "work/example_animation_from_gif.gif", { delayMs = 40 })
    local decoded = lurek.image.loadAnimated("work/example_animation_from_gif.gif")
    local anim = lurek.animation.fromAnimatedImage(decoded, { name = "gif", loop = true })
    lurek.log.info("[animation] fromAnimatedImage frames=" .. tostring(anim:getFrameCount()))
end
```

---

### `lurek.animation.fromAseprite`

Loads an animation from an Aseprite JSON export string.

```lua
lurek.animation.fromAseprite(json_str)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `json_str` | string | Raw Aseprite JSON document contents. |

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | Animation handle when parsing succeeds; raises an error when the JSON cannot be parsed. |

**Example**

```lua
do
    local json = '{"frames":[{"filename":"f0","frame":{"x":0,"y":0,"w":16,"h":16}}],"meta":{"size":{"w":16,"h":16},"frameTags":[]}}'
    local anim = lurek.animation.fromAseprite(json)
    if anim then
        lurek.log.info(tostring("from aseprite, clips = " .. anim:getClipCount()))
        lurek.log.info(tostring("from aseprite, frames = " .. anim:getFrameCount()))
    end
end
```

---

### `lurek.animation.fromFrames`

Creates an animation from explicit frame rectangle DTOs.

```lua
lurek.animation.fromFrames(frames, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `frames` | table | Array of `{x, y, w, h}` frame rectangles. |
| `opts?` | table | `{name, fps, loop, mode, play}` clip options. |

**Returns**

| Type | Description |
|------|-------------|
| [LAnimation](#lanimation) | New animation handle. |

**Example**

```lua
do
    local frames = {
        { x = 0, y = 0, w = 16, h = 16 },
        { x = 16, y = 0, w = 16, h = 16 },
    }
    local anim = lurek.animation.fromFrames(frames, { name = "idle", fps = 8, loop = true })
    local count = anim:getFrameCount()
    lurek.log.info("[animation] fromFrames count=" .. tostring(count))
end
```

---

### `lurek.animation.fromSpriteSheet`

Creates an animation from a `[LSpriteSheet](#lspritesheet)`, optionally using a named group.

```lua
lurek.animation.fromSpriteSheet(sheet, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sheet` | [LSpriteSheet](#lspritesheet) | Source sprite sheet. |
| `opts?` | table | `{group, name, fps, loop, mode, play}` clip options. |

**Returns**

| Type | Description |
|------|-------------|
| [LAnimation](#lanimation) | New animation handle. |

**Example**

```lua
do
    local sheet = lurek.sprite.newSheet(64, 16, 16, 16)
    sheet:nameGroup("walk", 0, 4)
    local anim = lurek.animation.fromSpriteSheet(sheet, { group = "walk", name = "walk", fps = 10 })
    local clips = anim:getClipCount()
    lurek.log.info("[animation] fromSpriteSheet clips=" .. tostring(clips))
end
```

---

### `lurek.animation.new`

Creates an empty animation with no frames or clips.

```lua
lurek.animation.new()
```

**Returns**

| Type | Description |
|------|-------------|
| [LAnimation](#lanimation) | New animation handle. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("idle", { 0 }, 4, true)
    local frameCount = anim:getFrameCount()
    local clipCount = anim:getClipCount()
    lurek.log.info("empty actor animation frame count=" .. tostring(frameCount))
    lurek.log.info("empty actor animation clip count=" .. tostring(clipCount))
end
```

---

### `lurek.animation.newBlendLayerSet`

Creates an empty blend layer set for layered animation playback.

```lua
lurek.animation.newBlendLayerSet()
```

**Returns**

| Type | Description |
|------|-------------|
| [LBlendLayerSet](#lblendlayerset) | New blend layer set handle. |

**Example**

```lua
do
    local bls = lurek.animation.newBlendLayerSet()
    bls:addLayer("base", "idle", 1.0)
    bls:addLayer("upper", "aim", 0.4)
    local layerCount = bls:len()
    local upperWeight = bls:getWeight("upper")
    lurek.log.info("blend layer set count=" .. tostring(layerCount))
    lurek.log.info("upper body weight=" .. tostring(upperWeight))
end
```

---

### `lurek.animation.newCurve`

Creates an empty animation curve. This function is exposed to Lua scripts.

```lua
lurek.animation.newCurve()
```

**Returns**

| Type | Description |
|------|-------------|
| [LAnimCurve](#lanimcurve) | New animation curve handle. |

**Example**

```lua
do
    local curve = lurek.animation.newCurve()
    curve:addKeyframe(0.0, 0.0)
    curve:addKeyframe(1.0, 1.0)
    local midValue = curve:eval(0.5)
    local keyframeCount = curve:keyframeCount()
    lurek.log.info("camera shake curve midpoint=" .. tostring(midValue))
    lurek.log.info("camera shake curve keyframes=" .. tostring(keyframeCount))
end
```

---

### `lurek.animation.newStateMachine`

Creates an animation state machine by consuming an animation handle.

```lua
lurek.animation.newStateMachine(anim_ud, initial)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `anim_ud` | [LAnimation](#lanimation) | Animation handle moved into the state machine. |
| `initial` | string | Initial state name stored in the state machine. |

**Returns**

| Type | Description |
|------|-------------|
| [LAnimStateMachine](#lanimstatemachine) | New animation state machine handle. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("idle", { 0 }, 1, true)
    local sm = lurek.animation.newStateMachine(anim, "idle")
    lurek.log.info(tostring("state machine created = " .. tostring(sm ~= nil)))
    lurek.log.info(tostring("state machine type = " .. sm:type()))
end
```

---

### `lurek.animation.newSyncGroup`

Creates an empty animation synchronization group.

```lua
lurek.animation.newSyncGroup()
```

**Returns**

| Type | Description |
|------|-------------|
| [LAnimSyncGroup](#lanimsyncgroup) | New animation sync group handle. |

**Example**

```lua
do
    local sg = lurek.animation.newSyncGroup()
    sg:add(101)
    sg:add(102)
    local memberCount = sg:memberCount()
    local typeName = sg:type()
    lurek.log.info("squad sync group members=" .. tostring(memberCount))
    lurek.log.info("squad sync group type=" .. tostring(typeName))
end
```

---

## Module Fields

*No module-level fields documented.*

## Enums

*No module-specific enums documented.*

## Types

- [LAnimCurve](#lanimcurve)
- [LAnimStateMachine](#lanimstatemachine)
- [LAnimSyncGroup](#lanimsyncgroup)
- [LAnimatedImage](#lanimatedimage)
- [LAnimation](#lanimation)
- [LBlendLayerSet](#lblendlayerset)
- [LSpriteSheet](#lspritesheet)

## LAnimCurve

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LAnimCurve:addKeyframe`

Adds a keyframe to the curve. This method is available to Lua scripts.

```lua
LAnimCurve:addKeyframe(t, v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | number | Keyframe time or normalized position. |
| `v` | number | Keyframe value. |

**Example**

```lua
do
    local curve = lurek.animation.newCurve()
    curve:addKeyframe(0.0, 0.0)
    curve:addKeyframe(0.5, 1.0)
    lurek.log.info(tostring("keyframes = " .. curve:keyframeCount()))
    lurek.log.info(tostring("mid value = " .. curve:eval(0.5)))
end
```

---

#### `LAnimCurve:clear`

Removes all keyframes from this curve.

```lua
LAnimCurve:clear()
```

**Example**

```lua
do
    local curve = lurek.animation.newCurve()
    curve:addKeyframe(0.0, 1.0)
    curve:addKeyframe(1.0, 2.0)
    curve:clear()
    lurek.log.info(tostring("after clear, keyframes = " .. curve:keyframeCount()))
end
```

---

#### `LAnimCurve:eval`

Evaluates the curve at a time or normalized position.

```lua
LAnimCurve:eval(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | number | Time or normalized position to evaluate. |

**Returns**

| Type | Description |
|------|-------------|
| number | Interpolated curve value. |

**Example**

```lua
do
    local curve = lurek.animation.newCurve()
    curve:addKeyframe(0.0, 0.0)
    curve:addKeyframe(1.0, 10.0)
    local mid = curve:eval(0.5)
    lurek.log.info(tostring("value at 0.5 = " .. mid))
end
```

---

#### `LAnimCurve:keyframeCount`

Returns the number of keyframes stored in this curve.

```lua
LAnimCurve:keyframeCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Keyframe count. |

**Example**

```lua
do
    local curve = lurek.animation.newCurve()
    curve:addKeyframe(0.0, 0.0)
    curve:addKeyframe(0.25, 5.0)
    curve:addKeyframe(1.0, 10.0)
    local keyframeCount = curve:keyframeCount()
    local halfValue = curve:eval(0.5)
    lurek.log.info("jump arc keyframes=" .. tostring(keyframeCount))
    lurek.log.info("jump arc midpoint=" .. tostring(halfValue))
end
```

---

#### `LAnimCurve:setCustomEasing`

Sets or clears a Lua callback used to evaluate custom easing.

```lua
LAnimCurve:setCustomEasing(func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `func` | function | Function used as custom easing callback, or nil to clear custom easing. |

**Example**

```lua
do
    local curve = lurek.animation.newCurve()
    curve:addKeyframe(0.0, 0.0)
    curve:addKeyframe(1.0, 100.0)
    curve:setCustomEasing(function(t) return t * t end)
    lurek.log.info(tostring("custom eased at 0.5 = " .. curve:eval(0.5)))
end
```

---

#### `LAnimCurve:setEasing`

Sets the built-in easing mode used between keyframes.

```lua
LAnimCurve:setEasing(mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | string | Easing mode `step`, `linear`, `ease_in`, `ease_out`, or `ease_in_out`. |

**Example**

```lua
do
    local curve = lurek.animation.newCurve()
    curve:addKeyframe(0.0, 0.0)
    curve:addKeyframe(1.0, 1.0)
    curve:setEasing("ease_in_out")
    lurek.log.info(tostring("eased value at 0.5 = " .. curve:eval(0.5)))
end
```

---

#### `LAnimCurve:type`

Returns the Lua-visible type name for this animation curve handle.

```lua
LAnimCurve:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LAnimCurve](#lanimcurve)`. |

**Example**

```lua
do
    local curve = lurek.animation.newCurve()
    curve:addKeyframe(0.0, 0.0)
    curve:addKeyframe(1.0, 1.0)
    local typeName = curve:type()
    local isCurve = curve:typeOf("LAnimCurve")
    lurek.log.info("curve type=" .. tostring(typeName))
    lurek.log.info("is curve=" .. tostring(isCurve))
end
```

---

#### `LAnimCurve:typeOf`

Returns whether this animation curve handle matches a supported type name.

```lua
LAnimCurve:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LAnimCurve](#lanimcurve)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local curve = lurek.animation.newCurve()
    curve:addKeyframe(0.0, 0.0)
    curve:addKeyframe(1.0, 1.0)
    local isCurve = curve:typeOf("LAnimCurve")
    local isBlendSet = curve:typeOf("LBlendLayerSet")
    lurek.log.info("is curve=" .. tostring(isCurve))
    lurek.log.info("is blend set=" .. tostring(isBlendSet))
end
```

---

## LAnimStateMachine

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LAnimStateMachine:addState`

Adds a state that plays a named animation clip.

```lua
LAnimStateMachine:addState(name, clip, looping)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | State name. |
| `clip` | string | Clip name to play while this state is active. |
| `looping` | boolean | True when the clip should loop in this state. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("idle", { 0 }, 5, true)
    local sm = lurek.animation.newStateMachine(anim, "idle")
    sm:addState("idle", "idle", true)
    lurek.log.info(tostring("states added"))
    lurek.log.info(tostring("current state = " .. sm:getState()))
end
```

---

#### `LAnimStateMachine:addTransition`

Adds a named-condition transition between two animation states.

```lua
LAnimStateMachine:addTransition(from_state, to_state, condition)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from_state` | string | Source state name. |
| `to_state` | string | Destination state name. |
| `condition` | string | Parameter condition expression understood by the state machine. |

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
    lurek.log.info(tostring("transition added: idle -> run"))
end
```

---

#### `LAnimStateMachine:draw`

Draws the current state-machine animation frame without advancing playback.

```lua
LAnimStateMachine:draw(image, x, y, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `image?` | [LImage](render.md#limage) | Texture atlas or spritesheet; omit when an image was stored with setImage. |
| `x?` | number | Destination X position (default 0). |
| `y?` | number | Destination Y position (default 0). |
| `opts?` | table | Optional transform table with numeric `rotation`, `scale`, `scaleX`, `scaleY`, `originX`, and `originY` fields. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a frame draw command was queued; false when no current frame is active. |

**Example**

```lua
do
    local atlas = lurek.render.newImage("content/examples/assets/images/sample_icon.png")
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 16, 16)
    anim:addClip("idle", { 0 }, 8, true)
    anim:play("idle")
    local sm = lurek.animation.newStateMachine(anim, "idle")
    sm:addState("idle", "idle", true)
    local queued = sm:draw(atlas, 48, 24, { scale = 2.0 })
    lurek.log.info(tostring("state machine draw queued = " .. tostring(queued)))
    sm:setImage(atlas)
    local queued2 = sm:draw(48, 24, { scale = 2.0 })
    lurek.log.info(tostring("state machine draw (stored image) queued = " .. tostring(queued2)))
end
```

---

#### `LAnimStateMachine:forceState`

Forces the state machine into a named state.

```lua
LAnimStateMachine:forceState(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | State name to activate immediately. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the state exists and was activated. |

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
    lurek.log.info(tostring("forced to state = " .. sm:getState()))
end
```

---

#### `LAnimStateMachine:getQuad`

Returns the current frame rectangle from the state machine's owned animation.

```lua
LAnimStateMachine:getQuad()
```

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | Table with `x`, `y`, `w`, and `h`, or nil when no frame is active. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("idle", { 0 }, 5, true)
    local sm = lurek.animation.newStateMachine(anim, "idle")
    sm:addState("idle", "idle", true)
    sm:update(0.0)
    lurek.log.info(tostring("sm quad = " .. tostring(sm:getQuad() ~= nil)))
end
```

---

#### `LAnimStateMachine:getState`

Returns the current animation state name.

```lua
LAnimStateMachine:getState()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Current state name. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("stand", { 0 }, 1, true)
    local sm = lurek.animation.newStateMachine(anim, "stand")
    sm:addState("stand", "stand", true)
    lurek.log.info(tostring("state = " .. sm:getState()))
end
```

---

#### `LAnimStateMachine:setImage`

Stores a spritesheet image on this state machine so draw can be called without an explicit image argument.

```lua
LAnimStateMachine:setImage(image)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `image` | [LImage](render.md#limage) | Texture atlas or spritesheet containing the animation frames. |

**Example**

```lua
do
    local atlas = lurek.render.newImage("content/examples/assets/images/sample_icon.png")
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 16, 16)
    anim:addClip("idle", { 0 }, 8, true)
    anim:play("idle")
    local sm = lurek.animation.newStateMachine(anim, "idle")
    sm:addState("idle", "idle", true)
    sm:setImage(atlas)
    local queued = sm:draw(48, 24)
    lurek.log.info(tostring("sm setImage draw queued = " .. tostring(queued)))
end
```

---

#### `LAnimStateMachine:setParam`

Sets a boolean, integer, or numeric state machine parameter.

```lua
LAnimStateMachine:setParam(name, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Parameter name used by transition conditions. |
| `value` | LuaValue | Boolean, integer, or number value to store. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("idle", { 0 }, 5, true)
    local sm = lurek.animation.newStateMachine(anim, "idle")
    sm:addState("idle", "idle", true)
    sm:setParam("speed", 2.5)
    lurek.log.info(tostring("params set"))
    lurek.log.info(tostring("state after param = " .. sm:getState()))
end
```

---

#### `LAnimStateMachine:type`

Returns the Lua-visible type name for this animation state machine handle.

```lua
LAnimStateMachine:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LAnimStateMachine](#lanimstatemachine)`. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("idle", { 0 }, 5, true)
    local sm = lurek.animation.newStateMachine(anim, "idle")
    lurek.log.info(tostring("type = " .. sm:type()))
    lurek.log.info(tostring("matches = " .. tostring(sm:typeOf("LAnimStateMachine"))))
end
```

---

#### `LAnimStateMachine:typeOf`

Returns whether this animation state machine handle matches a supported type name.

```lua
LAnimStateMachine:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LAnimStateMachine](#lanimstatemachine)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("idle", { 0 }, 5, true)
    local sm = lurek.animation.newStateMachine(anim, "idle")
    lurek.log.info(tostring("is LAnimStateMachine = " .. tostring(sm:typeOf("LAnimStateMachine"))))
end
```

---

#### `LAnimStateMachine:update`

Advances the animation state machine and its owned animation playback.

```lua
LAnimStateMachine:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Elapsed time in seconds. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("idle", { 0 }, 5, true)
    local sm = lurek.animation.newStateMachine(anim, "idle")
    sm:addState("idle", "idle", true)
    sm:update(0.016)
    lurek.log.info(tostring("sm updated, state = " .. sm:getState()))
end
```

---

## LAnimSyncGroup

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LAnimSyncGroup:add`

Adds an animation-like handle to the sync group.

```lua
LAnimSyncGroup:add(handle)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `handle` | number | Animation handle accepted by future sync group implementations. |

**Example**

```lua
do
    local sg = lurek.animation.newSyncGroup()
    sg:add(1)
    sg:add(2)
    local memberCount = sg:memberCount()
    local typeName = sg:type()
    lurek.log.info("sync group members after add=" .. tostring(memberCount))
    lurek.log.info("sync group type=" .. tostring(typeName))
end
```

---

#### `LAnimSyncGroup:clear`

Removes all members from the sync group.

```lua
LAnimSyncGroup:clear()
```

**Example**

```lua
do
    local sg = lurek.animation.newSyncGroup()
    sg:add(1)
    sg:add(2)
    sg:clear()
    local memberCount = sg:memberCount()
    local typeName = sg:type()
    lurek.log.info("sync members after clear=" .. tostring(memberCount))
    lurek.log.info("sync group type after clear=" .. tostring(typeName))
end
```

---

#### `LAnimSyncGroup:memberCount`

Returns the number of handles tracked by the sync group.

```lua
LAnimSyncGroup:memberCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Sync group member count. |

**Example**

```lua
do
    local sg = lurek.animation.newSyncGroup()
    sg:add(1)
    sg:add(2)
    local memberCount = sg:memberCount()
    sg:remove(2)
    lurek.log.info("members before trim=" .. tostring(memberCount))
    lurek.log.info("members after trim=" .. tostring(sg:memberCount()))
end
```

---

#### `LAnimSyncGroup:remove`

Removes an animation-like handle from the sync group.

```lua
LAnimSyncGroup:remove(handle)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `handle` | number | Animation handle accepted by future sync group implementations. |

**Example**

```lua
do
    local sg = lurek.animation.newSyncGroup()
    sg:add(1)
    sg:add(2)
    sg:remove(1)
    local memberCount = sg:memberCount()
    local stillHasSecond = memberCount > 0
    lurek.log.info("sync members after remove=" .. tostring(memberCount))
    lurek.log.info("second handle still tracked=" .. tostring(stillHasSecond))
end
```

---

#### `LAnimSyncGroup:type`

Returns the Lua-visible type name for this animation sync group handle.

```lua
LAnimSyncGroup:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LAnimSyncGroup](#lanimsyncgroup)`. |

**Example**

```lua
do
    local sg = lurek.animation.newSyncGroup()
    sg:add(11)
    local typeName = sg:type()
    local isSyncGroup = sg:typeOf("LAnimSyncGroup")
    local memberCount = sg:memberCount()
    lurek.log.info("sync group type=" .. tostring(typeName))
    lurek.log.info("is sync group=" .. tostring(isSyncGroup) .. " members=" .. tostring(memberCount))
end
```

---

#### `LAnimSyncGroup:typeOf`

Returns whether this animation sync group handle matches a supported type name.

```lua
LAnimSyncGroup:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LAnimSyncGroup](#lanimsyncgroup)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local sg = lurek.animation.newSyncGroup()
    sg:add(12)
    local isSyncGroup = sg:typeOf("LAnimSyncGroup")
    local isCurve = sg:typeOf("LAnimCurve")
    lurek.log.info("is sync group=" .. tostring(isSyncGroup))
    lurek.log.info("is curve=" .. tostring(isCurve))
end
```

---

## LAnimatedImage

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LAnimatedImage:frameCount`

Returns the number of decoded frames.

```lua
LAnimatedImage:frameCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Frame count. |

---

#### `LAnimatedImage:getDuration`

Returns a frame duration in milliseconds by one-based index.

```lua
LAnimatedImage:getDuration(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | One-based frame index. |

**Returns**

| Type | Description |
|------|-------------|
| number | Duration in milliseconds. |

---

#### `LAnimatedImage:getDurations`

Returns all frame durations in milliseconds.

```lua
LAnimatedImage:getDurations()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Array of integer durations. |

---

#### `LAnimatedImage:getFrame`

Returns a decoded frame by one-based index.

```lua
LAnimatedImage:getFrame(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | One-based frame index. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](render.md#limagedata) | Decoded frame image. |

---

#### `LAnimatedImage:getFrames`

Returns all decoded frame images as an array.

```lua
LAnimatedImage:getFrames()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Array of `[LImageData](render.md#limagedata)` values. |

---

#### `LAnimatedImage:type`

Returns the Lua-visible type name.

```lua
LAnimatedImage:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LAnimatedImage](#lanimatedimage)`. |

---

#### `LAnimatedImage:typeOf`

Returns whether this handle matches a supported type name.

```lua
LAnimatedImage:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches. |

---

## LAnimation

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LAnimation:addClip`

Adds a named clip using existing frame indices.

```lua
LAnimation:addClip(name, indices_tbl, fps, looping, mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Clip name used by playback and state machines. |
| `indices_tbl` | table | Array of frame indices that make up the clip. |
| `fps` | number | Playback speed in frames per second. |
| `looping` | boolean | True when playback should wrap at the end. |
| `mode?` | string | Playback mode `forward`, `reverse`, or `pingpong`; defaults to `forward`. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFramesFromGrid(128, 32, 32, 32, 0, 4)
    anim:addClip("walk", { 0, 1, 2, 3 }, 10, true, "forward")
    lurek.log.info(tostring("clips = " .. anim:getClipCount()))
    lurek.log.info(tostring("walk mode = " .. tostring(anim:getClipMode("walk"))))
end
```

---

#### `LAnimation:addClipFromGrid`

Adds frames from a texture grid and creates a clip that references the new frames.

```lua
LAnimation:addClipFromGrid(name, tw, th, fw, fh, start, count, fps, looping)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Clip name to create. |
| `tw` | number | Texture width in pixels. |
| `th` | number | Texture height in pixels. |
| `fw` | number | Frame width in pixels. |
| `fh` | number | Frame height in pixels. |
| `start` | number | Zero-based grid cell index where import begins. |
| `count` | number | Number of frames to add. |
| `fps` | number | Playback speed in frames per second. |
| `looping` | boolean | True when playback should wrap at the end. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addClipFromGrid("sprint", 256, 64, 32, 32, 0, 8, 15, true)
    anim:play("sprint")
    local frameCount = anim:getFrameCount()
    local clipCount = anim:getClipCount()
    local playing = anim:isPlaying()
    lurek.log.info("sprint clip frames=" .. tostring(frameCount))
    lurek.log.info("sprint clip count=" .. tostring(clipCount) .. " playing=" .. tostring(playing))
end
```

---

#### `LAnimation:addFrame`

Adds one frame rectangle to this animation.

```lua
LAnimation:addFrame(x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Frame X coordinate in texture pixels. |
| `y` | number | Frame Y coordinate in texture pixels. |
| `w` | number | Frame width in texture pixels. |
| `h` | number | Frame height in texture pixels. |

**Returns**

| Type | Description |
|------|-------------|
| number | Index of the inserted frame. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addFrame(32, 0, 32, 32)
    anim:addClip("blink", { 0, 1 }, 6, true)
    local frameCount = anim:getFrameCount()
    local clipCount = anim:getClipCount()
    lurek.log.info("npc blink frames=" .. tostring(frameCount))
    lurek.log.info("npc blink clips=" .. tostring(clipCount))
end
```

---

#### `LAnimation:addFramesFromGrid`

Adds frames by slicing a texture grid.

```lua
LAnimation:addFramesFromGrid(tw, th, fw, fh, start, count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tw` | number | Texture width in pixels. |
| `th` | number | Texture height in pixels. |
| `fw` | number | Frame width in pixels. |
| `fh` | number | Frame height in pixels. |
| `start` | number | Zero-based grid cell index where import begins. |
| `count` | number | Number of frames to add. |

**Returns**

| Type | Description |
|------|-------------|
| number | Number of frames inserted. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    local count = anim:addFramesFromGrid(256, 256, 32, 32, 0, 8)
    anim:addClip("run", { 0, 1, 2, 3 }, 12, true)
    local frameCount = anim:getFrameCount()
    local clipCount = anim:getClipCount()
    lurek.log.info("run sheet slices added=" .. tostring(count))
    lurek.log.info("run sheet frame count=" .. tostring(frameCount) .. " clips=" .. tostring(clipCount))
end
```

---

#### `LAnimation:addFramesFromRects`

Adds frames from an array of rectangle tables.

```lua
LAnimation:addFramesFromRects(rects)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `rects` | table | Array of tables with numeric `x`, `y`, `w`, and `h` fields. |

**Returns**

| Type | Description |
|------|-------------|
| number | Number of frames inserted. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFramesFromRects({ { x = 0, y = 0, w = 16, h = 16 }, { x = 16, y = 0, w = 16, h = 16 } })
    anim:addClip("pickup_spin", { 0, 1 }, 10, true)
    local frameCount = anim:getFrameCount()
    local clipName = anim:getClip()
    anim:play("pickup_spin")
    lurek.log.info("pickup rect frames=" .. tostring(frameCount))
    lurek.log.info("pickup active clip before play=" .. tostring(clipName) .. " after play=" .. tostring(anim:getClip()))
end
```

---

#### `LAnimation:crossfade`

Starts a crossfade from the current clip to another clip.

```lua
LAnimation:crossfade(clip_name, duration)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `clip_name` | string | Destination clip name. |
| `duration` | number | Crossfade duration in seconds. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the destination clip exists and crossfade started. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFramesFromGrid(128, 32, 32, 32, 0, 4)
    anim:addClip("idle", { 0, 1 }, 4, true)
    anim:addClip("run", { 2, 3 }, 8, true)
    anim:play("idle")
    anim:crossfade("run", 0.3)
    lurek.log.info(tostring("crossfading to run"))
    lurek.log.info(tostring("blend state exists = " .. tostring(anim:getBlendState() ~= nil)))
end
```

---

#### `LAnimation:draw`

Draws the current animation frame without advancing playback.

```lua
LAnimation:draw(image, x, y, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `image?` | [LImage](render.md#limage) | Texture atlas or spritesheet; omit when an image was stored with setImage. |
| `x?` | number | Destination X position (default 0). |
| `y?` | number | Destination Y position (default 0). |
| `opts?` | table | Optional transform table with numeric `rotation`, `scale`, `scaleX`, `scaleY`, `originX`, and `originY` fields. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a frame draw command was queued; false when no current frame is active. |

**Example**

```lua
do
    local atlas = lurek.render.newImage("content/examples/assets/images/sample_icon.png")
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 16, 16)
    anim:addClip("idle", { 0 }, 1, true)
    anim:play("idle")
    local queued = anim:draw(atlas, 20, 24, { scale = 2.0 })
    lurek.log.info(tostring("animation draw queued = " .. tostring(queued)))
    anim:setImage(atlas)
    local queued2 = anim:draw(20, 24, { scale = 2.0 })
    lurek.log.info(tostring("animation draw (stored image) queued = " .. tostring(queued2)))
end
```

---

#### `LAnimation:drawPreviewGrid`

Rasterizes all animation frames into a preview grid image.

```lua
LAnimation:drawPreviewGrid(columns, cell_size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `columns` | number | Number of columns in the preview grid. |
| `cell_size` | number | Size of each preview cell in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](render.md#limagedata) | Image data containing the preview grid. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFramesFromGrid(128, 32, 32, 32, 0, 4)
    anim:addClip("preview", { 0, 1, 2, 3 }, 8, true)
    local previewImage = anim:drawPreviewGrid(4, 36)
    local frameCount = anim:getFrameCount()
    lurek.log.info("preview grid generated=" .. tostring(previewImage ~= nil))
    lurek.log.info("preview grid frame count=" .. tostring(frameCount))
end
```

---

#### `LAnimation:drawToImage`

Rasterizes the current animation frame into an image userdata.

```lua
LAnimation:drawToImage(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | number | Output image width in pixels. |
| `h` | number | Output image height in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](render.md#limagedata) | Image data containing the rendered frame. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("snap", { 0 }, 1, false)
    anim:play("snap")
    local img = anim:drawToImage(64, 64)
    lurek.log.info(tostring("drawn to image = " .. tostring(img ~= nil)))
end
```

---

#### `LAnimation:getBlendState`

Returns current crossfade rectangles and blend factor when a crossfade is active.

```lua
LAnimation:getBlendState()
```

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | Table with `from`, `to`, and `blend`, or nil when no blend is active. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("a", { 0 }, 5, true)
    anim:play("a")
    local bs = anim:getBlendState()
    lurek.log.info(tostring("blend state = " .. tostring(bs ~= nil)))
end
```

---

#### `LAnimation:getClip`

Returns the current clip name when a clip is active.

```lua
LAnimation:getClip()
```

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | Current clip name, or nil when no clip is active. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 16, 16)
    anim:addClip("walk", { 0 }, 8, true)
    anim:play("walk")
    lurek.log.info(tostring("clip = " .. anim:getClip()))
end
```

---

#### `LAnimation:getClipCount`

Returns the number of named clips stored in this animation.

```lua
LAnimation:getClipCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Clip count. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 16, 16)
    anim:addClip("a", { 0 }, 5, false)
    anim:addClip("b", { 0 }, 5, true)
    lurek.log.info(tostring("clip count = " .. anim:getClipCount()))
end
```

---

#### `LAnimation:getClipMode`

Returns the playback mode name for a clip when it exists.

```lua
LAnimation:getClipMode(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Clip name to query. |

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | Playback mode string, or nil when the clip does not exist. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("run", { 0 }, 12, true, "pingpong")
    local mode = anim:getClipMode("run")
    lurek.log.info(tostring("run mode = " .. mode))
end
```

---

#### `LAnimation:getCurrentFrame`

Returns the current frame index. This method is available to Lua scripts.

```lua
LAnimation:getCurrentFrame()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current frame index. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFramesFromGrid(64, 32, 32, 32, 0, 2)
    anim:addClip("pair", { 0, 1 }, 4, true)
    anim:play("pair")
    lurek.log.info(tostring("current frame = " .. anim:getCurrentFrame()))
end
```

---

#### `LAnimation:getFrameCount`

Returns the number of frame rectangles stored in this animation.

```lua
LAnimation:getFrameCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Frame count. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addFrame(32, 0, 32, 32)
    anim:addClip("turn", { 0, 1 }, 8, false)
    local frameCount = anim:getFrameCount()
    local clipCount = anim:getClipCount()
    lurek.log.info("turn animation frame count=" .. tostring(frameCount))
    lurek.log.info("turn animation clip count=" .. tostring(clipCount))
end
```

---

#### `LAnimation:getQuad`

Returns the current frame rectangle as a table.

```lua
LAnimation:getQuad()
```

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | Table with `x`, `y`, `w`, and `h`, or nil when no frame is active. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("single", { 0 }, 1, false)
    anim:play("single")
    local q = anim:getQuad()
    lurek.log.info(tostring("quad = " .. tostring(q ~= nil)))
    lurek.log.info(tostring("frame = " .. anim:getCurrentFrame()))
end
```

---

#### `LAnimation:getSpeed`

Returns the animation playback speed multiplier.

```lua
LAnimation:getSpeed()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current playback speed multiplier. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 16, 16)
    anim:addClip("idle", { 0 }, 4, true)
    local defaultSpeed = anim:getSpeed()
    anim:setSpeed(1.5)
    lurek.log.info("default playback speed=" .. tostring(defaultSpeed))
    lurek.log.info("boosted playback speed=" .. tostring(anim:getSpeed()))
end
```

---

#### `LAnimation:isLooping`

Returns whether the current clip loops.

```lua
LAnimation:isLooping()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the active clip is looping. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 16, 16)
    anim:addClip("loop_clip", { 0 }, 5, true)
    anim:play("loop_clip")
    lurek.log.info(tostring("looping = " .. tostring(anim:isLooping())))
end
```

---

#### `LAnimation:isPlaying`

Returns whether this animation is currently playing.

```lua
LAnimation:isPlaying()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when playback is active. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 16, 16)
    anim:addClip("x", { 0 }, 1, false)
    anim:play("x")
    lurek.log.info(tostring("after play = " .. tostring(anim:isPlaying())))
end
```

---

#### `LAnimation:pause`

Pauses animation playback without changing the current clip.

```lua
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
    lurek.log.info(tostring("playing after pause = " .. tostring(anim:isPlaying())))
    lurek.log.info(tostring("clip after pause = " .. tostring(anim:getClip())))
end
```

---

#### `LAnimation:play`

Starts playback of a named clip. This method is available to Lua scripts.

```lua
LAnimation:play(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Clip name to play. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the clip exists and playback started. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFramesFromGrid(128, 32, 32, 32, 0, 4)
    anim:addClip("idle", { 0, 1, 2, 3 }, 8, true)
    anim:play("idle")
    lurek.log.info(tostring("playing = " .. tostring(anim:isPlaying())))
end
```

---

#### `LAnimation:pollEvents`

Drains animation events produced since the previous poll.

```lua
LAnimation:pollEvents()
```

**Returns**

| Type | Description |
|------|-------------|
| LAnimationPollEventsResult | Array of event tables with `type` and optional `frame` fields. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("once", { 0 }, 10, false)
    anim:play("once")
    anim:update(1.0)
    local events = anim:pollEvents()
    lurek.log.info(tostring("events count = " .. #events))
end
```

---

#### `LAnimation:resume`

Resumes playback of a paused animation.

```lua
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
    lurek.log.info(tostring("playing after resume = " .. tostring(anim:isPlaying())))
    lurek.log.info(tostring("clip after resume = " .. tostring(anim:getClip())))
end
```

---

#### `LAnimation:seek`

Seeks to a frame index in the current clip.

```lua
LAnimation:seek(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | Frame index to make current. |

**Example**

```lua
do
    local anim = lurek.animation.fromFrames({
        { x = 0, y = 0, w = 8, h = 8 },
        { x = 8, y = 0, w = 8, h = 8 },
    }, { name = "idle", fps = 6, play = true })
    anim:seek(1)
    local frame = anim:getCurrentFrame()
    lurek.log.info("[animation] seek frame=" .. tostring(frame))
end
```

---

#### `LAnimation:setClipMode`

Changes the playback mode for an existing clip.

```lua
LAnimation:setClipMode(name, mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Clip name to update. |
| `mode` | string | Playback mode `forward`, `reverse`, or `pingpong`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the clip exists and the mode was changed. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("test", { 0 }, 5, true, "forward")
    anim:setClipMode("test", "reverse")
    lurek.log.info(tostring("clip mode set to reverse"))
    lurek.log.info(tostring("clip mode now = " .. tostring(anim:getClipMode("test"))))
end
```

---

#### `LAnimation:setFrame`

Sets the current frame index directly.

```lua
LAnimation:setFrame(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | Frame index to make current. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFramesFromGrid(128, 32, 32, 32, 0, 4)
    anim:addClip("seq", { 0, 1, 2, 3 }, 8, true)
    anim:play("seq")
    anim:setFrame(2)
    lurek.log.info(tostring("frame after setFrame = " .. anim:getCurrentFrame()))
end
```

---

#### `LAnimation:setImage`

Stores a spritesheet image on this animation so draw can be called without an explicit image argument.

```lua
LAnimation:setImage(image)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `image` | [LImage](render.md#limage) | Texture atlas or spritesheet containing the animation frames. |

**Example**

```lua
do
    local atlas = lurek.render.newImage("content/examples/assets/images/sample_icon.png")
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 16, 16)
    anim:addClip("idle", { 0 }, 1, true)
    anim:play("idle")
    anim:setImage(atlas)
    local queued = anim:draw(20, 24)
    lurek.log.info(tostring("setImage draw queued = " .. tostring(queued)))
end
```

---

#### `LAnimation:setSpeed`

Sets the animation playback speed multiplier.

```lua
LAnimation:setSpeed(speed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `speed` | number | Playback speed multiplier used by future updates. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:setSpeed(2.0)
    anim:addFrame(0, 0, 16, 16)
    anim:addClip("dash", { 0 }, 12, true)
    local boostedSpeed = anim:getSpeed()
    anim:setSpeed(0.5)
    lurek.log.info("dash speed boosted=" .. tostring(boostedSpeed))
    lurek.log.info("dash speed slowed=" .. tostring(anim:getSpeed()))
end
```

---

#### `LAnimation:stop`

Stops playback and resets animation playback state.

```lua
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
    lurek.log.info(tostring("playing after stop = " .. tostring(anim:isPlaying())))
    lurek.log.info(tostring("current frame after stop = " .. anim:getCurrentFrame()))
end
```

---

#### `LAnimation:type`

Returns the Lua-visible type name for this animation handle.

```lua
LAnimation:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LAnimation](#lanimation)`. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 16, 16)
    anim:addClip("idle", { 0 }, 1, true)
    local typeName = anim:type()
    local isAnimation = anim:typeOf("LAnimation")
    lurek.log.info("animation type=" .. tostring(typeName))
    lurek.log.info("is LAnimation=" .. tostring(isAnimation))
end
```

---

#### `LAnimation:typeOf`

Returns whether this animation handle matches a supported type name.

```lua
LAnimation:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LAnimation](#lanimation)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 16, 16)
    anim:addClip("idle", { 0 }, 1, true)
    local isAnimation = anim:typeOf("LAnimation")
    local isCurve = anim:typeOf("LAnimCurve")
    lurek.log.info("is animation=" .. tostring(isAnimation))
    lurek.log.info("is curve=" .. tostring(isCurve))
end
```

---

#### `LAnimation:update`

Advances animation playback and records any frame or clip events.

```lua
LAnimation:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Elapsed time in seconds. |

**Example**

```lua
do
    local anim = lurek.animation.new()
    anim:addFramesFromGrid(64, 32, 32, 32, 0, 2)
    anim:addClip("tick", { 0, 1 }, 2, true)
    anim:play("tick")
    anim:update(0.6)
    lurek.log.info(tostring("current frame after update = " .. anim:getCurrentFrame()))
end
```

---

## LBlendLayerSet

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LBlendLayerSet:addLayer`

Adds a weighted animation blend layer with an optional bone mask.

```lua
LBlendLayerSet:addLayer(name, clip_name, weight, bones)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Unique layer name. |
| `clip_name` | string | Animation clip name used by the layer. |
| `weight` | number | Blend weight for this layer. |
| `bones?` | table | Optional array or map table of bone names included in the mask. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the layer was added. |

**Example**

```lua
do
    local bls = lurek.animation.newBlendLayerSet()
    bls:addLayer("base", "idle", 1.0)
    bls:addLayer("upper_body", "aim", 0.35)
    local layerCount = bls:len()
    local upperWeight = bls:getWeight("upper_body")
    lurek.log.info("blend layers added=" .. tostring(layerCount))
    lurek.log.info("upper body aim weight=" .. tostring(upperWeight))
end
```

---

#### `LBlendLayerSet:getWeight`

Returns the weight for a blend layer when it exists.

```lua
LBlendLayerSet:getWeight(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Layer name to query. |

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | Layer weight, or nil when the layer does not exist. |

**Example**

```lua
do
    local bls = lurek.animation.newBlendLayerSet()
    bls:addLayer("run", "run_clip", 0.7)
    bls:addLayer("lean", "lean_clip", 0.25)
    local runWeight = bls:getWeight("run")
    local leanWeight = bls:getWeight("lean")
    lurek.log.info("run layer weight=" .. tostring(runWeight))
    lurek.log.info("lean layer weight=" .. tostring(leanWeight))
end
```

---

#### `LBlendLayerSet:len`

Returns the number of blend layers.

```lua
LBlendLayerSet:len()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Blend layer count. |

**Example**

```lua
do
    local bls = lurek.animation.newBlendLayerSet()
    bls:addLayer("a", "clip_a", 1.0)
    bls:addLayer("b", "clip_b", 0.5)
    local layerCount = bls:len()
    local secondWeight = bls:getWeight("b")
    lurek.log.info("blend layer count=" .. tostring(layerCount))
    lurek.log.info("second layer weight=" .. tostring(secondWeight))
end
```

---

#### `LBlendLayerSet:listLayers`

Returns all blend layers with names, clip names, weights, and bone masks.

```lua
LBlendLayerSet:listLayers()
```

**Returns**

| Type | Description |
|------|-------------|
| LBlendLayerSetListLayersResult | Array of layer tables with `name`, `clip_name`, `weight`, and `bones` fields. |

**Example**

```lua
do
    local bls = lurek.animation.newBlendLayerSet()
    bls:addLayer("base", "idle", 1.0)
    local names = bls:listLayers()
    lurek.log.info(tostring("layers = " .. #names))
    lurek.log.info(tostring("first layer = " .. tostring(names[1])))
end
```

---

#### `LBlendLayerSet:removeLayer`

Removes a blend layer by name. This method is available to Lua scripts.

```lua
LBlendLayerSet:removeLayer(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Layer name to remove. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the layer was removed. |

**Example**

```lua
do
    local bls = lurek.animation.newBlendLayerSet()
    bls:addLayer("temp", "idle", 1.0)
    bls:removeLayer("temp")
    lurek.log.info(tostring("layer removed"))
    lurek.log.info(tostring("layer count = " .. bls:len()))
end
```

---

#### `LBlendLayerSet:setMask`

Replaces a layer bone mask from a table of bone names.

```lua
LBlendLayerSet:setMask(name, bones)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Layer name to update. |
| `bones` | table | Array or map table of bone names included in the mask. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the layer exists and the mask was changed. |

**Example**

```lua
do
    local bls = lurek.animation.newBlendLayerSet()
    bls:addLayer("arms", "swing", 1.0)
    bls:setMask("arms", { "shoulder_l", "arm_l", "hand_l" })
    lurek.log.info(tostring("mask set for arms layer"))
    lurek.log.info(tostring("layer count = " .. bls:len()))
end
```

---

#### `LBlendLayerSet:setWeight`

Sets the blend weight for an existing layer.

```lua
LBlendLayerSet:setWeight(name, weight)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Layer name to update. |
| `weight` | number | New layer weight. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the layer exists and the weight was changed. |

**Example**

```lua
do
    local bls = lurek.animation.newBlendLayerSet()
    bls:addLayer("walk", "walk_clip", 0.5)
    bls:setWeight("walk", 0.8)
    lurek.log.info(tostring("weight = " .. bls:getWeight("walk")))
    lurek.log.info(tostring("layer count = " .. bls:len()))
end
```

---

#### `LBlendLayerSet:type`

Returns the Lua-visible type name for this blend layer set handle.

```lua
LBlendLayerSet:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LBlendLayerSet](#lblendlayerset)`. |

**Example**

```lua
do
    local bls = lurek.animation.newBlendLayerSet()
    bls:addLayer("base", "idle", 1.0)
    local typeName = bls:type()
    local isBlendSet = bls:typeOf("LBlendLayerSet")
    local layerCount = bls:len()
    lurek.log.info("blend set type=" .. tostring(typeName))
    lurek.log.info("is blend set=" .. tostring(isBlendSet) .. " layers=" .. tostring(layerCount))
end
```

---

#### `LBlendLayerSet:typeOf`

Returns whether this blend layer set handle matches a supported type name.

```lua
LBlendLayerSet:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LBlendLayerSet](#lblendlayerset)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local bls = lurek.animation.newBlendLayerSet()
    bls:addLayer("base", "idle", 1.0)
    local isBlendSet = bls:typeOf("LBlendLayerSet")
    local isAnimation = bls:typeOf("LAnimation")
    lurek.log.info("is blend layer set=" .. tostring(isBlendSet))
    lurek.log.info("is animation=" .. tostring(isAnimation))
end
```

---

## LSpriteSheet

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LSpriteSheet:drawToImage`

Renders the sprite sheet grid into an [LImage](render.md#limage) of the given size for debugging or previews.

```lua
LSpriteSheet:drawToImage(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | number | Output image width in pixels. |
| `h` | number | Output image height in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| [LImage](render.md#limage) | A new image containing the rendered sprite sheet. |

---

#### `LSpriteSheet:getColumn`

Returns all frame quads in the given column of the sprite sheet grid.

```lua
LSpriteSheet:getColumn(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | number | 0-based column index. |

**Returns**

| Type | Description |
|------|-------------|
| LSpriteSheetGetColumnResult | Array of quad tables `{x, y, w, h}`. |

---

#### `LSpriteSheet:getFrame`

Returns the UV quad for a single frame by its 1-based index.

```lua
LSpriteSheet:getFrame(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | 1-based frame index in the sprite sheet. |

**Returns**

| Type | Description |
|------|-------------|
| LSpriteSheetGetFrameResult | Quad table `{x, y, w, h}` with normalized UV coordinates, or nil if the index is out of range. |

---

#### `LSpriteSheet:getFrameCount`

Returns the total number of frames in this sprite sheet.

```lua
LSpriteSheet:getFrameCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Total frame count (columns Ă— rows). |

---

#### `LSpriteSheet:getFrameSize`

Returns the pixel dimensions of a single frame cell.

```lua
LSpriteSheet:getFrameSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Frame width in pixels. |
| number | Frame height in pixels. |

---

#### `LSpriteSheet:getGridSize`

Returns the number of columns and rows in the sprite sheet grid.

```lua
LSpriteSheet:getGridSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Number of columns. |
| number | Number of rows. |

---

#### `LSpriteSheet:getGroupFrames`

Returns the frame quads for a named animation group.

```lua
LSpriteSheet:getGroupFrames(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Name of the animation group (e.g. "walk", "idle"). |

**Returns**

| Type | Description |
|------|-------------|
| LSpriteSheetGetGroupFramesResult | Array of quad tables for the group, or nil if the group does not exist. |

---

#### `LSpriteSheet:getGroupNames`

Returns an array of all named animation group names defined on this sheet.

```lua
LSpriteSheet:getGroupNames()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Group name strings. |

---

#### `LSpriteSheet:getRow`

Returns all frame quads in the given row of the sprite sheet grid.

```lua
LSpriteSheet:getRow(row)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `row` | number | 0-based row index. |

**Returns**

| Type | Description |
|------|-------------|
| LSpriteSheetGetRowResult | Array of quad tables `{x, y, w, h}`. |

---

#### `LSpriteSheet:nameGroup`

Defines a named animation group as a contiguous range of frames.

```lua
LSpriteSheet:nameGroup(name, start, count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Name for the group (e.g. "attack"). |
| `start` | number | 1-based start frame index. |
| `count` | number | Number of frames in the group. |

---

#### `LSpriteSheet:toAnimationClip`

Builds an animation clip DTO from this sheet without creating playback state.

```lua
LSpriteSheet:toAnimationClip(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts?` | table | `{name, group, fps, loop, mode}`. |

**Returns**

| Type | Description |
|------|-------------|
| table | Clip DTO with `name`, `frames`, `fps`, `loop`, and `mode`. |

---

#### `LSpriteSheet:toFrames`

Returns frame rectangle DTOs for all frames or a named group.

```lua
LSpriteSheet:toFrames(group)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `group?` | string | Optional group name. |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of `{x, y, w, h}` frame rectangles. |

---

#### `LSpriteSheet:type`

Returns the type name of this object.

```lua
LSpriteSheet:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always `"[LSpriteSheet](#lspritesheet)"`. |

---

#### `LSpriteSheet:typeOf`

Checks whether this object matches the given type name.

```lua
LSpriteSheet:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check (e.g. `"[LSpriteSheet](#lspritesheet)"` or `"Object"`). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the object is the given type. |

---
