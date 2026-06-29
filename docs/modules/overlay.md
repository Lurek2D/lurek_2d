# Overlay

## Purpose

Manages screen-space weather, fog, camera shakes, and screen flashes. - Supports wave distortion and transition wipes. - Owns designer-authored status overlays that can stack color washes, fullscreen textures, and routed post-fx presets.

## Summary

- The `overlay` module is the engine's screen-layer presentation surface for users who want weather, atmosphere, transitions, and other scene-wide visual treatments to behave as one coherent system.
- It groups full-screen and near-full-screen effects that are too global to belong to an individual sprite but too specialized to live as loose render hacks.
- This matters for fog washes, rain veils, damage flashes, atmospheric tinting, transition masks, and similar treatments that need their own timing and configuration rules.
- Weather, ambient mood, distortion-style effects, and transition controllers all belong here because they usually evolve over time rather than acting like static post-process toggles.
- Status overlays also belong here when gameplay needs controllable danger or condition feedback such as frozen, poison, low-health, blindness, radiation, or burn states to fade, stack, and report diagnostics consistently.
- That temporal behavior is the key reason the module exists: these effects are often stateful and orchestrated, not just one-frame visual filters.
- The same subsystem can therefore own persistent environmental treatment and short-lived screen transitions without burying either concern inside unrelated render code.
- Layer-wide control is important because these treatments often need coordinated fade-in, fade-out, stacking, and override rules when several moods or transitions compete for the screen at once.
- The module is useful whenever a project needs stronger screen-space presentation than a local sprite effect but does not need a full scene rewrite.
- `render` still draws the final image, but `overlay` owns the grouping, configuration, temporal behavior, accessibility policy, and diagnostics for these large-scale scene treatments.
- Read `overlay` as the orchestration layer for scene-wide atmospheric and transitional effects.

This module primarily collaborates with `color`, `image`, `render`, `runtime`. Its responsibility should stay inside the `Edge/Integration` group rather than absorb behavior owned by those neighbors.

## API Reference

- This page is the generated API reference for this module.

## Functions

### `lurek.overlay.new`

Creates an overlay controller for screen effects using optional dimensions.

```lua
lurek.overlay.new(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w?` | number | Overlay width in pixels, defaulting to 800. |
| `h?` | number | Overlay height in pixels, defaulting to 600. |

**Returns**

| Type | Description |
|------|-------------|
| [LOverlay](#loverlay) | New overlay handle. |

**Example**

```lua
do

    local ov = lurek.overlay.new(800, 600)
    local w, h = ov:getDimensions()
    lurek.log.info("new type=" .. ov:type())
    lurek.log.info("new size=" .. w .. "x" .. h)
    lurek.log.info("new width=" .. ov:getWidth())
    lurek.log.info("new height=" .. ov:getHeight())
end
```

---

### `lurek.overlay.newTransition`

Creates a timed screen transition with optional kind, duration, and color.

```lua
lurek.overlay.newTransition(kind, duration, color_tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `kind?` | string | Transition kind name, defaulting to `fade`. |
| `duration?` | number | Duration in seconds, defaulting to 1.0. |
| `color_tbl?` | table | Numeric RGBA table using indices 1 through 4. |

**Returns**

| Type | Description |
|------|-------------|
| [LScreenTransition](#lscreentransition) | New screen transition handle. |

**Example**

```lua
do

    local tr = lurek.overlay.newTransition("wipe", 0.75, { 0.05, 0.10, 0.15, 1.0 })
    local r, g, b, a = tr:color()
    lurek.log.info("newTransition type=" .. tr:type())
    lurek.log.info("newTransition kind=" .. tr:kind())
    lurek.log.info("newTransition active=" .. tostring(tr:isActive()))
    lurek.log.info("newTransition color=" .. string.format("%.2f,%.2f,%.2f,%.2f", r, g, b, a))
end
```

---

## Module Fields

*No module-level fields documented.*

## Enums

*No module-specific enums documented.*

## Types

- [LOverlay](#loverlay)
- [LScreenTransition](#lscreentransition)

## LOverlay

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LOverlay:clear`

Clears active overlay effects and resets transient state.

```lua
LOverlay:clear()
```

**Example**

```lua
do

    local ov = lurek.overlay.new(800, 600)
    ov:triggerFlash(1, 1, 1, 0.5, 0.1)
    lurek.log.info("LOverlay:clear before=" .. tostring(ov:isActive()))
    ov:clear()
    lurek.log.info("LOverlay:clear after=" .. tostring(ov:isActive()))
end
```

---

#### `LOverlay:clearStatusEffect`

Starts fading out one status layer.

```lua
LOverlay:clearStatusEffect(kind, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `kind` | string | Status kind or layer id. |
| `opts?` | table | Optional fade-out override table. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setStatusEffect("poison", { intensity = 5.0, fadeIn = 0.01 })
    ov:update(0.05)
    ov:clearStatusEffect("poison", { fadeOut = 0.01 })
    ov:update(0.05)
    lurek.log.info("[overlay.example] poison removed=" .. tostring(ov:getStatusEffect("poison") == nil))
end
```

---

#### `LOverlay:drawToImage`

Renders overlay state into an image object of the requested size.

```lua
LOverlay:drawToImage(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | number | Target image width in pixels. |
| `h` | number | Target image height in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| [LImage](render.md#limage) | Image containing the overlay draw state. |

**Example**

```lua
do

    local ov = lurek.overlay.new(200, 150)
    ov:flash(0.9, 0.95, 1.0, 0.6, 0.2)
    local img = ov:drawToImage(200, 150)
    lurek.log.info("LOverlay:drawToImage type=" .. type(img))
    lurek.log.info("LOverlay:drawToImage active=" .. tostring(ov:isActive()))
end
```

---

#### `LOverlay:fade`

Starts a fade overlay with optional alpha and duration.

```lua
LOverlay:fade(r, g, b, a, dur)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a?` | number | Target alpha, defaulting to 1.0. |
| `dur?` | number | Duration in seconds, defaulting to 1.0. |

**Example**

```lua
do

    local ov = lurek.overlay.new(800, 600)
    ov:fade(0.05, 0.05, 0.10, 0.85, 0.5)
    ov:update(0.1)
    lurek.log.info("fade isFading=" .. tostring(ov:isFading()))
    lurek.log.info("fade active=" .. tostring(ov:isActive()))
    lurek.log.info("fade flashAlpha=" .. string.format("%.2f", ov:getFlashAlpha()))
    lurek.log.info("fade dimensions=" .. ov:getWidth() .. "x" .. ov:getHeight())
end
```

---

#### `LOverlay:flash`

Starts a short flash overlay with optional alpha and duration.

```lua
LOverlay:flash(r, g, b, a, dur)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a?` | number | Alpha channel, defaulting to 1.0. |
| `dur?` | number | Duration in seconds, defaulting to 0.2. |

**Example**

```lua
do


    local ov = lurek.overlay.new(800, 600)
    ov:flash(1.0, 0.95, 0.70, 0.8, 0.2)
    lurek.log.info("LOverlay:flash isFlashing=" .. tostring(ov:isFlashing()))
    lurek.log.info("LOverlay:flash alpha=" .. string.format("%.2f", ov:getFlashAlpha()))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end
```

---

#### `LOverlay:getAccessibilityPolicy`

Returns the current overlay accessibility policy.

```lua
LOverlay:getAccessibilityPolicy()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Policy table with reduced motion, flash, shake, lightning, and grain controls. |

**Example**

```lua
do

    local ov = lurek.overlay.new(800, 600)
    ov:setAccessibilityPolicy({
        max_flash_alpha = 0.3,
        disable_lightning = true,
        disable_film_grain = true,
    })
    local policy = ov:getAccessibilityPolicy()
    lurek.log.info("policy flash alpha=" .. string.format("%.2f", policy.max_flash_alpha))
    lurek.log.info("policy disable lightning=" .. tostring(policy.disable_lightning))
    lurek.log.info("policy disable grain=" .. tostring(policy.disable_film_grain))
end
```

---

#### `LOverlay:getAmbientColor`

Returns overlay ambient RGBA color.

```lua
LOverlay:getAmbientColor()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Red channel. |
| number | Green channel. |
| number | Blue channel. |
| number | Alpha channel. |

**Example**

```lua
do


    local ov = lurek.overlay.new(800, 600)
    ov:setAmbientColor(0.2, 0.1, 0.3, 0.5)
    local r, g, b, a = ov:getAmbientColor()
    lurek.log.info("LOverlay:getAmbientColor=" .. string.format("%.2f,%.2f,%.2f,%.2f", r, g, b, a))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end
```

---

#### `LOverlay:getCloudCount`

Returns the overlay cloud shadow count.

```lua
LOverlay:getCloudCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Cloud shadow count. |

**Example**

```lua
do

    local ov = lurek.overlay.new(800, 600)
    ov:setCloudCount(8)
    ov:setCloudShadows(true)
    lurek.log.info("getCloudCount count=" .. ov:getCloudCount())
    lurek.log.info("getCloudCount enabled=" .. tostring(ov:isCloudShadowsEnabled()))
    lurek.log.info("getCloudCount width=" .. ov:getWidth())
    lurek.log.info("getCloudCount height=" .. ov:getHeight())
end
```

---

#### `LOverlay:getCloudOpacity`

Returns cloud shadow opacity. This method is available to Lua scripts.

```lua
LOverlay:getCloudOpacity()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Cloud opacity value. |

**Example**

```lua
do


    local ov = lurek.overlay.new(800, 600)
    ov:setCloudOpacity(0.7)
    lurek.log.info("LOverlay:getCloudOpacity=" .. string.format("%.2f", ov:getCloudOpacity()))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end
```

---

#### `LOverlay:getCloudScale`

Returns cloud shadow scale. This method is available to Lua scripts.

```lua
LOverlay:getCloudScale()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Cloud scale value. |

**Example**

```lua
do


    local ov = lurek.overlay.new(800, 600)
    ov:setCloudScale(1.5)
    lurek.log.info("LOverlay:getCloudScale=" .. string.format("%.2f", ov:getCloudScale()))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end
```

---

#### `LOverlay:getCloudSpeed`

Returns cloud shadow movement speed.

```lua
LOverlay:getCloudSpeed()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Cloud speed value. |

**Example**

```lua
do


    local ov = lurek.overlay.new(800, 600)
    ov:setCloudSpeed(0.3)
    lurek.log.info("LOverlay:getCloudSpeed=" .. string.format("%.2f", ov:getCloudSpeed()))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end
```

---

#### `LOverlay:getDimensions`

Returns the overlay dimensions. This method is available to Lua scripts.

```lua
LOverlay:getDimensions()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Overlay width in pixels. |
| number | Overlay height in pixels. |

**Example**

```lua
do

    local ov = lurek.overlay.new(800, 600)
    local w, h = ov:getDimensions()
    lurek.log.info("getDimensions=" .. w .. "x" .. h)
    lurek.log.info("getDimensions width=" .. ov:getWidth())
    lurek.log.info("getDimensions height=" .. ov:getHeight())
    lurek.log.info("getDimensions active=" .. tostring(ov:isActive()))
end
```

---

#### `LOverlay:getFilmGrainIntensity`

Returns overlay film grain intensity.

```lua
LOverlay:getFilmGrainIntensity()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current film grain intensity. |

**Example**

```lua
do


    local ov = lurek.overlay.new(800, 600)
    ov:setFilmGrainIntensity(0.4)
    lurek.log.info("LOverlay:getFilmGrainIntensity=" .. string.format("%.2f", ov:getFilmGrainIntensity()))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end
```

---

#### `LOverlay:getFlashAlpha`

Returns the current flash alpha. This method is available to Lua scripts.

```lua
LOverlay:getFlashAlpha()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Flash alpha value. |

**Example**

```lua
do


    local ov = lurek.overlay.new(800, 600)
    ov:flash(1, 1, 0, 1.0, 0.5)
    lurek.log.info("LOverlay:getFlashAlpha=" .. string.format("%.2f", ov:getFlashAlpha()))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end
```

---

#### `LOverlay:getFogColor`

Returns overlay fog RGBA color. This method is available to Lua scripts.

```lua
LOverlay:getFogColor()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Red channel. |
| number | Green channel. |
| number | Blue channel. |
| number | Alpha channel. |

**Example**

```lua
do


    local ov = lurek.overlay.new(800, 600)
    ov:setFogColor(0.5, 0.5, 0.5, 0.8)
    local r, g, b, a = ov:getFogColor()
    lurek.log.info("LOverlay:getFogColor=" .. string.format("%.2f,%.2f,%.2f,%.2f", r, g, b, a))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end
```

---

#### `LOverlay:getFogDensity`

Returns overlay fog density. This method is available to Lua scripts.

```lua
LOverlay:getFogDensity()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current fog density. |

**Example**

```lua
do


    local ov = lurek.overlay.new(800, 600)
    ov:setFogDensity(0.6)
    lurek.log.info("LOverlay:getFogDensity=" .. string.format("%.2f", ov:getFogDensity()))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end
```

---

#### `LOverlay:getHeatHazeIntensity`

Returns overlay heat haze intensity.

```lua
LOverlay:getHeatHazeIntensity()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current heat haze intensity. |

**Example**

```lua
do


    local ov = lurek.overlay.new(800, 600)
    ov:setHeatHazeIntensity(0.4)
    lurek.log.info("LOverlay:getHeatHazeIntensity=" .. string.format("%.2f", ov:getHeatHazeIntensity()))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end
```

---

#### `LOverlay:getHeight`

Returns the overlay height. This method is available to Lua scripts.

```lua
LOverlay:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Overlay height in pixels. |

**Example**

```lua
do

    local ov = lurek.overlay.new(800, 600)
    local w, h = ov:getDimensions()
    lurek.log.info("getHeight=" .. ov:getHeight())
    lurek.log.info("dimensions=" .. w .. "x" .. h)
    lurek.log.info("width getter=" .. ov:getWidth())
    lurek.log.info("type=" .. ov:type())
end
```

---

#### `LOverlay:getLightningAlpha`

Returns the current lightning alpha.

```lua
LOverlay:getLightningAlpha()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Lightning alpha value. |

**Example**

```lua
do


    local ov = lurek.overlay.new(800, 600)
    ov:triggerLightning()
    lurek.log.info("LOverlay:getLightningAlpha=" .. string.format("%.2f", ov:getLightningAlpha()))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end
```

---

#### `LOverlay:getLightningColor`

Returns overlay lightning RGBA color.

```lua
LOverlay:getLightningColor()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Red channel. |
| number | Green channel. |
| number | Blue channel. |
| number | Alpha channel. |

**Example**

```lua
do


    local ov = lurek.overlay.new(800, 600)
    ov:setLightningColor(0.9, 0.9, 1.0, 1.0)
    local r, g, b, a = ov:getLightningColor()
    lurek.log.info("LOverlay:getLightningColor=" .. string.format("%.2f,%.2f,%.2f,%.2f", r, g, b, a))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end
```

---

#### `LOverlay:getRenderPlan`

Returns the current render responsibility plan for active overlay layers.

```lua
LOverlay:getRenderPlan()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Table with `rendered`, `externally_handled`, `unsupported`, `fallback`, and `shader` string arrays. |

**Example**

```lua
do

    local ov = lurek.overlay.new(800, 600)
    ov:setFogEnabled(true)
    ov:setWater(0.2, 1.0, 0.5)
    ov:setCloudShadows(true)
    ov:setFilmGrainEnabled(true)
    local plan = ov:getRenderPlan()
    lurek.log.info("rendered layers=" .. tostring(#plan.rendered))
    lurek.log.info("external layers=" .. tostring(#plan.externally_handled))
    lurek.log.info("first external=" .. tostring(plan.externally_handled[1]))
end
```

---

#### `LOverlay:getShader`

Returns the shader bound to this overlay, if any.

```lua
LOverlay:getShader()
```

**Returns**

| Type | Description |
|------|-------------|
| [LShader](render.md#lshader)? | Bound shader or nil. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    local shader = lurek.render.newShader("@fragment fn fs(@location(0) color: vec4<f32>) -> @location(0) vec4<f32> { return color; }", { target = "overlay" })
    ov:setShader(shader)
    local active = ov:getShader()
    local target = active and active:getTarget() or "nil"
    ov:setShader(nil)
    lurek.log.info("[overlay.example] shader target=" .. target)
end
```

---

#### `LOverlay:getShaderLayer`

Returns a shader bound to one overlay layer, if present.

```lua
LOverlay:getShaderLayer(layer)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | string | Layer name. |

**Returns**

| Type | Description |
|------|-------------|
| [LShader](render.md#lshader)? | Bound shader or nil. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    local shader = lurek.render.newShader("@fragment fn fs(@location(0) color: vec4<f32>) -> @location(0) vec4<f32> { return color; }", { target = "overlay" })
    ov:setShaderLayer("heat_haze", shader)
    local active = ov:getShaderLayer("heat_haze")
    local target = active and active:getTarget() or "nil"
    ov:setShaderLayer("heat_haze", nil)
    lurek.log.info("[overlay.example] heat_haze target=" .. target)
end
```

---

#### `LOverlay:getShakeOffset`

Returns the current screen shake offset.

```lua
LOverlay:getShakeOffset()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current x offset. |
| number | Current y offset. |

**Example**

```lua
do


    local ov = lurek.overlay.new(800, 600)
    ov:shake(5.0, 0.3)
    local ox, oy = ov:getShakeOffset()
    lurek.log.info("LOverlay:getShakeOffset=" .. string.format("%.2f,%.2f", ox, oy))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end
```

---

#### `LOverlay:getStats`

Returns a telemetry snapshot for dashboard and debug workflows.

```lua
LOverlay:getStats()
```

**Returns**

| Type | Description |
|------|-------------|
| LOverlayGetStatsResult | Overlay telemetry fields. |

**Example**

```lua
do

    local ov = lurek.overlay.new(800, 600)
    ov:setWeatherEnabled(true)
    ov:setWeather("rain")
    ov:setWeatherIntensity(0.6)
    ov:triggerFlash(1.0, 1.0, 1.0, 0.7, 0.2)
    local stats = ov:getStats()
    lurek.log.info("overlay stats size=" .. stats.width .. "x" .. stats.height)
    lurek.log.info("overlay stats effects=" .. stats.active_effects .. " weather=" .. tostring(stats.weather_enabled))
end
```

---

#### `LOverlay:getStatusEffect`

Returns one status layer table or nil.

```lua
LOverlay:getStatusEffect(kind)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `kind` | string | Status kind or layer id. |

**Returns**

| Type | Description |
|------|-------------|
| table? | Layer table when present. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setStatusEffect("burning", { intensity = 6.0, fadeIn = 0.01 })
    ov:update(0.05)
    local layer = ov:getStatusEffect("burning")
    lurek.log.info("[overlay.example] burning shader=" .. tostring(layer.shader))
end
```

---

#### `LOverlay:getStatusEffects`

Returns all current status layers sorted by priority.

```lua
LOverlay:getStatusEffects()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Array of status layer tables. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setStatusEffect("lowhealth", { intensity = 3.0, priority = 0, fadeIn = 0.01 })
    ov:setStatusEffect("burning", { intensity = 5.0, priority = 5, fadeIn = 0.01 })
    ov:update(0.05)
    local layers = ov:getStatusEffects()
    lurek.log.info("[overlay.example] status count=" .. tostring(#layers))
    lurek.log.info("[overlay.example] front layer=" .. tostring(layers[#layers] and layers[#layers].id or "nil"))
end
```

---

#### `LOverlay:getTimeOfDay`

Returns the overlay time-of-day value.

```lua
LOverlay:getTimeOfDay()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current time-of-day value. |

**Example**

```lua
do

    local ov = lurek.overlay.new(800, 600)
    ov:setTimeOfDay(0.75)
    ov:setAmbientEnabled(true)
    local r, g, b, a = ov:getAmbientColor()
    lurek.log.info("getTimeOfDay=" .. ov:getTimeOfDay())
    lurek.log.info("ambient enabled=" .. tostring(ov:isAmbientEnabled()))
    lurek.log.info("ambient color=" .. string.format("%.2f,%.2f,%.2f,%.2f", r, g, b, a))
    lurek.log.info("active=" .. tostring(ov:isActive()))
end
```

---

#### `LOverlay:getVignetteStrength`

Returns overlay vignette strength.

```lua
LOverlay:getVignetteStrength()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current vignette strength. |

**Example**

```lua
do


    local ov = lurek.overlay.new(800, 600)
    ov:setVignetteStrength(0.6)
    lurek.log.info("LOverlay:getVignetteStrength=" .. string.format("%.2f", ov:getVignetteStrength()))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end
```

---

#### `LOverlay:getWater`

Returns a table describing the current water effect settings.

```lua
LOverlay:getWater()
```

**Returns**

| Type | Description |
|------|-------------|
| LOverlayGetWaterResult | Water state table with enabled, wave, tint, depth, and time fields. |

**Example**

```lua
do


    local ov = lurek.overlay.new(800, 600)
    ov:setWater(0.20, 1.10, 0.35)
    local w = ov:getWater()
    lurek.log.info("LOverlay:getWater enabled=" .. tostring(w.enabled))
    lurek.log.info("LOverlay:getWater wave=" .. string.format("%.2f", w.amplitude) .. "," .. string.format("%.2f", w.frequency) .. "," .. string.format("%.2f", w.speed))
end
```

---

#### `LOverlay:getWeather`

Returns the overlay weather type name.

```lua
LOverlay:getWeather()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Current weather type name. |

**Example**

```lua
do

    local ov = lurek.overlay.new(800, 600)
    ov:setWeather("rain")
    ov:setWeatherEnabled(true)
    ov:setWeatherIntensity(0.6)
    lurek.log.info("getWeather=" .. ov:getWeather())
    lurek.log.info("weather enabled=" .. tostring(ov:isWeatherEnabled()))
    lurek.log.info("weather intensity=" .. string.format("%.2f", ov:getWeatherIntensity()))
    lurek.log.info("wind speed=" .. string.format("%.2f", ov:getWindSpeed()))
end
```

---

#### `LOverlay:getWeatherIntensity`

Returns weather intensity for the current weather type.

```lua
LOverlay:getWeatherIntensity()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Weather intensity value. |

**Example**

```lua
do


    local ov = lurek.overlay.new(800, 600)
    ov:setWeatherIntensity(0.7)
    lurek.log.info("LOverlay:getWeatherIntensity=" .. string.format("%.2f", ov:getWeatherIntensity()))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end
```

---

#### `LOverlay:getWeatherRngState`

Returns the current deterministic overlay weather RNG state.

```lua
LOverlay:getWeatherRngState()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current weather RNG state. |

**Example**

```lua
do

    local ov = lurek.overlay.new(800, 600)
    ov:setWeatherSeed(246813579)
    local state = ov:getWeatherRngState()
    lurek.log.info("weather rng state=" .. tostring(state))
    lurek.log.info("weather type=" .. tostring(ov:getWeather()))
end
```

---

#### `LOverlay:getWidth`

Returns the overlay width. This method is available to Lua scripts.

```lua
LOverlay:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Overlay width in pixels. |

**Example**

```lua
do

    local ov = lurek.overlay.new(800, 600)
    local w, h = ov:getDimensions()
    lurek.log.info("getWidth=" .. ov:getWidth())
    lurek.log.info("dimensions=" .. w .. "x" .. h)
    lurek.log.info("height getter=" .. ov:getHeight())
    lurek.log.info("type=" .. ov:type())
end
```

---

#### `LOverlay:getWindDirection`

Returns the overlay weather wind direction.

```lua
LOverlay:getWindDirection()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Wind direction value. |

**Example**

```lua
do


    local ov = lurek.overlay.new(800, 600)
    ov:setWindDirection(0.79)
    lurek.log.info("LOverlay:getWindDirection=" .. string.format("%.2f", ov:getWindDirection()))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end
```

---

#### `LOverlay:getWindSpeed`

Returns the overlay weather wind speed.

```lua
LOverlay:getWindSpeed()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Wind speed value. |

**Example**

```lua
do


    local ov = lurek.overlay.new(800, 600)
    ov:setWindSpeed(12.0)
    lurek.log.info("LOverlay:getWindSpeed=" .. string.format("%.2f", ov:getWindSpeed()))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end
```

---

#### `LOverlay:isActive`

Returns whether any overlay effect is currently active.

```lua
LOverlay:isActive()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when overlay state should render. |

**Example**

```lua
do

    local ov = lurek.overlay.new(800, 600)
    ov:triggerFlash(1, 1, 1, 0.5, 0.3)
    lurek.log.info("isActive after flash=" .. tostring(ov:isActive()))
    lurek.log.info("isFlashing=" .. tostring(ov:isFlashing()))
    lurek.log.info("flashAlpha=" .. string.format("%.2f", ov:getFlashAlpha()))
    lurek.log.info("isFading=" .. tostring(ov:isFading()))
end
```

---

#### `LOverlay:isAmbientEnabled`

Returns whether overlay ambient color rendering is enabled.

```lua
LOverlay:isAmbientEnabled()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when ambient rendering is enabled. |

**Example**

```lua
do

    local ov = lurek.overlay.new(800, 600)
    ov:setAmbientEnabled(true)
    local r, g, b, a = ov:getAmbientColor()
    lurek.log.info("isAmbientEnabled=" .. tostring(ov:isAmbientEnabled()))
    lurek.log.info("ambient color=" .. string.format("%.2f,%.2f,%.2f,%.2f", r, g, b, a))
    lurek.log.info("width=" .. ov:getWidth())
    lurek.log.info("height=" .. ov:getHeight())
end
```

---

#### `LOverlay:isCloudShadowsEnabled`

Returns whether overlay cloud shadow rendering is enabled.

```lua
LOverlay:isCloudShadowsEnabled()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when cloud shadow rendering is enabled. |

**Example**

```lua
do

    local ov = lurek.overlay.new(800, 600)
    ov:setCloudShadows(true)
    ov:setCloudCount(6)
    lurek.log.info("isCloudShadowsEnabled=" .. tostring(ov:isCloudShadowsEnabled()))
    lurek.log.info("cloud count=" .. ov:getCloudCount())
    lurek.log.info("cloud scale=" .. string.format("%.2f", ov:getCloudScale()))
    lurek.log.info("cloud speed=" .. string.format("%.2f", ov:getCloudSpeed()))
end
```

---

#### `LOverlay:isFading`

Returns whether the fade overlay is active.

```lua
LOverlay:isFading()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True while fade is active. |

**Example**

```lua
do

    local ov = lurek.overlay.new(800, 600)
    ov:triggerFade(0.0, 0.0, 0.0, 1.0, 0.4)
    ov:update(0.1)
    lurek.log.info("isFading=" .. tostring(ov:isFading()))
    lurek.log.info("isActive=" .. tostring(ov:isActive()))
    lurek.log.info("flashAlpha=" .. string.format("%.2f", ov:getFlashAlpha()))
    lurek.log.info("isFlashing=" .. tostring(ov:isFlashing()))
end
```

---

#### `LOverlay:isFilmGrainEnabled`

Returns whether overlay film grain rendering is enabled.

```lua
LOverlay:isFilmGrainEnabled()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when film grain rendering is enabled. |

**Example**

```lua
do

    local ov = lurek.overlay.new(800, 600)
    ov:setFilmGrainEnabled(true)
    ov:setFilmGrainIntensity(0.35)
    lurek.log.info("isFilmGrainEnabled=" .. tostring(ov:isFilmGrainEnabled()))
    lurek.log.info("grain intensity=" .. string.format("%.2f", ov:getFilmGrainIntensity()))
    lurek.log.info("width=" .. ov:getWidth())
    lurek.log.info("height=" .. ov:getHeight())
end
```

---

#### `LOverlay:isFlashing`

Returns whether the flash overlay is active.

```lua
LOverlay:isFlashing()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True while the flash is active. |

**Example**

```lua
do

    local ov = lurek.overlay.new(800, 600)
    ov:triggerFlash(1, 0, 0, 1.0, 0.5)
    lurek.log.info("isFlashing=" .. tostring(ov:isFlashing()))
    lurek.log.info("flash alpha=" .. string.format("%.2f", ov:getFlashAlpha()))
    lurek.log.info("isActive=" .. tostring(ov:isActive()))
    lurek.log.info("isFading=" .. tostring(ov:isFading()))
end
```

---

#### `LOverlay:isFogEnabled`

Returns whether overlay fog rendering is enabled.

```lua
LOverlay:isFogEnabled()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when fog rendering is enabled. |

**Example**

```lua
do

    local ov = lurek.overlay.new(800, 600)
    ov:setFogEnabled(true)
    ov:setFogDensity(0.45)
    lurek.log.info("isFogEnabled=" .. tostring(ov:isFogEnabled()))
    lurek.log.info("fog density=" .. string.format("%.2f", ov:getFogDensity()))
    lurek.log.info("fog active=" .. tostring(ov:isActive()))
    lurek.log.info("dimensions=" .. ov:getWidth() .. "x" .. ov:getHeight())
end
```

---

#### `LOverlay:isHeatHazeEnabled`

Returns whether overlay heat haze rendering is enabled.

```lua
LOverlay:isHeatHazeEnabled()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when heat haze rendering is enabled. |

**Example**

```lua
do

    local ov = lurek.overlay.new(800, 600)
    ov:setHeatHazeEnabled(true)
    ov:setHeatHazeIntensity(0.25)
    lurek.log.info("isHeatHazeEnabled=" .. tostring(ov:isHeatHazeEnabled()))
    lurek.log.info("heat haze intensity=" .. string.format("%.2f", ov:getHeatHazeIntensity()))
    lurek.log.info("width=" .. ov:getWidth())
    lurek.log.info("height=" .. ov:getHeight())
end
```

---

#### `LOverlay:isShaking`

Returns whether the screen shake effect is active.

```lua
LOverlay:isShaking()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True while screen shake is active. |

**Example**

```lua
do

    local ov = lurek.overlay.new(800, 600)
    ov:triggerShake(5.0, 0.5)
    local ox, oy = ov:getShakeOffset()
    lurek.log.info("isShaking=" .. tostring(ov:isShaking()))
    lurek.log.info("shake offset=" .. string.format("%.2f,%.2f", ox, oy))
    lurek.log.info("isActive=" .. tostring(ov:isActive()))
    lurek.log.info("width=" .. ov:getWidth())
end
```

---

#### `LOverlay:isVignetteEnabled`

Returns whether overlay vignette rendering is enabled.

```lua
LOverlay:isVignetteEnabled()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when vignette rendering is enabled. |

**Example**

```lua
do

    local ov = lurek.overlay.new(800, 600)
    ov:setVignetteEnabled(true)
    ov:setVignetteStrength(0.55)
    lurek.log.info("isVignetteEnabled=" .. tostring(ov:isVignetteEnabled()))
    lurek.log.info("vignette strength=" .. string.format("%.2f", ov:getVignetteStrength()))
    lurek.log.info("width=" .. ov:getWidth())
    lurek.log.info("height=" .. ov:getHeight())
end
```

---

#### `LOverlay:isWeatherEnabled`

Returns whether overlay weather rendering is enabled.

```lua
LOverlay:isWeatherEnabled()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when weather rendering is enabled. |

**Example**

```lua
do

    local ov = lurek.overlay.new(800, 600)
    ov:setWeatherEnabled(true)
    ov:setWeather("snow")
    ov:setWeatherIntensity(0.5)
    lurek.log.info("isWeatherEnabled=" .. tostring(ov:isWeatherEnabled()))
    lurek.log.info("weather=" .. ov:getWeather())
    lurek.log.info("weather intensity=" .. string.format("%.2f", ov:getWeatherIntensity()))
    lurek.log.info("wind direction=" .. string.format("%.2f", ov:getWindDirection()))
end
```

---

#### `LOverlay:pullAmbientFromLight`

Copies ambient color from the shared light world into this overlay.

```lua
LOverlay:pullAmbientFromLight()
```

**Example**

```lua
do


    local source = lurek.overlay.new(800, 600)
    source:setAmbientColor(0.12, 0.18, 0.30, 0.65)
    source:pushAmbientToLight()

    local ov = lurek.overlay.new(800, 600)
    ov:pullAmbientFromLight()
    local r, g, b, a = ov:getAmbientColor()
    lurek.log.info("LOverlay:pullAmbientFromLight=" .. string.format("%.2f,%.2f,%.2f,%.2f", r, g, b, a))
end
```

---

#### `LOverlay:pushAmbientToLight`

Copies this overlay ambient color into the shared light world.

```lua
LOverlay:pushAmbientToLight()
```

**Example**

```lua
do


    local source = lurek.overlay.new(800, 600)
    source:setAmbientColor(0.30, 0.20, 0.50, 0.40)
    source:pushAmbientToLight()

    local probe = lurek.overlay.new(800, 600)
    probe:pullAmbientFromLight()
    local r, g, b, a = probe:getAmbientColor()
    lurek.log.info("LOverlay:pushAmbientToLight=" .. string.format("%.2f,%.2f,%.2f,%.2f", r, g, b, a))
end
```

---

#### `LOverlay:render`

Queues renderer commands for the overlay's current visual state.

```lua
LOverlay:render(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts?` | table | Optional table with `target` and `includeGlobal`. |

**Example**

```lua
do


    local ov = lurek.overlay.new(800, 600)
    ov:setStatusEffect("blind", {
        intensity = 6.0,
        fadeIn = 0.01,
        target = "sceneOnly",
        shader = "vignette",
    })
    ov:update(0.05)
    ov:render({ target = "sceneOnly" })
    ov:render({ target = "hudFront", includeGlobal = true })
    lurek.log.info("LOverlay:render active=" .. tostring(ov:isActive()))
    lurek.log.info("LOverlay:render statusLayers=" .. tostring(#ov:getStatusEffects()))
end
```

---

#### `LOverlay:resize`

Resizes the overlay target dimensions.

```lua
LOverlay:resize(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | number | New width in pixels. |
| `h` | number | New height in pixels. |

**Example**

```lua
do

    local ov = lurek.overlay.new(800, 600)
    ov:resize(1280, 720)
    local w, h = ov:getDimensions()
    lurek.log.info("resize=" .. ov:getWidth() .. "x" .. ov:getHeight())
    lurek.log.info("dimensions=" .. w .. "x" .. h)
    lurek.log.info("type=" .. ov:type())
    lurek.log.info("active=" .. tostring(ov:isActive()))
end
```

---

#### `LOverlay:setAccessibilityPolicy`

Replaces or partially updates the overlay accessibility policy.

```lua
LOverlay:setAccessibilityPolicy(policy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `policy?` | table | Optional policy table; nil resets defaults. |

**Example**

```lua
do

    local ov = lurek.overlay.new(800, 600)
    ov:setAccessibilityPolicy({
        reduced_motion = true,
        max_flash_alpha = 0.2,
        max_flash_duration = 0.1,
        max_shake_intensity = 1.25,
        disable_lightning = true,
        disable_film_grain = true,
    })
    ov:triggerFlash(1.0, 1.0, 1.0, 0.9, 0.5)
    lurek.log.info("reduced motion=" .. tostring(ov:getAccessibilityPolicy().reduced_motion))
    lurek.log.info("flash alpha after clamp=" .. string.format("%.2f", ov:getFlashAlpha()))
end
```

---

#### `LOverlay:setAmbientColor`

Sets the overlay ambient color from RGBA channels.

```lua
LOverlay:setAmbientColor(r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a?` | number | Alpha channel, defaulting to 1.0. |

**Example**

```lua
do


    local ov = lurek.overlay.new(800, 600)
    ov:setAmbientColor(0.2, 0.1, 0.3, 0.5)
    local r, g, b, a = ov:getAmbientColor()
    lurek.log.info("LOverlay:setAmbientColor=" .. string.format("%.2f,%.2f,%.2f,%.2f", r, g, b, a))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end
```

---

#### `LOverlay:setAmbientEnabled`

Enables or disables overlay ambient color rendering.

```lua
LOverlay:setAmbientEnabled(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | boolean | New ambient enabled flag. |

**Example**

```lua
do

    local ov = lurek.overlay.new(800, 600)
    ov:setAmbientEnabled(true)
    local r, g, b, a = ov:getAmbientColor()
    lurek.log.info("setAmbientEnabled=" .. tostring(ov:isAmbientEnabled()))
    lurek.log.info("ambient color=" .. string.format("%.2f,%.2f,%.2f,%.2f", r, g, b, a))
    lurek.log.info("width=" .. ov:getWidth())
    lurek.log.info("height=" .. ov:getHeight())
end
```

---

#### `LOverlay:setCloudCount`

Sets the overlay cloud shadow count.

```lua
LOverlay:setCloudCount(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | Cloud shadow count. |

**Example**

```lua
do

    local ov = lurek.overlay.new(800, 600)
    ov:setCloudCount(12)
    ov:setCloudShadows(true)
    lurek.log.info("setCloudCount=" .. ov:getCloudCount())
    lurek.log.info("cloud shadows=" .. tostring(ov:isCloudShadowsEnabled()))
    lurek.log.info("cloud opacity=" .. string.format("%.2f", ov:getCloudOpacity()))
    lurek.log.info("cloud speed=" .. string.format("%.2f", ov:getCloudSpeed()))
end
```

---

#### `LOverlay:setCloudOpacity`

Sets cloud shadow opacity. This method is available to Lua scripts.

```lua
LOverlay:setCloudOpacity(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | Cloud opacity value. |

**Example**

```lua
do


    local ov = lurek.overlay.new(800, 600)
    ov:setCloudOpacity(0.5)
    lurek.log.info("LOverlay:setCloudOpacity=" .. string.format("%.2f", ov:getCloudOpacity()))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end
```

---

#### `LOverlay:setCloudScale`

Sets cloud shadow scale. This method is available to Lua scripts.

```lua
LOverlay:setCloudScale(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | Cloud scale value. |

**Example**

```lua
do


    local ov = lurek.overlay.new(800, 600)
    ov:setCloudScale(2.0)
    lurek.log.info("LOverlay:setCloudScale=" .. string.format("%.2f", ov:getCloudScale()))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end
```

---

#### `LOverlay:setCloudShadows`

Enables or disables overlay cloud shadow rendering.

```lua
LOverlay:setCloudShadows(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | boolean | New cloud shadow enabled flag. |

**Example**

```lua
do

    local ov = lurek.overlay.new(800, 600)
    ov:setCloudShadows(true)
    ov:setCloudCount(5)
    lurek.log.info("setCloudShadows=" .. tostring(ov:isCloudShadowsEnabled()))
    lurek.log.info("cloud count=" .. ov:getCloudCount())
    lurek.log.info("cloud scale=" .. string.format("%.2f", ov:getCloudScale()))
    lurek.log.info("cloud opacity=" .. string.format("%.2f", ov:getCloudOpacity()))
end
```

---

#### `LOverlay:setCloudSpeed`

Sets cloud shadow movement speed. This method is available to Lua scripts.

```lua
LOverlay:setCloudSpeed(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | Cloud speed value. |

**Example**

```lua
do


    local ov = lurek.overlay.new(800, 600)
    ov:setCloudSpeed(0.5)
    lurek.log.info("LOverlay:setCloudSpeed=" .. string.format("%.2f", ov:getCloudSpeed()))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end
```

---

#### `LOverlay:setCustomShader`

Sets or clears the custom overlay shader name.

```lua
LOverlay:setCustomShader(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name?` | string | Optional shader name; nil clears the custom shader. |

**Example**

```lua
do

    local ov = lurek.overlay.new(800, 600)
    ov:setCustomShader("scanlines")
    local img_with_shader = ov:drawToImage(96, 64)
    ov:setCustomShader(nil)
    local img_without_shader = ov:drawToImage(96, 64)
    lurek.log.info("LOverlay:setCustomShader types=" .. type(img_with_shader) .. "," .. type(img_without_shader))
end
```

---

#### `LOverlay:setFilmGrainEnabled`

Enables or disables overlay film grain rendering.

```lua
LOverlay:setFilmGrainEnabled(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | boolean | New film grain enabled flag. |

**Example**

```lua
do

    local ov = lurek.overlay.new(800, 600)
    ov:setFilmGrainEnabled(true)
    ov:setFilmGrainIntensity(0.25)
    lurek.log.info("setFilmGrainEnabled=" .. tostring(ov:isFilmGrainEnabled()))
    lurek.log.info("grain intensity=" .. string.format("%.2f", ov:getFilmGrainIntensity()))
    lurek.log.info("width=" .. ov:getWidth())
    lurek.log.info("height=" .. ov:getHeight())
end
```

---

#### `LOverlay:setFilmGrainIntensity`

Sets overlay film grain intensity.

```lua
LOverlay:setFilmGrainIntensity(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | Film grain intensity value. |

**Example**

```lua
do


    local ov = lurek.overlay.new(800, 600)
    ov:setFilmGrainIntensity(0.3)
    lurek.log.info("LOverlay:setFilmGrainIntensity=" .. string.format("%.2f", ov:getFilmGrainIntensity()))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end
```

---

#### `LOverlay:setFogColor`

Sets the overlay fog color from RGBA channels.

```lua
LOverlay:setFogColor(r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a?` | number | Alpha channel, defaulting to 1.0. |

**Example**

```lua
do


    local ov = lurek.overlay.new(800, 600)
    ov:setFogColor(0.7, 0.7, 0.8, 0.6)
    local r, g, b, a = ov:getFogColor()
    lurek.log.info("LOverlay:setFogColor=" .. string.format("%.2f,%.2f,%.2f,%.2f", r, g, b, a))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end
```

---

#### `LOverlay:setFogDensity`

Sets overlay fog density. This method is available to Lua scripts.

```lua
LOverlay:setFogDensity(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | Fog density value. |

**Example**

```lua
do


    local ov = lurek.overlay.new(800, 600)
    ov:setFogDensity(0.5)
    lurek.log.info("LOverlay:setFogDensity=" .. string.format("%.2f", ov:getFogDensity()))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end
```

---

#### `LOverlay:setFogEnabled`

Enables or disables overlay fog rendering.

```lua
LOverlay:setFogEnabled(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | boolean | New fog enabled flag. |

**Example**

```lua
do

    local ov = lurek.overlay.new(800, 600)
    ov:setFogEnabled(true)
    ov:setFogDensity(0.5)
    lurek.log.info("setFogEnabled=" .. tostring(ov:isFogEnabled()))
    lurek.log.info("fog density=" .. string.format("%.2f", ov:getFogDensity()))
    lurek.log.info("width=" .. ov:getWidth())
    lurek.log.info("height=" .. ov:getHeight())
end
```

---

#### `LOverlay:setHeatHazeEnabled`

Enables or disables overlay heat haze rendering.

```lua
LOverlay:setHeatHazeEnabled(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | boolean | New heat haze enabled flag. |

**Example**

```lua
do

    local ov = lurek.overlay.new(800, 600)
    ov:setHeatHazeEnabled(true)
    ov:setHeatHazeIntensity(0.4)
    lurek.log.info("setHeatHazeEnabled=" .. tostring(ov:isHeatHazeEnabled()))
    lurek.log.info("heat haze intensity=" .. string.format("%.2f", ov:getHeatHazeIntensity()))
    lurek.log.info("width=" .. ov:getWidth())
    lurek.log.info("height=" .. ov:getHeight())
end
```

---

#### `LOverlay:setHeatHazeIntensity`

Sets overlay heat haze intensity. This method is available to Lua scripts.

```lua
LOverlay:setHeatHazeIntensity(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | Heat haze intensity value. |

**Example**

```lua
do


    local ov = lurek.overlay.new(800, 600)
    ov:setHeatHazeIntensity(0.5)
    lurek.log.info("LOverlay:setHeatHazeIntensity=" .. string.format("%.2f", ov:getHeatHazeIntensity()))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end
```

---

#### `LOverlay:setLightningColor`

Sets overlay lightning RGBA color.

```lua
LOverlay:setLightningColor(r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a?` | number | Alpha channel, defaulting to 1.0. |

**Example**

```lua
do


    local ov = lurek.overlay.new(800, 600)
    ov:setLightningColor(1.0, 1.0, 0.8, 1.0)
    local r, g, b, a = ov:getLightningColor()
    lurek.log.info("LOverlay:setLightningColor=" .. string.format("%.2f,%.2f,%.2f,%.2f", r, g, b, a))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end
```

---

#### `LOverlay:setShader`

Sets or clears the shader used for custom overlay rendering.

```lua
LOverlay:setShader(shader)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `shader?` | [LShader](render.md#lshader) | Overlay-target shader or nil to clear. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    local shader = lurek.render.newShader([[
@fragment
fn fs(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(color.rgb + uv.xyx * 0.0, color.a);
}
]], { target = "overlay" })
    ov:setShader(shader)
    lurek.log.info("[overlay.example] shader bound=" .. tostring(ov:getShader() ~= nil))
end
```

---

#### `LOverlay:setShaderLayer`

Sets or clears an overlay-layer shader binding.

```lua
LOverlay:setShaderLayer(layer, shader)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | string | Layer name such as `heat_haze`, `water`, or `fog`. |
| `shader?` | [LShader](render.md#lshader) | Overlay-target shader or nil to clear. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    local shader = lurek.render.newShader([[
@fragment
fn fs(@location(0) color: vec4<f32>) -> @location(0) vec4<f32> {
    return color;
}
]], { target = "overlay" })
    ov:setShaderLayer("heat_haze", shader)
    lurek.log.info("[overlay.example] layer shader=" .. tostring(ov:getShaderLayer("heat_haze") ~= nil))
end
```

---

#### `LOverlay:setStatusEffect`

Creates or updates one overlay-owned status layer such as `frozen`, `poison`, or `lowHealth`.

```lua
LOverlay:setStatusEffect(kind, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `kind` | string | Status kind name. |
| `opts` | table | Status options such as intensity, fade, texture, shader, and color. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    local texture = lurek.image.newImageData(8, 8)
    texture:fill(220, 240, 255, 255)
    ov:setStatusEffect("frozen", {
        intensity = 7.0,
        fadeIn = 0.05,
        color = { 0.65, 0.85, 1.0, 0.25 },
        texture = texture,
        textureOpacity = 0.5,
        shader = "grayscale",
        shaderStrength = 0.75,
    })
    ov:update(0.1)
    lurek.log.info("[overlay.example] status active=" .. tostring(ov:getStatusEffect("frozen") ~= nil))
end
```

---

#### `LOverlay:setStatusIntensity`

Updates one existing status intensity or creates a preset-backed layer when it is missing.

```lua
LOverlay:setStatusIntensity(kind, intensity)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `kind` | string | Status kind name. |
| `intensity` | number | Intensity in `0..1` or `1..10`. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setStatusIntensity("lowhealth", 4.0)
    ov:update(0.1)
    local layer = ov:getStatusEffect("lowhealth")
    lurek.log.info("[overlay.example] lowhealth intensity=" .. string.format("%.2f", layer.intensity))
end
```

---

#### `LOverlay:setTimeOfDay`

Sets the overlay time-of-day value used by ambient effects.

```lua
LOverlay:setTimeOfDay(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | Time-of-day value stored on the overlay ambient state. |

**Example**

```lua
do

    local ov = lurek.overlay.new(800, 600)
    ov:setTimeOfDay(0.5)
    local r, g, b, a = ov:getAmbientColor()
    lurek.log.info("setTimeOfDay=" .. ov:getTimeOfDay())
    lurek.log.info("ambient color=" .. string.format("%.2f,%.2f,%.2f,%.2f", r, g, b, a))
    lurek.log.info("ambient enabled=" .. tostring(ov:isAmbientEnabled()))
    lurek.log.info("active=" .. tostring(ov:isActive()))
end
```

---

#### `LOverlay:setVignetteEnabled`

Enables or disables overlay vignette rendering.

```lua
LOverlay:setVignetteEnabled(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | boolean | New vignette enabled flag. |

**Example**

```lua
do

    local ov = lurek.overlay.new(800, 600)
    ov:setVignetteEnabled(true)
    ov:setVignetteStrength(0.6)
    lurek.log.info("setVignetteEnabled=" .. tostring(ov:isVignetteEnabled()))
    lurek.log.info("vignette strength=" .. string.format("%.2f", ov:getVignetteStrength()))
    lurek.log.info("width=" .. ov:getWidth())
    lurek.log.info("height=" .. ov:getHeight())
end
```

---

#### `LOverlay:setVignetteStrength`

Sets overlay vignette strength. This method is available to Lua scripts.

```lua
LOverlay:setVignetteStrength(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | Vignette strength value. |

**Example**

```lua
do


    local ov = lurek.overlay.new(800, 600)
    ov:setVignetteStrength(0.7)
    lurek.log.info("LOverlay:setVignetteStrength=" .. string.format("%.2f", ov:getVignetteStrength()))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end
```

---

#### `LOverlay:setWater`

Enables water distortion and sets wave amplitude, frequency, and speed.

```lua
LOverlay:setWater(amplitude, frequency, speed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `amplitude` | number | Water wave amplitude. |
| `frequency` | number | Water wave frequency. |
| `speed` | number | Water animation speed. |

**Example**

```lua
do


    local ov = lurek.overlay.new(800, 600)
    ov:setWater(0.25, 1.25, 0.60)
    local w = ov:getWater()
    lurek.log.info("LOverlay:setWater enabled=" .. tostring(w.enabled))
    lurek.log.info("LOverlay:setWater wave=" .. string.format("%.2f", w.amplitude) .. "," .. string.format("%.2f", w.frequency) .. "," .. string.format("%.2f", w.speed))
end
```

---

#### `LOverlay:setWaterTint`

Sets the water tint color and strength.

```lua
LOverlay:setWaterTint(r, g, b, strength)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `strength` | number | Tint strength. |

**Example**

```lua
do


    local ov = lurek.overlay.new(800, 600)
    ov:setWater(0.20, 1.10, 0.35)
    ov:setWaterTint(0.1, 0.3, 0.7, 0.8)
    local w = ov:getWater()
    lurek.log.info("LOverlay:setWaterTint tint=" .. string.format("%.2f", w.tint_r) .. "," .. string.format("%.2f", w.tint_g) .. "," .. string.format("%.2f", w.tint_b) .. "," .. string.format("%.2f", w.tint_strength))
end
```

---

#### `LOverlay:setWeather`

Sets the overlay weather type by name.

```lua
LOverlay:setWeather(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Weather type name recognized by the engine. |

**Example**

```lua
do

    local ov = lurek.overlay.new(800, 600)
    ov:setWeather("snow")
    ov:setWeatherEnabled(true)
    ov:setWeatherIntensity(0.7)
    lurek.log.info("setWeather=" .. ov:getWeather())
    lurek.log.info("weather enabled=" .. tostring(ov:isWeatherEnabled()))
    lurek.log.info("weather intensity=" .. string.format("%.2f", ov:getWeatherIntensity()))
    lurek.log.info("wind speed=" .. string.format("%.2f", ov:getWindSpeed()))
end
```

---

#### `LOverlay:setWeatherEnabled`

Enables or disables overlay weather rendering.

```lua
LOverlay:setWeatherEnabled(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | boolean | New weather enabled flag. |

**Example**

```lua
do

    local ov = lurek.overlay.new(800, 600)
    ov:setWeatherEnabled(true)
    ov:setWeather("rain")
    ov:setWeatherIntensity(0.8)
    lurek.log.info("setWeatherEnabled=" .. tostring(ov:isWeatherEnabled()))
    lurek.log.info("weather=" .. ov:getWeather())
    lurek.log.info("weather intensity=" .. string.format("%.2f", ov:getWeatherIntensity()))
    lurek.log.info("wind direction=" .. string.format("%.2f", ov:getWindDirection()))
end
```

---

#### `LOverlay:setWeatherIntensity`

Sets weather intensity for the current weather type.

```lua
LOverlay:setWeatherIntensity(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | Weather intensity value. |

**Example**

```lua
do


    local ov = lurek.overlay.new(800, 600)
    ov:setWeatherIntensity(0.8)
    lurek.log.info("LOverlay:setWeatherIntensity=" .. string.format("%.2f", ov:getWeatherIntensity()))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end
```

---

#### `LOverlay:setWeatherRngState`

Replaces the current deterministic overlay weather RNG state.

```lua
LOverlay:setWeatherRngState(state)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `state` | number | New weather RNG state; zero maps to the engine default seed. |

**Example**

```lua
do

    local ov = lurek.overlay.new(800, 600)
    ov:setWeatherRngState(987654321)
    lurek.log.info("weather rng state=" .. tostring(ov:getWeatherRngState()))
    ov:setWeather("rain")
    lurek.log.info("overlay type=" .. tostring(ov:type()))
end
```

---

#### `LOverlay:setWeatherSeed`

Sets the deterministic overlay weather seed used for future particle sampling.

```lua
LOverlay:setWeatherSeed(seed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `seed` | number | Non-zero preferred seed value; zero maps to the engine default seed. |

**Example**

```lua
do

    local ov = lurek.overlay.new(800, 600)
    ov:setWeatherSeed(123456789)
    lurek.log.info("weather seed state=" .. tostring(ov:getWeatherRngState()))
    ov:setWeatherEnabled(true)
    lurek.log.info("weather enabled=" .. tostring(ov:isWeatherEnabled()))
end
```

---

#### `LOverlay:setWindDirection`

Sets the overlay weather wind direction.

```lua
LOverlay:setWindDirection(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | Wind direction value. |

**Example**

```lua
do


    local ov = lurek.overlay.new(800, 600)
    ov:setWindDirection(1.57)
    lurek.log.info("LOverlay:setWindDirection=" .. string.format("%.2f", ov:getWindDirection()))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end
```

---

#### `LOverlay:setWindSpeed`

Sets the overlay weather wind speed.

```lua
LOverlay:setWindSpeed(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | Wind speed value. |

**Example**

```lua
do


    local ov = lurek.overlay.new(800, 600)
    ov:setWindSpeed(8.0)
    lurek.log.info("LOverlay:setWindSpeed=" .. string.format("%.2f", ov:getWindSpeed()))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end
```

---

#### `LOverlay:shake`

Starts a screen shake with optional duration.

```lua
LOverlay:shake(intensity, dur)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `intensity` | number | Shake intensity. |
| `dur?` | number | Duration in seconds, defaulting to 0.5. |

**Example**

```lua
do

    local ov = lurek.overlay.new(800, 600)
    ov:shake(8.0, 0.4)
    local ox, oy = ov:getShakeOffset()
    lurek.log.info("shake isShaking=" .. tostring(ov:isShaking()))
    lurek.log.info("shake offset=" .. string.format("%.2f,%.2f", ox, oy))
    lurek.log.info("shake active=" .. tostring(ov:isActive()))
    lurek.log.info("shake height=" .. ov:getHeight())
end
```

---

#### `LOverlay:syncAmbientWithLight`

Resolves overlay and light ambient colors using a named mode and writes both stores.

```lua
LOverlay:syncAmbientWithLight(mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | string | One of `light`, `overlay`, `avg`, `max`, or `min`. |

**Example**

```lua
do


    local ov = lurek.overlay.new(800, 600)
    ov:setAmbientColor(0.20, 0.10, 0.40, 0.60)
    ov:syncAmbientWithLight("overlay")

    local probe = lurek.overlay.new(800, 600)
    probe:pullAmbientFromLight()
    local r, g, b, a = probe:getAmbientColor()
    lurek.log.info("LOverlay:syncAmbientWithLight=" .. string.format("%.2f,%.2f,%.2f,%.2f", r, g, b, a))
end
```

---

#### `LOverlay:triggerFade`

Starts a fade overlay toward a target alpha.

```lua
LOverlay:triggerFade(r, g, b, target_alpha, duration)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `target_alpha` | number | Target alpha value. |
| `duration` | number | Fade duration in seconds. |

**Example**

```lua
do

    local ov = lurek.overlay.new(800, 600)
    ov:triggerFade(1.0, 0, 0, 0, 0.2)
    ov:update(0.05)
    lurek.log.info("triggerFade isFading=" .. tostring(ov:isFading()))
    lurek.log.info("triggerFade active=" .. tostring(ov:isActive()))
    lurek.log.info("triggerFade isFlashing=" .. tostring(ov:isFlashing()))
    lurek.log.info("triggerFade width=" .. ov:getWidth())
end
```

---

#### `LOverlay:triggerFlash`

Starts a screen flash with explicit RGBA color and duration.

```lua
LOverlay:triggerFlash(r, g, b, a, duration)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a` | number | Alpha channel. |
| `duration` | number | Flash duration in seconds. |

**Example**

```lua
do

    local ov = lurek.overlay.new(800, 600)
    ov:triggerFlash(1, 1, 0, 1.0, 0.2)
    lurek.log.info("triggerFlash isFlashing=" .. tostring(ov:isFlashing()))
    lurek.log.info("triggerFlash alpha=" .. string.format("%.2f", ov:getFlashAlpha()))
    lurek.log.info("triggerFlash active=" .. tostring(ov:isActive()))
    lurek.log.info("triggerFlash type=" .. ov:type())
end
```

---

#### `LOverlay:triggerLightning`

Starts a lightning flash using the overlay lightning state.

```lua
LOverlay:triggerLightning()
```

**Example**

```lua
do


    local ov = lurek.overlay.new(800, 600)
    ov:triggerLightning()
    lurek.log.info("LOverlay:triggerLightning alpha=" .. string.format("%.2f", ov:getLightningAlpha()))
    local active = ov:isActive()
    lurek.log.info("active=" .. tostring(active))
end
```

---

#### `LOverlay:triggerShake`

Starts a screen shake effect. This method is available to Lua scripts.

```lua
LOverlay:triggerShake(intensity, duration)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `intensity` | number | Shake intensity. |
| `duration` | number | Shake duration in seconds. |

**Example**

```lua
do

    local ov = lurek.overlay.new(800, 600)
    ov:triggerShake(6.0, 0.3)
    local ox, oy = ov:getShakeOffset()
    lurek.log.info("triggerShake isShaking=" .. tostring(ov:isShaking()))
    lurek.log.info("triggerShake offset=" .. string.format("%.2f,%.2f", ox, oy))
    lurek.log.info("triggerShake active=" .. tostring(ov:isActive()))
    lurek.log.info("triggerShake width=" .. ov:getWidth())
end
```

---

#### `LOverlay:type`

Returns the Lua-visible type name for this overlay handle.

```lua
LOverlay:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LOverlay](#loverlay)`. |

**Example**

```lua
do

    local ov = lurek.overlay.new(800, 600)
    local w, h = ov:getDimensions()
    lurek.log.info("type=" .. ov:type())
    lurek.log.info("dimensions=" .. w .. "x" .. h)
    lurek.log.info("active=" .. tostring(ov:isActive()))
    lurek.log.info("typeOf overlay=" .. tostring(ov:typeOf("LOverlay")))
end
```

---

#### `LOverlay:typeOf`

Returns whether this overlay handle matches a supported type name.

```lua
LOverlay:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `Overlay` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do

    local ov = lurek.overlay.new(800, 600)
    lurek.log.info("typeOf LOverlay=" .. tostring(ov:typeOf("LOverlay")))
    lurek.log.info("overlay width=" .. tostring(ov:getWidth()))
    lurek.log.info("typeOf LScreenTransition=" .. tostring(ov:typeOf("LScreenTransition")))
    lurek.log.info("dimensions=" .. ov:getWidth() .. "x" .. ov:getHeight())
end
```

---

#### `LOverlay:update`

Advances overlay timers and animated effect state.

```lua
LOverlay:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Delta time in seconds. |

**Example**

```lua
do

    local ov = lurek.overlay.new(800, 600)
    ov:triggerShake(5.0, 1.0)
    ov:update(0.016)
    local ox, oy = ov:getShakeOffset()
    lurek.log.info("update isShaking=" .. tostring(ov:isShaking()))
    lurek.log.info("update offset=" .. string.format("%.2f,%.2f", ox, oy))
    lurek.log.info("update active=" .. tostring(ov:isActive()))
    lurek.log.info("update width=" .. ov:getWidth())
end
```

---

## LScreenTransition

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LScreenTransition:color`

Returns the transition RGBA color.

```lua
LScreenTransition:color()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Red channel. |
| number | Green channel. |
| number | Blue channel. |
| number | Alpha channel. |

**Example**

```lua
do


    local tr = lurek.overlay.newTransition("fade", 1.0, { 0.0, 0.0, 0.0, 1.0 })
    local r, g, b, a = tr:color()
    lurek.log.info("LScreenTransition:color=" .. string.format("%.2f,%.2f,%.2f,%.2f", r, g, b, a))
    local active = tr:isActive()
    lurek.log.info("active=" .. tostring(active))
end
```

---

#### `LScreenTransition:isActive`

Returns whether the transition is currently active.

```lua
LScreenTransition:isActive()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the transition is active. |

**Example**

```lua
do

    local tr = lurek.overlay.newTransition("fade", 1.0, { 0.0, 0.0, 0.0, 1.0 })
    tr:play()
    lurek.log.info("transition isActive=" .. tostring(tr:isActive()))
    lurek.log.info("transition isDone=" .. tostring(tr:isDone()))
    lurek.log.info("transition kind=" .. tr:kind())
    lurek.log.info("transition progress=" .. string.format("%.2f", tr:progress()))
end
```

---

#### `LScreenTransition:isDone`

Returns whether the transition has finished.

```lua
LScreenTransition:isDone()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the transition is complete. |

**Example**

```lua
do

    local tr = lurek.overlay.newTransition("fade", 0.2, { 0.0, 0.0, 0.0, 1.0 })
    tr:play()
    tr:update(1.0)
    lurek.log.info("transition isDone=" .. tostring(tr:isDone()))
    lurek.log.info("transition isActive=" .. tostring(tr:isActive()))
    lurek.log.info("transition progress=" .. string.format("%.2f", tr:progress()))
    lurek.log.info("transition type=" .. tr:type())
end
```

---

#### `LScreenTransition:kind`

Returns the transition kind name. This method is available to Lua scripts.

```lua
LScreenTransition:kind()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Transition kind name. |

**Example**

```lua
do

    local tr = lurek.overlay.newTransition("iris", 1.0, { 0.0, 0.0, 0.0, 1.0 })
    local r, g, b, a = tr:color()
    lurek.log.info("transition kind=" .. tr:kind())
    lurek.log.info("transition type=" .. tr:type())
    lurek.log.info("transition active=" .. tostring(tr:isActive()))
    lurek.log.info("transition color=" .. string.format("%.2f,%.2f,%.2f,%.2f", r, g, b, a))
end
```

---

#### `LScreenTransition:play`

Starts this screen transition forward from its current state.

```lua
LScreenTransition:play()
```

**Example**

```lua
do


    local tr = lurek.overlay.newTransition("fade", 0.5, { 0.0, 0.0, 0.0, 1.0 })
    tr:play()
    lurek.log.info("LScreenTransition:play isActive=" .. tostring(tr:isActive()))
    lurek.log.info("LScreenTransition:play progress=" .. string.format("%.2f", tr:progress()))
    local active = tr:isActive()
    lurek.log.info("active=" .. tostring(active))
end
```

---

#### `LScreenTransition:progress`

Returns normalized transition progress.

```lua
LScreenTransition:progress()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Progress value between the transition start and end. |

**Example**

```lua
do


    local tr = lurek.overlay.newTransition("fade", 1.0, { 0.0, 0.0, 0.0, 1.0 })
    tr:play()
    tr:update(0.5)
    lurek.log.info("LScreenTransition:progress=" .. string.format("%.2f", tr:progress()))
    local active = tr:isActive()
    lurek.log.info("active=" .. tostring(active))
end
```

---

#### `LScreenTransition:reverse`

Starts this screen transition in reverse from its current state.

```lua
LScreenTransition:reverse()
```

**Example**

```lua
do


    local tr = lurek.overlay.newTransition("fade", 1.0, { 0.0, 0.0, 0.0, 1.0 })
    tr:reverse()
    lurek.log.info("LScreenTransition:reverse isActive=" .. tostring(tr:isActive()))
    lurek.log.info("LScreenTransition:reverse progress=" .. string.format("%.2f", tr:progress()))
    local active = tr:isActive()
    lurek.log.info("active=" .. tostring(active))
end
```

---

#### `LScreenTransition:setColor`

Sets the transition RGBA color from a numeric array table.

```lua
LScreenTransition:setColor(color)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `color` | table | Numeric color table using indices 1 through 4. |

**Example**

```lua
do


    local tr = lurek.overlay.newTransition("fade", 1.0, { 0.0, 0.0, 0.0, 1.0 })
    tr:setColor({ 0.1, 0.05, 0.2, 1.0 })
    local r, g, b, a = tr:color()
    lurek.log.info("LScreenTransition:setColor=" .. string.format("%.2f,%.2f,%.2f,%.2f", r, g, b, a))
    local active = tr:isActive()
    lurek.log.info("active=" .. tostring(active))
end
```

---

#### `LScreenTransition:type`

Returns the Lua-visible type name for this transition handle.

```lua
LScreenTransition:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LScreenTransition](#lscreentransition)`. |

**Example**

```lua
do

    local tr = lurek.overlay.newTransition("fade", 1.0, { 0.0, 0.0, 0.0, 1.0 })
    local r, g, b, a = tr:color()
    lurek.log.info("transition type=" .. tr:type())
    lurek.log.info("transition kind=" .. tr:kind())
    lurek.log.info("transition active=" .. tostring(tr:isActive()))
    lurek.log.info("transition color=" .. string.format("%.2f,%.2f,%.2f,%.2f", r, g, b, a))
end
```

---

#### `LScreenTransition:typeOf`

Returns whether this transition handle matches a supported type name.

```lua
LScreenTransition:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `ScreenTransition` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do

    local tr = lurek.overlay.newTransition("fade", 1.0, { 0.0, 0.0, 0.0, 1.0 })
    lurek.log.info("typeOf LScreenTransition=" .. tostring(tr:typeOf("LScreenTransition")))
    lurek.log.info("typeOf LObject=" .. tostring(tr:typeOf("LObject")))
    lurek.log.info("typeOf LOverlay=" .. tostring(tr:typeOf("LOverlay")))
    lurek.log.info("kind=" .. tr:kind())
end
```

---

#### `LScreenTransition:update`

Advances this transition timer and returns whether it remains active.

```lua
LScreenTransition:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Delta time in seconds. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the transition is still active after the update. |

**Example**

```lua
do


    local tr = lurek.overlay.newTransition("fade", 1.0, { 0.0, 0.0, 0.0, 1.0 })
    tr:play()
    local still_active = tr:update(0.016)
    lurek.log.info("LScreenTransition:update active=" .. tostring(still_active))
    lurek.log.info("LScreenTransition:update progress=" .. string.format("%.2f", tr:progress()))
end
```

---
