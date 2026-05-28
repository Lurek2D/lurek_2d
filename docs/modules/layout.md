# Layout

- The `layout` module is a pure algorithmic component providing tree, DAG, and force-directed graph node-positioning algorithms for pipeline visualization, skill trees, dialog trees, and node editors.

The `layout` module offers four complementary 2D graph layout algorithms with no engine runtime dependencies, making it usable from any scripting context. `layout_tree` implements the Reingold-Tilford algorithm for compact hierarchical tree layout, packing sibling subtrees as tightly as possible with configurable horizontal and vertical node separation. Both top-down and left-to-right orientations are supported via `TreeConfig`. `layout_dag` applies the multi-phase Sugiyama layered layout to directed acyclic graphs — cycle removal, layer assignment, crossing minimization, and coordinate assignment — producing readable hierarchical diagrams for tech trees, build-dependency graphs, and quest dependency views.

For general undirected graphs where hierarchy is not meaningful, `layout_force` runs the Fruchterman-Reingold spring simulation. Nodes repel each other while edges attract; a cooling schedule reduces displacement each iteration until convergence. `ForceConfig` exposes temperature, cooling rate, repulsion constant, and maximum iterations. Seeding is deterministic given the same integer seed, producing reproducible node editor layouts.

All three algorithms return a `LayoutResult` mapping `NodeId` to `(f32, f32)` coordinates in logical pixels. Two post-processing utilities compose cleanly with any layout output: `snap_to_grid` rounds positions to a configurable cell size, and `center_in_area` translates the entire layout to fill a target viewport rectangle. The full algorithm suite is exposed via the `lurek.layout.*` Lua API, targeting pipeline visualization, dialog tree views, skill trees, and org charts.

## Functions

### `lurek.layout.centerInArea`

Centers the layout within a given area.

```lua
-- signature
lurek.layout.centerInArea(result, width, height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `result` | `table` | A layout result table with nodes array. |
| `width` | `number` | Target area width. |
| `height` | `number` | Target area height. |

**Returns**

| Type | Description |
|------|-------------|
| `table` | New layout result centered in the area. |

**Example**

```lua
do
    local result = {
        nodes = {
            { id = 1, x = 0, y = 0, width = 50, height = 30 },
            { id = 2, x = 60, y = 0, width = 40, height = 30 },
        },
    }
    local centered = lurek.layout.centerInArea(result, 400, 300)
    print("centered nodes = " .. #centered.nodes)
    print("node 1 x = " .. centered.nodes[1].x)
    print("layout height = " .. centered.height)
end
```

---

### `lurek.layout.dag`

Lays out a DAG using the Sugiyama layered algorithm.

```lua
-- signature
lurek.layout.dag(nodes, edges, config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `nodes` | `table` | Array of node tables with id, width, height, label fields. |
| `edges` | `table` | Array of edge tables with from, to, weight fields. |
| `config?` | `table` | Optional config with hSpacing, vSpacing, margin. |

**Returns**

| Type | Description |
|------|-------------|
| `table` | Layout result with nodes array, width, height. |

**Example**

```lua
do
    local nodes = {
        { id = 1, width = 60, height = 30, label = "Start" },
        { id = 2, width = 60, height = 30, label = "Build" },
        { id = 3, width = 60, height = 30, label = "Test" },
    }
    local edges = {
        { from = 1, to = 2, weight = 1.0 },
        { from = 1, to = 3, weight = 1.0 },
    }
    local result = lurek.layout.dag(nodes, edges, {
        hSpacing = 80,
        vSpacing = 100,
        margin = 24,
    })
    print("dag nodes = " .. #result.nodes)
    print("dag size = " .. result.width .. "x" .. result.height)
    print("node 2 y = " .. result.nodes[2].y)
end
```

---

### `lurek.layout.force`

Lays out a graph using force-directed Fruchterman-Reingold simulation.

```lua
-- signature
lurek.layout.force(nodes, edges, config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `nodes` | `table` | Array of node tables with id, width, height, label fields. |
| `edges` | `table` | Array of edge tables with from, to, weight fields. |
| `config?` | `table` | Optional config with iterations, repulsion, attraction, cooling, areaWidth, areaHeight. |

**Returns**

| Type | Description |
|------|-------------|
| `table` | Layout result with nodes array, width, height. |

**Example**

```lua
do
    local nodes = {
        { id = 1, width = 40, height = 24, label = "A" },
        { id = 2, width = 40, height = 24, label = "B" },
        { id = 3, width = 40, height = 24, label = "C" },
    }
    local edges = {
        { from = 1, to = 2, weight = 1.0 },
        { from = 2, to = 3, weight = 1.0 },
    }
    local result = lurek.layout.force(nodes, edges, {
        iterations = 40,
        repulsion = 6000,
        attraction = 0.02,
        cooling = 0.9,
        areaWidth = 400,
        areaHeight = 300,
    })
    print("force nodes = " .. #result.nodes)
    print("force size = " .. result.width .. "x" .. result.height)
    print("node 1 pos = " .. result.nodes[1].x .. "," .. result.nodes[1].y)
end
```

---

### `lurek.layout.snapToGrid`

Snaps all node positions to the nearest grid point.

```lua
-- signature
lurek.layout.snapToGrid(result, gridSize)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `result` | `table` | A layout result table with nodes array. |
| `gridSize` | `number` | Grid cell size in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| `table` | New layout result with snapped positions. |

**Example**

```lua
do
    local result = {
        nodes = {
            { id = 1, x = 13.5, y = 27.3, width = 40, height = 20 },
            { id = 2, x = 42.1, y = 11.9, width = 40, height = 20 },
        },
    }
    local snapped = lurek.layout.snapToGrid(result, 16)
    print("snapped nodes = " .. #snapped.nodes)
    print("node 1 = " .. snapped.nodes[1].x .. "," .. snapped.nodes[1].y)
    print("node 2 = " .. snapped.nodes[2].x .. "," .. snapped.nodes[2].y)
end
```

---

### `lurek.layout.tree`

Lays out a tree using the Reingold-Tilford algorithm.

```lua
-- signature
lurek.layout.tree(nodes, children, root, config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `nodes` | `table` | Array of node tables with id, width, height, label fields. |
| `children` | `table` | Map of parent node ID to array of child node IDs. |
| `root` | `number` | ID of the root node. |
| `config` | `table|nil` | Optional config with hSpacing, vSpacing, margin. |

**Returns**

| Type | Description |
|------|-------------|
| `table` | Layout result with nodes array, width, height. |

**Example**

```lua
do
    local nodes = {
        { id = 1, width = 60, height = 30, label = "Root" },
        { id = 2, width = 50, height = 24, label = "Left" },
        { id = 3, width = 50, height = 24, label = "Right" },
    }
    local children = {
        [1] = { 2, 3 },
    }
    local result = lurek.layout.tree(nodes, children, 1, {
        hSpacing = 70,
        vSpacing = 90,
        margin = 20,
    })
    print("tree nodes = " .. #result.nodes)
    print("tree size = " .. result.width .. "x" .. result.height)
    print("root x = " .. result.nodes[1].x)
end
```

---
