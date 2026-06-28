-- content/examples/flownet.lua
-- Auto-generated from content/examples2/graph_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/flownet.lua


--- Graph Module Part 1: factory, LGraph core (nodes, edges, items, pathfinding, stats)


--@api: lurek.graph.newGraph
do

    local g = lurek.graph.newGraph()
    local mine = g:addNode("mine", 24)
    local depot = g:addNode("depot", 48)
    g:addEdge(mine, depot, "belt")
    lurek.log.info("fresh network nodes=" .. g:getNodeCount() .. " edges=" .. g:getEdgeCount())
end

--@api: LGraph:addNode
do

    local g = lurek.graph.newGraph()
    local source = g:addNode("warehouse", 100)
    local sink = g:addNode("factory", 40)
    local edge = g:addEdge(source, sink, "road")
    local source_type = source:getType()
    lurek.log.info("added " .. source_type .. " linked by " .. edge:getType() .. " to " .. sink:getType())
end

--@api: LGraph:addEdge
do

    local g = lurek.graph.newGraph()
    local a = g:addNode("src")
    local b = g:addNode("dst")
    local e = g:addEdge(a, b, "road")
    lurek.log.info("edge type = " .. e:type())
end

--@api: LGraph:createItem
do

    local g = lurek.graph.newGraph()
    local store = g:addNode("storage", 8)
    local item = g:createItem("ore", 10.0)
    g:addItem(item, store)
    local kind = item:getType()
    lurek.log.info("created " .. kind .. " for " .. store:getType())
end

--@api: LGraph:addItem
do

    local g = lurek.graph.newGraph()
    local n = g:addNode("storage")
    local item = g:createItem("wood")
    g:addItem(item, n)
    lurek.log.info("item placed on node")
end

--@api: LGraph:removeNode
do

    local g = lurek.graph.newGraph()
    local n = g:addNode("buffer", 4)
    g:addNode("sink", 4)
    local ok = g:removeNode(n)
    local remaining = g:getNodeCount()
    lurek.log.info("removed buffer=" .. tostring(ok) .. " remaining=" .. remaining)
end

--@api: LGraph:removeEdge
do

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    local ok = g:removeEdge(e)
    lurek.log.info("removed edge = " .. tostring(ok))
end

--@api: LGraph:removeItem
do

    local g = lurek.graph.newGraph()
    local junkyard = g:addNode("junkyard", 8)
    local item = g:createItem("scrap")
    g:addItem(item, junkyard)
    local ok = g:removeItem(item)
    local remaining = g:getItemCount()
    lurek.log.info("removed scrap=" .. tostring(ok) .. " items=" .. remaining)
end

--@api: LGraph:hasNode
do

    local g = lurek.graph.newGraph()
    local n = g:addNode("source", 8)
    g:addNode("sink", 8)
    local present = g:hasNode(n)
    local count = g:getNodeCount()
    lurek.log.info("source present=" .. tostring(present) .. " node count=" .. count)
end

--@api: LGraph:hasEdge
do

    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    lurek.log.info("has edge = " .. tostring(g:hasEdge(e)))
end

--@api: LGraph:hasItem
do

    local g = lurek.graph.newGraph()
    local store = g:addNode("store", 4)
    local item = g:createItem("parcel")
    g:addItem(item, store)
    local present = g:hasItem(item)
    lurek.log.info("parcel tracked=" .. tostring(present) .. " items=" .. g:getItemCount())
end

--@api: LGraph:getNodeCount
do

    local g = lurek.graph.newGraph()
    g:addNode("mine", 8)
    g:addNode("smelter", 8)
    g:addNode("warehouse", 16)
    local count = g:getNodeCount()
    lurek.log.info("factory line nodes=" .. count)
end

--@api: LGraph:getEdgeCount
do

    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    g:addEdge(a, b)
    lurek.log.info("edges = " .. g:getEdgeCount())
end

--@api: LGraph:getItemCount
do

    local g = lurek.graph.newGraph()
    local storage = g:addNode("storage", 12)
    g:addItem(g:createItem("iron"), storage)
    g:addItem(g:createItem("coal"), storage)
    local count = g:getItemCount()
    lurek.log.info("inventory items=" .. count)
end

--@api: LGraph:getNodes
do

    local g = lurek.graph.newGraph()
    g:addNode("x")
    g:addNode("y")
    local nodes = g:getNodes()
    lurek.log.info("node list = " .. #nodes)
end

--@api: LGraph:getEdges
do

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addEdge(a, b)
    local edges = g:getEdges()
    lurek.log.info("edge list = " .. #edges)
end

--@api: LGraph:getItems
do

    local g = lurek.graph.newGraph()
    local storage = g:addNode("storage", 12)
    g:addItem(g:createItem("iron"), storage)
    g:addItem(g:createItem("copper"), storage)
    local items = g:getItems()
    local first_type = items[1] and items[1]:getType() or "none"
    lurek.log.info("item list=" .. #items .. " first=" .. first_type)
end

--@api: LGraph:getNeighbors
do

    local g = lurek.graph.newGraph()
    local a, b, c = g:addNode(), g:addNode(), g:addNode()
    g:addEdge(a, b)
    g:addEdge(a, c)
    local neighbors = g:getNeighbors(a)
    lurek.log.info("neighbors of a = " .. #neighbors)
end

--@api: LGraph:getEdgeBetween
do

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addEdge(a, b, "pipe")
    local e = g:getEdgeBetween(a, b)
    lurek.log.info("edge between a-b exists = " .. tostring(e ~= nil))
end

--@api: LGraph:findPath
do

    local g = lurek.graph.newGraph()
    local a, b, c = g:addNode(), g:addNode(), g:addNode()
    g:addEdge(a, b)
    g:addEdge(b, c)
    local result = g:findPath(a, c)
    lurek.log.info("path found = " .. tostring(result ~= nil))
end

--@api: LGraph:findPathForItem
do

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addEdge(a, b)
    local item = g:createItem("cargo")
    local result = g:findPathForItem(item, a, b)
    lurek.log.info("item path found = " .. tostring(result ~= nil))
end

--@api: LGraph:astar
do

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addEdge(a, b)
    local path = g:astar(a, b)
    lurek.log.info("astar path = " .. tostring(path ~= nil))
end

--@api: LGraph:getDistance
do

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addEdge(a, b)
    local d = g:getDistance(a, b)
    lurek.log.info("distance = " .. tostring(d))
end

--@api: LGraph:getReachable
do

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addEdge(a, b)
    local reachable = g:getReachable(a, 5.0)
    lurek.log.info("reachable = " .. #reachable)
end

--@api: LGraph:getStats
do

    local g = lurek.graph.newGraph()
    g:addNode()
    g:addNode()
    local stats = g:getStats()
    lurek.log.info("nodes=" .. stats.nodes .. " edges=" .. stats.edges .. " items=" .. stats.items)
end

--@api: LGraph:hasCycle
do

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addEdge(a, b)
    g:addEdge(b, a)
    lurek.log.info("has cycle = " .. tostring(g:hasCycle()))
end

--@api: LGraph:isBipartite
do

    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    g:addEdge(a, b)
    lurek.log.info("bipartite = " .. tostring(g:isBipartite()))
end

--@api: LGraph:topologicalSort
do

    local g = lurek.graph.newGraph()
    local a, b, c = g:addNode(), g:addNode(), g:addNode()
    g:addEdge(a, b)
    g:addEdge(b, c)
    local sorted = g:topologicalSort()
    lurek.log.info("topo sort = " .. tostring(sorted ~= nil))
end

--@api: LGraph:mst
do

    local g = lurek.graph.newGraph()
    local a, b, c = g:addNode(), g:addNode(), g:addNode()
    g:addEdge(a, b)
    g:addEdge(b, c)
    g:addEdge(a, c)
    local tree = g:mst()
    lurek.log.info("MST edges = " .. #tree)
end

--@api: LGraph:colorGraph
do

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addEdge(a, b)
    local colors = g:colorGraph()
    lurek.log.info("coloring type = " .. type(colors))
end

--@api: LGraph:getComponents
do

    local g = lurek.graph.newGraph()
    g:addNode()
    g:addNode()
    local comps = g:getComponents()
    lurek.log.info("components = " .. #comps)
end

--@api: LGraph:subgraph
do

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addNode()
    local sub = g:subgraph({a, b})
    lurek.log.info("subgraph nodes = " .. sub:getNodeCount())
end

--@api: LGraph:sendItem
do

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e, item = g:addEdge(a, b), g:createItem("package")
    g:addItem(item, a)
    g:sendItem(item, e)
    lurek.log.info("item sent along edge")
end

--@api: LGraph:on
do

    local g = lurek.graph.newGraph()
    g:on("itemEnter", function(item, node)
        lurek.log.info("item arrived at node")
    end)
    lurek.log.info("callback registered")
end

--@api: LGraph:step
do

    local g = lurek.graph.newGraph()
    local mine = g:addNode("mine", 8)
    local factory = g:addNode("factory", 8)
    g:addEdge(mine, factory, "belt")
    g:step()
    lurek.log.info("step processed " .. g:getNodeCount() .. " nodes")
end

--@api: LGraph:update
do

    local g = lurek.graph.newGraph()
    local mine = g:addNode("mine", 8)
    local factory = g:addNode("factory", 8)
    g:addEdge(mine, factory, "belt")
    g:update(0.016)
    lurek.log.info("update advanced " .. g:getEdgeCount() .. " edge(s)")
end

--@api: LGraph:tickParallel
do

    local g = lurek.graph.newGraph()
    local mine = g:addNode("mine", 8)
    local factory = g:addNode("factory", 8)
    g:addEdge(mine, factory, "belt")
    g:tickParallel(0.016)
    lurek.log.info("parallel tick ran on " .. g:getNodeCount() .. " nodes")
end

--@api: LGraph:processDemand
do

    local g = lurek.graph.newGraph()
    local mine = g:addNode("mine", 8)
    local factory = g:addNode("factory", 8)
    g:addEdge(mine, factory, "belt")
    g:processDemand()
    lurek.log.info("demand pass scanned " .. g:getEdgeCount() .. " edge(s)")
end

--@api: LGraph:type
do

    local g = lurek.graph.newGraph()
    local mine = g:addNode("mine", 8)
    g:addNode("depot", 8)
    local type_name = g:type()
    local present = g:hasNode(mine)
    lurek.log.info(type_name .. " tracks source=" .. tostring(present))
end

--@api: LGraph:typeOf
do

    local g = lurek.graph.newGraph()
    local mine = g:addNode("mine", 8)
    local is_graph = g:typeOf("LGraph")
    local is_object = g:typeOf("LObject")
    local node_count = g:getNodeCount()
    lurek.log.info("typeOf graph=" .. tostring(is_graph) .. " object=" .. tostring(is_object) .. " nodes=" .. node_count)
end

--- Graph Module Part 2: LGraphNode methods

--@api: LGraphNode:getType
do

    local g = lurek.graph.newGraph()
    local n = g:addNode("factory")
    n:addTag("smelting")
    local node_type = n:getType()
    local tags = n:getTags()
    lurek.log.info("node type=" .. node_type .. " tags=" .. #tags)
end

--@api: LGraphNode:setType
do

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setType("warehouse")
    n:setCapacity(24)
    local node_type = n:getType()
    lurek.log.info("retagged node=" .. node_type .. " capacity=" .. n:getCapacity())
end

--@api: LGraphNode:getCapacity
do

    local g = lurek.graph.newGraph()
    local n = g:addNode("store", 50)
    n:addTag("buffer")
    local capacity = n:getCapacity()
    local node_type = n:getType()
    lurek.log.info(node_type .. " capacity=" .. capacity)
end

--@api: LGraphNode:setCapacity
do

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setCapacity(200)
    n:setType("depot")
    local capacity = n:getCapacity()
    lurek.log.info(n:getType() .. " capacity=" .. capacity)
end

--@api: LGraphNode:getReservedCapacity
do

    local g = lurek.graph.newGraph()
    local n = g:addNode("warehouse", 5)
    n:reserveCapacity("planner-a", 2)
    local reserved = n:getReservedCapacity()
    local free = n:getAvailableCapacity()
    lurek.log.info("reserved=" .. reserved .. " free=" .. free)
end

--@api: LGraphNode:getAvailableCapacity
do

    local g = lurek.graph.newGraph()
    local n = g:addNode("warehouse", 5)
    n:reserveCapacity("planner-a", 2)
    local free = n:getAvailableCapacity()
    local reserved = n:getReservedCapacity()
    lurek.log.info("warehouse free=" .. free .. " reserved=" .. reserved)
end

--@api: LGraphNode:reserveCapacity
do

    local g = lurek.graph.newGraph()
    local n = g:addNode("warehouse", 5)
    local ok = n:reserveCapacity("planner-a", 2)
    local reserved = n:getReservedCapacity()
    local free = n:getAvailableCapacity()
    lurek.log.info("reservation ok=" .. tostring(ok) .. " reserved=" .. reserved .. " free=" .. free)
end

--@api: LGraphNode:releaseCapacityReservation
do

    local g = lurek.graph.newGraph()
    local n = g:addNode("warehouse", 5)
    n:reserveCapacity("planner-a", 2)
    local released = n:releaseCapacityReservation("planner-a", 1)
    lurek.log.info("released slots = " .. released)
end

--@api: LGraphNode:clearCapacityReservations
do

    local g = lurek.graph.newGraph()
    local n = g:addNode("warehouse", 5)
    n:reserveCapacity("planner-a", 2)
    n:clearCapacityReservations()
    lurek.log.info("reserved capacity = " .. n:getReservedCapacity())
end

--@api: LGraphNode:isActive
do

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setType("router")
    local active = n:isActive()
    local node_type = n:getType()
    lurek.log.info(node_type .. " active=" .. tostring(active))
end

--@api: LGraphNode:setActive
do

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setActive(false)
    n:setType("router")
    local active = n:isActive()
    lurek.log.info(n:getType() .. " active=" .. tostring(active))
end

--@api: LGraphNode:isFull
do

    local g = lurek.graph.newGraph()
    local n = g:addNode("bin", 1)
    local item = g:createItem("crate")
    g:addItem(item, n)
    local full = n:isFull()
    lurek.log.info("bin full=" .. tostring(full) .. " items=" .. n:getItemCount())
end

--@api: LGraphNode:getItemCount
do

    local g = lurek.graph.newGraph()
    local n = g:addNode("stockpile", 4)
    g:addItem(g:createItem("ore"), n)
    g:addItem(g:createItem("coal"), n)
    local items = n:getItemCount()
    lurek.log.info("stockpile items=" .. items)
end

--@api: LGraphNode:getItems
do

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    g:addItem(g:createItem("ore"), n)
    local items = n:getItems()
    lurek.log.info("node items = " .. #items)
end

--@api: LGraphNode:getEdges
do

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addEdge(a, b)
    local edges = a:getEdges("both")
    lurek.log.info("edges = " .. #edges)
end

--@api: LGraphNode:addSupply
do

    local g = lurek.graph.newGraph()
    local n = g:addNode("mine")
    n:addSupply("iron", 10)
    n:setPushRate(4)
    local stats = g:getStats()
    lurek.log.info("mine supply registered on " .. n:getType() .. " nodes=" .. stats.nodes)
end

--@api: LGraphNode:removeSupply
do

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addSupply("wood", 5)
    local ok = n:removeSupply("wood")
    lurek.log.info("removed supply = " .. tostring(ok))
end

--@api: LGraphNode:clearSupplies
do

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addSupply("a", 1)
    n:addSupply("b", 2)
    n:clearSupplies()
    lurek.log.info("supplies cleared")
end

--@api: LGraphNode:addDemand
do

    local g = lurek.graph.newGraph()
    local n = g:addNode("factory")
    n:addDemand("iron", 5, 1)
    n:setPullRate(3)
    local stats = g:getStats()
    lurek.log.info("factory demand registered nodes=" .. stats.nodes .. " edges=" .. stats.edges)
end

--@api: LGraphNode:removeDemand
do

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addDemand("coal", 3)
    local ok = n:removeDemand("coal")
    lurek.log.info("removed demand = " .. tostring(ok))
end

--@api: LGraphNode:clearDemands
do

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addDemand("x", 1)
    n:clearDemands()
    lurek.log.info("demands cleared")
end

--@api: LGraphNode:setConversion
do

    local g = lurek.graph.newGraph()
    local n = g:addNode("smelter")
    n:setConversion("iron_ore", "iron_bar", 2, 1)
    n:setProcessTime(2.5)
    local process_time = n:getProcessTime()
    lurek.log.info("smelter converts ore -> bar in " .. process_time .. "s")
end

--@api: LGraphNode:clearConversion
do

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setConversion("a", "b")
    local ok = n:clearConversion("a")
    lurek.log.info("cleared conversion = " .. tostring(ok))
end

--@api: LGraphNode:clearAllConversions
do

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setConversion("a", "b")
    n:setConversion("c", "d")
    n:clearAllConversions()
    lurek.log.info("all conversions cleared")
end

--@api: LGraphNode:getProcessTime
do

    local g = lurek.graph.newGraph()
    local n = g:addNode("assembler")
    n:setConversion("plate", "gear", 2, 1)
    local process_time = n:getProcessTime()
    lurek.log.info("assembler process time=" .. process_time)
end

--@api: LGraphNode:setProcessTime
do

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setProcessTime(2.5)
    n:setConversion("ore", "ingot", 1, 1)
    local process_time = n:getProcessTime()
    lurek.log.info("custom process time=" .. process_time)
end

--@api: LGraphNode:getFlowMode
do

    local g = lurek.graph.newGraph()
    local n = g:addNode("router")
    n:setPushRate(2)
    local mode = n:getFlowMode()
    lurek.log.info("router flow mode=" .. mode)
end

--@api: LGraphNode:setFlowMode
do

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setFlowMode("push")
    n:setPushRate(5)
    local mode = n:getFlowMode()
    lurek.log.info("node flow mode=" .. mode .. " push=" .. n:getPushRate())
end

--@api: LGraphNode:getPushRate
do

    local g = lurek.graph.newGraph()
    local n = g:addNode("mine")
    n:setFlowMode("push")
    local push_rate = n:getPushRate()
    lurek.log.info("push rate=" .. push_rate)
end

--@api: LGraphNode:setPushRate
do

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setPushRate(5)
    n:setFlowMode("push")
    local push_rate = n:getPushRate()
    lurek.log.info("configured push rate=" .. push_rate)
end

--@api: LGraphNode:getPullRate
do

    local g = lurek.graph.newGraph()
    local n = g:addNode("factory")
    n:setFlowMode("pull")
    local pull_rate = n:getPullRate()
    lurek.log.info("pull rate=" .. pull_rate)
end

--@api: LGraphNode:setPullRate
do

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setPullRate(3)
    n:setFlowMode("pull")
    local pull_rate = n:getPullRate()
    lurek.log.info("configured pull rate=" .. pull_rate)
end

--@api: LGraphNode:getPushFilter
do

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    local f = n:getPushFilter()
    n:setType("mine")
    local node_type = n:getType()
    lurek.log.info(node_type .. " push filter=" .. tostring(f))
end

--@api: LGraphNode:setPushFilter
do

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setPushFilter("iron")
    n:setPushRate(4)
    local filter = n:getPushFilter()
    lurek.log.info("push filter=" .. tostring(filter) .. " rate=" .. n:getPushRate())
end

--@api: LGraphNode:getPullFilter
do

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    local f = n:getPullFilter()
    n:setType("assembler")
    local node_type = n:getType()
    lurek.log.info(node_type .. " pull filter=" .. tostring(f))
end

--@api: LGraphNode:setPullFilter
do

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setPullFilter("wood")
    n:setPullRate(2)
    local filter = n:getPullFilter()
    lurek.log.info("pull filter=" .. tostring(filter) .. " rate=" .. n:getPullRate())
end

--@api: LGraphNode:getOverflowPolicy
do

    local g = lurek.graph.newGraph()
    local n = g:addNode("buffer", 2)
    n:setQueueEnabled(true)
    local policy = n:getOverflowPolicy() or "reject"
    lurek.log.info("overflow policy=" .. tostring(policy))
end

--@api: LGraphNode:setOverflowPolicy
do

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setOverflowPolicy("destroy")
    n:setCapacity(1)
    local policy = n:getOverflowPolicy() or "destroy"
    lurek.log.info("overflow policy=" .. tostring(policy) .. " cap=" .. n:getCapacity())
end

--@api: LGraphNode:isQueueEnabled
do

    local g = lurek.graph.newGraph()
    local n = g:addNode("buffer")
    n:setQueueCapacity(4)
    local enabled = n:isQueueEnabled()
    lurek.log.info("queue enabled=" .. tostring(enabled) .. " cap=" .. n:getQueueCapacity())
end

--@api: LGraphNode:setQueueEnabled
do

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setQueueEnabled(true)
    n:setQueueCapacity(4)
    local enabled = n:isQueueEnabled()
    lurek.log.info("queue enabled=" .. tostring(enabled) .. " cap=" .. n:getQueueCapacity())
end

--@api: LGraphNode:getQueueCapacity
do

    local g = lurek.graph.newGraph()
    local n = g:addNode("buffer")
    n:setQueueEnabled(true)
    local cap = n:getQueueCapacity()
    lurek.log.info("queue capacity=" .. cap)
end

--@api: LGraphNode:setQueueCapacity
do

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setQueueCapacity(10)
    n:setQueueEnabled(true)
    local cap = n:getQueueCapacity()
    lurek.log.info("queue capacity=" .. cap)
end

--@api: LGraphNode:getQueueSize
do

    local g = lurek.graph.newGraph()
    local n = g:addNode("buffer")
    n:setQueueEnabled(true)
    local queue_size = n:getQueueSize()
    lurek.log.info("queue size=" .. queue_size)
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
    lurek.log.info("queue size = " .. n:getQueueSize())
    lurek.log.info("enqueued = " .. tostring(queued))
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
    lurek.log.info("queue size = " .. n:getQueueSize())
    lurek.log.info("dequeued = " .. tostring(out ~= nil))
end

--@api: LGraphNode:addTag
do

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addTag("important")
    n:setType("hub")
    local tags = n:getTags()
    lurek.log.info(n:getType() .. " tags=" .. #tags)
end

--@api: LGraphNode:hasTag
do

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addTag("vip")
    n:addTag("priority")
    local has_vip = n:hasTag("vip")
    lurek.log.info("has vip=" .. tostring(has_vip) .. " tags=" .. #n:getTags())
end

--@api: LGraphNode:getTags
do

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addTag("a")
    n:addTag("b")
    local tags = n:getTags()
    lurek.log.info("tags = " .. #tags)
end

--@api: LGraphNode:removeTag
do

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addTag("temp")
    local ok = n:removeTag("temp")
    lurek.log.info("removed = " .. tostring(ok))
end

--@api: LGraphNode:clearTags
do

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addTag("x")
    n:addTag("y")
    n:clearTags()
    lurek.log.info("tags cleared")
end

--@api: LGraphNode:type
do

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setType("terminal")
    local type_name = n:type()
    local node_type = n:getType()
    lurek.log.info(type_name .. " node_type=" .. node_type)
end

--@api: LGraphNode:typeOf
do

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setType("terminal")
    local is_node = n:typeOf("LGraphNode")
    local is_object = n:typeOf("LObject")
    lurek.log.info("node typeOf=" .. tostring(is_node) .. " object=" .. tostring(is_object))
end

--- Graph Module Part 3: LGraphEdge and LGraphItem methods

--@api: LGraphEdge:getFrom
do

    local g = lurek.graph.newGraph()
    local a, b = g:addNode("src"), g:addNode("dst")
    local e = g:addEdge(a, b)
    local from = e:getFrom()
    lurek.log.info("from type = " .. from:getType())
end

--@api: LGraphEdge:getTo
do

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode("target")
    local e = g:addEdge(a, b)
    local to = e:getTo()
    lurek.log.info("to type = " .. to:getType())
end

--@api: LGraphEdge:getType
do

    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b, "conveyor")
    lurek.log.info("edge type = " .. e:getType())
end

--@api: LGraphEdge:setType
do

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:setType("rail")
    lurek.log.info("edge type = " .. e:getType())
end

--@api: LGraphEdge:getWeight
do

    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    lurek.log.info("weight = " .. e:getWeight())
end

--@api: LGraphEdge:setWeight
do

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:setWeight(3.5)
    lurek.log.info("weight = " .. e:getWeight())
end

--@api: LGraphEdge:getTravelTime
do

    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    lurek.log.info("travel time = " .. e:getTravelTime())
end

--@api: LGraphEdge:setTravelTime
do

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:setTravelTime(5.0)
    lurek.log.info("travel time = " .. e:getTravelTime())
end

--@api: LGraphEdge:getCapacity
do

    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    lurek.log.info("capacity = " .. e:getCapacity())
end

--@api: LGraphEdge:setCapacity
do

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:setCapacity(10)
    lurek.log.info("capacity = " .. e:getCapacity())
end

--@api: LGraphEdge:getReservedCapacity
do

    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    e:setCapacity(4)
    e:reserveCapacity("planner-a", 2)
    lurek.log.info("reserved capacity = " .. e:getReservedCapacity())
end

--@api: LGraphEdge:getAvailableCapacity
do

    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    e:setCapacity(4)
    e:reserveCapacity("planner-a", 2)
    lurek.log.info("available capacity = " .. e:getAvailableCapacity())
end

--@api: LGraphEdge:reserveCapacity
do

    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    e:setCapacity(4)
    local ok = e:reserveCapacity("planner-a", 2)
    lurek.log.info("reservation accepted = " .. tostring(ok))
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
    lurek.log.info("released slots = " .. released)
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
    lurek.log.info("reserved capacity = " .. e:getReservedCapacity())
end

--@api: LGraphEdge:getSpeedModifier
do

    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    lurek.log.info("speed mod = " .. e:getSpeedModifier())
end

--@api: LGraphEdge:setSpeedModifier
do

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:setSpeedModifier(2.0)
    lurek.log.info("speed mod = " .. e:getSpeedModifier())
end

--@api: LGraphEdge:getThroughput
do

    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    lurek.log.info("throughput = " .. e:getThroughput())
end

--@api: LGraphEdge:setThroughput
do

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:setThroughput(100)
    lurek.log.info("throughput = " .. e:getThroughput())
end

--@api: LGraphEdge:getCooldown
do

    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    lurek.log.info("cooldown = " .. e:getCooldown())
end

--@api: LGraphEdge:setCooldown
do

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:setCooldown(1.0)
    lurek.log.info("cooldown = " .. e:getCooldown())
end

--@api: LGraphEdge:isOnCooldown
do

    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    lurek.log.info("on cooldown = " .. tostring(e:isOnCooldown()))
end

--@api: LGraphEdge:isActive
do

    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    lurek.log.info("active = " .. tostring(e:isActive()))
end

--@api: LGraphEdge:setActive
do

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:setActive(false)
    lurek.log.info("active = " .. tostring(e:isActive()))
end

--@api: LGraphEdge:isBidirectional
do

    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    lurek.log.info("bidi = " .. tostring(e:isBidirectional()))
end

--@api: LGraphEdge:setBidirectional
do

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:setBidirectional(true)
    lurek.log.info("bidi = " .. tostring(e:isBidirectional()))
end

--@api: LGraphEdge:addAllowedType
do

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:addAllowedType("iron")
    lurek.log.info("iron allowed")
end

--@api: LGraphEdge:isItemTypeAllowed
do

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:addAllowedType("gold")
    lurek.log.info("gold allowed = " .. tostring(e:isItemTypeAllowed("gold")))
end

--@api: LGraphEdge:removeAllowedType
do

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:addAllowedType("coal")
    local ok = e:removeAllowedType("coal")
    lurek.log.info("removed = " .. tostring(ok))
end

--@api: LGraphEdge:clearAllowedTypes
do

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:addAllowedType("x")
    e:clearAllowedTypes()
    lurek.log.info("allow list cleared")
end

--@api: LGraphEdge:getItemsInTransit
do

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    local items = e:getItemsInTransit()
    lurek.log.info("in transit = " .. #items)
end

--@api: LGraphEdge:type
do

    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    lurek.log.info("type = " .. e:type())
end

--@api: LGraphEdge:typeOf
do

    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    lurek.log.info("is GraphEdge = " .. tostring(e:typeOf("LGraphEdge")))
end

--@api: LGraphItem:getType
do

    local g = lurek.graph.newGraph()
    local item = g:createItem("ore")
    local storage = g:addNode("storage", 4)
    g:addItem(item, storage)
    local item_type = item:getType()
    lurek.log.info("item type=" .. item_type .. " on " .. storage:getType())
end

--@api: LGraphItem:setType
do

    local g = lurek.graph.newGraph()
    local item = g:createItem("raw")
    item:setType("processed")
    local storage = g:addNode("storage", 4)
    g:addItem(item, storage)
    local item_type = item:getType()
    lurek.log.info("retagged item=" .. item_type)
end

--@api: LGraphItem:getPriority
do

    local g = lurek.graph.newGraph()
    local item = g:createItem("parcel")
    local storage = g:addNode("storage", 4)
    g:addItem(item, storage)
    local priority = item:getPriority()
    lurek.log.info("parcel priority=" .. priority)
end

--@api: LGraphItem:setPriority
do

    local g = lurek.graph.newGraph()
    local item = g:createItem("parcel")
    item:setPriority(5)
    local storage = g:addNode("storage", 4)
    g:addItem(item, storage)
    local priority = item:getPriority()
    lurek.log.info("rush order priority=" .. priority)
end

--@api: LGraphItem:getDecayTime
do

    local g = lurek.graph.newGraph()
    local item = g:createItem("food", 30.0)
    local pantry = g:addNode("pantry", 6)
    g:addItem(item, pantry)
    local decay = item:getDecayTime()
    lurek.log.info("food decay=" .. decay)
end

--@api: LGraphItem:setDecayTime
do

    local g = lurek.graph.newGraph()
    local item = g:createItem("fruit")
    item:setDecayTime(60.0)
    local pantry = g:addNode("pantry", 6)
    g:addItem(item, pantry)
    local decay = item:getDecayTime()
    lurek.log.info("fruit decay=" .. decay)
end

--@api: LGraphItem:getRemainingLife
do

    local g = lurek.graph.newGraph()
    local item = g:createItem("milk", 10.0)
    local cooler = g:addNode("cooler", 6)
    g:addItem(item, cooler)
    local remaining = item:getRemainingLife()
    lurek.log.info("milk remaining=" .. remaining)
end

--@api: LGraphItem:isAlive
do

    local g = lurek.graph.newGraph()
    local item = g:createItem("drone_part")
    local store = g:addNode("store", 4)
    g:addItem(item, store)
    local alive = item:isAlive()
    lurek.log.info("drone part alive=" .. tostring(alive))
end

--@api: LGraphItem:kill
do

    local g = lurek.graph.newGraph()
    local item = g:createItem("waste")
    local dump = g:addNode("dump", 4)
    g:addItem(item, dump)
    item:kill()
    local alive = item:isAlive()
    lurek.log.info("waste alive after kill=" .. tostring(alive))
end

--@api: LGraphItem:getPosition
do

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    local item = g:createItem("box")
    g:addItem(item, n)
    lurek.log.info("item is on a node = " .. tostring(item:getPosition() ~= nil))
end

--@api: LGraphItem:type
do

    local g = lurek.graph.newGraph()
    local item = g:createItem("box")
    local store = g:addNode("store", 4)
    g:addItem(item, store)
    local type_name = item:type()
    lurek.log.info(type_name .. " item_type=" .. item:getType())
end

--@api: LGraphItem:typeOf
do

    local g = lurek.graph.newGraph()
    local item = g:createItem("box")
    local store = g:addNode("store", 4)
    g:addItem(item, store)
    local is_item = item:typeOf("LGraphItem")
    lurek.log.info("item typeOf=" .. tostring(is_item) .. " alive=" .. tostring(item:isAlive()))
end

--@api: LGraph:addEdgeUnchecked
do

    local g = lurek.graph.newGraph()
    local a = g:addNode("hub")
    local b = g:addNode("sink")
    local edge = g:addEdgeUnchecked(a, b, "belt")
    lurek.log.info("edge type = " .. edge:getType())
    lurek.log.info("edge count = " .. g:getEdgeCount())
end

--@api: LGraph:batchAddNodes
do

    local g = lurek.graph.newGraph()
    local ids = g:batchAddNodes(3, { node_type = "router", capacity = 4 })
    local nodes = g:getNodes()
    lurek.log.info("created ids = " .. #ids)
    lurek.log.info("node count = " .. g:getNodeCount())
    lurek.log.info("first node type = " .. nodes[1]:getType())
end

--@api: LGraph:batchAddEdges
do

    local g = lurek.graph.newGraph()
    local ids = g:batchAddNodes(3, { node_type = "router" })
    local edge_ids = g:batchAddEdges({
        { ids[1], ids[2], "lane" },
        { ids[2], ids[3], "lane" },
    })
    lurek.log.info("created edges = " .. #edge_ids)
    lurek.log.info("edge count = " .. g:getEdgeCount())
end

--@api: LGraph:batchStep
do

    local g = lurek.graph.newGraph()
    local ids = g:batchAddNodes(2, { node_type = "router" })
    g:batchAddEdges({
        { ids[1], ids[2], "lane" },
    })
    g:batchStep(0.25, 4)
    lurek.log.info("node count = " .. g:getNodeCount())
    lurek.log.info("edge count = " .. g:getEdgeCount())
end
