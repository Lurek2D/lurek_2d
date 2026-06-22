# Camera

## Purpose

Tracks targets smoothly via customizable presets, dead-zones, and bounds.

## When To Use

- Follow logic, dead zones, damping, bounds, zoom, rotation, path motion, and viewport policy all live here so projects can define how scene focus becomes visible framing.
- This matters because camera behavior shapes feel and readability just as much as raw world state does.
- Follow and constraint logic are central because a useful camera is rarely just a position; it must decide how tightly to track a target, how much to lag, and what world bounds or dead zones should still preserve readability.

## Minimal Example

From the `lurek.camera.new` example block:

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(320, 180)
    cam:setZoom(1.25)
    local x, y = cam:getPosition()
    lurek.log.info("arena camera created=" .. tostring(cam ~= nil))
    lurek.log.info("arena camera type=" .. cam:type() .. " pos=" .. x .. "," .. y .. " zoom=" .. cam:getZoom())
end
```

## Common Patterns

- Start with `lurek.camera.new` when exploring this module.
- Start with `lurek.camera.newCamera` when exploring this module.
- Start with `lurek.camera.newRig` when exploring this module.
- Start with `lurek.camera.newWalker` when exploring this module.

## API Reference

- This page is the generated API reference for this module.
- Runnable example owner: `content/examples/camera.lua`

## Summary

- The `camera` module is the engine's shared view-control surface for users who need world motion to become readable player-facing framing.
- Follow logic, dead zones, damping, bounds, zoom, rotation, path motion, and viewport policy all live here so projects can define how scene focus becomes visible framing.
- This matters because camera behavior shapes feel and readability just as much as raw world state does.
- Follow and constraint logic are central because a useful camera is rarely just a position; it must decide how tightly to track a target, how much to lag, and what world bounds or dead zones should still preserve readability.
- Screen shake, sway, breathing, zoom pulses, and scripted paths extend the module from neutral viewing into gameplay feedback and cinematic presentation.
- Screen-to-world and world-to-screen conversion are equally important because overlays, minimaps, targeting, and editor tools depend on the same view contract.
- Split views, subviews, and viewport-aware framing broaden the feature beyond one player camera into inspection tools and multi-panel presentation workflows.
- Scripted path motion also makes the feature useful for guided pans, flyovers, tutorials, and tool previews where the point is not only to follow a target, but to author how attention moves through space.
- That same contract helps previews and gameplay stay visually aligned.
- This shared framing policy is what keeps several view-dependent systems aligned instead of each inventing its own screen-space math.
- `render` shows the result and world systems choose what to focus, but `camera` owns how that focus is followed, constrained, and transformed into visible space.
- Read `camera` as the authority for framing policy and coordinate conversion between world and screen.

This module primarily collaborates with `math`, `render`, `tilemap`. Its responsibility should stay inside the Platform Services group rather than absorb behavior owned by those neighbors.

## Functions

### `lurek.camera.new`

Creates a 2D camera with optional virtual viewport size.

```lua
lurek.camera.new(vw, vh)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `vw?` | number | Virtual viewport width; defaults to 800. |
| `vh?` | number | Virtual viewport height; defaults to 600. |

**Returns**

| Type | Description |
|------|-------------|
| [LCamera](#lcamera) | New camera handle. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(320, 180)
    cam:setZoom(1.25)
    local x, y = cam:getPosition()
    lurek.log.info("arena camera created=" .. tostring(cam ~= nil))
    lurek.log.info("arena camera type=" .. cam:type() .. " pos=" .. x .. "," .. y .. " zoom=" .. cam:getZoom())
end
```

---

### `lurek.camera.newCamera`

Creates a 2D camera with optional virtual viewport size.

```lua
lurek.camera.newCamera(vw, vh)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `vw?` | number | Virtual viewport width; defaults to 800. |
| `vh?` | number | Virtual viewport height; defaults to 600. |

**Returns**

| Type | Description |
|------|-------------|
| [LCamera](#lcamera) | New camera handle. |

**Example**

```lua
do
    local cam = lurek.camera.newCamera(1280, 720)
    cam:setViewport(0, 0, 1280, 720)
    cam:setPosition(640, 360)
    local _, _, w, h = cam:getViewport()
    lurek.log.info("cutscene camera created=" .. tostring(cam ~= nil))
    lurek.log.info("cutscene viewport=" .. w .. "x" .. h .. " center=" .. table.concat({ cam:getPosition() }, ","))
end
```

---

### `lurek.camera.newRig`

Creates an empty named camera rig. This function is exposed to Lua scripts.

```lua
lurek.camera.newRig()
```

**Returns**

| Type | Description |
|------|-------------|
| [LCameraRig](#lcamerarig) | New camera rig handle. |

**Example**

```lua
do
    local rig = lurek.camera.newRig()
    rig:setPosition("main", 320, 180)
    rig:setZoom("main", 1.5)
    local names = rig:names()
    lurek.log.info("rig created=" .. tostring(rig ~= nil))
    lurek.log.info("rig type=" .. rig:type() .. " cameras=" .. tostring(#names))
end
```

---

### `lurek.camera.newWalker`

Creates a tile-grid walker with smooth camera following.

```lua
lurek.camera.newWalker(map, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `map` | [LTileMap](#ltilemap) | Tilemap for collision detection. |
| `opts?` | table | Options table with keys: layer (default 1), tile_w, tile_h, body_w, body_h, speed, x, y, camera (optional custom camera). |

**Returns**

| Type | Description |
|------|-------------|
| [LCameraWalker](#lcamerawalker) | New walker handle. |

**Example**

```lua
do
    local map = lurek.tilemap.newTileMap(16, 16)
    local walker = lurek.camera.newWalker(map, {
        layer = 1,
        tile_w = 32,
        tile_h = 32,
        body_w = 24,
        body_h = 24,
        speed = 100,
        x = 64,
        y = 64
    })
    example_print_log("walker created = " .. tostring(walker ~= nil))
    example_print_log("walker type = " .. walker:type())
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

- [LCamera](#lcamera)
- [LCameraRig](#lcamerarig)
- [LCameraWalker](#lcamerawalker)
- [LTileMap](#ltilemap)

## LCamera

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LCamera:apply`

Appends render commands that apply this camera transform.

```lua
LCamera:apply()
```

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(400, 300)
    cam:apply()
    local x, y = cam:getPosition()
    example_print_log("camera applied")
    example_print_log("position = " .. x .. ", " .. y)
end
```

---

#### `LCamera:attach`

Appends render commands that attach this camera transform.

```lua
LCamera:attach()
```

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(480, 270)
    cam:setZoom(1.5)
    cam:attach()
    lurek.log.info("attach camera pos=" .. table.concat({ cam:getPosition() }, ","))
    lurek.log.info("attach camera zoom=" .. cam:getZoom())
end
```

---

#### `LCamera:clearParallaxFactors`

Clears all layer parallax factor overrides.

```lua
LCamera:clearParallaxFactors()
```

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setParallaxFactor("fg", 1.2)
    cam:clearParallaxFactors()
    example_print_log("parallax cleared")
    example_print_log("fg parallax = " .. tostring(cam:getParallaxFactor("fg")))
end
```

---

#### `LCamera:clearTarget`

Clears the follow target. This method is available to Lua scripts.

```lua
LCamera:clearTarget()
```

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setTarget(100, 100)
    cam:clearTarget()
    local ok = cam:getTarget()
    example_print_log("target cleared")
    example_print_log("has target = " .. tostring(ok))
end
```

---

#### `LCamera:detach`

Appends a render command that detaches the active camera transform.

```lua
LCamera:detach()
```

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(480, 270)
    cam:attach()
    cam:detach()
    lurek.log.info("detach camera pos=" .. table.concat({ cam:getPosition() }, ","))
    lurek.log.info("detach issued")
end
```

---

#### `LCamera:followPath`

Starts camera movement along an array of waypoint tables.

```lua
LCamera:followPath(points, duration)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `points` | table | Array of point tables using numeric indices `1` and `2` for X and Y. |
| `duration` | number | Total path duration in seconds. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    local points = { { 0, 0 }, { 400, 200 }, { 800, 0 } }
    cam:followPath(points, 3.0)
    example_print_log("following path over 3s")
    example_print_log("path progress = " .. tostring(cam:pathProgress()))
end
```

---

#### `LCamera:getBounds`

Returns camera bounds with a leading availability flag.

```lua
LCamera:getBounds()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | Has-bounds flag followed by X; Y; width; and height. (value 1). |
| number | Has-bounds flag followed by X; Y; width; and height. (value 2). |
| number | Has-bounds flag followed by X; Y; width; and height. (value 3). |
| number | Has-bounds flag followed by X; Y; width; and height. (value 4). |
| number | Has-bounds flag followed by X; Y; width; and height. (value 5). |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setBounds(0, 0, 2000, 1500)
    local ok, bx, by, bw, bh = cam:getBounds()
    cam:setPosition(1900, 1400)
    lurek.log.info("world bounds active=" .. tostring(ok))
    lurek.log.info("world bounds rect=" .. tostring(bx) .. "," .. tostring(by) .. "," .. tostring(bw) .. "," .. tostring(bh))
    lurek.log.info("world cam pos=" .. table.concat({ cam:getPosition() }, ","))
end
```

---

#### `LCamera:getDeadZone`

Returns follow dead-zone dimensions with a leading availability flag.

```lua
LCamera:getDeadZone()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | Has-dead-zone flag followed by width and height. (value 1). |
| number | Has-dead-zone flag followed by width and height. (value 2). |
| number | Has-dead-zone flag followed by width and height. (value 3). |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setDeadZone(40, 20)
    local ok, w, h = cam:getDeadZone()
    cam:setTarget(500, 300)
    cam:update(0.016)
    lurek.log.info("runner dead zone=" .. tostring(ok) .. "," .. tostring(w) .. "x" .. tostring(h))
    lurek.log.info("runner cam pos=" .. table.concat({ cam:getPosition() }, ","))
end
```

---

#### `LCamera:getEffectOffset`

Returns combined camera effect offset.

```lua
LCamera:getEffectOffset()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Effect X and Y offset. (value 1). |
| number | Effect X and Y offset. (value 2). |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    local ox, oy = cam:getEffectOffset()
    cam:startSway(1.0, 0.5, 1.0, 0.5)
    cam:update(0.1)
    local swayX, swayY = cam:getEffectOffset()
    lurek.log.info("effect offset base=" .. ox .. "," .. oy)
    lurek.log.info("effect offset sway=" .. swayX .. "," .. swayY)
end
```

---

#### `LCamera:getEffectiveZoom`

Returns zoom after camera effects are applied.

```lua
LCamera:getEffectiveZoom()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Effective zoom factor. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setZoom(2.0)
    local ez = cam:getEffectiveZoom()
    example_print_log("effective zoom = " .. ez)
    example_print_log("base zoom = " .. tostring(cam:getZoom()))
end
```

---

#### `LCamera:getFollowEasing`

Returns target follow easing mode.

```lua
LCamera:getFollowEasing()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Easing name `linear`, `smoothstep`, or `easeout`. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setFollowEasing("linear")
    local e = cam:getFollowEasing()
    cam:setTarget(300, 200)
    cam:update(0.05)
    lurek.log.info("platform easing=" .. e)
    lurek.log.info("platform pos=" .. table.concat({ cam:getPosition() }, ","))
end
```

---

#### `LCamera:getFollowSmooth`

Returns follow smoothing speed. This method is available to Lua scripts.

```lua
LCamera:getFollowSmooth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current follow smoothing speed. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setFollowSmooth(3.0)
    local s = cam:getFollowSmooth()
    cam:setTarget(128, 96)
    cam:update(0.05)
    lurek.log.info("dialog follow smooth=" .. s)
    lurek.log.info("dialog follow pos=" .. table.concat({ cam:getPosition() }, ","))
end
```

---

#### `LCamera:getLookAhead`

Returns follow look-ahead multiplier.

```lua
LCamera:getLookAhead()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current look-ahead multiplier. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setLookAhead(2.0)
    local la = cam:getLookAhead()
    cam:setTarget(520, 260)
    cam:update(0.016)
    lurek.log.info("scout look ahead=" .. la)
    lurek.log.info("scout cam=" .. table.concat({ cam:getPosition() }, ","))
end
```

---

#### `LCamera:getParallaxFactor`

Returns a parallax factor for a named layer.

```lua
LCamera:getParallaxFactor(layer)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | string | Layer name. |

**Returns**

| Type | Description |
|------|-------------|
| number | Stored parallax factor, or 1.0 when the layer has no override. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setParallaxFactor("clouds", 0.3)
    local f = cam:getParallaxFactor("clouds")
    cam:setParallaxFactor("mountains", 0.6)
    lurek.log.info("clouds parallax=" .. f)
    lurek.log.info("mountains parallax=" .. cam:getParallaxFactor("mountains"))
end
```

---

#### `LCamera:getPosition`

Returns the camera world position.

```lua
LCamera:getPosition()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Camera X and Y position in world units. (value 1). |
| number | Camera X and Y position in world units. (value 2). |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(100, 50)
    cam:move(24, -8)
    local x, y = cam:getPosition()
    cam:setZoom(1.1)
    lurek.log.info("spectator cam x=" .. x .. " y=" .. y)
    lurek.log.info("spectator zoom=" .. cam:getZoom())
end
```

---

#### `LCamera:getRenderOffset`

Returns current render offset after camera effects.

```lua
LCamera:getRenderOffset()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Render X and Y offset. (value 1). |
| number | Render X and Y offset. (value 2). |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    local rx, ry = cam:getRenderOffset()
    cam:shake(3.0, 0.2)
    cam:update(0.05)
    local shakeRx, shakeRy = cam:getRenderOffset()
    lurek.log.info("render offset base=" .. rx .. "," .. ry)
    lurek.log.info("render offset shaken=" .. shakeRx .. "," .. shakeRy)
end
```

---

#### `LCamera:getRotation`

Returns the camera rotation. This method is available to Lua scripts.

```lua
LCamera:getRotation()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current rotation in radians. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setRotation(1.5)
    local r = cam:getRotation()
    cam:setZoom(1.2)
    lurek.log.info("boss intro rotation=" .. r)
    lurek.log.info("boss intro zoom=" .. cam:getZoom())
end
```

---

#### `LCamera:getRotationConstraints`

Returns rotation constraints with availability flags.

```lua
LCamera:getRotationConstraints()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | Has-min flag and value followed by has-max flag and value. (value 1). |
| number | Has-min flag and value followed by has-max flag and value. (value 2). |
| boolean | Has-min flag and value followed by has-max flag and value. (value 3). |
| number | Has-min flag and value followed by has-max flag and value. (value 4). |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setRotationConstraints(-1.0, 1.0)
    local has_min, mn, has_max, mx = cam:getRotationConstraints()
    example_print_log("rotation min enabled = " .. tostring(has_min) .. " value = " .. mn)
    example_print_log("rotation max enabled = " .. tostring(has_max) .. " value = " .. mx)
end
```

---

#### `LCamera:getRotationDamping`

Returns rotation damping. This method is available to Lua scripts.

```lua
LCamera:getRotationDamping()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current rotation damping value. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setRotationDamping(0.7)
    local d = cam:getRotationDamping()
    cam:setRotation(-math.pi / 8)
    cam:update(0.1)
    lurek.log.info("aim cam damping=" .. d)
    lurek.log.info("aim cam rotation=" .. cam:getRotation())
end
```

---

#### `LCamera:getShakeOffset`

Returns current camera shake offset.

```lua
LCamera:getShakeOffset()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Shake X and Y offset. (value 1). |
| number | Shake X and Y offset. (value 2). |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:shake(5.0, 0.5)
    cam:update(0.01)
    local sx, sy = cam:getShakeOffset()
    example_print_log("shake = " .. sx .. ", " .. sy)
end
```

---

#### `LCamera:getTarget`

Returns the follow target with a leading availability flag.

```lua
LCamera:getTarget()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | Has-target flag followed by target X and Y. (value 1). |
| number | Has-target flag followed by target X and Y. (value 2). |
| number | Has-target flag followed by target X and Y. (value 3). |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setTarget(250, 125)
    local ok, tx, ty = cam:getTarget()
    cam:setLookAhead(1.5)
    cam:update(0.016)
    lurek.log.info("escort target=" .. tostring(ok) .. "," .. tostring(tx) .. "," .. tostring(ty))
    lurek.log.info("escort lookahead=" .. cam:getLookAhead())
end
```

---

#### `LCamera:getViewport`

Returns the camera viewport rectangle.

```lua
LCamera:getViewport()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Viewport X; Y; width; and height. (value 1). |
| number | Viewport X; Y; width; and height. (value 2). |
| number | Viewport X; Y; width; and height. (value 3). |
| number | Viewport X; Y; width; and height. (value 4). |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setViewport(10, 10, 780, 580)
    local x, y, w, h = cam:getViewport()
    cam:setPosition(390, 290)
    lurek.log.info("hud-safe viewport=" .. x .. "," .. y .. "," .. w .. "," .. h)
    lurek.log.info("hud-safe center=" .. table.concat({ cam:getPosition() }, ","))
end
```

---

#### `LCamera:getVisibleArea`

Returns the world-space area visible through this camera.

```lua
LCamera:getVisibleArea()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Visible X; Y; width; and height. (value 1). |
| number | Visible X; Y; width; and height. (value 2). |
| number | Visible X; Y; width; and height. (value 3). |
| number | Visible X; Y; width; and height. (value 4). |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(400, 300)
    local x, y, w, h = cam:getVisibleArea()
    cam:setZoom(1.25)
    local zx, zy, zw, zh = cam:getVisibleArea()
    lurek.log.info("visible area base=" .. x .. "," .. y .. " " .. w .. "x" .. h)
    lurek.log.info("visible area zoomed=" .. zx .. "," .. zy .. " " .. zw .. "x" .. zh)
end
```

---

#### `LCamera:getZoom`

Returns the camera zoom factor. This method is available to Lua scripts.

```lua
LCamera:getZoom()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current zoom factor. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setZoom(0.5)
    local z = cam:getZoom()
    cam:setViewport(0, 0, 400, 300)
    local _, _, w, h = cam:getViewport()
    lurek.log.info("minimap zoom=" .. z)
    lurek.log.info("minimap viewport=" .. w .. "x" .. h)
end
```

---

#### `LCamera:getZoomConstraints`

Returns zoom constraints with availability flags.

```lua
LCamera:getZoomConstraints()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | Has-min flag and value followed by has-max flag and value. (value 1). |
| number | Has-min flag and value followed by has-max flag and value. (value 2). |
| boolean | Has-min flag and value followed by has-max flag and value. (value 3). |
| number | Has-min flag and value followed by has-max flag and value. (value 4). |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setZoomConstraints(0.25, 3.0)
    local _, mn, _, mx = cam:getZoomConstraints()
    cam:setZoom(5.0)
    lurek.log.info("zoom range=" .. mn .. " to " .. mx)
    lurek.log.info("zoom after clamp request=" .. cam:getZoom())
end
```

---

#### `LCamera:getZoomDamping`

Returns zoom damping. This method is available to Lua scripts.

```lua
LCamera:getZoomDamping()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current zoom damping value. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setZoomDamping(0.8)
    local d = cam:getZoomDamping()
    cam:zoomTo(1.5, 0.5, "linear")
    cam:updateZoom(0.25)
    lurek.log.info("photo mode damping=" .. d)
    lurek.log.info("photo mode zoom=" .. cam:getZoom())
end
```

---

#### `LCamera:hasBounds`

Returns whether camera bounds are active.

```lua
LCamera:hasBounds()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when bounds are active. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setBounds(0, 0, 1000, 1000)
    cam:setPosition(900, 900)
    local x, y = cam:getPosition()
    lurek.log.info("arena bounds=" .. tostring(cam:hasBounds()))
    lurek.log.info("arena pos=" .. x .. "," .. y)
end
```

---

#### `LCamera:isBreathing`

Returns whether breathing zoom animation is active.

```lua
LCamera:isBreathing()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when breathing is active. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:startBreathing(0.02, 0.5)
    cam:update(0.1)
    lurek.log.info("breathing active=" .. tostring(cam:isBreathing()))
    lurek.log.info("breathing zoom=" .. cam:getEffectiveZoom())
end
```

---

#### `LCamera:isSway`

Returns whether camera sway is active.

```lua
LCamera:isSway()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when sway is active. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:startSway(1.0, 1.0, 1.0, 0.5)
    cam:update(0.1)
    local ox, oy = cam:getEffectOffset()
    lurek.log.info("torch sway=" .. tostring(cam:isSway()))
    lurek.log.info("torch offset=" .. ox .. "," .. oy)
end
```

---

#### `LCamera:lookAt`

Centers the camera on a world position.

```lua
LCamera:lookAt(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | World X position. |
| `y` | number | World Y position. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:lookAt(500, 250)
    local x, y = cam:getPosition()
    cam:setZoom(1.4)
    local areaX, areaY, areaW, areaH = cam:getVisibleArea()
    lurek.log.info("lookAt center=" .. x .. "," .. y)
    lurek.log.info("lookAt visible=" .. areaX .. "," .. areaY .. " " .. areaW .. "x" .. areaH)
end
```

---

#### `LCamera:move`

Moves the camera by a delta. This method is available to Lua scripts.

```lua
LCamera:move(dx, dy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dx` | number | X delta in world units. |
| `dy` | number | Y delta in world units. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(100, 100)
    cam:move(50, -25)
    local x, y = cam:getPosition()
    example_print_log("moved to " .. x .. ", " .. y)
end
```

---

#### `LCamera:onWindowResize`

Updates camera viewport state after a window resize.

```lua
LCamera:onWindowResize(window_w, window_h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `window_w` | number | New window width in pixels. |
| `window_h` | number | New window height in pixels. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:onWindowResize(1920, 1080)
    local _, _, w, h = cam:getViewport()
    example_print_log("resized to 1920x1080")
    example_print_log("viewport size = " .. w .. "x" .. h)
end
```

---

#### `LCamera:onWindowResizeScaled`

Updates camera viewport state using a virtual game size and scale mode.

```lua
LCamera:onWindowResizeScaled(game_w, game_h, window_w, window_h, mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `game_w` | number | Virtual game width in pixels. |
| `game_h` | number | Virtual game height in pixels. |
| `window_w` | number | New window width in pixels. |
| `window_h` | number | New window height in pixels. |
| `mode` | string | Scale mode `letterbox`, `stretch`, or `pixelperfect`. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:onWindowResizeScaled(800, 600, 1920, 1080, "letterbox")
    local x, y, w, h = cam:getViewport()
    example_print_log("scaled resize applied")
    example_print_log("viewport = " .. x .. "," .. y .. "," .. w .. "," .. h)
end
```

---

#### `LCamera:pathProgress`

Returns active path progress. This method is available to Lua scripts.

```lua
LCamera:pathProgress()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Normalized path progress from 0 to 1, or 1 when no path is active. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    local points = { { 0, 0 }, { 100, 100 } }
    cam:followPath(points, 1.0)
    cam:updatePath(0.5)
    local p = cam:pathProgress()
    example_print_log("progress = " .. p)
    example_print_log("progress halfway = " .. tostring(p > 0 and p < 1))
end
```

---

#### `LCamera:presetAggressiveFollow`

Applies the aggressive follow camera preset.

```lua
LCamera:presetAggressiveFollow()
```

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:presetAggressiveFollow()
    cam:setTarget(720, 260)
    cam:update(0.016)
    lurek.log.info("aggressive preset smooth=" .. cam:getFollowSmooth())
    lurek.log.info("aggressive preset lookahead=" .. cam:getLookAhead())
end
```

---

#### `LCamera:presetBalancedFollow`

Applies the balanced follow camera preset.

```lua
LCamera:presetBalancedFollow()
```

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:presetBalancedFollow()
    cam:setTarget(420, 220)
    cam:update(0.016)
    lurek.log.info("balanced preset smooth=" .. cam:getFollowSmooth())
    lurek.log.info("balanced preset lookahead=" .. cam:getLookAhead())
end
```

---

#### `LCamera:presetCinematicFollow`

Applies the cinematic follow camera preset.

```lua
LCamera:presetCinematicFollow()
```

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:presetCinematicFollow()
    cam:setTarget(640, 240)
    cam:update(0.016)
    lurek.log.info("cinematic preset smooth=" .. cam:getFollowSmooth())
    lurek.log.info("cinematic preset lookahead=" .. cam:getLookAhead())
end
```

---

#### `LCamera:presetTightFollow`

Applies the tight follow camera preset.

```lua
LCamera:presetTightFollow()
```

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:presetTightFollow()
    cam:setTarget(180, 120)
    cam:update(0.016)
    lurek.log.info("tight preset smooth=" .. cam:getFollowSmooth())
    lurek.log.info("tight preset pos=" .. table.concat({ cam:getPosition() }, ","))
end
```

---

#### `LCamera:removeBounds`

Removes active camera bounds. This method is available to Lua scripts.

```lua
LCamera:removeBounds()
```

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setBounds(0, 0, 1000, 1000)
    lurek.log.info("bounds before remove=" .. tostring(cam:hasBounds()))
    cam:removeBounds()
    cam:setPosition(1400, 1400)
    local x, y = cam:getPosition()
    lurek.log.info("bounds removed=" .. tostring(not cam:hasBounds()))
    lurek.log.info("free cam pos=" .. x .. "," .. y)
end
```

---

#### `LCamera:reset`

Appends a render command that removes the active camera transform.

```lua
LCamera:reset()
```

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(500, 500)
    cam:setZoom(3.0)
    cam:reset()
    example_print_log("camera reset command queued")
    example_print_log("zoom still readable = " .. tostring(cam:getZoom()))
end
```

---

#### `LCamera:setBounds`

Sets camera world bounds. This method is available to Lua scripts.

```lua
LCamera:setBounds(x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Bounds X coordinate. |
| `y` | number | Bounds Y coordinate. |
| `w` | number | Bounds width. |
| `h` | number | Bounds height. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setBounds(0, 0, 3200, 2400)
    cam:setPosition(3100, 2300)
    local ok, bx, by, bw, bh = cam:getBounds()
    lurek.log.info("overworld bounds=" .. tostring(cam:hasBounds()))
    lurek.log.info("overworld rect=" .. tostring(ok) .. "," .. tostring(bx) .. "," .. tostring(by) .. "," .. tostring(bw) .. "," .. tostring(bh))
end
```

---

#### `LCamera:setDeadZone`

Sets follow dead-zone dimensions.

```lua
LCamera:setDeadZone(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | number | Dead-zone width in world units. |
| `h` | number | Dead-zone height in world units. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setDeadZone(50, 30)
    local ok, w, h = cam:getDeadZone()
    example_print_log("dead zone active = " .. tostring(ok))
    example_print_log("dead zone = " .. tostring(w) .. "x" .. tostring(h))
end
```

---

#### `LCamera:setFollowEasing`

Sets target follow easing mode. This method is available to Lua scripts.

```lua
LCamera:setFollowEasing(easing)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `easing` | string | Easing name such as `linear`, `smoothstep`, or `easeout`. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setFollowEasing("quadOut")
    cam:setTarget(220, 140)
    cam:update(0.05)
    lurek.log.info("follow easing=" .. cam:getFollowEasing())
    lurek.log.info("follow pos=" .. table.concat({ cam:getPosition() }, ","))
end
```

---

#### `LCamera:setFollowSmooth`

Sets follow smoothing speed. This method is available to Lua scripts.

```lua
LCamera:setFollowSmooth(speed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `speed` | number | Follow smoothing speed. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setFollowSmooth(5.0)
    cam:setTarget(600, 300)
    cam:update(0.033)
    lurek.log.info("follow smooth=" .. cam:getFollowSmooth())
    lurek.log.info("follow pos=" .. table.concat({ cam:getPosition() }, ","))
end
```

---

#### `LCamera:setLookAhead`

Sets follow look-ahead multiplier.

```lua
LCamera:setLookAhead(mul)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mul` | number | Look-ahead multiplier applied to target motion. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setLookAhead(1.5)
    cam:setTarget(420, 240)
    cam:update(0.016)
    lurek.log.info("look ahead=" .. cam:getLookAhead())
    lurek.log.info("look ahead cam=" .. table.concat({ cam:getPosition() }, ","))
end
```

---

#### `LCamera:setParallaxFactor`

Sets a parallax factor for a named layer.

```lua
LCamera:setParallaxFactor(layer, factor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | string | Layer name. |
| `factor` | number | Parallax factor, where 1.0 follows the camera fully. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setParallaxFactor("background", 0.5)
    cam:setParallaxFactor("foreground", 1.2)
    local bg = cam:getParallaxFactor("background")
    local fg = cam:getParallaxFactor("foreground")
    lurek.log.info("parallax bg=" .. bg)
    lurek.log.info("parallax fg=" .. fg)
end
```

---

#### `LCamera:setPosition`

Sets the camera world position. This method is available to Lua scripts.

```lua
LCamera:setPosition(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Camera X position in world units. |
| `y` | number | Camera Y position in world units. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(200, 150)
    cam:setTarget(260, 180)
    local x, y = cam:getPosition()
    local hasTarget, tx, ty = cam:getTarget()
    lurek.log.info("player spawn camera pos=" .. x .. "," .. y)
    lurek.log.info("follow target=" .. tostring(hasTarget) .. " " .. tostring(tx) .. "," .. tostring(ty))
end
```

---

#### `LCamera:setRotation`

Sets the camera rotation. This method is available to Lua scripts.

```lua
LCamera:setRotation(r)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | number | Rotation in radians. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setRotation(math.pi / 4)
    cam:setPosition(600, 240)
    local x, y = cam:getPosition()
    lurek.log.info("falling bridge rotation=" .. cam:getRotation())
    lurek.log.info("falling bridge focus=" .. x .. "," .. y)
end
```

---

#### `LCamera:setRotationConstraints`

Sets optional minimum and maximum rotation constraints.

```lua
LCamera:setRotationConstraints(min_rot, max_rot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min_rot?` | number | Optional minimum rotation in radians. |
| `max_rot?` | number | Optional maximum rotation in radians. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setRotationConstraints(-0.5, 0.5)
    local has_min, min_r, has_max, max_r = cam:getRotationConstraints()
    example_print_log("has min/max = " .. tostring(has_min) .. "/" .. tostring(has_max))
    example_print_log("rotation constrained to [" .. min_r .. ", " .. max_r .. "]")
end
```

---

#### `LCamera:setRotationDamping`

Sets rotation damping. This method is available to Lua scripts.

```lua
LCamera:setRotationDamping(damping)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `damping` | number | Rotation damping value. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setRotationDamping(0.85)
    cam:setRotation(math.pi / 6)
    cam:update(0.1)
    lurek.log.info("rotation damping=" .. cam:getRotationDamping())
    lurek.log.info("rotation state=" .. cam:getRotation())
end
```

---

#### `LCamera:setTarget`

Sets a world-space follow target. This method is available to Lua scripts.

```lua
LCamera:setTarget(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Target X position. |
| `y` | number | Target Y position. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setTarget(500, 300)
    cam:setFollowSmooth(6.0)
    local ok, tx, ty = cam:getTarget()
    cam:update(0.016)
    lurek.log.info("chase target=" .. tostring(ok) .. "," .. tostring(tx) .. "," .. tostring(ty))
    lurek.log.info("chase camera pos=" .. table.concat({ cam:getPosition() }, ","))
end
```

---

#### `LCamera:setViewport`

Sets the camera viewport rectangle.

```lua
LCamera:setViewport(x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Viewport X coordinate in screen pixels. |
| `y` | number | Viewport Y coordinate in screen pixels. |
| `w` | number | Viewport width in screen pixels. |
| `h` | number | Viewport height in screen pixels. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setViewport(0, 0, 400, 300)
    local x, y, w, h = cam:getViewport()
    example_print_log("viewport x,y = " .. x .. ", " .. y)
    example_print_log("viewport size = " .. w .. "x" .. h)
end
```

---

#### `LCamera:setZoom`

Sets the camera zoom factor. This method is available to Lua scripts.

```lua
LCamera:setZoom(zoom)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `zoom` | number | Zoom factor applied to world rendering. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setZoom(2.0)
    cam:setPosition(480, 320)
    local x, y = cam:getPosition()
    local zoom = cam:getZoom()
    lurek.log.info("sniper zoom=" .. zoom)
    lurek.log.info("sniper anchor=" .. x .. "," .. y)
end
```

---

#### `LCamera:setZoomConstraints`

Sets optional minimum and maximum zoom constraints.

```lua
LCamera:setZoomConstraints(min_zoom, max_zoom)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min_zoom?` | number | Optional minimum zoom. |
| `max_zoom?` | number | Optional maximum zoom. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setZoomConstraints(0.5, 4.0)
    local has_min, min_z, has_max, max_z = cam:getZoomConstraints()
    example_print_log("has min/max = " .. tostring(has_min) .. "/" .. tostring(has_max))
    example_print_log("zoom constrained to [" .. min_z .. ", " .. max_z .. "]")
end
```

---

#### `LCamera:setZoomDamping`

Sets zoom damping. This method is available to Lua scripts.

```lua
LCamera:setZoomDamping(damping)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `damping` | number | Zoom damping value. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setZoomDamping(0.9)
    cam:zoomTo(2.0, 0.5, "linear")
    cam:updateZoom(0.25)
    lurek.log.info("zoom damping=" .. cam:getZoomDamping())
    lurek.log.info("zoom in progress=" .. cam:getZoom())
end
```

---

#### `LCamera:shake`

Starts a camera shake effect. This method is available to Lua scripts.

```lua
LCamera:shake(intensity, duration)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `intensity` | number | Shake intensity in world units. |
| `duration` | number | Shake duration in seconds. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:shake(10.0, 0.5)
    cam:update(0.1)
    local sx, sy = cam:getShakeOffset()
    lurek.log.info("impact shake active")
    lurek.log.info("impact offset=" .. sx .. "," .. sy)
    lurek.log.info("impact render offset=" .. table.concat({ cam:getRenderOffset() }, ","))
end
```

---

#### `LCamera:startBreathing`

Starts subtle breathing zoom animation.

```lua
LCamera:startBreathing(amplitude, rate)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `amplitude?` | number | Breathing zoom amplitude; defaults to 0.005. |
| `rate?` | number | Breathing rate; defaults to 0.2. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:startBreathing(0.02, 0.5)
    cam:update(0.1)
    local ez = cam:getEffectiveZoom()
    lurek.log.info("breathing started=" .. tostring(cam:isBreathing()))
    lurek.log.info("breathing effective zoom=" .. ez)
end
```

---

#### `LCamera:startSway`

Starts camera sway offset animation.

```lua
LCamera:startSway(amplitude_x, amplitude_y, frequency, decay)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `amplitude_x` | number | Horizontal sway amplitude. |
| `amplitude_y` | number | Vertical sway amplitude. |
| `frequency` | number | Sway frequency. |
| `decay?` | number | Sway decay value; defaults to 1.0. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:startSway(3.0, 2.0, 1.5, 0.5)
    cam:update(0.1)
    local ox, oy = cam:getEffectOffset()
    lurek.log.info("boat sway active=" .. tostring(cam:isSway()))
    lurek.log.info("boat sway offset=" .. ox .. "," .. oy)
end
```

---

#### `LCamera:stopBreathing`

Stops breathing zoom animation. This method is available to Lua scripts.

```lua
LCamera:stopBreathing()
```

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:startBreathing(0.01, 0.3)
    cam:update(0.1)
    cam:stopBreathing()
    local ez = cam:getEffectiveZoom()
    lurek.log.info("breathing stopped=" .. tostring(not cam:isBreathing()))
    lurek.log.info("breathing effective zoom=" .. ez)
end
```

---

#### `LCamera:stopPath`

Stops the active camera path. This method is available to Lua scripts.

```lua
LCamera:stopPath()
```

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    local points = { { 0, 0 }, { 100, 100 } }
    cam:followPath(points, 2.0)
    cam:stopPath()
    example_print_log("path stopped")
    example_print_log("path progress = " .. tostring(cam:pathProgress()))
end
```

---

#### `LCamera:stopSway`

Stops camera sway offset animation.

```lua
LCamera:stopSway()
```

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:startSway(2.0, 1.0, 1.0, 0.3)
    cam:update(0.1)
    cam:stopSway()
    local ox, oy = cam:getEffectOffset()
    lurek.log.info("sway stopped=" .. tostring(not cam:isSway()))
    lurek.log.info("post-sway offset=" .. ox .. "," .. oy)
end
```

---

#### `LCamera:stopZoom`

Stops the active zoom tween. This method is available to Lua scripts.

```lua
LCamera:stopZoom()
```

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:zoomTo(3.0, 2.0, "linear")
    cam:updateZoom(0.5)
    cam:stopZoom()
    local zoom = cam:getZoom()
    local continued = cam:updateZoom(0.5)
    lurek.log.info("zoom stopped at=" .. zoom)
    lurek.log.info("zoom tween continued=" .. tostring(continued))
end
```

---

#### `LCamera:toScreen`

Converts world coordinates to screen coordinates.

```lua
LCamera:toScreen(wx, wy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `wx` | number | World X coordinate. |
| `wy` | number | World Y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| number | Screen X and Y coordinates. (value 1). |
| number | Screen X and Y coordinates. (value 2). |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(100, 100)
    local sx, sy = cam:toScreen(500, 400)
    local wx, wy = cam:toWorld(sx, sy)
    lurek.log.info("marker screen=" .. sx .. "," .. sy)
    lurek.log.info("marker roundtrip world=" .. wx .. "," .. wy)
end
```

---

#### `LCamera:toWorld`

Converts screen coordinates to world coordinates.

```lua
LCamera:toWorld(sx, sy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sx` | number | Screen X coordinate. |
| `sy` | number | Screen Y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| number | World X and Y coordinates. (value 1). |
| number | World X and Y coordinates. (value 2). |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(100, 100)
    local wx, wy = cam:toWorld(400, 300)
    local sx, sy = cam:toScreen(wx, wy)
    lurek.log.info("cursor world=" .. wx .. "," .. wy)
    lurek.log.info("cursor roundtrip screen=" .. sx .. "," .. sy)
end
```

---

#### `LCamera:type`

Returns the Lua-visible type name for this camera handle.

```lua
LCamera:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LCamera](#lcamera)`. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(200, 120)
    cam:setZoom(1.1)
    lurek.log.info("camera type=" .. cam:type())
    lurek.log.info("camera pos=" .. table.concat({ cam:getPosition() }, ",") .. " zoom=" .. cam:getZoom())
end
```

---

#### `LCamera:typeOf`

Returns whether this camera handle matches a supported type name.

```lua
LCamera:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LCamera](#lcamera)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setPosition(200, 120)
    cam:setZoom(1.1)
    lurek.log.info("is LCamera=" .. tostring(cam:typeOf("LCamera")))
    lurek.log.info("is Object=" .. tostring(cam:typeOf("Object")))
end
```

---

#### `LCamera:update`

Advances camera follow, shake, and effect state.

```lua
LCamera:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Elapsed time in seconds. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:setTarget(200, 100)
    cam:setFollowSmooth(4.0)
    cam:update(0.016)
    local x, y = cam:getPosition()
    example_print_log("camera updated")
    example_print_log("position = " .. x .. ", " .. y)
end
```

---

#### `LCamera:updatePath`

Advances the active camera path and applies its position.

```lua
LCamera:updatePath(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Elapsed time in seconds. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a path position was applied. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    local points = { { 0, 0 }, { 200, 200 } }
    cam:followPath(points, 2.0)
    cam:updatePath(0.5)
    local x, y = cam:getPosition()
    example_print_log("path progress = " .. cam:pathProgress())
    example_print_log("position = " .. x .. ", " .. y)
end
```

---

#### `LCamera:updateZoom`

Advances the active zoom tween and applies its zoom value.

```lua
LCamera:updateZoom(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Elapsed time in seconds. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a zoom value was applied. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:zoomTo(2.0, 1.0, "linear")
    local runningMid = cam:updateZoom(0.5)
    local midZoom = cam:getZoom()
    local runningEnd = cam:updateZoom(0.5)
    lurek.log.info("mid zoom=" .. midZoom .. " running=" .. tostring(runningMid))
    lurek.log.info("end zoom=" .. cam:getZoom() .. " running=" .. tostring(runningEnd))
end
```

---

#### `LCamera:zoomPulse`

Triggers a temporary zoom pulse effect.

```lua
LCamera:zoomPulse(amplitude, duration)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `amplitude` | number | Zoom pulse amplitude. |
| `duration` | number | Pulse duration in seconds. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:zoomPulse(0.2, 0.3)
    local before = cam:getEffectiveZoom()
    cam:update(0.1)
    local during = cam:getEffectiveZoom()
    cam:update(0.3)
    lurek.log.info("pulse zoom before=" .. tostring(before) .. " during=" .. tostring(during))
    lurek.log.info("pulse zoom after=" .. tostring(cam:getEffectiveZoom()))
end
```

---

#### `LCamera:zoomTo`

Starts a zoom tween toward a target zoom factor.

```lua
LCamera:zoomTo(target_zoom, duration, easing)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target_zoom` | number | Destination zoom factor. |
| `duration` | number | Tween duration in seconds. |
| `easing?` | string | Easing name such as `linear`, `smoothstep`, or `easeout`. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    cam:zoomTo(2.0, 1.0, "quadOut")
    cam:updateZoom(0.5)
    lurek.log.info("boss reveal zoom=" .. cam:getZoom())
    cam:updateZoom(0.5)
    lurek.log.info("boss reveal final zoom=" .. cam:getZoom())
end
```

---

## LCameraRig

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LCameraRig:apply`

Appends render commands for a named camera in this rig.

```lua
LCameraRig:apply(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Camera name to apply. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the named camera exists. |

**Example**

```lua
do
    local rig = lurek.camera.newRig()
    rig:setPosition("main", 400, 300)
    local ok = rig:apply("main")
    local has, x, y, w, h = rig:getViewport("main")
    lurek.log.info("applied main=" .. tostring(ok))
    lurek.log.info("main viewport present=" .. tostring(has) .. " " .. tostring(x) .. "," .. tostring(y) .. "," .. tostring(w) .. "," .. tostring(h))
end
```

---

#### `LCameraRig:getViewport`

Returns a named rig camera viewport with a leading availability flag.

```lua
LCameraRig:getViewport(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Camera name to query. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | Has-camera flag followed by viewport X; Y; width; and height. (value 1). |
| number | Has-camera flag followed by viewport X; Y; width; and height. (value 2). |
| number | Has-camera flag followed by viewport X; Y; width; and height. (value 3). |
| number | Has-camera flag followed by viewport X; Y; width; and height. (value 4). |
| number | Has-camera flag followed by viewport X; Y; width; and height. (value 5). |

**Example**

```lua
do
    local rig = lurek.camera.newRig()
    rig:setPosition("left", 0, 0)
    rig:splitScreen(800, 600)
    local has, x, y, w, h = rig:getViewport("left")
    example_print_log("has=" .. tostring(has) .. " vp=" .. x .. "," .. y .. "," .. w .. "," .. h)
end
```

---

#### `LCameraRig:has`

Returns whether this rig contains a named camera.

```lua
LCameraRig:has(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Camera name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the camera exists. |

**Example**

```lua
do
    local rig = lurek.camera.newRig()
    rig:setPosition("x", 0, 0)
    rig:setPosition("y", 64, 64)
    lurek.log.info("has x=" .. tostring(rig:has("x")))
    lurek.log.info("has boss cam=" .. tostring(rig:has("boss")))
end
```

---

#### `LCameraRig:minimap`

Applies a minimap layout using the current window size and optional ratio.

```lua
LCameraRig:minimap(window_w, window_h, ratio)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `window_w` | number | Window width in pixels. |
| `window_h` | number | Window height in pixels. |
| `ratio?` | number | Minimap size ratio; defaults to 0.25. |

**Example**

```lua
do
    local rig = lurek.camera.newRig()
    rig:setPosition("main", 400, 300)
    rig:minimap(1280, 720, 0.25)
    local has, x, y, w, h = rig:getViewport("minimap")
    lurek.log.info("minimap layout applied=" .. tostring(has))
    lurek.log.info("minimap viewport=" .. x .. "," .. y .. "," .. w .. "," .. h)
end
```

---

#### `LCameraRig:names`

Returns all camera names in this rig.

```lua
LCameraRig:names()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Camera names. |

**Example**

```lua
do
    local rig = lurek.camera.newRig()
    rig:setPosition("p1", 0, 0)
    local list = rig:names()
    example_print_log("cameras = " .. #list)
    example_print_log("first name = " .. tostring(list[1]))
end
```

---

#### `LCameraRig:pictureInPicture`

Applies a picture-in-picture layout using optional inset size.

```lua
LCameraRig:pictureInPicture(window_w, window_h, pip_w, pip_h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `window_w` | number | Window width in pixels. |
| `window_h` | number | Window height in pixels. |
| `pip_w?` | number | Picture-in-picture width; defaults to 320. |
| `pip_h?` | number | Picture-in-picture height; defaults to 180. |

**Example**

```lua
do
    local rig = lurek.camera.newRig()
    rig:setPosition("main", 200, 200)
    rig:pictureInPicture(1280, 720, 320, 180)
    local has, x, y, w, h = rig:getViewport("pip")
    lurek.log.info("pip layout applied=" .. tostring(has))
    lurek.log.info("pip viewport=" .. x .. "," .. y .. "," .. w .. "," .. h)
end
```

---

#### `LCameraRig:remove`

Removes a named camera from this rig.

```lua
LCameraRig:remove(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Camera name to remove. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the camera existed and was removed. |

**Example**

```lua
do
    local rig = lurek.camera.newRig()
    rig:setPosition("temp", 0, 0)
    local ok = rig:remove("temp")
    local names = rig:names()
    lurek.log.info("removed temp=" .. tostring(ok))
    lurek.log.info("remaining rig cameras=" .. tostring(#names))
end
```

---

#### `LCameraRig:setPosition`

Sets the position of a named rig camera, creating it if needed.

```lua
LCameraRig:setPosition(name, x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Camera name. |
| `x` | number | Camera X position. |
| `y` | number | Camera Y position. |

**Example**

```lua
do
    local rig = lurek.camera.newRig()
    rig:setPosition("left", 100, 200)
    rig:setZoom("left", 1.2)
    local names = rig:names()
    lurek.log.info("camera positioned left=" .. tostring(rig:has("left")))
    lurek.log.info("rig names=" .. table.concat(names, ","))
end
```

---

#### `LCameraRig:setTarget`

Sets the follow target of a named rig camera, creating it if needed.

```lua
LCameraRig:setTarget(name, x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Camera name. |
| `x` | number | Target X position. |
| `y` | number | Target Y position. |

**Example**

```lua
do
    local rig = lurek.camera.newRig()
    rig:setPosition("cam1", 0, 0)
    rig:setTarget("cam1", 400, 300)
    example_print_log("target set on cam1")
    example_print_log("rig has cam1 = " .. tostring(rig:has("cam1")))
end
```

---

#### `LCameraRig:setZoom`

Sets the zoom of a named rig camera, creating it if needed.

```lua
LCameraRig:setZoom(name, zoom)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Camera name. |
| `zoom` | number | Camera zoom factor. |

**Example**

```lua
do
    local rig = lurek.camera.newRig()
    rig:setPosition("a", 0, 0)
    rig:setZoom("a", 1.5)
    local list = rig:names()
    example_print_log("zoom set on camera a")
    example_print_log("camera count = " .. tostring(#list))
end
```

---

#### `LCameraRig:splitScreen`

Applies a split-screen layout using the current window size.

```lua
LCameraRig:splitScreen(window_w, window_h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `window_w` | number | Window width in pixels. |
| `window_h` | number | Window height in pixels. |

**Example**

```lua
do
    local rig = lurek.camera.newRig()
    rig:setPosition("player1", 100, 100)
    rig:setPosition("player2", 500, 300)
    rig:splitScreen(1280, 720)
    example_print_log("split screen layout applied")
end
```

---

#### `LCameraRig:type`

Returns the Lua-visible type name for this camera rig handle.

```lua
LCameraRig:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LCameraRig](#lcamerarig)`. |

**Example**

```lua
do
    local rig = lurek.camera.newRig()
    rig:setPosition("debug", 0, 0)
    rig:setZoom("debug", 1.25)
    lurek.log.info("rig type=" .. rig:type())
    lurek.log.info("rig names=" .. table.concat(rig:names(), ","))
    lurek.log.info("rig has debug=" .. tostring(rig:has("debug")))
end
```

---

#### `LCameraRig:typeOf`

Returns whether this camera rig handle matches a supported type name.

```lua
LCameraRig:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LCameraRig](#lcamerarig)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local rig = lurek.camera.newRig()
    rig:setPosition("debug", 0, 0)
    rig:setTarget("debug", 64, 96)
    lurek.log.info("is LCameraRig=" .. tostring(rig:typeOf("LCameraRig")))
    lurek.log.info("is Object=" .. tostring(rig:typeOf("Object")))
    lurek.log.info("rig has debug=" .. tostring(rig:has("debug")))
end
```

---

#### `LCameraRig:updateAll`

Advances every camera in this rig. This method is available to Lua scripts.

```lua
LCameraRig:updateAll(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Elapsed time in seconds. |

**Example**

```lua
do
    local rig = lurek.camera.newRig()
    rig:setPosition("a", 0, 0)
    rig:setTarget("a", 200, 200)
    rig:updateAll(0.016)
    example_print_log("all cameras updated")
    example_print_log("camera count = " .. tostring(#rig:names()))
end
```

---

## LCameraWalker

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LCameraWalker:getCamera`

Returns the camera associated with this walker.

```lua
LCameraWalker:getCamera()
```

**Returns**

| Type | Description |
|------|-------------|
| [LCamera](#lcamera) | Camera that follows the walker. |

**Example**

```lua
do
    local map = lurek.tilemap.newTileMap(16, 16)
    local walker = lurek.camera.newWalker(map)
    local cam = walker:getCamera()
    walker:setPosition(64, 96)
    local x, y = walker:getPosition()
    lurek.log.info("walker camera type=" .. cam:type())
    lurek.log.info("walker pos=" .. x .. "," .. y)
end
```

---

#### `LCameraWalker:getPosition`

Returns the walker world-space center position.

```lua
LCameraWalker:getPosition()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Walker X and Y position in world units. (value 1). |
| number | Walker X and Y position in world units. (value 2). |

**Example**

```lua
do
    local map = lurek.tilemap.newTileMap(16, 16)
    local walker = lurek.camera.newWalker(map)
    walker:setPosition(96, 128)
    local x, y = walker:getPosition()
    example_print_log("walker pos = " .. x .. ", " .. y)
end
```

---

#### `LCameraWalker:getTilePosition`

Returns current walker tile coordinates (1-based).

```lua
LCameraWalker:getTilePosition()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Tile column and row (1-based). (value 1). |
| number | Tile column and row (1-based). (value 2). |

**Example**

```lua
do
    local map = lurek.tilemap.newTileMap(16, 16)
    local walker = lurek.camera.newWalker(map, { tile_w = 32, tile_h = 32 })
    walker:setTilePosition(3, 2)
    local tx, ty = walker:getTilePosition()
    example_print_log("walker tile = " .. tx .. ", " .. ty)
end
```

---

#### `LCameraWalker:moveDown`

Moves the walker down (positive Y) with collision checking.

```lua
LCameraWalker:moveDown(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt?` | number | Time delta in seconds (defaults to 1/60). |

**Example**

```lua
do
    local map = lurek.tilemap.newTileMap(16, 16)
    local walker = lurek.camera.newWalker(map, { speed = 50, x = 100, y = 100 })
    walker:moveDown(1.0)
    local _, y = walker:getPosition()
    example_print_log("moved down, new y = " .. y)
end
```

---

#### `LCameraWalker:moveLeft`

Moves the walker left (negative X) with collision checking.

```lua
LCameraWalker:moveLeft(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt?` | number | Time delta in seconds (defaults to 1/60). |

**Example**

```lua
do
    local map = lurek.tilemap.newTileMap(16, 16)
    local walker = lurek.camera.newWalker(map, { speed = 50, x = 100, y = 100 })
    walker:moveLeft(1.0)
    local x, _ = walker:getPosition()
    example_print_log("moved left, new x = " .. x)
end
```

---

#### `LCameraWalker:moveRight`

Moves the walker right (positive X) with collision checking.

```lua
LCameraWalker:moveRight(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt?` | number | Time delta in seconds (defaults to 1/60). |

**Example**

```lua
do
    local map = lurek.tilemap.newTileMap(16, 16)
    local walker = lurek.camera.newWalker(map, { speed = 50, x = 100, y = 100 })
    walker:moveRight(1.0)
    local x, _ = walker:getPosition()
    example_print_log("moved right, new x = " .. x)
end
```

---

#### `LCameraWalker:moveUp`

Moves the walker up (negative Y) with collision checking.

```lua
LCameraWalker:moveUp(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt?` | number | Time delta in seconds (defaults to 1/60). |

**Example**

```lua
do
    local map = lurek.tilemap.newTileMap(16, 16)
    local walker = lurek.camera.newWalker(map, { speed = 50, x = 100, y = 100 })
    walker:moveUp(1.0)
    local _, y = walker:getPosition()
    example_print_log("moved up, new y = " .. y)
end
```

---

#### `LCameraWalker:setPosition`

Sets the walker world-space center position.

```lua
LCameraWalker:setPosition(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Walker X position in world units. |
| `y` | number | Walker Y position in world units. |

**Example**

```lua
do
    local map = lurek.tilemap.newTileMap(16, 16)
    local walker = lurek.camera.newWalker(map)
    walker:setPosition(128, 96)
    local x, y = walker:getPosition()
    example_print_log("walker pos = " .. x .. ", " .. y)
end
```

---

#### `LCameraWalker:setTilePosition`

Places walker using 1-based tile coordinates.

```lua
LCameraWalker:setTilePosition(tx, ty)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tx` | number | Tile column (1-based). |
| `ty` | number | Tile row (1-based). |

**Example**

```lua
do
    local map = lurek.tilemap.newTileMap(16, 16)
    local walker = lurek.camera.newWalker(map, { tile_w = 32, tile_h = 32 })
    walker:setTilePosition(5, 4)
    local tx, ty = walker:getTilePosition()
    example_print_log("walker tile = " .. tx .. ", " .. ty)
end
```

---

#### `LCameraWalker:type`

Returns the type name of this userdata.

```lua
LCameraWalker:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always `"[LCameraWalker](#lcamerawalker)"`. |

**Example**

```lua
do
    local map = lurek.tilemap.newTileMap(16, 16)
    local walker = lurek.camera.newWalker(map)
    walker:setPosition(32, 48)
    local tx, ty = walker:getTilePosition()
    lurek.log.info("walker type=" .. walker:type())
    lurek.log.info("walker tile=" .. tx .. "," .. ty)
end
```

---

#### `LCameraWalker:typeOf`

Checks whether this object matches the given type name.

```lua
LCameraWalker:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check against. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if `name` is `"[LCameraWalker](#lcamerawalker)"` or `"Object"`. |

**Example**

```lua
do
    local map = lurek.tilemap.newTileMap(16, 16)
    local walker = lurek.camera.newWalker(map)
    walker:setPosition(32, 48)
    lurek.log.info("is walker type=" .. tostring(walker:typeOf("LCameraWalker")))
    lurek.log.info("is object type=" .. tostring(walker:typeOf("Object")))
end
```

---

#### `LCameraWalker:update`

Updates camera state and advances smooth interpolation.

```lua
LCameraWalker:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt?` | number | Time delta in seconds (defaults to 1/60). |

**Example**

```lua
do
    local map = lurek.tilemap.newTileMap(16, 16)
    local walker = lurek.camera.newWalker(map)
    walker:setPosition(50, 50)
    walker:update(0.016)  -- Update at ~60 FPS
    local x, y = walker:getPosition()
    example_print_log("walker updated, pos = " .. x .. ", " .. y)
end
```

---

## LTileMap

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LTileMap:addLayer`

Creates a new tile layer with the given name and dimensions.

```lua
LTileMap:addLayer(name, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Layer name. |
| `w` | number | Width in tiles. |
| `h` | number | Height in tiles. |

**Returns**

| Type | Description |
|------|-------------|
| number | Index of the new layer (1-based). |

---

#### `LTileMap:addTileSet`

Attaches a tileset to this map for tile rendering.

```lua
LTileMap:addTileSet(tileSet)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tileSet` | [LTileSet](tilemap.md#ltileset) | Tileset to add. |

---

#### `LTileMap:applyAutoTile`

Runs 4-bit auto-tiling on an entire layer, replacing tiles according to registered rules.

```lua
LTileMap:applyAutoTile(layer, typeName)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `typeName` | string | Tile type name whose rules to apply. |

---

#### `LTileMap:applyAutoTile8`

Runs 8-bit auto-tiling on an entire layer, considering diagonal neighbors.

```lua
LTileMap:applyAutoTile8(layer, typeName)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `typeName` | string | Tile type name whose rules to apply. |

---

#### `LTileMap:applyAutoTile8At`

Runs 8-bit auto-tiling at a single tile position and updates it and its neighbors.

```lua
LTileMap:applyAutoTile8At(layer, x, y, typeName)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `x` | number | Column (1-based). |
| `y` | number | Row (1-based). |
| `typeName` | string | Tile type name whose rules to apply. |

---

#### `LTileMap:applyAutoTileAt`

Runs 4-bit auto-tiling at a single tile position and updates it and its neighbors.

```lua
LTileMap:applyAutoTileAt(layer, x, y, typeName)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `x` | number | Column (1-based). |
| `y` | number | Row (1-based). |
| `typeName` | string | Tile type name whose rules to apply. |

---

#### `LTileMap:applyAutoTileMode`

Runs auto-tiling on an entire layer using the mode configured on the matching tileset.

```lua
LTileMap:applyAutoTileMode(layer, typeName)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `typeName` | string | Tile type name whose configured mode and rules to apply. |

---

#### `LTileMap:applyAutoTileModeAt`

Runs configured-mode auto-tiling at a single tile position and updates it and its neighbors.

```lua
LTileMap:applyAutoTileModeAt(layer, x, y, typeName)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `x` | number | Column (1-based). |
| `y` | number | Row (1-based). |
| `typeName` | string | Tile type name whose configured mode and rules to apply. |

---

#### `LTileMap:checkEntities`

Checks a list of entities against registered tile-enter callbacks on a layer.

```lua
LTileMap:checkEntities(layer, entities)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `entities` | table | Array of entity tables, each with `x`/`y` or `[1]`/`[2]` fields. |

---

#### `LTileMap:clearTile`

Removes the tile at a specific grid position, setting it to empty (GID 0).

```lua
LTileMap:clearTile(layer, x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `x` | number | Column (1-based). |
| `y` | number | Row (1-based). |

---

#### `LTileMap:drawToImage`

Rasterizes the map into an image using the given tile size, returning an image handle.

```lua
LTileMap:drawToImage(tileSize)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tileSize` | number | Pixel size of each tile in the output image. |

**Returns**

| Type | Description |
|------|-------------|
| [LImage](render.md#limage) | Rasterized image of the map. |

---

#### `LTileMap:fill`

Fills every cell of a layer with the given GID.

```lua
LTileMap:fill(layer, gid)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `gid` | number | Global tile ID to fill with. |

---

#### `LTileMap:findTilesByGid`

Returns all positions on a layer that contain a specific GID.

```lua
LTileMap:findTilesByGid(layer, gid)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `gid` | number | Global tile ID to search for. |

**Returns**

| Type | Description |
|------|-------------|
| LTileMapFindTilesByGidResult | Array of `{x=number, y=number}` positions. |

---

#### `LTileMap:fireTileExit`

Manually fires the tile-exit callback for a specific GID and entity at a tile position.

```lua
LTileMap:fireTileExit(gid, entity, tx, ty)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `gid` | number | Global tile ID. |
| `entity` | table | Entity table to pass to the callback. |
| `tx` | number | Tile column. |
| `ty` | number | Tile row. |

---

#### `LTileMap:fireTileStep`

Manually fires the tile-step callback for a specific GID and entity at a tile position.

```lua
LTileMap:fireTileStep(gid, entity, tx, ty)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `gid` | number | Global tile ID. |
| `entity` | table | Entity table to pass to the callback. |
| `tx` | number | Tile column. |
| `ty` | number | Tile row. |

---

#### `LTileMap:getChunkSize`

Returns the chunk size used for internal tile storage.

```lua
LTileMap:getChunkSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Chunk size in tiles per side. |

---

#### `LTileMap:getDiagnostics`

Returns tilemap diagnostics counters for invalid calls, unknown gids, and lazy index rebuilds.

```lua
LTileMap:getDiagnostics()
```

---

#### `LTileMap:getLayerColor`

Returns the tint color of a layer as four RGBA components.

```lua
LTileMap:getLayerColor(idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Layer index (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| number | Red (0..1). |
| number | Green (0..1). |
| number | Blue (0..1). |
| number | Alpha (0..1). |

---

#### `LTileMap:getLayerCount`

Returns the total number of layers in this map.

```lua
LTileMap:getLayerCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Layer count. |

---

#### `LTileMap:getLayerName`

Returns the name of a layer by index.

```lua
LTileMap:getLayerName(idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Layer index (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| string | Layer name, or nil if index is out of range. |

---

#### `LTileMap:getLayerOffset`

Returns the pixel offset of a layer.

```lua
LTileMap:getLayerOffset(idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Layer index (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| number | Horizontal offset. |
| number | Vertical offset. |

---

#### `LTileMap:getLayerParallax`

Returns the parallax scroll factor of a layer.

```lua
LTileMap:getLayerParallax(idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Layer index (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| number | Horizontal parallax factor. |
| number | Vertical parallax factor. |

---

#### `LTileMap:getLayerVisible`

Returns whether a layer is currently visible.

```lua
LTileMap:getLayerVisible(idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Layer index (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the layer is visible. |

---

#### `LTileMap:getOrientation`

Returns the current map orientation as a string.

```lua
LTileMap:getOrientation()
```

**Returns**

| Type | Description |
|------|-------------|
| string | One of `"topdown"`, `"sideview"`, `"isometric"`, `"hexagonal"`. |

---

#### `LTileMap:getTile`

Returns the tile GID at a specific grid position on a layer.

```lua
LTileMap:getTile(layer, x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `x` | number | Column (1-based). |
| `y` | number | Row (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| number | Global tile ID at that position. |

---

#### `LTileMap:getTileDimensions`

Returns both tile width and height in pixels.

```lua
LTileMap:getTileDimensions()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Tile width. |
| number | Tile height. |

---

#### `LTileMap:getTileHeight`

Returns the height of a single tile in pixels for this map.

```lua
LTileMap:getTileHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Tile height in pixels. |

---

#### `LTileMap:getTileSet`

Returns the tileset at the given index.

```lua
LTileMap:getTileSet(idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Tileset index (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| [LTileSet](tilemap.md#ltileset) | The tileset, or nil if index is out of range. |

---

#### `LTileMap:getTileSetCount`

Returns how many tilesets are attached to this map.

```lua
LTileMap:getTileSetCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Tileset count. |

---

#### `LTileMap:getTileWidth`

Returns the width of a single tile in pixels for this map.

```lua
LTileMap:getTileWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Tile width in pixels. |

---

#### `LTileMap:getViewport`

Returns the current viewport rectangle, or nils if none is set.

```lua
LTileMap:getViewport()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Left edge. |
| number | Top edge. |
| number | Width. |
| number | Height. |

---

#### `LTileMap:isSolid`

Checks whether the tile at a given position on a layer is solid.

```lua
LTileMap:isSolid(layer, x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `x` | number | Column (1-based). |
| `y` | number | Row (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the tile at that position is marked solid. |

---

#### `LTileMap:onTileEnter`

Registers a callback invoked when an entity enters a tile with the given GID.

```lua
LTileMap:onTileEnter(gid, func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `gid` | number | Global tile ID to watch for. |
| `func` | function | Callback receiving `(wx, wy, tx, ty)`. |

---

#### `LTileMap:onTileExit`

Registers a callback invoked when an entity leaves a tile with the given GID.

```lua
LTileMap:onTileExit(gid, func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `gid` | number | Global tile ID to watch for. |
| `func` | function | Callback receiving `(entity, tx, ty)`. |

---

#### `LTileMap:onTileStep`

Registers a callback invoked each frame an entity remains on a tile with the given GID.

```lua
LTileMap:onTileStep(gid, func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `gid` | number | Global tile ID to watch for. |
| `func` | function | Callback receiving `(entity, tx, ty)`. |

---

#### `LTileMap:rectOverlapsSolid`

Tests whether a world-space rectangle overlaps any solid tile on a layer.

```lua
LTileMap:rectOverlapsSolid(layer, x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `x` | number | Rectangle left edge in world pixels. |
| `y` | number | Rectangle top edge in world pixels. |
| `w` | number | Rectangle width in pixels. |
| `h` | number | Rectangle height in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if any solid tile is overlapped. |

---

#### `LTileMap:render`

Submits render commands for all visible tiles, optionally offset by a scroll position.

```lua
LTileMap:render(ox, oy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ox?` | number | Horizontal scroll offset (default 0). |
| `oy?` | number | Vertical scroll offset (default 0). |

---

#### `LTileMap:setLayerColor`

Sets the tint color for an entire layer.

```lua
LTileMap:setLayerColor(idx, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Layer index (1-based). |
| `r` | number | Red channel (0..1). |
| `g` | number | Green channel (0..1). |
| `b` | number | Blue channel (0..1). |
| `a` | number | Alpha channel (0..1). |

---

#### `LTileMap:setLayerOffset`

Sets the pixel offset for a layer, shifting all tiles during rendering.

```lua
LTileMap:setLayerOffset(idx, ox, oy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Layer index (1-based). |
| `ox` | number | Horizontal offset in pixels. |
| `oy` | number | Vertical offset in pixels. |

---

#### `LTileMap:setLayerParallax`

Sets the parallax scroll factor for a layer. Values less than 1 scroll slower than the camera.

```lua
LTileMap:setLayerParallax(idx, px, py)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Layer index (1-based). |
| `px` | number | Horizontal parallax factor. |
| `py` | number | Vertical parallax factor. |

---

#### `LTileMap:setLayerVisible`

Sets whether a layer is drawn during rendering.

```lua
LTileMap:setLayerVisible(idx, visible)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Layer index (1-based). |
| `visible` | boolean | True to show, false to hide. |

---

#### `LTileMap:setOrientation`

Sets the map orientation, affecting coordinate transforms and rendering.

```lua
LTileMap:setOrientation(orientation)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `orientation` | string | One of `"topdown"`, `"sideview"`, `"isometric"`, `"hexagonal"`. |

---

#### `LTileMap:setTile`

Sets the tile GID at a specific grid position on a layer.

```lua
LTileMap:setTile(layer, x, y, gid)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `x` | number | Column (1-based). |
| `y` | number | Row (1-based). |
| `gid` | number | Global tile ID to place. |

---

#### `LTileMap:setTileTint`

Overrides the color tint for a single tile at a given position.

```lua
LTileMap:setTileTint(layer, x, y, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `x` | number | Column (1-based). |
| `y` | number | Row (1-based). |
| `r` | number | Red channel (0..1). |
| `g` | number | Green channel (0..1). |
| `b` | number | Blue channel (0..1). |
| `a` | number | Alpha channel (0..1). |

---

#### `LTileMap:setViewport`

Sets the visible area of the map for culling during rendering.

```lua
LTileMap:setViewport(x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Left edge in world pixels. |
| `y` | number | Top edge in world pixels. |
| `w` | number | Viewport width in pixels. |
| `h` | number | Viewport height in pixels. |

---

#### `LTileMap:sweepRect`

Performs a swept AABB collision test against solid tiles on a layer, returning the contact point and normal.

```lua
LTileMap:sweepRect(layer, x, y, w, h, dx, dy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `x` | number | Rectangle left edge in world pixels. |
| `y` | number | Rectangle top edge in world pixels. |
| `w` | number | Rectangle width in pixels. |
| `h` | number | Rectangle height in pixels. |
| `dx` | number | Horizontal movement delta. |
| `dy` | number | Vertical movement delta. |

**Returns**

| Type | Description |
|------|-------------|
| number | Contact X position. |
| number | Contact Y position. |
| number | Normal X component. |
| number | Normal Y component. |
| number | Tile column hit (1-based; or 0 if no hit). |
| number | Tile row hit (1-based; or 0 if no hit). |

---

#### `LTileMap:tileToWorld`

Converts tile-grid coordinates to world-space pixel coordinates (top-left corner of the tile).

```lua
LTileMap:tileToWorld(tx, ty)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tx` | number | Tile column (1-based). |
| `ty` | number | Tile row (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| number | World X position in pixels. |
| number | World Y position in pixels. |

---

#### `LTileMap:tileTypeIndex`

Builds an index mapping each GID present on a layer to an array of `{x, y}` positions.

```lua
LTileMap:tileTypeIndex(layer)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| LTileMapTileTypeIndexResult | Table keyed by GID, each value an array of `{x=number, y=number}`. |

---

#### `LTileMap:toNavGrid`

Converts a layer into a 2D boolean grid for pathfinding. Tiles with GIDs in the given list are marked walkable.

```lua
LTileMap:toNavGrid(layer, gids)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `gids` | table | Array of walkable GIDs. |

**Returns**

| Type | Description |
|------|-------------|
| boolean[] | Flat walkable grid (true = walkable), row-major order. |

---

#### `LTileMap:tryAddLayer`

Creates a new tile layer and returns `nil, error` instead of throwing on invalid dimensions or layer limits.

```lua
LTileMap:tryAddLayer(name, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Layer name. |
| `w` | number | Width in tiles. |
| `h` | number | Height in tiles. |

**Returns**

| Type | Description |
|------|-------------|
| number | Index of the new layer (1-based). |
| string | Error message when validation fails. |

---

#### `LTileMap:tryGetTile`

Returns the tile GID at a specific grid position, or `nil, error` when the layer or coord is invalid.

```lua
LTileMap:tryGetTile(layer, x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `x` | number | Column (1-based). |
| `y` | number | Row (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| number | Global tile ID at that position. |
| string | Error message on failure. |

---

#### `LTileMap:trySetTile`

Sets a tile and returns `false, error` instead of throwing on invalid layer or coordinate input.

```lua
LTileMap:trySetTile(layer, x, y, gid)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `x` | number | Column (1-based). |
| `y` | number | Row (1-based). |
| `gid` | number | Global tile ID to place. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True on success. |
| string | Error message on failure. |

---

#### `LTileMap:trySetTileTint`

Sets a per-cell tint override and returns `false, error` instead of throwing on invalid input.

```lua
LTileMap:trySetTileTint(layer, x, y, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `x` | number | Column (1-based). |
| `y` | number | Row (1-based). |
| `r` | number | Red tint channel. |
| `g` | number | Green tint channel. |
| `b` | number | Blue tint channel. |
| `a` | number | Alpha tint channel. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True on success. |
| string | Error message on failure. |

---

#### `LTileMap:tryWorldToTile`

Converts world-space pixel coordinates to tile-grid coordinates, returning nils for negative or non-finite input.

```lua
LTileMap:tryWorldToTile(wx, wy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `wx` | number | World X position in pixels. |
| `wy` | number | World Y position in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| number | Tile column (1-based). |
| number | Tile row (1-based). |

---

#### `LTileMap:type`

Returns the type name of this userdata.

```lua
LTileMap:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always `"[LTileMap](#ltilemap)"`. |

---

#### `LTileMap:typeOf`

Checks whether this object matches the given type name.

```lua
LTileMap:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check against. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if `name` is `"[LTileMap](#ltilemap)"` or `"Object"`. |

---

#### `LTileMap:update`

Advances tile animations by the given delta time.

```lua
LTileMap:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Time elapsed in seconds since last update. |

---

#### `LTileMap:worldToTile`

Converts world-space pixel coordinates to tile-grid coordinates.

```lua
LTileMap:worldToTile(wx, wy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `wx` | number | World X position in pixels. |
| `wy` | number | World Y position in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| number | Tile column (1-based). |
| number | Tile row (1-based). |

---
