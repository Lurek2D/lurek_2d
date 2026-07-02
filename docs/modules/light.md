# Light

## Purpose

Manages point, spot, and directional lights with custom decay falloffs and groups. - Coordinates convex polygon occluders, shadow masks, flicker, and transitions.

## Summary

- The `light` module is the engine's shared 2D lighting-data surface for users who need lights, occluders, shadows, and illumination behavior to remain structured before rendering.
- It lets scripts reason about lighting as scene data instead of raw draw commands by grouping light types, falloff, attenuation, blend modes, occlusion, and shadow-related state in one model.
- This matters because atmosphere, visibility, stealth cues, alarms, and scene readability often depend on several changing lights at once.
- Flicker, ramps, fades, and other transitions are part of the contract because lighting is usually dynamic rather than fixed at load time.
- Light-world organization matters too, since several systems may contribute lights and occluders to the same scene and still need one inspectable runtime authority.
- Blend and attenuation semantics are especially important because they control not only whether a light exists, but how strongly it influences surrounding space and how several lights combine visually.
- Occluder-aware behavior is equally important because lights only become useful for scene reasoning when blocking and shadow semantics are modeled alongside them.
- This lets the same subsystem support both atmosphere and gameplay readability, since visibility cues often depend on how light is shaped by world geometry rather than on color alone.
- It also gives tools a stable light-world model to inspect.
- That shared data layer matters whenever gameplay, art direction, and debugging all need to read the same light setup.
- `render` draws the final result, but `light` owns how 2D light entities, falloff, and occlusion semantics are represented together.
- Read `light` as the owner of light definitions and light-world state inside the engine.

This module primarily collaborates with `color`, `image`, `math`, `runtime`. Its responsibility should stay inside the Platform Services group rather than absorb behavior owned by those neighbors.

## API Reference

- This page is the generated API reference for this module.

## Functions

### `lurek.light.advanceFlickers`

Advances flicker animation for all indexed flickering lights.

```lua
lurek.light.advanceFlickers(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Delta time in seconds. |

**Example**

```lua
do

    local light = lurek.light.newLight(200, 200, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:addFlicker(0.5, 1.0, 4.0)
    light:setFlickerEnabled(true)
    lurek.light.advanceFlickers(0.016)
    lurek.log.info(tostring("flickers advanced"))
end
```

---

### `lurek.light.clear`

Removes all lights and occluders from the light world.

```lua
lurek.light.clear()
```

**Example**

```lua
do

    lurek.light.newLight(0, 0, 50)
    lurek.light.newLight(40, 20, 70)
    local before = lurek.light.getLightCount()
    lurek.light.clear()
    lurek.log.info(tostring("after clear: lights = " .. lurek.light.getLightCount()))
end
```

---

### `lurek.light.drawToImage`

Renders an approximate light-map preview of this world into an ImageData.

```lua
lurek.light.drawToImage(width, height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | number | Image width. |
| `height` | number | Image height. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](render.md#limagedata) | Rendered light map. |

**Example**

```lua
do

    lurek.light.clear()
    lurek.light.setAmbient(0.04, 0.04, 0.06, 1.0)
    local light = lurek.light.newLight(200, 72, 180, { shadowEnabled = true, shadowFilter = "pcf5" })
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.6)
    local occ = lurek.light.newOccluder({160, 128, 240, 128, 240, 144, 160, 144})
    local light_count = lurek.light.getLightCount()
    local occ_count = lurek.light.getOccluderCount()
    local img = lurek.light.drawToImage(400, 300)
    lurek.log.info(tostring("lurek.light.drawToImage type=" .. type(img)))
    lurek.log.info(tostring("lurek.light.drawToImage size=" .. img:getWidth() .. "x" .. img:getHeight()))
    lurek.log.info(tostring("preview lights=" .. light_count .. " occluders=" .. occ_count .. " valid=" .. tostring(occ:isValid())))
end
```

---

### `lurek.light.getAmbient`

Returns global ambient light color.

```lua
lurek.light.getAmbient()
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

    local r, g, b, a = lurek.light.getAmbient()
    local enabled = lurek.light.isEnabled()
    local count = lurek.light.getLightCount()
    local max_lights = lurek.light.getMaxLights()
    lurek.log.info(tostring("ambient") .. " " .. tostring(r) .. " " .. tostring(g) .. " " .. tostring(b) .. " " .. tostring(a))
end
```

---

### `lurek.light.getGodRayHints`

Returns directional light hints for god-ray style effects.

```lua
lurek.light.getGodRayHints()
```

**Returns**

| Type | Description |
|------|-------------|
| LLightGetGodRayHintsResult | Array table of hint records with `x`, `y`, and `angle` fields. |

**Example**

```lua
do

    lurek.light.clear()
    local light = lurek.light.newLight(120, 90, 160)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setLightType("directional")
    light:setDirection(0.75)
    local hints = lurek.light.getGodRayHints()
    lurek.log.info(tostring("god ray hints = " .. #hints))
    lurek.log.info(tostring("first hint angle = " .. hints[1].angle))
end
```

---

### `lurek.light.getGroupCount`

Returns the number of lights in a group.

```lua
lurek.light.getGroupCount(group_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `group_id` | number | Light group id. |

**Returns**

| Type | Description |
|------|-------------|
| number | Number of lights in the group. |

**Example**

```lua
do

    local a = lurek.light.newLight(0, 0, 50)
    local b = lurek.light.newLight(10, 10, 50)
    a:setGroupId(1)
    b:setGroupId(1)
    lurek.log.info(tostring("group 1 count = " .. lurek.light.getGroupCount(1)))
end
```

---

### `lurek.light.getLightCount`

Returns the number of live lights. This function is exposed to Lua scripts.

```lua
lurek.light.getLightCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Light count. |

**Example**

```lua
do

    lurek.light.clear()
    lurek.light.newLight(0, 0, 100)
    lurek.light.newLight(50, 50, 80)
    local enabled = lurek.light.isEnabled()
    lurek.log.info(tostring("lights = " .. lurek.light.getLightCount()))
end
```

---

### `lurek.light.getMaxLights`

Returns the maximum configured light count.

```lua
lurek.light.getMaxLights()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Maximum light count. |

**Example**

```lua
do

    lurek.light.setMaxLights(128)
    lurek.light.clear()
    lurek.light.newLight(32, 32, 64)
    local count = lurek.light.getLightCount()
    lurek.log.info(tostring("max lights = " .. lurek.light.getMaxLights()))
end
```

---

### `lurek.light.getNormalMapHints`

Returns light hints that reference normal maps.

```lua
lurek.light.getNormalMapHints()
```

**Returns**

| Type | Description |
|------|-------------|
| LLightGetNormalMapHintsResult | Array table of normal-map light hint records. |

**Example**

```lua
do

    lurek.light.clear()
    local light = lurek.light.newLight(80, 60, 120)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setNormalMap("assets/textures/sample_normal.png")
    light:setNormalStrength(0.8)
    local hints = lurek.light.getNormalMapHints()
    lurek.log.info(tostring("normal map hints = " .. #hints))
    lurek.log.info(tostring("first hint strength = " .. hints[1].strength))
end
```

---

### `lurek.light.getOccluderCount`

Returns the number of live occluders.

```lua
lurek.light.getOccluderCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Occluder count. |

**Example**

```lua
do

    lurek.light.clear()
    lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    lurek.light.newOccluder({20, 20, 30, 20, 30, 30, 20, 30})
    local enabled = lurek.light.isEnabled()
    lurek.log.info(tostring("occluders = " .. lurek.light.getOccluderCount()))
end
```

---

### `lurek.light.getShader`

Returns the default custom light shader for the light world.

```lua
lurek.light.getShader()
```

**Returns**

| Type | Description |
|------|-------------|
| [LShader](render.md#lshader) | Bound shader or nil. |

**Example**

```lua
do
    local active = lurek.light.getShader()
    local target = active and active:getTarget() or "nil"
    lurek.light.setShader(nil)
    lurek.log.info("[light] world shader target=" .. target)
    lurek.log.info("[light] shader available=" .. tostring(active ~= nil))
end
```

---

### `lurek.light.isEnabled`

Returns whether the shared light world is enabled.

```lua
lurek.light.isEnabled()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when lighting is enabled. |

**Example**

```lua
do

    local enabled = lurek.light.isEnabled()
    local count = lurek.light.getLightCount()
    local max_lights = lurek.light.getMaxLights()
    local r, g, b, a = lurek.light.getAmbient()
    lurek.log.info(tostring("enabled = " .. tostring(enabled)))
end
```

---

### `lurek.light.newLight`

Creates a light and applies optional light settings.

```lua
lurek.light.newLight(x, y, radius, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Light x coordinate. |
| `y` | number | Light y coordinate. |
| `radius` | number | Light radius. |
| `opts?` | table | Table of light settings. |

**Returns**

| Type | Description |
|------|-------------|
| [LLight](#llight) | New light handle. |

**Example**

```lua
do

    local light = lurek.light.newLight(400, 300, 200)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    lurek.log.info(tostring("radius = " .. light:getRadius()))
end
```

---

### `lurek.light.newOccluder`

Creates an occluder from a flat vertex coordinate table and optional settings.

```lua
lurek.light.newOccluder(vtbl, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `vtbl` | table | Flat numeric array `[x1, y1, x2, y2, ...]`. |
| `opts?` | table | Table of occluder settings. |

**Returns**

| Type | Description |
|------|-------------|
| [LOccluder](#loccluder) | New occluder handle. |

**Example**

```lua
do

    local verts = {0, 0, 100, 0, 100, 50, 0, 50}
    local occ = lurek.light.newOccluder(verts)
    occ:setPosition(8, 12)
    occ:setOpacity(0.9)
    local occluder_count = lurek.light.getOccluderCount()
    lurek.log.info(tostring("occluder valid = " .. tostring(occ:isValid())))
end
```

---

### `lurek.light.setAmbient`

Sets global ambient light color. This function is exposed to Lua scripts.

```lua
lurek.light.setAmbient(r, g, b, a)
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

    lurek.light.setAmbient(0.1, 0.1, 0.15, 1)
    local r, g, b, a = lurek.light.getAmbient()
    local enabled = lurek.light.isEnabled()
    local count = lurek.light.getLightCount()
    lurek.log.info(tostring("ambient = " .. r .. "," .. g .. "," .. b .. "," .. a))
end
```

---

### `lurek.light.setEnabled`

Enables or disables the shared light world.

```lua
lurek.light.setEnabled(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | boolean | New enabled flag. |

**Example**

```lua
do

    lurek.light.clear()
    lurek.light.newLight(64, 64, 96)
    lurek.light.setEnabled(true)
    local count = lurek.light.getLightCount()
    local max_lights = lurek.light.getMaxLights()
    lurek.log.info(tostring("light world enabled = " .. tostring(lurek.light.isEnabled())))
end
```

---

### `lurek.light.setGroupColor`

Sets color for all lights in a group.

```lua
lurek.light.setGroupColor(group_id, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `group_id` | number | Light group id. |
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a?` | number | Alpha channel, defaulting to 1.0. |

**Example**

```lua
do

    lurek.light.clear()
    local first = lurek.light.newLight(10, 10, 60)
    local second = lurek.light.newLight(30, 20, 60)
    first:setGroupId(1)
    second:setGroupId(1)
    lurek.light.setGroupColor(1, 1, 0, 0, 1)
    local r, g, b, a = first:getColor()
    lurek.log.info(tostring("group 1 count = " .. lurek.light.getGroupCount(1)))
    lurek.log.info(tostring("group 1 color = " .. r .. "," .. g .. "," .. b .. "," .. a))
end
```

---

### `lurek.light.setGroupEnabled`

Enables or disables all lights in a group.

```lua
lurek.light.setGroupEnabled(group_id, enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `group_id` | number | Light group id. |
| `enabled` | boolean | New enabled flag for the group. |

**Example**

```lua
do

    lurek.light.clear()
    local first = lurek.light.newLight(20, 20, 70)
    local second = lurek.light.newLight(40, 40, 70)
    first:setGroupId(1)
    second:setGroupId(1)
    lurek.light.setGroupEnabled(1, false)
    lurek.log.info(tostring("group 1 count = " .. lurek.light.getGroupCount(1)))
    lurek.log.info(tostring("group 1 enabled = " .. tostring(first:isEnabled())))
end
```

---

### `lurek.light.setGroupIntensity`

Sets intensity for all lights in a group.

```lua
lurek.light.setGroupIntensity(group_id, intensity)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `group_id` | number | Light group id. |
| `intensity` | number | New intensity value. |

**Example**

```lua
do

    lurek.light.clear()
    local first = lurek.light.newLight(20, 20, 70)
    local second = lurek.light.newLight(40, 40, 70)
    first:setGroupId(1)
    second:setGroupId(1)
    lurek.light.setGroupIntensity(1, 3.0)
    lurek.log.info(tostring("group 1 count = " .. lurek.light.getGroupCount(1)))
    lurek.log.info(tostring("group 1 intensity = " .. first:getIntensity()))
end
```

---

### `lurek.light.setMaxLights`

Sets the maximum configured light count, clamped to 1 through 256.

```lua
lurek.light.setMaxLights(n)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `n` | number | Requested maximum light count. |

**Example**

```lua
do

    lurek.light.setMaxLights(64)
    lurek.light.clear()
    lurek.light.newLight(48, 48, 96)
    local count = lurek.light.getLightCount()
    lurek.log.info(tostring("max lights = " .. lurek.light.getMaxLights()))
end
```

---

### `lurek.light.setShader`

Sets or clears the default custom light shader for the light world.

```lua
lurek.light.setShader(shader)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `shader?` | [LShader](render.md#lshader) | Light-target shader or nil to clear. |

**Example**

```lua
do
    local before = lurek.light.getShader()
    lurek.light.setShader(nil)
    local after = lurek.light.getShader()
    lurek.log.info("[light] world shader cleared=" .. tostring(after == nil))
    lurek.log.info("[light] previous shader=" .. tostring(before ~= nil))
end
```

---

### `lurek.light.syncAmbient`

Returns the light world's ambient color hint.

```lua
lurek.light.syncAmbient()
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

    lurek.light.setAmbient(0.2, 0.25, 0.3, 1.0)
    local r, g, b, a = lurek.light.syncAmbient()
    local enabled = lurek.light.isEnabled()
    local count = lurek.light.getLightCount()
    lurek.log.info(tostring("sync ambient = " .. r .. "," .. g .. "," .. b .. "," .. a))
end
```

---

## Module Fields

*No module-level fields documented.*

## Enums

*No module-specific enums documented.*

## Types

- [LLight](#llight)
- [LOccluder](#loccluder)

## LLight

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LLight:addFlicker`

Adds flicker from min/max intensity range and frequency.

```lua
LLight:addFlicker(min, max, hz)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min` | number | Minimum flicker range value. |
| `max` | number | Maximum flicker range value. |
| `hz` | number | Flicker frequency in hertz. |

**Example**

```lua
do

    local light = lurek.light.newLight(100, 100, 80)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:addFlicker(0.5, 1.0, 8.0)
    local speed, strength = light:getFlicker()
    lurek.log.info(tostring("flicker speed = " .. speed))
    lurek.log.info(tostring("flicker strength = " .. strength))
end
```

---

#### `LLight:clearCookie`

Clears the cookie texture path stored on this Lua light handle.

```lua
LLight:clearCookie()
```

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setCookie("content/examples/assets/images/sample_texture.png")
    light:clearCookie()
    lurek.log.info(tostring("cookie = " .. tostring(light:getCookie())))
end
```

---

#### `LLight:clearNormalMap`

Clears the normal map path used by this light.

```lua
LLight:clearNormalMap()
```

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setNormalMap("content/examples/assets/images/sample_normal.dds")
    light:clearNormalMap()
    lurek.log.info(tostring("normal map = " .. tostring(light:getNormalMap())))
end
```

---

#### `LLight:getAttenuation`

Returns this light attenuation coefficients.

```lua
LLight:getAttenuation()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Constant coefficient. |
| number | Linear coefficient. |
| number | Quadratic coefficient. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setAttenuation(1, 0.1, 0.01)
    local c, l, q = light:getAttenuation()
    lurek.log.info(tostring("attenuation c=" .. c .. " l=" .. l .. " q=" .. q))
end
```

---

#### `LLight:getBlendMode`

Returns this light blend mode string.

```lua
LLight:getBlendMode()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Blend mode `add`, `sub`, or `mix`. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setBlendMode("add")
    lurek.log.info(tostring("blend = " .. light:getBlendMode()))
end
```

---

#### `LLight:getColor`

Returns this light RGBA color. This method is available to Lua scripts.

```lua
LLight:getColor()
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

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setColor(1, 0.5, 0, 0.9)
    local r, g, b, a = light:getColor()
    lurek.log.info(tostring("color = " .. r .. "," .. g .. "," .. b .. "," .. a))
end
```

---

#### `LLight:getCookie`

Returns the cookie texture path stored on this Lua light handle.

```lua
LLight:getCookie()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Cookie texture path, or nil when absent. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setCookie("content/examples/assets/images/sample_texture.png")
    lurek.log.info(tostring("cookie = " .. light:getCookie()))
end
```

---

#### `LLight:getDirection`

Returns this light direction angle.

```lua
LLight:getDirection()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Direction angle. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setLightType("directional")
    light:setDirection(1.57)
    lurek.log.info(tostring("direction = " .. light:getDirection()))
end
```

---

#### `LLight:getEnergy`

Returns this light energy value. This method is available to Lua scripts.

```lua
LLight:getEnergy()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Energy value. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setEnergy(2.5)
    lurek.log.info(tostring("energy = " .. light:getEnergy()))
end
```

---

#### `LLight:getFalloff`

Returns this light falloff mode string.

```lua
LLight:getFalloff()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Falloff mode `linear`, `smooth`, or `constant`. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setFalloff("smooth")
    lurek.log.info(tostring("falloff = " .. light:getFalloff()))
end
```

---

#### `LLight:getFlicker`

Returns this light flicker speed and strength.

```lua
LLight:getFlicker()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Flicker speed. |
| number | Flicker strength. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setFlicker(3.0, 0.4)
    local speed, strength = light:getFlicker()
    lurek.log.info(tostring("flicker speed=" .. speed .. " strength=" .. strength))
end
```

---

#### `LLight:getGroupId`

Returns this light group id. This method is available to Lua scripts.

```lua
LLight:getGroupId()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Group id. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setGroupId(5)
    lurek.log.info(tostring("group = " .. light:getGroupId()))
end
```

---

#### `LLight:getInnerAngle`

Returns this spot light inner cone angle.

```lua
LLight:getInnerAngle()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Inner angle. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setLightType("spot")
    light:setInnerAngle(0.3)
    light:setOuterAngle(0.8)
    lurek.log.info(tostring("inner = " .. light:getInnerAngle() .. " outer = " .. light:getOuterAngle()))
end
```

---

#### `LLight:getIntensity`

Returns this light intensity. This method is available to Lua scripts.

```lua
LLight:getIntensity()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Intensity value. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setIntensity(5)
    lurek.log.info(tostring("intensity = " .. light:getIntensity()))
end
```

---

#### `LLight:getLightMask`

Returns this light's inclusion mask.

```lua
LLight:getLightMask()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Light mask bits. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setLightMask(3)
    lurek.log.info(tostring("mask = " .. light:getLightMask()))
end
```

---

#### `LLight:getLightType`

Returns this light type string. This method is available to Lua scripts.

```lua
LLight:getLightType()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Light type `point`, `directional`, or `spot`. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setLightType("spot")
    lurek.log.info(tostring("type = " .. light:getLightType()))
end
```

---

#### `LLight:getNormalMap`

Returns the normal map path used by this light.

```lua
LLight:getNormalMap()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Normal map path, or nil when absent. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setNormalMap("content/examples/assets/images/sample_normal.dds")
    lurek.log.info(tostring("normal map = " .. light:getNormalMap()))
end
```

---

#### `LLight:getNormalStrength`

Returns this light's normal map strength.

```lua
LLight:getNormalStrength()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Normal map strength. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setNormalStrength(1.5)
    lurek.log.info(tostring("normal strength = " .. light:getNormalStrength()))
end
```

---

#### `LLight:getOuterAngle`

Returns this spot light outer cone angle.

```lua
LLight:getOuterAngle()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Outer angle. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setLightType("spot")
    light:setInnerAngle(0.3)
    light:setOuterAngle(0.8)
    lurek.log.info(tostring("inner = " .. light:getInnerAngle() .. " outer = " .. light:getOuterAngle()))
end
```

---

#### `LLight:getPosition`

Returns this light position. This method is available to Lua scripts.

```lua
LLight:getPosition()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Light x coordinate. |
| number | Light y coordinate. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setPosition(200, 150)
    local x, y = light:getPosition()
    lurek.log.info(tostring("pos = " .. x .. "," .. y))
end
```

---

#### `LLight:getRadius`

Returns this light radius. This method is available to Lua scripts.

```lua
LLight:getRadius()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Radius value. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setRadius(250)
    lurek.log.info(tostring("radius = " .. light:getRadius()))
end
```

---

#### `LLight:getShader`

Returns the custom light shader bound to this light, if any.

```lua
LLight:getShader()
```

**Returns**

| Type | Description |
|------|-------------|
| [LShader](render.md#lshader) | Bound shader or nil. |

**Example**

```lua
do
    local light = lurek.light.newLight(400, 300, 180)
    local active = light:getShader()
    local target = active and active:getTarget() or "nil"
    light:setShader(nil)
    lurek.log.info("[light] light shader target=" .. target)
end
```

---

#### `LLight:getShadowColor`

Returns this light shadow RGBA color.

```lua
LLight:getShadowColor()
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

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setShadowEnabled(true)
    light:setShadowColor(0, 0, 0.1, 0.8)
    local r, g, b, a = light:getShadowColor()
    lurek.log.info(tostring("shadow color = " .. r .. "," .. g .. "," .. b .. "," .. a))
end
```

---

#### `LLight:getShadowFilter`

Returns this light shadow filter string.

```lua
LLight:getShadowFilter()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Shadow filter `none`, `pcf5`, or `pcf13`. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setShadowEnabled(true)
    light:setShadowFilter("pcf5")
    lurek.log.info(tostring("shadow filter = " .. light:getShadowFilter()))
end
```

---

#### `LLight:getShadowMask`

Returns this light's shadow receiver mask.

```lua
LLight:getShadowMask()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Shadow mask bits. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setShadowMask(7)
    lurek.log.info(tostring("shadow mask = " .. light:getShadowMask()))
end
```

---

#### `LLight:getShadowSmooth`

Returns this light shadow smoothing value.

```lua
LLight:getShadowSmooth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Shadow smoothing value. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setShadowEnabled(true)
    light:setShadowSmooth(2.0)
    lurek.log.info(tostring("shadow smooth = " .. light:getShadowSmooth()))
end
```

---

#### `LLight:getShadowSoftness`

Returns this light shadow softness value.

```lua
LLight:getShadowSoftness()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Shadow softness value. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setShadowEnabled(true)
    light:setShadowSoftness(1.5)
    lurek.log.info(tostring("shadow softness = " .. light:getShadowSoftness()))
end
```

---

#### `LLight:isEnabled`

Returns whether this light is enabled.

```lua
LLight:isEnabled()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the light is enabled. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setEnabled(false)
    lurek.log.info(tostring("enabled = " .. tostring(light:isEnabled())))
end
```

---

#### `LLight:isFlickerEnabled`

Returns whether this light flicker is enabled.

```lua
LLight:isFlickerEnabled()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when flicker is enabled. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setFlicker(2.0, 0.3)
    light:setFlickerEnabled(true)
    lurek.log.info(tostring("flicker on = " .. tostring(light:isFlickerEnabled())))
end
```

---

#### `LLight:isShadowEnabled`

Returns whether this light casts shadows.

```lua
LLight:isShadowEnabled()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when shadows are enabled. |

**Example**

```lua
do

    local light = lurek.light.newLight(200, 200, 150)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setShadowEnabled(true)
    lurek.log.info(tostring("shadows = " .. tostring(light:isShadowEnabled())))
end
```

---

#### `LLight:isValid`

Returns whether this light handle still points to a live light.

```lua
LLight:isValid()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the light still exists. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    lurek.log.info(tostring("valid = " .. tostring(light:isValid())))
    light:remove()
    lurek.log.info(tostring("valid after remove = " .. tostring(light:isValid())))
end
```

---

#### `LLight:isVolumetric`

Returns whether this light is volumetric.

```lua
LLight:isVolumetric()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when volumetric behavior is enabled. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 200)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setVolumetric(true)
    lurek.log.info(tostring("volumetric = " .. tostring(light:isVolumetric())))
end
```

---

#### `LLight:remove`

Removes this light from the shared light world.

```lua
LLight:remove()
```

**Example**

```lua
do

    local lt = lurek.light.newLight(200, 300, 150)
    lt:setColor(1.0, 0.85, 0.55, 1.0)
    lt:setIntensity(1.5)
    lurek.log.info(tostring("lights = " .. lurek.light.getLightCount()))
    lt:remove()
    lurek.log.info(tostring("after remove = " .. lurek.light.getLightCount()))
end
```

---

#### `LLight:setAttenuation`

Sets this light attenuation coefficients.

```lua
LLight:setAttenuation(c, l, q)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `c` | number | Constant coefficient. |
| `l` | number | Linear coefficient. |
| `q` | number | Quadratic coefficient. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setAttenuation(1, 0.1, 0.01)
    local c, l, q = light:getAttenuation()
    lurek.log.info(tostring("attenuation c=" .. c .. " l=" .. l .. " q=" .. q))
end
```

---

#### `LLight:setBlendMode`

Sets this light blend mode. This method is available to Lua scripts.

```lua
LLight:setBlendMode(mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | string | Blend mode `add`, `sub`, or `mix`. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setBlendMode("add")
    lurek.log.info(tostring("blend = " .. light:getBlendMode()))
end
```

---

#### `LLight:setColor`

Sets this light RGBA color. This method is available to Lua scripts.

```lua
LLight:setColor(r, g, b, a)
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

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setColor(1, 0.5, 0, 0.9)
    local r, g, b, a = light:getColor()
    lurek.log.info(tostring("color = " .. r .. "," .. g .. "," .. b .. "," .. a))
end
```

---

#### `LLight:setCookie`

Stores a cookie texture path on this Lua light handle.

```lua
LLight:setCookie(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | Cookie texture path. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setCookie("content/examples/assets/images/sample_texture.png")
    lurek.log.info(tostring("cookie = " .. light:getCookie()))
end
```

---

#### `LLight:setDirection`

Sets this light direction angle. This method is available to Lua scripts.

```lua
LLight:setDirection(dir)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dir` | number | Direction angle in radians or engine units. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setLightType("directional")
    light:setDirection(1.57)
    lurek.log.info(tostring("direction = " .. light:getDirection()))
end
```

---

#### `LLight:setEnabled`

Enables or disables this light. This method is available to Lua scripts.

```lua
LLight:setEnabled(b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `b` | boolean | New enabled flag. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setEnabled(false)
    lurek.log.info(tostring("enabled = " .. tostring(light:isEnabled())))
end
```

---

#### `LLight:setEnergy`

Sets this light energy value. This method is available to Lua scripts.

```lua
LLight:setEnergy(e)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `e` | number | Energy value. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setEnergy(2.5)
    lurek.log.info(tostring("energy = " .. light:getEnergy()))
end
```

---

#### `LLight:setFalloff`

Sets this light falloff mode. This method is available to Lua scripts.

```lua
LLight:setFalloff(mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | string | Falloff mode `linear`, `smooth`, or `constant`. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setFalloff("smooth")
    lurek.log.info(tostring("falloff = " .. light:getFalloff()))
end
```

---

#### `LLight:setFlicker`

Configures flicker speed and strength for this light.

```lua
LLight:setFlicker(speed, strength)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `speed` | number | Flicker speed. |
| `strength` | number | Flicker strength. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setFlicker(3.0, 0.4)
    local speed, strength = light:getFlicker()
    lurek.log.info(tostring("flicker speed=" .. speed .. " strength=" .. strength))
end
```

---

#### `LLight:setFlickerEnabled`

Enables or disables this light flicker state.

```lua
LLight:setFlickerEnabled(b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `b` | boolean | New flicker enabled flag. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setFlicker(2.0, 0.3)
    light:setFlickerEnabled(true)
    lurek.log.info(tostring("flicker on = " .. tostring(light:isFlickerEnabled())))
end
```

---

#### `LLight:setGroupId`

Sets this light group id. This method is available to Lua scripts.

```lua
LLight:setGroupId(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Group id. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setGroupId(5)
    lurek.log.info(tostring("group = " .. light:getGroupId()))
end
```

---

#### `LLight:setInnerAngle`

Sets this spot light inner cone angle.

```lua
LLight:setInnerAngle(a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `a` | number | Inner angle. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setLightType("spot")
    light:setInnerAngle(0.3)
    light:setOuterAngle(0.8)
    lurek.log.info(tostring("inner = " .. light:getInnerAngle() .. " outer = " .. light:getOuterAngle()))
end
```

---

#### `LLight:setIntensity`

Sets this light intensity. This method is available to Lua scripts.

```lua
LLight:setIntensity(i)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `i` | number | Intensity value. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setIntensity(5)
    lurek.log.info(tostring("intensity = " .. light:getIntensity()))
end
```

---

#### `LLight:setLightMask`

Sets this light's inclusion mask. This method is available to Lua scripts.

```lua
LLight:setLightMask(mask)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mask` | number | Light mask bits. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setLightMask(3)
    lurek.log.info(tostring("mask = " .. light:getLightMask()))
end
```

---

#### `LLight:setLightType`

Sets this light type. This method is available to Lua scripts.

```lua
LLight:setLightType(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | string | Light type `point`, `directional`, or `spot`. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setLightType("spot")
    lurek.log.info(tostring("type = " .. light:getLightType()))
end
```

---

#### `LLight:setNormalMap`

Sets the normal map path used by this light.

```lua
LLight:setNormalMap(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | Normal map path. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setNormalMap("content/examples/assets/images/sample_normal.dds")
    lurek.log.info(tostring("normal map = " .. light:getNormalMap()))
end
```

---

#### `LLight:setNormalStrength`

Sets this light's normal map strength.

```lua
LLight:setNormalStrength(strength)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `strength` | number | Normal map strength. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setNormalStrength(1.5)
    lurek.log.info(tostring("normal strength = " .. light:getNormalStrength()))
end
```

---

#### `LLight:setOuterAngle`

Sets this spot light outer cone angle.

```lua
LLight:setOuterAngle(a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `a` | number | Outer angle. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setLightType("spot")
    light:setInnerAngle(0.3)
    light:setOuterAngle(0.8)
    lurek.log.info(tostring("inner = " .. light:getInnerAngle() .. " outer = " .. light:getOuterAngle()))
end
```

---

#### `LLight:setPosition`

Sets this light position. This method is available to Lua scripts.

```lua
LLight:setPosition(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Light x coordinate. |
| `y` | number | Light y coordinate. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setPosition(200, 150)
    local x, y = light:getPosition()
    lurek.log.info(tostring("pos = " .. x .. "," .. y))
end
```

---

#### `LLight:setRadius`

Sets this light radius. This method is available to Lua scripts.

```lua
LLight:setRadius(r)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | number | Radius value. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setRadius(250)
    lurek.log.info(tostring("radius = " .. light:getRadius()))
end
```

---

#### `LLight:setShader`

Sets or clears the custom light-contribution shader for this light.

```lua
LLight:setShader(shader)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `shader?` | [LShader](render.md#lshader) | Light-target shader or nil to clear. |

**Example**

```lua
do
    local light = lurek.light.newLight(400, 300, 180)
    light:setShader(nil)
    local active = light:getShader()
    lurek.log.info("[light] light shader cleared=" .. tostring(active == nil))
    lurek.log.info("[light] radius=" .. tostring(light:getRadius()))
end
```

---

#### `LLight:setShadowColor`

Sets this light shadow RGBA color. This method is available to Lua scripts.

```lua
LLight:setShadowColor(r, g, b, a)
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

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setShadowEnabled(true)
    light:setShadowColor(0, 0, 0.1, 0.8)
    local r, g, b, a = light:getShadowColor()
    lurek.log.info(tostring("shadow color = " .. r .. "," .. g .. "," .. b .. "," .. a))
end
```

---

#### `LLight:setShadowEnabled`

Enables or disables shadow casting for this light.

```lua
LLight:setShadowEnabled(b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `b` | boolean | New shadow enabled flag. |

**Example**

```lua
do

    local light = lurek.light.newLight(200, 200, 150)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setShadowEnabled(true)
    lurek.log.info(tostring("shadows = " .. tostring(light:isShadowEnabled())))
end
```

---

#### `LLight:setShadowFilter`

Sets this light shadow filter. This method is available to Lua scripts.

```lua
LLight:setShadowFilter(filter)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `filter` | string | Shadow filter `none`, `pcf5`, or `pcf13`. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setShadowEnabled(true)
    light:setShadowFilter("pcf5")
    lurek.log.info(tostring("shadow filter = " .. light:getShadowFilter()))
end
```

---

#### `LLight:setShadowMask`

Sets this light's shadow receiver mask.

```lua
LLight:setShadowMask(mask)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mask` | number | Shadow mask bits. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setShadowMask(7)
    lurek.log.info(tostring("shadow mask = " .. light:getShadowMask()))
end
```

---

#### `LLight:setShadowSmooth`

Sets this light shadow smoothing value.

```lua
LLight:setShadowSmooth(s)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `s` | number | Shadow smoothing value. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setShadowEnabled(true)
    light:setShadowSmooth(2.0)
    lurek.log.info(tostring("shadow smooth = " .. light:getShadowSmooth()))
end
```

---

#### `LLight:setShadowSoftness`

Sets this light shadow softness value.

```lua
LLight:setShadowSoftness(softness)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `softness` | number | Shadow softness value. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setShadowEnabled(true)
    light:setShadowSoftness(1.5)
    lurek.log.info(tostring("shadow softness = " .. light:getShadowSoftness()))
end
```

---

#### `LLight:setVolumetric`

Enables or disables volumetric behavior for this light.

```lua
LLight:setVolumetric(b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `b` | boolean | New volumetric flag. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 200)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setVolumetric(true)
    lurek.log.info(tostring("volumetric = " .. tostring(light:isVolumetric())))
end
```

---

#### `LLight:stopTransition`

Stops and clears this light's active transition.

```lua
LLight:stopTransition()
```

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:transitionTo({color = {0, 0, 1, 1}, intensity = 3.0, radius = 200}, 2.0)
    light:stopTransition()
    lurek.log.info(tostring("stopped, progress = " .. light:transitionProgress()))
end
```

---

#### `LLight:transitionProgress`

Returns active transition progress or 1.0 when no transition is active.

```lua
LLight:transitionProgress()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Transition progress. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:transitionTo({color = {0, 0, 1, 1}, intensity = 3.0, radius = 200}, 2.0)
    light:updateTransition(0.5)
    lurek.log.info(tostring("progress = " .. light:transitionProgress()))
end
```

---

#### `LLight:transitionTo`

Starts a transition toward target color, intensity, and radius values.

```lua
LLight:transitionTo(target, duration)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | table | Target table with optional `color`, `intensity`, and `radius` fields. |
| `duration` | number | Transition duration in seconds. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setColor(1, 0, 0, 1)
    light:setIntensity(1.0)
    light:transitionTo({color = {0, 0, 1, 1}, intensity = 3.0, radius = 200}, 2.0)
    lurek.log.info(tostring("progress = " .. light:transitionProgress()))
end
```

---

#### `LLight:type`

Returns the Lua-visible type name for this light handle.

```lua
LLight:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LLight](#llight)`. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    lurek.log.info(tostring("type = " .. light:type()))
    lurek.log.info(tostring("is LLight = " .. tostring(light:typeOf("LLight"))))
end
```

---

#### `LLight:typeOf`

Returns whether this light handle matches a supported type name.

```lua
LLight:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LLight](#llight)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    lurek.log.info(tostring("type = " .. light:type()))
    lurek.log.info(tostring("is LLight = " .. tostring(light:typeOf("LLight"))))
    lurek.log.info(tostring("is Object = " .. tostring(light:typeOf("LObject"))))
end
```

---

#### `LLight:updateTransition`

Advances this light's active transition and applies interpolated values.

```lua
LLight:updateTransition(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Delta time in seconds. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a transition value was applied. |

**Example**

```lua
do

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:transitionTo({color = {0, 0, 1, 1}, intensity = 3.0, radius = 200}, 2.0)
    local applied = light:updateTransition(0.5)
    lurek.log.info(tostring("applied = " .. tostring(applied)))
end
```

---

## LOccluder

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LOccluder:getLightMask`

Returns this occluder's light mask.

```lua
LOccluder:getLightMask()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Light mask bits. |

**Example**

```lua
do

    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    occ:setPosition(8, 12)
    occ:setOpacity(0.9)
    local occluder_count = lurek.light.getOccluderCount()
    occ:setLightMask(5)
    lurek.log.info(tostring("occ mask = " .. occ:getLightMask()))
end
```

---

#### `LOccluder:getOpacity`

Returns this occluder opacity. This method is available to Lua scripts.

```lua
LOccluder:getOpacity()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Opacity value. |

**Example**

```lua
do

    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    occ:setPosition(8, 12)
    occ:setOpacity(0.9)
    local occluder_count = lurek.light.getOccluderCount()
    occ:setOpacity(0.6)
    lurek.log.info(tostring("opacity = " .. occ:getOpacity()))
end
```

---

#### `LOccluder:getPosition`

Returns this occluder position offset.

```lua
LOccluder:getPosition()
```

**Returns**

| Type | Description |
|------|-------------|
| number | X coordinate. |
| number | Y coordinate. |

**Example**

```lua
do

    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    occ:setPosition(8, 12)
    occ:setOpacity(0.9)
    local occluder_count = lurek.light.getOccluderCount()
    occ:setPosition(50, 75)
    local x, y = occ:getPosition()
    lurek.log.info(tostring("occ pos = " .. x .. "," .. y))
end
```

---

#### `LOccluder:getVertices`

Returns this occluder's flat vertex coordinate list.

```lua
LOccluder:getVertices()
```

**Returns**

| Type | Description |
|------|-------------|
| number[] | Flat numeric array `[x1, y1, x2, y2, ...]`. |

**Example**

```lua
do

    local occ = lurek.light.newOccluder({0, 0, 20, 0, 20, 20, 0, 20})
    occ:setPosition(8, 12)
    occ:setOpacity(0.9)
    local occluder_count = lurek.light.getOccluderCount()
    occ:setVertices({0, 0, 30, 0, 30, 30, 0, 30})
    local v = occ:getVertices()
    lurek.log.info(tostring("vertex count = " .. #v / 2))
end
```

---

#### `LOccluder:isEnabled`

Returns whether this occluder is enabled.

```lua
LOccluder:isEnabled()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when enabled. |

**Example**

```lua
do

    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    occ:setPosition(8, 12)
    occ:setOpacity(0.9)
    local occluder_count = lurek.light.getOccluderCount()
    occ:setEnabled(false)
    lurek.log.info(tostring("enabled = " .. tostring(occ:isEnabled())))
end
```

---

#### `LOccluder:isValid`

Returns whether this occluder handle still points to a live occluder.

```lua
LOccluder:isValid()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the occluder still exists. |

**Example**

```lua
do

    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    occ:setPosition(8, 12)
    occ:setOpacity(0.9)
    local occluder_count = lurek.light.getOccluderCount()
    lurek.log.info(tostring("valid = " .. tostring(occ:isValid())))
    occ:remove()
    lurek.log.info(tostring("valid after remove = " .. tostring(occ:isValid())))
end
```

---

#### `LOccluder:remove`

Removes this occluder from the shared light world.

```lua
LOccluder:remove()
```

**Example**

```lua
do

    local vtbl = { 0, 0, 100, 0, 100, 100, 0, 100 }
    local occ = lurek.light.newOccluder(vtbl)
    occ:setPosition(8, 12)
    occ:setOpacity(0.9)
    local occluder_count = lurek.light.getOccluderCount()
    lurek.log.info(tostring("occluders = " .. lurek.light.getOccluderCount()))
    occ:remove()
    lurek.log.info(tostring("after remove = " .. lurek.light.getOccluderCount()))
end
```

---

#### `LOccluder:setEnabled`

Enables or disables this occluder.

```lua
LOccluder:setEnabled(b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `b` | boolean | New enabled flag. |

**Example**

```lua
do

    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    occ:setPosition(8, 12)
    occ:setOpacity(0.9)
    local occluder_count = lurek.light.getOccluderCount()
    occ:setEnabled(false)
    lurek.log.info(tostring("enabled = " .. tostring(occ:isEnabled())))
end
```

---

#### `LOccluder:setLightMask`

Sets this occluder's light mask. This method is available to Lua scripts.

```lua
LOccluder:setLightMask(mask)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mask` | number | Light mask bits. |

**Example**

```lua
do

    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    occ:setPosition(8, 12)
    occ:setOpacity(0.9)
    local occluder_count = lurek.light.getOccluderCount()
    occ:setLightMask(5)
    lurek.log.info(tostring("occ mask = " .. occ:getLightMask()))
end
```

---

#### `LOccluder:setOpacity`

Sets this occluder opacity. This method is available to Lua scripts.

```lua
LOccluder:setOpacity(o)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `o` | number | Opacity value. |

**Example**

```lua
do

    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    occ:setPosition(8, 12)
    occ:setOpacity(0.9)
    local occluder_count = lurek.light.getOccluderCount()
    occ:setOpacity(0.6)
    lurek.log.info(tostring("opacity = " .. occ:getOpacity()))
end
```

---

#### `LOccluder:setPosition`

Sets this occluder position offset.

```lua
LOccluder:setPosition(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X coordinate. |
| `y` | number | Y coordinate. |

**Example**

```lua
do

    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    occ:setPosition(8, 12)
    occ:setOpacity(0.9)
    local occluder_count = lurek.light.getOccluderCount()
    occ:setPosition(50, 75)
    local x, y = occ:getPosition()
    lurek.log.info(tostring("occ pos = " .. x .. "," .. y))
end
```

---

#### `LOccluder:setVertices`

Replaces this occluder's flat vertex coordinate list.

```lua
LOccluder:setVertices(tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tbl` | table | Flat numeric array `[x1, y1, x2, y2, ...]`. |

**Example**

```lua
do

    local occ = lurek.light.newOccluder({0, 0, 20, 0, 20, 20, 0, 20})
    occ:setPosition(8, 12)
    occ:setOpacity(0.9)
    local occluder_count = lurek.light.getOccluderCount()
    occ:setVertices({0, 0, 30, 0, 30, 30, 0, 30})
    local v = occ:getVertices()
    lurek.log.info(tostring("vertex count = " .. #v / 2))
end
```

---

#### `LOccluder:type`

Returns the Lua-visible type name for this occluder handle.

```lua
LOccluder:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LOccluder](#loccluder)`. |

**Example**

```lua
do

    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    occ:setPosition(8, 12)
    occ:setOpacity(0.9)
    local occluder_count = lurek.light.getOccluderCount()
    lurek.log.info(tostring("type = " .. occ:type()))
    lurek.log.info(tostring("is LOccluder = " .. tostring(occ:typeOf("LOccluder"))))
end
```

---

#### `LOccluder:typeOf`

Returns whether this occluder handle matches a supported type name.

```lua
LOccluder:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LOccluder](#loccluder)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do

    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    occ:setPosition(8, 12)
    occ:setOpacity(0.9)
    local occluder_count = lurek.light.getOccluderCount()
    lurek.log.info(tostring("type = " .. occ:type()))
    lurek.log.info(tostring("is LOccluder = " .. tostring(occ:typeOf("LOccluder"))))
    lurek.log.info(tostring("is Object = " .. tostring(occ:typeOf("LObject"))))
end
```

---
