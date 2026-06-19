# Effect

## Summary

- The `effect` module is the post-processing surface for users who want final-frame styling to be configurable at runtime instead of buried in renderer internals.
- Effect stacks, presets, and parameter control let projects combine blur, bloom, grading, distortion, and custom passes as a reusable look pipeline rather than as isolated toggles.
- The same module supports both full-frame and image-scoped workflows, which makes it useful for global scene mood, local asset treatment, and diagnostic capture flows.
- Runtime enabling, disabling, and reordering matter because visual iteration often depends on trying combinations quickly while the game is running.
- Preset-oriented workflow is a major user-facing advantage because art direction usually depends on named looks that can be switched, blended, or tuned per scene instead of rebuilt from scratch each time.
- That makes the module valuable for shipped presentation, look development, and visual comparison.
- It is especially useful when several passes need to be staged and tuned together as one style decision.
- It also keeps composition policy above the renderer, so projects can adjust how global and local treatments are assembled without rewriting low-level pass code.
- Read `effect` as the owner of effect composition and art-direction control. The renderer executes passes, but `effect` defines how those passes are organized and tuned from the user side.

## Functions

### `lurek.effect.getEffectTypes`

Returns all built-in post-processing effect type names.

```lua
lurek.effect.getEffectTypes()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Built-in effect type strings. |

**Example**

```lua
do
    local types = lurek.effect.getEffectTypes()
    local stack = lurek.effect.newStack(640, 360)
    stack:add(lurek.effect.newEffect(types[1] or "bloom"))
    local first = types[1] or "none"
    effect_log("effect catalog size=" .. #types .. " first=" .. first)
end
```

---

### `lurek.effect.getPresetNames`

Returns all built-in post-processing preset names.

```lua
lurek.effect.getPresetNames()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Built-in preset name strings. |

**Example**

```lua
do
    local names = lurek.effect.getPresetNames()
    local preset = names[1] or "retro_tv"
    local stack = lurek.effect.newPresetStack(preset, 320, 180)
    local count = stack:getEffectCount()
    effect_log("preset catalog size=" .. #names .. " sample=" .. preset .. " effects=" .. count)
end
```

---

### `lurek.effect.getShaderErrorDisplay`

Returns whether renderer shader error display overlays are enabled.

```lua
lurek.effect.getShaderErrorDisplay()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when shader error display is enabled. |

**Example**

```lua
do
    local on = lurek.effect.getShaderErrorDisplay()
    local stack = lurek.effect.newStack(320, 180)
    stack:add(lurek.effect.newEffect("bloom"))
    local count = stack:getEffectCount()
    effect_log("shader overlay=" .. tostring(on) .. " stack effects=" .. count)
end
```

---

### `lurek.effect.newCustomEffect`

Creates a custom post-processing effect that references an existing shader id.

```lua
lurek.effect.newCustomEffect(shader_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `shader_id` | number | Renderer shader identifier used for the custom effect. |

**Returns**

| Type | Description |
|------|-------------|
| [LPostFxEffect](#lpostfxeffect) | New custom post-processing effect handle. |

**Example**

```lua
do
    local fx = lurek.effect.newCustomEffect(1)
    fx:setParameter("distortion", 0.15)
    fx:disableAutoUniforms()
    local enabled = fx:isEnabled()
    effect_log("custom pass built_in=" .. tostring(fx:isBuiltIn()) .. " enabled=" .. tostring(enabled))
end
```

---

### `lurek.effect.newEffect`

Creates a built-in post-processing effect by type name.

```lua
lurek.effect.newEffect(type_name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_name` | string | Built-in effect type name such as `blur`, `bloom`, or `crt`. |

**Returns**

| Type | Description |
|------|-------------|
| [LPostFxEffect](#lpostfxeffect) | New post-processing effect handle. |

**Example**

```lua
do
    local fx = lurek.effect.newEffect("bloom")
    fx:setThreshold(0.65)
    fx:setIntensity(1.8)
    local effect_type = fx:getType()
    effect_log("cinematic " .. effect_type .. " built_in=" .. tostring(fx:isBuiltIn()))
end
```

---

### `lurek.effect.newImageEffect`

Creates an image effect chain from no arguments, a type name and optional parameters, or a chain table.

```lua
lurek.effect.newImageEffect(spec, params)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `spec?` | LuaValue | Optional effect type string, or an array table of effect entries, or nil for an empty chain. |
| `params?` | table | Optional parameter table used when `spec` is an effect type string. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageEffect](#limageeffect) | New image effect chain handle. |

**Example**

```lua
do
    local ie = lurek.effect.newImageEffect()
    ie:addEffect("bloom")
    ie:addEffect("blur")
    local count = ie:getEffectCount()
    effect_log("thumbnail chain effects=" .. count)
end
```

---

### `lurek.effect.newPass`

Creates a custom post-processing pass from an existing shader id.

```lua
lurek.effect.newPass(shader_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `shader_id` | number | Renderer shader identifier used for the pass. |

**Returns**

| Type | Description |
|------|-------------|
| [LPostFxEffect](#lpostfxeffect) | New custom post-processing effect handle. |

**Example**

```lua
do
    local fx = lurek.effect.newPass(2)
    fx:setParameter("exposure", 1.1)
    fx:enableAutoUniforms()
    local type_name = fx:getType()
    effect_log("custom pass type=" .. type_name .. " auto_uniforms=" .. tostring(fx:isAutoUniforms()))
end
```

---

### `lurek.effect.newPresetStack`

Creates a named preset post-processing stack with optional dimensions.

```lua
lurek.effect.newPresetStack(name, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Preset stack name. |
| `w?` | number | Stack width in pixels, defaulting to window width. |
| `h?` | number | Stack height in pixels, defaulting to window height. |

**Returns**

| Type | Description |
|------|-------------|
| [LPostFxStack](#lpostfxstack) | New preset post-processing stack handle. |

**Example**

```lua
do
    local stack = lurek.effect.newPresetStack("retro_tv", 320, 240)
    stack:setFeedback(0.2)
    local count = stack:getEffectCount()
    local w, h = stack:getDimensions()
    effect_log("retro preset effects=" .. count .. " size=" .. w .. "x" .. h)
end
```

---

### `lurek.effect.newStack`

Creates a post-processing stack using optional dimensions or the current window size.

```lua
lurek.effect.newStack(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w?` | number | Stack width in pixels, defaulting to window width. |
| `h?` | number | Stack height in pixels, defaulting to window height. |

**Returns**

| Type | Description |
|------|-------------|
| [LPostFxStack](#lpostfxstack) | New post-processing stack handle. |

**Example**

```lua
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:add(lurek.effect.newEffect("blur"))
    local w, h = stack:getDimensions()
    effect_log("combat stack " .. w .. "x" .. h .. " effects=" .. stack:getEffectCount())
end
```

---

### `lurek.effect.setShaderErrorDisplay`

Enables or disables renderer shader error display overlays.

```lua
lurek.effect.setShaderErrorDisplay(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | boolean | New shader error display flag. |

**Example**

```lua
do
    lurek.effect.setShaderErrorDisplay(true)
    local fx = lurek.effect.newEffect("blur")
    fx:setRadius(6.0)
    local shown = lurek.effect.getShaderErrorDisplay()
    effect_log("shader errors visible=" .. tostring(shown))
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

- [LImageEffect](#limageeffect)
- [LPostFxEffect](#lpostfxeffect)
- [LPostFxStack](#lpostfxstack)

## LImageEffect

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LImageEffect:addEffect`

Appends a built-in post-effect by type name to this image effect chain.

```lua
LImageEffect:addEffect(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Built-in effect type name. |

**Returns**

| Type | Description |
|------|-------------|
| [LPostFxEffect](#lpostfxeffect) | Handle for the effect added to the chain. |

**Example**

```lua
do
    local ie = lurek.effect.newImageEffect()
    local fx = ie:addEffect("bloom")
    ie:addEffect("blur")
    local count = ie:getEffectCount()
    effect_log("added effect=" .. fx:getType() .. " count=" .. count)
end
```

---

#### `LImageEffect:clear`

Removes every effect from this image effect chain.

```lua
LImageEffect:clear()
```

**Example**

```lua
do
    local ie = lurek.effect.newImageEffect()
    ie:addEffect("bloom")
    ie:clear()
    local count = ie:getEffectCount()
    local empty = ie:effectCount()
    effect_log("after clear count=" .. count .. " effectCount=" .. empty)
end
```

---

#### `LImageEffect:clearEffects`

Removes every effect from this image effect chain.

```lua
LImageEffect:clearEffects()
```

**Example**

```lua
do
    local ie = lurek.effect.newImageEffect()
    ie:addEffect("crt")
    ie:clearEffects()
    local count = ie:getEffectCount()
    local empty = ie:effectCount()
    effect_log("after clearEffects count=" .. count .. " effectCount=" .. empty)
end
```

---

#### `LImageEffect:clone`

Creates a new image effect chain with cloned effect entries.

```lua
LImageEffect:clone()
```

**Returns**

| Type | Description |
|------|-------------|
| [LImageEffect](#limageeffect) | New image effect handle with the same effect chain. |

**Example**

```lua
do
    local ie = lurek.effect.newImageEffect()
    ie:addEffect("bloom")
    local copy = ie:clone()
    copy:addEffect("blur")
    local count = copy:getEffectCount()
    effect_log("clone count=" .. count .. " source=" .. ie:getEffectCount())
end
```

---

#### `LImageEffect:effectCount`

Returns the number of effects in this image effect chain.

```lua
LImageEffect:effectCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Effect count. |

**Example**

```lua
do
    local ie = lurek.effect.newImageEffect()
    ie:addEffect("crt")
    ie:addEffect("bloom")
    local count = ie:effectCount()
    effect_log("effectCount=" .. count .. " cloneable=" .. tostring(ie:clone() ~= nil))
end
```

---

#### `LImageEffect:getEffect`

Looks up an image effect by one-based index or effect type name.

```lua
LImageEffect:getEffect(key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | Effect name string or one-based integer index. |

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | `[LPostFxEffect](#lpostfxeffect)` handle, or nil when no matching effect exists. |

**Example**

```lua
do
    local ie = lurek.effect.newImageEffect()
    ie:addEffect("blur")
    local fx = ie:getEffect("blur")
    ie:addEffect("bloom")
    local count = ie:getEffectCount()
    effect_log("found blur=" .. tostring(fx ~= nil) .. " count=" .. count)
end
```

---

#### `LImageEffect:getEffectCount`

Returns the number of effects in this image effect chain.

```lua
LImageEffect:getEffectCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Effect count. |

**Example**

```lua
do
    local ie = lurek.effect.newImageEffect()
    ie:addEffect("bloom")
    ie:addEffect("blur")
    local count = ie:getEffectCount()
    local first = ie:getEffect(1)
    effect_log("count=" .. count .. " first=" .. tostring(first and first:getType()))
end
```

---

#### `LImageEffect:removeByIndex`

Removes an image effect by zero-based internal index.

```lua
LImageEffect:removeByIndex(idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Zero-based effect index. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when an effect was removed. |

**Example**

```lua
do
    local ie = lurek.effect.newImageEffect()
    ie:addEffect("bloom")
    local ok = ie:removeByIndex(0)
    local count = ie:getEffectCount()
    effect_log("removeByIndex=" .. tostring(ok) .. " count=" .. count)
end
```

---

#### `LImageEffect:removeByName`

Removes the first image effect with a matching effect type name.

```lua
LImageEffect:removeByName(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Effect type name to remove. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when an effect was removed. |

**Example**

```lua
do
    local ie = lurek.effect.newImageEffect()
    ie:addEffect("blur")
    local ok = ie:removeByName("blur")
    local count = ie:getEffectCount()
    effect_log("removeByName=" .. tostring(ok) .. " count=" .. count)
end
```

---

#### `LImageEffect:removeEffect`

Removes an image effect by one-based index or effect type name.

```lua
LImageEffect:removeEffect(key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | Effect name string or one-based integer index. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when an effect was removed. |

**Example**

```lua
do
    local ie = lurek.effect.newImageEffect()
    ie:addEffect("bloom")
    local ok = ie:removeEffect("bloom")
    local count = ie:getEffectCount()
    effect_log("removed=" .. tostring(ok) .. " count=" .. count)
end
```

---

#### `LImageEffect:save`

Reports success for the current image effect save placeholder.

```lua
LImageEffect:save()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | Always true. |

**Example**

```lua
do
    local ie = lurek.effect.newImageEffect()
    ie:addEffect("bloom")
    ie:addEffect("crt")
    local ok = ie:save()
    local count = ie:getEffectCount()
    effect_log("save=" .. tostring(ok) .. " count=" .. count)
end
```

---

#### `LImageEffect:type`

Returns the Lua-visible type name for this image effect handle.

```lua
LImageEffect:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LImageEffect](#limageeffect)`. |

**Example**

```lua
do
    local ie = lurek.effect.newImageEffect()
    ie:addEffect("bloom")
    local type_name = ie:type()
    local is_object = ie:typeOf("LObject")
    effect_log(type_name .. " object=" .. tostring(is_object))
end
```

---

#### `LImageEffect:typeOf`

Returns whether this image effect handle matches a supported type name.

```lua
LImageEffect:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `ImageEffect` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local ie = lurek.effect.newImageEffect()
    ie:addEffect("bloom")
    local is_image_effect = ie:typeOf("LImageEffect")
    local type_name = ie:type()
    effect_log("is image effect=" .. tostring(is_image_effect) .. " type=" .. type_name)
end
```

---

## LPostFxEffect

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LPostFxEffect:disableAutoUniforms`

Disables automatic time and resolution uniforms for this effect.

```lua
LPostFxEffect:disableAutoUniforms()
```

**Example**

```lua
do
    local fx = lurek.effect.newEffect("bloom")
    fx:disableAutoUniforms()
    fx:setIntensity(1.4)
    local auto = fx:isAutoUniforms()
    effect_log("auto uniforms on=" .. tostring(auto))
end
```

---

#### `LPostFxEffect:enableAutoUniforms`

Enables automatic time and resolution uniforms for this effect.

```lua
LPostFxEffect:enableAutoUniforms()
```

**Example**

```lua
do
    local fx = lurek.effect.newEffect("bloom")
    fx:enableAutoUniforms()
    fx:setIntensity(1.4)
    local auto = fx:isAutoUniforms()
    effect_log("auto uniforms on=" .. tostring(auto))
end
```

---

#### `LPostFxEffect:getEffectType`

Returns the renderer effect type name.

```lua
LPostFxEffect:getEffectType()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Effect type name used by the renderer. |

**Example**

```lua
do
    local fx = lurek.effect.newEffect("bloom")
    fx:setThreshold(0.7)
    fx:setIntensity(1.6)
    local effect_type = fx:getEffectType()
    effect_log("effect type=" .. effect_type .. " owner=" .. fx:type())
end
```

---

#### `LPostFxEffect:getParameter`

Reads a numeric shader parameter and falls back to a default value when missing.

```lua
LPostFxEffect:getParameter(name, default)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Parameter name to read. |
| `default?` | number | Default value returned when the parameter is absent. |

**Returns**

| Type | Description |
|------|-------------|
| number | Stored parameter value or the supplied default. |

**Example**

```lua
do
    local fx = lurek.effect.newEffect("bloom")
    fx:setParameter("intensity", 1.5)
    local v = fx:getParameter("intensity", 1.0)
    fx:setEnabled(true)
    effect_log("intensity=" .. v .. " enabled=" .. tostring(fx:isEnabled()))
end
```

---

#### `LPostFxEffect:getParameterNames`

Returns the parameter names stored on this effect.

```lua
LPostFxEffect:getParameterNames()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Parameter name strings. |

**Example**

```lua
do
    local fx = lurek.effect.newEffect("bloom")
    fx:setParameter("threshold", 0.5)
    fx:setParameter("intensity", 1.3)
    local names = fx:getParameterNames()
    local first = names[1] or "none"
    effect_log("parameter names=" .. #names .. " first=" .. first)
end
```

---

#### `LPostFxEffect:getType`

Returns the renderer effect type name.

```lua
LPostFxEffect:getType()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Effect type name used by the renderer. |

**Example**

```lua
do
    local fx = lurek.effect.newEffect("blur")
    fx:setRadius(8.0)
    fx:setStrength(0.4)
    local effect_type = fx:getType()
    effect_log("pause blur type=" .. effect_type .. " owner=" .. fx:type())
end
```

---

#### `LPostFxEffect:getTypeName`

Returns the built-in or custom effect type name.

```lua
LPostFxEffect:getTypeName()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Effect type name used by the renderer. |

**Example**

```lua
do
    local fx = lurek.effect.newEffect("crt")
    fx:setScanlineStrength(0.35)
    fx:setOffset(0.002)
    local type_name = fx:getTypeName()
    effect_log("crt type name=" .. type_name .. " owner=" .. fx:type())
end
```

---

#### `LPostFxEffect:hasParameter`

Returns whether a shader parameter exists on this effect.

```lua
LPostFxEffect:hasParameter(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Parameter name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the parameter is present. |

**Example**

```lua
do
    local fx = lurek.effect.newEffect("blur")
    fx:setParameter("radius", 4)
    fx:setStrength(0.4)
    local has_radius = fx:hasParameter("radius")
    effect_log("has radius=" .. tostring(has_radius) .. " names=" .. #fx:getParameterNames())
end
```

---

#### `LPostFxEffect:isAutoUniforms`

Returns whether automatic uniforms are enabled for this effect.

```lua
LPostFxEffect:isAutoUniforms()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when automatic uniforms are enabled. |

**Example**

```lua
do
    local fx = lurek.effect.newEffect("bloom")
    fx:enableAutoUniforms()
    fx:setThreshold(0.7)
    local auto = fx:isAutoUniforms()
    effect_log("auto uniforms=" .. tostring(auto) .. " owner=" .. fx:type())
end
```

---

#### `LPostFxEffect:isBuiltIn`

Returns whether this effect uses one of the engine built-in effect types.

```lua
LPostFxEffect:isBuiltIn()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True for built-in effects, false for custom shader effects. |

**Example**

```lua
do
    local fx = lurek.effect.newEffect("blur")
    fx:setRadius(4.0)
    fx:setEnabled(true)
    local built_in = fx:isBuiltIn()
    effect_log("built_in=" .. tostring(built_in) .. " owner=" .. fx:type())
end
```

---

#### `LPostFxEffect:isEnabled`

Returns whether this effect is enabled on its owning effect object.

```lua
LPostFxEffect:isEnabled()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | Current enabled flag stored on the effect. |

**Example**

```lua
do
    local fx = lurek.effect.newEffect("bloom")
    fx:setIntensity(2.2)
    fx:setThreshold(0.6)
    local enabled = fx:isEnabled()
    effect_log("bloom enabled=" .. tostring(enabled) .. " owner=" .. fx:type())
end
```

---

#### `LPostFxEffect:setBrightness`

Sets the brightness shader parameter on this effect.

```lua
LPostFxEffect:setBrightness(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | Brightness value passed to the effect shader. |

**Example**

```lua
do
    local fx = lurek.effect.newEffect("bloom")
    fx:setBrightness(1.2)
    fx:setContrast(1.05)
    local brightness = fx:getParameter("brightness", 0.0)
    effect_log("grade brightness=" .. brightness)
end
```

---

#### `LPostFxEffect:setContrast`

Sets the contrast shader parameter on this effect.

```lua
LPostFxEffect:setContrast(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | Contrast value passed to the effect shader. |

**Example**

```lua
do
    local fx = lurek.effect.newEffect("bloom")
    fx:setContrast(1.1)
    fx:setBrightness(0.95)
    local contrast = fx:getParameter("contrast", 0.0)
    effect_log("grade contrast=" .. contrast)
end
```

---

#### `LPostFxEffect:setEnabled`

Enables or disables this effect. This method is available to Lua scripts.

```lua
LPostFxEffect:setEnabled(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | boolean | New enabled flag. |

**Example**

```lua
do
    local fx = lurek.effect.newEffect("bloom")
    fx:setEnabled(false)
    fx:setIntensity(2.0)
    local enabled = fx:isEnabled()
    effect_log("photo bloom enabled=" .. tostring(enabled))
end
```

---

#### `LPostFxEffect:setIntensity`

Sets the intensity shader parameter on this effect.

```lua
LPostFxEffect:setIntensity(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | Intensity value passed to the effect shader. |

**Example**

```lua
do
    local fx = lurek.effect.newEffect("bloom")
    fx:setIntensity(2.0)
    fx:setThreshold(0.6)
    local intensity = fx:getParameter("intensity", 0.0)
    effect_log("bloom intensity=" .. intensity)
end
```

---

#### `LPostFxEffect:setOffset`

Sets the offset shader parameter on this effect.

```lua
LPostFxEffect:setOffset(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | Offset value passed to the effect shader. |

**Example**

```lua
do
    local fx = lurek.effect.newEffect("crt")
    fx:setOffset(0.002)
    fx:setScanlineStrength(0.25)
    local offset = fx:getParameter("offset", 0.0)
    effect_log("crt offset=" .. offset)
end
```

---

#### `LPostFxEffect:setParameter`

Sets a numeric shader parameter by name.

```lua
LPostFxEffect:setParameter(name, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Parameter name expected by the effect shader. |
| `value` | number | Numeric parameter value. |

**Example**

```lua
do
    local fx = lurek.effect.newEffect("bloom")
    fx:setParameter("threshold", 0.8)
    fx:setParameter("intensity", 1.4)
    local threshold = fx:getParameter("threshold", 0.0)
    effect_log("custom threshold=" .. threshold)
end
```

---

#### `LPostFxEffect:setRadius`

Sets the radius shader parameter on this effect.

```lua
LPostFxEffect:setRadius(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | Radius value passed to the effect shader. |

**Example**

```lua
do
    local fx = lurek.effect.newEffect("blur")
    fx:setRadius(8)
    fx:setStrength(0.25)
    local radius = fx:getParameter("radius", 0.0)
    effect_log("blur radius=" .. radius)
end
```

---

#### `LPostFxEffect:setSaturation`

Sets the saturation shader parameter on this effect.

```lua
LPostFxEffect:setSaturation(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | Saturation value passed to the effect shader. |

**Example**

```lua
do
    local fx = lurek.effect.newEffect("bloom")
    fx:setSaturation(0.8)
    fx:setContrast(1.1)
    local saturation = fx:getParameter("saturation", 0.0)
    effect_log("grade saturation=" .. saturation)
end
```

---

#### `LPostFxEffect:setScanlineStrength`

Sets the scanline strength shader parameter on this effect.

```lua
LPostFxEffect:setScanlineStrength(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | Scanline strength value passed to the effect shader. |

**Example**

```lua
do
    local fx = lurek.effect.newEffect("crt")
    fx:setScanlineStrength(0.3)
    fx:setOffset(0.002)
    local scanline = fx:getParameter("scanline_strength", 0.0)
    effect_log("crt scanlines=" .. scanline)
end
```

---

#### `LPostFxEffect:setStrength`

Sets the strength shader parameter on this effect.

```lua
LPostFxEffect:setStrength(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | Strength value passed to the effect shader. |

**Example**

```lua
do
    local fx = lurek.effect.newEffect("blur")
    fx:setStrength(0.5)
    fx:setRadius(6.0)
    local strength = fx:getParameter("strength", 0.0)
    effect_log("blur strength=" .. strength)
end
```

---

#### `LPostFxEffect:setThreshold`

Sets the threshold shader parameter on this effect.

```lua
LPostFxEffect:setThreshold(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | Threshold value passed to the effect shader. |

**Example**

```lua
do
    local fx = lurek.effect.newEffect("bloom")
    fx:setThreshold(0.6)
    fx:setIntensity(1.7)
    local threshold = fx:getParameter("threshold", 0.0)
    effect_log("bloom threshold=" .. threshold)
end
```

---

#### `LPostFxEffect:type`

Returns the Lua-visible type name for this post-processing effect handle.

```lua
LPostFxEffect:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LPostFxEffect](#lpostfxeffect)`. |

**Example**

```lua
do
    local fx = lurek.effect.newEffect("blur")
    fx:setRadius(5.0)
    fx:setEnabled(true)
    local type_name = fx:type()
    effect_log(type_name .. " object=" .. tostring(fx:typeOf("LObject")))
end
```

---

#### `LPostFxEffect:typeOf`

Returns whether this effect handle matches a supported type name.

```lua
LPostFxEffect:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `PostFxEffect` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local fx = lurek.effect.newEffect("blur")
    fx:setRadius(5.0)
    fx:setStrength(0.4)
    local is_effect = fx:typeOf("LPostFxEffect")
    effect_log("is effect=" .. tostring(is_effect) .. " type=" .. fx:type())
end
```

---

## LPostFxStack

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LPostFxStack:add`

Appends an effect to the end of this stack.

```lua
LPostFxStack:add(effect_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `effect_ud` | [LPostFxEffect](#lpostfxeffect) | Effect handle to append. |

**Example**

```lua
do
    local stack = lurek.effect.newStack(800, 600)
    local fx = lurek.effect.newEffect("bloom")
    stack:add(fx)
    stack:add(lurek.effect.newEffect("blur"))
    local count = stack:getEffectCount()
    effect_log("stack count=" .. count)
end
```

---

#### `LPostFxStack:apply`

Queues this stack's enabled post-effect passes for renderer application.

```lua
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
    example_print_log("applied")
end
```

---

#### `LPostFxStack:beginCapture`

Starts post-effect capture and queues a renderer begin-capture command.

```lua
LPostFxStack:beginCapture()
```

**Example**

```lua
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:beginCapture()
    local capturing = stack:isCapturing()
    local count = stack:getEffectCount()
    effect_log("capture started=" .. tostring(capturing) .. " effects=" .. count)
end
```

---

#### `LPostFxStack:clear`

Removes all effects and pass state from this stack.

```lua
LPostFxStack:clear()
```

**Example**

```lua
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:clear()
    local count = stack:getEffectCount()
    local empty = stack:isEmpty()
    effect_log("after clear count=" .. count .. " empty=" .. tostring(empty))
end
```

---

#### `LPostFxStack:clearFeedback`

Resets the stack feedback blend factor to zero.

```lua
LPostFxStack:clearFeedback()
```

**Example**

```lua
do
    local stack = lurek.effect.newStack(800, 600)
    stack:setFeedback(0.8)
    stack:clearFeedback()
    local feedback = stack:getFeedback()
    local capturing = stack:isCapturing()
    effect_log("cleared feedback=" .. feedback .. " capturing=" .. tostring(capturing))
end
```

---

#### `LPostFxStack:dedup`

Removes duplicate effect handles while preserving first occurrences.

```lua
LPostFxStack:dedup()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Number of duplicate effects removed. |

**Example**

```lua
do
    local stack = lurek.effect.newStack(800, 600)
    local fx = lurek.effect.newEffect("bloom")
    stack:add(fx)
    stack:add(fx)
    local removed = stack:dedup()
    example_print_log("dedup removed = " .. removed)
end
```

---

#### `LPostFxStack:endCapture`

Ends post-effect capture and queues a renderer end-capture command.

```lua
LPostFxStack:endCapture()
```

**Example**

```lua
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:beginCapture()
    stack:endCapture()
    example_print_log("capture ended")
end
```

---

#### `LPostFxStack:getDimensions`

Returns the stack render dimensions.

```lua
LPostFxStack:getDimensions()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Stack width in pixels. |
| number | Stack height in pixels. |

**Example**

```lua
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("blur"))
    local w, h = stack:getDimensions()
    local count = stack:getEffectCount()
    effect_log("dims=" .. w .. "x" .. h .. " effects=" .. count)
end
```

---

#### `LPostFxStack:getEffect`

Returns the effect handle at a one-based position.

```lua
LPostFxStack:getEffect(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | One-based stack position. |

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | `[LPostFxEffect](#lpostfxeffect)` handle, or nil when the index is out of range. |

**Example**

```lua
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    local fx = stack:getEffect(1)
    local count = stack:getEffectCount()
    local kind = fx and fx:getType() or "none"
    effect_log("got effect=" .. kind .. " count=" .. count)
end
```

---

#### `LPostFxStack:getEffectCount`

Returns the number of effect handles in this stack.

```lua
LPostFxStack:getEffectCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Effect count. |

**Example**

```lua
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:add(lurek.effect.newEffect("blur"))
    local count = stack:getEffectCount()
    local enabled = #stack:getEnabledEffects()
    effect_log("effect count=" .. count .. " enabled=" .. enabled)
end
```

---

#### `LPostFxStack:getEnabledEffects`

Returns effect handles whose stack passes are enabled.

```lua
LPostFxStack:getEnabledEffects()
```

**Returns**

| Type | Description |
|------|-------------|
| [LPostFxEffect](#lpostfxeffect)[] | Enabled `[LPostFxEffect](#lpostfxeffect)` handles. |

**Example**

```lua
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:add(lurek.effect.newEffect("blur"))
    local enabled = stack:getEnabledEffects()
    example_print_log("enabled effects = " .. #enabled)
end
```

---

#### `LPostFxStack:getFeedback`

Returns the current stack feedback blend factor.

```lua
LPostFxStack:getFeedback()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Feedback blend factor in the range 0.0 through 1.0. |

**Example**

```lua
do
    local stack = lurek.effect.newStack(800, 600)
    stack:setFeedback(0.3)
    stack:add(lurek.effect.newEffect("crt"))
    local feedback = stack:getFeedback()
    effect_log("feedback=" .. feedback .. " width=" .. stack:getWidth())
end
```

---

#### `LPostFxStack:getHeight`

Returns the stack render height. This method is available to Lua scripts.

```lua
LPostFxStack:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Stack height in pixels. |

**Example**

```lua
do
    local stack = lurek.effect.newStack(1024, 768)
    stack:add(lurek.effect.newEffect("bloom"))
    local height = stack:getHeight()
    local count = stack:getEffectCount()
    effect_log("stack height=" .. height .. " effects=" .. count)
end
```

---

#### `LPostFxStack:getWidth`

Returns the stack render width. This method is available to Lua scripts.

```lua
LPostFxStack:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Stack width in pixels. |

**Example**

```lua
do
    local stack = lurek.effect.newStack(1024, 768)
    stack:add(lurek.effect.newEffect("bloom"))
    local width = stack:getWidth()
    local count = stack:getEffectCount()
    effect_log("stack width=" .. width .. " effects=" .. count)
end
```

---

#### `LPostFxStack:insert`

Inserts an effect at a one-based stack position.

```lua
LPostFxStack:insert(position, effect_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `position` | number | One-based insertion position, clamped to the stack length. |
| `effect_ud` | [LPostFxEffect](#lpostfxeffect) | Effect handle to insert. |

**Example**

```lua
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:insert(1, lurek.effect.newEffect("blur"))
    local first = stack:getEffect(1)
    local count = stack:getEffectCount()
    effect_log("after insert count=" .. count .. " first=" .. tostring(first and first:getType()))
end
```

---

#### `LPostFxStack:isCapturing`

Returns whether this stack is currently capturing draw commands.

```lua
LPostFxStack:isCapturing()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when capture mode is active. |

**Example**

```lua
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:setFeedback(0.15)
    local capturing = stack:isCapturing()
    effect_log("capturing=" .. tostring(capturing) .. " feedback=" .. stack:getFeedback())
end
```

---

#### `LPostFxStack:isEmpty`

Returns whether this stack has no effects.

```lua
LPostFxStack:isEmpty()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the stack has zero effects. |

**Example**

```lua
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    local empty = stack:isEmpty()
    local count = stack:getEffectCount()
    effect_log("empty=" .. tostring(empty) .. " count=" .. count)
end
```

---

#### `LPostFxStack:isEnabled`

Returns whether the effect pass at a one-based position is enabled.

```lua
LPostFxStack:isEnabled(position)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `position` | number | One-based stack position. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the pass is enabled; false for out-of-range positions. |

**Example**

```lua
do
    local stack = lurek.effect.newStack(800, 600)
    local fx = lurek.effect.newEffect("blur")
    stack:add(fx)
    fx:setEnabled(true)
    local enabled = stack:isEnabled(1)
    effect_log("pass enabled=" .. tostring(enabled) .. " count=" .. stack:getEffectCount())
end
```

---

#### `LPostFxStack:len`

Returns the number of effect handles in this stack.

```lua
LPostFxStack:len()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Effect count. |

**Example**

```lua
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:add(lurek.effect.newEffect("blur"))
    local len = stack:len()
    effect_log("len=" .. len .. " enabled=" .. #stack:getEnabledEffects())
end
```

---

#### `LPostFxStack:remove`

Removes the first matching effect handle from this stack.

```lua
LPostFxStack:remove(effect_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `effect_ud` | [LPostFxEffect](#lpostfxeffect) | Effect handle to remove. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the effect was found and removed. |

**Example**

```lua
do
    local stack = lurek.effect.newStack(800, 600)
    local fx = lurek.effect.newEffect("blur")
    stack:add(fx)
    local ok = stack:remove(fx)
    example_print_log("removed = " .. tostring(ok))
end
```

---

#### `LPostFxStack:resize`

Resizes the post-processing stack render target dimensions.

```lua
LPostFxStack:resize(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | number | New width in pixels. |
| `h` | number | New height in pixels. |

**Example**

```lua
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:resize(1920, 1080)
    local w, h = stack:getDimensions()
    effect_log("resized to " .. w .. "x" .. h)
end
```

---

#### `LPostFxStack:setEnabled`

Enables or disables the effect pass at a one-based stack position.

```lua
LPostFxStack:setEnabled(position, enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `position` | number | One-based stack position. |
| `enabled` | boolean | New enabled flag for the pass. |

**Example**

```lua
do
    local stack = lurek.effect.newStack(800, 600)
    local fx = lurek.effect.newEffect("bloom")
    stack:add(fx)
    stack:setEnabled(1, false)
    example_print_log("pass 1 enabled = " .. tostring(stack:isEnabled(1)))
end
```

---

#### `LPostFxStack:setFeedback`

Sets the stack feedback blend factor and clamps it to 0.0 through 1.0.

```lua
LPostFxStack:setFeedback(factor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `factor` | number | Feedback blend factor. |

**Example**

```lua
do
    local stack = lurek.effect.newStack(800, 600)
    stack:setFeedback(0.5)
    stack:add(lurek.effect.newEffect("crt"))
    local feedback = stack:getFeedback()
    effect_log("feedback=" .. feedback .. " effects=" .. stack:getEffectCount())
end
```

---

#### `LPostFxStack:type`

Returns the Lua-visible type name for this post-processing stack handle.

```lua
LPostFxStack:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LPostFxStack](#lpostfxstack)`. |

**Example**

```lua
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    local type_name = stack:type()
    local is_object = stack:typeOf("LObject")
    effect_log(type_name .. " object=" .. tostring(is_object))
end
```

---

#### `LPostFxStack:typeOf`

Returns whether this stack handle matches a supported type name.

```lua
LPostFxStack:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `PostFxStack` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    local is_stack = stack:typeOf("LPostFxStack")
    local type_name = stack:type()
    effect_log("is stack=" .. tostring(is_stack) .. " type=" .. type_name)
end
```

---
