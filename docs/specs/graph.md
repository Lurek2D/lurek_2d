# graph

## General Info

- Module group: `Foundations`
- Source path: `src/graph/`
- Lua API path(s): `src/lua_api/graph_api.rs`
- Primary Lua namespace: `lurek.graph`
- Rust test path(s): tests/rust/unit/graph_tests.rs plus inline graph module tests
- Lua test path(s): tests/lua/unit/test_graph.lua and related graph stress and golden suites

## Summary

The `graph` module is a powerful Foundations tier component designed to model directed flow-simulation networks. Moving beyond simple data-structure graphs, this module simulates complex logistics and transportation systems where typed items physically travel through interconnected nodes. The central `Graph` structure utilizes highly efficient `HashMap` storage and maintains persistent adjacency indexes, enabling O(1) neighbor lookups and robust graph traversal.

The simulation is deeply systemic. Items (`GraphItem`) accumulate in node inventories and traverse directed edges (`Edge`). These edges are not merely logical links; they enforce strict constraints including transit capacities, cooldown timers, and item-type filters. Nodes (`Node`) possess configurable item capacities, explicit queueing systems, and distinct flow modes (passive, push, or pull). Furthermore, nodes can execute `ConversionRule`s—acting as economic factories that consume specific inputs to produce new typed outputs. To manage bottlenecks, nodes implement defined `OverflowPolicy` behaviors, dictating whether excess items are rejected, queued, or destroyed.

The module runs an intricate simulation pipeline (`step(dt)`) that processes item decay, executes conversion rules, matches supply against demand declarations, and progresses items along edges. To support this, the module includes a comprehensive suite of graph algorithms: A* and Dijkstra shortest-path searches, reachability flood-fills, connected component discovery, cycle detection, topological sorting, Kruskal's minimum spanning tree, and graph coloring. Pathfinding inherently respects edge constraints and item-type filters. For performance scalability, the simulation tick can be executed in parallel using multi-threading. The engine exposes this entire logistical framework, alongside event-driven callbacks for state transitions, to Lua scripts via the `lurek.graph.*` namespace.

## Source Documentation

### `algorithms.rs`
- Connected-component discovery via undirected BFS traversal.
- Directed cycle detection using a three-color DFS walk.
- Kahn-style topological sort with deterministic tie-breaking.
- Kruskal minimum spanning forest using a union-find structure.
- Greedy graph coloring with sorted node-id processing order.
- Bipartiteness test through BFS two-coloring.
- A* shortest-path search using Euclidean node-position heuristics.
- All algorithms operate on the shared `Graph` adjacency representation.

### `core.rs`
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

### `edge.rs`
- Directed edge connecting two graph nodes with capacity, throughput, and cooldown constraints.
- Type-based filtering restricts which items may transit an edge.
- Supports bidirectional flag and per-edge speed/weight modifiers for pathfinding.

### `item.rs`
- Define `GraphItem` as the data carrier moved through graph nodes and edges.
- Track item position (at node, in transit, or unplaced) via `ItemPosition`.
- Provide decay-time lifetime, priority, and alive/dead state per item.

### `mod.rs`
- Directed graph container with typed nodes, edges, and item flow.
- Supply/demand modeling, conversion rules, and overflow policies.
- Pathfinding, simulation stepping, and event emission.
- Render helpers for visual graph output.

### `node.rs`
- Node struct with id, type, capacity, inventory, and flow settings for graph simulation.
- OverflowPolicy enum controlling behavior when a node reaches capacity: reject, destroy, or queue.
- FlowMode enum defining automatic push, pull, or passive behavior during simulation steps.
- ConversionRule, Supply, and Demand structs for item transformation and economic modeling.
- Tag, queue, and item management methods on Node.
- String-based FromStr parsing for policy and flow mode enums.

### `pathfinding.rs`
- Dijkstra shortest-path search over weighted directed graphs.
- Item-type-aware pathfinding respecting edge filters and cooldowns.
- Distance queries and bounded reachability flood-fill.
- Neighbor discovery across active edges and bidirectional links.
- Path reconstruction from predecessor maps into ordered node/edge lists.
- Priority-queue state with min-cost ordering for traversal.

### `render.rs`
- Render a graph as a circular node-and-edge diagram via `RenderCommand` output.
- Layout nodes evenly on a circle, draw edges as lines, color nodes by type.
- Produce a self-contained command list suitable for the engine renderer.

### `simulation.rs`
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

### `supply_demand.rs`
- Priority-ordered demand matching against available supply nodes.
- Pathfinding-based item routing from supplier to consumer.
- Event emission on supply depletion and demand fulfillment.

## Types

- `GraphStats` (`struct`, `core.rs`): Read-only state summary for graph size, activity, demand, supply, and queued items.
- `Graph` (`struct`, `core.rs`): Central directed graph container that owns nodes, edges, items, and most module behavior through impl blocks.
- `Edge` (`struct`, `edge.rs`): Directed connection that controls routing cost, travel time, cooldown, capacity, and allowed item types.
- `ItemPosition` (`enum`, `item.rs`): Enum describing whether an item is at a node, in transit on an edge, or unplaced.
- `GraphItem` (`struct`, `item.rs`): Typed entity that moves through the graph with lifetime, priority, and current position state.
- `OverflowPolicy` (`enum`, `node.rs`): Enum describing how full nodes reject, destroy, or queue incoming items.
- `FlowMode` (`enum`, `node.rs`): Enum describing whether a node passively holds items or actively pushes and or pulls them.
- `ConversionRule` (`struct`, `node.rs`): A rule that converts N input items of one type into M output items of another.
- `Supply` (`struct`, `node.rs`): Declares that a node can produce items of a given type up to a specified quantity.
- `Demand` (`struct`, `node.rs`): Declares that a node needs items of a given type, with a priority for fulfillment ordering.
- `Node` (`struct`, `node.rs`): Rich vertex type with capacity, flow mode, overflow policy, queueing, conversion rules, supplies, demands, and tags.
- `PathResult` (`struct`, `pathfinding.rs`): Shortest-path result containing ordered node IDs, edge IDs, and total path cost.
- `GraphEvent` (`enum`, `simulation.rs`): Event enum emitted by simulation and demand processing for Lua callback dispatch.

## Functions

- `Graph::get_components` (`algorithms.rs`): Return connected components as sorted node-id groups.
- `Graph::has_cycle` (`algorithms.rs`): Return true when the directed graph contains a cycle.
- `Graph::topological_sort` (`algorithms.rs`): Return a topological ordering or None when the graph has a cycle.
- `Graph::mst_kruskal` (`algorithms.rs`): Return edge ids in a Kruskal minimum spanning forest.
- `Graph::color_graph` (`algorithms.rs`): Assign greedy graph colors to node ids.
- `Graph::is_bipartite` (`algorithms.rs`): Return true when the graph is bipartite.
- `Graph::astar_graph` (`algorithms.rs`): Find an A* node path using supplied node positions as the heuristic source.
- `Graph::new` (`core.rs`): Create an empty graph with fresh id counters.
- `Graph::outgoing_edge_ids_slice` (`core.rs`): Return the indexed outgoing edge ids for a node.
- `Graph::incoming_edge_ids_slice` (`core.rs`): Return the indexed incoming edge ids for a node.
- `Graph::add_node` (`core.rs`): Add a node and return its assigned id.
- `Graph::remove_node` (`core.rs`): Remove a node and all connected edges, returning true when it existed.
- `Graph::has_node` (`core.rs`): Return true when the node id exists.
- `Graph::get_node_ids` (`core.rs`): Return all node ids in arbitrary order.
- `Graph::get_node_count` (`core.rs`): Return the number of nodes.
- `Graph::add_edge` (`core.rs`): Add an edge and return its assigned id or an error when either endpoint is missing.
- `Graph::remove_edge` (`core.rs`): Remove an edge and detach any items in transit, returning true when it existed.
- `Graph::has_edge` (`core.rs`): Return true when the edge id exists.
- `Graph::get_edge_ids` (`core.rs`): Return all edge ids in arbitrary order.
- `Graph::get_edge_count` (`core.rs`): Return the number of edges.
- `Graph::get_edge_between` (`core.rs`): Return the first outgoing edge id that connects the supplied nodes.
- `Graph::subgraph` (`core.rs`): Build a new graph containing only the selected nodes and connected data.
- `Graph::create_item` (`core.rs`): Create an item and return its assigned id.
- `Graph::add_item_to_node` (`core.rs`): Add an item to a node and return whether the placement succeeded.
- `Graph::remove_item` (`core.rs`): Remove an item from the graph and all node or edge containers.
- `Graph::has_item` (`core.rs`): Return true when the item id exists.
- `Graph::get_item_ids` (`core.rs`): Return all item ids in arbitrary order.
- `Graph::get_item_count` (`core.rs`): Return the number of items.
- `Graph::send_item` (`core.rs`): Send an item onto an edge and return whether the transfer succeeded.
- `Graph::get_stats` (`core.rs`): Return aggregate counts derived from the current graph state.
- `Graph::get_outgoing_edges` (`core.rs`): Return outgoing edge ids for a node.
- `Graph::get_incoming_edges` (`core.rs`): Return incoming edge ids for a node.
- `Graph::get_edges_by_direction` (`core.rs`): Return edge ids by requested direction or an error when the direction is invalid.
- `Graph::draw_to_image` (`core.rs`): Draw a simple circular graph preview into an image buffer.
- `Graph::serialize` (`core.rs`): Serialize nodes and edges into a JSON-like value map.
- `Graph::deserialize` (`core.rs`): Deserialize a graph from the JSON-like value map or return a shape error.
- `Edge::new` (`edge.rs`): Create an edge with default transit settings.
- `Edge::get_type` (`edge.rs`): Return the edge type string.
- `Edge::set_type` (`edge.rs`): Set the edge type string.
- `Edge::is_on_cooldown` (`edge.rs`): Return true when the edge is still on cooldown.
- `Edge::is_item_type_allowed` (`edge.rs`): Return true when the item type is allowed by the edge filter.
- `Edge::add_allowed_type` (`edge.rs`): Allow an item type on the edge.
- `Edge::remove_allowed_type` (`edge.rs`): Remove an allowed item type and return true when it existed.
- `Edge::clear_allowed_types` (`edge.rs`): Remove all allowed item type filters.
- `Edge::is_transit_full` (`edge.rs`): Return true when the transit buffer is at or above capacity.
- `GraphItem::new` (`item.rs`): Create an item with the supplied id, type, and decay time.
- `GraphItem::kill` (`item.rs`): Mark the item as dead.
- `GraphItem::is_alive` (`item.rs`): Return true when the item is alive.
- `GraphItem::get_type` (`item.rs`): Return the item type string.
- `GraphItem::set_type` (`item.rs`): Set the item type string.
- `GraphItem::get_decay_time` (`item.rs`): Return the configured decay time.
- `GraphItem::set_decay_time` (`item.rs`): Set decay time and reset remaining life when the new time is positive.
- `GraphItem::get_remaining_life` (`item.rs`): Return the remaining lifetime.
- `GraphItem::set_remaining_life` (`item.rs`): Set the remaining lifetime.
- `GraphItem::get_priority` (`item.rs`): Return the item priority.
- `GraphItem::set_priority` (`item.rs`): Set the item priority.
- `GraphItem::get_position` (`item.rs`): Return the current placement state.
- `GraphItem::set_position` (`item.rs`): Set the current placement state.
- `OverflowPolicy::to_str` (`node.rs`): Return the lowercase policy string.
- `FlowMode::to_str` (`node.rs`): Return the lowercase flow mode string.
- `Node::new` (`node.rs`): Create a node with default flow settings and the supplied id, type, and capacity.
- `Node::get_type` (`node.rs`): Return the node type string.
- `Node::set_type` (`node.rs`): Set the node type string.
- `Node::get_capacity` (`node.rs`): Return the node capacity.
- `Node::set_capacity` (`node.rs`): Set the node capacity.
- `Node::is_full` (`node.rs`): Return true when the node is at or above capacity.
- `Node::item_count` (`node.rs`): Return the number of items currently held on the node.
- `Node::add_tag` (`node.rs`): Add a tag to the node.
- `Node::remove_tag` (`node.rs`): Remove a tag and return true when it existed.
- `Node::has_tag` (`node.rs`): Return true when the node has the supplied tag.
- `Node::clear_tags` (`node.rs`): Remove all tags from the node.
- `Node::get_tags` (`node.rs`): Return all tags sorted in ascending order.
- `Node::add_supply` (`node.rs`): Add a supply record for an item type.
- `Node::remove_supply` (`node.rs`): Remove all supplies for an item type and return true when any were removed.
- `Node::clear_supplies` (`node.rs`): Remove all supply records.
- `Node::get_supply` (`node.rs`): Return the first supply record for an item type.
- `Node::get_available_supply` (`node.rs`): Sum all supply quantities for an item type.
- `Node::add_demand` (`node.rs`): Add a demand record for an item type.
- `Node::remove_demand` (`node.rs`): Remove all demands for an item type and return true when any were removed.
- `Node::clear_demands` (`node.rs`): Remove all demand records.
- `Node::get_demand` (`node.rs`): Return the first demand record for an item type.
- `Node::set_conversion` (`node.rs`): Set or replace a conversion rule keyed by its input type.
- `Node::clear_conversion` (`node.rs`): Remove a conversion rule and return true when it existed.
- `Node::clear_all_conversions` (`node.rs`): Remove all conversion rules.
- `Node::enqueue` (`node.rs`): Enqueue an item id and return false when the queue is full.
- `Node::dequeue` (`node.rs`): Dequeue the oldest queued item id when one exists.
- `Graph::find_path` (`pathfinding.rs`): Find the cheapest active path between two nodes.
- `Graph::find_path_for_item` (`pathfinding.rs`): Find the cheapest active path for an item type between two nodes.
- `Graph::get_distance` (`pathfinding.rs`): Return the cheapest path cost between two nodes.
- `Graph::get_reachable` (`pathfinding.rs`): Return nodes reachable from a source within an optional cost limit.
- `Graph::get_neighbors` (`pathfinding.rs`): Return active neighboring node ids connected to the supplied node.
- `Graph::generate_render_commands` (`render.rs`): Generate a simple circular graph preview as renderer commands.
- `Graph::update` (`simulation.rs`): Run one simulation update and return the emitted events.
- `Graph::step` (`simulation.rs`): Run one simulation update with dt set to 1.0.
- `Graph::update_parallel` (`simulation.rs`): Run one simulation update using parallel decay processing when enabled.
- `Graph::update_parallel` (`simulation.rs`): Run one simulation update when the parallel feature is disabled.
- `Graph::process_demand` (`supply_demand.rs`): Process node demands and return the resulting graph events.

## Lua API Reference

- Binding path(s): `src/lua_api/graph_api.rs`
- Namespace: `lurek.graph`

### Module Functions
- `lurek.graph.newGraph`: Creates an empty logistics graph with no nodes, edges, items, or callbacks.

### `LGraph` Methods
- `LGraph:addNode`: Creates a node with optional type and capacity.
- `LGraph:removeNode`: Removes a node and graph links associated with it.
- `LGraph:hasNode`: Returns whether a node handle still exists in this graph.
- `LGraph:getNodes`: Returns all nodes in this graph. This method is available to Lua scripts.
- `LGraph:getNodeCount`: Returns the number of nodes in this graph.
- `LGraph:addEdge`: Creates an edge between two nodes with an optional edge type.
- `LGraph:removeEdge`: Removes an edge by handle. This method is available to Lua scripts.
- `LGraph:hasEdge`: Returns whether an edge handle still exists in this graph.
- `LGraph:getEdges`: Returns all edges in this graph. This method is available to Lua scripts.
- `LGraph:getEdgeCount`: Returns the number of edges in this graph.
- `LGraph:getEdgeBetween`: Returns the edge connecting two nodes when one exists.
- `LGraph:createItem`: Creates an unplaced graph item with optional type and decay time.
- `LGraph:addItem`: Places an item onto a node. This method is available to Lua scripts.
- `LGraph:removeItem`: Removes an item from this graph. This method is available to Lua scripts.
- `LGraph:hasItem`: Returns whether an item handle still exists in this graph.
- `LGraph:getItems`: Returns all items in this graph. This method is available to Lua scripts.
- `LGraph:getItemCount`: Returns the number of items in this graph.
- `LGraph:sendItem`: Starts moving an item along an edge.
- `LGraph:update`: Advances graph simulation by delta time and dispatches generated callbacks.
- `LGraph:step`: Runs one discrete graph simulation step and dispatches generated callbacks.
- `LGraph:tickParallel`: Advances graph simulation through the parallel update path and dispatches generated callbacks.
- `LGraph:findPath`: Finds a path between two nodes. This method is available to Lua scripts.
- `LGraph:findPathForItem`: Finds a path for a specific item between two nodes while respecting item constraints.
- `LGraph:getDistance`: Returns graph distance between two nodes when reachable.
- `LGraph:getReachable`: Returns nodes reachable from a start node within an optional maximum distance.
- `LGraph:getNeighbors`: Returns neighbor nodes connected to a node.
- `LGraph:getComponents`: Returns connected components as arrays of node handles.
- `LGraph:subgraph`: Creates a new graph containing a subset of nodes.
- `LGraph:hasCycle`: Returns whether this graph contains a cycle.
- `LGraph:topologicalSort`: Returns nodes in topological order when the graph is acyclic.
- `LGraph:mst`: Computes a minimum spanning tree using Kruskal and returns edge ids.
- `LGraph:colorGraph`: Computes graph coloring and returns color indices by node id.
- `LGraph:isBipartite`: Returns whether this graph is bipartite.
- `LGraph:astar`: Runs A* pathfinding between two nodes.
- `LGraph:processDemand`: Processes graph supply and demand once and dispatches generated callbacks.
- `LGraph:getStats`: Returns graph counts and aggregate supply-demand statistics.
- `LGraph:on`: Registers a callback for a named graph event generated during simulation.
- `LGraph:type`: Returns the Lua-visible type name for this graph handle.
- `LGraph:typeOf`: Returns whether this graph handle matches a supported type name.

### `LGraphEdge` Methods
- `LGraphEdge:getType`: Returns the edge type string used by routing and filters.
- `LGraphEdge:setType`: Sets the edge type string used by routing and filters.
- `LGraphEdge:getFrom`: Returns the source node for this edge.
- `LGraphEdge:getTo`: Returns the destination node for this edge.
- `LGraphEdge:getCapacity`: Returns this edge's maximum concurrent item capacity.
- `LGraphEdge:setCapacity`: Sets this edge's maximum concurrent item capacity.
- `LGraphEdge:getThroughput`: Returns this edge's throughput value.
- `LGraphEdge:setThroughput`: Sets this edge's throughput value.
- `LGraphEdge:getTravelTime`: Returns the travel time for items moving across this edge.
- `LGraphEdge:setTravelTime`: Sets the travel time for items moving across this edge.
- `LGraphEdge:getWeight`: Returns the pathfinding weight for this edge.
- `LGraphEdge:setWeight`: Sets the pathfinding weight for this edge.
- `LGraphEdge:getSpeedModifier`: Returns this edge's speed modifier.
- `LGraphEdge:setSpeedModifier`: Sets this edge's speed modifier. This method is available to Lua scripts.
- `LGraphEdge:getCooldown`: Returns this edge's cooldown timer value.
- `LGraphEdge:setCooldown`: Sets this edge's cooldown timer value.
- `LGraphEdge:isOnCooldown`: Returns whether this edge is currently on cooldown.
- `LGraphEdge:isBidirectional`: Returns whether this edge allows travel in both directions.
- `LGraphEdge:setBidirectional`: Sets whether this edge allows travel in both directions.
- `LGraphEdge:isActive`: Returns whether this edge is active for routing and simulation.
- `LGraphEdge:setActive`: Enables or disables this edge for routing and simulation.
- `LGraphEdge:getItemsInTransit`: Returns graph items currently traveling along this edge.
- `LGraphEdge:addAllowedType`: Allows an item type to traverse this edge.
- `LGraphEdge:removeAllowedType`: Removes an item type from this edge's allow-list.
- `LGraphEdge:clearAllowedTypes`: Clears this edge's item type allow-list.
- `LGraphEdge:isItemTypeAllowed`: Returns whether an item type may traverse this edge.
- `LGraphEdge:type`: Returns the Lua-visible type name for this graph edge handle.
- `LGraphEdge:typeOf`: Returns whether this graph edge handle matches a supported type name.

### `LGraphItem` Methods
- `LGraphItem:getType`: Returns the item type string used by filters, conversions, supplies, and demands.
- `LGraphItem:setType`: Changes the item type string used by graph routing and processing rules.
- `LGraphItem:getDecayTime`: Returns the total decay lifetime configured for this item.
- `LGraphItem:setDecayTime`: Sets the total decay lifetime for this item.
- `LGraphItem:getRemainingLife`: Returns this item's remaining lifetime before decay.
- `LGraphItem:isAlive`: Returns whether this item is still alive in the graph simulation.
- `LGraphItem:kill`: Marks this item as dead so graph processing can remove or ignore it.
- `LGraphItem:getPriority`: Returns this item's routing or queue priority.
- `LGraphItem:setPriority`: Sets this item's routing or queue priority.
- `LGraphItem:getPosition`: Returns where this item is stored: a node, an edge plus progress, or no values when unplaced.
- `LGraphItem:type`: Returns the Lua-visible type name for this graph item handle.
- `LGraphItem:typeOf`: Returns whether this graph item handle matches a supported type name.

### `LGraphNode` Methods
- `LGraphNode:getType`: Returns this node's type string. This method is available to Lua scripts.
- `LGraphNode:setType`: Sets this node's type string. This method is available to Lua scripts.
- `LGraphNode:getCapacity`: Returns this node's item capacity.
- `LGraphNode:setCapacity`: Sets this node's item capacity. This method is available to Lua scripts.
- `LGraphNode:getItemCount`: Returns the number of items currently stored on this node.
- `LGraphNode:isFull`: Returns whether this node has reached its item capacity.
- `LGraphNode:isActive`: Returns whether this node is active for graph simulation.
- `LGraphNode:setActive`: Enables or disables this node for graph simulation.
- `LGraphNode:getOverflowPolicy`: Returns this node's overflow policy name.
- `LGraphNode:setOverflowPolicy`: Sets this node's overflow policy from a policy name.
- `LGraphNode:getFlowMode`: Returns this node's flow mode name.
- `LGraphNode:setFlowMode`: Sets this node's flow mode from a mode name.
- `LGraphNode:getPushRate`: Returns this node's push rate. This method is available to Lua scripts.
- `LGraphNode:setPushRate`: Sets this node's push rate. This method is available to Lua scripts.
- `LGraphNode:getPullRate`: Returns this node's pull rate. This method is available to Lua scripts.
- `LGraphNode:setPullRate`: Sets this node's pull rate. This method is available to Lua scripts.
- `LGraphNode:getPushFilter`: Returns this node's optional push item-type filter.
- `LGraphNode:setPushFilter`: Sets or clears this node's push item-type filter.
- `LGraphNode:getPullFilter`: Returns this node's optional pull item-type filter.
- `LGraphNode:setPullFilter`: Sets or clears this node's pull item-type filter.
- `LGraphNode:getProcessTime`: Returns the processing time used by this node's conversions.
- `LGraphNode:setProcessTime`: Sets the processing time used by this node's conversions.
- `LGraphNode:isQueueEnabled`: Returns whether this node's explicit queue is enabled.
- `LGraphNode:setQueueEnabled`: Enables or disables this node's explicit queue.
- `LGraphNode:getQueueCapacity`: Returns this node's queue capacity.
- `LGraphNode:setQueueCapacity`: Sets this node's queue capacity. This method is available to Lua scripts.
- `LGraphNode:getQueueSize`: Returns the number of item ids currently queued at this node.
- `LGraphNode:getItems`: Returns item handles currently stored on this node.
- `LGraphNode:getEdges`: Returns edge handles connected to this node in the requested direction.
- `LGraphNode:setConversion`: Configures an item conversion rule on this node.
- `LGraphNode:clearConversion`: Removes a conversion rule by input item type.
- `LGraphNode:clearAllConversions`: Removes every conversion rule from this node.
- `LGraphNode:addTag`: Adds a tag to this node. This method is available to Lua scripts.
- `LGraphNode:removeTag`: Removes a tag from this node. This method is available to Lua scripts.
- `LGraphNode:hasTag`: Returns whether this node has a tag.
- `LGraphNode:clearTags`: Removes every tag from this node. This method is available to Lua scripts.
- `LGraphNode:getTags`: Returns all tags assigned to this node.
- `LGraphNode:addSupply`: Adds supply quantity for an item type on this node.
- `LGraphNode:removeSupply`: Removes supply entry for an item type from this node.
- `LGraphNode:clearSupplies`: Removes every supply entry from this node.
- `LGraphNode:addDemand`: Adds demand quantity and optional priority for an item type on this node.
- `LGraphNode:removeDemand`: Removes demand entry for an item type from this node.
- `LGraphNode:clearDemands`: Removes every demand entry from this node.
- `LGraphNode:enqueue`: Adds an item handle to this node's explicit queue.
- `LGraphNode:dequeue`: Removes and returns the next item from this node's explicit queue.
- `LGraphNode:type`: Returns the Lua-visible type name for this graph node handle.
- `LGraphNode:typeOf`: Returns whether this graph node handle matches a supported type name.

## References

- `image`: Imports or references `image` from `src/image/`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- Keep this module reference synchronized with `src/graph/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
