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

print("graph_02.lua")
