# Layout

## Purpose

Computes size-aware graph layouts with post-processing helpers for grid snapping and viewport centering.

## When To Use

- It supports different layout strategies for different shapes, so dependency graphs, trees, and more organic maps can use an algorithm that matches the structure.
- Tree and DAG layouts account for real node widths and heights, so larger labels or panels do not collapse into adjacent siblings or ranks.
- Circular and radial layouts compute ring radii from node dimensions instead of using a naive count-only radius.

## Minimal Example

Example block: `lurek.layout.tree`

```lua
do
    local nodes = {
        { id = 1, width = 110, height = 34, label = "Root" },
        { id = 2, width = 70, height = 28, label = "HUD" },
        { id = 3, width = 130, height = 30, label = "Simulation" },
        { id = 4, width = 84, height = 28, label = "Tools" },
    }
    local children = {
        [1] = { 2, 3, 4 },
    }
    local result = lurek.layout.tree(nodes, children, 1, {
        hSpacing = 28,
        vSpacing = 48,
        margin = 20,
    })
    example_print_log("tree nodes = " .. #result.nodes)
    example_print_log("tree size = " .. result.width .. "x" .. result.height)
    example_print_log("root center x = " .. (result.nodes[1].x + result.nodes[1].width * 0.5))
end
```

## Common Patterns

- Start with `lurek.layout.centerInArea` when exploring this module.
- Start with `lurek.layout.circular` when exploring this module.
- Start with `lurek.layout.dag` when exploring this module.
- Start with `lurek.layout.force` when exploring this module.
- Start with `lurek.layout.grid` when exploring this module.

## API Reference

- This page is the generated API reference for this module.

## Summary

- The `layout` module is the automatic placement layer for users who need graph-like structures to become readable 2D diagrams without hand-positioning every node.
- It supports different layout strategies for different shapes, so dependency graphs, trees, and more organic maps can use an algorithm that matches the structure.
- Tree and DAG layouts account for real node widths and heights, so larger labels or panels do not collapse into adjacent siblings or ranks.
- Circular and radial layouts compute ring radii from node dimensions instead of using a naive count-only radius.
- Grid layout scores candidate column counts and uses variable row/column sizes for dense or disconnected inputs.
- Spiral, force, and stress layouts include rectangle-aware overlap reduction for larger unordered graphs.
- This is useful when a graph changes and still needs readable coordinates without manual upkeep.
- Read it as the module that turns abstract structure into stable coordinates.

This module is mostly self-contained inside the `Edge/Integration` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Functions

### `lurek.layout.centerInArea`

Centers the layout within a given area.

```lua
lurek.layout.centerInArea(result, width, height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `result` | table | A layout result table with nodes array. |
| `width` | number | Target area width. |
| `height` | number | Target area height. |

**Returns**

| Type | Description |
|------|-------------|
| table | New layout result centered in the area. |

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
    example_print_log("centered nodes = " .. #centered.nodes)
    example_print_log("node 1 x = " .. centered.nodes[1].x)
    example_print_log("layout height = " .. centered.height)
end
```

---

### `lurek.layout.circular`

Lays out nodes around a chord-safe circle for cycle-heavy graphs and overviews.

```lua
lurek.layout.circular(nodes, config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `nodes` | table | Array of node tables with id, width, height, label fields. |
| `config?` | table | Optional config with hSpacing, vSpacing, margin. |

**Returns**

| Type | Description |
|------|-------------|
| table | Layout result with nodes array, width, height. |

**Example**

```lua
do
    local nodes = {
        { id = 1, width = 64, height = 28, label = "Auth" },
        { id = 2, width = 72, height = 28, label = "API" },
        { id = 3, width = 62, height = 28, label = "UI" },
        { id = 4, width = 76, height = 28, label = "Cache" },
        { id = 5, width = 74, height = 28, label = "Queue" },
        { id = 6, width = 68, height = 28, label = "Mail" },
        { id = 7, width = 70, height = 28, label = "Billing" },
        { id = 8, width = 60, height = 28, label = "DB" },
    }
    local result = lurek.layout.circular(nodes, { hSpacing = 28, vSpacing = 28, margin = 12 })
    example_print_log("circular nodes = " .. #result.nodes)
    example_print_log("circular size = " .. result.width .. "x" .. result.height)
    example_print_log("first node = " .. result.nodes[1].x .. "," .. result.nodes[1].y)
end
```

---

### `lurek.layout.dag`

Lays out a size-aware DAG with centered layers, stable barycenter ordering, and height-aware ranks.

```lua
lurek.layout.dag(nodes, edges, config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `nodes` | table | Array of node tables with id, width, height, label fields. |
| `edges` | table | Array of edge tables with from, to, weight fields. |
| `config?` | table | Optional config with hSpacing, vSpacing, margin. |

**Returns**

| Type | Description |
|------|-------------|
| table | Layout result with nodes array, width, height. |

**Example**

```lua
do
    local nodes = {
        { id = 1, width = 86, height = 34, label = "Source" },
        { id = 2, width = 96, height = 48, label = "Build" },
        { id = 3, width = 76, height = 30, label = "Lint" },
        { id = 4, width = 94, height = 36, label = "Package" },
        { id = 5, width = 82, height = 30, label = "Ship" },
    }
    local edges = {
        { from = 1, to = 2, weight = 1.0 },
        { from = 1, to = 3, weight = 1.0 },
        { from = 2, to = 4, weight = 1.0 },
        { from = 3, to = 4, weight = 1.0 },
        { from = 4, to = 5, weight = 1.0 },
    }
    local result = lurek.layout.dag(nodes, edges, {
        hSpacing = 36,
        vSpacing = 42,
        margin = 24,
    })
    example_print_log("dag nodes = " .. #result.nodes)
    example_print_log("dag size = " .. result.width .. "x" .. result.height)
    example_print_log("node 2 y = " .. result.nodes[2].y)
end
```

---

### `lurek.layout.force`

Lays out a graph using bounded size-aware force simulation with final overlap cleanup.

```lua
lurek.layout.force(nodes, edges, config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `nodes` | table | Array of node tables with id, width, height, label fields. |
| `edges` | table | Array of edge tables with from, to, weight fields. |
| `config?` | table | Optional config with iterations, repulsion, attraction, cooling, areaWidth, areaHeight. |

**Returns**

| Type | Description |
|------|-------------|
| table | Layout result with nodes array, width, height. |

**Example**

```lua
do
    local nodes = {
        { id = 1, width = 62, height = 28, label = "Core" },
        { id = 2, width = 78, height = 30, label = "AI" },
        { id = 3, width = 68, height = 28, label = "Save" },
        { id = 4, width = 74, height = 30, label = "UI" },
        { id = 5, width = 66, height = 28, label = "Map" },
        { id = 6, width = 84, height = 32, label = "Path" },
    }
    local edges = {
        { from = 1, to = 2, weight = 1.0 },
        { from = 2, to = 3, weight = 1.0 },
        { from = 1, to = 4, weight = 0.8 },
        { from = 4, to = 5, weight = 0.8 },
        { from = 5, to = 6, weight = 1.2 },
        { from = 2, to = 6, weight = 0.7 },
    }
    local result = lurek.layout.force(nodes, edges, {
        iterations = 80,
        repulsion = 9000,
        attraction = 0.018,
        cooling = 0.92,
        areaWidth = 560,
        areaHeight = 360,
    })
    example_print_log("force nodes = " .. #result.nodes)
    example_print_log("force size = " .. result.width .. "x" .. result.height)
    example_print_log("node 1 pos = " .. result.nodes[1].x .. "," .. result.nodes[1].y)
end
```

---

### `lurek.layout.grid`

Lays out nodes in a compact variable-size grid for dense or disconnected graphs.

```lua
lurek.layout.grid(nodes, config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `nodes` | table | Array of node tables with id, width, height, label fields. |
| `config?` | table | Optional config with hSpacing, vSpacing, margin. |

**Returns**

| Type | Description |
|------|-------------|
| table | Layout result with nodes array, width, height. |

**Example**

```lua
do
    local nodes = {
        { id = 1, width = 58, height = 24, label = "HP" },
        { id = 2, width = 90, height = 30, label = "Inventory" },
        { id = 3, width = 64, height = 26, label = "Map" },
        { id = 4, width = 82, height = 28, label = "Journal" },
        { id = 5, width = 70, height = 24, label = "Skills" },
        { id = 6, width = 96, height = 32, label = "Equipment" },
        { id = 7, width = 62, height = 24, label = "Quest" },
    }
    local result = lurek.layout.grid(nodes, { hSpacing = 14, vSpacing = 18, margin = 10 })
    example_print_log("grid nodes = " .. #result.nodes)
    example_print_log("grid first x = " .. result.nodes[1].x)
    example_print_log("grid size = " .. result.width .. "x" .. result.height)
end
```

---

### `lurek.layout.radial`

Lays out a graph on size-aware breadth-first concentric rings from a root node.

```lua
lurek.layout.radial(nodes, edges, root, config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `nodes` | table | Array of node tables with id, width, height, label fields. |
| `edges` | table | Array of edge tables with from, to, weight fields. |
| `root` | number | ID of the radial center node. |
| `config` | table|nil | Optional config with hSpacing, vSpacing, margin. |

**Returns**

| Type | Description |
|------|-------------|
| table | Layout result with nodes array, width, height. |

**Example**

```lua
do
    local nodes = {
        { id = 1, width = 70, height = 30, label = "Gateway" },
        { id = 2, width = 64, height = 28, label = "Auth" },
        { id = 3, width = 64, height = 28, label = "API" },
        { id = 4, width = 64, height = 28, label = "CDN" },
        { id = 5, width = 72, height = 28, label = "Users" },
        { id = 6, width = 76, height = 28, label = "Orders" },
        { id = 7, width = 70, height = 28, label = "Media" },
    }
    local edges = {
        { from = 1, to = 2 },
        { from = 1, to = 3 },
        { from = 1, to = 4 },
        { from = 2, to = 5 },
        { from = 3, to = 6 },
        { from = 4, to = 7 },
    }
    local result = lurek.layout.radial(nodes, edges, 1, { hSpacing = 24, vSpacing = 52, margin = 16 })
    example_print_log("radial nodes = " .. #result.nodes)
    example_print_log("radial center id = " .. result.nodes[1].id)
    example_print_log("radial size = " .. result.width .. "x" .. result.height)
end
```

---

### `lurek.layout.snapToGrid`

Snaps all node positions to the nearest grid point.

```lua
lurek.layout.snapToGrid(result, gridSize)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `result` | table | A layout result table with nodes array. |
| `gridSize` | number | Grid cell size in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| table | New layout result with snapped positions. |

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
    example_print_log("snapped nodes = " .. #snapped.nodes)
    example_print_log("node 1 = " .. snapped.nodes[1].x .. "," .. snapped.nodes[1].y)
    example_print_log("node 2 = " .. snapped.nodes[2].x .. "," .. snapped.nodes[2].y)
end
```

---

### `lurek.layout.spiral`

Lays out nodes on an expanding overlap-checked spiral for fast large-graph refreshes.

```lua
lurek.layout.spiral(nodes, config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `nodes` | table | Array of node tables with id, width, height, label fields. |
| `config?` | table | Optional config with hSpacing, vSpacing, margin. |

**Returns**

| Type | Description |
|------|-------------|
| table | Layout result with nodes array, width, height. |

**Example**

```lua
do
    local nodes = {
        { id = 1, width = 58, height = 26, label = "S1" },
        { id = 2, width = 78, height = 28, label = "S2" },
        { id = 3, width = 64, height = 26, label = "S3" },
        { id = 4, width = 92, height = 30, label = "S4" },
        { id = 5, width = 70, height = 26, label = "S5" },
        { id = 6, width = 80, height = 28, label = "S6" },
        { id = 7, width = 60, height = 26, label = "S7" },
        { id = 8, width = 88, height = 30, label = "S8" },
        { id = 9, width = 72, height = 28, label = "S9" },
        { id = 10, width = 66, height = 26, label = "S10" },
    }
    local result = lurek.layout.spiral(nodes, { hSpacing = 12, vSpacing = 12, margin = 10 })
    example_print_log("spiral nodes = " .. #result.nodes)
    example_print_log("spiral last id = " .. result.nodes[#result.nodes].id)
    example_print_log("spiral size = " .. result.width .. "x" .. result.height)
end
```

---

### `lurek.layout.stress`

Lays out a graph by preserving graph-distance relationships with bounded relaxation and cleanup.

```lua
lurek.layout.stress(nodes, edges, config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `nodes` | table | Array of node tables with id, width, height, label fields. |
| `edges` | table | Array of edge tables with from, to, weight fields. |
| `config?` | table | Optional config with iterations, edgeLength, step. |

**Returns**

| Type | Description |
|------|-------------|
| table | Layout result with nodes array, width, height. |

**Example**

```lua
do
    local nodes = {
        { id = 1, width = 58, height = 26, label = "A1" },
        { id = 2, width = 58, height = 26, label = "A2" },
        { id = 3, width = 58, height = 26, label = "A3" },
        { id = 4, width = 58, height = 26, label = "A4" },
        { id = 5, width = 64, height = 28, label = "B1" },
        { id = 6, width = 64, height = 28, label = "B2" },
        { id = 7, width = 64, height = 28, label = "B3" },
        { id = 8, width = 64, height = 28, label = "B4" },
    }
    local edges = {
        { from = 1, to = 2 },
        { from = 2, to = 3 },
        { from = 3, to = 4 },
        { from = 1, to = 5 },
        { from = 5, to = 6 },
        { from = 6, to = 7 },
        { from = 7, to = 8 },
        { from = 4, to = 8 },
    }
    local result = lurek.layout.stress(nodes, edges, { iterations = 24, edgeLength = 66, step = 0.06 })
    example_print_log("stress nodes = " .. #result.nodes)
    example_print_log("stress width = " .. result.width)
    example_print_log("stress height = " .. result.height)
end
```

---

### `lurek.layout.tree`

Lays out a size-aware tree, centering parents over child spans and keeping disconnected nodes.

```lua
lurek.layout.tree(nodes, children, root, config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `nodes` | table | Array of node tables with id, width, height, label fields. |
| `children` | table | Map of parent node ID to array of child node IDs. |
| `root` | number | ID of the root node. |
| `config` | table|nil | Optional config with hSpacing, vSpacing, margin. |

**Returns**

| Type | Description |
|------|-------------|
| table | Layout result with nodes array, width, height. |

**Example**

```lua
do
    local nodes = {
        { id = 1, width = 110, height = 34, label = "Root" },
        { id = 2, width = 70, height = 28, label = "HUD" },
        { id = 3, width = 130, height = 30, label = "Simulation" },
        { id = 4, width = 84, height = 28, label = "Tools" },
    }
    local children = {
        [1] = { 2, 3, 4 },
    }
    local result = lurek.layout.tree(nodes, children, 1, {
        hSpacing = 28,
        vSpacing = 48,
        margin = 20,
    })
    example_print_log("tree nodes = " .. #result.nodes)
    example_print_log("tree size = " .. result.width .. "x" .. result.height)
    example_print_log("root center x = " .. (result.nodes[1].x + result.nodes[1].width * 0.5))
end
```

---

## Module Fields

*No module-level fields documented.*

## Enums

*No module-specific enums documented.*

## Types

*No Lua userdata types detected for this module.*
