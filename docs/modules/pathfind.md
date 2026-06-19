# Pathfind

## Summary

- The `pathfind` module is the engine's navigation and movement-analysis surface for users who need more than one hard-coded shortest-path helper.
- It supports several spatial models at once, including weighted grids, hex and isometric spaces, province-style graphs, influence fields, and other routing abstractions, so different worlds can still share one navigation family.
- A* is only part of the surface. The module also covers bidirectional search, Jump Point Search, hierarchical routing, graph travel, flow fields, influence maps, and reachability-style analysis under one subsystem.
- This breadth matters because movement questions differ dramatically across features. Some systems need one precise route, others need shared guidance, tactical pressure, move ranges, or background jobs for expensive searches.
- That makes the module useful not only for point-to-point travel but also for squad guidance, threat-aware movement, logistics overlays, and strategic map reasoning where spatial scoring matters.
- Async search support is especially important because pathfinding is often one of the first systems that must leave the main loop without losing an engine-owned, script-facing API.
- Shared abstractions for grids and graph-like inputs reduce adapter overhead and make it easier for a project to compare algorithms without rewriting all navigation data plumbing.
- Range and reachability helpers are as important as final path extraction. Many systems need to know where a unit could move, what lies inside a budget, or which cells are effectively controlled before they need an explicit route.
- Influence and shared-field helpers broaden the module into tactical analysis. Movement is not only about reaching a goal; it is also about preferring safe zones, avoiding danger, or flowing several actors in roughly the same direction.
- Because several world models can feed the same pathfinding family, projects can evolve from simple grid routing to richer graph or field-based navigation without abandoning the same conceptual subsystem.
- That flexibility is one of the main reasons the module exists as a family rather than as one algorithm wrapper: different gameplay scales can still share one navigation vocabulary.
- Cost rules are part of that vocabulary too. Terrain penalties, danger zones, ownership boundaries, and temporary blockers can all be expressed as navigation data instead of being bolted on after a path is returned.
- This helps projects keep route quality and tactical intent aligned, because the same system can explain not only where an actor can go, but why one route is preferred over another.
- The module is also valuable when several agents share the same traversability model but need different routing policies over it.
- That makes `pathfind` a planning layer, not only a shortest-path helper.
- Debug and visualization helpers matter because navigation bugs usually come from topology, weights, or blocked-space assumptions rather than from the solver implementation alone.
- `tilemap`, `province`, and related modules define traversable space, but `pathfind` owns how that space is searched, scored, and turned into movement advice.
- Read `pathfind` as the reusable navigation layer of the engine, not as a locomotion or animation system.

## Functions

### `lurek.pathfind.cancelAsyncPath`

Marks an async path request as cancelled.

```lua
lurek.pathfind.cancelAsyncPath(request_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `request_id` | number | Request id returned by `submitAsyncPath`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | Always true once the cancel marker is recorded. |

**Example**

```lua
do
    lurek.pathfind.clearAsyncPaths()
    local nav = lurek.pathfind.newNavGrid(24, 24)
    local request_id = lurek.pathfind.submitAsyncPath(nav, {
        start_x = 1,
        start_y = 1,
        goal_x = 24,
        goal_y = 24,
        stream_budget = 4,
    })
    example_print_log("cancelled = " .. tostring(lurek.pathfind.cancelAsyncPath(request_id)))
end
```

---

### `lurek.pathfind.clearAsyncPaths`

Drops all queued async path requests and recreates the worker pool with the configured thread count.

```lua
lurek.pathfind.clearAsyncPaths()
```

**Example**

```lua
do
    lurek.pathfind.clearAsyncPaths()
    local nav = lurek.pathfind.newNavGrid(12, 12)
    lurek.pathfind.submitAsyncPath(nav, {
        start_x = 1,
        start_y = 1,
        goal_x = 12,
        goal_y = 12,
        stream_budget = 2,
    })
    lurek.pathfind.clearAsyncPaths()
    example_print_log("pending = " .. tostring(lurek.pathfind.getAsyncPendingCount()))
end
```

---

### `lurek.pathfind.getAsyncPendingCount`

Returns the number of async path requests that have not emitted a terminal event.

```lua
lurek.pathfind.getAsyncPendingCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Pending async request count. |

**Example**

```lua
do
    lurek.pathfind.clearAsyncPaths()
    local before = lurek.pathfind.getAsyncPendingCount()
    local nav = lurek.pathfind.newNavGrid(12, 12)
    lurek.pathfind.submitAsyncPath(nav, {
        start_x = 1,
        start_y = 1,
        goal_x = 12,
        goal_y = 12,
        stream_budget = 2,
    })
    local after = lurek.pathfind.getAsyncPendingCount()
    example_print_log("pending_before = " .. tostring(before))
    example_print_log("pending_after = " .. tostring(after))
    lurek.pathfind.clearAsyncPaths()
end
```

---

### `lurek.pathfind.getThreadCount`

Returns the configured pathfinding thread count.

```lua
lurek.pathfind.getThreadCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Thread count (minimum 1). |

**Example**

```lua
do
    local tc = lurek.pathfind.getThreadCount()
    local nav = lurek.pathfind.newNavGrid(8, 8)
    nav:setBlocked(4, 4, true)
    local pending = lurek.pathfind.getAsyncPendingCount()

    pathfind_log("thread count = " .. tc)
    pathfind_log("pending async jobs = " .. pending)
    pathfind_log("sample grid blocked = " .. tostring(nav:isBlocked(4, 4)))
end
```

---

### `lurek.pathfind.newFlowField`

Creates a flow field for a navigation grid.

```lua
lurek.pathfind.newFlowField(grid_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `grid_ud` | [LNavGrid](#lnavgrid) | Navigation grid to compute flow field from. |

**Returns**

| Type | Description |
|------|-------------|
| [LFlowField](#lflowfield) | New flow field handle. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)
    nav:setBlocked(10, 5, true)
    nav:setBlocked(10, 6, true)
    nav:setBlocked(10, 7, true)

    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(20, 10)

    example_print_log("calculated = " .. tostring(ff:isCalculated()))
    example_print_log("targets = " .. #ff:getTargets())
end
```

---

### `lurek.pathfind.newGoalMap`

Creates a new multi-source Dijkstra distance-field goal map for the given grid dimensions.

```lua
lurek.pathfind.newGoalMap(width, height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | number | Grid width in cells. |
| `height` | number | Grid height in cells. |

**Returns**

| Type | Description |
|------|-------------|
| [LGoalMap](#lgoalmap) | New goal map ready for source registration and baking. |

**Example**

```lua
do
    local gm = lurek.pathfind.newGoalMap(16, 16)
    gm:addSource(8, 8, 1)
    gm:bake()
    local ready = gm:isReady()
    local center_distance = gm:distanceAt(8, 8)

    pathfind_log("goal map type = " .. gm:type())
    pathfind_log("goal map ready = " .. tostring(ready))
    pathfind_log("center distance = " .. center_distance)
end
```

---

### `lurek.pathfind.newHexGrid`

Creates a hex grid with the given dimensions.

```lua
lurek.pathfind.newHexGrid(width, height, layout_str)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | number | Grid width in hex columns. |
| `height` | number | Grid height in hex rows. |
| `layout_str?` | string | Hex layout: `flat` (default) or `pointy`. |

**Returns**

| Type | Description |
|------|-------------|
| [LHexGrid](#lhexgrid) | New hex grid handle. |

**Example**

```lua
do
    local hex = lurek.pathfind.newHexGrid(12, 10, "flat")

    hex:setBlocked(5, 5, true)
    hex:setBlocked(6, 5, true)

    example_print_log("blocked_5_5 = " .. tostring(hex:isBlocked(5, 5)))
    example_print_log("blocked_1_1 = " .. tostring(hex:isBlocked(1, 1)))
end
```

---

### `lurek.pathfind.newJpsGrid`

Creates a Jump Point Search grid with given dimensions.

```lua
lurek.pathfind.newJpsGrid(width, height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | number | Grid width in cells. |
| `height` | number | Grid height in cells. |

**Returns**

| Type | Description |
|------|-------------|
| [LJpsGrid](#ljpsgrid) | New JPS grid handle. |

**Example**

```lua
do
    local jps = lurek.pathfind.newJpsGrid(30, 30)

    jps:setBlocked(15, 10, true)
    jps:setBlocked(15, 11, true)
    jps:setBlocked(15, 12, true)

    example_print_log("blocked_15_10 = " .. tostring(jps:isBlocked(15, 10)))
    example_print_log("blocked_1_1 = " .. tostring(jps:isBlocked(1, 1)))
end
```

---

### `lurek.pathfind.newNavGrid`

Creates a navigation grid with the given dimensions.

```lua
lurek.pathfind.newNavGrid(width, height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | number | Grid width in cells. |
| `height` | number | Grid height in cells. |

**Returns**

| Type | Description |
|------|-------------|
| [LNavGrid](#lnavgrid) | New navigation grid handle. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(50, 50)
    local w, h = nav:getDimensions()
    nav:setBlocked(25, 25, true)
    local chunk = nav:getChunkSize()
    local center_blocked = nav:isBlocked(25, 25)

    pathfind_log("city nav dims = " .. w .. "x" .. h)
    pathfind_log("default chunk = " .. chunk)
    pathfind_log("market center blocked = " .. tostring(center_blocked))
end
```

---

### `lurek.pathfind.newNavGridFromTileMap`

Creates a navigation grid from a tilemap layer and blocked gid table.

```lua
lurek.pathfind.newNavGridFromTileMap(tm_ud, layer_index, blocked_table)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tm_ud` | [LTileMap](#ltilemap) | Tilemap to derive navigation grid from. |
| `layer_index` | number | One-based tilemap layer index. |
| `blocked_table` | table | Array of tile GIDs that should be blocked. |

**Returns**

| Type | Description |
|------|-------------|
| [LNavGrid](#lnavgrid) | New navigation grid handle. |

**Example**

```lua
do
    local tm = lurek.tilemap.newTileMap(16, 16, 8)
    local layer_index = tm:addLayer("ground", 8, 8)

    tm:setTile(layer_index, 3, 3, 2)
    tm:setTile(layer_index, 4, 3, 1)

    local ng = lurek.pathfind.newNavGridFromTileMap(tm, layer_index, { 2 })

    example_print_log("dims = " .. ng:getWidth() .. "x" .. ng:getHeight())
    example_print_log("blocked_3_3 = " .. tostring(ng:isBlocked(3, 3)))
    example_print_log("blocked_4_3 = " .. tostring(ng:isBlocked(4, 3)))
end
```

---

### `lurek.pathfind.newNavMesh`

Creates an empty navigation mesh for polygon-based pathfinding.

```lua
lurek.pathfind.newNavMesh()
```

**Returns**

| Type | Description |
|------|-------------|
| [LNavMesh](#lnavmesh) | New navmesh handle. |

**Example**

```lua
do
    local mesh = lurek.pathfind.newNavMesh()
    local id1 = mesh:addPolygon({
        { x = 0, y = 0 },
        { x = 100, y = 0 },
        { x = 50, y = 80 },
    })
    local id2 = mesh:addPolygon({
        { x = 50, y = 80 },
        { x = 100, y = 0 },
        { x = 150, y = 80 },
    })

    example_print_log("polygons = " .. mesh:getPolygonCount())
    example_print_log("ids = " .. id1 .. "," .. id2)
end
```

---

### `lurek.pathfind.newPathFlowField`

Creates an AI flow field from a path grid.

```lua
lurek.pathfind.newPathFlowField(grid_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `grid_ud` | [LPathGrid](#lpathgrid) | Path grid to compute AI flow field from. |

**Returns**

| Type | Description |
|------|-------------|
| [LAIFlowField](#laiflowfield) | New AI flow field handle. |

**Example**

```lua
do
    local grid = lurek.pathfind.newPathGrid(15, 15, 32)
    local aiff = lurek.pathfind.newPathFlowField(grid)

    aiff:setGoal(10, 10)

    local gx, gy = aiff:getGoal()
    example_print_log("dims = " .. aiff:getWidth() .. "x" .. aiff:getHeight())
    example_print_log("has_goal = " .. tostring(aiff:hasGoal()))
    example_print_log("goal = " .. gx .. "," .. gy)
end
```

---

### `lurek.pathfind.newPathGrid`

Creates a cell-size path grid with given dimensions.

```lua
lurek.pathfind.newPathGrid(w, h, cell_size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | number | Grid width in cells. |
| `h` | number | Grid height in cells. |
| `cell_size` | number | World-space size of each cell. |

**Returns**

| Type | Description |
|------|-------------|
| [LPathGrid](#lpathgrid) | New path grid handle. |

**Example**

```lua
do
    local grid = lurek.pathfind.newPathGrid(20, 15, 32)
    grid:setWalkable(10, 8, false)
    local width = grid:getWidth()
    local height = grid:getHeight()
    local cell_size = grid:getCellSize()
    local chokepoint_open = grid:isWalkable(10, 7)

    pathfind_log("patrol grid = " .. width .. "x" .. height)
    pathfind_log("patrol cell size = " .. cell_size)
    pathfind_log("approach tile walkable = " .. tostring(chokepoint_open))
end
```

---

### `lurek.pathfind.newPathfinder`

Creates a unit pathfinder for a navigation grid.

```lua
lurek.pathfind.newPathfinder(grid_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `grid_ud` | [LNavGrid](#lnavgrid) | Navigation grid to pathfind on. |

**Returns**

| Type | Description |
|------|-------------|
| [LUnitPathfinder](#lunitpathfinder) | New pathfinder handle. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(30, 30)

    nav:fill(1)
    nav:setBlocked(15, 10, true)
    nav:setBlocked(15, 11, true)
    nav:setBlocked(15, 12, true)
    nav:setBlocked(15, 13, true)

    local pf = lurek.pathfind.newPathfinder(nav)
    local path = pf:findPath(1, 12, 30, 12)
    if path then
        example_print_log("steps = " .. #path)
        example_print_log("first = " .. path[1].x .. "," .. path[1].y)
        example_print_log("last = " .. path[#path].x .. "," .. path[#path].y)
    else
        example_print_log("steps = 0")
    end
end
```

---

### `lurek.pathfind.pollAsyncPaths`

Returns all currently available async path events without blocking.

```lua
lurek.pathfind.pollAsyncPaths()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Array of event tables with ids, status, optional path, and completion flags. |

**Example**

```lua
do
    lurek.pathfind.clearAsyncPaths()
    local nav = lurek.pathfind.newNavGrid(24, 24)
    local request_id = lurek.pathfind.submitAsyncPath(nav, {
        start_x = 1,
        start_y = 1,
        goal_x = 24,
        goal_y = 24,
        stream_budget = 4,
    })
    local seen = {}
    for _ = 1, 64 do
        local events = lurek.pathfind.pollAsyncPaths()
        for i = 1, #events do
            seen[#seen + 1] = events[i]
        end
        if #seen > 0 then
            break
        end
        lurek.timer.sleep(0.001)
    end
    example_print_log("request = " .. tostring(request_id))
    example_print_log("events = " .. tostring(#seen))
end
```

---

### `lurek.pathfind.rangeMap`

Computes reachable cells from range map options.

```lua
lurek.pathfind.rangeMap(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | table | Options with dimensions, origin, budget, optional diagonal flag, costs, and blocked cells. |

**Returns**

| Type | Description |
|------|-------------|
| LPathfindRangeMapResult | Range map result with `cells`, `width`, and `height` fields. |

**Example**

```lua
do
    local result = lurek.pathfind.rangeMap({
        width = 10,
        height = 10,
        origin_x = 5,
        origin_y = 5,
        budget = 4,
        diagonal = true,
    })

    example_print_log("dims = " .. result.width .. "x" .. result.height)
    example_print_log("cells = " .. #result.cells)
    if #result.cells > 0 then
        example_print_log("first = " .. result.cells[1].x .. "," .. result.cells[1].y .. "," .. result.cells[1].cost)
    end
end
```

---

### `lurek.pathfind.setThreadCount`

Sets the configured pathfinding worker-thread count.

```lua
lurek.pathfind.setThreadCount(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | number | Desired thread count. |

**Example**

```lua
do
    local previous = lurek.pathfind.getThreadCount()
    local target = previous < 2 and 2 or previous

    lurek.pathfind.setThreadCount(target)
    local actual = lurek.pathfind.getThreadCount()
    local nav = lurek.pathfind.newNavGrid(6, 6)

    pathfind_log("thread count target = " .. target)
    pathfind_log("thread count actual = " .. actual)
    pathfind_log("worker sample dims = " .. nav:getWidth() .. "x" .. nav:getHeight())
end
```

---

### `lurek.pathfind.submitAsyncPath`

Queues an async path query against a navigation grid snapshot.

```lua
lurek.pathfind.submitAsyncPath(grid_ud, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `grid_ud` | [LNavGrid](#lnavgrid) | Navigation grid to clone for the worker. |
| `opts` | table | Options with start/goal cells and optional owner, version, priority, unit size, and stream budget. |

**Returns**

| Type | Description |
|------|-------------|
| number | Request id for polling and cancellation. |

**Example**

```lua
do
    lurek.pathfind.clearAsyncPaths()
    local nav = lurek.pathfind.newNavGrid(24, 24)
    local request_id = lurek.pathfind.submitAsyncPath(nav, {
        start_x = 1,
        start_y = 1,
        goal_x = 24,
        goal_y = 24,
        stream_budget = 4,
    })
    example_print_log("request_id = " .. tostring(request_id))
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

- [LAIFlowField](#laiflowfield)
- [LFlowField](#lflowfield)
- [LGoalMap](#lgoalmap)
- [LHexGrid](#lhexgrid)
- [LJpsGrid](#ljpsgrid)
- [LNavGrid](#lnavgrid)
- [LNavMesh](#lnavmesh)
- [LPathGrid](#lpathgrid)
- [LTileMap](#ltilemap)
- [LUnitPathfinder](#lunitpathfinder)

## LAIFlowField

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LAIFlowField:getDirection`

Returns flow direction vector for a one-based cell.

```lua
LAIFlowField:getDirection(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |

**Returns**

| Type | Description |
|------|-------------|
| number | Direction X component. |
| number | Direction Y component. |

**Example**

```lua
do
    local grid = lurek.pathfind.newPathGrid(10, 10, 16)
    local aiff = lurek.pathfind.newPathFlowField(grid)

    aiff:setGoal(10, 10)

    local dx, dy = aiff:getDirection(1, 1)
    example_print_log("dir = " .. dx .. "," .. dy)
    example_print_log("distance = " .. aiff:getDistance(1, 1))
end
```

---

#### `LAIFlowField:getDistance`

Returns distance to goal for a one-based cell.

```lua
LAIFlowField:getDistance(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |

**Returns**

| Type | Description |
|------|-------------|
| number | Distance to the goal. |

**Example**

```lua
do
    local grid = lurek.pathfind.newPathGrid(10, 10, 16)
    local aiff = lurek.pathfind.newPathFlowField(grid)

    aiff:setGoal(10, 10)

    local dx, dy = aiff:getDirection(1, 1)
    example_print_log("dir = " .. dx .. "," .. dy)
    example_print_log("distance = " .. aiff:getDistance(1, 1))
end
```

---

#### `LAIFlowField:getGoal`

Returns the one-based flow field goal, or nil when no goal is set.

```lua
LAIFlowField:getGoal()
```

**Returns**

| Type | Description |
|------|-------------|
| number | One-based goal column; or nil. |
| number | One-based goal row; or nil. |

**Example**

```lua
do
    local grid = lurek.pathfind.newPathGrid(15, 15, 32)
    local aiff = lurek.pathfind.newPathFlowField(grid)

    aiff:setGoal(10, 10)

    local gx, gy = aiff:getGoal()
    example_print_log("goal = " .. gx .. "," .. gy)
    example_print_log("has_goal = " .. tostring(aiff:hasGoal()))
end
```

---

#### `LAIFlowField:getHeight`

Returns flow field height from this object.

```lua
LAIFlowField:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Height. |

**Example**

```lua
do
    local pg = lurek.pathfind.newPathGrid(32, 32, 1)
    local ff = lurek.pathfind.newPathFlowField(pg)

    ff:setGoal(16, 16)

    example_print_log("dims = " .. ff:getWidth() .. "x" .. ff:getHeight())
    example_print_log("has_goal = " .. tostring(ff:hasGoal()))
end
```

---

#### `LAIFlowField:getWidth`

Returns flow field width from this object.

```lua
LAIFlowField:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width. |

**Example**

```lua
do
    local pg = lurek.pathfind.newPathGrid(32, 32, 1)
    local ff = lurek.pathfind.newPathFlowField(pg)

    ff:setGoal(16, 16)

    example_print_log("dims = " .. ff:getWidth() .. "x" .. ff:getHeight())
    example_print_log("has_goal = " .. tostring(ff:hasGoal()))
end
```

---

#### `LAIFlowField:hasGoal`

Returns whether a flow field goal is currently set.

```lua
LAIFlowField:hasGoal()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a goal exists. |

**Example**

```lua
do
    local pg = lurek.pathfind.newPathGrid(32, 32, 1)
    local ff = lurek.pathfind.newPathFlowField(pg)

    example_print_log("has_goal_before = " .. tostring(ff:hasGoal()))
    ff:setGoal(16, 16)
    example_print_log("has_goal_after = " .. tostring(ff:hasGoal()))
end
```

---

#### `LAIFlowField:setGoal`

Sets the one-based flow field goal and recalculates the field.

```lua
LAIFlowField:setGoal(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based goal column. |
| `y` | number | One-based goal row. |

**Example**

```lua
do
    local grid = lurek.pathfind.newPathGrid(15, 15, 32)
    local aiff = lurek.pathfind.newPathFlowField(grid)

    aiff:setGoal(10, 10)

    local gx, gy = aiff:getGoal()
    example_print_log("has_goal = " .. tostring(aiff:hasGoal()))
    example_print_log("goal = " .. gx .. "," .. gy)
end
```

---

#### `LAIFlowField:type`

Returns the Lua-visible type name for this AI flow field handle.

```lua
LAIFlowField:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LAIFlowField](#laiflowfield)`. |

**Example**

```lua
do
    local grid = lurek.pathfind.newPathGrid(5, 5, 32)
    local aiff = lurek.pathfind.newPathFlowField(grid)
    aiff:setGoal(5, 5)
    local type_name = aiff:type()
    local width = aiff:getWidth()
    local height = aiff:getHeight()

    pathfind_log("ai flow field type = " .. type_name)
    pathfind_log("field dims = " .. width .. "x" .. height)
    pathfind_log("goal ready = " .. tostring(aiff:hasGoal()))
end
```

---

#### `LAIFlowField:typeOf`

Returns whether this AI flow field handle matches a supported type name.

```lua
LAIFlowField:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | String value for `name`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local grid = lurek.pathfind.newPathGrid(5, 5, 32)
    local aiff = lurek.pathfind.newPathFlowField(grid)
    aiff:setGoal(4, 4)
    local is_ai_flow_field = aiff:typeOf("LAIFlowField")
    local is_object = aiff:typeOf("LObject")
    local is_flow_field = aiff:typeOf("LFlowField")

    pathfind_log("matches LAIFlowField = " .. tostring(is_ai_flow_field))
    pathfind_log("matches LObject = " .. tostring(is_object))
    pathfind_log("matches LFlowField = " .. tostring(is_flow_field))
end
```

---

## LFlowField

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LFlowField:calculate`

Calculates a flow field toward one target cell.

```lua
LFlowField:calculate(tx, ty, unit_size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tx` | number | One-based target column. |
| `ty` | number | One-based target row. |
| `unit_size?` | number | Unit footprint in cells (default 1). |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)

    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(20, 10)

    example_print_log("calculated = " .. tostring(ff:isCalculated()))
    example_print_log("targets = " .. #ff:getTargets())
end
```

---

#### `LFlowField:calculateMulti`

Calculates a flow field toward multiple target cells.

```lua
LFlowField:calculateMulti(targets, unit_size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `targets` | table | Array of `{x, y}` target tables. |
| `unit_size?` | number | Unit footprint in cells (default 1). |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(15, 15)

    nav:fill(1)

    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculateMulti({
        { x = 5, y = 5 },
        { x = 10, y = 10 },
    })

    local targets = ff:getTargets()
    example_print_log("targets = " .. #targets)
    example_print_log("first = " .. targets[1].x .. "," .. targets[1].y)
    example_print_log("last = " .. targets[#targets].x .. "," .. targets[#targets].y)
end
```

---

#### `LFlowField:getCostToTarget`

Returns integration cost to the target from a one-based grid cell.

```lua
LFlowField:getCostToTarget(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |

**Returns**

| Type | Description |
|------|-------------|
| number | Integration cost to the nearest target. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(10, 10)

    nav:fill(1)

    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(10, 10)

    local dx, dy = ff:getDirection(1, 1)
    example_print_log("dir = " .. dx .. "," .. dy)
    example_print_log("cost = " .. ff:getCostToTarget(1, 1))
end
```

---

#### `LFlowField:getDirection`

Returns flow direction vector at a one-based grid cell.

```lua
LFlowField:getDirection(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |

**Returns**

| Type | Description |
|------|-------------|
| number | Direction X component. |
| number | Direction Y component. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(10, 10)

    nav:fill(1)

    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(10, 10)

    local dx, dy = ff:getDirection(1, 1)
    example_print_log("dir = " .. dx .. "," .. dy)
    example_print_log("angle = " .. ff:getDirectionAngle(1, 1))
    example_print_log("cost = " .. ff:getCostToTarget(1, 1))
end
```

---

#### `LFlowField:getDirectionAngle`

Returns flow direction angle at a one-based grid cell.

```lua
LFlowField:getDirectionAngle(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |

**Returns**

| Type | Description |
|------|-------------|
| number | Direction angle in radians. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(10, 10)

    nav:fill(1)

    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(10, 10)

    example_print_log("angle = " .. ff:getDirectionAngle(1, 1))
    example_print_log("cost = " .. ff:getCostToTarget(1, 1))
end
```

---

#### `LFlowField:getTargets`

Returns target cells for this flow field.

```lua
LFlowField:getTargets()
```

**Returns**

| Type | Description |
|------|-------------|
| LFlowFieldGetTargetsResult | Array table of target point tables. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(15, 15)

    nav:fill(1)

    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculateMulti({
        { x = 4, y = 4 },
        { x = 12, y = 12 },
    })

    local targets = ff:getTargets()
    example_print_log("targets = " .. #targets)
    example_print_log("first = " .. targets[1].x .. "," .. targets[1].y)
end
```

---

#### `LFlowField:isCalculated`

Returns whether the flow field has been calculated.

```lua
LFlowField:isCalculated()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when calculated. |

**Example**

```lua
do
    local grid = lurek.pathfind.newNavGrid(16, 16)
    local ff = lurek.pathfind.newFlowField(grid)

    example_print_log("calculated_before = " .. tostring(ff:isCalculated()))
    ff:calculate(8, 8, 1)
    example_print_log("calculated_after = " .. tostring(ff:isCalculated()))
end
```

---

#### `LFlowField:steer`

Returns a steering velocity for a world position using the flow field.

```lua
LFlowField:steer(wx, wy, speed, tw, th)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `wx` | number | World X position. |
| `wy` | number | World Y position. |
| `speed` | number | Movement speed scalar. |
| `tw` | number | Tile width in world units. |
| `th` | number | Tile height in world units. |

**Returns**

| Type | Description |
|------|-------------|
| number | Steered X velocity. |
| number | Steered Y velocity. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(10, 10)

    nav:fill(1)

    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(10, 10)

    local vx, vy = ff:steer(50, 50, 100, 32, 32)
    example_print_log("velocity = " .. vx .. "," .. vy)
end
```

---

#### `LFlowField:type`

Returns the Lua-visible type name for this flow field handle.

```lua
LFlowField:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LFlowField](#lflowfield)`. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(5, 5)
    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(5, 5)
    local type_name = ff:type()
    local calculated = ff:isCalculated()
    local targets = ff:getTargets()

    pathfind_log("flow field type = " .. type_name)
    pathfind_log("calculated = " .. tostring(calculated))
    pathfind_log("target count = " .. #targets)
end
```

---

#### `LFlowField:typeOf`

Returns whether this flow field handle matches a supported type name.

```lua
LFlowField:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | String value for `name`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(5, 5)
    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(4, 4)
    local is_flow_field = ff:typeOf("LFlowField")
    local is_object = ff:typeOf("LObject")
    local is_ai_flow_field = ff:typeOf("LAIFlowField")

    pathfind_log("matches LFlowField = " .. tostring(is_flow_field))
    pathfind_log("matches LObject = " .. tostring(is_object))
    pathfind_log("matches LAIFlowField = " .. tostring(is_ai_flow_field))
end
```

---

## LGoalMap

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LGoalMap:addSource`

Registers a source cell for this goal map. Coordinates are one-based.

```lua
LGoalMap:addSource(x, y, weight)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `weight?` | number | Relative weight (default 1). Lower = stronger pull. |

**Example**

```lua
do
    local gm = lurek.pathfind.newGoalMap(16, 16)
    gm:addSource(8, 8, 1)
    gm:addSource(4, 12, 2)
    gm:bake()
    local origin_distance = gm:distanceAt(8, 8)
    local flank_distance = gm:distanceAt(4, 12)
    local corner_distance = gm:distanceAt(1, 1)

    pathfind_log("origin distance = " .. origin_distance)
    pathfind_log("flank source distance = " .. flank_distance)
    pathfind_log("corner distance = " .. corner_distance)
end
```

---

#### `LGoalMap:bake`

Runs multi-source Dijkstra to build the distance field using the registered blocker.

```lua
LGoalMap:bake()
```

**Example**

```lua
do
    local gm = lurek.pathfind.newGoalMap(16, 16)
    gm:addSource(8, 8, 1)
    gm:bake()
    local ready = gm:isReady()
    local distance_mid = gm:distanceAt(10, 8)
    local distance_corner = gm:distanceAt(1, 1)

    pathfind_log("ready after bake = " .. tostring(ready))
    pathfind_log("east lane distance = " .. distance_mid)
    pathfind_log("corner distance = " .. distance_corner)
end
```

---

#### `LGoalMap:clearSources`

Removes all registered source cells.

```lua
LGoalMap:clearSources()
```

**Example**

```lua
do
    local gm = lurek.pathfind.newGoalMap(16, 16)
    gm:addSource(8, 8, 1)
    gm:clearSources()
    gm:bake()
    example_print_log("ready_after_clear = " .. tostring(gm:isReady()))
end
```

---

#### `LGoalMap:distanceAt`

Returns the minimum cost from (x, y) to the nearest source.

```lua
LGoalMap:distanceAt(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |

**Returns**

| Type | Description |
|------|-------------|
| number | Distance value; max-int means unreachable. |

**Example**

```lua
do
    local gm = lurek.pathfind.newGoalMap(10, 10)
    gm:addSource(5, 5, 1)
    gm:bake()
    example_print_log("distance_5_5 = " .. gm:distanceAt(5, 5))
    example_print_log("distance_1_1 = " .. gm:distanceAt(1, 1))
end
```

---

#### `LGoalMap:flee`

Returns a normalised direction vector pointing away from sources (for fleeing NPCs).

```lua
LGoalMap:flee(x, y, fear)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `fear?` | number | Scale factor (default 1.0). |

**Returns**

| Type | Description |
|------|-------------|
| number | dx component. |
| number | dy component. |

**Example**

```lua
do
    local gm = lurek.pathfind.newGoalMap(10, 10)
    gm:addSource(5, 5, 1)
    gm:bake()
    local dx, dy = gm:flee(5, 6, 1.0)
    example_print_log("flee = " .. dx .. "," .. dy)
end
```

---

#### `LGoalMap:floodFill`

Returns all cells reachable from (cx, cy) within `threshold` steps.

```lua
LGoalMap:floodFill(cx, cy, threshold)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cx` | number | One-based center column. |
| `cy` | number | One-based center row. |
| `threshold` | number | Maximum distance to include. |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of `{x, y}` tables (one-based). |

**Example**

```lua
do
    local gm = lurek.pathfind.newGoalMap(12, 12)
    gm:addSource(6, 6, 1)
    gm:bake()
    local cells = gm:floodFill(6, 6, 4)
    example_print_log("flood_cells = " .. #cells)
end
```

---

#### `LGoalMap:gradientAt`

Returns a normalised direction vector pointing toward the nearest source.

```lua
LGoalMap:gradientAt(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |

**Returns**

| Type | Description |
|------|-------------|
| number | dx component. |
| number | dy component. |

**Example**

```lua
do
    local gm = lurek.pathfind.newGoalMap(10, 10)
    gm:addSource(10, 10, 1)
    gm:bake()
    local dx, dy = gm:gradientAt(1, 1)
    example_print_log("gradient = " .. dx .. "," .. dy)
end
```

---

#### `LGoalMap:isReady`

Returns true when the distance field has been baked and not invalidated.

```lua
LGoalMap:isReady()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the field is ready for queries. |

**Example**

```lua
do
    local gm = lurek.pathfind.newGoalMap(8, 8)
    gm:addSource(4, 4, 1)
    example_print_log("ready_before = " .. tostring(gm:isReady()))
    gm:bake()
    example_print_log("ready_after = " .. tostring(gm:isReady()))
end
```

---

#### `LGoalMap:restore`

Restores a distance field from a blob produced by `save`.

```lua
LGoalMap:restore(blob)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `blob` | string | Serialised blob. |

**Example**

```lua
do
    local gm = lurek.pathfind.newGoalMap(12, 12)
    gm:addSource(6, 6, 1)
    gm:bake()
    local blob = gm:save()

    local gm2 = lurek.pathfind.newGoalMap(12, 12)
    gm2:restore(blob)
    example_print_log("distance_restored = " .. gm2:distanceAt(6, 6))
end
```

---

#### `LGoalMap:save`

Serialises the current distance field to a binary blob string.

```lua
LGoalMap:save()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Serialised blob. |

**Example**

```lua
do
    local gm = lurek.pathfind.newGoalMap(12, 12)
    gm:addSource(6, 6, 1)
    gm:bake()
    local blob = gm:save()
    example_print_log("blob_bytes = " .. #blob)
end
```

---

#### `LGoalMap:setBlocker`

Sets a Lua predicate called during `bake` to determine blocked cells.

```lua
LGoalMap:setBlocker(fn)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `fn` | function | `fn(x: integer, y: integer) -> boolean` (one-based). |

**Example**

```lua
do
    local gm = lurek.pathfind.newGoalMap(16, 16)
    gm:addSource(8, 8, 1)
    gm:setBlocker(function(x, y)
        return x == 9 and y >= 4 and y <= 12
    end)
    gm:bake()
    example_print_log("distance_12_8 = " .. gm:distanceAt(12, 8))
end
```

---

#### `LGoalMap:setSources`

Replaces all registered source cells. Each entry must have x, y (one-based) and optional weight.

```lua
LGoalMap:setSources(sources)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sources` | table | Array of `{x, y, weight?}` tables. |

**Example**

```lua
do
    local gm = lurek.pathfind.newGoalMap(16, 16)
    gm:setSources({
        { x = 4, y = 4, weight = 1 },
        { x = 13, y = 13, weight = 2 },
    })
    gm:bake()
    example_print_log("ready = " .. tostring(gm:isReady()))
end
```

---

#### `LGoalMap:type`

Returns the Lua-visible type name for this goal map handle.

```lua
LGoalMap:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LGoalMap](#lgoalmap)`. |

**Example**

```lua
do
    local gm = lurek.pathfind.newGoalMap(8, 8)
    gm:addSource(4, 4, 1)
    gm:bake()
    local type_name = gm:type()
    local ready = gm:isReady()

    pathfind_log("goal map type = " .. type_name)
    pathfind_log("ready = " .. tostring(ready))
    pathfind_log("center distance = " .. gm:distanceAt(4, 4))
end
```

---

#### `LGoalMap:typeOf`

Returns whether this goal map handle matches a supported type name.

```lua
LGoalMap:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the name matches. |

**Example**

```lua
do
    local gm = lurek.pathfind.newGoalMap(8, 8)
    gm:addSource(4, 4, 1)
    gm:bake()
    local is_goal_map = gm:typeOf("LGoalMap")
    local is_object = gm:typeOf("LObject")
    local is_nav_mesh = gm:typeOf("LNavMesh")

    pathfind_log("matches LGoalMap = " .. tostring(is_goal_map))
    pathfind_log("matches LObject = " .. tostring(is_object))
    pathfind_log("matches LNavMesh = " .. tostring(is_nav_mesh))
end
```

---

## LHexGrid

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LHexGrid:distance`

Returns hex distance between two one-based hex cells.

```lua
LHexGrid:distance(c1, r1, c2, r2)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `c1` | number | One-based column of the first cell. |
| `r1` | number | One-based row of the first cell. |
| `c2` | number | One-based column of the second cell. |
| `r2` | number | One-based row of the second cell. |

**Returns**

| Type | Description |
|------|-------------|
| number | Hex distance. |

**Example**

```lua
do
    local hex = lurek.pathfind.newHexGrid(10, 10)
    hex:setBlocked(3, 3, true)
    local flank_distance = hex:distance(1, 1, 5, 5)
    local same_cell_distance = hex:distance(1, 1, 1, 1)
    local scout_distance = hex:distance(2, 4, 7, 4)

    pathfind_log("flank distance = " .. flank_distance)
    pathfind_log("same cell distance = " .. same_cell_distance)
    pathfind_log("frontline distance = " .. scout_distance)
end
```

---

#### `LHexGrid:fieldOfView`

Returns visible hex cells within range from an origin.

```lua
LHexGrid:fieldOfView(col, row, max_range)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | number | One-based origin column. |
| `row` | number | One-based origin row. |
| `max_range` | number | Maximum visibility range in cells. |

**Returns**

| Type | Description |
|------|-------------|
| LHexGridFieldOfViewResult | Array of `{col, row}` hex cell tables. |

**Example**

```lua
do
    local hex = lurek.pathfind.newHexGrid(15, 15)

    hex:setBlocked(8, 8, true)

    local visible = hex:fieldOfView(7, 7, 3)
    example_print_log("visible = " .. #visible)
    if #visible > 0 then
        example_print_log("first = " .. visible[1].col .. "," .. visible[1].row)
    end
end
```

---

#### `LHexGrid:findPath`

Finds a path between one-based hex cells.

```lua
LHexGrid:findPath(fc, fr, tc, tr)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `fc` | number | One-based start column. |
| `fr` | number | One-based start row. |
| `tc` | number | One-based goal column. |
| `tr` | number | One-based goal row. |

**Returns**

| Type | Description |
|------|-------------|
| LHexGridFindPathResult | Array of `{col, row}` hex cell tables, or nil when no path exists. |

**Example**

```lua
do
    local hex = lurek.pathfind.newHexGrid(10, 10)

    hex:setBlocked(5, 3, true)
    hex:setBlocked(5, 4, true)
    hex:setBlocked(5, 5, true)

    local path = hex:findPath(1, 5, 10, 5)
    if path then
        example_print_log("steps = " .. #path)
        example_print_log("first = " .. path[1].col .. "," .. path[1].row)
        example_print_log("last = " .. path[#path].col .. "," .. path[#path].row)
    else
        example_print_log("steps = 0")
    end
end
```

---

#### `LHexGrid:isBlocked`

Returns whether a one-based hex cell is blocked.

```lua
LHexGrid:isBlocked(col, row)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | number | One-based hex column. |
| `row` | number | One-based hex row. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when blocked. |

**Example**

```lua
do
    local hex = lurek.pathfind.newHexGrid(12, 10, "flat")
    hex:setBlocked(4, 4, true)
    hex:setBlocked(5, 4, true)
    local ridge = hex:isBlocked(4, 4)
    local ridge_neighbor = hex:isBlocked(5, 4)
    local open_hex = hex:isBlocked(4, 5)

    pathfind_log("ridge blocked = " .. tostring(ridge))
    pathfind_log("ridge neighbor blocked = " .. tostring(ridge_neighbor))
    pathfind_log("southern hex blocked = " .. tostring(open_hex))
end
```

---

#### `LHexGrid:lineOfSight`

Returns whether two one-based hex cells have line of sight.

```lua
LHexGrid:lineOfSight(fc, fr, tc, tr)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `fc` | number | One-based column of the first cell. |
| `fr` | number | One-based row of the first cell. |
| `tc` | number | One-based column of the second cell. |
| `tr` | number | One-based row of the second cell. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when line of sight is clear. |

**Example**

```lua
do
    local hex = lurek.pathfind.newHexGrid(10, 10)

    local clear = hex:lineOfSight(1, 1, 10, 10)
    hex:setBlocked(5, 5, true)
    local blocked = hex:lineOfSight(1, 1, 10, 10)

    example_print_log("clear = " .. tostring(clear))
    example_print_log("blocked = " .. tostring(blocked))
end
```

---

#### `LHexGrid:rangeOfMovement`

Returns reachable hex cells within a movement budget.

```lua
LHexGrid:rangeOfMovement(col, row, budget)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | number | One-based origin column. |
| `row` | number | One-based origin row. |
| `budget` | number | Maximum movement cost budget. |

**Returns**

| Type | Description |
|------|-------------|
| LHexGridRangeOfMovementResult | Array of `{col, row}` hex cell tables. |

**Example**

```lua
do
    local hex = lurek.pathfind.newHexGrid(12, 12)

    hex:setCost(6, 6, 3)

    local reachable = hex:rangeOfMovement(6, 6, 4)
    example_print_log("reachable = " .. #reachable)
    if #reachable > 0 then
        example_print_log("first = " .. reachable[1].col .. "," .. reachable[1].row)
    end
end
```

---

#### `LHexGrid:setBlocked`

Sets blocked state for a one-based hex cell.

```lua
LHexGrid:setBlocked(col, row, blocked)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | number | One-based hex column. |
| `row` | number | One-based hex row. |
| `blocked` | boolean | True to block the cell. |

**Example**

```lua
do
    local hex = lurek.pathfind.newHexGrid(12, 10, "flat")

    hex:setBlocked(5, 5, true)
    hex:setBlocked(6, 5, true)

    example_print_log("blocked_5_5 = " .. tostring(hex:isBlocked(5, 5)))
    example_print_log("blocked_6_5 = " .. tostring(hex:isBlocked(6, 5)))
end
```

---

#### `LHexGrid:setCost`

Sets movement cost for a one-based hex cell.

```lua
LHexGrid:setCost(col, row, cost)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | number | One-based hex column. |
| `row` | number | One-based hex row. |
| `cost` | number | Movement cost value. |

**Example**

```lua
do
    local hex = lurek.pathfind.newHexGrid(8, 8)

    hex:setCost(4, 4, 4)
    hex:setCost(5, 4, 4)

    local reachable = hex:rangeOfMovement(4, 4, 4)
    example_print_log("reachable = " .. #reachable)
    if #reachable > 0 then
        example_print_log("first = " .. reachable[1].col .. "," .. reachable[1].row)
    end
end
```

---

#### `LHexGrid:type`

Returns the Lua-visible type name for this hex grid handle.

```lua
LHexGrid:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LHexGrid](#lhexgrid)`. |

**Example**

```lua
do
    local hex = lurek.pathfind.newHexGrid(5, 5, "pointy")
    hex:setCost(3, 3, 2)
    local type_name = hex:type()
    local reachable = hex:rangeOfMovement(3, 3, 3)

    pathfind_log("hex grid type = " .. type_name)
    pathfind_log("reachable cells = " .. #reachable)
    pathfind_log("center blocked = " .. tostring(hex:isBlocked(3, 3)))
end
```

---

#### `LHexGrid:typeOf`

Returns whether this hex grid handle matches a supported type name.

```lua
LHexGrid:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | String value for `name`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local hex = lurek.pathfind.newHexGrid(5, 5, "pointy")
    hex:setBlocked(2, 2, true)
    local is_hex_grid = hex:typeOf("LHexGrid")
    local is_object = hex:typeOf("LObject")
    local is_jps_grid = hex:typeOf("LJpsGrid")

    pathfind_log("matches LHexGrid = " .. tostring(is_hex_grid))
    pathfind_log("matches LObject = " .. tostring(is_object))
    pathfind_log("matches LJpsGrid = " .. tostring(is_jps_grid))
end
```

---

## LJpsGrid

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LJpsGrid:findPath`

Finds a JPS path between one-based grid cells.

```lua
LJpsGrid:findPath(fx, fy, tx, ty)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `fx` | number | One-based start column. |
| `fy` | number | One-based start row. |
| `tx` | number | One-based goal column. |
| `ty` | number | One-based goal row. |

**Returns**

| Type | Description |
|------|-------------|
| LJpsGridFindPathResult | Array of `{x, y}` point tables, or nil when no path exists. |

**Example**

```lua
do
    local jps = lurek.pathfind.newJpsGrid(50, 50)

    for y = 10, 40 do
        jps:setBlocked(25, y, true)
    end
    jps:setBlocked(25, 30, false)

    local path = jps:findPath(1, 25, 50, 25)
    if path then
        example_print_log("points = " .. #path)
        example_print_log("first = " .. path[1].x .. "," .. path[1].y)
        example_print_log("last = " .. path[#path].x .. "," .. path[#path].y)
    else
        example_print_log("points = 0")
    end
end
```

---

#### `LJpsGrid:isBlocked`

Returns whether a one-based JPS grid cell is blocked.

```lua
LJpsGrid:isBlocked(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when blocked. |

**Example**

```lua
do
    local jps = lurek.pathfind.newJpsGrid(30, 30)
    jps:setBlocked(9, 9, true)
    jps:setBlocked(10, 9, true)
    local wall_center = jps:isBlocked(9, 9)
    local wall_neighbor = jps:isBlocked(10, 9)
    local lane_open = jps:isBlocked(9, 10)

    pathfind_log("wall center blocked = " .. tostring(wall_center))
    pathfind_log("wall neighbor blocked = " .. tostring(wall_neighbor))
    pathfind_log("lane blocked = " .. tostring(lane_open))
end
```

---

#### `LJpsGrid:setBlocked`

Sets blocked state for a one-based JPS grid cell.

```lua
LJpsGrid:setBlocked(x, y, blocked)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `blocked` | boolean | True to block the cell. |

**Example**

```lua
do
    local jps = lurek.pathfind.newJpsGrid(30, 30)

    jps:setBlocked(15, 10, true)
    jps:setBlocked(15, 11, true)
    jps:setBlocked(15, 12, true)

    example_print_log("blocked_15_10 = " .. tostring(jps:isBlocked(15, 10)))
    example_print_log("blocked_15_12 = " .. tostring(jps:isBlocked(15, 12)))
end
```

---

#### `LJpsGrid:type`

Returns the Lua-visible type name for this JPS grid handle.

```lua
LJpsGrid:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LJpsGrid](#ljpsgrid)`. |

**Example**

```lua
do
    local jps = lurek.pathfind.newJpsGrid(5, 5)
    jps:setBlocked(3, 3, true)
    local type_name = jps:type()
    local blocked_center = jps:isBlocked(3, 3)
    local path = jps:findPath(1, 1, 5, 5)

    pathfind_log("jps grid type = " .. type_name)
    pathfind_log("center blocked = " .. tostring(blocked_center))
    pathfind_log("corner route nodes = " .. tostring(path and #path or 0))
end
```

---

#### `LJpsGrid:typeOf`

Returns whether this JPS grid handle matches a supported type name.

```lua
LJpsGrid:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | String value for `name`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local jps = lurek.pathfind.newJpsGrid(5, 5)
    jps:setBlocked(2, 2, true)
    local is_jps_grid = jps:typeOf("LJpsGrid")
    local is_object = jps:typeOf("LObject")
    local is_hex_grid = jps:typeOf("LHexGrid")

    pathfind_log("matches LJpsGrid = " .. tostring(is_jps_grid))
    pathfind_log("matches LObject = " .. tostring(is_object))
    pathfind_log("matches LHexGrid = " .. tostring(is_hex_grid))
end
```

---

## LNavGrid

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LNavGrid:clearDirty`

Clears all dirty region markers from the grid.

```lua
LNavGrid:clearDirty()
```

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(50, 50)

    nav:setChunkSize(10)
    nav:setDirty(20, 20, 10, 10)
    nav:clearDirty()
    nav:rebuildAbstract()

    example_print_log("chunk = " .. nav:getChunkSize())
end
```

---

#### `LNavGrid:fill`

Fills the entire grid with a uniform movement cost.

```lua
LNavGrid:fill(cost)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cost` | number | Movement cost (0â€“255). |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(20, 20)
    nav:fill(3)
    nav:setCost(10, 10, 1)
    local border_cost = nav:getCost(1, 1)
    local far_corner_cost = nav:getCost(20, 20)
    local plaza_cost = nav:getCost(10, 10)

    pathfind_log("default patrol cost = " .. border_cost)
    pathfind_log("far corner cost = " .. far_corner_cost)
    pathfind_log("plaza override cost = " .. plaza_cost)
end
```

---

#### `LNavGrid:fillRect`

Fills a one-based rectangular area with a movement cost.

```lua
LNavGrid:fillRect(x, y, w, h, cost)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column of the top-left corner. |
| `y` | number | One-based row of the top-left corner. |
| `w` | number | Rectangle width in cells. |
| `h` | number | Rectangle height in cells. |
| `cost` | number | Movement cost (0â€“255). |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fillRect(5, 5, 5, 5, 0)

    example_print_log("blocked_5_5 = " .. tostring(nav:isBlocked(5, 5)))
    example_print_log("blocked_10_10 = " .. tostring(nav:isBlocked(10, 10)))
    example_print_log("blocked_11_11 = " .. tostring(nav:isBlocked(11, 11)))
end
```

---

#### `LNavGrid:findHpaPath`

Finds a hierarchical path using the cached abstract graph, rebuilding it on first use.

```lua
LNavGrid:findHpaPath(sx, sy, gx, gy, unit_size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sx` | number | One-based start column. |
| `sy` | number | One-based start row. |
| `gx` | number | One-based goal column. |
| `gy` | number | One-based goal row. |
| `unit_size?` | number | Optional unit footprint in cells, default 1. |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of `{x, y}` waypoint tables, or nil when no path exists. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(16, 16)
    nav:setChunkSize(4)
    nav:rebuildAbstract()
    local path = nav:findHpaPath(1, 1, 16, 16, 1)
    example_print_log("hpa path exists = " .. tostring(path ~= nil))
    example_print_log("hpa path len = " .. tostring(path and #path or 0))
end
```

---

#### `LNavGrid:getChunkSize`

Returns the hierarchical chunk size in cells.

```lua
LNavGrid:getChunkSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Chunk size. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(100, 100)
    nav:setChunkSize(12)
    nav:setBlocked(60, 60, true)
    local chunk_size = nav:getChunkSize()
    local dimensions = nav:getWidth() .. "x" .. nav:getHeight()

    pathfind_log("chunk size = " .. chunk_size)
    pathfind_log("sector dims = " .. dimensions)
    pathfind_log("warehouse blocked = " .. tostring(nav:isBlocked(60, 60)))
end
```

---

#### `LNavGrid:getCost`

Returns movement cost at a one-based grid cell.

```lua
LNavGrid:getCost(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |

**Returns**

| Type | Description |
|------|-------------|
| number | Movement cost. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(30, 30)
    nav:fill(1)
    nav:setCost(7, 8, 4)
    nav:setCost(8, 8, 7)
    local shallow_water = nav:getCost(7, 8)
    local deep_water = nav:getCost(8, 8)
    local dry_ground = nav:getCost(1, 1)

    pathfind_log("shallow water cost = " .. shallow_water)
    pathfind_log("deep water cost = " .. deep_water)
    pathfind_log("dry ground cost = " .. dry_ground)
end
```

---

#### `LNavGrid:getDiagonalMode`

Returns the current diagonal movement mode name.

```lua
LNavGrid:getDiagonalMode()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Mode name. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(10, 10)
    nav:setDiagonalMode("nocornercut")
    nav:setBlocked(4, 5, true)
    local mode = nav:getDiagonalMode()
    local blocked_neighbor = nav:isBlocked(4, 5)

    pathfind_log("formation diagonal mode = " .. mode)
    pathfind_log("blocked neighbor = " .. tostring(blocked_neighbor))
    pathfind_log("origin walkable = " .. tostring(nav:isWalkable(1, 1)))
end
```

---

#### `LNavGrid:getDimensions`

Returns grid width and height as two integers.

```lua
LNavGrid:getDimensions()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Grid width. |
| number | Grid height. |

**Example**

```lua
do
    local ng = lurek.pathfind.newNavGrid(20, 15)
    local w, h = ng:getDimensions()
    ng:setBlocked(10, 8, true)
    local width = ng:getWidth()
    local height = ng:getHeight()

    pathfind_log("nav dims = " .. w .. "x" .. h)
    pathfind_log("width via getter = " .. width)
    pathfind_log("height via getter = " .. height)
end
```

---

#### `LNavGrid:getHeight`

Returns grid height from this object.

```lua
LNavGrid:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Grid height. |

**Example**

```lua
do
    local ng = lurek.pathfind.newNavGrid(20, 15)
    local w, h = ng:getDimensions()
    local height = ng:getHeight()

    example_print_log("dims = " .. w .. "x" .. h)
    example_print_log("height = " .. height)
end
```

---

#### `LNavGrid:getWidth`

Returns grid width from this object.

```lua
LNavGrid:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Grid width. |

**Example**

```lua
do
    local ng = lurek.pathfind.newNavGrid(20, 15)
    local w, h = ng:getDimensions()
    local width = ng:getWidth()

    example_print_log("dims = " .. w .. "x" .. h)
    example_print_log("width = " .. width)
end
```

---

#### `LNavGrid:isBlocked`

Returns whether a one-based grid cell is blocked.

```lua
LNavGrid:isBlocked(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when blocked. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(30, 30)
    nav:fill(1)
    nav:setBlocked(12, 12, true)
    nav:setBlocked(13, 12, true)
    local barricade = nav:isBlocked(12, 12)
    local second_barricade = nav:isBlocked(13, 12)
    local alley = nav:isBlocked(12, 13)

    pathfind_log("barricade = " .. tostring(barricade))
    pathfind_log("second barricade = " .. tostring(second_barricade))
    pathfind_log("alley blocked = " .. tostring(alley))
end
```

---

#### `LNavGrid:isWalkable`

Returns whether a one-based grid cell is walkable for a unit size.

```lua
LNavGrid:isWalkable(x, y, unit_size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `unit_size?` | number | Unit footprint in cells (default 1). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when walkable. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)
    nav:setBlocked(6, 6, true)

    example_print_log("walkable_1x1 = " .. tostring(nav:isWalkable(5, 5)))
    example_print_log("walkable_blocked = " .. tostring(nav:isWalkable(6, 6)))
    example_print_log("walkable_2x2 = " .. tostring(nav:isWalkable(5, 5, 2)))
end
```

---

#### `LNavGrid:loadFromString`

Loads grid data from a serialized binary string.

```lua
LNavGrid:loadFromString(data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `data` | string | Serialized grid bytes. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(10, 10)

    nav:setBlocked(5, 5, true)
    nav:setCost(3, 3, 9)

    local data = nav:saveToString()
    local nav2 = lurek.pathfind.newNavGrid(10, 10)
    nav2:loadFromString(data)

    example_print_log("blocked_5_5 = " .. tostring(nav2:isBlocked(5, 5)))
    example_print_log("cost_3_3 = " .. nav2:getCost(3, 3))
end
```

---

#### `LNavGrid:rebuildAbstract`

Rebuilds the cached abstract graph for this grid.

```lua
LNavGrid:rebuildAbstract()
```

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(64, 64)

    nav:setChunkSize(8)
    nav:rebuildAbstract()

    example_print_log("chunk = " .. nav:getChunkSize())
    example_print_log("blocked_1_1 = " .. tostring(nav:isBlocked(1, 1)))
end
```

---

#### `LNavGrid:saveToString`

Saves grid data to a serialized binary string.

```lua
LNavGrid:saveToString()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Serialized grid bytes. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(10, 10)

    nav:setBlocked(5, 5, true)
    nav:setCost(3, 3, 9)

    local data = nav:saveToString()

    example_print_log("bytes = " .. #data)
    example_print_log("blocked_5_5 = " .. tostring(nav:isBlocked(5, 5)))
end
```

---

#### `LNavGrid:setBlocked`

Sets blocked state at a one-based grid cell.

```lua
LNavGrid:setBlocked(x, y, blocked)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `blocked` | boolean | True to block the cell. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(30, 30)
    nav:fill(1)
    nav:setBlocked(10, 10, true)
    nav:setBlocked(10, 11, true)
    local blocked_gate = nav:isBlocked(10, 10)
    local blocked_corridor = nav:isBlocked(10, 11)
    local detour_open = nav:isWalkable(11, 10)

    pathfind_log("main gate blocked = " .. tostring(blocked_gate))
    pathfind_log("corridor blocked = " .. tostring(blocked_corridor))
    pathfind_log("detour open = " .. tostring(detour_open))
end
```

---

#### `LNavGrid:setChunkSize`

Sets hierarchical chunk size for abstract graph partitioning.

```lua
LNavGrid:setChunkSize(size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `size` | number | Chunk side length in cells. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(100, 100)
    nav:setChunkSize(16)
    nav:rebuildAbstract()
    nav:setBlocked(40, 40, true)
    local chunk_size = nav:getChunkSize()
    local blocked_hub = nav:isBlocked(40, 40)

    pathfind_log("hpa chunk size = " .. chunk_size)
    pathfind_log("blocked logistics hub = " .. tostring(blocked_hub))
    pathfind_log("nav width = " .. nav:getWidth())
end
```

---

#### `LNavGrid:setCost`

Sets movement cost at a one-based grid cell.

```lua
LNavGrid:setCost(x, y, cost)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `cost` | number | Movement cost (0â€“255). |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(30, 30)
    nav:fill(1)
    nav:setCost(5, 5, 200)
    nav:setCost(5, 6, 25)
    local swamp_cost = nav:getCost(5, 5)
    local path_cost = nav:getCost(5, 6)
    local swamp_blocked = nav:isBlocked(5, 5)

    pathfind_log("swamp cost = " .. swamp_cost)
    pathfind_log("trail cost = " .. path_cost)
    pathfind_log("swamp blocked = " .. tostring(swamp_blocked))
end
```

---

#### `LNavGrid:setDiagonalMode`

Sets diagonal movement mode for this object.

```lua
LNavGrid:setDiagonalMode(mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | string | Mode name: `none`, `always`, or `nocornercut`. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(10, 10)
    nav:setDiagonalMode("always")
    nav:setBlocked(5, 5, true)
    local mode = nav:getDiagonalMode()
    local direct_corner = nav:isWalkable(4, 4)

    pathfind_log("scout diagonal mode = " .. mode)
    pathfind_log("corner tile open = " .. tostring(direct_corner))
    pathfind_log("blocked pivot = " .. tostring(nav:isBlocked(5, 5)))
end
```

---

#### `LNavGrid:setDirty`

Marks a one-based rectangular region dirty for incremental rebuild.

```lua
LNavGrid:setDirty(x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column of the top-left corner. |
| `y` | number | One-based row of the top-left corner. |
| `w` | number | Region width in cells. |
| `h` | number | Region height in cells. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(50, 50)

    nav:setChunkSize(10)
    nav:rebuildAbstract()
    nav:setBlocked(25, 25, true)
    nav:setDirty(20, 20, 10, 10)
    nav:rebuildAbstract()

    example_print_log("blocked_25_25 = " .. tostring(nav:isBlocked(25, 25)))
    example_print_log("chunk = " .. nav:getChunkSize())
end
```

---

#### `LNavGrid:type`

Returns the Lua-visible type name for this navigation grid handle.

```lua
LNavGrid:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LNavGrid](#lnavgrid)`. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(5, 5)
    nav:setCost(3, 3, 9)
    local type_name = nav:type()
    local dims = nav:getWidth() .. "x" .. nav:getHeight()
    local center_cost = nav:getCost(3, 3)

    pathfind_log("nav grid type = " .. type_name)
    pathfind_log("debug dims = " .. dims)
    pathfind_log("center cost = " .. center_cost)
end
```

---

#### `LNavGrid:typeOf`

Returns whether this navigation grid handle matches a supported type name.

```lua
LNavGrid:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | String value for `name`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(5, 5)
    nav:setBlocked(2, 3, true)
    local is_nav_grid = nav:typeOf("LNavGrid")
    local is_object = nav:typeOf("LObject")
    local is_path_grid = nav:typeOf("LPathGrid")

    pathfind_log("matches LNavGrid = " .. tostring(is_nav_grid))
    pathfind_log("matches LObject = " .. tostring(is_object))
    pathfind_log("matches LPathGrid = " .. tostring(is_path_grid))
end
```

---

## LNavMesh

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LNavMesh:addPolygon`

Adds a polygon from vertex tables and returns a one-based id.

```lua
LNavMesh:addPolygon(vertices)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `vertices` | table | Array of `{x, y}` vertex tables (minimum 3). |

**Returns**

| Type | Description |
|------|-------------|
| number | One-based polygon id. |

**Example**

```lua
do
    local mesh = lurek.pathfind.newNavMesh()
    local id = mesh:addPolygon({
        { x = 0, y = 0 },
        { x = 60, y = 0 },
        { x = 30, y = 45 },
    })

    example_print_log("polygon_id = " .. id)
    example_print_log("polygon_count = " .. mesh:getPolygonCount())
end
```

---

#### `LNavMesh:connectPolygons`

Connects two polygons by one-based id.

```lua
LNavMesh:connectPolygons(a, b, bidirectional)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `a` | number | One-based id of the first polygon. |
| `b` | number | One-based id of the second polygon. |
| `bidirectional?` | boolean | True for two-way link (default true). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the connection was added. |

**Example**

```lua
do
    local mesh = lurek.pathfind.newNavMesh()
    local a = mesh:addPolygon({
        { x = 0, y = 0 },
        { x = 50, y = 0 },
        { x = 25, y = 40 },
    })
    local b = mesh:addPolygon({
        { x = 50, y = 0 },
        { x = 100, y = 0 },
        { x = 75, y = 40 },
    })
    local c = mesh:addPolygon({
        { x = 25, y = 40 },
        { x = 75, y = 40 },
        { x = 50, y = 80 },
    })
    local ab = mesh:connectPolygons(a, b, true)
    local bc = mesh:connectPolygons(b, c, false)

    example_print_log("connected_ab = " .. tostring(ab))
    example_print_log("connected_bc = " .. tostring(bc))
    example_print_log("polygon_count = " .. mesh:getPolygonCount())
end
```

---

#### `LNavMesh:findPath`

Finds a path through the navmesh between world points.

```lua
LNavMesh:findPath(sx, sy, gx, gy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sx` | number | Start X in world coordinates. |
| `sy` | number | Start Y in world coordinates. |
| `gx` | number | Goal X in world coordinates. |
| `gy` | number | Goal Y in world coordinates. |

**Returns**

| Type | Description |
|------|-------------|
| LNavMeshFindPathResult | Array of `{x, y}` point tables, or nil when no path exists. |

**Example**

```lua
do
    local mesh = lurek.pathfind.newNavMesh()
    local p1 = mesh:addPolygon({
        { x = 0, y = 0 },
        { x = 100, y = 0 },
        { x = 100, y = 100 },
        { x = 0, y = 100 },
    })
    local p2 = mesh:addPolygon({
        { x = 100, y = 0 },
        { x = 200, y = 0 },
        { x = 200, y = 100 },
        { x = 100, y = 100 },
    })
    local p3 = mesh:addPolygon({
        { x = 200, y = 0 },
        { x = 300, y = 0 },
        { x = 300, y = 100 },
        { x = 200, y = 100 },
    })

    mesh:connectPolygons(p1, p2, true)
    mesh:connectPolygons(p2, p3, true)

    local path = mesh:findPath(10, 50, 290, 50)
    if path then
        example_print_log("waypoints = " .. #path)
        example_print_log("first = " .. path[1].x .. "," .. path[1].y)
        example_print_log("last = " .. path[#path].x .. "," .. path[#path].y)
    else
        example_print_log("waypoints = 0")
    end
end
```

---

#### `LNavMesh:getPolygonCount`

Returns the total navmesh polygon count.

```lua
LNavMesh:getPolygonCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Polygon count. |

**Example**

```lua
do
    local mesh = lurek.pathfind.newNavMesh()
    local id = mesh:addPolygon({
        { x = 0, y = 0 },
        { x = 64, y = 0 },
        { x = 32, y = 48 },
    })

    example_print_log("polygon_count = " .. mesh:getPolygonCount())
    example_print_log("first_id = " .. id)
end
```

---

#### `LNavMesh:type`

Returns the Lua-visible type name for this navmesh handle.

```lua
LNavMesh:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LNavMesh](#lnavmesh)`. |

**Example**

```lua
do
    local mesh = lurek.pathfind.newNavMesh()
    mesh:addPolygon({
        { x = 0, y = 0 },
        { x = 64, y = 0 },
        { x = 32, y = 48 },
    })
    local type_name = mesh:type()
    local polygon_count = mesh:getPolygonCount()

    pathfind_log("nav mesh type = " .. type_name)
    pathfind_log("triangle count = " .. polygon_count)
    pathfind_log("mesh ready for corridor routing = " .. tostring(polygon_count > 0))
end
```

---

#### `LNavMesh:typeOf`

Returns whether this navmesh handle matches a supported type name.

```lua
LNavMesh:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | String value for `name`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local mesh = lurek.pathfind.newNavMesh()
    mesh:addPolygon({
        { x = 0, y = 0 },
        { x = 32, y = 0 },
        { x = 16, y = 24 },
    })
    local is_nav_mesh = mesh:typeOf("LNavMesh")
    local is_object = mesh:typeOf("LObject")
    local is_goal_map = mesh:typeOf("LGoalMap")

    pathfind_log("matches LNavMesh = " .. tostring(is_nav_mesh))
    pathfind_log("matches LObject = " .. tostring(is_object))
    pathfind_log("matches LGoalMap = " .. tostring(is_goal_map))
end
```

---

## LPathGrid

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LPathGrid:findPath`

Finds a path between one-based path grid cells.

```lua
LPathGrid:findPath(sx, sy, gx, gy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sx` | number | One-based start column. |
| `sy` | number | One-based start row. |
| `gx` | number | One-based goal column. |
| `gy` | number | One-based goal row. |

**Returns**

| Type | Description |
|------|-------------|
| LPathGridFindPathResult | Array of `{x, y}` point tables, or nil when no path exists. |

**Example**

```lua
do
    local grid = lurek.pathfind.newPathGrid(10, 10, 32)

    for y = 1, 10 do
        grid:setWalkable(5, y, false)
    end
    grid:setWalkable(5, 8, true)

    local path = grid:findPath(1, 1, 10, 10)
    if path then
        example_print_log("steps = " .. #path)
        example_print_log("first = " .. path[1].x .. "," .. path[1].y)
        example_print_log("last = " .. path[#path].x .. "," .. path[#path].y)
    else
        example_print_log("steps = 0")
    end
end
```

---

#### `LPathGrid:findPathSmoothed`

Finds a smoothed path between one-based path grid cells.

```lua
LPathGrid:findPathSmoothed(sx, sy, gx, gy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sx` | number | One-based start column. |
| `sy` | number | One-based start row. |
| `gx` | number | One-based goal column. |
| `gy` | number | One-based goal row. |

**Returns**

| Type | Description |
|------|-------------|
| LPathGridFindPathSmoothedResult | Array of `{x, y}` point tables, or nil when no path exists. |

**Example**

```lua
do
    local grid = lurek.pathfind.newPathGrid(20, 20, 16)

    grid:setWalkable(10, 5, false)
    grid:setWalkable(10, 6, false)
    grid:setWalkable(10, 7, false)

    local path = grid:findPathSmoothed(1, 5, 20, 5)
    if path then
        example_print_log("points = " .. #path)
        example_print_log("first = " .. path[1].x .. "," .. path[1].y)
        example_print_log("last = " .. path[#path].x .. "," .. path[#path].y)
    else
        example_print_log("points = 0")
    end
end
```

---

#### `LPathGrid:getCellSize`

Returns path grid cell size from this object.

```lua
LPathGrid:getCellSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Cell size. |

**Example**

```lua
do
    local pg = lurek.pathfind.newPathGrid(10, 10, 32)
    pg:setWalkable(5, 5, false)
    local cell_size = pg:getCellSize()
    local dims = pg:getWidth() .. "x" .. pg:getHeight()
    local center_open = pg:isWalkable(5, 5)

    pathfind_log("cell size = " .. cell_size)
    pathfind_log("path grid dims = " .. dims)
    pathfind_log("center open = " .. tostring(center_open))
end
```

---

#### `LPathGrid:getCost`

Returns movement cost at a one-based cell.

```lua
LPathGrid:getCost(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |

**Returns**

| Type | Description |
|------|-------------|
| number | Movement cost. |

**Example**

```lua
do
    local grid = lurek.pathfind.newPathGrid(10, 10, 16)
    grid:setCost(6, 1, 1.5)
    grid:setCost(6, 2, 2.5)
    local bridge_cost = grid:getCost(6, 2)
    local lane_cost = grid:getCost(6, 1)
    local base_cost = grid:getCost(1, 1)

    pathfind_log("bridge tile cost = " .. bridge_cost)
    pathfind_log("lane tile cost = " .. lane_cost)
    pathfind_log("default tile cost = " .. base_cost)
end
```

---

#### `LPathGrid:getHeight`

Returns grid height from this object.

```lua
LPathGrid:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Grid height. |

**Example**

```lua
do
    local pg = lurek.pathfind.newPathGrid(10, 10, 32)
    pg:setCost(6, 6, 4)
    local height = pg:getHeight()
    local width = pg:getWidth()
    local center_cost = pg:getCost(6, 6)

    pathfind_log("height = " .. height)
    pathfind_log("width = " .. width)
    pathfind_log("center cost = " .. center_cost)
end
```

---

#### `LPathGrid:getWidth`

Returns grid width from this object.

```lua
LPathGrid:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Grid width. |

**Example**

```lua
do
    local pg = lurek.pathfind.newPathGrid(10, 10, 32)
    pg:setCost(4, 4, 3)
    local width = pg:getWidth()
    local height = pg:getHeight()
    local cell_size = pg:getCellSize()

    pathfind_log("width = " .. width)
    pathfind_log("height = " .. height)
    pathfind_log("cell size = " .. cell_size)
end
```

---

#### `LPathGrid:isWalkable`

Returns walkability at a one-based cell.

```lua
LPathGrid:isWalkable(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when walkable. |

**Example**

```lua
do
    local grid = lurek.pathfind.newPathGrid(20, 15, 32)
    grid:setWalkable(4, 4, false)
    grid:setWalkable(4, 5, true)
    local tower_cell = grid:isWalkable(4, 4)
    local stairs_cell = grid:isWalkable(4, 5)
    local courtyard_cell = grid:isWalkable(5, 5)

    pathfind_log("tower cell walkable = " .. tostring(tower_cell))
    pathfind_log("stairs cell walkable = " .. tostring(stairs_cell))
    pathfind_log("courtyard cell walkable = " .. tostring(courtyard_cell))
end
```

---

#### `LPathGrid:setCost`

Sets movement cost at a one-based cell.

```lua
LPathGrid:setCost(x, y, cost)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `cost` | number | Movement cost value. |

**Example**

```lua
do
    local grid = lurek.pathfind.newPathGrid(10, 10, 16)
    grid:setCost(3, 2, 2)
    grid:setCost(3, 3, 5)
    local mud_cost = grid:getCost(3, 3)
    local road_cost = grid:getCost(3, 2)
    local plain_cost = grid:getCost(3, 4)

    pathfind_log("mud tile cost = " .. mud_cost)
    pathfind_log("road tile cost = " .. road_cost)
    pathfind_log("plain tile cost = " .. plain_cost)
end
```

---

#### `LPathGrid:setWalkable`

Sets walkability at a one-based cell.

```lua
LPathGrid:setWalkable(x, y, w)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `w` | boolean | True to mark the cell walkable. |

**Example**

```lua
do
    local grid = lurek.pathfind.newPathGrid(20, 15, 32)
    grid:setWalkable(6, 7, false)
    grid:setWalkable(5, 5, false)
    local blocked_gate = grid:isWalkable(5, 5)
    local flank_route = grid:isWalkable(5, 6)
    local guard_post = grid:isWalkable(6, 7)

    pathfind_log("main gate open = " .. tostring(blocked_gate))
    pathfind_log("flank route open = " .. tostring(flank_route))
    pathfind_log("guard post open = " .. tostring(guard_post))
end
```

---

#### `LPathGrid:type`

Returns the Lua-visible type name for this path grid handle.

```lua
LPathGrid:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LPathGrid](#lpathgrid)`. |

**Example**

```lua
do
    local grid = lurek.pathfind.newPathGrid(5, 5, 32)
    grid:setWalkable(3, 3, false)
    local type_name = grid:type()
    local width = grid:getWidth()
    local height = grid:getHeight()
    local blocked_center = grid:isWalkable(3, 3)

    pathfind_log("path grid type = " .. type_name)
    pathfind_log("training grid = " .. width .. "x" .. height)
    pathfind_log("center walkable = " .. tostring(blocked_center))
end
```

---

#### `LPathGrid:typeOf`

Returns whether this path grid handle matches a supported type name.

```lua
LPathGrid:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | String value for `name`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local grid = lurek.pathfind.newPathGrid(5, 5, 32)
    grid:setCost(2, 2, 3)
    local is_path_grid = grid:typeOf("LPathGrid")
    local is_object = grid:typeOf("LObject")
    local is_nav_grid = grid:typeOf("LNavGrid")

    pathfind_log("matches LPathGrid = " .. tostring(is_path_grid))
    pathfind_log("matches LObject = " .. tostring(is_object))
    pathfind_log("matches LNavGrid = " .. tostring(is_nav_grid))
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
| number? | Index of the new layer (1-based). |
| string? | Error message when validation fails. |

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
| number? | Global tile ID at that position. |
| string? | Error message on failure. |

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
| string? | Error message on failure. |

---

#### `LTileMap:trySetTileTint`

Sets a per-cell tint override and returns `false, error` instead of throwing on invalid input.

```lua
LTileMap:trySetTileTint(layer, x, y, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | any |  |
| `x` | any |  |
| `y` | any |  |
| `r` | any |  |
| `g` | any |  |
| `b` | any |  |
| `a` | any |  |

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
| number? | Tile column (1-based). |
| number? | Tile row (1-based). |

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

## LUnitPathfinder

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LUnitPathfinder:clearCache`

Clears all cached paths on this object.

```lua
LUnitPathfinder:clearCache()
```

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    pf:setCacheEnabled(true)
    pf:findPath(1, 1, 20, 20)

    example_print_log("cache_before_clear = " .. pf:getCacheSize())
    pf:clearCache()
    example_print_log("cache_after_clear = " .. pf:getCacheSize())
end
```

---

#### `LUnitPathfinder:findNearestWalkable`

Finds nearest walkable one-based grid cell within a radius.

```lua
LUnitPathfinder:findNearestWalkable(x, y, max_radius, unit_size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column of the search origin. |
| `y` | number | One-based row of the search origin. |
| `max_radius` | number | Maximum search radius in cells. |
| `unit_size?` | number | Unit footprint in cells (default 1). |

**Returns**

| Type | Description |
|------|-------------|
| number | One-based column of the nearest walkable cell; or nil. |
| number | One-based row of the nearest walkable cell; or nil. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)
    nav:setBlocked(10, 10, true)
    nav:setBlocked(11, 10, true)
    nav:setBlocked(10, 11, true)
    nav:setBlocked(11, 11, true)

    local pf = lurek.pathfind.newPathfinder(nav)
    local nx, ny = pf:findNearestWalkable(10, 10, 5)

    example_print_log("nearest = " .. nx .. "," .. ny)
end
```

---

#### `LUnitPathfinder:findPartialPath`

Finds the best reachable path from a start to a goal within a maximum node budget. Useful for incremental pathfinding across frames.

```lua
LUnitPathfinder:findPartialPath(x1, y1, x2, y2, max_nodes, unit_size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x1` | number | One-based column of the start cell. |
| `y1` | number | One-based row of the start cell. |
| `x2` | number | One-based column of the goal cell. |
| `y2` | number | One-based row of the goal cell. |
| `max_nodes` | number | Maximum number of nodes to expand before stopping. |
| `unit_size?` | number | Width/height of the unit in grid cells for clearance checks (default 1). |

**Returns**

| Type | Description |
|------|-------------|
| LUnitPathfinderFindPartialPathResult | Array of `{x; y}` waypoint tables forming the found partial path. |
| boolean | `true` if the returned path reaches the exact goal cell. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(100, 100)

    nav:fill(1)
    nav:fillRect(40, 1, 1, 100, 0)
    nav:fillRect(40, 50, 1, 1, 1)

    local pf = lurek.pathfind.newPathfinder(nav)
    local path, reached = pf:findPartialPath(1, 1, 100, 100, 50)

    example_print_log("points = " .. #path)
    example_print_log("reached = " .. tostring(reached))
    example_print_log("last = " .. path[#path].x .. "," .. path[#path].y)
end
```

---

#### `LUnitPathfinder:findPath`

Finds a path between one-based grid cells.

```lua
LUnitPathfinder:findPath(x1, y1, x2, y2, unit_size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x1` | number | One-based start column. |
| `y1` | number | One-based start row. |
| `x2` | number | One-based goal column. |
| `y2` | number | One-based goal row. |
| `unit_size?` | number | Unit footprint in cells (default 1). |

**Returns**

| Type | Description |
|------|-------------|
| LUnitPathfinderFindPathResult | Array of `{x, y}` waypoint tables, or nil when no path exists. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(30, 30)

    nav:fill(1)
    nav:setBlocked(15, 10, true)
    nav:setBlocked(15, 11, true)
    nav:setBlocked(15, 12, true)
    nav:setBlocked(15, 13, true)

    local pf = lurek.pathfind.newPathfinder(nav)
    local path = pf:findPath(1, 12, 30, 12)
    if path then
        example_print_log("steps = " .. #path)
        example_print_log("first = " .. path[1].x .. "," .. path[1].y)
        example_print_log("last = " .. path[#path].x .. "," .. path[#path].y)
    else
        example_print_log("steps = 0")
    end
end
```

---

#### `LUnitPathfinder:findPathBidirectional`

Finds a path using bidirectional A* and returns completion status.

```lua
LUnitPathfinder:findPathBidirectional(x1, y1, x2, y2, unit_size, max_nodes)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x1` | number | One-based column of the start cell. |
| `y1` | number | One-based row of the start cell. |
| `x2` | number | One-based column of the goal cell. |
| `y2` | number | One-based row of the goal cell. |
| `unit_size?` | number | Width or height of the unit in grid cells for clearance checks (default 1). |
| `max_nodes?` | number | Optional node-expansion budget; 0 uses the full search. |

**Returns**

| Type | Description |
|------|-------------|
| LUnitPathfinderFindPathBidirectionalResult | Array of waypoint tables; or nil when no path exists. |
| boolean | True when the path is complete. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(40, 40)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    local path, complete = pf:findPathBidirectional(1, 1, 40, 40, 1, 500)
    if path then
        example_print_log("points = " .. #path)
        example_print_log("complete = " .. tostring(complete))
        example_print_log("last = " .. path[#path].x .. "," .. path[#path].y)
    else
        example_print_log("complete = " .. tostring(complete))
    end
end
```

---

#### `LUnitPathfinder:findPathSmooth`

Finds a smoothed path between one-based grid cells.

```lua
LUnitPathfinder:findPathSmooth(x1, y1, x2, y2, unit_size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x1` | number | One-based start column. |
| `y1` | number | One-based start row. |
| `x2` | number | One-based goal column. |
| `y2` | number | One-based goal row. |
| `unit_size?` | number | Unit footprint in cells (default 1). |

**Returns**

| Type | Description |
|------|-------------|
| LUnitPathfinderFindPathSmoothResult | Array of `{x, y}` waypoint tables, or nil when no path exists. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    local path = pf:findPathSmooth(1, 1, 20, 20)
    if path then
        example_print_log("points = " .. #path)
        example_print_log("first = " .. path[1].x .. "," .. path[1].y)
        example_print_log("last = " .. path[#path].x .. "," .. path[#path].y)
    else
        example_print_log("points = 0")
    end
end
```

---

#### `LUnitPathfinder:getCacheSize`

Returns the current path cache entry count.

```lua
LUnitPathfinder:getCacheSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Cache size. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    pf:setCacheEnabled(true)
    pf:findPath(1, 1, 20, 20)
    pf:findPath(5, 5, 15, 15)

    example_print_log("cache_size = " .. pf:getCacheSize())
end
```

---

#### `LUnitPathfinder:getPathCost`

Returns the total movement cost along a waypoint path.

```lua
LUnitPathfinder:getPathCost(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | table | Array of `{x, y}` waypoint tables. |

**Returns**

| Type | Description |
|------|-------------|
| number | Path cost. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(10, 10)

    nav:fill(1)
    nav:setCost(5, 5, 4)

    local pf = lurek.pathfind.newPathfinder(nav)
    local path = pf:findPath(1, 1, 10, 10)
    if path then
        example_print_log("cost = " .. pf:getPathCost(path))
        example_print_log("length = " .. pf:getPathLength(path))
    else
        example_print_log("cost = 0")
    end
end
```

---

#### `LUnitPathfinder:getPathLength`

Returns the total Euclidean length of a waypoint path.

```lua
LUnitPathfinder:getPathLength(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | table | Array of `{x, y}` waypoint tables. |

**Returns**

| Type | Description |
|------|-------------|
| number | Path length. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(10, 10)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    local path = pf:findPath(1, 1, 10, 10)
    if path then
        example_print_log("length = " .. pf:getPathLength(path))
        example_print_log("cost = " .. pf:getPathCost(path))
    else
        example_print_log("length = 0")
    end
end
```

---

#### `LUnitPathfinder:heuristicDistance`

Returns heuristic distance between two one-based cells.

```lua
LUnitPathfinder:heuristicDistance(x1, y1, x2, y2)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x1` | number | One-based column of the first cell. |
| `y1` | number | One-based row of the first cell. |
| `x2` | number | One-based column of the second cell. |
| `y2` | number | One-based row of the second cell. |

**Returns**

| Type | Description |
|------|-------------|
| number | Heuristic distance. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(20, 20)
    local pf = lurek.pathfind.newPathfinder(nav)
    nav:setBlocked(10, 10, true)
    local map_corner = pf:heuristicDistance(1, 1, 20, 20)
    local same_cell = pf:heuristicDistance(5, 5, 5, 5)
    local front_line = pf:heuristicDistance(2, 10, 18, 10)

    pathfind_log("corner estimate = " .. map_corner)
    pathfind_log("same cell estimate = " .. same_cell)
    pathfind_log("front line estimate = " .. front_line)
end
```

---

#### `LUnitPathfinder:isCacheEnabled`

Returns whether path cache is enabled.

```lua
LUnitPathfinder:isCacheEnabled()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when enabled. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    pf:setCacheEnabled(true)
    local enabled = pf:isCacheEnabled()
    pf:setCacheEnabled(false)

    example_print_log("enabled_before_disable = " .. tostring(enabled))
    example_print_log("enabled_after_disable = " .. tostring(pf:isCacheEnabled()))
end
```

---

#### `LUnitPathfinder:isReachable`

Returns whether a target cell is reachable from a start cell.

```lua
LUnitPathfinder:isReachable(x1, y1, x2, y2, unit_size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x1` | number | One-based start column. |
| `y1` | number | One-based start row. |
| `x2` | number | One-based target column. |
| `y2` | number | One-based target row. |
| `unit_size?` | number | Unit footprint in cells (default 1). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when reachable. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)
    nav:fillRect(10, 1, 1, 20, 0)

    local pf = lurek.pathfind.newPathfinder(nav)

    example_print_log("reachable_left = " .. tostring(pf:isReachable(1, 1, 9, 9)))
    example_print_log("reachable_right = " .. tostring(pf:isReachable(1, 1, 20, 20)))
end
```

---

#### `LUnitPathfinder:lineOfSight`

Returns whether two one-based cells have line of sight.

```lua
LUnitPathfinder:lineOfSight(x1, y1, x2, y2, unit_size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x1` | number | One-based column of the first cell. |
| `y1` | number | One-based row of the first cell. |
| `x2` | number | One-based column of the second cell. |
| `y2` | number | One-based row of the second cell. |
| `unit_size?` | number | Unit footprint in cells (default 1). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when line of sight is clear. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    local clear = pf:lineOfSight(1, 1, 20, 20)
    nav:setBlocked(10, 10, true)
    local blocked = pf:lineOfSight(1, 1, 20, 20)

    example_print_log("clear = " .. tostring(clear))
    example_print_log("blocked = " .. tostring(blocked))
end
```

---

#### `LUnitPathfinder:setCacheEnabled`

Enables or disables the path cache on this object.

```lua
LUnitPathfinder:setCacheEnabled(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | boolean | True to enable caching. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    pf:setCacheEnabled(true)
    pf:setCacheMaxSize(100)
    pf:findPath(1, 1, 20, 20)
    pf:findPath(5, 5, 15, 15)

    example_print_log("enabled = " .. tostring(pf:isCacheEnabled()))
    example_print_log("cache_size = " .. pf:getCacheSize())
    pf:clearCache()
    example_print_log("cache_after_clear = " .. pf:getCacheSize())
end
```

---

#### `LUnitPathfinder:setCacheMaxSize`

Sets maximum path cache size for this object.

```lua
LUnitPathfinder:setCacheMaxSize(n)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `n` | number | Maximum number of cached paths. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    pf:setCacheEnabled(true)
    pf:setCacheMaxSize(2)
    pf:findPath(1, 1, 20, 20)
    pf:findPath(2, 2, 19, 19)
    pf:findPath(3, 3, 18, 18)

    example_print_log("cache_size = " .. pf:getCacheSize())
end
```

---

#### `LUnitPathfinder:type`

Returns the Lua-visible type name for this pathfinder handle.

```lua
LUnitPathfinder:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LUnitPathfinder](#lunitpathfinder)`. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(5, 5)
    local pf = lurek.pathfind.newPathfinder(nav)
    nav:fill(1)
    local type_name = pf:type()
    local path = pf:findPath(1, 1, 5, 5)
    local cache_enabled = pf:isCacheEnabled()

    pathfind_log("pathfinder type = " .. type_name)
    pathfind_log("route nodes = " .. tostring(path and #path or 0))
    pathfind_log("cache enabled = " .. tostring(cache_enabled))
end
```

---

#### `LUnitPathfinder:typeOf`

Returns whether this pathfinder handle matches a supported type name.

```lua
LUnitPathfinder:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | String value for `name`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(5, 5)
    local pf = lurek.pathfind.newPathfinder(nav)
    nav:fill(1)
    local is_pathfinder = pf:typeOf("LUnitPathfinder")
    local is_object = pf:typeOf("LObject")
    local is_nav_grid = pf:typeOf("LNavGrid")

    pathfind_log("matches LUnitPathfinder = " .. tostring(is_pathfinder))
    pathfind_log("matches LObject = " .. tostring(is_object))
    pathfind_log("matches LNavGrid = " .. tostring(is_nav_grid))
end
```

---
