# Camera

- The `camera` module is a versatile and fully-featured 2D camera and viewport management system positioned within the Platform Services tier.

Its primary role is to handle world-to-screen coordinate mapping, transform calculations, viewport scaling, and dynamic camera behaviors without directly allocating or managing GPU resources. At its core, the module exposes two main camera types: the lightweight `Camera`, providing minimal state like position, zoom, rotation, and view-matrix generation; and the gameplay-ready `Camera2D`, which adds robust tracking behaviors, smooth interpolation, and boundary clamping.

A defining feature of `Camera2D` is its target tracking capability. It supports smooth-follow interpolation using linear, smooth-step, or ease-out-cubic easing. Developers can fine-tune tracking through dead zones, look-ahead multipliers, and zoom/rotation damping. For common use cases, the module provides out-of-the-box follow presets: tight, cinematic, balanced, and aggressive. The `Viewport` subsystem works hand-in-hand with the camera to resolve window resizing by mapping the logical game surface to the physical window using configurable scale modes (Letterbox, Stretch, PixelPerfect).

To enrich visual feedback and game feel, the module implements a suite of composable camera effects. These include `CameraShake` for impactful events, `ZoomPulse` for quick elastic snap-zooms, `CameraSway` for continuous sinusoidal offsets (ideal for underwater or rocking effects), and `CameraBreathing` for subtle rhythmic zoom oscillations. Furthermore, `CameraPath` and `CameraZoomTween` allow for scripted, eased transitions across waypoints and zoom levels over time.

For local multiplayer or complex UI requirements, the module provides `CameraRig2D`, a multi-view manager that stores named camera instances. This rig enables preset viewport layouts such as split-screen, picture-in-picture, and minimaps, performing bulk updates across multiple views deterministically. Finally, the `render` sub-module translates these mathematical states into actionable push/pop transform sequences for the rendering pipeline. The entire feature set is cleanly exposed to Lua through the `lurek.camera.*` namespace, allowing script authors complete control over game feel and multi-camera orchestration.

## Functions

### `lurek.camera.new`

Creates a 2D camera with optional virtual viewport size.

```lua
-- signature
lurek.camera.new(vw, vh)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `vw?` | `number` | Virtual viewport width; defaults to 800. |
| `vh?` | `number` | Virtual viewport height; defaults to 600. |

**Returns**

| Type | Description |
|------|-------------|
| `LCamera` | New camera handle. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    print("camera created = " .. tostring(cam ~= nil))
    print("camera type = " .. cam:type())
end
```

---

### `lurek.camera.newCamera`

Creates a 2D camera with optional virtual viewport size.

```lua
-- signature
lurek.camera.newCamera(vw, vh)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `vw?` | `number` | Virtual viewport width; defaults to 800. |
| `vh?` | `number` | Virtual viewport height; defaults to 600. |

**Returns**

| Type | Description |
|------|-------------|
| `LCamera` | New camera handle. |

**Example**

```lua
do
    local cam = lurek.camera.newCamera(1280, 720)
    print("camera created = " .. tostring(cam ~= nil))
    print("viewport width = " .. select(3, cam:getViewport()))
end
```

---

### `lurek.camera.newRig`

Creates an empty named camera rig. This function is exposed to Lua scripts.

```lua
-- signature
lurek.camera.newRig()
```

**Returns**

| Type | Description |
|------|-------------|
| `LCameraRig` | New camera rig handle. |

**Example**

```lua
do
    local rig = lurek.camera.newRig()
    print("rig created = " .. tostring(rig ~= nil))
    print("rig type = " .. rig:type())
end
```

---

## LCamera

### `LCamera:apply`

Appends render commands that apply this camera transform.

```lua
-- signature
LCamera:apply()
```

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(400, 300)
    cam:apply()
    local x, y = cam:getPosition()
    print("camera applied")
    print("position = " .. x .. ", " .. y)
end
```

---

### `LCamera:attach`

Appends render commands that attach this camera transform.

```lua
-- signature
LCamera:attach()
```

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:attach()
    print("camera attached")
end
```

---

### `LCamera:clearParallaxFactors`

Clears all layer parallax factor overrides.

```lua
-- signature
LCamera:clearParallaxFactors()
```

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setParallaxFactor("fg", 1.2)
    cam:clearParallaxFactors()
    print("parallax cleared")
    print("fg parallax = " .. tostring(cam:getParallaxFactor("fg")))
end
```

---

### `LCamera:clearTarget`

Clears the follow target. This method is available to Lua scripts.

```lua
-- signature
LCamera:clearTarget()
```

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setTarget(100, 100)
    cam:clearTarget()
    local ok = cam:getTarget()
    print("target cleared")
    print("has target = " .. tostring(ok))
end
```

---

### `LCamera:detach`

Appends a render command that detaches the active camera transform.

```lua
-- signature
LCamera:detach()
```

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:attach()
    cam:detach()
    print("camera detached")
end
```

---

### `LCamera:followPath`

Starts camera movement along an array of waypoint tables.

```lua
-- signature
LCamera:followPath(points, duration)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `points` | `table` | Array of point tables using numeric indices `1` and `2` for X and Y. |
| `duration` | `number` | Total path duration in seconds. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    local points = { { 0, 0 }, { 400, 200 }, { 800, 0 } }
    cam:followPath(points, 3.0)
    print("following path over 3s")
    print("path progress = " .. tostring(cam:pathProgress()))
end
```

---

### `LCamera:getBounds`

Returns camera bounds with a leading availability flag.

```lua
-- signature
LCamera:getBounds()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | a Has-bounds flag followed by X, Y, width, and height. |
| `number` | b Has-bounds flag followed by X, Y, width, and height. |
| `number` | c Has-bounds flag followed by X, Y, width, and height. |
| `number` | d Has-bounds flag followed by X, Y, width, and height. |
| `number` | e Has-bounds flag followed by X, Y, width, and height. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setBounds(0, 0, 2000, 1500)
    local ok, bx, by, bw, bh = cam:getBounds()
    print("bounds = " .. tostring(ok) .. "," .. tostring(bx) .. "," .. tostring(by) .. "," .. tostring(bw) .. "," .. tostring(bh))
end
```

---

### `LCamera:getDeadZone`

Returns follow dead-zone dimensions with a leading availability flag.

```lua
-- signature
LCamera:getDeadZone()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | a Has-dead-zone flag followed by width and height. |
| `number` | b Has-dead-zone flag followed by width and height. |
| `number` | c Has-dead-zone flag followed by width and height. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setDeadZone(40, 20)
    local ok, w, h = cam:getDeadZone()
    print("dead zone = " .. tostring(ok) .. "," .. tostring(w) .. "x" .. tostring(h))
end
```

---

### `LCamera:getEffectOffset`

Returns combined camera effect offset.

```lua
-- signature
LCamera:getEffectOffset()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Effect X and Y offset. |
| `number` | b Effect X and Y offset. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    local ox, oy = cam:getEffectOffset()
    print("effect offset = " .. ox .. ", " .. oy)
end
```

---

### `LCamera:getEffectiveZoom`

Returns zoom after camera effects are applied.

```lua
-- signature
LCamera:getEffectiveZoom()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Effective zoom factor. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setZoom(2.0)
    local ez = cam:getEffectiveZoom()
    print("effective zoom = " .. ez)
    print("base zoom = " .. tostring(cam:getZoom()))
end
```

---

### `LCamera:getFollowEasing`

Returns target follow easing mode.

```lua
-- signature
LCamera:getFollowEasing()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Easing name `linear`, `smoothstep`, or `easeout`. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setFollowEasing("linear")
    local e = cam:getFollowEasing()
    print("easing = " .. e)
end
```

---

### `LCamera:getFollowSmooth`

Returns follow smoothing speed. This method is available to Lua scripts.

```lua
-- signature
LCamera:getFollowSmooth()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Current follow smoothing speed. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setFollowSmooth(3.0)
    local s = cam:getFollowSmooth()
    print("follow smooth = " .. s)
end
```

---

### `LCamera:getLookAhead`

Returns follow look-ahead multiplier.

```lua
-- signature
LCamera:getLookAhead()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Current look-ahead multiplier. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setLookAhead(2.0)
    local la = cam:getLookAhead()
    print("look ahead = " .. la)
end
```

---

### `LCamera:getParallaxFactor`

Returns a parallax factor for a named layer.

```lua
-- signature
LCamera:getParallaxFactor(layer)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | `string` | Layer name. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Stored parallax factor, or 1.0 when the layer has no override. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setParallaxFactor("clouds", 0.3)
    local f = cam:getParallaxFactor("clouds")
    print("clouds parallax = " .. f)
end
```

---

### `LCamera:getPosition`

Returns the camera world position.

```lua
-- signature
LCamera:getPosition()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Camera X and Y position in world units. |
| `number` | b Camera X and Y position in world units. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(100, 50)
    local x, y = cam:getPosition()
    print("x=" .. x .. " y=" .. y)
end
```

---

### `LCamera:getRenderOffset`

Returns current render offset after camera effects.

```lua
-- signature
LCamera:getRenderOffset()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Render X and Y offset. |
| `number` | b Render X and Y offset. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    local rx, ry = cam:getRenderOffset()
    print("render offset = " .. rx .. ", " .. ry)
end
```

---

### `LCamera:getRotation`

Returns the camera rotation. This method is available to Lua scripts.

```lua
-- signature
LCamera:getRotation()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Current rotation in radians. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setRotation(1.5)
    local r = cam:getRotation()
    print("rotation = " .. r)
end
```

---

### `LCamera:getRotationConstraints`

Returns rotation constraints with availability flags.

```lua
-- signature
LCamera:getRotationConstraints()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | a Has-min flag and value followed by has-max flag and value. |
| `number` | b Has-min flag and value followed by has-max flag and value. |
| `boolean` | c Has-min flag and value followed by has-max flag and value. |
| `number` | d Has-min flag and value followed by has-max flag and value. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setRotationConstraints(-1.0, 1.0)
    local mn, mx = cam:getRotationConstraints()
    print("rotation range = " .. mn .. " to " .. mx)
end
```

---

### `LCamera:getRotationDamping`

Returns rotation damping. This method is available to Lua scripts.

```lua
-- signature
LCamera:getRotationDamping()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Current rotation damping value. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setRotationDamping(0.7)
    local d = cam:getRotationDamping()
    print("rot damping = " .. d)
end
```

---

### `LCamera:getShakeOffset`

Returns current camera shake offset.

```lua
-- signature
LCamera:getShakeOffset()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Shake X and Y offset. |
| `number` | b Shake X and Y offset. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:shake(5.0, 0.5)
    cam:update(0.01)
    local sx, sy = cam:getShakeOffset()
    print("shake = " .. sx .. ", " .. sy)
end
```

---

### `LCamera:getTarget`

Returns the follow target with a leading availability flag.

```lua
-- signature
LCamera:getTarget()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | a Has-target flag followed by target X and Y. |
| `number` | b Has-target flag followed by target X and Y. |
| `number` | c Has-target flag followed by target X and Y. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setTarget(250, 125)
    local ok, tx, ty = cam:getTarget()
    print("target = " .. tostring(ok) .. ", " .. tostring(tx) .. ", " .. tostring(ty))
end
```

---

### `LCamera:getViewport`

Returns the camera viewport rectangle.

```lua
-- signature
LCamera:getViewport()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Viewport X, Y, width, and height. |
| `number` | b Viewport X, Y, width, and height. |
| `number` | c Viewport X, Y, width, and height. |
| `number` | d Viewport X, Y, width, and height. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setViewport(10, 10, 780, 580)
    local x, y, w, h = cam:getViewport()
    print("viewport = " .. x .. "," .. y .. "," .. w .. "," .. h)
end
```

---

### `LCamera:getVisibleArea`

Returns the world-space area visible through this camera.

```lua
-- signature
LCamera:getVisibleArea()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Visible X, Y, width, and height. |
| `number` | b Visible X, Y, width, and height. |
| `number` | c Visible X, Y, width, and height. |
| `number` | d Visible X, Y, width, and height. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(400, 300)
    local x, y, w, h = cam:getVisibleArea()
    print("visible = " .. x .. "," .. y .. " " .. w .. "x" .. h)
end
```

---

### `LCamera:getZoom`

Returns the camera zoom factor. This method is available to Lua scripts.

```lua
-- signature
LCamera:getZoom()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Current zoom factor. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setZoom(0.5)
    local z = cam:getZoom()
    print("zoom = " .. z)
end
```

---

### `LCamera:getZoomConstraints`

Returns zoom constraints with availability flags.

```lua
-- signature
LCamera:getZoomConstraints()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | a Has-min flag and value followed by has-max flag and value. |
| `number` | b Has-min flag and value followed by has-max flag and value. |
| `boolean` | c Has-min flag and value followed by has-max flag and value. |
| `number` | d Has-min flag and value followed by has-max flag and value. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setZoomConstraints(0.25, 3.0)
    local _, mn, _, mx = cam:getZoomConstraints()
    print("zoom range = " .. mn .. " to " .. mx)
end
```

---

### `LCamera:getZoomDamping`

Returns zoom damping. This method is available to Lua scripts.

```lua
-- signature
LCamera:getZoomDamping()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Current zoom damping value. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setZoomDamping(0.8)
    local d = cam:getZoomDamping()
    print("damping = " .. d)
end
```

---

### `LCamera:hasBounds`

Returns whether camera bounds are active.

```lua
-- signature
LCamera:hasBounds()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when bounds are active. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setBounds(0, 0, 1000, 1000)
    print("has bounds = " .. tostring(cam:hasBounds()))
end
```

---

### `LCamera:isBreathing`

Returns whether breathing zoom animation is active.

```lua
-- signature
LCamera:isBreathing()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when breathing is active. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:startBreathing(0.02, 0.5)
    print("breathing = " .. tostring(cam:isBreathing()))
end
```

---

### `LCamera:isSway`

Returns whether camera sway is active.

```lua
-- signature
LCamera:isSway()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when sway is active. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:startSway(1.0, 1.0, 1.0, 0.5)
    print("is sway = " .. tostring(cam:isSway()))
end
```

---

### `LCamera:lookAt`

Centers the camera on a world position.

```lua
-- signature
LCamera:lookAt(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | World X position. |
| `y` | `number` | World Y position. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:lookAt(500, 250)
    local x, y = cam:getPosition()
    print("looking at " .. x .. ", " .. y)
end
```

---

### `LCamera:move`

Moves the camera by a delta. This method is available to Lua scripts.

```lua
-- signature
LCamera:move(dx, dy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dx` | `number` | X delta in world units. |
| `dy` | `number` | Y delta in world units. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(100, 100)
    cam:move(50, -25)
    local x, y = cam:getPosition()
    print("moved to " .. x .. ", " .. y)
end
```

---

### `LCamera:onWindowResize`

Updates camera viewport state after a window resize.

```lua
-- signature
LCamera:onWindowResize(window_w, window_h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `window_w` | `number` | New window width in pixels. |
| `window_h` | `number` | New window height in pixels. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:onWindowResize(1920, 1080)
    local _, _, w, h = cam:getViewport()
    print("resized to 1920x1080")
    print("viewport size = " .. w .. "x" .. h)
end
```

---

### `LCamera:onWindowResizeScaled`

Updates camera viewport state using a virtual game size and scale mode.

```lua
-- signature
LCamera:onWindowResizeScaled(game_w, game_h, window_w, window_h, mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `game_w` | `number` | Virtual game width in pixels. |
| `game_h` | `number` | Virtual game height in pixels. |
| `window_w` | `number` | New window width in pixels. |
| `window_h` | `number` | New window height in pixels. |
| `mode` | `string` | Scale mode `letterbox`, `stretch`, or `pixelperfect`. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:onWindowResizeScaled(800, 600, 1920, 1080, "letterbox")
    local x, y, w, h = cam:getViewport()
    print("scaled resize applied")
    print("viewport = " .. x .. "," .. y .. "," .. w .. "," .. h)
end
```

---

### `LCamera:pathProgress`

Returns active path progress. This method is available to Lua scripts.

```lua
-- signature
LCamera:pathProgress()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Normalized path progress from 0 to 1, or 1 when no path is active. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    local points = { { 0, 0 }, { 100, 100 } }
    cam:followPath(points, 1.0)
    cam:updatePath(0.5)
    local p = cam:pathProgress()
    print("progress = " .. p)
    print("progress halfway = " .. tostring(p > 0 and p < 1))
end
```

---

### `LCamera:presetAggressiveFollow`

Applies the aggressive follow camera preset.

```lua
-- signature
LCamera:presetAggressiveFollow()
```

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:presetAggressiveFollow()
    print("aggressive follow preset applied")
end
```

---

### `LCamera:presetBalancedFollow`

Applies the balanced follow camera preset.

```lua
-- signature
LCamera:presetBalancedFollow()
```

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:presetBalancedFollow()
    print("balanced follow preset applied")
end
```

---

### `LCamera:presetCinematicFollow`

Applies the cinematic follow camera preset.

```lua
-- signature
LCamera:presetCinematicFollow()
```

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:presetCinematicFollow()
    print("cinematic follow preset applied")
end
```

---

### `LCamera:presetTightFollow`

Applies the tight follow camera preset.

```lua
-- signature
LCamera:presetTightFollow()
```

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:presetTightFollow()
    print("tight follow preset applied")
end
```

---

### `LCamera:removeBounds`

Removes active camera bounds. This method is available to Lua scripts.

```lua
-- signature
LCamera:removeBounds()
```

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setBounds(0, 0, 1000, 1000)
    cam:removeBounds()
    print("bounds removed = " .. tostring(not cam:hasBounds()))
end
```

---

### `LCamera:reset`

Appends a render command that removes the active camera transform.

```lua
-- signature
LCamera:reset()
```

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(500, 500)
    cam:setZoom(3.0)
    cam:reset()
    print("camera reset command queued")
    print("zoom still readable = " .. tostring(cam:getZoom()))
end
```

---

### `LCamera:setBounds`

Sets camera world bounds. This method is available to Lua scripts.

```lua
-- signature
LCamera:setBounds(x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | Bounds X coordinate. |
| `y` | `number` | Bounds Y coordinate. |
| `w` | `number` | Bounds width. |
| `h` | `number` | Bounds height. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setBounds(0, 0, 3200, 2400)
    print("has bounds = " .. tostring(cam:hasBounds()))
    print("bounds set to 3200x2400")
end
```

---

### `LCamera:setDeadZone`

Sets follow dead-zone dimensions.

```lua
-- signature
LCamera:setDeadZone(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | `number` | Dead-zone width in world units. |
| `h` | `number` | Dead-zone height in world units. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setDeadZone(50, 30)
    local ok, w, h = cam:getDeadZone()
    print("dead zone active = " .. tostring(ok))
    print("dead zone = " .. tostring(w) .. "x" .. tostring(h))
end
```

---

### `LCamera:setFollowEasing`

Sets target follow easing mode. This method is available to Lua scripts.

```lua
-- signature
LCamera:setFollowEasing(easing)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `easing` | `string` | Easing name such as `linear`, `smoothstep`, or `easeout`. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setFollowEasing("quadOut")
    print("easing = " .. cam:getFollowEasing())
end
```

---

### `LCamera:setFollowSmooth`

Sets follow smoothing speed. This method is available to Lua scripts.

```lua
-- signature
LCamera:setFollowSmooth(speed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `speed` | `number` | Follow smoothing speed. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setFollowSmooth(5.0)
    print("smooth = " .. cam:getFollowSmooth())
end
```

---

### `LCamera:setLookAhead`

Sets follow look-ahead multiplier.

```lua
-- signature
LCamera:setLookAhead(mul)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mul` | `number` | Look-ahead multiplier applied to target motion. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setLookAhead(1.5)
    print("look ahead = " .. cam:getLookAhead())
end
```

---

### `LCamera:setParallaxFactor`

Sets a parallax factor for a named layer.

```lua
-- signature
LCamera:setParallaxFactor(layer, factor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | `string` | Layer name. |
| `factor` | `number` | Parallax factor, where 1.0 follows the camera fully. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setParallaxFactor("background", 0.5)
    print("parallax bg = " .. cam:getParallaxFactor("background"))
end
```

---

### `LCamera:setPosition`

Sets the camera world position. This method is available to Lua scripts.

```lua
-- signature
LCamera:setPosition(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | Camera X position in world units. |
| `y` | `number` | Camera Y position in world units. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(200, 150)
    local x, y = cam:getPosition()
    print("pos = " .. x .. ", " .. y)
end
```

---

### `LCamera:setRotation`

Sets the camera rotation. This method is available to Lua scripts.

```lua
-- signature
LCamera:setRotation(r)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | `number` | Rotation in radians. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setRotation(math.pi / 4)
    print("rotation = " .. cam:getRotation())
end
```

---

### `LCamera:setRotationConstraints`

Sets optional minimum and maximum rotation constraints.

```lua
-- signature
LCamera:setRotationConstraints(min_rot, max_rot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min_rot?` | `number` | Optional minimum rotation in radians. |
| `max_rot?` | `number` | Optional maximum rotation in radians. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setRotationConstraints(-0.5, 0.5)
    local has_min, min_r, has_max, max_r = cam:getRotationConstraints()
    print("has min/max = " .. tostring(has_min) .. "/" .. tostring(has_max))
    print("rotation constrained to [" .. min_r .. ", " .. max_r .. "]")
end
```

---

### `LCamera:setRotationDamping`

Sets rotation damping. This method is available to Lua scripts.

```lua
-- signature
LCamera:setRotationDamping(damping)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `damping` | `number` | Rotation damping value. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setRotationDamping(0.85)
    print("rotation damping = " .. cam:getRotationDamping())
end
```

---

### `LCamera:setTarget`

Sets a world-space follow target. This method is available to Lua scripts.

```lua
-- signature
LCamera:setTarget(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | Target X position. |
| `y` | `number` | Target Y position. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setTarget(500, 300)
    local ok, tx, ty = cam:getTarget()
    print("target = " .. tostring(ok) .. ", " .. tostring(tx) .. ", " .. tostring(ty))
end
```

---

### `LCamera:setViewport`

Sets the camera viewport rectangle.

```lua
-- signature
LCamera:setViewport(x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | Viewport X coordinate in screen pixels. |
| `y` | `number` | Viewport Y coordinate in screen pixels. |
| `w` | `number` | Viewport width in screen pixels. |
| `h` | `number` | Viewport height in screen pixels. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setViewport(0, 0, 400, 300)
    local x, y, w, h = cam:getViewport()
    print("viewport x,y = " .. x .. ", " .. y)
    print("viewport size = " .. w .. "x" .. h)
end
```

---

### `LCamera:setZoom`

Sets the camera zoom factor. This method is available to Lua scripts.

```lua
-- signature
LCamera:setZoom(zoom)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `zoom` | `number` | Zoom factor applied to world rendering. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setZoom(2.0)
    print("zoom = " .. cam:getZoom())
end
```

---

### `LCamera:setZoomConstraints`

Sets optional minimum and maximum zoom constraints.

```lua
-- signature
LCamera:setZoomConstraints(min_zoom, max_zoom)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min_zoom?` | `number` | Optional minimum zoom. |
| `max_zoom?` | `number` | Optional maximum zoom. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setZoomConstraints(0.5, 4.0)
    local has_min, min_z, has_max, max_z = cam:getZoomConstraints()
    print("has min/max = " .. tostring(has_min) .. "/" .. tostring(has_max))
    print("zoom constrained to [" .. min_z .. ", " .. max_z .. "]")
end
```

---

### `LCamera:setZoomDamping`

Sets zoom damping. This method is available to Lua scripts.

```lua
-- signature
LCamera:setZoomDamping(damping)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `damping` | `number` | Zoom damping value. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setZoomDamping(0.9)
    print("zoom damping = " .. cam:getZoomDamping())
end
```

---

### `LCamera:shake`

Starts a camera shake effect. This method is available to Lua scripts.

```lua
-- signature
LCamera:shake(intensity, duration)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `intensity` | `number` | Shake intensity in world units. |
| `duration` | `number` | Shake duration in seconds. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:shake(10.0, 0.5)
    print("shaking for 0.5s at intensity 10")
end
```

---

### `LCamera:startBreathing`

Starts subtle breathing zoom animation.

```lua
-- signature
LCamera:startBreathing(amplitude, rate)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `amplitude?` | `number` | Breathing zoom amplitude; defaults to 0.005. |
| `rate?` | `number` | Breathing rate; defaults to 0.2. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:startBreathing(0.02, 0.5)
    print("breathing started")
    print("is breathing = " .. tostring(cam:isBreathing()))
end
```

---

### `LCamera:startSway`

Starts camera sway offset animation.

```lua
-- signature
LCamera:startSway(amplitude_x, amplitude_y, frequency, decay)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `amplitude_x` | `number` | Horizontal sway amplitude. |
| `amplitude_y` | `number` | Vertical sway amplitude. |
| `frequency` | `number` | Sway frequency. |
| `decay?` | `number` | Sway decay value; defaults to 1.0. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:startSway(3.0, 2.0, 1.5, 0.5)
    print("sway started")
    print("is sway = " .. tostring(cam:isSway()))
end
```

---

### `LCamera:stopBreathing`

Stops breathing zoom animation. This method is available to Lua scripts.

```lua
-- signature
LCamera:stopBreathing()
```

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:startBreathing(0.01, 0.3)
    cam:stopBreathing()
    print("breathing stopped")
end
```

---

### `LCamera:stopPath`

Stops the active camera path. This method is available to Lua scripts.

```lua
-- signature
LCamera:stopPath()
```

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    local points = { { 0, 0 }, { 100, 100 } }
    cam:followPath(points, 2.0)
    cam:stopPath()
    print("path stopped")
    print("path progress = " .. tostring(cam:pathProgress()))
end
```

---

### `LCamera:stopSway`

Stops camera sway offset animation.

```lua
-- signature
LCamera:stopSway()
```

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:startSway(2.0, 1.0, 1.0, 0.3)
    cam:stopSway()
    print("sway stopped")
end
```

---

### `LCamera:stopZoom`

Stops the active zoom tween. This method is available to Lua scripts.

```lua
-- signature
LCamera:stopZoom()
```

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:zoomTo(3.0, 2.0, "linear")
    cam:stopZoom()
    print("zoom stopped")
end
```

---

### `LCamera:toScreen`

Converts world coordinates to screen coordinates.

```lua
-- signature
LCamera:toScreen(wx, wy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `wx` | `number` | World X coordinate. |
| `wy` | `number` | World Y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Screen X and Y coordinates. |
| `number` | b Screen X and Y coordinates. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(100, 100)
    local sx, sy = cam:toScreen(500, 400)
    print("screen = " .. sx .. ", " .. sy)
end
```

---

### `LCamera:toWorld`

Converts screen coordinates to world coordinates.

```lua
-- signature
LCamera:toWorld(sx, sy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sx` | `number` | Screen X coordinate. |
| `sy` | `number` | Screen Y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | a World X and Y coordinates. |
| `number` | b World X and Y coordinates. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(100, 100)
    local wx, wy = cam:toWorld(400, 300)
    print("world = " .. wx .. ", " .. wy)
end
```

---

### `LCamera:type`

Returns the Lua-visible type name for this camera handle.

```lua
-- signature
LCamera:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LCamera`. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    print("type = " .. cam:type())
end
```

---

### `LCamera:typeOf`

Returns whether this camera handle matches a supported type name.

```lua
-- signature
LCamera:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LCamera` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    print("is LCamera = " .. tostring(cam:typeOf("LCamera")))
end
```

---

### `LCamera:update`

Advances camera follow, shake, and effect state.

```lua
-- signature
LCamera:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | `number` | Elapsed time in seconds. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setTarget(200, 100)
    cam:setFollowSmooth(4.0)
    cam:update(0.016)
    local x, y = cam:getPosition()
    print("camera updated")
    print("position = " .. x .. ", " .. y)
end
```

---

### `LCamera:updatePath`

Advances the active camera path and applies its position.

```lua
-- signature
LCamera:updatePath(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | `number` | Elapsed time in seconds. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when a path position was applied. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    local points = { { 0, 0 }, { 200, 200 } }
    cam:followPath(points, 2.0)
    cam:updatePath(0.5)
    local x, y = cam:getPosition()
    print("path progress = " .. cam:pathProgress())
    print("position = " .. x .. ", " .. y)
end
```

---

### `LCamera:updateZoom`

Advances the active zoom tween and applies its zoom value.

```lua
-- signature
LCamera:updateZoom(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | `number` | Elapsed time in seconds. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when a zoom value was applied. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:zoomTo(2.0, 1.0, "linear")
    cam:updateZoom(0.5)
    print("zoom after 0.5s = " .. cam:getZoom())
end
```

---

### `LCamera:zoomPulse`

Triggers a temporary zoom pulse effect.

```lua
-- signature
LCamera:zoomPulse(amplitude, duration)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `amplitude` | `number` | Zoom pulse amplitude. |
| `duration` | `number` | Pulse duration in seconds. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:zoomPulse(0.2, 0.3)
    print("zoom pulse: amplitude=0.2, dur=0.3s")
    print("effective zoom = " .. tostring(cam:getEffectiveZoom()))
end
```

---

### `LCamera:zoomTo`

Starts a zoom tween toward a target zoom factor.

```lua
-- signature
LCamera:zoomTo(target_zoom, duration, easing)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target_zoom` | `number` | Destination zoom factor. |
| `duration` | `number` | Tween duration in seconds. |
| `easing?` | `string` | Easing name such as `linear`, `smoothstep`, or `easeout`. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:zoomTo(2.0, 1.0, "quadOut")
    print("zooming to 2x over 1s")
end
```

---

## LCameraRig

### `LCameraRig:apply`

Appends render commands for a named camera in this rig.

```lua
-- signature
LCameraRig:apply(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Camera name to apply. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the named camera exists. |

**Example**

```lua
do
    local rig = lurek.camera.newRig()
    rig:setPosition("main", 400, 300)
    local ok = rig:apply("main")
    print("applied main = " .. tostring(ok))
end
```

---

### `LCameraRig:getViewport`

Returns a named rig camera viewport with a leading availability flag.

```lua
-- signature
LCameraRig:getViewport(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Camera name to query. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | a Has-camera flag followed by viewport X, Y, width, and height. |
| `number` | b Has-camera flag followed by viewport X, Y, width, and height. |
| `number` | c Has-camera flag followed by viewport X, Y, width, and height. |
| `number` | d Has-camera flag followed by viewport X, Y, width, and height. |
| `number` | e Has-camera flag followed by viewport X, Y, width, and height. |

**Example**

```lua
do
    local rig = lurek.camera.newRig()
    rig:setPosition("left", 0, 0)
    rig:splitScreen(800, 600)
    local has, x, y, w, h = rig:getViewport("left")
    print("has=" .. tostring(has) .. " vp=" .. x .. "," .. y .. "," .. w .. "," .. h)
end
```

---

### `LCameraRig:has`

Returns whether this rig contains a named camera.

```lua
-- signature
LCameraRig:has(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Camera name to check. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the camera exists. |

**Example**

```lua
do
    local rig = lurek.camera.newRig()
    rig:setPosition("x", 0, 0)
    print("has x = " .. tostring(rig:has("x")))
end
```

---

### `LCameraRig:minimap`

Applies a minimap layout using the current window size and optional ratio.

```lua
-- signature
LCameraRig:minimap(window_w, window_h, ratio)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `window_w` | `number` | Window width in pixels. |
| `window_h` | `number` | Window height in pixels. |
| `ratio?` | `number` | Minimap size ratio; defaults to 0.25. |

**Example**

```lua
do
    local rig = lurek.camera.newRig()
    rig:setPosition("main", 400, 300)
    rig:minimap(1280, 720, 0.25)
    print("minimap layout applied")
end
```

---

### `LCameraRig:names`

Returns all camera names in this rig.

```lua
-- signature
LCameraRig:names()
```

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Camera names. |

**Example**

```lua
do
    local rig = lurek.camera.newRig()
    rig:setPosition("p1", 0, 0)
    local list = rig:names()
    print("cameras = " .. #list)
    print("first name = " .. tostring(list[1]))
end
```

---

### `LCameraRig:pictureInPicture`

Applies a picture-in-picture layout using optional inset size.

```lua
-- signature
LCameraRig:pictureInPicture(window_w, window_h, pip_w, pip_h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `window_w` | `number` | Window width in pixels. |
| `window_h` | `number` | Window height in pixels. |
| `pip_w?` | `number` | Picture-in-picture width; defaults to 320. |
| `pip_h?` | `number` | Picture-in-picture height; defaults to 180. |

**Example**

```lua
do
    local rig = lurek.camera.newRig()
    rig:setPosition("main", 200, 200)
    rig:pictureInPicture(1280, 720, 320, 180)
    print("PiP layout applied")
end
```

---

### `LCameraRig:remove`

Removes a named camera from this rig.

```lua
-- signature
LCameraRig:remove(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Camera name to remove. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the camera existed and was removed. |

**Example**

```lua
do
    local rig = lurek.camera.newRig()
    rig:setPosition("temp", 0, 0)
    local ok = rig:remove("temp")
    print("removed = " .. tostring(ok))
end
```

---

### `LCameraRig:setPosition`

Sets the position of a named rig camera, creating it if needed.

```lua
-- signature
LCameraRig:setPosition(name, x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Camera name. |
| `x` | `number` | Camera X position. |
| `y` | `number` | Camera Y position. |

**Example**

```lua
do
    local rig = lurek.camera.newRig()
    rig:setPosition("left", 100, 200)
    print("camera positioned: left")
    print("rig has left = " .. tostring(rig:has("left")))
end
```

---

### `LCameraRig:setTarget`

Sets the follow target of a named rig camera, creating it if needed.

```lua
-- signature
LCameraRig:setTarget(name, x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Camera name. |
| `x` | `number` | Target X position. |
| `y` | `number` | Target Y position. |

**Example**

```lua
do
    local rig = lurek.camera.newRig()
    rig:setPosition("cam1", 0, 0)
    rig:setTarget("cam1", 400, 300)
    print("target set on cam1")
    print("rig has cam1 = " .. tostring(rig:has("cam1")))
end
```

---

### `LCameraRig:setZoom`

Sets the zoom of a named rig camera, creating it if needed.

```lua
-- signature
LCameraRig:setZoom(name, zoom)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Camera name. |
| `zoom` | `number` | Camera zoom factor. |

**Example**

```lua
do
    local rig = lurek.camera.newRig()
    rig:setPosition("a", 0, 0)
    rig:setZoom("a", 1.5)
    local list = rig:names()
    print("zoom set on camera a")
    print("camera count = " .. tostring(#list))
end
```

---

### `LCameraRig:splitScreen`

Applies a split-screen layout using the current window size.

```lua
-- signature
LCameraRig:splitScreen(window_w, window_h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `window_w` | `number` | Window width in pixels. |
| `window_h` | `number` | Window height in pixels. |

**Example**

```lua
do
    local rig = lurek.camera.newRig()
    rig:setPosition("player1", 100, 100)
    rig:setPosition("player2", 500, 300)
    rig:splitScreen(1280, 720)
    print("split screen layout applied")
end
```

---

### `LCameraRig:type`

Returns the Lua-visible type name for this camera rig handle.

```lua
-- signature
LCameraRig:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LCameraRig`. |

**Example**

```lua
do
    local rig = lurek.camera.newRig()
    print("type = " .. rig:type())
end
```

---

### `LCameraRig:typeOf`

Returns whether this camera rig handle matches a supported type name.

```lua
-- signature
LCameraRig:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LCameraRig` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local rig = lurek.camera.newRig()
    print("is LCameraRig = " .. tostring(rig:typeOf("LCameraRig")))
end
```

---

### `LCameraRig:updateAll`

Advances every camera in this rig. This method is available to Lua scripts.

```lua
-- signature
LCameraRig:updateAll(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | `number` | Elapsed time in seconds. |

**Example**

```lua
do
    local rig = lurek.camera.newRig()
    rig:setPosition("a", 0, 0)
    rig:setTarget("a", 200, 200)
    rig:updateAll(0.016)
    print("all cameras updated")
    print("camera count = " .. tostring(#rig:names()))
end
```

---
