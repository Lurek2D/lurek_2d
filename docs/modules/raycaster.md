# Raycaster

## Purpose

Simulates pseudo-3D first-person views from 2D maps using DDA marching.

## When To Use

- Its technical base is DDA-style ray traversal over map-aligned space, but the important user-facing point is that the module turns that low-level technique into a complete first-person workflow with scene building, interaction helpers, lighting hooks, and deterministic output options.
- The module is valuable because it solves the interpretation layer between structured render input and a playable camera view. Users provide wall, floor, ceiling, sprite, model, and optional light tables, and raycaster decides how that data becomes depth, occlusion, visible openings, and first-person perspective.
- This matters most in projects that want first-person presence without the complexity of general 3D mesh authoring, continuous physics, and fully free camera semantics. The system stays constrained enough to be authorable and testable while still producing a convincing viewpoint.

## Minimal Example

Example block: `lurek.raycaster.buildMultiLevelSceneFromField`

```lua
do
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local field = lurek.tilefield.new({ width = 5, height = 5, levels = 2 })
    field:setRef(3, 3, 1, "wall", { tileset = "dungeon", object = "stone_wall" })
    field:setRef(4, 3, 1, "door", 12)
    field:setRef(4, 4, 2, "window", 13)
    field:setRef(3, 4, 1, "floor", { tileset = "dungeon", object = "stone_floor" })
    field:setRef(3, 4, 1, "ceiling", { tileset = "dungeon", object = "stone_ceiling" })
    field:setRef(3, 4, 1, "object", { tileset = "dungeon", object = "banner" })
    field:setModifier("torch", { light = { radius = 4, intensity = 1.25, color = { 1.0, 0.75, 0.35 } } })
    field:applyModifier(3, 4, 1, "torch")
    local catalog = lurek.tileset.newCatalog({
        dungeon = lurek.tileset.fromProvider({
            firstGid = 1,
            tileCount = 4,
            columns = 2,
            tileWidth = 16,
            tileHeight = 16,
            objects = {
                stone_wall = {
                    slot = "wall",
                    tileId = 2,
                    visual = { textureId = texture:getId(), tileId = 2 },
                },
                stone_floor = {
                    slot = "floor",
                    tileId = 3,
                    visual = { textureId = texture:getId(), tileId = 3 },
                },
                stone_ceiling = {
                    slot = "ceiling",
                    tileId = 4,
                    visual = { textureId = texture:getId(), tileId = 4 },
                },
                banner = {
                    slot = "object",
                    visual = { textureId = texture:getId() },
                },
            },
        }),
    })
    local quads = lurek.raycaster.buildMultiLevelSceneFromField({ px = 2.5, py = 2.5, angle = 0, fov = 1.0, rays = 32, max_dist = 8, screen_w = 96, screen_h = 64, active_level = 0 }, field, {
        catalog = catalog,
        wallChannel = "vision",
        wallSlot = "wall",
        doorSlot = "door",
        windowSlot = "window",
        floorSlot = "floor",
        ceilingSlot = "ceiling",
        objectSlot = "object",
        objectSize = 0.75,
        tileLights = true,
    }, nil, nil, { [11] = texture, [12] = texture, [13] = texture })
    local stats = lurek.raycaster.getLastBuildStats()
    ray_log("tilefield raycaster quads = " .. quads .. " lighting samples = " .. stats.lightingSamples)
end
```

## Common Patterns

- Start with `lurek.raycaster.applyLitShade` when exploring this module.
- Start with `lurek.raycaster.buildMultiLevelScene` when exploring this module.
- Start with `lurek.raycaster.buildMultiLevelSceneFromAdapter` when exploring this module.
- Start with `lurek.raycaster.buildMultiLevelSceneFromField` when exploring this module.
- Start with `lurek.raycaster.distanceShade` when exploring this module.

## API Reference

- This page is the generated API reference for this module.

## Summary

- The `raycaster` module is the engine's pseudo-3D first-person view system for users who want corridor shooters, dungeon crawlers, exploration views, or tactical previews built from structured 2D world data instead of from a full freeform 3D engine stack.
- Its technical base is DDA-style ray traversal over map-aligned space, but the important user-facing point is that the module turns that low-level technique into a complete first-person workflow with scene building, interaction helpers, lighting hooks, and deterministic output options.
- The module is valuable because it solves the interpretation layer between structured render input and a playable camera view. Users provide wall, floor, ceiling, sprite, model, and optional light tables, and `raycaster` decides how that data becomes depth, occlusion, visible openings, and first-person perspective.
- This matters most in projects that want first-person presence without the complexity of general 3D mesh authoring, continuous physics, and fully free camera semantics. The system stays constrained enough to be authorable and testable while still producing a convincing viewpoint.
- Variable heights, multilevel interpretation, partial blockers, and transparent or layered hits make the subsystem more than a toy single-plane corridor renderer. It can represent richer spaces where openings, stacked features, and elevation differences matter to play and readability.
- Door state and related wall-feature handling are render features. They affect ray obstruction, visible openings, picking, and scene comprehension, while gameplay movement, vision, action, and tile-lighting semantics live in `tilefield`, `awareness`, and `tilelight`.
- Floors and ceilings are part of the same contract rather than optional garnish, since convincing pseudo-3D scenes need more than wall columns to read as spaces.
- Billboard sprites keep moving actors, pickups, props, projectiles, and markers inside the same depth model as the wall renderer, which avoids a separate mismatched pseudo-3D object layer.
- Depth-aware ordering and visibility rules are therefore core capabilities. When wall features, sprites, and translucent elements overlap, the module owns what is actually visible and in what order.
- Render-light hooks and picking support make the subsystem useful for final rendering and tooling.
- Gameplay visibility, action lines, movement blockers, point tile-light, and global top-light are outside this module.
- Scene assembly is one of the biggest practical wins for users: walls, floors, ceilings, sprites, and optional inserted content are composed through one coherent first-person pipeline instead of several subsystems guessing at perspective differently.
- Projects that need movement or reachability should use `pathfind` with `tilefield` adapters and feed the resulting camera/world state back into raycaster as render input.
- Deterministic preview and software-capture paths matter because raycasted scenes often need screenshots, regression checks, editor thumbnails, or evidence artifacts outside live play.
- Because the module owns projection and picking, first-person tools can inspect what the renderer hit without becoming gameplay authorities.
- The result is a feature that serves both play and inspection. The same projection model can support a shipped first-person game, a level preview tool, or a visibility-debug workflow without changing how world interpretation works.
- This combination of constrained world model and rich view helpers is what gives the subsystem its identity: it provides first-person readability without giving up the structural advantages of a map-driven engine.
- From a boundary perspective, world/gameplay modules define semantics and `render` draws final commands, while `raycaster` owns how structured render input becomes a first-person readable visual field with depth, occlusion, and object placement.
- Read `raycaster` as the engine authority for grid-based first-person projection and scene composition.

This module primarily collaborates with `color`, `image`, `math`, `physics`, `render`, `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local near_r, near_g, near_b = lurek.raycaster.applyLitShade(0.9, 1.0, 0.8, 0.6)
    local far_r, far_g, far_b = lurek.raycaster.applyLitShade(0.2, 1.0, 0.8, 0.6)
    ray_log("near lit shade=" .. near_r .. "," .. near_g .. "," .. near_b)
    ray_log("far lit shade=" .. far_r .. "," .. far_g .. "," .. far_b)
    ray_log("near brighter than far=" .. tostring(near_r > far_r))
    ray_log("blue channel preserved=" .. tostring(near_b > 0 and far_b > 0))
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
| `lights?` | table | Array of render light tables. |
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

    example_print_log("stacked quad count = " .. quad_count)
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

    example_print_log("stacked adapter quad count = " .. quad_count)
end
```

---

### `lurek.raycaster.buildMultiLevelSceneFromField`

Builds a multilevel raycaster scene from tilefield blockers, slots, holes, surfaces, and tile light emitters.

```lua
lurek.raycaster.buildMultiLevelSceneFromField(params, field, opts, lights, sprites, wallTextures)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `params` | table | Scene params plus optional active_level. |
| `field` | [LTileField](#ltilefield) | Source tilefield. |
| `opts?` | table | Options with `wallChannel` (default `vision`), `catalog`/`tileCatalog`, `wallSlot`, `doorSlot`, `windowSlot`, `halfWallSlot`, `floorSlot`, `ceilingSlot`, `objectSlot`, `spriteSlot`, `floorHoleSlot`, `ceilingHoleSlot`, `backgroundSlot`, `skyboxSlot`, `overlaySlot`, `floorTextures`, `ceilingTextures`, `objectTextures`, `objectSize`, `objectIdBase`, `slotRefsAreTextures`, and `tileLights`. |
| `lights?` | table | Optional raycaster point lights. |
| `sprites?` | table|[LSpriteManager](#lspritemanager) | Optional raycaster sprites. |
| `wallTextures?` | table | Map of cell_value -> texture for wall surfaces. |

**Returns**

| Type | Description |
|------|-------------|
| number | Total number of quads in the built scene. |

**Example**

```lua
do
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local field = lurek.tilefield.new({ width = 5, height = 5, levels = 2 })
    field:setRef(3, 3, 1, "wall", { tileset = "dungeon", object = "stone_wall" })
    field:setRef(4, 3, 1, "door", 12)
    field:setRef(4, 4, 2, "window", 13)
    field:setRef(3, 4, 1, "floor", { tileset = "dungeon", object = "stone_floor" })
    field:setRef(3, 4, 1, "ceiling", { tileset = "dungeon", object = "stone_ceiling" })
    field:setRef(3, 4, 1, "object", { tileset = "dungeon", object = "banner" })
    field:setModifier("torch", { light = { radius = 4, intensity = 1.25, color = { 1.0, 0.75, 0.35 } } })
    field:applyModifier(3, 4, 1, "torch")
    local catalog = lurek.tileset.newCatalog({
        dungeon = lurek.tileset.fromProvider({
            firstGid = 1,
            tileCount = 4,
            columns = 2,
            tileWidth = 16,
            tileHeight = 16,
            objects = {
                stone_wall = {
                    slot = "wall",
                    tileId = 2,
                    visual = { textureId = texture:getId(), tileId = 2 },
                },
                stone_floor = {
                    slot = "floor",
                    tileId = 3,
                    visual = { textureId = texture:getId(), tileId = 3 },
                },
                stone_ceiling = {
                    slot = "ceiling",
                    tileId = 4,
                    visual = { textureId = texture:getId(), tileId = 4 },
                },
                banner = {
                    slot = "object",
                    visual = { textureId = texture:getId() },
                },
            },
        }),
    })
    local quads = lurek.raycaster.buildMultiLevelSceneFromField({ px = 2.5, py = 2.5, angle = 0, fov = 1.0, rays = 32, max_dist = 8, screen_w = 96, screen_h = 64, active_level = 0 }, field, {
        catalog = catalog,
        wallChannel = "vision",
        wallSlot = "wall",
        doorSlot = "door",
        windowSlot = "window",
        floorSlot = "floor",
        ceilingSlot = "ceiling",
        objectSlot = "object",
        objectSize = 0.75,
        tileLights = true,
    }, nil, nil, { [11] = texture, [12] = texture, [13] = texture })
    local stats = lurek.raycaster.getLastBuildStats()
    ray_log("tilefield raycaster quads = " .. quads .. " lighting samples = " .. stats.lightingSamples)
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local near = lurek.raycaster.distanceShade(0, 10)
    local mid = lurek.raycaster.distanceShade(5, 10)
    local far = lurek.raycaster.distanceShade(9, 10)

    example_print_log("near = " .. string.format("%.2f", near))
    example_print_log("mid = " .. string.format("%.2f", mid))
    example_print_log("far = " .. string.format("%.2f", far))
end
```

---

### `lurek.raycaster.drawLastScene`

Rasterizes the most recently built raycaster scene to raw image data.

```lua
lurek.raycaster.drawLastScene(width, height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | number | Output image width in pixels. |
| `height` | number | Output image height in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Rasterized image data for the last built scene. |

**Example**

```lua
do
    local map = lurek.raycaster.new(8, 8)
    local texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    for i = 0, 7 do
        map:setCell(i, 0, 1)
        map:setCell(i, 7, 1)
        map:setCell(0, i, 1)
        map:setCell(7, i, 1)
    end
    map:setCell(5, 4, 2)
    map:buildScene({
        px = 3.5,
        py = 4.5,
        angle = 0,
        fov = math.pi / 3,
        rays = 64,
        max_dist = 8,
        screen_w = 160,
        screen_h = 100,
        ambient = 0.35,
        floor_r = 0.25,
        floor_g = 0.20,
        floor_b = 0.14,
        ceiling_r = 0.08,
        ceiling_g = 0.10,
        ceiling_b = 0.20,
    }, {
        { x = 4.5, y = 4.5, radius = 4.0, intensity = 1.2, color = { 1.0, 0.70, 0.35 } },
    }, {
        { x = 4.5, y = 4.5, texture = texture, size = 0.85, id = 7 },
    }, {
        [1] = texture,
        [2] = texture,
    })
    local image = lurek.raycaster.drawLastScene(160, 100)
    local r, g, b = image:getPixel(80, 50)
    lurek.log.info("[raycaster.example] drawLastScene image=" .. image:getWidth() .. "x" .. image:getHeight() .. " center=" .. r .. "," .. g .. "," .. b)
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
| LRaycasterGetLastBuildStatsResult | Nil if no raycaster scene has been built yet; otherwise a stats table. |

**Example**

```lua
do
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
        { x = 4.0, y = 4.0, r = 1.0, g = 0.9, b = 0.8, radius = 4.0, intensity = 1.25 },
    }, {}, {
        [1] = wall_tex,
    })

    local stats = lurek.raycaster.getLastBuildStats()
    if stats then
        example_print_log("lighting samples = " .. stats.lightingSamples)
        example_print_log("lighting cache hits = " .. stats.lightingCacheHits)
        example_print_log("lighting cache misses = " .. stats.lightingCacheMisses)
    end
end
```

---

### `lurek.raycaster.getShader`

Returns the draw-target shader applied to the stored raycaster scene, or nil when default rendering is used.

```lua
lurek.raycaster.getShader()
```

**Returns**

| Type | Description |
|------|-------------|
| [LShader](#lshader)? | Bound shader handle, or nil. |

**Example**

```lua
do
    local shader = lurek.render.newShader([[
@fragment
fn fs(@location(0) color: vec4<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(color.rgb * vec3<f32>(1.0, 0.9, 0.8), color.a);
}
]], { target = "draw" })
    lurek.raycaster.setShader(shader)
    local active = lurek.raycaster.getShader()
    lurek.log.info("raycaster shader id = " .. tostring(active and active:getId()))
    lurek.raycaster.setShader(nil)
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.raycaster.new(16, 16)
    map:setCell(1, 1, 2)
    ray_log("new width=" .. map:width())
    ray_log("new height=" .. map:height())
    ray_log("spawn cell=" .. map:getCell(1, 1))
    ray_log("spawn blocked=" .. tostring(map:isBlocked(1, 1)))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local doors = lurek.raycaster.newDoorManager()
    local first = doors:addDoor(5, 3, "horizontal", 2.0)
    local second = doors:addDoor(8, 6, "vertical", 1.5)

    example_print_log("first id = " .. first)
    example_print_log("second id = " .. second)
    example_print_log("count = " .. doors:count())
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local hm = lurek.raycaster.newHeightMap(16, 16)
    hm:setFloor(5, 5, -0.3)
    hm:setCeiling(5, 5, 0.8)
    hm:setFloor(10, 10, 0.2)
    hm:setCeiling(10, 10, 1.5)

    example_print_log("floor(5,5) = " .. hm:floorAt(5, 5))
    example_print_log("ceiling(10,10) = " .. hm:ceilingAt(10, 10))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.raycaster.newMap(32, 32)
    map:setCell(4, 4, 3)
    ray_log("newMap width=" .. map:width())
    ray_log("newMap height=" .. map:height())
    ray_log("editor cell=" .. map:getCell(4, 4))
    ray_log("empty corridor=" .. tostring(map:isBlocked(5, 5)))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.raycaster.newMultiLevelGrid({
        {
            width = 2,
            height = 2,
            cells = { 0, 0, 0, 0 },
        },
    })
    example_print_log("persistent grid levels = " .. grid:levelCount())
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    example_print_log("scene adapter sprites = " .. #inputs.sprites)
    example_print_log("scene adapter lights = " .. #inputs.lights)
    example_print_log("scene adapter models = " .. #inputs.models)
    example_print_log("sprite pos = " .. string.format("%.2f,%.2f", inputs.sprites[1].x, inputs.sprites[1].y))
    example_print_log("adapter buildScene quads = " .. quad_count)
    example_print_log("adapter pick = " .. tostring(pick and pick.surface or "nil"))
    if pick then
        example_print_log("adapter pick hit = " .. string.format("%.2f,%.2f", pick.hit_x, pick.hit_y))
        example_print_log("adapter pick angle = " .. tostring(pick.ray_angle))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sprites = lurek.raycaster.newSpriteManager()
    local barrel = sprites:add(5.5, 3.5, "content/examples/assets/images/sample_texture.png", 1.0)
    local torch = sprites:add(8.5, 2.5, "content/examples/assets/images/sample_texture.png", 0.5, 1)
    local enemy = sprites:add(10.5, 7.5, "content/examples/assets/images/sample_texture.png", 1.2)

    sprites:setPosition(enemy, 11, 8)
    sprites:setVisible(torch, false)
    sprites:remove(barrel)

    example_print_log("torch id = " .. torch)
    example_print_log("enemy id = " .. enemy)
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
        example_print_log("stacked pick level = " .. hit.level)
        example_print_log("stacked pick surface = " .. hit.surface)
        example_print_log("stacked pick cell = " .. hit.x .. "," .. hit.y)
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
        example_print_log("adapter stacked pick = " .. hit.surface .. " @ level " .. hit.level)
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local near_height, near_top, near_bottom = lurek.raycaster.projectColumn(3.0, math.pi / 3, 200)
    local far_height = select(1, lurek.raycaster.projectColumn(8.0, math.pi / 3, 200))
    ray_log("near column height=" .. string.format("%.1f", near_height))
    ray_log("near top=" .. string.format("%.1f", near_top))
    ray_log("near bottom=" .. string.format("%.1f", near_bottom))
    ray_log("near taller than far=" .. tostring(near_height > far_height))
end
```

---

### `lurek.raycaster.setShader`

Binds a draw-target shader to the most recently built raycaster scene when it is presented by the renderer. Pass nil to clear.

```lua
lurek.raycaster.setShader(shader)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `shader?` | [LShader](#lshader) | Shader created with `lurek.render.newShader(code, { target = "draw" })`, or nil to clear. |

**Example**

```lua
do
    local shader = lurek.render.newShader([[
@fragment
fn fs(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(color.r * (0.75 + uv.x * 0.25), color.g, color.b, color.a);
}
]], { target = "draw" })
    lurek.raycaster.setShader(shader)
    local map = lurek.raycaster.new(8, 8)
    map:setCell(7, 4, 1)
    map:buildScene({ px = 3, py = 4, angle = 0, fov = math.pi / 3, rays = 16, max_dist = 8, screen_w = 160, screen_h = 90 }, {}, {}, {})
    lurek.raycaster.setShader(nil)
end
```

---

## Module Fields

*No module-level fields documented.*

## Enums

*No module-specific enums documented.*

## Types

- [LDoorManager](#ldoormanager)
- [LHeightMap](#lheightmap)
- [LImageData](#limagedata)
- [LMultiLevelGrid](#lmultilevelgrid)
- [LRaycaster](#lraycaster)
- [LSceneAdapter](#lsceneadapter)
- [LShader](#lshader)
- [LSpriteManager](#lspritemanager)
- [LTileField](#ltilefield)

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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dm = lurek.raycaster.newDoorManager()
    local id = dm:addDoor(5, 5, "horizontal", 0.5)
    local door = dm:getDoor(id)

    example_print_log("count = " .. dm:count())
    example_print_log("state = " .. door.state)
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dm = lurek.raycaster.newDoorManager()
    local id = dm:addDoor(5, 5, "horizontal", 0.5)
    dm:openDoor(id)
    dm:update(0.5)
    dm:closeDoor(id)
    dm:update(0.25)

    local door = dm:getDoor(id)

    example_print_log("state = " .. door.state)
    example_print_log("open = " .. string.format("%.2f", door.openAmount))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dm = lurek.raycaster.newDoorManager()
    local first = dm:addDoor(5, 5, "horizontal", 0.5)
    local second = dm:addDoor(6, 5, "vertical", 0.25)
    ray_log("count=" .. dm:count())
    ray_log("first state=" .. dm:getDoor(first).state)
    ray_log("second openAmount=" .. tostring(dm:getDoor(second).openAmount))
    ray_log("ids differ=" .. tostring(first ~= second))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local doors = lurek.raycaster.newDoorManager()
    local idx = doors:addDoor(3, 3, "vertical", 4.0)

    doors:openDoor(idx)
    for _ = 1, 10 do
        doors:update(0.1)
    end

    local door = doors:getDoor(idx)

    example_print_log("state = " .. door.state)
    example_print_log("open = " .. string.format("%.2f", door.openAmount))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dm = lurek.raycaster.newDoorManager()
    local id = dm:addDoor(5, 5, "horizontal", 0.5)
    dm:openDoor(id)
    dm:update(0.1)

    local door = dm:getDoor(id)

    example_print_log("state = " .. door.state)
    example_print_log("open = " .. string.format("%.2f", door.openAmount))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local doors = lurek.raycaster.newDoorManager()
    local id = doors:addDoor(2, 2, "horizontal", 0.5)
    local type_name = doors:type()
    ray_log("door manager type=" .. type_name)
    ray_log("door count=" .. doors:count())
    ray_log("tracked door state=" .. doors:getDoor(id).state)
    ray_log("door id=" .. tostring(id))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local doors = lurek.raycaster.newDoorManager()
    local id = doors:addDoor(3, 3, "vertical", 0.75)
    local door = doors:getDoor(id)
    ray_log("LDoorManager=" .. tostring(doors:typeOf("LDoorManager")))
    ray_log("LObject=" .. tostring(doors:typeOf("LObject")))
    ray_log("LRaycaster=" .. tostring(doors:typeOf("LRaycaster")))
    ray_log("door cell=" .. tostring(door.x) .. "," .. tostring(door.y))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dm = lurek.raycaster.newDoorManager()
    local id = dm:addDoor(5, 5, "horizontal", 0.5)
    dm:openDoor(id)
    dm:update(0.1)

    local door = dm:getDoor(id)

    example_print_log("state = " .. door.state)
    example_print_log("open = " .. string.format("%.2f", door.openAmount))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local hm = lurek.raycaster.newHeightMap(16, 16)
    hm:setFloor(3, 3, 0.2)
    hm:setCeiling(3, 3, 0.9)
    hm:setCeiling(4, 3, 1.1)
    ray_log("ceiling(3,3)=" .. hm:ceilingAt(3, 3))
    ray_log("ceiling(4,3)=" .. hm:ceilingAt(4, 3))
    ray_log("floor(3,3)=" .. hm:floorAt(3, 3))
    ray_log("ceiling authoring supports neighboring tiles")
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local hm = lurek.raycaster.newHeightMap(16, 16)
    hm:setFloor(3, 3, 0.2)
    hm:setCeiling(3, 3, 0.9)
    hm:setFloor(4, 3, -0.1)
    ray_log("floor(3,3)=" .. hm:floorAt(3, 3))
    ray_log("floor(4,3)=" .. hm:floorAt(4, 3))
    ray_log("ceiling(3,3)=" .. hm:ceilingAt(3, 3))
    ray_log("floor authoring supports neighboring tiles")
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local hm = lurek.raycaster.newHeightMap(16, 16)
    hm:setCeiling(3, 3, 0.9)
    hm:setCeiling(3, 4, 1.3)
    ray_log("ceiling(3,3)=" .. hm:ceilingAt(3, 3))
    ray_log("ceiling(3,4)=" .. hm:ceilingAt(3, 4))
    ray_log("floor(3,3)=" .. hm:floorAt(3, 3))
    ray_log("setCeiling updates targeted cells only")
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local hm = lurek.raycaster.newHeightMap(16, 16)
    hm:setFloor(3, 3, 0.2)
    hm:setFloor(4, 3, -0.2)
    ray_log("floor(3,3)=" .. hm:floorAt(3, 3))
    ray_log("floor(4,3)=" .. hm:floorAt(4, 3))
    ray_log("ceiling(3,3)=" .. hm:ceilingAt(3, 3))
    ray_log("setFloor updates targeted cells only")
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local hm = lurek.raycaster.newHeightMap(4, 4)
    hm:setFloor(1, 1, -0.25)
    local type_name = hm:type()
    ray_log("heightmap type=" .. type_name)
    ray_log("floor sample=" .. hm:floorAt(1, 1))
    ray_log("ceiling default=" .. hm:ceilingAt(1, 1))
    ray_log("type tracks authored cells")
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local hm = lurek.raycaster.newHeightMap(4, 4)
    hm:setCeiling(2, 2, 1.4)
    ray_log("LHeightMap=" .. tostring(hm:typeOf("LHeightMap")))
    ray_log("LObject=" .. tostring(hm:typeOf("LObject")))
    ray_log("LSpriteManager=" .. tostring(hm:typeOf("LSpriteManager")))
    ray_log("ceiling sample=" .. hm:ceilingAt(2, 2))
end
```

---

## LImageData

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LImageData:alphaMask`

Multiplies this image alpha channel by a factor in place.

```lua
LImageData:alphaMask(factor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `factor` | number | Alpha multiplier. |

---

#### `LImageData:applyEffect`

Applies a named image effect in place, or returns a new image when the effect changes size.

```lua
LImageData:applyEffect(name, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Effect name. |
| `opts?` | table | Effect options such as `factor`, `amount`, `radius`, `levels`, `region`, or `color`. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | nil | New image for size-changing effects, otherwise nil. |

---

#### `LImageData:applyEffects`

Applies a sequence of named effects in order.

```lua
LImageData:applyEffects(effects, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `effects` | table | Array of effect names or `{name=..., opts=...}` tables. |
| `opts?` | table | Default options used by string entries. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | nil | Last new image returned by a size-changing effect, otherwise nil. |

---

#### `LImageData:applyMask`

Multiplies this image alpha by another image's alpha channel.

```lua
LImageData:applyMask(mask)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mask` | [LImageData](#limagedata) | Same-sized alpha mask image. |

---

#### `LImageData:applyPaletteLut`

Applies a palette lookup table to this image in place.

```lua
LImageData:applyPaletteLut(lut_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `lut_ud` | [LPaletteLUT](image.md#lpalettelut) | Palette lookup table handle. |

---

#### `LImageData:applyShader`

Applies an offline image shader and returns the processed image.

```lua
LImageData:applyShader(shader, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `shader` | [LShader](#lshader) | Image-target shader. |
| `opts?` | table | Optional processing options. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Processed image. |

---

#### `LImageData:blit`

Copies a source image into this image at a destination coordinate.

```lua
LImageData:blit(src_ud, dst_x, dst_y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `src_ud` | [LImageData](#limagedata) | Source image data handle. |
| `dst_x` | number | Destination x coordinate. |
| `dst_y` | number | Destination y coordinate. |

---

#### `LImageData:blur`

Returns a blurred copy of this image.

```lua
LImageData:blur(radius)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `radius` | number | Blur radius. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Blurred image data handle. |

---

#### `LImageData:brightness`

Applies a brightness factor to this image in place.

```lua
LImageData:brightness(factor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `factor` | number | Brightness multiplier or adjustment factor. |

---

#### `LImageData:clone`

Returns a deep copy of this image data.

```lua
LImageData:clone()
```

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Copied image data. |

---

#### `LImageData:contrast`

Applies a contrast factor to this image in place.

```lua
LImageData:contrast(factor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `factor` | number | Contrast factor. |

---

#### `LImageData:convolve`

Applies a convolution kernel and returns the filtered image.

```lua
LImageData:convolve(kernel_t, ksize)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `kernel_t` | table | Array table of numeric kernel weights. |
| `ksize` | number | Kernel width and height. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Convolved image data handle. |

---

#### `LImageData:copyRegion`

Copies a rectangular region into a new image.

```lua
LImageData:copyRegion(x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Source x coordinate. |
| `y` | number | Source y coordinate. |
| `w` | number | Region width. |
| `h` | number | Region height. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Copied region. |

---

#### `LImageData:crop`

Returns a cropped image region. This method is available to Lua scripts.

```lua
LImageData:crop(x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Source x coordinate. |
| `y` | number | Source y coordinate. |
| `w` | number | Crop width. |
| `h` | number | Crop height. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Cropped image data handle. |

---

#### `LImageData:diff`

Computes a difference metric against another image.

```lua
LImageData:diff(other_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other_ud` | [LImageData](#limagedata) | Image data handle to compare with this image. |

**Returns**

| Type | Description |
|------|-------------|
| number | Difference score. |

---

#### `LImageData:drawCircle`

Draws a filled circle into this image.

```lua
LImageData:drawCircle(cx, cy, radius, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cx` | number | Circle center x coordinate. |
| `cy` | number | Circle center y coordinate. |
| `radius` | number | Circle radius. |
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a` | number | Alpha channel. |

---

#### `LImageData:drawLine`

Draws a line into this image. This method is available to Lua scripts.

```lua
LImageData:drawLine(x0, y0, x1, y1, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x0` | number | Start x coordinate. |
| `y0` | number | Start y coordinate. |
| `x1` | number | End x coordinate. |
| `y1` | number | End y coordinate. |
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a` | number | Alpha channel. |

---

#### `LImageData:drawRect`

Draws a filled rectangle into this image.

```lua
LImageData:drawRect(x, y, w, h, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Rectangle x coordinate. |
| `y` | number | Rectangle y coordinate. |
| `w` | number | Rectangle width. |
| `h` | number | Rectangle height. |
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a` | number | Alpha channel. |

---

#### `LImageData:encode`

Encodes image data in a supported format.

```lua
LImageData:encode(format)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `format` | string | Format name; currently `png`. |

**Returns**

| Type | Description |
|------|-------------|
| string | Encoded image bytes. |

---

#### `LImageData:fill`

Fills the whole image with one RGBA color.

```lua
LImageData:fill(r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a` | number | Alpha channel. |

---

#### `LImageData:flipHorizontal`

Flips this image horizontally in place.

```lua
LImageData:flipHorizontal()
```

---

#### `LImageData:flipVertical`

Flips this image vertically in place.

```lua
LImageData:flipVertical()
```

---

#### `LImageData:gamma`

Applies gamma correction to this image in place.

```lua
LImageData:gamma(gamma)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `gamma` | number | Gamma value. |

---

#### `LImageData:getDimensions`

Returns image dimensions. This method is available to Lua scripts.

```lua
LImageData:getDimensions()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width in pixels. |
| number | Height in pixels. |

---

#### `LImageData:getHeight`

Returns image height. This method is available to Lua scripts.

```lua
LImageData:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Height in pixels. |

---

#### `LImageData:getPixel`

Returns RGBA channels at a pixel coordinate.

```lua
LImageData:getPixel(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X coordinate. |
| `y` | number | Y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| number | Red channel. |
| number | Green channel. |
| number | Blue channel. |
| number | Alpha channel. |

---

#### `LImageData:getRawBytes`

Returns raw image bytes as a Lua string.

```lua
LImageData:getRawBytes()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Raw image byte string. |

---

#### `LImageData:getRegion`

Returns an image region when the requested rectangle is inside bounds.

```lua
LImageData:getRegion(x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Region x coordinate. |
| `y` | number | Region y coordinate. |
| `w` | number | Region width. |
| `h` | number | Region height. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | nil | `[LImageData](#limagedata)` handle, or nil when the region is out of bounds. |

---

#### `LImageData:getString`

Returns raw image bytes as a Lua string.

```lua
LImageData:getString()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Raw image byte string. |

---

#### `LImageData:getWidth`

Returns image width. This method is available to Lua scripts.

```lua
LImageData:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width in pixels. |

---

#### `LImageData:grayscale`

Converts this image to grayscale in place.

```lua
LImageData:grayscale()
```

---

#### `LImageData:invert`

Inverts image color channels in place.

```lua
LImageData:invert()
```

---

#### `LImageData:mapPixel`

Applies a Lua callback to every pixel and replaces each pixel with returned RGBA values.

```lua
LImageData:mapPixel(func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `func` | function | Callback receiving `(x, y, r, g, b, a)` and returning replacement channels. |

---

#### `LImageData:mapPixels`

Applies a Lua callback to every pixel and replaces each pixel with returned RGBA values.

```lua
LImageData:mapPixels(func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `func` | function | Callback receiving `(x, y, r, g, b, a)` and returning replacement channels. |

---

#### `LImageData:noise`

Adds noise to this image in place. This method is available to Lua scripts.

```lua
LImageData:noise(amount)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `amount` | number | Noise amount. |

---

#### `LImageData:paste`

Pastes a source image into this image at unsigned destination coordinates.

```lua
LImageData:paste(src_ud, dx, dy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `src_ud` | [LImageData](#limagedata) | Source image data handle. |
| `dx` | number | Destination x coordinate. |
| `dy` | number | Destination y coordinate. |

---

#### `LImageData:posterize`

Reduces image colors to a fixed number of levels in place.

```lua
LImageData:posterize(levels)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `levels` | number | Number of posterization levels. |

---

#### `LImageData:resize`

Returns a resized image using an optional named filter.

```lua
LImageData:resize(width, height, filter)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | number | Output width. |
| `height` | number | Output height. |
| `filter` | string | Optional filter name, defaulting to `bilinear`. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | nil | Resized `[LImageData](#limagedata)` handle, or nil when resizing fails. |

---

#### `LImageData:resizeNearest`

Returns a resized image using nearest-neighbor sampling.

```lua
LImageData:resizeNearest(new_w, new_h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `new_w` | number | Output width. |
| `new_h` | number | Output height. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Resized image data handle. |

---

#### `LImageData:rotate90cw`

Returns a new image rotated ninety degrees clockwise.

```lua
LImageData:rotate90cw()
```

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Rotated image data handle. |

---

#### `LImageData:saturation`

Applies a saturation factor to this image in place.

```lua
LImageData:saturation(factor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `factor` | number | Saturation factor. |

---

#### `LImageData:sepia`

Applies a sepia filter to this image in place.

```lua
LImageData:sepia()
```

---

#### `LImageData:setPixel`

Sets RGBA channels at a pixel coordinate.

```lua
LImageData:setPixel(x, y, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X coordinate. |
| `y` | number | Y coordinate. |
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a` | number | Alpha channel. |

---

#### `LImageData:setRawData`

Replaces the image byte buffer with raw bytes.

```lua
LImageData:setRawData(bytes)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bytes` | string | Raw byte string matching the image storage size. |

---

#### `LImageData:sharpen`

Returns a sharpened copy of this image.

```lua
LImageData:sharpen()
```

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Sharpened image data handle. |

---

#### `LImageData:threshold`

Applies a threshold filter to this image in place.

```lua
LImageData:threshold(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | number | Threshold channel value. |

---

#### `LImageData:tint`

Blends this image toward a tint color in place.

```lua
LImageData:tint(tr, tg, tb, factor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tr` | number | Tint red channel. |
| `tg` | number | Tint green channel. |
| `tb` | number | Tint blue channel. |
| `factor` | number | Tint blend factor. |

---

#### `LImageData:transform`

Returns a transformed image, currently supporting high-quality resize through `width`, `height`, and `filter`.

```lua
LImageData:transform(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts?` | table | Transform options. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Transformed image. |

---

#### `LImageData:type`

Returns the Lua-visible type name for this image data handle.

```lua
LImageData:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LImageData](#limagedata)`. |

---

#### `LImageData:typeOf`

Returns whether this image data handle matches the `[LImageData](#limagedata)` type name.

```lua
LImageData:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LImageData](#limagedata)` or `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches. |

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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        { width = 2, height = 2, cells = { 0, 0, 0, 0 }, floor_offset = 1, ceiling_height = 2 },
    })
    grid:setActiveLevel(1)
    example_print_log("active level = " .. grid:activeLevel())
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.raycaster.newMultiLevelGrid()
    local index = grid:addLevel({
        width = 2,
        height = 2,
        cells = { 0, 0, 0, 0 },
    })
    example_print_log("added level = " .. index)
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
| `lights?` | table | Array of render light tables. |
| `sprites?` | table|[LSpriteManager](#lspritemanager) | Array of level sprite tables or an [LSpriteManager](#lspritemanager). |
| `wallTextures?` | table | Map of cell_value -> texture for wall surfaces. |

**Returns**

| Type | Description |
|------|-------------|
| number | Total number of quads in the built scene. |

**Example**

```lua
do
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    example_print_log("persistent scene quads = " .. count)
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    example_print_log("persistent adapter quads = " .. quad_count)
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 1, 0, 0, 0 } },
    })
    grid:setWallFeatureCell(0, 0, { kind = "window", sill_height = 0.25, lintel_height = 0.8, alpha = 0.4 })
    grid:clearWallFeatureCell(0, 0)
    example_print_log("feature cleared = " .. tostring(grid:getWallFeatureCell(0, 0) == nil))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 }, floor_offset = 0.5, ceiling_height = 2.25 },
    })
    grid:setFloorOffset(0.75)
    ray_log("ceiling height=" .. grid:getCeilingHeight())
    ray_log("floor offset=" .. grid:getFloorOffset())
    ray_log("active level=" .. grid:activeLevel())
    ray_log("type=" .. grid:type())
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    grid:setCeilingTexture(lurek.render.newImage("content/examples/assets/images/sample_texture.png"))
    example_print_log("ceiling texture id = " .. tostring(grid:getCeilingTexture()))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    grid:setCeilingTextureCell(0, 0, lurek.render.newImage("content/examples/assets/images/sample_texture.png"))
    example_print_log("ceiling(0,0) texture id = " .. tostring(grid:getCeilingTextureCell(0, 0)))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        { width = 2, height = 2, cells = { 0, 5, 0, 0 } },
    })
    grid:setActiveLevel(1)
    example_print_log("active cell = " .. grid:getCell(1, 0))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        { width = 2, height = 2, cells = { 0, 0, 0, 0 }, floor_offset = 1.25, ceiling_height = 2.5 },
    })
    grid:setActiveLevel(1)
    example_print_log("floor offset = " .. grid:getFloorOffset())
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    grid:setFloorTexture(lurek.render.newImage("content/examples/assets/images/sample_texture.png"))
    example_print_log("floor texture id = " .. tostring(grid:getFloorTexture()))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    grid:setFloorTextureCell(1, 0, lurek.render.newImage("content/examples/assets/images/sample_texture.png"))
    example_print_log("floor(1,0) texture id = " .. tostring(grid:getFloorTextureCell(1, 0)))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    example_print_log("pit blocked = " .. tostring(pit.blocked))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 1, 0, 0, 0 } },
    })
    grid:setWallFeatureCell(0, 0, { kind = "window", sill_height = 0.25, lintel_height = 0.8, alpha = 0.4 })
    local feature = grid:getWallFeatureCell(0, 0)
    ray_log("feature kind=" .. tostring(feature and feature.kind))
    ray_log("feature alpha=" .. tostring(feature and feature.alpha))
    ray_log("empty cell absent=" .. tostring(grid:getWallFeatureCell(1, 1) == nil))
    ray_log("window sill=" .. tostring(feature and feature.sill_height))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        { width = 2, height = 2, cells = { 0, 0, 0, 0 }, ceiling_holes = { false, false, false, true } },
    })
    grid:setActiveLevel(1)
    example_print_log("imported ceiling hole = " .. tostring(grid:isCeilingHole(1, 1)))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        { width = 2, height = 2, cells = { 0, 0, 0, 0 }, floor_holes = { false, true, false, false } },
    })
    grid:setActiveLevel(1)
    example_print_log("imported floor hole = " .. tostring(grid:isFloorHole(1, 0)))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.raycaster.newMultiLevelGrid()
    grid:addLevel({
        width = 2,
        height = 2,
        cells = { 0, 0, 0, 0 },
    })
    example_print_log("level count = " .. grid:levelCount())
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
        example_print_log("persistent pick = " .. hit.surface .. " @ level " .. hit.level)
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
        example_print_log("persistent adapter hit = " .. hit.surface .. " #" .. tostring(hit.id))
        example_print_log("persistent adapter hit point = " .. string.format("%.2f,%.2f", hit.hit_x, hit.hit_y))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        { width = 2, height = 2, cells = { 0, 0, 0, 0 }, floor_offset = 1, ceiling_height = 2 },
    })
    grid:setActiveLevel(1)
    example_print_log("active after set = " .. grid:activeLevel())
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 }, floor_offset = 0.5, ceiling_height = 1.5 },
    })
    grid:setCeilingHeight(0.55)
    example_print_log("clamped ceiling height = " .. grid:getCeilingHeight())
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    grid:setActiveLevel(1)
    grid:setCeilingHole(1, 1, true)
    example_print_log("ceiling hole after set = " .. tostring(grid:isCeilingHole(1, 1)))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    local ceil_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    grid:setCeilingTexture(ceil_tex)
    example_print_log("default ceiling texture = " .. tostring(grid:getCeilingTexture()))
    grid:setCeilingTexture(nil)
    example_print_log("default ceiling cleared = " .. tostring(grid:getCeilingTexture() == nil))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    grid:setCeilingTextureCell(0, 1, lurek.render.newImage("content/examples/assets/images/sample_texture.png"))
    example_print_log("ceiling cell texture = " .. tostring(grid:getCeilingTextureCell(0, 1)))
    grid:setCeilingTextureCell(0, 1, nil)
    example_print_log("ceiling cell cleared = " .. tostring(grid:getCeilingTextureCell(0, 1) == nil))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    grid:setActiveLevel(1)
    grid:setCell(1, 0, 7)
    example_print_log("active cell after set = " .. grid:getCell(1, 0))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    grid:setActiveLevel(1)
    grid:setFloorHole(1, 0, true)
    example_print_log("floor hole after set = " .. tostring(grid:isFloorHole(1, 0)))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 }, floor_offset = 0, ceiling_height = 1 },
    })
    grid:setFloorOffset(0.75)
    example_print_log("updated floor offset = " .. grid:getFloorOffset())
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    local floor_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    grid:setFloorTexture(floor_tex)
    example_print_log("default floor texture = " .. tostring(grid:getFloorTexture()))
    grid:setFloorTexture(nil)
    example_print_log("default floor cleared = " .. tostring(grid:getFloorTexture() == nil))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    grid:setFloorTextureCell(1, 1, lurek.render.newImage("content/examples/assets/images/sample_texture.png"))
    example_print_log("floor cell texture = " .. tostring(grid:getFloorTextureCell(1, 1)))
    grid:setFloorTextureCell(1, 1, nil)
    example_print_log("floor cell cleared = " .. tostring(grid:getFloorTextureCell(1, 1) == nil))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    example_print_log("pit depth = " .. pit.depth)
    grid:setLoweredFloorCell(2, 2, nil)
    example_print_log("pit cleared = " .. tostring(grid:getLoweredFloorCell(2, 2) == nil))
end
```

---

#### `LMultiLevelGrid:setWallFeatureCell`

Attaches a render-only wall feature descriptor to a blocking cell on the active level.

```lua
LMultiLevelGrid:setWallFeatureCell(x, y, feature)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Grid column. |
| `y` | number | Grid row. |
| `feature` | table|Feature | "door", ...}. |

**Example**

```lua
do
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 1, 0, 0, 0 } },
    })
    grid:setWallFeatureCell(0, 0, { kind = "door", direction = "vertical", open_amount = 0.4, alpha = 0.9 })
    local feature = grid:getWallFeatureCell(0, 0)
    example_print_log("feature kind = " .. feature.kind)
    example_print_log("door open = " .. string.format("%.2f", feature.open_amount))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.raycaster.newMultiLevelGrid()
    grid:addLevel({ width = 2, height = 2, cells = { 0, 0, 0, 0 }, floor_offset = 0, ceiling_height = 1.5 })
    grid:setActiveLevel(0)
    ray_log("persistent type=" .. grid:type())
    ray_log("level count=" .. grid:levelCount())
    ray_log("active level=" .. grid:activeLevel())
    ray_log("typeOf grid=" .. tostring(grid:typeOf("LMultiLevelGrid")))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.raycaster.newMultiLevelGrid()
    grid:addLevel({ width = 2, height = 2, cells = { 0, 0, 0, 0 }, floor_offset = 1, ceiling_height = 2 })
    ray_log("LMultiLevelGrid=" .. tostring(grid:typeOf("LMultiLevelGrid")))
    ray_log("LObject=" .. tostring(grid:typeOf("LObject")))
    ray_log("LRaycaster=" .. tostring(grid:typeOf("LRaycaster")))
    ray_log("level count=" .. grid:levelCount())
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.raycaster.new(8, 8)
    local doors = lurek.raycaster.newDoorManager()
    map:setCell(3, 3, 2)

    local id = doors:addDoor(3, 3, "vertical", 1.0)
    map:applyDoorManager(doors)
    example_print_log("closed blocked = " .. tostring(map:isBlocked(3, 3)))

    doors:openDoor(id)
    doors:update(1.0)
    map:applyDoorManager(doors, 0.8)

    local feature = map:getWallFeatureCell(3, 3)
    example_print_log("kind = " .. feature.kind)
    example_print_log("blocked after open = " .. tostring(map:isBlocked(3, 3)))
    example_print_log("open amount = " .. string.format("%.2f", feature.open_amount))
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
| `lights?` | table | Array of render light tables {x, y, radius, r?, g?, b?, color?, intensity?, level?}. |
| `sprites?` | table|[LSpriteManager](#lspritemanager) | Array of sprite tables {x, y, texture?, size?, front_texture?, right_texture?, back_texture?, left_texture?, angle?} or an [LSpriteManager](#lspritemanager) with integer/[LImage](render.md#limage) textures. |
| `wallTextures?` | table | Map of cell_value -> texture for wall surfaces. |

**Returns**

| Type | Description |
|------|-------------|
| number | Total number of quads in the built scene. |

**Example**

```lua
do
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

    example_print_log("quad count = " .. quad_count)
    example_print_log("managed quad count = " .. managed_quad_count)
    example_print_log("directional sprite count = " .. #sprites)
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    example_print_log("adapter scene quads = " .. count)
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
| `lights?` | table | Array of render light tables. |
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

    example_print_log("quad count without model = " .. baseline)
    example_print_log("quad count with model = " .. count)
    if model_pick then
        example_print_log("model pick surface = " .. model_pick.surface)
        example_print_log("model pick id = " .. tostring(model_pick.id))
        example_print_log("model pick distance = " .. string.format("%.2f", model_pick.distance))
        example_print_log("model pick uv = " .. string.format("%.2f", model_pick.u) .. "," .. string.format("%.2f", model_pick.v))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.raycaster.new(16, 16)
    local uvs = map:castFloorRow(8, 8, 1, 0, 0, 0.66, 150)

    example_print_log("uv count = " .. #uvs)
    if uvs[1] then
        example_print_log("first uv = " .. string.format("%.2f", uvs[1].u) .. "," .. string.format("%.2f", uvs[1].v))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.raycaster.new(16, 16)
    for i = 0, 15 do
        map:setCell(i, 0, 1)
        map:setCell(i, 15, 1)
        map:setCell(0, i, 1)
        map:setCell(15, i, 1)
    end

    local hit = map:castRay(8, 8, 0, 20)

    if hit then
        example_print_log("distance = " .. string.format("%.2f", hit.distance))
        example_print_log("cell = " .. hit.cell_value .. " side = " .. hit.side)
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.raycaster.new(16, 16)
    map:setCell(5, 8, 2)
    map:setCell(10, 8, 1)
    map:setWallAlpha(2, 0.5)

    local hits = map:castRayMulti(2, 8.5, 0, 20, 4)

    example_print_log("hit count = " .. #hits)
    if hits[1] then
        example_print_log("first distance = " .. string.format("%.2f", hits[1].distance))
        example_print_log("first cell = " .. hits[1].cell_value)
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.raycaster.new(16, 16)
    for i = 0, 15 do
        map:setCell(i, 0, 1)
        map:setCell(i, 15, 1)
        map:setCell(0, i, 1)
        map:setCell(15, i, 1)
    end

    local hits = map:castRays(8, 8, 0, math.pi / 3, 10, 20)

    example_print_log("ray count = " .. #hits)
    if hits[1] then
        example_print_log("first distance = " .. string.format("%.2f", hits[1].distance))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.raycaster.new(16, 16)
    for i = 0, 15 do
        map:setCell(i, 0, 1)
        map:setCell(i, 15, 1)
        map:setCell(0, i, 1)
        map:setCell(15, i, 1)
    end

    local flat = map:castRaysFlat(8, 8, 0, math.pi / 3, 6, 20)

    example_print_log("flat value count = " .. #flat)
    example_print_log("first ray distance = " .. string.format("%.2f", flat[1] or 0))
    example_print_log("first ray cell = " .. tostring(flat[2]))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.raycaster.new(8, 8)
    map:setCell(3, 3, 1)
    map:setWallFeatureCell(3, 3, { kind = "window", sill_height = 0.25, lintel_height = 0.75, alpha = 0.35 })
    map:clearWallFeatureCell(3, 3)
    example_print_log("feature cleared = " .. tostring(map:getWallFeatureCell(3, 3) == nil))
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
| [LImageData](#limagedata) | Raw image data for all frames. |

**Example**

```lua
do
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.raycaster.new(8, 8)
    for i = 0, 7 do
        map:setCell(i, 0, 1)
        map:setCell(i, 7, 1)
        map:setCell(0, i, 1)
        map:setCell(7, i, 1)
    end

    local strip = map:drawCameraSweep(4, 4, math.pi / 3, 8, 8, 160, 100)

    example_print_log("width = " .. strip:getWidth())
    example_print_log("height = " .. strip:getHeight())
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
| [LImageData](#limagedata) | Raw depth-map image data. |

**Example**

```lua
do
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.raycaster.new(16, 16)
    for i = 0, 15 do
        map:setCell(i, 0, 1)
        map:setCell(i, 15, 1)
        map:setCell(0, i, 1)
        map:setCell(15, i, 1)
    end

    local depth = map:drawDepthMap(8, 8, 0, math.pi / 3, 160, 160, 100, 16)

    example_print_log("width = " .. depth:getWidth())
    example_print_log("height = " .. depth:getHeight())
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
| [LImageData](#limagedata) | Raw image data. |

**Example**

```lua
do
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.raycaster.new(8, 8)
    for i = 0, 7 do
        map:setCell(i, 0, 1)
        map:setCell(i, 7, 1)
        map:setCell(0, i, 1)
        map:setCell(7, i, 1)
    end

    map:setCell(3, 3, 1)

    local img = map:drawTopDown(4.5, 4.5, 0, 16)

    example_print_log("width = " .. img:getWidth())
    example_print_log("height = " .. img:getHeight())
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
| [LImageData](#limagedata) | Raw image data. |

**Example**

```lua
do
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.raycaster.new(16, 16)
    for i = 0, 15 do
        map:setCell(i, 0, 1)
        map:setCell(i, 15, 1)
        map:setCell(0, i, 1)
        map:setCell(15, i, 1)
    end

    local img = map:drawView(8, 8, 0, math.pi / 3, 320, 200, 16)

    example_print_log("width = " .. img:getWidth())
    example_print_log("height = " .. img:getHeight())
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.raycaster.new(8, 8)
    local ceil_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")

    map:setCeilingTextureCell(2, 2, ceil_tex)

    example_print_log("ceiling(2,2) = " .. tostring(map:getCeilingTextureCell(2, 2)))
    example_print_log("ceiling(0,0) = " .. tostring(map:getCeilingTextureCell(0, 0)))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.raycaster.new(8, 8)
    map:setCell(0, 0, 1)
    local value = map:getCell(0, 0)
    local empty = map:getCell(7, 7)

    example_print_log("cell(0,0) = " .. value)
    example_print_log("cell(7,7) = " .. empty)
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.raycaster.new(8, 8)
    local floor_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")

    map:setFloorTextureCell(3, 3, floor_tex)

    example_print_log("floor(3,3) = " .. tostring(map:getFloorTextureCell(3, 3)))
    example_print_log("floor(0,0) = " .. tostring(map:getFloorTextureCell(0, 0)))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
        example_print_log("texture = " .. tostring(cell.texture))
        example_print_log("depth = " .. cell.depth)
        example_print_log("blocked = " .. tostring(cell.blocked))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.raycaster.new(8, 8)
    map:setWallAlpha(2, 0.5)
    map:setWallAlpha(3, 0.25)
    ray_log("alpha(2)=" .. tostring(map:getWallAlpha(2)))
    ray_log("alpha(3)=" .. tostring(map:getWallAlpha(3)))
    ray_log("alpha(9)=" .. tostring(map:getWallAlpha(9)))
    ray_log("alpha map supports multiple tile ids")
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.raycaster.new(16, 16)
    for i = 0, 15 do
        map:setCell(i, 0, 1)
        map:setCell(i, 15, 1)
        map:setCell(0, i, 1)
        map:setCell(15, i, 1)
    end

    map:setCell(7, 5, 1)
    map:setWallFeatureCell(7, 5, { kind = "half", height = 0.5 })
    map:setCell(7, 7, 1)
    map:setWallFeatureCell(7, 7, { kind = "window", sill_height = 0.25, lintel_height = 0.78, alpha = 0.35 })
    map:setCell(7, 9, 1)
    map:setWallFeatureCell(7, 9, { kind = "door", direction = "vertical", open_amount = 1.0 })
    local feature = map:getWallFeatureCell(7, 7)
    example_print_log("feature kind = " .. tostring(feature and feature.kind))

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

    example_print_log("half wall blocked = " .. tostring(map:isBlocked(7, 5)))
    example_print_log("open door hit cell = " .. tostring(hit and hit.cell_value or "nil"))
    if picked then
        example_print_log("pick surface = " .. picked.surface)
        example_print_log("pick tile = " .. picked.x .. "," .. picked.y)
    end
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rc = lurek.raycaster.new(160, 120)
    rc:setCell(10, 10, 1)
    ray_log("height=" .. rc:height())
    ray_log("width=" .. rc:width())
    ray_log("sample cell=" .. rc:getCell(10, 10))
    ray_log("sample blocked=" .. tostring(rc:isBlocked(10, 10)))
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
| boolean | True if the cell blocks render rays. |

**Example**

```lua
do
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.raycaster.new(8, 8)
    map:setCell(3, 3, 1)
    map:setCell(4, 3, 2)
    ray_log("cell(3,3) blocked=" .. tostring(map:isBlocked(3, 3)))
    ray_log("cell(4,3) blocked=" .. tostring(map:isBlocked(4, 3)))
    ray_log("cell(2,2) blocked=" .. tostring(map:isBlocked(2, 2)))
    ray_log("wall values remain render input")
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    half_map:setWallFeatureCell(7, 5, { kind = "half", height = 0.5 })
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
        example_print_log("surface = " .. hit.surface)
        example_print_log("cell = " .. hit.x .. "," .. hit.y)
        example_print_log("distance = " .. string.format("%.2f", hit.distance))
        example_print_log("hit = " .. string.format("%.2f", hit.hit_x) .. "," .. string.format("%.2f", hit.hit_y))
        example_print_log("ray angle = " .. string.format("%.3f", hit.ray_angle))
        example_print_log("uv = " .. string.format("%.2f", hit.u) .. "," .. string.format("%.2f", hit.v))
    end
    if sprite_hit then
        example_print_log("sprite surface = " .. sprite_hit.surface)
        example_print_log("sprite id = " .. tostring(sprite_hit.id))
        example_print_log("sprite distance = " .. string.format("%.2f", sprite_hit.distance))
        example_print_log("sprite uv = " .. string.format("%.2f", sprite_hit.u) .. "," .. string.format("%.2f", sprite_hit.v))
    end
    if model_hit then
        example_print_log("model surface = " .. model_hit.surface)
        example_print_log("model id = " .. tostring(model_hit.id))
        example_print_log("model distance = " .. string.format("%.2f", model_hit.distance))
        example_print_log("model uv = " .. string.format("%.2f", model_hit.u) .. "," .. string.format("%.2f", model_hit.v))
    end
    if feature_hit and feature_hit.feature then
        example_print_log("feature kind = " .. feature_hit.feature.kind)
        example_print_log("feature section = " .. feature_hit.feature.section)
        example_print_log("feature wall height = " .. string.format("%.2f", feature_hit.wall_height))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
        example_print_log("adapter pick id = " .. tostring(hit.id))
        example_print_log("adapter pick point = " .. string.format("%.2f,%.2f", hit.hit_x, hit.hit_y))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.raycaster.new(16, 16)
    local proj = map:projectSprite(10, 8, 8, 8, 0, math.pi / 3, 320)

    example_print_log("screen_x = " .. proj.screen_x)
    example_print_log("scale = " .. string.format("%.2f", proj.scale))
    example_print_log("visible = " .. tostring(proj.visible))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.raycaster.new(8, 8)
    local ceil_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    map:setCeilingTextureCell(2, 2, ceil_tex)
    map:setCeilingTextureCell(2, 3, ceil_tex)
    ray_log("setCeilingTextureCell raw id=" .. tostring(map:getCeilingTextureCell(2, 2)))
    ray_log("neighbor raw id=" .. tostring(map:getCeilingTextureCell(2, 3)))
    ray_log("empty raw id=" .. tostring(map:getCeilingTextureCell(0, 0)))
    ray_log("ceiling texture cells assigned for room")
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.raycaster.new(8, 8)
    map:setCell(0, 0, 1)
    map:setCell(1, 0, 2)
    ray_log("cell(0,0)=" .. map:getCell(0, 0))
    ray_log("cell(1,0)=" .. map:getCell(1, 0))
    ray_log("blocked corner=" .. tostring(map:isBlocked(0, 0)))
    ray_log("blocked neighbor=" .. tostring(map:isBlocked(1, 0)))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.raycaster.new(8, 8)
    local cells = {}

    for i = 1, 64 do
        cells[i] = 0
    end

    for i = 1, 8 do
        cells[i] = 1
    end

    map:setCells(cells)
    example_print_log("cell(0,0) = " .. map:getCell(0, 0))
    example_print_log("cell(0,1) = " .. map:getCell(0, 1))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.raycaster.new(8, 8)
    local floor_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    map:setFloorTextureCell(3, 3, floor_tex)
    map:setFloorTextureCell(4, 3, floor_tex)
    ray_log("setFloorTextureCell raw id=" .. tostring(map:getFloorTextureCell(3, 3)))
    ray_log("neighbor raw id=" .. tostring(map:getFloorTextureCell(4, 3)))
    ray_log("empty raw id=" .. tostring(map:getFloorTextureCell(0, 0)))
    ray_log("floor texture cells assigned for corridor")
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

    example_print_log("depth = " .. cell.depth)
    example_print_log("blocked = " .. tostring(cell.blocked))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.raycaster.new(8, 8)
    map:setWallAlpha(2, 0.5)
    map:setCell(3, 3, 2)
    local alpha = map:getWallAlpha(2)
    ray_log("setWallAlpha tile=2")
    ray_log("alpha(2)=" .. tostring(alpha))
    ray_log("cell(3,3)=" .. map:getCell(3, 3))
    ray_log("tile remains blocked=" .. tostring(map:isBlocked(3, 3)))
end
```

---

#### `LRaycaster:setWallFeatureCell`

Attaches a render-only wall feature descriptor to a blocking cell.

```lua
LRaycaster:setWallFeatureCell(x, y, feature)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Grid column. |
| `y` | number | Grid row. |
| `feature` | table|Feature | "door", ...}. |

**Example**

```lua
do
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.raycaster.new(8, 8)
    map:setCell(3, 3, 1)
    map:setWallFeatureCell(3, 3, { kind = "window", sill_height = 0.25, lintel_height = 0.75, alpha = 0.4 })
    local feature = map:getWallFeatureCell(3, 3)

    example_print_log("feature kind = " .. feature.kind)
    example_print_log("feature alpha = " .. string.format("%.2f", feature.alpha))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.raycaster.new(8, 8)
    map:setCell(1, 1, 1)
    local type_name = map:type()
    ray_log("type=" .. type_name)
    ray_log("width=" .. map:width())
    ray_log("height=" .. map:height())
    ray_log("sample cell=" .. map:getCell(1, 1))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.raycaster.new(8, 8)
    map:setCell(2, 2, 1)
    ray_log("LRaycaster=" .. tostring(map:typeOf("LRaycaster")))
    ray_log("LObject=" .. tostring(map:typeOf("LObject")))
    ray_log("LSceneAdapter=" .. tostring(map:typeOf("LSceneAdapter")))
    ray_log("sample cell=" .. map:getCell(2, 2))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rc = lurek.raycaster.new(160, 120)
    rc:setCell(12, 12, 2)
    ray_log("width=" .. rc:width())
    ray_log("height=" .. rc:height())
    ray_log("sample cell=" .. rc:getCell(12, 12))
    ray_log("sample blocked=" .. tostring(rc:isBlocked(12, 12)))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local adapter = lurek.raycaster.newSceneAdapter()
    local tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    adapter:addDirectionalSprite(6.0, 3.5, tex, tex, tex, tex, {
        id = 32,
        level = 1,
        size = 1.0,
        angle = math.pi / 4,
    })
    local sprite = adapter:sceneInputs().sprites[1]
    example_print_log("directional front tex = " .. tostring(sprite.front_texture))
    example_print_log("directional angle = " .. string.format("%.3f", sprite.angle))
end
```

---

#### `LSceneAdapter:addLight`

Adds a static point light entry to the adapter.

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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:addLight(5.0, 3.5, 4.0, {
        intensity = 1.1,
        color = { 1.0, 0.7, 0.4 },
        level = 1,
    })
    local light = adapter:sceneInputs().lights[1]
    example_print_log("static light radius = " .. light.radius)
    example_print_log("static light intensity = " .. light.intensity)
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local adapter = lurek.raycaster.newSceneAdapter()
    local tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    adapter:addModel(
        lurek.render.loadModel("content/examples/assets/models/sample_tank.obj"),
        7.0,
        3.5,
        { id = 33, level = 1, yaw = 0.3, z = 0.1, scale = 0.2 }
    )
    local model = adapter:sceneInputs().models[1]
    example_print_log("static model id = " .. model.id)
    example_print_log("static model yaw = " .. string.format("%.2f", model.yaw))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:addSprite(
        4.5,
        3.5,
        lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        { id = 31, level = 1, size = 1.2 }
    )
    local sprite = adapter:sceneInputs().sprites[1]
    example_print_log("static sprite id = " .. sprite.id)
    example_print_log("static sprite pos = " .. string.format("%.2f,%.2f", sprite.x, sprite.y))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    example_print_log("body directional id = " .. sprite.id)
    example_print_log("body directional pos = " .. string.format("%.2f,%.2f", sprite.x, sprite.y))
    example_print_log("body directional angle = " .. string.format("%.3f", sprite.angle))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(2.0, 2.0, "dynamic")
    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:bindBodyLight(body, 3.0, { intensity = 0.8, offset_y = 0.25 })
    body:setPosition(3.0, 2.0)
    local light = adapter:sceneInputs().lights[1]
    example_print_log("body light pos = " .. string.format("%.2f,%.2f", light.x, light.y))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    example_print_log("body model yaw = " .. string.format("%.2f", model.yaw))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    example_print_log("body sprite pos = " .. string.format("%.2f,%.2f", sprite.x, sprite.y))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local adapter = lurek.raycaster.newSceneAdapter()
    local tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    adapter:addSprite(1.0, 1.0, tex)
    adapter:addLight(1.0, 1.0, 2.0)
    adapter:addModel(lurek.render.loadModel("content/examples/assets/models/sample_tank.obj"), 1.0, 1.0)
    adapter:clear()
    example_print_log("adapter cleared sprites = " .. #adapter:sceneInputs().sprites)
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:addLight(1.0, 1.0, 2.0)
    adapter:addLight(2.5, 1.0, 3.0, { intensity = 0.6, color = { 0.8, 0.9, 1.0 } })
    adapter:clearLights()
    local inputs = adapter:sceneInputs()
    ray_log("clearLights light count=" .. #inputs.lights)
    ray_log("clearLights sprite count=" .. #inputs.sprites)
    ray_log("clearLights model count=" .. #inputs.models)
end
```

---

#### `LSceneAdapter:clearModels`

Clears all loaded model entries from the adapter.

```lua
LSceneAdapter:clearModels()
```

**Example**

```lua
do
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:addModel(lurek.render.loadModel("content/examples/assets/models/sample_tank.obj"), 1.0, 1.0)
    adapter:addModel(lurek.render.loadModel("content/examples/assets/models/sample_tank.obj"), 2.0, 1.0, { id = 90 })
    adapter:clearModels()
    local inputs = adapter:sceneInputs()
    ray_log("clearModels model count=" .. #inputs.models)
    ray_log("clearModels sprite count=" .. #inputs.sprites)
    ray_log("clearModels light count=" .. #inputs.lights)
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:addSprite(
        1.0,
        1.0,
        lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    )
    adapter:clearSprites()
    example_print_log("adapter sprite count = " .. #adapter:sceneInputs().sprites)
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local adapter = lurek.raycaster.newSceneAdapter()
    local tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    adapter:addSprite(4.5, 3.5, tex, { id = 31, level = 1, size = 1.2 })
    adapter:addLight(5.0, 3.5, 4.0, {
        intensity = 1.1,
        color = { 1.0, 0.7, 0.4 },
        level = 1,
    })
    local inputs = adapter:sceneInputs()
    example_print_log("sceneInputs sprites = " .. #inputs.sprites)
    example_print_log("sceneInputs lights = " .. #inputs.lights)
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:addSprite(1.5, 2.5, lurek.render.newImage("content/examples/assets/images/sample_texture.png"), { id = 41 })
    ray_log("adapter type=" .. adapter:type())
    ray_log("adapter has sprites=" .. #adapter:sceneInputs().sprites)
    ray_log("adapter is scene adapter=" .. tostring(adapter:typeOf("LSceneAdapter")))
    ray_log("adapter models=" .. #adapter:sceneInputs().models)
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:addLight(4.0, 4.0, 3.0, { intensity = 1.0, color = { 1.0, 0.7, 0.4 } })
    ray_log("LSceneAdapter=" .. tostring(adapter:typeOf("LSceneAdapter")))
    ray_log("LObject=" .. tostring(adapter:typeOf("LObject")))
    ray_log("LSpriteManager=" .. tostring(adapter:typeOf("LSpriteManager")))
    ray_log("light snapshot=" .. #adapter:sceneInputs().lights)
end
```

---

## LShader

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LShader:getDiagnostics`

Returns shader validation diagnostics.

```lua
LShader:getDiagnostics()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Array of diagnostic strings. |

---

#### `LShader:getId`

Returns the internal numeric handle ID for this shader.

```lua
LShader:getId()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Opaque shader handle identifier. |

---

#### `LShader:getTarget`

Returns the target this shader was validated for.

```lua
LShader:getTarget()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Shader target name. |

---

#### `LShader:hasUniform`

Checks whether this shader declares a uniform with the given name.

```lua
LShader:hasUniform(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Uniform name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the uniform exists. |

---

#### `LShader:release`

Releases the shader resource. If active, the default shader is restored.

```lua
LShader:release()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the shader was valid and was released. |

---

#### `LShader:send`

Sends a uniform value to this shader by name. Supported types: number, boolean, or table (vec2/vec3/vec4).

```lua
LShader:send(name, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Uniform variable name declared in the shader. |
| `value` | number|boolean|table | The value to send. |

---

#### `LShader:type`

Returns the type name string for this shader object.

```lua
LShader:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always "[LShader](#lshader)". |

---

#### `LShader:typeOf`

Checks whether this object matches the given type name.

```lua
LShader:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check ("Shader" or "Object"). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the name matches. |

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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sm = lurek.raycaster.newSpriteManager()
    local id = sm:add(5, 5, "content/examples/assets/images/sample_texture.png", 1.0)
    local projected = sm:sortAndProject(0, 0, 0)
    ray_log("sprite id=" .. id)
    ray_log("projected count=" .. #projected)
    ray_log("first x=" .. tostring(projected[1] and projected[1].x))
    ray_log("first y=" .. tostring(projected[1] and projected[1].y))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

    example_print_log("sprite id = " .. id)
    example_print_log("texture = " .. order[1].texture)
    example_print_log("variant = " .. tostring(order[1].variant))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sprites = lurek.raycaster.newSpriteManager()
    sprites:add(1, 1, "content/examples/assets/images/sample_texture.png")
    sprites:add(2, 2, "content/examples/assets/images/sample_texture.png")
    sprites:clear()

    local order = sprites:sortAndProject(0, 0, 0)

    example_print_log("projected count = " .. #order)
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sm = lurek.raycaster.newSpriteManager()
    local id = sm:add(5, 5, "content/examples/assets/images/sample_texture.png", 1.0)
    sm:remove(id)

    local projected = sm:sortAndProject(0, 0, 0)

    example_print_log("remaining projected = " .. #projected)
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sprites = lurek.raycaster.newSpriteManager()
    local id = sprites:add(2.0, 0.0, "old.png", 1.0)
    sprites:setDirectionalTextures(id, "front2.png", "right2.png", "back2.png", "left2.png", math.pi)
    local order = sprites:sortAndProject(0, 0, 0)

    example_print_log("texture = " .. order[1].texture)
    example_print_log("variant = " .. tostring(order[1].variant))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sprites = lurek.raycaster.newSpriteManager()
    local id = sprites:addDirectional(2.0, 0.0, "front.png", "right.png", "back.png", "left.png", math.pi, 1.0)
    sprites:setFacing(id, 0.0)
    local order = sprites:sortAndProject(0, 0, 0)

    example_print_log("texture = " .. order[1].texture)
    example_print_log("variant = " .. tostring(order[1].variant))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sm = lurek.raycaster.newSpriteManager()
    local id = sm:add(5, 5, "content/examples/assets/images/sample_texture.png", 1.0)
    sm:setLevel(id, 2)

    local projected = sm:sortAndProject(0, 0, 0)

    example_print_log("level = " .. tostring(projected[1].level))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sm = lurek.raycaster.newSpriteManager()
    local id = sm:add(5, 5, "content/examples/assets/images/sample_texture.png", 1.0)
    sm:setPosition(id, 6, 6)

    local projected = sm:sortAndProject(0, 0, 0)

    example_print_log("first x = " .. projected[1].x)
    example_print_log("first y = " .. projected[1].y)
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sm = lurek.raycaster.newSpriteManager()
    local id = sm:add(5, 5, "content/examples/assets/images/sample_texture.png", 1.0)
    sm:setVisible(id, false)

    local projected = sm:sortAndProject(0, 0, 0)

    example_print_log("projected count = " .. #projected)
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sprites = lurek.raycaster.newSpriteManager()
    sprites:add(3, 3, "content/examples/assets/images/sample_texture.png")
    sprites:add(6, 6, "content/examples/assets/images/sample_texture.png")
    sprites:add(9, 9, "content/examples/assets/images/sample_texture.png")

    local order = sprites:sortAndProject(5, 5, 0)

    example_print_log("projected count = " .. #order)
    if order[1] then
        example_print_log("first id = " .. order[1].id)
        example_print_log("first distance = " .. string.format("%.2f", order[1].distance))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sprites = lurek.raycaster.newSpriteManager()
    local id = sprites:add(3.5, 2.5, "content/examples/assets/images/sample_texture.png", 1.0)
    ray_log("sprite manager type=" .. sprites:type())
    ray_log("projected count=" .. #sprites:sortAndProject(0, 0, 0))
    ray_log("typeOf sprite manager=" .. tostring(sprites:typeOf("LSpriteManager")))
    ray_log("first sprite id=" .. tostring(id))
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
    local function ray_log(message)
        lurek.log.info("[raycaster.example] " .. tostring(message))
    end
    local function build_walled_ray_map(width, height)
        local map = lurek.raycaster.new(width, height)
        for x = 0, width - 1 do
            map:setCell(x, 0, 1)
            map:setCell(x, height - 1, 1)
        end
        for y = 0, height - 1 do
            map:setCell(0, y, 1)
            map:setCell(width - 1, y, 1)
        end
        return map
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sprites = lurek.raycaster.newSpriteManager()
    local id = sprites:add(4.0, 1.0, "content/examples/assets/images/sample_texture.png", 0.75, 1)
    ray_log("LSpriteManager=" .. tostring(sprites:typeOf("LSpriteManager")))
    ray_log("LObject=" .. tostring(sprites:typeOf("LObject")))
    ray_log("LSceneAdapter=" .. tostring(sprites:typeOf("LSceneAdapter")))
    ray_log("visible sprite id=" .. tostring(id))
end
```

---

## LTileField

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LTileField:applyModifier`

Applies a named modifier to one cell.

```lua
LTileField:applyModifier(x, y, z, modifier)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `modifier` | string | Modifier name. |

---

#### `LTileField:applyProfile`

Applies a legacy profile to one cell.

```lua
LTileField:applyProfile(x, y, z, profile)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `profile` | string | Profile name. |

---

#### `LTileField:applyTilesetObject`

Applies the object archetype defaults for a tileset tile referenced from one cell.

```lua
LTileField:applyTilesetObject(x, y, z, slot, tileset, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `slot` | string | Reference slot name. |
| `tileset` | [LTileSet](tileset.md#ltileset) | Tileset that stores object archetype metadata. |
| `opts?` | table | Options: refIsGid. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the tileset object was found and applied. |

---

#### `LTileField:applyTilesetObjectLayer`

Applies tileset object defaults for every referenced cell on one tilefield level.

```lua
LTileField:applyTilesetObjectLayer(slot, tileset, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `slot` | string | Reference slot name. |
| `tileset` | [LTileSet](tileset.md#ltileset) | Tileset that stores object metadata. |
| `opts?` | table | Options: z, refIsGid. |

**Returns**

| Type | Description |
|------|-------------|
| number | Number of cells that received object defaults. |

---

#### `LTileField:blocks`

Returns whether a cell blocks a channel.

```lua
LTileField:blocks(x, y, z, channel)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `channel` | string | Blocker channel name to query. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the addressed cell blocks the channel. |

---

#### `LTileField:blocksCategory`

Returns whether one cell blocks a category.

```lua
LTileField:blocksCategory(x, y, z, category)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `z?` | any |  |
| `category` | any |  |

---

#### `LTileField:clear`

Clears all cell gameplay state.

```lua
LTileField:clear()
```

---

#### `LTileField:clearCell`

Clears gameplay state for one addressed cell.

```lua
LTileField:clearCell(x, y, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |

---

#### `LTileField:clearLine`

Returns true when the line between two cell tables has no blocker for a channel.

```lua
LTileField:clearLine(from_tbl, to_tbl, channel, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from_tbl` | table | Start cell table with one-based x, y, and optional z fields. |
| `to_tbl` | table | End cell table with one-based x, y, and optional z fields. |
| `channel` | string | Blocker channel name to test along the line. |
| `opts?` | table | Reserved optional line query options. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when no blocker exists between the two cells. |

---

#### `LTileField:clearModifier`

Removes one modifier from one cell.

```lua
LTileField:clearModifier(x, y, z, modifier)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `modifier` | string | Modifier name. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the cell had the modifier. |

---

#### `LTileField:clearRef`

Clears a named object/tile reference from one cell.

```lua
LTileField:clearRef(x, y, z, slot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `slot` | string | Reference slot name. |

---

#### `LTileField:defineCategory`

Defines or replaces a user category used by movement, awareness, light, sun, or custom systems.

```lua
LTileField:defineCategory(name, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Stable category name. |
| `opts?` | table?|Options | custom', active=true?. |

---

#### `LTileField:defineSlot`

Defines a named object slot that cells may reference.

```lua
LTileField:defineSlot(slot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `slot` | string | Slot name chosen by the Lua game. |

---

#### `LTileField:exportBlockLayer`

Exports one blocker channel and level as a row-major boolean array.

```lua
LTileField:exportBlockLayer(channel, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `channel` | string | Blocker channel name to export. |
| `z?` | number | One-based level, default 1. |

**Returns**

| Type | Description |
|------|-------------|
| table | Row-major boolean array for the requested channel and level. |

---

#### `LTileField:exportCostLayer`

Exports one cost channel and level as a row-major number array.

```lua
LTileField:exportCostLayer(channel, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `channel` | string | Cost channel name to export. |
| `z?` | number | One-based level, default 1. |

**Returns**

| Type | Description |
|------|-------------|
| table | Row-major number array for the requested channel and level. |

---

#### `LTileField:exportRefLayer`

Exports one named object/tile reference slot and level as a row-major array.

```lua
LTileField:exportRefLayer(slot, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `slot` | string | Reference slot name to export. |
| `z?` | number | One-based level, default 1. |

---

#### `LTileField:firstBlocker`

Returns the first one-based blocking cell table between two cells, or nil.

```lua
LTileField:firstBlocker(from_tbl, to_tbl, channel, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from_tbl` | table | Start cell table with one-based x, y, and optional z fields. |
| `to_tbl` | table | End cell table with one-based x, y, and optional z fields. |
| `channel` | string | Blocker channel name to test along the line. |
| `opts?` | table | Reserved optional line query options. |

**Returns**

| Type | Description |
|------|-------------|
| table | nil | First blocking cell table, or nil when the line is clear. |

---

#### `LTileField:footprintPassable`

Returns whether a rectangular footprint can occupy a cell anchor for a category.

```lua
LTileField:footprintPassable(x, y, z, w, h, category)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `z?` | any |  |
| `w` | any |  |
| `h` | any |  |
| `category` | any |  |

---

#### `LTileField:getCategories`

Returns known category names.

```lua
LTileField:getCategories()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Sorted category names. |

---

#### `LTileField:getCategory`

Returns category metadata, or nil when the category is unknown.

```lua
LTileField:getCategory(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Category name. |

**Returns**

| Type | Description |
|------|-------------|
| table | nil | Category table with name, kind, and active. |

---

#### `LTileField:getCategoryCost`

Returns one effective category cost.

```lua
LTileField:getCategoryCost(x, y, z, category)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `z?` | any |  |
| `category` | any |  |

---

#### `LTileField:getCategoryFilter`

Returns one effective RGB category filter.

```lua
LTileField:getCategoryFilter(x, y, z, category)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `z?` | any |  |
| `category` | any |  |

---

#### `LTileField:getCategoryTransmission`

Returns one effective category transmission multiplier.

```lua
LTileField:getCategoryTransmission(x, y, z, category)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `z?` | any |  |
| `category` | any |  |

---

#### `LTileField:getCell`

Returns a table with blockers, costs, sun occlusion, refs, and modifiers.

```lua
LTileField:getCell(x, y, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |

**Returns**

| Type | Description |
|------|-------------|
| table | Cell state table. |

---

#### `LTileField:getCost`

Returns the cost for one cell/channel.

```lua
LTileField:getCost(x, y, z, channel)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `channel` | string | Cost channel name to query. |

**Returns**

| Type | Description |
|------|-------------|
| number | Movement or traversal cost value. |

---

#### `LTileField:getModifier`

Returns a named tile modifier table, or nil.

```lua
LTileField:getModifier(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Modifier name. |

**Returns**

| Type | Description |
|------|-------------|
| table | nil | Modifier table. |

---

#### `LTileField:getModifiers`

Returns active modifier names on one cell.

```lua
LTileField:getModifiers(x, y, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |

**Returns**

| Type | Description |
|------|-------------|
| string[] | Active modifier names. |

---

#### `LTileField:getNeighbors`

Returns topology-aware same-level neighbours for one cell.

```lua
LTileField:getNeighbors(x, y, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of one-based coordinate tables. |

---

#### `LTileField:getProfile`

Returns a legacy profile table, or nil.

```lua
LTileField:getProfile(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Profile name. |

**Returns**

| Type | Description |
|------|-------------|
| table | nil | Profile table. |

---

#### `LTileField:getRef`

Returns a named object/tile reference from one cell, or nil.

```lua
LTileField:getRef(x, y, z, slot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `slot` | string | Reference slot name. |

**Returns**

| Type | Description |
|------|-------------|
| number | table|nil | Stored legacy id, typed ref table, or nil when unset. |

---

#### `LTileField:getRefProperties`

Reads all tileset properties for a tile referenced from one cell.

```lua
LTileField:getRefProperties(x, y, z, slot, tileset, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `slot` | string | Reference slot name. |
| `tileset` | [LTileSet](tileset.md#ltileset) | Tileset that stores object metadata. |
| `opts?` | table | Options: refIsGid. |

**Returns**

| Type | Description |
|------|-------------|
| table | nil | Property name/value table, or nil when the ref is missing/outside the tileset. |

---

#### `LTileField:getRefProperty`

Reads a tileset property for a tile referenced from one cell.

```lua
LTileField:getRefProperty(x, y, z, slot, tileset, property, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `slot` | string | Reference slot name. |
| `tileset` | [LTileSet](tileset.md#ltileset) | Tileset that stores object metadata. |
| `property` | string | Property name to read. |
| `opts?` | table | Options: refIsGid. |

**Returns**

| Type | Description |
|------|-------------|
| string | nil | Property value, or nil when missing. |

---

#### `LTileField:getRefPropertyBool`

Reads a tileset property for a tile referenced from one cell and parses it as a boolean.

```lua
LTileField:getRefPropertyBool(x, y, z, slot, tileset, property, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `slot` | string | Reference slot name. |
| `tileset` | [LTileSet](tileset.md#ltileset) | Tileset that stores object metadata. |
| `property` | string | Property name to read. |
| `opts?` | table | Options: refIsGid. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | nil | Boolean property value, or nil when missing/not boolean. |

---

#### `LTileField:getRefPropertyNumber`

Reads a tileset property for a tile referenced from one cell and parses it as a number.

```lua
LTileField:getRefPropertyNumber(x, y, z, slot, tileset, property, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `slot` | string | Reference slot name. |
| `tileset` | [LTileSet](tileset.md#ltileset) | Tileset that stores object metadata. |
| `property` | string | Property name to read. |
| `opts?` | table | Options: refIsGid. |

**Returns**

| Type | Description |
|------|-------------|
| number | nil | Numeric property value, or nil when missing/not numeric. |

---

#### `LTileField:getRefSlots`

Returns every declared ref slot.

```lua
LTileField:getRefSlots()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Ref slot names. |

---

#### `LTileField:getRegionCells`

Returns one-based cells for a named region, or nil when it does not exist.

```lua
LTileField:getRegionCells(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Region name. |

**Returns**

| Type | Description |
|------|-------------|
| table? | Array of `{ x, y, z }` cells. |

---

#### `LTileField:getRegionNames`

Returns all region names in stable order.

```lua
LTileField:getRegionNames()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Array of region names. |

---

#### `LTileField:getSize`

Returns field width, height, and level count.

```lua
LTileField:getSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Field width in cells. |
| number | Field height in cells. |
| number | Level count. |

---

#### `LTileField:getSunOcclusion`

Returns top-light occlusion in the inclusive range 0..1.

```lua
LTileField:getSunOcclusion(x, y, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |

**Returns**

| Type | Description |
|------|-------------|
| number | Top-light occlusion value in the inclusive range 0..1. |

---

#### `LTileField:getTopology`

Returns the field topology name used for coordinate interpretation.

```lua
LTileField:getTopology()
```

**Returns**

| Type | Description |
|------|-------------|
| string | `square`, `square4`, `square8`, `iso_square`, or `hex`. |

---

#### `LTileField:getVersion`

Returns the current tilefield data version.

```lua
LTileField:getVersion()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Monotonic field version incremented by data mutations. |

---

#### `LTileField:hasSlot`

Returns true when a named object slot is declared.

```lua
LTileField:hasSlot(slot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `slot` | string | Slot name. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when declared. |

---

#### `LTileField:inBounds`

Returns whether one-based coordinates are inside the field.

```lua
LTileField:inBounds(x, y, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when coordinates are in bounds. |

---

#### `LTileField:line`

Returns topology-aware one-based cells between `from` and `to` tables.

```lua
LTileField:line(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | table | `{from={x,y,z?}, to={x,y,z?}, includeEndpoints?}`. |

---

#### `LTileField:regionContains`

Returns whether a named region contains a one-based tile cell.

```lua
LTileField:regionContains(name, x, y, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Region name. |
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the region contains the cell. |

---

#### `LTileField:removeModifier`

Removes a named modifier and clears it from all cells.

```lua
LTileField:removeModifier(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Modifier name. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when removed. |

---

#### `LTileField:removeProfile`

Removes a legacy profile and clears it from all cells.

```lua
LTileField:removeProfile(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Profile name. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when removed. |

---

#### `LTileField:removeRegion`

Removes a named region.

```lua
LTileField:removeRegion(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Region name. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the region existed. |

---

#### `LTileField:removeSlot`

Removes a named object slot and clears its references from the field.

```lua
LTileField:removeSlot(slot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `slot` | string | Slot name. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the slot existed. |

---

#### `LTileField:setBlock`

Sets whether a cell blocks a channel.

```lua
LTileField:setBlock(x, y, z, channel, blocked)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `channel` | string | Blocker channel name to update. |
| `blocked` | boolean | True when the channel should be blocked. |

---

#### `LTileField:setCategoryBlock`

Sets one category blocker on one cell.

```lua
LTileField:setCategoryBlock(x, y, z, category, blocked)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `z?` | any |  |
| `category` | any |  |
| `blocked` | any |  |

---

#### `LTileField:setCategoryCost`

Sets one category cost on one cell.

```lua
LTileField:setCategoryCost(x, y, z, category, cost)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `z?` | any |  |
| `category` | any |  |
| `cost` | any |  |

---

#### `LTileField:setCategoryFilter`

Sets one RGB category filter on one cell.

```lua
LTileField:setCategoryFilter(x, y, z, category, filter)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `z?` | any |  |
| `category` | any |  |
| `filter` | any |  |

---

#### `LTileField:setCategoryTransmission`

Sets one category transmission multiplier on one cell.

```lua
LTileField:setCategoryTransmission(x, y, z, category, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `z?` | any |  |
| `category` | any |  |
| `value` | any |  |

---

#### `LTileField:setCell`

Sets cell state from a table with optional `blocks`, `costs`, `sunOcclusion`, `refs`, and `modifiers`.

```lua
LTileField:setCell(x, y, z, cell)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `cell` | table | Cell data. |

---

#### `LTileField:setCost`

Sets the cost for one cell/channel.

```lua
LTileField:setCost(x, y, z, channel, cost)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `channel` | string | Cost channel name to update. |
| `cost` | number | Movement or traversal cost value. |

---

#### `LTileField:setModifier`

Registers or replaces a named tile modifier.

```lua
LTileField:setModifier(name, modifier)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Modifier name. |
| `modifier` | table | Modifier table with blocks, costAdd, costMul, sunOcclusionAdd, light, properties. |

---

#### `LTileField:setProfile`

Registers or replaces a legacy tilefield profile.

```lua
LTileField:setProfile(name, profile)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Profile name. |
| `profile` | table | Profile table with blocks, costs, sunOcclusion, light, or properties. |

---

#### `LTileField:setRef`

Sets a named object/tile reference on one cell.

```lua
LTileField:setRef(x, y, z, slot, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `slot` | string | Reference slot name defined by the Lua game. |
| `value` | number|table | Legacy id or typed `{ tileset, tile?/object? }` ref stored for the slot. |

---

#### `LTileField:setRegionCells`

Defines or replaces a named region from explicit one-based tile cells.

```lua
LTileField:setRegionCells(name, cells)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Region name. |
| `cells` | table | Array of `{ x, y, z? }` cells. |

---

#### `LTileField:setRegionRect`

Defines or replaces a named region from an inclusive one-based tile rectangle.

```lua
LTileField:setRegionRect(name, x1, y1, x2, y2, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Region name. |
| `x1` | number | First one-based column. |
| `y1` | number | First one-based row. |
| `x2` | number | Second one-based column. |
| `y2` | number | Second one-based row. |
| `z?` | number | One-based level, default 1. |

---

#### `LTileField:setSunOcclusion`

Sets top-light occlusion in the inclusive range 0..1.

```lua
LTileField:setSunOcclusion(x, y, z, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `value` | number | Top-light occlusion value in the inclusive range 0..1. |

---

#### `LTileField:type`

Returns the Lua-visible type name for this tilefield handle.

```lua
LTileField:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LTileField](#ltilefield)`. |

---

#### `LTileField:typeOf`

Returns whether this handle matches a supported type name.

```lua
LTileField:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True for `[LTileField](#ltilefield)` or `LObject`. |

---

#### `LTileField:writeBlockLayer`

Writes one full blocker channel layer from a row-major boolean array.

```lua
LTileField:writeBlockLayer(channel, z, values)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `channel` | string | Blocker channel name to write. |
| `z?` | number | One-based level, default 1. |
| `values` | table | Row-major boolean array with width*height entries. |

---

#### `LTileField:writeCostLayer`

Writes one full cost channel layer from a row-major number array.

```lua
LTileField:writeCostLayer(channel, z, values)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `channel` | string | Cost channel name to write. |
| `z?` | number | One-based level, default 1. |
| `values` | table | Row-major number array with width*height entries. |

---

#### `LTileField:writeRefLayer`

Writes one full named ref layer from a row-major integer-or-nil array.

```lua
LTileField:writeRefLayer(slot, z, values)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `slot` | string | Reference slot name to write. |
| `z?` | number | One-based level, default 1. |
| `values` | table | Row-major integer-or-nil array with width*height entries. |

---
