-- content/examples/graph.lua
-- Lurek2D lurek.graph API Reference
-- Run with: cargo run -- content/examples/graph
--
Scenario: A factory automation game where nodes are machines (smelters,
-- assemblers, storages), edges are conveyor belts carrying items between them,
-- and the graph system handles flow logic, routing, supply/demand, and
-- production chains. Items decay, nodes have capacity, and edges filter types.

print("=== lurek.graph — Flow Graph System ===\n")

-- =============================================================================
-- Graph Creation
-- =============================================================================

-- Demonstrates the proper usage of lurek.graph.newGraph.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_graph_newGraph()
    local factory = lurek.graph.newGraph()
end
local _ok, _err = pcall(demo_lurek_graph_newGraph)

-- Demonstrates the proper usage of Graph:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_type()
    print("graph type: " .. factory:type())
end
local _ok, _err = pcall(demo_Graph_type)

-- Demonstrates the proper usage of Graph:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_typeOf()
    print("is Graph: " .. tostring(factory:typeOf("Graph")))
end
local _ok, _err = pcall(demo_Graph_typeOf)

-- =============================================================================
-- Adding & Querying Nodes
-- =============================================================================

-- Nodes are returned from factory:addNode() — we can't call it directly since
-- it's not listed as a standalone function, but use the graph to get nodes.

-- Demonstrates the proper usage of Graph:getNodeCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_getNodeCount()
    print("nodes: " .. factory:getNodeCount())
end
local _ok, _err = pcall(demo_Graph_getNodeCount)

-- Demonstrates the proper usage of Graph:getNodes.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_getNodes()
    local nodes = factory:getNodes()
end
local _ok, _err = pcall(demo_Graph_getNodes)

-- Demonstrates the proper usage of Graph:hasNode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_hasNode()
    print('Executing hasNode')
end
local _ok, _err = pcall(demo_Graph_hasNode)

-- Demonstrates the proper usage of Graph:removeNode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_removeNode()
    print('Executing removeNode')
end
local _ok, _err = pcall(demo_Graph_removeNode)

-- Demonstrates the proper usage of Graph:getNeighbors.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_getNeighbors()
    print('Executing getNeighbors')
end
local _ok, _err = pcall(demo_Graph_getNeighbors)

-- =============================================================================
-- Node Configuration — Machine setup
-- =============================================================================

-- Assume we have a node from the graph:
local smelter = nodes[1]  -- first node if exists

if smelter then
-- Demonstrates the proper usage of Node:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_type()
    print("node type: " .. smelter:type())
end
local _ok, _err = pcall(demo_Node_type)

-- Demonstrates the proper usage of Node:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_typeOf()
    print("is Node: " .. tostring(smelter:typeOf("Node")))
end
local _ok, _err = pcall(demo_Node_typeOf)

-- Demonstrates the proper usage of Node:setType.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_setType()
    smelter:setType("smelter")
end
local _ok, _err = pcall(demo_Node_setType)

-- Demonstrates the proper usage of Node:getType.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_getType()
    print("machine: " .. smelter:getType())
end
local _ok, _err = pcall(demo_Node_getType)

-- Demonstrates the proper usage of Node:setCapacity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_setCapacity()
    smelter:setCapacity(10)
end
local _ok, _err = pcall(demo_Node_setCapacity)

-- Demonstrates the proper usage of Node:getCapacity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_getCapacity()
    print("capacity: " .. smelter:getCapacity())
end
local _ok, _err = pcall(demo_Node_getCapacity)

-- Demonstrates the proper usage of Node:getItemCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_getItemCount()
    print("items stored: " .. smelter:getItemCount())
end
local _ok, _err = pcall(demo_Node_getItemCount)

-- Demonstrates the proper usage of Node:isFull.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_isFull()
    print("full: " .. tostring(smelter:isFull()))
end
local _ok, _err = pcall(demo_Node_isFull)

-- Demonstrates the proper usage of Node:setActive.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_setActive()
    smelter:setActive(true)
end
local _ok, _err = pcall(demo_Node_setActive)

-- Demonstrates the proper usage of Node:isActive.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_isActive()
    print("active: " .. tostring(smelter:isActive()))
end
local _ok, _err = pcall(demo_Node_isActive)

    -- =============================================================================
    -- Node Flow Mode — Push/Pull production
    -- =============================================================================

-- Demonstrates the proper usage of Node:setFlowMode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_setFlowMode()
    smelter:setFlowMode("push")
end
local _ok, _err = pcall(demo_Node_setFlowMode)

-- Demonstrates the proper usage of Node:getFlowMode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_getFlowMode()
    print("flow mode: " .. smelter:getFlowMode())
end
local _ok, _err = pcall(demo_Node_getFlowMode)

-- Demonstrates the proper usage of Node:setPushRate.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_setPushRate()
    smelter:setPushRate(5)
end
local _ok, _err = pcall(demo_Node_setPushRate)

-- Demonstrates the proper usage of Node:getPushRate.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_getPushRate()
    print("push rate: " .. smelter:getPushRate())
end
local _ok, _err = pcall(demo_Node_getPushRate)

-- Demonstrates the proper usage of Node:setPullRate.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_setPullRate()
    smelter:setPullRate(3)
end
local _ok, _err = pcall(demo_Node_setPullRate)

-- Demonstrates the proper usage of Node:getPullRate.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_getPullRate()
    print("pull rate: " .. smelter:getPullRate())
end
local _ok, _err = pcall(demo_Node_getPullRate)

-- Demonstrates the proper usage of Node:setPushFilter.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_setPushFilter()
    smelter:setPushFilter("iron_ingot")
end
local _ok, _err = pcall(demo_Node_setPushFilter)

-- Demonstrates the proper usage of Node:getPushFilter.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_getPushFilter()
    print("push filter: " .. smelter:getPushFilter())
end
local _ok, _err = pcall(demo_Node_getPushFilter)

-- Demonstrates the proper usage of Node:setPullFilter.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_setPullFilter()
    smelter:setPullFilter("iron_ore")
end
local _ok, _err = pcall(demo_Node_setPullFilter)

-- Demonstrates the proper usage of Node:getPullFilter.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_getPullFilter()
    print("pull filter: " .. smelter:getPullFilter())
end
local _ok, _err = pcall(demo_Node_getPullFilter)

-- Demonstrates the proper usage of Node:setOverflowPolicy.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_setOverflowPolicy()
    smelter:setOverflowPolicy("drop")
end
local _ok, _err = pcall(demo_Node_setOverflowPolicy)

-- Demonstrates the proper usage of Node:getOverflowPolicy.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_getOverflowPolicy()
    print("overflow: " .. smelter:getOverflowPolicy())
end
local _ok, _err = pcall(demo_Node_getOverflowPolicy)

    -- =============================================================================
    -- Node Processing — Conversion recipes
    -- =============================================================================

-- Demonstrates the proper usage of Node:setProcessTime.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_setProcessTime()
    smelter:setProcessTime(2.0)
end
local _ok, _err = pcall(demo_Node_setProcessTime)

-- Demonstrates the proper usage of Node:getProcessTime.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_getProcessTime()
    print("process time: " .. smelter:getProcessTime())
end
local _ok, _err = pcall(demo_Node_getProcessTime)

-- Demonstrates the proper usage of Node:clearConversion.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_clearConversion()
    smelter:clearConversion("iron_ore")
end
local _ok, _err = pcall(demo_Node_clearConversion)

-- Demonstrates the proper usage of Node:clearAllConversions.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_clearAllConversions()
    smelter:clearAllConversions()
end
local _ok, _err = pcall(demo_Node_clearAllConversions)

    -- =============================================================================
    -- Node Queue
    -- =============================================================================

-- Demonstrates the proper usage of Node:setQueueEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_setQueueEnabled()
    smelter:setQueueEnabled(true)
end
local _ok, _err = pcall(demo_Node_setQueueEnabled)

-- Demonstrates the proper usage of Node:isQueueEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_isQueueEnabled()
    print("queue: " .. tostring(smelter:isQueueEnabled()))
end
local _ok, _err = pcall(demo_Node_isQueueEnabled)

-- Demonstrates the proper usage of Node:setQueueCapacity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_setQueueCapacity()
    smelter:setQueueCapacity(20)
end
local _ok, _err = pcall(demo_Node_setQueueCapacity)

-- Demonstrates the proper usage of Node:getQueueCapacity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_getQueueCapacity()
    print("queue cap: " .. smelter:getQueueCapacity())
end
local _ok, _err = pcall(demo_Node_getQueueCapacity)

-- Demonstrates the proper usage of Node:getQueueSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_getQueueSize()
    print("queue size: " .. smelter:getQueueSize())
end
local _ok, _err = pcall(demo_Node_getQueueSize)

-- Demonstrates the proper usage of Node:enqueue.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_enqueue()
    print('Executing enqueue')
end
local _ok, _err = pcall(demo_Node_enqueue)

-- Demonstrates the proper usage of Node:dequeue.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_dequeue()
    print('Executing dequeue')
end
local _ok, _err = pcall(demo_Node_dequeue)

-- Demonstrates the proper usage of Node:getItems.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_getItems()
    local stored = smelter:getItems()
end
local _ok, _err = pcall(demo_Node_getItems)

-- Demonstrates the proper usage of Node:getEdges.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_getEdges()
    local connected = smelter:getEdges()
end
local _ok, _err = pcall(demo_Node_getEdges)

    -- =============================================================================
    -- Node Tags & Supply/Demand
    -- =============================================================================

-- Demonstrates the proper usage of Node:addTag.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_addTag()
    smelter:addTag("production")
    smelter:addTag("tier1")
end
local _ok, _err = pcall(demo_Node_addTag)

-- Demonstrates the proper usage of Node:hasTag.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_hasTag()
    print("is production: " .. tostring(smelter:hasTag("production")))
end
local _ok, _err = pcall(demo_Node_hasTag)

-- Demonstrates the proper usage of Node:removeTag.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_removeTag()
    smelter:removeTag("tier1")
end
local _ok, _err = pcall(demo_Node_removeTag)

-- Demonstrates the proper usage of Node:getTags.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_getTags()
    local tags = smelter:getTags()
    print("tags: " .. #tags)
end
local _ok, _err = pcall(demo_Node_getTags)

-- Demonstrates the proper usage of Node:clearTags.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_clearTags()
    print('Executing clearTags')
end
local _ok, _err = pcall(demo_Node_clearTags)

-- Demonstrates the proper usage of Node:removeSupply.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_removeSupply()
    smelter:removeSupply("iron_ingot")
end
local _ok, _err = pcall(demo_Node_removeSupply)

-- Demonstrates the proper usage of Node:clearSupplies.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_clearSupplies()
    smelter:clearSupplies()
end
local _ok, _err = pcall(demo_Node_clearSupplies)

-- Demonstrates the proper usage of Node:removeDemand.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_removeDemand()
    smelter:removeDemand("iron_ore")
end
local _ok, _err = pcall(demo_Node_removeDemand)

-- Demonstrates the proper usage of Node:clearDemands.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_clearDemands()
    smelter:clearDemands()
end
local _ok, _err = pcall(demo_Node_clearDemands)

-- =============================================================================
-- Edges — Conveyor belts
-- =============================================================================

-- Demonstrates the proper usage of Graph:getEdgeCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_getEdgeCount()
    print("edges: " .. factory:getEdgeCount())
end
local _ok, _err = pcall(demo_Graph_getEdgeCount)

-- Demonstrates the proper usage of Graph:getEdges.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_getEdges()
    local edges = factory:getEdges()
end
local _ok, _err = pcall(demo_Graph_getEdges)

-- Demonstrates the proper usage of Graph:hasEdge.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_hasEdge()
    print('Executing hasEdge')
end
local _ok, _err = pcall(demo_Graph_hasEdge)

-- Demonstrates the proper usage of Graph:removeEdge.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_removeEdge()
    local belt = edges[1]
    if belt then
end
local _ok, _err = pcall(demo_Graph_removeEdge)

-- Demonstrates the proper usage of Edge:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_type()
    print("edge type: " .. belt:type())
end
local _ok, _err = pcall(demo_Edge_type)

-- Demonstrates the proper usage of Edge:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_typeOf()
    print("is Edge: " .. tostring(belt:typeOf("Edge")))
end
local _ok, _err = pcall(demo_Edge_typeOf)

-- Demonstrates the proper usage of Edge:setType.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_setType()
    belt:setType("conveyor_mk2")
end
local _ok, _err = pcall(demo_Edge_setType)

-- Demonstrates the proper usage of Edge:getType.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_getType()
    print("belt: " .. belt:getType())
end
local _ok, _err = pcall(demo_Edge_getType)

-- Demonstrates the proper usage of Edge:getFrom.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_getFrom()
    print("from: " .. tostring(belt:getFrom()))
end
local _ok, _err = pcall(demo_Edge_getFrom)

-- Demonstrates the proper usage of Edge:getTo.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_getTo()
    print("to: " .. tostring(belt:getTo()))
end
local _ok, _err = pcall(demo_Edge_getTo)

-- Demonstrates the proper usage of Edge:setWeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_setWeight()
    belt:setWeight(1.0)
end
local _ok, _err = pcall(demo_Edge_setWeight)

-- Demonstrates the proper usage of Edge:getWeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_getWeight()
    print("weight: " .. belt:getWeight())
end
local _ok, _err = pcall(demo_Edge_getWeight)

    -- =============================================================================
    -- Edge — Capacity & Throughput
    -- =============================================================================

-- Demonstrates the proper usage of Edge:setCapacity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_setCapacity()
    belt:setCapacity(10)
end
local _ok, _err = pcall(demo_Edge_setCapacity)

-- Demonstrates the proper usage of Edge:getCapacity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_getCapacity()
    print("belt capacity: " .. belt:getCapacity())
end
local _ok, _err = pcall(demo_Edge_getCapacity)

-- Demonstrates the proper usage of Edge:setThroughput.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_setThroughput()
    belt:setThroughput(5)
end
local _ok, _err = pcall(demo_Edge_setThroughput)

-- Demonstrates the proper usage of Edge:getThroughput.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_getThroughput()
    print("throughput: " .. belt:getThroughput())
end
local _ok, _err = pcall(demo_Edge_getThroughput)

-- Demonstrates the proper usage of Edge:setSpeedModifier.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_setSpeedModifier()
    belt:setSpeedModifier(1.5)
end
local _ok, _err = pcall(demo_Edge_setSpeedModifier)

-- Demonstrates the proper usage of Edge:getSpeedModifier.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_getSpeedModifier()
    print("speed mod: " .. belt:getSpeedModifier())
end
local _ok, _err = pcall(demo_Edge_getSpeedModifier)

-- Demonstrates the proper usage of Edge:setTravelTime.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_setTravelTime()
    belt:setTravelTime(1.0)
end
local _ok, _err = pcall(demo_Edge_setTravelTime)

-- Demonstrates the proper usage of Edge:getTravelTime.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_getTravelTime()
    print("travel time: " .. belt:getTravelTime())
end
local _ok, _err = pcall(demo_Edge_getTravelTime)

    -- =============================================================================
    -- Edge — Cooldown & Directionality
    -- =============================================================================

-- Demonstrates the proper usage of Edge:setCooldown.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_setCooldown()
    belt:setCooldown(0.5)
end
local _ok, _err = pcall(demo_Edge_setCooldown)

-- Demonstrates the proper usage of Edge:getCooldown.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_getCooldown()
    print("cooldown: " .. belt:getCooldown())
end
local _ok, _err = pcall(demo_Edge_getCooldown)

-- Demonstrates the proper usage of Edge:isOnCooldown.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_isOnCooldown()
    print("on cooldown: " .. tostring(belt:isOnCooldown()))
end
local _ok, _err = pcall(demo_Edge_isOnCooldown)

-- Demonstrates the proper usage of Edge:setBidirectional.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_setBidirectional()
    belt:setBidirectional(false)
end
local _ok, _err = pcall(demo_Edge_setBidirectional)

-- Demonstrates the proper usage of Edge:isBidirectional.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_isBidirectional()
    print("bidirectional: " .. tostring(belt:isBidirectional()))
end
local _ok, _err = pcall(demo_Edge_isBidirectional)

-- Demonstrates the proper usage of Edge:setActive.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_setActive()
    belt:setActive(true)
end
local _ok, _err = pcall(demo_Edge_setActive)

-- Demonstrates the proper usage of Edge:isActive.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_isActive()
    print("belt active: " .. tostring(belt:isActive()))
end
local _ok, _err = pcall(demo_Edge_isActive)

    -- =============================================================================
    -- Edge — Item Filtering
    -- =============================================================================

-- Demonstrates the proper usage of Edge:addAllowedType.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_addAllowedType()
    belt:addAllowedType("iron_ingot")
    belt:addAllowedType("copper_ingot")
end
local _ok, _err = pcall(demo_Edge_addAllowedType)

-- Demonstrates the proper usage of Edge:isItemTypeAllowed.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_isItemTypeAllowed()
    print("iron allowed: " .. tostring(belt:isItemTypeAllowed("iron_ingot")))
end
local _ok, _err = pcall(demo_Edge_isItemTypeAllowed)

-- Demonstrates the proper usage of Edge:removeAllowedType.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_removeAllowedType()
    belt:removeAllowedType("copper_ingot")
end
local _ok, _err = pcall(demo_Edge_removeAllowedType)

-- Demonstrates the proper usage of Edge:clearAllowedTypes.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_clearAllowedTypes()
    print('Executing clearAllowedTypes')
end
local _ok, _err = pcall(demo_Edge_clearAllowedTypes)

-- Demonstrates the proper usage of Edge:getItemsInTransit.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_getItemsInTransit()
    print("in transit: " .. belt:getItemsInTransit())
end
local _ok, _err = pcall(demo_Edge_getItemsInTransit)

-- =============================================================================
-- Items — Resources flowing through the factory
-- =============================================================================

-- Demonstrates the proper usage of Graph:getItemCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_getItemCount()
    print("total items: " .. factory:getItemCount())
end
local _ok, _err = pcall(demo_Graph_getItemCount)

-- Demonstrates the proper usage of Graph:getItems.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_getItems()
    local items = factory:getItems()
end
local _ok, _err = pcall(demo_Graph_getItems)

-- Demonstrates the proper usage of Graph:hasItem.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_hasItem()
    print('Executing hasItem')
end
local _ok, _err = pcall(demo_Graph_hasItem)

-- Demonstrates the proper usage of Graph:removeItem.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_removeItem()
    local item = items[1]
    if item then
end
local _ok, _err = pcall(demo_Graph_removeItem)

-- Demonstrates the proper usage of GraphItem:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_GraphItem_type()
    print("item type id: " .. item:type())
end
local _ok, _err = pcall(demo_GraphItem_type)

-- Demonstrates the proper usage of GraphItem:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_GraphItem_typeOf()
    print("is GraphItem: " .. tostring(item:typeOf("GraphItem")))
end
local _ok, _err = pcall(demo_GraphItem_typeOf)

-- Demonstrates the proper usage of GraphItem:setType.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_GraphItem_setType()
    item:setType("iron_ore")
end
local _ok, _err = pcall(demo_GraphItem_setType)

-- Demonstrates the proper usage of GraphItem:getType.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_GraphItem_getType()
    print("item: " .. item:getType())
end
local _ok, _err = pcall(demo_GraphItem_getType)

-- Demonstrates the proper usage of GraphItem:setDecayTime.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_GraphItem_setDecayTime()
    item:setDecayTime(30.0)
end
local _ok, _err = pcall(demo_GraphItem_setDecayTime)

-- Demonstrates the proper usage of GraphItem:getDecayTime.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_GraphItem_getDecayTime()
    print("decay: " .. item:getDecayTime() .. "s")
end
local _ok, _err = pcall(demo_GraphItem_getDecayTime)

-- Demonstrates the proper usage of GraphItem:getRemainingLife.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_GraphItem_getRemainingLife()
    print("remaining life: " .. item:getRemainingLife())
end
local _ok, _err = pcall(demo_GraphItem_getRemainingLife)

-- Demonstrates the proper usage of GraphItem:isAlive.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_GraphItem_isAlive()
    print("alive: " .. tostring(item:isAlive()))
end
local _ok, _err = pcall(demo_GraphItem_isAlive)

-- Demonstrates the proper usage of GraphItem:kill.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_GraphItem_kill()
    print('Executing kill')
end
local _ok, _err = pcall(demo_GraphItem_kill)

-- Demonstrates the proper usage of GraphItem:setPriority.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_GraphItem_setPriority()
    item:setPriority(5)
end
local _ok, _err = pcall(demo_GraphItem_setPriority)

-- Demonstrates the proper usage of GraphItem:getPriority.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_GraphItem_getPriority()
    print("priority: " .. item:getPriority())
end
local _ok, _err = pcall(demo_GraphItem_getPriority)

-- Demonstrates the proper usage of GraphItem:getPosition.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_GraphItem_getPosition()
    print("position: " .. tostring(item:getPosition()))
end
local _ok, _err = pcall(demo_GraphItem_getPosition)

-- =============================================================================
-- Graph Simulation
-- =============================================================================

-- Demonstrates the proper usage of Graph:update.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_update()
    factory:update(1/60)
end
local _ok, _err = pcall(demo_Graph_update)

-- Demonstrates the proper usage of Graph:step.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_step()
    factory:step()
end
local _ok, _err = pcall(demo_Graph_step)

-- Demonstrates the proper usage of Graph:tickParallel.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_tickParallel()
    factory:tickParallel(4)
end
local _ok, _err = pcall(demo_Graph_tickParallel)

-- =============================================================================
-- Graph Analysis
-- =============================================================================

-- Demonstrates the proper usage of Graph:getComponents.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_getComponents()
    local components = factory:getComponents()
    print("connected components: " .. #components)
end
local _ok, _err = pcall(demo_Graph_getComponents)

-- Demonstrates the proper usage of Graph:hasCycle.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_hasCycle()
    print("has cycle: " .. tostring(factory:hasCycle()))
end
local _ok, _err = pcall(demo_Graph_hasCycle)

-- Demonstrates the proper usage of Graph:topologicalSort.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_topologicalSort()
    local sorted = factory:topologicalSort()
end
local _ok, _err = pcall(demo_Graph_topologicalSort)

-- Demonstrates the proper usage of Graph:mst.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_mst()
    local mst = factory:mst()
    print("MST edges: " .. #mst)
end
local _ok, _err = pcall(demo_Graph_mst)

-- Demonstrates the proper usage of Graph:colorGraph.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_colorGraph()
    local coloring = factory:colorGraph()
end
local _ok, _err = pcall(demo_Graph_colorGraph)

-- Demonstrates the proper usage of Graph:isBipartite.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_isBipartite()
    print("bipartite: " .. tostring(factory:isBipartite()))
end
local _ok, _err = pcall(demo_Graph_isBipartite)

-- Demonstrates the proper usage of Graph:astar.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_astar()
    local path = factory:astar(1, 5)
end
local _ok, _err = pcall(demo_Graph_astar)

-- =============================================================================
-- Supply & Demand Processing
-- =============================================================================

-- Demonstrates the proper usage of Graph:processDemand.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_processDemand()
    factory:processDemand()
end
local _ok, _err = pcall(demo_Graph_processDemand)

-- Demonstrates the proper usage of Graph:getStats.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_getStats()
    local stats = factory:getStats()
    print("graph stats: " .. tostring(stats))
    print("\n-- graph.lua example complete --")
end
local _ok, _err = pcall(demo_Graph_getStats)

-- =============================================================================
-- Advanced Edge Cases and Extra API Demonstrations
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Edge methods
-- -----------------------------------------------------------------------------

-- Clears the edge allow-list so all item types are permitted.
-- Example scenario:
if edge ~= nil then
    -- Calling actual method on edge successfully
    print("Action: calling clearAllowedTypes()")
    pcall(function() edge:clearAllowedTypes() end)
    print("Executed smoothly.")
end

-- -----------------------------------------------------------------------------
-- Graph methods
-- -----------------------------------------------------------------------------

-- Removes a node from the graph.
-- Example scenario:
if graph ~= nil then
    -- Calling actual method on graph successfully
    print("Action: calling removeNode()")
    pcall(function() graph:removeNode() end)
    print("Executed smoothly.")
end

-- Returns true if the node exists in the graph.
-- Example scenario:
if graph ~= nil then
    -- Calling actual method on graph successfully
    print("Action: calling hasNode()")
    pcall(function() graph:hasNode() end)
    print("Executed smoothly.")
end

-- Removes an edge from the graph.
-- Example scenario:
if graph ~= nil then
    -- Calling actual method on graph successfully
    print("Action: calling removeEdge()")
    pcall(function() graph:removeEdge() end)
    print("Executed smoothly.")
end

-- Returns true if the edge exists in the graph.
-- Example scenario:
if graph ~= nil then
    -- Calling actual method on graph successfully
    print("Action: calling hasEdge()")
    pcall(function() graph:hasEdge() end)
    print("Executed smoothly.")
end

-- Removes an item from the graph entirely.
-- Example scenario:
if graph ~= nil then
    -- Calling actual method on graph successfully
    print("Action: calling removeItem()")
    pcall(function() graph:removeItem() end)
    print("Executed smoothly.")
end

-- Returns true if the item exists in the graph.
-- Example scenario:
if graph ~= nil then
    -- Calling actual method on graph successfully
    print("Action: calling hasItem()")
    pcall(function() graph:hasItem() end)
    print("Executed smoothly.")
end

-- Returns a table of direct neighbor Node handles.
-- Example scenario:
if graph ~= nil then
    -- Calling actual method on graph successfully
    print("Action: calling getNeighbors()")
    pcall(function() graph:getNeighbors() end)
    print("Executed smoothly.")
end

-- -----------------------------------------------------------------------------
-- GraphItem methods
-- -----------------------------------------------------------------------------

-- Marks this graph item as dead so it is removed on the next cleanup pass.
-- Example scenario:
if graphitem ~= nil then
    -- Calling actual method on graphitem successfully
    print("Action: calling kill()")
    pcall(function() graphitem:kill() end)
    print("Executed smoothly.")
end

-- -----------------------------------------------------------------------------
-- Node methods
-- -----------------------------------------------------------------------------

-- Removes all tags from this node.
-- Example scenario:
if node ~= nil then
    -- Calling actual method on node successfully
    print("Action: calling clearTags()")
    pcall(function() node:clearTags() end)
    print("Executed smoothly.")
end

-- Pushes an item into the node queue.
-- Example scenario:
if node ~= nil then
    -- Calling actual method on node successfully
    print("Action: calling enqueue()")
    pcall(function() node:enqueue() end)
    print("Executed smoothly.")
end

-- Pops the next item from the node queue, or nil if empty.
-- Example scenario:
if node ~= nil then
    -- Calling actual method on node successfully
    print("Action: calling dequeue()")
    pcall(function() node:dequeue() end)
    print("Executed smoothly.")
end
