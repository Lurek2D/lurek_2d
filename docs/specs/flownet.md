<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/flownet.md or source docstrings instead. -->

# flownet

## TL;DR

- Simulates directed logistics networks using node inventories, push-pull rates, and overflow policies.
- Integrates weighted transits, pathfinding, supply-demand balancing, and circular layouts.

## General Info

- Module group: `Foundations`
- Source path: `src/flownet`
- Binding: `src/lua_api/flownet_api.rs`
- Namespace: `lurek.graph`
- Lua API surface: `1` functions, `7` types, `140` methods
- User-facing: `true`
- Plugin tier: `not_evaluated`

## Summary

- The `flownet` module is the logistics-graph simulation surface for users who want resources, items, queues, routes, and transformation rules to behave as one explicit networked system.
- Nodes, edges, items, capacities, queue rules, cooldowns, transit timing, and placement semantics combine into a model where supply and processing are visible parts of gameplay rather than hidden bookkeeping.
- Logistics-heavy features depend on more than pathfinding alone. They also need ownership of where an item is, how much throughput a path supports, how congestion behaves, and how transformation steps consume and produce goods.
- Push and pull flows, reservations, demand matching, and simulation ticks make the module useful for factory loops, economy simulations, routing puzzles, and colony-style systems where movement through a graph is itself part of the game.
- Structural algorithms such as components and cycle checks keep the module useful for diagnostics and tooling.
- Visualization, serialization, and deterministic state handling make `flownet` practical for saves, tests, long-running scenarios, and bottleneck debugging where users need to explain why a network did or did not move goods.
- Reservation and throughput semantics are especially important because most logistics gameplay is really about contention. Users need to understand why an item waited, which edge saturated first, whether a consumer starved, or how competing flows were prioritized through the same network.
- Transformation support broadens the module beyond transport. Many networks do not merely move goods; they refine, combine, split, package, or otherwise convert them, so production logic has to remain visible inside the same graph model as routing.
- Simulation ticks give the system a temporal identity as well. Transit delays, cooldowns, queue progress, and staged processing make flow behavior something that evolves over time rather than resolving as an instant path query.
- That timing layer helps explain congestion.
- This makes `flownet` strong for factory chains, colony logistics, convoy simulation, resource routing puzzles, and economy layers where bottlenecks, congestion, and transformation rules are core gameplay rather than invisible backend bookkeeping.
- Read `flownet` as the owner of directed resource movement and conversion across a graph. Other systems may feed data into the network or draw conclusions from it, but this module decides how items, capacities, paths, queues, and transformations interact over time.
- `pipeline` may orchestrate higher-level processes that inspect or mutate a flownet, but it should not absorb flownet's graph simulation rules. Keep item routing, congestion, capacity, supply-demand, and conversion semantics here; keep flexible block execution, signal gates, and Lua process callbacks in `pipeline`.

This module primarily collaborates with `image`, `render`, `runtime`. Its responsibility should stay inside the `Foundations` group rather than absorb behavior owned by those neighbors.

## Ownership

- Canonical source: `src/flownet`
- Owning tier: `Foundations`
- Plugin tier: `not_evaluated`
- Lua binding owner: `src/lua_api/flownet_api.rs`
- Referenced engine modules: `image`, `render`, `runtime`

## Imports

- `image`: Imports or references `src/image/`. Cross-group dependency from `Foundations` into `Platform Services`.
- `render`: Imports or references `src/render/`. Cross-group dependency from `Foundations` into `Platform Services`.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Foundations` into `Core Runtime`.

## Source Files

### algorithms.rs

- This file owns structural graph-analysis helpers such as components, cycle checks, topological order, and coloring.
- It builds temporary adjacency views from shared graph indexes instead of duplicating persistent topology ownership.
- `mst_kruskal` lives here because spanning-forest analysis is an offline topology query, not part of simulation ticks.
- `is_bipartite` and `color_graph` support diagnostics and planner inspection without mutating nodes, edges, or items.
- `astar_graph` stays here because heuristic routing with caller positions is separate from edge-cost path search.
- These helpers read `Graph` state and return derived answers; they never own transit, demand, or save side effects.
- Open it when analytic queries change; shortest-path execution and per-tick movement rules live in sibling files.

### core.rs

- This file owns `Graph`, the flownet container storing nodes, edges, items, id counters, and adjacency indexes.
- It provides the authoritative CRUD path for nodes, edges, and items, including cascading cleanup and id assignment.
- Item placement helpers live here because inventories, queues, and transit buffers must stay mutually consistent.
- Send validation also lives here so edge activity, cooldown, filters, and current item position are checked in one place.
- Outgoing and incoming edge indexes are maintained here to keep pathfinding, analytics, and simulation queries cheap.
- `subgraph` cloning lives here because it remaps nodes, edges, items, and container ownership into a coherent snapshot.
- Aggregate counts from `GraphStats` are computed here because only this file sees the full graph-wide ownership picture.
- `draw_to_image` provides a quick preview boundary, but the richer renderer integration lives in sibling `render.rs`.
- Serialization and deserialization live here because persistence rebuilds nodes, edges, items, and references together.
- Legacy and versioned snapshot loaders are validated here so broken references fail before other flownet code runs.
- This file does not advance time; `simulation.rs` owns per-tick behavior and `supply_demand.rs` owns fulfillment policy.
- Open it when graph ownership or persistence changes; node contracts and routing algorithms are implemented elsewhere.

### edge.rs

- This file owns edge state, covering endpoints, type filters, transit capacity, travel timing, and cooldown behavior.
- `Edge` stores bidirectionality, weights, reservations, and in-transit item ids that pathfinding and simulation both use.
- Capacity reservation helpers live here so planners and runtime sends evaluate the same available-space calculations.
- Filtering and cooldown checks here define whether an item type may enter an edge before any transit update begins.
- Open it when connection constraints change; node policy, route search, and graph indexing live in sibling files.

### item.rs

- This file owns flownet item records, covering identity, decay lifetime, priority, and current placement state.
- `ItemPosition` tracks whether an item is on a node, moving through an edge, or temporarily left unplaced.
- `GraphItem` exposes the mutable payload state that simulation, routing, and conversion rules inspect every tick.
- Open it when item lifecycle fields or placement semantics change; graph mutation and simulation live in siblings.

### mod.rs

- This module is the flownet index, wiring graph storage, simulation, routing, algorithms, and render helpers.
- It reexports `Graph`, ids, node contracts, items, edges, and events so callers enter the subsystem from one file.
- `core.rs` owns mutation and persistence, `simulation.rs` advances state, and `pathfinding.rs` owns route queries.
- `node.rs`, `edge.rs`, `item.rs`, and `types.rs` define the local data contracts consumed across all flownet logic.
- This file owns visibility and navigation only, not graph state, update rules, route costs, or debug drawing behavior.
- Open it when public flownet exports move; open the sibling owner file when transport or simulation semantics change.

### node.rs

- This file owns node state, including capacity, flow mode, overflow policy, queue state, tags, supplies, and demands.
- It defines the local contracts for `OverflowPolicy`, `FlowMode`, `ConversionRule`, `Supply`, `Demand`, and `Node`.
- Push and pull timers, reservations, and item filters live here because node policy drives later simulation decisions.
- Conversion, queue, and tag helpers live on `Node` so graph and simulation code can mutate one stable inventory owner.
- Supply and demand records are stored here because fulfillment and conversion rules need node-local economic state.
- This file does not move items between containers; `core.rs` owns graph mutation and `simulation.rs` owns tick execution.
- Open it when node behavior changes; edges, items, pathfinding, and graph serialization are implemented elsewhere.

### pathfinding.rs

- This file owns shortest-path queries and reachability over flownet graphs, returning ordered node and edge routes.
- `PathResult` is the durable route contract used by demand matching and any caller that needs executable path state.
- Dijkstra traversal lives here because route cost depends on edge activity, weights, cooldowns, and bidirectional flags.
- `find_path_for_item` adds type-filter and cooldown checks so planned movement matches the same constraints as sending.
- `get_distance`, `get_reachable`, and `get_neighbors` are read-only graph queries that never mutate containers or timers.
- Path reconstruction stays here because predecessor maps are an internal search detail, not work for `core.rs`.
- Open it when route semantics change; topology analytics, simulation ticks, and graph storage live in sibling files.

### render.rs

- This file owns the debug render adapter that turns flownet topology into generic `RenderCommand` previews.
- It lays nodes out on a deterministic circle, colors them by type, and draws visible links for quick inspection.
- No graph mutation lives here; it is a read-only bridge from `Graph` storage into the engine renderer surface.
- Open it when flownet visualization changes; simulation, routing, and topology ownership stay in sibling files.

### simulation.rs

- This file owns the per-tick flownet loop that advances decay, transit, cooldowns, flow, conversions, and queues.
- `GraphEvent` is declared here because update passes emit a stable stream of state transitions for observers and tests.
- Transit resolution lives here, including arrival handling, overflow-policy outcomes, queueing, and lost-item reporting.
- Push and pull phases use node timers and edge checks here so autonomous movement follows configured flow policies.
- Conversion processing also lives here because it consumes node inventories and produces new items during each tick.
- Queue promotion is local here because waiting items depend on processing time, capacity, and earlier arrival outcomes.
- `update_parallel` shares the same contract but parallelizes only decay; later stateful phases still run in order.
- Open it when runtime progression changes; graph CRUD, demand matching, and route queries live in sibling files.

### supply_demand.rs

- This file owns demand-matching logic that scans node requests, finds supplier paths, and dispatches items in order.
- It sorts demands by priority, checks available supply, and uses `find_path` plus `send_item` to start transfers.
- Supply depletion and fulfillment events are emitted here because this pass owns cross-node matching side effects.
- This is not the general tick loop; decay, transit, push, pull, and conversion updates live in `simulation.rs`.
- Open it when fulfillment policy changes; graph storage, pathfinding, and edge transit rules live in sibling files.

### types.rs

- This file owns the lightweight `NodeId`, `EdgeId`, and `ItemId` newtypes that label every flownet handle.
- It keeps raw `u64` identities wrapped so graph APIs, logs, and serialization stay type-safe at call boundaries.
- Constructors, `raw()`, display, and `From` conversions live here because id ergonomics must stay uniform everywhere.
- No graph storage lives here; this file is the narrow contract that other flownet files share for stable references.
- Open it when identifier semantics change; node, edge, item, and graph behavior are implemented in sibling files.



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
- `LGraphEdge:clearCapacityReservations() -> nil`: Removes every transit capacity reservation from this edge.
- `LGraphEdge:getAvailableCapacity() -> integer`: Returns how many transit slots remain after active items and reservations, or -1 when unlimited.
- `LGraphEdge:getCapacity() -> integer`: Returns this edge's maximum concurrent item capacity.
- `LGraphEdge:getCooldown() -> number`: Returns this edge's cooldown timer value.
- `LGraphEdge:getFrom() -> LGraphNode`: Returns the source node for this edge.
- `LGraphEdge:getItemsInTransit() -> LGraphItem[]`: Returns graph items currently traveling along this edge.
- `LGraphEdge:getReservedCapacity() -> integer`: Returns the total transit capacity reserved on this edge across all reservation keys.
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
- `LGraphEdge:releaseCapacityReservation(key, slots?) -> integer`: Releases reserved transit capacity for a key and returns the number of slots removed.
- `LGraphEdge:removeAllowedType(t) -> boolean`: Removes an item type from this edge's allow-list.
- `LGraphEdge:reserveCapacity(key, slots?) -> boolean`: Reserves transit capacity slots under a caller-provided key for planning and coordination.
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
- `LGraphNode:clearCapacityReservations() -> nil`: Removes every inventory capacity reservation from this node.
- `LGraphNode:clearConversion(in_type) -> boolean`: Removes a conversion rule by input item type.
- `LGraphNode:clearDemands() -> nil`: Removes every demand entry from this node.
- `LGraphNode:clearSupplies() -> nil`: Removes every supply entry from this node.
- `LGraphNode:clearTags() -> nil`: Removes every tag from this graph node.
- `LGraphNode:dequeue() -> LGraphItem`: Removes and returns the next item from this node's explicit queue.
- `LGraphNode:enqueue(item_ud) -> boolean`: Adds an item handle to this node's explicit queue.
- `LGraphNode:getAvailableCapacity() -> integer`: Returns how many node inventory slots remain after active items and reservations, or -1 when unlimited.
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
- `LGraphNode:getReservedCapacity() -> integer`: Returns the total item capacity reserved on this node across all reservation keys.
- `LGraphNode:getTags() -> string[]`: Returns all tags assigned to this node.
- `LGraphNode:getType() -> string`: Returns this node's type classification string.
- `LGraphNode:hasTag(tag) -> boolean`: Returns whether this node has a tag.
- `LGraphNode:isActive() -> boolean`: Returns whether this node is active for graph simulation.
- `LGraphNode:isFull() -> boolean`: Returns whether this node has reached its item capacity.
- `LGraphNode:isQueueEnabled() -> boolean`: Returns whether this node's explicit queue is enabled.
- `LGraphNode:releaseCapacityReservation(key, slots?) -> integer`: Releases reserved node capacity for a key and returns the number of slots removed.
- `LGraphNode:removeDemand(item_type) -> boolean`: Removes demand entry for an item type from this node.
- `LGraphNode:removeSupply(item_type) -> boolean`: Removes supply entry for an item type from this node.
- `LGraphNode:removeTag(tag) -> boolean`: Removes a tag from this node on this object.
- `LGraphNode:reserveCapacity(key, slots?) -> boolean`: Reserves node inventory capacity under a caller-provided key for planning and coordination.
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

## Examples

- `content/examples/flownet.lua` (present)

## Tests

- Lua unit: `tests/lua/unit/test_flownet_unit.lua` (present)
- Rust: `tests/rust/unit/flownet_tests.rs`

## Evidence / Golden

| Kind | Path |
|---|---|
| Evidence test | `tests/lua/evidence/test_flownet_evidence.lua` |
| Golden test | `tests/lua/golden/test_flownet_golden.lua` |
| Current artifact | `tests/artifacts/current/flownet/flownet_queue_overflow.png` |
| Current artifact | `tests/artifacts/current/flownet/flownet_route_constraints.png` |
| Current artifact | `tests/artifacts/current/flownet/flownet_supply_conversion.png` |
| Current artifact | `tests/artifacts/current/flownet/flownet_topology_algorithms.png` |
| Current artifact | `tests/artifacts/current/flownet/flownet_transit_capacity.png` |
| Baseline artifact | `tests/artifacts/baselines/flownet/flownet_queue_overflow.png` |
| Baseline artifact | `tests/artifacts/baselines/flownet/flownet_route_constraints.png` |
| Baseline artifact | `tests/artifacts/baselines/flownet/flownet_supply_conversion.png` |
| Baseline artifact | `tests/artifacts/baselines/flownet/flownet_topology_algorithms.png` |
| Baseline artifact | `tests/artifacts/baselines/flownet/flownet_transit_capacity.png` |

## Architecture Links

- Intentionally empty.

## Notes

- No additional module-specific notes.
