# Camera

## Summary

The `camera` module is the runtime camera stack for 2D view transforms, camera behavior, and viewport mapping. It is organized as cooperating submodules rather than one heavy type: core camera state (`types`), viewport scaling (`viewport` and `viewport_scale`), path/tween motion (`path`), effect primitives (`effects`), multi-camera coordination (`multi`), and render-command adapters (`render`).

This module's role is transform policy, not scene ownership. It computes where and how to view the world, then exposes that state to render paths and scripts. Features like follow behavior, easing, path interpolation, and rig composition are kept in camera space so gameplay systems can consume them without duplicating math.

The separation between viewport and camera behavior is deliberate. Viewport code governs screen/game scaling strategy and coordinate conversion, while camera code governs position/zoom/rotation behavior. This avoids accidental coupling between display resolution concerns and gameplay camera logic.

In practice, camera changes should preserve stable transform semantics across single-camera and multi-camera flows. Render integration should remain adapter-style: camera produces view data, renderer consumes commands.

Implementation detail and boundary guarantees for camera: this module keeps responsibilities explicit across source files so behavior remains inspectable during refactors. The current source map is: effects.rs: Camera effect primitives for transient motion overlays on top of base camera state.; mod.rs: Camera subsystem module root: effects, multi-view, path, render, types, and viewport.; multi.rs: Multi-camera rig that stores and manages named Camera2D instances.; path.rs: Waypoint-based camera path interpolation for scripted camera movement.; render.rs: Render command generation from camera transform state.; types.rs: Core camera state containers: Camera (minimal) and Camera2D (full runtime).; viewport.rs: Viewport scaling strategies for mapping a fixed game surface into variable window sizes.; viewport_scale.rs: Viewport scale state object used by the engine resize flow.. This split is part of the contract: orchestration stays in composition points, data models stay in type-centric files, and adapters stay in bridge files. That separation reduces hidden coupling, improves testability, and keeps Lua API surfaces aligned with Rust runtime semantics. For maintainers, the key guarantee is that high-level APIs should keep delegating into scoped internals instead of collapsing into a single large entry point. Future extensions should preserve explicit dependency direction and documented invariants near owning types and functions.

## Spec File Descriptions

_Poniższe opisy plików pochodzą bezpośrednio ze specyfikacji modułu (`docs/specs/<module>.md`)._

### effects.rs

- Implements transient camera-motion effects layered on top of the base follow transform state.
- Provides pulse-based zoom bursts for impact moments and short-lived cinematic emphasis.
- Adds oscillatory sway offsets with tunable frequency and damping for dynamic camera motion feel.
- Supplies breathing-style zoom modulation for subtle ambient life during low-action periods.
- Keeps each effect independently updateable so compositions remain modular and controllable.
- Serves as the reusable effect toolkit consumed by camera runtime state integration.

### mod.rs

- Defines the camera module boundary that groups transform state, effects, viewport, and rendering helpers.
- Exposes a coherent camera surface while keeping pathing, rigs, and scaling concerns modularized.
- Serves as the high-level composition root for runtime camera behavior across engine systems.

### multi.rs

- Implements multi-camera rig management over named camera instances for concurrent view setups.
- Provides preset layout helpers for split-screen, minimap, and picture-in-picture arrangements.
- Supports deterministic iteration and bulk mutation flows for multi-pass rendering integration.
- Serves as the orchestration layer for scenarios requiring more than one active camera view.

### path.rs

- Implements waypoint-driven camera path interpolation for scripted movement and guided shots.
- Provides zoom tweening with easing control for smooth focal transitions over fixed durations.
- Tracks segment progress across multi-point paths to produce continuous positional interpolation.
- Supports reusable easing selection so authored camera motion keeps consistent temporal character.
- Serves as the timeline-friendly movement layer above direct camera transform manipulation.

### render.rs

- Converts camera transform state into renderer command sequences for scene-space projection.
- Emits ordered push, translate, rotate, scale, and pop operations for deterministic visual mapping.
- Splits begin and end phases so callers can bracket arbitrary scene draw commands safely.
- Serves as the render-bridge layer between camera math state and command-stream execution.

### types.rs

- Defines core camera state models that represent both minimal and fully featured 2D camera behavior.
- Implements follow logic with dead-zone handling, smoothing response, and look-ahead displacement control.
- Integrates transient effects such as shake, pulse, sway, and breathing into effective camera transforms.
- Maintains zoom and rotation state with damping and bounded constraint ranges for runtime stability.
- Provides viewport-aware world-to-screen and screen-to-world mapping through explicit conversion utilities.
- Builds view matrices by composing position, rotation, zoom, and active effect contributions coherently.
- Exposes easing-driven interpolation options for authored motion character and follow response tuning.
- Supports target-follow presets that package common control profiles for gameplay camera styles.
- Keeps transform ownership centralized so dependent render and logic systems read consistent state.
- Serves as the primary camera runtime contract consumed across movement, rendering, and tooling layers.

### viewport.rs

- Implements viewport scaling policies that map fixed game space into dynamic window dimensions.
- Defines scale modes for aspect-preserving letterbox, free stretch, and pixel-perfect presentation.
- Stores computed scale and offset transforms recalculated on resize without recreating viewport state.
- Provides bidirectional coordinate conversion between screen pixels and logical game coordinates.
- Serves as the canonical scaling contract consumed by camera and render integration paths.

### viewport_scale.rs

- Implements runtime viewport-scale state used by resize and projection update workflows.
- Stores computed scale factors, offsets, and scaled dimensions after each window-size change.
- Provides bidirectional conversion helpers between logical game space and screen pixel coordinates.
- Serves as a compact scaling container for systems that need fast coordinate remapping.

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
| [LCamera](#lcamera-handle) | New camera handle. |

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
| [LCamera](#lcamera-handle) | New camera handle. |

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
lurek.camera.newRig()
```

**Returns**

| Type | Description |
|------|-------------|
| [LCameraRig](#lcamerarig-handle) | New camera rig handle. |

**Example**

```lua
do
    local rig = lurek.camera.newRig()
    print("rig created = " .. tostring(rig ~= nil))
    print("rig type = " .. rig:type())
end
```

---

## Module Fields

*No module-level fields documented.*

## Types

- [LCamera Handle](#lcamera-handle)
- [LCameraRig Handle](#lcamerarig-handle)

## Callbacks

*No callback parameters documented in this module.*

## Enums

*No module-specific enums documented.*

## LCamera Handle

### Fields

*No documented fields for this handle.*

### Methods

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
    print("camera applied")
    print("position = " .. x .. ", " .. y)
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
    cam:attach()
    print("camera attached")
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
    print("parallax cleared")
    print("fg parallax = " .. tostring(cam:getParallaxFactor("fg")))
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
    print("target cleared")
    print("has target = " .. tostring(ok))
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
    cam:attach()
    cam:detach()
    print("camera detached")
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
    print("following path over 3s")
    print("path progress = " .. tostring(cam:pathProgress()))
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
    print("bounds = " .. tostring(ok) .. "," .. tostring(bx) .. "," .. tostring(by) .. "," .. tostring(bw) .. "," .. tostring(bh))
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
    print("dead zone = " .. tostring(ok) .. "," .. tostring(w) .. "x" .. tostring(h))
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
    print("effect offset = " .. ox .. ", " .. oy)
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
    print("effective zoom = " .. ez)
    print("base zoom = " .. tostring(cam:getZoom()))
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
    print("easing = " .. e)
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
    print("follow smooth = " .. s)
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
    print("look ahead = " .. la)
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
    print("clouds parallax = " .. f)
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
    local x, y = cam:getPosition()
    print("x=" .. x .. " y=" .. y)
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
    print("render offset = " .. rx .. ", " .. ry)
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
    print("rotation = " .. r)
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
    local mn, mx = cam:getRotationConstraints()
    print("rotation range = " .. mn .. " to " .. mx)
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
    print("rot damping = " .. d)
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
    print("shake = " .. sx .. ", " .. sy)
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
    print("target = " .. tostring(ok) .. ", " .. tostring(tx) .. ", " .. tostring(ty))
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
    print("viewport = " .. x .. "," .. y .. "," .. w .. "," .. h)
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
    print("visible = " .. x .. "," .. y .. " " .. w .. "x" .. h)
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
    print("zoom = " .. z)
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
    print("zoom range = " .. mn .. " to " .. mx)
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
    print("damping = " .. d)
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
    print("has bounds = " .. tostring(cam:hasBounds()))
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
    print("breathing = " .. tostring(cam:isBreathing()))
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
    print("is sway = " .. tostring(cam:isSway()))
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
    print("looking at " .. x .. ", " .. y)
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
    print("moved to " .. x .. ", " .. y)
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
    print("resized to 1920x1080")
    print("viewport size = " .. w .. "x" .. h)
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
    print("scaled resize applied")
    print("viewport = " .. x .. "," .. y .. "," .. w .. "," .. h)
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
    print("progress = " .. p)
    print("progress halfway = " .. tostring(p > 0 and p < 1))
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
    print("aggressive follow preset applied")
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
    print("balanced follow preset applied")
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
    print("cinematic follow preset applied")
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
    print("tight follow preset applied")
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
    cam:removeBounds()
    print("bounds removed = " .. tostring(not cam:hasBounds()))
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
    print("camera reset command queued")
    print("zoom still readable = " .. tostring(cam:getZoom()))
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
    print("has bounds = " .. tostring(cam:hasBounds()))
    print("bounds set to 3200x2400")
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
    print("dead zone active = " .. tostring(ok))
    print("dead zone = " .. tostring(w) .. "x" .. tostring(h))
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
    print("easing = " .. cam:getFollowEasing())
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
    print("smooth = " .. cam:getFollowSmooth())
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
    print("look ahead = " .. cam:getLookAhead())
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
    print("parallax bg = " .. cam:getParallaxFactor("background"))
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
    local x, y = cam:getPosition()
    print("pos = " .. x .. ", " .. y)
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
    print("rotation = " .. cam:getRotation())
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
    print("has min/max = " .. tostring(has_min) .. "/" .. tostring(has_max))
    print("rotation constrained to [" .. min_r .. ", " .. max_r .. "]")
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
    print("rotation damping = " .. cam:getRotationDamping())
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
    local ok, tx, ty = cam:getTarget()
    print("target = " .. tostring(ok) .. ", " .. tostring(tx) .. ", " .. tostring(ty))
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
    print("viewport x,y = " .. x .. ", " .. y)
    print("viewport size = " .. w .. "x" .. h)
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
    print("zoom = " .. cam:getZoom())
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
    print("has min/max = " .. tostring(has_min) .. "/" .. tostring(has_max))
    print("zoom constrained to [" .. min_z .. ", " .. max_z .. "]")
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
    print("zoom damping = " .. cam:getZoomDamping())
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
    print("shaking for 0.5s at intensity 10")
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
    print("breathing started")
    print("is breathing = " .. tostring(cam:isBreathing()))
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
    print("sway started")
    print("is sway = " .. tostring(cam:isSway()))
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
    cam:stopBreathing()
    print("breathing stopped")
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
    print("path stopped")
    print("path progress = " .. tostring(cam:pathProgress()))
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
    cam:stopSway()
    print("sway stopped")
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
    cam:stopZoom()
    print("zoom stopped")
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
    print("screen = " .. sx .. ", " .. sy)
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
    print("world = " .. wx .. ", " .. wy)
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
| string | The string `[LCamera](#lcamera-handle)`. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    print("type = " .. cam:type())
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
| `name` | string | Type name to compare against `[LCamera](#lcamera-handle)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local cam = lurek.camera.new(800, 600)
    print("is LCamera = " .. tostring(cam:typeOf("LCamera")))
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
    print("camera updated")
    print("position = " .. x .. ", " .. y)
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
    print("path progress = " .. cam:pathProgress())
    print("position = " .. x .. ", " .. y)
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
    cam:updateZoom(0.5)
    print("zoom after 0.5s = " .. cam:getZoom())
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
    print("zoom pulse: amplitude=0.2, dur=0.3s")
    print("effective zoom = " .. tostring(cam:getEffectiveZoom()))
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
    print("zooming to 2x over 1s")
end
```

---

## LCameraRig Handle

### Fields

*No documented fields for this handle.*

### Methods

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
    print("applied main = " .. tostring(ok))
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
    print("has=" .. tostring(has) .. " vp=" .. x .. "," .. y .. "," .. w .. "," .. h)
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
    print("has x = " .. tostring(rig:has("x")))
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
    print("minimap layout applied")
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
    print("cameras = " .. #list)
    print("first name = " .. tostring(list[1]))
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
    print("PiP layout applied")
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
    print("removed = " .. tostring(ok))
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
    print("camera positioned: left")
    print("rig has left = " .. tostring(rig:has("left")))
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
    print("target set on cam1")
    print("rig has cam1 = " .. tostring(rig:has("cam1")))
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
    print("zoom set on camera a")
    print("camera count = " .. tostring(#list))
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
    print("split screen layout applied")
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
| string | The string `[LCameraRig](#lcamerarig-handle)`. |

**Example**

```lua
do
    local rig = lurek.camera.newRig()
    print("type = " .. rig:type())
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
| `name` | string | Type name to compare against `[LCameraRig](#lcamerarig-handle)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local rig = lurek.camera.newRig()
    print("is LCameraRig = " .. tostring(rig:typeOf("LCameraRig")))
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
    print("all cameras updated")
    print("camera count = " .. tostring(#rig:names()))
end
```

---
