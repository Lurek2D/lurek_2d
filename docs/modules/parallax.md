# Parallax

- The `parallax` module is a dedicated Feature Systems tier component that implements a highly configurable, multi-layer scrolling background system for Lurek2D.

It allows developers to easily create a deep sense of 2D perspective by stacking multiple textured layers that scroll at varying speeds relative to camera movement. The core of this system is the `ParallaxLayer`, which defines a single depth plane. By assigning a scroll speed multiplier to each layer (where 0.0 represents a distant static background and 1.0 moves precisely with the camera), the system automatically handles the complex camera-relative pixel offset computations necessary for convincing parallax effects. Layers are sorted back-to-front by their assigned Z-depth, with the lowest scroll factors naturally appearing furthest away.

In addition to camera-driven motion, the module features an independent auto-scroll mechanic. This allows layers to maintain a constant baseline velocity regardless of player movement, which is essential for animating ambient atmospheric elements like drifting clouds, flowing water, or moving starfields. The rendering pipeline of the `parallax` module is deeply optimized. It automatically computes `ParallaxDrawBatch`es, utilizing a sophisticated `tile_iter` algorithm to calculate the precise grid of visible repeating tiles required to fill the viewport (plus a safety cull margin). This avoids allocating vast repeating grids and instead generates lightweight, stateless `RenderCommand` sequences for GPU submission.

The visual fidelity of parallax layers can be further customized per-layer. It supports dynamic opacity adjustments, RGBA tinting, and various accumulation blend modes (such as additive or screen). Advanced visual features include a motion-stretch blur effect, which procedurally stretches layer tiles based on their auto-scroll velocity to simulate high-speed motion. For ease of use, the module includes a `presets` system offering ready-made configurations for common depth planes (e.g., far backgrounds, mid-grounds, and foreground fog). Grouped management is provided via `ParallaxSet`s, and the entire feature suite is fully exposed to the Lua environment through the `lurek.parallax.*` API.

## Functions

### `lurek.parallax.newLayer`

Creates a parallax layer from an options table.

```lua
-- signature
lurek.parallax.newLayer(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | `table` | Options table with required `texture` and optional scrolling, repeat, z, opacity, tint, blend, visibility, scale, tiling, depth, tile size, motion stretch, and effects fields. |

**Returns**

| Type | Description |
|------|-------------|
| `LParallaxLayer` | New parallax layer handle. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        scroll_factor_x = 0.3,
        scroll_factor_y = 0.1,
        z = 10,
        opacity = 0.9,
        tiling = true,
    })
    local sx, sy = layer:getScrollFactor()
    print("type = " .. layer:type())
    print("scroll = " .. sx .. "," .. sy)
    print("z = " .. layer:getZ())
end
```

---

### `lurek.parallax.newPresetLayer`

Creates a parallax layer from a named preset and texture image.

```lua
-- signature
lurek.parallax.newPresetLayer(preset_name, img_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `preset_name` | `string` | Preset name: `far`, `mid`, or `fog`. |
| `img_ud` | `LImage` | Image handle from `lurek.render.newImage`. |

**Returns**

| Type | Description |
|------|-------------|
| `LParallaxLayer` | New parallax layer handle. |

**Example**

```lua
do
    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local far = lurek.parallax.newPresetLayer("far", img)
    local mid = lurek.parallax.newPresetLayer("mid", img)
    print("far depth = " .. far:getDepth())
    print("mid z = " .. mid:getZ())
end
```

---

### `lurek.parallax.newSet`

Creates an empty parallax layer set.

```lua
-- signature
lurek.parallax.newSet(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Set name. |

**Returns**

| Type | Description |
|------|-------------|
| `LParallaxSet` | New parallax set handle. |

**Example**

```lua
do
    local set = lurek.parallax.newSet("background")
    print("name = " .. set:getName() .. " type = " .. set:type())
    print("layers = " .. set:layerCount())
end
```

---

## LParallaxLayer

### `LParallaxLayer:addEffectPass`

Adds a shader effect pass to this layer.

```lua
-- signature
LParallaxLayer:addEffectPass(effect_name, params)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `effect_name` | `string` | Effect name. |
| `params?` | `table` | Numeric parameter table. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:addEffectPass("blur", { radius = 1.5 })
    layer:addEffectPass("tint", { r = 1.0, g = 0.8, b = 0.6, a = 1.0 })
    print("effects = " .. layer:effectCount())
    layer:clearEffects()
    print("after clear = " .. layer:effectCount())
end
```

---

### `LParallaxLayer:clearClamp`

Clears layer clamp bounds on this object.

```lua
-- signature
LParallaxLayer:clearClamp()
```

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setClamp(-100, -50, 100, 50)
    print("clamped")
    layer:clearClamp()
    print("clamp cleared")
end
```

---

### `LParallaxLayer:clearEffects`

Clears shader effect passes from this layer.

```lua
-- signature
LParallaxLayer:clearEffects()
```

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:addEffectPass("blur", { radius = 1.5 })
    layer:addEffectPass("tint", { r = 1.0, g = 0.8, b = 0.6, a = 1.0 })
    print("effects = " .. layer:effectCount())
    layer:clearEffects()
    print("after clear = " .. layer:effectCount())
end
```

---

### `LParallaxLayer:effectCount`

Returns the shader effect pass count for this layer.

```lua
-- signature
LParallaxLayer:effectCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Effect pass count. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:addEffectPass("blur", { radius = 1.5 })
    layer:addEffectPass("tint", { r = 1.0, g = 0.8, b = 0.6, a = 1.0 })
    print("effects = " .. layer:effectCount())
    layer:clearEffects()
    print("after clear = " .. layer:effectCount())
end
```

---

### `LParallaxLayer:getAutoscroll`

Returns layer autoscroll velocity.

```lua
-- signature
LParallaxLayer:getAutoscroll()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a X velocity. |
| `number` | b Y velocity. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        autoscroll_x = 12,
        autoscroll_y = -4,
    })
    local vx, vy = layer:getAutoscroll()
    print("autoscroll = " .. vx .. "," .. vy)
end
```

---

### `LParallaxLayer:getBlendMode`

Returns the current layer blend mode name.

```lua
-- signature
LParallaxLayer:getBlendMode()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Blend mode name. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        blend_mode = "screen",
    })
    print("blend = " .. layer:getBlendMode())
end
```

---

### `LParallaxLayer:getDepth`

Returns parallax depth from this object.

```lua
-- signature
LParallaxLayer:getDepth()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Depth value. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        depth = 0.8,
    })
    print("depth = " .. layer:getDepth())
end
```

---

### `LParallaxLayer:getMotionStretch`

Returns the current motion stretch settings.

```lua
-- signature
LParallaxLayer:getMotionStretch()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | a Motion stretch flag. |
| `number` | b Stretch strength. |
| `number` | c Maximum stretch scale. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        motion_stretch = true,
        motion_stretch_strength = 0.5,
        motion_stretch_max = 2.0,
    })
    local enabled, strength, max_scale = layer:getMotionStretch()
    print("stretch enabled=" .. tostring(enabled) .. " strength=" .. strength .. " max=" .. max_scale)
end
```

---

### `LParallaxLayer:getOffset`

Returns layer offset for this object.

```lua
-- signature
LParallaxLayer:getOffset()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a X offset. |
| `number` | b Y offset. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        offset_x = 24,
        offset_y = -8,
    })
    local ox, oy = layer:getOffset()
    print("offset = " .. ox .. "," .. oy)
end
```

---

### `LParallaxLayer:getOpacity`

Returns layer opacity from this object.

```lua
-- signature
LParallaxLayer:getOpacity()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Opacity value. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        opacity = 0.35,
    })
    print("opacity = " .. layer:getOpacity())
end
```

---

### `LParallaxLayer:getScrollFactor`

Returns layer scroll factor from this object.

```lua
-- signature
LParallaxLayer:getScrollFactor()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a X scroll factor. |
| `number` | b Y scroll factor. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        scroll_factor_x = 0.75,
        scroll_factor_y = 0.15,
    })
    local sx, sy = layer:getScrollFactor()
    print("scroll = " .. sx .. "," .. sy)
end
```

---

### `LParallaxLayer:getTiling`

Returns whether layer tiling is enabled.

```lua
-- signature
LParallaxLayer:getTiling()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when tiling is enabled. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        tiling = true,
    })
    print("tiling = " .. tostring(layer:getTiling()))
end
```

---

### `LParallaxLayer:getTint`

Returns layer tint color from this object.

```lua
-- signature
LParallaxLayer:getTint()
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
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        tint_r = 0.6,
        tint_g = 0.8,
        tint_b = 1.0,
        tint_a = 0.75,
    })
    local r, g, b, a = layer:getTint()
    print("tint = " .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

### `LParallaxLayer:getZ`

Returns layer z order from this object.

```lua
-- signature
LParallaxLayer:getZ()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Z order. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        z = -5,
    })
    print("z = " .. layer:getZ())
end
```

---

### `LParallaxLayer:isVisible`

Returns layer visibility and returns a boolean.

```lua
-- signature
LParallaxLayer:isVisible()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when visible. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        visible = false,
    })
    print("visible = " .. tostring(layer:isVisible()))
end
```

---

### `LParallaxLayer:render`

Enqueues render commands using explicit camera coordinates.

```lua
-- signature
LParallaxLayer:render(cam_x, cam_y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cam_x` | `number` | Camera x coordinate. |
| `cam_y` | `number` | Camera y coordinate. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setAutoscroll(50, 0)
    layer:update(0.016)
    layer:render(100, 50)
    layer:renderAuto()
    print("rendered")
end
```

---

### `LParallaxLayer:renderAuto`

Enqueues render commands using the runtime camera.

```lua
-- signature
LParallaxLayer:renderAuto()
```

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setAutoscroll(50, 0)
    layer:update(0.016)
    layer:render(100, 50)
    layer:renderAuto()
    print("rendered")
end
```

---

### `LParallaxLayer:resetAutoscroll`

Resets the layer autoscroll offset to zero.

```lua
-- signature
LParallaxLayer:resetAutoscroll()
```

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setAutoscroll(20, 0)
    layer:update(1.0)
    layer:resetAutoscroll()
    local vx, vy = layer:getAutoscroll()
    print("velocity still = " .. vx .. "," .. vy)
    print("autoscroll reset")
end
```

---

### `LParallaxLayer:setAutoscroll`

Sets the layer autoscroll velocity values.

```lua
-- signature
LParallaxLayer:setAutoscroll(vx, vy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `vx` | `number` | X autoscroll velocity. |
| `vy` | `number` | Y autoscroll velocity. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setAutoscroll(20, 0)
    local vx, vy = layer:getAutoscroll()
    print("autoscroll = " .. vx .. "," .. vy)
    layer:update(1.0)
    layer:resetAutoscroll()
    print("autoscroll reset")
end
```

---

### `LParallaxLayer:setBlendMode`

Sets the layer blend mode by string name.

```lua
-- signature
LParallaxLayer:setBlendMode(mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | `string` | Blend mode name. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setBlendMode("add")
    print("blend = " .. layer:getBlendMode())
    layer:setBlendMode("alpha")
    print("blend = " .. layer:getBlendMode())
end
```

---

### `LParallaxLayer:setClamp`

Sets clamp bounds for layer movement.

```lua
-- signature
LParallaxLayer:setClamp(min_x, min_y, max_x, max_y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min_x` | `number` | Minimum X bound. |
| `min_y` | `number` | Minimum Y bound. |
| `max_x` | `number` | Maximum X bound. |
| `max_y` | `number` | Maximum Y bound. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setClamp(-100, -50, 100, 50)
    print("clamped")
    layer:clearClamp()
    print("clamp cleared")
end
```

---

### `LParallaxLayer:setDepth`

Sets parallax depth for this object.

```lua
-- signature
LParallaxLayer:setDepth(z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `z` | `number` | Depth value. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setDepth(0.5)
    print("depth = " .. layer:getDepth())
end
```

---

### `LParallaxLayer:setMotionStretch`

Sets the motion stretch settings for this layer.

```lua
-- signature
LParallaxLayer:setMotionStretch(enabled, strength, max_scale)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | `boolean` | Motion stretch flag. |
| `strength` | `number` | Stretch strength. |
| `max_scale` | `number` | Maximum stretch scale. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setMotionStretch(true, 0.5, 2.0)
    local enabled, strength, max_scale = layer:getMotionStretch()
    print("stretch enabled=" .. tostring(enabled) .. " strength=" .. strength .. " max=" .. max_scale)
end
```

---

### `LParallaxLayer:setOffset`

Sets the layer pixel offset for this object.

```lua
-- signature
LParallaxLayer:setOffset(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | X offset. |
| `y` | `number` | Y offset. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setOffset(10, -5)
    local ox, oy = layer:getOffset()
    print("offset = " .. ox .. "," .. oy)
end
```

---

### `LParallaxLayer:setOpacity`

Sets layer opacity, clamped to 0..1.

```lua
-- signature
LParallaxLayer:setOpacity(a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `a` | `number` | Opacity value. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setOpacity(0.7)
    print("opacity = " .. layer:getOpacity())
end
```

---

### `LParallaxLayer:setRepeat`

Sets horizontal and vertical repeat flags.

```lua
-- signature
LParallaxLayer:setRepeat(rx, ry)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `rx` | `boolean` | Repeat horizontally. |
| `ry` | `boolean` | Repeat vertically. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setRepeat(true, false)
    layer:render(32, 16)
    print("repeat set: horizontal only")
    print("z = " .. layer:getZ())
end
```

---

### `LParallaxLayer:setScale`

Sets the layer scale factor for this object.

```lua
-- signature
LParallaxLayer:setScale(sx, sy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sx` | `number` | X scale factor. |
| `sy` | `number` | Y scale factor. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setScale(2.0, 2.0)
    layer:render(0, 0)
    print("scaled 2x")
    print("type = " .. layer:type())
end
```

---

### `LParallaxLayer:setScrollFactor`

Sets layer scroll factor for this object.

```lua
-- signature
LParallaxLayer:setScrollFactor(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | X scroll factor. |
| `y` | `number` | Y scroll factor. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setScrollFactor(0.5, 0.2)
    local sx, sy = layer:getScrollFactor()
    print("scroll = " .. sx .. "," .. sy)
end
```

---

### `LParallaxLayer:setTileSize`

Sets tile size for tiling for this object.

```lua
-- signature
LParallaxLayer:setTileSize(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | `number` | Tile width. |
| `h` | `number` | Tile height. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        tiling = true,
    })
    layer:setTileSize(64, 64)
    layer:render(0, 0)
    print("tile size set to 64x64")
    print("rendered tiled layer")
end
```

---

### `LParallaxLayer:setTiling`

Enables or disables the layer tiling mode.

```lua
-- signature
LParallaxLayer:setTiling(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | `boolean` | Tiling flag. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setTiling(true)
    print("tiling = " .. tostring(layer:getTiling()))
end
```

---

### `LParallaxLayer:setTint`

Sets layer tint color for this object.

```lua
-- signature
LParallaxLayer:setTint(r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | `number` | Red channel (0–1). |
| `g` | `number` | Green channel (0–1). |
| `b` | `number` | Blue channel (0–1). |
| `a` | `number` | Alpha channel (0–1). |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setTint(1.0, 0.8, 0.6, 1.0)
    local r, g, b, a = layer:getTint()
    print("tint = " .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

### `LParallaxLayer:setVisible`

Sets layer visibility for this object.

```lua
-- signature
LParallaxLayer:setVisible(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `boolean` | Visibility flag. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setVisible(false)
    print("visible = " .. tostring(layer:isVisible()))
    layer:setVisible(true)
    print("visible = " .. tostring(layer:isVisible()))
end
```

---

### `LParallaxLayer:setZ`

Sets the layer z order for this object.

```lua
-- signature
LParallaxLayer:setZ(z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `z` | `number` | Z order. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setZ(-5)
    print("z = " .. layer:getZ())
end
```

---

### `LParallaxLayer:type`

Returns the Lua-visible type name for this parallax layer handle.

```lua
-- signature
LParallaxLayer:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LParallaxLayer`. |

**Example**

```lua
do
    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = img,
        scroll_factor_x = 0.5,
        scroll_factor_y = 0.2,
        z = -1,
    })
    print(layer:type())
end
```

---

### `LParallaxLayer:update`

Advances parallax layer autoscroll by delta time.

```lua
-- signature
LParallaxLayer:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | `number` | Delta time in seconds. |

**Example**

```lua
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setAutoscroll(50, 0)
    layer:update(0.016)
    layer:render(100, 50)
    layer:renderAuto()
    print("rendered")
end
```

---

## LParallaxSet

### `LParallaxSet:addLayer`

Adds a parallax layer to this set handle.

```lua
-- signature
LParallaxSet:addLayer(layer)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | `LParallaxLayer` | Layer handle. |

**Example**

```lua
do
    local set = lurek.parallax.newSet("scene")
    set:addLayer(lurek.parallax.newLayer({
        texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        z = 0,
    }))
    set:addLayer(lurek.parallax.newLayer({
        texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        z = 5,
    }))
    set:addLayer(lurek.parallax.newLayer({
        texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        z = 10,
    }))
    print("layers = " .. set:layerCount())
    print("removed = " .. tostring(set:removeLayerAt(2)) .. " layers = " .. set:layerCount())
end
```

---

### `LParallaxSet:getLayerZAt`

Returns z order for a layer by one-based index, or nil when out of range.

```lua
-- signature
LParallaxSet:getLayerZAt(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | `number` | One-based layer index. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Z order. |

**Example**

```lua
do
    local set = lurek.parallax.newSet("sorted")
    set:addLayer(lurek.parallax.newLayer({
        texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        z = 100,
    }))
    set:addLayer(lurek.parallax.newLayer({
        texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        z = 1,
    }))
    print("z at 1 = " .. tostring(set:getLayerZAt(1)))
    print("z at 2 = " .. tostring(set:getLayerZAt(2)))
    set:sortByZ()
    print("sorted: z at 1 = " .. tostring(set:getLayerZAt(1)))
end
```

---

### `LParallaxSet:getName`

Returns this set name from this object.

```lua
-- signature
LParallaxSet:getName()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Set name. |

**Example**

```lua
do
    local set = lurek.parallax.newSet("temp")
    set:setName("sky_layers")
    print("name = " .. set:getName())
end
```

---

### `LParallaxSet:isVisible`

Returns set visibility and returns a boolean.

```lua
-- signature
LParallaxSet:isVisible()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when visible. |

**Example**

```lua
do
    local set = lurek.parallax.newSet("temp")
    set:setVisible(false)
    print("visible = " .. tostring(set:isVisible()))
end
```

---

### `LParallaxSet:layerCount`

Returns the number of layers in this set.

```lua
-- signature
LParallaxSet:layerCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Layer count. |

**Example**

```lua
do
    local set = lurek.parallax.newSet("scene")
    set:addLayer(lurek.parallax.newLayer({
        texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        z = 0,
    }))
    set:addLayer(lurek.parallax.newLayer({
        texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        z = 5,
    }))
    set:addLayer(lurek.parallax.newLayer({
        texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        z = 10,
    }))
    print("layers = " .. set:layerCount())
    print("removed = " .. tostring(set:removeLayerAt(2)) .. " layers = " .. set:layerCount())
end
```

---

### `LParallaxSet:removeLayerAt`

Removes a layer by one-based index.

```lua
-- signature
LParallaxSet:removeLayerAt(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | `number` | One-based layer index. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when a layer was removed. |

**Example**

```lua
do
    local set = lurek.parallax.newSet("scene")
    set:addLayer(lurek.parallax.newLayer({
        texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        z = 0,
    }))
    set:addLayer(lurek.parallax.newLayer({
        texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        z = 5,
    }))
    set:addLayer(lurek.parallax.newLayer({
        texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        z = 10,
    }))
    print("layers = " .. set:layerCount())
    print("removed = " .. tostring(set:removeLayerAt(2)) .. " layers = " .. set:layerCount())
end
```

---

### `LParallaxSet:render`

Enqueues render commands for all visible set layers using explicit camera coordinates.

```lua
-- signature
LParallaxSet:render(cam_x, cam_y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cam_x` | `number` | Camera x coordinate. |
| `cam_y` | `number` | Camera y coordinate. |

**Example**

```lua
do
    local set = lurek.parallax.newSet("world")
    local layer = lurek.parallax.newLayer({
        texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        z = 0,
    })
    layer:setAutoscroll(30, 0)
    set:addLayer(layer)
    set:update(0.016)
    set:render(200, 100)
    set:renderAuto()
    print("set rendered")
end
```

---

### `LParallaxSet:renderAuto`

Enqueues render commands for all visible set layers using the runtime camera.

```lua
-- signature
LParallaxSet:renderAuto()
```

**Example**

```lua
do
    local set = lurek.parallax.newSet("world")
    local layer = lurek.parallax.newLayer({
        texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        z = 0,
    })
    layer:setAutoscroll(30, 0)
    set:addLayer(layer)
    set:update(0.016)
    set:render(200, 100)
    set:renderAuto()
    print("set rendered")
end
```

---

### `LParallaxSet:setName`

Sets this parallax set name for this object.

```lua
-- signature
LParallaxSet:setName(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Set name. |

**Example**

```lua
do
    local set = lurek.parallax.newSet("temp")
    set:setName("sky_layers")
    print("name = " .. set:getName())
    set:setVisible(false)
    print("visible = " .. tostring(set:isVisible()))
    set:setVisible(true)
    print("visible = " .. tostring(set:isVisible()))
end
```

---

### `LParallaxSet:setVisible`

Sets set visibility for this object.

```lua
-- signature
LParallaxSet:setVisible(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `boolean` | Visibility flag. |

**Example**

```lua
do
    local set = lurek.parallax.newSet("temp")
    set:setName("sky_layers")
    print("name = " .. set:getName())
    set:setVisible(false)
    print("visible = " .. tostring(set:isVisible()))
    set:setVisible(true)
    print("visible = " .. tostring(set:isVisible()))
end
```

---

### `LParallaxSet:sortByZ`

Sorts layers by z order on this object.

```lua
-- signature
LParallaxSet:sortByZ()
```

**Example**

```lua
do
    local set = lurek.parallax.newSet("sorted")
    set:addLayer(lurek.parallax.newLayer({
        texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        z = 100,
    }))
    set:addLayer(lurek.parallax.newLayer({
        texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        z = 1,
    }))
    print("before sort z1 = " .. tostring(set:getLayerZAt(1)))
    print("before sort z2 = " .. tostring(set:getLayerZAt(2)))
    set:sortByZ()
    print("sorted: z at 1 = " .. tostring(set:getLayerZAt(1)))
end
```

---

### `LParallaxSet:type`

Returns the Lua-visible type name for this parallax set handle.

```lua
-- signature
LParallaxSet:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LParallaxSet`. |

**Example**

```lua
do
    local set = lurek.parallax.newSet("bg_set")
    print(set:type())
end
```

---

### `LParallaxSet:update`

Updates all layers in this parallax set.

```lua
-- signature
LParallaxSet:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | `number` | Delta time in seconds. |

**Example**

```lua
do
    local set = lurek.parallax.newSet("world")
    local layer = lurek.parallax.newLayer({
        texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        z = 0,
    })
    layer:setAutoscroll(30, 0)
    set:addLayer(layer)
    set:update(0.016)
    set:render(200, 100)
    set:renderAuto()
    print("set rendered")
end
```

---
