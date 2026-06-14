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
- Last-build diagnostics expose lighting sample counts and cache reuse for scene-build profiling.
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

### `lurek.raycaster.buildMultiLevelScene`

Builds a multilevel raycaster scene from a stack of plain Lua level tables.

```lua
lurek.raycaster.buildMultiLevelScene(params, levels, lights, sprites, wallTextures, models)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `params` | table | Scene params plus optional active_level. |
| `levels` | table|[LMultiLevelGrid](#lmultilevelgrid) | Array of level tables or a persistent [LMultiLevelGrid](#lmultilevelgrid). |
| `lights?` | table | Array of point-light tables or [LPointLight](#lpointlight) userdata values. |
| `sprites?` | table|[LSpriteManager](#lspritemanager) | Array of sprite tables {x, y, texture?, size?, level?, front_texture?, right_texture?, back_texture?, left_texture?, angle?} or an [LSpriteManager](#lspritemanager) whose sprites use their own optional level indices and default to active_level. |
| `wallTextures?` | table | Map of cell_value -> texture for wall surfaces. |
| `models?` | table | Array of model instance tables {model, x, y, level?, rotation?, yaw?, z?, scale?}; instances default to `active_level`. |

**Returns**

| Type | Description |
|------|-------------|
| number | Total number of quads in the built scene. |

**Example**

```lua
do
    local wall_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local floor_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local ceil_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local pit_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
    local quad_count = lurek.raycaster.buildMultiLevelScene(
        {
            px = 0.5,
            py = 1.5,
            angle = 0,
            fov = math.pi / 3,
            rays = 64,
            max_dist = 12,
            screen_w = 320,
            screen_h = 200,
            active_level = 1,
            sun_r = 0.9,
            sun_g = 0.95,
            sun_b = 1.0,
            sun_intensity = 0.8,
            sun_angle = 0.0,
        },
        {
            {
                width = 4,
                height = 4,
                cells = {
                    0, 0, 0, 0,
                    0, 0, 0, 0,
                    0, 0, 0, 0,
                    0, 0, 0, 0,
                },
                floor_offset = 0,
                ceiling_height = 1,
            },
            {
                width = 4,
                height = 4,
                cells = {
                    0, 0, 0, 0,
                    0, 0, 0, 0,
                    0, 0, 0, 0,
                    0, 0, 0, 0,
                },
                floor_offset = 1,
                ceiling_height = 2,
                floor_holes = {
                    false, false, false, false,
                    false, false, false, false,
                    false, false, false, false,
                    false, false, false, false,
                },
                floor_texture = wall_tex,
                floor_cell_textures = {
                    { x = 0, y = 0, texture = floor_tex },
                },
                ceiling_cell_textures = {
                    { x = 0, y = 0, texture = ceil_tex },
                },
                lowered_floor_cells = {
                    {
                        x = 0,
                        y = 0,
                        texture = pit_tex,
                        depth = 0.35,
                        r = 0.8,
                        g = 0.7,
                        b = 0.6,
                        blocked = true,
                    },
                },
                wall_features = {
                    {
                        x = 1,
                        y = 0,
                        kind = "window",
                        sill_height = 0.25,
                        lintel_height = 0.8,
                        alpha = 0.4,
                    },
                },
            },
        },
        {},
        {},
        {},
        {
            { model = model, x = 2.5, y = 1.5, level = 1, yaw = math.pi / 6, z = 0.2, scale = 0.22 },
        }
    )

    print("stacked quad count = " .. quad_count)
end
```

---

### `lurek.raycaster.buildMultiLevelSceneFromAdapter`

Builds a multilevel raycaster scene from a stack of plain Lua level tables using a runtime scene adapter.

```lua
lurek.raycaster.buildMultiLevelSceneFromAdapter(params, levels, adapter, wallTextures)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `params` | table | Scene params plus optional active_level. |
| `levels` | table|[LMultiLevelGrid](#lmultilevelgrid) | Array of level tables or a persistent [LMultiLevelGrid](#lmultilevelgrid). |
| `adapter` | [LSceneAdapter](#lsceneadapter) | Runtime scene adapter providing lights, sprites, and models. |
| `wallTextures?` | table | Map of cell_value -> texture for wall surfaces. |

**Returns**

| Type | Description |
|------|-------------|
| number | Total number of quads in the built scene. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(2.5, 1.5, "dynamic")
    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:bindBodySprite(
        body,
        lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        { id = 21, level = 1, size = 1.0 }
    )
    adapter:bindBodyLight(body, 4.0, {
        level = 1,
        intensity = 1.0,
        color = { 1.0, 0.85, 0.6 },
    })
    local quad_count = lurek.raycaster.buildMultiLevelSceneFromAdapter(
        {
            px = 0.5,
            py = 1.5,
            angle = 0,
            fov = math.pi / 3,
            rays = 64,
            max_dist = 12,
            screen_w = 320,
            screen_h = 200,
            active_level = 1,
        },
        {
            {
                width = 4,
                height = 4,
                cells = {
                    0, 0, 0, 0,
                    0, 0, 0, 0,
                    0, 0, 0, 0,
                    0, 0, 0, 0,
                },
                floor_offset = 0,
                ceiling_height = 1,
            },
            {
                width = 4,
                height = 4,
                cells = {
                    0, 0, 0, 0,
                    0, 0, 0, 0,
                    0, 0, 0, 0,
                    0, 0, 0, 0,
                },
                floor_offset = 1,
                ceiling_height = 2,
            },
        },
        adapter,
        {}
    )

    print("stacked adapter quad count = " .. quad_count)
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

### `lurek.raycaster.getLastBuildStats`

Returns stats for the last stored raycaster scene build.

```lua
lurek.raycaster.getLastBuildStats()
```

**Returns**

| Type | Description |
|------|-------------|
| table? | Nil if no raycaster scene has been built yet; otherwise a stats table. |

**Example**

```lua
do
    local map = lurek.raycaster.new(8, 8)
    local wall_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    for i = 0, 7 do
        map:setCell(i, 0, 1)
        map:setCell(i, 7, 1)
        map:setCell(0, i, 1)
        map:setCell(7, i, 1)
    end
    for y = 1, 6 do
        for x = 1, 6 do
            map:setCeilingTextureCell(x, y, wall_tex)
        end
    end

    map:buildScene({
        px = 4,
        py = 4,
        angle = 0,
        fov = math.pi / 3,
        rays = 64,
        max_dist = 10,
        screen_w = 320,
        screen_h = 200,
    }, {
        lurek.raycaster.newPointLight(4.0, 4.0, 1.0, 0.9, 0.8, 4.0, 1.25),
    }, {}, {
        [1] = wall_tex,
    })

    local stats = lurek.raycaster.getLastBuildStats()
    if stats then
        print("lighting samples = " .. stats.lightingSamples)
        print("lighting cache hits = " .. stats.lightingCacheHits)
        print("lighting cache misses = " .. stats.lightingCacheMisses)
    end
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

### `lurek.raycaster.newMultiLevelGrid`

Creates a persistent multi-level raycaster world from plain Lua level tables or as an empty container.

```lua
lurek.raycaster.newMultiLevelGrid(levels)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `levels?` | table|[LMultiLevelGrid](#lmultilevelgrid) | Optional array of level tables or another [LMultiLevelGrid](#lmultilevelgrid) to clone. |

**Returns**

| Type | Description |
|------|-------------|
| [LMultiLevelGrid](#lmultilevelgrid) | Persistent multi-level world handle. |

**Example**

```lua
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        {
            width = 2,
            height = 2,
            cells = { 0, 0, 0, 0 },
        },
    })
    print("persistent grid levels = " .. grid:levelCount())
end
```

---

### `lurek.raycaster.newPointLight`

Creates a new point light with position, color, radius, and intensity.

```lua
lurek.raycaster.newPointLight(x, y, r, g, b, radius, intensity, level)
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
| `level?` | number | Optional multilevel slice index that owns this light. |

**Returns**

| Type | Description |
|------|-------------|
| [LPointLight](#lpointlight) | A new point light instance. |

**Example**

```lua
do
    local torch = lurek.raycaster.newPointLight(5.5, 3.5, 1.0, 0.8, 0.4, 4.0, 1.5, 1)
    local r, g, b = torch:color()

    print("pos = " .. torch:x() .. "," .. torch:y())
    print("color = " .. r .. "," .. g .. "," .. b)
    print("radius = " .. torch:radius() .. " intensity = " .. torch:intensity())
    print("level = " .. tostring(torch:level()))
end
```

---

### `lurek.raycaster.newSceneAdapter`

Creates a runtime adapter for sprites, lights, and models that can follow physics bodies.

```lua
lurek.raycaster.newSceneAdapter()
```

**Returns**

| Type | Description |
|------|-------------|
| [LSceneAdapter](#lsceneadapter) | A new empty scene adapter. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(5.0, 4.0, "dynamic")
    body:setAngle(math.pi / 2)

    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:bindBodySprite(
        body,
        lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        { id = 7, size = 1.3, level = 1, offset_x = 0.5 }
    )
    adapter:bindBodyLight(body, 4.0, {
        intensity = 1.2,
        color = { 1.0, 0.85, 0.5 },
        level = 1,
        offset_y = 0.4,
    })
    adapter:bindBodyModel(
        body,
        lurek.render.loadModel("content/examples/assets/models/sample_tank.obj"),
        { id = 8, level = 1, yaw_offset = 0.2, z = 0.15, scale = 0.22 }
    )

    body:setPosition(6.0, 4.5)
    local inputs = adapter:sceneInputs()
    local demo_map = lurek.raycaster.new(16, 16)
    for i = 0, 15 do
        demo_map:setCell(i, 0, 1)
        demo_map:setCell(i, 15, 1)
        demo_map:setCell(0, i, 1)
        demo_map:setCell(15, i, 1)
    end
    local params = {
        px = 4.5,
        py = 4.5,
        angle = 0.0,
        fov = math.pi / 3,
        rays = 32,
        max_dist = 16.0,
        screen_w = 160,
        screen_h = 100,
    }
    local quad_count = demo_map:buildSceneFromAdapter(params, adapter, {})
    local pick = demo_map:pickScreenFromAdapter(80, 50, params, adapter)
    print("scene adapter sprites = " .. #inputs.sprites)
    print("scene adapter lights = " .. #inputs.lights)
    print("scene adapter models = " .. #inputs.models)
    print("sprite pos = " .. string.format("%.2f,%.2f", inputs.sprites[1].x, inputs.sprites[1].y))
    print("adapter buildScene quads = " .. quad_count)
    print("adapter pick = " .. tostring(pick and pick.surface or "nil"))
    if pick then
        print("adapter pick hit = " .. string.format("%.2f,%.2f", pick.hit_x, pick.hit_y))
        print("adapter pick angle = " .. tostring(pick.ray_angle))
    end
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
    local torch = sprites:add(8.5, 2.5, "content/examples/assets/images/sample_texture.png", 0.5, 1)
    local enemy = sprites:add(10.5, 7.5, "content/examples/assets/images/sample_texture.png", 1.2)

    sprites:setPosition(enemy, 11, 8)
    sprites:setVisible(torch, false)
    sprites:remove(barrel)

    print("torch id = " .. torch)
    print("enemy id = " .. enemy)
end
```

---

### `lurek.raycaster.pickScreenMultiLevel`

Resolves a screen-space click against a stack of plain Lua level tables and returns the owning level.

```lua
lurek.raycaster.pickScreenMultiLevel(sx, sy, params, levels, wallTextures, sprites, models)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sx` | number | Screen X in pixels. |
| `sy` | number | Screen Y in pixels. |
| `params` | table | Camera params plus optional active_level. |
| `levels` | table|[LMultiLevelGrid](#lmultilevelgrid) | Array of level tables or a persistent [LMultiLevelGrid](#lmultilevelgrid). |
| `wallTextures?` | table | Optional map of cell_value -> texture for wall surfaces. |
| `sprites?` | table|[LSpriteManager](#lspritemanager) | Optional sprite tables or sprite manager used to resolve clickable billboard hits. |
| `models?` | table | Optional model instance tables used to resolve clickable projected model hits. |

**Returns**

| Type | Description |
|------|-------------|
| table | Pick result {x, y, level, surface, distance, hit_x, hit_y, u, v, cell_value?, side?, texture?, ray_angle, id?, wall_height?, feature?} or nil. `feature` mirrors the owning wall-feature descriptor and adds `section` for the solid band/panel that was hit. |

**Example**

```lua
do
    local wall_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local hit = lurek.raycaster.pickScreenMultiLevel(
        160,
        190,
        {
            px = 1.5,
            py = 1.5,
            angle = 0,
            fov = math.pi / 3,
            rays = 64,
            max_dist = 12,
            screen_w = 320,
            screen_h = 200,
            active_level = 1,
            camera_height = 0.5,
        },
        {
            {
                width = 8,
                height = 8,
                cells = {
                    0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0,
                },
                floor_offset = 0,
                ceiling_height = 1,
                ceiling_holes = {
                    false, false, false, false, false, false, false, false,
                    false, false, false, true, false, false, false, false,
                    false, false, false, false, false, false, false, false,
                    false, false, false, false, false, false, false, false,
                    false, false, false, false, false, false, false, false,
                    false, false, false, false, false, false, false, false,
                    false, false, false, false, false, false, false, false,
                    false, false, false, false, false, false, false, false,
                },
            },
            {
                width = 8,
                height = 8,
                cells = {
                    0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0,
                },
                floor_offset = 1,
                ceiling_height = 2,
                floor_holes = {
                    false, false, false, false, false, false, false, false,
                    false, false, false, true, false, false, false, false,
                    false, false, false, false, false, false, false, false,
                    false, false, false, false, false, false, false, false,
                    false, false, false, false, false, false, false, false,
                    false, false, false, false, false, false, false, false,
                    false, false, false, false, false, false, false, false,
                    false, false, false, false, false, false, false, false,
                },
                floor_texture = wall_tex,
            },
        },
        {}
    )

    if hit then
        print("stacked pick level = " .. hit.level)
        print("stacked pick surface = " .. hit.surface)
        print("stacked pick cell = " .. hit.x .. "," .. hit.y)
    end
end
```

---

### `lurek.raycaster.pickScreenMultiLevelFromAdapter`

Resolves a screen-space click against a stack of plain Lua level tables using a runtime scene adapter.

```lua
lurek.raycaster.pickScreenMultiLevelFromAdapter(sx, sy, params, levels, wallTextures, adapter)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sx` | number | Screen X in pixels. |
| `sy` | number | Screen Y in pixels. |
| `params` | table | Camera params plus optional active_level. |
| `levels` | table|[LMultiLevelGrid](#lmultilevelgrid) | Array of level tables or a persistent [LMultiLevelGrid](#lmultilevelgrid). |
| `wallTextures?` | table | Optional map of cell_value -> texture for wall surfaces. |
| `adapter` | [LSceneAdapter](#lsceneadapter) | Runtime scene adapter providing sprites and models. |

**Returns**

| Type | Description |
|------|-------------|
| table | Pick result {x, y, level, surface, distance, hit_x, hit_y, u, v, cell_value?, side?, texture?, ray_angle, id?, wall_height?, feature?} or nil. `feature` mirrors the owning wall-feature descriptor and adds `section` for the solid band/panel that was hit. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(2.5, 1.5, "dynamic")
    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:bindBodySprite(
        body,
        lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        { id = 22, level = 1, size = 1.0 }
    )
    local hit = lurek.raycaster.pickScreenMultiLevelFromAdapter(
        160,
        100,
        {
            px = 0.5,
            py = 1.5,
            angle = 0,
            fov = math.pi / 3,
            rays = 64,
            max_dist = 12,
            screen_w = 320,
            screen_h = 200,
            active_level = 1,
        },
        {
            {
                width = 4,
                height = 4,
                cells = {
                    0, 0, 0, 0,
                    0, 0, 0, 0,
                    0, 0, 0, 0,
                    0, 0, 0, 0,
                },
                floor_offset = 0,
                ceiling_height = 1,
            },
            {
                width = 4,
                height = 4,
                cells = {
                    0, 0, 0, 0,
                    0, 0, 0, 0,
                    0, 0, 0, 0,
                    0, 0, 0, 0,
                },
                floor_offset = 1,
                ceiling_height = 2,
            },
        },
        {},
        adapter
    )

    if hit then
        print("adapter stacked pick = " .. hit.surface .. " @ level " .. hit.level)
    end
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
- [LMultiLevelGrid](#lmultilevelgrid)
- [LPointLight](#lpointlight)
- [LRaycaster](#lraycaster)
- [LSceneAdapter](#lsceneadapter)
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

## LMultiLevelGrid

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LMultiLevelGrid:activeLevel`

Returns the currently active level index used for stacked camera height.

```lua
LMultiLevelGrid:activeLevel()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Active level index. |

**Example**

```lua
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        { width = 2, height = 2, cells = { 0, 0, 0, 0 }, floor_offset = 1, ceiling_height = 2 },
    })
    grid:setActiveLevel(1)
    print("active level = " .. grid:activeLevel())
end
```

---

#### `LMultiLevelGrid:addLevel`

Appends one level described with the same table format accepted by buildMultiLevelScene.

```lua
LMultiLevelGrid:addLevel(level)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `level` | table | Level table {width, height, cells, floor_offset?, ceiling_height?, floor_holes?, ceiling_holes?, floor_texture?, ceiling_texture?, floor_cell_textures?, ceiling_cell_textures?, lowered_floor_cells?, wall_features?}. |

**Returns**

| Type | Description |
|------|-------------|
| number | Zero-based level index of the appended level. |

**Example**

```lua
do
    local grid = lurek.raycaster.newMultiLevelGrid()
    local index = grid:addLevel({
        width = 2,
        height = 2,
        cells = { 0, 0, 0, 0 },
    })
    print("added level = " .. index)
end
```

---

#### `LMultiLevelGrid:buildScene`

Builds a textured multilevel raycaster scene from this persistent world and stores it for rendering.

```lua
LMultiLevelGrid:buildScene(params, lights, sprites, wallTextures)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `params` | table | Scene params for the current camera. |
| `lights?` | table | Array of point-light tables or [LPointLight](#lpointlight) userdata values. |
| `sprites?` | table|[LSpriteManager](#lspritemanager) | Array of level sprite tables or an [LSpriteManager](#lspritemanager). |
| `wallTextures?` | table | Map of cell_value -> texture for wall surfaces. |

**Returns**

| Type | Description |
|------|-------------|
| number | Total number of quads in the built scene. |

**Example**

```lua
do
    local wall_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        {
            width = 2,
            height = 2,
            cells = { 0, 1, 0, 0 },
            floor_offset = 1,
            ceiling_height = 2,
            floor_texture = wall_tex,
        },
    })
    grid:setActiveLevel(1)
    local count = grid:buildScene(
        {
            px = 0.5,
            py = 0.5,
            angle = 0,
            fov = math.pi / 3,
            rays = 64,
            max_dist = 12,
            screen_w = 320,
            screen_h = 200,
            camera_height = 0.5,
        },
        {},
        {},
        { [1] = wall_tex }
    )
    print("persistent scene quads = " .. count)
end
```

---

#### `LMultiLevelGrid:buildSceneFromAdapter`

Builds a textured multilevel raycaster scene from a runtime scene adapter that may follow physics bodies.

```lua
LMultiLevelGrid:buildSceneFromAdapter(params, adapter, wallTextures)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `params` | table | Scene params for the current camera. |
| `adapter` | [LSceneAdapter](#lsceneadapter) | Runtime scene adapter providing lights, sprites, and models. |
| `wallTextures?` | table | Map of cell_value -> texture for wall surfaces. |

**Returns**

| Type | Description |
|------|-------------|
| number | Total number of quads in the built scene. |

**Example**

```lua
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        {
            width = 4,
            height = 4,
            cells = {
                0, 0, 0, 0,
                0, 0, 0, 0,
                0, 0, 0, 0,
                0, 0, 0, 0,
            },
            floor_offset = 0,
            ceiling_height = 1,
        },
        {
            width = 4,
            height = 4,
            cells = {
                0, 0, 0, 0,
                0, 0, 0, 0,
                0, 0, 0, 0,
                0, 0, 0, 0,
            },
            floor_offset = 1,
            ceiling_height = 2,
        },
    })
    grid:setActiveLevel(1)

    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(2.5, 1.5, "dynamic")
    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:bindBodySprite(
        body,
        lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        { id = 35, level = 1, size = 1.0 }
    )
    local quad_count = grid:buildSceneFromAdapter({
        px = 0.5,
        py = 1.5,
        angle = 0,
        fov = math.pi / 3,
        rays = 32,
        max_dist = 8,
        screen_w = 160,
        screen_h = 100,
        active_level = 1,
    }, adapter, {})
    print("persistent adapter quads = " .. quad_count)
end
```

---

#### `LMultiLevelGrid:clearWallFeatureCell`

Removes any per-cell wall feature override from the active level.

```lua
LMultiLevelGrid:clearWallFeatureCell(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Grid column. |
| `y` | number | Grid row. |

**Example**

```lua
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 1, 0, 0, 0 } },
    })
    grid:setWindowCell(0, 0, 0.25, 0.8, 0.4)
    grid:clearWallFeatureCell(0, 0)
    print("feature cleared = " .. tostring(grid:getWallFeatureCell(0, 0) == nil))
end
```

---

#### `LMultiLevelGrid:getCeilingHeight`

Returns the ceiling height of the active level in world units.

```lua
LMultiLevelGrid:getCeilingHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Active-level ceiling height. |

**Example**

```lua
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 }, floor_offset = 0.5, ceiling_height = 2.25 },
    })
    print("ceiling height = " .. grid:getCeilingHeight())
end
```

---

#### `LMultiLevelGrid:getCeilingTexture`

Returns the default ceiling texture id used by the active level, or nil when none is set.

```lua
LMultiLevelGrid:getCeilingTexture()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Raw texture id or nil. |

**Example**

```lua
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    grid:setCeilingTexture(lurek.render.newImage("content/examples/assets/images/sample_texture.png"))
    print("ceiling texture id = " .. tostring(grid:getCeilingTexture()))
end
```

---

#### `LMultiLevelGrid:getCeilingTextureCell`

Returns the per-cell ceiling texture id assigned on the active level, or nil if none is set.

```lua
LMultiLevelGrid:getCeilingTextureCell(x, y)
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
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    grid:setCeilingTextureCell(0, 0, lurek.render.newImage("content/examples/assets/images/sample_texture.png"))
    print("ceiling(0,0) texture id = " .. tostring(grid:getCeilingTextureCell(0, 0)))
end
```

---

#### `LMultiLevelGrid:getCell`

Returns the wall type value at a grid cell on the active level.

```lua
LMultiLevelGrid:getCell(x, y)
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
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        { width = 2, height = 2, cells = { 0, 5, 0, 0 } },
    })
    grid:setActiveLevel(1)
    print("active cell = " .. grid:getCell(1, 0))
end
```

---

#### `LMultiLevelGrid:getFloorOffset`

Returns the floor height offset of the active level in world units.

```lua
LMultiLevelGrid:getFloorOffset()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Active-level floor offset. |

**Example**

```lua
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        { width = 2, height = 2, cells = { 0, 0, 0, 0 }, floor_offset = 1.25, ceiling_height = 2.5 },
    })
    grid:setActiveLevel(1)
    print("floor offset = " .. grid:getFloorOffset())
end
```

---

#### `LMultiLevelGrid:getFloorTexture`

Returns the default floor texture id used by the active level, or nil when none is set.

```lua
LMultiLevelGrid:getFloorTexture()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Raw texture id or nil. |

**Example**

```lua
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    grid:setFloorTexture(lurek.render.newImage("content/examples/assets/images/sample_texture.png"))
    print("floor texture id = " .. tostring(grid:getFloorTexture()))
end
```

---

#### `LMultiLevelGrid:getFloorTextureCell`

Returns the per-cell floor texture id assigned on the active level, or nil if none is set.

```lua
LMultiLevelGrid:getFloorTextureCell(x, y)
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
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    grid:setFloorTextureCell(1, 0, lurek.render.newImage("content/examples/assets/images/sample_texture.png"))
    print("floor(1,0) texture id = " .. tostring(grid:getFloorTextureCell(1, 0)))
end
```

---

#### `LMultiLevelGrid:getLoweredFloorCell`

Returns the lowered-floor configuration at an active-level cell, or nil if the cell is normal.

```lua
LMultiLevelGrid:getLoweredFloorCell(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Grid column. |
| `y` | number | Grid row. |

**Returns**

| Type | Description |
|------|-------------|
| table | Table {texture, depth, r, g, b, blocked} or nil. |

**Example**

```lua
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 4, height = 4, cells = {
            0, 0, 0, 0,
            0, 0, 0, 0,
            0, 0, 0, 0,
            0, 0, 0, 0,
        } },
    })
    grid:setLoweredFloorCell(1, 1, {
        texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        depth = 0.25,
        blocked = true,
    })
    local pit = grid:getLoweredFloorCell(1, 1)
    print("pit blocked = " .. tostring(pit.blocked))
end
```

---

#### `LMultiLevelGrid:getWallFeatureCell`

Returns the wall feature attached to an active-level cell, or nil when none is set.

```lua
LMultiLevelGrid:getWallFeatureCell(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Grid column. |
| `y` | number | Grid row. |

**Returns**

| Type | Description |
|------|-------------|
| LMultiLevelGridGetWallFeatureCellResult | Feature table {kind, alpha, ...} or nil. |

**Example**

```lua
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 1, 0, 0, 0 } },
    })
    print("feature absent = " .. tostring(grid:getWallFeatureCell(1, 1) == nil))
end
```

---

#### `LMultiLevelGrid:isCeilingHole`

Returns true when an active-level cell is open to the level above.

```lua
LMultiLevelGrid:isCeilingHole(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Grid column. |
| `y` | number | Grid row. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the ceiling is open at this cell. |

**Example**

```lua
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        { width = 2, height = 2, cells = { 0, 0, 0, 0 }, ceiling_holes = { false, false, false, true } },
    })
    grid:setActiveLevel(1)
    print("imported ceiling hole = " .. tostring(grid:isCeilingHole(1, 1)))
end
```

---

#### `LMultiLevelGrid:isFloorHole`

Returns true when an active-level cell is open to the level below.

```lua
LMultiLevelGrid:isFloorHole(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Grid column. |
| `y` | number | Grid row. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the floor is open at this cell. |

**Example**

```lua
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        { width = 2, height = 2, cells = { 0, 0, 0, 0 }, floor_holes = { false, true, false, false } },
    })
    grid:setActiveLevel(1)
    print("imported floor hole = " .. tostring(grid:isFloorHole(1, 0)))
end
```

---

#### `LMultiLevelGrid:levelCount`

Returns the total number of stored levels.

```lua
LMultiLevelGrid:levelCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Level count. |

**Example**

```lua
do
    local grid = lurek.raycaster.newMultiLevelGrid()
    grid:addLevel({
        width = 2,
        height = 2,
        cells = { 0, 0, 0, 0 },
    })
    print("level count = " .. grid:levelCount())
end
```

---

#### `LMultiLevelGrid:pickScreen`

Resolves a screen-space click against this persistent multi-level world and returns the owning level.

```lua
LMultiLevelGrid:pickScreen(sx, sy, params, wallTextures, sprites, models)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sx` | number | Screen X in pixels. |
| `sy` | number | Screen Y in pixels. |
| `params` | table | Camera params for the current frame. |
| `wallTextures?` | table | Optional map of cell_value -> texture for wall surfaces. |
| `sprites?` | table|[LSpriteManager](#lspritemanager) | Optional sprite tables or sprite manager used to resolve clickable billboard hits. |
| `models?` | table | Optional model instance tables used to resolve clickable projected model hits. |

**Returns**

| Type | Description |
|------|-------------|
| LMultiLevelGridPickScreenResult | Pick result {x, y, level, surface, distance, hit_x, hit_y, u, v, cell_value?, side?, texture?, ray_angle, id?, wall_height?, feature?} or nil. `feature` mirrors `getWallFeatureCell()` and adds `section` for the solid band/panel that was hit. |

**Example**

```lua
do
    local wall_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local grid = lurek.raycaster.newMultiLevelGrid({
        {
            width = 8,
            height = 8,
            cells = {
                0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0,
            },
        },
        {
            width = 8,
            height = 8,
            cells = {
                0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 1, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0,
            },
            floor_offset = 1,
            ceiling_height = 2,
        },
    })
    grid:setActiveLevel(1)
    local hit = grid:pickScreen(
        160,
        100,
        {
            px = 1.5,
            py = 2.5,
            angle = 0,
            fov = math.pi / 3,
            rays = 64,
            max_dist = 12,
            screen_w = 320,
            screen_h = 200,
            camera_height = 0.5,
        },
        { [1] = wall_tex }
    )
    if hit then
        print("persistent pick = " .. hit.surface .. " @ level " .. hit.level)
    end
end
```

---

#### `LMultiLevelGrid:pickScreenFromAdapter`

Resolves a screen-space click against this multilevel world using a runtime scene adapter.

```lua
LMultiLevelGrid:pickScreenFromAdapter(sx, sy, params, wallTextures, adapter)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sx` | number | Screen X in pixels. |
| `sy` | number | Screen Y in pixels. |
| `params` | table | Camera params for the current frame. |
| `wallTextures?` | table | Optional map of cell_value -> texture for wall surfaces. |
| `adapter` | [LSceneAdapter](#lsceneadapter) | Runtime scene adapter providing sprites and models. |

**Returns**

| Type | Description |
|------|-------------|
| table | Pick result or nil when nothing was hit. Wall hits may also include `wall_height` plus `feature = {kind, section, ...}` for half walls, windows, and doors. |

**Example**

```lua
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        {
            width = 4,
            height = 4,
            cells = {
                0, 0, 0, 0,
                0, 0, 0, 0,
                0, 0, 0, 0,
                0, 0, 0, 0,
            },
            floor_offset = 0,
            ceiling_height = 1,
        },
        {
            width = 4,
            height = 4,
            cells = {
                0, 0, 0, 0,
                0, 0, 0, 0,
                0, 0, 0, 0,
                0, 0, 0, 0,
            },
            floor_offset = 1,
            ceiling_height = 2,
        },
    })
    grid:setActiveLevel(1)

    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(2.5, 1.5, "dynamic")
    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:bindBodySprite(
        body,
        lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        { id = 35, level = 1, size = 1.0 }
    )
    adapter:bindBodyLight(body, 4.0, {
        level = 1,
        intensity = 1.0,
        color = { 1.0, 0.8, 0.6 },
    })

    local params = {
        px = 0.5,
        py = 1.5,
        angle = 0,
        fov = math.pi / 3,
        rays = 32,
        max_dist = 8,
        screen_w = 160,
        screen_h = 100,
        active_level = 1,
    }
    local hit = grid:pickScreenFromAdapter(80, 50, params, {}, adapter)
    if hit then
        print("persistent adapter hit = " .. hit.surface .. " #" .. tostring(hit.id))
        print("persistent adapter hit point = " .. string.format("%.2f,%.2f", hit.hit_x, hit.hit_y))
    end
end
```

---

#### `LMultiLevelGrid:setActiveLevel`

Sets the currently active level index used for stacked camera height.

```lua
LMultiLevelGrid:setActiveLevel(level)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `level` | number | Zero-based active level index. |

**Example**

```lua
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        { width = 2, height = 2, cells = { 0, 0, 0, 0 }, floor_offset = 1, ceiling_height = 2 },
    })
    grid:setActiveLevel(1)
    print("active after set = " .. grid:activeLevel())
end
```

---

#### `LMultiLevelGrid:setCeilingHeight`

Sets the ceiling height of the active level in world units.

```lua
LMultiLevelGrid:setCeilingHeight(height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `height` | number | New ceiling height in world units. |

**Example**

```lua
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 }, floor_offset = 0.5, ceiling_height = 1.5 },
    })
    grid:setCeilingHeight(0.55)
    print("clamped ceiling height = " .. grid:getCeilingHeight())
end
```

---

#### `LMultiLevelGrid:setCeilingHole`

Sets whether an active-level cell is open to the level above.

```lua
LMultiLevelGrid:setCeilingHole(x, y, hole)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Grid column. |
| `y` | number | Grid row. |
| `hole` | boolean | True when the ceiling should be open at this cell. |

**Example**

```lua
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    grid:setActiveLevel(1)
    grid:setCeilingHole(1, 1, true)
    print("ceiling hole after set = " .. tostring(grid:isCeilingHole(1, 1)))
end
```

---

#### `LMultiLevelGrid:setCeilingTexture`

Sets the default ceiling texture used by the active level. Pass nil to clear it.

```lua
LMultiLevelGrid:setCeilingTexture(texture)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `texture?` | [LImage](render.md#limage) | Texture image, integer id, or nil to clear. |

**Example**

```lua
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    local ceil_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    grid:setCeilingTexture(ceil_tex)
    print("default ceiling texture = " .. tostring(grid:getCeilingTexture()))
    grid:setCeilingTexture(nil)
    print("default ceiling cleared = " .. tostring(grid:getCeilingTexture() == nil))
end
```

---

#### `LMultiLevelGrid:setCeilingTextureCell`

Assigns a per-cell ceiling texture override on the active level. Pass nil to remove the override.

```lua
LMultiLevelGrid:setCeilingTextureCell(x, y, texture)
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
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    grid:setCeilingTextureCell(0, 1, lurek.render.newImage("content/examples/assets/images/sample_texture.png"))
    print("ceiling cell texture = " .. tostring(grid:getCeilingTextureCell(0, 1)))
    grid:setCeilingTextureCell(0, 1, nil)
    print("ceiling cell cleared = " .. tostring(grid:getCeilingTextureCell(0, 1) == nil))
end
```

---

#### `LMultiLevelGrid:setCell`

Sets the wall type value at a grid cell on the active level. Non-zero values are solid walls.

```lua
LMultiLevelGrid:setCell(x, y, val)
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
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    grid:setActiveLevel(1)
    grid:setCell(1, 0, 7)
    print("active cell after set = " .. grid:getCell(1, 0))
end
```

---

#### `LMultiLevelGrid:setDoorCell`

Attaches a sliding door feature to a blocking cell on the active level.

```lua
LMultiLevelGrid:setDoorCell(x, y, direction, openAmount, alpha)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Grid column. |
| `y` | number | Grid row. |
| `direction` | string | "horizontal" or "vertical". |
| `openAmount` | number | Door open amount, 0.0..1.0. |
| `alpha?` | number | Optional alpha multiplier. |

**Example**

```lua
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 1, 0, 0, 0 } },
    })
    grid:setDoorCell(0, 0, "vertical", 0.6, 0.9)
    print("door open amount = " .. grid:getWallFeatureCell(0, 0).open_amount)
end
```

---

#### `LMultiLevelGrid:setFloorHole`

Sets whether an active-level cell is open to the level below.

```lua
LMultiLevelGrid:setFloorHole(x, y, hole)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Grid column. |
| `y` | number | Grid row. |
| `hole` | boolean | True when the floor should be open at this cell. |

**Example**

```lua
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    grid:setActiveLevel(1)
    grid:setFloorHole(1, 0, true)
    print("floor hole after set = " .. tostring(grid:isFloorHole(1, 0)))
end
```

---

#### `LMultiLevelGrid:setFloorOffset`

Sets the floor height offset of the active level in world units.

```lua
LMultiLevelGrid:setFloorOffset(offset)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `offset` | number | New floor offset in world units. |

**Example**

```lua
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 }, floor_offset = 0, ceiling_height = 1 },
    })
    grid:setFloorOffset(0.75)
    print("updated floor offset = " .. grid:getFloorOffset())
end
```

---

#### `LMultiLevelGrid:setFloorTexture`

Sets the default floor texture used by the active level. Pass nil to clear it.

```lua
LMultiLevelGrid:setFloorTexture(texture)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `texture?` | [LImage](render.md#limage) | Texture image, integer id, or nil to clear. |

**Example**

```lua
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    local floor_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    grid:setFloorTexture(floor_tex)
    print("default floor texture = " .. tostring(grid:getFloorTexture()))
    grid:setFloorTexture(nil)
    print("default floor cleared = " .. tostring(grid:getFloorTexture() == nil))
end
```

---

#### `LMultiLevelGrid:setFloorTextureCell`

Assigns a per-cell floor texture override on the active level. Pass nil to remove the override.

```lua
LMultiLevelGrid:setFloorTextureCell(x, y, texture)
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
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    grid:setFloorTextureCell(1, 1, lurek.render.newImage("content/examples/assets/images/sample_texture.png"))
    print("floor cell texture = " .. tostring(grid:getFloorTextureCell(1, 1)))
    grid:setFloorTextureCell(1, 1, nil)
    print("floor cell cleared = " .. tostring(grid:getFloorTextureCell(1, 1) == nil))
end
```

---

#### `LMultiLevelGrid:setHalfWallCell`

Attaches a half-height wall feature to a blocking cell on the active level.

```lua
LMultiLevelGrid:setHalfWallCell(x, y, height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Grid column. |
| `y` | number | Grid row. |
| `height` | number | Solid wall height from floor, 0.0..1.0. |

**Example**

```lua
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 1, 0, 0, 0 } },
    })
    grid:setHalfWallCell(0, 0, 0.5)
    print("half feature kind = " .. grid:getWallFeatureCell(0, 0).kind)
end
```

---

#### `LMultiLevelGrid:setLoweredFloorCell`

Marks an active-level cell as a lowered floor (pit) with its own texture, depth, tint, and blocking flag.

```lua
LMultiLevelGrid:setLoweredFloorCell(x, y, opts)
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
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 4, height = 4, cells = {
            0, 0, 0, 0,
            0, 0, 0, 0,
            0, 0, 0, 0,
            0, 0, 0, 0,
        } },
    })
    grid:setLoweredFloorCell(2, 2, {
        texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        depth = 0.3,
        r = 0.8,
        g = 0.7,
        b = 0.6,
        blocked = false,
    })
    local pit = grid:getLoweredFloorCell(2, 2)
    print("pit depth = " .. pit.depth)
    grid:setLoweredFloorCell(2, 2, nil)
    print("pit cleared = " .. tostring(grid:getLoweredFloorCell(2, 2) == nil))
end
```

---

#### `LMultiLevelGrid:setWindowCell`

Attaches a window feature to a blocking cell on the active level, leaving a visible opening between sill and lintel.

```lua
LMultiLevelGrid:setWindowCell(x, y, sillHeight, lintelHeight, alpha)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Grid column. |
| `y` | number | Grid row. |
| `sillHeight` | number | Bottom of the opening from the floor, 0.0..1.0. |
| `lintelHeight` | number | Top of the opening from the floor, 0.0..1.0. |
| `alpha?` | number | Wall alpha multiplier for the solid bands. |

**Example**

```lua
do
    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 1, 0, 0, 0 } },
    })
    grid:setWindowCell(0, 0, 0.25, 0.8, 0.4)
    print("window sill = " .. grid:getWallFeatureCell(0, 0).sill_height)
end
```

---

#### `LMultiLevelGrid:type`

Returns the type name of this object ("[LMultiLevelGrid](#lmultilevelgrid)").

```lua
LMultiLevelGrid:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Type name string. |

**Example**

```lua
do
    local grid = lurek.raycaster.newMultiLevelGrid()
    print("persistent type = " .. grid:type())
end
```

---

#### `LMultiLevelGrid:typeOf`

Checks whether this object matches the given type name.

```lua
LMultiLevelGrid:typeOf(name)
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
    local grid = lurek.raycaster.newMultiLevelGrid()
    print("persistent typeOf = " .. tostring(grid:typeOf("LMultiLevelGrid")))
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

#### `LPointLight:level`

Returns the optional multilevel slice index that owns this light.

```lua
LPointLight:level()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Level index, or nil when this light is global across levels. |

**Example**

```lua
do
    local light = lurek.raycaster.newPointLight(1, 1, 1, 1, 1, 2, 0.5, 3)
    print("light level = " .. tostring(light:level()))
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
LPointLight:set(x, y, r, g, b, radius, intensity, level)
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
| `level?` | number | Optional multilevel slice index that owns this light. |

**Example**

```lua
do
    local light = lurek.raycaster.newPointLight(2, 2, 1, 1, 1, 3, 1.0)
    light:set(8, 8, 0, 0, 1, 6, 2.0, 2)
    local r, g, b = light:color()

    print("pos = " .. light:x() .. "," .. light:y())
    print("color = " .. r .. "," .. g .. "," .. b)
    print("radius = " .. light:radius() .. " intensity = " .. light:intensity())
    print("level = " .. tostring(light:level()))
end
```

---

#### `LPointLight:setLevel`

Updates the optional multilevel slice index that owns this light.

```lua
LPointLight:setLevel(level)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `level?` | number | Level index, or nil to let this light affect every level. |

**Example**

```lua
do
    local light = lurek.raycaster.newPointLight(1, 1, 1, 1, 1, 2, 0.5)
    light:setLevel(1)
    print("light level after set = " .. tostring(light:level()))
    light:setLevel(nil)
    print("light level after clear = " .. tostring(light:level()))
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

#### `LRaycaster:applyDoorManager`

Synchronizes animated doors from an `[LDoorManager](#ldoormanager)` into this map's per-cell wall features.

```lua
LRaycaster:applyDoorManager(doors, alpha)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `doors` | [LDoorManager](#ldoormanager) | Door manager holding animated open amounts. |
| `alpha?` | number | Optional alpha multiplier for the synchronized door slabs. |

**Example**

```lua
do
    local map = lurek.raycaster.new(8, 8)
    local doors = lurek.raycaster.newDoorManager()
    map:setCell(3, 3, 2)

    local id = doors:addDoor(3, 3, "vertical", 1.0)
    map:applyDoorManager(doors)
    print("closed blocked = " .. tostring(map:isBlocked(3, 3)))

    doors:openDoor(id)
    doors:update(1.0)
    map:applyDoorManager(doors, 0.8)

    local feature = map:getWallFeatureCell(3, 3)
    print("kind = " .. feature.kind)
    print("blocked after open = " .. tostring(map:isBlocked(3, 3)))
    print("open amount = " .. string.format("%.2f", feature.open_amount))
end
```

---

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
| `lights?` | table | Array of point-light tables or [LPointLight](#lpointlight) userdata values. |

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
| `lights?` | table | Array of point-light tables {x, y, radius, r?, g?, b?, color?, intensity?, level?} or [LPointLight](#lpointlight) userdata values. |
| `sprites?` | table|[LSpriteManager](#lspritemanager) | Array of sprite tables {x, y, texture?, size?, front_texture?, right_texture?, back_texture?, left_texture?, angle?} or an [LSpriteManager](#lspritemanager) with integer/[LImage](render.md#limage) textures. |
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
        sun_r = 0.75,
        sun_g = 0.8,
        sun_b = 1.0,
        sun_intensity = 0.85,
        sun_angle = 0.0,
        roof_darkness = 0.35,
    }
    local lights = {
        { x = 8, y = 8, r = 1.0, g = 0.9, b = 0.8, radius = 4.0, intensity = 1.5 },
    }
    local sprites = {
        {
            x = 10.5,
            y = 8.0,
            size = 1.0,
            angle = math.pi,
            front_texture = sprite_tex,
            right_texture = sprite_tex,
            back_texture = sprite_tex,
            left_texture = sprite_tex,
        },
    }
    local wall_textures = {
        [1] = wall_tex,
    }
    local quad_count = map:buildScene(params, lights, sprites, wall_textures)
    local managed = lurek.raycaster.newSpriteManager()
    managed:addDirectional(10.5, 8.0, sprite_tex, sprite_tex, sprite_tex, sprite_tex, math.pi, 1.0)
    local managed_quad_count = map:buildScene(params, lights, managed, wall_textures)

    print("quad count = " .. quad_count)
    print("managed quad count = " .. managed_quad_count)
    print("directional sprite count = " .. #sprites)
end
```

---

#### `LRaycaster:buildSceneFromAdapter`

Builds a textured raycaster scene from a runtime scene adapter that may follow physics bodies.

```lua
LRaycaster:buildSceneFromAdapter(params, adapter, wallTextures)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `params` | table | Scene params (same as buildScene). |
| `adapter` | [LSceneAdapter](#lsceneadapter) | Runtime scene adapter providing lights, sprites, and models. |
| `wallTextures?` | table | Map of cell_value -> texture for wall surfaces. |

**Returns**

| Type | Description |
|------|-------------|
| number | Total number of quads in the built scene. |

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
    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:addSprite(
        4.5,
        4.0,
        lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        { id = 38, size = 1.0 }
    )
    local count = map:buildSceneFromAdapter({
        px = 2.5,
        py = 4.0,
        angle = 0.0,
        fov = math.pi / 3,
        rays = 32,
        max_dist = 12.0,
        screen_w = 160,
        screen_h = 100,
    }, adapter, {})
    print("adapter scene quads = " .. count)
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
| `lights?` | table | Array of point-light tables or [LPointLight](#lpointlight) userdata values. |
| `sprites?` | table|[LSpriteManager](#lspritemanager) | Array of sprite tables with billboard or 4-direction textures, or an [LSpriteManager](#lspritemanager) with integer/[LImage](render.md#limage) textures. |
| `wallTextures?` | table | Map of cell_value -> texture. |
| `models?` | table | Array of model instance tables {model, x, y, rotation?, yaw?, z?, scale?}. |

**Returns**

| Type | Description |
|------|-------------|
| number | Total number of quads in the built scene. |

**Example**

```lua
do
    local rc = lurek.raycaster.new(80, 60)
    local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
    local params = {
        px = 8,
        py = 8,
        angle = 0,
        fov = math.pi / 3,
        rays = 40,
        max_dist = 20,
        screen_w = 160,
        screen_h = 100,
    }
    local baseline = rc:buildScene(params)
    local count = rc:buildSceneWithModels(params, nil, nil, nil, {
        { model = model, x = 10.5, y = 8.0, yaw = math.pi / 4, z = 0.15, scale = 0.22 },
    })
    local model_pick = rc:pickScreen(80, 60, params, nil, {
        { id = 42, model = model, x = 10.5, y = 8.0, yaw = math.pi / 4, z = 0.15, scale = 0.22 },
    })

    print("quad count without model = " .. baseline)
    print("quad count with model = " .. count)
    if model_pick then
        print("model pick surface = " .. model_pick.surface)
        print("model pick id = " .. tostring(model_pick.id))
        print("model pick distance = " .. string.format("%.2f", model_pick.distance))
        print("model pick uv = " .. string.format("%.2f", model_pick.u) .. "," .. string.format("%.2f", model_pick.v))
    end
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

#### `LRaycaster:clearWallFeatureCell`

Removes any per-cell wall feature override from a blocking cell.

```lua
LRaycaster:clearWallFeatureCell(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Grid column. |
| `y` | number | Grid row. |

**Example**

```lua
do
    local map = lurek.raycaster.new(8, 8)
    map:setCell(3, 3, 1)
    map:setWindowCell(3, 3, 0.25, 0.75, 0.35)
    map:clearWallFeatureCell(3, 3)
    print("feature cleared = " .. tostring(map:getWallFeatureCell(3, 3) == nil))
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
| `lights?` | table | Array of point-light tables {x, y, radius, r?, g?, b?, color?, intensity?, level?} or [LPointLight](#lpointlight) userdata values. |

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

#### `LRaycaster:getWallFeatureCell`

Returns the wall feature attached to a cell, or nil when none is set.

```lua
LRaycaster:getWallFeatureCell(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Grid column. |
| `y` | number | Grid row. |

**Returns**

| Type | Description |
|------|-------------|
| LRaycasterGetWallFeatureCellResult | Feature table {kind, alpha, ...} or nil. |

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

    map:setCell(7, 5, 1)
    map:setHalfWallCell(7, 5, 0.5)
    map:setCell(7, 7, 1)
    map:setWindowCell(7, 7, 0.25, 0.78, 0.35)
    map:setCell(7, 9, 1)
    map:setDoorCell(7, 9, "vertical", 1.0)

    local params = {
        px = 2.5,
        py = 7.5,
        angle = 0.0,
        fov = math.pi / 3,
        rays = 64,
        max_dist = 20.0,
        screen_w = 320,
        screen_h = 200,
    }
    local picked = map:pickScreen(160, 100, params)
    local hit = map:castRay(2.5, 9.5, 0.0, 20.0)
    local solid = lurek.raycaster.new(8, 3)
    solid:setCell(4, 1, 1)
    local solid_r = select(1, solid:computeTileLight(2, 1, 0.0, {
        { x = 5.5, y = 1.5, radius = 8.0, intensity = 8.0, color = { 1.0, 0.8, 0.6 } },
    }))
    local through_window = lurek.raycaster.new(8, 3)
    through_window:setCell(4, 1, 1)
    through_window:setWindowCell(4, 1, 0.25, 0.8, 0.35)
    local window_r = select(1, through_window:computeTileLight(2, 1, 0.0, {
        { x = 5.5, y = 1.5, radius = 8.0, intensity = 8.0, color = { 1.0, 0.8, 0.6 } },
    }))

    print("window los = " .. tostring(map:lineOfSight(2.5, 7.5, 12.5, 7.5)))
    print("half wall blocked = " .. tostring(map:isBlocked(7, 5)))
    print("open door hit cell = " .. tostring(hit and hit.cell_value or "nil"))
    print("solid light r = " .. string.format("%.3f", solid_r))
    print("window light r = " .. string.format("%.3f", window_r))
    if picked then
        print("pick surface = " .. picked.surface)
        print("pick tile = " .. picked.x .. "," .. picked.y)
    end
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

#### `LRaycaster:pickScreen`

Resolves a screen-space click back into the raycaster world using the same camera semantics as scene building.

```lua
LRaycaster:pickScreen(sx, sy, params, sprites, models)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sx` | number | Screen X in pixels. |
| `sy` | number | Screen Y in pixels. |
| `params` | table | Camera params {px, py, angle, fov, max_dist, screen_w, screen_h, camera_height?, horizon_offset?}. |
| `sprites?` | table|[LSpriteManager](#lspritemanager) | Optional sprite tables or sprite manager used to resolve clickable billboard hits. |
| `models?` | table | Optional model instance tables used to resolve clickable projected model hits. |

**Returns**

| Type | Description |
|------|-------------|
| LRaycasterPickScreenResult | Pick result {x, y, level, surface, distance, hit_x, hit_y, u, v, cell_value?, side?, texture?, ray_angle, id?, wall_height?, feature?} or nil. `feature` mirrors `getWallFeatureCell()` and adds `section` for the solid band/panel that was hit. |

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
    local hit = map:pickScreen(160, 100, params)
    local sprite_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
    local sprite_hit = map:pickScreen(160, 100, params, {
        { id = 7, x = 10.5, y = 8.0, texture = sprite_tex, size = 1.0 },
    })
    local model_hit = map:pickScreen(160, 120, params, nil, {
        { id = 8, model = model, x = 10.5, y = 8.0, yaw = math.pi / 4, z = 0.15, scale = 0.22 },
    })
    local half_map = lurek.raycaster.new(12, 10)
    for i = 0, 11 do
        half_map:setCell(i, 0, 1)
        half_map:setCell(i, 9, 1)
    end
    for i = 0, 9 do
        half_map:setCell(0, i, 1)
        half_map:setCell(11, i, 1)
    end
    half_map:setCell(7, 5, 1)
    half_map:setHalfWallCell(7, 5, 0.5)
    local feature_hit = half_map:pickScreen(160, 100, {
        px = 2.5,
        py = 5.5,
        angle = 0,
        fov = math.pi / 3,
        rays = 64,
        max_dist = 20,
        screen_w = 320,
        screen_h = 200,
    })

    if hit then
        print("surface = " .. hit.surface)
        print("cell = " .. hit.x .. "," .. hit.y)
        print("distance = " .. string.format("%.2f", hit.distance))
        print("hit = " .. string.format("%.2f", hit.hit_x) .. "," .. string.format("%.2f", hit.hit_y))
        print("ray angle = " .. string.format("%.3f", hit.ray_angle))
        print("uv = " .. string.format("%.2f", hit.u) .. "," .. string.format("%.2f", hit.v))
    end
    if sprite_hit then
        print("sprite surface = " .. sprite_hit.surface)
        print("sprite id = " .. tostring(sprite_hit.id))
        print("sprite distance = " .. string.format("%.2f", sprite_hit.distance))
        print("sprite uv = " .. string.format("%.2f", sprite_hit.u) .. "," .. string.format("%.2f", sprite_hit.v))
    end
    if model_hit then
        print("model surface = " .. model_hit.surface)
        print("model id = " .. tostring(model_hit.id))
        print("model distance = " .. string.format("%.2f", model_hit.distance))
        print("model uv = " .. string.format("%.2f", model_hit.u) .. "," .. string.format("%.2f", model_hit.v))
    end
    if feature_hit and feature_hit.feature then
        print("feature kind = " .. feature_hit.feature.kind)
        print("feature section = " .. feature_hit.feature.section)
        print("feature wall height = " .. string.format("%.2f", feature_hit.wall_height))
    end
end
```

---

#### `LRaycaster:pickScreenFromAdapter`

Resolves a screen-space click using sprite/model inputs sourced from a runtime scene adapter.

```lua
LRaycaster:pickScreenFromAdapter(sx, sy, params, adapter)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sx` | number | Screen X in pixels. |
| `sy` | number | Screen Y in pixels. |
| `params` | table | Camera params (same as pickScreen). |
| `adapter` | [LSceneAdapter](#lsceneadapter) | Runtime scene adapter providing sprites and models. |

**Returns**

| Type | Description |
|------|-------------|
| table | Pick result or nil when nothing was hit. Wall hits may also include `wall_height` plus `feature = {kind, section, ...}` for half walls, windows, and doors. |

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
    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:addSprite(
        4.5,
        4.0,
        lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        { id = 39, size = 1.0 }
    )
    local hit = map:pickScreenFromAdapter(80, 50, {
        px = 2.5,
        py = 4.0,
        angle = 0.0,
        fov = math.pi / 3,
        rays = 32,
        max_dist = 12.0,
        screen_w = 160,
        screen_h = 100,
    }, adapter)
    if hit then
        print("adapter pick id = " .. tostring(hit.id))
        print("adapter pick point = " .. string.format("%.2f,%.2f", hit.hit_x, hit.hit_y))
    end
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

#### `LRaycaster:setDoorCell`

Attaches a sliding door feature to a blocking cell.

```lua
LRaycaster:setDoorCell(x, y, direction, openAmount, alpha)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Grid column. |
| `y` | number | Grid row. |
| `direction` | string | "horizontal" or "vertical". |
| `openAmount` | number | Door open amount, 0.0..1.0. |
| `alpha?` | number | Optional alpha multiplier. |

**Example**

```lua
do
    local map = lurek.raycaster.new(8, 8)
    map:setCell(3, 3, 1)
    map:setDoorCell(3, 3, "horizontal", 1.0)
    local feature = map:getWallFeatureCell(3, 3)

    print("kind = " .. feature.kind)
    print("direction = " .. feature.direction)
    print("blocked = " .. tostring(map:isBlocked(3, 3)))
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

#### `LRaycaster:setHalfWallCell`

Attaches a half-height wall feature to a blocking cell.

```lua
LRaycaster:setHalfWallCell(x, y, height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Grid column. |
| `y` | number | Grid row. |
| `height` | number | Solid wall height from floor, 0.0..1.0. |

**Example**

```lua
do
    local map = lurek.raycaster.new(8, 8)
    map:setCell(3, 3, 1)
    map:setHalfWallCell(3, 3, 0.5)
    local feature = map:getWallFeatureCell(3, 3)

    print("kind = " .. feature.kind)
    print("height = " .. string.format("%.2f", feature.height))
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

#### `LRaycaster:setWindowCell`

Attaches a window feature to a blocking cell, leaving a visible opening between sill and lintel.

```lua
LRaycaster:setWindowCell(x, y, sillHeight, lintelHeight, alpha)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Grid column. |
| `y` | number | Grid row. |
| `sillHeight` | number | Bottom of the opening from the floor, 0.0..1.0. |
| `lintelHeight` | number | Top of the opening from the floor, 0.0..1.0. |
| `alpha?` | number | Wall alpha multiplier for the solid bands. |

**Example**

```lua
do
    local map = lurek.raycaster.new(8, 8)
    map:setCell(3, 3, 1)
    map:setWindowCell(3, 3, 0.3, 0.75, 0.4)
    local feature = map:getWallFeatureCell(3, 3)

    print("kind = " .. feature.kind)
    print("los = " .. tostring(map:lineOfSight(1.5, 3.5, 6.5, 3.5)))
    print("alpha = " .. string.format("%.2f", feature.alpha))
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

## LSceneAdapter

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LSceneAdapter:addDirectionalSprite`

Adds a static directional billboard sprite entry.

```lua
LSceneAdapter:addDirectionalSprite(x, y, front, right, back, left, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | World X position. |
| `y` | number | World Y position. |
| `front` | [LImage](render.md#limage)|number | Front-facing texture. |
| `right` | [LImage](render.md#limage)|number | Right-facing texture. |
| `back` | [LImage](render.md#limage)|number | Back-facing texture. |
| `left?` | [LImage](render.md#limage)|number | Left-facing texture (defaults to `right`). |
| `opts?` | table | Optional {size?, id?, level?, angle?}. |

**Example**

```lua
do
    local adapter = lurek.raycaster.newSceneAdapter()
    local tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    adapter:addDirectionalSprite(6.0, 3.5, tex, tex, tex, tex, {
        id = 32,
        level = 1,
        size = 1.0,
        angle = math.pi / 4,
    })
    local sprite = adapter:sceneInputs().sprites[1]
    print("directional front tex = " .. tostring(sprite.front_texture))
    print("directional angle = " .. string.format("%.3f", sprite.angle))
end
```

---

#### `LSceneAdapter:addLight`

Adds a static point light entry.

```lua
LSceneAdapter:addLight(x, y, radius, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | World X position. |
| `y` | number | World Y position. |
| `radius` | number | Light falloff radius. |
| `opts?` | table | Optional {intensity?, color?, r?, g?, b?, level?}. |

**Example**

```lua
do
    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:addLight(5.0, 3.5, 4.0, {
        intensity = 1.1,
        color = { 1.0, 0.7, 0.4 },
        level = 1,
    })
    local light = adapter:sceneInputs().lights[1]
    print("static light radius = " .. light.radius)
    print("static light intensity = " .. light.intensity)
end
```

---

#### `LSceneAdapter:addModel`

Adds a static OBJ model instance entry.

```lua
LSceneAdapter:addModel(model, x, y, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `model` | [LObjModel](render.md#lobjmodel) | OBJ model handle. |
| `x` | number | World X position. |
| `y` | number | World Y position. |
| `opts?` | table | Optional {id?, level?, yaw?, z?, scale?}. |

**Example**

```lua
do
    local adapter = lurek.raycaster.newSceneAdapter()
    local tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    adapter:addModel(
        lurek.render.loadModel("content/examples/assets/models/sample_tank.obj"),
        7.0,
        3.5,
        { id = 33, level = 1, yaw = 0.3, z = 0.1, scale = 0.2 }
    )
    local model = adapter:sceneInputs().models[1]
    print("static model id = " .. model.id)
    print("static model yaw = " .. string.format("%.2f", model.yaw))
end
```

---

#### `LSceneAdapter:addSprite`

Adds a static billboard sprite entry.

```lua
LSceneAdapter:addSprite(x, y, texture, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | World X position. |
| `y` | number | World Y position. |
| `texture` | [LImage](render.md#limage)|number | Sprite texture. |
| `opts?` | table | Optional {size?, id?, level?, angle?}. |

**Example**

```lua
do
    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:addSprite(
        4.5,
        3.5,
        lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        { id = 31, level = 1, size = 1.2 }
    )
    local sprite = adapter:sceneInputs().sprites[1]
    print("static sprite id = " .. sprite.id)
    print("static sprite pos = " .. string.format("%.2f,%.2f", sprite.x, sprite.y))
end
```

---

#### `LSceneAdapter:bindBodyDirectionalSprite`

Binds a directional billboard sprite to a live physics body.

```lua
LSceneAdapter:bindBodyDirectionalSprite(body, front, right, back, left, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `body` | [LBody](physics.md#lbody) | Physics body handle. |
| `front` | [LImage](render.md#limage)|number | Front-facing texture. |
| `right` | [LImage](render.md#limage)|number | Right-facing texture. |
| `back` | [LImage](render.md#limage)|number | Back-facing texture. |
| `left?` | [LImage](render.md#limage)|number | Left-facing texture (defaults to `right`). |
| `opts?` | table | Optional {size?, id?, level?, offset_x?, offset_y?, angle_offset?}. |

**Example**

```lua
do
    local tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(3.0, 3.0, "dynamic")
    body:setAngle(math.pi / 2)

    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:bindBodyDirectionalSprite(body, tex, tex, tex, tex, {
        id = 34,
        offset_y = 0.5,
        angle_offset = 0.25,
    })

    local sprite = adapter:sceneInputs().sprites[1]
    print("body directional id = " .. sprite.id)
    print("body directional pos = " .. string.format("%.2f,%.2f", sprite.x, sprite.y))
    print("body directional angle = " .. string.format("%.3f", sprite.angle))
end
```

---

#### `LSceneAdapter:bindBodyLight`

Binds a point light to a live physics body.

```lua
LSceneAdapter:bindBodyLight(body, radius, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `body` | [LBody](physics.md#lbody) | Physics body handle. |
| `radius` | number | Light falloff radius. |
| `opts?` | table | Optional {intensity?, color?, r?, g?, b?, level?, offset_x?, offset_y?}. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(2.0, 2.0, "dynamic")
    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:bindBodyLight(body, 3.0, { intensity = 0.8, offset_y = 0.25 })
    body:setPosition(3.0, 2.0)
    local light = adapter:sceneInputs().lights[1]
    print("body light pos = " .. string.format("%.2f,%.2f", light.x, light.y))
end
```

---

#### `LSceneAdapter:bindBodyModel`

Binds an OBJ model instance to a live physics body.

```lua
LSceneAdapter:bindBodyModel(body, model, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `body` | [LBody](physics.md#lbody) | Physics body handle. |
| `model` | [LObjModel](render.md#lobjmodel) | OBJ model handle. |
| `opts?` | table | Optional {id?, level?, yaw_offset?, offset_x?, offset_y?, z?, scale?}. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(2.0, 2.0, "dynamic")
    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:bindBodyModel(
        body,
        lurek.render.loadModel("content/examples/assets/models/sample_tank.obj"),
        { id = 37, offset_x = 0.5, yaw_offset = 0.2, scale = 0.25 }
    )
    body:setPosition(3.0, 2.0)
    local model = adapter:sceneInputs().models[1]
    print("body model yaw = " .. string.format("%.2f", model.yaw))
end
```

---

#### `LSceneAdapter:bindBodySprite`

Binds a billboard sprite to a live physics body.

```lua
LSceneAdapter:bindBodySprite(body, texture, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `body` | [LBody](physics.md#lbody) | Physics body handle. |
| `texture` | [LImage](render.md#limage)|number | Sprite texture. |
| `opts?` | table | Optional {size?, id?, level?, offset_x?, offset_y?, angle_offset?}. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(2.0, 2.0, "dynamic")
    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:bindBodySprite(
        body,
        lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        { id = 36, offset_x = 0.5 }
    )
    body:setPosition(3.0, 2.0)
    local sprite = adapter:sceneInputs().sprites[1]
    print("body sprite pos = " .. string.format("%.2f,%.2f", sprite.x, sprite.y))
end
```

---

#### `LSceneAdapter:clear`

Removes every tracked entry from the adapter.

```lua
LSceneAdapter:clear()
```

**Example**

```lua
do
    local adapter = lurek.raycaster.newSceneAdapter()
    local tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    adapter:addSprite(1.0, 1.0, tex)
    adapter:addLight(1.0, 1.0, 2.0)
    adapter:addModel(lurek.render.loadModel("content/examples/assets/models/sample_tank.obj"), 1.0, 1.0)
    adapter:clear()
    print("adapter cleared sprites = " .. #adapter:sceneInputs().sprites)
end
```

---

#### `LSceneAdapter:clearLights`

Removes every tracked light entry from the adapter.

```lua
LSceneAdapter:clearLights()
```

**Example**

```lua
do
    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:addLight(1.0, 1.0, 2.0)
    adapter:clearLights()
    print("adapter light count = " .. #adapter:sceneInputs().lights)
end
```

---

#### `LSceneAdapter:clearModels`

```lua
LSceneAdapter:clearModels()
```

**Example**

```lua
do
    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:addModel(lurek.render.loadModel("content/examples/assets/models/sample_tank.obj"), 1.0, 1.0)
    adapter:clearModels()
    print("adapter model count = " .. #adapter:sceneInputs().models)
end
```

---

#### `LSceneAdapter:clearSprites`

Removes every tracked sprite entry from the adapter.

```lua
LSceneAdapter:clearSprites()
```

**Example**

```lua
do
    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:addSprite(
        1.0,
        1.0,
        lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    )
    adapter:clearSprites()
    print("adapter sprite count = " .. #adapter:sceneInputs().sprites)
end
```

---

#### `LSceneAdapter:sceneInputs`

Resolves the current runtime snapshot into `{ lights, sprites, models }` tables.

```lua
LSceneAdapter:sceneInputs()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Snapshot table for build/pick calls. |

**Example**

```lua
do
    local adapter = lurek.raycaster.newSceneAdapter()
    local tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    adapter:addSprite(4.5, 3.5, tex, { id = 31, level = 1, size = 1.2 })
    adapter:addLight(5.0, 3.5, 4.0, {
        intensity = 1.1,
        color = { 1.0, 0.7, 0.4 },
        level = 1,
    })
    local inputs = adapter:sceneInputs()
    print("sceneInputs sprites = " .. #inputs.sprites)
    print("sceneInputs lights = " .. #inputs.lights)
end
```

---

#### `LSceneAdapter:type`

Returns the type name of this object.

```lua
LSceneAdapter:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always "[LSceneAdapter](#lsceneadapter)". |

**Example**

```lua
do
    local adapter = lurek.raycaster.newSceneAdapter()
    print("adapter type = " .. adapter:type())
end
```

---

#### `LSceneAdapter:typeOf`

Checks whether this object matches the given type name.

```lua
LSceneAdapter:typeOf(name)
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
    local adapter = lurek.raycaster.newSceneAdapter()
    print("adapter is scene adapter = " .. tostring(adapter:typeOf("LSceneAdapter")))
end
```

---

## LSpriteManager

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LSpriteManager:add`

Adds a new sprite to the manager at a world position with a texture label, raw id, or image handle.

```lua
LSpriteManager:add(x, y, texture, scale, level)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | World X position. |
| `y` | number | World Y position. |
| `texture` | any | Texture asset label, integer texture id, or [LImage](render.md#limage). |
| `scale?` | number | Sprite size multiplier (default 1.0). |
| `level?` | number | Optional multilevel slice index used by buildMultiLevelScene. |

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

#### `LSpriteManager:addDirectional`

Adds a new sprite with front/right/back/left textures and a world-facing angle.

```lua
LSpriteManager:addDirectional(x, y, front, right, back, left, angle, scale, level)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | World X position. |
| `y` | number | World Y position. |
| `front` | any | Texture shown when viewed from the front. |
| `right` | any | Texture shown from the right side. |
| `back` | any | Texture shown from behind. |
| `left?` | any | Texture shown from the left side (defaults to `right`). |
| `angle?` | number | World-space facing angle in radians (default 0.0). |
| `scale?` | number | Sprite size multiplier (default 1.0). |
| `level?` | number | Optional multilevel slice index used by buildMultiLevelScene. |

**Returns**

| Type | Description |
|------|-------------|
| number | Unique sprite id for later manipulation. |

**Example**

```lua
do
    local sprites = lurek.raycaster.newSpriteManager()
    local id = sprites:addDirectional(
        2.0,
        0.0,
        "front.png",
        "right.png",
        "back.png",
        "left.png",
        math.pi,
        1.0
    )
    local order = sprites:sortAndProject(0, 0, 0)

    print("sprite id = " .. id)
    print("texture = " .. order[1].texture)
    print("variant = " .. tostring(order[1].variant))
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

#### `LSpriteManager:setDirectionalTextures`

Replaces the directional bitmap set for an existing sprite and optionally updates its facing angle.

```lua
LSpriteManager:setDirectionalTextures(id, front, right, back, left, angle)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Sprite id. |
| `front` | any | Texture shown when viewed from the front. |
| `right` | any | Texture shown from the right side. |
| `back` | any | Texture shown from behind. |
| `left?` | any | Texture shown from the left side (defaults to `right`). |
| `angle?` | number | Optional new facing angle in radians. |

**Example**

```lua
do
    local sprites = lurek.raycaster.newSpriteManager()
    local id = sprites:add(2.0, 0.0, "old.png", 1.0)
    sprites:setDirectionalTextures(id, "front2.png", "right2.png", "back2.png", "left2.png", math.pi)
    local order = sprites:sortAndProject(0, 0, 0)

    print("texture = " .. order[1].texture)
    print("variant = " .. tostring(order[1].variant))
end
```

---

#### `LSpriteManager:setFacing`

Updates the facing angle of an existing directional sprite.

```lua
LSpriteManager:setFacing(id, angle)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Sprite id. |
| `angle` | number | New facing angle in radians. |

**Example**

```lua
do
    local sprites = lurek.raycaster.newSpriteManager()
    local id = sprites:addDirectional(2.0, 0.0, "front.png", "right.png", "back.png", "left.png", math.pi, 1.0)
    sprites:setFacing(id, 0.0)
    local order = sprites:sortAndProject(0, 0, 0)

    print("texture = " .. order[1].texture)
    print("variant = " .. tostring(order[1].variant))
end
```

---

#### `LSpriteManager:setLevel`

Updates the multilevel slice index for an existing sprite.

```lua
LSpriteManager:setLevel(id, level)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Sprite id. |
| `level` | number | New level index used by buildMultiLevelScene. |

**Example**

```lua
do
    local sm = lurek.raycaster.newSpriteManager()
    local id = sm:add(5, 5, "content/examples/assets/images/sample_texture.png", 1.0)
    sm:setLevel(id, 2)

    local projected = sm:sortAndProject(0, 0, 0)

    print("level = " .. tostring(projected[1].level))
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
| `camAngle` | number | Camera facing angle (reserved for future projection expansion). |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array of {id, x, y, level?, texture?, texture_id?, scale, distance, variant?, facing_angle?} sorted back-to-front. |

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
