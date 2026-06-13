# flownet

## TL;DR

- Simulates directed logistics networks using node inventories, push-pull rates, and overflow policies.
- Integrates weighted transits, pathfinding, supply-demand balancing, and circular layouts.

## General Info

- Module group: `Foundations`
- Source path: `src/flownet/`
- Binding: `src/lua_api/flownet_api.rs`
- Namespace: `lurek.graph`
- Lua API surface: `1` functions, `7` types, `130` methods
- Rust test path(s): tests/rust/unit/flownet_tests.rs plus inline flownet module tests
- Lua test path(s): tests/lua/unit/test_flownet.lua and related flownet stress and golden suites

## Summary

- This module gives users a simulation-ready logistics graph for resource movement and transformation gameplay.
- You can model producers, consumers, processors, and transit routes as explicit network structures.
- Node capacities, queue behavior, and overflow policies control how congestion is handled.
- Push and pull mechanics support both source-driven and demand-driven transfer strategies.
- Edge constraints such as throughput, cooldown, direction, and filtering define realistic transport limits.
- Item lifecycles include transit, placement, decay, and cleanup behavior for long-running simulations.
- Conversion rules enable factory-style nodes that transform inputs into outputs over time.
- Pathfinding support computes practical routes under dynamic network constraints.
- Supply-demand balancing helps route available goods toward prioritized deficits.
- Simulation stepping advances movement, timers, conversion, and event emission deterministically.
- Batch and parallel update paths support larger graph workloads.
- Structural algorithms like cycle detection and topological ordering aid network health checks.
- Reachability, components, and graph-coloring helpers support analysis and tooling use cases.
- Debug render output helps users visualize topology quickly while tuning behavior.
- Event callbacks expose simulation transitions for UI and analytics integration.
- Subgraph extraction allows focused operations on selected regions of a large network.
- Bulk node and edge creation supports procedural generation workflows.
- The module is suitable for economy loops, factory systems, routing puzzles, and colony logistics.
- It combines planning, simulation, and diagnostics in one runtime surface.
- Users can iterate on network rules directly from scripts without rewriting engine internals.
- The practical value is controllable complexity for resource-flow mechanics.
- It also improves debuggability by making route and capacity behavior observable.
- Overall, this module provides a full graph logistics toolkit for systemic gameplay design.
- Teams get both expressive modeling and deterministic execution in a single API boundary.

This module primarily collaborates with `image`, `render`, `runtime`. Its responsibility should stay inside the `Foundations` group rather than absorb behavior owned by those neighbors.

## Imports

- `image`: Imports or references `image` from `src/image/`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### algorithms.rs

- Graph algorithm implementations for directed flow networks including connectivity analysis, cycle detection, topological sorting, and minimum spanning trees.
- Implements white-gray-black DFS cycle detection, Kruskal MST construction, greedy graph coloring, and connected component enumeration for structural analysis.
- Provides O(V+E) traversals and ordering computations used by planning systems, diagnostics workflows, and topology validation on large flownet models.
- Operates directly on shared graph adjacency state without duplicating node or edge data, ensuring efficient memory usage and performance.
- Enables inspection and tuning of flownet topology behavior through bipartite detection, reachability checks, and deterministic node ordering guarantees.
- Supports both directed and undirected graph semantics through flexible edge enumeration and neighbor iteration strategies.

### core.rs

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

### edge.rs

- Provides flownet edge state that links nodes with transit limits, timing, and routing metadata.
- Encodes capacity, throughput, cooldown, and filtering constraints that govern movement eligibility.
- Supports directional and bidirectional semantics with pathfinding weight and speed modifiers.
- Delivers the per-connection transport contract used by simulation and routing systems.
- Keeps edge behavior explicit so tuning and diagnostics remain consistent across network updates.

### item.rs

- Provides flownet item records that carry typed payload identity through nodes and transit edges.
- Tracks location state as node-bound, in-transit, or unplaced to drive simulation decisions.
- Stores decay lifetime, priority, and alive status for scheduling and cleanup behavior.
- Delivers the movable unit model consumed by demand, conversion, and transport mechanics.
- Keeps item lifecycle state centralized for deterministic flow simulation and event emission.

### mod.rs

- Provides the high-level flownet module boundary for graph flow modeling, simulation, and rendering support.
- Connects nodes, edges, items, demand logic, routing, and update events into one runtime network surface.
- Delivers a complete directed-flow toolkit for gameplay systems that model transport and transformation.

### node.rs

- Provides flownet node modeling with capacity, inventory, policy, and flow-direction configuration.
- Defines overflow behavior modes that govern how nodes handle arrivals beyond available space.
- Encodes push and pull flow semantics used by simulation to move items across the graph.
- Stores conversion, supply, and demand records for transformation and economic-style mechanics.
- Exposes node-level queue and tag operations needed for runtime orchestration.
- Parses textual policy and flow values into typed enums for resilient script integration.
- Delivers the per-node behavior contract that anchors transport and conversion decisions.

### pathfinding.rs

- Provides flownet pathfinding operations that compute cheapest routes across weighted directed edges.
- Respects edge activity, cooldown, and type filters so route output matches simulation constraints.
- Supports distance and reachability queries for planning and demand-matching workflows.
- Builds predecessor maps and reconstructs ordered node and edge paths for execution.
- Uses priority-queue traversal for efficient shortest-path expansion under dynamic graph state.
- Integrates neighbor discovery across directional and bidirectional connectivity patterns.
- Delivers the routing layer used by supply movement and logistics decision systems.

### render.rs

- Provides debug render-command generation that visualizes flownet topology as node-edge diagrams.
- Lays out nodes on a circular frame and draws links with deterministic mapping.
- Colors nodes by type to expose structural roles at a glance during inspection.
- Delivers a self-contained preview command stream consumable by the renderer.

### simulation.rs

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

### supply_demand.rs

- Provides demand-processing logic that matches prioritized needs against available network supply.
- Uses pathfinding to route produced items from supplier nodes toward consumer destinations.
- Tracks fulfillment progress and decrements source supply quantities during transfer.
- Emits simulation events that expose depletion and fulfillment transitions to observers.
- Delivers the balancing layer that drives directed resource flow through the graph.

### types.rs

- Provides shared flownet identifier wrappers used to type node, edge, and item handles.
- Encapsulates raw numeric ids in lightweight newtypes for clearer API contracts.
- Supports conversion and display behavior needed across simulation and tooling call paths.
- Delivers the common identity foundation for graph storage and cross-module interoperability.
- Keeps handle semantics consistent so id usage remains safe and readable throughout flownet code.



## Lua API Ref

### Functions

- `lurek.graph.newGraph() -> LGraph`: Creates an empty logistics graph with no nodes, edges, items, or callbacks.

### Callbacks

- `LGraph:on` param `func` (`function`): Lua callback invoked with event-specific handles and values.

### Enums

- No documented module-level enums/constants.

### Types

#### LGraph Type

- Lua-side graph handle storing graph state and registered event callbacks.

##### Fields

- No documented fields.

##### Methods

- `LGraph:addEdge(from_ud, to_ud, edge_type?) -> LGraphEdge`: Creates an edge between two nodes with an optional edge type.
- `LGraph:addEdgeUnchecked(from_ud, to_ud, edge_type?) -> LGraphEdge`: Adds an edge without validating endpoint nodes exist. Faster for batch construction.
- `LGraph:addItem(item_ud, node_ud) -> nil`: Places an item onto a destination node.
- `LGraph:addNode(node_type?, capacity?) -> LGraphNode`: Creates a node with optional type and capacity.
- `LGraph:astar(from_node, to_node) -> LGraphNode[]`: Runs A* pathfinding between two nodes.
- `LGraph:batchAddEdges(edges) -> integer[]`: Creates multiple edges from a table of {from_id, to_id} or {from_id, to_id, edge_type} entries.
- `LGraph:batchAddNodes(count, config?) -> integer[]`: Creates multiple nodes at once, returning their IDs as a table.
- `LGraph:batchStep(dt, iterations) -> nil`: Runs multiple simulation steps in sequence. More efficient than calling step() in a loop from Lua.
- `LGraph:colorGraph() -> table`: Computes graph coloring and returns color indices by node id.
- `LGraph:createItem(item_type?, decay_time?) -> LGraphItem`: Creates an unplaced graph item with optional type and decay time.
- `LGraph:findPath(from_ud, to_ud) -> table`: Finds a path between two graph nodes.
- `LGraph:findPathForItem(item_ud, from_ud, to_ud) -> table`: Finds a path for a specific item between two nodes while respecting item constraints.
- `LGraph:getComponents() -> LGraphNode[]`: Returns connected components as arrays of node handles.
- `LGraph:getDistance(from_ud, to_ud) -> number`: Returns graph distance between two nodes when reachable.
- `LGraph:getEdgeBetween(from_ud, to_ud) -> LGraphEdge`: Returns the edge connecting two nodes when one exists.
- `LGraph:getEdgeCount() -> integer`: Returns the number of edges in this graph.
- `LGraph:getEdges() -> LGraphEdge[]`: Returns all edges in this logistics graph.
- `LGraph:getItemCount() -> integer`: Returns the number of items in this graph.
- `LGraph:getItems() -> LGraphItem[]`: Returns all items in this logistics graph.
- `LGraph:getNeighbors(node_ud) -> LGraphNode[]`: Returns neighbor nodes connected to a node.
- `LGraph:getNodeCount() -> integer`: Returns the number of nodes in this graph.
- `LGraph:getNodes() -> LGraphNode[]`: Returns all nodes in this logistics graph.
- `LGraph:getReachable(from_ud, max_dist?) -> LGraphNode[]`: Returns nodes reachable from a start node within an optional maximum distance.
- `LGraph:getStats() -> table`: Returns graph counts and aggregate supply-demand statistics.
- `LGraph:hasCycle() -> boolean`: Returns whether this graph contains a cycle.
- `LGraph:hasEdge(edge_ud) -> boolean`: Returns whether an edge handle still exists in this graph.
- `LGraph:hasItem(item_ud) -> boolean`: Returns whether an item handle still exists in this graph.
- `LGraph:hasNode(node_ud) -> boolean`: Returns whether a node handle still exists in this graph.
- `LGraph:isBipartite() -> boolean`: Returns whether this graph is bipartite.
- `LGraph:mst() -> integer[]`: Computes a minimum spanning tree using Kruskal and returns edge ids.
- `LGraph:on(event_name, func) -> nil`: Registers a callback for a named graph event generated during simulation.
- `LGraph:processDemand() -> nil`: Processes graph supply and demand once and dispatches generated callbacks.
- `LGraph:removeEdge(edge_ud) -> boolean`: Removes an edge by handle on this object.
- `LGraph:removeItem(item_ud) -> boolean`: Removes an item from this logistics graph.
- `LGraph:removeNode(node_ud) -> boolean`: Removes a node and graph links associated with it.
- `LGraph:sendItem(item_ud, edge_ud) -> nil`: Starts moving an item along an edge.
- `LGraph:step() -> nil`: Runs one discrete graph simulation step and dispatches generated callbacks.
- `LGraph:subgraph(nodes) -> LGraph`: Creates a new graph containing a subset of nodes.
- `LGraph:tickParallel(dt) -> nil`: Advances graph simulation through the parallel update path and dispatches generated callbacks.
- `LGraph:topologicalSort() -> LGraphNode[]`: Returns nodes in topological order when the graph is acyclic.
- `LGraph:type() -> string`: Returns the Lua-visible type name for this graph handle.
- `LGraph:typeOf(name) -> boolean`: Returns whether this graph handle matches a supported type name.
- `LGraph:update(dt) -> nil`: Advances graph simulation by delta time and dispatches generated callbacks.

#### LGraphEdge Type

- Lua-side edge handle referencing one edge id inside a graph.

##### Fields

- No documented fields.

##### Methods

- `LGraphEdge:addAllowedType(t) -> nil`: Allows an item type to traverse this edge.
- `LGraphEdge:clearAllowedTypes() -> nil`: Clears this edge's item type allow-list.
- `LGraphEdge:getCapacity() -> integer`: Returns this edge's maximum concurrent item capacity.
- `LGraphEdge:getCooldown() -> number`: Returns this edge's cooldown timer value.
- `LGraphEdge:getFrom() -> LGraphNode`: Returns the source node for this edge.
- `LGraphEdge:getItemsInTransit() -> LGraphItem[]`: Returns graph items currently traveling along this edge.
- `LGraphEdge:getSpeedModifier() -> number`: Returns this edge's speed modifier.
- `LGraphEdge:getThroughput() -> number`: Returns this edge's throughput value.
- `LGraphEdge:getTo() -> LGraphNode`: Returns the destination node for this edge.
- `LGraphEdge:getTravelTime() -> number`: Returns the travel time for items moving across this edge.
- `LGraphEdge:getType() -> string`: Returns the edge type string used by routing and filters.
- `LGraphEdge:getWeight() -> number`: Returns the pathfinding weight for this edge.
- `LGraphEdge:isActive() -> boolean`: Returns whether this edge is active for routing and simulation.
- `LGraphEdge:isBidirectional() -> boolean`: Returns whether this edge allows travel in both directions.
- `LGraphEdge:isItemTypeAllowed(t) -> boolean`: Returns whether an item type may traverse this edge.
- `LGraphEdge:isOnCooldown() -> boolean`: Returns whether this edge is currently on cooldown.
- `LGraphEdge:removeAllowedType(t) -> boolean`: Removes an item type from this edge's allow-list.
- `LGraphEdge:setActive(a) -> nil`: Enables or disables this edge for routing and simulation.
- `LGraphEdge:setBidirectional(b) -> nil`: Sets whether this edge allows travel in both directions.
- `LGraphEdge:setCapacity(c) -> nil`: Sets this edge's maximum concurrent item capacity.
- `LGraphEdge:setCooldown(c) -> nil`: Sets this edge's cooldown timer value.
- `LGraphEdge:setSpeedModifier(m) -> nil`: Sets this edge's speed modifier value.
- `LGraphEdge:setThroughput(t) -> nil`: Sets this edge's throughput value.
- `LGraphEdge:setTravelTime(t) -> nil`: Sets the travel time for items moving across this edge.
- `LGraphEdge:setType(t) -> nil`: Sets the edge type string used by routing and filters.
- `LGraphEdge:setWeight(w) -> nil`: Sets the pathfinding weight for this edge.
- `LGraphEdge:type() -> string`: Returns the Lua-visible type name for this graph edge handle.
- `LGraphEdge:typeOf(name) -> boolean`: Returns whether this graph edge handle matches a supported type name.

#### LGraphFindPathForItemResult Type

- Generated result shape from @field tags.

##### Fields

- `cost` (`number`): Total path cost.
- `edges` (`LGraphEdge[]`): Path edges in order.
- `nodes` (`LGraphNode[]`): Path nodes in order.

##### Methods

- No documented methods.

#### LGraphFindPathResult Type

- Generated result shape from @field tags.

##### Fields

- `cost` (`number`): Total path cost.
- `edges` (`LGraphEdge[]`): Path edges in order.
- `nodes` (`LGraphNode[]`): Path nodes in order.

##### Methods

- No documented methods.

#### LGraphGetStatsResult Type

- Generated result shape from @field tags.

##### Fields

- `activeEdges` (`integer`): Active edge count.
- `activeNodes` (`integer`): Active node count.
- `edges` (`integer`): Edge count.
- `items` (`integer`): Item count.
- `itemsInTransit` (`integer`): Items in transit.
- `itemsOnNodes` (`integer`): Items on nodes.
- `nodes` (`integer`): Node count.
- `queuedItems` (`integer`): Queued item count.
- `totalDemand` (`integer`): Total demand.
- `totalSupply` (`integer`): Total supply.

##### Methods

- No documented methods.

#### LGraphItem Type

- Lua-side item handle referencing one item id inside a graph.

##### Fields

- No documented fields.

##### Methods

- `LGraphItem:getDecayTime() -> number`: Returns the total decay lifetime configured for this item.
- `LGraphItem:getPosition() -> LGraphNode`: Returns where this item is stored: a node, an edge plus progress, or no values when unplaced.
- `LGraphItem:getPriority() -> integer`: Returns this item's routing or queue priority.
- `LGraphItem:getRemainingLife() -> number`: Returns this item's remaining lifetime before decay.
- `LGraphItem:getType() -> string`: Returns the item type string used by filters, conversions, supplies, and demands.
- `LGraphItem:isAlive() -> boolean`: Returns whether this item is still alive in the graph simulation.
- `LGraphItem:kill() -> nil`: Marks this item as dead so graph processing can remove or ignore it.
- `LGraphItem:setDecayTime(t) -> nil`: Sets the total decay lifetime for this item.
- `LGraphItem:setPriority(p) -> nil`: Sets this item's routing or queue priority.
- `LGraphItem:setType(t) -> nil`: Changes the item type string used by graph routing and processing rules.
- `LGraphItem:type() -> string`: Returns the Lua-visible type name for this graph item handle.
- `LGraphItem:typeOf(name) -> boolean`: Returns whether this graph item handle matches a supported type name.

#### LGraphNode Type

- Lua-side node handle referencing one node id inside a graph.

##### Fields

- No documented fields.

##### Methods

- `LGraphNode:addDemand(item_type, quantity, priority?) -> nil`: Adds demand quantity and optional priority for an item type on this node.
- `LGraphNode:addSupply(item_type, quantity) -> nil`: Adds supply quantity for an item type on this node.
- `LGraphNode:addTag(tag) -> nil`: Adds a tag to this node on this object.
- `LGraphNode:clearAllConversions() -> nil`: Removes every conversion rule from this node.
- `LGraphNode:clearConversion(in_type) -> boolean`: Removes a conversion rule by input item type.
- `LGraphNode:clearDemands() -> nil`: Removes every demand entry from this node.
- `LGraphNode:clearSupplies() -> nil`: Removes every supply entry from this node.
- `LGraphNode:clearTags() -> nil`: Removes every tag from this graph node.
- `LGraphNode:dequeue() -> LGraphItem`: Removes and returns the next item from this node's explicit queue.
- `LGraphNode:enqueue(item_ud) -> boolean`: Adds an item handle to this node's explicit queue.
- `LGraphNode:getCapacity() -> integer`: Returns this node's item capacity.
- `LGraphNode:getEdges(dir?) -> LGraphEdge[]`: Returns edge handles connected to this node in the requested direction.
- `LGraphNode:getFlowMode() -> string`: Returns this node's flow mode name.
- `LGraphNode:getItemCount() -> integer`: Returns the number of items currently stored on this node.
- `LGraphNode:getItems() -> LGraphItem[]`: Returns item handles currently stored on this node.
- `LGraphNode:getOverflowPolicy() -> string`: Returns this node's overflow policy name.
- `LGraphNode:getProcessTime() -> number`: Returns the processing time used by this node's conversions.
- `LGraphNode:getPullFilter() -> string`: Returns this node's optional pull item-type filter.
- `LGraphNode:getPullRate() -> number`: Returns this node's pull rate value.
- `LGraphNode:getPushFilter() -> string`: Returns this node's optional push item-type filter.
- `LGraphNode:getPushRate() -> number`: Returns this node's push rate value.
- `LGraphNode:getQueueCapacity() -> integer`: Returns this node's queue capacity.
- `LGraphNode:getQueueSize() -> integer`: Returns the number of item ids currently queued at this node.
- `LGraphNode:getTags() -> string[]`: Returns all tags assigned to this node.
- `LGraphNode:getType() -> string`: Returns this node's type classification string.
- `LGraphNode:hasTag(tag) -> boolean`: Returns whether this node has a tag.
- `LGraphNode:isActive() -> boolean`: Returns whether this node is active for graph simulation.
- `LGraphNode:isFull() -> boolean`: Returns whether this node has reached its item capacity.
- `LGraphNode:isQueueEnabled() -> boolean`: Returns whether this node's explicit queue is enabled.
- `LGraphNode:removeDemand(item_type) -> boolean`: Removes demand entry for an item type from this node.
- `LGraphNode:removeSupply(item_type) -> boolean`: Removes supply entry for an item type from this node.
- `LGraphNode:removeTag(tag) -> boolean`: Removes a tag from this node on this object.
- `LGraphNode:setActive(a) -> nil`: Enables or disables this node for graph simulation.
- `LGraphNode:setCapacity(c) -> nil`: Sets this node's item capacity value.
- `LGraphNode:setConversion(in_type, out_type, in_count?, out_count?) -> nil`: Configures an item conversion rule on this node.
- `LGraphNode:setFlowMode(m) -> nil`: Sets this node's flow mode from a mode name.
- `LGraphNode:setOverflowPolicy(p) -> nil`: Sets this node's overflow policy from a policy name.
- `LGraphNode:setProcessTime(t) -> nil`: Sets the processing time used by this node's conversions.
- `LGraphNode:setPullFilter(f?) -> nil`: Sets or clears this node's pull item-type filter.
- `LGraphNode:setPullRate(r) -> nil`: Sets this node's pull rate for this object.
- `LGraphNode:setPushFilter(f?) -> nil`: Sets or clears this node's push item-type filter.
- `LGraphNode:setPushRate(r) -> nil`: Sets this node's push rate for this object.
- `LGraphNode:setQueueCapacity(c) -> nil`: Sets this node's queue capacity value.
- `LGraphNode:setQueueEnabled(e) -> nil`: Enables or disables this node's explicit queue.
- `LGraphNode:setType(t) -> nil`: Sets this node's type string for this object.
- `LGraphNode:type() -> string`: Returns the Lua-visible type name for this graph node handle.
- `LGraphNode:typeOf(name) -> boolean`: Returns whether this graph node handle matches a supported type name.

## References

- `image`: Imports or references `image` from `src/image/`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- No additional module-specific notes.
