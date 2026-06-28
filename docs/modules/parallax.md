# Parallax

## Purpose

Manages layered scroll depth, autoscrolling, and tiling. - Adds motion blur.

## Summary

- The `parallax` module is the layered-background surface for projects that want depth and atmospheric motion without full 3D simulation.
- Layer definitions, presets, tiling behavior, and render helpers let several planes move at different camera-relative rates and create a stronger sense of scene depth.
- Drawing support and image export matter because parallax content may be used both in live rendering and in tooling or preview workflows.
- The module is useful for skies, distant scenery, decorative world layers, and motion-rich menu or transition backdrops that should stay cheaper and simpler than full interactive geometry.
- Camera-relative speed policy matters because background depth reads differently across scenes.
- It also keeps background motion readable across scene scales and camera styles.
- Read it as the place where depth-illusion backgrounds become reusable scene content instead of a one-off renderer trick.

This module primarily collaborates with `image`, `render`, `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## API Reference

- This page is the generated API reference for this module.

## Functions

### `lurek.parallax.newLayer`

Creates a parallax layer from an options table.

```lua
lurek.parallax.newLayer(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | table | Options table with required `texture` and optional scrolling, repeat, z, opacity, tint, blend, visibility, scale, tiling, depth, tile size, motion stretch, and effects fields. |

**Returns**

| Type | Description |
|------|-------------|
| [LParallaxLayer](#lparallaxlayer) | New parallax layer handle. |

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
    lurek.log.info(tostring("type = " .. layer:type()))
    lurek.log.info(tostring("scroll = " .. sx .. "," .. sy))
    lurek.log.info(tostring("z = " .. layer:getZ()))
end
```

---

### `lurek.parallax.newPresetLayer`

Creates a parallax layer from a named preset and texture image.

```lua
lurek.parallax.newPresetLayer(preset_name, img_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `preset_name` | string | Preset name: `far`, `mid`, or `fog`. |
| `img_ud` | [LImage](#limage) | Image handle from `lurek.render.newImage`. |

**Returns**

| Type | Description |
|------|-------------|
| [LParallaxLayer](#lparallaxlayer) | New parallax layer handle. |

**Example**

```lua
do

    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local far = lurek.parallax.newPresetLayer("far", img)
    local mid = lurek.parallax.newPresetLayer("mid", img)
    lurek.log.info(tostring("far depth = " .. far:getDepth()))
    lurek.log.info(tostring("mid z = " .. mid:getZ()))
end
```

---

### `lurek.parallax.newSet`

Creates an empty parallax layer set.

```lua
lurek.parallax.newSet(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Set name. |

**Returns**

| Type | Description |
|------|-------------|
| [LParallaxSet](#lparallaxset) | New parallax set handle. |

**Example**

```lua
do

    local set = lurek.parallax.newSet("background")
    local layer = lurek.parallax.newLayer({
        texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        z = 0,
    })
    set:addLayer(layer)
    lurek.log.info(tostring("name = " .. set:getName() .. " type = " .. set:type()))
    lurek.log.info(tostring("layers = " .. set:layerCount()))
end
```

---

## Module Fields

*No module-level fields documented.*

## Enums

*No module-specific enums documented.*

## Types

- [LImage](#limage)
- [LParallaxLayer](#lparallaxlayer)
- [LParallaxSet](#lparallaxset)

## LImage

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LImage:getDimensions`

Returns both width and height of this image.

```lua
LImage:getDimensions()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width and height in pixels. (value 1). |
| number | Width and height in pixels. (value 2). |

---

#### `LImage:getHeight`

Returns the height of this image in pixels.

```lua
LImage:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Height in pixels. |

---

#### `LImage:getId`

Returns the internal numeric handle ID for this image.

```lua
LImage:getId()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Opaque image handle identifier. |

---

#### `LImage:getWidth`

Returns the width of this image in pixels.

```lua
LImage:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width in pixels. |

---

#### `LImage:release`

Releases the GPU memory for this image. The handle becomes invalid after this call.

```lua
LImage:release()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the image was still valid and was released. |

---

#### `LImage:type`

Returns the type name string for this image object.

```lua
LImage:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always "[LImage](#limage)". |

---

#### `LImage:typeOf`

Checks whether this object matches the given type name.

```lua
LImage:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check ("Image" or "Object"). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the name matches. |

---

## LParallaxLayer

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LParallaxLayer:addEffectPass`

Adds a shader effect pass to this layer.

```lua
LParallaxLayer:addEffectPass(effect_name, params)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `effect_name` | string | Effect name. |
| `params?` | table | Numeric parameter table. |

**Example**

```lua
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:addEffectPass("blur", { radius = 1.5 })
    layer:addEffectPass("tint", { r = 1.0, g = 0.8, b = 0.6, a = 1.0 })
    lurek.log.info(tostring("effects = " .. layer:effectCount()))
    layer:clearEffects()
    lurek.log.info(tostring("after clear = " .. layer:effectCount()))
end
```

---

#### `LParallaxLayer:clearClamp`

Clears layer clamp bounds on this object.

```lua
LParallaxLayer:clearClamp()
```

**Example**

```lua
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setClamp(-100, -50, 100, 50)
    lurek.log.info(tostring("clamped"))
    layer:clearClamp()
    lurek.log.info(tostring("clamp cleared"))
end
```

---

#### `LParallaxLayer:clearEffects`

Clears shader effect passes from this layer.

```lua
LParallaxLayer:clearEffects()
```

**Example**

```lua
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:addEffectPass("blur", { radius = 1.5 })
    layer:addEffectPass("tint", { r = 1.0, g = 0.8, b = 0.6, a = 1.0 })
    lurek.log.info(tostring("effects = " .. layer:effectCount()))
    layer:clearEffects()
    lurek.log.info(tostring("after clear = " .. layer:effectCount()))
end
```

---

#### `LParallaxLayer:effectCount`

Returns the shader effect pass count for this layer.

```lua
LParallaxLayer:effectCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Effect pass count. |

**Example**

```lua
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:addEffectPass("blur", { radius = 1.5 })
    layer:addEffectPass("tint", { r = 1.0, g = 0.8, b = 0.6, a = 1.0 })
    lurek.log.info(tostring("effects = " .. layer:effectCount()))
    layer:clearEffects()
    lurek.log.info(tostring("after clear = " .. layer:effectCount()))
end
```

---

#### `LParallaxLayer:getAutoscroll`

Returns layer autoscroll velocity.

```lua
LParallaxLayer:getAutoscroll()
```

**Returns**

| Type | Description |
|------|-------------|
| number | X velocity. |
| number | Y velocity. |

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
    lurek.log.info(tostring("autoscroll = " .. vx .. "," .. vy))
end
```

---

#### `LParallaxLayer:getBlendMode`

Returns the current layer blend mode name.

```lua
LParallaxLayer:getBlendMode()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Blend mode name. |

**Example**

```lua
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        blend_mode = "screen",
    })
    lurek.log.info(tostring("blend = " .. layer:getBlendMode()))
end
```

---

#### `LParallaxLayer:getDepth`

Returns parallax depth from this object.

```lua
LParallaxLayer:getDepth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Depth value. |

**Example**

```lua
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        depth = 0.8,
    })
    lurek.log.info(tostring("depth = " .. layer:getDepth()))
end
```

---

#### `LParallaxLayer:getMotionStretch`

Returns the current motion stretch settings.

```lua
LParallaxLayer:getMotionStretch()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | Motion stretch flag. |
| number | Stretch strength. |
| number | Maximum stretch scale. |

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
    lurek.log.info(tostring("stretch enabled=" .. tostring(enabled) .. " strength=" .. strength .. " max=" .. max_scale))
end
```

---

#### `LParallaxLayer:getOffset`

Returns layer offset for this object.

```lua
LParallaxLayer:getOffset()
```

**Returns**

| Type | Description |
|------|-------------|
| number | X offset. |
| number | Y offset. |

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
    lurek.log.info(tostring("offset = " .. ox .. "," .. oy))
end
```

---

#### `LParallaxLayer:getOpacity`

Returns layer opacity from this object.

```lua
LParallaxLayer:getOpacity()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Opacity value. |

**Example**

```lua
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        opacity = 0.35,
    })
    lurek.log.info(tostring("opacity = " .. layer:getOpacity()))
end
```

---

#### `LParallaxLayer:getScrollFactor`

Returns layer scroll factor from this object.

```lua
LParallaxLayer:getScrollFactor()
```

**Returns**

| Type | Description |
|------|-------------|
| number | X scroll factor. |
| number | Y scroll factor. |

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
    lurek.log.info(tostring("scroll = " .. sx .. "," .. sy))
end
```

---

#### `LParallaxLayer:getShader`

Returns the draw-target shader bound to this parallax layer, if any.

```lua
LParallaxLayer:getShader()
```

**Returns**

| Type | Description |
|------|-------------|
| [LShader](render.md#lshader)? | Bound shader handle, or nil. |

**Example**

```lua
do
    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = img, opacity = 0.8 })
    local active = layer:getShader()
    lurek.log.info("parallax shader active=" .. tostring(active ~= nil))
    lurek.log.info("parallax opacity=" .. tostring(layer:getOpacity()))
end
```

---

#### `LParallaxLayer:getStats`

Returns telemetry for the current runtime camera and viewport.

```lua
LParallaxLayer:getStats()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Parallax layer telemetry fields. |

**Example**

```lua
do

    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = img, z = 3, depth = 0.4, tiling = true })
    layer:setAutoscroll(16, 0)
    layer:addEffectPass("tint", { r = 1.0, g = 0.8, b = 0.6, a = 1.0 })
    local stats = layer:getStats()
    lurek.log.info(tostring("layer stats tiles=" .. stats.visible_tile_count .. " effects=" .. stats.effect_pass_count))
    lurek.log.info(tostring("layer stats z=" .. stats.z .. " depth=" .. stats.depth))
end
```

---

#### `LParallaxLayer:getTiling`

Returns whether layer tiling is enabled.

```lua
LParallaxLayer:getTiling()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when tiling is enabled. |

**Example**

```lua
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        tiling = true,
    })
    lurek.log.info(tostring("tiling = " .. tostring(layer:getTiling())))
end
```

---

#### `LParallaxLayer:getTint`

Returns layer tint color from this object.

```lua
LParallaxLayer:getTint()
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

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        tint_r = 0.6,
        tint_g = 0.8,
        tint_b = 1.0,
        tint_a = 0.75,
    })
    local r, g, b, a = layer:getTint()
    lurek.log.info(tostring("tint = " .. r .. "," .. g .. "," .. b .. "," .. a))
end
```

---

#### `LParallaxLayer:getZ`

Returns layer z order from this object.

```lua
LParallaxLayer:getZ()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Z order. |

**Example**

```lua
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        z = -5,
    })
    lurek.log.info(tostring("z = " .. layer:getZ()))
end
```

---

#### `LParallaxLayer:isVisible`

Returns layer visibility and returns a boolean.

```lua
LParallaxLayer:isVisible()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when visible. |

**Example**

```lua
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        visible = false,
    })
    lurek.log.info(tostring("visible = " .. tostring(layer:isVisible())))
end
```

---

#### `LParallaxLayer:render`

Enqueues render commands using explicit camera coordinates.

```lua
LParallaxLayer:render(cam_x, cam_y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cam_x` | number | Camera x coordinate. |
| `cam_y` | number | Camera y coordinate. |

**Example**

```lua
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setAutoscroll(50, 0)
    layer:update(0.016)
    layer:render(100, 50)
    layer:renderAuto()
    lurek.log.info(tostring("rendered"))
end
```

---

#### `LParallaxLayer:renderAuto`

Enqueues render commands using the runtime camera.

```lua
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
    lurek.log.info(tostring("rendered"))
end
```

---

#### `LParallaxLayer:resetAutoscroll`

Resets the layer autoscroll offset to zero.

```lua
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
    lurek.log.info(tostring("velocity still = " .. vx .. "," .. vy))
    lurek.log.info(tostring("autoscroll reset"))
end
```

---

#### `LParallaxLayer:setAutoscroll`

Sets the layer autoscroll velocity values.

```lua
LParallaxLayer:setAutoscroll(vx, vy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `vx` | number | X autoscroll velocity. |
| `vy` | number | Y autoscroll velocity. |

**Example**

```lua
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setAutoscroll(20, 0)
    local vx, vy = layer:getAutoscroll()
    lurek.log.info(tostring("autoscroll = " .. vx .. "," .. vy))
    layer:update(1.0)
    layer:resetAutoscroll()
    lurek.log.info(tostring("autoscroll reset"))
end
```

---

#### `LParallaxLayer:setBlendMode`

Sets the layer blend mode by string name.

```lua
LParallaxLayer:setBlendMode(mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | string | Blend mode name. |

**Example**

```lua
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setBlendMode("add")
    lurek.log.info(tostring("blend = " .. layer:getBlendMode()))
    layer:setBlendMode("alpha")
    lurek.log.info(tostring("blend = " .. layer:getBlendMode()))
end
```

---

#### `LParallaxLayer:setClamp`

Sets clamp bounds for layer movement.

```lua
LParallaxLayer:setClamp(min_x, min_y, max_x, max_y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min_x` | number | Minimum X bound. |
| `min_y` | number | Minimum Y bound. |
| `max_x` | number | Maximum X bound. |
| `max_y` | number | Maximum Y bound. |

**Example**

```lua
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setClamp(-100, -50, 100, 50)
    lurek.log.info(tostring("clamped"))
    layer:clearClamp()
    lurek.log.info(tostring("clamp cleared"))
end
```

---

#### `LParallaxLayer:setDepth`

Sets parallax depth for this object.

```lua
LParallaxLayer:setDepth(z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `z` | number | Depth value. |

**Example**

```lua
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    lurek.log.info(tostring("depth before = " .. layer:getDepth()))
    layer:setDepth(0.5)
    lurek.log.info(tostring("depth = " .. layer:getDepth()))
    layer:setZ(layer:getZ() + 1)
end
```

---

#### `LParallaxLayer:setMotionStretch`

Sets the motion stretch settings for this layer.

```lua
LParallaxLayer:setMotionStretch(enabled, strength, max_scale)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | boolean | Motion stretch flag. |
| `strength` | number | Stretch strength. |
| `max_scale` | number | Maximum stretch scale. |

**Example**

```lua
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setMotionStretch(true, 0.5, 2.0)
    local enabled, strength, max_scale = layer:getMotionStretch()
    lurek.log.info(tostring("stretch enabled=" .. tostring(enabled) .. " strength=" .. strength .. " max=" .. max_scale))
end
```

---

#### `LParallaxLayer:setOffset`

Sets the layer pixel offset for this object.

```lua
LParallaxLayer:setOffset(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X offset. |
| `y` | number | Y offset. |

**Example**

```lua
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setOffset(10, -5)
    local ox, oy = layer:getOffset()
    lurek.log.info(tostring("offset = " .. ox .. "," .. oy))
end
```

---

#### `LParallaxLayer:setOpacity`

Sets layer opacity, clamped to 0..1.

```lua
LParallaxLayer:setOpacity(a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `a` | number | Opacity value. |

**Example**

```lua
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    lurek.log.info(tostring("opacity before = " .. layer:getOpacity()))
    layer:setOpacity(0.7)
    lurek.log.info(tostring("opacity = " .. layer:getOpacity()))
    layer:render(0, 0)
end
```

---

#### `LParallaxLayer:setRepeat`

Sets horizontal and vertical repeat flags.

```lua
LParallaxLayer:setRepeat(rx, ry)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `rx` | boolean | Repeat horizontally. |
| `ry` | boolean | Repeat vertically. |

**Example**

```lua
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setRepeat(true, false)
    layer:render(32, 16)
    lurek.log.info(tostring("repeat set: horizontal only"))
    lurek.log.info(tostring("z = " .. layer:getZ()))
end
```

---

#### `LParallaxLayer:setScale`

Sets the layer scale factor for this object.

```lua
LParallaxLayer:setScale(sx, sy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sx` | number | X scale factor. |
| `sy` | number | Y scale factor. |

**Example**

```lua
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setScale(2.0, 2.0)
    layer:render(0, 0)
    lurek.log.info(tostring("scaled 2x"))
    lurek.log.info(tostring("type = " .. layer:type()))
end
```

---

#### `LParallaxLayer:setScrollFactor`

Sets layer scroll factor for this object.

```lua
LParallaxLayer:setScrollFactor(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X scroll factor. |
| `y` | number | Y scroll factor. |

**Example**

```lua
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setScrollFactor(0.5, 0.2)
    local sx, sy = layer:getScrollFactor()
    lurek.log.info(tostring("scroll = " .. sx .. "," .. sy))
end
```

---

#### `LParallaxLayer:setShader`

Binds a draw-target shader to this parallax layer's generated render commands. Pass nil to clear.

```lua
LParallaxLayer:setShader(shader)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `shader?` | [LShader](render.md#lshader) | Shader created with `lurek.render.newShader(code, { target = "draw" })`, or nil to clear. |

**Example**

```lua
do
    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = img, z = -10, tiling = true })
    local before = layer:getShader()
    layer:setShader(nil)
    local after = layer:getShader()
    lurek.log.info("parallax shader cleared=" .. tostring(after == nil))
    lurek.log.info("parallax previous shader=" .. tostring(before ~= nil))
end
```

---

#### `LParallaxLayer:setTileSize`

Sets tile size for tiling for this object.

```lua
LParallaxLayer:setTileSize(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | number | Tile width. |
| `h` | number | Tile height. |

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
    lurek.log.info(tostring("tile size set to 64x64"))
    lurek.log.info(tostring("rendered tiled layer"))
end
```

---

#### `LParallaxLayer:setTiling`

Enables or disables the layer tiling mode.

```lua
LParallaxLayer:setTiling(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | boolean | Tiling flag. |

**Example**

```lua
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    lurek.log.info(tostring("tiling before = " .. tostring(layer:getTiling())))
    layer:setTiling(true)
    lurek.log.info(tostring("tiling = " .. tostring(layer:getTiling())))
    layer:render(0, 0)
end
```

---

#### `LParallaxLayer:setTint`

Sets layer tint color for this object.

```lua
LParallaxLayer:setTint(r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | number | Red channel (0-1). |
| `g` | number | Green channel (0-1). |
| `b` | number | Blue channel (0-1). |
| `a` | number | Alpha channel (0-1). |

**Example**

```lua
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setTint(1.0, 0.8, 0.6, 1.0)
    local r, g, b, a = layer:getTint()
    lurek.log.info(tostring("tint = " .. r .. "," .. g .. "," .. b .. "," .. a))
end
```

---

#### `LParallaxLayer:setVisible`

Sets layer visibility for this object.

```lua
LParallaxLayer:setVisible(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | boolean | Visibility flag. |

**Example**

```lua
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setVisible(false)
    lurek.log.info(tostring("visible = " .. tostring(layer:isVisible())))
    layer:setVisible(true)
    lurek.log.info(tostring("visible = " .. tostring(layer:isVisible())))
end
```

---

#### `LParallaxLayer:setZ`

Sets the layer z order for this object.

```lua
LParallaxLayer:setZ(z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `z` | number | Z order. |

**Example**

```lua
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    lurek.log.info(tostring("z before = " .. layer:getZ()))
    layer:setZ(-5)
    lurek.log.info(tostring("z = " .. layer:getZ()))
    layer:render(0, 0)
end
```

---

#### `LParallaxLayer:type`

Returns the Lua-visible type name for this parallax layer handle.

```lua
LParallaxLayer:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LParallaxLayer](#lparallaxlayer)`. |

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
    lurek.log.info(tostring(layer:type()))
end
```

---

#### `LParallaxLayer:update`

Advances parallax layer autoscroll by delta time.

```lua
LParallaxLayer:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Delta time in seconds. |

**Example**

```lua
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setAutoscroll(50, 0)
    layer:update(0.016)
    layer:render(100, 50)
    layer:renderAuto()
    lurek.log.info(tostring("rendered"))
end
```

---

## LParallaxSet

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LParallaxSet:addLayer`

Adds a parallax layer to this set handle.

```lua
LParallaxSet:addLayer(layer)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | [LParallaxLayer](#lparallaxlayer) | Layer handle. |

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
    lurek.log.info(tostring("layers = " .. set:layerCount()))
    lurek.log.info(tostring("removed = " .. tostring(set:removeLayerAt(2)) .. " layers = " .. set:layerCount()))
end
```

---

#### `LParallaxSet:getLayerZAt`

Returns z order for a layer by one-based index, or nil when out of range.

```lua
LParallaxSet:getLayerZAt(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | One-based layer index. |

**Returns**

| Type | Description |
|------|-------------|
| number | Z order. |

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
    lurek.log.info(tostring("z at 1 = " .. tostring(set:getLayerZAt(1))))
    lurek.log.info(tostring("z at 2 = " .. tostring(set:getLayerZAt(2))))
    set:sortByZ()
    lurek.log.info(tostring("sorted: z at 1 = " .. tostring(set:getLayerZAt(1))))
end
```

---

#### `LParallaxSet:getName`

Returns this set name from this object.

```lua
LParallaxSet:getName()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Set name. |

**Example**

```lua
do

    local set = lurek.parallax.newSet("temp")
    lurek.log.info(tostring("initial name = " .. set:getName()))
    set:setName("sky_layers")
    lurek.log.info(tostring("name = " .. set:getName()))
    set:setVisible(true)
    lurek.log.info(tostring("visible = " .. tostring(set:isVisible())))
end
```

---

#### `LParallaxSet:getStats`

Returns aggregated telemetry for all layers in the set.

```lua
LParallaxSet:getStats()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Set-level telemetry fields. |

**Example**

```lua
do

    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local set = lurek.parallax.newSet("stats_set")
    set:addLayer(lurek.parallax.newLayer({ texture = img, z = 1, tiling = true }))
    set:addLayer(lurek.parallax.newLayer({ texture = img, z = 5, depth = 0.7 }))
    local stats = set:getStats()
    lurek.log.info(tostring("set stats name=" .. stats.name .. " layers=" .. stats.layer_count))
    lurek.log.info(tostring("set stats visible tiles=" .. stats.visible_tile_count .. " effects=" .. stats.effect_pass_count))
end
```

---

#### `LParallaxSet:isVisible`

Returns set visibility and returns a boolean.

```lua
LParallaxSet:isVisible()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when visible. |

**Example**

```lua
do

    local set = lurek.parallax.newSet("temp")
    lurek.log.info(tostring("visible before = " .. tostring(set:isVisible())))
    set:setVisible(false)
    lurek.log.info(tostring("visible = " .. tostring(set:isVisible())))
    set:setVisible(true)
    lurek.log.info(tostring("visible after restore = " .. tostring(set:isVisible())))
end
```

---

#### `LParallaxSet:layerCount`

Returns the number of layers in this set.

```lua
LParallaxSet:layerCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Layer count. |

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
    lurek.log.info(tostring("layers = " .. set:layerCount()))
    lurek.log.info(tostring("removed = " .. tostring(set:removeLayerAt(2)) .. " layers = " .. set:layerCount()))
end
```

---

#### `LParallaxSet:removeLayerAt`

Removes a layer by one-based index.

```lua
LParallaxSet:removeLayerAt(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | One-based layer index. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a layer was removed. |

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
    lurek.log.info(tostring("layers = " .. set:layerCount()))
    lurek.log.info(tostring("removed = " .. tostring(set:removeLayerAt(2)) .. " layers = " .. set:layerCount()))
end
```

---

#### `LParallaxSet:render`

Enqueues render commands for all visible set layers using explicit camera coordinates.

```lua
LParallaxSet:render(cam_x, cam_y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cam_x` | number | Camera x coordinate. |
| `cam_y` | number | Camera y coordinate. |

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
    lurek.log.info(tostring("set rendered"))
end
```

---

#### `LParallaxSet:renderAuto`

Enqueues render commands for all visible set layers using the runtime camera.

```lua
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
    lurek.log.info(tostring("set rendered"))
end
```

---

#### `LParallaxSet:setName`

Sets this parallax set name for this object.

```lua
LParallaxSet:setName(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Set name. |

**Example**

```lua
do

    local set = lurek.parallax.newSet("temp")
    set:setName("sky_layers")
    lurek.log.info(tostring("name = " .. set:getName()))
    set:setVisible(false)
    lurek.log.info(tostring("visible = " .. tostring(set:isVisible())))
    set:setVisible(true)
    lurek.log.info(tostring("visible = " .. tostring(set:isVisible())))
end
```

---

#### `LParallaxSet:setVisible`

Sets set visibility for this object.

```lua
LParallaxSet:setVisible(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | boolean | Visibility flag. |

**Example**

```lua
do

    local set = lurek.parallax.newSet("temp")
    set:setName("sky_layers")
    lurek.log.info(tostring("name = " .. set:getName()))
    set:setVisible(false)
    lurek.log.info(tostring("visible = " .. tostring(set:isVisible())))
    set:setVisible(true)
    lurek.log.info(tostring("visible = " .. tostring(set:isVisible())))
end
```

---

#### `LParallaxSet:sortByZ`

Sorts layers by z order on this object.

```lua
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
    lurek.log.info(tostring("before sort z1 = " .. tostring(set:getLayerZAt(1))))
    lurek.log.info(tostring("before sort z2 = " .. tostring(set:getLayerZAt(2))))
    set:sortByZ()
    lurek.log.info(tostring("sorted: z at 1 = " .. tostring(set:getLayerZAt(1))))
end
```

---

#### `LParallaxSet:type`

Returns the Lua-visible type name for this parallax set handle.

```lua
LParallaxSet:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LParallaxSet](#lparallaxset)`. |

**Example**

```lua
do

    local set = lurek.parallax.newSet("bg_set")
    local type_name = set:type()
    set:setVisible(true)
    lurek.log.info(tostring("set type = " .. type_name))
    lurek.log.info(tostring("set name = " .. set:getName()))
    lurek.log.info(tostring("layers = " .. set:layerCount()))
end
```

---

#### `LParallaxSet:update`

Updates all layers in this parallax set.

```lua
LParallaxSet:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Delta time in seconds. |

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
    lurek.log.info(tostring("set rendered"))
end
```

---
