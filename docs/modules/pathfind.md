# Pathfind

- The `pathfind` module is a comprehensive Feature Systems tier library providing a vast array of pathfinding algorithms and spatial reasoning tools for Lurek2D.

It is designed to handle everything from simple grid-based movement to complex, multi-agent AI steering and hierarchical navigation. The foundation of the module is the `NavGrid`, a robust 2D grid structure supporting per-cell walkability masks, integer-based movement costs, and configurable diagonal movement policies (with corner-cutting prevention). On top of this, the module implements classical algorithms like A* (with octile or Manhattan heuristics), Dijkstra's algorithm for cost-weighted reachability, and unweighted BFS. For high-performance uniform-cost grids, it features Jump Point Search (JPS), which dramatically accelerates A* by pruning symmetric neighbors.

To address the challenges of large open worlds and massive agent counts, the module includes several advanced AI pathing techniques. Hierarchical Pathfinding A* (HPA*) partitions grids into chunks, building an abstract graph of boundary entrances to allow near-instant long-distance path planning that is later refined into tile-by-tile routes. For crowd simulation, the `FlowField` and `ai_flow_field` structures precompute directional vectors across a grid toward a specific goal, allowing hundreds of agents to steer smoothly without calculating individual paths. Additionally, the `InfluenceMap` system allows developers to propagate, blend, and decay scalar values across grids—perfect for tactical AI to evaluate threat levels, control zones, or attractive points of interest.

Beyond standard square grids, the module offers extensive support for alternative spatial layouts. It includes a fully featured `HexGrid` with cube-coordinate math, supporting both pointy-top and flat-top layouts, alongside specific line-of-sight and field-of-view queries. An `IsoGrid` provides specialized routing for isometric map layouts. For non-grid environments, the `NavMesh` structure allows A* routing across connected arbitrary polygons, extracting smoothed centroid corridors. To ensure pathfinding never stalls the primary game loop, the module features a dedicated `PathThreadPool`, allowing asynchronous, off-thread path requests via non-blocking channels. Finally, the `UnitPathfinder` provides a high-level, stateful wrapper for individual agents, handling path caching, variable unit sizes (clearance checks), partial paths, and string-pull smoothing. The entire suite is accessible via the `lurek.pathfind.*` Lua API.

## Functions

### `lurek.pathfind.getThreadCount`

Returns the configured pathfinding thread count.

```lua
-- signature
lurek.pathfind.getThreadCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Thread count (minimum 1). |

**Example**

```lua
do
    local tc = lurek.pathfind.getThreadCount()

    print("thread_count = " .. tc)
end
```

---

### `lurek.pathfind.newFlowField`

Creates a flow field for a navigation grid.

```lua
-- signature
lurek.pathfind.newFlowField(grid_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `grid_ud` | `LNavGrid` | Navigation grid to compute flow field from. |

**Returns**

| Type | Description |
|------|-------------|
| `LFlowField` | New flow field handle. |

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

    print("calculated = " .. tostring(ff:isCalculated()))
    print("targets = " .. #ff:getTargets())
end
```

---

### `lurek.pathfind.newHexGrid`

Creates a hex grid with the given dimensions.

```lua
-- signature
lurek.pathfind.newHexGrid(width, height, layout_str)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | `number` | Grid width in hex columns. |
| `height` | `number` | Grid height in hex rows. |
| `layout_str?` | `string` | Hex layout: `flat` (default) or `pointy`. |

**Returns**

| Type | Description |
|------|-------------|
| `LHexGrid` | New hex grid handle. |

**Example**

```lua
do
    local hex = lurek.pathfind.newHexGrid(12, 10, "flat")

    hex:setBlocked(5, 5, true)
    hex:setBlocked(6, 5, true)

    print("blocked_5_5 = " .. tostring(hex:isBlocked(5, 5)))
    print("blocked_1_1 = " .. tostring(hex:isBlocked(1, 1)))
end
```

---

### `lurek.pathfind.newJpsGrid`

Creates a Jump Point Search grid with given dimensions.

```lua
-- signature
lurek.pathfind.newJpsGrid(width, height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | `number` | Grid width in cells. |
| `height` | `number` | Grid height in cells. |

**Returns**

| Type | Description |
|------|-------------|
| `LJpsGrid` | New JPS grid handle. |

**Example**

```lua
do
    local jps = lurek.pathfind.newJpsGrid(30, 30)

    jps:setBlocked(15, 10, true)
    jps:setBlocked(15, 11, true)
    jps:setBlocked(15, 12, true)

    print("blocked_15_10 = " .. tostring(jps:isBlocked(15, 10)))
    print("blocked_1_1 = " .. tostring(jps:isBlocked(1, 1)))
end
```

---

### `lurek.pathfind.newNavGrid`

Creates a navigation grid with the given dimensions.

```lua
-- signature
lurek.pathfind.newNavGrid(width, height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | `number` | Grid width in cells. |
| `height` | `number` | Grid height in cells. |

**Returns**

| Type | Description |
|------|-------------|
| `LNavGrid` | New navigation grid handle. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(50, 50)
    local w, h = nav:getDimensions()

    print("dims = " .. w .. "x" .. h)
    print("chunk = " .. nav:getChunkSize())
end
```

---

### `lurek.pathfind.newNavGridFromTileMap`

Creates a navigation grid from a tilemap layer and blocked gid table.

```lua
-- signature
lurek.pathfind.newNavGridFromTileMap(tm_ud, layer_index, blocked_table)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tm_ud` | `LTileMap` | Tilemap to derive navigation grid from. |
| `layer_index` | `number` | One-based tilemap layer index. |
| `blocked_table` | `table` | Array of tile GIDs that should be blocked. |

**Returns**

| Type | Description |
|------|-------------|
| `LNavGrid` | New navigation grid handle. |

**Example**

```lua
do
    local tm = lurek.tilemap.newTileMap(16, 16, 8)
    local layer_index = tm:addLayer("ground", 8, 8)

    tm:setTile(layer_index, 3, 3, 2)
    tm:setTile(layer_index, 4, 3, 1)

    local ng = lurek.pathfind.newNavGridFromTileMap(tm, layer_index, { 2 })

    print("dims = " .. ng:getWidth() .. "x" .. ng:getHeight())
    print("blocked_3_3 = " .. tostring(ng:isBlocked(3, 3)))
    print("blocked_4_3 = " .. tostring(ng:isBlocked(4, 3)))
end
```

---

### `lurek.pathfind.newNavMesh`

Creates an empty navigation mesh for polygon-based pathfinding.

```lua
-- signature
lurek.pathfind.newNavMesh()
```

**Returns**

| Type | Description |
|------|-------------|
| `LNavMesh` | New navmesh handle. |

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

    print("polygons = " .. mesh:getPolygonCount())
    print("ids = " .. id1 .. "," .. id2)
end
```

---

### `lurek.pathfind.newPathFlowField`

Creates an AI flow field from a path grid.

```lua
-- signature
lurek.pathfind.newPathFlowField(grid_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `grid_ud` | `LPathGrid` | Path grid to compute AI flow field from. |

**Returns**

| Type | Description |
|------|-------------|
| `LAIFlowField` | New AI flow field handle. |

**Example**

```lua
do
    local grid = lurek.pathfind.newPathGrid(15, 15, 32)
    local aiff = lurek.pathfind.newPathFlowField(grid)

    aiff:setGoal(10, 10)

    local gx, gy = aiff:getGoal()
    print("dims = " .. aiff:getWidth() .. "x" .. aiff:getHeight())
    print("has_goal = " .. tostring(aiff:hasGoal()))
    print("goal = " .. gx .. "," .. gy)
end
```

---

### `lurek.pathfind.newPathGrid`

Creates a cell-size path grid with given dimensions.

```lua
-- signature
lurek.pathfind.newPathGrid(w, h, cell_size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | `number` | Grid width in cells. |
| `h` | `number` | Grid height in cells. |
| `cell_size` | `number` | World-space size of each cell. |

**Returns**

| Type | Description |
|------|-------------|
| `LPathGrid` | New path grid handle. |

**Example**

```lua
do
    local grid = lurek.pathfind.newPathGrid(20, 15, 32)

    print("grid = " .. grid:getWidth() .. "x" .. grid:getHeight())
    print("cell_size = " .. grid:getCellSize())
end
```

---

### `lurek.pathfind.newPathfinder`

Creates a unit pathfinder for a navigation grid.

```lua
-- signature
lurek.pathfind.newPathfinder(grid_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `grid_ud` | `LNavGrid` | Navigation grid to pathfind on. |

**Returns**

| Type | Description |
|------|-------------|
| `LUnitPathfinder` | New pathfinder handle. |

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
        print("steps = " .. #path)
        print("first = " .. path[1].x .. "," .. path[1].y)
        print("last = " .. path[#path].x .. "," .. path[#path].y)
    else
        print("steps = 0")
    end
end
```

---

### `lurek.pathfind.rangeMap`

Computes reachable cells from range map options.

```lua
-- signature
lurek.pathfind.rangeMap(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | `table` | Options with dimensions, origin, budget, optional diagonal flag, costs, and blocked cells. |

**Returns**

| Type | Description |
|------|-------------|
| `PathfindRangeMapResult` | Range map result with `cells`, `width`, and `height` fields. |

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

    print("dims = " .. result.width .. "x" .. result.height)
    print("cells = " .. #result.cells)
    if #result.cells > 0 then
        print("first = " .. result.cells[1].x .. "," .. result.cells[1].y .. "," .. result.cells[1].cost)
    end
end
```

---

### `lurek.pathfind.setThreadCount`

Sets the configured pathfinding worker-thread count.

```lua
-- signature
lurek.pathfind.setThreadCount(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | `number` | Desired thread count. |

**Example**

```lua
do
    lurek.pathfind.setThreadCount(2)

    print("thread_count = " .. lurek.pathfind.getThreadCount())
end
```

---

## LAIFlowField

### `LAIFlowField:getDirection`

Returns flow direction vector for a one-based cell.

```lua
-- signature
LAIFlowField:getDirection(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | One-based column. |
| `y` | `number` | One-based row. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Direction X component. |
| `number` | b Direction Y component. |

**Example**

```lua
do
    local grid = lurek.pathfind.newPathGrid(10, 10, 16)
    local aiff = lurek.pathfind.newPathFlowField(grid)

    aiff:setGoal(10, 10)

    local dx, dy = aiff:getDirection(1, 1)
    print("dir = " .. dx .. "," .. dy)
    print("distance = " .. aiff:getDistance(1, 1))
end
```

---

### `LAIFlowField:getDistance`

Returns distance to goal for a one-based cell.

```lua
-- signature
LAIFlowField:getDistance(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | One-based column. |
| `y` | `number` | One-based row. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Distance to the goal. |

**Example**

```lua
do
    local grid = lurek.pathfind.newPathGrid(10, 10, 16)
    local aiff = lurek.pathfind.newPathFlowField(grid)

    aiff:setGoal(10, 10)

    local dx, dy = aiff:getDirection(1, 1)
    print("dir = " .. dx .. "," .. dy)
    print("distance = " .. aiff:getDistance(1, 1))
end
```

---

### `LAIFlowField:getGoal`

Returns the one-based flow field goal, or nil when no goal is set.

```lua
-- signature
LAIFlowField:getGoal()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a One-based goal column, or nil. |
| `number` | b One-based goal row, or nil. |

**Example**

```lua
do
    local grid = lurek.pathfind.newPathGrid(15, 15, 32)
    local aiff = lurek.pathfind.newPathFlowField(grid)

    aiff:setGoal(10, 10)

    local gx, gy = aiff:getGoal()
    print("goal = " .. gx .. "," .. gy)
    print("has_goal = " .. tostring(aiff:hasGoal()))
end
```

---

### `LAIFlowField:getHeight`

Returns flow field height from this object.

```lua
-- signature
LAIFlowField:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Height. |

**Example**

```lua
do
    local pg = lurek.pathfind.newPathGrid(32, 32, 1)
    local ff = lurek.pathfind.newPathFlowField(pg)

    ff:setGoal(16, 16)

    print("dims = " .. ff:getWidth() .. "x" .. ff:getHeight())
    print("has_goal = " .. tostring(ff:hasGoal()))
end
```

---

### `LAIFlowField:getWidth`

Returns flow field width from this object.

```lua
-- signature
LAIFlowField:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Width. |

**Example**

```lua
do
    local pg = lurek.pathfind.newPathGrid(32, 32, 1)
    local ff = lurek.pathfind.newPathFlowField(pg)

    ff:setGoal(16, 16)

    print("dims = " .. ff:getWidth() .. "x" .. ff:getHeight())
    print("has_goal = " .. tostring(ff:hasGoal()))
end
```

---

### `LAIFlowField:hasGoal`

Returns whether a flow field goal is currently set.

```lua
-- signature
LAIFlowField:hasGoal()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when a goal exists. |

**Example**

```lua
do
    local pg = lurek.pathfind.newPathGrid(32, 32, 1)
    local ff = lurek.pathfind.newPathFlowField(pg)

    print("has_goal_before = " .. tostring(ff:hasGoal()))
    ff:setGoal(16, 16)
    print("has_goal_after = " .. tostring(ff:hasGoal()))
end
```

---

### `LAIFlowField:setGoal`

Sets the one-based flow field goal and recalculates the field.

```lua
-- signature
LAIFlowField:setGoal(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | One-based goal column. |
| `y` | `number` | One-based goal row. |

**Example**

```lua
do
    local grid = lurek.pathfind.newPathGrid(15, 15, 32)
    local aiff = lurek.pathfind.newPathFlowField(grid)

    aiff:setGoal(10, 10)

    local gx, gy = aiff:getGoal()
    print("has_goal = " .. tostring(aiff:hasGoal()))
    print("goal = " .. gx .. "," .. gy)
end
```

---

### `LAIFlowField:type`

Returns the Lua-visible type name for this AI flow field handle.

```lua
-- signature
LAIFlowField:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LAIFlowField`. |

**Example**

```lua
do
    local grid = lurek.pathfind.newPathGrid(5, 5, 32)
    local aiff = lurek.pathfind.newPathFlowField(grid)

    print("type = " .. aiff:type())
end
```

---

### `LAIFlowField:typeOf`

Returns whether this AI flow field handle matches a supported type name.

```lua
-- signature
LAIFlowField:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | String value for `name`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local grid = lurek.pathfind.newPathGrid(5, 5, 32)
    local aiff = lurek.pathfind.newPathFlowField(grid)

    print("is_ai_flow_field = " .. tostring(aiff:typeOf("LAIFlowField")))
    print("is_object = " .. tostring(aiff:typeOf("LObject")))
end
```

---

## LFlowField

### `LFlowField:calculate`

Calculates a flow field toward one target cell.

```lua
-- signature
LFlowField:calculate(tx, ty, unit_size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tx` | `number` | One-based target column. |
| `ty` | `number` | One-based target row. |
| `unit_size?` | `number` | Unit footprint in cells (default 1). |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)

    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(20, 10)

    print("calculated = " .. tostring(ff:isCalculated()))
    print("targets = " .. #ff:getTargets())
end
```

---

### `LFlowField:calculateMulti`

Calculates a flow field toward multiple target cells.

```lua
-- signature
LFlowField:calculateMulti(targets, unit_size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `targets` | `table` | Array of `{x, y}` target tables. |
| `unit_size?` | `number` | Unit footprint in cells (default 1). |

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
    print("targets = " .. #targets)
    print("first = " .. targets[1].x .. "," .. targets[1].y)
    print("last = " .. targets[#targets].x .. "," .. targets[#targets].y)
end
```

---

### `LFlowField:getCostToTarget`

Returns integration cost to the target from a one-based grid cell.

```lua
-- signature
LFlowField:getCostToTarget(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | One-based column. |
| `y` | `number` | One-based row. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Integration cost to the nearest target. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(10, 10)

    nav:fill(1)

    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(10, 10)

    local dx, dy = ff:getDirection(1, 1)
    print("dir = " .. dx .. "," .. dy)
    print("cost = " .. ff:getCostToTarget(1, 1))
end
```

---

### `LFlowField:getDirection`

Returns flow direction vector at a one-based grid cell.

```lua
-- signature
LFlowField:getDirection(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | One-based column. |
| `y` | `number` | One-based row. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Direction X component. |
| `number` | b Direction Y component. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(10, 10)

    nav:fill(1)

    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(10, 10)

    local dx, dy = ff:getDirection(1, 1)
    print("dir = " .. dx .. "," .. dy)
    print("angle = " .. ff:getDirectionAngle(1, 1))
    print("cost = " .. ff:getCostToTarget(1, 1))
end
```

---

### `LFlowField:getDirectionAngle`

Returns flow direction angle at a one-based grid cell.

```lua
-- signature
LFlowField:getDirectionAngle(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | One-based column. |
| `y` | `number` | One-based row. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Direction angle in radians. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(10, 10)

    nav:fill(1)

    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(10, 10)

    print("angle = " .. ff:getDirectionAngle(1, 1))
    print("cost = " .. ff:getCostToTarget(1, 1))
end
```

---

### `LFlowField:getTargets`

Returns target cells for this flow field.

```lua
-- signature
LFlowField:getTargets()
```

**Returns**

| Type | Description |
|------|-------------|
| `LFlowFieldGetTargetsResult` | Array table of target point tables. |

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
    print("targets = " .. #targets)
    print("first = " .. targets[1].x .. "," .. targets[1].y)
end
```

---

### `LFlowField:isCalculated`

Returns whether the flow field has been calculated.

```lua
-- signature
LFlowField:isCalculated()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when calculated. |

**Example**

```lua
do
    local grid = lurek.pathfind.newNavGrid(16, 16)
    local ff = lurek.pathfind.newFlowField(grid)

    print("calculated_before = " .. tostring(ff:isCalculated()))
    ff:calculate(8, 8, 1)
    print("calculated_after = " .. tostring(ff:isCalculated()))
end
```

---

### `LFlowField:steer`

Returns a steering velocity for a world position using the flow field.

```lua
-- signature
LFlowField:steer(wx, wy, speed, tw, th)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `wx` | `number` | World X position. |
| `wy` | `number` | World Y position. |
| `speed` | `number` | Movement speed scalar. |
| `tw` | `number` | Tile width in world units. |
| `th` | `number` | Tile height in world units. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Steered X velocity. |
| `number` | b Steered Y velocity. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(10, 10)

    nav:fill(1)

    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(10, 10)

    local vx, vy = ff:steer(50, 50, 100, 32, 32)
    print("velocity = " .. vx .. "," .. vy)
end
```

---

### `LFlowField:type`

Returns the Lua-visible type name for this flow field handle.

```lua
-- signature
LFlowField:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LFlowField`. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(5, 5)
    local ff = lurek.pathfind.newFlowField(nav)

    print("type = " .. ff:type())
end
```

---

### `LFlowField:typeOf`

Returns whether this flow field handle matches a supported type name.

```lua
-- signature
LFlowField:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | String value for `name`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(5, 5)
    local ff = lurek.pathfind.newFlowField(nav)

    print("is_flow_field = " .. tostring(ff:typeOf("LFlowField")))
    print("is_object = " .. tostring(ff:typeOf("LObject")))
end
```

---

## LHexGrid

### `LHexGrid:distance`

Returns hex distance between two one-based hex cells.

```lua
-- signature
LHexGrid:distance(c1, r1, c2, r2)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `c1` | `number` | One-based column of the first cell. |
| `r1` | `number` | One-based row of the first cell. |
| `c2` | `number` | One-based column of the second cell. |
| `r2` | `number` | One-based row of the second cell. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Hex distance. |

**Example**

```lua
do
    local hex = lurek.pathfind.newHexGrid(10, 10)

    print("dist_1_1_to_5_5 = " .. hex:distance(1, 1, 5, 5))
    print("dist_1_1_to_1_1 = " .. hex:distance(1, 1, 1, 1))
end
```

---

### `LHexGrid:fieldOfView`

Returns visible hex cells within range from an origin.

```lua
-- signature
LHexGrid:fieldOfView(col, row, max_range)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `number` | One-based origin column. |
| `row` | `number` | One-based origin row. |
| `max_range` | `number` | Maximum visibility range in cells. |

**Returns**

| Type | Description |
|------|-------------|
| `LHexGridFieldOfViewResult` | Array of `{col, row}` hex cell tables. |

**Example**

```lua
do
    local hex = lurek.pathfind.newHexGrid(15, 15)

    hex:setBlocked(8, 8, true)

    local visible = hex:fieldOfView(7, 7, 3)
    print("visible = " .. #visible)
    if #visible > 0 then
        print("first = " .. visible[1].col .. "," .. visible[1].row)
    end
end
```

---

### `LHexGrid:findPath`

Finds a path between one-based hex cells.

```lua
-- signature
LHexGrid:findPath(fc, fr, tc, tr)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `fc` | `number` | One-based start column. |
| `fr` | `number` | One-based start row. |
| `tc` | `number` | One-based goal column. |
| `tr` | `number` | One-based goal row. |

**Returns**

| Type | Description |
|------|-------------|
| `LHexGridFindPathResult` | Array of `{col, row}` hex cell tables, or nil when no path exists. |

**Example**

```lua
do
    local hex = lurek.pathfind.newHexGrid(10, 10)

    hex:setBlocked(5, 3, true)
    hex:setBlocked(5, 4, true)
    hex:setBlocked(5, 5, true)

    local path = hex:findPath(1, 5, 10, 5)
    if path then
        print("steps = " .. #path)
        print("first = " .. path[1].col .. "," .. path[1].row)
        print("last = " .. path[#path].col .. "," .. path[#path].row)
    else
        print("steps = 0")
    end
end
```

---

### `LHexGrid:isBlocked`

Returns whether a one-based hex cell is blocked.

```lua
-- signature
LHexGrid:isBlocked(col, row)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `number` | One-based hex column. |
| `row` | `number` | One-based hex row. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when blocked. |

**Example**

```lua
do
    local hex = lurek.pathfind.newHexGrid(12, 10, "flat")

    hex:setBlocked(4, 4, true)

    print("blocked_4_4 = " .. tostring(hex:isBlocked(4, 4)))
    print("blocked_4_5 = " .. tostring(hex:isBlocked(4, 5)))
end
```

---

### `LHexGrid:lineOfSight`

Returns whether two one-based hex cells have line of sight.

```lua
-- signature
LHexGrid:lineOfSight(fc, fr, tc, tr)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `fc` | `number` | One-based column of the first cell. |
| `fr` | `number` | One-based row of the first cell. |
| `tc` | `number` | One-based column of the second cell. |
| `tr` | `number` | One-based row of the second cell. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when line of sight is clear. |

**Example**

```lua
do
    local hex = lurek.pathfind.newHexGrid(10, 10)

    local clear = hex:lineOfSight(1, 1, 10, 10)
    hex:setBlocked(5, 5, true)
    local blocked = hex:lineOfSight(1, 1, 10, 10)

    print("clear = " .. tostring(clear))
    print("blocked = " .. tostring(blocked))
end
```

---

### `LHexGrid:rangeOfMovement`

Returns reachable hex cells within a movement budget.

```lua
-- signature
LHexGrid:rangeOfMovement(col, row, budget)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `number` | One-based origin column. |
| `row` | `number` | One-based origin row. |
| `budget` | `number` | Maximum movement cost budget. |

**Returns**

| Type | Description |
|------|-------------|
| `LHexGridRangeOfMovementResult` | Array of `{col, row}` hex cell tables. |

**Example**

```lua
do
    local hex = lurek.pathfind.newHexGrid(12, 12)

    hex:setCost(6, 6, 3)

    local reachable = hex:rangeOfMovement(6, 6, 4)
    print("reachable = " .. #reachable)
    if #reachable > 0 then
        print("first = " .. reachable[1].col .. "," .. reachable[1].row)
    end
end
```

---

### `LHexGrid:setBlocked`

Sets blocked state for a one-based hex cell.

```lua
-- signature
LHexGrid:setBlocked(col, row, blocked)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `number` | One-based hex column. |
| `row` | `number` | One-based hex row. |
| `blocked` | `boolean` | True to block the cell. |

**Example**

```lua
do
    local hex = lurek.pathfind.newHexGrid(12, 10, "flat")

    hex:setBlocked(5, 5, true)
    hex:setBlocked(6, 5, true)

    print("blocked_5_5 = " .. tostring(hex:isBlocked(5, 5)))
    print("blocked_6_5 = " .. tostring(hex:isBlocked(6, 5)))
end
```

---

### `LHexGrid:setCost`

Sets movement cost for a one-based hex cell.

```lua
-- signature
LHexGrid:setCost(col, row, cost)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `number` | One-based hex column. |
| `row` | `number` | One-based hex row. |
| `cost` | `number` | Movement cost value. |

**Example**

```lua
do
    local hex = lurek.pathfind.newHexGrid(8, 8)

    hex:setCost(4, 4, 4)
    hex:setCost(5, 4, 4)

    local reachable = hex:rangeOfMovement(4, 4, 4)
    print("reachable = " .. #reachable)
    if #reachable > 0 then
        print("first = " .. reachable[1].col .. "," .. reachable[1].row)
    end
end
```

---

### `LHexGrid:type`

Returns the Lua-visible type name for this hex grid handle.

```lua
-- signature
LHexGrid:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LHexGrid`. |

**Example**

```lua
do
    local hex = lurek.pathfind.newHexGrid(5, 5, "pointy")

    print("type = " .. hex:type())
end
```

---

### `LHexGrid:typeOf`

Returns whether this hex grid handle matches a supported type name.

```lua
-- signature
LHexGrid:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | String value for `name`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local hex = lurek.pathfind.newHexGrid(5, 5, "pointy")

    print("is_hex_grid = " .. tostring(hex:typeOf("LHexGrid")))
    print("is_object = " .. tostring(hex:typeOf("LObject")))
end
```

---

## LJpsGrid

### `LJpsGrid:findPath`

Finds a JPS path between one-based grid cells.

```lua
-- signature
LJpsGrid:findPath(fx, fy, tx, ty)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `fx` | `number` | One-based start column. |
| `fy` | `number` | One-based start row. |
| `tx` | `number` | One-based goal column. |
| `ty` | `number` | One-based goal row. |

**Returns**

| Type | Description |
|------|-------------|
| `LJpsGridFindPathResult` | Array of `{x, y}` point tables, or nil when no path exists. |

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
        print("points = " .. #path)
        print("first = " .. path[1].x .. "," .. path[1].y)
        print("last = " .. path[#path].x .. "," .. path[#path].y)
    else
        print("points = 0")
    end
end
```

---

### `LJpsGrid:isBlocked`

Returns whether a one-based JPS grid cell is blocked.

```lua
-- signature
LJpsGrid:isBlocked(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | One-based column. |
| `y` | `number` | One-based row. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when blocked. |

**Example**

```lua
do
    local jps = lurek.pathfind.newJpsGrid(30, 30)

    jps:setBlocked(9, 9, true)

    print("blocked_9_9 = " .. tostring(jps:isBlocked(9, 9)))
    print("blocked_9_10 = " .. tostring(jps:isBlocked(9, 10)))
end
```

---

### `LJpsGrid:setBlocked`

Sets blocked state for a one-based JPS grid cell.

```lua
-- signature
LJpsGrid:setBlocked(x, y, blocked)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | One-based column. |
| `y` | `number` | One-based row. |
| `blocked` | `boolean` | True to block the cell. |

**Example**

```lua
do
    local jps = lurek.pathfind.newJpsGrid(30, 30)

    jps:setBlocked(15, 10, true)
    jps:setBlocked(15, 11, true)
    jps:setBlocked(15, 12, true)

    print("blocked_15_10 = " .. tostring(jps:isBlocked(15, 10)))
    print("blocked_15_12 = " .. tostring(jps:isBlocked(15, 12)))
end
```

---

### `LJpsGrid:type`

Returns the Lua-visible type name for this JPS grid handle.

```lua
-- signature
LJpsGrid:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LJpsGrid`. |

**Example**

```lua
do
    local jps = lurek.pathfind.newJpsGrid(5, 5)

    print("type = " .. jps:type())
end
```

---

### `LJpsGrid:typeOf`

Returns whether this JPS grid handle matches a supported type name.

```lua
-- signature
LJpsGrid:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | String value for `name`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local jps = lurek.pathfind.newJpsGrid(5, 5)

    print("is_jps_grid = " .. tostring(jps:typeOf("LJpsGrid")))
    print("is_object = " .. tostring(jps:typeOf("LObject")))
end
```

---

## LNavGrid

### `LNavGrid:clearDirty`

Clears all dirty region markers from the grid.

```lua
-- signature
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

    print("chunk = " .. nav:getChunkSize())
end
```

---

### `LNavGrid:fill`

Fills the entire grid with a uniform movement cost.

```lua
-- signature
LNavGrid:fill(cost)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cost` | `number` | Movement cost (0–255). |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(3)

    print("cost_1_1 = " .. nav:getCost(1, 1))
    print("cost_20_20 = " .. nav:getCost(20, 20))
end
```

---

### `LNavGrid:fillRect`

Fills a one-based rectangular area with a movement cost.

```lua
-- signature
LNavGrid:fillRect(x, y, w, h, cost)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | One-based column of the top-left corner. |
| `y` | `number` | One-based row of the top-left corner. |
| `w` | `number` | Rectangle width in cells. |
| `h` | `number` | Rectangle height in cells. |
| `cost` | `number` | Movement cost (0–255). |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fillRect(5, 5, 5, 5, 0)

    print("blocked_5_5 = " .. tostring(nav:isBlocked(5, 5)))
    print("blocked_10_10 = " .. tostring(nav:isBlocked(10, 10)))
    print("blocked_11_11 = " .. tostring(nav:isBlocked(11, 11)))
end
```

---

### `LNavGrid:findHpaPath`

Finds a hierarchical path using the cached abstract graph, rebuilding it on first use.

```lua
-- signature
LNavGrid:findHpaPath(sx, sy, gx, gy, unit_size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sx` | `number` | One-based start column. |
| `sy` | `number` | One-based start row. |
| `gx` | `number` | One-based goal column. |
| `gy` | `number` | One-based goal row. |
| `unit_size?` | `number` | Optional unit footprint in cells, default 1. |

**Returns**

| Type | Description |
|------|-------------|
| `table` | Array of `{x, y}` waypoint tables, or nil when no path exists. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(16, 16)
    nav:setChunkSize(4)
    nav:rebuildAbstract()
    local path = nav:findHpaPath(1, 1, 16, 16, 1)
    print("hpa path exists = " .. tostring(path ~= nil))
    print("hpa path len = " .. tostring(path and #path or 0))
end
```

---

### `LNavGrid:getChunkSize`

Returns the hierarchical chunk size in cells.

```lua
-- signature
LNavGrid:getChunkSize()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Chunk size. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(100, 100)

    nav:setChunkSize(12)

    print("chunk = " .. nav:getChunkSize())
end
```

---

### `LNavGrid:getCost`

Returns movement cost at a one-based grid cell.

```lua
-- signature
LNavGrid:getCost(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | One-based column. |
| `y` | `number` | One-based row. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Movement cost. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(30, 30)

    nav:setCost(7, 8, 4)

    print("cost_7_8 = " .. nav:getCost(7, 8))
    print("cost_1_1 = " .. nav:getCost(1, 1))
end
```

---

### `LNavGrid:getDiagonalMode`

Returns the current diagonal movement mode name.

```lua
-- signature
LNavGrid:getDiagonalMode()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Mode name. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(10, 10)

    nav:setDiagonalMode("nocornercut")

    print("mode = " .. nav:getDiagonalMode())
end
```

---

### `LNavGrid:getDimensions`

Returns grid width and height as two integers.

```lua
-- signature
LNavGrid:getDimensions()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Grid width. |
| `number` | b Grid height. |

**Example**

```lua
do
    local ng = lurek.pathfind.newNavGrid(20, 15)
    local w, h = ng:getDimensions()

    print("dims = " .. w .. "x" .. h)
    print("width = " .. ng:getWidth())
end
```

---

### `LNavGrid:getHeight`

Returns grid height from this object.

```lua
-- signature
LNavGrid:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Grid height. |

**Example**

```lua
do
    local ng = lurek.pathfind.newNavGrid(20, 15)
    local w, h = ng:getDimensions()

    print("dims = " .. w .. "x" .. h)
    print("height = " .. h)
end
```

---

### `LNavGrid:getWidth`

Returns grid width from this object.

```lua
-- signature
LNavGrid:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Grid width. |

**Example**

```lua
do
    local ng = lurek.pathfind.newNavGrid(20, 15)
    local w, h = ng:getDimensions()

    print("dims = " .. w .. "x" .. h)
    print("width = " .. w)
end
```

---

### `LNavGrid:isBlocked`

Returns whether a one-based grid cell is blocked.

```lua
-- signature
LNavGrid:isBlocked(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | One-based column. |
| `y` | `number` | One-based row. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when blocked. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(30, 30)

    nav:setBlocked(12, 12, true)

    print("blocked_12_12 = " .. tostring(nav:isBlocked(12, 12)))
    print("blocked_12_13 = " .. tostring(nav:isBlocked(12, 13)))
end
```

---

### `LNavGrid:isWalkable`

Returns whether a one-based grid cell is walkable for a unit size.

```lua
-- signature
LNavGrid:isWalkable(x, y, unit_size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | One-based column. |
| `y` | `number` | One-based row. |
| `unit_size?` | `number` | Unit footprint in cells (default 1). |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when walkable. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)
    nav:setBlocked(6, 6, true)

    print("walkable_1x1 = " .. tostring(nav:isWalkable(5, 5)))
    print("walkable_blocked = " .. tostring(nav:isWalkable(6, 6)))
    print("walkable_2x2 = " .. tostring(nav:isWalkable(5, 5, 2)))
end
```

---

### `LNavGrid:loadFromString`

Loads grid data from a serialized binary string.

```lua
-- signature
LNavGrid:loadFromString(data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `data` | `string` | Serialized grid bytes. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(10, 10)

    nav:setBlocked(5, 5, true)
    nav:setCost(3, 3, 9)

    local data = nav:saveToString()
    local nav2 = lurek.pathfind.newNavGrid(10, 10)
    nav2:loadFromString(data)

    print("blocked_5_5 = " .. tostring(nav2:isBlocked(5, 5)))
    print("cost_3_3 = " .. nav2:getCost(3, 3))
end
```

---

### `LNavGrid:rebuildAbstract`

Rebuilds the cached abstract graph for this grid.

```lua
-- signature
LNavGrid:rebuildAbstract()
```

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(64, 64)

    nav:setChunkSize(8)
    nav:rebuildAbstract()

    print("chunk = " .. nav:getChunkSize())
    print("blocked_1_1 = " .. tostring(nav:isBlocked(1, 1)))
end
```

---

### `LNavGrid:saveToString`

Saves grid data to a serialized binary string.

```lua
-- signature
LNavGrid:saveToString()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Serialized grid bytes. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(10, 10)

    nav:setBlocked(5, 5, true)
    nav:setCost(3, 3, 9)

    local data = nav:saveToString()

    print("bytes = " .. #data)
    print("blocked_5_5 = " .. tostring(nav:isBlocked(5, 5)))
end
```

---

### `LNavGrid:setBlocked`

Sets blocked state at a one-based grid cell.

```lua
-- signature
LNavGrid:setBlocked(x, y, blocked)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | One-based column. |
| `y` | `number` | One-based row. |
| `blocked` | `boolean` | True to block the cell. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(30, 30)

    nav:setBlocked(10, 10, true)

    print("blocked_10_10 = " .. tostring(nav:isBlocked(10, 10)))
    print("cost_10_10 = " .. nav:getCost(10, 10))
end
```

---

### `LNavGrid:setChunkSize`

Sets hierarchical chunk size for abstract graph partitioning.

```lua
-- signature
LNavGrid:setChunkSize(size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `size` | `number` | Chunk side length in cells. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(100, 100)

    nav:setChunkSize(16)
    nav:rebuildAbstract()

    print("chunk = " .. nav:getChunkSize())
end
```

---

### `LNavGrid:setCost`

Sets movement cost at a one-based grid cell.

```lua
-- signature
LNavGrid:setCost(x, y, cost)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | One-based column. |
| `y` | `number` | One-based row. |
| `cost` | `number` | Movement cost (0–255). |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(30, 30)

    nav:setCost(5, 5, 200)

    print("cost_5_5 = " .. nav:getCost(5, 5))
    print("blocked_5_5 = " .. tostring(nav:isBlocked(5, 5)))
end
```

---

### `LNavGrid:setDiagonalMode`

Sets diagonal movement mode for this object.

```lua
-- signature
LNavGrid:setDiagonalMode(mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | `string` | Mode name: `none`, `always`, or `nocornercut`. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(10, 10)

    nav:setDiagonalMode("always")

    print("mode = " .. nav:getDiagonalMode())
end
```

---

### `LNavGrid:setDirty`

Marks a one-based rectangular region dirty for incremental rebuild.

```lua
-- signature
LNavGrid:setDirty(x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | One-based column of the top-left corner. |
| `y` | `number` | One-based row of the top-left corner. |
| `w` | `number` | Region width in cells. |
| `h` | `number` | Region height in cells. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(50, 50)

    nav:setChunkSize(10)
    nav:rebuildAbstract()
    nav:setBlocked(25, 25, true)
    nav:setDirty(20, 20, 10, 10)
    nav:rebuildAbstract()

    print("blocked_25_25 = " .. tostring(nav:isBlocked(25, 25)))
    print("chunk = " .. nav:getChunkSize())
end
```

---

### `LNavGrid:type`

Returns the Lua-visible type name for this navigation grid handle.

```lua
-- signature
LNavGrid:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LNavGrid`. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(5, 5)

    print("type = " .. nav:type())
end
```

---

### `LNavGrid:typeOf`

Returns whether this navigation grid handle matches a supported type name.

```lua
-- signature
LNavGrid:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | String value for `name`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(5, 5)

    print("is_nav_grid = " .. tostring(nav:typeOf("LNavGrid")))
    print("is_object = " .. tostring(nav:typeOf("LObject")))
end
```

---

## LNavMesh

### `LNavMesh:addPolygon`

Adds a polygon from vertex tables and returns a one-based id.

```lua
-- signature
LNavMesh:addPolygon(vertices)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `vertices` | `table` | Array of `{x, y}` vertex tables (minimum 3). |

**Returns**

| Type | Description |
|------|-------------|
| `number` | One-based polygon id. |

**Example**

```lua
do
    local mesh = lurek.pathfind.newNavMesh()
    local id = mesh:addPolygon({
        { x = 0, y = 0 },
        { x = 60, y = 0 },
        { x = 30, y = 45 },
    })

    print("polygon_id = " .. id)
    print("polygon_count = " .. mesh:getPolygonCount())
end
```

---

### `LNavMesh:connectPolygons`

Connects two polygons by one-based id.

```lua
-- signature
LNavMesh:connectPolygons(a, b, bidirectional)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `a` | `number` | One-based id of the first polygon. |
| `b` | `number` | One-based id of the second polygon. |
| `bidirectional?` | `boolean` | True for two-way link (default true). |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the connection was added. |

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

    print("connected_ab = " .. tostring(ab))
    print("connected_bc = " .. tostring(bc))
    print("polygon_count = " .. mesh:getPolygonCount())
end
```

---

### `LNavMesh:findPath`

Finds a path through the navmesh between world points.

```lua
-- signature
LNavMesh:findPath(sx, sy, gx, gy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sx` | `number` | Start X in world coordinates. |
| `sy` | `number` | Start Y in world coordinates. |
| `gx` | `number` | Goal X in world coordinates. |
| `gy` | `number` | Goal Y in world coordinates. |

**Returns**

| Type | Description |
|------|-------------|
| `LNavMeshFindPathResult` | Array of `{x, y}` point tables, or nil when no path exists. |

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
        print("waypoints = " .. #path)
        print("first = " .. path[1].x .. "," .. path[1].y)
        print("last = " .. path[#path].x .. "," .. path[#path].y)
    else
        print("waypoints = 0")
    end
end
```

---

### `LNavMesh:getPolygonCount`

Returns the total navmesh polygon count.

```lua
-- signature
LNavMesh:getPolygonCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Polygon count. |

**Example**

```lua
do
    local mesh = lurek.pathfind.newNavMesh()
    local id = mesh:addPolygon({
        { x = 0, y = 0 },
        { x = 64, y = 0 },
        { x = 32, y = 48 },
    })

    print("polygon_count = " .. mesh:getPolygonCount())
    print("first_id = " .. id)
end
```

---

### `LNavMesh:type`

Returns the Lua-visible type name for this navmesh handle.

```lua
-- signature
LNavMesh:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LNavMesh`. |

**Example**

```lua
do
    local mesh = lurek.pathfind.newNavMesh()

    print("type = " .. mesh:type())
end
```

---

### `LNavMesh:typeOf`

Returns whether this navmesh handle matches a supported type name.

```lua
-- signature
LNavMesh:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | String value for `name`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local mesh = lurek.pathfind.newNavMesh()

    print("is_nav_mesh = " .. tostring(mesh:typeOf("LNavMesh")))
    print("is_object = " .. tostring(mesh:typeOf("LObject")))
end
```

---

## LPathGrid

### `LPathGrid:findPath`

Finds a path between one-based path grid cells.

```lua
-- signature
LPathGrid:findPath(sx, sy, gx, gy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sx` | `number` | One-based start column. |
| `sy` | `number` | One-based start row. |
| `gx` | `number` | One-based goal column. |
| `gy` | `number` | One-based goal row. |

**Returns**

| Type | Description |
|------|-------------|
| `LPathGridFindPathResult` | Array of `{x, y}` point tables, or nil when no path exists. |

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
        print("steps = " .. #path)
        print("first = " .. path[1].x .. "," .. path[1].y)
        print("last = " .. path[#path].x .. "," .. path[#path].y)
    else
        print("steps = 0")
    end
end
```

---

### `LPathGrid:findPathSmoothed`

Finds a smoothed path between one-based path grid cells.

```lua
-- signature
LPathGrid:findPathSmoothed(sx, sy, gx, gy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sx` | `number` | One-based start column. |
| `sy` | `number` | One-based start row. |
| `gx` | `number` | One-based goal column. |
| `gy` | `number` | One-based goal row. |

**Returns**

| Type | Description |
|------|-------------|
| `LPathGridFindPathSmoothedResult` | Array of `{x, y}` point tables, or nil when no path exists. |

**Example**

```lua
do
    local grid = lurek.pathfind.newPathGrid(20, 20, 16)

    grid:setWalkable(10, 5, false)
    grid:setWalkable(10, 6, false)
    grid:setWalkable(10, 7, false)

    local path = grid:findPathSmoothed(1, 5, 20, 5)
    if path then
        print("points = " .. #path)
        print("first = " .. path[1].x .. "," .. path[1].y)
        print("last = " .. path[#path].x .. "," .. path[#path].y)
    else
        print("points = 0")
    end
end
```

---

### `LPathGrid:getCellSize`

Returns path grid cell size from this object.

```lua
-- signature
LPathGrid:getCellSize()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Cell size. |

**Example**

```lua
do
    local pg = lurek.pathfind.newPathGrid(10, 10, 32)

    print("cell_size = " .. pg:getCellSize())
    print("dims = " .. pg:getWidth() .. "x" .. pg:getHeight())
end
```

---

### `LPathGrid:getCost`

Returns movement cost at a one-based cell.

```lua
-- signature
LPathGrid:getCost(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | One-based column. |
| `y` | `number` | One-based row. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Movement cost. |

**Example**

```lua
do
    local grid = lurek.pathfind.newPathGrid(10, 10, 16)

    grid:setCost(6, 2, 2.5)

    print("cost_6_2 = " .. grid:getCost(6, 2))
    print("cost_1_1 = " .. grid:getCost(1, 1))
end
```

---

### `LPathGrid:getHeight`

Returns grid height from this object.

```lua
-- signature
LPathGrid:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Grid height. |

**Example**

```lua
do
    local pg = lurek.pathfind.newPathGrid(10, 10, 32)

    print("height = " .. pg:getHeight())
    print("cell_size = " .. pg:getCellSize())
end
```

---

### `LPathGrid:getWidth`

Returns grid width from this object.

```lua
-- signature
LPathGrid:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Grid width. |

**Example**

```lua
do
    local pg = lurek.pathfind.newPathGrid(10, 10, 32)

    print("width = " .. pg:getWidth())
    print("cell_size = " .. pg:getCellSize())
end
```

---

### `LPathGrid:isWalkable`

Returns walkability at a one-based cell.

```lua
-- signature
LPathGrid:isWalkable(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | One-based column. |
| `y` | `number` | One-based row. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when walkable. |

**Example**

```lua
do
    local grid = lurek.pathfind.newPathGrid(20, 15, 32)

    grid:setWalkable(4, 4, false)

    print("walkable_4_4 = " .. tostring(grid:isWalkable(4, 4)))
    print("walkable_4_5 = " .. tostring(grid:isWalkable(4, 5)))
end
```

---

### `LPathGrid:setCost`

Sets movement cost at a one-based cell.

```lua
-- signature
LPathGrid:setCost(x, y, cost)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | One-based column. |
| `y` | `number` | One-based row. |
| `cost` | `number` | Movement cost value. |

**Example**

```lua
do
    local grid = lurek.pathfind.newPathGrid(10, 10, 16)

    grid:setCost(3, 3, 5)

    print("cost_3_3 = " .. grid:getCost(3, 3))
    print("cost_3_4 = " .. grid:getCost(3, 4))
end
```

---

### `LPathGrid:setWalkable`

Sets walkability at a one-based cell.

```lua
-- signature
LPathGrid:setWalkable(x, y, w)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | One-based column. |
| `y` | `number` | One-based row. |
| `w` | `boolean` | True to mark the cell walkable. |

**Example**

```lua
do
    local grid = lurek.pathfind.newPathGrid(20, 15, 32)

    grid:setWalkable(5, 5, false)

    print("walkable_5_5 = " .. tostring(grid:isWalkable(5, 5)))
    print("walkable_5_6 = " .. tostring(grid:isWalkable(5, 6)))
end
```

---

### `LPathGrid:type`

Returns the Lua-visible type name for this path grid handle.

```lua
-- signature
LPathGrid:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LPathGrid`. |

**Example**

```lua
do
    local grid = lurek.pathfind.newPathGrid(5, 5, 32)

    print("type = " .. grid:type())
end
```

---

### `LPathGrid:typeOf`

Returns whether this path grid handle matches a supported type name.

```lua
-- signature
LPathGrid:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | String value for `name`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local grid = lurek.pathfind.newPathGrid(5, 5, 32)

    print("is_path_grid = " .. tostring(grid:typeOf("LPathGrid")))
    print("is_object = " .. tostring(grid:typeOf("LObject")))
end
```

---

## LUnitPathfinder

### `LUnitPathfinder:clearCache`

Clears all cached paths on this object.

```lua
-- signature
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

    print("cache_before_clear = " .. pf:getCacheSize())
    pf:clearCache()
    print("cache_after_clear = " .. pf:getCacheSize())
end
```

---

### `LUnitPathfinder:findNearestWalkable`

Finds nearest walkable one-based grid cell within a radius.

```lua
-- signature
LUnitPathfinder:findNearestWalkable(x, y, max_radius, unit_size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | One-based column of the search origin. |
| `y` | `number` | One-based row of the search origin. |
| `max_radius` | `number` | Maximum search radius in cells. |
| `unit_size?` | `number` | Unit footprint in cells (default 1). |

**Returns**

| Type | Description |
|------|-------------|
| `number` | a One-based column of the nearest walkable cell, or nil. |
| `number` | b One-based row of the nearest walkable cell, or nil. |

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

    print("nearest = " .. nx .. "," .. ny)
end
```

---

### `LUnitPathfinder:findPartialPath`

Finds the best reachable path from a start to a goal within a maximum node budget. Useful for incremental pathfinding across frames.

```lua
-- signature
LUnitPathfinder:findPartialPath(x1, y1, x2, y2, max_nodes, unit_size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x1` | `number` | One-based column of the start cell. |
| `y1` | `number` | One-based row of the start cell. |
| `x2` | `number` | One-based column of the goal cell. |
| `y2` | `number` | One-based row of the goal cell. |
| `max_nodes` | `number` | Maximum number of nodes to expand before stopping. |
| `unit_size?` | `number` | Width/height of the unit in grid cells for clearance checks (default 1). |

**Returns**

| Type | Description |
|------|-------------|
| `LUnitPathfinderFindPartialPathResult` | a Array of `{x, y}` waypoint tables forming the found partial path. |
| `boolean` | b `true` if the returned path reaches the exact goal cell. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(100, 100)

    nav:fill(1)
    nav:fillRect(40, 1, 1, 100, 0)
    nav:fillRect(40, 50, 1, 1, 1)

    local pf = lurek.pathfind.newPathfinder(nav)
    local path, reached = pf:findPartialPath(1, 1, 100, 100, 50)

    print("points = " .. #path)
    print("reached = " .. tostring(reached))
    print("last = " .. path[#path].x .. "," .. path[#path].y)
end
```

---

### `LUnitPathfinder:findPath`

Finds a path between one-based grid cells.

```lua
-- signature
LUnitPathfinder:findPath(x1, y1, x2, y2, unit_size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x1` | `number` | One-based start column. |
| `y1` | `number` | One-based start row. |
| `x2` | `number` | One-based goal column. |
| `y2` | `number` | One-based goal row. |
| `unit_size?` | `number` | Unit footprint in cells (default 1). |

**Returns**

| Type | Description |
|------|-------------|
| `LUnitPathfinderFindPathResult` | Array of `{x, y}` waypoint tables, or nil when no path exists. |

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
        print("steps = " .. #path)
        print("first = " .. path[1].x .. "," .. path[1].y)
        print("last = " .. path[#path].x .. "," .. path[#path].y)
    else
        print("steps = 0")
    end
end
```

---

### `LUnitPathfinder:findPathBidirectional`

Finds a path using bidirectional A* and returns completion status.

```lua
-- signature
LUnitPathfinder:findPathBidirectional(x1, y1, x2, y2, unit_size, max_nodes)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x1` | `number` | One-based column of the start cell. |
| `y1` | `number` | One-based row of the start cell. |
| `x2` | `number` | One-based column of the goal cell. |
| `y2` | `number` | One-based row of the goal cell. |
| `unit_size?` | `number` | Width or height of the unit in grid cells for clearance checks (default 1). |
| `max_nodes?` | `number` | Optional node-expansion budget; 0 uses the full search. |

**Returns**

| Type | Description |
|------|-------------|
| `LUnitPathfinderFindPathBidirectionalResult` | a Array of waypoint tables, or nil when no path exists. |
| `boolean` | b True when the path is complete. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(40, 40)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    local path, complete = pf:findPathBidirectional(1, 1, 40, 40, 1, 500)
    if path then
        print("points = " .. #path)
        print("complete = " .. tostring(complete))
        print("last = " .. path[#path].x .. "," .. path[#path].y)
    else
        print("complete = " .. tostring(complete))
    end
end
```

---

### `LUnitPathfinder:findPathSmooth`

Finds a smoothed path between one-based grid cells.

```lua
-- signature
LUnitPathfinder:findPathSmooth(x1, y1, x2, y2, unit_size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x1` | `number` | One-based start column. |
| `y1` | `number` | One-based start row. |
| `x2` | `number` | One-based goal column. |
| `y2` | `number` | One-based goal row. |
| `unit_size?` | `number` | Unit footprint in cells (default 1). |

**Returns**

| Type | Description |
|------|-------------|
| `LUnitPathfinderFindPathSmoothResult` | Array of `{x, y}` waypoint tables, or nil when no path exists. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    local path = pf:findPathSmooth(1, 1, 20, 20)
    if path then
        print("points = " .. #path)
        print("first = " .. path[1].x .. "," .. path[1].y)
        print("last = " .. path[#path].x .. "," .. path[#path].y)
    else
        print("points = 0")
    end
end
```

---

### `LUnitPathfinder:getCacheSize`

Returns the current path cache entry count.

```lua
-- signature
LUnitPathfinder:getCacheSize()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Cache size. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    pf:setCacheEnabled(true)
    pf:findPath(1, 1, 20, 20)
    pf:findPath(5, 5, 15, 15)

    print("cache_size = " .. pf:getCacheSize())
end
```

---

### `LUnitPathfinder:getPathCost`

Returns the total movement cost along a waypoint path.

```lua
-- signature
LUnitPathfinder:getPathCost(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `table` | Array of `{x, y}` waypoint tables. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Path cost. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(10, 10)

    nav:fill(1)
    nav:setCost(5, 5, 4)

    local pf = lurek.pathfind.newPathfinder(nav)
    local path = pf:findPath(1, 1, 10, 10)
    if path then
        print("cost = " .. pf:getPathCost(path))
        print("length = " .. pf:getPathLength(path))
    else
        print("cost = 0")
    end
end
```

---

### `LUnitPathfinder:getPathLength`

Returns the total Euclidean length of a waypoint path.

```lua
-- signature
LUnitPathfinder:getPathLength(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `table` | Array of `{x, y}` waypoint tables. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Path length. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(10, 10)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    local path = pf:findPath(1, 1, 10, 10)
    if path then
        print("length = " .. pf:getPathLength(path))
        print("cost = " .. pf:getPathCost(path))
    else
        print("length = 0")
    end
end
```

---

### `LUnitPathfinder:heuristicDistance`

Returns heuristic distance between two one-based cells.

```lua
-- signature
LUnitPathfinder:heuristicDistance(x1, y1, x2, y2)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x1` | `number` | One-based column of the first cell. |
| `y1` | `number` | One-based row of the first cell. |
| `x2` | `number` | One-based column of the second cell. |
| `y2` | `number` | One-based row of the second cell. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Heuristic distance. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(20, 20)
    local pf = lurek.pathfind.newPathfinder(nav)

    print("dist_1_1_to_20_20 = " .. pf:heuristicDistance(1, 1, 20, 20))
    print("dist_5_5_to_5_5 = " .. pf:heuristicDistance(5, 5, 5, 5))
end
```

---

### `LUnitPathfinder:isCacheEnabled`

Returns whether path cache is enabled.

```lua
-- signature
LUnitPathfinder:isCacheEnabled()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when enabled. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    pf:setCacheEnabled(true)
    local enabled = pf:isCacheEnabled()
    pf:setCacheEnabled(false)

    print("enabled_before_disable = " .. tostring(enabled))
    print("enabled_after_disable = " .. tostring(pf:isCacheEnabled()))
end
```

---

### `LUnitPathfinder:isReachable`

Returns whether a target cell is reachable from a start cell.

```lua
-- signature
LUnitPathfinder:isReachable(x1, y1, x2, y2, unit_size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x1` | `number` | One-based start column. |
| `y1` | `number` | One-based start row. |
| `x2` | `number` | One-based target column. |
| `y2` | `number` | One-based target row. |
| `unit_size?` | `number` | Unit footprint in cells (default 1). |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when reachable. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)
    nav:fillRect(10, 1, 1, 20, 0)

    local pf = lurek.pathfind.newPathfinder(nav)

    print("reachable_left = " .. tostring(pf:isReachable(1, 1, 9, 9)))
    print("reachable_right = " .. tostring(pf:isReachable(1, 1, 20, 20)))
end
```

---

### `LUnitPathfinder:lineOfSight`

Returns whether two one-based cells have line of sight.

```lua
-- signature
LUnitPathfinder:lineOfSight(x1, y1, x2, y2, unit_size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x1` | `number` | One-based column of the first cell. |
| `y1` | `number` | One-based row of the first cell. |
| `x2` | `number` | One-based column of the second cell. |
| `y2` | `number` | One-based row of the second cell. |
| `unit_size?` | `number` | Unit footprint in cells (default 1). |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when line of sight is clear. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    local clear = pf:lineOfSight(1, 1, 20, 20)
    nav:setBlocked(10, 10, true)
    local blocked = pf:lineOfSight(1, 1, 20, 20)

    print("clear = " .. tostring(clear))
    print("blocked = " .. tostring(blocked))
end
```

---

### `LUnitPathfinder:setCacheEnabled`

Enables or disables the path cache on this object.

```lua
-- signature
LUnitPathfinder:setCacheEnabled(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | `boolean` | True to enable caching. |

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

    print("enabled = " .. tostring(pf:isCacheEnabled()))
    print("cache_size = " .. pf:getCacheSize())
    pf:clearCache()
    print("cache_after_clear = " .. pf:getCacheSize())
end
```

---

### `LUnitPathfinder:setCacheMaxSize`

Sets maximum path cache size for this object.

```lua
-- signature
LUnitPathfinder:setCacheMaxSize(n)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `n` | `number` | Maximum number of cached paths. |

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

    print("cache_size = " .. pf:getCacheSize())
end
```

---

### `LUnitPathfinder:type`

Returns the Lua-visible type name for this pathfinder handle.

```lua
-- signature
LUnitPathfinder:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LUnitPathfinder`. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(5, 5)
    local pf = lurek.pathfind.newPathfinder(nav)

    print("type = " .. pf:type())
end
```

---

### `LUnitPathfinder:typeOf`

Returns whether this pathfinder handle matches a supported type name.

```lua
-- signature
LUnitPathfinder:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | String value for `name`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local nav = lurek.pathfind.newNavGrid(5, 5)
    local pf = lurek.pathfind.newPathfinder(nav)

    print("is_pathfinder = " .. tostring(pf:typeOf("LUnitPathfinder")))
    print("is_object = " .. tostring(pf:typeOf("LObject")))
end
```

---
