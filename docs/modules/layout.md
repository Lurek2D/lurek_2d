# Layout

## Summary

- The layout module gives users automatic 2D node placement for graph-like and tree-like visuals.
- It supports layered DAG layout, recursive tree layout, and force layout for organic relation maps.
- Shared result formats make it easy to swap strategies without changing integration code.
- Grid snapping and centering helpers polish raw coordinates for editor and HUD presentation.
- The module is useful for tech trees, dialog graphs, dependency maps, and debug topology views.
- It replaces manual positioning with repeatable, scriptable layout computation.

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
    print("centered nodes = " .. #centered.nodes)
    print("node 1 x = " .. centered.nodes[1].x)
    print("layout height = " .. centered.height)
end
```

---

### `lurek.layout.dag`

Lays out a DAG using the Sugiyama layered algorithm.

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
    print("snapped nodes = " .. #snapped.nodes)
    print("node 1 = " .. snapped.nodes[1].x .. "," .. snapped.nodes[1].y)
    print("node 2 = " .. snapped.nodes[2].x .. "," .. snapped.nodes[2].y)
end
```

---

### `lurek.layout.tree`

Lays out a tree using the Reingold-Tilford algorithm.

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

## Module Fields

*No module-level fields documented.*

## Callbacks

*No callback parameters documented in this module.*

## Enums

*No module-specific enums documented.*

## Types

*No Lua userdata types detected for this module.*
