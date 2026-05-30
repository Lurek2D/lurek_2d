# flownet

## General Info

- Module group: `Foundations`
- Source path: `src/flownet/`
- Binding: `src/lua_api/flownet_api.rs`
- Namespace: `lurek.graph`
- Lua API surface: `1` functions, `7` types, `130` methods
- Rust test path(s): tests/rust/unit/flownet_tests.rs plus inline flownet module tests
- Lua test path(s): tests/lua/unit/test_flownet.lua and related flownet stress and golden suites

## Summary

Moving beyond simple data-structure graphs, this module simulates complex logistics and transportation systems where typed items physically travel through interconnected nodes. The central `Graph` structure utilizes highly efficient `HashMap` storage and maintains persistent adjacency indexes, enabling O(1) neighbor lookups and robust graph traversal.

The simulation is deeply systemic. Items (`GraphItem`) accumulate in node inventories and traverse directed edges (`Edge`). These edges are not merely logical links; they enforce strict constraints including transit capacities, cooldown timers, and item-type filters. Nodes (`Node`) possess configurable item capacities, explicit queueing systems, and distinct flow modes (passive, push, or pull). Furthermore, nodes can execute `ConversionRule`s—acting as economic factories that consume specific inputs to produce new typed outputs. To manage bottlenecks, nodes implement defined `OverflowPolicy` behaviors, dictating whether excess items are rejected, queued, or destroyed.

The module runs an intricate simulation pipeline (`step(dt)`) that processes item decay, executes conversion rules, matches supply against demand declarations, and progresses items along edges. To support this, the module includes a comprehensive suite of graph algorithms: A* and Dijkstra shortest-path searches, reachability flood-fills, connected component discovery, cycle detection, topological sorting, Kruskal's minimum spanning tree, and graph coloring. Pathfinding inherently respects edge constraints and item-type filters. For performance scalability, the simulation tick can be executed in parallel using multi-threading. The engine exposes this entire logistical framework, alongside event-driven callbacks for state transitions, to Lua scripts via the `lurek.graph.*` namespace.

## Files

### [algorithms.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/flownet/algorithms.rs)

- Provides graph algorithm utilities for connectivity, ordering, coloring, and optimization analyses.
- Implements traversal and cycle checks that reveal structural health of directed flow networks.
- Supplies deterministic topological and spanning computations for planning and diagnostics workflows.
- Includes coloring and bipartite checks for partitioning and compatibility reasoning.
- Offers heuristic shortest-path search to support efficient route estimation over node geometry.
- Operates directly on shared graph adjacency state to avoid duplicate model translations.
- Delivers the analytical toolkit used to inspect and tune flownet topology behavior.

### [core.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/flownet/core.rs)

- Provides the central flownet graph container that owns nodes, edges, items, and adjacency indexes.
- Manages full CRUD lifecycles with cascading cleanup to keep topology and item state coherent.
- Tracks outgoing and incoming connectivity for efficient route and neighborhood queries.
- Coordinates item creation, placement, transit, and removal under node and edge constraints.
- Supports subgraph extraction and aggregate statistics for analysis and tooling pipelines.
- Exposes directional query helpers that simplify traversal and simulation planning logic.
- Includes debug-friendly serialization and preview output for inspection and persistence workflows.
- Keeps id allocation and storage ownership centralized for deterministic graph mutation behavior.
- Integrates overflow-aware placement paths that align with node policy semantics.
- Delivers the authoritative data backbone consumed by algorithms, pathfinding, and simulation updates.

### [edge.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/flownet/edge.rs)

- Provides flownet edge state that links nodes with transit limits, timing, and routing metadata.
- Encodes capacity, throughput, cooldown, and filtering constraints that govern movement eligibility.
- Supports directional and bidirectional semantics with pathfinding weight and speed modifiers.
- Delivers the per-connection transport contract used by simulation and routing systems.
- Keeps edge behavior explicit so tuning and diagnostics remain consistent across network updates.

### [item.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/flownet/item.rs)

- Provides flownet item records that carry typed payload identity through nodes and transit edges.
- Tracks location state as node-bound, in-transit, or unplaced to drive simulation decisions.
- Stores decay lifetime, priority, and alive status for scheduling and cleanup behavior.
- Delivers the movable unit model consumed by demand, conversion, and transport mechanics.
- Keeps item lifecycle state centralized for deterministic flow simulation and event emission.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/flownet/mod.rs)

- Provides the high-level flownet module boundary for graph flow modeling, simulation, and rendering support.
- Connects nodes, edges, items, demand logic, routing, and update events into one runtime network surface.
- Delivers a complete directed-flow toolkit for gameplay systems that model transport and transformation.

### [node.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/flownet/node.rs)

- Provides flownet node modeling with capacity, inventory, policy, and flow-direction configuration.
- Defines overflow behavior modes that govern how nodes handle arrivals beyond available space.
- Encodes push and pull flow semantics used by simulation to move items across the graph.
- Stores conversion, supply, and demand records for transformation and economic-style mechanics.
- Exposes node-level queue and tag operations needed for runtime orchestration.
- Parses textual policy and flow values into typed enums for resilient script integration.
- Delivers the per-node behavior contract that anchors transport and conversion decisions.

### [pathfinding.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/flownet/pathfinding.rs)

- Provides flownet pathfinding operations that compute cheapest routes across weighted directed edges.
- Respects edge activity, cooldown, and type filters so route output matches simulation constraints.
- Supports distance and reachability queries for planning and demand-matching workflows.
- Builds predecessor maps and reconstructs ordered node and edge paths for execution.
- Uses priority-queue traversal for efficient shortest-path expansion under dynamic graph state.
- Integrates neighbor discovery across directional and bidirectional connectivity patterns.
- Delivers the routing layer used by supply movement and logistics decision systems.

### [render.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/flownet/render.rs)

- Provides debug render-command generation that visualizes flownet topology as node-edge diagrams.
- Lays out nodes on a circular frame and draws links with deterministic mapping.
- Colors nodes by type to expose structural roles at a glance during inspection.
- Delivers a self-contained preview command stream consumable by the renderer.

### [simulation.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/flownet/simulation.rs)

- Provides the flownet simulation engine that advances transport, decay, conversion, and queue behavior per tick.
- Processes item lifetimes and removes expired entities while preserving graph consistency guarantees.
- Moves transit items along edges and resolves arrivals using each node's overflow policy.
- Executes push and pull flow mechanics with rate-limited logic tied to node configuration.
- Applies conversion rules that consume inputs and emit transformed output items at nodes.
- Handles queued backpressure by promoting waiting items when capacity becomes available.
- Emits structured simulation events for observable state transitions consumed by scripts.
- Supports optional parallel stepping paths for larger network workloads under feature gating.
- Coordinates sub-steps in deterministic order to keep outcomes reproducible across runs.
- Delivers the runtime progression core for logistics-style gameplay simulation.

### [supply_demand.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/flownet/supply_demand.rs)

- Provides demand-processing logic that matches prioritized needs against available network supply.
- Uses pathfinding to route produced items from supplier nodes toward consumer destinations.
- Tracks fulfillment progress and decrements source supply quantities during transfer.
- Emits simulation events that expose depletion and fulfillment transitions to observers.
- Delivers the balancing layer that drives directed resource flow through the graph.

### [types.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/flownet/types.rs)

- Provides shared flownet identifier wrappers used to type node, edge, and item handles.
- Encapsulates raw numeric ids in lightweight newtypes for clearer API contracts.
- Supports conversion and display behavior needed across simulation and tooling call paths.
- Delivers the common identity foundation for graph storage and cross-module interoperability.
- Keeps handle semantics consistent so id usage remains safe and readable throughout flownet code.
