# Effect

## Summary

The `effect` module manages visual post-effect composition data and lifecycle, including stack ordering, effect instances, presets, and conversion into render-command level apply/capture passes. It focuses on effect state orchestration rather than direct GPU execution.

Core responsibilities are partitioned across submodules: `effect` and `effect_type` define instance/state and built-in identifiers, `stack` manages ordered effect collections, `presets` supplies reusable configurations, `image_effect` groups image-scoped effect sets, and `render`/`draw` adapt effect state into command-level outputs consumed by the renderer.

A key architectural property is data-driven configuration. Effects are represented as configurable descriptors and parameter maps, enabling Lua and tooling workflows to compose visual pipelines without hardcoding render paths per effect.

The module should continue to own effect lifecycle and stack policy (including expiry/removal timing), while the renderer remains responsible for executing the generated commands on GPU resources.

Implementation detail and boundary guarantees for effect: this module keeps responsibilities explicit across source files so behavior remains inspectable during refactors. The current source map is: draw.rs: Render a preview image summarizing the current post-FX stack state.; effect.rs: Post-processing effect instance holding type, parameters, and enabled state.; effect_type.rs: Post-processing effect type enumeration and name registry.; image_effect.rs: Image-scoped post-processing effect pipeline that groups and orders shader passes.; mod.rs: Visual effect sub-system: particle effects, screen-space post-processing, and shakes.; presets.rs: Built-in post-processing effect presets (retro TV, horror, dream, neon, sepia).; render.rs: Render-command integration for the post-effects stack.; stack.rs: Ordered post-processing effect stack with per-entry enable flags.. This split is part of the contract: orchestration stays in composition points, data models stay in type-centric files, and adapters stay in bridge files. That separation reduces hidden coupling, improves testability, and keeps Lua API surfaces aligned with Rust runtime semantics. For maintainers, the key guarantee is that high-level APIs should keep delegating into scoped internals instead of collapsing into a single large entry point. Future extensions should preserve explicit dependency direction and documented invariants near owning types and functions.

## Spec File Descriptions

_Poniższe opisy plików pochodzą bezpośrednio ze specyfikacji modułu (`docs/specs/<module>.md`)._

### draw.rs

- Provides lightweight stack-preview rendering that converts effect activity into a quick diagnostic image.
- Distinguishes active and inactive stack states through deterministic color selection.
- Delivers a minimal visual probe for tooling and debug-side effect inspection.

### effect.rs

- Provides runtime post-effect instances that couple effect kind with mutable parameter state.
- Supports built-in and custom shader-backed variants under one unified runtime shape.
- Exposes parameter and enable controls for live effect tuning without pipeline rebuilds.
- Delivers the per-effect state object consumed by stack management and rendering stages.

### effect_type.rs

- Provides the canonical post-effect type catalog that defines all built-in processing identities.
- Maps stable Lua-facing names to typed variants for predictable script and engine interoperability.
- Supplies debug labels and parsing helpers that normalize user input into supported effect forms.
- Defines default parameter sets so each effect starts from consistent baseline behavior.
- Separates built-in variants from custom-shader paths while preserving one shared lookup model.
- Delivers the naming and typing backbone used by effect instances, stacks, and presets.

### image_effect.rs

- Provides image-scoped post-effect pipelines that group shared and owned effects into ordered pass chains.
- Supports add, remove, and lookup workflows so runtime code can manage effect sets incrementally.
- Converts active effects into renderer-facing pass descriptors for downstream execution.
- Delivers the per-target composition layer for reusable shader effect application.

### mod.rs

- Provides the high-level visual effects module boundary for post-processing composition and runtime control.
- Connects effect instances, stacks, presets, and renderer integration into one coherent pipeline surface.
- Delivers a data-driven effect orchestration layer that scripts and systems can configure predictably.

### presets.rs

- Provides built-in post-effect presets that package curated visual moods into ready-to-use chains.
- Builds effect sets with viewport-aware stack initialization for immediate runtime application.
- Exposes canonical preset names so scripts can select consistent looks with stable identifiers.
- Encapsulates preset assembly logic to keep stylistic recipes centralized and reusable.
- Delivers one-call factories that return enabled stacks configured for direct deployment.

### render.rs

- Provides render-command generation for post-effect capture and application flows.
- Emits deterministic begin, end, and apply command sequences consumed by the renderer.
- Delivers no-op behavior when stacks have no active effects to process.

### stack.rs

- Provides ordered post-effect stack management with per-entry enable state and target dimensions.
- Stores effect references in application order while preserving synchronized activation flags.
- Supports insertion, removal, reordering, and dedup operations for dynamic runtime composition.
- Exposes query helpers that report active subsets and positional stack metadata.
- Includes stack-introspection render helpers for debugging and visual tooling overlays.
- Applies defensive index handling so invalid operations fail safely at runtime boundaries.
- Delivers the sequencing core that determines how effect chains are executed frame to frame.

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
    print("available types = " .. #types)
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
    print("preset count = " .. #names)
    print("first preset = " .. tostring(names[1]))
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
    print("shader error display = " .. tostring(on))
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
| [LPostFxEffect](#lpostfxeffect-handle) | New custom post-processing effect handle. |

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
lurek.effect.newEffect(type_name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_name` | string | Built-in effect type name such as `blur`, `bloom`, or `crt`. |

**Returns**

| Type | Description |
|------|-------------|
| [LPostFxEffect](#lpostfxeffect-handle) | New post-processing effect handle. |

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
| [LImageEffect](#limageeffect-handle) | New image effect chain handle. |

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
lurek.effect.newPass(shader_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `shader_id` | number | Renderer shader identifier used for the pass. |

**Returns**

| Type | Description |
|------|-------------|
| [LPostFxEffect](#lpostfxeffect-handle) | New custom post-processing effect handle. |

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
| [LPostFxStack](#lpostfxstack-handle) | New preset post-processing stack handle. |

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
| [LPostFxStack](#lpostfxstack-handle) | New post-processing stack handle. |

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
    print("shader errors on")
end
```

---

## Module Fields

*No module-level fields documented.*

## Types

- [LImageEffect Handle](#limageeffect-handle)
- [LPostFxEffect Handle](#lpostfxeffect-handle)
- [LPostFxStack Handle](#lpostfxstack-handle)

## Callbacks

*No callback parameters documented in this module.*

## Enums

*No module-specific enums documented.*

## LImageEffect Handle

### Fields

*No documented fields for this handle.*

### Methods

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
| [LPostFxEffect](#lpostfxeffect-handle) | Handle for the effect added to the chain. |

**Example**

```lua
do
    local ie = lurek.effect.newImageEffect()
    local fx = ie:addEffect("bloom")
    print("added effect type = " .. fx:getType())
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
    print("after clear = " .. ie:getEffectCount())
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
    print("after clearEffects = " .. ie:getEffectCount())
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
| [LImageEffect](#limageeffect-handle) | New image effect handle with the same effect chain. |

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
    print("effectCount = " .. ie:effectCount())
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
| LuaValue | `[LPostFxEffect](#lpostfxeffect-handle)` handle, or nil when no matching effect exists. |

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
    print("count = " .. ie:getEffectCount())
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
    print("removeByIndex = " .. tostring(ok))
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
    print("removeByName = " .. tostring(ok))
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
    print("removed = " .. tostring(ok))
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
    local ok = ie:save()
    print("save = " .. tostring(ok))
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
| string | The string `[LImageEffect](#limageeffect-handle)`. |

**Example**

```lua
do
    local ie = lurek.effect.newImageEffect()
    print("type = " .. ie:type())
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
    print("is ImageEffect = " .. tostring(ie:typeOf("LImageEffect")))
end
```

---

## LPostFxEffect Handle

### Fields

*No documented fields for this handle.*

### Methods

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
    print("auto uniforms off = " .. tostring(fx:isAutoUniforms()))
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
    print("auto uniforms on = " .. tostring(fx:isAutoUniforms()))
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
    print("effectType = " .. fx:getEffectType())
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
    print("intensity = " .. v)
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
    local names = fx:getParameterNames()
    print("param names = " .. #names)
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
    print("type = " .. fx:getType())
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
    print("typeName = " .. fx:getTypeName())
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
    print("has radius = " .. tostring(fx:hasParameter("radius")))
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
    print("autoUniforms = " .. tostring(fx:isAutoUniforms()))
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
    print("builtIn = " .. tostring(fx:isBuiltIn()))
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
    print("enabled = " .. tostring(fx:isEnabled()))
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
    print("brightness set")
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
    print("contrast set")
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
    print("after disable = " .. tostring(fx:isEnabled()))
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
    print("intensity set")
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
    print("offset set")
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
    print("param set")
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
    print("radius set")
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
    print("saturation set")
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
    print("scanline set")
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
    print("strength set")
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
    print("threshold set")
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
| string | The string `[LPostFxEffect](#lpostfxeffect-handle)`. |

**Example**

```lua
do
    local fx = lurek.effect.newEffect("blur")
    print("type = " .. fx:type())
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
    print("is PostFxEffect = " .. tostring(fx:typeOf("LPostFxEffect")))
end
```

---

## LPostFxStack Handle

### Fields

*No documented fields for this handle.*

### Methods

#### `LPostFxStack:add`

Appends an effect to the end of this stack.

```lua
LPostFxStack:add(effect_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `effect_ud` | [LPostFxEffect](#lpostfxeffect-handle) | Effect handle to append. |

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
    print("applied")
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
    print("capture started")
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
    print("after clear = " .. stack:getEffectCount())
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
    print("cleared feedback = " .. stack:getFeedback())
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
    print("dedup removed = " .. removed)
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
    print("capture ended")
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
    local w, h = stack:getDimensions()
    print("dims = " .. w .. "x" .. h)
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
| LuaValue | `[LPostFxEffect](#lpostfxeffect-handle)` handle, or nil when the index is out of range. |

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
    print("effect count = " .. stack:getEffectCount())
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
| [LPostFxEffect](#lpostfxeffect-handle)[] | Enabled `[LPostFxEffect](#lpostfxeffect-handle)` handles. |

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
    print("feedback = " .. stack:getFeedback())
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
    print("height = " .. stack:getHeight())
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
    print("width = " .. stack:getWidth())
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
| `effect_ud` | [LPostFxEffect](#lpostfxeffect-handle) | Effect handle to insert. |

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
    print("capturing = " .. tostring(stack:isCapturing()))
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
    print("empty = " .. tostring(stack:isEmpty()))
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
    print("pass enabled = " .. tostring(stack:isEnabled(1)))
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
    print("len = " .. stack:len())
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
| `effect_ud` | [LPostFxEffect](#lpostfxeffect-handle) | Effect handle to remove. |

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
    print("removed = " .. tostring(ok))
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
    stack:resize(1920, 1080)
    print("resized w=" .. stack:getWidth())
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
    print("pass 1 enabled = " .. tostring(stack:isEnabled(1)))
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
    print("feedback = " .. stack:getFeedback())
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
| string | The string `[LPostFxStack](#lpostfxstack-handle)`. |

**Example**

```lua
do
    local stack = lurek.effect.newStack(800, 600)
    print("type = " .. stack:type())
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
    print("is PostFxStack = " .. tostring(stack:typeOf("LPostFxStack")))
end
```

---
