-- content/examples/flownet.lua
-- Auto-generated from content/examples2/graph_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/flownet.lua

--- Graph Module Part 1: factory, LGraph core (nodes, edges, items, pathfinding, stats)

--@api: lurek.graph.newGraph
do
    local g = lurek.graph.newGraph()
    print("graph type = " .. g:type())
    print("nodes = " .. g:getNodeCount())
    print("edges = " .. g:getEdgeCount())
end

--@api: LGraph:addNode
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("warehouse", 100)
    print("node type = " .. n:type())
end

--@api: LGraph:addEdge
do
    local g = lurek.graph.newGraph()
    local a = g:addNode("src")
    local b = g:addNode("dst")
    local e = g:addEdge(a, b, "road")
    print("edge type = " .. e:type())
end

--@api: LGraph:createItem
do
    local g = lurek.graph.newGraph()
    local item = g:createItem("ore", 10.0)
    print("item type = " .. item:type())
end

--@api: LGraph:addItem
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("storage")
    local item = g:createItem("wood")
    g:addItem(item, n)
    print("item placed on node")
end

--@api: LGraph:removeNode
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    local ok = g:removeNode(n)
    print("removed node = " .. tostring(ok))
end

--@api: LGraph:removeEdge
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    local ok = g:removeEdge(e)
    print("removed edge = " .. tostring(ok))
end

--@api: LGraph:removeItem
do
    local g = lurek.graph.newGraph()
    local item = g:createItem("scrap")
    local ok = g:removeItem(item)
    print("removed item = " .. tostring(ok))
end

--@api: LGraph:hasNode
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    print("has node = " .. tostring(g:hasNode(n)))
end

--@api: LGraph:hasEdge
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    print("has edge = " .. tostring(g:hasEdge(e)))
end

--@api: LGraph:hasItem
do
    local g = lurek.graph.newGraph()
    local item = g:createItem()
    print("has item = " .. tostring(g:hasItem(item)))
end

--@api: LGraph:getNodeCount
do
    local g = lurek.graph.newGraph()
    g:addNode()
    g:addNode()
    print("nodes = " .. g:getNodeCount())
end

--@api: LGraph:getEdgeCount
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    g:addEdge(a, b)
    print("edges = " .. g:getEdgeCount())
end

--@api: LGraph:getItemCount
do
    local g = lurek.graph.newGraph()
    g:createItem("a")
    g:createItem("b")
    print("items = " .. g:getItemCount())
end

--@api: LGraph:getNodes
do
    local g = lurek.graph.newGraph()
    g:addNode("x")
    g:addNode("y")
    local nodes = g:getNodes()
    print("node list = " .. #nodes)
end

--@api: LGraph:getEdges
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addEdge(a, b)
    local edges = g:getEdges()
    print("edge list = " .. #edges)
end

--@api: LGraph:getItems
do
    local g = lurek.graph.newGraph()
    g:createItem("iron")
    local items = g:getItems()
    print("item list = " .. #items)
end

--@api: LGraph:getNeighbors
do
    local g = lurek.graph.newGraph()
    local a, b, c = g:addNode(), g:addNode(), g:addNode()
    g:addEdge(a, b)
    g:addEdge(a, c)
    local neighbors = g:getNeighbors(a)
    print("neighbors of a = " .. #neighbors)
end

--@api: LGraph:getEdgeBetween
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addEdge(a, b, "pipe")
    local e = g:getEdgeBetween(a, b)
    print("edge between a-b exists = " .. tostring(e ~= nil))
end

--@api: LGraph:findPath
do
    local g = lurek.graph.newGraph()
    local a, b, c = g:addNode(), g:addNode(), g:addNode()
    g:addEdge(a, b)
    g:addEdge(b, c)
    local result = g:findPath(a, c)
    print("path found = " .. tostring(result ~= nil))
end

--@api: LGraph:findPathForItem
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addEdge(a, b)
    local item = g:createItem("cargo")
    local result = g:findPathForItem(item, a, b)
    print("item path found = " .. tostring(result ~= nil))
end

--@api: LGraph:astar
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addEdge(a, b)
    local path = g:astar(a, b)
    print("astar path = " .. tostring(path ~= nil))
end

--@api: LGraph:getDistance
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addEdge(a, b)
    local d = g:getDistance(a, b)
    print("distance = " .. tostring(d))
end

--@api: LGraph:getReachable
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addEdge(a, b)
    local reachable = g:getReachable(a, 5.0)
    print("reachable = " .. #reachable)
end

--@api: LGraph:getStats
do
    local g = lurek.graph.newGraph()
    g:addNode()
    g:addNode()
    local stats = g:getStats()
    print("nodes=" .. stats.nodes .. " edges=" .. stats.edges .. " items=" .. stats.items)
end

--@api: LGraph:hasCycle
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addEdge(a, b)
    g:addEdge(b, a)
    print("has cycle = " .. tostring(g:hasCycle()))
end

--@api: LGraph:isBipartite
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    g:addEdge(a, b)
    print("bipartite = " .. tostring(g:isBipartite()))
end

--@api: LGraph:topologicalSort
do
    local g = lurek.graph.newGraph()
    local a, b, c = g:addNode(), g:addNode(), g:addNode()
    g:addEdge(a, b)
    g:addEdge(b, c)
    local sorted = g:topologicalSort()
    print("topo sort = " .. tostring(sorted ~= nil))
end

--@api: LGraph:mst
do
    local g = lurek.graph.newGraph()
    local a, b, c = g:addNode(), g:addNode(), g:addNode()
    g:addEdge(a, b)
    g:addEdge(b, c)
    g:addEdge(a, c)
    local tree = g:mst()
    print("MST edges = " .. #tree)
end

--@api: LGraph:colorGraph
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addEdge(a, b)
    local colors = g:colorGraph()
    print("coloring type = " .. type(colors))
end

--@api: LGraph:getComponents
do
    local g = lurek.graph.newGraph()
    g:addNode()
    g:addNode()
    local comps = g:getComponents()
    print("components = " .. #comps)
end

--@api: LGraph:subgraph
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addNode()
    local sub = g:subgraph({a, b})
    print("subgraph nodes = " .. sub:getNodeCount())
end

--@api: LGraph:sendItem
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e, item = g:addEdge(a, b), g:createItem("package")
    g:addItem(item, a)
    g:sendItem(item, e)
    print("item sent along edge")
end

--@api: LGraph:on
do
    local g = lurek.graph.newGraph()
    g:on("itemEnter", function(item, node)
        print("item arrived at node")
    end)
    print("callback registered")
end

--@api: LGraph:step
do
    local g = lurek.graph.newGraph()
    g:step()
    print("stepped")
end

--@api: LGraph:update
do
    local g = lurek.graph.newGraph()
    g:update(0.016)
    print("updated")
end

--@api: LGraph:tickParallel
do
    local g = lurek.graph.newGraph()
    g:tickParallel(0.016)
    print("tick parallel done")
end

--@api: LGraph:processDemand
do
    local g = lurek.graph.newGraph()
    g:processDemand()
    print("demand processed")
end

--@api: LGraph:type
do
    local g = lurek.graph.newGraph()
    print("type = " .. g:type())
end

--@api: LGraph:typeOf
do
    local g = lurek.graph.newGraph()
    print("is Graph = " .. tostring(g:typeOf("LGraph")))
end

--- Graph Module Part 2: LGraphNode methods

--@api: LGraphNode:getType
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("factory")
    print("node type = " .. n:getType())
end

--@api: LGraphNode:setType
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setType("warehouse")
    print("set type = " .. n:getType())
end

--@api: LGraphNode:getCapacity
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("store", 50)
    print("capacity = " .. n:getCapacity())
end

--@api: LGraphNode:setCapacity
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setCapacity(200)
    print("capacity = " .. n:getCapacity())
end

--@api: LGraphNode:getReservedCapacity
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("warehouse", 5)
    n:reserveCapacity("planner-a", 2)
    print("reserved capacity = " .. n:getReservedCapacity())
end

--@api: LGraphNode:getAvailableCapacity
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("warehouse", 5)
    n:reserveCapacity("planner-a", 2)
    print("available capacity = " .. n:getAvailableCapacity())
end

--@api: LGraphNode:reserveCapacity
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("warehouse", 5)
    local ok = n:reserveCapacity("planner-a", 2)
    print("reservation accepted = " .. tostring(ok))
end

--@api: LGraphNode:releaseCapacityReservation
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("warehouse", 5)
    n:reserveCapacity("planner-a", 2)
    local released = n:releaseCapacityReservation("planner-a", 1)
    print("released slots = " .. released)
end

--@api: LGraphNode:clearCapacityReservations
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("warehouse", 5)
    n:reserveCapacity("planner-a", 2)
    n:clearCapacityReservations()
    print("reserved capacity = " .. n:getReservedCapacity())
end

--@api: LGraphNode:isActive
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    print("active = " .. tostring(n:isActive()))
end

--@api: LGraphNode:setActive
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setActive(false)
    print("active = " .. tostring(n:isActive()))
end

--@api: LGraphNode:isFull
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("bin", 1)
    print("full before = " .. tostring(n:isFull()))
end

--@api: LGraphNode:getItemCount
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    print("items = " .. n:getItemCount())
end

--@api: LGraphNode:getItems
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    g:addItem(g:createItem("ore"), n)
    local items = n:getItems()
    print("node items = " .. #items)
end

--@api: LGraphNode:getEdges
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addEdge(a, b)
    local edges = a:getEdges("both")
    print("edges = " .. #edges)
end

--@api: LGraphNode:addSupply
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("mine")
    n:addSupply("iron", 10)
    print("supply added")
end

--@api: LGraphNode:removeSupply
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addSupply("wood", 5)
    local ok = n:removeSupply("wood")
    print("removed supply = " .. tostring(ok))
end

--@api: LGraphNode:clearSupplies
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addSupply("a", 1)
    n:addSupply("b", 2)
    n:clearSupplies()
    print("supplies cleared")
end

--@api: LGraphNode:addDemand
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("factory")
    n:addDemand("iron", 5, 1)
    print("demand added")
end

--@api: LGraphNode:removeDemand
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addDemand("coal", 3)
    local ok = n:removeDemand("coal")
    print("removed demand = " .. tostring(ok))
end

--@api: LGraphNode:clearDemands
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addDemand("x", 1)
    n:clearDemands()
    print("demands cleared")
end

--@api: LGraphNode:setConversion
do
    local g = lurek.graph.newGraph()
    local n = g:addNode("smelter")
    n:setConversion("iron_ore", "iron_bar", 2, 1)
    print("conversion set: 2 ore -> 1 bar")
end

--@api: LGraphNode:clearConversion
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setConversion("a", "b")
    local ok = n:clearConversion("a")
    print("cleared conversion = " .. tostring(ok))
end

--@api: LGraphNode:clearAllConversions
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setConversion("a", "b")
    n:setConversion("c", "d")
    n:clearAllConversions()
    print("all conversions cleared")
end

--@api: LGraphNode:getProcessTime
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    print("process time = " .. n:getProcessTime())
end

--@api: LGraphNode:setProcessTime
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setProcessTime(2.5)
    print("process time = " .. n:getProcessTime())
end

--@api: LGraphNode:getFlowMode
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    print("flow mode = " .. n:getFlowMode())
end

--@api: LGraphNode:setFlowMode
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setFlowMode("push")
    print("flow mode = " .. n:getFlowMode())
end

--@api: LGraphNode:getPushRate
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    print("push rate = " .. n:getPushRate())
end

--@api: LGraphNode:setPushRate
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setPushRate(5)
    print("push rate = " .. n:getPushRate())
end

--@api: LGraphNode:getPullRate
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    print("pull rate = " .. n:getPullRate())
end

--@api: LGraphNode:setPullRate
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setPullRate(3)
    print("pull rate = " .. n:getPullRate())
end

--@api: LGraphNode:getPushFilter
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    local f = n:getPushFilter()
    print("push filter = " .. tostring(f))
end

--@api: LGraphNode:setPushFilter
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setPushFilter("iron")
    print("push filter = " .. tostring(n:getPushFilter()))
end

--@api: LGraphNode:getPullFilter
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    local f = n:getPullFilter()
    print("pull filter = " .. tostring(f))
end

--@api: LGraphNode:setPullFilter
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setPullFilter("wood")
    print("pull filter = " .. tostring(n:getPullFilter()))
end

--@api: LGraphNode:getOverflowPolicy
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    print("overflow = " .. tostring(n:getOverflowPolicy() or "reject"))
end

--@api: LGraphNode:setOverflowPolicy
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setOverflowPolicy("destroy")
    print("overflow = " .. tostring(n:getOverflowPolicy() or "destroy"))
end

--@api: LGraphNode:isQueueEnabled
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    print("queue enabled = " .. tostring(n:isQueueEnabled()))
end

--@api: LGraphNode:setQueueEnabled
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setQueueEnabled(true)
    print("queue enabled = " .. tostring(n:isQueueEnabled()))
end

--@api: LGraphNode:getQueueCapacity
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    print("queue cap = " .. n:getQueueCapacity())
end

--@api: LGraphNode:setQueueCapacity
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setQueueCapacity(10)
    print("queue cap = " .. n:getQueueCapacity())
end

--@api: LGraphNode:getQueueSize
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    print("queue size = " .. n:getQueueSize())
end

--@api: LGraphNode:enqueue
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

--@api: LGraphNode:dequeue
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

--@api: LGraphNode:addTag
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addTag("important")
    print("tag added")
end

--@api: LGraphNode:hasTag
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addTag("vip")
    print("has vip = " .. tostring(n:hasTag("vip")))
end

--@api: LGraphNode:getTags
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addTag("a")
    n:addTag("b")
    local tags = n:getTags()
    print("tags = " .. #tags)
end

--@api: LGraphNode:removeTag
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addTag("temp")
    local ok = n:removeTag("temp")
    print("removed = " .. tostring(ok))
end

--@api: LGraphNode:clearTags
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addTag("x")
    n:addTag("y")
    n:clearTags()
    print("tags cleared")
end

--@api: LGraphNode:type
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    print("type = " .. n:type())
end

--@api: LGraphNode:typeOf
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    print("is GraphNode = " .. tostring(n:typeOf("LGraphNode")))
end

--- Graph Module Part 3: LGraphEdge and LGraphItem methods

--@api: LGraphEdge:getFrom
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode("src"), g:addNode("dst")
    local e = g:addEdge(a, b)
    local from = e:getFrom()
    print("from type = " .. from:getType())
end

--@api: LGraphEdge:getTo
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode("target")
    local e = g:addEdge(a, b)
    local to = e:getTo()
    print("to type = " .. to:getType())
end

--@api: LGraphEdge:getType
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b, "conveyor")
    print("edge type = " .. e:getType())
end

--@api: LGraphEdge:setType
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:setType("rail")
    print("edge type = " .. e:getType())
end

--@api: LGraphEdge:getWeight
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    print("weight = " .. e:getWeight())
end

--@api: LGraphEdge:setWeight
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:setWeight(3.5)
    print("weight = " .. e:getWeight())
end

--@api: LGraphEdge:getTravelTime
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    print("travel time = " .. e:getTravelTime())
end

--@api: LGraphEdge:setTravelTime
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:setTravelTime(5.0)
    print("travel time = " .. e:getTravelTime())
end

--@api: LGraphEdge:getCapacity
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    print("capacity = " .. e:getCapacity())
end

--@api: LGraphEdge:setCapacity
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:setCapacity(10)
    print("capacity = " .. e:getCapacity())
end

--@api: LGraphEdge:getReservedCapacity
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    e:setCapacity(4)
    e:reserveCapacity("planner-a", 2)
    print("reserved capacity = " .. e:getReservedCapacity())
end

--@api: LGraphEdge:getAvailableCapacity
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    e:setCapacity(4)
    e:reserveCapacity("planner-a", 2)
    print("available capacity = " .. e:getAvailableCapacity())
end

--@api: LGraphEdge:reserveCapacity
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    e:setCapacity(4)
    local ok = e:reserveCapacity("planner-a", 2)
    print("reservation accepted = " .. tostring(ok))
end

--@api: LGraphEdge:releaseCapacityReservation
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    e:setCapacity(4)
    e:reserveCapacity("planner-a", 2)
    local released = e:releaseCapacityReservation("planner-a", 1)
    print("released slots = " .. released)
end

--@api: LGraphEdge:clearCapacityReservations
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    e:setCapacity(4)
    e:reserveCapacity("planner-a", 2)
    e:clearCapacityReservations()
    print("reserved capacity = " .. e:getReservedCapacity())
end

--@api: LGraphEdge:getSpeedModifier
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    print("speed mod = " .. e:getSpeedModifier())
end

--@api: LGraphEdge:setSpeedModifier
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:setSpeedModifier(2.0)
    print("speed mod = " .. e:getSpeedModifier())
end

--@api: LGraphEdge:getThroughput
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    print("throughput = " .. e:getThroughput())
end

--@api: LGraphEdge:setThroughput
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:setThroughput(100)
    print("throughput = " .. e:getThroughput())
end

--@api: LGraphEdge:getCooldown
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    print("cooldown = " .. e:getCooldown())
end

--@api: LGraphEdge:setCooldown
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:setCooldown(1.0)
    print("cooldown = " .. e:getCooldown())
end

--@api: LGraphEdge:isOnCooldown
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    print("on cooldown = " .. tostring(e:isOnCooldown()))
end

--@api: LGraphEdge:isActive
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    print("active = " .. tostring(e:isActive()))
end

--@api: LGraphEdge:setActive
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:setActive(false)
    print("active = " .. tostring(e:isActive()))
end

--@api: LGraphEdge:isBidirectional
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    print("bidi = " .. tostring(e:isBidirectional()))
end

--@api: LGraphEdge:setBidirectional
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:setBidirectional(true)
    print("bidi = " .. tostring(e:isBidirectional()))
end

--@api: LGraphEdge:addAllowedType
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:addAllowedType("iron")
    print("iron allowed")
end

--@api: LGraphEdge:isItemTypeAllowed
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:addAllowedType("gold")
    print("gold allowed = " .. tostring(e:isItemTypeAllowed("gold")))
end

--@api: LGraphEdge:removeAllowedType
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:addAllowedType("coal")
    local ok = e:removeAllowedType("coal")
    print("removed = " .. tostring(ok))
end

--@api: LGraphEdge:clearAllowedTypes
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:addAllowedType("x")
    e:clearAllowedTypes()
    print("allow list cleared")
end

--@api: LGraphEdge:getItemsInTransit
do
    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    local items = e:getItemsInTransit()
    print("in transit = " .. #items)
end

--@api: LGraphEdge:type
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    print("type = " .. e:type())
end

--@api: LGraphEdge:typeOf
do
    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    print("is GraphEdge = " .. tostring(e:typeOf("LGraphEdge")))
end

--@api: LGraphItem:getType
do
    local g = lurek.graph.newGraph()
    local item = g:createItem("ore")
    print("item type = " .. item:getType())
end

--@api: LGraphItem:setType
do
    local g = lurek.graph.newGraph()
    local item = g:createItem("raw")
    item:setType("processed")
    print("item type = " .. item:getType())
end

--@api: LGraphItem:getPriority
do
    local g = lurek.graph.newGraph()
    local item = g:createItem()
    print("priority = " .. item:getPriority())
end

--@api: LGraphItem:setPriority
do
    local g = lurek.graph.newGraph()
    local item = g:createItem()
    item:setPriority(5)
    print("priority = " .. item:getPriority())
end

--@api: LGraphItem:getDecayTime
do
    local g = lurek.graph.newGraph()
    local item = g:createItem("food", 30.0)
    print("decay time = " .. item:getDecayTime())
end

--@api: LGraphItem:setDecayTime
do
    local g = lurek.graph.newGraph()
    local item = g:createItem("fruit")
    item:setDecayTime(60.0)
    print("decay time = " .. item:getDecayTime())
end

--@api: LGraphItem:getRemainingLife
do
    local g = lurek.graph.newGraph()
    local item = g:createItem("milk", 10.0)
    print("remaining = " .. item:getRemainingLife())
end

--@api: LGraphItem:isAlive
do
    local g = lurek.graph.newGraph()
    local item = g:createItem()
    print("alive = " .. tostring(item:isAlive()))
end

--@api: LGraphItem:kill
do
    local g = lurek.graph.newGraph()
    local item = g:createItem()
    item:kill()
    print("alive after kill = " .. tostring(item:isAlive()))
end

--@api: LGraphItem:getPosition
do
    local g = lurek.graph.newGraph()
    local n = g:addNode()
    local item = g:createItem("box")
    g:addItem(item, n)
    print("item is on a node = " .. tostring(item:getPosition() ~= nil))
end

--@api: LGraphItem:type
do
    local g = lurek.graph.newGraph()
    local item = g:createItem()
    print("type = " .. item:type())
end

--@api: LGraphItem:typeOf
do
    local g = lurek.graph.newGraph()
    local item = g:createItem()
    print("is GraphItem = " .. tostring(item:typeOf("LGraphItem")))
end

--@api: LGraph:addEdgeUnchecked
do
    local g = lurek.graph.newGraph()
    local a = g:addNode("hub")
    local b = g:addNode("sink")
    local edge = g:addEdgeUnchecked(a, b, "belt")
    print("edge type = " .. edge:getType())
    print("edge count = " .. g:getEdgeCount())
end

--@api: LGraph:batchAddNodes
do
    local g = lurek.graph.newGraph()
    local ids = g:batchAddNodes(3, { node_type = "router", capacity = 4 })
    local nodes = g:getNodes()
    print("created ids = " .. #ids)
    print("node count = " .. g:getNodeCount())
    print("first node type = " .. nodes[1]:getType())
end

--@api: LGraph:batchAddEdges
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

--@api: LGraph:batchStep
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
