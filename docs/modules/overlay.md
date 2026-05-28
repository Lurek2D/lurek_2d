# Overlay

- The `overlay` module manages all screen-space visual effects drawn between the game world and the player: weather particles, atmospheric effects, screen flashes, camera shake, scene transitions, ambient tinting, and water distortion.

The `overlay` module provides a self-contained screen-space effects layer that sits above world rendering and below the HUD. The central `Overlay` struct owns every subsystem and drives their per-frame update via a single `update(dt)` call. It handles five distinct effect categories.

**Weather and atmosphere**: A particle-based `WeatherState` simulates seven weather modes — rain, snow, hail, dust, leaves, ash, and pollen — each with configurable wind parameters and an internal PRNG pool. Atmospheric overlays add full-screen fog, animated cloud layers, heat haze distortion, vignette darkening, film grain, and short-lived lightning flashes, all driven by opt-in state structs that default to disabled.

**Ambient lighting**: `AmbientState` applies a global RGBA tint driven by a time-of-day curve that interpolates through dawn, day, dusk, and night segments. This tint is synchronized with the `light` module via `pull_ambient_from_light` and `push_ambient_to_light` helpers to keep both systems consistent.

**Screen effects**: Three time-limited state machines handle `FlashState` (full-screen color burst with alpha decay), `ShakeState` (camera offset jitter using a deterministic internal PRNG), and `FadeState` (timed interpolation toward a target alpha). All three are triggered from Lua via `trigger_flash`, `trigger_shake`, and `trigger_fade`.

**Scene transitions**: `ScreenTransition` supports fade, wipe, iris wipe, and dissolve styles with forward and reverse playback modes. Normalized progress is exposed for renderer consumption.

**Water distortion**: `WaterOverlayState` applies an animated sine-wave distortion overlay with configurable amplitude, frequency, and speed, plus shallow-water tint and depth-based color shift.

All active layers emit `RenderCommand` entries built by `build_render_commands` for compositor integration. Debug visualization helpers render state panels and trigger previews into `ImageData` buffers. The full suite is accessible via `lurek.overlay.*`.

## Functions

### `lurek.overlay.new`

Creates an overlay controller for screen effects using optional dimensions.

```lua
-- signature
lurek.overlay.new(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w?` | `number` | Overlay width in pixels, defaulting to 800. |
| `h?` | `number` | Overlay height in pixels, defaulting to 600. |

**Returns**

| Type | Description |
|------|-------------|
| `LOverlay` | New overlay handle. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    local w, h = ov:getDimensions()
    print("lurek.overlay.new type=" .. ov:type())
    print("lurek.overlay.new size=" .. w .. "x" .. h)
end
```

---

### `lurek.overlay.newTransition`

Creates a timed screen transition with optional kind, duration, and color.

```lua
-- signature
lurek.overlay.newTransition(kind, duration, color_tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `kind?` | `string` | Transition kind name, defaulting to `fade`. |
| `duration?` | `number` | Duration in seconds, defaulting to 1.0. |
| `color_tbl?` | `table` | Numeric RGBA table using indices 1 through 4. |

**Returns**

| Type | Description |
|------|-------------|
| `LScreenTransition` | New screen transition handle. |

**Example**

```lua
do
    local tr = lurek.overlay.newTransition("wipe", 0.75, { 0.05, 0.10, 0.15, 1.0 })
    print("lurek.overlay.newTransition type=" .. tr:type())
    print("lurek.overlay.newTransition kind=" .. tr:kind())
end
```

---

## LOverlay

### `LOverlay:clear`

Clears active overlay effects and resets transient state.

```lua
-- signature
LOverlay:clear()
```

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:triggerFlash(1, 1, 1, 0.5, 0.1)
    print("LOverlay:clear before=" .. tostring(ov:isActive()))
    ov:clear()
    print("LOverlay:clear after=" .. tostring(ov:isActive()))
end
```

---

### `LOverlay:drawToImage`

Renders overlay state into an image object of the requested size.

```lua
-- signature
LOverlay:drawToImage(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | `number` | Target image width in pixels. |
| `h` | `number` | Target image height in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| `Image` | Image containing the overlay draw state. |

**Example**

```lua
do
    local ov = lurek.overlay.new(200, 150)
    ov:flash(0.9, 0.95, 1.0, 0.6, 0.2)
    local img = ov:drawToImage(200, 150)
    print("LOverlay:drawToImage type=" .. type(img))
    print("LOverlay:drawToImage active=" .. tostring(ov:isActive()))
end
```

---

### `LOverlay:fade`

Starts a fade overlay with optional alpha and duration.

```lua
-- signature
LOverlay:fade(r, g, b, a, dur)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | `number` | Red channel. |
| `g` | `number` | Green channel. |
| `b` | `number` | Blue channel. |
| `a?` | `number` | Target alpha, defaulting to 1.0. |
| `dur?` | `number` | Duration in seconds, defaulting to 1.0. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:fade(0.05, 0.05, 0.10, 0.85, 0.5)
    print("LOverlay:fade isFading=" .. tostring(ov:isFading()))
    print("LOverlay:fade active=" .. tostring(ov:isActive()))
end
```

---

### `LOverlay:flash`

Starts a short flash overlay with optional alpha and duration.

```lua
-- signature
LOverlay:flash(r, g, b, a, dur)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | `number` | Red channel. |
| `g` | `number` | Green channel. |
| `b` | `number` | Blue channel. |
| `a?` | `number` | Alpha channel, defaulting to 1.0. |
| `dur?` | `number` | Duration in seconds, defaulting to 0.2. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:flash(1.0, 0.95, 0.70, 0.8, 0.2)
    print("LOverlay:flash isFlashing=" .. tostring(ov:isFlashing()))
    print("LOverlay:flash alpha=" .. f2(ov:getFlashAlpha()))
end
```

---

### `LOverlay:getAmbientColor`

Returns overlay ambient RGBA color.

```lua
-- signature
LOverlay:getAmbientColor()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Red channel. |
| `number` | b Green channel. |
| `number` | c Blue channel. |
| `number` | d Alpha channel. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setAmbientColor(0.2, 0.1, 0.3, 0.5)
    local r, g, b, a = ov:getAmbientColor()
    print("LOverlay:getAmbientColor=" .. rgba_text(r, g, b, a))
end
```

---

### `LOverlay:getCloudCount`

Returns the overlay cloud shadow count.

```lua
-- signature
LOverlay:getCloudCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Cloud shadow count. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setCloudCount(8)
    print("LOverlay:getCloudCount=" .. ov:getCloudCount())
end
```

---

### `LOverlay:getCloudOpacity`

Returns cloud shadow opacity. This method is available to Lua scripts.

```lua
-- signature
LOverlay:getCloudOpacity()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Cloud opacity value. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setCloudOpacity(0.7)
    print("LOverlay:getCloudOpacity=" .. f2(ov:getCloudOpacity()))
end
```

---

### `LOverlay:getCloudScale`

Returns cloud shadow scale. This method is available to Lua scripts.

```lua
-- signature
LOverlay:getCloudScale()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Cloud scale value. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setCloudScale(1.5)
    print("LOverlay:getCloudScale=" .. f2(ov:getCloudScale()))
end
```

---

### `LOverlay:getCloudSpeed`

Returns cloud shadow movement speed.

```lua
-- signature
LOverlay:getCloudSpeed()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Cloud speed value. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setCloudSpeed(0.3)
    print("LOverlay:getCloudSpeed=" .. f2(ov:getCloudSpeed()))
end
```

---

### `LOverlay:getDimensions`

Returns the overlay dimensions. This method is available to Lua scripts.

```lua
-- signature
LOverlay:getDimensions()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Overlay width in pixels. |
| `number` | b Overlay height in pixels. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    local w, h = ov:getDimensions()
    print("LOverlay:getDimensions=" .. w .. "x" .. h)
end
```

---

### `LOverlay:getFilmGrainIntensity`

Returns overlay film grain intensity.

```lua
-- signature
LOverlay:getFilmGrainIntensity()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Current film grain intensity. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setFilmGrainIntensity(0.4)
    print("LOverlay:getFilmGrainIntensity=" .. f2(ov:getFilmGrainIntensity()))
end
```

---

### `LOverlay:getFlashAlpha`

Returns the current flash alpha. This method is available to Lua scripts.

```lua
-- signature
LOverlay:getFlashAlpha()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Flash alpha value. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:flash(1, 1, 0, 1.0, 0.5)
    print("LOverlay:getFlashAlpha=" .. f2(ov:getFlashAlpha()))
end
```

---

### `LOverlay:getFogColor`

Returns overlay fog RGBA color. This method is available to Lua scripts.

```lua
-- signature
LOverlay:getFogColor()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Red channel. |
| `number` | b Green channel. |
| `number` | c Blue channel. |
| `number` | d Alpha channel. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setFogColor(0.5, 0.5, 0.5, 0.8)
    local r, g, b, a = ov:getFogColor()
    print("LOverlay:getFogColor=" .. rgba_text(r, g, b, a))
end
```

---

### `LOverlay:getFogDensity`

Returns overlay fog density. This method is available to Lua scripts.

```lua
-- signature
LOverlay:getFogDensity()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Current fog density. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setFogDensity(0.6)
    print("LOverlay:getFogDensity=" .. f2(ov:getFogDensity()))
end
```

---

### `LOverlay:getHeatHazeIntensity`

Returns overlay heat haze intensity.

```lua
-- signature
LOverlay:getHeatHazeIntensity()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Current heat haze intensity. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setHeatHazeIntensity(0.4)
    print("LOverlay:getHeatHazeIntensity=" .. f2(ov:getHeatHazeIntensity()))
end
```

---

### `LOverlay:getHeight`

Returns the overlay height. This method is available to Lua scripts.

```lua
-- signature
LOverlay:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Overlay height in pixels. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    print("LOverlay:getHeight=" .. ov:getHeight())
end
```

---

### `LOverlay:getLightningAlpha`

Returns the current lightning alpha.

```lua
-- signature
LOverlay:getLightningAlpha()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Lightning alpha value. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:triggerLightning()
    print("LOverlay:getLightningAlpha=" .. f2(ov:getLightningAlpha()))
end
```

---

### `LOverlay:getLightningColor`

Returns overlay lightning RGBA color.

```lua
-- signature
LOverlay:getLightningColor()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Red channel. |
| `number` | b Green channel. |
| `number` | c Blue channel. |
| `number` | d Alpha channel. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setLightningColor(0.9, 0.9, 1.0, 1.0)
    local r, g, b, a = ov:getLightningColor()
    print("LOverlay:getLightningColor=" .. rgba_text(r, g, b, a))
end
```

---

### `LOverlay:getShakeOffset`

Returns the current screen shake offset.

```lua
-- signature
LOverlay:getShakeOffset()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Current x offset. |
| `number` | b Current y offset. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:shake(5.0, 0.3)
    local ox, oy = ov:getShakeOffset()
    print("LOverlay:getShakeOffset=" .. pair_text(ox, oy))
end
```

---

### `LOverlay:getTimeOfDay`

Returns the overlay time-of-day value.

```lua
-- signature
LOverlay:getTimeOfDay()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Current time-of-day value. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setTimeOfDay(0.75)
    print("LOverlay:getTimeOfDay=" .. ov:getTimeOfDay())
end
```

---

### `LOverlay:getVignetteStrength`

Returns overlay vignette strength.

```lua
-- signature
LOverlay:getVignetteStrength()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Current vignette strength. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setVignetteStrength(0.6)
    print("LOverlay:getVignetteStrength=" .. f2(ov:getVignetteStrength()))
end
```

---

### `LOverlay:getWater`

Returns a table describing the current water effect settings.

```lua
-- signature
LOverlay:getWater()
```

**Returns**

| Type | Description |
|------|-------------|
| `LOverlayGetWaterResult` | Water state table with enabled, wave, tint, depth, and time fields. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setWater(0.20, 1.10, 0.35)
    local w = ov:getWater()
    print("LOverlay:getWater enabled=" .. tostring(w.enabled))
    print("LOverlay:getWater wave=" .. f2(w.amplitude) .. "," .. f2(w.frequency) .. "," .. f2(w.speed))
end
```

---

### `LOverlay:getWeather`

Returns the overlay weather type name.

```lua
-- signature
LOverlay:getWeather()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Current weather type name. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setWeather("rain")
    print("LOverlay:getWeather=" .. ov:getWeather())
end
```

---

### `LOverlay:getWeatherIntensity`

Returns weather intensity for the current weather type.

```lua
-- signature
LOverlay:getWeatherIntensity()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Weather intensity value. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setWeatherIntensity(0.7)
    print("LOverlay:getWeatherIntensity=" .. f2(ov:getWeatherIntensity()))
end
```

---

### `LOverlay:getWidth`

Returns the overlay width. This method is available to Lua scripts.

```lua
-- signature
LOverlay:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Overlay width in pixels. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    print("LOverlay:getWidth=" .. ov:getWidth())
end
```

---

### `LOverlay:getWindDirection`

Returns the overlay weather wind direction.

```lua
-- signature
LOverlay:getWindDirection()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Wind direction value. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setWindDirection(0.79)
    print("LOverlay:getWindDirection=" .. f2(ov:getWindDirection()))
end
```

---

### `LOverlay:getWindSpeed`

Returns the overlay weather wind speed.

```lua
-- signature
LOverlay:getWindSpeed()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Wind speed value. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setWindSpeed(12.0)
    print("LOverlay:getWindSpeed=" .. f2(ov:getWindSpeed()))
end
```

---

### `LOverlay:isActive`

Returns whether any overlay effect is currently active.

```lua
-- signature
LOverlay:isActive()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when overlay state should render. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:triggerFlash(1, 1, 1, 0.5, 0.3)
    print("LOverlay:isActive=" .. tostring(ov:isActive()))
end
```

---

### `LOverlay:isAmbientEnabled`

Returns whether overlay ambient color rendering is enabled.

```lua
-- signature
LOverlay:isAmbientEnabled()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when ambient rendering is enabled. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setAmbientEnabled(true)
    print("LOverlay:isAmbientEnabled=" .. tostring(ov:isAmbientEnabled()))
end
```

---

### `LOverlay:isCloudShadowsEnabled`

Returns whether overlay cloud shadow rendering is enabled.

```lua
-- signature
LOverlay:isCloudShadowsEnabled()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when cloud shadow rendering is enabled. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setCloudShadows(true)
    print("LOverlay:isCloudShadowsEnabled=" .. tostring(ov:isCloudShadowsEnabled()))
    print("LOverlay:isCloudShadowsEnabled count=" .. ov:getCloudCount())
end
```

---

### `LOverlay:isFading`

Returns whether the fade overlay is active.

```lua
-- signature
LOverlay:isFading()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True while fade is active. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:triggerFade(0.0, 0.0, 0.0, 1.0, 0.4)
    print("LOverlay:isFading=" .. tostring(ov:isFading()))
end
```

---

### `LOverlay:isFilmGrainEnabled`

Returns whether overlay film grain rendering is enabled.

```lua
-- signature
LOverlay:isFilmGrainEnabled()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when film grain rendering is enabled. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setFilmGrainEnabled(true)
    print("LOverlay:isFilmGrainEnabled=" .. tostring(ov:isFilmGrainEnabled()))
end
```

---

### `LOverlay:isFlashing`

Returns whether the flash overlay is active.

```lua
-- signature
LOverlay:isFlashing()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True while the flash is active. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:triggerFlash(1, 0, 0, 1.0, 0.5)
    print("LOverlay:isFlashing=" .. tostring(ov:isFlashing()))
end
```

---

### `LOverlay:isFogEnabled`

Returns whether overlay fog rendering is enabled.

```lua
-- signature
LOverlay:isFogEnabled()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when fog rendering is enabled. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setFogEnabled(true)
    print("LOverlay:isFogEnabled=" .. tostring(ov:isFogEnabled()))
end
```

---

### `LOverlay:isHeatHazeEnabled`

Returns whether overlay heat haze rendering is enabled.

```lua
-- signature
LOverlay:isHeatHazeEnabled()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when heat haze rendering is enabled. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setHeatHazeEnabled(true)
    print("LOverlay:isHeatHazeEnabled=" .. tostring(ov:isHeatHazeEnabled()))
end
```

---

### `LOverlay:isShaking`

Returns whether the screen shake effect is active.

```lua
-- signature
LOverlay:isShaking()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True while screen shake is active. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:triggerShake(5.0, 0.5)
    print("LOverlay:isShaking=" .. tostring(ov:isShaking()))
end
```

---

### `LOverlay:isVignetteEnabled`

Returns whether overlay vignette rendering is enabled.

```lua
-- signature
LOverlay:isVignetteEnabled()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when vignette rendering is enabled. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setVignetteEnabled(true)
    print("LOverlay:isVignetteEnabled=" .. tostring(ov:isVignetteEnabled()))
end
```

---

### `LOverlay:isWeatherEnabled`

Returns whether overlay weather rendering is enabled.

```lua
-- signature
LOverlay:isWeatherEnabled()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when weather rendering is enabled. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setWeatherEnabled(true)
    print("LOverlay:isWeatherEnabled=" .. tostring(ov:isWeatherEnabled()))
end
```

---

### `LOverlay:pullAmbientFromLight`

Copies ambient color from the shared light world into this overlay.

```lua
-- signature
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
    print("LOverlay:pullAmbientFromLight=" .. rgba_text(r, g, b, a))
end
```

---

### `LOverlay:pushAmbientToLight`

Copies this overlay ambient color into the shared light world.

```lua
-- signature
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
    print("LOverlay:pushAmbientToLight=" .. rgba_text(r, g, b, a))
end
```

---

### `LOverlay:render`

Queues renderer commands for the overlay's current visual state.

```lua
-- signature
LOverlay:render()
```

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:flash(1.0, 1.0, 1.0, 0.5, 0.2)
    ov:render()
    print("LOverlay:render active=" .. tostring(ov:isActive()))
    print("LOverlay:render flashAlpha=" .. f2(ov:getFlashAlpha()))
end
```

---

### `LOverlay:resize`

Resizes the overlay target dimensions.

```lua
-- signature
LOverlay:resize(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | `number` | New width in pixels. |
| `h` | `number` | New height in pixels. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:resize(1280, 720)
    print("LOverlay:resize=" .. ov:getWidth() .. "x" .. ov:getHeight())
end
```

---

### `LOverlay:setAmbientColor`

Sets the overlay ambient color from RGBA channels.

```lua
-- signature
LOverlay:setAmbientColor(r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | `number` | Red channel. |
| `g` | `number` | Green channel. |
| `b` | `number` | Blue channel. |
| `a?` | `number` | Alpha channel, defaulting to 1.0. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setAmbientColor(0.2, 0.1, 0.3, 0.5)
    local r, g, b, a = ov:getAmbientColor()
    print("LOverlay:setAmbientColor=" .. rgba_text(r, g, b, a))
end
```

---

### `LOverlay:setAmbientEnabled`

Enables or disables overlay ambient color rendering.

```lua
-- signature
LOverlay:setAmbientEnabled(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `boolean` | New ambient enabled flag. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setAmbientEnabled(true)
    print("LOverlay:setAmbientEnabled=" .. tostring(ov:isAmbientEnabled()))
end
```

---

### `LOverlay:setCloudCount`

Sets the overlay cloud shadow count.

```lua
-- signature
LOverlay:setCloudCount(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | Cloud shadow count. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setCloudCount(12)
    print("LOverlay:setCloudCount=" .. ov:getCloudCount())
end
```

---

### `LOverlay:setCloudOpacity`

Sets cloud shadow opacity. This method is available to Lua scripts.

```lua
-- signature
LOverlay:setCloudOpacity(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | Cloud opacity value. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setCloudOpacity(0.5)
    print("LOverlay:setCloudOpacity=" .. f2(ov:getCloudOpacity()))
end
```

---

### `LOverlay:setCloudScale`

Sets cloud shadow scale. This method is available to Lua scripts.

```lua
-- signature
LOverlay:setCloudScale(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | Cloud scale value. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setCloudScale(2.0)
    print("LOverlay:setCloudScale=" .. f2(ov:getCloudScale()))
end
```

---

### `LOverlay:setCloudShadows`

Enables or disables overlay cloud shadow rendering.

```lua
-- signature
LOverlay:setCloudShadows(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `boolean` | New cloud shadow enabled flag. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setCloudShadows(true)
    print("LOverlay:setCloudShadows=" .. tostring(ov:isCloudShadowsEnabled()))
end
```

---

### `LOverlay:setCloudSpeed`

Sets cloud shadow movement speed. This method is available to Lua scripts.

```lua
-- signature
LOverlay:setCloudSpeed(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | Cloud speed value. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setCloudSpeed(0.5)
    print("LOverlay:setCloudSpeed=" .. f2(ov:getCloudSpeed()))
end
```

---

### `LOverlay:setCustomShader`

Sets or clears the custom overlay shader name.

```lua
-- signature
LOverlay:setCustomShader(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name?` | `string` | Optional shader name; nil clears the custom shader. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setCustomShader("scanlines")
    local img_with_shader = ov:drawToImage(96, 64)
    ov:setCustomShader(nil)
    local img_without_shader = ov:drawToImage(96, 64)
    print("LOverlay:setCustomShader types=" .. type(img_with_shader) .. "," .. type(img_without_shader))
end
```

---

### `LOverlay:setFilmGrainEnabled`

Enables or disables overlay film grain rendering.

```lua
-- signature
LOverlay:setFilmGrainEnabled(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `boolean` | New film grain enabled flag. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setFilmGrainEnabled(true)
    print("LOverlay:setFilmGrainEnabled=" .. tostring(ov:isFilmGrainEnabled()))
end
```

---

### `LOverlay:setFilmGrainIntensity`

Sets overlay film grain intensity.

```lua
-- signature
LOverlay:setFilmGrainIntensity(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | Film grain intensity value. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setFilmGrainIntensity(0.3)
    print("LOverlay:setFilmGrainIntensity=" .. f2(ov:getFilmGrainIntensity()))
end
```

---

### `LOverlay:setFogColor`

Sets the overlay fog color from RGBA channels.

```lua
-- signature
LOverlay:setFogColor(r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | `number` | Red channel. |
| `g` | `number` | Green channel. |
| `b` | `number` | Blue channel. |
| `a?` | `number` | Alpha channel, defaulting to 1.0. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setFogColor(0.7, 0.7, 0.8, 0.6)
    local r, g, b, a = ov:getFogColor()
    print("LOverlay:setFogColor=" .. rgba_text(r, g, b, a))
end
```

---

### `LOverlay:setFogDensity`

Sets overlay fog density. This method is available to Lua scripts.

```lua
-- signature
LOverlay:setFogDensity(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | Fog density value. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setFogDensity(0.5)
    print("LOverlay:setFogDensity=" .. f2(ov:getFogDensity()))
end
```

---

### `LOverlay:setFogEnabled`

Enables or disables overlay fog rendering.

```lua
-- signature
LOverlay:setFogEnabled(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `boolean` | New fog enabled flag. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setFogEnabled(true)
    print("LOverlay:setFogEnabled=" .. tostring(ov:isFogEnabled()))
end
```

---

### `LOverlay:setHeatHazeEnabled`

Enables or disables overlay heat haze rendering.

```lua
-- signature
LOverlay:setHeatHazeEnabled(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `boolean` | New heat haze enabled flag. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setHeatHazeEnabled(true)
    print("LOverlay:setHeatHazeEnabled=" .. tostring(ov:isHeatHazeEnabled()))
end
```

---

### `LOverlay:setHeatHazeIntensity`

Sets overlay heat haze intensity. This method is available to Lua scripts.

```lua
-- signature
LOverlay:setHeatHazeIntensity(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | Heat haze intensity value. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setHeatHazeIntensity(0.5)
    print("LOverlay:setHeatHazeIntensity=" .. f2(ov:getHeatHazeIntensity()))
end
```

---

### `LOverlay:setLightningColor`

Sets overlay lightning RGBA color.

```lua
-- signature
LOverlay:setLightningColor(r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | `number` | Red channel. |
| `g` | `number` | Green channel. |
| `b` | `number` | Blue channel. |
| `a?` | `number` | Alpha channel, defaulting to 1.0. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setLightningColor(1.0, 1.0, 0.8, 1.0)
    local r, g, b, a = ov:getLightningColor()
    print("LOverlay:setLightningColor=" .. rgba_text(r, g, b, a))
end
```

---

### `LOverlay:setTimeOfDay`

Sets the overlay time-of-day value used by ambient effects.

```lua
-- signature
LOverlay:setTimeOfDay(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | Time-of-day value stored on the overlay ambient state. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setTimeOfDay(0.5)
    print("LOverlay:setTimeOfDay=" .. ov:getTimeOfDay())
end
```

---

### `LOverlay:setVignetteEnabled`

Enables or disables overlay vignette rendering.

```lua
-- signature
LOverlay:setVignetteEnabled(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `boolean` | New vignette enabled flag. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setVignetteEnabled(true)
    print("LOverlay:setVignetteEnabled=" .. tostring(ov:isVignetteEnabled()))
end
```

---

### `LOverlay:setVignetteStrength`

Sets overlay vignette strength. This method is available to Lua scripts.

```lua
-- signature
LOverlay:setVignetteStrength(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | Vignette strength value. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setVignetteStrength(0.7)
    print("LOverlay:setVignetteStrength=" .. f2(ov:getVignetteStrength()))
end
```

---

### `LOverlay:setWater`

Enables water distortion and sets wave amplitude, frequency, and speed.

```lua
-- signature
LOverlay:setWater(amplitude, frequency, speed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `amplitude` | `number` | Water wave amplitude. |
| `frequency` | `number` | Water wave frequency. |
| `speed` | `number` | Water animation speed. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setWater(0.25, 1.25, 0.60)
    local w = ov:getWater()
    print("LOverlay:setWater enabled=" .. tostring(w.enabled))
    print("LOverlay:setWater wave=" .. f2(w.amplitude) .. "," .. f2(w.frequency) .. "," .. f2(w.speed))
end
```

---

### `LOverlay:setWaterTint`

Sets the water tint color and strength.

```lua
-- signature
LOverlay:setWaterTint(r, g, b, strength)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | `number` | Red channel. |
| `g` | `number` | Green channel. |
| `b` | `number` | Blue channel. |
| `strength` | `number` | Tint strength. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setWater(0.20, 1.10, 0.35)
    ov:setWaterTint(0.1, 0.3, 0.7, 0.8)
    local w = ov:getWater()
    print("LOverlay:setWaterTint tint=" .. f2(w.tint_r) .. "," .. f2(w.tint_g) .. "," .. f2(w.tint_b) .. "," .. f2(w.tint_strength))
end
```

---

### `LOverlay:setWeather`

Sets the overlay weather type by name.

```lua
-- signature
LOverlay:setWeather(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Weather type name recognized by the engine. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setWeather("snow")
    print("LOverlay:setWeather=" .. ov:getWeather())
end
```

---

### `LOverlay:setWeatherEnabled`

Enables or disables overlay weather rendering.

```lua
-- signature
LOverlay:setWeatherEnabled(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `boolean` | New weather enabled flag. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setWeatherEnabled(true)
    print("LOverlay:setWeatherEnabled=" .. tostring(ov:isWeatherEnabled()))
end
```

---

### `LOverlay:setWeatherIntensity`

Sets weather intensity for the current weather type.

```lua
-- signature
LOverlay:setWeatherIntensity(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | Weather intensity value. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setWeatherIntensity(0.8)
    print("LOverlay:setWeatherIntensity=" .. f2(ov:getWeatherIntensity()))
end
```

---

### `LOverlay:setWindDirection`

Sets the overlay weather wind direction.

```lua
-- signature
LOverlay:setWindDirection(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | Wind direction value. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setWindDirection(1.57)
    print("LOverlay:setWindDirection=" .. f2(ov:getWindDirection()))
end
```

---

### `LOverlay:setWindSpeed`

Sets the overlay weather wind speed.

```lua
-- signature
LOverlay:setWindSpeed(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | Wind speed value. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setWindSpeed(8.0)
    print("LOverlay:setWindSpeed=" .. f2(ov:getWindSpeed()))
end
```

---

### `LOverlay:shake`

Starts a screen shake with optional duration.

```lua
-- signature
LOverlay:shake(intensity, dur)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `intensity` | `number` | Shake intensity. |
| `dur?` | `number` | Duration in seconds, defaulting to 0.5. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:shake(8.0, 0.4)
    print("LOverlay:shake isShaking=" .. tostring(ov:isShaking()))
end
```

---

### `LOverlay:syncAmbientWithLight`

Resolves overlay and light ambient colors using a named mode and writes both stores.

```lua
-- signature
LOverlay:syncAmbientWithLight(mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | `string` | One of `light`, `overlay`, `avg`, `max`, or `min`. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:setAmbientColor(0.20, 0.10, 0.40, 0.60)
    ov:syncAmbientWithLight("overlay")

    local probe = lurek.overlay.new(800, 600)
    probe:pullAmbientFromLight()
    local r, g, b, a = probe:getAmbientColor()
    print("LOverlay:syncAmbientWithLight=" .. rgba_text(r, g, b, a))
end
```

---

### `LOverlay:triggerFade`

Starts a fade overlay toward a target alpha.

```lua
-- signature
LOverlay:triggerFade(r, g, b, target_alpha, duration)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | `number` | Red channel. |
| `g` | `number` | Green channel. |
| `b` | `number` | Blue channel. |
| `target_alpha` | `number` | Target alpha value. |
| `duration` | `number` | Fade duration in seconds. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:triggerFade(1.0, 0, 0, 0, 0.2)
    print("LOverlay:triggerFade isFading=" .. tostring(ov:isFading()))
end
```

---

### `LOverlay:triggerFlash`

Starts a screen flash with explicit RGBA color and duration.

```lua
-- signature
LOverlay:triggerFlash(r, g, b, a, duration)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | `number` | Red channel. |
| `g` | `number` | Green channel. |
| `b` | `number` | Blue channel. |
| `a` | `number` | Alpha channel. |
| `duration` | `number` | Flash duration in seconds. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:triggerFlash(1, 1, 0, 1.0, 0.2)
    print("LOverlay:triggerFlash isFlashing=" .. tostring(ov:isFlashing()))
end
```

---

### `LOverlay:triggerLightning`

Starts a lightning flash using the overlay lightning state.

```lua
-- signature
LOverlay:triggerLightning()
```

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:triggerLightning()
    print("LOverlay:triggerLightning alpha=" .. f2(ov:getLightningAlpha()))
end
```

---

### `LOverlay:triggerShake`

Starts a screen shake effect. This method is available to Lua scripts.

```lua
-- signature
LOverlay:triggerShake(intensity, duration)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `intensity` | `number` | Shake intensity. |
| `duration` | `number` | Shake duration in seconds. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:triggerShake(6.0, 0.3)
    print("LOverlay:triggerShake isShaking=" .. tostring(ov:isShaking()))
end
```

---

### `LOverlay:type`

Returns the Lua-visible type name for this overlay handle.

```lua
-- signature
LOverlay:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LOverlay`. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    print("LOverlay:type=" .. ov:type())
end
```

---

### `LOverlay:typeOf`

Returns whether this overlay handle matches a supported type name.

```lua
-- signature
LOverlay:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `Overlay` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    print("LOverlay:typeOf LOverlay=" .. tostring(ov:typeOf("LOverlay")))
end
```

---

### `LOverlay:update`

Advances overlay timers and animated effect state.

```lua
-- signature
LOverlay:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | `number` | Delta time in seconds. |

**Example**

```lua
do
    local ov = lurek.overlay.new(800, 600)
    ov:triggerShake(5.0, 1.0)
    ov:update(0.016)
    print("LOverlay:update isShaking=" .. tostring(ov:isShaking()))
end
```

---

## LScreenTransition

### `LScreenTransition:color`

Returns the transition RGBA color.

```lua
-- signature
LScreenTransition:color()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Red channel. |
| `number` | b Green channel. |
| `number` | c Blue channel. |
| `number` | d Alpha channel. |

**Example**

```lua
do
    local tr = lurek.overlay.newTransition("fade", 1.0, { 0.0, 0.0, 0.0, 1.0 })
    local r, g, b, a = tr:color()
    print("LScreenTransition:color=" .. rgba_text(r, g, b, a))
end
```

---

### `LScreenTransition:isActive`

Returns whether the transition is currently active.

```lua
-- signature
LScreenTransition:isActive()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the transition is active. |

**Example**

```lua
do
    local tr = lurek.overlay.newTransition("fade", 1.0, { 0.0, 0.0, 0.0, 1.0 })
    tr:play()
    print("LScreenTransition:isActive=" .. tostring(tr:isActive()))
end
```

---

### `LScreenTransition:isDone`

Returns whether the transition has finished.

```lua
-- signature
LScreenTransition:isDone()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the transition is complete. |

**Example**

```lua
do
    local tr = lurek.overlay.newTransition("fade", 0.2, { 0.0, 0.0, 0.0, 1.0 })
    tr:play()
    tr:update(1.0)
    print("LScreenTransition:isDone=" .. tostring(tr:isDone()))
end
```

---

### `LScreenTransition:kind`

Returns the transition kind name. This method is available to Lua scripts.

```lua
-- signature
LScreenTransition:kind()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Transition kind name. |

**Example**

```lua
do
    local tr = lurek.overlay.newTransition("iris", 1.0, { 0.0, 0.0, 0.0, 1.0 })
    print("LScreenTransition:kind=" .. tr:kind())
end
```

---

### `LScreenTransition:play`

Starts this screen transition forward from its current state.

```lua
-- signature
LScreenTransition:play()
```

**Example**

```lua
do
    local tr = lurek.overlay.newTransition("fade", 0.5, { 0.0, 0.0, 0.0, 1.0 })
    tr:play()
    print("LScreenTransition:play isActive=" .. tostring(tr:isActive()))
    print("LScreenTransition:play progress=" .. f2(tr:progress()))
end
```

---

### `LScreenTransition:progress`

Returns normalized transition progress.

```lua
-- signature
LScreenTransition:progress()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Progress value between the transition start and end. |

**Example**

```lua
do
    local tr = lurek.overlay.newTransition("fade", 1.0, { 0.0, 0.0, 0.0, 1.0 })
    tr:play()
    tr:update(0.5)
    print("LScreenTransition:progress=" .. f2(tr:progress()))
end
```

---

### `LScreenTransition:reverse`

Starts this screen transition in reverse from its current state.

```lua
-- signature
LScreenTransition:reverse()
```

**Example**

```lua
do
    local tr = lurek.overlay.newTransition("fade", 1.0, { 0.0, 0.0, 0.0, 1.0 })
    tr:reverse()
    print("LScreenTransition:reverse isActive=" .. tostring(tr:isActive()))
    print("LScreenTransition:reverse progress=" .. f2(tr:progress()))
end
```

---

### `LScreenTransition:setColor`

Sets the transition RGBA color from a numeric array table.

```lua
-- signature
LScreenTransition:setColor(color)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `color` | `table` | Numeric color table using indices 1 through 4. |

**Example**

```lua
do
    local tr = lurek.overlay.newTransition("fade", 1.0, { 0.0, 0.0, 0.0, 1.0 })
    tr:setColor({ 0.1, 0.05, 0.2, 1.0 })
    local r, g, b, a = tr:color()
    print("LScreenTransition:setColor=" .. rgba_text(r, g, b, a))
end
```

---

### `LScreenTransition:type`

Returns the Lua-visible type name for this transition handle.

```lua
-- signature
LScreenTransition:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LScreenTransition`. |

**Example**

```lua
do
    local tr = lurek.overlay.newTransition("fade", 1.0, { 0.0, 0.0, 0.0, 1.0 })
    print("LScreenTransition:type=" .. tr:type())
end
```

---

### `LScreenTransition:typeOf`

Returns whether this transition handle matches a supported type name.

```lua
-- signature
LScreenTransition:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `ScreenTransition` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local tr = lurek.overlay.newTransition("fade", 1.0, { 0.0, 0.0, 0.0, 1.0 })
    print("LScreenTransition:typeOf LScreenTransition=" .. tostring(tr:typeOf("LScreenTransition")))
end
```

---

### `LScreenTransition:update`

Advances this transition timer and returns whether it remains active.

```lua
-- signature
LScreenTransition:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | `number` | Delta time in seconds. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the transition is still active after the update. |

**Example**

```lua
do
    local tr = lurek.overlay.newTransition("fade", 1.0, { 0.0, 0.0, 0.0, 1.0 })
    tr:play()
    local still_active = tr:update(0.016)
    print("LScreenTransition:update active=" .. tostring(still_active))
    print("LScreenTransition:update progress=" .. f2(tr:progress()))
end
```

---
