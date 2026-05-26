# layout — Module Specification

| Field        | Value                                                    |
| ------------ | -------------------------------------------------------- |
| **Module**   | `layout`                                                 |
| **Tier**     | Foundations                                              |
| **Path**     | `src/layout/`                                            |
| **API**      | `lurek.layout.*`                                         |
| **Depends**  | (none — leaf module)                                     |
| **Used by**  | pipeline, dialog, graph, UI trees, skill trees, editors  |

## Purpose

Generic graph/tree/DAG layout algorithms for positioning nodes in 2D space.
Pure algorithmic module with no engine runtime dependencies.

## Files

| File           | Content                                                              |
| -------------- | -------------------------------------------------------------------- |
| `mod.rs`       | Module declarations and re-exports                                   |
| `types.rs`     | Core types: `NodeId`, `LayoutNode`, `LayoutEdge`, `LayoutConfig`, `LayoutResult` |
| `tree.rs`      | Reingold-Tilford tree layout algorithm                               |
| `dag.rs`       | Sugiyama layered DAG layout (layer assignment + crossing reduction)   |
| `force.rs`     | Force-directed spring layout (Fruchterman-Reingold)                  |
| `grid_align.rs`| Snap-to-grid and center-in-area post-processing                      |

## Public Types

- `NodeId = usize` — Index-based node identifier.
- `LayoutNode` — Node with id, x, y, width, height, label.
- `LayoutEdge` — Directed edge with from, to, weight.
- `LayoutConfig` — Spacing parameters (h_spacing, v_spacing, margin).
- `ForceConfig` — Force-directed parameters (iterations, repulsion, attraction, cooling, area).
- `LayoutResult` — Positioned nodes with bounding dimensions.

## Algorithms

### Reingold-Tilford Tree (`tree.rs`)
- Post-order traversal assigns x to leaves sequentially.
- Internal nodes are centered over their children.
- Depth determines y position.
- Produces minimal-width layouts with symmetric subtrees.

### Sugiyama Layered DAG (`dag.rs`)
- Layer assignment via longest path from sources (topological order).
- Crossing reduction via single-pass barycenter heuristic.
- Coordinate assignment with uniform spacing per layer.
- Handles multi-root DAGs (multiple sources placed at layer 0).

### Fruchterman-Reingold Force-Directed (`force.rs`)
- All-pairs repulsion (O(n²) per iteration).
- Edge-spring attraction proportional to distance and weight.
- Simulated annealing via temperature cooling.
- Bounded within configured area.

### Post-Processing (`grid_align.rs`)
- `snap_to_grid` — Round positions to nearest grid multiple.
- `center_in_area` — Translate layout to center within a given rectangle.

## Lua API Surface

| Function                         | Description                                     |
| -------------------------------- | ----------------------------------------------- |
| `lurek.layout.tree(nodes, children, root, config?)` | Reingold-Tilford tree layout    |
| `lurek.layout.dag(nodes, edges, config?)`            | Sugiyama layered DAG layout     |
| `lurek.layout.force(nodes, edges, config?)`          | Force-directed spring layout    |
| `lurek.layout.snapToGrid(result, gridSize)`          | Snap positions to grid          |
| `lurek.layout.centerInArea(result, width, height)`   | Center layout in area           |

### Node table format
```lua
{ id = 1, width = 60, height = 30, label = "Node A" }
```

### Edge table format
```lua
{ from = 1, to = 2, weight = 1.0 }
```

### Config table format
```lua
{ hSpacing = 50, vSpacing = 80, margin = 20 }
```

### Force config table format
```lua
{ iterations = 100, repulsion = 10000, attraction = 0.01, cooling = 0.95, areaWidth = 800, areaHeight = 600 }
```

### Result table format
```lua
{ nodes = { {id=1, x=..., y=..., width=..., height=..., label=...}, ... }, width = ..., height = ... }
```

## Cross-References

- `src/pipeline/` — uses DAG layout for stage visualization
- `src/dialog/` — uses tree layout for conversation trees
- `src/graph/` — uses force-directed layout for flow graphs
- `library/` — skill trees, node editors consume layout results
- `content/examples/layout.lua` — usage demonstration
