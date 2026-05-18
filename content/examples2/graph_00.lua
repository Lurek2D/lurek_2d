--- Graph Module Part 1: factory, LGraph core (nodes, edges, items, pathfinding, stats)

--@api-stub: lurek.graph.newGraph
-- Creates an empty logistics graph.
do
    local g = lurek.graph.newGraph()
    print("graph type = " .. g:type())
end

--@api-stub: LGraph:addNode
-- Creates a node with optional type and capacity.
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("warehouse", 100)
    print("node type = " .. n:type())
end

--@api-stub: LGraph:addEdge
-- Creates an edge between two nodes.
do
    local g = lurek.graph.newGraph()
    local a = g:addNode("src")
    local b = g:addNode("dst")
    local e = g:addEdge(a, b, "road")
    print("edge type = " .. e:type())
end

--@api-stub: LGraph:createItem
-- Creates an unplaced graph item.
do
    local g = lurek.graph.newGraph()
    local item = g:createItem("ore", 10.0)
    print("item type = " .. item:type())
end

--@api-stub: LGraph:addItem
-- Places an item onto a node.
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("storage")
    local item = g:createItem("wood")
    g:addItem(item, n)
    print("item placed on node")
end

--@api-stub: LGraph:removeNode
-- Removes a node from the graph.
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    local ok = g:removeNode(n)
    print("removed node = " .. tostring(ok))
end

--@api-stub: LGraph:removeEdge
-- Removes an edge from the graph.
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    local ok = g:removeEdge(e)
    print("removed edge = " .. tostring(ok))
end

--@api-stub: LGraph:removeItem
-- Removes an item from the graph.
do
    local g = lurek.graph.newGraph()
    local item = g:createItem("scrap")
    local ok = g:removeItem(item)
    print("removed item = " .. tostring(ok))
end

--@api-stub: LGraph:hasNode
-- Checks if a node handle exists.
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    print("has node = " .. tostring(g:hasNode(n)))
end

--@api-stub: LGraph:hasEdge
-- Checks if an edge handle exists.
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    print("has edge = " .. tostring(g:hasEdge(e)))
end

--@api-stub: LGraph:hasItem
-- Checks if an item handle exists.
do
    local g = lurek.graph.newGraph()
    local item = g:createItem()
    print("has item = " .. tostring(g:hasItem(item)))
end

--@api-stub: LGraph:getNodeCount
-- Returns the number of nodes.
do
    local g = lurek.graph.newGraph()
    g:addNode()
    g:addNode()
    print("nodes = " .. g:getNodeCount())
end

--@api-stub: LGraph:getEdgeCount
-- Returns the number of edges.
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    g:addEdge(a, b)
    print("edges = " .. g:getEdgeCount())
end

--@api-stub: LGraph:getItemCount
-- Returns the number of items.
do
    local g = lurek.graph.newGraph()
    g:createItem("a")
    g:createItem("b")
    print("items = " .. g:getItemCount())
end

--@api-stub: LGraph:getNodes
-- Returns all node handles.
do
    local g = lurek.graph.newGraph()
    g:addNode("x")
    g:addNode("y")
    local nodes = g:getNodes()
    print("node list = " .. #nodes)
end

--@api-stub: LGraph:getEdges
-- Returns all edge handles.
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    g:addEdge(a, b)
    local edges = g:getEdges()
    print("edge list = " .. #edges)
end

--@api-stub: LGraph:getItems
-- Returns all item handles.
do
    local g = lurek.graph.newGraph()
    g:createItem("iron")
    local items = g:getItems()
    print("item list = " .. #items)
end

--@api-stub: LGraph:getNeighbors
-- Returns neighbors of a node.
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local c = g:addNode()
    g:addEdge(a, b)
    g:addEdge(a, c)
    local neighbors = g:getNeighbors(a)
    print("neighbors of a = " .. #neighbors)
end

--@api-stub: LGraph:getEdgeBetween
-- Returns the edge connecting two nodes.
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    g:addEdge(a, b, "pipe")
    local e = g:getEdgeBetween(a, b)
    if e then
        print("edge between a-b exists")
    end
end

--@api-stub: LGraph:findPath
-- Finds a path between two nodes.
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local c = g:addNode()
    g:addEdge(a, b)
    g:addEdge(b, c)
    local result = g:findPath(a, c)
    if result then
        print("path cost = " .. result.cost)
        print("path nodes = " .. #result.nodes)
    end
end

--@api-stub: LGraph:findPathForItem
-- Finds a path for a specific item respecting constraints.
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    g:addEdge(a, b)
    local item = g:createItem("cargo")
    local result = g:findPathForItem(item, a, b)
    if result then
        print("item path cost = " .. result.cost)
    end
end

--@api-stub: LGraph:astar
-- Runs A* pathfinding between two nodes.
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    g:addEdge(a, b)
    local path = g:astar(a, b)
    if path then
        print("astar path = " .. #path .. " nodes")
    end
end

--@api-stub: LGraph:getDistance
-- Returns graph distance between two nodes.
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    g:addEdge(a, b)
    local d = g:getDistance(a, b)
    print("distance = " .. tostring(d))
end

--@api-stub: LGraph:getReachable
-- Returns nodes reachable within a max distance.
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    g:addEdge(a, b)
    local reachable = g:getReachable(a, 5.0)
    print("reachable = " .. #reachable)
end

--@api-stub: LGraph:getStats
-- Returns graph statistics.
do
    local g = lurek.graph.newGraph()
    g:addNode()
    g:addNode()
    local stats = g:getStats()
    print("nodes=" .. stats.nodes .. " edges=" .. stats.edges .. " items=" .. stats.items)
end

--@api-stub: LGraph:hasCycle
-- Checks if graph contains a cycle.
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    g:addEdge(a, b)
    g:addEdge(b, a)
    print("has cycle = " .. tostring(g:hasCycle()))
end

--@api-stub: LGraph:isBipartite
-- Checks if graph is bipartite.
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    g:addEdge(a, b)
    print("bipartite = " .. tostring(g:isBipartite()))
end

--@api-stub: LGraph:topologicalSort
-- Returns nodes in topological order.
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local c = g:addNode()
    g:addEdge(a, b)
    g:addEdge(b, c)
    local sorted = g:topologicalSort()
    if sorted then
        print("topo sort = " .. #sorted .. " nodes")
    end
end

--@api-stub: LGraph:mst
-- Computes minimum spanning tree edge ids.
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local c = g:addNode()
    g:addEdge(a, b)
    g:addEdge(b, c)
    g:addEdge(a, c)
    local tree = g:mst()
    print("MST edges = " .. #tree)
end

--@api-stub: LGraph:colorGraph
-- Computes graph coloring.
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    g:addEdge(a, b)
    local colors = g:colorGraph()
    print("coloring type = " .. type(colors))
end

--@api-stub: LGraph:getComponents
-- Returns connected components.
do
    local g = lurek.graph.newGraph()
    g:addNode()
    g:addNode()
    local comps = g:getComponents()
    print("components = " .. #comps)
end

--@api-stub: LGraph:subgraph
-- Creates a subgraph from selected nodes.
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    g:addNode()
    local sub = g:subgraph({a, b})
    print("subgraph nodes = " .. sub:getNodeCount())
end

--@api-stub: LGraph:sendItem
-- Starts moving an item along an edge.
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    e:setTravelTime(2.0)
    local item = g:createItem("package")
    g:addItem(item, a)
    g:sendItem(item, e)
    print("item sent along edge")
end

--@api-stub: LGraph:on
-- Registers a callback for a graph event.
do
    local g = lurek.graph.newGraph()
    g:on("item_arrived", function(item, node)
        print("item arrived at node")
    end)
    print("callback registered")
end

--@api-stub: LGraph:step
-- Runs one simulation step.
do
    local g = lurek.graph.newGraph()
    g:step()
    print("stepped")
end

--@api-stub: LGraph:update
-- Advances simulation by delta time.
do
    local g = lurek.graph.newGraph()
    g:update(0.016)
    print("updated")
end

--@api-stub: LGraph:tickParallel
-- Advances simulation via parallel path.
do
    local g = lurek.graph.newGraph()
    g:tickParallel(0.016)
    print("tick parallel done")
end

--@api-stub: LGraph:processDemand
-- Processes supply and demand once.
do
    local g = lurek.graph.newGraph()
    g:processDemand()
    print("demand processed")
end

--@api-stub: LGraph:type
-- Returns the type name "LGraph".
do
    local g = lurek.graph.newGraph()
    print("type = " .. g:type())
end

--@api-stub: LGraph:typeOf
-- Returns whether this graph matches a type name.
do
    local g = lurek.graph.newGraph()
    print("is Graph = " .. tostring(g:typeOf("Graph")))
end

print("graph_00.lua")
