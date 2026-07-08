# Pathfind

## Purpose

Navigates grids, hex layouts, isometric maps, navmeshes, and province graphs. - Employs A*, JPS, bidirectional search, HPA*, and async thread pools. - Uses Dijkstra flow fields, tactical influence maps, steering stacks, context steering, ORCA-style local avoidance, and debug visual overlays.

## Summary

- The `pathfind` module is the engine's navigation and movement-analysis surface for users who need more than one hard-coded shortest-path helper.
- It supports several spatial models at once, including weighted grids, hex and isometric spaces, province-style graphs, influence fields, and other routing abstractions, so different worlds can still share one navigation family.
- A* is only part of the surface. The module also covers bidirectional search, Jump Point Search, hierarchical routing, graph travel, flow fields, influence maps, steering, local avoidance, and reachability-style analysis under one subsystem.
- This breadth matters because movement questions differ dramatically across features. Some systems need one precise route, others need shared guidance, tactical pressure, move ranges, or background jobs for expensive searches.
- That makes the module useful not only for point-to-point travel but also for squad guidance, threat-aware movement, logistics overlays, and strategic map reasoning where spatial scoring matters.
- Async search support is especially important because pathfinding is often one of the first systems that must leave the main loop without losing an engine-owned, script-facing API.
- Shared abstractions for grids and graph-like inputs reduce adapter overhead and make it easier for a project to compare algorithms without rewriting all navigation data plumbing.
- Range and reachability helpers are as important as final path extraction. Many systems need to know where a unit could move, what lies inside a budget, or which cells are effectively controlled before they need an explicit route.
- Influence, steering, ORCA, and shared-field helpers broaden the module into tactical movement analysis. Movement is not only about reaching a goal; it is also about preferring safe zones, avoiding danger, and turning desired motion into local movement advice for several actors.
- Because several world models can feed the same pathfinding family, projects can evolve from simple grid routing to richer graph or field-based navigation without abandoning the same conceptual subsystem.
- That flexibility is one of the main reasons the module exists as a family rather than as one algorithm wrapper: different gameplay scales can still share one navigation vocabulary.
- Cost rules are part of that vocabulary too. Terrain penalties, danger zones, ownership boundaries, and temporary blockers can all be expressed as navigation data instead of being bolted on after a path is returned.
- This helps projects keep route quality and tactical intent aligned, because the same system can explain not only where an actor can go, but why one route is preferred over another.
- The module is also valuable when several agents share the same traversability model but need different routing policies over it.
- That makes `pathfind` a planning layer, not only a shortest-path helper.
- Debug and visualization helpers matter because navigation bugs usually come from topology, weights, or blocked-space assumptions rather than from the solver implementation alone.
- `tilemap`, `province`, and related modules define traversable space, but `pathfind` owns how that space is searched, scored, and turned into movement advice.
- Province-level BFS, weighted Dijkstra/A*, connected-component traversal, and reachability belong here even when `province` exposes convenience methods that adapt registry topology into pathfinding inputs.
- Read `pathfind` as the reusable navigation and local-movement analysis layer of the engine, not as an animation or physics integration system.

This module primarily collaborates with `flownet`, `image`, `render`, `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## API Reference

- This page is the generated API reference for this module.

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
    lurek.log.info("cancelled = " .. tostring(lurek.pathfind.cancelAsyncPath(request_id)))
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
    lurek.log.info("pending = " .. tostring(lurek.pathfind.getAsyncPendingCount()))
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
    lurek.log.info("pending_before = " .. tostring(before))
    lurek.log.info("pending_after = " .. tostring(after))
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

    lurek.log.info("thread count = " .. tc)
    lurek.log.info("pending async jobs = " .. pending)
    lurek.log.info("sample grid blocked = " .. tostring(nav:isBlocked(4, 4)))
end
```

---

### `lurek.pathfind.graphConnected`

Returns true when a target node is reachable from a start node in an integer-id graph.

```lua
lurek.pathfind.graphConnected(edges, from, to, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `edges` | table | Array of graph edge tables. |
| `from` | number | Start node id. |
| `to` | number | Target node id. |
| `opts?` | table | Options with `directed`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when reachable. |

**Example**

```lua
do

    local edges = {
        { from = 1, to = 2 },
        { from = 2, to = 3 },
    }
    local forward = lurek.pathfind.graphConnected(edges, 1, 3, { directed = true })
    local backward_directed = lurek.pathfind.graphConnected(edges, 3, 1, { directed = true })
    local backward_undirected = lurek.pathfind.graphConnected(edges, 3, 1)
    lurek.log.info("graph connected forward=" .. tostring(forward) .. " directed_back=" .. tostring(backward_directed) .. " undirected_back=" .. tostring(backward_undirected))
end
```

---

### `lurek.pathfind.graphConnectedComponents`

Returns connected components for an integer-id graph. Pass `nodes` to include isolated node ids.

```lua
lurek.pathfind.graphConnectedComponents(edges, nodes, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `edges` | table | Array of graph edge tables. |
| `nodes?` | table | Optional array of node ids; omitted nodes are inferred from edge endpoints. |
| `opts?` | table | Options with `directed`; directed graphs follow outgoing edges. |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of node-id arrays, sorted by first node id. |

**Example**

```lua
do

    local edges = {
        { from = 7, to = 8 },
        { from = 8, to = 9 },
        { from = 20, to = 21 },
    }
    local components = lurek.pathfind.graphConnectedComponents(edges, { 7, 8, 9, 10, 20, 21 })
    local isolated = components[2] and components[2][1] or nil
    local largest = components[1] and #components[1] or 0
    lurek.log.info("graph components=" .. tostring(#components) .. " largest=" .. tostring(largest) .. " isolated=" .. tostring(isolated))
end
```

---

### `lurek.pathfind.graphRoute`

Finds a route through an integer-id graph. Edges may be `{from,to}`, `{a,b}`, `{province_a,province_b}`, or `{from_id,to_id}` arrays. Options: `directed`, `algorithm` ("bfs"|"dijkstra"), and optional `cost(from, to)`.

```lua
lurek.pathfind.graphRoute(edges, from, to, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `edges` | table | Array of graph edge tables. |
| `from` | number | Start node id. |
| `to` | number | Target node id. |
| `opts?` | table | Options with `directed`, `algorithm`, and `cost` callback; a function may be passed directly as the cost callback. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Node id route from start to target, or nil when unreachable. |

**Example**

```lua
do

    local edges = {
        { from = 1, to = 2 },
        { from = 2, to = 3 },
        { from = 1, to = 4 },
        { from = 4, to = 3 },
    }
    local route = lurek.pathfind.graphRoute(edges, 1, 3, {
        algorithm = "dijkstra",
        cost = function(from, to)
            if (from == 1 and to == 2) or (from == 2 and to == 3) then
                return 12
            end
            return 1
        end,
    })
    lurek.log.info("graph route hops=" .. tostring(route and #route or 0) .. " via=" .. tostring(route and route[2]))
end
```

---

### `lurek.pathfind.graphRoutes`

Finds routes for a batch of graph `{from, to}` requests using the same edge table and options as `graphRoute`.

```lua
lurek.pathfind.graphRoutes(edges, requests, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `edges` | table | Array of graph edge tables. |
| `requests` | table | Array of `{from=integer,to=integer}` or `{from,to}` route requests. |
| `opts?` | table | Options with `directed`, `algorithm`, and `cost` callback; a function may be passed directly as the cost callback. |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of route arrays; unreachable entries are nil. |

**Example**

```lua
do

    local edges = {
        { 1, 2 },
        { 2, 3 },
        { 4, 5 },
    }
    local routes = lurek.pathfind.graphRoutes(edges, {
        { from = 1, to = 3 },
        { from = 1, to = 5 },
        { from = 4, to = 5 },
    })
    local first_len = routes[1] and #routes[1] or 0
    local third_len = routes[3] and #routes[3] or 0
    lurek.log.info("graph route batch first=" .. tostring(first_len) .. " third=" .. tostring(third_len) .. " second_nil=" .. tostring(routes[2] == nil))
end
```

---

### `lurek.pathfind.newContextSteering`

Creates a context steering model with the requested directional slot count.

```lua
lurek.pathfind.newContextSteering(slots)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `slots` | number | Directional slot count; zero selects the engine default of 16. |

**Returns**

| Type | Description |
|------|-------------|
| [LContextSteering](#lcontextsteering) | New context steering handle. |

**Example**

```lua
do

  local cs = lurek.pathfind.newContextSteering(8)
  cs:addSeekTarget(0, 0, 1.0)
  local slot_count = cs:slotCount()
  cs:addSeekTarget(256, 128, 1.0)
  local dx, dy = cs:evaluate(0, 0, 1, 0)
  lurek.log.info("lurek.pathfind.newContextSteering: ok=" .. tostring(cs ~= nil))
  lurek.log.info("lurek.pathfind.newContextSteering: dir=" .. tostring(dx) .. "," .. tostring(dy))
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

    lurek.log.info("calculated = " .. tostring(ff:isCalculated()))
    lurek.log.info("targets = " .. #ff:getTargets())
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

    lurek.log.info("goal map type = " .. gm:type())
    lurek.log.info("goal map ready = " .. tostring(ready))
    lurek.log.info("center distance = " .. center_distance)
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

    lurek.log.info("blocked_5_5 = " .. tostring(hex:isBlocked(5, 5)))
    lurek.log.info("blocked_1_1 = " .. tostring(hex:isBlocked(1, 1)))
end
```

---

### `lurek.pathfind.newHexGridFromField`

Creates a hex navigation grid from a hex tilefield level and movement category.

```lua
lurek.pathfind.newHexGridFromField(field_ud, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `field_ud` | [LTileField](tilefield.md#ltilefield) | Hex tilefield to derive navigation data from. |
| `opts?` | table | Options with `level`, `category`, `costCategory`, and `layout` (`"flat"` or `"pointy"`). |

**Returns**

| Type | Description |
|------|-------------|
| [LHexGrid](#lhexgrid) | New hex grid handle. |

**Example**

```lua
do

    local field = lurek.tilefield.new({ width = 6, height = 6, topology = "hex" })
    field:setBlock(3, 3, 1, "move", true)
    field:setCost(4, 3, 1, "move", 3)
    local grid = lurek.pathfind.newHexGridFromField(field, { level = 1, channel = "move", layout = "flat" })
    local route = grid:findPath(1, 3, 6, 3) or {}
    local blocked = grid:isBlocked(3, 3)
    lurek.log.info("field hex route nodes=" .. tostring(#route) .. " blocked=" .. tostring(blocked))
end
```

---

### `lurek.pathfind.newInfluenceMap`

Creates a grid influence map with the supplied cell dimensions and world cell size.

```lua
lurek.pathfind.newInfluenceMap(w, h, cs)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | number | Map width in cells. |
| `h` | number | Map height in cells. |
| `cs` | number | World size of one cell. |

**Returns**

| Type | Description |
|------|-------------|
| [LInfluenceMap](#linfluencemap) | New influence map handle. |

**Example**

```lua
do

  local imap = lurek.pathfind.newInfluenceMap(32, 32, 16)
  imap:addLayer("debug")
  local map_width = imap:getWidth()
  imap:addLayer("danger")
  imap:setInfluence("danger", 4, 5, 0.9)
  lurek.log.info("lurek.pathfind.newInfluenceMap: ok=" .. tostring(imap ~= nil))
  lurek.log.info("lurek.pathfind.newInfluenceMap: width=" .. tostring(imap:getWidth()))
end
```

---

### `lurek.pathfind.newIsoGrid`

Creates an isometric grid with the given dimensions.

```lua
lurek.pathfind.newIsoGrid(width, height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | number | Grid width in cells. |
| `height` | number | Grid height in cells. |

**Returns**

| Type | Description |
|------|-------------|
| [LIsoGrid](#lisogrid) | New isometric grid handle. |

**Example**

```lua
do

    local grid = lurek.pathfind.newIsoGrid(6, 5)
    grid:setBlocked(3, 3, true)
    local route = grid:findPath(1, 3, 6, 3) or {}
    local blocked = grid:isBlocked(3, 3)
    lurek.log.info("iso route nodes=" .. tostring(#route) .. " blocked=" .. tostring(blocked))
end
```

---

### `lurek.pathfind.newIsoGridFromField`

Creates an isometric navigation grid from an iso-square tilefield level and movement category.

```lua
lurek.pathfind.newIsoGridFromField(field_ud, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `field_ud` | [LTileField](tilefield.md#ltilefield) | Iso-square tilefield to derive navigation data from. |
| `opts?` | table | Options with `level`, `category`, and `costCategory`. |

**Returns**

| Type | Description |
|------|-------------|
| [LIsoGrid](#lisogrid) | New isometric grid handle. |

**Example**

```lua
do

    local field = lurek.tilefield.new({ width = 6, height = 5, topology = "iso_square" })
    field:setBlock(3, 3, 1, "move", true)
    field:setCost(4, 3, 1, "move", 3)
    local grid = lurek.pathfind.newIsoGridFromField(field, { level = 1, channel = "move" })
    local route = grid:findPath(1, 3, 6, 3) or {}
    lurek.log.info("field iso route nodes=" .. tostring(#route) .. " cost=" .. tostring(grid:getCost(4, 3)))
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

    lurek.log.info("blocked_15_10 = " .. tostring(jps:isBlocked(15, 10)))
    lurek.log.info("blocked_1_1 = " .. tostring(jps:isBlocked(1, 1)))
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

    lurek.log.info("city nav dims = " .. w .. "x" .. h)
    lurek.log.info("default chunk = " .. chunk)
    lurek.log.info("market center blocked = " .. tostring(center_blocked))
end
```

---

### `lurek.pathfind.newNavGridFromField`

Creates a navigation grid from a tilefield level and movement category.

```lua
lurek.pathfind.newNavGridFromField(field_ud, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `field_ud` | [LTileField](tilefield.md#ltilefield) | Tilefield to derive navigation grid from. |
| `opts?` | table | Options with `level`, `category`, `costCategory`, `footprintWidth`, `footprintHeight`, and `diagonalMode`. |

**Returns**

| Type | Description |
|------|-------------|
| [LNavGrid](#lnavgrid) | New navigation grid handle. |

**Example**

```lua
do

    local field = lurek.tilefield.new({ width = 6, height = 6 })
    field:applyProfile(3, 3, 1, "wall")
    local grid = lurek.pathfind.newNavGridFromField(field, { level = 1, channel = "move" })
    local blocked = grid:isBlocked(3, 3)
    local width = grid:getWidth()
    lurek.log.info("field navgrid width=" .. width .. " blocked=" .. tostring(blocked))
end
```

---

### `lurek.pathfind.newNavGridFromProvider`

Builds a navigation grid from a Lua provider table with width, height, optional costs/blocked arrays, or getCost/isBlocked callbacks.

```lua
lurek.pathfind.newNavGridFromProvider(provider)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `provider` | table | Lua-authored navigation-grid provider. |

**Returns**

| Type | Description |
|------|-------------|
| [LNavGrid](#lnavgrid) | New navigation grid copied from provider data. |

**Example**

```lua
do
    local provider = { width = 3, height = 2, blocked = { false, true, false, false, false, false }, costs = { 1, 4, 1, 1, 1, 1 } }
    local ok, value = pcall(function()
        local nav = lurek.pathfind.newNavGridFromProvider(provider)
        return nav:getCost(2, 1)
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
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
| `tm_ud` | [LTileMap](tilemap.md#ltilemap) | Tilemap to derive navigation grid from. |
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

    lurek.log.info("dims = " .. ng:getWidth() .. "x" .. ng:getHeight())
    lurek.log.info("blocked_3_3 = " .. tostring(ng:isBlocked(3, 3)))
    lurek.log.info("blocked_4_3 = " .. tostring(ng:isBlocked(4, 3)))
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

    lurek.log.info("polygons = " .. mesh:getPolygonCount())
    lurek.log.info("ids = " .. id1 .. "," .. id2)
end
```

---

### `lurek.pathfind.newORCASolver`

Creates an ORCA avoidance solver with the supplied prediction horizon.

```lua
lurek.pathfind.newORCASolver(time_horizon)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `time_horizon` | number | Time horizon used when computing collision avoidance velocities. |

**Returns**

| Type | Description |
|------|-------------|
| [LORCASolver](#lorcasolver) | New ORCA solver handle. |

**Example**

```lua
do

  local orca = lurek.pathfind.newORCASolver(1.5)
  orca:addAgent(0, 0, 0.5, 3.0)
  local preview_count = orca:agentCount()
  lurek.log.info("lurek.pathfind.newORCASolver: ok=" .. tostring(orca ~= nil))
  lurek.log.info("lurek.pathfind.newORCASolver: agents=" .. tostring(orca:agentCount()))
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
    lurek.log.info("dims = " .. aiff:getWidth() .. "x" .. aiff:getHeight())
    lurek.log.info("has_goal = " .. tostring(aiff:hasGoal()))
    lurek.log.info("goal = " .. gx .. "," .. gy)
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

    lurek.log.info("patrol grid = " .. width .. "x" .. height)
    lurek.log.info("patrol cell size = " .. cell_size)
    lurek.log.info("approach tile walkable = " .. tostring(chokepoint_open))
end
```

---

### `lurek.pathfind.newPathGridFromProvider`

Builds a path grid from a Lua provider table with width, height, optional cellSize, costs/walkable arrays, or getCost/isWalkable callbacks.

```lua
lurek.pathfind.newPathGridFromProvider(provider)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `provider` | table | Lua-authored path-grid provider. |

**Returns**

| Type | Description |
|------|-------------|
| [LPathGrid](#lpathgrid) | New path grid copied from provider data. |

**Example**

```lua
do
    local provider = { width = 3, height = 2, cellSize = 16, walkable = { true, false, true, true, true, true } }
    local ok, value = pcall(function()
        local grid = lurek.pathfind.newPathGridFromProvider(provider)
        return grid:getCellSize()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
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
        lurek.log.info("steps = " .. #path)
        lurek.log.info("first = " .. path[1].x .. "," .. path[1].y)
        lurek.log.info("last = " .. path[#path].x .. "," .. path[#path].y)
    else
        lurek.log.info("steps = 0")
    end
end
```

---

### `lurek.pathfind.newSteeringManager`

Creates an empty steering manager with support for built-in and custom movement behaviors.

```lua
lurek.pathfind.newSteeringManager()
```

**Returns**

| Type | Description |
|------|-------------|
| [LSteeringManager](#lsteeringmanager) | New steering manager handle. |

**Example**

```lua
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:addSeek(320, 180, 1.0)
  lurek.log.info("lurek.pathfind.newSteeringManager: ok=" .. tostring(steer ~= nil))
  lurek.log.info("lurek.pathfind.newSteeringManager: behaviors=" .. tostring(steer:getBehaviorCount()))
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
| table | Array of event tables with ids, status, optional `path` or grouped `paths`, and completion flags. |

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
    lurek.log.info("request = " .. tostring(request_id))
    lurek.log.info("events = " .. tostring(#seen))
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

    lurek.log.info("dims = " .. result.width .. "x" .. result.height)
    lurek.log.info("cells = " .. #result.cells)
    if #result.cells > 0 then
        lurek.log.info("first = " .. result.cells[1].x .. "," .. result.cells[1].y .. "," .. result.cells[1].cost)
    end
end
```

---

### `lurek.pathfind.rangeMapFromField`

Computes reachable cells from a tilefield level and movement category.

```lua
lurek.pathfind.rangeMapFromField(field_ud, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `field_ud` | [LTileField](tilefield.md#ltilefield) | Tilefield to read. |
| `opts` | table | Options with `origin`, `budget`, optional `level`, `category`, `costCategory`, and `diagonal`. |

**Returns**

| Type | Description |
|------|-------------|
| table | Range map result with `cells`, `width`, `height`, and `level`. |

**Example**

```lua
do

    local field = lurek.tilefield.new({ width = 6, height = 6 })
    field:setCost(2, 1, 1, "move", 2)
    local range = lurek.pathfind.rangeMapFromField(field, { origin = { x = 1, y = 1, z = 1 }, budget = 4 })
    local count = #range.cells
    local width = range.width
    lurek.log.info("field range width=" .. width .. " cells=" .. count)
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

    lurek.log.info("thread count target = " .. target)
    lurek.log.info("thread count actual = " .. actual)
    lurek.log.info("worker sample dims = " .. nav:getWidth() .. "x" .. nav:getHeight())
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
    lurek.log.info("request_id = " .. tostring(request_id))
end
```

---

### `lurek.pathfind.submitAsyncPathPairs`

Queues one async paired batch query against a navigation grid snapshot.

```lua
lurek.pathfind.submitAsyncPathPairs(grid_ud, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `grid_ud` | [LNavGrid](#lnavgrid) | Navigation grid to clone for the worker. |
| `opts` | table | Options with `pairs = { { start = {x,y}, goal = {x,y} } }` and optional owner, version, priority, footprint, unit size, and max steps. |

**Returns**

| Type | Description |
|------|-------------|
| number | Request id for polling and cancellation. |

**Example**

```lua
do

    lurek.pathfind.clearAsyncPaths()
    local nav = lurek.pathfind.newNavGrid(32, 32)
    local request_id = lurek.pathfind.submitAsyncPathPairs(nav, {
        pairs = {
            { start = { x = 1, y = 1 }, goal = { x = 32, y = 32 } },
            { start = { x = 2, y = 2 }, goal = { x = 32, y = 32 } },
            { start = { x = 6, y = 6 }, goal = { x = 20, y = 20 } },
        },
    })
    lurek.log.info("paired_request_id = " .. tostring(request_id))
end
```

---

### `lurek.pathfind.submitAsyncPathsToGoal`

Queues one async shared-goal batch query against a navigation grid snapshot.

```lua
lurek.pathfind.submitAsyncPathsToGoal(grid_ud, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `grid_ud` | [LNavGrid](#lnavgrid) | Navigation grid to clone for the worker. |
| `opts` | table | Options with `starts`, one goal (`goal_x`,`goal_y`) or `targets`, and optional owner, version, priority, footprint, unit size, and max steps. |

**Returns**

| Type | Description |
|------|-------------|
| number | Request id for polling and cancellation. |

**Example**

```lua
do

    lurek.pathfind.clearAsyncPaths()
    local nav = lurek.pathfind.newNavGrid(32, 32)
    local request_id = lurek.pathfind.submitAsyncPathsToGoal(nav, {
        starts = {
            { x = 1, y = 1 },
            { x = 2, y = 2 },
            { x = 6, y = 6 },
        },
        goal_x = 32,
        goal_y = 32,
    })
    lurek.log.info("grouped_request_id = " .. tostring(request_id))
end
```

---

## Module Fields

*No module-level fields documented.*

## Enums

*No module-specific enums documented.*

## Types

- [LAIFlowField](#laiflowfield)
- [LContextSteering](#lcontextsteering)
- [LFlowField](#lflowfield)
- [LGoalMap](#lgoalmap)
- [LHexGrid](#lhexgrid)
- [LInfluenceMap](#linfluencemap)
- [LIsoGrid](#lisogrid)
- [LJpsGrid](#ljpsgrid)
- [LNavGrid](#lnavgrid)
- [LNavMesh](#lnavmesh)
- [LORCASolver](#lorcasolver)
- [LPathGrid](#lpathgrid)
- [LSteeringManager](#lsteeringmanager)
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
    lurek.log.info("dir = " .. dx .. "," .. dy)
    lurek.log.info("distance = " .. aiff:getDistance(1, 1))
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
    lurek.log.info("dir = " .. dx .. "," .. dy)
    lurek.log.info("distance = " .. aiff:getDistance(1, 1))
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
    lurek.log.info("goal = " .. gx .. "," .. gy)
    lurek.log.info("has_goal = " .. tostring(aiff:hasGoal()))
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

    lurek.log.info("dims = " .. ff:getWidth() .. "x" .. ff:getHeight())
    lurek.log.info("has_goal = " .. tostring(ff:hasGoal()))
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

    lurek.log.info("dims = " .. ff:getWidth() .. "x" .. ff:getHeight())
    lurek.log.info("has_goal = " .. tostring(ff:hasGoal()))
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

    lurek.log.info("has_goal_before = " .. tostring(ff:hasGoal()))
    ff:setGoal(16, 16)
    lurek.log.info("has_goal_after = " .. tostring(ff:hasGoal()))
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
    lurek.log.info("has_goal = " .. tostring(aiff:hasGoal()))
    lurek.log.info("goal = " .. gx .. "," .. gy)
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

    lurek.log.info("ai flow field type = " .. type_name)
    lurek.log.info("field dims = " .. width .. "x" .. height)
    lurek.log.info("goal ready = " .. tostring(aiff:hasGoal()))
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

    lurek.log.info("matches LAIFlowField = " .. tostring(is_ai_flow_field))
    lurek.log.info("matches LObject = " .. tostring(is_object))
    lurek.log.info("matches LFlowField = " .. tostring(is_flow_field))
end
```

---

## LContextSteering

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LContextSteering:addAvoidBounds`

Adds rectangular bounds avoidance to context steering.

```lua
LContextSteering:addAvoidBounds(min_x, min_y, max_x, max_y, margin, weight)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min_x` | number | Minimum X bound. |
| `min_y` | number | Minimum Y bound. |
| `max_x` | number | Maximum X bound. |
| `max_y` | number | Maximum Y bound. |
| `margin` | number | Distance from bounds where avoidance begins. |
| `weight` | number | Avoidance behavior weight. |

**Example**

```lua
do

    local cs = lurek.pathfind.newContextSteering(8)
  cs:addSeekTarget(0, 0, 1.0)
  local slot_count = cs:slotCount()
    cs:addAvoidBounds(0, 0, 800, 600, 30.0, 1.0)
    lurek.log.info("avoid bounds set for 800x600 area")
end
```

---

#### `LContextSteering:addAvoidPoint`

Adds a point avoidance influence to context steering.

```lua
LContextSteering:addAvoidPoint(x, y, radius, weight)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Avoidance point X position. |
| `y` | number | Avoidance point Y position. |
| `radius` | number | Avoidance radius in world units. |
| `weight` | number | Avoidance behavior weight. |

**Example**

```lua
do

    local cs = lurek.pathfind.newContextSteering(8)
  cs:addSeekTarget(0, 0, 1.0)
  local slot_count = cs:slotCount()
    cs:addAvoidPoint(50, 50, 20.0, 1.5)
    lurek.log.info("avoid point at (50, 50) radius 20")
end
```

---

#### `LContextSteering:addSeekTarget`

Adds a context steering target attraction.

```lua
LContextSteering:addSeekTarget(tx, ty, weight)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tx` | number | Target X position in world units. |
| `ty` | number | Target Y position in world units. |
| `weight` | number | Attraction weight. |

**Example**

```lua
do

    local cs = lurek.pathfind.newContextSteering(8)
  cs:addSeekTarget(0, 0, 1.0)
  local slot_count = cs:slotCount()
    cs:addSeekTarget(200, 150, 1.0)
    lurek.log.info("seek target added at (200, 150)")
end
```

---

#### `LContextSteering:addWander`

Adds wander noise to context steering.

```lua
LContextSteering:addWander(jitter, weight)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `jitter` | number | Random steering jitter strength. |
| `weight` | number | Wander behavior weight. |

**Example**

```lua
do

    local cs = lurek.pathfind.newContextSteering(8)
  cs:addSeekTarget(0, 0, 1.0)
  local slot_count = cs:slotCount()
    cs:addWander(0.3, 0.5)
    lurek.log.info("wander behavior added")
end
```

---

#### `LContextSteering:chosenMagnitude`

Returns the magnitude of the last selected context steering slot.

```lua
LContextSteering:chosenMagnitude()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Last chosen magnitude. |

**Example**

```lua
do

    local cs = lurek.pathfind.newContextSteering(8)
  cs:addSeekTarget(0, 0, 1.0)
  local slot_count = cs:slotCount()
    cs:addSeekTarget(200, 200, 1.0)
    cs:evaluate(0, 0, 0, 0)
    local mag = cs:chosenMagnitude()
    lurek.log.info("magnitude = " .. mag)
end
```

---

#### `LContextSteering:clearBehaviors`

Removes all context steering behaviors.

```lua
LContextSteering:clearBehaviors()
```

**Example**

```lua
do

    local cs = lurek.pathfind.newContextSteering(8)
  cs:addSeekTarget(0, 0, 1.0)
  local slot_count = cs:slotCount()
    cs:addSeekTarget(100, 100, 1.0)
    cs:addAvoidPoint(50, 50, 10.0, 1.0)
    cs:clearBehaviors()
    lurek.log.info("behaviors cleared")
end
```

---

#### `LContextSteering:evaluate`

Evaluates context steering and returns the selected movement direction.

```lua
LContextSteering:evaluate(ax, ay, vx, vy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ax` | number | Agent X position. |
| `ay` | number | Agent Y position. |
| `vx` | number | Agent X velocity. |
| `vy` | number | Agent Y velocity. |

**Returns**

| Type | Description |
|------|-------------|
| number | Selected X and Y direction. (value 1). |
| number | Selected X and Y direction. (value 2). |

**Example**

```lua
do

    local cs = lurek.pathfind.newContextSteering(8)
  cs:addSeekTarget(0, 0, 1.0)
  local slot_count = cs:slotCount()
    cs:addSeekTarget(300, 200, 1.0)
    cs:addAvoidPoint(150, 150, 30.0, 2.0)
    local dx, dy = cs:evaluate(100, 100, 1.0, 0.0)
    lurek.log.info("direction = " .. dx .. ", " .. dy)
end
```

---

#### `LContextSteering:slotCount`

Returns the number of directional slots used by this context steering model.

```lua
LContextSteering:slotCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Direction slot count. |

**Example**

```lua
do

    local cs = lurek.pathfind.newContextSteering(16)
  cs:addSeekTarget(0, 0, 1.0)
  local slot_count = cs:slotCount()
    local type_name = cs:type()
    lurek.log.info("slots = " .. cs:slotCount())
end
```

---

#### `LContextSteering:type`

Returns the Lua-visible type name for this context steering handle.

```lua
LContextSteering:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LContextSteering](#lcontextsteering)`. |

**Example**

```lua
do

    local cs = lurek.pathfind.newContextSteering(8)
  cs:addSeekTarget(0, 0, 1.0)
  local slot_count = cs:slotCount()
    lurek.log.info("type = " .. cs:type())
  lurek.log.info("matches = " .. tostring(cs:typeOf("LContextSteering")))
end
```

---

#### `LContextSteering:typeOf`

Returns whether this context steering handle matches a supported type name.

```lua
LContextSteering:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LContextSteering](#lcontextsteering)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do

    local cs = lurek.pathfind.newContextSteering(8)
  cs:addSeekTarget(0, 0, 1.0)
  local slot_count = cs:slotCount()
    local type_name = cs:type()
    lurek.log.info("is LContextSteering = " .. tostring(cs:typeOf("LContextSteering")))
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

    lurek.log.info("calculated = " .. tostring(ff:isCalculated()))
    lurek.log.info("targets = " .. #ff:getTargets())
end
```

---

#### `LFlowField:calculateFor`

Calculates a flow field toward one target cell using a named navigation footprint.

```lua
LFlowField:calculateFor(name, tx, ty)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Stable footprint name defined on the backing navigation grid. |
| `tx` | number | One-based target column. |
| `ty` | number | One-based target row. |

**Example**

```lua
do

    local nav = lurek.pathfind.newNavGrid(15, 15)

    nav:fill(1)
    nav:defineFootprint("tank", { w = 2, h = 2 })
    nav:setBlocked(2, 2, true)

    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculateFor("tank", 10, 10)

    lurek.log.info("builds = " .. ff:getBuildCount())
    lurek.log.info("start cost = " .. tostring(ff:getCostToTarget(1, 1)))
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
    lurek.log.info("targets = " .. #targets)
    lurek.log.info("first = " .. targets[1].x .. "," .. targets[1].y)
    lurek.log.info("last = " .. targets[#targets].x .. "," .. targets[#targets].y)
end
```

---

#### `LFlowField:calculateMultiFor`

Calculates a flow field toward multiple target cells using a named navigation footprint.

```lua
LFlowField:calculateMultiFor(name, targets)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Stable footprint name defined on the backing navigation grid. |
| `targets` | table | Array of `{x, y}` target tables. |

**Example**

```lua
do

    local nav = lurek.pathfind.newNavGrid(15, 15)

    nav:fill(1)
    nav:defineFootprint("tank", { w = 2, h = 2 })

    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculateMultiFor("tank", {
        { x = 5, y = 5 },
        { x = 10, y = 10 },
    })

    local targets = ff:getTargets()
    lurek.log.info("targets = " .. #targets)
    lurek.log.info("generation = " .. tostring(ff:getGeneration()))
end
```

---

#### `LFlowField:getBuildCount`

Returns how many full flow-field builds have actually run on this object.

```lua
LFlowField:getBuildCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Number of full rebuilds. |

**Example**

```lua
do

    local nav = lurek.pathfind.newNavGrid(12, 12)

    nav:fill(1)

    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(8, 8)
    ff:calculate(8, 8)
    nav:setBlocked(3, 3, true)
    ff:calculate(8, 8)

    lurek.log.info("rebuild count = " .. tostring(ff:getBuildCount()))
    lurek.log.info("targets = " .. #ff:getTargets())
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
    lurek.log.info("dir = " .. dx .. "," .. dy)
    lurek.log.info("cost = " .. ff:getCostToTarget(1, 1))
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
    lurek.log.info("dir = " .. dx .. "," .. dy)
    lurek.log.info("angle = " .. ff:getDirectionAngle(1, 1))
    lurek.log.info("cost = " .. ff:getCostToTarget(1, 1))
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

    lurek.log.info("angle = " .. ff:getDirectionAngle(1, 1))
    lurek.log.info("cost = " .. ff:getCostToTarget(1, 1))
end
```

---

#### `LFlowField:getGeneration`

Returns the navigation-grid generation that produced the current flow field, or nil before the first build.

```lua
LFlowField:getGeneration()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Monotonic navigation-grid generation, or nil. |

**Example**

```lua
do

    local nav = lurek.pathfind.newNavGrid(12, 12)

    nav:fill(1)

    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(8, 8)
    local before = ff:getGeneration()
    nav:setBlocked(2, 2, true)
    ff:calculate(8, 8)
    local after = ff:getGeneration()

    lurek.log.info("flow generation before = " .. tostring(before))
    lurek.log.info("flow generation after = " .. tostring(after))
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
    lurek.log.info("targets = " .. #targets)
    lurek.log.info("first = " .. targets[1].x .. "," .. targets[1].y)
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

    lurek.log.info("calculated_before = " .. tostring(ff:isCalculated()))
    ff:calculate(8, 8, 1)
    lurek.log.info("calculated_after = " .. tostring(ff:isCalculated()))
end
```

---

#### `LFlowField:pathFrom`

Reconstructs a downhill route from one start cell to the nearest active target in the current flow field.

```lua
LFlowField:pathFrom(x, y, max_steps)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based start column. |
| `y` | number | One-based start row. |
| `max_steps?` | number | Maximum downhill steps to follow before aborting; 0 or nil uses a grid-sized default. |

**Returns**

| Type | Description |
|------|-------------|
| LFlowFieldPathFromResult | Array of `{x, y}` path tables, or nil when the cell is unreachable or the field is unbuilt. |

**Example**

```lua
do

    local nav = lurek.pathfind.newNavGrid(12, 12)

    nav:fill(1)

    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(10, 10)

    local path = ff:pathFrom(1, 1)
    lurek.log.info("path nodes = " .. tostring(path and #path or 0))
    lurek.log.info("last = " .. path[#path].x .. "," .. path[#path].y)
end
```

---

#### `LFlowField:pathsFrom`

Reconstructs downhill routes from many start cells to the nearest active target using one shared flow field.

```lua
LFlowField:pathsFrom(starts, max_steps)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `starts` | table | Array of `{x, y}` start tables. |
| `max_steps?` | number | Maximum downhill steps to follow for each start; 0 or nil uses a grid-sized default. |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of path arrays; unreachable entries are nil. |

**Example**

```lua
do

    local nav = lurek.pathfind.newNavGrid(12, 12)

    nav:fill(1)

    local ff = lurek.pathfind.newFlowField(nav)
    ff:calculate(10, 10)

    local routes = ff:pathsFrom({
        { x = 1, y = 1 },
        { x = 3, y = 3 },
        { x = 10, y = 10 },
    })

    lurek.log.info("route1 nodes = " .. tostring(routes[1] and #routes[1] or 0))
    lurek.log.info("route3 last = " .. routes[3][#routes[3]].x .. "," .. routes[3][#routes[3]].y)
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
    lurek.log.info("velocity = " .. vx .. "," .. vy)
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

    lurek.log.info("flow field type = " .. type_name)
    lurek.log.info("calculated = " .. tostring(calculated))
    lurek.log.info("target count = " .. #targets)
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

    lurek.log.info("matches LFlowField = " .. tostring(is_flow_field))
    lurek.log.info("matches LObject = " .. tostring(is_object))
    lurek.log.info("matches LAIFlowField = " .. tostring(is_ai_flow_field))
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

    lurek.log.info("origin distance = " .. origin_distance)
    lurek.log.info("flank source distance = " .. flank_distance)
    lurek.log.info("corner distance = " .. corner_distance)
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

    lurek.log.info("ready after bake = " .. tostring(ready))
    lurek.log.info("east lane distance = " .. distance_mid)
    lurek.log.info("corner distance = " .. distance_corner)
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
    lurek.log.info("ready_after_clear = " .. tostring(gm:isReady()))
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
    lurek.log.info("distance_5_5 = " .. gm:distanceAt(5, 5))
    lurek.log.info("distance_1_1 = " .. gm:distanceAt(1, 1))
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
    lurek.log.info("flee = " .. dx .. "," .. dy)
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
    lurek.log.info("flood_cells = " .. #cells)
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
    lurek.log.info("gradient = " .. dx .. "," .. dy)
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
    lurek.log.info("ready_before = " .. tostring(gm:isReady()))
    gm:bake()
    lurek.log.info("ready_after = " .. tostring(gm:isReady()))
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
    lurek.log.info("distance_restored = " .. gm2:distanceAt(6, 6))
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
    lurek.log.info("blob_bytes = " .. #blob)
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
    lurek.log.info("distance_12_8 = " .. gm:distanceAt(12, 8))
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
    lurek.log.info("ready = " .. tostring(gm:isReady()))
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

    lurek.log.info("goal map type = " .. type_name)
    lurek.log.info("ready = " .. tostring(ready))
    lurek.log.info("center distance = " .. gm:distanceAt(4, 4))
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

    lurek.log.info("matches LGoalMap = " .. tostring(is_goal_map))
    lurek.log.info("matches LObject = " .. tostring(is_object))
    lurek.log.info("matches LNavMesh = " .. tostring(is_nav_mesh))
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

    lurek.log.info("flank distance = " .. flank_distance)
    lurek.log.info("same cell distance = " .. same_cell_distance)
    lurek.log.info("frontline distance = " .. scout_distance)
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
    lurek.log.info("visible = " .. #visible)
    if #visible > 0 then
        lurek.log.info("first = " .. visible[1].col .. "," .. visible[1].row)
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
        lurek.log.info("steps = " .. #path)
        lurek.log.info("first = " .. path[1].col .. "," .. path[1].row)
        lurek.log.info("last = " .. path[#path].col .. "," .. path[#path].row)
    else
        lurek.log.info("steps = 0")
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

    lurek.log.info("ridge blocked = " .. tostring(ridge))
    lurek.log.info("ridge neighbor blocked = " .. tostring(ridge_neighbor))
    lurek.log.info("southern hex blocked = " .. tostring(open_hex))
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
    lurek.log.info("reachable = " .. #reachable)
    if #reachable > 0 then
        lurek.log.info("first = " .. reachable[1].col .. "," .. reachable[1].row)
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

    lurek.log.info("blocked_5_5 = " .. tostring(hex:isBlocked(5, 5)))
    lurek.log.info("blocked_6_5 = " .. tostring(hex:isBlocked(6, 5)))
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
    lurek.log.info("reachable = " .. #reachable)
    if #reachable > 0 then
        lurek.log.info("first = " .. reachable[1].col .. "," .. reachable[1].row)
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

    lurek.log.info("hex grid type = " .. type_name)
    lurek.log.info("reachable cells = " .. #reachable)
    lurek.log.info("center blocked = " .. tostring(hex:isBlocked(3, 3)))
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

    lurek.log.info("matches LHexGrid = " .. tostring(is_hex_grid))
    lurek.log.info("matches LObject = " .. tostring(is_object))
    lurek.log.info("matches LJpsGrid = " .. tostring(is_jps_grid))
end
```

---

## LInfluenceMap

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LInfluenceMap:addLayer`

Adds an influence layer with the given name if it does not already exist.

```lua
LInfluenceMap:addLayer(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Layer name used by later influence operations. |

**Example**

```lua
do

    local im = lurek.pathfind.newInfluenceMap(16, 16, 1.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
    im:addLayer("threat")
    im:addLayer("resources")
    lurek.log.info("layers added: threat, resources")
end
```

---

#### `LInfluenceMap:blend`

Blends two source layers into a destination layer using independent weights.

```lua
LInfluenceMap:blend(layer_a, weight_a, layer_b, weight_b, dest)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer_a` | string | First source layer name. |
| `weight_a` | number | Weight applied to the first source layer. |
| `layer_b` | string | Second source layer name. |
| `weight_b` | number | Weight applied to the second source layer. |
| `dest` | string | Destination layer name that receives the blended values. |

**Example**

```lua
do

  local im = lurek.pathfind.newInfluenceMap(8, 8, 1.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
  im:addLayer("threat")
  im:addLayer("reward")
  im:addLayer("combined")
  im:setInfluence("threat", 4, 4, 1.0)
  im:setInfluence("reward", 4, 4, 0.8)
  im:blend("threat", 0.5, "reward", 0.5, "combined")
  local val = im:getInfluence("combined", 4, 4)
    lurek.log.info("blended (4,4) = " .. val)
end
```

---

#### `LInfluenceMap:clearAll`

Clears every influence value in every layer.

```lua
LInfluenceMap:clearAll()
```

**Example**

```lua
do

  local im = lurek.pathfind.newInfluenceMap(8, 8, 1.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
  im:addLayer("a")
  im:addLayer("b")
  im:setInfluence("a", 1, 1, 1.0)
    im:setInfluence("b", 2, 2, 0.5)
    im:clearAll()
    lurek.log.info("all cleared, a(1,1) = " .. im:getInfluence("a", 1, 1))
end
```

---

#### `LInfluenceMap:clearLayer`

Clears every value in a named influence layer.

```lua
LInfluenceMap:clearLayer(layer)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | string | Layer name to clear. |

**Example**

```lua
do

  local im = lurek.pathfind.newInfluenceMap(8, 8, 1.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
  im:addLayer("marks")
    im:setInfluence("marks", 2, 2, 1.0)
    im:clearLayer("marks")
    local val = im:getInfluence("marks", 2, 2)
    lurek.log.info("after clear = " .. val)
end
```

---

#### `LInfluenceMap:decay`

Multiplies a named layer by a decay factor.

```lua
LInfluenceMap:decay(layer, factor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | string | Layer name to decay. |
| `factor` | number | Decay factor applied to every cell. |

**Example**

```lua
do

  local im = lurek.pathfind.newInfluenceMap(8, 8, 1.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
  im:addLayer("heat")
    im:setInfluence("heat", 4, 4, 1.0)
    im:decay("heat", 0.5)
    local val = im:getInfluence("heat", 4, 4)
    lurek.log.info("heat after decay = " .. val)
end
```

---

#### `LInfluenceMap:getCellSize`

Returns the world size represented by each influence map cell.

```lua
LInfluenceMap:getCellSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Cell size in world units. |

**Example**

```lua
do

    local im = lurek.pathfind.newInfluenceMap(8, 8, 2.5)
  im:addLayer("debug")
  local map_width = im:getWidth()
    local map_height = im:getHeight()
    lurek.log.info("cell size = " .. im:getCellSize())
end
```

---

#### `LInfluenceMap:getHeight`

Returns the influence map height in cells.

```lua
LInfluenceMap:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Cell height of the map. |

**Example**

```lua
do

    local im = lurek.pathfind.newInfluenceMap(16, 12, 2.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
    local cell_size = im:getCellSize()
    lurek.log.info("height = " .. im:getHeight())
end
```

---

#### `LInfluenceMap:getInfluence`

Returns one cell value from a named influence layer using one-based cell coordinates.

```lua
LInfluenceMap:getInfluence(layer, x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | string | Layer name to read. |
| `x` | number | One-based cell X coordinate. |
| `y` | number | One-based cell Y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| number | Influence value at the requested cell. |

**Example**

```lua
do

    local im = lurek.pathfind.newInfluenceMap(10, 10, 1.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
    im:addLayer("food")
    im:setInfluence("food", 4, 4, 0.75)
    local val = im:getInfluence("food", 4, 4)
    lurek.log.info("food at (4,4) = " .. val)
end
```

---

#### `LInfluenceMap:getMaxPosition`

Returns the cell position with the highest value on a named layer.

```lua
LInfluenceMap:getMaxPosition(layer)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | string | Layer name to scan. |

**Returns**

| Type | Description |
|------|-------------|
| number | One-based X and Y cell coordinates of the maximum value. (value 1). |
| number | One-based X and Y cell coordinates of the maximum value. (value 2). |

**Example**

```lua
do

  local im = lurek.pathfind.newInfluenceMap(10, 10, 1.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
  im:addLayer("gold")
    im:setInfluence("gold", 7, 3, 0.9)
    im:setInfluence("gold", 2, 8, 0.4)
    local mx, my = im:getMaxPosition("gold")
    lurek.log.info("max gold at (" .. mx .. ", " .. my .. ")")
end
```

---

#### `LInfluenceMap:getMinPosition`

Returns the cell position with the lowest value on a named layer.

```lua
LInfluenceMap:getMinPosition(layer)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | string | Layer name to scan. |

**Returns**

| Type | Description |
|------|-------------|
| number | One-based X and Y cell coordinates of the minimum value. (value 1). |
| number | One-based X and Y cell coordinates of the minimum value. (value 2). |

**Example**

```lua
do

  local im = lurek.pathfind.newInfluenceMap(10, 10, 1.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
  im:addLayer("cold")
    im:setInfluence("cold", 1, 1, -0.5)
    im:setInfluence("cold", 5, 5, 0.3)
    local mx, my = im:getMinPosition("cold")
    lurek.log.info("min cold at (" .. mx .. ", " .. my .. ")")
end
```

---

#### `LInfluenceMap:getWidth`

Returns the influence map width in cells.

```lua
LInfluenceMap:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Cell width of the map. |

**Example**

```lua
do

    local im = lurek.pathfind.newInfluenceMap(16, 12, 2.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
    local map_height = im:getHeight()
    lurek.log.info("width = " .. im:getWidth())
end
```

---

#### `LInfluenceMap:hasLayer`

Returns whether an influence layer exists.

```lua
LInfluenceMap:hasLayer(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Layer name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the layer exists. |

**Example**

```lua
do

    local im = lurek.pathfind.newInfluenceMap(8, 8, 2.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
    im:addLayer("heat")
    lurek.log.info("has heat = " .. tostring(im:hasLayer("heat")))
    lurek.log.info("has cold = " .. tostring(im:hasLayer("cold")))
end
```

---

#### `LInfluenceMap:propagate`

Propagates influence values across neighboring cells on a named layer.

```lua
LInfluenceMap:propagate(layer, momentum)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | string | Layer name to propagate. |
| `momentum?` | number | Propagation momentum factor; defaults to 0.5. |

**Example**

```lua
do

  local im = lurek.pathfind.newInfluenceMap(10, 10, 1.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
  im:addLayer("scent")
    im:setInfluence("scent", 5, 5, 1.0)
    im:propagate("scent", 0.8)
    local neighbor = im:getInfluence("scent", 4, 5)
    lurek.log.info("scent propagated to (4,5) = " .. neighbor)
end
```

---

#### `LInfluenceMap:queryRect`

Returns influence values inside a world-space rectangle on a named layer.

```lua
LInfluenceMap:queryRect(layer, wx, wy, ww, wh)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | string | Layer name to query. |
| `wx` | number | Rectangle X coordinate in world units. |
| `wy` | number | Rectangle Y coordinate in world units. |
| `ww` | number | Rectangle width in world units. |
| `wh` | number | Rectangle height in world units. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array of influence samples from cells inside the rectangle. |

**Example**

```lua
do

  local im = lurek.pathfind.newInfluenceMap(10, 10, 1.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
  im:addLayer("energy")
    im:setInfluence("energy", 2, 2, 0.5)
    im:setInfluence("energy", 3, 3, 0.5)
    local total = im:queryRect("energy", 1, 1, 4, 4)
    lurek.log.info("energy in rect = " .. total)
end
```

---

#### `LInfluenceMap:setInfluence`

Sets one cell value in a named influence layer using one-based cell coordinates.

```lua
LInfluenceMap:setInfluence(layer, x, y, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | string | Layer name to modify. |
| `x` | number | One-based cell X coordinate. |
| `y` | number | One-based cell Y coordinate. |
| `value` | number | Influence value to store in the cell. |

**Example**

```lua
do

    local im = lurek.pathfind.newInfluenceMap(10, 10, 1.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
    im:addLayer("danger")
    im:setInfluence("danger", 5, 5, 1.0)
    im:setInfluence("danger", 3, 7, 0.5)
    lurek.log.info("set influence at (5,5) and (3,7)")
end
```

---

#### `LInfluenceMap:stampInfluence`

Applies a radial influence stamp to a named layer in world coordinates.

```lua
LInfluenceMap:stampInfluence(layer, wx, wy, radius, value, falloff)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | string | Layer name to modify. |
| `wx` | number | World X coordinate of the stamp center. |
| `wy` | number | World Y coordinate of the stamp center. |
| `radius` | number | Stamp radius in world units. |
| `value` | number | Influence value applied at the center. |
| `falloff?` | number | Falloff exponent or multiplier; defaults to 1.0. |

**Example**

```lua
do

    local im = lurek.pathfind.newInfluenceMap(20, 20, 1.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
    im:addLayer("noise")
    im:stampInfluence("noise", 10.0, 10.0, 3.0, 1.0, 0.5)
    local center = im:getInfluence("noise", 10, 10)
    lurek.log.info("noise center = " .. center)
end
```

---

#### `LInfluenceMap:type`

Returns the Lua-visible type name for this influence map handle.

```lua
LInfluenceMap:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LInfluenceMap](#linfluencemap)`. |

**Example**

```lua
do

    local im = lurek.pathfind.newInfluenceMap(4, 4, 1.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
    lurek.log.info("type = " .. im:type())
  lurek.log.info("matches = " .. tostring(im:typeOf("LInfluenceMap")))
end
```

---

#### `LInfluenceMap:typeOf`

Returns whether this influence map handle matches a supported type name.

```lua
LInfluenceMap:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `InfluenceMap` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do

    local im = lurek.pathfind.newInfluenceMap(4, 4, 1.0)
  im:addLayer("debug")
  local map_width = im:getWidth()
    local type_name = im:type()
    lurek.log.info("is LInfluenceMap = " .. tostring(im:typeOf("LInfluenceMap")))
end
```

---

## LIsoGrid

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LIsoGrid:findPath`

Finds a path between one-based isometric cells.

```lua
LIsoGrid:findPath(fx, fy, tx, ty)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `fx` | number | One-based start X coordinate. |
| `fy` | number | One-based start Y coordinate. |
| `tx` | number | One-based goal X coordinate. |
| `ty` | number | One-based goal Y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| LIsoGridFindPathResult | Array of `{x, y}` cell tables, or nil when no path exists. |

**Example**

```lua
do

    local grid = lurek.pathfind.newIsoGrid(7, 5)
    grid:setBlocked(4, 1, true)
    grid:setBlocked(4, 2, true)
    grid:setBlocked(4, 3, true)
    local route = grid:findPath(1, 2, 7, 2) or {}
    local last = route[#route] or { x = 0, y = 0 }
    lurek.log.info("iso path nodes=" .. tostring(#route) .. " last=" .. tostring(last.x) .. "," .. tostring(last.y))
end
```

---

#### `LIsoGrid:getCost`

Returns movement cost for a one-based isometric grid cell.

```lua
LIsoGrid:getCost(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based cell X coordinate. |
| `y` | number | One-based cell Y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| number | Movement cost. |

**Example**

```lua
do

    local grid = lurek.pathfind.newIsoGrid(5, 5)
    grid:setCost(2, 2, 3.5)
    grid:setCost(2, 3, 1.5)
    local bridge = grid:getCost(2, 2)
    local lane = grid:getCost(2, 3)
    local plain = grid:getCost(1, 1)
    lurek.log.info("iso costs bridge=" .. tostring(bridge) .. " lane=" .. tostring(lane) .. " plain=" .. tostring(plain))
end
```

---

#### `LIsoGrid:isBlocked`

Returns whether a one-based isometric grid cell is blocked.

```lua
LIsoGrid:isBlocked(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based cell X coordinate. |
| `y` | number | One-based cell Y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when blocked or out of bounds. |

**Example**

```lua
do

    local grid = lurek.pathfind.newIsoGrid(5, 5)
    grid:setBlocked(4, 2, true)
    local wall = grid:isBlocked(4, 2)
    local floor = grid:isBlocked(4, 3)
    local route = grid:findPath(1, 2, 5, 2) or {}
    lurek.log.info("iso blocked wall=" .. tostring(wall) .. " floor=" .. tostring(floor) .. " route=" .. tostring(#route))
end
```

---

#### `LIsoGrid:setBlocked`

Sets blocked state for a one-based isometric grid cell.

```lua
LIsoGrid:setBlocked(x, y, blocked)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based cell X coordinate. |
| `y` | number | One-based cell Y coordinate. |
| `blocked` | boolean | True to block the cell. |

**Example**

```lua
do

    local grid = lurek.pathfind.newIsoGrid(5, 5)
    grid:setBlocked(2, 3, true)
    grid:setBlocked(2, 4, true)
    local first = grid:isBlocked(2, 3)
    local second = grid:isBlocked(2, 4)
    lurek.log.info("iso blockers first=" .. tostring(first) .. " second=" .. tostring(second))
end
```

---

#### `LIsoGrid:setCost`

Sets movement cost for a one-based isometric grid cell.

```lua
LIsoGrid:setCost(x, y, cost)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based cell X coordinate. |
| `y` | number | One-based cell Y coordinate. |
| `cost` | number | Finite positive movement cost. |

**Example**

```lua
do

    local grid = lurek.pathfind.newIsoGrid(5, 5)
    grid:setCost(3, 2, 2.5)
    grid:setCost(3, 3, 4.0)
    local road = grid:getCost(3, 2)
    local mud = grid:getCost(3, 3)
    lurek.log.info("iso costs road=" .. tostring(road) .. " mud=" .. tostring(mud))
end
```

---

#### `LIsoGrid:type`

Returns the Lua-visible type name for this isometric grid handle.

```lua
LIsoGrid:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LIsoGrid](#lisogrid)`. |

**Example**

```lua
do

    local grid = lurek.pathfind.newIsoGrid(4, 4)
    grid:setCost(2, 2, 2)
    local type_name = grid:type()
    local cost = grid:getCost(2, 2)
    local route = grid:findPath(1, 1, 4, 4) or {}
    lurek.log.info("iso type=" .. type_name .. " cost=" .. tostring(cost) .. " route=" .. tostring(#route))
end
```

---

#### `LIsoGrid:typeOf`

Returns whether this isometric grid handle matches a supported type name.

```lua
LIsoGrid:typeOf(name)
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

    local grid = lurek.pathfind.newIsoGrid(4, 4)
    grid:setBlocked(2, 2, true)
    local is_iso = grid:typeOf("LIsoGrid")
    local is_object = grid:typeOf("LObject")
    local is_hex = grid:typeOf("LHexGrid")
    lurek.log.info("iso typeOf iso=" .. tostring(is_iso) .. " object=" .. tostring(is_object) .. " hex=" .. tostring(is_hex))
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
        lurek.log.info("points = " .. #path)
        lurek.log.info("first = " .. path[1].x .. "," .. path[1].y)
        lurek.log.info("last = " .. path[#path].x .. "," .. path[#path].y)
    else
        lurek.log.info("points = 0")
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

    lurek.log.info("wall center blocked = " .. tostring(wall_center))
    lurek.log.info("wall neighbor blocked = " .. tostring(wall_neighbor))
    lurek.log.info("lane blocked = " .. tostring(lane_open))
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

    lurek.log.info("blocked_15_10 = " .. tostring(jps:isBlocked(15, 10)))
    lurek.log.info("blocked_15_12 = " .. tostring(jps:isBlocked(15, 12)))
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

    lurek.log.info("jps grid type = " .. type_name)
    lurek.log.info("center blocked = " .. tostring(blocked_center))
    lurek.log.info("corner route nodes = " .. tostring(path and #path or 0))
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

    lurek.log.info("matches LJpsGrid = " .. tostring(is_jps_grid))
    lurek.log.info("matches LObject = " .. tostring(is_object))
    lurek.log.info("matches LHexGrid = " .. tostring(is_hex_grid))
end
```

---

## LNavGrid

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LNavGrid:beginUpdate`

Starts a batched navigation edit that is finalized by `commitUpdate`.

```lua
LNavGrid:beginUpdate()
```

**Example**

```lua
do

    local nav = lurek.pathfind.newNavGrid(20, 20)
    nav:beginUpdate()
    nav:setBlockedRect(4, 4, 2, 2, true)
    local before = nav:getGeneration()
    local committed = nav:commitUpdate()

    lurek.log.info("generation before commit = " .. before)
    lurek.log.info("committed rects = " .. committed)
end
```

---

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

    lurek.log.info("chunk = " .. nav:getChunkSize())
end
```

---

#### `LNavGrid:commitUpdate`

Finalizes a batched navigation edit and refreshes clearance caches according to `opts.rebuild`.

```lua
LNavGrid:commitUpdate(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts?` | table?|Optional | "full"`. |

**Returns**

| Type | Description |
|------|-------------|
| number | Number of dirty rectangles committed by this batch. |

**Example**

```lua
do

    local nav = lurek.pathfind.newNavGrid(20, 20)
    nav:beginUpdate()
    nav:setBlockedRect(4, 4, 2, 2, true)
    nav:setCostRect(10, 10, 2, 2, 9)
    local committed = nav:commitUpdate({ rebuild = "dirty_chunks" })

    lurek.log.info("commit dirty rect count = " .. committed)
    lurek.log.info("generation = " .. nav:getGeneration())
end
```

---

#### `LNavGrid:defineFootprint`

Stores or replaces a named rectangular footprint for clearance caching.

```lua
LNavGrid:defineFootprint(name, footprint)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Stable footprint name. |
| `footprint` | table | Footprint table with positive `w` and `h` cell dimensions. |

**Example**

```lua
do

    local nav = lurek.pathfind.newNavGrid(20, 20)
    nav:defineFootprint("tank", { w = 2, h = 2 })
    local spec = nav:getFootprint("tank")
    nav:setBlocked(10, 10, true)

    lurek.log.info("tank footprint = " .. spec.w .. "x" .. spec.h)
    lurek.log.info("blocked pivot = " .. tostring(nav:isBlocked(10, 10)))
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
| `cost` | number | Movement cost (0-255). |

**Example**

```lua
do

    local nav = lurek.pathfind.newNavGrid(20, 20)
    nav:fill(3)
    nav:setCost(10, 10, 1)
    local border_cost = nav:getCost(1, 1)
    local far_corner_cost = nav:getCost(20, 20)
    local plaza_cost = nav:getCost(10, 10)

    lurek.log.info("default patrol cost = " .. border_cost)
    lurek.log.info("far corner cost = " .. far_corner_cost)
    lurek.log.info("plaza override cost = " .. plaza_cost)
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
| `cost` | number | Movement cost (0-255). |

**Example**

```lua
do

    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fillRect(5, 5, 5, 5, 0)

    lurek.log.info("blocked_5_5 = " .. tostring(nav:isBlocked(5, 5)))
    lurek.log.info("blocked_10_10 = " .. tostring(nav:isBlocked(10, 10)))
    lurek.log.info("blocked_11_11 = " .. tostring(nav:isBlocked(11, 11)))
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
    lurek.log.info("hpa path exists = " .. tostring(path ~= nil))
    lurek.log.info("hpa path len = " .. tostring(path and #path or 0))
end
```

---

#### `LNavGrid:findHpaPathsToGoal`

Finds hierarchical paths from many one-based start cells to one goal while sharing one abstract-goal search setup.

```lua
LNavGrid:findHpaPathsToGoal(starts, gx, gy, unit_size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `starts` | table | Array of `{x, y}` start tables. |
| `gx` | number | One-based goal column. |
| `gy` | number | One-based goal row. |
| `unit_size?` | number | Optional unit footprint in cells, default 1. |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of `{x, y}` waypoint-table arrays, or nil entries when no path exists. |

**Example**

```lua
do

    local nav = lurek.pathfind.newNavGrid(32, 32)
    nav:setChunkSize(8)
    nav:rebuildAbstract()

    local paths = nav:findHpaPathsToGoal({
        { x = 1, y = 1 },
        { x = 2, y = 8 },
        { x = 10, y = 3 },
    }, 30, 30, 1)

    lurek.log.info("shared hpa count = " .. tostring(#paths))
    lurek.log.info("first len = " .. tostring(paths[1] and #paths[1] or 0))
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

    lurek.log.info("chunk size = " .. chunk_size)
    lurek.log.info("sector dims = " .. dimensions)
    lurek.log.info("warehouse blocked = " .. tostring(nav:isBlocked(60, 60)))
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

    lurek.log.info("shallow water cost = " .. shallow_water)
    lurek.log.info("deep water cost = " .. deep_water)
    lurek.log.info("dry ground cost = " .. dry_ground)
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

    lurek.log.info("formation diagonal mode = " .. mode)
    lurek.log.info("blocked neighbor = " .. tostring(blocked_neighbor))
    lurek.log.info("origin walkable = " .. tostring(nav:isWalkable(1, 1)))
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

    lurek.log.info("nav dims = " .. w .. "x" .. h)
    lurek.log.info("width via getter = " .. width)
    lurek.log.info("height via getter = " .. height)
end
```

---

#### `LNavGrid:getDirtyRects`

Returns the committed dirty rectangles recorded on this grid.

```lua
LNavGrid:getDirtyRects()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Array of `{x, y, w, h}` tables using one-based positions. |

**Example**

```lua
do

    local nav = lurek.pathfind.newNavGrid(20, 20)
    nav:setBlockedRect(5, 5, 3, 3, true)
    local rects = nav:getDirtyRects()
    local first = rects[1]

    lurek.log.info("dirty rect count = " .. #rects)
    lurek.log.info("first dirty rect = " .. first.x .. "," .. first.y .. " " .. first.w .. "x" .. first.h)
end
```

---

#### `LNavGrid:getFootprint`

Returns the stored width and height for a named footprint when it exists.

```lua
LNavGrid:getFootprint(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Footprint name. |

**Returns**

| Type | Description |
|------|-------------|
| table | Table with `w` and `h`, or nil when the name is unknown. |

**Example**

```lua
do

    local nav = lurek.pathfind.newNavGrid(20, 20)
    nav:defineFootprint("super_heavy", { w = 4, h = 4 })
    local spec = nav:getFootprint("super_heavy")
    local missing = nav:getFootprint("missing")

    lurek.log.info("super heavy width = " .. spec.w)
    lurek.log.info("missing footprint = " .. tostring(missing == nil))
end
```

---

#### `LNavGrid:getGeneration`

Returns the current navigation-grid generation used for cache invalidation.

```lua
LNavGrid:getGeneration()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Monotonic generation counter. |

**Example**

```lua
do

    local ng = lurek.pathfind.newNavGrid(20, 15)
    local before = ng:getGeneration()
    ng:setBlocked(10, 8, true)
    local after = ng:getGeneration()

    lurek.log.info("generation before = " .. before)
    lurek.log.info("generation after = " .. after)
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

    lurek.log.info("dims = " .. w .. "x" .. h)
    lurek.log.info("height = " .. height)
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

    lurek.log.info("dims = " .. w .. "x" .. h)
    lurek.log.info("width = " .. width)
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

    lurek.log.info("barricade = " .. tostring(barricade))
    lurek.log.info("second barricade = " .. tostring(second_barricade))
    lurek.log.info("alley blocked = " .. tostring(alley))
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

    lurek.log.info("walkable_1x1 = " .. tostring(nav:isWalkable(5, 5)))
    lurek.log.info("walkable_blocked = " .. tostring(nav:isWalkable(6, 6)))
    lurek.log.info("walkable_2x2 = " .. tostring(nav:isWalkable(5, 5, 2)))
end
```

---

#### `LNavGrid:isWalkableFor`

Returns whether a one-based grid cell is walkable for a named footprint.

```lua
LNavGrid:isWalkableFor(name, x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Footprint name registered on this grid. |
| `x` | number | One-based column. |
| `y` | number | One-based row. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the full footprint fits and is passable. |

**Example**

```lua
do

    local nav = lurek.pathfind.newNavGrid(20, 20)
    nav:defineFootprint("tank", { w = 2, h = 2 })
    nav:rebuildClearance()
    nav:setBlocked(2, 2, true)

    lurek.log.info("tank at 1,1 = " .. tostring(nav:isWalkableFor("tank", 1, 1)))
    lurek.log.info("tank at 3,3 = " .. tostring(nav:isWalkableFor("tank", 3, 3)))
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

    lurek.log.info("blocked_5_5 = " .. tostring(nav2:isBlocked(5, 5)))
    lurek.log.info("cost_3_3 = " .. nav2:getCost(3, 3))
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

    lurek.log.info("chunk = " .. nav:getChunkSize())
    lurek.log.info("blocked_1_1 = " .. tostring(nav:isBlocked(1, 1)))
end
```

---

#### `LNavGrid:rebuildClearance`

Rebuilds clearance caches for all defined footprints or the supplied named subset.

```lua
LNavGrid:rebuildClearance(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts?` | table | Optional table with `profiles = { "name" }`. |

**Returns**

| Type | Description |
|------|-------------|
| number | Number of unique footprint dimensions rebuilt. |

**Example**

```lua
do

    local nav = lurek.pathfind.newNavGrid(20, 20)
    nav:defineFootprint("infantry", { w = 1, h = 1 })
    nav:defineFootprint("tank", { w = 2, h = 2 })
    local rebuilt = nav:rebuildClearance()

    lurek.log.info("rebuilt footprints = " .. rebuilt)
    lurek.log.info("tank walkable = " .. tostring(nav:isWalkableFor("tank", 1, 1)))
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

    lurek.log.info("bytes = " .. #data)
    lurek.log.info("blocked_5_5 = " .. tostring(nav:isBlocked(5, 5)))
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

    lurek.log.info("main gate blocked = " .. tostring(blocked_gate))
    lurek.log.info("corridor blocked = " .. tostring(blocked_corridor))
    lurek.log.info("detour open = " .. tostring(detour_open))
end
```

---

#### `LNavGrid:setBlockedRect`

Applies one blocked or passable rectangle in batch-edit style.

```lua
LNavGrid:setBlockedRect(x, y, w, h, blocked, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based top-left column. |
| `y` | number | One-based top-left row. |
| `w` | number | Rectangle width in cells. |
| `h` | number | Rectangle height in cells. |
| `blocked` | boolean | True to block the rectangle. |
| `opts?` | table | Optional metadata reserved for future use. |

**Example**

```lua
do

    local nav = lurek.pathfind.newNavGrid(20, 20)
    nav:setBlockedRect(5, 5, 3, 3, true)
    local center = nav:isBlocked(6, 6)
    local edge = nav:isBlocked(5, 5)

    lurek.log.info("blocked center = " .. tostring(center))
    lurek.log.info("blocked edge = " .. tostring(edge))
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

    lurek.log.info("hpa chunk size = " .. chunk_size)
    lurek.log.info("blocked logistics hub = " .. tostring(blocked_hub))
    lurek.log.info("nav width = " .. nav:getWidth())
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
| `cost` | number | Movement cost (0-255). |

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

    lurek.log.info("swamp cost = " .. swamp_cost)
    lurek.log.info("trail cost = " .. path_cost)
    lurek.log.info("swamp blocked = " .. tostring(swamp_blocked))
end
```

---

#### `LNavGrid:setCostRect`

Applies one cost rectangle in batch-edit style.

```lua
LNavGrid:setCostRect(x, y, w, h, cost, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based top-left column. |
| `y` | number | One-based top-left row. |
| `w` | number | Rectangle width in cells. |
| `h` | number | Rectangle height in cells. |
| `cost` | number | Movement cost (0-255). |
| `opts?` | table | Optional metadata reserved for future use. |

**Example**

```lua
do

    local nav = lurek.pathfind.newNavGrid(20, 20)
    nav:setCostRect(5, 5, 3, 3, 7)
    local center = nav:getCost(6, 6)
    local edge = nav:getCost(5, 5)

    lurek.log.info("cost center = " .. center)
    lurek.log.info("cost edge = " .. edge)
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

    lurek.log.info("scout diagonal mode = " .. mode)
    lurek.log.info("corner tile open = " .. tostring(direct_corner))
    lurek.log.info("blocked pivot = " .. tostring(nav:isBlocked(5, 5)))
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

    lurek.log.info("blocked_25_25 = " .. tostring(nav:isBlocked(25, 25)))
    lurek.log.info("chunk = " .. nav:getChunkSize())
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

    lurek.log.info("nav grid type = " .. type_name)
    lurek.log.info("debug dims = " .. dims)
    lurek.log.info("center cost = " .. center_cost)
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

    lurek.log.info("matches LNavGrid = " .. tostring(is_nav_grid))
    lurek.log.info("matches LObject = " .. tostring(is_object))
    lurek.log.info("matches LPathGrid = " .. tostring(is_path_grid))
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

    lurek.log.info("polygon_id = " .. id)
    lurek.log.info("polygon_count = " .. mesh:getPolygonCount())
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

    lurek.log.info("connected_ab = " .. tostring(ab))
    lurek.log.info("connected_bc = " .. tostring(bc))
    lurek.log.info("polygon_count = " .. mesh:getPolygonCount())
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
        lurek.log.info("waypoints = " .. #path)
        lurek.log.info("first = " .. path[1].x .. "," .. path[1].y)
        lurek.log.info("last = " .. path[#path].x .. "," .. path[#path].y)
    else
        lurek.log.info("waypoints = 0")
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

    lurek.log.info("polygon_count = " .. mesh:getPolygonCount())
    lurek.log.info("first_id = " .. id)
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

    lurek.log.info("nav mesh type = " .. type_name)
    lurek.log.info("triangle count = " .. polygon_count)
    lurek.log.info("mesh ready for corridor routing = " .. tostring(polygon_count > 0))
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

    lurek.log.info("matches LNavMesh = " .. tostring(is_nav_mesh))
    lurek.log.info("matches LObject = " .. tostring(is_object))
    lurek.log.info("matches LGoalMap = " .. tostring(is_goal_map))
end
```

---

## LORCASolver

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LORCASolver:addAgent`

Adds an ORCA avoidance agent and returns its zero-based solver index.

```lua
LORCASolver:addAgent(x, y, radius, max_speed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Initial X position. |
| `y` | number | Initial Y position. |
| `radius` | number | Collision radius. |
| `max_speed` | number | Maximum preferred speed. |

**Returns**

| Type | Description |
|------|-------------|
| number | Zero-based ORCA agent index. |

**Example**

```lua
do

    local orca = lurek.pathfind.newORCASolver(2.0)
    local idx = orca:addAgent(10.0, 20.0, 0.5, 3.0)
    local count = orca:agentCount()
    local type_name = orca:type()
    lurek.log.info("agent index = " .. idx)
end
```

---

#### `LORCASolver:agentCount`

Returns the number of ORCA agents in this solver.

```lua
LORCASolver:agentCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current ORCA agent count. |

**Example**

```lua
do

    local orca = lurek.pathfind.newORCASolver(2.0)
    orca:addAgent(0, 0, 1.0, 2.0)
    orca:addAgent(5, 5, 1.0, 2.0)
    local type_name = orca:type()
    local is_solver = orca:typeOf("LORCASolver")
    lurek.log.info("agent count = " .. orca:agentCount())
end
```

---

#### `LORCASolver:compute`

Computes safe velocities for all ORCA agents, optionally under a time budget.

```lua
LORCASolver:compute(dt_or_opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt_or_opts` | number|table | Either elapsed time in seconds, or a table with `dt`, `maxMs`, or `max_ms`. |

**Example**

```lua
do

  local orca = lurek.pathfind.newORCASolver(1.5)
  orca:addAgent(0, 0, 0.5, 3.0)
  orca:addAgent(5, 0, 0.5, 3.0)
  orca:setPreferredVelocity(0, 1.0, 0.0)
    orca:setPreferredVelocity(1, -1.0, 0.0)
    orca:compute({ dt = 0.016, max_ms = 1.0 })
    lurek.log.info("collision avoidance computed")
end
```

---

#### `LORCASolver:getSafeVelocity`

Returns the computed safe velocity for an ORCA agent addressed by zero-based index or stable key.

```lua
LORCASolver:getSafeVelocity(idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Zero-based ORCA agent index or stable caller-provided key. |

**Returns**

| Type | Description |
|------|-------------|
| number | Safe X and Y velocity; or zero velocity for an invalid index. (value 1). |
| number | Safe X and Y velocity; or zero velocity for an invalid index. (value 2). |

**Example**

```lua
do

  local orca = lurek.pathfind.newORCASolver(1.5)
  orca:addAgent(0, 0, 0.5, 3.0)
    orca:setPreferredVelocity(0, 2.0, 0.0)
    orca:compute(0.016)
    local vx, vy = orca:getSafeVelocity(0)
    lurek.log.info("safe velocity = " .. vx .. ", " .. vy)
end
```

---

#### `LORCASolver:getStats`

Returns statistics from the most recent ORCA compute step.

```lua
LORCASolver:getStats()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Table containing processed-agent, neighbor, budget, and spatial-hash counters. |

**Example**

```lua
do

    local orca = lurek.pathfind.newORCASolver(1.5)
    for i = 1, 16 do
        orca:setAgent(i, {
            x = (i - 1) * 1.0,
            y = 0.0,
            radius = 0.5,
            max_speed = 3.0,
            preferred_vx = 1.0,
            preferred_vy = 0.0,
        })
    end
    orca:compute({ dt = 0.016, max_ms = 0.0 })
    local stats = orca:getStats()
    lurek.log.info("budget exhausted = " .. tostring(stats.budgetExhausted))
end
```

---

#### `LORCASolver:removeAgent`

Removes an ORCA agent addressed by zero-based index or stable key.

```lua
LORCASolver:removeAgent(idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Zero-based ORCA agent index or stable caller-provided key. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when an agent was removed. |

**Example**

```lua
do

    local orca = lurek.pathfind.newORCASolver(2.0)
    orca:setAgent(200, { x = 0.0, y = 0.0, radius = 0.5, max_speed = 2.0 })
    local before = orca:agentCount()
    local removed = orca:removeAgent(200)
    local after = orca:agentCount()
    lurek.log.info("agent count before = " .. tostring(before))
    lurek.log.info("removed agent = " .. tostring(removed))
    lurek.log.info("agent count after = " .. tostring(after))
end
```

---

#### `LORCASolver:setAgent`

Inserts or updates an ORCA avoidance agent under a stable caller-provided key.

```lua
LORCASolver:setAgent(key, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | number | Stable agent key, such as a unit ID. |
| `opts` | table | Agent state with `x`, `y`, `radius`, and `max_speed`, plus optional velocity fields. |

**Example**

```lua
do

    local orca = lurek.pathfind.newORCASolver(2.0)
    orca:setAgent(101, {
        x = 10.0,
        y = 20.0,
        radius = 0.5,
        max_speed = 3.0,
        vx = 0.25,
        vy = 0.0,
        preferred_vx = 1.0,
        preferred_vy = 0.0,
    })
    orca:compute({ dt = 0.016 })
    local vx, vy = orca:getSafeVelocity(101)
    lurek.log.info("stable agent velocity = " .. vx .. ", " .. vy)
end
```

---

#### `LORCASolver:setCellSize`

Sets the spatial-hash cell size used when grouping ORCA agents.

```lua
LORCASolver:setCellSize(size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `size` | number | Spatial-hash cell size in world units. |

**Example**

```lua
do

    local orca = lurek.pathfind.newORCASolver(1.5)
    orca:setCellSize(6.0)
    orca:setAgent(11, { x = 0.0, y = 0.0, radius = 0.5, max_speed = 3.0 })
    orca:setAgent(12, { x = 8.0, y = 0.0, radius = 0.5, max_speed = 3.0 })
    orca:compute(0.016)
    local stats = orca:getStats()
    lurek.log.info("spatial cells = " .. tostring(stats.spatialCells))
end
```

---

#### `LORCASolver:setMaxNeighbors`

Sets the maximum retained neighbor count used during one ORCA solve step.

```lua
LORCASolver:setMaxNeighbors(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | number | Neighbor cap; values below `1` clamp to `1`. |

**Example**

```lua
do

    local orca = lurek.pathfind.newORCASolver(1.5)
    orca:setMaxNeighbors(1)
    orca:setCellSize(4.0)
    orca:setNeighborRadius(12.0)
    for i = 1, 4 do
        orca:setAgent(i, { x = i * 2.0, y = 0.0, radius = 0.5, max_speed = 3.0, preferred_vx = 1.0, preferred_vy = 0.0 })
    end
    orca:compute(0.016)
    local stats = orca:getStats()
    lurek.log.info("max neighbors used = " .. tostring(stats.maxNeighborsUsed))
end
```

---

#### `LORCASolver:setNeighborRadius`

Sets an explicit neighbor-query radius in world units; zero restores dynamic per-agent radius.

```lua
LORCASolver:setNeighborRadius(radius)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `radius` | number | Neighbor-query radius in world units. |

**Example**

```lua
do

    local orca = lurek.pathfind.newORCASolver(1.5)
    orca:setCellSize(4.0)
    orca:setNeighborRadius(3.0)
    orca:setAgent(1, { x = 0.0, y = 0.0, radius = 0.5, max_speed = 3.0 })
    orca:setAgent(2, { x = 20.0, y = 0.0, radius = 0.5, max_speed = 3.0 })
    orca:compute(0.016)
    local stats = orca:getStats()
    lurek.log.info("neighbors used = " .. tostring(stats.neighborsUsed))
end
```

---

#### `LORCASolver:setPosition`

Sets the position for an ORCA agent addressed by zero-based index or stable key.

```lua
LORCASolver:setPosition(idx, x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Zero-based ORCA agent index or stable caller-provided key. |
| `x` | number | New X position. |
| `y` | number | New Y position. |

**Example**

```lua
do

    local orca = lurek.pathfind.newORCASolver(2.0)
    orca:addAgent(0, 0, 0.5, 5.0)
    orca:setPosition(0, 5.0, 3.0)
    local count = orca:agentCount()
    local type_name = orca:type()
    lurek.log.info("position updated for agent 0")
end
```

---

#### `LORCASolver:setPreferredVelocity`

Sets the preferred velocity for an ORCA agent addressed by zero-based index or stable key.

```lua
LORCASolver:setPreferredVelocity(idx, pvx, pvy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Zero-based ORCA agent index or stable caller-provided key. |
| `pvx` | number | Preferred X velocity. |
| `pvy` | number | Preferred Y velocity. |

**Example**

```lua
do

    local orca = lurek.pathfind.newORCASolver(2.0)
    orca:addAgent(0, 0, 0.5, 5.0)
    orca:setPreferredVelocity(0, 2.0, 1.0)
    local count = orca:agentCount()
    local type_name = orca:type()
    lurek.log.info("preferred velocity set for agent 0")
end
```

---

#### `LORCASolver:setVelocity`

Sets the current velocity for an ORCA agent addressed by zero-based index or stable key.

```lua
LORCASolver:setVelocity(idx, vx, vy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Zero-based ORCA agent index or stable caller-provided key. |
| `vx` | number | Current X velocity. |
| `vy` | number | Current Y velocity. |

**Example**

```lua
do

    local orca = lurek.pathfind.newORCASolver(2.0)
    orca:setAgent(77, { x = 0.0, y = 0.0, radius = 0.5, max_speed = 5.0 })
    orca:setVelocity(77, 1.5, -0.5)
    orca:compute(0.016)
    local vx, vy = orca:getSafeVelocity(77)
    lurek.log.info("current velocity updated = " .. vx .. ", " .. vy)
end
```

---

#### `LORCASolver:type`

Returns the Lua-visible type name for this ORCA solver handle.

```lua
LORCASolver:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LORCASolver](#lorcasolver)`. |

**Example**

```lua
do

    local orca = lurek.pathfind.newORCASolver(1.0)
    orca:addAgent(0, 0, 0.5, 2.0)
    local count = orca:agentCount()
    lurek.log.info("type = " .. orca:type())
  lurek.log.info("matches = " .. tostring(orca:typeOf("LORCASolver")))
end
```

---

#### `LORCASolver:typeOf`

Returns whether this ORCA solver handle matches a supported type name.

```lua
LORCASolver:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LORCASolver](#lorcasolver)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do

    local orca = lurek.pathfind.newORCASolver(1.0)
    orca:addAgent(0, 0, 0.5, 2.0)
    local count = orca:agentCount()
    local type_name = orca:type()
    lurek.log.info("is LORCASolver = " .. tostring(orca:typeOf("LORCASolver")))
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
        lurek.log.info("steps = " .. #path)
        lurek.log.info("first = " .. path[1].x .. "," .. path[1].y)
        lurek.log.info("last = " .. path[#path].x .. "," .. path[#path].y)
    else
        lurek.log.info("steps = 0")
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
        lurek.log.info("points = " .. #path)
        lurek.log.info("first = " .. path[1].x .. "," .. path[1].y)
        lurek.log.info("last = " .. path[#path].x .. "," .. path[#path].y)
    else
        lurek.log.info("points = 0")
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

    lurek.log.info("cell size = " .. cell_size)
    lurek.log.info("path grid dims = " .. dims)
    lurek.log.info("center open = " .. tostring(center_open))
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

    lurek.log.info("bridge tile cost = " .. bridge_cost)
    lurek.log.info("lane tile cost = " .. lane_cost)
    lurek.log.info("default tile cost = " .. base_cost)
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

    lurek.log.info("height = " .. height)
    lurek.log.info("width = " .. width)
    lurek.log.info("center cost = " .. center_cost)
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

    lurek.log.info("width = " .. width)
    lurek.log.info("height = " .. height)
    lurek.log.info("cell size = " .. cell_size)
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

    lurek.log.info("tower cell walkable = " .. tostring(tower_cell))
    lurek.log.info("stairs cell walkable = " .. tostring(stairs_cell))
    lurek.log.info("courtyard cell walkable = " .. tostring(courtyard_cell))
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

    lurek.log.info("mud tile cost = " .. mud_cost)
    lurek.log.info("road tile cost = " .. road_cost)
    lurek.log.info("plain tile cost = " .. plain_cost)
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

    lurek.log.info("main gate open = " .. tostring(blocked_gate))
    lurek.log.info("flank route open = " .. tostring(flank_route))
    lurek.log.info("guard post open = " .. tostring(guard_post))
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

    lurek.log.info("path grid type = " .. type_name)
    lurek.log.info("training grid = " .. width .. "x" .. height)
    lurek.log.info("center walkable = " .. tostring(blocked_center))
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

    lurek.log.info("matches LPathGrid = " .. tostring(is_path_grid))
    lurek.log.info("matches LObject = " .. tostring(is_object))
    lurek.log.info("matches LNavGrid = " .. tostring(is_nav_grid))
end
```

---

## LSteeringManager

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LSteeringManager:addArrive`

Adds an arrive behavior that slows the agent as it approaches a target point.

```lua
LSteeringManager:addArrive(tx, ty, slowing, weight)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tx` | number | Target X position in world units. |
| `ty` | number | Target Y position in world units. |
| `slowing?` | number | Radius used to reduce speed near the target; defaults to 50.0. |
| `weight?` | number | Behavior weight applied during steering combination; defaults to 1.0. |

**Example**

```lua
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:addArrive(300, 300, 50, 1.0)
  local fx, fy = steer:calculate(280, 290, 30, 10, 100, 200, 1 / 60)
  lurek.log.info("LSteeringManager:addArrive: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end
```

---

#### `LSteeringManager:addCustomBehavior`

Adds a custom steering behavior backed by a Lua callback.

```lua
LSteeringManager:addCustomBehavior(func, weight)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `func` | function | Function called as `(agent, dt)` that returns an X and Y steering force. |
| `weight?` | number | Custom behavior weight applied to returned forces; defaults to 1.0. |

**Example**

```lua
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:addCustomBehavior(function(agent, dt) return 50, 0 end, 0.8)
  local count = steer:getBehaviorCount()
  lurek.log.info("LSteeringManager:addCustomBehavior: behaviors=" .. tostring(count))
end
```

---

#### `LSteeringManager:addEvade`

Adds an evade behavior that moves away from another named agent when a threat name is supplied.

```lua
LSteeringManager:addEvade(threat_name, weight)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `threat_name?` | string | Optional name of the agent to evade. |
| `weight?` | number | Behavior weight applied during steering combination; defaults to 1.0. |

**Example**

```lua
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:setEntity("enemy_agent", 140, 120, -10, 0)
  steer:addEvade("enemy_agent", 1.0)
  local fx, fy = steer:calculate(100, 120, 0, 0, 120, 250, 1 / 60)
  lurek.log.info("LSteeringManager:addEvade: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end
```

---

#### `LSteeringManager:addFlee`

Adds a flee behavior that pushes the agent away from a target point inside a panic distance.

```lua
LSteeringManager:addFlee(tx, ty, panic_dist, weight)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tx` | number | Threat X position in world units. |
| `ty` | number | Threat Y position in world units. |
| `panic_dist?` | number | Distance inside which fleeing is active; defaults to 200.0. |
| `weight?` | number | Behavior weight applied during steering combination; defaults to 1.0. |

**Example**

```lua
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:addFlee(200, 200, 1.0)
  local fx, fy = steer:calculate(210, 195, 0, 0, 100, 200, 1 / 60)
  lurek.log.info("LSteeringManager:addFlee: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end
```

---

#### `LSteeringManager:addFlock`

Adds a flocking behavior with separation, alignment, and cohesion weights.

```lua
LSteeringManager:addFlock(neighbor_radius, sep_w, align_w, coh_w, weight)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `neighbor_radius?` | number | Radius used to find flock neighbors; defaults to 100.0. |
| `sep_w?` | number | Separation force weight; defaults to 1.5. |
| `align_w?` | number | Alignment force weight; defaults to 1.0. |
| `coh_w?` | number | Cohesion force weight; defaults to 1.0. |
| `weight?` | number | Behavior weight applied during steering combination; defaults to 1.0. |

**Example**

```lua
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:setEntity("ally_1", 110, 100, 20, 0)
  steer:setEntity("ally_2", 95, 140, 10, 5)
  steer:addFlock(80, 1.5, 1.0, 1.0, 1.0)
  local fx, fy = steer:calculate(100, 120, 0, 0, 120, 250, 1 / 60)
  lurek.log.info("LSteeringManager:addFlock: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end
```

---

#### `LSteeringManager:addPursue`

Adds a pursue behavior that chases another named agent when a target name is supplied.

```lua
LSteeringManager:addPursue(target_name, weight)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target_name?` | string | Optional name of the agent to pursue. |
| `weight?` | number | Behavior weight applied during steering combination; defaults to 1.0. |

**Example**

```lua
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:setEntity("target_agent", 220, 120, 20, 0)
  steer:addPursue("target_agent", 1.0)
  local fx, fy = steer:calculate(100, 120, 0, 0, 120, 250, 1 / 60)
  lurek.log.info("LSteeringManager:addPursue: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end
```

---

#### `LSteeringManager:addSeek`

Adds a seek behavior that pulls the agent toward a target point.

```lua
LSteeringManager:addSeek(tx, ty, weight)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tx` | number | Target X position in world units. |
| `ty` | number | Target Y position in world units. |
| `weight?` | number | Behavior weight applied during steering combination; defaults to 1.0. |

**Example**

```lua
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:addSeek(400, 300, 1.0)
  local fx, fy = steer:calculate(50, 50, 0, 0, 100, 200, 1 / 60)
  lurek.log.info("LSteeringManager:addSeek: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end
```

---

#### `LSteeringManager:addWander`

Adds a wander behavior that produces jittered exploratory movement.

```lua
LSteeringManager:addWander(radius, dist, jitter, weight)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `radius?` | number | Wander circle radius; defaults to 20.0. |
| `dist?` | number | Wander circle distance in front of the agent; defaults to 40.0. |
| `jitter?` | number | Random displacement applied per update; defaults to 5.0. |
| `weight?` | number | Behavior weight applied during steering combination; defaults to 1.0. |

**Example**

```lua
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:addWander(25, 50, 8, 0.5)
  local fx, fy = steer:calculate(100, 100, 10, 0, 80, 150, 1 / 60)
  lurek.log.info("LSteeringManager:addWander: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end
```

---

#### `LSteeringManager:applyCustomSteering`

Runs enabled custom steering callbacks for an agent and returns the weighted combined force.

```lua
LSteeringManager:applyCustomSteering(agent, dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `agent` | [LBot](ai.md#lbot) | Bot handle passed through to every custom steering callback. |
| `dt` | number | Elapsed time in seconds passed to every custom steering callback. |

**Returns**

| Type | Description |
|------|-------------|
| number | Combined custom X and Y steering force. (value 1). |
| number | Combined custom X and Y steering force. (value 2). |

**Example**

```lua
do

  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("pusher")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  npc:setPosition(100, 100)
  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:addCustomBehavior(function(agent, dt) return 25, -10 end, 1.0)
  local fx, fy = steer:applyCustomSteering(npc, 1 / 60)
  lurek.log.info("LSteeringManager:applyCustomSteering: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end
```

---

#### `LSteeringManager:calculate`

Calculates a steering force for the supplied agent movement state.

```lua
LSteeringManager:calculate(px, py, vx, vy, max_speed, max_force, dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `px` | number | Current agent X position. |
| `py` | number | Current agent Y position. |
| `vx` | number | Current agent X velocity. |
| `vy` | number | Current agent Y velocity. |
| `max_speed` | number | Maximum allowed speed used by steering constraints. |
| `max_force` | number | Maximum allowed steering force. |
| `dt` | number | Elapsed time in seconds for this steering step. |

**Returns**

| Type | Description |
|------|-------------|
| number | X and Y steering force. (value 1). |
| number | X and Y steering force. (value 2). |

**Example**

```lua
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:addSeek(500, 300, 1.0)
  steer:addWander(15, 30, 4, 0.3)
  local fx, fy = steer:calculate(100, 100, 20, 5, 150, 250, 1 / 60)
  lurek.log.info("LSteeringManager:calculate: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end
```

---

#### `LSteeringManager:clearEntities`

Clears all steering-context entities.

```lua
LSteeringManager:clearEntities()
```

**Example**

```lua
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:setEntity("a", 0, 0)
  steer:setEntity("b", 16, 0)
  steer:clearEntities()
  lurek.log.info("LSteeringManager:clearEntities: count=" .. tostring(steer:entityCount()))
end
```

---

#### `LSteeringManager:clearPath`

Clears the active waypoint path behavior.

```lua
LSteeringManager:clearPath()
```

**Example**

```lua
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:setPath({ { x = 10, y = 10 }, { x = 100, y = 100 } }, 8.0, 1.0)
  steer:clearPath()
  local has = steer:hasPath()
  lurek.log.info("LSteeringManager:clearPath: hasPath=" .. tostring(has))
end
```

---

#### `LSteeringManager:enableSpatialHash`

Enables or disables spatial hash acceleration for neighbor queries.

```lua
LSteeringManager:enableSpatialHash(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | boolean | True to use spatial hashing, false to use direct scans. |

**Example**

```lua
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:enableSpatialHash(true)
  steer:setSpatialHashCellSize(48)
  lurek.log.info("LSteeringManager:enableSpatialHash: done")
end
```

---

#### `LSteeringManager:entityCount`

Returns the number of steering-context entities.

```lua
LSteeringManager:entityCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Entity count. |

**Example**

```lua
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:setEntity("a", 0, 0)
  lurek.log.info("LSteeringManager:entityCount: " .. tostring(steer:entityCount()))
end
```

---

#### `LSteeringManager:getBehaviorCount`

Returns the number of steering behaviors configured on this manager.

```lua
LSteeringManager:getBehaviorCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current steering behavior count. |

**Example**

```lua
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:addSeek(100, 100, 1.0)
  steer:addWander(10, 20, 3, 0.5)
  local count = steer:getBehaviorCount()
  lurek.log.info("LSteeringManager:getBehaviorCount: " .. tostring(count))
end
```

---

#### `LSteeringManager:getCombineMode`

Returns the current steering force combination mode.

```lua
LSteeringManager:getCombineMode()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Combine mode name. |

**Example**

```lua
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:setCombineMode("truncated")
  local mode = steer:getCombineMode()
  lurek.log.info("LSteeringManager:getCombineMode: " .. mode)
  lurek.log.info("LSteeringManager:getCombineMode: type=" .. steer:type())
end
```

---

#### `LSteeringManager:getLastDiagnostic`

Returns the most recent steering validation or runtime diagnostic.

```lua
LSteeringManager:getLastDiagnostic()
```

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | Diagnostic string, or nil when no diagnostic has been recorded. |

**Example**

```lua
do

  local steer = lurek.pathfind.newSteeringManager()
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("steer_probe")
  steer:addCustomBehavior(function() error("custom steering failure") end, 1.0)
  steer:applyCustomSteering(agent, 1 / 60)
  lurek.log.info("LSteeringManager:getLastDiagnostic: " .. tostring(steer:getLastDiagnostic()))
end
```

---

#### `LSteeringManager:getLastSteering`

Returns the last steering force calculated by this manager.

```lua
LSteeringManager:getLastSteering()
```

**Returns**

| Type | Description |
|------|-------------|
| number | X and Y force values from the previous calculation. (value 1). |
| number | X and Y force values from the previous calculation. (value 2). |

**Example**

```lua
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:addSeek(200, 200, 1.0)
  steer:calculate(50, 50, 0, 0, 100, 200, 1 / 60)
  local lx, ly = steer:getLastSteering()
  lurek.log.info("LSteeringManager:getLastSteering: " .. tostring(lx) .. "," .. tostring(ly))
end
```

---

#### `LSteeringManager:getPathProgress`

Returns the current one-based waypoint index and total waypoint count.

```lua
LSteeringManager:getPathProgress()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current waypoint index and total waypoint count. (value 1). |
| number | Current waypoint index and total waypoint count. (value 2). |

**Example**

```lua
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:setPath({ { x = 0, y = 0 }, { x = 100, y = 50 }, { x = 200, y = 100 } }, 10.0, 1.0)
  local idx, total = steer:getPathProgress()
  lurek.log.info("LSteeringManager:getPathProgress: " .. tostring(idx) .. "/" .. tostring(total))
end
```

---

#### `LSteeringManager:hasPath`

Returns whether this manager currently has an active waypoint path.

```lua
LSteeringManager:hasPath()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a path is configured and not complete. |

**Example**

```lua
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  local before = steer:hasPath()
  steer:setPath({ { x = 0, y = 0 }, { x = 50, y = 50 } }, 5.0, 1.0)
  local after = steer:hasPath()
  lurek.log.info("LSteeringManager:hasPath: before=" .. tostring(before) .. " after=" .. tostring(after))
end
```

---

#### `LSteeringManager:removeEntity`

Removes one named steering-context entity.

```lua
LSteeringManager:removeEntity(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Entity name to remove. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when an entity was removed. |

**Example**

```lua
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:setEntity("scout", 100, 80, 12, 0)
  local removed = steer:removeEntity("scout")
  lurek.log.info("LSteeringManager:removeEntity: removed=" .. tostring(removed))
end
```

---

#### `LSteeringManager:setCombineMode`

Sets how steering behavior forces are combined.

```lua
LSteeringManager:setCombineMode(mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | string | Combine mode string parsed by the steering manager. |

**Example**

```lua
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:setCombineMode("priority")
  local mode = steer:getCombineMode()
  lurek.log.info("LSteeringManager:setCombineMode: " .. mode)
end
```

---

#### `LSteeringManager:setEntity`

Sets or replaces one named steering-context entity.

```lua
LSteeringManager:setEntity(name, x, y, vx, vy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Entity name used by pursue, evade, and flock behaviors. |
| `x` | number | Current entity X position. |
| `y` | number | Current entity Y position. |
| `vx?` | number | Current entity X velocity; defaults to 0. |
| `vy?` | number | Current entity Y velocity; defaults to 0. |

**Example**

```lua
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:setEntity("scout", 100, 80, 12, 0)
  lurek.log.info("LSteeringManager:setEntity: count=" .. tostring(steer:entityCount()))
end
```

---

#### `LSteeringManager:setPath`

Sets a waypoint path behavior from an array of `{x, y}` tables.

```lua
LSteeringManager:setPath(waypoints, reach_radius, weight)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `waypoints` | table | Array of waypoint tables, each containing numeric `x` and `y` fields. |
| `reach_radius?` | number | Distance at which a waypoint is considered reached; defaults to 12.0. |
| `weight?` | number | Path following behavior weight; defaults to 1.0. |

**Example**

```lua
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  local waypoints = {
    { x = 50, y = 50 },
    { x = 200, y = 80 },
    { x = 350, y = 200 },
    { x = 400, y = 400 },
  }
  steer:setPath(waypoints, 16.0, 1.0)
  local has = steer:hasPath()
  lurek.log.info("LSteeringManager:setPath: hasPath=" .. tostring(has))
end
```

---

#### `LSteeringManager:setSpatialHashCellSize`

Sets the cell size used by the steering manager spatial hash.

```lua
LSteeringManager:setSpatialHashCellSize(size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `size` | number | Spatial hash cell size in world units. |

**Example**

```lua
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  steer:setSpatialHashCellSize(32)
  lurek.log.info("LSteeringManager:setSpatialHashCellSize: done")
end
```

---

#### `LSteeringManager:type`

Returns the Lua-visible type name for this steering manager handle.

```lua
LSteeringManager:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LSteeringManager](#lsteeringmanager)`. |

**Example**

```lua
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  local t = steer:type()
  lurek.log.info("LSteeringManager:type: " .. t)
  lurek.log.info("LSteeringManager:type: matches=" .. tostring(steer:typeOf("LSteeringManager")))
end
```

---

#### `LSteeringManager:typeOf`

Returns whether this steering manager handle matches a supported type name.

```lua
LSteeringManager:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `SteeringManager` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do

  local steer = lurek.pathfind.newSteeringManager()
  steer:addSeek(64, 64, 1.0)
  local behavior_count = steer:getBehaviorCount()
  local is_steer = steer:typeOf("LSteeringManager")
  local is_other = steer:typeOf("LBot")
  lurek.log.info("LSteeringManager:typeOf: LSteeringManager=" .. tostring(is_steer) .. " LBot=" .. tostring(is_other))
end
```

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

    lurek.log.info("cache_before_clear = " .. pf:getCacheSize())
    pf:clearCache()
    lurek.log.info("cache_after_clear = " .. pf:getCacheSize())
end
```

---

#### `LUnitPathfinder:clearReservations`

Clears all caller-owned reserved cells.

```lua
LUnitPathfinder:clearReservations()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Number of reservations cleared. |

**Example**

```lua
do
  local grid = lurek.pathfind.newNavGrid(8, 8)
  local pathfinder = lurek.pathfind.newPathfinder(grid)
  pathfinder:reserveCells({ { x = 1, y = 1 }, { x = 2, y = 1 } })
  local cleared = pathfinder:clearReservations()
  lurek.log.info("cleared reservations=" .. tostring(cleared))
end
```

---

#### `LUnitPathfinder:clearSharedGoalCache`

Clears all cached shared-goal fields on this object.

```lua
LUnitPathfinder:clearSharedGoalCache()
```

**Example**

```lua
do

    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    pf:findPathsToGoal({ { x = 1, y = 1 } }, 20, 20)
    local before = pf:getSharedGoalCacheSize()
    pf:clearSharedGoalCache()

    lurek.log.info("shared cache before = " .. tostring(before))
    lurek.log.info("shared cache after = " .. tostring(pf:getSharedGoalCacheSize()))
end
```

---

#### `LUnitPathfinder:findAttackMovePaths`

Finds one path per start toward a shared attack-move goal.

```lua
LUnitPathfinder:findAttackMovePaths(starts, gx, gy, unit_size, max_steps)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `starts` | table | Array of `{x, y}` start tables. |
| `gx` | number | One-based goal column. |
| `gy` | number | One-based goal row. |
| `unit_size?` | number | Unit footprint in cells (default 1). |
| `max_steps?` | number | Maximum downhill steps to follow for each start. |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of path arrays; unreachable entries are nil. |

**Example**

```lua
do
  local grid = lurek.pathfind.newNavGrid(8, 8)
  local pathfinder = lurek.pathfind.newPathfinder(grid)
  local starts = { { x = 1, y = 1 }, { x = 2, y = 1 } }
  local paths = pathfinder:findAttackMovePaths(starts, 8, 8, 1, 16)
  lurek.log.info("attack-move paths=" .. tostring(#paths))
end
```

---

#### `LUnitPathfinder:findFormationPaths`

Finds one path per start toward formation slots around a shared goal.

```lua
LUnitPathfinder:findFormationPaths(starts, gx, gy, unit_size, spacing)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `starts` | table | Array of `{x, y}` start tables. |
| `gx` | number | One-based formation center column. |
| `gy` | number | One-based formation center row. |
| `unit_size?` | number | Unit footprint in cells (default 1). |
| `spacing?` | number | Slot spacing in cells (default 1). |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of path arrays; unreachable entries are nil. |

**Example**

```lua
do
  local grid = lurek.pathfind.newNavGrid(8, 8)
  local pathfinder = lurek.pathfind.newPathfinder(grid)
  local starts = { { x = 1, y = 1 }, { x = 2, y = 1 } }
  local paths = pathfinder:findFormationPaths(starts, 8, 8, 1, 1)
  lurek.log.info("formation paths=" .. tostring(#paths))
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

    lurek.log.info("nearest = " .. nx .. "," .. ny)
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

    lurek.log.info("points = " .. #path)
    lurek.log.info("reached = " .. tostring(reached))
    lurek.log.info("last = " .. path[#path].x .. "," .. path[#path].y)
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
        lurek.log.info("steps = " .. #path)
        lurek.log.info("first = " .. path[1].x .. "," .. path[1].y)
        lurek.log.info("last = " .. path[#path].x .. "," .. path[#path].y)
    else
        lurek.log.info("steps = 0")
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
        lurek.log.info("points = " .. #path)
        lurek.log.info("complete = " .. tostring(complete))
        lurek.log.info("last = " .. path[#path].x .. "," .. path[#path].y)
    else
        lurek.log.info("complete = " .. tostring(complete))
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
        lurek.log.info("points = " .. #path)
        lurek.log.info("first = " .. path[1].x .. "," .. path[1].y)
        lurek.log.info("last = " .. path[#path].x .. "," .. path[#path].y)
    else
        lurek.log.info("points = 0")
    end
end
```

---

#### `LUnitPathfinder:findPathsToGoal`

Finds routes from many one-based start cells to one goal cell using one shared-goal field.

```lua
LUnitPathfinder:findPathsToGoal(starts, gx, gy, unit_size, max_steps)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `starts` | table | Array of `{x, y}` start tables. |
| `gx` | number | One-based goal column. |
| `gy` | number | One-based goal row. |
| `unit_size?` | number | Unit footprint in cells (default 1). |
| `max_steps?` | number | Maximum downhill steps to follow for each start; 0 or nil uses a grid-sized default. |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of path arrays; unreachable entries are nil. |

**Example**

```lua
do

    local nav = lurek.pathfind.newNavGrid(30, 30)

    nav:fill(1)
    nav:setBlocked(15, 10, true)
    nav:setBlocked(15, 11, true)
    nav:setBlocked(15, 12, true)

    local pf = lurek.pathfind.newPathfinder(nav)
    local routes = pf:findPathsToGoal({
        { x = 1, y = 12 },
        { x = 2, y = 14 },
        { x = 5, y = 20 },
    }, 30, 12)

    lurek.log.info("shared routes = " .. tostring(#routes))
    lurek.log.info("first nodes = " .. tostring(routes[1] and #routes[1] or 0))
end
```

---

#### `LUnitPathfinder:findPathsToGoalFor`

Finds routes from many one-based start cells to one goal cell using one named-footprint shared-goal field.

```lua
LUnitPathfinder:findPathsToGoalFor(name, starts, gx, gy, max_steps)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Stable footprint name defined on the backing navigation grid. |
| `starts` | table | Array of `{x, y}` start tables. |
| `gx` | number | One-based goal column. |
| `gy` | number | One-based goal row. |
| `max_steps?` | number | Maximum downhill steps to follow for each start; 0 or nil uses a grid-sized default. |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of path arrays; unreachable entries are nil. |

**Example**

```lua
do

    local nav = lurek.pathfind.newNavGrid(30, 30)

    nav:fill(1)
    nav:defineFootprint("tank", { w = 2, h = 2 })
    nav:setBlocked(2, 2, true)

    local pf = lurek.pathfind.newPathfinder(nav)
    local routes = pf:findPathsToGoalFor("tank", {
        { x = 1, y = 1 },
        { x = 5, y = 5 },
        { x = 8, y = 8 },
    }, 25, 25)

    lurek.log.info("blocked start nil = " .. tostring(routes[1] == nil))
    lurek.log.info("second nodes = " .. tostring(routes[2] and #routes[2] or 0))
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

    lurek.log.info("cache_size = " .. pf:getCacheSize())
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
        lurek.log.info("cost = " .. pf:getPathCost(path))
        lurek.log.info("length = " .. pf:getPathLength(path))
    else
        lurek.log.info("cost = 0")
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
        lurek.log.info("length = " .. pf:getPathLength(path))
        lurek.log.info("cost = " .. pf:getPathCost(path))
    else
        lurek.log.info("length = 0")
    end
end
```

---

#### `LUnitPathfinder:getSharedFlowField`

Returns a cached shared-goal flow field handle for one target cell and unit footprint size.

```lua
LUnitPathfinder:getSharedFlowField(gx, gy, unit_size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `gx` | number | One-based goal column. |
| `gy` | number | One-based goal row. |
| `unit_size?` | number | Unit footprint in cells (default 1). |

**Returns**

| Type | Description |
|------|-------------|
| [LFlowField](#lflowfield) | Flow field handle backed by the pathfinder's shared-goal cache. |

**Example**

```lua
do

    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    local flow = pf:getSharedFlowField(20, 20)
    local path = flow:pathFrom(1, 1)

    lurek.log.info("shared flow targets = " .. tostring(#flow:getTargets()))
    lurek.log.info("path last = " .. path[#path].x .. "," .. path[#path].y)
end
```

---

#### `LUnitPathfinder:getSharedFlowFieldFor`

Returns a cached shared-goal flow field handle for one target cell and one named footprint.

```lua
LUnitPathfinder:getSharedFlowFieldFor(name, gx, gy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Stable footprint name defined on the backing navigation grid. |
| `gx` | number | One-based goal column. |
| `gy` | number | One-based goal row. |

**Returns**

| Type | Description |
|------|-------------|
| [LFlowField](#lflowfield) | Flow field handle backed by the pathfinder's shared-goal cache. |

**Example**

```lua
do

    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)
    nav:defineFootprint("tank", { w = 2, h = 2 })
    nav:setBlocked(2, 2, true)

    local pf = lurek.pathfind.newPathfinder(nav)
    local flow = pf:getSharedFlowFieldFor("tank", 18, 18)

    lurek.log.info("tank start cost = " .. tostring(flow:getCostToTarget(1, 1)))
    lurek.log.info("open lane cost = " .. tostring(flow:getCostToTarget(5, 5)))
end
```

---

#### `LUnitPathfinder:getSharedFlowFieldMulti`

Returns a cached shared-goal flow field handle for many target cells and one unit footprint size.

```lua
LUnitPathfinder:getSharedFlowFieldMulti(targets, unit_size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `targets` | table | Array of `{x, y}` goal tables. |
| `unit_size?` | number | Unit footprint in cells (default 1). |

**Returns**

| Type | Description |
|------|-------------|
| [LFlowField](#lflowfield) | Flow field handle backed by the pathfinder's shared-goal cache. |

**Example**

```lua
do

    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    local flow = pf:getSharedFlowFieldMulti({
        { x = 18, y = 18 },
        { x = 20, y = 20 },
    })

    lurek.log.info("shared multi targets = " .. tostring(#flow:getTargets()))
    lurek.log.info("cache size = " .. tostring(pf:getSharedGoalCacheSize()))
end
```

---

#### `LUnitPathfinder:getSharedFlowFieldMultiFor`

Returns a cached shared-goal flow field handle for many target cells and one named footprint.

```lua
LUnitPathfinder:getSharedFlowFieldMultiFor(name, targets)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Stable footprint name defined on the backing navigation grid. |
| `targets` | table | Array of `{x, y}` goal tables. |

**Returns**

| Type | Description |
|------|-------------|
| [LFlowField](#lflowfield) | Flow field handle backed by the pathfinder's shared-goal cache. |

**Example**

```lua
do

    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)
    nav:defineFootprint("tank", { w = 2, h = 2 })

    local pf = lurek.pathfind.newPathfinder(nav)
    local flow = pf:getSharedFlowFieldMultiFor("tank", {
        { x = 16, y = 16 },
        { x = 18, y = 18 },
    })

    lurek.log.info("footprint targets = " .. tostring(#flow:getTargets()))
    lurek.log.info("builds = " .. tostring(flow:getBuildCount()))
end
```

---

#### `LUnitPathfinder:getSharedGoalCacheSize`

Returns the current shared-goal field cache entry count.

```lua
LUnitPathfinder:getSharedGoalCacheSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Shared-goal cache size. |

**Example**

```lua
do

    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    pf:findPathsToGoal({ { x = 1, y = 1 }, { x = 3, y = 3 } }, 20, 20)

    lurek.log.info("shared cache size = " .. tostring(pf:getSharedGoalCacheSize()))
    lurek.log.info("path cache size = " .. tostring(pf:getCacheSize()))
end
```

---

#### `LUnitPathfinder:getSharedGoalCacheStats`

Returns shared-goal flow-field cache counters for debugging and performance inspection.

```lua
LUnitPathfinder:getSharedGoalCacheStats()
```

**Returns**

| Type | Description |
|------|-------------|
| LUnitPathfinderGetSharedGoalCacheStatsResult | Cache statistics table. |

**Example**

```lua
do

    local nav = lurek.pathfind.newNavGrid(20, 20)

    nav:fill(1)

    local pf = lurek.pathfind.newPathfinder(nav)
    pf:getSharedFlowField(20, 20)
    pf:getSharedFlowField(20, 20)
    local stats = pf:getSharedGoalCacheStats()

    lurek.log.info("shared hits = " .. tostring(stats.hits))
    lurek.log.info("shared misses = " .. tostring(stats.misses))
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

    lurek.log.info("corner estimate = " .. map_corner)
    lurek.log.info("same cell estimate = " .. same_cell)
    lurek.log.info("front line estimate = " .. front_line)
end
```

---

#### `LUnitPathfinder:isCacheEnabled`

Returns whether the pathfinder's internal caches are enabled.

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

    lurek.log.info("enabled_before_disable = " .. tostring(enabled))
    lurek.log.info("enabled_after_disable = " .. tostring(pf:isCacheEnabled()))
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

    lurek.log.info("reachable_left = " .. tostring(pf:isReachable(1, 1, 9, 9)))
    lurek.log.info("reachable_right = " .. tostring(pf:isReachable(1, 1, 20, 20)))
end
```

---

#### `LUnitPathfinder:reserveCells`

Records caller-owned cell reservations for batch planning.

```lua
LUnitPathfinder:reserveCells(cells)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cells` | table | Array of `{x, y}` one-based cells. |

**Returns**

| Type | Description |
|------|-------------|
| number | Total reserved cell count after the update. |

**Example**

```lua
do
  local grid = lurek.pathfind.newNavGrid(8, 8)
  local pathfinder = lurek.pathfind.newPathfinder(grid)
  local starts = { { x = 1, y = 1 }, { x = 2, y = 1 } }
  local reserved = pathfinder:reserveCells(starts)
  lurek.log.info("reserved cells=" .. tostring(reserved))
end
```

---

#### `LUnitPathfinder:setCacheEnabled`

Enables or disables the pathfinder's internal route and shared-goal caches on this object.

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

    lurek.log.info("enabled = " .. tostring(pf:isCacheEnabled()))
    lurek.log.info("cache_size = " .. pf:getCacheSize())
    pf:clearCache()
    lurek.log.info("cache_after_clear = " .. pf:getCacheSize())
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

    lurek.log.info("cache_size = " .. pf:getCacheSize())
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

    lurek.log.info("pathfinder type = " .. type_name)
    lurek.log.info("route nodes = " .. tostring(path and #path or 0))
    lurek.log.info("cache enabled = " .. tostring(cache_enabled))
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

    lurek.log.info("matches LUnitPathfinder = " .. tostring(is_pathfinder))
    lurek.log.info("matches LObject = " .. tostring(is_object))
    lurek.log.info("matches LNavGrid = " .. tostring(is_nav_grid))
end
```

---
