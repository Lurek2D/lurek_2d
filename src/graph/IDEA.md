# IDEA.md — `graph` module

> Migrated from `ideas/features/graph.md` and `ideas/performance/16-graph-flow-simulation.md`.
> Status checked against `src/graph/` and `src/lua_api/graph_api.rs`.
> Lua namespace: `lurek.graph`. The graph is item-flow-oriented, not a pure algorithm graph.

---

## Features

### ✅ DONE — Dijkstra Shortest Path
**Source**: features/graph.md — Feature Gaps #3

`shortestPath(from, to)` exposed in `graph_api.rs` (line ~1403). Uses edge weights.

---

### ✅ DONE — Cycle Detection
**Source**: features/graph.md — Feature Gaps #4

`hasCycle()` implemented in `graph_api.rs` (line ~1525). Returns `true` if a directed cycle
exists.

---

### ✅ DONE — Topological Sort
**Source**: features/graph.md — Feature Gaps #5

`topologicalSort()` implemented in `graph_api.rs` (line ~1533). Returns sorted Node handles
or `nil` if a cycle exists.

---

### ✅ DONE — Graph Coloring
**Source**: features/graph.md — Feature Gaps #7

`colorGraph()` and `getNodeColor()` implemented in `algorithms.rs` + `graph_api.rs`.
Returns a Lua table mapping node IDs to integer color indices (greedy BFS coloring,
automatically uses the minimum number of colors for the graph structure).
```lua
local colors = g:colorGraph()  -- {[node_id] = color_int, ...}
```

---

### ✅ DONE — Minimum Spanning Tree
**Source**: features/graph.md — Feature Gaps #6

`mst()` (Kruskal's algorithm) found in `graph_api.rs` (line ~1560). Returns a table of
edge IDs forming the MST.

---

### ✅ DONE — Bipartite Check
**Source**: features/graph.md — Feature Gaps #8

`isBipartite()` implemented in `algorithms.rs` + `graph_api.rs`.
Returns `true` if the graph has no odd-length cycles (2-colorable).
```lua
if g:isBipartite() then ... end
```

---

### 🤔 CONSIDER — Algorithm Graph vs Flow Graph Naming
**Source**: features/graph.md — Structural Issues

`lurek.graph` is described in docs as an item-flow-simulation module (conveyor-belt style).
But it also exposes pure graph-theory algorithms (Dijkstra, topoSort). This dual identity
is confusing. Consider splitting flow simulation into `lurek.flow` and exposing algorithms
under `lurek.graph.algo.*`, or clearly documenting that algorithms are utilities on top of
the flow graph. Requires Lua-Designer decision.

---

## Performance

### ❌ TODO — Parallel Flow Tick (rayon)
**Source**: performance/16-graph-flow-simulation.md

Each node's tick (evaluate conversion rules, move items) is independent of other nodes in
the same generation. Embarrassingly parallel with rayon. No parallelism found in
`src/graph/flow.rs`. Priority: **MEDIUM** for graphs with 1000+ nodes.
