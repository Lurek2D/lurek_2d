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

This module represents the directed logistics and transport network subsystem, providing tools to build, analyze, and simulate complex graph networks. The graph container stores nodes, connections, and individual payloads, managing entity lifecycles to ensure consistency across connections. This architecture allows developers to design logistics networks, supply grids, or economic pipelines directly using structured network nodes and connection endpoints.

At the network junctions, nodes are configured with item capacities, inventory records, and queue rules. Nodes support advanced push and pull mechanics to guide item transfers automatically. They also manage item conversion recipes, consuming specific input items and generating transformed outputs after defined process intervals. When capacity limits are reached, customizable overflow policies decide how excess arrivals are handled at the node boundaries.

Connections between nodes represent weighted transit paths that carry payloads over defined intervals. Connection edges enforce throughput limits, traversal cooldown timers, and directional rules. They also support item-type filtering to restrict which items may traverse specific routes. During simulation updates, items move along these edges, and their velocities are modified dynamically by edge attributes like distance and custom speed scales.

To coordinate movement, the system includes algorithms for pathfinding and logistics balancing. A priority-based routing engine computes the cheapest pathways across connections, respecting current traversal constraints and filters. Additionally, a supply-demand manager matches prioritized needs at consumer nodes with resources available at producer sites, scheduling pathfinding routes to transport materials through the network.

The simulation core updates all transit queues, item lifetimes, and node conversion timers dynamically. It resolves waiting items, handles backpressure, and removes expired items automatically. The graph structure supports diagnostic algorithms that perform structural health checks, including cycle detection and topological sorting. Additionally, a circular layout generator produces debug diagrams to help visualize the network state.

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
