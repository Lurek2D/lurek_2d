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

print("graph_01.lua")
