# Raycaster

## Summary

- The raycaster module projects 2D grid maps into pseudo-3D first-person scenes.
- Core traversal uses DDA ray marching for reliable tile intersection.
- Perpendicular distance correction reduces fish-eye distortion artifacts.
- Layered hit traversal supports transparent or partially passable surfaces.
- Heightmaps support variable floor and ceiling profiles.
- Multilevel support enables stacked slices and vertical transition logic.
- Sliding doors are tracked as stateful animated grid occupants.
- Grid-motion helpers support classic tile-snapped dungeon movement.
- Billboard sprites represent dynamic entities in camera-facing projection.
- Depth-aware ordering prevents billboard leakage through wall columns.
- Scene building composes walls, floors, ceilings, sprites, and optional mesh inserts.
- Lighting combines ambient and point-light effects with occlusion checks.
- Depth buffers track wall ownership per screen column.
- GPU path emits render commands for shared backend composition.
- CPU software path supports snapshots, tests, and tool previews.
- Tile picking maps screen coordinates back to hit tile and side semantics.
- Visibility helpers support line-of-sight and fan-style query tooling.
- Visualization utilities generate diagnostic images for rays and depth behavior.
- Column batch structures provide compact transport of cast results.
- Scene structs define a stable handoff between cast and draw phases.
- Camera semantics are kept consistent across cast, pick, and render paths.
- The module is 2D-first and does not implement full 3D physics.
- It owns projection and scene composition for first-person map experiences.
- Dependencies remain aligned with Lurek2D architecture boundaries.
- Invariants emphasize deterministic cast output for fixed camera/map input.
- Ordering invariants preserve coherent depth between walls and billboards.
- APIs support both gameplay runtime and authoring/debug workflows.
- The module is suitable for retro FPS and dungeon crawler experiences.
- It provides strong observability through explicit diagnostics.
- Performance is controlled by bounded per-column processing and culling assumptions.
- Integration with render is direct through shared quad-oriented command language.
- Overall, raycaster is a dedicated Feature Systems view pipeline.
- It delivers practical first-person rendering without a full 3D stack.
- This keeps implementation affordable while preserving gameplay readability.
- The module is robust enough for production maps and iterative prototypes.
- It supports deterministic behavior needed by evidence-style tests.

This module primarily collaborates with `color`, `image`, `math`, `render`, `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Functions

### `lurek.raycaster.applyLitShade`

Applies an RGB light color to a scalar shade value.

```lua
lurek.raycaster.applyLitShade(baseShade, r, g, b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `baseShade` | number | Base shade multiplier. |
| `r` | number | Red light channel. |
| `g` | number | Green light channel. |
| `b` | number | Blue light channel. |

**Returns**

| Type | Description |
|------|-------------|
| number | Shaded red channel. |
| number | Shaded green channel. |
| number | Shaded blue channel. |

**Example**

```lua
do
    local r, g, b = lurek.raycaster.applyLitShade(0.5, 1.0, 0.8, 0.6)
    print("lit shade = " .. r .. "," .. g .. "," .. b)
    print("red positive = " .. tostring(r > 0))
end
```

---

### `lurek.raycaster.distanceShade`

Returns a brightness multiplier (0.0..1.0) based on distance for fog/darkness falloff.

```lua
lurek.raycaster.distanceShade(distance, maxDistance)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `distance` | number | Distance to shade. |
| `maxDistance` | number | Distance at which shade reaches zero. |

**Returns**

| Type | Description |
|------|-------------|
| number | Shade factor (1.0 at distance 0, approaching 0.0 at maxDistance). |

**Example**

```lua
do
    local near = lurek.raycaster.distanceShade(0, 10)
    local mid = lurek.raycaster.distanceShade(5, 10)
    local far = lurek.raycaster.distanceShade(9, 10)

    print("near = " .. string.format("%.2f", near))
    print("mid = " .. string.format("%.2f", mid))
    print("far = " .. string.format("%.2f", far))
end
```

---

### `lurek.raycaster.new`

Creates a new raycaster map with the given grid dimensions.

```lua
lurek.raycaster.new(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | number | Map width in cells. |
| `h` | number | Map height in cells. |

**Returns**

| Type | Description |
|------|-------------|
| [LRaycaster](#lraycaster) | A new raycaster map instance. |

**Example**

```lua
do
    local map = lurek.raycaster.new(16, 16)
    print("width = " .. map:width())
    print("height = " .. map:height())
end
```

---

### `lurek.raycaster.newDoorManager`

Creates a new door manager for tracking and animating sliding doors.

```lua
lurek.raycaster.newDoorManager()
```

**Returns**

| Type | Description |
|------|-------------|
| [LDoorManager](#ldoormanager) | A new empty door manager. |

**Example**

```lua
do
    local doors = lurek.raycaster.newDoorManager()
    local first = doors:addDoor(5, 3, "horizontal", 2.0)
    local second = doors:addDoor(8, 6, "vertical", 1.5)

    print("first id = " .. first)
    print("second id = " .. second)
    print("count = " .. doors:count())
end
```

---

### `lurek.raycaster.newHeightMap`

Creates a new height map for variable floor/ceiling heights across the grid.

```lua
lurek.raycaster.newHeightMap(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | number | Width in cells. |
| `h` | number | Height in cells. |

**Returns**

| Type | Description |
|------|-------------|
| [LHeightMap](#lheightmap) | A new height map initialized to zero. |

**Example**

```lua
do
    local hm = lurek.raycaster.newHeightMap(16, 16)
    hm:setFloor(5, 5, -0.3)
    hm:setCeiling(5, 5, 0.8)
    hm:setFloor(10, 10, 0.2)
    hm:setCeiling(10, 10, 1.5)

    print("floor(5,5) = " .. hm:floorAt(5, 5))
    print("ceiling(10,10) = " .. hm:ceilingAt(10, 10))
end
```

---

### `lurek.raycaster.newMap`

Creates a new raycaster map (alias for `new`).

```lua
lurek.raycaster.newMap(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | number | Map width in cells. |
| `h` | number | Map height in cells. |

**Returns**

| Type | Description |
|------|-------------|
| [LRaycaster](#lraycaster) | A new raycaster map instance. |

**Example**

```lua
do
    local map = lurek.raycaster.newMap(32, 32)
    print("width = " .. map:width())
    print("height = " .. map:height())
end
```

---

### `lurek.raycaster.newPointLight`

Creates a new point light with position, color, radius, and intensity.

```lua
lurek.raycaster.newPointLight(x, y, r, g, b, radius, intensity)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | World X position. |
| `y` | number | World Y position. |
| `r` | number | Red channel (0.0..1.0). |
| `g` | number | Green channel (0.0..1.0). |
| `b` | number | Blue channel (0.0..1.0). |
| `radius` | number | Light falloff radius in world units. |
| `intensity` | number | Brightness multiplier. |

**Returns**

| Type | Description |
|------|-------------|
| [LPointLight](#lpointlight) | A new point light instance. |

**Example**

```lua
do
    local torch = lurek.raycaster.newPointLight(5.5, 3.5, 1.0, 0.8, 0.4, 4.0, 1.5)
    local r, g, b = torch:color()

    print("pos = " .. torch:x() .. "," .. torch:y())
    print("color = " .. r .. "," .. g .. "," .. b)
    print("radius = " .. torch:radius() .. " intensity = " .. torch:intensity())
end
```

---

### `lurek.raycaster.newSpriteManager`

Creates a new sprite manager for tracking and projecting billboard sprites.

```lua
lurek.raycaster.newSpriteManager()
```

**Returns**

| Type | Description |
|------|-------------|
| [LSpriteManager](#lspritemanager) | A new empty sprite manager. |

**Example**

```lua
do
    local sprites = lurek.raycaster.newSpriteManager()
    local barrel = sprites:add(5.5, 3.5, "content/examples/assets/images/sample_texture.png", 1.0)
    local torch = sprites:add(8.5, 2.5, "content/examples/assets/images/sample_texture.png", 0.5)
    local enemy = sprites:add(10.5, 7.5, "content/examples/assets/images/sample_texture.png", 1.2)

    sprites:setPosition(enemy, 11, 8)
    sprites:setVisible(torch, false)
    sprites:remove(barrel)

    print("torch id = " .. torch)
    print("enemy id = " .. enemy)
end
```

---

### `lurek.raycaster.projectColumn`

Computes the projected wall-column height for a given distance, FOV, and screen height.

```lua
lurek.raycaster.projectColumn(distance, fov, screenHeight)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `distance` | number | Perpendicular distance to the wall. |
| `fov` | number | Field of view in radians. |
| `screenHeight` | number | Screen height in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| number | Projected column height in pixels. |

**Example**

```lua
do
    local height, top, bottom = lurek.raycaster.projectColumn(5.0, math.pi / 3, 200)

    print("height = " .. string.format("%.1f", height))
    print("top = " .. string.format("%.1f", top))
    print("bottom = " .. string.format("%.1f", bottom))
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

- [LDoorManager](#ldoormanager)
- [LHeightMap](#lheightmap)
- [LPointLight](#lpointlight)
- [LRaycaster](#lraycaster)
- [LSpriteManager](#lspritemanager)

## LDoorManager

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LDoorManager:addDoor`

Registers a new sliding door at the given grid cell.

```lua
LDoorManager:addDoor(x, y, direction, speed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Grid column of the door cell. |
| `y` | number | Grid row of the door cell. |
| `direction` | string | Slide axis: "horizontal" or "vertical". |
| `speed` | number | How fast the door opens/closes (units per second). |

**Returns**

| Type | Description |
|------|-------------|
| number | Zero-based index of the newly added door. |

**Example**

```lua
do
    local dm = lurek.raycaster.newDoorManager()
    local id = dm:addDoor(5, 5, "horizontal", 0.5)
    local door = dm:getDoor(id)

    print("count = " .. dm:count())
    print("state = " .. door.state)
end
```

---

#### `LDoorManager:closeDoor`

Begins closing the door at the given index. The door animates over time via `update()`.

```lua
LDoorManager:closeDoor(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | Zero-based index of the door to close. |

**Example**

```lua
do
    local dm = lurek.raycaster.newDoorManager()
    local id = dm:addDoor(5, 5, "horizontal", 0.5)
    dm:openDoor(id)
    dm:update(0.5)
    dm:closeDoor(id)
    dm:update(0.25)

    local door = dm:getDoor(id)

    print("state = " .. door.state)
    print("open = " .. string.format("%.2f", door.openAmount))
end
```

---

#### `LDoorManager:count`

Returns the total number of registered doors.

```lua
LDoorManager:count()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Door count. |

**Example**

```lua
do
    local dm = lurek.raycaster.newDoorManager()
    dm:addDoor(5, 5, "horizontal", 0.5)
    dm:addDoor(6, 5, "vertical", 0.25)

    print("count = " .. dm:count())
end
```

---

#### `LDoorManager:getDoor`

Returns a table describing the door at the given index, or nil if index is out of range.

```lua
LDoorManager:getDoor(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | Zero-based index of the door to query. |

**Returns**

| Type | Description |
|------|-------------|
| LDoorManagerGetDoorResult | Door info table, or nil if not found. |

**Example**

```lua
do
    local doors = lurek.raycaster.newDoorManager()
    local idx = doors:addDoor(3, 3, "vertical", 4.0)

    doors:openDoor(idx)
    for _ = 1, 10 do
        doors:update(0.1)
    end

    local door = doors:getDoor(idx)

    print("state = " .. door.state)
    print("open = " .. string.format("%.2f", door.openAmount))
end
```

---

#### `LDoorManager:openDoor`

Begins opening the door at the given index. The door animates over time via `update()`.

```lua
LDoorManager:openDoor(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | Zero-based index of the door to open. |

**Example**

```lua
do
    local dm = lurek.raycaster.newDoorManager()
    local id = dm:addDoor(5, 5, "horizontal", 0.5)
    dm:openDoor(id)
    dm:update(0.1)

    local door = dm:getDoor(id)

    print("state = " .. door.state)
    print("open = " .. string.format("%.2f", door.openAmount))
end
```

---

#### `LDoorManager:type`

Returns the type name of this object.

```lua
LDoorManager:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always "[LDoorManager](#ldoormanager)". |

**Example**

```lua
do
    local doors = lurek.raycaster.newDoorManager()
    print("type = " .. doors:type())
end
```

---

#### `LDoorManager:typeOf`

Checks whether this object matches the given type name.

```lua
LDoorManager:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the name matches this userdata type. |

**Example**

```lua
do
    local doors = lurek.raycaster.newDoorManager()
    print("LDoorManager = " .. tostring(doors:typeOf("LDoorManager")))
    print("LObject = " .. tostring(doors:typeOf("LObject")))
end
```

---

#### `LDoorManager:update`

Advances all door animations by the given delta time. Call once per frame.

```lua
LDoorManager:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Delta time in seconds since last frame. |

**Example**

```lua
do
    local dm = lurek.raycaster.newDoorManager()
    local id = dm:addDoor(5, 5, "horizontal", 0.5)
    dm:openDoor(id)
    dm:update(0.1)

    local door = dm:getDoor(id)

    print("state = " .. door.state)
    print("open = " .. string.format("%.2f", door.openAmount))
end
```

---

## LHeightMap

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LHeightMap:ceilingAt`

Returns the ceiling height offset at a given grid cell.

```lua
LHeightMap:ceilingAt(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Grid column. |
| `y` | number | Grid row. |

**Returns**

| Type | Description |
|------|-------------|
| number | Ceiling height offset at that cell. |

**Example**

```lua
do
    local hm = lurek.raycaster.newHeightMap(16, 16)
    hm:setFloor(3, 3, 0.2)
    hm:setCeiling(3, 3, 0.9)

    print("ceiling = " .. hm:ceilingAt(3, 3))
end
```

---

#### `LHeightMap:floorAt`

Returns the floor height offset at a given grid cell.

```lua
LHeightMap:floorAt(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Grid column. |
| `y` | number | Grid row. |

**Returns**

| Type | Description |
|------|-------------|
| number | Floor height offset at that cell. |

**Example**

```lua
do
    local hm = lurek.raycaster.newHeightMap(16, 16)
    hm:setFloor(3, 3, 0.2)
    hm:setCeiling(3, 3, 0.9)

    print("floor = " .. hm:floorAt(3, 3))
end
```

---

#### `LHeightMap:setCeiling`

Sets the ceiling height offset at a specific grid cell.

```lua
LHeightMap:setCeiling(x, y, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Grid column. |
| `y` | number | Grid row. |
| `h` | number | Ceiling height offset (0.0 = default ceiling level). |

**Example**

```lua
do
    local hm = lurek.raycaster.newHeightMap(16, 16)
    hm:setCeiling(3, 3, 0.9)

    print("ceiling = " .. hm:ceilingAt(3, 3))
end
```

---

#### `LHeightMap:setFloor`

Sets the floor height offset at a specific grid cell.

```lua
LHeightMap:setFloor(x, y, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Grid column. |
| `y` | number | Grid row. |
| `h` | number | Floor height offset (0.0 = default floor level). |

**Example**

```lua
do
    local hm = lurek.raycaster.newHeightMap(16, 16)
    hm:setFloor(3, 3, 0.2)

    print("floor = " .. hm:floorAt(3, 3))
end
```

---

#### `LHeightMap:type`

Returns the type name of this object.

```lua
LHeightMap:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always "[LHeightMap](#lheightmap)". |

**Example**

```lua
do
    local hm = lurek.raycaster.newHeightMap(4, 4)
    print("type = " .. hm:type())
end
```

---

#### `LHeightMap:typeOf`

Checks whether this object matches the given type name.

```lua
LHeightMap:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the name matches this userdata type. |

**Example**

```lua
do
    local hm = lurek.raycaster.newHeightMap(4, 4)
    print("LHeightMap = " .. tostring(hm:typeOf("LHeightMap")))
    print("LObject = " .. tostring(hm:typeOf("LObject")))
end
```

---

## LPointLight

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LPointLight:color`

Returns the RGB color components of this light.

```lua
LPointLight:color()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Red channel (0.0..1.0). |
| number | Green channel (0.0..1.0). |
| number | Blue channel (0.0..1.0). |

**Example**

```lua
do
    local pl = lurek.raycaster.newPointLight(8, 8, 1, 1, 0.8, 5.0, 2.0)
    local r, g, b = pl:color()

    print("color = " .. r .. "," .. g .. "," .. b)
end
```

---

#### `LPointLight:intensity`

Returns the brightness multiplier of this light.

```lua
LPointLight:intensity()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Intensity. |

**Example**

```lua
do
    local pl = lurek.raycaster.newPointLight(8, 8, 1, 1, 0.8, 5.0, 2.0)

    print("intensity = " .. pl:intensity())
end
```

---

#### `LPointLight:radius`

Returns the light's falloff radius in world units.

```lua
LPointLight:radius()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Radius. |

**Example**

```lua
do
    local pl = lurek.raycaster.newPointLight(8, 8, 1, 1, 0.8, 5.0, 2.0)

    print("radius = " .. pl:radius())
end
```

---

#### `LPointLight:set`

Overwrites all properties of this point light in a single call.

```lua
LPointLight:set(x, y, r, g, b, radius, intensity)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | New X world position. |
| `y` | number | New Y world position. |
| `r` | number | Red color channel (0.0..1.0). |
| `g` | number | Green color channel (0.0..1.0). |
| `b` | number | Blue color channel (0.0..1.0). |
| `radius` | number | Falloff radius in world units. |
| `intensity` | number | Brightness multiplier. |

**Example**

```lua
do
    local light = lurek.raycaster.newPointLight(2, 2, 1, 1, 1, 3, 1.0)
    light:set(8, 8, 0, 0, 1, 6, 2.0)
    local r, g, b = light:color()

    print("pos = " .. light:x() .. "," .. light:y())
    print("color = " .. r .. "," .. g .. "," .. b)
    print("radius = " .. light:radius() .. " intensity = " .. light:intensity())
end
```

---

#### `LPointLight:type`

Returns the type name of this object ("[LPointLight](#lpointlight)").

```lua
LPointLight:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Type name string. |

**Example**

```lua
do
    local light = lurek.raycaster.newPointLight(0, 0, 1, 1, 1, 1, 1)
    print("type = " .. light:type())
end
```

---

#### `LPointLight:typeOf`

Checks whether this object matches the given type name.

```lua
LPointLight:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to test against. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if this object is of the given type. |

**Example**

```lua
do
    local light = lurek.raycaster.newPointLight(0, 0, 1, 1, 1, 1, 1)
    print("LPointLight = " .. tostring(light:typeOf("LPointLight")))
    print("LObject = " .. tostring(light:typeOf("LObject")))
end
```

---

#### `LPointLight:x`

Returns the X world position of this light.

```lua
LPointLight:x()
```

**Returns**

| Type | Description |
|------|-------------|
| number | X coordinate. |

**Example**

```lua
do
    local pl = lurek.raycaster.newPointLight(8, 8, 1, 1, 0.8, 5.0, 2.0)

    print("x = " .. pl:x())
end
```

---

#### `LPointLight:y`

Returns the Y world position of this light.

```lua
LPointLight:y()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Y coordinate. |

**Example**

```lua
do
    local pl = lurek.raycaster.newPointLight(8, 8, 1, 1, 0.8, 5.0, 2.0)

    print("y = " .. pl:y())
end
```

---

## LRaycaster

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LRaycaster:buildMinimapWindow`

Generates a grid of minimap tile samples around a center point with lighting info.

```lua
LRaycaster:buildMinimapWindow(centerX, centerY, radius, ambient, lights)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `centerX` | number | Center X in world coordinates. |
| `centerY` | number | Center Y in world coordinates. |
| `radius` | number | Tile radius around the center to sample. |
| `ambient` | number | Ambient light level (0.0..1.0). |
| `lights?` | table | Array of point-light tables. |

**Returns**

| Type | Description |
|------|-------------|
| LRaycasterBuildMinimapWindowResult | Array of {x, y, blocked, visible, r, g, b, luma} tables. |

**Example**

```lua
do
    local map = lurek.raycaster.new(16, 16)
    for i = 0, 15 do
        map:setCell(i, 0, 1)
        map:setCell(i, 15, 1)
        map:setCell(0, i, 1)
        map:setCell(15, i, 1)
    end

    map:setCell(5, 8, 1)
    local lights = {
        { x = 8, y = 8, r = 1.0, g = 1.0, b = 0.8, radius = 5.0, intensity = 1.0 },
    }
    local cells = map:buildMinimapWindow(8, 8, 5, 0.2, lights)

    print("sample count = " .. #cells)
    if cells[1] then
        print("first cell = " .. cells[1].x .. "," .. cells[1].y)
        print("first luma = " .. string.format("%.2f", cells[1].luma))
    end
end
```

---

#### `LRaycaster:buildScene`

Builds a complete textured raycaster scene for GPU rendering. Stores the output internally.

```lua
LRaycaster:buildScene(params, lights, sprites, wallTextures)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `params` | table | Scene params {px, py, angle, fov, rays, max_dist, screen_w, screen_h, ambient?, shade_dist?, floor_r/g/b?, ceiling_r/g/b?, camera_height?, horizon_offset?}. |
| `lights?` | table | Array of point-light tables {x, y, radius, r?, g?, b?, intensity?}. |
| `sprites?` | table | Array of sprite tables {x, y, texture, size?}. |
| `wallTextures?` | table | Map of cell_value -> texture for wall surfaces. |

**Returns**

| Type | Description |
|------|-------------|
| number | Total number of quads in the built scene. |

**Example**

```lua
do
    local map = lurek.raycaster.new(16, 16)
    local wall_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local sprite_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")

    for i = 0, 15 do
        map:setCell(i, 0, 1)
        map:setCell(i, 15, 1)
        map:setCell(0, i, 1)
        map:setCell(15, i, 1)
    end

    local params = {
        px = 8,
        py = 8,
        angle = 0,
        fov = math.pi / 3,
        rays = 64,
        max_dist = 16,
        screen_w = 320,
        screen_h = 200,
    }
    local lights = {
        { x = 8, y = 8, r = 1.0, g = 0.9, b = 0.8, radius = 4.0, intensity = 1.5 },
    }
    local sprites = {
        { x = 10.5, y = 8.0, texture = sprite_tex, size = 1.0 },
    }
    local wall_textures = {
        [1] = wall_tex,
    }
    local quad_count = map:buildScene(params, lights, sprites, wall_textures)

    print("quad count = " .. quad_count)
end
```

---

#### `LRaycaster:buildSceneWithModels`

Builds a textured raycaster scene with additional 3D .obj model instances projected into the view.

```lua
LRaycaster:buildSceneWithModels(params, lights, sprites, wallTextures, models)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `params` | table | Scene params (same as buildScene). |
| `lights?` | table | Array of point-light tables. |
| `sprites?` | table | Array of sprite tables. |
| `wallTextures?` | table | Map of cell_value -> texture. |
| `models?` | table | Array of model instance tables {model, x, y, rotation?, scale?}. |

**Returns**

| Type | Description |
|------|-------------|
| number | Total number of quads in the built scene. |

**Example**

```lua
do
    local rc = lurek.raycaster.new(80, 60)
    local params = {
        px = 8,
        py = 8,
        angle = 0,
        fov = math.pi / 3,
        rays = 40,
        max_dist = 20,
        screen_w = 160,
        screen_h = 90,
    }
    local count = rc:buildSceneWithModels(params, nil, nil, nil, nil)

    print("quad count = " .. count)
end
```

---

#### `LRaycaster:castFloorRow`

Computes floor/ceiling texture UV coordinates for a single scanline row.

```lua
LRaycaster:castFloorRow(camX, camY, dirX, dirY, planeX, planeY, row)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `camX` | number | Camera X position. |
| `camY` | number | Camera Y position. |
| `dirX` | number | Camera forward direction X. |
| `dirY` | number | Camera forward direction Y. |
| `planeX` | number | Camera plane X (half-width of FOV). |
| `planeY` | number | Camera plane Y (half-width of FOV). |
| `row` | number | Scanline row offset from screen center. |

**Returns**

| Type | Description |
|------|-------------|
| LRaycasterCastFloorRowResult | Array of {u, v} tables for each pixel in the row. |

**Example**

```lua
do
    local map = lurek.raycaster.new(16, 16)
    local uvs = map:castFloorRow(8, 8, 1, 0, 0, 0.66, 150)

    print("uv count = " .. #uvs)
    if uvs[1] then
        print("first uv = " .. string.format("%.2f", uvs[1].u) .. "," .. string.format("%.2f", uvs[1].v))
    end
end
```

---

#### `LRaycaster:castRay`

Casts a single ray from (ox,oy) at the given angle and returns hit info or nil.

```lua
LRaycaster:castRay(ox, oy, angle, maxDist)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ox` | number | Ray origin X. |
| `oy` | number | Ray origin Y. |
| `angle` | number | Ray direction in radians. |
| `maxDist` | number | Maximum cast distance. |

**Returns**

| Type | Description |
|------|-------------|
| LRaycasterCastRayResult | Hit table {distance, raw_distance, cell_value, alpha, side, tex_u, hit_x, hit_y, hit} or nil. |

**Example**

```lua
do
    local map = lurek.raycaster.new(16, 16)
    for i = 0, 15 do
        map:setCell(i, 0, 1)
        map:setCell(i, 15, 1)
        map:setCell(0, i, 1)
        map:setCell(15, i, 1)
    end

    local hit = map:castRay(8, 8, 0, 20)

    if hit then
        print("distance = " .. string.format("%.2f", hit.distance))
        print("cell = " .. hit.cell_value .. " side = " .. hit.side)
    end
end
```

---

#### `LRaycaster:castRayMulti`

Casts a single ray that passes through transparent walls, returning multiple hits.

```lua
LRaycaster:castRayMulti(ox, oy, angle, maxDist, maxHits)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ox` | number | Ray origin X. |
| `oy` | number | Ray origin Y. |
| `angle` | number | Ray direction in radians. |
| `maxDist` | number | Maximum cast distance. |
| `maxHits?` | number | Maximum number of hits to collect (default 4, max 8). |

**Returns**

| Type | Description |
|------|-------------|
| LRaycasterCastRayMultiResult | Array of hit tables in distance order. |

**Example**

```lua
do
    local map = lurek.raycaster.new(16, 16)
    map:setCell(5, 8, 2)
    map:setCell(10, 8, 1)
    map:setWallAlpha(2, 0.5)

    local hits = map:castRayMulti(2, 8.5, 0, 20, 4)

    print("hit count = " .. #hits)
    if hits[1] then
        print("first distance = " .. string.format("%.2f", hits[1].distance))
        print("first cell = " .. hits[1].cell_value)
    end
end
```

---

#### `LRaycaster:castRays`

Casts multiple rays across a field of view and returns an array of hit tables.

```lua
LRaycaster:castRays(ox, oy, angle, fov, count, maxDist)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ox` | number | Ray origin X. |
| `oy` | number | Ray origin Y. |
| `angle` | number | Center angle in radians. |
| `fov` | number | Field of view in radians. |
| `count` | number | Number of rays to cast. |
| `maxDist` | number | Maximum cast distance per ray. |

**Returns**

| Type | Description |
|------|-------------|
| LRaycasterCastRaysResult | Array of hit tables (same fields as castRay). |

**Example**

```lua
do
    local map = lurek.raycaster.new(16, 16)
    for i = 0, 15 do
        map:setCell(i, 0, 1)
        map:setCell(i, 15, 1)
        map:setCell(0, i, 1)
        map:setCell(15, i, 1)
    end

    local hits = map:castRays(8, 8, 0, math.pi / 3, 10, 20)

    print("ray count = " .. #hits)
    if hits[1] then
        print("first distance = " .. string.format("%.2f", hits[1].distance))
    end
end
```

---

#### `LRaycaster:castRaysFlat`

Casts multiple rays and returns only the corrected distances as a flat array.

```lua
LRaycaster:castRaysFlat(ox, oy, angle, fov, count, maxDist)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ox` | number | Ray origin X. |
| `oy` | number | Ray origin Y. |
| `angle` | number | Center angle in radians. |
| `fov` | number | Field of view in radians. |
| `count` | number | Number of rays to cast. |
| `maxDist` | number | Maximum cast distance per ray. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Flat array of corrected distance values. |

**Example**

```lua
do
    local map = lurek.raycaster.new(16, 16)
    for i = 0, 15 do
        map:setCell(i, 0, 1)
        map:setCell(i, 15, 1)
        map:setCell(0, i, 1)
        map:setCell(15, i, 1)
    end

    local flat = map:castRaysFlat(8, 8, 0, math.pi / 3, 6, 20)

    print("flat value count = " .. #flat)
    print("first ray distance = " .. string.format("%.2f", flat[1] or 0))
    print("first ray cell = " .. tostring(flat[2]))
end
```

---

#### `LRaycaster:computeTileLight`

Computes the combined lighting color at a tile from ambient and point lights, accounting for walls.

```lua
LRaycaster:computeTileLight(x, y, ambient, lights)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Tile grid column. |
| `y` | number | Tile grid row. |
| `ambient` | number | Base ambient light level (0.0..1.0). |
| `lights?` | table | Array of point-light tables {x, y, radius, r?, g?, b?, intensity?}. |

**Returns**

| Type | Description |
|------|-------------|
| number | Red light channel. |
| number | Green light channel. |
| number | Blue light channel. |
| number | Average luminance. |

**Example**

```lua
do
    local map = lurek.raycaster.new(16, 16)
    local lights = {
        { x = 8, y = 8, r = 1.0, g = 0.9, b = 0.7, radius = 5.0, intensity = 2.0 },
        { x = 3, y = 3, r = 0.2, g = 0.5, b = 1.0, radius = 3.0, intensity = 1.0 },
    }
    local r, g, b, luma = map:computeTileLight(7, 8, 0.1, lights)

    print("r = " .. string.format("%.2f", r))
    print("g = " .. string.format("%.2f", g))
    print("luma = " .. string.format("%.2f", luma))
end
```

---

#### `LRaycaster:drawCameraSweep`

Renders multiple frames of a rotating camera sweep as a single combined image.

```lua
LRaycaster:drawCameraSweep(x, y, fov, maxDist, numFrames, fw, fh)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Camera X position. |
| `y` | number | Camera Y position. |
| `fov` | number | Field of view in radians. |
| `maxDist` | number | Maximum render distance. |
| `numFrames` | number | Number of rotation steps. |
| `fw` | number | Frame width in pixels. |
| `fh` | number | Frame height in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](render.md#limagedata) | Raw image data for all frames. |

**Example**

```lua
do
    local map = lurek.raycaster.new(8, 8)
    for i = 0, 7 do
        map:setCell(i, 0, 1)
        map:setCell(i, 7, 1)
        map:setCell(0, i, 1)
        map:setCell(7, i, 1)
    end

    local strip = map:drawCameraSweep(4, 4, math.pi / 3, 8, 8, 160, 100)

    print("width = " .. strip:getWidth())
    print("height = " .. strip:getHeight())
end
```

---

#### `LRaycaster:drawDepthMap`

Renders a grayscale depth map showing distance-to-wall for each column.

```lua
LRaycaster:drawDepthMap(px, py, angle, fov, numRays, w, h, maxDist)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `px` | number | Player X position. |
| `py` | number | Player Y position. |
| `angle` | number | Player facing angle in radians. |
| `fov` | number | Field of view in radians. |
| `numRays` | number | Number of rays (columns) to cast. |
| `w` | number | Output image width in pixels. |
| `h` | number | Output image height in pixels. |
| `maxDist` | number | Maximum render distance. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](render.md#limagedata) | Raw depth-map image data. |

**Example**

```lua
do
    local map = lurek.raycaster.new(16, 16)
    for i = 0, 15 do
        map:setCell(i, 0, 1)
        map:setCell(i, 15, 1)
        map:setCell(0, i, 1)
        map:setCell(15, i, 1)
    end

    local depth = map:drawDepthMap(8, 8, 0, math.pi / 3, 160, 160, 100, 16)

    print("width = " .. depth:getWidth())
    print("height = " .. depth:getHeight())
end
```

---

#### `LRaycaster:drawLineOfSight`

Renders a debug image showing the line-of-sight ray between two world points.

```lua
LRaycaster:drawLineOfSight(ax, ay, bx, by, scale)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ax` | number | Start X. |
| `ay` | number | Start Y. |
| `bx` | number | End X. |
| `by` | number | End Y. |
| `scale` | number | Pixels per grid cell. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](render.md#limagedata) | Raw image data for this view. |

**Example**

```lua
do
    local map = lurek.raycaster.new(8, 8)
    map:setCell(4, 4, 1)

    local img = map:drawLineOfSight(1, 1, 7, 7, 16)

    print("width = " .. img:getWidth())
    print("height = " .. img:getHeight())
end
```

---

#### `LRaycaster:drawTopDown`

Renders a top-down debug view of the map with the player's position and direction.

```lua
LRaycaster:drawTopDown(px, py, angle, scale)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `px` | number | Player X position. |
| `py` | number | Player Y position. |
| `angle` | number | Player facing angle in radians. |
| `scale` | number | Pixels per grid cell. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](render.md#limagedata) | Raw image data. |

**Example**

```lua
do
    local map = lurek.raycaster.new(8, 8)
    for i = 0, 7 do
        map:setCell(i, 0, 1)
        map:setCell(i, 7, 1)
        map:setCell(0, i, 1)
        map:setCell(7, i, 1)
    end

    map:setCell(3, 3, 1)

    local img = map:drawTopDown(4.5, 4.5, 0, 16)

    print("width = " .. img:getWidth())
    print("height = " .. img:getHeight())
end
```

---

#### `LRaycaster:drawView`

Renders a first-person raycaster view to a raw image buffer (no textures, flat-shaded).

```lua
LRaycaster:drawView(px, py, angle, fov, w, h, maxDist)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `px` | number | Player X position. |
| `py` | number | Player Y position. |
| `angle` | number | Player facing angle in radians. |
| `fov` | number | Field of view in radians. |
| `w` | number | Output image width in pixels. |
| `h` | number | Output image height in pixels. |
| `maxDist` | number | Maximum render distance. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](render.md#limagedata) | Raw image data. |

**Example**

```lua
do
    local map = lurek.raycaster.new(16, 16)
    for i = 0, 15 do
        map:setCell(i, 0, 1)
        map:setCell(i, 15, 1)
        map:setCell(0, i, 1)
        map:setCell(15, i, 1)
    end

    local img = map:drawView(8, 8, 0, math.pi / 3, 320, 200, 16)

    print("width = " .. img:getWidth())
    print("height = " .. img:getHeight())
end
```

---

#### `LRaycaster:extractMinimap`

Extracts a pixel minimap image centered on the player from this raycaster map.

```lua
LRaycaster:extractMinimap(playerX, playerY, playerAngle, viewRadius, cellSize)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `playerX` | number | Player x position in world space. |
| `playerY` | number | Player y position in world space. |
| `playerAngle` | number | Player facing angle in radians. |
| `viewRadius` | number | Visible tile radius around the player. |
| `cellSize` | number | Pixel size of each minimap cell. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](render.md#limagedata) | Image data containing the extracted minimap. |

**Example**

```lua
do
    local map = lurek.raycaster.new(8, 8)
    map:setCell(0, 0, 1)
    map:setCell(1, 0, 1)
    map:setCell(0, 1, 1)
    local image = map:extractMinimap(4.0, 4.0, 0.0, 3, 4)
    print("minimap type = " .. image:type())
    print("minimap width = " .. image:getWidth())
end
```

---

#### `LRaycaster:getCeilingTextureCell`

Returns the raw texture id assigned to this ceiling cell, or nil if none.

```lua
LRaycaster:getCeilingTextureCell(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Grid column. |
| `y` | number | Grid row. |

**Returns**

| Type | Description |
|------|-------------|
| number | Raw texture id or nil. |

**Example**

```lua
do
    local map = lurek.raycaster.new(8, 8)
    local ceil_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")

    map:setCeilingTextureCell(2, 2, ceil_tex)

    print("ceiling(2,2) = " .. tostring(map:getCeilingTextureCell(2, 2)))
    print("ceiling(0,0) = " .. tostring(map:getCeilingTextureCell(0, 0)))
end
```

---

#### `LRaycaster:getCell`

Returns the wall type value at a grid cell.

```lua
LRaycaster:getCell(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Grid column. |
| `y` | number | Grid row. |

**Returns**

| Type | Description |
|------|-------------|
| number | Cell value (0 = empty, 1+ = wall type). |

**Example**

```lua
do
    local map = lurek.raycaster.new(8, 8)
    map:setCell(0, 0, 1)
    local value = map:getCell(0, 0)
    local empty = map:getCell(7, 7)

    print("cell(0,0) = " .. value)
    print("cell(7,7) = " .. empty)
end
```

---

#### `LRaycaster:getFloorTextureCell`

Returns the raw texture id assigned to this floor cell, or nil if none.

```lua
LRaycaster:getFloorTextureCell(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Grid column. |
| `y` | number | Grid row. |

**Returns**

| Type | Description |
|------|-------------|
| number | Raw texture id or nil. |

**Example**

```lua
do
    local map = lurek.raycaster.new(8, 8)
    local floor_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")

    map:setFloorTextureCell(3, 3, floor_tex)

    print("floor(3,3) = " .. tostring(map:getFloorTextureCell(3, 3)))
    print("floor(0,0) = " .. tostring(map:getFloorTextureCell(0, 0)))
end
```

---

#### `LRaycaster:getLoweredFloorCell`

Returns the lowered floor configuration at a cell, or nil if the cell is normal.

```lua
LRaycaster:getLoweredFloorCell(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Grid column. |
| `y` | number | Grid row. |

**Returns**

| Type | Description |
|------|-------------|
| LRaycasterGetLoweredFloorCellResult | Table {texture, depth, r, g, b, blocked} or nil. |

**Example**

```lua
do
    local map = lurek.raycaster.new(8, 8)
    local pit_texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png")

    map:setLoweredFloorCell(4, 4, {
        texture = pit_texture,
        depth = 0.3,
        r = 0.1,
        g = 0.4,
        b = 0.8,
        blocked = false,
    })

    local cell = map:getLoweredFloorCell(4, 4)

    if cell then
        print("texture = " .. tostring(cell.texture))
        print("depth = " .. cell.depth)
        print("blocked = " .. tostring(cell.blocked))
    end
end
```

---

#### `LRaycaster:getWallAlpha`

Returns the current transparency value for a wall tile type.

```lua
LRaycaster:getWallAlpha(tileType)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tileType` | number | The cell value to query. |

**Returns**

| Type | Description |
|------|-------------|
| number | Alpha value (0.0..1.0). |

**Example**

```lua
do
    local map = lurek.raycaster.new(8, 8)
    map:setWallAlpha(2, 0.5)

    print("alpha(2) = " .. map:getWallAlpha(2))
    print("alpha(9) = " .. map:getWallAlpha(9))
end
```

---

#### `LRaycaster:gridMove`

Performs a discrete grid-step movement in one of 4 cardinal directions with collision.

```lua
LRaycaster:gridMove(px, py, dir, action, step)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `px` | number | Current X position. |
| `py` | number | Current Y position. |
| `dir` | number | Facing direction 1..4 (1=N, 2=E, 3=S, 4=W). |
| `action` | string | Movement action: "forward", "back", "left", or "right". |
| `step` | number | Step distance in world units (typically 1.0). |

**Returns**

| Type | Description |
|------|-------------|
| number | Final X position. |
| number | Final Y position. |
| boolean | Whether the move succeeded. |

**Example**

```lua
do
    local map = lurek.raycaster.new(8, 8)
    for i = 0, 7 do
        map:setCell(i, 0, 1)
        map:setCell(i, 7, 1)
        map:setCell(0, i, 1)
        map:setCell(7, i, 1)
    end

    local nx, ny, moved = map:gridMove(4.5, 4.5, 2, "forward", 1.0)
    local sx, sy, strafe = map:gridMove(nx, ny, 2, "left", 1.0)

    print("forward = " .. tostring(moved) .. " -> " .. nx .. "," .. ny)
    print("left = " .. tostring(strafe) .. " -> " .. sx .. "," .. sy)
end
```

---

#### `LRaycaster:height`

Returns the map height in grid cells.

```lua
LRaycaster:height()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Map height. |

**Example**

```lua
do
    local rc = lurek.raycaster.new(160, 120)

    print("height = " .. rc:height())
    print("width = " .. rc:width())
end
```

---

#### `LRaycaster:isBlocked`

Returns true if the grid cell is a solid wall (non-zero value).

```lua
LRaycaster:isBlocked(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Grid column. |
| `y` | number | Grid row. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if cell blocks movement and rays. |

**Example**

```lua
do
    local map = lurek.raycaster.new(8, 8)
    map:setCell(3, 3, 1)

    print("cell(3,3) blocked = " .. tostring(map:isBlocked(3, 3)))
    print("cell(2,2) blocked = " .. tostring(map:isBlocked(2, 2)))
end
```

---

#### `LRaycaster:isWalkBlocked`

Returns true if the cell blocks walking (solid wall OR blocked lowered-floor cell).

```lua
LRaycaster:isWalkBlocked(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Grid column. |
| `y` | number | Grid row. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the cell cannot be walked through. |

**Example**

```lua
do
    local map = lurek.raycaster.new(8, 8)
    local pit_texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png")

    map:setLoweredFloorCell(3, 3, {
        texture = pit_texture,
        depth = 0.3,
        blocked = true,
    })

    print("cell(3,3) walk blocked = " .. tostring(map:isWalkBlocked(3, 3)))
    print("cell(2,2) walk blocked = " .. tostring(map:isWalkBlocked(2, 2)))
end
```

---

#### `LRaycaster:lineOfSight`

Tests whether there is a clear line of sight between two world points (no walls in between).

```lua
LRaycaster:lineOfSight(x1, y1, x2, y2)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x1` | number | Start X. |
| `y1` | number | Start Y. |
| `x2` | number | End X. |
| `y2` | number | End Y. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the path is unobstructed. |

**Example**

```lua
do
    local map = lurek.raycaster.new(16, 16)
    map:setCell(8, 8, 1)

    local clear = map:lineOfSight(4, 4, 12, 4)
    local blocked = map:lineOfSight(4, 8, 12, 8)

    print("clear = " .. tostring(clear))
    print("blocked = " .. tostring(blocked))
end
```

---

#### `LRaycaster:projectSprite`

Projects a world-space sprite to screen coordinates for billboard rendering.

```lua
LRaycaster:projectSprite(sx, sy, px, py, pa, fov, screenW)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sx` | number | Sprite world X. |
| `sy` | number | Sprite world Y. |
| `px` | number | Player X position. |
| `py` | number | Player Y position. |
| `pa` | number | Player angle in radians. |
| `fov` | number | Field of view in radians. |
| `screenW` | number | Screen width in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| LRaycasterProjectSpriteResult | Projection info {screen_x, scale, distance, visible}. |

**Example**

```lua
do
    local map = lurek.raycaster.new(16, 16)
    local proj = map:projectSprite(10, 8, 8, 8, 0, math.pi / 3, 320)

    print("screen_x = " .. proj.screen_x)
    print("scale = " .. string.format("%.2f", proj.scale))
    print("visible = " .. tostring(proj.visible))
end
```

---

#### `LRaycaster:revealCellsFromRays`

Casts rays across the FOV and returns a list of grid cells that are visible (for fog-of-war).

```lua
LRaycaster:revealCellsFromRays(ox, oy, angle, fov, count, maxDist, step)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ox` | number | Ray origin X. |
| `oy` | number | Ray origin Y. |
| `angle` | number | Center angle in radians. |
| `fov` | number | Field of view in radians. |
| `count` | number | Number of rays. |
| `maxDist` | number | Maximum ray distance. |
| `step?` | number | Walk step along each ray (default 0.2). |

**Returns**

| Type | Description |
|------|-------------|
| LRaycasterRevealCellsFromRaysResult | Array of {x, y} tables representing revealed grid cells. |

**Example**

```lua
do
    local map = lurek.raycaster.new(16, 16)
    for i = 0, 15 do
        map:setCell(i, 0, 1)
        map:setCell(i, 15, 1)
        map:setCell(0, i, 1)
        map:setCell(15, i, 1)
    end

    map:setCell(6, 8, 1)
    local revealed = map:revealCellsFromRays(8, 8, 0, math.pi * 2, 64, 10)

    print("revealed count = " .. #revealed)
    if revealed[1] then
        print("first cell = " .. revealed[1].x .. "," .. revealed[1].y)
    end
end
```

---

#### `LRaycaster:setCeilingTextureCell`

Assigns a per-cell ceiling texture override. Pass nil to remove the override.

```lua
LRaycaster:setCeilingTextureCell(x, y, texture)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Grid column. |
| `y` | number | Grid row. |
| `texture?` | [LImage](render.md#limage) | Texture image, integer id, or nil to clear. |

**Example**

```lua
do
    local map = lurek.raycaster.new(8, 8)
    local ceil_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")

    map:setCeilingTextureCell(2, 2, ceil_tex)

    print("raw id = " .. tostring(map:getCeilingTextureCell(2, 2)))
end
```

---

#### `LRaycaster:setCell`

Sets the wall type value at a grid cell. Non-zero values are solid walls.

```lua
LRaycaster:setCell(x, y, val)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Grid column. |
| `y` | number | Grid row. |
| `val` | number | Wall type (0 = empty, 1+ = wall texture index). |

**Example**

```lua
do
    local map = lurek.raycaster.new(8, 8)
    map:setCell(0, 0, 1)
    print("cell(0,0) = " .. map:getCell(0, 0))
    print("blocked = " .. tostring(map:isBlocked(0, 0)))
end
```

---

#### `LRaycaster:setCells`

Replaces the entire map grid with a flat array of cell values (row-major order).

```lua
LRaycaster:setCells(cells)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cells` | table | Flat array of numbers with width*height elements. |

**Example**

```lua
do
    local map = lurek.raycaster.new(8, 8)
    local cells = {}

    for i = 1, 64 do
        cells[i] = 0
    end

    for i = 1, 8 do
        cells[i] = 1
    end

    map:setCells(cells)
    print("cell(0,0) = " .. map:getCell(0, 0))
    print("cell(0,1) = " .. map:getCell(0, 1))
end
```

---

#### `LRaycaster:setFloorTextureCell`

Assigns a per-cell floor texture override. Pass nil to remove the override.

```lua
LRaycaster:setFloorTextureCell(x, y, texture)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Grid column. |
| `y` | number | Grid row. |
| `texture?` | [LImage](render.md#limage) | Texture image, integer id, or nil to clear. |

**Example**

```lua
do
    local map = lurek.raycaster.new(8, 8)
    local floor_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")

    map:setFloorTextureCell(3, 3, floor_tex)

    print("raw id = " .. tostring(map:getFloorTextureCell(3, 3)))
end
```

---

#### `LRaycaster:setLoweredFloorCell`

Marks a cell as a lowered floor (pit) with its own texture, depth, tint, and blocking flag.

```lua
LRaycaster:setLoweredFloorCell(x, y, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Grid column. |
| `y` | number | Grid row. |
| `opts?` | table | Options table {texture, depth?, r?, g?, b?, blocked?} or nil to clear. |

**Example**

```lua
do
    local map = lurek.raycaster.new(8, 8)
    local pit_texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png")

    map:setLoweredFloorCell(4, 4, {
        texture = pit_texture,
        depth = 0.3,
        r = 0.1,
        g = 0.4,
        b = 0.8,
        blocked = false,
    })

    local cell = map:getLoweredFloorCell(4, 4)

    print("depth = " .. cell.depth)
    print("blocked = " .. tostring(cell.blocked))
end
```

---

#### `LRaycaster:setWallAlpha`

Sets the transparency for a specific wall tile type, enabling see-through walls.

```lua
LRaycaster:setWallAlpha(tileType, alpha)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tileType` | number | The cell value (1..255) whose alpha to change. |
| `alpha` | number | Opacity (0.0 = fully transparent, 1.0 = fully opaque). |

**Example**

```lua
do
    local map = lurek.raycaster.new(8, 8)
    map:setWallAlpha(2, 0.5)

    print("alpha(2) = " .. map:getWallAlpha(2))
end
```

---

#### `LRaycaster:tryMove`

Attempts to move from (px,py) by (dx,dy) with wall-slide collision. Returns the final position.

```lua
LRaycaster:tryMove(px, py, dx, dy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `px` | number | Current X position in world space. |
| `py` | number | Current Y position in world space. |
| `dx` | number | Desired X movement delta. |
| `dy` | number | Desired Y movement delta. |

**Returns**

| Type | Description |
|------|-------------|
| number | Final X position. |
| number | Final Y position. |
| boolean | Whether any movement occurred. |

**Example**

```lua
do
    local map = lurek.raycaster.new(8, 8)
    for i = 0, 7 do
        map:setCell(i, 0, 1)
        map:setCell(i, 7, 1)
        map:setCell(0, i, 1)
        map:setCell(7, i, 1)
    end

    local nx, ny, moved = map:tryMove(4.5, 4.5, 0.25, 0)
    local wx, wy, blocked = map:tryMove(0.5, 0.5, -1, 0)

    print("free move = " .. tostring(moved) .. " -> " .. nx .. "," .. ny)
    print("wall move = " .. tostring(blocked) .. " -> " .. wx .. "," .. wy)
end
```

---

#### `LRaycaster:type`

Returns the type name of this object ("[LRaycaster](#lraycaster)").

```lua
LRaycaster:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Type name string. |

**Example**

```lua
do
    local map = lurek.raycaster.new(8, 8)
    print("type = " .. map:type())
end
```

---

#### `LRaycaster:typeOf`

Checks whether this object matches the given type name.

```lua
LRaycaster:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to test against. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if this object is of the given type. |

**Example**

```lua
do
    local map = lurek.raycaster.new(8, 8)
    print("LRaycaster = " .. tostring(map:typeOf("LRaycaster")))
    print("LObject = " .. tostring(map:typeOf("LObject")))
end
```

---

#### `LRaycaster:width`

Returns the map width in grid cells.

```lua
LRaycaster:width()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Map width. |

**Example**

```lua
do
    local rc = lurek.raycaster.new(160, 120)

    print("width = " .. rc:width())
    print("height = " .. rc:height())
end
```

---

## LSpriteManager

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LSpriteManager:add`

Adds a new sprite to the manager at a world position with a texture name and optional scale.

```lua
LSpriteManager:add(x, y, texture, scale)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | World X position. |
| `y` | number | World Y position. |
| `texture` | string | Texture asset name. |
| `scale?` | number | Sprite size multiplier (default 1.0). |

**Returns**

| Type | Description |
|------|-------------|
| number | Unique sprite id for later manipulation. |

**Example**

```lua
do
    local sm = lurek.raycaster.newSpriteManager()
    local id = sm:add(5, 5, "content/examples/assets/images/sample_texture.png", 1.0)

    print("sprite id = " .. id)
end
```

---

#### `LSpriteManager:clear`

Removes all sprites from the manager.

```lua
LSpriteManager:clear()
```

**Example**

```lua
do
    local sprites = lurek.raycaster.newSpriteManager()
    sprites:add(1, 1, "content/examples/assets/images/sample_texture.png")
    sprites:add(2, 2, "content/examples/assets/images/sample_texture.png")
    sprites:clear()

    local order = sprites:sortAndProject(0, 0, 0)

    print("projected count = " .. #order)
end
```

---

#### `LSpriteManager:remove`

Removes a sprite by its id. This method is available to Lua scripts.

```lua
LSpriteManager:remove(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Sprite id returned by add(). |

**Example**

```lua
do
    local sm = lurek.raycaster.newSpriteManager()
    local id = sm:add(5, 5, "content/examples/assets/images/sample_texture.png", 1.0)
    sm:remove(id)

    local projected = sm:sortAndProject(0, 0, 0)

    print("remaining projected = " .. #projected)
end
```

---

#### `LSpriteManager:setPosition`

Updates the world position of an existing sprite.

```lua
LSpriteManager:setPosition(id, x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Sprite id. |
| `x` | number | New world X. |
| `y` | number | New world Y. |

**Example**

```lua
do
    local sm = lurek.raycaster.newSpriteManager()
    local id = sm:add(5, 5, "content/examples/assets/images/sample_texture.png", 1.0)
    sm:setPosition(id, 6, 6)

    local projected = sm:sortAndProject(0, 0, 0)

    print("first x = " .. projected[1].x)
    print("first y = " .. projected[1].y)
end
```

---

#### `LSpriteManager:setVisible`

Shows or hides a sprite without removing it.

```lua
LSpriteManager:setVisible(id, visible)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Sprite id. |
| `visible` | boolean | Whether the sprite should be rendered. |

**Example**

```lua
do
    local sm = lurek.raycaster.newSpriteManager()
    local id = sm:add(5, 5, "content/examples/assets/images/sample_texture.png", 1.0)
    sm:setVisible(id, false)

    local projected = sm:sortAndProject(0, 0, 0)

    print("projected count = " .. #projected)
end
```

---

#### `LSpriteManager:sortAndProject`

Sorts all visible sprites by distance from the camera and returns projection data.

```lua
LSpriteManager:sortAndProject(camX, camY, camAngle)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `camX` | number | Camera X position. |
| `camY` | number | Camera Y position. |
| `camAngle` | number | Camera facing angle (unused, reserved). |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array of {id, x, y, texture, scale, distance} sorted back-to-front. |

**Example**

```lua
do
    local sprites = lurek.raycaster.newSpriteManager()
    sprites:add(3, 3, "content/examples/assets/images/sample_texture.png")
    sprites:add(6, 6, "content/examples/assets/images/sample_texture.png")
    sprites:add(9, 9, "content/examples/assets/images/sample_texture.png")

    local order = sprites:sortAndProject(5, 5, 0)

    print("projected count = " .. #order)
    if order[1] then
        print("first id = " .. order[1].id)
        print("first distance = " .. string.format("%.2f", order[1].distance))
    end
end
```

---

#### `LSpriteManager:type`

Returns the type name of this object ("[LSpriteManager](#lspritemanager)").

```lua
LSpriteManager:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Type name string. |

**Example**

```lua
do
    local sprites = lurek.raycaster.newSpriteManager()
    print("type = " .. sprites:type())
end
```

---

#### `LSpriteManager:typeOf`

Checks whether this object matches the given type name.

```lua
LSpriteManager:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to test against. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if this object is of the given type. |

**Example**

```lua
do
    local sprites = lurek.raycaster.newSpriteManager()
    print("LSpriteManager = " .. tostring(sprites:typeOf("LSpriteManager")))
    print("LObject = " .. tostring(sprites:typeOf("LObject")))
end
```

---
