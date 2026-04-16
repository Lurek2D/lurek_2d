# IDEA.md — `graph` module

> Migrated from `ideas/features/graph.md` and `ideas/performance/16-graph-flow-simulation.md`.
> Status checked against `src/graph/` and `src/lua_api/graph_api.rs`.
> Lua namespace: `lurek.graph`. The graph is item-flow-oriented, not a pure algorithm graph.

---

## Features

### 🤔 CONSIDER — Algorithm Graph vs Flow Graph Naming
**Source**: features/graph.md — Structural Issues

`lurek.graph` is described in docs as an item-flow-simulation module (conveyor-belt style).
But it also exposes pure graph-theory algorithms (Dijkstra, topoSort). This dual identity
is confusing. Consider splitting flow simulation into `lurek.flow` and exposing algorithms
under `lurek.graph.algo.*`, or clearly documenting that algorithms are utilities on top of
the flow graph. Requires Lua-Designer decision.

---

## Performance
