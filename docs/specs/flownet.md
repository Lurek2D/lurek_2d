# flownet

## TL;DR

- The `flownet` module is a powerful Foundations tier component designed to model directed flow-simulation networks.

## General Info

- Module group: `Foundations`
- Source path: `src/flownet/`
- Lua API path(s): `src/lua_api/flownet_api.rs`
- Primary Lua namespace: `lurek.graph`
- Rust test path(s): tests/rust/unit/flownet_tests.rs plus inline flownet module tests
- Lua test path(s): tests/lua/unit/test_flownet.lua and related flownet stress and golden suites

## Summary

Moving beyond simple data-structure graphs, this module simulates complex logistics and transportation systems where typed items physically travel through interconnected nodes. The central `Graph` structure utilizes highly efficient `HashMap` storage and maintains persistent adjacency indexes, enabling O(1) neighbor lookups and robust graph traversal.

The simulation is deeply systemic. Items (`GraphItem`) accumulate in node inventories and traverse directed edges (`Edge`). These edges are not merely logical links; they enforce strict constraints including transit capacities, cooldown timers, and item-type filters. Nodes (`Node`) possess configurable item capacities, explicit queueing systems, and distinct flow modes (passive, push, or pull). Furthermore, nodes can execute `ConversionRule`s—acting as economic factories that consume specific inputs to produce new typed outputs. To manage bottlenecks, nodes implement defined `OverflowPolicy` behaviors, dictating whether excess items are rejected, queued, or destroyed.

The module runs an intricate simulation pipeline (`step(dt)`) that processes item decay, executes conversion rules, matches supply against demand declarations, and progresses items along edges. To support this, the module includes a comprehensive suite of graph algorithms: A* and Dijkstra shortest-path searches, reachability flood-fills, connected component discovery, cycle detection, topological sorting, Kruskal's minimum spanning tree, and graph coloring. Pathfinding inherently respects edge constraints and item-type filters. For performance scalability, the simulation tick can be executed in parallel using multi-threading. The engine exposes this entire logistical framework, alongside event-driven callbacks for state transitions, to Lua scripts via the `lurek.graph.*` namespace.

## Files

### algorithms.rs

- Connected-component discovery via undirected BFS traversal.
- Directed cycle detection using a three-color DFS walk.
- Kahn-style topological sort with deterministic tie-breaking.
- Kruskal minimum spanning forest using a union-find structure.
- Greedy graph coloring with sorted node-id processing order.
- Bipartiteness test through BFS two-coloring.
- A* shortest-path search using Euclidean node-position heuristics.
- All algorithms operate on the shared `Graph` adjacency representation.

### core.rs

- Graph container managing nodes, edges, and items with id-based lookup.
- Adjacency indexes for fast outgoing and incoming edge queries.
- Node CRUD with cascade removal of connected edges and displaced items.
- Edge CRUD with transit capacity, cooldown, and type filtering.
- Item lifecycle: creation, node placement (with overflow policy), transit, and removal.
- Subgraph extraction preserving topology and item positions.
- Aggregate stats computation across nodes and edges.
- Direction-based edge queries (in, out, both).
- Simple circular-layout image rendering for debug preview.
- JSON-like serialize and deserialize for persistence.

### edge.rs

- Directed edge connecting two graph nodes with capacity, throughput, and cooldown constraints.
- Type-based filtering restricts which items may transit an edge.
- Supports bidirectional flag and per-edge speed/weight modifiers for pathfinding.
- Captures functional behavior for edge so callers can compose this capability safely.

### item.rs

- Define `GraphItem` as the data carrier moved through graph nodes and edges.
- Track item position (at node, in transit, or unplaced) via `ItemPosition`.
- Provide decay-time lifetime, priority, and alive/dead state per item.
- Captures functional behavior for item so callers can compose this capability safely.

### mod.rs

- Directed flownet container with typed nodes, edges, and item flow.
- Supply/demand modeling, conversion rules, and overflow policies.
- Pathfinding, simulation stepping, and event emission.
- Render helpers for visual flownet output.

### node.rs

- Node struct with id, type, capacity, inventory, and flow settings for graph simulation.
- OverflowPolicy enum controlling behavior when a node reaches capacity: reject, destroy, or queue.
- FlowMode enum defining automatic push, pull, or passive behavior during simulation steps.
- ConversionRule, Supply, and Demand structs for item transformation and economic modeling.
- Tag, queue, and item management methods on Node.
- String-based FromStr parsing for policy and flow mode enums.

### pathfinding.rs

- Dijkstra shortest-path search over weighted directed graphs.
- Item-type-aware pathfinding respecting edge filters and cooldowns.
- Distance queries and bounded reachability flood-fill.
- Neighbor discovery across active edges and bidirectional links.
- Path reconstruction from predecessor maps into ordered node/edge lists.
- Priority-queue state with min-cost ordering for traversal.

### render.rs

- Render a graph as a circular node-and-edge diagram via `RenderCommand` output.
- Layout nodes evenly on a circle, draw edges as lines, color nodes by type.
- Produce a self-contained command list suitable for the engine renderer.

### simulation.rs

- Graph simulation tick loop: `update`, `step`, and parallel variant.
- Item decay processing: reduce remaining life, kill expired items, purge from all containers.
- Edge transit progression: advance items along edges and resolve arrivals with overflow policy.
- Push-flow mechanics: rate-limited emission of items from push-capable nodes onto outgoing edges.
- Pull-flow mechanics: rate-limited demand of items into pull-capable nodes from source inventories.
- Node conversion rules: consume matching inputs and produce typed outputs per recipe.
- Queue processing: timed dequeue of waiting items into node inventories when capacity allows.
- Overflow handling: reject, destroy, or queue items that arrive at full nodes.
- Parallel simulation via rayon feature gate for large-graph workloads.
- GraphEvent emission for every state transition observable by Lua scripts.

### supply_demand.rs

- Priority-ordered demand matching against available supply nodes.
- Pathfinding-based item routing from supplier to consumer.
- Event emission on supply depletion and demand fulfillment.
- Captures functional behavior for supply demand so callers can compose this capability safely.

### types.rs

- Shared type definitions for the flownet visual scripting graph.
- `NodeId`, `PortId`, and `EdgeId` are newtype wrappers around `u32` for clarity.
- `PortKind` distinguishes input/output and the value type carried (number, bool, any).
- `NodeValue` is the runtime variant type flowing through edges at evaluation time.
- All types are `Clone + Debug + PartialEq` to support undo-redo snapshotting.

## Lua API Ref

- Binding: `src/lua_api/flownet_api.rs`
- Namespace: `lurek.graph`

### Functions

- `lurek.graph.newGraph`: Creates an empty logistics graph with no nodes, edges, items, or callbacks.

### Enums

- No documented module-level enums/constants.

### Types


#### LGraph Type


##### Fields

- No documented fields.

##### Methods

- `LGraph:addEdge`: Creates an edge between two nodes with an optional edge type.
- `LGraph:addEdgeUnchecked`: Adds an edge without validating endpoint nodes exist. Faster for batch construction.
- `LGraph:addItem`: Places an item onto a destination node.
- `LGraph:addNode`: Creates a node with optional type and capacity.
- `LGraph:astar`: Runs A* pathfinding between two nodes.
- `LGraph:batchAddEdges`: Creates multiple edges from a table of {from_id, to_id} or {from_id, to_id, edge_type} entries.
- `LGraph:batchAddNodes`: Creates multiple nodes at once, returning their IDs as a table.
- `LGraph:batchStep`: Runs multiple simulation steps in sequence. More efficient than calling step() in a loop from Lua.
- `LGraph:colorGraph`: Computes graph coloring and returns color indices by node id.
- `LGraph:createItem`: Creates an unplaced graph item with optional type and decay time.
- `LGraph:findPath`: Finds a path between two graph nodes.
- `LGraph:findPathForItem`: Finds a path for a specific item between two nodes while respecting item constraints.
- `LGraph:getComponents`: Returns connected components as arrays of node handles.
- `LGraph:getDistance`: Returns graph distance between two nodes when reachable.
- `LGraph:getEdgeBetween`: Returns the edge connecting two nodes when one exists.
- `LGraph:getEdgeCount`: Returns the number of edges in this graph.
- `LGraph:getEdges`: Returns all edges in this logistics graph.
- `LGraph:getItemCount`: Returns the number of items in this graph.
- `LGraph:getItems`: Returns all items in this logistics graph.
- `LGraph:getNeighbors`: Returns neighbor nodes connected to a node.
- `LGraph:getNodeCount`: Returns the number of nodes in this graph.
- `LGraph:getNodes`: Returns all nodes in this logistics graph.
- `LGraph:getReachable`: Returns nodes reachable from a start node within an optional maximum distance.
- `LGraph:getStats`: Returns graph counts and aggregate supply-demand statistics.
- `LGraph:hasCycle`: Returns whether this graph contains a cycle.
- `LGraph:hasEdge`: Returns whether an edge handle still exists in this graph.
- `LGraph:hasItem`: Returns whether an item handle still exists in this graph.
- `LGraph:hasNode`: Returns whether a node handle still exists in this graph.
- `LGraph:isBipartite`: Returns whether this graph is bipartite.
- `LGraph:mst`: Computes a minimum spanning tree using Kruskal and returns edge ids.
- `LGraph:on`: Registers a callback for a named graph event generated during simulation.
- `LGraph:processDemand`: Processes graph supply and demand once and dispatches generated callbacks.
- `LGraph:removeEdge`: Removes an edge by handle on this object.
- `LGraph:removeItem`: Removes an item from this logistics graph.
- `LGraph:removeNode`: Removes a node and graph links associated with it.
- `LGraph:sendItem`: Starts moving an item along an edge.
- `LGraph:step`: Runs one discrete graph simulation step and dispatches generated callbacks.
- `LGraph:subgraph`: Creates a new graph containing a subset of nodes.
- `LGraph:tickParallel`: Advances graph simulation through the parallel update path and dispatches generated callbacks.
- `LGraph:topologicalSort`: Returns nodes in topological order when the graph is acyclic.
- `LGraph:type`: Returns the Lua-visible type name for this graph handle.
- `LGraph:typeOf`: Returns whether this graph handle matches a supported type name.
- `LGraph:update`: Advances graph simulation by delta time and dispatches generated callbacks.


#### LGraphEdge Type


##### Fields

- No documented fields.

##### Methods

- `LGraphEdge:addAllowedType`: Allows an item type to traverse this edge.
- `LGraphEdge:clearAllowedTypes`: Clears this edge's item type allow-list.
- `LGraphEdge:getCapacity`: Returns this edge's maximum concurrent item capacity.
- `LGraphEdge:getCooldown`: Returns this edge's cooldown timer value.
- `LGraphEdge:getFrom`: Returns the source node for this edge.
- `LGraphEdge:getItemsInTransit`: Returns graph items currently traveling along this edge.
- `LGraphEdge:getSpeedModifier`: Returns this edge's speed modifier.
- `LGraphEdge:getThroughput`: Returns this edge's throughput value.
- `LGraphEdge:getTo`: Returns the destination node for this edge.
- `LGraphEdge:getTravelTime`: Returns the travel time for items moving across this edge.
- `LGraphEdge:getType`: Returns the edge type string used by routing and filters.
- `LGraphEdge:getWeight`: Returns the pathfinding weight for this edge.
- `LGraphEdge:isActive`: Returns whether this edge is active for routing and simulation.
- `LGraphEdge:isBidirectional`: Returns whether this edge allows travel in both directions.
- `LGraphEdge:isItemTypeAllowed`: Returns whether an item type may traverse this edge.
- `LGraphEdge:isOnCooldown`: Returns whether this edge is currently on cooldown.
- `LGraphEdge:removeAllowedType`: Removes an item type from this edge's allow-list.
- `LGraphEdge:setActive`: Enables or disables this edge for routing and simulation.
- `LGraphEdge:setBidirectional`: Sets whether this edge allows travel in both directions.
- `LGraphEdge:setCapacity`: Sets this edge's maximum concurrent item capacity.
- `LGraphEdge:setCooldown`: Sets this edge's cooldown timer value.
- `LGraphEdge:setSpeedModifier`: Sets this edge's speed modifier value.
- `LGraphEdge:setThroughput`: Sets this edge's throughput value.
- `LGraphEdge:setTravelTime`: Sets the travel time for items moving across this edge.
- `LGraphEdge:setType`: Sets the edge type string used by routing and filters.
- `LGraphEdge:setWeight`: Sets the pathfinding weight for this edge.
- `LGraphEdge:type`: Returns the Lua-visible type name for this graph edge handle.
- `LGraphEdge:typeOf`: Returns whether this graph edge handle matches a supported type name.


#### LGraphItem Type


##### Fields

- No documented fields.

##### Methods

- `LGraphItem:getDecayTime`: Returns the total decay lifetime configured for this item.
- `LGraphItem:getPosition`: Returns where this item is stored: a node, an edge plus progress, or no values when unplaced.
- `LGraphItem:getPriority`: Returns this item's routing or queue priority.
- `LGraphItem:getRemainingLife`: Returns this item's remaining lifetime before decay.
- `LGraphItem:getType`: Returns the item type string used by filters, conversions, supplies, and demands.
- `LGraphItem:isAlive`: Returns whether this item is still alive in the graph simulation.
- `LGraphItem:kill`: Marks this item as dead so graph processing can remove or ignore it.
- `LGraphItem:setDecayTime`: Sets the total decay lifetime for this item.
- `LGraphItem:setPriority`: Sets this item's routing or queue priority.
- `LGraphItem:setType`: Changes the item type string used by graph routing and processing rules.
- `LGraphItem:type`: Returns the Lua-visible type name for this graph item handle.
- `LGraphItem:typeOf`: Returns whether this graph item handle matches a supported type name.


#### LGraphNode Type


##### Fields

- No documented fields.

##### Methods

- `LGraphNode:addDemand`: Adds demand quantity and optional priority for an item type on this node.
- `LGraphNode:addSupply`: Adds supply quantity for an item type on this node.
- `LGraphNode:addTag`: Adds a tag to this node on this object.
- `LGraphNode:clearAllConversions`: Removes every conversion rule from this node.
- `LGraphNode:clearConversion`: Removes a conversion rule by input item type.
- `LGraphNode:clearDemands`: Removes every demand entry from this node.
- `LGraphNode:clearSupplies`: Removes every supply entry from this node.
- `LGraphNode:clearTags`: Removes every tag from this graph node.
- `LGraphNode:dequeue`: Removes and returns the next item from this node's explicit queue.
- `LGraphNode:enqueue`: Adds an item handle to this node's explicit queue.
- `LGraphNode:getCapacity`: Returns this node's item capacity.
- `LGraphNode:getEdges`: Returns edge handles connected to this node in the requested direction.
- `LGraphNode:getFlowMode`: Returns this node's flow mode name.
- `LGraphNode:getItemCount`: Returns the number of items currently stored on this node.
- `LGraphNode:getItems`: Returns item handles currently stored on this node.
- `LGraphNode:getOverflowPolicy`: Returns this node's overflow policy name.
- `LGraphNode:getProcessTime`: Returns the processing time used by this node's conversions.
- `LGraphNode:getPullFilter`: Returns this node's optional pull item-type filter.
- `LGraphNode:getPullRate`: Returns this node's pull rate value.
- `LGraphNode:getPushFilter`: Returns this node's optional push item-type filter.
- `LGraphNode:getPushRate`: Returns this node's push rate value.
- `LGraphNode:getQueueCapacity`: Returns this node's queue capacity.
- `LGraphNode:getQueueSize`: Returns the number of item ids currently queued at this node.
- `LGraphNode:getTags`: Returns all tags assigned to this node.
- `LGraphNode:getType`: Returns this node's type classification string.
- `LGraphNode:hasTag`: Returns whether this node has a tag.
- `LGraphNode:isActive`: Returns whether this node is active for graph simulation.
- `LGraphNode:isFull`: Returns whether this node has reached its item capacity.
- `LGraphNode:isQueueEnabled`: Returns whether this node's explicit queue is enabled.
- `LGraphNode:removeDemand`: Removes demand entry for an item type from this node.
- `LGraphNode:removeSupply`: Removes supply entry for an item type from this node.
- `LGraphNode:removeTag`: Removes a tag from this node on this object.
- `LGraphNode:setActive`: Enables or disables this node for graph simulation.
- `LGraphNode:setCapacity`: Sets this node's item capacity value.
- `LGraphNode:setConversion`: Configures an item conversion rule on this node.
- `LGraphNode:setFlowMode`: Sets this node's flow mode from a mode name.
- `LGraphNode:setOverflowPolicy`: Sets this node's overflow policy from a policy name.
- `LGraphNode:setProcessTime`: Sets the processing time used by this node's conversions.
- `LGraphNode:setPullFilter`: Sets or clears this node's pull item-type filter.
- `LGraphNode:setPullRate`: Sets this node's pull rate for this object.
- `LGraphNode:setPushFilter`: Sets or clears this node's push item-type filter.
- `LGraphNode:setPushRate`: Sets this node's push rate for this object.
- `LGraphNode:setQueueCapacity`: Sets this node's queue capacity value.
- `LGraphNode:setQueueEnabled`: Enables or disables this node's explicit queue.
- `LGraphNode:setType`: Sets this node's type string for this object.
- `LGraphNode:type`: Returns the Lua-visible type name for this graph node handle.
- `LGraphNode:typeOf`: Returns whether this graph node handle matches a supported type name.

## References

- `image`: Imports or references `image` from `src/image/`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.
