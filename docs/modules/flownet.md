# Flownet

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

## Functions

*No standalone module functions documented.*

## Module Fields

*No module-level fields documented.*

## Callbacks

*No callback parameters documented in this module.*

## Enums

*No module-specific enums documented.*

## Types

- [LGraph](#lgraph)
- [LGraphEdge](#lgraphedge)
- [LGraphItem](#lgraphitem)
- [LGraphNode](#lgraphnode)

## LGraph

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LGraph:addEdge`

Creates an edge between two nodes with an optional edge type.

```lua
LGraph:addEdge(from_ud, to_ud, edge_type)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from_ud` | [LGraphNode](#lgraphnode) | Source node handle. |
| `to_ud` | [LGraphNode](#lgraphnode) | Destination node handle. |
| `edge_type?` | string | Edge type. |

**Returns**

| Type | Description |
|------|-------------|
| [LGraphEdge](#lgraphedge) | New edge handle. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a = g:addNode("src")
    local b = g:addNode("dst")
    local e = g:addEdge(a, b, "road")
    example_print_log("edge type = " .. e:type())
end
```

---

#### `LGraph:addEdgeUnchecked`

Adds an edge without validating endpoint nodes exist. Faster for batch construction.

```lua
LGraph:addEdgeUnchecked(from_ud, to_ud, edge_type)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from_ud` | [LGraphNode](#lgraphnode) | Source node handle. |
| `to_ud` | [LGraphNode](#lgraphnode) | Destination node handle. |
| `edge_type?` | string | Edge type. |

**Returns**

| Type | Description |
|------|-------------|
| [LGraphEdge](#lgraphedge) | New edge handle. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a = g:addNode("hub")
    local b = g:addNode("sink")
    local edge = g:addEdgeUnchecked(a, b, "belt")
    example_print_log("edge type = " .. edge:getType())
    example_print_log("edge count = " .. g:getEdgeCount())
end
```

---

#### `LGraph:addItem`

Places an item onto a destination node.

```lua
LGraph:addItem(item_ud, node_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `item_ud` | [LGraphItem](#lgraphitem) | Item handle to place. |
| `node_ud` | [LGraphNode](#lgraphnode) | Destination node handle. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("storage")
    local item = g:createItem("wood")
    g:addItem(item, n)
    example_print_log("item placed on node")
end
```

---

#### `LGraph:addNode`

Creates a node with optional type and capacity.

```lua
LGraph:addNode(node_type, capacity)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `node_type?` | string | Node type, defaulting to `default`. |
| `capacity?` | number | Capacity, defaulting to -1. |

**Returns**

| Type | Description |
|------|-------------|
| [LGraphNode](#lgraphnode) | New node handle. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local source = g:addNode("warehouse", 100)
    local sink = g:addNode("factory", 40)
    local edge = g:addEdge(source, sink, "road")
    local source_type = source:getType()
    flownet_log("added " .. source_type .. " linked by " .. edge:getType() .. " to " .. sink:getType())
end
```

---

#### `LGraph:astar`

Runs A* pathfinding between two nodes.

```lua
LGraph:astar(from_node, to_node)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from_node` | [LGraphNode](#lgraphnode) | Start node handle. |
| `to_node` | [LGraphNode](#lgraphnode) | Target node handle. |

**Returns**

| Type | Description |
|------|-------------|
| [LGraphNode](#lgraphnode)[] | `[LGraphNode](#lgraphnode)` handles along the path, or nil when no path exists. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addEdge(a, b)
    local path = g:astar(a, b)
    example_print_log("astar path = " .. tostring(path ~= nil))
end
```

---

#### `LGraph:batchAddEdges`

Creates multiple edges from a table of {from_id, to_id} or {from_id, to_id, edge_type} entries.

```lua
LGraph:batchAddEdges(edges)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `edges` | table | Array of sub-tables with node IDs and optional edge type. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array of new edge IDs. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local ids = g:batchAddNodes(3, { node_type = "router" })
    local edge_ids = g:batchAddEdges({
        { ids[1], ids[2], "lane" },
        { ids[2], ids[3], "lane" },
    })
    example_print_log("created edges = " .. #edge_ids)
    example_print_log("edge count = " .. g:getEdgeCount())
end
```

---

#### `LGraph:batchAddNodes`

Creates multiple nodes at once, returning their IDs as a table.

```lua
LGraph:batchAddNodes(count, config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | number | Number of nodes to create. |
| `config?` | table | Optional shared config: node_type (string?), capacity (integer?). |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array of new node IDs. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local ids = g:batchAddNodes(3, { node_type = "router", capacity = 4 })
    local nodes = g:getNodes()
    example_print_log("created ids = " .. #ids)
    example_print_log("node count = " .. g:getNodeCount())
    example_print_log("first node type = " .. nodes[1]:getType())
end
```

---

#### `LGraph:batchStep`

Runs multiple simulation steps in sequence. More efficient than calling step() in a loop from Lua.

```lua
LGraph:batchStep(dt, iterations)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Delta time per step. |
| `iterations` | number | Number of steps to run. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local ids = g:batchAddNodes(2, { node_type = "router" })
    g:batchAddEdges({
        { ids[1], ids[2], "lane" },
    })
    g:batchStep(0.25, 4)
    example_print_log("node count = " .. g:getNodeCount())
    example_print_log("edge count = " .. g:getEdgeCount())
end
```

---

#### `LGraph:colorGraph`

Computes graph coloring and returns color indices by node id.

```lua
LGraph:colorGraph()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Map table from node id (integer key) to color index (integer). |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addEdge(a, b)
    local colors = g:colorGraph()
    example_print_log("coloring type = " .. type(colors))
end
```

---

#### `LGraph:createItem`

Creates an unplaced graph item with optional type and decay time.

```lua
LGraph:createItem(item_type, decay_time)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `item_type?` | string | Item type, defaulting to `default`. |
| `decay_time?` | number | Decay lifetime, defaulting to -1.0. |

**Returns**

| Type | Description |
|------|-------------|
| [LGraphItem](#lgraphitem) | New graph item handle. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local store = g:addNode("storage", 8)
    local item = g:createItem("ore", 10.0)
    g:addItem(item, store)
    local kind = item:getType()
    flownet_log("created " .. kind .. " for " .. store:getType())
end
```

---

#### `LGraph:findPath`

Finds a path between two graph nodes.

```lua
LGraph:findPath(from_ud, to_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from_ud` | [LGraphNode](#lgraphnode) | Start node handle. |
| `to_ud` | [LGraphNode](#lgraphnode) | Target node handle. |

**Returns**

| Type | Description |
|------|-------------|
| LGraphFindPathResult | Path result table with nodes, edges, and cost, or nil when no path exists. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b, c = g:addNode(), g:addNode(), g:addNode()
    g:addEdge(a, b)
    g:addEdge(b, c)
    local result = g:findPath(a, c)
    example_print_log("path found = " .. tostring(result ~= nil))
end
```

---

#### `LGraph:findPathForItem`

Finds a path for a specific item between two nodes while respecting item constraints.

```lua
LGraph:findPathForItem(item_ud, from_ud, to_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `item_ud` | [LGraphItem](#lgraphitem) | Item handle used for routing constraints. |
| `from_ud` | [LGraphNode](#lgraphnode) | Start node handle. |
| `to_ud` | [LGraphNode](#lgraphnode) | Target node handle. |

**Returns**

| Type | Description |
|------|-------------|
| LGraphFindPathForItemResult | Path result table with nodes, edges, and cost, or nil when no path exists. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addEdge(a, b)
    local item = g:createItem("cargo")
    local result = g:findPathForItem(item, a, b)
    example_print_log("item path found = " .. tostring(result ~= nil))
end
```

---

#### `LGraph:getComponents`

Returns connected components as arrays of node handles.

```lua
LGraph:getComponents()
```

**Returns**

| Type | Description |
|------|-------------|
| [LGraphNode](#lgraphnode)[] | Component tables containing `[LGraphNode](#lgraphnode)` handles. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    g:addNode()
    g:addNode()
    local comps = g:getComponents()
    example_print_log("components = " .. #comps)
end
```

---

#### `LGraph:getDistance`

Returns graph distance between two nodes when reachable.

```lua
LGraph:getDistance(from_ud, to_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from_ud` | [LGraphNode](#lgraphnode) | Start node handle. |
| `to_ud` | [LGraphNode](#lgraphnode) | Target node handle. |

**Returns**

| Type | Description |
|------|-------------|
| number | Distance between the two nodes, or nil when no path connects the nodes. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addEdge(a, b)
    local d = g:getDistance(a, b)
    example_print_log("distance = " .. tostring(d))
end
```

---

#### `LGraph:getEdgeBetween`

Returns the edge connecting two nodes when one exists.

```lua
LGraph:getEdgeBetween(from_ud, to_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from_ud` | [LGraphNode](#lgraphnode) | Source node handle. |
| `to_ud` | [LGraphNode](#lgraphnode) | Destination node handle. |

**Returns**

| Type | Description |
|------|-------------|
| [LGraphEdge](#lgraphedge) | Edge handle connecting the two nodes, or nil when no edge connects the nodes. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addEdge(a, b, "pipe")
    local e = g:getEdgeBetween(a, b)
    example_print_log("edge between a-b exists = " .. tostring(e ~= nil))
end
```

---

#### `LGraph:getEdgeCount`

Returns the number of edges in this graph.

```lua
LGraph:getEdgeCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Edge count. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    g:addEdge(a, b)
    example_print_log("edges = " .. g:getEdgeCount())
end
```

---

#### `LGraph:getEdges`

Returns all edges in this logistics graph.

```lua
LGraph:getEdges()
```

**Returns**

| Type | Description |
|------|-------------|
| [LGraphEdge](#lgraphedge)[] | `[LGraphEdge](#lgraphedge)` handles. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addEdge(a, b)
    local edges = g:getEdges()
    example_print_log("edge list = " .. #edges)
end
```

---

#### `LGraph:getItemCount`

Returns the number of items in this graph.

```lua
LGraph:getItemCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Item count. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local storage = g:addNode("storage", 12)
    g:addItem(g:createItem("iron"), storage)
    g:addItem(g:createItem("coal"), storage)
    local count = g:getItemCount()
    flownet_log("inventory items=" .. count)
end
```

---

#### `LGraph:getItems`

Returns all items in this logistics graph.

```lua
LGraph:getItems()
```

**Returns**

| Type | Description |
|------|-------------|
| [LGraphItem](#lgraphitem)[] | `[LGraphItem](#lgraphitem)` handles. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local storage = g:addNode("storage", 12)
    g:addItem(g:createItem("iron"), storage)
    g:addItem(g:createItem("copper"), storage)
    local items = g:getItems()
    local first_type = items[1] and items[1]:getType() or "none"
    flownet_log("item list=" .. #items .. " first=" .. first_type)
end
```

---

#### `LGraph:getNeighbors`

Returns neighbor nodes connected to a node.

```lua
LGraph:getNeighbors(node_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `node_ud` | [LGraphNode](#lgraphnode) | Node handle to inspect. |

**Returns**

| Type | Description |
|------|-------------|
| [LGraphNode](#lgraphnode)[] | Neighboring `[LGraphNode](#lgraphnode)` handles. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b, c = g:addNode(), g:addNode(), g:addNode()
    g:addEdge(a, b)
    g:addEdge(a, c)
    local neighbors = g:getNeighbors(a)
    example_print_log("neighbors of a = " .. #neighbors)
end
```

---

#### `LGraph:getNodeCount`

Returns the number of nodes in this graph.

```lua
LGraph:getNodeCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Node count. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    g:addNode("mine", 8)
    g:addNode("smelter", 8)
    g:addNode("warehouse", 16)
    local count = g:getNodeCount()
    flownet_log("factory line nodes=" .. count)
end
```

---

#### `LGraph:getNodes`

Returns all nodes in this logistics graph.

```lua
LGraph:getNodes()
```

**Returns**

| Type | Description |
|------|-------------|
| [LGraphNode](#lgraphnode)[] | `[LGraphNode](#lgraphnode)` handles. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    g:addNode("x")
    g:addNode("y")
    local nodes = g:getNodes()
    example_print_log("node list = " .. #nodes)
end
```

---

#### `LGraph:getReachable`

Returns nodes reachable from a start node within an optional maximum distance.

```lua
LGraph:getReachable(from_ud, max_dist)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from_ud` | [LGraphNode](#lgraphnode) | Start node handle. |
| `max_dist?` | number | Maximum distance. |

**Returns**

| Type | Description |
|------|-------------|
| [LGraphNode](#lgraphnode)[] | Reachable `[LGraphNode](#lgraphnode)` handles. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addEdge(a, b)
    local reachable = g:getReachable(a, 5.0)
    example_print_log("reachable = " .. #reachable)
end
```

---

#### `LGraph:getStats`

Returns graph counts and aggregate supply-demand statistics.

```lua
LGraph:getStats()
```

**Returns**

| Type | Description |
|------|-------------|
| LGraphGetStatsResult | Table with node, edge, item, activity, transit, demand, supply, and queue counts. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    g:addNode()
    g:addNode()
    local stats = g:getStats()
    example_print_log("nodes=" .. stats.nodes .. " edges=" .. stats.edges .. " items=" .. stats.items)
end
```

---

#### `LGraph:hasCycle`

Returns whether this graph contains a cycle.

```lua
LGraph:hasCycle()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the graph has a cycle. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addEdge(a, b)
    g:addEdge(b, a)
    example_print_log("has cycle = " .. tostring(g:hasCycle()))
end
```

---

#### `LGraph:hasEdge`

Returns whether an edge handle still exists in this graph.

```lua
LGraph:hasEdge(edge_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `edge_ud` | [LGraphEdge](#lgraphedge) | Edge handle to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the edge exists. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    example_print_log("has edge = " .. tostring(g:hasEdge(e)))
end
```

---

#### `LGraph:hasItem`

Returns whether an item handle still exists in this graph.

```lua
LGraph:hasItem(item_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `item_ud` | [LGraphItem](#lgraphitem) | Item handle to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the item exists. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local store = g:addNode("store", 4)
    local item = g:createItem("parcel")
    g:addItem(item, store)
    local present = g:hasItem(item)
    flownet_log("parcel tracked=" .. tostring(present) .. " items=" .. g:getItemCount())
end
```

---

#### `LGraph:hasNode`

Returns whether a node handle still exists in this graph.

```lua
LGraph:hasNode(node_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `node_ud` | [LGraphNode](#lgraphnode) | Node handle to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the node exists. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("source", 8)
    g:addNode("sink", 8)
    local present = g:hasNode(n)
    local count = g:getNodeCount()
    flownet_log("source present=" .. tostring(present) .. " node count=" .. count)
end
```

---

#### `LGraph:isBipartite`

Returns whether this graph is bipartite.

```lua
LGraph:isBipartite()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the graph is bipartite. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    g:addEdge(a, b)
    example_print_log("bipartite = " .. tostring(g:isBipartite()))
end
```

---

#### `LGraph:mst`

Computes a minimum spanning tree using Kruskal and returns edge ids.

```lua
LGraph:mst()
```

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array table of edge ids included in the tree. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b, c = g:addNode(), g:addNode(), g:addNode()
    g:addEdge(a, b)
    g:addEdge(b, c)
    g:addEdge(a, c)
    local tree = g:mst()
    example_print_log("MST edges = " .. #tree)
end
```

---

#### `LGraph:on`

Registers a callback for a named graph event generated during simulation.

```lua
LGraph:on(event_name, func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `event_name` | string | Event name from the valid graph event list. |
| `func` | function | Lua callback invoked with event-specific handles and values. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    g:on("itemEnter", function(item, node)
        example_print_log("item arrived at node")
    end)
    example_print_log("callback registered")
end
```

---

#### `LGraph:processDemand`

Processes graph supply and demand once and dispatches generated callbacks.

```lua
LGraph:processDemand()
```

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local mine = g:addNode("mine", 8)
    local factory = g:addNode("factory", 8)
    g:addEdge(mine, factory, "belt")
    g:processDemand()
    flownet_log("demand pass scanned " .. g:getEdgeCount() .. " edge(s)")
end
```

---

#### `LGraph:removeEdge`

Removes an edge by handle on this object.

```lua
LGraph:removeEdge(edge_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `edge_ud` | [LGraphEdge](#lgraphedge) | Edge handle to remove. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the edge was removed. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    local ok = g:removeEdge(e)
    example_print_log("removed edge = " .. tostring(ok))
end
```

---

#### `LGraph:removeItem`

Removes an item from this logistics graph.

```lua
LGraph:removeItem(item_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `item_ud` | [LGraphItem](#lgraphitem) | Item handle to remove. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the item was removed. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local junkyard = g:addNode("junkyard", 8)
    local item = g:createItem("scrap")
    g:addItem(item, junkyard)
    local ok = g:removeItem(item)
    local remaining = g:getItemCount()
    flownet_log("removed scrap=" .. tostring(ok) .. " items=" .. remaining)
end
```

---

#### `LGraph:removeNode`

Removes a node and graph links associated with it.

```lua
LGraph:removeNode(node_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `node_ud` | [LGraphNode](#lgraphnode) | Node handle to remove. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the node was removed. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("buffer", 4)
    g:addNode("sink", 4)
    local ok = g:removeNode(n)
    local remaining = g:getNodeCount()
    flownet_log("removed buffer=" .. tostring(ok) .. " remaining=" .. remaining)
end
```

---

#### `LGraph:sendItem`

Starts moving an item along an edge.

```lua
LGraph:sendItem(item_ud, edge_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `item_ud` | [LGraphItem](#lgraphitem) | Item handle to send. |
| `edge_ud` | [LGraphEdge](#lgraphedge) | Edge handle to traverse. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e, item = g:addEdge(a, b), g:createItem("package")
    g:addItem(item, a)
    g:sendItem(item, e)
    example_print_log("item sent along edge")
end
```

---

#### `LGraph:step`

Runs one discrete graph simulation step and dispatches generated callbacks.

```lua
LGraph:step()
```

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local mine = g:addNode("mine", 8)
    local factory = g:addNode("factory", 8)
    g:addEdge(mine, factory, "belt")
    g:step()
    flownet_log("step processed " .. g:getNodeCount() .. " nodes")
end
```

---

#### `LGraph:subgraph`

Creates a new graph containing a subset of nodes.

```lua
LGraph:subgraph(nodes)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `nodes` | table | Array table of `[LGraphNode](#lgraphnode)` handles to include. |

**Returns**

| Type | Description |
|------|-------------|
| [LGraph](#lgraph) | New subgraph handle. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addNode()
    local sub = g:subgraph({a, b})
    example_print_log("subgraph nodes = " .. sub:getNodeCount())
end
```

---

#### `LGraph:tickParallel`

Advances graph simulation through the parallel update path and dispatches generated callbacks.

```lua
LGraph:tickParallel(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Delta time in seconds. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local mine = g:addNode("mine", 8)
    local factory = g:addNode("factory", 8)
    g:addEdge(mine, factory, "belt")
    g:tickParallel(0.016)
    flownet_log("parallel tick ran on " .. g:getNodeCount() .. " nodes")
end
```

---

#### `LGraph:topologicalSort`

Returns nodes in topological order when the graph is acyclic.

```lua
LGraph:topologicalSort()
```

**Returns**

| Type | Description |
|------|-------------|
| [LGraphNode](#lgraphnode)[] | `[LGraphNode](#lgraphnode)` handles in topological order, or nil when sorting is impossible due to cycles. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b, c = g:addNode(), g:addNode(), g:addNode()
    g:addEdge(a, b)
    g:addEdge(b, c)
    local sorted = g:topologicalSort()
    example_print_log("topo sort = " .. tostring(sorted ~= nil))
end
```

---

#### `LGraph:type`

Returns the Lua-visible type name for this graph handle.

```lua
LGraph:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LGraph](#lgraph)`. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local mine = g:addNode("mine", 8)
    g:addNode("depot", 8)
    local type_name = g:type()
    local present = g:hasNode(mine)
    flownet_log(type_name .. " tracks source=" .. tostring(present))
end
```

---

#### `LGraph:typeOf`

Returns whether this graph handle matches a supported type name.

```lua
LGraph:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LGraph](#lgraph)`, `Graph`, and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local mine = g:addNode("mine", 8)
    local is_graph = g:typeOf("LGraph")
    local is_object = g:typeOf("LObject")
    local node_count = g:getNodeCount()
    flownet_log("typeOf graph=" .. tostring(is_graph) .. " object=" .. tostring(is_object) .. " nodes=" .. node_count)
end
```

---

#### `LGraph:update`

Advances graph simulation by delta time and dispatches generated callbacks.

```lua
LGraph:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Delta time in seconds. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local mine = g:addNode("mine", 8)
    local factory = g:addNode("factory", 8)
    g:addEdge(mine, factory, "belt")
    g:update(0.016)
    flownet_log("update advanced " .. g:getEdgeCount() .. " edge(s)")
end
```

---

## LGraphEdge

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LGraphEdge:addAllowedType`

Allows an item type to traverse this edge.

```lua
LGraphEdge:addAllowedType(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | string | Item type to allow. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:addAllowedType("iron")
    example_print_log("iron allowed")
end
```

---

#### `LGraphEdge:clearAllowedTypes`

Clears this edge's item type allow-list.

```lua
LGraphEdge:clearAllowedTypes()
```

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:addAllowedType("x")
    e:clearAllowedTypes()
    example_print_log("allow list cleared")
end
```

---

#### `LGraphEdge:clearCapacityReservations`

Removes every transit capacity reservation from this edge.

```lua
LGraphEdge:clearCapacityReservations()
```

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    e:setCapacity(4)
    e:reserveCapacity("planner-a", 2)
    e:clearCapacityReservations()
    example_print_log("reserved capacity = " .. e:getReservedCapacity())
end
```

---

#### `LGraphEdge:getAvailableCapacity`

Returns how many transit slots remain after active items and reservations, or -1 when unlimited.

```lua
LGraphEdge:getAvailableCapacity()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Available transit slots, or -1 when the edge capacity is unlimited. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    e:setCapacity(4)
    e:reserveCapacity("planner-a", 2)
    example_print_log("available capacity = " .. e:getAvailableCapacity())
end
```

---

#### `LGraphEdge:getCapacity`

Returns this edge's maximum concurrent item capacity.

```lua
LGraphEdge:getCapacity()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Edge capacity. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    example_print_log("capacity = " .. e:getCapacity())
end
```

---

#### `LGraphEdge:getCooldown`

Returns this edge's cooldown timer value.

```lua
LGraphEdge:getCooldown()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Cooldown in seconds. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    example_print_log("cooldown = " .. e:getCooldown())
end
```

---

#### `LGraphEdge:getFrom`

Returns the source node for this edge.

```lua
LGraphEdge:getFrom()
```

**Returns**

| Type | Description |
|------|-------------|
| [LGraphNode](#lgraphnode) | Source node handle. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode("src"), g:addNode("dst")
    local e = g:addEdge(a, b)
    local from = e:getFrom()
    example_print_log("from type = " .. from:getType())
end
```

---

#### `LGraphEdge:getItemsInTransit`

Returns graph items currently traveling along this edge.

```lua
LGraphEdge:getItemsInTransit()
```

**Returns**

| Type | Description |
|------|-------------|
| [LGraphItem](#lgraphitem)[] | `[LGraphItem](#lgraphitem)` handles. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    local items = e:getItemsInTransit()
    example_print_log("in transit = " .. #items)
end
```

---

#### `LGraphEdge:getReservedCapacity`

Returns the total transit capacity reserved on this edge across all reservation keys.

```lua
LGraphEdge:getReservedCapacity()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Reserved transit slot count. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    e:setCapacity(4)
    e:reserveCapacity("planner-a", 2)
    example_print_log("reserved capacity = " .. e:getReservedCapacity())
end
```

---

#### `LGraphEdge:getSpeedModifier`

Returns this edge's speed modifier.

```lua
LGraphEdge:getSpeedModifier()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Speed modifier. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    example_print_log("speed mod = " .. e:getSpeedModifier())
end
```

---

#### `LGraphEdge:getThroughput`

Returns this edge's throughput value.

```lua
LGraphEdge:getThroughput()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current throughput. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    example_print_log("throughput = " .. e:getThroughput())
end
```

---

#### `LGraphEdge:getTo`

Returns the destination node for this edge.

```lua
LGraphEdge:getTo()
```

**Returns**

| Type | Description |
|------|-------------|
| [LGraphNode](#lgraphnode) | Destination node handle. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode("target")
    local e = g:addEdge(a, b)
    local to = e:getTo()
    example_print_log("to type = " .. to:getType())
end
```

---

#### `LGraphEdge:getTravelTime`

Returns the travel time for items moving across this edge.

```lua
LGraphEdge:getTravelTime()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Travel time in seconds. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    example_print_log("travel time = " .. e:getTravelTime())
end
```

---

#### `LGraphEdge:getType`

Returns the edge type string used by routing and filters.

```lua
LGraphEdge:getType()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Current edge type. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b, "conveyor")
    example_print_log("edge type = " .. e:getType())
end
```

---

#### `LGraphEdge:getWeight`

Returns the pathfinding weight for this edge.

```lua
LGraphEdge:getWeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Edge weight. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    example_print_log("weight = " .. e:getWeight())
end
```

---

#### `LGraphEdge:isActive`

Returns whether this edge is active for routing and simulation.

```lua
LGraphEdge:isActive()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the edge is active. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    example_print_log("active = " .. tostring(e:isActive()))
end
```

---

#### `LGraphEdge:isBidirectional`

Returns whether this edge allows travel in both directions.

```lua
LGraphEdge:isBidirectional()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the edge is bidirectional. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    example_print_log("bidi = " .. tostring(e:isBidirectional()))
end
```

---

#### `LGraphEdge:isItemTypeAllowed`

Returns whether an item type may traverse this edge.

```lua
LGraphEdge:isItemTypeAllowed(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | string | Item type to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the item type is allowed. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:addAllowedType("gold")
    example_print_log("gold allowed = " .. tostring(e:isItemTypeAllowed("gold")))
end
```

---

#### `LGraphEdge:isOnCooldown`

Returns whether this edge is currently on cooldown.

```lua
LGraphEdge:isOnCooldown()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when cooldown is active. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    example_print_log("on cooldown = " .. tostring(e:isOnCooldown()))
end
```

---

#### `LGraphEdge:releaseCapacityReservation`

Releases reserved transit capacity for a key and returns the number of slots removed.

```lua
LGraphEdge:releaseCapacityReservation(key, slots)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | Reservation key to release. |
| `slots?` | number | Number of slots to release, defaulting to all slots for that key. |

**Returns**

| Type | Description |
|------|-------------|
| number | Number of slots actually released. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    e:setCapacity(4)
    e:reserveCapacity("planner-a", 2)
    local released = e:releaseCapacityReservation("planner-a", 1)
    example_print_log("released slots = " .. released)
end
```

---

#### `LGraphEdge:removeAllowedType`

Removes an item type from this edge's allow-list.

```lua
LGraphEdge:removeAllowedType(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | string | Item type to remove. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the type was present. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:addAllowedType("coal")
    local ok = e:removeAllowedType("coal")
    example_print_log("removed = " .. tostring(ok))
end
```

---

#### `LGraphEdge:reserveCapacity`

Reserves transit capacity slots under a caller-provided key for planning and coordination.

```lua
LGraphEdge:reserveCapacity(key, slots)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | Reservation key used to group planner-owned capacity holds. |
| `slots?` | number | Number of slots to reserve, defaulting to 1. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the reservation fit within currently available capacity. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    e:setCapacity(4)
    local ok = e:reserveCapacity("planner-a", 2)
    example_print_log("reservation accepted = " .. tostring(ok))
end
```

---

#### `LGraphEdge:setActive`

Enables or disables this edge for routing and simulation.

```lua
LGraphEdge:setActive(a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `a` | boolean | New active flag. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:setActive(false)
    example_print_log("active = " .. tostring(e:isActive()))
end
```

---

#### `LGraphEdge:setBidirectional`

Sets whether this edge allows travel in both directions.

```lua
LGraphEdge:setBidirectional(b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `b` | boolean | New bidirectional flag. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:setBidirectional(true)
    example_print_log("bidi = " .. tostring(e:isBidirectional()))
end
```

---

#### `LGraphEdge:setCapacity`

Sets this edge's maximum concurrent item capacity.

```lua
LGraphEdge:setCapacity(c)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `c` | number | New edge capacity. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:setCapacity(10)
    example_print_log("capacity = " .. e:getCapacity())
end
```

---

#### `LGraphEdge:setCooldown`

Sets this edge's cooldown timer value.

```lua
LGraphEdge:setCooldown(c)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `c` | number | Cooldown in seconds. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:setCooldown(1.0)
    example_print_log("cooldown = " .. e:getCooldown())
end
```

---

#### `LGraphEdge:setSpeedModifier`

Sets this edge's speed modifier value.

```lua
LGraphEdge:setSpeedModifier(m)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `m` | number | Speed modifier. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:setSpeedModifier(2.0)
    example_print_log("speed mod = " .. e:getSpeedModifier())
end
```

---

#### `LGraphEdge:setThroughput`

Sets this edge's throughput value.

```lua
LGraphEdge:setThroughput(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | number | New throughput. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:setThroughput(100)
    example_print_log("throughput = " .. e:getThroughput())
end
```

---

#### `LGraphEdge:setTravelTime`

Sets the travel time for items moving across this edge.

```lua
LGraphEdge:setTravelTime(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | number | Travel time in seconds. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:setTravelTime(5.0)
    example_print_log("travel time = " .. e:getTravelTime())
end
```

---

#### `LGraphEdge:setType`

Sets the edge type string used by routing and filters.

```lua
LGraphEdge:setType(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | string | New edge type. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:setType("rail")
    example_print_log("edge type = " .. e:getType())
end
```

---

#### `LGraphEdge:setWeight`

Sets the pathfinding weight for this edge.

```lua
LGraphEdge:setWeight(w)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | number | Edge weight. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:setWeight(3.5)
    example_print_log("weight = " .. e:getWeight())
end
```

---

#### `LGraphEdge:type`

Returns the Lua-visible type name for this graph edge handle.

```lua
LGraphEdge:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LGraphEdge](#lgraphedge)`. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    example_print_log("type = " .. e:type())
end
```

---

#### `LGraphEdge:typeOf`

Returns whether this graph edge handle matches a supported type name.

```lua
LGraphEdge:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LGraphEdge](#lgraphedge)`, `GraphEdge`, and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    example_print_log("is GraphEdge = " .. tostring(e:typeOf("LGraphEdge")))
end
```

---

## LGraphItem

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LGraphItem:getDecayTime`

Returns the total decay lifetime configured for this item.

```lua
LGraphItem:getDecayTime()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Decay time in seconds, or the graph's sentinel for no decay. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local item = g:createItem("food", 30.0)
    local pantry = g:addNode("pantry", 6)
    g:addItem(item, pantry)
    local decay = item:getDecayTime()
    flownet_log("food decay=" .. decay)
end
```

---

#### `LGraphItem:getPosition`

Returns where this item is stored: a node, an edge plus progress, or no values when unplaced.

```lua
LGraphItem:getPosition()
```

**Returns**

| Type | Description |
|------|-------------|
| [LGraphNode](#lgraphnode) | Node handle when the item is at a node. |
| [LGraphEdge](#lgraphedge) | Edge handle when the item is in transit. |
| number | Transit progress when the item is in transit; or nil no value when the item is unplaced. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    local item = g:createItem("box")
    g:addItem(item, n)
    example_print_log("item is on a node = " .. tostring(item:getPosition() ~= nil))
end
```

---

#### `LGraphItem:getPriority`

Returns this item's routing or queue priority.

```lua
LGraphItem:getPriority()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Item priority. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local item = g:createItem("parcel")
    local storage = g:addNode("storage", 4)
    g:addItem(item, storage)
    local priority = item:getPriority()
    flownet_log("parcel priority=" .. priority)
end
```

---

#### `LGraphItem:getRemainingLife`

Returns this item's remaining lifetime before decay.

```lua
LGraphItem:getRemainingLife()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Remaining lifetime in seconds. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local item = g:createItem("milk", 10.0)
    local cooler = g:addNode("cooler", 6)
    g:addItem(item, cooler)
    local remaining = item:getRemainingLife()
    flownet_log("milk remaining=" .. remaining)
end
```

---

#### `LGraphItem:getType`

Returns the item type string used by filters, conversions, supplies, and demands.

```lua
LGraphItem:getType()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Current item type. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local item = g:createItem("ore")
    local storage = g:addNode("storage", 4)
    g:addItem(item, storage)
    local item_type = item:getType()
    flownet_log("item type=" .. item_type .. " on " .. storage:getType())
end
```

---

#### `LGraphItem:isAlive`

Returns whether this item is still alive in the graph simulation.

```lua
LGraphItem:isAlive()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the item has not decayed or been killed. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local item = g:createItem("drone_part")
    local store = g:addNode("store", 4)
    g:addItem(item, store)
    local alive = item:isAlive()
    flownet_log("drone part alive=" .. tostring(alive))
end
```

---

#### `LGraphItem:kill`

Marks this item as dead so graph processing can remove or ignore it.

```lua
LGraphItem:kill()
```

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local item = g:createItem("waste")
    local dump = g:addNode("dump", 4)
    g:addItem(item, dump)
    item:kill()
    local alive = item:isAlive()
    flownet_log("waste alive after kill=" .. tostring(alive))
end
```

---

#### `LGraphItem:setDecayTime`

Sets the total decay lifetime for this item.

```lua
LGraphItem:setDecayTime(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | number | Decay time in seconds, or the graph's sentinel for no decay. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local item = g:createItem("fruit")
    item:setDecayTime(60.0)
    local pantry = g:addNode("pantry", 6)
    g:addItem(item, pantry)
    local decay = item:getDecayTime()
    flownet_log("fruit decay=" .. decay)
end
```

---

#### `LGraphItem:setPriority`

Sets this item's routing or queue priority.

```lua
LGraphItem:setPriority(p)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `p` | number | New item priority. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local item = g:createItem("parcel")
    item:setPriority(5)
    local storage = g:addNode("storage", 4)
    g:addItem(item, storage)
    local priority = item:getPriority()
    flownet_log("rush order priority=" .. priority)
end
```

---

#### `LGraphItem:setType`

Changes the item type string used by graph routing and processing rules.

```lua
LGraphItem:setType(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | string | New item type. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local item = g:createItem("raw")
    item:setType("processed")
    local storage = g:addNode("storage", 4)
    g:addItem(item, storage)
    local item_type = item:getType()
    flownet_log("retagged item=" .. item_type)
end
```

---

#### `LGraphItem:type`

Returns the Lua-visible type name for this graph item handle.

```lua
LGraphItem:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LGraphItem](#lgraphitem)`. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local item = g:createItem("box")
    local store = g:addNode("store", 4)
    g:addItem(item, store)
    local type_name = item:type()
    flownet_log(type_name .. " item_type=" .. item:getType())
end
```

---

#### `LGraphItem:typeOf`

Returns whether this graph item handle matches a supported type name.

```lua
LGraphItem:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LGraphItem](#lgraphitem)`, `GraphItem`, and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local item = g:createItem("box")
    local store = g:addNode("store", 4)
    g:addItem(item, store)
    local is_item = item:typeOf("LGraphItem")
    flownet_log("item typeOf=" .. tostring(is_item) .. " alive=" .. tostring(item:isAlive()))
end
```

---

## LGraphNode

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LGraphNode:addDemand`

Adds demand quantity and optional priority for an item type on this node.

```lua
LGraphNode:addDemand(item_type, quantity, priority)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `item_type` | string | Item type demanded by the node. |
| `quantity` | number | Demand quantity to add. |
| `priority?` | number | Demand priority, defaulting to 0. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("factory")
    n:addDemand("iron", 5, 1)
    n:setPullRate(3)
    local stats = g:getStats()
    flownet_log("factory demand registered nodes=" .. stats.nodes .. " edges=" .. stats.edges)
end
```

---

#### `LGraphNode:addSupply`

Adds supply quantity for an item type on this node.

```lua
LGraphNode:addSupply(item_type, quantity)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `item_type` | string | Item type supplied by the node. |
| `quantity` | number | Supply quantity to add. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("mine")
    n:addSupply("iron", 10)
    n:setPushRate(4)
    local stats = g:getStats()
    flownet_log("mine supply registered on " .. n:getType() .. " nodes=" .. stats.nodes)
end
```

---

#### `LGraphNode:addTag`

Adds a tag to this node on this object.

```lua
LGraphNode:addTag(tag)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tag` | string | Tag to add. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addTag("important")
    n:setType("hub")
    local tags = n:getTags()
    flownet_log(n:getType() .. " tags=" .. #tags)
end
```

---

#### `LGraphNode:clearAllConversions`

Removes every conversion rule from this node.

```lua
LGraphNode:clearAllConversions()
```

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setConversion("a", "b")
    n:setConversion("c", "d")
    n:clearAllConversions()
    example_print_log("all conversions cleared")
end
```

---

#### `LGraphNode:clearCapacityReservations`

Removes every inventory capacity reservation from this node.

```lua
LGraphNode:clearCapacityReservations()
```

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("warehouse", 5)
    n:reserveCapacity("planner-a", 2)
    n:clearCapacityReservations()
    example_print_log("reserved capacity = " .. n:getReservedCapacity())
end
```

---

#### `LGraphNode:clearConversion`

Removes a conversion rule by input item type.

```lua
LGraphNode:clearConversion(in_type)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `in_type` | string | Input item type. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a conversion rule was removed. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setConversion("a", "b")
    local ok = n:clearConversion("a")
    example_print_log("cleared conversion = " .. tostring(ok))
end
```

---

#### `LGraphNode:clearDemands`

Removes every demand entry from this node.

```lua
LGraphNode:clearDemands()
```

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addDemand("x", 1)
    n:clearDemands()
    example_print_log("demands cleared")
end
```

---

#### `LGraphNode:clearSupplies`

Removes every supply entry from this node.

```lua
LGraphNode:clearSupplies()
```

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addSupply("a", 1)
    n:addSupply("b", 2)
    n:clearSupplies()
    example_print_log("supplies cleared")
end
```

---

#### `LGraphNode:clearTags`

Removes every tag from this graph node.

```lua
LGraphNode:clearTags()
```

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addTag("x")
    n:addTag("y")
    n:clearTags()
    example_print_log("tags cleared")
end
```

---

#### `LGraphNode:dequeue`

Removes and returns the next item from this node's explicit queue.

```lua
LGraphNode:dequeue()
```

**Returns**

| Type | Description |
|------|-------------|
| [LGraphItem](#lgraphitem) | Item handle from the queue, or nil when the queue is empty. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("buffer")
    n:setQueueEnabled(true)
    n:setQueueCapacity(5)
    local item = g:createItem("box")
    g:addItem(item, n)
    n:enqueue(item)
    local out = n:dequeue()
    example_print_log("queue size = " .. n:getQueueSize())
    example_print_log("dequeued = " .. tostring(out ~= nil))
end
```

---

#### `LGraphNode:enqueue`

Adds an item handle to this node's explicit queue.

```lua
LGraphNode:enqueue(item_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `item_ud` | [LGraphItem](#lgraphitem) | Item handle to enqueue. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the item was queued. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("buffer")
    n:setQueueEnabled(true)
    n:setQueueCapacity(5)
    local item = g:createItem("parcel")
    g:addItem(item, n)
    local queued = n:enqueue(item)
    example_print_log("queue size = " .. n:getQueueSize())
    example_print_log("enqueued = " .. tostring(queued))
end
```

---

#### `LGraphNode:getAvailableCapacity`

Returns how many node inventory slots remain after active items and reservations, or -1 when unlimited.

```lua
LGraphNode:getAvailableCapacity()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Available inventory slots, or -1 when the node capacity is unlimited. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("warehouse", 5)
    n:reserveCapacity("planner-a", 2)
    local free = n:getAvailableCapacity()
    local reserved = n:getReservedCapacity()
    flownet_log("warehouse free=" .. free .. " reserved=" .. reserved)
end
```

---

#### `LGraphNode:getCapacity`

Returns this node's item capacity.

```lua
LGraphNode:getCapacity()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Node capacity. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("store", 50)
    n:addTag("buffer")
    local capacity = n:getCapacity()
    local node_type = n:getType()
    flownet_log(node_type .. " capacity=" .. capacity)
end
```

---

#### `LGraphNode:getEdges`

Returns edge handles connected to this node in the requested direction.

```lua
LGraphNode:getEdges(dir)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dir?` | string | Direction string, defaulting to `both`. |

**Returns**

| Type | Description |
|------|-------------|
| [LGraphEdge](#lgraphedge)[] | `[LGraphEdge](#lgraphedge)` handles. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addEdge(a, b)
    local edges = a:getEdges("both")
    example_print_log("edges = " .. #edges)
end
```

---

#### `LGraphNode:getFlowMode`

Returns this node's flow mode name.

```lua
LGraphNode:getFlowMode()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Flow mode string. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("router")
    n:setPushRate(2)
    local mode = n:getFlowMode()
    flownet_log("router flow mode=" .. mode)
end
```

---

#### `LGraphNode:getItemCount`

Returns the number of items currently stored on this node.

```lua
LGraphNode:getItemCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Item count. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("stockpile", 4)
    g:addItem(g:createItem("ore"), n)
    g:addItem(g:createItem("coal"), n)
    local items = n:getItemCount()
    flownet_log("stockpile items=" .. items)
end
```

---

#### `LGraphNode:getItems`

Returns item handles currently stored on this node.

```lua
LGraphNode:getItems()
```

**Returns**

| Type | Description |
|------|-------------|
| [LGraphItem](#lgraphitem)[] | `[LGraphItem](#lgraphitem)` handles. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    g:addItem(g:createItem("ore"), n)
    local items = n:getItems()
    example_print_log("node items = " .. #items)
end
```

---

#### `LGraphNode:getOverflowPolicy`

Returns this node's overflow policy name.

```lua
LGraphNode:getOverflowPolicy()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Overflow policy string. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("buffer", 2)
    n:setQueueEnabled(true)
    local policy = n:getOverflowPolicy() or "reject"
    flownet_log("overflow policy=" .. tostring(policy))
end
```

---

#### `LGraphNode:getProcessTime`

Returns the processing time used by this node's conversions.

```lua
LGraphNode:getProcessTime()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Processing time in seconds. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("assembler")
    n:setConversion("plate", "gear", 2, 1)
    local process_time = n:getProcessTime()
    flownet_log("assembler process time=" .. process_time)
end
```

---

#### `LGraphNode:getPullFilter`

Returns this node's optional pull item-type filter.

```lua
LGraphNode:getPullFilter()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Filter string when a pull filter is set, or nil when no pull filter is set. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    local f = n:getPullFilter()
    n:setType("assembler")
    local node_type = n:getType()
    flownet_log(node_type .. " pull filter=" .. tostring(f))
end
```

---

#### `LGraphNode:getPullRate`

Returns this node's pull rate value.

```lua
LGraphNode:getPullRate()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Pull rate. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("factory")
    n:setFlowMode("pull")
    local pull_rate = n:getPullRate()
    flownet_log("pull rate=" .. pull_rate)
end
```

---

#### `LGraphNode:getPushFilter`

Returns this node's optional push item-type filter.

```lua
LGraphNode:getPushFilter()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Filter string when a push filter is set, or nil when no push filter is set. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    local f = n:getPushFilter()
    n:setType("mine")
    local node_type = n:getType()
    flownet_log(node_type .. " push filter=" .. tostring(f))
end
```

---

#### `LGraphNode:getPushRate`

Returns this node's push rate value.

```lua
LGraphNode:getPushRate()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Push rate. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("mine")
    n:setFlowMode("push")
    local push_rate = n:getPushRate()
    flownet_log("push rate=" .. push_rate)
end
```

---

#### `LGraphNode:getQueueCapacity`

Returns this node's queue capacity.

```lua
LGraphNode:getQueueCapacity()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Queue capacity. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("buffer")
    n:setQueueEnabled(true)
    local cap = n:getQueueCapacity()
    flownet_log("queue capacity=" .. cap)
end
```

---

#### `LGraphNode:getQueueSize`

Returns the number of item ids currently queued at this node.

```lua
LGraphNode:getQueueSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Queue size. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("buffer")
    n:setQueueEnabled(true)
    local queue_size = n:getQueueSize()
    flownet_log("queue size=" .. queue_size)
end
```

---

#### `LGraphNode:getReservedCapacity`

Returns the total item capacity reserved on this node across all reservation keys.

```lua
LGraphNode:getReservedCapacity()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Reserved node slot count. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("warehouse", 5)
    n:reserveCapacity("planner-a", 2)
    local reserved = n:getReservedCapacity()
    local free = n:getAvailableCapacity()
    flownet_log("reserved=" .. reserved .. " free=" .. free)
end
```

---

#### `LGraphNode:getTags`

Returns all tags assigned to this node.

```lua
LGraphNode:getTags()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Tag strings. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addTag("a")
    n:addTag("b")
    local tags = n:getTags()
    example_print_log("tags = " .. #tags)
end
```

---

#### `LGraphNode:getType`

Returns this node's type classification string.

```lua
LGraphNode:getType()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Current node type. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("factory")
    n:addTag("smelting")
    local node_type = n:getType()
    local tags = n:getTags()
    flownet_log("node type=" .. node_type .. " tags=" .. #tags)
end
```

---

#### `LGraphNode:hasTag`

Returns whether this node has a tag.

```lua
LGraphNode:hasTag(tag)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tag` | string | Tag to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the tag is present. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addTag("vip")
    n:addTag("priority")
    local has_vip = n:hasTag("vip")
    flownet_log("has vip=" .. tostring(has_vip) .. " tags=" .. #n:getTags())
end
```

---

#### `LGraphNode:isActive`

Returns whether this node is active for graph simulation.

```lua
LGraphNode:isActive()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the node is active. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setType("router")
    local active = n:isActive()
    local node_type = n:getType()
    flownet_log(node_type .. " active=" .. tostring(active))
end
```

---

#### `LGraphNode:isFull`

Returns whether this node has reached its item capacity.

```lua
LGraphNode:isFull()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the node is full. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("bin", 1)
    local item = g:createItem("crate")
    g:addItem(item, n)
    local full = n:isFull()
    flownet_log("bin full=" .. tostring(full) .. " items=" .. n:getItemCount())
end
```

---

#### `LGraphNode:isQueueEnabled`

Returns whether this node's explicit queue is enabled.

```lua
LGraphNode:isQueueEnabled()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when queueing is enabled. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("buffer")
    n:setQueueCapacity(4)
    local enabled = n:isQueueEnabled()
    flownet_log("queue enabled=" .. tostring(enabled) .. " cap=" .. n:getQueueCapacity())
end
```

---

#### `LGraphNode:releaseCapacityReservation`

Releases reserved node capacity for a key and returns the number of slots removed.

```lua
LGraphNode:releaseCapacityReservation(key, slots)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | Reservation key to release. |
| `slots?` | number | Number of slots to release, defaulting to all slots for that key. |

**Returns**

| Type | Description |
|------|-------------|
| number | Number of slots actually released. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("warehouse", 5)
    n:reserveCapacity("planner-a", 2)
    local released = n:releaseCapacityReservation("planner-a", 1)
    example_print_log("released slots = " .. released)
end
```

---

#### `LGraphNode:removeDemand`

Removes demand entry for an item type from this node.

```lua
LGraphNode:removeDemand(item_type)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `item_type` | string | Item type demand entry to remove. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when demand existed. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addDemand("coal", 3)
    local ok = n:removeDemand("coal")
    example_print_log("removed demand = " .. tostring(ok))
end
```

---

#### `LGraphNode:removeSupply`

Removes supply entry for an item type from this node.

```lua
LGraphNode:removeSupply(item_type)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `item_type` | string | Item type supply entry to remove. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when supply existed. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addSupply("wood", 5)
    local ok = n:removeSupply("wood")
    example_print_log("removed supply = " .. tostring(ok))
end
```

---

#### `LGraphNode:removeTag`

Removes a tag from this node on this object.

```lua
LGraphNode:removeTag(tag)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tag` | string | Tag to remove. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the tag was present. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addTag("temp")
    local ok = n:removeTag("temp")
    example_print_log("removed = " .. tostring(ok))
end
```

---

#### `LGraphNode:reserveCapacity`

Reserves node inventory capacity under a caller-provided key for planning and coordination.

```lua
LGraphNode:reserveCapacity(key, slots)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | Reservation key used to group planner-owned capacity holds. |
| `slots?` | number | Number of slots to reserve, defaulting to 1. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the reservation fit within currently available capacity. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("warehouse", 5)
    local ok = n:reserveCapacity("planner-a", 2)
    local reserved = n:getReservedCapacity()
    local free = n:getAvailableCapacity()
    flownet_log("reservation ok=" .. tostring(ok) .. " reserved=" .. reserved .. " free=" .. free)
end
```

---

#### `LGraphNode:setActive`

Enables or disables this node for graph simulation.

```lua
LGraphNode:setActive(a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `a` | boolean | New active flag. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setActive(false)
    n:setType("router")
    local active = n:isActive()
    flownet_log(n:getType() .. " active=" .. tostring(active))
end
```

---

#### `LGraphNode:setCapacity`

Sets this node's item capacity value.

```lua
LGraphNode:setCapacity(c)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `c` | number | New node capacity. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setCapacity(200)
    n:setType("depot")
    local capacity = n:getCapacity()
    flownet_log(n:getType() .. " capacity=" .. capacity)
end
```

---

#### `LGraphNode:setConversion`

Configures an item conversion rule on this node.

```lua
LGraphNode:setConversion(in_type, out_type, in_count, out_count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `in_type` | string | Input item type. |
| `out_type` | string | Output item type. |
| `in_count?` | number | Input count, defaulting to 1. |
| `out_count?` | number | Output count, defaulting to 1. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("smelter")
    n:setConversion("iron_ore", "iron_bar", 2, 1)
    n:setProcessTime(2.5)
    local process_time = n:getProcessTime()
    flownet_log("smelter converts ore -> bar in " .. process_time .. "s")
end
```

---

#### `LGraphNode:setFlowMode`

Sets this node's flow mode from a mode name.

```lua
LGraphNode:setFlowMode(m)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `m` | string | Flow mode string. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setFlowMode("push")
    n:setPushRate(5)
    local mode = n:getFlowMode()
    flownet_log("node flow mode=" .. mode .. " push=" .. n:getPushRate())
end
```

---

#### `LGraphNode:setOverflowPolicy`

Sets this node's overflow policy from a policy name.

```lua
LGraphNode:setOverflowPolicy(p)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `p` | string | Overflow policy string. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setOverflowPolicy("destroy")
    n:setCapacity(1)
    local policy = n:getOverflowPolicy() or "destroy"
    flownet_log("overflow policy=" .. tostring(policy) .. " cap=" .. n:getCapacity())
end
```

---

#### `LGraphNode:setProcessTime`

Sets the processing time used by this node's conversions.

```lua
LGraphNode:setProcessTime(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | number | Processing time in seconds. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setProcessTime(2.5)
    n:setConversion("ore", "ingot", 1, 1)
    local process_time = n:getProcessTime()
    flownet_log("custom process time=" .. process_time)
end
```

---

#### `LGraphNode:setPullFilter`

Sets or clears this node's pull item-type filter.

```lua
LGraphNode:setPullFilter(f)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `f?` | string | Item type filter string. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setPullFilter("wood")
    n:setPullRate(2)
    local filter = n:getPullFilter()
    flownet_log("pull filter=" .. tostring(filter) .. " rate=" .. n:getPullRate())
end
```

---

#### `LGraphNode:setPullRate`

Sets this node's pull rate for this object.

```lua
LGraphNode:setPullRate(r)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | number | New pull rate. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setPullRate(3)
    n:setFlowMode("pull")
    local pull_rate = n:getPullRate()
    flownet_log("configured pull rate=" .. pull_rate)
end
```

---

#### `LGraphNode:setPushFilter`

Sets or clears this node's push item-type filter.

```lua
LGraphNode:setPushFilter(f)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `f?` | string | Item type filter string. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setPushFilter("iron")
    n:setPushRate(4)
    local filter = n:getPushFilter()
    flownet_log("push filter=" .. tostring(filter) .. " rate=" .. n:getPushRate())
end
```

---

#### `LGraphNode:setPushRate`

Sets this node's push rate for this object.

```lua
LGraphNode:setPushRate(r)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | number | New push rate. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setPushRate(5)
    n:setFlowMode("push")
    local push_rate = n:getPushRate()
    flownet_log("configured push rate=" .. push_rate)
end
```

---

#### `LGraphNode:setQueueCapacity`

Sets this node's queue capacity value.

```lua
LGraphNode:setQueueCapacity(c)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `c` | number | Queue capacity. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setQueueCapacity(10)
    n:setQueueEnabled(true)
    local cap = n:getQueueCapacity()
    flownet_log("queue capacity=" .. cap)
end
```

---

#### `LGraphNode:setQueueEnabled`

Enables or disables this node's explicit queue.

```lua
LGraphNode:setQueueEnabled(e)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `e` | boolean | New queue enabled flag. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setQueueEnabled(true)
    n:setQueueCapacity(4)
    local enabled = n:isQueueEnabled()
    flownet_log("queue enabled=" .. tostring(enabled) .. " cap=" .. n:getQueueCapacity())
end
```

---

#### `LGraphNode:setType`

Sets this node's type string for this object.

```lua
LGraphNode:setType(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | string | New node type. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setType("warehouse")
    n:setCapacity(24)
    local node_type = n:getType()
    flownet_log("retagged node=" .. node_type .. " capacity=" .. n:getCapacity())
end
```

---

#### `LGraphNode:type`

Returns the Lua-visible type name for this graph node handle.

```lua
LGraphNode:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LGraphNode](#lgraphnode)`. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setType("terminal")
    local type_name = n:type()
    local node_type = n:getType()
    flownet_log(type_name .. " node_type=" .. node_type)
end
```

---

#### `LGraphNode:typeOf`

Returns whether this graph node handle matches a supported type name.

```lua
LGraphNode:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LGraphNode](#lgraphnode)`, `GraphNode`, and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setType("terminal")
    local is_node = n:typeOf("LGraphNode")
    local is_object = n:typeOf("LObject")
    flownet_log("node typeOf=" .. tostring(is_node) .. " object=" .. tostring(is_object))
end
```

---
