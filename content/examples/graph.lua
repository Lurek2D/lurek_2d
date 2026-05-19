-- content/examples/graph.lua
-- Auto-generated from content/examples2/graph_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/graph.lua

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

--- Graph Module Part 2: LGraphNode methods

--@api-stub: LGraphNode:getType
-- Returns the node type string.
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("factory")
    print("node type = " .. n:getType())
end

--@api-stub: LGraphNode:setType
-- Sets the node type string.
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setType("warehouse")
    print("set type = " .. n:getType())
end

--@api-stub: LGraphNode:getCapacity
-- Returns node item capacity.
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("store", 50)
    print("capacity = " .. n:getCapacity())
end

--@api-stub: LGraphNode:setCapacity
-- Sets node item capacity.
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setCapacity(200)
    print("capacity = " .. n:getCapacity())
end

--@api-stub: LGraphNode:isActive
-- Returns whether node is active.
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    print("active = " .. tostring(n:isActive()))
end

--@api-stub: LGraphNode:setActive
-- Enables or disables the node.
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setActive(false)
    print("active = " .. tostring(n:isActive()))
end

--@api-stub: LGraphNode:isFull
-- Checks if node has reached capacity.
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("bin", 1)
    print("full before = " .. tostring(n:isFull()))
end

--@api-stub: LGraphNode:getItemCount
-- Returns items stored on this node.
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    print("items = " .. n:getItemCount())
end

--@api-stub: LGraphNode:getItems
-- Returns item handles on this node.
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    local item = g:createItem("ore")
    g:addItem(item, n)
    local items = n:getItems()
    print("node items = " .. #items)
end

--@api-stub: LGraphNode:getEdges
-- Returns edges connected to this node.
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    g:addEdge(a, b)
    local edges = a:getEdges("both")
    print("edges = " .. #edges)
end

--@api-stub: LGraphNode:addSupply
-- Adds supply for an item type.
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("mine")
    n:addSupply("iron", 10)
    print("supply added")
end

--@api-stub: LGraphNode:removeSupply
-- Removes supply for an item type.
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addSupply("wood", 5)
    local ok = n:removeSupply("wood")
    print("removed supply = " .. tostring(ok))
end

--@api-stub: LGraphNode:clearSupplies
-- Removes all supply entries.
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addSupply("a", 1)
    n:addSupply("b", 2)
    n:clearSupplies()
    print("supplies cleared")
end

--@api-stub: LGraphNode:addDemand
-- Adds demand for an item type with optional priority.
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("factory")
    n:addDemand("iron", 5, 1)
    print("demand added")
end

--@api-stub: LGraphNode:removeDemand
-- Removes demand for an item type.
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addDemand("coal", 3)
    local ok = n:removeDemand("coal")
    print("removed demand = " .. tostring(ok))
end

--@api-stub: LGraphNode:clearDemands
-- Removes all demand entries.
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addDemand("x", 1)
    n:clearDemands()
    print("demands cleared")
end

--@api-stub: LGraphNode:setConversion
-- Configures an item conversion rule.
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("smelter")
    n:setConversion("iron_ore", "iron_bar", 2, 1)
    print("conversion set: 2 ore -> 1 bar")
end

--@api-stub: LGraphNode:clearConversion
-- Removes a conversion rule.
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setConversion("a", "b")
    local ok = n:clearConversion("a")
    print("cleared conversion = " .. tostring(ok))
end

--@api-stub: LGraphNode:clearAllConversions
-- Removes all conversion rules.
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setConversion("a", "b")
    n:setConversion("c", "d")
    n:clearAllConversions()
    print("all conversions cleared")
end

--@api-stub: LGraphNode:getProcessTime
-- Returns conversion processing time.
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    print("process time = " .. n:getProcessTime())
end

--@api-stub: LGraphNode:setProcessTime
-- Sets conversion processing time.
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setProcessTime(2.5)
    print("process time = " .. n:getProcessTime())
end

--@api-stub: LGraphNode:getFlowMode
-- Returns the node's flow mode.
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    print("flow mode = " .. n:getFlowMode())
end

--@api-stub: LGraphNode:setFlowMode
-- Sets the node's flow mode.
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setFlowMode("push")
    print("flow mode = " .. n:getFlowMode())
end

--@api-stub: LGraphNode:getPushRate
-- Returns the node's push rate.
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    print("push rate = " .. n:getPushRate())
end

--@api-stub: LGraphNode:setPushRate
-- Sets the node's push rate.
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setPushRate(5)
    print("push rate = " .. n:getPushRate())
end

--@api-stub: LGraphNode:getPullRate
-- Returns the node's pull rate.
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    print("pull rate = " .. n:getPullRate())
end

--@api-stub: LGraphNode:setPullRate
-- Sets the node's pull rate.
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setPullRate(3)
    print("pull rate = " .. n:getPullRate())
end

--@api-stub: LGraphNode:getPushFilter
-- Returns the push item-type filter.
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    local f = n:getPushFilter()
    print("push filter = " .. tostring(f))
end

--@api-stub: LGraphNode:setPushFilter
-- Sets the push item-type filter.
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setPushFilter("iron")
    print("push filter = " .. tostring(n:getPushFilter()))
end

--@api-stub: LGraphNode:getPullFilter
-- Returns the pull item-type filter.
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    local f = n:getPullFilter()
    print("pull filter = " .. tostring(f))
end

--@api-stub: LGraphNode:setPullFilter
-- Sets the pull item-type filter.
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setPullFilter("wood")
    print("pull filter = " .. tostring(n:getPullFilter()))
end

--@api-stub: LGraphNode:getOverflowPolicy
-- Returns the node's overflow policy.
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    print("overflow = " .. n:getOverflowPolicy())
end

--@api-stub: LGraphNode:setOverflowPolicy
-- Sets the node's overflow policy.
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setOverflowPolicy("drop")
    print("overflow = " .. n:getOverflowPolicy())
end

--@api-stub: LGraphNode:isQueueEnabled
-- Checks if explicit queue is enabled.
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    print("queue enabled = " .. tostring(n:isQueueEnabled()))
end

--@api-stub: LGraphNode:setQueueEnabled
-- Enables or disables explicit queue.
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setQueueEnabled(true)
    print("queue enabled = " .. tostring(n:isQueueEnabled()))
end

--@api-stub: LGraphNode:getQueueCapacity
-- Returns queue capacity.
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    print("queue cap = " .. n:getQueueCapacity())
end

--@api-stub: LGraphNode:setQueueCapacity
-- Sets queue capacity.
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setQueueCapacity(10)
    print("queue cap = " .. n:getQueueCapacity())
end

--@api-stub: LGraphNode:getQueueSize
-- Returns current queue size.
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    print("queue size = " .. n:getQueueSize())
end

--@api-stub: LGraphNode:enqueue
-- Enqueues an item.
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setQueueEnabled(true)
    n:setQueueCapacity(5)
    local item = g:createItem("parcel")
    g:addItem(item, n)
    local ok = n:enqueue(item)
    print("enqueued = " .. tostring(ok))
end

--@api-stub: LGraphNode:dequeue
-- Dequeues the next item.
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setQueueEnabled(true)
    n:setQueueCapacity(5)
    local item = g:createItem("box")
    g:addItem(item, n)
    n:enqueue(item)
    local out = n:dequeue()
    if out then
        print("dequeued item type = " .. out:getType())
    end
end

--@api-stub: LGraphNode:addTag
-- Adds a tag to the node.
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addTag("important")
    print("tag added")
end

--@api-stub: LGraphNode:hasTag
-- Checks if node has a tag.
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addTag("vip")
    print("has vip = " .. tostring(n:hasTag("vip")))
end

--@api-stub: LGraphNode:getTags
-- Returns all tags.
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addTag("a")
    n:addTag("b")
    local tags = n:getTags()
    print("tags = " .. #tags)
end

--@api-stub: LGraphNode:removeTag
-- Removes a tag.
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addTag("temp")
    local ok = n:removeTag("temp")
    print("removed = " .. tostring(ok))
end

--@api-stub: LGraphNode:clearTags
-- Removes all tags.
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addTag("x")
    n:addTag("y")
    n:clearTags()
    print("tags cleared")
end

--@api-stub: LGraphNode:type
-- Returns the type name "LGraphNode".
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    print("type = " .. n:type())
end

--@api-stub: LGraphNode:typeOf
-- Returns whether this node matches a type name.
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    print("is GraphNode = " .. tostring(n:typeOf("GraphNode")))
end

--- Graph Module Part 3: LGraphEdge and LGraphItem methods

--@api-stub: LGraphEdge:getFrom
-- Returns the source node.
do
    local g = lurek.graph.newGraph()
    local a = g:addNode("src")
    local b = g:addNode("dst")
    local e = g:addEdge(a, b)
    local from = e:getFrom()
    print("from type = " .. from:getType())
end

--@api-stub: LGraphEdge:getTo
-- Returns the destination node.
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode("target")
    local e = g:addEdge(a, b)
    local to = e:getTo()
    print("to type = " .. to:getType())
end

--@api-stub: LGraphEdge:getType
-- Returns the edge type string.
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b, "conveyor")
    print("edge type = " .. e:getType())
end

--@api-stub: LGraphEdge:setType
-- Sets the edge type string.
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    e:setType("rail")
    print("edge type = " .. e:getType())
end

--@api-stub: LGraphEdge:getWeight
-- Returns the edge pathfinding weight.
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    print("weight = " .. e:getWeight())
end

--@api-stub: LGraphEdge:setWeight
-- Sets the edge weight.
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    e:setWeight(3.5)
    print("weight = " .. e:getWeight())
end

--@api-stub: LGraphEdge:getTravelTime
-- Returns edge travel time.
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    print("travel time = " .. e:getTravelTime())
end

--@api-stub: LGraphEdge:setTravelTime
-- Sets edge travel time.
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    e:setTravelTime(5.0)
    print("travel time = " .. e:getTravelTime())
end

--@api-stub: LGraphEdge:getCapacity
-- Returns edge item capacity.
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    print("capacity = " .. e:getCapacity())
end

--@api-stub: LGraphEdge:setCapacity
-- Sets edge item capacity.
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    e:setCapacity(10)
    print("capacity = " .. e:getCapacity())
end

--@api-stub: LGraphEdge:getSpeedModifier
-- Returns edge speed modifier.
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    print("speed mod = " .. e:getSpeedModifier())
end

--@api-stub: LGraphEdge:setSpeedModifier
-- Sets edge speed modifier.
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    e:setSpeedModifier(2.0)
    print("speed mod = " .. e:getSpeedModifier())
end

--@api-stub: LGraphEdge:getThroughput
-- Returns edge throughput.
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    print("throughput = " .. e:getThroughput())
end

--@api-stub: LGraphEdge:setThroughput
-- Sets edge throughput.
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    e:setThroughput(100)
    print("throughput = " .. e:getThroughput())
end

--@api-stub: LGraphEdge:getCooldown
-- Returns edge cooldown.
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    print("cooldown = " .. e:getCooldown())
end

--@api-stub: LGraphEdge:setCooldown
-- Sets edge cooldown.
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    e:setCooldown(1.0)
    print("cooldown = " .. e:getCooldown())
end

--@api-stub: LGraphEdge:isOnCooldown
-- Checks if edge is on cooldown.
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    print("on cooldown = " .. tostring(e:isOnCooldown()))
end

--@api-stub: LGraphEdge:isActive
-- Returns whether edge is active.
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    print("active = " .. tostring(e:isActive()))
end

--@api-stub: LGraphEdge:setActive
-- Enables or disables the edge.
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    e:setActive(false)
    print("active = " .. tostring(e:isActive()))
end

--@api-stub: LGraphEdge:isBidirectional
-- Checks if edge is bidirectional.
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    print("bidi = " .. tostring(e:isBidirectional()))
end

--@api-stub: LGraphEdge:setBidirectional
-- Sets bidirectional flag.
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    e:setBidirectional(true)
    print("bidi = " .. tostring(e:isBidirectional()))
end

--@api-stub: LGraphEdge:addAllowedType
-- Allows an item type to traverse this edge.
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    e:addAllowedType("iron")
    print("iron allowed")
end

--@api-stub: LGraphEdge:isItemTypeAllowed
-- Checks if an item type can traverse.
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    e:addAllowedType("gold")
    print("gold allowed = " .. tostring(e:isItemTypeAllowed("gold")))
end

--@api-stub: LGraphEdge:removeAllowedType
-- Removes an item type from the allow-list.
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    e:addAllowedType("coal")
    local ok = e:removeAllowedType("coal")
    print("removed = " .. tostring(ok))
end

--@api-stub: LGraphEdge:clearAllowedTypes
-- Clears the allow-list.
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    e:addAllowedType("x")
    e:clearAllowedTypes()
    print("allow list cleared")
end

--@api-stub: LGraphEdge:getItemsInTransit
-- Returns items traveling along this edge.
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    local items = e:getItemsInTransit()
    print("in transit = " .. #items)
end

--@api-stub: LGraphEdge:type
-- Returns the type name "LGraphEdge".
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    print("type = " .. e:type())
end

--@api-stub: LGraphEdge:typeOf
-- Returns whether this edge matches a type name.
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    print("is GraphEdge = " .. tostring(e:typeOf("GraphEdge")))
end

--@api-stub: LGraphItem:getType
-- Returns the item type string.
do
    local g = lurek.graph.newGraph()
    local item = g:createItem("ore")
    print("item type = " .. item:getType())
end

--@api-stub: LGraphItem:setType
-- Changes the item type string.
do
    local g = lurek.graph.newGraph()
    local item = g:createItem("raw")
    item:setType("processed")
    print("item type = " .. item:getType())
end

--@api-stub: LGraphItem:getPriority
-- Returns item priority.
do
    local g = lurek.graph.newGraph()
    local item = g:createItem()
    print("priority = " .. item:getPriority())
end

--@api-stub: LGraphItem:setPriority
-- Sets item priority.
do
    local g = lurek.graph.newGraph()
    local item = g:createItem()
    item:setPriority(5)
    print("priority = " .. item:getPriority())
end

--@api-stub: LGraphItem:getDecayTime
-- Returns total decay lifetime.
do
    local g = lurek.graph.newGraph()
    local item = g:createItem("food", 30.0)
    print("decay time = " .. item:getDecayTime())
end

--@api-stub: LGraphItem:setDecayTime
-- Sets decay lifetime.
do
    local g = lurek.graph.newGraph()
    local item = g:createItem("fruit")
    item:setDecayTime(60.0)
    print("decay time = " .. item:getDecayTime())
end

--@api-stub: LGraphItem:getRemainingLife
-- Returns remaining lifetime.
do
    local g = lurek.graph.newGraph()
    local item = g:createItem("milk", 10.0)
    print("remaining = " .. item:getRemainingLife())
end

--@api-stub: LGraphItem:isAlive
-- Checks if item is still alive.
do
    local g = lurek.graph.newGraph()
    local item = g:createItem()
    print("alive = " .. tostring(item:isAlive()))
end

--@api-stub: LGraphItem:kill
-- Marks the item as dead.
do
    local g = lurek.graph.newGraph()
    local item = g:createItem()
    item:kill()
    print("alive after kill = " .. tostring(item:isAlive()))
end

--@api-stub: LGraphItem:getPosition
-- Returns item position (node or edge+progress).
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    local item = g:createItem("box")
    g:addItem(item, n)
    local node, edge, progress = item:getPosition()
    if node then
        print("item is on a node")
    end
end

--@api-stub: LGraphItem:type
-- Returns the type name "LGraphItem".
do
    local g = lurek.graph.newGraph()
    local item = g:createItem()
    print("type = " .. item:type())
end

--@api-stub: LGraphItem:typeOf
-- Returns whether this item matches a type name.
do
    local g = lurek.graph.newGraph()
    local item = g:createItem()
    print("is GraphItem = " .. tostring(item:typeOf("GraphItem")))
end

print("content/examples/graph.lua")
