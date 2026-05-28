# Effect

- The `effect` module is a comprehensive Platform Services component responsible for the engine's post-processing and screen-space visual effects pipeline.
- **Note:** Weather, atmosphere, and screen overlay effects have been extracted to `src/overlay/` — see [`docs/specs/overlay.md`](overlay.md).

It provides developers with the tools to significantly enhance the visual fidelity of their games through composable, full-screen shaders and overlays. The core of this pipeline is the `PostFxStack`, which manages an ordered list of `PostFxEffect` instances. These effects process the rendered frame buffer sequentially before it is presented to the screen. The built-in effects catalog is extensive, offering varied blur algorithms (Gaussian, box, radial), bloom (combining thresholding, blurring, and additive blending), LUT-based color grading, lens distortion, vignette, chromatic aberration, scanlines, CRT curvature, film grain, and pixelation. Custom shader passes are also fully supported via explicit shader handles.

Operating parallel to the shader pipeline is the `Overlay` controller. It manages screen-space, CPU-driven visual states that overlay the world, such as ambient lighting tints driven by a time-of-day curve (dawn, day, dusk, night) and complex weather particle simulations (rain, snow, hail, dust, leaves, ash, pollen). The `Overlay` system also handles instantaneous atmospheric triggers, including screen flashes, camera shakes with deterministic PRNG offsets, lightning flashes, and fade-in/fade-out transitions. A specialized `WaterOverlay` adds animated water surface distortion with configurable amplitude and depth-based color shifting.

For bridging scene changes, the module includes a `ScreenTransition` state machine offering classic visual transitions (fade, wipe, iris wipe, dissolve) with time-based playback and reverse capabilities. For scenarios where GPU post-processing is unnecessary or unavailable, `ImageEffect` provides CPU-side per-pixel operations. The entire module is heavily configurable via Lua scripts through the `lurek.effect.*` namespace, allowing for dynamic, real-time adjustments to effect stacks, preset loading, and weather conditions.

## Functions

### `lurek.effect.getEffectTypes`

Returns all built-in post-processing effect type names.

```lua
-- signature
lurek.effect.getEffectTypes()
```

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Built-in effect type strings. |

**Example**

```lua
do
    local types = lurek.effect.getEffectTypes()
    print("available types = " .. #types)
end
```

---

### `lurek.effect.getPresetNames`

Returns all built-in post-processing preset names.

```lua
-- signature
lurek.effect.getPresetNames()
```

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Built-in preset name strings. |

**Example**

```lua
do
    local names = lurek.effect.getPresetNames()
    print("preset count = " .. #names)
    print("first preset = " .. tostring(names[1]))
end
```

---

### `lurek.effect.getShaderErrorDisplay`

Returns whether renderer shader error display overlays are enabled.

```lua
-- signature
lurek.effect.getShaderErrorDisplay()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when shader error display is enabled. |

**Example**

```lua
do
    local on = lurek.effect.getShaderErrorDisplay()
    print("shader error display = " .. tostring(on))
end
```

---

### `lurek.effect.newCustomEffect`

Creates a custom post-processing effect that references an existing shader id.

```lua
-- signature
lurek.effect.newCustomEffect(shader_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `shader_id` | `number` | Renderer shader identifier used for the custom effect. |

**Returns**

| Type | Description |
|------|-------------|
| `LPostFxEffect` | New custom post-processing effect handle. |

**Example**

```lua
do
    local fx = lurek.effect.newCustomEffect(1)
    print("custom effect built-in = " .. tostring(fx:isBuiltIn()))
end
```

---

### `lurek.effect.newEffect`

Creates a built-in post-processing effect by type name.

```lua
-- signature
lurek.effect.newEffect(type_name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_name` | `string` | Built-in effect type name such as `blur`, `bloom`, or `crt`. |

**Returns**

| Type | Description |
|------|-------------|
| `LPostFxEffect` | New post-processing effect handle. |

**Example**

```lua
do
    local fx = lurek.effect.newEffect("bloom")
    print("effect type = " .. fx:getType())
    print("built-in = " .. tostring(fx:isBuiltIn()))
end
```

---

### `lurek.effect.newImageEffect`

Creates an image effect chain from no arguments, a type name and optional parameters, or a chain table.

```lua
-- signature
lurek.effect.newImageEffect(spec, params)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `spec?` | `LuaValue` | Optional effect type string, or an array table of effect entries, or nil for an empty chain. |
| `params?` | `table` | Optional parameter table used when `spec` is an effect type string. |

**Returns**

| Type | Description |
|------|-------------|
| `LImageEffect` | New image effect chain handle. |

**Example**

```lua
do
    local ie = lurek.effect.newImageEffect()
    print("image effect count = " .. ie:getEffectCount())
end
```

---

### `lurek.effect.newPass`

Creates a custom post-processing pass from an existing shader id.

```lua
-- signature
lurek.effect.newPass(shader_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `shader_id` | `number` | Renderer shader identifier used for the pass. |

**Returns**

| Type | Description |
|------|-------------|
| `LPostFxEffect` | New custom post-processing effect handle. |

**Example**

```lua
do
    local fx = lurek.effect.newPass(2)
    print("pass type = " .. fx:getType())
end
```

---

### `lurek.effect.newPresetStack`

Creates a named preset post-processing stack with optional dimensions.

```lua
-- signature
lurek.effect.newPresetStack(name, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Preset stack name. |
| `w?` | `number` | Stack width in pixels, defaulting to window width. |
| `h?` | `number` | Stack height in pixels, defaulting to window height. |

**Returns**

| Type | Description |
|------|-------------|
| `LPostFxStack` | New preset post-processing stack handle. |

**Example**

```lua
do
    local stack = lurek.effect.newPresetStack("retro_tv", 320, 240)
    print("preset stack effects = " .. stack:getEffectCount())
end
```

---

### `lurek.effect.newStack`

Creates a post-processing stack using optional dimensions or the current window size.

```lua
-- signature
lurek.effect.newStack(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w?` | `number` | Stack width in pixels, defaulting to window width. |
| `h?` | `number` | Stack height in pixels, defaulting to window height. |

**Returns**

| Type | Description |
|------|-------------|
| `LPostFxStack` | New post-processing stack handle. |

**Example**

```lua
do
    local stack = lurek.effect.newStack(800, 600)
    print("stack w=" .. stack:getWidth() .. " h=" .. stack:getHeight())
end
```

---

### `lurek.effect.setShaderErrorDisplay`

Enables or disables renderer shader error display overlays.

```lua
-- signature
lurek.effect.setShaderErrorDisplay(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | `boolean` | New shader error display flag. |

**Example**

```lua
do
    lurek.effect.setShaderErrorDisplay(true)
    print("shader errors on")
end
```

---

## LImageEffect

### `LImageEffect:addEffect`

Appends a built-in post-effect by type name to this image effect chain.

```lua
-- signature
LImageEffect:addEffect(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Built-in effect type name. |

**Returns**

| Type | Description |
|------|-------------|
| `LPostFxEffect` | Handle for the effect added to the chain. |

**Example**

```lua
do
    local ie = lurek.effect.newImageEffect()
    local fx = ie:addEffect("bloom")
    print("added effect type = " .. fx:getType())
end
```

---

### `LImageEffect:clear`

Removes every effect from this image effect chain.

```lua
-- signature
LImageEffect:clear()
```

**Example**

```lua
do
    local ie = lurek.effect.newImageEffect()
    ie:addEffect("bloom")
    ie:clear()
    print("after clear = " .. ie:getEffectCount())
end
```

---

### `LImageEffect:clearEffects`

Removes every effect from this image effect chain.

```lua
-- signature
LImageEffect:clearEffects()
```

**Example**

```lua
do
    local ie = lurek.effect.newImageEffect()
    ie:addEffect("crt")
    ie:clearEffects()
    print("after clearEffects = " .. ie:getEffectCount())
end
```

---

### `LImageEffect:clone`

Creates a new image effect chain with cloned effect entries.

```lua
-- signature
LImageEffect:clone()
```

**Returns**

| Type | Description |
|------|-------------|
| `LImageEffect` | New image effect handle with the same effect chain. |

**Example**

```lua
do
    local ie = lurek.effect.newImageEffect()
    ie:addEffect("bloom")
    local copy = ie:clone()
    print("clone count = " .. copy:getEffectCount())
end
```

---

### `LImageEffect:effectCount`

Returns the number of effects in this image effect chain.

```lua
-- signature
LImageEffect:effectCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Effect count. |

**Example**

```lua
do
    local ie = lurek.effect.newImageEffect()
    ie:addEffect("crt")
    print("effectCount = " .. ie:effectCount())
end
```

---

### `LImageEffect:getEffect`

Looks up an image effect by one-based index or effect type name.

```lua
-- signature
LImageEffect:getEffect(key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | `string` | Effect name string or one-based integer index. |

**Returns**

| Type | Description |
|------|-------------|
| `LuaValue` | `LPostFxEffect` handle, or nil when no matching effect exists. |

**Example**

```lua
do
    local ie = lurek.effect.newImageEffect()
    ie:addEffect("blur")
    local fx = ie:getEffect("blur")
    print("found effect = " .. tostring(fx ~= nil))
end
```

---

### `LImageEffect:getEffectCount`

Returns the number of effects in this image effect chain.

```lua
-- signature
LImageEffect:getEffectCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Effect count. |

**Example**

```lua
do
    local ie = lurek.effect.newImageEffect()
    ie:addEffect("bloom")
    ie:addEffect("blur")
    print("count = " .. ie:getEffectCount())
end
```

---

### `LImageEffect:removeByIndex`

Removes an image effect by zero-based internal index.

```lua
-- signature
LImageEffect:removeByIndex(idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | `number` | Zero-based effect index. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when an effect was removed. |

**Example**

```lua
do
    local ie = lurek.effect.newImageEffect()
    ie:addEffect("bloom")
    local ok = ie:removeByIndex(0)
    print("removeByIndex = " .. tostring(ok))
end
```

---

### `LImageEffect:removeByName`

Removes the first image effect with a matching effect type name.

```lua
-- signature
LImageEffect:removeByName(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Effect type name to remove. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when an effect was removed. |

**Example**

```lua
do
    local ie = lurek.effect.newImageEffect()
    ie:addEffect("blur")
    local ok = ie:removeByName("blur")
    print("removeByName = " .. tostring(ok))
end
```

---

### `LImageEffect:removeEffect`

Removes an image effect by one-based index or effect type name.

```lua
-- signature
LImageEffect:removeEffect(key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | `string` | Effect name string or one-based integer index. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when an effect was removed. |

**Example**

```lua
do
    local ie = lurek.effect.newImageEffect()
    ie:addEffect("bloom")
    local ok = ie:removeEffect("bloom")
    print("removed = " .. tostring(ok))
end
```

---

### `LImageEffect:save`

Reports success for the current image effect save placeholder.

```lua
-- signature
LImageEffect:save()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | Always true. |

**Example**

```lua
do
    local ie = lurek.effect.newImageEffect()
    local ok = ie:save()
    print("save = " .. tostring(ok))
end
```

---

### `LImageEffect:type`

Returns the Lua-visible type name for this image effect handle.

```lua
-- signature
LImageEffect:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LImageEffect`. |

**Example**

```lua
do
    local ie = lurek.effect.newImageEffect()
    print("type = " .. ie:type())
end
```

---

### `LImageEffect:typeOf`

Returns whether this image effect handle matches a supported type name.

```lua
-- signature
LImageEffect:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `ImageEffect` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local ie = lurek.effect.newImageEffect()
    print("is ImageEffect = " .. tostring(ie:typeOf("LImageEffect")))
end
```

---

## LPostFxEffect

### `LPostFxEffect:disableAutoUniforms`

Disables automatic time and resolution uniforms for this effect.

```lua
-- signature
LPostFxEffect:disableAutoUniforms()
```

**Example**

```lua
do
    local fx = lurek.effect.newEffect("bloom")
    fx:disableAutoUniforms()
    print("auto uniforms off = " .. tostring(fx:isAutoUniforms()))
end
```

---

### `LPostFxEffect:enableAutoUniforms`

Enables automatic time and resolution uniforms for this effect.

```lua
-- signature
LPostFxEffect:enableAutoUniforms()
```

**Example**

```lua
do
    local fx = lurek.effect.newEffect("bloom")
    fx:enableAutoUniforms()
    print("auto uniforms on = " .. tostring(fx:isAutoUniforms()))
end
```

---

### `LPostFxEffect:getEffectType`

Returns the renderer effect type name.

```lua
-- signature
LPostFxEffect:getEffectType()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Effect type name used by the renderer. |

**Example**

```lua
do
    local fx = lurek.effect.newEffect("bloom")
    print("effectType = " .. fx:getEffectType())
end
```

---

### `LPostFxEffect:getParameter`

Reads a numeric shader parameter and falls back to a default value when missing.

```lua
-- signature
LPostFxEffect:getParameter(name, default)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Parameter name to read. |
| `default?` | `number` | Default value returned when the parameter is absent. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Stored parameter value or the supplied default. |

**Example**

```lua
do
    local fx = lurek.effect.newEffect("bloom")
    fx:setParameter("intensity", 1.5)
    local v = fx:getParameter("intensity", 1.0)
    print("intensity = " .. v)
end
```

---

### `LPostFxEffect:getParameterNames`

Returns the parameter names stored on this effect.

```lua
-- signature
LPostFxEffect:getParameterNames()
```

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Parameter name strings. |

**Example**

```lua
do
    local fx = lurek.effect.newEffect("bloom")
    fx:setParameter("threshold", 0.5)
    local names = fx:getParameterNames()
    print("param names = " .. #names)
end
```

---

### `LPostFxEffect:getType`

Returns the renderer effect type name.

```lua
-- signature
LPostFxEffect:getType()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Effect type name used by the renderer. |

**Example**

```lua
do
    local fx = lurek.effect.newEffect("blur")
    print("type = " .. fx:getType())
end
```

---

### `LPostFxEffect:getTypeName`

Returns the built-in or custom effect type name.

```lua
-- signature
LPostFxEffect:getTypeName()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Effect type name used by the renderer. |

**Example**

```lua
do
    local fx = lurek.effect.newEffect("crt")
    print("typeName = " .. fx:getTypeName())
end
```

---

### `LPostFxEffect:hasParameter`

Returns whether a shader parameter exists on this effect.

```lua
-- signature
LPostFxEffect:hasParameter(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Parameter name to check. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the parameter is present. |

**Example**

```lua
do
    local fx = lurek.effect.newEffect("blur")
    fx:setParameter("radius", 4)
    print("has radius = " .. tostring(fx:hasParameter("radius")))
end
```

---

### `LPostFxEffect:isAutoUniforms`

Returns whether automatic uniforms are enabled for this effect.

```lua
-- signature
LPostFxEffect:isAutoUniforms()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when automatic uniforms are enabled. |

**Example**

```lua
do
    local fx = lurek.effect.newEffect("bloom")
    print("autoUniforms = " .. tostring(fx:isAutoUniforms()))
end
```

---

### `LPostFxEffect:isBuiltIn`

Returns whether this effect uses one of the engine built-in effect types.

```lua
-- signature
LPostFxEffect:isBuiltIn()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True for built-in effects, false for custom shader effects. |

**Example**

```lua
do
    local fx = lurek.effect.newEffect("blur")
    print("builtIn = " .. tostring(fx:isBuiltIn()))
end
```

---

### `LPostFxEffect:isEnabled`

Returns whether this effect is enabled on its owning effect object.

```lua
-- signature
LPostFxEffect:isEnabled()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | Current enabled flag stored on the effect. |

**Example**

```lua
do
    local fx = lurek.effect.newEffect("bloom")
    print("enabled = " .. tostring(fx:isEnabled()))
end
```

---

### `LPostFxEffect:setBrightness`

Sets the brightness shader parameter on this effect.

```lua
-- signature
LPostFxEffect:setBrightness(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | Brightness value passed to the effect shader. |

**Example**

```lua
do
    local fx = lurek.effect.newEffect("bloom")
    fx:setBrightness(1.2)
    print("brightness set")
end
```

---

### `LPostFxEffect:setContrast`

Sets the contrast shader parameter on this effect.

```lua
-- signature
LPostFxEffect:setContrast(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | Contrast value passed to the effect shader. |

**Example**

```lua
do
    local fx = lurek.effect.newEffect("bloom")
    fx:setContrast(1.1)
    print("contrast set")
end
```

---

### `LPostFxEffect:setEnabled`

Enables or disables this effect. This method is available to Lua scripts.

```lua
-- signature
LPostFxEffect:setEnabled(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | `boolean` | New enabled flag. |

**Example**

```lua
do
    local fx = lurek.effect.newEffect("bloom")
    fx:setEnabled(false)
    print("after disable = " .. tostring(fx:isEnabled()))
end
```

---

### `LPostFxEffect:setIntensity`

Sets the intensity shader parameter on this effect.

```lua
-- signature
LPostFxEffect:setIntensity(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | Intensity value passed to the effect shader. |

**Example**

```lua
do
    local fx = lurek.effect.newEffect("bloom")
    fx:setIntensity(2.0)
    print("intensity set")
end
```

---

### `LPostFxEffect:setOffset`

Sets the offset shader parameter on this effect.

```lua
-- signature
LPostFxEffect:setOffset(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | Offset value passed to the effect shader. |

**Example**

```lua
do
    local fx = lurek.effect.newEffect("crt")
    fx:setOffset(0.002)
    print("offset set")
end
```

---

### `LPostFxEffect:setParameter`

Sets a numeric shader parameter by name.

```lua
-- signature
LPostFxEffect:setParameter(name, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Parameter name expected by the effect shader. |
| `value` | `number` | Numeric parameter value. |

**Example**

```lua
do
    local fx = lurek.effect.newEffect("bloom")
    fx:setParameter("threshold", 0.8)
    print("param set")
end
```

---

### `LPostFxEffect:setRadius`

Sets the radius shader parameter on this effect.

```lua
-- signature
LPostFxEffect:setRadius(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | Radius value passed to the effect shader. |

**Example**

```lua
do
    local fx = lurek.effect.newEffect("blur")
    fx:setRadius(8)
    print("radius set")
end
```

---

### `LPostFxEffect:setSaturation`

Sets the saturation shader parameter on this effect.

```lua
-- signature
LPostFxEffect:setSaturation(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | Saturation value passed to the effect shader. |

**Example**

```lua
do
    local fx = lurek.effect.newEffect("bloom")
    fx:setSaturation(0.8)
    print("saturation set")
end
```

---

### `LPostFxEffect:setScanlineStrength`

Sets the scanline strength shader parameter on this effect.

```lua
-- signature
LPostFxEffect:setScanlineStrength(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | Scanline strength value passed to the effect shader. |

**Example**

```lua
do
    local fx = lurek.effect.newEffect("crt")
    fx:setScanlineStrength(0.3)
    print("scanline set")
end
```

---

### `LPostFxEffect:setStrength`

Sets the strength shader parameter on this effect.

```lua
-- signature
LPostFxEffect:setStrength(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | Strength value passed to the effect shader. |

**Example**

```lua
do
    local fx = lurek.effect.newEffect("blur")
    fx:setStrength(0.5)
    print("strength set")
end
```

---

### `LPostFxEffect:setThreshold`

Sets the threshold shader parameter on this effect.

```lua
-- signature
LPostFxEffect:setThreshold(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | Threshold value passed to the effect shader. |

**Example**

```lua
do
    local fx = lurek.effect.newEffect("bloom")
    fx:setThreshold(0.6)
    print("threshold set")
end
```

---

### `LPostFxEffect:type`

Returns the Lua-visible type name for this post-processing effect handle.

```lua
-- signature
LPostFxEffect:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LPostFxEffect`. |

**Example**

```lua
do
    local fx = lurek.effect.newEffect("blur")
    print("type = " .. fx:type())
end
```

---

### `LPostFxEffect:typeOf`

Returns whether this effect handle matches a supported type name.

```lua
-- signature
LPostFxEffect:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `PostFxEffect` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local fx = lurek.effect.newEffect("blur")
    print("is PostFxEffect = " .. tostring(fx:typeOf("LPostFxEffect")))
end
```

---

## LPostFxStack

### `LPostFxStack:add`

Appends an effect to the end of this stack.

```lua
-- signature
LPostFxStack:add(effect_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `effect_ud` | `LPostFxEffect` | Effect handle to append. |

**Example**

```lua
do
    local stack = lurek.effect.newStack(800, 600)
    local fx = lurek.effect.newEffect("bloom")
    stack:add(fx)
    print("stack count = " .. stack:getEffectCount())
end
```

---

### `LPostFxStack:apply`

Queues this stack's enabled post-effect passes for renderer application.

```lua
-- signature
LPostFxStack:apply()
```

**Example**

```lua
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:beginCapture()
    stack:endCapture()
    stack:apply()
    print("applied")
end
```

---

### `LPostFxStack:beginCapture`

Starts post-effect capture and queues a renderer begin-capture command.

```lua
-- signature
LPostFxStack:beginCapture()
```

**Example**

```lua
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:beginCapture()
    print("capture started")
end
```

---

### `LPostFxStack:clear`

Removes all effects and pass state from this stack.

```lua
-- signature
LPostFxStack:clear()
```

**Example**

```lua
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:clear()
    print("after clear = " .. stack:getEffectCount())
end
```

---

### `LPostFxStack:clearFeedback`

Resets the stack feedback blend factor to zero.

```lua
-- signature
LPostFxStack:clearFeedback()
```

**Example**

```lua
do
    local stack = lurek.effect.newStack(800, 600)
    stack:setFeedback(0.8)
    stack:clearFeedback()
    print("cleared feedback = " .. stack:getFeedback())
end
```

---

### `LPostFxStack:dedup`

Removes duplicate effect handles while preserving first occurrences.

```lua
-- signature
LPostFxStack:dedup()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Number of duplicate effects removed. |

**Example**

```lua
do
    local stack = lurek.effect.newStack(800, 600)
    local fx = lurek.effect.newEffect("bloom")
    stack:add(fx)
    stack:add(fx)
    local removed = stack:dedup()
    print("dedup removed = " .. removed)
end
```

---

### `LPostFxStack:endCapture`

Ends post-effect capture and queues a renderer end-capture command.

```lua
-- signature
LPostFxStack:endCapture()
```

**Example**

```lua
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:beginCapture()
    stack:endCapture()
    print("capture ended")
end
```

---

### `LPostFxStack:getDimensions`

Returns the stack render dimensions.

```lua
-- signature
LPostFxStack:getDimensions()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Stack width in pixels. |
| `number` | b Stack height in pixels. |

**Example**

```lua
do
    local stack = lurek.effect.newStack(800, 600)
    local w, h = stack:getDimensions()
    print("dims = " .. w .. "x" .. h)
end
```

---

### `LPostFxStack:getEffect`

Returns the effect handle at a one-based position.

```lua
-- signature
LPostFxStack:getEffect(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | `number` | One-based stack position. |

**Returns**

| Type | Description |
|------|-------------|
| `LuaValue` | `LPostFxEffect` handle, or nil when the index is out of range. |

**Example**

```lua
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    local fx = stack:getEffect(1)
    print("got effect at 1 = " .. tostring(fx ~= nil))
end
```

---

### `LPostFxStack:getEffectCount`

Returns the number of effect handles in this stack.

```lua
-- signature
LPostFxStack:getEffectCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Effect count. |

**Example**

```lua
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:add(lurek.effect.newEffect("blur"))
    print("effect count = " .. stack:getEffectCount())
end
```

---

### `LPostFxStack:getEnabledEffects`

Returns effect handles whose stack passes are enabled.

```lua
-- signature
LPostFxStack:getEnabledEffects()
```

**Returns**

| Type | Description |
|------|-------------|
| `LPostFxEffect[]` | Enabled `LPostFxEffect` handles. |

**Example**

```lua
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:add(lurek.effect.newEffect("blur"))
    local enabled = stack:getEnabledEffects()
    print("enabled effects = " .. #enabled)
end
```

---

### `LPostFxStack:getFeedback`

Returns the current stack feedback blend factor.

```lua
-- signature
LPostFxStack:getFeedback()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Feedback blend factor in the range 0.0 through 1.0. |

**Example**

```lua
do
    local stack = lurek.effect.newStack(800, 600)
    stack:setFeedback(0.3)
    print("feedback = " .. stack:getFeedback())
end
```

---

### `LPostFxStack:getHeight`

Returns the stack render height. This method is available to Lua scripts.

```lua
-- signature
LPostFxStack:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Stack height in pixels. |

**Example**

```lua
do
    local stack = lurek.effect.newStack(1024, 768)
    print("height = " .. stack:getHeight())
end
```

---

### `LPostFxStack:getWidth`

Returns the stack render width. This method is available to Lua scripts.

```lua
-- signature
LPostFxStack:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Stack width in pixels. |

**Example**

```lua
do
    local stack = lurek.effect.newStack(1024, 768)
    print("width = " .. stack:getWidth())
end
```

---

### `LPostFxStack:insert`

Inserts an effect at a one-based stack position.

```lua
-- signature
LPostFxStack:insert(position, effect_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `position` | `number` | One-based insertion position, clamped to the stack length. |
| `effect_ud` | `LPostFxEffect` | Effect handle to insert. |

**Example**

```lua
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:insert(1, lurek.effect.newEffect("blur"))
    print("after insert count = " .. stack:getEffectCount())
end
```

---

### `LPostFxStack:isCapturing`

Returns whether this stack is currently capturing draw commands.

```lua
-- signature
LPostFxStack:isCapturing()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when capture mode is active. |

**Example**

```lua
do
    local stack = lurek.effect.newStack(800, 600)
    print("capturing = " .. tostring(stack:isCapturing()))
end
```

---

### `LPostFxStack:isEmpty`

Returns whether this stack has no effects.

```lua
-- signature
LPostFxStack:isEmpty()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the stack has zero effects. |

**Example**

```lua
do
    local stack = lurek.effect.newStack(800, 600)
    print("empty = " .. tostring(stack:isEmpty()))
end
```

---

### `LPostFxStack:isEnabled`

Returns whether the effect pass at a one-based position is enabled.

```lua
-- signature
LPostFxStack:isEnabled(position)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `position` | `number` | One-based stack position. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the pass is enabled; false for out-of-range positions. |

**Example**

```lua
do
    local stack = lurek.effect.newStack(800, 600)
    local fx = lurek.effect.newEffect("blur")
    stack:add(fx)
    print("pass enabled = " .. tostring(stack:isEnabled(1)))
end
```

---

### `LPostFxStack:len`

Returns the number of effect handles in this stack.

```lua
-- signature
LPostFxStack:len()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Effect count. |

**Example**

```lua
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    print("len = " .. stack:len())
end
```

---

### `LPostFxStack:remove`

Removes the first matching effect handle from this stack.

```lua
-- signature
LPostFxStack:remove(effect_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `effect_ud` | `LPostFxEffect` | Effect handle to remove. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the effect was found and removed. |

**Example**

```lua
do
    local stack = lurek.effect.newStack(800, 600)
    local fx = lurek.effect.newEffect("blur")
    stack:add(fx)
    local ok = stack:remove(fx)
    print("removed = " .. tostring(ok))
end
```

---

### `LPostFxStack:resize`

Resizes the post-processing stack render target dimensions.

```lua
-- signature
LPostFxStack:resize(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | `number` | New width in pixels. |
| `h` | `number` | New height in pixels. |

**Example**

```lua
do
    local stack = lurek.effect.newStack(800, 600)
    stack:resize(1920, 1080)
    print("resized w=" .. stack:getWidth())
end
```

---

### `LPostFxStack:setEnabled`

Enables or disables the effect pass at a one-based stack position.

```lua
-- signature
LPostFxStack:setEnabled(position, enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `position` | `number` | One-based stack position. |
| `enabled` | `boolean` | New enabled flag for the pass. |

**Example**

```lua
do
    local stack = lurek.effect.newStack(800, 600)
    local fx = lurek.effect.newEffect("bloom")
    stack:add(fx)
    stack:setEnabled(1, false)
    print("pass 1 enabled = " .. tostring(stack:isEnabled(1)))
end
```

---

### `LPostFxStack:setFeedback`

Sets the stack feedback blend factor and clamps it to 0.0 through 1.0.

```lua
-- signature
LPostFxStack:setFeedback(factor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `factor` | `number` | Feedback blend factor. |

**Example**

```lua
do
    local stack = lurek.effect.newStack(800, 600)
    stack:setFeedback(0.5)
    print("feedback = " .. stack:getFeedback())
end
```

---

### `LPostFxStack:type`

Returns the Lua-visible type name for this post-processing stack handle.

```lua
-- signature
LPostFxStack:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LPostFxStack`. |

**Example**

```lua
do
    local stack = lurek.effect.newStack(800, 600)
    print("type = " .. stack:type())
end
```

---

### `LPostFxStack:typeOf`

Returns whether this stack handle matches a supported type name.

```lua
-- signature
LPostFxStack:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `PostFxStack` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local stack = lurek.effect.newStack(800, 600)
    print("is PostFxStack = " .. tostring(stack:typeOf("LPostFxStack")))
end
```

---
