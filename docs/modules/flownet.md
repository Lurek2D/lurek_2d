# Flownet

- The `flownet` module is a powerful Foundations tier component designed to model directed flow-simulation networks.

Moving beyond simple data-structure graphs, this module simulates complex logistics and transportation systems where typed items physically travel through interconnected nodes. The central `Graph` structure utilizes highly efficient `HashMap` storage and maintains persistent adjacency indexes, enabling O(1) neighbor lookups and robust graph traversal.

The simulation is deeply systemic. Items (`GraphItem`) accumulate in node inventories and traverse directed edges (`Edge`). These edges are not merely logical links; they enforce strict constraints including transit capacities, cooldown timers, and item-type filters. Nodes (`Node`) possess configurable item capacities, explicit queueing systems, and distinct flow modes (passive, push, or pull). Furthermore, nodes can execute `ConversionRule`s—acting as economic factories that consume specific inputs to produce new typed outputs. To manage bottlenecks, nodes implement defined `OverflowPolicy` behaviors, dictating whether excess items are rejected, queued, or destroyed.

The module runs an intricate simulation pipeline (`step(dt)`) that processes item decay, executes conversion rules, matches supply against demand declarations, and progresses items along edges. To support this, the module includes a comprehensive suite of graph algorithms: A* and Dijkstra shortest-path searches, reachability flood-fills, connected component discovery, cycle detection, topological sorting, Kruskal's minimum spanning tree, and graph coloring. Pathfinding inherently respects edge constraints and item-type filters. For performance scalability, the simulation tick can be executed in parallel using multi-threading. The engine exposes this entire logistical framework, alongside event-driven callbacks for state transitions, to Lua scripts via the `lurek.graph.*` namespace.

## LGraph

### `LGraph:addEdge`

Creates an edge between two nodes with an optional edge type.

```lua
-- signature
LGraph:addEdge(from_ud, to_ud, edge_type)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from_ud` | `LGraphNode` | Source node handle. |
| `to_ud` | `LGraphNode` | Destination node handle. |
| `edge_type?` | `string` | Edge type. |

**Returns**

| Type | Description |
|------|-------------|
| `LGraphEdge` | New edge handle. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a = g:addNode("src")
    local b = g:addNode("dst")
    local e = g:addEdge(a, b, "road")
    print("edge type = " .. e:type())
end
```

---

### `LGraph:addEdgeUnchecked`

Adds an edge without validating endpoint nodes exist. Faster for batch construction.

```lua
-- signature
LGraph:addEdgeUnchecked(from_ud, to_ud, edge_type)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from_ud` | `LGraphNode` | Source node handle. |
| `to_ud` | `LGraphNode` | Destination node handle. |
| `edge_type?` | `string` | Edge type. |

**Returns**

| Type | Description |
|------|-------------|
| `LGraphEdge` | New edge handle. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a = g:addNode("hub")
    local b = g:addNode("sink")
    local edge = g:addEdgeUnchecked(a, b, "belt")
    print("edge type = " .. edge:getType())
    print("edge count = " .. g:getEdgeCount())
end
```

---

### `LGraph:addItem`

Places an item onto a destination node.

```lua
-- signature
LGraph:addItem(item_ud, node_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `item_ud` | `LGraphItem` | Item handle to place. |
| `node_ud` | `LGraphNode` | Destination node handle. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("storage")
    local item = g:createItem("wood")
    g:addItem(item, n)
    print("item placed on node")
end
```

---

### `LGraph:addNode`

Creates a node with optional type and capacity.

```lua
-- signature
LGraph:addNode(node_type, capacity)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `node_type?` | `string` | Node type, defaulting to `default`. |
| `capacity?` | `number` | Capacity, defaulting to -1. |

**Returns**

| Type | Description |
|------|-------------|
| `LGraphNode` | New node handle. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("warehouse", 100)
    print("node type = " .. n:type())
end
```

---

### `LGraph:astar`

Runs A* pathfinding between two nodes.

```lua
-- signature
LGraph:astar(from_node, to_node)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from_node` | `LGraphNode` | Start node handle. |
| `to_node` | `LGraphNode` | Target node handle. |

**Returns**

| Type | Description |
|------|-------------|
| `LGraphNode[]` | `LGraphNode` handles along the path, or nil when no path exists. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addEdge(a, b)
    local path = g:astar(a, b)
    print("astar path = " .. tostring(path ~= nil))
end
```

---

### `LGraph:batchAddEdges`

Creates multiple edges from a table of {from_id, to_id} or {from_id, to_id, edge_type} entries.

```lua
-- signature
LGraph:batchAddEdges(edges)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `edges` | `table` | Array of sub-tables with node IDs and optional edge type. |

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Array of new edge IDs. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local ids = g:batchAddNodes(3, { node_type = "router" })
    local edge_ids = g:batchAddEdges({
        { ids[1], ids[2], "lane" },
        { ids[2], ids[3], "lane" },
    })
    print("created edges = " .. #edge_ids)
    print("edge count = " .. g:getEdgeCount())
end
```

---

### `LGraph:batchAddNodes`

Creates multiple nodes at once, returning their IDs as a table.

```lua
-- signature
LGraph:batchAddNodes(count, config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | `number` | Number of nodes to create. |
| `config?` | `table` | Optional shared config: node_type (string?), capacity (integer?). |

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Array of new node IDs. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local ids = g:batchAddNodes(3, { node_type = "router", capacity = 4 })
    local nodes = g:getNodes()
    print("created ids = " .. #ids)
    print("node count = " .. g:getNodeCount())
    print("first node type = " .. nodes[1]:getType())
end
```

---

### `LGraph:batchStep`

Runs multiple simulation steps in sequence. More efficient than calling step() in a loop from Lua.

```lua
-- signature
LGraph:batchStep(dt, iterations)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | `number` | Delta time per step. |
| `iterations` | `number` | Number of steps to run. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local ids = g:batchAddNodes(2, { node_type = "router" })
    g:batchAddEdges({
        { ids[1], ids[2], "lane" },
    })
    g:batchStep(0.25, 4)
    print("node count = " .. g:getNodeCount())
    print("edge count = " .. g:getEdgeCount())
end
```

---

### `LGraph:colorGraph`

Computes graph coloring and returns color indices by node id.

```lua
-- signature
LGraph:colorGraph()
```

**Returns**

| Type | Description |
|------|-------------|
| `table` | Map table from node id (integer key) to color index (integer). |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addEdge(a, b)
    local colors = g:colorGraph()
    print("coloring type = " .. type(colors))
end
```

---

### `LGraph:createItem`

Creates an unplaced graph item with optional type and decay time.

```lua
-- signature
LGraph:createItem(item_type, decay_time)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `item_type?` | `string` | Item type, defaulting to `default`. |
| `decay_time?` | `number` | Decay lifetime, defaulting to -1.0. |

**Returns**

| Type | Description |
|------|-------------|
| `LGraphItem` | New graph item handle. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local item = g:createItem("ore", 10.0)
    print("item type = " .. item:type())
end
```

---

### `LGraph:findPath`

Finds a path between two graph nodes.

```lua
-- signature
LGraph:findPath(from_ud, to_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from_ud` | `LGraphNode` | Start node handle. |
| `to_ud` | `LGraphNode` | Target node handle. |

**Returns**

| Type | Description |
|------|-------------|
| `LGraphFindPathResult` | Path result table with nodes, edges, and cost, or nil when no path exists. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b, c = g:addNode(), g:addNode(), g:addNode()
    g:addEdge(a, b)
    g:addEdge(b, c)
    local result = g:findPath(a, c)
    print("path found = " .. tostring(result ~= nil))
end
```

---

### `LGraph:findPathForItem`

Finds a path for a specific item between two nodes while respecting item constraints.

```lua
-- signature
LGraph:findPathForItem(item_ud, from_ud, to_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `item_ud` | `LGraphItem` | Item handle used for routing constraints. |
| `from_ud` | `LGraphNode` | Start node handle. |
| `to_ud` | `LGraphNode` | Target node handle. |

**Returns**

| Type | Description |
|------|-------------|
| `LGraphFindPathForItemResult` | Path result table with nodes, edges, and cost, or nil when no path exists. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addEdge(a, b)
    local item = g:createItem("cargo")
    local result = g:findPathForItem(item, a, b)
    print("item path found = " .. tostring(result ~= nil))
end
```

---

### `LGraph:getComponents`

Returns connected components as arrays of node handles.

```lua
-- signature
LGraph:getComponents()
```

**Returns**

| Type | Description |
|------|-------------|
| `LGraphNode[]` | Component tables containing `LGraphNode` handles. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    g:addNode()
    g:addNode()
    local comps = g:getComponents()
    print("components = " .. #comps)
end
```

---

### `LGraph:getDistance`

Returns graph distance between two nodes when reachable.

```lua
-- signature
LGraph:getDistance(from_ud, to_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from_ud` | `LGraphNode` | Start node handle. |
| `to_ud` | `LGraphNode` | Target node handle. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Distance between the two nodes, or nil when no path connects the nodes. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addEdge(a, b)
    local d = g:getDistance(a, b)
    print("distance = " .. tostring(d))
end
```

---

### `LGraph:getEdgeBetween`

Returns the edge connecting two nodes when one exists.

```lua
-- signature
LGraph:getEdgeBetween(from_ud, to_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from_ud` | `LGraphNode` | Source node handle. |
| `to_ud` | `LGraphNode` | Destination node handle. |

**Returns**

| Type | Description |
|------|-------------|
| `LGraphEdge` | Edge handle connecting the two nodes, or nil when no edge connects the nodes. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addEdge(a, b, "pipe")
    local e = g:getEdgeBetween(a, b)
    print("edge between a-b exists = " .. tostring(e ~= nil))
end
```

---

### `LGraph:getEdgeCount`

Returns the number of edges in this graph.

```lua
-- signature
LGraph:getEdgeCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Edge count. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    g:addEdge(a, b)
    print("edges = " .. g:getEdgeCount())
end
```

---

### `LGraph:getEdges`

Returns all edges in this logistics graph.

```lua
-- signature
LGraph:getEdges()
```

**Returns**

| Type | Description |
|------|-------------|
| `LGraphEdge[]` | `LGraphEdge` handles. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addEdge(a, b)
    local edges = g:getEdges()
    print("edge list = " .. #edges)
end
```

---

### `LGraph:getItemCount`

Returns the number of items in this graph.

```lua
-- signature
LGraph:getItemCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Item count. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    g:createItem("a")
    g:createItem("b")
    print("items = " .. g:getItemCount())
end
```

---

### `LGraph:getItems`

Returns all items in this logistics graph.

```lua
-- signature
LGraph:getItems()
```

**Returns**

| Type | Description |
|------|-------------|
| `LGraphItem[]` | `LGraphItem` handles. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    g:createItem("iron")
    local items = g:getItems()
    print("item list = " .. #items)
end
```

---

### `LGraph:getNeighbors`

Returns neighbor nodes connected to a node.

```lua
-- signature
LGraph:getNeighbors(node_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `node_ud` | `LGraphNode` | Node handle to inspect. |

**Returns**

| Type | Description |
|------|-------------|
| `LGraphNode[]` | Neighboring `LGraphNode` handles. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b, c = g:addNode(), g:addNode(), g:addNode()
    g:addEdge(a, b)
    g:addEdge(a, c)
    local neighbors = g:getNeighbors(a)
    print("neighbors of a = " .. #neighbors)
end
```

---

### `LGraph:getNodeCount`

Returns the number of nodes in this graph.

```lua
-- signature
LGraph:getNodeCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Node count. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    g:addNode()
    g:addNode()
    print("nodes = " .. g:getNodeCount())
end
```

---

### `LGraph:getNodes`

Returns all nodes in this logistics graph.

```lua
-- signature
LGraph:getNodes()
```

**Returns**

| Type | Description |
|------|-------------|
| `LGraphNode[]` | `LGraphNode` handles. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    g:addNode("x")
    g:addNode("y")
    local nodes = g:getNodes()
    print("node list = " .. #nodes)
end
```

---

### `LGraph:getReachable`

Returns nodes reachable from a start node within an optional maximum distance.

```lua
-- signature
LGraph:getReachable(from_ud, max_dist)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from_ud` | `LGraphNode` | Start node handle. |
| `max_dist?` | `number` | Maximum distance. |

**Returns**

| Type | Description |
|------|-------------|
| `LGraphNode[]` | Reachable `LGraphNode` handles. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addEdge(a, b)
    local reachable = g:getReachable(a, 5.0)
    print("reachable = " .. #reachable)
end
```

---

### `LGraph:getStats`

Returns graph counts and aggregate supply-demand statistics.

```lua
-- signature
LGraph:getStats()
```

**Returns**

| Type | Description |
|------|-------------|
| `LGraphGetStatsResult` | Table with node, edge, item, activity, transit, demand, supply, and queue counts. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    g:addNode()
    g:addNode()
    local stats = g:getStats()
    print("nodes=" .. stats.nodes .. " edges=" .. stats.edges .. " items=" .. stats.items)
end
```

---

### `LGraph:hasCycle`

Returns whether this graph contains a cycle.

```lua
-- signature
LGraph:hasCycle()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the graph has a cycle. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addEdge(a, b)
    g:addEdge(b, a)
    print("has cycle = " .. tostring(g:hasCycle()))
end
```

---

### `LGraph:hasEdge`

Returns whether an edge handle still exists in this graph.

```lua
-- signature
LGraph:hasEdge(edge_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `edge_ud` | `LGraphEdge` | Edge handle to check. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the edge exists. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    print("has edge = " .. tostring(g:hasEdge(e)))
end
```

---

### `LGraph:hasItem`

Returns whether an item handle still exists in this graph.

```lua
-- signature
LGraph:hasItem(item_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `item_ud` | `LGraphItem` | Item handle to check. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the item exists. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local item = g:createItem()
    print("has item = " .. tostring(g:hasItem(item)))
end
```

---

### `LGraph:hasNode`

Returns whether a node handle still exists in this graph.

```lua
-- signature
LGraph:hasNode(node_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `node_ud` | `LGraphNode` | Node handle to check. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the node exists. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    print("has node = " .. tostring(g:hasNode(n)))
end
```

---

### `LGraph:isBipartite`

Returns whether this graph is bipartite.

```lua
-- signature
LGraph:isBipartite()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the graph is bipartite. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    g:addEdge(a, b)
    print("bipartite = " .. tostring(g:isBipartite()))
end
```

---

### `LGraph:mst`

Computes a minimum spanning tree using Kruskal and returns edge ids.

```lua
-- signature
LGraph:mst()
```

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Array table of edge ids included in the tree. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b, c = g:addNode(), g:addNode(), g:addNode()
    g:addEdge(a, b)
    g:addEdge(b, c)
    g:addEdge(a, c)
    local tree = g:mst()
    print("MST edges = " .. #tree)
end
```

---

### `LGraph:on`

Registers a callback for a named graph event generated during simulation.

```lua
-- signature
LGraph:on(event_name, func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `event_name` | `string` | Event name from the valid graph event list. |
| `func` | `function` | Lua callback invoked with event-specific handles and values. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    g:on("itemEnter", function(item, node)
        print("item arrived at node")
    end)
    print("callback registered")
end
```

---

### `LGraph:processDemand`

Processes graph supply and demand once and dispatches generated callbacks.

```lua
-- signature
LGraph:processDemand()
```

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    g:processDemand()
    print("demand processed")
end
```

---

### `LGraph:removeEdge`

Removes an edge by handle on this object.

```lua
-- signature
LGraph:removeEdge(edge_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `edge_ud` | `LGraphEdge` | Edge handle to remove. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the edge was removed. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    local ok = g:removeEdge(e)
    print("removed edge = " .. tostring(ok))
end
```

---

### `LGraph:removeItem`

Removes an item from this logistics graph.

```lua
-- signature
LGraph:removeItem(item_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `item_ud` | `LGraphItem` | Item handle to remove. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the item was removed. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local item = g:createItem("scrap")
    local ok = g:removeItem(item)
    print("removed item = " .. tostring(ok))
end
```

---

### `LGraph:removeNode`

Removes a node and graph links associated with it.

```lua
-- signature
LGraph:removeNode(node_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `node_ud` | `LGraphNode` | Node handle to remove. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the node was removed. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    local ok = g:removeNode(n)
    print("removed node = " .. tostring(ok))
end
```

---

### `LGraph:sendItem`

Starts moving an item along an edge.

```lua
-- signature
LGraph:sendItem(item_ud, edge_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `item_ud` | `LGraphItem` | Item handle to send. |
| `edge_ud` | `LGraphEdge` | Edge handle to traverse. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e, item = g:addEdge(a, b), g:createItem("package")
    g:addItem(item, a)
    g:sendItem(item, e)
    print("item sent along edge")
end
```

---

### `LGraph:step`

Runs one discrete graph simulation step and dispatches generated callbacks.

```lua
-- signature
LGraph:step()
```

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    g:step()
    print("stepped")
end
```

---

### `LGraph:subgraph`

Creates a new graph containing a subset of nodes.

```lua
-- signature
LGraph:subgraph(nodes)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `nodes` | `table` | Array table of `LGraphNode` handles to include. |

**Returns**

| Type | Description |
|------|-------------|
| `LGraph` | New subgraph handle. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addNode()
    local sub = g:subgraph({a, b})
    print("subgraph nodes = " .. sub:getNodeCount())
end
```

---

### `LGraph:tickParallel`

Advances graph simulation through the parallel update path and dispatches generated callbacks.

```lua
-- signature
LGraph:tickParallel(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | `number` | Delta time in seconds. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    g:tickParallel(0.016)
    print("tick parallel done")
end
```

---

### `LGraph:topologicalSort`

Returns nodes in topological order when the graph is acyclic.

```lua
-- signature
LGraph:topologicalSort()
```

**Returns**

| Type | Description |
|------|-------------|
| `LGraphNode[]` | `LGraphNode` handles in topological order, or nil when sorting is impossible due to cycles. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b, c = g:addNode(), g:addNode(), g:addNode()
    g:addEdge(a, b)
    g:addEdge(b, c)
    local sorted = g:topologicalSort()
    print("topo sort = " .. tostring(sorted ~= nil))
end
```

---

### `LGraph:type`

Returns the Lua-visible type name for this graph handle.

```lua
-- signature
LGraph:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LGraph`. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    print("type = " .. g:type())
end
```

---

### `LGraph:typeOf`

Returns whether this graph handle matches a supported type name.

```lua
-- signature
LGraph:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LGraph`, `Graph`, and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    print("is Graph = " .. tostring(g:typeOf("LGraph")))
end
```

---

### `LGraph:update`

Advances graph simulation by delta time and dispatches generated callbacks.

```lua
-- signature
LGraph:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | `number` | Delta time in seconds. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    g:update(0.016)
    print("updated")
end
```

---

## LGraphEdge

### `LGraphEdge:addAllowedType`

Allows an item type to traverse this edge.

```lua
-- signature
LGraphEdge:addAllowedType(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | `string` | Item type to allow. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:addAllowedType("iron")
    print("iron allowed")
end
```

---

### `LGraphEdge:clearAllowedTypes`

Clears this edge's item type allow-list.

```lua
-- signature
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
    print("allow list cleared")
end
```

---

### `LGraphEdge:getCapacity`

Returns this edge's maximum concurrent item capacity.

```lua
-- signature
LGraphEdge:getCapacity()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Edge capacity. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    print("capacity = " .. e:getCapacity())
end
```

---

### `LGraphEdge:getCooldown`

Returns this edge's cooldown timer value.

```lua
-- signature
LGraphEdge:getCooldown()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Cooldown in seconds. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    print("cooldown = " .. e:getCooldown())
end
```

---

### `LGraphEdge:getFrom`

Returns the source node for this edge.

```lua
-- signature
LGraphEdge:getFrom()
```

**Returns**

| Type | Description |
|------|-------------|
| `LGraphNode` | Source node handle. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode("src"), g:addNode("dst")
    local e = g:addEdge(a, b)
    local from = e:getFrom()
    print("from type = " .. from:getType())
end
```

---

### `LGraphEdge:getItemsInTransit`

Returns graph items currently traveling along this edge.

```lua
-- signature
LGraphEdge:getItemsInTransit()
```

**Returns**

| Type | Description |
|------|-------------|
| `LGraphItem[]` | `LGraphItem` handles. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    local items = e:getItemsInTransit()
    print("in transit = " .. #items)
end
```

---

### `LGraphEdge:getSpeedModifier`

Returns this edge's speed modifier.

```lua
-- signature
LGraphEdge:getSpeedModifier()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Speed modifier. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    print("speed mod = " .. e:getSpeedModifier())
end
```

---

### `LGraphEdge:getThroughput`

Returns this edge's throughput value.

```lua
-- signature
LGraphEdge:getThroughput()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Current throughput. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    print("throughput = " .. e:getThroughput())
end
```

---

### `LGraphEdge:getTo`

Returns the destination node for this edge.

```lua
-- signature
LGraphEdge:getTo()
```

**Returns**

| Type | Description |
|------|-------------|
| `LGraphNode` | Destination node handle. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode("target")
    local e = g:addEdge(a, b)
    local to = e:getTo()
    print("to type = " .. to:getType())
end
```

---

### `LGraphEdge:getTravelTime`

Returns the travel time for items moving across this edge.

```lua
-- signature
LGraphEdge:getTravelTime()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Travel time in seconds. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    print("travel time = " .. e:getTravelTime())
end
```

---

### `LGraphEdge:getType`

Returns the edge type string used by routing and filters.

```lua
-- signature
LGraphEdge:getType()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Current edge type. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b, "conveyor")
    print("edge type = " .. e:getType())
end
```

---

### `LGraphEdge:getWeight`

Returns the pathfinding weight for this edge.

```lua
-- signature
LGraphEdge:getWeight()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Edge weight. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    print("weight = " .. e:getWeight())
end
```

---

### `LGraphEdge:isActive`

Returns whether this edge is active for routing and simulation.

```lua
-- signature
LGraphEdge:isActive()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the edge is active. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    print("active = " .. tostring(e:isActive()))
end
```

---

### `LGraphEdge:isBidirectional`

Returns whether this edge allows travel in both directions.

```lua
-- signature
LGraphEdge:isBidirectional()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the edge is bidirectional. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    print("bidi = " .. tostring(e:isBidirectional()))
end
```

---

### `LGraphEdge:isItemTypeAllowed`

Returns whether an item type may traverse this edge.

```lua
-- signature
LGraphEdge:isItemTypeAllowed(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | `string` | Item type to check. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the item type is allowed. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:addAllowedType("gold")
    print("gold allowed = " .. tostring(e:isItemTypeAllowed("gold")))
end
```

---

### `LGraphEdge:isOnCooldown`

Returns whether this edge is currently on cooldown.

```lua
-- signature
LGraphEdge:isOnCooldown()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when cooldown is active. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    print("on cooldown = " .. tostring(e:isOnCooldown()))
end
```

---

### `LGraphEdge:removeAllowedType`

Removes an item type from this edge's allow-list.

```lua
-- signature
LGraphEdge:removeAllowedType(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | `string` | Item type to remove. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the type was present. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:addAllowedType("coal")
    local ok = e:removeAllowedType("coal")
    print("removed = " .. tostring(ok))
end
```

---

### `LGraphEdge:setActive`

Enables or disables this edge for routing and simulation.

```lua
-- signature
LGraphEdge:setActive(a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `a` | `boolean` | New active flag. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:setActive(false)
    print("active = " .. tostring(e:isActive()))
end
```

---

### `LGraphEdge:setBidirectional`

Sets whether this edge allows travel in both directions.

```lua
-- signature
LGraphEdge:setBidirectional(b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `b` | `boolean` | New bidirectional flag. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:setBidirectional(true)
    print("bidi = " .. tostring(e:isBidirectional()))
end
```

---

### `LGraphEdge:setCapacity`

Sets this edge's maximum concurrent item capacity.

```lua
-- signature
LGraphEdge:setCapacity(c)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `c` | `number` | New edge capacity. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:setCapacity(10)
    print("capacity = " .. e:getCapacity())
end
```

---

### `LGraphEdge:setCooldown`

Sets this edge's cooldown timer value.

```lua
-- signature
LGraphEdge:setCooldown(c)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `c` | `number` | Cooldown in seconds. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:setCooldown(1.0)
    print("cooldown = " .. e:getCooldown())
end
```

---

### `LGraphEdge:setSpeedModifier`

Sets this edge's speed modifier value.

```lua
-- signature
LGraphEdge:setSpeedModifier(m)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `m` | `number` | Speed modifier. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:setSpeedModifier(2.0)
    print("speed mod = " .. e:getSpeedModifier())
end
```

---

### `LGraphEdge:setThroughput`

Sets this edge's throughput value.

```lua
-- signature
LGraphEdge:setThroughput(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | `number` | New throughput. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:setThroughput(100)
    print("throughput = " .. e:getThroughput())
end
```

---

### `LGraphEdge:setTravelTime`

Sets the travel time for items moving across this edge.

```lua
-- signature
LGraphEdge:setTravelTime(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | `number` | Travel time in seconds. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:setTravelTime(5.0)
    print("travel time = " .. e:getTravelTime())
end
```

---

### `LGraphEdge:setType`

Sets the edge type string used by routing and filters.

```lua
-- signature
LGraphEdge:setType(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | `string` | New edge type. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:setType("rail")
    print("edge type = " .. e:getType())
end
```

---

### `LGraphEdge:setWeight`

Sets the pathfinding weight for this edge.

```lua
-- signature
LGraphEdge:setWeight(w)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | `number` | Edge weight. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:setWeight(3.5)
    print("weight = " .. e:getWeight())
end
```

---

### `LGraphEdge:type`

Returns the Lua-visible type name for this graph edge handle.

```lua
-- signature
LGraphEdge:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LGraphEdge`. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    print("type = " .. e:type())
end
```

---

### `LGraphEdge:typeOf`

Returns whether this graph edge handle matches a supported type name.

```lua
-- signature
LGraphEdge:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LGraphEdge`, `GraphEdge`, and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    print("is GraphEdge = " .. tostring(e:typeOf("LGraphEdge")))
end
```

---

## LGraphItem

### `LGraphItem:getDecayTime`

Returns the total decay lifetime configured for this item.

```lua
-- signature
LGraphItem:getDecayTime()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Decay time in seconds, or the graph's sentinel for no decay. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local item = g:createItem("food", 30.0)
    print("decay time = " .. item:getDecayTime())
end
```

---

### `LGraphItem:getPosition`

Returns where this item is stored: a node, an edge plus progress, or no values when unplaced.

```lua
-- signature
LGraphItem:getPosition()
```

**Returns**

| Type | Description |
|------|-------------|
| `LGraphNode` | a Node handle when the item is at a node. |
| `LGraphEdge` | b Edge handle when the item is in transit. |
| `number` | c Transit progress when the item is in transit, or nil no value when the item is unplaced. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    local item = g:createItem("box")
    g:addItem(item, n)
    print("item is on a node = " .. tostring(item:getPosition() ~= nil))
end
```

---

### `LGraphItem:getPriority`

Returns this item's routing or queue priority.

```lua
-- signature
LGraphItem:getPriority()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Item priority. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local item = g:createItem()
    print("priority = " .. item:getPriority())
end
```

---

### `LGraphItem:getRemainingLife`

Returns this item's remaining lifetime before decay.

```lua
-- signature
LGraphItem:getRemainingLife()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Remaining lifetime in seconds. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local item = g:createItem("milk", 10.0)
    print("remaining = " .. item:getRemainingLife())
end
```

---

### `LGraphItem:getType`

Returns the item type string used by filters, conversions, supplies, and demands.

```lua
-- signature
LGraphItem:getType()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Current item type. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local item = g:createItem("ore")
    print("item type = " .. item:getType())
end
```

---

### `LGraphItem:isAlive`

Returns whether this item is still alive in the graph simulation.

```lua
-- signature
LGraphItem:isAlive()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the item has not decayed or been killed. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local item = g:createItem()
    print("alive = " .. tostring(item:isAlive()))
end
```

---

### `LGraphItem:kill`

Marks this item as dead so graph processing can remove or ignore it.

```lua
-- signature
LGraphItem:kill()
```

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local item = g:createItem()
    item:kill()
    print("alive after kill = " .. tostring(item:isAlive()))
end
```

---

### `LGraphItem:setDecayTime`

Sets the total decay lifetime for this item.

```lua
-- signature
LGraphItem:setDecayTime(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | `number` | Decay time in seconds, or the graph's sentinel for no decay. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local item = g:createItem("fruit")
    item:setDecayTime(60.0)
    print("decay time = " .. item:getDecayTime())
end
```

---

### `LGraphItem:setPriority`

Sets this item's routing or queue priority.

```lua
-- signature
LGraphItem:setPriority(p)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `p` | `number` | New item priority. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local item = g:createItem()
    item:setPriority(5)
    print("priority = " .. item:getPriority())
end
```

---

### `LGraphItem:setType`

Changes the item type string used by graph routing and processing rules.

```lua
-- signature
LGraphItem:setType(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | `string` | New item type. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local item = g:createItem("raw")
    item:setType("processed")
    print("item type = " .. item:getType())
end
```

---

### `LGraphItem:type`

Returns the Lua-visible type name for this graph item handle.

```lua
-- signature
LGraphItem:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LGraphItem`. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local item = g:createItem()
    print("type = " .. item:type())
end
```

---

### `LGraphItem:typeOf`

Returns whether this graph item handle matches a supported type name.

```lua
-- signature
LGraphItem:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LGraphItem`, `GraphItem`, and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local item = g:createItem()
    print("is GraphItem = " .. tostring(item:typeOf("LGraphItem")))
end
```

---

## LGraphNode

### `LGraphNode:addDemand`

Adds demand quantity and optional priority for an item type on this node.

```lua
-- signature
LGraphNode:addDemand(item_type, quantity, priority)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `item_type` | `string` | Item type demanded by the node. |
| `quantity` | `number` | Demand quantity to add. |
| `priority?` | `number` | Demand priority, defaulting to 0. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("factory")
    n:addDemand("iron", 5, 1)
    print("demand added")
end
```

---

### `LGraphNode:addSupply`

Adds supply quantity for an item type on this node.

```lua
-- signature
LGraphNode:addSupply(item_type, quantity)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `item_type` | `string` | Item type supplied by the node. |
| `quantity` | `number` | Supply quantity to add. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("mine")
    n:addSupply("iron", 10)
    print("supply added")
end
```

---

### `LGraphNode:addTag`

Adds a tag to this node on this object.

```lua
-- signature
LGraphNode:addTag(tag)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tag` | `string` | Tag to add. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addTag("important")
    print("tag added")
end
```

---

### `LGraphNode:clearAllConversions`

Removes every conversion rule from this node.

```lua
-- signature
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
    print("all conversions cleared")
end
```

---

### `LGraphNode:clearConversion`

Removes a conversion rule by input item type.

```lua
-- signature
LGraphNode:clearConversion(in_type)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `in_type` | `string` | Input item type. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when a conversion rule was removed. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setConversion("a", "b")
    local ok = n:clearConversion("a")
    print("cleared conversion = " .. tostring(ok))
end
```

---

### `LGraphNode:clearDemands`

Removes every demand entry from this node.

```lua
-- signature
LGraphNode:clearDemands()
```

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addDemand("x", 1)
    n:clearDemands()
    print("demands cleared")
end
```

---

### `LGraphNode:clearSupplies`

Removes every supply entry from this node.

```lua
-- signature
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
    print("supplies cleared")
end
```

---

### `LGraphNode:clearTags`

Removes every tag from this graph node.

```lua
-- signature
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
    print("tags cleared")
end
```

---

### `LGraphNode:dequeue`

Removes and returns the next item from this node's explicit queue.

```lua
-- signature
LGraphNode:dequeue()
```

**Returns**

| Type | Description |
|------|-------------|
| `LGraphItem` | Item handle from the queue, or nil when the queue is empty. |

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
    print("queue size = " .. n:getQueueSize())
    print("dequeued = " .. tostring(out ~= nil))
end
```

---

### `LGraphNode:enqueue`

Adds an item handle to this node's explicit queue.

```lua
-- signature
LGraphNode:enqueue(item_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `item_ud` | `LGraphItem` | Item handle to enqueue. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the item was queued. |

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
    print("queue size = " .. n:getQueueSize())
    print("enqueued = " .. tostring(queued))
end
```

---

### `LGraphNode:getCapacity`

Returns this node's item capacity.

```lua
-- signature
LGraphNode:getCapacity()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Node capacity. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("store", 50)
    print("capacity = " .. n:getCapacity())
end
```

---

### `LGraphNode:getEdges`

Returns edge handles connected to this node in the requested direction.

```lua
-- signature
LGraphNode:getEdges(dir)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dir?` | `string` | Direction string, defaulting to `both`. |

**Returns**

| Type | Description |
|------|-------------|
| `LGraphEdge[]` | `LGraphEdge` handles. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addEdge(a, b)
    local edges = a:getEdges("both")
    print("edges = " .. #edges)
end
```

---

### `LGraphNode:getFlowMode`

Returns this node's flow mode name.

```lua
-- signature
LGraphNode:getFlowMode()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Flow mode string. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    print("flow mode = " .. n:getFlowMode())
end
```

---

### `LGraphNode:getItemCount`

Returns the number of items currently stored on this node.

```lua
-- signature
LGraphNode:getItemCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Item count. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    print("items = " .. n:getItemCount())
end
```

---

### `LGraphNode:getItems`

Returns item handles currently stored on this node.

```lua
-- signature
LGraphNode:getItems()
```

**Returns**

| Type | Description |
|------|-------------|
| `LGraphItem[]` | `LGraphItem` handles. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    g:addItem(g:createItem("ore"), n)
    local items = n:getItems()
    print("node items = " .. #items)
end
```

---

### `LGraphNode:getOverflowPolicy`

Returns this node's overflow policy name.

```lua
-- signature
LGraphNode:getOverflowPolicy()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Overflow policy string. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    print("overflow = " .. tostring(n:getOverflowPolicy() or "reject"))
end
```

---

### `LGraphNode:getProcessTime`

Returns the processing time used by this node's conversions.

```lua
-- signature
LGraphNode:getProcessTime()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Processing time in seconds. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    print("process time = " .. n:getProcessTime())
end
```

---

### `LGraphNode:getPullFilter`

Returns this node's optional pull item-type filter.

```lua
-- signature
LGraphNode:getPullFilter()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Filter string when a pull filter is set, or nil when no pull filter is set. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    local f = n:getPullFilter()
    print("pull filter = " .. tostring(f))
end
```

---

### `LGraphNode:getPullRate`

Returns this node's pull rate value.

```lua
-- signature
LGraphNode:getPullRate()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Pull rate. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    print("pull rate = " .. n:getPullRate())
end
```

---

### `LGraphNode:getPushFilter`

Returns this node's optional push item-type filter.

```lua
-- signature
LGraphNode:getPushFilter()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Filter string when a push filter is set, or nil when no push filter is set. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    local f = n:getPushFilter()
    print("push filter = " .. tostring(f))
end
```

---

### `LGraphNode:getPushRate`

Returns this node's push rate value.

```lua
-- signature
LGraphNode:getPushRate()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Push rate. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    print("push rate = " .. n:getPushRate())
end
```

---

### `LGraphNode:getQueueCapacity`

Returns this node's queue capacity.

```lua
-- signature
LGraphNode:getQueueCapacity()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Queue capacity. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    print("queue cap = " .. n:getQueueCapacity())
end
```

---

### `LGraphNode:getQueueSize`

Returns the number of item ids currently queued at this node.

```lua
-- signature
LGraphNode:getQueueSize()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Queue size. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    print("queue size = " .. n:getQueueSize())
end
```

---

### `LGraphNode:getTags`

Returns all tags assigned to this node.

```lua
-- signature
LGraphNode:getTags()
```

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Tag strings. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addTag("a")
    n:addTag("b")
    local tags = n:getTags()
    print("tags = " .. #tags)
end
```

---

### `LGraphNode:getType`

Returns this node's type classification string.

```lua
-- signature
LGraphNode:getType()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Current node type. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("factory")
    print("node type = " .. n:getType())
end
```

---

### `LGraphNode:hasTag`

Returns whether this node has a tag.

```lua
-- signature
LGraphNode:hasTag(tag)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tag` | `string` | Tag to check. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the tag is present. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addTag("vip")
    print("has vip = " .. tostring(n:hasTag("vip")))
end
```

---

### `LGraphNode:isActive`

Returns whether this node is active for graph simulation.

```lua
-- signature
LGraphNode:isActive()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the node is active. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    print("active = " .. tostring(n:isActive()))
end
```

---

### `LGraphNode:isFull`

Returns whether this node has reached its item capacity.

```lua
-- signature
LGraphNode:isFull()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the node is full. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("bin", 1)
    print("full before = " .. tostring(n:isFull()))
end
```

---

### `LGraphNode:isQueueEnabled`

Returns whether this node's explicit queue is enabled.

```lua
-- signature
LGraphNode:isQueueEnabled()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when queueing is enabled. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    print("queue enabled = " .. tostring(n:isQueueEnabled()))
end
```

---

### `LGraphNode:removeDemand`

Removes demand entry for an item type from this node.

```lua
-- signature
LGraphNode:removeDemand(item_type)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `item_type` | `string` | Item type demand entry to remove. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when demand existed. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addDemand("coal", 3)
    local ok = n:removeDemand("coal")
    print("removed demand = " .. tostring(ok))
end
```

---

### `LGraphNode:removeSupply`

Removes supply entry for an item type from this node.

```lua
-- signature
LGraphNode:removeSupply(item_type)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `item_type` | `string` | Item type supply entry to remove. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when supply existed. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addSupply("wood", 5)
    local ok = n:removeSupply("wood")
    print("removed supply = " .. tostring(ok))
end
```

---

### `LGraphNode:removeTag`

Removes a tag from this node on this object.

```lua
-- signature
LGraphNode:removeTag(tag)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tag` | `string` | Tag to remove. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the tag was present. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addTag("temp")
    local ok = n:removeTag("temp")
    print("removed = " .. tostring(ok))
end
```

---

### `LGraphNode:setActive`

Enables or disables this node for graph simulation.

```lua
-- signature
LGraphNode:setActive(a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `a` | `boolean` | New active flag. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setActive(false)
    print("active = " .. tostring(n:isActive()))
end
```

---

### `LGraphNode:setCapacity`

Sets this node's item capacity value.

```lua
-- signature
LGraphNode:setCapacity(c)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `c` | `number` | New node capacity. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setCapacity(200)
    print("capacity = " .. n:getCapacity())
end
```

---

### `LGraphNode:setConversion`

Configures an item conversion rule on this node.

```lua
-- signature
LGraphNode:setConversion(in_type, out_type, in_count, out_count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `in_type` | `string` | Input item type. |
| `out_type` | `string` | Output item type. |
| `in_count?` | `number` | Input count, defaulting to 1. |
| `out_count?` | `number` | Output count, defaulting to 1. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("smelter")
    n:setConversion("iron_ore", "iron_bar", 2, 1)
    print("conversion set: 2 ore -> 1 bar")
end
```

---

### `LGraphNode:setFlowMode`

Sets this node's flow mode from a mode name.

```lua
-- signature
LGraphNode:setFlowMode(m)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `m` | `string` | Flow mode string. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setFlowMode("push")
    print("flow mode = " .. n:getFlowMode())
end
```

---

### `LGraphNode:setOverflowPolicy`

Sets this node's overflow policy from a policy name.

```lua
-- signature
LGraphNode:setOverflowPolicy(p)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `p` | `string` | Overflow policy string. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setOverflowPolicy("destroy")
    print("overflow = " .. tostring(n:getOverflowPolicy() or "destroy"))
end
```

---

### `LGraphNode:setProcessTime`

Sets the processing time used by this node's conversions.

```lua
-- signature
LGraphNode:setProcessTime(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | `number` | Processing time in seconds. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setProcessTime(2.5)
    print("process time = " .. n:getProcessTime())
end
```

---

### `LGraphNode:setPullFilter`

Sets or clears this node's pull item-type filter.

```lua
-- signature
LGraphNode:setPullFilter(f)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `f?` | `string` | Item type filter string. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setPullFilter("wood")
    print("pull filter = " .. tostring(n:getPullFilter()))
end
```

---

### `LGraphNode:setPullRate`

Sets this node's pull rate for this object.

```lua
-- signature
LGraphNode:setPullRate(r)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | `number` | New pull rate. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setPullRate(3)
    print("pull rate = " .. n:getPullRate())
end
```

---

### `LGraphNode:setPushFilter`

Sets or clears this node's push item-type filter.

```lua
-- signature
LGraphNode:setPushFilter(f)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `f?` | `string` | Item type filter string. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setPushFilter("iron")
    print("push filter = " .. tostring(n:getPushFilter()))
end
```

---

### `LGraphNode:setPushRate`

Sets this node's push rate for this object.

```lua
-- signature
LGraphNode:setPushRate(r)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | `number` | New push rate. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setPushRate(5)
    print("push rate = " .. n:getPushRate())
end
```

---

### `LGraphNode:setQueueCapacity`

Sets this node's queue capacity value.

```lua
-- signature
LGraphNode:setQueueCapacity(c)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `c` | `number` | Queue capacity. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setQueueCapacity(10)
    print("queue cap = " .. n:getQueueCapacity())
end
```

---

### `LGraphNode:setQueueEnabled`

Enables or disables this node's explicit queue.

```lua
-- signature
LGraphNode:setQueueEnabled(e)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `e` | `boolean` | New queue enabled flag. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setQueueEnabled(true)
    print("queue enabled = " .. tostring(n:isQueueEnabled()))
end
```

---

### `LGraphNode:setType`

Sets this node's type string for this object.

```lua
-- signature
LGraphNode:setType(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | `string` | New node type. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setType("warehouse")
    print("set type = " .. n:getType())
end
```

---

### `LGraphNode:type`

Returns the Lua-visible type name for this graph node handle.

```lua
-- signature
LGraphNode:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LGraphNode`. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    print("type = " .. n:type())
end
```

---

### `LGraphNode:typeOf`

Returns whether this graph node handle matches a supported type name.

```lua
-- signature
LGraphNode:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LGraphNode`, `GraphNode`, and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    print("is GraphNode = " .. tostring(n:typeOf("LGraphNode")))
end
```

---
