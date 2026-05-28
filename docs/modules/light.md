# Light

- The `light` module is a comprehensive Platform Services tier component that provides a robust 2D lighting data model for Lurek2D.

It is responsible for managing point, spot, and area lights, alongside shadow-casting occluders, to create dynamic and atmospheric scene illumination. At its core, the `Light2D` struct encapsulates the properties of an individual light source, including its position, color, radius, intensity, cone angles for spot behavior, falloff curves, and procedural flicker configurations. The module is intentionally designed as a pure data management layer—it handles the logical state, grouping, and animation of lights, while the actual GPU rasterization and shader execution are deferred entirely to the `render` module.

The central orchestration of these lighting primitives is handled by the `LightWorld`. This scene-level container holds pools of active lights and `Occluder` shapes (convex polygons that block light propagation to generate shadows). It provides an efficient slotmap-backed architecture for adding, removing, and querying these entities, as well as applying batch operations like intensity or color changes across named light groups. The lighting model supports sophisticated attenuation, allowing for quadratic, linear, and inverse-square falloff models, alongside custom coefficient tuples to precisely control how light decays over distance. Blend modes (additive, subtractive, alpha-mix) dictate how each light composited into the final accumulation buffer.

Beyond static illumination, the module excels in dynamic effects. It features a robust `FlickerConfig` system that drives procedural, noise-based intensity variation over time—ideal for simulating torches, candles, or unstable neon signs. To ensure optimal performance, the flicker system utilizes a lazy-indexed advance loop that only evaluates lights with active flicker states. The module also supports time-based linear transitions for smoothly animating light color, intensity, and radius. Additionally, it offers advanced shadow filtering presets (from hard shadows to various PCF soft-shadow kernels) and normal-map integration for surface shading. The entire feature set is extensively exposed to the scripting environment via the `lurek.light.*` API.

## Functions

### `lurek.light.advanceFlickers`

Advances flicker animation for all indexed flickering lights.

```lua
-- signature
lurek.light.advanceFlickers(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | `number` | Delta time in seconds. |

**Example**

```lua
do
    local light = lurek.light.newLight(200, 200, 100)
    light:addFlicker(0.5, 1.0, 4.0)
    light:setFlickerEnabled(true)
    lurek.light.advanceFlickers(0.016)
    print("flickers advanced")
end
```

---

### `lurek.light.clear`

Removes all lights and occluders from the light world.

```lua
-- signature
lurek.light.clear()
```

**Example**

```lua
do
    lurek.light.newLight(0, 0, 50)
    lurek.light.clear()
    print("after clear: lights = " .. lurek.light.getLightCount())
end
```

---

### `lurek.light.drawToImage`

Renders an approximate light-map preview of this world into an ImageData.

```lua
-- signature
lurek.light.drawToImage(width, height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | `number` | Image width. |
| `height` | `number` | Image height. |

**Returns**

| Type | Description |
|------|-------------|
| `LImageData` | Rendered light map. |

**Example**

```lua
do
    lurek.light.clear()
    local light = lurek.light.newLight(200, 150, 120)
    light:setColor(1.0, 0.9, 0.6, 1.0)
    local img = lurek.light.drawToImage(400, 300)
    print("lurek.light.drawToImage type=" .. type(img))
    print("lurek.light.drawToImage hasLight = " .. tostring(light:isValid()))
end
```

---

### `lurek.light.getAmbient`

Returns global ambient light color.

```lua
-- signature
lurek.light.getAmbient()
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
    local r, g, b, a = lurek.light.getAmbient()
    print("ambient", r, g, b, a)
end
```

---

### `lurek.light.getGodRayHints`

Returns directional light hints for god-ray style effects.

```lua
-- signature
lurek.light.getGodRayHints()
```

**Returns**

| Type | Description |
|------|-------------|
| `LightGetGodRayHintsResult` | Array table of hint records with `x`, `y`, and `angle` fields. |

**Example**

```lua
do
    lurek.light.clear()
    local light = lurek.light.newLight(120, 90, 160)
    light:setLightType("directional")
    light:setDirection(0.75)
    local hints = lurek.light.getGodRayHints()
    print("god ray hints = " .. #hints)
    print("first hint angle = " .. hints[1].angle)
end
```

---

### `lurek.light.getGroupCount`

Returns the number of lights in a group.

```lua
-- signature
lurek.light.getGroupCount(group_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `group_id` | `number` | Light group id. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Number of lights in the group. |

**Example**

```lua
do
    local a = lurek.light.newLight(0, 0, 50)
    local b = lurek.light.newLight(10, 10, 50)
    a:setGroupId(1)
    b:setGroupId(1)
    print("group 1 count = " .. lurek.light.getGroupCount(1))
end
```

---

### `lurek.light.getLightCount`

Returns the number of live lights. This function is exposed to Lua scripts.

```lua
-- signature
lurek.light.getLightCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Light count. |

**Example**

```lua
do
    lurek.light.clear()
    lurek.light.newLight(0, 0, 100)
    lurek.light.newLight(50, 50, 80)
    print("lights = " .. lurek.light.getLightCount())
end
```

---

### `lurek.light.getMaxLights`

Returns the maximum configured light count.

```lua
-- signature
lurek.light.getMaxLights()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Maximum light count. |

**Example**

```lua
do
    lurek.light.setMaxLights(128)
    print("max lights = " .. lurek.light.getMaxLights())
end
```

---

### `lurek.light.getNormalMapHints`

Returns light hints that reference normal maps.

```lua
-- signature
lurek.light.getNormalMapHints()
```

**Returns**

| Type | Description |
|------|-------------|
| `LightGetNormalMapHintsResult` | Array table of normal-map light hint records. |

**Example**

```lua
do
    lurek.light.clear()
    local light = lurek.light.newLight(80, 60, 120)
    light:setNormalMap("assets/textures/sample_normal.png")
    light:setNormalStrength(0.8)
    local hints = lurek.light.getNormalMapHints()
    print("normal map hints = " .. #hints)
    print("first hint strength = " .. hints[1].strength)
end
```

---

### `lurek.light.getOccluderCount`

Returns the number of live occluders.

```lua
-- signature
lurek.light.getOccluderCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Occluder count. |

**Example**

```lua
do
    lurek.light.clear()
    lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    lurek.light.newOccluder({20, 20, 30, 20, 30, 30, 20, 30})
    print("occluders = " .. lurek.light.getOccluderCount())
end
```

---

### `lurek.light.isEnabled`

Returns whether the shared light world is enabled.

```lua
-- signature
lurek.light.isEnabled()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when lighting is enabled. |

**Example**

```lua
do
    local enabled = lurek.light.isEnabled()
    print("enabled = " .. tostring(enabled))
end
```

---

### `lurek.light.newLight`

Creates a light and applies optional light settings.

```lua
-- signature
lurek.light.newLight(x, y, radius, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | Light x coordinate. |
| `y` | `number` | Light y coordinate. |
| `radius` | `number` | Light radius. |
| `opts?` | `table` | Table of light settings. |

**Returns**

| Type | Description |
|------|-------------|
| `LLight` | New light handle. |

**Example**

```lua
do
    local light = lurek.light.newLight(400, 300, 200)
    print("radius = " .. light:getRadius())
end
```

---

### `lurek.light.newOccluder`

Creates an occluder from a flat vertex coordinate table and optional settings.

```lua
-- signature
lurek.light.newOccluder(vtbl, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `vtbl` | `table` | Flat numeric array `[x1, y1, x2, y2, ...]`. |
| `opts?` | `table` | Table of occluder settings. |

**Returns**

| Type | Description |
|------|-------------|
| `LOccluder` | New occluder handle. |

**Example**

```lua
do
    local verts = {0, 0, 100, 0, 100, 50, 0, 50}
    local occ = lurek.light.newOccluder(verts)
    print("occluder valid = " .. tostring(occ:isValid()))
end
```

---

### `lurek.light.setAmbient`

Sets global ambient light color. This function is exposed to Lua scripts.

```lua
-- signature
lurek.light.setAmbient(r, g, b, a)
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
    lurek.light.setAmbient(0.1, 0.1, 0.15, 1)
    local r, g, b, a = lurek.light.getAmbient()
    print("ambient = " .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

### `lurek.light.setEnabled`

Enables or disables the shared light world.

```lua
-- signature
lurek.light.setEnabled(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | `boolean` | New enabled flag. |

**Example**

```lua
do
    lurek.light.setEnabled(true)
    print("light world enabled = " .. tostring(lurek.light.isEnabled()))
end
```

---

### `lurek.light.setGroupColor`

Sets color for all lights in a group.

```lua
-- signature
lurek.light.setGroupColor(group_id, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `group_id` | `number` | Light group id. |
| `r` | `number` | Red channel. |
| `g` | `number` | Green channel. |
| `b` | `number` | Blue channel. |
| `a?` | `number` | Alpha channel, defaulting to 1.0. |

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
    print("group 1 count = " .. lurek.light.getGroupCount(1))
    print("group 1 color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

### `lurek.light.setGroupEnabled`

Enables or disables all lights in a group.

```lua
-- signature
lurek.light.setGroupEnabled(group_id, enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `group_id` | `number` | Light group id. |
| `enabled` | `boolean` | New enabled flag for the group. |

**Example**

```lua
do
    lurek.light.clear()
    local first = lurek.light.newLight(20, 20, 70)
    local second = lurek.light.newLight(40, 40, 70)
    first:setGroupId(1)
    second:setGroupId(1)
    lurek.light.setGroupEnabled(1, false)
    print("group 1 count = " .. lurek.light.getGroupCount(1))
    print("group 1 enabled = " .. tostring(first:isEnabled()))
end
```

---

### `lurek.light.setGroupIntensity`

Sets intensity for all lights in a group.

```lua
-- signature
lurek.light.setGroupIntensity(group_id, intensity)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `group_id` | `number` | Light group id. |
| `intensity` | `number` | New intensity value. |

**Example**

```lua
do
    lurek.light.clear()
    local first = lurek.light.newLight(20, 20, 70)
    local second = lurek.light.newLight(40, 40, 70)
    first:setGroupId(1)
    second:setGroupId(1)
    lurek.light.setGroupIntensity(1, 3.0)
    print("group 1 count = " .. lurek.light.getGroupCount(1))
    print("group 1 intensity = " .. first:getIntensity())
end
```

---

### `lurek.light.setMaxLights`

Sets the maximum configured light count, clamped to 1 through 256.

```lua
-- signature
lurek.light.setMaxLights(n)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `n` | `number` | Requested maximum light count. |

**Example**

```lua
do
    lurek.light.setMaxLights(64)
    print("max lights = " .. lurek.light.getMaxLights())
end
```

---

### `lurek.light.syncAmbient`

Returns the light world's ambient color hint.

```lua
-- signature
lurek.light.syncAmbient()
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
    lurek.light.setAmbient(0.2, 0.25, 0.3, 1.0)
    local r, g, b, a = lurek.light.syncAmbient()
    print("sync ambient = " .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

## LLight

### `LLight:addFlicker`

Adds flicker from min/max intensity range and frequency.

```lua
-- signature
LLight:addFlicker(min, max, hz)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min` | `number` | Minimum flicker range value. |
| `max` | `number` | Maximum flicker range value. |
| `hz` | `number` | Flicker frequency in hertz. |

**Example**

```lua
do
    local light = lurek.light.newLight(100, 100, 80)
    light:addFlicker(0.5, 1.0, 8.0)
    local speed, strength = light:getFlicker()
    print("flicker speed = " .. speed)
    print("flicker strength = " .. strength)
end
```

---

### `LLight:clearCookie`

Clears the cookie texture path stored on this Lua light handle.

```lua
-- signature
LLight:clearCookie()
```

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setCookie("content/examples/assets/images/sample_texture.png")
    light:clearCookie()
    print("cookie = " .. tostring(light:getCookie()))
end
```

---

### `LLight:clearNormalMap`

Clears the normal map path used by this light.

```lua
-- signature
LLight:clearNormalMap()
```

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setNormalMap("content/examples/assets/images/sample_normal.dds")
    light:clearNormalMap()
    print("normal map = " .. tostring(light:getNormalMap()))
end
```

---

### `LLight:getAttenuation`

Returns this light attenuation coefficients.

```lua
-- signature
LLight:getAttenuation()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Constant coefficient. |
| `number` | b Linear coefficient. |
| `number` | c Quadratic coefficient. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setAttenuation(1, 0.1, 0.01)
    local c, l, q = light:getAttenuation()
    print("attenuation c=" .. c .. " l=" .. l .. " q=" .. q)
end
```

---

### `LLight:getBlendMode`

Returns this light blend mode string.

```lua
-- signature
LLight:getBlendMode()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Blend mode `add`, `sub`, or `mix`. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setBlendMode("add")
    print("blend = " .. light:getBlendMode())
end
```

---

### `LLight:getColor`

Returns this light RGBA color. This method is available to Lua scripts.

```lua
-- signature
LLight:getColor()
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
    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1, 0.5, 0, 0.9)
    local r, g, b, a = light:getColor()
    print("color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

### `LLight:getCookie`

Returns the cookie texture path stored on this Lua light handle.

```lua
-- signature
LLight:getCookie()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Cookie texture path, or nil when absent. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setCookie("content/examples/assets/images/sample_texture.png")
    print("cookie = " .. light:getCookie())
end
```

---

### `LLight:getDirection`

Returns this light direction angle.

```lua
-- signature
LLight:getDirection()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Direction angle. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setLightType("directional")
    light:setDirection(1.57)
    print("direction = " .. light:getDirection())
end
```

---

### `LLight:getEnergy`

Returns this light energy value. This method is available to Lua scripts.

```lua
-- signature
LLight:getEnergy()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Energy value. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setEnergy(2.5)
    print("energy = " .. light:getEnergy())
end
```

---

### `LLight:getFalloff`

Returns this light falloff mode string.

```lua
-- signature
LLight:getFalloff()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Falloff mode `linear`, `smooth`, or `constant`. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setFalloff("smooth")
    print("falloff = " .. light:getFalloff())
end
```

---

### `LLight:getFlicker`

Returns this light flicker speed and strength.

```lua
-- signature
LLight:getFlicker()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Flicker speed. |
| `number` | b Flicker strength. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setFlicker(3.0, 0.4)
    local speed, strength = light:getFlicker()
    print("flicker speed=" .. speed .. " strength=" .. strength)
end
```

---

### `LLight:getGroupId`

Returns this light group id. This method is available to Lua scripts.

```lua
-- signature
LLight:getGroupId()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Group id. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setGroupId(5)
    print("group = " .. light:getGroupId())
end
```

---

### `LLight:getInnerAngle`

Returns this spot light inner cone angle.

```lua
-- signature
LLight:getInnerAngle()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Inner angle. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setLightType("spot")
    light:setInnerAngle(0.3)
    light:setOuterAngle(0.8)
    print("inner = " .. light:getInnerAngle() .. " outer = " .. light:getOuterAngle())
end
```

---

### `LLight:getIntensity`

Returns this light intensity. This method is available to Lua scripts.

```lua
-- signature
LLight:getIntensity()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Intensity value. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setIntensity(5)
    print("intensity = " .. light:getIntensity())
end
```

---

### `LLight:getLightMask`

Returns this light's inclusion mask.

```lua
-- signature
LLight:getLightMask()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Light mask bits. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setLightMask(3)
    print("mask = " .. light:getLightMask())
end
```

---

### `LLight:getLightType`

Returns this light type string. This method is available to Lua scripts.

```lua
-- signature
LLight:getLightType()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Light type `point`, `directional`, or `spot`. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setLightType("spot")
    print("type = " .. light:getLightType())
end
```

---

### `LLight:getNormalMap`

Returns the normal map path used by this light.

```lua
-- signature
LLight:getNormalMap()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Normal map path, or nil when absent. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setNormalMap("content/examples/assets/images/sample_normal.dds")
    print("normal map = " .. light:getNormalMap())
end
```

---

### `LLight:getNormalStrength`

Returns this light's normal map strength.

```lua
-- signature
LLight:getNormalStrength()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Normal map strength. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setNormalStrength(1.5)
    print("normal strength = " .. light:getNormalStrength())
end
```

---

### `LLight:getOuterAngle`

Returns this spot light outer cone angle.

```lua
-- signature
LLight:getOuterAngle()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Outer angle. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setLightType("spot")
    light:setInnerAngle(0.3)
    light:setOuterAngle(0.8)
    print("inner = " .. light:getInnerAngle() .. " outer = " .. light:getOuterAngle())
end
```

---

### `LLight:getPosition`

Returns this light position. This method is available to Lua scripts.

```lua
-- signature
LLight:getPosition()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Light x coordinate. |
| `number` | b Light y coordinate. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setPosition(200, 150)
    local x, y = light:getPosition()
    print("pos = " .. x .. "," .. y)
end
```

---

### `LLight:getRadius`

Returns this light radius. This method is available to Lua scripts.

```lua
-- signature
LLight:getRadius()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Radius value. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setRadius(250)
    print("radius = " .. light:getRadius())
end
```

---

### `LLight:getShadowColor`

Returns this light shadow RGBA color.

```lua
-- signature
LLight:getShadowColor()
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
    local light = lurek.light.newLight(0, 0, 100)
    light:setShadowEnabled(true)
    light:setShadowColor(0, 0, 0.1, 0.8)
    local r, g, b, a = light:getShadowColor()
    print("shadow color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

### `LLight:getShadowFilter`

Returns this light shadow filter string.

```lua
-- signature
LLight:getShadowFilter()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Shadow filter `none`, `pcf5`, or `pcf13`. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setShadowEnabled(true)
    light:setShadowFilter("pcf5")
    print("shadow filter = " .. light:getShadowFilter())
end
```

---

### `LLight:getShadowMask`

Returns this light's shadow receiver mask.

```lua
-- signature
LLight:getShadowMask()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Shadow mask bits. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setShadowMask(7)
    print("shadow mask = " .. light:getShadowMask())
end
```

---

### `LLight:getShadowSmooth`

Returns this light shadow smoothing value.

```lua
-- signature
LLight:getShadowSmooth()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Shadow smoothing value. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setShadowEnabled(true)
    light:setShadowSmooth(2.0)
    print("shadow smooth = " .. light:getShadowSmooth())
end
```

---

### `LLight:getShadowSoftness`

Returns this light shadow softness value.

```lua
-- signature
LLight:getShadowSoftness()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Shadow softness value. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setShadowEnabled(true)
    light:setShadowSoftness(1.5)
    print("shadow softness = " .. light:getShadowSoftness())
end
```

---

### `LLight:isEnabled`

Returns whether this light is enabled.

```lua
-- signature
LLight:isEnabled()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the light is enabled. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setEnabled(false)
    print("enabled = " .. tostring(light:isEnabled()))
end
```

---

### `LLight:isFlickerEnabled`

Returns whether this light flicker is enabled.

```lua
-- signature
LLight:isFlickerEnabled()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when flicker is enabled. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setFlicker(2.0, 0.3)
    light:setFlickerEnabled(true)
    print("flicker on = " .. tostring(light:isFlickerEnabled()))
end
```

---

### `LLight:isShadowEnabled`

Returns whether this light casts shadows.

```lua
-- signature
LLight:isShadowEnabled()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when shadows are enabled. |

**Example**

```lua
do
    local light = lurek.light.newLight(200, 200, 150)
    light:setShadowEnabled(true)
    print("shadows = " .. tostring(light:isShadowEnabled()))
end
```

---

### `LLight:isValid`

Returns whether this light handle still points to a live light.

```lua
-- signature
LLight:isValid()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the light still exists. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    print("valid = " .. tostring(light:isValid()))
    light:remove()
    print("valid after remove = " .. tostring(light:isValid()))
end
```

---

### `LLight:isVolumetric`

Returns whether this light is volumetric.

```lua
-- signature
LLight:isVolumetric()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when volumetric behavior is enabled. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 200)
    light:setVolumetric(true)
    print("volumetric = " .. tostring(light:isVolumetric()))
end
```

---

### `LLight:remove`

Removes this light from the shared light world.

```lua
-- signature
LLight:remove()
```

**Example**

```lua
do
    local lt = lurek.light.newLight(200, 300, 150)
    print("lights = " .. lurek.light.getLightCount())
    lt:remove()
    print("after remove = " .. lurek.light.getLightCount())
end
```

---

### `LLight:setAttenuation`

Sets this light attenuation coefficients.

```lua
-- signature
LLight:setAttenuation(c, l, q)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `c` | `number` | Constant coefficient. |
| `l` | `number` | Linear coefficient. |
| `q` | `number` | Quadratic coefficient. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setAttenuation(1, 0.1, 0.01)
    local c, l, q = light:getAttenuation()
    print("attenuation c=" .. c .. " l=" .. l .. " q=" .. q)
end
```

---

### `LLight:setBlendMode`

Sets this light blend mode. This method is available to Lua scripts.

```lua
-- signature
LLight:setBlendMode(mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | `string` | Blend mode `add`, `sub`, or `mix`. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setBlendMode("add")
    print("blend = " .. light:getBlendMode())
end
```

---

### `LLight:setColor`

Sets this light RGBA color. This method is available to Lua scripts.

```lua
-- signature
LLight:setColor(r, g, b, a)
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
    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1, 0.5, 0, 0.9)
    local r, g, b, a = light:getColor()
    print("color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

### `LLight:setCookie`

Stores a cookie texture path on this Lua light handle.

```lua
-- signature
LLight:setCookie(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | Cookie texture path. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setCookie("content/examples/assets/images/sample_texture.png")
    print("cookie = " .. light:getCookie())
end
```

---

### `LLight:setDirection`

Sets this light direction angle. This method is available to Lua scripts.

```lua
-- signature
LLight:setDirection(dir)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dir` | `number` | Direction angle in radians or engine units. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setLightType("directional")
    light:setDirection(1.57)
    print("direction = " .. light:getDirection())
end
```

---

### `LLight:setEnabled`

Enables or disables this light. This method is available to Lua scripts.

```lua
-- signature
LLight:setEnabled(b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `b` | `boolean` | New enabled flag. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setEnabled(false)
    print("enabled = " .. tostring(light:isEnabled()))
end
```

---

### `LLight:setEnergy`

Sets this light energy value. This method is available to Lua scripts.

```lua
-- signature
LLight:setEnergy(e)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `e` | `number` | Energy value. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setEnergy(2.5)
    print("energy = " .. light:getEnergy())
end
```

---

### `LLight:setFalloff`

Sets this light falloff mode. This method is available to Lua scripts.

```lua
-- signature
LLight:setFalloff(mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | `string` | Falloff mode `linear`, `smooth`, or `constant`. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setFalloff("smooth")
    print("falloff = " .. light:getFalloff())
end
```

---

### `LLight:setFlicker`

Configures flicker speed and strength for this light.

```lua
-- signature
LLight:setFlicker(speed, strength)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `speed` | `number` | Flicker speed. |
| `strength` | `number` | Flicker strength. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setFlicker(3.0, 0.4)
    local speed, strength = light:getFlicker()
    print("flicker speed=" .. speed .. " strength=" .. strength)
end
```

---

### `LLight:setFlickerEnabled`

Enables or disables this light flicker state.

```lua
-- signature
LLight:setFlickerEnabled(b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `b` | `boolean` | New flicker enabled flag. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setFlicker(2.0, 0.3)
    light:setFlickerEnabled(true)
    print("flicker on = " .. tostring(light:isFlickerEnabled()))
end
```

---

### `LLight:setGroupId`

Sets this light group id. This method is available to Lua scripts.

```lua
-- signature
LLight:setGroupId(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Group id. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setGroupId(5)
    print("group = " .. light:getGroupId())
end
```

---

### `LLight:setInnerAngle`

Sets this spot light inner cone angle.

```lua
-- signature
LLight:setInnerAngle(a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `a` | `number` | Inner angle. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setLightType("spot")
    light:setInnerAngle(0.3)
    light:setOuterAngle(0.8)
    print("inner = " .. light:getInnerAngle() .. " outer = " .. light:getOuterAngle())
end
```

---

### `LLight:setIntensity`

Sets this light intensity. This method is available to Lua scripts.

```lua
-- signature
LLight:setIntensity(i)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `i` | `number` | Intensity value. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setIntensity(5)
    print("intensity = " .. light:getIntensity())
end
```

---

### `LLight:setLightMask`

Sets this light's inclusion mask. This method is available to Lua scripts.

```lua
-- signature
LLight:setLightMask(mask)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mask` | `number` | Light mask bits. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setLightMask(3)
    print("mask = " .. light:getLightMask())
end
```

---

### `LLight:setLightType`

Sets this light type. This method is available to Lua scripts.

```lua
-- signature
LLight:setLightType(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | `string` | Light type `point`, `directional`, or `spot`. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setLightType("spot")
    print("type = " .. light:getLightType())
end
```

---

### `LLight:setNormalMap`

Sets the normal map path used by this light.

```lua
-- signature
LLight:setNormalMap(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | Normal map path. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setNormalMap("content/examples/assets/images/sample_normal.dds")
    print("normal map = " .. light:getNormalMap())
end
```

---

### `LLight:setNormalStrength`

Sets this light's normal map strength.

```lua
-- signature
LLight:setNormalStrength(strength)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `strength` | `number` | Normal map strength. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setNormalStrength(1.5)
    print("normal strength = " .. light:getNormalStrength())
end
```

---

### `LLight:setOuterAngle`

Sets this spot light outer cone angle.

```lua
-- signature
LLight:setOuterAngle(a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `a` | `number` | Outer angle. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setLightType("spot")
    light:setInnerAngle(0.3)
    light:setOuterAngle(0.8)
    print("inner = " .. light:getInnerAngle() .. " outer = " .. light:getOuterAngle())
end
```

---

### `LLight:setPosition`

Sets this light position. This method is available to Lua scripts.

```lua
-- signature
LLight:setPosition(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | Light x coordinate. |
| `y` | `number` | Light y coordinate. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setPosition(200, 150)
    local x, y = light:getPosition()
    print("pos = " .. x .. "," .. y)
end
```

---

### `LLight:setRadius`

Sets this light radius. This method is available to Lua scripts.

```lua
-- signature
LLight:setRadius(r)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | `number` | Radius value. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setRadius(250)
    print("radius = " .. light:getRadius())
end
```

---

### `LLight:setShadowColor`

Sets this light shadow RGBA color. This method is available to Lua scripts.

```lua
-- signature
LLight:setShadowColor(r, g, b, a)
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
    local light = lurek.light.newLight(0, 0, 100)
    light:setShadowEnabled(true)
    light:setShadowColor(0, 0, 0.1, 0.8)
    local r, g, b, a = light:getShadowColor()
    print("shadow color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

### `LLight:setShadowEnabled`

Enables or disables shadow casting for this light.

```lua
-- signature
LLight:setShadowEnabled(b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `b` | `boolean` | New shadow enabled flag. |

**Example**

```lua
do
    local light = lurek.light.newLight(200, 200, 150)
    light:setShadowEnabled(true)
    print("shadows = " .. tostring(light:isShadowEnabled()))
end
```

---

### `LLight:setShadowFilter`

Sets this light shadow filter. This method is available to Lua scripts.

```lua
-- signature
LLight:setShadowFilter(filter)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `filter` | `string` | Shadow filter `none`, `pcf5`, or `pcf13`. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setShadowEnabled(true)
    light:setShadowFilter("pcf5")
    print("shadow filter = " .. light:getShadowFilter())
end
```

---

### `LLight:setShadowMask`

Sets this light's shadow receiver mask.

```lua
-- signature
LLight:setShadowMask(mask)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mask` | `number` | Shadow mask bits. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setShadowMask(7)
    print("shadow mask = " .. light:getShadowMask())
end
```

---

### `LLight:setShadowSmooth`

Sets this light shadow smoothing value.

```lua
-- signature
LLight:setShadowSmooth(s)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `s` | `number` | Shadow smoothing value. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setShadowEnabled(true)
    light:setShadowSmooth(2.0)
    print("shadow smooth = " .. light:getShadowSmooth())
end
```

---

### `LLight:setShadowSoftness`

Sets this light shadow softness value.

```lua
-- signature
LLight:setShadowSoftness(softness)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `softness` | `number` | Shadow softness value. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setShadowEnabled(true)
    light:setShadowSoftness(1.5)
    print("shadow softness = " .. light:getShadowSoftness())
end
```

---

### `LLight:setVolumetric`

Enables or disables volumetric behavior for this light.

```lua
-- signature
LLight:setVolumetric(b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `b` | `boolean` | New volumetric flag. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 200)
    light:setVolumetric(true)
    print("volumetric = " .. tostring(light:isVolumetric()))
end
```

---

### `LLight:stopTransition`

Stops and clears this light's active transition.

```lua
-- signature
LLight:stopTransition()
```

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:transitionTo({color = {0, 0, 1, 1}, intensity = 3.0, radius = 200}, 2.0)
    light:stopTransition()
    print("stopped, progress = " .. light:transitionProgress())
end
```

---

### `LLight:transitionProgress`

Returns active transition progress or 1.0 when no transition is active.

```lua
-- signature
LLight:transitionProgress()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Transition progress. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:transitionTo({color = {0, 0, 1, 1}, intensity = 3.0, radius = 200}, 2.0)
    light:updateTransition(0.5)
    print("progress = " .. light:transitionProgress())
end
```

---

### `LLight:transitionTo`

Starts a transition toward target color, intensity, and radius values.

```lua
-- signature
LLight:transitionTo(target, duration)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | `table` | Target table with optional `color`, `intensity`, and `radius` fields. |
| `duration` | `number` | Transition duration in seconds. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1, 0, 0, 1)
    light:setIntensity(1.0)
    light:transitionTo({color = {0, 0, 1, 1}, intensity = 3.0, radius = 200}, 2.0)
    print("progress = " .. light:transitionProgress())
end
```

---

### `LLight:type`

Returns the Lua-visible type name for this light handle.

```lua
-- signature
LLight:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LLight`. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    print("type = " .. light:type())
    print("is LLight = " .. tostring(light:typeOf("LLight")))
end
```

---

### `LLight:typeOf`

Returns whether this light handle matches a supported type name.

```lua
-- signature
LLight:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LLight` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    print("type = " .. light:type())
    print("is LLight = " .. tostring(light:typeOf("LLight")))
    print("is Object = " .. tostring(light:typeOf("LObject")))
end
```

---

### `LLight:updateTransition`

Advances this light's active transition and applies interpolated values.

```lua
-- signature
LLight:updateTransition(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | `number` | Delta time in seconds. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when a transition value was applied. |

**Example**

```lua
do
    local light = lurek.light.newLight(0, 0, 100)
    light:transitionTo({color = {0, 0, 1, 1}, intensity = 3.0, radius = 200}, 2.0)
    local applied = light:updateTransition(0.5)
    print("applied = " .. tostring(applied))
end
```

---

## LOccluder

### `LOccluder:getLightMask`

Returns this occluder's light mask.

```lua
-- signature
LOccluder:getLightMask()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Light mask bits. |

**Example**

```lua
do
    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    occ:setLightMask(5)
    print("occ mask = " .. occ:getLightMask())
end
```

---

### `LOccluder:getOpacity`

Returns this occluder opacity. This method is available to Lua scripts.

```lua
-- signature
LOccluder:getOpacity()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Opacity value. |

**Example**

```lua
do
    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    occ:setOpacity(0.6)
    print("opacity = " .. occ:getOpacity())
end
```

---

### `LOccluder:getPosition`

Returns this occluder position offset.

```lua
-- signature
LOccluder:getPosition()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a X coordinate. |
| `number` | b Y coordinate. |

**Example**

```lua
do
    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    occ:setPosition(50, 75)
    local x, y = occ:getPosition()
    print("occ pos = " .. x .. "," .. y)
end
```

---

### `LOccluder:getVertices`

Returns this occluder's flat vertex coordinate list.

```lua
-- signature
LOccluder:getVertices()
```

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Flat numeric array `[x1, y1, x2, y2, ...]`. |

**Example**

```lua
do
    local occ = lurek.light.newOccluder({0, 0, 20, 0, 20, 20, 0, 20})
    occ:setVertices({0, 0, 30, 0, 30, 30, 0, 30})
    local v = occ:getVertices()
    print("vertex count = " .. #v / 2)
end
```

---

### `LOccluder:isEnabled`

Returns whether this occluder is enabled.

```lua
-- signature
LOccluder:isEnabled()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when enabled. |

**Example**

```lua
do
    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    occ:setEnabled(false)
    print("enabled = " .. tostring(occ:isEnabled()))
end
```

---

### `LOccluder:isValid`

Returns whether this occluder handle still points to a live occluder.

```lua
-- signature
LOccluder:isValid()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the occluder still exists. |

**Example**

```lua
do
    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    print("valid = " .. tostring(occ:isValid()))
    occ:remove()
    print("valid after remove = " .. tostring(occ:isValid()))
end
```

---

### `LOccluder:remove`

Removes this occluder from the shared light world.

```lua
-- signature
LOccluder:remove()
```

**Example**

```lua
do
    local vtbl = { 0, 0, 100, 0, 100, 100, 0, 100 }
    local occ = lurek.light.newOccluder(vtbl)
    print("occluders = " .. lurek.light.getOccluderCount())
    occ:remove()
    print("after remove = " .. lurek.light.getOccluderCount())
end
```

---

### `LOccluder:setEnabled`

Enables or disables this occluder.

```lua
-- signature
LOccluder:setEnabled(b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `b` | `boolean` | New enabled flag. |

**Example**

```lua
do
    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    occ:setEnabled(false)
    print("enabled = " .. tostring(occ:isEnabled()))
end
```

---

### `LOccluder:setLightMask`

Sets this occluder's light mask. This method is available to Lua scripts.

```lua
-- signature
LOccluder:setLightMask(mask)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mask` | `number` | Light mask bits. |

**Example**

```lua
do
    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    occ:setLightMask(5)
    print("occ mask = " .. occ:getLightMask())
end
```

---

### `LOccluder:setOpacity`

Sets this occluder opacity. This method is available to Lua scripts.

```lua
-- signature
LOccluder:setOpacity(o)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `o` | `number` | Opacity value. |

**Example**

```lua
do
    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    occ:setOpacity(0.6)
    print("opacity = " .. occ:getOpacity())
end
```

---

### `LOccluder:setPosition`

Sets this occluder position offset.

```lua
-- signature
LOccluder:setPosition(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | X coordinate. |
| `y` | `number` | Y coordinate. |

**Example**

```lua
do
    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    occ:setPosition(50, 75)
    local x, y = occ:getPosition()
    print("occ pos = " .. x .. "," .. y)
end
```

---

### `LOccluder:setVertices`

Replaces this occluder's flat vertex coordinate list.

```lua
-- signature
LOccluder:setVertices(tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tbl` | `table` | Flat numeric array `[x1, y1, x2, y2, ...]`. |

**Example**

```lua
do
    local occ = lurek.light.newOccluder({0, 0, 20, 0, 20, 20, 0, 20})
    occ:setVertices({0, 0, 30, 0, 30, 30, 0, 30})
    local v = occ:getVertices()
    print("vertex count = " .. #v / 2)
end
```

---

### `LOccluder:type`

Returns the Lua-visible type name for this occluder handle.

```lua
-- signature
LOccluder:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LOccluder`. |

**Example**

```lua
do
    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    print("type = " .. occ:type())
    print("is LOccluder = " .. tostring(occ:typeOf("LOccluder")))
end
```

---

### `LOccluder:typeOf`

Returns whether this occluder handle matches a supported type name.

```lua
-- signature
LOccluder:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LOccluder` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    print("type = " .. occ:type())
    print("is LOccluder = " .. tostring(occ:typeOf("LOccluder")))
    print("is Object = " .. tostring(occ:typeOf("LObject")))
end
```

---
